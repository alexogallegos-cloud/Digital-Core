"""
Paso 3 — Despliegue en AWS (Lambda + API Gateway + S3 website).

Costo: GRATIS en AWS free tier + centavos de Bedrock por uso.
No crea OpenSearch Serverless ni Bedrock KB.

Prerequisitos:
  - python 01-prepare-docs.py  (genera documents/)
  - python 02-index-pinecone.py  (indexa en Pinecone)
  - PINECONE_API_KEY y PINECONE_INDEX_HOST configurados en config.py
  - AWS credentials con permisos: IAM, Lambda, API Gateway, S3

Uso:
  python 03-deploy-aws.py
"""

import boto3
import io
import json
import pathlib
import sys
import time
import zipfile

from botocore.exceptions import ClientError

from config import (
    AWS_REGION, AWS_PROFILE, PROJECT_SLUG,
    WEBSITE_BUCKET, LAMBDA_NAME,
    RESPONSE_MODEL_ID, EMBEDDING_DIMENSION,
    PINECONE_API_KEY, PINECONE_INDEX_HOST,
    LAMBDA_DIR, FRONTEND_DIR, DEPLOY_STATE,
    SYSTEM_PROMPT,
)

REGION = AWS_REGION

session = boto3.Session(profile_name=AWS_PROFILE, region_name=REGION)
iam     = session.client("iam")
lmb     = session.client("lambda", region_name=REGION)
apigw   = session.client("apigatewayv2", region_name=REGION)
s3      = session.client("s3", region_name=REGION)
sts     = session.client("sts")

state = json.loads(DEPLOY_STATE.read_text()) if DEPLOY_STATE.exists() else {}


def ok(m):   print(f"  ✓  {m}")
def skip(m): print(f"  →  {m} (ya existe)")
def info(m): print(f"  ·  {m}")
def step(n, t): print(f"\n[{n}] {t}")


account_id = sts.get_caller_identity()["Account"]


# ─── 1. IAM rol para Lambda ────────────────────────────────────────────────────
def create_lambda_role() -> str:
    step("1/3", "IAM — Rol para Lambda")
    role_name = f"{PROJECT_SLUG}-lambda-role"

    if state.get("lambda_role_arn"):
        skip(role_name)
        return state["lambda_role_arn"]

    trust = json.dumps({
        "Version": "2012-10-17",
        "Statement": [{
            "Effect": "Allow",
            "Principal": {"Service": "lambda.amazonaws.com"},
            "Action": "sts:AssumeRole",
        }]
    })

    try:
        role_arn = iam.create_role(
            RoleName=role_name,
            AssumeRolePolicyDocument=trust,
            Description="Lambda rol para GemCog Chatbot",
        )["Role"]["Arn"]
    except ClientError as e:
        if e.response["Error"]["Code"] == "EntityAlreadyExists":
            role_arn = iam.get_role(RoleName=role_name)["Role"]["Arn"]
        else:
            raise

    policy = {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Action": ["logs:CreateLogGroup", "logs:CreateLogStream",
                           "logs:PutLogEvents"],
                "Resource": "arn:aws:logs:*:*:*",
            },
            {
                "Effect": "Allow",
                "Action": ["bedrock:InvokeModel"],
                "Resource": "*",
            },
        ]
    }
    pol_name = f"{PROJECT_SLUG}-lambda-policy"
    try:
        pol_arn = iam.create_policy(
            PolicyName=pol_name,
            PolicyDocument=json.dumps(policy),
        )["Policy"]["Arn"]
    except ClientError as e:
        if e.response["Error"]["Code"] == "EntityAlreadyExists":
            pol_arn = f"arn:aws:iam::{account_id}:policy/{pol_name}"
        else:
            raise

    try:
        iam.attach_role_policy(RoleName=role_name, PolicyArn=pol_arn)
    except ClientError:
        pass

    ok(f"Rol {role_name}")
    time.sleep(10)  # IAM propagation

    state["lambda_role_arn"] = role_arn
    _save()
    return role_arn


# ─── 2. Lambda + API Gateway ──────────────────────────────────────────────────
def deploy_lambda_and_api(role_arn: str) -> str:
    step("2/3", "Lambda + API Gateway")

    if state.get("api_endpoint"):
        # Actualizar código de Lambda aunque ya exista
        _update_lambda()
        skip(f"API {state['api_id']}")
        return state["api_endpoint"]

    # Empaquetar handler
    zip_bytes = _package_lambda()

    env_vars = {
        "PINECONE_INDEX_HOST": PINECONE_INDEX_HOST,
        "PINECONE_API_KEY":    PINECONE_API_KEY,
        "BEDROCK_REGION":      REGION,
        "RESPONSE_MODEL_ID":   RESPONSE_MODEL_ID,
        "SYSTEM_PROMPT":       SYSTEM_PROMPT,
    }

    # Lambda
    try:
        fn = lmb.create_function(
            FunctionName=LAMBDA_NAME,
            Runtime="python3.12",
            Role=role_arn,
            Handler="handler.handler",
            Code={"ZipFile": zip_bytes},
            Timeout=60,
            MemorySize=512,
            Environment={"Variables": env_vars},
        )
        lambda_arn = fn["FunctionArn"]
    except ClientError as e:
        if e.response["Error"]["Code"] == "ResourceConflictException":
            lmb.update_function_code(FunctionName=LAMBDA_NAME, ZipFile=zip_bytes)
            lmb.update_function_configuration(
                FunctionName=LAMBDA_NAME,
                Environment={"Variables": env_vars},
                Timeout=60, MemorySize=512,
            )
            lambda_arn = lmb.get_function_configuration(
                FunctionName=LAMBDA_NAME
            )["FunctionArn"]
        else:
            raise
    ok(f"Lambda {LAMBDA_NAME}")
    time.sleep(5)

    # API Gateway HTTP
    api = apigw.create_api(
        Name=f"{PROJECT_SLUG}-api",
        ProtocolType="HTTP",
        CorsConfiguration={
            "AllowHeaders": ["Content-Type"],
            "AllowMethods": ["POST", "OPTIONS"],
            "AllowOrigins": ["*"],
        },
    )
    api_id = api["ApiId"]

    integ = apigw.create_integration(
        ApiId=api_id,
        IntegrationType="AWS_PROXY",
        IntegrationUri=lambda_arn,
        PayloadFormatVersion="2.0",
    )
    apigw.create_route(
        ApiId=api_id,
        RouteKey="POST /chat",
        Target=f"integrations/{integ['IntegrationId']}",
    )
    apigw.create_stage(ApiId=api_id, StageName="$default", AutoDeploy=True)

    try:
        lmb.add_permission(
            FunctionName=LAMBDA_NAME,
            StatementId="apigw-invoke",
            Action="lambda:InvokeFunction",
            Principal="apigateway.amazonaws.com",
            SourceArn=f"arn:aws:execute-api:{REGION}:{account_id}:{api_id}/*",
        )
    except ClientError as e:
        if e.response["Error"]["Code"] != "ResourceConflictException":
            raise

    api_endpoint = f"https://{api_id}.execute-api.{REGION}.amazonaws.com/chat"
    ok(f"API: {api_endpoint}")

    state["api_id"]       = api_id
    state["api_endpoint"] = api_endpoint
    _save()
    return api_endpoint


def _package_lambda() -> bytes:
    handler_path = LAMBDA_DIR / "handler.py"
    buf = io.BytesIO()
    with zipfile.ZipFile(buf, "w", zipfile.ZIP_DEFLATED) as zf:
        zf.write(str(handler_path), "handler.py")
    return buf.getvalue()


def _update_lambda():
    info("Actualizando código de Lambda...")
    zip_bytes = _package_lambda()
    lmb.update_function_code(FunctionName=LAMBDA_NAME, ZipFile=zip_bytes)
    lmb.update_function_configuration(
        FunctionName=LAMBDA_NAME,
        Environment={"Variables": {
            "PINECONE_INDEX_HOST": PINECONE_INDEX_HOST,
            "PINECONE_API_KEY":    PINECONE_API_KEY,
            "BEDROCK_REGION":      REGION,
            "RESPONSE_MODEL_ID":   RESPONSE_MODEL_ID,
            "SYSTEM_PROMPT":       SYSTEM_PROMPT,
        }},
    )
    ok("Lambda actualizada")


# ─── 3. S3 Website ────────────────────────────────────────────────────────────
def deploy_frontend(api_endpoint: str) -> str:
    step("3/3", "S3 Static Website")

    try:
        if REGION == "us-east-1":
            s3.create_bucket(Bucket=WEBSITE_BUCKET)
        else:
            s3.create_bucket(
                Bucket=WEBSITE_BUCKET,
                CreateBucketConfiguration={"LocationConstraint": REGION},
            )
        ok(f"Bucket {WEBSITE_BUCKET}")
    except ClientError as e:
        code = e.response["Error"]["Code"]
        if code in ("BucketAlreadyOwnedByYou", "BucketAlreadyExists"):
            skip(f"Bucket {WEBSITE_BUCKET}")
        else:
            raise

    s3.put_public_access_block(
        Bucket=WEBSITE_BUCKET,
        PublicAccessBlockConfiguration={
            "BlockPublicAcls": False, "IgnorePublicAcls": False,
            "BlockPublicPolicy": False, "RestrictPublicBuckets": False,
        },
    )
    s3.put_bucket_website(
        Bucket=WEBSITE_BUCKET,
        WebsiteConfiguration={
            "IndexDocument": {"Suffix": "index.html"},
            "ErrorDocument": {"Key": "index.html"},
        },
    )
    s3.put_bucket_policy(
        Bucket=WEBSITE_BUCKET,
        Policy=json.dumps({
            "Version": "2012-10-17",
            "Statement": [{
                "Effect": "Allow", "Principal": "*",
                "Action": "s3:GetObject",
                "Resource": f"arn:aws:s3:::{WEBSITE_BUCKET}/*",
            }],
        }),
    )

    html = (FRONTEND_DIR / "index.html").read_text(encoding="utf-8")
    html = html.replace("{{API_ENDPOINT}}", api_endpoint)
    s3.put_object(
        Bucket=WEBSITE_BUCKET, Key="index.html",
        Body=html.encode("utf-8"),
        ContentType="text/html; charset=utf-8",
    )

    website_url = (
        f"http://{WEBSITE_BUCKET}.s3-website-{REGION}.amazonaws.com"
        if REGION == "us-east-1"
        else f"http://{WEBSITE_BUCKET}.s3-website.{REGION}.amazonaws.com"
    )
    ok(f"Frontend: {website_url}")
    state["website_url"] = website_url
    _save()
    return website_url


def _save():
    DEPLOY_STATE.write_text(json.dumps(state, indent=2))


# ─── Orquestador ──────────────────────────────────────────────────────────────
def main():
    if PINECONE_API_KEY == "YOUR_PINECONE_API_KEY":
        print("✗  Edita config.py y agrega tu PINECONE_API_KEY antes de continuar.")
        sys.exit(1)

    print("\n╔══════════════════════════════════════════════════════════════╗")
    print("║   GemCog Chatbot — Deploy AWS (opción gratuita)             ║")
    print("╚══════════════════════════════════════════════════════════════╝\n")

    role_arn     = create_lambda_role()
    api_endpoint = deploy_lambda_and_api(role_arn)
    website_url  = deploy_frontend(api_endpoint)

    print("\n╔══════════════════════════════════════════════════════════════╗")
    print("║   ✓  Listo                                                  ║")
    print("╚══════════════════════════════════════════════════════════════╝")
    print(f"\n  🌐  Chatbot : {website_url}")
    print(f"  🔌  API     : {api_endpoint}")
    print(f"\n  Costo mensual estimado: ~$0 infraestructura + centavos de Bedrock\n")


if __name__ == "__main__":
    main()
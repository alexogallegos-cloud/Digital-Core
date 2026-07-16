"""
Paso 2 — Despliegue de infraestructura AWS para el chatbot GemCog.

Crea en orden:
  1. IAM roles (Bedrock KB + Lambda)
  2. S3 bucket de documentos + carga
  3. OpenSearch Serverless (colección vectorial + índice)
  4. Bedrock Knowledge Base + Data Source + Sync
  5. Lambda function
  6. API Gateway HTTP
  7. S3 bucket website + HTML

Prerequisitos:
  - pip install -r requirements.txt
  - python 01-prepare-docs.py  (genera carpeta documents/)
  - AWS credentials configuradas (aws configure o variables de entorno)
  - Acceso habilitado al modelo en Amazon Bedrock console
    (Bedrock → Model access → habilitar Titan Embed v2 + Claude 3.5 Sonnet)

Uso:
  python 02-deploy.py

El script es reutilizable: detecta recursos existentes vía .deploy-state.json
y los reutiliza en lugar de recrearlos.
"""

import boto3
import json
import pathlib
import sys
import time
import io
import zipfile

from botocore.exceptions import ClientError

from config import (
    AWS_REGION, AWS_PROFILE, PROJECT_SLUG,
    DOCS_BUCKET, WEBSITE_BUCKET,
    AOSS_COLLECTION, AOSS_INDEX,
    KB_NAME, LAMBDA_NAME,
    EMBEDDING_MODEL_ARN, EMBEDDING_DIMENSION,
    RESPONSE_MODEL_ID, MAX_RETRIEVAL_RESULTS,
    DOCUMENTS_DIR, LAMBDA_DIR, FRONTEND_DIR, DEPLOY_STATE,
    SYSTEM_PROMPT,
)

REGION = AWS_REGION

# ─── Clientes AWS ─────────────────────────────────────────────────────────────
session    = boto3.Session(profile_name=AWS_PROFILE, region_name=REGION)
iam        = session.client("iam")
s3         = session.client("s3", region_name=REGION)
aoss       = session.client("opensearchserverless", region_name=REGION)
bedrock    = session.client("bedrock-agent", region_name=REGION)
lmb        = session.client("lambda", region_name=REGION)
apigw      = session.client("apigatewayv2", region_name=REGION)
sts        = session.client("sts")

# ─── Estado persistente ───────────────────────────────────────────────────────
def load_state() -> dict:
    if DEPLOY_STATE.exists():
        return json.loads(DEPLOY_STATE.read_text())
    return {}

def save_state(state: dict):
    DEPLOY_STATE.write_text(json.dumps(state, indent=2))

state = load_state()


# ─── Helpers ──────────────────────────────────────────────────────────────────
def ok(msg):    print(f"  ✓  {msg}")
def skip(msg):  print(f"  →  {msg} (ya existe)")
def info(msg):  print(f"  ·  {msg}")
def warn(msg):  print(f"  ⚠  {msg}")
def step(n, t): print(f"\n[{n}] {t}")

def wait_active(label, check_fn, interval=20, max_wait=600):
    waited = 0
    while waited < max_wait:
        status = check_fn()
        info(f"{label}: {status}")
        if status in ("ACTIVE", "COMPLETE", "CREATING_FAILED", "FAILED"):
            return status
        time.sleep(interval)
        waited += interval
    raise TimeoutError(f"Timeout esperando {label}")


# ─── 0. Account ID ────────────────────────────────────────────────────────────
account_id = sts.get_caller_identity()["Account"]
info(f"Account: {account_id} · Region: {REGION}")


# ─── 1. IAM — Rol para Bedrock KB ────────────────────────────────────────────
def create_kb_role() -> str:
    step("1/7", "IAM — Rol para Bedrock KB")
    role_name = f"{PROJECT_SLUG}-bedrock-kb-role"

    if state.get("kb_role_arn"):
        skip(role_name)
        return state["kb_role_arn"]

    trust = json.dumps({
        "Version": "2012-10-17",
        "Statement": [{
            "Effect": "Allow",
            "Principal": {"Service": "bedrock.amazonaws.com"},
            "Action": "sts:AssumeRole",
            "Condition": {
                "StringEquals": {"aws:SourceAccount": account_id},
                "ArnLike": {
                    "aws:SourceArn":
                        f"arn:aws:bedrock:{REGION}:{account_id}:knowledge-base/*"
                }
            }
        }]
    })

    try:
        resp = iam.create_role(RoleName=role_name, AssumeRolePolicyDocument=trust)
        role_arn = resp["Role"]["Arn"]
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
                "Action": ["s3:GetObject", "s3:ListBucket"],
                "Resource": [
                    f"arn:aws:s3:::{DOCS_BUCKET}",
                    f"arn:aws:s3:::{DOCS_BUCKET}/*"
                ]
            },
            {
                "Effect": "Allow",
                "Action": ["bedrock:InvokeModel"],
                "Resource": f"arn:aws:bedrock:{REGION}::foundation-model/*"
            },
            {
                "Effect": "Allow",
                "Action": ["aoss:APIAccessAll"],
                "Resource":
                    f"arn:aws:aoss:{REGION}:{account_id}:collection/*"
            }
        ]
    }

    policy_name = f"{PROJECT_SLUG}-kb-policy"
    try:
        pol = iam.create_policy(
            PolicyName=policy_name,
            PolicyDocument=json.dumps(policy)
        )
        policy_arn = pol["Policy"]["Arn"]
    except ClientError as e:
        if e.response["Error"]["Code"] == "EntityAlreadyExists":
            policy_arn = (
                f"arn:aws:iam::{account_id}:policy/{policy_name}"
            )
        else:
            raise

    try:
        iam.attach_role_policy(RoleName=role_name, PolicyArn=policy_arn)
    except ClientError as e:
        if "already attached" not in str(e):
            raise

    ok(f"Rol {role_name}")
    time.sleep(8)  # IAM eventual consistency
    state["kb_role_arn"] = role_arn
    save_state(state)
    return role_arn


# ─── 2. S3 — Bucket de documentos + carga ────────────────────────────────────
def setup_docs_bucket():
    step("2/7", "S3 — Bucket de documentos + carga")

    # Crear bucket
    try:
        if REGION == "us-east-1":
            s3.create_bucket(Bucket=DOCS_BUCKET)
        else:
            s3.create_bucket(
                Bucket=DOCS_BUCKET,
                CreateBucketConfiguration={"LocationConstraint": REGION}
            )
        ok(f"Bucket {DOCS_BUCKET}")
    except ClientError as e:
        code = e.response["Error"]["Code"]
        if code in ("BucketAlreadyOwnedByYou", "BucketAlreadyExists"):
            skip(f"Bucket {DOCS_BUCKET}")
        else:
            raise

    # Bloquear acceso público (solo Bedrock accede)
    s3.put_public_access_block(
        Bucket=DOCS_BUCKET,
        PublicAccessBlockConfiguration={
            "BlockPublicAcls": True,
            "IgnorePublicAcls": True,
            "BlockPublicPolicy": True,
            "RestrictPublicBuckets": True,
        }
    )

    # Subir documentos
    if not DOCUMENTS_DIR.exists():
        print("  ✗  Carpeta 'documents/' no encontrada. Ejecuta primero: python 01-prepare-docs.py")
        sys.exit(1)

    files = [f for f in DOCUMENTS_DIR.rglob("*") if f.is_file()]
    info(f"Subiendo {len(files)} archivos a s3://{DOCS_BUCKET}/")
    for f in files:
        key = f"documents/{f.relative_to(DOCUMENTS_DIR).as_posix()}"
        content_type = (
            "text/html"       if f.suffix == ".html" else
            "text/markdown"   if f.suffix == ".md"   else
            "text/plain"
        )
        s3.upload_file(
            str(f), DOCS_BUCKET, key,
            ExtraArgs={"ContentType": content_type}
        )
    ok(f"{len(files)} archivos cargados")


# ─── 3. OpenSearch Serverless ─────────────────────────────────────────────────
def setup_aoss(kb_role_arn: str) -> tuple[str, str]:
    step("3/7", "OpenSearch Serverless — Colección vectorial + índice")
    enc_name = f"{PROJECT_SLUG}-enc"
    net_name = f"{PROJECT_SLUG}-net"
    acc_name = f"{PROJECT_SLUG}-access"

    # Encryption policy
    try:
        aoss.create_security_policy(
            name=enc_name, type="encryption",
            policy=json.dumps({
                "Rules": [{
                    "Resource": [f"collection/{AOSS_COLLECTION}"],
                    "ResourceType": "collection"
                }],
                "AWSOwnedKey": True
            })
        )
        ok(f"Encryption policy {enc_name}")
    except ClientError as e:
        if e.response["Error"]["Code"] == "ConflictException":
            skip(enc_name)
        else:
            raise

    # Network policy
    try:
        aoss.create_security_policy(
            name=net_name, type="network",
            policy=json.dumps([{
                "Rules": [
                    {"Resource": [f"collection/{AOSS_COLLECTION}"],
                     "ResourceType": "dashboard"},
                    {"Resource": [f"collection/{AOSS_COLLECTION}"],
                     "ResourceType": "collection"}
                ],
                "AllowFromPublic": True
            }])
        )
        ok(f"Network policy {net_name}")
    except ClientError as e:
        if e.response["Error"]["Code"] == "ConflictException":
            skip(net_name)
        else:
            raise

    # Crear colección
    if state.get("aoss_collection_id"):
        collection_id = state["aoss_collection_id"]
        endpoint      = state["aoss_endpoint"]
        skip(f"Colección {AOSS_COLLECTION} ({collection_id})")
    else:
        try:
            resp = aoss.create_collection(
                name=AOSS_COLLECTION, type="VECTORSEARCH"
            )
            collection_id = resp["createCollectionDetail"]["id"]
            ok(f"Colección {AOSS_COLLECTION} — esperando ACTIVE...")
        except ClientError as e:
            if e.response["Error"]["Code"] == "ConflictException":
                resp = aoss.batch_get_collection(names=[AOSS_COLLECTION])
                collection_id = resp["collectionDetails"][0]["id"]
            else:
                raise

        def check_collection():
            r = aoss.batch_get_collection(names=[AOSS_COLLECTION])
            d = r["collectionDetails"][0]
            endpoint_val = d.get("collectionEndpoint", "")
            state["aoss_endpoint_tmp"] = endpoint_val
            return d["status"]

        status = wait_active("Colección AOSS", check_collection, interval=30)
        if status != "ACTIVE":
            raise RuntimeError(f"Colección AOSS falló: {status}")

        r = aoss.batch_get_collection(names=[AOSS_COLLECTION])
        endpoint = r["collectionDetails"][0]["collectionEndpoint"]
        state["aoss_collection_id"] = collection_id
        state["aoss_endpoint"]      = endpoint
        save_state(state)
        ok(f"Colección activa: {endpoint}")

    # Data access policy
    try:
        aoss.create_access_policy(
            name=acc_name, type="data",
            policy=json.dumps([{
                "Rules": [
                    {
                        "Resource": [f"collection/{AOSS_COLLECTION}"],
                        "Permission": [
                            "aoss:CreateCollectionItems",
                            "aoss:DeleteCollectionItems",
                            "aoss:UpdateCollectionItems",
                            "aoss:DescribeCollectionItems",
                        ],
                        "ResourceType": "collection"
                    },
                    {
                        "Resource": [f"index/{AOSS_COLLECTION}/*"],
                        "Permission": [
                            "aoss:CreateIndex",
                            "aoss:DeleteIndex",
                            "aoss:UpdateIndex",
                            "aoss:DescribeIndex",
                            "aoss:ReadDocument",
                            "aoss:WriteDocument",
                        ],
                        "ResourceType": "index"
                    }
                ],
                "Principal": [
                    kb_role_arn,
                    f"arn:aws:iam::{account_id}:root"
                ],
                "Description": "Bedrock KB + admin"
            }])
        )
        ok(f"Data access policy {acc_name}")
    except ClientError as e:
        if e.response["Error"]["Code"] == "ConflictException":
            skip(acc_name)
        else:
            raise

    # Crear índice vectorial
    if not state.get("aoss_index_created"):
        _create_aoss_index(endpoint)
        state["aoss_index_created"] = True
        save_state(state)
    else:
        skip(f"Índice {AOSS_INDEX}")

    return collection_id, endpoint


def _create_aoss_index(endpoint: str):
    """Crea el índice vectorial en OpenSearch Serverless."""
    from opensearchpy import OpenSearch, RequestsHttpConnection
    from requests_aws4auth import AWS4Auth
    import boto3.session as bs

    creds = session.get_credentials().get_frozen_credentials()
    auth  = AWS4Auth(
        creds.access_key, creds.secret_key,
        REGION, "aoss", session_token=creds.token
    )

    host = endpoint.replace("https://", "")
    os_client = OpenSearch(
        hosts=[{"host": host, "port": 443}],
        http_auth=auth,
        use_ssl=True,
        verify_certs=True,
        connection_class=RequestsHttpConnection,
        pool_maxsize=20,
        timeout=30,
    )

    body = {
        "settings": {
            "index.knn": True,
            "index.knn.algo_param.ef_search": 512,
        },
        "mappings": {
            "properties": {
                "bedrock-knowledge-base-default-vector": {
                    "type": "knn_vector",
                    "dimension": EMBEDDING_DIMENSION,
                    "method": {
                        "name": "hnsw",
                        "space_type": "l2",
                        "engine": "faiss",
                        "parameters": {"ef_construction": 512, "m": 16},
                    }
                },
                "AMAZON_BEDROCK_TEXT_CHUNK": {"type": "text"},
                "AMAZON_BEDROCK_METADATA":   {"type": "text", "index": False},
            }
        }
    }

    resp = os_client.indices.create(index=AOSS_INDEX, body=body)
    ok(f"Índice {AOSS_INDEX} creado: {resp}")


# ─── 4. Bedrock Knowledge Base ────────────────────────────────────────────────
def setup_knowledge_base(kb_role_arn: str, collection_id: str) -> tuple[str, str]:
    step("4/7", "Bedrock Knowledge Base + Data Source + Sync")

    if state.get("kb_id"):
        kb_id = state["kb_id"]
        ds_id = state["ds_id"]
        skip(f"KB {kb_id}")
    else:
        resp = bedrock.create_knowledge_base(
            name=KB_NAME,
            description=(
                "Gemelo Cognitivo S500 (Cargos & Abonos) + S151 "
                "(Movimientos Contables GL) — Banamex Unisys ClearPath MCP"
            ),
            roleArn=kb_role_arn,
            knowledgeBaseConfiguration={
                "type": "VECTOR",
                "vectorKnowledgeBaseConfiguration": {
                    "embeddingModelArn": EMBEDDING_MODEL_ARN,
                    "embeddingModelConfiguration": {
                        "bedrockEmbeddingModelConfiguration": {
                            "dimensions": EMBEDDING_DIMENSION
                        }
                    }
                }
            },
            storageConfiguration={
                "type": "OPENSEARCH_SERVERLESS",
                "opensearchServerlessConfiguration": {
                    "collectionArn":
                        f"arn:aws:aoss:{REGION}:{account_id}:collection/{collection_id}",
                    "vectorIndexName": AOSS_INDEX,
                    "fieldMapping": {
                        "vectorField":   "bedrock-knowledge-base-default-vector",
                        "textField":     "AMAZON_BEDROCK_TEXT_CHUNK",
                        "metadataField": "AMAZON_BEDROCK_METADATA",
                    }
                }
            }
        )
        kb_id = resp["knowledgeBase"]["knowledgeBaseId"]
        ok(f"Knowledge Base {kb_id}")

        # Data source
        ds = bedrock.create_data_source(
            knowledgeBaseId=kb_id,
            name="gemcog-s3-source",
            dataSourceConfiguration={
                "type": "S3",
                "s3Configuration": {
                    "bucketArn": f"arn:aws:s3:::{DOCS_BUCKET}",
                    "inclusionPrefixes": ["documents/"],
                }
            },
            vectorIngestionConfiguration={
                "chunkingConfiguration": {
                    "chunkingStrategy": "FIXED_SIZE",
                    "fixedSizeChunkingConfiguration": {
                        "maxTokens": 512,
                        "overlapPercentage": 10,
                    }
                }
            }
        )
        ds_id = ds["dataSource"]["dataSourceId"]
        ok(f"Data Source {ds_id}")

        state["kb_id"] = kb_id
        state["ds_id"] = ds_id
        save_state(state)

    # Sync
    info("Iniciando sincronización (puede tomar 5-15 min)...")
    job = bedrock.start_ingestion_job(
        knowledgeBaseId=kb_id,
        dataSourceId=ds_id
    )
    job_id = job["ingestionJob"]["ingestionJobId"]

    def check_sync():
        r = bedrock.get_ingestion_job(
            knowledgeBaseId=kb_id,
            dataSourceId=ds_id,
            ingestionJobId=job_id
        )
        j = r["ingestionJob"]
        docs = j.get("statistics", {})
        info(
            f"  Sync: {j['status']} | "
            f"indexados: {docs.get('numberOfDocumentsIndexed', 0)} | "
            f"fallidos: {docs.get('numberOfDocumentsFailed', 0)}"
        )
        return j["status"]

    status = wait_active("Sync KB", check_sync, interval=30, max_wait=1200)
    if status not in ("COMPLETE", "COMPLETE_WITH_FAILURES"):
        raise RuntimeError(f"Sync KB falló: {status}")
    ok(f"KB sincronizada ({status})")
    return kb_id, ds_id


# ─── 5. Lambda ────────────────────────────────────────────────────────────────
def setup_lambda(kb_id: str) -> str:
    step("5/7", "Lambda — Función API del chatbot")
    role_name = f"{PROJECT_SLUG}-lambda-role"

    if state.get("lambda_arn"):
        skip(f"Lambda {LAMBDA_NAME}")
        return state["lambda_arn"]

    # Rol Lambda
    trust = json.dumps({
        "Version": "2012-10-17",
        "Statement": [{
            "Effect": "Allow",
            "Principal": {"Service": "lambda.amazonaws.com"},
            "Action": "sts:AssumeRole"
        }]
    })
    try:
        r = iam.create_role(RoleName=role_name, AssumeRolePolicyDocument=trust)
        lm_role_arn = r["Role"]["Arn"]
    except ClientError as e:
        if e.response["Error"]["Code"] == "EntityAlreadyExists":
            lm_role_arn = iam.get_role(RoleName=role_name)["Role"]["Arn"]
        else:
            raise

    policy = {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Action": ["logs:CreateLogGroup", "logs:CreateLogStream",
                           "logs:PutLogEvents"],
                "Resource": "arn:aws:logs:*:*:*"
            },
            {
                "Effect": "Allow",
                "Action": [
                    "bedrock:Retrieve",
                    "bedrock:RetrieveAndGenerate",
                    "bedrock:InvokeModel",
                ],
                "Resource": "*"
            }
        ]
    }
    pol_name = f"{PROJECT_SLUG}-lambda-policy"
    try:
        pol = iam.create_policy(
            PolicyName=pol_name,
            PolicyDocument=json.dumps(policy)
        )
        pol_arn = pol["Policy"]["Arn"]
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
    time.sleep(10)

    # Empaquetar handler.py
    handler_path = LAMBDA_DIR / "handler.py"
    buf = io.BytesIO()
    with zipfile.ZipFile(buf, "w", zipfile.ZIP_DEFLATED) as zf:
        zf.write(str(handler_path), "handler.py")
    zip_bytes = buf.getvalue()

    env_vars = {
        "KNOWLEDGE_BASE_ID": kb_id,
        "MODEL_ARN":  f"arn:aws:bedrock:{REGION}::foundation-model/{RESPONSE_MODEL_ID}",
        "SYSTEM_PROMPT": SYSTEM_PROMPT,
        "BEDROCK_REGION": REGION,
    }

    try:
        resp = lmb.create_function(
            FunctionName=LAMBDA_NAME,
            Runtime="python3.12",
            Role=lm_role_arn,
            Handler="handler.handler",
            Code={"ZipFile": zip_bytes},
            Timeout=60,
            MemorySize=256,
            Environment={"Variables": env_vars},
        )
        lambda_arn = resp["FunctionArn"]
    except ClientError as e:
        if e.response["Error"]["Code"] == "ResourceConflictException":
            # Actualizar función existente
            lmb.update_function_code(
                FunctionName=LAMBDA_NAME, ZipFile=zip_bytes
            )
            lmb.update_function_configuration(
                FunctionName=LAMBDA_NAME,
                Environment={"Variables": env_vars},
                Timeout=60, MemorySize=256,
            )
            lambda_arn = lmb.get_function_configuration(
                FunctionName=LAMBDA_NAME
            )["FunctionArn"]
        else:
            raise

    # Esperar a que Lambda esté activa
    time.sleep(5)
    ok(f"Lambda {LAMBDA_NAME}")
    state["lambda_arn"] = lambda_arn
    save_state(state)
    return lambda_arn


# ─── 6. API Gateway HTTP ──────────────────────────────────────────────────────
def setup_api_gateway(lambda_arn: str) -> str:
    step("6/7", "API Gateway HTTP — Endpoint del chatbot")

    if state.get("api_endpoint"):
        skip(f"API {state['api_id']}")
        return state["api_endpoint"]

    api = apigw.create_api(
        Name=f"{PROJECT_SLUG}-api",
        ProtocolType="HTTP",
        CorsConfiguration={
            "AllowHeaders": ["Content-Type"],
            "AllowMethods": ["POST", "OPTIONS"],
            "AllowOrigins": ["*"],
        }
    )
    api_id = api["ApiId"]

    integration = apigw.create_integration(
        ApiId=api_id,
        IntegrationType="AWS_PROXY",
        IntegrationUri=lambda_arn,
        PayloadFormatVersion="2.0",
    )
    int_id = integration["IntegrationId"]

    apigw.create_route(
        ApiId=api_id,
        RouteKey="POST /chat",
        Target=f"integrations/{int_id}",
    )
    apigw.create_stage(
        ApiId=api_id,
        StageName="$default",
        AutoDeploy=True,
    )

    api_endpoint = f"https://{api_id}.execute-api.{REGION}.amazonaws.com/chat"

    # Permiso para que API Gateway invoque Lambda
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

    ok(f"API: {api_endpoint}")
    state["api_id"]       = api_id
    state["api_endpoint"] = api_endpoint
    save_state(state)
    return api_endpoint


# ─── 7. S3 Website + HTML ─────────────────────────────────────────────────────
def deploy_frontend(api_endpoint: str) -> str:
    step("7/7", "S3 Static Website — Frontend del chatbot")

    try:
        if REGION == "us-east-1":
            s3.create_bucket(Bucket=WEBSITE_BUCKET)
        else:
            s3.create_bucket(
                Bucket=WEBSITE_BUCKET,
                CreateBucketConfiguration={"LocationConstraint": REGION}
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
            "BlockPublicAcls":      False,
            "IgnorePublicAcls":     False,
            "BlockPublicPolicy":    False,
            "RestrictPublicBuckets": False,
        }
    )
    s3.put_bucket_website(
        Bucket=WEBSITE_BUCKET,
        WebsiteConfiguration={
            "IndexDocument": {"Suffix": "index.html"},
            "ErrorDocument": {"Key": "index.html"},
        }
    )
    s3.put_bucket_policy(
        Bucket=WEBSITE_BUCKET,
        Policy=json.dumps({
            "Version": "2012-10-17",
            "Statement": [{
                "Effect": "Allow",
                "Principal": "*",
                "Action": "s3:GetObject",
                "Resource": f"arn:aws:s3:::{WEBSITE_BUCKET}/*"
            }]
        })
    )

    # Leer HTML e inyectar el endpoint
    html_path = FRONTEND_DIR / "index.html"
    html = html_path.read_text(encoding="utf-8")
    html = html.replace("{{API_ENDPOINT}}", api_endpoint)

    s3.put_object(
        Bucket=WEBSITE_BUCKET,
        Key="index.html",
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
    save_state(state)
    return website_url


# ─── Orquestador ──────────────────────────────────────────────────────────────
def main():
    print("\n╔══════════════════════════════════════════════════════════════╗")
    print("║   GemCog Chatbot — Despliegue AWS Bedrock                   ║")
    print("╚══════════════════════════════════════════════════════════════╝\n")

    kb_role_arn                = create_kb_role()
    setup_docs_bucket()
    collection_id, _endpoint   = setup_aoss(kb_role_arn)
    kb_id, _ds_id              = setup_knowledge_base(kb_role_arn, collection_id)
    lambda_arn                 = setup_lambda(kb_id)
    api_endpoint               = setup_api_gateway(lambda_arn)
    website_url                = deploy_frontend(api_endpoint)

    print("\n╔══════════════════════════════════════════════════════════════╗")
    print("║   ✓  Despliegue completo                                    ║")
    print("╚══════════════════════════════════════════════════════════════╝")
    print(f"\n  🌐  Chatbot:  {website_url}")
    print(f"  🔌  API:      {api_endpoint}")
    print(f"  📚  KB ID:    {kb_id}")
    print(f"\n  Estado guardado en: {DEPLOY_STATE}\n")


if __name__ == "__main__":
    main()
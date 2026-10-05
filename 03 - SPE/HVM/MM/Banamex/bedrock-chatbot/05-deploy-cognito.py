"""
Paso 5 — Proteger el portal Digital Brain con Cognito + CloudFront.

Flujo:
  1. Cognito User Pool  (self-signup + email OTP)
  2. Lambda@Edge        (valida JWT en cada request)
  3. CloudFront         (OAC → S3 privado)
  4. S3                 (bucket vuelve privado; solo CloudFront puede leer)
  5. Subir páginas auth/ con los IDs de Cognito reales

Uso:
    python 05-deploy-cognito.py
    python 05-deploy-cognito.py --update   # re-sube auth/ y Lambda (sin recrear CF)

Prerequisitos:
    pip install boto3 cryptography requests
    AWS credentials con permisos: IAM, Cognito, Lambda, CloudFront, S3
"""

import base64
import json
import pathlib
import sys
import time
import zipfile
import io
import urllib.request

import boto3
from botocore.exceptions import ClientError

try:
    from cryptography.hazmat.primitives.asymmetric.rsa import RSAPublicNumbers
    from cryptography.hazmat.backends import default_backend
    from cryptography.hazmat.primitives import serialization
except ImportError:
    sys.exit("✗  Falta: pip install cryptography")

from config import AWS_REGION, AWS_PROFILE, DEPLOY_STATE

PORTAL_BUCKET = "gemcog-banamex-portal-ui"

# ─── Constantes ───────────────────────────────────────────────────────────────
AUTH_DIR       = pathlib.Path(__file__).parent / "auth"
USER_POOL_NAME = "gemcog-banamex-users"
APP_CLIENT_NAME= "gemcog-banamex-portal"
LAMBDA_NAME_EDGE = "gemcog-banamex-edge-auth"

# Lambda@Edge debe estar en us-east-1
session_us = boto3.Session(profile_name=AWS_PROFILE, region_name="us-east-1")
cognito  = session_us.client("cognito-idp")
lmb      = session_us.client("lambda")
iam      = session_us.client("iam")
cf       = session_us.client("cloudfront")
s3       = session_us.client("s3")
sts      = session_us.client("sts")

state = json.loads(DEPLOY_STATE.read_text()) if DEPLOY_STATE.exists() else {}

def ok(m):   print(f"  ✓  {m}")
def info(m): print(f"  ·  {m}")
def step(n, t): print(f"\n[{n}] {t}")
def save():
    DEPLOY_STATE.write_text(json.dumps(state, indent=2, ensure_ascii=False))


# ─── 1. Cognito User Pool ─────────────────────────────────────────────────────
def create_user_pool() -> tuple[str, str]:
    step("1/5", "Cognito — User Pool")

    if state.get("user_pool_id"):
        info(f"User Pool existente: {state['user_pool_id']}")
        return state["user_pool_id"], state["client_id"]

    resp = cognito.create_user_pool(
        PoolName=USER_POOL_NAME,
        AutoVerifiedAttributes=["email"],
        UsernameAttributes=["email"],
        Policies={
            "PasswordPolicy": {
                "MinimumLength": 8,
                "RequireUppercase": True,
                "RequireLowercase": True,
                "RequireNumbers": True,
                "RequireSymbols": True,
            }
        },
        EmailConfiguration={"EmailSendingAccount": "COGNITO_DEFAULT"},
        VerificationMessageTemplate={
            "DefaultEmailOption": "CONFIRM_WITH_CODE",
            "EmailSubject": "Digital Brain Banamex — Código de verificación",
            "EmailMessage": (
                "Tu código de verificación para el portal Digital Brain es: {####}\n\n"
                "Este código expira en 24 horas.\n\n"
                "Accenture · Banamex Modernización de Mainframe"
            ),
        },
        AdminCreateUserConfig={"AllowAdminCreateUserOnly": False},
    )
    pool_id = resp["UserPool"]["Id"]
    ok(f"User Pool creado: {pool_id}")

    # App Client
    cl = cognito.create_user_pool_client(
        UserPoolId=pool_id,
        ClientName=APP_CLIENT_NAME,
        GenerateSecret=False,
        ExplicitAuthFlows=[
            "ALLOW_USER_PASSWORD_AUTH",
            "ALLOW_USER_SRP_AUTH",
            "ALLOW_REFRESH_TOKEN_AUTH",
        ],
        PreventUserExistenceErrors="ENABLED",
    )
    client_id = cl["UserPoolClient"]["ClientId"]
    ok(f"App Client creado: {client_id}")

    state["user_pool_id"] = pool_id
    state["client_id"]    = client_id
    save()
    return pool_id, client_id


# ─── 2. JWKS → PEM (para Lambda@Edge sin npm) ────────────────────────────────
def fetch_pems(pool_id: str) -> dict:
    """Descarga JWKS de Cognito y convierte a PEM."""
    url = f"https://cognito-idp.us-east-1.amazonaws.com/{pool_id}/.well-known/jwks.json"
    for attempt in range(6):
        try:
            with urllib.request.urlopen(url, timeout=10) as r:
                jwks = json.loads(r.read())
            break
        except Exception:
            if attempt == 5:
                raise
            time.sleep(3)

    def b64url_to_int(s):
        s += "=" * (4 - len(s) % 4)
        return int.from_bytes(base64.urlsafe_b64decode(s), "big")

    pems = {}
    for key in jwks["keys"]:
        if key.get("use") != "sig":
            continue
        pub = RSAPublicNumbers(
            e=b64url_to_int(key["e"]),
            n=b64url_to_int(key["n"])
        ).public_key(default_backend())
        pem = pub.public_bytes(
            serialization.Encoding.PEM,
            serialization.PublicFormat.SubjectPublicKeyInfo
        ).decode("utf-8")
        pems[key["kid"]] = pem

    ok(f"JWKS descargado — {len(pems)} claves convertidas a PEM")
    return pems


# ─── 3. Lambda@Edge ───────────────────────────────────────────────────────────
EDGE_HANDLER_TEMPLATE = """\
'use strict';
const crypto = require('crypto');
const PEMS      = {PEMS_JSON};
const POOL_ID   = '{POOL_ID}';
const CLIENT_ID = '{CLIENT_ID}';
const ISSUER    = 'https://cognito-idp.us-east-1.amazonaws.com/' + POOL_ID;
const PUBLIC    = ['/auth/', '/favicon'];

function parseCookies(hdrs) {
  const c = {};
  ((hdrs && hdrs.cookie) || []).forEach(h =>
    h.value.split(';').forEach(p => {
      const [k, ...v] = p.trim().split('=');
      c[k.trim()] = v.join('=');
    })
  );
  return c;
}

function b64url(s) {
  s = s.replace(/-/g, '+').replace(/_/g, '/');
  while (s.length % 4) s += '=';
  return Buffer.from(s, 'base64').toString('utf8');
}

function verify(token) {
  try {
    const parts = token.split('.');
    if (parts.length !== 3) return null;
    const hdr = JSON.parse(b64url(parts[0]));
    const pay = JSON.parse(b64url(parts[1]));
    const pem = PEMS[hdr.kid];
    if (!pem) return null;
    const ver = crypto.createVerify('RSA-SHA256');
    ver.update(parts[0] + '.' + parts[1]);
    const sig = Buffer.from(parts[2].replace(/-/g,'+').replace(/_/g,'/'), 'base64');
    if (!ver.verify(pem, sig)) return null;
    const now = Math.floor(Date.now() / 1000);
    if (pay.exp < now) return null;
    if (pay.iss !== ISSUER) return null;
    if (pay.aud !== CLIENT_ID && pay.client_id !== CLIENT_ID) return null;
    if (pay.token_use !== 'id') return null;
    return pay;
  } catch(e) { return null; }
}

exports.handler = async (event) => {
  const req = event.Records[0].cf.request;
  const uri = req.uri;

  // Paths públicos: páginas de auth pasan siempre sin validación
  if (PUBLIC.some(p => uri.startsWith(p))) {
    return req;
  }

  // Todo lo demás requiere token JWT válido en cookie
  const cookies = parseCookies(req.headers);
  const token   = cookies['id_token'];
  if (token && verify(token)) return req;

  return {
    status: '302', statusDescription: 'Found',
    headers: {
      location:       [{ key: 'Location',      value: '/auth/login.html' }],
      'cache-control':[{ key: 'Cache-Control', value: 'no-cache' }]
    }
  };
};
"""

def deploy_lambda_edge(pool_id: str, client_id: str, pems: dict) -> str:
    step("2/5", "Lambda@Edge — validador JWT")

    account_id = sts.get_caller_identity()["Account"]

    # ── Rol IAM ──
    role_name = "gemcog-banamex-edge-role"
    try:
        role_arn = iam.get_role(RoleName=role_name)["Role"]["Arn"]
        info(f"Rol existente: {role_arn}")
    except ClientError:
        trust = {
            "Version": "2012-10-17",
            "Statement": [{
                "Effect": "Allow",
                "Principal": {"Service": ["lambda.amazonaws.com",
                                          "edgelambda.amazonaws.com"]},
                "Action": "sts:AssumeRole"
            }]
        }
        role_arn = iam.create_role(
            RoleName=role_name,
            AssumeRolePolicyDocument=json.dumps(trust)
        )["Role"]["Arn"]
        iam.attach_role_policy(
            RoleName=role_name,
            PolicyArn="arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
        )
        time.sleep(12)
        ok(f"Rol IAM creado: {role_arn}")

    # ── Código del handler ──
    code = (EDGE_HANDLER_TEMPLATE
            .replace("{PEMS_JSON}", json.dumps(pems))
            .replace("{POOL_ID}",   pool_id)
            .replace("{CLIENT_ID}", client_id))

    buf = io.BytesIO()
    with zipfile.ZipFile(buf, "w", zipfile.ZIP_DEFLATED) as zf:
        zf.writestr("index.js", code)
    zip_bytes = buf.getvalue()

    # ── Crear o actualizar Lambda ──
    try:
        lmb.get_function(FunctionName=LAMBDA_NAME_EDGE)
        lmb.update_function_code(
            FunctionName=LAMBDA_NAME_EDGE, ZipFile=zip_bytes
        )
        time.sleep(6)
        ok("Lambda@Edge código actualizado")
    except ClientError:
        lmb.create_function(
            FunctionName=LAMBDA_NAME_EDGE,
            Runtime="nodejs18.x",
            Role=role_arn,
            Handler="index.handler",
            Code={"ZipFile": zip_bytes},
            Timeout=5, MemorySize=128,
            Description="Validador JWT Cognito para portal Digital Brain Banamex",
        )
        time.sleep(8)
        ok("Lambda@Edge creada")

    # ── Publicar versión (Lambda@Edge requiere versión específica) ──
    ver = lmb.publish_version(FunctionName=LAMBDA_NAME_EDGE)
    ver_arn = ver["FunctionArn"]
    ok(f"Versión publicada: {ver_arn}")

    state["edge_lambda_arn"] = ver_arn
    save()
    return ver_arn


# ─── 4. CloudFront con OAC ────────────────────────────────────────────────────
def create_cloudfront(edge_arn: str) -> str:
    step("3/5", "CloudFront — distribución + OAC")

    if state.get("cf_domain"):
        info(f"CloudFront existente: {state['cf_domain']}")
        return state["cf_domain"]

    # Origin Access Control (reusar si ya existe)
    OAC_NAME = "gemcog-banamex-oac"
    try:
        oac = cf.create_origin_access_control(
            OriginAccessControlConfig={
                "Name": OAC_NAME,
                "Description": "OAC para portal Digital Brain Banamex",
                "SigningProtocol": "sigv4",
                "SigningBehavior": "always",
                "OriginAccessControlOriginType": "s3",
            }
        )
        oac_id = oac["OriginAccessControl"]["Id"]
        ok(f"OAC creado: {oac_id}")
    except ClientError as e:
        if "AlreadyExists" not in str(e):
            raise
        # Buscar el existente por nombre
        paginator = cf.get_paginator("list_origin_access_controls")
        oac_id = None
        for page in paginator.paginate():
            for item in page["OriginAccessControlList"].get("Items", []):
                if item["Name"] == OAC_NAME:
                    oac_id = item["Id"]
                    break
        if not oac_id:
            raise RuntimeError("OAC existente no encontrado en el listado")
        info(f"OAC existente reutilizado: {oac_id}")

    origin_domain = f"{PORTAL_BUCKET}.s3.us-east-1.amazonaws.com"

    dist = cf.create_distribution(
        DistributionConfig={
            "CallerReference": f"gemcog-banamex-{int(time.time())}",
            "Comment": "Portal Digital Brain Banamex — protegido con Cognito",
            "DefaultRootObject": "index.html",
            "Enabled": True,
            "HttpVersion": "http2",
            "Origins": {
                "Quantity": 1,
                "Items": [{
                    "Id": "s3-origin",
                    "DomainName": origin_domain,
                    "S3OriginConfig": {"OriginAccessIdentity": ""},
                    "OriginAccessControlId": oac_id,
                }]
            },
            "DefaultCacheBehavior": {
                "TargetOriginId": "s3-origin",
                "ViewerProtocolPolicy": "redirect-to-https",
                "AllowedMethods": {"Quantity": 2, "Items": ["GET", "HEAD"]},
                "ForwardedValues": {
                    "QueryString": False,
                    "Cookies": {"Forward": "none"},
                    "Headers": {"Quantity": 0},
                },
                "LambdaFunctionAssociations": {
                    "Quantity": 1,
                    "Items": [{
                        "LambdaFunctionARN": edge_arn,
                        "EventType": "viewer-request",
                        "IncludeBody": False,
                    }]
                },
                "MinTTL": 0,
                "DefaultTTL": 86400,
                "MaxTTL": 31536000,
                "Compress": True,
                "TrustedSigners": {"Enabled": False, "Quantity": 0},
            },
            "CustomErrorResponses": {
                "Quantity": 1,
                "Items": [{
                    "ErrorCode": 403,
                    "ResponsePagePath": "/auth/login.html",
                    "ResponseCode": "200",
                    "ErrorCachingMinTTL": 0,
                }]
            },
        }
    )
    domain = dist["Distribution"]["DomainName"]
    dist_id = dist["Distribution"]["Id"]
    ok(f"CloudFront creado: {domain}  (ID: {dist_id})")
    info("⏳  La distribución tarda ~15 min en desplegarse globalmente.")

    state["cf_domain"] = domain
    state["cf_dist_id"] = dist_id
    state["oac_id"] = oac_id
    save()
    return domain


# ─── 5. S3: volver privado + OAC policy ─────────────────────────────────────
def make_s3_private():
    step("4/5", "S3 — hacer bucket privado (solo CloudFront)")

    account_id = sts.get_caller_identity()["Account"]

    if "cf_dist_id" not in state:
        print("  ✗  No hay distribución CloudFront en el estado.")
        return

    # Restaurar Block Public Access
    s3.put_public_access_block(
        Bucket=PORTAL_BUCKET,
        PublicAccessBlockConfiguration={
            "BlockPublicAcls": True,
            "IgnorePublicAcls": True,
            "BlockPublicPolicy": True,
            "RestrictPublicBuckets": True,
        }
    )

    # Política OAC: solo CloudFront puede leer
    policy = {
        "Version": "2012-10-17",
        "Statement": [{
            "Sid": "AllowCloudFrontServicePrincipal",
            "Effect": "Allow",
            "Principal": {"Service": "cloudfront.amazonaws.com"},
            "Action": "s3:GetObject",
            "Resource": f"arn:aws:s3:::{PORTAL_BUCKET}/*",
            "Condition": {
                "StringEquals": {
                    "AWS:SourceArn": f"arn:aws:cloudfront::{account_id}:distribution/{state['cf_dist_id']}"
                }
            }
        }]
    }
    s3.put_bucket_policy(Bucket=PORTAL_BUCKET, Policy=json.dumps(policy))
    ok("Bucket privado — solo CloudFront puede leer")


# ─── 6. Subir auth pages ─────────────────────────────────────────────────────
def upload_auth_pages(pool_id: str, client_id: str):
    step("5/5", "S3 — subir páginas de autenticación")

    if not AUTH_DIR.exists():
        print(f"  ✗  Carpeta auth/ no encontrada: {AUTH_DIR}")
        return

    # cognito-config.js con valores reales
    config_js = (
        "window.COGNITO_CONFIG = {\n"
        f'  region:     "us-east-1",\n'
        f'  userPoolId: "{pool_id}",\n'
        f'  clientId:   "{client_id}"\n'
        "};\n"
    )
    s3.put_object(
        Bucket=PORTAL_BUCKET,
        Key="auth/cognito-config.js",
        Body=config_js.encode("utf-8"),
        ContentType="application/javascript",
    )
    ok("auth/cognito-config.js subido")

    # Subir HTML de auth
    for f in AUTH_DIR.glob("*.html"):
        s3.upload_file(
            str(f), PORTAL_BUCKET, f"auth/{f.name}",
            ExtraArgs={"ContentType": "text/html; charset=utf-8"}
        )
        ok(f"auth/{f.name}")

    # URL pública
    cf_url = f"https://{state.get('cf_domain', PORTAL_BUCKET + '.cloudfront.net')}"
    print(f"\n  🌐  Login page: {cf_url}/auth/login.html")


# ─── Main ─────────────────────────────────────────────────────────────────────
def main():
    update_only = "--update" in sys.argv
    print("── Deploy Cognito + CloudFront + Lambda@Edge ───────────────────────")
    print(f"  Bucket  : {PORTAL_BUCKET}")
    print(f"  Región  : us-east-1\n")

    pool_id, client_id = create_user_pool()

    pems     = fetch_pems(pool_id)
    edge_arn = deploy_lambda_edge(pool_id, client_id, pems)

    if not update_only:
        cf_domain = create_cloudfront(edge_arn)
        make_s3_private()

    upload_auth_pages(pool_id, client_id)

    print("\n── Resultado ────────────────────────────────────────────────────────")
    cf_url = f"https://{state.get('cf_domain', '(pendiente)')}"
    ok(f"Portal (CloudFront):  {cf_url}")
    ok(f"Login:                {cf_url}/auth/login.html")
    ok(f"Estado guardado en:   {DEPLOY_STATE}")
    print("\n  ⏳  CloudFront tarda ~15 min en desplegarse por primera vez.")
    print("  → Para actualizar auth pages sin recrear CF: python 05-deploy-cognito.py --update\n")


if __name__ == "__main__":
    main()

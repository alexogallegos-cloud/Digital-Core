"""
Paso 4 — Deploy del portal Digital Brain como S3 static website.

Sube todos los archivos de gemcog-portal-2026-08-26-cliente-entregable/
a un bucket S3 con website hosting habilitado.

Uso:
    python 04-deploy-portal.py           # crea bucket y sube
    python 04-deploy-portal.py --sync    # solo sincroniza (bucket ya existe)
"""

import boto3
import json
import mimetypes
import pathlib
import sys

from botocore.exceptions import ClientError
from config import AWS_REGION, AWS_PROFILE, BANAMEX_DIR, DEPLOY_STATE

# ─── Configuración ────────────────────────────────────────────────────────────
PORTAL_BUCKET = "gemcog-banamex-portal-ui"
PORTAL_DIR    = (
    BANAMEX_DIR
    / "systems" / "core" / "unisys" / "source"
    / "GemCogAlt" / "gemcog-portal-2026-08-26-cliente-entregable"
)

# Extensiones a subir (excluir .gitkeep, .docx, .md que son internos)
INCLUDE_EXTENSIONS = {".html", ".js", ".css", ".json", ".svg", ".png",
                      ".jpg", ".jpeg", ".gif", ".ico", ".woff", ".woff2",
                      ".ttf", ".eot", ".map", ".txt"}

# ─── Helpers ──────────────────────────────────────────────────────────────────
session = boto3.Session(profile_name=AWS_PROFILE, region_name=AWS_REGION)
s3      = session.client("s3", region_name=AWS_REGION)

def ok(m):   print(f"  ✓  {m}")
def info(m): print(f"  ·  {m}")
def step(n, t): print(f"\n[{n}] {t}")


def create_bucket():
    step("1/3", f"S3 — Crear bucket: {PORTAL_BUCKET}")
    try:
        if AWS_REGION == "us-east-1":
            s3.create_bucket(Bucket=PORTAL_BUCKET)
        else:
            s3.create_bucket(
                Bucket=PORTAL_BUCKET,
                CreateBucketConfiguration={"LocationConstraint": AWS_REGION},
            )
        ok(f"Bucket creado: {PORTAL_BUCKET}")
    except ClientError as e:
        code = e.response["Error"]["Code"]
        if code in ("BucketAlreadyOwnedByYou", "BucketAlreadyExists"):
            info("Bucket ya existe — continuando")
        else:
            raise

    # Deshabilitar Block Public Access
    s3.delete_public_access_block(Bucket=PORTAL_BUCKET)

    # Bucket policy: acceso público de lectura
    policy = {
        "Version": "2012-10-17",
        "Statement": [{
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": f"arn:aws:s3:::{PORTAL_BUCKET}/*",
        }],
    }
    s3.put_bucket_policy(Bucket=PORTAL_BUCKET, Policy=json.dumps(policy))

    # Habilitar static website hosting
    s3.put_bucket_website(
        Bucket=PORTAL_BUCKET,
        WebsiteConfiguration={
            "IndexDocument": {"Suffix": "index.html"},
            "ErrorDocument": {"Key": "index.html"},
        },
    )
    ok("Static website hosting habilitado")


def upload_files() -> tuple[int, int]:
    step("2/3", f"Upload — {PORTAL_DIR.name}")
    if not PORTAL_DIR.exists():
        print(f"  ✗  Portal no encontrado: {PORTAL_DIR}")
        sys.exit(1)

    uploaded = 0
    skipped  = 0

    all_files = [f for f in PORTAL_DIR.rglob("*") if f.is_file()]
    total     = len(all_files)

    for src in sorted(all_files):
        suffix = src.suffix.lower()
        if suffix not in INCLUDE_EXTENSIONS:
            skipped += 1
            continue

        # Clave S3: path relativo al directorio portal, con forward slashes
        key = src.relative_to(PORTAL_DIR).as_posix()

        # MIME type
        mime, _ = mimetypes.guess_type(src.name)
        mime = mime or "application/octet-stream"
        if suffix == ".html":
            mime = "text/html; charset=utf-8"
        elif suffix == ".js":
            mime = "application/javascript"
        elif suffix == ".css":
            mime = "text/css"

        try:
            s3.upload_file(
                str(src),
                PORTAL_BUCKET,
                key,
                ExtraArgs={"ContentType": mime},
            )
            uploaded += 1
            if uploaded % 25 == 0:
                print(f"  ·  {uploaded}/{total} archivos subidos...")
        except Exception as e:
            print(f"  ⚠  Error subiendo {key}: {e}")

    ok(f"{uploaded} archivos subidos ({skipped} omitidos por extensión)")
    return uploaded, skipped


def print_result():
    step("3/3", "Resultado")
    website_url = (
        f"http://{PORTAL_BUCKET}.s3-website-{AWS_REGION}.amazonaws.com"
    )
    ok(f"Portal disponible en:\n\n  {website_url}\n")

    # Guardar URL en .deploy-state.json
    state = json.loads(DEPLOY_STATE.read_text()) if DEPLOY_STATE.exists() else {}
    state["portal_url"] = website_url
    DEPLOY_STATE.write_text(json.dumps(state, indent=2))
    ok("URL guardada en .deploy-state.json")


def main():
    sync_only = "--sync" in sys.argv
    print("── Deploy Portal Digital Brain → S3 ───────────────────────────────")
    print(f"  Fuente : {PORTAL_DIR}")
    print(f"  Bucket : {PORTAL_BUCKET}")
    print(f"  Región : {AWS_REGION}\n")

    if not sync_only:
        create_bucket()

    upload_files()
    print_result()


if __name__ == "__main__":
    main()

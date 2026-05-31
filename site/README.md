# Digital Core — static site

Sitio estático que publica las metodologías y entregables de Digital Core, offering por offering.
Primer contenido: **03 Software & Platform Engineering → HVM → Mainframe Modernization → Reverse Engineering**.

## Estructura

```
site/
├── index.html                          ← landing Digital Core (7 offerings)
├── 03-software-platform-engineering/
│   └── high-velocity-modernization/
│       └── mainframe-modernization/
│           ├── index.html              ← hub MM (8 fases)
│           └── reverse-engineering/
│               ├── index.html          ← portada RE
│               ├── methodology.html
│               ├── discovery-assessment.html
│               ├── benchmark.html
│               ├── handoff-discover-to-regulatory.html
│               ├── hitl-adjudication.csv
│               └── graphs/{truth,blind,augmented}.html
├── 01-… 02-… 04-… 05-… 06-… 07-…       ← vacías, listas para crecer
├── _build.py                           ← regenera el contenido del RE desde el árbol de agentes
└── infra/                              ← Terraform: S3 privado + CloudFront (OAC), público
```

## Rebuild del contenido (cuando cambian los entregables del RE)

```
python site/_build.py
```
Copia los grafos, reescribe los enlaces relativos a rutas web, y convierte benchmark/handoff (MD) a HTML.
Las landing pages (`index.html` raíz y de MM) son estáticas autoradas — no las regenera.

## Infraestructura (una vez)

```
cd site/infra
terraform init
terraform apply -var="suffix=ago-2026"        # sufijo único para el bucket S3
```
Outputs: `bucket_name`, `site_url`, `cloudfront_domain`, `cloudfront_distribution_id`.

### Dominio propio (opcional)

**Caso A — DNS en Route 53 (automático):** valida el cert y crea el alias solo.
```
terraform apply -var="suffix=ago-2026" \
  -var="domain_name=digitalcore.midominio.com" \
  -var="route53_zone_id=Z0123456789ABC"
```

**Caso B — DNS externo (GoDaddy, etc.):** crea el cert; tú creas los registros DNS a mano.
```
terraform apply -var="suffix=ago-2026" -var="domain_name=digitalcore.midominio.com"
# 1) output acm_validation_records -> crea esos CNAME en tu DNS (valida el cert ACM)
# 2) output cloudfront_target      -> apunta tu dominio (CNAME) a ese host
# 3) re-apply cuando el cert esté ISSUED
```
Sin `domain_name`, el sitio queda en la URL de CloudFront (cert default, HTTPS). El cert ACM va siempre en `us-east-1` (lo maneja el provider `aws.use1`).

## Despliegue del contenido

```
cd site
aws s3 sync . s3://<bucket_name> --delete --exclude "infra/*" --exclude "_build.py" --exclude "README.md"
aws cloudfront create-invalidation --distribution-id <dist_id> --paths "/*"
```
`aws s3 sync` asigna content-type por extensión (html→text/html, csv→text/csv).

## Notas

- **Acceso público** por CloudFront; el bucket S3 es privado (solo CloudFront vía OAC lee).
- **Solo contenido sin IP de cliente.** El corebank es sintético. Al crecer a otros offerings con material de cliente, reconsiderar acceso (WAF/Cognito) antes de subir.
- HTML **self-contained offline** (logo base64, D3 inline) — no hay assets compartidos que romper.
- Enlaces **explícitos .html** (no requieren rewrite de directorios en CloudFront).

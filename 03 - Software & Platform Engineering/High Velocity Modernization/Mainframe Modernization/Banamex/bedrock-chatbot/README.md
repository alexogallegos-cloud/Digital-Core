# GemCog Chatbot — Banamex S500 + S151
> Indexado: ✅ 2026-07-17 — README del proyecto/componente (contexto de conocimiento)

Chatbot HTML hosteado en AWS S3. Backend: Lambda + API Gateway.
RAG personalizado con **Pinecone Free Tier** (vector store gratuito)
+ **Amazon Bedrock** (embeddings + generación con Claude).

---

## Arquitectura

```
Browser (S3 Static Site)
  └─→ API Gateway (HTTP, CORS)
        └─→ Lambda Python 3.12
              ├─→ Bedrock Titan Embed v2  ← embebe la pregunta
              ├─→ Pinecone Free           ← busca los 15 chunks más relevantes
              └─→ Bedrock Claude          ← genera la respuesta con contexto
```

---

## Costo estimado

| Recurso | Costo |
|---------|-------|
| **Pinecone Starter** | **GRATIS** (100K vectores) |
| Lambda + API Gateway + S3 | **GRATIS** (free tier AWS) |
| Bedrock Titan Embed (indexar, una vez) | < $0.01 USD (~$0.17 MXN) |
| Bedrock Claude 3.5 Sonnet (por uso) | ~$3/1M tokens input · ~$15/1M output |
| Uso moderado (100 queries/mes, ~5K tokens c/u) | ~$1.50 USD (~$26 MXN/mes) |

> **Comparado con OpenSearch Serverless: ahorro de ~$175 USD/mes (~$3,060 MXN/mes)**

---

## Prerequisitos

### 1. Pinecone Free (5 minutos)
1. Crear cuenta gratis en **pinecone.io**
2. New Index → Name: `gemcog-banamex`, Dimensions: `1024`, Metric: `cosine`
3. Copiar el **API Key** y el **Host** del índice
4. Pegar en `config.py`:
   ```python
   PINECONE_API_KEY    = "tu-api-key-aqui"
   PINECONE_INDEX_HOST = "https://gemcog-banamex-xxx.pinecone.io"
   ```

### 2. Python 3.10+
```bash
pip install -r requirements.txt
```

### 3. Credenciales AWS
```bash
aws configure
```
Permisos mínimos: IAM, Lambda, API Gateway, S3, Bedrock.

### 4. Habilitar modelos en Bedrock (solo la primera vez)
**AWS Console → Bedrock → Model access** → habilitar:
- `Amazon Titan Embed Text V2`
- `Anthropic Claude 3.5 Sonnet v2` (o Haiku para menor costo)

---

## Despliegue — 3 pasos

### Paso 1 — Preparar documentos
```bash
python 01-prepare-docs.py
```
Convierte JSONs a Markdown, copia ~220 archivos a `documents/`.

### Paso 2 — Indexar en Pinecone (una sola vez)
```bash
python 02-index-pinecone.py
```
Embebe cada chunk con Bedrock Titan y lo sube a Pinecone.
Tarda ~10-20 min. Costo: < $0.01 USD.

### Paso 3 — Desplegar en AWS
```bash
python 03-deploy-aws.py
```
Crea Lambda + API Gateway + S3 website. Tarda ~2 min.

**Output:**
```
  🌐  Chatbot : http://gemcog-banamex-chatbot-ui.s3-website-us-east-1.amazonaws.com
  🔌  API     : https://xxxx.execute-api.us-east-1.amazonaws.com/chat
```

---

## Configuración clave en `config.py`

| Variable | Descripción |
|----------|-------------|
| `PINECONE_API_KEY` | API Key de tu cuenta Pinecone |
| `PINECONE_INDEX_HOST` | URL del índice (ej: `https://gemcog-xxx.pinecone.io`) |
| `AWS_REGION` | Región AWS (default: us-east-1) |
| `RESPONSE_MODEL_ID` | Modelo de respuesta (Sonnet v2 = mejor · Haiku = más barato) |
| `SYSTEM_PROMPT` | Instrucciones del asistente |

---

## Estructura de archivos

```
bedrock-chatbot/
├── README.md
├── config.py              ← configuración central (editar antes de usar)
├── requirements.txt
├── 01-prepare-docs.py     ← convierte y copia docs a documents/
├── 02-index-pinecone.py   ← indexa docs en Pinecone (ejecutar una vez)
├── 03-deploy-aws.py       ← crea Lambda + API GW + S3 website
├── 02-deploy.py           ← alternativa con Bedrock KB + OpenSearch (~$175/mes)
├── .deploy-state.json     ← (generado) IDs de recursos AWS
├── documents/             ← (generado) docs preparados
├── lambda/
│   └── handler.py         ← RAG: embed → Pinecone → Claude
└── frontend/
    └── index.html         ← chatbot HTML con tema GemCog
```

---

## Eliminar recursos AWS

```bash
# Desde AWS Console:
# 1. Lambda → Funciones → gemcog-banamex-api → Eliminar
# 2. API Gateway → APIs → gemcog-banamex-api → Eliminar
# 3. S3 → gemcog-banamex-chatbot-ui → Vaciar → Eliminar
# 4. IAM → Roles → gemcog-banamex-lambda-role → Eliminar
#
# Pinecone: desde pinecone.io → Indexes → Delete
```
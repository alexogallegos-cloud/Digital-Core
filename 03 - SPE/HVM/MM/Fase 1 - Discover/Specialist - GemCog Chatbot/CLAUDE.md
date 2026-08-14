# Specialist — GemCog Chatbot
> Alojado en: ★ Digital Core · MM L4 · Fase 1 - Discover (output interactivo de la KB)
> Modelo: DC = ejecución completa · sin handoff a SME externo

```
┌─[★ Digital Core · MM L4]────────────────────────────────────────────┐
│ Specialist — GemCog Chatbot                                          │
│ Convierte la KB del Gemelo Cognitivo en un asistente consultable     │
│ RAG · Pinecone · AWS Bedrock · Lambda · S3 · client branding         │
└──────────────────────────────────────────────────────────────────────┘
```

---

## Identidad y Perfil

Soy el specialist que convierte los **outputs de la Fase 1 - Discover** — vocabulario, grafo de dependencias, biografías de programas, reglas de negocio, código fuente anotado — en un **chatbot RAG desplegado y consultable** con branding del cliente.

Mi input es la Knowledge Base (KB) generada por `Specialist - Reverse Engineering` (Etapas 0–3). Mi output es una URL activa donde arquitectos, developers, PMs y reguladores pueden hacer preguntas en lenguaje natural sobre el sistema legacy.

No analizo código mainframe ni genero artefactos de modernización — eso lo hacen RE + 7R Assessment. Yo **empaqueto el conocimiento ya generado** en una interfaz conversacional accesible.

---

## Principio Rector

> **El Gemelo Cognitivo vale lo que puede responder a las 11pm antes de un comité de reguladores. El chatbot es la interfaz de consulta del gemelo — sin él, el conocimiento existe solo para quien sabe leer JSON. Con él, cualquier stakeholder puede interrogar 700K LOC de COBOL en segundos.**

---

## Cuándo se Invoca

| Trigger | Prerequisito |
|---------|-------------|
| Etapa 3 (Business Logic Extraction) completada | KB del proyecto en `{cliente}/` con vocab, souls, gemelo, rules, source |
| Cliente solicita interfaz de consulta del gemelo | Mínimo: Etapa 0 + Etapa 1 completadas (inventario + vocab) |
| Kick-off de Fase 4/5 — el equipo target necesita consultar el AS-IS | KB completa recomendable |
| Demo a stakeholders / comité directivo | Cualquier estado de la KB — el chatbot responde con lo que hay |

---

## Componente que Entrega

| Artefacto | Descripción |
|-----------|-------------|
| **Chatbot RAG** | Interfaz web de pregunta-respuesta sobre la KB del gemelo |
| **URL pública** | S3 static website — accesible sin VPN, sin instalación |
| **Vector index** | Pinecone index con todos los documentos de la KB embebidos |
| **API Lambda** | Endpoint serverless RAG (embed → search → generate) |
| `config.py` | Configuración central del proyecto (excluida de git) |
| `documents/` | Staging folder con todos los documentos preparados (excluida de git) |

---

## Stack Técnico Canónico

| Capa | Servicio | Detalle |
|------|----------|---------|
| **Vector store** | Pinecone Free Tier | Serverless · Dense · AWS us-east-1 · hasta 100K vectores · $0/mes |
| **Embedding** | Amazon Bedrock — Titan Embed Text v2 | `amazon.titan-embed-text-v2:0` · 1024 dims · $0.02/1M tokens |
| **Generación** | Amazon Bedrock — Converse API | `amazon.nova-pro-v1:0` (sin use-case form, acceso inmediato) |
| **Backend** | AWS Lambda (Python 3.12) | `urllib.request` para Pinecone REST — sin capas adicionales |
| **API** | AWS API Gateway HTTP API | CORS habilitado · POST /chat |
| **Frontend** | S3 Static Website | Single HTML · sin framework · branding del cliente |
| **IAM** | Rol Lambda con `bedrock:InvokeModel` en `*` | Cubre modelos + inference profiles |

### Modelos Bedrock — Estado julio 2026

> **IMPORTANTE**: los modelos Claude 3.5 (2024) llegaron a EOL en 2026. Usar siempre modelos ACTIVE de la lista siguiente.

```python
# Verificar modelos activos en la cuenta:
aws bedrock list-foundation-models --region us-east-1 --by-provider anthropic \
  --query 'modelSummaries[?modelLifecycle.status==`ACTIVE`].[modelId,modelName]' --output table

# Modelos Amazon Nova (sin use-case form — acceso inmediato):
aws bedrock list-foundation-models --region us-east-1 --by-provider amazon \
  --query 'modelSummaries[?modelLifecycle.status==`ACTIVE`].[modelId,modelName]' --output table
```

| Modelo | Model ID Bedrock | Requiere form | Recomendado |
|--------|-----------------|---------------|-------------|
| Amazon Nova Pro | `amazon.nova-pro-v1:0` | No | **Sí — default** |
| Amazon Nova Lite | `amazon.nova-lite-v1:0` | No | Demo/costo bajo |
| Claude Haiku 4.5 | `us.anthropic.claude-haiku-4-5-20251001-v1:0` | Sí | Solo si form aprobado |
| Claude Sonnet 4.6 | `us.anthropic.claude-sonnet-4-6` | Sí | Solo si form aprobado |

**Regla de API**: los modelos Claude nuevos (4.x, 5.x) requieren `bedrock.converse()` con inference profile (`us.` prefix). Los modelos Amazon Nova también usan `bedrock.converse()`. **No usar `invoke_model` con modelos nuevos.**

---

## Workflow End-to-End

### Paso 0 — Setup del entorno

```bash
# Crear carpeta en el proyecto del cliente
mkdir {cliente}/bedrock-chatbot
cd {cliente}/bedrock-chatbot

# Instalar dependencias
pip install boto3>=1.34.0 requests>=2.31.0 pinecone>=3.0.0

# Crear índice en Pinecone Free Tier:
# → https://app.pinecone.io → Create Index
# → Name: gemcog-{cliente}
# → Dimensions: 1024 · Metric: cosine
# → Type: Dense · Cloud: AWS us-east-1 · Mode: Serverless / On-demand
# → Copiar API Key y Host URL
```

### Paso 1 — Preparar documentos (`01-prepare-docs.py`)

Lee todos los artefactos de la KB del cliente y los copia a `documents/` como texto plano normalizado. Convierte JSON → Markdown. Filtra binarios/EBCDIC. **Resultado típico: 200-300 archivos, 70-100 MB.**

```python
# Configurar en config.py:
BANAMEX_DIR = THIS_DIR.parent  # raíz del proyecto cliente
CORE_DOCS   = [...]            # lista de artefactos GemCog canónicos
SOURCE_GLOBS = [...]           # patrones glob del código fuente
```

### Paso 2 — Indexar en Pinecone (`02-index-pinecone.py`)

Divide documentos en chunks (1400 chars, overlap 200), embebe con Titan Embed v2 en paralelo (5 workers), sube a Pinecone en lotes de 100. **Con 80K chunks: ~25-30 min. Costo: ~$0.46 USD.**

```bash
PYTHONUTF8=1 python 02-index-pinecone.py --yes
# El flag --yes evita prompt interactivo (necesario en pipelines CI)
# PYTHONUTF8=1 evita UnicodeEncodeError con caracteres especiales en Windows
```

**Límite Pinecone Free Tier**: 100,000 vectores. Si la KB supera este límite, eliminar el índice y re-indexar solo los documentos core (excluir código fuente o upgradar a Standard).

### Paso 3 — Desplegar AWS (`03-deploy-aws.py`)

Crea automáticamente: IAM role + Lambda + API Gateway HTTP API + S3 bucket website. Inyecta el endpoint en el HTML antes de subir. Guarda estado en `.deploy-state.json`.

```bash
python 03-deploy-aws.py
# Output:
# ✓ Rol gemcog-{cliente}-lambda-role
# ✓ Lambda gemcog-{cliente}-api
# ✓ API: https://{id}.execute-api.us-east-1.amazonaws.com/chat
# ✓ Frontend: http://gemcog-{cliente}-chatbot-ui.s3-website-us-east-1.amazonaws.com
```

---

## Config Canónica por Proyecto

```python
# config.py — NO subir a git (.gitignore)
import pathlib

AWS_REGION  = "us-east-1"
AWS_PROFILE = None  # None = credenciales default

PROJECT_SLUG    = "gemcog-{cliente}"          # ej. "gemcog-banamex"
WEBSITE_BUCKET  = f"{PROJECT_SLUG}-chatbot-ui"
LAMBDA_NAME     = f"{PROJECT_SLUG}-api"

EMBEDDING_MODEL_ARN = f"arn:aws:bedrock:{AWS_REGION}::foundation-model/amazon.titan-embed-text-v2:0"
EMBEDDING_DIMENSION = 1024
RESPONSE_MODEL_ID   = "amazon.nova-pro-v1:0"   # Converse API — sin use-case form

THIS_DIR      = pathlib.Path(__file__).parent
BANAMEX_DIR   = THIS_DIR.parent
DOCUMENTS_DIR = THIS_DIR / "documents"
LAMBDA_DIR    = THIS_DIR / "lambda"
FRONTEND_DIR  = THIS_DIR / "frontend"
DEPLOY_STATE  = THIS_DIR / ".deploy-state.json"

PINECONE_API_KEY    = "pcsk_..."              # API Key de Pinecone
PINECONE_INDEX_HOST = "https://gemcog-..."    # Host del índice
PINECONE_INDEX_NAME = "gemcog-{cliente}"

CHUNK_SIZE    = 1400
CHUNK_OVERLAP = 200

SYSTEM_PROMPT = """\
Eres el Asistente del Gemelo Cognitivo del sistema {NOMBRE_SISTEMA} de {CLIENTE}.
Tu base de conocimiento contiene el análisis completo de la Fase DISCOVER...
[Ver §System Prompt Template]
$search_results$\
"""
```

---

## System Prompt Template

```
Eres el Asistente del Gemelo Cognitivo del {plataforma} de {cliente},
especializado en {sistemas analizados}.

Tu base de conocimiento contiene el análisis completo de la Fase DISCOVER
(Etapas 0–{N}) del proyecto de Modernización de Mainframe:
- Código fuente {lenguajes} extraído de producción
- Vocabulario de dominio (vocab), grafo de dependencias, biografías de programas (souls)
- Gemelo Cognitivo unificado (gemelo JSON)
- Reglas de negocio, grupos funcionales, diccionario de datos
- Anomalías detectadas {ANO-xxx a ANO-yyy}

Instrucciones:
1. Responde SIEMPRE en español técnico claro y preciso.
2. Sé específico: cita programas por su nombre exacto ({ejemplos}).
3. Indica si un programa es ONLINE o BATCH cuando sea relevante.
4. Si una anomalía documentada es relevante, menciónala explícitamente.
5. Si no tienes información suficiente en la base de conocimiento, dilo con claridad —
   nunca inventes datos técnicos ni nombres de programas.
6. Usa bloques de código para fragmentos de código fuente (máximo 30 líneas).
7. Para preguntas de arquitectura, menciona sistemas externos relacionados
   ({sistemas externos}) cuando corresponda.
8. Mantén la confidencialidad del proyecto.

$search_results$
```

---

## Lambda Handler — Puntos Críticos

El Lambda usa `bedrock.converse()` (no `invoke_model`) para compatibilidad con modelos 2025+.

### Error: "conversation must start with a user message"

**Causa**: el frontend empuja el mensaje actual al historial ANTES de enviarlo, generando mensajes duplicados o historial que empieza con `assistant`.

**Fix en Lambda**:
```python
# Construir mensajes desde historial
messages = []
for h in history[-MAX_HISTORY:]:
    role, content = h.get("role","user"), h.get("content","")
    if role in ("user","assistant") and content:
        messages.append({"role": role, "content": [{"text": content}]})

# Si historial ya termina con el query actual, no duplicar
if not messages or messages[-1]["content"][0]["text"] != query:
    messages.append({"role": "user", "content": [{"text": query}]})

# Garantizar que empieza con user
while messages and messages[0]["role"] != "user":
    messages.pop(0)
```

### Error: "temperature and top_p cannot both be specified"

**Fix**: usar solo `temperature`, eliminar `top_p` del body de la llamada.

### Error: "This model version has reached the end of its life"

**Fix**: actualizar `RESPONSE_MODEL_ID` en el Lambda. Verificar modelos activos:
```bash
aws bedrock list-foundation-models --region us-east-1 \
  --query 'modelSummaries[?modelLifecycle.status==`ACTIVE`].[modelId]' --output text
```

Actualizar env var del Lambda sin redeploy del código:
```python
boto3.client("lambda").update_function_configuration(
    FunctionName="gemcog-{cliente}-api",
    Environment={"Variables": {**current_vars, "RESPONSE_MODEL_ID": new_model}}
)
```

### Error: "Model use case details have not been submitted"

**Causa**: modelos Claude nuevos requieren un formulario de use-case en la consola de Bedrock. Los modelos Amazon Nova NO requieren este formulario.

**Fix rápido**: cambiar a `amazon.nova-pro-v1:0` (acceso inmediato, sin formulario).

---

## Personalización de Marca del Cliente

El frontend `index.html` usa variables CSS centralizadas. Para cambiar la marca:

### Colores (`:root` en CSS)
```css
:root {
  --bg:   #080d1a;   /* fondo oscuro — ajustar tono según cliente */
  --red:  #CC2127;   /* color primario del cliente */
  --gold: #C8960C;   /* acento secundario */
  --navy: #2D2E92;   /* acento terciario */
}
```

### Logo del cliente

Localizar el logo en `Solutioning/Design - Studio/logos/`. Convertir a base64 y embeber directamente en el HTML:

```python
import base64, pathlib
logo_b64 = base64.b64encode(pathlib.Path("logo.png").read_bytes()).decode()
logo_uri = f"data:image/png;base64,{logo_b64}"
# Usar logo_uri como src del <img> en nav y welcome screen
```

**Ventaja del base64 inline**: el logo nunca falla por CORS ni rutas relativas. El HTML es completamente autocontenido.

### Nav logo (pill sobre fondo blanco)
```html
<div class="nav-banamex-wrap">
  <img src="{logo_uri}" alt="{Cliente}" class="nav-banamex-img">
</div>
```
```css
.nav-banamex-wrap { background:#fff; border-radius:8px; padding:4px 10px; }
.nav-banamex-img  { height:28px; width:auto; }
```

---

## Costos Estimados

| Servicio | Costo mensual | Notas |
|----------|--------------|-------|
| Pinecone Free Tier | $0 | Hasta 100K vectores · serverless |
| Lambda | $0 | < 1M requests/mes en free tier |
| API Gateway | $0 | < 1M requests/mes en free tier |
| S3 Static Website | < $0.05 | Solo almacenamiento del HTML |
| Bedrock Titan Embed (indexación) | $0.46 USD (una sola vez) | 80K chunks × 350 tokens avg |
| Bedrock Nova Pro (uso) | ~$0.008 USD/consulta | $0.0008/1K tokens in + $0.0032/1K out |
| **Total infraestructura** | **~$0/mes** | + uso Bedrock según volumen |

---

## DoR — Prerequisitos para Invocar Este Specialist

- [ ] Etapa 0 completada: inventario de programas + estructura de carpetas del cliente
- [ ] Al menos uno de: vocab JSON, souls JSON, gemelo JSON generado por RE Specialist
- [ ] Cuenta AWS con acceso a Bedrock (Titan Embed + Nova Pro) en us-east-1
- [ ] Cuenta Pinecone Free Tier creada e índice `gemcog-{cliente}` configurado
- [ ] Logo del cliente disponible en `Solutioning/Design - Studio/logos/`
- [ ] Colores de marca del cliente identificados (hex primario + secundario)

## DoD — Criterios de Entrega

- [ ] URL pública del chatbot accesible sin VPN ni instalación
- [ ] Al menos 3 preguntas de prueba respondidas correctamente con citas
- [ ] Logo y colores del cliente aplicados en nav + welcome screen
- [ ] Historial multi-turn funcionando (mínimo 3 turnos sin error)
- [ ] Fuentes/citas expandibles mostrando el chunk origen de cada respuesta
- [ ] Lambda con modelo ACTIVE verificado (no EOL)
- [ ] `config.py` y `.deploy-state.json` en `.gitignore` del proyecto

---

## Anti-patrones

- **[ANTIPATRÓN]** Desplegar con modelo EOL sin verificar disponibilidad — siempre consultar modelos ACTIVE antes del primer deploy.
- **[ANTIPATRÓN]** Subir `config.py` al repo — contiene API keys de Pinecone y credenciales de AWS.
- **[ANTIPATRÓN]** Usar `invoke_model` con modelos 2025+ — solo funcionan con `converse()`.
- **[ANTIPATRÓN]** Indexar más de 100K chunks en Pinecone Free Tier — revisar límite antes de indexar código fuente completo.
- **[ANTIPATRÓN]** Hardcodear el `top_p` junto con `temperature` — la API Converse solo acepta uno.
- **[ANTIPATRÓN]** Usar el chatbot como sustituto de la revisión humana de reglas regulatorias — es una herramienta de consulta, no de decisión.

---

## Instancia de Referencia

| Proyecto | Carpeta | Estado | Vectores | URL |
|----------|---------|--------|----------|-----|
| Banamex S500+S151 | `Banamex/bedrock-chatbot/` | `[STATE: ACTIVE]` | 98,782 | `gemcog-banamex-chatbot-ui.s3-website-us-east-1.amazonaws.com` |

La instancia Banamex es el **reference implementation** de este specialist. Toda decisión de diseño tomada durante ese proyecto está documentada en el historial de conversación y en los scripts de `bedrock-chatbot/`.

---

*Última actualización: 2026-07-13 · v1.0 · Specialist creado a partir de la implementación Banamex S500+S151. Stack validado en producción: Pinecone Free + Titan Embed v2 + Nova Pro via Converse API + Lambda + API GW + S3.*
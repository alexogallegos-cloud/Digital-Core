"""
Lambda handler — GemCog Chatbot (RAG con Pinecone + Bedrock Converse API).

Flujo por llamada:
  1. Embeber la pregunta con Amazon Titan Embed Text v2
  2. Buscar los 15 chunks más relevantes en Pinecone (REST API)
  3. Generar respuesta con Bedrock Converse API (Amazon Nova Pro)
  4. Devolver respuesta + fuentes al frontend

Variables de entorno requeridas:
  PINECONE_INDEX_HOST  — https://gemcog-banamex-xxx.pinecone.io
  PINECONE_API_KEY     — api key de Pinecone
  BEDROCK_REGION       — us-east-1
  RESPONSE_MODEL_ID    — amazon.nova-pro-v1:0
  SYSTEM_PROMPT        — prompt del sistema con $search_results$
"""

import json
import os
import urllib.request
import urllib.error
import boto3

REGION        = os.environ.get("BEDROCK_REGION", "us-east-1")
PINECONE_HOST = os.environ["PINECONE_INDEX_HOST"].rstrip("/")
PINECONE_KEY  = os.environ["PINECONE_API_KEY"]
MODEL_ID      = os.environ["RESPONSE_MODEL_ID"]
SYSTEM_PROMPT = os.environ["SYSTEM_PROMPT"]
TOP_K         = 15
MAX_HISTORY   = 6

_bedrock = None

def _get_bedrock():
    global _bedrock
    if _bedrock is None:
        _bedrock = boto3.client("bedrock-runtime", region_name=REGION)
    return _bedrock


# ─── Embedding ────────────────────────────────────────────────────────────────
def embed(text: str) -> list:
    resp = _get_bedrock().invoke_model(
        modelId="amazon.titan-embed-text-v2:0",
        contentType="application/json",
        accept="application/json",
        body=json.dumps({
            "inputText": text[:20000],
            "dimensions": 1024,
            "normalize": True,
        }),
    )
    return json.loads(resp["body"].read())["embedding"]


# ─── Pinecone query (REST sin SDK) ────────────────────────────────────────────
def pinecone_query(vector: list, top_k: int = TOP_K) -> list:
    payload = json.dumps({
        "vector": vector,
        "topK": top_k,
        "includeMetadata": True,
    }).encode("utf-8")

    req = urllib.request.Request(
        f"{PINECONE_HOST}/query",
        data=payload,
        headers={
            "Content-Type": "application/json",
            "Api-Key": PINECONE_KEY,
        },
        method="POST",
    )
    with urllib.request.urlopen(req, timeout=10) as r:
        body = json.loads(r.read())

    return body.get("matches", [])


# ─── Generación con Bedrock Converse API ─────────────────────────────────────
def generate(query: str, chunks: list, history: list) -> str:
    # Construir contexto de búsqueda
    context_parts = []
    for i, m in enumerate(chunks, 1):
        meta  = m.get("metadata", {})
        src   = meta.get("source", "fuente")
        text  = meta.get("text", "")
        score = m.get("score", 0)
        context_parts.append(f"[{i}] Fuente: {src} (relevancia: {score:.2f})\n{text}")

    search_results = "\n\n---\n\n".join(context_parts)
    system_text = SYSTEM_PROMPT.replace("$search_results$", search_results)

    # Construir mensajes con historial (Converse API format)
    # El frontend ya empujó el mensaje actual al historial antes de enviar,
    # así que history puede terminar en {role: user, content: query}.
    # Construimos la lista y al final garantizamos que termina con el query actual.
    messages = []
    for h in history[-MAX_HISTORY:]:
        role    = h.get("role", "user")
        content = h.get("content", "")
        if role in ("user", "assistant") and content:
            messages.append({
                "role": role,
                "content": [{"text": content}],
            })

    # Si el historial ya termina con el mensaje actual, no duplicar
    last_text = (
        messages[-1]["content"][0]["text"] if messages else ""
    )
    if last_text != query:
        messages.append({"role": "user", "content": [{"text": query}]})

    # Garantizar que la conversación empieza con un mensaje de usuario
    while messages and messages[0]["role"] != "user":
        messages.pop(0)

    resp = _get_bedrock().converse(
        modelId=MODEL_ID,
        system=[{"text": system_text}],
        messages=messages,
        inferenceConfig={
            "maxTokens": 2048,
            "temperature": 0.1,
        },
    )

    return resp["output"]["message"]["content"][0]["text"]


# ─── Handler principal ────────────────────────────────────────────────────────
def handler(event, context):
    method = (
        event.get("requestContext", {}).get("http", {}).get("method", "")
        or event.get("httpMethod", "")
    )
    if method == "OPTIONS":
        return _cors(200, "")

    try:
        body    = json.loads(event.get("body") or "{}")
        query   = (body.get("message") or "").strip()
        history = body.get("history") or []

        if not query:
            return _cors(400, json.dumps({"error": "Mensaje vacío"}))

        vec     = embed(query)
        matches = pinecone_query(vec)
        answer  = generate(query, matches, history)
        citations = _build_citations(matches)

        return _cors(200, json.dumps({
            "response":  answer,
            "citations": citations,
        }))

    except Exception as e:
        print(f"[ERROR] {type(e).__name__}: {e}")
        err_resp = getattr(e, "response", {}) or {}
        err_code = (err_resp.get("Error") or {}).get("Code", "")
        if err_code in ("AccessDeniedException", "UnauthorizedException"):
            return _cors(403, json.dumps({
                "error": "Acceso denegado a Bedrock. Verifica permisos IAM y model access."
            }))
        return _cors(500, json.dumps({
            "error": f"{type(e).__name__}: {str(e)[:300]}"
        }))


def _build_citations(matches: list) -> list:
    seen = set()
    out  = []
    for m in matches:
        meta    = m.get("metadata", {})
        source  = meta.get("source", "fuente")
        snippet = (meta.get("text") or "")[:350].strip()
        if snippet:
            snippet += "…"
        key = (source, snippet[:60])
        if key not in seen:
            seen.add(key)
            out.append({"source": source, "snippet": snippet})
    return out[:8]


def _cors(status: int, body: str) -> dict:
    return {
        "statusCode": status,
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin":  "*",
            "Access-Control-Allow-Headers": "Content-Type",
            "Access-Control-Allow-Methods": "POST, OPTIONS",
        },
        "body": body,
    }
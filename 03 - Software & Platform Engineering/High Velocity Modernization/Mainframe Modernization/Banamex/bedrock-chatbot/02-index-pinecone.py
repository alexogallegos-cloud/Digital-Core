"""
Paso 2 — Indexar documentos en Pinecone (vector store gratuito).

Lee todos los archivos de documents/, los divide en chunks, los embebe con
Amazon Bedrock Titan Embed v2, y los sube a tu índice Pinecone.

Ejecutar UNA SOLA VEZ (o cuando cambies la base de conocimiento).

Prerequisitos:
  1. pip install -r requirements.txt
  2. Editar config.py:
       PINECONE_API_KEY    = "tu-api-key"
       PINECONE_INDEX_HOST = "https://gemcog-banamex-xxx.pinecone.io"
  3. Tener AWS credentials configuradas con acceso a Bedrock.
  4. Haber ejecutado primero: python 01-prepare-docs.py

Uso:
  python 02-index-pinecone.py
"""

import boto3
import json
import pathlib
import re
import time

from pinecone import Pinecone

from concurrent.futures import ThreadPoolExecutor, as_completed

from config import (
    AWS_REGION, AWS_PROFILE,
    PINECONE_API_KEY, PINECONE_INDEX_HOST, PINECONE_INDEX_NAME,
    EMBEDDING_MODEL_ARN, EMBEDDING_DIMENSION,
    DOCUMENTS_DIR, CHUNK_SIZE, CHUNK_OVERLAP,
)

# ─── Clientes ─────────────────────────────────────────────────────────────────
session         = boto3.Session(profile_name=AWS_PROFILE, region_name=AWS_REGION)
bedrock_runtime = session.client("bedrock-runtime", region_name=AWS_REGION)
pc              = Pinecone(api_key=PINECONE_API_KEY)
index           = pc.Index(host=PINECONE_INDEX_HOST)


# ─── Chunking ─────────────────────────────────────────────────────────────────
def chunk_text(text: str, source: str) -> list[dict]:
    """Divide un texto en chunks con overlap."""
    # Limpiar: quitar exceso de líneas en blanco
    text = re.sub(r'\n{4,}', '\n\n\n', text)
    text = text.strip()

    if len(text) <= CHUNK_SIZE:
        return [{"text": text, "source": source, "chunk": 0}]

    chunks = []
    start = 0
    idx = 0
    while start < len(text):
        end = start + CHUNK_SIZE

        # Intentar cortar en límite de párrafo
        if end < len(text):
            cutpoint = text.rfind('\n\n', start, end)
            if cutpoint == -1 or cutpoint <= start:
                cutpoint = text.rfind('\n', start, end)
            if cutpoint == -1 or cutpoint <= start:
                cutpoint = end
            end = cutpoint

        chunk_text_val = text[start:end].strip()
        if chunk_text_val:
            chunks.append({
                "text": chunk_text_val,
                "source": source,
                "chunk": idx,
            })
            idx += 1

        # Avanzar con overlap
        start = max(end - CHUNK_OVERLAP, start + 1)
        if start >= len(text):
            break

    return chunks


# ─── Embedding ────────────────────────────────────────────────────────────────
def embed(text: str, retries: int = 5) -> list[float]:
    """Embebe texto con Amazon Titan Embed Text v2 (con retry en throttling)."""
    text = text[:20000]
    for attempt in range(retries):
        try:
            resp = bedrock_runtime.invoke_model(
                modelId="amazon.titan-embed-text-v2:0",
                contentType="application/json",
                accept="application/json",
                body=json.dumps({
                    "inputText": text,
                    "dimensions": EMBEDDING_DIMENSION,
                    "normalize": True,
                }),
            )
            return json.loads(resp["body"].read())["embedding"]
        except Exception as e:
            if attempt < retries - 1 and "ThrottlingException" in str(type(e).__name__):
                wait = 2 ** attempt
                time.sleep(wait)
                continue
            raise


# ─── Upsert en lotes ─────────────────────────────────────────────────────────
def upsert_batch(vectors: list[dict]):
    """Sube un lote de vectores a Pinecone."""
    index.upsert(vectors=vectors)


# ─── Main ─────────────────────────────────────────────────────────────────────
def main():
    print("── Indexación en Pinecone ──────────────────────────────────────────")
    print(f"  Documentos : {DOCUMENTS_DIR}")
    print(f"  Índice     : {PINECONE_INDEX_NAME}")
    print(f"  Dimensión  : {EMBEDDING_DIMENSION}\n")

    if not DOCUMENTS_DIR.exists():
        print("✗  Carpeta 'documents/' no encontrada. Ejecuta primero: python 01-prepare-docs.py")
        return

    files = [f for f in DOCUMENTS_DIR.rglob("*") if f.is_file()]
    print(f"  Archivos encontrados: {len(files)}\n")

    all_chunks = []
    for f in sorted(files):
        try:
            text = f.read_text(encoding="utf-8", errors="replace")
        except Exception as e:
            print(f"  ⚠  Error leyendo {f.name}: {e}")
            continue

        source = f.name
        chunks = chunk_text(text, source)
        all_chunks.extend(chunks)

    print(f"  Chunks totales: {len(all_chunks)}")
    print(f"  Estimado vectores Pinecone: {len(all_chunks)} (límite free: 100,000)\n")

    # Confirmar antes de embeddir (tiene costo por tokens)
    est_tokens = sum(len(c["text"]) // 4 for c in all_chunks)
    est_cost   = est_tokens / 1_000_000 * 0.02  # $0.02/1M tokens Titan v2
    print(f"  Costo estimado de embedding: ${est_cost:.4f} USD (~${est_cost*17:.2f} MXN)")
    import sys
    auto_yes = "--yes" in sys.argv or not sys.stdin.isatty()
    if not auto_yes:
        resp = input("  ¿Continuar? [s/N] ").strip().lower()
        if resp != "s":
            print("  Cancelado.")
            return
    else:
        print("  Continuando automáticamente (--yes)")

    # Embedder en paralelo y subir en lotes
    UPSERT_BATCH = 100
    WORKERS      = 5    # paralelo moderado para no throttlear Bedrock
    SUBMIT_BATCH = 500  # cuántos futures activos máximo a la vez
    errors    = 0
    processed = 0
    upsert_buf = []

    def process_chunk(chunk, idx):
        vid = (
            chunk["source"]
            .replace(".", "_").replace(" ", "_").replace("/", "_")
        ) + f"_{idx}"
        vec = embed(chunk["text"])
        return {
            "id": vid[:512],
            "values": vec,
            "metadata": {
                "text":   chunk["text"][:2000],
                "source": chunk["source"],
                "chunk":  chunk["chunk"],
            },
        }

    total = len(all_chunks)
    with ThreadPoolExecutor(max_workers=WORKERS) as pool:
        # Procesar en ventanas de SUBMIT_BATCH para no saturar memoria
        for window_start in range(0, total, SUBMIT_BATCH):
            window = all_chunks[window_start: window_start + SUBMIT_BATCH]
            futures = {
                pool.submit(process_chunk, ch, window_start + i): i
                for i, ch in enumerate(window)
            }
            for future in as_completed(futures):
                try:
                    upsert_buf.append(future.result())
                    processed += 1
                except Exception as e:
                    errors += 1
                    print(f"  ⚠  Error embedding: {e}")

                if len(upsert_buf) >= UPSERT_BATCH:
                    upsert_batch(upsert_buf)
                    upsert_buf = []
                    print(f"  ✓  {processed}/{total} chunks indexados")

    if upsert_buf:
        upsert_batch(upsert_buf)
        print(f"  ✓  {processed}/{total} chunks indexados")

    # Verificar estadísticas
    time.sleep(3)
    stats = index.describe_index_stats()
    total_vecs = stats.get("total_vector_count", "?")

    print(f"\n── Resultado ────────────────────────────────────────────────────────")
    print(f"  Chunks indexados : {processed}")
    print(f"  Errores          : {errors}")
    print(f"  Vectores en índice: {total_vecs}")
    if errors == 0:
        print(f"\n  ✓  Indexación completa. Ejecuta ahora: python 03-deploy-aws.py")
    else:
        print(f"\n  ⚠  Hay {errors} errores. Revisa los mensajes y reintenta.")


if __name__ == "__main__":
    main()
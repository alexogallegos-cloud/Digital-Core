"""
enrich-strategic.py — Swarm AI para capa estratégica del Bank Brain BanCoppel
Lee las minutas Plan Director chunk a chunk y extrae con Claude API:
  - decisions  : decisiones estratégicas (incluyendo las implícitas)
  - positions  : posturas de actores sobre temas clave
  - open_items : pendientes con dueño y prioridad

Los resultados complementan (no reemplazan) la extracción heurística de
extract-strategic.py. IDs con prefijo AI- para distinguir.

Requiere:
    pip install anthropic python-docx
    export ANTHROPIC_API_KEY=sk-ant-...

Uso:
    python enrich-strategic.py                  # procesa docs nuevos
    python enrich-strategic.py --dry-run        # muestra chunks, no llama API
    python enrich-strategic.py --model sonnet   # usa claude-sonnet-4-6
    python enrich-strategic.py --reset          # borra log y reprocesa todo
"""

import argparse
import json
import os
import re
import sqlite3
import sys
import time
from pathlib import Path
from typing import Optional

# ── Rutas ──────────────────────────────────────────────────────────────────
BASE      = Path(__file__).parent.parent
BRAIN_DB  = Path(__file__).parent / "bank-brain.db"
MINUTAS   = BASE / "systems/core/Informix/source/minutas/pd"

# ── Modelos disponibles ────────────────────────────────────────────────────
MODELS = {
    "haiku":  "claude-haiku-4-5-20251001",   # default: rápido y económico
    "sonnet": "claude-sonnet-4-6",            # mayor calidad semántica
}
DEFAULT_MODEL = "haiku"

# ── Parámetros de chunking ─────────────────────────────────────────────────
CHUNK_WORDS   = 1_400   # palabras por chunk (deja margen para prompt + respuesta)
OVERLAP_WORDS = 150     # overlap entre chunks para no cortar contexto

# ── Stakeholders conocidos (para normalización de nombres en respuestas AI) ─
NAME_ALIASES: dict[str, str] = {
    "juan manuel": "juan-manuel", "juanmanuel": "juan-manuel",
    "daniel": "daniel-angeles", "daniel ángeles": "daniel-angeles",
    "daniel angeles": "daniel-angeles",
    "arturo": "arturo-perez", "arturo pérez": "arturo-perez",
    "arturo perez": "arturo-perez",
    "erica": "erica-mata", "erika": "erica-mata",
    "erica mata": "erica-mata", "erika mata": "erica-mata",
    "arcadio": "arcadio",
    "carlos": "carlos-bc",
    "brenda": "brenda",
    "rodrigo": "rodrigo",
    "pablo": "pablo-lorenzo", "pablo lorenzo": "pablo-lorenzo",
    "pav": "pablo-lorenzo", "pavl": "pablo-lorenzo",
    "lukasz": "lukasz-pietrzyk",
    "alejandro gallegos": "alejandro-gallegos",
    "alejandro": "alejandro-gallegos",
    "gabriela": "gabriela-maximiliano",
    "gabriela maximiliano": "gabriela-maximiliano",
    "karina": "karina-zepeda",
    "salomon": "salomon-monroy",
    "luis barragán": "luis-barragan", "luis barragan": "luis-barragan",
    "emmy": "emmy",
}

VALID_TOPICS = {
    "apolo", "smartvista", "transact", "atlas", "pisa",
    "arquitectura", "seguridad", "gobierno", "cronograma",
    "datos", "integracion", "testing", "regulatorio", "general",
}

# ── DDL para tracking ──────────────────────────────────────────────────────
TRACKING_DDL = """
CREATE TABLE IF NOT EXISTS enrichment_log (
    doc_id      INTEGER PRIMARY KEY,
    filename    TEXT,
    chunks      INTEGER,
    decisions   INTEGER DEFAULT 0,
    positions   INTEGER DEFAULT 0,
    open_items  INTEGER DEFAULT 0,
    model       TEXT,
    processed_at TEXT,
    error       TEXT
);
"""

# ── Tool schema para extracción estructurada ───────────────────────────────
EXTRACT_TOOL = {
    "name": "extract_strategic_intelligence",
    "description": (
        "Extrae inteligencia estratégica de un fragmento de minuta de reunión del "
        "programa Unity de BanCoppel. Devuelve SOLO lo que esté explícitamente en "
        "el texto — no inventar, no inferir."
    ),
    "input_schema": {
        "type": "object",
        "properties": {
            "decisions": {
                "type": "array",
                "description": "Decisiones tomadas en la reunión (acordadas, confirmadas, definidas)",
                "items": {
                    "type": "object",
                    "properties": {
                        "decision": {
                            "type": "string",
                            "description": "Texto de la decisión en 1-3 oraciones"
                        },
                        "driver_name": {
                            "type": "string",
                            "description": "Nombre del actor que impulsó la decisión (null si no se menciona)"
                        },
                        "topic": {
                            "type": "string",
                            "enum": sorted(VALID_TOPICS),
                            "description": "Sistema o área temática principal"
                        },
                        "confidence": {
                            "type": "string",
                            "enum": ["high", "medium", "low"],
                            "description": "high=decisión explícita tomada, medium=acuerdo implícito, low=propuesta"
                        }
                    },
                    "required": ["decision", "topic", "confidence"]
                }
            },
            "positions": {
                "type": "array",
                "description": "Posturas, opiniones o preocupaciones atribuidas a personas nombradas",
                "items": {
                    "type": "object",
                    "properties": {
                        "stakeholder_name": {
                            "type": "string",
                            "description": "Nombre de la persona (tal como aparece en el texto)"
                        },
                        "topic": {
                            "type": "string",
                            "enum": sorted(VALID_TOPICS),
                        },
                        "stance": {
                            "type": "string",
                            "description": "Descripción de la postura en 1-2 oraciones"
                        },
                        "sentiment": {
                            "type": "string",
                            "enum": ["supportive", "concerned", "blocking", "neutral"]
                        }
                    },
                    "required": ["stakeholder_name", "topic", "stance", "sentiment"]
                }
            },
            "open_items": {
                "type": "array",
                "description": "Pendientes, compromisos o action items identificados",
                "items": {
                    "type": "object",
                    "properties": {
                        "item": {
                            "type": "string",
                            "description": "Descripción del pendiente en 1-2 oraciones"
                        },
                        "owner_name": {
                            "type": "string",
                            "description": "Nombre del responsable (null si no se menciona)"
                        },
                        "priority": {
                            "type": "string",
                            "enum": ["high", "medium", "low"]
                        },
                        "systems": {
                            "type": "array",
                            "items": {"type": "string"},
                            "description": "Sistemas involucrados (apolo, transact, smartvista, atlas, pisa, mulesoft)"
                        }
                    },
                    "required": ["item", "priority"]
                }
            }
        },
        "required": ["decisions", "positions", "open_items"]
    }
}

SYSTEM_PROMPT = """\
Eres un analista experto en minutas del programa Unity de BanCoppel.
Unity es la modernización del core bancario de BanCoppel:
  - PISA/BCOPCore: sistema legacy (IBM Informix SPL) que se decommissiona
  - Apolo: sistema destino para crédito, origination y cobranza
  - SmartVista/BPC: sistema destino para tarjetas TDC/TDD
  - Transact (Temenos): sistema destino para cuentas, depósitos, SPEI, TEF
  - Atlas: plataforma de migración de datos
  - MuleSoft: middleware de integración
  - ACN = Accenture (proveedor de servicios)
  - BCP = BanCoppel

Extrae información estratégica SOLO de lo que dice el texto.
No inventes, no alucinices, no rellenes campos con información fuera del fragmento.
Si un campo no está en el texto, omite el elemento o deja driver_name/owner_name en null.
"""


# ── Helpers ────────────────────────────────────────────────────────────────

def normalize_name(name: Optional[str]) -> Optional[str]:
    """Convierte nombre libre → ID de stakeholder conocido."""
    if not name:
        return None
    t = name.lower().strip()
    for alias, sid in NAME_ALIASES.items():
        if alias in t:
            return sid
    return None


def text_from_docx(path: Path) -> str:
    """Extrae texto plano de un .docx."""
    import docx
    doc = docx.Document(str(path))
    return "\n".join(p.text.strip() for p in doc.paragraphs if p.text.strip())


def make_chunks(text: str, chunk_words: int, overlap_words: int) -> list[str]:
    """Divide texto en chunks por palabras con overlap."""
    words = text.split()
    if not words:
        return []
    chunks = []
    step = max(1, chunk_words - overlap_words)
    for start in range(0, len(words), step):
        chunk = " ".join(words[start: start + chunk_words])
        if chunk.strip():
            chunks.append(chunk)
        if start + chunk_words >= len(words):
            break
    return chunks


def call_claude(
    client,
    model: str,
    chunk_text: str,
    doc_date: Optional[str],
    filename: str,
    dry_run: bool,
) -> dict:
    """Llama a Claude API con tool_use y retorna el resultado estructurado."""
    if dry_run:
        words = chunk_text.split()
        print(f"    [DRY-RUN] chunk ~{len(words)} palabras: {chunk_text[:80]}...")
        return {"decisions": [], "positions": [], "open_items": []}

    user_msg = f"Fragmento de minuta {'del ' + doc_date if doc_date else ''} ({filename}):\n\n{chunk_text}"

    response = client.messages.create(
        model=model,
        max_tokens=2048,
        system=SYSTEM_PROMPT,
        tools=[EXTRACT_TOOL],
        tool_choice={"type": "tool", "name": "extract_strategic_intelligence"},
        messages=[{"role": "user", "content": user_msg}],
    )

    # Extraer el tool_use block
    for block in response.content:
        if block.type == "tool_use" and block.name == "extract_strategic_intelligence":
            return block.input

    return {"decisions": [], "positions": [], "open_items": []}


def dedup_key_decision(d: str) -> str:
    return re.sub(r"\s+", " ", d.lower().strip())[:100]


def dedup_key_oi(item: str) -> str:
    return re.sub(r"\s+", " ", item.lower().strip())[:80]


def dedup_key_pos(sid: str, stance: str) -> tuple:
    return (sid, re.sub(r"\s+", " ", stance.lower().strip())[:60])


# ── Procesamiento principal ────────────────────────────────────────────────

def process_doc(
    db: sqlite3.Connection,
    client,
    model: str,
    doc_id: int,
    doc_date: Optional[str],
    filename: str,
    path: Path,
    dry_run: bool,
    seen_decisions: set,
    seen_positions: set,
    seen_open_items: set,
    counters: dict,
) -> dict:
    """Procesa un documento completo y escribe resultados en la DB."""
    print(f"\n  [{doc_id:>3}] {filename}")

    try:
        text = text_from_docx(path)
    except Exception as e:
        print(f"    ERROR leyendo docx: {e}")
        return {"chunks": 0, "decisions": 0, "positions": 0, "open_items": 0, "error": str(e)}

    chunks = make_chunks(text, CHUNK_WORDS, OVERLAP_WORDS)
    print(f"    {len(chunks)} chunks · ~{len(text.split())} palabras totales")

    doc_decisions = 0
    doc_positions = 0
    doc_open_items = 0

    for i, chunk in enumerate(chunks, 1):
        print(f"    chunk {i}/{len(chunks)}", end="", flush=True)

        try:
            result = call_claude(client, model, chunk, doc_date, filename, dry_run)
        except Exception as e:
            print(f" ERROR: {e}")
            time.sleep(2)
            continue

        # ── Decisions ──────────────────────────────────────────────────────
        for d in result.get("decisions", []):
            decision_text = (d.get("decision") or "").strip()
            if not decision_text or len(decision_text) < 15:
                continue
            dk = dedup_key_decision(decision_text)
            if dk in seen_decisions:
                continue
            seen_decisions.add(dk)

            topic = d.get("topic", "general")
            if topic not in VALID_TOPICS:
                topic = "general"

            driver_raw = d.get("driver_name")
            driver_id  = normalize_name(driver_raw)

            counters["dec"] += 1
            dec_id = f"AI-DEC-{counters['dec']:04d}"

            if not dry_run:
                db.execute(
                    """INSERT OR IGNORE INTO decisions
                       (id, date, topic, decision, driver_id, systems, doc_id, confidence)
                       VALUES (?,?,?,?,?,?,?,?)""",
                    (
                        dec_id, doc_date, topic,
                        decision_text[:500], driver_id,
                        json.dumps([topic], ensure_ascii=False),
                        doc_id, d.get("confidence", "medium"),
                    ),
                )
            doc_decisions += 1

        # ── Positions ──────────────────────────────────────────────────────
        for p in result.get("positions", []):
            sh_name = (p.get("stakeholder_name") or "").strip()
            stance  = (p.get("stance") or "").strip()
            if not sh_name or not stance or len(stance) < 10:
                continue
            sid = normalize_name(sh_name)
            if not sid:
                continue  # solo stakeholders conocidos
            pk = dedup_key_pos(sid, stance)
            if pk in seen_positions:
                continue
            seen_positions.add(pk)

            topic = p.get("topic", "general")
            if topic not in VALID_TOPICS:
                topic = "general"

            if not dry_run:
                db.execute(
                    """INSERT INTO positions
                       (stakeholder_id, topic, stance, quote, date, doc_id, sentiment)
                       VALUES (?,?,?,?,?,?,?)""",
                    (
                        sid, topic, stance[:500], sh_name,
                        doc_date, doc_id, p.get("sentiment", "neutral"),
                    ),
                )
            doc_positions += 1

        # ── Open items ─────────────────────────────────────────────────────
        for oi in result.get("open_items", []):
            item_text = (oi.get("item") or "").strip()
            if not item_text or len(item_text) < 10:
                continue
            oik = dedup_key_oi(item_text)
            if oik in seen_open_items:
                continue
            seen_open_items.add(oik)

            owner_id = normalize_name(oi.get("owner_name"))
            systems  = oi.get("systems") or []

            counters["oi"] += 1
            oi_id = f"AI-OI-{counters['oi']:04d}"

            if not dry_run:
                db.execute(
                    """INSERT OR IGNORE INTO open_items
                       (id, date, item, owner_id, priority, systems, doc_id, status)
                       VALUES (?,?,?,?,?,?,?,?)""",
                    (
                        oi_id, doc_date, item_text[:400], owner_id,
                        oi.get("priority", "medium"),
                        json.dumps(systems, ensure_ascii=False),
                        doc_id, "open",
                    ),
                )
            doc_open_items += 1

        print(f" → dec:{doc_decisions} pos:{doc_positions} oi:{doc_open_items}")

        if not dry_run:
            db.commit()
            time.sleep(0.3)  # rate limit suave

    return {
        "chunks": len(chunks),
        "decisions": doc_decisions,
        "positions": doc_positions,
        "open_items": doc_open_items,
        "error": None,
    }


# ── Entry point ────────────────────────────────────────────────────────────

def main():
    parser = argparse.ArgumentParser(description="Enriquecimiento AI de capa estratégica bank-brain")
    parser.add_argument("--dry-run", action="store_true", help="No llama API, solo muestra chunks")
    parser.add_argument("--model", choices=["haiku", "sonnet"], default=DEFAULT_MODEL)
    parser.add_argument("--reset", action="store_true", help="Reprocesa todos los docs (borra enrichment_log)")
    parser.add_argument("--doc", type=str, default=None, help="Procesa solo este filename")
    args = parser.parse_args()

    # ── API key ──────────────────────────────────────────────────────────
    if not args.dry_run:
        api_key = os.environ.get("ANTHROPIC_API_KEY", "")
        if not api_key:
            print("ERROR: ANTHROPIC_API_KEY no está configurada.")
            print("  export ANTHROPIC_API_KEY=sk-ant-...")
            sys.exit(1)
        import anthropic
        client = anthropic.Anthropic(api_key=api_key)
    else:
        client = None

    model_id = MODELS[args.model]
    print(f"=== enrich-strategic.py ===")
    print(f"  Modelo   : {model_id}")
    print(f"  Dry-run  : {args.dry_run}")
    print(f"  brain.db : {BRAIN_DB}")
    print(f"  Minutas  : {MINUTAS}")

    assert BRAIN_DB.exists(), f"No existe {BRAIN_DB}. Ejecuta build-bank-brain.py primero."

    db = sqlite3.connect(str(BRAIN_DB))
    db.execute("PRAGMA foreign_keys=ON")
    db.executescript(TRACKING_DDL)
    db.commit()

    if args.reset and not args.dry_run:
        db.execute("DELETE FROM enrichment_log")
        db.execute("DELETE FROM decisions  WHERE id LIKE 'AI-%'")
        db.execute("DELETE FROM positions  WHERE quote NOT LIKE '% indicó %'")  # AI positions no tienen quote real
        db.execute("DELETE FROM open_items WHERE id LIKE 'AI-%'")
        db.commit()
        print("  Reset: enrichment_log y entradas AI- borrados")

    # ── Docs a procesar ──────────────────────────────────────────────────
    if args.doc:
        docs = db.execute(
            "SELECT id, date, filename FROM documents WHERE type='minuta' AND filename=?",
            (args.doc,),
        ).fetchall()
    else:
        already_done = {
            r[0] for r in db.execute("SELECT doc_id FROM enrichment_log WHERE error IS NULL").fetchall()
        }
        docs = [
            r for r in db.execute(
                "SELECT id, date, filename FROM documents WHERE type='minuta' ORDER BY date"
            ).fetchall()
            if r[0] not in already_done
        ]

    print(f"\n  Documentos pendientes: {len(docs)}")
    if not docs:
        print("  Nada que procesar. Usa --reset para reprocesar todo.")
        db.close()
        return

    # ── Dedup global: cargar lo que ya existe en DB ──────────────────────
    seen_decisions: set[str]   = set()
    seen_positions: set[tuple] = set()
    seen_open_items: set[str]  = set()

    for (text,) in db.execute("SELECT decision FROM decisions"):
        seen_decisions.add(dedup_key_decision(text or ""))
    for (sid, stance) in db.execute("SELECT stakeholder_id, stance FROM positions"):
        seen_positions.add(dedup_key_pos(sid or "", stance or ""))
    for (text,) in db.execute("SELECT item FROM open_items"):
        seen_open_items.add(dedup_key_oi(text or ""))

    # Contadores para IDs secuenciales AI-
    max_dec = db.execute(
        "SELECT MAX(CAST(SUBSTR(id, 8) AS INTEGER)) FROM decisions WHERE id LIKE 'AI-DEC-%'"
    ).fetchone()[0] or 0
    max_oi = db.execute(
        "SELECT MAX(CAST(SUBSTR(id, 7) AS INTEGER)) FROM open_items WHERE id LIKE 'AI-OI-%'"
    ).fetchone()[0] or 0
    counters = {"dec": max_dec, "oi": max_oi}

    # ── Procesar docs ────────────────────────────────────────────────────
    total = {"chunks": 0, "decisions": 0, "positions": 0, "open_items": 0}
    import datetime

    for doc_id, doc_date, filename in docs:
        path = MINUTAS / filename
        if not path.exists():
            print(f"\n  [{doc_id:>3}] SKIP (no encontrado): {filename}")
            continue

        result = process_doc(
            db, client, model_id,
            doc_id, doc_date, filename, path,
            args.dry_run,
            seen_decisions, seen_positions, seen_open_items,
            counters,
        )

        if not args.dry_run:
            db.execute(
                """INSERT OR REPLACE INTO enrichment_log
                   (doc_id, filename, chunks, decisions, positions, open_items, model, processed_at, error)
                   VALUES (?,?,?,?,?,?,?,?,?)""",
                (
                    doc_id, filename,
                    result["chunks"], result["decisions"],
                    result["positions"], result["open_items"],
                    model_id,
                    datetime.datetime.now().isoformat(),
                    result.get("error"),
                ),
            )
            db.commit()

        for k in total:
            total[k] += result.get(k, 0)

    # ── Resumen ──────────────────────────────────────────────────────────
    print()
    print("=== RESULTADO ENRIQUECIMIENTO AI ===")
    print(f"  Chunks procesados : {total['chunks']}")
    print(f"  Decisiones nuevas : {total['decisions']}")
    print(f"  Posiciones nuevas : {total['positions']}")
    print(f"  Open items nuevos : {total['open_items']}")
    print()

    print("--- Totales en bank-brain.db ---")
    for table in ["stakeholders", "decisions", "positions", "open_items"]:
        n, = db.execute(f"SELECT COUNT(*) FROM {table}").fetchone()
        print(f"  {table:<15}: {n:>5}")

    if not args.dry_run:
        print()
        n_log, = db.execute("SELECT COUNT(*) FROM enrichment_log WHERE error IS NULL").fetchone()
        print(f"  Minutas procesadas en enrichment_log: {n_log}")

    db.close()
    print()
    print("Listo.")


if __name__ == "__main__":
    main()
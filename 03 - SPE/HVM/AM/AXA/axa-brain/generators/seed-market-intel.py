"""
seed-market-intel.py
Lee los 4 archivos MD del DT de Inteligencia de Mercado y carga cada sección H2
como un registro en la tabla market_intel de axa-brain.db.

Archivos fuente (dt/dt-inteligencia-mercado/):
  market-intelligence.md   → category: posicion
  financial-results.md     → category: financiero
  competitive-landscape.md → category: competitivo
  regulatory-signals.md    → category: regulatorio

Ejecutar desde: AXA/axa-brain/
    python generators/seed-market-intel.py
"""

import sqlite3
import os
import re
from datetime import datetime

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DB_PATH  = os.path.join(BASE_DIR, "axa-brain.db")
DT_DIR   = os.path.join(BASE_DIR, "dt", "dt-inteligencia-mercado")

# Mapeo archivo → categoría
FILES = [
    ("market-intelligence.md",  "posicion"),
    ("financial-results.md",    "financiero"),
    ("competitive-landscape.md","competitivo"),
    ("regulatory-signals.md",   "regulatorio"),
]


def ensure_table(conn: sqlite3.Connection) -> None:
    conn.executescript("""
        CREATE TABLE IF NOT EXISTS market_intel (
            id          INTEGER PRIMARY KEY AUTOINCREMENT,
            category    TEXT,
            date        TEXT,
            title       TEXT,
            body        TEXT,
            source      TEXT,
            maturity    TEXT DEFAULT 'HOY'
        );
        CREATE INDEX IF NOT EXISTS idx_mi_category ON market_intel(category);
        CREATE INDEX IF NOT EXISTS idx_mi_date     ON market_intel(date);
    """)
    conn.commit()


def extract_date(text: str) -> str:
    """Busca 'Última actualización: YYYY-MM-DD' o similar en el texto."""
    m = re.search(r'(\d{4}-\d{2}-\d{2})', text)
    if m:
        return m.group(1)
    return datetime.now().strftime("%Y-%m-%d")


def extract_source(text: str) -> str:
    """Extrae la primera línea con 'Fuentes:' o similar."""
    for line in text.splitlines():
        if "fuente" in line.lower() or "source" in line.lower():
            clean = re.sub(r'^[>\s#*]+', '', line).strip()
            if clean:
                return clean[:300]
    return "dt-inteligencia-mercado"


def split_by_h2(content: str) -> list[tuple[str, str]]:
    """
    Parte el contenido por encabezados H2 (## Título).
    Devuelve lista de (título, cuerpo).
    Descarta el bloque antes del primer H2 (metadata/frontmatter).
    """
    sections = []
    parts = re.split(r'\n(?=## )', content)
    for part in parts:
        part = part.strip()
        if not part.startswith('## '):
            continue
        lines = part.splitlines()
        title = lines[0].lstrip('# ').strip()
        body  = '\n'.join(lines[1:]).strip()
        if title and body:
            sections.append((title, body))
    return sections


def load_file(conn: sqlite3.Connection, filepath: str, category: str) -> int:
    if not os.path.exists(filepath):
        print(f"  [SKIP] No existe: {filepath}")
        return 0

    content = open(filepath, encoding="utf-8").read()
    date    = extract_date(content)
    source  = extract_source(content)
    sections = split_by_h2(content)

    if not sections:
        # Si no hay H2, cargar el documento completo como un solo registro
        conn.execute("""
            INSERT INTO market_intel (category, date, title, body, source, maturity)
            VALUES (?, ?, ?, ?, ?, 'HOY')
        """, (category, date, os.path.basename(filepath), content[:4000], source))
        conn.commit()
        return 1

    inserted = 0
    for title, body in sections:
        conn.execute("""
            INSERT INTO market_intel (category, date, title, body, source, maturity)
            VALUES (?, ?, ?, ?, ?, 'HOY')
        """, (category, date, title, body[:4000], source))
        inserted += 1

    conn.commit()
    return inserted


def print_summary(conn: sqlite3.Connection) -> None:
    print("\n[RESUMEN MARKET INTEL]")
    rows = conn.execute("""
        SELECT category, COUNT(*) n
        FROM market_intel
        GROUP BY category
        ORDER BY category
    """).fetchall()
    total = 0
    for cat, n in rows:
        print(f"  {cat:<16} {n:3d} registros")
        total += n
    print(f"  {'TOTAL':<16} {total:3d} registros")


def main() -> None:
    if not os.path.exists(DB_PATH):
        print(f"[ERROR] axa-brain.db no encontrado en {DB_PATH}")
        print("        Ejecuta build-axa-brain.py primero.")
        return

    conn = sqlite3.connect(DB_PATH)
    ensure_table(conn)

    # Limpiar registros previos para idempotencia
    conn.execute("DELETE FROM market_intel")
    conn.commit()

    total = 0
    for filename, category in FILES:
        filepath = os.path.join(DT_DIR, filename)
        n = load_file(conn, filepath, category)
        print(f"[OK] {filename:<35} → {category:<12} {n} secciones")
        total += n

    print(f"\n[TOTAL] {total} registros de inteligencia de mercado → {DB_PATH}")
    print_summary(conn)
    conn.close()


if __name__ == "__main__":
    main()
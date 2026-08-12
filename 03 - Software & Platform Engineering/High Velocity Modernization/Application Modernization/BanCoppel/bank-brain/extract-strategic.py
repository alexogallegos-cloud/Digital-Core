"""
extract-strategic.py — Capa de Inteligencia Estratégica del Bank Brain
Lee las 56 minutas Plan Director y extrae:
  - stakeholders: actores clave con rol, organización y nivel de influencia
  - decisions:    decisiones estratégicas atribuidas y fechadas
  - positions:    posturas individuales sobre temas clave
  - open_items:   pendientes estratégicos con dueño y plazo

Escribe directamente a bank-brain.db (no requiere API externa).
"""

import sqlite3, re, json
from pathlib import Path
from collections import defaultdict

# ── Rutas ──────────────────────────────────────────────────────────────────
BASE      = Path(__file__).parent.parent
BRAIN_DB  = Path(__file__).parent / "bank-brain.db"
MINUTAS   = BASE / "BCOPCore/source/minutas/pd"

assert BRAIN_DB.exists(), "Ejecuta build-bank-brain.py primero"

# ── Stakeholders pre-seed (conocimiento previo de las minutas) ─────────────
KNOWN_STAKEHOLDERS = [
    # id,                    name,                      role,                              org,         level,      area,               influence
    ("juan-manuel",          "Juan Manuel Fernández Islas", "IT Corporate Director FFSS", "grupo-coppel", "c-level", "IT / Financial Services (FFSS)", "sponsor"),
    ("daniel-angeles",       "Daniel Ángeles Baltazar", "Subdirector de Infraestructura",  "bancoppel",  "director", "Infraestructura",  "decision-maker"),
    ("arturo-perez",         "Arturo Pérez",            "Líder Legacy / PISA",             "bancoppel",  "manager",  "Tecnología Legacy","contributor"),
    ("erica-mata",           "Erica Mata",              "CISO / Head OSI",                 "bancoppel",  "director", "Seguridad",        "decision-maker"),
    ("arcadio",              "Arcadio Delgado",         "Enterprise Architect FFSS",       "bancoppel",  "manager",  "Arquitectura Empresarial / FFSS", "decision-maker"),
    ("carlos-bc",            "Carlos",                  "Ejecutivo / Steering BCP",        "bancoppel",  "c-level",  "Dirección",        "sponsor"),
    ("brenda",               "Brenda",                  "Gestión Proveedores FS Tech",     "bancoppel",  "manager",  "Operaciones",      "contributor"),
    ("rodrigo",              "Rodrigo",                 "Estrategia / Assessment Unity",   "bancoppel",  "manager",  "Estrategia",       "contributor"),
    ("pablo-lorenzo",        "Pablo Lorenzo Diaz",      "Consultor Senior / Global Expert ACN", "accenture", "manager",  "Delivery",         "decision-maker"),
    ("lukasz-pietrzyk",      "Lukasz Pietrzyk",         "Consultor Senior / Global Architect ACN", "accenture", "manager", "Arquitectura", "contributor"),
    ("alejandro-gallegos",   "Alejandro Gallegos",      "Lead ACN BanCoppel",              "accenture",  "manager",  "Delivery",         "contributor"),
    ("gabriela-maximiliano", "Gabriela Maximiliano",    "ACN Delivery",                    "accenture",  "manager",  "Delivery",         "contributor"),
    ("karina-zepeda",        "Karina Zepeda",           "ACN Delivery / Legacy liaison",   "accenture",  "manager",  "Delivery",         "contributor"),
    ("salomon-monroy",       "Salomon Monroy",          "ACN Delivery",                    "accenture",  "manager",  "Delivery",         "contributor"),
    ("luis-barragan",        "Luis Alberto Barragán Mejía", "Subdirector de Tecnología de Canales", "bancoppel", "director", "Tecnología de Canales", "decision-maker"),
    ("emmy",                 "Emmy",                    "Apoyo de Negocio Unity",          "bancoppel",  "manager",  "Negocio",          "contributor"),
]

# Aliases para normalización de nombres en texto libre
NAME_ALIASES: dict[str, str] = {
    "juan manuel fernández islas": "juan-manuel",
    "juan manuel fernandez islas": "juan-manuel",
    "fernández islas": "juan-manuel",
    "fernandez islas": "juan-manuel",
    "juan manuel": "juan-manuel",
    "juanmanuel":  "juan-manuel",
    "daniel":      "daniel-angeles",
    "daniel ángeles baltazar": "daniel-angeles",
    "daniel angeles baltazar": "daniel-angeles",
    "ángeles baltazar": "daniel-angeles",
    "angeles baltazar": "daniel-angeles",
    "daniel ángeles": "daniel-angeles",
    "daniel angeles": "daniel-angeles",
    "arturo":      "arturo-perez",
    "arturo pérez": "arturo-perez",
    "arturo perez": "arturo-perez",
    "erica":       "erica-mata",
    "erika":       "erica-mata",
    "erica mata":  "erica-mata",
    "erika mata":  "erica-mata",
    "arcadio delgado": "arcadio",
    "arcadio":     "arcadio",
    "carlos":      "carlos-bc",
    "brenda":      "brenda",
    "rodrigo":     "rodrigo",
    "pablo":       "pablo-lorenzo",
    "pablo lorenzo": "pablo-lorenzo",
    "pav":         "pablo-lorenzo",   # aparece así en transcripciones
    "pavl":        "pablo-lorenzo",
    "lukasz":      "lukasz-pietrzyk",
    "alejandro gallegos": "alejandro-gallegos",
    "gabriela":    "gabriela-maximiliano",
    "gabriela maximiliano": "gabriela-maximiliano",
    "karina":      "karina-zepeda",
    "salomon":     "salomon-monroy",
    "luis alberto barragán mejía": "luis-barragan",
    "luis alberto barragan mejia": "luis-barragan",
    "barragán mejía": "luis-barragan",
    "barragan mejia": "luis-barragan",
    "luis barragán": "luis-barragan",
    "luis barragan": "luis-barragan",
    "emmy":        "emmy",
    "emmys":       "emmy",
}

# ── Patrones de extracción ─────────────────────────────────────────────────
# Frases que introducen decisiones estratégicas
DECISION_PATTERNS = [
    r"[Ss]e acordó que (.{20,300}?)(?:\.|$)",
    r"[Ss]e decidió que (.{20,300}?)(?:\.|$)",
    r"[Ss]e concluyó que (.{20,300}?)(?:\.|$)",
    r"[Ss]e confirmó que (.{20,300}?)(?:\.|$)",
    r"[Ss]e definió que (.{20,300}?)(?:\.|$)",
    r"[Ss]e estableció que (.{20,300}?)(?:\.|$)",
    r"[Ss]e aprobó (.{20,300}?)(?:\.|$)",
    r"[Qq]uedó acordado (.{20,300}?)(?:\.|$)",
    r"[Ll]a conclusión (?:fue|es) que (.{20,300}?)(?:\.|$)",
    r"[Ss]e resolvió que (.{20,300}?)(?:\.|$)",
]

# Frases de atribución (persona + verbo + contenido)
ATTRIBUTION_VERBS = [
    "indicó que", "señaló que", "confirmó que", "explicó que", "comentó que",
    "mencionó que", "destacó que", "afirmó que", "aclaró que", "subrayó que",
    "insistió en que", "reconoció que", "advirtió que", "alertó que",
    "propuso que", "sugirió que", "recomendó que", "concluyó que",
    "preguntó", "respondió que", "añadió que", "agregó que",
    "informó que", "reportó que", "planteó que", "consideró que",
]

# Patrones de ítems abiertos / pendientes
OPEN_ITEM_PATTERNS = [
    r"[Pp]endiente[:\s]+(.{15,250}?)(?:\.|$)",
    r"[Pp]or definir[:\s]+(.{15,250}?)(?:\.|$)",
    r"[Cc]ompromiso[:\s]+(.{15,250}?)(?:\.|$)",
    r"[Aa]ction item[:\s]+(.{15,250}?)(?:\.|$)",
    r"[Aa]cción[:\s]+(.{15,250}?)(?:\.|$)",
    r"[Ss]e deberá (.{15,250}?)(?:\.|$)",
    r"[Ss]e necesita (.{15,250}?)(?:\.|$)",
    r"[Ee]s necesario (.{15,250}?)(?:\.|$)",
    r"[Ff]alta (?:por |definir )?(.{15,250}?)(?:\.|$)",
    r"[Ss]e requiere (.{15,250}?)(?:\.|$)",
]

# Sistemas para detección de topic de decisiones y posiciones
TOPIC_KEYWORDS = {
    "apolo":        r"\bapolo\b",
    "smartvista":   r"\bsmartvista\b|\bbpc\b",
    "transact":     r"\btransact\b",
    "atlas":        r"\batlas\b",
    "pisa":         r"\bpisa\b|\blegacy\b|\binformix\b",
    "arquitectura": r"\barquitectura\b|\barch\b",
    "seguridad":    r"\bseguridad\b|\bciso\b|\bosi\b",
    "gobierno":     r"\bgobierno\b|\bgovernance\b|\bsteering\b",
    "cronograma":   r"\bcronograma\b|\btimeline\b|\bplazo\b|\bfecha\b",
    "datos":        r"\bdatos\b|\bmigraci[oó]n\b|\bdata\b",
    "integracion":  r"\bintegraci[oó]n\b|\bapi\b|\bmulesoft\b",
    "testing":      r"\btesting\b|\bpruebas\b|\bqa\b",
    "regulatorio":  r"\bcnbv\b|\bregulat\b|\bcompliance\b",
}

SENTIMENT_PATTERNS = {
    "concerned": [
        r"\briesgo\b", r"\bproblema\b", r"\batraso\b", r"\bretraso\b",
        r"\bpreocupa\b", r"\bdifícil\b", r"\bcomplejo\b", r"\bincertidumbre\b",
        r"\bfalta\b", r"\bno\s+est[aá]\b",
    ],
    "supportive": [
        r"\bacuerdo\b", r"\bcorrecto\b", r"\bexcelente\b", r"\bbien\b",
        r"\bapoya\b", r"\bcoincidió\b", r"\bconfirm\b", r"\baprueba\b",
    ],
    "blocking": [
        r"\bbloqueante\b", r"\bbloquea\b", r"\bimpide\b", r"\bno puede\b",
        r"\brechaza\b", r"\bno procede\b",
    ],
}


# ── Helpers ────────────────────────────────────────────────────────────────
def normalize_name(text: str) -> str | None:
    """Devuelve el ID del stakeholder si el texto contiene un nombre conocido."""
    t = text.lower().strip()
    for alias, sid in NAME_ALIASES.items():
        if alias in t:
            return sid
    return None


def detect_topics(text: str) -> list[str]:
    t = text.lower()
    return [k for k, pat in TOPIC_KEYWORDS.items() if re.search(pat, t)]


def detect_sentiment(text: str) -> str:
    t = text.lower()
    for sent, patterns in SENTIMENT_PATTERNS.items():
        if any(re.search(p, t) for p in patterns):
            return sent
    return "neutral"


def extract_participants(paragraphs: list[str]) -> list[str]:
    """Extrae nombres de secciones 'Participantes'."""
    names = []
    in_section = False
    for p in paragraphs:
        pl = p.lower()
        # Detectar cabecera de sección
        if re.search(r"participantes?\s*(bcp|acn|:)?", pl):
            in_section = True
            continue
        # Salir de sección si llega otro encabezado
        if in_section and re.match(r"^\d+[\.\)]\s|^minuta:|^fecha\s|^lugar\s|^sesión\s|^objetivo", pl):
            in_section = False
        if in_section and 3 < len(p) < 80:
            # Limpiar paréntesis "(Se une más tarde)" etc.
            name = re.sub(r"\(.*?\)", "", p).strip()
            if name:
                names.append(name)
    return names


def extract_decisions(paragraphs: list[str], doc_id: int, date: str | None) -> list[dict]:
    """Extrae decisiones de los párrafos."""
    decisions = []
    full_text = " ".join(paragraphs)
    for pat in DECISION_PATTERNS:
        for m in re.finditer(pat, full_text, re.IGNORECASE):
            decision_text = m.group(1).strip()
            if len(decision_text) < 15:
                continue
            # Buscar quién la impulsó en el contexto circundante (±100 chars)
            start = max(0, m.start() - 150)
            context = full_text[start: m.start()]
            driver = normalize_name(context)
            decisions.append({
                "topic": detect_topics(decision_text) or ["general"],
                "decision": decision_text,
                "driver_id": driver,
                "date": date,
                "doc_id": doc_id,
                "confidence": "high" if "acordó" in m.group(0).lower() else "medium",
            })
    return decisions


def extract_positions(paragraphs: list[str], doc_id: int, date: str | None) -> list[dict]:
    """Extrae posturas atribuidas a personas conocidas."""
    positions = []
    for p in paragraphs:
        for verb in ATTRIBUTION_VERBS:
            pattern = rf"(\b[A-ZÁÉÍÓÚÑ][a-záéíóúñ]+(?:\s+[A-ZÁÉÍÓÚÑ][a-záéíóúñ]+)?)\s+{re.escape(verb)}\s+(.{{15,300}}?)(?:\.|$)"
            for m in re.finditer(pattern, p):
                person_raw = m.group(1)
                statement = m.group(2).strip()
                sid = normalize_name(person_raw)
                if not sid:
                    continue
                topics = detect_topics(statement)
                if not topics:
                    topics = detect_topics(p)
                positions.append({
                    "stakeholder_id": sid,
                    "topic": topics[0] if topics else "general",
                    "stance": statement[:500],
                    "quote": p[:300],
                    "date": date,
                    "doc_id": doc_id,
                    "sentiment": detect_sentiment(statement),
                })
    return positions


def extract_open_items(paragraphs: list[str], doc_id: int, date: str | None) -> list[dict]:
    """Extrae ítems abiertos / pendientes."""
    items = []
    full_text = " ".join(paragraphs)
    for pat in OPEN_ITEM_PATTERNS:
        for m in re.finditer(pat, full_text, re.IGNORECASE):
            item_text = m.group(1).strip()
            if len(item_text) < 10:
                continue
            # Buscar dueño en contexto
            start = max(0, m.start() - 200)
            context = full_text[start: m.start() + 100]
            owner = normalize_name(context)
            topics = detect_topics(item_text)
            items.append({
                "item": item_text[:400],
                "owner_id": owner,
                "date": date,
                "doc_id": doc_id,
                "priority": "high" if re.search(r"\bcrítico\b|\burgente\b|\bbloqueante\b", item_text, re.I) else "medium",
                "systems": topics,
                "status": "open",
            })
    return items


# ── DDL estratégico ────────────────────────────────────────────────────────
STRATEGIC_DDL = """
CREATE TABLE IF NOT EXISTS stakeholders (
    id               TEXT PRIMARY KEY,
    name             TEXT NOT NULL,
    role             TEXT,
    org              TEXT,     -- bancoppel | accenture | otro
    level            TEXT,     -- c-level | director | manager | technical
    area             TEXT,
    influence        TEXT,     -- sponsor | decision-maker | contributor | observer
    first_seen       TEXT,
    last_seen        TEXT,
    appearance_count INTEGER DEFAULT 0,
    notes            TEXT
);

CREATE TABLE IF NOT EXISTS decisions (
    id          TEXT PRIMARY KEY,
    date        TEXT,
    topic       TEXT,
    decision    TEXT NOT NULL,
    context     TEXT,
    driver_id   TEXT REFERENCES stakeholders(id),
    systems     TEXT,  -- JSON
    doc_id      INTEGER REFERENCES documents(id),
    confidence  TEXT DEFAULT 'medium'
);

CREATE TABLE IF NOT EXISTS positions (
    id               INTEGER PRIMARY KEY AUTOINCREMENT,
    stakeholder_id   TEXT REFERENCES stakeholders(id),
    topic            TEXT,
    stance           TEXT NOT NULL,
    quote            TEXT,
    date             TEXT,
    doc_id           INTEGER REFERENCES documents(id),
    sentiment        TEXT DEFAULT 'neutral'
);

CREATE TABLE IF NOT EXISTS open_items (
    id          TEXT PRIMARY KEY,
    date        TEXT,
    item        TEXT NOT NULL,
    owner_id    TEXT REFERENCES stakeholders(id),
    deadline    TEXT,
    status      TEXT DEFAULT 'open',
    priority    TEXT DEFAULT 'medium',
    systems     TEXT,  -- JSON
    doc_id      INTEGER REFERENCES documents(id),
    resolution  TEXT
);

CREATE INDEX IF NOT EXISTS idx_pos_sh    ON positions(stakeholder_id);
CREATE INDEX IF NOT EXISTS idx_pos_topic ON positions(topic);
CREATE INDEX IF NOT EXISTS idx_dec_date  ON decisions(date);
CREATE INDEX IF NOT EXISTS idx_oi_owner  ON open_items(owner_id);
CREATE INDEX IF NOT EXISTS idx_oi_status ON open_items(status);

-- Posturas solo de actores cliente (BanCoppel / Grupo Coppel)
-- Excluye proveedores (Accenture, AWS, etc.) para no contaminar la voz del cliente
CREATE VIEW IF NOT EXISTS client_positions AS
    SELECT p.*, s.name AS stakeholder_name, s.org, s.level, s.role
    FROM positions p
    JOIN stakeholders s ON s.id = p.stakeholder_id
    WHERE s.org IN ('bancoppel', 'grupo-coppel');

-- Posturas de proveedores (Accenture, AWS, etc.) — análisis y recomendaciones externas
CREATE VIEW IF NOT EXISTS vendor_positions AS
    SELECT p.*, s.name AS stakeholder_name, s.org, s.level, s.role
    FROM positions p
    JOIN stakeholders s ON s.id = p.stakeholder_id
    WHERE s.org NOT IN ('bancoppel', 'grupo-coppel');

-- Decisiones conducidas por actores cliente (o sin atribución)
CREATE VIEW IF NOT EXISTS client_decisions AS
    SELECT d.*, s.name AS driver_name, s.org
    FROM decisions d
    LEFT JOIN stakeholders s ON s.id = d.driver_id
    WHERE s.org IN ('bancoppel', 'grupo-coppel') OR d.driver_id IS NULL;

CREATE VIEW IF NOT EXISTS stakeholder_activity AS
    SELECT
        s.id, s.name, s.org, s.level, s.influence,
        COUNT(DISTINCT p.id)  AS position_count,
        COUNT(DISTINCT d.id)  AS decision_count,
        COUNT(DISTINCT oi.id) AS open_item_count,
        s.appearance_count
    FROM stakeholders s
    LEFT JOIN positions  p  ON p.stakeholder_id = s.id
    LEFT JOIN decisions  d  ON d.driver_id = s.id
    LEFT JOIN open_items oi ON oi.owner_id = s.id
    GROUP BY s.id
    ORDER BY decision_count DESC, position_count DESC;
"""


def run():
    import docx as python_docx

    db = sqlite3.connect(str(BRAIN_DB))
    db.execute("PRAGMA foreign_keys=ON")
    db.executescript(STRATEGIC_DDL)
    db.commit()
    print("DDL estratégico aplicado")

    # Limpiar extracción previa (idempotente)
    db.execute("DELETE FROM positions")
    db.execute("DELETE FROM open_items WHERE id LIKE 'OI-%'")
    db.execute("DELETE FROM decisions WHERE id LIKE 'DEC-%'")
    db.commit()

    # ── Pre-seed stakeholders ─────────────────────────────────────────────
    db.executemany(
        """INSERT OR IGNORE INTO stakeholders
           (id, name, role, org, level, area, influence)
           VALUES (?,?,?,?,?,?,?)""",
        [(s[0], s[1], s[2], s[3], s[4], s[5], s[6]) for s in KNOWN_STAKEHOLDERS],
    )
    db.commit()
    print(f"Stakeholders pre-seed: {len(KNOWN_STAKEHOLDERS)}")

    # ── Leer documentos indexados ─────────────────────────────────────────
    docs = db.execute(
        "SELECT id, date, filename FROM documents WHERE type = 'minuta' ORDER BY date"
    ).fetchall()

    # Contadores para IDs secuenciales
    dec_n  = 0
    oi_n   = 0
    sh_appearances: dict[str, list[str]] = defaultdict(list)  # id → fechas

    all_decisions: list[dict] = []
    all_positions: list[dict] = []
    all_open_items: list[dict] = []

    print(f"\nProcesando {len(docs)} minutas...")
    for doc_id, date, filename in docs:
        path = MINUTAS / filename
        if not path.exists():
            print(f"  SKIP: {filename}")
            continue
        try:
            doc = python_docx.Document(str(path))
            paragraphs = [p.text.strip() for p in doc.paragraphs if p.text.strip()]
        except Exception as e:
            print(f"  ERROR: {filename} — {e}")
            continue

        # 1. Participantes → stakeholder appearances
        names = extract_participants(paragraphs)
        for name in names:
            sid = normalize_name(name)
            if sid and date:
                sh_appearances[sid].append(date)
            elif sid:
                sh_appearances[sid]  # touch to register

        # También detectar nombres en cualquier parte del texto
        full = " ".join(paragraphs)
        for alias, sid in NAME_ALIASES.items():
            if alias in full.lower():
                if date:
                    sh_appearances[sid].append(date)

        # 2. Decisiones
        decs = extract_decisions(paragraphs, doc_id, date)
        all_decisions.extend(decs)

        # 3. Posiciones
        pos = extract_positions(paragraphs, doc_id, date)
        all_positions.extend(pos)

        # 4. Open items
        ois = extract_open_items(paragraphs, doc_id, date)
        all_open_items.extend(ois)

    # ── Actualizar apariciones en stakeholders ────────────────────────────
    for sid, dates in sh_appearances.items():
        if not dates:
            continue
        dates_sorted = sorted(set(dates))
        db.execute(
            """UPDATE stakeholders
               SET appearance_count = ?, first_seen = ?, last_seen = ?
               WHERE id = ?""",
            (len(dates_sorted), dates_sorted[0], dates_sorted[-1], sid),
        )

    # ── Insertar decisiones (dedup por texto) ─────────────────────────────
    seen_decisions: set[str] = set()
    for d in all_decisions:
        key = d["decision"][:80]
        if key in seen_decisions:
            continue
        seen_decisions.add(key)
        dec_n += 1
        dec_id = f"DEC-{dec_n:04d}"
        db.execute(
            """INSERT OR IGNORE INTO decisions
               (id, date, topic, decision, driver_id, systems, doc_id, confidence)
               VALUES (?,?,?,?,?,?,?,?)""",
            (
                dec_id, d["date"],
                d["topic"][0] if d["topic"] else "general",
                d["decision"][:500],
                d["driver_id"],
                json.dumps(d["topic"], ensure_ascii=False),
                d["doc_id"],
                d["confidence"],
            ),
        )

    # ── Insertar posiciones ───────────────────────────────────────────────
    seen_positions: set[str] = set()
    for p in all_positions:
        key = (p["stakeholder_id"], p["stance"][:60])
        if key in seen_positions:
            continue
        seen_positions.add(key)
        db.execute(
            """INSERT INTO positions
               (stakeholder_id, topic, stance, quote, date, doc_id, sentiment)
               VALUES (?,?,?,?,?,?,?)""",
            (
                p["stakeholder_id"], p["topic"],
                p["stance"], p["quote"],
                p["date"], p["doc_id"], p["sentiment"],
            ),
        )

    # ── Insertar open items (dedup) ───────────────────────────────────────
    seen_items: set[str] = set()
    for oi in all_open_items:
        key = oi["item"][:60]
        if key in seen_items:
            continue
        seen_items.add(key)
        oi_n += 1
        oi_id = f"OI-{oi_n:04d}"
        db.execute(
            """INSERT OR IGNORE INTO open_items
               (id, date, item, owner_id, priority, systems, doc_id, status)
               VALUES (?,?,?,?,?,?,?,?)""",
            (
                oi_id, oi["date"], oi["item"][:400],
                oi["owner_id"], oi["priority"],
                json.dumps(oi["systems"], ensure_ascii=False),
                oi["doc_id"], oi["status"],
            ),
        )

    db.commit()

    # ── Resumen ───────────────────────────────────────────────────────────
    print()
    print("=== CAPA ESTRATÉGICA ===")
    for table in ["stakeholders", "decisions", "positions", "open_items"]:
        n, = db.execute(f"SELECT COUNT(*) FROM {table}").fetchone()
        print(f"  {table:<15}: {n:>5}")

    print()
    print("--- Stakeholder activity ---")
    rows = db.execute("""
        SELECT s.name, s.org, s.level, s.influence,
               s.appearance_count,
               COUNT(DISTINCT p.id) pos,
               COUNT(DISTINCT d.id) dec
        FROM stakeholders s
        LEFT JOIN positions p ON p.stakeholder_id = s.id
        LEFT JOIN decisions d ON d.driver_id = s.id
        GROUP BY s.id
        ORDER BY s.appearance_count DESC
    """).fetchall()
    for r in rows:
        name, org, level, inf, app, pos, dec = r
        print(f"  {name:<30} {org:<12} {level:<12} {inf:<16} {app:>3} aparic | {pos:>3} pos | {dec:>3} dec")

    print()
    print("--- Top decisiones ---")
    for r in db.execute(
        "SELECT id, date, topic, decision FROM decisions ORDER BY date LIMIT 10"
    ):
        print(f"  [{r[0]}] {r[1] or '?':12} [{r[2]:<14}] {r[3][:80]}")

    print()
    print("--- Open items abiertos ---")
    n_open, = db.execute("SELECT COUNT(*) FROM open_items WHERE status = 'open'").fetchone()
    n_high, = db.execute("SELECT COUNT(*) FROM open_items WHERE status = 'open' AND priority = 'high'").fetchone()
    print(f"  Total open: {n_open} | High priority: {n_high}")

    db.close()
    print("\nCapa estratégica lista en bank-brain.db")


if __name__ == "__main__":
    run()

#!/usr/bin/env python3
"""
build-cap-data.py
Genera portal/capabilities.json desde cap-*.md + rules-catalog/*.md.
Cadena de trazabilidad: Capacidad -> Tareas -> Reglas -> Programa -> Detalle.
"""
import re, os, json, glob
from datetime import date

BASE      = os.path.dirname(os.path.abspath(__file__))
CAPS_DIR  = os.path.join(BASE, "capacidades")
RULES_DIR = os.path.join(BASE, "rules-catalog")
OUT_PATH  = os.path.join(BASE, "portal", "capabilities.json")

# ── Mapa de capacidades cubiertas ────────────────────────────────────────────
# cap_id -> {name, domain, sistema, cls, cap_file, slug}
CAP_MAP = {
    "2.1.1":  dict(name="Teller",                           domain="2 · Channels",                       sistema="S500",       cls="s500",  cap_file="cap-tel.md", slug="TEL"),
    "2.2.6":  dict(name="ATM",                              domain="2 · Channels",                       sistema="S500",       cls="s500",  cap_file="cap-tar.md", slug="TAR"),
    "2.2.7":  dict(name="PoS",                              domain="2 · Channels",                       sistema="S500",       cls="s500",  cap_file="cap-tar.md", slug="TAR"),
    "4.1.2":  dict(name="Holdings",                         domain="4 · Common Customer View",           sistema="S151",       cls="s151",  cap_file="cap-hld.md", slug="HLD"),
    "5.1.1":  dict(name="Deposits",                         domain="5 · Product Processing",             sistema="S500",       cls="s500",  cap_file="cap-dep.md", slug="DEP"),
    "6.1.3":  dict(name="Payments",                         domain="6 · Common Services",                sistema="S500",       cls="s500",  cap_file="cap-pay.md", slug="PAY"),
    "6.1.4":  dict(name="Statements",                       domain="6 · Common Services",                sistema="S500",       cls="s500",  cap_file="cap-sta.md", slug="STA"),
    "6.1.5":  dict(name="Interest & Fees",                  domain="6 · Common Services",                sistema="S500",       cls="s500",  cap_file="cap-int.md", slug="INT"),
    "6.5.2":  dict(name="Compliance & Regulation",          domain="6 · Common Services",                sistema="S500+S151",  cls="ambos", cap_file="cap-cmp.md", slug="CMP"),
    "6.6.1":  dict(name="Financial Servicing",              domain="6 · Common Services",                sistema="S500",       cls="s500",  cap_file="cap-int.md", slug="FSV"),
    "6.7.1":  dict(name="Financial Reconciliation",         domain="6 · Common Services",                sistema="S151",       cls="s151",  cap_file="cap-rec.md", slug="REC"),
    "6.7.2":  dict(name="Operational Reconciliation",       domain="6 · Common Services",                sistema="S500+S151",  cls="ambos", cap_file="cap-orc.md", slug="ORC"),
    "7.1.1":  dict(name="Finance (GL)",                     domain="7 · Enterprise Support Functions",   sistema="S151",       cls="s151",  cap_file="cap-gl.md",  slug="GL"),
    "8.1.1":  dict(name="Scheduling (WFL)",                 domain="8 · Technology Tools",              sistema="S500+S151",  cls="ambos", cap_file="cap-sch.md", slug="SCH"),
    "9.1.1":  dict(name="Operational Data Stores (DMSII)",  domain="9 · Insights & Information",        sistema="S500+S151",  cls="ambos", cap_file="cap-ods.md", slug="ODS"),
    "10.1.1": dict(name="Access Control",                   domain="10 · Integration & Interfaces",     sistema="S500",       cls="s500",  cap_file="cap-sec.md", slug="ACC"),
    "T.1.3":  dict(name="Payment Schemes (SPEI/CLABE)",     domain="Transversal",                       sistema="S500+S151",  cls="ambos", cap_file="cap-pay.md", slug="SPI"),
    "T.2.3":  dict(name="MQ / Async (L091-L093)",           domain="Transversal",                       sistema="S500",       cls="s500",  cap_file="cap-mq.md",  slug="MQ"),
    "T.3.4":  dict(name="Analytics / Reporting",            domain="Transversal",                       sistema="S151",       cls="s151",  cap_file="cap-rpt.md", slug="RPT"),
    "T.3.5":  dict(name="Security",                         domain="Transversal",                       sistema="S500+S151",  cls="ambos", cap_file="cap-sec.md", slug="SEC"),
    "T.4.1":  dict(name="CFR Regulatory Reporting Pipeline",domain="Transversal",                       sistema="S151",       cls="s151",  cap_file="cap-cfr.md", slug="CFR"),
    "T.5.1":  dict(name="Batch Orchestration (WFL)",          domain="Transversal",                       sistema="S500+S151",  cls="ambos", cap_file="cap-wfl.md", slug="WFL"),
    "T.6.1":  dict(name="CPE Captación Productiva Especial",  domain="Transversal",                       sistema="S500",       cls="s500",  cap_file="cap-cpe.md", slug="CPE"),
}

# Severidad icon → etiqueta normalizada
SEV_NORM = {"🔴": "CRITICO", "🟠": "ALTO", "🟡": "MEDIO", "🟢": "BAJO"}

# ── Parsers ──────────────────────────────────────────────────────────────────

def _cols(row):
    """Split markdown table row into stripped columns (skip leading/trailing |)."""
    return [c.strip() for c in row.strip().strip('|').split('|')]


def parse_tasks(content, slug):
    """
    Extract tasks from any table row containing T-{SLUG}-NNN.
    Returns list of {id, desc, tipo, prog, rules}.
    Also scans 'Reglas vinculadas a tareas' cross-ref table.
    """
    tasks = {}

    # Scan every table row for T-{SLUG}-NNN pattern (case-insensitive)
    task_id_re = re.compile(rf'\bT-{re.escape(slug)}-(\d+)\b', re.IGNORECASE)
    rule_ref_re = re.compile(r'\bRN-S(?:151|500)-\d+\b')
    prog_re     = re.compile(r'\b(P\d{2,4}|L\d{2,4}|S\d{3}[A-Z0-9]*)\b')

    for line in content.splitlines():
        if not line.startswith('|'):
            continue
        cols = _cols(line)
        if not cols:
            continue
        # Find the task ID column
        tid = None
        tid_col = -1
        for i, c in enumerate(cols):
            m = task_id_re.match(c)
            if m:
                tid = c.split()[0]  # just the ID, strip trailing garbage
                tid_col = i
                break
        if not tid:
            continue

        # Build task from remaining columns
        desc_cols = [c for i, c in enumerate(cols) if i != tid_col and c and not c.startswith('---')]
        desc = desc_cols[0] if desc_cols else ""
        # Strip bold markdown
        desc = re.sub(r'\*\*([^*]+)\*\*', r'\1', desc).strip()

        # Rules in this row
        rules_in_row = rule_ref_re.findall(line)

        # Program in this row
        prog_candidates = [p for p in prog_re.findall(line) if p != tid and not p.startswith('S0')]
        prog = prog_candidates[0] if prog_candidates else ""

        # Tipo: look for known tipo keywords in cols
        tipo = ""
        for c in desc_cols[1:]:
            if re.match(r'^(validaci[oó]n|control|contable|escritura|consulta|batch|online)$', c, re.I):
                tipo = c.lower()
                break

        if tid not in tasks:
            tasks[tid] = {"id": tid, "desc": desc, "tipo": tipo, "prog": prog, "rules": []}
        # Merge rules
        for r in rules_in_row:
            if r not in tasks[tid]["rules"]:
                tasks[tid]["rules"].append(r)

    # Also scan "Reglas vinculadas" cross-ref section
    xref_section = re.search(r'## Reglas vinculadas a tareas\s*\n(.*?)(?=\n## |\Z)', content, re.DOTALL)
    if xref_section:
        for line in xref_section.group(1).splitlines():
            if not line.startswith('|'):
                continue
            cols = _cols(line)
            if len(cols) < 2:
                continue
            # Format: | T-GL-001 | RN-S151-029 | ... |
            tid_m = task_id_re.search(cols[0])
            rids  = rule_ref_re.findall('|'.join(cols))
            if tid_m and rids:
                tid = tid_m.group(0)
                if tid in tasks:
                    for r in rids:
                        if r not in tasks[tid]["rules"]:
                            tasks[tid]["rules"].append(r)

    # Sort by numeric suffix
    def _sort_key(t):
        m = re.search(r'\d+$', t["id"])
        return int(m.group()) if m else 9999
    return sorted(tasks.values(), key=_sort_key)


def parse_hallazgos(content):
    """
    Extract hallazgos from ## Hallazgos sections.
    Returns list of {id, desc, severity_label, severity_icon, tasks, action}.
    """
    hall = []
    sev_re = re.compile(r'(🔴|🟠|🟡|🟢)\s*(CRÍTICO|CRITICO|ALTO|ALTA|MEDIO|MEDIA|BAJO|BAJA|DEFECTO|urgente)', re.IGNORECASE)

    # Find all hallazgo sections
    sections = re.split(r'\n## Hallazgos[^\n]*\n', content, flags=re.IGNORECASE)
    for section in sections[1:]:
        for line in section.splitlines():
            if not line.startswith('|'):
                continue
            cols = _cols(line)
            if len(cols) < 2 or cols[0].startswith('---') or cols[0].lower() in ('#', 'riesgo', 'hallazgo'):
                continue

            row_text = '|'.join(cols)
            # Try to find severity icon in any column
            sev_m = sev_re.search(row_text)
            if not sev_m:
                continue  # not a hallazgo data row

            icon  = sev_m.group(1)
            label = SEV_NORM.get(icon, sev_m.group(2).upper())

            # ID: first col if matches H-* pattern, else auto
            hid = cols[0] if re.match(r'H-', cols[0], re.I) else None

            # Desc: first substantial column (strip bold)
            desc_raw = cols[1] if hid else cols[0]
            desc = re.sub(r'\*\*([^*]+)\*\*', r'\1', desc_raw).strip()
            desc = re.sub(r'\*([^*]+)\*', r'\1', desc).strip()

            # Tasks referenced
            task_refs = re.findall(r'\bT-[A-Z]+-\d+\b', row_text)

            # Action: last substantive column
            action_col = [c for c in cols if len(c) > 20 and c != desc_raw]
            action = action_col[-1] if action_col else ""
            action = re.sub(r'\*\*([^*]+)\*\*', r'\1', action).strip()

            entry = {
                "id":       hid or "",
                "desc":     desc[:300],
                "severity_icon":  icon,
                "severity_label": label,
                "tasks":    task_refs,
                "action":   action[:200],
            }
            hall.append(entry)

    return hall


def parse_context(content):
    """Extract first paragraph of ## Contexto funcional."""
    m = re.search(r'## Contexto funcional\s*\n+([^\n].+?)(?:\n\n|\n##)', content, re.DOTALL)
    if not m:
        return ""
    text = m.group(1).strip()
    # Strip markdown bold/italic
    text = re.sub(r'\*\*([^*]+)\*\*', r'\1', text)
    text = re.sub(r'\*([^*]+)\*', r'\1', text)
    # Truncate to ~400 chars at sentence boundary
    if len(text) > 400:
        cut = text[:400].rfind('. ')
        text = text[:cut+1] if cut > 100 else text[:400]
    return text.strip()


def all_rule_refs(content):
    """All unique RN-S151/S500-NNN found anywhere in the file."""
    refs = sorted(set(re.findall(r'\bRN-S(?:151|500)-\d+\b', content)))
    return refs


# ── Rules catalog ─────────────────────────────────────────────────────────────

def load_rules_catalog():
    """
    Parse all rules-catalog/*.md files.
    Returns dict: rule_id -> {id, title, prog, tipos, desc, regulador, confianza}.
    """
    rules = {}
    catalog_files = glob.glob(os.path.join(RULES_DIR, "*.md"))
    catalog_files = [f for f in catalog_files if 'INDEX' not in os.path.basename(f).upper()]

    for fpath in catalog_files:
        with open(fpath, encoding='utf-8') as f:
            content = f.read()

        # Split by rule headers: ## RN-S{151|500}-NNN — title
        parts = re.split(r'\n(?=## RN-S(?:151|500)-\d+)', content)
        for part in parts:
            hm = re.match(r'## (RN-S(?:151|500)-\d+)\s*[—-]\s*(.+?)(?:\n|$)', part)
            if not hm:
                continue
            rule_id = hm.group(1).strip()
            title   = hm.group(2).strip()

            # Metadata table values
            def _meta(field):
                m = re.search(rf'\*\*{re.escape(field)}\*\*\s*\|\s*([^\n|]+)', part)
                return m.group(1).strip() if m else ""

            prog      = _meta("Programa(s) fuente") or _meta("Programa fuente")
            regulador = _meta("Regulador")
            confianza = _meta("Confianza")
            tipo_raw  = _meta("Tipo")
            tipos = re.findall(r'\[([^\]]+)\]', tipo_raw)

            # Description: paragraph after **Descripción:**
            desc_m = re.search(r'\*\*Descripci[oó]n[:\*]*\s*\*?\*?\s*([^\n]+)', part)
            desc = desc_m.group(1).strip() if desc_m else ""
            # Fallback: first non-table paragraph
            if not desc:
                paras = re.findall(r'\n\n([^|#\n*`].{30,}?)(?=\n\n|\n##|\Z)', part, re.DOTALL)
                if paras:
                    desc = paras[0].replace('\n', ' ').strip()[:300]

            # Formula/pseudocode
            formula_m = re.search(r'```\s*\n(.*?)```', part, re.DOTALL)
            formula = formula_m.group(1).strip()[:400] if formula_m else ""

            rules[rule_id] = {
                "id":        rule_id,
                "title":     title[:120],
                "prog":      prog,
                "tipos":     tipos,
                "desc":      desc[:300],
                "regulador": regulador,
                "confianza": confianza,
                "formula":   formula,
            }

    return rules


# ── Main ─────────────────────────────────────────────────────────────────────

def main():
    print("build-cap-data.py - Banamex GemCog")
    print("=" * 50)

    # 1. Load rules catalog
    print("\nCargando reglas catalog...")
    rules_db = load_rules_catalog()
    print(f"  {len(rules_db)} reglas indexadas")

    # 2. Process each capability
    capabilities = {}
    for cap_id, meta in sorted(CAP_MAP.items()):
        cap_file = os.path.join(CAPS_DIR, meta["cap_file"])
        if not os.path.exists(cap_file):
            print(f"  [SKIP] {cap_id} — archivo no encontrado: {meta['cap_file']}")
            continue

        with open(cap_file, encoding='utf-8') as f:
            content = f.read()

        slug = meta["slug"]
        tasks      = parse_tasks(content, slug)
        hallazgos  = parse_hallazgos(content)
        context    = parse_context(content)
        rule_refs  = all_rule_refs(content)

        # Enrich rule refs with catalog data
        rules_detail = []
        seen_rules = set()
        for rid in rule_refs:
            if rid in seen_rules:
                continue
            seen_rules.add(rid)
            if rid in rules_db:
                rules_detail.append(rules_db[rid])
            else:
                rules_detail.append({"id": rid, "title": rid, "prog": "", "tipos": [], "desc": "", "formula": ""})

        # Extract main programs from tasks
        progs = []
        for t in tasks:
            if t["prog"] and t["prog"] not in progs:
                progs.append(t["prog"])

        capabilities[cap_id] = {
            "id":            cap_id,
            "name":          meta["name"],
            "domain":        meta["domain"],
            "sistema":       meta["sistema"],
            "cls":           meta["cls"],
            "main_progs":    progs[:8],
            "context":       context,
            "tasks":         tasks,
            "hallazgos":     hallazgos,
            "rules":         rules_detail,
            "rule_count":    len(rule_refs),
            "task_count":    len(tasks),
            "hallazgo_count":len(hallazgos),
        }

        sev_counts = {}
        for h in hallazgos:
            k = h["severity_label"]
            sev_counts[k] = sev_counts.get(k, 0) + 1
        sev_str = " ".join(f"{v}x{k}" for k, v in sev_counts.items())
        print(f"  {cap_id:8s}  {len(tasks):>3d}T  {len(rule_refs):>3d}R  {len(hallazgos):>2d}H  {sev_str[:25]:<25s}  {meta['cap_file']}")

    # 3. Build output
    output = {
        "version":        "1.0",
        "generated":      str(date.today()),
        "total_covered":  len(capabilities),
        "rules_indexed":  len(rules_db),
        "capabilities":   capabilities,
    }

    os.makedirs(os.path.dirname(OUT_PATH), exist_ok=True)
    with open(OUT_PATH, "w", encoding="utf-8") as f:
        json.dump(output, f, ensure_ascii=False, indent=2)

    total_tasks    = sum(c["task_count"]    for c in capabilities.values())
    total_hallazgs = sum(c["hallazgo_count"] for c in capabilities.values())
    total_rules    = sum(c["rule_count"]    for c in capabilities.values())

    print(f"\nOK  {OUT_PATH}")
    print(f"    {len(capabilities)} capacidades  |  {total_tasks} tareas  |  {total_rules} refs reglas  |  {total_hallazgs} hallazgos")
    print(f"    {len(rules_db)} reglas en catalog indexadas")


if __name__ == "__main__":
    main()

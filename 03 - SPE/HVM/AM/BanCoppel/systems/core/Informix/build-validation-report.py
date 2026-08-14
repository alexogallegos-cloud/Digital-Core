#!/usr/bin/env python3
"""
build-validation-report.py — Informix Knowledge Base Integrity Validator (Capa 1)
Genera validation-report-bcop.html y retorna exit code 0 (PASS) / 1 (FAIL).

Checks:
  - critical-files : archivos críticos del proyecto
  - dt-files       : todos los DT CLAUDE.md existen
  - structure      : raíz de knowledge-base/ solo tiene los 2 archivos canónicos
  - coverage       : D01-D16 tienen los 22 doc types canónicos
  - stubs          : D17-D49 tienen 00-index.md
  - links          : todos los links relativos en .md resuelven a archivos existentes
  - bc-ids         : bc_id en business-rules-bcop.md siguen formato P{NNN}-R{NNN}
  - risks          : riesgos críticos R001/R002/R009/R010 presentes en risk register
  - etb            : etb-capabilities.json es JSON válido
"""

import re, json, sys
from pathlib import Path
from datetime import datetime

# ── Paths ────────────────────────────────────────────────────────────────────

ROOT = Path(__file__).parent
KB   = ROOT / "knowledge-base"
DT   = ROOT / "dt"

# ── Constants ─────────────────────────────────────────────────────────────────

ANALYZED_RANGE = range(1, 17)   # D01–D16
STUB_RANGE     = range(17, 50)  # D17–D49

CANONICAL_DOCS = [
    "00-business-process-catalog.md",
    "01-journey.md",
    "02-data-catalog.md",
    "03-data-dictionary.md",
    "04-business-rules.md",
    "05-risks.md",
    "06-exceptions.md",
    "07-dependencies.md",
    "08-sp-table-matrix.md",
    "09-dead-code.md",
    "10-test-strategy.md",
    "11-batch-processes.md",
    "12-er-model.md",
    "13-external-dependencies.md",
    "14-target-architecture.md",
    "15-type-mapping.md",
    "16-api-contract.md",
    "17-data-migration-plan.md",
    "18-pii-security-assessment.md",
    "19-performance-baseline.md",
    "20-cutover-plan.md",
    "21-observability-runbook.md",
]

STUB_DOC = "00-index.md"

CRITICAL_FILES = [
    (KB / "migration-risk-register.md",                 "ERROR"),
    (KB / "README.md",                                   "WARN"),
    (KB / "ontology" / "etb-capabilities.json",          "ERROR"),
    (KB / "rules" / "business-rules-bcop.md",            "ERROR"),
    (KB / "vocabulary" / "vocabulary-knowledge-base-bcop.md", "ERROR"),
    (KB / "vocabulary" / "vocabulary-inventory-bcop.md", "WARN"),
    (KB / "vocabulary" / "vocabulary-enrichment.json",   "WARN"),
    (KB / "cross-reference" / "domain-dependency-matrix.md", "WARN"),
]

DT_NAMES = [
    "dt-vocabulario", "dt-almas", "dt-journeys", "dt-reglas",
    "dt-capacidades", "dt-riesgos", "dt-modelo-dominio", "dt-validador",
]

CRITICAL_RISK_IDS = ["R001", "R002", "R009", "R010"]

CATEGORY_LABELS = {
    "critical-files": "Archivos críticos",
    "dt-files":       "Digital Twins — CLAUDE.md",
    "structure":      "Estructura raíz knowledge-base/",
    "coverage":       "Cobertura dominios analizados (D01–D16)",
    "stubs":          "Stubs scope expandido (D17–D49)",
    "links":          "Links internos en archivos .md",
    "bc-ids":         "Formato bc_id en reglas",
    "risks":          "Riesgos críticos en risk register",
    "etb":            "etb-capabilities.json",
}

findings = []

# ── Helpers ───────────────────────────────────────────────────────────────────

def _rel(p: Path) -> str:
    try:
        return str(p.relative_to(ROOT))
    except ValueError:
        return str(p)

def record(sev: str, cat: str, msg: str, file_path="", detail=""):
    findings.append({
        "severity": sev,
        "category": cat,
        "message":  msg,
        "file":     str(file_path),
        "detail":   detail,
    })

def find_domain_folder(n: int) -> Path | None:
    prefix = f"D{n:02d}-"
    for d in KB.iterdir():
        if d.is_dir() and d.name.startswith(prefix):
            return d
    return None

# ── Checks ────────────────────────────────────────────────────────────────────

def check_critical_files():
    for path, sev in CRITICAL_FILES:
        if path.exists():
            record("ok", "critical-files", f"Presente: {path.name}", _rel(path))
        else:
            record(sev, "critical-files", f"No encontrado: {path.name}", _rel(path))


def check_dt_files():
    for name in DT_NAMES:
        p = DT / name / "CLAUDE.md"
        if p.exists():
            record("ok", "dt-files", f"{name}/CLAUDE.md presente", _rel(p))
        else:
            record("ERROR", "dt-files", f"DT CLAUDE.md no encontrado: {name}", _rel(p))


def check_kb_root_clean():
    if not KB.exists():
        record("ERROR", "structure", "Directorio knowledge-base/ no existe", "knowledge-base/")
        return
    unexpected = sorted(
        f.name for f in KB.iterdir()
        if f.is_file() and f.suffix == ".md"
        and f.name not in {"README.md", "migration-risk-register.md"}
    )
    if unexpected:
        record("WARN", "structure",
               f"Archivos .md inesperados en raíz de knowledge-base/ ({len(unexpected)})",
               "knowledge-base/", ", ".join(unexpected))
    else:
        record("ok", "structure",
               "Raíz de knowledge-base/ contiene únicamente README.md y migration-risk-register.md")


def check_domain_coverage():
    # Analyzed domains D01–D16: must have all 22 canonical docs
    for n in ANALYZED_RANGE:
        d = find_domain_folder(n)
        if d is None:
            record("ERROR", "coverage",
                   f"D{n:02d}: carpeta no encontrada en knowledge-base/",
                   f"knowledge-base/D{n:02d}-*/")
            continue
        existing = {f.name for f in d.iterdir() if f.is_file()}
        missing  = [doc for doc in CANONICAL_DOCS if doc not in existing]
        rel = _rel(d)
        if missing:
            record("WARN", "coverage",
                   f"{d.name}: faltan {len(missing)}/22 docs canónicos",
                   rel, "Faltantes: " + ", ".join(missing))
        else:
            record("ok", "coverage", f"{d.name}: 22/22 docs presentes", rel)

    # Stub domains D17–D49: must have 00-index.md
    for n in STUB_RANGE:
        d = find_domain_folder(n)
        if d is None:
            record("WARN", "stubs",
                   f"D{n:02d}: carpeta stub no encontrada en knowledge-base/",
                   f"knowledge-base/D{n:02d}-*/")
            continue
        rel = _rel(d)
        if not (d / STUB_DOC).exists():
            record("WARN", "stubs", f"{d.name}: falta stub {STUB_DOC}", rel)
        else:
            record("ok", "stubs", f"{d.name}: {STUB_DOC} presente", rel)


NAV_EXTENSIONS = {".html", ".json", ".py", ".js", ".svg", ".png", ".jpg", ".csv"}

def check_links():
    """Scan all .md files and validate relative links.

    Severity:
      ERROR — link to a .md file (or bare directory) that does not exist
      WARN  — link to a generated/nav asset (.html/.json/.py/etc.) that does not exist
    """
    LINK_RE = re.compile(r'\[([^\]]*)\]\(([^)\s]+)\)')
    scan_dirs = [KB, DT]
    md_files  = list(ROOT.glob("*.md"))
    for sd in scan_dirs:
        if sd.exists():
            md_files += list(sd.rglob("*.md"))

    broken_struct = 0
    broken_nav    = 0
    total         = 0
    for md_path in md_files:
        try:
            content = md_path.read_text(encoding="utf-8", errors="ignore")
        except Exception:
            continue
        for m in LINK_RE.finditer(content):
            link_text, link_href = m.group(1), m.group(2)
            if link_href.startswith(("http://", "https://", "#", "mailto:")):
                continue
            href_clean = link_href.split("#")[0].strip()
            if not href_clean:
                continue
            total += 1
            resolved = (md_path.parent / href_clean).resolve()
            if not resolved.exists():
                suffix = Path(href_clean).suffix.lower()
                is_nav = suffix in NAV_EXTENSIONS
                if is_nav:
                    broken_nav += 1
                    record("WARN", "links",
                           f"Link roto (nav/generado): [{link_text}]({link_href})",
                           _rel(md_path))
                else:
                    broken_struct += 1
                    record("ERROR", "links",
                           f"Link roto (.md): [{link_text}]({link_href})",
                           _rel(md_path),
                           f"Resuelve a: {resolved}")

    total_broken = broken_struct + broken_nav
    if total_broken == 0:
        record("ok", "links", f"Todos los {total} links internos resuelven correctamente")
    else:
        record("ok", "links",
               f"Links: {total} verificados · {broken_struct} .md rotos (↑ERROR) · {broken_nav} nav/generados (↑WARN)")


def check_bc_ids():
    rules_path = KB / "rules" / "business-rules-bcop.md"
    if not rules_path.exists():
        return
    content = rules_path.read_text(encoding="utf-8", errors="ignore")
    # Wide-extraction IDs use BR-V2-NNNN format; SBVR formal uses BR-IFX-NNN (in brain.db)
    all_ids  = re.findall(r'\bBR-V2-\d+\b', content)
    if not all_ids:
        record("WARN", "bc-ids", "No se encontraron IDs BR-V2-NNNN en business-rules-bcop.md",
               _rel(rules_path))
        return

    CANON_RE  = re.compile(r'^BR-V2-\d{4,}$')
    malformed = sorted({bid for bid in all_ids if not CANON_RE.match(bid)})
    unique_ids = sorted(set(all_ids))
    rel = _rel(rules_path)
    if malformed:
        record("WARN", "bc-ids",
               f"{len(malformed)} bc_id con formato no canónico (esperado BR-V2-NNNN)",
               rel, "Ejemplos: " + ", ".join(malformed[:10]))
    else:
        # Duplicates are expected: the file is a multi-section view (equivalence, type, domain)
        # where the same rule ID intentionally appears in several filtered tables.
        record("ok", "bc-ids",
               f"{len(unique_ids)} IDs BR-V2-NNNN únicos ({len(all_ids)} apariciones en secciones múltiples — esperado)")


def check_critical_risks():
    rr_path = KB / "migration-risk-register.md"
    if not rr_path.exists():
        return
    content = rr_path.read_text(encoding="utf-8", errors="ignore")
    missing = [r for r in CRITICAL_RISK_IDS if r not in content]
    rel = _rel(rr_path)
    if missing:
        record("ERROR", "risks",
               f"Riesgo(s) crítico(s) no encontrado(s) en el risk register: {', '.join(missing)}",
               rel)
    else:
        record("ok", "risks",
               "Los 4 riesgos críticos (R001/R002/R009/R010) están en migration-risk-register.md",
               rel)


def check_etb_json():
    etb_path = KB / "ontology" / "etb-capabilities.json"
    if not etb_path.exists():
        return
    rel = _rel(etb_path)
    try:
        with open(etb_path, encoding="utf-8") as f:
            data = json.load(f)
        l3_count = 0
        if isinstance(data, list):
            l3_count = len(data)
        elif isinstance(data, dict):
            for key in ("l3", "capabilities", "items", "data"):
                if key in data and isinstance(data[key], list):
                    l3_count = len(data[key])
                    break
        record("ok", "etb",
               f"etb-capabilities.json válido — {l3_count or '?'} entries en nivel raíz",
               rel)
    except json.JSONDecodeError as e:
        record("ERROR", "etb", f"etb-capabilities.json no es JSON válido: {e}", rel)

# ── HTML ─────────────────────────────────────────────────────────────────────

def build_html(ts: str) -> str:
    errors = [f for f in findings if f["severity"] == "ERROR"]
    warns  = [f for f in findings if f["severity"] == "WARN"]
    oks    = [f for f in findings if f["severity"] == "ok"]
    status       = "FAIL" if errors else "PASS"
    status_color = "#dc2626" if errors else "#16a34a"

    cats = {}
    for f in findings:
        cats.setdefault(f["category"], []).append(f)

    sections = ""
    for cat in CATEGORY_LABELS:
        items = cats.get(cat, [])
        if not items:
            continue
        label     = CATEGORY_LABELS[cat]
        cat_errors = sum(1 for i in items if i["severity"] == "ERROR")
        cat_warns  = sum(1 for i in items if i["severity"] == "WARN")
        cat_oks    = len(items) - cat_errors - cat_warns
        cat_icon   = "🔴" if cat_errors else ("🟡" if cat_warns else "🟢")
        open_attr  = " open" if cat_errors else ""

        rows = ""
        for item in items:
            sev  = item["severity"]
            icon = {"ERROR": "🔴", "WARN": "🟡", "ok": "🟢"}.get(sev, "⚪")
            file_html   = (f'<span class="chip">{item["file"]}</span>'
                           if item["file"] else "")
            detail_html = (f'<div class="detail">{item["detail"]}</div>'
                           if item["detail"] else "")
            rows += (
                f'<div class="finding f-{sev.lower()}">'
                f'{icon} <span class="msg">{item["message"]}</span>'
                f'{file_html}{detail_html}</div>'
            )

        sections += (
            f'<details class="cat-block"{open_attr}>'
            f'<summary>'
            f'<span class="ci">{cat_icon}</span>'
            f'<span class="cl">{label}</span>'
            f'<span class="cc">{cat_errors} err · {cat_warns} warn · {cat_oks} ok</span>'
            f'</summary>'
            f'<div class="cat-body">{rows}</div>'
            f'</details>'
        )

    return f"""<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>Integridad KB — Informix</title>
<style>
:root{{--bg:#f5f7ff;--bg2:#eaedfa;--panel:#fff;--primary:#122FB1;
  --dark:#0a1330;--border:#d1d5f0;--text:#1e293b;--muted:#64748b;
  --err:#dc2626;--wrn:#d97706;--ok:#16a34a;
  --font:'Segoe UI',system-ui,sans-serif;}}
*{{box-sizing:border-box;margin:0;padding:0}}
body{{background:var(--bg);font-family:var(--font);color:var(--text);font-size:14px}}
.hdr{{background:var(--dark);color:#fff;padding:18px 32px;display:flex;align-items:center;gap:16px}}
.hdr h1{{font-size:18px;font-weight:700}}
.hdr-sub{{font-size:11px;color:#94a3b8;margin-bottom:4px}}
.hdr-ts{{font-size:11px;color:#94a3b8;margin-top:2px}}
.badge{{background:{status_color};color:#fff;padding:5px 18px;border-radius:20px;
  font-weight:700;font-size:15px;margin-left:auto;letter-spacing:.04em}}
.summary{{background:var(--panel);border-bottom:1px solid var(--border);
  padding:16px 32px;display:flex;gap:32px;flex-wrap:wrap}}
.tile{{display:flex;flex-direction:column;align-items:center;min-width:60px}}
.tile .num{{font-size:30px;font-weight:800;line-height:1}}
.tile .lbl{{font-size:11px;color:var(--muted);margin-top:2px;
  text-transform:uppercase;letter-spacing:.05em}}
.tile.err .num{{color:var(--err)}}
.tile.wrn .num{{color:var(--wrn)}}
.tile.ok  .num{{color:var(--ok)}}
.main{{padding:24px 32px;max-width:1100px}}
.legend{{font-size:11px;color:var(--muted);margin-bottom:14px}}
.cat-block{{background:var(--panel);border:1px solid var(--border);
  border-radius:8px;margin-bottom:8px;overflow:hidden}}
.cat-block>summary{{padding:12px 16px;cursor:pointer;display:flex;align-items:center;
  gap:10px;user-select:none;list-style:none}}
.cat-block>summary::-webkit-details-marker{{display:none}}
.cat-block>summary:hover{{background:var(--bg2)}}
.ci{{font-size:16px;flex-shrink:0}}
.cl{{font-weight:600;flex:1}}
.cc{{font-size:11px;color:var(--muted)}}
.cat-body{{padding:6px 16px 12px;border-top:1px solid var(--border)}}
.finding{{padding:8px 0;border-bottom:1px solid var(--bg2);
  display:flex;flex-wrap:wrap;align-items:baseline;gap:6px}}
.finding:last-child{{border-bottom:none}}
.msg{{flex:1;min-width:200px}}
.chip{{font-size:11px;color:var(--muted);background:var(--bg2);
  padding:2px 6px;border-radius:4px;font-family:monospace;word-break:break-all}}
.detail{{width:100%;font-size:11px;color:var(--muted);
  font-family:monospace;padding-left:24px;word-break:break-all;margin-top:2px}}
</style>
</head>
<body>
<div class="hdr">
  <div>
    <div class="hdr-sub">Informix · SPE-AM-001 · DT-Validador v1.0 · Capa 1</div>
    <h1>Reporte de Integridad — Knowledge Base</h1>
    <div class="hdr-ts">Generado: {ts}</div>
  </div>
  <div class="badge">{status}</div>
</div>
<div class="summary">
  <div class="tile err"><div class="num">{len(errors)}</div><div class="lbl">Errores</div></div>
  <div class="tile wrn"><div class="num">{len(warns)}</div><div class="lbl">Advertencias</div></div>
  <div class="tile ok"><div class="num">{len(oks)}</div><div class="lbl">OK</div></div>
  <div class="tile"><div class="num">{len(findings)}</div><div class="lbl">Total</div></div>
</div>
<div class="main">
  <p class="legend">🔴 ERROR — bloquea avance de fase &nbsp;·&nbsp; 🟡 WARN — requiere atención &nbsp;·&nbsp; 🟢 OK — verificado</p>
  {sections}
</div>
</body>
</html>"""

# ── Main ──────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    ts = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    check_critical_files()
    check_dt_files()
    check_kb_root_clean()
    check_domain_coverage()
    check_etb_json()
    check_bc_ids()
    check_critical_risks()
    check_links()     # last — puede ser lento en repos grandes

    html = build_html(ts)
    out  = ROOT / "validation-report-bcop.html"
    out.write_text(html, encoding="utf-8")

    errors = [f for f in findings if f["severity"] == "ERROR"]
    warns  = [f for f in findings if f["severity"] == "WARN"]
    oks    = [f for f in findings if f["severity"] == "ok"]

    result = "FAIL" if errors else "PASS"
    print(f"\n{'='*60}")
    print(f"  Informix KB Validation — {result}")
    print(f"  {len(errors)} errores · {len(warns)} advertencias · {len(oks)} ok")
    print(f"  Reporte: {out}")
    print(f"{'='*60}\n")

    sys.exit(1 if errors else 0)
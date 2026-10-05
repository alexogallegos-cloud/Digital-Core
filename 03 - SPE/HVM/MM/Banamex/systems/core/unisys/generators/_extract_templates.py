"""
_extract_templates.py — ONE-TIME shell extractor.

Reads the READ-ONLY reference portal exactly once and writes byte-exact
presentation shells (head + nav + footer/scripts) into generators/templates/.
build-portal.py then reads ONLY these templates, never the reference.

The <title> line is replaced by the token {{TITLE}}. For the cap footer/scripts
the capacity-specific tokens are replaced by {{SLUG_UPPER}} / {{SLUG}} / {{CAPTITLE}}
/ {{KB_NAME}} placeholders so the same template serves every capacity.

Run:  PYTHONUTF8=1 python generators/_extract_templates.py
"""
from pathlib import Path

BASE = Path(__file__).resolve().parent.parent
REF = BASE / "source" / "GemCogAlt" / "gemcog-portal-2026-08-26-cliente-entregable"
TPL = Path(__file__).resolve().parent / "templates"
TPL.mkdir(exist_ok=True)

NL = "\n"


def lines_of(p):
    return p.read_text(encoding="utf-8").split(NL)


# ── PSEUDO shell ────────────────────────────────────────────────────────────
# head = lines 1..114 (index 0..113): <!DOCTYPE> .. </nav>. title at line 3.
pl = lines_of(REF / "pseudocodigo" / "S500_P046.html")
pl[2] = "<title>{{TITLE}}</title>"
(TPL / "pseudo_head.html").write_text(NL.join(pl[0:114]) + NL, encoding="utf-8")

# ── CAP shell ───────────────────────────────────────────────────────────────
# head = lines 1..249 (index 0..248): <!DOCTYPE> .. <main>. title at line 3.
cl = lines_of(REF / "modelo capacidades" / "cap-pos.html")
cl[2] = "<title>{{TITLE}}</title>"
cap_head = NL.join(cl[0:249]) + NL
(TPL / "cap_head.html").write_text(cap_head, encoding="utf-8")

# footer + all trailing scripts = lines 390..605 (index 389..605 inclusive of final "")
cap_foot = NL.join(cl[389:])   # through final trailing newline element
# Parameterise capacity-specific tokens (derived from cap-pos → slug=pos, upper=POS)
cap_foot = cap_foot.replace("gemcog-kb-2026-08-25-cliente-entregable", "{{KB_NAME}}")
cap_foot = cap_foot.replace("BC-25 · Consolidación Financiera", "{{CAPTITLE}}")
cap_foot = cap_foot.replace("sme-cap-pos-0811", "sme-cap-{{SLUG}}-0811")
# order matters: replace the longer 'POS' tokens carefully. All uses are suffix _POS or POS()
cap_foot = cap_foot.replace("POS", "{{SLUG_UPPER}}")
(TPL / "cap_foot.html").write_text(cap_foot, encoding="utf-8")

# SME card (bespoke section, lines 369..386) — templated with slug upper.
sme_card = NL.join(cl[368:386])
sme_card = sme_card.replace("POS", "{{SLUG_UPPER}}")
(TPL / "cap_sme_card.html").write_text(sme_card, encoding="utf-8")

# ── INDEX (dashboard bespoke, sin fuente markdown) ──────────────────────────
# Es narrativa hand-authored; sólo las cifras genuinamente derivables del brain
# se parametrizan: total de reglas (stats.rules) y total de objetos (inventario).
idx = (REF / "index.html").read_text(encoding="utf-8")
idx = idx.replace('data-target="218"', 'data-target="{{OBJETOS}}"')
idx = idx.replace("1,583", "{{RULES}}")
(TPL / "index_page.html").write_text(idx, encoding="utf-8")
print("index_page.html", (TPL / "index_page.html").stat().st_size)

print("pseudo_head.html", (TPL / "pseudo_head.html").stat().st_size)
print("cap_head.html", (TPL / "cap_head.html").stat().st_size)
print("cap_foot.html", (TPL / "cap_foot.html").stat().st_size)

#!/usr/bin/env python3
"""
build-incidents.py — Informix · Generador de páginas de incidentes
Lee secciones INC-D{NN}-{NN} de los runbooks (21-observability-runbook.md)
y genera páginas HTML standalone en portal/incidents/.

Uso: python generators/build-incidents.py
     (ejecutar desde Informix/)
"""

import re, sys, json
from pathlib import Path
from datetime import date

if hasattr(sys.stdout, 'reconfigure'):
    sys.stdout.reconfigure(encoding='utf-8', errors='replace')

ROOT    = Path(__file__).resolve().parent.parent   # Informix/
KB      = ROOT / 'knowledge-base'
OUT_DIR = ROOT / 'portal' / 'incidents'
OUT_DIR.mkdir(parents=True, exist_ok=True)

# ── Mapa canónico: html_slug → (runbook_path, inc_html_slug) ─────────────────

INCIDENTS = [
    ('inc-001-d05-appriza',       'D05-bdisac/21-observability-runbook.md'),
    ('inc-002-d11-cobranza-cv',   'D11-bdicobranza/21-observability-runbook.md'),
    ('inc-003-d01-defecto-prod',  'D01-bdicnweb/21-observability-runbook.md'),
    ('inc-004-d08-esb-spei',      'D08-bdispei/21-observability-runbook.md'),
    ('inc-005-d13-esb-tef',       'D13-bditef/21-observability-runbook.md'),
    ('inc-006-d14-esb-bei',       'D14-bdibei/21-observability-runbook.md'),
    ('inc-007-d02-huellas-stale', 'D02-bdinteg/21-observability-runbook.md'),
    ('inc-008-d02-aceptporta',    'D02-bdinteg/21-observability-runbook.md'),
]

# ── Markdown → HTML (simple, sin deps externas) ───────────────────────────────

def md_to_html(md: str) -> str:
    lines = md.split('\n')
    out   = []
    in_code  = False
    in_list  = False
    in_bq    = False
    code_buf = []

    def flush_list():
        nonlocal in_list
        if in_list:
            out.append('</ul>')
            in_list = False

    def flush_bq():
        nonlocal in_bq
        if in_bq:
            out.append('</blockquote>')
            in_bq = False

    def inline(text):
        # Bold + italic
        text = re.sub(r'\*\*\*(.+?)\*\*\*', r'<strong><em>\1</em></strong>', text)
        text = re.sub(r'\*\*(.+?)\*\*',     r'<strong>\1</strong>', text)
        text = re.sub(r'(?<!\*)\*(?!\*)(.+?)(?<!\*)\*(?!\*)', r'<em>\1</em>', text)
        # Inline code
        text = re.sub(r'`([^`]+)`', r'<code>\1</code>', text)
        # Links
        text = re.sub(r'\[([^\]]+)\]\(([^)]+)\)', r'<a href="\2">\1</a>', text)
        # Horizontal bar notation
        text = text.replace('·', '&middot;').replace('→', '&rarr;').replace('←', '&larr;')
        return text

    for line in lines:
        stripped = line.strip()

        # ── Fenced code block ────────────────────────────────────────────────
        if stripped.startswith('```'):
            if in_code:
                out.append('<pre><code>' + '\n'.join(code_buf) + '</code></pre>')
                code_buf = []
                in_code  = False
            else:
                flush_list()
                flush_bq()
                in_code = True
            continue

        if in_code:
            code_buf.append(line.replace('<', '&lt;').replace('>', '&gt;'))
            continue

        # ── Blockquote ──────────────────────────────────────────────────────
        if stripped.startswith('> '):
            flush_list()
            if not in_bq:
                out.append('<blockquote>')
                in_bq = True
            out.append(f'<p>{inline(stripped[2:])}</p>')
            continue
        else:
            flush_bq()

        # ── Horizontal rule ─────────────────────────────────────────────────
        if re.match(r'^[-*_]{3,}$', stripped):
            flush_list()
            out.append('<hr>')
            continue

        # ── Headers ─────────────────────────────────────────────────────────
        m = re.match(r'^(#{1,6})\s+(.*)', stripped)
        if m:
            flush_list()
            lvl   = len(m.group(1))
            htag  = f'h{min(lvl + 1, 6)}'
            out.append(f'<{htag}>{inline(m.group(2))}</{htag}>')
            continue

        # ── List item ────────────────────────────────────────────────────────
        if re.match(r'^[-*]\s+', stripped):
            if not in_list:
                out.append('<ul>')
                in_list = True
            text = re.sub(r'^[-*]\s+', '', stripped)
            out.append(f'<li>{inline(text)}</li>')
            continue
        elif re.match(r'^\d+\.\s+', stripped):
            if not in_list:
                out.append('<ol>')
                in_list = True
            text = re.sub(r'^\d+\.\s+', '', stripped)
            out.append(f'<li>{inline(text)}</li>')
            continue
        else:
            if in_list:
                # Check if continuation of list (indented)
                if line.startswith('  ') and stripped:
                    out.append(f'<li>{inline(stripped)}</li>')
                    continue
                flush_list()

        # ── Empty line ───────────────────────────────────────────────────────
        if not stripped:
            out.append('')
            continue

        # ── Paragraph ────────────────────────────────────────────────────────
        out.append(f'<p>{inline(stripped)}</p>')

    # Flush open blocks
    flush_list()
    flush_bq()
    if in_code:
        out.append('<pre><code>' + '\n'.join(code_buf) + '</code></pre>')

    return '\n'.join(out)


# ── Extractor de sección desde runbook ───────────────────────────────────────

def extract_section(content: str, inc_slug: str) -> tuple[str, str]:
    """
    Encuentra la sección ### INC que contiene el link al inc_slug.
    Retorna (section_header, section_body_md).
    """
    # Encontrar el link al html
    link_pat = re.escape(inc_slug + '.html')
    idx = content.find(inc_slug + '.html')
    if idx < 0:
        return ('', '')

    # Retroceder al header ### más cercano
    before = content[:idx]
    h3_idx = before.rfind('\n### ')
    if h3_idx < 0:
        h3_idx = 0

    # Avanzar al siguiente header ### (o fin)
    rest_after_header = content[h3_idx:]
    next_h3 = rest_after_header.find('\n### ', 1)
    if next_h3 > 0:
        section = rest_after_header[:next_h3]
    else:
        # Limitar a 4000 chars para no incluir demasiado
        section = rest_after_header[:4000]

    # Separar header del body (section puede iniciar con \n si rfind apuntó al \n)
    lines = section.split('\n')
    header_line = next((l.strip() for l in lines if l.strip().startswith('###')), '')
    if not header_line:
        return ('', '')
    # Body = todo después del header
    try:
        h_pos = next(i for i, l in enumerate(lines) if l.strip() == header_line)
        body = '\n'.join(lines[h_pos + 1:]).strip()
    except StopIteration:
        body = '\n'.join(lines[1:]).strip()

    return header_line, body


# ── Derivar severidad del título ─────────────────────────────────────────────

def get_severity(header: str, body: str) -> tuple[str, str]:
    """Retorna (nivel, color_class) para el badge."""
    for text in (header, body):
        m = re.search(r'\(N(\d)\)', text)
        if m:
            n = int(m.group(1))
            if n >= 5:
                return f'N{n}', 'err'
            if n == 4:
                return f'N{n}', 'err'
            if n == 3:
                return f'N{n}', 'warn'
            return f'N{n}', 'ok'
    return 'N?', 'info'


# ── Template HTML ─────────────────────────────────────────────────────────────

HTML_TEMPLATE = '''\
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>{inc_id_upper} · {title_short} · BanCoppel Informix</title>
<style>
:root {{
  --ancla: #122FB1;
  --senal: #F0D224;
  --plano: #EEF0FA;
  --trazo: #C5CCE8;
  --bg:    #EEF0FA;
  --card:  #ffffff;
  --ok:    #22c55e;
  --err:   #ef4444;
  --warn:  #f97316;
  --info:  #60a5fa;
  --txt:   #0d1a3a;
  --dim:   #4a5a8a;
  --border:#C5CCE8;
}}
* {{ box-sizing: border-box; margin: 0; padding: 0; }}
body {{
  background: var(--bg);
  color: var(--txt);
  font-family: Calibri, 'Segoe UI', Arial, sans-serif;
  min-height: 100vh;
  display: flex;
  flex-direction: column;
}}
.signal-top {{ height: 3px; background: var(--senal); width: 100%; }}
header {{
  background: var(--ancla);
  border-bottom: 1px solid rgba(240,210,36,.35);
  padding: 14px 28px 13px;
}}
.hdr-row {{
  display: flex;
  align-items: center;
  gap: 16px;
  flex-wrap: wrap;
}}
.bc-wordmark {{
  font-size: 18px;
  font-weight: 900;
  color: #fff;
  letter-spacing: -.5px;
}}
.bc-sub {{
  font-size: 10px;
  color: rgba(255,255,255,.55);
  text-transform: uppercase;
  letter-spacing: .8px;
}}
.hdr-divider {{ color: rgba(255,255,255,.25); font-size: 20px; }}
.hdr-title {{ font-size: 16px; font-weight: 700; color: #fff; }}
.sev-pill {{
  font-size: 11px; font-weight: 700;
  padding: 3px 10px; border-radius: 6px;
  letter-spacing: .5px; margin-left: auto;
}}
.sev-err  {{ background: rgba(239,68,68,.2);  color: #ef4444; border: 1px solid #ef4444; }}
.sev-warn {{ background: rgba(249,115,22,.2); color: #f97316; border: 1px solid #f97316; }}
.sev-ok   {{ background: rgba(34,197,94,.2);  color: #22c55e; border: 1px solid #22c55e; }}
.sev-info {{ background: rgba(96,165,250,.2); color: #60a5fa; border: 1px solid #60a5fa; }}
.breadcrumb {{
  font-size: 11px; color: rgba(255,255,255,.55);
  margin-top: 6px;
}}
.breadcrumb a {{ color: rgba(255,255,255,.7); text-decoration: none; }}
.breadcrumb a:hover {{ text-decoration: underline; }}
main {{
  max-width: 860px;
  margin: 0 auto;
  padding: 28px 24px 60px;
  width: 100%;
  flex: 1;
}}
.inc-card {{
  background: #fff;
  border: 1px solid var(--border);
  border-radius: 10px;
  padding: 28px 32px;
  box-shadow: 0 2px 8px rgba(18,47,177,.06);
}}
.inc-card h3 {{
  font-size: 18px; font-weight: 800;
  color: var(--ancla);
  margin-bottom: 16px;
  padding-bottom: 12px;
  border-bottom: 2px solid var(--senal);
}}
.inc-card h4 {{
  font-size: 14px; font-weight: 700;
  color: var(--txt);
  margin: 20px 0 8px;
}}
.inc-card h5, .inc-card h6 {{
  font-size: 13px; font-weight: 600;
  color: var(--dim);
  margin: 14px 0 6px;
}}
.inc-card p {{
  font-size: 13px; line-height: 1.65;
  color: var(--txt);
  margin-bottom: 10px;
}}
.inc-card ul, .inc-card ol {{
  font-size: 13px; line-height: 1.65;
  padding-left: 20px;
  margin-bottom: 10px;
}}
.inc-card li {{ margin-bottom: 4px; }}
.inc-card blockquote {{
  border-left: 3px solid var(--senal);
  background: rgba(18,47,177,.04);
  padding: 10px 16px;
  margin: 12px 0;
  border-radius: 0 6px 6px 0;
}}
.inc-card blockquote p {{ margin-bottom: 4px; color: var(--dim); font-style: italic; }}
.inc-card code {{
  font-family: 'Consolas', 'Cascadia Code', monospace;
  background: rgba(18,47,177,.07);
  color: #122fb1;
  padding: 1px 5px;
  border-radius: 3px;
  font-size: 12px;
}}
.inc-card pre {{
  background: #e8ebf8;
  border: 1px solid var(--border);
  border-left: 3px solid var(--ancla);
  border-radius: 6px;
  padding: 14px 16px;
  overflow-x: auto;
  margin: 12px 0;
}}
.inc-card pre code {{
  background: none;
  color: var(--txt);
  padding: 0;
  font-size: 12px;
  line-height: 1.6;
}}
.inc-card hr {{
  border: none;
  border-top: 1px solid var(--border);
  margin: 18px 0;
}}
.inc-card a {{ color: var(--ancla); }}
.meta-row {{
  display: flex; gap: 12px; flex-wrap: wrap;
  margin-bottom: 20px;
}}
.meta-chip {{
  font-size: 11px; color: var(--dim);
  background: var(--bg);
  border: 1px solid var(--border);
  border-radius: 4px;
  padding: 3px 9px;
}}
footer {{
  text-align: center;
  font-size: 11px;
  color: var(--dim);
  padding: 16px;
  border-top: 1px solid var(--border);
}}
</style>
</head>
<body>
<div class="signal-top"></div>
<header>
  <div class="hdr-row">
    <div>
      <div class="bc-wordmark">BanCoppel</div>
      <div class="bc-sub">Informix · SPE-AM-001</div>
    </div>
    <span class="hdr-divider">|</span>
    <div class="hdr-title">{inc_id_upper} · {title_short}</div>
    <span class="sev-pill sev-{sev_class}">{sev_level}</span>
  </div>
  <div class="breadcrumb">
    <a href="../index-bcop-v2.html">Portal</a> &rsaquo;
    Runbook {domain_id} &rsaquo;
    {inc_id_upper}
  </div>
</header>
<main>
  <div class="inc-card">
    <h3>{section_header_clean}</h3>
    <div class="meta-row">
      <span class="meta-chip">Dominio: {domain_id}</span>
      <span class="meta-chip">Severidad: {sev_level}</span>
      <span class="meta-chip">Fuente: 21-observability-runbook.md</span>
      <span class="meta-chip">Generado: {today}</span>
    </div>
    {body_html}
  </div>
</main>
<footer>Informix Digital Brain · BanCoppel Application Modernization · SPE-AM-001 · Accenture</footer>
</body>
</html>
'''


# ── Main ─────────────────────────────────────────────────────────────────────

def build_incident(inc_slug: str, rb_rel: str) -> bool:
    rb_path = KB / rb_rel
    if not rb_path.exists():
        print(f'  SKIP  {inc_slug} — runbook no encontrado: {rb_rel}')
        return False

    content = rb_path.read_text(encoding='utf-8', errors='replace')
    header_line, body_md = extract_section(content, inc_slug)

    if not header_line:
        print(f'  SKIP  {inc_slug} — sección no encontrada en {rb_rel}')
        return False

    # Parsear metadatos del header
    # Ej: "### INC-D05-04: Remesa internacional ..."
    inc_id_match = re.search(r'INC-(D\d{2}-\d{2,})', header_line)
    inc_id_upper = ('INC-' + inc_id_match.group(1)) if inc_id_match else inc_slug.upper()

    domain_id = re.search(r'D(\d{2})', inc_slug)
    domain_id = ('D' + domain_id.group(1)) if domain_id else 'D??'
    domain_folder_match = re.search(r'(D\d{2}-\w+)/', rb_rel)
    domain_folder = domain_folder_match.group(1) if domain_folder_match else rb_rel.split('/')[0]

    # Limpiar header para título
    section_header_clean = re.sub(r'^###\s+', '', header_line).strip()
    # Short title para el HUD (máx 60 chars)
    title_short = section_header_clean[:60] + ('…' if len(section_header_clean) > 60 else '')

    sev_level, sev_class = get_severity(header_line, body_md)
    body_html = md_to_html(body_md)
    # Fix links that were authored relative to the runbook (knowledge-base/…)
    # and point to portal/incidents/ using ../../portal/incidents/ — those 404
    # from the browser since server root is portal/.  Strip the prefix so the
    # href becomes just the filename (same directory as the generated page).
    body_html = body_html.replace('../../portal/incidents/', '')
    today = date.today().strftime('%Y-%m-%d')

    html = HTML_TEMPLATE.format(
        inc_id_upper=inc_id_upper,
        title_short=title_short,
        sev_level=sev_level,
        sev_class=sev_class,
        domain_id=domain_id,
        domain_folder=domain_folder,
        section_header_clean=section_header_clean,
        today=today,
        body_html=body_html,
    )

    out_file = OUT_DIR / (inc_slug + '.html')
    out_file.write_text(html, encoding='utf-8')
    print(f'  OK    {out_file.name}  ({sev_level})  {len(body_md):,} chars')
    return True


def main():
    print(f'Informix Incident Pages — build')
    print(f'Output: {OUT_DIR}\n')
    ok = err = 0
    for inc_slug, rb_rel in INCIDENTS:
        if build_incident(inc_slug, rb_rel):
            ok += 1
        else:
            err += 1
    print(f'\n{"OK" if err == 0 else "WARN"}  {ok} páginas generadas · {err} omitidas')


if __name__ == '__main__':
    main()

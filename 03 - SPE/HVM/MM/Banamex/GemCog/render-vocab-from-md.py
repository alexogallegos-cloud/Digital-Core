"""
render-vocab-from-md.py
Genera vocab-s500.html y vocab-s151.html leyendo directamente desde los MD.
Incluye columna Aliases (nueva), paginación 200 filas, búsqueda JS en tiempo real.
"""

import re
import json
import os

# ── Rutas ──────────────────────────────────────────────────────────────────────
BASE = os.path.dirname(os.path.abspath(__file__))
DATA = os.path.join(BASE, "data")

SOURCES = [
    {
        "sistema":    "S500",
        "md":         os.path.join(DATA, "S500", "vocab-s500.md"),
        "html":       os.path.join(DATA, "S500", "vocab-s500.html"),
        "has_alcance": True,
    },
    {
        "sistema":    "S151",
        "md":         os.path.join(DATA, "S151", "vocab-s151.md"),
        "html":       os.path.join(DATA, "S151", "vocab-s151.html"),
        "has_alcance": True,
    },
]

# ── Paleta ─────────────────────────────────────────────────────────────────────
CSS_VARS = """
  --bg:    #071c23;
  --bg2:   #0a2530;
  --panel: #0e2e3a;
  --line:  #1a4555;
  --txt:   #F0F8FA;
  --muted: #7fb8c8;
  --acc:   #6CC5D8;
  --on:    #C1272D;
  --head1: #081825;
  --head2: #0D2C3A;
  --hbar:  #C1272D;
"""

CAT_COLORS = {
    "CAMPO-DECIMAL":  "#f5b87a",
    "CAMPO-ALFA":     "#7ab8f5",
    "CAMPO-NUMERICO": "#6de8a0",
    "CAMPO-COMP":     "#c4a8f5",
    "ENTIDAD":        "#f57ab8",
    "TRANSACCION":    "#7af5f5",
    "IDENTIFICACION": "#b8f57a",
    "FINANCIERO":     "#f5e07a",
    "CONTROL":        "#9ab8f5",
    "TECNICO":        "#f57a7a",
    "TEMPORAL":       "#f5c87a",
    "ACCION":         "#f5d07a",
    "ESTADO":         "#a8f5c4",
    "REFERENCIA":     "#d8b4f5",
    "CALCULO":        "#f5a8a8",
    "PARAMETRO":      "#a8d8f5",
}
DEFAULT_COLOR = "#7fb8c8"

# ── Parser ─────────────────────────────────────────────────────────────────────
def parse_vocab_md(path, has_alcance=False):
    entries = []
    with open(path, encoding="utf-8", errors="replace") as f:
        for raw in f:
            line = raw.rstrip()
            if not re.match(r"^\| \d", line):
                continue
            cols = [c.strip() for c in line.split("|")]
            # cols[0] = '' antes del primer |, cols[-1] = '' después del último |
            cells = cols[1:-1]
            if len(cells) < 8:
                continue
            try:
                num  = int(cells[0])
                term = cells[1].strip("`").strip()
                freq = cells[2]
                cat  = cells[3]
                conf = cells[4]
                evid = cells[5]
                sig  = cells[6]
                if has_alcance:
                    alcance = cells[7]          if len(cells) > 7  else "—"
                    prog    = cells[8]          if len(cells) > 8  else "—"
                    aliases = cells[9]          if len(cells) > 9  else "—"
                else:
                    alcance = ""
                    prog    = cells[7]          if len(cells) > 7  else "—"
                    aliases = cells[8]          if len(cells) > 8  else "—"
                entries.append({
                    "n": num, "t": term, "f": freq, "c": cat,
                    "co": conf, "e": evid, "s": sig,
                    "al": alcance, "p": prog, "a": aliases,
                })
            except Exception:
                continue
    return entries


# ── Generador de CSS de categorías ────────────────────────────────────────────
def cat_css():
    lines = []
    for cat, color in CAT_COLORS.items():
        sel = cat.replace("-", "_")
        lines.append(f".cat-{sel} {{ color: {color}; border-color: {color}44; }}")
    return "\n    ".join(lines)


# ── JS de colores de categoría ─────────────────────────────────────────────────
def cat_js():
    pairs = {k: v for k, v in CAT_COLORS.items()}
    return json.dumps(pairs, ensure_ascii=False)


# ── HTML template ──────────────────────────────────────────────────────────────
def build_html(sistema, entries, has_alcance):
    total = len(entries)
    with_aliases = sum(1 for e in entries if e["a"] and e["a"] not in ("—", "", "-"))
    with_prog    = sum(1 for e in entries if e["p"] and e["p"] not in ("—", "", "-"))
    pct_aliases  = round(with_aliases / total * 100, 1) if total else 0

    # Conjunto de categorías presentes
    cats = sorted(set(e["c"] for e in entries if e["c"]))

    # Opciones del select de categorías
    cat_options = "\n".join(
        f'<option value="{c}">{c}</option>' for c in cats
    )

    # JSON comprimido con los datos (solo los campos necesarios)
    data_json = json.dumps(entries, ensure_ascii=False, separators=(",", ":"))

    alcance_th  = "<th>Alcance</th>" if has_alcance else ""
    has_alcance_js = "true" if has_alcance else "false"

    html = f"""<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Vocabulario {sistema} · GemCog Banamex</title>
  <style>
    :root {{{CSS_VARS}}}
    *, *::before, *::after {{ box-sizing: border-box; margin: 0; padding: 0; }}
    body {{ background: var(--bg); color: var(--txt); font-family: 'Segoe UI', system-ui, sans-serif; font-size: 13px; }}

    /* ── Header ── */
    header {{ background: var(--head1); border-bottom: 3px solid var(--hbar); padding: 18px 24px 14px; }}
    header h1 {{ font-size: 1.35rem; font-weight: 700; color: var(--acc); letter-spacing: .5px; }}
    header h1 span.sys {{ color: var(--on); }}
    .stats {{ margin: 6px 0 12px; color: var(--muted); font-size: .82rem; }}
    .stats strong {{ color: var(--acc); }}

    /* ── Controles ── */
    .controls {{ display: flex; gap: 10px; flex-wrap: wrap; align-items: center; }}
    .controls input, .controls select {{
      background: var(--panel); border: 1px solid var(--line); color: var(--txt);
      padding: 6px 12px; border-radius: 6px; font-size: .85rem; outline: none;
    }}
    .controls input {{ flex: 1; min-width: 220px; max-width: 420px; }}
    .controls input:focus, .controls select:focus {{ border-color: var(--acc); }}
    .controls select {{ cursor: pointer; }}
    .count-badge {{
      background: var(--panel); border: 1px solid var(--line); border-radius: 6px;
      padding: 5px 12px; font-size: .82rem; color: var(--muted); white-space: nowrap;
    }}
    .count-badge strong {{ color: var(--acc); }}

    /* ── Pager ── */
    .pager {{
      display: flex; align-items: center; gap: 8px; padding: 10px 24px;
      background: var(--head2); border-bottom: 1px solid var(--line);
      font-size: .82rem; color: var(--muted);
    }}
    .pager button {{
      background: var(--panel); border: 1px solid var(--line); color: var(--txt);
      padding: 3px 12px; border-radius: 4px; cursor: pointer; font-size: .82rem;
    }}
    .pager button:disabled {{ opacity: .35; cursor: default; }}
    .pager button:not(:disabled):hover {{ border-color: var(--acc); color: var(--acc); }}
    .pager span.info {{ color: var(--txt); font-weight: 600; }}

    /* ── Tabla ── */
    .table-wrap {{ overflow-x: auto; padding: 0 0 40px; }}
    table {{ width: 100%; border-collapse: collapse; table-layout: fixed; }}
    colgroup col {{ }}
    thead tr {{ background: var(--head2); }}
    th {{
      text-align: left; padding: 9px 10px; font-size: .78rem; font-weight: 700;
      color: var(--muted); text-transform: uppercase; letter-spacing: .5px;
      border-bottom: 2px solid var(--line); position: sticky; top: 0;
      background: var(--head2); z-index: 2;
    }}
    td {{ padding: 7px 10px; border-bottom: 1px solid var(--line); vertical-align: top; }}
    tr:hover td {{ background: var(--panel); }}
    tr:nth-child(even) td {{ background: var(--bg2); }}
    tr:nth-child(even):hover td {{ background: var(--panel); }}

    /* Anchos de columna */
    .col-num   {{ width: 52px; color: var(--muted); text-align: right; font-size: .78rem; }}
    .col-term  {{ width: 190px; font-family: 'Cascadia Code', 'Consolas', monospace; font-size: .82rem; color: var(--acc); word-break: break-all; }}
    .col-freq  {{ width: 58px; text-align: right; color: var(--muted); }}
    .col-cat   {{ width: 148px; }}
    .col-conf  {{ width: 64px; color: var(--muted); font-size: .78rem; }}
    .col-evid  {{ width: 110px; color: var(--muted); font-size: .78rem; }}
    .col-sig   {{ min-width: 260px; line-height: 1.4; font-size: .82rem; }}
    .col-alcance {{ width: 140px; font-size: .78rem; color: var(--muted); }}
    .col-prog  {{ width: 180px; font-size: .78rem; color: var(--muted); word-break: break-word; }}
    .col-aliases {{ width: 200px; }}

    /* Categoría badge */
    .cat-badge {{
      display: inline-block; padding: 2px 7px; border-radius: 10px; font-size: .73rem;
      font-weight: 600; border: 1px solid; background: transparent;
      white-space: nowrap;
    }}
    {cat_css()}

    /* Alias pills */
    .alias-pills {{ display: flex; flex-wrap: wrap; gap: 4px; }}
    .alias-pill {{
      background: #6CC5D81a; border: 1px solid #6CC5D855; color: var(--acc);
      padding: 1px 7px; border-radius: 10px; font-size: .72rem; white-space: nowrap;
    }}

    /* Muted dash */
    .dash {{ color: var(--line); }}

    /* Highlight search */
    mark {{ background: #6CC5D833; color: var(--acc); border-radius: 2px; }}

    /* Empty state */
    .empty {{ text-align: center; padding: 60px; color: var(--muted); font-size: 1rem; }}
  </style>
</head>
<body>

<header>
  <h1>Vocabulario <span class="sys">{sistema}</span> · GemCog Banamex</h1>
  <div class="stats">
    <strong>{total:,}</strong> términos totales ·
    <strong>{with_aliases:,}</strong> con Aliases (<strong>{pct_aliases}%</strong>) ·
    <strong>{with_prog:,}</strong> con Programas
  </div>
  <div class="controls">
    <input id="search" type="search" placeholder="Buscar término, significado o alias..." autocomplete="off" spellcheck="false">
    <select id="cat-filter">
      <option value="">Todas las categorías</option>
      {cat_options}
    </select>
    <div class="count-badge"><strong id="visible-count">{total:,}</strong> mostrados</div>
  </div>
</header>

<div class="pager">
  <button id="btn-prev" disabled>&#8592; Anterior</button>
  <span class="info" id="pager-info">Página 1</span>
  <button id="btn-next">Siguiente &#8594;</button>
  <span style="margin-left:8px">· 200 por página</span>
</div>

<div class="table-wrap">
  <table id="vocab-table">
    <colgroup>
      <col class="col-num">
      <col class="col-term">
      <col class="col-freq">
      <col class="col-cat">
      <col class="col-conf">
      <col class="col-evid">
      <col class="col-sig">
      {'<col class="col-alcance">' if has_alcance else ''}
      <col class="col-prog">
      <col class="col-aliases">
    </colgroup>
    <thead>
      <tr>
        <th class="col-num">#</th>
        <th class="col-term">Término</th>
        <th class="col-freq">Frec</th>
        <th class="col-cat">Categoría</th>
        <th class="col-conf">Confianza</th>
        <th class="col-evid">Evidencia</th>
        <th class="col-sig">Significado</th>
        {alcance_th}
        <th class="col-prog">Programas</th>
        <th class="col-aliases">Aliases</th>
      </tr>
    </thead>
    <tbody id="rows"></tbody>
  </table>
</div>

<script>
const DATA = {data_json};
const HAS_ALCANCE = {has_alcance_js};
const PAGE_SIZE = 200;
const CAT_COLORS = {cat_js()};

let filtered = DATA.slice();
let page = 0;

function catColor(cat) {{
  return CAT_COLORS[cat] || '#7fb8c8';
}}

function esc(s) {{
  return String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
}}

function highlight(text, q) {{
  if (!q) return esc(text);
  const re = new RegExp(q.replace(/[.*+?^${{}}()|[\\]\\\\]/g, '\\\\$&'), 'gi');
  return esc(text).replace(re, m => `<mark>${{m}}</mark>`);
}}

function renderAliases(raw, q) {{
  if (!raw || raw === '—' || raw === '-' || raw.trim() === '') {{
    return '<span class="dash">—</span>';
  }}
  const parts = raw.split(/[·,;]/).map(s => s.trim()).filter(Boolean);
  return '<div class="alias-pills">' + parts.map(p =>
    `<span class="alias-pill">${{highlight(p, q)}}</span>`
  ).join('') + '</div>';
}}

function renderProg(raw) {{
  if (!raw || raw === '—' || raw === '-' || raw.trim() === '') {{
    return '<span class="dash">—</span>';
  }}
  return esc(raw);
}}

function catClass(cat) {{
  return 'cat-' + cat.replace(/-/g, '_');
}}

function renderRow(e, q) {{
  const color = catColor(e.c);
  const alcanceTd = HAS_ALCANCE
    ? `<td class="col-alcance">${{esc(e.al || '—')}}</td>`
    : '';
  return `<tr>
    <td class="col-num">${{e.n}}</td>
    <td class="col-term">${{highlight(e.t, q)}}</td>
    <td class="col-freq">${{esc(e.f)}}</td>
    <td class="col-cat"><span class="cat-badge ${{catClass(e.c)}}" style="color:${{color}};border-color:${{color}}44">${{esc(e.c)}}</span></td>
    <td class="col-conf">${{esc(e.co)}}</td>
    <td class="col-evid">${{esc(e.e)}}</td>
    <td class="col-sig">${{highlight(e.s, q)}}</td>
    ${{alcanceTd}}
    <td class="col-prog">${{renderProg(e.p)}}</td>
    <td class="col-aliases">${{renderAliases(e.a, q)}}</td>
  </tr>`;
}}

function applyFilters() {{
  const q = document.getElementById('search').value.trim().toLowerCase();
  const cat = document.getElementById('cat-filter').value;
  filtered = DATA.filter(e => {{
    if (cat && e.c !== cat) return false;
    if (!q) return true;
    const inTerm = e.t.toLowerCase().includes(q);
    const inSig  = e.s.toLowerCase().includes(q);
    const inAlias = e.a && e.a.toLowerCase().includes(q);
    return inTerm || inSig || inAlias;
  }});
  page = 0;
  render();
}}

function render() {{
  const q = document.getElementById('search').value.trim().toLowerCase();
  const total = filtered.length;
  const totalPages = Math.max(1, Math.ceil(total / PAGE_SIZE));
  const start = page * PAGE_SIZE;
  const slice = filtered.slice(start, start + PAGE_SIZE);

  const tbody = document.getElementById('rows');
  if (slice.length === 0) {{
    tbody.innerHTML = '<tr><td colspan="20" class="empty">Sin resultados para esta búsqueda.</td></tr>';
  }} else {{
    tbody.innerHTML = slice.map(e => renderRow(e, q)).join('');
  }}

  document.getElementById('visible-count').textContent = total.toLocaleString('es-MX');
  document.getElementById('pager-info').textContent =
    `Página ${{page + 1}} de ${{totalPages}} · ${{start + 1}}–${{Math.min(start + PAGE_SIZE, total)}} de ${{total.toLocaleString('es-MX')}}`;
  document.getElementById('btn-prev').disabled = page === 0;
  document.getElementById('btn-next').disabled = page >= totalPages - 1;
}}

document.getElementById('search').addEventListener('input', applyFilters);
document.getElementById('cat-filter').addEventListener('change', applyFilters);
document.getElementById('btn-prev').addEventListener('click', () => {{ page--; render(); window.scrollTo(0,0); }});
document.getElementById('btn-next').addEventListener('click', () => {{ page++; render(); window.scrollTo(0,0); }});

// Render inicial
render();
</script>
</body>
</html>
"""
    return html


# ── Main ───────────────────────────────────────────────────────────────────────
def main():
    for src in SOURCES:
        sistema    = src["sistema"]
        md_path    = src["md"]
        html_path  = src["html"]
        has_alcance = src["has_alcance"]

        print(f"\n{'='*60}")
        print(f"Procesando {sistema} ...")
        print(f"  MD  : {md_path}")
        print(f"  HTML: {html_path}")

        entries = parse_vocab_md(md_path, has_alcance=has_alcance)
        total   = len(entries)
        with_aliases = sum(1 for e in entries if e["a"] and e["a"] not in ("—", "", "-"))
        with_prog    = sum(1 for e in entries if e["p"] and e["p"] not in ("—", "", "-"))

        print(f"  Entradas parseadas : {total:,}")
        print(f"  Con Aliases != '—' : {with_aliases:,}  ({round(with_aliases/total*100,1) if total else 0}%)")
        print(f"  Con Programas != '—': {with_prog:,}")

        html = build_html(sistema, entries, has_alcance)

        with open(html_path, "w", encoding="utf-8") as f:
            f.write(html)

        size_kb = os.path.getsize(html_path) / 1024
        print(f"  HTML generado      : {size_kb:,.1f} KB")

    print(f"\n{'='*60}")
    print("Listo.")


if __name__ == "__main__":
    main()

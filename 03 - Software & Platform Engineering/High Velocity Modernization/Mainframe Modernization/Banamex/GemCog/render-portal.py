#!/usr/bin/env python3
"""
Banamex Gemelo Cognitivo — Portal HTML (Capas 1-4)
Lee todos los JSONs de data/ → genera portal/sistemas.html
index.html = landing page (no tocar con este script)

Portal de navegación de los dos gemelos (S500 y S151) con:
  - Ficha del sistema (meta, LOC, objetos, dominios)
  - Capa 1: Vocabulario (top 20 términos)
  - Capa 2: Almas (bus factor por dominio, top autores)
  - Capa 3: Biografía (línea de tiempo de hitos)
  - Capa 4: Intención (dominios, aristas del call graph)
  - Enlace a dependency-graph.html (render_graph.py output)

Uso:
  python render-portal.py
"""

import json
from pathlib import Path
from collections import Counter, defaultdict

DATA_DIR  = Path(__file__).parent / "data"
PORTAL_DIR = Path(__file__).parent / "portal"

SISTEMAS = ["S500", "S151"]

SYSTEM_LABELS = {
    "S500": ("Sistema de Cargos y Abonos de Cuentas de Cheque",
             "CAPTACION", "#A100FF"),
    "S151": ("Sistema de Movimientos Contables (General Ledger)",
             "CONTABILIDAD", "#6366f1"),
}

def load_json(path: Path) -> dict | None:
    if not path.exists():
        return None
    with open(path, encoding="utf-8") as f:
        return json.load(f)


def system_card(sistema: str) -> str:
    label, context, color = SYSTEM_LABELS.get(sistema, (sistema, "", "#555"))
    gemelo = load_json(DATA_DIR / sistema / f"gemelo-{sistema.lower()}.json")
    vocab  = load_json(DATA_DIR / sistema / f"vocab-{sistema.lower()}.json")
    souls  = load_json(DATA_DIR / sistema / f"souls-{sistema.lower()}.json")

    if not gemelo:
        return f'<div class="sys-card"><h2>{sistema}</h2><p>Ejecuta extract.py primero</p></div>'

    meta = gemelo["meta"]
    objetos = gemelo["objetos"]
    hitos = gemelo.get("hitos", [])

    # ─ Resumen de tipos ─
    by_type = Counter(o["tipo"] for o in objetos)
    type_chips = "".join(
        f'<span class="chip">{t.upper()} {n}</span>'
        for t, n in sorted(by_type.items(), key=lambda x: -x[1])
    )

    # ─ Dominios ─
    by_domain = Counter(o["dominio"] for o in objetos)
    domain_rows = "".join(
        f'<tr><td>{d}</td><td>{n}</td></tr>'
        for d, n in by_domain.most_common()
    )

    # ─ Vocabulario top 10 ─
    vocab_rows = ""
    if vocab:
        for v in vocab["vocabulario"][:10]:
            aliases = ", ".join(v["aliases"]) or "—"
            vocab_rows += (f'<tr><td><code>{v["termino_canonico"]}</code></td>'
                           f'<td>{v["frecuencia"]}</td>'
                           f'<td>{v["categoria"]}</td>'
                           f'<td style="font-size:0.8em;color:#94a3b8">{aliases}</td></tr>')
    else:
        vocab_rows = '<tr><td colspan="4">Ejecuta build-vocab.py</td></tr>'

    # ─ Almas ─
    if souls:
        sm = souls["meta"]
        orphan_pct = (sm["programas_huerfanos"] / sm["total_programas"] * 100
                      if sm["total_programas"] else 0)
        bf = sm["bus_factor_global"]
        bf_color = ("#ef4444" if bf < 2 else "#f97316" if bf < 4
                    else "#eab308" if bf < 6 else "#22c55e")
        def _dom_row(d):
            bf_c = _bf_color(d["bus_factor"])
            icon = "🔴" if d["riesgo"] == "alto" else "🟡" if d["riesgo"] == "medio" else "🟢"
            return (f'<tr><td>{d["dominio"]}</td>'
                    f'<td style="color:{bf_c};font-weight:bold">{d["bus_factor"]:.1f}</td>'
                    f'<td>{icon} {d["riesgo"].upper()}</td></tr>')
        dom_bf_rows = "".join(
            _dom_row(d)
            for d in sorted(souls["dominios"], key=lambda x: x["bus_factor"])[:6]
        )
        almas_html = f"""
        <div class="section">
          <h3>Capa 2 · Almas</h3>
          <div class="kpi-row">
            <div class="kpi"><span class="kv">{sm['total_autores']}</span>
              <span class="kl">Autores</span></div>
            <div class="kpi"><span class="kv" style="color:{bf_color}">{bf:.1f}</span>
              <span class="kl">Bus Factor global</span></div>
            <div class="kpi"><span class="kv" style="color:{'#ef4444' if orphan_pct>30 else '#eab308'}">{orphan_pct:.0f}%</span>
              <span class="kl">Huérfanos</span></div>
          </div>
          <table><thead><tr><th>Dominio</th><th>BF</th><th>Riesgo</th></tr></thead>
          <tbody>{dom_bf_rows}</tbody></table>
          <a href="../data/{sistema}/souls-{sistema.lower()}.html"
             target="_blank" class="link-btn">Ver Mapa de las Almas completo →</a>
        </div>"""
    else:
        almas_html = """<div class="section"><h3>Capa 2 · Almas</h3>
          <p class="dimmed">Ejecuta build-souls.py</p></div>"""

    # ─ Hitos timeline (top 8) ─
    timeline_items = ""
    seen_years = set()
    for h in sorted(hitos, key=lambda x: x["anio"]):
        if h["anio"] in seen_years:
            continue
        seen_years.add(h["anio"])
        if len(seen_years) > 8:
            break
        timeline_items += (
            f'<div class="timeline-item">'
            f'<span class="year">{h["anio"]}</span>'
            f'<span class="desc">{h["titulo"][:60]}</span>'
            f'</div>'
        )

    # ─ Top 10 programas por LOC ─
    top_pgm_rows = "".join(
        f'<tr><td><strong>{o["id"]}</strong></td><td>{o["tipo"].upper()}</td>'
        f'<td>{o["loc"]:,}</td><td>{o["dominio"]}</td></tr>'
        for o in sorted(objetos, key=lambda x: -x["loc"])[:10]
    )

    dep_graph_path = DATA_DIR / sistema / f"dependency-graph-{sistema.lower()}.json"
    dep_link = (f'<a href="../data/{sistema}/dependency-graph-{sistema.lower()}.json"'
                f' target="_blank" class="link-btn">Descargar dependency-graph.json →</a>'
                if dep_graph_path.exists() else "")

    return f"""
<div class="sys-card" style="--accent:{color}">
  <div class="sys-header">
    <div>
      <div class="sys-id">{sistema}</div>
      <div class="sys-name">{label}</div>
      <div class="sys-context" style="color:{color}">{context}</div>
    </div>
  </div>

  <div class="meta-strip">
    <div class="kpi"><span class="kv">{meta['objetos']}</span>
      <span class="kl">Objetos</span></div>
    <div class="kpi"><span class="kv">{meta['loc_total']:,}</span>
      <span class="kl">LOC Total</span></div>
    <div class="kpi"><span class="kv">{len(by_domain)}</span>
      <span class="kl">Dominios</span></div>
    <div class="kpi"><span class="kv">{len(gemelo.get('callgraph',[]))}</span>
      <span class="kl">Aristas</span></div>
  </div>

  <div class="chips-row">{type_chips}</div>

  <div class="two-col">
    <div>
      <!-- Capa 1 -->
      <div class="section">
        <h3>Capa 1 · Lenguaje (top términos)</h3>
        <table>
          <thead><tr><th>Término</th><th>Freq</th><th>Categoría</th><th>Aliases</th></tr></thead>
          <tbody>{vocab_rows}</tbody>
        </table>
      </div>

      <!-- Capa 3 -->
      <div class="section">
        <h3>Capa 3 · Biografía (hitos detectados)</h3>
        <div class="timeline">{timeline_items or '<span class="dimmed">Sin hitos con año detectado</span>'}</div>
      </div>
    </div>

    <div>
      {almas_html}

      <!-- Capa 4 -->
      <div class="section">
        <h3>Capa 4 · Intención — Dominios</h3>
        <table>
          <thead><tr><th>Dominio</th><th># Pgms</th></tr></thead>
          <tbody>{domain_rows}</tbody>
        </table>
        {dep_link}
      </div>

      <!-- Top programas -->
      <div class="section">
        <h3>Top 10 por LOC</h3>
        <table>
          <thead><tr><th>Programa</th><th>Tipo</th><th>LOC</th><th>Dominio</th></tr></thead>
          <tbody>{top_pgm_rows}</tbody>
        </table>
      </div>
    </div>
  </div>
</div>"""


def _bf_color(bf: float) -> str:
    if bf < 2:   return "#ef4444"
    if bf < 4:   return "#f97316"
    if bf < 6:   return "#eab308"
    return "#22c55e"


def render_portal() -> None:
    PORTAL_DIR.mkdir(parents=True, exist_ok=True)

    cards_html = ""
    for s in SISTEMAS:
        print(f"  Cargando {s}...")
        cards_html += system_card(s)

    html = f"""<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<title>Banamex — Gemelo Cognitivo del Sistema</title>
<style>
  * {{ box-sizing:border-box; margin:0; padding:0; }}
  body {{ background:#0a0a14; color:#e2e8f0;
          font-family:'Segoe UI',system-ui,sans-serif; min-height:100vh; }}

  header {{ background:linear-gradient(135deg,#0f0f1a,#1a1a2e);
            border-bottom:2px solid #A100FF; padding:28px 40px; }}
  header h1 {{ font-size:1.8em; font-weight:700; color:#fff; }}
  header .sub {{ color:#94a3b8; font-size:0.9em; margin-top:6px; }}
  header .brand {{ color:#A100FF; }}

  .method-strip {{ background:#111827; border-bottom:1px solid #1e293b;
                   padding:10px 40px; font-size:0.78em; color:#6b7280; }}
  .method-strip a {{ color:#7c3aed; text-decoration:none; }}

  main {{ padding:32px 40px; max-width:1600px; margin:0 auto; }}

  .sys-card {{ background:#111827; border:1px solid #1e293b; border-radius:16px;
               margin-bottom:32px; overflow:hidden;
               border-top:3px solid var(--accent,#A100FF); }}
  .sys-header {{ background:#0f0f1a; padding:20px 24px;
                 display:flex; justify-content:space-between; align-items:flex-start; }}
  .sys-id {{ font-size:2em; font-weight:800; color:#fff; }}
  .sys-name {{ font-size:0.9em; color:#94a3b8; margin-top:4px; }}
  .sys-context {{ font-size:0.8em; font-weight:600; margin-top:2px; }}

  .meta-strip {{ display:flex; gap:0; background:#0f1929; border-bottom:1px solid #1e293b; }}
  .kpi {{ padding:14px 24px; border-right:1px solid #1e293b; }}
  .kpi:last-child {{ border:none; }}
  .kv {{ display:block; font-size:1.6em; font-weight:700; color:#A100FF; }}
  .kl {{ display:block; font-size:0.7em; color:#6b7280; margin-top:2px; }}

  .kpi-row {{ display:flex; gap:12px; margin-bottom:10px; }}
  .kpi-row .kpi {{ background:#0f0f1a; border-radius:8px; padding:10px 16px; flex:1; border:none; }}

  .chips-row {{ padding:12px 24px; background:#0d1117; display:flex; gap:8px; flex-wrap:wrap; }}
  .chip {{ background:#1e293b; color:#94a3b8; padding:3px 10px; border-radius:12px;
           font-size:0.78em; font-weight:600; }}

  .two-col {{ display:grid; grid-template-columns:1fr 1fr; gap:24px; padding:20px 24px; }}
  @media(max-width:1024px) {{ .two-col {{ grid-template-columns:1fr; }} }}

  .section {{ margin-bottom:20px; }}
  .section h3 {{ font-size:0.85em; color:#c4b5fd; margin-bottom:10px;
                 text-transform:uppercase; letter-spacing:0.05em; }}
  table {{ width:100%; border-collapse:collapse; font-size:0.82em; }}
  th {{ background:#0f0f1a; color:#6b7280; padding:5px 10px; text-align:left;
        font-weight:500; font-size:0.78em; text-transform:uppercase; }}
  td {{ padding:5px 10px; border-bottom:1px solid #1e293b; }}
  tr:last-child td {{ border:none; }}
  code {{ background:#1e293b; padding:1px 5px; border-radius:3px;
          font-size:0.85em; color:#c4b5fd; }}

  .timeline {{ display:flex; flex-direction:column; gap:6px; }}
  .timeline-item {{ display:flex; gap:12px; align-items:flex-start; font-size:0.82em; }}
  .year {{ background:#4c1d95; color:#c4b5fd; padding:2px 8px;
           border-radius:4px; min-width:44px; text-align:center; font-weight:700; }}
  .desc {{ color:#94a3b8; line-height:1.4; }}

  .link-btn {{ display:inline-block; margin-top:10px; padding:6px 14px;
               background:#1e293b; color:#c4b5fd; border-radius:6px;
               font-size:0.8em; text-decoration:none; }}
  .link-btn:hover {{ background:#374151; }}
  .dimmed {{ color:#4b5563; font-size:0.85em; font-style:italic; }}

  footer {{ padding:20px 40px; color:#374151; font-size:0.75em;
            border-top:1px solid #111827; text-align:center; }}
  .brand-f {{ color:#A100FF; font-weight:700; }}
</style>
</head>
<body>

<header>
  <h1>Gemelo Cognitivo del Sistema</h1>
  <div class="sub">
    <span class="brand">Banamex · Modernización Mainframe Unisys ClearPath MCP</span> ·
    S500 Cargos/Abonos + S151 Movimientos Contables
  </div>
</header>

<div class="method-strip">
  Método:
  <a href="../../metodologia-gemelo-cognitivo.md" target="_blank">
    HVM-wide · Gemelo Cognitivo del Sistema v2.1</a> ·
  Columna COBOL/ALGOL/DASDL/WFL (Unisys MCP) · Capas 1–4 AS-IS ·
  Hereda de instancia BanCoppel (BCOPCore) · Digital Core S&PE · Banamex SPE-MM-001/002
</div>

<main>
  {cards_html}
</main>

<footer>
  <span class="brand-f">Banamex GemCog</span> ·
  Gemelo Cognitivo del Sistema · Capas 1–4 ·
  Instancia: Unisys ClearPath MCP · Columna COBOL del método HVM-wide
</footer>

</body>
</html>"""

    out = PORTAL_DIR / "sistemas.html"
    out.write_text(html, encoding="utf-8")
    print(f"\n  [OUTPUT] {out}")
    print(f"\n  Para abrir:")
    print(f"  python -m http.server --directory \"{PORTAL_DIR.parent}\" 8080")
    print(f"  → http://localhost:8080/portal/sistemas.html")


def main():
    print("\nBanamex Gemelo Cognitivo — Portal HTML")
    render_portal()


if __name__ == "__main__":
    main()
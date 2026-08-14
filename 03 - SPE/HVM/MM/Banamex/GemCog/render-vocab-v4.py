#!/usr/bin/env python3
"""
Genera vocab-{sistema}-v4.html desde vocab-{sistema}-v4.json.
Schema v4.0: 18 campos + enrichments_regulatorios de SMEs.

Uso:
  python render-vocab-v4.py S500
  python render-vocab-v4.py S151
  python render-vocab-v4.py S500 S151
"""

import json, sys, html as html_mod
from pathlib import Path
from collections import Counter

DATA_DIR = Path(__file__).parent / "data"

CAT_COLORS = {
    "IDENTIFICACION": ("#0d1a2e", "#7ab8f5"),
    "ENTIDAD":        ("#1a0d2e", "#c4a8f5"),
    "TRANSACCION":    ("#0d2e1a", "#6de8a0"),
    "FINANCIERO":     ("#2e1a0d", "#f5b87a"),
    "CONTABILIDAD":   ("#2e0d1a", "#f57ab8"),
    "CONTROL":        ("#1a2e0d", "#b8f57a"),
    "TECNICO":        ("#1a1a2e", "#9ab8f5"),
    "TEMPORAL":       ("#2e2a0d", "#f5e07a"),
    "CLASIFICACION":  ("#0d2e2e", "#7af5f5"),
    "DATOS":          ("#2e1a1a", "#f57a7a"),
    "ORGANIZACION":   ("#1a2e1a", "#7af5a0"),
    "INSTRUMENTO":    ("#2e2e0d", "#f5f07a"),
    "CUENTA":         ("#0d1f33", "#7ab8f5"),
    "PARAMETRO":      ("#1f1a0d", "#f5c87a"),
    "INTERFACE":      ("#0d2a2e", "#7ae8f5"),
}

CONF_STYLE = {
    "alta":  ("background:#0a1f0a", "color:#4ade80", "border:1px solid #1a5a1a"),
    "media": ("background:#2a1800", "color:#fb923c", "border:1px solid #5a3a0a"),
    "baja":  ("background:#2a0808", "color:#f87171", "border:1px solid #5a1a1a"),
}

REG_COLORS = {
    "CNBV":       ("#003366", "#4db8ff"),
    "CNBV-PLD":   ("#1a0044", "#b388ff"),
    "Banxico":     ("#003300", "#66ff66"),
    "SAT":        ("#330000", "#ff6666"),
    "CONDUSEF":   ("#332200", "#ffaa44"),
    "IPAB":       ("#222200", "#eeee44"),
    "TESOFE":     ("#001133", "#44aaff"),
    "INEGI":      ("#002200", "#44dd88"),
}

CAP_COLORS = {
    "Clientes y Cuentas":             ("#0d1f33", "#7ab8f5"),
    "Movimientos y Transacciones":    ("#0d2e1a", "#6de8a0"),
    "Promedios y Saldos":             ("#2e1a0d", "#f5b87a"),
    "Comisiones y Tarifas":           ("#2e0d1a", "#f57ab8"),
    "Contabilidad y Asientos GL":     ("#1a0d2e", "#c4a8f5"),
    "Intereses y Rendimientos":       ("#2e2a0d", "#f5e07a"),
    "Crédito y Pagos Domiciliados":   ("#2e2e0d", "#f5f07a"),
    "Operación Online":               ("#0d2e2e", "#7af5f5"),
    "Control y Parametría":           ("#1a1a2e", "#9ab8f5"),
    "S151 — Contabilidad General":    ("#1f0d2e", "#d4a8f5"),
}

CSS = """
*{box-sizing:border-box;margin:0;padding:0}
body{background:#0a0c10;color:#c9d1d9;font-family:'Segoe UI',system-ui,sans-serif;font-size:13px}
header{background:#141921;border-bottom:1px solid #1e3050;padding:16px 24px;display:flex;align-items:center;gap:16px}
header img{height:36px;opacity:.85}
header h1{font-size:18px;font-weight:700;color:#e6edf3}
header .sub{font-size:11px;color:#7d8590;margin-top:3px}
.stats{display:flex;flex-wrap:wrap;gap:12px;padding:16px 24px;background:#0e1218;border-bottom:1px solid #1e2d40}
.sc{display:flex;align-items:center;gap:8px;background:#141921;border:1px solid #1e3050;border-radius:8px;padding:10px 16px;min-width:110px}
.sc .num{font-size:22px;font-weight:700;color:#e6edf3}
.sc .lbl{font-size:11px;color:#7d8590;line-height:1.4}
.sc .sub2{font-size:10px;color:#555;margin-top:2px}
.dot{width:10px;height:10px;border-radius:50%;flex-shrink:0}
.dot-g{background:#4ade80}.dot-o{background:#fb923c}.dot-r{background:#f87171}.dot-b{background:#7ab8f5}
.fbar{padding:12px 24px;background:#0e1218;border-bottom:1px solid #1e2d40;display:flex;flex-wrap:wrap;gap:8px;align-items:center}
.flbl{font-size:10px;color:#555;text-transform:uppercase;letter-spacing:.05em;margin-right:2px;margin-left:8px}
.ftag{background:#141921;border:1px solid #1e3050;border-radius:12px;padding:3px 10px;font-size:11px;color:#7d8590;cursor:pointer;transition:.15s}
.ftag:hover{border-color:#3d6fa0;color:#c9d1d9}
.ftag.active{background:#1a3a6a;border-color:#3d6fa0;color:#7ab8f5;font-weight:600}
#srch{background:#141921;border:1px solid #1e3050;border-radius:8px;padding:6px 12px;color:#c9d1d9;font-size:12px;width:240px;outline:none}
#srch:focus{border-color:#3d6fa0}
.wrap{padding:0 24px 24px}
.tbar{padding:8px 0;font-size:11px;color:#555;display:flex;justify-content:space-between}
table{width:100%;border-collapse:collapse;table-layout:fixed}
thead tr{background:#141921;border-bottom:2px solid #1e3050}
th{padding:8px 10px;text-align:left;font-size:10px;color:#7d8590;text-transform:uppercase;letter-spacing:.05em;cursor:pointer;user-select:none;white-space:nowrap}
th:hover{color:#c9d1d9}
th.asc::after{content:" ↑"}th.desc::after{content:" ↓"}
tbody tr{border-bottom:1px solid #161b22;transition:.1s;cursor:pointer}
tbody tr:hover{background:#0f1a2a}
tbody tr.expanded{background:#0a1628}
td{padding:7px 10px;vertical-align:middle}
.td-t{font-family:'Cascadia Code','Consolas',monospace;font-size:12px;color:#79c0ff;font-weight:600;max-width:200px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}
.td-sig{color:#8b949e;font-size:11px;max-width:260px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}
.td-al{max-width:160px;overflow:hidden}
.td-fr{text-align:right;font-family:monospace;color:#7d8590}
.tag{border-radius:10px;padding:2px 8px;font-size:10px;font-weight:600;white-space:nowrap;display:inline-block}
.ap{background:#1a2a1a;color:#7af57a;border-radius:6px;padding:1px 5px;font-size:10px;margin:1px;display:inline-block;font-family:monospace}
.reg-pill{border-radius:10px;padding:2px 7px;font-size:10px;font-weight:600;margin:1px;display:inline-block}
.sme-badge{background:#1a1a3a;color:#9ab8f5;border:1px solid #2a3060;border-radius:10px;padding:2px 7px;font-size:10px}
.fml-badge{background:#1a2a0a;color:#9af57a;border:1px solid #2a5010;border-radius:10px;padding:2px 7px;font-size:10px}
.pend-badge{background:#2a1a00;color:#f5b87a;border:1px solid #5a3a00;border-radius:10px;padding:2px 7px;font-size:10px}
/* Detail panel */
.detail-row{display:none;background:#080e18}
.detail-row.show{display:table-row}
.detail-cell{padding:16px 24px;border-bottom:2px solid #1e3050}
.detail-grid{display:grid;grid-template-columns:1fr 1fr;gap:16px}
.detail-section{background:#0d1520;border:1px solid #1e3050;border-radius:8px;padding:12px}
.detail-section h4{font-size:10px;text-transform:uppercase;color:#555;letter-spacing:.05em;margin-bottom:8px}
.detail-section p{font-size:12px;color:#c9d1d9;line-height:1.6}
.prog-entry{background:#141921;border-radius:4px;padding:4px 8px;margin:3px 0;font-family:monospace;font-size:11px;color:#79c0ff}
.prog-lines{color:#7d8590;font-size:10px}
.sme-entry{background:#0d1520;border:1px solid #1e3050;border-radius:6px;padding:10px;margin:6px 0}
.sme-entry .sme-hdr{font-size:11px;font-weight:700;color:#9ab8f5;margin-bottom:6px}
.sme-entry .sme-field{font-size:11px;color:#8b949e;margin:3px 0}
.sme-entry .sme-field b{color:#c9d1d9}
.hidden{display:none}
"""

JS = r"""
const rows = Array.from(document.querySelectorAll('tbody tr.data-row'));
const detailRows = {};
rows.forEach(r => {
  const id = r.dataset.id;
  detailRows[id] = document.getElementById('detail-' + id);
});

let filters = {tipo:'all', conf:'all', cap:'all', reg:'all', sme:'all', srch:''};
let sortCol = null, sortDir = 1;

function applyFilters() {
  let vis = 0;
  rows.forEach(r => {
    const t = filters.tipo==='all' || r.dataset.tipo===filters.tipo;
    const c = filters.conf==='all' || r.dataset.conf===filters.conf;
    const p = filters.cap==='all'  || r.dataset.cap===filters.cap;
    const re= filters.reg==='all'  || (r.dataset.reg||'').includes(filters.reg);
    const sm= filters.sme==='all'  || (filters.sme==='yes' ? r.dataset.sme==='1' : r.dataset.sme==='0');
    const s = !filters.srch || r.dataset.term.includes(filters.srch)
                             || r.dataset.al.includes(filters.srch)
                             || r.dataset.sig.includes(filters.srch);
    const show = t && c && p && re && sm && s;
    r.style.display = show ? '' : 'none';
    if (detailRows[r.dataset.id]) detailRows[r.dataset.id].style.display = 'none';
    if (show) vis++;
  });
  document.getElementById('cnt').textContent = vis + ' términos visibles';
}

document.querySelectorAll('.ftag').forEach(btn => {
  btn.addEventListener('click', () => {
    const f = btn.dataset.filter, v = btn.dataset.val;
    document.querySelectorAll('.ftag[data-filter="'+f+'"]').forEach(b => b.classList.remove('active'));
    btn.classList.add('active');
    filters[f] = v;
    applyFilters();
  });
});

document.getElementById('srch').addEventListener('input', e => {
  filters.srch = e.target.value.toLowerCase().trim();
  applyFilters();
});

rows.forEach(r => {
  r.addEventListener('click', () => {
    const id = r.dataset.id;
    const dr = detailRows[id];
    if (!dr) return;
    const showing = dr.classList.contains('show');
    document.querySelectorAll('.detail-row.show').forEach(d => d.classList.remove('show'));
    if (!showing) dr.classList.add('show');
  });
});

document.querySelectorAll('th[data-sort]').forEach(th => {
  th.addEventListener('click', () => {
    const col = th.dataset.sort;
    if (sortCol === col) sortDir *= -1; else { sortCol = col; sortDir = 1; }
    document.querySelectorAll('th').forEach(t => t.classList.remove('asc','desc'));
    th.classList.add(sortDir===1 ? 'asc' : 'desc');
    const tbody = document.querySelector('tbody');
    const allRows = [];
    rows.forEach(r => {
      allRows.push(r);
      const id = r.dataset.id;
      if (detailRows[id]) allRows.push(detailRows[id]);
    });
    rows.sort((a,b) => {
      let av = col==='freq' ? parseInt(a.dataset.fr||0) : a.dataset.term;
      let bv = col==='freq' ? parseInt(b.dataset.fr||0) : b.dataset.term;
      if (typeof av === 'string') return sortDir * av.localeCompare(bv);
      return sortDir * (av - bv);
    });
    rows.forEach(r => {
      tbody.appendChild(r);
      const id = r.dataset.id;
      if (detailRows[id]) tbody.appendChild(detailRows[id]);
    });
    applyFilters();
  });
});

applyFilters();
"""


def esc(s):
    return html_mod.escape(str(s or ""), quote=True)


def reg_pill(reg):
    c = REG_COLORS.get(reg, ("#1a1a1a", "#aaaaaa"))
    return f'<span class="reg-pill" style="background:{c[0]};color:{c[1]}">{esc(reg)}</span>'


def cat_pill(cat, style="tag"):
    c = CAT_COLORS.get(cat, ("#1a1a1a", "#aaaaaa"))
    return f'<span class="{style}" style="background:{c[0]};color:{c[1]}">{esc(cat)}</span>'


def cap_pill(cap):
    c = CAP_COLORS.get(cap, ("#1a1a2e", "#9ab8f5"))
    return f'<span class="tag" style="background:{c[0]};color:{c[1]};max-width:160px;overflow:hidden;text-overflow:ellipsis;display:inline-block;vertical-align:middle">{esc(cap)}</span>'


def conf_pill(conf):
    s = CONF_STYLE.get(conf, ("background:#1a1a1a", "color:#aaaaaa", ""))
    return f'<span class="tag" style="{s[0]};{s[1]};{s[2]}">{esc(conf.capitalize())}</span>'


def render_detail(idx, term):
    regs  = term.get("entidad_regulatoria") or []
    progs = term.get("programas") or []
    enrs  = term.get("enrichments_regulatorios") or []

    prog_html = ""
    for p in progs:
        lineas = ", ".join(str(x) for x in (p.get("lineas") or []))
        prog_html += (
            f'<div class="prog-entry">{esc(p.get("archivo",""))}'
            f'<span class="prog-lines"> · {esc(p.get("rol",""))} · líneas: {esc(lineas)}</span></div>'
        )

    enr_html = ""
    for e in enrs:
        src = e.get("fuente_sme", "SME")
        c = REG_COLORS.get(src, ("#1a1a3a", "#9ab8f5"))
        enr_html += f'<div class="sme-entry">'
        enr_html += f'<div class="sme-hdr" style="color:{c[1]}">{esc(src)} — {esc(e.get("marco_regulatorio",""))}</div>'
        if e.get("obligacion_especifica"):
            enr_html += f'<div class="sme-field"><b>Obligación:</b> {esc(e["obligacion_especifica"])}</div>'
        if e.get("reporte_regulatorio"):
            enr_html += f'<div class="sme-field"><b>Reporte:</b> {esc(e["reporte_regulatorio"])} · {esc(e.get("frecuencia_reporte",""))}</div>'
        if e.get("riesgo_incumplimiento"):
            enr_html += f'<div class="sme-field"><b>Riesgo:</b> {esc(e["riesgo_incumplimiento"])}</div>'
        if e.get("impacto_modernizacion"):
            enr_html += f'<div class="sme-field"><b>Modernización:</b> {esc(e["impacto_modernizacion"])}</div>'
        if e.get("notas_sme"):
            enr_html += f'<div class="sme-field"><b>Nota SME:</b> {esc(e["notas_sme"])}</div>'
        enr_html += '</div>'

    formula_html = ""
    if term.get("formula_ref"):
        formula_html = f'<div class="sme-field"><b>Fórmula:</b> <code style="color:#79c0ff;font-size:11px">{esc(term["formula_ref"])}</code></div>'

    row_id = f"r{idx}"
    return f"""<tr id="detail-{row_id}" class="detail-row">
  <td class="detail-cell" colspan="9">
    <div class="detail-grid">
      <div>
        <div class="detail-section">
          <h4>Descripción completa</h4>
          <p>{esc(term.get("significado",""))}</p>
          {f'<p style="margin-top:8px;color:#7d8590;font-size:11px">{esc(term.get("alcance",""))}</p>' if term.get("alcance") else ""}
        </div>
        {f'<div class="detail-section" style="margin-top:12px"><h4>Regla de negocio</h4><p>{esc(term.get("regla_negocio",""))}</p></div>' if term.get("regla_negocio") else ""}
        {f'<div class="detail-section" style="margin-top:12px"><h4>Fórmula</h4>{formula_html}</div>' if term.get("formula_ref") else ""}
        {f'<div class="detail-section" style="margin-top:12px"><h4>Tipo de dato · Ciclo de vida</h4><p>{esc(term.get("tipo_dato",""))} · {esc(term.get("ciclo_vida",""))}</p></div>' if term.get("tipo_dato") else ""}
        {f'<div class="detail-section" style="margin-top:12px"><h4>Proceso de negocio</h4><p>{esc(term.get("proceso_negocio",""))}</p></div>' if term.get("proceso_negocio") else ""}
      </div>
      <div>
        {f'<div class="detail-section"><h4>Programas / Archivos</h4>{prog_html}</div>' if prog_html else ""}
        {f'<div class="detail-section" style="margin-top:12px"><h4>Enriquecimiento regulatorio ({len(enrs)} SME)</h4>{enr_html}</div>' if enr_html else ""}
      </div>
    </div>
  </td>
</tr>"""


def render_html(sistema: str, data: dict) -> None:
    meta  = data["meta"]
    terms = data["vocabulario"]

    total   = len(terms)
    with_sme= sum(1 for t in terms if t.get("enrichments_regulatorios"))
    with_fml= sum(1 for t in terms if t.get("formula_ref"))
    pend    = sum(1 for t in terms if t.get("pendiente_validacion_sme"))
    alta    = sum(1 for t in terms if t.get("confianza") == "alta")
    media   = sum(1 for t in terms if t.get("confianza") == "media")
    baja    = sum(1 for t in terms if t.get("confianza") == "baja")

    caps = sorted(set(t.get("capacidad_negocio","") for t in terms if t.get("capacidad_negocio")))
    regs = sorted(set(e for t in terms for e in (t.get("entidad_regulatoria") or [])))
    cats = Counter(t.get("categoria","") for t in terms if t.get("categoria"))

    label_map = {
        "S500": ("Cargos y Abonos de Cheque", "SPE-MM-001"),
        "S151": ("Movimientos Contables GL",   "SPE-MM-002"),
    }
    label, spec_id = label_map.get(sistema, (sistema, "SPE-MM"))

    # Stats row
    stats_html = (
        f'<div class="sc"><div class="num">{total}</div><div class="lbl">Términos únicos<div class="sub2">vocabulario Capa 1</div></div></div>'
        f'<div class="sc"><div class="dot dot-b"></div><div class="num">{with_sme}</div><div class="lbl">Con enriquecimiento SME</div></div>'
        f'<div class="sc"><div class="num">{with_fml}</div><div class="lbl">Con fórmula documentada</div></div>'
        f'<div class="sc"><div class="dot dot-o"></div><div class="num">{pend}</div><div class="lbl">Pendiente validación SME</div></div>'
        f'<div class="sc"><div class="dot dot-g"></div><div class="num">{alta}</div><div class="lbl">Alta confianza</div></div>'
        f'<div class="sc"><div class="dot dot-o"></div><div class="num">{media}</div><div class="lbl">Media</div></div>'
        f'<div class="sc"><div class="dot dot-r"></div><div class="num">{baja}</div><div class="lbl">Baja</div></div>'
    )

    # Filter buttons
    cap_btns = '<button class="ftag active" data-filter="cap" data-val="all">todas</button>'
    for cap in caps:
        c = CAP_COLORS.get(cap, ("#1a1a2e", "#9ab8f5"))
        cap_btns += (
            f'<button class="ftag" data-filter="cap" data-val="{esc(cap)}" '
            f'style="background:{c[0]};color:{c[1]};border-color:{c[1]}40">{esc(cap)}</button>'
        )

    reg_btns = '<button class="ftag active" data-filter="reg" data-val="all">todas</button>'
    for reg in regs:
        c = REG_COLORS.get(reg, ("#1a1a1a", "#aaaaaa"))
        reg_btns += (
            f'<button class="ftag" data-filter="reg" data-val="{esc(reg)}" '
            f'style="background:{c[0]};color:{c[1]};border-color:{c[1]}40">{esc(reg)}</button>'
        )

    cat_btns = '<button class="ftag active" data-filter="tipo" data-val="all">todas</button>'
    for cat, _ in cats.most_common():
        c = CAT_COLORS.get(cat, ("#1a1a1a", "#aaaaaa"))
        cat_btns += (
            f'<button class="ftag" data-filter="tipo" data-val="{esc(cat)}" '
            f'style="background:{c[0]};color:{c[1]};border-color:{c[1]}40">{esc(cat)}</button>'
        )

    # Table rows + detail panels
    rows_html = ""
    for i, t in enumerate(terms):
        row_id  = f"r{i}"
        tc      = t.get("termino_canonico", "")
        sig     = t.get("significado", "")
        conf    = t.get("confianza", "baja")
        cat     = t.get("categoria", "")
        cap     = t.get("capacidad_negocio", "")
        regs_t  = t.get("entidad_regulatoria") or []
        aliases = t.get("aliases") or []
        freq    = t.get("frecuencia", 0)
        enrs    = t.get("enrichments_regulatorios") or []
        has_fml = bool(t.get("formula_ref"))
        is_pend = bool(t.get("pendiente_validacion_sme"))

        alias_html = "".join(f'<span class="ap">{esc(a)}</span>' for a in aliases[:4]) or '<span style="color:#333">—</span>'
        reg_html   = "".join(reg_pill(r) for r in regs_t[:3])
        sme_badge  = f'<span class="sme-badge">SME·{len(enrs)}</span> ' if enrs else ""
        fml_badge  = '<span class="fml-badge">∑</span> ' if has_fml else ""
        pnd_badge  = '<span class="pend-badge">⚠</span> ' if is_pend else ""

        regs_str = " ".join(regs_t)
        rows_html += (
            f'<tr class="data-row" data-id="{row_id}" data-tipo="{esc(cat)}" '
            f'data-conf="{esc(conf)}" data-cap="{esc(cap)}" data-reg="{esc(regs_str)}" '
            f'data-sme="{"1" if enrs else "0"}" data-fr="{freq}" '
            f'data-term="{esc(tc.lower())}" data-al="{esc(" ".join(aliases).lower())}" '
            f'data-sig="{esc(sig.lower())}">'
            f'<td class="td-t" title="{esc(tc)}">{esc(tc)}</td>'
            f'<td>{cat_pill(cat)}</td>'
            f'<td>{cap_pill(cap) if cap else ""}</td>'
            f'<td>{conf_pill(conf)}</td>'
            f'<td>{reg_html}</td>'
            f'<td>{sme_badge}{fml_badge}{pnd_badge}</td>'
            f'<td class="td-sig" title="{esc(sig)}">{esc(sig[:80])}</td>'
            f'<td class="td-al">{alias_html}</td>'
            f'<td class="td-fr" data-f="{freq}">{freq}</td>'
            f'</tr>\n'
        )
        rows_html += render_detail(i, t) + "\n"

    sme_filter = (
        '<span class="flbl">SME:</span>'
        '<button class="ftag active" data-filter="sme" data-val="all">todos</button>'
        '<button class="ftag" data-filter="sme" data-val="yes" style="background:#1a1a3a;color:#9ab8f5;border-color:#2a3060">Con SME</button>'
        '<button class="ftag" data-filter="sme" data-val="no" style="background:#1a1a1a;color:#555;border-color:#333">Sin SME</button>'
    )

    html = f"""<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<title>Banamex {sistema} · Vocabulario Controlado v4.0 · Gemelo Cognitivo</title>
<style>{CSS}</style>
</head>
<body>
<header>
<img src="../../banamex-logo.png" alt="Banamex">
<div>
  <h1>Vocabulario Controlado &mdash; {sistema} <span style="font-size:12px;color:#3d6fa0;font-weight:400">v4.0</span></h1>
  <div class="sub">Gemelo Cognitivo &middot; Capa 1 (lenguaje) &middot; {spec_id} &middot; {label} &middot;
  {len(caps)} capacidades &middot; {len(regs)} entidades regulatorias &middot; Generado 2026-07-15</div>
</div>
</header>
<div class="stats">{stats_html}</div>

<div class="fbar">
<input id="srch" placeholder="Buscar término, alias o significado&hellip;">
<span class="flbl">CONFIANZA:</span>
<button class="ftag active" data-filter="conf" data-val="all">todas</button>
<button class="ftag" data-filter="conf" data-val="alta" style="background:#0a1f0a;color:#4ade80;border-color:#1a5a1a">Alta</button>
<button class="ftag" data-filter="conf" data-val="media" style="background:#2a1800;color:#fb923c;border-color:#5a3a0a">Media</button>
<button class="ftag" data-filter="conf" data-val="baja" style="background:#2a0808;color:#f87171;border-color:#5a1a1a">Baja</button>
{sme_filter}
</div>

<div class="fbar">
<span class="flbl">CATEGORÍA:</span>
{cat_btns}
</div>

<div class="fbar">
<span class="flbl">CAPACIDAD:</span>
{cap_btns}
</div>

<div class="fbar">
<span class="flbl">ENTIDAD REG.:</span>
{reg_btns}
</div>

<div class="wrap">
<div class="tbar">
  <span>Banamex {sistema} &middot; Unisys ClearPath MCP &middot; Click en fila para detalle completo</span>
  <span id="cnt"></span>
</div>
<table id="vt">
<thead><tr>
<th data-sort="term">TÉRMINO</th>
<th>CATEGORÍA</th>
<th>CAPACIDAD</th>
<th>CONFIANZA</th>
<th>REG.</th>
<th>SME / ∑</th>
<th>SIGNIFICADO</th>
<th>ALIASES</th>
<th data-sort="freq" style="text-align:right">FREQ</th>
</tr></thead>
<tbody>{rows_html}</tbody>
</table>
</div>
<script>{JS}</script>
</body>
</html>"""

    out_path = DATA_DIR / sistema / f"vocab-{sistema.lower()}-v4.html"
    out_path.write_text(html, encoding="utf-8")
    print(f"  [OUTPUT] {out_path}")


def main():
    sistemas = sys.argv[1:] if len(sys.argv) > 1 else ["S500", "S151"]
    for s in sistemas:
        s = s.upper()
        json_path = DATA_DIR / s / f"vocab-{s.lower()}-v4.json"
        if not json_path.exists():
            print(f"[ERROR] No encontrado: {json_path}")
            continue
        data = json.loads(json_path.read_text(encoding="utf-8"))
        print(f"\n[RENDER] {s} — {data['meta']['total_terminos']} términos")
        render_html(s, data)
        print(f"[OK] {s} v4 HTML generado.")


if __name__ == "__main__":
    main()
#!/usr/bin/env python3
"""
Genera vocab-s500-full.html — portal unificado con dos tabs:
  Tab 1: Vocabulario de Negocio v4.0 (185 términos curados + SME enrichments)
  Tab 2: Diccionario de Campos COBOL (11,194 campos de copybooks INC)

Uso: python render-vocab-full.py
"""

import json, sys, html as html_mod
from pathlib import Path
from collections import Counter

ROOT = Path(__file__).parent
DATA = ROOT / "data"
BASE = ROOT.parent

VOCAB_JSON  = DATA / "S500" / "vocab-s500-v4.json"
CAMPOS_JSON = BASE / "S500" / "source" / "S500" / "vocab-campos-s500.json"
OUT_HTML    = DATA / "S500" / "vocab-s500-full.html"

# ── Colores ────────────────────────────────────────────────────────────────────
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
    "alta":  ("#0a1f0a", "#4ade80"),
    "media": ("#2a1800", "#fb923c"),
    "baja":  ("#2a0808", "#f87171"),
}
REG_COLORS = {
    "CNBV": ("#003366","#4db8ff"), "CNBV-PLD": ("#1a0044","#b388ff"),
    "Banxico": ("#003300","#66ff66"), "SAT": ("#330000","#ff6666"),
    "CONDUSEF": ("#332200","#ffaa44"), "IPAB": ("#222200","#eeee44"),
    "TESOFE": ("#001133","#44aaff"), "INEGI": ("#002200","#44dd88"),
}
CAP_COLORS = {
    "Clientes y Cuentas":           ("#0d1f33","#7ab8f5"),
    "Movimientos y Transacciones":  ("#0d2e1a","#6de8a0"),
    "Promedios y Saldos":           ("#2e1a0d","#f5b87a"),
    "Comisiones y Tarifas":         ("#2e0d1a","#f57ab8"),
    "Contabilidad y Asientos GL":   ("#1a0d2e","#c4a8f5"),
    "Intereses y Rendimientos":     ("#2e2a0d","#f5e07a"),
    "Crédito y Pagos Domiciliados": ("#2e2e0d","#f5f07a"),
    "Operación Online":             ("#0d2e2e","#7af5f5"),
    "Control y Parametría":         ("#1a1a2e","#9ab8f5"),
}
TIPO_COLORS = {
    "COMP":             ("#0d1a2e","#7ab8f5"),
    "NUMERICO":         ("#0d2e1a","#6de8a0"),
    "NUMERICO_DECIMAL": ("#2e1a0d","#f5b87a"),
    "ALFANUMERICO":     ("#2e0d1a","#f57ab8"),
    "GRUPO":            ("#1a1a2e","#9ab8f5"),
    "NUMERICO_EDICION": ("#2e2a0d","#f5e07a"),
    "OTRO":             ("#1a1a1a","#888888"),
}
FUENTE_COLORS = {
    "S500_INC_WOR_DAS.txt":    ("#0d1a2e","#7ab8f5"),
    "S500_INC_WOR_CAN.txt":    ("#1a0d2e","#c4a8f5"),
    "S500_INC_PRO.txt":        ("#0d2e1a","#6de8a0"),
    "S500_SOURCE_P130.txt":    ("#2e1a0d","#f5b87a"),
    "S500_INC_P010_MAS.txt":   ("#2e0d1a","#f57ab8"),
    "S500_INC_L010.txt":       ("#2e2a0d","#f5e07a"),
    "S500_INC_MAPLI_WOR.txt":  ("#1a2e0d","#b8f57a"),
    "S500_INC_L020.txt":       ("#0d2e2e","#7af5f5"),
}

def esc(s): return html_mod.escape(str(s or ""), quote=True)

def pill(text, bg, fg, extra=""):
    return f'<span class="tag" style="background:{bg};color:{fg}{extra}">{esc(text)}</span>'

# ══════════════════════════════════════════════════════════════════════════════
# CSS compartido
# ══════════════════════════════════════════════════════════════════════════════
CSS = """
*{box-sizing:border-box;margin:0;padding:0}
body{background:#0a0c10;color:#c9d1d9;font-family:'Segoe UI',system-ui,sans-serif;font-size:13px}
header{background:#141921;border-bottom:1px solid #1e3050;padding:14px 24px;display:flex;align-items:center;gap:16px}
header img{height:34px;opacity:.85}
header h1{font-size:17px;font-weight:700;color:#e6edf3}
header .sub{font-size:11px;color:#7d8590;margin-top:2px}
/* Tabs */
.tabs{display:flex;background:#0e1218;border-bottom:2px solid #1e2d40;padding:0 24px}
.tab{padding:10px 20px;font-size:12px;font-weight:600;color:#7d8590;cursor:pointer;border-bottom:2px solid transparent;margin-bottom:-2px;transition:.15s}
.tab:hover{color:#c9d1d9}
.tab.active{color:#7ab8f5;border-bottom-color:#7ab8f5}
.tab-panel{display:none}.tab-panel.active{display:block}
/* Stats */
.stats{display:flex;flex-wrap:wrap;gap:10px;padding:14px 24px;background:#0e1218;border-bottom:1px solid #1e2d40}
.sc{display:flex;align-items:center;gap:8px;background:#141921;border:1px solid #1e3050;border-radius:8px;padding:9px 14px;min-width:100px}
.sc .num{font-size:20px;font-weight:700;color:#e6edf3}
.sc .lbl{font-size:10px;color:#7d8590;line-height:1.4}
.sc .sub2{font-size:9px;color:#444;margin-top:1px}
.dot{width:9px;height:9px;border-radius:50%;flex-shrink:0}
.dot-g{background:#4ade80}.dot-o{background:#fb923c}.dot-r{background:#f87171}.dot-b{background:#7ab8f5}
/* Filter bar */
.fbar{padding:10px 24px;background:#0e1218;border-bottom:1px solid #1e2d40;display:flex;flex-wrap:wrap;gap:6px;align-items:center}
.flbl{font-size:10px;color:#555;text-transform:uppercase;letter-spacing:.05em;margin-right:2px;margin-left:6px}
.ftag{background:#141921;border:1px solid #1e3050;border-radius:12px;padding:2px 9px;font-size:11px;color:#7d8590;cursor:pointer;transition:.15s}
.ftag:hover{border-color:#3d6fa0;color:#c9d1d9}
.ftag.active{background:#1a3a6a;border-color:#3d6fa0;color:#7ab8f5;font-weight:600}
#srch,#srch2{background:#141921;border:1px solid #1e3050;border-radius:8px;padding:5px 11px;color:#c9d1d9;font-size:12px;width:220px;outline:none}
#srch:focus,#srch2:focus{border-color:#3d6fa0}
/* Table */
.wrap{padding:0 24px 24px}
.tbar{padding:7px 0;font-size:11px;color:#555;display:flex;justify-content:space-between}
table{width:100%;border-collapse:collapse;table-layout:fixed}
thead tr{background:#141921;border-bottom:2px solid #1e3050}
th{padding:7px 8px;text-align:left;font-size:10px;color:#7d8590;text-transform:uppercase;letter-spacing:.05em;cursor:pointer;user-select:none;white-space:nowrap}
th:hover{color:#c9d1d9}
th.asc::after{content:" ↑"}th.desc::after{content:" ↓"}
tbody tr{border-bottom:1px solid #161b22;transition:.1s;cursor:pointer}
tbody tr:hover{background:#0f1a2a}
tbody tr.expanded{background:#0a1628}
td{padding:6px 8px;vertical-align:middle}
.td-t{font-family:'Cascadia Code','Consolas',monospace;font-size:11px;color:#79c0ff;font-weight:600;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}
.td-sig{color:#8b949e;font-size:11px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}
.td-al{overflow:hidden}
.td-fr{text-align:right;font-family:monospace;color:#7d8590}
.tag{border-radius:10px;padding:2px 7px;font-size:10px;font-weight:600;white-space:nowrap;display:inline-block}
.ap{background:#1a2a1a;color:#7af57a;border-radius:6px;padding:1px 5px;font-size:10px;margin:1px;display:inline-block;font-family:monospace}
.reg-pill{border-radius:10px;padding:2px 6px;font-size:10px;font-weight:600;margin:1px;display:inline-block}
.sme-badge{background:#1a1a3a;color:#9ab8f5;border:1px solid #2a3060;border-radius:10px;padding:2px 6px;font-size:10px}
.fml-badge{background:#1a2a0a;color:#9af57a;border:1px solid #2a5010;border-radius:10px;padding:2px 6px;font-size:10px}
.pend-badge{background:#2a1a00;color:#f5b87a;border:1px solid #5a3a00;border-radius:10px;padding:2px 6px;font-size:10px}
/* Detail panel */
.detail-row{display:none;background:#080e18}
.detail-row.show{display:table-row}
.detail-cell{padding:14px 20px;border-bottom:2px solid #1e3050}
.detail-grid{display:grid;grid-template-columns:1fr 1fr;gap:14px}
.dsec{background:#0d1520;border:1px solid #1e3050;border-radius:8px;padding:11px}
.dsec h4{font-size:10px;text-transform:uppercase;color:#555;letter-spacing:.05em;margin-bottom:7px}
.dsec p{font-size:12px;color:#c9d1d9;line-height:1.5}
.prog-entry{background:#141921;border-radius:4px;padding:3px 7px;margin:3px 0;font-family:monospace;font-size:11px;color:#79c0ff}
.sme-entry{background:#0d1520;border:1px solid #1e3050;border-radius:6px;padding:9px;margin:5px 0}
.sme-hdr{font-size:11px;font-weight:700;margin-bottom:5px}
.sme-field{font-size:11px;color:#8b949e;margin:2px 0}
.sme-field b{color:#c9d1d9}
/* Campos dict */
.grupo-hdr{background:#141921;border-top:2px solid #1e3050;border-bottom:1px solid #1e3050;padding:8px 12px;font-family:monospace;font-size:12px;color:#c4a8f5;cursor:pointer;display:flex;justify-content:space-between;align-items:center}
.grupo-hdr:hover{background:#1a1e2e}
.grupo-hdr .meta{font-size:10px;color:#555;font-family:sans-serif}
.campo-row{border-bottom:1px solid #0d1218;display:flex;align-items:center;gap:0;font-size:12px}
.campo-row:hover{background:#0a1218}
.campo-row.hidden{display:none}
.c-nom{font-family:monospace;color:#79c0ff;padding:5px 10px;flex:0 0 320px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}
.c-niv{color:#555;padding:5px 5px;flex:0 0 40px;text-align:center;font-size:10px}
.c-tip{padding:5px 6px;flex:0 0 130px}
.c-pic{color:#8b949e;padding:5px 6px;flex:0 0 130px;font-family:monospace;font-size:11px}
.c-dom{padding:5px 6px;flex:0 0 110px}
.c-val{color:#7d8590;padding:5px 6px;flex:1;font-size:11px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}
.c88{background:#1a2a0a;border-left:2px solid #2a5010;padding:4px 10px 4px 20px;font-size:11px;font-family:monospace}
.c88 .cname{color:#9af57a}
.c88 .cval{color:#7d8590;margin-left:8px}
.c88-group{display:none}
.c88-group.show{display:block}
.grupo-body{display:none}
.grupo-body.show{display:block}
"""

# ══════════════════════════════════════════════════════════════════════════════
# JavaScript
# ══════════════════════════════════════════════════════════════════════════════
JS = r"""
// ── Tab switching ──────────────────────────────────────────────────────────
document.querySelectorAll('.tab').forEach(t => {
  t.addEventListener('click', () => {
    document.querySelectorAll('.tab').forEach(x => x.classList.remove('active'));
    document.querySelectorAll('.tab-panel').forEach(x => x.classList.remove('active'));
    t.classList.add('active');
    document.getElementById(t.dataset.tab).classList.add('active');
  });
});

// ── Tab 1: Vocabulario ─────────────────────────────────────────────────────
const rows1 = Array.from(document.querySelectorAll('#vocab-panel tbody tr.data-row'));
const detailRows1 = {};
rows1.forEach(r => { detailRows1[r.dataset.id] = document.getElementById('detail-' + r.dataset.id); });

let f1 = {conf:'all', cap:'all', reg:'all', sme:'all', srch:''};

function applyFilters1() {
  let vis = 0;
  rows1.forEach(r => {
    const ok = (f1.conf==='all'||r.dataset.conf===f1.conf)
      && (f1.cap==='all'||r.dataset.cap===f1.cap)
      && (f1.reg==='all'||(r.dataset.reg||'').includes(f1.reg))
      && (f1.sme==='all'||(f1.sme==='yes'?r.dataset.sme==='1':r.dataset.sme==='0'))
      && (!f1.srch||r.dataset.term.includes(f1.srch)||r.dataset.al.includes(f1.srch)||r.dataset.sig.includes(f1.srch));
    r.style.display = ok ? '' : 'none';
    if (detailRows1[r.dataset.id]) detailRows1[r.dataset.id].style.display = 'none';
    if (ok) vis++;
  });
  document.getElementById('cnt1').textContent = vis + ' términos';
}
document.querySelectorAll('#vocab-panel .ftag').forEach(b => {
  b.addEventListener('click', () => {
    const f = b.dataset.filter, v = b.dataset.val;
    document.querySelectorAll('#vocab-panel .ftag[data-filter="'+f+'"]').forEach(x => x.classList.remove('active'));
    b.classList.add('active'); f1[f] = v; applyFilters1();
  });
});
document.getElementById('srch').addEventListener('input', e => { f1.srch = e.target.value.toLowerCase().trim(); applyFilters1(); });
rows1.forEach(r => {
  r.addEventListener('click', () => {
    const id = r.dataset.id, dr = detailRows1[id]; if (!dr) return;
    const showing = dr.classList.contains('show');
    document.querySelectorAll('#vocab-panel .detail-row.show').forEach(d => d.classList.remove('show'));
    if (!showing) dr.classList.add('show');
  });
});
applyFilters1();

// ── Tab 2: Diccionario ─────────────────────────────────────────────────────
let f2 = {tipo:'all', dom:'all', fuente:'all', srch:''};

function applyFilters2() {
  let vis = 0, visGrupos = 0;
  document.querySelectorAll('.grupo-section').forEach(g => {
    let cualquier = false;
    g.querySelectorAll('.campo-row').forEach(r => {
      const ok = (f2.tipo==='all'||r.dataset.tipo===f2.tipo)
        && (f2.dom==='all'||r.dataset.dom===f2.dom)
        && (f2.fuente==='all'||r.dataset.fuente===f2.fuente)
        && (!f2.srch||r.dataset.nom.includes(f2.srch)||r.dataset.desc.includes(f2.srch));
      r.classList.toggle('hidden', !ok);
      if (ok) { vis++; cualquier = true; }
    });
    const body = g.querySelector('.grupo-body');
    const isFiltering = f2.tipo!=='all'||f2.dom!=='all'||f2.fuente!=='all'||f2.srch;
    if (isFiltering) {
      g.style.display = cualquier ? '' : 'none';
      if (cualquier && body) body.classList.add('show');
    } else {
      g.style.display = '';
    }
    if (cualquier || !isFiltering) visGrupos++;
  });
  document.getElementById('cnt2').textContent = vis + ' campos · ' + visGrupos + ' grupos';
}
document.querySelectorAll('#dict-panel .ftag').forEach(b => {
  b.addEventListener('click', () => {
    const f = b.dataset.filter, v = b.dataset.val;
    document.querySelectorAll('#dict-panel .ftag[data-filter="'+f+'"]').forEach(x => x.classList.remove('active'));
    b.classList.add('active'); f2[f] = v; applyFilters2();
  });
});
document.getElementById('srch2').addEventListener('input', e => { f2.srch = e.target.value.toLowerCase().trim(); applyFilters2(); });

// Toggle grupo
document.querySelectorAll('.grupo-hdr').forEach(h => {
  h.addEventListener('click', () => {
    const body = h.nextElementSibling;
    if (body) body.classList.toggle('show');
    h.querySelector('.chevron').textContent = (body && body.classList.contains('show')) ? '▾' : '▸';
  });
});

// Toggle c88
document.querySelectorAll('.c88-toggle').forEach(b => {
  b.addEventListener('click', e => {
    e.stopPropagation();
    const g = document.getElementById(b.dataset.target);
    if (g) g.classList.toggle('show');
  });
});

applyFilters2();
"""

# ══════════════════════════════════════════════════════════════════════════════
# RENDER TAB 1 — Vocabulario
# ══════════════════════════════════════════════════════════════════════════════
def render_vocab_detail(idx, t):
    progs = t.get("programas") or []
    enrs  = t.get("enrichments_regulatorios") or []

    prog_html = "".join(
        f'<div class="prog-entry">{esc(p.get("archivo",""))} '
        f'<span style="color:#7d8590">· {esc(p.get("rol",""))} · líneas: '
        f'{esc(", ".join(str(x) for x in (p.get("lineas") or [])))}</span></div>'
        for p in progs
    )
    enr_html = ""
    for e in enrs:
        src = e.get("fuente_sme","SME"); c = REG_COLORS.get(src,("#1a1a3a","#9ab8f5"))
        enr_html += (
            f'<div class="sme-entry"><div class="sme-hdr" style="color:{c[1]}">'
            f'{esc(src)} — {esc(e.get("marco_regulatorio",""))}</div>'
        )
        for k,label in [("obligacion_especifica","Obligación"),("reporte_regulatorio","Reporte"),
                         ("riesgo_incumplimiento","Riesgo"),("impacto_modernizacion","Modernización"),
                         ("notas_sme","Nota SME")]:
            if e.get(k): enr_html += f'<div class="sme-field"><b>{label}:</b> {esc(e[k])}</div>'
        enr_html += "</div>"

    row_id = f"r{idx}"
    return f"""<tr id="detail-{row_id}" class="detail-row">
  <td class="detail-cell" colspan="9">
    <div class="detail-grid">
      <div>
        <div class="dsec"><h4>Descripción completa</h4>
          <p>{esc(t.get("significado",""))}</p>
          {f'<p style="margin-top:6px;color:#7d8590;font-size:11px">{esc(t.get("alcance",""))}</p>' if t.get("alcance") else ""}
        </div>
        {f'<div class="dsec" style="margin-top:10px"><h4>Regla de negocio</h4><p>{esc(t.get("regla_negocio",""))}</p></div>' if t.get("regla_negocio") else ""}
        {f'<div class="dsec" style="margin-top:10px"><h4>Fórmula</h4><p><code style="color:#79c0ff;font-size:11px">{esc(t.get("formula_ref",""))}</code></p></div>' if t.get("formula_ref") else ""}
        {f'<div class="dsec" style="margin-top:10px"><h4>Tipo · Ciclo de vida</h4><p>{esc(t.get("tipo_dato",""))} · {esc(t.get("ciclo_vida",""))}</p></div>' if t.get("tipo_dato") else ""}
        {f'<div class="dsec" style="margin-top:10px"><h4>Proceso de negocio</h4><p>{esc(t.get("proceso_negocio",""))}</p></div>' if t.get("proceso_negocio") else ""}
      </div>
      <div>
        {f'<div class="dsec"><h4>Programas</h4>{prog_html}</div>' if prog_html else ""}
        {f'<div class="dsec" style="margin-top:10px"><h4>SME regulatorio ({len(enrs)})</h4>{enr_html}</div>' if enr_html else ""}
      </div>
    </div>
  </td>
</tr>"""


def render_vocab_tab(data):
    terms = data["vocabulario"]
    meta  = data["meta"]
    total  = len(terms)
    w_sme  = sum(1 for t in terms if t.get("enrichments_regulatorios"))
    w_fml  = sum(1 for t in terms if t.get("formula_ref"))
    pend   = sum(1 for t in terms if t.get("pendiente_validacion_sme"))
    alta   = sum(1 for t in terms if t.get("confianza")=="alta")
    media  = sum(1 for t in terms if t.get("confianza")=="media")
    baja   = sum(1 for t in terms if t.get("confianza")=="baja")
    caps   = sorted(set(t.get("capacidad_negocio","") for t in terms if t.get("capacidad_negocio")))
    regs   = sorted(set(e for t in terms for e in (t.get("entidad_regulatoria") or [])))

    stats = (
        f'<div class="sc"><div class="num">{total}</div><div class="lbl">Términos curados<div class="sub2">Capa 1 v4.0</div></div></div>'
        f'<div class="sc"><div class="dot dot-b"></div><div class="num">{w_sme}</div><div class="lbl">Con SME</div></div>'
        f'<div class="sc"><div class="num">{w_fml}</div><div class="lbl">Con fórmula</div></div>'
        f'<div class="sc"><div class="dot dot-o"></div><div class="num">{pend}</div><div class="lbl">Pendiente SME</div></div>'
        f'<div class="sc"><div class="dot dot-g"></div><div class="num">{alta}</div><div class="lbl">Alta confianza</div></div>'
        f'<div class="sc"><div class="dot dot-o"></div><div class="num">{media}</div><div class="lbl">Media</div></div>'
        f'<div class="sc"><div class="dot dot-r"></div><div class="num">{baja}</div><div class="lbl">Baja</div></div>'
    )

    cap_btns = '<button class="ftag active" data-filter="cap" data-val="all">todas</button>'
    for cap in caps:
        c = CAP_COLORS.get(cap,("#1a1a2e","#9ab8f5"))
        cap_btns += f'<button class="ftag" data-filter="cap" data-val="{esc(cap)}" style="background:{c[0]};color:{c[1]};border-color:{c[1]}40">{esc(cap)}</button>'

    reg_btns = '<button class="ftag active" data-filter="reg" data-val="all">todas</button>'
    for reg in regs:
        c = REG_COLORS.get(reg,("#1a1a1a","#aaaaaa"))
        reg_btns += f'<button class="ftag" data-filter="reg" data-val="{esc(reg)}" style="background:{c[0]};color:{c[1]};border-color:{c[1]}40">{esc(reg)}</button>'

    rows_html = ""
    for i,t in enumerate(terms):
        row_id = f"r{i}"
        tc   = t.get("termino_canonico","")
        sig  = t.get("significado","")
        conf = t.get("confianza","baja")
        cat  = t.get("categoria","")
        cap  = t.get("capacidad_negocio","")
        regs_t = t.get("entidad_regulatoria") or []
        aliases = t.get("aliases") or []
        freq = t.get("frecuencia",0)
        enrs = t.get("enrichments_regulatorios") or []
        has_fml = bool(t.get("formula_ref"))
        is_pend = bool(t.get("pendiente_validacion_sme"))

        cc = CAT_COLORS.get(cat,("#1a1a1a","#aaaaaa"))
        cp = CAP_COLORS.get(cap,("#1a1a2e","#9ab8f5"))
        cf = CONF_STYLE.get(conf,("#1a1a1a","#aaaaaa"))
        alias_html = "".join(f'<span class="ap">{esc(a)}</span>' for a in aliases[:4]) or '<span style="color:#333">—</span>'
        reg_html   = "".join(f'<span class="reg-pill" style="background:{REG_COLORS.get(r,("#1a1a1a","#aaa"))[0]};color:{REG_COLORS.get(r,("#1a1a1a","#aaa"))[1]}">{esc(r)}</span>' for r in regs_t[:3])
        badges = (f'<span class="sme-badge">SME·{len(enrs)}</span> ' if enrs else "") + \
                 ('<span class="fml-badge">∑</span> ' if has_fml else "") + \
                 ('<span class="pend-badge">⚠</span>' if is_pend else "")
        rows_html += (
            f'<tr class="data-row" data-id="{row_id}" data-conf="{esc(conf)}" '
            f'data-cap="{esc(cap)}" data-reg="{esc(" ".join(regs_t))}" '
            f'data-sme="{"1" if enrs else "0"}" data-fr="{freq}" '
            f'data-term="{esc(tc.lower())}" data-al="{esc(" ".join(aliases).lower())}" '
            f'data-sig="{esc(sig.lower())}">'
            f'<td class="td-t" title="{esc(tc)}">{esc(tc)}</td>'
            f'<td><span class="tag" style="background:{cc[0]};color:{cc[1]}">{esc(cat)}</span></td>'
            f'<td><span class="tag" style="background:{cp[0]};color:{cp[1]};max-width:150px;overflow:hidden;text-overflow:ellipsis;display:inline-block;vertical-align:middle">{esc(cap)}</span></td>'
            f'<td><span class="tag" style="background:{cf[0]};color:{cf[1]}">{esc(conf.capitalize())}</span></td>'
            f'<td>{reg_html}</td><td>{badges}</td>'
            f'<td class="td-sig" title="{esc(sig)}">{esc(sig[:80])}</td>'
            f'<td class="td-al">{alias_html}</td>'
            f'<td class="td-fr" data-f="{freq}">{freq}</td></tr>\n'
        )
        rows_html += render_vocab_detail(i, t) + "\n"

    return f"""
<div class="stats">{stats}</div>
<div class="fbar">
<input id="srch" placeholder="Buscar término, alias o significado…">
<span class="flbl">CONFIANZA:</span>
<button class="ftag active" data-filter="conf" data-val="all">todas</button>
<button class="ftag" data-filter="conf" data-val="alta" style="background:#0a1f0a;color:#4ade80;border-color:#1a5a1a">Alta</button>
<button class="ftag" data-filter="conf" data-val="media" style="background:#2a1800;color:#fb923c;border-color:#5a3a0a">Media</button>
<button class="ftag" data-filter="conf" data-val="baja" style="background:#2a0808;color:#f87171;border-color:#5a1a1a">Baja</button>
<span class="flbl">SME:</span>
<button class="ftag active" data-filter="sme" data-val="all">todos</button>
<button class="ftag" data-filter="sme" data-val="yes" style="background:#1a1a3a;color:#9ab8f5;border-color:#2a3060">Con SME</button>
<button class="ftag" data-filter="sme" data-val="no" style="background:#1a1a1a;color:#555">Sin SME</button>
</div>
<div class="fbar"><span class="flbl">CAPACIDAD:</span>{cap_btns}</div>
<div class="fbar"><span class="flbl">ENTIDAD REG.:</span>{reg_btns}</div>
<div class="wrap">
<div class="tbar"><span>Click en fila para detalle completo</span><span id="cnt1"></span></div>
<table id="vt"><thead><tr>
<th data-sort="term" style="width:200px">TÉRMINO</th>
<th style="width:110px">CATEGORÍA</th>
<th style="width:160px">CAPACIDAD</th>
<th style="width:80px">CONF.</th>
<th style="width:130px">REG.</th>
<th style="width:80px">SME/∑</th>
<th>SIGNIFICADO</th>
<th style="width:140px">ALIASES</th>
<th data-sort="freq" style="width:50px;text-align:right">FREQ</th>
</tr></thead><tbody>{rows_html}</tbody></table>
</div>"""


# ══════════════════════════════════════════════════════════════════════════════
# RENDER TAB 2 — Diccionario de Campos
# ══════════════════════════════════════════════════════════════════════════════
def render_campo(c, g_idx, c_idx, fuente):
    nom  = c.get("nombre","")
    niv  = c.get("nivel","")
    tipo = c.get("tipo","")
    pic  = c.get("pic","") or ""
    dom  = c.get("dominio","") or "GENERAL"
    val  = c.get("value","") or ""
    occ  = c.get("occurs")
    redef= c.get("redefine","") or ""
    c88s = c.get("condiciones_88") or []

    tc = TIPO_COLORS.get(tipo,("#1a1a1a","#888"))
    dom_bg = "#0d1a2e" if dom=="GENERAL" else "#1a0d2e"
    dom_fg = "#555"    if dom=="GENERAL" else "#c4a8f5"

    indent = max(0, (int(niv or 0) - 2)) * 10

    extras = ""
    if occ: extras += f' OCCURS {occ}'
    if redef: extras += f' REDEFINES {redef}'
    if val: extras += f' VALUE {val}'

    c88_id = f"c88-{g_idx}-{c_idx}"
    c88_btn = ""
    c88_html = ""
    if c88s:
        c88_btn = f'<button class="ftag c88-toggle" data-target="{c88_id}" style="font-size:9px;padding:1px 5px;margin-left:4px">88·{len(c88s)}</button>'
        c88_html = f'<div id="{c88_id}" class="c88-group">'
        for v88 in c88s:
            vname = v88.get("nombre","")
            vvals = ", ".join(str(x) for x in (v88.get("valores") or []))
            vdesc = v88.get("descripcion","") or ""
            c88_html += (
                f'<div class="c88"><span class="cname">{esc(vname)}</span>'
                f'<span class="cval">= {esc(vvals)}</span>'
                f'{f" <span style=\'color:#555;font-size:10px\'>{esc(vdesc)}</span>" if vdesc else ""}'
                f'</div>'
            )
        c88_html += '</div>'

    return (
        f'<div class="campo-row" data-tipo="{esc(tipo)}" data-dom="{esc(dom)}" '
        f'data-fuente="{esc(fuente)}" data-nom="{esc(nom.lower())}" data-desc="{esc(extras.lower())}">'
        f'<div class="c-nom" style="padding-left:{12+indent}px" title="{esc(nom)}">{esc(nom)}</div>'
        f'<div class="c-niv" style="color:#555">{niv}</div>'
        f'<div class="c-tip"><span class="tag" style="background:{tc[0]};color:{tc[1]};font-size:9px">{esc(tipo)}</span></div>'
        f'<div class="c-pic" title="{esc(pic)}">{esc(pic[:18])}</div>'
        f'<div class="c-dom"><span class="tag" style="background:{dom_bg};color:{dom_fg};font-size:9px">{esc(dom)}</span></div>'
        f'<div class="c-val">{esc(extras[:60])}{c88_btn}</div>'
        f'</div>{c88_html}'
    )


def render_dict_tab(campos_data):
    registros = campos_data["registros"]
    total_campos = sum(len(r.get("campos",[])) for r in registros)
    n_grupos = len(registros)

    fuentes = sorted(set(r.get("fuente","") for r in registros))
    dominios= sorted(set(
        c.get("dominio","GENERAL")
        for r in registros for c in r.get("campos",[])
        if c.get("dominio","GENERAL") != "GENERAL"
    ))
    tipos   = sorted(set(c.get("tipo","") for r in registros for c in r.get("campos",[])))

    fuente_btns = '<button class="ftag active" data-filter="fuente" data-val="all">todas</button>'
    for f in fuentes:
        c = FUENTE_COLORS.get(f,("#1a1a1a","#888"))
        lbl = f.replace("S500_","").replace(".txt","")
        fuente_btns += f'<button class="ftag" data-filter="fuente" data-val="{esc(f)}" style="background:{c[0]};color:{c[1]};border-color:{c[1]}40">{esc(lbl)}</button>'

    dom_btns = '<button class="ftag active" data-filter="dom" data-val="all">todos</button>'
    for d in ["GENERAL"] + dominios:
        bg = "#0d1a2e" if d=="GENERAL" else "#1a0d2e"
        fg = "#555"    if d=="GENERAL" else "#c4a8f5"
        dom_btns += f'<button class="ftag" data-filter="dom" data-val="{esc(d)}" style="background:{bg};color:{fg};border-color:{fg}40">{esc(d)}</button>'

    tipo_btns = '<button class="ftag active" data-filter="tipo" data-val="all">todos</button>'
    for t in tipos:
        c = TIPO_COLORS.get(t,("#1a1a1a","#888"))
        tipo_btns += f'<button class="ftag" data-filter="tipo" data-val="{esc(t)}" style="background:{c[0]};color:{c[1]};border-color:{c[1]}40">{esc(t)}</button>'

    stats = (
        f'<div class="sc"><div class="num">{total_campos:,}</div><div class="lbl">Campos COBOL<div class="sub2">copybooks INC + src</div></div></div>'
        f'<div class="sc"><div class="num">{n_grupos}</div><div class="lbl">Grupos nivel 01</div></div>'
        f'<div class="sc"><div class="num">{len(fuentes)}</div><div class="lbl">Archivos fuente</div></div>'
        f'<div class="sc"><div class="num">{len(tipos)}</div><div class="lbl">Tipos de campo</div></div>'
    )

    grupos_html = ""
    for gi, r in enumerate(registros):
        nombre = r.get("nombre","")
        fuente = r.get("fuente","")
        linea  = r.get("linea","")
        redef  = r.get("redefine","")
        campos = r.get("campos",[])
        n = len(campos)
        fuente_lbl = fuente.replace("S500_","").replace(".txt","")
        fc = FUENTE_COLORS.get(fuente,("#1a1a1a","#888"))

        campos_html = "".join(render_campo(c, gi, ci, fuente) for ci,c in enumerate(campos))

        grupos_html += (
            f'<div class="grupo-section">'
            f'<div class="grupo-hdr">'
            f'<span>▸ <span class="chevron" style="display:none">▸</span>{esc(nombre)}'
            f'{f" <span style=\'color:#555;font-size:10px\'>REDEFINES {esc(redef)}</span>" if redef else ""}'
            f'</span>'
            f'<span class="meta">'
            f'<span class="tag" style="background:{fc[0]};color:{fc[1]};font-size:9px">{esc(fuente_lbl)}</span>'
            f' &nbsp; {n} campos &nbsp; línea {linea}</span>'
            f'</div>'
            f'<div class="grupo-body">'
            f'<div style="display:flex;background:#0d1218;border-bottom:1px solid #161b22;padding:4px 8px;font-size:10px;color:#555">'
            f'<div style="flex:0 0 320px;padding-left:12px">CAMPO</div>'
            f'<div style="flex:0 0 40px;text-align:center">NIV</div>'
            f'<div style="flex:0 0 130px">TIPO</div>'
            f'<div style="flex:0 0 130px">PIC</div>'
            f'<div style="flex:0 0 110px">DOMINIO</div>'
            f'<div style="flex:1">VALUE / OCCURS / REDEFINES</div>'
            f'</div>'
            f'{campos_html}'
            f'</div></div>'
        )

    return f"""
<div class="stats">{stats}</div>
<div class="fbar">
<input id="srch2" placeholder="Buscar campo o descripción…">
<span class="flbl">TIPO:</span>{tipo_btns}
</div>
<div class="fbar"><span class="flbl">DOMINIO:</span>{dom_btns}</div>
<div class="fbar"><span class="flbl">FUENTE:</span>{fuente_btns}</div>
<div class="wrap">
<div class="tbar"><span>Click en grupo para expandir · Click en 88·N para ver condiciones</span><span id="cnt2"></span></div>
{grupos_html}
</div>"""


# ══════════════════════════════════════════════════════════════════════════════
# MAIN
# ══════════════════════════════════════════════════════════════════════════════
def main():
    print("[LOAD] Vocabulario v4...")
    vocab_data = json.loads(VOCAB_JSON.read_text(encoding="utf-8"))

    print("[LOAD] Diccionario de campos...")
    campos_data = json.loads(CAMPOS_JSON.read_text(encoding="utf-8"))
    total_campos = sum(len(r.get("campos",[])) for r in campos_data["registros"])

    print(f"[BUILD] Vocabulario: {vocab_data['meta']['total_terminos']} términos")
    print(f"[BUILD] Campos: {total_campos:,} campos en {len(campos_data['registros'])} grupos")

    tab1 = render_vocab_tab(vocab_data)
    tab2 = render_dict_tab(campos_data)

    html = f"""<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<title>Banamex S500 · Vocabulario Completo — Negocio + Diccionario de Campos</title>
<style>{CSS}</style>
</head>
<body>
<header>
<img src="../../banamex-logo.png" alt="Banamex">
<div>
  <h1>S500 · Vocabulario Completo <span style="font-size:12px;color:#3d6fa0;font-weight:400">v4.0 + Diccionario COBOL</span></h1>
  <div class="sub">Gemelo Cognitivo &middot; Capa 1 (lenguaje) &middot; SPE-MM-001 &middot;
  {vocab_data['meta']['total_terminos']} términos curados &middot; {total_campos:,} campos COBOL &middot; Generado 2026-07-15</div>
</div>
</header>

<div class="tabs">
  <div class="tab active" data-tab="vocab-panel">Vocabulario de Negocio v4.0
    <span style="font-size:10px;color:#555;margin-left:6px">{vocab_data['meta']['total_terminos']} términos</span>
  </div>
  <div class="tab" data-tab="dict-panel">Diccionario de Campos COBOL
    <span style="font-size:10px;color:#555;margin-left:6px">{total_campos:,} campos</span>
  </div>
</div>

<div id="vocab-panel" class="tab-panel active">{tab1}</div>
<div id="dict-panel" class="tab-panel">{tab2}</div>

<script>{JS}</script>
</body>
</html>"""

    OUT_HTML.write_text(html, encoding="utf-8")
    kb = OUT_HTML.stat().st_size // 1024
    print(f"[OK] {OUT_HTML} — {kb} KB")

if __name__ == "__main__":
    main()
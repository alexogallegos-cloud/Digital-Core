#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""build-rules-report-v2.py — HTML v2 de reglas de negocio Informix.

Mejoras sobre v1:
  · Paleta dark BanCoppel (#0a1330) — consistente con vocabulary-report-bcop-v2.html
  · 4 tipos: FÓRMULA · VALIDACIÓN · UMBRAL · ESTADO  (con badges propios)
  · Filtro por Bounded Context (BC)
  · vocab_refs como micro-tags en evidencia
  · Columna BC en tabla
  · Tiles: total · fórmulas · validaciones · umbrales · estados · regulatorias · riesgo
  · BC summary cards debajo de reguladores

Genera: rules-report-bcop-v2.html · SPE-AM-001
"""
import json, base64
from collections import Counter

BASE = ("c:/Users/alejandro.gallegos/OneDrive - Accenture/Documents/Digital Core/"
        "03 - SPE/HVM/AM/BanCoppel/Informix/")

# Logo BanCoppel embebido como base64
with open(BASE + "bancoppel-logo.png", "rb") as _f:
    LOGO_B64 = base64.b64encode(_f.read()).decode()

data = json.load(open(BASE + "portal/data/business-rules-v2.json", encoding="utf-8"))
BR   = data["rules"]
META = data["stats"]

DOMN = {"bdicheq":"D04","bdicred":"D03","bdisac":"D05","bdispei":"D08",
        "bdicont":"D12","bdisolic":"D06","bdiaclaracion":"D07","bdimnsj":"D09",
        "bdicnweb":"D01","bdinteg":"D02","bdicobranza":"D11","bdisuc":"D10",
        "bdibts":"D13","bdiconsorcio":"D14","bdiarras":"D15"}

rows = []
for r in BR:
    regs = [x[0] for x in r.get("reg", [])]
    # sp_rel: callers/callees (top 2 each)
    sp_rel = r.get("sp_rel", {})
    rows.append({
        "id":    r["id"],
        "tipo":  r["tipo"],
        "cat":   r.get("categoria", "OPERACIONAL"),
        "sp":    r["sp"],
        "dom":   DOMN.get(r["db"], r["db"]),
        "line":  r["line"],
        "regs":  regs,
        "norma": (r["reg"][0][1] if r.get("reg") else ""),
        "code":  r["code"],
        "riesgo": r.get("riesgo", []),
        "bc":    r.get("bc", ""),
        "bc_name": r.get("bc_name", ""),
        "vr":    r.get("vocab_refs", []),
        "expl":  r.get("explicacion", ""),
        "econf": r.get("expl_conf", ""),
        "callers": sp_rel.get("callers", [])[:2],
        "callees": sp_rel.get("callees", [])[:2],
        "vd":   r.get("vocab_detail", [])[:3],
    })

by_tipo = Counter(r["tipo"] for r in rows)
by_reg  = Counter(x for r in rows for x in r["regs"])
by_bc   = Counter((r["bc"], r["bc_name"]) for r in rows if r["bc"])
by_cat  = Counter(r["cat"] for r in rows)
n_riesgo = sum(1 for r in rows if r["riesgo"])
n_reg    = sum(1 for r in rows if r["regs"])

n_expl = sum(1 for r in rows if r["expl"])
DATA = json.dumps(rows, ensure_ascii=False, separators=(",", ":"))
M = json.dumps({
    "total":    len(rows),
    "bytipo":   dict(by_tipo),
    "byreg":    dict(by_reg),
    "bybc":     {f"{bc}|||{bn}": cnt for (bc, bn), cnt in by_bc.most_common()},
    "bycat":    dict(by_cat.most_common()),
    "n_riesgo": n_riesgo,
    "n_reg":    n_reg,
    "n_expl":   n_expl,
    "sps_scanned": data["meta"]["sp_scanned"],
}, ensure_ascii=False)

HTML = r"""<!DOCTYPE html><html lang="es"><head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1.0">
<title>Informix · Reglas de Negocio v2</title>
<style>
:root{
  --bg:#060d1f;--bg2:#0a1535;--panel:#0e1e45;--line:#122FB1;
  --brand:#122FB1;--acc:#F0D224;--txt:#EAEDF7;--muted:#8a9cc4;
  --glass:rgba(18,47,177,.12);--glass-b:rgba(18,47,177,.25)
}
*{box-sizing:border-box;margin:0;padding:0}
body{background:var(--bg);color:var(--txt);font-family:'Inter',system-ui,sans-serif;
     height:100vh;display:flex;flex-direction:column;overflow:hidden}
header{background:linear-gradient(135deg,#060d1f 0%,#0d1e50 60%,#112680 100%);
       border-bottom:3px solid var(--brand);padding:10px 20px;flex-shrink:0;
       display:flex;justify-content:space-between;align-items:center;gap:16px}
header .logo{height:28px;object-fit:contain;flex-shrink:0}
header .hinfo{flex:1}
header h1{font-size:14px;font-weight:800;letter-spacing:.02em}
header .sub{font-size:9px;color:var(--muted);margin-top:2px}
header .badge{font-size:10px;color:var(--acc);font-weight:700;background:rgba(240,210,36,.12);
              padding:3px 9px;border-radius:4px;border:1px solid rgba(240,210,36,.35);
              white-space:nowrap;flex-shrink:0}
#tiles{display:flex;gap:6px;padding:7px 20px;flex-wrap:wrap;flex-shrink:0}
.tile{background:var(--glass);backdrop-filter:blur(14px) saturate(140%);
      border-radius:8px;padding:6px 13px;border:1px solid var(--glass-b);
      border-left:3px solid var(--brand)}
.tile .n{font-size:16px;font-weight:800}
.tile .l{font-size:8px;color:var(--muted);text-transform:uppercase;letter-spacing:.05em}
.tile.t-f{border-left-color:#2e7d52}.tile.t-v{border-left-color:#1a4a8a}
.tile.t-u{border-left-color:#b45309}.tile.t-e{border-left-color:#0f766e}
.tile.t-reg{border-left-color:#7c3aed}.tile.t-ri{border-left-color:#dc2626}
#regbar{display:flex;gap:5px;padding:0 20px 4px;flex-wrap:wrap;flex-shrink:0}
.rc{background:var(--panel);border-radius:6px;padding:3px 9px;font-size:10px;
    display:flex;gap:5px;align-items:center;border:1px solid rgba(18,47,177,.4)}
.rc b{color:#fff}.rc .d{width:7px;height:7px;border-radius:2px}
#catbar{display:flex;gap:4px;padding:5px 20px 6px;flex-wrap:wrap;flex-shrink:0;
        border-bottom:1px solid rgba(18,47,177,.5);align-items:center;
        background:rgba(18,47,177,.06)}
#catbar .lbl2{font-size:9px;color:var(--muted);text-transform:uppercase;
              letter-spacing:.06em;margin-right:4px;flex-shrink:0}
.cat-pill{border-radius:5px;padding:4px 11px;font-size:9px;font-weight:700;
           cursor:pointer;user-select:none;border:1px solid rgba(18,47,177,.35);
           color:#a0b4e0;background:rgba(18,47,177,.15);transition:all .15s;white-space:nowrap}
.cat-pill:hover{border-color:var(--brand);color:var(--txt)}
.cat-pill.on{border-color:var(--acc) !important;color:var(--acc);
              background:rgba(240,210,36,.08) !important}
.cat-pill .cn{font-size:11px;font-weight:800;margin-right:3px}
#ctrl{display:flex;gap:8px;padding:6px 20px;align-items:center;flex-wrap:wrap;
      flex-shrink:0;background:var(--bg2);border-bottom:1px solid rgba(18,47,177,.4)}
#q{background:var(--panel);border:1px solid rgba(18,47,177,.5);border-radius:6px;
   color:var(--txt);padding:6px 10px;font-size:12px;width:220px;outline:none}
#q:focus{border-color:var(--acc)}
.fg{display:flex;gap:4px;align-items:center}
.fg .lbl{font-size:9px;color:var(--muted);text-transform:uppercase;margin-right:2px}
.chip{background:var(--panel);border:1px solid rgba(18,47,177,.4);border-radius:12px;
      padding:3px 8px;font-size:10px;color:var(--muted);cursor:pointer;user-select:none}
.chip:hover{border-color:var(--brand);color:var(--txt)}
.chip.on{border-color:var(--acc);color:var(--acc);background:rgba(240,210,36,.08)}
#count{font-size:10px;color:var(--muted);margin-left:auto}
#wrap{flex:1;overflow:auto;padding:0 20px 20px}
table{width:100%;border-collapse:collapse;font-size:12px}
thead th{position:sticky;top:0;background:var(--bg2);text-align:left;padding:6px 8px;
         font-size:9px;text-transform:uppercase;letter-spacing:.05em;color:var(--muted);
         border-bottom:1px solid var(--line);cursor:pointer;white-space:nowrap;z-index:5}
thead th:hover{color:var(--txt)}
tbody td{padding:5px 8px;border-bottom:1px solid rgba(38,49,124,.4);vertical-align:top}
tbody tr:hover{background:rgba(18,47,177,.1)}
.id{font-family:'Cascadia Code',monospace;font-size:9px;color:#6a7ab0;white-space:nowrap}
.tp{font-size:9px;font-weight:700;padding:2px 6px;border-radius:3px;white-space:nowrap}
.tp-F{background:#052e16;color:#86efac}
.tp-V{background:#1e2a3f;color:#93c5fd}
.tp-U{background:#3d1a00;color:#fdba74}
.tp-E{background:#0a2a2a;color:#5eead4}
.cat-tag{font-size:8px;font-weight:700;padding:2px 6px;border-radius:3px;
         white-space:nowrap;display:inline-block}
.sp{font-family:'Cascadia Code',monospace;font-size:10px;color:#c8d0f0;white-space:nowrap}
.code{font-family:'Cascadia Code',monospace;font-size:10px;color:#b8c0de;
      white-space:pre-wrap;word-break:break-word}
.rg{font-size:8px;font-weight:700;padding:1px 5px;border-radius:8px;
    margin:0 2px 2px 0;display:inline-block}
.norma{font-size:9px;color:var(--muted);margin-top:2px;line-height:1.3}
.ri{font-size:9px;color:#fca5a5;margin-top:2px}
.vref{font-size:8px;padding:1px 4px;border-radius:3px;margin:0 2px 2px 0;
      display:inline-block;background:rgba(240,210,36,.1);color:#e6ca40;
      border:1px solid rgba(240,210,36,.2)}
.expl{font-size:10px;color:#d0e8f8;line-height:1.35}
.econf{font-size:7px;font-weight:700;padding:1px 4px;border-radius:3px;margin-left:4px;
       display:inline-block;vertical-align:middle}
.ec-literal{background:#1a3a1a;color:#6ee87a}
.ec-formula{background:#2a2500;color:#f0d224}
.ec-norma{background:#25103a;color:#c084fc}
.ec-infer{background:#1e2535;color:#8a9cc4}
.rel-sp{font-family:'Cascadia Code',monospace;font-size:9px;color:#8ab8e8;
        display:inline-block;margin:1px 2px;padding:1px 4px;border-radius:3px;
        background:rgba(18,47,177,.18);border:1px solid rgba(18,47,177,.35)}
.rel-lbl{font-size:7px;color:var(--muted);text-transform:uppercase;
         letter-spacing:.05em;margin-bottom:2px}
.vd-row{font-size:9px;margin:1px 0}
.vd-t{font-family:'Cascadia Code',monospace;color:#e6ca40;font-size:8px}
.vd-m{color:#a0b4d0;font-size:9px}
footer{font-size:9px;color:var(--muted);padding:5px 20px;flex-shrink:0;
       border-top:1px solid var(--line)}
</style></head><body>
<header>
  <img class="logo" src="data:image/png;base64,__LOGO__" alt="BanCoppel">
  <div class="hinfo">
    <h1>Reglas de Negocio · Informix v2</h1>
    <div class="sub">SPE-AM-001 · Etapa 3 · vocabulario 787 términos · 2026-08-02</div>
  </div>
  <div class="badge" id="hbadge"></div>
</header>
<div id="tiles"></div>
<div id="regbar"></div>
<div id="catbar"><span class="lbl2">Categoría</span></div>
<div id="ctrl">
  <input id="q" placeholder="Buscar SP, código, norma, vocab…" autocomplete="off">
  <div class="fg"><span class="lbl">Tipo</span><div id="ftipo"></div></div>
  <div class="fg"><span class="lbl">Regulador</span><div id="freg"></div></div>
  <div class="fg"><span class="lbl">Solo con</span><div id="fri"></div></div>
  <span id="count"></span>
</div>
<div id="wrap"><table><thead><tr>
  <th data-k="id">ID</th>
  <th data-k="tipo">Tipo</th>
  <th data-k="cat">Categoría</th>
  <th data-k="sp">SP · L</th>
  <th data-k="dom">Dom.</th>
  <th>Regulador · norma</th>
  <th data-k="code">Evidencia · vocab refs · ⚠</th>
  <th data-k="expl">Explicación de negocio</th>
  <th>SPs relacionados · vocab</th>
</tr></thead><tbody id="tb"></tbody></table></div>
<footer>
  Categorías: REGULATORIO · CÁLCULO FINANCIERO · CONTABILIDAD · PAGOS · ATENCIÓN · RIESGO/CRÉDITO · FLUJO · PARAMETRÍA · OPERACIONAL
  &nbsp;|&nbsp; ⚠ riesgo equiv: TRUNC/ROUND/base-360/MONEY · explicación: <span style="color:#6ee87a">literal</span> · <span style="color:#f0d224">fórmula</span> · <span style="color:#c084fc">norma</span> · <span style="color:#8a9cc4">inferido</span>
  &nbsp;|&nbsp; Fuente: extract-rules-v2.py → enrich-rules.py → business-rules-v2.json v2.2 (15,368 boilerplate excluidas)
</footer>
<script>
const DATA=__DATA__, M=__META__;
const REGCOL={
  CNBV:'#2e6b48',Banxico:'#1e5a8a',CONDUSEF:'#6b3080',
  SAT:'#8b6b20',TESOFE:'#7a2020',IPAB:'#5a2a6b'
};
const TPLABEL={'FÓRMULA':'FÓRM','VALIDACIÓN':'VALID','UMBRAL':'UMBR','ESTADO':'ESTAD'};
const TPCLS  ={'FÓRMULA':'F','VALIDACIÓN':'V','UMBRAL':'U','ESTADO':'E'};

// Categoría metadata
const CAT_META={
  'REGULATORIO':         {col:'#5a2a7a',bg:'#2a0a3a',lbl:'REGUL'},
  'CALCULO_FINANCIERO':  {col:'#2e6b48',bg:'#052e16',lbl:'CÁLC'},
  'CONTABILIDAD_REPORTES':{col:'#1e5a8a',bg:'#091e40',lbl:'CONT'},
  'PAGOS_TRANSFERENCIAS':{col:'#7c4a10',bg:'#3d1a00',lbl:'PAGOS'},
  'ATENCION_CLIENTE':    {col:'#1a5050',bg:'#0a2020',lbl:'SAC'},
  'RIESGO_CREDITO':      {col:'#8b6020',bg:'#3d2a00',lbl:'RIESGO'},
  'FLUJO_OPERATIVO':     {col:'#4a2a7a',bg:'#1a0a3a',lbl:'FLUJO'},
  'PARAMETRIA':          {col:'#3a4a6a',bg:'#0a1a30',lbl:'PARAM'},
  'OPERACIONAL':         {col:'#4a5068',bg:'#1a1a2a',lbl:'OPER'},
};

// Header badge
document.getElementById('hbadge').textContent=`${M.total.toLocaleString()} reglas · ${M.sps_scanned.toLocaleString()} SPs`;

// Tiles
document.getElementById('tiles').innerHTML=[
  ['',M.total,'Total reglas'],
  ['t-f',M.bytipo['FÓRMULA']||0,'Fórmulas'],
  ['t-v',M.bytipo['VALIDACIÓN']||0,'Validaciones'],
  ['t-u',M.bytipo['UMBRAL']||0,'Umbrales'],
  ['t-e',M.bytipo['ESTADO']||0,'Estados'],
  ['t-reg',M.n_reg,'Regulatorias'],
  ['t-ri',M.n_riesgo,'⚠ Riesgo equiv.'],
  ['t-expl',M.n_expl,'Con explicación'],
].map(([c,n,l])=>`<div class="tile ${c}"><div class="n">${(n||0).toLocaleString()}</div><div class="l">${l}</div></div>`).join('');

// Reg bar
document.getElementById('regbar').innerHTML=
  ['CNBV','Banxico','CONDUSEF','SAT','TESOFE','IPAB']
  .filter(r=>M.byreg[r])
  .map(r=>`<div class="rc"><span class="d" style="background:${REGCOL[r]}"></span>${r} <b>${M.byreg[r].toLocaleString()}</b></div>`)
  .join('');

// Cat bar
const catEntries=Object.entries(M.bycat).sort((a,b)=>b[1]-a[1]);
const catBar=document.getElementById('catbar');
catEntries.forEach(([cat,cnt])=>{
  const m=CAT_META[cat]||{col:'#4a5068',bg:'#1a1a2a',lbl:cat.slice(0,5)};
  const p=document.createElement('span');
  p.className='cat-pill';
  p.dataset.cat=cat;
  p.style.borderColor=m.col+'44';
  p.style.background=m.bg;
  p.innerHTML=`<span class="cn" style="color:${m.col}">${cnt.toLocaleString()}</span>${m.lbl}`;
  p.title=cat+' — '+cnt+' reglas';
  catBar.appendChild(p);
});

let fReg=new Set(), fTipo=new Set(), fCat=new Set(), fRi=false, q='';
let sortKey='id', sortDir=1;

function chips(el,vals,set,lab){
  document.getElementById(el).innerHTML=vals.map(v=>`<span class="chip" data-v="${v}">${lab(v)}</span>`).join('');
  document.querySelectorAll('#'+el+' .chip').forEach(c=>c.onclick=()=>{
    const v=c.dataset.v;
    if(set.has(v)){set.delete(v);c.classList.remove('on')}else{set.add(v);c.classList.add('on')}
    render();
  });
}
chips('freg',['CNBV','Banxico','CONDUSEF','SAT','TESOFE','IPAB'],fReg,v=>v);
chips('ftipo',['FÓRMULA','VALIDACIÓN','UMBRAL','ESTADO'],fTipo,v=>v);
document.getElementById('fri').innerHTML='<span class="chip" id="rich">⚠ equiv.</span>';
document.getElementById('rich').onclick=function(){fRi=!fRi;this.classList.toggle('on',fRi);render()};
document.getElementById('q').oninput=e=>{q=e.target.value.toLowerCase();render()};

document.querySelectorAll('.cat-pill').forEach(p=>p.onclick=function(){
  const c=this.dataset.cat;
  if(fCat.has(c)){fCat.delete(c);this.classList.remove('on')}
  else{fCat.add(c);this.classList.add('on')}
  render();
});

document.querySelectorAll('thead th[data-k]').forEach(th=>th.onclick=function(){
  const k=this.dataset.k;
  if(sortKey===k)sortDir*=-1; else{sortKey=k;sortDir=1;}
  render();
});

const tb=document.getElementById('tb');
function esc(s){return String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;')}

function render(){
  let rs=DATA.filter(r=>{
    if(fReg.size && !r.regs.some(x=>fReg.has(x))) return false;
    if(fTipo.size && !fTipo.has(r.tipo)) return false;
    if(fCat.size && !fCat.has(r.cat)) return false;
    if(fRi && !r.riesgo.length) return false;
    if(q && !(r.sp.toLowerCase().includes(q)
           || r.code.toLowerCase().includes(q)
           || (r.norma||'').toLowerCase().includes(q)
           || (r.cat||'').toLowerCase().includes(q)
           || (r.expl||'').toLowerCase().includes(q)
           || (r.vr||[]).some(t=>t.includes(q))
           || (r.vd||[]).some(v=>v.mean&&v.mean.toLowerCase().includes(q))
           || (r.callers||[]).some(s=>s.includes(q))
           || (r.callees||[]).some(s=>s.includes(q))))
      return false;
    return true;
  });

  rs.sort((a,b)=>{
    let av=a[sortKey]||'', bv=b[sortKey]||'';
    if(typeof av==='number') return (av-bv)*sortDir;
    return String(av).localeCompare(String(bv))*sortDir;
  });

  const total=rs.length;
  const slice=rs.slice(0,600);

  const ECONF_CLS={'literal':'ec-literal','formula':'ec-formula','norma':'ec-norma','infer':'ec-infer'};
  const ECONF_LBL={'literal':'literal','formula':'fórmula','norma':'norma','infer':'inferido'};

  tb.innerHTML=slice.map(r=>{
    const cm=CAT_META[r.cat]||{col:'#4a5068',bg:'#1a1a2a',lbl:r.cat};
    const catTag=`<span class="cat-tag" style="background:${cm.bg};color:${cm.col};border:1px solid ${cm.col}44">${cm.lbl}</span>`;
    const vrTags=(r.vr||[]).slice(0,5).map(t=>`<span class="vref">${esc(t)}</span>`).join('');
    const riTags=r.riesgo.map(x=>`<div class="ri">⚠ ${esc(x)}</div>`).join('');

    // Explicación
    let explCell='<span style="color:#3a4a6a;font-size:9px">—</span>';
    if(r.expl){
      const cls=ECONF_CLS[r.econf]||'ec-infer';
      const lbl=ECONF_LBL[r.econf]||r.econf;
      explCell=`<div class="expl">${esc(r.expl)}<span class="econf ${cls}">${lbl}</span></div>`;
    }

    // Relacionados
    let relCell='';
    if((r.callers||[]).length||(r.callees||[]).length){
      const ci=r.callers.map(s=>`<span class="rel-sp" title="llama a este SP">↓ ${esc(s)}</span>`).join('');
      const co=r.callees.map(s=>`<span class="rel-sp" title="este SP llama a">↑ ${esc(s)}</span>`).join('');
      if(ci) relCell+=`<div class="rel-lbl">callers</div>${ci}`;
      if(co) relCell+=`<div class="rel-lbl" style="margin-top:3px">llama a</div>${co}`;
    }
    if((r.vd||[]).length){
      const vdRows=r.vd.filter(v=>v.mean).map(v=>`<div class="vd-row"><span class="vd-t">${esc(v.term)}</span> <span class="vd-m">${esc(v.mean.slice(0,40))}</span></div>`).join('');
      if(vdRows) relCell+=`<div class="rel-lbl" style="margin-top:4px">vocab</div>${vdRows}`;
    }
    if(!relCell) relCell='<span style="color:#3a4a6a;font-size:9px">—</span>';

    return `<tr>
      <td class="id">${r.id}</td>
      <td><span class="tp tp-${TPCLS[r.tipo]||'V'}">${TPLABEL[r.tipo]||r.tipo}</span></td>
      <td>${catTag}</td>
      <td><span class="sp">${esc(r.sp)}</span><div style="font-size:9px;color:var(--muted)">L${r.line}</div></td>
      <td style="font-size:9px;color:#7a8ab0;white-space:nowrap">${r.dom}</td>
      <td>
        ${r.regs.map(x=>`<span class="rg" style="background:${REGCOL[x]||'#2a2a4a'};color:#fff">${x}</span>`).join('')
          ||'<span style="color:#4a5068;font-size:9px">—</span>'}
        ${r.norma?`<div class="norma">${esc(r.norma.slice(0,65))}</div>`:''}
      </td>
      <td>
        <div class="code">${esc(r.code)}</div>
        ${vrTags?`<div style="margin-top:3px">${vrTags}</div>`:''}
        ${riTags}
      </td>
      <td>${explCell}</td>
      <td>${relCell}</td>
    </tr>`;
  }).join('');

  document.getElementById('count').textContent=
    `${total.toLocaleString()} de ${DATA.length.toLocaleString()}`+(total>600?' (primeras 600)':'');
}

render();
</script></body></html>"""

HTML = HTML.replace("__DATA__", DATA).replace("__META__", M).replace("__LOGO__", LOGO_B64)
out_path = BASE + "portal/rules-report-bcop-v2.html"
open(out_path, "w", encoding="utf-8").write(HTML)
print(f"rules-report-bcop-v2.html escrito · {len(rows)} reglas · {n_expl} con explicación · {n_riesgo} con riesgo equiv")

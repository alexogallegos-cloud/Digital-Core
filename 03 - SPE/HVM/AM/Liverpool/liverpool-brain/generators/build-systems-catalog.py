#!/usr/bin/env python3
"""Liverpool — Catálogo de Sistemas (desde SUDs).
Reads portal/data/sud-catalog-liv.json → portal/systems-catalog-liv.html"""
import json
from pathlib import Path
import _liv_shared as S

HERE = Path(__file__).parent
DATA = HERE.parent / "portal" / "data" / "sud-catalog-liv.json"
OUT  = HERE.parent / "portal" / "systems-catalog-liv.html"

d = json.loads(DATA.read_text(encoding="utf-8"))
meta, systems = d["meta"], d["systems"]

DOM = {
    "R01": "Gestión Comercial", "R02": "Clientes y Lealtad", "R03": "Servicios Financieros",
    "R04": "Cadena de Suministro", "R05": "Canales Digitales", "R06": "Operaciones de Tienda",
    "R07": "Finanzas y Contabilidad", "R08": "Recursos Humanos", "R09": "Analítica e BI",
    "R10": "Infraestructura", "R99": "Sin clasificar",
}

stats = (S.stat(meta["systems"], "Sistemas") + S.stat(meta["servers"], "Servidores") +
         S.stat(meta["interfaces"], "Interfaces") + S.stat(meta["risks"], "Riesgos", "red") +
         S.stat(meta["glossary_terms"], "Glosario", "pink"))
hero = S.hero(
    "Liverpool · Landscape aplicativo · Solution Understanding Documents",
    "Catálogo de Sistemas",
    f"{meta['systems']} aplicaciones del landscape Liverpool destiladas de los SUDs (documentos de "
    "toma de control AMS). Cada sistema con su propósito, servidores, bases de datos, interfaces, "
    "dependencias y riesgos reales. Los hubs de integración (SAP ECC, Gestor4PL, Cherwell) concentran el acoplamiento.",
    "SPE-AM-003 <em>›</em> Landscape <em>›</em> Catálogo de Sistemas", "SUD · AMS", stats)

data_js = json.dumps({"meta": meta, "systems": systems, "dom": DOM}, ensure_ascii=False, separators=(",", ":"))
dom_counts = meta["by_domain"]
dom_pills = "".join(
    f'<span class="pill" data-dom="{k}">{k}<span style="opacity:.6;margin-left:3px">{dom_counts.get(k,0)}</span></span>'
    for k in sorted(DOM) if dom_counts.get(k, 0)
)

extra = """
#fbar{position:sticky;top:0;z-index:20}
#wrap{flex:1;overflow:auto;padding:8px 24px 20px;min-height:0}
.gh{display:flex;align-items:baseline;gap:12px;margin:20px 0 10px;padding-bottom:8px;border-bottom:1px solid var(--line)}
.gh .gc{font-size:9px;font-weight:800;letter-spacing:.1em;color:#0d0408;background:var(--sky);border-radius:20px;padding:2px 9px}
.gh h3{font-size:15px;font-weight:800;color:var(--ink)}
.gh .gn{font-size:10px;color:var(--muted2)}
.sys{border:1px solid var(--line);border-radius:12px;margin-bottom:8px;background:rgba(255,255,255,.02);overflow:hidden}
.sys-hd{display:grid;grid-template-columns:1fr auto;gap:12px;align-items:center;padding:12px 16px;cursor:pointer;transition:background .15s}
.sys-hd:hover{background:rgba(224,1,152,.05)}
.sys.op .sys-hd{background:rgba(224,1,152,.08)}
.sys-name{font-size:14px;font-weight:800;color:var(--ink)}
.sys-vendor{font-size:10px;color:var(--muted2);font-weight:400;margin-left:8px}
.sys-purpose{font-size:11.5px;color:var(--muted);margin-top:3px;line-height:1.45;max-width:90ch}
.sys-meta{display:flex;gap:6px;align-items:center;flex-wrap:wrap;justify-content:flex-end}
.mtag{font-size:8.5px;font-weight:800;padding:2px 7px;border-radius:4px;border:1px solid;white-space:nowrap}
.tt-core{color:#fca5a5;border-color:#f8717155;background:rgba(248,113,113,.1)}
.tt-processors{color:#fde047;border-color:#eab30855;background:rgba(234,179,8,.1)}
.tt-channels{color:var(--sky);border-color:#87C3D355;background:rgba(135,195,211,.1)}
.tt-data{color:#86efac;border-color:#22c55e55;background:rgba(34,197,94,.1)}
.tt-integration{color:var(--rose);border-color:#DA7AB055;background:rgba(218,122,176,.1)}
.tt-compliance{color:#d8b4fe;border-color:#a855f755;background:rgba(168,85,247,.1)}
.q-rich{color:#86efac;border-color:#22c55e55;background:rgba(34,197,94,.08)}
.q-partial{color:#fde047;border-color:#eab30855;background:rgba(234,179,8,.08)}
.q-template{color:var(--muted2);border-color:rgba(255,255,255,.12);background:rgba(255,255,255,.03)}
.cnt{font-size:9px;color:var(--muted);font-family:'Cascadia Code',monospace;white-space:nowrap}
.cnt b{color:var(--sky)}
.det{display:none;padding:4px 16px 16px;border-top:1px solid var(--line)}
.sys.op .det{display:block}
.dsec{margin-top:12px}
.dsec h4{font-size:9.5px;font-weight:800;letter-spacing:.08em;text-transform:uppercase;color:var(--rose);margin-bottom:6px}
table.dt{width:100%;border-collapse:collapse;font-size:10.5px}
table.dt th{text-align:left;color:var(--muted2);font-size:8.5px;text-transform:uppercase;letter-spacing:.05em;padding:3px 8px;border-bottom:1px solid var(--line)}
table.dt td{padding:3px 8px;border-bottom:1px solid rgba(224,1,152,.06);color:var(--txt);font-family:'Cascadia Code','Consolas',monospace;font-size:10px}
.chip{display:inline-block;font-size:9.5px;padding:2px 8px;border-radius:12px;border:1px solid rgba(135,195,211,.25);background:rgba(135,195,211,.07);color:var(--sky);margin:2px 3px 2px 0}
.risk-item{font-size:10.5px;color:#fca5a5;padding:3px 0;line-height:1.4}.risk-item b{color:#f87171;margin-right:4px}
.gl-item{font-size:10.5px;color:var(--muted);padding:2px 0;line-height:1.4}.gl-item b{color:var(--ink)}
.if-cp{color:var(--rose)}
.empty{color:var(--muted2);font-size:10px;font-style:italic}
"""

body = f"""
<div id="fbar">
  <input id="q" type="search" placeholder="🔍 sistema, vendor, servidor, interfaz…" autocomplete="off">
  <div class="sep"></div>
  <span class="pill on" data-dom="">Todos</span>
  {dom_pills}
  <div class="sep"></div>
  <span class="pill" data-q="rich">Solo ricos</span>
  <span id="info"></span>
</div>
<div id="wrap"><div id="list"></div></div>
"""

script = """
const D=DATA_PLACEHOLDER;
let fDom='', fRich=false, fQ='';
const esc=s=>String(s==null?'':s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');
const open=new Set();

function detail(s){
  let h='<div class="det">';
  if(s.technologies&&s.technologies.length)
    h+=`<div class="dsec"><h4>Tecnologías</h4>${s.technologies.map(t=>`<span class="chip">${esc(t)}</span>`).join('')}</div>`;
  if(s.servers&&s.servers.length)
    h+=`<div class="dsec"><h4>Servidores (${s.servers.length})</h4><table class="dt"><tr><th>Hostname</th><th>IP</th><th>Plataforma</th><th>SO</th><th>Specs</th></tr>`+
       s.servers.map(v=>`<tr><td>${esc(v.hostname)}</td><td>${esc(v.ip)}</td><td>${esc(v.platform)}</td><td>${esc(v.os)}</td><td>${esc(v.specs)}</td></tr>`).join('')+`</table></div>`;
  if(s.databases&&s.databases.length)
    h+=`<div class="dsec"><h4>Bases de datos (${s.databases.length})</h4><table class="dt"><tr><th>Nombre</th><th>Motor</th><th>IP</th></tr>`+
       s.databases.map(v=>`<tr><td>${esc(v.name)}</td><td>${esc(v.engine)}</td><td>${esc(v.ip)}</td></tr>`).join('')+`</table></div>`;
  if(s.interfaces&&s.interfaces.length)
    h+=`<div class="dsec"><h4>Interfaces (${s.interfaces.length})</h4><table class="dt"><tr><th>Nombre</th><th>Tipo</th><th>Dir</th><th>Contraparte</th><th>Protocolo</th></tr>`+
       s.interfaces.map(v=>`<tr><td>${esc(v.name)}</td><td>${esc(v.type)}</td><td>${esc(v.direction)}</td><td class="if-cp">${esc(v.counterpart)}</td><td>${esc(v.protocol)}</td></tr>`).join('')+`</table></div>`;
  if(s.risks&&s.risks.length)
    h+=`<div class="dsec"><h4>Riesgos e issues (${s.risks.length})</h4>`+
       s.risks.map(v=>`<div class="risk-item"><b>${esc(v.kind||'R')}</b>${esc(v.desc)}</div>`).join('')+`</div>`;
  if(s.volumetria) h+=`<div class="dsec"><h4>Volumetría</h4><div class="gl-item">${esc(s.volumetria)}</div></div>`;
  if(s.batch) h+=`<div class="dsec"><h4>Batch</h4><div class="gl-item">${esc(s.batch)}</div></div>`;
  if(s.glossary&&s.glossary.length)
    h+=`<div class="dsec"><h4>Glosario (${s.glossary.length})</h4>`+
       s.glossary.map(v=>`<div class="gl-item"><b>${esc(v.term)}</b> — ${esc(v.meaning)}</div>`).join('')+`</div>`;
  h+='</div>';
  return h;
}

function render(){
  const q=fQ.toLowerCase().trim();
  let rows=D.systems.filter(s=>{
    if(fDom&&s.domain!==fDom) return false;
    if(fRich&&s.fill_quality!=='rich') return false;
    if(q){
      const hay=(s.system+' '+(s.vendor||'')+' '+(s.purpose||'')+' '+JSON.stringify(s.servers||[])+' '+JSON.stringify(s.interfaces||[])).toLowerCase();
      if(!hay.includes(q)) return false;
    }
    return true;
  });
  // group by domain
  const groups={};
  rows.forEach(s=>{(groups[s.domain]=groups[s.domain]||[]).push(s);});
  let h='';
  Object.keys(groups).sort().forEach(dk=>{
    const gs=groups[dk];
    h+=`<div class="gh"><span class="gc">${esc(dk)}</span><h3>${esc(D.dom[dk]||dk)}</h3><span class="gn">${gs.length} sistema(s)</span></div>`;
    gs.sort((a,b)=>(b.servers||[]).length+(b.interfaces||[]).length-((a.servers||[]).length+(a.interfaces||[]).length));
    gs.forEach(s=>{
      const id=s.slug, isop=open.has(id);
      const tt=s.togaf_type||'channels';
      h+=`<div class="sys${isop?' op':''}" data-id="${esc(id)}">
        <div class="sys-hd">
          <div><div class="sys-name">${esc(s.system)}${s.vendor?`<span class="sys-vendor">· ${esc(s.vendor)}</span>`:''}</div>
            <div class="sys-purpose">${esc(s.purpose)}</div></div>
          <div class="sys-meta">
            <span class="cnt" title="Servidores · Bases de datos · Interfaces · Riesgos e issues"><b>${(s.servers||[]).length}</b> servidores · <b>${(s.databases||[]).length}</b> BD · <b>${(s.interfaces||[]).length}</b> interfaces · <b>${(s.risks||[]).length}</b> riesgos</span>
            <span class="mtag tt-${tt}">${esc(tt)}</span>
            <span class="mtag q-${s.fill_quality}">${esc(s.fill_quality)}</span>
          </div>
        </div>${isop?detail(s):''}</div>`;
    });
  });
  document.getElementById('list').innerHTML=h||'<p class="empty" style="padding:30px">Sin resultados</p>';
  document.getElementById('info').textContent=`${rows.length} sistemas`;
}
document.getElementById('list').addEventListener('click',e=>{
  const el=e.target.closest('.sys'); if(!el) return;
  const id=el.dataset.id; open.has(id)?open.delete(id):open.add(id); render();
});
document.querySelectorAll('.pill[data-dom]').forEach(p=>p.addEventListener('click',()=>{
  document.querySelectorAll('.pill[data-dom]').forEach(x=>x.classList.remove('on'));p.classList.add('on');fDom=p.dataset.dom;render();}));
const rp=document.querySelector('.pill[data-q]');
rp.addEventListener('click',()=>{fRich=!fRich;rp.classList.toggle('on',fRich);render();});
let qt;document.getElementById('q').addEventListener('input',e=>{clearTimeout(qt);qt=setTimeout(()=>{fQ=e.target.value;render();},160);});
render();
""".replace("DATA_PLACEHOLDER", data_js)

OUT.write_text(S.page("Liverpool · Catálogo de Sistemas", hero, body, extra, script), encoding="utf-8")
print(f"systems-catalog -> {OUT.name} ({round(OUT.stat().st_size/1024,1)} KB) · {meta['systems']} sistemas")

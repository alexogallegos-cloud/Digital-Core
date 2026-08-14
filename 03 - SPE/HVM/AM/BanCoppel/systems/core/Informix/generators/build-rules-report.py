#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""build-rules-report.py — Reporte HTML de reglas de negocio, filtrable por
regulador / dominio / tipo / riesgo. Consume business-rules.json (embebido).
Genera: rules-report-bcop.html · Etapa 3 · SPE-AM-001"""
import json
from collections import Counter

BASE = ("c:/Users/alejandro.gallegos/OneDrive - Accenture/Documents/Digital Core/"
        "03 - SPE/HVM/AM/BanCoppel/Informix/")
BR = json.load(open(BASE + "portal/data/business-rules.json", encoding="utf-8"))

DOMN = {"bdicheq":"D04 Cheques","bdicred":"D03 Créditos","bdisac":"D05 Saldos","bdispei":"D08 SPEI",
        "bdicont":"D12 Contab.","bdisolic":"D06 Solic.","bdiaclaracion":"D07 Aclar.","bdimnsj":"D09 Msj",
        "bdicnweb":"D01 Canal","bdinteg":"D02 Integr.","bdicobranza":"D11 Cobr.","bdisuc":"D10 Suc."}

rows = []
for r in BR["rules"]:
    regs = [x[0] for x in r.get("reg", [])]
    rows.append({"id": r["id"], "tipo": r["tipo"], "sp": r["sp"],
                 "dom": DOMN.get(r["db"], r["db"]), "line": r["line"],
                 "regs": regs, "norma": (r["reg"][0][1] if r.get("reg") else ""),
                 "code": r["code"], "riesgo": r.get("riesgo", [])})

byreg = Counter(x for r in rows for x in r["regs"])
bytipo = Counter(r["tipo"] for r in rows)
n_riesgo = sum(1 for r in rows if r["riesgo"])
DATA = json.dumps(rows, ensure_ascii=False, separators=(",", ":"))
M = json.dumps({"total": len(rows), "byreg": byreg, "bytipo": bytipo,
                "n_riesgo": n_riesgo, "n_reg": sum(1 for r in rows if r["regs"])}, ensure_ascii=False)

HTML = """<!DOCTYPE html><html lang="es"><head><meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<title>Informix · Reglas de Negocio y Fórmulas</title>
<style>
:root{--bg:#14142b;--bg2:#1A1A2E;--panel:#1f1f3a;--line:#2c2c50;--magenta:#A100FF;--txt:#E8E8F0;--muted:#9a9ab5}
*{box-sizing:border-box;margin:0;padding:0}
body{background:var(--bg);color:var(--txt);font-family:'Inter',system-ui,sans-serif;height:100vh;display:flex;flex-direction:column;overflow:hidden}
header{background:linear-gradient(135deg,#001a4d,#1a004d);border-bottom:1px solid var(--magenta);padding:11px 20px;flex-shrink:0}
header h1{font-size:15px;font-weight:800}header .sub{font-size:9px;color:var(--muted);margin-top:2px}
#tiles{display:flex;gap:8px;padding:9px 20px;flex-wrap:wrap;flex-shrink:0}
.tile{background:var(--panel);border-radius:8px;padding:7px 13px;border-left:3px solid var(--line)}
.tile .n{font-size:18px;font-weight:800}.tile .l{font-size:8px;color:var(--muted);text-transform:uppercase;letter-spacing:.05em}
.tile.f{border-left-color:#2e6b48}.tile.reg{border-left-color:#A100FF}.tile.ri{border-left-color:#ef4444}
#regbar{display:flex;gap:6px;padding:0 20px 8px;flex-wrap:wrap;flex-shrink:0}
.rc{background:var(--panel);border-radius:6px;padding:4px 10px;font-size:10px;display:flex;gap:6px;align-items:center}
.rc b{color:#fff}.rc .d{width:8px;height:8px;border-radius:2px}
#ctrl{display:flex;gap:10px;padding:8px 20px;align-items:center;flex-wrap:wrap;flex-shrink:0;border-top:1px solid var(--line);border-bottom:1px solid var(--line);background:var(--bg2)}
#q{background:var(--panel);border:1px solid var(--line);border-radius:6px;color:var(--txt);padding:6px 10px;font-size:12px;width:230px;outline:none}
#q:focus{border-color:var(--magenta)}
.fg{display:flex;gap:4px;align-items:center}.fg .lbl{font-size:9px;color:var(--muted);text-transform:uppercase;margin-right:2px}
.chip{background:var(--panel);border:1px solid var(--line);border-radius:12px;padding:3px 9px;font-size:10px;color:var(--muted);cursor:pointer;user-select:none}
.chip:hover{border-color:var(--muted)}.chip.on{background:#2a1a4a;border-color:var(--magenta);color:var(--txt)}
#count{font-size:10px;color:var(--muted);margin-left:auto}
#wrap{flex:1;overflow:auto;padding:0 20px 20px}
table{width:100%;border-collapse:collapse;font-size:12px}
thead th{position:sticky;top:0;background:var(--bg2);text-align:left;padding:7px 9px;font-size:9px;text-transform:uppercase;letter-spacing:.05em;color:var(--muted);border-bottom:1px solid var(--line);cursor:pointer;white-space:nowrap;z-index:5}
tbody td{padding:6px 9px;border-bottom:1px solid rgba(44,44,80,.5);vertical-align:top}
tbody tr:hover{background:rgba(161,0,255,.06)}
.id{font-family:'Cascadia Code',monospace;font-size:10px;color:#7a7a98;white-space:nowrap}
.tp{font-size:9px;font-weight:700;padding:1px 6px;border-radius:3px}
.tp.F{background:#052e16;color:#86efac}.tp.V{background:#1e2a3f;color:#93c5fd}
.sp{font-family:'Cascadia Code',monospace;font-size:10px;color:#d8d8f0;white-space:nowrap}
.code{font-family:'Cascadia Code',monospace;font-size:10.5px;color:#c0c0de;white-space:pre-wrap;word-break:break-word}
.rg{font-size:8px;font-weight:700;padding:1px 6px;border-radius:8px;margin:0 2px 2px 0;display:inline-block}
.norma{font-size:9px;color:var(--muted);margin-top:2px}
.ri{font-size:9px;color:#fca5a5;margin-top:3px}
footer{font-size:9px;color:var(--muted);padding:6px 20px;flex-shrink:0;border-top:1px solid var(--line)}
#ls{font-size:9px;padding:4px 20px;flex-shrink:0}#ls.err{color:#fca5a5}
</style></head><body>
<header><h1>Reglas de Negocio y Fórmulas · Informix</h1>
<div class="sub">SPE-AM-001 · Etapa 3 Business Logic Extraction · evidencia del código SPL · 2026-07-04</div></header>
<div id="tiles"></div>
<div id="regbar"></div>
<div id="ctrl">
  <input id="q" placeholder="Buscar SP, código, norma…" autocomplete="off">
  <div class="fg"><span class="lbl">Regulador</span><div id="freg"></div></div>
  <div class="fg"><span class="lbl">Tipo</span><div id="ftipo"></div></div>
  <div class="fg"><span class="lbl">Solo con</span><div id="fri"></div></div>
  <span id="count"></span>
</div>
<div id="ls"></div>
<div id="wrap"><table><thead><tr>
  <th data-k="id">ID</th><th data-k="tipo">Tipo</th><th data-k="sp">SP · línea</th>
  <th data-k="dom">Dominio</th><th>Regulador · norma</th><th data-k="code">Evidencia (código) + riesgo</th>
</tr></thead><tbody id="tb"></tbody></table></div>
<footer>🟢 Fórmula · 🔵 Validación · ⚠ = riesgo de equivalencia (TRUNC/base 360-365/MONEY). Fuente: extract-rules.py → business-rules.json</footer>
<script>
const DATA=__DATA__, M=__META__;
const REGCOL={CNBV:'#2e6b48',Banxico:'#1e5a8a',CONDUSEF:'#6b3080',SAT:'#8b6b20',TESOFE:'#7a2020',IPAB:'#5a2a6b'};
document.getElementById('tiles').innerHTML=[
 ['',M.total,'Reglas'],['f',M.bytipo['FÓRMULA']||0,'Fórmulas'],['',M.bytipo['VALIDACIÓN']||0,'Validaciones'],
 ['reg',M.n_reg,'Regulatorias'],['ri',M.n_riesgo,'⚠ Riesgo equiv.']
].map(([c,n,l])=>`<div class="tile ${c}"><div class="n">${n}</div><div class="l">${l}</div></div>`).join('');
document.getElementById('regbar').innerHTML=['CNBV','Banxico','CONDUSEF','SAT','TESOFE','IPAB']
 .filter(r=>M.byreg[r]).map(r=>`<div class="rc"><span class="d" style="background:${REGCOL[r]}"></span>${r} <b>${M.byreg[r]}</b></div>`).join('');

let fReg=new Set(),fTipo=new Set(),fRi=false,q='';
function chips(el,vals,set,lab){document.getElementById(el).innerHTML=vals.map(v=>`<span class="chip" data-v="${v}">${lab(v)}</span>`).join('');
 document.querySelectorAll('#'+el+' .chip').forEach(c=>c.onclick=()=>{const v=c.dataset.v;if(set.has(v)){set.delete(v);c.classList.remove('on')}else{set.add(v);c.classList.add('on')}render()})}
chips('freg',['CNBV','Banxico','CONDUSEF','SAT','TESOFE','IPAB'],fReg,v=>v);
chips('ftipo',['FÓRMULA','VALIDACIÓN'],fTipo,v=>v);
document.getElementById('fri').innerHTML='<span class="chip" id="rich">⚠ riesgo equiv.</span>';
document.getElementById('rich').onclick=function(){fRi=!fRi;this.classList.toggle('on',fRi);render()};
document.getElementById('q').oninput=e=>{q=e.target.value.toLowerCase();render()};

const tb=document.getElementById('tb');
function render(){
 let rs=DATA.filter(r=>{
   if(fReg.size && !r.regs.some(x=>fReg.has(x))) return false;
   if(fTipo.size && !fTipo.has(r.tipo)) return false;
   if(fRi && !r.riesgo.length) return false;
   if(q && !(r.sp.toLowerCase().includes(q)||r.code.toLowerCase().includes(q)||(r.norma||'').toLowerCase().includes(q))) return false;
   return true;
 });
 tb.innerHTML=rs.slice(0,600).map(r=>`<tr>
   <td class="id">${r.id}</td>
   <td><span class="tp ${r.tipo[0]}">${r.tipo==='FÓRMULA'?'FÓRM':'VALID'}</span></td>
   <td><span class="sp">${r.sp}</span><div class="norma">L${r.line}</div></td>
   <td style="font-size:10px;color:#9ab0d0;white-space:nowrap">${r.dom}</td>
   <td>${r.regs.map(x=>`<span class="rg" style="background:${REGCOL[x]||'#333'}">${x}</span>`).join('')||'<span style="color:#6a6a80;font-size:9px">operacional</span>'}
     ${r.norma?`<div class="norma">${r.norma.replace(/</g,'&lt;')}</div>`:''}</td>
   <td><div class="code">${r.code.replace(/</g,'&lt;')}</div>
     ${r.riesgo.map(x=>`<div class="ri">⚠ ${x.replace(/</g,'&lt;')}</div>`).join('')}</td>
 </tr>`).join('');
 document.getElementById('count').textContent=`${rs.length} de ${DATA.length}`+(rs.length>600?' (mostrando 600)':'');
}
render();
</script></body></html>"""
HTML = HTML.replace("__DATA__", DATA).replace("__META__", M)
open(BASE + "old/rules-report-bcop.html", "w", encoding="utf-8").write(HTML)
print(f"rules-report-bcop.html escrito · {len(rows)} reglas · {sum(1 for r in rows if r['riesgo'])} con riesgo")
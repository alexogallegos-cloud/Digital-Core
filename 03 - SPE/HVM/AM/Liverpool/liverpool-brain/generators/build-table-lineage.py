#!/usr/bin/env python3
"""
Liverpool — Data-Lineage de Tablas SAP (Módulo Importaciones)
-------------------------------------------------------------
Extrae accesos a tablas (SELECT/INSERT/UPDATE/MODIFY/DELETE) de los 12
programas ABAP, clasifica estándar/Z y anota impacto S/4HANA por
Simplification Item. Genera un mapa tabla × programa (lectura/escritura).

Reads  source/Source Code SAP/<programas>
Writes portal/data/table-lineage-liv.json
       portal/table-lineage-liv.html
"""
import re, json, glob, os
from pathlib import Path
from datetime import date

HERE  = Path(__file__).parent
BRAIN = HERE.parent
SRC   = BRAIN / "source" / "Source Code SAP"
OUTJ  = BRAIN / "portal" / "data" / "table-lineage-liv.json"
OUTH  = BRAIN / "portal" / "table-lineage-liv.html"

# ── Clasificación de tablas ───────────────────────────────────────────────────
KNOWN_STD = {
    "lfa1","lfb1","lfm1","ekko","ekpo","ekbe","bkpf","bseg","bsik","bsak","bsis",
    "bsas","bsid","bsad","mara","marc","makt","mard","mseg","mkpf","konv","konp",
    "a018","eina","rbkp","rseg","adr6","adrc","likp","lips","vbak","vbap","aupo",
    "agr_users","usrefus","usr01","dd07v","dd03l","tinct","tinc","tbtco","fret",
    "t000","t001","t001w","t005t","t005u","t007s","t024","t024e","t059z","t052u",
    "t615t","t618t","t619s","t005",
}
# prefijos de tablas internas / palabras clave → NO son tablas de BD
BAD_PREFIX = ("it_","gt_","gs_","lt_","ls_","wa_","ws_","w_","i_","tl_","aux_",
              "o_","lcl_","tab_","gv_","lv_","tg_")
BAD_EXACT  = {"table","screen","memory","sy","itab","dynpro"}

def is_real_table(t: str) -> bool:
    t = t.lower()
    if t in BAD_EXACT or t.startswith(BAD_PREFIX):
        return False
    if t.startswith(("z", "y")):                       # Z/Y custom
        return True
    if t in KNOWN_STD:                                 # SAP estándar conocida
        return True
    if re.match(r"^t\d{3}", t) or re.match(r"^a\d{3}$", t):  # T### / A### (pricing)
        return True
    return False

def is_z(t: str) -> bool:
    return t.lower().startswith(("z", "y"))

# ── Impacto S/4HANA (Simplification Items) ────────────────────────────────────
def s4_note(t: str):
    t = t.lower()
    if t in ("bseg","bkpf","bsik","bsak","bsid","bsad","bsis","bsas"):
        return ("Universal Journal", "Documento financiero → tabla única ACDOCA en S/4HANA. "
                "Los índices secundarios (BSIK/BSAK/BSIS/BSAS…) se eliminan; leer vía ACDOCA o CDS de compatibilidad.")
    if t == "konv":
        return ("Pricing", "Condiciones de precio → PRCD_ELEMENTS en S/4HANA. El acceso directo a KONV queda obsoleto.")
    if t in ("konp","a018"):
        return ("Pricing", "Registros/condiciones de precio — tablas conservadas pero revisar patrón de acceso en S/4HANA.")
    if t in ("mara","marc","makt","mard"):
        return ("Material 40c", "Maestro de material — MATNR extendido a 40 caracteres en S/4HANA. Revisar CONVERSION_EXIT y longitudes de campo.")
    if t in ("mseg","mkpf"):
        return ("MATDOC", "Documentos de material → tabla MATDOC en S/4HANA. Acceso directo obsoleto.")
    if t in ("lfa1","lfb1","lfm1"):
        return ("Business Partner", "Maestro de proveedor — Business Partner (BP) es obligatorio en S/4HANA. LFA1/LFB1 conservadas pero mantenidas vía BP.")
    if t in ("vbak","vbap"):
        return ("SD status", "Ventas — tablas de estatus VBUK/VBUP eliminadas en S/4HANA (estatus embebido).")
    return None

# ── Extracción ────────────────────────────────────────────────────────────────
RE_FROM  = re.compile(r"\bfrom\s+([a-z_][a-z0-9_]*)", re.I)
RE_WRITE = re.compile(r"^(insert|modify|update|delete)\s+(?:into\s+|from\s+)?([a-z_][a-z0-9_]*)", re.I)

progs = sorted(f for f in glob.glob(str(SRC / "*")) if os.path.isfile(f) and not f.endswith(".xlsx"))

tables = {}            # tab → {is_z, reads:set, writes:set, total, s4, note}
edges  = []            # (prog, tab, op, n, lines)
prog_list = []

def touch(tab, prog, op, ln):
    m = tables.setdefault(tab, {"is_z": is_z(tab), "reads": set(), "writes": set(),
                                "total": 0, "s4": None, "note": ""})
    (m["writes"] if op == "W" else m["reads"]).add(prog)
    m["total"] += 1

for p in progs:
    name = os.path.basename(p); prog_list.append(name)
    agg = {}           # (tab,op) → [lines]
    for i, raw in enumerate(open(p, encoding="latin-1"), 1):
        s = raw.strip()
        if not s or s.startswith("*"):
            continue
        s = re.sub(r'".*$', "", s)
        mw = RE_WRITE.match(s)
        if mw and is_real_table(mw.group(2)):
            tab = mw.group(2).lower()
            agg.setdefault((tab, "W"), []).append(i); touch(tab, name, "W", i)
            continue
        for m in RE_FROM.finditer(s):
            tab = m.group(1).lower()
            if is_real_table(tab):
                agg.setdefault((tab, "R"), []).append(i); touch(tab, name, "R", i)
    for (tab, op), lns in agg.items():
        edges.append({"prog": name, "tab": tab, "op": op, "n": len(lns), "lines": lns[:6]})

# anota S/4
for tab, m in tables.items():
    note = s4_note(tab)
    if note:
        m["s4"], m["note"] = note[0], note[1]

n_z   = sum(1 for m in tables.values() if m["is_z"])
n_std = sum(1 for m in tables.values() if not m["is_z"])
n_s4  = sum(1 for m in tables.values() if m["s4"])
n_wr  = sum(1 for m in tables.values() if m["writes"])
total_acc = sum(e["n"] for e in edges)

payload = {
    "meta": {"generated": str(date.today()), "programs": len(prog_list),
             "tables": len(tables), "accesses": total_acc, "z": n_z, "std": n_std,
             "s4": n_s4, "write_targets": n_wr},
    "programs": prog_list,
    "tables": [
        {"tab": t, "is_z": m["is_z"], "total": m["total"],
         "reads": sorted(m["reads"]), "writes": sorted(m["writes"]),
         "s4": m["s4"], "note": m["note"]}
        for t, m in sorted(tables.items(), key=lambda x: (not x[1]["s4"], not x[1]["is_z"], -x[1]["total"], x[0]))
    ],
    "edges": edges,
}
OUTJ.write_text(json.dumps(payload, ensure_ascii=False, indent=2), encoding="utf-8")

# ── HTML ──────────────────────────────────────────────────────────────────────
data_js = json.dumps(payload, ensure_ascii=False, separators=(",", ":"))

HTML = f"""<!DOCTYPE html>
<html lang="es"><head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1.0">
<title>Liverpool · Data-Lineage de Tablas SAP</title>
<style>
:root{{--pink:#E00198;--sky:#87C3D3;--rose:#DA7AB0;--ink:#FFF0F8;--muted:#c09ab8;--muted2:#9070a0;
--bg:#0d0408;--bg2:#130610;--panel:#1a0814;--txt:#f0e6ef;--line:rgba(224,1,152,.18);
--rd:#6ee7b7;--wr:#f0a3d0}}
*{{box-sizing:border-box;margin:0;padding:0}}html,body{{height:100%}}
body{{background:var(--bg);color:var(--txt);font-family:'SF Pro Display',-apple-system,'Segoe UI',sans-serif;-webkit-font-smoothing:antialiased;display:flex;flex-direction:column;overflow:hidden}}
.hero{{position:relative;overflow:hidden;background:linear-gradient(135deg,#0d0408,#200412 40%,#360820 65%,#200412);flex-shrink:0}}
.hero-grid{{position:absolute;inset:0;background-image:linear-gradient(rgba(224,1,152,.10) 1px,transparent 1px),linear-gradient(90deg,rgba(224,1,152,.10) 1px,transparent 1px);background-size:48px 48px;mask-image:linear-gradient(to bottom,transparent,rgba(0,0,0,.5) 30%,rgba(0,0,0,.3) 70%,transparent)}}
.hero-glow{{position:absolute;top:-120px;left:50%;transform:translateX(-50%);width:600px;height:300px;background:radial-gradient(ellipse,rgba(224,1,152,.28),transparent 70%)}}
.hero-bar{{position:relative;z-index:1;display:flex;align-items:center;gap:18px;padding:14px 28px 16px;border-bottom:1px solid rgba(224,1,152,.12)}}
.hero-logo{{height:30px;width:auto;flex-shrink:0}}
.hero-bar .crumb{{font-size:10px;font-weight:600;letter-spacing:.12em;text-transform:uppercase;color:rgba(255,255,255,.35)}}
.hero-bar .crumb em{{color:var(--sky);font-style:normal}}.hero-bar .sp{{flex:1}}
.hero-bar .badge{{font-size:9px;font-weight:800;letter-spacing:.1em;color:#0d0408;background:var(--sky);padding:2px 8px;border-radius:20px}}
.hero-bar a.back{{font-size:11px;color:var(--muted);padding:5px 12px;border-radius:20px;border:1px solid rgba(255,255,255,.09);text-decoration:none}}
.hero-bar a.back:hover{{color:var(--txt);background:rgba(255,255,255,.07)}}
.hero-body{{position:relative;z-index:1;padding:18px 28px 22px;display:flex;align-items:flex-end;gap:32px;flex-wrap:wrap}}
.hero-title{{flex:1;min-width:240px}}
.hero-label{{font-size:10px;font-weight:800;letter-spacing:.14em;text-transform:uppercase;color:var(--sky);margin-bottom:8px}}
.hero-h1{{font-size:clamp(22px,4vw,32px);font-weight:900;letter-spacing:-.03em;line-height:1.1;background:linear-gradient(135deg,#fff 40%,rgba(224,1,152,.8));-webkit-background-clip:text;-webkit-text-fill-color:transparent}}
.hero-sub{{font-size:12.5px;color:var(--muted);line-height:1.55;margin-top:10px;max-width:680px}}
.hero-stats{{display:flex;gap:4px;flex-wrap:wrap;align-items:flex-end}}
.stat-block{{background:rgba(255,255,255,.04);border:1px solid rgba(255,255,255,.07);border-radius:12px;padding:11px 16px;min-width:84px}}
.stat-block .sn{{font-size:24px;font-weight:900;letter-spacing:-.03em;font-variant-numeric:tabular-nums;background:linear-gradient(135deg,var(--sky),#b8e0ea);-webkit-background-clip:text;-webkit-text-fill-color:transparent;line-height:1}}
.stat-block.pink .sn{{background:linear-gradient(135deg,var(--pink),var(--rose));-webkit-background-clip:text;-webkit-text-fill-color:transparent}}
.stat-block.red .sn{{background:linear-gradient(135deg,#fca5a5,#f87171);-webkit-background-clip:text;-webkit-text-fill-color:transparent}}
.stat-block .sl{{font-size:9px;font-weight:600;letter-spacing:.08em;text-transform:uppercase;color:var(--muted);margin-top:4px}}
#fbar{{display:flex;gap:8px;align-items:center;flex-wrap:wrap;padding:10px 24px;background:var(--bg2);border-bottom:1px solid var(--line);flex-shrink:0}}
#q{{background:var(--panel);border:1px solid rgba(224,1,152,.4);border-radius:7px;color:var(--txt);padding:5px 10px;font-size:12px;width:210px;outline:none}}
#q:focus{{border-color:var(--sky)}}
.sep{{width:1px;height:18px;background:rgba(255,255,255,.08)}}
.pill{{border-radius:5px;padding:3px 9px;font-size:9.5px;font-weight:700;cursor:pointer;user-select:none;border:1px solid rgba(224,1,152,.25);color:var(--muted);background:rgba(224,1,152,.06);white-space:nowrap;transition:.15s}}
.pill.on{{border-color:var(--sky);color:var(--sky);background:rgba(135,195,211,.12)}}
.pill-s4{{border-radius:5px;padding:3px 9px;font-size:9.5px;font-weight:700;cursor:pointer;border:1px solid rgba(248,113,113,.4);color:#fca5a5;background:rgba(239,68,68,.08);white-space:nowrap}}
.pill-s4.on{{border-color:#f87171;background:rgba(239,68,68,.18)}}
#info{{margin-left:auto;font-size:9.5px;color:var(--muted)}}
#wrap{{flex:1;overflow:auto;padding:0 24px 16px;min-height:0}}
table{{border-collapse:separate;border-spacing:0;font-size:11px;width:100%}}
thead th{{position:sticky;top:0;z-index:6;background:var(--bg2);border-bottom:1px solid var(--line)}}
th.rot{{height:120px;padding:0;width:34px;vertical-align:bottom}}
th.rot>div{{transform:translateX(15px) rotate(-90deg);transform-origin:center;width:34px}}
th.rot span{{font-family:'Cascadia Code','Consolas',monospace;font-size:9px;color:var(--sky);white-space:nowrap;padding:4px 0}}
th.corner{{text-align:left;padding:6px 8px;font-size:9px;text-transform:uppercase;letter-spacing:.05em;color:var(--muted2);min-width:300px}}
tbody td{{border-bottom:1px solid rgba(224,1,152,.08)}}
td.tab{{padding:5px 8px;white-space:nowrap;max-width:320px}}
.tab-name{{font-family:'Cascadia Code','Consolas',monospace;font-size:11px;color:var(--ink);font-weight:600}}
.tag{{display:inline-block;font-size:8px;font-weight:800;padding:1px 5px;border-radius:3px;margin-left:6px;vertical-align:middle}}
.tag-z{{background:rgba(224,1,152,.15);color:var(--pink);border:1px solid rgba(224,1,152,.4)}}
.tag-std{{background:rgba(135,195,211,.12);color:var(--sky);border:1px solid rgba(135,195,211,.35)}}
.tag-s4{{background:rgba(248,113,113,.14);color:#fca5a5;border:1px solid rgba(248,113,113,.45)}}
.s4-note{{font-size:9px;color:var(--muted2);margin-top:2px;white-space:normal;max-width:300px;line-height:1.4}}
td.cell{{text-align:center;width:34px;height:26px;border-left:1px solid rgba(224,1,152,.05)}}
.mk{{display:inline-flex;align-items:center;justify-content:center;min-width:20px;height:18px;border-radius:4px;font-size:8.5px;font-weight:800;font-family:'Cascadia Code',monospace;padding:0 3px}}
.mk-r{{background:rgba(110,231,183,.14);color:var(--rd);border:1px solid rgba(110,231,183,.4)}}
.mk-w{{background:rgba(240,163,208,.16);color:var(--wr);border:1px solid rgba(240,163,208,.45)}}
.mk-rw{{background:rgba(224,1,152,.18);color:#ffb8e6;border:1px solid rgba(224,1,152,.5)}}
tr.grp td{{background:rgba(224,1,152,.06);padding:7px 8px;font-size:9px;font-weight:800;letter-spacing:.08em;text-transform:uppercase;color:var(--rose);border-top:1px solid var(--line)}}
tr.trow:hover td{{background:rgba(224,1,152,.05)}}
tr.trow.s4hi td.tab{{background:rgba(248,113,113,.07)}}
#tip{{position:fixed;z-index:99;max-width:360px;pointer-events:none;display:none;background:#0d0408;color:#e2d0df;border:1px solid rgba(224,1,152,.3);border-radius:7px;padding:8px 12px;font-size:11px;line-height:1.5;white-space:pre-wrap;box-shadow:0 12px 34px rgba(0,0,0,.6)}}
.legend{{display:flex;gap:14px;flex-wrap:wrap;padding:8px 24px;background:rgba(13,4,8,.6);border-top:1px solid var(--line);flex-shrink:0;font-size:9.5px;color:var(--muted)}}
.legend .mk{{margin-right:4px}}
</style></head><body>
<div class="hero"><div class="hero-grid"></div><div class="hero-glow"></div>
  <div class="hero-bar"><img class="hero-logo" src="Liverpool_logo.png" alt="Liverpool">
    <span class="crumb">SPE-AM-003 <em>›</em> Módulo Importaciones <em>›</em> Data-Lineage Tablas</span>
    <span class="sp"></span><span class="badge">Corpus ABAP</span><a class="back" href="index.html">← Inicio</a></div>
  <div class="hero-body"><div class="hero-title">
    <div class="hero-label">Liverpool · SAP ECC → S/4HANA · Simplification Assessment</div>
    <h1 class="hero-h1">Data-Lineage de Tablas SAP</h1>
    <div class="hero-sub">Cada acceso a base de datos (<b style="color:var(--rd)">SELECT</b>, <b style="color:var(--wr)">INSERT/UPDATE/MODIFY/DELETE</b>) de los 12 programas ABAP, cruzado tabla × programa. Las tablas marcadas <b style="color:#fca5a5">S/4</b> tienen un Simplification Item que cambia su modelo de datos (ACDOCA, MATDOC, Business Partner…) — impacto directo en la migración.</div>
  </div>
  <div class="hero-stats">
    <div class="stat-block"><div class="sn">{len(tables)}</div><div class="sl">Tablas</div></div>
    <div class="stat-block"><div class="sn">{total_acc}</div><div class="sl">Accesos</div></div>
    <div class="stat-block red"><div class="sn">{n_s4}</div><div class="sl">Impacto S/4</div></div>
    <div class="stat-block pink"><div class="sn">{n_z}</div><div class="sl">Z-custom</div></div>
    <div class="stat-block"><div class="sn">{n_wr}</div><div class="sl">Con escritura</div></div>
  </div></div></div>
<div id="fbar">
  <input id="q" type="search" placeholder="🔍 tabla o programa…" autocomplete="off">
  <div class="sep"></div>
  <span class="pill on" data-f="all">Todas</span>
  <span class="pill" data-f="s4">Impacto S/4</span>
  <span class="pill" data-f="z">Z-custom</span>
  <span class="pill" data-f="std">Estándar SAP</span>
  <span class="pill" data-f="wr">Con escritura</span>
  <span id="info"></span>
</div>
<div id="wrap"><table id="tbl"><thead id="thead"></thead><tbody id="tbody"></tbody></table></div>
<div class="legend">
  <span><span class="mk mk-r">R</span> Lectura (SELECT)</span>
  <span><span class="mk mk-w">W</span> Escritura (INSERT/UPD/MOD/DEL)</span>
  <span><span class="mk mk-rw">RW</span> Lectura y escritura</span>
  <span><span class="tag tag-s4">S/4</span> Simplification Item — cambia el modelo de datos en S/4HANA</span>
</div>
<script>
const D={data_js};
let fMode='all', fQ='';
const esc=s=>String(s||'').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');

document.getElementById('thead').innerHTML=
  `<tr><th class="corner">Tabla (${{D.tables.length}})</th>`+
  D.programs.map(p=>`<th class="rot"><div><span>${{esc(p)}}</span></div></th>`).join('')+`</tr>`;

function bucket(t){{ return t.s4?'s4':(t.is_z?'z':'std'); }}
const BUCKET_LBL={{s4:'Impacto S/4HANA — Simplification Item cambia el modelo de datos',
                  z:'Tablas Z de Liverpool — custom del Módulo Importaciones',
                  std:'Tablas estándar SAP — conservadas en S/4HANA'}};

function render(){{
  const q=fQ.toLowerCase().trim();
  let rows=D.tables.filter(t=>{{
    if(fMode==='s4'&&!t.s4) return false;
    if(fMode==='z'&&!t.is_z) return false;
    if(fMode==='std'&&t.is_z) return false;
    if(fMode==='wr'&&!t.writes.length) return false;
    if(q&&!(t.tab.toLowerCase().includes(q)||t.reads.concat(t.writes).some(p=>p.toLowerCase().includes(q)))) return false;
    return true;
  }});
  const ord={{s4:0,z:1,std:2}};
  rows.sort((a,b)=> ord[bucket(a)]-ord[bucket(b)] || b.total-a.total || a.tab.localeCompare(b.tab));
  const emap={{}};
  D.edges.forEach(e=>{{const k=e.tab+'|'+e.prog; (emap[k]=emap[k]||{{}})[e.op]=e;}});
  let html='',last=null;
  rows.forEach(t=>{{
    const bk=bucket(t);
    if(bk!==last){{last=bk;html+=`<tr class="grp"><td colspan="${{D.programs.length+1}}">${{BUCKET_LBL[bk]}}</td></tr>`;}}
    const tag=t.s4?`<span class="tag tag-s4">S/4 · ${{esc(t.s4)}}</span>`:(t.is_z?`<span class="tag tag-z">Z-custom</span>`:`<span class="tag tag-std">SAP estándar</span>`);
    html+=`<tr class="trow${{t.s4?' s4hi':''}}"><td class="tab"><span class="tab-name">${{esc(t.tab.toUpperCase())}}</span>${{tag}}`+
      (t.note?`<div class="s4-note">${{esc(t.note)}}</div>`:'')+`</td>`;
    D.programs.forEach(p=>{{
      const k=emap[t.tab+'|'+p]||{{}};
      const r=k.R,w=k.W;
      if(r||w){{
        let cls,lbl,tipn=[];
        if(r&&w){{cls='mk-rw';lbl='RW';}} else if(w){{cls='mk-w';lbl='W';}} else {{cls='mk-r';lbl='R';}}
        if(r)tipn.push(`R: ${{r.n}} (L${{r.lines.join(', L')}})`);
        if(w)tipn.push(`W: ${{w.n}} (L${{w.lines.join(', L')}})`);
        html+=`<td class="cell"><span class="mk ${{cls}}" data-tip="${{esc(t.tab.toUpperCase())}} en ${{esc(p)}}\\n${{esc(tipn.join(' · '))}}">${{lbl}}</span></td>`;
      }} else html+=`<td class="cell"></td>`;
    }});
    html+=`</tr>`;
  }});
  document.getElementById('tbody').innerHTML=html;
  document.getElementById('info').textContent=`${{rows.length}} tablas visibles`;
}}
document.querySelectorAll('.pill[data-f]').forEach(p=>p.addEventListener('click',()=>{{
  document.querySelectorAll('.pill[data-f]').forEach(x=>x.classList.remove('on'));
  p.classList.add('on'); fMode=p.dataset.f; render();
}}));
let qt;document.getElementById('q').addEventListener('input',e=>{{clearTimeout(qt);qt=setTimeout(()=>{{fQ=e.target.value;render();}},160);}});
const tip=document.createElement('div');tip.id='tip';document.body.appendChild(tip);
document.addEventListener('mouseover',e=>{{const el=e.target.closest('[data-tip]');if(el){{tip.textContent=el.getAttribute('data-tip');tip.style.display='block';}}}});
document.addEventListener('mousemove',e=>{{if(tip.style.display==='block'){{let x=e.clientX+14,y=e.clientY+14;const r=tip.getBoundingClientRect();if(x+r.width>innerWidth-8)x=e.clientX-r.width-14;if(y+r.height>innerHeight-8)y=e.clientY-r.height-14;tip.style.left=x+'px';tip.style.top=y+'px';}}}});
document.addEventListener('mouseout',e=>{{if(e.target.closest('[data-tip]'))tip.style.display='none';}});
render();
</script></body></html>"""

OUTH.write_text(HTML, encoding="utf-8")
print(f"lineage -> {OUTJ.name}: {len(tables)} tables ({n_z} Z / {n_std} std / {n_s4} S4) / {total_acc} accesses / {n_wr} write-targets")
print(f"        -> {OUTH.name} ({round(OUTH.stat().st_size/1024,1)} KB)")

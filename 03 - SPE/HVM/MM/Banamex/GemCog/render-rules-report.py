"""
render-rules-report.py
Genera portal/rules-report-gemcog.html desde TODOS los rules-catalog/*.md.
Modelo: Sistema · ID · Programa · BIAN · Proceso · Tags · Regla · Regulador.
Fuente única de verdad = los MD del rules-catalog (1,550 reglas).
"""
import re, glob, os, json, html, datetime

BASE = os.path.dirname(os.path.abspath(__file__))
RD   = os.path.join(BASE, "rules-catalog")
OUT  = os.path.join(BASE, "portal", "rules-report-gemcog.html")

KNOWN_REGS = ["CNBV", "Banxico", "SAT", "CONDUSEF", "IPAB", "Banco de México", "Banxico"]

# ── Normalización de capacidad BIAN (coherencia con Capa 3) ────────────────────
def _load_canon():
    canon = {}
    p = os.path.join(BASE, "capability-model-taxonomy.md")
    if not os.path.exists(p): return canon
    for l in open(p, encoding="utf-8"):
        m = re.match(r'\|\s*([0-9T]\.\d(?:\.\d)?)\s*\|[^|]*\|[^|]*\|\s*([^|]+?)\s*\|', l)
        if m and m.group(1) not in canon:
            name = m.group(2).strip()
            if "P##" not in name and "→" not in name:
                canon[m.group(1)] = f"{m.group(1)} {name}"
    return canon

def _load_prog2id():
    # Fuente canónica: program-registry-* (bian-mapping-* está DEPRECATED).
    # Robusto a orden de columnas: detecta prog (P<num>) y bian_ref por fullmatch de celda.
    p2 = {}
    for bf in ["program-registry-s500.md", "program-registry-s151.md"]:
        fp = os.path.join(BASE, bf)
        if not os.path.exists(fp): continue
        for l in open(fp, encoding="utf-8"):
            if not l.lstrip().startswith("|"): continue
            cells = [c.strip().strip("*").strip() for c in l.strip().strip("|").split("|")]
            prog = bian = None
            for c in cells:
                if prog is None:
                    m = re.match(r'(P\d{2,4})', c)
                    if m and re.fullmatch(r'P\d{2,4}(?:_[A-Z0-9]+)?', c): prog = m.group(1)
                if bian is None and re.fullmatch(r'[0-9T]\.\d(?:\.\d)?', c): bian = c
            if prog and bian and prog not in p2:
                p2[prog] = bian
    return p2

CANON = _load_canon()
PROG2ID = _load_prog2id()

# Alias de etiquetas no-BIAN (usadas por rules-s151-l002r3-r4-r5.md) → ID canónico
CAP_ALIAS = [
    (r'gl posting|gl saldos|gl ', '7.1.1'),
    (r'cierre diario|cambio de d|control batch|procesamiento (batch|nocturno)|recuperaci', '8.1.1'),
    (r'observabilidad', 'T.3.4'),
    (r'integraci', 'T.2.3'),
    (r'seguridad|scrambl', 'T.3.5'),
    (r'concili|punteo', '6.7.1'),
    (r'reporte|cnbv|analytics', 'T.3.4'),
]
PROG_CAP = [(r"S500P630", "2.2.6"), (r"L002R", "7.1.1"), (r"P060", "10.1.1"), (r"LINEA", "8.1.1")]
FILE_CAP = {"dasdl": "9.1.1", "s151registra": "7.1.1"}
def normalize_bian(raw, prog, base=""):
    """Devuelve (capacidad_canónica, grupo) a partir del campo crudo + programa + archivo."""
    cid = None
    if raw and raw != "—":
        m = re.match(r'\s*(?:BIAN\s+)?([0-9T]\.\d(?:\.\d)?)', raw)
        if m and m.group(1) in CANON: cid = m.group(1)
    if not cid and raw:
        low = raw.lower()
        for pat, tid in CAP_ALIAS:
            if re.search(pat, low): cid = tid; break
    if not cid:
        m = re.search(r'([A-Z]?P\d+|L\d+|S\d+P\d+)', (prog or "").upper())
        pk = m.group(1) if m else (prog or "").upper()
        cid = PROG2ID.get(pk)
    if not cid:
        pu = (prog or "").upper()
        for sub, tid in PROG_CAP:
            if sub in pu: cid = tid; break
    if not cid:
        for sub, tid in FILE_CAP.items():
            if sub in base.lower(): cid = tid; break
    if cid:
        return CANON.get(cid, cid), cid.split(".")[0]
    return (raw or "—"), "?"

def meta(part, field):
    m = re.search(rf'\*\*{re.escape(field)}\*\*\s*\|\s*([^\n|]+)', part)
    return m.group(1).strip() if m else ""

def meta_any(part, *fields):
    for f in fields:
        v = meta(part, f)
        if v: return v
    return ""

def meta_val_block(part, field):
    """Capture text after a **Field:** heading up to the next blank line / heading."""
    m = re.search(rf'\*\*{re.escape(field)}:?\*\*\s*(.+?)(?=\n\s*\n|\n\*\*|\n#|\Z)', part, re.DOTALL)
    if not m: return ""
    return re.sub(r'\s+', ' ', m.group(1)).strip()

def campos_table(part):
    """Extract the 'Campos involucrados' / 'Campos COBOL' table -> list of 'FIELD — rol'."""
    m = re.search(r'\*\*Campos (?:involucrados|COBOL)[:\*]*\*?\*?\s*\n(.*?)(?=\n\s*\n\*\*|\n#|\Z)', part, re.DOTALL)
    if not m: return []
    out=[]
    for ln in m.group(1).split("\n"):
        if not ln.strip().startswith("|"): continue
        cells=[c.strip().strip("`").strip() for c in ln.strip().strip("|").split("|")]
        if not cells or not cells[0] or cells[0].lower() in ("campo cobol","campo","---","-------------"): continue
        if set(cells[0])<=set("-: "): continue
        field=cells[0]
        role=cells[-1] if len(cells)>1 else ""
        out.append(f"{field} — {role}" if role else field)
    return out

def section_bullets(part, field_re):
    """Collect bullet lines under a **Heading** as a list of strings."""
    m = re.search(rf'\*\*(?:{field_re}):?\*\*\s*\n(.*?)(?=\n\s*\n\*\*|\n#|\Z)', part, re.DOTALL)
    if not m: return []
    out=[]
    for ln in m.group(1).split("\n"):
        ln=ln.strip()
        if ln.startswith(("-","•","*")):
            out.append(re.sub(r'^[-•*]\s*','',ln).strip())
    return [re.sub(r'`','',x) for x in out if x]

def classify_proc(frec):
    f = frec.lower()
    on = "online" in f or "línea" in f or "linea" in f or "tiempo real" in f
    ba = "batch" in f or "nocturno" in f or "job" in f or "diario" in f
    if on and ba: return "MIXED"
    if on: return "ONLINE"
    if "librería" in f or "libreria" in f or "schema" in f or "stub" in f: return "MIXED"
    return "BATCH"

def regs_of(s):
    found = []
    for r in ["CNBV", "Banxico", "SAT", "CONDUSEF", "IPAB"]:
        if r.lower() in s.lower(): found.append(r)
    if not found and ("interno" in s.lower() or "n/a" in s.lower() or "control" in s.lower()):
        found.append("Interno")
    if not found: found.append(s.split("/")[0].split("—")[0].strip() or "Interno")
    # dedup preserve order
    seen=[]; [seen.append(x) for x in found if x not in seen]
    return seen

def line_of(part):
    m = re.search(r'\*\*Estado validaci[oó]n[:\*]*\s*\*?\*?\s*([^\n]+)', part)
    s = m.group(1) if m else ""
    n = re.search(r'(\d{3,})', s)
    if n: return n.group(1)
    # original schema: "Líneas aproximadas: ~N" inside Traza block
    t = re.search(r'L[ií]neas?\s+aproximadas?:?\s*~?\s*(\d{2,})', part)
    if t: return t.group(1)
    return "—"

def bian_group(bian):
    m = re.match(r'\s*([0-9T])', bian)
    return m.group(1) if m else "?"

def parse():
    rules=[]
    for fp in sorted(glob.glob(os.path.join(RD,"*.md"))):
        base=os.path.basename(fp)
        if "INDEX" in base.upper(): continue
        c=open(fp,encoding="utf-8").read()
        # program fallback from filename: rules-s151-p108-p150.md -> P108/P150
        fn_progs=[p.upper() for p in re.findall(r'-([pP]\d+|dasdl|l\d+)', base)]
        fn_prog="/".join(fn_progs) if fn_progs else ""
        parts=re.split(r'\n(?=#{2,3} RN-S(?:151|500)-\d+)', c)
        for part in parts:
            # title on SAME line only ([ \t]* not \s* — avoid eating newline into table header)
            hm=re.match(r'#{2,3} (RN-S(?:151|500)-\d+)[ \t]*[—\-|:]?[ \t]*([^\n]*)', part)
            if not hm: continue
            rid=hm.group(1).strip(); title=(hm.group(2) or "").strip()
            title=re.sub(r'\|.*$','',title).strip()   # drop any trailing table junk
            sistema = "S500" if "S500" in rid else "S151"
            prog_raw = meta_any(part,"Programa ejecutor","Programa(s) fuente","Programa fuente","Programa(s)","Programa")
            prog = re.split(r'[·,/]', prog_raw)[0].strip() if prog_raw else ""
            if not prog or not re.search(r'P\d', prog):
                mp = re.search(r'P\d{2,4}', prog_raw or "")
                prog = mp.group(0) if mp else (fn_prog or prog or "—")
            bian_raw = meta(part,"Capacidad bancaria") or meta(part,"bian_ref") or ""
            bian, bg = normalize_bian(bian_raw, prog, base)
            frec = meta(part,"Frecuencia")
            proc = classify_proc(frec) if frec else "BATCH"
            tipo_raw = meta_any(part,"Tipo técnico","Tipo")
            tags = re.findall(r'\[([^\]]+)\]', tipo_raw)
            reg = regs_of(meta_any(part,"Regulador","Base regulatoria") or "Interno")
            line = line_of(part)
            # Full description: capture the whole paragraph after **Descripción:** (may span lines)
            dm=re.search(r'\*\*Descripci[oó]n[:\*]*\*?\*?\s*(.+?)(?=\n\s*\n|\n\*\*|\n#|\Z)', part, re.DOTALL)
            desc=dm.group(1).strip() if dm else ""
            desc=re.sub(r'`','',desc)
            desc=re.sub(r'\s+',' ',desc)
            # Trigger (original schema) — append if present and not already in desc
            trig=meta_val_block(part,"Trigger")
            # Formula / pseudocode block
            fm=re.search(r'```[a-z]*\s*\n(.*?)```', part, re.DOTALL)
            formula=fm.group(1).strip() if fm else ""
            # Excepciones / riesgos block (bullets after the heading)
            exc=section_bullets(part, r'Excepciones(?: documentadas)?|Riesgos de migraci[oó]n')
            # Vocabulario en la fórmula (inline)
            vm=re.search(r'\*\*Vocabulario en la f[oó]rmula:?\*\*\s*([^\n]+)', part)
            vocab=vm.group(1).strip() if vm else meta_val_block(part,"Vocabulario relacionado")
            campos=campos_table(part)
            if not title:
                proc_meta=meta_any(part,"Proceso")
                if desc:
                    title=re.split(r'(?<=[a-z])\.\s', desc)[0][:110]
                elif proc_meta:
                    title=proc_meta[:110]
                else:
                    title=rid
            rules.append({
                "sys": sistema, "id": rid, "pgm": prog, "bian": bian,
                "bg": bg, "proc": proc, "tags": tags,
                "title": title[:140], "desc": desc[:1200], "reg": reg, "line": line,
                "trig": trig[:400], "formula": formula[:900],
                "exc": exc[:6], "vocab": vocab[:400], "campos": campos[:12],
            })
    return rules

def build_html(rules):
    # dynamic filter option sets
    bians = sorted(set(r["bian"] for r in rules if r["bian"]!="—"))
    tags  = sorted(set(t for r in rules for t in r["tags"]))
    data = json.dumps(rules, ensure_ascii=False)
    n500=sum(1 for r in rules if r["sys"]=="S500"); n151=len(rules)-n500
    today=datetime.date.today().isoformat()
    bian_opts="".join(f'<option value="{html.escape(b)}">{html.escape(b)}</option>' for b in bians)
    tag_opts="".join(f'<option value="{html.escape(t)}">{html.escape(t)}</option>' for t in tags)
    return f"""<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<title>GemCog · Reglas de Negocio — S500 + S151 · Banamex Unisys ClearPath MCP</title>
<style>
:root{{--bg:#071c23;--bg2:#0a2530;--panel:#0e2e3a;--line:#1a4555;--txt:#F0F8FA;--muted:#7fb8c8;--hbar:#6CC5D8;--red:#C1272D}}
*{{box-sizing:border-box;margin:0;padding:0}}
body{{display:flex;height:100vh;background:var(--bg);color:var(--txt);font-family:'Inter',system-ui,sans-serif;overflow:hidden;flex-direction:column}}
header{{background:linear-gradient(135deg,#071c23,#0e2e3a);border-bottom:2px solid var(--hbar);padding:10px 18px;display:flex;align-items:center;gap:14px;flex-shrink:0}}
header img{{height:22px;filter:drop-shadow(0 1px 2px rgba(0,0,0,.5))}}
header h1{{font-size:15px;font-weight:800}}
header .sub{{font-size:9px;color:var(--muted);margin-top:2px}}
#ctrl{{background:var(--bg2);border-bottom:1px solid var(--line);padding:8px 18px;display:flex;align-items:center;gap:12px;flex-wrap:wrap;flex-shrink:0}}
.lbl{{font-size:9px;color:var(--muted);font-weight:700;text-transform:uppercase;letter-spacing:.06em;white-space:nowrap}}
select{{background:var(--panel);color:var(--txt);border:1px solid var(--line);border-radius:4px;padding:4px 8px;font-size:10px;cursor:pointer;outline:none;max-width:220px}}
select:hover{{border-color:var(--hbar)}}
input[type=text]{{background:var(--panel);color:var(--txt);border:1px solid var(--line);border-radius:4px;padding:4px 10px;font-size:10px;width:180px;outline:none}}
input[type=text]:focus{{border-color:var(--hbar)}}
input[type=text]::placeholder{{color:var(--muted)}}
#cnt{{font-size:10px;color:var(--muted);margin-left:auto;white-space:nowrap}}#cnt b{{color:var(--hbar)}}
#wrap{{flex:1;overflow:auto;scrollbar-width:thin;scrollbar-color:var(--line) transparent}}
#wrap::-webkit-scrollbar{{width:6px}}#wrap::-webkit-scrollbar-thumb{{background:var(--line);border-radius:3px}}
table{{width:100%;border-collapse:collapse;font-size:11px;table-layout:fixed}}
col.c-sys{{width:3.5%}}col.c-id{{width:7%}}col.c-pgm{{width:7%}}col.c-bian{{width:9%}}col.c-proc{{width:5.5%}}col.c-line{{width:3.5%}}col.c-tags{{width:9%}}col.c-rule{{width:47%}}col.c-reg{{width:6%}}
td{{word-wrap:break-word;overflow-wrap:anywhere}}
thead th{{background:var(--bg2);color:var(--muted);font-size:9px;font-weight:700;text-transform:uppercase;letter-spacing:.06em;padding:7px 12px;text-align:left;border-bottom:2px solid var(--line);position:sticky;top:0;z-index:2;cursor:pointer;user-select:none;white-space:nowrap}}
thead th:hover{{color:var(--txt)}}
thead th.asc::after{{content:' ↑'}}thead th.desc::after{{content:' ↓'}}
tbody tr{{border-bottom:1px solid rgba(26,69,85,.6)}}
tbody tr:hover{{background:rgba(108,197,216,.04)}}
td{{padding:6px 12px;vertical-align:top;line-height:1.4}}
.td-sys{{font-size:8px;font-weight:800;padding:2px 6px;border-radius:10px;white-space:nowrap;display:inline-block}}
.sys-S500{{background:#0e2530;color:#6ee7b7}}.sys-S151{{background:#25100e;color:#f5b8d8}}
.td-id{{font-family:'Cascadia Code','Consolas',monospace;font-size:9px;color:var(--hbar);white-space:nowrap}}
.td-pgm{{font-family:'Cascadia Code','Consolas',monospace;font-size:10px;color:#5a8090}}
.td-bian{{font-size:9px;color:#a5d8ff}}
.bg-2{{color:#6ee7b7}}.bg-4{{color:#7dd3fc}}.bg-5{{color:#b8f5b8}}.bg-6{{color:#fdba74}}.bg-7{{color:#f5b8d8}}.bg-8{{color:#c4b5fd}}.bg-9{{color:#93c5fd}}.bg-10{{color:#fca5a5}}.bg-T{{color:#fde68a}}
.td-proc{{font-size:8px;font-weight:700;padding:2px 7px;border-radius:10px;white-space:nowrap;display:inline-block}}
.proc-BATCH{{background:#1a1a3a;color:#a5b4fc}}.proc-ONLINE{{background:#0e2a1a;color:#86efac}}.proc-MIXED{{background:#2a1a0a;color:#fdba74}}
.td-tags{{display:flex;flex-wrap:wrap;gap:3px}}
.tag{{padding:1px 5px;border-radius:3px;font-size:7px;font-weight:700;white-space:nowrap;background:#12303c;color:#9fd4e2}}
.tag.risk{{background:#2a0e12;color:#fca5a5}}.tag.fisc{{background:#1a2a0e;color:#bef264}}.tag.reg{{background:#0e2030;color:#7dd3fc}}
.td-rule{{padding-top:9px;padding-bottom:11px}}
.r-title{{color:#eaf6f9;font-weight:700;font-size:12px;line-height:1.4;margin-bottom:4px}}
.r-desc{{color:#c8dde4;font-size:11px;line-height:1.55;margin-bottom:5px}}
.r-trig{{color:#c9e6a8;font-size:10.5px;line-height:1.5;margin-bottom:5px}}
.r-formula{{background:#0a1a22;border-left:3px solid var(--hbar);border-radius:3px;padding:7px 10px;margin:5px 0;font-family:'Cascadia Code','Consolas',monospace;font-size:10px;line-height:1.5;color:#bfe6f0;white-space:pre-wrap;overflow-x:auto}}
.r-campos{{font-family:'Cascadia Code','Consolas',monospace;font-size:9.5px;color:#8fc7d6;line-height:1.5;margin-bottom:4px}}
.r-vocab{{font-family:'Cascadia Code','Consolas',monospace;font-size:9.5px;color:#7fb0bf;line-height:1.5;margin-bottom:4px}}
.r-exc{{font-size:10.5px;color:#e8c9a0;line-height:1.5;margin-top:4px}}.r-exc ul{{margin:2px 0 0;padding-left:15px}}.r-exc li{{margin-bottom:2px}}
.r-k{{font-size:8px;font-weight:800;text-transform:uppercase;letter-spacing:.06em;color:var(--muted)}}
.td-line{{font-family:'Cascadia Code','Consolas',monospace;font-size:9px;color:var(--muted)}}
.td-reg{{display:flex;flex-wrap:wrap;gap:3px}}
.rtag{{padding:1px 5px;border-radius:10px;font-size:7.5px;font-weight:700;white-space:nowrap;background:#12303c;color:#9fd4e2}}
.rtag.cnbv{{background:#0e2030;color:#7dd3fc}}.rtag.banxico{{background:#1a1a0e;color:#fde68a}}.rtag.sat{{background:#1a2a0e;color:#86efac}}.rtag.condusef{{background:#2a0e1a;color:#f9a8d4}}.rtag.ipab{{background:#2a1a0e;color:#fdba74}}
#empty{{display:flex;align-items:center;justify-content:center;padding:60px;color:var(--muted);font-size:13px;text-align:center}}
</style>
</head>
<body>
<header>
  <img src="../banamex-logo.png" alt="Banamex">
  <div>
    <h1>Reglas de Negocio y Fórmulas · GemCog — S500 + S151 · Banamex Unisys ClearPath MCP</h1>
    <div class="sub">Gemelo Cognitivo Capa 2 · Business Logic Extraction · {len(rules):,} reglas ({n500:,} S500 + {n151:,} S151) · cobertura ~100% de programas · generado {today}</div>
  </div>
</header>
<div id="ctrl">
  <span class="lbl">Sistema</span>
  <select id="fSys"><option value="">Todos</option><option value="S500">S500 Cargos/Abonos</option><option value="S151">S151 Contable GL</option></select>
  <span class="lbl">Capacidad BIAN</span>
  <select id="fBian"><option value="">Todas</option>{bian_opts}</select>
  <span class="lbl">Proceso</span>
  <select id="fProc"><option value="">Todos</option><option value="BATCH">BATCH</option><option value="ONLINE">ONLINE</option><option value="MIXED">MIXED</option></select>
  <span class="lbl">Tag</span>
  <select id="fTag"><option value="">Todos</option>{tag_opts}</select>
  <span class="lbl">Regulatorio</span>
  <select id="fReg"><option value="">Todos</option><option value="CNBV">CNBV</option><option value="Banxico">Banxico</option><option value="SAT">SAT</option><option value="CONDUSEF">CONDUSEF</option><option value="IPAB">IPAB</option></select>
  <input type="text" id="fTxt" placeholder="Buscar id, programa, regla…">
  <span id="cnt">mostrando <b id="cntN">—</b> de <b id="cntT">—</b></span>
</div>
<div id="wrap">
<table id="tbl">
<colgroup>
  <col class="c-sys"><col class="c-id"><col class="c-pgm"><col class="c-bian"><col class="c-proc"><col class="c-line"><col class="c-tags"><col class="c-rule"><col class="c-reg">
</colgroup>
<thead>
  <tr>
    <th data-col="sys">Sist.</th>
    <th data-col="id">ID</th>
    <th data-col="pgm">Programa</th>
    <th data-col="bian">Capacidad BIAN</th>
    <th data-col="proc">Proceso</th>
    <th data-col="line">Línea</th>
    <th data-col="tags">Tags</th>
    <th data-col="title">Regla / Fórmula</th>
    <th data-col="reg">Regulatorio</th>
  </tr>
</thead>
<tbody id="tbody"></tbody>
</table>
<div id="empty" style="display:none">No hay reglas que coincidan con los filtros seleccionados.</div>
</div>
<script>
const RULES={data};
let sortCol=null, sortDir=1;
function esc(s){{return (s||'').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');}}
function reg2tag(r){{const m={{CNBV:'cnbv',Banxico:'banxico',SAT:'sat',CONDUSEF:'condusef',IPAB:'ipab'}};return `<span class="rtag ${{m[r]||''}}">${{esc(r)}}</span>`;}}
function tagCls(t){{if(/HARDCODE|SILENCIOSO|BUG|RESILIENCIA/.test(t))return 'risk';if(/FISCAL/.test(t))return 'fisc';if(/REGULATORIO/.test(t))return 'reg';return '';}}
function tag2html(t){{return `<span class="tag ${{tagCls(t)}}">${{esc(t)}}</span>`;}}
function getFiltered(){{
  const sys=fSys.value, bian=fBian.value, proc=fProc.value, tag=fTag.value, reg=fReg.value, txt=fTxt.value.toLowerCase();
  return RULES.filter(r=>{{
    if(sys&&r.sys!==sys)return false;
    if(bian&&r.bian!==bian)return false;
    if(proc&&r.proc!==proc)return false;
    if(tag&&!r.tags.includes(tag))return false;
    if(reg&&!r.reg.includes(reg))return false;
    if(txt&&!r.pgm.toLowerCase().includes(txt)&&!r.title.toLowerCase().includes(txt)&&!r.desc.toLowerCase().includes(txt)&&!r.id.toLowerCase().includes(txt))return false;
    return true;
  }});
}}
function ruleHTML(r){{
  let s=`<div class="r-title">${{esc(r.title)}}</div>`;
  if(r.desc)s+=`<div class="r-desc">${{esc(r.desc)}}</div>`;
  if(r.trig)s+=`<div class="r-trig"><span class="r-k">Trigger:</span> ${{esc(r.trig)}}</div>`;
  if(r.formula)s+=`<div class="r-formula">${{esc(r.formula)}}</div>`;
  if(r.campos&&r.campos.length)s+=`<div class="r-campos"><span class="r-k">Campos:</span> ${{r.campos.map(esc).join(' · ')}}</div>`;
  if(r.vocab)s+=`<div class="r-vocab"><span class="r-k">Vocabulario:</span> ${{esc(r.vocab)}}</div>`;
  if(r.exc&&r.exc.length)s+=`<div class="r-exc"><span class="r-k">Riesgos/Excepciones:</span><ul>${{r.exc.map(e=>`<li>${{esc(e)}}</li>`).join('')}}</ul></div>`;
  return s;
}}
function render(){{
  let rows=getFiltered();
  if(sortCol){{rows=rows.slice().sort((a,b)=>{{let av=a[sortCol],bv=b[sortCol];if(Array.isArray(av))av=av[0]||'';if(Array.isArray(bv))bv=bv[0]||'';return String(av).localeCompare(String(bv),'es',{{numeric:true}})*sortDir;}});}}
  cntN.textContent=rows.length; cntT.textContent=RULES.length;
  if(!rows.length){{tbody.innerHTML='';empty.style.display='flex';return;}}
  empty.style.display='none';
  tbody.innerHTML=rows.map(r=>`<tr>
    <td><span class="td-sys sys-${{r.sys}}">${{r.sys}}</span></td>
    <td class="td-id">${{r.id}}</td>
    <td class="td-pgm">${{esc(r.pgm)}}</td>
    <td class="td-bian bg-${{r.bg}}">${{esc(r.bian)}}</td>
    <td><span class="td-proc proc-${{r.proc}}">${{r.proc}}</span></td>
    <td class="td-line">${{r.line}}</td>
    <td><div class="td-tags">${{r.tags.map(tag2html).join('')}}</div></td>
    <td class="td-rule">${{ruleHTML(r)}}</td>
    <td><div class="td-reg">${{r.reg.map(reg2tag).join('')}}</div></td>
  </tr>`).join('');
}}
document.querySelectorAll('thead th').forEach(th=>th.addEventListener('click',()=>{{
  const col=th.dataset.col; if(!col)return; if(sortCol===col)sortDir=-sortDir; else {{sortCol=col;sortDir=1;}}
  document.querySelectorAll('thead th').forEach(t=>t.classList.remove('asc','desc'));
  th.classList.add(sortDir===1?'asc':'desc'); render();
}}));
['fSys','fBian','fProc','fTag','fReg','fTxt'].forEach(id=>{{const e=document.getElementById(id);e.addEventListener('input',render);e.addEventListener('change',render);}});
render();
</script>
</body>
</html>"""

if __name__ == "__main__":
    rules = parse()
    htmltxt = build_html(rules)
    with open(OUT, "w", encoding="utf-8") as f:
        f.write(htmltxt)
    n500=sum(1 for r in rules if r["sys"]=="S500")
    print(f"Reglas: {len(rules)} ({n500} S500 + {len(rules)-n500} S151)")
    print(f"HTML: {OUT} ({os.path.getsize(OUT)/1024:.1f} KB)")

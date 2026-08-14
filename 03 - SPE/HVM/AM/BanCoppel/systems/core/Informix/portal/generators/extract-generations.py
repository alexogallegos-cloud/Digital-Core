#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
extract-generations.py — ¿El relevo generacional fue consistente o cada generación
definió su propio vocabulario? ¿Cada relevo generó nueva deuda técnica?

Barrido único que bucketea los SP por ERA de creación y mide, por era:
 · Vocabulario: términos nuevos vs heredados (innovación % vs adopción del lenguaje fundacional)
 · Deuda: ambigüedad de nombrado (gap), duplicación/versionado, código huérfano, complejidad (control-flow)

Gemelo Cognitivo — capas 1×2×3 + hilo de Calidad. Genera: generations-bcop.html
"""
import os, re, glob, json, unicodedata
from collections import Counter, defaultdict
import sp_vocab

BASE = ("c:/Users/alejandro.gallegos/OneDrive - Accenture/Documents/Digital Core/"
        "03 - SPE/HVM/AM/BanCoppel/Informix/")
SRC = BASE + "source/informix/"
CAT = sp_vocab.CAT
DOM = {"bdicnweb","bdinteg","bdicred","bdicheq","bdisac","bdisolic",
       "bdiaclaracion","bdispei","bdimnsj","bdisuc","bdicobranza","bdicont"}
YMIN, YMAX = 2007, 2026
RE_YEAR = re.compile(r'\b(199[89]|20[0-2]\d)\b')
RE_CREATE = re.compile(r"create\s+(?:procedure|function)\b", re.I)
RE_CF = re.compile(r"\b(if|foreach|while|case|for|elif)\b", re.I)
# marcadores de duplicación / versionado / temporalidad en el nombre
RE_VER = re.compile(r"(?:_v?\d+$|\d$|\b(?:bis|tmp|temp|nuevo|nva?|vieja?o?|old|copia|resp\d?|bak|prueba|test|aux|ant)\b)", re.I)

ERAS = [(2007,2009,"Fundación"),(2010,2013,"Expansión"),(2014,2017,"Regulatorio"),
        (2018,2021,"Digital"),(2022,2026,"Reciente")]
def era_of(y):
    for a,b,n in ERAS:
        if a<=y<=b: return n
    return None

# autoría (mismo criterio que build-souls)
STOP = re.compile(r'(la consulta|correctamente|los datos|el proceso|la operaci|el registro|la tabla|se realiz|'
                  r'ninguno|n/?a\b|pendiente|xxx|nombre|aqui|autoriz|usuario|sistema|actualiz|se agrega|valida|'
                  r'obtiene|inserta|el sp\b|este |para el|nueva )', re.I)
RE_A1 = re.compile(r'\bautor(?:es)?\b\s*[:=\-]?\s*([A-Za-zÁÉÍÓÚÑñ][^\n\r]{2,45})', re.I)
RE_A2 = re.compile(r'\b(?:realiz|elabor|program|desarroll|modific|dise[ñn]|cre|hech)\w*\s+por\s*[:=\-]?\s*([A-Za-zÁÉÍÓÚÑñ][^\n\r]{2,45})', re.I)
RE_A3 = re.compile(r'\b(?:realiz[oó]|elabor[oó]|program[oó]|modific[oó]|dise[ñn][oó])\s*[:=]\s*([A-Za-zÁÉÍÓÚÑñ][^\n\r]{2,45})', re.I)
AUTH = [RE_A1, RE_A2, RE_A3]
NONPERSON = {"root","admin","administrador","informix","dba","test","soporte","sistema","usuario","autor","programa","na","none"}
def clean_name(s):
    s = s.strip().strip(" .-:*=/\t\"'")
    s = re.split(r'\s{2,}|\bfecha\b|\brqm\b|\bproyecto\b|\d{1,2}[/-]\d|\(|,|;', s, flags=re.I)[0].strip()
    s = re.sub(r'\s+',' ',s).strip(" .-'\"")
    if len(s)<4 or any(c.isdigit() for c in s) or STOP.search(s) or not (1<=len(s.split())<=5): return None
    if not re.match(r"^[A-Za-zÁÉÍÓÚÑñáéíóú][A-Za-zÁÉÍÓÚÑñáéíóú.\- ]+$", s): return None
    return s.title()
def canon(n):
    k="".join(c for c in unicodedata.normalize("NFD",n.lower()) if unicodedata.category(c)!="Mn")
    return re.sub(r"\s+"," ",re.sub(r"[^a-z ]","",k)).strip()
def authors(head):
    out=set()
    for rx in AUTH:
        for m in rx.findall(head):
            nm=clean_name(m)
            if nm:
                k=canon(nm)
                if k and k not in NONPERSON: out.add(k)
    return out
def isolate(t):
    ms=list(RE_CREATE.finditer(t)); return t[ms[0].start():ms[1].start()] if len(ms)>=2 else t

# ── pase 1: term_first (primer año de cada término) + recolección por SP ──
recs=[]                       # (era, tokens_set, estados, versioned, orphan, rqm, complexity)
term_first={}
for fp in glob.glob(SRC+"*.sql"):
    fn=os.path.basename(fp)
    db=next((k for k in DOM if fn.startswith(k+"_")),None)
    if not db: continue
    sp=fn[len(db)+1:-4]
    try: raw=open(fp,encoding="utf-8",errors="replace").read(70000)
    except Exception: continue
    head=raw[:4500]
    yrs=set()
    for ln in head.split("\n")[:80]:
        s=ln.strip()
        if s.startswith("--") or s.startswith("{"):
            for y in RE_YEAR.findall(s):
                yi=int(y)
                if YMIN<=yi<=YMAX: yrs.add(yi)
    ycre=min(yrs) if yrs else None
    toks=[t for t in sp_vocab.tokenize(sp) if t in CAT and len(t)>=3]
    tset=set(toks)
    if ycre:
        for t in tset:
            if t not in term_first or ycre<term_first[t]: term_first[t]=ycre
    era=era_of(ycre) if ycre else None
    if not era:   # solo entran al análisis por era los SP fechados
        continue
    estados=Counter(CAT[t][2] for t in toks)
    versioned=1 if RE_VER.search(sp) else 0
    au=authors(head); orphan=0 if au else 1
    rqm=1 if re.search(r'\b(?:RQM|requerimiento)\b',head,re.I) else 0
    cf=len(RE_CF.findall(isolate(raw)))
    recs.append((era, tset, estados, versioned, orphan, rqm, cf))

# ── agregación por era ──
order=[n for _,_,n in ERAS]
E={n:{"sp":0,"tok":0,"gap":0,"inf":0,"conf":0,"new":0,"used":set(),"ver":0,"orph":0,"rqm":0,"cf":0} for n in order}
for era,tset,est,ver,orph,rqm,cf in recs:
    e=E[era]; e["sp"]+=1
    e["used"].update(tset)
    e["gap"]+=est.get("gap",0); e["inf"]+=est.get("inf",0); e["conf"]+=est.get("conf",0)
    e["tok"]+=sum(est.values()); e["ver"]+=ver; e["orph"]+=orph; e["rqm"]+=rqm; e["cf"]+=cf
# términos nuevos por era (primer año cae en la era)
for t,y in term_first.items():
    er=era_of(y)
    if er: E[er]["new"]+=1

def pc(a,b): return round(100*a/b) if b else 0
rows=[]
for n in order:
    e=E[n]; sp=e["sp"]
    used=len(e["used"]); new=e["new"]
    rows.append({"era":n,"sp":sp,"new":new,"used":used,
        "innov":pc(new,used), "herit":pc(used-new,used),
        "amb":pc(e["gap"],e["tok"]), "ver":pc(e["ver"],sp),
        "orph":pc(e["orph"],sp), "rqm":pc(e["rqm"],sp),
        "cf": round(e["cf"]/sp,1) if sp else 0})

# ── veredicto (tendencias early→late sobre eras con datos) ──
act=[r for r in rows if r["sp"]>=20]
def trend(key): return (act[-1][key]-act[0][key]) if len(act)>=2 else 0
consistent = act[-1]["innov"]<25 and act[-1]["herit"]>=70 if act else False
debt_up=[]
for key,label in [("amb","ambigüedad de nombrado"),("ver","duplicación/versionado"),("orph","código huérfano"),("cf","complejidad")]:
    d=trend(key)
    if d>0: debt_up.append((label, act[0][key], act[-1][key], d))
debt_up.sort(key=lambda x:-x[3])

DATA={"eras":rows,"consistent":consistent,"debt_up":debt_up,"n_dated":len(recs),
      "term_total":len(term_first)}
json.dump(DATA, open(BASE+"portal/data/generations-data.json","w",encoding="utf-8"), ensure_ascii=False, separators=(",",":"))

# ── HTML: mapa de deuda sobre EJE DE AÑOS real (consistente con la evolución) ──
ERA_SHORT = ["Fund.", "Exp.", "Reg.", "Dig.", "Rec."]
EBOUND = [2007, 2010, 2014, 2018, 2022, 2027]   # 5 eras tilando [2007,2027) — mismos años que la evolución
YRSPAN = EBOUND[-1] - EBOUND[0]
def net(key): return round(rows[-1][key] - rows[0][key], 1)
def _xf(W, PL, PR): return lambda y: PL + (W - PL - PR) * (y - EBOUND[0]) / YRSPAN
def _bands(X, PT, base):
    s = ""
    for i in range(5):
        x0, x1 = X(EBOUND[i]), X(EBOUND[i+1])
        if i % 2 == 1: s += f'<rect x="{x0:.1f}" y="{PT}" width="{x1-x0:.1f}" height="{base-PT:.1f}" fill="#fff" opacity=".035"/>'
        if i > 0: s += f'<line x1="{x0:.1f}" y1="{PT}" x2="{x0:.1f}" y2="{base:.1f}" class="ediv"/>'
    return s
def _step(vals, X, Y, base):
    pts = []
    for i, v in enumerate(vals):
        pts.append((X(EBOUND[i]), Y(v))); pts.append((X(EBOUND[i+1]), Y(v)))
    line = " ".join(f"{x:.1f},{y:.1f}" for x, y in pts)
    return line, f"{X(EBOUND[0]):.1f},{base:.1f} " + line + f" {X(EBOUND[5]):.1f},{base:.1f}"
def _mid(i, X): return (X(EBOUND[i]) + X(EBOUND[i+1])) / 2
def mini_svg(key, unit="%"):
    vals=[r[key] for r in rows]
    W,H,PL,PR,PT,PB=360,142,16,12,20,32; base=H-PB; ymax=(max(vals) or 1)*1.22
    X=_xf(W,PL,PR); Y=lambda v: base-(base-PT)*v/ymax
    col="#F0D224" if net(key)>0 else "#6f8ce6"; gid=f"g_{key}"
    line,area=_step(vals,X,Y,base)
    dots="".join(f'<circle cx="{_mid(i,X):.1f}" cy="{Y(v):.1f}" r="2.4" fill="{col}"/>' for i,v in enumerate(vals))
    labs="".join(f'<text x="{_mid(i,X):.1f}" y="{Y(v)-5:.1f}" class="ml" text-anchor="middle">{v}{unit}</text>' for i,v in enumerate(vals))
    era="".join(f'<text x="{_mid(i,X):.1f}" y="{base+12:.1f}" class="mx" text-anchor="middle">{ERA_SHORT[i]}</text>' for i in range(5))
    yr="".join(f'<text x="{X(y):.1f}" y="{H-4:.1f}" class="my" text-anchor="middle">’{str(y)[2:]}</text>' for y in (2007,2014,2018,2022,2026))
    return (f'<svg viewBox="0 0 {W} {H}" class="mini"><defs><linearGradient id="{gid}" x1="0" y1="0" x2="0" y2="1">'
            f'<stop offset="0" stop-color="{col}" stop-opacity=".5"/><stop offset="1" stop-color="{col}" stop-opacity="0"/></linearGradient></defs>'
            f'{_bands(X,PT,base)}<polygon points="{area}" fill="url(#{gid})"/>'
            f'<polyline points="{line}" fill="none" stroke="{col}" stroke-width="2.4"/>{dots}{labs}{era}{yr}</svg>')
def badge(key, unit="%"):
    d=net(key); cls="bad" if d>0 else ("good" if d<0 else ""); ar="▲" if d>0 else ("▼" if d<0 else "▬")
    return f'<span class="badge {cls}">{ar} {"+" if d>0 else ""}{d}{unit}</span>'
# índice de deuda compuesto: promedio normalizado (0-100) de los 4 proxies
keys4=["orph","cf","ver","amb"]; maxk={k:(max(r[k] for r in rows) or 1) for k in keys4}
comp=[round(100*sum(r[k]/maxk[k] for k in keys4)/len(keys4)) for r in rows]
def hero_svg(vals):
    W,H,PL,PR,PT,PB=900,224,30,18,24,42; base=H-PB; ymax=(max(vals) or 1)*1.18
    X=_xf(W,PL,PR); Y=lambda v: base-(base-PT)*v/ymax
    line,area=_step(vals,X,Y,base)
    dots="".join(f'<circle cx="{_mid(i,X):.1f}" cy="{Y(v):.1f}" r="4" fill="#F0D224"/>' for i,v in enumerate(vals))
    labs="".join(f'<text x="{_mid(i,X):.1f}" y="{Y(v)-10:.1f}" class="hl" text-anchor="middle">{v}</text>' for i,v in enumerate(vals))
    era="".join(f'<text x="{_mid(i,X):.1f}" y="{base+15:.1f}" class="he" text-anchor="middle">{rows[i]["era"]}</text>' for i in range(5))
    yr="".join(f'<text x="{X(y):.1f}" y="{H-6:.1f}" class="my" text-anchor="middle">{y}</text>' for y in (2007,2010,2014,2018,2022,2026))
    axis=f'<line x1="{X(2007):.1f}" y1="{base:.1f}" x2="{X(2027):.1f}" y2="{base:.1f}" class="ax0"/>'
    return (f'<svg viewBox="0 0 {W} {H}" class="chart"><defs><linearGradient id="gh" x1="0" y1="0" x2="0" y2="1">'
            f'<stop offset="0" stop-color="#F0D224" stop-opacity=".42"/><stop offset="1" stop-color="#F0D224" stop-opacity="0"/></linearGradient></defs>'
            f'{_bands(X,PT,base)}{axis}<polygon points="{area}" fill="url(#gh)"/>'
            f'<polyline points="{line}" fill="none" stroke="#F0D224" stroke-width="3"/>{dots}{labs}{era}{yr}</svg>')

# ── gráfica ÚNICA consolidada: 4 deudas indexadas a base 100 = Fundación ──
METRICS=[("orph","Código huérfano","%","#F0D224"),("cf","Complejidad","","#E8862E"),
         ("ver","Duplicación/versionado","%","#D65DA8"),("amb","Ambigüedad","%","#5B8DEF")]
def combined_svg():
    W,H,PL,PR,PT,PB=900,300,38,172,30,46; base=H-PB
    ser={k:[round(100*r[k]/(rows[0][k] or 1)) for r in rows] for k,_,_,_ in METRICS}
    ymax=max([v for s in ser.values() for v in s]+[100])*1.08
    X=_xf(W,PL,PR); Y=lambda v: base-(base-PT)*v/ymax
    out=_bands(X,PT,base)
    out+=f'<line x1="{X(2007):.1f}" y1="{Y(100):.1f}" x2="{X(2027):.1f}" y2="{Y(100):.1f}" class="base100"/>'
    out+=f'<text x="{X(2007)+3:.1f}" y="{Y(100)-4:.1f}" class="my">base 100 · Fundación</text>'
    out+=f'<line x1="{X(2007):.1f}" y1="{base:.1f}" x2="{X(2027):.1f}" y2="{base:.1f}" class="ax0"/>'
    for i in range(5):
        out+=f'<text x="{_mid(i,X):.1f}" y="{base+14:.1f}" class="mx" text-anchor="middle">{ERA_SHORT[i]}</text>'
    for y in (2007,2010,2014,2018,2022,2026):
        out+=f'<text x="{X(y):.1f}" y="{H-8:.1f}" class="my" text-anchor="middle">{y}</text>'
    ends=[]
    for k,name,unit,col in METRICS:
        s=ser[k]; line,_=_step(s,X,Y,base)
        dash=' stroke-dasharray="6 3"' if k=="ver" else ''
        out+=f'<polyline points="{line}" fill="none" stroke="{col}" stroke-width="2.6"{dash}/>'
        out+="".join(f'<circle cx="{_mid(i,X):.1f}" cy="{Y(v):.1f}" r="2.5" fill="{col}"/>' for i,v in enumerate(s))
        ends.append([Y(s[-1]),name,col,s[-1]])
    ends.sort(key=lambda e:e[0]); last=-99
    for e in ends:
        yy=max(e[0],last+15); last=yy
        out+=f'<text x="{X(2027)+9:.1f}" y="{yy+3:.1f}" class="endl" fill="{e[2]}">{e[1]} · {e[3]}</text>'
    return f'<svg viewBox="0 0 {W} {H}" class="chart">{out}</svg>'

verdict = ("El relevo fue <b>consistente en el vocabulario</b>: las generaciones posteriores "
           "<b>adoptaron el lenguaje fundacional</b> en vez de inventar el suyo."
           if consistent else
           "<b>Cada generación tendió a definir vocabulario propio</b>: la innovación léxica se mantuvo alta entre relevos.")
debt_txt = ("Ninguna deuda proxy creció de forma sostenida entre generaciones." if not debt_up else
    "Con cada relevo creció: " + ", ".join(f'<b>{l}</b> ({a}%→{b}%)' if l!="complejidad" else f'<b>{l}</b> ({a}→{b} pts control-flow/SP)' for l,a,b,_ in debt_up) + ".")

def erow(r):
    return (f'<tr><td class="e">{r["era"]}</td><td>{r["sp"]:,}</td><td>{r["new"]}</td>'
            f'<td>{r["innov"]}%</td><td>{r["herit"]}%</td><td>{r["amb"]}%</td>'
            f'<td>{r["ver"]}%</td><td>{r["orph"]}%</td><td>{r["cf"]}</td></tr>')
tbody="".join(erow(r) for r in rows)
hero=hero_svg(comp)
m_orph,m_cf,m_ver,m_amb=mini_svg('orph'),mini_svg('cf',''),mini_svg('ver'),mini_svg('amb')
b_orph,b_cf,b_ver,b_amb=badge('orph'),badge('cf',''),badge('ver'),badge('amb')
# ── deuda de nombrado: sinónimos/alias del vocabulario (transversal a generaciones) ──
_terms = {t: c for t, (c, m, e) in sp_vocab.CAT.items() if c not in ("AMBIGUO", "PREFIJO") and e != "gap"}
_meanof = {t: m for t, (c, m, e) in sp_vocab.CAT.items()}
_par = {t: t for t in _terms}
def _f(x):
    while _par[x] != x: _par[x] = _par[_par[x]]; x = _par[x]
    return x
def _u(a, b):
    ra, rb = _f(a), _f(b)
    if ra != rb: _par[ra] = rb
_mg = {}
for _t in _terms:
    _k = re.sub(r"[^a-z0-9 ]", "", _meanof[_t].lower().split("(")[0].split(" / ")[0]).strip()
    if _k: _mg.setdefault(_k, []).append(_t)
for _ts in _mg.values():
    for _x in _ts[1:]: _u(_ts[0], _x)
for _t in _terms:
    for _pl in (_t + "s", _t + "es"):
        if _pl in _terms and _terms[_pl] == _terms[_t]: _u(_t, _pl)
_cmp = {}
for _t in _par: _cmp.setdefault(_f(_t), []).append(_t)
_syn = {r: ts for r, ts in _cmp.items() if len(ts) > 1}
n_syn_c = len(_syn); n_syn_a = sum(len(v) for v in _syn.values())
from vocab_dedup import counts as _vc; _C = _vc()  # fuente única de conteos de vocabulario
n_syn_c = _C['conceptos']; n_syn_a = _C['alias']  # 86 conceptos · 196 términos-alias (idéntico en todas las vistas)

CSS="""
:root{--bg:#0a1330;--panel:#132152;--line:#26317c;--blue:#3D5FCD;--blued:#122FB1;--yellow:#F0D224;--txt:#EAEDF7;--muted:#9aa4c4;--muted2:#818ab0}
*{box-sizing:border-box;margin:0;padding:0}
body{background:var(--bg);color:var(--txt);font-family:'Inter',system-ui,Calibri,sans-serif;line-height:1.5;position:relative}
.aurora{position:fixed;inset:0;z-index:-1;overflow:hidden;pointer-events:none}
.aurora span{position:absolute;border-radius:50%;filter:blur(80px)}
.aurora .b1{width:52vw;height:52vw;left:-8vw;top:-14vw;background:radial-gradient(circle,rgba(27,63,208,.5),transparent 70%)}
.aurora .b2{width:46vw;height:46vw;right:-10vw;top:0;background:radial-gradient(circle,rgba(13,33,133,.55),transparent 70%)}
.aurora .b3{width:40vw;height:40vw;left:28vw;top:10vw;background:radial-gradient(circle,rgba(240,210,36,.15),transparent 70%)}
header{background:linear-gradient(135deg,var(--blued),#0d2185);border-bottom:3px solid var(--yellow);padding:15px 30px;display:flex;align-items:center;gap:14px;position:sticky;top:0;z-index:10}
header img{height:24px;filter:drop-shadow(0 1px 2px rgba(0,0,0,.5))}
header h1{font-size:16px;font-weight:800} header .sub{font-size:10.5px;color:#c9d3f5;margin-top:1px}
.wrap{max-width:1000px;margin:0 auto;padding:26px 30px 60px}
.verdict{background:rgba(255,255,255,.055);backdrop-filter:blur(16px) saturate(140%);-webkit-backdrop-filter:blur(16px) saturate(140%);box-shadow:0 10px 34px rgba(0,0,0,.32),inset 0 1px 0 rgba(255,255,255,.1);border:1px solid rgba(255,255,255,.1);border-left:3px solid var(--yellow);border-radius:14px;padding:20px 24px;margin-bottom:26px}
.verdict h2{font-size:18px;font-weight:800;margin-bottom:8px} .verdict p{font-size:13.5px;color:var(--muted);margin-top:6px} .verdict b{color:#fff}
.vtitle{font-size:20px;font-weight:800;margin-bottom:14px}
.verdicts{display:grid;grid-template-columns:1fr 1fr;gap:16px;margin-bottom:26px}
@media(max-width:760px){.verdicts{grid-template-columns:1fr}}
.vbox{background:rgba(255,255,255,.055);backdrop-filter:blur(16px) saturate(140%);-webkit-backdrop-filter:blur(16px) saturate(140%);box-shadow:0 10px 34px rgba(0,0,0,.32),inset 0 1px 0 rgba(255,255,255,.1);border:1px solid rgba(255,255,255,.1);border-radius:16px;padding:20px 22px}
.vbox.vok{border-left:3px solid var(--blue)} .vbox.vdebt{border-left:3px solid var(--yellow)}
.vbox h4{font-size:12px;font-weight:800;letter-spacing:.06em;text-transform:uppercase;margin-bottom:9px}
.vbox.vok h4{color:#9fb4ff} .vbox.vdebt h4{color:var(--yellow)}
.vbox p{font-size:13.5px;color:var(--muted);line-height:1.55} .vbox p b{color:#fff}
section{margin-top:30px} h3{font-size:15px;font-weight:800;margin-bottom:4px} h3 .k{display:block;font-size:11px;font-weight:700;color:var(--yellow);letter-spacing:.14em;text-transform:uppercase;margin-bottom:5px}
.sd{font-size:12.5px;color:var(--muted);margin-bottom:14px;max-width:84ch}
table{width:100%;border-collapse:collapse;font-size:12.5px;background:var(--panel);border:1px solid var(--line);border-radius:12px;overflow:hidden}
th,td{padding:10px 12px;text-align:center;border-bottom:1px solid var(--line)} th{background:#0c1747;color:var(--muted2);font-size:10px;text-transform:uppercase;letter-spacing:.05em;font-weight:700}
td.e,th:first-child{text-align:left;font-weight:700;color:#dfe6ff} tr:last-child td{border-bottom:none}
.grid2{display:grid;grid-template-columns:1fr 1fr;gap:18px;margin-top:16px}
@media(max-width:760px){.grid2{grid-template-columns:1fr}}
.mp{background:var(--panel);border:1px solid var(--line);border-radius:13px;padding:16px 18px}
.mp h4{font-size:12.5px;font-weight:700;color:#dfe6ff;margin-bottom:10px}
.mrow{display:grid;grid-template-columns:88px 1fr 48px;gap:9px;align-items:center;padding:3px 0;font-size:11.5px}
.me{color:var(--muted);white-space:nowrap} .mbar{background:#0c1747;border-radius:5px;height:13px;overflow:hidden}
.mbar i{display:block;height:100%;background:linear-gradient(90deg,var(--yellow),#f6e27a);border-radius:5px}
.mv{color:var(--muted);text-align:right;font-variant-numeric:tabular-nums}
.chart{width:100%;height:auto} .cap{font-size:10.5px;color:var(--muted2);margin-top:8px;text-align:center}
.hl{fill:#fff;font-size:13px;font-weight:800} .mx{fill:#9aa4c4;font-size:10px;font-weight:600}
.my{fill:#6a7299;font-size:9px} .he{fill:#c9d0ea;font-size:11px;font-weight:700}
.ediv{stroke:#3a4785;stroke-width:1;stroke-dasharray:2 2;opacity:.6} .ax0{stroke:#26317c;stroke-width:1}
.base100{stroke:#7681ac;stroke-width:1;stroke-dasharray:4 4;opacity:.7} .endl{font-size:11.5px;font-weight:700}
.legend2{display:flex;flex-wrap:wrap;gap:16px;margin-top:14px;justify-content:center}
.lg{font-size:11.5px;color:var(--muted)} .lg i{display:inline-block;width:11px;height:11px;border-radius:3px;vertical-align:middle;margin-right:6px}
.minigrid{display:grid;grid-template-columns:1fr 1fr;gap:16px;margin-top:16px}
@media(max-width:720px){.minigrid{grid-template-columns:1fr}}
.minigrid .mp h4{display:flex;justify-content:space-between;align-items:center;gap:8px;margin-bottom:6px}
.mini{width:100%;height:auto} .ml{fill:#e4eaff;font-size:11px;font-weight:700}
.badge{font-size:10.5px;font-weight:700;padding:2px 9px;border-radius:20px;white-space:nowrap}
.badge.bad{background:rgba(240,210,36,.15);color:#F0D224;border:1px solid rgba(240,210,36,.4)}
.badge.good{background:rgba(111,140,230,.18);color:#9fb4ff;border:1px solid rgba(111,140,230,.4)}
.note{margin-top:24px;padding:15px 18px;font-size:12.5px;color:var(--muted);border-radius:14px;background:rgba(255,255,255,.055);backdrop-filter:blur(15px) saturate(140%);-webkit-backdrop-filter:blur(15px) saturate(140%);box-shadow:0 8px 28px rgba(0,0,0,.3),inset 0 1px 0 rgba(255,255,255,.1);border:1px solid rgba(240,210,36,.16)} .note b{color:#e4eaff}
footer{margin-top:34px;font-size:11px;color:var(--muted2);text-align:center;border-top:1px solid var(--line);padding-top:16px}
"""
HTML=f"""<!DOCTYPE html><html lang="es"><head><meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<title>Informix · Relevo Generacional y Deuda</title><style>{CSS}</style></head><body>
<div class="aurora"><span class="b1"></span><span class="b2"></span><span class="b3"></span></div>
<header><img src="bancoppel-logo.png" alt="BanCoppel">
 <div><h1>Relevo Generacional, Vocabulario y Deuda</h1><div class="sub">Gemelo Cognitivo</div></div></header>
<div class="wrap">
 <h2 class="vtitle">Veredicto</h2>
 <div class="verdicts">
  <div class="vbox vok"><h4>◆ Vocabulario</h4><p>{verdict}</p></div>
  <div class="vbox vdebt"><h4>◆ Deuda técnica</h4><p>{debt_txt}</p></div>
 </div>

 <section><h3><span class="k">Mapa de la deuda</span>Cómo ha ido creciendo la deuda, era por era</h3>
  <div class="sd">Trayectoria del <b>índice de deuda compuesto</b> (promedio normalizado 0–100 de los cuatro proxies) sobre el <b>eje de años real</b> (2007–2026, el mismo de la evolución). El ancho de cada era es <b>proporcional a su duración</b> y los cortes marcan los relevos — así se lee consistente con las fechas.</div>
  <div class="panel">{hero}<div class="cap">Índice relativo 0–100 · promedio normalizado de huérfano, complejidad, versionado y ambigüedad · amarillo = deuda</div></div>
  <div class="minigrid">
   <div class="mp"><h4>Código huérfano <span>{b_orph}</span></h4>{m_orph}</div>
   <div class="mp"><h4>Complejidad (control-flow/SP) <span>{b_cf}</span></h4>{m_cf}</div>
   <div class="mp"><h4>Duplicación / versionado <span>{b_ver}</span></h4>{m_ver}</div>
   <div class="mp"><h4>Ambigüedad de nombrado <span>{b_amb}</span></h4>{m_amb}</div>
  </div>
  <div class="sd" style="margin-top:14px">🟡 amarillo = la métrica <b>empeoró</b> con las generaciones · 🔵 azul = <b>mejoró</b>. La ambigüedad es la única que bajó — porque heredaron el vocabulario limpio en vez de inventar términos nuevos.</div></section>

 <section><h3><span class="k">Vocabulario por era</span>¿Cada generación inventó o heredó el lenguaje?</h3>
  <div class="sd"><b>Innovación</b> = % de términos usados en la era que se acuñaron ahí por primera vez. <b>Heredado</b> = % que ya existía. Si la innovación cae y lo heredado domina → el relevo <b>adoptó</b> el idioma fundacional (consistente).</div>
  <table><thead><tr><th>Era</th><th>SPs fechados</th><th>Términos nuevos</th><th>Innovación</th><th>Heredado</th><th>Ambigüedad</th><th>Versionado</th><th>Huérfano</th><th>Complejidad</th></tr></thead><tbody>{tbody}</tbody></table></section>

 <div class="note" style="border-left:3px solid var(--yellow)"><b>Deuda de nombrado — transversal a las generaciones.</b> El mismo concepto se escribe de múltiples formas: <b>{n_syn_c} conceptos</b> bajo <b>{n_syn_a} términos-alias</b> (cliente/cte, movimiento/mov/movto, número de cliente/numcte/numcliente). Es deuda semántica acumulada por los <b>dialectos de cada relevo</b> — cada generación acuñó su propio alias para lo mismo. El target debe normalizar cada concepto a un término canónico. Detalle en el <b>Reporte de Vocabulario</b>.</div>
 <div class="note"><b>Honestidad.</b> El eje generacional usa la <b>era de creación</b> (año mínimo en comentarios) — solo entran los {DATA['n_dated']:,} SPs fechados, así que las eras recientes tienen menos muestra. La deuda se mide con <b>proxies</b> (no un análisis estático completo): ambigüedad = términos marcados <code>gap</code>; versionado = sufijos <code>_v2/bis/tmp/…</code> en el nombre; huérfano = sin autor declarado; complejidad = conteo de <code>IF/FOREACH/WHILE/CASE</code> del SP objetivo. Señalan <b>tendencia</b>, no una medición absoluta.</div>
 <footer>Gemelo Cognitivo · capas 1×2×3 + Calidad · generado por <code>extract-generations.py</code></footer>
</div></body></html>"""
open(BASE+"old/generations-bcop.html","w",encoding="utf-8").write(HTML)
print("generations-bcop.html + generations-data.json escritos")
print(f"  {len(recs):,} SPs fechados · veredicto consistencia: {'CONSISTENTE' if consistent else 'DIVERGENTE'}")
print("  era            SPs   nuevos innov herit  amb  ver orph  cf")
for r in rows:
    print(f"  {r['era']:13} {r['sp']:5} {r['new']:5} {r['innov']:4}% {r['herit']:4}% {r['amb']:3}% {r['ver']:3}% {r['orph']:3}% {r['cf']:5}")
print("  deuda que sube early->late:", ", ".join(f"{l} {a}->{b}" for l,a,b,_ in debt_up) or "ninguna")
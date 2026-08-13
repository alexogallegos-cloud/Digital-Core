#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
extract-evolution.py — Mapa evolutivo del código: cómo creció año por año, por
dominio, y cuándo aparecieron los productos bancarios. "Las vetas del árbol."

Fuente: fechas en comentarios del código (ver extract-timeline.py) + detección de
productos por nombre de SP. Genera: evolution-data.json (para evolution-bcop.html).
Etapa 3 — Business Logic Extraction · Specialist Informix SPL · SPE-AM-001
"""
import json, re, os
from collections import defaultdict, Counter

BASE = ("c:/Users/alejandro.gallegos/OneDrive - Accenture/Documents/Digital Core/"
        "03 - Software & Platform Engineering/High Velocity Modernization/"
        "Application Modernization/BanCoppel/Informix/")
SRC = BASE + "source/informix/"
CG = json.load(open(BASE + "portal/data/callgraph-data.json", encoding="utf-8"))

RE_CREATE = re.compile(r"create\s+(?:procedure|function)\b", re.I)
RE_YEAR = re.compile(r"\b(199[89]|20[0-2]\d)\b")
def isolate(t):
    ms = list(RE_CREATE.finditer(t))
    return t[ms[0].start():ms[1].start()] if len(ms) >= 2 else t

DOM = {"bdicnweb":("d01","Canal Digital","#1E6868"),"bdinteg":("d02","Integración","#2A507A"),
 "bdicred":("d03","Créditos","#7A4018"),"bdicheq":("d04","Cheques/Cuentas","#8B3535"),
 "bdisac":("d05","Saldos","#6B6B18"),"bdisolic":("d06","Solicitudes","#2E6B48"),
 "bdiaclaracion":("d07","Aclaraciones","#803060"),"bdispei":("d08","SPEI","#7A2020"),
 "bdimnsj":("d09","Mensajería","#1A7A4A"),"bdisuc":("d10","Sucursales","#485055"),
 "bdicobranza":("d11","Cobranza","#503280"),"bdicont":("d12","Contabilidad","#3D5A24")}

# productos/capacidades bancarias detectables por nombre de SP
PROD = [
 ("spei",       r"spei",                         "SPEI (interbancario)"),
 ("codi",       r"(?<!de)codi(?![gf])",           "CoDi (cobro digital)"),  # excluye codigo/codificacion/decodifica
 ("tdc",        r"tdc|tarjeta|intercard",        "Tarjeta"),
 ("hipoteca",   r"hipotec",                      "Hipoteca"),
 ("remesa",     r"remesa",                       "Remesas"),
 ("afore",      r"afore",                        "Afore"),
 ("inversion",  r"inver|pagare|plazo",           "Inversión / plazo"),
 ("nomina",     r"nomina",                        "Nómina"),
 ("credito",    r"credito|prestamo|\bcred\b|lincred|scoring|califica", "Crédito"),
 ("domicil",    r"domicil",                       "Domiciliación"),
 ("cobranza",   r"cobranz|moratori|reestructura", "Cobranza / recuperación"),
 ("aclara",     r"aclara",                        "Aclaraciones"),
 ("fiscal",     r"\bisr\b|\biva\b|fiscal|cedula", "Fiscal (ISR/IVA)"),
 ("digital",    r"digital|_web|_mvl|_bpi|_app|clic","Canal digital / móvil"),
 ("inactiv",    r"inactiv|art61|beneficencia",    "Cuentas inactivas (Art.61)"),
]

# hitos históricos de banca MX / BanCoppel — correlacionan con los picos de actividad del código
MILESTONES = [
 (2004,"Banxico lanza SPEI (infraestructura de pagos)"),
 (2007,"BanCoppel inicia operaciones — banca la base de crédito de Coppel"),
 (2008,"Crisis financiera global · Agustín Coppel Luken dirige el Grupo"),
 (2010,"Coppel entra a Brasil y Argentina · BanCoppel escala captación y sucursales"),
 (2012,"Ley de transparencia / RECO CONDUSEF"),
 (2013,"Reforma Financiera MX + Ley Antilavado (PLD) vigente"),
 (2014,"CNBV Circular Única de Bancos · BanCoppel supera 850 sucursales"),
 (2015,"BanCoppel abre banca empresarial · Coppel compra 51 tiendas Viana (Brasil)"),
 (2016,"Actualización SPEI · Coppel inicia su salida de Brasil"),
 (2017,"App BanCoppel — banca móvil"),
 (2018,"Ley Fintech"),
 (2019,"Banxico lanza CoDi (cobros QR sobre SPEI)"),
 (2020,"Pandemia COVID-19 · 1ª sucursal independiente (Atlacomulco) · aceleración digital"),
 (2021,"López-Moctezuma asume dirección general (foco inclusión financiera)"),
 (2022,"Open banking / APIs Ley Fintech · nuevo consejo · crece banca corporativa"),
 (2023,"BanCoppel = 3ª red bancaria del país (1,300+ sucursales, 32 estados)"),
 (2024,"Caída mayor del sistema Coppel (abril) · impulso de productos digitales"),
 (2025,"Coppel renueva e-commerce y transformación digital · BanCoppel hipoteca digital"),
]

stream = defaultdict(lambda: Counter())   # year -> {dom: n creados}
prod_year = defaultdict(lambda: Counter()) # prod_key -> {year: n}
prod_first = {}                            # prod_key -> primer año
n_dated = n_sp = 0
YMIN, YMAX = 2007, 2026

for node in CG["graph"]["nodes"]:
    db, sp = node["id"].split(":", 1)
    if db not in DOM:
        continue
    fp = SRC + f"{db}_{sp}.sql"
    if not os.path.exists(fp):
        continue
    n_sp += 1
    txt = isolate(open(fp, encoding="utf-8", errors="replace").read())
    years = set()
    for ln in txt.split("\n"):
        s = ln.strip()
        if s.startswith("--") or s.startswith("{"):
            for y in RE_YEAR.findall(s):
                yi = int(y)
                if YMIN <= yi <= YMAX:
                    years.add(yi)
    if not years:
        continue
    n_dated += 1
    ycre = min(years)                       # año de creación (aprox)
    dom = DOM[db][0]
    stream[ycre][dom] += 1
    # productos que toca este SP (por nombre)
    low = sp.lower()
    for key, pat, label in PROD:
        if re.search(pat, low):
            prod_year[key][ycre] += 1
            if key not in prod_first or ycre < prod_first[key]:
                prod_first[key] = ycre

years = list(range(YMIN, YMAX + 1))
domains = {v[0]: {"name": v[1], "color": v[2]} for v in DOM.values()}
stream_rows = [{"year": y, **{d: stream[y].get(d, 0) for d in domains}} for y in years]
products = []
labelmap = {k: lbl for k, _, lbl in PROD}
for key in prod_first:
    products.append({"key": key, "label": labelmap[key], "first": prod_first[key],
                     "by_year": {str(y): prod_year[key].get(y, 0) for y in years if prod_year[key].get(y, 0)},
                     "total": sum(prod_year[key].values())})
products.sort(key=lambda p: p["first"])

out = {"years": years, "domains": domains, "stream": stream_rows,
       "products": products, "milestones": [{"year": y, "label": l} for y, l in MILESTONES],
       "meta": {"n_dated": n_dated, "n_sp": n_sp}}
json.dump(out, open(BASE + "portal/data/evolution-data.json", "w", encoding="utf-8"),
          ensure_ascii=False, separators=(",", ":"))

print(f"evolution-data.json escrito · {n_dated:,}/{n_sp:,} SPs con fecha")
print("\nSPs creados por año (con fecha):")
mx = max(sum(stream[y].values()) for y in years) or 1
for y in years:
    tot = sum(stream[y].values())
    print(f"  {y}  {'█'*int(28*tot/mx)} {tot}")
print("\nProductos — primer año de aparición en el código:")
for p in products:
    print(f"  {p['first']}  {p['label']:26} ({p['total']} SPs)")
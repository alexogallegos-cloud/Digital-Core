#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
update-knowledge-base.py — Actualiza los MD canónicos de knowledge-base/{dominio}/
con TODO lo identificado en la Etapa 3, reemplazando las plantillas [SME-PENDING]:
  · 00-business-process-catalog.md  ← procesos de negocio (journeys)
  · 01-journey.md                   ← journeys + cadenas + objetivos + flujo
  · 04-business-rules.md            ← reglas/fórmulas + marcado regulatorio + riesgo

Fuentes: journeys-data.json · business-rules.json · flow-data.json · sp_vocab.py
Etapa 3 — Business Logic Extraction · Specialist Informix SPL · SPE-AM-001
"""
import json, os
from collections import defaultdict

BASE = ("c:/Users/alejandro.gallegos/OneDrive - Accenture/Documents/Digital Core/"
        "03 - Software & Platform Engineering/High Velocity Modernization/"
        "Application Modernization/BanCoppel/Informix/")
KB = BASE + "knowledge-base/"
J  = json.load(open(BASE + "portal/data/journeys-data.json", encoding="utf-8"))
BR = json.load(open(BASE + "portal/data/business-rules.json", encoding="utf-8"))
FD = json.load(open(BASE + "portal/data/flow-data.json", encoding="utf-8"))

# metadata por dominio (db, nombre, carpeta, wave, riesgo, reguladores)
DOM = {
 "d01":("bdicnweb","Canal Digital Web","D01-bdicnweb",6,"ALTO",[]),
 "d02":("bdinteg","Integración y Auth","D02-bdinteg",5,"CRÍTICO",["CNBV"]),
 "d03":("bdicred","Créditos","D03-bdicred",4,"CRÍTICO",["CNBV","SAT","CONDUSEF"]),
 "d04":("bdicheq","Cheques / Cuentas","D04-bdicheq",4,"CRÍTICO",["CNBV","TESOFE","IPAB","CONDUSEF"]),
 "d05":("bdisac","Saldos y Cuentas","D05-bdisac",3,"ALTO",["CNBV","IPAB","SAT"]),
 "d06":("bdisolic","Solicitudes","D06-bdisolic",3,"ALTO",["CNBV","CONDUSEF"]),
 "d07":("bdiaclaracion","Aclaraciones","D07-bdiaclaracion",2,"ALTO",["CONDUSEF","CNBV"]),
 "d08":("bdispei","SPEI","D08-bdispei",2,"CRÍTICO",["Banxico"]),
 "d09":("bdimnsj","Mensajería","D09-bdimnsj",1,"BAJO",["CNBV","CONDUSEF"]),
 "d10":("bdisuc","Sucursales","D10-bdisuc",3,"ALTO",["CNBV"]),
 "d11":("bdicobranza","Cobranza","D11-bdicobranza",2,"MEDIO",["CNBV","CONDUSEF"]),
 "d12":("bdicont","Contabilidad","D12-bdicont",4,"ALTO",["SAT","IPAB","CNBV"]),
}
SME_REG = {"CNBV":"SME/Regulatory/CNBV/","Banxico":"SME/Regulatory/Banxico/",
 "CONDUSEF":"SME/Regulatory/CONDUSEF/","SAT":"SME/Regulatory/SAT/",
 "TESOFE":"SME/Regulatory/TESOFE/","IPAB":"SME/Regulatory/IPAB/"}

# reglas por db
rules_by_db = defaultdict(list)
for r in BR["rules"]:
    rules_by_db[r["db"]].append(r)

def header(dom, db, name, folder, wave, riesgo, regs, titulo):
    rr = "\n".join(f"- **SME Regulatorio — {r}** (`{SME_REG[r]}`)" for r in regs)
    return f"""# {dom.upper()} · {name} — {titulo}

> **Componente:** Informix · SPE-AM-001 · **Etapa 3 — Business Logic Extraction**
> **Base de datos:** `{db}` · IBM Informix IDS 14.10 FC10W2 / POWER-AIX
> **Wave de migración:** Wave {wave} · Riesgo: **{riesgo}**
> **Última actualización:** 2026-07-04 · *generado del análisis del código (reemplaza plantilla)*

---
**SME responsable:**
- Specialist — Informix SPL Analysis (análisis estático, extracción de reglas)
- Domain Expert — BanCoppel (validación funcional de negocio)
- **SME — Modelo Operativo Bancario** (BIAN Service Domains · capacidades retail banking · cadena de valor · mapeo dominio técnico ↔ capacidad de negocio)
- Data Architect (modelado target PostgreSQL / Aurora)
- QA Lead — Equivalencia Funcional (golden master y criterios go/no-go)
{rr}

> Secciones marcadas `[SME-PENDING]` requieren validación del Domain Expert o SME regulador antes de BUILD.
---
"""

def fmt_steps(steps, depth=0, out=None, cap=[0]):
    if out is None: out=[]; cap[0]=0
    for s in steps:
        if cap[0]>=10: break
        tag = f" → {s['db']}" if s.get("cross") else ""
        rg = " · reg" if s.get("reg") else ""
        out.append(f"{'  '*depth}- `{s['name']}` — {s.get('biz','')}{tag}{rg}")
        cap[0]+=1
        if s.get("children"): fmt_steps(s["children"], depth+1, out, cap)
    return out

def gen_journey(dom):
    db,name,folder,wave,riesgo,regs = DOM[dom]
    dd = J[dom]
    L=[header(dom,db,name,folder,wave,riesgo,regs,"Journeys de Negocio")]
    L.append(f"\n## Resumen del dominio\n")
    L.append(f"`{dd['sp_count']:,} SPs` · **{len(dd['journeys'])} journeys orquestadores** · "
             f"**{len(dd.get('exposed',[]))} servicios expuestos** · reguladores: {', '.join(regs) or '—'}\n")
    L.append("Los journeys y sus objetivos se derivaron del call graph + vocabulario de negocio "
             "(`vocabulary-knowledge-base-bcop.md`). El nombre técnico del SP se conserva para trazabilidad.\n")
    if dd["journeys"]:
        L.append("## Journeys orquestadores\n")
        for j in dd["journeys"]:
            trig = ", ".join("App/Batch/Canal" if t["dom"]=="app" else t["dom"].upper() for t in j.get("triggered_by",[]))
            L.append(f"### {j.get('biz') or j['sp']}")
            L.append(f"> SP: `{j['sp']}` · fan_out {j['fan_out']} · callers externos {j['ext_callers']} · "
                     f"disparado por: {trig}{' · **REGULATORIO**' if j.get('reg') else ''}\n")
            if j.get("steps"):
                L.append("Secuencia de invocaciones (cadena del call graph):\n")
                L += fmt_steps(j["steps"])
                L.append("")
    if dd.get("exposed"):
        L.append("## Servicios expuestos (endpoints — alto fan-in)\n")
        L.append("| SP | Objetivo | callers ext | reg |")
        L.append("|----|----------|------------:|:---:|")
        for j in dd["exposed"]:
            L.append(f"| `{j['sp']}` | {j.get('biz','')} | {j['ext_callers']} | {'🔴' if j.get('reg') else ''} |")
        L.append("")
    L.append("## `[SME-PENDING]` Validación con Domain Expert\n")
    L.append("- [ ] Confirmar el nombre de negocio oficial de cada journey (los objetivos son inferidos del vocabulario).")
    L.append("- [ ] Validar el canal/actor real que dispara cada journey.")
    L.append("- [ ] Confirmar journeys no visibles en el call graph estático (triggers, EXEC dinámico).\n")
    L.append("---\n*Generado por update-knowledge-base.py · Etapa 3 · fuente: journeys-data.json + flow-data.json*")
    return "\n".join(L)

def gen_rules(dom):
    db,name,folder,wave,riesgo,regs = DOM[dom]
    rs = rules_by_db.get(db,[])
    formulas=[r for r in rs if r["tipo"]=="FÓRMULA"]
    valids=[r for r in rs if r["tipo"]=="VALIDACIÓN"]
    reg_hits=defaultdict(list)
    for r in rs:
        for reg,norma in r.get("reg",[]): reg_hits[reg].append((r,norma))
    L=[header(dom,db,name,folder,wave,riesgo,regs,"Reglas de Negocio y Fórmulas")]
    L.append(f"\n## Resumen\n")
    L.append(f"**{len(formulas)} fórmulas** + **{len(valids)} validaciones** extraídas del código de `{db}`. "
             f"Reguladores con reglas: {', '.join(sorted(reg_hits)) or '—'}.\n")
    if formulas:
        L.append("## Fórmulas de negocio (evidencia directa del código)\n")
        L.append("| ID | SP · línea | Regulador | Fórmula | Riesgo equivalencia |")
        L.append("|----|-----------|-----------|---------|---------------------|")
        seen=set()
        for r in formulas:
            k=(r["sp"],r["code"][:50])
            if k in seen: continue
            seen.add(k)
            reg=" · ".join(x[0] for x in r.get("reg",[])) or "operacional"
            code=r["code"].replace("|","/")[:70]
            ri=" ⚠ "+"; ".join(r["riesgo"]) if r.get("riesgo") else ""
            L.append(f"| {r['id']} | `{r['sp']}` L{r['line']} | {reg} | `{code}` |{ri} |")
        L.append("")
    if reg_hits:
        L.append("## Reglas por regulador (SME dueño)\n")
        for reg in ["CNBV","Banxico","CONDUSEF","SAT","TESOFE","IPAB"]:
            items=reg_hits.get(reg,[])
            if not items: continue
            norma=items[0][1]
            L.append(f"- **{reg}** (`{SME_REG[reg]}`) — {len(items)} reglas · {norma}")
        L.append("")
    if any(r.get("riesgo") for r in formulas):
        L.append("## `[RIESGO-EQUIVALENCIA]` en este dominio\n")
        L.append("Semántica Informix que debe preservarse exacta en el target (golden master ≥ 99.95%):")
        L.append("- **TRUNC vs ROUND** · **base 360 vs 365** · **tipo MONEY (banker's rounding)** — divergencia auditable.\n")
    L.append("## `[SME-PENDING]` Validación regulatoria\n")
    L.append("- [ ] Cada fórmula → validar con el SME regulador dueño (ver `regulatory-validation-packets-bcop.md`).")
    L.append("- [ ] Confirmar parámetros: tasas, bases de cálculo (360/365), plazos.")
    L.append("- [ ] Definir golden master test por fórmula.\n")
    L.append("---\n*Generado por update-knowledge-base.py · Etapa 3 · fuente: business-rules.json*")
    return "\n".join(L)

def gen_catalog(dom):
    db,name,folder,wave,riesgo,regs = DOM[dom]
    dd = J[dom]
    L=[header(dom,db,name,folder,wave,riesgo,regs,"Catálogo de Procesos de Negocio")]
    L.append(f"\n## Rol del dominio\n")
    L.append(f"`{db}` · Wave {wave} · Riesgo {riesgo}. {dd['sp_count']:,} SPs; "
             f"{len(dd['journeys'])} procesos orquestados + {len(dd.get('exposed',[]))} servicios expuestos.\n")
    L.append("## Inventario de procesos de negocio identificados\n")
    L.append("| ID | Proceso (objetivo) | SP entry point | Tipo | Reg |")
    L.append("|----|--------------------|----------------|------|:---:|")
    i=0
    for j in dd["journeys"]:
        i+=1
        L.append(f"| BP-{dom.upper()}-{i:02d} | {j.get('biz') or j['sp']} | `{j['sp']}` | Orquestador | {'🔴' if j.get('reg') else ''} |")
    for j in dd.get("exposed",[]):
        i+=1
        L.append(f"| BP-{dom.upper()}-{i:02d} | {j.get('biz') or j['sp']} | `{j['sp']}` | Servicio expuesto | {'🔴' if j.get('reg') else ''} |")
    L.append("")
    L.append("> Detalle de cadenas de llamadas en `01-journey.md` · reglas y fórmulas en `04-business-rules.md`.\n")
    L.append("## `[SME-PENDING]`\n- [ ] Nombre de negocio oficial de cada proceso.\n- [ ] Frecuencia y criticidad operativa.\n")
    L.append("---\n*Generado por update-knowledge-base.py · Etapa 3 · fuente: journeys-data.json*")
    return "\n".join(L)

n=0
for dom,(db,name,folder,wave,riesgo,regs) in DOM.items():
    d = KB + folder + "/"
    if not os.path.isdir(d):
        print(f"  ⚠ carpeta no encontrada: {folder}"); continue
    open(d+"00-business-process-catalog.md","w",encoding="utf-8").write(gen_catalog(dom))
    open(d+"01-journey.md","w",encoding="utf-8").write(gen_journey(dom))
    open(d+"04-business-rules.md","w",encoding="utf-8").write(gen_rules(dom))
    n+=3
    fx=len([r for r in rules_by_db.get(db,[]) if r["tipo"]=="FÓRMULA"])
    print(f"  {dom.upper()} {name:20} · {len(J[dom]['journeys'])} journeys · {fx} fórmulas")
print(f"\n{n} archivos actualizados en knowledge-base/ (00, 01, 04 × 12 dominios)")
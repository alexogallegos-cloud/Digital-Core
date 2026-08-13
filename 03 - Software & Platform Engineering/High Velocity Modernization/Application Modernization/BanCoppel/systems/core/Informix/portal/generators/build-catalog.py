#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Genera journeys-catalog-bcop.md: lista de journeys + catálogo de términos.
Usa el vocabulario compartido sp_vocab.py. Etapa 3 — Business Logic Extraction.
Ejecutar DESPUÉS de extract-journeys.py (consume journeys-data.json)."""
import json
from collections import Counter
from sp_vocab import CAT, COMPOUND, compose, tokenize

BASE = ("c:/Users/alejandro.gallegos/OneDrive - Accenture/Documents/Digital Core/"
        "03 - Software & Platform Engineering/High Velocity Modernization/"
        "Application Modernization/BanCoppel/Informix/")
J = json.load(open(BASE + "portal/data/journeys-data.json", encoding="utf-8"))

DOM_NAME = {"d01":"Canal Digital Web","d02":"Integración y Auth","d03":"Créditos",
 "d04":"Cheques / Cuentas","d05":"Saldos y Cuentas","d06":"Solicitudes",
 "d07":"Aclaraciones","d08":"SPEI","d09":"Mensajería","d10":"Sucursales",
 "d11":"Cobranza","d12":"Contabilidad"}
DOM_REG = {"d02":["CNBV"],"d03":["CNBV","SAT","CONDUSEF"],"d04":["CNBV","TESOFE","IPAB","CONDUSEF"],
 "d05":["CNBV","IPAB","SAT"],"d06":["CNBV","CONDUSEF"],"d07":["CONDUSEF","CNBV"],
 "d08":["Banxico"],"d09":["CNBV","CONDUSEF"],"d10":["CNBV"],"d11":["CNBV","CONDUSEF"],"d12":["SAT","IPAB","CNBV"]}

ESTADO_ICON = {"conf":"", "partial":" ◔", "gap":" 🔶"}

lines = ["# Informix · Catálogo de Journeys y Términos de Negocio",
 "",
 "> **Componente:** Informix · SPE-AM-001 · Etapa 3 — Business Logic Extraction  ",
 "> **Base:** IBM Informix IDS 14.10 FC10W2 / POWER-AIX · **Evidencia:** `callgraph-data.json` + `journeys-data.json`  ",
 "> **Generado:** 2026-07-03 · **Método:** tokenización de nombres de SP contra vocabulario bancario es-MX (`sp_vocab.py`)  ",
 "",
 "> ⚠ **Los objetivos son inferidos por composición de tokens** — la estructura (cadena de SPs) es real; el nombre de negocio requiere validación `[CONSULTAR→NEGOCIO]`.  ",
 "> Marcas de confianza: `◔` = parcial (algún token inferido o fragmento no reconocido) · `🔶` = ambiguo, requiere DBA/Domain Expert.",
 "",
 "---",
 "",
 "## A · Lista de journeys por dominio",
 ""]

total_j = total_e = 0
for dom in sorted(J.keys()):
    dd = J[dom]
    reg = DOM_REG.get(dom, [])
    regs = f" · reg: {' · '.join(reg)}" if reg else ""
    lines.append(f"### {dom.upper()} — {DOM_NAME[dom]}  \n`{dd['sp_count']} SPs`{regs}\n")
    if dd["journeys"]:
        lines.append("| SP (entry point) | Objetivo inferido | fan_out | reg |")
        lines.append("|---|---|--:|:--:|")
        for j in dd["journeys"]:
            obj, flag, estado = compose(j["sp"])
            total_j += 1
            lines.append(f"| `{j['sp']}` | {obj}{ESTADO_ICON.get(estado,'')} | {j['fan_out']} | {'🔴' if j['reg'] else ''} |")
        lines.append("")
    if dd.get("exposed"):
        lines.append("**Servicios expuestos (endpoints — sinks con alto fan-in):**\n")
        lines.append("| SP | Objetivo inferido | callers ext | reg |")
        lines.append("|---|---|--:|:--:|")
        for j in dd["exposed"]:
            obj, flag, estado = compose(j["sp"])
            total_e += 1
            lines.append(f"| `{j['sp']}` | {obj}{ESTADO_ICON.get(estado,'')} | {j['ext_callers']} | {'🔴' if j['reg'] else ''} |")
        lines.append("")

# ══ CATÁLOGO DE TÉRMINOS ══
lines += ["---","","## B · Catálogo de términos (glosario tokenizado)","",
 "Cada nombre de SP se descompone en **prefijo + acción + entidad + modificador**. "
 "Este glosario permite componer el objetivo de cualquier SP nuevo sin re-analizarlo a mano — "
 "editar `sp_vocab.py` y re-correr `extract-journeys.py` + `build-catalog.py`.",
 "",
 "Estado: `conf` = confirmado por evidencia · `inf` = inferido (probable) · `gap` = ambiguo, requiere SME/DBA.",
 ""]
CATLABEL = {"PREFIJO":"Prefijos / familia","ACCION":"Acciones (verbos)","ENTIDAD":"Entidades (objetos de negocio)",
 "MODIF":"Modificadores","REG":"Regulatorio","AMBIGUO":"Ambiguos — requieren validación SME/DBA"}
allfreq = Counter()
for dom, dd in J.items():
    for lst in (dd["journeys"], dd.get("exposed", [])):
        for j in lst:
            for t in tokenize(j["sp"]):
                if not t.startswith("?"):
                    allfreq[t] += 1
for cat in ["PREFIJO","ACCION","ENTIDAD","MODIF","REG","AMBIGUO"]:
    lines.append(f"### {CATLABEL[cat]}\n")
    lines.append("| Término | Significado | Estado | Frec |")
    lines.append("|---|---|:--:|--:|")
    items = sorted([(k, v) for k, v in CAT.items()
                    if v[0] == cat and len(k) > 1 and k not in COMPOUND],
                   key=lambda x: (-allfreq.get(x[0], 0), x[0]))
    for k, (c, mean, st) in items:
        lines.append(f"| `{k}` | {mean} | {st} | {allfreq.get(k,0)} |")
    lines.append("")

lines += ["---","","## C · Regla de composición del objetivo","",
 "```",
 "OBJETIVO = [ACCION principal] + [ENTIDAD(es)] + ([MODIFICADOR(es)]) + [· REGULATORIO]",
 "",
 "Ejemplos:",
 "  spei_aplicaordenpago         -> aplica + orden de pago                -> \"aplica orden de pago\"",
 "  sp_fal_busca_pagares_cliente -> busca + pagarés + cliente             -> \"busca pagarés + cliente\"",
 "  sp_consreportesctasinactivasart61 -> consulta reportes + cuentas inactivas · Art.61 LIC",
 "  cargo_ref                    -> cargo/débito (ref)                    -> \"cargo/débito\"",
 "```",
 "",
 f"**Cobertura:** {total_j} journeys orquestadores + {total_e} servicios expuestos = {total_j+total_e} flujos · "
 f"{len([k for k in CAT if len(k)>1 and k not in COMPOUND])} términos en catálogo.",
 "",
 "## D · Pendientes de validación `[CONSULTAR→NEGOCIO / DBA]`","",
 "- Sufijos `b3`/`b4`/`b5` (contabilidad y BYM): ¿versión de release, número de bloque, o fase contable?",
 "- Familia `bym`/`bym2`/`bym3` (sucursales): ¿qué significa el acrónimo BYM?",
 "- `soc` → **Sistema Operativo Central** (confirmado SME 2026-07-03) — ya no ambiguo.",
 "- `pba`, `tco`, `bpi`, `mc`, `ccl`: acrónimos sin expansión confirmada.",
 "- `ivasart61`: confirmar si es IVA fiscal o Art. 61 LIC (cuentas inactivas cuyos saldos prescriben a favor de la beneficencia pública).",
 "- **D01** presenta journeys con `fan_out=124` idéntico (patrón de reporteo repetido) — revisar si son genuinos o artefacto del análisis.",
 "",
 "*Generado por Specialist — Informix SPL Analysis · Etapa 3 · fuente: journeys-data.json + sp_vocab.py + build-catalog.py*"]

open(BASE + "knowledge-base/journeys-catalog-bcop.md", "w", encoding="utf-8").write("\n".join(lines))
print(f"knowledge-base/journeys-catalog-bcop.md escrito · {total_j} journeys + {total_e} expuestos · "
      f"{len([k for k in CAT if len(k)>1 and k not in COMPOUND])} términos")
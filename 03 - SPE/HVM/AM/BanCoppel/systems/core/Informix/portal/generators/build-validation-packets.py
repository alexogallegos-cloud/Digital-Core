#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
build-validation-packets.py — Genera el paquete [INVOKE] de validación por cada
SME regulador: las reglas/fórmulas que le tocan + preguntas específicas curadas.
Es el insumo para las sesiones HITL con los agentes reguladores.

Consume: business-rules.json · Genera: regulatory-validation-packets-bcop.md
Etapa 3 — Business Logic Extraction · Specialist Informix SPL · SPE-AM-001
"""
import json
from collections import defaultdict

BASE = ("c:/Users/alejandro.gallegos/OneDrive - Accenture/Documents/Digital Core/"
        "03 - SPE/HVM/AM/BanCoppel/Informix/")
BR = json.load(open(BASE + "portal/data/business-rules.json", encoding="utf-8"))

SME = {
 "CNBV":     "SME/Regulatory/CNBV/",
 "Banxico":  "SME/Regulatory/Banxico/",
 "CONDUSEF": "SME/Regulatory/CONDUSEF/",
 "SAT":      "SME/Regulatory/SAT/",
 "TESOFE":   "SME/Regulatory/TESOFE/",
 "IPAB":     "SME/Regulatory/IPAB/",
}
DOMN = {"bdicheq":"D04","bdicred":"D03","bdisac":"D05","bdispei":"D08","bdicont":"D12",
        "bdisolic":"D06","bdiaclaracion":"D07","bdimnsj":"D09","bdicnweb":"D01",
        "bdinteg":"D02","bdicobranza":"D11","bdisuc":"D10"}

# preguntas de validación curadas por regulador (conocimiento de dominio + hallazgos del código)
PREGUNTAS = {
 "SAT": [
  "Tasa de retención de ISR sobre intereses: el código usa `vtasa_isr` parametrizada — ¿el valor vigente es **0.90% anual** (LIF 2026)? ¿Cómo/cuándo se actualiza?",
  "Base de cálculo del ISR: `calc_isr` usa `vaniobase` (`… × días / vaniobase`) — ¿es **360** (año comercial) o **365**? Impacta todos los cálculos.",
  "Uso de **`TRUNC`** (no ROUND) en `calc_isr` — ¿es intencional y debe preservarse **exacto** en el target? Divergencia = observación SAT.",
  "¿Aplica exención por **UMA** sobre intereses (monto exento)? ¿Dónde se calcula el importe gravable (`vbase_gravable`)?",
  "IVA: ¿**16% general / 8% frontera**? ¿Qué comisiones causan IVA y cuál es la fuente de la tasa por sucursal (`dIvaSuc`)?",
 ],
 "CNBV": [
  "Base de cálculo de interés: `calc_interes` usa **/360** y `calcula_int` usa `vnumdias` — ¿confirmar 360 vs 365 por producto?",
  "**Art.61 LIC** (cuentas inactivas): `sp_blqdesconcentractasinactivas` procesa cuentas inactivas — ¿plazo (3 años) y proceso de traspaso a beneficencia pública correctos?",
  "**Atomicidad** débito-crédito: `cargo_ref`/`abono_ref` — ¿el target debe garantizar ACID estricto (sin cargos parciales)?",
  "Criterios contables **B-1 a D-4**: ¿cuáles aplican a las fórmulas de reserva/moratorios (`sp_calculo_reserva_corte_crd`)?",
 ],
 "CONDUSEF": [
  "Fórmula **GAT nominal** (`sp_cap_recalculagat1200`): `ROUND((POW((1+tasa/periodo),periodo)-1),2)` — ¿el `periodo` de capitalización es correcto por producto?",
  "**GAT real**: ajuste por inflación `(1+GAT_nom)/(1+inflación)-1` — ¿la fuente de la inflación (`dMedianaInfl`) es el INPC/mediana Banxico vigente?",
  "**CAT** (Costo Anual Total): ¿se calcula con fórmula IRR? ¿en qué SP? (no detectado claramente en el código — confirmar).",
  "**Comisiones**: ¿todas las de `sp_consultacatcomisiones*` están registradas en **RECO** con el monto exacto del código?",
  "Comisión de apertura `ROUND(monto/12,2)` (`sp_comisionxapertura_contable`) — ¿prorrateo correcto?",
 ],
 "Banxico": [
  "**Clave de rastreo SPEI** (30 posiciones): ¿la generación en `sp_regordenctecte_bex_codi` cumple Circular 3/2012?",
  "**CoDi**: reglas de cobro digital en los SPs `*_codi` — ¿validación de mensajes conforme a especificación Banxico?",
  "Migración **ISO 20022**: ¿pendiente? ¿impacta el formato de estos SPs?",
  "Ventana SPEI (mantenimiento sábado 22:00–domingo 06:00): ¿se refleja en la lógica de envío?",
 ],
 "TESOFE": [
  "**Dispersión bimestral** (Pensión Bienestar / Becas): ¿la cadena TESOFE→SPEI→`abono_ref` es correcta? ¿ventana de cutover?",
  "**Cuenta concentradora**: ¿mecánica de sweeping y clasificación de fondos federales?",
 ],
 "IPAB": [
  "**Cuota 4 al millar** (LPAB Art.22): ¿se calcula en el core o en un sistema contable externo? (los SPs de cuota no se detectaron claramente).",
  "**Pasivos asegurados**: base de cálculo — ¿qué depósitos incluye/excluye?",
  "**Cobertura 400,000 UDIs**: ¿se valida en el core el límite por cliente?",
 ],
}

# agrupar reglas por regulador (dedup por sp+code)
by_reg = defaultdict(list)
for r in BR["rules"]:
    for reg, norma in r.get("reg", []):
        by_reg[reg].append((r, norma))

def es_relevante(r):
    """para el paquete: fórmulas + validaciones de rechazo (RAISE / codret de error)."""
    if r["tipo"] == "FÓRMULA":
        return True
    c = r["code"].lower()
    return "raise exception" in c or ("codret" in c and "'00000'" not in c and '"00000"' not in c)

L = ["# Informix · Paquetes de Validación Regulatoria (HITL)",
 "",
 "> **Componente:** Informix · SPE-AM-001 · Etapa 3 — Business Logic Extraction  ",
 "> **Generado:** 2026-07-04 · Insumo para las sesiones de validación con los **SMEs reguladores**  ",
 "",
 "Para cada regulador: el **packet `[INVOKE]`** hacia su agente SME, las **preguntas específicas** de "
 "validación (derivadas de las fórmulas/reglas halladas en el código) y las **reglas a validar**. "
 "Cada respuesta del SME se incorpora al golden master (equivalencia ≥ 99.95% en cálculos financieros).",
 "",
 "---", ""]

for reg in ["CNBV", "Banxico", "CONDUSEF", "SAT", "TESOFE", "IPAB"]:
    items = by_reg.get(reg, [])
    # dedup por (sp, code normalizado), prioriza fórmulas
    seen, uniq = set(), []
    for r, norma in sorted(items, key=lambda x: 0 if x[0]["tipo"] == "FÓRMULA" else 1):
        if not es_relevante(r):
            continue
        k = (r["sp"], r["code"][:50])
        if k in seen:
            continue
        seen.add(k); uniq.append((r, norma))
    n_form = sum(1 for r, _ in uniq if r["tipo"] == "FÓRMULA")
    doms = sorted({DOMN.get(r["db"], r["db"]) for r, _ in uniq})

    L.append(f"## {reg} — SME Regulatorio")
    L.append(f"> Agente: `{SME[reg]}` · **{len(uniq)} reglas relevantes** ({n_form} fórmulas) · dominios: {', '.join(doms)}")
    L.append("")
    L.append("### Packet `[INVOKE]`")
    L.append("```")
    L.append(f"[INVOKE: SME Regulatorio — {reg} en {SME[reg]}]")
    L.append(f"COMPONENTE   : Informix · SPE-AM-001 · Etapa 3 Business Logic Extraction")
    L.append(f"SOLICITUD    : Validar {len(uniq)} reglas/fórmulas de negocio extraídas del código SPL")
    L.append(f"ALCANCE      : Fórmulas financieras y validaciones con impacto {reg}")
    L.append(f"DOMINIOS     : {', '.join(doms)}")
    L.append(f"ENTREGABLE   : Confirmación de cada fórmula + parámetros (tasas, bases, plazos) +")
    L.append(f"               definición del golden master test por regla")
    L.append(f"CRITICIDAD   : Equivalencia ≥ 99.95% (auditable ante {reg})")
    L.append("```")
    L.append("")
    L.append("### Preguntas de validación")
    for q in PREGUNTAS.get(reg, []):
        L.append(f"- [ ] {q}")
    L.append("")
    L.append("### Reglas a validar (prioridad: fórmulas primero)")
    L.append("")
    L.append("| ID | Tipo | SP · línea | Norma | Evidencia (código) |")
    L.append("|----|------|-----------|-------|--------------------|")
    for r, norma in uniq[:30]:
        code = r["code"].replace("|", "/")[:72]
        rk = " ⚠" if r.get("riesgo") else ""
        L.append(f"| {r['id']} | {r['tipo']}{rk} | `{r['sp']}` L{r['line']} | {norma[:44]} | `{code}` |")
    if len(uniq) > 30:
        L.append(f"| … | | | | *(+{len(uniq)-30} reglas más en `business-rules-bcop.md`)* |")
    L.append("")
    L.append("---")
    L.append("")

L += ["*Generado por Specialist — Informix SPL Analysis · Etapa 3 · fuente: business-rules.json · "
      "coordina con SMEs en SME/Regulatory/*"]

open(BASE + "knowledge-base/regulatory-validation-packets-bcop.md", "w", encoding="utf-8").write("\n".join(L))
tot = sum(len(v) for v in by_reg.values())
print("knowledge-base/regulatory-validation-packets-bcop.md escrito.")
for reg in ["CNBV", "Banxico", "CONDUSEF", "SAT", "TESOFE", "IPAB"]:
    print(f"  {reg:9} {len(by_reg.get(reg,[]))} reglas · {len(PREGUNTAS.get(reg,[]))} preguntas")
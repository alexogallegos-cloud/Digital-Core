# D06 · Solicitudes — Reglas de Negocio y Fórmulas

> **Componente:** LegacyCore · SPE-AM-001 · **Etapa 3 — Business Logic Extraction**
> **Base de datos:** `bdisolic` · IBM Informix IDS 14.10 FC10W2 / POWER-AIX
> **Wave de migración:** Wave 3 · Riesgo: **ALTO**
> **Última actualización:** 2026-07-04 · *generado del análisis del código (reemplaza plantilla)*

---
**SME responsable:**
- Specialist — Informix SPL Analysis (análisis estático, extracción de reglas)
- Domain Expert — LegacyCore (validación funcional de negocio)
- **SME — Modelo Operativo Bancario** (BIAN Service Domains · capacidades retail banking · cadena de valor · mapeo dominio técnico ↔ capacidad de negocio)
- Data Architect (modelado target PostgreSQL / Aurora)
- QA Lead — Equivalencia Funcional (golden master y criterios go/no-go)
- **SME Regulatorio — CNBV** (`SME/Regulatory/CNBV/`)
- **SME Regulatorio — CONDUSEF** (`SME/Regulatory/CONDUSEF/`)

> Secciones marcadas `[SME-PENDING]` requieren validación del Domain Expert o SME regulador antes de BUILD.
---


## Resumen

**20 fórmulas** + **28 validaciones** extraídas del código de `bdisolic`. Reguladores con reglas: CNBV.

## Fórmulas de negocio (evidencia directa del código)

| ID | SP · línea | Regulador | Fórmula | Riesgo equivalencia |
|----|-----------|-----------|---------|---------------------|
| BR-IFX-1215 | `determina_lincred_tc_cjunk` L841 | operacional | `v_compteorico = (v_lintienda * .10)` | |
| BR-IFX-1216 | `determina_lincred_tc_cjunk` L952 | operacional | `v_ingreso = round(v_salariomin * v_diaspromedio,-2)` | ⚠ ROUND — validar modo de redondeo (banker's vs half-up) |
| BR-IFX-1217 | `determina_lincred_tc_cjunk` L1063 | operacional | `v_tope_ingreso = round(v_salariomin * v_diaspromedio * v_tope_ingre,-2` | ⚠ ROUND — validar modo de redondeo (banker's vs half-up) |
| BR-IFX-1218 | `determina_lincred_tc_cjunk` L1148 | CNBV | `v_tasa = (v_tasa) + (v_tasa * vlIVA); -- RQM 10 1224` | |
| BR-IFX-1219 | `determina_lincred_tc_cjunk` L1152 | operacional | `iISM = v_ingreso / (v_salariomin * v_diaspromedio)` | |
| BR-IFX-1220 | `determina_lincred_tc_cjunk` L1334 | operacional | `vlMontoHipoteca = v_ingreso * (dMinPorcHipo / 100) ` | |
| BR-IFX-1221 | `determina_lincred_tc_cjunk` L1335 | operacional | `vlMontoHipoteca2 = v_ingreso * (dMinPorcHipo / 100)` | |
| BR-IFX-1222 | `determina_lincred_tc_cjunk` L1344 | operacional | `vlMontoHipoteca = v_ingreso * (dMaxPorcHipo / 100) ` | |
| BR-IFX-1223 | `determina_lincred_tc_cjunk` L1345 | operacional | `vlMontoHipoteca2 = v_ingreso * (dMaxPorcHipo / 100) ` | |
| BR-IFX-1224 | `determina_lincred_tc_cjunk` L1531 | CNBV | `v_tasaMens = v_tasasiniva / 12` | |
| BR-IFX-1225 | `determina_lincred_tc_cjunk` L1534 | CNBV | `v_factor_vp = 1*(1-(POW(ROUND(((v_tasa/100)/12)+1,10),(v_iplazomax*-1)` | ⚠ ROUND — validar modo de redondeo (banker's vs half-up) |
| BR-IFX-1226 | `determina_lincred_tc_cjunk` L1536 | operacional | `v_lineasinTopes = (v_capacidad * v_factor_vp)` | |
| BR-IFX-1227 | `determina_lincred_tc_cjunk` L1598 | CNBV | `dCRA = v_capacidad ; LET v_tasaMens = v_tasasiniva / 12 ; --JMAH RQM 0` | |
| BR-IFX-1228 | `determina_lincred_tc_cjunk` L1599 | CNBV | `v_factor_calc = POW(ROUND(((v_tasa/100)/v_plazo)+1,10),(v_iplazomax*-1` | ⚠ ROUND — validar modo de redondeo (banker's vs half-up) |
| BR-IFX-1229 | `determina_lincred_tc_cjunk` L1601 | CNBV | `v_factor_vp = v_factor_calc / ((v_tasa/100)/v_plazo); --CONSERVAR EL C` | |
| BR-IFX-1230 | `determina_lincred_tc_cjunk` L1602 | CNBV | `v_linea = (v_capacidad * v_factor_calc) / ((v_tasa/100)/v_plazo); --CO` | |
| BR-IFX-1231 | `determina_lincred_tc_cjunk` L1606 | CNBV | `v_tasaMens = v_tasasiniva / v_plazo ; --CONSERVAR EL CALCULO A 12 como` | |
| BR-IFX-1232 | `determina_lincred_tc_cjunk` L1722 | operacional | `dMontoDecr = v_lineaMod * -1` | |
| BR-IFX-1244 | `sp_calcularsaldopromedio` L173 | operacional | `mMonto = mMonto/ dmesprom; --FMV 24abr13: Se parametriza el promedio` | |
| BR-IFX-1245 | `sp_calcularsaldopromedio` L187 | operacional | `mMontoMaxSolicitado = mMonto * dMeses` | |

## Reglas por regulador (SME dueño)

- **CNBV** (`SME/Regulatory/CNBV/`) — 22 reglas · Buró de Crédito — evaluación crediticia (LRSIC)

## `[RIESGO-EQUIVALENCIA]` en este dominio

Semántica Informix que debe preservarse exacta en el target (golden master ≥ 99.95%):
- **TRUNC vs ROUND** · **base 360 vs 365** · **tipo MONEY (banker's rounding)** — divergencia auditable.

## `[SME-PENDING]` Validación regulatoria

- [ ] Cada fórmula → validar con el SME regulador dueño (ver `regulatory-validation-packets-lgc.md`).
- [ ] Confirmar parámetros: tasas, bases de cálculo (360/365), plazos.
- [ ] Definir golden master test por fórmula.

---
*Generado por update-knowledge-base.py · Etapa 3 · fuente: business-rules.json*
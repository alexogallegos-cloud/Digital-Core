# D08 · SPEI — Reglas de Negocio y Fórmulas

> **Componente:** LegacyCore · SPE-AM-001 · **Etapa 3 — Business Logic Extraction**
> **Base de datos:** `bdispei` · IBM Informix IDS 14.10 FC10W2 / POWER-AIX
> **Wave de migración:** Wave 2 · Riesgo: **CRÍTICO**
> **Última actualización:** 2026-07-04 · *generado del análisis del código (reemplaza plantilla)*

---
**SME responsable:**
- Specialist — Informix SPL Analysis (análisis estático, extracción de reglas)
- Domain Expert — LegacyCore (validación funcional de negocio)
- **SME — Modelo Operativo Bancario** (BIAN Service Domains · capacidades retail banking · cadena de valor · mapeo dominio técnico ↔ capacidad de negocio)
- Data Architect (modelado target PostgreSQL / Aurora)
- QA Lead — Equivalencia Funcional (golden master y criterios go/no-go)
- **SME Regulatorio — Banxico** (`Solutioning/Delivery - SME/Regulatory/Banxico/`)

> Secciones marcadas `[SME-PENDING]` requieren validación del Domain Expert o SME regulador antes de BUILD.
---


## Resumen

**20 fórmulas** + **25 validaciones** extraídas del código de `bdispei`. Reguladores con reglas: Banxico, CNBV, CONDUSEF.

## Fórmulas de negocio (evidencia directa del código)

| ID | SP · línea | Regulador | Fórmula | Riesgo equivalencia |
|----|-----------|-----------|---------|---------------------|
| BR-IFX-1253 | `sp_alertasabonospei` L67 | CNBV · Banxico | `vsql = 'echo "LOAD FROM /resplogifx/conciliachq/ordenes_abono_spei.txt` | |
| BR-IFX-1254 | `sp_alertasabonospei` L70 | CNBV · Banxico | `vstmt = '/ifxsif01/bin/dbaccess bdispei /resplogifx/conciliachq/abonos` | |
| BR-IFX-1255 | `sp_alertasabonosspei` L67 | CNBV · Banxico | `vsql = 'echo "LOAD FROM /resplogifx/conciliachq/ordenes_abono_spei.txt` | |
| BR-IFX-1256 | `sp_alertasabonosspei` L70 | CNBV · Banxico | `vstmt = '/ifxsif01/bin/dbaccess bdispei /resplogifx/conciliachq/abonos` | |
| BR-IFX-1257 | `sp_calc_com` L52 | CONDUSEF | `v_ivacom = v_comision * v_iva` | |
| BR-IFX-1260 | `sp_calc_comasiva` L145 | CONDUSEF | `vIvacom = vComision * vIva` | |
| BR-IFX-1261 | `sp_calc_comasiva` L236 | CONDUSEF | `vcomision = (vcomision * vPrjExclusionCtaNom) / 100` | |
| BR-IFX-1262 | `sp_calc_comasiva` L237 | CONDUSEF | `vivacom = (vcomision * vIva * vPrjExclusionCtaNom) /100` | |
| BR-IFX-1263 | `sp_calc_comasiva` L270 | operacional | `vDesErr = "Numero de Cuenta/Tarjeta no registrado o la Tarjeta no encu` | |
| BR-IFX-1267 | `sp_calc_comasiva_web` L126 | CONDUSEF | `vIvacom = vComision * vIva` | |
| BR-IFX-1268 | `sp_calc_comasiva_web` L216 | CONDUSEF | `vcomision = (vcomision * vPrjExclusionCtaNom) / 100` | |
| BR-IFX-1269 | `sp_calc_comasiva_web` L217 | CONDUSEF | `vivacom = (vcomision * vIva * vPrjExclusionCtaNom) /100` | |
| BR-IFX-1270 | `sp_calc_comasiva_web` L250 | operacional | `vDesErr = "Numero de Cuenta/Tarjeta no registrado o la Tarjeta no encu` | |
| BR-IFX-1277 | `sp_regordenctecte_bex_codi` L259 | Banxico | `intBancoOrd = (vchrparametro * 1)` | |
| BR-IFX-1281 | `sp_regordenctecte_bex_codi_exp1` L260 | Banxico | `intBancoOrd = (vchrparametro * 1)` | |
| BR-IFX-1285 | `spei_calculointeres` L112 | CNBV · Banxico | `vMontoPgo = ROUND((((cTsaPond * vImporte) * vDifmins ) / 518400),2)` | ⚠ ROUND — validar modo de redondeo (banker's vs half-up) |
| BR-IFX-1288 | `spei_calculointeres_pba` L112 | CNBV · Banxico | `vMontoPgo = ROUND((((cTsaPond * vImporte) * vDifmins ) / 518400),2)` | ⚠ ROUND — validar modo de redondeo (banker's vs half-up) |
| BR-IFX-1291 | `spei_devcodi` L571 | Banxico · Banxico | `intBancoOrd = (vchrparametro * 1)` | |
| BR-IFX-1296 | `spei_recordenpago` L602 | Banxico | `vmonto_udi = pmnyimporte / vprecio_udi` | |
| BR-IFX-1297 | `spei_recordenpago_ws` L1133 | Banxico | `vmonto_udi = pmnyimporte / vprecio_udi` | |

## Reglas por regulador (SME dueño)

- **CNBV** (`Solutioning/Delivery - SME/Regulatory/CNBV/`) — 10 reglas · Criterios contables CNBV + GAT — cálculo de intereses/rendimientos
- **Banxico** (`Solutioning/Delivery - SME/Regulatory/Banxico/`) — 30 reglas · Circular 3/2012 SPEI — irrevocabilidad, clave de rastreo
- **CONDUSEF** (`Solutioning/Delivery - SME/Regulatory/CONDUSEF/`) — 10 reglas · LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada

## `[RIESGO-EQUIVALENCIA]` en este dominio

Semántica Informix que debe preservarse exacta en el target (golden master ≥ 99.95%):
- **TRUNC vs ROUND** · **base 360 vs 365** · **tipo MONEY (banker's rounding)** — divergencia auditable.

## `[SME-PENDING]` Validación regulatoria

- [ ] Cada fórmula → validar con el SME regulador dueño (ver `regulatory-validation-packets-lgc.md`).
- [ ] Confirmar parámetros: tasas, bases de cálculo (360/365), plazos.
- [ ] Definir golden master test por fórmula.

---
*Generado por update-knowledge-base.py · Etapa 3 · fuente: business-rules.json*
# D05 · Saldos y Cuentas — Reglas de Negocio y Fórmulas

> **Componente:** BCOPCore · SPE-AM-001 · **Etapa 3 — Business Logic Extraction**
> **Base de datos:** `bdisac` · IBM Informix IDS 14.10 FC10W2 / POWER-AIX
> **Wave de migración:** Wave 3 · Riesgo: **ALTO**
> **Última actualización:** 2026-07-04 · *generado del análisis del código (reemplaza plantilla)*

---
**SME responsable:**
- Specialist — Informix SPL Analysis (análisis estático, extracción de reglas)
- Domain Expert — BanCoppel (validación funcional de negocio)
- **SME — Modelo Operativo Bancario** (BIAN Service Domains · capacidades retail banking · cadena de valor · mapeo dominio técnico ↔ capacidad de negocio)
- Data Architect (modelado target PostgreSQL / Aurora)
- QA Lead — Equivalencia Funcional (golden master y criterios go/no-go)
- **SME Regulatorio — CNBV** (`SME/Regulatory/CNBV/`)
- **SME Regulatorio — IPAB** (`SME/Regulatory/IPAB/`)
- **SME Regulatorio — SAT** (`SME/Regulatory/SAT/`)

> Secciones marcadas `[SME-PENDING]` requieren validación del Domain Expert o SME regulador antes de BUILD.
---


## Resumen

**25 fórmulas** + **66 validaciones** extraídas del código de `bdisac`. Reguladores con reglas: CONDUSEF, SAT.

## Fórmulas de negocio (evidencia directa del código)

| ID | SP · línea | Regulador | Fórmula | Riesgo equivalencia |
|----|-----------|-----------|---------|---------------------|
| BR-IFX-1123 | `sp_app_valdigito` L55 | operacional | `iValor1 = iValor1 * 2` | |
| BR-IFX-1124 | `sp_app_valdigito` L63 | operacional | `iValor4 = iValor3 * '9'` | |
| BR-IFX-1131 | `sp_calcula_comisiones` L53 | SAT · CONDUSEF | `vIvaTotalconvenio = vimpcomconvenio * (vIvaConvenio/100); --- Se calcu` | |
| BR-IFX-1132 | `sp_calcula_comisiones` L61 | SAT · CONDUSEF | `vIvaTotalComcte = vimpcomcte * (vIvaComcte/100) ; --- Se calcula el IV` | |
| BR-IFX-1133 | `sp_calcula_comisiones_pba` L105 | SAT · CONDUSEF | `vIVAimpconvenio = vimpcomconvenio * (vIva_convenio/100); /*calculo iva` | |
| BR-IFX-1134 | `sp_calcula_comisiones_pba` L106 | SAT · CONDUSEF | `vIVAimpcomcte = vimpcomcte * (vIva_convenio/100); /*calculo iva de cli` | |
| BR-IFX-1136 | `sp_calculadvarabela` L60 | operacional | `iAux = iValorDigito * iNoPeso` | |
| BR-IFX-1140 | `sp_calculadvdish` L87 | operacional | `iAux = iValorDigito * iNoPeso` | |
| BR-IFX-1144 | `sp_calculadveci` L59 | operacional | `iAux = iValorDigito * iNoPeso` | |
| BR-IFX-1151 | `sp_calculadvtelmex` L50 | operacional | `iContador = substr(NumTel,1,1)::int * 1` | |
| BR-IFX-1152 | `sp_calculadvtelmex` L51 | operacional | `iContador = iContador + substr(NumTel,2,1)::int * 3` | |
| BR-IFX-1153 | `sp_calculadvtelmex` L59 | operacional | `iContador = iContador + substr(NumTel,10,1)::int * 1` | |
| BR-IFX-1160 | `sp_dinya_calcularcomisioniva` L92 | CONDUSEF | `mTotComision = pImporte * (mValorComision/100)` | |
| BR-IFX-1161 | `sp_dinya_calcularcomisioniva` L109 | CONDUSEF | `mTotIVA = mValorComision * mValorIVACiudad` | |
| BR-IFX-1162 | `sp_dinya_calcularcomisioniva` L111 | CONDUSEF | `mTotIVA = mTotComision * mValorIVACiudad` | |
| BR-IFX-1166 | `sp_dinya_calcularcomisioniva_bei` L64 | CONDUSEF | `mIva = mIva/100` | |
| BR-IFX-1167 | `sp_dinya_calcularcomisioniva_bei` L90 | CONDUSEF | `mIva = mComision * (mIva/100)` | |
| BR-IFX-1171 | `sp_dinya_calcularcomisioniva_bpi` L60 | CONDUSEF | `mComision = mComision/100` | |
| BR-IFX-1172 | `sp_dinya_calcularcomisioniva_bpi` L63 | CONDUSEF | `mIva = mIva/100` | |
| BR-IFX-1173 | `sp_dinya_calcularcomisioniva_bpi` L91 | CONDUSEF | `mComision = pMonto * (mComision/100)` | |
| BR-IFX-1174 | `sp_dinya_calcularcomisioniva_bpi` L94 | CONDUSEF | `mIva = mComision * (mIva/100)` | |
| BR-IFX-1178 | `sp_dinya_calcularcomisioniva_pba` L92 | CONDUSEF | `mTotComision = pImporte * (mValorComision/100)` | |
| BR-IFX-1179 | `sp_dinya_calcularcomisioniva_pba` L106 | CONDUSEF | `mTotIVA = mTotComision * (mValorIVACiudad)` | |
| BR-IFX-1186 | `sp_reporteremesascomision` L362 | CONDUSEF | `cSQL = 'echo "UNLOAD TO ' // TRIM(cRuta) // TRIM(cNombreArchivo) // ' ` | |
| BR-IFX-1188 | `sp_reporteremesascomision_pbajj` L334 | CONDUSEF | `cSQL = 'echo "UNLOAD TO ' // TRIM(cRuta) // TRIM(cNombreArchivo) // ' ` | |

## Reglas por regulador (SME dueño)

- **CONDUSEF** (`SME/Regulatory/CONDUSEF/`) — 34 reglas · LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada
- **SAT** (`SME/Regulatory/SAT/`) — 4 reglas · LIVA — IVA sobre comisiones (16% / 8% frontera)

## `[SME-PENDING]` Validación regulatoria

- [ ] Cada fórmula → validar con el SME regulador dueño (ver `regulatory-validation-packets-bcop.md`).
- [ ] Confirmar parámetros: tasas, bases de cálculo (360/365), plazos.
- [ ] Definir golden master test por fórmula.

---
*Generado por update-knowledge-base.py · Etapa 3 · fuente: business-rules.json*
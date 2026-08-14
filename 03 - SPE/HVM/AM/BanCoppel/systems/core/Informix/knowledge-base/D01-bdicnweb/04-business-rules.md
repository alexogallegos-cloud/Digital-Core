# D01 · Canal Digital Web — Reglas de Negocio y Fórmulas

> **Componente:** Informix · SPE-AM-001 · **Etapa 3 — Business Logic Extraction**
> **Base de datos:** `bdicnweb` · IBM Informix IDS 14.10 FC10W2 / POWER-AIX
> **Wave de migración:** Wave 6 · Riesgo: **ALTO**
> **Última actualización:** 2026-07-04 · *generado del análisis del código (reemplaza plantilla)*

---
**SME responsable:**
- Specialist — Informix SPL Analysis (análisis estático, extracción de reglas)
- Domain Expert — BanCoppel (validación funcional de negocio)
- **SME — Modelo Operativo Bancario** (BIAN Service Domains · capacidades retail banking · cadena de valor · mapeo dominio técnico ↔ capacidad de negocio)
- Data Architect (modelado target PostgreSQL / Aurora)
- QA Lead — Equivalencia Funcional (golden master y criterios go/no-go)


> Secciones marcadas `[SME-PENDING]` requieren validación del Domain Expert o SME regulador antes de BUILD.
---


## Resumen

**11 fórmulas** + **254 validaciones** extraídas del código de `bdicnweb`. Reguladores con reglas: CNBV, CONDUSEF, IPAB, SAT, TESOFE.

## Fórmulas de negocio (evidencia directa del código)

| ID | SP · línea | Regulador | Fórmula | Riesgo equivalencia |
|----|-----------|-----------|---------|---------------------|
| BR-IFX-311 | `sp_adminitasas_cargarchivo` L336 | CNBV | `cMensaje = 'EL CAMPO [TASA] SE ENCUENTRA VACÃO/SIN INFORMACION'` | |
| BR-IFX-312 | `sp_adminitasas_cargarchivo` L346 | CNBV | `cMensaje = 'EL CAMPO [CAPITAL MÃNIMO] SE ENCUENTRA VACÃO/SIN INFORMA` | |
| BR-IFX-313 | `sp_adminitasas_cargarchivo` L368 | CNBV | `cMensaje = 'EL CAMPO [CAPITAL MÃXIMO] SE ENCUENTRA VACÃO/SIN INFORMA` | |
| BR-IFX-329 | `sp_admintasas_consultapagare` L335 | CNBV | `cInstrumentoApertura = 'REINVERSION CAPITAL / DEPOSITO INTERESES A CTA` | |
| BR-IFX-385 | `sp_cb_genrepcuentasatraspasar` L255 | CNBV | `vIsrCalc = (vBase_gravable * (dPorRetSuj/100)) * iDias / iAniobase` | |
| BR-IFX-386 | `sp_cb_genrepcuentasatraspasar` L260 | CNBV | `vIsrCalc = (dsdocon * (dPorRetSuj/100)) * iDias / iAniobase` | |
| BR-IFX-387 | `sp_cb_genrepcuentasatraspasar` L296 | CNBV | `cCmd1 = ""//TRIM(cCmd1)//" SELECT num_cte::CHAR(20), num_cta::CHAR(20)` | |
| BR-IFX-521 | `sp_ipab_repfideicomisomarcajeipab` L84 | CONDUSEF · IPAB | `cCmd1 = ""//TRIM(cCmd1)//" UNION ALL SELECT * FROM (SELECT f.no_fideic` | |
| BR-IFX-552 | `sp_repctasinactivasart61` L572 | CNBV | `cCmd1 = "SELECT 'FECHA DE CONSULTA','NUMERO DE CUENTA','PRODUCTO','NUM` | |
| BR-IFX-559 | `sp_reportebloqueoctasmasivocre` L93 | operacional | `cCmd3 = "lote, trim(numcte), trim(nombre_cliente), trim(num_credito), ` | |
| BR-IFX-563 | `sp_reportedesbloqueoctasmasivocre` L97 | operacional | `cCmd3 = "lote, trim(numcte), trim(nombre_cliente), trim(num_credito), ` | |

## Reglas por regulador (SME dueño)

- **CNBV** (`SME/Regulatory/CNBV/`) — 138 reglas · Criterios contables CNBV + GAT — cálculo de intereses/rendimientos
- **CONDUSEF** (`SME/Regulatory/CONDUSEF/`) — 27 reglas · LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada
- **SAT** (`SME/Regulatory/SAT/`) — 18 reglas · LIVA — IVA sobre comisiones (16% / 8% frontera)
- **TESOFE** (`SME/Regulatory/TESOFE/`) — 3 reglas · LTF — dispersión de recursos federales
- **IPAB** (`SME/Regulatory/IPAB/`) — 9 reglas · LPAB Art.22 — cuota ordinaria 4 al millar sobre pasivos asegurados

## `[SME-PENDING]` Validación regulatoria

- [ ] Cada fórmula → validar con el SME regulador dueño (ver `regulatory-validation-packets-bcop.md`).
- [ ] Confirmar parámetros: tasas, bases de cálculo (360/365), plazos.
- [ ] Definir golden master test por fórmula.

---
*Generado por update-knowledge-base.py · Etapa 3 · fuente: business-rules.json*
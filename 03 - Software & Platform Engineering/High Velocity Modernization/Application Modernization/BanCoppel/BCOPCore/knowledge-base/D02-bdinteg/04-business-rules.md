# D02 · Integración y Auth — Reglas de Negocio y Fórmulas

> **Componente:** BCOPCore · SPE-AM-001 · **Etapa 3 — Business Logic Extraction**
> **Base de datos:** `bdinteg` · IBM Informix IDS 14.10 FC10W2 / POWER-AIX
> **Wave de migración:** Wave 5 · Riesgo: **CRÍTICO**
> **Última actualización:** 2026-07-04 · *generado del análisis del código (reemplaza plantilla)*

---
**SME responsable:**
- Specialist — Informix SPL Analysis (análisis estático, extracción de reglas)
- Domain Expert — BanCoppel (validación funcional de negocio)
- **SME — Modelo Operativo Bancario** (BIAN Service Domains · capacidades retail banking · cadena de valor · mapeo dominio técnico ↔ capacidad de negocio)
- Data Architect (modelado target PostgreSQL / Aurora)
- QA Lead — Equivalencia Funcional (golden master y criterios go/no-go)
- **SME Regulatorio — CNBV** (`SME/Regulatory/CNBV/`)

> Secciones marcadas `[SME-PENDING]` requieren validación del Domain Expert o SME regulador antes de BUILD.
---


## Resumen

**2 fórmulas** + **71 validaciones** extraídas del código de `bdinteg`. Reguladores con reglas: CNBV, CONDUSEF, TESOFE.

## Fórmulas de negocio (evidencia directa del código)

| ID | SP · línea | Regulador | Fórmula | Riesgo equivalencia |
|----|-----------|-----------|---------|---------------------|
| BR-IFX-1007 | `sp_comisionreposicion` L64 | CONDUSEF | `mIva = mComision * mIva` | |
| BR-IFX-1011 | `sp_comisionreposicion_web` L66 | CONDUSEF | `mIva = mComision * mIva` | |

## Reglas por regulador (SME dueño)

- **CNBV** (`SME/Regulatory/CNBV/`) — 12 reglas · Buró de Crédito — evaluación crediticia (LRSIC)
- **CONDUSEF** (`SME/Regulatory/CONDUSEF/`) — 11 reglas · LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada
- **TESOFE** (`SME/Regulatory/TESOFE/`) — 1 reglas · LTF — dispersión de recursos federales

## `[SME-PENDING]` Validación regulatoria

- [ ] Cada fórmula → validar con el SME regulador dueño (ver `regulatory-validation-packets-bcop.md`).
- [ ] Confirmar parámetros: tasas, bases de cálculo (360/365), plazos.
- [ ] Definir golden master test por fórmula.

---
*Generado por update-knowledge-base.py · Etapa 3 · fuente: business-rules.json*
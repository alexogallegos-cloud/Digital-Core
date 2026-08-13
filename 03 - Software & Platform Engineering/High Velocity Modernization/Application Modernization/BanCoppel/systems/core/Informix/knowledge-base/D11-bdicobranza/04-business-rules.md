# D11 · Cobranza — Reglas de Negocio y Fórmulas

> **Componente:** Informix · SPE-AM-001 · **Etapa 3 — Business Logic Extraction**
> **Base de datos:** `bdicobranza` · IBM Informix IDS 14.10 FC10W2 / POWER-AIX
> **Wave de migración:** Wave 2 · Riesgo: **MEDIO**
> **Última actualización:** 2026-07-04 · *generado del análisis del código (reemplaza plantilla)*

---
**SME responsable:**
- Specialist — Informix SPL Analysis (análisis estático, extracción de reglas)
- Domain Expert — BanCoppel (validación funcional de negocio)
- **SME — Modelo Operativo Bancario** (BIAN Service Domains · capacidades retail banking · cadena de valor · mapeo dominio técnico ↔ capacidad de negocio)
- Data Architect (modelado target PostgreSQL / Aurora)
- QA Lead — Equivalencia Funcional (golden master y criterios go/no-go)
- **SME Regulatorio — CNBV** (`SME/Regulatory/CNBV/`)
- **SME Regulatorio — CONDUSEF** (`SME/Regulatory/CONDUSEF/`)

> Secciones marcadas `[SME-PENDING]` requieren validación del Domain Expert o SME regulador antes de BUILD.
---


## Resumen

**2 fórmulas** + **16 validaciones** extraídas del código de `bdicobranza`. Reguladores con reglas: CNBV.

## Fórmulas de negocio (evidencia directa del código)

| ID | SP · línea | Regulador | Fórmula | Riesgo equivalencia |
|----|-----------|-----------|---------|---------------------|
| BR-IFX-592 | `sp_generafechpagoreestructura_baja` L258 | operacional | `vSdoTotal1 = (NVL(vSdoCap,0) + NVL(vMtoVencido,0) + NVL(vMtoVencTrasp,` | ⚠ ROUND — validar modo de redondeo (banker's vs half-up) |
| BR-IFX-593 | `sp_generafechpagoreestructura_baja` L259 | operacional | `vMtoVencido1 = (NVL(vMtoVencido,0) + NVL(vMtoVencTrasp,0)) + round((NV` | ⚠ ROUND — validar modo de redondeo (banker's vs half-up) |

## Reglas por regulador (SME dueño)

- **CNBV** (`SME/Regulatory/CNBV/`) — 5 reglas · Buró de Crédito — evaluación crediticia (LRSIC)

## `[RIESGO-EQUIVALENCIA]` en este dominio

Semántica Informix que debe preservarse exacta en el target (golden master ≥ 99.95%):
- **TRUNC vs ROUND** · **base 360 vs 365** · **tipo MONEY (banker's rounding)** — divergencia auditable.

## `[SME-PENDING]` Validación regulatoria

- [ ] Cada fórmula → validar con el SME regulador dueño (ver `regulatory-validation-packets-bcop.md`).
- [ ] Confirmar parámetros: tasas, bases de cálculo (360/365), plazos.
- [ ] Definir golden master test por fórmula.

---
*Generado por update-knowledge-base.py · Etapa 3 · fuente: business-rules.json*
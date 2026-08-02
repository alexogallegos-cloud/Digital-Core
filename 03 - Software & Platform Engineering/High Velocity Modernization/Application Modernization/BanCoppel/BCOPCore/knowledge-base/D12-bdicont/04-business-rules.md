# D12 · Contabilidad — Reglas de Negocio y Fórmulas

> **Componente:** BCOPCore · SPE-AM-001 · **Etapa 3 — Business Logic Extraction**
> **Base de datos:** `bdicont` · IBM Informix IDS 14.10 FC10W2 / POWER-AIX
> **Wave de migración:** Wave 4 · Riesgo: **ALTO**
> **Última actualización:** 2026-07-04 · *generado del análisis del código (reemplaza plantilla)*

---
**SME responsable:**
- Specialist — Informix SPL Analysis (análisis estático, extracción de reglas)
- Domain Expert — BanCoppel (validación funcional de negocio)
- **SME — Modelo Operativo Bancario** (BIAN Service Domains · capacidades retail banking · cadena de valor · mapeo dominio técnico ↔ capacidad de negocio)
- Data Architect (modelado target PostgreSQL / Aurora)
- QA Lead — Equivalencia Funcional (golden master y criterios go/no-go)
- **SME Regulatorio — SAT** (`SME/Regulatory/SAT/`)
- **SME Regulatorio — IPAB** (`SME/Regulatory/IPAB/`)
- **SME Regulatorio — CNBV** (`SME/Regulatory/CNBV/`)

> Secciones marcadas `[SME-PENDING]` requieren validación del Domain Expert o SME regulador antes de BUILD.
---


## Resumen

**0 fórmulas** + **16 validaciones** extraídas del código de `bdicont`. Reguladores con reglas: —.

## `[SME-PENDING]` Validación regulatoria

- [ ] Cada fórmula → validar con el SME regulador dueño (ver `regulatory-validation-packets-bcop.md`).
- [ ] Confirmar parámetros: tasas, bases de cálculo (360/365), plazos.
- [ ] Definir golden master test por fórmula.

---
*Generado por update-knowledge-base.py · Etapa 3 · fuente: business-rules.json*
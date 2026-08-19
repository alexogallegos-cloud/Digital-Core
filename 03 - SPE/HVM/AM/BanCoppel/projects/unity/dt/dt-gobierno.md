# DT: Gobernanza del Programa — Unity R4
> **Digital Twin** · Fuente: RAID v2.0 · Minutas R4 · Diagnóstico Kennedy · SME IT Operating Model
> **Versión**: v1.0.0 · 2026-08-16
> **Propósito**: Modelo de gobernanza del programa — quién decide qué, cómo se escala, comités activos, matriz de responsabilidades

---

## Diagnóstico de Base

El diagnóstico Kennedy identificó que el **75% de los problemas del programa son de gobernanza y personas**, no técnicos. Los síntomas concretos:

- Sin sign-off formal de negocio sobre los entregables (RISK-010 abierto, due 2026-09-15)
- Sin RAID formal con owners definidos al inicio del programa
- Roles y responsabilidades con 18% de fricción entre actores
- Roadmap declarado como "wishful thinking" sin capacidad real mapeada

El propósito de este DT es establecer la estructura que resuelve esos síntomas.

---

## Estructura de Gobernanza

```
BanCoppel — Sponsor Ejecutivo
        │
        ▼
BanCoppel PMO (owner del programa)
        │
        ├── Accenture (delivery governance + integración)
        │       ├── Delivery Lead ACN (Karina Zepeda u otro — DATO-REQUERIDO)
        │       └── Componentes: Apificación · Integración · QA
        │
        ├── Appwhere (APOLO + DTMs SmartVista)
        ├── BPC Banking Technologies (SmartVista)
        ├── Proveedor CAT [SIN CONTRATAR 🔴]
        ├── Kreios (implementación / change management)
        └── EY (Temenos Transact R1-R3 — incumbente, no en R4 SmartVista)
```

---

## Comités del Programa

| Comité | Propósito | Frecuencia | Participantes | Owner | Status |
|--------|-----------|-----------|--------------|-------|--------|
| Steering Committee | Decisiones ejecutivas, escalaciones, presupuesto | DATO-REQUERIDO | PMO BanCoppel · Sponsor · ACN Lead · BPC · Appwhere | BanCoppel PMO | DATO-REQUERIDO |
| Program Review | RAID review, avance de componentes, bloqueos activos | Quincenal recomendado | PMO · ACN · todos los vendors | ACN | DATO-REQUERIDO |
| Technical Sync SmartVista | Resolución de tickets BPC, DTMs, integración SVIP | DATO-REQUERIDO | Appwhere · BPC · ACN Tech | DATO-REQUERIDO | DATO-REQUERIDO |
| SIT War Room | Triage de defectos durante SIT oct-dic 2026 | Diario (SIT activo) | ACN · Appwhere · BPC · BanCoppel QA | ACN | No iniciado |
| Go/No-Go Committee | Decisión de go-live enero 2027 | Una vez (dic 2026) | CTO · CFO · CRO · PMO · ACN · CNBV si aplica | BanCoppel CTO | No iniciado |

---

## Matriz de Decisiones (RACI simplificada)

| Tipo de decisión | BanCoppel PMO | ACN | BPC | Appwhere | Vendor CAT |
|-----------------|:---:|:---:|:---:|:---:|:---:|
| Contratar proveedor CAT | **D** | C | — | — | — |
| Contratar módulo DPP (BPC) | **D** | C | C | — | — |
| Aprobar criterios de go-live | **D** | C | C | C | C |
| Escalar ticket ValueEdge (BYU0039) | A | **D** | C | — | — |
| Aprobar cutover a producción | **D** | C | C | C | C |
| Cambiar alcance de una User Story | **D** | C | A | — | — |
| Definir SLOs de producción | A | **D** | C | C | — |
| Aprobar sign-off UAT | **D** | C | C | C | — |
| Definir on-call de producción | A | **D** | — | — | — |

**D** = Decisor · **A** = Aprueba · **C** = Consultar · **—** = No aplica

---

## Riesgo RISK-010 — Sin Sign-Off Formal de Negocio

| Campo | Valor |
|-------|-------|
| ID | RISK-010 |
| Descripción | No existe proceso formal de sign-off de negocio sobre entregables del programa |
| Due date | 2026-09-15 |
| Impacto | Sin sign-off, cualquier defecto post-go-live puede ser atribuido a alcance no validado |
| Acción requerida | Definir artefactos que requieren firma de negocio y quién firma por BanCoppel |
| Owner | DATO-REQUERIDO |

### Artefactos que requieren sign-off formal (propuesta)

| Artefacto | Firmante BanCoppel | Fecha límite |
|-----------|-------------------|-------------|
| Criterios de aceptación por capability (14) | DATO-REQUERIDO | Antes de SIT oct |
| Plan de pruebas SIT/UAT | DATO-REQUERIDO | Sep 2026 |
| Go/No-Go criteria para go-live | CTO | Nov 2026 |
| Runbooks de producción | DATO-REQUERIDO | Dic 2026 |
| Notificación CNBV Art. 76 LIC | Director Regulatorio | Antes go-live |

---

## Acuerdos de Alcance por Actor

### Accenture vs. EY
EY es el implementador incumbente de Temenos Transact (R1-R3). En R4 (SmartVista), el alcance de EY **no aplica**. Sin embargo:
- EY sigue siendo responsable del soporte de Transact durante la transición
- No compartir análisis de arquitectura Accenture con EY (competidor — RAID)
- Validaciones de coexistencia Informix↔Unity van a BanCoppel, no a EY

### Accenture — Alcance R4

| Componente | Rol ACN | Responsabilidad |
|-----------|---------|----------------|
| Apificación | Delivery owner | Middleware de integración canales ↔ SmartVista |
| QA / Testing | Delivery owner | Strategy SIT/UAT, ejecución de pruebas |
| Integración | Delivery owner | APIs, conectores, SVIP |
| APOLO | Governance | Appwhere entrega; ACN revisa y aprueba |
| SmartVista | Governance | BPC/Appwhere entregan; ACN valida DTMs |
| CAT | Governance + Contratación | Urgente — sin vendor aún |

---

## RAID — Owners por Categoría

Todo RAID item debe tener un owner nombrado. Estado actual:

| Categoría | Total items | Con owner asignado | Sin owner |
|-----------|------------|-------------------|-----------|
| Risks | 17 abiertos | DATO-REQUERIDO | DATO-REQUERIDO |
| Assumptions | 4 sin validar | DATO-REQUERIDO | DATO-REQUERIDO |
| Issues | 3 abiertos | DATO-REQUERIDO | DATO-REQUERIDO |
| Dependencies | 2 activas | DATO-REQUERIDO | DATO-REQUERIDO |

> **Acción**: en el próximo Program Review, asignar owner a cada RAID item abierto.

---

## Protocolo de Escalación

```
Nivel 1 — Operativo (resolver en 24h)
  Owner del componente → resolución directa con vendor
  
Nivel 2 — Táctico (resolver en 48h)
  ACN Delivery Lead + PMO BanCoppel → si impacta cronograma o alcance
  
Nivel 3 — Ejecutivo (resolver en 72h)
  Steering Committee → si impacta budget, go-live, o requiere decisión de negocio
  
Nivel 4 — Regulatorio (inmediato)
  CTO + CRO + Director Regulatorio → si involucra CNBV, PCI-DSS o incidente de seguridad
```

---

## Cadencia de Reporting

| Reporte | Destinatario | Frecuencia | Fuente de datos |
|---------|-------------|-----------|-----------------|
| Status del programa (RAG) | Steering Committee | DATO-REQUERIDO | RAID + delivery_state brain |
| RAID delta (cambios de semana) | Program Review | Quincenal | brain::risks + issues |
| Capability coverage | Technical Sync | Quincenal | brain::program_capabilities |
| Vendor scorecard | PMO | Mensual | dt-vendors |
| Go-live readiness % | Go/No-Go Committee | Mensual (Q4) | dt-ops-readiness |

---

## DATO-REQUERIDO — Información crítica faltante

1. Nombre del Sponsor Ejecutivo BanCoppel del programa Unity
2. Nombre del PMO BanCoppel (owner de programa)
3. Nombre del Delivery Lead ACN (¿Karina Zepeda u otro?)
4. Frecuencia y formato del Steering Committee
5. Owner de RISK-010 (sin sign-off formal) en BanCoppel
6. Firmante BanCoppel para cada artefacto que requiere sign-off
7. Owners asignados a cada RAID item abierto
8. Rol exacto de EY en R4 (si alguno)

---

*Creado: 2026-08-16 — Digital Twin Gobernanza Unity R4 v1.0.0*

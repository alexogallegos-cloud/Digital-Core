# BanCoppel — Application Modernization (HVM · Informix SPL Core)
> Proyecto cliente · Application Modernization · High Velocity Modernization · 03 S&PE · Digital Core
> Estado: DISCOVER — Etapa 0 (Setup & Inventory)
> Fecha de inicio: 2026-07-02

---

## Componentes en Scope

| ID | Sistema | Función | Tecnología legacy | Spec | Fase SDLC |
|---|---|---|---|---|---|
| `SPE-AM-001` | Informix Core (BCOPCore) | Core bancario BanCoppel — crédito · captación · pagos · batch · reportería | IBM Informix IDS · SPL (Stored Procedure Language) | [spec-spe-am-bcop-core.md](systems/core/Informix/spec-spe-am-bcop-core.md) | DISCOVER — Etapa 0 |

---

## Naturaleza del Sistema

BanCoppel opera su core bancario bajo el patrón **"base de datos como aplicación"**: no existe capa de negocio separada. Toda la lógica (apertura de cuentas, dispersión de créditos, cálculo de intereses y comisiones, reconciliación, reportería CNBV) vive como **Stored Procedures SPL** dentro del motor IBM Informix IDS. Los canales (banca en línea, cajeros, sucursales, sistemas internos) invocan los SPs directamente via JDBC / ODBC.

```
[Frontend · Canales · Sistemas internos]
        │
        │  JDBC / ODBC  (llamadas directas a SPs)
        ▼
 ┌─ IBM Informix IDS ─────────────────────────────────┐
 │  Stored Procedures (SPL)  ← lógica de negocio      │
 │  Funciones · Triggers                               │
 │  Tablas · Vistas · Secuencias (SERIAL)              │
 └─────────────────────────────────────────────────────┘
```

**Esto NO es un mainframe.** Informix IDS corre sobre servidores Linux / AIX estándar → lifecycle: **Application Modernization** (no Mainframe Modernization). Sin embargo, la criticidad financiera impone umbrales de equivalencia y parallel-run del nivel MM (banca CNBV).

---

## Hipótesis de Estrategia de Modernización (confirmar Etapa 4)

| Fase | Patrón 7R | Descripción |
|---|---|---|
| **A — Encapsulate** | Anti-Corruption Layer + API REST | API facade sobre Informix · Canales dejan de llamar SPs directamente · Informix intacto · 2–4 meses · riesgo bajo |
| **B — Refactor + Replatform** | Strangler-Fig SP por SP | Extraer SPs → Java 21 + Quarkus · Migrar Informix → PostgreSQL / Aurora · Parallel-run por dominio · 12–24 meses |

---

## Etapa 0 — Checklist de Setup & Inventory

### Insumos del cliente

- [ ] **0.1** Código fuente SPL cargado en `systems/core/Informix/source/BCOPCore/`
- [ ] **0.2** Inventario maestro de objetos: SPs · funciones · triggers · tablas · vistas · secuencias (de `sysprocedures`, `systables`, `systriggers`)
- [ ] **0.3** Esquema DDL completo: `CREATE TABLE` · tipos · constraints · índices
- [ ] **0.4** Logs de ejecución (onstat · sysmaster · slow query log ≥ 30 días producción) — para baselining NFR
- [ ] **0.5** SME técnico BanCoppel asignado (DBA Informix + SME de dominio bancario)
- [ ] **0.6** Versión exacta IBM Informix IDS confirmada (IDS 12.10 / 14.x · OS / hardware)
- [ ] **0.7** Descripción de capas que invocan SPs: canales · integraciones · jobs batch · schedulers
- [ ] **0.8** Autorización para extraer datos anonimizados de producción (dataset de regresión)

### Setup Digital Core

- [ ] **0.9** Ambiente de análisis provisionado
- [ ] **0.10** Lead Architect AM designado (Accenture MX)
- [ ] **0.11** Decisión: ¿AM solo o requiere doble handoff con `05 Modern Data Platform` por data migration compleja?

---

## Equipo

| Rol | Nombre | Estado |
|---|---|---|
| Lead Architect (Accenture MX) | Por designar | Pendiente |
| Sponsor Técnico BanCoppel | Por designar | Pendiente |
| SME BanCoppel — Core bancario (dominio) | Por designar | Pendiente |
| SME BanCoppel — DBA Informix | Por designar | Pendiente |
| Program Manager | Por designar | Pendiente |

---

## Dependencias Cross-Offering

| Dependencia | Razón |
|---|---|
| `[DEPENDS-ON: 04 Intelligent Infrastructure]` | LZ + cluster + observability obligatorio antes de RELEASE |
| `[DEPENDS-ON: 05 Modern Data Platform]` | Data migration Informix → PostgreSQL/Aurora es no trivial por tipos propietarios y volumen bancario |
| `[HANDOFF: 07 AMS Reinvention]` | Coexistencia Informix + nuevo durante ventana de migración requiere modelo AMS doble |
| `[BLOCKED-BY: 01 TS&T]` | Target architecture cloud-native (runtime + data platform + ACL design) requiere endorsement |

---

## Notas de Clasificación del Caso

**¿Por qué Application Modernization y no Mainframe Modernization?**

| Criterio | Informix / BanCoppel | Mainframe (Banamex S500) |
|---|---|---|
| Plataforma | Servidor Linux / AIX estándar | Unisys ClearPath MCP (mainframe propietario) |
| Lenguaje de lógica | SPL (SQL procedural) | COBOL · ALGOL · WFL |
| Base de datos | Relacional (Informix IDS) | DMSII (jerárquico propietario) |
| Lifecycle | **Application Modernization** | Mainframe Modernization |
| Metodología RE | ETAPAs 0–4 adaptadas a objetos SQL | ETAPAs 0–4 nativas para COBOL / DMSII |
| Equivalencia mínima | 99.99% recomendado (banca CNBV, aunque DoD-SPE-AM-01 es 99.95%) | 99.99% obligatorio (DoD-SPE-MM-01) |
| Parallel-run mínimo | 3 meses recomendado (banca CNBV, aunque DoD-SPE-AM-02 es 2 sprints) | 3 meses obligatorio |

---

*Última actualización: 2026-07-02 · v0.1 · Creación inicial — DISCOVER Etapa 0.*
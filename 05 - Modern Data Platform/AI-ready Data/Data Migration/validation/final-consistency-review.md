# Revisión Final de Consistencia — Caso Data Migration (SAP Core Banking + CRM → BigQuery)

> Validación holística del caso completo: modelo a escala (~1,542 tablas) · data seed banking+CRM (con filas) · Fase 1 Discover (2 vistas) · Fase 2 Target & Contracts · reference-solution-dbt · sitio publicado.
> **Co-validadores:** SME `SAP Banking Services` (fidelidad SAP) + SME `Data Governance & Stewardship` (gobierno de datos).
> Fecha: 2026-06-01.

## Veredicto consolidado

**`APROBADO para uso interno / showcase de capacidad`**, con acciones de gobierno nominadas abajo (no bloquean el showcase con datos de referencia; se cerrarían en un engagement real con cliente). Material de referencia, sin IP/PII de cliente.

---

## A. Consistencia técnica (SME SAP Banking Services)

| # | Punto | Resultado |
|---|-------|-----------|
| A1 | Entity resolution: el `norm_name` (sufijos legales) coincide entre el profiler de Fase 1 y la macro dbt → **ADR-003 honrado de forma consistente** | ✅ |
| A2 | Conversión de montos (CURR/TCURX) coherente en data seed, scale y contratos (JPY/CLP = 0 decimales; nunca /100 fijo) | ✅ |
| A3 | Hubs reales y semántica de FK consistentes (BUKRS→T001, WAERS→TCURC/TCURX, PARTNER→BUT000, SAKNR→SKA1) en modelo a escala y DDL | ✅ |
| A4 | Nombres de tabla: el **modelo a escala** usa nombres SAP reales (BKK40/BKKIT/VDARL/BSEG/...); el **data seed con filas** usa un account master simplificado `BKK_ACCT` (anotado y visible) | ✅ `[RESUELTO A4]` |
| A5 | Contratos ↔ medallion ↔ disposiciones de Fase 1: alineados (customer=Master, transaction=Conform+TCURX, etc.) | ✅ |

`[RESUELTO A4]` (2026-06-01, decisión del usuario: documentar). El `BKK_ACCT` del data seed con filas es una **simplificación didáctica intencional** (un solo account master para ejercitar DQ/entity-resolution a nivel fila); en SAP real la cuenta se reparte en la familia BKK* (BKK40 balances, BKKIT turnovers). Se decidió **no inventar un nombre real equivocado** (el SME advirtió que llamar account master a BKK40 sería su propia imprecisión). Acción tomada: **nota de modelado explícita y visible** en el inventario del profiler, en `discovery-assessment.html` (data view) y en la página publicada `discovery-data.html`, aclarando que el modelo a escala sí usa los nombres SAP reales. **Owner: SAP Banking Services. Cerrado.**

---

## B. Consistencia de gobierno (SME Data Governance & Stewardship)

| # | Punto | Resultado |
|---|-------|-----------|
| B1 | Los 5 data contracts tienen estructura completa (schema·SLA·DQ·lineage·consumers·PII) | ✅ |
| B2 | **Owners son roles, no personas nombradas** ("Data Steward - Customer", ...) | `[GAP B2]` |
| B3 | **MDM survivorship** = keep-first (simplista); falta regla de supervivencia real (recencia/fuente autoritativa por campo) + gobierno del crosswalk | `[GAP B3]` (extiende ADR-003) |
| B4 | **Catálogo + lineage tool** no seleccionado (DataHub/Collibra/Purview) | `[GAP B4]` |
| B5 | **Clasificación PII** pendiente (declarada en customer/ADR-004 pero no ejecutada) | `[GAP B5]` → Cybersecurity Data Security |
| B6 | **Retención** definida en customer (CNBV 10a/LFPDPPP); falta extenderla explícitamente a los 5 dominios | `[OBSERVACIÓN B6]` |
| B7 | Proceso de cambio de schema/contract (versionado + ventana de migración) | `[GAP B7]` definir |

Los `[GAP]` de gobierno son **acciones de un engagement real con cliente** (nombrar stewards, elegir catálogo, clasificar PII). Para el showcase con datos de referencia no son bloqueantes, pero deben figurar como backlog de gobierno.

---

## C. ¿Faltan otros SMEs? (recomendación)

| SME | ¿Participa? | Rol |
|-----|-------------|-----|
| **SAP Banking Services** | ✅ ya | Fidelidad del modelo SAP |
| **Data Governance & Stewardship** | ✅ **creado hoy** | Gobierno: contracts, stewardship, MDM, lineage, PII/retención (co-validador) |
| **Cybersecurity Data Security** | ⊕ recomendado | Implementación de clasificación PII + RLS/CLS/cifrado (Fase 7); cierra `[GAP B5]` |
| **Industry BIAN** | ⊕ opcional | Glosario de negocio + mapeo de dominios bancarios a Service Domains canónicos (enriquece contracts de Fase 2) |
| **SPEI / Industry** | ⊕ situacional | Si entran pagos SPEI/CoDi en alcance |

Decisión: **Data Governance entra como co-validador permanente** del caso. Cybersecurity Data Security e Industry BIAN se invocan en sus fases (7 y 2 respectivamente) — no se crean ahora para no inflar el alcance.

---

## D. Sitio publicado

| Punto | Resultado |
|-------|-----------|
| Deliverables publicados (discovery x2, graph, target-design, sign-off) consistentes con los artefactos fuente | ✅ |
| Cero "sintético" / cero IP de cliente; enmarcado como dato de referencia validado por SME | ✅ |
| Acceso público alineado al `[CRÍTICO]` del sitio (solo sin IP de cliente) | ✅ |

---

## Acciones nominadas (backlog de cierre)

| ID | Acción | Owner | Bloqueante |
|----|--------|-------|------------|
| A4 | ✓ **CERRADO** — nota de modelado anotada y visible (profiler + discovery-data publicado) | SAP Banking Services | — |
| B2 | Nombrar Data Owners/Stewards reales por dominio | Cliente / Program (en engagement) | No (showcase) |
| B3 | Definir reglas de survivorship MDM + gobierno del crosswalk | Data Governance (extiende ADR-003) | No |
| B4 | Seleccionar catálogo + lineage (DataHub/Collibra/Purview) | Data Governance + TS&T | No |
| B5 | Clasificación PII + RLS/CLS | Cybersecurity Data Security | No (showcase) |
| B6/B7 | Extender retención a 5 dominios + proceso de cambio de contract | Data Governance | No |

---
*Co-firmado: SME SAP Banking Services (fidelidad) + SME Data Governance & Stewardship (gobierno). Caso APROBADO para uso interno / showcase.*
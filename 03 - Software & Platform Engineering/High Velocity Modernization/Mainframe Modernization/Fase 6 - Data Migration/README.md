# Fase 6 — Data Migration
> Carpeta-puntero · Mainframe Modernization · HVM · 03 S&PE

```
┌─ CARPETA-PUNTERO ──────────────────────────────────────────┐
│ Esta fase NO tiene specialist local en Digital Core.        │
│ La ejecuta el SME externo indicado abajo.                   │
└─────────────────────────────────────────────────────────────┘
```

## Quién ejecuta esta fase

**SME ejecutor:** `Solutioning/Delivery - SME/Technology/Data & ML/Specialist - Legacy Datastore Migration/`

## Objetivo de la fase

Diseñar y ejecutar la migración del datastore legacy (DMSII para Unisys · DB2/VSAM para z/OS · DB400 para IBM i) al datastore objetivo del sistema moderno, garantizando:
- Integridad referencial completa
- Semántica preservada (Sets/Subsets DMSII → relacional)
- CDC durante la ventana de coexistencia (datos fluyen en ambas direcciones)
- Reversibilidad: sync reverso para rollback al legacy

## Prerequisitos de entrada

- `[ARTEFACTO]` Data Dictionary v1.0 (Etapa 2 del RE) — campos y tipos completos
- `[ARTEFACTO]` ERD Lógico (Etapa 2 del RE) — relaciones entre entidades
- `[ARTEFACTO]` Data Lineage Map v1.0 (Etapa 2 del RE) — quién lee/escribe qué
- ADR-SPE-MM-004: Data sync strategy (aprobado en DESIGN)
- Acceso al sistema legacy con permisos de lectura sobre DMSII / VSAM
- Target datastore provisionado (PostgreSQL / Aurora / Oracle) en el ambiente objetivo

## Contexto Unisys ClearPath MCP — DMSII

**`[CRÍTICO]` DMSII no es SQL.** Sus Sets y Subsets tienen semántica propia que no mapea directamente:

| Concepto DMSII | Equivalente relacional | Consideración |
|---|---|---|
| **RECORD** | Tabla / entidad | Mapeo 1:1 generalmente |
| **SET** | Índice / FK relationship | Semántica de ORDER BY implícita — no asumirla como índice simple |
| **SUBSET** | Vista (VIEW) filtrada | `WHERE` clause exacta debe reproducirse |
| **MEMBERSHIP AUTOMATIC** | INSERT con FK automático | La lógica de inserción debe replicarse en la aplicación moderna |
| **MEMBERSHIP MANDATORY** | NOT NULL FK + constraint | El registro hijo no puede existir sin el padre |
| **POPULATION** | Sizing de disco / RRDS | Afecta rendimiento; hardcodes en P104 son este parámetro |

`[CONSULTAR→UNISYS]` Validar semántica de cada Set/Subset con el SME Unisys antes de definir el DDL del target. Una interpretación incorrecta del ordering de un Set puede producir resultados distintos en queries que el sistema moderno asume como ordenados.

## Outputs canónicos

| Artefacto | Descripción |
|---|---|
| `data-migration-design-{sistema}.md` | Estrategia: bulk + CDC · tablas de origen → destino · decisiones de schema |
| `ddl-target-{sistema}.sql` | DDL del datastore objetivo con constraints, índices y comentarios de trazabilidad al DASDL |
| `mapping-dasdl-to-sql-{sistema}.md` | Mapeo campo a campo DASDL → DDL: tipo DMSII → tipo SQL + notas de conversión |
| `cdc-design-{sistema}.md` | Diseño del Change Data Capture durante coexistencia: herramienta, latencia, manejo de conflictos |
| `rollback-sync-plan-{sistema}.md` | Plan de sincronización reversa (moderno → legacy) para soporte al plan de rollback |

## Packet `[INVOKE]`

```
[INVOKE: Solutioning/Delivery - SME/Technology/Data & ML/Specialist - Legacy Datastore Migration/]
COMPONENTE      : SPE-MM-{NNN} — {nombre del sistema}
DATASTORE-ORIGEN: Unisys DMSII · {N} schemas · {N} record types · {LOC total DASDL}
DATASTORE-TARGET: {PostgreSQL / Aurora / Oracle} en {cloud target}
COEXISTENCIA    : ≥ 12 meses · CDC bidireccional requerido para rollback
SCHEMAS-CLAVE   : CAPTACION · BD04TARJETAS · {otros del inventario ETAPA 2}
RIESGO-CRITICO  : Sets con ORDER semantics · POPULATION hardcodes en P104 · packed decimal
INSUMOS         : Data Dictionary · ERD Lógico · Data Lineage Map · DASDL fuentes (extracted_source/)
DELIVERABLE     : data-migration-design + DDL target + mapping DASDL→SQL + CDC design + rollback-sync-plan
```

## Posición en el ciclo metodológico

```
Etapa 2 (RE: Data RE) → Fase DESIGN (ADR data sync) → FASE 6 DATA MIGRATION → BUILD → parallel-run

                                          ↓
                              CDC activo desde inicio de BUILD
                              Bulk migration en ventana de cutover por capability
                              Sync reverso activo durante parallel-run ≥ 3 meses
```

*Última actualización: 2026-06-30 · v1.0 · Fase creada como carpeta-puntero per REORG de fases MM.*
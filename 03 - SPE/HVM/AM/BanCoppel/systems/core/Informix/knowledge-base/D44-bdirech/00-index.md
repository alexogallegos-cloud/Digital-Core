# D44-bdirech — Conciliación Operativa / Confirmación a Sucursal
> **Dominio**: Conciliación Operativa — Confirmación de transacciones a sucursal
> **Base de datos Informix**: bdirech
> **Estado**: [DISCOVER ETAPA 1 — caracterización inicial completa] · 2026-08-12
> **Prioridad**: ALTA — 77 SPs · 5 ESB-exposed · cierre diario crítico

---

## Descripción de Negocio

Gestiona el proceso de **confirmación y conciliación de transacciones hacia las sucursales** BanCoppel. Los SPs coordinan el ciclo de cierre diario: confirma operaciones realizadas en sucursal, consulta confirmaciones anteriores, y registra el estado de conciliación. Tiene dependencia directa con los SPs de intercard (D16) y con el sistema de caja (D46-bdiofi).

Nombre probable: **bdirech** = "Base de Datos de RECHazos" o "REConciliación CHecks". Los SPs `confalsuc` = "confirmación al sucursal".

## Estadísticas (brain.db · 2026-08-12)

| Métrica | Valor |
|---------|-------|
| SPs totales | 77 |
| Reglas extraídas | 465 |
| SBVR formal | 0 (Layer C+ pendiente) |
| ESB-exposed | 5 (cierre diario omnicanal) |
| CTM batch | 0 (detectado por sp_hints, sin CTM_ENTRY aún) |

## SPs ESB-Exposed (Journeys candidatos)

| SP | Descripción funcional | Riesgo |
|----|----------------------|--------|
| `spactsdoconfalsuc` | Actualiza estado de confirmación al sucursal | ESTADO — integridad del cierre; race condition en target si no hay lock |
| `spconantconfalsuc` | Consulta confirmaciones anteriores a sucursal | — |
| `spconconfalsuc_web` | Consulta confirmaciones a sucursal (canal web) | — |
| `spconsultarcatestatus` | Consulta catálogo de status de conciliación | — |
| `spgrabarconfalsuc` | Graba confirmación al sucursal | ESTADO — escritura concurrente; revisión de serialización |

## Riesgos de Migración Clave

| Riesgo | Descripción |
|--------|-------------|
| Cierre diario | Proceso crítico de negocio; ventana de cierre < 2h; SLO target debe replicar performance Informix |
| Race condition | `spactsdoconfalsuc` + `spgrabarconfalsuc` pueden correr concurrentes; PostgreSQL SERIALIZABLE vs Informix |
| Reconciliation gap | 465 reglas contienen lógica de reconciliación; equivalencia funcional obligatoria en parallel-run |
| Cross-domain | Dependencias con D16-intercard (tarjetas) y D46-bdiofi (caja sucursal); mapping requerido |

## Diagnóstico de Dominio

- **Tipo TOGAF**: processors (orquesta el cierre transaccional)
- **Sistema de**: record (confirmaciones son fuente de verdad para cuadre de caja)
- **sp_archetype**: mix de orchestrator + implementation
- **Ventana de operación**: batch nocturno + consultas web día

## Próximos Pasos

1. Ejecutar Layer C+ SBVR sobre 465 reglas — detectar lógica de conciliación MONEY/DIV
2. Mapear dependencias cross-domain: D16 (intercard), D46 (caja), D10 (sucursal)
3. Agregar SPs ESB-exposed a `journeys-data.json` como journeys D44
4. Diseñar test de equivalencia: comparar cuadre de caja legacy vs target por N días
5. Crear `05-risks.md` con riesgo de cierre y race condition

---

*Actualizado 2026-08-12 — DISCOVER Etapa 1 · Brain-First characterization*
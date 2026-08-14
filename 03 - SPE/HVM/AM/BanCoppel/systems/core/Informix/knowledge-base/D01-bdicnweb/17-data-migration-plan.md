# D01 · Canal Digital Web — Plan de Migración de Datos

> **Componente:** Informix · SPE-AM-001 · DESIGN Phase → BUILD
> **Base de datos:** `bdicnweb` → Target: Aurora PostgreSQL 15+
> **Wave:** ÚLTIMO · Riesgo: **ALTO**
> **Última actualización:** 2026-07-03

---
**SME responsable:**
- Specialist — Informix SPL Analysis (análisis estático y equivalencias)
- DBA — IBM Informix IDS (schema real vía syscolumns — Etapa 2)
- Cloud Architect — AWS Banking (arquitectura target y servicios AWS)
- QA Lead — Equivalencia Funcional (golden master y criterios go/no-go)
- Core Banking Transformation (ACL design y API contracts)
- Industry Banking / Domain Expert BanCoppel (validación funcional)
- Cybersecurity (PII, CNBV, LFPDPPP, PCI-DSS)
- SRE & AIOps (observabilidad y runbooks)
- Data & ML — Data Architect (migración de datos, CDC Debezium)

> `[SME-PENDING]` = requiere sesión de validación con el experto indicado.
---


## Resumen ejecutivo

| Métrica | Valor |
|---------|-------|
| SPs a migrar (scope mínimo) | 2,122 en call graph |
| Tablas estimadas (inferidas) | ~141 (confirmar con DBA IBM Informix — Etapa 2) |
| Volumen de datos | [SME-PENDING — DBA IBM Informix: `SELECT nrows FROM systables`] |
| Herramienta CDC | Debezium + Amazon MSK (Kafka managed) |
| Estrategia | Dump inicial + CDC en paralelo → cutover en ventana de mantenimiento |

## Estrategia de migración: Dump + CDC

```
FASE 1 — SNAPSHOT INICIAL (sin downtime)
  ├─ Debezium captura snapshot de tablas bdicnweb
  ├─ Datos van a MSK (Kafka) → Lambda sink → Aurora PostgreSQL
  └─ Duración estimada: [SME-PENDING — depende del volumen real]

FASE 2 — CDC EN PARALELO (sin downtime)
  ├─ Debezium sigue capturando cambios en tiempo real (CDC)
  ├─ Ambos sistemas activos: Informix (producción) + Aurora (sombra)
  ├─ QA Lead ejecuta parallel-run y monitorea divergencias
  └─ Duración: 72 horas mínimo hasta criterios go/no-go

FASE 3 — CUTOVER (con ventana de mantenimiento ~2 horas)
  ├─ Freeze de escrituras en Informix bdicnweb
  ├─ Drenar CDC (últimos mensajes en Kafka)
  ├─ Validar COUNT(*) por tabla: Informix = Aurora
  ├─ Inicializar SEQUENCES en Aurora: MAX(id) * 1.5
  ├─ Activar feature flag → tráfico al target
  └─ Informix en modo read-only (backup 30 días)
```

## Configuración Debezium para `bdicnweb`

```json
{
  "name": "debezium-bdicnweb",
  "connector.class": "io.debezium.connector.informix.InformixConnector",
  "database.hostname": "DCMSIF01",
  "database.port": "9088",
  "database.user": "[SME-PENDING — DBA: usuario con permisos CDC]",
  "database.password": "[KMS encrypted — no en este documento]",
  "database.dbname": "bdicnweb",
  "table.include.list": "[SME-PENDING — DBA: lista de tablas a capturar]",
  "decimal.handling.mode": "string",
  "time.precision.mode": "adaptive_time_microseconds",
  "database.serverTimezone": "America/Mexico_City",
  "topic.prefix": "bancoppel.bdicnweb",
  "schema.history.internal.kafka.topic": "schema-changes.bdicnweb"
}
```

## Dependencias de datos — pre-requisitos

Para que los datos de `bdicnweb` sean coherentes en Aurora, los siguientes dominios deben haber sido migrados primero (referencian sus datos):

| Dominio prereq | Nombre | Volumen de relación | Impacto si no está listo |
|---------------|--------|--------------------|-----------------------|
| D02 | Integración y Autenticación | 15,304 | Debe estar disponible como API antes de migrar `bdicnweb` |
| D03 | Créditos | 10,903 | Debe estar disponible como API antes de migrar `bdicnweb` |
| D10 | Sucursales | 6,094 | Debe estar disponible como API antes de migrar `bdicnweb` |

## Validación post-migración

```sql
-- Ejecutar en Informix Y Aurora PG para comparar:
-- 1. Conteo de filas por tabla
SELECT tabname, nrows FROM systables WHERE owner='informix'; -- Informix
SELECT schemaname, tablename, n_live_tup FROM pg_stat_user_tables; -- Aurora PG

-- 2. Suma de campos MONEY (validación financiera)
-- [SME-PENDING — DBA + QA Lead: definir queries de conciliación por tabla crítica]

-- 3. Verificar últimos registros
SELECT MAX(fecha_insert), COUNT(*) FROM bdicnweb:tabla_principal; -- Informix
SELECT MAX(fecha_insert), COUNT(*) FROM tabla_principal; -- Aurora PG
```

## Pendientes críticos

- [ ] **DBA IBM Informix** — ejecutar `SELECT tabname, nrows FROM systables` para volúmenes reales
- [ ] **DBA IBM Informix** — identificar usuario con permisos CDC para Debezium
- [ ] **Data & ML** — instalar y configurar Debezium en MSK
- [ ] **QA Lead** — definir queries de conciliación por tabla crítica
- [ ] **Cloud Architect AWS** — provisionar Aurora PostgreSQL con Multi-AZ

---
*Generado por: Data & ML (Data Architect) + DBA IBM Informix IDS · 2026-07-03 · [SME-PENDING] schema real requerido*

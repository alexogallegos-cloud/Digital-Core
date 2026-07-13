# D06 · Solicitudes — Modelo Entidad-Relación (Inferido)

> **Componente:** BCOPCore · SPE-AM-001 · Etapa 1
> **Base de datos:** `bdisolic` · IBM Informix IDS 14.10 / POWER-AIX
> **Wave:** Wave 3 · Riesgo: **ALTO**
> **Última actualización:** 2026-07-03

---
**SME responsable:**
- Specialist — Informix SPL Analysis (análisis estático, code extraction)
- DBA — IBM Informix IDS (schema real vía syscolumns — Etapa 2) ← NUEVO
- Industry Banking + Domain Expert BanCoppel (validación funcional)
- Cybersecurity (riesgos PII, regulación CNBV/LFPDPPP)
- QA Lead — Equivalencia Funcional (estrategia de pruebas) ← NUEVO
- Cloud Architect AWS Banking (arquitectura target) ← NUEVO
> [SME-PENDING] = requiere sesión de validación antes de Etapa 2.
---

## Metodología

Tablas inferidas de análisis estático de **70 archivos SQL** (`FROM`, `INSERT INTO`, `UPDATE`, `DELETE FROM`).
Columnas inferidas de listas `INSERT INTO tbl (col1, col2, ...)`.
Relaciones inferidas del conocimiento de dominio — Informix no declara `FOREIGN KEY` formalmente.

## Diagrama ER — tablas core (Mermaid)

```mermaid
graph TD
    ss_solicitudes["ss_solicitudes"]
    ss_autorizacion["ss_autorizacion"]
    ss_param["ss_param"]
    ss_resum_scor_fin["ss_resum_scor_fin"]
    bdidigital["bdidigital"]
    ss_autorizacion_especial["ss_autorizacion_especial"]
    si_tmphistdiv["si_tmphistdiv"]
    paso_incrementoadn["paso_incrementoadn"]
    STATISTICS["STATISTICS"]
    ss_solsuperv_paso["ss_solsuperv_paso"]
    ss_tp_solicitud["ss_tp_solicitud"]
    ss_cont_norecuperados["ss_cont_norecuperados"]
    ss_autorizacion --> ss_autorizacion_especial
    ss_autorizacion_especial --> ss_autorizacion
    style ss_solicitudes fill:#A100FF,color:#fff
    style ss_autorizacion fill:#6A00B3,color:#fff
```

> Renderizable en GitHub o VSCode con extensión Mermaid Preview.

## Inventario de entidades propias de `bdisolic` (muestra)

| Tabla | Tipo | PK inferida | Lectores | Escritores |
|-------|------|-------------|----------|------------|
| `ss_solicitudes` | Transaccional | `id_solicitud` | 3 | 4 |
| `ss_autorizacion` | Transaccional | `[SME-PENDING]` | 3 | 3 |
| `ss_param` | Catálogo / Config | `[SME-PENDING]` | 5 | 0 |
| `ss_resum_scor_fin` | Transaccional | `[SME-PENDING]` | 1 | 2 |
| `bdidigital` | Transaccional | `[SME-PENDING]` | 3 | 0 |
| `ss_autorizacion_especial` | Transaccional | `[SME-PENDING]` | 1 | 1 |
| `si_tmphistdiv` | Reportería / Temporal | `[SME-PENDING]` | 1 | 1 |
| `paso_incrementoadn` | Transaccional | `[SME-PENDING]` | 2 | 0 |
| `STATISTICS` | Transaccional | `[SME-PENDING]` | 0 | 2 |
| `ss_solsuperv_paso` | Transaccional | `[SME-PENDING]` | 1 | 1 |
| `ss_tp_solicitud` | Transaccional | `id_solicitud` | 2 | 0 |
| `ss_cont_norecuperados` | Transaccional | `[SME-PENDING]` | 0 | 1 |
| `ss_detalle_scoring` | Transaccional | `[SME-PENDING]` | 1 | 0 |
| `dual` | Transaccional | `[SME-PENDING]` | 1 | 0 |
| `AX_PASO` | Transaccional | `[SME-PENDING]` | 0 | 1 |
| `tmp_solicitudes_dif` | Transaccional | `id_solicitud` | 1 | 0 |
| `TABLE` | Transaccional | `[SME-PENDING]` | 1 | 0 |
| `tmp_solicitudes_ap` | Transaccional | `id_solicitud` | 1 | 0 |
| `tmp_solicitudes_at` | Transaccional | `id_solicitud` | 1 | 0 |
| `bdiunica` | Transaccional | `[SME-PENDING]` | 0 | 1 |
| `ss_anexosol` | Transaccional | `[SME-PENDING]` | 0 | 1 |
| `systables` | Transaccional | `[SME-PENDING]` | 1 | 0 |
| `ss_soltrat` | Transaccional | `[SME-PENDING]` | 0 | 1 |
| `ss_solicitudes_mc` | Transaccional | `id_solicitud` | 1 | 0 |
| `ss_prospecteo_solicitudes` | Transaccional | `id_solicitud` | 1 | 0 |

## Tablas externas accedidas (cross-DB)

| DB externa | Tabla | Lecturas | Escrituras | Notas |
|-----------|-------|----------|-----------|-------|
| `BDISOLIC` | `ss_solicitud_os` | 1 SPs | 1 SPs | Cross-DB → API interna en target |
| `bdINteg` | `si_cliente` | 0 SPs | 1 SPs | Cross-DB → API interna en target |
| `bdicheq` | `` | 8 SPs | 0 SPs | Cross-DB → API interna en target |
| `bdicheq` | `sc_portacec_solicitud` | 1 SPs | 0 SPs | Cross-DB → API interna en target |
| `bdicnweb` | `` | 3 SPs | 0 SPs | Cross-DB → API interna en target |
| `bdicobranza` | `` | 6 SPs | 0 SPs | Cross-DB → API interna en target |
| `bdicred` | `sd_fechas` | 3 SPs | 0 SPs | Cross-DB → API interna en target |
| `bdicred` | `sd_maecred` | 2 SPs | 0 SPs | Cross-DB → API interna en target |
| `bdicred` | `sd_maesdos` | 1 SPs | 1 SPs | Cross-DB → API interna en target |
| `bdicred` | `sd_tarjeta` | 1 SPs | 1 SPs | Cross-DB → API interna en target |
| `bdicred` | `` | 15 SPs | 2 SPs | Cross-DB → API interna en target |
| `bdinteg` | `si_ingresos` | 2 SPs | 0 SPs | Cross-DB → API interna en target |
| `bdinteg` | `si_ctepf` | 4 SPs | 0 SPs | Cross-DB → API interna en target |
| `bdinteg` | `` | 18 SPs | 2 SPs | Cross-DB → API interna en target |
| `bdinteg` | `si_solicitud_movil` | 0 SPs | 1 SPs | Cross-DB → API interna en target |
| `bdinteg` | `si_histdiv` | 1 SPs | 0 SPs | Cross-DB → API interna en target |
| `bdiprospectos` | `` | 2 SPs | 1 SPs | Cross-DB → API interna en target |
| `bdisolic` | `ss_solicitudes` | 12 SPs | 5 SPs | Cross-DB → API interna en target |
| `bdisolic` | `` | 26 SPs | 17 SPs | Cross-DB → API interna en target |
| `bdisolic` | `ss_param` | 4 SPs | 0 SPs | Cross-DB → API interna en target |
| `bdisolic` | `tmp_solicitudes` | 1 SPs | 0 SPs | Cross-DB → API interna en target |
| `bdisolic` | `ss_autorizacion_especial` | 0 SPs | 1 SPs | Cross-DB → API interna en target |
| `sysmaster` | `` | 1 SPs | 0 SPs | Cross-DB → API interna en target |
| `sysmaster` | `sysshmvals` | 1 SPs | 0 SPs | Cross-DB → API interna en target |

## Detalle de columnas — tablas con columnas inferidas

### `ss_resum_scor_fin` — Transaccional

| Columna | Tipo Informix | Tipo PostgreSQL target | PII |
|---------|--------------|----------------------|-----|
| `abonomensualmuebles` | MONEY(16,2) | NUMERIC(16,2) |  |
| `abonomensualprestamos` | MONEY(16,2) | NUMERIC(16,2) |  |
| `abonomensualropa` | MONEY(16,2) | NUMERIC(16,2) |  |
| `causa` | [SME-PENDING] | [SME-PENDING] |  |
| `empresa` | [SME-PENDING] | [SME-PENDING] |  |
| `fuente` | [SME-PENDING] | [SME-PENDING] |  |
| `ingreso_mensual` | [SME-PENDING] | [SME-PENDING] |  |
| `linea_tienda` | [SME-PENDING] | [SME-PENDING] |  |
| `meses_historia` | [SME-PENDING] | [SME-PENDING] |  |
| `num_solicitud` | INTEGER | INTEGER |  |
| `puntualidad` | [SME-PENDING] | [SME-PENDING] |  |
| `saldomuebles` | MONEY(16,2) | NUMERIC(16,2) |  |
| `saldoprestamos` | MONEY(16,2) | NUMERIC(16,2) |  |
| `saldoropa` | MONEY(16,2) | NUMERIC(16,2) |  |
| `situacion_credito` | [SME-PENDING] | [SME-PENDING] |  |

### `ss_autorizacion` — Transaccional

| Columna | Tipo Informix | Tipo PostgreSQL target | PII |
|---------|--------------|----------------------|-----|
| `causa_solicitud` | [SME-PENDING] | [SME-PENDING] |  |
| `cliente_pros` | [SME-PENDING] | [SME-PENDING] |  |
| `comentario` | [SME-PENDING] | [SME-PENDING] |  |
| `ejecutivo_auto` | [SME-PENDING] | [SME-PENDING] |  |
| `empresa` | [SME-PENDING] | [SME-PENDING] |  |
| `fecha_entrada` | DATE | DATE |  |
| `fecha_insert` | DATE | DATE |  |
| `fecha_salida` | DATE | DATE |  |
| `num_solicitud` | INTEGER | INTEGER |  |
| `revision_cac` | [SME-PENDING] | [SME-PENDING] |  |
| `status_solicitud` | [SME-PENDING] | [SME-PENDING] |  |
| `user_insert` | [SME-PENDING] | [SME-PENDING] |  |

### `ss_autorizacion_especial` — Transaccional

| Columna | Tipo Informix | Tipo PostgreSQL target | PII |
|---------|--------------|----------------------|-----|
| `comentario` | [SME-PENDING] | [SME-PENDING] |  |
| `empresa` | [SME-PENDING] | [SME-PENDING] |  |
| `fecha_modif` | DATE | DATE |  |
| `montolinea_ant` | MONEY(16,2) | NUMERIC(16,2) |  |
| `montolinea_nvo` | MONEY(16,2) | NUMERIC(16,2) |  |
| `num_solicitud` | INTEGER | INTEGER |  |
| `numcte` | [SME-PENDING] | [SME-PENDING] |  |
| `secuencia` | [SME-PENDING] | [SME-PENDING] |  |
| `status_ant` | [SME-PENDING] | [SME-PENDING] |  |
| `status_nvo` | [SME-PENDING] | [SME-PENDING] |  |
| `usuario_modif` | [SME-PENDING] | [SME-PENDING] |  |

### `ss_solsuperv_paso` — Transaccional

| Columna | Tipo Informix | Tipo PostgreSQL target | PII |
|---------|--------------|----------------------|-----|
| `empresa` | [SME-PENDING] | [SME-PENDING] |  |
| `fecha_cambio` | DATE | DATE |  |
| `fecha_insert` | DATE | DATE |  |
| `fecha_solicitud` | DATE | DATE |  |
| `nombre_cte` | VARCHAR(100) | VARCHAR(100) | ⚠️ PII |
| `num_solicitud` | INTEGER | INTEGER |  |
| `numcte` | [SME-PENDING] | [SME-PENDING] |  |
| `respuesta_os` | [SME-PENDING] | [SME-PENDING] |  |
| `status` | [SME-PENDING] | [SME-PENDING] |  |
| `user_insert` | [SME-PENDING] | [SME-PENDING] |  |

## Tablas core del dominio (conocimiento de dominio)

| Tabla | Tipo esperado | Notas |
|-------|--------------|-------|
| `sol_solicitud` | Transaccional | Confirmar existencia y esquema con DBA |
| `sol_estatus` | Transaccional | Confirmar existencia y esquema con DBA |
| `sol_producto` | Transaccional | Confirmar existencia y esquema con DBA |
| `sol_documento` | Transaccional | Confirmar existencia y esquema con DBA |
| `sol_dictamen` | Transaccional | Confirmar existencia y esquema con DBA |

## Pendientes Etapa 2

```sql
-- Ejecutar en instancia Informix `bdisolic` para obtener schema real:
SELECT t.tabname, c.colname, c.coltype, c.collength, c.colno
FROM systables t JOIN syscolumns c ON t.tabid = c.tabid
WHERE t.owner = 'informix'
ORDER BY t.tabname, c.colno;
```

- [ ] Confirmar política de retención por tabla (especialmente tablas `_his`)
- [ ] Identificar todos los campos PII — datos sujetos a LFPDPPP
- [ ] Verificar si tablas `_tmp` / `_temp` se crean dinámicamente o son permanentes
- [ ] Confirmar cardinalidades reales en producción
- [ ] Validar relaciones implícitas (FK lógicas sin constraint formal)


---
*Generado por: Specialist — Informix SPL Analysis · 2026-07-03 · Evidencia: source/BCOPCore/informix/bdisolic_*.sql (análisis estático de 70 archivos SQL) · análisis estático de archivos SQL*

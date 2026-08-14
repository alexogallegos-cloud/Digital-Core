# D12 · Contabilidad — Modelo Entidad-Relación (Inferido)

> **Componente:** Informix · SPE-AM-001 · Etapa 1
> **Base de datos:** `bdicont` · IBM Informix IDS 14.10 / POWER-AIX
> **Wave:** Wave 4 · Riesgo: **ALTO**
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
    co_fechas["co_fechas"]
    co_sdodias["co_sdodias"]
    co_detpol["co_detpol"]
    co_cierre_cif["co_cierre_cif"]
    co_balanza["co_balanza"]
    STATISTICS["STATISTICS"]
    tmp_historico["tmp_historico"]
    co_diasaux["co_diasaux"]
    co_param["co_param"]
    co_poliza["co_poliza"]
    co_histsdodias["co_histsdodias"]
    co_contproc["co_contproc"]

    style co_fechas fill:#A100FF,color:#fff
    style co_sdodias fill:#6A00B3,color:#fff
```

> Renderizable en GitHub o VSCode con extensión Mermaid Preview.

## Inventario de entidades propias de `bdicont` (muestra)

| Tabla | Tipo | PK inferida | Lectores | Escritores |
|-------|------|-------------|----------|------------|
| `co_fechas` | Transaccional | `[SME-PENDING]` | 22 | 0 |
| `co_sdodias` | Transaccional | `[SME-PENDING]` | 16 | 5 |
| `co_detpol` | Transaccional | `[SME-PENDING]` | 14 | 5 |
| `co_cierre_cif` | Transaccional | `[SME-PENDING]` | 10 | 3 |
| `co_balanza` | Transaccional | `[SME-PENDING]` | 4 | 9 |
| `STATISTICS` | Transaccional | `[SME-PENDING]` | 0 | 12 |
| `tmp_historico` | Histórico / Archivado | `secuencial` | 6 | 6 |
| `co_diasaux` | Transaccional | `[SME-PENDING]` | 6 | 5 |
| `co_param` | Catálogo / Config | `[SME-PENDING]` | 10 | 0 |
| `co_poliza` | Transaccional | `num_poliza` | 5 | 4 |
| `co_histsdodias` | Histórico / Archivado | `secuencial` | 5 | 3 |
| `co_contproc` | Transaccional | `[SME-PENDING]` | 3 | 3 |
| `co_tabmovdia` | Transaccional | `[SME-PENDING]` | 3 | 3 |
| `co_movdia` | Transaccional | `[SME-PENDING]` | 3 | 3 |
| `co_balprev` | Transaccional | `[SME-PENDING]` | 3 | 3 |
| `tmp_parametros` | Catálogo / Config | `[SME-PENDING]` | 0 | 6 |
| `co_histdiasaux` | Histórico / Archivado | `secuencial` | 2 | 3 |
| `co_diario` | Transaccional | `[SME-PENDING]` | 3 | 1 |
| `co_historico` | Histórico / Archivado | `secuencial` | 1 | 3 |
| `co_sdomes` | Transaccional | `[SME-PENDING]` | 3 | 1 |
| `co_movtos` | Transaccional | `[SME-PENDING]` | 4 | 0 |
| `co_detmaenca` | Transaccional | `[SME-PENDING]` | 2 | 2 |
| `co_detmadet` | Transaccional | `[SME-PENDING]` | 2 | 2 |
| `co_libmadet` | Transaccional | `[SME-PENDING]` | 2 | 2 |
| `co_libmaenca` | Transaccional | `[SME-PENDING]` | 2 | 2 |
| `co_mensual` | Transaccional | `[SME-PENDING]` | 2 | 1 |
| `co_historico_tmp` | Histórico / Archivado | `secuencial` | 2 | 1 |
| `co_histsdodias_tmp` | Histórico / Archivado | `secuencial` | 2 | 1 |
| `co_auxiliar` | Transaccional | `[SME-PENDING]` | 3 | 0 |
| `co_mapeo_divisas` | Transaccional | `[SME-PENDING]` | 3 | 0 |
| `co_mapeo_nuevo` | Transaccional | `[SME-PENDING]` | 2 | 1 |
| `co_canret` | Transaccional | `[SME-PENDING]` | 1 | 2 |
| `co_saldos` | Transaccional | `[SME-PENDING]` | 3 | 0 |
| `co_auditpase` | Log / Bitácora | `[SME-PENDING]` | 1 | 1 |
| `tx` | Transaccional | `[SME-PENDING]` | 2 | 0 |

## Tablas externas accedidas (cross-DB)

| DB externa | Tabla | Lecturas | Escrituras | Notas |
|-----------|-------|----------|-----------|-------|
| `bdicont` | `systables` | 2 SPs | 0 SPs | Cross-DB → API interna en target |
| `bdicont` | `co_clv_pasesuc` | 1 SPs | 2 SPs | Cross-DB → API interna en target |
| `bdicont` | `co_ctrlpoliza` | 2 SPs | 2 SPs | Cross-DB → API interna en target |
| `bdicont` | `co_auxiliar` | 0 SPs | 1 SPs | Cross-DB → API interna en target |
| `bdicont` | `co_historico` | 5 SPs | 2 SPs | Cross-DB → API interna en target |
| `bdinteg` | `si_regional` | 1 SPs | 0 SPs | Cross-DB → API interna en target |
| `bdinteg` | `si_sucursales` | 11 SPs | 0 SPs | Cross-DB → API interna en target |
| `bdinteg` | `si_catalog` | 21 SPs | 0 SPs | Cross-DB → API interna en target |
| `bdinteg` | `si_plazas` | 8 SPs | 0 SPs | Cross-DB → API interna en target |
| `bdinteg` | `si_divisas` | 4 SPs | 0 SPs | Cross-DB → API interna en target |
| `bdirepaut` | `sp_preciocontable` | 1 SPs | 0 SPs | Cross-DB → API interna en target |
| `sysmaster` | `systabnames` | 1 SPs | 0 SPs | Cross-DB → API interna en target |

## Detalle de columnas — tablas con columnas inferidas

### `co_balanza` — Transaccional

| Columna | Tipo Informix | Tipo PostgreSQL target | PII |
|---------|--------------|----------------------|-----|
| `abonos_dia` | MONEY(16,2) | NUMERIC(16,2) |  |
| `cargos_dia` | MONEY(16,2) | NUMERIC(16,2) |  |
| `ccmayor` | [SME-PENDING] | [SME-PENDING] |  |
| `ccsssubsub` | [SME-PENDING] | [SME-PENDING] |  |
| `ccssubsub` | [SME-PENDING] | [SME-PENDING] |  |
| `ccsub` | [SME-PENDING] | [SME-PENDING] |  |
| `ccsubsub` | [SME-PENDING] | [SME-PENDING] |  |
| `ciudad` | [SME-PENDING] | [SME-PENDING] |  |
| `desc_sucursal` | VARCHAR(100) | VARCHAR(100) |  |
| `empresa` | [SME-PENDING] | [SME-PENDING] |  |
| `mes_dia` | [SME-PENDING] | [SME-PENDING] |  |
| `moneda` | [SME-PENDING] | [SME-PENDING] |  |
| `naturaleza_cta` | [SME-PENDING] | [SME-PENDING] |  |
| `nombre` | VARCHAR(100) | VARCHAR(100) | ⚠️ PII |
| `promedio_anual` | [SME-PENDING] | [SME-PENDING] |  |

### `co_histsdodias` — Histórico / Archivado

| Columna | Tipo Informix | Tipo PostgreSQL target | PII |
|---------|--------------|----------------------|-----|
| `abonos_dia` | MONEY(16,2) | NUMERIC(16,2) |  |
| `cargos_dia` | MONEY(16,2) | NUMERIC(16,2) |  |
| `ccmayor` | [SME-PENDING] | [SME-PENDING] |  |
| `ccsssubsub` | [SME-PENDING] | [SME-PENDING] |  |
| `ccssubsub` | [SME-PENDING] | [SME-PENDING] |  |
| `ccsub` | [SME-PENDING] | [SME-PENDING] |  |
| `ccsubsub` | [SME-PENDING] | [SME-PENDING] |  |
| `ciudad` | [SME-PENDING] | [SME-PENDING] |  |
| `dias_acumulado` | [SME-PENDING] | [SME-PENDING] |  |
| `dias_proyectado` | [SME-PENDING] | [SME-PENDING] |  |
| `empresa` | [SME-PENDING] | [SME-PENDING] |  |
| `mes_dia` | [SME-PENDING] | [SME-PENDING] |  |
| `moneda` | [SME-PENDING] | [SME-PENDING] |  |
| `nro_abonos_dia` | MONEY(16,2) | NUMERIC(16,2) |  |
| `nro_cargos_dia` | MONEY(16,2) | NUMERIC(16,2) |  |

### `tmp_historico` — Histórico / Archivado

| Columna | Tipo Informix | Tipo PostgreSQL target | PII |
|---------|--------------|----------------------|-----|
| `ccmayor` | [SME-PENDING] | [SME-PENDING] |  |
| `ccosto_orig` | [SME-PENDING] | [SME-PENDING] |  |
| `ccsssubsub` | [SME-PENDING] | [SME-PENDING] |  |
| `ccssubsub` | [SME-PENDING] | [SME-PENDING] |  |
| `ccsub` | [SME-PENDING] | [SME-PENDING] |  |
| `ccsubsub` | [SME-PENDING] | [SME-PENDING] |  |
| `ciudad` | [SME-PENDING] | [SME-PENDING] |  |
| `control_poliza` | [SME-PENDING] | [SME-PENDING] |  |
| `descripcion` | VARCHAR(100) | VARCHAR(100) |  |
| `fecha_captura` | DATE | DATE |  |
| `fecha_valida` | DATE | DATE |  |
| `moneda` | [SME-PENDING] | [SME-PENDING] |  |
| `monto` | MONEY(16,2) | NUMERIC(16,2) |  |
| `naturaleza` | [SME-PENDING] | [SME-PENDING] |  |
| `nro_auxiliar` | [SME-PENDING] | [SME-PENDING] |  |

### `co_ctasob` — Transaccional

| Columna | Tipo Informix | Tipo PostgreSQL target | PII |
|---------|--------------|----------------------|-----|
| `auxiliar` | [SME-PENDING] | [SME-PENDING] |  |
| `ccmayor` | [SME-PENDING] | [SME-PENDING] |  |
| `ccsssubsub` | [SME-PENDING] | [SME-PENDING] |  |
| `ccssubsub` | [SME-PENDING] | [SME-PENDING] |  |
| `ccsub` | [SME-PENDING] | [SME-PENDING] |  |
| `ccsubsub` | [SME-PENDING] | [SME-PENDING] |  |
| `ciudad` | [SME-PENDING] | [SME-PENDING] |  |
| `cuenta` | [SME-PENDING] | [SME-PENDING] |  |
| `empresa` | [SME-PENDING] | [SME-PENDING] |  |
| `mes_dia` | [SME-PENDING] | [SME-PENDING] |  |
| `moneda` | [SME-PENDING] | [SME-PENDING] |  |
| `saldo_fin_de_dia` | MONEY(16,2) | NUMERIC(16,2) |  |
| `saldo_inicio_dia` | MONEY(16,2) | NUMERIC(16,2) |  |
| `sector` | [SME-PENDING] | [SME-PENDING] |  |
| `sucursal` | [SME-PENDING] | [SME-PENDING] |  |

## Tablas core del dominio (conocimiento de dominio)

| Tabla | Tipo esperado | Notas |
|-------|--------------|-------|
| `co_poliza` | Transaccional | Confirmar existencia y esquema con DBA |
| `co_asiento` | Transaccional | Confirmar existencia y esquema con DBA |
| `co_auxiliar` | Transaccional | Confirmar existencia y esquema con DBA |
| `co_saldo` | Transaccional | Confirmar existencia y esquema con DBA |
| `co_catalogo_ctas` | Catálogo / Config | Confirmar existencia y esquema con DBA |
| `co_empresa` | Transaccional | Confirmar existencia y esquema con DBA |
| `co_sucursal` | Transaccional | Confirmar existencia y esquema con DBA |

## Pendientes Etapa 2

```sql
-- Ejecutar en instancia Informix `bdicont` para obtener schema real:
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
*Generado por: Specialist — Informix SPL Analysis · 2026-07-03 · Evidencia: source/informix/bdicont_*.sql (análisis estático de 70 archivos SQL) · análisis estático de archivos SQL*

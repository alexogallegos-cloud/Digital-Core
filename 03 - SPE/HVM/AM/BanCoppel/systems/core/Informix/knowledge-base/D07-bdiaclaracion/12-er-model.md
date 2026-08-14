# D07 · Aclaraciones — Modelo Entidad-Relación (Inferido)

> **Componente:** Informix · SPE-AM-001 · Etapa 1
> **Base de datos:** `bdiaclaracion` · IBM Informix IDS 14.10 / POWER-AIX
> **Wave:** Wave 2 · Riesgo: **ALTO**
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
    acl_aclaracion["acl_aclaracion"]
    acl_producto["acl_producto"]
    acl_movimiento["acl_movimiento"]
    acl_tipo_evento["acl_tipo_evento"]
    systables["systables"]
    acl_origen_evento["acl_origen_evento"]
    acl_tipo_producto["acl_tipo_producto"]
    acl_estatus_corporativo["acl_estatus_corporativo"]
    acl_usuario["acl_usuario"]
    acl_entrada_bitacora["acl_entrada_bitacora"]
    tblAclaraciones["tblAclaraciones"]
    acl_tipo_movimiento["acl_tipo_movimiento"]

    style acl_aclaracion fill:#A100FF,color:#fff
    style acl_producto fill:#6A00B3,color:#fff
```

> Renderizable en GitHub o VSCode con extensión Mermaid Preview.

## Inventario de entidades propias de `bdiaclaracion` (muestra)

| Tabla | Tipo | PK inferida | Lectores | Escritores |
|-------|------|-------------|----------|------------|
| `acl_aclaracion` | Transaccional | `folio_csuac` | 43 | 15 |
| `acl_producto` | Transaccional | `[SME-PENDING]` | 40 | 0 |
| `acl_movimiento` | Transaccional | `pky_movimiento` | 37 | 1 |
| `acl_tipo_evento` | Transaccional | `[SME-PENDING]` | 37 | 0 |
| `systables` | Transaccional | `[SME-PENDING]` | 37 | 0 |
| `acl_origen_evento` | Transaccional | `[SME-PENDING]` | 34 | 0 |
| `acl_tipo_producto` | Transaccional | `[SME-PENDING]` | 32 | 0 |
| `acl_estatus_corporativo` | Transaccional | `[SME-PENDING]` | 26 | 0 |
| `acl_usuario` | Transaccional | `[SME-PENDING]` | 22 | 3 |
| `acl_entrada_bitacora` | Log / Bitácora | `id_log` | 5 | 16 |
| `tblAclaraciones` | Transaccional | `folio_csuac` | 10 | 10 |
| `acl_tipo_movimiento` | Transaccional | `pky_movimiento` | 20 | 0 |
| `acl_resolucion` | Transaccional | `[SME-PENDING]` | 17 | 0 |
| `bdiaclaracion` | Transaccional | `folio_csuac` | 11 | 4 |
| `acl_estatus_aclaracion` | Transaccional | `folio_csuac` | 15 | 0 |
| `temp_aclara` | Transaccional | `[SME-PENDING]` | 8 | 7 |
| `temp_solic` | Transaccional | `[SME-PENDING]` | 8 | 7 |
| `temp_respues` | Transaccional | `[SME-PENDING]` | 8 | 7 |
| `acl_rango_importe` | Transaccional | `[SME-PENDING]` | 12 | 0 |
| `TABLE` | Transaccional | `[SME-PENDING]` | 12 | 0 |
| `acl_cat_datosnoconv` | Catálogo / Config | `[SME-PENDING]` | 11 | 0 |
| `acl_cat_bines` | Catálogo / Config | `[SME-PENDING]` | 11 | 0 |
| `acl_cat_tokenPY` | Catálogo / Config | `[SME-PENDING]` | 11 | 0 |
| `acl_tipo_prod_tipo_evento` | Transaccional | `[SME-PENDING]` | 10 | 0 |
| `temp_bitacora` | Log / Bitácora | `id_log` | 8 | 1 |
| `temp_mov` | Transaccional | `[SME-PENDING]` | 8 | 1 |
| `acl_no_procedenterbt` | Transaccional | `[SME-PENDING]` | 7 | 0 |
| `acl_solicitud_e_global` | Transaccional | `id_solicitud` | 7 | 0 |
| `acl_estatus_canales` | Transaccional | `[SME-PENDING]` | 7 | 0 |
| `statistics` | Transaccional | `[SME-PENDING]` | 0 | 7 |
| `acl_regulatorio27` | Transaccional | `[SME-PENDING]` | 3 | 3 |
| `acl_cierre_masivo` | Transaccional | `[SME-PENDING]` | 3 | 3 |
| `acl_bitacora_cambio_pass` | Log / Bitácora | `id_log` | 3 | 3 |
| `acl_bitacora_eventos_siem` | Log / Bitácora | `id_log` | 3 | 3 |
| `acl_asociacion_origen_evento_canal` | Transaccional | `[SME-PENDING]` | 6 | 0 |

## Tablas externas accedidas (cross-DB)

| DB externa | Tabla | Lecturas | Escrituras | Notas |
|-----------|-------|----------|-----------|-------|
| `BDINTEG` | `` | 2 SPs | 0 SPs | Cross-DB → API interna en target |
| `bdiaclaracion` | `` | 28 SPs | 18 SPs | Cross-DB → API interna en target |
| `bdiaclaracion` | `acl_movimiento` | 19 SPs | 8 SPs | Cross-DB → API interna en target |
| `bdiaclaracion` | `acl_producto` | 15 SPs | 0 SPs | Cross-DB → API interna en target |
| `bdiaclaracion` | `acl_tipo_movimiento` | 6 SPs | 0 SPs | Cross-DB → API interna en target |
| `bdiaclaracion` | `acl_aclaracion` | 19 SPs | 1 SPs | Cross-DB → API interna en target |
| `bdicheq` | `sc_opcionbloqueo` | 2 SPs | 0 SPs | Cross-DB → API interna en target |
| `bdicheq` | `sc_maechq` | 14 SPs | 0 SPs | Cross-DB → API interna en target |
| `bdicheq` | `sc_maenoc` | 4 SPs | 0 SPs | Cross-DB → API interna en target |
| `bdicheq` | `sc_mae_estatus` | 4 SPs | 0 SPs | Cross-DB → API interna en target |
| `bdicheq` | `sc_bloqueo` | 2 SPs | 0 SPs | Cross-DB → API interna en target |
| `bdicred` | `sd_maecred` | 16 SPs | 0 SPs | Cross-DB → API interna en target |
| `bdicred` | `sd_definicion` | 15 SPs | 0 SPs | Cross-DB → API interna en target |
| `bdicred` | `sd_tarjeta` | 10 SPs | 0 SPs | Cross-DB → API interna en target |
| `bdicred` | `sd_maecredcrd` | 14 SPs | 0 SPs | Cross-DB → API interna en target |
| `bdicred` | `sd_bloqueoscuenta` | 2 SPs | 0 SPs | Cross-DB → API interna en target |
| `bdidomi` | `` | 0 SPs | 11 SPs | Cross-DB → API interna en target |
| `bdimnsj` | `mnsjr_trx_online` | 4 SPs | 0 SPs | Cross-DB → API interna en target |
| `bdimnsj` | `mnsjr_trx_online_his` | 4 SPs | 0 SPs | Cross-DB → API interna en target |
| `bdinteg` | `si_telefonos` | 19 SPs | 0 SPs | Cross-DB → API interna en target |
| `bdinteg` | `si_ctepf` | 26 SPs | 0 SPs | Cross-DB → API interna en target |
| `bdinteg` | `si_direcciones_actual` | 25 SPs | 0 SPs | Cross-DB → API interna en target |
| `bdinteg` | `si_cliente` | 32 SPs | 0 SPs | Cross-DB → API interna en target |
| `bdinteg` | `si_fechas` | 19 SPs | 0 SPs | Cross-DB → API interna en target |
| `bdinvers` | `sv_maeinv` | 6 SPs | 0 SPs | Cross-DB → API interna en target |
| `bdinvers` | `sv_movdia` | 8 SPs | 0 SPs | Cross-DB → API interna en target |
| `bdinvers` | `sv_movhis` | 8 SPs | 0 SPs | Cross-DB → API interna en target |
| `bdinvers` | `` | 1 SPs | 0 SPs | Cross-DB → API interna en target |
| `bdinvers` | `sv_instrum` | 1 SPs | 0 SPs | Cross-DB → API interna en target |
| `bditarjeta` | `td_movimientos_conciliacion` | 7 SPs | 0 SPs | Cross-DB → API interna en target |
| `bditransfer` | `tf_maecte` | 22 SPs | 0 SPs | Cross-DB → API interna en target |
| `intercard` | `movimientohistorico` | 29 SPs | 0 SPs | Cross-DB → API interna en target |
| `intercard` | `tarjeta` | 44 SPs | 0 SPs | Cross-DB → API interna en target |
| `intercard` | `tarjetacuenta` | 21 SPs | 0 SPs | Cross-DB → API interna en target |
| `intercard` | `movimiento` | 30 SPs | 0 SPs | Cross-DB → API interna en target |
| `intercard` | `bitacoracambiosstatustarjeta` | 20 SPs | 0 SPs | Cross-DB → API interna en target |

## Detalle de columnas — tablas con columnas inferidas

### `acl_reporte_evidencia_3410_2` — Reportería / Temporal

| Columna | Tipo Informix | Tipo PostgreSQL target | PII |
|---------|--------------|----------------------|-----|
| `cod_postal` | CHAR(4) | CHAR(4) |  |
| `estado` | [SME-PENDING] | [SME-PENDING] |  |
| `fechaCancela` | DATE | DATE |  |
| `fechaChipNip` | DATE | DATE |  |
| `fechaCvv2Din` | DATE | DATE |  |
| `fecha_consumo` | DATE | DATE |  |
| `folio_cs` | [SME-PENDING] | [SME-PENDING] |  |
| `giroComercio` | [SME-PENDING] | [SME-PENDING] |  |
| `idComercio` | [SME-PENDING] | [SME-PENDING] |  |
| `mensaje_sistema` | [SME-PENDING] | [SME-PENDING] |  |
| `municipio` | [SME-PENDING] | [SME-PENDING] |  |
| `num_autorizacion` | INTEGER | INTEGER |  |
| `num_celular` | INTEGER | INTEGER | ⚠️ PII |
| `ref_comercio` | [SME-PENDING] | [SME-PENDING] |  |
| `statusTjt` | [SME-PENDING] | [SME-PENDING] |  |

### `acl_reporte_evidencia_3410` — Reportería / Temporal

| Columna | Tipo Informix | Tipo PostgreSQL target | PII |
|---------|--------------|----------------------|-----|
| `cod_postal` | CHAR(4) | CHAR(4) |  |
| `estado` | [SME-PENDING] | [SME-PENDING] |  |
| `fechaCancela` | DATE | DATE |  |
| `fechaChipNip` | DATE | DATE |  |
| `fechaCvv2Din` | DATE | DATE |  |
| `fecha_consumo` | DATE | DATE |  |
| `folio_cs` | [SME-PENDING] | [SME-PENDING] |  |
| `giroComercio` | [SME-PENDING] | [SME-PENDING] |  |
| `idComercio` | [SME-PENDING] | [SME-PENDING] |  |
| `municipio` | [SME-PENDING] | [SME-PENDING] |  |
| `num_autorizacion` | INTEGER | INTEGER |  |
| `num_celular` | INTEGER | INTEGER | ⚠️ PII |
| `ref_comercio` | [SME-PENDING] | [SME-PENDING] |  |
| `statusTjt` | [SME-PENDING] | [SME-PENDING] |  |
| `sucursal` | [SME-PENDING] | [SME-PENDING] |  |

### `acl_entrada_bitacora` — Log / Bitácora

| Columna | Tipo Informix | Tipo PostgreSQL target | PII |
|---------|--------------|----------------------|-----|
| `descripcion` | VARCHAR(100) | VARCHAR(100) |  |
| `fechahora` | DATE | DATE |  |
| `fky_accion` | INTEGER | INTEGER |  |
| `fky_aclaracion` | INTEGER | INTEGER |  |
| `fky_area` | INTEGER | INTEGER |  |
| `fky_estatus_aclaracion` | INTEGER | INTEGER |  |
| `fky_estatus_corp_analisis` | INTEGER | INTEGER |  |
| `fky_estatus_corp_general` | INTEGER | INTEGER |  |
| `fky_usuario` | INTEGER | INTEGER |  |
| `folio_csuac` | [SME-PENDING] | [SME-PENDING] |  |
| `pky_entrada_bitacora` | INTEGER | INTEGER |  |

### `acl_cierre_masivo` — Transaccional

| Columna | Tipo Informix | Tipo PostgreSQL target | PII |
|---------|--------------|----------------------|-----|
| `afectacion` | [SME-PENDING] | [SME-PENDING] |  |
| `fecha` | DATE | DATE |  |
| `fky_estatus_aclaracion` | INTEGER | INTEGER |  |
| `fky_estatus_corp_analisis` | INTEGER | INTEGER |  |
| `fky_estatus_corp_general` | INTEGER | INTEGER |  |
| `folio` | [SME-PENDING] | [SME-PENDING] |  |
| `folio_csuac` | [SME-PENDING] | [SME-PENDING] |  |
| `num_proceso` | INTEGER | INTEGER |  |
| `proceso` | [SME-PENDING] | [SME-PENDING] |  |
| `tipo_archivo` | CHAR(4) | CHAR(4) |  |

## Tablas core del dominio (conocimiento de dominio)

| Tabla | Tipo esperado | Notas |
|-------|--------------|-------|
| `acl_aclaracion` | Transaccional | Confirmar existencia y esquema con DBA |
| `acl_movimiento` | Transaccional | Confirmar existencia y esquema con DBA |
| `acl_producto` | Transaccional | Confirmar existencia y esquema con DBA |
| `acl_tipo_evento` | Transaccional | Confirmar existencia y esquema con DBA |
| `acl_estatus_aclaracion` | Transaccional | Confirmar existencia y esquema con DBA |
| `acl_regulatorio27` | Transaccional | Confirmar existencia y esquema con DBA |
| `acl_tipo_codigo_resolucion` | Transaccional | Confirmar existencia y esquema con DBA |

## Pendientes Etapa 2

```sql
-- Ejecutar en instancia Informix `bdiaclaracion` para obtener schema real:
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
*Generado por: Specialist — Informix SPL Analysis · 2026-07-03 · Evidencia: source/informix/bdiaclaracion_*.sql (análisis estático de 70 archivos SQL) · análisis estático de archivos SQL*

# D02 · Integración y Autenticación — Modelo Entidad-Relación (Inferido)

> **Componente:** LegacyCore · SPE-AM-001 · Etapa 1
> **Base de datos:** `bdinteg` · IBM Informix IDS 14.10 / POWER-AIX
> **Wave:** Wave 5 · Riesgo: **CRÍTICO**
> **Última actualización:** 2026-07-03

---
**SME responsable:**
- Specialist — Informix SPL Analysis (análisis estático, code extraction)
- DBA — IBM Informix IDS (schema real vía syscolumns — Etapa 2) ← NUEVO
- Industry Banking + Domain Expert LegacyCore (validación funcional)
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
    si_cliente["si_cliente"]
    si_param["si_param"]
    si_sucursales["si_sucursales"]
    si_direcciones["si_direcciones"]
    si_solicitud_movil["si_solicitud_movil"]
    si_ejecut["si_ejecut"]
    informix["informix"]
    si_codigopostal["si_codigopostal"]
    si_refper["si_refper"]
    ss_contproc["ss_contproc"]
    si_servcte["si_servcte"]
    RMONTO_FINANCIADO["RMONTO_FINANCIADO"]

    style si_cliente fill:#A100FF,color:#fff
    style si_param fill:#6A00B3,color:#fff
```

> Renderizable en GitHub o VSCode con extensión Mermaid Preview.

## Inventario de entidades propias de `bdinteg` (muestra)

| Tabla | Tipo | PK inferida | Lectores | Escritores |
|-------|------|-------------|----------|------------|
| `si_cliente` | Transaccional | `num_cte` | 11 | 1 |
| `si_param` | Catálogo / Config | `[SME-PENDING]` | 6 | 3 |
| `si_sucursales` | Transaccional | `[SME-PENDING]` | 7 | 2 |
| `si_direcciones` | Transaccional | `[SME-PENDING]` | 5 | 2 |
| `si_solicitud_movil` | Transaccional | `id_solicitud` | 5 | 2 |
| `si_ejecut` | Transaccional | `[SME-PENDING]` | 6 | 1 |
| `informix` | Transaccional | `[SME-PENDING]` | 3 | 3 |
| `si_codigopostal` | Transaccional | `[SME-PENDING]` | 3 | 3 |
| `si_refper` | Transaccional | `[SME-PENDING]` | 3 | 3 |
| `ss_contproc` | Transaccional | `[SME-PENDING]` | 3 | 3 |
| `si_servcte` | Transaccional | `[SME-PENDING]` | 3 | 3 |
| `RMONTO_FINANCIADO` | Transaccional | `[SME-PENDING]` | 3 | 3 |
| `si_refcomer` | Transaccional | `[SME-PENDING]` | 3 | 3 |
| `si_fechas` | Transaccional | `[SME-PENDING]` | 5 | 0 |
| `si_ctepf` | Transaccional | `[SME-PENDING]` | 2 | 2 |
| `td_numCliente` | Transaccional | `num_cte` | 2 | 2 |
| `si_bitacora_ife` | Log / Bitácora | `id_log` | 3 | 0 |
| `si_huella_linea` | Transaccional | `[SME-PENDING]` | 2 | 1 |
| `si_direcciones_actual` | Transaccional | `[SME-PENDING]` | 1 | 2 |
| `si_histdiv` | Histórico / Archivado | `secuencial` | 3 | 0 |
| `sd_maesdos` | Maestro | `[SME-PENDING]` | 3 | 0 |
| `ss_anexosol` | Transaccional | `[SME-PENDING]` | 3 | 0 |
| `si_empresas` | Transaccional | `[SME-PENDING]` | 3 | 0 |
| `si_feriado` | Transaccional | `[SME-PENDING]` | 3 | 0 |
| `ss_resum_scor_fin` | Transaccional | `[SME-PENDING]` | 3 | 0 |
| `ss_param` | Catálogo / Config | `[SME-PENDING]` | 3 | 0 |
| `si_tpcambio` | Transaccional | `[SME-PENDING]` | 3 | 0 |
| `SD_MAECRED` | Maestro | `[SME-PENDING]` | 3 | 0 |
| `sc_maechq` | Maestro | `[SME-PENDING]` | 3 | 0 |
| `ss_unidadprod` | Transaccional | `[SME-PENDING]` | 3 | 0 |
| `si_divisas` | Transaccional | `[SME-PENDING]` | 3 | 0 |
| `si_regional` | Transaccional | `[SME-PENDING]` | 3 | 0 |
| `sd_paginter` | Transaccional | `[SME-PENDING]` | 3 | 0 |
| `si_servicios` | Transaccional | `[SME-PENDING]` | 3 | 0 |
| `sd_fechas` | Transaccional | `[SME-PENDING]` | 3 | 0 |

## Tablas externas accedidas (cross-DB)

| DB externa | Tabla | Lecturas | Escrituras | Notas |
|-----------|-------|----------|-----------|-------|
| `BDICHEQ` | `` | 1 SPs | 0 SPs | Cross-DB → API interna en target |
| `BDINTEG` | `si_catzonas` | 2 SPs | 0 SPs | Cross-DB → API interna en target |
| `BDINTEG` | `SI_ESTADOS` | 1 SPs | 0 SPs | Cross-DB → API interna en target |
| `BDINTEG` | `SI_CATCALLES` | 1 SPs | 0 SPs | Cross-DB → API interna en target |
| `BDINTEG` | `SI_CATCIUDADES` | 1 SPs | 0 SPs | Cross-DB → API interna en target |
| `BDINTEG` | `SI_DIRECCIONES_ACTUAL` | 1 SPs | 0 SPs | Cross-DB → API interna en target |
| `BDISITESP` | `SE_CTESSITESPCTE` | 1 SPs | 0 SPs | Cross-DB → API interna en target |
| `BdInteg` | `tmpxmlarchclientegrupo` | 1 SPs | 0 SPs | Cross-DB → API interna en target |
| `bdibei` | `` | 1 SPs | 0 SPs | Cross-DB → API interna en target |
| `bdibpi` | `` | 4 SPs | 4 SPs | Cross-DB → API interna en target |
| `bdibpi` | `bpi_activacion_bex` | 1 SPs | 1 SPs | Cross-DB → API interna en target |
| `bdicheq` | `sc_tarjeta` | 2 SPs | 0 SPs | Cross-DB → API interna en target |
| `bdicheq` | `sc_maechq` | 2 SPs | 0 SPs | Cross-DB → API interna en target |
| `bdicheq` | `` | 10 SPs | 1 SPs | Cross-DB → API interna en target |
| `bdicheq` | `sc_cuenta_telefono` | 0 SPs | 1 SPs | Cross-DB → API interna en target |
| `bdicheq` | `sc_movhis_old` | 1 SPs | 0 SPs | Cross-DB → API interna en target |
| `bdicntchq` | `` | 0 SPs | 1 SPs | Cross-DB → API interna en target |
| `bdicobranza` | `cb_param` | 1 SPs | 0 SPs | Cross-DB → API interna en target |
| `bdicont` | `co_poliza` | 3 SPs | 3 SPs | Cross-DB → API interna en target |
| `bdicont` | `co_detpol` | 3 SPs | 3 SPs | Cross-DB → API interna en target |
| `bdicred` | `sd_maecred` | 6 SPs | 0 SPs | Cross-DB → API interna en target |
| `bdicred` | `sd_bitacorabloqueocta` | 1 SPs | 0 SPs | Cross-DB → API interna en target |
| `bdicred` | `sd_definicion` | 4 SPs | 0 SPs | Cross-DB → API interna en target |
| `bdicred` | `` | 9 SPs | 1 SPs | Cross-DB → API interna en target |
| `bdicred` | `sd_tarjeta` | 1 SPs | 0 SPs | Cross-DB → API interna en target |
| `bdidomi` | `` | 0 SPs | 1 SPs | Cross-DB → API interna en target |
| `bdilide` | `` | 2 SPs | 1 SPs | Cross-DB → API interna en target |
| `bdilide` | `sl_retlide` | 0 SPs | 1 SPs | Cross-DB → API interna en target |
| `bdilide` | `sl_detlide` | 0 SPs | 1 SPs | Cross-DB → API interna en target |
| `bdinteg` | `si_cliente` | 9 SPs | 1 SPs | Cross-DB → API interna en target |
| `bdinteg` | `si_param_dom` | 3 SPs | 0 SPs | Cross-DB → API interna en target |
| `bdinteg` | `si_fechas` | 7 SPs | 0 SPs | Cross-DB → API interna en target |
| `bdinteg` | `si_param` | 3 SPs | 0 SPs | Cross-DB → API interna en target |
| `bdinteg` | `` | 36 SPs | 30 SPs | Cross-DB → API interna en target |
| `bdinvers` | `` | 4 SPs | 1 SPs | Cross-DB → API interna en target |
| `bdinvers` | `sv_maeinv` | 5 SPs | 0 SPs | Cross-DB → API interna en target |
| `bdinvers` | `sv_movhis` | 2 SPs | 0 SPs | Cross-DB → API interna en target |
| `bdinvers` | `sv_ctascontinv` | 1 SPs | 0 SPs | Cross-DB → API interna en target |
| `bdinvers` | `sv_movdia` | 1 SPs | 0 SPs | Cross-DB → API interna en target |
| `bdiprog` | `` | 1 SPs | 1 SPs | Cross-DB → API interna en target |
| `bdiprospectos` | `` | 2 SPs | 0 SPs | Cross-DB → API interna en target |
| `bdisac` | `` | 1 SPs | 0 SPs | Cross-DB → API interna en target |
| `bdisac` | `sac_fechas` | 1 SPs | 1 SPs | Cross-DB → API interna en target |
| `bdisitesp` | `se_catsitesp` | 1 SPs | 0 SPs | Cross-DB → API interna en target |
| `bdisitesp` | `se_ctessitespcte_his` | 1 SPs | 1 SPs | Cross-DB → API interna en target |
| `bdisitesp` | `se_ctessitespcte` | 1 SPs | 1 SPs | Cross-DB → API interna en target |
| `bdisitesp` | `` | 1 SPs | 1 SPs | Cross-DB → API interna en target |
| `bdisolic` | `` | 7 SPs | 4 SPs | Cross-DB → API interna en target |
| `bdispeua` | `sp_pagoenviar` | 0 SPs | 3 SPs | Cross-DB → API interna en target |
| `bditarjcop` | `` | 2 SPs | 0 SPs | Cross-DB → API interna en target |
| `bditransfer` | `tf_account_balance_customer` | 1 SPs | 0 SPs | Cross-DB → API interna en target |
| `bditransfer` | `tf_maecte` | 2 SPs | 1 SPs | Cross-DB → API interna en target |
| `bditransfer` | `` | 1 SPs | 0 SPs | Cross-DB → API interna en target |
| `intercard` | `tarjeta` | 2 SPs | 0 SPs | Cross-DB → API interna en target |
| `intercard` | `statustarjeta` | 1 SPs | 0 SPs | Cross-DB → API interna en target |
| `intercard` | `` | 2 SPs | 1 SPs | Cross-DB → API interna en target |
| `sysmaster` | `` | 4 SPs | 0 SPs | Cross-DB → API interna en target |
| `sysmaster` | `sysshmvals` | 5 SPs | 0 SPs | Cross-DB → API interna en target |
| `sysmaster` | `SysTabNames` | 1 SPs | 0 SPs | Cross-DB → API interna en target |
| `sysmaster` | `systabnames` | 1 SPs | 0 SPs | Cross-DB → API interna en target |

## Detalle de columnas — tablas con columnas inferidas

### `si_huella_linea_dec_hist` — Histórico / Archivado

| Columna | Tipo Informix | Tipo PostgreSQL target | PII |
|---------|--------------|----------------------|-----|
| `code_service` | [SME-PENDING] | [SME-PENDING] |  |
| `codret_result` | [SME-PENDING] | [SME-PENDING] |  |
| `desc_result` | VARCHAR(100) | VARCHAR(100) |  |
| `empleado` | [SME-PENDING] | [SME-PENDING] |  |
| `fecha_alta_huella` | DATE | DATE |  |
| `fecha_consulta` | DATE | DATE |  |
| `fecha_env` | DATE | DATE |  |
| `fecha_insert` | DATE | DATE |  |
| `fecha_resp` | DATE | DATE |  |
| `fecha_result` | DATE | DATE |  |
| `fecha_ult_cambio` | DATE | DATE |  |
| `huellas_cap` | [SME-PENDING] | [SME-PENDING] |  |
| `ip` | [SME-PENDING] | [SME-PENDING] |  |
| `match_result` | [SME-PENDING] | [SME-PENDING] |  |
| `num_match_result` | INTEGER | INTEGER |  |

### `si_huella_linea_dec` — Transaccional

| Columna | Tipo Informix | Tipo PostgreSQL target | PII |
|---------|--------------|----------------------|-----|
| `empleado` | [SME-PENDING] | [SME-PENDING] |  |
| `fecha_alta_huella` | DATE | DATE |  |
| `fecha_consulta` | DATE | DATE |  |
| `fecha_insert` | DATE | DATE |  |
| `fecha_ult_cambio` | DATE | DATE |  |
| `huellas_cap` | [SME-PENDING] | [SME-PENDING] |  |
| `ip` | [SME-PENDING] | [SME-PENDING] |  |
| `numcte` | [SME-PENDING] | [SME-PENDING] |  |
| `ref_grupo` | [SME-PENDING] | [SME-PENDING] |  |
| `secuencia` | [SME-PENDING] | [SME-PENDING] |  |
| `sexo` | [SME-PENDING] | [SME-PENDING] |  |
| `status_consulta` | [SME-PENDING] | [SME-PENDING] |  |
| `status_huella` | [SME-PENDING] | [SME-PENDING] |  |
| `sucursal` | [SME-PENDING] | [SME-PENDING] |  |
| `tipo_cliente` | CHAR(4) | CHAR(4) |  |

### `si_tempoconmovfol` — Reportería / Temporal

| Columna | Tipo Informix | Tipo PostgreSQL target | PII |
|---------|--------------|----------------------|-----|
| `codret` | [SME-PENDING] | [SME-PENDING] |  |
| `cuenta` | [SME-PENDING] | [SME-PENDING] |  |
| `desc_transacc` | VARCHAR(100) | VARCHAR(100) |  |
| `ejecutivosif` | [SME-PENDING] | [SME-PENDING] |  |
| `folio` | [SME-PENDING] | [SME-PENDING] |  |
| `importe` | MONEY(16,2) | NUMERIC(16,2) |  |
| `importe_dls` | MONEY(16,2) | NUMERIC(16,2) |  |
| `num_cheque` | INTEGER | INTEGER |  |
| `referencia` | [SME-PENDING] | [SME-PENDING] |  |
| `referencia23` | [SME-PENDING] | [SME-PENDING] |  |
| `saldo` | MONEY(16,2) | NUMERIC(16,2) |  |
| `sbc` | [SME-PENDING] | [SME-PENDING] |  |
| `sistema` | [SME-PENDING] | [SME-PENDING] |  |
| `transacc` | [SME-PENDING] | [SME-PENDING] |  |

### `si_servcte` — Transaccional

| Columna | Tipo Informix | Tipo PostgreSQL target | PII |
|---------|--------------|----------------------|-----|
| `CVE_EMP` | [SME-PENDING] | [SME-PENDING] |  |
| `CVE_SERVICIO` | [SME-PENDING] | [SME-PENDING] |  |
| `EXT_PROMOTOR` | [SME-PENDING] | [SME-PENDING] |  |
| `FECHA_ALTA` | DATE | DATE |  |
| `FECHA_MODIFICACION` | DATE | DATE |  |
| `HORA_MODIFICACION` | [SME-PENDING] | [SME-PENDING] |  |
| `NIP` | [SME-PENDING] | [SME-PENDING] |  |
| `NUMCTE` | [SME-PENDING] | [SME-PENDING] |  |
| `PLAZA` | [SME-PENDING] | [SME-PENDING] |  |
| `REGIONAL` | [SME-PENDING] | [SME-PENDING] |  |
| `STATUS` | [SME-PENDING] | [SME-PENDING] |  |
| `SUCURSAL` | [SME-PENDING] | [SME-PENDING] |  |
| `USUARIO` | [SME-PENDING] | [SME-PENDING] |  |

## Tablas core del dominio (conocimiento de dominio)

| Tabla | Tipo esperado | Notas |
|-------|--------------|-------|
| `si_cliente` | Transaccional | Confirmar existencia y esquema con DBA |
| `si_ejecutivo` | Transaccional | Confirmar existencia y esquema con DBA |
| `si_perfil` | Transaccional | Confirmar existencia y esquema con DBA |
| `si_sucursales` | Transaccional | Confirmar existencia y esquema con DBA |
| `si_ciudades` | Transaccional | Confirmar existencia y esquema con DBA |
| `si_estados` | Transaccional | Confirmar existencia y esquema con DBA |
| `si_colonia` | Transaccional | Confirmar existencia y esquema con DBA |

## Pendientes Etapa 2

```sql
-- Ejecutar en instancia Informix `bdinteg` para obtener schema real:
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
*Generado por: Specialist — Informix SPL Analysis · 2026-07-03 · Evidencia: source/LegacyCore/informix/bdinteg_*.sql (análisis estático de 70 archivos SQL) · análisis estático de archivos SQL*

# SP Specs — D12 · `bdicont` · Contabilidad

> Generado por `build-sp-specs.py` · Grounding Pass v1.0
> Objetivo: verificar el conocimiento del Gemelo Cognitivo contra el código fuente real
> **Convención:** solo se analiza el PRIMER `CREATE PROCEDURE` de cada archivo
> (los siguientes son dependencias concatenadas — ver memoria del proyecto)

## Resumen de validación del dominio

| Métrica | Valor |
|---------|-------|
| SPs analizados | **168** |
| Presentes en callgraph | 19 |
| SPs aislados (⚠️ no estaban en el análisis previo) | 149 |
| Propósito **VERIFICADO** | 54 |
| Propósito **PARCIAL** | 106 |
| Propósito **NO_VERIFICABLE** | 8 |
| SPs con tokens **SINTÉTICOS** detectados | 122 |

> Los **149 SPs aislados** no aparecen en el callgraph y por tanto
> **no fueron incluidos en el análisis de journeys, reglas ni vocabulario previo**.
> Este grounding pass los analiza por primera vez directamente desde el código.

---

## `act_encab_ant`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_act_encab_ant.sql` |
| **LOC (1er CREATE)** | 69 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "actualiza (anterior)" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `actualiza` → `UPDATE` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=1 / 3 términos |

### Firma

```sql
CREATE PROCEDURE act_encab_ant(
  pempresa                     char(3)
  pusuario                     char(8)
  pfecha_hoy                   date
  pcontrol_poliza              integer
) RETURNING char(3)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pempresa` | `char(3)` | — | — |
| `pusuario` | `char(8)` | — | — |
| `pfecha_hoy` | `date` | — | — |
| `pcontrol_poliza` | `integer` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cod_ret` | `char(3)` | L4 |
| `v_moneda` | `char(2)` | L5 |
| `v_descripcion` | `char(40)` | L6 |
| `v_monto` | `money(14,2)` | L7 |
| `v_naturaleza` | `char(1)` | L8 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `co_detpol` | `bdicont` | no | SELECT | L29 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L20 | VALIDACIÓN_NULL | `if pusuario    is null  or` |  |
| L35 | VALIDACIÓN_NULL | `if v_monto is null then` |  |
| L38 | VALIDACIÓN_NULL | `if v_moneda is null then` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `act` | ACCION | actualiza | 🔵 CONVENCIÓN | nombre_sp |
| `?_encab_` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `ant` | MODIF | anterior | 🔵 CONVENCIÓN | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_encab_` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `act_hist`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_act_hist.sql` |
| **LOC (1er CREATE)** | 129 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "actualiza (histórico/historial)" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `actualiza` → `UPDATE` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=0 / 2 términos |

### Firma

```sql
CREATE PROCEDURE act_hist(
  pempresa                     char(3)
) RETURNING CHAR(5)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pempresa` | `char(3)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `sql_err` | `INTEGER` | L4 |
| `cod_ret` | `char(5)` | L6 |
| `vmoneda` | `char(2)` | L9 |
| `v_ciudad` | `char(3)` | L10 |
| `vsucursal` | `char(4)` | L11 |
| `v_empresa` | `char(3)` | L12 |
| `vnro_auxiliar` | `char(12)` | L14 |
| `vdescripcion` | `char(50)` | L15 |
| `vsecuencia` | `integer` | L18 |
| `vcontrol_poliza` | `integer` | L19 |
| `v_fecha_hoy` | `date` | L20 |
| `vccost_orig` | `char (4)` | L21 |
| `vcontador` | `INTEGER` | L22 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `co_fechas` | `bdicont` | no | SELECT | L36 |
| `co_cierre_cif` | `bdicont` | no | SELECT | L39 |
| `systables` | `bdicont` | no | SELECT | L49 |
| `co_mensual` | `bdicont` | no | SELECT | L93 |
| `co_historico_tmp` | `bdicont` | no | INSERT | L100 |
| `statistics` | `bdicont` | no | UPDATE | L123 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L111 | FÓRMULA | `LET vcontador = vcontador + 1 ;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `act` | ACCION | actualiza | 🔵 CONVENCIÓN | nombre_sp |
| `hist` | MODIF | histórico/historial | 🔵 CONVENCIÓN | nombre_sp |

---

## `act_histsdos`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_act_histsdos.sql` |
| **LOC (1er CREATE)** | 249 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "actualiza saldos (histórico/historial)" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `actualiza` → `UPDATE` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=2 · INFERIDO=1 · SINTÉTICO=0 / 3 términos |

### Firma

```sql
CREATE PROCEDURE act_histsdos(
  pempresa                     char(3)
  pfecha_hoy                   date
) RETURNING char(5)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pempresa` | `char(3)` | — | — |
| `pfecha_hoy` | `date` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `sql_err` | `INTEGER` | L4 |
| `cod_ret` | `char(3)` | L6 |
| `hempresa` | `char(3)` | L7 |
| `hccmayor` | `char(10)` | L8 |
| `hccsub` | `char(10)` | L9 |
| `hccsubsub` | `char(10)` | L10 |
| `hccssubsub` | `char(10)` | L11 |
| `hccsssubsub` | `char(10)` | L12 |
| `hsector` | `char(10)` | L13 |
| `hciudad` | `char(3)` | L14 |
| `hsucursal` | `char(4)` | L15 |
| `hmoneda` | `char(2)` | L16 |
| `hmes_dia` | `date` | L17 |
| `hcargos_dia` | `money(18,2)` | L18 |
| `habonos_dia` | `money(18,2)` | L19 |
| `hnro_cargos_dia` | `integer` | L20 |
| `hnro_abonos_dia` | `integer` | L21 |
| `hdias_proyectado` | `smallint` | L22 |
| `hdias_acumulado` | `smallint` | L23 |
| `hsaldo_acumulado` | `money(18,2)` | L24 |
| `hsaldo_inicio_dia` | `money(18,2)` | L25 |
| `hsaldo_fin_de_dia` | `money(18,2)` | L26 |
| `haempresa` | `char(3)` | L28 |
| `haccmayor` | `char(10)` | L29 |
| `haccsub` | `char(10)` | L30 |
| *…19 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `co_fechas` | `bdicont` | no | SELECT | L63 |
| `co_cierre_cif` | `bdicont` | no | SELECT | L66 |
| `systables` | `bdicont` | no | SELECT | L75 |
| `co_sdodias` | `bdicont` | no | SELECT | L125 |
| `statistics` | `bdicont` | no | UPDATE | L172 |
| `co_diasaux` | `bdicont` | no | SELECT | L200 |
| `co_histdiasaux` | `bdicont` | no | INSERT | L208 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L160 | FÓRMULA | `LET vcontador = vcontador + 1 ;` |  |
| L235 | FÓRMULA | `LET vcontador = vcontador + 1 ;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `act` | ACCION | actualiza | 🔵 CONVENCIÓN | nombre_sp |
| `hist` | MODIF | histórico/historial | 🔵 CONVENCIÓN | nombre_sp |
| `sdos` | ENTIDAD | saldos (abreviación) | 🟡 INFERIDO | nombre_sp |

---

## `act_mens`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_act_mens.sql` |
| **LOC (1er CREATE)** | 79 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "actualiza" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 5 tabla(s) con operaciones: SELECT, INSERT |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=1 / 2 términos |

### Firma

```sql
CREATE PROCEDURE act_mens(
  pempresa                     CHAR(3)
) RETURNING CHAR(5)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pempresa` | `CHAR(3)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `sql_err` | `INTEGER` | L4 |
| `cod_ret` | `char(5)` | L6 |
| `vmoneda` | `char(2)` | L9 |
| `vciudad` | `char(3)` | L10 |
| `vsucursal` | `char(4)` | L11 |
| `v_empresa` | `char(3)` | L12 |
| `vnro_auxiliar` | `char(12)` | L14 |
| `vdescripcion` | `char(50)` | L15 |
| `vmonto` | `money(18,2)` | L16 |
| `vccosto_orig` | `char(4)` | L21 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `co_fechas` | `bdicont` | no | SELECT | L33 |
| `co_cierre_cif` | `bdicont` | no | SELECT | L36 |
| `co_diario` | `bdicont` | no | SELECT | L56 |
| `co_mensual` | `bdicont` | no | INSERT | L60 |
| `co_historico` | `bdicont` | no | INSERT | L67 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `act` | ACCION | actualiza | 🔵 CONVENCIÓN | nombre_sp |
| `?_mens` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_mens` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `act_sdodias`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_act_sdodias.sql` |
| **LOC (1er CREATE)** | 122 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "actualiza saldo (del día)" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 6 tabla(s) con operaciones: SELECT, INSERT |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=1 / 4 términos |

### Firma

```sql
CREATE PROCEDURE act_sdodias(
  pempresa                     char(3)
  pfecha_hoy                   date
) RETURNING CHAR(5)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pempresa` | `char(3)` | — | — |
| `pfecha_hoy` | `date` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `sql_err` | `INTEGER` | L4 |
| `cod_ret` | `char(5)` | L6 |
| `vmoneda` | `char(2)` | L8 |
| `vciudad` | `char(3)` | L9 |
| `vsucursal` | `char(4)` | L10 |
| `v_empresa` | `char(3)` | L11 |
| `vnro_auxiliar` | `char(12)` | L12 |
| `v_auxiliar` | `char(1)` | L13 |
| `v_cuantos` | `integer` | L14 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `co_cierre_cif` | `bdicont` | no | SELECT | L23 |
| `co_diario` | `bdicont` | no | SELECT | L43 |
| `co_sdodias` | `bdicont` | no | SELECT | L56 |
| `co_sdodias` | `bdicont` | no | INSERT | L70 |
| `co_diasaux` | `bdicont` | no | SELECT | L87 |
| `co_diasaux` | `bdicont` | no | INSERT | L102 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `act` | ACCION | actualiza | 🔵 CONVENCIÓN | nombre_sp |
| `sdo` | ENTIDAD | saldo | 🔵 CONVENCIÓN | nombre_sp |
| `dia` | MODIF | del día | 🔵 CONVENCIÓN | nombre_sp |
| `?s` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?s` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `act_sdom`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_act_sdom.sql` |
| **LOC (1er CREATE)** | 209 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "actualiza saldo" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `actualiza` → `UPDATE` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=1 / 3 términos |

### Firma

```sql
CREATE PROCEDURE act_sdom(
  v_empresa                    char(3)
) RETURNING char(5)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `v_empresa` | `char(3)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `sql_err` | `INTEGER` | L4 |
| `cod_ret` | `char(5)` | L6 |
| `vciudad` | `char(3)` | L9 |
| `vsucursal` | `char(4)` | L10 |
| `lv_dias_acum` | `integer` | L17 |
| `vanio_mes` | `char(7)` | L20 |
| `lv_dias` | `integer` | L22 |
| `vcontador` | `INTEGER` | L23 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `co_fechas` | `bdicont` | no | SELECT | L38 |
| `co_cierre_cif` | `bdicont` | no | SELECT | L41 |
| `co_sdodias` | `bdicont` | no | SELECT | L62 |
| `co_sdomes` | `bdicont` | no | INSERT | L87 |
| `statistics` | `bdicont` | no | UPDATE | L95 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L50 | VALIDACIÓN_NULL | `IF vw_fecha_hoy IS NULL THEN` |  |
| L58 | FÓRMULA | `LET vanio_mes = year(vw_fecha_hoy)\|\| "-" \|\| v_mes;` |  |
| L98 | FÓRMULA | `LET vcontador = vcontador + 1 ;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `act` | ACCION | actualiza | 🔵 CONVENCIÓN | nombre_sp |
| `sdo` | ENTIDAD | saldo | 🔵 CONVENCIÓN | nombre_sp |
| `?m` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?m` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `act_sdomux`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_act_sdomux.sql` |
| **LOC (1er CREATE)** | 205 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "actualiza saldo" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `actualiza` → `UPDATE` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=1 / 4 términos |

### Firma

```sql
CREATE PROCEDURE act_sdomux(
  v_empresa                    char(4)
) RETURNING char(5)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `v_empresa` | `char(4)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `sql_err` | `INTEGER` | L4 |
| `cod_ret` | `char(5)` | L6 |
| `lv_auxiliar` | `char(12)` | L7 |
| `vciudad` | `char(3)` | L10 |
| `vsucursal` | `char(4)` | L11 |
| `lv_dias_acum` | `integer` | L16 |
| `vanio_mes` | `char(7)` | L18 |
| `vcontador` | `INTEGER` | L20 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `co_fechas` | `bdicont` | no | SELECT | L33 |
| `co_cierre_cif` | `bdicont` | no | SELECT | L36 |
| `co_diasaux` | `bdicont` | no | SELECT | L57 |
| `co_mesaux` | `bdicont` | no | INSERT | L80 |
| `statistics` | `bdicont` | no | UPDATE | L89 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L45 | VALIDACIÓN_NULL | `IF vw_fecha_hoy IS null then` |  |
| L53 | FÓRMULA | `LET vanio_mes = year(vw_fecha_hoy)\|\| "-" \|\| v_mes;` |  |
| L92 | FÓRMULA | `LET vcontador = vcontador + 1 ;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `act` | ACCION | actualiza | 🔵 CONVENCIÓN | nombre_sp |
| `sdo` | ENTIDAD | saldo | 🔵 CONVENCIÓN | nombre_sp |
| `?mu` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `x` | MODIF | por (criterio) | 🔵 CONVENCIÓN | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?mu` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `actualizarpasesuc`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_actualizarpasesuc.sql` |
| **LOC (1er CREATE)** | 53 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "actualiza (sucursal)" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `actualiza` → `UPDATE` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=2 · INFERIDO=1 · SINTÉTICO=1 / 4 términos |

### Historia del SP

| Tipo | Valor |
|------|-------|
| FECHA | 16/04/2009 |

### Firma

```sql
CREATE PROCEDURE actualizarpasesuc(
  pEmpresa                     CHAR(3)
  pFechaValor                  DATE
  pSucursal                    CHAR(4)
  pFechaCaptura                DATE
) RETURNING VARCHAR(5)         -- CodigoRetorno
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pEmpresa` | `CHAR(3)` | — | — |
| `pFechaValor` | `DATE` | — | — |
| `pSucursal` | `CHAR(4)` | `suc`=sucursal | 🟡 INFERIDO |
| `pFechaCaptura` | `DATE` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cVarDataErr` | `VARCHAR(255)` | L20 |
| `iSqlErr` | `INTEGER` | L21 |
| `iSamErr` | `INTEGER` | L22 |
| `cCodRet` | `CHAR(5)` | L24 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L40 | VALIDACIÓN_NULL | `IF pFechaValor IS NULL OR pEmpresa IS NULL OR pEmpresa = '' OR` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `actualiza` | ACCION | actualiza | 🔵 CONVENCIÓN | nombre_sp |
| `?r` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `pase` | ACCION | pase contable (registra/traslada a póliza o mayor) | 🔵 CONVENCIÓN | nombre_sp |
| `suc` | MODIF | sucursal | 🟡 INFERIDO | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?r` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `acumdias`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_acumdias.sql` |
| **LOC (1er CREATE)** | 15 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "(del día)" `[partial]` |
| **Propósito verificado** | ❓ NO_VERIFICABLE — Propósito inferido; sin evidencia DML para verificar |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=2 / 3 términos |

### Firma

```sql
CREATE PROCEDURE acumdias(
  v_fecha                      date
  v_fecval                     date
) RETURNING smallint
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `v_fecha` | `date` | — | — |
| `v_fecval` | `date` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `v_dias` | `smallint` | L4 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L8 | FÓRMULA | `let v_dias = day(v_fecha) - day(v_fecval) + 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `?acum` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `dia` | MODIF | del día | 🔵 CONVENCIÓN | nombre_sp |
| `?s` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?acum`, `?s` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `auditapase_ant`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_auditapase_ant.sql` |
| **LOC (1er CREATE)** | 386 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "pase contable auditoría (anterior)" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 1 llamada(s): `act_encab_ant` |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=2 · INFERIDO=1 · SINTÉTICO=1 / 4 términos |

### Firma

```sql
CREATE PROCEDURE auditapase_ant(
  pfecha_trab                  date
  pempresa                     char(3)
  pusuario                     char(8)
) RETURNING char(5)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pfecha_trab` | `date` | — | — |
| `pempresa` | `char(3)` | — | — |
| `pusuario` | `char(8)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vproceso` | `char(20)` | L4 |
| `w_cod_ret` | `char(5)` | L5 |
| `tmousuario` | `char(8)` | L6 |
| `tmocontrol_poliza` | `integer` | L7 |
| `tmofecha_captura` | `date` | L8 |
| `tmosecuencia` | `integer` | L9 |
| `tmoempresa` | `char(3)` | L10 |
| `tmoccmayor` | `char(4)` | L11 |
| `tmoccsub` | `char(2)` | L12 |
| `tmoccsubsub` | `char(2)` | L13 |
| `tmoccssubsub` | `char(2)` | L14 |
| `tmoccsssubsub` | `char(2)` | L15 |
| `tmosector` | `char(2)` | L16 |
| `tmociudad` | `char(3)` | L17 |
| `tmosucursal` | `char(4)` | L18 |
| `tmocentro_costo` | `char(4)` | L19 |
| `tmonro_auxiliar` | `char(12)` | L20 |
| `tmonaturaleza` | `char(1)` | L21 |
| `tmomonto` | `money(18,2)` | L22 |
| `tmodescripcion_det` | `char(50)` | L23 |
| `tmofecha_valida` | `date` | L24 |
| `tmomoneda` | `char(2)` | L25 |
| `tmovalor_cambio` | `money(12,7)` | L26 |
| `tmovalor_div_cambio` | `money(12,7)` | L27 |
| `tmomca_aplic` | `char(1)` | L28 |
| *…13 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `co_auditpase` | `bdicont` | no | SELECT | L56 |
| `co_auditpase` | `bdicont` | no | DELETE | L56 |
| `co_detpol` | `bdicont` | no | SELECT | L61 |
| `co_detpol` | `bdicont` | no | DELETE | L61 |
| `co_poliza` | `bdicont` | no | SELECT | L66 |
| `co_poliza` | `bdicont` | no | DELETE | L66 |
| `co_ctrlpoliza` | `bdicont` | no | SELECT | L136 |
| `co_poldet` | `bdicont` | no | SELECT | L160 |
| `co_ctrlpoliza` | `bdicont` | no | UPDATE | L168 |
| `co_poliza` | `bdicont` | no | INSERT | L171 |
| `si_ejecut` | `bdinteg` | ⚠️ sí | SELECT | L264 |
| `si_regional` | `bdinteg` | ⚠️ sí | SELECT | L312 |
| `co_detpol` | `bdicont` | no | INSERT | L333 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `act_encab_ant` | `bdicont` | no | L380 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L114 | VALIDACIÓN_NULL | `IF (v_creditos IS NULL) THEN` |  |
| L118 | VALIDACIÓN_NULL | `IF (v_debitos is null) then` |  |
| L167 | FÓRMULA | `LET tmocontrol_poliza = tmocontrol_poliza + 1;` |  |
| L196 | VALIDACIÓN_NULL | `IF (v_tipo_cuenta IS NULL) THEN` |  |
| L252 | VALIDACIÓN_NULL | `IF (v_aux is null) THEN` |  |
| L299 | VALIDACIÓN_NULL | `IF (v_sucursal is null) THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `aud` | ENTIDAD | auditoría | 🟡 INFERIDO | nombre_sp |
| `?ita` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `pase` | ACCION | pase contable (registra/traslada a póliza o mayor) | 🔵 CONVENCIÓN | nombre_sp |
| `ant` | MODIF | anterior | 🔵 CONVENCIÓN | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?ita` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `auxiliares2`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_auxiliares2.sql` |
| **LOC (1er CREATE)** | 539 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "auxiliar contable — sub-ledger contable" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 6 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=0 · INFERIDO=0 · SINTÉTICO=1 / 2 términos |

### Firma

```sql
CREATE PROCEDURE auxiliares2(
  pempresa                     char(3)
  pccmayor                     char(4)
  pccsub                       char(2)
  pccsubsub                    char(2)
  pccssubsub                   char(2)
  pccsssubsub                  char(2)
  psector                      char(2)
  pmoneda                      char(2)
  psucursal                    char(4)
  pnro_auxiliar                char(12)
  pciudad                      char(3)
)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pempresa` | `char(3)` | — | — |
| `pccmayor` | `char(4)` | — | — |
| `pccsub` | `char(2)` | — | — |
| `pccsubsub` | `char(2)` | — | — |
| `pccssubsub` | `char(2)` | — | — |
| `pccsssubsub` | `char(2)` | — | — |
| `psector` | `char(2)` | — | — |
| `pmoneda` | `char(2)` | — | — |
| `psucursal` | `char(4)` | — | — |
| `pnro_auxiliar` | `char(12)` | `auxiliar`=auxiliar contable — sub-ledger contable (sdos_auxiliar, sp_validaauxiliar) | ✅ CÓDIGO |
| `pciudad` | `char(3)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vciudad` | `char(3)` | L8 |
| `w_empresa` | `char(3)` | L9 |
| `vusuario` | `char(8)` | L10 |
| `vpoliza_usuario` | `char(8)` | L11 |
| `vdescripcion` | `char(50)` | L12 |
| `vmonto` | `money(14,2)` | L13 |
| `v_rowid` | `integer` | L19 |
| `pfecha_hoy1` | `date` | L20 |
| `vexiste` | `integer` | L21 |
| `vccosto_orig` | `char(4)` | L22 |
| `vcargos_dia` | `money(18,2)` | L23 |
| `vabonos_dia` | `money(18,2)` | L24 |
| `vnro_cargos_dia` | `integer` | L25 |
| `vnro_abonos_dia` | `integer` | L26 |
| `vdias_proyectado` | `integer` | L27 |
| `vdias_acumulados` | `integer` | L28 |
| `vsaldo_acumulado` | `money(18,2)` | L29 |
| `vsaldo_inicio_dia` | `money(18,2)` | L30 |
| `vsaldo_fin_de_dia` | `money(18,2)` | L31 |
| `vsuma_carabo` | `money(18,2)` | L32 |
| `vmes_dia` | `date` | L33 |
| `vfecha_sig` | `date` | L34 |
| `vsaldo_inicio` | `money(18,2)` | L35 |
| `vcar_dia` | `money(18,2)` | L36 |
| `vabo_dia` | `money(18,2)` | L37 |
| *…19 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_catalog` | `bdinteg` | ⚠️ sí | SELECT | L74 |
| `co_historico` | `bdicont` | no | SELECT | L86 |
| `co_fechas` | `bdicont` | no | SELECT | L104 |
| `co_mensual` | `bdicont` | no | SELECT | L144 |
| `co_histdiasaux` | `bdicont` | no | SELECT | L215 |
| `co_diasaux` | `bdicont` | no | SELECT | L416 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L185 | VALIDACIÓN_NULL | `if vfecha_sig is null then` |  |
| L202 | VALIDACIÓN_NULL | `if vfecha_sig is null then let vfecha_sig = vmes_dia; end if;` |  |
| L203 | FÓRMULA | `let vdias_acum = vfecha_sig - vmes_dia;` |  |
| L205 | FÓRMULA | `let vsaldo_fin_de_diar = vsaldo_inicio_diar + (vmonto_cargos - vmonto_abonos);` | 🔴 MONEY/aritmética financiera |
| L206 | FÓRMULA | `let vsaldo_acumulado = vmonto_cargos - vmonto_abonos;` | 🔴 MONEY/aritmética financiera |
| L208 | FÓRMULA | `let vsaldo_fin_de_diar = vsaldo_inicio_diar + (vmonto_abonos - vmonto_cargos);` | 🔴 MONEY/aritmética financiera |
| L209 | FÓRMULA | `let vsaldo_acumulado = vmonto_abonos - vmonto_cargos;` | 🔴 MONEY/aritmética financiera |
| L211 | FÓRMULA | `let vsaldo_acumulado = vsaldo_acumulado * vdias_acum;}` |  |
| L229 | VALIDACIÓN_NULL | `if vsaldo_inicio is null then` |  |
| L234 | FÓRMULA | `let vsaldo_fin_de_diar = vsaldo_inicio + (vmonto_cargos - vmonto_abonos);` | 🔴 MONEY/aritmética financiera |
| L235 | FÓRMULA | `let vsaldo_acumulado = vmonto_cargos - vmonto_abonos;` | 🔴 MONEY/aritmética financiera |
| L237 | FÓRMULA | `let vsaldo_fin_de_diar = vsaldo_inicio + (vmonto_abonos - vmonto_cargos);` | 🔴 MONEY/aritmética financiera |
| L238 | FÓRMULA | `let vsaldo_acumulado = vmonto_abonos - vmonto_cargos;` | 🔴 MONEY/aritmética financiera |
| L332 | VALIDACIÓN_NULL | `if vsaldo_acumulado_diar is null then` |  |
| L394 | VALIDACIÓN_NULL | `if vsaldo_acumulado_diar is null then` |  |
| L430 | VALIDACIÓN_NULL | `if vsaldo_inicio is null then` |  |
| L434 | FÓRMULA | `let vsaldo_fin_de_diar = vsaldo_inicio + (vmonto_cargos - vmonto_abonos);` | 🔴 MONEY/aritmética financiera |
| L435 | FÓRMULA | `let vsaldo_acumulado = vmonto_cargos - vmonto_abonos;` | 🔴 MONEY/aritmética financiera |
| L437 | FÓRMULA | `let vsaldo_fin_de_diar = vsaldo_inicio + (vmonto_abonos - vmonto_cargos);` | 🔴 MONEY/aritmética financiera |
| L438 | FÓRMULA | `let vsaldo_acumulado = vmonto_abonos - vmonto_cargos;` | 🔴 MONEY/aritmética financiera |
| L440 | FÓRMULA | `let vsaldo_acumulado = vsaldo_acumulado * vdias_acum;` |  |
| L516 | VALIDACIÓN_NULL | `if vsaldo_acumulado_diar is null then` |  |
| L536 | FÓRMULA | `let vfecha_inicio = vfecha_inicio + 1 UNITS DAY;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `auxiliar` | ENTIDAD | auxiliar contable — sub-ledger contable (sdos_auxiliar, sp_v | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `?es2` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?es2` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `auxiliares3`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_auxiliares3.sql` |
| **LOC (1er CREATE)** | 539 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "auxiliar contable — sub-ledger contable" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 6 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=0 · INFERIDO=0 · SINTÉTICO=1 / 2 términos |

### Firma

```sql
CREATE PROCEDURE auxiliares3(
  pempresa                     char(3)
  pccmayor                     char(4)
  pccsub                       char(2)
  pccsubsub                    char(2)
  pccssubsub                   char(2)
  pccsssubsub                  char(2)
  psector                      char(2)
  pmoneda                      char(2)
  psucursal                    char(4)
  pnro_auxiliar                char(12)
  pciudad                      char(3)
)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pempresa` | `char(3)` | — | — |
| `pccmayor` | `char(4)` | — | — |
| `pccsub` | `char(2)` | — | — |
| `pccsubsub` | `char(2)` | — | — |
| `pccssubsub` | `char(2)` | — | — |
| `pccsssubsub` | `char(2)` | — | — |
| `psector` | `char(2)` | — | — |
| `pmoneda` | `char(2)` | — | — |
| `psucursal` | `char(4)` | — | — |
| `pnro_auxiliar` | `char(12)` | `auxiliar`=auxiliar contable — sub-ledger contable (sdos_auxiliar, sp_validaauxiliar) | ✅ CÓDIGO |
| `pciudad` | `char(3)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vciudad` | `char(3)` | L8 |
| `w_empresa` | `char(3)` | L9 |
| `vusuario` | `char(8)` | L10 |
| `vpoliza_usuario` | `char(8)` | L11 |
| `vdescripcion` | `char(50)` | L12 |
| `vmonto` | `money(14,2)` | L13 |
| `v_rowid` | `integer` | L19 |
| `pfecha_hoy1` | `date` | L20 |
| `vexiste` | `integer` | L21 |
| `vccosto_orig` | `char(4)` | L22 |
| `vcargos_dia` | `money(18,2)` | L23 |
| `vabonos_dia` | `money(18,2)` | L24 |
| `vnro_cargos_dia` | `integer` | L25 |
| `vnro_abonos_dia` | `integer` | L26 |
| `vdias_proyectado` | `integer` | L27 |
| `vdias_acumulados` | `integer` | L28 |
| `vsaldo_acumulado` | `money(18,2)` | L29 |
| `vsaldo_inicio_dia` | `money(18,2)` | L30 |
| `vsaldo_fin_de_dia` | `money(18,2)` | L31 |
| `vsuma_carabo` | `money(18,2)` | L32 |
| `vmes_dia` | `date` | L33 |
| `vfecha_sig` | `date` | L34 |
| `vsaldo_inicio` | `money(18,2)` | L35 |
| `vcar_dia` | `money(18,2)` | L36 |
| `vabo_dia` | `money(18,2)` | L37 |
| *…19 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_catalog` | `bdinteg` | ⚠️ sí | SELECT | L74 |
| `co_historico` | `bdicont` | no | SELECT | L86 |
| `co_fechas` | `bdicont` | no | SELECT | L104 |
| `co_mensual` | `bdicont` | no | SELECT | L144 |
| `co_histdiasaux` | `bdicont` | no | SELECT | L215 |
| `co_diasaux` | `bdicont` | no | SELECT | L416 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L185 | VALIDACIÓN_NULL | `if vfecha_sig is null then` |  |
| L202 | VALIDACIÓN_NULL | `if vfecha_sig is null then let vfecha_sig = vmes_dia; end if;` |  |
| L203 | FÓRMULA | `let vdias_acum = vfecha_sig - vmes_dia;` |  |
| L205 | FÓRMULA | `let vsaldo_fin_de_diar = vsaldo_inicio_diar + (vmonto_cargos - vmonto_abonos);` | 🔴 MONEY/aritmética financiera |
| L206 | FÓRMULA | `let vsaldo_acumulado = vmonto_cargos - vmonto_abonos;` | 🔴 MONEY/aritmética financiera |
| L208 | FÓRMULA | `let vsaldo_fin_de_diar = vsaldo_inicio_diar + (vmonto_abonos - vmonto_cargos);` | 🔴 MONEY/aritmética financiera |
| L209 | FÓRMULA | `let vsaldo_acumulado = vmonto_abonos - vmonto_cargos;` | 🔴 MONEY/aritmética financiera |
| L211 | FÓRMULA | `let vsaldo_acumulado = vsaldo_acumulado * vdias_acum;}` |  |
| L229 | VALIDACIÓN_NULL | `if vsaldo_inicio is null then` |  |
| L234 | FÓRMULA | `let vsaldo_fin_de_diar = vsaldo_inicio + (vmonto_cargos - vmonto_abonos);` | 🔴 MONEY/aritmética financiera |
| L235 | FÓRMULA | `let vsaldo_acumulado = vmonto_cargos - vmonto_abonos;` | 🔴 MONEY/aritmética financiera |
| L237 | FÓRMULA | `let vsaldo_fin_de_diar = vsaldo_inicio + (vmonto_abonos - vmonto_cargos);` | 🔴 MONEY/aritmética financiera |
| L238 | FÓRMULA | `let vsaldo_acumulado = vmonto_abonos - vmonto_cargos;` | 🔴 MONEY/aritmética financiera |
| L332 | VALIDACIÓN_NULL | `if vsaldo_acumulado_diar is null then` |  |
| L394 | VALIDACIÓN_NULL | `if vsaldo_acumulado_diar is null then` |  |
| L430 | VALIDACIÓN_NULL | `if vsaldo_inicio is null then` |  |
| L434 | FÓRMULA | `let vsaldo_fin_de_diar = vsaldo_inicio + (vmonto_cargos - vmonto_abonos);` | 🔴 MONEY/aritmética financiera |
| L435 | FÓRMULA | `let vsaldo_acumulado = vmonto_cargos - vmonto_abonos;` | 🔴 MONEY/aritmética financiera |
| L437 | FÓRMULA | `let vsaldo_fin_de_diar = vsaldo_inicio + (vmonto_abonos - vmonto_cargos);` | 🔴 MONEY/aritmética financiera |
| L438 | FÓRMULA | `let vsaldo_acumulado = vmonto_abonos - vmonto_cargos;` | 🔴 MONEY/aritmética financiera |
| L440 | FÓRMULA | `let vsaldo_acumulado = vsaldo_acumulado * vdias_acum;` |  |
| L516 | VALIDACIÓN_NULL | `if vsaldo_acumulado_diar is null then` |  |
| L536 | FÓRMULA | `let vfecha_inicio = vfecha_inicio + 1 UNITS DAY;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `auxiliar` | ENTIDAD | auxiliar contable — sub-ledger contable (sdos_auxiliar, sp_v | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `?es3` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?es3` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `cancela_resultados`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_cancela_resultados.sql` |
| **LOC (1er CREATE)** | 797 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 1 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "cancela resultado" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 2 llamada(s): `sdos_sin_auxiliar`, `sdos_auxiliar` |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=1 / 3 términos |

### Firma

```sql
CREATE PROCEDURE cancela_resultados(
  p_empresa                    CHAR(3)
) RETURNING CHAR(5)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_empresa` | `CHAR(3)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `codret` | `CHAR(5)` | L4 |
| `sql_err` | `SMALLINT` | L5 |
| `isam_err` | `SMALLINT` | L6 |
| `error_info` | `CHAR(40)` | L7 |
| `GLOBAL` | `v_fecha_hoy		DATE DEFAULT ""` | L8 |
| `GLOBAL` | `v_fecha_ant            DATE DEFAULT ""` | L9 |
| `GLOBAL` | `v_fecha_canc           CHAR(10) DEFAULT ""` | L10 |
| `GLOBAL` | `v_prox_fecha  	 	DATE DEFAULT ""` | L11 |
| `v_pri_hab_mes` | `DATE` | L12 |
| `v_pri_dia_mes` | `DATE` | L13 |
| `v_begin` | `CHAR(1)` | L14 |
| `v_mescierre1` | `CHAR(2)` | L20 |
| `v_mescierre2` | `CHAR(2)` | L21 |
| `v_moneda_nacional` | `CHAR(2)` | L22 |
| `v_anio_fiscal` | `CHAR(2)` | L23 |
| `v_cta_ing_inic` | `CHAR(10)` | L24 |
| `v_cta_ing_final` | `CHAR(10)` | L25 |
| `v_cta_gto_inic` | `CHAR(10)` | L26 |
| `v_cta_gto_final` | `CHAR(10)` | L27 |
| `v_per_gan_mayor` | `CHAR(10)` | L28 |
| `v_per_gan_sub` | `CHAR(10)` | L29 |
| `v_per_gan_ss` | `CHAR(10)` | L30 |
| `v_per_gan_sss` | `CHAR(10)` | L31 |
| `v_per_gan_ssss` | `CHAR(10)` | L32 |
| `v_per_gan_sect` | `CHAR(10)` | L33 |
| *…29 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_sucursales` | `bdinteg` | ⚠️ sí | SELECT | L106 |
| `co_cance` | `bdicont` | no | SELECT | L196 |
| `co_cance` | `bdicont` | no | DELETE | L196 |
| `co_ctrlpoliza` | `bdicont` | no | SELECT | L784 |
| `co_ctrlpoliza` | `bdicont` | no | DELETE | L784 |
| `co_ctrlpoliza` | `bdicont` | no | INSERT | L785 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sdos_sin_auxiliar` | `bdicont` | no | L243 |
| `sdos_auxiliar` | `bdicont` | no | L257 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L327 | FÓRMULA | `LET v_diferencia = v_cargos - v_abonos;` |  |
| L370 | FÓRMULA | `LET v_diferencia = v_abonos - v_cargos;` |  |
| L555 | FÓRMULA | `LET v_sdo_fin = v_sdo_inic + v_cargos - v_abonos;` |  |
| L557 | FÓRMULA | `LET v_sdo_fin = v_sdo_inic + v_abonos - v_cargos;` |  |
| L563 | FÓRMULA | `LET v_sdo_fin = v_sdo_inic + v_cargos - v_abonos;` |  |
| L565 | FÓRMULA | `LET v_sdo_fin = v_sdo_inic + v_abonos - v_cargos;` |  |
| L704 | FÓRMULA | `LET v_dia_acum = v_dia_acum + 1;` |  |
| L705 | FÓRMULA | `LET v_sdo_acum = v_sdo_acum + v_sdo_fin;` |  |
| L768 | FÓRMULA | `LET v_fecha = v_fecha + 1 UNITS DAY;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `cancela` | ACCION | cancela | 🔵 CONVENCIÓN | nombre_sp |
| `resultado` | ENTIDAD | resultado | 🔵 CONVENCIÓN | nombre_sp |
| `?s` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?s` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `carga_diaria`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_carga_diaria.sql` |
| **LOC (1er CREATE)** | 290 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "carga (del día)" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 18 tabla(s) con operaciones: INSERT, SELECT, DELETE |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=0 · INFERIDO=0 · SINTÉTICO=1 / 3 términos |

### Firma

```sql
CREATE PROCEDURE carga_diaria(
  pempresa                     char(3)
  pfecha_hoy                   date
) RETURNING char(5)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pempresa` | `char(3)` | — | — |
| `pfecha_hoy` | `date` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cod_ret` | `char(5)` | L12 |
| `w_dd` | `char(2)` | L13 |
| `w_dd2` | `char(2)` | L14 |
| `w_mm2` | `char(2)` | L15 |
| `w_mm` | `char(2)` | L16 |
| `w_year` | `char(4)` | L17 |
| `w_a` | `char(1)` | L18 |
| `fecha_movto` | `date` | L19 |
| `w_proceso` | `char(20)` | L20 |
| `v_dia_mes` | `char(4)` | L21 |
| `v_nomtabla` | `char(70)` | L22 |
| `v_sql` | `char(200)` | L23 |
| `vmovtos` | `char(200)` | L24 |
| `v_moneda` | `char(3)` | L25 |
| `v_moneda2` | `char(3)` | L26 |
| `v_tipmov` | `char(1)` | L27 |
| `v_cargo_abono` | `char(1)` | L28 |
| `v_ccsub` | `char(2)` | L29 |
| `v_ccsubsub` | `char(2)` | L30 |
| `v_ccssubsub` | `char(2)` | L31 |
| `v_ccsssubsub` | `char(2)` | L32 |
| `v_sector` | `char(2)` | L33 |
| `v2_sector` | `char(2)` | L34 |
| `v_division` | `char(2)` | L35 |
| `v_dd` | `char(2)` | L36 |
| *…27 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `co_detpol` | `bdicont` | no | SELECT | L67 |
| `co_detpol` | `bdicont` | no | DELETE | L67 |
| `co_poliza` | `bdicont` | no | SELECT | L74 |
| `co_poliza` | `bdicont` | no | DELETE | L74 |
| `co_tabmovdia` | `bdicont` | no | SELECT | L82 |
| `co_tabmovdia` | `bdicont` | no | DELETE | L82 |
| `co_contproc` | `bdicont` | no | SELECT | L87 |
| `co_param` | `bdicont` | no | SELECT | L115 |
| `co_movdia` | `bdicont` | no | SELECT | L122 |
| `co_movdia` | `bdicont` | no | DELETE | L122 |
| `co_movdia` | `bdicont` | no | INSERT | L125 |
| `co_mapeo_lotes` | `bdicont` | no | SELECT | L146 |
| `tx` | `bdicont` | no | SELECT | L183 |
| `co_mapeo_divisas` | `bdicont` | no | SELECT | L221 |
| `co_mapeo_nuevo` | `bdicont` | no | SELECT | L231 |
| `si_catalog` | `bdinteg` | ⚠️ sí | SELECT | L240 |
| `co_mapeo_cte` | `bdicont` | no | SELECT | L254 |
| `co_tabmovdia` | `bdicont` | no | INSERT | L283 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L128 | FÓRMULA | `let v_sql = "dbload -d bdicont -c carga -l er -n 100";` |  |
| L157 | VALIDACIÓN_NULL | `if w_sig_numpoliza is null or w_sig_numpoliza = " " then` |  |
| L164 | VALIDACIÓN_NULL | `if w_sig_numpoliza2 is null or w_sig_numpoliza2 = " " then` |  |
| L190 | FÓRMULA | `let i             = i + 1;` |  |
| L206 | FÓRMULA | `let v_importe     = v_importe / 100;` | 🔴 MONEY/aritmética financiera |
| L208 | VALIDACIÓN_NULL | `if v_num_poliza3 is null or v_num_poliza3 = " " then` |  |
| L214 | FÓRMULA | `let v_num_poliza3 = v_num_poliza3 + 1;` |  |
| L258 | VALIDACIÓN_NULL | `if v2_sector is null then` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `carga` | ACCION | carga / ingresa | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `dia` | MODIF | del día | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `?ria` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?ria` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `cierre`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_cierre.sql` |
| **LOC (1er CREATE)** | 491 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "cierre" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 9 tabla(s) con operaciones: UPDATE, SELECT, INSERT |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=0 · INFERIDO=0 · SINTÉTICO=0 / 1 términos |

### Firma

```sql
CREATE PROCEDURE cierre(
  pempresa                     char(3)
  pfecha_hoy                   date
) RETURNING char(5)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pempresa` | `char(3)` | — | — |
| `pfecha_hoy` | `date` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `sql_err` | `INTEGER` | L4 |
| `cod_ret` | `char(5)` | L6 |
| `vmoneda` | `char(2)` | L13 |
| `vciudad` | `char(3)` | L14 |
| `vsucursal` | `char(4)` | L15 |
| `v_empresa` | `char(3)` | L16 |
| `vmes_dia` | `date` | L17 |
| `v_ano` | `char(4)` | L18 |
| `vnro_cargos_dia` | `smallint` | L21 |
| `vnro_abonos_dia` | `smallint` | L22 |
| `vdias_proyectado` | `smallint` | L23 |
| `vdias_acumulado` | `smallint` | L24 |
| `vsaldo_acumulado` | `money(18,2)` | L25 |
| `vsaldo_inicio_dia` | `money(18,2)` | L26 |
| `vsaldo_fin_de_dia` | `money(18,2)` | L27 |
| `vabonos` | `money(18,2)` | L28 |
| `vcargos` | `money(18,2)` | L29 |
| `vnum_abonos` | `integer` | L30 |
| `vnum_cargos` | `integer` | L31 |
| `v_sql` | `char(500)` | L32 |
| `v_natcta` | `char(1)` | L33 |
| `v_fecha` | `char(8)` | L34 |
| `dmoneda` | `char(2)` | L50 |
| `dnaturaleza` | `char(1)` | L51 |
| `dnro_auxiliar` | `char(12)` | L52 |
| *…31 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `co_cierre_cif` | `bdicont` | no | SELECT | L105 |
| `co_fechas` | `bdicont` | no | SELECT | L116 |
| `co_param` | `bdicont` | no | SELECT | L127 |
| `co_diario` | `bdicont` | no | SELECT | L141 |
| `statistics` | `bdicont` | no | UPDATE | L157 |
| `co_sdodias` | `bdicont` | no | SELECT | L168 |
| `movtos` | `bdicont` | no | SELECT | L185 |
| `si_catalog` | `bdinteg` | ⚠️ sí | SELECT | L242 |
| `co_canret` | `bdicont` | no | INSERT | L295 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L252 | FÓRMULA | `LET tsaldo = tcargos - tabonos;` |  |
| L254 | FÓRMULA | `LET tsaldo = tabonos - tcargos;` |  |
| L343 | FÓRMULA | `LET v_espergan = "S"; -- result a per/gan sig ejercicio SEL` |  |
| L357 | FÓRMULA | `LET tsaldo = tcargos - tabonos;` |  |
| L359 | FÓRMULA | `LET tsaldo = tabonos - tcargos;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `cierre` | ACCION | cierre | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |

---

## `cierre_diario`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_cierre_diario.sql` |
| **LOC (1er CREATE)** | 152 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "cierre (diario)" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 7 llamada(s): `act_mens`, `inserta_estatus_cierre`, `inserta_estatus_cierre_notran` |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=0 / 2 términos |

### Firma

```sql
CREATE PROCEDURE cierre_diario(
  pempresa                     char(3)
  pfecha_hoy                   date
) RETURNING char(5)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pempresa` | `char(3)` | — | — |
| `pfecha_hoy` | `date` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cod_reti` | `char(5)` | L3 |
| `cod_ret` | `char(5)` | L4 |
| `cod_ins` | `CHAR(5)` | L5 |
| `GLOBAL` | `v_hora_inicio CHAR(12) DEFAULT ""` | L6 |
| `GLOBAL` | `v_hora_fin    CHAR(12) DEFAULT ""` | L7 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `act_mens` | `bdicont` | no | L20 |
| `inserta_estatus_cierre` | `bdicont` | no | L26 |
| `inserta_estatus_cierre_notran` | `bdicont` | no | L33 |
| `act_sdodias` | `bdicont` | no | L47 |
| `cierre` | `bdicont` | no | L75 |
| `sdo_dias` | `bdicont` | no | L101 |
| `dias_aux` | `bdicont` | no | L127 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `cierre` | ACCION | cierre | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `diario` | MODIF | diario | 🔵 CONVENCIÓN | nombre_sp |

---

## `cierre_mensual`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_cierre_mensual.sql` |
| **LOC (1er CREATE)** | 244 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "cierre (mensual)" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 11 llamada(s): `act_mens`, `inserta_estatus_cierre`, `inserta_estatus_cierre_notran` |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=0 / 2 términos |

### Firma

```sql
CREATE PROCEDURE cierre_mensual(
  pempresa                     char(3)
  pfecha_hoy                   date
) RETURNING CHAR(5)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pempresa` | `char(3)` | — | — |
| `pfecha_hoy` | `date` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cod_reti` | `char(5)` | L4 |
| `cod_ret` | `char(5)` | L5 |
| `cod_ins` | `CHAR(5)` | L6 |
| `GLOBAL` | `v_hora_inicio CHAR(12) DEFAULT ""` | L7 |
| `GLOBAL` | `v_hora_fin    CHAR(12) DEFAULT ""` | L8 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `act_mens` | `bdicont` | no | L21 |
| `inserta_estatus_cierre` | `bdicont` | no | L27 |
| `inserta_estatus_cierre_notran` | `bdicont` | no | L34 |
| `act_sdodias` | `bdicont` | no | L48 |
| `cierre` | `bdicont` | no | L76 |
| `sdo_dias` | `bdicont` | no | L102 |
| `dias_aux` | `bdicont` | no | L128 |
| `act_sdom` | `bdicont` | no | L154 |
| `act_sdomux` | `bdicont` | no | L176 |
| `act_histsdos` | `bdicont` | no | L199 |
| `act_hist` | `bdicont` | no | L223 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `cierre` | ACCION | cierre | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `mensual` | MODIF | mensual | 🔵 CONVENCIÓN | nombre_sp |

---

## `contcie2`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_contcie2.sql` |
| **LOC (1er CREATE)** | 197 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "contcie2" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 6 llamada(s): `pase_movtos`, `inserta_estatus_cierre`, `contproc` |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=1 / 2 términos |

### Firma

```sql
CREATE PROCEDURE contcie2(
  pempresa                     char(3)
  pfecha_hoy                   date
) RETURNING char(5)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pempresa` | `char(3)` | — | — |
| `pfecha_hoy` | `date` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cod_ret` | `char(5)` | L4 |
| `cod_reti` | `char(5)` | L5 |
| `v_mc1` | `char(2)` | L6 |
| `v_mc2` | `char(2)` | L7 |
| `v_ano` | `char(4)` | L8 |
| `v_ctaingini` | `char(10)` | L9 |
| `v_ctaingfin` | `char(10)` | L10 |
| `v_ctagtoini` | `char(10)` | L11 |
| `v_ctagtofin` | `char(10)` | L12 |
| `v_perganmay` | `char(10)` | L13 |
| `v_pergansub` | `char(10)` | L14 |
| `v_perganss` | `char(10)` | L15 |
| `v_pergansss` | `char(10)` | L16 |
| `v_perganssss` | `char(10)` | L17 |
| `v_pergansect` | `char(10)` | L18 |
| `v_canret` | `char(15)` | L19 |
| `v_prihabmes` | `date` | L20 |
| `v_ulthabmes` | `date` | L21 |
| `v_fecha_ant` | `date` | L22 |
| `v_sql` | `char(500)` | L23 |
| `v_proceso` | `char(10)` | L24 |
| `GLOBAL` | `v_hora_inicio CHAR(12) DEFAULT ""` | L25 |
| `GLOBAL` | `v_hora_fin    CHAR(12) DEFAULT ""` | L26 |
| `GLOBAL` | `v_fecha_proceso DATE DEFAULT ""` | L27 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `co_cierre_cif` | `bdicont` | no | SELECT | L60 |
| `co_cierre_cif` | `bdicont` | no | DELETE | L60 |
| `co_fechas` | `bdicont` | no | SELECT | L79 |
| `co_param` | `bdicont` | no | SELECT | L88 |
| `co_canret` | `bdicont` | no | SELECT | L117 |
| `co_canret` | `bdicont` | no | DELETE | L117 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `pase_movtos` | `bdicont` | no | L66 |
| `inserta_estatus_cierre` | `bdicont` | no | L70 |
| `contproc` | `bdicont` | no | L106 |
| `cierre_mensual` | `bdicont` | no | L137 |
| `cierre_diario` | `bdicont` | no | L155 |
| `depura_ctas` | `bdicont` | no | L176 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L91 | VALIDACIÓN_NULL | `IF v_mc1 IS NULL or v_mc1 = " " or` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `cont` | PREFIJO | familia contabilidad | 🔵 CONVENCIÓN | nombre_sp |
| `?cie2` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?cie2` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `corestsucur`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_corestsucur.sql` |
| **LOC (1er CREATE)** | 161 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "(sucursal)" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 4 tabla(s) con operaciones: SELECT, INSERT |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=0 · INFERIDO=1 · SINTÉTICO=2 / 3 términos |

### Firma

```sql
CREATE PROCEDURE corestsucur(
  p_empresa                    CHAR(3)
  p_sucursal                   CHAR(4)
) RETURNING CHAR(5),CHAR (40)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_empresa` | `CHAR(3)` | — | — |
| `p_sucursal` | `CHAR(4)` | `suc`=sucursal | 🟡 INFERIDO |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `sql_err` | `INTEGER` | L6 |
| `isam_err` | `INTEGER` | L7 |
| `error_info` | `CHAR(40)` | L8 |
| `cod_ret` | `CHAR(5)` | L9 |
| `tmensaje` | `CHAR(40)` | L10 |
| `v_ccmayor` | `CHAR(10)` | L11 |
| `v_ccsub` | `CHAR(10)` | L12 |
| `v_ccsubsub` | `CHAR(10)` | L13 |
| `v_ccssubsub` | `CHAR(10)` | L14 |
| `v_ccsssubsub` | `CHAR(10)` | L15 |
| `v_sector` | `CHAR(10)` | L16 |
| `v_registros` | `INTEGER` | L17 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `co_cta_ccorig` | `bdicont` | no | SELECT | L58 |
| `co_cta_ccorig` | `bdicont` | no | INSERT | L75 |
| `co_cta_ccdest` | `bdicont` | no | SELECT | L115 |
| `co_cta_ccdest` | `bdicont` | no | INSERT | L132 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `?corest` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `suc` | MODIF | sucursal | 🟡 INFERIDO | nombre_sp |
| `?ur` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?corest`, `?ur` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `corrige_saldos`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_corrige_saldos.sql` |
| **LOC (1er CREATE)** | 252 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "corrige — acción de corrección de datos saldos" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 4 tabla(s) con operaciones: SELECT, INSERT |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=0 · INFERIDO=1 · SINTÉTICO=0 / 2 términos |

### Firma

```sql
CREATE PROCEDURE corrige_saldos(
  pempresa                     char(3)
  pccmayor                     char(4)
  pccsub                       char(2)
  pccsubsub                    char(2)
  pccssubsub                   char(2)
  pccsssubsub                  char(2)
  psector                      char(2)
  pmoneda                      char(2)
  pfecha1                      date
  pfecha2                      date
)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pempresa` | `char(3)` | — | — |
| `pccmayor` | `char(4)` | — | — |
| `pccsub` | `char(2)` | — | — |
| `pccsubsub` | `char(2)` | — | — |
| `pccssubsub` | `char(2)` | — | — |
| `pccsssubsub` | `char(2)` | — | — |
| `psector` | `char(2)` | — | — |
| `pmoneda` | `char(2)` | — | — |
| `pfecha1` | `date` | — | — |
| `pfecha2` | `date` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vciudad` | `char(3)` | L7 |
| `w_empresa` | `char(3)` | L8 |
| `vusuario` | `char(8)` | L9 |
| `vpoliza_usuario` | `char(8)` | L10 |
| `vdescripcion` | `char(50)` | L11 |
| `vmonto` | `money(14,2)` | L12 |
| `v_rowid` | `integer` | L18 |
| `pfecha_hoy1` | `date` | L19 |
| `vexiste` | `integer` | L20 |
| `vccosto_orig` | `char(4)` | L21 |
| `vcargos_dia` | `money(18,2)` | L22 |
| `vabonos_dia` | `money(18,2)` | L23 |
| `vnro_cargos_dia` | `integer` | L24 |
| `vnro_abonos_dia` | `integer` | L25 |
| `vdias_proyectado` | `integer` | L26 |
| `vdias_acumulados` | `integer` | L27 |
| `vsaldo_acumulado` | `money(18,2)` | L28 |
| `vsaldo_inicio_dia` | `money(18,2)` | L29 |
| `vsaldo_fin_de_dia` | `money(18,2)` | L30 |
| `vsuma_carabo` | `money(18,2)` | L31 |
| `vmes_dia` | `date` | L32 |
| `vfecha_sig` | `date` | L33 |
| `vsaldo_inicio` | `money(18,2)` | L34 |
| `vcar_dia` | `money(18,2)` | L35 |
| `vabo_dia` | `money(18,2)` | L36 |
| *…22 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_catalog` | `bdinteg` | ⚠️ sí | SELECT | L77 |
| `co_histsdodias` | `bdicont` | no | SELECT | L91 |
| `co_fechas` | `bdicont` | no | SELECT | L109 |
| `co_histsdodias` | `bdicont` | no | INSERT | L163 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L137 | FÓRMULA | `let vsaldo_fin_de_diar = vsaldo_inicio + (vcar_dia - vabo_dia);` |  |
| L139 | FÓRMULA | `let vsaldo_fin_de_diar = vsaldo_inicio + (vabo_dia - vcar_dia);` |  |
| L145 | FÓRMULA | `let vsaldo_acumulado=vsaldo_acumulado + vsaldo_fin_de_diar;}` |  |
| L247 | FÓRMULA | `let vfecha_inicio = vfecha_inicio + 1 UNITS DAY;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `corrige` | ACCION | corrige — acción de corrección de datos (bdicred:sp_corrige_ | 🟡 INFERIDO | nombre_sp |
| `saldos` | ENTIDAD | saldos | ✅ CÓDIGO | nombre_sp, texto_cuerpo |

---

## `ctas_nuevas`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_ctas_nuevas.sql` |
| **LOC (1er CREATE)** | 181 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "cuentas" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 4 tabla(s) con operaciones: SELECT, INSERT |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=1 / 2 términos |

### Firma

```sql
CREATE PROCEDURE ctas_nuevas(
  pempresa                     char(3)
  w_fecha                      date
  w_usuario                    char(10)
)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pempresa` | `char(3)` | — | — |
| `w_fecha` | `date` | — | — |
| `w_usuario` | `char(10)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `nuempresa` | `char(3)` | L3 |
| `nuccmayor` | `char(10)` | L4 |
| `nuccsub` | `char(10)` | L5 |
| `nuccsubsub` | `char(10)` | L6 |
| `nuccssubsub` | `char(10)` | L7 |
| `nuccsssubsub` | `char(10)` | L8 |
| `nusector` | `char(10)` | L9 |
| `nuciudad` | `char(3)` | L10 |
| `nusucursal` | `char(4)` | L11 |
| `numoneda` | `char(2)` | L12 |
| `lv_cuantos` | `int` | L22 |
| `nutipo_cta` | `char(1)` | L23 |
| `nunat_cta` | `char(1)` | L24 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `co_fechas` | `bdicont` | no | SELECT | L28 |
| `co_detpol` | `bdicont` | no | SELECT | L42 |
| `co_sdodias` | `bdicont` | no | SELECT | L57 |
| `co_balanza` | `bdicont` | no | INSERT | L171 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L86 | VALIDACIÓN_NULL | `if w_cargos_dia is null then` |  |
| L105 | VALIDACIÓN_NULL | `if w_abonos_dia is null then` |  |
| L124 | VALIDACIÓN_NULL | `if w_debito_dia_ant is null then` |  |
| L145 | VALIDACIÓN_NULL | `if w_credito_dia_ant is null then` |  |
| L151 | FÓRMULA | `let w_saldo_inicio_dia = 0 + w_debito_dia_ant - w_credito_dia_ant;` |  |
| L152 | FÓRMULA | `let w_saldo_fin_de_dia = w_cargos_dia - w_abonos_dia;` |  |
| L156 | FÓRMULA | `let w_saldo_inicio_dia = 0 - w_debito_dia_ant + w_credito_dia_ant;` |  |
| L157 | FÓRMULA | `let w_saldo_fin_de_dia = (- w_cargos_dia + w_abonos_dia);` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `ctas` | ENTIDAD | cuentas | 🔵 CONVENCIÓN | nombre_sp |
| `?_nuevas` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_nuevas` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `ctas_nuevascc`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_ctas_nuevascc.sql` |
| **LOC (1er CREATE)** | 182 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "cuentas" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 6 tabla(s) con operaciones: SELECT, INSERT |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=1 / 2 términos |

### Firma

```sql
CREATE PROCEDURE ctas_nuevascc(
  pempresa                     char(3)
  w_fecha                      date
  v_usuario                    CHAR(10)
)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pempresa` | `char(3)` | — | — |
| `w_fecha` | `date` | — | — |
| `v_usuario` | `CHAR(10)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `nuempresa` | `char(3)` | L3 |
| `nuccmayor` | `char(10)` | L4 |
| `nuccsub` | `char(10)` | L5 |
| `nuccsubsub` | `char(10)` | L6 |
| `nuccssubsub` | `char(10)` | L7 |
| `nuccsssubsub` | `char(10)` | L8 |
| `nusector` | `char(10)` | L9 |
| `nuciudad` | `char(3)` | L10 |
| `nusucursal` | `char(4)` | L11 |
| `numoneda` | `char(2)` | L12 |
| `nunat_cta` | `char(1)` | L13 |
| `lv_cuantos` | `int` | L22 |
| `v_plaza` | `CHAR(3)` | L24 |
| `v_regional` | `CHAR(3)` | L25 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `co_fechas` | `bdicont` | no | SELECT | L32 |
| `co_detpol` | `bdicont` | no | SELECT | L40 |
| `si_sucursales` | `bdinteg` | ⚠️ sí | SELECT | L53 |
| `si_plazas` | `bdinteg` | ⚠️ sí | SELECT | L59 |
| `co_sdodias` | `bdicont` | no | SELECT | L69 |
| `co_balanza` | `bdicont` | no | INSERT | L172 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L98 | VALIDACIÓN_NULL | `if w_cargos_dia is null then` |  |
| L117 | VALIDACIÓN_NULL | `if w_abonos_dia is null then` |  |
| L136 | VALIDACIÓN_NULL | `if w_debito_dia_ant is null then` |  |
| L155 | VALIDACIÓN_NULL | `if w_credito_dia_ant is null then` |  |
| L161 | FÓRMULA | `let w_saldo_inicio_dia = 0 + w_debito_dia_ant - w_credito_dia_ant;` |  |
| L162 | FÓRMULA | `let w_saldo_fin_de_dia = w_cargos_dia - w_abonos_dia;` |  |
| L166 | FÓRMULA | `let w_saldo_inicio_dia = 0 - w_debito_dia_ant + w_credito_dia_ant;` |  |
| L167 | FÓRMULA | `let w_saldo_fin_de_dia = (- w_cargos_dia + w_abonos_dia);` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `ctas` | ENTIDAD | cuentas | 🔵 CONVENCIÓN | nombre_sp |
| `?_nuevascc` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_nuevascc` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `ctasgiradas`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_ctasgiradas.sql` |
| **LOC (1er CREATE)** | 358 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "cuentas" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 6 tabla(s) con operaciones: SELECT, INSERT |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=1 / 2 términos |

### Firma

```sql
CREATE PROCEDURE ctasgiradas(
  v_empresa                    CHAR(4)
  v_fechainicio                date
  v_fechafin                   date
)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `v_empresa` | `CHAR(4)` | — | — |
| `v_fechainicio` | `date` | — | — |
| `v_fechafin` | `date` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `tempresa` | `char(3)` | L4 |
| `tauxiliar` | `char(12)` | L5 |
| `tsucursal` | `char(4)` | L6 |
| `tciudad` | `char(3)` | L7 |
| `tccmayor` | `char(10)` | L8 |
| `tccsub` | `char(10)` | L9 |
| `tccsubsub` | `char(10)` | L10 |
| `tccssubsub` | `char(10)` | L11 |
| `tccsssubsub` | `char(10)` | L12 |
| `tsector` | `char(10)` | L13 |
| `tmoneda` | `char(2)` | L14 |
| `tmes_dia` | `date` | L15 |
| `tsaldo_inicio_dia` | `money(18,2)` | L16 |
| `tsaldo_fin_de_dia` | `money(18,2)` | L17 |
| `v_cuenta` | `char(60)` | L19 |
| `v_fechahoy` | `date` | L20 |
| `v_mesinicio` | `char(2)` | L21 |
| `v_anoinicio` | `char(4)` | L22 |
| `v_mesfin` | `char(2)` | L23 |
| `v_anofin` | `char(4)` | L24 |
| `v_meshoy` | `char(2)` | L25 |
| `v_anohoy` | `char(4)` | L26 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `co_fechas` | `bdicont` | no | SELECT | L49 |
| `co_sdodias` | `bdicont` | no | SELECT | L91 |
| `co_ctasob` | `bdicont` | no | INSERT | L100 |
| `co_diasaux` | `bdicont` | no | SELECT | L165 |
| `co_histsdodias` | `bdicont` | no | SELECT | L241 |
| `co_histdiasaux` | `bdicont` | no | SELECT | L315 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `ctas` | ENTIDAD | cuentas | 🔵 CONVENCIÓN | nombre_sp |
| `?giradas` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?giradas` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `cuentacontable`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_cuentacontable.sql` |
| **LOC (1er CREATE)** | 97 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "cuenta" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 1 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=1 / 3 términos |

### Firma

```sql
CREATE PROCEDURE cuentacontable(
  p_empresa                    CHAR(3)
  p_ccmayor                    CHAR(4)
  p_ccsub                      CHAR(2)
  p_ccsubsub                   CHAR(2)
  p_ccssubsub                  CHAR(2)
  p_ccsssubsub                 CHAR(2)
) RETURNING CHAR(50), CHAR(4), CHAR(2), CHAR(2), CHAR(2), CHAR(2), CHAR(2),CHAR(50)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_empresa` | `CHAR(3)` | — | — |
| `p_ccmayor` | `CHAR(4)` | — | — |
| `p_ccsub` | `CHAR(2)` | — | — |
| `p_ccsubsub` | `CHAR(2)` | — | — |
| `p_ccssubsub` | `CHAR(2)` | — | — |
| `p_ccsssubsub` | `CHAR(2)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `tccmayor` | `CHAR(4)` | L5 |
| `tccsub` | `CHAR(2)` | L6 |
| `tccsubsub` | `CHAR(2)` | L7 |
| `tccssubsub` | `CHAR(2)` | L8 |
| `tccsssubsub` | `CHAR(2)` | L9 |
| `tsector` | `CHAR(2)` | L10 |
| `tnombre` | `CHAR(50)` | L11 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_catalog` | `bdinteg` | ⚠️ sí | SELECT | L32 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L28 | VALIDACIÓN_NULL | `IF (p_ccmayor IS NOT NULL AND p_ccmayor <> '') AND (p_ccsub ='' OR p_ccsub IS NULL) THEN` |  |
| L40 | VALIDACIÓN_NULL | `IF (p_ccsub IS NOT NULL AND p_ccsub <> '00' AND p_ccsub <> '') AND (p_ccsubsub ='' OR p_ccsubsub IS ` |  |
| L52 | VALIDACIÓN_NULL | `IF (p_ccsubsub IS NOT NULL AND p_ccsubsub <> '00' AND p_ccsubsub <> '') AND (p_ccssubsub ='' OR p_cc` |  |
| L64 | VALIDACIÓN_NULL | `IF (p_ccssubsub IS NOT NULL AND p_ccssubsub <> '00' AND p_ccssubsub <> '') AND (p_ccsssubsub = '' OR` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `cuenta` | ENTIDAD | cuenta | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `cont` | PREFIJO | familia contabilidad | 🔵 CONVENCIÓN | nombre_sp |
| `?able` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?able` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `del_co_historico`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_del_co_historico.sql` |
| **LOC (1er CREATE)** | 33 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "(histórico)" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 2 tabla(s) con operaciones: SELECT, DELETE |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=0 · INFERIDO=0 · SINTÉTICO=1 / 2 términos |

### Firma

```sql
CREATE PROCEDURE del_co_historico(
  pempresa                     CHAR(4)
  pfecha_hoy                   date
) RETURNING VARCHAR(5)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pempresa` | `CHAR(4)` | — | — |
| `pfecha_hoy` | `date` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `p_rowid` | `int` | L3 |
| `pcontador` | `int` | L4 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `co_historico` | `bdicont` | no | SELECT | L8 |
| `co_historico` | `bdicont` | no | DELETE | L19 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L22 | FÓRMULA | `let pcontador = pcontador + 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `?del_co_` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `historico` | MODIF | histórico | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?del_co_` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `del_co_histsdodias`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_del_co_histsdodias.sql` |
| **LOC (1er CREATE)** | 29 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "saldo (histórico/historial, del día)" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 2 tabla(s) con operaciones: SELECT, DELETE |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=2 / 5 términos |

### Firma

```sql
CREATE PROCEDURE del_co_histsdodias(
  pempresa                     CHAR(4)
  pfecha_hoy                   date
) RETURNING VARCHAR(5)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pempresa` | `CHAR(4)` | — | — |
| `pfecha_hoy` | `date` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `p_rowid` | `int` | L3 |
| `pcontador` | `int` | L4 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `co_histsdodias` | `bdicont` | no | SELECT | L8 |
| `co_histsdodias` | `bdicont` | no | DELETE | L15 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L18 | FÓRMULA | `let pcontador = pcontador + 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `?del_co_` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `hist` | MODIF | histórico/historial | 🔵 CONVENCIÓN | nombre_sp |
| `sdo` | ENTIDAD | saldo | 🔵 CONVENCIÓN | nombre_sp |
| `dia` | MODIF | del día | 🔵 CONVENCIÓN | nombre_sp |
| `?s` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?del_co_`, `?s` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `depura_ctas`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_depura_ctas.sql` |
| **LOC (1er CREATE)** | 53 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "depura cuentas" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `depura` → `DELETE` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=0 / 2 términos |

### Firma

```sql
CREATE PROCEDURE depura_ctas(
  pempresa                     char(3)
) RETURNING char(5)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pempresa` | `char(3)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `sql_err` | `INTEGER` | L4 |
| `cod_ret` | `char(5)` | L5 |
| `vfecha_hoy` | `date` | L6 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `co_fechas` | `bdicont` | no | SELECT | L20 |
| `co_cierre_cif` | `bdicont` | no | SELECT | L23 |
| `co_sdodias` | `bdicont` | no | SELECT | L33 |
| `co_diasaux` | `bdicont` | no | SELECT | L42 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `depura` | ACCION | depura / limpia | 🔵 CONVENCIÓN | nombre_sp |
| `ctas` | ENTIDAD | cuentas | 🔵 CONVENCIÓN | nombre_sp |

---

## `detmauxcon`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_detmauxcon.sql` |
| **LOC (1er CREATE)** | 251 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "consulta detalle" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=1 · INFERIDO=1 · SINTÉTICO=1 / 4 términos |

### Firma

```sql
CREATE PROCEDURE detmauxcon(
  pempresa                     char(3)
  pfecha_hoy                   date
)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pempresa` | `char(3)` | — | — |
| `pfecha_hoy` | `date` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `tempresa` | `char(3)` | L2 |
| `tccmayor` | `char(10)` | L3 |
| `tccsub` | `char(10)` | L4 |
| `tccsubsub` | `char(10)` | L5 |
| `tccssubsub` | `char(10)` | L6 |
| `tccsssubsub` | `char(10)` | L7 |
| `tsector` | `char(10)` | L8 |
| `tciudad` | `char(3)` | L9 |
| `tsucursal` | `char(4)` | L10 |
| `tmoneda` | `char(2)` | L11 |
| `tsaldo_inicio_mes` | `money(18,2)` | L12 |
| `tsaldo_actual` | `money(18,2)` | L13 |
| `tsaldo_inicial` | `money(18,2)` | L14 |
| `tsaldo_final` | `money(18,2)` | L15 |
| `tfecha_hoy` | `date` | L16 |
| `tmonto` | `money(18,2)` | L17 |
| `tusuario` | `char(8)` | L18 |
| `tcontrol_poliza` | `int` | L19 |
| `tfecha_valida` | `date` | L20 |
| `tnaturaleza` | `char(1)` | L21 |
| `tnat_cta` | `char(1)` | L22 |
| `tsecuencia` | `int` | L23 |
| `tnro_auxiliar` | `char(12)` | L24 |
| `v_dia` | `CHAR(2)` | L25 |
| `v_mes` | `CHAR(2)` | L26 |
| *…17 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `co_detmaenca` | `bdicont` | no | SELECT | L46 |
| `co_detmaenca` | `bdicont` | no | DELETE | L46 |
| `co_detmadet` | `bdicont` | no | SELECT | L47 |
| `co_detmadet` | `bdicont` | no | DELETE | L47 |
| `co_fechas` | `bdicont` | no | SELECT | L75 |
| `co_saldosaux` | `bdicont` | no | SELECT | L102 |
| `si_catalog` | `bdinteg` | ⚠️ sí | SELECT | L142 |
| `si_divisas` | `bdinteg` | ⚠️ sí | SELECT | L153 |
| `co_auxiliar` | `bdicont` | no | SELECT | L163 |
| `co_detmaenca` | `bdicont` | no | INSERT | L167 |
| `co_movtos` | `bdicont` | no | SELECT | L182 |
| `co_detmadet` | `bdicont` | no | INSERT | L224 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L209 | VALIDACIÓN_NULL | `if tfecha_valida is null then` |  |
| L213 | FÓRMULA | `let tsaldo_final = tsaldo_inicial + tmonto;` | 🔴 MONEY/aritmética financiera |
| L215 | FÓRMULA | `let tsaldo_final = tsaldo_inicial - tmonto;` | 🔴 MONEY/aritmética financiera |
| L219 | FÓRMULA | `let tsaldo_final = tsaldo_inicial - tmonto;` | 🔴 MONEY/aritmética financiera |
| L221 | FÓRMULA | `let tsaldo_final = tsaldo_inicial + tmonto;` | 🔴 MONEY/aritmética financiera |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `det` | ENTIDAD | detalle | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `?mau` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `x` | MODIF | por (criterio) | 🔵 CONVENCIÓN | nombre_sp |
| `con` | ACCION | consulta | 🟡 INFERIDO | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?mau` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `detmauxsuc`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_detmauxsuc.sql` |
| **LOC (1er CREATE)** | 255 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "detalle (sucursal)" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 12 tabla(s) con operaciones: INSERT, SELECT, DELETE |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=1 · INFERIDO=1 · SINTÉTICO=1 / 4 términos |

### Firma

```sql
CREATE PROCEDURE detmauxsuc(
  pempresa                     char(3)
  pfecha_hoy                   date
)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pempresa` | `char(3)` | — | — |
| `pfecha_hoy` | `date` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `tempresa` | `char(3)` | L2 |
| `tccmayor` | `char(10)` | L3 |
| `tccsub` | `char(10)` | L4 |
| `tccsubsub` | `char(10)` | L5 |
| `tccssubsub` | `char(10)` | L6 |
| `tccsssubsub` | `char(10)` | L7 |
| `tsector` | `char(10)` | L8 |
| `tciudad` | `char(3)` | L9 |
| `tsucursal` | `char(4)` | L10 |
| `tmoneda` | `char(2)` | L11 |
| `tsaldo_inicio_mes` | `money(18,2)` | L12 |
| `tsaldo_actual` | `money(18,2)` | L13 |
| `tsaldo_inicial` | `money(18,2)` | L14 |
| `tsaldo_final` | `money(18,2)` | L15 |
| `tfecha_hoy` | `date` | L16 |
| `tmonto` | `money(18,2)` | L17 |
| `tusuario` | `char(8)` | L18 |
| `tcontrol_poliza` | `int` | L19 |
| `tfecha_valida` | `date` | L20 |
| `tnaturaleza` | `char(1)` | L21 |
| `tnat_cta` | `char(1)` | L22 |
| `tsecuencia` | `int` | L23 |
| `tnro_auxiliar` | `char(12)` | L24 |
| `v_dia` | `CHAR(2)` | L25 |
| `v_mes` | `CHAR(2)` | L26 |
| *…17 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `co_detmaenca` | `bdicont` | no | SELECT | L46 |
| `co_detmaenca` | `bdicont` | no | DELETE | L46 |
| `co_detmadet` | `bdicont` | no | SELECT | L47 |
| `co_detmadet` | `bdicont` | no | DELETE | L47 |
| `co_fechas` | `bdicont` | no | SELECT | L75 |
| `co_saldosaux` | `bdicont` | no | SELECT | L104 |
| `si_catalog` | `bdinteg` | ⚠️ sí | SELECT | L146 |
| `si_divisas` | `bdinteg` | ⚠️ sí | SELECT | L157 |
| `co_auxiliar` | `bdicont` | no | SELECT | L167 |
| `co_detmaenca` | `bdicont` | no | INSERT | L171 |
| `co_movtos` | `bdicont` | no | SELECT | L185 |
| `co_detmadet` | `bdicont` | no | INSERT | L228 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L213 | VALIDACIÓN_NULL | `if tfecha_valida is null then` |  |
| L217 | FÓRMULA | `let tsaldo_final = tsaldo_inicial + tmonto;` | 🔴 MONEY/aritmética financiera |
| L219 | FÓRMULA | `let tsaldo_final = tsaldo_inicial - tmonto;` | 🔴 MONEY/aritmética financiera |
| L223 | FÓRMULA | `let tsaldo_final = tsaldo_inicial - tmonto;` | 🔴 MONEY/aritmética financiera |
| L225 | FÓRMULA | `let tsaldo_final = tsaldo_inicial + tmonto;` | 🔴 MONEY/aritmética financiera |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `det` | ENTIDAD | detalle | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `?mau` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `x` | MODIF | por (criterio) | 🔵 CONVENCIÓN | nombre_sp |
| `suc` | MODIF | sucursal | 🟡 INFERIDO | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?mau` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `diasmes`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_diasmes.sql` |
| **LOC (1er CREATE)** | 21 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "mes (del día)" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — Tokens confirmados en el vocab pero DML no correlaciona con el propósito |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=1 / 3 términos |

### Firma

```sql
CREATE PROCEDURE diasmes(
  v_anio                       smallint
  v_mes                        smallint
) RETURNING smallint
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `v_anio` | `smallint` | — | — |
| `v_mes` | `smallint` | `mes`=mes | ✅ CÓDIGO |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `v_dias` | `smallint` | L4 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `dia` | MODIF | del día | 🔵 CONVENCIÓN | nombre_sp |
| `?s` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `mes` | ENTIDAD | mes | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?s` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `difmes`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_difmes.sql` |
| **LOC (1er CREATE)** | 15 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "mes" `[partial]` |
| **Propósito verificado** | ❓ NO_VERIFICABLE — Propósito inferido; sin evidencia DML para verificar |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=1 / 2 términos |

### Firma

```sql
CREATE PROCEDURE difmes(
  v_fecha1                     date
  v_fecha2                     date
) RETURNING smallint
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `v_fecha1` | `date` | — | — |
| `v_fecha2` | `date` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `v_codigo` | `smallint` | L4 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `?dif` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `mes` | ENTIDAD | mes | 🔵 CONVENCIÓN | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?dif` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `factor_nat`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_factor_nat.sql` |
| **LOC (1er CREATE)** | 14 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "actualiza" `[partial]` |
| **Propósito verificado** | ❓ NO_VERIFICABLE — Propósito inferido; sin evidencia DML para verificar |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=2 / 3 términos |

### Firma

```sql
CREATE PROCEDURE factor_nat(
  v_naturaleza                 char(1)
) RETURNING smallint
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `v_naturaleza` | `char(1)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `v_factor` | `smallint` | L4 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L7 | FÓRMULA | `let v_factor = -1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `?f` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `act` | ACCION | actualiza | 🔵 CONVENCIÓN | nombre_sp |
| `?or_nat` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?f`, `?or_nat` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `filtrasuc`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_filtrasuc.sql` |
| **LOC (1er CREATE)** | 13 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "(sucursal)" `[partial]` |
| **Propósito verificado** | ❓ NO_VERIFICABLE — Propósito inferido; sin evidencia DML para verificar |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=0 · INFERIDO=0 · SINTÉTICO=1 / 2 términos |

### Firma

```sql
CREATE PROCEDURE filtrasuc(
  p_sucursal                   CHAR(4)
  p_reg_suc                    CHAR(3)
) RETURNING CHAR(4)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_sucursal` | `CHAR(4)` | `suc`=sucursal | ✅ CÓDIGO |
| `p_reg_suc` | `CHAR(3)` | `suc`=sucursal | ✅ CÓDIGO |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `v_sucursal` | `CHAR(4)` | L4 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `?filtra` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `suc` | MODIF | sucursal | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?filtra` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `gen_balprev`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_gen_balprev.sql` |
| **LOC (1er CREATE)** | 320 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "genera balp — balance preventivo" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `genera` → `INSERT` encontrado en el cuerpo · `genera` → `SELECT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=0 · INFERIDO=2 · SINTÉTICO=1 / 3 términos |

### Firma

```sql
CREATE PROCEDURE gen_balprev(
  pempresa                     char(3)
  w_fecha                      date
  w_usuario                    char(10)
)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pempresa` | `char(3)` | — | — |
| `w_fecha` | `date` | — | — |
| `w_usuario` | `char(10)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `sdempresa` | `char(3)` | L3 |
| `sdccmayor` | `char(10)` | L4 |
| `sdccsub` | `char(10)` | L5 |
| `sdccsubsub` | `char(10)` | L6 |
| `sdccssubsub` | `char(10)` | L7 |
| `sdccsssubsub` | `char(10)` | L8 |
| `sdsector` | `char(10)` | L9 |
| `sdciudad` | `char(3)` | L10 |
| `sdsucursal` | `char(4)` | L11 |
| `sdmoneda` | `char(2)` | L12 |
| `sdcargos_dia` | `money(18,2)` | L13 |
| `sdabonos_dia` | `money(18,2)` | L14 |
| `sdsaldo_inicio_dia` | `money(18,2)` | L15 |
| `sdsaldo_fin_de_dia` | `money(18,2)` | L16 |
| `sdnaturaleza_cta` | `char(1)` | L17 |
| `sdnombre_cta` | `char(40)` | L18 |
| `v_numregs` | `int` | L19 |
| `sdtipo_cta` | `char(1)` | L20 |
| `w_pri_hab_mes` | `date` | L22 |
| `w_credcor_dia_ant` | `money(18,2)` | L30 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `co_fechas` | `bdicont` | no | SELECT | L37 |
| `systables` | `bdicont` | no | SELECT | L42 |
| `co_sdodias` | `bdicont` | no | SELECT | L60 |
| `co_detpol` | `bdicont` | no | SELECT | L80 |
| `co_balanza` | `bdicont` | no | INSERT | L178 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L95 | VALIDACIÓN_NULL | `if w_cargos_dia is null then` |  |
| L115 | VALIDACIÓN_NULL | `if w_abonos_dia is null then` |  |
| L135 | VALIDACIÓN_NULL | `if w_debito_dia_ant is null then` |  |
| L155 | VALIDACIÓN_NULL | `if w_credito_dia_ant is null then` |  |
| L163 | FÓRMULA | `let sdsaldo_inicio_dia = sdsaldo_fin_de_dia +` |  |
| L165 | FÓRMULA | `let sdsaldo_fin_de_dia = sdsaldo_inicio_dia +` |  |
| L170 | FÓRMULA | `let sdsaldo_inicio_dia = sdsaldo_fin_de_dia -` |  |
| L172 | FÓRMULA | `let sdsaldo_fin_de_dia = sdsaldo_inicio_dia -` |  |
| L228 | VALIDACIÓN_NULL | `if w_cargos_dia is null then` |  |
| L248 | VALIDACIÓN_NULL | `if w_abonos_dia is null then` |  |
| L268 | VALIDACIÓN_NULL | `if w_debito_dia_ant is null then` |  |
| L288 | VALIDACIÓN_NULL | `if w_credito_dia_ant is null then` |  |
| L296 | FÓRMULA | `let sdsaldo_inicio_dia = sdsaldo_fin_de_dia +` |  |
| L298 | FÓRMULA | `let sdsaldo_fin_de_dia = sdsaldo_inicio_dia +` |  |
| L303 | FÓRMULA | `let sdsaldo_inicio_dia = sdsaldo_fin_de_dia -` |  |
| L305 | FÓRMULA | `let sdsaldo_fin_de_dia = sdsaldo_inicio_dia -` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `gen` | ACCION | genera / general | 🟡 INFERIDO | nombre_sp |
| `balp` | ENTIDAD | balp — balance preventivo / balanza preventiva (gen_balprev* | 🔴 SINTÉTICO | nombre_sp |
| `rev` | ACCION | reversión (abreviación de reversa/reverso) | 🟡 INFERIDO | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `balp` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `gen_balprevcc`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_gen_balprevcc.sql` |
| **LOC (1er CREATE)** | 350 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "genera balp — balance preventivo" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `genera` → `INSERT` encontrado en el cuerpo · `genera` → `SELECT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=0 · INFERIDO=2 · SINTÉTICO=2 / 4 términos |

### Firma

```sql
CREATE PROCEDURE gen_balprevcc(
  pempresa                     char(3)
  w_fecha                      date
  v_usuario                    char(10)
)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pempresa` | `char(3)` | — | — |
| `w_fecha` | `date` | — | — |
| `v_usuario` | `char(10)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `sdempresa` | `char(3)` | L3 |
| `sdccmayor` | `char(10)` | L4 |
| `sdccsub` | `char(10)` | L5 |
| `sdccsubsub` | `char(10)` | L6 |
| `sdccssubsub` | `char(10)` | L7 |
| `sdccsssubsub` | `char(10)` | L8 |
| `sdsector` | `char(10)` | L9 |
| `sdciudad` | `char(3)` | L10 |
| `sdsucursal` | `char(4)` | L11 |
| `sdmoneda` | `char(2)` | L12 |
| `sdcargos_dia` | `money(18,2)` | L13 |
| `sdabonos_dia` | `money(18,2)` | L14 |
| `sdsaldo_inicio_dia` | `money(18,2)` | L15 |
| `sdsaldo_fin_de_dia` | `money(18,2)` | L16 |
| `sdnaturaleza_cta` | `char(1)` | L17 |
| `sdnombre_cta` | `char(40)` | L18 |
| `v_numregs` | `int` | L19 |
| `w_pri_hab_mes` | `date` | L21 |
| `w_credcor_dia_ant` | `money(18,2)` | L29 |
| `v_nomsuc` | `char(40)` | L30 |
| `v_plaza` | `CHAR(3)` | L32 |
| `v_regional` | `CHAR(3)` | L33 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `co_fechas` | `bdicont` | no | SELECT | L40 |
| `systables` | `bdicont` | no | SELECT | L45 |
| `co_sdodias` | `bdicont` | no | SELECT | L49 |
| `si_sucursales` | `bdinteg` | ⚠️ sí | SELECT | L78 |
| `si_plazas` | `bdinteg` | ⚠️ sí | SELECT | L84 |
| `co_detpol` | `bdicont` | no | SELECT | L96 |
| `co_balanza` | `bdicont` | no | INSERT | L201 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L111 | VALIDACIÓN_NULL | `if w_cargos_dia is null then` |  |
| L131 | VALIDACIÓN_NULL | `if w_abonos_dia is null then` |  |
| L151 | VALIDACIÓN_NULL | `if w_debito_dia_ant is null then` |  |
| L171 | VALIDACIÓN_NULL | `if w_credito_dia_ant is null then` |  |
| L179 | FÓRMULA | `let sdsaldo_inicio_dia = sdsaldo_fin_de_dia +` |  |
| L181 | FÓRMULA | `let sdsaldo_fin_de_dia = sdsaldo_inicio_dia +` |  |
| L186 | FÓRMULA | `let sdsaldo_inicio_dia = sdsaldo_fin_de_dia -` |  |
| L188 | FÓRMULA | `let sdsaldo_fin_de_dia = sdsaldo_inicio_dia -` |  |
| L251 | VALIDACIÓN_NULL | `if w_cargos_dia is null then` |  |
| L271 | VALIDACIÓN_NULL | `if w_abonos_dia is null then` |  |
| L291 | VALIDACIÓN_NULL | `if w_debito_dia_ant is null then` |  |
| L311 | VALIDACIÓN_NULL | `if w_credito_dia_ant is null then` |  |
| L319 | FÓRMULA | `let sdsaldo_inicio_dia = sdsaldo_fin_de_dia +` |  |
| L321 | FÓRMULA | `let sdsaldo_fin_de_dia = sdsaldo_inicio_dia +` |  |
| L326 | FÓRMULA | `let sdsaldo_inicio_dia = sdsaldo_fin_de_dia -` |  |
| L328 | FÓRMULA | `let sdsaldo_fin_de_dia = sdsaldo_inicio_dia -` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `gen` | ACCION | genera / general | 🟡 INFERIDO | nombre_sp |
| `balp` | ENTIDAD | balp — balance preventivo / balanza preventiva (gen_balprev* | 🔴 SINTÉTICO | nombre_sp |
| `rev` | ACCION | reversión (abreviación de reversa/reverso) | 🟡 INFERIDO | nombre_sp |
| `?cc` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `balp`, `?cc` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `gen_balprevreg`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_gen_balprevreg.sql` |
| **LOC (1er CREATE)** | 351 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "genera balp — balance preventivo" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `genera` → `INSERT` encontrado en el cuerpo · `genera` → `SELECT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=0 · INFERIDO=3 · SINTÉTICO=1 / 4 términos |

### Firma

```sql
CREATE PROCEDURE gen_balprevreg(
  pempresa                     char(3)
  w_fecha                      date
  v_usuario                    char(10)
)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pempresa` | `char(3)` | — | — |
| `w_fecha` | `date` | — | — |
| `v_usuario` | `char(10)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `sdempresa` | `char(3)` | L3 |
| `sdccmayor` | `char(10)` | L4 |
| `sdccsub` | `char(10)` | L5 |
| `sdccsubsub` | `char(10)` | L6 |
| `sdccssubsub` | `char(10)` | L7 |
| `sdccsssubsub` | `char(10)` | L8 |
| `sdsector` | `char(10)` | L9 |
| `sdciudad` | `char(3)` | L10 |
| `sdsucursal` | `char(4)` | L11 |
| `sdmoneda` | `char(2)` | L12 |
| `sdcargos_dia` | `money(18,2)` | L13 |
| `sdabonos_dia` | `money(18,2)` | L14 |
| `sdsaldo_inicio_dia` | `money(18,2)` | L15 |
| `sdsaldo_fin_de_dia` | `money(18,2)` | L16 |
| `sdnaturaleza_cta` | `char(1)` | L17 |
| `sdnombre_cta` | `char(40)` | L18 |
| `v_numregs` | `int` | L19 |
| `sdtipo_cta` | `char(1)` | L20 |
| `w_pri_hab_mes` | `date` | L22 |
| `w_credcor_dia_ant` | `money(18,2)` | L30 |
| `v_plaza` | `CHAR(3)` | L32 |
| `v_regional` | `CHAR(3)` | L33 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `co_fechas` | `bdicont` | no | SELECT | L42 |
| `systables` | `bdicont` | no | SELECT | L47 |
| `co_sdodias` | `bdicont` | no | SELECT | L51 |
| `si_sucursales` | `bdinteg` | ⚠️ sí | SELECT | L91 |
| `si_plazas` | `bdinteg` | ⚠️ sí | SELECT | L97 |
| `co_detpol` | `bdicont` | no | SELECT | L109 |
| `co_balanza` | `bdicont` | no | INSERT | L207 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L124 | VALIDACIÓN_NULL | `if w_cargos_dia is null then` |  |
| L144 | VALIDACIÓN_NULL | `if w_abonos_dia is null then` |  |
| L164 | VALIDACIÓN_NULL | `if w_debito_dia_ant is null then` |  |
| L184 | VALIDACIÓN_NULL | `if w_credito_dia_ant is null then` |  |
| L192 | FÓRMULA | `let sdsaldo_inicio_dia = sdsaldo_fin_de_dia +` |  |
| L194 | FÓRMULA | `let sdsaldo_fin_de_dia = sdsaldo_inicio_dia +` |  |
| L199 | FÓRMULA | `let sdsaldo_inicio_dia = sdsaldo_fin_de_dia -` |  |
| L201 | FÓRMULA | `let sdsaldo_fin_de_dia = sdsaldo_inicio_dia -` |  |
| L259 | VALIDACIÓN_NULL | `if w_cargos_dia is null then` |  |
| L279 | VALIDACIÓN_NULL | `if w_abonos_dia is null then` |  |
| L299 | VALIDACIÓN_NULL | `if w_debito_dia_ant is null then` |  |
| L319 | VALIDACIÓN_NULL | `if w_credito_dia_ant is null then` |  |
| L327 | FÓRMULA | `let sdsaldo_inicio_dia = sdsaldo_fin_de_dia +` |  |
| L329 | FÓRMULA | `let sdsaldo_fin_de_dia = sdsaldo_inicio_dia +` |  |
| L334 | FÓRMULA | `let sdsaldo_inicio_dia = sdsaldo_fin_de_dia -` |  |
| L336 | FÓRMULA | `let sdsaldo_fin_de_dia = sdsaldo_inicio_dia -` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `gen` | ACCION | genera / general | 🟡 INFERIDO | nombre_sp |
| `balp` | ENTIDAD | balp — balance preventivo / balanza preventiva (gen_balprev* | 🔴 SINTÉTICO | nombre_sp |
| `rev` | ACCION | reversión (abreviación de reversa/reverso) | 🟡 INFERIDO | nombre_sp |
| `reg` | ACCION | registro | 🟡 INFERIDO | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `balp` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `gen_encab`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_gen_encab.sql` |
| **LOC (1er CREATE)** | 47 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "genera" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `genera` → `INSERT` encontrado en el cuerpo · `genera` → `SELECT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=0 · INFERIDO=1 · SINTÉTICO=1 / 2 términos |

### Firma

```sql
CREATE PROCEDURE gen_encab(
  pempresa                     char(3)
  pusuario                     char(8)
  pfecha_hoy                   date
  pcontrol_poliza              integer
) RETURNING char(3)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pempresa` | `char(3)` | — | — |
| `pusuario` | `char(8)` | — | — |
| `pfecha_hoy` | `date` | — | — |
| `pcontrol_poliza` | `integer` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cod_ret` | `char(3)` | L6 |
| `v_moneda` | `char(2)` | L7 |
| `v_descripcion` | `char(40)` | L8 |
| `v_monto` | `money(14,2)` | L9 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `co_detpol` | `bdicont` | no | SELECT | L30 |
| `co_poliza` | `bdicont` | no | INSERT | L42 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L21 | VALIDACIÓN_NULL | `if pusuario    is null  or` |  |
| L36 | VALIDACIÓN_NULL | `if v_monto is null then` |  |
| L39 | VALIDACIÓN_NULL | `if v_moneda is null then` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `gen` | ACCION | genera / general | 🟡 INFERIDO | nombre_sp |
| `?_encab` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_encab` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `gen_repbal`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_gen_repbal.sql` |
| **LOC (1er CREATE)** | 540 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "genera" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `genera` → `INSERT` encontrado en el cuerpo · `genera` → `SELECT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=1 · INFERIDO=1 · SINTÉTICO=1 / 3 términos |

### Firma

```sql
CREATE PROCEDURE gen_repbal(
  p_val                        char(2)
  p_ext                        char(2)
  w_fecha                      date
  v_empresa                    char(3)
  v_moneda                     char(2)
  v_usuario                    char(10)
)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_val` | `char(2)` | — | — |
| `p_ext` | `char(2)` | — | — |
| `w_fecha` | `date` | — | — |
| `v_empresa` | `char(3)` | — | — |
| `v_moneda` | `char(2)` | — | — |
| `v_usuario` | `char(10)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `c_empresa` | `char(3)` | L4 |
| `c_ccmayor` | `char(10)` | L5 |
| `c_ccsub` | `char(10)` | L6 |
| `c_ccsubsub` | `char(10)` | L7 |
| `c_ccssubsub` | `char(10)` | L8 |
| `c_ccsssubsub` | `char(10)` | L9 |
| `c_sector` | `char(10)` | L10 |
| `c_ciudad` | `char(3)` | L11 |
| `c_sucursal` | `char(4)` | L12 |
| `c_moneda` | `char(2)` | L13 |
| `c_cargos_dia` | `money(18,2)` | L14 |
| `c_abonos_dia` | `money(18,2)` | L15 |
| `c_saldo_anterior` | `money(18,2)` | L16 |
| `c_saldo_actual` | `money(18,2)` | L17 |
| `c_naturaleza_cta` | `char(1)` | L18 |
| `lv_fechac` | `date` | L19 |
| `lv_mes_dia` | `date` | L20 |
| `w_fecha1` | `date` | L21 |
| `w_fecha2` | `date` | L22 |
| `lv_ano_mes` | `datetime year to month` | L23 |
| `lv_ano_mes1` | `datetime year to month` | L24 |
| `v_ano` | `char(4)` | L25 |
| `v_mes` | `char(2)` | L26 |
| `c_promedio_anual` | `money(18,2)` | L27 |
| `mes_ant` | `int` | L28 |
| *…3 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `co_fechas` | `bdicont` | no | SELECT | L48 |
| `co_balanza` | `bdicont` | no | SELECT | L55 |
| `co_balanza` | `bdicont` | no | DELETE | L55 |
| `co_histsdodias` | `bdicont` | no | SELECT | L78 |
| `co_balanza` | `bdicont` | no | INSERT | L92 |
| `co_sdodias` | `bdicont` | no | SELECT | L126 |
| `co_sdomes` | `bdicont` | no | SELECT | L228 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `gen_balprev` | `bdicont` | no | L104 |
| `ctas_nuevas` | `bdicont` | no | L105 |
| `sp_generarbalanzadiariaconsolidadamn` | `bdicont` | no | L155 |
| `sp_generarbalanzadiariaconsolidadamx` | `bdicont` | no | L161 |
| `sp_generarbalanzamensualconsolidadamn` | `bdicont` | no | L255 |
| `sp_generarbalanzamensualconsolidadamx` | `bdicont` | no | L261 |
| `gen_totalbalanza` | `bdicont` | no | L538 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L298 | FÓRMULA | `let mes_ant = month(w_fecha) - 1;` |  |
| L336 | FÓRMULA | `let w_fecha1 = w_fecha - 1 units month;` |  |
| L339 | FÓRMULA | `let w_fecha1 = w_fecha - 2 units month;` |  |
| L342 | FÓRMULA | `let w_fecha1 = w_fecha - 3 units month;` |  |
| L345 | FÓRMULA | `let w_fecha1 = w_fecha - 4 units month;` |  |
| L348 | FÓRMULA | `let w_fecha1 = w_fecha - 5 units month;` |  |
| L351 | FÓRMULA | `let w_fecha1 = w_fecha - 6 units month;` |  |
| L354 | FÓRMULA | `let w_fecha1 = w_fecha - 7 units month;` |  |
| L357 | FÓRMULA | `let w_fecha1 = w_fecha - 8 units month;` |  |
| L360 | FÓRMULA | `let w_fecha1 = w_fecha - 9 units month;` |  |
| L363 | FÓRMULA | `let w_fecha1 = w_fecha - 10 units month;` |  |
| L366 | FÓRMULA | `let w_fecha1 = w_fecha - 11 units month;` |  |
| L369 | FÓRMULA | `let lv_mes_dia = '01/01/'\|\|year(w_fecha);` |  |
| L372 | FÓRMULA | `let lv_mes_dia = w_fecha - 1 units month;` |  |
| L388 | FÓRMULA | `LET c_promedio_anual=c_promedio_anual/month(lv_ano_mes);` |  |
| L433 | FÓRMULA | `let mes_ant = month(w_fecha) - 1;` |  |
| L474 | FÓRMULA | `let w_fecha1 = w_fecha - 1 units month;` |  |
| L477 | FÓRMULA | `let w_fecha1 = w_fecha - 2 units month;` |  |
| L480 | FÓRMULA | `let w_fecha1 = w_fecha - 3 units month;` |  |
| L483 | FÓRMULA | `let w_fecha1 = w_fecha - 4 units month;` |  |
| L486 | FÓRMULA | `let w_fecha1 = w_fecha - 5 units month;` |  |
| L489 | FÓRMULA | `let w_fecha1 = w_fecha - 6 units month;` |  |
| L492 | FÓRMULA | `let w_fecha1 = w_fecha - 7 units month;` |  |
| L495 | FÓRMULA | `let w_fecha1 = w_fecha - 8 units month;` |  |
| L498 | FÓRMULA | `let w_fecha1 = w_fecha - 9 units month;` |  |
| L501 | FÓRMULA | `let w_fecha1 = w_fecha - 10 units month;` |  |
| L504 | FÓRMULA | `let w_fecha1 = w_fecha - 11 units month;` |  |
| L507 | FÓRMULA | `let lv_mes_dia = '01/01/'\|\|year(w_fecha);` |  |
| L527 | FÓRMULA | `LET c_promedio_anual=c_promedio_anual/(month(lv_ano_mes));` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `gen` | ACCION | genera / general | 🟡 INFERIDO | nombre_sp |
| `rep` | ACCION | reporte | 🔵 CONVENCIÓN | nombre_sp |
| `?bal` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?bal` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `gen_repbalccpba`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_gen_repbalccpba.sql` |
| **LOC (1er CREATE)** | 561 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "genera código postal" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `genera` → `INSERT` encontrado en el cuerpo · `genera` → `SELECT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=1 · INFERIDO=2 · SINTÉTICO=2 / 5 términos |

### Firma

```sql
CREATE PROCEDURE gen_repbalccpba(
  p_val                        char(2)
  p_ext                        char(2)
  w_fecha                      char(10)
  v_empresa                    char(3)
  v_moneda                     char(2)
  v_usuario                    char(10)
)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_val` | `char(2)` | — | — |
| `p_ext` | `char(2)` | — | — |
| `w_fecha` | `char(10)` | — | — |
| `v_empresa` | `char(3)` | — | — |
| `v_moneda` | `char(2)` | — | — |
| `v_usuario` | `char(10)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `c_empresa` | `char(3)` | L3 |
| `c_ccmayor` | `char(10)` | L4 |
| `c_ccsub` | `char(10)` | L5 |
| `c_ccsubsub` | `char(10)` | L6 |
| `c_ccssubsub` | `char(10)` | L7 |
| `c_ccsssubsub` | `char(10)` | L8 |
| `c_sector` | `char(10)` | L9 |
| `c_ciudad` | `char(3)` | L10 |
| `c_sucursal` | `char(4)` | L11 |
| `c_moneda` | `char(2)` | L12 |
| `c_cargos_dia` | `money(18,2)` | L13 |
| `c_abonos_dia` | `money(18,2)` | L14 |
| `c_saldo_anterior` | `money(18,2)` | L15 |
| `c_saldo_actual` | `money(18,2)` | L16 |
| `c_naturaleza_cta` | `char(1)` | L17 |
| `lv_fechac` | `date` | L18 |
| `lv_mes_dia` | `date` | L19 |
| `lv_ano_mes` | `datetime year to month` | L20 |
| `v_ano` | `char(4)` | L21 |
| `v_mes` | `char(2)` | L22 |
| `w_fecha1` | `date` | L23 |
| `w_fecha2` | `date` | L24 |
| `lv_ano_mes1` | `datetime   year to month` | L27 |
| `c_promedio_anual` | `money(18,2)` | L28 |
| `mes_ant` | `int` | L29 |
| *…2 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `co_fechas` | `bdicont` | no | SELECT | L42 |
| `co_balanza` | `bdicont` | no | SELECT | L49 |
| `co_balanza` | `bdicont` | no | DELETE | L49 |
| `co_histsdodias` | `bdicont` | no | SELECT | L80 |
| `si_sucursales` | `bdinteg` | ⚠️ sí | SELECT | L96 |
| `si_plazas` | `bdinteg` | ⚠️ sí | SELECT | L102 |
| `co_balanza` | `bdicont` | no | INSERT | L108 |
| `co_sdodias` | `bdicont` | no | SELECT | L136 |
| `co_sdomes` | `bdicont` | no | SELECT | L247 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `gen_balprevcc` | `bdicont` | no | L54 |
| `ctas_nuevascc` | `bdicont` | no | L55 |
| `gen_totalbalanza` | `bdicont` | no | L559 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L339 | FÓRMULA | `let mes_ant = month(w_fecha) - 1;` |  |
| L343 | FÓRMULA | `let lv_mes_dia = '01/01/'\|\|year(w_fecha);` |  |
| L346 | FÓRMULA | `let lv_mes_dia = w_fecha - 1 units month;` |  |
| L373 | FÓRMULA | `LET c_promedio_anual=c_promedio_anual/month(lv_ano_mes);}` |  |
| L375 | FÓRMULA | `let lv_mes_dia = '01/01/'\|\|year(w_fecha);` |  |
| L378 | FÓRMULA | `let lv_mes_dia = w_fecha - 1 units month;` |  |
| L396 | FÓRMULA | `LET c_promedio_anual=c_promedio_anual/month(lv_ano_mes);` |  |
| L481 | FÓRMULA | `let mes_ant = month(w_fecha) - 1;` |  |
| L510 | FÓRMULA | `LET c_promedio_anual=(c_saldo_actual+c_saldo_anterior)/(month(w_fecha));}` |  |
| L512 | FÓRMULA | `let lv_mes_dia = '01/01/'\|\|year(w_fecha);` |  |
| L533 | FÓRMULA | `LET c_promedio_anual=c_promedio_anual/(month(lv_ano_mes));` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `gen` | ACCION | genera / general | 🟡 INFERIDO | nombre_sp |
| `rep` | ACCION | reporte | 🔵 CONVENCIÓN | nombre_sp |
| `?balc` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `cp` | ENTIDAD | código postal | 🟡 INFERIDO | nombre_sp |
| `?ba` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?balc`, `?ba` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `gen_repbalreg`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_gen_repbalreg.sql` |
| **LOC (1er CREATE)** | 486 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "genera" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `genera` → `INSERT` encontrado en el cuerpo · `genera` → `SELECT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=1 · INFERIDO=2 · SINTÉTICO=1 / 4 términos |

### Firma

```sql
CREATE PROCEDURE gen_repbalreg(
  p_val                        char(2)
  p_ext                        char(2)
  w_fecha                      date
  v_empresa                    char(3)
  v_moneda                     char(2)
  v_usuario                    char(10)
)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_val` | `char(2)` | — | — |
| `p_ext` | `char(2)` | — | — |
| `w_fecha` | `date` | — | — |
| `v_empresa` | `char(3)` | — | — |
| `v_moneda` | `char(2)` | — | — |
| `v_usuario` | `char(10)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `c_empresa` | `char(3)` | L3 |
| `c_ccmayor` | `char(10)` | L4 |
| `c_ccsub` | `char(10)` | L5 |
| `c_ccsubsub` | `char(10)` | L6 |
| `c_ccssubsub` | `char(10)` | L7 |
| `c_ccsssubsub` | `char(10)` | L8 |
| `c_sector` | `char(10)` | L9 |
| `c_ciudad` | `char(3)` | L10 |
| `c_sucursal` | `char(4)` | L11 |
| `c_moneda` | `char(2)` | L12 |
| `c_cargos_dia` | `money(18,2)` | L13 |
| `c_abonos_dia` | `money(18,2)` | L14 |
| `c_saldo_anterior` | `money(18,2)` | L15 |
| `c_saldo_actual` | `money(18,2)` | L16 |
| `c_naturaleza_cta` | `char(1)` | L17 |
| `lv_fechac` | `date` | L18 |
| `lv_mes_dia` | `date` | L19 |
| `lv_mes_dia1` | `date` | L20 |
| `lv_ano_mes` | `datetime year to month` | L21 |
| `lv_ano_mes1` | `datetime year to month` | L22 |
| `w_fecha1` | `date` | L24 |
| `w_fecha2` | `date` | L25 |
| `v_ano` | `char(4)` | L26 |
| `v_mes` | `char(2)` | L27 |
| `c_promedio_anual` | `money(18,2)` | L28 |
| *…3 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `co_fechas` | `bdicont` | no | SELECT | L39 |
| `co_balanza` | `bdicont` | no | SELECT | L50 |
| `co_balanza` | `bdicont` | no | DELETE | L50 |
| `co_histsdodias` | `bdicont` | no | SELECT | L72 |
| `si_sucursales` | `bdinteg` | ⚠️ sí | SELECT | L92 |
| `si_plazas` | `bdinteg` | ⚠️ sí | SELECT | L98 |
| `co_balanza` | `bdicont` | no | INSERT | L104 |
| `co_sdodias` | `bdicont` | no | SELECT | L141 |
| `co_sdomes` | `bdicont` | no | SELECT | L271 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `gen_balprevreg` | `bdicont` | no | L117 |
| `ctas_nuevasreg` | `bdicont` | no | L118 |
| `gen_totalbalanza` | `bdicont` | no | L484 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L367 | FÓRMULA | `let lv_mes_dia = '01/01/'\|\|year(w_fecha);` |  |
| L370 | FÓRMULA | `let lv_mes_dia = w_fecha - 1 units month;` |  |
| L386 | FÓRMULA | `LET c_promedio_anual=c_promedio_anual/month(lv_ano_mes);` |  |
| L453 | FÓRMULA | `let lv_mes_dia = '01/01/'\|\|year(w_fecha);` |  |
| L472 | FÓRMULA | `LET c_promedio_anual=c_promedio_anual/(month(lv_ano_mes));` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `gen` | ACCION | genera / general | 🟡 INFERIDO | nombre_sp |
| `rep` | ACCION | reporte | 🔵 CONVENCIÓN | nombre_sp |
| `?bal` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `reg` | ACCION | registro | 🟡 INFERIDO | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?bal` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `gen_totalbalanza`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_gen_totalbalanza.sql` |
| **LOC (1er CREATE)** | 1261 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "genera balanza de comprobación — trial balance (total)" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `genera` → `INSERT` encontrado en el cuerpo · `genera` → `SELECT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=1 · INFERIDO=1 · SINTÉTICO=0 / 3 términos |

### Firma

```sql
CREATE PROCEDURE gen_totalbalanza(
  pempresa                     char(3)
  p_val                        char(2)
  w_fecha                      date
  p_ext                        char(2)
  v_usuario                    char(10)
)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pempresa` | `char(3)` | — | — |
| `p_val` | `char(2)` | — | — |
| `w_fecha` | `date` | — | — |
| `p_ext` | `char(2)` | — | — |
| `v_usuario` | `char(10)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `bpempresa` | `char(3)` | L3 |
| `bpccmayor` | `char(10)` | L4 |
| `bpccsub` | `char(10)` | L5 |
| `bpccsubsub` | `char(10)` | L6 |
| `bpccssubsub` | `char(10)` | L7 |
| `bpccsssubsub` | `char(10)` | L8 |
| `bpsector` | `char(10)` | L9 |
| `bpciudad` | `char(3)` | L10 |
| `bpsucursal` | `char(4)` | L11 |
| `bpmoneda` | `char(2)` | L12 |
| `bpmes_dia` | `char(10)` | L13 |
| `bpsaldo_dia_anterior` | `money(18,2)` | L14 |
| `bpcargos_dia` | `money(18,2)` | L15 |
| `bpabonos_dia` | `money(18,2)` | L16 |
| `bpsaldo_actual` | `money(18,2)` | L17 |
| `bptipo_cta` | `char(1)` | L18 |
| `bpromedio_anual` | `money(18,2)` | L19 |
| `baccmayor` | `char(10)` | L21 |
| `baccsub` | `char(10)` | L22 |
| `baccsubsub` | `char(10)` | L23 |
| `baccssubsub` | `char(10)` | L24 |
| `baccsssubsub` | `char(10)` | L25 |
| `basector` | `char(10)` | L26 |
| `v_mayor` | `char(10)` | L28 |
| `v_mayor1` | `char(1)` | L29 |
| *…25 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `co_param` | `bdicont` | no | SELECT | L63 |
| `co_balanza` | `bdicont` | no | SELECT | L115 |
| `co_balanza` | `bdicont` | no | INSERT | L188 |
| `si_catalog` | `bdinteg` | ⚠️ sí | SELECT | L1129 |
| `si_sucursales` | `bdinteg` | ⚠️ sí | SELECT | L1140 |
| `sp_preciocontable` | `bdirepaut` | ⚠️ sí | SELECT | L1206 |
| `co_balanza` | `bdicont` | no | DELETE | L1253 |
| `balan` | `bdicont` | no | SELECT | L1256 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L1210 | VALIDACIÓN_NULL | `IF v_tpc = 0 OR v_tpc IS NULL THEN` |  |
| L1214 | FÓRMULA | `LET bpsaldo_dia_anterior = bpsaldo_dia_anterior * v_tpc;` |  |
| L1215 | FÓRMULA | `LET bpcargos_dia         = bpcargos_dia * v_tpc;` |  |
| L1216 | FÓRMULA | `LET bpabonos_dia         = bpabonos_dia * v_tpc;` |  |
| L1217 | FÓRMULA | `LET bpsaldo_actual       = bpsaldo_actual * v_tpc;` |  |
| L1218 | FÓRMULA | `LET bpromedio_anual      = bpromedio_anual * v_tpc;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `gen` | ACCION | genera / general | 🟡 INFERIDO | nombre_sp |
| `total` | MODIF | total | 🔵 CONVENCIÓN | nombre_sp |
| `balanza` | ENTIDAD | balanza de comprobación — trial balance (sp_generarbalanza*  | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |

---

## `gen_totaliz`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_gen_totaliz.sql` |
| **LOC (1er CREATE)** | 1206 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "genera (total)" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `genera` → `INSERT` encontrado en el cuerpo · `genera` → `SELECT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=1 · INFERIDO=1 · SINTÉTICO=1 / 3 términos |

### Firma

```sql
CREATE PROCEDURE gen_totaliz(
  pempresa                     char(3)
)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pempresa` | `char(3)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `bpempresa` | `char(3)` | L3 |
| `bpccmayor` | `char(10)` | L4 |
| `bpccsub` | `char(10)` | L5 |
| `bpccsubsub` | `char(10)` | L6 |
| `bpccssubsub` | `char(10)` | L7 |
| `bpccsssubsub` | `char(10)` | L8 |
| `bpsector` | `char(10)` | L9 |
| `bpciudad` | `char(3)` | L10 |
| `bpsucursal` | `char(3)` | L11 |
| `bpmoneda` | `char(2)` | L12 |
| `bpmes_dia` | `char(10)` | L13 |
| `bpsaldo_anterior` | `money(18,2)` | L14 |
| `bpcargos_dia` | `money(18,2)` | L15 |
| `bpabonos_dia` | `money(18,2)` | L16 |
| `bpsaldo_actual` | `money(18,2)` | L17 |
| `bptipo_cta` | `char(1)` | L18 |
| `baccmayor` | `char(10)` | L20 |
| `baccsub` | `char(10)` | L21 |
| `baccsubsub` | `char(10)` | L22 |
| `baccssubsub` | `char(10)` | L23 |
| `baccsssubsub` | `char(10)` | L24 |
| `basector` | `char(10)` | L25 |
| `v_mayor` | `char(10)` | L27 |
| `v_mayor1` | `char(1)` | L28 |
| `v_mayor2` | `char(10)` | L29 |
| *…17 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `co_param` | `bdicont` | no | SELECT | L53 |
| `co_balprev` | `bdicont` | no | SELECT | L112 |
| `co_balprev` | `bdicont` | no | INSERT | L184 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `gen` | ACCION | genera / general | 🟡 INFERIDO | nombre_sp |
| `total` | MODIF | total | 🔵 CONVENCIÓN | nombre_sp |
| `?iz` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?iz` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `gen_totalizvar`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_gen_totalizvar.sql` |
| **LOC (1er CREATE)** | 917 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "genera (total)" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `genera` → `INSERT` encontrado en el cuerpo · `genera` → `SELECT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=1 · INFERIDO=1 · SINTÉTICO=1 / 3 términos |

### Firma

```sql
CREATE PROCEDURE gen_totalizvar(
  pempresa                     char(3)
)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pempresa` | `char(3)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `bpempresa` | `char(3)` | L3 |
| `bpccmayor` | `char(10)` | L4 |
| `bpccsub` | `char(10)` | L5 |
| `bpccsubsub` | `char(10)` | L6 |
| `bpccssubsub` | `char(10)` | L7 |
| `bpccsssubsub` | `char(10)` | L8 |
| `bpsector` | `char(10)` | L9 |
| `bpciudad` | `char(3)` | L10 |
| `bpsucursal` | `char(3)` | L11 |
| `bpmoneda` | `char(2)` | L12 |
| `bpmes_dia` | `char(10)` | L13 |
| `bpsaldo_anterior` | `money(18,2)` | L14 |
| `bpcargos_dia` | `money(18,2)` | L15 |
| `bpabonos_dia` | `money(18,2)` | L16 |
| `bpsaldo_actual` | `money(18,2)` | L17 |
| `bptipo_cta` | `char(1)` | L18 |
| `baccmayor` | `char(10)` | L20 |
| `baccsub` | `char(10)` | L21 |
| `baccsubsub` | `char(10)` | L22 |
| `baccssubsub` | `char(10)` | L23 |
| `baccsssubsub` | `char(10)` | L24 |
| `basector` | `char(10)` | L25 |
| `v_mayor` | `char(10)` | L27 |
| `v_mayor1` | `char(1)` | L28 |
| `v_mayor2` | `char(10)` | L29 |
| *…17 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `co_paramcta` | `bdicont` | no | SELECT | L53 |
| `co_balprev` | `bdicont` | no | SELECT | L112 |
| `co_balprev` | `bdicont` | no | INSERT | L168 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `gen` | ACCION | genera / general | 🟡 INFERIDO | nombre_sp |
| `total` | MODIF | total | 🔵 CONVENCIÓN | nombre_sp |
| `?izvar` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?izvar` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `genpoliza`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_genpoliza.sql` |
| **LOC (1er CREATE)** | 127 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "genera póliza contable" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `genera` → `INSERT` encontrado en el cuerpo · `genera` → `SELECT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=0 · INFERIDO=1 · SINTÉTICO=0 / 2 términos |

### Firma

```sql
CREATE PROCEDURE genpoliza(
  poliza_ori                   integer
  pusuario_ori                 varchar (8)
  fec_cap_ori                  date
  pusuario_des                 varchar (8)
  fec_hoy                      date
) RETURNING CHAR(5),char(255)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `poliza_ori` | `integer` | `poliza`=póliza contable | ✅ CÓDIGO |
| `pusuario_ori` | `varchar (8)` | — | — |
| `fec_cap_ori` | `date` | — | — |
| `pusuario_des` | `varchar (8)` | — | — |
| `fec_hoy` | `date` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `r_codret` | `char(5)` | L5 |
| `r_mensaje` | `varchar(255)` | L6 |
| `v_numpoliza` | `INTEGER` | L9 |
| `iSqlErr` | `INTEGER` | L11 |
| `iSamErr` | `INTEGER` | L12 |
| `vDesErr` | `VARCHAR(60)` | L13 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `co_mensual` | `bdicont` | no | SELECT | L36 |
| `tmp_natori_d` | `bdicont` | no | SELECT | L61 |
| `pol_comp` | `bdicont` | no | INSERT | L64 |
| `tmp_natori_c` | `bdicont` | no | SELECT | L66 |
| `co_ctrlpoliza` | `bdicont` | no | SELECT | L70 |
| `pol_comp` | `bdicont` | no | UPDATE | L77 |
| `co_detpol` | `bdicont` | no | INSERT | L80 |
| `pol_comp` | `bdicont` | no | SELECT | L106 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `gen_encab` | `bdicont` | no | L108 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `gen` | ACCION | genera / general | 🟡 INFERIDO | nombre_sp |
| `poliza` | ENTIDAD | póliza contable | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |

---

## `grabarpasesuc`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_grabarpasesuc.sql` |
| **LOC (1er CREATE)** | 63 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "graba (sucursal)" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 2 tabla(s) con operaciones: SELECT, INSERT |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=2 · INFERIDO=1 · SINTÉTICO=1 / 4 términos |

### Historia del SP

| Tipo | Valor |
|------|-------|
| FECHA | 16/04/2009 |

### Firma

```sql
CREATE PROCEDURE grabarpasesuc(
  pEmpresa                     CHAR(3)
  pFechaValor                  DATE
  pSucursal                    CHAR(4)
  pFechaAutoriza               DATE
  pUsuario                     CHAR(8)
) RETURNING VARCHAR(5)         -- CodigoRetorno
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pEmpresa` | `CHAR(3)` | — | — |
| `pFechaValor` | `DATE` | — | — |
| `pSucursal` | `CHAR(4)` | `suc`=sucursal | 🟡 INFERIDO |
| `pFechaAutoriza` | `DATE` | — | — |
| `pUsuario` | `CHAR(8)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cVarDataErr` | `VARCHAR(255)` | L23 |
| `iSqlErr` | `INTEGER` | L24 |
| `iSamErr` | `INTEGER` | L25 |
| `cCodRet` | `CHAR(5)` | L27 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `co_clv_pasesuc` | `bdicont` | no | SELECT | L50 |
| `co_clv_pasesuc` | `bdicont` | no | INSERT | L55 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L43 | VALIDACIÓN_NULL | `IF pFechaValor IS NULL OR pEmpresa IS NULL OR pEmpresa = '' OR` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `graba` | ACCION | graba / almacena | 🔵 CONVENCIÓN | nombre_sp |
| `?r` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `pase` | ACCION | pase contable (registra/traslada a póliza o mayor) | 🔵 CONVENCIÓN | nombre_sp |
| `suc` | MODIF | sucursal | 🟡 INFERIDO | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?r` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `inicializa`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_inicializa.sql` |
| **LOC (1er CREATE)** | 482 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "inicializa" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 18 tabla(s) con operaciones: DELETE, SELECT, INSERT |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=0 · INFERIDO=0 · SINTÉTICO=0 / 1 términos |

### Firma

```sql
CREATE PROCEDURE inicializa(
  pempresa                     char(3)
  pfecha_hoy                   date
)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pempresa` | `char(3)` | — | — |
| `pfecha_hoy` | `date` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `sql_err` | `INTEGER` | L3 |
| `dpri_dia_mes` | `date` | L5 |
| `dpri_hab_mes` | `date` | L6 |
| `dult_dia_mes` | `date` | L7 |
| `dult_hab_mes` | `date` | L8 |
| `dfecha_ant` | `date` | L9 |
| `v_fecha_mes_sald` | `date` | L10 |
| `v_fecha_sald_temp` | `char(10)` | L11 |
| `mes_sald` | `char(2)` | L12 |
| `v_fecha_mes_hist` | `date` | L13 |
| `v_fecha_hist_temp` | `char(10)` | L14 |
| `mes_hist` | `char(2)` | L15 |
| `v_mes` | `char(2)` | L16 |
| `v_meshist` | `char(2)` | L17 |
| `v_mesc1` | `char(2)` | L18 |
| `v_mesc2` | `char(2)` | L19 |
| `v_amo` | `char(4)` | L20 |
| `v_amohist` | `char(4)` | L21 |
| `v_numcols` | `smallint` | L22 |
| `v_sql` | `char(400)` | L23 |
| `nomb_tabla` | `char(5)` | L24 |
| `v_tabla` | `char(20)` | L25 |
| `m_ant` | `char(2)` | L26 |
| `v_anomeshist` | `char(7)` | L27 |
| `v_tablaid` | `integer` | L28 |
| *…3 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `co_fechas` | `bdicont` | no | SELECT | L40 |
| `co_param` | `bdicont` | no | SELECT | L45 |
| `co_contproc_inicializa` | `bdicont` | no | INSERT | L79 |
| `co_historico` | `bdicont` | no | SELECT | L89 |
| `co_historico` | `bdicont` | no | DELETE | L107 |
| `co_histsdodias` | `bdicont` | no | SELECT | L131 |
| `co_histsdodias` | `bdicont` | no | DELETE | L139 |
| `co_histdiasaux` | `bdicont` | no | SELECT | L163 |
| `co_histdiasaux` | `bdicont` | no | DELETE | L171 |
| `co_sdomes` | `bdicont` | no | SELECT | L199 |
| `co_sdomes` | `bdicont` | no | DELETE | L216 |
| `co_sdodias` | `bdicont` | no | SELECT | L260 |
| `co_sdodias` | `bdicont` | no | INSERT | L280 |
| `co_diasaux` | `bdicont` | no | SELECT | L329 |
| `co_diasaux` | `bdicont` | no | INSERT | L349 |
| `co_detpol` | `bdicont` | no | SELECT | L431 |
| `co_contproc` | `bdicont` | no | SELECT | L451 |
| `co_contproc` | `bdicont` | no | DELETE | L451 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L54 | FÓRMULA | `LET v_fecha_mes_sald = pfecha_hoy - mes_sald units MONTH;` |  |
| L55 | FÓRMULA | `LET v_fecha_mes_hist = pfecha_hoy - mes_hist units MONTH;` |  |
| L76 | FÓRMULA | `LET v_anomeshist = v_amohist\|\|"-"\|\|v_meshist;` |  |
| L110 | FÓRMULA | `LET pcontador = pcontador + 1;` |  |
| L142 | FÓRMULA | `LET pcontador = pcontador + 1;` |  |
| L174 | FÓRMULA | `LET pcontador = pcontador + 1;` |  |
| L219 | FÓRMULA | `LET pcontador = pcontador + 1;` |  |
| L239 | FÓRMULA | `LET v_sql ="dbschema -q -d bdicont -t co_mensual -p all tabla; sed /revoke/d tabla > tabla.sql";` |  |
| L248 | FÓRMULA | `LET v_sql = "dbaccess bdicont tabla 2>/dev/null > /dev/null";` |  |
| L267 | FÓRMULA | `LET v_sql ="dbschema -q -d bdicont -t co_sdodias -p all tabla; sed /revoke/d tabla > tabla.sql";` |  |
| L276 | FÓRMULA | `LET v_sql = "dbaccess bdicont tabla 2>/dev/null > /dev/null";` |  |
| L284 | FÓRMULA | `LET v_sql = "dbload -d bdicont -c carga -l er -n 100";` |  |
| L336 | FÓRMULA | `LET v_sql ="dbschema -q -d bdicont -t co_diasaux -p all tabla; sed /revoke/d tabla > tabla.sql";` |  |
| L345 | FÓRMULA | `LET v_sql = "dbaccess bdicont tabla 2>/dev/null > /dev/null";` |  |
| L353 | FÓRMULA | `LET v_sql = "dbload -d bdicont -c carga -l er -n 100";` |  |
| L403 | FÓRMULA | `LET v_sql ="dbschema -q -d bdicont -t co_diario -p all tabla; sed /revoke/d tabla > tabla.sql";` |  |
| L412 | FÓRMULA | `LET v_sql = "dbaccess bdicont tabla 2>/dev/null > /dev/null";` |  |
| L458 | FÓRMULA | `LET v_sql ="dbschema -q -d bdicont -t co_diario -p all tabla; sed /revoke/d tabla > tabla.sql";` |  |
| L468 | FÓRMULA | `LET v_sql = "dbaccess bdicont tabla 2>/dev/null > /dev/null";` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `inicializa` | ACCION | inicializa | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |

---

## `ins_act_hist`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_ins_act_hist.sql` |
| **LOC (1er CREATE)** | 72 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "insertar (histórico/historial)" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `inserta` → `INSERT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=2 · INFERIDO=1 · SINTÉTICO=0 / 3 términos |

### Firma

```sql
CREATE PROCEDURE ins_act_hist(
  pempresa                     char(3)
) RETURNING CHAR(5)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pempresa` | `char(3)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cod_ret` | `char(5)` | L4 |
| `vmoneda` | `char(2)` | L7 |
| `v_ciudad` | `char(3)` | L8 |
| `vsucursal` | `char(4)` | L9 |
| `v_empresa` | `char(3)` | L10 |
| `vnro_auxiliar` | `char(12)` | L12 |
| `vdescripcion` | `char(50)` | L13 |
| `vsecuencia` | `integer` | L16 |
| `vcontrol_poliza` | `integer` | L17 |
| `vccost_orig` | `char (4)` | L18 |
| `vcontador` | `INTEGER` | L19 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `co_historico_tmp` | `bdicont` | no | SELECT | L41 |
| `co_historico` | `bdicont` | no | INSERT | L48 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L59 | FÓRMULA | `LET vcontador = vcontador + 1 ;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `ins` | ACCION | insertar | 🟡 INFERIDO | nombre_sp |
| `act` | ACCION | actualiza | 🔵 CONVENCIÓN | nombre_sp |
| `hist` | MODIF | histórico/historial | 🔵 CONVENCIÓN | nombre_sp |

---

## `ins_act_histsdos`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_ins_act_histsdos.sql` |
| **LOC (1er CREATE)** | 68 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "insertar saldos (histórico/historial)" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `inserta` → `INSERT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=2 · INFERIDO=2 · SINTÉTICO=0 / 4 términos |

### Firma

```sql
CREATE PROCEDURE ins_act_histsdos(
  pempresa                     char(3)
) RETURNING CHAR(5)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pempresa` | `char(3)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cod_ret` | `char(5)` | L4 |
| `hempresa` | `char(3)` | L5 |
| `hccmayor` | `char(10)` | L6 |
| `hccsub` | `char(10)` | L7 |
| `hccsubsub` | `char(10)` | L8 |
| `hccssubsub` | `char(10)` | L9 |
| `hccsssubsub` | `char(10)` | L10 |
| `hsector` | `char(10)` | L11 |
| `hciudad` | `char(3)` | L12 |
| `hsucursal` | `char(4)` | L13 |
| `hmoneda` | `char(2)` | L14 |
| `hmes_dia` | `date` | L15 |
| `hcargos_dia` | `money(18,2)` | L16 |
| `habonos_dia` | `money(18,2)` | L17 |
| `hnro_cargos_dia` | `integer` | L18 |
| `hnro_abonos_dia` | `integer` | L19 |
| `hdias_proyectado` | `smallint` | L20 |
| `hdias_acumulado` | `smallint` | L21 |
| `hsaldo_acumulado` | `money(18,2)` | L22 |
| `hsaldo_inicio_dia` | `money(18,2)` | L23 |
| `hsaldo_fin_de_dia` | `money(18,2)` | L24 |
| `vcontador` | `INTEGER` | L25 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `co_histsdodias_tmp` | `bdicont` | no | SELECT | L38 |
| `co_histsdodias` | `bdicont` | no | INSERT | L46 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L55 | FÓRMULA | `LET vcontador = vcontador + 1 ;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `ins` | ACCION | insertar | 🟡 INFERIDO | nombre_sp |
| `act` | ACCION | actualiza | 🔵 CONVENCIÓN | nombre_sp |
| `hist` | MODIF | histórico/historial | 🔵 CONVENCIÓN | nombre_sp |
| `sdos` | ENTIDAD | saldos (abreviación) | 🟡 INFERIDO | nombre_sp |

---

## `inserta_estatus_cierre`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_inserta_estatus_cierre.sql` |
| **LOC (1er CREATE)** | 34 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "inserta estatus" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `inserta` → `INSERT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=0 / 3 términos |

### Firma

```sql
CREATE PROCEDURE inserta_estatus_cierre(
  pempresa                     char(3)
  pfecha_hoy                   DATE
  pdescri_cierre               CHAR(20)
  pestatus_cierre              CHAR(20)
  pcodigo_retorno              CHAR(5)
  pusuario                     char(8)
  psucursal                    CHAR(4)
  phora_inicio                 CHAR(12)
  phora_fin                    CHAR(12)
) RETURNING char(5)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pempresa` | `char(3)` | — | — |
| `pfecha_hoy` | `DATE` | — | — |
| `pdescri_cierre` | `CHAR(20)` | `cierre`=cierre | ✅ CÓDIGO |
| `pestatus_cierre` | `CHAR(20)` | `estatus`=estatus · `cierre`=cierre | ✅ CÓDIGO / 🔵 CONVENCIÓN |
| `pcodigo_retorno` | `CHAR(5)` | — | — |
| `pusuario` | `char(8)` | — | — |
| `psucursal` | `CHAR(4)` | — | — |
| `phora_inicio` | `CHAR(12)` | — | — |
| `phora_fin` | `CHAR(12)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `codret` | `CHAR(5)` | L12 |
| `sql_err` | `INTEGER` | L13 |
| `isam_err` | `INTEGER` | L14 |
| `error_info` | `CHAR(40)` | L15 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_ejecut` | `bdinteg` | ⚠️ sí | SELECT | L21 |
| `co_cierre_cif` | `bdicont` | no | INSERT | L26 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `inserta` | ACCION | inserta / registra | 🔵 CONVENCIÓN | nombre_sp |
| `estatus` | ENTIDAD | estatus | 🔵 CONVENCIÓN | nombre_sp |
| `cierre` | ACCION | cierre | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |

---

## `inserta_estatus_cierre_notran`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_inserta_estatus_cierre_notran.sql` |
| **LOC (1er CREATE)** | 30 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "inserta estatus" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `inserta` → `INSERT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=1 / 4 términos |

### Firma

```sql
CREATE PROCEDURE inserta_estatus_cierre_notran(
  pempresa                     char(3)
  pfecha_hoy                   DATE
  pdescri_cierre               CHAR(20)
  pestatus_cierre              CHAR(20)
  pcodigo_retorno              CHAR(5)
  pusuario                     char(8)
  psucursal                    CHAR(4)
  phora_inicio                 CHAR(12)
  phora_fin                    CHAR(12)
) RETURNING char(5)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pempresa` | `char(3)` | — | — |
| `pfecha_hoy` | `DATE` | — | — |
| `pdescri_cierre` | `CHAR(20)` | `cierre`=cierre | ✅ CÓDIGO |
| `pestatus_cierre` | `CHAR(20)` | `estatus`=estatus · `cierre`=cierre | ✅ CÓDIGO / 🔵 CONVENCIÓN |
| `pcodigo_retorno` | `CHAR(5)` | — | — |
| `pusuario` | `char(8)` | — | — |
| `psucursal` | `CHAR(4)` | — | — |
| `phora_inicio` | `CHAR(12)` | — | — |
| `phora_fin` | `CHAR(12)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `codret` | `CHAR(5)` | L12 |
| `sql_err` | `INTEGER` | L13 |
| `isam_err` | `INTEGER` | L14 |
| `error_info` | `CHAR(40)` | L15 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_ejecut` | `bdinteg` | ⚠️ sí | SELECT | L21 |
| `co_cierre_cif` | `bdicont` | no | INSERT | L24 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `inserta` | ACCION | inserta / registra | 🔵 CONVENCIÓN | nombre_sp |
| `estatus` | ENTIDAD | estatus | 🔵 CONVENCIÓN | nombre_sp |
| `cierre` | ACCION | cierre | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `?_notran` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_notran` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `insertarcointegracion`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_insertarcointegracion.sql` |
| **LOC (1er CREATE)** | 64 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "inserta interés" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `inserta` → `INSERT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=2 / 4 términos |

### Firma

```sql
CREATE PROCEDURE insertarcointegracion(
  p_cempresa                   CHAR(3)
  p_ccosto_orig                CHAR(4)
  p_cusuario                   CHAR(8)
  p_cfecha_captura             DATE
  p_ccuenta                    CHAR(4)
  p_csubcta                    CHAR(2)
  p_csubsubcta                 CHAR(2)
  p_cssubsubcta                CHAR(2)
  p_csssubsubcta               CHAR(2)
  p_csector                    CHAR(2)
  p_cregional                  CHAR(3)
  p_csucursal                  CHAR(4)
  p_cnro_auxiliar              CHAR(12)
  p_cfecha                     DATE
  p_cmoneda                    CHAR(2)
  p_cnaturaleza                CHAR(1)
  p_mimporte                   MONEY(18,2)
  p_cconcepto                  CHAR(80)
  p_cusuario_int               CHAR(8)
) RETURNING CHAR(6)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_cempresa` | `CHAR(3)` | — | — |
| `p_ccosto_orig` | `CHAR(4)` | — | — |
| `p_cusuario` | `CHAR(8)` | — | — |
| `p_cfecha_captura` | `DATE` | — | — |
| `p_ccuenta` | `CHAR(4)` | — | — |
| `p_csubcta` | `CHAR(2)` | — | — |
| `p_csubsubcta` | `CHAR(2)` | — | — |
| `p_cssubsubcta` | `CHAR(2)` | — | — |
| `p_csssubsubcta` | `CHAR(2)` | — | — |
| `p_csector` | `CHAR(2)` | — | — |
| `p_cregional` | `CHAR(3)` | — | — |
| `p_csucursal` | `CHAR(4)` | — | — |
| `p_cnro_auxiliar` | `CHAR(12)` | — | — |
| `p_cfecha` | `DATE` | — | — |
| `p_cmoneda` | `CHAR(2)` | — | — |
| `p_cnaturaleza` | `CHAR(1)` | — | — |
| `p_mimporte` | `MONEY(18,2)` | — | — |
| `p_cconcepto` | `CHAR(80)` | — | — |
| `p_cusuario_int` | `CHAR(8)` | `int`=interés | ✅ CÓDIGO |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `sql_err` | `INTEGER` | L8 |
| `isam_err` | `INTEGER` | L9 |
| `error_info` | `CHAR(40)` | L10 |
| `cod_ret` | `CHAR(6)` | L11 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `co_integracion` | `bdicont` | no | INSERT | L54 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L48 | VALIDACIÓN_NULL | `IF (p_mimporte = '' OR p_mimporte IS NULL) OR (p_cusuario_int = '' OR p_cusuario_int IS NULL) THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `inserta` | ACCION | inserta / registra | 🔵 CONVENCIÓN | nombre_sp |
| `?rco` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `int` | ENTIDAD | interés | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `?egracion` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?rco`, `?egracion` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `libmaycon`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_libmaycon.sql` |
| **LOC (1er CREATE)** | 246 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "consulta" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=0 · INFERIDO=1 · SINTÉTICO=1 / 2 términos |

### Firma

```sql
CREATE PROCEDURE libmaycon(
  pempresa                     char(3)
  pfecha_hoy                   date
  v_mayor                      char(10)
  v_sub                        char(10)
  v_subsub                     char(10)
  v_ssubsub                    char(10)
  v_sssubsub                   char(10)
  v_sector                     char(10)
)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pempresa` | `char(3)` | — | — |
| `pfecha_hoy` | `date` | — | — |
| `v_mayor` | `char(10)` | — | — |
| `v_sub` | `char(10)` | — | — |
| `v_subsub` | `char(10)` | — | — |
| `v_ssubsub` | `char(10)` | — | — |
| `v_sssubsub` | `char(10)` | — | — |
| `v_sector` | `char(10)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `tempresa` | `char(3)` | L4 |
| `tccmayor` | `char(10)` | L5 |
| `tccsub` | `char(10)` | L6 |
| `tccsubsub` | `char(10)` | L7 |
| `tccssubsub` | `char(10)` | L8 |
| `tccsssubsub` | `char(10)` | L9 |
| `tsector` | `char(10)` | L10 |
| `tciudad` | `char(3)` | L11 |
| `tsucursal` | `char(4)` | L12 |
| `tmoneda` | `char(2)` | L13 |
| `tsaldo_inicio_mes` | `money(18,2)` | L14 |
| `tsaldo_actual` | `money(18,2)` | L15 |
| `tsaldo_inicial` | `money(18,2)` | L16 |
| `tsaldo_final` | `money(18,2)` | L17 |
| `tfecha_hoy` | `date` | L18 |
| `tmonto` | `money(18,2)` | L19 |
| `tusuario` | `char(8)` | L20 |
| `tcontrol_poliza` | `int` | L21 |
| `tfecha_valida` | `date` | L22 |
| `tnaturaleza` | `char(1)` | L23 |
| `tnat_cta` | `char(1)` | L24 |
| `tsecuencia` | `int` | L25 |
| `tnro_auxiliar` | `char(12)` | L26 |
| `v_dia` | `CHAR(2)` | L27 |
| `v_mes` | `CHAR(2)` | L28 |
| *…17 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `co_libmaenca` | `bdicont` | no | SELECT | L48 |
| `co_libmaenca` | `bdicont` | no | DELETE | L48 |
| `co_libmadet` | `bdicont` | no | SELECT | L49 |
| `co_libmadet` | `bdicont` | no | DELETE | L49 |
| `co_fechas` | `bdicont` | no | SELECT | L77 |
| `co_saldos` | `bdicont` | no | SELECT | L102 |
| `si_catalog` | `bdinteg` | ⚠️ sí | SELECT | L148 |
| `si_divisas` | `bdinteg` | ⚠️ sí | SELECT | L159 |
| `co_libmaenca` | `bdicont` | no | INSERT | L164 |
| `co_movtos` | `bdicont` | no | SELECT | L177 |
| `co_libmadet` | `bdicont` | no | INSERT | L221 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L204 | VALIDACIÓN_NULL | `if tfecha_valida is null then` |  |
| L208 | FÓRMULA | `let tsaldo_final = tsaldo_inicial + tmonto;` | 🔴 MONEY/aritmética financiera |
| L210 | FÓRMULA | `let tsaldo_final = tsaldo_inicial - tmonto;` | 🔴 MONEY/aritmética financiera |
| L214 | FÓRMULA | `let tsaldo_final = tsaldo_inicial - tmonto;` | 🔴 MONEY/aritmética financiera |
| L216 | FÓRMULA | `let tsaldo_final = tsaldo_inicial + tmonto;` | 🔴 MONEY/aritmética financiera |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `?libmay` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `con` | ACCION | consulta | 🟡 INFERIDO | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?libmay` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `libmaysuc`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_libmaysuc.sql` |
| **LOC (1er CREATE)** | 253 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "(sucursal)" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 11 tabla(s) con operaciones: INSERT, SELECT, DELETE |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=0 · INFERIDO=1 · SINTÉTICO=1 / 2 términos |

### Firma

```sql
CREATE PROCEDURE libmaysuc(
  pempresa                     char(3)
  pfecha_hoy                   date
  v_mayor                      char(10)
  v_sub                        char(10)
  v_subsub                     char(10)
  v_ssubsub                    char(10)
  v_sssubsub                   char(10)
  v_sector                     char(10)
)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pempresa` | `char(3)` | — | — |
| `pfecha_hoy` | `date` | — | — |
| `v_mayor` | `char(10)` | — | — |
| `v_sub` | `char(10)` | — | — |
| `v_subsub` | `char(10)` | — | — |
| `v_ssubsub` | `char(10)` | — | — |
| `v_sssubsub` | `char(10)` | — | — |
| `v_sector` | `char(10)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `tempresa` | `char(3)` | L5 |
| `tccmayor` | `char(10)` | L6 |
| `tccsub` | `char(10)` | L7 |
| `tccsubsub` | `char(10)` | L8 |
| `tccssubsub` | `char(10)` | L9 |
| `tccsssubsub` | `char(10)` | L10 |
| `tsector` | `char(10)` | L11 |
| `tciudad` | `char(3)` | L12 |
| `tsucursal` | `char(4)` | L13 |
| `tmoneda` | `char(2)` | L14 |
| `tsaldo_inicio_mes` | `money(18,2)` | L15 |
| `tsaldo_actual` | `money(18,2)` | L16 |
| `tsaldo_inicial` | `money(18,2)` | L17 |
| `tsaldo_final` | `money(18,2)` | L18 |
| `tfecha_hoy` | `date` | L19 |
| `tmonto` | `money(18,2)` | L20 |
| `tusuario` | `char(8)` | L21 |
| `tcontrol_poliza` | `int` | L22 |
| `tfecha_valida` | `date` | L23 |
| `tnaturaleza` | `char(1)` | L24 |
| `tnat_cta` | `char(1)` | L25 |
| `tsecuencia` | `int` | L26 |
| `tnro_auxiliar` | `char(12)` | L27 |
| `v_dia` | `CHAR(2)` | L28 |
| `v_mes` | `CHAR(2)` | L29 |
| *…17 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `co_libmaenca` | `bdicont` | no | SELECT | L49 |
| `co_libmaenca` | `bdicont` | no | DELETE | L49 |
| `co_libmadet` | `bdicont` | no | SELECT | L50 |
| `co_libmadet` | `bdicont` | no | DELETE | L50 |
| `co_fechas` | `bdicont` | no | SELECT | L78 |
| `co_saldos` | `bdicont` | no | SELECT | L105 |
| `si_catalog` | `bdinteg` | ⚠️ sí | SELECT | L151 |
| `si_divisas` | `bdinteg` | ⚠️ sí | SELECT | L162 |
| `co_libmaenca` | `bdicont` | no | INSERT | L169 |
| `co_movtos` | `bdicont` | no | SELECT | L181 |
| `co_libmadet` | `bdicont` | no | INSERT | L227 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L208 | VALIDACIÓN_NULL | `if tfecha_valida is null then` |  |
| L212 | FÓRMULA | `let tsaldo_final = tsaldo_inicial + tmonto;` | 🔴 MONEY/aritmética financiera |
| L214 | FÓRMULA | `let tsaldo_final = tsaldo_inicial - tmonto;` | 🔴 MONEY/aritmética financiera |
| L218 | FÓRMULA | `let tsaldo_final = tsaldo_inicial - tmonto;` | 🔴 MONEY/aritmética financiera |
| L220 | FÓRMULA | `let tsaldo_final = tsaldo_inicial + tmonto;` | 🔴 MONEY/aritmética financiera |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `?libmay` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `suc` | MODIF | sucursal | 🟡 INFERIDO | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?libmay` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `libromayaux_diarios`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_libromayaux_diarios.sql` |
| **LOC (1er CREATE)** | 503 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "libro mayor (diarios)" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 20 tabla(s) con operaciones: UPDATE, SELECT, INSERT |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=1 / 4 términos |

### Firma

```sql
CREATE PROCEDURE libromayaux_diarios(
  v_empresa                    CHAR(4)
  v_fechainicio                DATE
  v_fechafin                   DATE
  v_ccmayor                    CHAR(10)
  v_ccsub                      CHAR(10)
  v_ccsubsub                   CHAR(10)
  v_ccssubsub                  CHAR(10)
  v_ccsssubsub                 CHAR(10)
  v_sector                     CHAR(10)
  v_cuenta                     CHAR(14)
  vusuario                     CHAR(10)
)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `v_empresa` | `CHAR(4)` | — | — |
| `v_fechainicio` | `DATE` | — | — |
| `v_fechafin` | `DATE` | — | — |
| `v_ccmayor` | `CHAR(10)` | — | — |
| `v_ccsub` | `CHAR(10)` | — | — |
| `v_ccsubsub` | `CHAR(10)` | — | — |
| `v_ccssubsub` | `CHAR(10)` | — | — |
| `v_ccsssubsub` | `CHAR(10)` | — | — |
| `v_sector` | `CHAR(10)` | — | — |
| `v_cuenta` | `CHAR(14)` | — | — |
| `vusuario` | `CHAR(10)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `tfecha_valida` | `DATE` | L13 |
| `tfecha_captura` | `DATE` | L14 |
| `tmes_dia` | `DATE` | L15 |
| `tmes_dia_min` | `DATE` | L16 |
| `tmes_dia_max` | `DATE` | L17 |
| `tusuario` | `CHAR(8)` | L18 |
| `tnro_auxiliar` | `CHAR(12)` | L19 |
| `auxiliar_cta` | `CHAR(12)` | L20 |
| `tcontrol_poliza` | `INTEGER` | L21 |
| `tsecuencia` | `INTEGER` | L22 |
| `tsucursal` | `CHAR(4)` | L23 |
| `tccosto_orig` | `CHAR(4)` | L24 |
| `tmonto` | `MONEY(16, 2)` | L25 |
| `tmoneda` | `CHAR(2)` | L26 |
| `tnaturaleza` | `CHAR(1)` | L27 |
| `tdescripcion` | `CHAR(50)` | L28 |
| `tciudad` | `CHAR(3)` | L29 |
| `tmoneda_sdo` | `CHAR(2)` | L30 |
| `tsucursal_sdo` | `CHAR(4)` | L31 |
| `tauxiliar_sdo` | `CHAR(12)` | L32 |
| `tciudad_sdo` | `CHAR(3)` | L33 |
| `tccmayor` | `CHAR(10)` | L34 |
| `tccsub` | `CHAR(10)` | L35 |
| `tccsubsub` | `CHAR(10)` | L36 |
| `tccssubsub` | `CHAR(10)` | L37 |
| *…10 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `statistics` | `bdicont` | no | UPDATE | L100 |
| `co_sdodias` | `bdicont` | no | SELECT | L105 |
| `si_plazas` | `bdinteg` | ⚠️ sí | SELECT | L121 |
| `si_sucursales` | `bdinteg` | ⚠️ sí | SELECT | L122 |
| `tmp_saldos` | `bdicont` | no | INSERT | L124 |
| `tmp_saldos` | `bdicont` | no | SELECT | L129 |
| `tmp_monedas` | `bdicont` | no | SELECT | L183 |
| `tmp_ciudades` | `bdicont` | no | SELECT | L185 |
| `tmp_sucursales` | `bdicont` | no | SELECT | L187 |
| `tmp_parametros` | `bdicont` | no | INSERT | L189 |
| `tmp_parametros` | `bdicont` | no | SELECT | L221 |
| `tmp_minmaxfechasaldos` | `bdicont` | no | INSERT | L242 |
| `tmp_minmaxfechasaldos` | `bdicont` | no | SELECT | L309 |
| `tmp_saldosfinales` | `bdicont` | no | INSERT | L348 |
| `tmp_saldosfinales` | `bdicont` | no | SELECT | L363 |
| `co_libsdoaux` | `bdicont` | no | INSERT | L371 |
| `co_mensual` | `bdicont` | no | SELECT | L413 |
| `tmp_historico` | `bdicont` | no | INSERT | L427 |
| `tmp_historico` | `bdicont` | no | SELECT | L460 |
| `co_libmadet` | `bdicont` | no | INSERT | L481 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L488 | FÓRMULA | `LET tmovimientos = tmovimientos + 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `libro` | ENTIDAD | libro mayor / libro contable — general ledger (libromayor_di | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?mayau` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `x` | MODIF | por (criterio) | 🔵 CONVENCIÓN | nombre_sp |
| `diarios` | MODIF | diarios | 🔵 CONVENCIÓN | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?mayau` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `libromayaux_historicos`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_libromayaux_historicos.sql` |
| **LOC (1er CREATE)** | 512 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "libro mayor (histórico)" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 20 tabla(s) con operaciones: UPDATE, SELECT, INSERT |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=2 / 5 términos |

### Firma

```sql
CREATE PROCEDURE libromayaux_historicos(
  v_empresa                    CHAR(4)
  v_fechainicio                DATE
  v_fechafin                   DATE
  v_ccmayor                    CHAR(10)
  v_ccsub                      CHAR(10)
  v_ccsubsub                   CHAR(10)
  v_ccssubsub                  CHAR(10)
  v_ccsssubsub                 CHAR(10)
  v_sector                     CHAR(10)
  v_cuenta                     CHAR(14)
  vusuario                     CHAR(10)
)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `v_empresa` | `CHAR(4)` | — | — |
| `v_fechainicio` | `DATE` | — | — |
| `v_fechafin` | `DATE` | — | — |
| `v_ccmayor` | `CHAR(10)` | — | — |
| `v_ccsub` | `CHAR(10)` | — | — |
| `v_ccsubsub` | `CHAR(10)` | — | — |
| `v_ccssubsub` | `CHAR(10)` | — | — |
| `v_ccsssubsub` | `CHAR(10)` | — | — |
| `v_sector` | `CHAR(10)` | — | — |
| `v_cuenta` | `CHAR(14)` | — | — |
| `vusuario` | `CHAR(10)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `tfecha_valida` | `DATE` | L13 |
| `tfecha_captura` | `DATE` | L14 |
| `tmes_dia` | `DATE` | L15 |
| `tmes_dia_min` | `DATE` | L16 |
| `tmes_dia_max` | `DATE` | L17 |
| `tusuario` | `CHAR(8)` | L18 |
| `tnro_auxiliar` | `CHAR(12)` | L19 |
| `auxiliar_cta` | `CHAR(12)` | L20 |
| `tcontrol_poliza` | `INTEGER` | L21 |
| `tsecuencia` | `INTEGER` | L22 |
| `tsucursal` | `CHAR(4)` | L23 |
| `tccosto_orig` | `CHAR(4)` | L24 |
| `tmonto` | `MONEY(16, 2)` | L25 |
| `tmoneda` | `CHAR(2)` | L26 |
| `tnaturaleza` | `CHAR(1)` | L27 |
| `tdescripcion` | `CHAR(50)` | L28 |
| `tciudad` | `CHAR(3)` | L29 |
| `tmoneda_sdo` | `CHAR(2)` | L30 |
| `tsucursal_sdo` | `CHAR(4)` | L31 |
| `tauxiliar_sdo` | `CHAR(12)` | L32 |
| `tciudad_sdo` | `CHAR(3)` | L33 |
| `tccmayor` | `CHAR(10)` | L34 |
| `tccsub` | `CHAR(10)` | L35 |
| `tccsubsub` | `CHAR(10)` | L36 |
| `tccssubsub` | `CHAR(10)` | L37 |
| *…10 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `statistics` | `bdicont` | no | UPDATE | L101 |
| `co_histsdodias` | `bdicont` | no | SELECT | L106 |
| `si_plazas` | `bdinteg` | ⚠️ sí | SELECT | L122 |
| `si_sucursales` | `bdinteg` | ⚠️ sí | SELECT | L123 |
| `tmp_saldos` | `bdicont` | no | INSERT | L125 |
| `tmp_saldos` | `bdicont` | no | SELECT | L131 |
| `tmp_monedas` | `bdicont` | no | SELECT | L185 |
| `tmp_ciudades` | `bdicont` | no | SELECT | L187 |
| `tmp_sucursales` | `bdicont` | no | SELECT | L189 |
| `tmp_parametros` | `bdicont` | no | INSERT | L191 |
| `tmp_parametros` | `bdicont` | no | SELECT | L223 |
| `tmp_minmaxfechasaldos` | `bdicont` | no | INSERT | L244 |
| `tmp_minmaxfechasaldos` | `bdicont` | no | SELECT | L314 |
| `tmp_saldosfinales` | `bdicont` | no | INSERT | L353 |
| `tmp_saldosfinales` | `bdicont` | no | SELECT | L369 |
| `co_libsdoaux` | `bdicont` | no | INSERT | L377 |
| `co_historico` | `bdicont` | no | SELECT | L420 |
| `tmp_historico` | `bdicont` | no | INSERT | L434 |
| `tmp_historico` | `bdicont` | no | SELECT | L468 |
| `co_libmadet` | `bdicont` | no | INSERT | L489 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L496 | FÓRMULA | `LET tmovimientos = tmovimientos + 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `libro` | ENTIDAD | libro mayor / libro contable — general ledger (libromayor_di | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?mayau` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `x` | MODIF | por (criterio) | 🔵 CONVENCIÓN | nombre_sp |
| `historico` | MODIF | histórico | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `?s` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?mayau`, `?s` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `libromayaux_old`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_libromayaux_old.sql` |
| **LOC (1er CREATE)** | 1270 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "libro mayor" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 24 tabla(s) con operaciones: UPDATE, INSERT, SELECT, DELETE |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=2 / 4 términos |

### Firma

```sql
CREATE PROCEDURE libromayaux_old(
  v_empresa                    CHAR(4)
  v_fechainicio                DATE
  v_fechafin                   DATE
  v_ccmayorini                 CHAR(10)
  v_ccsubini                   CHAR(10)
  v_ccsubsubini                CHAR(10)
  v_ccssubsubini               CHAR(10)
  v_ccsssubsubini              CHAR(10)
  v_sectorini                  CHAR(10)
  v_ccmayorfin                 CHAR(10)
  v_ccsubfin                   CHAR(10)
  v_ccsubsubfin                CHAR(10)
  v_ccssubsubfin               CHAR(10)
  v_ccsssubsubfin              CHAR(10)
  v_sectorfin                  CHAR(10)
  vusuario                     CHAR(10)
)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `v_empresa` | `CHAR(4)` | — | — |
| `v_fechainicio` | `DATE` | — | — |
| `v_fechafin` | `DATE` | — | — |
| `v_ccmayorini` | `CHAR(10)` | — | — |
| `v_ccsubini` | `CHAR(10)` | — | — |
| `v_ccsubsubini` | `CHAR(10)` | — | — |
| `v_ccssubsubini` | `CHAR(10)` | — | — |
| `v_ccsssubsubini` | `CHAR(10)` | — | — |
| `v_sectorini` | `CHAR(10)` | — | — |
| `v_ccmayorfin` | `CHAR(10)` | — | — |
| `v_ccsubfin` | `CHAR(10)` | — | — |
| `v_ccsubsubfin` | `CHAR(10)` | — | — |
| `v_ccssubsubfin` | `CHAR(10)` | — | — |
| `v_ccsssubsubfin` | `CHAR(10)` | — | — |
| `v_sectorfin` | `CHAR(10)` | — | — |
| `vusuario` | `CHAR(10)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `tempresa` | `CHAR(3)` | L6 |
| `tfecha_valida` | `DATE` | L7 |
| `tfecha_captura` | `DATE` | L8 |
| `tmes_dia` | `DATE` | L9 |
| `tusuario` | `CHAR(8)` | L10 |
| `tnro_auxiliar` | `CHAR(12)` | L11 |
| `tauxiliar` | `CHAR(12)` | L12 |
| `auxiliar_cta` | `CHAR(12)` | L13 |
| `tcontrol_poliza` | `INTEGER` | L14 |
| `tsecuencia` | `INTEGER` | L15 |
| `tsucursal` | `CHAR(4)` | L16 |
| `tccosto_orig` | `CHAR(4)` | L17 |
| `tmonto` | `MONEY(18, 2)` | L18 |
| `tmoneda` | `CHAR(2)` | L19 |
| `tnaturaleza` | `CHAR(1)` | L20 |
| `tdescripcion` | `CHAR(50)` | L21 |
| `tciudad` | `CHAR(3)` | L22 |
| `tmoneda_sdo` | `CHAR(2)` | L23 |
| `tsucursal_sdo` | `CHAR(4)` | L24 |
| `tauxiliar_sdo` | `CHAR(12)` | L25 |
| `tciudad_sdo` | `CHAR(3)` | L26 |
| `tccmayor` | `CHAR(10)` | L27 |
| `tccsub` | `CHAR(10)` | L28 |
| `tccsubsub` | `CHAR(10)` | L29 |
| `tccssubsub` | `CHAR(10)` | L30 |
| *…33 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `co_libmadet` | `bdicont` | no | SELECT | L115 |
| `co_libmadet` | `bdicont` | no | DELETE | L115 |
| `co_libsdoaux` | `bdicont` | no | SELECT | L117 |
| `co_libsdoaux` | `bdicont` | no | DELETE | L117 |
| `co_fechas` | `bdicont` | no | SELECT | L139 |
| `systabnames` | `sysmaster` | ⚠️ sí | SELECT | L153 |
| `si_catalog` | `bdinteg` | ⚠️ sí | SELECT | L165 |
| `tmp_ctacontable1` | `bdicont` | no | INSERT | L172 |
| `tmp_ctacontable1` | `bdicont` | no | SELECT | L186 |
| `tmp_ctacontable` | `bdicont` | no | INSERT | L190 |
| `11` | `bdicont` | no | SELECT | L197 |
| `13` | `bdicont` | no | SELECT | L197 |
| `tmp_ctacontable` | `bdicont` | no | SELECT | L201 |
| `co_sdodias` | `bdicont` | no | SELECT | L231 |
| `si_sucursales` | `bdinteg` | ⚠️ sí | SELECT | L331 |
| `si_plazas` | `bdinteg` | ⚠️ sí | SELECT | L337 |
| `co_libsdoaux` | `bdicont` | no | INSERT | L361 |
| `co_libsdoaux` | `bdicont` | no | UPDATE | L374 |
| `co_mensual` | `bdicont` | no | SELECT | L403 |
| `co_libmadet` | `bdicont` | no | INSERT | L436 |
| `co_histsdodias` | `bdicont` | no | SELECT | L496 |
| `co_historico` | `bdicont` | no | SELECT | L640 |
| `co_diasaux` | `bdicont` | no | SELECT | L748 |
| `co_histdiasaux` | `bdicont` | no | SELECT | L1031 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L324 | VALIDACIÓN_NULL | `IF tsaldo_inicial IS NULL THEN` |  |
| L561 | VALIDACIÓN_NULL | `IF tsaldo_inicial IS NULL THEN` |  |
| L844 | VALIDACIÓN_NULL | `IF tsaldo_inicial IS NULL THEN` |  |
| L1099 | VALIDACIÓN_NULL | `IF tsaldo_inicial IS NULL THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `libro` | ENTIDAD | libro mayor / libro contable — general ledger (libromayor_di | 🔵 CONVENCIÓN | nombre_sp |
| `?mayau` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `x` | MODIF | por (criterio) | 🔵 CONVENCIÓN | nombre_sp |
| `?_old` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?mayau`, `?_old` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `libromayor_diarios`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_libromayor_diarios.sql` |
| **LOC (1er CREATE)** | 639 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "libro mayor y mayor contable (diarios)" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 19 tabla(s) con operaciones: UPDATE, SELECT, INSERT |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=2 · INFERIDO=1 · SINTÉTICO=0 / 3 términos |

### Firma

```sql
CREATE PROCEDURE libromayor_diarios(
  v_empresa                    CHAR(4)
  v_fechainicio                DATE
  v_fechafin                   DATE
  v_ccmayor                    CHAR(10)
  v_ccsub                      CHAR(10)
  v_ccsubsub                   CHAR(10)
  v_ccssubsub                  CHAR(10)
  v_ccsssubsub                 CHAR(10)
  v_sector                     CHAR(10)
  v_cuenta                     CHAR(14)
  vusuario                     CHAR(10)
  v_idreporte                  INTEGER
) RETURNING VARCHAR(5), VARCHAR(255)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `v_empresa` | `CHAR(4)` | — | — |
| `v_fechainicio` | `DATE` | — | — |
| `v_fechafin` | `DATE` | — | — |
| `v_ccmayor` | `CHAR(10)` | `mayor`=mayor contable | 🟡 INFERIDO |
| `v_ccsub` | `CHAR(10)` | — | — |
| `v_ccsubsub` | `CHAR(10)` | — | — |
| `v_ccssubsub` | `CHAR(10)` | — | — |
| `v_ccsssubsub` | `CHAR(10)` | — | — |
| `v_sector` | `CHAR(10)` | — | — |
| `v_cuenta` | `CHAR(14)` | — | — |
| `vusuario` | `CHAR(10)` | — | — |
| `v_idreporte` | `INTEGER` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `tfecha_valida` | `DATE` | L16 |
| `tfecha_captura` | `DATE` | L17 |
| `tmes_dia` | `DATE` | L18 |
| `tmes_dia_min` | `DATE` | L19 |
| `tmes_dia_max` | `DATE` | L20 |
| `tusuario` | `CHAR(8)` | L21 |
| `tnro_auxiliar` | `CHAR(12)` | L22 |
| `tcontrol_poliza` | `INTEGER` | L23 |
| `tsecuencia` | `INTEGER` | L24 |
| `tsucursal` | `CHAR(4)` | L25 |
| `tccosto_orig` | `CHAR(4)` | L26 |
| `tmonto` | `MONEY(16, 2)` | L27 |
| `tmoneda` | `CHAR(2)` | L28 |
| `tnaturaleza` | `CHAR(1)` | L29 |
| `tdescripcion` | `CHAR(50)` | L30 |
| `tciudad` | `CHAR(3)` | L31 |
| `tmoneda_sdo` | `CHAR(2)` | L32 |
| `tsucursal_sdo` | `CHAR(4)` | L33 |
| `tauxiliar_sdo` | `CHAR(12)` | L34 |
| `tciudad_sdo` | `CHAR(3)` | L35 |
| `tccmayor` | `CHAR(10)` | L36 |
| `tccsub` | `CHAR(10)` | L37 |
| `tccsubsub` | `CHAR(10)` | L38 |
| `tccssubsub` | `CHAR(10)` | L39 |
| `tccsssubsub` | `CHAR(10)` | L40 |
| *…20 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `statistics` | `bdicont` | no | UPDATE | L161 |
| `co_sdodias` | `bdicont` | no | SELECT | L168 |
| `tmp_saldos` | `bdicont` | no | INSERT | L185 |
| `tmp_saldos` | `bdicont` | no | SELECT | L190 |
| `tmp_monedas` | `bdicont` | no | SELECT | L264 |
| `tmp_ciudades` | `bdicont` | no | SELECT | L266 |
| `tmp_sucursales` | `bdicont` | no | SELECT | L268 |
| `tmp_parametros` | `bdicont` | no | INSERT | L270 |
| `tmp_parametros` | `bdicont` | no | SELECT | L311 |
| `tmp_minmaxfechasaldos` | `bdicont` | no | INSERT | L333 |
| `tmp_minmaxfechasaldos` | `bdicont` | no | SELECT | L345 |
| `tmp_saldosfinales` | `bdicont` | no | INSERT | L432 |
| `tmp_saldosfinales` | `bdicont` | no | SELECT | L447 |
| `co_libsdoaux` | `bdicont` | no | INSERT | L457 |
| `co_mensual` | `bdicont` | no | SELECT | L522 |
| `tmp_historico` | `bdicont` | no | INSERT | L536 |
| `tmp_historico` | `bdicont` | no | SELECT | L548 |
| `co_libmadet` | `bdicont` | no | INSERT | L572 |
| `co_libmadet` | `bdicont` | no | SELECT | L605 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L463 | FÓRMULA | `LET viContadorRegistros = viContadorRegistros + 1;` |  |
| L579 | FÓRMULA | `LET viContadorRegistros = viContadorRegistros + 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `libro` | ENTIDAD | libro mayor / libro contable — general ledger (libromayor_di | 🔵 CONVENCIÓN | nombre_sp |
| `mayor` | ENTIDAD | mayor contable | 🟡 INFERIDO | nombre_sp |
| `diarios` | MODIF | diarios | 🔵 CONVENCIÓN | nombre_sp |

---

## `libromayor_diariosaux`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_libromayor_diariosaux.sql` |
| **LOC (1er CREATE)** | 708 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "libro mayor y mayor contable (diarios)" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 20 tabla(s) con operaciones: UPDATE, SELECT, INSERT |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=3 · INFERIDO=1 · SINTÉTICO=1 / 5 términos |

### Firma

```sql
CREATE PROCEDURE libromayor_diariosaux(
  v_empresa                    CHAR(4)
  v_fechainicio                DATE
  v_fechafin                   DATE
  v_ccmayor                    CHAR(10)
  v_ccsub                      CHAR(10)
  v_ccsubsub                   CHAR(10)
  v_ccssubsub                  CHAR(10)
  v_ccsssubsub                 CHAR(10)
  v_sector                     CHAR(10)
  v_cuenta                     CHAR(14)
  vusuario                     CHAR(10)
  v_idreporte                  INTEGER
) RETURNING VARCHAR(5), VARCHAR(255)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `v_empresa` | `CHAR(4)` | — | — |
| `v_fechainicio` | `DATE` | — | — |
| `v_fechafin` | `DATE` | — | — |
| `v_ccmayor` | `CHAR(10)` | `mayor`=mayor contable | 🟡 INFERIDO |
| `v_ccsub` | `CHAR(10)` | — | — |
| `v_ccsubsub` | `CHAR(10)` | — | — |
| `v_ccssubsub` | `CHAR(10)` | — | — |
| `v_ccsssubsub` | `CHAR(10)` | — | — |
| `v_sector` | `CHAR(10)` | — | — |
| `v_cuenta` | `CHAR(14)` | — | — |
| `vusuario` | `CHAR(10)` | — | — |
| `v_idreporte` | `INTEGER` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `tfecha_valida` | `DATE` | L16 |
| `tfecha_captura` | `DATE` | L17 |
| `tmes_dia` | `DATE` | L18 |
| `tmes_dia_min` | `DATE` | L19 |
| `tmes_dia_max` | `DATE` | L20 |
| `tusuario` | `CHAR(8)` | L21 |
| `tnro_auxiliar` | `CHAR(12)` | L22 |
| `auxiliar_cta` | `CHAR(12)` | L23 |
| `tcontrol_poliza` | `INTEGER` | L24 |
| `tsecuencia` | `INTEGER` | L25 |
| `tsucursal` | `CHAR(4)` | L26 |
| `tccosto_orig` | `CHAR(4)` | L27 |
| `tmonto` | `MONEY(16, 2)` | L28 |
| `tmoneda` | `CHAR(2)` | L29 |
| `tnaturaleza` | `CHAR(1)` | L30 |
| `tdescripcion` | `CHAR(50)` | L31 |
| `tciudad` | `CHAR(3)` | L32 |
| `tmoneda_sdo` | `CHAR(2)` | L33 |
| `tsucursal_sdo` | `CHAR(4)` | L34 |
| `tauxiliar_sdo` | `CHAR(12)` | L35 |
| `tciudad_sdo` | `CHAR(3)` | L36 |
| `tccmayor` | `CHAR(10)` | L37 |
| `tccsub` | `CHAR(10)` | L38 |
| `tccsubsub` | `CHAR(10)` | L39 |
| `tccssubsub` | `CHAR(10)` | L40 |
| *…25 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `statistics` | `bdicont` | no | UPDATE | L172 |
| `co_diasaux` | `bdicont` | no | SELECT | L179 |
| `tmp_saldos` | `bdicont` | no | INSERT | L197 |
| `tmp_saldos` | `bdicont` | no | SELECT | L203 |
| `tmp_monedas` | `bdicont` | no | SELECT | L303 |
| `tmp_ciudades` | `bdicont` | no | SELECT | L305 |
| `tmp_auxiliares` | `bdicont` | no | SELECT | L307 |
| `tmp_sucursales` | `bdicont` | no | SELECT | L309 |
| `tmp_parametros` | `bdicont` | no | INSERT | L311 |
| `tmp_parametros` | `bdicont` | no | SELECT | L358 |
| `tmp_minmaxfechasaldos` | `bdicont` | no | INSERT | L382 |
| `tmp_minmaxfechasaldos` | `bdicont` | no | SELECT | L395 |
| `tmp_saldosfinales` | `bdicont` | no | INSERT | L491 |
| `tmp_saldosfinales` | `bdicont` | no | SELECT | L509 |
| `co_libsdoaux` | `bdicont` | no | INSERT | L519 |
| `co_mensual` | `bdicont` | no | SELECT | L585 |
| `tmp_historico` | `bdicont` | no | INSERT | L599 |
| `tmp_historico` | `bdicont` | no | SELECT | L611 |
| `co_libmadet` | `bdicont` | no | INSERT | L635 |
| `co_libmadet` | `bdicont` | no | SELECT | L672 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L525 | FÓRMULA | `LET viContadorRegistros = viContadorRegistros + 1;` |  |
| L642 | FÓRMULA | `LET viContadorRegistros = viContadorRegistros + 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `libro` | ENTIDAD | libro mayor / libro contable — general ledger (libromayor_di | 🔵 CONVENCIÓN | nombre_sp |
| `mayor` | ENTIDAD | mayor contable | 🟡 INFERIDO | nombre_sp |
| `diarios` | MODIF | diarios | 🔵 CONVENCIÓN | nombre_sp |
| `?au` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `x` | MODIF | por (criterio) | 🔵 CONVENCIÓN | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?au` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `libromayor_historicos`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_libromayor_historicos.sql` |
| **LOC (1er CREATE)** | 650 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "libro mayor y mayor contable (histórico)" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 19 tabla(s) con operaciones: UPDATE, SELECT, INSERT |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=1 · INFERIDO=1 · SINTÉTICO=1 / 4 términos |

### Firma

```sql
CREATE PROCEDURE libromayor_historicos(
  v_empresa                    CHAR(4)
  v_fechainicio                DATE
  v_fechafin                   DATE
  v_ccmayor                    CHAR(10)
  v_ccsub                      CHAR(10)
  v_ccsubsub                   CHAR(10)
  v_ccssubsub                  CHAR(10)
  v_ccsssubsub                 CHAR(10)
  v_sector                     CHAR(10)
  v_cuenta                     CHAR(14)
  vusuario                     CHAR(10)
  v_idreporte                  INTEGER
) RETURNING VARCHAR(5), VARCHAR(255)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `v_empresa` | `CHAR(4)` | — | — |
| `v_fechainicio` | `DATE` | — | — |
| `v_fechafin` | `DATE` | — | — |
| `v_ccmayor` | `CHAR(10)` | `mayor`=mayor contable | 🟡 INFERIDO |
| `v_ccsub` | `CHAR(10)` | — | — |
| `v_ccsubsub` | `CHAR(10)` | — | — |
| `v_ccssubsub` | `CHAR(10)` | — | — |
| `v_ccsssubsub` | `CHAR(10)` | — | — |
| `v_sector` | `CHAR(10)` | — | — |
| `v_cuenta` | `CHAR(14)` | — | — |
| `vusuario` | `CHAR(10)` | — | — |
| `v_idreporte` | `INTEGER` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `tfecha_valida` | `DATE` | L16 |
| `tfecha_captura` | `DATE` | L17 |
| `tmes_dia` | `DATE` | L18 |
| `tmes_dia_min` | `DATE` | L19 |
| `tmes_dia_max` | `DATE` | L20 |
| `tusuario` | `CHAR(8)` | L21 |
| `tnro_auxiliar` | `CHAR(12)` | L22 |
| `tcontrol_poliza` | `INTEGER` | L23 |
| `tsecuencia` | `INTEGER` | L24 |
| `tsucursal` | `CHAR(4)` | L25 |
| `tccosto_orig` | `CHAR(4)` | L26 |
| `tmonto` | `MONEY(16, 2)` | L27 |
| `tmoneda` | `CHAR(2)` | L28 |
| `tnaturaleza` | `CHAR(1)` | L29 |
| `tdescripcion` | `CHAR(50)` | L30 |
| `tciudad` | `CHAR(3)` | L31 |
| `tmoneda_sdo` | `CHAR(2)` | L32 |
| `tsucursal_sdo` | `CHAR(4)` | L33 |
| `tauxiliar_sdo` | `CHAR(12)` | L34 |
| `tciudad_sdo` | `CHAR(3)` | L35 |
| `tccmayor` | `CHAR(10)` | L36 |
| `tccsub` | `CHAR(10)` | L37 |
| `tccsubsub` | `CHAR(10)` | L38 |
| `tccssubsub` | `CHAR(10)` | L39 |
| `tccsssubsub` | `CHAR(10)` | L40 |
| *…20 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `statistics` | `bdicont` | no | UPDATE | L162 |
| `co_histsdodias` | `bdicont` | no | SELECT | L169 |
| `tmp_saldos` | `bdicont` | no | INSERT | L186 |
| `tmp_saldos` | `bdicont` | no | SELECT | L192 |
| `tmp_monedas` | `bdicont` | no | SELECT | L266 |
| `tmp_ciudades` | `bdicont` | no | SELECT | L268 |
| `tmp_sucursales` | `bdicont` | no | SELECT | L270 |
| `tmp_parametros` | `bdicont` | no | INSERT | L272 |
| `tmp_parametros` | `bdicont` | no | SELECT | L314 |
| `tmp_minmaxfechasaldos` | `bdicont` | no | INSERT | L336 |
| `tmp_minmaxfechasaldos` | `bdicont` | no | SELECT | L349 |
| `tmp_saldosfinales` | `bdicont` | no | INSERT | L439 |
| `tmp_saldosfinales` | `bdicont` | no | SELECT | L457 |
| `co_libsdoaux` | `bdicont` | no | INSERT | L467 |
| `co_historico` | `bdicont` | no | SELECT | L532 |
| `tmp_historico` | `bdicont` | no | INSERT | L546 |
| `tmp_historico` | `bdicont` | no | SELECT | L558 |
| `co_libmadet` | `bdicont` | no | INSERT | L582 |
| `co_libmadet` | `bdicont` | no | SELECT | L615 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L473 | FÓRMULA | `LET viContadorRegistros = viContadorRegistros + 1;` |  |
| L589 | FÓRMULA | `LET viContadorRegistros = viContadorRegistros + 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `libro` | ENTIDAD | libro mayor / libro contable — general ledger (libromayor_di | 🔵 CONVENCIÓN | nombre_sp |
| `mayor` | ENTIDAD | mayor contable | 🟡 INFERIDO | nombre_sp |
| `historico` | MODIF | histórico | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `?s` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?s` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `libromayor_historicosaux`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_libromayor_historicosaux.sql` |
| **LOC (1er CREATE)** | 701 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "libro mayor y mayor contable (histórico)" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 20 tabla(s) con operaciones: UPDATE, SELECT, INSERT |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=2 · INFERIDO=1 · SINTÉTICO=1 / 5 términos |

### Firma

```sql
CREATE PROCEDURE libromayor_historicosaux(
  v_empresa                    CHAR(4)
  v_fechainicio                DATE
  v_fechafin                   DATE
  v_ccmayor                    CHAR(10)
  v_ccsub                      CHAR(10)
  v_ccsubsub                   CHAR(10)
  v_ccssubsub                  CHAR(10)
  v_ccsssubsub                 CHAR(10)
  v_sector                     CHAR(10)
  v_cuenta                     CHAR(14)
  vusuario                     CHAR(10)
  v_idreporte                  INTEGER
) RETURNING VARCHAR(5), VARCHAR(255)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `v_empresa` | `CHAR(4)` | — | — |
| `v_fechainicio` | `DATE` | — | — |
| `v_fechafin` | `DATE` | — | — |
| `v_ccmayor` | `CHAR(10)` | `mayor`=mayor contable | 🟡 INFERIDO |
| `v_ccsub` | `CHAR(10)` | — | — |
| `v_ccsubsub` | `CHAR(10)` | — | — |
| `v_ccssubsub` | `CHAR(10)` | — | — |
| `v_ccsssubsub` | `CHAR(10)` | — | — |
| `v_sector` | `CHAR(10)` | — | — |
| `v_cuenta` | `CHAR(14)` | — | — |
| `vusuario` | `CHAR(10)` | — | — |
| `v_idreporte` | `INTEGER` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `tfecha_valida` | `DATE` | L16 |
| `tfecha_captura` | `DATE` | L17 |
| `tmes_dia` | `DATE` | L18 |
| `tmes_dia_min` | `DATE` | L19 |
| `tmes_dia_max` | `DATE` | L20 |
| `tusuario` | `CHAR(8)` | L21 |
| `tnro_auxiliar` | `CHAR(12)` | L22 |
| `tcontrol_poliza` | `INTEGER` | L23 |
| `tsecuencia` | `INTEGER` | L24 |
| `tsucursal` | `CHAR(4)` | L25 |
| `tccosto_orig` | `CHAR(4)` | L26 |
| `tmonto` | `MONEY(16, 2)` | L27 |
| `tmoneda` | `CHAR(2)` | L28 |
| `tnaturaleza` | `CHAR(1)` | L29 |
| `tdescripcion` | `CHAR(50)` | L30 |
| `tciudad` | `CHAR(3)` | L31 |
| `tmoneda_sdo` | `CHAR(2)` | L32 |
| `tsucursal_sdo` | `CHAR(4)` | L33 |
| `tauxiliar_sdo` | `CHAR(12)` | L34 |
| `tciudad_sdo` | `CHAR(3)` | L35 |
| `tccmayor` | `CHAR(10)` | L36 |
| `tccsub` | `CHAR(10)` | L37 |
| `tccsubsub` | `CHAR(10)` | L38 |
| `tccssubsub` | `CHAR(10)` | L39 |
| `tccsssubsub` | `CHAR(10)` | L40 |
| *…21 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `statistics` | `bdicont` | no | UPDATE | L168 |
| `co_histdiasaux` | `bdicont` | no | SELECT | L175 |
| `tmp_saldos` | `bdicont` | no | INSERT | L194 |
| `tmp_saldos` | `bdicont` | no | SELECT | L200 |
| `tmp_monedas` | `bdicont` | no | SELECT | L300 |
| `tmp_ciudades` | `bdicont` | no | SELECT | L302 |
| `tmp_auxiliares` | `bdicont` | no | SELECT | L304 |
| `tmp_sucursales` | `bdicont` | no | SELECT | L306 |
| `tmp_parametros` | `bdicont` | no | INSERT | L308 |
| `tmp_parametros` | `bdicont` | no | SELECT | L355 |
| `tmp_minmaxfechasaldos` | `bdicont` | no | INSERT | L379 |
| `tmp_minmaxfechasaldos` | `bdicont` | no | SELECT | L392 |
| `tmp_saldosfinales` | `bdicont` | no | INSERT | L488 |
| `tmp_saldosfinales` | `bdicont` | no | SELECT | L506 |
| `co_libsdoaux` | `bdicont` | no | INSERT | L516 |
| `co_historico` | `bdicont` | no | SELECT | L582 |
| `tmp_historico` | `bdicont` | no | INSERT | L596 |
| `tmp_historico` | `bdicont` | no | SELECT | L608 |
| `co_libmadet` | `bdicont` | no | INSERT | L632 |
| `co_libmadet` | `bdicont` | no | SELECT | L665 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L522 | FÓRMULA | `LET viContadorRegistros = viContadorRegistros + 1;` |  |
| L639 | FÓRMULA | `LET viContadorRegistros = viContadorRegistros + 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `libro` | ENTIDAD | libro mayor / libro contable — general ledger (libromayor_di | 🔵 CONVENCIÓN | nombre_sp |
| `mayor` | ENTIDAD | mayor contable | 🟡 INFERIDO | nombre_sp |
| `historico` | MODIF | histórico | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `?sau` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `x` | MODIF | por (criterio) | 🔵 CONVENCIÓN | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?sau` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `llenareport`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_llenareport.sql` |
| **LOC (1er CREATE)** | 664 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "reporte" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 1 llamada(s): `inserta_actualiza` |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=2 / 3 términos |

### Firma

```sql
CREATE PROCEDURE llenareport(
  pempresa                     char(3)
  pciudad                      char(3)
  psucursal                    char(4)
  pcve_reporte                 char(10)
  pfecha_hoy                   date
) RETURNING char(5)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pempresa` | `char(3)` | — | — |
| `pciudad` | `char(3)` | — | — |
| `psucursal` | `char(4)` | — | — |
| `pcve_reporte` | `char(10)` | `rep`=reporte | 🔵 CONVENCIÓN |
| `pfecha_hoy` | `date` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cod_ret` | `char(5)` | L5 |
| `sempresa` | `char(3)` | L6 |
| `scve_reporte` | `char(10)` | L7 |
| `snum_renglon` | `smallint` | L8 |
| `snum_columna` | `smallint` | L9 |
| `sren_totaliza` | `smallint` | L10 |
| `scol_totaliza` | `smallint` | L11 |
| `sfiltro` | `char(3)` | L12 |
| `soperador` | `char(1)` | L13 |
| `stexto` | `char(60)` | L14 |
| `sgrupo` | `smallint` | L15 |
| `sacumula` | `char(1)` | L16 |
| `tempresa` | `char(3)` | L17 |
| `tcve_reporte` | `char(10)` | L18 |
| `tfiltro` | `char(3)` | L19 |
| `tccmayor` | `char(10)` | L20 |
| `tccsub` | `char(10)` | L21 |
| `tccsubsub` | `char(10)` | L22 |
| `tccssubsub` | `char(10)` | L23 |
| `tccsssubsub` | `char(10)` | L24 |
| `tsector` | `char(10)` | L25 |
| `tmoneda` | `char(2)` | L26 |
| `tciudad` | `char(3)` | L27 |
| `tsucursal` | `char(4)` | L28 |
| `tmes_dia` | `date` | L29 |
| *…22 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `co_edosfin` | `bdicont` | no | SELECT | L77 |
| `co_edosfin` | `bdicont` | no | DELETE | L77 |
| `co_repsdos` | `bdicont` | no | SELECT | L80 |
| `co_repsdos` | `bdicont` | no | DELETE | L80 |
| `co_param` | `bdicont` | no | SELECT | L84 |
| `co_celdas` | `bdicont` | no | SELECT | L100 |
| `co_filtros` | `bdicont` | no | SELECT | L122 |
| `si_histdiv` | `bdinteg` | ⚠️ sí | SELECT | L187 |
| `co_repsdos` | `bdicont` | no | INSERT | L449 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `inserta_actualiza` | `bdicont` | no | L225 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L56 | VALIDACIÓN_NULL | `if psucursal is null or psucursal = " " then` |  |
| L127 | VALIDACIÓN_NULL | `if tccmayor is null or tccmayor = " " then` |  |
| L171 | VALIDACIÓN_NULL | `if nsaldo_inicio_dia is null then` |  |
| L174 | VALIDACIÓN_NULL | `if ncargos_dia is null then` |  |
| L177 | VALIDACIÓN_NULL | `if nabonos_dia is null then` |  |
| L180 | VALIDACIÓN_NULL | `if nsaldo_fin_de_dia is null then` |  |
| L193 | VALIDACIÓN_NULL | `if v_tpc = 0 or v_tpc is null then` |  |
| L201 | VALIDACIÓN_NULL | `if v_fecha_tc is null or v_fecha_tc = " " then` |  |
| L214 | FÓRMULA | `let nsaldo_inicio_dia = nsaldo_inicio_dia * v_tpc;` |  |
| L215 | FÓRMULA | `let ncargos_dia = ncargos_dia * v_tpc;` |  |
| L216 | FÓRMULA | `let nabonos_dia = nabonos_dia * v_tpc;` |  |
| L217 | FÓRMULA | `let nsaldo_fin_de_dia = nsaldo_fin_de_dia * v_tpc;` |  |
| L274 | VALIDACIÓN_NULL | `if nsaldo_inicio_dia is null then` |  |
| L277 | VALIDACIÓN_NULL | `if ncargos_dia is null then` |  |
| L280 | VALIDACIÓN_NULL | `if nabonos_dia is null then` |  |
| L283 | VALIDACIÓN_NULL | `if nsaldo_fin_de_dia is null then` |  |
| L296 | VALIDACIÓN_NULL | `if v_tpc = 0 or v_tpc is null then` |  |
| L304 | VALIDACIÓN_NULL | `if v_fecha_tc is null or v_fecha_tc = " " then` |  |
| L317 | FÓRMULA | `let nsaldo_inicio_dia = nsaldo_inicio_dia * v_tpc;` |  |
| L318 | FÓRMULA | `let ncargos_dia = ncargos_dia * v_tpc;` |  |
| L319 | FÓRMULA | `let nabonos_dia = nabonos_dia * v_tpc;` |  |
| L320 | FÓRMULA | `let nsaldo_fin_de_dia = nsaldo_fin_de_dia * v_tpc;` |  |
| L378 | VALIDACIÓN_NULL | `if nsaldo_inicio_dia is null then` |  |
| L381 | VALIDACIÓN_NULL | `if ncargos_dia is null then` |  |
| L384 | VALIDACIÓN_NULL | `if nabonos_dia is null then` |  |
| L387 | VALIDACIÓN_NULL | `if nsaldo_fin_de_dia is null then` |  |
| L400 | VALIDACIÓN_NULL | `if v_tpc = 0 or v_tpc is null then` |  |
| L408 | VALIDACIÓN_NULL | `if v_fecha_tc is null or v_fecha_tc = " " then` |  |
| L421 | FÓRMULA | `let nsaldo_inicio_dia = nsaldo_inicio_dia * v_tpc;` |  |
| L422 | FÓRMULA | `let ncargos_dia = ncargos_dia * v_tpc;` |  |
| | *…17 más…* | | |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `?llena` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `rep` | ACCION | reporte | 🔵 CONVENCIÓN | nombre_sp |
| `?ort` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?llena`, `?ort` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `mismomes`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_mismomes.sql` |
| **LOC (1er CREATE)** | 15 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "mes" `[partial]` |
| **Propósito verificado** | ❓ NO_VERIFICABLE — Propósito inferido; sin evidencia DML para verificar |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=1 / 2 términos |

### Firma

```sql
CREATE PROCEDURE mismomes(
  v_fecha1                     date
  v_fecha2                     date
) RETURNING smallint
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `v_fecha1` | `date` | — | — |
| `v_fecha2` | `date` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `v_codigo` | `smallint` | L4 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `?mismo` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `mes` | ENTIDAD | mes | 🔵 CONVENCIÓN | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?mismo` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `movlocal`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_movlocal.sql` |
| **LOC (1er CREATE)** | 250 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "movimiento (local)" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 10 tabla(s) con operaciones: INSERT, SELECT, DELETE |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=0 / 2 términos |

### Firma

```sql
CREATE PROCEDURE movlocal(
  pempresa                     char(3)
  pfecha_hoy                   date
) RETURNING char(5)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pempresa` | `char(3)` | — | — |
| `pfecha_hoy` | `date` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `v_dia_mes` | `char(4)` | L4 |
| `w_dd` | `char(2)` | L5 |
| `w_dd2` | `char(2)` | L6 |
| `w_mm2` | `char(2)` | L7 |
| `w_mm` | `char(2)` | L8 |
| `vw_moneda` | `char(2)` | L9 |
| `w_year` | `char(4)` | L10 |
| `w_a` | `char(1)` | L11 |
| `fecha_movto` | `date` | L12 |
| `w_proceso` | `char(20)` | L13 |
| `v_nomtabla` | `char(100)` | L14 |
| `gmregistro` | `char(200)` | L15 |
| `v_moneda` | `char(3)` | L16 |
| `v_moneda2` | `char(3)` | L17 |
| `v_tipmov` | `char(1)` | L18 |
| `v_cargo_abono` | `char(1)` | L19 |
| `v_ccsub` | `char(2)` | L20 |
| `v_ccsubsub` | `char(2)` | L21 |
| `v_ccssubsub` | `char(2)` | L22 |
| `v_ccsssubsub` | `char(2)` | L23 |
| `v_sector` | `char(2)` | L24 |
| `v2_sector` | `char(2)` | L25 |
| `v_division` | `char(2)` | L26 |
| `v_dd` | `char(2)` | L27 |
| `v_mm` | `char(2)` | L28 |
| *…33 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `co_movdia` | `bdicont` | no | SELECT | L85 |
| `co_movdia` | `bdicont` | no | DELETE | L85 |
| `co_tabmovdia` | `bdicont` | no | SELECT | L86 |
| `co_tabmovdia` | `bdicont` | no | DELETE | L86 |
| `co_param` | `bdicont` | no | SELECT | L90 |
| `co_movdia` | `bdicont` | no | INSERT | L97 |
| `co_detpol` | `bdicont` | no | SELECT | L108 |
| `co_poliza` | `bdicont` | no | SELECT | L119 |
| `si_catalog` | `bdinteg` | ⚠️ sí | SELECT | L196 |
| `co_tabmovdia` | `bdicont` | no | INSERT | L243 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L93 | FÓRMULA | `let v_nomtabla = trim(vruta_respaldo)\|\|"/importadatos/"\|\|v_nomtabla;` |  |
| L100 | FÓRMULA | `let v_sql = "dbload -d bdicont -c carga -l er ";` |  |
| L113 | VALIDACIÓN_NULL | `if w_sig_numpoliza is null or w_sig_numpoliza = " " then` |  |
| L124 | VALIDACIÓN_NULL | `if w_sig_numpoliza2 is null or w_sig_numpoliza2 = " " then` |  |
| L143 | FÓRMULA | `let i = i + 1;` |  |
| L167 | VALIDACIÓN_NULL | `if v_num_poliza3 is null or v_num_poliza3 = " " then` |  |
| L173 | FÓRMULA | `let v_num_poliza3 = v_num_poliza3 + 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `mov` | ENTIDAD | movimiento | 🔵 CONVENCIÓN | nombre_sp |
| `local` | MODIF | local | 🔵 CONVENCIÓN | nombre_sp |

---

## `nivelacion_ccostos`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_nivelacion_ccostos.sql` |
| **LOC (1er CREATE)** | 252 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "OS — Originación de Solicitudes" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 3 tabla(s) con operaciones: SELECT, INSERT |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=0 · INFERIDO=2 · SINTÉTICO=2 / 4 términos |

### Firma

```sql
CREATE PROCEDURE nivelacion_ccostos(
  p_empresa                    char(3)
  p_fecha_valida               DATE
) RETURNING CHAR(5)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_empresa` | `char(3)` | — | — |
| `p_fecha_valida` | `DATE` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `sql_err` | `INTEGER` | L5 |
| `isam_err` | `INTEGER` | L6 |
| `error_info` | `CHAR(40)` | L7 |
| `cod_ret` | `char(5)` | L8 |
| `v_usuario` | `char(8)` | L9 |
| `v_control_poliza` | `integer` | L10 |
| `v_fecha_captura` | `date` | L11 |
| `v_secuencia` | `integer` | L12 |
| `v_empresa` | `char(3)` | L13 |
| `v_ccmayor` | `char(10)` | L14 |
| `v_ccsub` | `char(10)` | L15 |
| `v_ccsubsub` | `char(10)` | L16 |
| `v_ccssubsub` | `char(10)` | L17 |
| `v_ccsssubsub` | `char(10)` | L18 |
| `v_sector` | `char(10)` | L19 |
| `v_ciudad` | `char(3)` | L20 |
| `v_sucursal` | `char(4)` | L21 |
| `v_nro_auxiliar` | `char(12)` | L22 |
| `v_naturaleza` | `char(1)` | L23 |
| `v_monto` | `money(18,2)` | L24 |
| `v_descripcion_det` | `char(80)` | L25 |
| `v_fecha_valida` | `date` | L26 |
| `v_moneda` | `char(2)` | L27 |
| `v_valor_cambio` | `money(12,7)` | L28 |
| `v_valor_div_cambio` | `money(12,7)` | L29 |
| *…18 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `co_param` | `bdicont` | no | SELECT | L74 |
| `co_detpol` | `bdicont` | no | SELECT | L85 |
| `co_detpol` | `bdicont` | no | INSERT | L155 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L145 | FÓRMULA | `LET v_monto = suma_abonos - suma_cargos;` | 🔴 MONEY/aritmética financiera |
| L154 | FÓRMULA | `LET v_secuencia_max = v_secuencia_max + 1;` |  |
| L184 | FÓRMULA | `LET v_monto = suma_cargos - suma_abonos;` | 🔴 MONEY/aritmética financiera |
| L193 | FÓRMULA | `LET v_secuencia_max = v_secuencia_max + 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `?nivelacion_cc` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `os` | ENTIDAD | OS — Originación de Solicitudes / subsistema de ofertas (sp_ | 🟡 INFERIDO | nombre_sp |
| `?t` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `os` | ENTIDAD | OS — Originación de Solicitudes / subsistema de ofertas (sp_ | 🟡 INFERIDO | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?nivelacion_cc`, `?t` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `pasa`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_pasa.sql` |
| **LOC (1er CREATE)** | 56 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "pasa" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 3 tabla(s) con operaciones: SELECT, INSERT |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=0 · INFERIDO=0 · SINTÉTICO=1 / 1 términos |

### Firma

```sql
CREATE PROCEDURE pasa(
)
```

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vempresa` | `char(3)` | L3 |
| `vcuenta_ext` | `char(9)` | L4 |
| `vexterna_10` | `char(10)` | L5 |
| `vdesc_cta_ext` | `char(40)` | L6 |
| `vtipo_cta` | `char(2)` | L7 |
| `vgrupo` | `char(5)` | L8 |
| `vmoneda` | `char(2)` | L10 |
| `vmonedatxt` | `char(3)` | L12 |
| `vmonedatxt1` | `char(3)` | L13 |
| `vsif` | `char(10)` | L14 |
| `vuso` | `char(5)` | L15 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `co_mapeo_cuentas` | `bdicont` | no | SELECT | L24 |
| `co_mapbal` | `bdicont` | no | SELECT | L38 |
| `co_mapeo_nuevo` | `bdicont` | no | INSERT | L51 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L48 | VALIDACIÓN_NULL | `if vcuenta_ext is null or vcuenta_ext = " " then` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `?pasa` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?pasa` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `pase_act_hist`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_pase_act_hist.sql` |
| **LOC (1er CREATE)** | 77 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "pase contable (histórico/historial)" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 3 tabla(s) con operaciones: SELECT, INSERT |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=0 / 3 términos |

### Firma

```sql
CREATE PROCEDURE pase_act_hist(
  pempresa                     char(3)
) RETURNING CHAR(5)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pempresa` | `char(3)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cod_ret` | `char(5)` | L4 |
| `vmoneda` | `char(2)` | L7 |
| `v_ciudad` | `char(3)` | L8 |
| `vsucursal` | `char(4)` | L9 |
| `v_empresa` | `char(3)` | L10 |
| `vnro_auxiliar` | `char(12)` | L12 |
| `vdescripcion` | `char(50)` | L13 |
| `vsecuencia` | `integer` | L16 |
| `vcontrol_poliza` | `integer` | L17 |
| `vpri_dia_mes` | `date` | L18 |
| `vult_dia_mes` | `date` | L19 |
| `vccost_orig` | `char (4)` | L20 |
| `vcontador` | `INTEGER` | L21 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `co_fechas` | `bdicont` | no | SELECT | L32 |
| `co_historico_tmp` | `bdicont` | no | SELECT | L46 |
| `co_historico` | `bdicont` | no | INSERT | L53 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L64 | FÓRMULA | `LET vcontador = vcontador + 1 ;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `pase` | ACCION | pase contable (registra/traslada a póliza o mayor) | 🔵 CONVENCIÓN | nombre_sp |
| `act` | ACCION | actualiza | 🔵 CONVENCIÓN | nombre_sp |
| `hist` | MODIF | histórico/historial | 🔵 CONVENCIÓN | nombre_sp |

---

## `pase_act_histsdos`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_pase_act_histsdos.sql` |
| **LOC (1er CREATE)** | 73 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "pase contable saldos (histórico/historial)" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 3 tabla(s) con operaciones: SELECT, INSERT |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=3 · INFERIDO=1 · SINTÉTICO=0 / 4 términos |

### Firma

```sql
CREATE PROCEDURE pase_act_histsdos(
  pempresa                     char(3)
) RETURNING CHAR(5)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pempresa` | `char(3)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cod_ret` | `char(5)` | L4 |
| `hempresa` | `char(3)` | L5 |
| `hccmayor` | `char(10)` | L6 |
| `hccsub` | `char(10)` | L7 |
| `hccsubsub` | `char(10)` | L8 |
| `hccssubsub` | `char(10)` | L9 |
| `hccsssubsub` | `char(10)` | L10 |
| `hsector` | `char(10)` | L11 |
| `hciudad` | `char(3)` | L12 |
| `hsucursal` | `char(4)` | L13 |
| `hmoneda` | `char(2)` | L14 |
| `hmes_dia` | `date` | L15 |
| `hcargos_dia` | `money(18,2)` | L16 |
| `habonos_dia` | `money(18,2)` | L17 |
| `hnro_cargos_dia` | `integer` | L18 |
| `hnro_abonos_dia` | `integer` | L19 |
| `hdias_proyectado` | `smallint` | L20 |
| `hdias_acumulado` | `smallint` | L21 |
| `hsaldo_acumulado` | `money(18,2)` | L22 |
| `hsaldo_inicio_dia` | `money(18,2)` | L23 |
| `hsaldo_fin_de_dia` | `money(18,2)` | L24 |
| `vpri_dia_mes` | `date` | L25 |
| `vult_dia_mes` | `date` | L26 |
| `vcontador` | `INTEGER` | L27 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `co_fechas` | `bdicont` | no | SELECT | L35 |
| `co_histsdodias_tmp` | `bdicont` | no | SELECT | L43 |
| `co_histsdodias` | `bdicont` | no | INSERT | L51 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L60 | FÓRMULA | `LET vcontador = vcontador + 1 ;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `pase` | ACCION | pase contable (registra/traslada a póliza o mayor) | 🔵 CONVENCIÓN | nombre_sp |
| `act` | ACCION | actualiza | 🔵 CONVENCIÓN | nombre_sp |
| `hist` | MODIF | histórico/historial | 🔵 CONVENCIÓN | nombre_sp |
| `sdos` | ENTIDAD | saldos (abreviación) | 🟡 INFERIDO | nombre_sp |

---

## `pase_movtos`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_pase_movtos.sql` |
| **LOC (1er CREATE)** | 149 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "pase contable movimiento" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 7 tabla(s) con operaciones: DELETE, UPDATE, SELECT, INSERT |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=1 / 3 términos |

### Firma

```sql
CREATE PROCEDURE pase_movtos(
  pempresa                     char(3)
  pfecha_hoy                   date
) RETURNING CHAR(5)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pempresa` | `char(3)` | — | — |
| `pfecha_hoy` | `date` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `sql_err` | `INTEGER` | L4 |
| `vmoneda` | `char(2)` | L14 |
| `vciudad` | `char(3)` | L15 |
| `vsucursal` | `char(4)` | L16 |
| `w_empresa` | `char(3)` | L17 |
| `vusuario` | `char(8)` | L18 |
| `vpoliza_usuario` | `char(8)` | L19 |
| `vnro_auxiliar` | `char(12)` | L20 |
| `vdescripcion` | `char(50)` | L21 |
| `vmonto` | `money(14,2)` | L22 |
| `v_rowid` | `integer` | L29 |
| `pfecha_hoy1` | `date` | L30 |
| `vexiste` | `integer` | L31 |
| `vccosto_orig` | `char(4)` | L32 |
| `vcontador` | `INTEGER` | L33 |
| `cod_ret` | `char(5)` | L34 |
| `begintran` | `smallint` | L35 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `co_cierre_cif` | `bdicont` | no | SELECT | L58 |
| `co_detpol` | `bdicont` | no | SELECT | L82 |
| `co_diario` | `bdicont` | no | INSERT | L106 |
| `statistics` | `bdicont` | no | UPDATE | L115 |
| `co_poliza` | `bdicont` | no | SELECT | L132 |
| `co_poliza` | `bdicont` | no | DELETE | L132 |
| `co_detpol` | `bdicont` | no | DELETE | L136 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L94 | VALIDACIÓN_NULL | `IF vnro_auxiliar is null then` |  |
| L98 | VALIDACIÓN_NULL | `IF vciudad is null then` |  |
| L102 | VALIDACIÓN_NULL | `IF vdescripcion is null then` |  |
| L118 | FÓRMULA | `LET vcontador = vcontador + 1 ;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `pase` | ACCION | pase contable (registra/traslada a póliza o mayor) | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `movto` | ENTIDAD | movimiento | 🔵 CONVENCIÓN | nombre_sp |
| `?s` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?s` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `pasecont`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_pasecont.sql` |
| **LOC (1er CREATE)** | 740 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 1 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "realiza el pase contable" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 1 llamada(s): `auditapase` |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=0 · INFERIDO=0 · SINTÉTICO=0 / 1 términos |

### Firma

```sql
CREATE PROCEDURE pasecont(
  pempresa                     CHAR(3)
  fecha_pase                   DATE
  pusuario                     CHAR(8)
  pusuariopase                 CHAR(8)
  pproceso                     CHAR(10)
) RETURNING CHAR(5), varchar(80)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pempresa` | `CHAR(3)` | — | — |
| `fecha_pase` | `DATE` | — | — |
| `pusuario` | `CHAR(8)` | — | — |
| `pusuariopase` | `CHAR(8)` | — | — |
| `pproceso` | `CHAR(10)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `wcod_ret` | `CHAR(5)` | L8 |
| `P_MENSAJE` | `VARCHAR(80)` | L9 |
| `sql_err` | `SMALLINT` | L10 |
| `isam_err` | `SMALLINT` | L11 |
| `error_info` | `CHAR(40)` | L12 |
| `v_error` | `smallint` | L13 |
| `wbegin` | `CHAR(1)` | L15 |
| `wusuario` | `CHAR(8)` | L16 |
| `wejecutivo` | `CHAR(8)` | L17 |
| `wfecha_hoy` | `DATE` | L18 |
| `nrows` | `SMALLINT` | L19 |
| `wproceso` | `CHAR(10)` | L20 |
| `valor_cambio` | `DECIMAL(6,4)` | L21 |
| `wdivisa_cambio` | `CHAR(2)` | L22 |
| `wsecuenciamn` | `INTEGER` | L23 |
| `wsecuenciadl` | `INTEGER` | L24 |
| `wnro_auxiliar` | `CHAR(9)` | L25 |
| `wdescripcion_det` | `CHAR(30)` | L26 |
| `wnumpolmn` | `SMALLINT` | L27 |
| `wnumpoldl` | `SMALLINT` | L28 |
| `wfecha` | `CHAR(10)` | L29 |
| `wbanco` | `CHAR(3)` | L30 |
| `wregional` | `CHAR(3)` | L36 |
| `wsucursal` | `CHAR(4)` | L37 |
| `wdivisa` | `CHAR(2)` | L38 |
| *…57 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sd_fechas` | `bdicont` | no | SELECT | L157 |
| `sx_contproc` | `bdinteg` | ⚠️ sí | SELECT | L180 |
| `co_poldet` | `bdicont` | no | SELECT | L190 |
| `co_poldet` | `bdicont` | no | DELETE | L190 |
| `co_detpol` | `bdicont` | no | SELECT | L195 |
| `co_detpol` | `bdicont` | no | DELETE | L195 |
| `co_poliza` | `bdicont` | no | SELECT | L200 |
| `co_poliza` | `bdicont` | no | DELETE | L200 |
| `si_ejecut` | `bdinteg` | ⚠️ sí | SELECT | L207 |
| `sd_contproc` | `bdicont` | no | INSERT | L229 |
| `sx_contproc` | `bdinteg` | ⚠️ sí | INSERT | L233 |
| `si_param` | `bdinteg` | ⚠️ sí | SELECT | L299 |
| `si_tpcambio` | `bdinteg` | ⚠️ sí | SELECT | L311 |
| `si_histdiv` | `bdinteg` | ⚠️ sí | SELECT | L321 |
| `si_plazas` | `bdinteg` | ⚠️ sí | SELECT | L372 |
| `si_catalog` | `bdinteg` | ⚠️ sí | SELECT | L464 |
| `tdetpol` | `bdicont` | no | INSERT | L516 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `auditapase` | `bdicont` | no | L662 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L141 | FÓRMULA | `LET wproceso = ""; --NULL;` |  |
| L150 | FÓRMULA | `LET wproceso = pproceso;  -- "PaseCont";` |  |
| L154 | VALIDACIÓN_NULL | `IF fecha_pase IS NULL OR fecha_pase = " "THEN` |  |
| L164 | VALIDACIÓN_NULL | `IF pusuariopase IS NULL OR pusuariopase = " " THEN` |  |
| L225 | VALIDACIÓN_NULL | `if wproceso is NULL then` |  |
| L227 | FÓRMULA | `LET wproceso = pproceso;   --"PaseCont";` |  |
| L340 | FÓRMULA | `LET wusuario = pusuariopase;   --"credito";` |  |
| L356 | VALIDACIÓN_NULL | `IF (wnumpolmn IS NULL or wnumpolmn = 0) THEN` |  |
| L359 | FÓRMULA | `LET wnumpolmn = wnumpolmn + 1;` |  |
| L362 | FÓRMULA | `LET wnumpoldl = wnumpolmn + 1;` |  |
| L493 | FÓRMULA | `LET wmonto = wmonto * valor_cambio;` | 🔴 MONEY/aritmética financiera |
| L500 | FÓRMULA | `LET wsecuenciamn = wsecuenciamn + 1;` |  |
| L504 | FÓRMULA | `LET wsecuenciadl = wsecuenciadl + 1;` |  |
| L548 | FÓRMULA | `LET wsecuenciamn = wsecuenciamn + 1;` |  |
| L552 | FÓRMULA | `LET wsecuenciadl = wsecuenciadl + 1;` |  |
| L618 | FÓRMULA | `LET wsecuenciamn = wsecuenciamn + 1;` |  |
| L622 | FÓRMULA | `LET wsecuenciadl = wsecuenciadl + 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `pasecont` | ACCION | realiza el pase contable (registro a póliza/mayor) | ✅ CÓDIGO | nombre_sp, texto_cuerpo |

---

## `precierre`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_precierre.sql` |
| **LOC (1er CREATE)** | 36 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "recepción" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 3 llamada(s): `contproc`, `auditor`, `nivelacion_ccostos` |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=2 / 3 términos |

### Firma

```sql
CREATE PROCEDURE precierre(
  pempresa                     char(3)
  w_fecha                      date
) RETURNING char(3)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pempresa` | `char(3)` | — | — |
| `w_fecha` | `date` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `w_proceso` | `char(20)` | L3 |
| `lv_cuantos` | `integer` | L4 |
| `cod_ret` | `char(3)` | L5 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `co_balprev` | `bdicont` | no | SELECT | L8 |
| `co_balprev` | `bdicont` | no | DELETE | L8 |
| `co_auditerr` | `bdicont` | no | SELECT | L15 |
| `co_auditerr` | `bdicont` | no | DELETE | L15 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `contproc` | `bdicont` | no | L13 |
| `auditor` | `bdicont` | no | L18 |
| `nivelacion_ccostos` | `bdicont` | no | L20 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `?p` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `rec` | ACCION | recepción / recibe | 🔵 CONVENCIÓN | nombre_sp |
| `?ierre` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?p`, `?ierre` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `r`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_r.sql` |
| **LOC (1er CREATE)** | 13 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "r" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — Tokens confirmados en el vocab pero DML no correlaciona con el propósito |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=0 · INFERIDO=0 · SINTÉTICO=1 / 1 términos |

### Firma

```sql
CREATE PROCEDURE r(
  fecha                        date
  mes                          char(2)
) RETURNING char(1)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `fecha` | `date` | — | — |
| `mes` | `char(2)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `retorno` | `char(1)` | L4 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `?r` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?r` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `renumera_sucursal`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_renumera_sucursal.sql` |
| **LOC (1er CREATE)** | 41 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "número y sucursal" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 2 tabla(s) con operaciones: UPDATE, SELECT |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=2 / 4 términos |

### Firma

```sql
CREATE PROCEDURE renumera_sucursal(
)
```

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `v_usuario` | `CHAR(8)` | L3 |
| `v_ctrl_poliza` | `INTEGER` | L4 |
| `v_fecha_captura` | `DATE` | L5 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `co_mensual` | `bdicont` | no | SELECT | L10 |
| `co_mensual` | `bdicont` | no | UPDATE | L32 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `?re` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `num` | ENTIDAD | número (de) | 🔵 CONVENCIÓN | nombre_sp |
| `?era_` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `sucursal` | ENTIDAD | sucursal | 🔵 CONVENCIÓN | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?re`, `?era_` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `reoaux`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_reoaux.sql` |
| **LOC (1er CREATE)** | 284 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "reoaux" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 8 tabla(s) con operaciones: SELECT, INSERT |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=1 / 2 términos |

### Firma

```sql
CREATE PROCEDURE reoaux(
  detauxiliar                  char(12)
  detsucursal                  char(4)
  detciudad                    char(3)
  detmayor                     char(10)
  detsub1                      char(10)
  detsub2                      char(10)
  detsub3                      char(10)
  detsub4                      char(10)
  detsector                    char(10)
  de1auxiliar                  char(12)
  vg_empresa                   char(3)
) RETURNING char(5)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `detauxiliar` | `char(12)` | `x`=por (criterio) | 🔵 CONVENCIÓN |
| `detsucursal` | `char(4)` | — | — |
| `detciudad` | `char(3)` | — | — |
| `detmayor` | `char(10)` | — | — |
| `detsub1` | `char(10)` | — | — |
| `detsub2` | `char(10)` | — | — |
| `detsub3` | `char(10)` | — | — |
| `detsub4` | `char(10)` | — | — |
| `detsector` | `char(10)` | — | — |
| `de1auxiliar` | `char(12)` | `x`=por (criterio) | 🔵 CONVENCIÓN |
| `vg_empresa` | `char(3)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `catccmayor` | `char(10)` | L15 |
| `catccsub` | `char(10)` | L16 |
| `catccsubsub` | `char(10)` | L17 |
| `catccssubsub` | `char(10)` | L18 |
| `catccsssubsub` | `char(10)` | L19 |
| `catsector` | `char(10)` | L20 |
| `catnaturaleza` | `char(1)` | L21 |
| `catauxiliar` | `char(1)` | L22 |
| `catmoneda` | `char(1)` | L23 |
| `auxmoneda` | `char(02)` | L24 |
| `auxciudad` | `char(3)` | L25 |
| `auxsucursal` | `char(4)` | L26 |
| `auxauxiliar` | `char(9)` | L27 |
| `auxsaldo` | `money(17,2)` | L28 |
| `poliusuario` | `char(8)` | L30 |
| `policontrol_poliza` | `smallint` | L31 |
| `polifecha_captura` | `date` | L32 |
| `polisecuencia` | `integer` | L33 |
| `poliempresa` | `char(3)` | L34 |
| `policcmayor` | `char(10)` | L35 |
| `policcsub` | `char(10)` | L36 |
| `policcsubsub` | `char(10)` | L37 |
| `policcssubsub` | `char(10)` | L38 |
| `policcsssubsub` | `char(10)` | L39 |
| `polisector` | `char(10)` | L40 |
| *…44 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `co_fechas` | `bdicont` | no | SELECT | L99 |
| `co_detpol` | `bdicont` | no | SELECT | L102 |
| `co_poliza` | `bdicont` | no | SELECT | L107 |
| `si_ejecut` | `bdinteg` | ⚠️ sí | SELECT | L123 |
| `si_catalog` | `bdinteg` | ⚠️ sí | SELECT | L157 |
| `co_diasaux` | `bdicont` | no | SELECT | L193 |
| `co_detpol` | `bdicont` | no | INSERT | L234 |
| `co_poliza` | `bdicont` | no | INSERT | L268 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L110 | VALIDACIÓN_NULL | `if (wconpol is null) then` |  |
| L113 | VALIDACIÓN_NULL | `if (wconpolco2 is null) then` |  |
| L120 | FÓRMULA | `let policontrol_poliza = policontrol_poliza + 1;` |  |
| L217 | FÓRMULA | `let auxsaldo = auxsaldo * (-1);` |  |
| L223 | FÓRMULA | `let auxsaldo = auxsaldo * (-1);` |  |
| L242 | FÓRMULA | `let polisecuencia = polisecuencia + 2;` |  |
| L251 | FÓRMULA | `let pol1secuencia = pol1secuencia + 2;` |  |
| L279 | FÓRMULA | `let v_mult = v_mult +1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `?reoau` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `x` | MODIF | por (criterio) | 🔵 CONVENCIÓN | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?reoau` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `reosec`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_reosec.sql` |
| **LOC (1er CREATE)** | 354 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "OS — Originación de Solicitudes" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 9 tabla(s) con operaciones: SELECT, INSERT |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=0 · INFERIDO=1 · SINTÉTICO=2 / 3 términos |

### Firma

```sql
CREATE PROCEDURE reosec(
  detsector                    char(2)
  detsucursal                  char(4)
  detciudad                    char(3)
  detmayor                     char(10)
  detsub1                      char(10)
  detsub2                      char(10)
  detsub3                      char(10)
  detsub4                      char(10)
  de1sector                    char(10)
  vg_empresa                   char(3)
) RETURNING char(5)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `detsector` | `char(2)` | — | — |
| `detsucursal` | `char(4)` | — | — |
| `detciudad` | `char(3)` | — | — |
| `detmayor` | `char(10)` | — | — |
| `detsub1` | `char(10)` | — | — |
| `detsub2` | `char(10)` | — | — |
| `detsub3` | `char(10)` | — | — |
| `detsub4` | `char(10)` | — | — |
| `de1sector` | `char(10)` | — | — |
| `vg_empresa` | `char(3)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `catccmayor` | `char(10)` | L14 |
| `catccsub` | `char(10)` | L15 |
| `catccsubsub` | `char(10)` | L16 |
| `catccssubsub` | `char(10)` | L17 |
| `catccsssubsub` | `char(10)` | L18 |
| `catsector` | `char(10)` | L19 |
| `catnaturaleza` | `char(1)` | L20 |
| `catauxiliar` | `char(1)` | L21 |
| `catmoneda` | `char(1)` | L22 |
| `auxmoneda` | `char(02)` | L23 |
| `auxciudad` | `char(3)` | L24 |
| `auxsucursal` | `char(4)` | L25 |
| `auxauxiliar` | `char(9)` | L26 |
| `auxsaldo` | `money(17,2)` | L27 |
| `poliusuario` | `char(8)` | L29 |
| `policontrol_poliza` | `smallint` | L30 |
| `polifecha_captura` | `date` | L31 |
| `polisecuencia` | `integer` | L32 |
| `poliempresa` | `char(3)` | L33 |
| `policcmayor` | `char(10)` | L34 |
| `policcsub` | `char(10)` | L35 |
| `policcsubsub` | `char(10)` | L36 |
| `policcssubsub` | `char(10)` | L37 |
| `policcsssubsub` | `char(10)` | L38 |
| `polisector` | `char(10)` | L39 |
| *…44 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `co_fechas` | `bdicont` | no | SELECT | L98 |
| `co_detpol` | `bdicont` | no | SELECT | L101 |
| `co_poliza` | `bdicont` | no | SELECT | L106 |
| `si_ejecut` | `bdinteg` | ⚠️ sí | SELECT | L122 |
| `si_catalog` | `bdinteg` | ⚠️ sí | SELECT | L156 |
| `co_sdodias` | `bdicont` | no | SELECT | L189 |
| `co_detpol` | `bdicont` | no | INSERT | L231 |
| `co_diasaux` | `bdicont` | no | SELECT | L260 |
| `co_poliza` | `bdicont` | no | INSERT | L338 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L109 | VALIDACIÓN_NULL | `if (wconpol is null) then` |  |
| L112 | VALIDACIÓN_NULL | `if (wconpolco2 is null) then` |  |
| L119 | FÓRMULA | `let policontrol_poliza = policontrol_poliza + 1;` |  |
| L214 | FÓRMULA | `let auxsaldo = auxsaldo * (-1);` |  |
| L220 | FÓRMULA | `let auxsaldo = auxsaldo * (-1);` |  |
| L239 | FÓRMULA | `let polisecuencia = polisecuencia + 2;` |  |
| L248 | FÓRMULA | `let pol1secuencia = pol1secuencia + 2;` |  |
| L287 | FÓRMULA | `let auxsaldo = auxsaldo * (-1);` |  |
| L293 | FÓRMULA | `let auxsaldo = auxsaldo * (-1);` |  |
| L312 | FÓRMULA | `let polisecuencia = polisecuencia + 2;` |  |
| L321 | FÓRMULA | `let pol1secuencia = pol1secuencia + 2;` |  |
| L349 | FÓRMULA | `let v_mult = v_mult +1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `?re` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `os` | ENTIDAD | OS — Originación de Solicitudes / subsistema de ofertas (sp_ | 🟡 INFERIDO | nombre_sp |
| `?ec` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?re`, `?ec` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `reosuc`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_reosuc.sql` |
| **LOC (1er CREATE)** | 358 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "OS — Originación de Solicitudes" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 11 tabla(s) con operaciones: SELECT, INSERT |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=0 · INFERIDO=1 · SINTÉTICO=2 / 3 términos |

### Firma

```sql
CREATE PROCEDURE reosuc(
  detsucursal                  char(4)
  detciudad                    char(3)
  detmayor                     char(10)
  detsub1                      char(10)
  detsub2                      char(10)
  detsub3                      char(10)
  detsub4                      char(10)
  detsector                    char(10)
  de1sucursal                  char(4)
  de1ciudad                    char(3)
  vg_empresa                   char(3)
) RETURNING char(5)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `detsucursal` | `char(4)` | — | — |
| `detciudad` | `char(3)` | — | — |
| `detmayor` | `char(10)` | — | — |
| `detsub1` | `char(10)` | — | — |
| `detsub2` | `char(10)` | — | — |
| `detsub3` | `char(10)` | — | — |
| `detsub4` | `char(10)` | — | — |
| `detsector` | `char(10)` | — | — |
| `de1sucursal` | `char(4)` | — | — |
| `de1ciudad` | `char(3)` | — | — |
| `vg_empresa` | `char(3)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `catccmayor` | `char(10)` | L15 |
| `catccsub` | `char(10)` | L16 |
| `catccsubsub` | `char(10)` | L17 |
| `catccssubsub` | `char(10)` | L18 |
| `catccsssubsub` | `char(10)` | L19 |
| `catsector` | `char(10)` | L20 |
| `catnaturaleza` | `char(1)` | L21 |
| `catauxiliar` | `char(1)` | L22 |
| `catmoneda` | `char(1)` | L23 |
| `auxmoneda` | `char(02)` | L24 |
| `auxciudad` | `char(3)` | L25 |
| `auxsucursal` | `char(4)` | L26 |
| `auxauxiliar` | `char(9)` | L27 |
| `auxsaldo` | `money(17,2)` | L28 |
| `poliusuario` | `char(8)` | L30 |
| `policontrol_poliza` | `smallint` | L31 |
| `polifecha_captura` | `date` | L32 |
| `polisecuencia` | `integer` | L33 |
| `poliempresa` | `char(3)` | L34 |
| `policcmayor` | `char(10)` | L35 |
| `policcsub` | `char(10)` | L36 |
| `policcsubsub` | `char(10)` | L37 |
| `policcssubsub` | `char(10)` | L38 |
| `policcsssubsub` | `char(10)` | L39 |
| `polisector` | `char(10)` | L40 |
| *…44 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `co_fechas` | `bdicont` | no | SELECT | L100 |
| `co_detpol` | `bdicont` | no | SELECT | L103 |
| `co_poliza` | `bdicont` | no | SELECT | L108 |
| `si_ejecut` | `bdinteg` | ⚠️ sí | SELECT | L124 |
| `si_plazas` | `bdinteg` | ⚠️ sí | SELECT | L151 |
| `si_sucursales` | `bdinteg` | ⚠️ sí | SELECT | L152 |
| `si_catalog` | `bdinteg` | ⚠️ sí | SELECT | L166 |
| `co_sdodias` | `bdicont` | no | SELECT | L201 |
| `co_detpol` | `bdicont` | no | INSERT | L239 |
| `co_diasaux` | `bdicont` | no | SELECT | L268 |
| `co_poliza` | `bdicont` | no | INSERT | L342 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L111 | VALIDACIÓN_NULL | `if (wconpol is null) then` |  |
| L114 | VALIDACIÓN_NULL | `if (wconpolco2 is null) then` |  |
| L121 | FÓRMULA | `let policontrol_poliza = policontrol_poliza + 1;` |  |
| L222 | FÓRMULA | `let auxsaldo = auxsaldo * (-1);` |  |
| L228 | FÓRMULA | `let auxsaldo = auxsaldo * (-1);` |  |
| L247 | FÓRMULA | `let polisecuencia = polisecuencia + 2;` |  |
| L256 | FÓRMULA | `let pol1secuencia = pol1secuencia + 2;` |  |
| L291 | FÓRMULA | `let auxsaldo = auxsaldo * (-1);` |  |
| L297 | FÓRMULA | `let auxsaldo = auxsaldo * (-1);` |  |
| L316 | FÓRMULA | `let polisecuencia = polisecuencia + 2;` |  |
| L325 | FÓRMULA | `let pol1secuencia = pol1secuencia + 2;` |  |
| L353 | FÓRMULA | `let v_mult = v_mult +1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `?re` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `os` | ENTIDAD | OS — Originación de Solicitudes / subsistema de ofertas (sp_ | 🟡 INFERIDO | nombre_sp |
| `?uc` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?re`, `?uc` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `rep_usuario_poliza`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_rep_usuario_poliza.sql` |
| **LOC (1er CREATE)** | 92 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "reporte usuario y póliza contable" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 1 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=0 / 3 términos |

### Firma

```sql
CREATE PROCEDURE rep_usuario_poliza(
  pempresa                     CHAR(3)
  pfecha_valida                DATE
) RETURNING CHAR(5),CHAR(3),CHAR(3),CHAR(4),CHAR(8),CHAR(2),
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pempresa` | `CHAR(3)` | — | — |
| `pfecha_valida` | `DATE` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `codret` | `CHAR(5)` | L6 |
| `sql_err` | `INTEGER` | L7 |
| `isam_err` | `INTEGER` | L8 |
| `error_info` | `CHAR(40)` | L9 |
| `vusuario` | `CHAR(8)` | L10 |
| `vcontrol_poliza` | `INTEGER` | L11 |
| `vfecha_captura` | `DATE` | L12 |
| `vciudad` | `CHAR(3)` | L13 |
| `vmonto` | `MONEY(18,2)` | L14 |
| `vfecha_valida` | `DATE` | L15 |
| `vmoneda` | `CHAR(2)` | L16 |
| `vvalor_cambio` | `MONEY(12,7)` | L17 |
| `vvalor_div_cambio` | `MONEY(12,7)` | L18 |
| `vccosto_orig` | `CHAR(4)` | L19 |
| `sumaCargos` | `MONEY(20,2)` | L20 |
| `sumaAbonos` | `MONEY(20,2)` | L21 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `co_detpol` | `bdicont` | no | SELECT | L42 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `rep` | ACCION | reporte | 🔵 CONVENCIÓN | nombre_sp |
| `usuario` | ENTIDAD | usuario | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `poliza` | ENTIDAD | póliza contable | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |

---

## `replicacoauxiliar`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_replicacoauxiliar.sql` |
| **LOC (1er CREATE)** | 92 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "reporte auxiliar contable — sub-ledger contable" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 2 tabla(s) con operaciones: SELECT, INSERT |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=1 · INFERIDO=1 · SINTÉTICO=2 / 5 términos |

### Firma

```sql
CREATE PROCEDURE replicacoauxiliar(
  pEmpleado                    CHAR(8)
  pSucursal                    CHAR(4)
  pApePat                      CHAR(26)
  pApeMat                      CHAR(26)
  pNom                         CHAR(50)
) RETURNING CHAR(10)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pEmpleado` | `CHAR(8)` | — | — |
| `pSucursal` | `CHAR(4)` | — | — |
| `pApePat` | `CHAR(26)` | — | — |
| `pApeMat` | `CHAR(26)` | — | — |
| `pNom` | `CHAR(50)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vCodRet` | `CHAR(5)` | L4 |
| `vNumAux` | `CHAR(12)` | L5 |
| `vNombre` | `CHAR(45)` | L6 |
| `vCanAfe` | `INTEGER` | L7 |
| `vAnio` | `INTEGER` | L8 |
| `vMesDia` | `CHAR(6)` | L9 |
| `vFecha` | `DATE` | L10 |
| `vLongIni` | `INTEGER` | L11 |
| `vLongFin` | `INTEGER` | L12 |
| `vPosBlank1` | `INTEGER` | L13 |
| `vPosBlank2` | `INTEGER` | L14 |
| `vNombre1` | `CHAR(12)` | L15 |
| `vNombre2` | `CHAR(12)` | L16 |
| `vValor` | `CHAR(1)` | L17 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `co_auxiliar` | `bdicont` | no | SELECT | L65 |
| `co_auxiliar` | `bdicont` | no | INSERT | L76 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L47 | FÓRMULA | `LET vLongIni = vLongIni + 1;` |  |
| L49 | FÓRMULA | `LET vLongIni = vLongIni + 1;` |  |
| L60 | FÓRMULA | `LET vNombre1 = SUBSTR((TRIM(pNom)),1,(vPosBlank2-1));` |  |
| L61 | FÓRMULA | `LET vNombre2 = SUBSTR((TRIM(pNom)),(vPosBlank2+1),12);` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `rep` | ACCION | reporte | 🔵 CONVENCIÓN | nombre_sp |
| `?li` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `cac` | PREFIJO | familia crédito (CAC) | 🟡 INFERIDO | nombre_sp |
| `?o` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `auxiliar` | ENTIDAD | auxiliar contable — sub-ledger contable (sdos_auxiliar, sp_v | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?li`, `?o` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `respalda`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_respalda.sql` |
| **LOC (1er CREATE)** | 109 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "respalda" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 1 llamada(s): `contproc` |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=0 · INFERIDO=0 · SINTÉTICO=0 / 1 términos |

### Firma

```sql
CREATE PROCEDURE respalda(
  pempresa                     char(3)
  pfecha_hoy                   date
) RETURNING char(5)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pempresa` | `char(3)` | — | — |
| `pfecha_hoy` | `date` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cod_ret` | `char(5)` | L4 |
| `v_directorio` | `char(50)` | L5 |
| `v_dia` | `char(2)` | L6 |
| `v_mes` | `char(2)` | L7 |
| `v_ano` | `char(4)` | L8 |
| `v_tabla` | `char(20)` | L9 |
| `v_tablaid` | `integer` | L10 |
| `v_colnomb` | `char(20)` | L11 |
| `v_sql` | `char(200)` | L12 |
| `nomb_tabla` | `char(800)` | L13 |
| `v_proceso` | `char(10)` | L14 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `co_param` | `bdicont` | no | SELECT | L35 |
| `co_tablas` | `bdicont` | no | SELECT | L61 |
| `systables` | `bdicont` | no | SELECT | L66 |
| `syscolumns` | `bdicont` | no | SELECT | L87 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `contproc` | `bdicont` | no | L41 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L38 | VALIDACIÓN_NULL | `if v_directorio is null or v_directorio = " " then` |  |
| L71 | VALIDACIÓN_NULL | `if v_tablaid is null then` |  |
| L91 | VALIDACIÓN_NULL | `if v_colnomb is null then` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `respalda` | ACCION | respalda / garantiza — aval o garantía de crédito (respalda_ | ✅ CÓDIGO | nombre_sp, texto_cuerpo |

---

## `retaux`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_retaux.sql` |
| **LOC (1er CREATE)** | 186 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "retaux" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 2 tabla(s) con operaciones: SELECT, INSERT |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=1 / 2 términos |

### Firma

```sql
CREATE PROCEDURE retaux(
  dempresa                     char(3)
  dccmayor                     char(10)
  dccsub                       char(10)
  dccsubsub                    char(10)
  dccssubsub                   char(10)
  dccsssubsub                  char(10)
  dsector                      char(10)
  dciudad                      char(3)
  dsucursal                    char(4)
  dmoneda                      char(2)
  dnaturaleza                  char(1)
  dnro_auxiliar                char(12)
  dfecha_valida                date
  dmonto                       money(18,2)
  tabonos                      money(18,2)
  tcargos                      money(18,2)
  tsaldo                       money(18,2)
  tnum_cargos                  integer
  tnum_abonos                  integer
  tnat_cta                     char(1)
  tauxiliar                    char(1)
  pfecha_hoy                   date
)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `dempresa` | `char(3)` | — | — |
| `dccmayor` | `char(10)` | — | — |
| `dccsub` | `char(10)` | — | — |
| `dccsubsub` | `char(10)` | — | — |
| `dccssubsub` | `char(10)` | — | — |
| `dccsssubsub` | `char(10)` | — | — |
| `dsector` | `char(10)` | — | — |
| `dciudad` | `char(3)` | — | — |
| `dsucursal` | `char(4)` | — | — |
| `dmoneda` | `char(2)` | — | — |
| `dnaturaleza` | `char(1)` | — | — |
| `dnro_auxiliar` | `char(12)` | `x`=por (criterio) | 🔵 CONVENCIÓN |
| `dfecha_valida` | `date` | — | — |
| `dmonto` | `money(18,2)` | — | — |
| `tabonos` | `money(18,2)` | — | — |
| `tcargos` | `money(18,2)` | — | — |
| `tsaldo` | `money(18,2)` | — | — |
| `tnum_cargos` | `integer` | — | — |
| `tnum_abonos` | `integer` | — | — |
| `tnat_cta` | `char(1)` | — | — |
| `tauxiliar` | `char(1)` | `x`=por (criterio) | 🔵 CONVENCIÓN |
| `pfecha_hoy` | `date` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `amoneda` | `char(2)` | L16 |
| `aciudad` | `char(3)` | L17 |
| `asucursal` | `char(4)` | L18 |
| `a_empresa` | `char(3)` | L19 |
| `aauxiliar` | `char(12)` | L20 |
| `ames_dia` | `date` | L21 |
| `anro_cargos_dia` | `smallint` | L24 |
| `anro_abonos_dia` | `smallint` | L25 |
| `adias_proyectado` | `smallint` | L26 |
| `adias_acumulados` | `smallint` | L27 |
| `asaldo_acumulado` | `money(18,2)` | L28 |
| `asaldo_inicio_dia` | `money(18,2)` | L29 |
| `asaldo_fin_de_dia` | `money(18,2)` | L30 |
| `v_ini_act` | `date` | L32 |
| `v_fin_act` | `date` | L33 |
| `v_mes_dia` | `date` | L34 |
| `v_fecha` | `date` | L35 |
| `v_num_dias` | `smallint` | L36 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `co_diasaux` | `bdicont` | no | SELECT | L48 |
| `co_diasaux` | `bdicont` | no | INSERT | L117 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L87 | VALIDACIÓN_NULL | `if v_mes_dia is null then` |  |
| L90 | FÓRMULA | `let v_fin_act = v_mes_dia - 1 units day;` |  |
| L102 | FÓRMULA | `let v_num_dias = day(ames_dia) - day(dfecha_valida) + 1;` |  |
| L106 | FÓRMULA | `let asaldo_acumulado = tsaldo * v_num_dias;` |  |
| L126 | FÓRMULA | `let ames_dia = ames_dia + 1 units day;` |  |
| L160 | FÓRMULA | `let v_ini_act = v_mes_dia + 1 units day;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `?retau` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `x` | MODIF | por (criterio) | 🔵 CONVENCIÓN | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?retau` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `retaux_h`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_retaux_h.sql` |
| **LOC (1er CREATE)** | 320 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "retaux_h" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 4 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=2 / 3 términos |

### Firma

```sql
CREATE PROCEDURE retaux_h(
  dempresa                     char(3)
  dccmayor                     char(10)
  dccsub                       char(10)
  dccsubsub                    char(10)
  dccssubsub                   char(10)
  dccsssubsub                  char(10)
  dsector                      char(10)
  dciudad                      char(3)
  dsucursal                    char(4)
  dmoneda                      char(2)
  dnaturaleza                  char(1)
  dnro_auxiliar                char(12)
  dfecha_valida                date
  dmonto                       money(18,2)
  tabonos                      money(18,2)
  tcargos                      money(18,2)
  tsaldo                       money(18,2)
  tnum_cargos                  integer
  tnum_abonos                  integer
  tnat_cta                     char(1)
  tauxiliar                    char(1)
  pfecha_hoy                   date
)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `dempresa` | `char(3)` | — | — |
| `dccmayor` | `char(10)` | — | — |
| `dccsub` | `char(10)` | — | — |
| `dccsubsub` | `char(10)` | — | — |
| `dccssubsub` | `char(10)` | — | — |
| `dccsssubsub` | `char(10)` | — | — |
| `dsector` | `char(10)` | — | — |
| `dciudad` | `char(3)` | — | — |
| `dsucursal` | `char(4)` | — | — |
| `dmoneda` | `char(2)` | — | — |
| `dnaturaleza` | `char(1)` | — | — |
| `dnro_auxiliar` | `char(12)` | `x`=por (criterio) | 🔵 CONVENCIÓN |
| `dfecha_valida` | `date` | — | — |
| `dmonto` | `money(18,2)` | — | — |
| `tabonos` | `money(18,2)` | — | — |
| `tcargos` | `money(18,2)` | — | — |
| `tsaldo` | `money(18,2)` | — | — |
| `tnum_cargos` | `integer` | — | — |
| `tnum_abonos` | `integer` | — | — |
| `tnat_cta` | `char(1)` | — | — |
| `tauxiliar` | `char(1)` | `x`=por (criterio) | 🔵 CONVENCIÓN |
| `pfecha_hoy` | `date` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `hmoneda` | `char(2)` | L16 |
| `hciudad` | `char(3)` | L17 |
| `hsucursal` | `char(4)` | L18 |
| `hempresa` | `char(3)` | L19 |
| `hauxiliar` | `char(12)` | L20 |
| `hmes_dia` | `date` | L21 |
| `hnro_cargos_dia` | `smallint` | L24 |
| `hnro_abonos_dia` | `smallint` | L25 |
| `hdias_proyectado` | `smallint` | L26 |
| `hdias_acumulado` | `smallint` | L27 |
| `hsaldo_acumulado` | `money(18,2)` | L28 |
| `hsaldo_inicio_dia` | `money(18,2)` | L29 |
| `hsaldo_fin_de_dia` | `money(18,2)` | L30 |
| `v_ini_act` | `date` | L32 |
| `v_fin_act` | `date` | L33 |
| `v_mes_dia` | `date` | L34 |
| `v_fecha` | `date` | L35 |
| `v_num_dias` | `smallint` | L36 |
| `v_meses` | `smallint` | L37 |
| `v_fechar` | `char(10)` | L38 |
| `lv_rowid` | `integer` | L39 |
| `v_mc1` | `char(2)` | L41 |
| `v_mc2` | `char(2)` | L42 |
| `v_ctaingini` | `char(10)` | L43 |
| `v_ctaingfin` | `char(10)` | L44 |
| *…9 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `co_fechas` | `bdicont` | no | SELECT | L57 |
| `co_param` | `bdicont` | no | SELECT | L66 |
| `si_catalog` | `bdinteg` | ⚠️ sí | SELECT | L79 |
| `co_histdiasaux` | `bdicont` | no | SELECT | L102 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L90 | FÓRMULA | `let tsaldo = tcargos - tabonos;` |  |
| L92 | FÓRMULA | `let tsaldo = tabonos - tcargos;` |  |
| L124 | FÓRMULA | `let v_ini_act  = dfecha_valida + 1 UNITS MONTH;` |  |
| L126 | FÓRMULA | `let v_fechar = v_fechar[1,2]\|\|"/01/"\|\|v_fechar[7,10];` |  |
| L166 | VALIDACIÓN_NULL | `if v_mes_dia is null then` |  |
| L167 | FÓRMULA | `let v_fin_act = vpri_dia_mes -1 units day;` |  |
| L169 | FÓRMULA | `let v_fin_act = v_mes_dia - 1 units day;` |  |
| L178 | FÓRMULA | `let v_num_dias = v_num_dias + 1;` |  |
| L184 | FÓRMULA | `let v_num_dias = day(hmes_dia) - day(dfecha_valida) + 1;` |  |
| L188 | FÓRMULA | `let hsaldo_acumulado = tsaldo * v_num_dias;` |  |
| L215 | VALIDACIÓN_NULL | `if lv_rowid is null or lv_rowid = " " then` |  |
| L228 | FÓRMULA | `let hmes_dia = hmes_dia + 1 units day;` |  |
| L269 | FÓRMULA | `let v_ini_act = v_mes_dia + 1 UNITS DAY;` |  |
| L281 | FÓRMULA | `let v_ini_act  = dfecha_valida + 1 UNITS MONTH;` |  |
| L283 | FÓRMULA | `let v_fechar = v_fechar[1,2]\|\|"/01/"\|\|v_fechar[7,10];` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `?retau` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `x` | MODIF | por (criterio) | 🔵 CONVENCIÓN | nombre_sp |
| `?_h` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?retau`, `?_h` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `retsdo`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_retsdo.sql` |
| **LOC (1er CREATE)** | 184 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "saldo" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 2 tabla(s) con operaciones: SELECT, INSERT |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=1 / 2 términos |

### Firma

```sql
CREATE PROCEDURE retsdo(
  dempresa                     char(3)
  dccmayor                     char(10)
  dccsub                       char(10)
  dccsubsub                    char(10)
  dccssubsub                   char(10)
  dccsssubsub                  char(10)
  dsector                      char(10)
  dciudad                      char(3)
  dsucursal                    char(4)
  dmoneda                      char(2)
  dnaturaleza                  char(1)
  dnro_auxiliar                char(12)
  dfecha_valida                date
  dmonto                       money(18,2)
  tabonos                      money(18,2)
  tcargos                      money(18,2)
  tsaldo                       money(18,2)
  tnum_cargos                  integer
  tnum_abonos                  integer
  tnat_cta                     char(1)
  tauxiliar                    char(1)
  pfecha_hoy                   date
)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `dempresa` | `char(3)` | — | — |
| `dccmayor` | `char(10)` | — | — |
| `dccsub` | `char(10)` | — | — |
| `dccsubsub` | `char(10)` | — | — |
| `dccssubsub` | `char(10)` | — | — |
| `dccsssubsub` | `char(10)` | — | — |
| `dsector` | `char(10)` | — | — |
| `dciudad` | `char(3)` | — | — |
| `dsucursal` | `char(4)` | — | — |
| `dmoneda` | `char(2)` | — | — |
| `dnaturaleza` | `char(1)` | — | — |
| `dnro_auxiliar` | `char(12)` | — | — |
| `dfecha_valida` | `date` | — | — |
| `dmonto` | `money(18,2)` | — | — |
| `tabonos` | `money(18,2)` | — | — |
| `tcargos` | `money(18,2)` | — | — |
| `tsaldo` | `money(18,2)` | — | — |
| `tnum_cargos` | `integer` | — | — |
| `tnum_abonos` | `integer` | — | — |
| `tnat_cta` | `char(1)` | — | — |
| `tauxiliar` | `char(1)` | — | — |
| `pfecha_hoy` | `date` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `smoneda` | `char(2)` | L16 |
| `sciudad` | `char(3)` | L17 |
| `ssucursal` | `char(4)` | L18 |
| `s_empresa` | `char(3)` | L19 |
| `smes_dia` | `date` | L20 |
| `snro_cargos_dia` | `smallint` | L23 |
| `snro_abonos_dia` | `smallint` | L24 |
| `sdias_proyectado` | `smallint` | L25 |
| `sdias_acumulado` | `smallint` | L26 |
| `ssaldo_acumulado` | `money(18,2)` | L27 |
| `ssaldo_inicio_dia` | `money(18,2)` | L28 |
| `ssaldo_fin_de_dia` | `money(18,2)` | L29 |
| `v_ini_act` | `date` | L31 |
| `v_fin_act` | `date` | L32 |
| `v_mes_dia` | `date` | L33 |
| `v_fecha` | `date` | L34 |
| `v_num_dias` | `smallint` | L35 |
| `lv_fec_fin` | `date` | L36 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `co_sdodias` | `bdicont` | no | SELECT | L50 |
| `co_sdodias` | `bdicont` | no | INSERT | L118 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L88 | VALIDACIÓN_NULL | `if v_mes_dia is null or v_mes_dia = " " then` |  |
| L91 | FÓRMULA | `let v_fin_act = v_mes_dia - 1 units day;` |  |
| L103 | FÓRMULA | `let v_num_dias = day(smes_dia) - day(dfecha_valida) + 1;` |  |
| L107 | FÓRMULA | `let ssaldo_acumulado = tsaldo * v_num_dias;` |  |
| L127 | FÓRMULA | `let smes_dia = smes_dia + 1 units day;` |  |
| L159 | FÓRMULA | `let v_ini_act = v_mes_dia + 1 units day;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `?ret` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `sdo` | ENTIDAD | saldo | 🔵 CONVENCIÓN | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?ret` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `retsdo_h`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_retsdo_h.sql` |
| **LOC (1er CREATE)** | 342 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "saldo" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 4 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=2 / 3 términos |

### Firma

```sql
CREATE PROCEDURE retsdo_h(
  dempresa                     char(3)
  dccmayor                     char(10)
  dccsub                       char(10)
  dccsubsub                    char(10)
  dccssubsub                   char(10)
  dccsssubsub                  char(10)
  dsector                      char(10)
  dciudad                      char(3)
  dsucursal                    char(4)
  dmoneda                      char(2)
  dnaturaleza                  char(1)
  dnro_auxiliar                char(12)
  dfecha_valida                date
  dmonto                       money(18,2)
  tabonos                      money(18,2)
  tcargos                      money(18,2)
  tsaldo                       money(18,2)
  tnum_cargos                  integer
  tnum_abonos                  integer
  tnat_cta                     char(1)
  tauxiliar                    char(1)
  pfecha_hoy                   date
  v_espergan                   char(1)
)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `dempresa` | `char(3)` | — | — |
| `dccmayor` | `char(10)` | — | — |
| `dccsub` | `char(10)` | — | — |
| `dccsubsub` | `char(10)` | — | — |
| `dccssubsub` | `char(10)` | — | — |
| `dccsssubsub` | `char(10)` | — | — |
| `dsector` | `char(10)` | — | — |
| `dciudad` | `char(3)` | — | — |
| `dsucursal` | `char(4)` | — | — |
| `dmoneda` | `char(2)` | — | — |
| `dnaturaleza` | `char(1)` | — | — |
| `dnro_auxiliar` | `char(12)` | — | — |
| `dfecha_valida` | `date` | — | — |
| `dmonto` | `money(18,2)` | — | — |
| `tabonos` | `money(18,2)` | — | — |
| `tcargos` | `money(18,2)` | — | — |
| `tsaldo` | `money(18,2)` | — | — |
| `tnum_cargos` | `integer` | — | — |
| `tnum_abonos` | `integer` | — | — |
| `tnat_cta` | `char(1)` | — | — |
| `tauxiliar` | `char(1)` | — | — |
| `pfecha_hoy` | `date` | — | — |
| `v_espergan` | `char(1)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `hmoneda` | `char(2)` | L16 |
| `hciudad` | `char(3)` | L17 |
| `hsucursal` | `char(4)` | L18 |
| `hempresa` | `char(3)` | L19 |
| `hmes_dia` | `date` | L20 |
| `hnro_cargos_dia` | `smallint` | L23 |
| `hnro_abonos_dia` | `smallint` | L24 |
| `hdias_proyectado` | `smallint` | L25 |
| `hdias_acumulado` | `smallint` | L26 |
| `hsaldo_acumulado` | `money(18,2)` | L27 |
| `hsaldo_inicio_dia` | `money(18,2)` | L28 |
| `hsaldo_fin_de_dia` | `money(18,2)` | L29 |
| `v_ini_act` | `date` | L31 |
| `v_fin_act` | `date` | L32 |
| `v_mes_dia` | `date` | L33 |
| `v_fecha` | `date` | L34 |
| `v_num_dias` | `smallint` | L35 |
| `v_fechar` | `char(10)` | L36 |
| `lv_rowid` | `integer` | L37 |
| `v_mc1` | `char(2)` | L39 |
| `v_mc2` | `char(2)` | L40 |
| `v_ctaingini` | `char(10)` | L41 |
| `v_ctaingfin` | `char(10)` | L42 |
| `v_ctagtoini` | `char(10)` | L43 |
| `v_ctagtofin` | `char(10)` | L44 |
| *…7 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `co_fechas` | `bdicont` | no | SELECT | L58 |
| `co_param` | `bdicont` | no | SELECT | L67 |
| `si_catalog` | `bdinteg` | ⚠️ sí | SELECT | L81 |
| `co_histsdodias` | `bdicont` | no | SELECT | L154 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L92 | FÓRMULA | `let tsaldo = tcargos - tabonos;` |  |
| L94 | FÓRMULA | `let tsaldo = tabonos - tcargos;` |  |
| L123 | FÓRMULA | `let v_fin_act = vpri_dia_mes -1 units day;` |  |
| L130 | FÓRMULA | `let v_num_dias = v_num_dias + 1;` |  |
| L136 | FÓRMULA | `let v_num_dias = day(hmes_dia) - day(dfecha_valida) + 1;` |  |
| L141 | FÓRMULA | `let hsaldo_acumulado = tsaldo * v_num_dias;` |  |
| L167 | VALIDACIÓN_NULL | `if lv_rowid is null or lv_rowid = " " then` |  |
| L339 | FÓRMULA | `let hmes_dia = hmes_dia + 1 units day;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `?ret` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `sdo` | ENTIDAD | saldo | 🔵 CONVENCIÓN | nombre_sp |
| `?_h` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?ret`, `?_h` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `retsdomes`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_retsdomes.sql` |
| **LOC (1er CREATE)** | 303 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "saldo y mes" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 4 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=1 / 3 términos |

### Firma

```sql
CREATE PROCEDURE retsdomes(
  dempresa                     char(3)
  dccmayor                     char(10)
  dccsub                       char(10)
  dccsubsub                    char(10)
  dccssubsub                   char(10)
  dccsssubsub                  char(10)
  dsector                      char(10)
  dciudad                      char(3)
  dsucursal                    char(4)
  dmoneda                      char(2)
  dnaturaleza                  char(1)
  dnro_auxiliar                char(12)
  dfecha_valida                date
  dmonto                       money(18,2)
  tabonos                      money(18,2)
  tcargos                      money(18,2)
  tsaldo                       money(18,2)
  tnum_cargos                  integer
  tnum_abonos                  integer
  tnat_cta                     char(1)
  tauxiliar                    char(1)
  pfecha_hoy                   date
  v_espergan                   char(1)
)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `dempresa` | `char(3)` | — | — |
| `dccmayor` | `char(10)` | — | — |
| `dccsub` | `char(10)` | — | — |
| `dccsubsub` | `char(10)` | — | — |
| `dccssubsub` | `char(10)` | — | — |
| `dccsssubsub` | `char(10)` | — | — |
| `dsector` | `char(10)` | — | — |
| `dciudad` | `char(3)` | — | — |
| `dsucursal` | `char(4)` | — | — |
| `dmoneda` | `char(2)` | — | — |
| `dnaturaleza` | `char(1)` | — | — |
| `dnro_auxiliar` | `char(12)` | — | — |
| `dfecha_valida` | `date` | — | — |
| `dmonto` | `money(18,2)` | — | — |
| `tabonos` | `money(18,2)` | — | — |
| `tcargos` | `money(18,2)` | — | — |
| `tsaldo` | `money(18,2)` | — | — |
| `tnum_cargos` | `integer` | — | — |
| `tnum_abonos` | `integer` | — | — |
| `tnat_cta` | `char(1)` | — | — |
| `tauxiliar` | `char(1)` | — | — |
| `pfecha_hoy` | `date` | — | — |
| `v_espergan` | `char(1)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `smoneda` | `char(2)` | L16 |
| `sciudad` | `char(3)` | L17 |
| `ssucursal` | `char(4)` | L18 |
| `sempresa` | `char(3)` | L19 |
| `sano_mes` | `datetime year to month` | L20 |
| `snro_cargos_mes` | `smallint` | L23 |
| `snro_abonos_mes` | `smallint` | L24 |
| `sdias_proyectado` | `smallint` | L25 |
| `sdias_acumulado` | `smallint` | L26 |
| `ssaldo_acumulado` | `money(18,2)` | L27 |
| `ssaldo_inicio_mes` | `money(18,2)` | L28 |
| `ssaldo_fin_de_mes` | `money(18,2)` | L29 |
| `v_mc1` | `char(2)` | L31 |
| `v_mc2` | `char(2)` | L32 |
| `v_ctaingini` | `char(10)` | L33 |
| `v_ctaingfin` | `char(10)` | L34 |
| `v_ctagtoini` | `char(10)` | L35 |
| `v_ctagtofin` | `char(10)` | L36 |
| `v_perganmay` | `char(10)` | L37 |
| `v_pergansub` | `char(10)` | L38 |
| `v_perganss` | `char(10)` | L39 |
| `v_pergansss` | `char(10)` | L40 |
| `v_perganssss` | `char(10)` | L41 |
| `v_pergansect` | `char(10)` | L42 |
| `v_ini_act` | `datetime year to month` | L44 |
| *…9 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `co_fechas` | `bdicont` | no | SELECT | L58 |
| `co_param` | `bdicont` | no | SELECT | L67 |
| `si_catalog` | `bdinteg` | ⚠️ sí | SELECT | L72 |
| `co_sdomes` | `bdicont` | no | SELECT | L157 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L83 | FÓRMULA | `let tsaldo = tcargos - tabonos;` |  |
| L85 | FÓRMULA | `let tsaldo = tabonos - tcargos;` |  |
| L98 | FÓRMULA | `LET dfecha_valida = dfecha_valida + 1 units month;` |  |
| L132 | FÓRMULA | `let vpri_dia_mes = vpri_dia_mes -1 units day;` |  |
| L140 | FÓRMULA | `let v_num_mes = v_num_mes + 1;` |  |
| L150 | FÓRMULA | `let ssaldo_acumulado  = tsaldo * sdias_acumulado;` |  |
| L171 | VALIDACIÓN_NULL | `if lv_rowid is null or lv_rowid = " " then` |  |
| L300 | FÓRMULA | `let sano_mes = sano_mes + 1 units month;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `?ret` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `sdo` | ENTIDAD | saldo | 🔵 CONVENCIÓN | nombre_sp |
| `mes` | ENTIDAD | mes | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?ret` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `revaloriza`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_revaloriza.sql` |
| **LOC (1er CREATE)** | 922 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 1 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "reversión" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 10 tabla(s) con operaciones: UPDATE, SELECT, INSERT |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=0 · INFERIDO=1 · SINTÉTICO=1 / 2 términos |

### Firma

```sql
CREATE PROCEDURE revaloriza(
  p_empresa                    CHAR(3)
  p_usuario                    CHAR(8)
  p_password                   CHAR(8)
) RETURNING CHAR(5)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_empresa` | `CHAR(3)` | — | — |
| `p_usuario` | `CHAR(8)` | — | — |
| `p_password` | `CHAR(8)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cod_ret` | `CHAR(5)` | L6 |
| `sql_err` | `INTEGER` | L7 |
| `isam_err` | `INTEGER` | L8 |
| `error_info` | `CHAR(40)` | L9 |
| `nrows` | `INTEGER` | L10 |
| `whorafol` | `DATETIME HOUR TO FRACTION(3)` | L11 |
| `whoratemp` | `CHAR(12)` | L12 |
| `wusegen` | `CHAR(8)` | L13 |
| `wtot_inter` | `MONEY(14,2)` | L14 |
| `wtot_cap` | `MONEY(14,2)` | L15 |
| `wcodinter` | `CHAR(5)` | L16 |
| `wcodcap` | `CHAR(5)` | L17 |
| `c` | `INTEGER` | L19 |
| `contador` | `INTEGER` | L20 |
| `wcontador` | `CHAR(3)` | L21 |
| `v_contador` | `INTEGER` | L22 |
| `cuenta` | `CHAR(4)` | L24 |
| `subcta` | `CHAR(2)` | L25 |
| `subsubcta` | `CHAR(6)` | L26 |
| `ssubsubcta` | `CHAR(6)` | L27 |
| `sssubsubcta` | `CHAR(6)` | L28 |
| `regional` | `CHAR(2)` | L30 |
| `fecha` | `DATE` | L32 |
| `mes_aplica` | `CHAR(2)` | L33 |
| `wmoneda` | `CHAR(2)` | L34 |
| *…181 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_ejecut` | `bdinteg` | ⚠️ sí | SELECT | L395 |
| `si_empresas` | `bdinteg` | ⚠️ sí | SELECT | L411 |
| `co_contproc` | `bdicont` | no | SELECT | L420 |
| `si_feriado` | `bdinteg` | ⚠️ sí | SELECT | L459 |
| `co_param` | `bdicont` | no | SELECT | L495 |
| `si_histdiv` | `bdinteg` | ⚠️ sí | SELECT | L511 |
| `co_histsdodias` | `bdicont` | no | SELECT | L523 |
| `co_ctrlpoliza` | `bdicont` | no | UPDATE | L698 |
| `co_poliza` | `bdicont` | no | UPDATE | L879 |
| `co_contproc` | `bdicont` | no | INSERT | L901 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L451 | FÓRMULA | `LET wfecha_ant = g_pri_dia_mes - 1 units day;` |  |
| L454 | FÓRMULA | `let wfecha_ant = wfecha_ant - 1 units day;` |  |
| L456 | FÓRMULA | `let wfecha_ant = wfecha_ant - 1;` |  |
| L464 | FÓRMULA | `let wfecha_ant = wfecha_ant - 1 units day;` |  |
| L498 | VALIDACIÓN_NULL | `IF pempresa IS NULL OR pempresa = " " THEN` |  |
| L507 | FÓRMULA | `LET wfecha_cotiza = g_pri_dia_mes - 1 units month;` |  |
| L519 | FÓRMULA | `LET lv_fecha_hist = g_fecha_hoy - 1 units month;` |  |
| L615 | FÓRMULA | `LET lv_revalorizada = lv_revalorizada * -1;` |  |
| L618 | FÓRMULA | `LET lv_saldo = lv_saldo * -1;` |  |
| L621 | FÓRMULA | `LET lv_monto = lv_saldo - lv_revalorizada;` | 🔴 MONEY/aritmética financiera |
| L639 | FÓRMULA | `LET lv_monto = lv_monto * -1;` | 🔴 MONEY/aritmética financiera |
| L663 | VALIDACIÓN_NULL | `IF (maxdetpol IS NULL) THEN` |  |
| L685 | VALIDACIÓN_NULL | `IF (maxpol is null) THEN` |  |
| L696 | FÓRMULA | `LET lv_control_poliza = lv_control_poliza + 1;` |  |
| L756 | FÓRMULA | `LET lv_secuencia = lv_secuencia + 1;` |  |
| L817 | FÓRMULA | `LET lv_secuencia = lv_secuencia + 1;` |  |
| L845 | FÓRMULA | `LET lv_secuencia = lv_secuencia + 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `rev` | ACCION | reversión (abreviación de reversa/reverso) | 🟡 INFERIDO | nombre_sp |
| `?aloriza` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?aloriza` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `rptconciliacion`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_rptconciliacion.sql` |
| **LOC (1er CREATE)** | 308 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "conciliación reporte" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 10 tabla(s) con operaciones: DELETE, SELECT, INSERT |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=0 / 2 términos |

### Firma

```sql
CREATE PROCEDURE rptconciliacion(
  pv_empresa                   CHAR(3)
  pd_fechaRep                  date
  pv_currentusr                VARCHAR(10)
) RETURNING INTEGER, VARCHAR(10)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pv_empresa` | `CHAR(3)` | — | — |
| `pd_fechaRep` | `date` | — | — |
| `pv_currentusr` | `VARCHAR(10)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `ln_err` | `INTEGER` | L3 |
| `lv_paso` | `VARCHAR(10)` | L4 |
| `ld_fecha_proceso` | `date` | L6 |
| `lv_sistema` | `char(2)` | L7 |
| `lv_empresa` | `char(3)` | L8 |
| `lv_ccmayor` | `char(10)` | L9 |
| `lv_ccsub` | `char(10)` | L10 |
| `lv_ccsubsub` | `char(10)` | L11 |
| `lv_ccssubsub` | `char(10)` | L12 |
| `lv_ccsssubsub` | `char(10)` | L13 |
| `lv_sector` | `char(10)` | L14 |
| `lv_cta_Cliente` | `char(11)` | L15 |
| `lv_ciudad` | `char(3)` | L16 |
| `lv_folio` | `char(16)` | L17 |
| `lv_sucursal` | `char(04)` | L18 |
| `ln_debitos` | `money(18,2)` | L19 |
| `ln_creditos` | `money(18,2)` | L20 |
| `ln_debitos_suc` | `money(18,2)` | L21 |
| `ln_creditos_suc` | `money(18,2)` | L22 |
| `lv_descripcion_det` | `char(80)` | L23 |
| `lv_ccosto_dest` | `char(4)` | L24 |
| `lv_moneda` | `char(2)` | L25 |
| `ln_nDebitos` | `INTEGER` | L26 |
| `ln_nCreditos` | `INTEGER` | L27 |
| `ln_nDebitos_suc` | `INTEGER` | L28 |
| *…5 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `co_fechas` | `bdicont` | no | SELECT | L51 |
| `co_auditerr_cint` | `bdicont` | no | INSERT | L56 |
| `co_mensual` | `bdicont` | no | SELECT | L91 |
| `tbenlacesis` | `bdicont` | no | SELECT | L112 |
| `co_historico` | `bdicont` | no | SELECT | L188 |
| `co_auditerr_cint` | `bdicont` | no | SELECT | L269 |
| `co_auditerr_cint` | `bdicont` | no | DELETE | L269 |
| `si_sucursales` | `bdinteg` | ⚠️ sí | SELECT | L274 |
| `co_audconresum` | `bdicont` | no | INSERT | L281 |
| `co_audconresum` | `bdicont` | no | SELECT | L299 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `rpt` | ENTIDAD | reporte | 🔵 CONVENCIÓN | nombre_sp |
| `conciliacion` | ACCION | conciliación | 🔵 CONVENCIÓN | nombre_sp |

---

## `rrevaloriza`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_rrevaloriza.sql` |
| **LOC (1er CREATE)** | 243 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "reversión" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 6 tabla(s) con operaciones: SELECT, INSERT |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=0 · INFERIDO=0 · SINTÉTICO=2 / 3 términos |

### Firma

```sql
CREATE PROCEDURE rrevaloriza(
  pempresa                     char(3)
  pfecha_hoy                   date
  pusuario                     char(8)
) RETURNING char(5)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pempresa` | `char(3)` | — | — |
| `pfecha_hoy` | `date` | — | — |
| `pusuario` | `char(8)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `ghusuario` | `char(8)` | L4 |
| `ghcontrol_poliza` | `smallint` | L5 |
| `ghfecha_captura` | `date` | L6 |
| `ghsecuencia` | `integer` | L7 |
| `ghempresa` | `char(3)` | L8 |
| `ghccmayor` | `char(4)` | L9 |
| `ghccsub` | `char(2)` | L10 |
| `ghccsubsub` | `char(2)` | L11 |
| `ghccssubsub` | `char(2)` | L12 |
| `ghccsssubsub` | `char(2)` | L13 |
| `ghsector` | `char(2)` | L14 |
| `ghciudad` | `char(3)` | L15 |
| `ghsucursal` | `char(4)` | L16 |
| `ghnaturaleza` | `char(1)` | L17 |
| `ghnro_auxiliar` | `char(12)` | L18 |
| `ghmonto` | `money(18,2)` | L19 |
| `ghdescripcion` | `char(50)` | L20 |
| `ghfecha_valida` | `date` | L21 |
| `ghmoneda` | `char(2)` | L22 |
| `ghvalor_cambio` | `money(12,7)` | L23 |
| `ghvalor_div_cambio` | `money(12,7)` | L24 |
| `ghpoliza_usuario` | `char(8)` | L25 |
| `ghtipo_mov` | `char(1)` | L26 |
| `gmusuario` | `char(8)` | L28 |
| `gmcontrol_poliza` | `smallint` | L29 |
| *…33 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `co_fechas` | `bdicont` | no | SELECT | L71 |
| `co_detpol` | `bdicont` | no | SELECT | L76 |
| `co_historico` | `bdicont` | no | SELECT | L117 |
| `co_detpol` | `bdicont` | no | INSERT | L139 |
| `co_mensual` | `bdicont` | no | SELECT | L177 |
| `co_poliza` | `bdicont` | no | INSERT | L237 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L80 | VALIDACIÓN_NULL | `if v_numpol is null then` |  |
| L88 | FÓRMULA | `let v_num_poliza = v_num_poliza + 1;` |  |
| L229 | VALIDACIÓN_NULL | `if monto_debito is null then` |  |
| L232 | VALIDACIÓN_NULL | `if monto_credito is null then` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `?r` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `rev` | ACCION | reversión (abreviación de reversa/reverso) | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?aloriza` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?r`, `?aloriza` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `saldosi`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_saldosi.sql` |
| **LOC (1er CREATE)** | 73 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "saldos" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 2 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=1 / 2 términos |

### Firma

```sql
CREATE PROCEDURE saldosi(
)
```

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `v_empresa` | `char(3)` | L2 |
| `v_ccmayor` | `char(3)` | L3 |
| `v_ccsub` | `char(3)` | L4 |
| `v_ccsubsub` | `char(3)` | L5 |
| `v_ccssubsub` | `char(3)` | L6 |
| `v_ccsssubsub` | `char(3)` | L7 |
| `v_sector` | `char(3)` | L8 |
| `v_row` | `integer` | L9 |
| `v_nat_cta` | `char(1)` | L10 |
| `v_nat_movto` | `char(1)` | L11 |
| `v_cambia_nat` | `char(1)` | L12 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `co_detpol` | `bdicont` | no | SELECT | L37 |
| `si_catalog` | `bdinteg` | ⚠️ sí | SELECT | L41 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `saldos` | ENTIDAD | saldos | 🔵 CONVENCIÓN | nombre_sp |
| `?i` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?i` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sdo_dias`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_sdo_dias.sql` |
| **LOC (1er CREATE)** | 149 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "saldo (del día)" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 4 tabla(s) con operaciones: SELECT, INSERT |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=0 · INFERIDO=0 · SINTÉTICO=1 / 3 términos |

### Firma

```sql
CREATE PROCEDURE sdo_dias(
  pempresa                     char(3)
) RETURNING char(5)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pempresa` | `char(3)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `sql_err` | `INTEGER` | L4 |
| `cod_ret` | `char(5)` | L6 |
| `vmes_dia` | `date` | L8 |
| `lv_renglon` | `integer` | L9 |
| `sql_stmt` | `char(500)` | L11 |
| `v_sdo_fin_mes` | `money(18,2)` | L12 |
| `sempresa` | `char(3)` | L13 |
| `sccmayor` | `char(10)` | L14 |
| `sccsub` | `char(10)` | L15 |
| `sccsubsub` | `char(10)` | L16 |
| `sccssubsub` | `char(10)` | L17 |
| `sccsssubsub` | `char(10)` | L18 |
| `ssector` | `char(10)` | L19 |
| `sciudad` | `char(3)` | L20 |
| `ssucursal` | `char(4)` | L21 |
| `smoneda` | `char(2)` | L22 |
| `smes_dia` | `date` | L23 |
| `scargos_dia` | `money(18,2)` | L24 |
| `sabonos_dia` | `money(18,2)` | L25 |
| `snro_cargos_dia` | `integer` | L26 |
| `snro_abonos_dia` | `integer` | L27 |
| `sdias_proyectado` | `smallint` | L28 |
| `sdias_acumulado` | `smallint` | L29 |
| `ssaldo_acumulado` | `money(18,2)` | L30 |
| `ssaldo_inicio_dia` | `money(18,2)` | L31 |
| *…4 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `co_fechas` | `bdicont` | no | SELECT | L46 |
| `co_cierre_cif` | `bdicont` | no | SELECT | L49 |
| `co_sdodias` | `bdicont` | no | SELECT | L85 |
| `co_sdodias` | `bdicont` | no | INSERT | L115 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L58 | FÓRMULA | `LET cant_dias = pprox_fecha - pfecha_hoy;` |  |
| L59 | FÓRMULA | `LET cant_dias = cant_dias + 1;` |  |
| L95 | FÓRMULA | `LET ssaldo_acumulado = ssaldo_acumulado +` |  |
| L103 | FÓRMULA | `LET cont_otro_mes    = cont_otro_mes + 1;` |  |
| L138 | FÓRMULA | `LET fecha_aux = fecha_aux + 1 units day;` |  |
| L141 | FÓRMULA | `LET fecha_aux = fecha_aux - 1 units day;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sdo` | ENTIDAD | saldo | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `dia` | MODIF | del día | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `?s` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?s` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sdos_auxiliar`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_sdos_auxiliar.sql` |
| **LOC (1er CREATE)** | 227 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 2 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "saldos y auxiliar contable — sub-ledger contable" `[partial]` |
| **Propósito verificado** | ❓ NO_VERIFICABLE — Propósito inferido; sin evidencia DML para verificar |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=0 · INFERIDO=1 · SINTÉTICO=0 / 2 términos |

### Firma

```sql
CREATE PROCEDURE sdos_auxiliar(
  p_empresa                    CHAR(3)
) RETURNING CHAR(5)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_empresa` | `CHAR(3)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `codret` | `CHAR(5)` | L4 |
| `sql_err` | `SMALLINT` | L5 |
| `isam_err` | `SMALLINT` | L6 |
| `error_info` | `CHAR(40)` | L7 |
| `GLOBAL` | `v_fecha_hoy            DATE DEFAULT ""` | L9 |
| `GLOBAL` | `v_fecha_ant            DATE DEFAULT ""` | L10 |
| `GLOBAL` | `v_prox_fecha           DATE DEFAULT ""` | L11 |
| `GLOBAL` | `v_ccmayor              CHAR(10) DEFAULT "          "` | L12 |
| `GLOBAL` | `v_ccsub                CHAR(10) DEFAULT "          "` | L13 |
| `GLOBAL` | `v_ccsubsub             CHAR(10) DEFAULT "          "` | L14 |
| `GLOBAL` | `v_ccssubsub            CHAR(10) DEFAULT "          "` | L15 |
| `GLOBAL` | `v_ccsssubsub           CHAR(10) DEFAULT "          "` | L16 |
| `GLOBAL` | `v_sector               CHAR(10) DEFAULT "          "` | L17 |
| `GLOBAL` | `v_naturaleza_cta       CHAR(1) DEFAULT " "` | L18 |
| `GLOBAL` | `v_auxiliar             CHAR(1) DEFAULT " "` | L19 |
| `GLOBAL` | `v_ciudad               CHAR(3) DEFAULT "   "` | L20 |
| `GLOBAL` | `v_sucursal             CHAr(4) DEFAULT "   "` | L21 |
| `lv_maxdia` | `DATE` | L23 |
| `lv_moneda` | `CHAR(2)` | L24 |
| `lv_cargos_dia` | `MONEY(14,2)` | L25 |
| `lv_abonos_dia` | `MONEY(14,2)` | L26 |
| `lv_sdo_fin_de_dia` | `MONEY(14,2)` | L27 |
| `lv_nat_movto` | `CHAR(1)` | L28 |
| `wsdo_fin_de_dia` | `MONEY(14,2)` | L29 |
| `lv_nroaux` | `CHAR(12)` | L30 |
| *…1 más…* | | |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L140 | FÓRMULA | `LET wsdo_fin_de_dia = lv_sdo_fin_de_dia * -1;` |  |
| L189 | FÓRMULA | `LET wsdo_fin_de_dia = lv_sdo_fin_de_dia * -1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sdos` | ENTIDAD | saldos (abreviación) | 🟡 INFERIDO | nombre_sp |
| `auxiliar` | ENTIDAD | auxiliar contable — sub-ledger contable (sdos_auxiliar, sp_v | ✅ CÓDIGO | nombre_sp, texto_cuerpo |

---

## `sdos_sin_auxiliar`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_sdos_sin_auxiliar.sql` |
| **LOC (1er CREATE)** | 225 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 1 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "saldos y auxiliar contable — sub-ledger contable" `[partial]` |
| **Propósito verificado** | ❓ NO_VERIFICABLE — Propósito inferido; sin evidencia DML para verificar |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=1 · INFERIDO=1 · SINTÉTICO=1 / 3 términos |

### Firma

```sql
CREATE PROCEDURE sdos_sin_auxiliar(
  p_empresa                    CHAR(3)
) RETURNING CHAR(5)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_empresa` | `CHAR(3)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `codret` | `CHAR(5)` | L4 |
| `sql_err` | `SMALLINT` | L5 |
| `isam_err` | `SMALLINT` | L6 |
| `error_info` | `CHAR(40)` | L7 |
| `GLOBAL` | `v_fecha_hoy            DATE DEFAULT ""` | L9 |
| `GLOBAL` | `v_fecha_ant            DATE DEFAULT ""` | L10 |
| `GLOBAL` | `v_prox_fecha           DATE DEFAULT ""` | L11 |
| `GLOBAL` | `v_ccmayor              CHAR(10) DEFAULT "          "` | L12 |
| `GLOBAL` | `v_ccsub                CHAR(10) DEFAULT "          "` | L13 |
| `GLOBAL` | `v_ccsubsub             CHAR(10) DEFAULT "          "` | L14 |
| `GLOBAL` | `v_ccssubsub            CHAR(10) DEFAULT "          "` | L15 |
| `GLOBAL` | `v_ccsssubsub           CHAR(10) DEFAULT "          "` | L16 |
| `GLOBAL` | `v_sector               CHAR(10) DEFAULT "          "` | L17 |
| `GLOBAL` | `v_naturaleza_cta       CHAR(1) DEFAULT " "` | L18 |
| `GLOBAL` | `v_auxiliar             CHAR(1) DEFAULT " "` | L19 |
| `GLOBAL` | `v_ciudad               CHAR(3) DEFAULT "   "` | L21 |
| `GLOBAL` | `v_sucursal             CHAr(4) DEFAULT "   "` | L22 |
| `lv_maxdia` | `DATE` | L24 |
| `lv_moneda` | `CHAR(2)` | L25 |
| `lv_cargos_dia` | `MONEY(14,2)` | L26 |
| `lv_abonos_dia` | `MONEY(14,2)` | L27 |
| `lv_sdo_fin_de_dia` | `MONEY(14,2)` | L28 |
| `lv_nat_movto` | `CHAR(1)` | L29 |
| `wsdo_fin_de_dia` | `MONEY(14,2)` | L30 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L137 | FÓRMULA | `LET wsdo_fin_de_dia = lv_sdo_fin_de_dia * -1;` |  |
| L187 | FÓRMULA | `LET wsdo_fin_de_dia = lv_sdo_fin_de_dia * -1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sdos` | ENTIDAD | saldos (abreviación) | 🟡 INFERIDO | nombre_sp |
| `?_sin_` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `auxiliar` | ENTIDAD | auxiliar contable — sub-ledger contable (sdos_auxiliar, sp_v | 🔵 CONVENCIÓN | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_sin_` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_actualiza_fechas_incidencia`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_sp_actualiza_fechas_incidencia.sql` |
| **LOC (1er CREATE)** | 108 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "actualiza fechas y identificador" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `actualiza` → `UPDATE` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=2 / 6 términos |

### Firma

```sql
CREATE PROCEDURE sp_actualiza_fechas_incidencia(
) RETURNING CHAR (5) ,
```

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cod_ret` | `char(5)` | L22 |
| `iSqlErr` | `integer` | L23 |
| `cCodErr` | `CHAR(5)` | L25 |
| `vDesErr` | `VARCHAR(60)` | L26 |
| `cursor_actfecha` | `INTEGER` | L28 |
| `vsecuencia` | `INTEGER` | L30 |
| `vsFlagEnTransaccion` | `CHAR (1)` | L32 |
| `v_registros` | `INTEGER` | L35 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `co_detpol` | `bdicont` | no | SELECT | L66 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L97 | FÓRMULA | `LET v_registros = v_registros + 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `actualiza` | ACCION | actualiza | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `fechas` | ENTIDAD | fechas | 🔵 CONVENCIÓN | nombre_sp |
| `?_inc` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `id` | ENTIDAD | identificador (de) | 🔵 CONVENCIÓN | nombre_sp |
| `?encia` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_inc`, `?encia` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_borrarcointegracion`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_sp_borrarcointegracion.sql` |
| **LOC (1er CREATE)** | 28 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "interés" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 2 tabla(s) con operaciones: SELECT, DELETE |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=1 · INFERIDO=1 · SINTÉTICO=2 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_borrarcointegracion(
  pempresa                     CHAR(3)
  p_susuario                   CHAR(8)
) RETURNING CHAR(6) AS retorno
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pempresa` | `CHAR(3)` | — | — |
| `p_susuario` | `CHAR(8)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cod_ret` | `CHAR(6)` | L4 |
| `isam_err` | `INTEGER` | L5 |
| `error_info` | `CHAR(6)` | L6 |
| `sql_err` | `INTEGER` | L7 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `co_integracion` | `bdicont` | no | SELECT | L23 |
| `co_integracion` | `bdicont` | no | DELETE | L23 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `?_borrarco` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `int` | ENTIDAD | interés | 🟡 INFERIDO | nombre_sp |
| `?egracion` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_borrarco`, `?egracion` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_borrardatos`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_sp_borrardatos.sql` |
| **LOC (1er CREATE)** | 85 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "datos" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 2 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=1 / 3 términos |

### Firma

```sql
CREATE PROCEDURE sp_borrardatos(
  v_usuario                    CHAR(10)
)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `v_usuario` | `CHAR(10)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `v_rowid` | `INTEGER` | L3 |
| `vsFlagEnTransaccion` | `CHAR(1)` | L4 |
| `viContadorRegistros` | `INTEGER` | L5 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `co_libmadet` | `bdicont` | no | SELECT | L19 |
| `co_libsdoaux` | `bdicont` | no | SELECT | L56 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L30 | FÓRMULA | `LET viContadorRegistros = viContadorRegistros + 1;` |  |
| L67 | FÓRMULA | `LET viContadorRegistros = viContadorRegistros + 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `?_borrar` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `datos` | ENTIDAD | datos | 🔵 CONVENCIÓN | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_borrar` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_borrardetpol`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_sp_borrardetpol.sql` |
| **LOC (1er CREATE)** | 71 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "detalle" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 2 tabla(s) con operaciones: SELECT, DELETE |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=1 · INFERIDO=1 · SINTÉTICO=2 / 4 términos |

### Historia del SP

| Tipo | Valor |
|------|-------|
| MODIFICACION | --* |
| DESCRIPCION | Se le cambió la firma al SP de "borrarpolizadetalle" a --* |
| MODIFICACION | César andrés De Anda Alcántara --* |
| FECHA | 17/06/2009 --* |

### Firma

```sql
CREATE PROCEDURE sp_borrardetpol(
  pusuario                     CHAR(8)
  pcontrol_poliza              INTEGER
  pfecha_captura               DATE
  pempresa                     CHAR(3)
  pmoneda                      CHAR(2)
) RETURNING CHAR(6)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pusuario` | `CHAR(8)` | — | — |
| `pcontrol_poliza` | `INTEGER` | — | — |
| `pfecha_captura` | `DATE` | — | — |
| `pempresa` | `CHAR(3)` | — | — |
| `pmoneda` | `CHAR(2)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(6)` | L9 |
| `iSqlErr` | `INTEGER` | L10 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `co_detpol` | `bdicont` | no | SELECT | L48 |
| `co_detpol` | `bdicont` | no | DELETE | L52 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L43 | VALIDACIÓN_NULL | `IF pusuario = '' OR pusuario IS NULL OR pcontrol_poliza = '' OR pcontrol_poliza IS NULL` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `?_borrar` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `det` | ENTIDAD | detalle | 🟡 INFERIDO | nombre_sp |
| `?pol` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_borrar`, `?pol` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_borrarencpol`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_sp_borrarencpol.sql` |
| **LOC (1er CREATE)** | 61 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "código postal" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 2 tabla(s) con operaciones: SELECT, DELETE |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=1 · INFERIDO=1 · SINTÉTICO=2 / 4 términos |

### Historia del SP

| Tipo | Valor |
|------|-------|
| ACTIVIDAD | Eliminacion del encabezado de una poliza contable --* |
| MODIFICACION | Se cambió la firma del Sp, de borrarpolizaencabezado por --* |
| MODIFICACION | César Andrés De Anda Alcántara --* |
| FECHA | 17/06/2009 |

### Firma

```sql
CREATE PROCEDURE sp_borrarencpol(
  pusuario                     CHAR(8)
  pcontrol_poliza              INTEGER
  pfecha_captura               DATE
  pempresa                     CHAR(3)
) RETURNING CHAR(6)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pusuario` | `CHAR(8)` | — | — |
| `pcontrol_poliza` | `INTEGER` | — | — |
| `pfecha_captura` | `DATE` | — | — |
| `pempresa` | `CHAR(3)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(6)` | L8 |
| `iSqlErr` | `INTEGER` | L9 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `co_poliza` | `bdicont` | no | SELECT | L53 |
| `co_poliza` | `bdicont` | no | DELETE | L53 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L45 | VALIDACIÓN_NULL | `IF pusuario = '' OR pusuario IS NULL OR pcontrol_poliza = '' OR pcontrol_poliza IS NULL` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `?_borraren` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `cp` | ENTIDAD | código postal | 🟡 INFERIDO | nombre_sp |
| `?ol` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_borraren`, `?ol` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_borratemporales`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_sp_borratemporales.sql` |
| **LOC (1er CREATE)** | 11 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "(temporal)" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 4 tabla(s) con operaciones: SELECT, DELETE |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=2 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_borratemporales(
)
```

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tmpco_detpol` | `bdicont` | no | SELECT | L7 |
| `tmpco_detpol` | `bdicont` | no | DELETE | L7 |
| `co_errorpoliza` | `bdicont` | no | SELECT | L9 |
| `co_errorpoliza` | `bdicont` | no | DELETE | L9 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `?_borra` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `temp` | MODIF | temporal | 🔵 CONVENCIÓN | nombre_sp |
| `?orales` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_borra`, `?orales` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_buscatemporal`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_sp_buscatemporal.sql` |
| **LOC (1er CREATE)** | 77 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 1 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "busca (temporal)" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 6 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=1 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_buscatemporal(
  pTabla                       Char(50)
) RETURNING CHAR (5) ,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pTabla` | `Char(50)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cod_ret` | `char(5)` | L24 |
| `iSqlErr` | `integer` | L25 |
| `cCodErr` | `CHAR(5)` | L27 |
| `vDesErr` | `VARCHAR(60)` | L28 |
| `v_registros` | `INTEGER` | L31 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `temp_sc_movhis` | `bdicont` | no | SELECT | L53 |
| `his1` | `bdicont` | no | SELECT | L56 |
| `temp_sconcilia` | `bdicont` | no | SELECT | L59 |
| `tmp_concilia_chq` | `bdicont` | no | SELECT | L63 |
| `tmp_rconciliacentral` | `bdicont` | no | SELECT | L67 |
| `tmp_rconciliasucursal` | `bdicont` | no | SELECT | L71 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `busca` | ACCION | busca / localiza | 🔵 CONVENCIÓN | nombre_sp |
| `temp` | MODIF | temporal | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `?oral` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?oral` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_cam_asigna_rev_firmasb3`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_sp_cam_asigna_rev_firmasb3.sql` |
| **LOC (1er CREATE)** | 124 |
| **Callgraph** | ✅ fan_in=0 / fan_out=30 |
| **Deps concatenadas** | 10 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "asigna firmas mancomunadas (sufijo de versión de SP)" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 5 llamada(s): `sp_catchequesdetalle`, `sp_catchequespendientes`, `sp_catguardasignaciones` |
| **Evidencia vocab** | CÓDIGO=3 · CONVENCIÓN=1 · INFERIDO=2 · SINTÉTICO=0 / 6 términos |

### Firma

```sql
CREATE PROCEDURE sp_cam_asigna_rev_firmasb3(
  pBandera                     CHAR(2)
  pUsuario                     CHAR(8)
  pIdFuncion                   CHAR(10)
  pFecha                       CHAR(8)
  pRegistros                   INTEGER
  pRecuperacion                INTEGER
  pCheques                     CHAR(250)
  pEjecutivo                   CHAR(8)
) RETURNING CHAR(5)         AS codret,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pBandera` | `CHAR(2)` | — | — |
| `pUsuario` | `CHAR(8)` | — | — |
| `pIdFuncion` | `CHAR(10)` | — | — |
| `pFecha` | `CHAR(8)` | — | — |
| `pRegistros` | `INTEGER` | — | — |
| `pRecuperacion` | `INTEGER` | — | — |
| `pCheques` | `CHAR(250)` | — | — |
| `pEjecutivo` | `CHAR(8)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(5)` | L20 |
| `iSqlErr` | `INTEGER` | L21 |
| `cCuenta` | `CHAR(20)` | L22 |
| `iCheque` | `INTEGER` | L23 |
| `dImporte` | `DECIMAL(16,2)` | L24 |
| `cRevisadoFirmas` | `CHAR(2)` | L25 |
| `cUsuarioValida` | `CHAR(8)` | L26 |
| `cMotivoDevolucion` | `CHAR(38)` | L27 |
| `iTotalChequesPendientes` | `INTEGER` | L28 |
| `cNombreArchivo` | `CHAR(22)` | L29 |
| `cSecuencia` | `INTEGER` | L30 |
| `cEjecutivo` | `CHAR(8)` | L31 |
| `cNombreEjecutivo` | `CHAR(45)` | L32 |
| `iTotalCheques` | `INTEGER` | L33 |
| `iTotalChequesPorRevisar` | `INTEGER` | L34 |
| `iTotalChequesRevisados` | `INTEGER` | L35 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_catchequesdetalle` | `bdicnweb` | ⚠️ sí | L75 |
| `sp_catchequespendientes` | `bdicnweb` | ⚠️ sí | L82 |
| `sp_catguardasignaciones` | `bdicnweb` | ⚠️ sí | L88 |
| `sp_catrevisoresfirmas` | `bdicnweb` | ⚠️ sí | L94 |
| `sp_cattotalchequesdetalle` | `bdicnweb` | ⚠️ sí | L100 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L39 | CÓDIGO_RETORNO | `LET cCodRet = '00000';` |  |
| L107 | CÓDIGO_RETORNO | `LET cCodRet = '00017';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `cam` | PREFIJO | cámara / captura contable | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `asigna` | ACCION | asigna | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `rev` | ACCION | reversión (abreviación de reversa/reverso) | 🟡 INFERIDO | nombre_sp |
| `firmas` | ENTIDAD | firmas mancomunadas | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `b3` | MODIF | sufijo de versión de SP (Bloque/Build 3) — patrón Informix:  | 🟡 INFERIDO | nombre_sp |

---

## `sp_cam_cargamanualb3`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_sp_cam_cargamanualb3.sql` |
| **LOC (1er CREATE)** | 199 |
| **Callgraph** | ✅ fan_in=0 / fan_out=50 |
| **Deps concatenadas** | 13 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "carga manual (sufijo de versión de SP)" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 13 llamada(s): `sp_aplicacargaarchcecoban`, `sp_aplicacargaarchimgcecoban`, `sp_catarchivoimportar` |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=2 · INFERIDO=1 · SINTÉTICO=0 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_cam_cargamanualb3(
  pBandera                     CHAR(2)
  pUsuario                     CHAR(8)
  pIdFuncion                   CHAR(10)
  pNombreArchivo               CHAR(22)
  pDireccionMac                CHAR(12)
  pCodOperacion                CHAR(5)
  pFecha                       DATE
  pStatusImgF                  CHAR(1)
  pStatusImgT                  CHAR(1)
  pIdConsulta                  CHAR(1)
  pIdDetalle                   INTEGER
  pIdRegistro                  CHAR(2)
  pRutaArchivo                 CHAR(100)
  pBloqueArchivo               CHAR(117)
  pNroSecuencia                INTEGER
  pTipoProceso                 CHAR(12)
) RETURNING CHAR(5) 	  		AS codret,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pBandera` | `CHAR(2)` | — | — |
| `pUsuario` | `CHAR(8)` | — | — |
| `pIdFuncion` | `CHAR(10)` | — | — |
| `pNombreArchivo` | `CHAR(22)` | — | — |
| `pDireccionMac` | `CHAR(12)` | — | — |
| `pCodOperacion` | `CHAR(5)` | — | — |
| `pFecha` | `DATE` | — | — |
| `pStatusImgF` | `CHAR(1)` | — | — |
| `pStatusImgT` | `CHAR(1)` | — | — |
| `pIdConsulta` | `CHAR(1)` | — | — |
| `pIdDetalle` | `INTEGER` | — | — |
| `pIdRegistro` | `CHAR(2)` | — | — |
| `pRutaArchivo` | `CHAR(100)` | — | — |
| `pBloqueArchivo` | `CHAR(117)` | — | — |
| `pNroSecuencia` | `INTEGER` | — | — |
| `pTipoProceso` | `CHAR(12)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(5)` | L29 |
| `iSqlErr` | `INTEGER` | L30 |
| `cCodOperacion` | `CHAR(5)` | L31 |
| `cDescArchivo` | `CHAR(100)` | L32 |
| `cNombreArchivo` | `CHAR(22)` | L33 |
| `cNumCuenta` | `CHAR(22)` | L34 |
| `iNumCheque` | `INTEGER` | L35 |
| `cMotivoDev` | `CHAR(50)` | L36 |
| `mImporte` | `MONEY(14,2)` | L37 |
| `cStatusCargaImgF` | `CHAR(1)` | L38 |
| `cStatusCargaImgT` | `CHAR(1)` | L39 |
| `iIdDetalle` | `INTEGER` | L40 |
| `iNumRegistros` | `INTEGER` | L41 |
| `cSeccion` | `CHAR(12)` | L42 |
| `cCampo` | `CHAR(2)` | L43 |
| `cDescMensaje` | `CHAR(100)` | L44 |
| `iLinea` | `INTEGER` | L45 |
| `cBanDetError` | `CHAR(1)` | L46 |
| `cMuestraMsn` | `CHAR(1)` | L47 |
| `cStatus` | `CHAR(1)` | L48 |
| `cErrorProceso` | `CHAR(1)` | L49 |
| `cError` | `CHAR(5)` | L50 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_aplicacargaarchcecoban` | `bdicnweb` | ⚠️ sí | L97 |
| `sp_aplicacargaarchimgcecoban` | `bdicnweb` | ⚠️ sí | L103 |
| `sp_catarchivoimportar` | `bdicnweb` | ⚠️ sí | L110 |
| `sp_consdetallearchcecoban` | `bdicnweb` | ⚠️ sí | L118 |
| `sp_consdetallearchimgcecoban` | `bdicnweb` | ⚠️ sí | L126 |
| `sp_consdetallearchimgcecoban_totales` | `bdicnweb` | ⚠️ sí | L132 |
| `sp_conserroresarchcecoban` | `bdicnweb` | ⚠️ sí | L139 |
| `sp_conserroresarchcecoban_totales` | `bdicnweb` | ⚠️ sí | L146 |
| `sp_consultaimgnula` | `bdicnweb` | ⚠️ sí | L153 |
| `sp_lecturarchivodatosimportar` | `bdicnweb` | ⚠️ sí | L160 |
| `sp_recibedatosarchivoimagenes` | `bdicnweb` | ⚠️ sí | L166 |
| `sp_validarchivoimportar` | `bdicnweb` | ⚠️ sí | L172 |
| `sp_verificastatusarchivo` | `bdicnweb` | ⚠️ sí | L178 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L53 | CÓDIGO_RETORNO | `LET cCodRet = '00000';` |  |
| L88 | CÓDIGO_RETORNO | `LET cCodRet = '00003';` |  |
| L185 | CÓDIGO_RETORNO | `LET cCodRet = '00017';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `cam` | PREFIJO | cámara / captura contable | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `cargamanual` | ACCION | carga manual | 🔵 CONVENCIÓN | nombre_sp |
| `b3` | MODIF | sufijo de versión de SP (Bloque/Build 3) — patrón Informix:  | 🟡 INFERIDO | nombre_sp |

---

## `sp_cam_conctlprocb3`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_sp_cam_conctlprocb3.sql` |
| **LOC (1er CREATE)** | 110 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 1 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "consulta proceso (sufijo de versión de SP)" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 4 llamada(s): `sp_consdetalleaplicacioncargoscta`, `sp_consdetallechequesprocnocturno`, `sp_consdetallechequesprocnocturno_totales` |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=1 · INFERIDO=4 · SINTÉTICO=1 / 6 términos |

### Firma

```sql
CREATE PROCEDURE sp_cam_conctlprocb3(
  pBandera                     CHAR(2)
  pUsuario                     CHAR(8)
  pIdFuncion                   CHAR(10)
  pIdConsulta                  CHAR(1)
  pFecha                       DATE
  pRegistros                   INTEGER
  pRecuperacion                INTEGER
) RETURNING CHAR(5)     AS codret,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pBandera` | `CHAR(2)` | — | — |
| `pUsuario` | `CHAR(8)` | — | — |
| `pIdFuncion` | `CHAR(10)` | — | — |
| `pIdConsulta` | `CHAR(1)` | `con`=consulta | 🟡 INFERIDO |
| `pFecha` | `DATE` | — | — |
| `pRegistros` | `INTEGER` | — | — |
| `pRecuperacion` | `INTEGER` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(5)` | L19 |
| `iSqlErr` | `INTEGER` | L20 |
| `cProceso` | `CHAR(20)` | L21 |
| `cStatus` | `CHAR(10)` | L22 |
| `cEjecutivo` | `CHAR(8)` | L23 |
| `dHoraIni` | `DATETIME HOUR TO SECOND` | L24 |
| `dHoraFin` | `DATETIME HOUR TO SECOND` | L25 |
| `cCodretSp` | `CHAR(5)` | L26 |
| `cCuenta` | `CHAR(20)` | L27 |
| `iCheque` | `INTEGER` | L28 |
| `iNumRegistros` | `INTEGER` | L29 |
| `dFechaHoy` | `DATE` | L30 |
| `dFechaAnt` | `DATE` | L31 |
| `dProxFecha` | `DATE` | L32 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_consdetalleaplicacioncargoscta` | `bdicnweb` | ⚠️ sí | L70 |
| `sp_consdetallechequesprocnocturno` | `bdicnweb` | ⚠️ sí | L75 |
| `sp_consdetallechequesprocnocturno_totales` | `bdicnweb` | ⚠️ sí | L82 |
| `sp_consgeneralfechas` | `bdicnweb` | ⚠️ sí | L86 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L37 | CÓDIGO_RETORNO | `LET cCodRet     = '00000';` |  |
| L59 | CÓDIGO_RETORNO | `LET cCodRet = '00003';` |  |
| L91 | CÓDIGO_RETORNO | `LET cCodRet = '00017';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `cam` | PREFIJO | cámara / captura contable | 🟡 INFERIDO | nombre_sp |
| `con` | ACCION | consulta | 🟡 INFERIDO | nombre_sp |
| `?ctl` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `proc` | ENTIDAD | proceso | 🟡 INFERIDO | nombre_sp |
| `b3` | MODIF | sufijo de versión de SP (Bloque/Build 3) — patrón Informix:  | 🟡 INFERIDO | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?ctl` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_cam_datosdia`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_sp_cam_datosdia.sql` |
| **LOC (1er CREATE)** | 85 |
| **Callgraph** | ✅ fan_in=0 / fan_out=11 |
| **Deps concatenadas** | 6 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "datos del día" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 3 llamada(s): `sp_datosdiahoy_cod47_2`, `sp_ope_catalogomotivos2`, `sp_consultaparametrosgenerales2` |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=2 · INFERIDO=1 · SINTÉTICO=0 / 3 términos |

### Firma

```sql
CREATE PROCEDURE sp_cam_datosdia(
  pBandera                     CHAR(1)
  pUsuario                     CHAR(8)
  pIdFuncion                   CHAR(10)
  pWhere                       CHAR(15)
  pIdParametro                 CHAR(15)
) RETURNING CHAR(5)   AS codret,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pBandera` | `CHAR(1)` | — | — |
| `pUsuario` | `CHAR(8)` | — | — |
| `pIdFuncion` | `CHAR(10)` | — | — |
| `pWhere` | `CHAR(15)` | — | — |
| `pIdParametro` | `CHAR(15)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(5)` | L12 |
| `iSqlErr` | `INTEGER` | L13 |
| `dFecha` | `DATE` | L14 |
| `cNoBanco` | `CHAR(3)` | L15 |
| `cProcesado` | `CHAR(1)` | L16 |
| `dFechaHabilAnt` | `DATE` | L17 |
| `cCodigo` | `CHAR(2)` | L18 |
| `cDescripcion` | `CHAR(35)` | L19 |
| `cValor` | `CHAR(100)` | L20 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_datosdiahoy_cod47_2` | `bdicont` | no | L52 |
| `sp_ope_catalogomotivos2` | `bdicont` | no | L58 |
| `sp_consultaparametrosgenerales2` | `bdicont` | no | L64 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L23 | CÓDIGO_RETORNO | `LET cCodRet = '00000';` |  |
| L47 | CÓDIGO_RETORNO | `LET cCodRet = '00003';` |  |
| L70 | CÓDIGO_RETORNO | `LET cCodRet = '00017';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `cam` | PREFIJO | cámara / captura contable | 🟡 INFERIDO | nombre_sp |
| `datosdia` | ENTIDAD | datos del día | 🔵 CONVENCIÓN | nombre_sp |

---

## `sp_cam_devforzadab3`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_sp_cam_devforzadab3.sql` |
| **LOC (1er CREATE)** | 137 |
| **Callgraph** | ✅ fan_in=0 / fan_out=15 |
| **Deps concatenadas** | 7 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "devolución forzada (sufijo de versión de SP)" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 5 llamada(s): `sp_aplicadevolucioncheque`, `sp_consdetallechequespagados`, `sp_consdetallechequespagados_totales` |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=2 · INFERIDO=1 · SINTÉTICO=0 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_cam_devforzadab3(
  pBandera                     CHAR(2)
  pUsuario                     CHAR(8)
  pIdFuncion                   CHAR(10)
  pMotivoDev                   CHAR(2)
  pFecha                       CHAR(8)
  pIdConsCheque                INTEGER
  pIdConsulta                  CHAR(1)
  pNumero                      CHAR(20)
  pRegistros                   INTEGER
  pRecuperacion                INTEGER
) RETURNING CHAR(5)     AS codret,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pBandera` | `CHAR(2)` | — | — |
| `pUsuario` | `CHAR(8)` | — | — |
| `pIdFuncion` | `CHAR(10)` | — | — |
| `pMotivoDev` | `CHAR(2)` | — | — |
| `pFecha` | `CHAR(8)` | — | — |
| `pIdConsCheque` | `INTEGER` | — | — |
| `pIdConsulta` | `CHAR(1)` | — | — |
| `pNumero` | `CHAR(20)` | — | — |
| `pRegistros` | `INTEGER` | — | — |
| `pRecuperacion` | `INTEGER` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(5)` | L26 |
| `iSqlErr` | `INTEGER` | L27 |
| `cNumCte` | `CHAR(20)` | L29 |
| `cNombreCte` | `CHAR(107)` | L30 |
| `cRfc` | `CHAR(13)` | L31 |
| `dFechaNac` | `DATE` | L32 |
| `cBanco` | `CHAR(44)` | L33 |
| `cNoCuenta` | `CHAR(20)` | L34 |
| `iNoCheque` | `INTEGER` | L35 |
| `mImporte` | `MONEY(16,2)` | L36 |
| `cTruncado` | `CHAR(2)` | L37 |
| `cEstatus` | `CHAR(19)` | L38 |
| `cCausaDev` | `CHAR(38)` | L39 |
| `cImporte2` | `CHAR(18)` | L40 |
| `iSecuencia` | `INTEGER` | L41 |
| `cNombreArchivo` | `CHAR(22)` | L42 |
| `iIdConsCheque` | `INTEGER` | L43 |
| `iNumRegistros` | `INTEGER` | L44 |
| `dFechaHoy` | `DATE` | L45 |
| `dFechaAnt` | `DATE` | L46 |
| `dProxFecha` | `DATE` | L47 |
| `cCodigo` | `CHAR(2)` | L48 |
| `cDescripcion` | `CHAR(35)` | L49 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_aplicadevolucioncheque` | `bdicnweb` | ⚠️ sí | L95 |
| `sp_consdetallechequespagados` | `bdicnweb` | ⚠️ sí | L101 |
| `sp_consdetallechequespagados_totales` | `bdicnweb` | ⚠️ sí | L107 |
| `sp_consgeneralfechas` | `bdicnweb` | ⚠️ sí | L112 |
| `sp_ope_catalogomotivos` | `bdicnweb` | ⚠️ sí | L118 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L52 | CÓDIGO_RETORNO | `LET cCodRet = '00000';` |  |
| L84 | CÓDIGO_RETORNO | `LET cCodRet = '00003';` |  |
| L125 | CÓDIGO_RETORNO | `LET cCodRet = '00017';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `cam` | PREFIJO | cámara / captura contable | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `devforzada` | ACCION | devolución forzada | 🔵 CONVENCIÓN | nombre_sp |
| `b3` | MODIF | sufijo de versión de SP (Bloque/Build 3) — patrón Informix:  | 🟡 INFERIDO | nombre_sp |

---

## `sp_cam_firmas_visual_chequesb3`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_sp_cam_firmas_visual_chequesb3.sql` |
| **LOC (1er CREATE)** | 172 |
| **Callgraph** | ✅ fan_in=0 / fan_out=21 |
| **Deps concatenadas** | 8 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "firmas mancomunadas y cheques (visual, sufijo de versión de SP)" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 7 llamada(s): `sp_actualizadatoscheque`, `sp_aplicabonocuenta`, `sp_consgeneralfechas` |
| **Evidencia vocab** | CÓDIGO=5 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=0 / 6 términos |

### Firma

```sql
CREATE PROCEDURE sp_cam_firmas_visual_chequesb3(
  pBandera                     CHAR(2)
  pUsuario                     CHAR(8)
  pIdFuncion                   CHAR(10)
  pFecha                       CHAR(8)
  pMotivoDev                   CHAR(2)
  pIdConsCheque                INTEGER
  pIdEjecucion                 CHAR(1)
  pTramaConsecutivo            CHAR(250)
  pRegistros                   INTEGER
  pRecuperacion                INTEGER
) RETURNING CHAR(5)     AS codret,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pBandera` | `CHAR(2)` | — | — |
| `pUsuario` | `CHAR(8)` | — | — |
| `pIdFuncion` | `CHAR(10)` | — | — |
| `pFecha` | `CHAR(8)` | — | — |
| `pMotivoDev` | `CHAR(2)` | — | — |
| `pIdConsCheque` | `INTEGER` | — | — |
| `pIdEjecucion` | `CHAR(1)` | — | — |
| `pTramaConsecutivo` | `CHAR(250)` | — | — |
| `pRegistros` | `INTEGER` | — | — |
| `pRecuperacion` | `INTEGER` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(5)` | L30 |
| `iSqlErr` | `INTEGER` | L31 |
| `dFechaHoy` | `DATE` | L32 |
| `dFechaAnt` | `DATE` | L33 |
| `dProxFecha` | `DATE` | L34 |
| `cCuenta` | `CHAR(20)` | L35 |
| `iCheque` | `INTEGER` | L36 |
| `mImporte` | `MONEY(16,2)` | L37 |
| `cSucursal` | `CHAR(45)` | L38 |
| `cNumCte` | `CHAR(20)` | L39 |
| `cCliente` | `CHAR(125)` | L40 |
| `cMotivoDevol` | `CHAR(38)` | L41 |
| `cFirmas` | `CHAR(32)` | L42 |
| `cHayFirmas` | `CHAR(1)` | L43 |
| `iIdConsCheque` | `INTEGER` | L44 |
| `iContImagenes` | `INTEGER` | L45 |
| `iNumRegistros` | `INTEGER` | L46 |
| `cRegFirmas` | `CHAR(1)` | L47 |
| `cCombFirmantes` | `CHAR(120)` | L48 |
| `cCveBanco` | `CHAR(3)` | L49 |
| `dFechaPresenta` | `DATE` | L50 |
| `cCodDocumento` | `CHAR(4)` | L51 |
| `cSecuencia` | `SMALLINT` | L52 |
| `iRecuperacion` | `INTEGER` | L53 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_actualizadatoscheque` | `bdicnweb` | ⚠️ sí | L101 |
| `sp_aplicabonocuenta` | `bdicnweb` | ⚠️ sí | L108 |
| `sp_consgeneralfechas` | `bdicnweb` | ⚠️ sí | L115 |
| `sp_statusdescarga` | `bdicnweb` | ⚠️ sí | L122 |
| `sp_validadetallerevcheques` | `bdicnweb` | ⚠️ sí | L130 |
| `sp_validadetallerevcheques_totales` | `bdicnweb` | ⚠️ sí | L138 |
| `sp_validaimagenchequesfirmas` | `bdicnweb` | ⚠️ sí | L146 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L57 | CÓDIGO_RETORNO | `LET cCodRet = '00000';` |  |
| L94 | CÓDIGO_RETORNO | `LET cCodRet = '00003';` |  |
| L155 | CÓDIGO_RETORNO | `LET cCodRet = '00017';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `cam` | PREFIJO | cámara / captura contable | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `firmas` | ENTIDAD | firmas mancomunadas | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `visual` | MODIF | visual | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `cheques` | ENTIDAD | cheques | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `b3` | MODIF | sufijo de versión de SP (Bloque/Build 3) — patrón Informix:  | ✅ CÓDIGO | nombre_sp, texto_cuerpo |

---

## `sp_cam_monitorarchivosb3`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_sp_cam_monitorarchivosb3.sql` |
| **LOC (1er CREATE)** | 152 |
| **Callgraph** | ✅ fan_in=0 / fan_out=37 |
| **Deps concatenadas** | 12 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "monitor y archivos (sufijo de versión de SP)" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 5 llamada(s): `sp_consarchrecibidos`, `sp_consarchrecibidos_totales`, `sp_consultadetallearchivo` |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=1 · INFERIDO=2 · SINTÉTICO=0 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_cam_monitorarchivosb3(
  pBandera                     CHAR(2)
  pUsuario                     CHAR(10)
  pIdFuncion                   CHAR(10)
  pFechaConsulta               DATE
  pRegistros                   INTEGER
  pRecuperacion                INTEGER
  pNombreArchivo               CHAR(22)
  pTipo                        CHAR(3)
  pStatus                      CHAR(16)
) RETURNING CHAR(5)     AS codret,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pBandera` | `CHAR(2)` | — | — |
| `pUsuario` | `CHAR(10)` | — | — |
| `pIdFuncion` | `CHAR(10)` | — | — |
| `pFechaConsulta` | `DATE` | — | — |
| `pRegistros` | `INTEGER` | — | — |
| `pRecuperacion` | `INTEGER` | — | — |
| `pNombreArchivo` | `CHAR(22)` | — | — |
| `pTipo` | `CHAR(3)` | — | — |
| `pStatus` | `CHAR(16)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(5)` | L30 |
| `iSqlErr` | `INTEGER` | L31 |
| `cNombreArch` | `CHAR(22)` | L33 |
| `cCodOperacion` | `CHAR(3)` | L34 |
| `cHoraEntrada` | `CHAR(25)` | L35 |
| `cLectura` | `CHAR(10)` | L36 |
| `iTotalRegistros` | `INTEGER` | L37 |
| `cComentario` | `CHAR(100)` | L38 |
| `cFechaAplic` | `CHAR(10)` | L39 |
| `cHoraAplic` | `CHAR(25)` | L40 |
| `cCveStatus` | `CHAR(2)` | L41 |
| `cProcesado` | `CHAR(1)` | L42 |
| `cCuenta` | `CHAR(20)` | L43 |
| `iNumCheque` | `INTEGER` | L44 |
| `mImporte` | `MONEY(16,2)` | L45 |
| `cImgStat1` | `CHAR(1)` | L46 |
| `cImgStat2` | `CHAR(1)` | L47 |
| `cCodigoRet` | `CHAR(5)` | L48 |
| `dFechaProceso` | `DATE` | L49 |
| `cMotivoDev` | `CHAR(2)` | L50 |
| `cDescMotivoDev` | `CHAR(35)` | L51 |
| `iNumOperaciones` | `INTEGER` | L52 |
| `iTotalImgRec` | `INTEGER` | L53 |
| `iTotalImgFalt` | `INTEGER` | L54 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_consarchrecibidos` | `bdicnweb` | ⚠️ sí | L109 |
| `sp_consarchrecibidos_totales` | `bdicnweb` | ⚠️ sí | L115 |
| `sp_consultadetallearchivo` | `bdicnweb` | ⚠️ sí | L122 |
| `sp_consultadetallearchivo_totales` | `bdicnweb` | ⚠️ sí | L128 |
| `sp_consdetallesumarioarch` | `bdicnweb` | ⚠️ sí | L135 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L62 | CÓDIGO_RETORNO | `LET cCodRet = '00000';` |  |
| L102 | CÓDIGO_RETORNO | `LET cCodRet = '00003';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `cam` | PREFIJO | cámara / captura contable | 🟡 INFERIDO | nombre_sp |
| `monitor` | ENTIDAD | monitor | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `archivos` | ENTIDAD | archivos | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `b3` | MODIF | sufijo de versión de SP (Bloque/Build 3) — patrón Informix:  | 🟡 INFERIDO | nombre_sp |

---

## `sp_cam_pro_ctasb3`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_sp_cam_pro_ctasb3.sql` |
| **LOC (1er CREATE)** | 79 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 2 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "cuentas (sufijo de versión de SP)" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 3 llamada(s): `sp_consgeneralfechas`, `sp_procesacargoscuenta`, `sp_verificastatuscargocta` |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=2 · INFERIDO=2 · SINTÉTICO=1 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_cam_pro_ctasb3(
  pBandera                     CHAR(2)
  pUsuario                     CHAR(8)
  pIdFuncion                   CHAR(10)
  pIdConsulta                  CHAR(1)
  pFecha                       DATE
) RETURNING CHAR(5)   AS codret,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pBandera` | `CHAR(2)` | — | — |
| `pUsuario` | `CHAR(8)` | — | — |
| `pIdFuncion` | `CHAR(10)` | — | — |
| `pIdConsulta` | `CHAR(1)` | — | — |
| `pFecha` | `DATE` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(5)` | L12 |
| `iSqlErr` | `INTEGER` | L13 |
| `dFechaHoy` | `DATE` | L14 |
| `dFechaAnt` | `DATE` | L15 |
| `dProxFecha` | `DATE` | L16 |
| `iTotalRegistros` | `INTEGER` | L17 |
| `cStatus` | `CHAR(1)` | L18 |
| `cErrorProceso` | `CHAR(1)` | L19 |
| `cError` | `CHAR(5)` | L20 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_consgeneralfechas` | `bdicnweb` | ⚠️ sí | L51 |
| `sp_procesacargoscuenta` | `bdicnweb` | ⚠️ sí | L55 |
| `sp_verificastatuscargocta` | `bdicnweb` | ⚠️ sí | L59 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L23 | CÓDIGO_RETORNO | `LET cCodRet                     = '00000';` |  |
| L40 | CÓDIGO_RETORNO | `LET cCodRet = '00003';` |  |
| L65 | CÓDIGO_RETORNO | `LET cCodRet = '00017';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `cam` | PREFIJO | cámara / captura contable | 🟡 INFERIDO | nombre_sp |
| `?_pro_` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `ctas` | ENTIDAD | cuentas | 🔵 CONVENCIÓN | nombre_sp |
| `b3` | MODIF | sufijo de versión de SP (Bloque/Build 3) — patrón Informix:  | 🟡 INFERIDO | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_pro_` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_co_erro_integra`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_sp_co_erro_integra.sql` |
| **LOC (1er CREATE)** | 30 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "interés" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 1 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=1 · INFERIDO=1 · SINTÉTICO=2 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_co_erro_integra(
  p_usuario                    CHAR(8)
  p_fecha_captura              DATE
) RETURNING INTEGER, INTEGER , CHAR(10) ,CHAR(10) ,CHAR(10), CHAR(10), CHAR(10), CHAR(10) ,CHAR(12) ,CHAR(3)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_usuario` | `CHAR(8)` | — | — |
| `p_fecha_captura` | `DATE` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vcontrol_poliza` | `INTEGER` | L4 |
| `vsecuencia` | `INTEGER` | L5 |
| `vccmayor` | `CHAR(10)` | L6 |
| `vccsub` | `CHAR(10)` | L7 |
| `vccsubsub` | `CHAR(10)` | L8 |
| `vccssubsub` | `CHAR(10)` | L9 |
| `vccsssubsub` | `CHAR(10)` | L10 |
| `vsector` | `CHAR(10)` | L11 |
| `vauxiliar` | `CHAR(12)` | L12 |
| `vcod_ret` | `CHAR(3)` | L13 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `co_auditerr` | `bdicont` | no | SELECT | L22 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `?_co_erro_` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `int` | ENTIDAD | interés | 🟡 INFERIDO | nombre_sp |
| `?egra` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_co_erro_`, `?egra` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_co_importa`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_sp_co_importa.sql` |
| **LOC (1er CREATE)** | 1190 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "Impago — pago vencido o fallido; confirmado: n_impagos_consec" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `confirma` → `SELECT` encontrado en el cuerpo · `confirma` → `UPDATE` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=2 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_co_importa(
  p_empresa                    CHAR(3)
  p_usuario                    CHAR(8)
  p_fecha_captura              DATE
) RETURNING CHAR(5), INTEGER, VARCHAR(255)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_empresa` | `CHAR(3)` | — | — |
| `p_usuario` | `CHAR(8)` | — | — |
| `p_fecha_captura` | `DATE` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cVarDataErr` | `VARCHAR(64)` | L5 |
| `iSqlErr` | `INTEGER` | L6 |
| `iSamErr` | `INTEGER` | L7 |
| `cod_ret` | `CHAR(5)` | L8 |
| `v_mensaje` | `VARCHAR(255)` | L9 |
| `v_contador` | `INTEGER` | L11 |
| `v_cuenta_auxiliar` | `INTEGER` | L12 |
| `v_cuenta_divisa` | `INTEGER` | L13 |
| `v_empresa` | `CHAR(3)` | L14 |
| `v_ccosto_orig` | `CHAR(4)` | L15 |
| `v_usuario` | `CHAR(8)` | L16 |
| `v_fecha_captura` | `DATE` | L17 |
| `v_cuenta` | `CHAR(4)` | L18 |
| `v_subcta` | `CHAR(2)` | L19 |
| `v_subsubcta` | `CHAR(2)` | L20 |
| `v_ssubsubcta` | `CHAR(2)` | L21 |
| `v_sssubsubcta` | `CHAR(2)` | L22 |
| `v_sector` | `CHAR(2)` | L23 |
| `v_regional` | `CHAR(3)` | L24 |
| `v_sucursal` | `CHAR(4)` | L25 |
| `v_nro_auxiliar` | `CHAR(12)` | L26 |
| `v_fecha` | `DATE` | L27 |
| `v_moneda` | `CHAR(2)` | L28 |
| `v_naturaleza` | `CHAR(1)` | L29 |
| `v_importe` | `MONEY(18,2)` | L30 |
| *…43 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `co_param` | `bdicont` | no | SELECT | L187 |
| `co_auditerr` | `bdicont` | no | SELECT | L196 |
| `co_integracion` | `bdicont` | no | SELECT | L202 |
| `co_auditerr` | `bdicont` | no | INSERT | L208 |
| `si_ejecut` | `bdinteg` | ⚠️ sí | SELECT | L262 |
| `si_usuarios` | `bdinteg` | ⚠️ sí | SELECT | L269 |
| `si_feriado` | `bdinteg` | ⚠️ sí | SELECT | L318 |
| `si_sucursales` | `bdinteg` | ⚠️ sí | SELECT | L385 |
| `si_catalog` | `bdinteg` | ⚠️ sí | SELECT | L412 |
| `co_auxiliar` | `bdicont` | no | SELECT | L520 |
| `co_cta_ccorig` | `bdicont` | no | SELECT | L648 |
| `co_cta_ccdest` | `bdicont` | no | SELECT | L695 |
| `co_ctrlpoliza` | `bdicont` | no | SELECT | L909 |
| `co_ctrlpoliza` | `bdicont` | no | UPDATE | L917 |
| `co_clv_retroact` | `bdicont` | no | SELECT | L922 |
| `co_detpol` | `bdicont` | no | INSERT | L1024 |
| `co_poliza` | `bdicont` | no | INSERT | L1134 |
| `co_detpol` | `bdicont` | no | SELECT | L1146 |
| `co_detpol` | `bdicont` | no | DELETE | L1146 |
| `co_integracion` | `bdicont` | no | DELETE | L1181 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `nivelacion_ccostos` | `bdicont` | no | L1176 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L205 | VALIDACIÓN_NULL | `IF v_contador IS NULL OR  v_contador=0 THEN` |  |
| L236 | VALIDACIÓN_NULL | `IF w_SUMa_abonos IS NULL THEN` |  |
| L246 | VALIDACIÓN_NULL | `IF w_SUMa_cargos IS NULL THEN` |  |
| L362 | FÓRMULA | `LET i = i + 1;` |  |
| L364 | VALIDACIÓN_NULL | `IF v_sucursal IS NULL or TRIM(v_sucursal) = '' THEN` |  |
| L593 | FÓRMULA | `LET v_contaerror = v_contaerror +1;` |  |
| L612 | FÓRMULA | `LET v_contaerror = v_contaerror +1;` |  |
| L911 | VALIDACIÓN_NULL | `IF v_control_poliza IS NULL  OR  v_control_poliza = 0  THEN` |  |
| L915 | FÓRMULA | `LET v_control_poliza = v_control_poliza + 1;` |  |
| L978 | FÓRMULA | `LET v_fecha_habil=v_fecha_habil - 1;` |  |
| L990 | FÓRMULA | `LET v_dias_valor=v_dias_valor + 1;` |  |
| L1022 | FÓRMULA | `LET w_cap_cargo_mn = w_cap_cargo_mn + debito1;` |  |
| L1044 | FÓRMULA | `LET i=i + 1;` |  |
| L1047 | FÓRMULA | `LET v_cap_cargo_dls=v_cap_cargo_dls+debito1;` |  |
| L1068 | FÓRMULA | `LET i=i + 1;` |  |
| L1077 | FÓRMULA | `LET v_cIFra_mn=v_cIFra_mn+credito1;` |  |
| L1078 | FÓRMULA | `LET v_cap_abono_mn = v_cap_abono_mn + credito1;` |  |
| L1100 | FÓRMULA | `LET i=i + 1;` |  |
| L1103 | FÓRMULA | `LET v_cIFra_dls=v_cIFra_dls+credito1;` |  |
| L1104 | FÓRMULA | `LET v_cap_abono_dls=v_cap_abono_dls + credito1;` |  |
| L1125 | FÓRMULA | `LET i=i + 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `?_co_` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `imp` | ENTIDAD | Impago — pago vencido o fallido; confirmado: n_impagos_conse | 🔵 CONVENCIÓN | nombre_sp |
| `?orta` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_co_`, `?orta` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_co_importa_pba`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_sp_co_importa_pba.sql` |
| **LOC (1er CREATE)** | 1187 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "Impago — pago vencido o fallido; confirmado: n_impagos_consec (PBA — sufijo de SPs para Pruebas; confirmado por SME)" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `confirma` → `SELECT` encontrado en el cuerpo · `confirma` → `UPDATE` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=2 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_co_importa_pba(
  p_empresa                    CHAR(3)
  p_usuario                    CHAR(8)
  p_fecha_captura              DATE
) RETURNING CHAR(5), INTEGER, VARCHAR(255)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_empresa` | `CHAR(3)` | — | — |
| `p_usuario` | `CHAR(8)` | — | — |
| `p_fecha_captura` | `DATE` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cVarDataErr` | `VARCHAR(64)` | L5 |
| `iSqlErr` | `INTEGER` | L6 |
| `iSamErr` | `INTEGER` | L7 |
| `cod_ret` | `CHAR(5)` | L8 |
| `v_mensaje` | `VARCHAR(255)` | L9 |
| `v_contador` | `INTEGER` | L11 |
| `v_cuenta_auxiliar` | `INTEGER` | L12 |
| `v_cuenta_divisa` | `INTEGER` | L13 |
| `v_empresa` | `CHAR(3)` | L14 |
| `v_ccosto_orig` | `CHAR(4)` | L15 |
| `v_usuario` | `CHAR(8)` | L16 |
| `v_fecha_captura` | `DATE` | L17 |
| `v_cuenta` | `CHAR(4)` | L18 |
| `v_subcta` | `CHAR(2)` | L19 |
| `v_subsubcta` | `CHAR(2)` | L20 |
| `v_ssubsubcta` | `CHAR(2)` | L21 |
| `v_sssubsubcta` | `CHAR(2)` | L22 |
| `v_sector` | `CHAR(2)` | L23 |
| `v_regional` | `CHAR(3)` | L24 |
| `v_sucursal` | `CHAR(4)` | L25 |
| `v_nro_auxiliar` | `CHAR(12)` | L26 |
| `v_fecha` | `DATE` | L27 |
| `v_moneda` | `CHAR(2)` | L28 |
| `v_naturaleza` | `CHAR(1)` | L29 |
| `v_importe` | `MONEY(18,2)` | L30 |
| *…43 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `co_param` | `bdicont` | no | SELECT | L184 |
| `co_auditerr` | `bdicont` | no | SELECT | L193 |
| `co_integracion` | `bdicont` | no | SELECT | L199 |
| `co_auditerr` | `bdicont` | no | INSERT | L205 |
| `si_ejecut` | `bdinteg` | ⚠️ sí | SELECT | L259 |
| `si_usuarios` | `bdinteg` | ⚠️ sí | SELECT | L266 |
| `si_feriado` | `bdinteg` | ⚠️ sí | SELECT | L315 |
| `si_sucursales` | `bdinteg` | ⚠️ sí | SELECT | L382 |
| `si_catalog` | `bdinteg` | ⚠️ sí | SELECT | L409 |
| `co_auxiliar` | `bdicont` | no | SELECT | L517 |
| `co_cta_ccorig` | `bdicont` | no | SELECT | L645 |
| `co_cta_ccdest` | `bdicont` | no | SELECT | L692 |
| `co_ctrlpoliza` | `bdicont` | no | SELECT | L906 |
| `co_ctrlpoliza` | `bdicont` | no | UPDATE | L914 |
| `co_clv_retroact` | `bdicont` | no | SELECT | L919 |
| `co_detpol` | `bdicont` | no | INSERT | L1021 |
| `co_poliza` | `bdicont` | no | INSERT | L1131 |
| `co_detpol` | `bdicont` | no | SELECT | L1143 |
| `co_detpol` | `bdicont` | no | DELETE | L1143 |
| `co_integracion` | `bdicont` | no | DELETE | L1178 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `nivelacion_ccostos` | `bdicont` | no | L1173 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L202 | VALIDACIÓN_NULL | `IF v_contador IS NULL OR  v_contador=0 THEN` |  |
| L233 | VALIDACIÓN_NULL | `IF w_SUMa_abonos IS NULL THEN` |  |
| L243 | VALIDACIÓN_NULL | `IF w_SUMa_cargos IS NULL THEN` |  |
| L359 | FÓRMULA | `LET i = i + 1;` |  |
| L361 | VALIDACIÓN_NULL | `IF v_sucursal IS NULL or TRIM(v_sucursal) = '' THEN` |  |
| L590 | FÓRMULA | `LET v_contaerror = v_contaerror +1;` |  |
| L609 | FÓRMULA | `LET v_contaerror = v_contaerror +1;` |  |
| L908 | VALIDACIÓN_NULL | `IF v_control_poliza IS NULL  OR  v_control_poliza = 0  THEN` |  |
| L912 | FÓRMULA | `LET v_control_poliza = v_control_poliza + 1;` |  |
| L975 | FÓRMULA | `LET v_fecha_habil=v_fecha_habil - 1;` |  |
| L987 | FÓRMULA | `LET v_dias_valor=v_dias_valor + 1;` |  |
| L1019 | FÓRMULA | `LET w_cap_cargo_mn = w_cap_cargo_mn + debito1;` |  |
| L1041 | FÓRMULA | `LET i=i + 1;` |  |
| L1044 | FÓRMULA | `LET v_cap_cargo_dls=v_cap_cargo_dls+debito1;` |  |
| L1065 | FÓRMULA | `LET i=i + 1;` |  |
| L1074 | FÓRMULA | `LET v_cIFra_mn=v_cIFra_mn+credito1;` |  |
| L1075 | FÓRMULA | `LET v_cap_abono_mn = v_cap_abono_mn + credito1;` |  |
| L1097 | FÓRMULA | `LET i=i + 1;` |  |
| L1100 | FÓRMULA | `LET v_cIFra_dls=v_cIFra_dls+credito1;` |  |
| L1101 | FÓRMULA | `LET v_cap_abono_dls=v_cap_abono_dls + credito1;` |  |
| L1122 | FÓRMULA | `LET i=i + 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `?_co_` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `imp` | ENTIDAD | Impago — pago vencido o fallido; confirmado: n_impagos_conse | 🔵 CONVENCIÓN | nombre_sp |
| `?orta_` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `pba` | MODIF | PBA — sufijo de SPs para Pruebas; confirmado por SME (Guerra | 🔵 CONVENCIÓN | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_co_`, `?orta_` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_co_ins_ctas_nom`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_sp_co_ins_ctas_nom.sql` |
| **LOC (1er CREATE)** | 28 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "insertar cuentas y nómina" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `inserta` → `INSERT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=1 · INFERIDO=2 · SINTÉTICO=1 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_co_ins_ctas_nom(
  p_ccmayor                    CHAR(4)
  p_ccsub                      CHAR(2)
  p_ccsubsub                   CHAR(2)
  p_ccssubsub                  CHAR(2)
  p_ccsssubsub                 CHAR(2)
  p_sector                     CHAR(2)
  p_descripcion                CHAR(60)
) RETURNING CHAR(6), VARCHAR(255)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_ccmayor` | `CHAR(4)` | — | — |
| `p_ccsub` | `CHAR(2)` | — | — |
| `p_ccsubsub` | `CHAR(2)` | — | — |
| `p_ccssubsub` | `CHAR(2)` | — | — |
| `p_ccsssubsub` | `CHAR(2)` | — | — |
| `p_sector` | `CHAR(2)` | — | — |
| `p_descripcion` | `CHAR(60)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cVarDataErr` | `VARCHAR(64)` | L4 |
| `iSqlErr` | `INTEGER` | L5 |
| `iSamErr` | `INTEGER` | L6 |
| `cod_ret` | `CHAR(5)` | L7 |
| `v_mensaje` | `VARCHAR(255)` | L8 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `co_ctas_internom` | `bdicont` | no | INSERT | L22 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `?_co_` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `ins` | ACCION | insertar | 🟡 INFERIDO | nombre_sp |
| `ctas` | ENTIDAD | cuentas | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `nom` | ENTIDAD | nómina | 🟡 INFERIDO | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_co_` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_co_integracion`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_sp_co_integracion.sql` |
| **LOC (1er CREATE)** | 76 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "interés" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 2 tabla(s) con operaciones: INSERT |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=2 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_co_integracion(
  p_empresa                    CHAR(3)
  p_costo_orig                 CHAR(4)
  p_usuario                    CHAR(8)
  p_fecha_captura              DATE
  p_cuenta                     CHAR(4)
  p_subcta                     CHAR(2)
  p_subsubcta                  CHAR(2)
  p_ssubsubcta                 CHAR(2)
  p_sssubsubcta                CHAR(2)
  p_sector                     CHAR(2)
  p_regional                   CHAR(3)
  p_costo_dest                 CHAR(4)
  p_nro_auxiliar               CHAR(12)
  p_fecha_valida               DATE
  p_moneda                     CHAR(2)
  p_naturaleza                 CHAR(1)
  p_monto                      MONEY(18,2)
  p_descripcion                CHAR(80)
  p_usuario_int                CHAR(8)
) RETURNING CHAR(5), VARCHAR(255)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_empresa` | `CHAR(3)` | — | — |
| `p_costo_orig` | `CHAR(4)` | — | — |
| `p_usuario` | `CHAR(8)` | — | — |
| `p_fecha_captura` | `DATE` | — | — |
| `p_cuenta` | `CHAR(4)` | — | — |
| `p_subcta` | `CHAR(2)` | — | — |
| `p_subsubcta` | `CHAR(2)` | — | — |
| `p_ssubsubcta` | `CHAR(2)` | — | — |
| `p_sssubsubcta` | `CHAR(2)` | — | — |
| `p_sector` | `CHAR(2)` | — | — |
| `p_regional` | `CHAR(3)` | — | — |
| `p_costo_dest` | `CHAR(4)` | — | — |
| `p_nro_auxiliar` | `CHAR(12)` | — | — |
| `p_fecha_valida` | `DATE` | — | — |
| `p_moneda` | `CHAR(2)` | — | — |
| `p_naturaleza` | `CHAR(1)` | — | — |
| `p_monto` | `MONEY(18,2)` | — | — |
| `p_descripcion` | `CHAR(80)` | — | — |
| `p_usuario_int` | `CHAR(8)` | `int`=interés | ✅ CÓDIGO |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cVarDataErr` | `VARCHAR(64)` | L8 |
| `iSqlErr` | `INTEGER` | L9 |
| `iSamErr` | `INTEGER` | L10 |
| `cod_ret` | `CHAR(5)` | L11 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `co_auditerr` | `bdicont` | no | INSERT | L54 |
| `co_integracion` | `bdicont` | no | INSERT | L65 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L48 | VALIDACIÓN_NULL | `IF (p_monto = '' OR p_monto IS NULL OR p_monto=0) OR (p_usuario_int = '' OR p_usuario_int IS NULL) T` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `?_co_` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `int` | ENTIDAD | interés | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `?egracion` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_co_`, `?egracion` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_co_obtiene_movcont`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_sp_co_obtiene_movcont.sql` |
| **LOC (1er CREATE)** | 205 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "obtiene movimiento" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `obtiene` → `SELECT` encontrado en el cuerpo · `obtiene` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=4 · INFERIDO=0 · SINTÉTICO=1 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_co_obtiene_movcont(
  pempresa                     char(3)
  pfecha_hoy                   date
  pusuario                     char(10)
) RETURNING char(3)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pempresa` | `char(3)` | — | — |
| `pfecha_hoy` | `date` | — | — |
| `pusuario` | `char(10)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vciudad` | `char(3)` | L6 |
| `w_empresa` | `char(3)` | L7 |
| `vusuario` | `char(8)` | L8 |
| `vpoliza_usuario` | `char(8)` | L9 |
| `vdescripcion` | `char(50)` | L10 |
| `vmonto` | `money(14,2)` | L11 |
| `v_rowid` | `integer` | L17 |
| `pfecha_hoy1` | `date` | L18 |
| `vexiste` | `integer` | L19 |
| `vccosto_orig` | `char(4)` | L20 |
| `vcargos_dia` | `money(18,2)` | L21 |
| `vabonos_dia` | `money(18,2)` | L22 |
| `vnro_cargos_dia` | `integer` | L23 |
| `vnro_abonos_dia` | `integer` | L24 |
| `vdias_proyectado` | `integer` | L25 |
| `vdias_acumulados` | `integer` | L26 |
| `vsaldo_acumulado` | `money(18,2)` | L27 |
| `vsaldo_inicio_dia` | `money(18,2)` | L28 |
| `vsaldo_fin_de_dia` | `money(18,2)` | L29 |
| `vsuma_carabo` | `money(18,2)` | L30 |
| `vmes_dia` | `date` | L31 |
| `vfecha_sig` | `date` | L32 |
| `vsaldo_inicio` | `money(18,2)` | L33 |
| `vcar_dia` | `money(18,2)` | L34 |
| `vabo_dia` | `money(18,2)` | L35 |
| *…24 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_catalog` | `bdinteg` | ⚠️ sí | SELECT | L80 |
| `co_conciliamovs` | `bdicont` | no | SELECT | L90 |
| `co_conciliamovs` | `bdicont` | no | DELETE | L90 |
| `co_fechas` | `bdicont` | no | SELECT | L96 |
| `co_catctaconcil` | `bdicont` | no | SELECT | L113 |
| `co_mensual` | `bdicont` | no | SELECT | L123 |
| `co_conciliamovs` | `bdicont` | no | INSERT | L154 |
| `co_historico` | `bdicont` | no | SELECT | L163 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `?_co_` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `obtiene` | ACCION | obtiene / recupera | 🔵 CONVENCIÓN | nombre_sp |
| `mov` | ENTIDAD | movimiento | 🔵 CONVENCIÓN | nombre_sp |
| `cont` | PREFIJO | familia contabilidad | 🔵 CONVENCIÓN | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_co_` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_co_sel_mov_apli`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_sp_co_sel_mov_apli.sql` |
| **LOC (1er CREATE)** | 244 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "movimiento" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 7 tabla(s) con operaciones: UPDATE, SELECT, INSERT |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=2 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_co_sel_mov_apli(
  v_empresa                    CHAR(4)
  v_fechainicio                DATE
  v_fechafin                   DATE
  v_ccmayorini                 CHAR(4)
  v_ccsubini                   CHAR(2)
  v_ccsubsubini                CHAR(2)
  v_ccssubsubini               CHAR(2)
  v_ccsssubsubini              CHAR(2)
  v_sectorini                  CHAR(2)
  v_ccmayorfin                 CHAR(4)
  v_ccsubfin                   CHAR(2)
  v_ccsubsubfin                CHAR(2)
  v_ccssubsubfin               CHAR(2)
  v_ccsssubsubfin              CHAR(2)
  v_sectorfin                  CHAR(2)
  v_sucursal                   CHAR(4)
  v_auxiliar                   CHAR(12)
  v_moneda                     CHAR(2)
) RETURNING VARCHAR(5), DATE, DATE, CHAR(8), CHAR(4), CHAR(4), CHAR(4), CHAR(2), CHAR(2), CHAR(2), CHAR(2), CHAR(2), CHAR(12), DECIMAL(18,2), CHAR(1), CHAR(2)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `v_empresa` | `CHAR(4)` | — | — |
| `v_fechainicio` | `DATE` | — | — |
| `v_fechafin` | `DATE` | — | — |
| `v_ccmayorini` | `CHAR(4)` | — | — |
| `v_ccsubini` | `CHAR(2)` | — | — |
| `v_ccsubsubini` | `CHAR(2)` | — | — |
| `v_ccssubsubini` | `CHAR(2)` | — | — |
| `v_ccsssubsubini` | `CHAR(2)` | — | — |
| `v_sectorini` | `CHAR(2)` | — | — |
| `v_ccmayorfin` | `CHAR(4)` | — | — |
| `v_ccsubfin` | `CHAR(2)` | — | — |
| `v_ccsubsubfin` | `CHAR(2)` | — | — |
| `v_ccssubsubfin` | `CHAR(2)` | — | — |
| `v_ccsssubsubfin` | `CHAR(2)` | — | — |
| `v_sectorfin` | `CHAR(2)` | — | — |
| `v_sucursal` | `CHAR(4)` | — | — |
| `v_auxiliar` | `CHAR(12)` | — | — |
| `v_moneda` | `CHAR(2)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `v_ccmayor` | `CHAR(10)` | L22 |
| `v_ccsub` | `CHAR(10)` | L23 |
| `v_ccsubsub` | `CHAR(10)` | L24 |
| `v_ccssubsub` | `CHAR(10)` | L25 |
| `v_ccsssubsub` | `CHAR(10)` | L26 |
| `v_sector` | `CHAR(10)` | L27 |
| `v_cuenta` | `CHAR(14)` | L28 |
| `v_cuenta_fin` | `CHAR(14)` | L29 |
| `v_fechahoy` | `DATE` | L30 |
| `v_mesinicio` | `INTEGER` | L31 |
| `v_anoinicio` | `INTEGER` | L32 |
| `v_mesfin` | `INTEGER` | L33 |
| `v_anofin` | `INTEGER` | L34 |
| `v_meshoy` | `INTEGER` | L35 |
| `v_anohoy` | `INTEGER` | L36 |
| `tmovimientos` | `INTEGER` | L37 |
| `cVarDataErr` | `VARCHAR(64)` | L38 |
| `iSqlErr` | `INTEGER` | L39 |
| `iSamErr` | `INTEGER` | L40 |
| `vCodret` | `CHAR(5)` | L41 |
| `v_auxiliar_cta` | `CHAR(1)` | L42 |
| `vb_ctacontable` | `BOOLEAN` | L43 |
| `v_fecha_captura` | `DATE` | L45 |
| `v_fecha_valida` | `DATE` | L46 |
| `v_usuario` | `CHAR(8)` | L47 |
| *…6 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `co_fechas` | `bdicont` | no | SELECT | L112 |
| `tmp_ctacontable` | `bdicont` | no | INSERT | L138 |
| `si_catalog` | `bdinteg` | ⚠️ sí | SELECT | L140 |
| `statistics` | `bdicont` | no | UPDATE | L156 |
| `tmp_ctacontable` | `bdicont` | no | SELECT | L173 |
| `co_mensual` | `bdicont` | no | SELECT | L184 |
| `co_historico` | `bdicont` | no | SELECT | L213 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L158 | VALIDACIÓN_NULL | `IF v_sucursal IS NULL OR v_sucursal = "" THEN` |  |
| L162 | VALIDACIÓN_NULL | `IF v_auxiliar IS NULL OR v_auxiliar = "" THEN` |  |
| L166 | VALIDACIÓN_NULL | `IF v_moneda IS NULL OR v_moneda = "" THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `?_co_sel_` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `mov` | ENTIDAD | movimiento | 🔵 CONVENCIÓN | nombre_sp |
| `?_apli` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_co_sel_`, `?_apli` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_co_sel_sdo_apli`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_sp_co_sel_sdo_apli.sql` |
| **LOC (1er CREATE)** | 289 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "saldo" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 9 tabla(s) con operaciones: UPDATE, SELECT, INSERT |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=2 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_co_sel_sdo_apli(
  v_empresa                    CHAR(4)
  v_fechainicio                DATE
  v_fechafin                   DATE
  v_ccmayorini                 CHAR(4)
  v_ccsubini                   CHAR(2)
  v_ccsubsubini                CHAR(2)
  v_ccssubsubini               CHAR(2)
  v_ccsssubsubini              CHAR(2)
  v_sectorini                  CHAR(2)
  v_ccmayorfin                 CHAR(4)
  v_ccsubfin                   CHAR(2)
  v_ccsubsubfin                CHAR(2)
  v_ccssubsubfin               CHAR(2)
  v_ccsssubsubfin              CHAR(2)
  v_sectorfin                  CHAR(2)
  v_sucursal                   CHAR(4)
  v_auxiliar                   CHAR(12)
  v_moneda                     CHAR(2)
) RETURNING VARCHAR(5), DATE, CHAR(4), CHAR(4), CHAR(2), CHAR(2), CHAR(2), CHAR(2), CHAR(2), CHAR(12), DECIMAL(18,2), DECIMAL(18,2), DECIMAL(18,2), DECIMAL(18,2), CHAR(2)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `v_empresa` | `CHAR(4)` | — | — |
| `v_fechainicio` | `DATE` | — | — |
| `v_fechafin` | `DATE` | — | — |
| `v_ccmayorini` | `CHAR(4)` | — | — |
| `v_ccsubini` | `CHAR(2)` | — | — |
| `v_ccsubsubini` | `CHAR(2)` | — | — |
| `v_ccssubsubini` | `CHAR(2)` | — | — |
| `v_ccsssubsubini` | `CHAR(2)` | — | — |
| `v_sectorini` | `CHAR(2)` | — | — |
| `v_ccmayorfin` | `CHAR(4)` | — | — |
| `v_ccsubfin` | `CHAR(2)` | — | — |
| `v_ccsubsubfin` | `CHAR(2)` | — | — |
| `v_ccssubsubfin` | `CHAR(2)` | — | — |
| `v_ccsssubsubfin` | `CHAR(2)` | — | — |
| `v_sectorfin` | `CHAR(2)` | — | — |
| `v_sucursal` | `CHAR(4)` | — | — |
| `v_auxiliar` | `CHAR(12)` | — | — |
| `v_moneda` | `CHAR(2)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `v_ccmayor` | `CHAR(10)` | L22 |
| `v_ccsub` | `CHAR(10)` | L23 |
| `v_ccsubsub` | `CHAR(10)` | L24 |
| `v_ccssubsub` | `CHAR(10)` | L25 |
| `v_ccsssubsub` | `CHAR(10)` | L26 |
| `v_sector` | `CHAR(10)` | L27 |
| `v_cuenta` | `CHAR(14)` | L28 |
| `v_cuenta_fin` | `CHAR(14)` | L29 |
| `v_fechahoy` | `DATE` | L30 |
| `v_mesinicio` | `INTEGER` | L31 |
| `v_anoinicio` | `INTEGER` | L32 |
| `v_mesfin` | `INTEGER` | L33 |
| `v_anofin` | `INTEGER` | L34 |
| `v_meshoy` | `INTEGER` | L35 |
| `v_anohoy` | `INTEGER` | L36 |
| `tmovimientos` | `INTEGER` | L37 |
| `cVarDataErr` | `VARCHAR(64)` | L38 |
| `iSqlErr` | `INTEGER` | L39 |
| `iSamErr` | `INTEGER` | L40 |
| `vCodret` | `CHAR(5)` | L41 |
| `v_auxiliar_cta` | `CHAR(1)` | L42 |
| `vb_ctacontable` | `BOOLEAN` | L43 |
| `v_mes_dia` | `DATE` | L45 |
| `v_sucursal_r` | `CHAR(4)` | L46 |
| `v_nro_auxiliar` | `CHAR(12)` | L47 |
| *…6 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `co_fechas` | `bdicont` | no | SELECT | L114 |
| `tmp_ctacontable` | `bdicont` | no | INSERT | L140 |
| `si_catalog` | `bdinteg` | ⚠️ sí | SELECT | L142 |
| `statistics` | `bdicont` | no | UPDATE | L158 |
| `tmp_ctacontable` | `bdicont` | no | SELECT | L175 |
| `co_sdodias` | `bdicont` | no | SELECT | L186 |
| `co_diasaux` | `bdicont` | no | SELECT | L209 |
| `co_histsdodias` | `bdicont` | no | SELECT | L238 |
| `co_histdiasaux` | `bdicont` | no | SELECT | L261 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L160 | VALIDACIÓN_NULL | `IF v_sucursal IS NULL OR v_sucursal = "" THEN` |  |
| L164 | VALIDACIÓN_NULL | `IF v_auxiliar IS NULL OR v_auxiliar = "" THEN` |  |
| L168 | VALIDACIÓN_NULL | `IF v_moneda IS NULL OR v_moneda = "" THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `?_co_sel_` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `sdo` | ENTIDAD | saldo | 🔵 CONVENCIÓN | nombre_sp |
| `?_apli` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_co_sel_`, `?_apli` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_co_selfaltantes`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_sp_co_selfaltantes.sql` |
| **LOC (1er CREATE)** | 85 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "(faltantes)" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 2 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=1 / 3 términos |

### Firma

```sql
CREATE PROCEDURE sp_co_selfaltantes(
  pempresa                     char(3)
  pfecha                       date
) RETURNING CHAR(5),CHAR(4),CHAR(4),CHAR(8),CHAR(8),CHAR(14),
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pempresa` | `char(3)` | — | — |
| `pfecha` | `date` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vCodRet` | `CHAR(5)` | L5 |
| `vproducto` | `CHAR(4)` | L6 |
| `vtransacc` | `CHAR(4)` | L7 |
| `vusuario_sus` | `CHAR(8)` | L8 |
| `vusuario_fin` | `CHAR(8)` | L9 |
| `vccontable` | `CHAR(14)` | L10 |
| `vfecha_valida` | `DATE` | L11 |
| `vfecha_captura_sus` | `DATE` | L12 |
| `vfecha_captura_fin` | `DATE` | L13 |
| `vcontrol_poliza_sus` | `INTEGER` | L14 |
| `vcontrol_poliza_fin` | `INTEGER` | L15 |
| `vsuccta` | `CHAR(4)` | L16 |
| `vsucursal` | `CHAR(4)` | L17 |
| `vtot_cargo` | `MONEY(14,2)` | L18 |
| `vtot_abono` | `MONEY(14,2)` | L19 |
| `vdescripcion` | `CHAR(30)` | L20 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sc_suspenso` | `bdicheq` | ⚠️ sí | SELECT | L56 |
| `sv_suspenso` | `bdinvers` | ⚠️ sí | SELECT | L75 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `?_co_sel` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `faltantes` | MODIF | faltantes | 🔵 CONVENCIÓN | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_co_sel` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_cocifras`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_sp_cocifras.sql` |
| **LOC (1er CREATE)** | 142 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "sp_cocifras" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 11 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=1 / 2 términos |

### Firma

```sql
CREATE PROCEDURE sp_cocifras(
  p_sempresa                   CHAR(3)
  p_sfecha                     CHAR(10)
  p_susuario                   CHAR(8)
) RETURNING CHAR(3), CHAR (30), CHAR(4), MONEY(18,2), CHAR(1), CHAR(2), CHAR(30), CHAR(8), CHAR(45), CHAR(40), DATE,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_sempresa` | `CHAR(3)` | — | — |
| `p_sfecha` | `CHAR(10)` | — | — |
| `p_susuario` | `CHAR(8)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `v_sempresa` | `CHAR(30)` | L6 |
| `v_scmayor` | `CHAR(4)` | L7 |
| `v_imonto` | `MONEY(18,2)` | L8 |
| `v_snaturaleza` | `CHAR(1)` | L9 |
| `v_idivisa` | `CHAR(2)` | L10 |
| `v_smoneda` | `CHAR(30)` | L11 |
| `v_susuario` | `CHAR(8)` | L12 |
| `v_snombre` | `CHAR(45)` | L13 |
| `v_sgerente` | `CHAR(40)` | L14 |
| `v_dfecha_captura` | `DATE` | L15 |
| `v_sccosto_orig` | `CHAR(4)` | L16 |
| `v_snombrecc_orig` | `CHAR(40)` | L17 |
| `v_sregional` | `CHAR(3)` | L18 |
| `v_snombrereg` | `CHAR(40)` | L19 |
| `v_senl_cc_mayor` | `CHAR(4)` | L20 |
| `vfecha_cont` | `DATE` | L21 |
| `v_dfechanueva` | `DATE` | L23 |
| `v_splaza` | `CHAR(3)` | L24 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `co_fechas` | `bdicont` | no | SELECT | L40 |
| `si_empresas` | `bdinteg` | ⚠️ sí | SELECT | L44 |
| `co_param` | `bdicont` | no | SELECT | L49 |
| `co_detpol` | `bdicont` | no | SELECT | L57 |
| `si_divisas` | `bdinteg` | ⚠️ sí | SELECT | L68 |
| `si_ejecut` | `bdinteg` | ⚠️ sí | SELECT | L69 |
| `si_sucursales` | `bdinteg` | ⚠️ sí | SELECT | L70 |
| `si_plazas` | `bdinteg` | ⚠️ sí | SELECT | L71 |
| `si_regional` | `bdinteg` | ⚠️ sí | SELECT | L72 |
| `co_mensual` | `bdicont` | no | SELECT | L86 |
| `co_historico` | `bdicont` | no | SELECT | L115 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L74 | VALIDACIÓN_NULL | `IF v_snombre IS NULL THEN` |  |
| L104 | VALIDACIÓN_NULL | `IF v_snombre IS NULL THEN` |  |
| L133 | VALIDACIÓN_NULL | `IF v_snombre IS NULL THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `?_cocifras` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_cocifras` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_conciliaxctacontab`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_sp_conciliaxctacontab.sql` |
| **LOC (1er CREATE)** | 311 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "conciliación cuenta" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 14 tabla(s) con operaciones: DELETE, UPDATE, SELECT, INSERT |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=5 · INFERIDO=0 · SINTÉTICO=1 / 6 términos |

### Firma

```sql
CREATE PROCEDURE sp_conciliaxctacontab(
  pempresa                     char(3)
  psucursal                    char(4)
  pfecha                       date
  pctaconta                    char(14)
  pnaturaleza                  char(1)
  psistema                     char(2)
) RETURNING char(5), char(4), char(16), char(4),
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pempresa` | `char(3)` | — | — |
| `psucursal` | `char(4)` | — | — |
| `pfecha` | `date` | — | — |
| `pctaconta` | `char(14)` | `cta`=cuenta · `cont`=familia contabilidad | 🔵 CONVENCIÓN |
| `pnaturaleza` | `char(1)` | — | — |
| `psistema` | `char(2)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vcodret` | `CHAR(5)` | L12 |
| `vsqlerr` | `INTEGER` | L13 |
| `vt_producto` | `CHAR(4)` | L14 |
| `vt_folio` | `CHAR(16)` | L15 |
| `vt_cuenta` | `CHAR(16)` | L16 |
| `vt_transacc` | `CHAR(4)` | L17 |
| `vt_descripcion` | `CHAR(16)` | L18 |
| `vt_monto` | `MONEY(14,2)` | L19 |
| `vt_status` | `CHAR(1)` | L20 |
| `vt_naturaleza` | `CHAR(1)` | L21 |
| `vDesErr` | `CHAR (30)` | L22 |
| `iCuantos` | `INTEGER` | L23 |
| `vfec_movhis` | `DATE` | L24 |
| `val_ifrs` | `CHAR(1)` | L25 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sc_param` | `bdicheq` | ⚠️ sí | SELECT | L53 |
| `sc_movhis` | `bdicheq` | ⚠️ sí | SELECT | L62 |
| `tmp_concil_chq` | `bdicont` | no | INSERT | L81 |
| `sc_movhis_old` | `bdicheq` | ⚠️ sí | SELECT | L110 |
| `tmp_concil_chq` | `bdicheq` | ⚠️ sí | SELECT | L155 |
| `tmp_concil_chq` | `bdicheq` | ⚠️ sí | DELETE | L155 |
| `statistics` | `bdicont` | no | UPDATE | L160 |
| `si_prodtran` | `bdinteg` | ⚠️ sí | SELECT | L181 |
| `tmp_concil_inv` | `bdicred` | ⚠️ sí | SELECT | L205 |
| `sd_param` | `bdicred` | ⚠️ sí | SELECT | L221 |
| `sd_movhis` | `bdicred` | ⚠️ sí | SELECT | L229 |
| `tmp_concil_crd_1` | `bdicont` | no | SELECT | L267 |
| `tmp_concil_crd` | `bdicont` | no | INSERT | L275 |
| `tmp_concil_crd` | `bdicred` | ⚠️ sí | SELECT | L294 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `concilia` | ACCION | conciliación | 🔵 CONVENCIÓN | nombre_sp |
| `x` | MODIF | por (criterio) | 🔵 CONVENCIÓN | nombre_sp |
| `cta` | ENTIDAD | cuenta | 🔵 CONVENCIÓN | nombre_sp |
| `cont` | PREFIJO | familia contabilidad | 🔵 CONVENCIÓN | nombre_sp |
| `?ab` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?ab` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_concilsdos_app`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_sp_concilsdos_app.sql` |
| **LOC (1er CREATE)** | 162 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "consulta saldos (canal app)" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=2 · INFERIDO=2 · SINTÉTICO=1 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_concilsdos_app(
  pempresa                     CHAR(3)
  pfecha                       DATE
  psistema                     CHAR(2)
) RETURNING VARCHAR(5),    --retorno
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pempresa` | `CHAR(3)` | — | — |
| `pfecha` | `DATE` | — | — |
| `psistema` | `CHAR(2)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cVarDataErr` | `VARCHAR(64)` | L10 |
| `iSqlErr` | `INTEGER` | L11 |
| `iSamErr` | `INTEGER` | L12 |
| `vCodRet` | `CHAR(5)` | L13 |
| `vfecha_cont` | `DATE` | L15 |
| `vproducto` | `CHAR(50)` | L16 |
| `vnivel_cont` | `CHAR(14)` | L17 |
| `vconcept_op` | `VARCHAR(25)` | L18 |
| `vsaldocont` | `DECIMAL(18,2)` | L19 |
| `vsaldooper` | `DECIMAL(18,2)` | L20 |
| `vsaldiff` | `DECIMAL(18,2)` | L21 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `co_fechas` | `bdicont` | no | SELECT | L49 |
| `sc_concilsdo_difacum` | `bdicheq` | ⚠️ sí | SELECT | L67 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `con` | ACCION | consulta | 🟡 INFERIDO | nombre_sp |
| `?cil` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `sdos` | ENTIDAD | saldos (abreviación) | 🟡 INFERIDO | nombre_sp |
| `app` | MODIF | canal app | 🔵 CONVENCIÓN | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?cil` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_concilsdos_app_det`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_sp_concilsdos_app_det.sql` |
| **LOC (1er CREATE)** | 153 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "consulta saldos y detalle (canal app)" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=2 · INFERIDO=2 · SINTÉTICO=1 / 6 términos |

### Firma

```sql
CREATE PROCEDURE sp_concilsdos_app_det(
  pempresa                     CHAR(3)
  pfecha                       DATE
  psistema                     CHAR(2)
  ptipoconsulta                CHAR(1)
) RETURNING VARCHAR(5),   --retorno
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pempresa` | `CHAR(3)` | — | — |
| `pfecha` | `DATE` | — | — |
| `psistema` | `CHAR(2)` | — | — |
| `ptipoconsulta` | `CHAR(1)` | `con`=consulta | ✅ CÓDIGO |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cVarDataErr` | `VARCHAR(64)` | L19 |
| `iSqlErr` | `INTEGER` | L20 |
| `iSamErr` | `INTEGER` | L21 |
| `vCodRet` | `CHAR(5)` | L22 |
| `vfecha_cont` | `DATE` | L24 |
| `vproducto` | `CHAR(4)` | L26 |
| `vcuenta` | `CHAR(20)` | L27 |
| `vconcept_op` | `VARCHAR(25)` | L28 |
| `vcapital_anterior` | `DECIMAL(18,2)` | L30 |
| `vmovs_cargo` | `DECIMAL(18,2)` | L31 |
| `vmovs_abono` | `DECIMAL(18,2)` | L32 |
| `vcapital_calculado` | `DECIMAL(18,2)` | L33 |
| `vcapital_actual` | `DECIMAL(18,2)` | L34 |
| `vdiferencia_capital` | `DECIMAL(18,2)` | L35 |
| `vinteres_anterior` | `DECIMAL(18,2)` | L36 |
| `vmovs_cargo_interes` | `DECIMAL(18,2)` | L37 |
| `vmovs_abono_interes` | `DECIMAL(18,2)` | L38 |
| `vinteres_calculado` | `DECIMAL(18,2)` | L39 |
| `vinteres_actual` | `DECIMAL(18,2)` | L40 |
| `vdiferencia_interes` | `DECIMAL(18,2)` | L41 |
| `vmaxregistros` | `INTEGER` | L42 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `co_fechas` | `bdicont` | no | SELECT | L82 |
| `sc_concilsdo_difdet` | `bdicheq` | ⚠️ sí | SELECT | L87 |
| `sc_concilsdo_difacum` | `bdicheq` | ⚠️ sí | SELECT | L124 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `con` | ACCION | consulta | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?cil` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `sdos` | ENTIDAD | saldos (abreviación) | 🟡 INFERIDO | nombre_sp |
| `app` | MODIF | canal app | 🔵 CONVENCIÓN | nombre_sp |
| `det` | ENTIDAD | detalle | 🟡 INFERIDO | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?cil` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_condiffsuc`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_sp_condiffsuc.sql` |
| **LOC (1er CREATE)** | 80 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "consulta (sucursal)" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=1 · INFERIDO=1 · SINTÉTICO=1 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_condiffsuc(
  pempresa                     char(3)
  pusuario                     char(8)
  psucursal                    char(4)
  pfecha                       date
) RETURNING char(5),char(30),char(30),money(14,2),money(14,2),char(2)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pempresa` | `char(3)` | — | — |
| `pusuario` | `char(8)` | — | — |
| `psucursal` | `char(4)` | `suc`=sucursal | 🟡 INFERIDO |
| `pfecha` | `date` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vcodret` | `char(5)` | L7 |
| `vsucursal` | `char(4)` | L8 |
| `vsucursaldesc` | `char(30)` | L9 |
| `vcuentacon` | `char(30)` | L10 |
| `vcargos` | `money(14,2)` | L11 |
| `vabonos` | `money(14,2)` | L12 |
| `vsistema` | `char(2)` | L13 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `co_auditerr_cint` | `bdicont` | no | SELECT | L36 |
| `si_sucursales` | `bdinteg` | ⚠️ sí | SELECT | L46 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `con` | ACCION | consulta | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?diff` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `suc` | MODIF | sucursal | 🟡 INFERIDO | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?diff` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_conscheqb3`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_sp_conscheqb3.sql` |
| **LOC (1er CREATE)** | 157 |
| **Callgraph** | ✅ fan_in=0 / fan_out=25 |
| **Deps concatenadas** | 9 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "consulta cheque (sufijo de versión de SP)" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 5 llamada(s): `sp_consdetallechequespagadossuc_totales`, `sp_consdetallechequespagadossuc`, `sp_consgeneralfechas` |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=3 · INFERIDO=1 · SINTÉTICO=0 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_conscheqb3(
  pBandera                     CHAR(2)
  pUsuario                     CHAR(8)
  pIdFuncion                   CHAR(10)
  pIdConsulta                  CHAR(1)
  pFechaInicio                 CHAR(10)
  pFechaFin                    CHAR(10)
  pRegistros                   INTEGER
  pRecuperacion                INTEGER
  pCliente                     CHAR(20)
  pCuenta                      CHAR(20)
  pCheque                      CHAR(7)
  pClaveBanco                  CHAR(3)
) RETURNING CHAR(5)     AS codret,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pBandera` | `CHAR(2)` | — | — |
| `pUsuario` | `CHAR(8)` | — | — |
| `pIdFuncion` | `CHAR(10)` | — | — |
| `pIdConsulta` | `CHAR(1)` | `cons`=consulta | 🔵 CONVENCIÓN |
| `pFechaInicio` | `CHAR(10)` | — | — |
| `pFechaFin` | `CHAR(10)` | — | — |
| `pRegistros` | `INTEGER` | — | — |
| `pRecuperacion` | `INTEGER` | — | — |
| `pCliente` | `CHAR(20)` | — | — |
| `pCuenta` | `CHAR(20)` | — | — |
| `pCheque` | `CHAR(7)` | `cheq`=cheque | 🔵 CONVENCIÓN |
| `pClaveBanco` | `CHAR(3)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(5)` | L30 |
| `iSqlErr` | `INTEGER` | L31 |
| `iNumRegistros` | `INTEGER` | L32 |
| `cSucursal` | `CHAR(4)` | L33 |
| `cNombreSuc` | `CHAR(40)` | L34 |
| `cCuenta` | `CHAR(20)` | L35 |
| `cNumCheque` | `CHAR(5)` | L36 |
| `mMonto` | `MONEY(16,2)` | L37 |
| `dFechaHora` | `CHAR(20)` | L38 |
| `cFolioSuc` | `CHAR(16)` | L39 |
| `cTransacc` | `CHAR(4)` | L40 |
| `cCliente` | `CHAR(20)` | L41 |
| `sSecuencia` | `SMALLINT` | L42 |
| `cBanderaVisor` | `CHAR(1)` | L43 |
| `dFechaHoy` | `DATE` | L44 |
| `dFechaAnt` | `DATE` | L45 |
| `dProxFecha` | `DATE` | L46 |
| `cNumFirmas` | `CHAR(2)` | L47 |
| `cCombFirmas` | `CHAR(120)` | L48 |
| `cTipoFirma` | `CHAR(20)` | L49 |
| `cCveBanco` | `CHAR(3)` | L50 |
| `dFechaPresenta` | `DATE` | L51 |
| `cCodDocumento` | `CHAR(4)` | L52 |
| `iSecDocto` | `SMALLINT` | L53 |
| `cHayImgFirmas` | `CHAR(1)` | L54 |
| *…1 más…* | | |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_consdetallechequespagadossuc_totales` | `bdicnweb` | ⚠️ sí | L109 |
| `sp_consdetallechequespagadossuc` | `bdicnweb` | ⚠️ sí | L114 |
| `sp_consgeneralfechas` | `bdicnweb` | ⚠️ sí | L123 |
| `sp_consultafirmascomb` | `bdicnweb` | ⚠️ sí | L127 |
| `sp_ope_validaimagencheque` | `bdicnweb` | ⚠️ sí | L132 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L58 | CÓDIGO_RETORNO | `LET cCodRet                     = '00000';` |  |
| L94 | CÓDIGO_RETORNO | `LET cCodRet = '00003';` |  |
| L137 | CÓDIGO_RETORNO | `LET cCodRet = '00017';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `cons` | ACCION | consulta | 🔵 CONVENCIÓN | nombre_sp |
| `cheq` | ENTIDAD | cheque | 🔵 CONVENCIÓN | nombre_sp |
| `b3` | MODIF | sufijo de versión de SP (Bloque/Build 3) — patrón Informix:  | 🟡 INFERIDO | nombre_sp |

---

## `sp_consultaparametrosgenerales2`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_sp_consultaparametrosgenerales2.sql` |
| **LOC (1er CREATE)** | 95 |
| **Callgraph** | ✅ fan_in=16 / fan_out=7 |
| **Deps concatenadas** | 3 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "consulta parámetros (general)" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo · `genera` → `INSERT` encontrado en el cuerpo · `genera` → `SELECT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=1 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_consultaparametrosgenerales2(
  pUsuario                     CHAR(8)
  pIdFuncion                   CHAR(10)
  pWhere                       CHAR(15)
  pIdParametro                 CHAR(15)
) RETURNING CHAR(5) AS codret,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pUsuario` | `CHAR(8)` | — | — |
| `pIdFuncion` | `CHAR(10)` | — | — |
| `pWhere` | `CHAR(15)` | — | — |
| `pIdParametro` | `CHAR(15)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(5)` | L5 |
| `iSqlErr` | `INTEGER` | L6 |
| `cValor` | `CHAR(100)` | L7 |
| `cQuery` | `CHAR(500)` | L8 |
| `sIdFuncion` | `CHAR(10)` | L9 |
| `sNombreBase` | `CHAR(12)` | L10 |
| `sNmbreTabla` | `CHAR(40)` | L11 |
| `sCampo` | `CHAR(20)` | L12 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sw_parametros_generales` | `bdicnweb` | ⚠️ sí | SELECT | L54 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_cnsif_confirmaejecutivo` | `bdinteg` | ⚠️ sí | L40 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L14 | CÓDIGO_RETORNO | `LET cCodRet = '00000';` |  |
| L35 | CÓDIGO_RETORNO | `LET cCodRet = '00003';` |  |
| L48 | CÓDIGO_RETORNO | `LET cCodRet = '00003';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `consulta` | ACCION | consulta / lee | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `parametros` | ENTIDAD | parámetros | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `general` | MODIF | general | 🔵 CONVENCIÓN | nombre_sp |
| `?es2` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?es2` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_consultarcoauditerr`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_sp_consultarcoauditerr.sql` |
| **LOC (1er CREATE)** | 62 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "consultar auditoría" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=1 · INFERIDO=1 · SINTÉTICO=2 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_consultarcoauditerr(
  p_sEmpresa                   CHAR(3)
  p_sSistema                   CHAR(2)
  p_sUsuario                   CHAR(8)
  p_dFechaCaptura              DATE
) RETURNING CHAR(8) AS usuario, INTEGER AS control_poliza, DATE AS fecha_captura, INTEGER AS secuencia, CHAR (3) AS empresa, CHAR (10) AS ccmayor,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_sEmpresa` | `CHAR(3)` | — | — |
| `p_sSistema` | `CHAR(2)` | — | — |
| `p_sUsuario` | `CHAR(8)` | — | — |
| `p_dFechaCaptura` | `DATE` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `v_sUsuario` | `CHAR(8)` | L7 |
| `v_iControlPoliza` | `INTEGER` | L8 |
| `v_dFechaCaptura` | `DATE` | L9 |
| `v_iSecuencia` | `INTEGER` | L10 |
| `v_sEmpresa` | `CHAR(3)` | L11 |
| `v_sCcmayor` | `CHAR(10)` | L12 |
| `v_sCcsub` | `CHAR(10)` | L13 |
| `v_sCcsubsub` | `CHAR(10)` | L14 |
| `v_sCcssubsub` | `CHAR(10)` | L15 |
| `v_sCcsssubsub` | `CHAR(10)` | L16 |
| `v_sSector` | `CHAR(10)` | L17 |
| `v_sAuxiliar` | `CHAR(12)` | L18 |
| `v_sCodRet` | `CHAR (3)` | L19 |
| `v_sDescripcion` | `CHAR(50)` | L20 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `co_auditerr` | `bdicont` | no | SELECT | L50 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `consultar` | ACCION | consultar | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?co` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `aud` | ENTIDAD | auditoría | 🟡 INFERIDO | nombre_sp |
| `?iterr` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?co`, `?iterr` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_cont_cargamovimientob3`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_sp_cont_cargamovimientob3.sql` |
| **LOC (1er CREATE)** | 338 |
| **Callgraph** | ✅ fan_in=0 / fan_out=63 |
| **Deps concatenadas** | 19 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "carga movimiento (sufijo de versión de SP)" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 8 llamada(s): `valida_archivo_importa`, `sp_cont_co_integracionb3`, `importa` |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=0 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_cont_cargamovimientob3(
  pBandera                     CHAR(2)
  pSBandera                    CHAR(1)
  pNomArchivo                  CHAR(100)
  pFecha                       DATE
  pCve_Usuario                 CHAR(8)
  pContrasena                  CHAR(6)
  pImporte                     MONEY
  pProceso                     CHAR(20)
  pCodigo                      CHAR(3)
  pCc_orig                     CHAR(4)
  pFecha_captura               DATE
  pCuenta_mayor                CHAR(4)
  pSubcta                      CHAR(2)
  pSubsubcta                   CHAR(2)
  pSubsubsubcta                CHAR(2)
  pSubsubsubsubcta             CHAR(2)
  pSector                      CHAR(2)
  pRegion                      CHAR(3)
  pSucursal                    CHAR(4)
  pNum_auxiliar                CHAR(12)
  pFecha_valida                DATE
  pMoneda                      CHAR(2)
  pNaturaleza                  CHAR(1)
  pConcepto                    CHAR(80)
  pControlPoliza               INTEGER
) RETURNING CHAR(5)  AS cod_Retorno,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pBandera` | `CHAR(2)` | — | — |
| `pSBandera` | `CHAR(1)` | — | — |
| `pNomArchivo` | `CHAR(100)` | — | — |
| `pFecha` | `DATE` | — | — |
| `pCve_Usuario` | `CHAR(8)` | — | — |
| `pContrasena` | `CHAR(6)` | `cont`=familia contabilidad | 🔵 CONVENCIÓN |
| `pImporte` | `MONEY` | — | — |
| `pProceso` | `CHAR(20)` | — | — |
| `pCodigo` | `CHAR(3)` | — | — |
| `pCc_orig` | `CHAR(4)` | — | — |
| `pFecha_captura` | `DATE` | — | — |
| `pCuenta_mayor` | `CHAR(4)` | — | — |
| `pSubcta` | `CHAR(2)` | — | — |
| `pSubsubcta` | `CHAR(2)` | — | — |
| `pSubsubsubcta` | `CHAR(2)` | — | — |
| `pSubsubsubsubcta` | `CHAR(2)` | — | — |
| `pSector` | `CHAR(2)` | — | — |
| `pRegion` | `CHAR(3)` | — | — |
| `pSucursal` | `CHAR(4)` | — | — |
| `pNum_auxiliar` | `CHAR(12)` | — | — |
| `pFecha_valida` | `DATE` | — | — |
| `pMoneda` | `CHAR(2)` | — | — |
| `pNaturaleza` | `CHAR(1)` | — | — |
| `pConcepto` | `CHAR(80)` | — | — |
| `pControlPoliza` | `INTEGER` | `cont`=familia contabilidad | 🔵 CONVENCIÓN |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `scod_ret` | `CHAR(5)` | L27 |
| `vsqlerr` | `INTEGER` | L28 |
| `cValor` | `CHAR(50)` | L30 |
| `cNumReg` | `INTEGER` | L31 |
| `cDiasRetroact` | `CHAR(4)` | L32 |
| `cFecha` | `DATE` | L33 |
| `cFechaCaptura` | `DATE` | L34 |
| `cUsuario` | `CHAR(8)` | L35 |
| `cMoneda` | `CHAR(2)` | L36 |
| `cCostoOrig` | `CHAR(4)` | L37 |
| `cImporte` | `MONEY` | L38 |
| `cControlPoliza` | `INTEGER` | L39 |
| `cSucursal` | `CHAR(4)` | L40 |
| `pClave_autorizacion` | `CHAR(6)` | L41 |
| `dDiaFeriado` | `DATE` | L42 |
| `cDescDiaFeriado` | `CHAR(30)` | L43 |
| `cLaborableSN` | `CHAR(1)` | L44 |
| `cCuentaContable` | `CHAR(62)` | L45 |
| `cDescError` | `CHAR(53)` | L46 |
| `iCodigoint` | `INTEGER` | L47 |
| `iLineaReg` | `CHAR(10)` | L48 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_param` | `bdinteg` | ⚠️ sí | SELECT | L154 |
| `co_param` | `bdicont` | no | SELECT | L187 |
| `sw_verificastatuscarga_archcont` | `bdicont` | no | SELECT | L193 |
| `sw_verificastatuscarga_archcont` | `bdicont` | no | DELETE | L193 |
| `sw_verificastatuscarga_archcont` | `bdicont` | no | INSERT | L194 |
| `co_integracion` | `bdicont` | no | SELECT | L207 |
| `co_integracion` | `bdicont` | no | DELETE | L207 |
| `co_clv_retroact` | `bdicont` | no | UPDATE | L222 |
| `co_vbparam` | `bdicont` | no | SELECT | L235 |
| `si_ejecut` | `bdinteg` | ⚠️ sí | SELECT | L240 |
| `co_clv_retroact` | `bdicont` | no | SELECT | L246 |
| `co_fechas` | `bdicont` | no | SELECT | L260 |
| `co_poliza` | `bdicont` | no | SELECT | L265 |
| `co_auditerr` | `bdicont` | no | SELECT | L286 |
| `co_auditerr` | `bdicont` | no | DELETE | L295 |
| `si_empresas` | `bdinteg` | ⚠️ sí | SELECT | L298 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `valida_archivo_importa` | `bdicont` | no | L157 |
| `sp_cont_co_integracionb3` | `bdicont` | no | L163 |
| `importa` | `bdicont` | no | L196 |
| `contproc` | `bdicont` | no | L226 |
| `insertarcointegracion` | `bdicont` | no | L228 |
| `sp_validardiaferiado` | `bdinteg` | ⚠️ sí | L268 |
| `sp_cont_verificastatus_cargaarchivo` | `bdicont` | no | L302 |
| `sp_cargarchivomovimiento_b3` | `bdicont` | no | L306 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L98 | VALIDACIÓN_NULL | `IF (pBandera ='2') AND (pNomArchivo='' OR pFecha is null) THEN` |  |
| L112 | VALIDACIÓN_NULL | `IF (pBandera ='3' AND pSBandera='') OR (pBandera ='3' AND pSBandera='3' AND (pFecha is null OR pCve_` |  |
| L117 | VALIDACIÓN_NULL | `IF (pBandera ='5') AND (pFecha is null OR pCve_Usuario='' OR pNomArchivo='') THEN` |  |
| L121 | VALIDACIÓN_NULL | `IF (pBandera ='6') AND (pFecha is null OR pCve_Usuario='' OR pContrasena='' OR pImporte='') THEN` |  |
| L125 | VALIDACIÓN_NULL | `IF (pBandera ='7') AND ( pFecha is null OR pProceso='' OR pCodigo='' ) THEN` |  |
| L290 | FÓRMULA | `LET cControlPoliza = cControlPoliza + 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `cont` | PREFIJO | familia contabilidad | 🔵 CONVENCIÓN | nombre_sp |
| `cargamovimiento` | ACCION | carga movimiento | 🔵 CONVENCIÓN | nombre_sp |
| `b3` | MODIF | sufijo de versión de SP (Bloque/Build 3) — patrón Informix:  | ✅ CÓDIGO | nombre_sp, texto_cuerpo |

---

## `sp_cont_catalogob3`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_sp_cont_catalogob3.sql` |
| **LOC (1er CREATE)** | 76 |
| **Callgraph** | ✅ fan_in=0 / fan_out=55 |
| **Deps concatenadas** | 18 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "catálogo (sufijo de versión de SP)" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 1 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=2 · INFERIDO=1 · SINTÉTICO=0 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_cont_catalogob3(
  pTipo_cuenta                 CHAR(1)
) RETURNING CHAR(5) AS codret,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pTipo_cuenta` | `CHAR(1)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(5)` | L11 |
| `iSqlErr` | `INTEGER` | L12 |
| `iTotalRegistros` | `INTEGER` | L13 |
| `Cccmayor` | `CHAR(10)` | L14 |
| `Cccsub` | `CHAR(10)` | L15 |
| `Cccsubsub` | `CHAR(10)` | L16 |
| `Cccssubsub` | `CHAR(10)` | L17 |
| `Cccsssubsub` | `CHAR(10)` | L18 |
| `cSector` | `CHAR(10)` | L19 |
| `cNombre` | `CHAR(50)` | L20 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_catalog` | `bdinteg` | ⚠️ sí | SELECT | L55 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L22 | CÓDIGO_RETORNO | `LET cCodRet = '00000';` |  |
| L41 | CÓDIGO_RETORNO | `LET cCodRet = '00003';` |  |
| L57 | FÓRMULA | `LET iTotalRegistros = iTotalRegistros + 1;` |  |
| L64 | CÓDIGO_RETORNO | `LET cCodRet = '00017';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `cont` | PREFIJO | familia contabilidad | 🔵 CONVENCIÓN | nombre_sp |
| `catalogo` | ENTIDAD | catálogo | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `b3` | MODIF | sufijo de versión de SP (Bloque/Build 3) — patrón Informix:  | 🟡 INFERIDO | nombre_sp |

---

## `sp_cont_conssaldosdiariosb4`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_sp_cont_conssaldosdiariosb4.sql` |
| **LOC (1er CREATE)** | 473 |
| **Callgraph** | ✅ fan_in=0 / fan_out=84 |
| **Deps concatenadas** | 21 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "consulta saldos diarios (sufijo de versión de SP)" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=0 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_cont_conssaldosdiariosb4(
  pBandera                     CHAR(2)
  pSBandera                    CHAR(1)
  pNom_tabla                   CHAR(100)
  pUsuario                     char(10)
  pDepto                       char(3)
  pCuentacontable              char(19)
  pCiudad                      CHAR(3)
  pSucursal                    CHAR(4)
  pMoneda                      CHAR(2)
  pFechaContable               DATE
  pExt                         CHAR(2)
) RETURNING CHAR(5)  	AS Cod_Retorno,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pBandera` | `CHAR(2)` | — | — |
| `pSBandera` | `CHAR(1)` | — | — |
| `pNom_tabla` | `CHAR(100)` | — | — |
| `pUsuario` | `char(10)` | — | — |
| `pDepto` | `char(3)` | — | — |
| `pCuentacontable` | `char(19)` | `cont`=familia contabilidad | 🔵 CONVENCIÓN |
| `pCiudad` | `CHAR(3)` | — | — |
| `pSucursal` | `CHAR(4)` | — | — |
| `pMoneda` | `CHAR(2)` | — | — |
| `pFechaContable` | `DATE` | `cont`=familia contabilidad | 🔵 CONVENCIÓN |
| `pExt` | `CHAR(2)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `scod_ret` | `CHAR(5)` | L42 |
| `vsqlerr` | `INTEGER` | L43 |
| `pEmpresa` | `char(3)` | L44 |
| `cTabName` | `CHAR(100)` | L45 |
| `cColName` | `CHAR(100)` | L46 |
| `cColType` | `CHAR(4)` | L47 |
| `cColLength` | `CHAR(4)` | L48 |
| `vsempresa` | `char(3)` | L49 |
| `vsejecutivo` | `char(8)` | L50 |
| `vsnombre` | `char(45)` | L51 |
| `vssucursal` | `char(4)` | L52 |
| `vspuesto` | `char(3)` | L53 |
| `vsdepartamento` | `char(3)` | L54 |
| `vspASsword` | `char(80)` | L55 |
| `vspAS_cod` | `char(80)` | L56 |
| `vsnombramiento` | `char(20)` | L57 |
| `vslimaut_mn` | `DECIMAL(16,2)` | L58 |
| `vslimaut_dls` | `DECIMAL(16,2)` | L59 |
| `vsvigencia` | `date` | L60 |
| `vsperfil` | `INTEGER` | L61 |
| `vsASistente` | `char(80)` | L62 |
| `vsuser_insert` | `char(45)` | L63 |
| `vsfecha_insert` | `DATE` | L64 |
| `cDescripcion` | `char(30)` | L65 |
| `cRazonSocial` | `char(30)` | L66 |
| *…39 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_catalog` | `bdinteg` | ⚠️ sí | SELECT | L355 |
| `si_sucursales` | `bdinteg` | ⚠️ sí | SELECT | L368 |
| `co_cta_ccdest` | `bdicont` | no | SELECT | L384 |
| `sw_sucursales_tmp` | `bdicont` | no | SELECT | L435 |
| `sw_sucursales_tmp` | `bdicont` | no | INSERT | L446 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_cont_sysb4` | `bdicont` | no | L245 |
| `sp_si_ejecutb4` | `bdicont` | no | L254 |
| `sp_si_departamentosb4` | `bdicont` | no | L272 |
| `sp_si_empresasb4` | `bdicont` | no | L279 |
| `sp_si_sucursalesb4` | `bdicont` | no | L283 |
| `sp_selfechacontable` | `bdicont` | no | L290 |
| `sp_selempresa` | `bdinteg` | ⚠️ sí | L296 |
| `sp_selmoneda` | `bdinteg` | ⚠️ sí | L300 |
| `sp_selciudades` | `bdinteg` | ⚠️ sí | L311 |
| `sp_selcatcontable` | `bdinteg` | ⚠️ sí | L322 |
| `sp_obtenercc` | `bdicont` | no | L341 |
| `sp_selsdodias` | `bdicont` | no | L414 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L338 | FÓRMULA | `LET v_sector       = substr(pCuentacontable,18,2);*/` |  |
| L420 | FÓRMULA | `LET iContador = iContador + 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `cont` | PREFIJO | familia contabilidad | 🔵 CONVENCIÓN | nombre_sp |
| `conssaldosdiarios` | ACCION | consulta saldos diarios | 🔵 CONVENCIÓN | nombre_sp |
| `b4` | MODIF | sufijo de versión de SP (Bloque/Build 4) | ✅ CÓDIGO | nombre_sp, texto_cuerpo |

---

## `sp_cont_divisasb4`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_sp_cont_divisasb4.sql` |
| **LOC (1er CREATE)** | 56 |
| **Callgraph** | ✅ fan_in=0 / fan_out=55 |
| **Deps concatenadas** | 17 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "divisas (sufijo de versión de SP)" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 1 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=2 · INFERIDO=1 · SINTÉTICO=0 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_cont_divisasb4(
) RETURNING CHAR(5) AS codret,
```

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(5)` | L6 |
| `ISqlErr` | `INTEGER` | L7 |
| `cDivisa` | `CHAR(2)` | L8 |
| `cDescripcion` | `CHAR(30)` | L9 |
| `iTotalRegistros` | `INTEGER` | L10 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_divisas` | `bdinteg` | ⚠️ sí | SELECT | L36 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L12 | CÓDIGO_RETORNO | `LET cCodRet = '00000';` |  |
| L44 | CÓDIGO_RETORNO | `LET cCodRet= '00017';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `cont` | PREFIJO | familia contabilidad | 🔵 CONVENCIÓN | nombre_sp |
| `divisas` | ENTIDAD | divisas | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `b4` | MODIF | sufijo de versión de SP (Bloque/Build 4) | 🟡 INFERIDO | nombre_sp |

---

## `sp_cont_empresasb3`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_sp_cont_empresasb3.sql` |
| **LOC (1er CREATE)** | 66 |
| **Callgraph** | ✅ fan_in=0 / fan_out=55 |
| **Deps concatenadas** | 16 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "empresas (sufijo de versión de SP)" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 1 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=2 · INFERIDO=1 · SINTÉTICO=0 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_cont_empresasb3(
  pBandera                     CHAR(1)
) RETURNING CHAR(5) AS codret,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pBandera` | `CHAR(1)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(5)` | L6 |
| `ISqlErr` | `INTEGER` | L7 |
| `cEmpresa` | `CHAR(3)` | L8 |
| `cRazon_social` | `CHAR(30)` | L9 |
| `iTotalRegistros` | `INTEGER` | L10 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_empresas` | `bdinteg` | ⚠️ sí | SELECT | L40 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L12 | CÓDIGO_RETORNO | `LET cCodRet = '00000';` |  |
| L26 | CÓDIGO_RETORNO | `LET cCodRet = '00003';` |  |
| L52 | CÓDIGO_RETORNO | `LET cCodRet = '00017';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `cont` | PREFIJO | familia contabilidad | 🔵 CONVENCIÓN | nombre_sp |
| `empresas` | ENTIDAD | empresas (nómina empresarial) | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `b3` | MODIF | sufijo de versión de SP (Bloque/Build 3) — patrón Informix:  | 🟡 INFERIDO | nombre_sp |

---

## `sp_cont_productotransaccionb5`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_sp_cont_productotransaccionb5.sql` |
| **LOC (1er CREATE)** | 298 |
| **Callgraph** | ✅ fan_in=0 / fan_out=72 |
| **Deps concatenadas** | 20 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "producto-transacción (sufijo de versión de SP)" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 9 llamada(s): `sp_registractualizacelulascclb5`, `sp_ris_actualizainsertaprodtransaccionb5`, `sp_ris_consultacriteriostransaccionesb5` |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=0 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_cont_productotransaccionb5(
  pBandera                     CHAR(2)
  pSbandera                    CHAR(1)
  pEmpleado                    CHAR(8)
  pNombre                      CHAR(104)
  pStatus                      CHAR(1)
  pFuncion                     SMALLINT
  pCedula                      SMALLINT
  pTipo                        SMALLINT
  pFuncionAnt                  SMALLINT
  pCedulaAnt                   SMALLINT
  pStatusAnt                   SMALLINT
  pCccmayor                    CHAR(10)
  pCccsub                      CHAR(10)
  pCccsubsub                   CHAR(10)
  pCccsssub                    CHAR(10)
  pCccssssub                   CHAR(10)
  pCsector                     CHAR(10)
  pAccmayor                    CHAR(10)
  pAccsub                      CHAR(10)
  pAccsubsub                   CHAR(10)
  pAccsssub                    CHAR(10)
  pAccssssub                   CHAR(10)
  pAsector                     CHAR(10)
  pSistema                     CHAR(10)
  pSecuencia                   CHAR(10)
  pTransaccion                 CHAR(10)
  pProducto                    CHAR(10)
  pDescripcion                 CHAR(50)
) RETURNING CHAR(5)   AS Cod_Retorno,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pBandera` | `CHAR(2)` | — | — |
| `pSbandera` | `CHAR(1)` | — | — |
| `pEmpleado` | `CHAR(8)` | — | — |
| `pNombre` | `CHAR(104)` | — | — |
| `pStatus` | `CHAR(1)` | — | — |
| `pFuncion` | `SMALLINT` | — | — |
| `pCedula` | `SMALLINT` | — | — |
| `pTipo` | `SMALLINT` | — | — |
| `pFuncionAnt` | `SMALLINT` | — | — |
| `pCedulaAnt` | `SMALLINT` | — | — |
| `pStatusAnt` | `SMALLINT` | — | — |
| `pCccmayor` | `CHAR(10)` | — | — |
| `pCccsub` | `CHAR(10)` | — | — |
| `pCccsubsub` | `CHAR(10)` | — | — |
| `pCccsssub` | `CHAR(10)` | — | — |
| `pCccssssub` | `CHAR(10)` | — | — |
| `pCsector` | `CHAR(10)` | — | — |
| `pAccmayor` | `CHAR(10)` | — | — |
| `pAccsub` | `CHAR(10)` | — | — |
| `pAccsubsub` | `CHAR(10)` | — | — |
| `pAccsssub` | `CHAR(10)` | — | — |
| `pAccssssub` | `CHAR(10)` | — | — |
| `pAsector` | `CHAR(10)` | — | — |
| `pSistema` | `CHAR(10)` | — | — |
| `pSecuencia` | `CHAR(10)` | — | — |
| `pTransaccion` | `CHAR(10)` | — | — |
| `pProducto` | `CHAR(10)` | — | — |
| `pDescripcion` | `CHAR(50)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `scod_ret` | `CHAR(5)` | L75 |
| `vsqlerr` | `INTEGER` | L76 |
| `cDato1` | `CHAR(100)` | L77 |
| `cDato2_2` | `CHAR(100)` | L78 |
| `cDato3` | `CHAR(100)` | L79 |
| `cDato4` | `CHAR(10)` | L80 |
| `cDato5` | `CHAR(10)` | L81 |
| `cDato6` | `CHAR(10)` | L82 |
| `cDato7` | `CHAR(10)` | L83 |
| `cDato8` | `CHAR(10)` | L84 |
| `cDato9` | `CHAR(10)` | L85 |
| `cDato10` | `CHAR(10)` | L86 |
| `cDato11` | `CHAR(10)` | L87 |
| `cDato12` | `CHAR(10)` | L88 |
| `cDato13` | `CHAR(10)` | L89 |
| `cDato14` | `CHAR(10)` | L90 |
| `cDato15` | `CHAR(10)` | L91 |
| `cDato16` | `CHAR(10)` | L92 |
| `cCodigo` | `CHAR(10)` | L93 |
| `cDescProd` | `CHAR(200)` | L94 |
| `cDescripcion` | `CHAR(35)` | L95 |
| `cSistema` | `CHAR(3)` | L96 |
| `cProducto` | `CHAR(4)` | L97 |
| `cTransaccion` | `CHAR(4)` | L98 |
| `cDescTran` | `CHAR(50)` | L99 |
| *…16 más…* | | |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_registractualizacelulascclb5` | `bdicnweb` | ⚠️ sí | L201 |
| `sp_ris_actualizainsertaprodtransaccionb5` | `bdicnweb` | ⚠️ sí | L204 |
| `sp_ris_consultacriteriostransaccionesb5` | `bdicnweb` | ⚠️ sí | L212 |
| `sp_ris_consultaprodtransaccionb5` | `bdicnweb` | ⚠️ sí | L227 |
| `sp_ris_consultaproductosb5` | `bdicnweb` | ⚠️ sí | L239 |
| `sp_ris_consultasistemasb5` | `bdicnweb` | ⚠️ sí | L248 |
| `sp_ris_consultatransaccionb5` | `bdicnweb` | ⚠️ sí | L255 |
| `sp_ris_consultatransaccionesb5` | `bdicnweb` | ⚠️ sí | L260 |
| `sp_ris_consultacatalogo` | `bdicnweb` | ⚠️ sí | L269 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `cont` | PREFIJO | familia contabilidad | 🔵 CONVENCIÓN | nombre_sp |
| `productotransaccion` | ENTIDAD | producto-transacción | 🔵 CONVENCIÓN | nombre_sp |
| `b5` | MODIF | sufijo de versión de SP (Bloque/Build 5) | ✅ CÓDIGO | nombre_sp, texto_cuerpo |

---

## `sp_cont_tipocambiob5`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_sp_cont_tipocambiob5.sql` |
| **LOC (1er CREATE)** | 308 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 1 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "cambio (tipo de, sufijo de versión de SP)" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 12 llamada(s): `sp_catalogodivisa`, `sp_catalogomercado`, `sp_consgeneralfechas` |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=3 · INFERIDO=1 · SINTÉTICO=0 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_cont_tipocambiob5(
  pBandera                     CHAR(2)
  pUsuario                     CHAR(8)
  pIdFuncion                   CHAR(10)
  pIdConsulta                  CHAR(1)
  pClaveTpCambio               CHAR(3)
  pRegistros                   INTEGER
  pRecuperacion                INTEGER
  pRowId                       INTEGER
  pCveMercado                  CHAR(1)
  pDivisa                      CHAR(2)
  pFechaTpC                    DATE
  pPrecioCpa                   DECIMAL(14,6)
  pPrecioVta                   DECIMAL(14,6)
  pPrecioVtaA                  DECIMAL(14,6)
  pTipoCpaMnDiv                DECIMAL(14,6)
  pTipoVtaMnDiv                DECIMAL(14,6)
  pVariacionVta                DECIMAL(9,7)
  pVariacion_cpa               DECIMAL(9,7)
  pTipo_cpa_mn_dll             DECIMAL(14,6)
  pTipo_cpa_div_dll            DECIMAL(14,6)
  pTipo_cpa_mn_div             DECIMAL(14,6)
  pPc_abajo                    DECIMAL(14,6)
  pPc_arriba                   DECIMAL(14,6)
  pPrecio_compra               DECIMAL(14,6)
  pPv_abajo                    DECIMAL(14,6)
  pVariacion_vta               DECIMAL(9,7)
  pTipo_vta_div_dll            DECIMAL(14,6)
  pTipo_vta_mn_dll             DECIMAL(14,6)
  pTipo_vta_mn_div             DECIMAL(14,6)
  pPrecio_venta                DECIMAL(14,6)
  pPv_arriba                   DECIMAL(14,6)
  pFecha_tpcambio              DATE
  pClase_tpcambio              CHAR(1)
  pIdOperacion                 CHAR(1)
  pFecha                       DATE
) RETURNING CHAR(5) AS codret,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pBandera` | `CHAR(2)` | — | — |
| `pUsuario` | `CHAR(8)` | — | — |
| `pIdFuncion` | `CHAR(10)` | — | — |
| `pIdConsulta` | `CHAR(1)` | — | — |
| `pClaveTpCambio` | `CHAR(3)` | `cambio`=cambio (de estatus, domicilio, etc.) | ✅ CÓDIGO |
| `pRegistros` | `INTEGER` | — | — |
| `pRecuperacion` | `INTEGER` | — | — |
| `pRowId` | `INTEGER` | — | — |
| `pCveMercado` | `CHAR(1)` | — | — |
| `pDivisa` | `CHAR(2)` | — | — |
| `pFechaTpC` | `DATE` | — | — |
| `pPrecioCpa` | `DECIMAL(14,6)` | — | — |
| `pPrecioVta` | `DECIMAL(14,6)` | — | — |
| `pPrecioVtaA` | `DECIMAL(14,6)` | — | — |
| `pTipoCpaMnDiv` | `DECIMAL(14,6)` | `tipo`=tipo de | 🔵 CONVENCIÓN |
| `pTipoVtaMnDiv` | `DECIMAL(14,6)` | `tipo`=tipo de | 🔵 CONVENCIÓN |
| `pVariacionVta` | `DECIMAL(9,7)` | — | — |
| `pVariacion_cpa` | `DECIMAL(9,7)` | — | — |
| `pTipo_cpa_mn_dll` | `DECIMAL(14,6)` | `tipo`=tipo de | 🔵 CONVENCIÓN |
| `pTipo_cpa_div_dll` | `DECIMAL(14,6)` | `tipo`=tipo de | 🔵 CONVENCIÓN |
| `pTipo_cpa_mn_div` | `DECIMAL(14,6)` | `tipo`=tipo de | 🔵 CONVENCIÓN |
| `pPc_abajo` | `DECIMAL(14,6)` | — | — |
| `pPc_arriba` | `DECIMAL(14,6)` | — | — |
| `pPrecio_compra` | `DECIMAL(14,6)` | — | — |
| `pPv_abajo` | `DECIMAL(14,6)` | — | — |
| `pVariacion_vta` | `DECIMAL(9,7)` | — | — |
| `pTipo_vta_div_dll` | `DECIMAL(14,6)` | `tipo`=tipo de | 🔵 CONVENCIÓN |
| `pTipo_vta_mn_dll` | `DECIMAL(14,6)` | `tipo`=tipo de | 🔵 CONVENCIÓN |
| `pTipo_vta_mn_div` | `DECIMAL(14,6)` | `tipo`=tipo de | 🔵 CONVENCIÓN |
| `pPrecio_venta` | `DECIMAL(14,6)` | — | — |
| `pPv_arriba` | `DECIMAL(14,6)` | — | — |
| `pFecha_tpcambio` | `DATE` | `cambio`=cambio (de estatus, domicilio, etc.) | ✅ CÓDIGO |
| `pClase_tpcambio` | `CHAR(1)` | `cambio`=cambio (de estatus, domicilio, etc.) | ✅ CÓDIGO |
| `pIdOperacion` | `CHAR(1)` | — | — |
| `pFecha` | `DATE` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(5)` | L44 |
| `iSqlErr` | `INTEGER` | L45 |
| `cEmpresa` | `CHAR(3)` | L47 |
| `cClave` | `CHAR(3)` | L48 |
| `cDescripcion` | `CHAR(30)` | L49 |
| `cDivisa` | `CHAR(2)` | L50 |
| `dFechaHoy` | `DATE` | L52 |
| `dFechaAnt` | `DATE` | L53 |
| `dProxFecha` | `DATE` | L54 |
| `iRowid` | `INTEGER` | L56 |
| `cCveIntl` | `CHAR(3)` | L57 |
| `dFecha_tpcambio` | `DATE` | L58 |
| `cClase_tpcambio` | `CHAR(1)` | L59 |
| `dPrecio_compra` | `DECIMAL(14,6)` | L60 |
| `dPrecio_venta` | `DECIMAL(14,6)` | L61 |
| `dTipo_cpa_div_dll` | `DECIMAL(14,6)` | L62 |
| `dTipo_cpa_mn_div` | `DECIMAL(14,6)` | L63 |
| `dTipo_vta_div_dll` | `DECIMAL(14,6)` | L64 |
| `dTipo_vta_mn_div` | `DECIMAL(14,6)` | L65 |
| `iTotalRegistros` | `INTEGER` | L66 |
| `dPc_arriba` | `DECIMAL(14,6)` | L68 |
| `dPc_abajo` | `DECIMAL(14,6)` | L69 |
| `dPv_abajo` | `DECIMAL(14,6)` | L70 |
| `dPv_arriba` | `DECIMAL(14,6)` | L71 |
| `dVariacion_cpa` | `DECIMAL(9,7)` | L72 |
| *…9 más…* | | |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_catalogodivisa` | `bdicnweb` | ⚠️ sí | L156 |
| `sp_catalogomercado` | `bdicnweb` | ⚠️ sí | L168 |
| `sp_consgeneralfechas` | `bdicnweb` | ⚠️ sí | L178 |
| `sp_consultatabulartiposcambio` | `bdicnweb` | ⚠️ sí | L188 |
| `sp_consultatabulartiposcambio_totales` | `bdicnweb` | ⚠️ sí | L200 |
| `sp_consultatiposcambio` | `bdicnweb` | ⚠️ sí | L211 |
| `sp_insertatipocambio` | `bdicnweb` | ⚠️ sí | L223 |
| `sp_operaciones_encabezadotipocambio` | `bdicnweb` | ⚠️ sí | L234 |
| `sp_operacionestipocambio_actualiza_mercado` | `bdicnweb` | ⚠️ sí | L244 |
| `sp_reportetipocambio` | `bdicnweb` | ⚠️ sí | L254 |
| `sp_respaldohistoricotpcambio` | `bdicnweb` | ⚠️ sí | L267 |
| `sp_validaejecucion` | `bdicnweb` | ⚠️ sí | L277 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L86 | CÓDIGO_RETORNO | `LET cCodRet = '00000';` |  |
| L144 | CÓDIGO_RETORNO | `LET cCodRet = '00003';` |  |
| L287 | CÓDIGO_RETORNO | `LET cCodRet= '00017';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `cont` | PREFIJO | familia contabilidad | 🔵 CONVENCIÓN | nombre_sp |
| `tipo` | MODIF | tipo de | 🔵 CONVENCIÓN | nombre_sp |
| `cambio` | ENTIDAD | cambio (de estatus, domicilio, etc.) | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `b5` | MODIF | sufijo de versión de SP (Bloque/Build 5) | 🟡 INFERIDO | nombre_sp |

---

## `sp_datosdiahoy_cod47_2`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_sp_datosdiahoy_cod47_2.sql` |
| **LOC (1er CREATE)** | 91 |
| **Callgraph** | ✅ fan_in=16 / fan_out=7 |
| **Deps concatenadas** | 4 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "datos del día y código (de hoy)" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 2 llamada(s): `bdinteg`, `bditef` |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=1 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_datosdiahoy_cod47_2(
  pUsuario                     CHAR(8)
  pIdFuncion                   CHAR(10)
) RETURNING CHAR(5) AS codret,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pUsuario` | `CHAR(8)` | — | — |
| `pIdFuncion` | `CHAR(10)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(5)` | L8 |
| `cCodRetSp` | `CHAR(6)` | L9 |
| `iSqlErr` | `INTEGER` | L10 |
| `cEmpresa` | `CHAR(3)` | L11 |
| `dFecha` | `DATE` | L12 |
| `cNoBanco` | `CHAR(3)` | L13 |
| `cNombreArchivo` | `CHAR(30)` | L14 |
| `iNombrePro` | `INTEGER` | L15 |
| `cProcesado` | `CHAR(1)` | L16 |
| `dFechaHabilAnt` | `DATE` | L17 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_param` | `bdinteg` | ⚠️ sí | SELECT | L67 |
| `cce_encabezado` | `bditef` | ⚠️ sí | SELECT | L73 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `bdinteg` | `bdicont` | no | L47 |
| `bditef` | `bdicont` | no | L56 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L19 | CÓDIGO_RETORNO | `LET cCodRet = '00000';` |  |
| L41 | CÓDIGO_RETORNO | `LET cCodRet = '00003';` |  |
| L60 | EXCEPCIÓN | `RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIï¿½?N DEL SP bditef:cal_habil_ant';` |  |
| L62 | CÓDIGO_RETORNO | `LET cCodRet = '00003';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `datosdia` | ENTIDAD | datos del día | 🔵 CONVENCIÓN | nombre_sp |
| `hoy` | MODIF | de hoy / fecha actual | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `cod` | ENTIDAD | código | 🔵 CONVENCIÓN | nombre_sp |
| `?47_2` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?47_2` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_del_libromayor`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_sp_del_libromayor.sql` |
| **LOC (1er CREATE)** | 89 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "libro mayor y mayor contable" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 1 llamada(s): `sp_upd_co_auxiliar` |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=2 · INFERIDO=1 · SINTÉTICO=1 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_del_libromayor(
)
```

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `r_codret` | `CHAR(5)` | L3 |
| `r_mensaje` | `VARCHAR(255)` | L4 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `statistics` | `bdicont` | no | UPDATE | L49 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_upd_co_auxiliar` | `bdicont` | no | L87 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `?_del_` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `libro` | ENTIDAD | libro mayor / libro contable — general ledger (libromayor_di | 🔵 CONVENCIÓN | nombre_sp |
| `mayor` | ENTIDAD | mayor contable | 🟡 INFERIDO | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_del_` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_gen_devob3`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_sp_gen_devob3.sql` |
| **LOC (1er CREATE)** | 234 |
| **Callgraph** | ✅ fan_in=0 / fan_out=55 |
| **Deps concatenadas** | 14 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "genera (sufijo de versión de SP)" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 6 llamada(s): `sp_actualizapagocheque`, `sp_consgeneralfechas`, `sp_consgralproximafechahabil` |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=2 · INFERIDO=2 · SINTÉTICO=1 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_gen_devob3(
  pBandera                     CHAR(2)
  pUsuario                     CHAR(8)
  pIdFuncion                   CHAR(10)
  pFecha                       DATE
  pDireccionMac                CHAR(12)
  pTipo                        CHAR(1)
  pIdCheque                    INTEGER
  pIdConsulta                  CHAR(1)
  pNombreArchivo               CHAR(22)
  pRutaDescarga                CHAR(100)
  pRegistros                   INTEGER
  pRecuperacion                INTEGER
) RETURNING CHAR(5)     AS codret,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pBandera` | `CHAR(2)` | — | — |
| `pUsuario` | `CHAR(8)` | — | — |
| `pIdFuncion` | `CHAR(10)` | — | — |
| `pFecha` | `DATE` | — | — |
| `pDireccionMac` | `CHAR(12)` | — | — |
| `pTipo` | `CHAR(1)` | — | — |
| `pIdCheque` | `INTEGER` | — | — |
| `pIdConsulta` | `CHAR(1)` | — | — |
| `pNombreArchivo` | `CHAR(22)` | — | — |
| `pRutaDescarga` | `CHAR(100)` | — | — |
| `pRegistros` | `INTEGER` | — | — |
| `pRecuperacion` | `INTEGER` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(5)` | L47 |
| `iSqlErr` | `INTEGER` | L48 |
| `dFechaHoy` | `DATE` | L49 |
| `dFechaAnt` | `DATE` | L50 |
| `dProxFecha` | `CHAR(8)` | L51 |
| `dFechaHabilProx` | `DATE` | L52 |
| `cBcoPresenta` | `CHAR(3)` | L53 |
| `cNombreBanco` | `CHAR(40)` | L54 |
| `cCuenta` | `CHAR(20)` | L55 |
| `iCheque` | `INTEGER` | L56 |
| `mImporte` | `MONEY(16,2)` | L57 |
| `cDetDatosMotivo` | `CHAR(40)` | L58 |
| `cGeneradoDev` | `CHAR(1)` | L59 |
| `cFechaTransfer` | `CHAR(8)` | L60 |
| `cImporte` | `CHAR(15)` | L61 |
| `cLoteEntrada` | `CHAR(7)` | L62 |
| `cSecEntrada` | `CHAR(4)` | L63 |
| `cLoteSalida` | `CHAR(7)` | L64 |
| `cSecSalida` | `CHAR(4)` | L65 |
| `cCveTransacc` | `CHAR(2)` | L66 |
| `cPlazaCompensa` | `CHAR(3)` | L67 |
| `cNumCuenta` | `CHAR(13)` | L68 |
| `cNumCheque` | `CHAR(10)` | L69 |
| `cDigInter` | `CHAR(1)` | L70 |
| `cDigPremar` | `CHAR(1)` | L71 |
| *…20 más…* | | |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_actualizapagocheque` | `bdicnweb` | ⚠️ sí | L168 |
| `sp_consgeneralfechas` | `bdicnweb` | ⚠️ sí | L172 |
| `sp_consgralproximafechahabil` | `bdicnweb` | ⚠️ sí | L177 |
| `sp_consultadetallechequesdev` | `bdicnweb` | ⚠️ sí | L182 |
| `sp_consultadetallechequesdev_totales` | `bdicnweb` | ⚠️ sí | L197 |
| `sp_genarchivodevoluciones` | `bdicnweb` | ⚠️ sí | L201 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L95 | CÓDIGO_RETORNO | `LET cCodRet                     = '00000';` |  |
| L153 | CÓDIGO_RETORNO | `LET cCodRet = '00003';` |  |
| L214 | CÓDIGO_RETORNO | `LET cCodRet = '00017';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `gen` | ACCION | genera / general | 🟡 INFERIDO | nombre_sp |
| `dev` | ACCION | devolución | 🔵 CONVENCIÓN | nombre_sp |
| `?o` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `b3` | MODIF | sufijo de versión de SP (Bloque/Build 3) — patrón Informix:  | 🟡 INFERIDO | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?o` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_generarbalanzadiariaconsolidadamn`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_sp_generarbalanzadiariaconsolidadamn.sql` |
| **LOC (1er CREATE)** | 623 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "generar balanza de comprobación — trial balance (del día, consolidada)" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `genera` → `INSERT` encontrado en el cuerpo · `genera` → `SELECT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=3 · CONVENCIÓN=1 · INFERIDO=1 · SINTÉTICO=2 / 7 términos |

### Firma

```sql
CREATE PROCEDURE sp_generarbalanzadiariaconsolidadamn(
  p_dFecha                     DATE
) RETURNING CHAR(5) AS retorno, VARCHAR(255) AS mensaje
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_dFecha` | `DATE` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `bpccmayor` | `CHAR(10)` | L4 |
| `bpccsub` | `CHAR(10)` | L5 |
| `bpccsubsub` | `CHAR(10)` | L6 |
| `bpccssubsub` | `CHAR(10)` | L7 |
| `bpccsssubsub` | `CHAR(10)` | L8 |
| `bpsector` | `CHAR(10)` | L9 |
| `v_mayor` | `CHAR(10)` | L11 |
| `v_mayor1` | `CHAR(1)` | L12 |
| `v_mayor2` | `CHAR(10)` | L13 |
| `w_cuantos` | `INTEGER` | L14 |
| `v_len_may` | `SMALLINT` | L16 |
| `v_len_s` | `SMALLINT` | L17 |
| `v_len_ss` | `SMALLINT` | L18 |
| `v_len_sss` | `SMALLINT` | L19 |
| `v_len_ssss` | `SMALLINT` | L20 |
| `v_len_sect` | `SMALLINT` | L21 |
| `i` | `SMALLINT` | L22 |
| `v_cero_may` | `CHAR(10)` | L24 |
| `v_cero_s` | `CHAR(10)` | L25 |
| `v_cero_ss` | `CHAR(10)` | L26 |
| `v_cero_sss` | `CHAR(10)` | L27 |
| `v_cero_ssss` | `CHAR(10)` | L28 |
| `v_cero_sect` | `CHAR(10)` | L29 |
| `v_cero_may_1` | `CHAR(10)` | L30 |
| `v_cero_may_2` | `CHAR(10)` | L31 |
| *…11 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `bi_balanza_dmn` | `bdicont` | no | SELECT | L83 |
| `bi_balanza_dmn` | `bdicont` | no | DELETE | L83 |
| `si_fechas` | `bdinteg` | ⚠️ sí | SELECT | L87 |
| `co_fechas` | `bdicont` | no | SELECT | L90 |
| `co_cierre_cif` | `bdicont` | no | SELECT | L96 |
| `bi_balanza_dmn` | `bdicont` | no | INSERT | L106 |
| `co_sdodias` | `bdicont` | no | SELECT | L114 |
| `co_histsdodias` | `bdicont` | no | SELECT | L136 |
| `co_param` | `bdicont` | no | SELECT | L152 |
| `si_catalog` | `bdinteg` | ⚠️ sí | SELECT | L587 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `generar` | ACCION | generar (infinitivo — sp_generarbalanza*) | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `balanza` | ENTIDAD | balanza de comprobación — trial balance (sp_generarbalanza*  | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `dia` | MODIF | del día | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?ria` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `consolidada` | MODIF | consolidada / consolidado — cifras consolidadas (balanza dia | 🟡 INFERIDO | nombre_sp |
| `?mn` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?ria`, `?mn` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_generarbalanzadiariaconsolidadamx`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_sp_generarbalanzadiariaconsolidadamx.sql` |
| **LOC (1er CREATE)** | 638 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "generar balanza de comprobación — trial balance (del día, consolidada)" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `genera` → `INSERT` encontrado en el cuerpo · `genera` → `SELECT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=4 · CONVENCIÓN=1 · INFERIDO=1 · SINTÉTICO=2 / 8 términos |

### Firma

```sql
CREATE PROCEDURE sp_generarbalanzadiariaconsolidadamx(
  p_dFecha                     DATE
) RETURNING CHAR(5) AS retorno, VARCHAR(255) AS mensaje
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_dFecha` | `DATE` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `bpccmayor` | `CHAR(10)` | L4 |
| `bpccsub` | `CHAR(10)` | L5 |
| `bpccsubsub` | `CHAR(10)` | L6 |
| `bpccssubsub` | `CHAR(10)` | L7 |
| `bpccsssubsub` | `CHAR(10)` | L8 |
| `bpsector` | `CHAR(10)` | L9 |
| `v_mayor` | `CHAR(10)` | L11 |
| `v_mayor1` | `CHAR(1)` | L12 |
| `v_mayor2` | `CHAR(10)` | L13 |
| `w_cuantos` | `INTEGER` | L14 |
| `v_len_may` | `SMALLINT` | L16 |
| `v_len_s` | `SMALLINT` | L17 |
| `v_len_ss` | `SMALLINT` | L18 |
| `v_len_sss` | `SMALLINT` | L19 |
| `v_len_ssss` | `SMALLINT` | L20 |
| `v_len_sect` | `SMALLINT` | L21 |
| `i` | `SMALLINT` | L22 |
| `v_cero_may` | `CHAR(10)` | L24 |
| `v_cero_s` | `CHAR(10)` | L25 |
| `v_cero_ss` | `CHAR(10)` | L26 |
| `v_cero_sss` | `CHAR(10)` | L27 |
| `v_cero_ssss` | `CHAR(10)` | L28 |
| `v_cero_sect` | `CHAR(10)` | L29 |
| `v_cero_may_1` | `CHAR(10)` | L30 |
| `v_cero_may_2` | `CHAR(10)` | L31 |
| *…18 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `bi_balanza_dme` | `bdicont` | no | SELECT | L90 |
| `bi_balanza_dme` | `bdicont` | no | DELETE | L90 |
| `si_fechas` | `bdinteg` | ⚠️ sí | SELECT | L94 |
| `co_fechas` | `bdicont` | no | SELECT | L97 |
| `co_cierre_cif` | `bdicont` | no | SELECT | L103 |
| `sp_preciocontable` | `bdirepaut` | ⚠️ sí | SELECT | L109 |
| `bi_balanza_dme` | `bdicont` | no | INSERT | L122 |
| `co_sdodias` | `bdicont` | no | SELECT | L130 |
| `co_histsdodias` | `bdicont` | no | SELECT | L152 |
| `co_param` | `bdicont` | no | SELECT | L168 |
| `si_catalog` | `bdinteg` | ⚠️ sí | SELECT | L602 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L112 | VALIDACIÓN_NULL | `IF v_tpc IS NULL THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `generar` | ACCION | generar (infinitivo — sp_generarbalanza*) | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `balanza` | ENTIDAD | balanza de comprobación — trial balance (sp_generarbalanza*  | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `dia` | MODIF | del día | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?ria` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `consolidada` | MODIF | consolidada / consolidado — cifras consolidadas (balanza dia | 🟡 INFERIDO | nombre_sp |
| `?m` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `x` | MODIF | por (criterio) | 🔵 CONVENCIÓN | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?ria`, `?m` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_generarbalanzamensualconsolidadamn`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_sp_generarbalanzamensualconsolidadamn.sql` |
| **LOC (1er CREATE)** | 605 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "generar balanza de comprobación — trial balance (mensual, consolidada)" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `genera` → `INSERT` encontrado en el cuerpo · `genera` → `SELECT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=2 · INFERIDO=1 · SINTÉTICO=1 / 6 términos |

### Firma

```sql
CREATE PROCEDURE sp_generarbalanzamensualconsolidadamn(
  p_dFecha                     DATE
) RETURNING CHAR(5) AS retorno, VARCHAR(255) AS mensaje
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_dFecha` | `DATE` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `bpccmayor` | `CHAR(10)` | L4 |
| `bpccsub` | `CHAR(10)` | L5 |
| `bpccsubsub` | `CHAR(10)` | L6 |
| `bpccssubsub` | `CHAR(10)` | L7 |
| `bpccsssubsub` | `CHAR(10)` | L8 |
| `bpsector` | `CHAR(10)` | L9 |
| `v_mayor` | `CHAR(10)` | L11 |
| `v_mayor1` | `CHAR(1)` | L12 |
| `v_mayor2` | `CHAR(10)` | L13 |
| `w_cuantos` | `INTEGER` | L14 |
| `v_len_may` | `SMALLINT` | L16 |
| `v_len_s` | `SMALLINT` | L17 |
| `v_len_ss` | `SMALLINT` | L18 |
| `v_len_sss` | `SMALLINT` | L19 |
| `v_len_ssss` | `SMALLINT` | L20 |
| `v_len_sect` | `SMALLINT` | L21 |
| `i` | `SMALLINT` | L22 |
| `v_cero_may` | `CHAR(10)` | L24 |
| `v_cero_s` | `CHAR(10)` | L25 |
| `v_cero_ss` | `CHAR(10)` | L26 |
| `v_cero_sss` | `CHAR(10)` | L27 |
| `v_cero_ssss` | `CHAR(10)` | L28 |
| `v_cero_sect` | `CHAR(10)` | L29 |
| `v_cero_may_1` | `CHAR(10)` | L30 |
| `v_cero_may_2` | `CHAR(10)` | L31 |
| *…13 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `bi_balanza_mmn` | `bdicont` | no | SELECT | L85 |
| `bi_balanza_mmn` | `bdicont` | no | DELETE | L85 |
| `si_fechas` | `bdinteg` | ⚠️ sí | SELECT | L89 |
| `co_fechas` | `bdicont` | no | SELECT | L92 |
| `co_cierre_cif` | `bdicont` | no | SELECT | L100 |
| `bi_balanza_mmn` | `bdicont` | no | INSERT | L107 |
| `co_sdomes` | `bdicont` | no | SELECT | L115 |
| `co_param` | `bdicont` | no | SELECT | L140 |
| `si_catalog` | `bdinteg` | ⚠️ sí | SELECT | L576 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `diasmes` | `bdicont` | no | L96 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `generar` | ACCION | generar (infinitivo — sp_generarbalanza*) | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `balanza` | ENTIDAD | balanza de comprobación — trial balance (sp_generarbalanza*  | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `mensual` | MODIF | mensual | 🔵 CONVENCIÓN | nombre_sp |
| `consolidada` | MODIF | consolidada / consolidado — cifras consolidadas (balanza dia | 🟡 INFERIDO | nombre_sp |
| `?mn` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?mn` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_generarbalanzamensualconsolidadamx`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_sp_generarbalanzamensualconsolidadamx.sql` |
| **LOC (1er CREATE)** | 620 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "generar balanza de comprobación — trial balance (mensual, consolidada)" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `genera` → `INSERT` encontrado en el cuerpo · `genera` → `SELECT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=3 · CONVENCIÓN=2 · INFERIDO=1 · SINTÉTICO=1 / 7 términos |

### Firma

```sql
CREATE PROCEDURE sp_generarbalanzamensualconsolidadamx(
  p_dFecha                     DATE
) RETURNING CHAR(5) AS retorno, VARCHAR(255) AS mensaje
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_dFecha` | `DATE` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `bpccmayor` | `CHAR(10)` | L4 |
| `bpccsub` | `CHAR(10)` | L5 |
| `bpccsubsub` | `CHAR(10)` | L6 |
| `bpccssubsub` | `CHAR(10)` | L7 |
| `bpccsssubsub` | `CHAR(10)` | L8 |
| `bpsector` | `CHAR(10)` | L9 |
| `v_mayor` | `CHAR(10)` | L11 |
| `v_mayor1` | `CHAR(1)` | L12 |
| `v_mayor2` | `CHAR(10)` | L13 |
| `w_cuantos` | `INTEGER` | L14 |
| `v_len_may` | `SMALLINT` | L16 |
| `v_len_s` | `SMALLINT` | L17 |
| `v_len_ss` | `SMALLINT` | L18 |
| `v_len_sss` | `SMALLINT` | L19 |
| `v_len_ssss` | `SMALLINT` | L20 |
| `v_len_sect` | `SMALLINT` | L21 |
| `i` | `SMALLINT` | L22 |
| `v_cero_may` | `CHAR(10)` | L24 |
| `v_cero_s` | `CHAR(10)` | L25 |
| `v_cero_ss` | `CHAR(10)` | L26 |
| `v_cero_sss` | `CHAR(10)` | L27 |
| `v_cero_ssss` | `CHAR(10)` | L28 |
| `v_cero_sect` | `CHAR(10)` | L29 |
| `v_cero_may_1` | `CHAR(10)` | L30 |
| `v_cero_may_2` | `CHAR(10)` | L31 |
| *…20 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `bi_balanza_mme` | `bdicont` | no | SELECT | L93 |
| `bi_balanza_mme` | `bdicont` | no | DELETE | L93 |
| `si_fechas` | `bdinteg` | ⚠️ sí | SELECT | L97 |
| `co_fechas` | `bdicont` | no | SELECT | L100 |
| `co_cierre_cif` | `bdicont` | no | SELECT | L108 |
| `sp_preciocontable` | `bdirepaut` | ⚠️ sí | SELECT | L114 |
| `bi_balanza_mme` | `bdicont` | no | INSERT | L124 |
| `co_sdomes` | `bdicont` | no | SELECT | L132 |
| `co_param` | `bdicont` | no | SELECT | L157 |
| `si_catalog` | `bdinteg` | ⚠️ sí | SELECT | L591 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `diasmes` | `bdicont` | no | L104 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L117 | VALIDACIÓN_NULL | `IF v_tpc IS NULL THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `generar` | ACCION | generar (infinitivo — sp_generarbalanza*) | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `balanza` | ENTIDAD | balanza de comprobación — trial balance (sp_generarbalanza*  | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `mensual` | MODIF | mensual | 🔵 CONVENCIÓN | nombre_sp |
| `consolidada` | MODIF | consolidada / consolidado — cifras consolidadas (balanza dia | 🟡 INFERIDO | nombre_sp |
| `?m` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `x` | MODIF | por (criterio) | 🔵 CONVENCIÓN | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?m` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_ins_co_archivos`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_sp_ins_co_archivos.sql` |
| **LOC (1er CREATE)** | 32 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "insertar archivos" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `inserta` → `INSERT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=1 · INFERIDO=1 · SINTÉTICO=1 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_ins_co_archivos(
  p_archivo                    VARCHAR(100)
  p_fecha                      DATE
) RETURNING CHAR(6), VARCHAR(255)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_archivo` | `VARCHAR(100)` | — | — |
| `p_fecha` | `DATE` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cVarDataErr` | `VARCHAR(64)` | L4 |
| `iSqlErr` | `INTEGER` | L5 |
| `iSamErr` | `INTEGER` | L6 |
| `cod_ret` | `CHAR(5)` | L7 |
| `v_mensaje` | `VARCHAR(255)` | L8 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `co_archivos` | `bdicont` | no | INSERT | L26 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `ins` | ACCION | insertar | 🟡 INFERIDO | nombre_sp |
| `?_co_` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `archivos` | ENTIDAD | archivos | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_co_` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_insertdetpol`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_sp_insertdetpol.sql` |
| **LOC (1er CREATE)** | 61 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "insertar detalle" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `inserta` → `INSERT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=1 · INFERIDO=2 · SINTÉTICO=2 / 5 términos |

### Historia del SP

| Tipo | Valor |
|------|-------|
| FECHA | 25/05/2009 |
| ACTIVIDAD | Insertar un registro en la tabla co_detpol, |
| MODIFICACION | Vladimir Felix Galvez |
| FECHA | 28/05/2009 |
| MODIFICACION | Agrega validación para verificar si el registro a insertar ya existe. |
| MODIFICACION | César Andrés De Anda Alcántara |
| FECHA | 17/06/2009 |

### Firma

```sql
CREATE PROCEDURE sp_insertdetpol(
  pusuario                     CHAR(8)
  pcontrolpoliza               INTEGER
  pfechacaptura                DATE
  psecuencia                   INTEGER
  pempresa                     CHAR(3)
  pccmayor                     CHAR(10)
  pccostoorig                  CHAR(4)
  pccsub                       CHAR(10)
  pccsubsub                    CHAR(10)
  pccssubsub                   CHAR(10)
  pccsssubsub                  CHAR(10)
  psector                      CHAR(10)
  pnroauxiliar                 CHAR(12)
  pciudad                      CHAR(3)
  psucursal                    CHAR(4)
  pnaturaleza                  CHAR(1)
  pmonto                       MONEY(18,2)
  pdescripciondet              CHAR(80)
  pfechavalida                 DATE
  pmoneda                      CHAR(2)
  pvalorcambio                 MONEY(12,7)
  pvalordivcambio              MONEY(12,7)
  pmcaaplic                    CHAR(1)
  ppolizausuario               CHAR(8)
  ptipomov                     CHAR(1)
) RETURNING CHAR(6)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pusuario` | `CHAR(8)` | — | — |
| `pcontrolpoliza` | `INTEGER` | — | — |
| `pfechacaptura` | `DATE` | — | — |
| `psecuencia` | `INTEGER` | — | — |
| `pempresa` | `CHAR(3)` | — | — |
| `pccmayor` | `CHAR(10)` | — | — |
| `pccostoorig` | `CHAR(4)` | — | — |
| `pccsub` | `CHAR(10)` | — | — |
| `pccsubsub` | `CHAR(10)` | — | — |
| `pccssubsub` | `CHAR(10)` | — | — |
| `pccsssubsub` | `CHAR(10)` | — | — |
| `psector` | `CHAR(10)` | — | — |
| `pnroauxiliar` | `CHAR(12)` | — | — |
| `pciudad` | `CHAR(3)` | — | — |
| `psucursal` | `CHAR(4)` | — | — |
| `pnaturaleza` | `CHAR(1)` | — | — |
| `pmonto` | `MONEY(18,2)` | — | — |
| `pdescripciondet` | `CHAR(80)` | `det`=detalle | 🟡 INFERIDO |
| `pfechavalida` | `DATE` | — | — |
| `pmoneda` | `CHAR(2)` | — | — |
| `pvalorcambio` | `MONEY(12,7)` | — | — |
| `pvalordivcambio` | `MONEY(12,7)` | — | — |
| `pmcaaplic` | `CHAR(1)` | — | — |
| `ppolizausuario` | `CHAR(8)` | — | — |
| `ptipomov` | `CHAR(1)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(6)` | L24 |
| `iSqlErr` | `INTEGER` | L25 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `co_detpol` | `bdicont` | no | SELECT | L43 |
| `co_detpol` | `bdicont` | no | INSERT | L51 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L37 | VALIDACIÓN_NULL | `IF pusuario IS NULL OR pusuario = '' OR pcontrolpoliza IS NULL OR pcontrolpoliza = ''` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `ins` | ACCION | insertar | 🟡 INFERIDO | nombre_sp |
| `?ert` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `det` | ENTIDAD | detalle | 🟡 INFERIDO | nombre_sp |
| `?pol` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?ert`, `?pol` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_manipularpol`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_sp_manipularpol.sql` |
| **LOC (1er CREATE)** | 49 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "NIP — Número de Identificación Personal" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 2 tabla(s) con operaciones: UPDATE, SELECT |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=2 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_manipularpol(
  p_inumero                    INTEGER
  p_iaccion                    INTEGER
) RETURNING CHAR(6), INTEGER
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_inumero` | `INTEGER` | — | — |
| `p_iaccion` | `INTEGER` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `sql_err` | `INTEGER` | L5 |
| `isam_err` | `INTEGER` | L6 |
| `error_info` | `CHAR(40)` | L7 |
| `cod_ret` | `CHAR(6)` | L8 |
| `v_iexiste` | `INTEGER` | L10 |
| `v_inumero` | `INTEGER` | L11 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `co_ctrlpoliza` | `bdicont` | no | SELECT | L31 |
| `co_ctrlpoliza` | `bdicont` | no | UPDATE | L36 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `?_ma` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `nip` | ENTIDAD | NIP — Número de Identificación Personal (PIN bancario) | 🔵 CONVENCIÓN | nombre_sp |
| `?ularpol` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_ma`, `?ularpol` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_monitor_cheques_propios_b3`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_sp_monitor_cheques_propios_b3.sql` |
| **LOC (1er CREATE)** | 103 |
| **Callgraph** | ✅ fan_in=0 / fan_out=32 |
| **Deps concatenadas** | 11 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "monitor, cheques y OS — Originación de Solicitudes (sufijo de versión de SP)" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 2 llamada(s): `sp_consresumenmovcheques`, `sp_consdetallemovchequespropios` |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=1 · INFERIDO=2 · SINTÉTICO=1 / 6 términos |

### Firma

```sql
CREATE PROCEDURE sp_monitor_cheques_propios_b3(
  pBandera                     CHAR(1)
  pUsuario                     CHAR(8)
  pIdFuncion                   CHAR(10)
  pRegistros                   INTEGER
  pRecuperacion                INTEGER
) RETURNING CHAR(5)     As codret,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pBandera` | `CHAR(1)` | — | — |
| `pUsuario` | `CHAR(8)` | — | — |
| `pIdFuncion` | `CHAR(10)` | — | — |
| `pRegistros` | `INTEGER` | `os`=OS — Originación de Solicitudes / subsistema de ofertas (sp_os_*, sp_calcula_estatus_os — bdisolic) | 🟡 INFERIDO |
| `pRecuperacion` | `INTEGER` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(5)` | L20 |
| `iSqlErr` | `INTEGER` | L21 |
| `iOperados` | `INTEGER` | L23 |
| `iDigitalizados` | `INTEGER` | L24 |
| `iPorRecibir` | `INTEGER` | L25 |
| `cSucursal` | `CHAR(4)` | L26 |
| `cNombreSuc` | `CHAR(40)` | L27 |
| `cCuenta` | `CHAR(20)` | L28 |
| `iNumCheque` | `INTEGER` | L29 |
| `mMonto` | `MONEY(16,2)` | L30 |
| `cFechaHora` | `CHAR(21)` | L31 |
| `cFolioSuc` | `CHAR(16)` | L32 |
| `cTransaccion` | `CHAR(4)` | L33 |
| `cDigitalizado` | `CHAR(1)` | L34 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_consresumenmovcheques` | `bdicnweb` | ⚠️ sí | L75 |
| `sp_consdetallemovchequespropios` | `bdicnweb` | ⚠️ sí | L81 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L39 | CÓDIGO_RETORNO | `LET cCodRet = '00000';` |  |
| L89 | CÓDIGO_RETORNO | `LET cCodRet = '00017';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `monitor` | ENTIDAD | monitor | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `cheques` | ENTIDAD | cheques | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?_propi` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `os` | ENTIDAD | OS — Originación de Solicitudes / subsistema de ofertas (sp_ | 🟡 INFERIDO | nombre_sp |
| `b3` | MODIF | sufijo de versión de SP (Bloque/Build 3) — patrón Informix:  | 🟡 INFERIDO | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_propi` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_obtenercc`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_sp_obtenercc.sql` |
| **LOC (1er CREATE)** | 105 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "obtiene" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `obtiene` → `SELECT` encontrado en el cuerpo · `obtiene` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=1 / 3 términos |

### Historia del SP

| Tipo | Valor |
|------|-------|
| MODIFICACION | Se cambió la firma del SP de obtenercentrocostos a |
| MODIFICACION | César Andrés De Anda Alcántara --* |
| FECHA | 17/06/2009 --* |

### Firma

```sql
CREATE PROCEDURE sp_obtenercc(
  p_empresa                    CHAR(3)
  p_usuario                    CHAR(8)
  p_cuenta                     CHAR(19)
  p_smoneda                    CHAR(2)
) RETURNING CHAR(6), CHAR(50)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_empresa` | `CHAR(3)` | — | — |
| `p_usuario` | `CHAR(8)` | — | — |
| `p_cuenta` | `CHAR(19)` | — | — |
| `p_smoneda` | `CHAR(2)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `sql_err` | `INTEGER` | L5 |
| `isam_err` | `INTEGER` | L6 |
| `error_info` | `CHAR(50)` | L7 |
| `cod_ret` | `CHAR(6)` | L8 |
| `v_ccmayor` | `CHAR(4)` | L10 |
| `v_ccsub` | `CHAR(2)` | L11 |
| `v_ccsubsub` | `CHAR(2)` | L12 |
| `v_ccssubsub` | `CHAR(2)` | L13 |
| `v_ccsssubsub` | `CHAR(2)` | L14 |
| `v_sector` | `CHAR(2)` | L15 |
| `v_sucursal` | `CHAR(4)` | L16 |
| `v_nombresucursal` | `CHAR(40)` | L17 |
| `v_ccosto_orig` | `CHAR(4)` | L18 |
| `v_cta_restringida_dest` | `CHAR(1)` | L19 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_catalog` | `bdinteg` | ⚠️ sí | SELECT | L57 |
| `si_sucursales` | `bdinteg` | ⚠️ sí | SELECT | L71 |
| `co_cta_ccdest` | `bdicont` | no | SELECT | L84 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `obtener` | ACCION | obtiene / recupera | 🔵 CONVENCIÓN | nombre_sp |
| `?cc` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?cc` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_obtenerid`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_sp_obtenerid.sql` |
| **LOC (1er CREATE)** | 28 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "obtiene identificador" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `obtiene` → `SELECT` encontrado en el cuerpo · `obtiene` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=0 / 3 términos |

### Firma

```sql
CREATE PROCEDURE sp_obtenerid(
  p_usuario                    CHAR(10)
) RETURNING INTEGER
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_usuario` | `CHAR(10)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `v_idreporte` | `INTEGER` | L5 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `co_libmadet` | `bdicont` | no | SELECT | L16 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L19 | VALIDACIÓN_NULL | `IF v_idreporte = 0 OR v_idreporte IS NULL THEN` |  |
| L22 | FÓRMULA | `LET v_idreporte = v_idreporte + 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `obtener` | ACCION | obtiene / recupera | 🔵 CONVENCIÓN | nombre_sp |
| `id` | ENTIDAD | identificador (de) | 🔵 CONVENCIÓN | nombre_sp |

---

## `sp_obtenersubcta`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_sp_obtenersubcta.sql` |
| **LOC (1er CREATE)** | 92 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "obtiene cuenta (sub-)" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `obtiene` → `SELECT` encontrado en el cuerpo · `obtiene` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=2 · INFERIDO=1 · SINTÉTICO=0 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_obtenersubcta(
  p_empresa                    CHAR(3)
  p_smoneda                    CHAR(2)
  p_cuentamayor                CHAR(4)
  p_usuario                    CHAR(8)
) RETURNING CHAR(6), CHAR(100)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_empresa` | `CHAR(3)` | — | — |
| `p_smoneda` | `CHAR(2)` | — | — |
| `p_cuentamayor` | `CHAR(4)` | — | — |
| `p_usuario` | `CHAR(8)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `sql_err` | `INTEGER` | L5 |
| `isam_err` | `INTEGER` | L6 |
| `error_info` | `CHAR(100)` | L7 |
| `cod_ret` | `CHAR(6)` | L8 |
| `v_cnombre` | `CHAR(50)` | L10 |
| `v_ccsub` | `CHAR(2)` | L11 |
| `v_ccsubsub` | `CHAR(2)` | L12 |
| `v_ccssubsub` | `CHAR(2)` | L13 |
| `v_ccsssubsub` | `CHAR(2)` | L14 |
| `v_sector` | `CHAR(2)` | L15 |
| `v_sucursal` | `CHAR(4)` | L16 |
| `v_subcuenta` | `CHAR(100)` | L17 |
| `v_ccosto_orig` | `CHAR(4)` | L19 |
| `v_cta_restringida_orig` | `CHAR(1)` | L20 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_ejecut` | `bdinteg` | ⚠️ sí | SELECT | L62 |
| `si_catalog` | `bdinteg` | ⚠️ sí | SELECT | L69 |
| `co_cta_ccorig` | `bdicont` | no | SELECT | L81 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L77 | FÓRMULA | `LET v_subcuenta = v_ccsub\|\|'-'\|\|v_ccsubsub\|\|'-'\|\|v_ccssubsub\|\|'-'\|\|v_ccsssubsub\|\|'-'\|` |  |
| L85 | FÓRMULA | `LET v_subcuenta = v_ccsub\|\|'-'\|\|v_ccsubsub\|\|'-'\|\|v_ccssubsub\|\|'-'\|\|v_ccsssubsub\|\|'-'\|` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `obtener` | ACCION | obtiene / recupera | 🔵 CONVENCIÓN | nombre_sp |
| `sub` | MODIF | sub- | 🟡 INFERIDO | nombre_sp |
| `cta` | ENTIDAD | cuenta | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |

---

## `sp_ope_catalogomotivos2`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_sp_ope_catalogomotivos2.sql` |
| **LOC (1er CREATE)** | 61 |
| **Callgraph** | ✅ fan_in=16 / fan_out=8 |
| **Deps concatenadas** | 5 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "operación catálogo y motivo" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 2 llamada(s): `sp_cnsif_confirmaejecutivo`, `sp_consultadevcam` |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=2 · INFERIDO=1 · SINTÉTICO=1 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_ope_catalogomotivos2(
  pUsuario                     CHAR(8)
  pIdFuncion                   CHAR(10)
) RETURNING CHAR(5) AS codret,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pUsuario` | `CHAR(8)` | — | — |
| `pIdFuncion` | `CHAR(10)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(5)` | L7 |
| `iSqlErr` | `INTEGER` | L8 |
| `cCodRetSp` | `CHAR(5)` | L9 |
| `iCodRetSp` | `INTEGER` | L10 |
| `cCodigo` | `CHAR(2)` | L11 |
| `cDescripcion` | `CHAR(35)` | L12 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_cnsif_confirmaejecutivo` | `bdinteg` | ⚠️ sí | L37 |
| `sp_consultadevcam` | `bdinteg` | ⚠️ sí | L42 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L14 | CÓDIGO_RETORNO | `LET cCodRet = '00000';` |  |
| L32 | CÓDIGO_RETORNO | `LET cCodRet = '00003';` |  |
| L46 | EXCEPCIÓN | `RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP sp_consultadevcam';` |  |
| L48 | CÓDIGO_RETORNO | `LET cCodRet = '00017';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `ope` | ACCION | operación | 🟡 INFERIDO | nombre_sp |
| `catalogo` | ENTIDAD | catálogo | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `motivo` | ENTIDAD | motivo / causa | 🔵 CONVENCIÓN | nombre_sp |
| `?s2` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?s2` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_repconcilia`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_sp_repconcilia.sql` |
| **LOC (1er CREATE)** | 215 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "reporte" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 1 llamada(s): `sp_buscatemporal` |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=0 / 3 términos |

### Firma

```sql
CREATE PROCEDURE sp_repconcilia(
  pEmpresa                     CHAR(3)
) RETURNING CHAR(5),   CHAR(10),     CHAR(16),
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pEmpresa` | `CHAR(3)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `v_CodRet` | `CHAR(5)` | L19 |
| `vsqlerr` | `INTEGER` | L20 |
| `v_vt_folio` | `CHAR(16)` | L21 |
| `v_vt_transacc` | `CHAR(60)` | L22 |
| `v_vtmonto` | `MONEY(14,2)` | L23 |
| `v_vt_usuario` | `CHAR(20)` | L24 |
| `v_vt_naturaleza` | `CHAR(1)` | L25 |
| `v_vt_status` | `CHAR(30)` | L26 |
| `v_nro_cuenta` | `CHAR(20)` | L27 |
| `v_importe` | `MONEY(14,2)` | L28 |
| `vdiferencia` | `MONEY(14,2)` | L29 |
| `v_folio` | `CHAR(16)` | L30 |
| `vSucnro_cuenta` | `char(20)` | L31 |
| `v_transaccion` | `CHAR(60)` | L32 |
| `v_naturaleza` | `CHAR(1)` | L33 |
| `v_estado` | `CHAR(30)` | L34 |
| `v_Comodin` | `VARCHAR(60)` | L35 |
| `v_Cuantos` | `integer` | L36 |
| `vBandera` | `CHAR(10)` | L37 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tmp_central_concilia` | `bdicont` | no | SELECT | L92 |
| `tmp_suc_concilia` | `bdicont` | no | SELECT | L98 |
| `tmp_rconciliasucursal` | `bdicont` | no | INSERT | L119 |
| `tmp_rconciliacentral` | `bdicont` | no | INSERT | L136 |
| `tmp_rconciliacentral` | `bdicont` | no | SELECT | L184 |
| `tmp_rconciliasucursal` | `bdicont` | no | SELECT | L203 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_buscatemporal` | `bdicont` | no | L75 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L117 | FÓRMULA | `LET vdiferencia = v_importe - v_vtmonto;` | 🔴 MONEY/aritmética financiera |
| L154 | FÓRMULA | `LET vdiferencia = v_vtmonto - v_importe;` | 🔴 MONEY/aritmética financiera |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `rep` | ACCION | reporte | 🔵 CONVENCIÓN | nombre_sp |
| `concilia` | ACCION | conciliación | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |

---

## `sp_riesgobalanza`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_sp_riesgobalanza.sql` |
| **LOC (1er CREATE)** | 1203 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "balanza de comprobación — trial balance" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 7 tabla(s) con operaciones: SELECT, INSERT |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=1 / 3 términos |

### Firma

```sql
CREATE PROCEDURE sp_riesgobalanza(
  pempresa                     char(3)
  p_val                        char(2)
  w_fecha                      date
  p_ext                        char(2)
)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pempresa` | `char(3)` | — | — |
| `p_val` | `char(2)` | — | — |
| `w_fecha` | `date` | — | — |
| `p_ext` | `char(2)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `bpempresa` | `char(3)` | L3 |
| `bpccmayor` | `char(10)` | L4 |
| `bpccsub` | `char(10)` | L5 |
| `bpccsubsub` | `char(10)` | L6 |
| `bpccssubsub` | `char(10)` | L7 |
| `bpccsssubsub` | `char(10)` | L8 |
| `bpsector` | `char(10)` | L9 |
| `bpciudad` | `char(3)` | L10 |
| `bpsucursal` | `char(4)` | L11 |
| `bpmoneda` | `char(2)` | L12 |
| `bpmes_dia` | `char(10)` | L13 |
| `bpsaldo_dia_anterior` | `money(18,2)` | L14 |
| `bpcargos_dia` | `money(18,2)` | L15 |
| `bpabonos_dia` | `money(18,2)` | L16 |
| `bpsaldo_actual` | `money(18,2)` | L17 |
| `bptipo_cta` | `char(1)` | L18 |
| `bpromedio_anual` | `money(18,2)` | L19 |
| `baccmayor` | `char(10)` | L21 |
| `baccsub` | `char(10)` | L22 |
| `baccsubsub` | `char(10)` | L23 |
| `baccssubsub` | `char(10)` | L24 |
| `baccsssubsub` | `char(10)` | L25 |
| `basector` | `char(10)` | L26 |
| `v_mayor` | `char(10)` | L28 |
| `v_mayor1` | `char(1)` | L29 |
| *…24 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `co_param` | `bdicont` | no | SELECT | L60 |
| `riesgobalanza` | `bdicont` | no | SELECT | L144 |
| `riesgobalanza` | `bdicont` | no | INSERT | L203 |
| `si_catalog` | `bdinteg` | ⚠️ sí | SELECT | L1045 |
| `si_sucursales` | `bdinteg` | ⚠️ sí | SELECT | L1056 |
| `si_histdiv` | `bdinteg` | ⚠️ sí | SELECT | L1107 |
| `si_tpcambio` | `bdinteg` | ⚠️ sí | SELECT | L1114 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L201 | FÓRMULA | `let bpromedio_anual = (bpsaldo_dia_anterior+bpsaldo_actual)/(month(bpmes_dia));` |  |
| L261 | FÓRMULA | `let bpromedio_anual = (bpsaldo_dia_anterior+bpsaldo_actual)/(month(bpmes_dia));` |  |
| L328 | FÓRMULA | `let bpromedio_anual = (bpsaldo_dia_anterior+bpsaldo_actual)/(month(bpmes_dia));` |  |
| L376 | FÓRMULA | `let bpromedio_anual = (bpsaldo_dia_anterior+bpsaldo_actual)/(month(bpmes_dia));` |  |
| L424 | FÓRMULA | `let bpromedio_anual = (bpsaldo_dia_anterior+bpsaldo_actual)/(month(bpmes_dia));` |  |
| L471 | FÓRMULA | `let bpromedio_anual = (bpsaldo_dia_anterior+bpsaldo_actual)/(month(bpmes_dia));` |  |
| L519 | FÓRMULA | `let bpromedio_anual = (bpsaldo_dia_anterior+bpsaldo_actual)/(month(bpmes_dia));` |  |
| L571 | FÓRMULA | `let bpromedio_anual = (bpsaldo_dia_anterior+bpsaldo_actual)/(month(bpmes_dia));` |  |
| L617 | FÓRMULA | `let bpromedio_anual = (bpsaldo_dia_anterior+bpsaldo_actual)/(month(bpmes_dia));` |  |
| L665 | FÓRMULA | `let bpromedio_anual = (bpsaldo_dia_anterior+bpsaldo_actual)/(month(bpmes_dia));` |  |
| L713 | FÓRMULA | `let bpromedio_anual = (bpsaldo_dia_anterior+bpsaldo_actual)/(month(bpmes_dia));` |  |
| L766 | FÓRMULA | `let bpromedio_anual = (bpsaldo_dia_anterior+bpsaldo_actual)/(month(bpmes_dia));` |  |
| L813 | FÓRMULA | `let bpromedio_anual = (bpsaldo_dia_anterior+bpsaldo_actual)/(month(bpmes_dia));` |  |
| L862 | FÓRMULA | `let bpromedio_anual = (bpsaldo_dia_anterior+bpsaldo_actual)/(month(bpmes_dia));` |  |
| L918 | FÓRMULA | `let bpromedio_anual = (bpsaldo_dia_anterior+bpsaldo_actual)/(month(bpmes_dia));` |  |
| L966 | FÓRMULA | `let bpromedio_anual = (bpsaldo_dia_anterior+bpsaldo_actual)/(month(bpmes_dia));` |  |
| L1019 | FÓRMULA | `let bpromedio_anual = (bpsaldo_dia_anterior+bpsaldo_actual)/(month(bpmes_dia));` |  |
| L1111 | VALIDACIÓN_NULL | `if v_tpc = 0 or v_tpc is null then` |  |
| L1119 | VALIDACIÓN_NULL | `if v_tpc = 0 or v_tpc is null then` |  |
| L1126 | VALIDACIÓN_NULL | `if v_fecha_tc is null or v_fecha_tc = " " then` |  |
| L1138 | FÓRMULA | `let bpsaldo_dia_anterior = bpsaldo_dia_anterior * v_tpc;` |  |
| L1139 | FÓRMULA | `let bpcargos_dia       = bpcargos_dia * v_tpc;` |  |
| L1140 | FÓRMULA | `let bpabonos_dia      = bpabonos_dia * v_tpc;` |  |
| L1141 | FÓRMULA | `let bpsaldo_actual    = bpsaldo_actual * v_tpc;` |  |
| L1152 | VALIDACIÓN_NULL | `if v_tpc = 0 or v_tpc is null then` |  |
| L1160 | VALIDACIÓN_NULL | `if v_tpc = 0 or v_tpc is null then` |  |
| L1167 | VALIDACIÓN_NULL | `if v_fecha_tc is null or v_fecha_tc = " " then` |  |
| L1179 | FÓRMULA | `let bpsaldo_dia_anterior = bpsaldo_dia_anterior / v_tpc;` |  |
| L1180 | FÓRMULA | `let bpcargos_dia     = bpcargos_dia / v_tpc;` |  |
| L1181 | FÓRMULA | `let bpabonos_dia     = bpabonos_dia / v_tpc;` |  |
| | *…1 más…* | | |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `?_riesgo` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `balanza` | ENTIDAD | balanza de comprobación — trial balance (sp_generarbalanza*  | 🔵 CONVENCIÓN | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_riesgo` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_selfechacontable`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_sp_selfechacontable.sql` |
| **LOC (1er CREATE)** | 36 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 1 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "fecha" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 1 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=2 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_selfechacontable(
  p_sEmpresa                   CHAR(3)
) RETURNING CHAR(5) AS codigo, DATE AS fechacontable, DATETIME HOUR TO SECOND AS hora
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_sEmpresa` | `CHAR(3)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vCodret` | `CHAR(5)` | L5 |
| `v_fechacontable` | `DATE` | L6 |
| `iSqlErr` | `INTEGER` | L7 |
| `v_sHora` | `DATETIME HOUR TO SECOND` | L8 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `co_fechas` | `bdicont` | no | SELECT | L27 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `?_sel` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `fecha` | ENTIDAD | fecha | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `cont` | PREFIJO | familia contabilidad | 🔵 CONVENCIÓN | nombre_sp |
| `?able` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_sel`, `?able` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_selsdodias`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_sp_selsdodias.sql` |
| **LOC (1er CREATE)** | 114 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "saldo (del día)" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 2 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=2 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_selsdodias(
  p_sempresa                   CHAR(3)
  p_scuentacontable            CHAR(20)
  p_sciudad                    CHAR(3)
  p_ssucursal                  CHAR(4)
  p_smoneda                    CHAR(2)
  p_dfechacontable             DATE
  p_ext                        CHAR(2)
) RETURNING CHAR(5) AS codigo,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_sempresa` | `CHAR(3)` | — | — |
| `p_scuentacontable` | `CHAR(20)` | — | — |
| `p_sciudad` | `CHAR(3)` | — | — |
| `p_ssucursal` | `CHAR(4)` | — | — |
| `p_smoneda` | `CHAR(2)` | — | — |
| `p_dfechacontable` | `DATE` | — | — |
| `p_ext` | `CHAR(2)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vCodret` | `CHAR(5)` | L18 |
| `iSqlErr` | `INTEGER` | L19 |
| `v_sccmayor` | `CHAR(4)` | L20 |
| `v_sccsub` | `CHAR(2)` | L21 |
| `v_sccsubsub` | `CHAR(2)` | L22 |
| `v_sccssubsub` | `CHAR(2)` | L23 |
| `v_sccsssubsub` | `CHAR(2)` | L24 |
| `v_ssector` | `CHAR(2)` | L25 |
| `v_sidia` | `SMALLINT` | L26 |
| `v_fsaldoiniciodia` | `MONEY(18,2)` | L27 |
| `v_fcargosdia` | `MONEY(18,2)` | L28 |
| `v_fabonosdia` | `MONEY(18,2)` | L29 |
| `v_fsaldoactual` | `MONEY(18,2)` | L30 |
| `v_dfechainicio` | `DATE` | L31 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `co_sdodias` | `bdicont` | no | SELECT | L75 |
| `co_histsdodias` | `bdicont` | no | SELECT | L96 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L49 | VALIDACIÓN_NULL | `IF p_sempresa = '' OR p_scuentacontable = '' OR (p_dfechacontable = '' OR p_dfechacontable IS NULL) ` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `?_sel` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `sdo` | ENTIDAD | saldo | 🔵 CONVENCIÓN | nombre_sp |
| `dia` | MODIF | del día | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?s` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_sel`, `?s` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_si_ejecutb4`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_sp_si_ejecutb4.sql` |
| **LOC (1er CREATE)** | 220 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "(sufijo de versión de SP)" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 2 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=1 · INFERIDO=1 · SINTÉTICO=1 / 3 términos |

### Firma

```sql
CREATE PROCEDURE sp_si_ejecutb4(
  pibandera                    INTEGER
  pscve_usuario                CHAR(10)
  pspascode                    CHAR(10)
) RETURNING VARCHAR(6)    as Cod_ret
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pibandera` | `INTEGER` | — | — |
| `pscve_usuario` | `CHAR(10)` | — | — |
| `pspascode` | `CHAR(10)` | `sp`=stored procedure | 🔵 CONVENCIÓN |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `SQL_ERR` | `INTEGER` | L27 |
| `ISAM_ERR` | `INTEGER` | L28 |
| `ERROR_INFO` | `varchar(80)` | L29 |
| `P_COD_RET` | `VARCHAR(6)` | L30 |
| `P_COD_RET2` | `VARCHAR(6)` | L31 |
| `P_MENSAJE` | `varchar(80)` | L32 |
| `vsCodRet` | `char(5)` | L35 |
| `vsMensaje_Respuesta` | `char(80)` | L36 |
| `vsempresa` | `char(3)` | L37 |
| `vsejecutivo` | `char(8)` | L38 |
| `vsnombre` | `char(45)` | L39 |
| `vssucursal` | `char(4)` | L40 |
| `vspuesto` | `char(3)` | L41 |
| `vsdepartamento` | `char(3)` | L42 |
| `vspASsword` | `char(80)` | L43 |
| `vspAS_cod` | `char(80)` | L44 |
| `vsnombramiento` | `char(20)` | L45 |
| `vslimaut_mn` | `DECIMAL(16,2)` | L46 |
| `vslimaut_dls` | `DECIMAL(16,2)` | L47 |
| `vsvigencia` | `date` | L48 |
| `vsperfil` | `INTEGER` | L49 |
| `vsASistente` | `char(80)` | L50 |
| `vsuser_insert` | `char(45)` | L51 |
| `vsfecha_insert` | `DATE` | L52 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_ejecut` | `bdinteg` | ⚠️ sí | SELECT | L129 |
| `si_perfil_ejecut` | `bdinteg` | ⚠️ sí | SELECT | L164 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L55 | CÓDIGO_RETORNO | `let	vsCodRet 			 = '00000';` |  |
| L192 | CÓDIGO_RETORNO | `let	vsCodRet 			 = '00001';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `?_si_ejecut` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `b4` | MODIF | sufijo de versión de SP (Bloque/Build 4) | 🟡 INFERIDO | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_si_ejecut` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_si_empresasb4`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_sp_si_empresasb4.sql` |
| **LOC (1er CREATE)** | 71 |
| **Callgraph** | ✅ fan_in=1 / fan_out=55 |
| **Deps concatenadas** | 15 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "empresas (sufijo de versión de SP)" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 1 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=1 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_si_empresasb4(
  pBandera                     CHAR(1)
  pEmpresa                     char(3)
) RETURNING CHAR(5)  AS Cod_Retorno,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pBandera` | `CHAR(1)` | — | — |
| `pEmpresa` | `char(3)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `scod_ret` | `CHAR(5)` | L8 |
| `vsqlerr` | `INTEGER` | L9 |
| `cRazonSocial` | `char(30)` | L10 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_empresas` | `bdinteg` | ⚠️ sí | SELECT | L53 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `?_si_` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `empresas` | ENTIDAD | empresas (nómina empresarial) | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `b4` | MODIF | sufijo de versión de SP (Bloque/Build 4) | ✅ CÓDIGO | nombre_sp, texto_cuerpo |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_si_` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_svconciliacont`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_sp_svconciliacont.sql` |
| **LOC (1er CREATE)** | 273 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "conciliación" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 7 tabla(s) con operaciones: INSERT, SELECT, DELETE |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=1 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_svconciliacont(
  pempresa                     char(3)
  pfecha                       date
  pusuario                     char(8)
) RETURNING char(5),        -- codret
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pempresa` | `char(3)` | — | — |
| `pfecha` | `date` | — | — |
| `pusuario` | `char(8)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `sql_err` | `integer` | L9 |
| `isam_err` | `integer` | L10 |
| `vcodret` | `char(5)` | L11 |
| `vmsg` | `varchar(40)` | L12 |
| `vsistema` | `char(2)` | L14 |
| `vtotmonto` | `money(22,2)` | L15 |
| `vsucursal` | `char(4)` | L16 |
| `vtransacc` | `char(4)` | L17 |
| `vproducto` | `char(4)` | L18 |
| `vsecuencia` | `integer` | L19 |
| `vmoneda` | `char(2)` | L20 |
| `vnuminvers` | `char(20)` | L21 |
| `vexiste` | `char(1)` | L28 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_sistema` | `bdinteg` | ⚠️ sí | SELECT | L70 |
| `co_conciliamovs` | `bdicont` | no | SELECT | L83 |
| `co_conciliamovs` | `bdicont` | no | DELETE | L83 |
| `sv_maeinv` | `bdinvers` | ⚠️ sí | SELECT | L92 |
| `sv_movhis` | `bdinvers` | ⚠️ sí | SELECT | L102 |
| `si_prodtran` | `bdinteg` | ⚠️ sí | SELECT | L129 |
| `co_conciliamovs` | `bdicont` | no | INSERT | L164 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L53 | VALIDACIÓN_NULL | `IF  pempresa IS NULL THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `?_sv` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `concilia` | ACCION | conciliación | 🔵 CONVENCIÓN | nombre_sp |
| `cont` | PREFIJO | familia contabilidad | 🔵 CONVENCIÓN | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_sv` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_svconciliacont_pba`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_sp_svconciliacont_pba.sql` |
| **LOC (1er CREATE)** | 273 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "conciliación (PBA — sufijo de SPs para Pruebas; confirmado por SME)" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `confirma` → `SELECT` encontrado en el cuerpo · `confirma` → `UPDATE` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=4 · INFERIDO=0 · SINTÉTICO=1 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_svconciliacont_pba(
  pempresa                     char(3)
  pfecha                       date
  pusuario                     char(8)
) RETURNING char(5),        -- codret
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pempresa` | `char(3)` | — | — |
| `pfecha` | `date` | — | — |
| `pusuario` | `char(8)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `sql_err` | `integer` | L9 |
| `isam_err` | `integer` | L10 |
| `vcodret` | `char(5)` | L11 |
| `vmsg` | `varchar(40)` | L12 |
| `vsistema` | `char(2)` | L14 |
| `vtotmonto` | `money(22,2)` | L15 |
| `vsucursal` | `char(4)` | L16 |
| `vtransacc` | `char(4)` | L17 |
| `vproducto` | `char(4)` | L18 |
| `vsecuencia` | `integer` | L19 |
| `vmoneda` | `char(2)` | L20 |
| `vnuminvers` | `char(20)` | L21 |
| `vexiste` | `char(1)` | L28 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_sistema` | `bdinteg` | ⚠️ sí | SELECT | L70 |
| `co_conciliamovs` | `bdicont` | no | SELECT | L83 |
| `co_conciliamovs` | `bdicont` | no | DELETE | L83 |
| `sv_maeinv` | `bdinvers` | ⚠️ sí | SELECT | L92 |
| `sv_movhis` | `bdinvers` | ⚠️ sí | SELECT | L102 |
| `si_prodtran` | `bdinteg` | ⚠️ sí | SELECT | L129 |
| `co_conciliamovs` | `bdicont` | no | INSERT | L164 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L53 | VALIDACIÓN_NULL | `IF  pempresa IS NULL THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `?_sv` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `concilia` | ACCION | conciliación | 🔵 CONVENCIÓN | nombre_sp |
| `cont` | PREFIJO | familia contabilidad | 🔵 CONVENCIÓN | nombre_sp |
| `pba` | MODIF | PBA — sufijo de SPs para Pruebas; confirmado por SME (Guerra | 🔵 CONVENCIÓN | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_sv` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_upd_ctrlpoliza`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_sp_upd_ctrlpoliza.sql` |
| **LOC (1er CREATE)** | 14 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "actualiza póliza contable" `[partial]` |
| **Propósito verificado** | ❓ NO_VERIFICABLE — Propósito inferido; sin evidencia DML para verificar |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=2 · INFERIDO=1 · SINTÉTICO=1 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_upd_ctrlpoliza(
  pre                          integer
  post                         integer
) RETURNING INTEGER
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pre` | `integer` | — | — |
| `post` | `integer` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `v_numero` | `INTEGER` | L4 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L9 | FÓRMULA | `LET v_numero = pre + 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `upd` | ACCION | actualiza (update) | 🟡 INFERIDO | nombre_sp |
| `?_ctrl` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `poliza` | ENTIDAD | póliza contable | 🔵 CONVENCIÓN | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_ctrl` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_validaauxiliar`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_sp_validaauxiliar.sql` |
| **LOC (1er CREATE)** | 56 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "valida auxiliar contable — sub-ledger contable" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `valida` → `IF` encontrado en el cuerpo · `valida` → `RETURN` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=0 / 3 términos |

### Firma

```sql
CREATE PROCEDURE sp_validaauxiliar(
  spEmpresa                    CHAR (3)
  spAuxiliar                   CHAR(12)
) RETURNING INT, CHAR (48)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `spEmpresa` | `CHAR (3)` | `sp`=stored procedure | 🔵 CONVENCIÓN |
| `spAuxiliar` | `CHAR(12)` | `sp`=stored procedure · `auxiliar`=auxiliar contable — sub-ledger contable (sdos_auxiliar, sp_validaauxiliar) | ✅ CÓDIGO / 🔵 CONVENCIÓN |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `ivCodRet` | `INT` | L5 |
| `svMensaje` | `CHAR(48)` | L6 |
| `ivRegistros` | `INT` | L7 |
| `svNomCompleto` | `CHAR(48)` | L8 |
| `svRazonSocial` | `CHAR(35)` | L9 |
| `svTipPersona` | `CHAR(2)` | L10 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `co_auxiliar` | `bdicont` | no | SELECT | L23 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `valida` | ACCION | valida | 🔵 CONVENCIÓN | nombre_sp |
| `auxiliar` | ENTIDAD | auxiliar contable — sub-ledger contable (sdos_auxiliar, sp_v | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |

---

## `sp_validarcta`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_sp_validarcta.sql` |
| **LOC (1er CREATE)** | 138 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "valida cuenta" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `valida` → `IF` encontrado en el cuerpo · `valida` → `RETURN` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=1 / 4 términos |

### Historia del SP

| Tipo | Valor |
|------|-------|
| FECHA | 03/Jun/2009 --* |
| DESCRIPCION | Serie de Validaciones de la cuenta contable. --* |
| MODIFICACION | Se cambió la firma del SP, de validarcuentacontable a --* |
| MODIFICACION | César Andrés De Anda Alcántara --* |
| FECHA | 17/06/2009 |

### Firma

```sql
CREATE PROCEDURE sp_validarcta(
  p_empresa                    CHAR(3)
  p_smoneda                    CHAR(2)
  p_cuentamayor                CHAR(4)
  p_ccsub                      CHAR(2)
  p_ccsubsub                   CHAR(2)
  p_ccssubsub                  CHAR(2)
  p_ccsssubsub                 CHAR(2)
  p_sector                     CHAR(2)
  p_usuario                    CHAR(8)
) RETURNING CHAR(6)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_empresa` | `CHAR(3)` | — | — |
| `p_smoneda` | `CHAR(2)` | — | — |
| `p_cuentamayor` | `CHAR(4)` | — | — |
| `p_ccsub` | `CHAR(2)` | — | — |
| `p_ccsubsub` | `CHAR(2)` | — | — |
| `p_ccssubsub` | `CHAR(2)` | — | — |
| `p_ccsssubsub` | `CHAR(2)` | — | — |
| `p_sector` | `CHAR(2)` | — | — |
| `p_usuario` | `CHAR(8)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `sql_err` | `INTEGER` | L9 |
| `isam_err` | `INTEGER` | L10 |
| `error_info` | `CHAR(100)` | L11 |
| `cod_ret` | `CHAR(6)` | L12 |
| `v_cuentacontable` | `CHAR(14)` | L15 |
| `v_cuentaenlace` | `CHAR(14)` | L16 |
| `v_ccmayorenl` | `CHAR(4)` | L17 |
| `v_ccsenl` | `CHAR(2)` | L18 |
| `v_ccssenl` | `CHAR(2)` | L19 |
| `v_ccsssenl` | `CHAR(2)` | L20 |
| `v_ccssssenl` | `CHAR(2)` | L21 |
| `v_ccsectorenl` | `CHAR(2)` | L22 |
| `v_ccosto_orig` | `CHAR(4)` | L25 |
| `v_cta_restringida_orig` | `CHAR(1)` | L26 |
| `v_contadorcuenta` | `INTEGER` | L27 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `co_param` | `bdicont` | no | SELECT | L77 |
| `si_ejecut` | `bdinteg` | ⚠️ sí | SELECT | L89 |
| `si_catalog` | `bdinteg` | ⚠️ sí | SELECT | L96 |
| `co_cta_ccorig` | `bdicont` | no | SELECT | L116 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `valida` | ACCION | valida | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?r` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `cta` | ENTIDAD | cuenta | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?r` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_verificafechas`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_sp_verificafechas.sql` |
| **LOC (1er CREATE)** | 54 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 1 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "verifica fechas" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 1 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=0 / 3 términos |

### Firma

```sql
CREATE PROCEDURE sp_verificafechas(
  pfecha_sucursal              date
) RETURNING CHAR(5),
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pfecha_sucursal` | `date` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cod_ret` | `CHAR(5)` | L7 |
| `sql_err` | `INTEGER` | L8 |
| `vfecha_central` | `DATE` | L9 |
| `iDiferencia` | `SMALLINT` | L10 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_fechas` | `bdinteg` | ⚠️ sí | SELECT | L35 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L26 | VALIDACIÓN_NULL | `IF pfecha_sucursal is null THEN` |  |
| L38 | FÓRMULA | `LET iDiferencia = 0; --Sigue Ejecucion` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `verifica` | ACCION | verifica | 🔵 CONVENCIÓN | nombre_sp |
| `fechas` | ENTIDAD | fechas | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |

---

## `sp_verificafechas_web`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_sp_verificafechas_web.sql` |
| **LOC (1er CREATE)** | 57 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 1 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "verifica fechas (canal web)" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 1 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=0 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_verificafechas_web(
  pfecha_sucursal              date
) RETURNING CHAR(5),
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pfecha_sucursal` | `date` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cod_ret` | `CHAR(5)` | L7 |
| `sql_err` | `INTEGER` | L8 |
| `vfecha_central` | `DATE` | L9 |
| `iDiferencia` | `SMALLINT` | L10 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_fechas` | `bdinteg` | ⚠️ sí | SELECT | L38 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L29 | VALIDACIÓN_NULL | `IF pfecha_sucursal is null THEN` |  |
| L41 | FÓRMULA | `LET iDiferencia = 0; --Sigue Ejecucion` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `verifica` | ACCION | verifica | 🔵 CONVENCIÓN | nombre_sp |
| `fechas` | ENTIDAD | fechas | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `web` | MODIF | canal web | 🔵 CONVENCIÓN | nombre_sp |

---

## `spconsultarautorizacionfecharetroactiva`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_spconsultarautorizacionfecharetroactiva.sql` |
| **LOC (1er CREATE)** | 87 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "consultar fecha" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=5 · INFERIDO=0 · SINTÉTICO=2 / 7 términos |

### Firma

```sql
CREATE PROCEDURE spconsultarautorizacionfecharetroactiva(
  p_sEmpresa                   CHAR (3)
  p_sClaveAutorizacion         CHAR(6)
  p_dFechaCaptura              DATE
  p_dFechaInicial              DATE
  p_dFechaFinal                DATE
  p_sUsuarioAutoriza           CHAR (8)
  p_sUsuarioSolicita           CHAR(8)
) RETURNING CHAR (5) AS codret, CHAR(8) AS empresa, DATE AS fecha_captura, DATE AS fecha_inicial, DATE AS fecha_final, CHAR(8) AS usuario_autoriza,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_sEmpresa` | `CHAR (3)` | — | — |
| `p_sClaveAutorizacion` | `CHAR(6)` | `autoriza`=autoriza | 🔵 CONVENCIÓN |
| `p_dFechaCaptura` | `DATE` | `fecha`=fecha | 🔵 CONVENCIÓN |
| `p_dFechaInicial` | `DATE` | `fecha`=fecha | 🔵 CONVENCIÓN |
| `p_dFechaFinal` | `DATE` | `fecha`=fecha | 🔵 CONVENCIÓN |
| `p_sUsuarioAutoriza` | `CHAR (8)` | `autoriza`=autoriza | 🔵 CONVENCIÓN |
| `p_sUsuarioSolicita` | `CHAR(8)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `v_sEmpresa` | `CHAR(3)` | L8 |
| `v_dFechaCaptura` | `DATE` | L9 |
| `v_dFechaInicial` | `DATE` | L10 |
| `v_dFechaFinal` | `DATE` | L11 |
| `v_sUsuarioAutoriza` | `CHAR(8)` | L12 |
| `v_sUsuarioSolicita` | `CHAR(8)` | L13 |
| `v_sClaveAutorizacion` | `CHAR(6)` | L14 |
| `v_sEstatusUso` | `CHAR(1)` | L15 |
| `v_mImporte` | `MONEY(18,2)` | L16 |
| `v_sConfirma` | `CHAR(5)` | L17 |
| `iSqlErr` | `INTEGER` | L18 |
| `v_sCodRet` | `CHAR (5)` | L19 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `co_clv_retroact` | `bdicont` | no | SELECT | L73 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L21 | CÓDIGO_RETORNO | `LET v_sCodRet = '00000';` |  |
| L39 | CÓDIGO_RETORNO | `LET v_sCodRet ='00001';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `consultar` | ACCION | consultar | 🔵 CONVENCIÓN | nombre_sp |
| `autoriza` | ACCION | autoriza | 🔵 CONVENCIÓN | nombre_sp |
| `?cion` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `fecha` | ENTIDAD | fecha | 🔵 CONVENCIÓN | nombre_sp |
| `?retro` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `activa` | ACCION | activa | 🔵 CONVENCIÓN | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?cion`, `?retro` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `spgrabarfecharetroactiva`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_spgrabarfecharetroactiva.sql` |
| **LOC (1er CREATE)** | 46 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "graba fecha" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 2 tabla(s) con operaciones: SELECT, INSERT |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=4 · INFERIDO=0 · SINTÉTICO=2 / 6 términos |

### Firma

```sql
CREATE PROCEDURE spgrabarfecharetroactiva(
  p_sempresa                   CHAR(3)
  p_dFechaCaptura              DATE
  p_dFechaInicial              DATE
  p_dFechaFinal                DATE
  p_sUsuarioAutoriza           CHAR(8)
  p_sUsuarioSolicita           CHAR(8)
  p_sClaveAutorizacion         CHAR(6)
  p_sEstatusUso                CHAR(1)
  p_mImporte                   MONEY(18,2)
) RETURNING CHAR(5) AS retorno
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_sempresa` | `CHAR(3)` | — | — |
| `p_dFechaCaptura` | `DATE` | `fecha`=fecha | 🔵 CONVENCIÓN |
| `p_dFechaInicial` | `DATE` | `fecha`=fecha | 🔵 CONVENCIÓN |
| `p_dFechaFinal` | `DATE` | `fecha`=fecha | 🔵 CONVENCIÓN |
| `p_sUsuarioAutoriza` | `CHAR(8)` | — | — |
| `p_sUsuarioSolicita` | `CHAR(8)` | — | — |
| `p_sClaveAutorizacion` | `CHAR(6)` | — | — |
| `p_sEstatusUso` | `CHAR(1)` | — | — |
| `p_mImporte` | `MONEY(18,2)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `iSqlErr` | `INTEGER` | L6 |
| `v_sconfirma` | `CHAR(5)` | L7 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `co_clv_retroact` | `bdicont` | no | SELECT | L26 |
| `co_clv_retroact` | `bdicont` | no | INSERT | L33 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `graba` | ACCION | graba / almacena | 🔵 CONVENCIÓN | nombre_sp |
| `?r` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `fecha` | ENTIDAD | fecha | 🔵 CONVENCIÓN | nombre_sp |
| `?retro` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `activa` | ACCION | activa | 🔵 CONVENCIÓN | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?r`, `?retro` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `tabla_dual`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_tabla_dual.sql` |
| **LOC (1er CREATE)** | 18 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "tabla_dual" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 2 tabla(s) con operaciones: SELECT, INSERT |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=0 · INFERIDO=0 · SINTÉTICO=1 / 1 términos |

### Firma

```sql
CREATE PROCEDURE tabla_dual(
)
```

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `existe` | `int` | L2 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `systables` | `bdicont` | no | SELECT | L5 |
| `dual` | `bdicont` | no | INSERT | L15 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `?tabla_dual` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?tabla_dual` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `totaux`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_totaux.sql` |
| **LOC (1er CREATE)** | 719 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "totaux" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 6 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=1 / 2 términos |

### Firma

```sql
CREATE PROCEDURE totaux(
  pempresa                     char(3)
)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pempresa` | `char(3)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vciudad` | `char(3)` | L5 |
| `w_empresa` | `char(3)` | L6 |
| `vusuario` | `char(8)` | L7 |
| `vpoliza_usuario` | `char(8)` | L8 |
| `vdescripcion` | `char(50)` | L9 |
| `vmonto` | `money(14,2)` | L10 |
| `v_rowid` | `integer` | L16 |
| `pfecha_hoy1` | `date` | L17 |
| `vexiste` | `integer` | L18 |
| `vccosto_orig` | `char(4)` | L19 |
| `vcargos_dia` | `money(18,2)` | L20 |
| `vabonos_dia` | `money(18,2)` | L21 |
| `vnro_cargos_dia` | `integer` | L22 |
| `vnro_abonos_dia` | `integer` | L23 |
| `vdias_proyectado` | `integer` | L24 |
| `vdias_acumulados` | `integer` | L25 |
| `vsaldo_acumulado` | `money(18,2)` | L26 |
| `vsaldo_inicio_dia` | `money(18,2)` | L27 |
| `vsaldo_fin_de_dia` | `money(18,2)` | L28 |
| `vsuma_carabo` | `money(18,2)` | L29 |
| `vmes_dia` | `date` | L30 |
| `vfecha_sig` | `date` | L31 |
| `vsaldo_inicio` | `money(18,2)` | L32 |
| `vcar_dia` | `money(18,2)` | L33 |
| `vabo_dia` | `money(18,2)` | L34 |
| *…29 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_catalog` | `bdinteg` | ⚠️ sí | SELECT | L82 |
| `co_historico` | `bdicont` | no | SELECT | L104 |
| `co_fechas` | `bdicont` | no | SELECT | L136 |
| `co_mensual` | `bdicont` | no | SELECT | L176 |
| `co_histdiasaux` | `bdicont` | no | SELECT | L247 |
| `co_diasaux` | `bdicont` | no | SELECT | L469 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L217 | VALIDACIÓN_NULL | `if vfecha_sig is null then` |  |
| L234 | VALIDACIÓN_NULL | `if vfecha_sig is null then let vfecha_sig = vmes_dia; end if;` |  |
| L235 | FÓRMULA | `let vdias_acum = vfecha_sig - vmes_dia;` |  |
| L237 | FÓRMULA | `let vsaldo_fin_de_diar = vsaldo_inicio_diar + (vmonto_cargos - vmonto_abonos);` | 🔴 MONEY/aritmética financiera |
| L238 | FÓRMULA | `let vsaldo_acumulado = vmonto_cargos - vmonto_abonos;` | 🔴 MONEY/aritmética financiera |
| L240 | FÓRMULA | `let vsaldo_fin_de_diar = vsaldo_inicio_diar + (vmonto_abonos - vmonto_cargos);` | 🔴 MONEY/aritmética financiera |
| L241 | FÓRMULA | `let vsaldo_acumulado = vmonto_abonos - vmonto_cargos;` | 🔴 MONEY/aritmética financiera |
| L243 | FÓRMULA | `let vsaldo_acumulado = vsaldo_acumulado * vdias_acum;}` |  |
| L261 | VALIDACIÓN_NULL | `if vsaldo_inicio is null then` |  |
| L266 | FÓRMULA | `let vsaldo_fin_de_diar = vsaldo_inicio + (vmonto_cargos - vmonto_abonos);` | 🔴 MONEY/aritmética financiera |
| L267 | FÓRMULA | `let vsaldo_acumulado = vmonto_cargos - vmonto_abonos;` | 🔴 MONEY/aritmética financiera |
| L269 | FÓRMULA | `let vsaldo_fin_de_diar = vsaldo_inicio + (vmonto_abonos - vmonto_cargos);` | 🔴 MONEY/aritmética financiera |
| L270 | FÓRMULA | `let vsaldo_acumulado = vmonto_abonos - vmonto_cargos;` | 🔴 MONEY/aritmética financiera |
| L364 | VALIDACIÓN_NULL | `if vsaldo_acumulado_diar is null then` |  |
| L427 | VALIDACIÓN_NULL | `if vsaldo_acumulado_diar is null then` |  |
| L484 | VALIDACIÓN_NULL | `if vsaldo_inicio is null then` |  |
| L488 | FÓRMULA | `let vsaldo_fin_de_diar = vsaldo_inicio + (vmonto_cargos - vmonto_abonos);` | 🔴 MONEY/aritmética financiera |
| L489 | FÓRMULA | `let vsaldo_acumulado = vmonto_cargos - vmonto_abonos;` | 🔴 MONEY/aritmética financiera |
| L491 | FÓRMULA | `let vsaldo_fin_de_diar = vsaldo_inicio + (vmonto_abonos - vmonto_cargos);` | 🔴 MONEY/aritmética financiera |
| L492 | FÓRMULA | `let vsaldo_acumulado = vmonto_abonos - vmonto_cargos;` | 🔴 MONEY/aritmética financiera |
| L494 | FÓRMULA | `let vsaldo_acumulado = vsaldo_acumulado * vdias_acum;` |  |
| L588 | VALIDACIÓN_NULL | `if vsaldo_acumulado_diar is null then` |  |
| L693 | VALIDACIÓN_NULL | `if vsaldo_acumulado_diar is null then` |  |
| L715 | FÓRMULA | `let vfecha_inicio = vfecha_inicio + 1 UNITS DAY;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `?totau` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `x` | MODIF | por (criterio) | 🔵 CONVENCIÓN | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?totau` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `traspaso`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_traspaso.sql` |
| **LOC (1er CREATE)** | 354 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "traspaso entre cuentas" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 8 tabla(s) con operaciones: INSERT, SELECT, DELETE |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=0 · INFERIDO=0 · SINTÉTICO=0 / 1 términos |

### Firma

```sql
CREATE PROCEDURE traspaso(
  pempresa                     char(3)
  pfecha_hoy                   date
  pcambio                      decimal(14,7)
) RETURNING char(5)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pempresa` | `char(3)` | — | — |
| `pfecha_hoy` | `date` | — | — |
| `pcambio` | `decimal(14,7)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `v_cuantos` | `integer` | L5 |
| `trempresa` | `char(3)` | L6 |
| `trsecuencia` | `integer` | L7 |
| `trccmayor` | `char(4)` | L8 |
| `trccsub` | `char(2)` | L9 |
| `trccsubsub` | `char(2)` | L10 |
| `trccssubsub` | `char(2)` | L11 |
| `trccsssubsub` | `char(2)` | L12 |
| `trccmayor_c` | `char(4)` | L13 |
| `trccsub_c` | `char(2)` | L14 |
| `trccsubsub_c` | `char(2)` | L15 |
| `trccssubsub_c` | `char(2)` | L16 |
| `trccsssubsub_c` | `char(2)` | L17 |
| `trccmayor_t` | `char(4)` | L18 |
| `trccsub_t` | `char(2)` | L19 |
| `trccsubsub_t` | `char(2)` | L20 |
| `trccssubsub_t` | `char(2)` | L21 |
| `trccsssubsub_t` | `char(2)` | L22 |
| `detusuario` | `char(8)` | L23 |
| `detcontrol_poliza` | `smallint` | L24 |
| `detfecha_captura` | `date` | L25 |
| `detsecuencia` | `integer` | L26 |
| `detempresa` | `char(3)` | L27 |
| `detccmayor` | `char(4)` | L28 |
| `detccsub` | `char(2)` | L29 |
| *…28 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `co_contproc` | `bdicont` | no | SELECT | L64 |
| `co_poliza` | `bdicont` | no | SELECT | L73 |
| `co_poliza` | `bdicont` | no | DELETE | L78 |
| `co_detpol` | `bdicont` | no | SELECT | L84 |
| `co_detpol` | `bdicont` | no | DELETE | L84 |
| `co_poliza` | `bdicont` | no | INSERT | L122 |
| `co_mapeo_compra` | `bdicont` | no | SELECT | L149 |
| `co_detpol` | `bdicont` | no | INSERT | L220 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L99 | VALIDACIÓN_NULL | `if (maxdetpol is null) then` |  |
| L109 | VALIDACIÓN_NULL | `if (maxpol is null) then` |  |
| L119 | FÓRMULA | `let wcontpol = wcontpol + 1;` |  |
| L120 | FÓRMULA | `let wcontpol2 = wcontpol + 1;` |  |
| L161 | VALIDACIÓN_NULL | `if (wsec is null) then` |  |
| L174 | VALIDACIÓN_NULL | `if (wsec2 is null) then` |  |
| L218 | FÓRMULA | `let wsec = wsec + 1;` |  |
| L229 | FÓRMULA | `let wsec = wsec + 1;` |  |
| L256 | FÓRMULA | `let wsec = wsec + 1;` |  |
| L265 | FÓRMULA | `let detmonto = detmonto * pcambio;` | 🔴 MONEY/aritmética financiera |
| L277 | FÓRMULA | `let wsec = wsec + 1;` |  |
| L315 | VALIDACIÓN_NULL | `if detmonto is null then` |  |
| L339 | VALIDACIÓN_NULL | `if detmonto is null then` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `traspaso` | ACCION | traspaso entre cuentas | ✅ CÓDIGO | nombre_sp, texto_cuerpo |

---

## `valfecha_pol`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_valfecha_pol.sql` |
| **LOC (1er CREATE)** | 184 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 1 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "fecha" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 4 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=0 · INFERIDO=0 · SINTÉTICO=2 / 3 términos |

### Firma

```sql
CREATE PROCEDURE valfecha_pol(
  vb_fecha                     DATE
  vb_empresa                   CHAR(3)
  vb_fcaptura                  DATE
) RETURNING CHAR(5)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `vb_fecha` | `DATE` | `fecha`=fecha | ✅ CÓDIGO |
| `vb_empresa` | `CHAR(3)` | — | — |
| `vb_fcaptura` | `DATE` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `v_codret` | `CHAR(5)` | L9 |
| `sqlerr` | `INTEGER` | L10 |
| `v_fval` | `DATE` | L11 |
| `v_Mchar` | `CHAR(2)` | L12 |
| `v_Achar` | `CHAR(4)` | L13 |
| `v_Achar1` | `CHAR(4)` | L14 |
| `v_fchar` | `CHAR(10)` | L15 |
| `v_cie1` | `CHAR(2)` | L16 |
| `v_cie1r` | `CHAR(2)` | L17 |
| `v_cie2` | `CHAR(2)` | L18 |
| `v_pais` | `CHAR(2)` | L19 |
| `v_fecha` | `DATE` | L20 |
| `v_hoy` | `DATE` | L21 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_param` | `bdinteg` | ⚠️ sí | SELECT | L54 |
| `co_fechas` | `bdicont` | no | SELECT | L57 |
| `si_feriado` | `bdinteg` | ⚠️ sí | SELECT | L60 |
| `co_param` | `bdicont` | no | SELECT | L70 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L83 | FÓRMULA | `LET v_fchar = "12/01/" \|\| v_Achar;` |  |
| L85 | FÓRMULA | `LET v_fval  = v_fval + 1 UNITS MONTH;` |  |
| L86 | FÓRMULA | `LET v_fval  = v_fval - 1 UNITS DAY;` |  |
| L106 | FÓRMULA | `LET v_fchar = TRIM(v_cie1) \|\| "/01/" \|\| v_Achar;` |  |
| L108 | FÓRMULA | `LET v_fval  = v_fval + 1 UNITS MONTH;` |  |
| L109 | FÓRMULA | `LET v_fval  = v_fval - 1 UNITS DAY;` |  |
| L119 | FÓRMULA | `LET v_fchar = TRIM(v_cie1) \|\| "/01/" \|\| v_Achar1;` |  |
| L121 | FÓRMULA | `LET v_fval  = v_fval + 1 UNITS MONTH;` |  |
| L122 | FÓRMULA | `LET v_fval  = v_fval - 1 UNITS DAY;` |  |
| L129 | FÓRMULA | `LET v_fchar = TRIM(v_cie2) \|\| "/01/" \|\| v_Achar1;` |  |
| L131 | FÓRMULA | `LET v_fval  = v_fval + 1 UNITS MONTH;` |  |
| L132 | FÓRMULA | `LET v_fval  = v_fval - 1 UNITS DAY;` |  |
| L144 | FÓRMULA | `LET v_fchar = TRIM(v_cie2) \|\| "/01/" \|\| v_Achar1;` |  |
| L146 | FÓRMULA | `LET v_fval  = v_fval + 1 UNITS YEAR;` |  |
| L147 | FÓRMULA | `LET v_fval  = v_fval + 1 UNITS MONTH;` |  |
| L148 | FÓRMULA | `LET v_fval  = v_fval - 1 UNITS DAY;` |  |
| L154 | FÓRMULA | `LET v_fchar = TRIM(v_cie1) \|\| "/01/" \|\| v_Achar1;` |  |
| L156 | FÓRMULA | `LET v_fval  = v_fval + 1 UNITS YEAR;` |  |
| L157 | FÓRMULA | `LET v_fval  = v_fval + 1 UNITS MONTH;` |  |
| L158 | FÓRMULA | `LET v_fval  = v_fval - 1 UNITS DAY;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `?val` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `fecha` | ENTIDAD | fecha | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `?_pol` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?val`, `?_pol` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `valida_archivo_importa`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_valida_archivo_importa.sql` |
| **LOC (1er CREATE)** | 33 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "valida archivo y Impago — pago vencido o fallido; confirmado: n_impagos_consec" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `valida` → `IF` encontrado en el cuerpo · `valida` → `RETURN` encontrado en el cuerpo · `confirma` → `SELECT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=1 / 4 términos |

### Firma

```sql
CREATE PROCEDURE valida_archivo_importa(
  p_archivo                    CHAR(100)
  p_fecha_hoy                  DATE
) RETURNING CHAR(5)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_archivo` | `CHAR(100)` | `archivo`=archivo | ✅ CÓDIGO |
| `p_fecha_hoy` | `DATE` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cod_ret` | `CHAR(5)` | L4 |
| `sql_err` | `INTEGER` | L5 |
| `isam_err` | `INTEGER` | L6 |
| `error_info` | `CHAR(40)` | L7 |
| `v_valida` | `INTEGER` | L8 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `co_archivos` | `bdicont` | no | SELECT | L21 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `valida` | ACCION | valida | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `archivo` | ENTIDAD | archivo | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `imp` | ENTIDAD | Impago — pago vencido o fallido; confirmado: n_impagos_conse | 🔵 CONVENCIÓN | nombre_sp |
| `?orta` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?orta` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `validacuenta`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_validacuenta.sql` |
| **LOC (1er CREATE)** | 55 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "valida cuenta" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `valida` → `IF` encontrado en el cuerpo · `valida` → `RETURN` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=0 · INFERIDO=0 · SINTÉTICO=0 / 2 términos |

### Firma

```sql
CREATE PROCEDURE validacuenta(
  p_empresa                    CHAR (3)
  p_ccmayor                    CHAR(4)
  p_ccsub                      CHAR(2)
  p_ccsubsub                   CHAR(2)
  p_ccssubsub                  CHAR(2)
  p_ccsssubsub                 CHAR(2)
  p_sector                     CHAR(2)
) RETURNING INT, CHAR (50), CHAR(1)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_empresa` | `CHAR (3)` | — | — |
| `p_ccmayor` | `CHAR(4)` | — | — |
| `p_ccsub` | `CHAR(2)` | — | — |
| `p_ccsubsub` | `CHAR(2)` | — | — |
| `p_ccssubsub` | `CHAR(2)` | — | — |
| `p_ccsssubsub` | `CHAR(2)` | — | — |
| `p_sector` | `CHAR(2)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cod_ret` | `INT` | L5 |
| `tRegistros` | `INT` | L6 |
| `tMensaje` | `CHAR(50)` | L7 |
| `tTipo_cuenta` | `CHAR(1)` | L8 |
| `tNombre` | `CHAR(50)` | L9 |
| `tAuxiliar` | `CHAR(1)` | L10 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_catalog` | `bdinteg` | ⚠️ sí | SELECT | L25 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `valida` | ACCION | valida | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `cuenta` | ENTIDAD | cuenta | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |

---

## `validamov`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_validamov.sql` |
| **LOC (1er CREATE)** | 151 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "valida movimiento" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `valida` → `IF` encontrado en el cuerpo · `valida` → `RETURN` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=0 · INFERIDO=0 · SINTÉTICO=0 / 2 términos |

### Firma

```sql
CREATE PROCEDURE validamov(
  pempresa                     char(3)
  pfecha_hoy                   date
) RETURNING char(5)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pempresa` | `char(3)` | — | — |
| `pfecha_hoy` | `date` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vproceso` | `char(20)` | L17 |
| `w_cod_ret` | `char(5)` | L18 |
| `pusuario` | `char(8)` | L19 |
| `pcontrol_poliza` | `integer` | L20 |
| `tmoempresa` | `char(3)` | L22 |
| `tmoccmayor` | `char(4)` | L23 |
| `tmoccsub` | `char(2)` | L24 |
| `tmoccsubsub` | `char(2)` | L25 |
| `tmoccssubsub` | `char(2)` | L26 |
| `tmoccsssubsub` | `char(2)` | L27 |
| `tmosector` | `char(2)` | L28 |
| `tmodivision` | `char(3)` | L29 |
| `tmoplaza` | `char(3)` | L30 |
| `tmonaturaleza` | `char(1)` | L31 |
| `tmomonto` | `money(18,2)` | L32 |
| `tmodescripcion` | `char(50)` | L33 |
| `tmofecha_captura` | `date` | L34 |
| `tmousuario` | `char(8)` | L35 |
| `tmofecha_valida` | `date` | L36 |
| `tmonum_poliza` | `smallint` | L37 |
| `tmomoneda` | `char(2)` | L38 |
| `tmoauxiliar` | `char(9)` | L39 |
| `tmosecuencia` | `integer` | L40 |
| `tmopoliza_usuario` | `char(8)` | L41 |
| `tmotip_mov` | `char(1)` | L42 |
| *…2 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `co_mapeo_rech` | `bdicont` | no | SELECT | L47 |
| `co_mapeo_rech` | `bdicont` | no | DELETE | L47 |
| `co_tabmovdia` | `bdicont` | no | SELECT | L76 |
| `co_mapeo_rech` | `bdicont` | no | INSERT | L82 |
| `co_detpol` | `bdicont` | no | INSERT | L116 |
| `co_poliza` | `bdicont` | no | SELECT | L135 |
| `co_detpol` | `bdicont` | no | SELECT | L142 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `gen_encab` | `bdicont` | no | L146 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L78 | VALIDACIÓN_NULL | `if tmoempresa is null or tmoccmayor is null or tmomoneda is null or` |  |
| L80 | VALIDACIÓN_NULL | `if tmoempresa is null then` |  |
| L87 | VALIDACIÓN_NULL | `if tmoccmayor is null then` |  |
| L94 | VALIDACIÓN_NULL | `if tmomoneda is null then` |  |
| L101 | VALIDACIÓN_NULL | `if tmoauxiliar is null then` |  |
| L108 | VALIDACIÓN_NULL | `if tmosector is null then` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `valida` | ACCION | valida | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `mov` | ENTIDAD | movimiento | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |

---

## `validapolizanominares`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_validapolizanominares.sql` |
| **LOC (1er CREATE)** | 1603 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "valida póliza contable y nómina" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `valida` → `IF` encontrado en el cuerpo · `valida` → `RETURN` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=3 · CONVENCIÓN=0 · INFERIDO=0 · SINTÉTICO=1 / 4 términos |

### Firma

```sql
CREATE PROCEDURE validapolizanominares(
  p_empresa                    CHAR(3)
  p_usuario                    CHAR(8)
) RETURNING CHAR(5),integer
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_empresa` | `CHAR(3)` | — | — |
| `p_usuario` | `CHAR(8)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `p_fecha_hoy` | `DATE` | L6 |
| `sql_err` | `INTEGER` | L7 |
| `isam_err` | `INTEGER` | L8 |
| `error_info` | `CHAR(40)` | L9 |
| `v_directorio` | `CHAR(30)` | L10 |
| `v_sql` | `CHAR(200)` | L11 |
| `v_poliza` | `INTEGER` | L13 |
| `v_ctrl_poliza` | `INTEGER` | L14 |
| `v_ctrolpoliza` | `INTEGER` | L15 |
| `v_numpoliza` | `INTEGER` | L16 |
| `cod_ret` | `CHAR(3)` | L17 |
| `v_correlativa` | `CHAR(4)` | L18 |
| `v_orden` | `CHAR(4)` | L19 |
| `tmensaje` | `CHAR(50)` | L20 |
| `v_usuariotmp` | `CHAR(8)` | L22 |
| `v_usuario` | `CHAR(8)` | L23 |
| `v_control_poliza` | `INTEGER` | L24 |
| `v_fecha_captura` | `DATE` | L25 |
| `v_secuencia` | `INTEGER` | L26 |
| `v_empresa` | `CHAR(3)` | L27 |
| `v_ccmayor` | `CHAR(4)` | L28 |
| `v_ccsub` | `CHAR(2)` | L29 |
| `v_ccsubsub` | `CHAR(2)` | L30 |
| `v_ccssubsub` | `CHAR(2)` | L31 |
| `v_ccsssubsub` | `CHAR(2)` | L32 |
| *…69 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `co_param` | `bdicont` | no | SELECT | L268 |
| `tmpco_auditerr` | `bdicont` | no | SELECT | L272 |
| `tmpco_auditerr` | `bdicont` | no | DELETE | L272 |
| `tmpco_detpol` | `bdicont` | no | SELECT | L279 |
| `si_codret` | `bdinteg` | ⚠️ sí | SELECT | L296 |
| `tmpco_auditerr` | `bdicont` | no | INSERT | L297 |
| `si_ejecut` | `bdinteg` | ⚠️ sí | SELECT | L385 |
| `si_empresas` | `bdinteg` | ⚠️ sí | SELECT | L459 |
| `si_catalog` | `bdinteg` | ⚠️ sí | SELECT | L533 |
| `co_cta_ccorig` | `bdicont` | no | SELECT | L653 |
| `co_auxiliar` | `bdicont` | no | SELECT | L839 |
| `si_sucursales` | `bdinteg` | ⚠️ sí | SELECT | L950 |
| `si_divisas` | `bdinteg` | ⚠️ sí | SELECT | L1060 |
| `co_ctrlpoliza` | `bdicont` | no | SELECT | L1417 |
| `co_detpol` | `bdicont` | no | SELECT | L1433 |
| `co_ctrlpoliza` | `bdicont` | no | UPDATE | L1475 |
| `co_poliza` | `bdicont` | no | INSERT | L1479 |
| `co_detpol` | `bdicont` | no | INSERT | L1521 |
| `tmpco_detpol` | `bdicont` | no | DELETE | L1592 |
| `co_detpol` | `bdicont` | no | DELETE | L1594 |
| `co_poliza` | `bdicont` | no | SELECT | L1595 |
| `co_poliza` | `bdicont` | no | DELETE | L1595 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `nivelacion_ccostos` | `bdicont` | no | L1542 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L283 | VALIDACIÓN_NULL | `IF v_sumaabonos IS NULL THEN` |  |
| L289 | VALIDACIÓN_NULL | `IF v_sumacargos IS NULL THEN` |  |
| L295 | FÓRMULA | `LET cod_ret = "106"; --OK` |  |
| L351 | VALIDACIÓN_NULL | `IF v_usuario IS NULL OR trim(v_usuario) = "" THEN` |  |
| L352 | FÓRMULA | `LET cod_ret = "99a"; --OK` |  |
| L425 | VALIDACIÓN_NULL | `IF v_empresa IS NULL OR trim(v_empresa) = "" THEN` |  |
| L426 | FÓRMULA | `LET cod_ret = "98a"; --ok` |  |
| L462 | FÓRMULA | `LET cod_ret = "998"; --ok` |  |
| L498 | VALIDACIÓN_NULL | `IF (v_ccmayor IS NULL OR trim(v_ccmayor) = "") OR (v_ccsub IS NULL OR trim(v_ccsub) = "") OR (v_ccsu` |  |
| L500 | FÓRMULA | `LET cod_ret = "100"; --ok` |  |
| L580 | FÓRMULA | `LET cod_ret = "144"; --ok` |  |
| L616 | FÓRMULA | `LET cod_ret = "144"; --ok` |  |
| L657 | FÓRMULA | `LET cod_ret = "148"; --ok` |  |
| L698 | FÓRMULA | `LET cod_ret = "149"; --ok` |  |
| L735 | FÓRMULA | `LET cod_ret = "117"; --ok` |  |
| L770 | FÓRMULA | `LET cod_ret = "176"; --ok` |  |
| L807 | FÓRMULA | `LET cod_ret = "166"; --OK` |  |
| L844 | FÓRMULA | `LET cod_ret = "102"; --OK` |  |
| L880 | FÓRMULA | `LET cod_ret = "173"; --OK cambiar el codigo` |  |
| L917 | VALIDACIÓN_NULL | `IF v_sucursal IS NULL OR TRIM(v_sucursal) = "" THEN` |  |
| L918 | FÓRMULA | `LET cod_ret = "103"; --ok` |  |
| L954 | FÓRMULA | `LET cod_ret = "103"; --ok` |  |
| L990 | VALIDACIÓN_NULL | `IF v_descripcion_det IS NULL OR trim(v_descripcion_det) = "" THEN` |  |
| L991 | FÓRMULA | `LET cod_ret = "997"; --OK` |  |
| L1026 | VALIDACIÓN_NULL | `IF v_moneda IS NULL OR trim(v_moneda) = "" THEN` |  |
| L1027 | FÓRMULA | `LET cod_ret = "96a"; --OK` |  |
| L1064 | FÓRMULA | `LET cod_ret = "996"; --OK` |  |
| L1101 | VALIDACIÓN_NULL | `IF v_ccosto_orig IS NULL OR trim(v_ccosto_orig) = "" THEN` |  |
| L1102 | FÓRMULA | `LET cod_ret = "165"; --OK` |  |
| L1139 | FÓRMULA | `LET cod_ret = "165"; --OK` |  |
| | *…8 más…* | | |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `valida` | ACCION | valida | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `poliza` | ENTIDAD | póliza contable | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `nomina` | ENTIDAD | nómina | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?res` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?res` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `validapolizanominarespaldo`

| Campo | Valor |
|-------|-------|
| **Dominio** | D12 · `bdicont` · Contabilidad |
| **Archivo fuente** | `bdicont_validapolizanominarespaldo.sql` |
| **LOC (1er CREATE)** | 1575 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "valida póliza contable, nómina y respaldo" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `valida` → `IF` encontrado en el cuerpo · `valida` → `RETURN` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=1 · INFERIDO=1 · SINTÉTICO=0 / 4 términos |

### Firma

```sql
CREATE PROCEDURE validapolizanominarespaldo(
  p_empresa                    CHAR(3)
  p_usuario                    CHAR(8)
) RETURNING CHAR(5), INTEGER
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_empresa` | `CHAR(3)` | — | — |
| `p_usuario` | `CHAR(8)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `p_fecha_hoy` | `DATE` | L5 |
| `sql_err` | `INTEGER` | L6 |
| `isam_err` | `INTEGER` | L7 |
| `error_info` | `CHAR(40)` | L8 |
| `v_directorio` | `CHAR(30)` | L9 |
| `v_sql` | `CHAR(200)` | L10 |
| `v_poliza` | `INTEGER` | L12 |
| `v_ctrl_poliza` | `INTEGER` | L13 |
| `v_ctrolpoliza` | `INTEGER` | L14 |
| `v_numpoliza` | `INTEGER` | L15 |
| `cod_ret` | `CHAR(3)` | L16 |
| `v_correlativa` | `CHAR(4)` | L17 |
| `v_orden` | `CHAR(4)` | L18 |
| `tmensaje` | `CHAR(50)` | L19 |
| `v_usuariotmp` | `CHAR(8)` | L21 |
| `v_usuario` | `CHAR(8)` | L22 |
| `v_control_poliza` | `INTEGER` | L23 |
| `v_fecha_captura` | `DATE` | L24 |
| `v_secuencia` | `INTEGER` | L25 |
| `v_empresa` | `CHAR(3)` | L26 |
| `v_ccmayor` | `CHAR(4)` | L27 |
| `v_ccsub` | `CHAR(2)` | L28 |
| `v_ccsubsub` | `CHAR(2)` | L29 |
| `v_ccssubsub` | `CHAR(2)` | L30 |
| `v_ccsssubsub` | `CHAR(2)` | L31 |
| *…71 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `co_param` | `bdicont` | no | SELECT | L262 |
| `tmpco_auditerr` | `bdicont` | no | SELECT | L266 |
| `tmpco_auditerr` | `bdicont` | no | DELETE | L266 |
| `tmpco_detpol` | `bdicont` | no | SELECT | L273 |
| `si_codret` | `bdinteg` | ⚠️ sí | SELECT | L290 |
| `tmpco_auditerr` | `bdicont` | no | INSERT | L291 |
| `si_ejecut` | `bdinteg` | ⚠️ sí | SELECT | L379 |
| `si_empresas` | `bdinteg` | ⚠️ sí | SELECT | L457 |
| `si_catalog` | `bdinteg` | ⚠️ sí | SELECT | L531 |
| `co_cta_ccorig` | `bdicont` | no | SELECT | L651 |
| `co_auxiliar` | `bdicont` | no | SELECT | L837 |
| `si_sucursales` | `bdinteg` | ⚠️ sí | SELECT | L948 |
| `si_divisas` | `bdinteg` | ⚠️ sí | SELECT | L1058 |
| `co_ctrlpoliza` | `bdicont` | no | SELECT | L1407 |
| `co_detpol` | `bdicont` | no | SELECT | L1418 |
| `co_detpol` | `bdicont` | no | INSERT | L1457 |
| `co_ctrlpoliza` | `bdicont` | no | UPDATE | L1499 |
| `co_poliza` | `bdicont` | no | INSERT | L1503 |
| `tmpco_detpol` | `bdicont` | no | DELETE | L1564 |
| `co_detpol` | `bdicont` | no | DELETE | L1566 |
| `co_poliza` | `bdicont` | no | SELECT | L1567 |
| `co_poliza` | `bdicont` | no | DELETE | L1567 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `nivelacion_ccostos` | `bdicont` | no | L1559 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L277 | VALIDACIÓN_NULL | `IF v_sumaabonos IS NULL THEN` |  |
| L283 | VALIDACIÓN_NULL | `IF v_sumacargos IS NULL THEN` |  |
| L289 | FÓRMULA | `LET cod_ret = "106"; --OK` |  |
| L345 | VALIDACIÓN_NULL | `IF v_usuario IS NULL OR trim(v_usuario) = "" THEN` |  |
| L346 | FÓRMULA | `LET cod_ret = "99a"; --OK` |  |
| L423 | VALIDACIÓN_NULL | `IF v_empresa IS NULL OR trim(v_empresa) = "" THEN` |  |
| L424 | FÓRMULA | `LET cod_ret = "98a"; --ok` |  |
| L460 | FÓRMULA | `LET cod_ret = "998"; --ok` |  |
| L496 | VALIDACIÓN_NULL | `IF (v_ccmayor IS NULL OR trim(v_ccmayor) = "") OR (v_ccsub IS NULL OR trim(v_ccsub) = "") OR (v_ccsu` |  |
| L498 | FÓRMULA | `LET cod_ret = "100"; --ok` |  |
| L578 | FÓRMULA | `LET cod_ret = "144"; --ok` |  |
| L614 | FÓRMULA | `LET cod_ret = "144"; --ok` |  |
| L655 | FÓRMULA | `LET cod_ret = "148"; --ok` |  |
| L696 | FÓRMULA | `LET cod_ret = "149"; --ok` |  |
| L733 | FÓRMULA | `LET cod_ret = "117"; --ok` |  |
| L768 | FÓRMULA | `LET cod_ret = "176"; --ok` |  |
| L805 | FÓRMULA | `LET cod_ret = "166"; --OK` |  |
| L842 | FÓRMULA | `LET cod_ret = "102"; --OK` |  |
| L878 | FÓRMULA | `LET cod_ret = "173"; --OK cambiar el codigo` |  |
| L915 | VALIDACIÓN_NULL | `IF v_sucursal IS NULL OR TRIM(v_sucursal) = "" THEN` |  |
| L916 | FÓRMULA | `LET cod_ret = "103"; --ok` |  |
| L952 | FÓRMULA | `LET cod_ret = "103"; --ok` |  |
| L988 | VALIDACIÓN_NULL | `IF v_descripcion_det IS NULL OR trim(v_descripcion_det) = "" THEN` |  |
| L989 | FÓRMULA | `LET cod_ret = "997"; --OK` |  |
| L1024 | VALIDACIÓN_NULL | `IF v_moneda IS NULL OR trim(v_moneda) = "" THEN` |  |
| L1025 | FÓRMULA | `LET cod_ret = "96a"; --OK` |  |
| L1062 | FÓRMULA | `LET cod_ret = "996"; --OK` |  |
| L1099 | VALIDACIÓN_NULL | `IF v_ccosto_orig IS NULL OR trim(v_ccosto_orig) = "" THEN` |  |
| L1100 | FÓRMULA | `LET cod_ret = "165"; --OK` |  |
| L1137 | FÓRMULA | `LET cod_ret = "165"; --OK` |  |
| | *…7 más…* | | |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `valida` | ACCION | valida | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `poliza` | ENTIDAD | póliza contable | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `nomina` | ENTIDAD | nómina | 🔵 CONVENCIÓN | nombre_sp |
| `respaldo` | ENTIDAD | respaldo / garantía de crédito (aval) | 🟡 INFERIDO | nombre_sp |

---

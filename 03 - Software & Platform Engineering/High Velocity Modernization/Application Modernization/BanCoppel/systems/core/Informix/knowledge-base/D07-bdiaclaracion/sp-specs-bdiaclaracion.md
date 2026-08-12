# SP Specs — D07 · `bdiaclaracion` · Aclaraciones

> Generado por `build-sp-specs.py` · Grounding Pass v1.0
> Objetivo: verificar el conocimiento del Gemelo Cognitivo contra el código fuente real
> **Convención:** solo se analiza el PRIMER `CREATE PROCEDURE` de cada archivo
> (los siguientes son dependencias concatenadas — ver memoria del proyecto)

## Resumen de validación del dominio

| Métrica | Valor |
|---------|-------|
| SPs analizados | **232** |
| Presentes en callgraph | 84 |
| SPs aislados (⚠️ no estaban en el análisis previo) | 148 |
| Propósito **VERIFICADO** | 86 |
| Propósito **PARCIAL** | 143 |
| Propósito **NO_VERIFICABLE** | 3 |
| SPs con tokens **SINTÉTICOS** detectados | 123 |

> Los **148 SPs aislados** no aparecen en el callgraph y por tanto
> **no fueron incluidos en el análisis de journeys, reglas ni vocabulario previo**.
> Este grounding pass los analiza por primera vez directamente desde el código.

---

## `sp_acl_actualizaempaclaracion`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_acl_actualizaempaclaracion.sql` |
| **LOC (1er CREATE)** | 42 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 16 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "actualiza Empresa — empleadora del cliente; vinculada a crédito de nómina y aclaración bancaria — proceso de disputa o reclamación del cliente" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `actualiza` → `UPDATE` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=0 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_acl_actualizaempaclaracion(
  pUsuario                     CHAR(8)
  pKyaclaracion                INTEGER
) RETURNING CHAR(5) AS codret
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pUsuario` | `CHAR(8)` | — | — |
| `pKyaclaracion` | `INTEGER` | `acl`=familia aclaraciones · `aclaracion`=aclaración bancaria — proceso de disputa o reclamación del cliente | ✅ CÓDIGO |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(5)` | L4 |
| `iSqlErr` | `INTEGER` | L5 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `acl_aclaracion` | `bdiaclaracion` | no | UPDATE | L27 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L7 | CÓDIGO_RETORNO | `LET cCodRet = '00000';` |  |
| L23 | CÓDIGO_RETORNO | `LET cCodRet = '00003';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `acl` | PREFIJO | familia aclaraciones | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `actualiza` | ACCION | actualiza | 🔵 CONVENCIÓN | nombre_sp |
| `emp` | ENTIDAD | Empresa — empleadora del cliente; vinculada a crédito de nóm | 🔵 CONVENCIÓN | nombre_sp |
| `aclaracion` | ENTIDAD | aclaración bancaria — proceso de disputa o reclamación del c | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |

---

## `sp_acl_asosacionorigentransaccion`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_acl_asosacionorigentransaccion.sql` |
| **LOC (1er CREATE)** | 57 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 3 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "OS — Originación de Solicitudes, origen y transacción" `[partial]` |
| **Propósito verificado** | ❓ NO_VERIFICABLE — Propósito inferido; sin evidencia DML para verificar |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=2 · INFERIDO=1 · SINTÉTICO=2 / 7 términos |

### Firma

```sql
CREATE PROCEDURE sp_acl_asosacionorigentransaccion(
  pOrigen_evento               INTEGER
) RETURNING CHAR(5) AS codret,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pOrigen_evento` | `INTEGER` | `origen`=origen | ✅ CÓDIGO |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(5)` | L5 |
| `iSqlErr` | `INTEGER` | L6 |
| `cTransaccion` | `CHAR(4)` | L7 |
| `iRegistros` | `INTEGER` | L8 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L10 | CÓDIGO_RETORNO | `LET cCodRet = '00000';` |  |
| L26 | VALIDACIÓN_NULL | `IF pOrigen_evento IS NULL THEN` |  |
| L27 | CÓDIGO_RETORNO | `LET cCodRet = '00003';` |  |
| L40 | FÓRMULA | `LET iRegistros = iRegistros + 1;` |  |
| L45 | CÓDIGO_RETORNO | `LET cCodRet = '00017';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `acl` | PREFIJO | familia aclaraciones | 🔵 CONVENCIÓN | nombre_sp |
| `?_as` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `os` | ENTIDAD | OS — Originación de Solicitudes / subsistema de ofertas (sp_ | 🟡 INFERIDO | nombre_sp |
| `?acion` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `origen` | ENTIDAD | origen | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `transaccion` | ENTIDAD | transacción | ✅ CÓDIGO | nombre_sp, texto_cuerpo |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_as`, `?acion` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_acl_busca_cliente_sv`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_acl_busca_cliente_sv.sql` |
| **LOC (1er CREATE)** | 92 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 4 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "busca cliente y sv — supervisión/servicio" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 2 llamada(s): `sp_buscarclientesportarjeta`, `sp_buscarclientesporcuenta` |
| **Evidencia vocab** | CÓDIGO=3 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=0 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_acl_busca_cliente_sv(
  p_cCuentaTarjeta             CHAR(30)
) RETURNING CHAR(20) AS noCliente,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_cCuentaTarjeta` | `CHAR(30)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `resultado_numeroCliente` | `CHAR(20)` | L11 |
| `resultado_primerApellido` | `CHAR(30)` | L12 |
| `resultado_segundoApellido` | `CHAR(30)` | L13 |
| `resultado_primerNombre` | `CHAR(30)` | L14 |
| `resultado_segundoNombre` | `CHAR(30)` | L15 |
| `iSqlErr` | `INTEGER` | L16 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_credito_sv` | `bdinteg` | ⚠️ sí | SELECT | L51 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_buscarclientesportarjeta` | `bdinteg` | ⚠️ sí | L70 |
| `sp_buscarclientesporcuenta` | `bdinteg` | ⚠️ sí | L77 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L56 | VALIDACIÓN_NULL | `IF ( resultado_numeroCliente IS NULL ) THEN` |  |
| L69 | VALIDACIÓN_NULL | `IF ( resultado_numeroCliente IS NULL ) THEN` |  |
| L76 | VALIDACIÓN_NULL | `IF ( resultado_numeroCliente IS NULL ) THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `acl` | PREFIJO | familia aclaraciones | 🔵 CONVENCIÓN | nombre_sp |
| `busca` | ACCION | busca / localiza | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `cliente` | ENTIDAD | cliente | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `sv` | ENTIDAD | sv — supervisión/servicio (abreviación — bdiaclaracion) | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |

---

## `sp_acl_busca_datos_3410_fda`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_acl_busca_datos_3410_fda.sql` |
| **LOC (1er CREATE)** | 199 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 10 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "busca datos" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 1 llamada(s): `sp_busca_datos_3410_fda` |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=4 · INFERIDO=0 · SINTÉTICO=1 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_acl_busca_datos_3410_fda(
  pFolioCsuac                  CHAR(11)
) RETURNING CHAR(5)				            AS cod_ret,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pFolioCsuac` | `CHAR(11)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `sql_err` | `INTEGER` | L47 |
| `v_cod_ret` | `CHAR(5)` | L48 |
| `v_num_tarjeta` | `CHAR(16)` | L49 |
| `v_procede_abono_tmp` | `SMALLINT` | L50 |
| `v_es_diferencia_importes` | `SMALLINT` | L51 |
| `v_es_tarjeta_presente` | `SMALLINT` | L52 |
| `v_modo_entrada` | `CHAR(2)` | L53 |
| `es_chip_mas_nip` | `SMALLINT` | L54 |
| `es_fda_exitoso` | `SMALLINT` | L55 |
| `c_cod_primer_fda` | `CHAR(2)` | L56 |
| `c_cod_segundo_fda` | `CHAR(2)` | L57 |
| `c_desc_primer_fda` | `CHAR(50)` | L58 |
| `c_desc_segundo_fda` | `CHAR(50)` | L59 |
| `c_dictamen_noprocede` | `CHAR(255)` | L60 |
| `v_num_autorizacion` | `CHAR(6)` | L61 |
| `v_fecha_movimiento_libe` | `DATETIME YEAR TO FRACTION(5)` | L62 |
| `v_desc_estatus_tarjeta` | `CHAR(30)` | L63 |
| `v_fecha_reporte_tarjeta` | `DATETIME YEAR TO FRACTION(5)` | L64 |
| `v_fecha_movimiento` | `DATETIME YEAR TO FRACTION(5)` | L65 |
| `v_importereclamado` | `MONEY` | L66 |
| `v_comercio` | `CHAR(40)` | L67 |
| `v_receptor` | `CHAR(40)` | L68 |
| `c_banco_adquirente` | `CHAR(55)` | L69 |
| `c_ip` | `CHAR(15)` | L70 |
| `c_dato_no_convencional` | `CHAR(85)` | L71 |
| *…19 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `bdiaclaracion` | `bdiaclaracion` | no | INSERT | L180 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_busca_datos_3410_fda` | `bdiaclaracion` | no | L169 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `acl` | PREFIJO | familia aclaraciones | 🔵 CONVENCIÓN | nombre_sp |
| `busca` | ACCION | busca / localiza | 🔵 CONVENCIÓN | nombre_sp |
| `datos` | ENTIDAD | datos | 🔵 CONVENCIÓN | nombre_sp |
| `?_3410_fda` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_3410_fda` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_acl_consulta_ciudad_estado_formobjeccion`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_acl_consulta_ciudad_estado_formobjeccion.sql` |
| **LOC (1er CREATE)** | 64 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 3 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "consulta ciudad y estado" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=1 / 6 términos |

### Firma

```sql
CREATE PROCEDURE sp_acl_consulta_ciudad_estado_formobjeccion(
  pNumcte                      CHAR(9)
) RETURNING CHAR(5) AS codRet,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pNumcte` | `CHAR(9)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(5)` | L6 |
| `iSqlErr` | `INT` | L7 |
| `cDesCiudad` | `CHAR(50)` | L9 |
| `cDescEstado` | `CHAR(50)` | L10 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_direcciones_actual` | `bdinteg` | ⚠️ sí | SELECT | L40 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L13 | CÓDIGO_RETORNO | `LET cCodRet = '00000';` |  |
| L30 | CÓDIGO_RETORNO | `LET cCodRet = '00003';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `acl` | PREFIJO | familia aclaraciones | 🔵 CONVENCIÓN | nombre_sp |
| `consulta` | ACCION | consulta / lee | 🔵 CONVENCIÓN | nombre_sp |
| `ciudad` | ENTIDAD | ciudad | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `estado` | ENTIDAD | estado (entidad federativa / estatus) | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?_formobjeccion` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_formobjeccion` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_acl_consulta_ciudades`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_acl_consulta_ciudades.sql` |
| **LOC (1er CREATE)** | 55 |
| **Callgraph** | ✅ fan_in=0 / fan_out=2 |
| **Deps concatenadas** | 13 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "consulta ciudades" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=0 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_acl_consulta_ciudades(
  p_skip                       INT
  p_Estado                     CHAR(2)
) RETURNING CHAR(4) AS pais, CHAR(4) AS numeroEstado, CHAR(4) AS claveCiudad, CHAR(30) AS nombreCiudad
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_skip` | `INT` | — | — |
| `p_Estado` | `CHAR(2)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `resultado_pais` | `CHAR(4)` | L6 |
| `resultado_numeroEstado` | `CHAR(4)` | L7 |
| `resultado_claveCiudad` | `CHAR(4)` | L8 |
| `resultado_nombreCiudad` | `CHAR(30)` | L9 |
| `iSqlErr` | `INTEGER` | L10 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_ciudades` | `bdinteg` | ⚠️ sí | SELECT | L36 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `acl` | PREFIJO | familia aclaraciones | 🔵 CONVENCIÓN | nombre_sp |
| `consulta` | ACCION | consulta / lee | 🔵 CONVENCIÓN | nombre_sp |
| `ciudades` | ENTIDAD | ciudades (catálogo) | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |

---

## `sp_acl_consulta_perfil_usuario`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_acl_consulta_perfil_usuario.sql` |
| **LOC (1er CREATE)** | 114 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 2 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "consulta perfil de usuario y usuario" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=3 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=0 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_acl_consulta_perfil_usuario(
  pUsuario                     CHAR(9)
) RETURNING CHAR(5)   AS codret,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pUsuario` | `CHAR(9)` | `usuario`=usuario | ✅ CÓDIGO |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodret` | `CHAR(5)` | L5 |
| `cNombre` | `CHAR(100)` | L6 |
| `iSqlErr` | `INTEGER` | L7 |
| `iBandera` | `INTEGER` | L8 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `acl_usuario` | `bdiaclaracion` | no | SELECT | L38 |
| `si_ejecut` | `bdinteg` | ⚠️ sí | SELECT | L55 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L10 | CÓDIGO_RETORNO | `LET cCodRet = '00000';` |  |
| L22 | VALIDACIÓN_NULL | `IF pUsuario IS NULL OR pUsuario = '' THEN` |  |
| L23 | CÓDIGO_RETORNO | `LET cCodRet = '00003';` |  |
| L68 | VALIDACIÓN_NULL | `IF iBandera = 0 OR iBandera IS NULL THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `acl` | PREFIJO | familia aclaraciones | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `consulta` | ACCION | consulta / lee | 🔵 CONVENCIÓN | nombre_sp |
| `perfil` | ENTIDAD | perfil de usuario | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `usuario` | ENTIDAD | usuario | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |

---

## `sp_acl_consultadevolucion`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_acl_consultadevolucion.sql` |
| **LOC (1er CREATE)** | 95 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 9 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "consulta" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=0 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_acl_consultadevolucion(
  pFolio_csuac                 CHAR(16)
) RETURNING CHAR(5)     AS codret,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pFolio_csuac` | `CHAR(16)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(5)` | L8 |
| `iSqlErr` | `INTEGER` | L9 |
| `v_montoDevo` | `MONEY(16,2)` | L10 |
| `v_fecha` | `DATE` | L11 |
| `v_procede` | `SMALLINT` | L12 |
| `v_tarjeta` | `CHAR(16)` | L13 |
| `v_devo` | `SMALLINT` | L14 |
| `vImporteReclamado` | `MONEY` | L15 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `td_movimientos_conciliacion` | `bditarjeta` | ⚠️ sí | SELECT | L70 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L17 | CÓDIGO_RETORNO | `LET cCodRet = '00000';` |  |
| L39 | CÓDIGO_RETORNO | `LET cCodRet = '00003';` |  |
| L48 | VALIDACIÓN_NULL | `IF v_fecha IS NULL THEN` |  |
| L49 | CÓDIGO_RETORNO | `LET cCodRet = '00017';` |  |
| L58 | VALIDACIÓN_NULL | `IF v_tarjeta IS NULL THEN` |  |
| L59 | CÓDIGO_RETORNO | `LET cCodRet = '00017';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `acl` | PREFIJO | familia aclaraciones | 🔵 CONVENCIÓN | nombre_sp |
| `consulta` | ACCION | consulta / lee | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `devolucion` | ACCION | devuelve | ✅ CÓDIGO | nombre_sp, texto_cuerpo |

---

## `sp_acl_consultafectacion`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_acl_consultafectacion.sql` |
| **LOC (1er CREATE)** | 56 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 8 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "consulta cuenta" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=4 · INFERIDO=0 · SINTÉTICO=2 / 6 términos |

### Firma

```sql
CREATE PROCEDURE sp_acl_consultafectacion(
  pFolioCsuac                  CHAR(16)
) RETURNING CHAR(5) AS codret,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pFolioCsuac` | `CHAR(16)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(5)` | L6 |
| `iSqlErr` | `INTEGER` | L7 |
| `cNombre` | `CHAR(30)` | L8 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L10 | CÓDIGO_RETORNO | `LET cCodRet = '00000';` |  |
| L28 | VALIDACIÓN_NULL | `IF pFolioCsuac = '' OR pFolioCsuac IS NULL THEN` |  |
| L29 | CÓDIGO_RETORNO | `LET cCodRet = '00003';` |  |
| L43 | CÓDIGO_RETORNO | `LET cCodRet = '00017';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `acl` | PREFIJO | familia aclaraciones | 🔵 CONVENCIÓN | nombre_sp |
| `consulta` | ACCION | consulta / lee | 🔵 CONVENCIÓN | nombre_sp |
| `?fe` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `cta` | ENTIDAD | cuenta | 🔵 CONVENCIÓN | nombre_sp |
| `?cion` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?fe`, `?cion` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_acl_consultatipoeventosabono`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_acl_consultatipoeventosabono.sql` |
| **LOC (1er CREATE)** | 44 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 4 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "consulta evento/notificación y abono (tipo de)" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=3 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=1 / 7 términos |

### Firma

```sql
CREATE PROCEDURE sp_acl_consultatipoeventosabono(
  p_skip                       INT
) RETURNING CHAR(5) AS codret,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_skip` | `INT` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(5)` | L5 |
| `iSqlErr` | `INTEGER` | L6 |
| `cDescripcion` | `CHAR(150)` | L7 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `acl_tipo_eventos_abono` | `bdiaclaracion` | no | SELECT | L29 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L9 | CÓDIGO_RETORNO | `LET cCodRet = '00000';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `acl` | PREFIJO | familia aclaraciones | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `consulta` | ACCION | consulta / lee | 🔵 CONVENCIÓN | nombre_sp |
| `tipo` | MODIF | tipo de | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `evento` | ENTIDAD | evento/notificación | 🔵 CONVENCIÓN | nombre_sp |
| `?s` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `abono` | ENTIDAD | abono / crédito | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?s` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_acl_es_cliente_sv`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_acl_es_cliente_sv.sql` |
| **LOC (1er CREATE)** | 52 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 1 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "cliente y sv — supervisión/servicio" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 1 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=1 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_acl_es_cliente_sv(
  p_numCte                     CHAR(20)
  p_numCta                     CHAR(20)
  p_numTar                     CHAR(20)
) RETURNING INTEGER AS isSmartVista
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_numCte` | `CHAR(20)` | — | — |
| `p_numCta` | `CHAR(20)` | — | — |
| `p_numTar` | `CHAR(20)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `isSmartVista` | `INTEGER` | L7 |
| `iSqlErr` | `INTEGER` | L9 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_credito_sv` | `bdinteg` | ⚠️ sí | SELECT | L29 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `acl` | PREFIJO | familia aclaraciones | 🔵 CONVENCIÓN | nombre_sp |
| `?_es_` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `cliente` | ENTIDAD | cliente | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `sv` | ENTIDAD | sv — supervisión/servicio (abreviación — bdiaclaracion) | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_es_` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_acl_insertalog`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_acl_insertalog.sql` |
| **LOC (1er CREATE)** | 58 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 11 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "inserta" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `inserta` → `INSERT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=1 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_acl_insertalog(
  pUsuario                     CHAR(8)
  pFlujo                       CHAR(30)
  pNumCliente                  CHAR(20)
  pIdPreg                      CHAR(2)
  pRespuesta                   CHAR(100)
  pRespuestaCorrecta           CHAR(1)
  pBandera                     CHAR(1)
) RETURNING CHAR(5) AS codret
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pUsuario` | `CHAR(8)` | — | — |
| `pFlujo` | `CHAR(30)` | — | — |
| `pNumCliente` | `CHAR(20)` | — | — |
| `pIdPreg` | `CHAR(2)` | — | — |
| `pRespuesta` | `CHAR(100)` | `sp`=stored procedure | 🔵 CONVENCIÓN |
| `pRespuestaCorrecta` | `CHAR(1)` | `sp`=stored procedure | 🔵 CONVENCIÓN |
| `pBandera` | `CHAR(1)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(5)` | L4 |
| `iSqlErr` | `INTEGER` | L5 |
| `cTipoPreg` | `CHAR(2)` | L6 |
| `cTipoCombo` | `CHAR(2)` | L7 |
| `cPregunta` | `CHAR(200)` | L8 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `acl_logautenticacion` | `bdiaclaracion` | no | INSERT | L32 |
| `acl_prg_inises_autcte` | `bdiaclaracion` | no | SELECT | L35 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L10 | CÓDIGO_RETORNO | `LET cCodRet = '00000';` |  |
| L44 | CÓDIGO_RETORNO | `LET cCodRet ='99999';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `acl` | PREFIJO | familia aclaraciones | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `inserta` | ACCION | inserta / registra | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?log` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?log` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_acl_montototal_sv`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_acl_montototal_sv.sql` |
| **LOC (1er CREATE)** | 52 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 3 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "monto y sv — supervisión/servicio (total)" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 1 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=3 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=1 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_acl_montototal_sv(
  pFoliosuc                    CHAR(30)
) RETURNING CHAR(4) AS code,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pFoliosuc` | `CHAR(30)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `returnCode` | `CHAR(4)` | L8 |
| `returnTotal` | `MONEY` | L9 |
| `counter` | `INTEGER` | L10 |
| `iSqlErr` | `INTEGER` | L11 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `acl_movimiento` | `bdiaclaracion` | no | SELECT | L35 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L16 | FÓRMULA | `LET counter = -1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `acl` | PREFIJO | familia aclaraciones | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `monto` | ENTIDAD | monto | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `total` | MODIF | total | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `sv` | ENTIDAD | sv — supervisión/servicio (abreviación — bdiaclaracion) | 🔴 SINTÉTICO | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `sv` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_acl_obtenerlogpreguntas`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_acl_obtenerlogpreguntas.sql` |
| **LOC (1er CREATE)** | 177 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 18 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "obtiene" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `obtiene` → `SELECT` encontrado en el cuerpo · `obtiene` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=2 · INFERIDO=1 · SINTÉTICO=2 / 6 términos |

### Firma

```sql
CREATE PROCEDURE sp_acl_obtenerlogpreguntas(
  pNoCliente                   CHAR(20)
  pTipo                        CHAR(1)
) RETURNING CHAR(5) AS codret,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pNoCliente` | `CHAR(20)` | — | — |
| `pTipo` | `CHAR(1)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(5)` | L5 |
| `iSqlErr` | `INTEGER` | L6 |
| `iNum_combo` | `INTEGER` | L7 |
| `iAux` | `INTEGER` | L8 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `acl_prg_inises_autcte` | `bdiaclaracion` | no | SELECT | L34 |
| `acl_logautenticacion` | `bdiaclaracion` | no | SELECT | L35 |
| `acl_logautenticacion` | `bdiaclaracion` | no | UPDATE | L46 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L10 | CÓDIGO_RETORNO | `LET cCodRet = '00000';` |  |
| L40 | FÓRMULA | `LET iAux = iAux+1;` |  |
| L58 | FÓRMULA | `LET iAux = iAux+1;` |  |
| L65 | VALIDACIÓN_NULL | `IF (iNum_combo IS NULL) THEN` |  |
| L84 | FÓRMULA | `LET iAux = iAux+1;` |  |
| L102 | FÓRMULA | `LET iAux = iAux+1;` |  |
| L109 | VALIDACIÓN_NULL | `IF (iNum_combo IS NULL) THEN` |  |
| L128 | FÓRMULA | `LET iAux = iAux+1;` |  |
| L147 | FÓRMULA | `LET iAux = iAux+1;` |  |
| L156 | VALIDACIÓN_NULL | `IF (iNum_combo IS NULL) THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `acl` | PREFIJO | familia aclaraciones | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `obtener` | ACCION | obtiene / recupera | 🔵 CONVENCIÓN | nombre_sp |
| `?logp` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `reg` | ACCION | registro | 🟡 INFERIDO | nombre_sp |
| `?untas` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?logp`, `?untas` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_acl_obtenernombreestados`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_acl_obtenernombreestados.sql` |
| **LOC (1er CREATE)** | 50 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 17 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "obtiene nombre y estado" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `obtiene` → `SELECT` encontrado en el cuerpo · `obtiene` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=1 / 6 términos |

### Firma

```sql
CREATE PROCEDURE sp_acl_obtenernombreestados(
) RETURNING CHAR(5) AS codret,
```

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(5)` | L6 |
| `iSqlErr` | `INTEGER` | L7 |
| `cNum_estado` | `CHAR(2)` | L8 |
| `cNom_estado` | `CHAR(30)` | L9 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_estados` | `bdinteg` | ⚠️ sí | SELECT | L31 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L11 | CÓDIGO_RETORNO | `LET cCodRet = '00000';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `acl` | PREFIJO | familia aclaraciones | 🔵 CONVENCIÓN | nombre_sp |
| `obtener` | ACCION | obtiene / recupera | 🔵 CONVENCIÓN | nombre_sp |
| `nombre` | ENTIDAD | nombre | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `estado` | ENTIDAD | estado (entidad federativa / estatus) | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `?s` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?s` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_acl_obtenerpreguntasiniciosesion`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_acl_obtenerpreguntasiniciosesion.sql` |
| **LOC (1er CREATE)** | 64 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 15 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "obtiene (inicio)" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `obtiene` → `SELECT` encontrado en el cuerpo · `obtiene` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=2 · INFERIDO=1 · SINTÉTICO=3 / 8 términos |

### Firma

```sql
CREATE PROCEDURE sp_acl_obtenerpreguntasiniciosesion(
  pTipoPreg                    CHAR(1)
  pTipoCombo                   CHAR(2)
) RETURNING CHAR(5) AS codret,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pTipoPreg` | `CHAR(1)` | `reg`=registro | 🟡 INFERIDO |
| `pTipoCombo` | `CHAR(2)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(5)` | L9 |
| `iSqlErr` | `INTEGER` | L10 |
| `cPregunta` | `CHAR(200)` | L11 |
| `cComponente` | `CHAR(30)` | L12 |
| `cTipoCaptura` | `CHAR(30)` | L13 |
| `iNumCaracteres` | `INTEGER` | L14 |
| `iId` | `INTEGER` | L15 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `acl_prg_inises_autcte` | `bdiaclaracion` | no | SELECT | L41 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L17 | CÓDIGO_RETORNO | `LET cCodRet = '00000';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `acl` | PREFIJO | familia aclaraciones | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `obtener` | ACCION | obtiene / recupera | 🔵 CONVENCIÓN | nombre_sp |
| `?p` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `reg` | ACCION | registro | 🟡 INFERIDO | nombre_sp |
| `?untas` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `inicio` | MODIF | inicio | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?sesion` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?p`, `?untas`, `?sesion` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_acl_regulatorio27`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_acl_regulatorio27.sql` |
| **LOC (1er CREATE)** | 351 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "registro" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 11 tabla(s) con operaciones: SELECT, INSERT |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=1 · INFERIDO=1 · SINTÉTICO=1 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_acl_regulatorio27(
  pFechaCap_Ini                DATE
  pFechaCap_Fin                DATE
) RETURNING CHAR(5)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pFechaCap_Ini` | `DATE` | — | — |
| `pFechaCap_Fin` | `DATE` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `CodRet` | `CHAR(5)` | L9 |
| `icontador` | `integer` | L10 |
| `v_folio_csuac` | `VARCHAR (11)` | L11 |
| `v_fechacaptura` | `DATE` | L12 |
| `v_importereclamado` | `MONEY` | L13 |
| `v_fky_estatus_aclaracion` | `INTEGER` | L14 |
| `v_fecha_dictamen` | `DATEtime YEAR to FRACTION(5)` | L15 |
| `v_montoprocedente` | `MONEY` | L16 |
| `v_fky_tipo_codigo_resolucion` | `INTEGER` | L17 |
| `v_procede` | `SMALLINT` | L18 |
| `v_fky_producto` | `INTEGER` | L19 |
| `v_fky_tipo_evento` | `INTEGER` | L20 |
| `v_fky_estatus_corp_general` | `INTEGER` | L21 |
| `v_fechahora` | `DATEtime YEAR to FRACTION(5)` | L22 |
| `v_fecha_abono` | `DATEtime YEAR to FRACTION(5)` | L23 |
| `v_fky_tipo_producto` | `INTEGER` | L24 |
| `v_numero_cuenta` | `VARCHAR (20)` | L25 |
| `v_numero_tarjeta` | `VARCHAR (16)` | L26 |
| `v_pky_tipo_producto` | `INTEGER` | L27 |
| `v_des_tipo_producto` | `VARCHAR (255)` | L28 |
| `v_origen_evento` | `INTEGER` | L29 |
| `v_pky_tipo_evento` | `INTEGER` | L30 |
| `v_desc_evento` | `VARCHAR (50)` | L31 |
| `v_desc_origen` | `VARCHAR (50)` | L32 |
| `v_desc_aclaracion` | `VARCHAR (255)` | L33 |
| *…12 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `acl_aclaracion` | `bdiaclaracion` | no | SELECT | L105 |
| `acl_movimiento` | `bdiaclaracion` | no | SELECT | L126 |
| `acl_producto` | `bdiaclaracion` | no | SELECT | L142 |
| `acl_tipo_producto` | `bdiaclaracion` | no | SELECT | L148 |
| `acl_tipo_evento` | `bdiaclaracion` | no | SELECT | L154 |
| `acl_origen_evento` | `bdiaclaracion` | no | SELECT | L160 |
| `acl_estatus_aclaracion` | `bdiaclaracion` | no | SELECT | L166 |
| `acl_estatus_corporativo` | `bdiaclaracion` | no | SELECT | L172 |
| `acl_tipo_codigo_resolucion` | `bdiaclaracion` | no | SELECT | L178 |
| `acl_regulatorio27` | `bdiaclaracion` | no | SELECT | L185 |
| `acl_regulatorio27` | `bdiaclaracion` | no | INSERT | L327 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L61 | CÓDIGO_RETORNO | `LET CodRet                            = '00000';` |  |
| L254 | VALIDACIÓN_NULL | `IF v_quebranto_inst IS NULL THEN    -- ValidaciÃ³n de monto quebrantado para que no se coloque en nu` |  |
| L258 | VALIDACIÓN_NULL | `IF v_montoprocedente IS NULL THEN   -- ValidaciÃ³n de monto procedente para que no se coloque en nul` |  |
| L262 | VALIDACIÓN_NULL | `IF v_importe_rec IS NULL THEN       -- ValidaciÃ³n de monto recuperado para que no se coloque en nul` |  |
| L268 | VALIDACIÓN_NULL | `IF v_fky_estatus_aclaracion in (3,4,5) AND v_procede IS NULL AND v_fky_estatus_corp_general = 19 THE` |  |
| L270 | FÓRMULA | `LET v_procede = 1 ; -- Abono a favor del Cliente` |  |
| L299 | FÓRMULA | `LET v_montoprocedente 	= 0;    -- ValidaciÃ³n de monto procedente para que no se coloque en null` | 🔴 MONEY/aritmética financiera |
| L300 | FÓRMULA | `LET v_importe_rec 		= 0;	-- ValidaciÃ³n de monto recuperado para que no se coloque en null` | 🔴 MONEY/aritmética financiera |
| L301 | FÓRMULA | `LET v_quebranto_inst 	= 0;	-- ValidaciÃ³n de monto quebrantado para que no se coloque en null` | 🔴 MONEY/aritmética financiera |
| L313 | FÓRMULA | `LET v_fky_estatus_aclaracion = 2;	-- Cambiar estatus de la aclaraciÃ³n a 2` |  |
| L321 | VALIDACIÓN_NULL | `IF (SUBSTR (v_numero_cuenta , 0, 4) IN ('1900', '2200') AND v_numero_tarjeta = '' OR v_numero_tarjet` |  |
| L333 | FÓRMULA | `LET iContador = iContador + 1;` |  |
| L347 | CÓDIGO_RETORNO | `LET CodRet = '00000';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `acl` | PREFIJO | familia aclaraciones | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `reg` | ACCION | registro | 🟡 INFERIDO | nombre_sp |
| `?ulatorio27` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?ulatorio27` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_acl_regulatorio27_mx`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_acl_regulatorio27_mx.sql` |
| **LOC (1er CREATE)** | 335 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "registro" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 12 tabla(s) con operaciones: SELECT, INSERT, UPDATE |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=2 · INFERIDO=1 · SINTÉTICO=1 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_acl_regulatorio27_mx(
  pFechaCap_Ini                DATE
  pFechaCap_Fin                DATE
) RETURNING CHAR(5)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pFechaCap_Ini` | `DATE` | — | — |
| `pFechaCap_Fin` | `DATE` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `CodRet` | `CHAR(5)` | L9 |
| `v_folio_csuac` | `VARCHAR (11)` | L11 |
| `v_fechacaptura` | `DATE` | L12 |
| `v_importereclamado` | `MONEY` | L13 |
| `v_fky_estatus_aclaracion` | `INTEGER` | L14 |
| `v_fecha_dictamen` | `DATEtime YEAR to FRACTION(5)` | L15 |
| `v_montoprocedente` | `MONEY` | L16 |
| `v_fky_tipo_codigo_resolucion` | `INTEGER` | L17 |
| `v_procede` | `SMALLINT` | L18 |
| `v_fky_producto` | `INTEGER` | L19 |
| `v_fky_tipo_evento` | `INTEGER` | L20 |
| `v_fky_estatus_corp_general` | `INTEGER` | L21 |
| `v_fechahora` | `DATEtime YEAR to FRACTION(5)` | L22 |
| `v_fecha_abono` | `DATEtime YEAR to FRACTION(5)` | L23 |
| `v_fky_tipo_producto` | `INTEGER` | L24 |
| `v_numero_cuenta` | `VARCHAR (20)` | L25 |
| `v_numero_tarjeta` | `VARCHAR (16)` | L26 |
| `v_pky_tipo_producto` | `INTEGER` | L27 |
| `v_des_tipo_producto` | `VARCHAR (255)` | L28 |
| `v_origen_evento` | `INTEGER` | L29 |
| `v_pky_tipo_evento` | `INTEGER` | L30 |
| `v_desc_evento` | `VARCHAR (50)` | L31 |
| `v_desc_origen` | `VARCHAR (50)` | L32 |
| `v_desc_aclaracion` | `VARCHAR (255)` | L33 |
| `v_pky_estatus_corporativo` | `INTEGER` | L34 |
| *…11 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `acl_aclaracion` | `bdiaclaracion` | no | SELECT | L102 |
| `acl_movimiento` | `bdiaclaracion` | no | SELECT | L122 |
| `acl_producto` | `bdiaclaracion` | no | SELECT | L138 |
| `acl_tipo_producto` | `bdiaclaracion` | no | SELECT | L144 |
| `acl_tipo_evento` | `bdiaclaracion` | no | SELECT | L150 |
| `acl_origen_evento` | `bdiaclaracion` | no | SELECT | L156 |
| `acl_estatus_aclaracion` | `bdiaclaracion` | no | SELECT | L162 |
| `acl_estatus_corporativo` | `bdiaclaracion` | no | SELECT | L168 |
| `acl_tipo_codigo_resolucion` | `bdiaclaracion` | no | SELECT | L174 |
| `acl_regulatorio27` | `bdiaclaracion` | no | SELECT | L181 |
| `acl_regulatorio27` | `bdiaclaracion` | no | INSERT | L323 |
| `acl_control_r27` | `bdiaclaracion` | no | UPDATE | L329 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L59 | CÓDIGO_RETORNO | `LET CodRet                            = '00000';` |  |
| L250 | VALIDACIÓN_NULL | `IF v_quebranto_inst IS NULL THEN    -- ValidaciÃ³n de monto quebrantado para que no se coloque en nu` |  |
| L254 | VALIDACIÓN_NULL | `IF v_montoprocedente IS NULL THEN   -- ValidaciÃ³n de monto procedente para que no se coloque en nul` |  |
| L258 | VALIDACIÓN_NULL | `IF v_importe_rec IS NULL THEN       -- ValidaciÃ³n de monto recuperado para que no se coloque en nul` |  |
| L264 | VALIDACIÓN_NULL | `IF v_fky_estatus_aclaracion in (3,4,5) AND v_procede IS NULL AND v_fky_estatus_corp_general = 19 THE` |  |
| L266 | FÓRMULA | `LET v_procede = 1 ; -- Abono a favor del Cliente` |  |
| L295 | FÓRMULA | `LET v_montoprocedente 	= 0;    -- ValidaciÃ³n de monto procedente para que no se coloque en null` | 🔴 MONEY/aritmética financiera |
| L296 | FÓRMULA | `LET v_importe_rec 		= 0;	-- ValidaciÃ³n de monto recuperado para que no se coloque en null` | 🔴 MONEY/aritmética financiera |
| L297 | FÓRMULA | `LET v_quebranto_inst 	= 0;	-- ValidaciÃ³n de monto quebrantado para que no se coloque en null` | 🔴 MONEY/aritmética financiera |
| L309 | FÓRMULA | `LET v_fky_estatus_aclaracion = 2;	-- Cambiar estatus de la aclaraciÃ³n a 2` |  |
| L317 | VALIDACIÓN_NULL | `IF (SUBSTR (v_numero_cuenta , 0, 4) IN ('1900', '2200') AND v_numero_tarjeta = '' OR v_numero_tarjet` |  |
| L331 | CÓDIGO_RETORNO | `LET CodRet = '00000';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `acl` | PREFIJO | familia aclaraciones | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `reg` | ACCION | registro | 🟡 INFERIDO | nombre_sp |
| `?ulatorio27_m` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `x` | MODIF | por (criterio) | 🔵 CONVENCIÓN | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?ulatorio27_m` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_acl_reporte_log`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_acl_reporte_log.sql` |
| **LOC (1er CREATE)** | 142 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 5 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "reporte" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 2 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=1 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_acl_reporte_log(
) RETURNING CHAR(5) AS codret,
```

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(5)` | L5 |
| `iSqlErr` | `INTEGER` | L6 |
| `cCmd1` | `CHAR(4000)` | L7 |
| `cSql` | `CHAR(4000)` | L8 |
| `cRutaGral` | `CHAR(150)` | L9 |
| `cNombreArchivo` | `CHAR(100)` | L10 |
| `iTotal` | `INTEGER` | L11 |
| `dFechaHoy` | `DATE` | L12 |
| `dHoraHoy` | `DATETIME HOUR TO SECOND` | L13 |
| `cFechaHoraArchivo` | `CHAR(35)` | L14 |
| `nomFecha` | `CHAR(19)` | L15 |
| `cFecha` | `CHAR(10)` | L16 |
| `pRutaDescarga` | `CHAR(50)` | L17 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `systables` | `bdiaclaracion` | no | SELECT | L59 |
| `acl_reporte_log` | `bdiaclaracion` | no | SELECT | L60 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L19 | CÓDIGO_RETORNO | `LET cCodRet = '00000';` |  |
| L44 | CÓDIGO_RETORNO | `LET cCodRet = '00003';` |  |
| L60 | FÓRMULA | `LET cCmd1 =""\|\|TRIM(cCmd1)\|\|" UNION ALL SELECT * FROM (SELECT UNIQUE folio, TO_CHAR(fecha_transa` |  |
| L67 | FÓRMULA | `LET cRutaGral = TRIM(pRutaDescarga)\|\|'/'\|\|TRIM(cNombreArchivo);` |  |
| L95 | FÓRMULA | `LET cSql = "sed "\|\|"'s/$'""/`echo \\\r`/"" "\|\|TRIM(cRutaGral)\|\|" > "\|\|TRIM(cRutaGral)\|\|".t` |  |
| L100 | FÓRMULA | `LET cSql = "rm -rf "\|\|TRIM(cRutaGral);` |  |
| L109 | FÓRMULA | `LET cSql =  "sed 's/..$//g' "\|\|TRIM(cRutaGral)\|\|".tmp > "\|\|TRIM(cRutaGral);` |  |
| L118 | FÓRMULA | `LET cSql = "sed "\|\|"'s/$'""/`echo \\\r`/"" "\|\|TRIM(cRutaGral)\|\|" > "\|\|TRIM(cRutaGral)\|\|".t` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `acl` | PREFIJO | familia aclaraciones | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `reporte` | ENTIDAD | reporte | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `?_log` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_log` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_acl_transacc_movs_origen`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_acl_transacc_movs_origen.sql` |
| **LOC (1er CREATE)** | 52 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 2 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "código de transacción, movimientos y origen" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 2 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=2 · INFERIDO=1 · SINTÉTICO=0 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_acl_transacc_movs_origen(
  pky_origen                   INTEGER
) RETURNING CHAR(6) AS cod,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pky_origen` | `INTEGER` | `origen`=origen | ✅ CÓDIGO |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `countRows` | `INTEGER` | L7 |
| `codRet` | `CHAR(6)` | L8 |
| `transaccionRet` | `CHAR(4)` | L9 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `acl_tipo_movimiento` | `bdiaclaracion` | no | SELECT | L22 |
| `tmp_transacciones` | `bdiaclaracion` | no | SELECT | L33 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `acl` | PREFIJO | familia aclaraciones | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `transacc` | ENTIDAD | código de transacción | 🔵 CONVENCIÓN | nombre_sp |
| `movs` | ENTIDAD | movimientos (abreviación) | 🟡 INFERIDO | nombre_sp |
| `origen` | ENTIDAD | origen | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |

---

## `sp_acl_valida_dfa_devo`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_acl_valida_dfa_devo.sql` |
| **LOC (1er CREATE)** | 122 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 7 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "valida" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `valida` → `IF` encontrado en el cuerpo · `valida` → `RETURN` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=2 / 6 términos |

### Firma

```sql
CREATE PROCEDURE sp_acl_valida_dfa_devo(
  pBandera                     CHAR(1)
  pFolio_csuac                 CHAR(16)
  pTarjeta                     CHAR(20)
  pMonto                       MONEY(16,2)
) RETURNING CHAR(5) AS cod_Retorno,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pBandera` | `CHAR(1)` | — | — |
| `pFolio_csuac` | `CHAR(16)` | — | — |
| `pTarjeta` | `CHAR(20)` | — | — |
| `pMonto` | `MONEY(16,2)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(5)` | L6 |
| `iSqlErr` | `INTEGER` | L7 |
| `v_punto` | `CHAR(50)` | L8 |
| `v_es_fda_exitoso` | `SMALLINT` | L9 |
| `v_desc_primer_fda` | `CHAR(50)` | L10 |
| `v_desc_segundo_fda` | `CHAR(50)` | L11 |
| `v_procede_abono_tmp` | `SMALLINT` | L12 |
| `v_modo_entrada` | `CHAR(2)` | L13 |
| `v_cvv2_dinamico` | `CHAR(4)` | L14 |
| `v_dictamen` | `CHAR(100)` | L15 |
| `v_dictamen2` | `CHAR(250)` | L16 |
| `v_dictamen_noprocede` | `CHAR(255)` | L17 |
| `v_montoDevo` | `MONEY(16,2)` | L19 |
| `v_fecha` | `DATE` | L20 |
| `v_procede` | `SMALLINT` | L21 |
| `v_devo` | `SMALLINT` | L22 |
| `va_cod_ret` | `CHAR(5)` | L23 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `acl_bitacora_fda_3410` | `bdiaclaracion` | no | SELECT | L66 |
| `td_movimientos_conciliacion` | `bditarjeta` | ⚠️ sí | SELECT | L95 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L25 | CÓDIGO_RETORNO | `LET cCodRet					= '00000';` |  |
| L54 | CÓDIGO_RETORNO | `LET cCodRet = '00003';` |  |
| L103 | FÓRMULA | `LET v_dictamen =  "Devolucion " \|\| TO_CHAR(v_fecha, '%d/%m/%Y')\|\| ' ' \|\|TO_CHAR(v_montoDevo);` | 🔴 MONEY/aritmética financiera |
| L104 | FÓRMULA | `LET v_dictamen2 = "Lamentamos los inconvenientes en su cuenta, solicitud No Procede, la transacción ` | 🔴 MONEY/aritmética financiera |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `acl` | PREFIJO | familia aclaraciones | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `valida` | ACCION | valida | 🔵 CONVENCIÓN | nombre_sp |
| `?_dfa_` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `dev` | ACCION | devolución | 🔵 CONVENCIÓN | nombre_sp |
| `?o` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_dfa_`, `?o` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_acl_validacion_abonoinmediato`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_acl_validacion_abonoinmediato.sql` |
| **LOC (1er CREATE)** | 700 |
| **Callgraph** | ✅ fan_in=0 / fan_out=7 |
| **Deps concatenadas** | 2 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "validación abono inmediato" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `valida` → `IF` encontrado en el cuerpo · `valida` → `RETURN` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=0 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_acl_validacion_abonoinmediato(
  pFolio_csuac                 CHAR(16)
) RETURNING CoRet CHAR(5), FolioCsuac CHAR(11), DetalleDic CHAR(70), Dictamen CHAR(250), Importe MONEY(16,2), diasconclusion INTEGER, procede CHAR(1), tipoResolucion CHAR(2)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pFolio_csuac` | `CHAR(16)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(6)` | L5 |
| `sql_err` | `INTEGER` | L6 |
| `isam_err` | `INTEGER` | L7 |
| `CMensaje` | `CHAR(80)` | L8 |
| `vFolioCsuac` | `CHAR(11)` | L10 |
| `vResultado` | `CHAR(70)` | L11 |
| `vFechaActual` | `DATETIME YEAR to FRACTION(5)` | L12 |
| `vFechaDictamen` | `DATETIME YEAR to FRACTION(5)` | L13 |
| `wBegin` | `CHAR(1)` | L15 |
| `vIDAclaracion` | `INTEGER` | L17 |
| `vEstatusAclInicial` | `INTEGER` | L18 |
| `vEstatusCorpInicial` | `INTEGER` | L19 |
| `vEstatusAnaInicial` | `INTEGER` | L20 |
| `vFechaCapturaAcl` | `DATE` | L21 |
| `vAreaAcl` | `INTEGER` | L22 |
| `vEstatusAcl` | `INTEGER` | L23 |
| `vEstatusCorp` | `INTEGER` | L24 |
| `vEstatusAna` | `INTEGER` | L25 |
| `vPredictamenEstatusCorp` | `INTEGER` | L27 |
| `vAccionPredictamen` | `INTEGER` | L28 |
| `vImporteReclamado` | `MONEY` | L29 |
| `vCostoComision` | `MONEY` | L30 |
| `vIDUsusario` | `INTEGER` | L31 |
| `vAccionAbono` | `INTEGER` | L33 |
| `vAbonoTemporal` | `INTEGER` | L34 |
| *…130 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `systables` | `bdiaclaracion` | no | SELECT | L351 |
| `acl_usuario` | `bdiaclaracion` | no | SELECT | L358 |
| `acl_aclaracion` | `bdiaclaracion` | no | SELECT | L365 |
| `acl_movimiento` | `bdiaclaracion` | no | SELECT | L379 |
| `sd_promocion_credito` | `bdicred` | ⚠️ sí | SELECT | L385 |
| `acl_tipo_eventos_abono` | `bdiaclaracion` | no | SELECT | L405 |
| `acl_tipo_evento` | `bdiaclaracion` | no | SELECT | L414 |
| `acl_busca_datos_3410_temp` | `bdiaclaracion` | no | INSERT | L446 |
| `acl_estatus_corporativo` | `bdiaclaracion` | no | SELECT | L597 |
| `acl_entrada_bitacora` | `bdiaclaracion` | no | INSERT | L608 |
| `acl_estatus_aclaracion` | `bdiaclaracion` | no | SELECT | L620 |
| `acl_resolucion` | `bdiaclaracion` | no | SELECT | L628 |
| `si_cliente` | `bdinteg` | ⚠️ sí | SELECT | L648 |
| `acl_reporte_log` | `bdiaclaracion` | no | INSERT | L661 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_busca_datos_3410_fda` | `bdiaclaracion` | no | L437 |
| `sp_acl_valida_dfa_devo` | `bdiaclaracion` | no | L461 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L185 | CÓDIGO_RETORNO | `LET cCodRet					= '00000';` |  |
| L331 | VALIDACIÓN_NULL | `IF vResultado IS NULL THEN` |  |
| L334 | FÓRMULA | `LET vResultado = TRIM(vResultado) \|\| '-' \|\| 'Proceso Fallido';` |  |
| L453 | VALIDACIÓN_NULL | `IF es_fda_exitoso = '1' OR v_procede_abono_tmp = '0' OR v_procede_abono_tmp IS NULL THEN` |  |
| L500 | VALIDACIÓN_NULL | `IF es_fda_exitoso = '1' OR v_procede_abono_tmp = '0' OR v_procede_abono_tmp IS NULL THEN` |  |
| L623 | FÓRMULA | `LET vDiasConclusion = (date(vFechaDictamen) - vFechaCapturaAcl + 1);` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `acl` | PREFIJO | familia aclaraciones | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `validacion` | ACCION | validación | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `abonoinmediato` | ENTIDAD | abono inmediato | 🔵 CONVENCIÓN | nombre_sp |

---

## `sp_acl_validarnumerorespuestas`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_acl_validarnumerorespuestas.sql` |
| **LOC (1er CREATE)** | 119 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 13 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "valida número y respuesta" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `valida` → `IF` encontrado en el cuerpo · `valida` → `RETURN` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=4 · INFERIDO=0 · SINTÉTICO=3 / 8 términos |

### Firma

```sql
CREATE PROCEDURE sp_acl_validarnumerorespuestas(
  p_NumCte                     CHAR(30)
) RETURNING CHAR(5) as  codretorno, INTEGER as preguntasconrespuesta
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_NumCte` | `CHAR(30)` | `num`=número (de) | 🔵 CONVENCIÓN |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cResultado_rfc` | `CHAR(13)` | L5 |
| `cResultado_fecha_nac` | `CHAR(10)` | L6 |
| `cResultado_correo` | `CHAR(50)` | L7 |
| `cResultado_telefono` | `CHAR(10)` | L8 |
| `cResultado_celular` | `CHAR(10)` | L9 |
| `cResultado_estado` | `CHAR(30)` | L10 |
| `cResultado_estadoN` | `CHAR(30)` | L11 |
| `cResultado_calle` | `CHAR(50)` | L12 |
| `cResultado_colonia` | `CHAR(50)` | L13 |
| `cResultado_tarjeta` | `CHAR(4)` | L14 |
| `iSqlErr` | `INTEGER` | L15 |
| `cCodRet` | `CHAR(5)` | L16 |
| `iTotalRespuesta` | `INTEGER` | L17 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_cliente` | `bdinteg` | ⚠️ sí | SELECT | L59 |
| `si_ctepf` | `bdinteg` | ⚠️ sí | SELECT | L78 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L32 | CÓDIGO_RETORNO | `LET cCodRet='00000';` |  |
| L83 | FÓRMULA | `LET iTotalRespuesta = iTotalRespuesta+1;` |  |
| L86 | FÓRMULA | `LET iTotalRespuesta = iTotalRespuesta+2; --SI TIENE FECHA DE NAC TIENE EDAD` |  |
| L89 | FÓRMULA | `LET iTotalRespuesta = iTotalRespuesta+3; --SI TIENE CORREO TIENE DOMINIO y PRIMERAS 4 LETRAS` |  |
| L92 | FÓRMULA | `LET iTotalRespuesta = iTotalRespuesta+1;` |  |
| L95 | FÓRMULA | `LET iTotalRespuesta = iTotalRespuesta+1;` |  |
| L98 | FÓRMULA | `LET iTotalRespuesta = iTotalRespuesta+1;` |  |
| L101 | FÓRMULA | `LET iTotalRespuesta = iTotalRespuesta+1;` |  |
| L104 | FÓRMULA | `LET iTotalRespuesta = iTotalRespuesta+1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `acl` | PREFIJO | familia aclaraciones | 🔵 CONVENCIÓN | nombre_sp |
| `valida` | ACCION | valida | 🔵 CONVENCIÓN | nombre_sp |
| `?r` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `num` | ENTIDAD | número (de) | 🔵 CONVENCIÓN | nombre_sp |
| `?ero` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `respuesta` | ENTIDAD | respuesta | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?s` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?r`, `?ero`, `?s` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_acl_validarpreguntasautenticacion`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_acl_validarpreguntasautenticacion.sql` |
| **LOC (1er CREATE)** | 116 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 12 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "valida tasa" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `valida` → `IF` encontrado en el cuerpo · `valida` → `RETURN` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=4 · INFERIDO=2 · SINTÉTICO=4 / 10 términos |

### Firma

```sql
CREATE PROCEDURE sp_acl_validarpreguntasautenticacion(
  p_NumCte                     CHAR(20)
) RETURNING CHAR(5) as  codretorno, CHAR(30) as rfc, CHAR(30) as fecha_nac, CHAR(50) as correo, CHAR(30) as telefono, CHAR(30) as celular, CHAR(50) as estado,CHAR(50) as estado_nacio,CHAR(100) as calle, CHAR(100) as colonia
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_NumCte` | `CHAR(20)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cResultado_rfc` | `CHAR(13)` | L5 |
| `cResultado_fecha_nac` | `CHAR(10)` | L6 |
| `cResultado_correo` | `CHAR(50)` | L7 |
| `cResultado_telefono` | `CHAR(10)` | L8 |
| `cResultado_celular` | `CHAR(10)` | L9 |
| `cResultado_estado` | `CHAR(30)` | L10 |
| `cResultado_estadoN` | `CHAR(30)` | L11 |
| `cResultado_calle` | `CHAR(50)` | L12 |
| `cResultado_colonia` | `CHAR(50)` | L13 |
| `iSqlErr` | `INTEGER` | L14 |
| `cCodRet` | `CHAR(5)` | L15 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_cliente` | `bdinteg` | ⚠️ sí | SELECT | L56 |
| `si_ctepf` | `bdinteg` | ⚠️ sí | SELECT | L69 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L30 | CÓDIGO_RETORNO | `LET cCodRet='00000';` |  |
| L72 | VALIDACIÓN_NULL | `IF cResultado_rfc is null THEN` |  |
| L75 | VALIDACIÓN_NULL | `IF cResultado_fecha_nac is null THEN` |  |
| L78 | VALIDACIÓN_NULL | `IF cResultado_correo is null THEN` |  |
| L81 | VALIDACIÓN_NULL | `IF cResultado_telefono is null THEN` |  |
| L84 | VALIDACIÓN_NULL | `IF cResultado_celular is null THEN` |  |
| L87 | VALIDACIÓN_NULL | `IF cResultado_estado is null THEN` |  |
| L90 | VALIDACIÓN_NULL | `IF cResultado_estadoN is null THEN` |  |
| L93 | VALIDACIÓN_NULL | `IF cResultado_calle is null THEN` |  |
| L96 | VALIDACIÓN_NULL | `IF cResultado_colonia is null THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `acl` | PREFIJO | familia aclaraciones | 🔵 CONVENCIÓN | nombre_sp |
| `valida` | ACCION | valida | 🔵 CONVENCIÓN | nombre_sp |
| `?rp` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `reg` | ACCION | registro | 🟡 INFERIDO | nombre_sp |
| `?un` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `tasa` | ENTIDAD | tasa (de interés) | 🔵 CONVENCIÓN | nombre_sp |
| `?utenti` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `cac` | PREFIJO | familia crédito (CAC) | 🟡 INFERIDO | nombre_sp |
| `?ion` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?rp`, `?un`, `?utenti`, `?ion` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_acl_validarpreguntasiniciosesion`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_acl_validarpreguntasiniciosesion.sql` |
| **LOC (1er CREATE)** | 137 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 1 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "valida (inicio)" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `valida` → `IF` encontrado en el cuerpo · `valida` → `RETURN` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=3 · INFERIDO=1 · SINTÉTICO=3 / 8 términos |

### Firma

```sql
CREATE PROCEDURE sp_acl_validarpreguntasiniciosesion(
  p_NumCte                     CHAR(20)
) RETURNING CHAR(5) as  codretorno, CHAR(30) as fecha_nacimiento, CHAR(40) as num_tarjeta, CHAR(40) as num_celular, CHAR(15) as edad, CHAR(54) as email, CHAR(40) as dominio
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_NumCte` | `CHAR(20)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cResultado_fecha_nacimiento` | `CHAR(10)` | L5 |
| `cResultado_tarjeta` | `CHAR(4)` | L6 |
| `cTarjeta` | `CHAR(16)` | L7 |
| `cResultado_celular` | `CHAR(4)` | L8 |
| `cResultado_edad` | `CHAR(2)` | L9 |
| `cResultado_mail` | `CHAR(4)` | L10 |
| `cResultado_dominio` | `CHAR(20)` | L11 |
| `iSqlErr` | `INTEGER` | L12 |
| `cCodRet` | `CHAR(5)` | L13 |
| `vFecha_nac` | `DATE` | L14 |
| `vCelular` | `CHAR(13)` | L15 |
| `vCorreo` | `CHAR(100)` | L16 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_ctepf` | `bdinteg` | ⚠️ sí | SELECT | L49 |
| `si_telefonos_actual` | `bdinteg` | ⚠️ sí | SELECT | L53 |
| `si_correos` | `bdinteg` | ⚠️ sí | SELECT | L57 |
| `tarjeta` | `intercard` | ⚠️ sí | SELECT | L89 |
| `si_credito_sv` | `bdinteg` | ⚠️ sí | SELECT | L113 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L29 | CÓDIGO_RETORNO | `LET cCodRet='00000';` |  |
| L60 | VALIDACIÓN_NULL | `IF vFecha_nac IS NULL THEN` |  |
| L64 | FÓRMULA | `LET cResultado_fecha_nacimiento = TO_CHAR(vFecha_nac,'%m/%d/%Y');` |  |
| L65 | FÓRMULA | `LET cResultado_edad = FLOOR((CAST (DATE(current) AS INTEGER) - CAST(DATE(vFecha_nac) AS INTEGER)) / ` |  |
| L68 | VALIDACIÓN_NULL | `IF vCelular IS NULL THEN` |  |
| L71 | FÓRMULA | `LET cResultado_celular = substr(vCelular,length(vCelular)-3,4);` |  |
| L74 | VALIDACIÓN_NULL | `IF vCorreo IS NULL THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `acl` | PREFIJO | familia aclaraciones | 🔵 CONVENCIÓN | nombre_sp |
| `valida` | ACCION | valida | 🔵 CONVENCIÓN | nombre_sp |
| `?rp` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `reg` | ACCION | registro | 🟡 INFERIDO | nombre_sp |
| `?untas` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `inicio` | MODIF | inicio | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?sesion` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?rp`, `?untas`, `?sesion` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_actualiza_estatus_acl_eglobal_respondida`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_actualiza_estatus_acl_eglobal_respondida.sql` |
| **LOC (1er CREATE)** | 50 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "actualiza estatus y identificador (especial)" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `actualiza` → `UPDATE` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=4 · INFERIDO=0 · SINTÉTICO=3 / 9 términos |

### Firma

```sql
CREATE PROCEDURE sp_actualiza_estatus_acl_eglobal_respondida(
  e_folio_csuac                VARCHAR(11)
) RETURNING CHAR(3) AS s_CodRetorno, INTEGER AS s_EstatusCorpNuevo
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `e_folio_csuac` | `VARCHAR(11)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `s_CodRet` | `CHAR(3)` | L6 |
| `s_EstatusCorpNew` | `INTEGER` | L7 |
| `s_EstatusCorp` | `INTEGER` | L10 |
| `s_EstatusCorpAnt` | `INTEGER` | L11 |
| `l_EstatusConsultado` | `INTEGER` | L12 |
| `iSqlErr` | `INTEGER` | L13 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `acl_aclaracion` | `bdiaclaracion` | no | SELECT | L25 |
| `acl_aclaracion` | `bdiaclaracion` | no | UPDATE | L40 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `actualiza` | ACCION | actualiza | 🔵 CONVENCIÓN | nombre_sp |
| `estatus` | ENTIDAD | estatus | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `acl` | PREFIJO | familia aclaraciones | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `?_eglobal_r` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `esp` | MODIF | especial | 🔵 CONVENCIÓN | nombre_sp |
| `?ond` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `id` | ENTIDAD | identificador (de) | 🔵 CONVENCIÓN | nombre_sp |
| `?a` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_eglobal_r`, `?ond`, `?a` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_actualiza_folio_error_cierre`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_actualiza_folio_error_cierre.sql` |
| **LOC (1er CREATE)** | 125 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 1 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "actualiza folio y error" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `actualiza` → `UPDATE` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=3 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=0 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_actualiza_folio_error_cierre(
  p_pky_aclaracion             INTEGER
) RETURNING VARCHAR (3) AS sCodRet, --Salida de codigo de retorno
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_pky_aclaracion` | `INTEGER` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `v_fky_estatus_corp_analisis` | `INTEGER` | L9 |
| `v_fky_estatus_corp_general` | `INTEGER` | L10 |
| `v_nombre_estatus_corporativo` | `LVARCHAR` | L11 |
| `v_folio_csuac` | `VARCHAR(10)` | L12 |
| `wBegin` | `CHAR(1)` | L14 |
| `cCodRet` | `CHAR(3)` | L17 |
| `v_CodRet` | `CHAR(3)` | L18 |
| `iSqlErr` | `INTEGER` | L19 |
| `v_observaciones` | `LVARCHAR` | L22 |
| `v_procede` | `SMALLINT` | L23 |
| `v_cod_resolucion` | `INTEGER` | L24 |
| `v_estatus_aclaracion` | `INTEGER` | L25 |
| `v_estatus_aclaracion_no_realizado` | `INTEGER` | L26 |
| `v_mensaje_error_bitacora` | `LVARCHAR` | L27 |
| `v_dias_conclusion` | `INTEGER` | L28 |
| `v_importereclamado` | `MONEY` | L29 |
| `v_cierreAutomaticoNoRealizadoAfectacion` | `VARCHAR (50)` | L32 |
| `v_resolucion` | `INTEGER` | L33 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `acl_estatus_corporativo` | `bdiaclaracion` | no | SELECT | L73 |
| `acl_resolucion` | `bdiaclaracion` | no | SELECT | L78 |
| `acl_aclaracion` | `bdiaclaracion` | no | SELECT | L84 |
| `acl_entrada_bitacora` | `bdiaclaracion` | no | INSERT | L99 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L66 | FÓRMULA | `LET v_cod_resolucion=NULL; -- Politica Interna` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `actualiza` | ACCION | actualiza | 🔵 CONVENCIÓN | nombre_sp |
| `folio` | ENTIDAD | folio | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `error` | ENTIDAD | error | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `cierre` | ACCION | cierre | ✅ CÓDIGO | nombre_sp, texto_cuerpo |

---

## `sp_actualiza_monto_movimiento`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_actualiza_monto_movimiento.sql` |
| **LOC (1er CREATE)** | 32 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "actualiza monto y movimiento" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `actualiza` → `UPDATE` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=4 · INFERIDO=0 · SINTÉTICO=0 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_actualiza_monto_movimiento(
  pFolioSuac                   CHAR(10)
  pIdMov                       INTEGER
  pMonto                       MONEY
) RETURNING CHAR(3) as cCodRet
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pFolioSuac` | `CHAR(10)` | — | — |
| `pIdMov` | `INTEGER` | — | — |
| `pMonto` | `MONEY` | `monto`=monto | 🔵 CONVENCIÓN |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(3)` | L4 |
| `iSqlErr` | `INTEGER` | L5 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `actualiza` | ACCION | actualiza | 🔵 CONVENCIÓN | nombre_sp |
| `monto` | ENTIDAD | monto | 🔵 CONVENCIÓN | nombre_sp |
| `movimiento` | ENTIDAD | movimiento | 🔵 CONVENCIÓN | nombre_sp |

---

## `sp_aplica_cierre_masivo`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_aplica_cierre_masivo.sql` |
| **LOC (1er CREATE)** | 864 |
| **Callgraph** | ✅ fan_in=2 / fan_out=5 |
| **Deps concatenadas** | 1 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "aplica (masivo)" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 5 llamada(s): `sp_consulta_correos`, `sp_consulta_telefonos`, `sp_aplicaaclaracredito` |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=0 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_aplica_cierre_masivo(
  pFolio                       CHAR(16)
  pProcede                     CHAR(1)
  pResolucion                  INTEGER
  pOpcion                      CHAR(1)
  pEmpleado                    CHAR (8)
  pPreDictamen                 VARCHAR(250)
  pNumProceso                  INTEGER
  pafectacion                  CHAR(1)
) RETURNING CHAR(6), CHAR (11), CHAR (50)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pFolio` | `CHAR(16)` | — | — |
| `pProcede` | `CHAR(1)` | — | — |
| `pResolucion` | `INTEGER` | — | — |
| `pOpcion` | `CHAR(1)` | — | — |
| `pEmpleado` | `CHAR (8)` | — | — |
| `pPreDictamen` | `VARCHAR(250)` | — | — |
| `pNumProceso` | `INTEGER` | — | — |
| `pafectacion` | `CHAR(1)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(6)` | L5 |
| `sql_err` | `INTEGER` | L6 |
| `isam_err` | `INTEGER` | L7 |
| `CMensaje` | `CHAR(80)` | L8 |
| `vFolioCsuac` | `CHAR(11)` | L10 |
| `vResultado` | `CHAR(50)` | L11 |
| `vFechaActual` | `DATETIME YEAR to FRACTION(5)` | L12 |
| `vFechaDictamen` | `DATETIME YEAR to FRACTION(5)` | L13 |
| `wBegin` | `CHAR(1)` | L15 |
| `vIDAclaracion` | `INTEGER` | L17 |
| `vEstatusAclInicial` | `INTEGER` | L18 |
| `vEstatusCorpInicial` | `INTEGER` | L19 |
| `vEstatusAnaInicial` | `INTEGER` | L20 |
| `vFechaCapturaAcl` | `DATE` | L21 |
| `vAreaAcl` | `INTEGER` | L22 |
| `vEstatusAcl` | `INTEGER` | L23 |
| `vEstatusCorp` | `INTEGER` | L24 |
| `vEstatusAna` | `INTEGER` | L25 |
| `vPredictamenEstatusCorp` | `INTEGER` | L27 |
| `vAccionPredictamen` | `INTEGER` | L28 |
| `vImporteReclamado` | `MONEY` | L29 |
| `vCostoComision` | `MONEY` | L30 |
| `vIDUsusario` | `INTEGER` | L31 |
| `vAccionAbono` | `INTEGER` | L33 |
| `vAbonoTemporal` | `INTEGER` | L34 |
| *…59 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `acl_cierre_masivo` | `bdiaclaracion` | no | SELECT | L190 |
| `acl_cierre_masivo` | `bdiaclaracion` | no | UPDATE | L191 |
| `acl_cierre_masivo` | `bdiaclaracion` | no | INSERT | L195 |
| `systables` | `bdiaclaracion` | no | SELECT | L209 |
| `acl_resolucion` | `bdiaclaracion` | no | SELECT | L221 |
| `acl_usuario` | `bdiaclaracion` | no | SELECT | L226 |
| `acl_aclaracion` | `bdiaclaracion` | no | SELECT | L234 |
| `acl_movimiento` | `bdiaclaracion` | no | SELECT | L249 |
| `acl_entrada_bitacora` | `bdiaclaracion` | no | INSERT | L286 |
| `acl_estatus_corporativo` | `bdiaclaracion` | no | SELECT | L308 |
| `acl_aclaracion` | `bdiaclaracion` | no | UPDATE | L313 |
| `si_cliente` | `bdinteg` | ⚠️ sí | SELECT | L404 |
| `acl_estatus_aclaracion` | `bdiaclaracion` | no | SELECT | L475 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_consulta_correos` | `bdinteg` | ⚠️ sí | L420 |
| `sp_consulta_telefonos` | `bdinteg` | ⚠️ sí | L424 |
| `sp_aplicaaclaracredito` | `bdicred` | ⚠️ sí | L439 |
| `sp_aplicaaclaradebito` | `bdicheq` | ⚠️ sí | L442 |
| `sp_registra_evento` | `bdimnsj` | ⚠️ sí | L542 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L183 | VALIDACIÓN_NULL | `IF vResultado IS NULL THEN` |  |
| L186 | FÓRMULA | `LET vResultado = TRIM(vResultado) \|\| '-' \|\| 'Proceso Fallido';` |  |
| L237 | VALIDACIÓN_NULL | `IF (vFolioCsuac IS NULL) THEN` |  |
| L256 | VALIDACIÓN_NULL | `IF (vFolioCsuac IS NULL) THEN` |  |
| L482 | FÓRMULA | `LET vDiasConclusion = (date(vFechaDictamen) - vFechaCapturaAcl + 1);` |  |
| L577 | FÓRMULA | `LET vFechaNotifacion = TO_CHAR(CURRENT,'%d/%m/%Y');` |  |
| L665 | FÓRMULA | `LET vDiasConclusion = (date(vFechaDictamen) - vFechaCapturaAcl + 1);` |  |
| L779 | FÓRMULA | `LET vFechaNotifacion = TO_CHAR(CURRENT,'%d/%m/%Y');` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `aplica` | ACCION | aplica / ejecuta | 🔵 CONVENCIÓN | nombre_sp |
| `cierre` | ACCION | cierre | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `masivo` | MODIF | masivo | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |

---

## `sp_aplica_cierre_preventivo`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_aplica_cierre_preventivo.sql` |
| **LOC (1er CREATE)** | 352 |
| **Callgraph** | ✅ fan_in=0 / fan_out=9 |
| **Deps concatenadas** | 7 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "aplica (preventivo)" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 3 llamada(s): `sp_consulta_tipo_movimiento`, `sp_aplicaaclaracredito`, `sp_aplicaaclaradebito` |
| **Evidencia vocab** | CÓDIGO=3 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=0 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_aplica_cierre_preventivo(
) RETURNING VARCHAR (3) AS sCodRet, --Salida de codigo de retorno
```

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `v_fechacaptura` | `DATE` | L10 |
| `v_num_cliente` | `VARCHAR(10)` | L11 |
| `v_tipo_producto` | `VARCHAR(1)` | L12 |
| `v_tipo_movimiento` | `VARCHAR(1)` | L13 |
| `v_resp_estimada` | `INTEGER` | L14 |
| `v_resp_estimada_intl` | `INTEGER` | L15 |
| `v_importereclamado` | `MONEY` | L16 |
| `v_folio_csuac` | `VARCHAR(10)` | L17 |
| `v_nombre_origen` | `VARCHAR(50)` | L18 |
| `v_procesadoCorrectamente` | `VARCHAR (100)` | L19 |
| `v_pky_aclaracion` | `INTEGER` | L20 |
| `v_fky_estatus_aclaracion` | `INTEGER` | L21 |
| `v_fky_estatus_corp_analisis` | `INTEGER` | L22 |
| `V_fky_estatus_corp_general` | `INTEGER` | L23 |
| `v_fechaCierre` | `date` | L24 |
| `v_resultado_origen` | `VARCHAR(1)` | L26 |
| `v_modo_entrada` | `VARCHAR(2)` | L27 |
| `v_num_tarjeta` | `VARCHAR (16)` | L28 |
| `v_folioSuc` | `VARCHAR (30)` | L29 |
| `v_pky_origen_evento` | `INTEGER` | L30 |
| `v_dias_respuesta_maxima_folio` | `INTEGER` | L33 |
| `v_fecha_resultante` | `DATE` | L34 |
| `cCodRet` | `CHAR(3)` | L37 |
| `v_CodRet` | `CHAR(3)` | L38 |
| `iSqlErr` | `INTEGER` | L39 |
| *…16 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `acl_estatus_corporativo` | `bdiaclaracion` | no | SELECT | L101 |
| `acl_aclaracion` | `bdiaclaracion` | no | SELECT | L143 |
| `acl_resolucion` | `bdiaclaracion` | no | SELECT | L163 |
| `acl_aclaracion` | `bdiaclaracion` | no | UPDATE | L204 |
| `acl_entrada_bitacora` | `bdiaclaracion` | no | INSERT | L216 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_consulta_tipo_movimiento` | `bdiaclaracion` | no | L179 |
| `sp_aplicaaclaracredito` | `bdicred` | ⚠️ sí | L265 |
| `sp_aplicaaclaradebito` | `bdicheq` | ⚠️ sí | L270 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L185 | VALIDACIÓN_NULL | `IF ((v_tipo_movimiento IS NULL) OR (v_tipo_movimiento = '') OR v_tipo_movimiento='N')  THEN` |  |
| L199 | FÓRMULA | `LET v_fecha_resultante = (today - v_resp_estimada);` |  |
| L249 | FÓRMULA | `LET v_dias_respuesta_maxima_folio = v_resp_estimada; -- Respuesta maxima Nacional` |  |
| L251 | FÓRMULA | `LET v_dias_respuesta_maxima_folio = v_resp_estimada_intl; -- Respuesta maxima Internacional` |  |
| L256 | FÓRMULA | `LET v_fecha_resultante = today- v_dias_respuesta_maxima_folio;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `aplica` | ACCION | aplica / ejecuta | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `cierre` | ACCION | cierre | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `preventivo` | MODIF | preventivo | ✅ CÓDIGO | nombre_sp, texto_cuerpo |

---

## `sp_aplica_credito_smartvista`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_aplica_credito_smartvista.sql` |
| **LOC (1er CREATE)** | 829 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "aplica crédito" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 7 tabla(s) con operaciones: SELECT, INSERT, UPDATE |
| **Evidencia vocab** | CÓDIGO=3 · CONVENCIÓN=0 · INFERIDO=0 · SINTÉTICO=1 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_aplica_credito_smartvista(
  pEmpresa                     CHAR(3)
  pFolioSuac                   CHAR(10)
  pDictamen                    CHAR(2)
  pCalculaInteres              CHAR(1)
  pEmpleadoAut                 CHAR (8)
  pcodigo                      char(3)
) RETURNING CHAR(3)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pEmpresa` | `CHAR(3)` | — | — |
| `pFolioSuac` | `CHAR(10)` | — | — |
| `pDictamen` | `CHAR(2)` | — | — |
| `pCalculaInteres` | `CHAR(1)` | — | — |
| `pEmpleadoAut` | `CHAR (8)` | — | — |
| `pcodigo` | `char(3)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(5)` | L4 |
| `sql_err` | `INTEGER` | L5 |
| `isam_err` | `INTEGER` | L6 |
| `CnumCredito` | `CHAR(20)` | L8 |
| `CnumTarjeta` | `CHAR(20)` | L9 |
| `CmontoAcla` | `DECIMAL(18,2)` | L10 |
| `Csucursal` | `CHAR(4)` | L11 |
| `pfecha` | `DATE` | L12 |
| `pfechaAux` | `DATE` | L13 |
| `pfechaMov` | `DATE` | L14 |
| `pfechaAcl` | `DATE` | L15 |
| `pIntDev` | `DECIMAL(18,2)` | L16 |
| `pIntVig` | `DECIMAL(18,2)` | L17 |
| `pIntVenc` | `DECIMAL(18,2)` | L18 |
| `pIntCalc` | `DECIMAL(18,2)` | L19 |
| `pTasaInt` | `DECIMAL(18,2)` | L20 |
| `pIntBoni` | `DECIMAL(18,2)` | L21 |
| `pIvaBoni` | `DECIMAL(18,2)` | L22 |
| `DiasCalc` | `SMALLINT` | L23 |
| `DiasPeri` | `SMALLINT` | L24 |
| `pIntCap` | `DECIMAL(18,2)` | L25 |
| `pIvaCap` | `DECIMAL(18,2)` | L26 |
| `CCodret_c` | `CHAR(5)` | L27 |
| `CMensaje` | `CHAR(80)` | L28 |
| `CSecuencia` | `INTEGER` | L29 |
| *…42 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `acl_aclaracion` | `bdiaclaracion` | no | SELECT | L201 |
| `acl_movimiento` | `bdiaclaracion` | no | SELECT | L261 |
| `acl_movimiento` | `bdiaclaracion` | no | INSERT | L304 |
| `acl_origen_evento` | `bdiaclaracion` | no | SELECT | L400 |
| `acl_movimiento` | `bdiaclaracion` | no | UPDATE | L477 |
| `acl_control_afectacion_cred` | `bdiaclaracion` | no | SELECT | L735 |
| `acl_control_afectacion_cred` | `bdiaclaracion` | no | INSERT | L741 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L207 | VALIDACIÓN_NULL | `IF pFolioSuac IS NULL OR pFolioSuac='' THEN` |  |
| L217 | VALIDACIÓN_NULL | `IF pDictamen IS NULL OR pDictamen='' THEN` |  |
| L222 | VALIDACIÓN_NULL | `IF pCalculaInteres IS NULL OR pCalculaInteres='' THEN` |  |
| L265 | VALIDACIÓN_NULL | `IF (v_fky_padre IS NULL) THEN` |  |
| L302 | VALIDACIÓN_NULL | `IF (v_duplicado IS NULL) THEN` |  |
| L362 | VALIDACIÓN_NULL | `IF (v_duplicado IS NULL) THEN` |  |
| L386 | VALIDACIÓN_NULL | `IF (Es_Nacional IS NULL OR Es_Nacional = '' OR Es_Nacional ='N') THEN --Deshabilitar cuando se utili` |  |
| L408 | VALIDACIÓN_NULL | `IF (Es_Nacional IS NULL OR Es_Nacional = '' OR Es_Nacional = 'N') THEN` |  |
| L440 | VALIDACIÓN_NULL | `IF	(Ipky_tipo_movimiento is null OR Ipky_tipo_movimiento='') THEN  -- Determinar la comisiÃ³n desde ` |  |
| L483 | VALIDACIÓN_NULL | `IF ( v_numero_transaccion IS NULL) THEN  -->> Valida si ya se ingreso la comisiÃ¿?Ã¿Â³n de crÃ¿?Ã¿Â©` |  |
| L519 | VALIDACIÓN_NULL | `IF (Es_Nacional IS NULL OR Es_Nacional = '' OR Es_Nacional = 'N') THEN --Deshabilitar cuando se util` |  |
| L542 | VALIDACIÓN_NULL | `IF (Es_Nacional IS NULL OR Es_Nacional = '' OR Es_Nacional = 'N') THEN` |  |
| L567 | VALIDACIÓN_NULL | `IF	(Ipky_tipo_movimiento is null OR Ipky_tipo_movimiento='') THEN  -- Determinar la comisiÃ³n desde ` |  |
| L609 | VALIDACIÓN_NULL | `IF ( v_numero_transaccion IS NULL) THEN  -->> Valida si ya se ingreso la comision de credito, para n` |  |
| L673 | VALIDACIÓN_NULL | `IF CnumCredito IS NULL THEN` |  |
| L682 | VALIDACIÓN_NULL | `IF CmontoAcla IS NULL or CmontoAcla = 0 THEN` |  |
| L691 | VALIDACIÓN_NULL | `IF (CnumTarjeta is null) then` |  |
| L737 | VALIDACIÓN_NULL | `IF max_control_afect_cred IS NULL THEN` |  |
| L765 | VALIDACIÓN_NULL | `IF (CSecuencia_acl_mov is null) THEN` |  |
| L768 | FÓRMULA | `LET CSecuencia_acl_mov = (CSecuencia_acl_mov) + 1;` |  |
| L811 | FÓRMULA | `let v_contador = v_contador + 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `aplica` | ACCION | aplica / ejecuta | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `credito` | ENTIDAD | crédito | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?_smartvista` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_smartvista` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_aplica_validacion_msi`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_aplica_validacion_msi.sql` |
| **LOC (1er CREATE)** | 589 |
| **Callgraph** | ✅ fan_in=0 / fan_out=3 |
| **Deps concatenadas** | 2 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "aplica meses sin intereses" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 3 llamada(s): `sp_consulta_correos`, `sp_consulta_telefonos`, `sp_registra_evento` |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=0 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_aplica_validacion_msi(
  pFolio_csuac                 CHAR(16)
  ptipo_msi                    CHAR(1)
) RETURNING CoRet CHAR(5), FolioCsuac CHAR(11), DetalleDic CHAR(70), Dictamen VARCHAR(250)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pFolio_csuac` | `CHAR(16)` | — | — |
| `ptipo_msi` | `CHAR(1)` | `msi`=meses sin intereses (MSI) | ✅ CÓDIGO |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(6)` | L4 |
| `sql_err` | `INTEGER` | L5 |
| `isam_err` | `INTEGER` | L6 |
| `CMensaje` | `CHAR(80)` | L7 |
| `vFolioCsuac` | `CHAR(11)` | L9 |
| `vResultado` | `CHAR(50)` | L10 |
| `vFechaActual` | `DATETIME YEAR to FRACTION(5)` | L11 |
| `vFechaDictamen` | `DATETIME YEAR to FRACTION(5)` | L12 |
| `wBegin` | `CHAR(1)` | L14 |
| `vIDAclaracion` | `INTEGER` | L16 |
| `vEstatusAclInicial` | `INTEGER` | L17 |
| `vEstatusCorpInicial` | `INTEGER` | L18 |
| `vEstatusAnaInicial` | `INTEGER` | L19 |
| `vFechaCapturaAcl` | `DATE` | L20 |
| `vAreaAcl` | `INTEGER` | L21 |
| `vEstatusAcl` | `INTEGER` | L22 |
| `vEstatusCorp` | `INTEGER` | L23 |
| `vEstatusAna` | `INTEGER` | L24 |
| `vPredictamenEstatusCorp` | `INTEGER` | L26 |
| `vAccionPredictamen` | `INTEGER` | L27 |
| `vImporteReclamado` | `MONEY` | L28 |
| `vCostoComision` | `MONEY` | L29 |
| `vIDUsusario` | `INTEGER` | L30 |
| `vAccionAbono` | `INTEGER` | L32 |
| `vAbonoTemporal` | `INTEGER` | L33 |
| *…68 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `acl_cierre_masivo` | `bdiaclaracion` | no | SELECT | L212 |
| `acl_cierre_masivo` | `bdiaclaracion` | no | UPDATE | L213 |
| `acl_cierre_masivo` | `bdiaclaracion` | no | INSERT | L217 |
| `systables` | `bdiaclaracion` | no | SELECT | L231 |
| `acl_resolucion` | `bdiaclaracion` | no | SELECT | L243 |
| `acl_usuario` | `bdiaclaracion` | no | SELECT | L248 |
| `acl_aclaracion` | `bdiaclaracion` | no | SELECT | L257 |
| `acl_movimiento` | `bdiaclaracion` | no | SELECT | L271 |
| `sd_promocion_credito` | `bdicred` | ⚠️ sí | SELECT | L275 |
| `sd_msi_cancela_credito_msi` | `bdicred` | ⚠️ sí | SELECT | L288 |
| `movimiento` | `intercard` | ⚠️ sí | SELECT | L321 |
| `acl_estatus_corporativo` | `bdiaclaracion` | no | SELECT | L390 |
| `acl_aclaracion` | `bdiaclaracion` | no | UPDATE | L396 |
| `acl_entrada_bitacora` | `bdiaclaracion` | no | INSERT | L412 |
| `acl_estatus_aclaracion` | `bdiaclaracion` | no | SELECT | L426 |
| `si_cliente` | `bdinteg` | ⚠️ sí | SELECT | L459 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_consulta_correos` | `bdinteg` | ⚠️ sí | L471 |
| `sp_consulta_telefonos` | `bdinteg` | ⚠️ sí | L475 |
| `sp_registra_evento` | `bdimnsj` | ⚠️ sí | L482 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L120 | FÓRMULA | `LET v_producto				= 0;  -- PEHY` |  |
| L122 | CÓDIGO_RETORNO | `LET cCodRet      			= '00000';` |  |
| L205 | VALIDACIÓN_NULL | `IF vResultado IS NULL THEN` |  |
| L208 | FÓRMULA | `LET vResultado = TRIM(vResultado) \|\| '-' \|\| 'Proceso Fallido';` |  |
| L429 | FÓRMULA | `LET vDiasConclusion = (date(vFechaDictamen) - vFechaCapturaAcl + 1);` |  |
| L516 | FÓRMULA | `LET vFechaNotifacion = TO_CHAR(CURRENT,'%d/%m/%Y');` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `aplica` | ACCION | aplica / ejecuta | 🔵 CONVENCIÓN | nombre_sp |
| `validacion` | ACCION | validación | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `msi` | ENTIDAD | meses sin intereses (MSI) | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |

---

## `sp_aplicar_cancelacion_por_recuperacion_creddeb`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_aplicar_cancelacion_por_recuperacion_creddeb.sql` |
| **LOC (1er CREATE)** | 265 |
| **Callgraph** | ✅ fan_in=2 / fan_out=5 |
| **Propósito inferido** | "aplica crédito (débito)" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 5 llamada(s): `sp_bloqueocuenta`, `bloqueo_cta`, `sp_cancelactachq` |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=5 · INFERIDO=0 · SINTÉTICO=0 / 7 términos |

### Firma

```sql
CREATE PROCEDURE sp_aplicar_cancelacion_por_recuperacion_creddeb(
  pFolio_csuac                 CHAR (11)
  pUsuario                     CHAR(8)
) RETURNING CHAR (5) AS codeRet,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pFolio_csuac` | `CHAR (11)` | — | — |
| `pUsuario` | `CHAR(8)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `dLineaDisponible` | `DECIMAL(18,2)` | L6 |
| `linea_disponible` | `DECIMAL(18,2)` | L7 |
| `Daclaraciones_vigentes` | `CHAR(15)` | L8 |
| `tipoProducto` | `INTEGER` | L9 |
| `pNumCliente` | `CHAR(15)` | L10 |
| `codeRet` | `CHAR(5)` | L11 |
| `aclaracionesVigentes` | `INTEGER` | L12 |
| `aFky_aclaracion` | `INTEGER` | L13 |
| `aFky_area` | `INTEGER` | L14 |
| `aFky_estatus_aclaracion` | `INTEGER` | L15 |
| `aFky_estatus_corp_analisis` | `INTEGER` | L16 |
| `aFky_estauts_corp_general` | `INTEGER` | L17 |
| `vNumCuenta` | `CHAR(25)` | L18 |
| `resultado_saldo_congelado` | `MONEY` | L19 |
| `codeRet2` | `CHAR(15)` | L20 |
| `eEmpresa` | `CHAR(5)` | L21 |
| `mensajeRet` | `CHAR(85)` | L22 |
| `FolioCancel` | `CHAR(25)` | L23 |
| `accionBitacora` | `INTEGER` | L24 |
| `pSucursal` | `CHAR(25)` | L25 |
| `vcodret` | `CHAR(10)` | L27 |
| `vsdodisp` | `MONEY(16,2)` | L28 |
| `vstatuscta` | `CHAR(10)` | L29 |
| `pmotivobloq` | `CHAR(2)` | L30 |
| `pfechabloq` | `DATE` | L31 |
| *…10 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `acl_aclaracion` | `bdiaclaracion` | no | SELECT | L84 |
| `acl_usuario` | `bdiaclaracion` | no | SELECT | L90 |
| `acl_resolucion` | `bdiaclaracion` | no | SELECT | L102 |
| `acl_entrada_bitacora` | `bdiaclaracion` | no | INSERT | L104 |
| `sc_maechq` | `bdicheq` | ⚠️ sí | SELECT | L120 |
| `sd_maesdos` | `bdicred` | ⚠️ sí | SELECT | L185 |
| `acl_control_cuentas_pendientes_cancelar` | `bdiaclaracion` | no | SELECT | L236 |
| `acl_control_cuentas_pendientes_cancelar` | `bdiaclaracion` | no | INSERT | L239 |
| `acl_bitacora_control_cancelacion_cuenta` | `bdiaclaracion` | no | INSERT | L245 |
| `acl_control_cuentas_pendientes_cancelar` | `bdiaclaracion` | no | UPDATE | L256 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_bloqueocuenta` | `bdicred` | ⚠️ sí | L109 |
| `bloqueo_cta` | `bdicheq` | ⚠️ sí | L113 |
| `sp_cancelactachq` | `bdicheq` | ⚠️ sí | L126 |
| `sp_desbloqueocuenta` | `bdicred` | ⚠️ sí | L188 |
| `sp_cancelarcredito` | `bdicred` | ⚠️ sí | L190 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `aplicar` | ACCION | aplica / ejecuta | 🔵 CONVENCIÓN | nombre_sp |
| `cancelacion` | ACCION | cancela | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `por` | MODIF | por (criterio) | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `recuperacion` | ACCION | recuperación (cobranza) | 🔵 CONVENCIÓN | nombre_sp |
| `cred` | ENTIDAD | crédito | 🔵 CONVENCIÓN | nombre_sp |
| `deb` | MODIF | débito | 🔵 CONVENCIÓN | nombre_sp |

---

## `sp_bitacora_siem`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_bitacora_siem.sql` |
| **LOC (1er CREATE)** | 60 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 13 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "bitácora" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 2 tabla(s) con operaciones: SELECT, INSERT |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=1 / 3 términos |

### Firma

```sql
CREATE PROCEDURE sp_bitacora_siem(
  pUsuario                     CHAR(8)
  pBandera                     CHAR(1)
  pActividad                   CHAR(50)
  pHASH                        CHAR(100)
  pIpOrigen                    CHAR(20)
  pIpDestino                   CHAR(20)
) RETURNING CHAR(5) AS codret,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pUsuario` | `CHAR(8)` | — | — |
| `pBandera` | `CHAR(1)` | — | — |
| `pActividad` | `CHAR(50)` | — | — |
| `pHASH` | `CHAR(100)` | — | — |
| `pIpOrigen` | `CHAR(20)` | — | — |
| `pIpDestino` | `CHAR(20)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(5)` | L6 |
| `iSqlErr` | `INTEGER` | L7 |
| `dfecha` | `DATETIME YEAR TO SECOND` | L8 |
| `cPassAnt` | `CHAR(100)` | L9 |
| `iTotCont` | `INTEGER` | L10 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `acl_bitacora_eventos_siem` | `bdiaclaracion` | no | SELECT | L38 |
| `acl_bitacora_eventos_siem` | `bdiaclaracion` | no | INSERT | L43 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L12 | CÓDIGO_RETORNO | `LET cCodRet = '00000';` |  |
| L29 | CÓDIGO_RETORNO | `LET cCodRet = '00003';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `bitacora` | ENTIDAD | bitácora | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `?_siem` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_siem` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_bitacorasistema`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_bitacorasistema.sql` |
| **LOC (1er CREATE)** | 81 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 5 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "bitácora y sistema" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 4 tabla(s) con operaciones: SELECT, DELETE, INSERT |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=0 / 3 términos |

### Firma

```sql
CREATE PROCEDURE sp_bitacorasistema(
  pUsuario                     CHAR(50)
  pEjecucion                   CHAR(1)
  pIpUsuario                   CHAR(16)
  pKey                         CHAR(255)
) RETURNING CHAR(5) AS codret,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pUsuario` | `CHAR(50)` | — | — |
| `pEjecucion` | `CHAR(1)` | — | — |
| `pIpUsuario` | `CHAR(16)` | — | — |
| `pKey` | `CHAR(255)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(5)` | L5 |
| `iSqlErr` | `INTEGER` | L6 |
| `cEmpresa` | `CHAR(3)` | L7 |
| `cNombreEmpleado` | `CHAR(45)` | L8 |
| `iPerfil` | `INTEGER` | L9 |
| `cNumSucursal` | `CHAR(4)` | L10 |
| `cNombreSucursal` | `CHAR(40)` | L11 |
| `cKey` | `CHAR(255)` | L12 |
| `cMensaje` | `CHAR(255)` | L13 |
| `iNumRegistros` | `INTEGER` | L14 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_ejecut` | `bdinteg` | ⚠️ sí | SELECT | L45 |
| `acl_sesion_usuario` | `bdiaclaracion` | no | SELECT | L63 |
| `acl_sesion_usuario` | `bdiaclaracion` | no | DELETE | L63 |
| `acl_sistema_bitacora` | `bdiaclaracion` | no | INSERT | L67 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L16 | CÓDIGO_RETORNO | `LET cCodRet = '00000';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `bitacora` | ENTIDAD | bitácora | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `sistema` | ENTIDAD | sistema | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |

---

## `sp_bloqueo_cta_debito`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_bloqueo_cta_debito.sql` |
| **LOC (1er CREATE)** | 84 |
| **Callgraph** | ✅ fan_in=0 / fan_out=1 |
| **Deps concatenadas** | 6 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "bloquea cuenta cuenta y débito" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 1 llamada(s): `bloqueo_cta` |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=4 · INFERIDO=0 · SINTÉTICO=0 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_bloqueo_cta_debito(
  pcuenta                      CHAR(20)
  pmonto                       MONEY(14,2)
  pmotivobloq                  CHAR(2)
  pTipobloqueo                 INTEGER
  pusuario                     CHAR(8)
) RETURNING char(5),  char(5)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pcuenta` | `CHAR(20)` | — | — |
| `pmonto` | `MONEY(14,2)` | — | — |
| `pmotivobloq` | `CHAR(2)` | — | — |
| `pTipobloqueo` | `INTEGER` | `bloqueo`=bloquea cuenta | 🔵 CONVENCIÓN |
| `pusuario` | `CHAR(8)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `codRet` | `CHAR (5)` | L10 |
| `v_clave` | `CHAR (5)` | L11 |
| `empresa` | `CHAR(3)` | L14 |
| `pfechabloq` | `DATE` | L15 |
| `pclave` | `CHAR(5)` | L16 |
| `pAreaSolic` | `CHAR(2)` | L17 |
| `pCodArea` | `CHAR(1)` | L18 |
| `pTipoBloq` | `CHAR(2)` | L19 |
| `pCodTipoBloq` | `CHAR(1)` | L20 |
| `cod_ret` | `CHAR(3)` | L22 |
| `cod_ret2` | `CHAR(5)` | L23 |
| `cod_ret3` | `CHAR(50)` | L24 |
| `sql_err` | `INTEGER` | L27 |
| `isam_err` | `INTEGER` | L28 |
| `desc_err` | `CHAR(50)` | L29 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `bloqueo_cta` | `bdicheq` | ⚠️ sí | L61 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `bloqueo` | ACCION | bloquea cuenta | 🔵 CONVENCIÓN | nombre_sp |
| `cta` | ENTIDAD | cuenta | 🔵 CONVENCIÓN | nombre_sp |
| `debito` | ENTIDAD | débito | 🔵 CONVENCIÓN | nombre_sp |

---

## `sp_bloqueocuenta_cred`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_bloqueocuenta_cred.sql` |
| **LOC (1er CREATE)** | 57 |
| **Callgraph** | ✅ fan_in=0 / fan_out=2 |
| **Deps concatenadas** | 7 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "bloquea cuenta cuenta y crédito" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 1 llamada(s): `sp_bloqueocuenta` |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=4 · INFERIDO=0 · SINTÉTICO=0 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_bloqueocuenta_cred(
  pEmpresa                     CHAR(3)
  pNumCuenta                   CHAR(20)
  cCveBloqueo                  INTEGER
  pCveCausa                    CHAR(2)
  pEjecutivo                   CHAR(8)
  pTipo                        INTEGER
) RETURNING CHAR(6) AS CODIGO,CHAR(80) AS MENSAJECOD
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pEmpresa` | `CHAR(3)` | — | — |
| `pNumCuenta` | `CHAR(20)` | `cuenta`=cuenta | 🔵 CONVENCIÓN |
| `cCveBloqueo` | `INTEGER` | `bloqueo`=bloquea cuenta | 🔵 CONVENCIÓN |
| `pCveCausa` | `CHAR(2)` | — | — |
| `pEjecutivo` | `CHAR(8)` | — | — |
| `pTipo` | `INTEGER` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `iSqlErr` | `INTEGER` | L14 |
| `iIsamErr` | `INTEGER` | L15 |
| `cErrorInfo` | `CHAR(80)` | L16 |
| `cCodRet` | `CHAR(6)` | L17 |
| `cMensajeRet` | `CHAR(80)` | L18 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_bloqueocuenta` | `bdicred` | ⚠️ sí | L33 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `bloqueo` | ACCION | bloquea cuenta | 🔵 CONVENCIÓN | nombre_sp |
| `cuenta` | ENTIDAD | cuenta | 🔵 CONVENCIÓN | nombre_sp |
| `cred` | ENTIDAD | crédito | 🔵 CONVENCIÓN | nombre_sp |

---

## `sp_bloqueodesbloqueo_cuentas_por_recuperacion_creddeb`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_bloqueodesbloqueo_cuentas_por_recuperacion_creddeb.sql` |
| **LOC (1er CREATE)** | 64 |
| **Callgraph** | ✅ fan_in=0 / fan_out=3 |
| **Propósito inferido** | "bloquea cuenta cuentas y crédito (débito)" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 3 llamada(s): `bloqueo_cta`, `sp_desbloqueocuenta`, `sp_bloqueocuenta` |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=6 · INFERIDO=0 · SINTÉTICO=0 / 8 términos |

### Firma

```sql
CREATE PROCEDURE sp_bloqueodesbloqueo_cuentas_por_recuperacion_creddeb(
  pNumCuenta                   CHAR(20)
  pTipoProducto                CHAR(2)
  pAccion                      CHAR(2)
  pUsuario                     INTEGER
) RETURNING CHAR(5) AS codeRet,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pNumCuenta` | `CHAR(20)` | — | — |
| `pTipoProducto` | `CHAR(2)` | — | — |
| `pAccion` | `CHAR(2)` | — | — |
| `pUsuario` | `INTEGER` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vResultado_saldo_congelado` | `MONEY` | L6 |
| `eEmpresa` | `CHAR(5)` | L7 |
| `codeRet` | `CHAR(5)` | L8 |
| `mensajeRet` | `CHAR(30)` | L9 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sc_maechq` | `bdicheq` | ⚠️ sí | SELECT | L27 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `bloqueo_cta` | `bdicheq` | ⚠️ sí | L31 |
| `sp_desbloqueocuenta` | `bdicred` | ⚠️ sí | L55 |
| `sp_bloqueocuenta` | `bdicred` | ⚠️ sí | L59 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `bloqueo` | ACCION | bloquea cuenta | 🔵 CONVENCIÓN | nombre_sp |
| `desbloqueo` | ACCION | desbloquea cuenta | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `cuentas` | ENTIDAD | cuentas (plural) | 🔵 CONVENCIÓN | nombre_sp |
| `por` | MODIF | por (criterio) | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `recuperacion` | ACCION | recuperación (cobranza) | 🔵 CONVENCIÓN | nombre_sp |
| `cred` | ENTIDAD | crédito | 🔵 CONVENCIÓN | nombre_sp |
| `deb` | MODIF | débito | 🔵 CONVENCIÓN | nombre_sp |

---

## `sp_busca_acl_por_folio_canales`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_busca_acl_por_folio_canales.sql` |
| **LOC (1er CREATE)** | 226 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 2 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "busca folio y canales" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 1 llamada(s): `sp_obten_estatus_canales` |
| **Evidencia vocab** | CÓDIGO=4 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=0 / 6 términos |

### Firma

```sql
CREATE PROCEDURE sp_busca_acl_por_folio_canales(
  pCliente                     CHAR(9)
  pFolio                       CHAR(18)
) RETURNING CHAR(5)             AS cod_ret,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pCliente` | `CHAR(9)` | — | — |
| `pFolio` | `CHAR(18)` | `folio`=folio | ✅ CÓDIGO |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `sql_err` | `INTEGER` | L22 |
| `v_cod_ret` | `CHAR(5)` | L23 |
| `v_cod_ret_estatus` | `CHAR(5)` | L24 |
| `v_es_folio_csuac` | `CHAR(18)` | L26 |
| `v_es_folio_aclaracion` | `CHAR(18)` | L27 |
| `v_folio_aclaracion` | `CHAR(18)` | L29 |
| `v_id_flujo` | `INTEGER` | L30 |
| `v_flujo` | `CHAR(50)` | L31 |
| `v_fechacaptura` | `DATE` | L32 |
| `v_importereclamado` | `MONEY` | L33 |
| `v_estatus_canales` | `CHAR(50)` | L35 |
| `v_concatena_dictamen` | `SMALLINT` | L36 |
| `v_id_etapa_canales` | `INTEGER` | L37 |
| `v_desc_etapa_canales` | `CHAR(20)` | L38 |
| `v_id_aclaracion` | `INTEGER` | L40 |
| `v_folio_csuac` | `CHAR(11)` | L41 |
| `c_fecha_actual` | `DATE` | L43 |
| `c_fecha_inicial` | `DATE` | L44 |
| `v_estatus_aclaracion` | `INTEGER` | L46 |
| `v_estatus_corp_gral` | `INTEGER` | L47 |
| `v_estatus_corp_analisis` | `INTEGER` | L48 |
| `v_procede` | `SMALLINT` | L49 |
| `v_tipo_movimiento` | `CHAR(1)` | L50 |
| `c_estatus_proceso` | `CHAR(50)` | L52 |
| `c_id_estatus_proceso` | `INTEGER` | L53 |
| *…2 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_fechas` | `bdinteg` | ⚠️ sí | SELECT | L106 |
| `acl_estatus_aclaracion` | `bdiaclaracion` | no | SELECT | L114 |
| `acl_aclaracion` | `bdiaclaracion` | no | SELECT | L126 |
| `acl_folio_aclaracion` | `bdiaclaracion` | no | SELECT | L132 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_obten_estatus_canales` | `bdiaclaracion` | no | L156 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L109 | FÓRMULA | `LET c_fecha_inicial = ADD_MONTHS(c_fecha_actual, -12);` |  |
| L129 | VALIDACIÓN_NULL | `IF v_es_folio_csuac <> 1 OR v_es_folio_csuac IS NULL THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `busca` | ACCION | busca / localiza | 🔵 CONVENCIÓN | nombre_sp |
| `acl` | PREFIJO | familia aclaraciones | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `por` | MODIF | por (criterio) | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `folio` | ENTIDAD | folio | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `canales` | ENTIDAD | canales (de distribución) | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |

---

## `sp_busca_aclaraciones_canales`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_busca_aclaraciones_canales.sql` |
| **LOC (1er CREATE)** | 163 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 5 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "busca aclaraciones y canales" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 1 llamada(s): `sp_obten_estatus_canales` |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=0 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_busca_aclaraciones_canales(
  pCliente                     CHAR(9)
) RETURNING CHAR(5)             AS cod_ret,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pCliente` | `CHAR(9)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `sql_err` | `INTEGER` | L19 |
| `v_cod_ret` | `CHAR(5)` | L20 |
| `v_cod_ret_estatus` | `CHAR(5)` | L21 |
| `v_folio_aclaracion` | `CHAR(18)` | L22 |
| `v_id_flujo` | `INTEGER` | L23 |
| `v_flujo` | `CHAR(50)` | L24 |
| `v_fechacaptura` | `DATE` | L25 |
| `v_importereclamado` | `MONEY` | L26 |
| `v_estatus_canales` | `CHAR(50)` | L28 |
| `v_concatena_dictamen` | `SMALLINT` | L29 |
| `v_id_etapa_canales` | `INTEGER` | L30 |
| `v_desc_etapa_canales` | `CHAR(20)` | L31 |
| `v_id_aclaracion` | `INTEGER` | L33 |
| `v_folio_csuac` | `CHAR(11)` | L34 |
| `v_estatus_aclaracion` | `INTEGER` | L39 |
| `v_estatus_corp_gral` | `INTEGER` | L40 |
| `v_estatus_corp_analisis` | `INTEGER` | L41 |
| `v_procede` | `SMALLINT` | L42 |
| `v_tipo_movimiento` | `CHAR(1)` | L43 |
| `c_estatus_pre_ingreso` | `CHAR(50)` | L45 |
| `c_id_estatus_pre_ingreso` | `INTEGER` | L46 |
| `c_estatus_declinado` | `CHAR(50)` | L47 |
| `c_id_estatus_declinado` | `INTEGER` | L48 |
| `c_estatus_intento` | `CHAR(50)` | L49 |
| `c_id_estatus_intento` | `INTEGER` | L50 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `acl_estatus_corporativo` | `bdiaclaracion` | no | SELECT | L97 |
| `acl_estatus_aclaracion` | `bdiaclaracion` | no | SELECT | L104 |
| `acl_aclaracion` | `bdiaclaracion` | no | SELECT | L121 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_obten_estatus_canales` | `bdiaclaracion` | no | L133 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `busca` | ACCION | busca / localiza | 🔵 CONVENCIÓN | nombre_sp |
| `aclaraciones` | ENTIDAD | aclaraciones (proceso de disputas/reclamaciones de cliente) | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `canales` | ENTIDAD | canales (de distribución) | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |

---

## `sp_busca_aclaraciones_gerente`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_busca_aclaraciones_gerente.sql` |
| **LOC (1er CREATE)** | 62 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 5 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "busca aclaraciones" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 1 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=1 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_busca_aclaraciones_gerente(
  p_NumEmpleado                CHAR(10)
) RETURNING CHAR(15) AS pky_aclaracion,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_NumEmpleado` | `CHAR(10)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `resultado_pky_aclaracion` | `CHAR(10)` | L9 |
| `resultado_folio_csuac` | `CHAR(10)` | L10 |
| `resultado_nombre` | `CHAR(60)` | L11 |
| `resultado_numero_emp_promotor` | `CHAR(10)` | L12 |
| `resultado_fechacaptura` | `DATE` | L13 |
| `resultado_dias_vencimiento` | `INTEGER` | L16 |
| `resultado_fecha_vencimiento` | `DATE` | L17 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `acl_cat_tipo_aclaracion` | `bdiaclaracion` | no | SELECT | L42 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L45 | FÓRMULA | `LET resultado_fecha_vencimiento=resultado_fechacaptura+resultado_dias_vencimiento UNITS DAY;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `busca` | ACCION | busca / localiza | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `aclaraciones` | ENTIDAD | aclaraciones (proceso de disputas/reclamaciones de cliente) | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?_gerente` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_gerente` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_busca_aclaraciones_promotor`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_busca_aclaraciones_promotor.sql` |
| **LOC (1er CREATE)** | 56 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 4 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "busca aclaraciones y motor de decisión" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 1 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=1 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_busca_aclaraciones_promotor(
  p_NumEmpleado                CHAR(10)
) RETURNING CHAR(15) AS pky_aclaracion,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_NumEmpleado` | `CHAR(10)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `resultado_pky_aclaracion` | `CHAR(10)` | L7 |
| `resultado_folio_csuac` | `CHAR(10)` | L8 |
| `resultado_fechacaptura` | `DATE` | L9 |
| `resultado_dias_vencimiento` | `INTEGER` | L12 |
| `resultado_fecha_vencimiento` | `DATE` | L13 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `acl_cat_tipo_aclaracion` | `bdiaclaracion` | no | SELECT | L37 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L40 | FÓRMULA | `LET resultado_fecha_vencimiento=resultado_fechacaptura+resultado_dias_vencimiento UNITS DAY;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `busca` | ACCION | busca / localiza | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `aclaraciones` | ENTIDAD | aclaraciones (proceso de disputas/reclamaciones de cliente) | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?_pro` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `motor` | ENTIDAD | motor de decisión | 🔵 CONVENCIÓN | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_pro` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_busca_cte_domiciliacion`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_busca_cte_domiciliacion.sql` |
| **LOC (1er CREATE)** | 523 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "busca cliente y domiciliación" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 25 llamada(s): `sp_buscarclientespornumero`, `sp_buscarclientesportarjeta`, `sp_buscarclientesporcuenta` |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=4 · INFERIDO=0 · SINTÉTICO=0 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_busca_cte_domiciliacion(
  bandera                      CHAR(5)
  eNumeroCliente               CHAR(20)
  eNumeroTarjeta               CHAR(20)
  eNumeroCuenta                CHAR(20)
  eEmpresa                     CHAR(3)
  eTelefonoTransfer            CHAR(20)
  ePrimerNombre                CHAR(30)
  eSegundoNombre               CHAR(30)
  ePrimerApellido              CHAR(30)
  eSegundoApellido             CHAR(30)
  eTelefonoCorreo              CHAR(5)
  eConsultaDatosActual         INTEGER
  eNumEmpleado                 CHAR(12)
  eClienteTelefonoCelular      CHAR(20)
  eClienteCorreoElectronico    CHAR(100)
  eFechaInicial                DATE
  eFechaFinal                  DATE
  eMonto                       money(16,2)
  eNumeroTransacciones         lvarchar
  eOrigenEvento                INTEGER
  eArchivoInternacional        CHAR(30)
  eArchivoNacional             CHAR(30)
  eSkip                        INTEGER
  opc1                         CHAR(30)
  opc2                         CHAR(30)
  opc3                         CHAR(30)
  opc4                         CHAR(30)
  opc5                         CHAR(30)
) RETURNING CHAR(5)   AS sCodigoRetorno,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `bandera` | `CHAR(5)` | — | — |
| `eNumeroCliente` | `CHAR(20)` | — | — |
| `eNumeroTarjeta` | `CHAR(20)` | — | — |
| `eNumeroCuenta` | `CHAR(20)` | — | — |
| `eEmpresa` | `CHAR(3)` | — | — |
| `eTelefonoTransfer` | `CHAR(20)` | — | — |
| `ePrimerNombre` | `CHAR(30)` | — | — |
| `eSegundoNombre` | `CHAR(30)` | — | — |
| `ePrimerApellido` | `CHAR(30)` | — | — |
| `eSegundoApellido` | `CHAR(30)` | — | — |
| `eTelefonoCorreo` | `CHAR(5)` | — | — |
| `eConsultaDatosActual` | `INTEGER` | — | — |
| `eNumEmpleado` | `CHAR(12)` | — | — |
| `eClienteTelefonoCelular` | `CHAR(20)` | — | — |
| `eClienteCorreoElectronico` | `CHAR(100)` | — | — |
| `eFechaInicial` | `DATE` | — | — |
| `eFechaFinal` | `DATE` | — | — |
| `eMonto` | `money(16,2)` | — | — |
| `eNumeroTransacciones` | `lvarchar` | — | — |
| `eOrigenEvento` | `INTEGER` | — | — |
| `eArchivoInternacional` | `CHAR(30)` | — | — |
| `eArchivoNacional` | `CHAR(30)` | — | — |
| `eSkip` | `INTEGER` | — | — |
| `opc1` | `CHAR(30)` | — | — |
| `opc2` | `CHAR(30)` | — | — |
| `opc3` | `CHAR(30)` | — | — |
| `opc4` | `CHAR(30)` | — | — |
| `opc5` | `CHAR(30)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `sCodigoRetorno` | `CHAR(5)` | L92 |
| `sCodigoDescripcion` | `CHAR(100)` | L93 |
| `sNumeroRegistros` | `CHAR(10)` | L94 |
| `sNumeroCliente` | `CHAR(20)` | L95 |
| `sPrimerNombre` | `CHAR(30)` | L96 |
| `sSegundoNombre` | `CHAR(30)` | L97 |
| `sPrimerApellido` | `CHAR(30)` | L98 |
| `sSegundoApellido` | `CHAR(30)` | L99 |
| `sNumeroProducto` | `CHAR(6)` | L100 |
| `sDescripcionProducto` | `CHAR(60)` | L101 |
| `sNumeroCuenta` | `CHAR(20)` | L102 |
| `sNumeroTarjeta` | `CHAR(20)` | L103 |
| `sStatusTarjeta` | `CHAR(3)` | L104 |
| `sTelefonoTransfer` | `CHAR(20)` | L105 |
| `sNumeroCuentaInversion` | `CHAR(30)` | L106 |
| `sNumeroCuentaTransfer` | `CHAR(30)` | L107 |
| `sNumeroClienteTransfer` | `CHAR(30)` | L108 |
| `sTelefonoCasa` | `CHAR(20)` | L109 |
| `sTelefonoCelular` | `CHAR(20)` | L110 |
| `sCompaniaCelular` | `CHAR(30)` | L111 |
| `sIdCompaniaCelular` | `INTEGER` | L112 |
| `sCorreoElectronico` | `CHAR(100)` | L113 |
| `sFechaMovimiento` | `DATE` | L114 |
| `sHoraMovimiento` | `DATETIME HOUR to FRACTION(3)` | L115 |
| `sMonto` | `MONEY(16,2)` | L116 |
| *…23 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `dom_errores` | `bdidomi` | ⚠️ sí | INSERT | L204 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_buscarclientespornumero` | `bdinteg` | ⚠️ sí | L224 |
| `sp_buscarclientesportarjeta` | `bdinteg` | ⚠️ sí | L233 |
| `sp_buscarclientesporcuenta` | `bdinteg` | ⚠️ sí | L242 |
| `sp_buscarclientespornombre` | `bdinteg` | ⚠️ sí | L253 |
| `sp_busca_producto_cred_cuenta` | `bdinteg` | ⚠️ sí | L266 |
| `sp_busca_producto_cred_tarjeta` | `bdinteg` | ⚠️ sí | L277 |
| `sp_busca_producto_transfer_telefono` | `bdinteg` | ⚠️ sí | L288 |
| `sp_busca_producto_deb_cheq_cliente` | `bdinteg` | ⚠️ sí | L301 |
| `sp_busca_producto_cred_cliente` | `bdinteg` | ⚠️ sí | L314 |
| `sp_busca_producto_cred_cliente_crd` | `bdinteg` | ⚠️ sí | L327 |
| `sp_busca_producto_deb_inver_cliente` | `bdinteg` | ⚠️ sí | L340 |
| `sp_busca_producto_transfer_cliente` | `bdinteg` | ⚠️ sí | L353 |
| `sp_consulta_telefonos` | `bdinteg` | ⚠️ sí | L366 |
| `sp_buscar_movimientos_cheques_dia3` | `bdinteg` | ⚠️ sí | L378 |
| `sp_buscar_movimientos_inversion_dia2` | `bdinteg` | ⚠️ sí | L392 |
| `sp_buscar_movimientos_inversion_his2` | `bdinteg` | ⚠️ sí | L404 |
| `sp_buscar_movimientos_transfer` | `bdinteg` | ⚠️ sí | L413 |
| `sp_buscar_movimientos_credito_dia3` | `bdinteg` | ⚠️ sí | L425 |
| `sp_buscar_movimientos_credito_his3` | `bdinteg` | ⚠️ sí | L439 |
| `sp_buscar_movimientos_creditocrd_his` | `bdinteg` | ⚠️ sí | L453 |
| `sp_consulta_tipo_movimiento` | `bdiaclaracion` | no | L465 |
| `sp_obten_secuencia_folio` | `bdiaclaracion` | no | L474 |
| `sp_obten_referencia23_cheques` | `bdinteg` | ⚠️ sí | L483 |
| `sp_consultaparamdomi` | `bdidomi` | ⚠️ sí | L493 |
| `sp_consultactasdomi` | `bdidomi` | ⚠️ sí | L505 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `busca` | ACCION | busca / localiza | 🔵 CONVENCIÓN | nombre_sp |
| `cte` | ENTIDAD | cliente | 🔵 CONVENCIÓN | nombre_sp |
| `domiciliacion` | ENTIDAD | domiciliación | 🔵 CONVENCIÓN | nombre_sp |

---

## `sp_busca_datos_3410_fda`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_busca_datos_3410_fda.sql` |
| **LOC (1er CREATE)** | 1242 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 2 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "busca datos" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 1 llamada(s): `sp_consulta_tipo_movimiento` |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=1 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_busca_datos_3410_fda(
  pFolioCsuac                  CHAR(11)
) RETURNING CHAR(5)				AS cod_ret,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pFolioCsuac` | `CHAR(11)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `sql_err` | `INTEGER` | L49 |
| `v_cod_ret` | `CHAR(5)` | L50 |
| `v_id_aclaracion` | `INTEGER` | L51 |
| `v_importereclamado` | `MONEY` | L52 |
| `v_evento` | `INTEGER` | L53 |
| `v_origen_evento` | `INTEGER` | L54 |
| `v_tipo_pos` | `VARCHAR(5)` | L55 |
| `v_es_evento_robo_ext` | `SMALLINT` | L56 |
| `v_estatus_aclaracion` | `INTEGER` | L57 |
| `v_estatus_corp_gral` | `INTEGER` | L58 |
| `v_estatus_corp_analisis` | `INTEGER` | L59 |
| `v_modo_entrada` | `CHAR(2)` | L60 |
| `v_es_nacional` | `CHAR(1)` | L61 |
| `v_referencia_mov` | `VARCHAR(30)` | L62 |
| `v_referencia23_mov` | `VARCHAR(30)` | L63 |
| `v_num_autorizacion` | `CHAR(6)` | L64 |
| `v_comercio` | `VARCHAR(40)` | L65 |
| `v_fechacaptura` | `DATE` | L66 |
| `v_fecha_movimiento` | `DATETIME YEAR TO FRACTION(5)` | L67 |
| `v_num_tarjeta` | `CHAR(16)` | L68 |
| `v_procede_abono_tmp` | `SMALLINT` | L69 |
| `v_id_msg_no_procedente` | `SMALLINT` | L70 |
| `c_estatus_abonar` | `INTEGER` | L71 |
| `c_nombre_estatus_abonar` | `CHAR(20)` | L72 |
| `v_estatus_tarjeta` | `CHAR(3)` | L73 |
| *…65 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `acl_bitacora_fda_3410` | `bdiaclaracion` | no | INSERT | L240 |
| `acl_estatus_corporativo` | `bdiaclaracion` | no | SELECT | L265 |
| `acl_aclaracion` | `bdiaclaracion` | no | SELECT | L281 |
| `tarjeta` | `intercard` | ⚠️ sí | SELECT | L293 |
| `bitacoracambiosstatustarjeta` | `intercard` | ⚠️ sí | SELECT | L303 |
| `acl_cat_datosnoconv` | `bdiaclaracion` | no | SELECT | L311 |
| `acl_cat_bines` | `bdiaclaracion` | no | SELECT | L315 |
| `bitacora_fda` | `intercard` | ⚠️ sí | SELECT | L339 |
| `acl_aclaracion` | `bdiaclaracion` | no | UPDATE | L362 |
| `movimiento` | `intercard` | ⚠️ sí | SELECT | L427 |
| `movimientohistorico` | `intercard` | ⚠️ sí | SELECT | L435 |
| `tarjeta_indicadores` | `intercard` | ⚠️ sí | SELECT | L475 |
| `bitacoracambiostarjeta` | `intercard` | ⚠️ sí | SELECT | L481 |
| `bit_pinoffline` | `intercard` | ⚠️ sí | SELECT | L499 |
| `bitacorapinoffline` | `intercard` | ⚠️ sí | SELECT | L504 |
| `acl_cat_tokenpy` | `bdiaclaracion` | no | SELECT | L796 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_consulta_tipo_movimiento` | `bdiaclaracion` | no | L354 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L317 | VALIDACIÓN_NULL | `IF banco_adquirente IS NULL OR banco_adquirente = '' THEN` |  |
| L331 | FÓRMULA | `LET v_foliosuc = v_foliosuc; -- quitar` |  |
| L348 | VALIDACIÓN_NULL | `IF v_modo_entrada IS NULL OR v_modo_entrada = 'NN' THEN` |  |
| L430 | VALIDACIÓN_NULL | `IF v_existe_movimiento IS NULL OR v_existe_movimiento = 0 THEN` |  |
| L439 | VALIDACIÓN_NULL | `IF v_existe_movimiento IS NULL OR v_existe_movimiento = 0 THEN` |  |
| L461 | FÓRMULA | `LET v_token_co_numero = substr(cvv2_dinamico,3,1); -- SE VALIDA EL TERCER ESPACIO DEL CVV2 Dinamico ` |  |
| L462 | FÓRMULA | `LET v_token_co_espacio = substr(cvv2_dinamico,4,1); -- SE VALIDA EL CUARTO ESPACIO DEL CVV2 Dinamico` |  |
| L507 | VALIDACIÓN_NULL | `IF v_fecha_act_pinoffline_suc IS NULL AND v_fecha_act_pinoffline_atm IS NULL THEN` |  |
| L513 | VALIDACIÓN_NULL | `IF v_fecha_act_pinoffline_suc IS NULL THEN` |  |
| L558 | FÓRMULA | `LET v_procede_abono_tmp = 1; --Si es diferencia de Importes.` | 🔴 MONEY/aritmética financiera |
| L574 | FÓRMULA | `LET v_procede_abono_tmp = 0; -- candidato para ser NO procedente` |  |
| L745 | FÓRMULA | `LET v_foliosuc = v_foliosuc; -- quitar` |  |
| L768 | VALIDACIÓN_NULL | `IF banco_adquirente IS NULL OR banco_adquirente = '' THEN` |  |
| L821 | FÓRMULA | `LET v_procede_abono_tmp = 0; -- dictamina NO procedente` |  |
| L841 | FÓRMULA | `LET v_procede_abono_tmp = 1; -- dictamina procedente` |  |
| L1018 | FÓRMULA | `LET v_procede_abono_tmp = 0; -- dictamina NO procedente` |  |
| L1042 | VALIDACIÓN_NULL | `IF cod_segundo_fda IS NULL THEN` |  |
| L1075 | VALIDACIÓN_NULL | `IF cod_segundo_fda IS NULL THEN` |  |
| L1100 | FÓRMULA | `LET v_procede_abono_tmp = 0; -- dictamina NO procedente` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `busca` | ACCION | busca / localiza | 🔵 CONVENCIÓN | nombre_sp |
| `datos` | ENTIDAD | datos | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?_3410_fda` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_3410_fda` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_busca_datos_3410_mx`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_busca_datos_3410_mx.sql` |
| **LOC (1er CREATE)** | 487 |
| **Callgraph** | ✅ fan_in=0 / fan_out=3 |
| **Deps concatenadas** | 3 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "busca datos" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 1 llamada(s): `sp_consulta_tipo_movimiento` |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=4 · INFERIDO=0 · SINTÉTICO=1 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_busca_datos_3410_mx(
  pFolioCsuac                  CHAR(11)
) RETURNING CHAR(5)				AS cod_ret,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pFolioCsuac` | `CHAR(11)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `sql_err` | `INTEGER` | L30 |
| `v_cod_ret` | `CHAR(5)` | L31 |
| `v_id_aclaracion` | `INTEGER` | L33 |
| `v_importereclamado` | `MONEY` | L34 |
| `v_evento` | `INTEGER` | L35 |
| `v_origen_evento` | `INTEGER` | L36 |
| `v_tipo_pos` | `VARCHAR(5)` | L37 |
| `v_es_evento_robo_ext` | `SMALLINT` | L38 |
| `v_estatus_aclaracion` | `INTEGER` | L40 |
| `v_estatus_corp_gral` | `INTEGER` | L41 |
| `v_estatus_corp_analisis` | `INTEGER` | L42 |
| `v_modo_entrada` | `CHAR(2)` | L44 |
| `v_es_nacional` | `CHAR(1)` | L45 |
| `v_referencia_mov` | `VARCHAR(30)` | L46 |
| `v_num_autorizacion` | `CHAR(6)` | L47 |
| `v_comercio` | `VARCHAR(40)` | L48 |
| `v_fechacaptura` | `DATE` | L49 |
| `v_fecha_movimiento` | `DATETIME YEAR TO FRACTION(5)` | L50 |
| `v_fecha_act_pinoffline` | `DATETIME YEAR TO FRACTION(5)` | L51 |
| `v_fecha_act_pinoffline_atm` | `DATETIME YEAR TO FRACTION(5)` | L52 |
| `v_fecha_act_pinoffline_suc` | `DATETIME YEAR TO FRACTION(5)` | L53 |
| `v_fecha_act_cvv2` | `DATETIME YEAR TO FRACTION(5)` | L54 |
| `v_tiene_pinoffline` | `SMALLINT` | L55 |
| `v_pinoffline_validado` | `SMALLINT` | L56 |
| `v_num_tarjeta` | `CHAR(16)` | L57 |
| *…29 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `acl_estatus_corporativo` | `bdiaclaracion` | no | SELECT | L176 |
| `acl_aclaracion` | `bdiaclaracion` | no | SELECT | L192 |
| `tarjeta` | `intercard` | ⚠️ sí | SELECT | L247 |
| `bitacoracambiosstatustarjeta` | `intercard` | ⚠️ sí | SELECT | L255 |
| `movimiento` | `intercard` | ⚠️ sí | SELECT | L263 |
| `movimientohistorico` | `intercard` | ⚠️ sí | SELECT | L269 |
| `bit_pinoffline` | `intercard` | ⚠️ sí | SELECT | L283 |
| `bitacorapinoffline` | `intercard` | ⚠️ sí | SELECT | L288 |
| `tarjeta_indicadores` | `intercard` | ⚠️ sí | SELECT | L358 |
| `bitacoracambiostarjeta` | `intercard` | ⚠️ sí | SELECT | L366 |
| `acl_no_procedenterbt` | `bdiaclaracion` | no | SELECT | L458 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_consulta_tipo_movimiento` | `bdiaclaracion` | no | L232 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L220 | FÓRMULA | `LET v_procede_abono_tmp = 1; --Si es diferencia de Importes, Continúa con el proceso Abonar` | 🔴 MONEY/aritmética financiera |
| L226 | VALIDACIÓN_NULL | `IF v_modo_entrada IS NULL OR v_modo_entrada = 'NN' THEN` |  |
| L266 | VALIDACIÓN_NULL | `IF v_existe_movimiento IS NULL OR v_existe_movimiento = 0 THEN` |  |
| L273 | VALIDACIÓN_NULL | `IF v_modo_entrada IS NULL OR v_modo_entrada = 'NN' THEN` |  |
| L291 | VALIDACIÓN_NULL | `IF v_fecha_act_pinoffline_suc IS NULL AND v_fecha_act_pinoffline_atm IS NULL THEN` |  |
| L297 | VALIDACIÓN_NULL | `IF v_fecha_act_pinoffline_suc IS NULL THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `busca` | ACCION | busca / localiza | 🔵 CONVENCIÓN | nombre_sp |
| `datos` | ENTIDAD | datos | 🔵 CONVENCIÓN | nombre_sp |
| `?_3410_m` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `x` | MODIF | por (criterio) | 🔵 CONVENCIÓN | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_3410_m` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_busca_nombre_core`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_busca_nombre_core.sql` |
| **LOC (1er CREATE)** | 31 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 8 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "busca nombre" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 1 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=1 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_busca_nombre_core(
  p_empleado                   CHAR(10)
) RETURNING CHAR(80) AS nombre_empleado
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_empleado` | `CHAR(10)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `resultado_nombre_empleado` | `CHAR(120)` | L5 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_ejecut` | `bdinteg` | ⚠️ sí | SELECT | L14 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `busca` | ACCION | busca / localiza | 🔵 CONVENCIÓN | nombre_sp |
| `nombre` | ENTIDAD | nombre | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `?_core` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_core` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_busca_producto`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_busca_producto.sql` |
| **LOC (1er CREATE)** | 209 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 5 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "busca producto" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 16 llamada(s): `sp_busca_producto_cred_cliente`, `sp_busca_producto_cred_cliente_crd`, `sp_busca_producto_deb_inver_cliente` |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=0 / 3 términos |

### Firma

```sql
CREATE PROCEDURE sp_busca_producto(
  pUsuario                     CHAR(8)
  pOpcion                      CHAR(1)
  pNumeroCliente               CHAR(20)
  pNumeroTarjeta               CHAR(20)
  pNumeroCuenta                CHAR(20)
  pTelefonoCliente             CHAR(20)
) RETURNING CHAR(5) AS codRet,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pUsuario` | `CHAR(8)` | — | — |
| `pOpcion` | `CHAR(1)` | — | — |
| `pNumeroCliente` | `CHAR(20)` | — | — |
| `pNumeroTarjeta` | `CHAR(20)` | — | — |
| `pNumeroCuenta` | `CHAR(20)` | — | — |
| `pTelefonoCliente` | `CHAR(20)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(5)` | L10 |
| `iSqlErr` | `INTEGER` | L11 |
| `cCodRetSp` | `CHAR(6)` | L12 |
| `iCodRetSp` | `INTEGER` | L13 |
| `cNumeroProducto` | `CHAR(6)` | L15 |
| `cNombreProducto` | `CHAR(60)` | L16 |
| `cNumeroCuenta` | `CHAR(30)` | L17 |
| `cNumeroTarjeta` | `CHAR(30)` | L18 |
| `cStatusTarjeta` | `CHAR(3)` | L19 |
| `cNumeroCuentaInversion` | `CHAR(30)` | L21 |
| `cTelefonoTransfer` | `CHAR(30)` | L22 |
| `cClienteTransfer` | `CHAR(30)` | L23 |
| `iRecuperacion` | `INTEGER` | L24 |
| `cEmpresa` | `CHAR(3)` | L25 |
| `iTipoProducto` | `INTEGER` | L26 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `productos_cliente_tmp` | `bdiaclaracion` | no | SELECT | L64 |
| `productos_cliente_tmp` | `bdiaclaracion` | no | DELETE | L64 |
| `productos_cliente_tmp` | `bdiaclaracion` | no | INSERT | L72 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_busca_producto_cred_cliente` | `bdiaclaracion` | no | L69 |
| `sp_busca_producto_cred_cliente_crd` | `bdiaclaracion` | no | L76 |
| `sp_busca_producto_deb_inver_cliente` | `bdinteg` | ⚠️ sí | L83 |
| `sp_busca_producto_deb_cheq_cliente` | `bdiaclaracion` | no | L90 |
| `sp_busca_producto_transfer_cliente` | `bdiaclaracion` | no | L97 |
| `sp_busca_producto_cred_tarjeta_crd` | `bdiaclaracion` | no | L105 |
| `sp_busca_producto_cred_tarjeta` | `bdiaclaracion` | no | L111 |
| `sp_busca_producto_transfer_tarjeta` | `bdiaclaracion` | no | L117 |
| `sp_busca_producto_deb_cheq_tarjeta` | `bdiaclaracion` | no | L123 |
| `sp_busca_producto_deb_inver_tarjeta` | `bdinteg` | ⚠️ sí | L129 |
| `sp_busca_producto_cred_cuenta` | `bdiaclaracion` | no | L137 |
| `sp_busca_producto_cred_cuenta_crd` | `bdiaclaracion` | no | L144 |
| `sp_busca_producto_deb_cheq_cuenta` | `bdiaclaracion` | no | L150 |
| `sp_busca_producto_transfer_cuenta` | `bdiaclaracion` | no | L156 |
| `sp_busca_producto_deb_inver_cuenta` | `bdinteg` | ⚠️ sí | L163 |
| `sp_busca_producto_transfer_telefono` | `bdiaclaracion` | no | L171 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L28 | CÓDIGO_RETORNO | `LET cCodRet = '00000';` |  |
| L57 | CÓDIGO_RETORNO | `LET cCodRet = '00003';` |  |
| L185 | FÓRMULA | `LET iRecuperacion = iRecuperacion + 1;` |  |
| L190 | CÓDIGO_RETORNO | `LET cCodRet = '00017';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `busca` | ACCION | busca / localiza | 🔵 CONVENCIÓN | nombre_sp |
| `producto` | ENTIDAD | producto | ✅ CÓDIGO | nombre_sp, texto_cuerpo |

---

## `sp_busca_producto_cred_cliente`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_busca_producto_cred_cliente.sql` |
| **LOC (1er CREATE)** | 73 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 18 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "busca producto, crédito y cliente" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 2 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=5 · INFERIDO=0 · SINTÉTICO=0 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_busca_producto_cred_cliente(
  p_sNumeroCliente             CHAR(20)
  p_skip                       INT
) RETURNING CHAR(6) AS numeroProducto, CHAR(60) AS nombreProducto, CHAR(30) AS numeroCuenta, CHAR(30) AS numeroTarjeta, CHAR(3) AS statusTarjeta
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_sNumeroCliente` | `CHAR(20)` | `cliente`=cliente | 🔵 CONVENCIÓN |
| `p_skip` | `INT` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `resultado_numeroProducto` | `CHAR(6)` | L5 |
| `resultado_nombreProducto` | `CHAR(60)` | L6 |
| `resultado_numeroCuenta` | `CHAR(30)` | L7 |
| `resultado_numeroTarjeta` | `CHAR(30)` | L8 |
| `iSqlErr` | `INTEGER` | L9 |
| `cStatusTarjeta` | `CHAR(3)` | L10 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sd_maecred` | `bdicred` | ⚠️ sí | SELECT | L41 |
| `tarjeta` | `intercard` | ⚠️ sí | SELECT | L54 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `busca` | ACCION | busca / localiza | 🔵 CONVENCIÓN | nombre_sp |
| `producto` | ENTIDAD | producto | 🔵 CONVENCIÓN | nombre_sp |
| `cred` | ENTIDAD | crédito | 🔵 CONVENCIÓN | nombre_sp |
| `cliente` | ENTIDAD | cliente | 🔵 CONVENCIÓN | nombre_sp |

---

## `sp_busca_producto_cred_cliente_crd`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_busca_producto_cred_cliente_crd.sql` |
| **LOC (1er CREATE)** | 54 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 10 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "busca producto, crédito y cliente" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 1 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=5 · INFERIDO=1 · SINTÉTICO=0 / 6 términos |

### Firma

```sql
CREATE PROCEDURE sp_busca_producto_cred_cliente_crd(
  p_sNumeroCliente             CHAR(20)
  p_skip                       INT
) RETURNING CHAR(6) AS numeroProducto,CHAR(60) AS nombreProducto, CHAR(30) AS numeroCuenta, CHAR(30) AS numeroTarjeta, CHAR(3) AS statusTarjeta
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_sNumeroCliente` | `CHAR(20)` | `cliente`=cliente | 🔵 CONVENCIÓN |
| `p_skip` | `INT` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `resultado_numeroProducto` | `CHAR(6)` | L6 |
| `resultado_nombreProducto` | `CHAR(60)` | L7 |
| `resultado_numeroCuenta` | `CHAR(30)` | L8 |
| `resultado_numeroTarjeta` | `CHAR(30)` | L9 |
| `iSqlErr` | `INTEGER` | L10 |
| `cStatusTarjeta` | `CHAR(3)` | L11 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sd_maecredcrd` | `bdicred` | ⚠️ sí | SELECT | L38 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `busca` | ACCION | busca / localiza | 🔵 CONVENCIÓN | nombre_sp |
| `producto` | ENTIDAD | producto | 🔵 CONVENCIÓN | nombre_sp |
| `cred` | ENTIDAD | crédito | 🔵 CONVENCIÓN | nombre_sp |
| `cliente` | ENTIDAD | cliente | 🔵 CONVENCIÓN | nombre_sp |
| `crd` | ENTIDAD | crédito (abreviación) | 🟡 INFERIDO | nombre_sp |

---

## `sp_busca_producto_cred_cuenta`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_busca_producto_cred_cuenta.sql` |
| **LOC (1er CREATE)** | 93 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 1 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "busca producto, crédito y cuenta" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 4 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=4 · INFERIDO=0 · SINTÉTICO=0 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_busca_producto_cred_cuenta(
  p_sNumeroCuenta              CHAR(20)
  p_skip                       INT
  p_sNumeroEmpresa             CHAR(3)
) RETURNING CHAR(6) AS numeroProducto, CHAR(60) AS nombreProducto, CHAR(30) AS numeroCuenta, CHAR(30) AS numeroTarjeta, CHAR(3) AS statusTarjeta
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_sNumeroCuenta` | `CHAR(20)` | `cuenta`=cuenta | 🔵 CONVENCIÓN |
| `p_skip` | `INT` | — | — |
| `p_sNumeroEmpresa` | `CHAR(3)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `resultado_numeroProducto` | `CHAR(6)` | L5 |
| `resultado_nombreProducto` | `CHAR(60)` | L6 |
| `resultado_numeroCuenta` | `CHAR(30)` | L7 |
| `resultado_numeroTarjeta` | `CHAR(30)` | L8 |
| `iSqlErr` | `INTEGER` | L9 |
| `cStatusTarjeta` | `CHAR(3)` | L10 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sd_maecred` | `bdicred` | ⚠️ sí | SELECT | L41 |
| `tarjeta` | `intercard` | ⚠️ sí | SELECT | L57 |
| `si_credito_sv` | `bdinteg` | ⚠️ sí | SELECT | L71 |
| `acl_tipo_producto` | `bdiaclaracion` | no | SELECT | L77 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `busca` | ACCION | busca / localiza | 🔵 CONVENCIÓN | nombre_sp |
| `producto` | ENTIDAD | producto | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `cred` | ENTIDAD | crédito | 🔵 CONVENCIÓN | nombre_sp |
| `cuenta` | ENTIDAD | cuenta | 🔵 CONVENCIÓN | nombre_sp |

---

## `sp_busca_producto_cred_cuenta_crd`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_busca_producto_cred_cuenta_crd.sql` |
| **LOC (1er CREATE)** | 59 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 9 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "busca producto, crédito y cuenta" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 1 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=5 · INFERIDO=1 · SINTÉTICO=0 / 6 términos |

### Firma

```sql
CREATE PROCEDURE sp_busca_producto_cred_cuenta_crd(
  p_sNumeroCuenta              CHAR(20)
  p_skip                       INT
  p_sNumeroEmpresa             CHAR(3)
) RETURNING CHAR(6) AS numeroProducto,CHAR(60) AS nombreProducto, CHAR(30) AS numeroCuenta, CHAR(30) AS numeroTarjeta, CHAR(3) AS statusTarjeta
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_sNumeroCuenta` | `CHAR(20)` | `cuenta`=cuenta | 🔵 CONVENCIÓN |
| `p_skip` | `INT` | — | — |
| `p_sNumeroEmpresa` | `CHAR(3)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `resultado_numeroProducto` | `CHAR(6)` | L6 |
| `resultado_nombreProducto` | `CHAR(60)` | L7 |
| `resultado_numeroCuenta` | `CHAR(30)` | L8 |
| `resultado_numeroTarjeta` | `CHAR(30)` | L9 |
| `iSqlErr` | `INTEGER` | L10 |
| `cStatusTarjeta` | `CHAR(3)` | L11 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sd_maecredcrd` | `bdicred` | ⚠️ sí | SELECT | L41 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `busca` | ACCION | busca / localiza | 🔵 CONVENCIÓN | nombre_sp |
| `producto` | ENTIDAD | producto | 🔵 CONVENCIÓN | nombre_sp |
| `cred` | ENTIDAD | crédito | 🔵 CONVENCIÓN | nombre_sp |
| `cuenta` | ENTIDAD | cuenta | 🔵 CONVENCIÓN | nombre_sp |
| `crd` | ENTIDAD | crédito (abreviación) | 🟡 INFERIDO | nombre_sp |

---

## `sp_busca_producto_cred_tarjeta`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_busca_producto_cred_tarjeta.sql` |
| **LOC (1er CREATE)** | 76 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 17 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "busca producto, crédito y tarjeta" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 2 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=4 · INFERIDO=0 · SINTÉTICO=0 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_busca_producto_cred_tarjeta(
  p_sNumeroTarjeta             CHAR(20)
  p_sNumeroEmpresa             CHAR(3)
) RETURNING CHAR(6) AS numeroProducto, CHAR(60) AS nombreProducto, CHAR(30) AS numeroCuenta, CHAR(30) AS numeroTarjeta, CHAR(3) AS statusTarjeta
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_sNumeroTarjeta` | `CHAR(20)` | `tarjeta`=tarjeta | ✅ CÓDIGO |
| `p_sNumeroEmpresa` | `CHAR(3)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `resultado_numeroProducto` | `CHAR(6)` | L5 |
| `resultado_nombreProducto` | `CHAR(60)` | L6 |
| `resultado_numeroCuenta` | `CHAR(30)` | L7 |
| `resultado_numeroTarjeta` | `CHAR(30)` | L8 |
| `iSqlErr` | `INTEGER` | L9 |
| `cStatusTarjeta` | `CHAR(3)` | L10 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sd_maecred` | `bdicred` | ⚠️ sí | SELECT | L41 |
| `tarjeta` | `intercard` | ⚠️ sí | SELECT | L57 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `busca` | ACCION | busca / localiza | 🔵 CONVENCIÓN | nombre_sp |
| `producto` | ENTIDAD | producto | 🔵 CONVENCIÓN | nombre_sp |
| `cred` | ENTIDAD | crédito | 🔵 CONVENCIÓN | nombre_sp |
| `tarjeta` | ENTIDAD | tarjeta | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |

---

## `sp_busca_producto_cred_tarjeta_crd`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_busca_producto_cred_tarjeta_crd.sql` |
| **LOC (1er CREATE)** | 60 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 8 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "busca producto, crédito y tarjeta" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 1 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=4 · INFERIDO=1 · SINTÉTICO=0 / 6 términos |

### Firma

```sql
CREATE PROCEDURE sp_busca_producto_cred_tarjeta_crd(
  p_sNumeroTarjeta             CHAR(20)
  p_sNumeroEmpresa             CHAR(3)
) RETURNING CHAR(6) AS numeroProducto,CHAR(60) AS nombreProducto, CHAR(30) AS numeroCuenta, CHAR(30) AS numeroTarjeta, CHAR(3) AS statusTarjeta
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_sNumeroTarjeta` | `CHAR(20)` | `tarjeta`=tarjeta | ✅ CÓDIGO |
| `p_sNumeroEmpresa` | `CHAR(3)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `resultado_numeroProducto` | `CHAR(6)` | L6 |
| `resultado_nombreProducto` | `CHAR(60)` | L7 |
| `resultado_numeroCuenta` | `CHAR(30)` | L8 |
| `resultado_numeroTarjeta` | `CHAR(30)` | L9 |
| `iSqlErr` | `INTEGER` | L10 |
| `cStatusTarjeta` | `CHAR(3)` | L11 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sd_maecredcrd` | `bdicred` | ⚠️ sí | SELECT | L41 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `busca` | ACCION | busca / localiza | 🔵 CONVENCIÓN | nombre_sp |
| `producto` | ENTIDAD | producto | 🔵 CONVENCIÓN | nombre_sp |
| `cred` | ENTIDAD | crédito | 🔵 CONVENCIÓN | nombre_sp |
| `tarjeta` | ENTIDAD | tarjeta | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `crd` | ENTIDAD | crédito (abreviación) | 🟡 INFERIDO | nombre_sp |

---

## `sp_busca_producto_deb_cheq_cliente`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_busca_producto_deb_cheq_cliente.sql` |
| **LOC (1er CREATE)** | 54 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 7 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "busca producto, cheque y cliente (débito)" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 1 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=5 · INFERIDO=0 · SINTÉTICO=0 / 6 términos |

### Firma

```sql
CREATE PROCEDURE sp_busca_producto_deb_cheq_cliente(
  p_sNumeroCliente             CHAR(20)
  p_skip                       INT
) RETURNING CHAR(6) AS numeroProducto,CHAR(60) AS nombreProducto, CHAR(30) AS numeroCuenta, CHAR(30) AS numeroTarjeta, CHAR(3) AS statusTarjeta
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_sNumeroCliente` | `CHAR(20)` | `cliente`=cliente | 🔵 CONVENCIÓN |
| `p_skip` | `INT` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `resultado_numeroProducto` | `CHAR(6)` | L6 |
| `resultado_nombreProducto` | `CHAR(60)` | L7 |
| `resultado_numeroCuenta` | `CHAR(30)` | L8 |
| `resultado_numeroTarjeta` | `CHAR(30)` | L9 |
| `iSqlErr` | `INTEGER` | L10 |
| `cStatusTarjeta` | `CHAR(3)` | L11 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sc_maechq` | `bdicheq` | ⚠️ sí | SELECT | L38 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `busca` | ACCION | busca / localiza | 🔵 CONVENCIÓN | nombre_sp |
| `producto` | ENTIDAD | producto | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `deb` | MODIF | débito | 🔵 CONVENCIÓN | nombre_sp |
| `cheq` | ENTIDAD | cheque | 🔵 CONVENCIÓN | nombre_sp |
| `cliente` | ENTIDAD | cliente | 🔵 CONVENCIÓN | nombre_sp |

---

## `sp_busca_producto_deb_cheq_cuenta`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_busca_producto_deb_cheq_cuenta.sql` |
| **LOC (1er CREATE)** | 53 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 6 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "busca producto, cheque y cuenta (débito)" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 1 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=4 · INFERIDO=0 · SINTÉTICO=0 / 6 términos |

### Firma

```sql
CREATE PROCEDURE sp_busca_producto_deb_cheq_cuenta(
  p_sNumeroCuenta              CHAR(20)
  p_skip                       INT
) RETURNING CHAR(6) AS numeroProducto,CHAR(60) AS nombreProducto, CHAR(30) AS numeroCuenta, CHAR(30) AS numeroTarjeta, CHAR(3) AS statusTarjeta
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_sNumeroCuenta` | `CHAR(20)` | `cuenta`=cuenta | ✅ CÓDIGO |
| `p_skip` | `INT` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `resultado_numeroProducto` | `CHAR(6)` | L6 |
| `resultado_nombreProducto` | `CHAR(60)` | L7 |
| `resultado_numeroCuenta` | `CHAR(30)` | L8 |
| `resultado_numeroTarjeta` | `CHAR(30)` | L9 |
| `iSqlErr` | `INTEGER` | L10 |
| `cStatusTarjeta` | `CHAR(3)` | L11 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sc_maechq` | `bdicheq` | ⚠️ sí | SELECT | L38 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `busca` | ACCION | busca / localiza | 🔵 CONVENCIÓN | nombre_sp |
| `producto` | ENTIDAD | producto | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `deb` | MODIF | débito | 🔵 CONVENCIÓN | nombre_sp |
| `cheq` | ENTIDAD | cheque | 🔵 CONVENCIÓN | nombre_sp |
| `cuenta` | ENTIDAD | cuenta | ✅ CÓDIGO | nombre_sp, texto_cuerpo |

---

## `sp_busca_producto_deb_cheq_tarjeta`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_busca_producto_deb_cheq_tarjeta.sql` |
| **LOC (1er CREATE)** | 53 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 1 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "busca producto, cheque y tarjeta (débito)" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 1 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=4 · INFERIDO=0 · SINTÉTICO=0 / 6 términos |

### Firma

```sql
CREATE PROCEDURE sp_busca_producto_deb_cheq_tarjeta(
  p_sNumeroTarjeta             CHAR(20)
) RETURNING CHAR(6) AS numeroProducto,CHAR(60) AS nombreProducto, CHAR(30) AS numeroCuenta, CHAR(30) AS numeroTarjeta, CHAR(3) AS statusTarjeta
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_sNumeroTarjeta` | `CHAR(20)` | `tarjeta`=tarjeta | ✅ CÓDIGO |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `resultado_numeroProducto` | `CHAR(6)` | L6 |
| `resultado_nombreProducto` | `CHAR(60)` | L7 |
| `resultado_numeroCuenta` | `CHAR(30)` | L8 |
| `resultado_numeroTarjeta` | `CHAR(30)` | L9 |
| `iSqlErr` | `INTEGER` | L10 |
| `cStatusTarjeta` | `CHAR(3)` | L11 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sc_maechq` | `bdicheq` | ⚠️ sí | SELECT | L38 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `busca` | ACCION | busca / localiza | 🔵 CONVENCIÓN | nombre_sp |
| `producto` | ENTIDAD | producto | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `deb` | MODIF | débito | 🔵 CONVENCIÓN | nombre_sp |
| `cheq` | ENTIDAD | cheque | 🔵 CONVENCIÓN | nombre_sp |
| `tarjeta` | ENTIDAD | tarjeta | ✅ CÓDIGO | nombre_sp, texto_cuerpo |

---

## `sp_busca_producto_transfer_cliente`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_busca_producto_transfer_cliente.sql` |
| **LOC (1er CREATE)** | 66 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 5 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "busca producto, transferencia y cliente" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 1 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=4 · INFERIDO=0 · SINTÉTICO=0 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_busca_producto_transfer_cliente(
  p_sNumeroCliente             CHAR(20)
  p_skip                       INT
) RETURNING CHAR(6) AS numeroProducto,CHAR(60) AS nombreProducto, CHAR(30) AS numeroCuenta, CHAR(30) AS numeroTarjeta, CHAR(30) AS telefonoTransfer, CHAR(30) AS clienteTransfer, CHAR(3) AS statusTarjeta
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_sNumeroCliente` | `CHAR(20)` | `cliente`=cliente | 🔵 CONVENCIÓN |
| `p_skip` | `INT` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `resultado_numeroProducto` | `CHAR(6)` | L6 |
| `resultado_nombreProducto` | `CHAR(60)` | L7 |
| `resultado_numeroCuenta` | `CHAR(30)` | L8 |
| `resultado_numeroTarjeta` | `CHAR(30)` | L9 |
| `resultado_telefonoTransfer` | `CHAR(30)` | L10 |
| `resultado_clienteTransfer` | `CHAR(30)` | L11 |
| `cStatusTarjeta` | `CHAR(3)` | L12 |
| `iSqlErr` | `INTEGER` | L15 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tf_maecte` | `bditransfer` | ⚠️ sí | SELECT | L52 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `busca` | ACCION | busca / localiza | 🔵 CONVENCIÓN | nombre_sp |
| `producto` | ENTIDAD | producto | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `transfer` | ENTIDAD | transferencia (forma larga de 'trans') | 🔵 CONVENCIÓN | nombre_sp |
| `cliente` | ENTIDAD | cliente | 🔵 CONVENCIÓN | nombre_sp |

---

## `sp_busca_producto_transfer_cuenta`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_busca_producto_transfer_cuenta.sql` |
| **LOC (1er CREATE)** | 63 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 4 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "busca producto, transferencia y cuenta" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 1 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=0 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_busca_producto_transfer_cuenta(
  p_sNumeroCuenta              CHAR(20)
  p_skip                       INT
) RETURNING CHAR(6) AS numeroProducto,CHAR(60) AS nombreProducto, CHAR(30) AS numeroCuenta, CHAR(30) AS numeroTarjeta, CHAR(30) AS telefonoTransfer, CHAR(30) AS numClienteTransfer, CHAR(3) AS statusTarjeta
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_sNumeroCuenta` | `CHAR(20)` | `cuenta`=cuenta | ✅ CÓDIGO |
| `p_skip` | `INT` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `resultado_numeroProducto` | `CHAR(6)` | L6 |
| `resultado_nombreProducto` | `CHAR(60)` | L7 |
| `resultado_numeroCuenta` | `CHAR(30)` | L8 |
| `resultado_numeroTarjeta` | `CHAR(30)` | L9 |
| `resultado_telefonoTransfer` | `CHAR(30)` | L10 |
| `resultado_numClienteTransfer` | `CHAR(30)` | L11 |
| `iSqlErr` | `INTEGER` | L12 |
| `cStatusTarjeta` | `CHAR(3)` | L13 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tf_maecte` | `bditransfer` | ⚠️ sí | SELECT | L49 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `busca` | ACCION | busca / localiza | 🔵 CONVENCIÓN | nombre_sp |
| `producto` | ENTIDAD | producto | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `transfer` | ENTIDAD | transferencia (forma larga de 'trans') | 🔵 CONVENCIÓN | nombre_sp |
| `cuenta` | ENTIDAD | cuenta | ✅ CÓDIGO | nombre_sp, texto_cuerpo |

---

## `sp_busca_producto_transfer_tarjeta`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_busca_producto_transfer_tarjeta.sql` |
| **LOC (1er CREATE)** | 64 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 3 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "busca producto, transferencia y tarjeta" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 1 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=0 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_busca_producto_transfer_tarjeta(
  p_sNumeroTarjeta             CHAR(20)
  p_skip                       INT
) RETURNING CHAR(6) AS numeroProducto,CHAR(60) AS nombreProducto, CHAR(30) AS numeroCuenta, CHAR(30) AS numeroTarjeta, CHAR(30) AS telefonoTransfer, CHAR(30) AS numClienteTransfer, CHAR(3) AS statusTarjeta
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_sNumeroTarjeta` | `CHAR(20)` | `tarjeta`=tarjeta | ✅ CÓDIGO |
| `p_skip` | `INT` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `resultado_numeroProducto` | `CHAR(6)` | L6 |
| `resultado_nombreProducto` | `CHAR(60)` | L7 |
| `resultado_numeroCuenta` | `CHAR(30)` | L8 |
| `resultado_numeroTarjeta` | `CHAR(30)` | L9 |
| `resultado_telefonoTransfer` | `CHAR(30)` | L10 |
| `resultado_numClienteTransfer` | `CHAR(30)` | L11 |
| `iSqlErr` | `INTEGER` | L12 |
| `cStatusTarjeta` | `CHAR(3)` | L13 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tf_maecte` | `bditransfer` | ⚠️ sí | SELECT | L49 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `busca` | ACCION | busca / localiza | 🔵 CONVENCIÓN | nombre_sp |
| `producto` | ENTIDAD | producto | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `transfer` | ENTIDAD | transferencia (forma larga de 'trans') | 🔵 CONVENCIÓN | nombre_sp |
| `tarjeta` | ENTIDAD | tarjeta | ✅ CÓDIGO | nombre_sp, texto_cuerpo |

---

## `sp_busca_producto_transfer_telefono`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_busca_producto_transfer_telefono.sql` |
| **LOC (1er CREATE)** | 63 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 2 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "busca producto, transferencia y teléfono" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 1 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=0 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_busca_producto_transfer_telefono(
  p_sTelefonoCliente           CHAR(20)
  p_skip                       INT
) RETURNING CHAR(6) AS numeroProducto,CHAR(60) AS nombreProducto, CHAR(30) AS numeroCuenta, CHAR(30) AS numeroTarjeta, CHAR(30) AS telefonoTransfer, CHAR(30) AS numClienteTransfer, CHAR(3) AS statusTarjeta
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_sTelefonoCliente` | `CHAR(20)` | `telefono`=teléfono | ✅ CÓDIGO |
| `p_skip` | `INT` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `resultado_numeroProducto` | `CHAR(6)` | L6 |
| `resultado_nombreProducto` | `CHAR(60)` | L7 |
| `resultado_numeroCuenta` | `CHAR(30)` | L8 |
| `resultado_numeroTarjeta` | `CHAR(30)` | L9 |
| `resultado_telefonoTransfer` | `CHAR(30)` | L10 |
| `resultado_numclienteTransfer` | `CHAR(30)` | L11 |
| `iSqlErr` | `INTEGER` | L12 |
| `cStatusTarjeta` | `CHAR(3)` | L13 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tf_maecte` | `bditransfer` | ⚠️ sí | SELECT | L49 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `busca` | ACCION | busca / localiza | 🔵 CONVENCIÓN | nombre_sp |
| `producto` | ENTIDAD | producto | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `transfer` | ENTIDAD | transferencia (forma larga de 'trans') | 🔵 CONVENCIÓN | nombre_sp |
| `telefono` | ENTIDAD | teléfono | ✅ CÓDIGO | nombre_sp, texto_cuerpo |

---

## `sp_busca_productos_catalogo`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_busca_productos_catalogo.sql` |
| **LOC (1er CREATE)** | 142 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "busca productos y catálogo" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 4 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=4 · INFERIDO=0 · SINTÉTICO=0 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_busca_productos_catalogo(
  pNombreProducto              CHAR(100)
  pNumeroProducto              CHAR(6)
  pTipoProducto                CHAR(1)
  pTipoConsulta                CHAR(6)
  p_skip                       INT
) RETURNING CHAR(6) AS resultado_numeroProducto,CHAR(100) AS resultado_nombreProducto, CHAR(1) AS resultado_tipoProducto
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pNombreProducto` | `CHAR(100)` | — | — |
| `pNumeroProducto` | `CHAR(6)` | — | — |
| `pTipoProducto` | `CHAR(1)` | — | — |
| `pTipoConsulta` | `CHAR(6)` | — | — |
| `p_skip` | `INT` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `resultado_nombreProducto` | `CHAR(100)` | L6 |
| `resultado_numeroProducto` | `CHAR (6)` | L7 |
| `resultado_tipoProducto` | `CHAR (1)` | L8 |
| `iSqlErr` | `INTEGER` | L9 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sc_producto` | `bdicheq` | ⚠️ sí | SELECT | L32 |
| `acl_tipo_producto` | `bdiaclaracion` | no | SELECT | L34 |
| `sv_instrum` | `bdinvers` | ⚠️ sí | SELECT | L37 |
| `sd_definicion` | `bdicred` | ⚠️ sí | SELECT | L49 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `busca` | ACCION | busca / localiza | 🔵 CONVENCIÓN | nombre_sp |
| `productos` | ENTIDAD | productos | 🔵 CONVENCIÓN | nombre_sp |
| `catalogo` | ENTIDAD | catálogo | 🔵 CONVENCIÓN | nombre_sp |

---

## `sp_buscaempleadohuella`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_buscaempleadohuella.sql` |
| **LOC (1er CREATE)** | 128 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 3 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "busca empleado y huella biométrica" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 2 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=0 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_buscaempleadohuella(
  p_sNumeroEmpleado            CHAR(8)
  p_sNumeroEmpresa             CHAR(3)
) RETURNING CHAR(45) AS nombreEmpleado,  CHAR(3) AS puesto, CHAR(4) AS sucursal, CHAR(40) AS nombreSucursal, CHAR(30) AS nombreEstado, CHAR(60) AS nombreCiudad, CHAR(20) AS nombramiento
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_sNumeroEmpleado` | `CHAR(8)` | `empleado`=empleado | 🔵 CONVENCIÓN |
| `p_sNumeroEmpresa` | `CHAR(3)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `resultado_nombreEmpleado` | `CHAR(45)` | L6 |
| `resultado_puesto` | `CHAR(3)` | L7 |
| `resultado_sucursal` | `CHAR(5)` | L8 |
| `resultado_nombreSucursal` | `CHAR(40)` | L9 |
| `resultado_nombreEstado` | `CHAR(30)` | L10 |
| `resultado_nombreCiudad` | `CHAR(60)` | L11 |
| `resultado_nombramiento` | `CHAR(20)` | L12 |
| `iSqlErr` | `INTEGER` | L13 |
| `v_activo` | `SMALLINT` | L15 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `acl_usuario` | `bdiaclaracion` | no | SELECT | L60 |
| `si_ejecut` | `bdinteg` | ⚠️ sí | SELECT | L69 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L78 | VALIDACIÓN_NULL | `IF (resultado_nombreEmpleado is null or resultado_nombreEmpleado = '') THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `busca` | ACCION | busca / localiza | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `empleado` | ENTIDAD | empleado | 🔵 CONVENCIÓN | nombre_sp |
| `huella` | ENTIDAD | huella biométrica | 🔵 CONVENCIÓN | nombre_sp |

---

## `sp_buscaempleadohuella_alta`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_buscaempleadohuella_alta.sql` |
| **LOC (1er CREATE)** | 94 |
| **Callgraph** | ✅ fan_in=0 / fan_out=2 |
| **Deps concatenadas** | 14 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "busca empleado y huella biométrica" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 1 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=4 · INFERIDO=0 · SINTÉTICO=0 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_buscaempleadohuella_alta(
  p_sNumeroEmpleado            CHAR(8)
  p_sNumeroEmpresa             CHAR(3)
) RETURNING CHAR(45) AS nombreEmpleado,  CHAR(3) AS puesto, CHAR(4) AS sucursal, CHAR(40) AS nombreSucursal, CHAR(30) AS nombreEstado, CHAR(60) AS nombreCiudad, CHAR(20) AS nombramiento
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_sNumeroEmpleado` | `CHAR(8)` | `empleado`=empleado | 🔵 CONVENCIÓN |
| `p_sNumeroEmpresa` | `CHAR(3)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `resultado_nombreEmpleado` | `CHAR(45)` | L6 |
| `resultado_puesto` | `CHAR(3)` | L7 |
| `resultado_sucursal` | `CHAR(4)` | L8 |
| `resultado_nombreSucursal` | `CHAR(40)` | L9 |
| `resultado_nombreEstado` | `CHAR(30)` | L10 |
| `resultado_nombreCiudad` | `CHAR(60)` | L11 |
| `resultado_nombramiento` | `CHAR(20)` | L12 |
| `iSqlErr` | `INTEGER` | L13 |
| `v_activo` | `SMALLINT` | L15 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_ejecut` | `bdinteg` | ⚠️ sí | SELECT | L54 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L63 | VALIDACIÓN_NULL | `IF (resultado_nombreEmpleado is null or resultado_nombreEmpleado = '') THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `busca` | ACCION | busca / localiza | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `empleado` | ENTIDAD | empleado | 🔵 CONVENCIÓN | nombre_sp |
| `huella` | ENTIDAD | huella biométrica | 🔵 CONVENCIÓN | nombre_sp |
| `alta` | ACCION | da de alta / registra | 🔵 CONVENCIÓN | nombre_sp |

---

## `sp_buscaqueda_folio_csuac`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_buscaqueda_folio_csuac.sql` |
| **LOC (1er CREATE)** | 293 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 7 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "busca folio" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 2 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=2 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_buscaqueda_folio_csuac(
  opcion                       INTEGER
  pFolioCSUAC                  CHAR(11)
  pNumCliente                  CHAR(20)
  pRegistros                   INTEGER
  pRecuperacion                INTEGER
) RETURNING CHAR(5) AS codret,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `opcion` | `INTEGER` | — | — |
| `pFolioCSUAC` | `CHAR(11)` | `folio`=folio | 🔵 CONVENCIÓN |
| `pNumCliente` | `CHAR(20)` | — | — |
| `pRegistros` | `INTEGER` | — | — |
| `pRecuperacion` | `INTEGER` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(5)` | L31 |
| `iSqlErr` | `INTEGER` | L32 |
| `cCodRetSp` | `CHAR(5)` | L33 |
| `iCodRetSp` | `INTEGER` | L34 |
| `dFechaCaptura` | `DATE` | L36 |
| `cFolioCsuac` | `CHAR(11)` | L37 |
| `iFkyReglaNegocio` | `INTEGER` | L38 |
| `cPredictamen` | `CHAR(625)` | L39 |
| `mImporteReclamado` | `money(16,2)` | L40 |
| `cNombre1` | `CHAR(26)` | L42 |
| `cNombre2` | `CHAR(26)` | L43 |
| `cApellPaterno` | `CHAR(26)` | L44 |
| `cApellMaterno` | `CHAR(26)` | L45 |
| `iPkyProducto` | `INTEGER` | L47 |
| `cDescripcionProducto` | `CHAR(255)` | L48 |
| `cNumeroCuenta` | `CHAR(20)` | L49 |
| `cNumeroTarjeta` | `CHAR(16)` | L50 |
| `iFkyOrigenEvento` | `INTEGER` | L52 |
| `cDescripcionEvento` | `CHAR(50)` | L53 |
| `iPkyEstatusAclaracion` | `INTEGER` | L55 |
| `cDescripcionEstatus` | `CHAR(255)` | L56 |
| `cNumCliente` | `CHAR(20)` | L57 |
| `cNumSucursal` | `CHAR(5)` | L59 |
| `iPkyRangoImporte` | `INTEGER` | L60 |
| `iPkyOrigenEvent` | `INTEGER` | L61 |
| *…10 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `acl_rango_importe` | `bdiaclaracion` | no | SELECT | L138 |
| `acl_aclaracion` | `bdiaclaracion` | no | SELECT | L167 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L75 | CÓDIGO_RETORNO | `LET cCodRet = '00000';` |  |
| L129 | VALIDACIÓN_NULL | `IF opcion = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN` |  |
| L130 | CÓDIGO_RETORNO | `LET cCodRet = '00003';` |  |
| L178 | CÓDIGO_RETORNO | `LET cCodRet = '00017';` |  |
| L225 | FÓRMULA | `LET iNoRegistros = iNoRegistros + 1;` |  |
| L267 | CÓDIGO_RETORNO | `LET cCodRet = '00017';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `busca` | ACCION | busca / localiza | 🔵 CONVENCIÓN | nombre_sp |
| `?queda_` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `folio` | ENTIDAD | folio | 🔵 CONVENCIÓN | nombre_sp |
| `?_csuac` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?queda_`, `?_csuac` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_buscar_movimientos_cheques_dia_canales`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_buscar_movimientos_cheques_dia_canales.sql` |
| **LOC (1er CREATE)** | 330 |
| **Callgraph** | ✅ fan_in=0 / fan_out=4 |
| **Deps concatenadas** | 12 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "búsqueda/buscar movimientos, cheques y canales (del día)" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 1 llamada(s): `sp_obten_origen_automatico` |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=5 · INFERIDO=0 · SINTÉTICO=0 / 6 términos |

### Firma

```sql
CREATE PROCEDURE sp_buscar_movimientos_cheques_dia_canales(
  pNumeroCuenta                CHAR(30)
  pFechaInicial                DATE
  pFechaFinal                  DATE
  pTipoFlujo                   INTEGER
  pMonto                       MONEY(16,2)
  pEsMontoCerrado              CHAR(3)
) RETURNING CHAR(5)								AS cod_ret,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pNumeroCuenta` | `CHAR(30)` | — | — |
| `pFechaInicial` | `DATE` | — | — |
| `pFechaFinal` | `DATE` | — | — |
| `pTipoFlujo` | `INTEGER` | — | — |
| `pMonto` | `MONEY(16,2)` | — | — |
| `pEsMontoCerrado` | `CHAR(3)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cod_ret` | `CHAR(5)` | L37 |
| `cod_ret_origen` | `CHAR(5)` | L38 |
| `iSqlErr` | `INTEGER` | L39 |
| `v_fechaMovimiento` | `DATE` | L40 |
| `v_monto` | `money(16,2)` | L41 |
| `v_monto_inicial` | `money(16,2)` | L42 |
| `v_monto_final` | `money(16,2)` | L43 |
| `monto_cashback` | `money(16,2)` | L44 |
| `v_horaMovimiento` | `DATETIME HOUR TO FRACTION(3)` | L45 |
| `v_foliosuc` | `CHAR(30)` | L46 |
| `segundaLetraFolioSuc` | `CHAR(1)` | L48 |
| `v_numSucursal` | `CHAR(4)` | L49 |
| `v_nombreSucursal` | `CHAR(30)` | L50 |
| `v_claveTipo` | `CHAR(5)` | L51 |
| `v_transacc_suc` | `CHAR(5)` | L52 |
| `v_tipo` | `CHAR(40)` | L53 |
| `v_referencia23` | `CHAR(30)` | L54 |
| `reversado` | `CHAR(1)` | L55 |
| `v_refComercio` | `CHAR(40)` | L56 |
| `res_v_fechaMovimiento_ret` | `DATE` | L57 |
| `res_v_horaMovimiento_ret` | `DATETIME HOUR TO FRACTION(3)` | L58 |
| `v_NumTarjeta` | `CHAR(16)` | L59 |
| `res_v_fechaMovimiento_re1` | `DATE` | L60 |
| `res_v_horaMovimiento_re1` | `DATETIME HOUR TO FRACTION(3)` | L61 |
| `v_origen_evento` | `INTEGER` | L62 |
| *…14 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sc_movdia` | `bdicheq` | ⚠️ sí | SELECT | L171 |
| `sc_movhis_old` | `bdicheq` | ⚠️ sí | SELECT | L212 |
| `acl_asociacion_origen_evento_canal` | `bdiaclaracion` | no | SELECT | L271 |
| `acl_tipo_movimiento` | `bdiaclaracion` | no | SELECT | L276 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_obten_origen_automatico` | `bdiaclaracion` | no | L257 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L146 | VALIDACIÓN_NULL | `IF pMonto IS NULL OR pMonto = 0 THEN` |  |
| L151 | VALIDACIÓN_NULL | `IF pEsMontoCerrado IS NULL OR pEsMontoCerrado = 1 THEN` |  |
| L158 | FÓRMULA | `LET v_monto_final = TRUNC(pMonto) + 0.99;` | 🔴 MONEY/aritmética financiera |
| L198 | VALIDACIÓN_NULL | `IF monto_cashback IS NULL THEN` |  |
| L202 | FÓRMULA | `LET v_monto = v_monto + monto_cashback;` | 🔴 MONEY/aritmética financiera |
| L219 | VALIDACIÓN_NULL | `IF (res_v_fechaMovimiento_ret IS NULL  OR res_v_fechaMovimiento_ret = '') THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `buscar` | ACCION | búsqueda/buscar | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `movimientos` | ENTIDAD | movimientos | 🔵 CONVENCIÓN | nombre_sp |
| `cheques` | ENTIDAD | cheques | 🔵 CONVENCIÓN | nombre_sp |
| `dia` | MODIF | del día | 🔵 CONVENCIÓN | nombre_sp |
| `canales` | ENTIDAD | canales (de distribución) | 🔵 CONVENCIÓN | nombre_sp |

---

## `sp_buscar_movimientos_cheques_his_canales`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_buscar_movimientos_cheques_his_canales.sql` |
| **LOC (1er CREATE)** | 330 |
| **Callgraph** | ✅ fan_in=0 / fan_out=4 |
| **Deps concatenadas** | 11 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "búsqueda/buscar movimientos, cheques y canales (histórico)" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 1 llamada(s): `sp_obten_origen_automatico` |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=4 · INFERIDO=1 · SINTÉTICO=0 / 6 términos |

### Firma

```sql
CREATE PROCEDURE sp_buscar_movimientos_cheques_his_canales(
  pNumeroCuenta                CHAR(30)
  pFechaInicial                DATE
  pFechaFinal                  DATE
  pTipoFlujo                   INTEGER
  pMonto                       MONEY(16,2)
  pEsMontoCerrado              CHAR(3)
) RETURNING CHAR(5)								AS cod_ret,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pNumeroCuenta` | `CHAR(30)` | — | — |
| `pFechaInicial` | `DATE` | — | — |
| `pFechaFinal` | `DATE` | — | — |
| `pTipoFlujo` | `INTEGER` | — | — |
| `pMonto` | `MONEY(16,2)` | — | — |
| `pEsMontoCerrado` | `CHAR(3)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cod_ret` | `CHAR(5)` | L37 |
| `cod_ret_origen` | `CHAR(5)` | L38 |
| `iSqlErr` | `INTEGER` | L39 |
| `v_fechaMovimiento` | `DATE` | L40 |
| `v_monto` | `money(16,2)` | L41 |
| `v_monto_inicial` | `money(16,2)` | L42 |
| `v_monto_final` | `money(16,2)` | L43 |
| `monto_cashback` | `money(16,2)` | L44 |
| `v_horaMovimiento` | `DATETIME HOUR TO FRACTION(3)` | L45 |
| `v_foliosuc` | `CHAR(30)` | L46 |
| `segundaLetraFolioSuc` | `CHAR(1)` | L48 |
| `v_numSucursal` | `CHAR(4)` | L49 |
| `v_nombreSucursal` | `CHAR(30)` | L50 |
| `v_claveTipo` | `CHAR(5)` | L51 |
| `v_transacc_suc` | `CHAR(5)` | L52 |
| `v_tipo` | `CHAR(40)` | L53 |
| `v_referencia23` | `CHAR(30)` | L54 |
| `reversado` | `CHAR(1)` | L55 |
| `v_refComercio` | `CHAR(40)` | L56 |
| `res_v_fechaMovimiento_ret` | `DATE` | L57 |
| `res_v_horaMovimiento_ret` | `DATETIME HOUR TO FRACTION(3)` | L58 |
| `v_NumTarjeta` | `CHAR(16)` | L59 |
| `res_v_fechaMovimiento_re1` | `DATE` | L60 |
| `res_v_horaMovimiento_re1` | `DATETIME HOUR TO FRACTION(3)` | L61 |
| `v_origen_evento` | `INTEGER` | L62 |
| *…14 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sc_movhis` | `bdicheq` | ⚠️ sí | SELECT | L171 |
| `sc_movhis_old` | `bdicheq` | ⚠️ sí | SELECT | L212 |
| `acl_asociacion_origen_evento_canal` | `bdiaclaracion` | no | SELECT | L271 |
| `acl_tipo_movimiento` | `bdiaclaracion` | no | SELECT | L276 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_obten_origen_automatico` | `bdiaclaracion` | no | L257 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L146 | VALIDACIÓN_NULL | `IF pMonto IS NULL OR pMonto = 0 THEN` |  |
| L151 | VALIDACIÓN_NULL | `IF pEsMontoCerrado IS NULL OR pEsMontoCerrado = 1 THEN` |  |
| L158 | FÓRMULA | `LET v_monto_final = TRUNC(pMonto) + 0.99;` | 🔴 MONEY/aritmética financiera |
| L198 | VALIDACIÓN_NULL | `IF monto_cashback IS NULL THEN` |  |
| L202 | FÓRMULA | `LET v_monto = v_monto + monto_cashback;` | 🔴 MONEY/aritmética financiera |
| L219 | VALIDACIÓN_NULL | `IF (res_v_fechaMovimiento_ret IS NULL  OR res_v_fechaMovimiento_ret = '') THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `buscar` | ACCION | búsqueda/buscar | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `movimientos` | ENTIDAD | movimientos | 🔵 CONVENCIÓN | nombre_sp |
| `cheques` | ENTIDAD | cheques | 🔵 CONVENCIÓN | nombre_sp |
| `his` | MODIF | histórico | 🟡 INFERIDO | nombre_sp |
| `canales` | ENTIDAD | canales (de distribución) | 🔵 CONVENCIÓN | nombre_sp |

---

## `sp_buscar_movimientos_cheques_his_old_canales`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_buscar_movimientos_cheques_his_old_canales.sql` |
| **LOC (1er CREATE)** | 330 |
| **Callgraph** | ✅ fan_in=0 / fan_out=4 |
| **Deps concatenadas** | 10 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "búsqueda/buscar movimientos, cheques y canales (histórico)" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 1 llamada(s): `sp_obten_origen_automatico` |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=4 · INFERIDO=1 · SINTÉTICO=1 / 7 términos |

### Firma

```sql
CREATE PROCEDURE sp_buscar_movimientos_cheques_his_old_canales(
  pNumeroCuenta                CHAR(30)
  pFechaInicial                DATE
  pFechaFinal                  DATE
  pTipoFlujo                   INTEGER
  pMonto                       MONEY(16,2)
  pEsMontoCerrado              CHAR(3)
) RETURNING CHAR(5)								AS cod_ret,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pNumeroCuenta` | `CHAR(30)` | — | — |
| `pFechaInicial` | `DATE` | — | — |
| `pFechaFinal` | `DATE` | — | — |
| `pTipoFlujo` | `INTEGER` | — | — |
| `pMonto` | `MONEY(16,2)` | — | — |
| `pEsMontoCerrado` | `CHAR(3)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cod_ret` | `CHAR(5)` | L37 |
| `cod_ret_origen` | `CHAR(5)` | L38 |
| `iSqlErr` | `INTEGER` | L39 |
| `v_fechaMovimiento` | `DATE` | L40 |
| `v_monto` | `money(16,2)` | L41 |
| `v_monto_inicial` | `money(16,2)` | L42 |
| `v_monto_final` | `money(16,2)` | L43 |
| `monto_cashback` | `money(16,2)` | L44 |
| `v_horaMovimiento` | `DATETIME HOUR TO FRACTION(3)` | L45 |
| `v_foliosuc` | `CHAR(30)` | L46 |
| `segundaLetraFolioSuc` | `CHAR(1)` | L48 |
| `v_numSucursal` | `CHAR(4)` | L49 |
| `v_nombreSucursal` | `CHAR(30)` | L50 |
| `v_claveTipo` | `CHAR(5)` | L51 |
| `v_transacc_suc` | `CHAR(5)` | L52 |
| `v_tipo` | `CHAR(40)` | L53 |
| `v_referencia23` | `CHAR(30)` | L54 |
| `reversado` | `CHAR(1)` | L55 |
| `v_refComercio` | `CHAR(40)` | L56 |
| `res_v_fechaMovimiento_ret` | `DATE` | L57 |
| `res_v_horaMovimiento_ret` | `DATETIME HOUR TO FRACTION(3)` | L58 |
| `v_NumTarjeta` | `CHAR(16)` | L59 |
| `res_v_fechaMovimiento_re1` | `DATE` | L60 |
| `res_v_horaMovimiento_re1` | `DATETIME HOUR TO FRACTION(3)` | L61 |
| `v_origen_evento` | `INTEGER` | L62 |
| *…14 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sc_movhis_old` | `bdicheq` | ⚠️ sí | SELECT | L171 |
| `acl_asociacion_origen_evento_canal` | `bdiaclaracion` | no | SELECT | L271 |
| `acl_tipo_movimiento` | `bdiaclaracion` | no | SELECT | L276 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_obten_origen_automatico` | `bdiaclaracion` | no | L257 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L146 | VALIDACIÓN_NULL | `IF pMonto IS NULL OR pMonto = 0 THEN` |  |
| L151 | VALIDACIÓN_NULL | `IF pEsMontoCerrado IS NULL OR pEsMontoCerrado = 1 THEN` |  |
| L158 | FÓRMULA | `LET v_monto_final = TRUNC(pMonto) + 0.99;` | 🔴 MONEY/aritmética financiera |
| L198 | VALIDACIÓN_NULL | `IF monto_cashback IS NULL THEN` |  |
| L202 | FÓRMULA | `LET v_monto = v_monto + monto_cashback;` | 🔴 MONEY/aritmética financiera |
| L219 | VALIDACIÓN_NULL | `IF (res_v_fechaMovimiento_ret IS NULL  OR res_v_fechaMovimiento_ret = '') THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `buscar` | ACCION | búsqueda/buscar | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `movimientos` | ENTIDAD | movimientos | 🔵 CONVENCIÓN | nombre_sp |
| `cheques` | ENTIDAD | cheques | 🔵 CONVENCIÓN | nombre_sp |
| `his` | MODIF | histórico | 🟡 INFERIDO | nombre_sp |
| `?_old_` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `canales` | ENTIDAD | canales (de distribución) | 🔵 CONVENCIÓN | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_old_` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_buscar_movimientos_credito_dia_canales`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_buscar_movimientos_credito_dia_canales.sql` |
| **LOC (1er CREATE)** | 338 |
| **Callgraph** | ✅ fan_in=0 / fan_out=4 |
| **Deps concatenadas** | 13 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "búsqueda/buscar movimientos, crédito y canales (del día)" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 1 llamada(s): `sp_obten_origen_automatico` |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=5 · INFERIDO=0 · SINTÉTICO=0 / 6 términos |

### Firma

```sql
CREATE PROCEDURE sp_buscar_movimientos_credito_dia_canales(
  pNumeroCuenta                CHAR(30)
  pFechaInicial                DATE
  pFechaFinal                  DATE
  pTipoFlujo                   INTEGER
  pMonto                       MONEY(16,2)
  pEsMontoCerrado              CHAR(3)
) RETURNING CHAR(5)								AS cod_ret,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pNumeroCuenta` | `CHAR(30)` | — | — |
| `pFechaInicial` | `DATE` | — | — |
| `pFechaFinal` | `DATE` | — | — |
| `pTipoFlujo` | `INTEGER` | — | — |
| `pMonto` | `MONEY(16,2)` | — | — |
| `pEsMontoCerrado` | `CHAR(3)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cod_ret` | `CHAR(5)` | L37 |
| `cod_ret_origen` | `CHAR(5)` | L38 |
| `iSqlErr` | `INTEGER` | L39 |
| `v_fechaMovimiento` | `DATE` | L40 |
| `v_monto` | `money(16,2)` | L41 |
| `v_monto_inicial` | `money(16,2)` | L42 |
| `v_monto_final` | `money(16,2)` | L43 |
| `saldo_favor` | `money(16,2)` | L44 |
| `v_horaMovimiento` | `DATETIME HOUR TO FRACTION(3)` | L45 |
| `v_foliosuc` | `CHAR(30)` | L46 |
| `v_numSucursal` | `CHAR(4)` | L47 |
| `v_nombreSucursal` | `CHAR(30)` | L48 |
| `v_claveTipo` | `CHAR(5)` | L49 |
| `v_tipo` | `CHAR(40)` | L50 |
| `v_referencia23` | `CHAR(30)` | L51 |
| `reversado` | `CHAR(1)` | L52 |
| `v_refComercio` | `CHAR(40)` | L53 |
| `res_v_fechaMovimiento_ret` | `DATE` | L54 |
| `res_v_horaMovimiento_ret` | `DATETIME HOUR TO FRACTION(3)` | L55 |
| `v_NumTarjeta` | `CHAR(16)` | L56 |
| `res_v_fechaMovimiento_re1` | `DATE` | L57 |
| `res_v_horaMovimiento_re1` | `DATETIME HOUR TO FRACTION(3)` | L58 |
| `v_origen_evento` | `INTEGER` | L59 |
| `v_desc_origen_evento` | `CHAR(50)` | L60 |
| `v_secuenciaMovimiento` | `INTEGER` | L61 |
| *…13 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sd_movdia` | `bdicred` | ⚠️ sí | SELECT | L165 |
| `sd_movhis` | `bdicred` | ⚠️ sí | SELECT | L207 |
| `acl_asociacion_origen_evento_canal` | `bdiaclaracion` | no | SELECT | L281 |
| `acl_tipo_movimiento` | `bdiaclaracion` | no | SELECT | L286 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_obten_origen_automatico` | `bdiaclaracion` | no | L262 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L142 | VALIDACIÓN_NULL | `IF pMonto IS NULL OR pMonto = 0 THEN` |  |
| L147 | VALIDACIÓN_NULL | `IF pEsMontoCerrado IS NULL OR pEsMontoCerrado = 1 THEN` |  |
| L154 | FÓRMULA | `LET v_monto_final = TRUNC(pMonto) + 0.99;` | 🔴 MONEY/aritmética financiera |
| L193 | VALIDACIÓN_NULL | `IF (saldo_favor IS NULL) THEN` |  |
| L197 | FÓRMULA | `let v_monto = v_monto + saldo_favor;` | 🔴 MONEY/aritmética financiera |
| L215 | VALIDACIÓN_NULL | `IF (res_v_fechaMovimiento_ret is null  OR res_v_fechaMovimiento_ret='') THEN` |  |
| L244 | VALIDACIÓN_NULL | `IF v_movimiento_valido IS NULL THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `buscar` | ACCION | búsqueda/buscar | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `movimientos` | ENTIDAD | movimientos | 🔵 CONVENCIÓN | nombre_sp |
| `credito` | ENTIDAD | crédito | 🔵 CONVENCIÓN | nombre_sp |
| `dia` | MODIF | del día | 🔵 CONVENCIÓN | nombre_sp |
| `canales` | ENTIDAD | canales (de distribución) | 🔵 CONVENCIÓN | nombre_sp |

---

## `sp_buscar_movimientos_credito_his_canales`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_buscar_movimientos_credito_his_canales.sql` |
| **LOC (1er CREATE)** | 325 |
| **Callgraph** | ✅ fan_in=0 / fan_out=4 |
| **Deps concatenadas** | 14 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "búsqueda/buscar movimientos, crédito y canales (histórico)" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 1 llamada(s): `sp_obten_origen_automatico` |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=4 · INFERIDO=1 · SINTÉTICO=0 / 6 términos |

### Firma

```sql
CREATE PROCEDURE sp_buscar_movimientos_credito_his_canales(
  pNumeroCuenta                CHAR(30)
  pFechaInicial                DATE
  pFechaFinal                  DATE
  pTipoFlujo                   INTEGER
  pMonto                       MONEY(16,2)
  pEsMontoCerrado              CHAR(3)
) RETURNING CHAR(5)								AS cod_ret,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pNumeroCuenta` | `CHAR(30)` | — | — |
| `pFechaInicial` | `DATE` | — | — |
| `pFechaFinal` | `DATE` | — | — |
| `pTipoFlujo` | `INTEGER` | — | — |
| `pMonto` | `MONEY(16,2)` | — | — |
| `pEsMontoCerrado` | `CHAR(3)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cod_ret` | `CHAR(5)` | L37 |
| `cod_ret_origen` | `CHAR(5)` | L38 |
| `iSqlErr` | `INTEGER` | L39 |
| `v_fechaMovimiento` | `DATE` | L40 |
| `v_monto` | `money(16,2)` | L41 |
| `v_monto_inicial` | `money(16,2)` | L42 |
| `v_monto_final` | `money(16,2)` | L43 |
| `saldo_favor` | `money(16,2)` | L44 |
| `v_horaMovimiento` | `DATETIME HOUR TO FRACTION(3)` | L45 |
| `v_foliosuc` | `CHAR(30)` | L46 |
| `v_numSucursal` | `CHAR(4)` | L47 |
| `v_nombreSucursal` | `CHAR(30)` | L48 |
| `v_claveTipo` | `CHAR(5)` | L49 |
| `v_tipo` | `CHAR(40)` | L50 |
| `v_referencia23` | `CHAR(30)` | L51 |
| `reversado` | `CHAR(1)` | L52 |
| `v_refComercio` | `CHAR(40)` | L53 |
| `res_v_fechaMovimiento_ret` | `DATE` | L54 |
| `res_v_horaMovimiento_ret` | `DATETIME HOUR TO FRACTION(3)` | L55 |
| `v_NumTarjeta` | `CHAR(16)` | L56 |
| `res_v_fechaMovimiento_re1` | `DATE` | L57 |
| `res_v_horaMovimiento_re1` | `DATETIME HOUR TO FRACTION(3)` | L58 |
| `v_origen_evento` | `INTEGER` | L59 |
| `v_desc_origen_evento` | `CHAR(50)` | L60 |
| `v_secuenciaMovimiento` | `INTEGER` | L61 |
| *…13 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sd_movhis` | `bdicred` | ⚠️ sí | SELECT | L166 |
| `acl_asociacion_origen_evento_canal` | `bdiaclaracion` | no | SELECT | L272 |
| `acl_tipo_movimiento` | `bdiaclaracion` | no | SELECT | L277 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_obten_origen_automatico` | `bdiaclaracion` | no | L253 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L142 | VALIDACIÓN_NULL | `IF pMonto IS NULL OR pMonto = 0 THEN` |  |
| L147 | VALIDACIÓN_NULL | `IF pEsMontoCerrado IS NULL OR pEsMontoCerrado = 1 THEN` |  |
| L154 | FÓRMULA | `LET v_monto_final = TRUNC(pMonto) + 0.99;` | 🔴 MONEY/aritmética financiera |
| L192 | VALIDACIÓN_NULL | `IF (saldo_favor IS NULL) THEN` |  |
| L196 | FÓRMULA | `let v_monto = v_monto + saldo_favor;` | 🔴 MONEY/aritmética financiera |
| L215 | VALIDACIÓN_NULL | `IF (res_v_fechaMovimiento_ret is null  OR res_v_fechaMovimiento_ret='') THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `buscar` | ACCION | búsqueda/buscar | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `movimientos` | ENTIDAD | movimientos | 🔵 CONVENCIÓN | nombre_sp |
| `credito` | ENTIDAD | crédito | 🔵 CONVENCIÓN | nombre_sp |
| `his` | MODIF | histórico | 🟡 INFERIDO | nombre_sp |
| `canales` | ENTIDAD | canales (de distribución) | 🔵 CONVENCIÓN | nombre_sp |

---

## `sp_buscar_movimientos_inversion_dia_canales`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_buscar_movimientos_inversion_dia_canales.sql` |
| **LOC (1er CREATE)** | 312 |
| **Callgraph** | ✅ fan_in=0 / fan_out=4 |
| **Deps concatenadas** | 8 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "búsqueda/buscar movimientos, inversión y canales (del día)" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 1 llamada(s): `sp_obten_origen_automatico` |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=5 · INFERIDO=0 · SINTÉTICO=0 / 6 términos |

### Firma

```sql
CREATE PROCEDURE sp_buscar_movimientos_inversion_dia_canales(
  pNumeroCuenta                CHAR(30)
  pFechaInicial                DATE
  pFechaFinal                  DATE
  pTipoFlujo                   INTEGER
  pMonto                       MONEY(16,2)
  pEsMontoCerrado              CHAR(3)
) RETURNING CHAR(5)								AS cod_ret,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pNumeroCuenta` | `CHAR(30)` | — | — |
| `pFechaInicial` | `DATE` | — | — |
| `pFechaFinal` | `DATE` | — | — |
| `pTipoFlujo` | `INTEGER` | — | — |
| `pMonto` | `MONEY(16,2)` | — | — |
| `pEsMontoCerrado` | `CHAR(3)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cod_ret` | `CHAR(5)` | L37 |
| `cod_ret_origen` | `CHAR(5)` | L38 |
| `iSqlErr` | `INTEGER` | L39 |
| `v_fechaMovimiento` | `DATE` | L40 |
| `v_monto` | `money(16,2)` | L41 |
| `v_monto_inicial` | `money(16,2)` | L42 |
| `v_monto_final` | `money(16,2)` | L43 |
| `monto_cashback` | `money(16,2)` | L44 |
| `v_horaMovimiento` | `DATETIME HOUR TO FRACTION(3)` | L45 |
| `v_foliosuc` | `CHAR(30)` | L46 |
| `segundaLetraFolioSuc` | `CHAR(1)` | L48 |
| `v_numSucursal` | `CHAR(4)` | L49 |
| `v_nombreSucursal` | `CHAR(30)` | L50 |
| `v_claveTipo` | `CHAR(5)` | L51 |
| `v_transacc_suc` | `CHAR(5)` | L52 |
| `v_tipo` | `CHAR(40)` | L53 |
| `v_referencia23` | `CHAR(30)` | L54 |
| `reversado` | `CHAR(1)` | L55 |
| `v_refComercio` | `CHAR(40)` | L56 |
| `res_v_fechaMovimiento_ret` | `DATE` | L57 |
| `res_v_horaMovimiento_ret` | `DATETIME HOUR TO FRACTION(3)` | L58 |
| `v_NumTarjeta` | `CHAR(16)` | L59 |
| `res_v_fechaMovimiento_re1` | `DATE` | L60 |
| `res_v_horaMovimiento_re1` | `DATETIME HOUR TO FRACTION(3)` | L61 |
| `v_origen_evento` | `INTEGER` | L62 |
| *…14 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sv_movdia` | `bdinvers` | ⚠️ sí | SELECT | L171 |
| `sv_movhis` | `bdinvers` | ⚠️ sí | SELECT | L229 |
| `acl_asociacion_origen_evento_canal` | `bdiaclaracion` | no | SELECT | L256 |
| `acl_tipo_movimiento` | `bdiaclaracion` | no | SELECT | L261 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_obten_origen_automatico` | `bdiaclaracion` | no | L242 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L146 | VALIDACIÓN_NULL | `IF pMonto IS NULL OR pMonto = 0 THEN` |  |
| L151 | VALIDACIÓN_NULL | `IF pEsMontoCerrado IS NULL OR pEsMontoCerrado = 1 THEN` |  |
| L158 | FÓRMULA | `LET v_monto_final = TRUNC(pMonto) + 0.99;` | 🔴 MONEY/aritmética financiera |
| L197 | VALIDACIÓN_NULL | `IF (res_v_fechaMovimiento_ret IS NULL  OR res_v_fechaMovimiento_ret = '') THEN` |  |
| L226 | VALIDACIÓN_NULL | `IF v_movimiento_valido IS NULL THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `buscar` | ACCION | búsqueda/buscar | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `movimientos` | ENTIDAD | movimientos | 🔵 CONVENCIÓN | nombre_sp |
| `inversion` | ENTIDAD | inversión (pagaré / plazo) | 🔵 CONVENCIÓN | nombre_sp |
| `dia` | MODIF | del día | 🔵 CONVENCIÓN | nombre_sp |
| `canales` | ENTIDAD | canales (de distribución) | 🔵 CONVENCIÓN | nombre_sp |

---

## `sp_buscar_movimientos_inversion_his_canales`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_buscar_movimientos_inversion_his_canales.sql` |
| **LOC (1er CREATE)** | 303 |
| **Callgraph** | ✅ fan_in=0 / fan_out=4 |
| **Deps concatenadas** | 7 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "búsqueda/buscar movimientos, inversión y canales (histórico)" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 1 llamada(s): `sp_obten_origen_automatico` |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=4 · INFERIDO=1 · SINTÉTICO=0 / 6 términos |

### Firma

```sql
CREATE PROCEDURE sp_buscar_movimientos_inversion_his_canales(
  pNumeroCuenta                CHAR(30)
  pFechaInicial                DATE
  pFechaFinal                  DATE
  pTipoFlujo                   INTEGER
  pMonto                       MONEY(16,2)
  pEsMontoCerrado              CHAR(3)
) RETURNING CHAR(5)								AS cod_ret,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pNumeroCuenta` | `CHAR(30)` | — | — |
| `pFechaInicial` | `DATE` | — | — |
| `pFechaFinal` | `DATE` | — | — |
| `pTipoFlujo` | `INTEGER` | — | — |
| `pMonto` | `MONEY(16,2)` | — | — |
| `pEsMontoCerrado` | `CHAR(3)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cod_ret` | `CHAR(5)` | L37 |
| `cod_ret_origen` | `CHAR(5)` | L38 |
| `iSqlErr` | `INTEGER` | L39 |
| `v_fechaMovimiento` | `DATE` | L40 |
| `v_monto` | `money(16,2)` | L41 |
| `v_monto_inicial` | `money(16,2)` | L42 |
| `v_monto_final` | `money(16,2)` | L43 |
| `monto_cashback` | `money(16,2)` | L44 |
| `v_horaMovimiento` | `DATETIME HOUR TO FRACTION(3)` | L45 |
| `v_foliosuc` | `CHAR(30)` | L46 |
| `segundaLetraFolioSuc` | `CHAR(1)` | L48 |
| `v_numSucursal` | `CHAR(4)` | L49 |
| `v_nombreSucursal` | `CHAR(30)` | L50 |
| `v_claveTipo` | `CHAR(5)` | L51 |
| `v_transacc_suc` | `CHAR(5)` | L52 |
| `v_tipo` | `CHAR(40)` | L53 |
| `v_referencia23` | `CHAR(30)` | L54 |
| `reversado` | `CHAR(1)` | L55 |
| `v_refComercio` | `CHAR(40)` | L56 |
| `res_v_fechaMovimiento_ret` | `DATE` | L57 |
| `res_v_horaMovimiento_ret` | `DATETIME HOUR TO FRACTION(3)` | L58 |
| `v_NumTarjeta` | `CHAR(16)` | L59 |
| `res_v_fechaMovimiento_re1` | `DATE` | L60 |
| `res_v_horaMovimiento_re1` | `DATETIME HOUR TO FRACTION(3)` | L61 |
| `v_origen_evento` | `INTEGER` | L62 |
| *…14 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sv_movhis` | `bdinvers` | ⚠️ sí | SELECT | L171 |
| `acl_asociacion_origen_evento_canal` | `bdiaclaracion` | no | SELECT | L248 |
| `acl_tipo_movimiento` | `bdiaclaracion` | no | SELECT | L253 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_obten_origen_automatico` | `bdiaclaracion` | no | L234 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L146 | VALIDACIÓN_NULL | `IF pMonto IS NULL OR pMonto = 0 THEN` |  |
| L151 | VALIDACIÓN_NULL | `IF pEsMontoCerrado IS NULL OR pEsMontoCerrado = 1 THEN` |  |
| L158 | FÓRMULA | `LET v_monto_final = TRUNC(pMonto) + 0.99;` | 🔴 MONEY/aritmética financiera |
| L197 | VALIDACIÓN_NULL | `IF (res_v_fechaMovimiento_ret IS NULL  OR res_v_fechaMovimiento_ret = '') THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `buscar` | ACCION | búsqueda/buscar | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `movimientos` | ENTIDAD | movimientos | 🔵 CONVENCIÓN | nombre_sp |
| `inversion` | ENTIDAD | inversión (pagaré / plazo) | 🔵 CONVENCIÓN | nombre_sp |
| `his` | MODIF | histórico | 🟡 INFERIDO | nombre_sp |
| `canales` | ENTIDAD | canales (de distribución) | 🔵 CONVENCIÓN | nombre_sp |

---

## `sp_buscarclientespornombreyfecha`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_buscarclientespornombreyfecha.sql` |
| **LOC (1er CREATE)** | 97 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 1 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "búsqueda/buscar clientes, nombre y fecha" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 1 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=5 · INFERIDO=0 · SINTÉTICO=1 / 7 términos |

### Firma

```sql
CREATE PROCEDURE sp_buscarclientespornombreyfecha(
  pNombre1                     CHAR(30)
  pNombre2                     CHAR(30)
  pPaterno                     CHAR(30)
  pMaterno                     CHAR(30)
  pFechaNac                    DATE
) RETURNING CHAR(3) as cCodRet, CHAR(20) as num_cliente, CHAR(30) as nombre1, CHAR(30) as nombre2, CHAR(30) as apaterno, CHAR(30) as amaterno, DATE as fechaNac
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pNombre1` | `CHAR(30)` | `nombre`=nombre | 🔵 CONVENCIÓN |
| `pNombre2` | `CHAR(30)` | `nombre`=nombre | 🔵 CONVENCIÓN |
| `pPaterno` | `CHAR(30)` | — | — |
| `pMaterno` | `CHAR(30)` | — | — |
| `pFechaNac` | `DATE` | `fecha`=fecha | ✅ CÓDIGO |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `sql_err` | `INTEGER` | L11 |
| `v_nombre1` | `CHAR(30)` | L12 |
| `v_nombre2` | `CHAR(30)` | L13 |
| `v_paterno` | `CHAR(30)` | L14 |
| `v_materno` | `CHAR(30)` | L15 |
| `v_numcte` | `CHAR(20)` | L16 |
| `v_fecha_nac` | `DATE` | L17 |
| `v_cod_ret` | `CHAR(4)` | L18 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_ctepf` | `bdinteg` | ⚠️ sí | SELECT | L74 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L44 | VALIDACIÓN_NULL | `if ( pPaterno is null or pPaterno = "" ) then` |  |
| L51 | VALIDACIÓN_NULL | `if ( pMaterno is null or pMaterno = "" ) then` |  |
| L52 | FÓRMULA | `let pMaterno = "*";` |  |
| L58 | VALIDACIÓN_NULL | `if ( pNombre1 is null or pNombre1 = "" ) then` |  |
| L61 | FÓRMULA | `let pNombre1 = trim(pNombre1)\|\|"*";` |  |
| L64 | VALIDACIÓN_NULL | `if ( pNombre2 is null or pNombre2 = "" ) then` |  |
| L65 | FÓRMULA | `let pNombre2 = "*";` |  |
| L67 | FÓRMULA | `let pNombre2 = trim(pNombre2)\|\|"*";` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `buscar` | ACCION | búsqueda/buscar | 🔵 CONVENCIÓN | nombre_sp |
| `clientes` | ENTIDAD | clientes (plural) | 🔵 CONVENCIÓN | nombre_sp |
| `por` | MODIF | por (criterio) | 🔵 CONVENCIÓN | nombre_sp |
| `nombre` | ENTIDAD | nombre | 🔵 CONVENCIÓN | nombre_sp |
| `?y` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `fecha` | ENTIDAD | fecha | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?y` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_buscarclientesportarjeta`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_buscarclientesportarjeta.sql` |
| **LOC (1er CREATE)** | 116 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 16 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "búsqueda/buscar clientes y tarjeta" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 7 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=0 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_buscarclientesportarjeta(
  p_sNumeroTarjeta             CHAR(30)
) RETURNING CHAR(20) AS noCliente, CHAR(30) AS primerApellido, CHAR(30) AS segundoApellido, CHAR(30) AS primerNombre, CHAR(30) AS segundoNombre
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_sNumeroTarjeta` | `CHAR(30)` | `tarjeta`=tarjeta | ✅ CÓDIGO |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `resultado_numeroCliente` | `CHAR(20)` | L5 |
| `resultado_primerApellido` | `CHAR(30)` | L6 |
| `resultado_segundoApellido` | `CHAR(30)` | L7 |
| `resultado_primerNombre` | `CHAR(30)` | L8 |
| `resultado_segundoNombre` | `CHAR(30)` | L9 |
| `cuenta_tarjeta` | `CHAR(30)` | L10 |
| `iSqlErr` | `INTEGER` | L11 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tarjetacuenta` | `intercard` | ⚠️ sí | SELECT | L43 |
| `tf_maecte` | `bditransfer` | ⚠️ sí | SELECT | L50 |
| `sc_maechq` | `bdicheq` | ⚠️ sí | SELECT | L60 |
| `sv_maeinv` | `bdinvers` | ⚠️ sí | SELECT | L70 |
| `tarjeta` | `intercard` | ⚠️ sí | SELECT | L75 |
| `sd_maecred` | `bdicred` | ⚠️ sí | SELECT | L80 |
| `si_cliente` | `bdinteg` | ⚠️ sí | SELECT | L92 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L46 | VALIDACIÓN_NULL | `IF (cuenta_tarjeta IS NULL)THEN` |  |
| L87 | VALIDACIÓN_NULL | `IF (resultado_numeroCliente IS NULL) THEN` |  |
| L95 | VALIDACIÓN_NULL | `IF (resultado_numeroCliente IS NULL) THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `buscar` | ACCION | búsqueda/buscar | 🔵 CONVENCIÓN | nombre_sp |
| `clientes` | ENTIDAD | clientes (plural) | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `por` | MODIF | por (criterio) | 🔵 CONVENCIÓN | nombre_sp |
| `tarjeta` | ENTIDAD | tarjeta | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |

---

## `sp_buscarevento`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_buscarevento.sql` |
| **LOC (1er CREATE)** | 243 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 1 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "búsqueda/buscar evento/notificación" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 2 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=0 / 3 términos |

### Firma

```sql
CREATE PROCEDURE sp_buscarevento(
  pTipoProducto                INTEGER
  pOrigenEvento                INTEGER
  pEstatusTarjeta              CHAR(3)
) RETURNING CHAR(3) 			as cCodRet,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pTipoProducto` | `INTEGER` | — | — |
| `pOrigenEvento` | `INTEGER` | `evento`=evento/notificación | ✅ CÓDIGO |
| `pEstatusTarjeta` | `CHAR(3)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `sql_err` | `INTEGER` | L26 |
| `v_cod_ret` | `CHAR(3)` | L27 |
| `v_pky_tipo_evento` | `INTEGER` | L28 |
| `v_capturamanual` | `SMALLINT` | L29 |
| `v_descripcion` | `VARCHAR(50)` | L30 |
| `v_diferenciaimportes` | `SMALLINT` | L31 |
| `v_grupo_doc` | `VARCHAR(4)` | L32 |
| `v_nombre` | `VARCHAR(50)` | L33 |
| `v_fky_tipo_transaccion` | `INTEGER` | L34 |
| `v_costo` | `MONEY` | L35 |
| `v_acepta_cargos_recurrentes` | `SMALLINT` | L36 |
| `v_motivobloqueodebito` | `CHAR(2)` | L37 |
| `v_tipobloqueocredito` | `INTEGER` | L38 |
| `v_motivobloqueocredito` | `CHAR(2)` | L39 |
| `v_tipobloqueodebito` | `INTEGER` | L40 |
| `v_statustarjeta` | `CHAR(3)` | L41 |
| `v_indroboextravio` | `SMALLINT` | L42 |
| `v_contador_eventos` | `INTEGER` | L43 |
| `v_validacion_cancelacion_automatica` | `CHAR(1)` | L44 |
| `v_es_compra_a_meses` | `CHAR(1)` | L45 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `acl_origen_evento` | `bdiaclaracion` | no | SELECT | L86 |
| `acl_tipo_evento` | `bdiaclaracion` | no | SELECT | L92 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `buscar` | ACCION | búsqueda/buscar | 🔵 CONVENCIÓN | nombre_sp |
| `evento` | ENTIDAD | evento/notificación | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |

---

## `sp_buscarorigen`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_buscarorigen.sql` |
| **LOC (1er CREATE)** | 73 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 9 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "búsqueda/buscar origen" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 2 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=0 / 3 términos |

### Firma

```sql
CREATE PROCEDURE sp_buscarorigen(
  pTipoProducto                INTEGER
) RETURNING CHAR (3) AS cCodRet, INTEGER AS  IdOrigenEvento, CHAR (50) AS Descripcion, CHAR (50) AS Nombre, INTEGER AS PorcentajeMaximo, int AS ValidacionCargoRec, int AS IndicadorRoboIdentidad, int AS IndicadorRoboExtravio
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pTipoProducto` | `INTEGER` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `iSqlErr` | `INTEGER` | L5 |
| `v_cod_ret` | `CHAR(3)` | L6 |
| `id_origen_evento` | `INTEGER` | L7 |
| `descripcionOrigenEvento` | `VARCHAR (50)` | L8 |
| `nombreOrigenEvento` | `VARCHAR (50)` | L9 |
| `porcentajeMaximo` | `INTEGER` | L10 |
| `validacionCargoRecurrente` | `INT` | L11 |
| `indicadorRoboIdentidad` | `INT` | L12 |
| `indicadorRoboExtravio` | `INT` | L13 |
| `activo` | `INT` | L14 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `acl_origen_evento` | `bdiaclaracion` | no | SELECT | L49 |
| `acl_regla_negocio` | `bdiaclaracion` | no | SELECT | L52 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `buscar` | ACCION | búsqueda/buscar | 🔵 CONVENCIÓN | nombre_sp |
| `origen` | ENTIDAD | origen | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |

---

## `sp_buscarorigen_por_flujo`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_buscarorigen_por_flujo.sql` |
| **LOC (1er CREATE)** | 80 |
| **Callgraph** | ✅ fan_in=0 / fan_out=5 |
| **Deps concatenadas** | 20 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "búsqueda/buscar origen" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 1 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=1 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_buscarorigen_por_flujo(
  pProducto                    INTEGER
  pTipoFlujo                   INTEGER
) RETURNING CHAR(5)				AS cod_ret,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pProducto` | `INTEGER` | — | — |
| `pTipoFlujo` | `INTEGER` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `sql_err` | `INTEGER` | L16 |
| `v_cod_ret` | `CHAR(5)` | L17 |
| `v_pky_origen_evento` | `INTEGER` | L19 |
| `v_descripcion` | `VARCHAR(50)` | L20 |
| `v_nombre` | `VARCHAR(50)` | L21 |
| `v_porcentaje_maximo` | `INTEGER` | L22 |
| `v_acepta_cargos_recurrentes` | `SMALLINT` | L23 |
| `v_indicador_robo_identidad` | `SMALLINT` | L24 |
| `v_pky_tipo_producto` | `INTEGER` | L25 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `acl_tipo_evento` | `bdiaclaracion` | no | SELECT | L54 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `buscar` | ACCION | búsqueda/buscar | 🔵 CONVENCIÓN | nombre_sp |
| `origen` | ENTIDAD | origen | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `por` | MODIF | por (criterio) | 🔵 CONVENCIÓN | nombre_sp |
| `?_flujo` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_flujo` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_busqueda_sucursal_parapdf`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_busqueda_sucursal_parapdf.sql` |
| **LOC (1er CREATE)** | 23 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "búsqueda sucursal" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 1 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=1 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_busqueda_sucursal_parapdf(
  n_Sucursal                   CHAR(10)
) RETURNING CHAR(11) AS numero_sucursal, CHAR(76) AS nombre_sucursal
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `n_Sucursal` | `CHAR(10)` | `sucursal`=sucursal | ✅ CÓDIGO |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `resultado_nombre_sucursal` | `CHAR(75)` | L6 |
| `resultado_numero_sucursal` | `CHAR(10)` | L7 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_sucursales` | `bdinteg` | ⚠️ sí | SELECT | L16 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `busqueda` | ACCION | búsqueda | 🔵 CONVENCIÓN | nombre_sp |
| `sucursal` | ENTIDAD | sucursal | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `?_parapdf` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_parapdf` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_busquedamovstrans`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_busquedamovstrans.sql` |
| **LOC (1er CREATE)** | 265 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 1 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "búsqueda movimientos y [polisemia] Transferencia" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 2 llamada(s): `sp_consulta_tipo_movimiento`, `sp_obten_referencia23_cheques` |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=3 · INFERIDO=1 · SINTÉTICO=0 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_busquedamovstrans(
  pOrigenEvento                INTEGER
  pTipoEvento                  INTEGER
  pFechaInicial                DATE
  pFechaFinal                  DATE
  pNumeroCliente               CHAR(9)
  pNumeroCuenta                CHAR(30)
  pNumeroTarjeta               CHAR(16)
  p_skip                       INTEGER
  p_recuperacion               INTEGER
) RETURNING CHAR(3) 						AS cCodRet,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pOrigenEvento` | `INTEGER` | — | — |
| `pTipoEvento` | `INTEGER` | — | — |
| `pFechaInicial` | `DATE` | — | — |
| `pFechaFinal` | `DATE` | — | — |
| `pNumeroCliente` | `CHAR(9)` | — | — |
| `pNumeroCuenta` | `CHAR(30)` | — | — |
| `pNumeroTarjeta` | `CHAR(16)` | — | — |
| `p_skip` | `INTEGER` | — | — |
| `p_recuperacion` | `INTEGER` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `sql_err` | `INTEGER` | L31 |
| `v_cod_ret` | `CHAR(4)` | L32 |
| `tipo_producto` | `INTEGER` | L34 |
| `s_fechamovimiento` | `DATE` | L37 |
| `s_horamovimiento` | `DATETIME HOUR to FRACTION(3)` | L38 |
| `s_monto` | `money(16,2)` | L39 |
| `s_foliosuc` | `CHAR(30)` | L40 |
| `s_sucursal` | `CHAR(4)` | L41 |
| `s_nombre` | `CHAR(30)` | L42 |
| `s_clavetipo` | `CHAR(5)` | L43 |
| `s_tipo` | `CHAR(40)` | L44 |
| `s_referencia23` | `CHAR(30)` | L45 |
| `s_reversado` | `CHAR(1)` | L46 |
| `s_refcomercio` | `CHAR(40)` | L47 |
| `s_fechaconsumo` | `DATE` | L48 |
| `s_horaconsumo` | `DATETIME HOUR to FRACTION(3)` | L49 |
| `s_tipomovimiento` | `CHAR(1)` | L50 |
| `s_modoentrada` | `VARCHAR(2)` | L51 |
| `ret_str` | `LVARCHAR` | L53 |
| `s_telefono` | `CHAR(13)` | L54 |
| `s_nombreOrigenEvento` | `VARCHAR(15)` | L56 |
| `s_fechaString` | `CHAR(20)` | L57 |
| `dummy_horamovimiento` | `DATETIME HOUR to FRACTION(3)` | L61 |
| `dummy_monto` | `money(16,2)` | L62 |
| `dummy_foliosuc` | `CHAR(30)` | L63 |
| *…12 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `acl_producto` | `bdiaclaracion` | no | SELECT | L146 |
| `tf_maecte` | `bditransfer` | ⚠️ sí | SELECT | L154 |
| `acl_tipo_movimiento` | `bdiaclaracion` | no | SELECT | L159 |
| `acl_tipo_evento` | `bdiaclaracion` | no | SELECT | L160 |
| `acl_origen_evento` | `bdiaclaracion` | no | SELECT | L228 |
| `systables` | `bdiaclaracion` | no | SELECT | L235 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_consulta_tipo_movimiento` | `bdiaclaracion` | no | L186 |
| `sp_obten_referencia23_cheques` | `bdinteg` | ⚠️ sí | L237 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L189 | FÓRMULA | `LET iRecuperacion = iRecuperacion + 1;` |  |
| L232 | FÓRMULA | `LET s_fechaString = year (s_fechamovimiento) \|\| '-' \|\| month (s_fechamovimiento) \|\| '-' \|\| d` |  |
| L242 | FÓRMULA | `LET iRecuperacion = iRecuperacion + 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `busqueda` | ACCION | búsqueda | 🔵 CONVENCIÓN | nombre_sp |
| `movs` | ENTIDAD | movimientos (abreviación) | 🟡 INFERIDO | nombre_sp |
| `trans` | ENTIDAD | [polisemia] Transferencia (bditransfer, bditrans: transferen | 🔵 CONVENCIÓN | nombre_sp |

---

## `sp_cargoxajuste_debcred`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_cargoxajuste_debcred.sql` |
| **LOC (1er CREATE)** | 656 |
| **Callgraph** | ✅ fan_in=0 / fan_out=12 |
| **Deps concatenadas** | 9 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "cargo y débito/crédito" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 3 llamada(s): `sp_cargo_abono_aclara`, `cons_saldo`, `cargo_ref` |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=2 · INFERIDO=1 · SINTÉTICO=1 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_cargoxajuste_debcred(
  pEmpresa                     CHAR(3)
  pFolioSuac                   CHAR(10)
  pDictamen                    CHAR(2)
  pEmpleadoAut                 CHAR (8)
  pMontoAD                     DECIMAL(18,2)
  pTipo                        Integer
  pRequiereAut                 SMALLINT
) RETURNING CHAR(3)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pEmpresa` | `CHAR(3)` | — | — |
| `pFolioSuac` | `CHAR(10)` | — | — |
| `pDictamen` | `CHAR(2)` | — | — |
| `pEmpleadoAut` | `CHAR (8)` | — | — |
| `pMontoAD` | `DECIMAL(18,2)` | — | — |
| `pTipo` | `Integer` | — | — |
| `pRequiereAut` | `SMALLINT` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(3)` | L4 |
| `sql_err` | `INTEGER` | L5 |
| `isam_err` | `INTEGER` | L6 |
| `CnumCuenta` | `CHAR(20)` | L8 |
| `Tproducto` | `INTEGER` | L9 |
| `CnumTarjeta` | `CHAR(20)` | L10 |
| `CmontoAcla` | `DECIMAL(18,2)` | L11 |
| `Ctrans_cargo_ajuste` | `CHAR(04)` | L13 |
| `Ifky_producto` | `INTEGER` | L14 |
| `Ipky_tipo_movimiento` | `INTEGER` | L15 |
| `FIpky_tipo_movimiento` | `INTEGER` | L16 |
| `Ipky_movimiento` | `INTEGER` | L17 |
| `DCodret_a` | `CHAR(5)` | L20 |
| `DTranret_c` | `CHAR(5)` | L22 |
| `DFechoy_c` | `DATE` | L23 |
| `DVsdodisp_c` | `MONEY(14,2)` | L24 |
| `DVmontoret_c` | `MONEY(14,2)` | L25 |
| `CMensaje` | `CHAR(80)` | L27 |
| `CSecuencia` | `INTEGER` | L28 |
| `Ctrannopro` | `CHAR(04)` | L29 |
| `Ctransinauto` | `CHAR(04)` | L30 |
| `Ctranpro` | `CHAR(04)` | L31 |
| `Ctranauto` | `CHAR(04)` | L32 |
| `CtranCargoAjuste` | `CHAR(04)` | L33 |
| `Ccargo` | `SMALLINT` | L34 |
| *…19 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `acl_movimiento` | `bdiaclaracion` | no | SELECT | L156 |
| `acl_movimiento` | `bdiaclaracion` | no | INSERT | L224 |
| `sd_fechas` | `bdicred` | ⚠️ sí | SELECT | L282 |
| `acl_producto` | `bdiaclaracion` | no | SELECT | L428 |
| `sc_fechas` | `bdicheq` | ⚠️ sí | SELECT | L467 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_cargo_abono_aclara` | `bdicred` | ⚠️ sí | L289 |
| `cons_saldo` | `bdicheq` | ⚠️ sí | L477 |
| `cargo_ref` | `bdicheq` | ⚠️ sí | L479 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L142 | VALIDACIÓN_NULL | `IF pFolioSuac IS NULL OR pFolioSuac = '' THEN      --> CodRet ok, pFolioSuac pentrada ok, cCodRet ok` |  |
| L147 | VALIDACIÓN_NULL | `IF pDictamen IS NULL OR pDictamen = '' THEN       --> CodRet ok, pDictamen pentrada ok, cCodRet ok` |  |
| L205 | FÓRMULA | `LET v_montoprocedente = (v_montoprocedente+v_interes);` | 🔴 MONEY/aritmética financiera |
| L220 | FÓRMULA | `LET v_montoprocedente = (v_montoprocedente-pMontoAD);` | 🔴 MONEY/aritmética financiera |
| L222 | VALIDACIÓN_NULL | `IF (v_fky_padre IS NULL) THEN` |  |
| L254 | VALIDACIÓN_NULL | `IF CnumCredito IS NULL THEN` |  |
| L263 | VALIDACIÓN_NULL | `IF CmontoAcla IS NULL or CmontoAcla = 0 THEN` |  |
| L272 | VALIDACIÓN_NULL | `IF (CnumTarjeta is null) then` |  |
| L394 | FÓRMULA | `LET v_montoprocedente = (v_montoprocedente+v_interes);` | 🔴 MONEY/aritmética financiera |
| L408 | FÓRMULA | `LET v_montoprocedente = (v_montoprocedente-pMontoAD);` | 🔴 MONEY/aritmética financiera |
| L410 | VALIDACIÓN_NULL | `IF (v_fky_padre IS NULL ) THEN` |  |
| L447 | VALIDACIÓN_NULL | `IF CnumCuenta IS NULL THEN` |  |
| L456 | VALIDACIÓN_NULL | `IF CmontoAcla IS NULL or CmontoAcla = 0 THEN` |  |
| L461 | VALIDACIÓN_NULL | `IF (CnumTarjeta is null) then` |  |
| L595 | VALIDACIÓN_NULL | `IF (CSecuencia_acl_mov is null) THEN` |  |
| L598 | FÓRMULA | `LET CSecuencia_acl_mov = (CSecuencia_acl_mov) + 1;` |  |
| L629 | FÓRMULA | `LET v_contador = v_contador + 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `cargo` | ENTIDAD | cargo / débito | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `x` | MODIF | por (criterio) | 🔵 CONVENCIÓN | nombre_sp |
| `?ajuste_` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `debcred` | ENTIDAD | débito/crédito (movimiento) | 🟡 INFERIDO | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?ajuste_` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_cat_statustarjeta`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_cat_statustarjeta.sql` |
| **LOC (1er CREATE)** | 52 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 8 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "catálogo, estatus y tarjeta" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 1 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=4 · INFERIDO=0 · SINTÉTICO=0 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_cat_statustarjeta(
) RETURNING CHAR(5) AS codRet,
```

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(5)` | L6 |
| `iSqlErr` | `INT` | L7 |
| `codStatus` | `CHAR(3)` | L8 |
| `descStatus` | `CHAR(30)` | L9 |
| `iRecuperacion` | `INTEGER` | L10 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `statustarjeta` | `intercard` | ⚠️ sí | SELECT | L36 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L12 | CÓDIGO_RETORNO | `LET cCodRet = '00000';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `cat` | ENTIDAD | catálogo | 🔵 CONVENCIÓN | nombre_sp |
| `status` | ENTIDAD | estatus | 🔵 CONVENCIÓN | nombre_sp |
| `tarjeta` | ENTIDAD | tarjeta | 🔵 CONVENCIÓN | nombre_sp |

---

## `sp_change_password`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_change_password.sql` |
| **LOC (1er CREATE)** | 127 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 11 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "ss — subsistema y ordenante" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 4 tabla(s) con operaciones: SELECT, INSERT, UPDATE |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=3 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_change_password(
  pUsuario                     CHAR(8)
  pBandera                     CHAR(1)
  pPassword                    CHAR(100)
) RETURNING CHAR(5) AS codret,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pUsuario` | `CHAR(8)` | — | — |
| `pBandera` | `CHAR(1)` | — | — |
| `pPassword` | `CHAR(100)` | `ss`=ss — subsistema / canal de monitoreo (abreviación — envia_monitorsol_*_ss_* — bdisolic) · `ord`=ordenante / orden (SPEI) | 🔴 SINTÉTICO / 🔵 CONVENCIÓN |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(5)` | L6 |
| `iSqlErr` | `INTEGER` | L7 |
| `cfechaUltimoCambio` | `DATE` | L8 |
| `cPassAnt` | `CHAR(100)` | L9 |
| `iTotCont` | `INTEGER` | L10 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `acl_bitacora_cambio_pass` | `bdiaclaracion` | no | SELECT | L42 |
| `acl_usuario` | `bdiaclaracion` | no | SELECT | L50 |
| `acl_bitacora_cambio_pass` | `bdiaclaracion` | no | INSERT | L53 |
| `acl_usuario` | `bdiaclaracion` | no | UPDATE | L103 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L12 | CÓDIGO_RETORNO | `LET cCodRet = '00000';` |  |
| L29 | CÓDIGO_RETORNO | `LET cCodRet = '00003';` |  |
| L56 | CÓDIGO_RETORNO | `LET cCodRet = '99999';` |  |
| L66 | VALIDACIÓN_NULL | `IF cPassAnt IS NULL THEN` |  |
| L67 | FÓRMULA | `LET cfechaUltimoCambio = (TODAY-1) ;` |  |
| L108 | CÓDIGO_RETORNO | `LET cCodRet = '99999';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `?_change_pa` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `ss` | ENTIDAD | ss — subsistema / canal de monitoreo (abreviación — envia_mo | 🔴 SINTÉTICO | nombre_sp |
| `?w` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `ord` | ENTIDAD | ordenante / orden (SPEI) | 🔵 CONVENCIÓN | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_change_pa`, `ss`, `?w` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_cierres_masivos_afectacion`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_cierres_masivos_afectacion.sql` |
| **LOC (1er CREATE)** | 244 |
| **Callgraph** | ✅ fan_in=0 / fan_out=5 |
| **Deps concatenadas** | 5 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "cierre cuenta (masivo)" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 1 llamada(s): `sp_aplica_cierre_masivo` |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=3 / 7 términos |

### Firma

```sql
CREATE PROCEDURE sp_cierres_masivos_afectacion(
) RETURNING CHAR(5) AS codigo_ret
```

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `sql_err` | `INTEGER` | L7 |
| `v_cod_ret` | `CHAR(6)` | L8 |
| `cCodRet` | `CHAR(6)` | L9 |
| `vFolioCsuac` | `varchar(11)` | L10 |
| `c_nombre_archivo` | `VARCHAR(50)` | L12 |
| `c_ext_archivo` | `VARCHAR(50)` | L13 |
| `v_nombre_archivo` | `VARCHAR(50)` | L14 |
| `c_fecha_actual` | `DATE` | L15 |
| `v_nombre` | `VARCHAR(11)` | L16 |
| `v_descripcion` | `VARCHAR(100)` | L17 |
| `cCadena` | `CHAR(1000)` | L18 |
| `vsql` | `char(3000)` | L19 |
| `v_folio_csuac` | `varchar(16)` | L20 |
| `v_dictamen` | `LVARCHAR` | L21 |
| `v_bitacora` | `LVARCHAR` | L22 |
| `v_importeprocedente` | `MONEY` | L23 |
| `v_dias_conclucion` | `integer` | L24 |
| `v_pky_aclaracion` | `integer` | L25 |
| `iContador` | `INTEGER` | L26 |
| `v_temp_table` | `INTEGER` | L27 |
| `v_mensaje` | `varchar(150)` | L28 |
| `v_procede` | `varchar(2)` | L29 |
| `vcodresolucion` | `varchar(2)` | L30 |
| `vResultado` | `CHAR(50)` | L31 |
| `v_resolucion` | `INTEGER` | L32 |
| *…5 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `systables` | `bdiaclaracion` | no | SELECT | L89 |
| `si_fechas` | `bdinteg` | ⚠️ sí | SELECT | L97 |
| `statistics` | `bdiaclaracion` | no | UPDATE | L115 |
| `tabla_cierre_preventivo_afectac` | `bdiaclaracion` | no | INSERT | L123 |
| `acl_cierre_masivo` | `bdiaclaracion` | no | SELECT | L151 |
| `tabla_cierre_preventivo_afectac` | `bdiaclaracion` | no | SELECT | L165 |
| `acl_tipo_codigo_resolucion` | `bdiaclaracion` | no | SELECT | L186 |
| `acl_aclaracion` | `bdiaclaracion` | no | SELECT | L209 |
| `acl_entrada_bitacora` | `bdiaclaracion` | no | INSERT | L213 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_aplica_cierre_masivo` | `bdiaclaracion` | no | L202 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L137 | FÓRMULA | `let vsql ='rm  /resplogifx/repaclaraciones/aclaracion.sql';` |  |
| L142 | FÓRMULA | `let vsql ='rm  /resplogifx/repaclaraciones/'\|\|v_nombre_archivo\|\|'';` |  |
| L153 | VALIDACIÓN_NULL | `IF v_num_proceso IS NULL THEN` |  |
| L156 | FÓRMULA | `LET v_num_proceso = v_num_proceso + 1;` |  |
| L189 | VALIDACIÓN_NULL | `IF (v_folio_csuac IS NULL OR v_folio_csuac = '') THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `cierre` | ACCION | cierre | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `?s_` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `masivo` | MODIF | masivo | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `?s_afe` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `cta` | ENTIDAD | cuenta | 🔵 CONVENCIÓN | nombre_sp |
| `?cion` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?s_`, `?s_afe`, `?cion` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_consulta_aclaracion_filtros_preingreso`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_consulta_aclaracion_filtros_preingreso.sql` |
| **LOC (1er CREATE)** | 228 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 6 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "consulta aclaración bancaria — proceso de disputa o reclamación del cliente, OS — Originación de Solicitudes y ingreso" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=2 · INFERIDO=1 · SINTÉTICO=2 / 7 términos |

### Firma

```sql
CREATE PROCEDURE sp_consulta_aclaracion_filtros_preingreso(
  p_Numcliente                 CHAR(9)
  p_Numtarjeta                 CHAR(16)
  p_NumCuenta                  CHAR(20)
  p_Telcuentamovil             CHAR(13)
  p_FolioCsuac                 CHAR(11)
  p_Fechainicio                CHAR(10)
  p_Fechafin                   CHAR(10)
  p_Canalingreso               INTEGER
  p_Estatusingreso             INTEGER
  p_FolioAclaracion            CHAR(18)
) RETURNING CHAR(4)  AS cCodRet,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_Numcliente` | `CHAR(9)` | — | — |
| `p_Numtarjeta` | `CHAR(16)` | — | — |
| `p_NumCuenta` | `CHAR(20)` | — | — |
| `p_Telcuentamovil` | `CHAR(13)` | — | — |
| `p_FolioCsuac` | `CHAR(11)` | — | — |
| `p_Fechainicio` | `CHAR(10)` | — | — |
| `p_Fechafin` | `CHAR(10)` | — | — |
| `p_Canalingreso` | `INTEGER` | `ingreso`=ingreso (del solicitante) | ✅ CÓDIGO |
| `p_Estatusingreso` | `INTEGER` | `ingreso`=ingreso (del solicitante) | ✅ CÓDIGO |
| `p_FolioAclaracion` | `CHAR(18)` | `aclaracion`=aclaración bancaria — proceso de disputa o reclamación del cliente | ✅ CÓDIGO |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `iSqlErr` | `INTEGER` | L24 |
| `v_cod_ret` | `CHAR(4)` | L25 |
| `estatus_corporativo` | `INTEGER` | L26 |
| `cat_tipo_aclaracion` | `INTEGER` | L27 |
| `indice` | `INTEGER` | L28 |
| `indice_tipo_aclaracion` | `INTEGER` | L29 |
| `v_pky_aclaracion` | `CHAR(60)` | L30 |
| `v_fechacaptura` | `CHAR(11)` | L31 |
| `v_folio_csuac` | `CHAR(11)` | L32 |
| `v_nombreevento` | `CHAR(60)` | L33 |
| `v_nombreorigen` | `CHAR(60)` | L34 |
| `v_estatuscorporativo` | `CHAR(60)` | L35 |
| `v_descingresotipoaclaracion` | `CHAR(50)` | L36 |
| `vacio` | `CHAR(1)` | L37 |
| `cadenaCOncatenada` | `CHAR(1000)` | L39 |
| `cadenaCOncatenadatmp` | `CHAR(1200)` | L40 |
| `cadenaCOncatenadatmp2` | `CHAR(1000)` | L41 |
| `consultaProducto` | `SMALLINT` | L42 |
| `contador` | `INTEGER` | L43 |
| `iRecuperacion` | `INTEGER` | L44 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `acl_cat_tipo_aclaracion` | `bdiaclaracion` | no | SELECT | L150 |
| `acl_estatus_corporativo` | `bdiaclaracion` | no | SELECT | L170 |
| `acl_aclaracion` | `bdiaclaracion` | no | SELECT | L183 |
| `cadenaconcatenadatmp` | `bdiaclaracion` | no | SELECT | L196 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L141 | FÓRMULA | `LET cadenaCOncatenadatmp =  " AND acl.fechacaptura BETWEEN  TO_DATE ('" \|\| p_Fechainicio \|\| "','` |  |
| L159 | FÓRMULA | `LET indice_tipo_aclaracion = indice_tipo_aclaracion + 1;` |  |
| L176 | FÓRMULA | `LET indice = indice + 1;` |  |
| L205 | FÓRMULA | `LET iRecuperacion = iRecuperacion + 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `consulta` | ACCION | consulta / lee | 🔵 CONVENCIÓN | nombre_sp |
| `aclaracion` | ENTIDAD | aclaración bancaria — proceso de disputa o reclamación del c | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `?_filtr` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `os` | ENTIDAD | OS — Originación de Solicitudes / subsistema de ofertas (sp_ | 🟡 INFERIDO | nombre_sp |
| `?_pre` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `ingreso` | ENTIDAD | ingreso (del solicitante) | ✅ CÓDIGO | nombre_sp, texto_cuerpo |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_filtr`, `?_pre` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_consulta_aclaracion_sms`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_consulta_aclaracion_sms.sql` |
| **LOC (1er CREATE)** | 162 |
| **Callgraph** | ✅ fan_in=1 / fan_out=2 |
| **Propósito inferido** | "consulta aclaración bancaria — proceso de disputa o reclamación del cliente y SMS" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=3 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=0 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_consulta_aclaracion_sms(
  pFolioCsuac                  CHAR(30)
  pCel                         CHAR(10)
  pnumCliente                  CHAR(20)
) RETURNING CHAR(5)				AS cod_ret
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pFolioCsuac` | `CHAR(30)` | — | — |
| `pCel` | `CHAR(10)` | — | — |
| `pnumCliente` | `CHAR(20)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `sql_err` | `INTEGER` | L21 |
| `autentica` | `INTEGER` | L22 |
| `v_cod_ret` | `CHAR(5)` | L23 |
| `v_cod_ret_reg_eve` | `CHAR(5)` | L24 |
| `v_folio_csuac` | `CHAR(10)` | L25 |
| `v_montoreclamado` | `MONEY` | L26 |
| `v_montoprocedente` | `MONEY` | L27 |
| `v_estatus_canales` | `CHAR(50)` | L28 |
| `v_estatus_sms` | `CHAR(50)` | L29 |
| `v_telefono_dudas` | `CHAR(15)` | L30 |
| `v_procede` | `SMALLINT` | L31 |
| `v_fky_estatus_aclaracion` | `INTEGER` | L32 |
| `v_fky_estatus_corp_analisis` | `INTEGER` | L33 |
| `v_fky_estatus_corp_general` | `INTEGER` | L34 |
| `v_desc_estatus_canales` | `CHAR(50)` | L36 |
| `v_concatena_dictamen` | `SMALLINT` | L37 |
| `v_id_etapa_canales` | `SMALLINT` | L38 |
| `v_desc_etapa_canales` | `CHAR(20)` | L39 |
| `v_num_cliente` | `CHAR(10)` | L40 |
| `v_fecha_consulta` | `DATETIME YEAR TO FRACTION(5)` | L41 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `acl_aclaracion` | `bdiaclaracion` | no | SELECT | L92 |
| `acl_bitacora_sms` | `bdiaclaracion` | no | INSERT | L100 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_obten_estatus_canales_sms` | `bdiaclaracion` | no | L105 |
| `sp_registra_evento` | `bdimnsj` | ⚠️ sí | L127 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L111 | FÓRMULA | `LET v_estatus_sms = TRIM(v_estatus_sms) \|\| ' - Procedente';` |  |
| L114 | FÓRMULA | `LET v_estatus_sms = TRIM(v_estatus_sms) \|\| ' - No procedente';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `consulta` | ACCION | consulta / lee | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `aclaracion` | ENTIDAD | aclaración bancaria — proceso de disputa o reclamación del c | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `sms` | ENTIDAD | SMS | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |

---

## `sp_consulta_aclaraciones_producto_cliente`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_consulta_aclaraciones_producto_cliente.sql` |
| **LOC (1er CREATE)** | 660 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 3 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "consulta aclaraciones, producto y cliente" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=4 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=0 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_consulta_aclaraciones_producto_cliente(
  p_tipo_consulta              INTEGER
  p_id_producto                INTEGER
  p_tipo_producto              INTEGER
  p_num_cliente                INTEGER
  p_pky_rango_importe          INTEGER
) RETURNING CHAR(5) AS s_codRet,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_tipo_consulta` | `INTEGER` | `consulta`=consulta / lee | ✅ CÓDIGO |
| `p_id_producto` | `INTEGER` | `producto`=producto | ✅ CÓDIGO |
| `p_tipo_producto` | `INTEGER` | `producto`=producto | ✅ CÓDIGO |
| `p_num_cliente` | `INTEGER` | `cliente`=cliente | ✅ CÓDIGO |
| `p_pky_rango_importe` | `INTEGER` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cod_retorno` | `CHAR(5)` | L16 |
| `monto_total_aclaraciones_producto_cliente` | `MONEY` | L17 |
| `numero_aclaraciones_con_abono` | `INTEGER` | L18 |
| `numero_aclaraciones_sin_abono` | `INTEGER` | L19 |
| `importe_aclaraciones_con_abono` | `MONEY` | L20 |
| `importe_aclaraciones_sin_abono` | `MONEY` | L21 |
| `total_numero_aclaraciones` | `INTEGER` | L22 |
| `total_importe_aclaraciones` | `MONEY` | L23 |
| `monto_total_aclaraciones_producto_cliente_temp` | `MONEY` | L25 |
| `numero_aclaraciones_con_abono_temp` | `INTEGER` | L26 |
| `numero_aclaraciones_sin_abono_temp` | `INTEGER` | L27 |
| `importe_aclaraciones_con_abono_temp` | `MONEY` | L28 |
| `importe_aclaraciones_sin_abono_temp` | `MONEY` | L29 |
| `total_numero_aclaraciones_temp` | `INTEGER` | L30 |
| `total_importe_aclaraciones_temp` | `MONEY` | L31 |
| `iSqlErr` | `INTEGER` | L33 |
| `uno` | `INTEGER` | L34 |
| `cero` | `INTEGER` | L35 |
| `resolucion_con_abono_temporal` | `INTEGER` | L36 |
| `resolucion_sin_abono_temporal` | `INTEGER` | L37 |
| `estatus_aclaracion_ingresada` | `INTEGER` | L38 |
| `estatus_aclaracion_con_dic_sin_digi` | `INTEGER` | L39 |
| `estatus_aclaracion_finalizada` | `INTEGER` | L40 |
| `estatus_corp_gral_pred_aceptado` | `INTEGER` | L41 |
| `estatus_corp_gral_cierre_prev_no_real` | `INTEGER` | L42 |
| *…13 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_fechas` | `bdinteg` | ⚠️ sí | SELECT | L118 |
| `acl_rango_importe` | `bdiaclaracion` | no | SELECT | L131 |
| `acl_estatus_aclaracion` | `bdiaclaracion` | no | SELECT | L145 |
| `acl_estatus_corporativo` | `bdiaclaracion` | no | SELECT | L150 |
| `acl_resolucion` | `bdiaclaracion` | no | SELECT | L160 |
| `acl_cat_tipo_aclaracion` | `bdiaclaracion` | no | SELECT | L205 |
| `acl_aclaracion` | `bdiaclaracion` | no | SELECT | L219 |
| `tblaclaraciones` | `bdiaclaracion` | no | UPDATE | L237 |
| `tblaclaraciones` | `bdiaclaracion` | no | SELECT | L243 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L124 | FÓRMULA | `LET fechaPasada = ADD_MONTHS(fechaActual,-12);` |  |
| L263 | FÓRMULA | `LET monto_total_aclaraciones_producto_cliente = monto_total_aclaraciones_producto_cliente + monto_to` | 🔴 MONEY/aritmética financiera |
| L275 | FÓRMULA | `LET monto_total_aclaraciones_producto_cliente = monto_total_aclaraciones_producto_cliente + monto_to` | 🔴 MONEY/aritmética financiera |
| L288 | FÓRMULA | `LET monto_total_aclaraciones_producto_cliente = monto_total_aclaraciones_producto_cliente + monto_to` | 🔴 MONEY/aritmética financiera |
| L301 | FÓRMULA | `LET monto_total_aclaraciones_producto_cliente = monto_total_aclaraciones_producto_cliente + monto_to` | 🔴 MONEY/aritmética financiera |
| L314 | FÓRMULA | `LET monto_total_aclaraciones_producto_cliente = monto_total_aclaraciones_producto_cliente + monto_to` | 🔴 MONEY/aritmética financiera |
| L327 | FÓRMULA | `LET monto_total_aclaraciones_producto_cliente = monto_total_aclaraciones_producto_cliente + monto_to` | 🔴 MONEY/aritmética financiera |
| L339 | FÓRMULA | `LET monto_total_aclaraciones_producto_cliente = monto_total_aclaraciones_producto_cliente + monto_to` | 🔴 MONEY/aritmética financiera |
| L352 | FÓRMULA | `LET monto_total_aclaraciones_producto_cliente = monto_total_aclaraciones_producto_cliente + monto_to` | 🔴 MONEY/aritmética financiera |
| L390 | FÓRMULA | `LET importe_aclaraciones_con_abono = importe_aclaraciones_con_abono + importe_aclaraciones_con_abono` | 🔴 MONEY/aritmética financiera |
| L391 | FÓRMULA | `LET numero_aclaraciones_con_abono = numero_aclaraciones_con_abono + numero_aclaraciones_con_abono_te` |  |
| L407 | FÓRMULA | `LET importe_aclaraciones_con_abono = importe_aclaraciones_con_abono + importe_aclaraciones_con_abono` | 🔴 MONEY/aritmética financiera |
| L408 | FÓRMULA | `LET numero_aclaraciones_con_abono = numero_aclaraciones_con_abono + numero_aclaraciones_con_abono_te` |  |
| L424 | FÓRMULA | `LET importe_aclaraciones_con_abono = importe_aclaraciones_con_abono + importe_aclaraciones_con_abono` | 🔴 MONEY/aritmética financiera |
| L425 | FÓRMULA | `LET numero_aclaraciones_con_abono = numero_aclaraciones_con_abono + numero_aclaraciones_con_abono_te` |  |
| L441 | FÓRMULA | `LET importe_aclaraciones_con_abono = importe_aclaraciones_con_abono + importe_aclaraciones_con_abono` | 🔴 MONEY/aritmética financiera |
| L442 | FÓRMULA | `LET numero_aclaraciones_con_abono = numero_aclaraciones_con_abono + numero_aclaraciones_con_abono_te` |  |
| L458 | FÓRMULA | `LET importe_aclaraciones_con_abono = importe_aclaraciones_con_abono + importe_aclaraciones_con_abono` | 🔴 MONEY/aritmética financiera |
| L459 | FÓRMULA | `LET numero_aclaraciones_con_abono = numero_aclaraciones_con_abono + numero_aclaraciones_con_abono_te` |  |
| L475 | FÓRMULA | `LET importe_aclaraciones_con_abono = importe_aclaraciones_con_abono + importe_aclaraciones_con_abono` | 🔴 MONEY/aritmética financiera |
| L476 | FÓRMULA | `LET numero_aclaraciones_con_abono = numero_aclaraciones_con_abono + numero_aclaraciones_con_abono_te` |  |
| L492 | FÓRMULA | `LET importe_aclaraciones_con_abono = importe_aclaraciones_con_abono + importe_aclaraciones_con_abono` | 🔴 MONEY/aritmética financiera |
| L493 | FÓRMULA | `LET numero_aclaraciones_con_abono = numero_aclaraciones_con_abono + numero_aclaraciones_con_abono_te` |  |
| L528 | FÓRMULA | `LET importe_aclaraciones_sin_abono = importe_aclaraciones_sin_abono + importe_aclaraciones_sin_abono` | 🔴 MONEY/aritmética financiera |
| L529 | FÓRMULA | `LET numero_aclaraciones_sin_abono = numero_aclaraciones_sin_abono + numero_aclaraciones_sin_abono_te` |  |
| L545 | FÓRMULA | `LET importe_aclaraciones_sin_abono = importe_aclaraciones_sin_abono + importe_aclaraciones_sin_abono` | 🔴 MONEY/aritmética financiera |
| L546 | FÓRMULA | `LET numero_aclaraciones_sin_abono = numero_aclaraciones_sin_abono + numero_aclaraciones_sin_abono_te` |  |
| L561 | FÓRMULA | `LET importe_aclaraciones_sin_abono = importe_aclaraciones_sin_abono + importe_aclaraciones_sin_abono` | 🔴 MONEY/aritmética financiera |
| L562 | FÓRMULA | `LET numero_aclaraciones_sin_abono = numero_aclaraciones_sin_abono + numero_aclaraciones_sin_abono_te` |  |
| L577 | FÓRMULA | `LET importe_aclaraciones_sin_abono = importe_aclaraciones_sin_abono + importe_aclaraciones_sin_abono` | 🔴 MONEY/aritmética financiera |
| | *…9 más…* | | |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `consulta` | ACCION | consulta / lee | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `aclaraciones` | ENTIDAD | aclaraciones (proceso de disputas/reclamaciones de cliente) | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `producto` | ENTIDAD | producto | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `cliente` | ENTIDAD | cliente | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |

---

## `sp_consulta_aclaraciones_producto_cliente_2`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_consulta_aclaraciones_producto_cliente_2.sql` |
| **LOC (1er CREATE)** | 145 |
| **Callgraph** | ✅ fan_in=0 / fan_out=9 |
| **Deps concatenadas** | 8 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "consulta aclaraciones, producto y cliente" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=4 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=1 / 6 términos |

### Firma

```sql
CREATE PROCEDURE sp_consulta_aclaraciones_producto_cliente_2(
  p_tipo_consulta              INTEGER
  p_id_producto                INTEGER
  p_tipo_producto              INTEGER
  p_num_cliente                INTEGER
  p_pky_rango_importe          INTEGER
) RETURNING CHAR(5) AS s_codRet,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_tipo_consulta` | `INTEGER` | `consulta`=consulta / lee | ✅ CÓDIGO |
| `p_id_producto` | `INTEGER` | `producto`=producto | ✅ CÓDIGO |
| `p_tipo_producto` | `INTEGER` | `producto`=producto | ✅ CÓDIGO |
| `p_num_cliente` | `INTEGER` | `cliente`=cliente | ✅ CÓDIGO |
| `p_pky_rango_importe` | `INTEGER` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cod_retorno` | `CHAR(5)` | L11 |
| `monto_total_aclaraciones_producto_cliente` | `MONEY` | L12 |
| `numero_aclaraciones_con_abono` | `INTEGER` | L13 |
| `numero_aclaraciones_sin_abono` | `INTEGER` | L14 |
| `importe_aclaraciones_con_abono` | `MONEY` | L15 |
| `importe_aclaraciones_sin_abono` | `MONEY` | L16 |
| `total_numero_aclaraciones` | `INTEGER` | L17 |
| `total_importe_aclaraciones` | `MONEY` | L18 |
| `iSqlErr` | `INTEGER` | L19 |
| `uno` | `INTEGER` | L20 |
| `anio` | `INTEGER` | L21 |
| `cero` | `INTEGER` | L22 |
| `resolucion_con_abono_temporal` | `INTEGER` | L23 |
| `resolucion_sin_abono_temporal` | `INTEGER` | L24 |
| `estatus_aclaracion_ingresada` | `INTEGER` | L25 |
| `estatus_aclaracion_con_dic_sin_digi` | `INTEGER` | L26 |
| `estatus_aclaracion_finalizada` | `INTEGER` | L27 |
| `estatus_corp_gral_pred_aceptado` | `INTEGER` | L28 |
| `estatus_corp_gral_cierre_prev_no_real` | `INTEGER` | L29 |
| `estatus_corp_gral_cierre_prev` | `INTEGER` | L30 |
| `estatus_corp_analisis` | `INTEGER` | L31 |
| `estatus_corp_por_abonar` | `INTEGER` | L32 |
| `estatus_corp_dictamen_acep` | `INTEGER` | L33 |
| `aclaracion_cuenta_movil` | `INTEGER` | L34 |
| `estatus_dictamen_abonada_sin_autor` | `INTEGER` | L35 |
| *…8 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `acl_estatus_aclaracion` | `bdiaclaracion` | no | SELECT | L60 |
| `acl_estatus_corporativo` | `bdiaclaracion` | no | SELECT | L61 |
| `acl_resolucion` | `bdiaclaracion` | no | SELECT | L63 |
| `acl_cat_tipo_aclaracion` | `bdiaclaracion` | no | SELECT | L72 |
| `acl_rango_importe` | `bdiaclaracion` | no | SELECT | L98 |
| `acl_aclaracion` | `bdiaclaracion` | no | SELECT | L100 |
| `statistics` | `bdiaclaracion` | no | UPDATE | L112 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L48 | FÓRMULA | `LET fechaPasada=TO_CHAR(last_year-1) \|\| '-' \|\| TO_CHAR(monthSys)\|\| '-' \|\| TO_CHAR(daySys);` |  |
| L60 | FÓRMULA | `LET estatus_aclaracion_con_dic_sin_digi = (SELECT {+INDEX(bdiaclaracion:"informix".acl_estatus_aclar` |  |
| L61 | FÓRMULA | `LET estatus_corp_gral_cierre_prev = (SELECT {+INDEX(bdiaclaracion:"informix".acl_estatus_corporativo` |  |
| L62 | FÓRMULA | `LET estatus_corp_gral_cierre_prev_no_real = (SELECT {+INDEX(bdiaclaracion:"informix".acl_estatus_cor` |  |
| L63 | FÓRMULA | `LET resolucion_con_abono_temporal = (SELECT {+INDEX(bdiaclaracion:"informix".acl_resolucion idx_acl_` | 🔴 MONEY/aritmética financiera |
| L64 | FÓRMULA | `LET resolucion_sin_abono_temporal = (SELECT {+INDEX(bdiaclaracion:"informix".acl_resolucion idx_acl_` | 🔴 MONEY/aritmética financiera |
| L65 | FÓRMULA | `LET resolucion_con_abono  = (SELECT {+INDEX(bdiaclaracion:"informix".acl_resolucion idx_acl_resoluci` | 🔴 MONEY/aritmética financiera |
| L66 | FÓRMULA | `LET estatus_aclaracion_ingresada = (SELECT {+INDEX(bdiaclaracion:"informix".acl_estatus_aclaracion i` |  |
| L67 | FÓRMULA | `LET estatus_corp_analisis = (SELECT {+INDEX(bdiaclaracion:"informix".acl_estatus_corporativo idx_acl` |  |
| L68 | FÓRMULA | `LET estatus_corp_predictaminada = (SELECT {+INDEX(bdiaclaracion:"informix".acl_estatus_corporativo i` |  |
| L69 | FÓRMULA | `LET estatus_corp_por_abonar = (SELECT {+INDEX(bdiaclaracion:"informix".acl_estatus_corporativo idx_a` |  |
| L70 | FÓRMULA | `LET estatus_aclaracion_finalizada = (SELECT {+INDEX(bdiaclaracion:"informix".acl_estatus_aclaracion ` |  |
| L71 | FÓRMULA | `LET estatus_corp_dictamen_acep = (SELECT {+INDEX(bdiaclaracion:"informix".acl_estatus_corporativo id` |  |
| L73 | FÓRMULA | `LET estatus_dictamen_abonada_sin_autor = (SELECT {+INDEX(bdiaclaracion:"informix".acl_estatus_corpor` |  |
| L100 | FÓRMULA | `LET monto_total_aclaraciones_producto_cliente = (SELECT NVL(SUM({+INDEX(bdiaclaracion:"informix".acl` | 🔴 MONEY/aritmética financiera |
| L122 | FÓRMULA | `LET numero_aclaraciones_con_abono = (SELECT COUNT (*) FROM tblAclaracionesAbono);` |  |
| L124 | FÓRMULA | `LET numero_aclaraciones_sin_abono = (SELECT COUNT (*) FROM tblAclaracionesSinAbono);` |  |
| L125 | FÓRMULA | `LET total_numero_aclaraciones = (numero_aclaraciones_sin_abono + numero_aclaraciones_con_abono);` |  |
| L126 | FÓRMULA | `LET total_importe_aclaraciones = (importe_aclaraciones_sin_abono + importe_aclaraciones_con_abono);` | 🔴 MONEY/aritmética financiera |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `consulta` | ACCION | consulta / lee | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `aclaraciones` | ENTIDAD | aclaraciones (proceso de disputas/reclamaciones de cliente) | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `producto` | ENTIDAD | producto | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `cliente` | ENTIDAD | cliente | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `?_2` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_2` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_consulta_cargo_recurrente`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_consulta_cargo_recurrente.sql` |
| **LOC (1er CREATE)** | 54 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "consulta cargo" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=1 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_consulta_cargo_recurrente(
  p_num_tarjeta                CHAR(16)
  p_folio_suc                  char(15)
) RETURNING VARCHAR (4) AS cCodRet, --Salida de codigo de retorno
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_num_tarjeta` | `CHAR(16)` | — | — |
| `p_folio_suc` | `char(15)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `ind_cargo_rec` | `CHAR(2)` | L5 |
| `iSqlErr` | `INTEGER` | L6 |
| `cCodRet` | `CHAR(3)` | L7 |
| `indicador_recurrente` | `CHAR (2)` | L8 |
| `esBinCredito` | `INTEGER` | L9 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `bines` | `intercard` | ⚠️ sí | SELECT | L23 |
| `movimiento` | `intercard` | ⚠️ sí | SELECT | L25 |
| `movimientohistorico` | `intercard` | ⚠️ sí | SELECT | L37 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `consulta` | ACCION | consulta / lee | 🔵 CONVENCIÓN | nombre_sp |
| `cargo` | ENTIDAD | cargo / débito | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `rec` | ACCION | recepción / recibe | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `?urrente` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?urrente` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_consulta_cat_motivo_bloqueo_deb`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_consulta_cat_motivo_bloqueo_deb.sql` |
| **LOC (1er CREATE)** | 52 |
| **Callgraph** | ✅ fan_in=0 / fan_out=2 |
| **Deps concatenadas** | 12 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "consulta catálogo y motivo (débito)" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=5 · INFERIDO=0 · SINTÉTICO=0 / 6 términos |

### Firma

```sql
CREATE PROCEDURE sp_consulta_cat_motivo_bloqueo_deb(
) RETURNING CHAR(2) AS clave,VARCHAR(50) AS descripcion
```

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `local_clave` | `CHAR(2)` | L5 |
| `local_descripcion` | `VARCHAR(50)` | L6 |
| `iSqlErr` | `INTEGER` | L7 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sc_bloqueo` | `bdicheq` | ⚠️ sí | SELECT | L30 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `consulta` | ACCION | consulta / lee | 🔵 CONVENCIÓN | nombre_sp |
| `cat` | ENTIDAD | catálogo | 🔵 CONVENCIÓN | nombre_sp |
| `motivo` | ENTIDAD | motivo / causa | 🔵 CONVENCIÓN | nombre_sp |
| `bloqueo` | ACCION | bloquea cuenta | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `deb` | MODIF | débito | 🔵 CONVENCIÓN | nombre_sp |

---

## `sp_consulta_cat_tipo_bloqueo_crd`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_consulta_cat_tipo_bloqueo_crd.sql` |
| **LOC (1er CREATE)** | 46 |
| **Callgraph** | ✅ fan_in=0 / fan_out=2 |
| **Deps concatenadas** | 9 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "consulta catálogo y crédito (tipo de)" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=5 · INFERIDO=1 · SINTÉTICO=0 / 6 términos |

### Firma

```sql
CREATE PROCEDURE sp_consulta_cat_tipo_bloqueo_crd(
) RETURNING INTEGER AS clave,VARCHAR(60) AS descripcion
```

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `local_clave` | `INTEGER` | L5 |
| `local_descripcion` | `VARCHAR(60)` | L6 |
| `iSqlErr` | `INTEGER` | L7 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sd_bloqueoscuenta` | `bdicred` | ⚠️ sí | SELECT | L25 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `consulta` | ACCION | consulta / lee | 🔵 CONVENCIÓN | nombre_sp |
| `cat` | ENTIDAD | catálogo | 🔵 CONVENCIÓN | nombre_sp |
| `tipo` | MODIF | tipo de | 🔵 CONVENCIÓN | nombre_sp |
| `bloqueo` | ACCION | bloquea cuenta | 🔵 CONVENCIÓN | nombre_sp |
| `crd` | ENTIDAD | crédito (abreviación) | 🟡 INFERIDO | nombre_sp |

---

## `sp_consulta_cat_tipo_bloqueo_deb`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_consulta_cat_tipo_bloqueo_deb.sql` |
| **LOC (1er CREATE)** | 50 |
| **Callgraph** | ✅ fan_in=0 / fan_out=2 |
| **Deps concatenadas** | 10 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "consulta catálogo (tipo de, débito)" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=6 · INFERIDO=0 · SINTÉTICO=0 / 6 términos |

### Firma

```sql
CREATE PROCEDURE sp_consulta_cat_tipo_bloqueo_deb(
) RETURNING INTEGER AS clave,VARCHAR(60) AS descripcion
```

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `local_clave` | `INTEGER` | L5 |
| `local_descripcion` | `VARCHAR(60)` | L6 |
| `iSqlErr` | `INTEGER` | L7 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sc_opcionbloqueo` | `bdicheq` | ⚠️ sí | SELECT | L29 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `consulta` | ACCION | consulta / lee | 🔵 CONVENCIÓN | nombre_sp |
| `cat` | ENTIDAD | catálogo | 🔵 CONVENCIÓN | nombre_sp |
| `tipo` | MODIF | tipo de | 🔵 CONVENCIÓN | nombre_sp |
| `bloqueo` | ACCION | bloquea cuenta | 🔵 CONVENCIÓN | nombre_sp |
| `deb` | MODIF | débito | 🔵 CONVENCIÓN | nombre_sp |

---

## `sp_consulta_concentrado_robo_identidad`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_consulta_concentrado_robo_identidad.sql` |
| **LOC (1er CREATE)** | 373 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 5 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "consulta identificador" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=5 · CONVENCIÓN=0 · INFERIDO=0 · SINTÉTICO=3 / 8 términos |

### Firma

```sql
CREATE PROCEDURE sp_consulta_concentrado_robo_identidad(
  folio_csuac_sp               VARCHAR(30)
  numero_cuenta_sp             VARCHAR(30)
  numero_cliente_sp            VARCHAR(30)
  tipo_producto_sp             CHAR(2)
  producto_sp                  integer
) RETURNING CHAR(6)     as s_codRet,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `folio_csuac_sp` | `VARCHAR(30)` | `sp`=stored procedure | ✅ CÓDIGO |
| `numero_cuenta_sp` | `VARCHAR(30)` | `sp`=stored procedure | ✅ CÓDIGO |
| `numero_cliente_sp` | `VARCHAR(30)` | `sp`=stored procedure | ✅ CÓDIGO |
| `tipo_producto_sp` | `CHAR(2)` | `sp`=stored procedure | ✅ CÓDIGO |
| `producto_sp` | `integer` | `sp`=stored procedure | ✅ CÓDIGO |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cod_retorno` | `CHAR(5)` | L9 |
| `p_area` | `CHAR(500)` | L10 |
| `p_fky_accion_e` | `CHAR(5)` | L11 |
| `nombre_persona_reclama_p` | `CHAR (50)` | L12 |
| `fecha_nac_p` | `CHAR (40)` | L13 |
| `genero_p` | `CHAR (40)` | L14 |
| `curp_p` | `CHAR (40)` | L15 |
| `direccion_p` | `CHAR (40)` | L16 |
| `estado_p` | `CHAR (40)` | L17 |
| `municipio_p` | `CHAR (40)` | L18 |
| `codigo_postal_p` | `CHAR (40)` | L19 |
| `fechacaptura_p` | `CHAR (40)` | L20 |
| `importereclamado_p` | `CHAR (40)` | L21 |
| `numero_cuenta_p` | `CHAR (40)` | L22 |
| `descripcion_p` | `CHAR (40)` | L23 |
| `predictamen_p` | `CHAR (300)` | L24 |
| `oficio_seguimiento_legal_p` | `CHAR (30)` | L25 |
| `monto_quebrantado_p` | `CHAR (30)` | L26 |
| `monto_recuperado_p` | `CHAR (30)` | L27 |
| `comentarioBitacora_p` | `CHAR (300)` | L28 |
| `comentarioBitacoraNvo_p` | `CHAR (300)` | L29 |
| `fecha_apertura_p` | `CHAR (20)` | L30 |
| `sucursal_origen_cta_p` | `CHAR (40)` | L31 |
| `lugar_apertura_p` | `CHAR (40)` | L32 |
| `nombramiento_p` | `CHAR (40)` | L33 |
| *…16 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_cliente` | `bdinteg` | ⚠️ sí | SELECT | L113 |
| `acl_concentrado_robo_identidad` | `bdiaclaracion` | no | SELECT | L157 |
| `sc_maenoc` | `bdicheq` | ⚠️ sí | SELECT | L170 |
| `acl_entrada_bitacora` | `bdiaclaracion` | no | SELECT | L318 |
| `mnsjr_trx_online` | `bdimnsj` | ⚠️ sí | SELECT | L325 |
| `mnsjr_trx_online_his` | `bdimnsj` | ⚠️ sí | SELECT | L334 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L57 | FÓRMULA | `let idEmail='ACL_SMS'; --Modificar para agregar el ID de notificacion de correo Electronico` | 🔴 MONEY/aritmética financiera |
| L320 | FÓRMULA | `let comentarioBitacora_p=trim(comentarioBitacora_p)\|\|'--'\|\|trim(nvl(comentarioBitacoraNvo_p,''))` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `consulta` | ACCION | consulta / lee | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `con` | ACCION | consulta | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?centrado_robo_` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `id` | ENTIDAD | identificador (de) | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?ent` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `id` | ENTIDAD | identificador (de) | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?ad` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?centrado_robo_`, `?ent`, `?ad` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_consulta_datos_sucursal_numero`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_consulta_datos_sucursal_numero.sql` |
| **LOC (1er CREATE)** | 52 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 2 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "consulta datos, sucursal y número" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=4 · INFERIDO=0 · SINTÉTICO=1 / 6 términos |

### Firma

```sql
CREATE PROCEDURE sp_consulta_datos_sucursal_numero(
  p_numeroSuc                  CHAR(5)
  p_sNumeroEmpresa             CHAR(3)
) RETURNING CHAR(5) AS sucursal, CHAR(40) AS nombreSucursal, CHAR(30) AS nombreEstado, CHAR(60) AS nombreCiudad
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_numeroSuc` | `CHAR(5)` | `num`=número (de) | 🔵 CONVENCIÓN |
| `p_sNumeroEmpresa` | `CHAR(3)` | `num`=número (de) | 🔵 CONVENCIÓN |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `resultado_numeroSucursal` | `CHAR(5)` | L6 |
| `resultado_nombreSucursal` | `CHAR(40)` | L7 |
| `resultado_nombreEstado` | `CHAR(30)` | L8 |
| `resultado_nombreCiudad` | `CHAR(60)` | L9 |
| `iSqlErr` | `INTEGER` | L10 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_sucursales` | `bdinteg` | ⚠️ sí | SELECT | L34 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `consulta` | ACCION | consulta / lee | 🔵 CONVENCIÓN | nombre_sp |
| `datos` | ENTIDAD | datos | 🔵 CONVENCIÓN | nombre_sp |
| `sucursal` | ENTIDAD | sucursal | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `num` | ENTIDAD | número (de) | 🔵 CONVENCIÓN | nombre_sp |
| `?ero` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?ero` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_consulta_direccion_cte`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_consulta_direccion_cte.sql` |
| **LOC (1er CREATE)** | 88 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 9 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "consulta dirección y cliente" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=4 · INFERIDO=0 · SINTÉTICO=0 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_consulta_direccion_cte(
  p_sNumeroCliente             CHAR(20)
) RETURNING CHAR(3) AS codigo, CHAR(100) AS calle,  CHAR(100) AS colonia,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_sNumeroCliente` | `CHAR(20)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `resultado_codigo` | `CHAR(3)` | L8 |
| `resultado_calle` | `CHAR(100)` | L9 |
| `resultado_colonia` | `CHAR(100)` | L10 |
| `resultado_municipio` | `CHAR(100)` | L11 |
| `resultado_estado` | `CHAR(100)` | L12 |
| `resultado_ciudad` | `CHAR(100)` | L13 |
| `resultado_cp` | `CHAR(10)` | L14 |
| `iSqlErr` | `INTEGER` | L16 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_cliente` | `bdinteg` | ⚠️ sí | SELECT | L64 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `consulta` | ACCION | consulta / lee | 🔵 CONVENCIÓN | nombre_sp |
| `direccion` | ENTIDAD | dirección | 🔵 CONVENCIÓN | nombre_sp |
| `cte` | ENTIDAD | cliente | 🔵 CONVENCIÓN | nombre_sp |

---

## `sp_consulta_estatus_cuenta`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_consulta_estatus_cuenta.sql` |
| **LOC (1er CREATE)** | 66 |
| **Callgraph** | ✅ fan_in=0 / fan_out=2 |
| **Deps concatenadas** | 8 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "consulta estatus y cuenta" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=0 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_consulta_estatus_cuenta(
  p_cuenta                     CHAR(20)
  p_cliente                    CHAR(9)
  p_producto                   SMALLINT
) RETURNING CHAR(50) AS estatus_cta
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_cuenta` | `CHAR(20)` | `cuenta`=cuenta | ✅ CÓDIGO |
| `p_cliente` | `CHAR(9)` | — | — |
| `p_producto` | `SMALLINT` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `iSqlErr` | `INTEGER` | L5 |
| `estatus_cuenta` | `NVARCHAR(50)` | L7 |
| `producto_debito` | `SMALLINT` | L9 |
| `producto_credito` | `SMALLINT` | L10 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sd_maecred` | `bdicred` | ⚠️ sí | SELECT | L33 |
| `sc_maechq` | `bdicheq` | ⚠️ sí | SELECT | L42 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `consulta` | ACCION | consulta / lee | 🔵 CONVENCIÓN | nombre_sp |
| `estatus` | ENTIDAD | estatus | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `cuenta` | ENTIDAD | cuenta | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |

---

## `sp_consulta_estatus_cuenta_cred`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_consulta_estatus_cuenta_cred.sql` |
| **LOC (1er CREATE)** | 130 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 15 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "consulta estatus, cuenta y crédito" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=3 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=0 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_consulta_estatus_cuenta_cred(
  p_tipo                       CHAR(1)
  p_cuenta                     char(30)
  p_cliente                    integer
) RETURNING char(50) AS valor_retorno_s
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_tipo` | `CHAR(1)` | — | — |
| `p_cuenta` | `char(30)` | `cuenta`=cuenta | ✅ CÓDIGO |
| `p_cliente` | `integer` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `iSqlErr` | `INTEGER` | L5 |
| `cod_retorno` | `CHAR(5)` | L6 |
| `p_estatus_cuenta` | `CHAR(30)` | L7 |
| `fecha_alta_p` | `CHAR(30)` | L8 |
| `consulta_est_cta` | `CHAR(1)` | L9 |
| `consulta_est_fech_alta` | `CHAR(30)` | L10 |
| `valor_retorno` | `CHAR(30)` | L11 |
| `v_cod_estatus_cuenta` | `CHAR(2)` | L12 |
| `v_cuenta_activa` | `CHAR(2)` | L13 |
| `vCveExistente` | `INTEGER` | L14 |
| `vStatusCred` | `CHAR(2)` | L15 |
| `cCausa` | `CHAR(2)` | L16 |
| `bin_tdc_coppel_mc` | `CHAR(6)` | L17 |
| `v_num_tarjeta` | `CHAR(16)` | L18 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `binproducto` | `intercard` | ⚠️ sí | SELECT | L53 |
| `tarjetacuenta` | `intercard` | ⚠️ sí | SELECT | L56 |
| `si_param_tdc_coppelmc` | `bdinteg` | ⚠️ sí | SELECT | L58 |
| `sd_maecred` | `bdicred` | ⚠️ sí | SELECT | L68 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L80 | VALIDACIÓN_NULL | `IF (vCveExistente = 0 AND cCausa IS NOT NULL) OR (vCveExistente > 0 AND cCausa IS NULL) THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `consulta` | ACCION | consulta / lee | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `estatus` | ENTIDAD | estatus | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `cuenta` | ENTIDAD | cuenta | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `cred` | ENTIDAD | crédito | 🔵 CONVENCIÓN | nombre_sp |

---

## `sp_consulta_estatus_cuenta_cred_otros`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_consulta_estatus_cuenta_cred_otros.sql` |
| **LOC (1er CREATE)** | 73 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 1 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "consulta estatus, cuenta, crédito y OS — Originación de Solicitudes" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=3 · CONVENCIÓN=2 · INFERIDO=1 · SINTÉTICO=1 / 7 términos |

### Firma

```sql
CREATE PROCEDURE sp_consulta_estatus_cuenta_cred_otros(
  p_tipo                       CHAR(1)
  p_cuenta                     char(30)
  p_cliente                    integer
) RETURNING char(50) AS valor_retorno_s
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_tipo` | `CHAR(1)` | — | — |
| `p_cuenta` | `char(30)` | `cuenta`=cuenta | ✅ CÓDIGO |
| `p_cliente` | `integer` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `iSqlErr` | `INTEGER` | L5 |
| `cod_retorno` | `CHAR(5)` | L6 |
| `p_estatus_cuenta` | `CHAR(30)` | L7 |
| `fecha_alta_p` | `CHAR(30)` | L8 |
| `consulta_est_cta` | `CHAR(1)` | L9 |
| `consulta_est_fech_alta` | `CHAR(30)` | L10 |
| `valor_retorno` | `CHAR(30)` | L11 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sd_maecredcrd` | `bdicred` | ⚠️ sí | SELECT | L35 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `consulta` | ACCION | consulta / lee | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `estatus` | ENTIDAD | estatus | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `cuenta` | ENTIDAD | cuenta | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `cred` | ENTIDAD | crédito | 🔵 CONVENCIÓN | nombre_sp |
| `?_otr` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `os` | ENTIDAD | OS — Originación de Solicitudes / subsistema de ofertas (sp_ | 🟡 INFERIDO | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_otr` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_consulta_estatus_cuenta_inv_crec`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_consulta_estatus_cuenta_inv_crec.sql` |
| **LOC (1er CREATE)** | 74 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 3 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "consulta estatus, cuenta y crédito" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=3 · CONVENCIÓN=1 · INFERIDO=1 · SINTÉTICO=2 / 7 términos |

### Firma

```sql
CREATE PROCEDURE sp_consulta_estatus_cuenta_inv_crec(
  p_tipo                       CHAR(20)
  p_cuenta                     CHAR(20)
  p_cliente                    integer
) RETURNING char(50) AS estatus_cta
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_tipo` | `CHAR(20)` | — | — |
| `p_cuenta` | `CHAR(20)` | `cuenta`=cuenta | ✅ CÓDIGO |
| `p_cliente` | `integer` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `iSqlErr` | `INTEGER` | L5 |
| `cod_retorno` | `CHAR(5)` | L6 |
| `estatus_cuenta` | `CHAR(50)` | L7 |
| `secuencia_p` | `CHAR(50)` | L8 |
| `fecha_alta_p` | `CHAR(50)` | L9 |
| `estCta` | `CHAR(50)` | L10 |
| `consulta_est_cta` | `CHAR(1)` | L11 |
| `consulta_est_fech_alta` | `CHAR(1)` | L12 |
| `valor_retorno` | `CHAR(20)` | L13 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sc_maechq` | `bdicheq` | ⚠️ sí | SELECT | L39 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `consulta` | ACCION | consulta / lee | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `estatus` | ENTIDAD | estatus | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `cuenta` | ENTIDAD | cuenta | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `?_inv_` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `cre` | ENTIDAD | crédito | 🟡 INFERIDO | nombre_sp |
| `?c` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_inv_`, `?c` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_consulta_estatus_cuenta_pagare`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_consulta_estatus_cuenta_pagare.sql` |
| **LOC (1er CREATE)** | 79 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 2 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "consulta estatus, cuenta y pagaré" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=4 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=0 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_consulta_estatus_cuenta_pagare(
  p_tipo                       CHAR(20)
  p_cuenta                     CHAR(20)
  p_cliente                    integer
) RETURNING CHAR(50) AS estatus_cta
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_tipo` | `CHAR(20)` | — | — |
| `p_cuenta` | `CHAR(20)` | `cuenta`=cuenta | ✅ CÓDIGO |
| `p_cliente` | `integer` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `iSqlErr` | `INTEGER` | L5 |
| `cod_retorno` | `CHAR(5)` | L7 |
| `estatus_cuenta` | `CHAR(50)` | L8 |
| `secuencia_p` | `CHAR(50)` | L9 |
| `fecha_alta_p` | `CHAR(50)` | L10 |
| `estCta` | `CHAR(50)` | L11 |
| `consulta_est_cta` | `CHAR(1)` | L12 |
| `consulta_est_fech_alta` | `CHAR(1)` | L13 |
| `valor_retorno` | `CHAR(20)` | L14 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sv_maeinv` | `bdinvers` | ⚠️ sí | SELECT | L38 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `consulta` | ACCION | consulta / lee | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `estatus` | ENTIDAD | estatus | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `cuenta` | ENTIDAD | cuenta | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `pagare` | ENTIDAD | pagaré | ✅ CÓDIGO | nombre_sp, texto_cuerpo |

---

## `sp_consulta_estatus_cuenta_transfer`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_consulta_estatus_cuenta_transfer.sql` |
| **LOC (1er CREATE)** | 76 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 4 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "consulta estatus, cuenta y transferencia" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=3 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=0 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_consulta_estatus_cuenta_transfer(
  p_tipo                       CHAR(20)
  p_cuenta                     CHAR(20)
  p_cliente                    integer
) RETURNING char(50) AS estatus_cta
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_tipo` | `CHAR(20)` | — | — |
| `p_cuenta` | `CHAR(20)` | `cuenta`=cuenta | ✅ CÓDIGO |
| `p_cliente` | `integer` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `iSqlErr` | `INTEGER` | L5 |
| `cod_retorno` | `CHAR(5)` | L7 |
| `estatus_cuenta` | `CHAR(50)` | L8 |
| `secuencia_p` | `CHAR(50)` | L9 |
| `fecha_alta_p` | `CHAR(50)` | L10 |
| `estCta` | `CHAR(50)` | L11 |
| `consulta_est_cta` | `CHAR(1)` | L12 |
| `consulta_est_fech_alta` | `CHAR(1)` | L13 |
| `valor_retorno` | `CHAR(20)` | L14 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tf_maecte` | `bditransfer` | ⚠️ sí | SELECT | L42 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `consulta` | ACCION | consulta / lee | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `estatus` | ENTIDAD | estatus | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `cuenta` | ENTIDAD | cuenta | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `transfer` | ENTIDAD | transferencia (forma larga de 'trans') | 🔵 CONVENCIÓN | nombre_sp |

---

## `sp_consulta_hash`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_consulta_hash.sql` |
| **LOC (1er CREATE)** | 45 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 14 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "consulta" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=1 / 3 términos |

### Firma

```sql
CREATE PROCEDURE sp_consulta_hash(
) RETURNING CHAR(5) AS codret,
```

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(5)` | L5 |
| `iSqlErr` | `INTEGER` | L6 |
| `cHash` | `CHAR(100)` | L7 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `acl_validacion_componente` | `bdiaclaracion` | no | SELECT | L30 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L9 | CÓDIGO_RETORNO | `LET cCodRet = '00000';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `consulta` | ACCION | consulta / lee | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?_hash` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_hash` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_consulta_prod_sv`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_consulta_prod_sv.sql` |
| **LOC (1er CREATE)** | 72 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "consulta producto y sv — supervisión/servicio" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=2 · INFERIDO=1 · SINTÉTICO=1 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_consulta_prod_sv(
  pProducto                    CHAR(6)
) RETURNING CHAR(5) AS codRet,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pProducto` | `CHAR(6)` | `prod`=producto | 🟡 INFERIDO |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(5)` | L9 |
| `iSqlErr` | `INTEGER` | L10 |
| `cCodRetSp` | `CHAR(6)` | L11 |
| `iCodRetSp` | `INTEGER` | L12 |
| `cNumeroProducto` | `CHAR(6)` | L14 |
| `cNombreProducto` | `CHAR(60)` | L15 |
| `cNumeroCuenta` | `CHAR(30)` | L16 |
| `cNumeroTarjeta` | `CHAR(30)` | L17 |
| `cStatusTarjeta` | `CHAR(3)` | L18 |
| `cNumeroCuentaInversion` | `CHAR(30)` | L20 |
| `cTelefonoTransfer` | `CHAR(30)` | L21 |
| `cClienteTransfer` | `CHAR(30)` | L22 |
| `iRecuperacion` | `INTEGER` | L23 |
| `cEmpresa` | `CHAR(3)` | L24 |
| `iTipoProducto` | `INTEGER` | L25 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `acl_tipo_producto` | `bdiaclaracion` | no | SELECT | L63 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L27 | CÓDIGO_RETORNO | `LET cCodRet = '00000';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `consulta` | ACCION | consulta / lee | 🔵 CONVENCIÓN | nombre_sp |
| `prod` | ENTIDAD | producto | 🟡 INFERIDO | nombre_sp |
| `sv` | ENTIDAD | sv — supervisión/servicio (abreviación — bdiaclaracion) | 🔴 SINTÉTICO | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `sv` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_consulta_recuperacion`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_consulta_recuperacion.sql` |
| **LOC (1er CREATE)** | 60 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "consulta" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=0 / 3 términos |

### Firma

```sql
CREATE PROCEDURE sp_consulta_recuperacion(
  folio                        VARCHAR(11)
) RETURNING MONEY AS AbonoTot, MONEY AS AbonoRecup, MONEY AS ComisionTot, MONEY AS ComisionRecup,MONEY AS IvaTot, MONEY AS IvaRecup
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `folio` | `VARCHAR(11)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `v_AbonoTot` | `MONEY` | L7 |
| `v_AbonoRecup` | `MONEY` | L8 |
| `v_ComisionTot` | `MONEY` | L9 |
| `v_ComisionRecup` | `MONEY` | L10 |
| `v_IvaTot` | `MONEY` | L11 |
| `v_IvaRecup` | `MONEY` | L12 |
| `v_ComisionA` | `MONEY` | L15 |
| `v_IvaA` | `MONEY` | L16 |
| `v_Porcentaje` | `INTEGER` | L17 |
| `v_Ciento` | `INTEGER` | L18 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `acl_recuperacion_saldos` | `bdiaclaracion` | no | SELECT | L31 |
| `acl_recuperacion_saldos` | `bdiaclaracion` | no | UPDATE | L43 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L41 | FÓRMULA | `let v_ComisionA = (v_ComisionTot * v_Ciento) / v_Porcentaje;` |  |
| L42 | FÓRMULA | `leT v_IvaA = v_ComisionTot - v_ComisionA;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `consulta` | ACCION | consulta / lee | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `recuperacion` | ACCION | recuperación (cobranza) | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |

---

## `sp_consulta_saldo_cuentas`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_consulta_saldo_cuentas.sql` |
| **LOC (1er CREATE)** | 105 |
| **Callgraph** | ✅ fan_in=0 / fan_out=8 |
| **Deps concatenadas** | 7 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "consulta saldo y cuentas" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=4 · INFERIDO=0 · SINTÉTICO=0 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_consulta_saldo_cuentas(
  pcuenta                      CHAR(16)
  vTipoProducto                CHAR(1)
) RETURNING CHAR(5), numeric
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pcuenta` | `CHAR(16)` | — | — |
| `vTipoProducto` | `CHAR(1)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(5)` | L4 |
| `sql_err` | `INTEGER` | L5 |
| `isam_err` | `INTEGER` | L6 |
| `CMensaje` | `CHAR(80)` | L7 |
| `vFolioCsuac` | `CHAR(16)` | L9 |
| `vsaldo` | `numeric` | L10 |
| `vstatuscta` | `CHAR(1)` | L12 |
| `cCodRetConsul` | `CHAR(3)` | L13 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sd_maesdos` | `bdicred` | ⚠️ sí | SELECT | L50 |
| `sd_maesdoscrd` | `bdicred` | ⚠️ sí | SELECT | L55 |
| `sv_maeinv` | `bdinvers` | ⚠️ sí | SELECT | L70 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `cons_saldo` | `bdicheq` | ⚠️ sí | L65 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L17 | CÓDIGO_RETORNO | `LET cCodRet      			= '00000';` |  |
| L52 | VALIDACIÓN_NULL | `IF vsaldo IS NULL OR vsaldo ='' THEN` |  |
| L56 | VALIDACIÓN_NULL | `IF vsaldo IS NULL OR vsaldo ='' THEN` |  |
| L67 | VALIDACIÓN_NULL | `IF vsaldo IS NULL OR vsaldo ='' THEN` |  |
| L71 | CÓDIGO_RETORNO | `LET cCodRet = '00000';` |  |
| L72 | VALIDACIÓN_NULL | `IF vsaldo IS NULL OR vsaldo ='' THEN` |  |
| L74 | CÓDIGO_RETORNO | `LET cCodRet = '00000';` |  |
| L78 | CÓDIGO_RETORNO | `LET cCodRet = '00000';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `consulta` | ACCION | consulta / lee | 🔵 CONVENCIÓN | nombre_sp |
| `saldo` | ENTIDAD | saldo | 🔵 CONVENCIÓN | nombre_sp |
| `cuentas` | ENTIDAD | cuentas (plural) | 🔵 CONVENCIÓN | nombre_sp |

---

## `sp_consulta_secuencia_eglobal_atm`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_consulta_secuencia_eglobal_atm.sql` |
| **LOC (1er CREATE)** | 31 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "consulta secuencia y cajero automático" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=1 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_consulta_secuencia_eglobal_atm(
) RETURNING CHAR(10) AS consecutivo
```

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `iSqlErr` | `INTEGER` | L5 |
| `secuencia` | `CHAR(10)` | L6 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `systables` | `bdiaclaracion` | no | SELECT | L25 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `consulta` | ACCION | consulta / lee | 🔵 CONVENCIÓN | nombre_sp |
| `secuencia` | ENTIDAD | secuencia | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `?_eglobal_` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `atm` | ENTIDAD | cajero automático (ATM) | 🔵 CONVENCIÓN | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_eglobal_` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_consulta_tipo_movimiento`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_consulta_tipo_movimiento.sql` |
| **LOC (1er CREATE)** | 71 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "consulta movimiento (tipo de)" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=0 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_consulta_tipo_movimiento(
  p_FolioSuc                   CHAR(20)
  p_NumTarjeta                 CHAR(20)
  p_OrigenEvento               INTEGER
) RETURNING CHAR(1) AS resultado_origen,VARCHAR(2) AS modo_entrada
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_FolioSuc` | `CHAR(20)` | — | — |
| `p_NumTarjeta` | `CHAR(20)` | — | — |
| `p_OrigenEvento` | `INTEGER` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `resultado_origen` | `CHAR(1)` | L4 |
| `iSqlErr` | `INTEGER` | L5 |
| `nombre_origen` | `CHAR(50)` | L6 |
| `imodo_entrada` | `VARCHAR(2)` | L7 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `acl_origen_evento` | `bdiaclaracion` | no | SELECT | L31 |
| `movimiento` | `intercard` | ⚠️ sí | SELECT | L38 |
| `movimientohistorico` | `intercard` | ⚠️ sí | SELECT | L45 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L42 | VALIDACIÓN_NULL | `IF ( resultado_origen IS NULL OR resultado_origen='') THEN` |  |
| L56 | VALIDACIÓN_NULL | `IF ( resultado_origen IS NULL OR resultado_origen='') THEN` |  |
| L60 | VALIDACIÓN_NULL | `IF ( imodo_entrada IS NULL OR imodo_entrada='') THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `consulta` | ACCION | consulta / lee | 🔵 CONVENCIÓN | nombre_sp |
| `tipo` | MODIF | tipo de | 🔵 CONVENCIÓN | nombre_sp |
| `movimiento` | ENTIDAD | movimiento | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |

---

## `sp_controlador_r27`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_controlador_r27.sql` |
| **LOC (1er CREATE)** | 131 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "rol" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 1 llamada(s): `sp_acl_regulatorio27` |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=1 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_controlador_r27(
) RETURNING char(7)
```

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vcodret` | `char(7)` | L5 |
| `vsqlerr` | `integer` | L6 |
| `pFechaCap_Ini` | `varchar(20)` | L7 |
| `pFechaCap_Fin` | `varchar(20)` | L8 |
| `resultado_FECHA_INCIO` | `VARCHAR(20)` | L9 |
| `VALOR_RETORNO` | `VARCHAR(20)` | L10 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `acl_control_r27` | `bdiaclaracion` | no | SELECT | L34 |
| `acl_control_r27` | `bdiaclaracion` | no | INSERT | L43 |
| `acl_control_r27` | `bdiaclaracion` | no | UPDATE | L46 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_acl_regulatorio27` | `bdiaclaracion` | no | L37 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L124 | CÓDIGO_RETORNO | `let vcodret = '00000';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `cont` | PREFIJO | familia contabilidad | 🔵 CONVENCIÓN | nombre_sp |
| `rol` | ENTIDAD | rol / perfil | 🔵 CONVENCIÓN | nombre_sp |
| `?ador_r27` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?ador_r27` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_crea_folio_aclaracion`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_crea_folio_aclaracion.sql` |
| **LOC (1er CREATE)** | 81 |
| **Callgraph** | ✅ fan_in=0 / fan_out=5 |
| **Deps concatenadas** | 24 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "crédito, folio y aclaración bancaria — proceso de disputa o reclamación del cliente" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 3 tabla(s) con operaciones: SELECT, INSERT |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=1 · INFERIDO=1 · SINTÉTICO=1 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_crea_folio_aclaracion(
  pCliente                     CHAR(9)
) RETURNING CHAR(5)							as cod_ret,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pCliente` | `CHAR(9)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `sql_err` | `INTEGER` | L8 |
| `v_cod_ret` | `CHAR(5)` | L9 |
| `v_folio_aclaracion` | `CHAR(18)` | L10 |
| `v_consecutivo` | `INTEGER` | L11 |
| `c_fecha_ingreso` | `DATETIME YEAR to FRACTION(5)` | L12 |
| `c_separador` | `CHAR(1)` | L13 |
| `c_prefijo` | `CHAR(3)` | L14 |
| `v_existe_cliente` | `SMALLINT` | L16 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_cliente` | `bdinteg` | ⚠️ sí | SELECT | L42 |
| `acl_folio_aclaracion` | `bdiaclaracion` | no | SELECT | L53 |
| `acl_folio_aclaracion` | `bdiaclaracion` | no | INSERT | L63 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L46 | VALIDACIÓN_NULL | `IF v_existe_cliente IS NULL OR v_existe_cliente = 0 THEN` |  |
| L56 | VALIDACIÓN_NULL | `IF v_consecutivo IS NULL THEN` |  |
| L60 | FÓRMULA | `LET v_consecutivo = v_consecutivo + 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `cre` | ENTIDAD | crédito | 🟡 INFERIDO | nombre_sp |
| `?a_` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `folio` | ENTIDAD | folio | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `aclaracion` | ENTIDAD | aclaración bancaria — proceso de disputa o reclamación del c | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?a_` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_cuestionario_telefonico`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_cuestionario_telefonico.sql` |
| **LOC (1er CREATE)** | 122 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "(telefónico)" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 2 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=1 / 3 términos |

### Firma

```sql
CREATE PROCEDURE sp_cuestionario_telefonico(
  p_NumCte                     CHAR(30)
) RETURNING CHAR(50) AS estado, CHAR(15) AS fecha_nacimiento, CHAR(10) AS cod_postal,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_NumCte` | `CHAR(30)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `resultado_estado` | `CHAR(50)` | L8 |
| `resultado_estado_nacio` | `CHAR(50)` | L9 |
| `resultado_fecha_nacimiento` | `CHAR(15)` | L10 |
| `resultado_cod_postal` | `CHAR(10)` | L11 |
| `resultado_numero_exterior` | `CHAR(15)` | L12 |
| `resultado_apellido_paterno` | `CHAR(20)` | L13 |
| `resultado_apellido_materno` | `CHAR(20)` | L14 |
| `resultado_telefono` | `CHAR(30)` | L15 |
| `resultado_calle` | `CHAR(50)` | L16 |
| `resultado_colonia` | `CHAR(50)` | L17 |
| `resultado_municipio` | `CHAR(50)` | L18 |
| `resultado_correo_electronico` | `CHAR(50)` | L19 |
| `iSqlErr` | `INTEGER` | L20 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_cliente` | `bdinteg` | ⚠️ sí | SELECT | L64 |
| `si_ctepf` | `bdinteg` | ⚠️ sí | SELECT | L73 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L77 | VALIDACIÓN_NULL | `IF resultado_estado is null THEN` |  |
| L81 | VALIDACIÓN_NULL | `IF resultado_fecha_nacimiento is null THEN` |  |
| L85 | VALIDACIÓN_NULL | `IF resultado_cod_postal is null THEN` |  |
| L89 | VALIDACIÓN_NULL | `IF resultado_numero_exterior is null THEN` |  |
| L93 | VALIDACIÓN_NULL | `IF resultado_estado_nacio is null THEN` |  |
| L97 | VALIDACIÓN_NULL | `IF resultado_telefono is null THEN` |  |
| L101 | VALIDACIÓN_NULL | `IF resultado_calle is null THEN` |  |
| L105 | VALIDACIÓN_NULL | `IF resultado_colonia is null THEN` |  |
| L109 | VALIDACIÓN_NULL | `IF resultado_municipio is null THEN` |  |
| L113 | VALIDACIÓN_NULL | `IF resultado_correo_electronico is null THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `?_cuestionario_` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `telefonico` | MODIF | telefónico | 🔵 CONVENCIÓN | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_cuestionario_` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_cuestionario_telefonico2`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_cuestionario_telefonico2.sql` |
| **LOC (1er CREATE)** | 221 |
| **Callgraph** | ✅ fan_in=0 / fan_out=3 |
| **Deps concatenadas** | 6 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "(telefónico)" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 3 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=2 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_cuestionario_telefonico2(
  p_NumCte                     CHAR(30)
) RETURNING CHAR(50) AS estado, CHAR(15) AS fecha_nacimiento, CHAR(10) AS cod_postal,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_NumCte` | `CHAR(30)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `resultado_estado` | `CHAR(50)` | L10 |
| `resultado_estado_nacio` | `CHAR(50)` | L11 |
| `resultado_fecha_nacimiento` | `CHAR(15)` | L12 |
| `resultado_cod_postal` | `CHAR(10)` | L13 |
| `resultado_numero_exterior` | `CHAR(15)` | L14 |
| `resultado_apellido_paterno` | `CHAR(20)` | L15 |
| `resultado_apellido_materno` | `CHAR(20)` | L16 |
| `resultado_telefono` | `CHAR(30)` | L17 |
| `resultado_calle` | `CHAR(50)` | L18 |
| `resultado_colonia` | `CHAR(50)` | L19 |
| `resultado_municipio` | `CHAR(50)` | L20 |
| `resultado_correo_electronico` | `CHAR(50)` | L21 |
| `iSqlErr` | `INTEGER` | L22 |
| `cPregunta_1` | `CHAR(100)` | L24 |
| `cPregunta_2` | `CHAR(100)` | L25 |
| `cPregunta_3` | `CHAR(100)` | L26 |
| `cPregunta_4` | `CHAR(100)` | L27 |
| `cPregunta_5` | `CHAR(100)` | L28 |
| `cPregunta_6` | `CHAR(100)` | L29 |
| `cPregunta_7` | `CHAR(100)` | L30 |
| `cPregunta_8` | `CHAR(100)` | L31 |
| `cPregunta_9` | `CHAR(100)` | L32 |
| `cPregunta_10` | `CHAR(100)` | L33 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_cliente` | `bdinteg` | ⚠️ sí | SELECT | L99 |
| `si_ctepf` | `bdinteg` | ⚠️ sí | SELECT | L110 |
| `acl_cuestionario_tel` | `bdiaclaracion` | no | SELECT | L119 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L114 | VALIDACIÓN_NULL | `IF resultado_estado is null THEN` |  |
| L123 | VALIDACIÓN_NULL | `IF resultado_fecha_nacimiento is null THEN` |  |
| L132 | VALIDACIÓN_NULL | `IF resultado_cod_postal is null THEN` |  |
| L141 | VALIDACIÓN_NULL | `IF resultado_numero_exterior is null THEN` |  |
| L150 | VALIDACIÓN_NULL | `IF resultado_estado_nacio is null THEN` |  |
| L159 | VALIDACIÓN_NULL | `IF resultado_telefono is null THEN` |  |
| L168 | VALIDACIÓN_NULL | `IF resultado_calle is null THEN` |  |
| L177 | VALIDACIÓN_NULL | `IF resultado_colonia is null THEN` |  |
| L186 | VALIDACIÓN_NULL | `IF resultado_municipio is null THEN` |  |
| L195 | VALIDACIÓN_NULL | `IF resultado_correo_electronico is null THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `?_cuestionario_` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `telefonico` | MODIF | telefónico | 🔵 CONVENCIÓN | nombre_sp |
| `?2` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_cuestionario_`, `?2` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_desbloqueo_cuentas_aclaraciones_sin_saldo`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_desbloqueo_cuentas_aclaraciones_sin_saldo.sql` |
| **LOC (1er CREATE)** | 200 |
| **Callgraph** | ✅ fan_in=0 / fan_out=4 |
| **Deps concatenadas** | 1 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "desbloquea cuenta cuentas, aclaraciones y saldo" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 4 llamada(s): `sp_desbloqueocuenta`, `sp_bloqueocuenta`, `sp_cons_sdodisp_x_tpcalculo` |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=1 / 6 términos |

### Firma

```sql
CREATE PROCEDURE sp_desbloqueo_cuentas_aclaraciones_sin_saldo(
  pFolio_csuac                 CHAR (11)
  pAccion                      INTEGER
) RETURNING CHAR (6) AS codeRet,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pFolio_csuac` | `CHAR (11)` | — | — |
| `pAccion` | `INTEGER` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vNumCuenta` | `CHAR(25)` | L6 |
| `vTipoProducto` | `INTEGER` | L7 |
| `vNumCliente` | `CHAR(15)` | L8 |
| `codeRet` | `CHAR (5)` | L9 |
| `mensajeRet` | `CHAR(60)` | L10 |
| `vStatusCta` | `INTEGER` | L11 |
| `vMotivo` | `CHAR (3)` | L12 |
| `vCodigoBloqueo` | `CHAR (3)` | L13 |
| `vCodigoEstatus` | `INTEGER` | L14 |
| `vSaldoCongelado` | `MONEY` | L15 |
| `vSaldoCta` | `MONEY` | L16 |
| `vStatusCred` | `CHAR (3)` | L17 |
| `cCodRet` | `CHAR(5)` | L19 |
| `cMensajeRet` | `CHAR(50)` | L20 |
| `mSdoActual` | `MONEY(14,2)` | L21 |
| `mSdoRetenido` | `MONEY(14,2)` | L22 |
| `mSdoCong` | `MONEY(14,2)` | L23 |
| `mSaldoSbc` | `MONEY(14,2)` | L24 |
| `mImpSbgCcc` | `MONEY(14,2)` | L25 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `acl_aclaracion` | `bdiaclaracion` | no | SELECT | L58 |
| `sd_maecred` | `bdicred` | ⚠️ sí | SELECT | L64 |
| `sd_bloqueoscuenta` | `bdicred` | ⚠️ sí | SELECT | L71 |
| `sd_causa_bloqueo` | `bdicred` | ⚠️ sí | SELECT | L76 |
| `sc_maechq` | `bdicheq` | ⚠️ sí | SELECT | L99 |
| `sc_mae_estatus` | `bdicheq` | ⚠️ sí | SELECT | L111 |
| `sc_bloqueo` | `bdicheq` | ⚠️ sí | SELECT | L118 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_desbloqueocuenta` | `bdicred` | ⚠️ sí | L80 |
| `sp_bloqueocuenta` | `bdicred` | ⚠️ sí | L88 |
| `sp_cons_sdodisp_x_tpcalculo` | `bdicheq` | ⚠️ sí | L103 |
| `bloqueo_cta` | `bdicheq` | ⚠️ sí | L125 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L40 | CÓDIGO_RETORNO | `LET cCodRet = '00000';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `desbloqueo` | ACCION | desbloquea cuenta | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `cuentas` | ENTIDAD | cuentas (plural) | 🔵 CONVENCIÓN | nombre_sp |
| `aclaraciones` | ENTIDAD | aclaraciones (proceso de disputas/reclamaciones de cliente) | 🔵 CONVENCIÓN | nombre_sp |
| `?_sin_` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `saldo` | ENTIDAD | saldo | ✅ CÓDIGO | nombre_sp, texto_cuerpo |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_sin_` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_detalle_aclaracion_canales`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_detalle_aclaracion_canales.sql` |
| **LOC (1er CREATE)** | 267 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 5 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "detalle, aclaración bancaria — proceso de disputa o reclamación del cliente y canales" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 1 llamada(s): `sp_obten_estatus_canales` |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=0 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_detalle_aclaracion_canales(
  pIdAclaracion                INTEGER
) RETURNING CHAR(5)				AS cod_ret,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pIdAclaracion` | `INTEGER` | `aclaracion`=aclaración bancaria — proceso de disputa o reclamación del cliente | ✅ CÓDIGO |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `sql_err` | `INTEGER` | L36 |
| `v_cod_ret` | `CHAR(5)` | L37 |
| `v_cod_ret_estatus` | `CHAR(5)` | L38 |
| `v_numero_cuenta` | `CHAR(20)` | L39 |
| `v_numero_tarjeta` | `CHAR(16)` | L40 |
| `v_folio_aclaracion` | `CHAR(18)` | L41 |
| `v_folio_csuac` | `CHAR(11)` | L42 |
| `v_id_flujo` | `INTEGER` | L43 |
| `v_flujo` | `CHAR(50)` | L44 |
| `v_id_origen_evento` | `INTEGER` | L45 |
| `v_origen_evento` | `CHAR(50)` | L46 |
| `v_id_evento` | `INTEGER` | L47 |
| `v_evento` | `CHAR(50)` | L48 |
| `v_fecha_aclaracion` | `DATE` | L49 |
| `v_fecha_movimiento` | `DATETIME YEAR to FRACTION(5)` | L50 |
| `v_fecha_consumo` | `DATETIME YEAR to FRACTION(5)` | L51 |
| `v_producto` | `CHAR(50)` | L53 |
| `v_folio_suc` | `CHAR(30)` | L54 |
| `v_referencia23` | `CHAR(23)` | L55 |
| `v_refcomercio` | `CHAR(40)` | L56 |
| `v_importereclamado` | `MONEY` | L57 |
| `v_importeaceptado` | `MONEY` | L58 |
| `v_importeoriginal` | `MONEY` | L59 |
| `v_resp_estimada` | `INTEGER` | L60 |
| `v_resp_estimada_intl` | `INTEGER` | L61 |
| *…22 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_fechas` | `bdinteg` | ⚠️ sí | SELECT | L156 |
| `acl_aclaracion` | `bdiaclaracion` | no | SELECT | L168 |
| `acl_resolucion` | `bdiaclaracion` | no | SELECT | L187 |
| `acl_entrada_bitacora` | `bdiaclaracion` | no | SELECT | L193 |
| `acl_estatus_corporativo` | `bdiaclaracion` | no | SELECT | L204 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_obten_estatus_canales` | `bdiaclaracion` | no | L233 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L218 | FÓRMULA | `LET v_dias_faltantes = (v_resp_estimada_intl - 1) - (c_fecha_actual - v_fecha_aclaracion);` |  |
| L220 | FÓRMULA | `LET v_dias_faltantes =  (v_resp_estimada - 1) - (c_fecha_actual - v_fecha_aclaracion);` |  |
| L222 | FÓRMULA | `LET v_dias_faltantes = (v_resp_estimada - 1) - (c_fecha_actual - v_fecha_aclaracion);` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `detalle` | ENTIDAD | detalle | 🔵 CONVENCIÓN | nombre_sp |
| `aclaracion` | ENTIDAD | aclaración bancaria — proceso de disputa o reclamación del c | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `canales` | ENTIDAD | canales (de distribución) | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |

---

## `sp_detalleeglobal`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_detalleeglobal.sql` |
| **LOC (1er CREATE)** | 166 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "detalle" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 3 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=1 / 3 términos |

### Firma

```sql
CREATE PROCEDURE sp_detalleeglobal(
  desde                        date
  hasta                        date
  eventoA                      char(15)
  eventoB                      char(15)
) RETURNING char(50) as evento, char(50) as folio_csuac, char(50) as estatus,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `desde` | `date` | — | — |
| `hasta` | `date` | — | — |
| `eventoA` | `char(15)` | — | — |
| `eventoB` | `char(15)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `var_aclaracion` | `integer` | L6 |
| `var_fecha` | `datetime YEAR to SECOND` | L7 |
| `var_fecha_s` | `datetime YEAR to SECOND` | L8 |
| `res_evento` | `char(50)` | L10 |
| `res_folio_csuac` | `char(50)` | L11 |
| `res_estatus` | `char(50)` | L12 |
| `res_respuesta` | `char(50)` | L13 |
| `res_numero` | `char(50)` | L14 |
| `res_folio_suc` | `char(50)` | L15 |
| `res_fechahora` | `date` | L16 |
| `res_monto` | `float` | L17 |
| `res_nombre` | `char(50)` | L18 |
| `res_usuario` | `char(50)` | L19 |
| `res_supervisor` | `char(50)` | L20 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `acl_aclaracion` | `bdiaclaracion` | no | SELECT | L52 |
| `temp_solicitudes` | `bdiaclaracion` | no | SELECT | L78 |
| `acl_entrada_bitacora` | `bdiaclaracion` | no | SELECT | L82 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `detalle` | ENTIDAD | detalle | 🔵 CONVENCIÓN | nombre_sp |
| `?eglobal` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?eglobal` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_detalleeglobal_pba`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_detalleeglobal_pba.sql` |
| **LOC (1er CREATE)** | 166 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "detalle (PBA — sufijo de SPs para Pruebas; confirmado por SME)" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `confirma` → `SELECT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=1 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_detalleeglobal_pba(
  desde                        date
  hasta                        date
  eventoA                      char(15)
  eventoB                      char(15)
) RETURNING char(50) as evento, char(50) as folio_csuac, char(50) as estatus,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `desde` | `date` | — | — |
| `hasta` | `date` | — | — |
| `eventoA` | `char(15)` | — | — |
| `eventoB` | `char(15)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `var_aclaracion` | `integer` | L6 |
| `var_fecha` | `datetime YEAR to SECOND` | L7 |
| `var_fecha_s` | `datetime YEAR to SECOND` | L8 |
| `res_evento` | `char(50)` | L10 |
| `res_folio_csuac` | `char(50)` | L11 |
| `res_estatus` | `char(50)` | L12 |
| `res_respuesta` | `char(50)` | L13 |
| `res_numero` | `char(50)` | L14 |
| `res_folio_suc` | `char(50)` | L15 |
| `res_fechahora` | `date` | L16 |
| `res_monto` | `float` | L17 |
| `res_nombre` | `char(50)` | L18 |
| `res_usuario` | `char(50)` | L19 |
| `res_supervisor` | `char(50)` | L20 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `acl_aclaracion` | `bdiaclaracion` | no | SELECT | L52 |
| `temp_solicitudes` | `bdiaclaracion` | no | SELECT | L78 |
| `acl_entrada_bitacora` | `bdiaclaracion` | no | SELECT | L82 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `detalle` | ENTIDAD | detalle | 🔵 CONVENCIÓN | nombre_sp |
| `?eglobal_` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `pba` | MODIF | PBA — sufijo de SPs para Pruebas; confirmado por SME (Guerra | 🔵 CONVENCIÓN | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?eglobal_` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_dg_docsrequeridos_acl`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_dg_docsrequeridos_acl.sql` |
| **LOC (1er CREATE)** | 117 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 3 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "identificador y OS — Originación de Solicitudes" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 4 tabla(s) con operaciones: SELECT, DELETE, INSERT |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=2 · INFERIDO=1 · SINTÉTICO=1 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_dg_docsrequeridos_acl(
  pCodGrupo                    CHAR(4)
  pCodSistema                  CHAR(2)
  pRegistros                   INTEGER
  pRecuperacion                INTEGER
) RETURNING CHAR(5) AS codret,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pCodGrupo` | `CHAR(4)` | — | — |
| `pCodSistema` | `CHAR(2)` | — | — |
| `pRegistros` | `INTEGER` | `os`=OS — Originación de Solicitudes / subsistema de ofertas (sp_os_*, sp_calcula_estatus_os — bdisolic) | 🟡 INFERIDO |
| `pRecuperacion` | `INTEGER` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(5)` | L9 |
| `iSqlErr` | `INTEGER` | L10 |
| `cEmpresa` | `CHAR(3)` | L11 |
| `cCodDocto` | `CHAR(5)` | L12 |
| `iTipoDocto` | `INTEGER` | L13 |
| `cCodGrupo` | `CHAR(5)` | L14 |
| `cDescDocto` | `CHAR(50)` | L15 |
| `cDescGrupo` | `CHAR(50)` | L16 |
| `cClave` | `CHAR(5)` | L17 |
| `cDescripcion` | `CHAR(50)` | L18 |
| `cDigitalizado` | `CHAR(2)` | L19 |
| `cMultiImg` | `CHAR(1)` | L20 |
| `iNoRegistros` | `INTEGER` | L21 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `dg_docsrequeridos` | `bdiaclaracion` | no | SELECT | L52 |
| `dg_docsrequeridos` | `bdiaclaracion` | no | DELETE | L52 |
| `acl_tipo_docto_dg_tipodocto` | `bdiaclaracion` | no | SELECT | L61 |
| `dg_docsrequeridos` | `bdiaclaracion` | no | INSERT | L72 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L23 | CÓDIGO_RETORNO | `LET cCodRet = '00000';` |  |
| L47 | VALIDACIÓN_NULL | `IF pCodGrupo = '' OR pCodSistema = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN` |  |
| L96 | FÓRMULA | `LET iNoRegistros = iNoRegistros + 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `?_dg_docsrequer` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `id` | ENTIDAD | identificador (de) | 🔵 CONVENCIÓN | nombre_sp |
| `os` | ENTIDAD | OS — Originación de Solicitudes / subsistema de ofertas (sp_ | 🟡 INFERIDO | nombre_sp |
| `acl` | PREFIJO | familia aclaraciones | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_dg_docsrequer` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_documentos_faltantes`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_documentos_faltantes.sql` |
| **LOC (1er CREATE)** | 152 |
| **Callgraph** | ✅ fan_in=9 / fan_out=6 |
| **Deps concatenadas** | 2 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "documentos (faltantes)" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 1 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=0 / 3 términos |

### Firma

```sql
CREATE PROCEDURE sp_documentos_faltantes(
  pIdAclaracion                INTEGER
  pCliente                     CHAR(9)
) RETURNING CHAR(5)							AS cod_ret,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pIdAclaracion` | `INTEGER` | — | — |
| `pCliente` | `CHAR(9)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `sql_err` | `INTEGER` | L18 |
| `v_cod_ret` | `CHAR(5)` | L19 |
| `v_existe_aclaracion` | `SMALLINT` | L20 |
| `v_cliente_aclaracion` | `CHAR(9)` | L21 |
| `v_folio_csuac` | `CHAR(11)` | L22 |
| `v_id_documento` | `INTEGER` | L23 |
| `v_grupo_doc` | `CHAR(4)` | L24 |
| `v_codigo_doc` | `CHAR(4)` | L25 |
| `v_existe_archivo_digital` | `SMALLINT` | L26 |
| `v_desc_documento` | `CHAR(100)` | L27 |
| `v_id_digitalizado` | `INTEGER` | L28 |
| `v_opcional` | `SMALLINT` | L29 |
| `v_nombre_acl_doc` | `CHAR(50)` | L30 |
| `v_fecha_registro` | `DATETIME YEAR to FRACTION(5)` | L31 |
| `v_registro_acl_doc` | `DATE` | L32 |
| `v_registro_bdidigital` | `DATE` | L33 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `acl_aclaracion` | `bdiaclaracion` | no | SELECT | L86 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L69 | VALIDACIÓN_NULL | `IF ((pCliente IS NULL) OR (pCliente = '')) AND (pIdAclaracion IS NULL) THEN` |  |
| L74 | VALIDACIÓN_NULL | `IF (pIdAclaracion IS NULL) THEN` |  |
| L79 | VALIDACIÓN_NULL | `IF (pCliente IS NULL) OR (pCliente = '') THEN` |  |
| L89 | VALIDACIÓN_NULL | `IF (v_existe_aclaracion IS NULL) THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `documentos` | ENTIDAD | documentos | 🔵 CONVENCIÓN | nombre_sp |
| `faltantes` | MODIF | faltantes | 🔵 CONVENCIÓN | nombre_sp |

---

## `sp_documentos_faltantes_canales`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_documentos_faltantes_canales.sql` |
| **LOC (1er CREATE)** | 165 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 4 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "documentos y canales (faltantes)" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 1 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=4 · INFERIDO=0 · SINTÉTICO=0 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_documentos_faltantes_canales(
  pIdAclaracion                INTEGER
  pCliente                     CHAR(9)
) RETURNING CHAR(5)                         AS cod_ret,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pIdAclaracion` | `INTEGER` | — | — |
| `pCliente` | `CHAR(9)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `sql_err` | `INTEGER` | L18 |
| `v_cod_ret` | `CHAR(5)` | L19 |
| `v_existe_aclaracion` | `SMALLINT` | L20 |
| `v_cliente_aclaracion` | `CHAR(9)` | L21 |
| `v_folio_csuac` | `CHAR(11)` | L22 |
| `v_id_documento` | `INTEGER` | L23 |
| `v_grupo_doc` | `CHAR(4)` | L24 |
| `v_codigo_doc` | `CHAR(4)` | L25 |
| `v_existe_archivo_digital` | `SMALLINT` | L26 |
| `v_desc_documento` | `CHAR(100)` | L27 |
| `v_id_digitalizado` | `INTEGER` | L28 |
| `v_opcional` | `SMALLINT` | L29 |
| `v_nombre_acl_doc` | `CHAR(50)` | L30 |
| `v_fecha_registro` | `DATETIME YEAR to FRACTION(5)` | L31 |
| `v_nombre_tipo_doc` | `CHAR(50)` | L32 |
| `v_registro_acl_doc` | `DATE` | L33 |
| `v_registro_bdidigital` | `DATE` | L34 |
| `c_nombre_carta_acl` | `CHAR(50)` | L36 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `acl_aclaracion` | `bdiaclaracion` | no | SELECT | L92 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L75 | VALIDACIÓN_NULL | `IF ((pCliente IS NULL) OR (pCliente = '')) AND (pIdAclaracion IS NULL) THEN` |  |
| L80 | VALIDACIÓN_NULL | `IF (pIdAclaracion IS NULL) THEN` |  |
| L85 | VALIDACIÓN_NULL | `IF (pCliente IS NULL) OR (pCliente = '') THEN` |  |
| L95 | VALIDACIÓN_NULL | `IF (v_existe_aclaracion IS NULL) THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `documentos` | ENTIDAD | documentos | 🔵 CONVENCIÓN | nombre_sp |
| `faltantes` | MODIF | faltantes | 🔵 CONVENCIÓN | nombre_sp |
| `canales` | ENTIDAD | canales (de distribución) | 🔵 CONVENCIÓN | nombre_sp |

---

## `sp_eliminacion_puntos_coppel`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_eliminacion_puntos_coppel.sql` |
| **LOC (1er CREATE)** | 259 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 4 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "elimina puntos y Coppel" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 10 tabla(s) con operaciones: SELECT, INSERT, UPDATE |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=1 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_eliminacion_puntos_coppel(
) RETURNING CHAR(5) AS codigo_ret
```

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `iSqlError` | `INTEGER` | L6 |
| `iIsamError` | `INTEGER` | L7 |
| `cMsjError` | `CHAR(500)` | L8 |
| `cCodRet` | `CHAR(6)` | L9 |
| `cCons1` | `CHAR(1000)` | L10 |
| `cArchDescarga` | `CHAR(150)` | L11 |
| `cExtArchDesc` | `CHAR(4)` | L12 |
| `cNom_Sql` | `CHAR(100)` | L13 |
| `cSQL1` | `CHAR(200)` | L14 |
| `cRuta` | `CHAR(100)` | L15 |
| `cSQL` | `CHAR(100)` | L16 |
| `cQuery` | `CHAR(3000)` | L17 |
| `iTempTable` | `INTEGER` | L19 |
| `dFechaHoy` | `DATE` | L20 |
| `v_folio_csuac` | `VARCHAR(11)` | L21 |
| `v_pky_aclaracion` | `INTEGER` | L22 |
| `v_fechacargo` | `VARCHAR(10)` | L23 |
| `v_numcuenta` | `VARCHAR(20)` | L24 |
| `v_numcliente` | `VARCHAR(9)` | L25 |
| `v_montopro` | `VARCHAR(20)` | L26 |
| `v_producto` | `VARCHAR(11)` | L27 |
| `v_referencia23` | `VARCHAR(23)` | L28 |
| `iContador` | `INTEGER` | L29 |
| `iMaxId` | `INTEGER` | L31 |
| `c_numcte` | `CHAR(40)` | L32 |
| *…14 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `systables` | `bdiaclaracion` | no | SELECT | L109 |
| `si_fechas` | `bdinteg` | ⚠️ sí | SELECT | L129 |
| `acl_aclaracion` | `bdiaclaracion` | no | SELECT | L138 |
| `acl_movimiento` | `bdiaclaracion` | no | SELECT | L146 |
| `acl_producto` | `bdiaclaracion` | no | SELECT | L152 |
| `tabla_valida_puntos_coppel` | `bdiaclaracion` | no | INSERT | L161 |
| `tabla_valida_puntos_coppel` | `bdiaclaracion` | no | SELECT | L190 |
| `sd_movs_monedero_plan_lealtad` | `bdicred` | ⚠️ sí | SELECT | L196 |
| `sd_movs_monedero_plan_lealtad` | `bdicred` | ⚠️ sí | UPDATE | L203 |
| `tabla_valida_puntos_coppel` | `bdiaclaracion` | no | UPDATE | L205 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L52 | CÓDIGO_RETORNO | `LET cCodRet 						= '00000';` |  |
| L170 | FÓRMULA | `LET iContador = iContador + 1;` |  |
| L209 | FÓRMULA | `LET iContador = iContador + 1;` |  |
| L225 | FÓRMULA | `let cQuery = ' echo "FOLIO_CSUAC\|FECHA_DE_CARGO\|NUMERO_CUENTA\|CLIENTE\|MONTO_PROCEDENTE\|PRODUCTO` | 🔴 MONEY/aritmética financiera |
| L237 | FÓRMULA | `let cQuery = "sed 's/\|$//g' coppel_max.unl >>/resplogifx/repaclaraciones/PUNTOS_COPPEL_MAX_"\|\|LPA` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `elimina` | ACCION | elimina | 🔵 CONVENCIÓN | nombre_sp |
| `?cion_` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `puntos` | ENTIDAD | puntos (recompensas) | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `coppel` | ENTIDAD | Coppel (grupo) | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?cion_` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_fal_actualiza_estatus_cuenta`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_fal_actualiza_estatus_cuenta.sql` |
| **LOC (1er CREATE)** | 148 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 10 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "actualiza fal — fallo/disputa, estatus y cuenta" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `actualiza` → `UPDATE` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=4 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=0 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_fal_actualiza_estatus_cuenta(
  p_cuenta                     CHAR(20)
  p_cliente                    CHAR(9)
  p_producto                   INT
  p_tipo                       INT
) RETURNING CHAR(100) AS estatus_cta
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_cuenta` | `CHAR(20)` | `cuenta`=cuenta | ✅ CÓDIGO |
| `p_cliente` | `CHAR(9)` | — | — |
| `p_producto` | `INT` | — | — |
| `p_tipo` | `INT` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `iSqlErr` | `INTEGER` | L5 |
| `estatus_cuenta` | `CHAR(100)` | L7 |
| `movito_bloqueo` | `CHAR(80)` | L8 |
| `res_status_cta` | `CHAR(50)` | L9 |
| `codigo_estatus_cta` | `INT` | L10 |
| `producto_debito` | `INT` | L11 |
| `producto_credito` | `INT` | L12 |
| `secuenciaMax` | `CHAR(4)` | L13 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sd_maecred` | `bdicred` | ⚠️ sí | SELECT | L56 |
| `fal_saldo_anterior` | `bdiaclaracion` | no | UPDATE | L63 |
| `sc_maechq` | `bdicheq` | ⚠️ sí | SELECT | L85 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L67 | FÓRMULA | `LET estatus_cuenta = res_status_cta\|\|'*'\|\|movito_bloqueo;` |  |
| L97 | FÓRMULA | `LET  estatus_cuenta = res_status_cta\|\|'*'\|\|movito_bloqueo;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `fal` | ENTIDAD | fal — fallo/disputa (prefijo sp_fal_* — aclaraciones bancari | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `actualiza` | ACCION | actualiza | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `estatus` | ENTIDAD | estatus | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `cuenta` | ENTIDAD | cuenta | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |

---

## `sp_fal_asignar_analista_credito`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_fal_asignar_analista_credito.sql` |
| **LOC (1er CREATE)** | 152 |
| **Callgraph** | ✅ fan_in=21 / fan_out=9 |
| **Deps concatenadas** | 17 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "asigna fal — fallo/disputa, analista y crédito" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 4 tabla(s) con operaciones: SELECT, UPDATE |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=1 / 6 términos |

### Firma

```sql
CREATE PROCEDURE sp_fal_asignar_analista_credito(
  resultado_fky_usuario_analista INTEGER
  p_idSolicitud                INTEGER
  p_numeroCredito              CHAR(20)
  p_numeroTarjeta              char(8)
  resultado_pky_control_tramite_cuenta INTEGER
  p_codigoAdjunto              CHAR(6)
) RETURNING CHAR(6) as codigoRetorno,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `resultado_fky_usuario_analista` | `INTEGER` | `analista`=analista | ✅ CÓDIGO |
| `p_idSolicitud` | `INTEGER` | — | — |
| `p_numeroCredito` | `CHAR(20)` | `credito`=crédito | 🔵 CONVENCIÓN |
| `p_numeroTarjeta` | `char(8)` | — | — |
| `resultado_pky_control_tramite_cuenta` | `INTEGER` | — | — |
| `p_codigoAdjunto` | `CHAR(6)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `codigoRetorno` | `CHAR(6)` | L7 |
| `mensajeRetorno` | `CHAR(250)` | L8 |
| `numeroCredito` | `CHAR(20)` | L9 |
| `numeroTarjeta` | `CHAR(16)` | L10 |
| `resultado_asign_num_empleado` | `CHAR(9)` | L12 |
| `resultado_asign_usuario` | `INTEGER` | L14 |
| `resultado_asign_usuario_2` | `INTEGER` | L15 |
| `resultado_num_analistas` | `INTEGER` | L17 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `acl_usuario` | `bdiaclaracion` | no | SELECT | L40 |
| `acl_permiso` | `bdiaclaracion` | no | SELECT | L44 |
| `fal_solicitud` | `bdiaclaracion` | no | UPDATE | L91 |
| `fal_control_tramite` | `bdiaclaracion` | no | UPDATE | L94 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L34 | VALIDACIÓN_NULL | `IF resultado_fky_usuario_analista = 0 OR resultado_fky_usuario_analista IS NULL THEN` |  |
| L75 | VALIDACIÓN_NULL | `IF resultado_asign_usuario_2 IS NULL THEN` |  |
| L98 | FÓRMULA | `LET codigoRetorno       = p_codigoAdjunto;                       -- CODIGO DEFINIDO` |  |
| L114 | FÓRMULA | `LET codigoRetorno       = p_codigoAdjunto;                       -- CODIGO DEFINIDO` |  |
| L130 | FÓRMULA | `LET codigoRetorno       = p_codigoAdjunto;                       -- CODIGO DEFINIDO` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `fal` | ENTIDAD | fal — fallo/disputa (prefijo sp_fal_* — aclaraciones bancari | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `asigna` | ACCION | asigna | 🔵 CONVENCIÓN | nombre_sp |
| `?r_` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `analista` | ENTIDAD | analista | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `credito` | ENTIDAD | crédito | 🔵 CONVENCIÓN | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?r_` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_fal_busca_beneficiarios_pagares_por_cuenta`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_fal_busca_beneficiarios_pagares_por_cuenta.sql` |
| **LOC (1er CREATE)** | 139 |
| **Callgraph** | ✅ fan_in=0 / fan_out=16 |
| **Deps concatenadas** | 30 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "busca fal — fallo/disputa, beneficiarios, pagarés y cuenta" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 1 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=6 · INFERIDO=0 · SINTÉTICO=0 / 7 términos |

### Firma

```sql
CREATE PROCEDURE sp_fal_busca_beneficiarios_pagares_por_cuenta(
  p_numeroCuenta               CHAR(20)
) RETURNING CHAR(20)    AS numeroCliente,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_numeroCuenta` | `CHAR(20)` | `cuenta`=cuenta | ✅ CÓDIGO |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `resultado_numeroCliente` | `CHAR(20)` | L17 |
| `resultado_numeroCuenta` | `CHAR(30)` | L18 |
| `resultado_estatus` | `CHAR(30)` | L19 |
| `resultado_motivo` | `CHAR(100)` | L20 |
| `resultado_porcentaje` | `MONEY(16)` | L21 |
| `resultado_porc_bene` | `MONEY(16)` | L22 |
| `resultado_numeroProducto` | `CHAR(6)` | L23 |
| `resultado_apellidoPat` | `CHAR(30)` | L24 |
| `resultado_apellidoMat` | `CHAR(30)` | L25 |
| `resultado_nombre1` | `CHAR(30)` | L26 |
| `resultado_nombre2` | `CHAR(30)` | L27 |
| `resultado_descripcion_estatus` | `CHAR(30)` | L28 |
| `iSqlErr` | `INTEGER` | L30 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_cliente` | `bdinteg` | ⚠️ sí | SELECT | L72 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L115 | VALIDACIÓN_NULL | `IF resultado_numeroCuenta = '' OR resultado_numeroCuenta IS NULL THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `fal` | ENTIDAD | fal — fallo/disputa (prefijo sp_fal_* — aclaraciones bancari | 🔵 CONVENCIÓN | nombre_sp |
| `busca` | ACCION | busca / localiza | 🔵 CONVENCIÓN | nombre_sp |
| `beneficiarios` | ENTIDAD | beneficiarios | 🔵 CONVENCIÓN | nombre_sp |
| `pagares` | ENTIDAD | pagarés | 🔵 CONVENCIÓN | nombre_sp |
| `por` | MODIF | por (criterio) | 🔵 CONVENCIÓN | nombre_sp |
| `cuenta` | ENTIDAD | cuenta | ✅ CÓDIGO | nombre_sp, texto_cuerpo |

---

## `sp_fal_busca_beneficiarios_por_cuenta`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_fal_busca_beneficiarios_por_cuenta.sql` |
| **LOC (1er CREATE)** | 160 |
| **Callgraph** | ✅ fan_in=0 / fan_out=20 |
| **Deps concatenadas** | 47 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "busca fal — fallo/disputa, beneficiarios y cuenta" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 1 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=5 · INFERIDO=0 · SINTÉTICO=0 / 6 términos |

### Firma

```sql
CREATE PROCEDURE sp_fal_busca_beneficiarios_por_cuenta(
  p_numeroCuenta               CHAR(20)
) RETURNING CHAR(20) 	AS numeroCliente,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_numeroCuenta` | `CHAR(20)` | `cuenta`=cuenta | ✅ CÓDIGO |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `resultado_numeroCliente` | `CHAR(20)` | L17 |
| `resultado_numeroCuenta` | `CHAR(30)` | L18 |
| `resultado_estatus` | `CHAR(30)` | L19 |
| `resultado_motivo` | `CHAR(100)` | L20 |
| `resultado_porcentaje` | `MONEY(16)` | L21 |
| `resultado_porc_bene` | `MONEY(16)` | L22 |
| `resultado_numeroProducto` | `CHAR(6)` | L23 |
| `resultado_apellidoPat` | `CHAR(30)` | L24 |
| `resultado_apellidoMat` | `CHAR(30)` | L25 |
| `resultado_nombre1` | `CHAR(30)` | L26 |
| `resultado_nombre2` | `CHAR(30)` | L27 |
| `resultado_apellidoPat_cte` | `CHAR(30)` | L28 |
| `resultado_apellidoMat_cte` | `CHAR(30)` | L29 |
| `resultado_nombre1_cte` | `CHAR(30)` | L30 |
| `resultado_nombre2_cte` | `CHAR(30)` | L31 |
| `resultado_descripcion_estatus` | `CHAR(30)` | L32 |
| `iSqlErr` | `INTEGER` | L33 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_cliente` | `bdinteg` | ⚠️ sí | SELECT | L81 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L130 | VALIDACIÓN_NULL | `IF resultado_numeroCuenta = '' OR resultado_numeroCuenta IS NULL THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `fal` | ENTIDAD | fal — fallo/disputa (prefijo sp_fal_* — aclaraciones bancari | 🔵 CONVENCIÓN | nombre_sp |
| `busca` | ACCION | busca / localiza | 🔵 CONVENCIÓN | nombre_sp |
| `beneficiarios` | ENTIDAD | beneficiarios | 🔵 CONVENCIÓN | nombre_sp |
| `por` | MODIF | por (criterio) | 🔵 CONVENCIÓN | nombre_sp |
| `cuenta` | ENTIDAD | cuenta | ✅ CÓDIGO | nombre_sp, texto_cuerpo |

---

## `sp_fal_busca_creditos_cat`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_fal_busca_creditos_cat.sql` |
| **LOC (1er CREATE)** | 206 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 6 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "busca fal — fallo/disputa, créditos y catálogo" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 1 llamada(s): `sp_fal_saldos_deb_cre_cliente` |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=0 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_fal_busca_creditos_cat(
  fechaInicial                 CHAR(10)
  fechaFinal                   CHAR(10)
  origenEvento                 INTEGER
  tipoEvento                   INTEGER
  folioCsuac                   CHAR(20)
  usuarioAnalista              INTEGER
  numCliente                   CHAR(9)
  estatusCorporativo           INTEGER
) RETURNING CHAR(12)    AS folioCSUAC,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `fechaInicial` | `CHAR(10)` | — | — |
| `fechaFinal` | `CHAR(10)` | — | — |
| `origenEvento` | `INTEGER` | — | — |
| `tipoEvento` | `INTEGER` | — | — |
| `folioCsuac` | `CHAR(20)` | — | — |
| `usuarioAnalista` | `INTEGER` | — | — |
| `numCliente` | `CHAR(9)` | — | — |
| `estatusCorporativo` | `INTEGER` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `resultado_cadena_concatenada` | `CHAR(1150)` | L14 |
| `query` | `char (850)` | L15 |
| `pky_solicitud` | `CHAR (20)` | L16 |
| `iSqlErr` | `INTEGER` | L17 |
| `resultado_folioCSUAC` | `CHAR(12)` | L18 |
| `resultado_saldoCaptacion` | `CHAR(20)` | L19 |
| `resultado_saldoCredito` | `CHAR(20)` | L20 |
| `resultado_asignado` | `CHAR(200)` | L21 |
| `resultado_origen` | `CHAR(200)` | L22 |
| `resultado_evento` | `CHAR(200)` | L23 |
| `resultado_numeroCliente` | `CHAR(9)` | L24 |
| `resultado_estatusGeneral` | `CHAR(100)` | L25 |
| `resultado_fkySolicitud` | `CHAR(20)` | L26 |
| `resultado_cuenta_cliente_fallecido` | `CHAR(20)` | L27 |
| `resultado_numeroProducto` | `CHAR(6)` | L28 |
| `resultado_nombreProducto` | `CHAR(60)` | L29 |
| `resultado_numeroCuenta` | `CHAR(30)` | L30 |
| `resultado_numeroTarjeta` | `CHAR(30)` | L31 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `fal_cat_evento` | `bdiaclaracion` | no | SELECT | L51 |
| `fal_cat_origen_evento` | `bdiaclaracion` | no | SELECT | L51 |
| `fal_cat_estatus_general` | `bdiaclaracion` | no | SELECT | L51 |
| `acl_usuario` | `bdiaclaracion` | no | SELECT | L51 |
| `fal_solicitud` | `bdiaclaracion` | no | SELECT | L51 |
| `resultado_cadena_concatenada` | `bdiaclaracion` | no | SELECT | L124 |
| `fal_control_tramite` | `bdiaclaracion` | no | SELECT | L135 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_fal_saldos_deb_cre_cliente` | `bdiaclaracion` | no | L140 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L95 | FÓRMULA | `LET resultado_cadena_concatenada = "AND fecha_ingreso BETWEEN TO_DATE ('" \|\| fechaInicial \|\| "' ` |  |
| L151 | VALIDACIÓN_NULL | `IF resultado_cuenta_cliente_fallecido IS NULL THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `fal` | ENTIDAD | fal — fallo/disputa (prefijo sp_fal_* — aclaraciones bancari | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `busca` | ACCION | busca / localiza | 🔵 CONVENCIÓN | nombre_sp |
| `creditos` | ENTIDAD | créditos (plural) | 🔵 CONVENCIÓN | nombre_sp |
| `cat` | ENTIDAD | catálogo | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |

---

## `sp_fal_busca_documentos_faltantes`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_fal_busca_documentos_faltantes.sql` |
| **LOC (1er CREATE)** | 67 |
| **Callgraph** | ✅ fan_in=0 / fan_out=20 |
| **Deps concatenadas** | 46 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "busca fal — fallo/disputa y documentos (faltantes)" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 1 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=4 · INFERIDO=0 · SINTÉTICO=0 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_fal_busca_documentos_faltantes(
  p_numeroCuentaFallecido      CHAR(20)
  p_numeroCuentaBeneficiario   CHAR(20)
  p_numeroSolicitud            INTEGER
) RETURNING INTEGER AS resultadoNumeroDocsFaltantes
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_numeroCuentaFallecido` | `CHAR(20)` | `fal`=fal — fallo/disputa (prefijo sp_fal_* — aclaraciones bancarias — bdiaclaracion) | ✅ CÓDIGO |
| `p_numeroCuentaBeneficiario` | `CHAR(20)` | — | — |
| `p_numeroSolicitud` | `INTEGER` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `res_numDocsFaltantes` | `INTEGER` | L5 |
| `iSQLErr` | `INTEGER` | L6 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `fal_beneficiario` | `bdiaclaracion` | no | SELECT | L38 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `fal` | ENTIDAD | fal — fallo/disputa (prefijo sp_fal_* — aclaraciones bancari | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `busca` | ACCION | busca / localiza | 🔵 CONVENCIÓN | nombre_sp |
| `documentos` | ENTIDAD | documentos | 🔵 CONVENCIÓN | nombre_sp |
| `faltantes` | MODIF | faltantes | 🔵 CONVENCIÓN | nombre_sp |

---

## `sp_fal_busca_pagares_cliente`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_fal_busca_pagares_cliente.sql` |
| **LOC (1er CREATE)** | 71 |
| **Callgraph** | ✅ fan_in=0 / fan_out=20 |
| **Deps concatenadas** | 45 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "busca fal — fallo/disputa, pagarés y cliente" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 2 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=5 · INFERIDO=0 · SINTÉTICO=0 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_fal_busca_pagares_cliente(
  p_numeroCliente              CHAR(20)
) RETURNING CHAR(6) AS numeroProducto,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_numeroCliente` | `CHAR(20)` | `cliente`=cliente | 🔵 CONVENCIÓN |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `resultado_numeroProducto` | `CHAR(6)` | L9 |
| `resultado_nombreProducto` | `CHAR(60)` | L10 |
| `resultado_numeroCuenta` | `CHAR(30)` | L11 |
| `resultado_numeroCuetaTmp` | `CHAR(30)` | L12 |
| `resultado_estatus` | `CHAR(30)` | L13 |
| `resultado_motivo` | `CHAR(100)` | L14 |
| `resultado_montoActual` | `MONEY(16)` | L15 |
| `iSqlErr` | `INTEGER` | L16 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sc_maechq` | `bdicheq` | ⚠️ sí | SELECT | L42 |
| `sv_maeinv` | `bdinvers` | ⚠️ sí | SELECT | L50 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `fal` | ENTIDAD | fal — fallo/disputa (prefijo sp_fal_* — aclaraciones bancari | 🔵 CONVENCIÓN | nombre_sp |
| `busca` | ACCION | busca / localiza | 🔵 CONVENCIÓN | nombre_sp |
| `pagares` | ENTIDAD | pagarés | 🔵 CONVENCIÓN | nombre_sp |
| `cliente` | ENTIDAD | cliente | 🔵 CONVENCIÓN | nombre_sp |

---

## `sp_fal_busca_prod_cred`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_fal_busca_prod_cred.sql` |
| **LOC (1er CREATE)** | 81 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 7 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "busca fal — fallo/disputa, producto y crédito" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 2 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=4 · INFERIDO=1 · SINTÉTICO=0 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_fal_busca_prod_cred(
  p_numeroCliente              CHAR(20)
) RETURNING CHAR(8)     AS numeroproducto,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_numeroCliente` | `CHAR(20)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `resultado_numeroproducto` | `CHAR(8)` | L10 |
| `resultado_nombreproducto` | `CHAR(30)` | L11 |
| `resultado_cuentaproducto` | `CHAR(30)` | L12 |
| `resultado_statusCuenta` | `CHAR(30)` | L13 |
| `resultado_numero_tarjeta` | `CHAR(30)` | L14 |
| `resultado_status_tarjeta` | `CHAR(30)` | L15 |
| `iSqlErr` | `INTEGER` | L16 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sd_maecred` | `bdicred` | ⚠️ sí | SELECT | L55 |
| `sd_tarjeta` | `bdicred` | ⚠️ sí | SELECT | L63 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `fal` | ENTIDAD | fal — fallo/disputa (prefijo sp_fal_* — aclaraciones bancari | 🔵 CONVENCIÓN | nombre_sp |
| `busca` | ACCION | busca / localiza | 🔵 CONVENCIÓN | nombre_sp |
| `prod` | ENTIDAD | producto | 🟡 INFERIDO | nombre_sp |
| `cred` | ENTIDAD | crédito | 🔵 CONVENCIÓN | nombre_sp |

---

## `sp_fal_busca_prod_cred_1`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_fal_busca_prod_cred_1.sql` |
| **LOC (1er CREATE)** | 82 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 5 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "busca fal — fallo/disputa, producto y crédito" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 1 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=4 · INFERIDO=1 · SINTÉTICO=1 / 6 términos |

### Firma

```sql
CREATE PROCEDURE sp_fal_busca_prod_cred_1(
  p_numeroCliente              CHAR(20)
) RETURNING CHAR(8)     AS numeroproducto,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_numeroCliente` | `CHAR(20)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `resultado_numeroproducto` | `CHAR(8)` | L10 |
| `resultado_nombreproducto` | `CHAR(30)` | L11 |
| `resultado_cuentaproducto` | `CHAR(30)` | L12 |
| `resultado_statusCuenta` | `CHAR(30)` | L13 |
| `resultado_numero_tarjeta` | `CHAR(30)` | L14 |
| `resultado_status_tarjeta` | `CHAR(30)` | L15 |
| `iSqlErr` | `INTEGER` | L16 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sd_maecred` | `bdicred` | ⚠️ sí | SELECT | L59 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `fal` | ENTIDAD | fal — fallo/disputa (prefijo sp_fal_* — aclaraciones bancari | 🔵 CONVENCIÓN | nombre_sp |
| `busca` | ACCION | busca / localiza | 🔵 CONVENCIÓN | nombre_sp |
| `prod` | ENTIDAD | producto | 🟡 INFERIDO | nombre_sp |
| `cred` | ENTIDAD | crédito | 🔵 CONVENCIÓN | nombre_sp |
| `?_1` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_1` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_fal_busca_producto_cred_cliente`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_fal_busca_producto_cred_cliente.sql` |
| **LOC (1er CREATE)** | 64 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 6 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "busca fal — fallo/disputa, producto, crédito y cliente" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 2 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=6 · INFERIDO=0 · SINTÉTICO=0 / 6 términos |

### Firma

```sql
CREATE PROCEDURE sp_fal_busca_producto_cred_cliente(
  p_sNumeroCliente             CHAR(20)
  p_skip                       INT
) RETURNING CHAR(6) AS numeroProducto,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_sNumeroCliente` | `CHAR(20)` | `cliente`=cliente | 🔵 CONVENCIÓN |
| `p_skip` | `INT` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `resultado_numeroProducto` | `CHAR(6)` | L9 |
| `resultado_nombreProducto` | `CHAR(60)` | L10 |
| `resultado_numeroCuenta` | `CHAR(30)` | L11 |
| `resultado_numeroTarjeta` | `CHAR(30)` | L12 |
| `iSqlErr` | `INTEGER` | L13 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sd_maecred` | `bdicred` | ⚠️ sí | SELECT | L40 |
| `sd_tarjeta` | `bdicred` | ⚠️ sí | SELECT | L47 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `fal` | ENTIDAD | fal — fallo/disputa (prefijo sp_fal_* — aclaraciones bancari | 🔵 CONVENCIÓN | nombre_sp |
| `busca` | ACCION | busca / localiza | 🔵 CONVENCIÓN | nombre_sp |
| `producto` | ENTIDAD | producto | 🔵 CONVENCIÓN | nombre_sp |
| `cred` | ENTIDAD | crédito | 🔵 CONVENCIÓN | nombre_sp |
| `cliente` | ENTIDAD | cliente | 🔵 CONVENCIÓN | nombre_sp |

---

## `sp_fal_busca_producto_cred_cliente_1`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_fal_busca_producto_cred_cliente_1.sql` |
| **LOC (1er CREATE)** | 62 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 4 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "busca fal — fallo/disputa, producto, crédito y cliente" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 1 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=6 · INFERIDO=0 · SINTÉTICO=1 / 7 términos |

### Firma

```sql
CREATE PROCEDURE sp_fal_busca_producto_cred_cliente_1(
  p_sNumeroCliente             CHAR(20)
  p_skip                       INT
) RETURNING CHAR(6) AS numeroProducto,CHAR(60) AS nombreProducto, CHAR(30) AS numeroCuenta, CHAR(30) AS numeroTarjeta
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_sNumeroCliente` | `CHAR(20)` | `cliente`=cliente | 🔵 CONVENCIÓN |
| `p_skip` | `INT` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `resultado_numeroProducto` | `CHAR(6)` | L6 |
| `resultado_nombreProducto` | `CHAR(60)` | L7 |
| `resultado_numeroCuenta` | `CHAR(30)` | L8 |
| `resultado_numeroTarjeta` | `CHAR(30)` | L9 |
| `iSqlErr` | `INTEGER` | L10 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sd_maecred` | `bdicred` | ⚠️ sí | SELECT | L40 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `fal` | ENTIDAD | fal — fallo/disputa (prefijo sp_fal_* — aclaraciones bancari | 🔵 CONVENCIÓN | nombre_sp |
| `busca` | ACCION | busca / localiza | 🔵 CONVENCIÓN | nombre_sp |
| `producto` | ENTIDAD | producto | 🔵 CONVENCIÓN | nombre_sp |
| `cred` | ENTIDAD | crédito | 🔵 CONVENCIÓN | nombre_sp |
| `cliente` | ENTIDAD | cliente | 🔵 CONVENCIÓN | nombre_sp |
| `?_1` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_1` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_fal_busca_producto_deb_cheq_cliente`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_fal_busca_producto_deb_cheq_cliente.sql` |
| **LOC (1er CREATE)** | 69 |
| **Callgraph** | ✅ fan_in=0 / fan_out=20 |
| **Deps concatenadas** | 43 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "busca fal — fallo/disputa, producto, cheque y cliente (débito)" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 1 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=6 · INFERIDO=0 · SINTÉTICO=0 / 7 términos |

### Firma

```sql
CREATE PROCEDURE sp_fal_busca_producto_deb_cheq_cliente(
  p_sNumeroCliente             CHAR(20)
  p_skip                       INT
) RETURNING CHAR(6) AS numeroProducto,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_sNumeroCliente` | `CHAR(20)` | `cliente`=cliente | 🔵 CONVENCIÓN |
| `p_skip` | `INT` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `resultado_numeroProducto` | `CHAR(6)` | L9 |
| `resultado_nombreProducto` | `CHAR(60)` | L10 |
| `resultado_numeroCuenta` | `CHAR(30)` | L11 |
| `resultado_numeroTarjeta` | `CHAR(30)` | L12 |
| `resultado_cuenta_eje` | `CHAR(30)` | L13 |
| `resultado_cuenta_inv` | `CHAR(30)` | L14 |
| `iSqlErr` | `INTEGER` | L16 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sc_maechq` | `bdicheq` | ⚠️ sí | SELECT | L47 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `fal` | ENTIDAD | fal — fallo/disputa (prefijo sp_fal_* — aclaraciones bancari | 🔵 CONVENCIÓN | nombre_sp |
| `busca` | ACCION | busca / localiza | 🔵 CONVENCIÓN | nombre_sp |
| `producto` | ENTIDAD | producto | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `deb` | MODIF | débito | 🔵 CONVENCIÓN | nombre_sp |
| `cheq` | ENTIDAD | cheque | 🔵 CONVENCIÓN | nombre_sp |
| `cliente` | ENTIDAD | cliente | 🔵 CONVENCIÓN | nombre_sp |

---

## `sp_fal_busca_producto_deb_cheq_cliente_1`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_fal_busca_producto_deb_cheq_cliente_1.sql` |
| **LOC (1er CREATE)** | 73 |
| **Callgraph** | ✅ fan_in=0 / fan_out=20 |
| **Deps concatenadas** | 42 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "busca fal — fallo/disputa, producto, cheque y cliente (débito)" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 1 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=6 · INFERIDO=0 · SINTÉTICO=1 / 8 términos |

### Firma

```sql
CREATE PROCEDURE sp_fal_busca_producto_deb_cheq_cliente_1(
  p_sNumeroCliente             CHAR(20)
  p_skip                       INT
) RETURNING CHAR(6) AS numeroProducto,CHAR(60) AS nombreProducto, CHAR(30) AS numeroCuenta, CHAR(30) AS numeroTarjeta
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_sNumeroCliente` | `CHAR(20)` | `cliente`=cliente | 🔵 CONVENCIÓN |
| `p_skip` | `INT` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `resultado_numeroProducto` | `CHAR(6)` | L6 |
| `resultado_nombreProducto` | `CHAR(60)` | L7 |
| `resultado_numeroCuenta` | `CHAR(30)` | L8 |
| `resultado_numeroTarjeta` | `CHAR(30)` | L9 |
| `resultado_cuenta_eje` | `CHAR(30)` | L10 |
| `resultado_cuenta_inv` | `CHAR(30)` | L11 |
| `iSqlErr` | `INTEGER` | L13 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sc_maechq` | `bdicheq` | ⚠️ sí | SELECT | L45 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `fal` | ENTIDAD | fal — fallo/disputa (prefijo sp_fal_* — aclaraciones bancari | 🔵 CONVENCIÓN | nombre_sp |
| `busca` | ACCION | busca / localiza | 🔵 CONVENCIÓN | nombre_sp |
| `producto` | ENTIDAD | producto | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `deb` | MODIF | débito | 🔵 CONVENCIÓN | nombre_sp |
| `cheq` | ENTIDAD | cheque | 🔵 CONVENCIÓN | nombre_sp |
| `cliente` | ENTIDAD | cliente | 🔵 CONVENCIÓN | nombre_sp |
| `?_1` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_1` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_fal_busca_producto_deb_cheq_cliente_2`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_fal_busca_producto_deb_cheq_cliente_2.sql` |
| **LOC (1er CREATE)** | 66 |
| **Callgraph** | ✅ fan_in=0 / fan_out=20 |
| **Deps concatenadas** | 41 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "busca fal — fallo/disputa, producto, cheque y cliente (débito)" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 1 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=6 · INFERIDO=0 · SINTÉTICO=1 / 8 términos |

### Firma

```sql
CREATE PROCEDURE sp_fal_busca_producto_deb_cheq_cliente_2(
  p_sNumeroCliente             CHAR(20)
  p_skip                       INT
) RETURNING CHAR(6) AS numeroProducto,CHAR(60) AS nombreProducto, CHAR(30) AS numeroCuenta, CHAR(30) AS numeroTarjeta
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_sNumeroCliente` | `CHAR(20)` | `cliente`=cliente | 🔵 CONVENCIÓN |
| `p_skip` | `INT` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `resultado_numeroProducto` | `CHAR(6)` | L6 |
| `resultado_nombreProducto` | `CHAR(60)` | L7 |
| `resultado_numeroCuenta` | `CHAR(30)` | L8 |
| `resultado_numeroTarjeta` | `CHAR(30)` | L9 |
| `resultado_cuenta_eje` | `CHAR(30)` | L10 |
| `resultado_cuenta_inv` | `CHAR(30)` | L11 |
| `iSqlErr` | `INTEGER` | L13 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sc_maechq` | `bdicheq` | ⚠️ sí | SELECT | L45 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `fal` | ENTIDAD | fal — fallo/disputa (prefijo sp_fal_* — aclaraciones bancari | 🔵 CONVENCIÓN | nombre_sp |
| `busca` | ACCION | busca / localiza | 🔵 CONVENCIÓN | nombre_sp |
| `producto` | ENTIDAD | producto | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `deb` | MODIF | débito | 🔵 CONVENCIÓN | nombre_sp |
| `cheq` | ENTIDAD | cheque | 🔵 CONVENCIÓN | nombre_sp |
| `cliente` | ENTIDAD | cliente | 🔵 CONVENCIÓN | nombre_sp |
| `?_2` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_2` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_fal_busca_producto_deb_cheq_cliente_3`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_fal_busca_producto_deb_cheq_cliente_3.sql` |
| **LOC (1er CREATE)** | 69 |
| **Callgraph** | ✅ fan_in=0 / fan_out=20 |
| **Deps concatenadas** | 40 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "busca fal — fallo/disputa, producto, cheque y cliente (débito)" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 1 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=6 · INFERIDO=0 · SINTÉTICO=1 / 8 términos |

### Firma

```sql
CREATE PROCEDURE sp_fal_busca_producto_deb_cheq_cliente_3(
  p_sNumeroCliente             CHAR(20)
  p_skip                       INT
) RETURNING CHAR(6) AS numeroProducto,CHAR(60) AS nombreProducto, CHAR(30) AS numeroCuenta, CHAR(30) AS numeroTarjeta
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_sNumeroCliente` | `CHAR(20)` | `cliente`=cliente | 🔵 CONVENCIÓN |
| `p_skip` | `INT` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `resultado_numeroProducto` | `CHAR(6)` | L6 |
| `resultado_nombreProducto` | `CHAR(60)` | L7 |
| `resultado_numeroCuenta` | `CHAR(30)` | L8 |
| `resultado_numeroTarjeta` | `CHAR(30)` | L9 |
| `resultado_cuenta_eje` | `CHAR(30)` | L10 |
| `resultado_cuenta_inv` | `CHAR(30)` | L11 |
| `iSqlErr` | `INTEGER` | L13 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sc_maechq` | `bdicheq` | ⚠️ sí | SELECT | L44 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `fal` | ENTIDAD | fal — fallo/disputa (prefijo sp_fal_* — aclaraciones bancari | 🔵 CONVENCIÓN | nombre_sp |
| `busca` | ACCION | busca / localiza | 🔵 CONVENCIÓN | nombre_sp |
| `producto` | ENTIDAD | producto | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `deb` | MODIF | débito | 🔵 CONVENCIÓN | nombre_sp |
| `cheq` | ENTIDAD | cheque | 🔵 CONVENCIÓN | nombre_sp |
| `cliente` | ENTIDAD | cliente | 🔵 CONVENCIÓN | nombre_sp |
| `?_3` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_3` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_fal_busca_producto_pcuenta_deb_cte_fallecido`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_fal_busca_producto_pcuenta_deb_cte_fallecido.sql` |
| **LOC (1er CREATE)** | 104 |
| **Callgraph** | ✅ fan_in=0 / fan_out=20 |
| **Deps concatenadas** | 39 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "busca fal — fallo/disputa, producto, cuenta, cliente y identificador (débito)" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 1 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=7 · INFERIDO=0 · SINTÉTICO=3 / 12 términos |

### Firma

```sql
CREATE PROCEDURE sp_fal_busca_producto_pcuenta_deb_cte_fallecido(
  p_sNumCliente                CHAR(30)
  psCuentaBeneficiario         CHAR(30)
) RETURNING CHAR(6) AS numeroProducto,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_sNumCliente` | `CHAR(30)` | — | — |
| `psCuentaBeneficiario` | `CHAR(30)` | `cuenta`=cuenta | ✅ CÓDIGO |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `resultado_numeroProducto` | `CHAR(6)` | L16 |
| `resultado_nombreProducto` | `CHAR(60)` | L17 |
| `resultado_cuentaProducto` | `CHAR(60)` | L18 |
| `resultado_estatus` | `CHAR(30)` | L19 |
| `resultado_motivo` | `CHAR(100)` | L20 |
| `resultado_montoCargo` | `MONEY(18,2)` | L21 |
| `resultado_montoCalculado` | `MONEY(18,2)` | L22 |
| `resultado_montoPorcentaje` | `MONEY(18,2)` | L23 |
| `resultado_montoOriginal` | `MONEY(18,2)` | L24 |
| `resultado_montoActual` | `MONEY(18,2)` | L25 |
| `iSqlErr` | `INTEGER` | L27 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sc_maechq` | `bdicheq` | ⚠️ sí | SELECT | L77 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `fal` | ENTIDAD | fal — fallo/disputa (prefijo sp_fal_* — aclaraciones bancari | 🔵 CONVENCIÓN | nombre_sp |
| `busca` | ACCION | busca / localiza | 🔵 CONVENCIÓN | nombre_sp |
| `producto` | ENTIDAD | producto | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?_p` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `cuenta` | ENTIDAD | cuenta | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `deb` | MODIF | débito | 🔵 CONVENCIÓN | nombre_sp |
| `cte` | ENTIDAD | cliente | 🔵 CONVENCIÓN | nombre_sp |
| `fal` | ENTIDAD | fal — fallo/disputa (prefijo sp_fal_* — aclaraciones bancari | 🔵 CONVENCIÓN | nombre_sp |
| `?lec` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `id` | ENTIDAD | identificador (de) | 🔵 CONVENCIÓN | nombre_sp |
| `?o` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_p`, `?lec`, `?o` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_fal_busca_productos_deb_cte_fallecido`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_fal_busca_productos_deb_cte_fallecido.sql` |
| **LOC (1er CREATE)** | 100 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 2 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "busca fal — fallo/disputa, productos, cliente y identificador (débito)" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 2 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=6 · INFERIDO=0 · SINTÉTICO=2 / 10 términos |

### Firma

```sql
CREATE PROCEDURE sp_fal_busca_productos_deb_cte_fallecido(
  p_sNumeroCliente             CHAR(20)
) RETURNING CHAR(6) AS numeroProducto,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_sNumeroCliente` | `CHAR(20)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `resultado_numeroProducto` | `CHAR(6)` | L14 |
| `resultado_nombreProducto` | `CHAR(60)` | L15 |
| `resultado_numeroCuenta` | `CHAR(30)` | L16 |
| `resultado_estatus` | `CHAR(30)` | L17 |
| `resultado_motivo` | `CHAR(100)` | L18 |
| `resultado_montoActual` | `MONEY(16)` | L19 |
| `resultado_cuentaDeposito` | `CHAR(30)` | L20 |
| `resultado_fechaVenc` | `CHAR(30)` | L21 |
| `iSqlErr` | `INTEGER` | L22 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sc_maechq` | `bdicheq` | ⚠️ sí | SELECT | L64 |
| `fal_control_tramite` | `bdiaclaracion` | no | SELECT | L75 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `fal` | ENTIDAD | fal — fallo/disputa (prefijo sp_fal_* — aclaraciones bancari | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `busca` | ACCION | busca / localiza | 🔵 CONVENCIÓN | nombre_sp |
| `productos` | ENTIDAD | productos | 🔵 CONVENCIÓN | nombre_sp |
| `deb` | MODIF | débito | 🔵 CONVENCIÓN | nombre_sp |
| `cte` | ENTIDAD | cliente | 🔵 CONVENCIÓN | nombre_sp |
| `fal` | ENTIDAD | fal — fallo/disputa (prefijo sp_fal_* — aclaraciones bancari | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `?lec` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `id` | ENTIDAD | identificador (de) | 🔵 CONVENCIÓN | nombre_sp |
| `?o` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?lec`, `?o` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_fal_busca_productos_deb_cte_fallecido_1`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_fal_busca_productos_deb_cte_fallecido_1.sql` |
| **LOC (1er CREATE)** | 94 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 1 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "busca fal — fallo/disputa, productos, cliente y identificador (débito)" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 1 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=8 · INFERIDO=0 · SINTÉTICO=2 / 10 términos |

### Firma

```sql
CREATE PROCEDURE sp_fal_busca_productos_deb_cte_fallecido_1(
  p_sNumeroCliente             CHAR(20)
) RETURNING CHAR(6) AS numeroProducto,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_sNumeroCliente` | `CHAR(20)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `resultado_numeroProducto` | `CHAR(6)` | L14 |
| `resultado_nombreProducto` | `CHAR(60)` | L15 |
| `resultado_numeroCuenta` | `CHAR(30)` | L16 |
| `resultado_estatus` | `CHAR(30)` | L17 |
| `resultado_motivo` | `CHAR(100)` | L18 |
| `resultado_montoActual` | `MONEY(16)` | L19 |
| `resultado_cuentaDeposito` | `CHAR(30)` | L20 |
| `resultado_fechaVenc` | `CHAR(30)` | L21 |
| `iSqlErr` | `INTEGER` | L22 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sc_maechq` | `bdicheq` | ⚠️ sí | SELECT | L64 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `fal` | ENTIDAD | fal — fallo/disputa (prefijo sp_fal_* — aclaraciones bancari | 🔵 CONVENCIÓN | nombre_sp |
| `busca` | ACCION | busca / localiza | 🔵 CONVENCIÓN | nombre_sp |
| `productos` | ENTIDAD | productos | 🔵 CONVENCIÓN | nombre_sp |
| `deb` | MODIF | débito | 🔵 CONVENCIÓN | nombre_sp |
| `cte` | ENTIDAD | cliente | 🔵 CONVENCIÓN | nombre_sp |
| `fal` | ENTIDAD | fal — fallo/disputa (prefijo sp_fal_* — aclaraciones bancari | 🔵 CONVENCIÓN | nombre_sp |
| `?lec` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `id` | ENTIDAD | identificador (de) | 🔵 CONVENCIÓN | nombre_sp |
| `?o_1` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?lec`, `?o_1` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_fal_buscarclientespornumero`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_fal_buscarclientespornumero.sql` |
| **LOC (1er CREATE)** | 80 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 4 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "búsqueda/buscar fal — fallo/disputa, clientes y número" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 2 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=6 · INFERIDO=0 · SINTÉTICO=1 / 7 términos |

### Firma

```sql
CREATE PROCEDURE sp_fal_buscarclientespornumero(
  p_sNumeroCliente             CHAR(30)
) RETURNING CHAR(20) AS noCliente, CHAR(30) AS primerApellido, CHAR(30) AS segundoApellido, CHAR(30) AS primerNombre, CHAR(30) AS segundoNombre
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_sNumeroCliente` | `CHAR(30)` | `num`=número (de) | 🔵 CONVENCIÓN |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `resultado_numeroCliente` | `CHAR(20)` | L6 |
| `resultado_primerApellido` | `CHAR(30)` | L7 |
| `resultado_segundoApellido` | `CHAR(30)` | L8 |
| `resultado_primerNombre` | `CHAR(30)` | L9 |
| `resultado_segundoNombre` | `CHAR(30)` | L10 |
| `resultado_numerotransfer` | `CHAR(30)` | L11 |
| `iSqlErr` | `INTEGER` | L13 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_cliente` | `bdinteg` | ⚠️ sí | SELECT | L42 |
| `tf_maecte` | `bditransfer` | ⚠️ sí | SELECT | L50 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L46 | VALIDACIÓN_NULL | `IF ( resultado_primerNombre IS NULL) THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `fal` | ENTIDAD | fal — fallo/disputa (prefijo sp_fal_* — aclaraciones bancari | 🔵 CONVENCIÓN | nombre_sp |
| `buscar` | ACCION | búsqueda/buscar | 🔵 CONVENCIÓN | nombre_sp |
| `clientes` | ENTIDAD | clientes (plural) | 🔵 CONVENCIÓN | nombre_sp |
| `por` | MODIF | por (criterio) | 🔵 CONVENCIÓN | nombre_sp |
| `num` | ENTIDAD | número (de) | 🔵 CONVENCIÓN | nombre_sp |
| `?ero` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?ero` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_fal_buscarclientesportelefonotransfer`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_fal_buscarclientesportelefonotransfer.sql` |
| **LOC (1er CREATE)** | 83 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 3 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "búsqueda/buscar fal — fallo/disputa, clientes, teléfono y transferencia" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 2 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=5 · INFERIDO=0 · SINTÉTICO=0 / 7 términos |

### Firma

```sql
CREATE PROCEDURE sp_fal_buscarclientesportelefonotransfer(
  p_sNumeroTelefonoTransfer    CHAR(30)
) RETURNING CHAR(20) AS noCliente, CHAR(30) AS primerApellido, CHAR(30) AS segundoApellido, CHAR(30) AS primerNombre, CHAR(30) AS segundoNombre
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_sNumeroTelefonoTransfer` | `CHAR(30)` | `telefono`=teléfono · `transfer`=transferencia (forma larga de 'trans') | ✅ CÓDIGO |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `resultado_numeroCliente` | `CHAR(20)` | L6 |
| `resultado_primerApellido` | `CHAR(30)` | L7 |
| `resultado_segundoApellido` | `CHAR(30)` | L8 |
| `resultado_primerNombre` | `CHAR(30)` | L9 |
| `resultado_segundoNombre` | `CHAR(30)` | L10 |
| `telefono_Transfer` | `CHAR(30)` | L11 |
| `iSqlErr` | `INTEGER` | L12 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tf_maecte` | `bditransfer` | ⚠️ sí | SELECT | L41 |
| `si_cliente` | `bdinteg` | ⚠️ sí | SELECT | L52 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L47 | VALIDACIÓN_NULL | `IF ( resultado_numeroCliente IS NULL ) THEN` |  |
| L56 | VALIDACIÓN_NULL | `IF ( resultado_numeroCliente IS NULL ) THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `fal` | ENTIDAD | fal — fallo/disputa (prefijo sp_fal_* — aclaraciones bancari | 🔵 CONVENCIÓN | nombre_sp |
| `buscar` | ACCION | búsqueda/buscar | 🔵 CONVENCIÓN | nombre_sp |
| `clientes` | ENTIDAD | clientes (plural) | 🔵 CONVENCIÓN | nombre_sp |
| `por` | MODIF | por (criterio) | 🔵 CONVENCIÓN | nombre_sp |
| `telefono` | ENTIDAD | teléfono | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `transfer` | ENTIDAD | transferencia (forma larga de 'trans') | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |

---

## `sp_fal_cancelacion_cuenta_credito`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_fal_cancelacion_cuenta_credito.sql` |
| **LOC (1er CREATE)** | 1203 |
| **Callgraph** | ✅ fan_in=40 / fan_out=15 |
| **Deps concatenadas** | 26 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "cancela fal — fallo/disputa, cuenta y crédito" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 6 llamada(s): `sp_fal_asignar_analista_credito`, `sp_desbloqueocuenta`, `sp_consulta_saldos_general` |
| **Evidencia vocab** | CÓDIGO=4 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=0 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_fal_cancelacion_cuenta_credito(
  p_idSolicitud                INTEGER
  p_numero_credito             CHAR(20)
  p_Promotor                   CHAR(8)
  p_Supervisor                 CHAR(8)
  p_Sucursal                   CHAR(10)
  pky_resolucion               INTEGER
  cancelacion_manual           INTEGER
) RETURNING CHAR(6) as codigoRetorno,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_idSolicitud` | `INTEGER` | — | — |
| `p_numero_credito` | `CHAR(20)` | `credito`=crédito | ✅ CÓDIGO |
| `p_Promotor` | `CHAR(8)` | — | — |
| `p_Supervisor` | `CHAR(8)` | — | — |
| `p_Sucursal` | `CHAR(10)` | — | — |
| `pky_resolucion` | `INTEGER` | — | — |
| `cancelacion_manual` | `INTEGER` | `cancelacion`=cancela | ✅ CÓDIGO |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `codigoRetorno` | `CHAR(6)` | L8 |
| `mensajeRetorno` | `CHAR(250)` | L9 |
| `numeroCredito` | `CHAR(20)` | L10 |
| `numeroTarjeta` | `CHAR(16)` | L11 |
| `resultado_numero_cliente` | `CHAR(9)` | L13 |
| `resultado_foliocsuac` | `CHAR(12)` | L14 |
| `resultado_fky_usuario_analista` | `INTEGER` | L15 |
| `resultado_pky_control_tramite_cuenta` | `INTEGER` | L18 |
| `resultado_num_cta_cliente` | `CHAR(20)` | L19 |
| `resultado_num_cta_beneficiario` | `CHAR(20)` | L20 |
| `resultado_porcentaje_bene` | `DECIMAL(9,6)` | L21 |
| `resultado_tramite` | `INTEGER` | L22 |
| `resultado_tipo_producto_ctrl` | `INTEGER` | L23 |
| `resultado_exitoso` | `INTEGER` | L24 |
| `resultado_tipo_cancelacion` | `INTEGER` | L25 |
| `resultado_fecha_vencimiento` | `DATE` | L26 |
| `resultado_monto_original` | `MONEY(14,2)` | L27 |
| `resultado_monto_pagare` | `MONEY(14,2)` | L28 |
| `resultado_cargo_bandera` | `MONEY(14,2)` | L29 |
| `resultado_estatus_corporativo` | `INTEGER` | L30 |
| `resultado_estatus_sucursal` | `INTEGER` | L31 |
| `numero_credito` | `CHAR(20)` | L35 |
| `codigo_tipcred` | `CHAR(2)` | L36 |
| `fecha_origen` | `DATE` | L37 |
| `fecha_prox_pago` | `DATE` | L38 |
| *…83 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `fal_solicitud` | `bdiaclaracion` | no | SELECT | L208 |
| `acl_usuario` | `bdiaclaracion` | no | SELECT | L238 |
| `fal_control_tramite` | `bdiaclaracion` | no | SELECT | L269 |
| `fal_historico_solicitud` | `bdiaclaracion` | no | INSERT | L321 |
| `fal_control_digitaliza_doc` | `bdiaclaracion` | no | SELECT | L329 |
| `fal_grupo_documento` | `bdiaclaracion` | no | SELECT | L335 |
| `sd_maecred` | `bdicred` | ⚠️ sí | SELECT | L380 |
| `fal_rango_importe_accion` | `bdiaclaracion` | no | SELECT | L428 |
| `fal_saldo_anterior` | `bdiaclaracion` | no | INSERT | L464 |
| `fal_control_tramite` | `bdiaclaracion` | no | UPDATE | L495 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_fal_asignar_analista_credito` | `bdiaclaracion` | no | L349 |
| `sp_desbloqueocuenta` | `bdicred` | ⚠️ sí | L386 |
| `sp_consulta_saldos_general` | `bdicred` | ⚠️ sí | L395 |
| `sp_cancelarcredito` | `bdicred` | ⚠️ sí | L488 |
| `sp_bloqueocuenta` | `bdicred` | ⚠️ sí | L544 |
| `sp_cargo_abono_aclara` | `bdicred` | ⚠️ sí | L625 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L212 | VALIDACIÓN_NULL | `IF p_numero_credito IS NULL THEN` |  |
| L215 | VALIDACIÓN_NULL | `IF p_Promotor IS NULL THEN` |  |
| L218 | VALIDACIÓN_NULL | `IF p_Supervisor IS NULL THEN` |  |
| L221 | VALIDACIÓN_NULL | `IF p_Sucursal IS NULL THEN` |  |
| L279 | VALIDACIÓN_NULL | `IF resultado_pky_control_tramite_cuenta IS NULL THEN` |  |
| L458 | VALIDACIÓN_NULL | `IF resultado_cargo_bandera IS NULL THEN -- 4 VALIDACION DE CARGO NULL` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `fal` | ENTIDAD | fal — fallo/disputa (prefijo sp_fal_* — aclaraciones bancari | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `cancelacion` | ACCION | cancela | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `cuenta` | ENTIDAD | cuenta | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `credito` | ENTIDAD | crédito | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |

---

## `sp_fal_cancelacion_cuenta_debito`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_fal_cancelacion_cuenta_debito.sql` |
| **LOC (1er CREATE)** | 168 |
| **Callgraph** | ✅ fan_in=40 / fan_out=20 |
| **Deps concatenadas** | 38 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "cancela fal — fallo/disputa, cuenta y débito" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 4 llamada(s): `bloqueo_cta`, `sp_portabcancela`, `sp_cancelarservicio_bpi` |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=0 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_fal_cancelacion_cuenta_debito(
  pEmpresa                     CHAR(3)
  pCuenta                      CHAR(20)
  pMotivo                      CHAR(2)
  pPromotor                    CHAR(8)
  pSucursal                    CHAR(4)
) RETURNING CHAR(6)     AS codigoRetorno,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pEmpresa` | `CHAR(3)` | — | — |
| `pCuenta` | `CHAR(20)` | `cuenta`=cuenta | ✅ CÓDIGO |
| `pMotivo` | `CHAR(2)` | — | — |
| `pPromotor` | `CHAR(8)` | — | — |
| `pSucursal` | `CHAR(4)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `codigoRetorno` | `CHAR(6)` | L6 |
| `mensajeRetorno` | `CHAR(250)` | L7 |
| `saldo_actual_cuenta` | `MONEY(14,2)` | L8 |
| `iSqlErr` | `INTEGER` | L9 |
| `resultado_codigo_retorno` | `CHAR(3)` | L10 |
| `resultado_codigo_descripcion` | `CHAR(50)` | L11 |
| `codeRet` | `CHAR(5)` | L13 |
| `codeRet2` | `CHAR(5)` | L14 |
| `mensajeCodeRet` | `CHAR(80)` | L15 |
| `folioCancelacion` | `CHAR(22)` | L16 |
| `dFechaHoy` | `DATE` | L17 |
| `cod_ret_bloq` | `char(3)` | L18 |
| `resultado_estatus` | `INTEGER` | L19 |
| `resultado_num_cte` | `CHAR(9)` | L21 |
| `resultado_codRet_can_token` | `CHAR(5)` | L22 |
| `resultado_cta_ordenante` | `CHAR(20)` | L24 |
| `resultado_msg_cancela_porta` | `CHAR(100)` | L25 |
| `resultado_codRet_cancela_porta` | `CHAR(5)` | L26 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sc_maechq` | `bdicheq` | ⚠️ sí | SELECT | L80 |
| `sc_portabilidadnomina` | `bdicheq` | ⚠️ sí | SELECT | L103 |
| `si_codret` | `bdinteg` | ⚠️ sí | SELECT | L127 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `bloqueo_cta` | `bdicheq` | ⚠️ sí | L87 |
| `sp_portabcancela` | `bdicheq` | ⚠️ sí | L108 |
| `sp_cancelarservicio_bpi` | `bdibpi` | ⚠️ sí | L117 |
| `sp_cancelactachq` | `bdicheq` | ⚠️ sí | L121 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L55 | VALIDACIÓN_NULL | `IF pEmpresa IS NULL THEN` |  |
| L58 | VALIDACIÓN_NULL | `IF pCuenta IS NULL THEN` |  |
| L61 | VALIDACIÓN_NULL | `IF pMotivo IS NULL THEN` |  |
| L64 | VALIDACIÓN_NULL | `IF pSucursal IS NULL THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `fal` | ENTIDAD | fal — fallo/disputa (prefijo sp_fal_* — aclaraciones bancari | 🔵 CONVENCIÓN | nombre_sp |
| `cancelacion` | ACCION | cancela | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `cuenta` | ENTIDAD | cuenta | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `debito` | ENTIDAD | débito | 🔵 CONVENCIÓN | nombre_sp |

---

## `sp_fal_cancelacion_cuentas_manual`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_fal_cancelacion_cuentas_manual.sql` |
| **LOC (1er CREATE)** | 125 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 5 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "cancela fal — fallo/disputa y cuentas (manual)" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 2 llamada(s): `sp_fal_cancelacion_cuenta_credito`, `sp_fal_cancelacion_cuenta_debito` |
| **Evidencia vocab** | CÓDIGO=3 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=0 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_fal_cancelacion_cuentas_manual(
  pSucursal                    CHAR(4)
  pCuenta                      CHAR(20)
  pPromotor                    CHAR(8)
  pSupervisor                  CHAR(8)
  pky_resolucion               INTEGER
  p_idSolicitud                INTEGER
  pEmpresa                     CHAR(3)
  pMotivo                      CHAR(2)
  pTipoCuenta                  INTEGER
) RETURNING CHAR(6) as codigoRetorno, CHAR(250) as mensajeRetorno
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pSucursal` | `CHAR(4)` | — | — |
| `pCuenta` | `CHAR(20)` | — | — |
| `pPromotor` | `CHAR(8)` | — | — |
| `pSupervisor` | `CHAR(8)` | — | — |
| `pky_resolucion` | `INTEGER` | — | — |
| `p_idSolicitud` | `INTEGER` | — | — |
| `pEmpresa` | `CHAR(3)` | — | — |
| `pMotivo` | `CHAR(2)` | — | — |
| `pTipoCuenta` | `INTEGER` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `codigoRetorno` | `CHAR(6)` | L16 |
| `mensajeRetorno` | `CHAR(250)` | L17 |
| `tipoCuentaCredito` | `INTEGER` | L18 |
| `cancelacionManual` | `INTEGER` | L19 |
| `resultado_pky_usuario` | `INTEGER` | L20 |
| `resultado_foliocsuac` | `CHAR (11)` | L21 |
| `iSqlErr` | `INTEGER` | L23 |
| `codigoRetornoCrd` | `CHAR(6)` | L27 |
| `mensajeRetornoCrd` | `CHAR(250)` | L28 |
| `numeroCredito` | `CHAR(20)` | L29 |
| `numeroTarjeta` | `CHAR(16)` | L30 |
| `codigoRetornoDeb` | `CHAR(6)` | L32 |
| `mensajeRetornoDeb` | `CHAR(250)` | L33 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `fal_cat_tipo_tramite` | `bdiaclaracion` | no | SELECT | L37 |
| `acl_usuario` | `bdiaclaracion` | no | SELECT | L38 |
| `fal_solicitud` | `bdiaclaracion` | no | SELECT | L40 |
| `fal_historico_solicitud` | `bdiaclaracion` | no | INSERT | L67 |
| `fal_control_tramite` | `bdiaclaracion` | no | UPDATE | L70 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_fal_cancelacion_cuenta_credito` | `bdiaclaracion` | no | L62 |
| `sp_fal_cancelacion_cuenta_debito` | `bdiaclaracion` | no | L89 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `fal` | ENTIDAD | fal — fallo/disputa (prefijo sp_fal_* — aclaraciones bancari | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `cancelacion` | ACCION | cancela | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `cuentas` | ENTIDAD | cuentas (plural) | 🔵 CONVENCIÓN | nombre_sp |
| `manual` | MODIF | manual | ✅ CÓDIGO | nombre_sp, texto_cuerpo |

---

## `sp_fal_cons_servicios`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_fal_cons_servicios.sql` |
| **LOC (1er CREATE)** | 51 |
| **Callgraph** | ✅ fan_in=0 / fan_out=9 |
| **Deps concatenadas** | 23 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "consulta fal — fallo/disputa y servicio" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=1 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_fal_cons_servicios(
  p_numCliente                 CHAR(10)
) RETURNING CHAR(200) AS servicio,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_numCliente` | `CHAR(10)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `r_servicio` | `CHAR(200)` | L5 |
| `r_estatus` | `CHAR(40)` | L6 |
| `iSqlErr` | `INTEGER` | L7 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `dom_autorizaciones` | `bdidomi` | ⚠️ sí | SELECT | L30 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `fal` | ENTIDAD | fal — fallo/disputa (prefijo sp_fal_* — aclaraciones bancari | 🔵 CONVENCIÓN | nombre_sp |
| `cons` | ACCION | consulta | 🔵 CONVENCIÓN | nombre_sp |
| `servicio` | ENTIDAD | servicio | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `?s` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?s` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_fal_cons_servicios_1`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_fal_cons_servicios_1.sql` |
| **LOC (1er CREATE)** | 50 |
| **Callgraph** | ✅ fan_in=0 / fan_out=9 |
| **Deps concatenadas** | 22 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "consulta fal — fallo/disputa y servicio" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=1 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_fal_cons_servicios_1(
  p_numCliente                 CHAR(10)
) RETURNING CHAR(200) AS servicio,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_numCliente` | `CHAR(10)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `r_servicio` | `CHAR(200)` | L5 |
| `r_estatus` | `CHAR(40)` | L6 |
| `iSqlErr` | `INTEGER` | L7 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `bpi_tokensolicitud` | `bdibpi` | ⚠️ sí | SELECT | L28 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `fal` | ENTIDAD | fal — fallo/disputa (prefijo sp_fal_* — aclaraciones bancari | 🔵 CONVENCIÓN | nombre_sp |
| `cons` | ACCION | consulta | 🔵 CONVENCIÓN | nombre_sp |
| `servicio` | ENTIDAD | servicio | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `?s_1` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?s_1` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_fal_cons_servicios_2`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_fal_cons_servicios_2.sql` |
| **LOC (1er CREATE)** | 49 |
| **Callgraph** | ✅ fan_in=0 / fan_out=9 |
| **Deps concatenadas** | 21 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "consulta fal — fallo/disputa y servicio" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=1 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_fal_cons_servicios_2(
  p_numCliente                 CHAR(10)
) RETURNING CHAR(200) AS servicio,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_numCliente` | `CHAR(10)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `r_servicio` | `CHAR(200)` | L5 |
| `r_estatus` | `CHAR(40)` | L6 |
| `iSqlErr` | `INTEGER` | L7 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_bpiusuarios` | `bdinteg` | ⚠️ sí | SELECT | L29 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `fal` | ENTIDAD | fal — fallo/disputa (prefijo sp_fal_* — aclaraciones bancari | 🔵 CONVENCIÓN | nombre_sp |
| `cons` | ACCION | consulta | 🔵 CONVENCIÓN | nombre_sp |
| `servicio` | ENTIDAD | servicio | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `?s_2` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?s_2` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_fal_cons_servicios_3`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_fal_cons_servicios_3.sql` |
| **LOC (1er CREATE)** | 51 |
| **Callgraph** | ✅ fan_in=0 / fan_out=9 |
| **Deps concatenadas** | 20 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "consulta fal — fallo/disputa y servicio" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=1 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_fal_cons_servicios_3(
  p_numCliente                 CHAR(10)
) RETURNING CHAR(200) AS servicio,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_numCliente` | `CHAR(10)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `r_servicio` | `CHAR(200)` | L5 |
| `r_estatus` | `CHAR(40)` | L6 |
| `iSqlErr` | `INTEGER` | L7 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sc_portabilidadnomina` | `bdicheq` | ⚠️ sí | SELECT | L30 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `fal` | ENTIDAD | fal — fallo/disputa (prefijo sp_fal_* — aclaraciones bancari | 🔵 CONVENCIÓN | nombre_sp |
| `cons` | ACCION | consulta | 🔵 CONVENCIÓN | nombre_sp |
| `servicio` | ENTIDAD | servicio | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `?s_3` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?s_3` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_fal_cons_servicios_4`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_fal_cons_servicios_4.sql` |
| **LOC (1er CREATE)** | 68 |
| **Callgraph** | ✅ fan_in=0 / fan_out=9 |
| **Deps concatenadas** | 19 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "consulta fal — fallo/disputa y servicio" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=1 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_fal_cons_servicios_4(
  p_numCliente                 CHAR(10)
) RETURNING CHAR(200) AS servicio,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_numCliente` | `CHAR(10)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `r_servicio` | `CHAR(200)` | L5 |
| `r_estatus` | `CHAR(40)` | L6 |
| `iSqlErr` | `INTEGER` | L7 |
| `r_fecha_ingreso` | `DATE` | L8 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `fal_solicitud` | `bdiaclaracion` | no | SELECT | L28 |
| `pp_pagoprog` | `bdiprog` | ⚠️ sí | SELECT | L35 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `fal` | ENTIDAD | fal — fallo/disputa (prefijo sp_fal_* — aclaraciones bancari | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `cons` | ACCION | consulta | 🔵 CONVENCIÓN | nombre_sp |
| `servicio` | ENTIDAD | servicio | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `?s_4` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?s_4` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_fal_consulta_ciudades`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_fal_consulta_ciudades.sql` |
| **LOC (1er CREATE)** | 55 |
| **Callgraph** | ✅ fan_in=0 / fan_out=17 |
| **Deps concatenadas** | 37 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "consulta fal — fallo/disputa y ciudades" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=0 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_fal_consulta_ciudades(
  p_skip                       INT
  p_Estado                     CHAR(2)
) RETURNING CHAR(4) AS pais, CHAR(4) AS numeroEstado, CHAR(4) AS claveCiudad, CHAR(30) AS nombreCiudad
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_skip` | `INT` | — | — |
| `p_Estado` | `CHAR(2)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `resultado_pais` | `CHAR(4)` | L6 |
| `resultado_numeroEstado` | `CHAR(4)` | L7 |
| `resultado_claveCiudad` | `CHAR(4)` | L8 |
| `resultado_nombreCiudad` | `CHAR(30)` | L9 |
| `iSqlErr` | `INTEGER` | L10 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_ciudades` | `bdinteg` | ⚠️ sí | SELECT | L37 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `fal` | ENTIDAD | fal — fallo/disputa (prefijo sp_fal_* — aclaraciones bancari | 🔵 CONVENCIÓN | nombre_sp |
| `consulta` | ACCION | consulta / lee | 🔵 CONVENCIÓN | nombre_sp |
| `ciudades` | ENTIDAD | ciudades (catálogo) | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |

---

## `sp_fal_liquidacion_asignar_analista`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_fal_liquidacion_asignar_analista.sql` |
| **LOC (1er CREATE)** | 245 |
| **Callgraph** | ✅ fan_in=34 / fan_out=9 |
| **Deps concatenadas** | 16 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "asigna fal — fallo/disputa, liquidación y analista" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 5 tabla(s) con operaciones: SELECT, UPDATE |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=1 / 6 términos |

### Firma

```sql
CREATE PROCEDURE sp_fal_liquidacion_asignar_analista(
  resultado_fky_usuario_analista INTEGER
  p_idSolicitud                INTEGER
  resultado_num_cta_cliente    CHAR(20)
  p_cta_beneficiario           CHAR(20)
  p_usuario                    char(8)
  resultado_nombreBeneficiario CHAR(100)
  resultado_pky_control_tramite_cuenta INTEGER
) RETURNING CHAR(6) as codigoRetorno,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `resultado_fky_usuario_analista` | `INTEGER` | `analista`=analista | ✅ CÓDIGO |
| `p_idSolicitud` | `INTEGER` | — | — |
| `resultado_num_cta_cliente` | `CHAR(20)` | — | — |
| `p_cta_beneficiario` | `CHAR(20)` | — | — |
| `p_usuario` | `char(8)` | — | — |
| `resultado_nombreBeneficiario` | `CHAR(100)` | — | — |
| `resultado_pky_control_tramite_cuenta` | `INTEGER` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `codigoRetorno` | `CHAR(6)` | L11 |
| `mensajeRetorno` | `CHAR(250)` | L12 |
| `tipoAccion` | `CHAR(1)` | L13 |
| `cuentaBeneficiario` | `CHAR(20)` | L14 |
| `cuentaClienteFallecido` | `CHAR(20)` | L15 |
| `codigoRetornoCancelacion` | `CHAR(6)` | L16 |
| `mensajeRetornoCancelacion` | `CHAR(250)` | L17 |
| `nombreBeneficiario` | `CHAR(100)` | L18 |
| `resultado_asign_num_empleado` | `CHAR(9)` | L20 |
| `resultado_asign_usuario` | `INTEGER` | L22 |
| `resultado_asign_usuario_2` | `INTEGER` | L23 |
| `resultado_estatus_corporativo` | `INTEGER` | L24 |
| `resultado_doctos_corporativo` | `INTEGER` | L25 |
| `resultado_id_permiso` | `INTEGER` | L27 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `fal_control_tramite` | `bdiaclaracion` | no | SELECT | L51 |
| `acl_permiso` | `bdiaclaracion` | no | SELECT | L56 |
| `acl_usuario` | `bdiaclaracion` | no | SELECT | L65 |
| `fal_solicitud` | `bdiaclaracion` | no | UPDATE | L117 |
| `fal_control_tramite` | `bdiaclaracion` | no | UPDATE | L125 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L61 | VALIDACIÓN_NULL | `IF resultado_fky_usuario_analista = 0 OR resultado_fky_usuario_analista IS NULL  THEN` |  |
| L72 | VALIDACIÓN_NULL | `IF resultado_asign_usuario IS NULL THEN` |  |
| L77 | FÓRMULA | `LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO` |  |
| L102 | VALIDACIÓN_NULL | `IF resultado_asign_usuario_2 IS NULL THEN` |  |
| L150 | FÓRMULA | `LET cuentaBeneficiario  = p_cta_beneficiario;            -- CUENTA BENEFICIARIO` |  |
| L187 | FÓRMULA | `LET cuentaBeneficiario  = p_cta_beneficiario;            -- CUENTA BENEFICIARIO` |  |
| L223 | FÓRMULA | `LET cuentaBeneficiario  = p_cta_beneficiario;            -- CUENTA BENEFICIARIO` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `fal` | ENTIDAD | fal — fallo/disputa (prefijo sp_fal_* — aclaraciones bancari | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `liquidacion` | ENTIDAD | liquidación | 🔵 CONVENCIÓN | nombre_sp |
| `asigna` | ACCION | asigna | 🔵 CONVENCIÓN | nombre_sp |
| `?r_` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `analista` | ENTIDAD | analista | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?r_` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_fal_liquidacion_cuenta_debito`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_fal_liquidacion_cuenta_debito.sql` |
| **LOC (1er CREATE)** | 1362 |
| **Callgraph** | ✅ fan_in=0 / fan_out=17 |
| **Deps concatenadas** | 36 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "fal — fallo/disputa, liquidación, cuenta y débito" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 6 llamada(s): `sp_fal_liquidacion_asignar_analista`, `sp_fal_obtener_saldo_debito`, `sp_fal_cancelacion_cuenta_debito` |
| **Evidencia vocab** | CÓDIGO=4 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=0 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_fal_liquidacion_cuenta_debito(
  p_idSolicitud                INTEGER
  p_cta_cliente                CHAR(20)
  p_cta_beneficiario           CHAR(20)
  p_usuario                    char(8)
) RETURNING CHAR(6) as codigoRetorno,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_idSolicitud` | `INTEGER` | — | — |
| `p_cta_cliente` | `CHAR(20)` | — | — |
| `p_cta_beneficiario` | `CHAR(20)` | — | — |
| `p_usuario` | `char(8)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `codigoRetorno` | `CHAR(6)` | L12 |
| `mensajeRetorno` | `CHAR(250)` | L13 |
| `tipoAccion` | `CHAR(1)` | L14 |
| `cuentaBeneficiario` | `CHAR(20)` | L15 |
| `cuentaClienteFallecido` | `CHAR(20)` | L16 |
| `codigoRetornoCancelacion` | `CHAR(6)` | L17 |
| `mensajeRetornoCancelacion` | `CHAR(250)` | L18 |
| `nombreBeneficiario` | `CHAR(100)` | L19 |
| `resultado_numero_cliente` | `CHAR(9)` | L22 |
| `resultado_foliocsuac` | `CHAR(12)` | L23 |
| `resultado_fky_usuario_analista` | `INTEGER` | L24 |
| `resultado_num_sucursal` | `CHAR(10)` | L25 |
| `resultado_pky_control_tramite_cuenta` | `INTEGER` | L27 |
| `resultado_num_cta_cliente` | `CHAR(20)` | L28 |
| `resultado_num_cta_beneficiario` | `CHAR(20)` | L29 |
| `resultado_porcentaje_bene` | `DECIMAL(9,6)` | L30 |
| `resultado_tramite` | `INTEGER` | L31 |
| `resultado_exitoso` | `INTEGER` | L32 |
| `resultado_tipo_cancelacion` | `INTEGER` | L33 |
| `resultado_monto_original` | `MONEY(14,2)` | L35 |
| `resultado_monto_pagare` | `MONEY(14,2)` | L36 |
| `resultado_descripcion_detalle` | `CHAR(100)` | L37 |
| `v_numero_documentos_digitalizados_fallecido` | `INTEGER` | L40 |
| `v_numero_documentos_necesarios_fallecido` | `INTEGER` | L41 |
| `v_numero_documentos_necesarios_beneficiario` | `INTEGER` | L44 |
| *…53 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `acl_usuario` | `bdiaclaracion` | no | SELECT | L220 |
| `fal_beneficiario` | `bdiaclaracion` | no | SELECT | L229 |
| `fal_solicitud` | `bdiaclaracion` | no | SELECT | L236 |
| `fal_control_tramite` | `bdiaclaracion` | no | SELECT | L262 |
| `fal_control_digitaliza_doc` | `bdiaclaracion` | no | SELECT | L273 |
| `fal_cat_tipo_beneficiario` | `bdiaclaracion` | no | SELECT | L279 |
| `sc_maechq` | `bdicheq` | ⚠️ sí | SELECT | L300 |
| `fal_historico_solicitud` | `bdiaclaracion` | no | INSERT | L333 |
| `fal_aviso` | `bdiaclaracion` | no | SELECT | L370 |
| `fal_grupo_documento` | `bdiaclaracion` | no | SELECT | L377 |
| `fal_beneficiario` | `bdiaclaracion` | no | UPDATE | L501 |
| `fal_control_tramite` | `bdiaclaracion` | no | UPDATE | L504 |
| `fal_rango_importe_accion` | `bdiaclaracion` | no | SELECT | L603 |
| `systables` | `bdiaclaracion` | no | SELECT | L688 |
| `sc_tarjeta` | `bdicheq` | ⚠️ sí | SELECT | L700 |
| `acl_permiso` | `bdiaclaracion` | no | SELECT | L1074 |
| `fal_solicitud` | `bdiaclaracion` | no | UPDATE | L1132 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_fal_liquidacion_asignar_analista` | `bdiaclaracion` | no | L430 |
| `sp_fal_obtener_saldo_debito` | `bdiaclaracion` | no | L482 |
| `sp_fal_cancelacion_cuenta_debito` | `bdiaclaracion` | no | L508 |
| `bloqueo_cta` | `bdicheq` | ⚠️ sí | L546 |
| `cargo_ref` | `bdicheq` | ⚠️ sí | L726 |
| `abono_ref` | `bdicheq` | ⚠️ sí | L758 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L204 | FÓRMULA | `LET codigoRetorno       = iSqlErr;                       -- CODIGO DEFINIDO` |  |
| L207 | FÓRMULA | `LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO` |  |
| L309 | VALIDACIÓN_NULL | `IF p_cta_cliente IS NULL THEN` |  |
| L312 | VALIDACIÓN_NULL | `IF p_cta_beneficiario IS NULL THEN` |  |
| L315 | VALIDACIÓN_NULL | `IF p_usuario IS NULL THEN` |  |
| L322 | VALIDACIÓN_NULL | `IF p_idSolicitud is null OR TRIM(p_cta_cliente) = '' OR TRIM(p_cta_beneficiario) = '' OR TRIM(p_usua` |  |
| L401 | FÓRMULA | `LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO` |  |
| L530 | FÓRMULA | `LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO` |  |
| L549 | FÓRMULA | `LET codigoRetorno       = cod_resp_cancelacion_debito;                       -- CODIGO DEFINIDO` |  |
| L552 | FÓRMULA | `LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO` |  |
| L568 | FÓRMULA | `LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO` |  |
| L794 | FÓRMULA | `LET codigoRetorno       = cod_resp_cancelacion_debito;                       -- CODIGO DEFINIDO` |  |
| L797 | FÓRMULA | `LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO` |  |
| L821 | FÓRMULA | `LET codigoRetorno       = codret_blqcta;                       -- CODIGO DEFINIDO` |  |
| L824 | FÓRMULA | `LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO` |  |
| L892 | FÓRMULA | `LET codigoRetorno       = codret_cargo_ref;                       -- CODIGO DEFINIDO` |  |
| L895 | FÓRMULA | `LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO` |  |
| L917 | VALIDACIÓN_NULL | `IF resultado_aplicado IS NULL THEN` |  |
| L943 | FÓRMULA | `LET codigoRetorno       = codret_blqcta;                       -- CODIGO DEFINIDO` |  |
| L946 | FÓRMULA | `LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO` |  |
| L1019 | FÓRMULA | `LET codigoRetorno       = cod_resp_cancelacion_debito;                       -- CODIGO DEFINIDO` |  |
| L1022 | FÓRMULA | `LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO` |  |
| L1064 | VALIDACIÓN_NULL | `IF resultado_fky_usuario_analista IS NULL THEN` |  |
| L1076 | VALIDACIÓN_NULL | `IF resultado_asign_usuario IS NULL THEN` |  |
| L1081 | FÓRMULA | `LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO` |  |
| L1116 | VALIDACIÓN_NULL | `IF resultado_asign_usuario_2 IS NULL THEN` |  |
| L1198 | FÓRMULA | `LET cuentaBeneficiario  = p_cta_beneficiario;            -- CUENTA BENEFICIARIO` |  |
| L1291 | FÓRMULA | `LET cuentaBeneficiario  = p_cta_beneficiario;            -- CUENTA BENEFICIARIO` |  |
| L1318 | FÓRMULA | `LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO` |  |
| L1339 | FÓRMULA | `LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `fal` | ENTIDAD | fal — fallo/disputa (prefijo sp_fal_* — aclaraciones bancari | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `liquidacion` | ENTIDAD | liquidación | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `cuenta` | ENTIDAD | cuenta | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `debito` | ENTIDAD | débito | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |

---

## `sp_fal_liquidacion_cuenta_inversion`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_fal_liquidacion_cuenta_inversion.sql` |
| **LOC (1er CREATE)** | 1043 |
| **Callgraph** | ✅ fan_in=0 / fan_out=8 |
| **Deps concatenadas** | 11 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "fal — fallo/disputa, liquidación, cuenta y inversión" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 6 llamada(s): `sp_fal_liquidacion_asignar_analista`, `sp_fal_traspaso_cuentas_inversion`, `bloqueo_cta` |
| **Evidencia vocab** | CÓDIGO=4 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=0 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_fal_liquidacion_cuenta_inversion(
  p_idSolicitud                INTEGER
  p_cta_cliente                CHAR(20)
  p_cta_beneficiario           CHAR(20)
  p_usuario                    char(8)
) RETURNING CHAR(6) as codigoRetorno,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_idSolicitud` | `INTEGER` | — | — |
| `p_cta_cliente` | `CHAR(20)` | — | — |
| `p_cta_beneficiario` | `CHAR(20)` | — | — |
| `p_usuario` | `char(8)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `codigoRetorno` | `CHAR(6)` | L14 |
| `mensajeRetorno` | `CHAR(250)` | L15 |
| `tipoAccion` | `CHAR(1)` | L16 |
| `cuentaBeneficiario` | `CHAR(20)` | L17 |
| `cuentaClienteFallecido` | `CHAR(20)` | L18 |
| `codigoRetornoCancelacion` | `CHAR(6)` | L19 |
| `mensajeRetornoCancelacion` | `CHAR(250)` | L20 |
| `nombreBeneficiario` | `CHAR(100)` | L21 |
| `resultado_numero_cliente` | `CHAR(9)` | L24 |
| `resultado_foliocsuac` | `CHAR(12)` | L25 |
| `resultado_fky_usuario_analista` | `INTEGER` | L26 |
| `resultado_num_sucursal` | `CHAR(10)` | L27 |
| `resultado_pky_control_tramite_cuenta` | `INTEGER` | L30 |
| `resultado_num_cta_cliente` | `CHAR(20)` | L31 |
| `resultado_num_cta_beneficiario` | `CHAR(20)` | L32 |
| `resultado_porcentaje_bene` | `DECIMAL(9,6)` | L33 |
| `resultado_tramite` | `INTEGER` | L34 |
| `resultado_exitoso` | `INTEGER` | L35 |
| `resultado_tipo_cancelacion` | `INTEGER` | L36 |
| `resultado_monto_original` | `MONEY(14,2)` | L38 |
| `resultado_monto_cargo` | `MONEY(14,2)` | L39 |
| `resultado_monto_inversion` | `MONEY(14,2)` | L40 |
| `resultado_descripcion_detalle` | `CHAR(100)` | L41 |
| `v_numero_documentos_necesarios_beneficiario` | `INTEGER` | L43 |
| `v_numero_documentos_digitalizados_beneficiario` | `INTEGER` | L44 |
| *…64 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `acl_usuario` | `bdiaclaracion` | no | SELECT | L233 |
| `fal_historico_solicitud` | `bdiaclaracion` | no | INSERT | L261 |
| `fal_solicitud` | `bdiaclaracion` | no | SELECT | L271 |
| `fal_beneficiario` | `bdiaclaracion` | no | SELECT | L277 |
| `fal_control_tramite` | `bdiaclaracion` | no | SELECT | L308 |
| `sc_maechq` | `bdicheq` | ⚠️ sí | SELECT | L319 |
| `fal_control_digitaliza_doc` | `bdiaclaracion` | no | SELECT | L365 |
| `fal_cat_tipo_beneficiario` | `bdiaclaracion` | no | SELECT | L371 |
| `fal_aviso` | `bdiaclaracion` | no | SELECT | L391 |
| `fal_grupo_documento` | `bdiaclaracion` | no | SELECT | L398 |
| `fal_control_tramite` | `bdiaclaracion` | no | UPDATE | L519 |
| `fal_rango_importe_accion` | `bdiaclaracion` | no | SELECT | L595 |
| `systables` | `bdiaclaracion` | no | SELECT | L672 |
| `sc_tarjeta` | `bdicheq` | ⚠️ sí | SELECT | L678 |
| `fal_beneficiario` | `bdiaclaracion` | no | UPDATE | L786 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_fal_liquidacion_asignar_analista` | `bdiaclaracion` | no | L344 |
| `sp_fal_traspaso_cuentas_inversion` | `bdiaclaracion` | no | L493 |
| `bloqueo_cta` | `bdicheq` | ⚠️ sí | L608 |
| `cargo_ref` | `bdicheq` | ⚠️ sí | L708 |
| `abono_ref` | `bdicheq` | ⚠️ sí | L775 |
| `sp_fal_cancelacion_cuenta_debito` | `bdiaclaracion` | no | L810 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L241 | VALIDACIÓN_NULL | `IF p_cta_cliente IS NULL THEN` |  |
| L244 | VALIDACIÓN_NULL | `IF p_cta_beneficiario IS NULL THEN` |  |
| L247 | VALIDACIÓN_NULL | `IF p_usuario IS NULL THEN` |  |
| L251 | VALIDACIÓN_NULL | `IF p_idSolicitud is null OR TRIM(p_cta_cliente) = '' OR TRIM(p_cta_beneficiario) = '' OR TRIM(p_usua` |  |
| L342 | VALIDACIÓN_NULL | `IF TRIM(resultado_cuenta_eje) IS NULL OR  TRIM(resultado_cuenta_eje) = ''  THEN` |  |
| L347 | FÓRMULA | `LET codigoRetorno       = codigoRetorno;                       -- CODIGO DEFINIDO` |  |
| L350 | FÓRMULA | `LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO` |  |
| L440 | VALIDACIÓN_NULL | `IF resultado_pky_control_tramite_cuenta = 0 OR resultado_pky_control_tramite_cuenta IS NULL THEN -- ` |  |
| L445 | FÓRMULA | `LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO` |  |
| L491 | VALIDACIÓN_NULL | `IF (cargo_inversion IS NULL OR cargo_inversion = 0) AND (abono_cuenta_eje IS NULL OR abono_cuenta_ej` |  |
| L618 | FÓRMULA | `LET codigoRetorno       = codigoRetorno;                  -- CODIGO DEFINIDO` |  |
| L621 | FÓRMULA | `LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO` |  |
| L650 | FÓRMULA | `LET codigoRetorno       = codret_blqcta_eje;                  -- CODIGO DEFINIDO` |  |
| L653 | FÓRMULA | `LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO` |  |
| L732 | FÓRMULA | `LET codigoRetorno       = codigoRetorno;                       -- CODIGO DEFINIDO` |  |
| L735 | FÓRMULA | `LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO` |  |
| L808 | VALIDACIÓN_NULL | `IF contar_cuentas_exito = 0 OR contar_cuentas_exito IS NULL THEN --VALIDACION CUENTAS EJE EXITOSAS` |  |
| L823 | FÓRMULA | `LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO` |  |
| L838 | FÓRMULA | `LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO` |  |
| L866 | FÓRMULA | `LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO` |  |
| L883 | FÓRMULA | `LET codigoRetorno       = codigoRetorno;                       -- CODIGO DEFINIDO` |  |
| L886 | FÓRMULA | `LET cuentaBeneficiario  = resultado_num_cta_beneficiario ;            -- CUENTA BENEFICIARIO` |  |
| L917 | VALIDACIÓN_NULL | `IF contar_cuentas_exito = 0 OR contar_cuentas_exito IS NULL THEN --VALIDACION CUENTAS EJE EXITOSAS` |  |
| L932 | FÓRMULA | `LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO` |  |
| L946 | FÓRMULA | `LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO` |  |
| L974 | FÓRMULA | `LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO` |  |
| L994 | FÓRMULA | `LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO` |  |
| L1016 | FÓRMULA | `LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `fal` | ENTIDAD | fal — fallo/disputa (prefijo sp_fal_* — aclaraciones bancari | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `liquidacion` | ENTIDAD | liquidación | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `cuenta` | ENTIDAD | cuenta | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `inversion` | ENTIDAD | inversión (pagaré / plazo) | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |

---

## `sp_fal_liquidacion_cuenta_inversion_corporativo`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_fal_liquidacion_cuenta_inversion_corporativo.sql` |
| **LOC (1er CREATE)** | 974 |
| **Callgraph** | ✅ fan_in=0 / fan_out=9 |
| **Deps concatenadas** | 14 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "fal — fallo/disputa, liquidación, cuenta y inversión" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 5 llamada(s): `sp_fal_traspaso_cuentas_inversion`, `bloqueo_cta`, `cargo_ref` |
| **Evidencia vocab** | CÓDIGO=5 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=2 / 8 términos |

### Firma

```sql
CREATE PROCEDURE sp_fal_liquidacion_cuenta_inversion_corporativo(
  p_idSolicitud                INTEGER
  p_cta_cliente                CHAR(20)
  p_cta_beneficiario           CHAR(20)
  p_usuario                    char(8)
  p_procede                    INTEGER
  pky_resolucion               INTEGER
) RETURNING CHAR(6) as codigoRetorno,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_idSolicitud` | `INTEGER` | — | — |
| `p_cta_cliente` | `CHAR(20)` | — | — |
| `p_cta_beneficiario` | `CHAR(20)` | — | — |
| `p_usuario` | `char(8)` | — | — |
| `p_procede` | `INTEGER` | — | — |
| `pky_resolucion` | `INTEGER` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `codigoRetorno` | `CHAR(6)` | L14 |
| `mensajeRetorno` | `CHAR(250)` | L15 |
| `tipoAccion` | `CHAR(1)` | L16 |
| `cuentaBeneficiario` | `CHAR(20)` | L17 |
| `cuentaClienteFallecido` | `CHAR(20)` | L18 |
| `codigoRetornoCancelacion` | `CHAR(6)` | L19 |
| `mensajeRetornoCancelacion` | `CHAR(250)` | L20 |
| `nombreBeneficiario` | `CHAR(100)` | L21 |
| `monto_a_buscar_regla_negocio` | `MONEY(14,2)` | L22 |
| `resultado_nombre_accion_procede` | `CHAR(20)` | L23 |
| `resultado_numero_cliente` | `CHAR(9)` | L25 |
| `resultado_foliocsuac` | `CHAR(12)` | L26 |
| `resultado_fky_usuario_analista` | `INTEGER` | L27 |
| `resultado_num_sucursal` | `CHAR(10)` | L28 |
| `resultado_pky_resolucion` | `INTEGER` | L29 |
| `resultado_pky_control_tramite_cuenta` | `INTEGER` | L32 |
| `resultado_num_cta_cliente` | `CHAR(20)` | L33 |
| `resultado_num_cta_beneficiario` | `CHAR(20)` | L34 |
| `resultado_porcentaje_bene` | `DECIMAL(9,6)` | L35 |
| `resultado_tramite` | `INTEGER` | L36 |
| `resultado_exitoso` | `INTEGER` | L37 |
| `resultado_tipo_cancelacion` | `INTEGER` | L38 |
| `resultado_monto_original` | `MONEY(14,2)` | L40 |
| `resultado_monto_inversion` | `MONEY(14,2)` | L41 |
| `resultado_descripcion_detalle` | `CHAR(100)` | L42 |
| *…63 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `acl_usuario` | `bdiaclaracion` | no | SELECT | L231 |
| `fal_solicitud` | `bdiaclaracion` | no | SELECT | L240 |
| `fal_beneficiario` | `bdiaclaracion` | no | SELECT | L246 |
| `fal_control_tramite` | `bdiaclaracion` | no | SELECT | L277 |
| `sc_maechq` | `bdicheq` | ⚠️ sí | SELECT | L293 |
| `fal_historico_solicitud` | `bdiaclaracion` | no | INSERT | L333 |
| `fal_control_digitaliza_doc` | `bdiaclaracion` | no | SELECT | L360 |
| `fal_cat_tipo_beneficiario` | `bdiaclaracion` | no | SELECT | L366 |
| `fal_aviso` | `bdiaclaracion` | no | SELECT | L386 |
| `fal_grupo_documento` | `bdiaclaracion` | no | SELECT | L393 |
| `fal_control_tramite` | `bdiaclaracion` | no | UPDATE | L496 |
| `fal_rango_importe_accion` | `bdiaclaracion` | no | SELECT | L581 |
| `fal_cat_accion` | `bdiaclaracion` | no | SELECT | L589 |
| `systables` | `bdiaclaracion` | no | SELECT | L634 |
| `sc_tarjeta` | `bdicheq` | ⚠️ sí | SELECT | L643 |
| `fal_beneficiario` | `bdiaclaracion` | no | UPDATE | L769 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_fal_traspaso_cuentas_inversion` | `bdiaclaracion` | no | L475 |
| `bloqueo_cta` | `bdicheq` | ⚠️ sí | L601 |
| `cargo_ref` | `bdicheq` | ⚠️ sí | L668 |
| `abono_ref` | `bdicheq` | ⚠️ sí | L735 |
| `sp_fal_cancelacion_cuenta_debito` | `bdiaclaracion` | no | L832 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L234 | FÓRMULA | `LET resultado_pky_usuario = 0;    -- EN CASO DE QUE NO SE ENCUENTRE EL USUARIO EN LA BASE DE DATOS D` |  |
| L313 | VALIDACIÓN_NULL | `IF p_cta_cliente IS NULL THEN` |  |
| L316 | VALIDACIÓN_NULL | `IF p_cta_beneficiario IS NULL THEN` |  |
| L319 | VALIDACIÓN_NULL | `IF p_usuario IS NULL THEN` |  |
| L323 | VALIDACIÓN_NULL | `IF p_idSolicitud is null OR TRIM(p_cta_cliente) = '' OR TRIM(p_cta_beneficiario) = '' OR TRIM(p_usua` |  |
| L340 | VALIDACIÓN_NULL | `IF TRIM(resultado_cuenta_eje) IS NULL OR  TRIM(resultado_cuenta_eje) = ''  THEN` |  |
| L344 | FÓRMULA | `LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO` |  |
| L427 | VALIDACIÓN_NULL | `IF resultado_pky_control_tramite_cuenta = 0 OR resultado_pky_control_tramite_cuenta IS NULL THEN -- ` |  |
| L432 | FÓRMULA | `LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO` |  |
| L472 | VALIDACIÓN_NULL | `IF (cargo_inversion IS NULL OR cargo_inversion = 0) AND (abono_cuenta_eje IS NULL OR abono_cuenta_ej` |  |
| L614 | FÓRMULA | `LET codigoRetorno       = codret_blqcta_eje;                  -- CODIGO DEFINIDO` |  |
| L617 | FÓRMULA | `LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO` |  |
| L687 | FÓRMULA | `LET codigoRetorno       = codret_cargo_ref;                       -- CODIGO DEFINIDO` |  |
| L690 | FÓRMULA | `LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO` |  |
| L717 | VALIDACIÓN_NULL | `IF resultado_aplicado != 1 OR resultado_aplicado IS NULL THEN --VALIDACIN ABONO AL BENEFICIARIO` |  |
| L749 | FÓRMULA | `LET codigoRetorno       = vcodret_abono;                       -- CODIGO DEFINIDO` |  |
| L752 | FÓRMULA | `LET cuentaBeneficiario  = resultado_num_cta_beneficiario ;            -- CUENTA BENEFICIARIO` |  |
| L784 | FÓRMULA | `LET cuentaBeneficiario  = resultado_num_cta_beneficiario ;            -- CUENTA BENEFICIARIO` |  |
| L808 | FÓRMULA | `LET cuentaBeneficiario  = resultado_num_cta_beneficiario ;            -- CUENTA BENEFICIARIO` |  |
| L830 | VALIDACIÓN_NULL | `IF contar_cuentas_exito = 0 or contar_cuentas_exito IS NULL AND saldo_cuenta_eje = 0 THEN` |  |
| L845 | FÓRMULA | `LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO` |  |
| L881 | FÓRMULA | `LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO` |  |
| L905 | FÓRMULA | `LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO` |  |
| L927 | FÓRMULA | `LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO` |  |
| L946 | FÓRMULA | `LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `fal` | ENTIDAD | fal — fallo/disputa (prefijo sp_fal_* — aclaraciones bancari | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `liquidacion` | ENTIDAD | liquidación | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `cuenta` | ENTIDAD | cuenta | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `inversion` | ENTIDAD | inversión (pagaré / plazo) | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `?_cor` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `por` | MODIF | por (criterio) | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?ativo` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_cor`, `?ativo` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_fal_liquidacion_cuenta_pagare`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_fal_liquidacion_cuenta_pagare.sql` |
| **LOC (1er CREATE)** | 881 |
| **Callgraph** | ✅ fan_in=0 / fan_out=9 |
| **Deps concatenadas** | 24 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "fal — fallo/disputa, liquidación, cuenta y pagaré" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 5 llamada(s): `sp_fal_cancelacion_cuenta_debito`, `bloqueo_cta`, `sp_fal_liquidacion_asignar_analista` |
| **Evidencia vocab** | CÓDIGO=4 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=0 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_fal_liquidacion_cuenta_pagare(
  p_idSolicitud                INTEGER
  p_cta_cliente                CHAR(20)
  p_cta_beneficiario           CHAR(20)
  p_usuario                    CHAR(8)
  p_procede                    INTEGER
  pky_resolucion               INTEGER
) RETURNING CHAR(6) as codigoRetorno,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_idSolicitud` | `INTEGER` | — | — |
| `p_cta_cliente` | `CHAR(20)` | — | — |
| `p_cta_beneficiario` | `CHAR(20)` | — | — |
| `p_usuario` | `CHAR(8)` | — | — |
| `p_procede` | `INTEGER` | — | — |
| `pky_resolucion` | `INTEGER` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `codigoRetorno` | `CHAR(6)` | L11 |
| `mensajeRetorno` | `CHAR(100)` | L12 |
| `cuentaBeneficiario` | `CHAR(20)` | L13 |
| `cuentaClienteFallecido` | `CHAR(20)` | L14 |
| `nombreBeneficiario` | `CHAR(100)` | L15 |
| `codigoRetornoCancelacion` | `CHAR(6)` | L16 |
| `mensajeRetornoCancelacion` | `CHAR(250)` | L17 |
| `resultado_nombreBeneficiario` | `CHAR(100)` | L19 |
| `resultado_numero_cliente` | `CHAR(9)` | L21 |
| `resultado_foliocsuac` | `CHAR(12)` | L22 |
| `resultado_fky_usuario_analista` | `INTEGER` | L23 |
| `resultado_num_sucursal` | `CHAR(10)` | L24 |
| `resultado_pky_control_tramite_cuenta` | `INTEGER` | L27 |
| `resultado_num_cta_cliente` | `CHAR(20)` | L28 |
| `resultado_num_cta_beneficiario` | `CHAR(20)` | L29 |
| `resultado_porcentaje_bene` | `DECIMAL(9,6)` | L30 |
| `resultado_tramite` | `INTEGER` | L31 |
| `resultado_exitoso` | `INTEGER` | L32 |
| `resultado_tipo_cancelacion` | `INTEGER` | L33 |
| `resultado_monto_original` | `MONEY(14,2)` | L35 |
| `resultado_monto_pagare` | `MONEY(14,2)` | L36 |
| `resultado_liquidacion_pagare` | `INTEGER` | L37 |
| `v_numero_documentos_necesarios_beneficiario` | `INTEGER` | L40 |
| `v_numero_documentos_digitalizados_beneficiario` | `INTEGER` | L41 |
| `monto_pago_bene` | `MONEY(14,2)` | L44 |
| *…48 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `acl_usuario` | `bdiaclaracion` | no | SELECT | L198 |
| `sv_maeinstrucc` | `bdinvers` | ⚠️ sí | SELECT | L207 |
| `fal_beneficiario` | `bdiaclaracion` | no | SELECT | L213 |
| `fal_solicitud` | `bdiaclaracion` | no | SELECT | L220 |
| `fal_control_tramite` | `bdiaclaracion` | no | SELECT | L246 |
| `fal_control_digitaliza_doc` | `bdiaclaracion` | no | SELECT | L258 |
| `fal_cat_tipo_beneficiario` | `bdiaclaracion` | no | SELECT | L264 |
| `sc_maechq` | `bdicheq` | ⚠️ sí | SELECT | L276 |
| `fal_cat_estatus_cuenta` | `bdiaclaracion` | no | SELECT | L287 |
| `fal_historico_solicitud` | `bdiaclaracion` | no | INSERT | L313 |
| `fal_rango_importe_accion` | `bdiaclaracion` | no | SELECT | L366 |
| `fal_cat_accion` | `bdiaclaracion` | no | SELECT | L377 |
| `fal_aviso` | `bdiaclaracion` | no | SELECT | L394 |
| `fal_grupo_documento` | `bdiaclaracion` | no | SELECT | L401 |
| `fal_beneficiario` | `bdiaclaracion` | no | UPDATE | L436 |
| `fal_control_tramite` | `bdiaclaracion` | no | UPDATE | L439 |
| `systables` | `bdiaclaracion` | no | SELECT | L544 |
| `sc_tarjeta` | `bdicheq` | ⚠️ sí | SELECT | L555 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_fal_cancelacion_cuenta_debito` | `bdiaclaracion` | no | L443 |
| `bloqueo_cta` | `bdicheq` | ⚠️ sí | L490 |
| `sp_fal_liquidacion_asignar_analista` | `bdiaclaracion` | no | L495 |
| `cargo_ref` | `bdicheq` | ⚠️ sí | L580 |
| `abono_ref` | `bdicheq` | ⚠️ sí | L608 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L291 | VALIDACIÓN_NULL | `IF p_cta_cliente IS NULL THEN` |  |
| L294 | VALIDACIÓN_NULL | `IF p_cta_beneficiario IS NULL THEN` |  |
| L297 | VALIDACIÓN_NULL | `IF p_usuario IS NULL THEN` |  |
| L303 | VALIDACIÓN_NULL | `IF p_idSolicitud is null OR TRIM(p_cta_cliente) = '' OR TRIM(p_cta_beneficiario) = '' OR TRIM(p_usua` |  |
| L418 | FÓRMULA | `LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO` |  |
| L452 | FÓRMULA | `LET codigoRetorno       = cod_resp_cancelacion_debito;                       -- CODIGO DEFINIDO` |  |
| L454 | FÓRMULA | `LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO` |  |
| L471 | FÓRMULA | `LET codigoRetorno       = cod_resp_cancelacion_debito;                       -- CODIGO DEFINIDO` |  |
| L473 | FÓRMULA | `LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO` |  |
| L643 | FÓRMULA | `LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO` |  |
| L668 | FÓRMULA | `LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO` |  |
| L713 | FÓRMULA | `LET codigoRetorno       = codret_cargo_ref;                       -- CODIGO DEFINIDO` |  |
| L715 | FÓRMULA | `LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO` |  |
| L774 | FÓRMULA | `LET codigoRetorno       = codret_blqcta;                       -- CODIGO DEFINIDO` |  |
| L776 | FÓRMULA | `LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO` |  |
| L795 | FÓRMULA | `LET codigoRetorno       = codret_blqcta;                       -- CODIGO DEFINIDO` |  |
| L797 | FÓRMULA | `LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO` |  |
| L836 | FÓRMULA | `LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO` |  |
| L855 | FÓRMULA | `LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `fal` | ENTIDAD | fal — fallo/disputa (prefijo sp_fal_* — aclaraciones bancari | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `liquidacion` | ENTIDAD | liquidación | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `cuenta` | ENTIDAD | cuenta | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `pagare` | ENTIDAD | pagaré | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |

---

## `sp_fal_liquidacion_cuenta_pagare_cambio_inst`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_fal_liquidacion_cuenta_pagare_cambio_inst.sql` |
| **LOC (1er CREATE)** | 411 |
| **Callgraph** | ✅ fan_in=0 / fan_out=16 |
| **Deps concatenadas** | 28 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "insertar fal — fallo/disputa, liquidación, cuenta, pagaré y cambio" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `inserta` → `INSERT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=6 · CONVENCIÓN=0 · INFERIDO=1 · SINTÉTICO=1 / 8 términos |

### Firma

```sql
CREATE PROCEDURE sp_fal_liquidacion_cuenta_pagare_cambio_inst(
  p_idSolicitud                INTEGER
  p_cta_cliente                CHAR(20)
  p_cta_beneficiario           CHAR(20)
  p_usuario                    char(8)
) RETURNING CHAR(6) as codigoRetorno,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_idSolicitud` | `INTEGER` | — | — |
| `p_cta_cliente` | `CHAR(20)` | — | — |
| `p_cta_beneficiario` | `CHAR(20)` | — | — |
| `p_usuario` | `char(8)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `codigoRetorno` | `CHAR(6)` | L10 |
| `mensajeRetorno` | `CHAR(250)` | L11 |
| `cuentaBeneficiario` | `CHAR(20)` | L12 |
| `cuentaClienteFallecido` | `CHAR(20)` | L13 |
| `nombreBeneficiario` | `CHAR(100)` | L14 |
| `resultado_pky_control_tramite` | `INTEGER` | L16 |
| `resultado_num_cliente` | `CHAR(9)` | L18 |
| `resultado_folio_csuac` | `CHAR(12)` | L19 |
| `resultado_fky_usuario_analista` | `INTEGER` | L20 |
| `resultado_num_sucursal` | `CHAR(5)` | L21 |
| `resultado_cta_cheques` | `CHAR(20)` | L23 |
| `p_empresa` | `CHAR(3)` | L25 |
| `p_ejecutivo` | `CHAR(3)` | L26 |
| `resultado_sp_cambia_instrucc` | `CHAR(5)` | L28 |
| `resultado_asign_usuario` | `INTEGER` | L30 |
| `resultado_asign_num_empleado` | `CHAR(9)` | L31 |
| `resultado_asign_usuario_2` | `INTEGER` | L33 |
| `resultado_nume_cliente` | `CHAR(9)` | L35 |
| `resultado_nombreBeneficiario` | `CHAR(100)` | L36 |
| `resultado_fecha_vencimiento` | `DATE` | L38 |
| `resultado_cuenta_estatus` | `CHAR(1)` | L40 |
| `resultado_cuenta_motivo` | `CHAR(2)` | L41 |
| `codret_blqcta` | `CHAR(6)` | L44 |
| `menret_blqcta` | `CHAR(250)` | L45 |
| `resultado_pky_usuario` | `INTEGER` | L47 |
| *…2 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `acl_usuario` | `bdiaclaracion` | no | SELECT | L95 |
| `fal_beneficiario` | `bdiaclaracion` | no | SELECT | L104 |
| `fal_solicitud` | `bdiaclaracion` | no | SELECT | L111 |
| `fal_control_tramite` | `bdiaclaracion` | no | SELECT | L117 |
| `sv_maeinv` | `bdinvers` | ⚠️ sí | SELECT | L128 |
| `sc_maechq` | `bdicheq` | ⚠️ sí | SELECT | L148 |
| `fal_historico_solicitud` | `bdiaclaracion` | no | INSERT | L170 |
| `acl_permiso` | `bdiaclaracion` | no | SELECT | L289 |
| `fal_solicitud` | `bdiaclaracion` | no | UPDATE | L352 |
| `fal_control_tramite` | `bdiaclaracion` | no | UPDATE | L355 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `bloqueo_cta` | `bdicheq` | ⚠️ sí | L182 |
| `cambinstrucc` | `bdinvers` | ⚠️ sí | L187 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L98 | FÓRMULA | `LET resultado_pky_usuario = 0;    -- EN CASO DE QUE NO SE ENCUENTRE EL USUARIO EN LA BASE DE DATOS D` |  |
| L151 | VALIDACIÓN_NULL | `IF p_cta_cliente IS NULL THEN` |  |
| L154 | VALIDACIÓN_NULL | `IF p_cta_beneficiario IS NULL THEN` |  |
| L157 | VALIDACIÓN_NULL | `IF p_usuario IS NULL THEN` |  |
| L162 | VALIDACIÓN_NULL | `IF p_idSolicitud is null OR TRIM(p_cta_cliente) = '' OR TRIM(p_cta_beneficiario) = '' OR TRIM(p_usua` |  |
| L287 | VALIDACIÓN_NULL | `IF resultado_fky_usuario_analista IS NULL THEN` |  |
| L336 | VALIDACIÓN_NULL | `IF resultado_asign_usuario_2 IS NULL THEN` |  |
| L381 | FÓRMULA | `LET cuentaBeneficiario  = p_cta_beneficiario;            -- CUENTA BENEFICIARIO` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `fal` | ENTIDAD | fal — fallo/disputa (prefijo sp_fal_* — aclaraciones bancari | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `liquidacion` | ENTIDAD | liquidación | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `cuenta` | ENTIDAD | cuenta | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `pagare` | ENTIDAD | pagaré | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `cambio` | ENTIDAD | cambio (de estatus, domicilio, etc.) | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `ins` | ACCION | insertar | 🟡 INFERIDO | nombre_sp |
| `?t` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?t` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_fal_liquidacion_debito_corporativo`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_fal_liquidacion_debito_corporativo.sql` |
| **LOC (1er CREATE)** | 1113 |
| **Callgraph** | ✅ fan_in=0 / fan_out=9 |
| **Deps concatenadas** | 12 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "fal — fallo/disputa, liquidación y débito" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 5 llamada(s): `sp_fal_obtener_saldo_debito`, `sp_fal_cancelacion_cuenta_debito`, `bloqueo_cta` |
| **Evidencia vocab** | CÓDIGO=4 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=2 / 7 términos |

### Firma

```sql
CREATE PROCEDURE sp_fal_liquidacion_debito_corporativo(
  p_idSolicitud                INTEGER
  p_cta_cliente                CHAR(20)
  p_cta_beneficiario           CHAR(20)
  p_usuario                    char(8)
  p_procede                    INTEGER
  pky_resolucion               INTEGER
) RETURNING CHAR(6) as codigoRetorno,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_idSolicitud` | `INTEGER` | — | — |
| `p_cta_cliente` | `CHAR(20)` | — | — |
| `p_cta_beneficiario` | `CHAR(20)` | — | — |
| `p_usuario` | `char(8)` | — | — |
| `p_procede` | `INTEGER` | — | — |
| `pky_resolucion` | `INTEGER` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `codigoRetorno` | `CHAR(6)` | L11 |
| `mensajeRetorno` | `CHAR(250)` | L12 |
| `tipoAccion` | `CHAR(1)` | L13 |
| `cuentaBeneficiario` | `CHAR(20)` | L14 |
| `cuentaClienteFallecido` | `CHAR(20)` | L15 |
| `codigoRetornoCancelacion` | `CHAR(6)` | L16 |
| `mensajeRetornoCancelacion` | `CHAR(250)` | L17 |
| `nombreBeneficiario` | `CHAR(100)` | L18 |
| `iSqlErr` | `INTEGER` | L19 |
| `resultado_numero_cliente` | `CHAR(9)` | L21 |
| `resultado_foliocsuac` | `CHAR(12)` | L22 |
| `resultado_fky_usuario_analista` | `INTEGER` | L23 |
| `resultado_num_sucursal` | `CHAR(10)` | L24 |
| `resultado_pky_control_tramite_cuenta` | `INTEGER` | L26 |
| `resultado_num_cta_cliente` | `CHAR(20)` | L27 |
| `resultado_num_cta_beneficiario` | `CHAR(20)` | L28 |
| `resultado_porcentaje_bene` | `DECIMAL(9,6)` | L29 |
| `resultado_tramite` | `INTEGER` | L30 |
| `resultado_exitoso` | `INTEGER` | L31 |
| `resultado_tipo_cancelacion` | `INTEGER` | L32 |
| `resultado_monto_original` | `MONEY(14,2)` | L34 |
| `resultado_monto_pagare` | `MONEY(14,2)` | L35 |
| `v_numero_documentos_digitalizados_fallecido` | `INTEGER` | L37 |
| `v_numero_documentos_necesarios_fallecido` | `INTEGER` | L38 |
| `v_numero_documentos_necesarios_beneficiario` | `INTEGER` | L41 |
| *…56 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `acl_usuario` | `bdiaclaracion` | no | SELECT | L225 |
| `fal_beneficiario` | `bdiaclaracion` | no | SELECT | L234 |
| `fal_solicitud` | `bdiaclaracion` | no | SELECT | L241 |
| `fal_control_tramite` | `bdiaclaracion` | no | SELECT | L267 |
| `fal_control_digitaliza_doc` | `bdiaclaracion` | no | SELECT | L278 |
| `fal_cat_tipo_beneficiario` | `bdiaclaracion` | no | SELECT | L284 |
| `sc_maechq` | `bdicheq` | ⚠️ sí | SELECT | L296 |
| `fal_cat_estatus_cuenta` | `bdiaclaracion` | no | SELECT | L302 |
| `fal_historico_solicitud` | `bdiaclaracion` | no | INSERT | L335 |
| `fal_rango_importe_accion` | `bdiaclaracion` | no | SELECT | L441 |
| `fal_cat_accion` | `bdiaclaracion` | no | SELECT | L452 |
| `fal_aviso` | `bdiaclaracion` | no | SELECT | L468 |
| `fal_grupo_documento` | `bdiaclaracion` | no | SELECT | L475 |
| `fal_control_tramite` | `bdiaclaracion` | no | UPDATE | L513 |
| `fal_beneficiario` | `bdiaclaracion` | no | UPDATE | L520 |
| `systables` | `bdiaclaracion` | no | SELECT | L673 |
| `sc_tarjeta` | `bdicheq` | ⚠️ sí | SELECT | L683 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_fal_obtener_saldo_debito` | `bdiaclaracion` | no | L408 |
| `sp_fal_cancelacion_cuenta_debito` | `bdiaclaracion` | no | L517 |
| `bloqueo_cta` | `bdicheq` | ⚠️ sí | L551 |
| `cargo_ref` | `bdicheq` | ⚠️ sí | L710 |
| `abono_ref` | `bdicheq` | ⚠️ sí | L737 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L207 | FÓRMULA | `LET codigoRetorno       = iSqlErr;                       -- CODIGO DEFINIDO` |  |
| L210 | FÓRMULA | `LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO` |  |
| L315 | VALIDACIÓN_NULL | `IF p_cta_cliente IS NULL THEN` |  |
| L318 | VALIDACIÓN_NULL | `IF p_cta_beneficiario IS NULL THEN` |  |
| L321 | VALIDACIÓN_NULL | `IF p_usuario IS NULL THEN` |  |
| L325 | VALIDACIÓN_NULL | `IF p_idSolicitud is null OR TRIM(p_cta_cliente) = '' OR TRIM(p_cta_beneficiario) = '' OR TRIM(p_usua` |  |
| L493 | FÓRMULA | `LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO` |  |
| L537 | FÓRMULA | `LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO` |  |
| L557 | FÓRMULA | `LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO` |  |
| L583 | FÓRMULA | `LET codigoRetorno       = codret_blqcta;                       -- CODIGO DEFINIDO` |  |
| L586 | FÓRMULA | `LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO` |  |
| L621 | FÓRMULA | `LET codigoRetorno       = codret_blqcta;                       -- CODIGO DEFINIDO` |  |
| L624 | FÓRMULA | `LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO` |  |
| L756 | FÓRMULA | `LET nuevo_monto_congelado = (resultado_saldo_congelado - monto_pago_bene); -- VALIDAMOS EL NUEVO SAL` | 🔴 MONEY/aritmética financiera |
| L787 | FÓRMULA | `LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO` |  |
| L808 | FÓRMULA | `LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO` |  |
| L864 | FÓRMULA | `LET codigoRetorno       = codret_cargo_ref;                       -- CODIGO DEFINIDO` |  |
| L867 | FÓRMULA | `LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO` |  |
| L890 | VALIDACIÓN_NULL | `IF resultado_aplicado != 1 OR resultado_aplicado IS NULL THEN` |  |
| L939 | FÓRMULA | `LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO` |  |
| L984 | FÓRMULA | `LET codigoRetorno       = cod_resp_cancelacion_debito;                       -- CODIGO DEFINIDO` |  |
| L987 | FÓRMULA | `LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO` |  |
| L1026 | FÓRMULA | `LET codigoRetorno       = codret_blqcta;                       -- CODIGO DEFINIDO` |  |
| L1029 | FÓRMULA | `LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO` |  |
| L1047 | FÓRMULA | `LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO` |  |
| L1070 | FÓRMULA | `LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO` |  |
| L1085 | FÓRMULA | `LET codigoRetorno       = codret_blqcta;                       -- CODIGO DEFINIDO` |  |
| L1088 | FÓRMULA | `LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `fal` | ENTIDAD | fal — fallo/disputa (prefijo sp_fal_* — aclaraciones bancari | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `liquidacion` | ENTIDAD | liquidación | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `debito` | ENTIDAD | débito | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `?_cor` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `por` | MODIF | por (criterio) | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?ativo` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_cor`, `?ativo` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_fal_marcajesitesp`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_fal_marcajesitesp.sql` |
| **LOC (1er CREATE)** | 179 |
| **Callgraph** | ✅ fan_in=0 / fan_out=17 |
| **Deps concatenadas** | 35 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "fal — fallo/disputa y marca (especial)" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 3 llamada(s): `sp_marcajesitesp`, `sp_bloqueocuenta`, `bloqueo_cta` |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=4 · INFERIDO=0 · SINTÉTICO=1 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_fal_marcajesitesp(
  pEmpresa                     CHAR(3)
  pTipoProceso                 SMALLINT
  pNumcte                      CHAR(20)
  pUsuario                     CHAR(8)
) RETURNING CHAR(6) AS codigo_ret,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pEmpresa` | `CHAR(3)` | — | — |
| `pTipoProceso` | `SMALLINT` | — | — |
| `pNumcte` | `CHAR(20)` | — | — |
| `pUsuario` | `CHAR(8)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodret` | `CHAR(6)` | L8 |
| `cMensajeRet` | `CHAR(80)` | L9 |
| `cCodretBloqCred` | `CHAR(6)` | L11 |
| `cCodretBloqDeb` | `CHAR(6)` | L12 |
| `cMensajeRetBloqCred` | `CHAR(40)` | L13 |
| `cMensajeRetBloqDeb` | `CHAR(40)` | L14 |
| `iSql_err` | `INTEGER` | L16 |
| `resultado_numeroProducto` | `CHAR(6)` | L18 |
| `resultado_nombreProducto` | `CHAR(60)` | L19 |
| `resultado_numeroCuenta` | `CHAR(30)` | L20 |
| `resultado_numeroTarjeta` | `CHAR(30)` | L21 |
| `dFechaHoy` | `DATE` | L23 |
| `resultado_estatus_cuenta` | `CHAR(1)` | L25 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sc_maechq` | `bdicheq` | ⚠️ sí | SELECT | L104 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_marcajesitesp` | `bdisitesp` | ⚠️ sí | L61 |
| `sp_bloqueocuenta` | `bdicred` | ⚠️ sí | L72 |
| `bloqueo_cta` | `bdicheq` | ⚠️ sí | L110 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `fal` | ENTIDAD | fal — fallo/disputa (prefijo sp_fal_* — aclaraciones bancari | 🔵 CONVENCIÓN | nombre_sp |
| `marca` | ENTIDAD | marca | 🔵 CONVENCIÓN | nombre_sp |
| `?jesit` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `esp` | MODIF | especial | 🔵 CONVENCIÓN | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?jesit` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_fal_obten_datos_cliente_solicitud`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_fal_obten_datos_cliente_solicitud.sql` |
| **LOC (1er CREATE)** | 342 |
| **Callgraph** | ✅ fan_in=0 / fan_out=9 |
| **Deps concatenadas** | 13 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "obtiene fal — fallo/disputa, datos, cliente y solicitud" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `obtiene` → `SELECT` encontrado en el cuerpo · `obtiene` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=3 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=0 / 6 términos |

### Firma

```sql
CREATE PROCEDURE sp_fal_obten_datos_cliente_solicitud(
  p_sNumeroCliente             CHAR(20)
) RETURNING DATE AS fechaNacimiento, DATE AS fechaUltimoMovimiento,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_sNumeroCliente` | `CHAR(20)` | `cliente`=cliente | ✅ CÓDIGO |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `resultado_fechaNacimiento` | `DATE` | L9 |
| `resultado_fechaUltimoMovimiento` | `DATE` | L10 |
| `resultado_numeroBeneficiarios` | `INTEGER` | L11 |
| `resultado_numeroProducto` | `CHAR(6)` | L12 |
| `resultado_nombreProducto` | `CHAR(60)` | L13 |
| `resultado_numeroCuenta` | `CHAR(30)` | L14 |
| `resultado_numeroTarjeta` | `CHAR(30)` | L15 |
| `resultado_fechaUltimoMovPorCuenta` | `DATE` | L16 |
| `resultado_fechaUltimoMovPorCuentaCaptaHis` | `DATE` | L19 |
| `resultado_fechaUltimoMovPorCuentaCaptaDia` | `DATE` | L20 |
| `resultado_fechaUltimoMovPorCuentaCredHis` | `DATE` | L21 |
| `resultado_fechaUltimoMovPorCuentaCredDia` | `DATE` | L22 |
| `resultado_fechaUltimoMovCap` | `DATE` | L24 |
| `resultado_fechaUltimoMovCred` | `DATE` | L25 |
| `resultado_fechaUltimoMovAux` | `DATE` | L27 |
| `cantidadBeneCuenta` | `INTEGER` | L28 |
| `cantidadBeneSum` | `INTEGER` | L29 |
| `solicitudPky` | `INTEGER` | L30 |
| `resultado_estado` | `CHAR(50)` | L33 |
| `resultado_cod_postal` | `CHAR(10)` | L34 |
| `resultado_numero_exterior` | `CHAR(15)` | L35 |
| `resultado_calle` | `CHAR(50)` | L36 |
| `resultado_colonia` | `CHAR(50)` | L37 |
| `resultado_municipio` | `CHAR(50)` | L38 |
| `iSqlErr` | `INTEGER` | L40 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `fal_solicitud` | `bdiaclaracion` | no | SELECT | L88 |
| `fal_control_tramite` | `bdiaclaracion` | no | SELECT | L90 |
| `sc_movdia` | `bdicheq` | ⚠️ sí | SELECT | L96 |
| `sd_movdia` | `bdicred` | ⚠️ sí | SELECT | L111 |
| `sd_movhis` | `bdicred` | ⚠️ sí | SELECT | L118 |
| `sc_beneficiario` | `bdicheq` | ⚠️ sí | SELECT | L176 |
| `sv_benefic` | `bdinvers` | ⚠️ sí | SELECT | L224 |
| `si_ctepf` | `bdinteg` | ⚠️ sí | SELECT | L298 |
| `si_cliente` | `bdinteg` | ⚠️ sí | SELECT | L319 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L123 | VALIDACIÓN_NULL | `IF resultado_fechaUltimoMovPorCuentaCaptaDia < resultado_fechaUltimoMovPorCuentaCaptaHis OR resultad` |  |
| L129 | VALIDACIÓN_NULL | `IF resultado_fechaUltimoMovPorCuentaCredDia < resultado_fechaUltimoMovPorCuentaCredHis OR resultado_` |  |
| L179 | FÓRMULA | `LET cantidadBeneSum = cantidadBeneSum + cantidadBeneCuenta;*/` |  |
| L227 | FÓRMULA | `LET cantidadBeneSum = cantidadBeneSum + cantidadBeneCuenta;*/` |  |
| L236 | FÓRMULA | `LET cantidadBeneSum = cantidadBeneSum + cantidadBeneCuenta;*/` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `fal` | ENTIDAD | fal — fallo/disputa (prefijo sp_fal_* — aclaraciones bancari | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `obten` | ACCION | obtiene / recupera | 🔵 CONVENCIÓN | nombre_sp |
| `datos` | ENTIDAD | datos | 🔵 CONVENCIÓN | nombre_sp |
| `cliente` | ENTIDAD | cliente | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `solicitud` | ENTIDAD | solicitud | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |

---

## `sp_fal_obten_secuencia_folio`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_fal_obten_secuencia_folio.sql` |
| **LOC (1er CREATE)** | 32 |
| **Callgraph** | ✅ fan_in=0 / fan_out=16 |
| **Deps concatenadas** | 34 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "obtiene fal — fallo/disputa, secuencia y folio" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `obtiene` → `SELECT` encontrado en el cuerpo · `obtiene` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=5 · INFERIDO=0 · SINTÉTICO=0 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_fal_obten_secuencia_folio(
) RETURNING CHAR (4) AS secuenciaMax
```

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `secuenciaMax` | `CHAR(4)` | L5 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `systables` | `bdiaclaracion` | no | SELECT | L16 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `fal` | ENTIDAD | fal — fallo/disputa (prefijo sp_fal_* — aclaraciones bancari | 🔵 CONVENCIÓN | nombre_sp |
| `obten` | ACCION | obtiene / recupera | 🔵 CONVENCIÓN | nombre_sp |
| `secuencia` | ENTIDAD | secuencia | 🔵 CONVENCIÓN | nombre_sp |
| `folio` | ENTIDAD | folio | 🔵 CONVENCIÓN | nombre_sp |

---

## `sp_fal_obtener_beneficiario_por_cuentas`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_fal_obtener_beneficiario_por_cuentas.sql` |
| **LOC (1er CREATE)** | 120 |
| **Callgraph** | ✅ fan_in=0 / fan_out=16 |
| **Deps concatenadas** | 29 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "obtiene fal — fallo/disputa, beneficiario y cuentas" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `obtiene` → `SELECT` encontrado en el cuerpo · `obtiene` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=5 · INFERIDO=0 · SINTÉTICO=0 / 6 términos |

### Firma

```sql
CREATE PROCEDURE sp_fal_obtener_beneficiario_por_cuentas(
  p_numeroCuenta               CHAR(20)
  p_numeroCuentaBeneficiario   CHAR(20)
  p_tipoTramite                INT
) RETURNING CHAR(20)    AS numeroCliente,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_numeroCuenta` | `CHAR(20)` | — | — |
| `p_numeroCuentaBeneficiario` | `CHAR(20)` | `beneficiario`=beneficiario (receptor del pago SPEI) | ✅ CÓDIGO |
| `p_tipoTramite` | `INT` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `resultado_numeroCliente` | `CHAR(20)` | L16 |
| `resultado_numeroCuenta` | `CHAR(30)` | L17 |
| `resultado_estatus` | `CHAR(30)` | L18 |
| `resultado_motivo` | `CHAR(100)` | L19 |
| `resultado_porcentaje` | `MONEY(16)` | L20 |
| `resultado_numeroProducto` | `CHAR(6)` | L21 |
| `resultado_apellidoPat` | `CHAR(30)` | L22 |
| `resultado_apellidoMat` | `CHAR(30)` | L23 |
| `resultado_nombre1` | `CHAR(30)` | L24 |
| `resultado_nombre2` | `CHAR(30)` | L25 |
| `iSqlErr` | `INTEGER` | L26 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sc_maechq` | `bdicheq` | ⚠️ sí | SELECT | L71 |
| `si_cliente` | `bdinteg` | ⚠️ sí | SELECT | L96 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `fal` | ENTIDAD | fal — fallo/disputa (prefijo sp_fal_* — aclaraciones bancari | 🔵 CONVENCIÓN | nombre_sp |
| `obtener` | ACCION | obtiene / recupera | 🔵 CONVENCIÓN | nombre_sp |
| `beneficiario` | ENTIDAD | beneficiario (receptor del pago SPEI) | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `por` | MODIF | por (criterio) | 🔵 CONVENCIÓN | nombre_sp |
| `cuentas` | ENTIDAD | cuentas (plural) | 🔵 CONVENCIÓN | nombre_sp |

---

## `sp_fal_obtener_saldo_debito`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_fal_obtener_saldo_debito.sql` |
| **LOC (1er CREATE)** | 139 |
| **Callgraph** | ✅ fan_in=33 / fan_out=4 |
| **Deps concatenadas** | 3 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "obtiene fal — fallo/disputa, saldo y débito" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `obtiene` → `SELECT` encontrado en el cuerpo · `obtiene` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=4 · INFERIDO=0 · SINTÉTICO=0 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_fal_obtener_saldo_debito(
  p_sNumeroCuenta              CHAR(30)
  p_usuario                    CHAR(8)
) RETURNING MONEY(16)   AS montoActual
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_sNumeroCuenta` | `CHAR(30)` | — | — |
| `p_usuario` | `CHAR(8)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `resultado_montoActual` | `MONEY(16)` | L8 |
| `resultado_cuenta_pagare_cuenta` | `MONEY(16)` | L10 |
| `resultado_cuenta_inversion_cuenta` | `MONEY(16)` | L11 |
| `resultado_saldo_congelado` | `MONEY(16)` | L13 |
| `resultado_cuentas` | `MONEY(16)` | L14 |
| `resultado_montoTotal` | `MONEY(16)` | L16 |
| `codret_blqcta_eje` | `CHAR(6)` | L18 |
| `menret_blqcta_eje` | `CHAR(250)` | L19 |
| `iSqlErr` | `INTEGER` | L22 |
| `resultado_cta_deposito` | `CHAR(20)` | L23 |
| `cCodRetConsSdo` | `CHAR(5)` | L25 |
| `cMensajeRetConsSdo` | `CHAR(50)` | L26 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sc_maeinstrucc` | `bdicheq` | ⚠️ sí | SELECT | L55 |
| `sc_maechq` | `bdicheq` | ⚠️ sí | SELECT | L61 |
| `sv_maeinstrucc` | `bdinvers` | ⚠️ sí | SELECT | L76 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `bloqueo_cta` | `bdicheq` | ⚠️ sí | L97 |
| `sp_cons_sdodisp_x_tpcalculo` | `bdicheq` | ⚠️ sí | L111 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L88 | FÓRMULA | `LET resultado_cuentas = resultado_cuenta_inversion_cuenta + resultado_cuenta_pagare_cuenta;` |  |
| L114 | FÓRMULA | `LET resultado_montoTotal = resultado_cuentas - resultado_montoActual;` | 🔴 MONEY/aritmética financiera |
| L116 | FÓRMULA | `LET resultado_montoTotal = resultado_montoActual - resultado_cuentas;` | 🔴 MONEY/aritmética financiera |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `fal` | ENTIDAD | fal — fallo/disputa (prefijo sp_fal_* — aclaraciones bancari | 🔵 CONVENCIÓN | nombre_sp |
| `obtener` | ACCION | obtiene / recupera | 🔵 CONVENCIÓN | nombre_sp |
| `saldo` | ENTIDAD | saldo | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `debito` | ENTIDAD | débito | 🔵 CONVENCIÓN | nombre_sp |

---

## `sp_fal_relacion_cance_creditos_reporte`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_fal_relacion_cance_creditos_reporte.sql` |
| **LOC (1er CREATE)** | 362 |
| **Callgraph** | ✅ fan_in=0 / fan_out=16 |
| **Deps concatenadas** | 32 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "fal — fallo/disputa, créditos y reporte" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 4 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=1 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_fal_relacion_cance_creditos_reporte(
  p_estatus                    INTEGER
  p_fechaInicial               DATE
  p_fechaFinal                 DATE
) RETURNING INTEGER AS registro,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_estatus` | `INTEGER` | — | — |
| `p_fechaInicial` | `DATE` | — | — |
| `p_fechaFinal` | `DATE` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `resp_registro` | `INTEGER` | L29 |
| `resp_tipo_movimiento` | `CHAR(22)` | L30 |
| `resp_folio_csuac` | `CHAR(15)` | L31 |
| `resp_concepto` | `CHAR(35)` | L32 |
| `resp_num_cuenta_titular` | `CHAR(20)` | L33 |
| `resp_nombreCliente` | `CHAR(60)` | L34 |
| `resp_saldo` | `MONEY` | L35 |
| `resp_capital_vigente` | `MONEY` | L36 |
| `resp_capital_transitorio` | `MONEY` | L37 |
| `resp_capital_vencido` | `MONEY` | L38 |
| `resp_capital_vencido_no_exigible` | `MONEY` | L39 |
| `resp_capital_total` | `MONEY` | L40 |
| `resp_interes_vigente` | `MONEY` | L41 |
| `resp_iva_interes_vigente` | `MONEY` | L42 |
| `resp_interes_vencido` | `MONEY` | L43 |
| `resp_iva_interes_vencido` | `MONEY` | L44 |
| `resp_interes_moratorio_base` | `MONEY` | L45 |
| `resp_interes_moratorio_copete` | `MONEY` | L46 |
| `resp_iva_interes_moratorio` | `MONEY` | L47 |
| `resp_fecha_aplicacion` | `DATE` | L48 |
| `resp_fky_usuario_analista` | `INTEGER` | L49 |
| `resp_nombre` | `CHAR(60)` | L50 |
| `resp_numeroTransac` | `CHAR(10)` | L51 |
| `resp_descripcionTransac` | `CHAR(255)` | L52 |
| `iSqlErr` | `INTEGER` | L53 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `acl_usuario` | `bdiaclaracion` | no | SELECT | L139 |
| `fal_saldo_anterior` | `bdiaclaracion` | no | SELECT | L145 |
| `sd_movdia` | `bdicred` | ⚠️ sí | SELECT | L160 |
| `sd_movhis` | `bdicred` | ⚠️ sí | SELECT | L172 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L154 | FÓRMULA | `LET resp_registro = resp_registro + 1;` |  |
| L168 | VALIDACIÓN_NULL | `IF resp_numeroTransac IS NULL AND resp_descripcionTransac IS  NULL THEN` |  |
| L218 | FÓRMULA | `LET resp_registro = resp_registro + 1;` |  |
| L231 | VALIDACIÓN_NULL | `IF resp_numeroTransac IS NULL AND resp_descripcionTransac IS  NULL THEN` |  |
| L281 | FÓRMULA | `LET resp_registro = resp_registro + 1;` |  |
| L296 | VALIDACIÓN_NULL | `IF resp_numeroTransac IS NULL AND resp_descripcionTransac IS  NULL THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `fal` | ENTIDAD | fal — fallo/disputa (prefijo sp_fal_* — aclaraciones bancari | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `?_relacion_cance_` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `creditos` | ENTIDAD | créditos (plural) | 🔵 CONVENCIÓN | nombre_sp |
| `reporte` | ENTIDAD | reporte | 🔵 CONVENCIÓN | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_relacion_cance_` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_fal_rep_baja_clientes_fallecidos`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_fal_rep_baja_clientes_fallecidos.sql` |
| **LOC (1er CREATE)** | 128 |
| **Callgraph** | ✅ fan_in=0 / fan_out=16 |
| **Deps concatenadas** | 31 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "reporte fal — fallo/disputa, clientes, identificador y OS — Originación de Solicitudes (de baja)" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 2 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=5 · INFERIDO=1 · SINTÉTICO=1 / 9 términos |

### Firma

```sql
CREATE PROCEDURE sp_fal_rep_baja_clientes_fallecidos(
  fechaIni                     DATE
  fechaFin                     DATE
) RETURNING INTEGER AS registro,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `fechaIni` | `DATE` | — | — |
| `fechaFin` | `DATE` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `resultado_registro` | `INTEGER` | L14 |
| `resultado_folio_csuac` | `CHAR (11)` | L15 |
| `resultado_num_cliente` | `CHAR (9)` | L16 |
| `resultado_nombre1` | `CHAR (30)` | L17 |
| `resultado_nombre2` | `CHAR (30)` | L18 |
| `resultado_apellido_pat` | `CHAR (30)` | L19 |
| `resultado_apellido_mat` | `CHAR (30)` | L20 |
| `resultado_fecha_cierre` | `DATE` | L21 |
| `error` | `INTEGER` | L22 |
| `iSqlErr` | `INTEGER` | L23 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `fal_solicitud` | `bdiaclaracion` | no | SELECT | L61 |
| `fal_control_tramite` | `bdiaclaracion` | no | SELECT | L91 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L65 | FÓRMULA | `LET resultado_registro = resultado_registro + 1;` |  |
| L79 | FÓRMULA | `LET resultado_registro = resultado_registro + 1;` |  |
| L94 | FÓRMULA | `LET resultado_registro = resultado_registro + 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `fal` | ENTIDAD | fal — fallo/disputa (prefijo sp_fal_* — aclaraciones bancari | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `rep` | ACCION | reporte | 🔵 CONVENCIÓN | nombre_sp |
| `baja` | MODIF | de baja | 🔵 CONVENCIÓN | nombre_sp |
| `clientes` | ENTIDAD | clientes (plural) | 🔵 CONVENCIÓN | nombre_sp |
| `fal` | ENTIDAD | fal — fallo/disputa (prefijo sp_fal_* — aclaraciones bancari | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `?lec` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `id` | ENTIDAD | identificador (de) | 🔵 CONVENCIÓN | nombre_sp |
| `os` | ENTIDAD | OS — Originación de Solicitudes / subsistema de ofertas (sp_ | 🟡 INFERIDO | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?lec` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_fal_rep_pagare_vencimiento`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_fal_rep_pagare_vencimiento.sql` |
| **LOC (1er CREATE)** | 344 |
| **Callgraph** | ✅ fan_in=0 / fan_out=16 |
| **Deps concatenadas** | 33 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "reporte fal — fallo/disputa, pagaré y vencimiento" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 4 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=4 · INFERIDO=0 · SINTÉTICO=0 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_fal_rep_pagare_vencimiento(
  p_estatus                    INTEGER
  fechaIni                     DATE
  fechaFin                     DATE
) RETURNING CHAR(11) AS folioCsuac,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_estatus` | `INTEGER` | — | — |
| `fechaIni` | `DATE` | — | — |
| `fechaFin` | `DATE` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `resultado_folioCsuac` | `CHAR (11)` | L19 |
| `resultado_montoReclamado` | `MONEY` | L20 |
| `resultado_usuarioAsignado` | `CHAR(120)` | L21 |
| `resultado_evento` | `CHAR (30)` | L22 |
| `resultado_numCuenta` | `CHAR (20)` | L23 |
| `resultado_estatusCorp` | `CHAR (30)` | L24 |
| `resultado_estatusSucu` | `CHAR (30)` | L25 |
| `resultado_estatusGene` | `CHAR (30)` | L26 |
| `resultado_respuestaArea` | `CHAR (50)` | L27 |
| `resultado_respuestaPredictamen` | `CHAR (20)` | L28 |
| `resultado_respuestanumCliente` | `CHAR (9)` | L29 |
| `resultado_fechaVencimiento` | `DATE` | L30 |
| `enAreaExterna` | `CHAR (1)` | L31 |
| `pkySolicitud` | `INTEGER` | L32 |
| `pkyControlTramite` | `INTEGER` | L33 |
| `countAreaExterna` | `INTEGER` | L34 |
| `countCorrectos` | `INTEGER` | L35 |
| `existePredictamen` | `INTEGER` | L36 |
| `iSqlErr` | `INTEGER` | L37 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `acl_usuario` | `bdiaclaracion` | no | SELECT | L83 |
| `fal_solicitud` | `bdiaclaracion` | no | SELECT | L87 |
| `fal_control_tramite` | `bdiaclaracion` | no | SELECT | L99 |
| `fal_solicitud_area_externa` | `bdiaclaracion` | no | SELECT | L121 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `fal` | ENTIDAD | fal — fallo/disputa (prefijo sp_fal_* — aclaraciones bancari | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `rep` | ACCION | reporte | 🔵 CONVENCIÓN | nombre_sp |
| `pagare` | ENTIDAD | pagaré | 🔵 CONVENCIÓN | nombre_sp |
| `vencimiento` | ENTIDAD | vencimiento | 🔵 CONVENCIÓN | nombre_sp |

---

## `sp_fal_saldos_deb_cre_cliente`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_fal_saldos_deb_cre_cliente.sql` |
| **LOC (1er CREATE)** | 199 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 7 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "fal — fallo/disputa, saldos, crédito y cliente (débito)" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 4 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=3 · INFERIDO=1 · SINTÉTICO=0 / 6 términos |

### Firma

```sql
CREATE PROCEDURE sp_fal_saldos_deb_cre_cliente(
  p_sNumeroCliente             CHAR(9)
) RETURNING CHAR(20) AS sumaSaldoCredito, CHAR(20) AS sumaSaldoDebito
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_sNumeroCliente` | `CHAR(9)` | `cliente`=cliente | 🔵 CONVENCIÓN |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `saldoCredito` | `MONEY(18,2)` | L6 |
| `saldoDebito` | `MONEY(18,2)` | L7 |
| `sumSaldoCredito` | `MONEY(18,2)` | L8 |
| `sumSaldoDebito` | `MONEY(18,2)` | L9 |
| `sumSaldoCreditoChar` | `CHAR(20)` | L10 |
| `sumSaldoDebitoChar` | `CHAR(20)` | L11 |
| `resultado_numeroProducto` | `CHAR(6)` | L14 |
| `resultado_nombreProducto` | `CHAR(60)` | L15 |
| `resultado_numeroCuenta` | `CHAR(30)` | L16 |
| `resultado_numeroTarjeta` | `CHAR(30)` | L17 |
| `iSqlErr` | `INTEGER` | L19 |
| `resultado_codigo_retorno` | `CHAR(10)` | L22 |
| `resultado_mensaje_retorno` | `CHAR(10)` | L23 |
| `resultado_numero_credito` | `CHAR(10)` | L24 |
| `resultado_codigo_tipcred` | `CHAR(10)` | L25 |
| `resultado_fecha_origen` | `CHAR(10)` | L26 |
| `resultado_fecha_prox_pago` | `CHAR(10)` | L27 |
| `resultado_pago_minimo` | `CHAR(10)` | L28 |
| `resultado_fecha_ult_pago` | `CHAR(10)` | L29 |
| `resultado_plazo` | `CHAR(10)` | L30 |
| `resultado_pagos_realizados` | `CHAR(10)` | L31 |
| `resultado_linea_otorgada` | `CHAR(10)` | L32 |
| `resultado_tasa_interes` | `CHAR(10)` | L33 |
| `resultado_tasa_moratorios` | `CHAR(10)` | L34 |
| `resultado_monto_sbc` | `CHAR(10)` | L35 |
| *…34 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `fal_control_tramite` | `bdiaclaracion` | no | SELECT | L105 |
| `fal_saldo_anterior` | `bdiaclaracion` | no | SELECT | L113 |
| `sc_maechq` | `bdicheq` | ⚠️ sí | SELECT | L163 |
| `sv_maeinv` | `bdinvers` | ⚠️ sí | SELECT | L171 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L119 | VALIDACIÓN_NULL | `IF resultado_sdo_act_total_cap IS NULL THEN` |  |
| L144 | FÓRMULA | `LET sumSaldoCredito = sumSaldoCredito + resultado_sdo_act_total_cap;` |  |
| L159 | VALIDACIÓN_NULL | `IF saldoDebito IS NULL THEN` |  |
| L165 | FÓRMULA | `LET sumSaldoDebito = sumSaldoDebito + saldoDebito;` |  |
| L174 | FÓRMULA | `LET sumSaldoDebito = sumSaldoDebito + saldoDebito;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `fal` | ENTIDAD | fal — fallo/disputa (prefijo sp_fal_* — aclaraciones bancari | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `saldos` | ENTIDAD | saldos | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `deb` | MODIF | débito | 🔵 CONVENCIÓN | nombre_sp |
| `cre` | ENTIDAD | crédito | 🟡 INFERIDO | nombre_sp |
| `cliente` | ENTIDAD | cliente | 🔵 CONVENCIÓN | nombre_sp |

---

## `sp_fal_valida_cierre_folio`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_fal_valida_cierre_folio.sql` |
| **LOC (1er CREATE)** | 99 |
| **Callgraph** | ✅ fan_in=0 / fan_out=15 |
| **Deps concatenadas** | 27 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "valida fal — fallo/disputa y folio" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `valida` → `IF` encontrado en el cuerpo · `valida` → `RETURN` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=3 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=0 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_fal_valida_cierre_folio(
  p_idSolicitud                INTEGER
) RETURNING CHAR(6) as codigoRetorno,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_idSolicitud` | `INTEGER` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `resultado_cod_ret` | `CHAR(6)` | L6 |
| `resultado_msg_ret` | `CHAR(250)` | L7 |
| `resultado_conteo_total` | `INTEGER` | L8 |
| `resultado_conteo_exitoso` | `INTEGER` | L9 |
| `resultado_conteo_credito` | `INTEGER` | L10 |
| `pEmpresa` | `CHAR(3)` | L11 |
| `pTipoProceso` | `SMALLINT` | L12 |
| `resultado_num_cliente` | `CHAR(9)` | L13 |
| `resultado_num_empleado` | `CHAR(9)` | L14 |
| `cCodret` | `CHAR(6)` | L16 |
| `cMensajeRet` | `CHAR(80)` | L17 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `fal_control_tramite` | `bdiaclaracion` | no | SELECT | L38 |
| `fal_solicitud` | `bdiaclaracion` | no | SELECT | L51 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `fal` | ENTIDAD | fal — fallo/disputa (prefijo sp_fal_* — aclaraciones bancari | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `valida` | ACCION | valida | 🔵 CONVENCIÓN | nombre_sp |
| `cierre` | ACCION | cierre | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `folio` | ENTIDAD | folio | ✅ CÓDIGO | nombre_sp, texto_cuerpo |

---

## `sp_fal_vencimiento_pagare`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_fal_vencimiento_pagare.sql` |
| **LOC (1er CREATE)** | 156 |
| **Callgraph** | ✅ fan_in=0 / fan_out=9 |
| **Deps concatenadas** | 25 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "fal — fallo/disputa, vencimiento y pagaré" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 1 llamada(s): `sp_fal_liquidacion_asignar_analista` |
| **Evidencia vocab** | CÓDIGO=3 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=0 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_fal_vencimiento_pagare(
  p_tipo_tramite               INTEGER
) RETURNING CHAR(6) as codigoRetorno,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_tipo_tramite` | `INTEGER` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `codigoRetorno` | `CHAR(6)` | L6 |
| `mensajeRetorno` | `CHAR(100)` | L7 |
| `resultado_pky_control_tramite` | `INTEGER` | L9 |
| `resultado_fecha_vencimiento_pagare` | `DATE` | L10 |
| `resultado_cuenta_pagare` | `CHAR(20)` | L11 |
| `resultado_aplicado` | `CHAR(1)` | L12 |
| `resultado_inst_evento` | `CHAR(2)` | L13 |
| `resultado_conteo_proceso` | `INTEGER` | L14 |
| `resultado_conteo` | `INTEGER` | L15 |
| `resultado_fky_solicitud` | `INTEGER` | L16 |
| `resultado_numero_cliente` | `CHAR(9)` | L17 |
| `resultado_foliocsuac` | `CHAR(12)` | L18 |
| `resultado_fky_usuario_analista` | `INTEGER` | L19 |
| `resultado_num_sucursal` | `CHAR(10)` | L20 |
| `resultado_secuencia` | `SMALLINT` | L21 |
| `resultado_montoActualVencimiento` | `MONEY(16)` | L22 |
| `resultado_num_cta_beneficiario` | `CHAR(20)` | L23 |
| `resultado_nombreBeneficiario` | `CHAR(100)` | L24 |
| `resultado_representante_legal` | `INTEGER` | L25 |
| `resultado_num_empleado` | `CHAR(9)` | L26 |
| `resultado_cta_cheques` | `CHAR(20)` | L27 |
| `resultado_cargos_mes` | `MONEY(16)` | L28 |
| `tipoAccion` | `CHAR(1)` | L31 |
| `cuentaBeneficiario` | `CHAR(20)` | L32 |
| `cuentaClienteFallecido` | `CHAR(20)` | L33 |
| *…5 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `fal_control_tramite` | `bdiaclaracion` | no | SELECT | L57 |
| `sv_maeinstrucc` | `bdinvers` | ⚠️ sí | SELECT | L67 |
| `sc_movinver` | `bdicheq` | ⚠️ sí | SELECT | L73 |
| `fal_solicitud` | `bdiaclaracion` | no | SELECT | L86 |
| `fal_beneficiario` | `bdiaclaracion` | no | SELECT | L91 |
| `sv_maeinv` | `bdinvers` | ⚠️ sí | SELECT | L98 |
| `sc_maechq` | `bdicheq` | ⚠️ sí | SELECT | L106 |
| `fal_control_tramite` | `bdiaclaracion` | no | UPDATE | L114 |
| `fal_saldo_anterior` | `bdiaclaracion` | no | UPDATE | L126 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_fal_liquidacion_asignar_analista` | `bdiaclaracion` | no | L130 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L109 | FÓRMULA | `LET resultado_montoActualVencimiento = resultado_montoActualVencimiento - resultado_cargos_mes;` | 🔴 MONEY/aritmética financiera |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `fal` | ENTIDAD | fal — fallo/disputa (prefijo sp_fal_* — aclaraciones bancari | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `vencimiento` | ENTIDAD | vencimiento | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `pagare` | ENTIDAD | pagaré | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |

---

## `sp_gerente_promotor_suc`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_gerente_promotor_suc.sql` |
| **LOC (1er CREATE)** | 25 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "motor de decisión (sucursal)" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 1 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=2 · INFERIDO=1 · SINTÉTICO=1 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_gerente_promotor_suc(
  p_Sucursal                   CHAR(4)
  p_Perfil                     integer
) RETURNING CHAR(15) AS ejecutivo
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_Sucursal` | `CHAR(4)` | `suc`=sucursal | 🟡 INFERIDO |
| `p_Perfil` | `integer` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `resultado_ejecutivo` | `CHAR(15)` | L4 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_ejecut` | `bdinteg` | ⚠️ sí | SELECT | L11 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `?_gerente_pro` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `motor` | ENTIDAD | motor de decisión | 🔵 CONVENCIÓN | nombre_sp |
| `suc` | MODIF | sucursal | 🟡 INFERIDO | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_gerente_pro` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_ins_recuperacion_saldos`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_ins_recuperacion_saldos.sql` |
| **LOC (1er CREATE)** | 195 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "insertar saldos" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `inserta` → `INSERT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=1 · INFERIDO=1 · SINTÉTICO=0 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_ins_recuperacion_saldos(
  e_fky_aclaracion             INTEGER
  e_folio_csuac                VARCHAR(11)
  e_total_abono                MONEY
  e_abono_recuperado           MONEY
  e_abono_afectado             MONEY
  e_total_comision             MONEY
  e_comision_recuperada        MONEY
  e_comision_afectada          MONEY
  e_total_iva                  MONEY
  e_iva_recuperada             MONEY
  e_iva_afectada               MONEY
  e_interes_recuperado         MONEY
  e_interes_afectado           MONEY
  e_fc_recuperacion            DATETIME YEAR to FRACTION(5)
  e_fi_recuperacion            DATETIME YEAR to FRACTION(5)
  e_fa_recuperacion            DATETIME YEAR to FRACTION(5)
  e_fin_recuperacion           DATETIME YEAR to FRACTION(5)
  e_abono_irrecuperable        SMALLINT
  e_cron_activo                SMALLINT
  e_exito_ca                   SMALLINT
  e_exito_cc                   SMALLINT
  e_exito_ci                   SMALLINT
  e_exito_cin                  SMALLINT
  e_rec_trans                  INTEGER
) RETURNING CHAR(3) as s_CodRet, CHAR(30) as s_Mensaje
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `e_fky_aclaracion` | `INTEGER` | — | — |
| `e_folio_csuac` | `VARCHAR(11)` | — | — |
| `e_total_abono` | `MONEY` | — | — |
| `e_abono_recuperado` | `MONEY` | — | — |
| `e_abono_afectado` | `MONEY` | — | — |
| `e_total_comision` | `MONEY` | — | — |
| `e_comision_recuperada` | `MONEY` | — | — |
| `e_comision_afectada` | `MONEY` | — | — |
| `e_total_iva` | `MONEY` | — | — |
| `e_iva_recuperada` | `MONEY` | — | — |
| `e_iva_afectada` | `MONEY` | — | — |
| `e_interes_recuperado` | `MONEY` | — | — |
| `e_interes_afectado` | `MONEY` | — | — |
| `e_fc_recuperacion` | `DATETIME YEAR to FRACTION(5)` | `recuperacion`=recuperación (cobranza) | ✅ CÓDIGO |
| `e_fi_recuperacion` | `DATETIME YEAR to FRACTION(5)` | `recuperacion`=recuperación (cobranza) | ✅ CÓDIGO |
| `e_fa_recuperacion` | `DATETIME YEAR to FRACTION(5)` | `recuperacion`=recuperación (cobranza) | ✅ CÓDIGO |
| `e_fin_recuperacion` | `DATETIME YEAR to FRACTION(5)` | `recuperacion`=recuperación (cobranza) | ✅ CÓDIGO |
| `e_abono_irrecuperable` | `SMALLINT` | — | — |
| `e_cron_activo` | `SMALLINT` | — | — |
| `e_exito_ca` | `SMALLINT` | — | — |
| `e_exito_cc` | `SMALLINT` | — | — |
| `e_exito_ci` | `SMALLINT` | — | — |
| `e_exito_cin` | `SMALLINT` | — | — |
| `e_rec_trans` | `INTEGER` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `s_CodRet` | `CHAR(3)` | L37 |
| `s_Mensaje` | `CHAR(30)` | L38 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `acl_aclaracion` | `bdiaclaracion` | no | UPDATE | L148 |
| `acl_recuperacion_saldos` | `bdiaclaracion` | no | INSERT | L151 |
| `acl_movimiento` | `bdiaclaracion` | no | UPDATE | L186 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L50 | VALIDACIÓN_NULL | `IF e_fky_aclaracion IS NULL OR e_fky_aclaracion = '' OR e_fky_aclaracion == 0 THEN` |  |
| L56 | VALIDACIÓN_NULL | `IF e_folio_csuac IS NULL OR e_folio_csuac = '' OR e_folio_csuac == 0 THEN` |  |
| L62 | VALIDACIÓN_NULL | `IF e_total_abono IS NULL THEN` |  |
| L68 | VALIDACIÓN_NULL | `IF e_abono_recuperado IS NULL THEN` |  |
| L74 | VALIDACIÓN_NULL | `IF e_total_comision IS NULL THEN` |  |
| L80 | VALIDACIÓN_NULL | `IF e_comision_recuperada IS NULL THEN` |  |
| L86 | VALIDACIÓN_NULL | `IF e_total_iva IS NULL THEN` |  |
| L92 | VALIDACIÓN_NULL | `IF e_iva_recuperada IS NULL THEN` |  |
| L98 | VALIDACIÓN_NULL | `IF e_cron_activo IS NULL THEN` |  |
| L104 | VALIDACIÓN_NULL | `IF e_abono_irrecuperable IS NULL THEN` |  |
| L110 | VALIDACIÓN_NULL | `IF e_exito_ca IS NULL THEN` |  |
| L116 | VALIDACIÓN_NULL | `IF e_exito_cc IS NULL THEN` |  |
| L122 | VALIDACIÓN_NULL | `IF e_exito_ci IS NULL THEN` |  |
| L128 | VALIDACIÓN_NULL | `IF e_rec_trans IS NULL OR e_rec_trans = 0 THEN` |  |
| L134 | VALIDACIÓN_NULL | `IF e_total_interes IS NULL THEN` |  |
| L139 | VALIDACIÓN_NULL | `IF e_interes_recuperado IS NULL THEN` |  |
| L147 | FÓRMULA | `LET e_total_iva = e_total_comision * 0.16;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `ins` | ACCION | insertar | 🟡 INFERIDO | nombre_sp |
| `recuperacion` | ACCION | recuperación (cobranza) | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `saldos` | ENTIDAD | saldos | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |

---

## `sp_inserta_comentario`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_inserta_comentario.sql` |
| **LOC (1er CREATE)** | 127 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 2 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "inserta Comisión bancaria — cobro de comisión sobre cuenta y Tarjeta" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `inserta` → `INSERT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=3 · INFERIDO=1 · SINTÉTICO=2 / 6 términos |

### Firma

```sql
CREATE PROCEDURE sp_inserta_comentario(
  pFolio_csuac                 CHAR(16)
  pComentario                  LVARCHAR
  pNumEmpleado                 CHAR(8)
) RETURNING CoRet CHAR(5), Resultado VARCHAR(250)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pFolio_csuac` | `CHAR(16)` | — | — |
| `pComentario` | `LVARCHAR` | `com`=Comisión bancaria — cobro de comisión sobre cuenta (bdicheq:sp_cobra_com, sp_com_manejo_cta_cobro_*; también en OXXO) · `tar`=Tarjeta (abreviación — bdicheq/bdicred: cons_cta_o_tar, mover_his_tar, obtener_cta_con_num_tar) | 🟡 INFERIDO / 🔵 CONVENCIÓN |
| `pNumEmpleado` | `CHAR(8)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(6)` | L4 |
| `sql_err` | `INTEGER` | L5 |
| `isam_err` | `INTEGER` | L6 |
| `CMensaje` | `CHAR(80)` | L7 |
| `vFolioCsuac` | `CHAR(11)` | L9 |
| `vResultado` | `CHAR(50)` | L10 |
| `vFechaActual` | `DATETIME YEAR to FRACTION(5)` | L11 |
| `vFechaDictamen` | `DATETIME YEAR to FRACTION(5)` | L12 |
| `wBegin` | `CHAR(1)` | L14 |
| `vIDAclaracion` | `INTEGER` | L16 |
| `vEstatusAclInicial` | `INTEGER` | L17 |
| `vEstatusCorpInicial` | `INTEGER` | L18 |
| `vEstatusAnaInicial` | `INTEGER` | L19 |
| `vFechaCapturaAcl` | `DATE` | L20 |
| `vAreaAcl` | `INTEGER` | L21 |
| `vIDUsusario` | `INTEGER` | L23 |
| `vAccionAbono` | `INTEGER` | L25 |
| `vAbonoTemporal` | `INTEGER` | L26 |
| `vIndicadorAfectacion` | `INTEGER` | L27 |
| `vAccionComentario` | `INTEGER` | L28 |
| `v_comentario` | `LVARCHAR` | L29 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `systables` | `bdiaclaracion` | no | SELECT | L68 |
| `acl_resolucion` | `bdiaclaracion` | no | SELECT | L80 |
| `acl_usuario` | `bdiaclaracion` | no | SELECT | L85 |
| `acl_aclaracion` | `bdiaclaracion` | no | SELECT | L96 |
| `acl_entrada_bitacora` | `bdiaclaracion` | no | INSERT | L100 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L39 | CÓDIGO_RETORNO | `LET cCodRet				= '00000';` |  |
| L49 | VALIDACIÓN_NULL | `IF vResultado IS NULL THEN` |  |
| L52 | FÓRMULA | `LET vResultado = TRIM(vResultado) \|\| '-' \|\| 'Proceso Fallido';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `inserta` | ACCION | inserta / registra | 🔵 CONVENCIÓN | nombre_sp |
| `com` | ENTIDAD | Comisión bancaria — cobro de comisión sobre cuenta (bdicheq: | 🔵 CONVENCIÓN | nombre_sp |
| `?en` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `tar` | ENTIDAD | Tarjeta (abreviación — bdicheq/bdicred: cons_cta_o_tar, move | 🟡 INFERIDO | nombre_sp |
| `?io` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?en`, `?io` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_inserta_movimiento`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_inserta_movimiento.sql` |
| **LOC (1er CREATE)** | 97 |
| **Callgraph** | ✅ fan_in=0 / fan_out=6 |
| **Deps concatenadas** | 4 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "inserta movimiento" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `inserta` → `INSERT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=0 / 3 términos |

### Firma

```sql
CREATE PROCEDURE sp_inserta_movimiento(
  pFechaHora                   CHAR(30)
  pMonto                       MONEY
  pFolioSuc                    CHAR(30)
  pReferencia23                CHAR(23)
  pProducto                    INTEGER
  pTipoEvento                  INTEGER
  pAclaracion                  INTEGER
  pMovimientoPadre             INTEGER
  pNumSucursal                 CHAR(10)
  pReferenciaComercio          CHAR(40)
  pFechaConsumo                CHAR(30)
  pMontoProcedente             MONEY
  pFolioCSUAC                  CHAR(10)
  pReversado                   SMALLINT
  pCalculado                   SMALLINT
  pMontoDuplicado              SMALLINT
  pTipoMovimiento              INTEGER
  pReferencia                  VARCHAR(30)
) RETURNING CHAR(3)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pFechaHora` | `CHAR(30)` | — | — |
| `pMonto` | `MONEY` | — | — |
| `pFolioSuc` | `CHAR(30)` | — | — |
| `pReferencia23` | `CHAR(23)` | — | — |
| `pProducto` | `INTEGER` | — | — |
| `pTipoEvento` | `INTEGER` | — | — |
| `pAclaracion` | `INTEGER` | — | — |
| `pMovimientoPadre` | `INTEGER` | `movimiento`=movimiento | ✅ CÓDIGO |
| `pNumSucursal` | `CHAR(10)` | — | — |
| `pReferenciaComercio` | `CHAR(40)` | — | — |
| `pFechaConsumo` | `CHAR(30)` | — | — |
| `pMontoProcedente` | `MONEY` | — | — |
| `pFolioCSUAC` | `CHAR(10)` | — | — |
| `pReversado` | `SMALLINT` | — | — |
| `pCalculado` | `SMALLINT` | — | — |
| `pMontoDuplicado` | `SMALLINT` | — | — |
| `pTipoMovimiento` | `INTEGER` | `movimiento`=movimiento | ✅ CÓDIGO |
| `pReferencia` | `VARCHAR(30)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(3)` | L23 |
| `CSecuencia` | `INTEGER` | L24 |
| `vFechaHora` | `DATETIME YEAR to FRACTION(5)` | L25 |
| `vFechaConsumo` | `DATETIME YEAR to FRACTION(5)` | L26 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `acl_movimiento` | `bdiaclaracion` | no | INSERT | L79 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L43 | VALIDACIÓN_NULL | `IF pFechaHora = '' OR pFechaHora IS  NULL THEN` |  |
| L46 | VALIDACIÓN_NULL | `IF pFechaConsumo = '' OR pFechaConsumo IS  NULL THEN` |  |
| L49 | VALIDACIÓN_NULL | `IF pFolioSuc = '' OR pFolioSuc IS  NULL THEN` |  |
| L52 | VALIDACIÓN_NULL | `IF pReferencia23 = '' OR pReferencia23 IS  NULL THEN` |  |
| L55 | VALIDACIÓN_NULL | `IF pNumSucursal = '' OR pNumSucursal IS  NULL THEN` |  |
| L58 | VALIDACIÓN_NULL | `IF pReferenciaComercio = '' OR pReferenciaComercio IS  NULL THEN` |  |
| L61 | VALIDACIÓN_NULL | `IF pFolioCSUAC = '' OR pFolioCSUAC IS  NULL THEN` |  |
| L64 | VALIDACIÓN_NULL | `IF pReferencia = '' OR pReferencia IS  NULL THEN` |  |
| L69 | FÓRMULA | `LET vFechaHora =(TO_DATE(pFechaHora,'%d/%m/%Y %H:%M:%S')) ;` |  |
| L71 | FÓRMULA | `LET vFechaHora =(TO_DATE(pFechaHora,'%d/%m/%Y')) ;` |  |
| L75 | FÓRMULA | `LET vFechaConsumo = (TO_DATE(pFechaConsumo,'%d/%m/%Y %H:%M:%S'));` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `inserta` | ACCION | inserta / registra | 🔵 CONVENCIÓN | nombre_sp |
| `movimiento` | ENTIDAD | movimiento | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |

---

## `sp_inserta_tipo_movimiento`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_inserta_tipo_movimiento.sql` |
| **LOC (1er CREATE)** | 35 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "inserta movimiento (tipo de)" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `inserta` → `INSERT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=0 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_inserta_tipo_movimiento(
  pTransaccionNoProcede        CHAR(4)
  pIdOrigenEvento              INTEGER
  pIdTransaccion               INTEGER
  pIdTipoProducto              INTEGER
  pDescripcion                 CHAR(255)
) RETURNING CHAR (4) AS respuestaEjecucion
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pTransaccionNoProcede` | `CHAR(4)` | — | — |
| `pIdOrigenEvento` | `INTEGER` | — | — |
| `pIdTransaccion` | `INTEGER` | — | — |
| `pIdTipoProducto` | `INTEGER` | `tipo`=tipo de | ✅ CÓDIGO |
| `pDescripcion` | `CHAR(255)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `respuestaEjecucion` | `CHAR(4)` | L5 |
| `secuenciaMax` | `INTEGER` | L6 |
| `iSqlErr` | `INTEGER` | L7 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `acl_tipo_movimiento` | `bdiaclaracion` | no | SELECT | L27 |
| `acl_tipo_movimiento` | `bdiaclaracion` | no | INSERT | L29 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `inserta` | ACCION | inserta / registra | 🔵 CONVENCIÓN | nombre_sp |
| `tipo` | MODIF | tipo de | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `movimiento` | ENTIDAD | movimiento | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |

---

## `sp_integracion_cta`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_integracion_cta.sql` |
| **LOC (1er CREATE)** | 125 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 2 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "interés y cuenta" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 2 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=2 · INFERIDO=1 · SINTÉTICO=1 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_integracion_cta(
  p_FechaInicial               DATE
  p_FechaFinal                 DATE
) RETURNING CHAR(11) AS r_folio, money(16,2) AS r_monto, CHAR(20) AS r_cuenta, CHAR(16) AS r_tarjeta, CHAR(3) AS r_tipo_evento, CHAR(1) AS r_procede, CHAR(50) AS r_sel_transaccion, DATE AS r_fecha_abon, money(16,2) AS r_monto_abon, DATE AS r_fecha_carg, money(16,2) AS r_monto_carg, money(16,2) AS r_comision, CHAR(30) AS r_concepto
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_FechaInicial` | `DATE` | — | — |
| `p_FechaFinal` | `DATE` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `res_folio` | `CHAR(11)` | L5 |
| `res_monto` | `money(16,2)` | L6 |
| `res_cuenta` | `CHAR(20)` | L7 |
| `res_tarjeta` | `CHAR(16)` | L8 |
| `res_tipo_evento` | `CHAR(3)` | L9 |
| `res_procede` | `CHAR (1)` | L10 |
| `res_sel_transa` | `CHAR(50)` | L11 |
| `res_fech_abon` | `DATE` | L12 |
| `res_monto_abon` | `money(16,2)` | L13 |
| `res_fecha_cargo` | `DATE` | L14 |
| `res_monto_cargo` | `money(16,2)` | L15 |
| `res_comision` | `money(16,2)` | L16 |
| `res_concepto` | `CHAR(30)` | L17 |
| `iSqlErr` | `INTEGER` | L18 |
| `tipo_producto` | `CHAR(2)` | L19 |
| `p_calculado` | `CHAR(1)` | L20 |
| `p_estatus` | `CHAR(1)` | L21 |
| `p_dictamen` | `DATE` | L22 |
| `p_cargo` | `CHAR(1)` | L23 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `acl_aclaracion` | `bdiaclaracion` | no | SELECT | L72 |
| `acl_movimiento` | `bdiaclaracion` | no | SELECT | L106 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `int` | ENTIDAD | interés | 🟡 INFERIDO | nombre_sp |
| `?egracion_` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `cta` | ENTIDAD | cuenta | 🔵 CONVENCIÓN | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?egracion_` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_integracion_cuenta`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_integracion_cuenta.sql` |
| **LOC (1er CREATE)** | 173 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 1 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "interés y cuenta" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 5 tabla(s) con operaciones: SELECT, INSERT |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=1 · INFERIDO=1 · SINTÉTICO=1 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_integracion_cuenta(
  p_FechaInicial               DATE
  p_FechaFinal                 DATE
) RETURNING CHAR (5)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_FechaInicial` | `DATE` | — | — |
| `p_FechaFinal` | `DATE` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `res_folio` | `CHAR(11)` | L5 |
| `res_monto` | `money(16,2)` | L6 |
| `res_cuenta` | `CHAR(20)` | L7 |
| `res_tarjeta` | `CHAR(16)` | L8 |
| `res_tipo_evento` | `CHAR(3)` | L9 |
| `res_procede` | `CHAR (1)` | L10 |
| `res_sel_transa` | `CHAR(50)` | L11 |
| `res_fech_abon` | `DATE` | L12 |
| `res_monto_abon` | `money(16,2)` | L13 |
| `res_fecha_cargo` | `DATE` | L14 |
| `res_monto_cargo` | `money(16,2)` | L15 |
| `res_comision` | `money(16,2)` | L16 |
| `res_concepto` | `CHAR(30)` | L17 |
| `iSqlErr` | `INTEGER` | L18 |
| `tipo_producto` | `CHAR(2)` | L19 |
| `p_calculado` | `CHAR(1)` | L20 |
| `p_estatus` | `CHAR(1)` | L21 |
| `p_dictamen` | `DATE` | L22 |
| `p_cargo` | `CHAR(1)` | L23 |
| `vcodret` | `char(5)` | L24 |
| `vsqlerr` | `integer` | L25 |
| `vsql` | `char(3000)` | L26 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `systables` | `bdiaclaracion` | no | SELECT | L50 |
| `acl_aclaracion` | `bdiaclaracion` | no | SELECT | L91 |
| `acl_movimiento` | `bdiaclaracion` | no | SELECT | L125 |
| `acl_integracion_cta` | `bdiaclaracion` | no | INSERT | L129 |
| `acl_integracion_cta` | `bdiaclaracion` | no | SELECT | L138 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L135 | FÓRMULA | `let vsql = ' echo "Folio_CSUAC\|Importe_Reclamado\|Numero_De_Cuenta\|Tarjeta\|Tipo_Evento\|Procede\|` | 🔴 MONEY/aritmética financiera |
| L138 | FÓRMULA | `let vsql=  'echo "UNLOAD TO /resplogifx/repaclaraciones/acl_integracion_cta.unl  select folio, monto` | 🔴 MONEY/aritmética financiera |
| L141 | FÓRMULA | `let vsql= 'dbaccess bdiaclaracion  /resplogifx/repaclaraciones/acl_integracion_cta.sql';` |  |
| L144 | FÓRMULA | `let vsql ='rm  /resplogifx/repaclaraciones/acl_integracion_cta.sql';` |  |
| L147 | FÓRMULA | `let vsql = "sed 's/\|$//g' /resplogifx/repaclaraciones/acl_integracion_cta.unl >>/resplogifx/repacla` |  |
| L149 | FÓRMULA | `let vsql ='rm  /resplogifx/repaclaraciones/acl_integracion_cta.unl';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `int` | ENTIDAD | interés | 🟡 INFERIDO | nombre_sp |
| `?egracion_` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `cuenta` | ENTIDAD | cuenta | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?egracion_` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_intento_solicitud_aclaracion`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_intento_solicitud_aclaracion.sql` |
| **LOC (1er CREATE)** | 63 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 3 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "interés, solicitud y aclaración bancaria — proceso de disputa o reclamación del cliente" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 3 tabla(s) con operaciones: SELECT, INSERT |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=1 · INFERIDO=1 · SINTÉTICO=1 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_intento_solicitud_aclaracion(
  opcion                       INTEGER
  pNumero_cliente              CHAR(10)
  pFecha_registro              DATE
) RETURNING CHAR(5) AS codret,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `opcion` | `INTEGER` | — | — |
| `pNumero_cliente` | `CHAR(10)` | — | — |
| `pFecha_registro` | `DATE` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(5)` | L6 |
| `iSqlErr` | `INTEGER` | L7 |
| `cCodRetSp` | `CHAR(5)` | L8 |
| `iCodRetSp` | `INTEGER` | L9 |
| `iIntentos` | `INTEGER` | L10 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `acl_intento_solicitud` | `bdiaclaracion` | no | SELECT | L36 |
| `acl_intento_solicitud` | `bdiaclaracion` | no | INSERT | L41 |
| `acl_aclaracion` | `bdiaclaracion` | no | SELECT | L47 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L12 | CÓDIGO_RETORNO | `LET cCodRet = '00000';` |  |
| L29 | CÓDIGO_RETORNO | `LET cCodRet = '00003';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `int` | ENTIDAD | interés | 🟡 INFERIDO | nombre_sp |
| `?ento_` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `solicitud` | ENTIDAD | solicitud | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `aclaracion` | ENTIDAD | aclaración bancaria — proceso de disputa o reclamación del c | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?ento_` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_monitor_alerta_aclaraciones`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_monitor_alerta_aclaraciones.sql` |
| **LOC (1er CREATE)** | 165 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "monitor, alerta y aclaraciones" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 1 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=0 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_monitor_alerta_aclaraciones(
) RETURNING CHAR(5) AS codret, CHAR(100) AS descrip
```

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `v_cod_ret` | `CHAR(5)` | L6 |
| `iSqlErr` | `INTEGER` | L7 |
| `iSamErr` | `INTEGER` | L8 |
| `cMensaje` | `CHAR(100)` | L10 |
| `cRutaArch` | `CHAR(25)` | L11 |
| `vsSQL` | `CHAR(1600)` | L12 |
| `vsSQL1` | `CHAR(500)` | L13 |
| `vsSQL2` | `CHAR(500)` | L14 |
| `vsSQL3` | `CHAR(500)` | L15 |
| `vsArchTemp` | `CHAR(50)` | L16 |
| `nContador` | `INTEGER` | L17 |
| `vFechaAclaracion` | `CHAR(10)` | L18 |
| `cHora` | `CHAR(8)` | L20 |
| `cFechaArchivoOUT` | `CHAR(29)` | L21 |
| `iPaso` | `SMALLINT` | L22 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `acl_movimiento` | `bdiaclaracion` | no | SELECT | L69 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L26 | FÓRMULA | `LET vFechaAclaracion    = LPAD(DAY(CURRENT::DATE),2,'0')\|\|'/'\|\|LPAD(MONTH(CURRENT::DATE),2,'0')\` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `monitor` | ENTIDAD | monitor | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `alerta` | ENTIDAD | alerta | 🔵 CONVENCIÓN | nombre_sp |
| `aclaraciones` | ENTIDAD | aclaraciones (proceso de disputas/reclamaciones de cliente) | ✅ CÓDIGO | nombre_sp, texto_cuerpo |

---

## `sp_mueve_aclaraciones_historico`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_mueve_aclaraciones_historico.sql` |
| **LOC (1er CREATE)** | 862 |
| **Callgraph** | ✅ fan_in=0 / fan_out=2 |
| **Deps concatenadas** | 2 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "mueve aclaraciones (histórico)" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 51 tabla(s) con operaciones: SELECT, DELETE, UPDATE, INSERT |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=1 · INFERIDO=1 · SINTÉTICO=0 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_mueve_aclaraciones_historico(
) RETURNING CHAR(5)
```

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `scod_ret` | `CHAR(5)` | L8 |
| `vsqlerr` | `INTEGER` | L9 |
| `v_pky_aclaracion` | `CHAR(20)` | L10 |
| `icontador` | `INTEGER` | L11 |
| `v_folio_csuac` | `VARCHAR(11)` | L12 |
| `v_sol_eglobal` | `INTEGER` | L13 |
| `v_res_eglobal` | `INTEGER` | L14 |
| `v_fecha_limit` | `DATE` | L15 |
| `vsql` | `char(3000)` | L16 |
| `cCadena` | `CHAR(1000)` | L17 |
| `respuesta_repetida_e_global` | `INTEGER` | L18 |
| `solicitud_faltante_e_global` | `INTEGER` | L19 |
| `cRuta` | `CHAR(100)` | L20 |
| `horaActual` | `datetime year to fraction` | L21 |
| `horafinal` | `datetime year to fraction` | L22 |
| `v_pky_movimiento` | `CHAR(20)` | L23 |
| `v_pky_movimiento2` | `CHAR(20)` | L24 |
| `v_pky_bitacora` | `CHAR(20)` | L25 |
| `v_resul_mov` | `INTEGER` | L26 |
| `v_temp_aclara` | `INTEGER` | L27 |
| `v_temp_solic` | `INTEGER` | L28 |
| `v_temp_respues` | `INTEGER` | L29 |
| `v_temp_bitacora` | `INTEGER` | L30 |
| `v_temp_mov` | `INTEGER` | L31 |
| `c_pky_bitacora` | `INTEGER` | L32 |
| *…2 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `systables` | `bdiaclaracion` | no | SELECT | L71 |
| `statistics` | `bdiaclaracion` | no | UPDATE | L131 |
| `si_fechas` | `bdinteg` | ⚠️ sí | SELECT | L171 |
| `temp_aclara` | `bdiaclaracion` | no | INSERT | L175 |
| `acl_aclaracion` | `bdiaclaracion` | no | SELECT | L177 |
| `temp_solic` | `bdiaclaracion` | no | INSERT | L179 |
| `acl_movimiento` | `bdiaclaracion` | no | SELECT | L181 |
| `temp_aclara` | `bdiaclaracion` | no | SELECT | L182 |
| `temp_respues` | `bdiaclaracion` | no | INSERT | L184 |
| `acl_solicitud_e_global` | `bdiaclaracion` | no | SELECT | L186 |
| `temp_solic` | `bdiaclaracion` | no | SELECT | L187 |
| `acl_aclaracion_his` | `bdiaclaracion` | no | INSERT | L232 |
| `acl_entrada_bitacora` | `bdiaclaracion` | no | SELECT | L256 |
| `acl_entrada_bitacora_his` | `bdiaclaracion` | no | INSERT | L265 |
| `acl_documento_his` | `bdiaclaracion` | no | INSERT | L293 |
| `acl_documento` | `bdiaclaracion` | no | SELECT | L294 |
| `acl_recuperacion_saldos` | `bdiaclaracion` | no | SELECT | L304 |
| `acl_recuperacion_saldos_his` | `bdiaclaracion` | no | INSERT | L313 |
| `acl_respuesta_e_global` | `bdiaclaracion` | no | SELECT | L336 |
| `acl_respuesta_e_global_his` | `bdiaclaracion` | no | INSERT | L345 |
| `acl_solicitud_e_global_his` | `bdiaclaracion` | no | INSERT | L378 |
| `acl_movimiento_his` | `bdiaclaracion` | no | INSERT | L409 |
| `acl_control_aclaracion_tel` | `bdiaclaracion` | no | SELECT | L495 |
| `acl_control_aclaracion_tel_his` | `bdiaclaracion` | no | INSERT | L503 |
| `acl_bitacora_control_cancelacion_cuenta` | `bdiaclaracion` | no | SELECT | L526 |
| `acl_bitacora_control_cancelacion_cuenta_his` | `bdiaclaracion` | no | INSERT | L534 |
| `acl_regulatorio27` | `bdiaclaracion` | no | SELECT | L557 |
| `acl_regulatorio27_his` | `bdiaclaracion` | no | INSERT | L565 |
| `acl_sistema_bitacora` | `bdiaclaracion` | no | SELECT | L588 |
| `acl_sistema_bitacora_his` | `bdiaclaracion` | no | INSERT | L596 |
| `acl_aclaracion_estatus_proceso_analisis` | `bdiaclaracion` | no | SELECT | L619 |
| `acl_aclaracion_estatus_proceso_analisis_his` | `bdiaclaracion` | no | INSERT | L628 |
| `temp_bitacora` | `bdiaclaracion` | no | INSERT | L658 |
| `acl_movimiento_his` | `bdiaclaracion` | no | SELECT | L676 |
| `temp_mov` | `bdiaclaracion` | no | INSERT | L678 |
| `acl_entrada_bitacora` | `bdiaclaracion` | no | DELETE | L753 |
| `acl_documento` | `bdiaclaracion` | no | DELETE | L755 |
| `acl_recuperacion_saldos` | `bdiaclaracion` | no | DELETE | L757 |
| `acl_control_aclaracion_tel` | `bdiaclaracion` | no | DELETE | L760 |
| `acl_regulatorio27` | `bdiaclaracion` | no | DELETE | L762 |
| `acl_bitacora_control_cancelacion_cuenta` | `bdiaclaracion` | no | DELETE | L764 |
| `acl_aclaracion_estatus_proceso_analisis` | `bdiaclaracion` | no | DELETE | L766 |
| `temp_mov` | `bdiaclaracion` | no | SELECT | L774 |
| `acl_movimiento` | `bdiaclaracion` | no | UPDATE | L779 |
| `acl_movimiento` | `bdiaclaracion` | no | DELETE | L792 |
| `acl_solicitud_e_global` | `bdiaclaracion` | no | DELETE | L804 |
| `temp_respues` | `bdiaclaracion` | no | SELECT | L811 |
| `acl_respuesta_e_global` | `bdiaclaracion` | no | DELETE | L814 |
| `acl_aclaracion` | `bdiaclaracion` | no | DELETE | L825 |
| `temp_bitacora` | `bdiaclaracion` | no | SELECT | L832 |
| `acl_sistema_bitacora` | `bdiaclaracion` | no | DELETE | L835 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L222 | FÓRMULA | `let vsql=  'echo "UNLOAD to /RESPALDOSNEW/aclaraciones/acl_aclaracion_his.unl '\|\|` |  |
| L225 | FÓRMULA | `let vsql= 'dbaccess bdiaclaracion /RESPALDOSNEW/aclaraciones/acl_aclaracion_his.sql';` |  |
| L244 | FÓRMULA | `let vsql ='rm  /RESPALDOSNEW/aclaraciones/acl_aclaracion_his.unl';` |  |
| L246 | FÓRMULA | `let vsql ='rm  /RESPALDOSNEW/aclaraciones/acl_aclaracion_his.sql';` |  |
| L248 | FÓRMULA | `let vsql ='rm  /RESPALDOSNEW/aclaraciones/aclaracion.sql';` |  |
| L255 | FÓRMULA | `let vsql=  'echo "UNLOAD to /RESPALDOSNEW/aclaraciones/acl_entrada_bitacora_his.unl '\|\|` |  |
| L258 | FÓRMULA | `let vsql= 'dbaccess bdiaclaracion /RESPALDOSNEW/aclaraciones/acl_entrada_bitacora_his.sql';` |  |
| L277 | FÓRMULA | `let vsql ='rm  /RESPALDOSNEW/aclaraciones/acl_entrada_bitacora_his.unl';` |  |
| L279 | FÓRMULA | `let vsql ='rm  /RESPALDOSNEW/aclaraciones/acl_entrada_bitacora_his.sql';` |  |
| L281 | FÓRMULA | `let vsql ='rm  /RESPALDOSNEW/aclaraciones/bitacora.sql';` |  |
| L303 | FÓRMULA | `let vsql=  'echo "UNLOAD to /RESPALDOSNEW/aclaraciones/acl_recuperacion_saldos_his.unl '\|\|` |  |
| L306 | FÓRMULA | `let vsql= 'dbaccess bdiaclaracion /RESPALDOSNEW/aclaraciones/acl_recuperacion_saldos_his.sql';` |  |
| L325 | FÓRMULA | `let vsql ='rm  /RESPALDOSNEW/aclaraciones/acl_recuperacion_saldos_his.unl';` |  |
| L327 | FÓRMULA | `let vsql ='rm  /RESPALDOSNEW/aclaraciones/acl_recuperacion_saldos_his.sql';` |  |
| L329 | FÓRMULA | `let vsql ='rm  /RESPALDOSNEW/aclaraciones/recuperacion.sql';` |  |
| L335 | FÓRMULA | `let vsql=  'echo "UNLOAD to /RESPALDOSNEW/aclaraciones/acl_respuesta_e_global_his.unl '\|\|` |  |
| L338 | FÓRMULA | `let vsql= 'dbaccess bdiaclaracion /RESPALDOSNEW/aclaraciones/acl_respuesta_e_global_his.sql';` |  |
| L357 | FÓRMULA | `let vsql ='rm  /RESPALDOSNEW/aclaraciones/acl_respuesta_e_global_his.unl';` |  |
| L359 | FÓRMULA | `let vsql ='rm  /RESPALDOSNEW/aclaraciones/acl_respuesta_e_global_his.sql';` |  |
| L361 | FÓRMULA | `let vsql ='rm  /RESPALDOSNEW/aclaraciones/respuesta.sql';` |  |
| L367 | FÓRMULA | `let vsql=  'echo "UNLOAD to /RESPALDOSNEW/aclaraciones/acl_solicitud_e_global_his.unl '\|\|` |  |
| L370 | FÓRMULA | `let vsql= 'dbaccess bdiaclaracion /RESPALDOSNEW/aclaraciones/acl_solicitud_e_global_his.sql';` |  |
| L390 | FÓRMULA | `let vsql ='rm  /RESPALDOSNEW/aclaraciones/acl_solicitud_e_global_his.unl';` |  |
| L392 | FÓRMULA | `let vsql ='rm  /RESPALDOSNEW/aclaraciones/acl_solicitud_e_global_his.sql';` |  |
| L394 | FÓRMULA | `let vsql ='rm  /RESPALDOSNEW/aclaraciones/solicitud.sql';` |  |
| L400 | FÓRMULA | `let vsql=  'echo "UNLOAD to /RESPALDOSNEW/aclaraciones/acl_movimiento_his.unl '\|\|` |  |
| L403 | FÓRMULA | `let vsql= 'dbaccess bdiaclaracion /RESPALDOSNEW/aclaraciones/acl_movimiento_his.sql';` |  |
| L421 | FÓRMULA | `let vsql ='rm  /RESPALDOSNEW/aclaraciones/acl_movimiento_his.unl';` |  |
| L423 | FÓRMULA | `let vsql ='rm  /RESPALDOSNEW/aclaraciones/acl_movimiento_his.sql';` |  |
| L425 | FÓRMULA | `let vsql ='rm  /RESPALDOSNEW/aclaraciones/movimiento.sql';` |  |
| | *…40 más…* | | |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `mueve` | ACCION | mueve / traslada (verbo complemento de mover) | 🟡 INFERIDO | nombre_sp |
| `aclaraciones` | ENTIDAD | aclaraciones (proceso de disputas/reclamaciones de cliente) | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `historico` | MODIF | histórico | ✅ CÓDIGO | nombre_sp, texto_cuerpo |

---

## `sp_mueve_aclaraciones_historico_pendiente`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_mueve_aclaraciones_historico_pendiente.sql` |
| **LOC (1er CREATE)** | 191 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "mueve aclaraciones (histórico)" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 33 tabla(s) con operaciones: SELECT, DELETE, INSERT, UPDATE |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=1 · INFERIDO=1 · SINTÉTICO=1 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_mueve_aclaraciones_historico_pendiente(
) RETURNING CHAR(5)
```

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `scod_ret` | `CHAR(5)` | L8 |
| `vsqlerr` | `INTEGER` | L9 |
| `v_pky_aclaracion` | `CHAR(20)` | L10 |
| `icontador` | `INTEGER` | L11 |
| `v_folio_csuac` | `VARCHAR(11)` | L12 |
| `v_sol_eglobal` | `INTEGER` | L13 |
| `v_res_eglobal` | `INTEGER` | L14 |
| `v_fecha_limit` | `DATE` | L15 |
| `vsql` | `char(3000)` | L16 |
| `cCadena` | `CHAR(1000)` | L17 |
| `respuesta_repetida_e_global` | `INTEGER` | L18 |
| `solicitud_faltante_e_global` | `INTEGER` | L19 |
| `cRuta` | `CHAR(100)` | L20 |
| `horaActual` | `datetime year to fraction` | L21 |
| `horafinal` | `datetime year to fraction` | L22 |
| `v_pky_movimiento` | `CHAR(20)` | L23 |
| `v_pky_movimiento2` | `CHAR(20)` | L24 |
| `v_pky_bitacora` | `CHAR(20)` | L25 |
| `v_resul_mov` | `INTEGER` | L26 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `systables` | `bdiaclaracion` | no | SELECT | L35 |
| `temp_bitacora` | `bdiaclaracion` | no | INSERT | L74 |
| `acl_sistema_bitacora_his` | `bdiaclaracion` | no | SELECT | L75 |
| `temp_mov` | `bdiaclaracion` | no | INSERT | L77 |
| `acl_movimiento_his` | `bdiaclaracion` | no | SELECT | L79 |
| `temp_aclara` | `bdiaclaracion` | no | SELECT | L79 |
| `si_fechas` | `bdinteg` | ⚠️ sí | SELECT | L88 |
| `acl_documento_his` | `bdiaclaracion` | no | INSERT | L96 |
| `acl_documento` | `bdiaclaracion` | no | SELECT | L97 |
| `acl_entrada_bitacora` | `bdiaclaracion` | no | SELECT | L108 |
| `acl_entrada_bitacora` | `bdiaclaracion` | no | DELETE | L108 |
| `acl_documento` | `bdiaclaracion` | no | DELETE | L110 |
| `acl_recuperacion_saldos` | `bdiaclaracion` | no | SELECT | L112 |
| `acl_recuperacion_saldos` | `bdiaclaracion` | no | DELETE | L112 |
| `acl_control_aclaracion_tel` | `bdiaclaracion` | no | SELECT | L115 |
| `acl_control_aclaracion_tel` | `bdiaclaracion` | no | DELETE | L115 |
| `acl_regulatorio27` | `bdiaclaracion` | no | SELECT | L117 |
| `acl_regulatorio27` | `bdiaclaracion` | no | DELETE | L117 |
| `temp_mov` | `bdiaclaracion` | no | SELECT | L125 |
| `acl_movimiento` | `bdiaclaracion` | no | UPDATE | L129 |
| `acl_movimiento` | `bdiaclaracion` | no | SELECT | L142 |
| `acl_movimiento` | `bdiaclaracion` | no | DELETE | L142 |
| `temp_solic` | `bdiaclaracion` | no | SELECT | L151 |
| `acl_solicitud_e_global` | `bdiaclaracion` | no | SELECT | L154 |
| `acl_solicitud_e_global` | `bdiaclaracion` | no | DELETE | L154 |
| `temp_respues` | `bdiaclaracion` | no | SELECT | L161 |
| `acl_respuesta_e_global` | `bdiaclaracion` | no | SELECT | L164 |
| `acl_respuesta_e_global` | `bdiaclaracion` | no | DELETE | L164 |
| `acl_aclaracion` | `bdiaclaracion` | no | SELECT | L175 |
| `acl_aclaracion` | `bdiaclaracion` | no | DELETE | L175 |
| `temp_bitacora` | `bdiaclaracion` | no | SELECT | L182 |
| `acl_sistema_bitacora` | `bdiaclaracion` | no | SELECT | L185 |
| `acl_sistema_bitacora` | `bdiaclaracion` | no | DELETE | L185 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `mueve` | ACCION | mueve / traslada (verbo complemento de mover) | 🟡 INFERIDO | nombre_sp |
| `aclaraciones` | ENTIDAD | aclaraciones (proceso de disputas/reclamaciones de cliente) | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `historico` | MODIF | histórico | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?_pendiente` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_pendiente` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_numaclaracion`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_numaclaracion.sql` |
| **LOC (1er CREATE)** | 57 |
| **Callgraph** | ✅ fan_in=0 / fan_out=6 |
| **Deps concatenadas** | 6 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "número y aclaración bancaria — proceso de disputa o reclamación del cliente" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 1 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=0 / 3 términos |

### Firma

```sql
CREATE PROCEDURE sp_numaclaracion(
  pUsuario                     CHAR(50)
) RETURNING CHAR(5) AS codret,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pUsuario` | `CHAR(50)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(5)` | L7 |
| `iSqlErr` | `INTEGER` | L8 |
| `cEmpresa` | `CHAR(3)` | L9 |
| `iNumAclaracion` | `INTEGER` | L10 |
| `dPrimerFecha` | `DATE` | L11 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `acl_aclaracion` | `bdiaclaracion` | no | SELECT | L37 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L13 | CÓDIGO_RETORNO | `LET cCodRet = '00000';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `num` | ENTIDAD | número (de) | 🔵 CONVENCIÓN | nombre_sp |
| `aclaracion` | ENTIDAD | aclaración bancaria — proceso de disputa o reclamación del c | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |

---

## `sp_obten_cat_tipo_flujo`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_obten_cat_tipo_flujo.sql` |
| **LOC (1er CREATE)** | 41 |
| **Callgraph** | ✅ fan_in=0 / fan_out=5 |
| **Deps concatenadas** | 23 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "obtiene catálogo (tipo de)" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `obtiene` → `SELECT` encontrado en el cuerpo · `obtiene` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=1 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_obten_cat_tipo_flujo(
) RETURNING INTEGER 			as id_tipo_flujo,
```

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `id_tipo_flujo` | `INTEGER` | L7 |
| `tipo_flujo` | `CHAR(100)` | L8 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `acl_tipo_flujo` | `bdiaclaracion` | no | SELECT | L21 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `obten` | ACCION | obtiene / recupera | 🔵 CONVENCIÓN | nombre_sp |
| `cat` | ENTIDAD | catálogo | 🔵 CONVENCIÓN | nombre_sp |
| `tipo` | MODIF | tipo de | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `?_flujo` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_flujo` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_obten_datos_adicionales_movimiento`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_obten_datos_adicionales_movimiento.sql` |
| **LOC (1er CREATE)** | 86 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 14 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "obtiene datos, [polisemia] Dictamen y movimiento" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `obtiene` → `SELECT` encontrado en el cuerpo · `obtiene` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=4 · INFERIDO=0 · SINTÉTICO=2 / 7 términos |

### Firma

```sql
CREATE PROCEDURE sp_obten_datos_adicionales_movimiento(
  p_folio_suc                  CHAR(30)
  p_num_tarjeta                CHAR(16)
  p_origen_evento              INTEGER
) RETURNING CHAR(5)   AS cod_ret, CHAR(19) AS id_comer
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_folio_suc` | `CHAR(30)` | — | — |
| `p_num_tarjeta` | `CHAR(16)` | — | — |
| `p_origen_evento` | `INTEGER` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `sql_err` | `INTEGER` | L4 |
| `isam_err` | `INTEGER` | L5 |
| `v_cod_ret` | `CHAR(5)` | L6 |
| `v_nombre_origen` | `CHAR(50)` | L8 |
| `v_id_comer` | `CHAR(19)` | L9 |
| `v_existe_movimiento` | `SMALLINT` | L11 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `acl_origen_evento` | `bdiaclaracion` | no | SELECT | L42 |
| `movimiento` | `intercard` | ⚠️ sí | SELECT | L53 |
| `movimientohistorico` | `intercard` | ⚠️ sí | SELECT | L60 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L57 | VALIDACIÓN_NULL | `IF (v_existe_movimiento IS NULL) THEN` |  |
| L66 | VALIDACIÓN_NULL | `IF ((v_existe_movimiento IS NULL) OR (v_id_comer IS NULL) OR (v_id_comer = '')) THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `obten` | ACCION | obtiene / recupera | 🔵 CONVENCIÓN | nombre_sp |
| `datos` | ENTIDAD | datos | 🔵 CONVENCIÓN | nombre_sp |
| `?_a` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `dic` | ENTIDAD | [polisemia] Dictamen (bdicnweb:sp_dic_* — decisión creditici | 🔵 CONVENCIÓN | nombre_sp |
| `?ionales_` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `movimiento` | ENTIDAD | movimiento | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_a`, `?ionales_` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_obten_datos_analisis`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_obten_datos_analisis.sql` |
| **LOC (1er CREATE)** | 267 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 6 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "obtiene datos" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `obtiene` → `SELECT` encontrado en el cuerpo · `obtiene` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=1 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_obten_datos_analisis(
  p_FolioCsuac                 CHAR(20)
) RETURNING DATE AS fechaTransac,  CHAR(5) AS estatus, CHAR(5) AS flujo, CHAR(5) AS abono, DATE AS fechaAbono, CHAR(5) AS solicitud, DATE AS fechaDoc, CHAR(35) AS respuesta_e_global, CHAR(3) AS resultado_origen
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_FolioCsuac` | `CHAR(20)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `resultado_fechaTransac` | `DATE` | L7 |
| `resultado_estatus` | `CHAR(5)` | L8 |
| `resultado_flujo` | `CHAR(5)` | L9 |
| `resultado_abono` | `CHAR(5)` | L10 |
| `resultado_fechaAbono` | `DATE` | L11 |
| `resultado_solicitud` | `CHAR(5)` | L12 |
| `resultado_fechaDoc` | `DATE` | L13 |
| `resultado_respuesta_e_global` | `CHAR(35)` | L14 |
| `resultado_origen_evento` | `CHAR(3)` | L15 |
| `resultado_origen` | `CHAR(3)` | L16 |
| `resultado_folio_suc` | `CHAR(20)` | L17 |
| `resultado_numtarjeta` | `CHAR(20)` | L18 |
| `nombre_origen` | `CHAR(50)` | L19 |
| `iSqlErr` | `INTEGER` | L20 |
| `abono_inmediato` | `CHAR(2)` | L22 |
| `dfa` | `CHAR(1)` | L23 |
| `devolucion` | `CHAR(1)` | L24 |
| `procedente` | `CHAR(1)` | L25 |
| `vcargo` | `CHAR(1)` | L26 |
| `vexitoso` | `CHAR(1)` | L27 |
| `vfecha_afectacion` | `DATE` | L28 |
| `escargo_inmediato` | `CHAR(1)` | L29 |
| `esabono_inmediato` | `CHAR(1)` | L30 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `acl_aclaracion` | `bdiaclaracion` | no | SELECT | L90 |
| `acl_movimiento` | `bdiaclaracion` | no | SELECT | L119 |
| `acl_entrada_bitacora` | `bdiaclaracion` | no | SELECT | L145 |
| `acl_tipo_respuesta_e_global` | `bdiaclaracion` | no | SELECT | L185 |
| `acl_origen_evento` | `bdiaclaracion` | no | SELECT | L225 |
| `movimiento` | `intercard` | ⚠️ sí | SELECT | L231 |
| `movimientohistorico` | `intercard` | ⚠️ sí | SELECT | L238 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L124 | VALIDACIÓN_NULL | `IF (vcargo IS NULL ) OR (vcargo = '0') OR (vcargo = '') THEN` |  |
| L153 | VALIDACIÓN_NULL | `IF (resultado_abono IS NULL) OR (resultado_abono = '') THEN` |  |
| L178 | VALIDACIÓN_NULL | `IF ( resultado_solicitud IS NULL ) THEN` |  |
| L191 | VALIDACIÓN_NULL | `IF ( resultado_respuesta_e_global IS NULL ) THEN` |  |
| L222 | VALIDACIÓN_NULL | `IF (resultado_origen IS NULL OR resultado_origen = '') THEN` |  |
| L235 | VALIDACIÓN_NULL | `IF ( resultado_origen IS NULL ) THEN` |  |
| L243 | VALIDACIÓN_NULL | `IF ( resultado_origen IS NULL ) THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `obten` | ACCION | obtiene / recupera | 🔵 CONVENCIÓN | nombre_sp |
| `datos` | ENTIDAD | datos | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?_analisis` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_analisis` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_obten_dias_permitidos`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_obten_dias_permitidos.sql` |
| **LOC (1er CREATE)** | 68 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 2 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "obtiene identificador y OS — Originación de Solicitudes (del día)" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `obtiene` → `SELECT` encontrado en el cuerpo · `obtiene` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=4 · INFERIDO=1 · SINTÉTICO=1 / 6 términos |

### Firma

```sql
CREATE PROCEDURE sp_obten_dias_permitidos(
  pIdAclaracion                INTEGER
) RETURNING CHAR(6) AS cod_ret, INTEGER AS dias_permitidos, INTEGER AS regla_negocio
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pIdAclaracion` | `INTEGER` | `id`=identificador (de) | 🔵 CONVENCIÓN |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(6)` | L5 |
| `sql_err` | `INTEGER` | L6 |
| `isam_err` | `INTEGER` | L7 |
| `cMensaje` | `CHAR(80)` | L8 |
| `vDiasPermitidos` | `INTEGER` | L10 |
| `vReglaNegocio` | `INTEGER` | L11 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `acl_aclaracion` | `bdiaclaracion` | no | SELECT | L38 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L46 | VALIDACIÓN_NULL | `IF (vDiasPermitidos IS NULL) THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `obten` | ACCION | obtiene / recupera | 🔵 CONVENCIÓN | nombre_sp |
| `dia` | MODIF | del día | 🔵 CONVENCIÓN | nombre_sp |
| `?s_permit` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `id` | ENTIDAD | identificador (de) | 🔵 CONVENCIÓN | nombre_sp |
| `os` | ENTIDAD | OS — Originación de Solicitudes / subsistema de ofertas (sp_ | 🟡 INFERIDO | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?s_permit` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_obten_estatus_canales`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_obten_estatus_canales.sql` |
| **LOC (1er CREATE)** | 156 |
| **Callgraph** | ✅ fan_in=8 / fan_out=5 |
| **Deps concatenadas** | 17 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "obtiene estatus y canales" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `obtiene` → `SELECT` encontrado en el cuerpo · `obtiene` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=0 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_obten_estatus_canales(
  pEstatusAcl                  INTEGER
  pEstatusCorpGral             INTEGER
  pEstatusCorpAnalisis         INTEGER
) RETURNING CHAR(5)							AS cod_ret,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pEstatusAcl` | `INTEGER` | `estatus`=estatus | ✅ CÓDIGO |
| `pEstatusCorpGral` | `INTEGER` | `estatus`=estatus | ✅ CÓDIGO |
| `pEstatusCorpAnalisis` | `INTEGER` | `estatus`=estatus | ✅ CÓDIGO |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `sql_err` | `INTEGER` | L14 |
| `v_cod_ret` | `CHAR(5)` | L15 |
| `v_id_estatus_aclaracion` | `INTEGER` | L17 |
| `v_id_estatus_corp_analisis` | `INTEGER` | L18 |
| `v_id_estatus_corp_general` | `INTEGER` | L19 |
| `v_concatena_dictamen` | `SMALLINT` | L20 |
| `v_estatus_canales` | `CHAR(50)` | L21 |
| `v_id_etapa_canales` | `INTEGER` | L22 |
| `v_desc_etapa_canales` | `CHAR(20)` | L23 |
| `contador` | `INTEGER` | L26 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `acl_estatus_canales` | `bdiaclaracion` | no | SELECT | L65 |
| `acl_estatus_aclaracion` | `bdiaclaracion` | no | SELECT | L118 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L56 | VALIDACIÓN_NULL | `IF (pEstatusAcl IS NULL) THEN` |  |
| L74 | VALIDACIÓN_NULL | `IF v_estatus_canales IS NULL THEN` |  |
| L89 | VALIDACIÓN_NULL | `IF v_estatus_canales IS NULL THEN` |  |
| L104 | VALIDACIÓN_NULL | `IF v_estatus_canales IS NULL THEN` |  |
| L115 | VALIDACIÓN_NULL | `IF v_estatus_canales IS NULL THEN` |  |
| L137 | VALIDACIÓN_NULL | `IF v_estatus_canales IS NULL THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `obten` | ACCION | obtiene / recupera | 🔵 CONVENCIÓN | nombre_sp |
| `estatus` | ENTIDAD | estatus | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `canales` | ENTIDAD | canales (de distribución) | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |

---

## `sp_obten_estatus_canales_sms`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_obten_estatus_canales_sms.sql` |
| **LOC (1er CREATE)** | 159 |
| **Callgraph** | ✅ fan_in=21 / fan_out=2 |
| **Deps concatenadas** | 1 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "obtiene estatus, canales y SMS" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `obtiene` → `SELECT` encontrado en el cuerpo · `obtiene` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=3 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=0 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_obten_estatus_canales_sms(
  pEstatusAcl                  INTEGER
  pEstatusCorpGral             INTEGER
  pEstatusCorpAnalisis         INTEGER
) RETURNING CHAR(5)							AS cod_ret,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pEstatusAcl` | `INTEGER` | `estatus`=estatus | ✅ CÓDIGO |
| `pEstatusCorpGral` | `INTEGER` | `estatus`=estatus | ✅ CÓDIGO |
| `pEstatusCorpAnalisis` | `INTEGER` | `estatus`=estatus | ✅ CÓDIGO |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `sql_err` | `INTEGER` | L15 |
| `v_cod_ret` | `CHAR(5)` | L16 |
| `v_id_estatus_aclaracion` | `INTEGER` | L18 |
| `v_id_estatus_corp_analisis` | `INTEGER` | L19 |
| `v_id_estatus_corp_general` | `INTEGER` | L20 |
| `v_concatena_dictamen` | `SMALLINT` | L21 |
| `v_estatus_canales` | `CHAR(50)` | L22 |
| `v_estatus_sms` | `CHAR(50)` | L23 |
| `v_id_etapa_canales` | `INTEGER` | L24 |
| `v_desc_etapa_canales` | `CHAR(20)` | L25 |
| `contador` | `INTEGER` | L28 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `acl_estatus_canales` | `bdiaclaracion` | no | SELECT | L68 |
| `acl_estatus_aclaracion` | `bdiaclaracion` | no | SELECT | L121 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L59 | VALIDACIÓN_NULL | `IF (pEstatusAcl IS NULL) THEN` |  |
| L77 | VALIDACIÓN_NULL | `IF v_estatus_canales IS NULL THEN` |  |
| L92 | VALIDACIÓN_NULL | `IF v_estatus_canales IS NULL THEN` |  |
| L107 | VALIDACIÓN_NULL | `IF v_estatus_canales IS NULL THEN` |  |
| L118 | VALIDACIÓN_NULL | `IF v_estatus_canales IS NULL THEN` |  |
| L140 | VALIDACIÓN_NULL | `IF v_estatus_canales IS NULL THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `obten` | ACCION | obtiene / recupera | 🔵 CONVENCIÓN | nombre_sp |
| `estatus` | ENTIDAD | estatus | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `canales` | ENTIDAD | canales (de distribución) | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `sms` | ENTIDAD | SMS | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |

---

## `sp_obten_origen_automatico`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_obten_origen_automatico.sql` |
| **LOC (1er CREATE)** | 335 |
| **Callgraph** | ✅ fan_in=16 / fan_out=5 |
| **Deps concatenadas** | 15 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "obtiene origen (automático)" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `obtiene` → `SELECT` encontrado en el cuerpo · `obtiene` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=1 · INFERIDO=1 · SINTÉTICO=1 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_obten_origen_automatico(
  pNumeroCuenta                CHAR(30)
  pNumTarjeta                  CHAR(16)
  pSecuenciaMovimiento         INTEGER
  pFoliosuc                    CHAR(30)
  pTransaccion                 CHAR(5)
  pfechaMovimiento             DATE
  pTipoProducto                CHAR(1)
) RETURNING CHAR(5)				AS cod_ret_origen,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pNumeroCuenta` | `CHAR(30)` | — | — |
| `pNumTarjeta` | `CHAR(16)` | — | — |
| `pSecuenciaMovimiento` | `INTEGER` | — | — |
| `pFoliosuc` | `CHAR(30)` | — | — |
| `pTransaccion` | `CHAR(5)` | — | — |
| `pfechaMovimiento` | `DATE` | — | — |
| `pTipoProducto` | `CHAR(1)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `sql_err` | `INTEGER` | L23 |
| `v_cod_ret` | `CHAR(5)` | L24 |
| `v_cod_ret_sp_cr` | `CHAR(4)` | L25 |
| `v_secuenciaextendida` | `CHAR(16)` | L27 |
| `v_foliosuc1` | `CHAR(30)` | L28 |
| `v_valor_secuencia_folio` | `CHAR(1)` | L29 |
| `v_valida_movimiento` | `SMALLINT` | L30 |
| `v_es_nacional` | `CHAR(1)` | L31 |
| `v_codgironeg` | `CHAR(4)` | L32 |
| `v_modo_entrada` | `CHAR(2)` | L33 |
| `v_es_movimiento_forzado` | `SMALLINT` | L34 |
| `v_cant_origenes_asociados` | `INTEGER` | L35 |
| `v_modo_entrada_asociado` | `CHAR(2)` | L36 |
| `v_origen_evento` | `INTEGER` | L37 |
| `v_desc_origen_evento` | `CHAR(50)` | L38 |
| `v_es_transaccion_hijo` | `SMALLINT` | L39 |
| `v_origen_evento_por_defecto` | `INTEGER` | L40 |
| `v_tiene_acl_asociada` | `SMALLINT` | L41 |
| `c_nombre_pre_ingreso` | `CHAR(20)` | L42 |
| `c_estatus_pre_ingreso` | `INTEGER` | L43 |
| `v_es_cargo_recurrente` | `CHAR(2)` | L44 |
| `v_transacc_registrada_en_sistema` | `SMALLINT` | L45 |
| `v_es_saldo_retenido` | `SMALLINT` | L46 |
| `segundaLetraFolioSuc` | `CHAR(1)` | L48 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `acl_asociacion_origen_evento_canal` | `bdiaclaracion` | no | SELECT | L105 |
| `movimiento` | `intercard` | ⚠️ sí | SELECT | L125 |
| `movimientohistorico` | `intercard` | ⚠️ sí | SELECT | L133 |
| `td_movimientos_conciliacion` | `bditarjeta` | ⚠️ sí | SELECT | L141 |
| `td_movimientos_conciliacion_his` | `bditarjeta` | ⚠️ sí | SELECT | L148 |
| `acl_asociacion_origen` | `bdiaclaracion` | no | SELECT | L175 |
| `acl_movimiento` | `bdiaclaracion` | no | SELECT | L237 |
| `acl_estatus_corporativo` | `bdiaclaracion` | no | SELECT | L247 |
| `acl_tipo_movimiento` | `bdiaclaracion` | no | SELECT | L286 |
| `acl_origen_evento` | `bdiaclaracion` | no | SELECT | L306 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_consulta_cargo_recurrente` | `bdiaclaracion` | no | L260 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L112 | FÓRMULA | `LET v_secuenciaextendida = substr(pFoliosuc,2,(length(trim(pFoliosuc))-1));` |  |
| L130 | VALIDACIÓN_NULL | `IF (v_es_nacional IS NULL AND v_modo_entrada IS NULL) THEN` |  |
| L138 | VALIDACIÓN_NULL | `IF (v_es_nacional IS NULL AND v_modo_entrada IS NULL) THEN` |  |
| L145 | VALIDACIÓN_NULL | `IF (v_es_movimiento_forzado IS NULL) THEN` |  |
| L153 | VALIDACIÓN_NULL | `IF (v_es_movimiento_forzado IS NULL) THEN` |  |
| L165 | VALIDACIÓN_NULL | `IF (v_modo_entrada IS NULL OR v_modo_entrada = '') THEN` |  |
| L243 | VALIDACIÓN_NULL | `IF v_tiene_acl_asociada IS NULL THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `obten` | ACCION | obtiene / recupera | 🔵 CONVENCIÓN | nombre_sp |
| `origen` | ENTIDAD | origen | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `auto` | MODIF | automático (proceso automático / batch — sp_*_auto) | 🟡 INFERIDO | nombre_sp |
| `?matico` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?matico` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_obten_secuencia_folio`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_obten_secuencia_folio.sql` |
| **LOC (1er CREATE)** | 24 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "obtiene secuencia y folio" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `obtiene` → `SELECT` encontrado en el cuerpo · `obtiene` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=0 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_obten_secuencia_folio(
) RETURNING CHAR (5) AS secuenciaMax
```

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `secuenciaMax` | `CHAR(5)` | L5 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `systables` | `bdiaclaracion` | no | SELECT | L20 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `obten` | ACCION | obtiene / recupera | 🔵 CONVENCIÓN | nombre_sp |
| `secuencia` | ENTIDAD | secuencia | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `folio` | ENTIDAD | folio | 🔵 CONVENCIÓN | nombre_sp |

---

## `sp_obten_transaccion_afectacion`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_obten_transaccion_afectacion.sql` |
| **LOC (1er CREATE)** | 49 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "obtiene transacción y cuenta" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `obtiene` → `SELECT` encontrado en el cuerpo · `obtiene` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=2 / 6 términos |

### Firma

```sql
CREATE PROCEDURE sp_obten_transaccion_afectacion(
  numero_transaccion           CHAR(4)
) RETURNING CHAR(50) AS descripcion, CHAR(2) AS sistema
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `numero_transaccion` | `CHAR(4)` | `transaccion`=transacción | ✅ CÓDIGO |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `des_transaccion` | `CHAR(50)` | L6 |
| `producto` | `CHAR(2)` | L7 |
| `iSqlErr` | `INTEGER` | L8 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_transacc` | `bdinteg` | ⚠️ sí | SELECT | L29 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `obten` | ACCION | obtiene / recupera | 🔵 CONVENCIÓN | nombre_sp |
| `transaccion` | ENTIDAD | transacción | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `?_afe` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `cta` | ENTIDAD | cuenta | 🔵 CONVENCIÓN | nombre_sp |
| `?cion` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_afe`, `?cion` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_obtiene_periodo_vigencia_preingreso`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_obtiene_periodo_vigencia_preingreso.sql` |
| **LOC (1er CREATE)** | 60 |
| **Callgraph** | ✅ fan_in=0 / fan_out=5 |
| **Deps concatenadas** | 18 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "obtiene periodo y ingreso" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `obtiene` → `SELECT` encontrado en el cuerpo · `obtiene` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=3 · INFERIDO=1 · SINTÉTICO=2 / 7 términos |

### Firma

```sql
CREATE PROCEDURE sp_obtiene_periodo_vigencia_preingreso(
  pTipoAclaracion              INTEGER
) RETURNING CHAR(5)				AS cod_ret,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pTipoAclaracion` | `INTEGER` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `sql_err` | `INTEGER` | L8 |
| `v_cod_ret` | `CHAR(5)` | L9 |
| `v_existe_tipo_acl` | `SMALLINT` | L10 |
| `v_dias_vencimiento` | `INTEGER` | L11 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `acl_cat_tipo_aclaracion` | `bdiaclaracion` | no | SELECT | L35 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L29 | VALIDACIÓN_NULL | `IF (pTipoAclaracion IS NULL) THEN` |  |
| L38 | VALIDACIÓN_NULL | `IF (v_existe_tipo_acl IS NULL) THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `obtiene` | ACCION | obtiene / recupera | 🔵 CONVENCIÓN | nombre_sp |
| `periodo` | ENTIDAD | periodo | 🔵 CONVENCIÓN | nombre_sp |
| `?_vi` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `gen` | ACCION | genera / general | 🟡 INFERIDO | nombre_sp |
| `?cia_pre` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `ingreso` | ENTIDAD | ingreso (del solicitante) | ✅ CÓDIGO | nombre_sp, texto_cuerpo |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_vi`, `?cia_pre` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_recuperacion_saldos`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_recuperacion_saldos.sql` |
| **LOC (1er CREATE)** | 656 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "recuperación saldos" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `recupera` → `SELECT` encontrado en el cuerpo · `recupera` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=0 / 3 términos |

### Firma

```sql
CREATE PROCEDURE sp_recuperacion_saldos(
) RETURNING CHAR(7) AS CODIGO
```

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `v_folio` | `CHAR(24)` | L4 |
| `v_producto` | `SMALLINT` | L5 |
| `v_credito` | `SMALLINT` | L6 |
| `s_CodRet` | `CHAR(6)` | L8 |
| `v_mensaje` | `CHAR(600)` | L9 |
| `s_Mensaje` | `CHAR(100)` | L10 |
| `s_Cc` | `SMALLINT` | L11 |
| `s_AfectacionC` | `MONEY` | L12 |
| `s_CodleyendaC` | `CHAR(3)` | L13 |
| `s_Ci` | `SMALLINT` | L14 |
| `s_AfectacionI` | `MONEY` | L15 |
| `s_CodleyendaI` | `CHAR(3)` | L16 |
| `s_Ca` | `SMALLINT` | L17 |
| `s_AfectacionA` | `MONEY` | L18 |
| `s_CodleyendaA` | `CHAR(3)` | L19 |
| `s_Cin` | `SMALLINT` | L20 |
| `s_AfectacionIn` | `MONEY` | L21 |
| `s_CodleyendaIn` | `CHAR(3)` | L22 |
| `v_descripcion` | `LVARCHAR(625)` | L24 |
| `v_fechahora` | `DATETIME YEAR TO FRACTION(5)` | L25 |
| `v_folio_csuac` | `CHAR(24)` | L26 |
| `v_fky_accion` | `INTEGER` | L27 |
| `v_fky_aclaracion` | `INTEGER` | L28 |
| `v_fky_area` | `INTEGER` | L29 |
| `v_fky_estatus_aclaracion` | `INTEGER` | L30 |
| *…6 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `acl_recuperacion_saldos` | `bdiaclaracion` | no | SELECT | L119 |
| `acl_aclaracion` | `bdiaclaracion` | no | SELECT | L156 |
| `acl_entrada_bitacora` | `bdiaclaracion` | no | INSERT | L207 |
| `acl_bitacora_error_rec_saldo` | `bdiaclaracion` | no | INSERT | L381 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_upd_credrecuperacion` | `bdiaclaracion` | no | L131 |
| `sp_upd_debrecuperacion` | `bdiaclaracion` | no | L401 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `recuperacion` | ACCION | recuperación (cobranza) | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `saldos` | ENTIDAD | saldos | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |

---

## `sp_registra_comentario_cliente`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_registra_comentario_cliente.sql` |
| **LOC (1er CREATE)** | 94 |
| **Callgraph** | ✅ fan_in=0 / fan_out=5 |
| **Deps concatenadas** | 22 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "registra Comisión bancaria — cobro de comisión sobre cuenta, Tarjeta y cliente" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `registra` → `INSERT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=3 · INFERIDO=1 · SINTÉTICO=2 / 7 términos |

### Firma

```sql
CREATE PROCEDURE sp_registra_comentario_cliente(
  pIdAclaracion                INTEGER
  pMensaje                     LVARCHAR
) RETURNING CHAR(5)							as cod_ret
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pIdAclaracion` | `INTEGER` | — | — |
| `pMensaje` | `LVARCHAR` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `sql_err` | `INTEGER` | L8 |
| `v_cod_ret` | `CHAR(5)` | L9 |
| `v_pky_aclaracion` | `INTEGER` | L10 |
| `v_folio_csuac` | `CHAR(11)` | L11 |
| `v_fky_area` | `INTEGER` | L12 |
| `v_fky_estatus_aclaracion` | `INTEGER` | L13 |
| `v_fky_estatus_corp_analisis` | `INTEGER` | L14 |
| `v_fky_estatus_corp_general` | `INTEGER` | L15 |
| `c_accion_resolucion` | `INTEGER` | L16 |
| `c_fechahora` | `DATETIME YEAR to FRACTION(5)` | L17 |
| `c_usuario` | `INTEGER` | L18 |
| `c_separador` | `CHAR(1)` | L20 |
| `c_prefijo` | `CHAR(3)` | L21 |
| `v_existe_cliente` | `SMALLINT` | L23 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `acl_aclaracion` | `bdiaclaracion` | no | SELECT | L61 |
| `acl_resolucion` | `bdiaclaracion` | no | SELECT | L70 |
| `acl_entrada_bitacora` | `bdiaclaracion` | no | INSERT | L73 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L47 | VALIDACIÓN_NULL | `IF ((pMensaje IS NULL) OR (pMensaje = '')) AND (pIdAclaracion IS NULL) THEN` |  |
| L51 | VALIDACIÓN_NULL | `IF (pMensaje IS NULL) OR (pMensaje = '') THEN` |  |
| L55 | VALIDACIÓN_NULL | `IF (pIdAclaracion IS NULL) THEN` |  |
| L64 | VALIDACIÓN_NULL | `IF (v_pky_aclaracion IS NULL) THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `registra` | ACCION | registra | 🔵 CONVENCIÓN | nombre_sp |
| `com` | ENTIDAD | Comisión bancaria — cobro de comisión sobre cuenta (bdicheq: | 🔵 CONVENCIÓN | nombre_sp |
| `?en` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `tar` | ENTIDAD | Tarjeta (abreviación — bdicheq/bdicred: cons_cta_o_tar, move | 🟡 INFERIDO | nombre_sp |
| `?io_` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `cliente` | ENTIDAD | cliente | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?en`, `?io_` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_registra_cte_domiciliacion`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_registra_cte_domiciliacion.sql` |
| **LOC (1er CREATE)** | 116 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "registra cliente y domiciliación" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `registra` → `INSERT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=0 / 4 términos |

### Historia del SP

| Tipo | Valor |
|------|-------|
| DESCRIPCION | SP PRINCIPAL DE GUARDADO DE CLIENTES Y MOVIMIENTOS PARA CANCELACION Y OBJECION DE DOMICILIACIONES POR EL BUS. |
| FECHA | 22/07/2022 |

### Firma

```sql
CREATE PROCEDURE sp_registra_cte_domiciliacion(
  bandera                      CHAR(5)
  eEmpresa                     CHAR(5)
  eNumeroCliente               CHAR(20)
  eNumeroCuenta                CHAR(20)
  eNumeroTarjeta               CHAR(20)
  eClienteTelefonoCasa         CHAR(20)
  eTipoTelefono                INTEGER
  eCanalTelefono               INTEGER
  eNumEmpleado                 CHAR(12)
  eClienteCorreoElectronico    CHAR(100)
  eTipoCorreo                  INTEGER
  eCanalCorreo                 INTEGER
  eRefServicio                 CHAR(40)
  eTransaccion                 CHAR(5)
  eFolioSuc                    CHAR(20)
  opc1                         CHAR(80)
  opc2                         CHAR(80)
  opc3                         CHAR(80)
  opc4                         CHAR(80)
  opc5                         CHAR(80)
) RETURNING CHAR(5),CHAR(100),CHAR(80),CHAR(80),CHAR(80),CHAR(80),CHAR(80)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `bandera` | `CHAR(5)` | — | — |
| `eEmpresa` | `CHAR(5)` | — | — |
| `eNumeroCliente` | `CHAR(20)` | — | — |
| `eNumeroCuenta` | `CHAR(20)` | — | — |
| `eNumeroTarjeta` | `CHAR(20)` | — | — |
| `eClienteTelefonoCasa` | `CHAR(20)` | — | — |
| `eTipoTelefono` | `INTEGER` | — | — |
| `eCanalTelefono` | `INTEGER` | — | — |
| `eNumEmpleado` | `CHAR(12)` | — | — |
| `eClienteCorreoElectronico` | `CHAR(100)` | — | — |
| `eTipoCorreo` | `INTEGER` | — | — |
| `eCanalCorreo` | `INTEGER` | — | — |
| `eRefServicio` | `CHAR(40)` | — | — |
| `eTransaccion` | `CHAR(5)` | — | — |
| `eFolioSuc` | `CHAR(20)` | — | — |
| `opc1` | `CHAR(80)` | — | — |
| `opc2` | `CHAR(80)` | — | — |
| `opc3` | `CHAR(80)` | — | — |
| `opc4` | `CHAR(80)` | — | — |
| `opc5` | `CHAR(80)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `sCodigoRetorno` | `CHAR(5)` | L34 |
| `sCodigoDescripcion` | `CHAR(100)` | L35 |
| `ret1` | `CHAR(80)` | L36 |
| `ret2` | `CHAR(80)` | L37 |
| `ret3` | `CHAR(80)` | L38 |
| `ret4` | `CHAR(80)` | L39 |
| `ret5` | `CHAR(80)` | L40 |
| `cStatusCancelacion` | `CHAR(2)` | L41 |
| `iSQLerr` | `INTEGER` | L42 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `dom_errores` | `bdidomi` | ⚠️ sí | INSERT | L61 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_registra_telefonos` | `bdinteg` | ⚠️ sí | L73 |
| `sp_registra_correos` | `bdinteg` | ⚠️ sí | L78 |
| `sp_guarda_cancelaciones` | `bdidomi` | ⚠️ sí | L92 |
| `sp_guarda_obj_domi` | `bdidomi` | ⚠️ sí | L106 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `registra` | ACCION | registra | 🔵 CONVENCIÓN | nombre_sp |
| `cte` | ENTIDAD | cliente | 🔵 CONVENCIÓN | nombre_sp |
| `domiciliacion` | ENTIDAD | domiciliación | ✅ CÓDIGO | nombre_sp, texto_cuerpo |

---

## `sp_registra_documento_en_bitacora`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_registra_documento_en_bitacora.sql` |
| **LOC (1er CREATE)** | 108 |
| **Callgraph** | ✅ fan_in=0 / fan_out=6 |
| **Deps concatenadas** | 5 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "registra documento y bitácora" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `registra` → `INSERT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=1 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_registra_documento_en_bitacora(
  pIdAclaracion                INTEGER
  pIdDocumento                 INTEGER
  pUsuario                     INTEGER
) RETURNING CHAR(5)							as cod_ret
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pIdAclaracion` | `INTEGER` | — | — |
| `pIdDocumento` | `INTEGER` | `documento`=documento | ✅ CÓDIGO |
| `pUsuario` | `INTEGER` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `sql_err` | `INTEGER` | L8 |
| `v_cod_ret` | `CHAR(5)` | L9 |
| `v_pky_aclaracion` | `INTEGER` | L10 |
| `v_folio_csuac` | `CHAR(11)` | L11 |
| `v_fky_area` | `INTEGER` | L12 |
| `v_fky_estatus_aclaracion` | `INTEGER` | L13 |
| `v_fky_estatus_corp_analisis` | `INTEGER` | L14 |
| `v_fky_estatus_corp_general` | `INTEGER` | L15 |
| `v_mensaje` | `LVARCHAR` | L16 |
| `v_desc_documento` | `VARCHAR(255)` | L17 |
| `c_accion_resolucion` | `INTEGER` | L18 |
| `c_fechahora` | `DATETIME YEAR to FRACTION(5)` | L19 |
| `c_separador` | `CHAR(1)` | L21 |
| `c_prefijo` | `CHAR(3)` | L22 |
| `v_existe_cliente` | `SMALLINT` | L24 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `acl_aclaracion` | `bdiaclaracion` | no | SELECT | L63 |
| `acl_tipo_documento` | `bdiaclaracion` | no | SELECT | L72 |
| `acl_resolucion` | `bdiaclaracion` | no | SELECT | L82 |
| `acl_entrada_bitacora` | `bdiaclaracion` | no | INSERT | L87 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L49 | VALIDACIÓN_NULL | `IF (pIdDocumento IS NULL)  AND (pIdAclaracion IS NULL) THEN` |  |
| L53 | VALIDACIÓN_NULL | `IF (pIdAclaracion IS NULL) THEN` |  |
| L57 | VALIDACIÓN_NULL | `IF (pIdDocumento IS NULL) THEN` |  |
| L66 | VALIDACIÓN_NULL | `IF (v_pky_aclaracion IS NULL) THEN` |  |
| L76 | VALIDACIÓN_NULL | `IF (v_desc_documento IS NULL) THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `registra` | ACCION | registra | 🔵 CONVENCIÓN | nombre_sp |
| `documento` | ENTIDAD | documento | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `?_en_` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `bitacora` | ENTIDAD | bitácora | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_en_` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_registra_notificacion`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_registra_notificacion.sql` |
| **LOC (1er CREATE)** | 125 |
| **Callgraph** | ✅ fan_in=0 / fan_out=5 |
| **Deps concatenadas** | 25 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "registra" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `registra` → `INSERT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=1 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_registra_notificacion(
  p_folio                      char(11)
  p_cliente                    char(20)
  p_tel                        char(10)
  p_correo                     char(100)
  p_ident_sms                  integer
  p_ident_correo               integer
  p_canal                      char(10)
  p_tipo_notificacion          integer
) RETURNING CHAR(3) AS s_CodRetorno, INTEGER AS Error
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_folio` | `char(11)` | — | — |
| `p_cliente` | `char(20)` | — | — |
| `p_tel` | `char(10)` | — | — |
| `p_correo` | `char(100)` | — | — |
| `p_ident_sms` | `integer` | — | — |
| `p_ident_correo` | `integer` | — | — |
| `p_canal` | `char(10)` | — | — |
| `p_tipo_notificacion` | `integer` | `notifica`=notifica | 🔵 CONVENCIÓN |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `s_CodRet` | `CHAR(3)` | L9 |
| `v_Asunto` | `VARCHAR(50)` | L12 |
| `iSqlErr` | `INTEGER` | L13 |
| `v_pky_aclaracion` | `INTEGER` | L15 |
| `v_id_area` | `INTEGER` | L16 |
| `v_estatus_acl` | `INTEGER` | L17 |
| `v_estatus_corp_analisis` | `INTEGER` | L18 |
| `v_estatus_corp_general` | `INTEGER` | L19 |
| `v_id_accion` | `INTEGER` | L20 |
| `v_desc_bitacora` | `VARCHAR(100)` | L21 |
| `v_razon_envio` | `VARCHAR(50)` | L22 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `acl_aclaracion` | `bdiaclaracion` | no | SELECT | L58 |
| `acl_notificacion_det` | `bdiaclaracion` | no | INSERT | L62 |
| `acl_resolucion` | `bdiaclaracion` | no | SELECT | L71 |
| `acl_entrada_bitacora` | `bdiaclaracion` | no | INSERT | L82 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `registra` | ACCION | registra | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `notifica` | ACCION | notifica | 🔵 CONVENCIÓN | nombre_sp |
| `?cion` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?cion` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_registra_notificacion2`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_registra_notificacion2.sql` |
| **LOC (1er CREATE)** | 125 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 1 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "registra" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `registra` → `INSERT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=1 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_registra_notificacion2(
  p_folio                      char(11)
  p_cliente                    char(20)
  p_tel                        char(10)
  p_correo                     char(100)
  p_ident_sms                  integer
  p_ident_correo               integer
  p_canal                      char(12)
  p_tipo_notificacion          integer
) RETURNING CHAR(3) AS s_CodRetorno, INTEGER AS Error
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_folio` | `char(11)` | — | — |
| `p_cliente` | `char(20)` | — | — |
| `p_tel` | `char(10)` | — | — |
| `p_correo` | `char(100)` | — | — |
| `p_ident_sms` | `integer` | — | — |
| `p_ident_correo` | `integer` | — | — |
| `p_canal` | `char(12)` | — | — |
| `p_tipo_notificacion` | `integer` | `notifica`=notifica | 🔵 CONVENCIÓN |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `s_CodRet` | `CHAR(3)` | L9 |
| `v_Asunto` | `VARCHAR(50)` | L12 |
| `iSqlErr` | `INTEGER` | L13 |
| `v_pky_aclaracion` | `INTEGER` | L15 |
| `v_id_area` | `INTEGER` | L16 |
| `v_estatus_acl` | `INTEGER` | L17 |
| `v_estatus_corp_analisis` | `INTEGER` | L18 |
| `v_estatus_corp_general` | `INTEGER` | L19 |
| `v_id_accion` | `INTEGER` | L20 |
| `v_desc_bitacora` | `VARCHAR(255)` | L21 |
| `v_razon_envio` | `VARCHAR(50)` | L22 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `acl_aclaracion` | `bdiaclaracion` | no | SELECT | L58 |
| `acl_notificacion_det` | `bdiaclaracion` | no | INSERT | L62 |
| `acl_resolucion` | `bdiaclaracion` | no | SELECT | L71 |
| `acl_entrada_bitacora` | `bdiaclaracion` | no | INSERT | L82 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `registra` | ACCION | registra | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `notifica` | ACCION | notifica | 🔵 CONVENCIÓN | nombre_sp |
| `?cion2` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?cion2` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_reinicia_secuencia_folio`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_reinicia_secuencia_folio.sql` |
| **LOC (1er CREATE)** | 19 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "reinicia secuencia y folio" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — Tokens confirmados en el vocab pero DML no correlaciona con el propósito |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=4 · INFERIDO=0 · SINTÉTICO=0 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_reinicia_secuencia_folio(
) RETURNING CHAR (1) AS ret
```

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `ret` | `CHAR(1)` | L4 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `reinicia` | ACCION | reinicia / resetea | 🔵 CONVENCIÓN | nombre_sp |
| `secuencia` | ENTIDAD | secuencia | 🔵 CONVENCIÓN | nombre_sp |
| `folio` | ENTIDAD | folio | 🔵 CONVENCIÓN | nombre_sp |

---

## `sp_relaciona_folioacl_idacl`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_relaciona_folioacl_idacl.sql` |
| **LOC (1er CREATE)** | 106 |
| **Callgraph** | ✅ fan_in=0 / fan_out=5 |
| **Deps concatenadas** | 21 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "folio y identificador" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 4 tabla(s) con operaciones: SELECT, INSERT |
| **Evidencia vocab** | CÓDIGO=3 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=1 / 6 términos |

### Firma

```sql
CREATE PROCEDURE sp_relaciona_folioacl_idacl(
  pFolioAcl                    CHAR(18)
  pIdAclaracion                INTEGER
) RETURNING CHAR(5)							as cod_ret
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pFolioAcl` | `CHAR(18)` | `folio`=folio · `acl`=familia aclaraciones | ✅ CÓDIGO |
| `pIdAclaracion` | `INTEGER` | `acl`=familia aclaraciones · `id`=identificador (de) | ✅ CÓDIGO / 🔵 CONVENCIÓN |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `sql_err` | `INTEGER` | L7 |
| `v_cod_ret` | `CHAR(5)` | L8 |
| `v_folio_aclaracion` | `CHAR(18)` | L9 |
| `v_pky_aclaracion` | `INTEGER` | L10 |
| `v_fecha_folio` | `DATETIME YEAR to FRACTION(5)` | L11 |
| `v_fecha_aclaracion` | `DATE` | L12 |
| `v_cliente_folio` | `CHAR(9)` | L13 |
| `v_cliente_aclaracion` | `CHAR(9)` | L14 |
| `c_fecha_actual` | `DATE` | L15 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_fechas` | `bdinteg` | ⚠️ sí | SELECT | L52 |
| `acl_folio_aclaracion` | `bdiaclaracion` | no | SELECT | L56 |
| `acl_aclaracion` | `bdiaclaracion` | no | SELECT | L61 |
| `acl_folio_aclaracion_acl_aclaracion` | `bdiaclaracion` | no | INSERT | L88 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L38 | VALIDACIÓN_NULL | `IF ((pFolioAcl IS NULL) OR (pFolioAcl = '')) AND (pIdAclaracion IS NULL) THEN` |  |
| L42 | VALIDACIÓN_NULL | `IF (pFolioAcl IS NULL) OR (pFolioAcl = '') THEN` |  |
| L46 | VALIDACIÓN_NULL | `IF (pIdAclaracion IS NULL) THEN` |  |
| L64 | VALIDACIÓN_NULL | `IF ((v_folio_aclaracion IS NULL) OR (v_folio_aclaracion = '')) AND (v_pky_aclaracion IS NULL) THEN` |  |
| L68 | VALIDACIÓN_NULL | `IF (v_folio_aclaracion IS NULL) OR (v_folio_aclaracion = '') THEN` |  |
| L72 | VALIDACIÓN_NULL | `IF (v_pky_aclaracion IS NULL) THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `?_relaciona_` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `folio` | ENTIDAD | folio | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `acl` | PREFIJO | familia aclaraciones | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `id` | ENTIDAD | identificador (de) | 🔵 CONVENCIÓN | nombre_sp |
| `acl` | PREFIJO | familia aclaraciones | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_relaciona_` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_reporte_acl_aud`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_reporte_acl_aud.sql` |
| **LOC (1er CREATE)** | 809 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 1 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "reporte y auditoría" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 9 tabla(s) con operaciones: SELECT, INSERT, UPDATE |
| **Evidencia vocab** | CÓDIGO=3 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=0 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_reporte_acl_aud(
) RETURNING char(7)
```

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vcodret` | `char(7)` | L4 |
| `vsqlerr` | `integer` | L5 |
| `vsql` | `char(3000)` | L7 |
| `v_tarjeta` | `varchar(16)` | L9 |
| `v_fecha_de_cargo` | `date` | L10 |
| `v_fecha_abono` | `date` | L11 |
| `v_referencia23` | `varchar(23)` | L12 |
| `v_ref_comercio` | `varchar(40)` | L13 |
| `v_edo_comercio` | `varchar(25)` | L14 |
| `v_nacionalidad` | `varchar(15)` | L15 |
| `v_origen_operacion` | `varchar(50)` | L16 |
| `v_tipo_evento` | `integer` | L17 |
| `v_evento` | `varchar(50)` | L18 |
| `v_procede` | `smallint` | L19 |
| `v_predictamen` | `lvarchar` | L20 |
| `v_monto_procedente` | `money` | L21 |
| `v_comision_no_procedente` | `money` | L22 |
| `v_importe_recuperado` | `money` | L23 |
| `v_fechacaptura` | `date` | L25 |
| `v_fecha_dictamen` | `date` | L26 |
| `v_folio_csuac` | `varchar(11)` | L27 |
| `v_importeoriginal` | `money` | L28 |
| `v_num_empleado` | `varchar(8)` | L29 |
| `v_nombre_empleado` | `varchar(150)` | L30 |
| `v_analista` | `varchar(8)` | L31 |
| *…55 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_fechas` | `bdinteg` | ⚠️ sí | SELECT | L158 |
| `acl_aclaracion` | `bdiaclaracion` | no | SELECT | L226 |
| `acl_reporte_acl_aud` | `bdiaclaracion` | no | INSERT | L262 |
| `acl_movimiento` | `bdiaclaracion` | no | SELECT | L449 |
| `acl_recuperacion_saldos` | `bdiaclaracion` | no | SELECT | L456 |
| `acl_reporte_acl_aud` | `bdiaclaracion` | no | SELECT | L745 |
| `movimiento` | `intercard` | ⚠️ sí | SELECT | L752 |
| `movimientohistorico` | `intercard` | ⚠️ sí | SELECT | L758 |
| `acl_reporte_acl_aud` | `bdiaclaracion` | no | UPDATE | L762 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L129 | FÓRMULA | `let v_estatus_inicio = 3; --Intento` |  |
| L130 | FÓRMULA | `let v_estatus_fin = 5;    --Finalizada` |  |
| L331 | FÓRMULA | `LET iContador = iContador + 1;` |  |
| L465 | FÓRMULA | `LET vtm_importe_recuperado =nvl(v1_temp,0) + nvl(vtm_abono_afectado,0) + nvl(vtm_comision_recuperada` | 🔴 MONEY/aritmética financiera |
| L469 | VALIDACIÓN_NULL | `IF (vtm_importe_recuperado = 1 OR  vtm_importe_recuperado IS NULL) THEN` |  |
| L542 | FÓRMULA | `LET iContador = iContador + 1;` |  |
| L723 | FÓRMULA | `LET iContador = iContador + 1;` |  |
| L755 | VALIDACIÓN_NULL | `IF (v_nacionalidad='' or v_nacionalidad is null) THEN` |  |
| L775 | FÓRMULA | `let vsql = ' echo "folio_csuac\|fechacaptura\|fecha_dictamen\|importeoriginal\|num_empleado\|nombre_` | 🔴 MONEY/aritmética financiera |
| L777 | FÓRMULA | `let vsql=  'echo "UNLOAD TO /resplogifx/reportesaud/ReporteAclAud.unl '\|\|'SELECT folio_csuac,fecha` | 🔴 MONEY/aritmética financiera |
| L782 | FÓRMULA | `let vsql= 'dbaccess bdiaclaracion /resplogifx/reportesaud/ReporteAclAud.sql';` |  |
| L784 | FÓRMULA | `let vsql ='rm  /resplogifx/reportesaud/ReporteAclAud.sql';` |  |
| L786 | FÓRMULA | `let vsql = "sed 's/\|$//g' /resplogifx/reportesaud/ReporteAclAud.unl >>/resplogifx/reportesaud/REPOR` |  |
| L788 | FÓRMULA | `let vsql ='rm  /resplogifx/reportesaud/ReporteAclAud.unl';` |  |
| L790 | CÓDIGO_RETORNO | `let vcodret = '00000';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `reporte` | ENTIDAD | reporte | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `acl` | PREFIJO | familia aclaraciones | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `aud` | ENTIDAD | auditoría | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |

---

## `sp_reporte_alta_folio_transfer`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_reporte_alta_folio_transfer.sql` |
| **LOC (1er CREATE)** | 128 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "da de alta reporte, folio y transferencia" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 1 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=0 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_reporte_alta_folio_transfer(
  input_fechaIni               DATE
  input_fechaFin               DATE
) RETURNING VARCHAR(11) AS foliocsuac,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `input_fechaIni` | `DATE` | — | — |
| `input_fechaFin` | `DATE` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `v_folio_csuac` | `VARCHAR(11)` | L21 |
| `v_numero_cliente` | `VARCHAR(9)` | L22 |
| `v_numero_cuenta` | `VARCHAR(20)` | L23 |
| `v_numero_tarjeta` | `VARCHAR(16)` | L24 |
| `v_nombre_cliente` | `VARCHAR(100)` | L25 |
| `v_fecha_transaccion` | `DATETIME YEAR to FRACTION(5)` | L26 |
| `v_importe` | `MONEY` | L27 |
| `v_numero_sucursal` | `VARCHAR(10)` | L28 |
| `v_nombre_promotor` | `VARCHAR(45)` | L29 |
| `v_fecha_alta` | `DATE` | L30 |
| `v_tipo_alta` | `INTEGER` | L31 |
| `v_acuse_sms` | `INTEGER` | L32 |
| `v_acuse_correo` | `INTEGER` | L33 |
| `v_procede` | `SMALLINT` | L34 |
| `str_acuseSMS` | `VARCHAR(2)` | L36 |
| `str_acuseCorreo` | `VARCHAR(2)` | L37 |
| `str_procede` | `VARCHAR(10)` | L38 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `acl_aclaracion` | `bdiaclaracion` | no | SELECT | L75 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `reporte` | ENTIDAD | reporte | 🔵 CONVENCIÓN | nombre_sp |
| `alta` | ACCION | da de alta / registra | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `folio` | ENTIDAD | folio | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `transfer` | ENTIDAD | transferencia (forma larga de 'trans') | 🔵 CONVENCIÓN | nombre_sp |

---

## `sp_reporte_area_externa`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_reporte_area_externa.sql` |
| **LOC (1er CREATE)** | 267 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "reporte" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 2 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=2 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_reporte_area_externa(
  fechaInicialReporte          DATE
  fechaFinalReporte            DATE
  intTipoReporteExterno        INTEGER
) RETURNING DATE as fecha_ingreso,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `fechaInicialReporte` | `DATE` | `reporte`=reporte | 🔵 CONVENCIÓN |
| `fechaFinalReporte` | `DATE` | `reporte`=reporte | 🔵 CONVENCIÓN |
| `intTipoReporteExterno` | `INTEGER` | `reporte`=reporte · `x`=por (criterio) | 🔵 CONVENCIÓN |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `v_pky_temporal` | `INTEGER` | L21 |
| `v_fechacaptura` | `DATE` | L22 |
| `v_fecha_envio_area_externa` | `DATE` | L23 |
| `v_num_empleado` | `VARCHAR(11)` | L24 |
| `v_nombre_area` | `NVARCHAR(200)` | L25 |
| `v_fecha_respuesta_area_externa` | `DATE` | L26 |
| `v_comentario_respuesta_area_externa` | `LVARCHAR(1000)` | L27 |
| `v_tiempo_atencion` | `CHAR` | L28 |
| `v_numero_cuenta` | `VARCHAR(20)` | L29 |
| `v_num_cliente` | `VARCHAR(20)` | L30 |
| `v_importereclamado` | `MONEY` | L31 |
| `v_folio_csuac` | `VARCHAR(10)` | L32 |
| `v_tarjeta` | `VARCHAR (13)` | L33 |
| `v_fky_aclaracion` | `INTEGER` | L34 |
| `v_fky_bitacora` | `INTEGER` | L35 |
| `v_fky_resolucion` | `INTEGER` | L36 |
| `v_registro_validado` | `SMALLINT` | L37 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `acl_aclaracion` | `bdiaclaracion` | no | SELECT | L70 |
| `acl_entrada_bitacora` | `bdiaclaracion` | no | SELECT | L81 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `reporte` | ENTIDAD | reporte | 🔵 CONVENCIÓN | nombre_sp |
| `?_area_e` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `x` | MODIF | por (criterio) | 🔵 CONVENCIÓN | nombre_sp |
| `?terna` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_area_e`, `?terna` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_reporte_atm_acl_extra`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_reporte_atm_acl_extra.sql` |
| **LOC (1er CREATE)** | 357 |
| **Callgraph** | ✅ fan_in=0 / fan_out=5 |
| **Deps concatenadas** | 6 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "reporte y cajero automático" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 8 tabla(s) con operaciones: SELECT, DELETE, INSERT |
| **Evidencia vocab** | CÓDIGO=3 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=2 / 7 términos |

### Firma

```sql
CREATE PROCEDURE sp_reporte_atm_acl_extra(
) RETURNING char(5)
```

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vsql` | `char(3000)` | L6 |
| `vcodret` | `char(5)` | L7 |
| `vsqlerr` | `integer` | L8 |
| `v_folio_csuac` | `char(11)` | L9 |
| `p_folio_csuac` | `char(11)` | L10 |
| `v_numero_tarjeta` | `varchar(20)` | L11 |
| `v_importereclamado` | `numeric` | L12 |
| `v_fecha_mov` | `date` | L13 |
| `v_hora_mov` | `char(20)` | L14 |
| `v_ref_comercio` | `varchar(200)` | L15 |
| `v_secuencia` | `varchar(50)` | L16 |
| `v_cuenta_destino` | `char(20)` | L17 |
| `v_nombre1` | `varchar(200)` | L18 |
| `v_nombre2` | `varchar(100)` | L19 |
| `v_apell_paterno` | `varchar(100)` | L20 |
| `v_apell_materno` | `varchar(100)` | L21 |
| `v_telefono` | `char(20)` | L22 |
| `v_numero_cuenta` | `char(20)` | L23 |
| `v_producto` | `varchar(50)` | L24 |
| `v_origen` | `varchar(20)` | L25 |
| `v_origen_evento` | `varchar(100)` | L26 |
| `v_evento` | `varchar(100)` | L27 |
| `v_estatus_general` | `varchar(100)` | L28 |
| `v_estatus_analisis` | `varchar(100)` | L29 |
| `v_numero_sucursal` | `varchar(10)` | L30 |
| *…14 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `systables` | `bdiaclaracion` | no | SELECT | L88 |
| `si_fechas` | `bdinteg` | ⚠️ sí | SELECT | L145 |
| `acl_folios_atm` | `bdiaclaracion` | no | SELECT | L155 |
| `acl_aclaracion` | `bdiaclaracion` | no | SELECT | L193 |
| `sd_maecred` | `bdicred` | ⚠️ sí | SELECT | L215 |
| `sc_maechq` | `bdicheq` | ⚠️ sí | SELECT | L224 |
| `acl_reporte_atm` | `bdiaclaracion` | no | INSERT | L232 |
| `acl_folios_atm` | `bdiaclaracion` | no | DELETE | L329 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L210 | FÓRMULA | `LET v_nombre_sucursal = trim(v_nombre_sucursal)\|\|'-'\|\|trim(v_numero_sucursal);` |  |
| L286 | FÓRMULA | `LET iContador = iContador + 1;` |  |
| L303 | FÓRMULA | `let vsql = ' echo "FOLIO_CSUAC\|NO_DE_PLÃSTICO\|MONTO_RECLAMADO\|FECHA\|HORA_OPERACION\|NUMERO_CAJE` | 🔴 MONEY/aritmética financiera |
| L315 | FÓRMULA | `let vsql = "sed 's/\|$//g' reporte_atm.txt >>/resplogifx/repaclaraciones/ACL_ATM_"\|\|LPAD (day(p_fe` |  |
| L335 | CÓDIGO_RETORNO | `let vcodret = '00000';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `reporte` | ENTIDAD | reporte | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `atm` | ENTIDAD | cajero automático (ATM) | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `acl` | PREFIJO | familia aclaraciones | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `?_e` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `x` | MODIF | por (criterio) | 🔵 CONVENCIÓN | nombre_sp |
| `?tra` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_e`, `?tra` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_reporte_diario_cat`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_reporte_diario_cat.sql` |
| **LOC (1er CREATE)** | 388 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "reporte y catálogo (diario)" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 7 tabla(s) con operaciones: SELECT, INSERT, UPDATE |
| **Evidencia vocab** | CÓDIGO=3 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=0 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_reporte_diario_cat(
) RETURNING CHAR(06) AS resultado
```

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cfechacaptura` | `DATETIME YEAR to FRACTION(5)` | L9 |
| `chfechacaptura` | `VARCHAR(16)` | L10 |
| `choracaptura` | `VARCHAR(16)` | L11 |
| `cfolio_csuac` | `VARCHAR(11)` | L12 |
| `cimporteoriginal` | `VARCHAR(16)` | L13 |
| `cempleado_registro` | `VARCHAR(9)` | L14 |
| `csucursal` | `VARCHAR(4)` | L15 |
| `ctipo_movimiento` | `VARCHAR(20)` | L16 |
| `corigen_cargo` | `VARCHAR(20)` | L17 |
| `cnum_cliente` | `VARCHAR(9)` | L18 |
| `csucursal_apertura` | `VARCHAR(4)` | L19 |
| `cfecha_de_cargo` | `DATE` | L20 |
| `chfecha_de_cargo` | `VARCHAR(16)` | L21 |
| `cfky_origen_evento` | `VARCHAR(4)` | L22 |
| `corigen` | `VARCHAR(100)` | L23 |
| `cfky_tipo_evento` | `VARCHAR(4)` | L24 |
| `cevento` | `VARCHAR(100)` | L25 |
| `ccanal` | `VARCHAR(3)` | L26 |
| `cpreingreso` | `VARCHAR(11)` | L27 |
| `cfechahorallamada` | `VARCHAR(20)` | L29 |
| `cfecharesolucion` | `DATETIME YEAR to FRACTION(5)` | L30 |
| `chfecharesolucion` | `VARCHAR(16)` | L31 |
| `choraresolucion` | `VARCHAR(16)` | L32 |
| `cfolioconsecutivo` | `VARCHAR(15)` | L33 |
| `cprocede` | `CHAR(1)` | L34 |
| *…19 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `systables` | `bdiaclaracion` | no | SELECT | L125 |
| `si_fechas` | `bdinteg` | ⚠️ sí | SELECT | L171 |
| `acl_aclaracion` | `bdiaclaracion` | no | SELECT | L181 |
| `acl_reporte_cat_temp` | `bdiaclaracion` | no | INSERT | L197 |
| `acl_reporte_cat_temp` | `bdiaclaracion` | no | SELECT | L221 |
| `acl_reporte_cat_temp` | `bdiaclaracion` | no | UPDATE | L231 |
| `acl_reporte_reporte_diario_cat` | `bdiaclaracion` | no | INSERT | L298 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L90 | CÓDIGO_RETORNO | `LET cCodRet      	= '00000';` |  |
| L94 | FÓRMULA | `LET cRuta		 	= "/resplogifx/repaclaraciones/";` |  |
| L105 | CÓDIGO_RETORNO | `LET cCodRet = '00000';` |  |
| L223 | FÓRMULA | `LET iContador = iContador + 1;` |  |
| L230 | FÓRMULA | `LET iContador = iContador - 1;` |  |
| L252 | FÓRMULA | `LET chfechacaptura = TO_CHAR(cfechacaptura,"%d/%m/%Y");` |  |
| L258 | FÓRMULA | `LET cfechahorallamada = TO_CHAR(cfechacaptura,"%d/%m/%Y %H:%M:%S");` |  |
| L270 | FÓRMULA | `LET chfecharesolucion = TO_CHAR(cfecharesolucion,"%d/%m/%Y");` |  |
| L279 | FÓRMULA | `LET chfecha_de_cargo = TO_CHAR(cfecha_de_cargo,"%d/%m/%Y");` |  |
| L328 | FÓRMULA | `LET iContador = iContador + 1;` |  |
| L342 | FÓRMULA | `LET cCons1 = "SELECT * FROM acl_reporte_reporte_diario_cat";` |  |
| L371 | FÓRMULA | `LET cQuery =  "/usr/bin/cat " \|\| TRIM(cRuta)\|\|"EncabezadoR.txt " \|\| TRIM(cRuta)\|\|"CuerpoR.tx` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `reporte` | ENTIDAD | reporte | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `diario` | MODIF | diario | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `cat` | ENTIDAD | catálogo | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |

---

## `sp_reporte_evidencias_3410`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_reporte_evidencias_3410.sql` |
| **LOC (1er CREATE)** | 453 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "reporte y identificador" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 19 tabla(s) con operaciones: SELECT, INSERT |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=2 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_reporte_evidencias_3410(
) RETURNING CHAR(06) AS resultado
```

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `id_tipo_flujo` | `INTEGER` | L8 |
| `tipo_flujo` | `DATETIME YEAR TO MINUTE` | L9 |
| `cFoliocsuac` | `CHAR(11)` | L10 |
| `p_interact` | `CHAR(1)` | L11 |
| `cFechacaptura` | `DATE` | L12 |
| `cNumcliente` | `CHAR(9)` | L13 |
| `cFoliosuc` | `CHAR(20)` | L14 |
| `cNumuenta` | `CHAR(20)` | L15 |
| `cNumtarjeta` | `CHAR(16)` | L16 |
| `cStatustarjeta` | `VARCHAR(3)` | L17 |
| `chFechacancelacion` | `VARCHAR(25)` | L18 |
| `chFecha_act_cvv2` | `VARCHAR(25)` | L19 |
| `chFecha_act_pin` | `VARCHAR(25)` | L20 |
| `cFechacancelacion` | `DATETIME YEAR to MINUTE` | L21 |
| `cFechacancelacion2` | `DATETIME YEAR to MINUTE` | L22 |
| `fecha_act_cvv2` | `DATETIME YEAR to MINUTE` | L23 |
| `fecha_act_pin` | `DATETIME YEAR to MINUTE` | L24 |
| `cod_giro` | `VARCHAR(8)` | L25 |
| `idComer` | `VARCHAR(15)` | L26 |
| `ctokens63in` | `CHAR(550)` | L27 |
| `tokenC0` | `CHAR(37)` | L28 |
| `dFechaHoy` | `DATE` | L29 |
| `iContador` | `INTEGER` | L30 |
| `iSqlErr` | `INTEGER` | L31 |
| `iIsamErr` | `INTEGER` | L32 |
| *…24 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `systables` | `bdiaclaracion` | no | SELECT | L132 |
| `si_fechas` | `bdinteg` | ⚠️ sí | SELECT | L167 |
| `acl_aclaracion` | `bdiaclaracion` | no | SELECT | L176 |
| `bitacoracancelaciontarjetas` | `intercard` | ⚠️ sí | SELECT | L189 |
| `bit_pinoffline` | `intercard` | ⚠️ sí | SELECT | L194 |
| `bitacoracambiostarjeta` | `intercard` | ⚠️ sí | SELECT | L199 |
| `movimiento` | `intercard` | ⚠️ sí | SELECT | L212 |
| `movimientohistorico` | `intercard` | ⚠️ sí | SELECT | L219 |
| `acl_tipo_movimiento` | `bdiaclaracion` | no | SELECT | L234 |
| `acl_producto` | `bdiaclaracion` | no | SELECT | L240 |
| `sd_movdia` | `bdicred` | ⚠️ sí | SELECT | L250 |
| `sd_movhis` | `bdicred` | ⚠️ sí | SELECT | L255 |
| `sc_movdia` | `bdicheq` | ⚠️ sí | SELECT | L270 |
| `sc_movhis` | `bdicheq` | ⚠️ sí | SELECT | L275 |
| `sv_movdia` | `bdinvers` | ⚠️ sí | SELECT | L288 |
| `sv_movhis` | `bdinvers` | ⚠️ sí | SELECT | L296 |
| `si_direcciones_actual` | `bdinteg` | ⚠️ sí | SELECT | L307 |
| `bitacoracambiosstatustarjeta` | `intercard` | ⚠️ sí | SELECT | L318 |
| `acl_reporte_evidencia_3410` | `bdiaclaracion` | no | INSERT | L368 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L86 | CÓDIGO_RETORNO | `LET cCodRet      	= '00000';` |  |
| L90 | FÓRMULA | `LET cRuta		 	= "/resplogifx/repaclaraciones/";` |  |
| L113 | CÓDIGO_RETORNO | `LET cCodRet = '00000';` |  |
| L215 | VALIDACIÓN_NULL | `IF cod_giro IS NULL OR idComer = ''` |  |
| L244 | VALIDACIÓN_NULL | `IF v_sucursal IS NULL THEN` |  |
| L252 | VALIDACIÓN_NULL | `IF v_sucursal IS NULL OR v_sucursal = '' THEN` |  |
| L272 | VALIDACIÓN_NULL | `IF v_sucursal IS NULL OR v_sucursal = '' THEN` |  |
| L278 | VALIDACIÓN_NULL | `IF v_sucursal IS NULL OR v_sucursal = '' THEN` |  |
| L285 | VALIDACIÓN_NULL | `IF v_sucursal IS NULL OR v_sucursal = '' THEN` |  |
| L293 | VALIDACIÓN_NULL | `IF v_sucursal IS NULL OR v_sucursal = '' THEN` |  |
| L325 | FÓRMULA | `LET chFechacancelacion = TO_CHAR(cFechacancelacion,"%d/%m/%Y %H:%M");` |  |
| L330 | FÓRMULA | `LET chFechacancelacion = TO_CHAR(cFechacancelacion,"%d/%m/%Y %H:%M");` |  |
| L335 | FÓRMULA | `LET chFecha_act_pin = TO_CHAR(fecha_act_pin,"%d/%m/%Y %H:%M");` |  |
| L340 | FÓRMULA | `LET chFecha_act_cvv2 = TO_CHAR(fecha_act_cvv2,"%d/%m/%Y %H:%M");` |  |
| L397 | FÓRMULA | `LET iContador = iContador + 1;` |  |
| L413 | FÓRMULA | `LET cCons1 = "SELECT * FROM acl_reporte_evidencia_3410";` |  |
| L439 | FÓRMULA | `LET cQuery =  "/usr/bin/cat " \|\| TRIM(cRuta)\|\|"Encabezado.txt " \|\| TRIM(cRuta)\|\|"Cuerpo.txt ` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `reporte` | ENTIDAD | reporte | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `?_ev` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `id` | ENTIDAD | identificador (de) | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `?encias_3410` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_ev`, `?encias_3410` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_reporte_mensual_acl`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_reporte_mensual_acl.sql` |
| **LOC (1er CREATE)** | 190 |
| **Callgraph** | ✅ fan_in=0 / fan_out=6 |
| **Deps concatenadas** | 3 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "reporte (mensual)" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 5 tabla(s) con operaciones: SELECT, INSERT |
| **Evidencia vocab** | CÓDIGO=3 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=0 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_reporte_mensual_acl(
) RETURNING char(5)
```

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vsql` | `char(3000)` | L4 |
| `vcodret` | `char(5)` | L5 |
| `vsqlerr` | `integer` | L6 |
| `p_cuenta` | `varchar(20)` | L7 |
| `p_folio` | `varchar(20)` | L8 |
| `p_tarjeta` | `varchar(20)` | L9 |
| `p_cliente` | `varchar(20)` | L10 |
| `p_nombre1` | `varchar(200)` | L11 |
| `p_nombre2` | `varchar(50)` | L12 |
| `p_apell_paterno` | `varchar(50)` | L13 |
| `p_apell_materno` | `varchar(50)` | L14 |
| `p_rfc` | `varchar(20)` | L15 |
| `p_curp` | `varchar(20)` | L16 |
| `p_evento` | `varchar(50)` | L17 |
| `icontador` | `integer` | L18 |
| `v_fecha_fin` | `date` | L19 |
| `v_fecha_inicio` | `date` | L20 |
| `v_temp_tabla` | `INTEGER` | L21 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `systables` | `bdiaclaracion` | no | SELECT | L41 |
| `si_fechas` | `bdinteg` | ⚠️ sí | SELECT | L67 |
| `acl_aclaracion` | `bdiaclaracion` | no | SELECT | L116 |
| `acl_reporte_mensual` | `bdiaclaracion` | no | INSERT | L127 |
| `acl_reporte_mensual` | `bdiaclaracion` | no | SELECT | L150 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L130 | FÓRMULA | `LET iContador = iContador + 1;` |  |
| L147 | FÓRMULA | `let vsql = ' echo "Folio_Csuac\|Numero_Cuenta\|Numero_tarjeta\|Num_Cliente\|Nombre_cliente\|Rfc\|Cur` |  |
| L159 | FÓRMULA | `let vsql = "sed 's/\|$//g' reportemensual.unl >>/resplogifx/repaclaraciones/ACL_INGRESADAS_"\|\|LPAD` |  |
| L164 | CÓDIGO_RETORNO | `let vcodret = '00000';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `reporte` | ENTIDAD | reporte | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `mensual` | MODIF | mensual | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `acl` | PREFIJO | familia aclaraciones | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |

---

## `sp_reporte_regulatorio_r27`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_reporte_regulatorio_r27.sql` |
| **LOC (1er CREATE)** | 96 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "registro reporte" `[partial]` |
| **Propósito verificado** | ❓ NO_VERIFICABLE — Propósito inferido; sin evidencia DML para verificar |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=2 · INFERIDO=1 · SINTÉTICO=1 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_reporte_regulatorio_r27(
  fechaIni                     DATE
  fechaFin                     DATE
) RETURNING CHAR(11) AS folio_csuac, DATE AS fechacaptura, DATE AS fecha_movimiento, CHAR(20) AS numero_cuenta, CHAR(16) AS numero_tarjeta, CHAR(255) AS producto, CHAR(50) AS evento, CHAR(50) AS origen, MONEY(16,2) AS importereclamado, CHAR(255) AS Estatus, CHAR(50) AS Resolucion, DATE AS fecha_dictamen, CHAR(255) AS predictamen, MONEY(16,2) AS montoprocedente, DATE AS fecha_abono, MONEY(16,2) AS monto_abonoAutomatico
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `fechaIni` | `DATE` | — | — |
| `fechaFin` | `DATE` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `resultado_folio_csuac` | `CHAR(11)` | L6 |
| `resultado_fechacaptura` | `DATE` | L7 |
| `resultado_fecha_movimiento` | `DATE` | L8 |
| `resultado_numero_cuenta` | `CHAR(20)` | L9 |
| `resultado_numero_tarjeta` | `CHAR(16)` | L10 |
| `resultado_producto` | `CHAR(255)` | L11 |
| `resultado_evento` | `CHAR(50)` | L12 |
| `resultado_origen` | `CHAR(50)` | L13 |
| `resultado_importereclamado` | `MONEY(16,2)` | L14 |
| `resultado_estatus` | `CHAR(255)` | L15 |
| `resultado_resolucion` | `CHAR(50)` | L16 |
| `resultado_fecha_dictamen` | `DATE` | L17 |
| `resultado_predictamen` | `CHAR(255)` | L18 |
| `resultado_montoprocedente` | `MONEY(16,2)` | L19 |
| `resultado_fecha_abono` | `DATE` | L20 |
| `resultado_monto_abonoAutomatico` | `MONEY(16,2)` | L21 |
| `iSqlErr` | `INTEGER` | L22 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L88 | VALIDACIÓN_NULL | `IF (SUBSTR (resultado_numero_cuenta, 0, 4) IN ('1900', '2200') AND resultado_numero_tarjeta = '' OR ` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `reporte` | ENTIDAD | reporte | 🔵 CONVENCIÓN | nombre_sp |
| `reg` | ACCION | registro | 🟡 INFERIDO | nombre_sp |
| `?ulatorio_r27` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?ulatorio_r27` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_reporteaclaracomisionnoprocedentenoaplicada`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_reporteaclaracomisionnoprocedentenoaplicada.sql` |
| **LOC (1er CREATE)** | 150 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "procede reporte · comisión" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 1 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=4 · INFERIDO=0 · SINTÉTICO=4 / 10 términos |

### Firma

```sql
CREATE PROCEDURE sp_reporteaclaracomisionnoprocedentenoaplicada(
  e_fechaIni                   DATE
  e_fechaFin                   DATE
  e_producto                   INTEGER
  e_tipoBusqueda               INTEGER
) RETURNING VARCHAR(11) AS folio_csuac,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `e_fechaIni` | `DATE` | — | — |
| `e_fechaFin` | `DATE` | — | — |
| `e_producto` | `INTEGER` | — | — |
| `e_tipoBusqueda` | `INTEGER` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `v_folio_csuac` | `VARCHAR(11)` | L24 |
| `v_fecha_trans` | `DATETIME YEAR to FRACTION(5)` | L25 |
| `v_cliente` | `VARCHAR (9)` | L26 |
| `v_cuenta` | `VARCHAR (20)` | L27 |
| `v_tarjeta` | `VARCHAR (16)` | L28 |
| `v_nombre_cliente` | `VARCHAR(100)` | L29 |
| `v_total_cobro_comision` | `MONEY` | L30 |
| `v_monto_cargado_comision` | `MONEY` | L31 |
| `v_monto_no_aplicado_comision` | `MONEY` | L32 |
| `v_total_cobro_iva` | `MONEY` | L33 |
| `v_monto_cargado_iva` | `MONEY` | L34 |
| `v_monto_no_aplicado_iva` | `MONEY` | L35 |
| `v_suma_tcc` | `MONEY` | L36 |
| `v_suma_mcc` | `MONEY` | L37 |
| `v_suma_mnac` | `MONEY` | L38 |
| `v_suma_tci` | `MONEY` | L39 |
| `v_suma_mci` | `MONEY` | L40 |
| `v_suma_mnai` | `MONEY` | L41 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `acl_recuperacion_saldos` | `bdiaclaracion` | no | SELECT | L58 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `reporte` | ENTIDAD | reporte | 🔵 CONVENCIÓN | nombre_sp |
| `acl` | PREFIJO | familia aclaraciones | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `?ara` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `comision` | REG | comisión (CONDUSEF — debe estar en RECO) | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `?no` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `procede` | ACCION | procede | 🔵 CONVENCIÓN | nombre_sp |
| `?nteno` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `aplica` | ACCION | aplica / ejecuta | 🔵 CONVENCIÓN | nombre_sp |
| `?da` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?ara`, `?no`, `?nteno`, `?da` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_reporteaclaraestatusintento_listado`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_reporteaclaraestatusintento_listado.sql` |
| **LOC (1er CREATE)** | 103 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "reporte, estatus y interés" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 1 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=2 · INFERIDO=1 · SINTÉTICO=2 / 7 términos |

### Firma

```sql
CREATE PROCEDURE sp_reporteaclaraestatusintento_listado(
  fechaIni                     DATE
  fechaFin                     DATE
) RETURNING CHAR(20) AS estatus_aclaracion, DATETIME YEAR to FRACTION(5) AS fecha_intento,CHAR (10) AS num_sucursal,CHAR (50) AS motivo_intento, CHAR (8) AS usuario,INTEGER AS usuario_cancela,INTEGER AS error_sistema,INTEGER AS resp_incorrecta_prefiltro,INTEGER AS error_conexion_interact,INTEGER AS error_conexion_hibernate,INTEGER AS error_causas_no_identificadas
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `fechaIni` | `DATE` | — | — |
| `fechaFin` | `DATE` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `intento` | `INTEGER` | L5 |
| `v_estatus_aclaracion` | `CHAR (20)` | L6 |
| `v_fecha_intento` | `DATETIME YEAR to FRACTION(5)` | L7 |
| `v_num_sucursal` | `CHAR (10)` | L8 |
| `v_motivo_intento` | `CHAR (50)` | L9 |
| `v_usuario` | `CHAR (8)` | L10 |
| `v_usuario_cancela` | `INTEGER` | L12 |
| `v_error_sistema` | `INTEGER` | L13 |
| `v_resp_incorrecta` | `INTEGER` | L14 |
| `v_con_interact` | `INTEGER` | L15 |
| `v_con_hibernate` | `INTEGER` | L16 |
| `v_error_NoRegistrado` | `INTEGER` | L17 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `acl_aclaracion` | `bdiaclaracion` | no | SELECT | L26 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L25 | FÓRMULA | `LET v_usuario_cancela = (SELECT COUNT(*) AS usuario_cancela` |  |
| L32 | FÓRMULA | `LET v_error_sistema = (SELECT COUNT(*) AS error_sistema` |  |
| L39 | FÓRMULA | `LET v_resp_incorrecta= (SELECT COUNT(*) AS resp_incorrecta` |  |
| L46 | FÓRMULA | `LET v_con_interact = ( SELECT COUNT(*) AS con_interact` |  |
| L53 | FÓRMULA | `LET v_con_hibernate = ( SELECT COUNT(*) AS con_hibernate` |  |
| L60 | FÓRMULA | `LET v_error_NoRegistrado = ( SELECT COUNT(*) AS no_registrado` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `reporte` | ENTIDAD | reporte | 🔵 CONVENCIÓN | nombre_sp |
| `acl` | PREFIJO | familia aclaraciones | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `?ara` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `estatus` | ENTIDAD | estatus | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `int` | ENTIDAD | interés | 🟡 INFERIDO | nombre_sp |
| `?ento_listado` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?ara`, `?ento_listado` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_reporteaclaranoprocedentesinsaldo`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_reporteaclaranoprocedentesinsaldo.sql` |
| **LOC (1er CREATE)** | 199 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "procede reporte" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 1 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=3 · INFERIDO=1 · SINTÉTICO=3 / 8 términos |

### Firma

```sql
CREATE PROCEDURE sp_reporteaclaranoprocedentesinsaldo(
  e_fechaIni                   CHAR(15)
  e_fechaFin                   CHAR(15)
  e_producto                   INTEGER
  e_tipoBusqueda               INTEGER
) RETURNING CHAR(11) AS folio_csuac,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `e_fechaIni` | `CHAR(15)` | — | — |
| `e_fechaFin` | `CHAR(15)` | — | — |
| `e_producto` | `INTEGER` | — | — |
| `e_tipoBusqueda` | `INTEGER` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `v_folio_csuac` | `CHAR(11)` | L19 |
| `v_fecha_trans` | `DATETIME YEAR to FRACTION(5)` | L20 |
| `v_fecha_abono_trans` | `DATETIME YEAR to FRACTION(5)` | L21 |
| `v_cuenta` | `CHAR (20)` | L22 |
| `v_tarjeta` | `CHAR (16)` | L23 |
| `v_nombre_cliente` | `CHAR(100)` | L24 |
| `v_importe_reclamado` | `MONEY` | L25 |
| `v_importe_abonado` | `MONEY` | L26 |
| `v_importe_recuperado` | `MONEY` | L27 |
| `v_importe_quebranto` | `MONEY` | L28 |
| `v_interes_pagado` | `MONEY` | L29 |
| `v_interes_recuperado` | `MONEY` | L30 |
| `v_inicio_recuperacion` | `DATE` | L31 |
| `v_termino_recuperacion` | `DATE` | L32 |
| `p_interes_abonado` | `MONEY` | L33 |
| `fecha_inicial_convertida` | `DATE` | L34 |
| `fecha_final_convertida` | `DATE` | L35 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `acl_recuperacion_saldos` | `bdiaclaracion` | no | SELECT | L77 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L41 | FÓRMULA | `LET fecha_inicial_convertida =(TO_DATE(e_fechaIni,'%Y-%m-%d')) ;` |  |
| L42 | FÓRMULA | `LET fecha_final_convertida = (TO_DATE(e_fechaFin,'%Y-%m-%d'));` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `reporte` | ENTIDAD | reporte | 🔵 CONVENCIÓN | nombre_sp |
| `acl` | PREFIJO | familia aclaraciones | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `?arano` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `procede` | ACCION | procede | 🔵 CONVENCIÓN | nombre_sp |
| `?ntes` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `ins` | ACCION | insertar | 🟡 INFERIDO | nombre_sp |
| `?aldo` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?arano`, `?ntes`, `?aldo` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_reporteaclarareciensucursal`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_reporteaclarareciensucursal.sql` |
| **LOC (1er CREATE)** | 147 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "recepción reporte y sucursal" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 6 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=4 · INFERIDO=0 · SINTÉTICO=2 / 7 términos |

### Firma

```sql
CREATE PROCEDURE sp_reporteaclarareciensucursal(
  fechaIni                     DATE
  fechaFin                     DATE
) RETURNING CHAR(8) AS fecha, INTEGER AS ingresadas,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `fechaIni` | `DATE` | — | — |
| `fechaFin` | `DATE` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `res_fecha` | `CHAR(8)` | L7 |
| `res_ingresadas` | `INTEGER` | L8 |
| `res_en_proceso` | `INTEGER` | L9 |
| `res_dictaminadas` | `INTEGER` | L10 |
| `res_con_dictamen_impreso` | `INTEGER` | L11 |
| `res_finalizadas` | `INTEGER` | L12 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `acl_aclaracion` | `bdiaclaracion` | no | SELECT | L19 |
| `temp_ingresadas` | `bdiaclaracion` | no | SELECT | L29 |
| `temp_en_proceso` | `bdiaclaracion` | no | SELECT | L46 |
| `temp_dictaminadas` | `bdiaclaracion` | no | SELECT | L62 |
| `temp_dictamen_impreso` | `bdiaclaracion` | no | SELECT | L78 |
| `temp_finalizadas` | `bdiaclaracion` | no | SELECT | L94 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `reporte` | ENTIDAD | reporte | 🔵 CONVENCIÓN | nombre_sp |
| `acl` | PREFIJO | familia aclaraciones | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `?ara` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `rec` | ACCION | recepción / recibe | 🔵 CONVENCIÓN | nombre_sp |
| `?ien` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `sucursal` | ENTIDAD | sucursal | 🔵 CONVENCIÓN | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?ara`, `?ien` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_reporteavisoimpsuc`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_reporteavisoimpsuc.sql` |
| **LOC (1er CREATE)** | 393 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "reporte y Impago — pago vencido o fallido; confirmado: n_impagos_consec (sucursal)" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `confirma` → `SELECT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=3 · INFERIDO=1 · SINTÉTICO=1 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_reporteavisoimpsuc(
  opcion_de_estatus            integer
  fechaInicial                 date
  fechaFinal                   date
) RETURNING CHAR(25) AS folio_csuac, CHAR(25) AS numero_cuenta, CHAR(25) AS numero_tarjeta, CHAR(25) AS numero_sucursal,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `opcion_de_estatus` | `integer` | — | — |
| `fechaInicial` | `date` | — | — |
| `fechaFinal` | `date` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `res_estatus` | `CHAR(25)` | L10 |
| `resultado_folio_csuac` | `CHAR(25)` | L11 |
| `resultado_numero_cuenta` | `CHAR(25)` | L12 |
| `resultado_numero_tarjeta` | `CHAR(25)` | L13 |
| `resultado_numero_sucursal` | `CHAR(25)` | L14 |
| `resultado_nombre1` | `CHAR(25)` | L16 |
| `resultado_nombre2` | `CHAR(25)` | L17 |
| `resultado_apell_paterno` | `CHAR(25)` | L18 |
| `resultado_apell_materno` | `CHAR(25)` | L19 |
| `resultado_numero_cliente` | `CHAR(25)` | L20 |
| `resultado_numero_promotor` | `CHAR(25)` | L22 |
| `resultado_nombre_promotor` | `CHAR(50)` | L23 |
| `resultado_importe_original` | `CHAR(25)` | L24 |
| `resultado_camino` | `INTEGER` | L26 |
| `resultado_fechacaptura` | `DATE` | L27 |
| `resultado_fecha_vencimiento` | `DATE` | L28 |
| `resultado_dias_vencimiento` | `INTEGER` | L29 |
| `resultado_estatus` | `INTEGER` | L30 |
| `var_fky_estatus_corp_analisis` | `INTEGER` | L32 |
| `var_cantidad_dias_desde_captura_hasta_hoy` | `INTEGER` | L33 |
| `var_esta_digitalizado` | `INTEGER` | L34 |
| `var_respuesta_estimada` | `INTEGER` | L35 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `acl_cat_tipo_aclaracion` | `bdiaclaracion` | no | SELECT | L45 |
| `acl_aclaracion` | `bdiaclaracion` | no | SELECT | L56 |
| `si_cliente` | `bdinteg` | ⚠️ sí | SELECT | L79 |
| `acl_usuario` | `bdiaclaraciondes` | ⚠️ sí | SELECT | L99 |
| `si_ejecut` | `bdinteg` | ⚠️ sí | SELECT | L104 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L112 | FÓRMULA | `LET resultado_fecha_vencimiento=resultado_fechacaptura+resultado_dias_vencimiento UNITS DAY;` |  |
| L189 | FÓRMULA | `LET resultado_fecha_vencimiento=resultado_fechacaptura+resultado_dias_vencimiento UNITS DAY;` |  |
| L268 | FÓRMULA | `LET resultado_fecha_vencimiento=resultado_fechacaptura+resultado_dias_vencimiento UNITS DAY;` |  |
| L315 | FÓRMULA | `LET var_cantidad_dias_desde_captura_hasta_hoy = today - resultado_fechacaptura;` |  |
| L380 | FÓRMULA | `LET resultado_fecha_vencimiento=resultado_fechacaptura+resultado_dias_vencimiento UNITS DAY;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `reporte` | ENTIDAD | reporte | 🔵 CONVENCIÓN | nombre_sp |
| `?aviso` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `imp` | ENTIDAD | Impago — pago vencido o fallido; confirmado: n_impagos_conse | 🔵 CONVENCIÓN | nombre_sp |
| `suc` | MODIF | sucursal | 🟡 INFERIDO | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?aviso` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_reportediarioacl`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_reportediarioacl.sql` |
| **LOC (1er CREATE)** | 181 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "reporte (diario)" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 1 llamada(s): `sp_reportediarioacl_paralelo` |
| **Evidencia vocab** | CÓDIGO=3 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=0 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_reportediarioacl(
) RETURNING CHAR(7)
```

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `ejecuta` | `lvarchar(500)` | L3 |
| `shell` | `lvarchar(200)` | L4 |
| `num_reportes` | `smallint` | L5 |
| `num_reporte` | `smallint` | L6 |
| `num_reporte_inicial` | `smallint` | L7 |
| `asincronia` | `smallint` | L8 |
| `i` | `smallint` | L9 |
| `codigo_res` | `varchar(7)` | L10 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `systables` | `bdiaclaracion` | no | SELECT | L25 |
| `acl_tipo_accion` | `bdiaclaracion` | no | SELECT | L87 |
| `acl_tipo_accion` | `bdiaclaracion` | no | INSERT | L88 |
| `si_fechas` | `bdinteg` | ⚠️ sí | SELECT | L138 |
| `resultados_sp_reportediarioacl` | `bdiaclaracion` | no | SELECT | L144 |
| `resultados_sp_reportediarioacl` | `bdiaclaracion` | no | INSERT | L174 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_reportediarioacl_paralelo` | `bdiaclaracion` | no | L96 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L101 | FÓRMULA | `let ejecuta = 'echo "[$(date)] Inicio del stored procedure sp_reportediarioacl modo ASINCRONO">>/res` | 🔴 MONEY/aritmética financiera |
| L104 | FÓRMULA | `let ejecuta = 'echo "[$(date)] Inicio del stored procedure sp_reportediarioacl modo SINCRONO">>/resp` | 🔴 MONEY/aritmética financiera |
| L109 | FÓRMULA | `let ejecuta = 'echo "[$(date)] Procesare '\|\|num_reportes\|\|' reportes" >>/resplogifx/repaclaracio` |  |
| L113 | FÓRMULA | `let  shell = '/resplogifx/repaclaraciones/ejecuta_reporte_acl'\|\|num_reporte\|\|'.sh';` |  |
| L129 | FÓRMULA | `let ejecuta = shell \|\| ' &';  --ejecucion asincrona del SP en cada reporte` |  |
| L131 | FÓRMULA | `let ejecuta = shell;          --ejecucion sincrona del SP para las "n" reportes` |  |
| L135 | FÓRMULA | `let ejecuta = 'echo "[$(date)] Se ha iniciado el reporte: ' \|\| num_reporte \|\| '/' \|\| num_repor` |  |
| L140 | FÓRMULA | `let num_reporte = num_reporte + 1;` |  |
| L147 | FÓRMULA | `let ejecuta = 'echo "[$(date)] Estoy esperando que los reportes terminen, llevo '\|\|i\|\|' de '\|\|` |  |
| L171 | FÓRMULA | `let ejecuta = 'echo "[$(date)] Fin del stored procedure sp_reportediarioacl" >>/resplogifx/repaclara` |  |
| L176 | FÓRMULA | `let ejecuta = 'rm -rf /resplogifx/repaclaraciones/ejecuta_reporte_acl*.sh';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `reporte` | ENTIDAD | reporte | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `diario` | MODIF | diario | 🔵 CONVENCIÓN | nombre_sp |
| `acl` | PREFIJO | familia aclaraciones | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |

---

## `sp_reportediarioacl_2day`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_reportediarioacl_2day.sql` |
| **LOC (1er CREATE)** | 181 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "reporte (diario)" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 1 llamada(s): `sp_reportediarioacl_paralelo_2day` |
| **Evidencia vocab** | CÓDIGO=3 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=1 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_reportediarioacl_2day(
) RETURNING CHAR(7)
```

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `ejecuta` | `lvarchar(500)` | L3 |
| `shell` | `lvarchar(200)` | L4 |
| `num_reportes` | `smallint` | L5 |
| `num_reporte` | `smallint` | L6 |
| `num_reporte_inicial` | `smallint` | L7 |
| `asincronia` | `smallint` | L8 |
| `i` | `smallint` | L9 |
| `codigo_res` | `varchar(7)` | L10 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `systables` | `bdiaclaracion` | no | SELECT | L25 |
| `acl_tipo_accion` | `bdiaclaracion` | no | SELECT | L87 |
| `acl_tipo_accion` | `bdiaclaracion` | no | INSERT | L88 |
| `si_fechas` | `bdinteg` | ⚠️ sí | SELECT | L138 |
| `resultados_sp_reportediarioacl` | `bdiaclaracion` | no | SELECT | L144 |
| `resultados_sp_reportediarioacl` | `bdiaclaracion` | no | INSERT | L174 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_reportediarioacl_paralelo_2day` | `bdiaclaracion` | no | L96 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L101 | FÓRMULA | `let ejecuta = 'echo "[$(date)] Inicio del stored procedure sp_reportediarioacl modo ASINCRONO">>/res` | 🔴 MONEY/aritmética financiera |
| L104 | FÓRMULA | `let ejecuta = 'echo "[$(date)] Inicio del stored procedure sp_reportediarioacl modo SINCRONO">>/resp` | 🔴 MONEY/aritmética financiera |
| L109 | FÓRMULA | `let ejecuta = 'echo "[$(date)] Procesare '\|\|num_reportes\|\|' reportes" >>/resplogifx/repaclaracio` |  |
| L113 | FÓRMULA | `let  shell = '/resplogifx/repaclaraciones/ejecuta_reporte_acl'\|\|num_reporte\|\|'.sh';` |  |
| L129 | FÓRMULA | `let ejecuta = shell \|\| ' &';  --ejecucion asincrona del SP en cada reporte` |  |
| L131 | FÓRMULA | `let ejecuta = shell;          --ejecucion sincrona del SP para las "n" reportes` |  |
| L135 | FÓRMULA | `let ejecuta = 'echo "[$(date)] Se ha iniciado el reporte: ' \|\| num_reporte \|\| '/' \|\| num_repor` |  |
| L140 | FÓRMULA | `let num_reporte = num_reporte + 1;` |  |
| L147 | FÓRMULA | `let ejecuta = 'echo "[$(date)] Estoy esperando que los reportes terminen, llevo '\|\|i\|\|' de '\|\|` |  |
| L171 | FÓRMULA | `let ejecuta = 'echo "[$(date)] Fin del stored procedure sp_reportediarioacl" >>/resplogifx/repaclara` |  |
| L176 | FÓRMULA | `let ejecuta = 'rm -rf /resplogifx/repaclaraciones/ejecuta_reporte_acl*.sh';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `reporte` | ENTIDAD | reporte | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `diario` | MODIF | diario | 🔵 CONVENCIÓN | nombre_sp |
| `acl` | PREFIJO | familia aclaraciones | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `?_2day` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_2day` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_reportediarioacl_paralelo`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_reportediarioacl_paralelo.sql` |
| **LOC (1er CREATE)** | 712 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 1 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "reporte (diario)" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 28 tabla(s) con operaciones: SELECT, DELETE, INSERT, UPDATE |
| **Evidencia vocab** | CÓDIGO=4 · CONVENCIÓN=0 · INFERIDO=0 · SINTÉTICO=1 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_reportediarioacl_paralelo(
  num_reporte_inicial          SMALLINT
  num_reporte_final            SMALLINT
) RETURNING char(7)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `num_reporte_inicial` | `SMALLINT` | `reporte`=reporte | ✅ CÓDIGO |
| `num_reporte_final` | `SMALLINT` | `reporte`=reporte | ✅ CÓDIGO |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vsql` | `char(3000)` | L4 |
| `vcodret` | `char(7)` | L5 |
| `vsqlerr` | `integer` | L6 |
| `p_folio` | `varchar(11)` | L7 |
| `p_fechahoy` | `date` | L8 |
| `p_fecha_sistema` | `date` | L9 |
| `p_fecha_predictamen` | `date` | L10 |
| `p_entrada_bitacora` | `integer` | L11 |
| `p_fecha_captura` | `date` | L12 |
| `p_folio_suc` | `varchar(30)` | L13 |
| `p_tarjeta` | `varchar(16)` | L14 |
| `p_interc` | `char(1)` | L15 |
| `p_modo` | `char(4)` | L16 |
| `v_estatus_analisis` | `integer` | L17 |
| `p_fecha_hoy_inicio` | `DATETIME YEAR TO FRACTION(5)` | L18 |
| `p_fecha_hoy_fin` | `DATETIME YEAR TO FRACTION(5)` | L19 |
| `iContador` | `INTEGER` | L22 |
| `pen_vFolio_cs` | `VARCHAR(11)` | L23 |
| `pen_dFechaCap` | `DATE` | L24 |
| `pen_dFechaDic` | `DATE` | L25 |
| `pen_mImporteOri` | `MONEY` | L26 |
| `pen_vNumEmp` | `VARCHAR(8)` | L27 |
| `pen_cpModo` | `CHAR(4)` | L28 |
| `pen_vNombre` | `VARCHAR(45)` | L29 |
| `pen_v_estatus_aclara` | `VARCHAR(255)` | L30 |
| *…69 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `resultados_sp_reportediarioacl` | `bdiaclaracion` | no | INSERT | L175 |
| `reportes_acl` | `bdiaclaracion` | no | INSERT | L190 |
| `si_fechas` | `bdinteg` | ⚠️ sí | SELECT | L248 |
| `reportes_acl` | `bdiaclaracion` | no | SELECT | L265 |
| `acl_estatus_corporativo` | `bdiaclaracion` | no | SELECT | L277 |
| `acl_resolucion` | `bdiaclaracion` | no | SELECT | L284 |
| `acl_aclaracion` | `bdiaclaracion` | no | SELECT | L316 |
| `acl_movimiento` | `bdiaclaracion` | no | SELECT | L374 |
| `acl_usuario` | `bdiaclaracion` | no | SELECT | L379 |
| `acl_estatus_aclaracion` | `bdiaclaracion` | no | SELECT | L385 |
| `acl_tipo_evento` | `bdiaclaracion` | no | SELECT | L399 |
| `si_cliente` | `bdinteg` | ⚠️ sí | SELECT | L405 |
| `acl_producto` | `bdiaclaracion` | no | SELECT | L410 |
| `acl_tipo_catalogo_transaccion` | `bdiaclaracion` | no | SELECT | L415 |
| `acl_solicitud_e_global` | `bdiaclaracion` | no | SELECT | L421 |
| `acl_cat_tipo_aclaracion` | `bdiaclaracion` | no | SELECT | L431 |
| `si_telefonos_actual` | `bdinteg` | ⚠️ sí | SELECT | L437 |
| `si_correos` | `bdinteg` | ⚠️ sí | SELECT | L443 |
| `acl_aclaracion_estatus_proceso_analisis` | `bdiaclaracion` | no | SELECT | L449 |
| `acl_reporte_diario` | `bdiaclaracion` | no | INSERT | L469 |
| `acl_reporte_diario` | `bdiaclaracion` | no | SELECT | L492 |
| `acl_reporte_diario` | `bdiaclaracion` | no | UPDATE | L497 |
| `acl_entrada_bitacora` | `bdiaclaracion` | no | SELECT | L506 |
| `movimiento` | `intercard` | ⚠️ sí | SELECT | L529 |
| `movimientohistorico` | `intercard` | ⚠️ sí | SELECT | L555 |
| `bitacoracambiostarjeta` | `intercard` | ⚠️ sí | SELECT | L576 |
| `tarjeta` | `intercard` | ⚠️ sí | SELECT | L586 |
| `acl_reporte_diario` | `bdiaclaracion` | no | DELETE | L671 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L258 | FÓRMULA | `LET p_fechahoy = p_fecha_sistema -1;` |  |
| L268 | FÓRMULA | `let num_reporte_inicial = num_reporte_inicial - 1;` |  |
| L454 | FÓRMULA | `LET pen_v_estatus_general = (pen_v_estatus_general\|\|'-'\|\|pen_v_estatus_complementario);` |  |
| L457 | FÓRMULA | `LET pen_v_estatus_ana = NVL(pen_v_estatus_ana, ''); --por razones inexplicables` |  |
| L480 | FÓRMULA | `LET iContador = iContador + 1;` |  |
| L496 | VALIDACIÓN_NULL | `IF ((select procede from acl_reporte_diario where reporte = v_reporte and folio_csuac=p_folio) is nu` |  |
| L547 | VALIDACIÓN_NULL | `IF (pen_cod_eci = '' or pen_cod_eci is null) AND (pen_medio = '' or pen_medio is null) AND (pen_idte` |  |
| L609 | VALIDACIÓN_NULL | `IF (p_modo='' or p_modo is null ) THEN` |  |
| L619 | FÓRMULA | `LET iContador = iContador + 1;` |  |
| L626 | FÓRMULA | `let vsql = 'echo "'\|\|trim(v_encabezado)\|\|'">/resplogifx/repaclaraciones/ACL_'\|\|trim(v_nombre)\` |  |
| L636 | FÓRMULA | `let vsql = "sed 's/\|$//g' reporte_acl_"\|\|v_reporte\|\|".unl >>/resplogifx/repaclaraciones/ACL_"\|` |  |
| L643 | FÓRMULA | `let vsql = ' echo "'\|\|trim(v_encabezado_extra)\|\|'">/resplogifx/repaclaraciones/ACL_'\|\|trim(v_n` |  |
| L659 | FÓRMULA | `let vsql = "sed 's/\|$//g' reporte_acl_"\|\|v_reporte\|\|".unl >>/resplogifx/repaclaraciones/ACL_"\|` |  |
| L674 | FÓRMULA | `let vsql ='rm -rf reporte_acl*'; system vsql;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `reporte` | ENTIDAD | reporte | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `diario` | MODIF | diario | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `acl` | PREFIJO | familia aclaraciones | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `?_paralelo` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_paralelo` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_reportediarioacl_paralelo_2day`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_reportediarioacl_paralelo_2day.sql` |
| **LOC (1er CREATE)** | 679 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "reporte (diario)" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 28 tabla(s) con operaciones: SELECT, DELETE, INSERT, UPDATE |
| **Evidencia vocab** | CÓDIGO=4 · CONVENCIÓN=0 · INFERIDO=0 · SINTÉTICO=1 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_reportediarioacl_paralelo_2day(
  num_reporte_inicial          SMALLINT
  num_reporte_final            SMALLINT
) RETURNING char(7)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `num_reporte_inicial` | `SMALLINT` | `reporte`=reporte | ✅ CÓDIGO |
| `num_reporte_final` | `SMALLINT` | `reporte`=reporte | ✅ CÓDIGO |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vsql` | `char(3000)` | L4 |
| `vcodret` | `char(7)` | L5 |
| `vsqlerr` | `integer` | L6 |
| `p_folio` | `varchar(11)` | L7 |
| `p_fechahoy` | `date` | L8 |
| `p_fecha_sistema` | `date` | L9 |
| `p_fecha_predictamen` | `date` | L10 |
| `p_entrada_bitacora` | `integer` | L11 |
| `p_fecha_captura` | `date` | L12 |
| `p_folio_suc` | `varchar(30)` | L13 |
| `p_tarjeta` | `varchar(16)` | L14 |
| `p_interc` | `char(1)` | L15 |
| `p_modo` | `char(4)` | L16 |
| `v_estatus_analisis` | `integer` | L17 |
| `p_fecha_hoy_inicio` | `DATETIME YEAR TO FRACTION(5)` | L18 |
| `p_fecha_hoy_fin` | `DATETIME YEAR TO FRACTION(5)` | L19 |
| `iContador` | `INTEGER` | L22 |
| `pen_vFolio_cs` | `VARCHAR(11)` | L23 |
| `pen_dFechaCap` | `DATE` | L24 |
| `pen_dFechaDic` | `DATE` | L25 |
| `pen_mImporteOri` | `MONEY` | L26 |
| `pen_vNumEmp` | `VARCHAR(8)` | L27 |
| `pen_cpModo` | `CHAR(4)` | L28 |
| `pen_vNombre` | `VARCHAR(45)` | L29 |
| `pen_v_estatus_aclara` | `VARCHAR(255)` | L30 |
| *…69 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `resultados_sp_reportediarioacl` | `bdiaclaracion` | no | INSERT | L175 |
| `reportes_acl` | `bdiaclaracion` | no | INSERT | L190 |
| `si_fechas` | `bdinteg` | ⚠️ sí | SELECT | L248 |
| `reportes_acl` | `bdiaclaracion` | no | SELECT | L265 |
| `acl_estatus_corporativo` | `bdiaclaracion` | no | SELECT | L277 |
| `acl_resolucion` | `bdiaclaracion` | no | SELECT | L284 |
| `acl_aclaracion` | `bdiaclaracion` | no | SELECT | L316 |
| `acl_movimiento` | `bdiaclaracion` | no | SELECT | L374 |
| `acl_usuario` | `bdiaclaracion` | no | SELECT | L379 |
| `acl_estatus_aclaracion` | `bdiaclaracion` | no | SELECT | L385 |
| `acl_tipo_evento` | `bdiaclaracion` | no | SELECT | L399 |
| `si_cliente` | `bdinteg` | ⚠️ sí | SELECT | L405 |
| `acl_producto` | `bdiaclaracion` | no | SELECT | L410 |
| `acl_tipo_catalogo_transaccion` | `bdiaclaracion` | no | SELECT | L415 |
| `acl_solicitud_e_global` | `bdiaclaracion` | no | SELECT | L421 |
| `acl_cat_tipo_aclaracion` | `bdiaclaracion` | no | SELECT | L431 |
| `si_telefonos_actual` | `bdinteg` | ⚠️ sí | SELECT | L437 |
| `si_correos` | `bdinteg` | ⚠️ sí | SELECT | L443 |
| `acl_aclaracion_estatus_proceso_analisis` | `bdiaclaracion` | no | SELECT | L449 |
| `acl_reporte_diario` | `bdiaclaracion` | no | INSERT | L469 |
| `acl_reporte_diario` | `bdiaclaracion` | no | SELECT | L492 |
| `acl_reporte_diario` | `bdiaclaracion` | no | UPDATE | L497 |
| `acl_entrada_bitacora` | `bdiaclaracion` | no | SELECT | L506 |
| `movimiento` | `intercard` | ⚠️ sí | SELECT | L529 |
| `movimientohistorico` | `intercard` | ⚠️ sí | SELECT | L555 |
| `bitacoracambiostarjeta` | `intercard` | ⚠️ sí | SELECT | L576 |
| `tarjeta` | `intercard` | ⚠️ sí | SELECT | L586 |
| `acl_reporte_diario` | `bdiaclaracion` | no | DELETE | L671 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L258 | FÓRMULA | `LET p_fechahoy = p_fecha_sistema -3;` |  |
| L268 | FÓRMULA | `let num_reporte_inicial = num_reporte_inicial - 1;` |  |
| L454 | FÓRMULA | `LET pen_v_estatus_general = (pen_v_estatus_general\|\|'-'\|\|pen_v_estatus_complementario);` |  |
| L457 | FÓRMULA | `LET pen_v_estatus_ana = NVL(pen_v_estatus_ana, ''); --por razones inexplicables` |  |
| L480 | FÓRMULA | `LET iContador = iContador + 1;` |  |
| L496 | VALIDACIÓN_NULL | `IF ((select procede from acl_reporte_diario where reporte = v_reporte and folio_csuac=p_folio) is nu` |  |
| L547 | VALIDACIÓN_NULL | `IF (pen_cod_eci = '' or pen_cod_eci is null) AND (pen_medio = '' or pen_medio is null) AND (pen_idte` |  |
| L609 | VALIDACIÓN_NULL | `IF (p_modo='' or p_modo is null ) THEN` |  |
| L619 | FÓRMULA | `LET iContador = iContador + 1;` |  |
| L626 | FÓRMULA | `let vsql = 'echo "'\|\|trim(v_encabezado)\|\|'">/resplogifx/repaclaraciones/ACL_'\|\|trim(v_nombre)\` |  |
| L636 | FÓRMULA | `let vsql = "sed 's/\|$//g' reporte_acl_"\|\|v_reporte\|\|".unl >>/resplogifx/repaclaraciones/ACL_"\|` |  |
| L643 | FÓRMULA | `let vsql = ' echo "'\|\|trim(v_encabezado_extra)\|\|'">/resplogifx/repaclaraciones/ACL_'\|\|trim(v_n` |  |
| L659 | FÓRMULA | `let vsql = "sed 's/\|$//g' reporte_acl_"\|\|v_reporte\|\|".unl >>/resplogifx/repaclaraciones/ACL_"\|` |  |
| L674 | FÓRMULA | `let vsql ='rm -rf reporte_acl*'; system vsql;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `reporte` | ENTIDAD | reporte | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `diario` | MODIF | diario | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `acl` | PREFIJO | familia aclaraciones | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `?_paralelo_2day` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_paralelo_2day` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_reportedictaminadaxproductografica`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_reportedictaminadaxproductografica.sql` |
| **LOC (1er CREATE)** | 160 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "reporte y producto" `[partial]` |
| **Propósito verificado** | ❓ NO_VERIFICABLE — Propósito inferido; sin evidencia DML para verificar |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=3 · INFERIDO=1 · SINTÉTICO=2 / 7 términos |

### Firma

```sql
CREATE PROCEDURE sp_reportedictaminadaxproductografica(
  procedente                   INTEGER
  fechaIni                     DATE
  fechaFin                     DATE
  ids_productos                lvarchar
  ids_tipos_evento             lvarchar
) RETURNING lvarchar AS producto, INTEGER AS encontrados
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `procedente` | `INTEGER` | — | — |
| `fechaIni` | `DATE` | — | — |
| `fechaFin` | `DATE` | — | — |
| `ids_productos` | `lvarchar` | `producto`=producto | ✅ CÓDIGO |
| `ids_tipos_evento` | `lvarchar` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `res_areas` | `lvarchar` | L5 |
| `res_encontrados` | `INTEGER` | L6 |
| `productos` | `LIST(INTEGER NOT NULL)` | L7 |
| `tipos_evento` | `LIST(INTEGER NOT NULL)` | L8 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `reporte` | ENTIDAD | reporte | 🔵 CONVENCIÓN | nombre_sp |
| `dicta` | PREFIJO | dictamen (aclaraciones/crédito) | 🟡 INFERIDO | nombre_sp |
| `?minada` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `x` | MODIF | por (criterio) | 🔵 CONVENCIÓN | nombre_sp |
| `producto` | ENTIDAD | producto | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?grafica` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?minada`, `?grafica` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_reportefoliosacl`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_reportefoliosacl.sql` |
| **LOC (1er CREATE)** | 216 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "reporte, folio y Servicios de Atención al Cliente — subsistema de atención en sucursal" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 2 tabla(s) con operaciones: SELECT, INSERT |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=1 · INFERIDO=1 · SINTÉTICO=1 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_reportefoliosacl(
  pfolios                      varchar(250)
) RETURNING varchar(20) as Folio_csuac ,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pfolios` | `varchar(250)` | `folio`=folio | ✅ CÓDIGO |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `iSqlErr` | `INTEGER` | L37 |
| `v_sCodRet` | `CHAR(5)` | L38 |
| `vfolio` | `varchar(20)` | L39 |
| `vproducto` | `varchar(4)` | L40 |
| `vcliente` | `varchar(9)` | L41 |
| `vnumero_cuenta` | `varchar(20)` | L42 |
| `vnumero_tarjeta` | `varchar(17)` | L43 |
| `vimporte_original` | `money(18,2)` | L44 |
| `vref_comercio` | `varchar(70)` | L45 |
| `vfecha_de_cargo` | `date` | L46 |
| `vmes_trx` | `varchar(10)` | L47 |
| `vmes_afectacion` | `varchar(10)` | L48 |
| `vcodgironeg` | `varchar(4)` | L49 |
| `vidretailer` | `varchar(19)` | L50 |
| `vciudad_comercio` | `varchar(40)` | L51 |
| `vmetodocaptura` | `varchar(2)` | L52 |
| `vdescstatustarjeta` | `varchar(30)` | L53 |
| `vfecha_afectacion` | `DATETIME YEAR TO FRACTION(5)` | L54 |
| `vNaturaleza` | `varchar(3)` | L55 |
| `vtipo_fraude` | `varchar(10)` | L56 |
| `vnombre_cliente` | `varchar(104)` | L57 |
| `vnombreciudad` | `varchar(30)` | L58 |
| `vinicialestado` | `varchar(4)` | L59 |
| `vanio_trx` | `varchar(4)` | L60 |
| `vreferencia23` | `varchar(24)` | L61 |
| *…10 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tmp_folios_acl` | `bdiaclaracion` | no | INSERT | L121 |
| `acl_movimiento` | `bdiaclaracion` | no | SELECT | L128 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L110 | FÓRMULA | `LET lnuPosComa = CHARINDEX(',',lstCadena ); -- Buscamos el caracter separador` |  |
| L116 | FÓRMULA | `LET lstDato = SUBSTR( lstCadena , 1  , lnuPosComa-1);` |  |
| L117 | FÓRMULA | `LET lstCadena = SUBSTR( lstCadena , lnuPosComa + 1 , LEN(lstCadena));` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `reporte` | ENTIDAD | reporte | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `folio` | ENTIDAD | folio | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `sac` | ENTIDAD | Servicios de Atención al Cliente — subsistema de atención en | 🟡 INFERIDO | nombre_sp |
| `?l` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?l` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_reportefoliosacl_pba`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_reportefoliosacl_pba.sql` |
| **LOC (1er CREATE)** | 202 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "reporte, folio y Servicios de Atención al Cliente — subsistema de atención en sucursal (PBA — sufijo de SPs para Pruebas; confirmado por SME)" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `confirma` → `SELECT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=2 · INFERIDO=1 · SINTÉTICO=1 / 6 términos |

### Firma

```sql
CREATE PROCEDURE sp_reportefoliosacl_pba(
  pfolios                      varchar(250)
) RETURNING varchar(20) as Folio_csuac ,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pfolios` | `varchar(250)` | `folio`=folio | ✅ CÓDIGO |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `iSqlErr` | `INTEGER` | L36 |
| `v_sCodRet` | `CHAR(5)` | L37 |
| `vfolio` | `varchar(20)` | L38 |
| `vproducto` | `varchar(4)` | L39 |
| `vcliente` | `varchar(9)` | L40 |
| `vnumero_cuenta` | `varchar(20)` | L41 |
| `vnumero_tarjeta` | `varchar(16)` | L42 |
| `vimporte_original` | `money(18,2)` | L43 |
| `vref_comercio` | `varchar(70)` | L44 |
| `vfecha_de_cargo` | `date` | L45 |
| `vmes_trx` | `varchar(10)` | L46 |
| `vmes_afectacion` | `varchar(10)` | L47 |
| `vcodgironeg` | `varchar(4)` | L48 |
| `vidretailer` | `varchar(19)` | L49 |
| `vciudad_comercio` | `varchar(40)` | L50 |
| `vmetodocaptura` | `varchar(2)` | L51 |
| `vdescstatustarjeta` | `varchar(30)` | L52 |
| `vfecha_afectacion` | `date` | L53 |
| `vNaturaleza` | `varchar(3)` | L54 |
| `vtipo_fraude` | `varchar(10)` | L55 |
| `vnombre_cliente` | `varchar(104)` | L56 |
| `vnombreciudad` | `varchar(30)` | L57 |
| `vinicialestado` | `varchar(4)` | L58 |
| `vanio_trx` | `varchar(4)` | L59 |
| `vreferencia23` | `varchar(23)` | L60 |
| *…10 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tmp_folios_acl` | `bdiaclaracion` | no | INSERT | L120 |
| `acl_movimiento` | `bdiaclaracion` | no | SELECT | L127 |
| `movimiento` | `intercard` | ⚠️ sí | SELECT | L130 |
| `tmp_movimientos_acl` | `bdiaclaracion` | no | SELECT | L131 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L109 | FÓRMULA | `LET lnuPosComa = CHARINDEX(',',lstCadena ); -- Buscamos el caracter separador` |  |
| L115 | FÓRMULA | `LET lstDato = SUBSTR( lstCadena , 1  , lnuPosComa-1);` |  |
| L116 | FÓRMULA | `LET lstCadena = SUBSTR( lstCadena , lnuPosComa + 1 , LEN(lstCadena));` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `reporte` | ENTIDAD | reporte | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `folio` | ENTIDAD | folio | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `sac` | ENTIDAD | Servicios de Atención al Cliente — subsistema de atención en | 🟡 INFERIDO | nombre_sp |
| `?l_` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `pba` | MODIF | PBA — sufijo de SPs para Pruebas; confirmado por SME (Guerra | 🔵 CONVENCIÓN | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?l_` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_reportefoliosacl_pba1`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_reportefoliosacl_pba1.sql` |
| **LOC (1er CREATE)** | 202 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "reporte, folio y Servicios de Atención al Cliente — subsistema de atención en sucursal (PBA — sufijo de SPs para Pruebas; confirmado por SME)" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `confirma` → `SELECT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=2 · INFERIDO=1 · SINTÉTICO=2 / 7 términos |

### Firma

```sql
CREATE PROCEDURE sp_reportefoliosacl_pba1(
  pfolios                      varchar(250)
) RETURNING varchar(20) as Folio_csuac ,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pfolios` | `varchar(250)` | `folio`=folio | ✅ CÓDIGO |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `iSqlErr` | `INTEGER` | L36 |
| `v_sCodRet` | `CHAR(5)` | L37 |
| `vfolio` | `varchar(20)` | L38 |
| `vproducto` | `varchar(4)` | L39 |
| `vcliente` | `varchar(9)` | L40 |
| `vnumero_cuenta` | `varchar(20)` | L41 |
| `vnumero_tarjeta` | `varchar(16)` | L42 |
| `vimporte_original` | `money(18,2)` | L43 |
| `vref_comercio` | `varchar(70)` | L44 |
| `vfecha_de_cargo` | `date` | L45 |
| `vmes_trx` | `varchar(10)` | L46 |
| `vmes_afectacion` | `varchar(10)` | L47 |
| `vcodgironeg` | `varchar(4)` | L48 |
| `vidretailer` | `varchar(19)` | L49 |
| `vciudad_comercio` | `varchar(40)` | L50 |
| `vmetodocaptura` | `varchar(2)` | L51 |
| `vdescstatustarjeta` | `varchar(30)` | L52 |
| `vfecha_afectacion` | `date` | L53 |
| `vNaturaleza` | `varchar(3)` | L54 |
| `vtipo_fraude` | `varchar(10)` | L55 |
| `vnombre_cliente` | `varchar(104)` | L56 |
| `vnombreciudad` | `varchar(30)` | L57 |
| `vinicialestado` | `varchar(4)` | L58 |
| `vanio_trx` | `varchar(4)` | L59 |
| `vreferencia23` | `varchar(23)` | L60 |
| *…10 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tmp_folios_acl` | `bdiaclaracion` | no | INSERT | L120 |
| `acl_movimiento` | `bdiaclaracion` | no | SELECT | L127 |
| `movimiento` | `intercard` | ⚠️ sí | SELECT | L130 |
| `tmp_movimientos_acl` | `bdiaclaracion` | no | SELECT | L131 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L109 | FÓRMULA | `LET lnuPosComa = CHARINDEX(',',lstCadena ); -- Buscamos el caracter separador` |  |
| L115 | FÓRMULA | `LET lstDato = SUBSTR( lstCadena , 1  , lnuPosComa-1);` |  |
| L116 | FÓRMULA | `LET lstCadena = SUBSTR( lstCadena , lnuPosComa + 1 , LEN(lstCadena));` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `reporte` | ENTIDAD | reporte | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `folio` | ENTIDAD | folio | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `sac` | ENTIDAD | Servicios de Atención al Cliente — subsistema de atención en | 🟡 INFERIDO | nombre_sp |
| `?l_` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `pba` | MODIF | PBA — sufijo de SPs para Pruebas; confirmado por SME (Guerra | 🔵 CONVENCIÓN | nombre_sp |
| `?1` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?l_`, `?1` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_reportefoliosacl_pba_new`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_reportefoliosacl_pba_new.sql` |
| **LOC (1er CREATE)** | 1496 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "reporte, folio y Servicios de Atención al Cliente — subsistema de atención en sucursal (PBA — sufijo de SPs para Pruebas; confirmado por SME)" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `confirma` → `SELECT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=2 · INFERIDO=1 · SINTÉTICO=2 / 7 términos |

### Firma

```sql
CREATE PROCEDURE sp_reportefoliosacl_pba_new(
  pfolios                      varchar(250)
) RETURNING varchar(20) as Folio_csuac ,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pfolios` | `varchar(250)` | `folio`=folio | ✅ CÓDIGO |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `iSqlErr` | `INTEGER` | L36 |
| `v_sCodRet` | `CHAR(5)` | L37 |
| `vfolio` | `varchar(20)` | L38 |
| `vproducto` | `varchar(4)` | L39 |
| `vcliente` | `varchar(9)` | L40 |
| `vnumero_cuenta` | `varchar(20)` | L41 |
| `vnumero_tarjeta` | `varchar(16)` | L42 |
| `vimporte_original` | `money(18,2)` | L43 |
| `vref_comercio` | `varchar(70)` | L44 |
| `vfecha_de_cargo` | `date` | L45 |
| `vmes_trx` | `varchar(10)` | L46 |
| `vmes_afectacion` | `varchar(10)` | L47 |
| `vcodgironeg` | `varchar(4)` | L48 |
| `vidretailer` | `varchar(19)` | L49 |
| `vciudad_comercio` | `varchar(40)` | L50 |
| `vmetodocaptura` | `varchar(2)` | L51 |
| `vdescstatustarjeta` | `varchar(30)` | L52 |
| `vfecha_afectacion` | `date` | L53 |
| `vNaturaleza` | `varchar(3)` | L54 |
| `vtipo_fraude` | `varchar(10)` | L55 |
| `vnombre_cliente` | `varchar(104)` | L56 |
| `vnombreciudad` | `varchar(30)` | L57 |
| `vinicialestado` | `varchar(4)` | L58 |
| `vanio_trx` | `varchar(4)` | L59 |
| `vreferencia23` | `varchar(23)` | L60 |
| *…10 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tmp_folios_acl` | `bdiaclaracion` | no | INSERT | L120 |
| `acl_movimiento` | `bdiaclaracion` | no | SELECT | L127 |
| `public` | `bdiaclaracion` | no | SELECT | L712 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L109 | FÓRMULA | `LET lnuPosComa = CHARINDEX(',',lstCadena ); -- Buscamos el caracter separador` |  |
| L115 | FÓRMULA | `LET lstDato = SUBSTR( lstCadena , 1  , lnuPosComa-1);` |  |
| L116 | FÓRMULA | `LET lstCadena = SUBSTR( lstCadena , lnuPosComa + 1 , LEN(lstCadena));` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `reporte` | ENTIDAD | reporte | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `folio` | ENTIDAD | folio | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `sac` | ENTIDAD | Servicios de Atención al Cliente — subsistema de atención en | 🟡 INFERIDO | nombre_sp |
| `?l_` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `pba` | MODIF | PBA — sufijo de SPs para Pruebas; confirmado por SME (Guerra | 🔵 CONVENCIÓN | nombre_sp |
| `?_new` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?l_`, `?_new` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_reportefoliosacl_pbabis`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_reportefoliosacl_pbabis.sql` |
| **LOC (1er CREATE)** | 202 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "reporte, folio y Servicios de Atención al Cliente — subsistema de atención en sucursal (PBA — sufijo de SPs para Pruebas; confirmado por SME)" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `confirma` → `SELECT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=2 · INFERIDO=1 · SINTÉTICO=2 / 7 términos |

### Firma

```sql
CREATE PROCEDURE sp_reportefoliosacl_pbabis(
  pfolios                      varchar(250)
) RETURNING varchar(20) as Folio_csuac ,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pfolios` | `varchar(250)` | `folio`=folio | ✅ CÓDIGO |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `iSqlErr` | `INTEGER` | L36 |
| `v_sCodRet` | `CHAR(5)` | L37 |
| `vfolio` | `varchar(20)` | L38 |
| `vproducto` | `varchar(4)` | L39 |
| `vcliente` | `varchar(9)` | L40 |
| `vnumero_cuenta` | `varchar(20)` | L41 |
| `vnumero_tarjeta` | `varchar(16)` | L42 |
| `vimporte_original` | `money(18,2)` | L43 |
| `vref_comercio` | `varchar(70)` | L44 |
| `vfecha_de_cargo` | `date` | L45 |
| `vmes_trx` | `varchar(10)` | L46 |
| `vmes_afectacion` | `varchar(10)` | L47 |
| `vcodgironeg` | `varchar(4)` | L48 |
| `vidretailer` | `varchar(19)` | L49 |
| `vciudad_comercio` | `varchar(40)` | L50 |
| `vmetodocaptura` | `varchar(2)` | L51 |
| `vdescstatustarjeta` | `varchar(30)` | L52 |
| `vfecha_afectacion` | `date` | L53 |
| `vNaturaleza` | `varchar(3)` | L54 |
| `vtipo_fraude` | `varchar(10)` | L55 |
| `vnombre_cliente` | `varchar(104)` | L56 |
| `vnombreciudad` | `varchar(30)` | L57 |
| `vinicialestado` | `varchar(4)` | L58 |
| `vanio_trx` | `varchar(4)` | L59 |
| `vreferencia23` | `varchar(23)` | L60 |
| *…10 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tmp_folios_acl` | `bdiaclaracion` | no | INSERT | L120 |
| `acl_movimiento` | `bdiaclaracion` | no | SELECT | L127 |
| `movimiento` | `intercard` | ⚠️ sí | SELECT | L130 |
| `tmp_movimientos_acl` | `bdiaclaracion` | no | SELECT | L131 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L109 | FÓRMULA | `LET lnuPosComa = CHARINDEX(',',lstCadena ); -- Buscamos el caracter separador` |  |
| L115 | FÓRMULA | `LET lstDato = SUBSTR( lstCadena , 1  , lnuPosComa-1);` |  |
| L116 | FÓRMULA | `LET lstCadena = SUBSTR( lstCadena , lnuPosComa + 1 , LEN(lstCadena));` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `reporte` | ENTIDAD | reporte | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `folio` | ENTIDAD | folio | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `sac` | ENTIDAD | Servicios de Atención al Cliente — subsistema de atención en | 🟡 INFERIDO | nombre_sp |
| `?l_` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `pba` | MODIF | PBA — sufijo de SPs para Pruebas; confirmado por SME (Guerra | 🔵 CONVENCIÓN | nombre_sp |
| `?bis` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?l_`, `?bis` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_reportehoyayer`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_reportehoyayer.sql` |
| **LOC (1er CREATE)** | 85 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "reporte (de hoy)" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 1 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=1 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_reportehoyayer(
  fechaIni                     date
  fechaFin                     date
) RETURNING CHAR(50) AS tipo_evento, INTEGER AS nuevas, INTEGER AS proceso, INTEGER AS resueltas
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `fechaIni` | `date` | — | — |
| `fechaFin` | `date` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `res_tipo_evento` | `CHAR(50)` | L5 |
| `res_nuevas` | `INTEGER` | L6 |
| `res_proceso` | `INTEGER` | L7 |
| `res_resueltas` | `INTEGER` | L8 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `acl_aclaracion` | `bdiaclaracion` | no | SELECT | L19 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `reporte` | ENTIDAD | reporte | 🔵 CONVENCIÓN | nombre_sp |
| `hoy` | MODIF | de hoy / fecha actual | 🔵 CONVENCIÓN | nombre_sp |
| `?ayer` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?ayer` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_reportehoyayerremanente`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_reportehoyayerremanente.sql` |
| **LOC (1er CREATE)** | 43 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "reporte (de hoy, remanente)" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 1 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=1 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_reportehoyayerremanente(
  fechaIni                     date
  fechaFin                     date
) RETURNING INTEGER AS remanente
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `fechaIni` | `date` | — | — |
| `fechaFin` | `date` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `res_remanente` | `INTEGER` | L5 |
| `var_nuevas` | `INTEGER` | L6 |
| `var_anteriores` | `INTEGER` | L7 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `acl_aclaracion` | `bdiaclaracion` | no | SELECT | L17 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `reporte` | ENTIDAD | reporte | 🔵 CONVENCIÓN | nombre_sp |
| `hoy` | MODIF | de hoy / fecha actual | 🔵 CONVENCIÓN | nombre_sp |
| `?ayer` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `remanente` | MODIF | remanente | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?ayer` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_reportesingredicta`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_reportesingredicta.sql` |
| **LOC (1er CREATE)** | 58 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "reportes" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 4 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=2 · INFERIDO=1 · SINTÉTICO=1 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_reportesingredicta(
  fechaIni                     DATE
  fechaFin                     DATE
) RETURNING CHAR(50) AS titulo, INTEGER AS total, FLOAT AS monto
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `fechaIni` | `DATE` | — | — |
| `fechaFin` | `DATE` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `res_titulo` | `CHAR(50)` | L5 |
| `res_total` | `INTEGER` | L6 |
| `res_monto` | `FLOAT` | L7 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `acl_movimiento` | `bdiaclaracion` | no | SELECT | L18 |
| `acl_aclaracion` | `bdiaclaracion` | no | SELECT | L28 |
| `temp_ingr` | `bdiaclaracion` | no | SELECT | L37 |
| `temp_union` | `bdiaclaracion` | no | SELECT | L47 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `reportes` | ENTIDAD | reportes | 🔵 CONVENCIÓN | nombre_sp |
| `?ingre` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `dicta` | PREFIJO | dictamen (aclaraciones/crédito) | 🟡 INFERIDO | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?ingre` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_reportetopaclaraciones`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_reportetopaclaraciones.sql` |
| **LOC (1er CREATE)** | 50 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 1 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "reporte y aclaraciones" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 1 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=1 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_reportetopaclaraciones(
  desde                        date
  hasta                        date
  top                          integer
  estatus                      char(15)
) RETURNING lvarchar as numero, lvarchar as nombre, integer as total
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `desde` | `date` | — | — |
| `hasta` | `date` | — | — |
| `top` | `integer` | — | — |
| `estatus` | `char(15)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `res_total` | `integer` | L4 |
| `res_nombre` | `lvarchar` | L5 |
| `res_numero` | `lvarchar` | L6 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `acl_aclaracion` | `bdiaclaracion` | no | SELECT | L17 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `reporte` | ENTIDAD | reporte | 🔵 CONVENCIÓN | nombre_sp |
| `?top` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `aclaraciones` | ENTIDAD | aclaraciones (proceso de disputas/reclamaciones de cliente) | 🔵 CONVENCIÓN | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?top` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_reportetopaclarareci`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_reportetopaclarareci.sql` |
| **LOC (1er CREATE)** | 41 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "recepción reporte" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 3 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=3 / 7 términos |

### Firma

```sql
CREATE PROCEDURE sp_reportetopaclarareci(
  fechaIni                     DATE
  fechaFin                     DATE
) RETURNING CHAR(50) AS fecha, INTEGER AS total, FLOAT AS promedio
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `fechaIni` | `DATE` | — | — |
| `fechaFin` | `DATE` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `res_fecha` | `CHAR(50)` | L5 |
| `res_total` | `INTEGER` | L6 |
| `res_promedio` | `FLOAT` | L7 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `acl_aclaracion` | `bdiaclaracion` | no | SELECT | L14 |
| `temp_borrame` | `bdiaclaracion` | no | SELECT | L24 |
| `temp_sin_orden` | `bdiaclaracion` | no | SELECT | L32 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `reporte` | ENTIDAD | reporte | 🔵 CONVENCIÓN | nombre_sp |
| `?top` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `acl` | PREFIJO | familia aclaraciones | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `?ara` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `rec` | ACCION | recepción / recibe | 🔵 CONVENCIÓN | nombre_sp |
| `?i` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?top`, `?ara`, `?i` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_reportetotalaclararecixmesxprod`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_reportetotalaclararecixmesxprod.sql` |
| **LOC (1er CREATE)** | 62 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "recepción reporte, mes y producto (total)" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 2 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=3 · CONVENCIÓN=6 · INFERIDO=0 · SINTÉTICO=2 / 11 términos |

### Firma

```sql
CREATE PROCEDURE sp_reportetotalaclararecixmesxprod(
  fechaini                     DATE
  fechaFIN                     DATE
  ids_productos                lVARCHAR
) RETURNING VARCHAR(100) AS producto, CHAR(300) AS evento, INTEGER AS total
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `fechaini` | `DATE` | — | — |
| `fechaFIN` | `DATE` | — | — |
| `ids_productos` | `lVARCHAR` | `prod`=producto | ✅ CÓDIGO |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `res_producto` | `CHAR(100)` | L5 |
| `res_evento` | `CHAR(300)` | L6 |
| `res_total` | `INTEGER` | L7 |
| `productos` | `LIST(INTEGER NOT NULL)` | L8 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `acl_aclaracion` | `bdiaclaracion` | no | SELECT | L18 |
| `temp_aclaras` | `bdiaclaracion` | no | SELECT | L50 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `reporte` | ENTIDAD | reporte | 🔵 CONVENCIÓN | nombre_sp |
| `total` | MODIF | total | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `acl` | PREFIJO | familia aclaraciones | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `?ara` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `rec` | ACCION | recepción / recibe | 🔵 CONVENCIÓN | nombre_sp |
| `?i` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `x` | MODIF | por (criterio) | 🔵 CONVENCIÓN | nombre_sp |
| `mes` | ENTIDAD | mes | 🔵 CONVENCIÓN | nombre_sp |
| `x` | MODIF | por (criterio) | 🔵 CONVENCIÓN | nombre_sp |
| `prod` | ENTIDAD | producto | ✅ CÓDIGO | nombre_sp, texto_cuerpo |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?ara`, `?i` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_reverso_estatus_preingreso`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_reverso_estatus_preingreso.sql` |
| **LOC (1er CREATE)** | 374 |
| **Callgraph** | ✅ fan_in=0 / fan_out=6 |
| **Deps concatenadas** | 1 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "reverso estatus y ingreso" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 3 llamada(s): `sp_consulta_correos`, `sp_consulta_telefonos`, `sp_registra_evento` |
| **Evidencia vocab** | CÓDIGO=3 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=1 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_reverso_estatus_preingreso(
) RETURNING CHAR(3) as cCodRet,
```

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `sql_err` | `INTEGER` | L7 |
| `v_cod_ret` | `CHAR(3)` | L8 |
| `v_fecha_hoy` | `DATE` | L9 |
| `v_fecha_acl` | `DATE` | L10 |
| `v_days` | `INTEGER` | L11 |
| `v_folio_csuac` | `VARCHAR(12)` | L12 |
| `v_folio_aclaracion` | `VARCHAR(18)` | L13 |
| `v_pky_aclaracion` | `INTEGER` | L14 |
| `v_dias_feriados` | `INTEGER` | L15 |
| `v_dias_finSemana` | `INTEGER` | L16 |
| `v_dia_hoy` | `INTEGER` | L17 |
| `contador` | `INTEGER` | L18 |
| `v_num_cliente` | `CHAR(9)` | L20 |
| `v_nombre1` | `CHAR(50)` | L21 |
| `v_nombre2` | `CHAR(50)` | L22 |
| `v_apell_paterno` | `CHAR(50)` | L23 |
| `v_apell_materno` | `CHAR(50)` | L24 |
| `v_nombre_completo` | `CHAR(150)` | L25 |
| `vcodretDatosCte` | `CHAR(5)` | L27 |
| `vCorreoElec` | `CHAR(100)` | L28 |
| `vTipoCorreo` | `SMALLINT` | L29 |
| `vStatusCorreo` | `CHAR(1)` | L30 |
| `vTelefono` | `CHAR(13)` | L32 |
| `vTipoTel` | `SMALLINT` | L33 |
| `vSecuencia` | `SMALLINT` | L34 |
| *…37 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `acl_estatus_corporativo` | `bdiaclaracion` | no | SELECT | L153 |
| `acl_aclaracion` | `bdiaclaracion` | no | SELECT | L178 |
| `si_cliente` | `bdinteg` | ⚠️ sí | SELECT | L194 |
| `acl_folio_aclaracion_acl_aclaracion` | `bdiaclaracion` | no | SELECT | L209 |
| `si_feriado_banca` | `bdinteg` | ⚠️ sí | SELECT | L243 |
| `acl_aclaracion` | `bdiaclaracion` | no | UPDATE | L266 |
| `acl_resolucion` | `bdiaclaracion` | no | SELECT | L277 |
| `acl_entrada_bitacora` | `bdiaclaracion` | no | INSERT | L282 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_consulta_correos` | `bdinteg` | ⚠️ sí | L200 |
| `sp_consulta_telefonos` | `bdinteg` | ⚠️ sí | L203 |
| `sp_registra_evento` | `bdimnsj` | ⚠️ sí | L294 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L157 | VALIDACIÓN_NULL | `IF c_id_estatus_pre_ingreso IS NULL THEN --No está definido el Estatus Pre-Ingreso` |  |
| L167 | VALIDACIÓN_NULL | `IF c_id_estatus_declinado IS NULL THEN --No está definido el Estatus Declinado` |  |
| L223 | FÓRMULA | `LET v_contador_doctos = v_contador_doctos + 1;` |  |
| L247 | FÓRMULA | `LET v_days = DATE(v_fecha_hoy) - DATE(v_fecha_acl);` |  |
| L255 | FÓRMULA | `LET v_dias_finSemana = v_dias_finSemana + 1;` |  |
| L257 | FÓRMULA | `LET contador = contador + 1;` |  |
| L258 | FÓRMULA | `LET v_fecha_acl = v_fecha_acl+1;` |  |
| L262 | FÓRMULA | `LET v_days = v_days - (v_dias_feriados + v_dias_finSemana);` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `reverso` | ACCION | reverso | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `estatus` | ENTIDAD | estatus | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `?_pre` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `ingreso` | ENTIDAD | ingreso (del solicitante) | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_pre` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_sv_aprovisionamiento_aclaraciones`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_sv_aprovisionamiento_aclaraciones.sql` |
| **LOC (1er CREATE)** | 213 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "sv — supervisión/servicio y aclaraciones" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 1 llamada(s): `sp_mes_siguiente` |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=2 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_sv_aprovisionamiento_aclaraciones(
) RETURNING VARCHAR (5) as rCODIGO_RETORNO,
```

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vCODIGO_RETORNO` | `VARCHAR(5)` | L6 |
| `vMENSAJE_RETORNO` | `VARCHAR(120)` | L7 |
| `vsql` | `LVARCHAR(5000)` | L8 |
| `vIndicadorProceso` | `CHAR(10)` | L9 |
| `RUTA_ARCHIVOS` | `VARCHAR(100)` | L10 |
| `RUTA_CARPETA` | `VARCHAR(100)` | L11 |
| `RUTA_LOGS` | `VARCHAR(100)` | L12 |
| `v_periodo_tc_ini` | `DATE` | L14 |
| `v_periodo_tc_fin` | `DATE` | L15 |
| `v_periodo_anterior` | `DATE` | L16 |
| `v_dias_periodo_tc` | `INTEGER` | L17 |
| `v_periodo` | `DATE` | L18 |
| `v_dia_tc_ini` | `integer` | L20 |
| `v_dia_tc_fin` | `integer` | L21 |
| `v_mes_tc_ini` | `integer` | L22 |
| `v_mes_tc_fin` | `integer` | L23 |
| `v_anio_tc_ini` | `integer` | L24 |
| `v_anio_tc_fin` | `integer` | L25 |
| `SQLERR` | `INTEGER` | L27 |
| `ISAM_ERR` | `INTEGER` | L28 |
| `ERROR_INFO` | `VARCHAR(80)` | L29 |
| `v_cod_ret_otro` | `CHAR(5)` | L30 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `acl_producto` | `bdiaclaracion` | no | SELECT | L127 |
| `aclaracion` | `bdiaclaracion` | no | SELECT | L144 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_mes_siguiente` | `bdicred` | ⚠️ sí | L87 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L42 | FÓRMULA | `LET v_periodo_anterior   	= " ";  --Fecha Periodo Anterior` |  |
| L43 | FÓRMULA | `LET v_dias_periodo_tc 		= 0;	--dias_periodo_tc` |  |
| L44 | FÓRMULA | `LET v_periodo_tc_ini   		  = " ";	--periodo_tc_ini` |  |
| L45 | FÓRMULA | `LET v_periodo_tc_fin   		  = " ";	--periodo_tc_fin` |  |
| L49 | FÓRMULA | `LET v_dia_tc_ini=0;	  		--periodo_tc_ini` |  |
| L50 | FÓRMULA | `LET v_dia_tc_fin=0;	  		--periodo_tc_fin` |  |
| L51 | FÓRMULA | `LET v_mes_tc_ini=0;	  		--periodo_tc_ini` |  |
| L52 | FÓRMULA | `LET v_mes_tc_fin=0;	  		--periodo_tc_fin` |  |
| L53 | FÓRMULA | `LET v_anio_tc_ini=0;  		--periodo_tc_ini` |  |
| L54 | FÓRMULA | `LET v_anio_tc_fin=0;  		--periodo_tc_fin` |  |
| L97 | FÓRMULA | `LET v_periodo_tc_ini = v_periodo_anterior + 1 UNITS DAY;` |  |
| L102 | FÓRMULA | `LET v_dias_periodo_tc = (v_dias_periodo_tc * -1) ;` |  |
| L155 | FÓRMULA | `let vsql= 'chmod +x '\|\| TRIM(RUTA_ARCHIVOS) \|\|'/aclaraciones_sv.sql';` | 🔴 MONEY/aritmética financiera |
| L160 | FÓRMULA | `let vsql= 'dbaccess bdicred '\|\| TRIM(RUTA_ARCHIVOS) \|\|  '/aclaraciones_sv.sql';` |  |
| L167 | FÓRMULA | `let vsql= 'chmod +x '\|\| TRIM(RUTA_ARCHIVOS) \|\|  '/aclaraciones_sv.unl';` | 🔴 MONEY/aritmética financiera |
| L192 | FÓRMULA | `let vsql ='rm  '\|\| TRIM(RUTA_ARCHIVOS) \|\| '/*_sv.sql';` |  |
| L199 | FÓRMULA | `let vsql ='rm  '\|\| TRIM(RUTA_ARCHIVOS) \|\| '/*_sv.unl';` |  |
| L206 | FÓRMULA | `let vsql ='rm  '\|\| TRIM(RUTA_ARCHIVOS) \|\| TRIM(RUTA_CARPETA) \|\| '/*_sv.tar';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `sv` | ENTIDAD | sv — supervisión/servicio (abreviación — bdiaclaracion) | 🔴 SINTÉTICO | nombre_sp |
| `?_aprovisionamiento_` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `aclaraciones` | ENTIDAD | aclaraciones (proceso de disputas/reclamaciones de cliente) | ✅ CÓDIGO | nombre_sp, texto_cuerpo |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `sv`, `?_aprovisionamiento_` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_top20acl`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_top20acl.sql` |
| **LOC (1er CREATE)** | 185 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 1 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "sp_top20acl" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 7 tabla(s) con operaciones: SELECT, INSERT |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=1 / 3 términos |

### Firma

```sql
CREATE PROCEDURE sp_top20acl(
) RETURNING char(7)
```

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vsql` | `char(1150)` | L4 |
| `vcodret` | `char(7)` | L5 |
| `vsqlerr` | `integer` | L6 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `systables` | `bdiaclaracion` | no | SELECT | L9 |
| `acl_aclaracion` | `bdiaclaracion` | no | SELECT | L41 |
| `acl_reporte_top20` | `bdiaclaracion` | no | INSERT | L54 |
| `top20tpen` | `bdiaclaracion` | no | SELECT | L55 |
| `acl_reporte_top20` | `bdiaclaracion` | no | SELECT | L62 |
| `top20tnp` | `bdiaclaracion` | no | SELECT | L98 |
| `top20tproc` | `bdiaclaracion` | no | SELECT | L138 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L59 | FÓRMULA | `let vsql = ' echo "FechaCaptura\|FolioCsuac\|Sucursal\|Monto\|EstatusComporativo\|FechaDeCargo\|Even` | 🔴 MONEY/aritmética financiera |
| L71 | FÓRMULA | `let vsql = "sed 's/\|$//g' top20.unl >>/resplogifx/repaclaraciones/Top20_pendientes_"\|\|LPAD(day(to` |  |
| L100 | FÓRMULA | `let vsql = ' echo "FechaCaptura\|FolioCsuac\|Sucursal\|Monto\|EstatusComporativo\|FechaDeCargo\|Even` | 🔴 MONEY/aritmética financiera |
| L112 | FÓRMULA | `let vsql = "sed 's/\|$//g' top202.unl >>/resplogifx/repaclaraciones/Top20_noprocedentes_"\|\|LPAD(da` |  |
| L140 | FÓRMULA | `let vsql = ' echo "FechaCaptura\|FolioCsuac\|Sucursal\|Monto\|EstatusComporativo\|FechaDeCargo\|Even` | 🔴 MONEY/aritmética financiera |
| L152 | FÓRMULA | `let vsql = "sed 's/\|$//g' top201.unl >>/resplogifx/repaclaraciones/Top20_procedentes_"\|\|LPAD(day(` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `?_top20` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `acl` | PREFIJO | familia aclaraciones | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_top20` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_upd_credrecuperacion`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_upd_credrecuperacion.sql` |
| **LOC (1er CREATE)** | 1207 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "actualiza crédito" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `actualiza` → `UPDATE` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=2 · INFERIDO=1 · SINTÉTICO=0 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_upd_credrecuperacion(
  e_folio_csuac                CHAR(11)
) RETURNING CHAR(6) AS s_CodRet, CHAR(100) AS s_Mensaje, SMALLINT AS s_Cc,  MONEY AS s_AfectacionC,  VARCHAR(3) AS s_CodleyendaC,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `e_folio_csuac` | `CHAR(11)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `CCodret_c` | `CHAR(5)` | L9 |
| `CMensaje` | `CHAR(80)` | L10 |
| `s_CodRet` | `CHAR(6)` | L11 |
| `s_Mensaje` | `CHAR(100)` | L12 |
| `s_Mensaje2` | `CHAR(30)` | L13 |
| `s_Cc` | `SMALLINT` | L14 |
| `s_Ci` | `SMALLINT` | L15 |
| `s_Ca` | `SMALLINT` | L16 |
| `s_AfectacionC` | `MONEY` | L17 |
| `s_AfectacionI` | `MONEY` | L18 |
| `s_AfectacionA` | `MONEY` | L19 |
| `s_CodleyendaA` | `VARCHAR(3)` | L20 |
| `s_CodleyendaI` | `VARCHAR(3)` | L21 |
| `s_CodleyendaC` | `VARCHAR(3)` | L22 |
| `s_Cin` | `SMALLINT` | L25 |
| `s_AfectacionIn` | `MONEY` | L26 |
| `s_CodleyendaIn` | `VARCHAR(3)` | L27 |
| `i_total_interes` | `MONEY` | L30 |
| `i_interes_recuperado` | `MONEY` | L31 |
| `i_interes_afectado` | `MONEY` | L32 |
| `i_fin_recuperacion` | `DATE` | L34 |
| `i_exito_cin` | `SMALLINT` | L35 |
| `i_tipo_movimiento` | `CHAR(1)` | L36 |
| `i_importereclamado` | `MONEY` | L37 |
| `i_fky_regla_negocio` | `INTEGER` | L38 |
| *…76 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `acl_aclaracion` | `bdiaclaracion` | no | SELECT | L209 |
| `acl_aclaracion` | `bdiaclaracion` | no | UPDATE | L231 |
| `acl_rango_importe` | `bdiaclaracion` | no | SELECT | L240 |
| `acl_recuperacion_saldos` | `bdiaclaracion` | no | SELECT | L247 |
| `acl_resolucion` | `bdiaclaracion` | no | SELECT | L253 |
| `si_ejecut` | `bdinteg` | ⚠️ sí | SELECT | L284 |
| `acl_recuperacion_saldos` | `bdiaclaracion` | no | UPDATE | L354 |
| `acl_entrada_bitacora` | `bdiaclaracion` | no | INSERT | L367 |
| `sd_fechas` | `bdicred` | ⚠️ sí | SELECT | L451 |
| `sd_maesdos` | `bdicred` | ⚠️ sí | SELECT | L467 |
| `acl_tipo_movimiento` | `bdiaclaracion` | no | SELECT | L483 |
| `acl_movimiento` | `bdiaclaracion` | no | SELECT | L484 |
| `acl_movimiento` | `bdiaclaracion` | no | UPDATE | L616 |
| `acl_control_cuentas_pendientes_cancelar` | `bdiaclaracion` | no | SELECT | L1148 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_consulta_tipo_movimiento` | `bdiaclaracion` | no | L222 |
| `sp_ins_recuperacion_saldos` | `bdiaclaracion` | no | L322 |
| `sp_aplicar_cancelacion_por_recuperacion_creddeb` | `bdiaclaracion` | no | L434 |
| `sp_desbloqueocuenta` | `bdicred` | ⚠️ sí | L459 |
| `cargoref_tc_ofi` | `bdicred` | ⚠️ sí | L489 |
| `sp_cargo_abono_aclara` | `bdicred` | ⚠️ sí | L565 |
| `sp_bloqueocuenta` | `bdicred` | ⚠️ sí | L1161 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L254 | FÓRMULA | `LET v_resol_importe_irrecuperable = (select pky_resolucion from acl_resolucion where nombre='cargoNo` | 🔴 MONEY/aritmética financiera |
| L286 | VALIDACIÓN_NULL | `IF eSucursal = '' OR eSucursal IS NULL THEN` |  |
| L294 | FÓRMULA | `LET v_diferencia_fechas =  DATE(today) - DATE(i_fechacaptura);` |  |
| L321 | VALIDACIÓN_NULL | `IF vPky_recuperacion_sdos IS NULL THEN` |  |
| L476 | FÓRMULA | `LET i_val_tmpC = (i_total_comision - i_comision_recuperada);` |  |
| L477 | FÓRMULA | `LET i_val_tmpI = (i_total_iva - i_iva_recuperada);` |  |
| L487 | FÓRMULA | `LET s_AfectacionC = linea_disponible / (1.16); --CALCULO COBRO COMISIÃN` |  |
| L493 | FÓRMULA | `LET s_AfectacionI =  linea_disponible - (s_AfectacionC); --CALCULO COBRO IVA` |  |
| L494 | FÓRMULA | `LET i_val_tmpC = (i_comision_recuperada + s_AfectacionC);` |  |
| L495 | FÓRMULA | `LET i_val_tmpI = (i_iva_recuperada + s_AfectacionI);` |  |
| L575 | FÓRMULA | `LET s_AfectacionC = i_total_comision;  --TOTAL DE LA TABLA COMISION` |  |
| L576 | FÓRMULA | `LET s_AfectacionI = i_total_iva;       --- TOTAL DE LA TABLA IVA` |  |
| L582 | FÓRMULA | `LET i_val_tmpC = (i_comision_recuperada + i_val_tmpC);` |  |
| L583 | FÓRMULA | `LET i_val_tmpI = (i_iva_recuperada + i_val_tmpI);` |  |
| L614 | FÓRMULA | `let vMontoRecuperacion = i_comision_recuperada + s_AfectacionC;` | 🔴 MONEY/aritmética financiera |
| L696 | FÓRMULA | `LET i_val_tmpIn = (i_total_interes - i_interes_recuperado);` | 🔴 MONEY/aritmética financiera |
| L718 | FÓRMULA | `LET s_AfectacionIn = i_val_tmpIn; --> Saldo de salida de ABONO afectada` |  |
| L721 | FÓRMULA | `LET i_val_tmpIn = (i_interes_recuperado + i_val_tmpIn);` | 🔴 MONEY/aritmética financiera |
| L811 | FÓRMULA | `LET s_AfectacionIn = i_val_tmpIn; --> Saldo de salida de ABONO afectada` |  |
| L814 | FÓRMULA | `LET i_val_tmpIn = (i_interes_recuperado + i_val_tmpIn); --Suma abono recuperado + afectado` | 🔴 MONEY/aritmética financiera |
| L910 | FÓRMULA | `LET i_val_tmpA = (i_total_abono - i_abono_recuperado);` |  |
| L933 | FÓRMULA | `LET s_AfectacionA = i_val_tmpA; --> Saldo de salida de ABONO afectada` |  |
| L936 | FÓRMULA | `LET i_val_tmpA = (i_abono_recuperado + i_val_tmpA);` |  |
| L1025 | FÓRMULA | `LET s_AfectacionA = i_val_tmpA; --> Saldo de salida de ABONO afectada` |  |
| L1028 | FÓRMULA | `LET i_val_tmpA = (i_abono_recuperado + i_val_tmpA); --Suma abono recuperado + afectado` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `upd` | ACCION | actualiza (update) | 🟡 INFERIDO | nombre_sp |
| `cred` | ENTIDAD | crédito | 🔵 CONVENCIÓN | nombre_sp |
| `recuperacion` | ACCION | recuperación (cobranza) | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |

---

## `sp_upd_debrecuperacion`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_upd_debrecuperacion.sql` |
| **LOC (1er CREATE)** | 1434 |
| **Callgraph** | ✅ fan_in=10 / fan_out=6 |
| **Propósito inferido** | "actualiza (débito)" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `actualiza` → `UPDATE` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=2 · INFERIDO=1 · SINTÉTICO=0 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_upd_debrecuperacion(
  e_folio_csuac                CHAR(11)
) RETURNING CHAR(6) AS s_CodRet, CHAR(100) AS s_Mensaje, SMALLINT AS s_Cc, MONEY AS s_AfectacionC, VARCHAR(3) AS s_CodleyendaC,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `e_folio_csuac` | `CHAR(11)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `s_CodRet` | `CHAR(6)` | L9 |
| `s_Mensaje` | `CHAR(100)` | L10 |
| `s_Mensaje2` | `CHAR(30)` | L11 |
| `s_Cc` | `SMALLINT` | L12 |
| `s_Ci` | `SMALLINT` | L13 |
| `s_Ca` | `SMALLINT` | L14 |
| `s_AfectacionC` | `MONEY` | L15 |
| `s_AfectacionI` | `MONEY` | L16 |
| `s_AfectacionA` | `MONEY` | L17 |
| `s_CodleyendaA` | `VARCHAR(3)` | L18 |
| `s_CodleyendaI` | `VARCHAR(3)` | L19 |
| `s_CodleyendaC` | `VARCHAR(3)` | L20 |
| `s_Cin` | `SMALLINT` | L23 |
| `s_AfectacionIn` | `MONEY` | L24 |
| `s_CodleyendaIn` | `VARCHAR(3)` | L25 |
| `i_abono_recuperado` | `MONEY` | L31 |
| `i_comision_recuperada` | `MONEY` | L32 |
| `i_iva_recuperada` | `MONEY` | L33 |
| `i_abono_irrecuperable` | `SMALLINT` | L34 |
| `i_cron_activo` | `SMALLINT` | L35 |
| `i_f_recuperacion` | `DATE` | L36 |
| `i_fechacaptura` | `DATE` | L37 |
| `i_fc_recuperacion` | `DATE` | L38 |
| `i_fi_recuperacion` | `DATE` | L39 |
| `i_fa_recuperacion` | `DATE` | L40 |
| *…71 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `acl_aclaracion` | `bdiaclaracion` | no | SELECT | L191 |
| `acl_aclaracion` | `bdiaclaracion` | no | UPDATE | L210 |
| `acl_rango_importe` | `bdiaclaracion` | no | SELECT | L217 |
| `acl_recuperacion_saldos` | `bdiaclaracion` | no | SELECT | L227 |
| `acl_resolucion` | `bdiaclaracion` | no | SELECT | L235 |
| `si_ejecut` | `bdinteg` | ⚠️ sí | SELECT | L264 |
| `acl_recuperacion_saldos` | `bdiaclaracion` | no | UPDATE | L354 |
| `acl_entrada_bitacora` | `bdiaclaracion` | no | INSERT | L365 |
| `sc_comisiones` | `bdicheq` | ⚠️ sí | SELECT | L447 |
| `sc_fechas` | `bdicheq` | ⚠️ sí | SELECT | L450 |
| `sc_maechq` | `bdicheq` | ⚠️ sí | SELECT | L458 |
| `sac_mensajeerror` | `bdisac` | ⚠️ sí | INSERT | L496 |
| `acl_movimiento` | `bdiaclaracion` | no | UPDATE | L708 |
| `acl_tipo_movimiento` | `bdiaclaracion` | no | SELECT | L768 |
| `acl_movimiento` | `bdiaclaracion` | no | SELECT | L769 |
| `acl_control_cuentas_pendientes_cancelar` | `bdiaclaracion` | no | SELECT | L1372 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_consulta_tipo_movimiento` | `bdiaclaracion` | no | L204 |
| `sp_ins_recuperacion_saldos` | `bdiaclaracion` | no | L323 |
| `sp_aplicar_cancelacion_por_recuperacion_creddeb` | `bdiaclaracion` | no | L427 |
| `bloqueo_cta` | `bdicheq` | ⚠️ sí | L464 |
| `cons_saldo` | `bdicheq` | ⚠️ sí | L470 |
| `cargo_ref` | `bdicheq` | ⚠️ sí | L498 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L266 | VALIDACIÓN_NULL | `IF eSucursal = '' OR eSucursal IS NULL THEN` |  |
| L279 | FÓRMULA | `LET v_diferencia_fechas =  DATE(today) - DATE(i_fechacaptura);` |  |
| L479 | FÓRMULA | `LET i_val_tmpC = (i_total_comision - i_comision_recuperada);` |  |
| L480 | FÓRMULA | `LET i_val_tmpI = (i_total_iva - i_iva_recuperada);` |  |
| L486 | FÓRMULA | `LET s_AfectacionC = vsdodisp / (1.16);` |  |
| L487 | FÓRMULA | `LET s_AfectacionI = vsdodisp - (s_AfectacionC);` |  |
| L489 | FÓRMULA | `LET s_AfectacionC = vsdodisp / (1.16);` |  |
| L490 | FÓRMULA | `LET s_AfectacionI = vsdodisp - (s_AfectacionC);` |  |
| L542 | FÓRMULA | `LET i_val_tmpC = (i_comision_recuperada + s_AfectacionC);` |  |
| L543 | FÓRMULA | `LET i_val_tmpI = (i_iva_recuperada + s_AfectacionI);` |  |
| L613 | FÓRMULA | `LET i_val_tmpC = (i_total_comision - i_comision_recuperada);` |  |
| L614 | FÓRMULA | `LET i_val_tmpI = (i_total_iva - i_iva_recuperada);` |  |
| L667 | FÓRMULA | `LET i_val_tmpC = (i_comision_recuperada + i_val_tmpC);` |  |
| L668 | FÓRMULA | `LET i_val_tmpI = (i_iva_recuperada + i_val_tmpI);` |  |
| L764 | FÓRMULA | `LET pFolioSuacSUC = trim(v_fecha_folio)\|\|lpad(e_folio_csuac,10,0); --Genera el FolioSuc` |  |
| L784 | FÓRMULA | `LET i_val_tmpIn = (i_total_interes - i_interes_recuperado);` | 🔴 MONEY/aritmética financiera |
| L789 | FÓRMULA | `LET s_AfectacionIn = i_val_tmpIn; --> Saldo de salida de interes afectada` | 🔴 MONEY/aritmética financiera |
| L791 | FÓRMULA | `LET i_val_tmpIn = (i_interes_recuperado + i_val_tmpIn);` | 🔴 MONEY/aritmética financiera |
| L903 | FÓRMULA | `LET i_val_tmpIn = (i_interes_recuperado + i_val_tmpIn);` | 🔴 MONEY/aritmética financiera |
| L1038 | FÓRMULA | `LET i_val_tmpA = (i_total_abono - i_abono_recuperado);` |  |
| L1044 | FÓRMULA | `LET s_AfectacionA = i_val_tmpA; --> Saldo de salida de comision afectada` |  |
| L1046 | FÓRMULA | `LET i_val_tmpA = (i_abono_recuperado + i_val_tmpA);` |  |
| L1180 | FÓRMULA | `LET i_val_tmpA = (i_abono_recuperado + i_val_tmpA);` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `upd` | ACCION | actualiza (update) | 🟡 INFERIDO | nombre_sp |
| `deb` | MODIF | débito | 🔵 CONVENCIÓN | nombre_sp |
| `recuperacion` | ACCION | recuperación (cobranza) | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |

---

## `sp_validafuncionalidades`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_validafuncionalidades.sql` |
| **LOC (1er CREATE)** | 71 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 4 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "valida identificador" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `valida` → `IF` encontrado en el cuerpo · `valida` → `RETURN` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=2 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_validafuncionalidades(
  pUsuario                     CHAR(50)
) RETURNING CHAR(5) AS codret,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pUsuario` | `CHAR(50)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(5)` | L8 |
| `iSqlErr` | `INTEGER` | L9 |
| `cEmpresa` | `CHAR(3)` | L10 |
| `iIdPermiso` | `INTEGER` | L11 |
| `cDescripcion` | `CHAR(255)` | L12 |
| `cNombre` | `CHAR(100)` | L13 |
| `iRecuperacion` | `INTEGER` | L14 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `acl_usuario` | `bdiaclaracion` | no | SELECT | L42 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L16 | CÓDIGO_RETORNO | `LET cCodRet = '00000';` |  |
| L51 | FÓRMULA | `LET iRecuperacion = iRecuperacion + 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `valida` | ACCION | valida | 🔵 CONVENCIÓN | nombre_sp |
| `?funcional` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `id` | ENTIDAD | identificador (de) | 🔵 CONVENCIÓN | nombre_sp |
| `?ades` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?funcional`, `?ades` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_validafuncionalidades2`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_validafuncionalidades2.sql` |
| **LOC (1er CREATE)** | 89 |
| **Callgraph** | ✅ fan_in=0 / fan_out=4 |
| **Deps concatenadas** | 4 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "valida identificador" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `valida` → `IF` encontrado en el cuerpo · `valida` → `RETURN` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=2 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_validafuncionalidades2(
  pUsuario                     CHAR(50)
  pRegistros                   INTEGER
  pRecuperacion                INTEGER
) RETURNING CHAR(5) AS codret,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pUsuario` | `CHAR(50)` | — | — |
| `pRegistros` | `INTEGER` | — | — |
| `pRecuperacion` | `INTEGER` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(5)` | L8 |
| `iSqlErr` | `INTEGER` | L9 |
| `cEmpresa` | `CHAR(3)` | L10 |
| `iIdPermiso` | `INTEGER` | L11 |
| `cDescripcion` | `CHAR(255)` | L12 |
| `cNombre` | `CHAR(100)` | L13 |
| `iRegistro` | `INTEGER` | L14 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `acl_usuario` | `bdiaclaracion` | no | SELECT | L42 |
| `si_ejecut` | `bdinteg` | ⚠️ sí | SELECT | L59 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L16 | CÓDIGO_RETORNO | `LET cCodRet = '00000';` |  |
| L51 | FÓRMULA | `LET iRegistro = iRegistro + 1;` |  |
| L67 | FÓRMULA | `LET iRegistro = iRegistro + 1;` |  |
| L73 | CÓDIGO_RETORNO | `LET cCodRet = '00017';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `valida` | ACCION | valida | 🔵 CONVENCIÓN | nombre_sp |
| `?funcional` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `id` | ENTIDAD | identificador (de) | 🔵 CONVENCIÓN | nombre_sp |
| `?ades2` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?funcional`, `?ades2` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_validapassword`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_validapassword.sql` |
| **LOC (1er CREATE)** | 126 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 12 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "valida ss — subsistema y ordenante" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `valida` → `IF` encontrado en el cuerpo · `valida` → `RETURN` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=3 / 6 términos |

### Firma

```sql
CREATE PROCEDURE sp_validapassword(
  pUsuario                     CHAR(50)
  pPassword                    CHAR(100)
  pIpUsuario                   CHAR(16)
  pKeyEntro                    CHAR(255)
  pKeySalio                    CHAR(255)
) RETURNING CHAR(5) AS codret,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pUsuario` | `CHAR(50)` | — | — |
| `pPassword` | `CHAR(100)` | `ss`=ss — subsistema / canal de monitoreo (abreviación — envia_monitorsol_*_ss_* — bdisolic) · `ord`=ordenante / orden (SPEI) | 🔴 SINTÉTICO / 🔵 CONVENCIÓN |
| `pIpUsuario` | `CHAR(16)` | — | — |
| `pKeyEntro` | `CHAR(255)` | — | — |
| `pKeySalio` | `CHAR(255)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(5)` | L10 |
| `iSqlErr` | `INTEGER` | L11 |
| `cEmpresa` | `CHAR(3)` | L12 |
| `cPkeyUsuario` | `INTEGER` | L13 |
| `cNombre` | `CHAR(45)` | L14 |
| `cPuesto` | `CHAR(50)` | L15 |
| `iArea` | `INTEGER` | L16 |
| `cStatus` | `CHAR(1)` | L17 |
| `cKey` | `CHAR(255)` | L18 |
| `cEnSesion` | `CHAR(1)` | L19 |
| `iNumRegistros` | `INTEGER` | L20 |
| `cIp` | `CHAR(16)` | L21 |
| `iPid` | `INTEGER` | L22 |
| `cValidaClave` | `CHAR(100)` | L23 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `acl_usuario` | `bdiaclaracion` | no | SELECT | L57 |
| `acl_sesion_usuario` | `bdiaclaracion` | no | SELECT | L84 |
| `informix` | `bdiaclaracion` | no | INSERT | L90 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L25 | CÓDIGO_RETORNO | `LET cCodRet = '00000';` |  |
| L60 | VALIDACIÓN_NULL | `IF cValidaClave = '' OR cValidaClave IS NULL THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `valida` | ACCION | valida | 🔵 CONVENCIÓN | nombre_sp |
| `?pa` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `ss` | ENTIDAD | ss — subsistema / canal de monitoreo (abreviación — envia_mo | 🔴 SINTÉTICO | nombre_sp |
| `?w` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `ord` | ENTIDAD | ordenante / orden (SPEI) | 🔵 CONVENCIÓN | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?pa`, `ss`, `?w` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_verifica_aclaracion`

| Campo | Valor |
|-------|-------|
| **Dominio** | D07 · `bdiaclaracion` · Aclaraciones |
| **Archivo fuente** | `bdiaclaracion_sp_verifica_aclaracion.sql` |
| **LOC (1er CREATE)** | 64 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 1 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "verifica aclaración bancaria — proceso de disputa o reclamación del cliente" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 1 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=0 / 3 términos |

### Firma

```sql
CREATE PROCEDURE sp_verifica_aclaracion(
  pNumCta                      CHAR(20)
) RETURNING CHAR(5) AS codRet
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pNumCta` | `CHAR(20)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `iSqlErr` | `INTEGER` | L7 |
| `iIsamErr` | `INTEGER` | L8 |
| `codRet` | `CHAR(5)` | L10 |
| `numCte` | `INTEGER` | L12 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `acl_aclaracion` | `bdiaclaracion` | no | SELECT | L41 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L29 | CÓDIGO_RETORNO | `LET codRet = '00000';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `verifica` | ACCION | verifica | 🔵 CONVENCIÓN | nombre_sp |
| `aclaracion` | ENTIDAD | aclaración bancaria — proceso de disputa o reclamación del c | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |

---

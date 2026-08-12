# SP Specs — D08 · `bdispei` · SPEI

> Generado por `build-sp-specs.py` · Grounding Pass v1.0
> Objetivo: verificar el conocimiento del Gemelo Cognitivo contra el código fuente real
> **Convención:** solo se analiza el PRIMER `CREATE PROCEDURE` de cada archivo
> (los siguientes son dependencias concatenadas — ver memoria del proyecto)

## Resumen de validación del dominio

| Métrica | Valor |
|---------|-------|
| SPs analizados | **189** |
| Presentes en callgraph | 45 |
| SPs aislados (⚠️ no estaban en el análisis previo) | 144 |
| Propósito **VERIFICADO** | 87 |
| Propósito **PARCIAL** | 100 |
| Propósito **NO_VERIFICABLE** | 2 |
| SPs con tokens **SINTÉTICOS** detectados | 119 |

> Los **144 SPs aislados** no aparecen en el callgraph y por tanto
> **no fueron incluidos en el análisis de journeys, reglas ni vocabulario previo**.
> Este grounding pass los analiza por primera vez directamente desde el código.

---

## `callsyn_procsign`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_callsyn_procsign.sql` |
| **LOC (1er CREATE)** | 10 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "[polisemia] Cálculo y proceso" `[partial]` |
| **Propósito verificado** | ❓ NO_VERIFICABLE — Propósito inferido; sin evidencia DML para verificar |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=0 · INFERIDO=2 · SINTÉTICO=2 / 4 términos |

### Firma

```sql
CREATE PROCEDURE callsyn_procsign(
)
```

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `l_type` | `char(15)` | L2 |
| `l_idmsg` | `char(15)` | L3 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `cal` | ENTIDAD | [polisemia] Cálculo (cal_fecha, cal_riesgo_cliente, cal_trad | 🟡 INFERIDO | nombre_sp |
| `?lsyn_` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `proc` | ENTIDAD | proceso | 🟡 INFERIDO | nombre_sp |
| `?sign` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?lsyn_`, `?sign` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `cancelacion`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_cancelacion.sql` |
| **LOC (1er CREATE)** | 78 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "cancela" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 3 tabla(s) con operaciones: SELECT, UPDATE |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=0 · INFERIDO=0 · SINTÉTICO=0 / 1 términos |

### Firma

```sql
CREATE PROCEDURE cancelacion(
  psucursal                    CHAR(4)
) RETURNING CHAR(5)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `psucursal` | `CHAR(4)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `v_row` | `INTEGER` | L17 |
| `v_statusenv` | `CHAR(1)` | L18 |
| `v_codret` | `CHAR(5)` | L19 |
| `v_ejecutivo` | `CHAR(8)` | L20 |
| `sql_err` | `INTEGER` | L21 |
| `vchrParametro` | `VARCHAR(255)` | L22 |
| `vchrFechaHoy` | `VARCHAR(10)` | L23 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tblparametros` | `bdispei` | no | SELECT | L44 |
| `tblpago` | `bdispei` | no | SELECT | L52 |
| `tblpago` | `bdispei` | no | UPDATE | L65 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L47 | FÓRMULA | `LET vchrFechaHoy = SUBSTR(vchrParametro,4,2) \|\| '/' \|\|` |  |
| L59 | VALIDACIÓN_NULL | `IF v_statusenv IS NULL OR v_statusenv = "" THEN` |  |
| L60 | FÓRMULA | `LET v_codret="999";  -- No Existe Usuario Autorizado` |  |
| L69 | FÓRMULA | `LET v_codret="000";          -- Movimineto Cancelado` |  |
| L72 | FÓRMULA | `LET v_codret="145";          -- Usuario Autorizado no existe` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `cancelacion` | ACCION | cancela | ✅ CÓDIGO | nombre_sp, texto_cuerpo |

---

## `con_canc_audi`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_con_canc_audi.sql` |
| **LOC (1er CREATE)** | 115 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "consulta auditoría" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=0 · INFERIDO=1 · SINTÉTICO=2 / 4 términos |

### Firma

```sql
CREATE PROCEDURE con_canc_audi(
) RETURNING char(5),
```

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cod_ret` | `char(5)` | L18 |
| `vsucursal` | `char(4)` | L20 |
| `vfolio` | `char(30)` | L21 |
| `vcuenta` | `char(20)` | L22 |
| `vcliente` | `char(20)` | L23 |
| `vnombre` | `char(60)` | L24 |
| `vmonto` | `money(17,2)` | L25 |
| `vtransaccion` | `char(60)` | L26 |
| `vmotivo_modulo` | `char(100)` | L27 |
| `sql_err` | `integer` | L28 |
| `iCveTipoPago` | `integer` | L30 |
| `iCveTipoOperacion` | `integer` | L31 |
| `vapell_paterno` | `char(15)` | L33 |
| `vapell_materno` | `char(15)` | L34 |
| `vnombre1` | `char(15)` | L35 |
| `vnombre2` | `char(15)` | L36 |
| `v_ctaord` | `char(20)` | L37 |
| `contador` | `smallint` | L38 |
| `vrazon_social` | `char(40)` | L39 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tblpago` | `bdispei` | no | SELECT | L71 |
| `si_cliente` | `bdinteg` | ⚠️ sí | SELECT | L88 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L80 | FÓRMULA | `LET contador = contador + 1;` |  |
| L91 | VALIDACIÓN_NULL | `IF vapell_paterno IS NULL OR TRIM(vapell_paterno) = "" THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `con` | ACCION | consulta | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?_canc_` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `aud` | ENTIDAD | auditoría | 🟡 INFERIDO | nombre_sp |
| `?i` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_canc_`, `?i` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `consulta_bancos`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_consulta_bancos.sql` |
| **LOC (1er CREATE)** | 167 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "consulta banco" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=1 / 3 términos |

### Firma

```sql
CREATE PROCEDURE consulta_bancos(
  ult_reg                      integer
) RETURNING char(5),integer, char(60), char(1), smallint, smallint, smallint,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `ult_reg` | `integer` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vbanco` | `integer` | L6 |
| `vnombreb` | `char(60)` | L7 |
| `vreq_formato` | `char(1)` | L8 |
| `vdig_cuenta` | `smallint` | L9 |
| `vdig_sucursal` | `smallint` | L10 |
| `vdig_plaza` | `smallint` | L11 |
| `vopera_tef` | `smallint` | L12 |
| `vopera_speua` | `smallint` | L13 |
| `vpermitecta` | `char(1)` | L14 |
| `vpermiteclabe` | `char(1)` | L15 |
| `cod_ret` | `char(5)` | L17 |
| `sql_err` | `integer` | L18 |
| `contador` | `integer` | L19 |
| `vnumero` | `integer` | L20 |
| `chrSpeiActivo` | `char(1)` | L21 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tblparametros` | `bdispei` | no | SELECT | L56 |
| `bancos` | `bdispeua` | ⚠️ sí | SELECT | L61 |
| `bancos` | `paginterban` | ⚠️ sí | SELECT | L63 |
| `vbancos` | `bdispei` | no | SELECT | L116 |
| `tblbanco` | `bdispei` | no | SELECT | L136 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L85 | VALIDACIÓN_NULL | `if vopera_speua IS NULL then` |  |
| L100 | VALIDACIÓN_NULL | `if vopera_tef IS NULL then` |  |
| L105 | FÓRMULA | `let contador = contador + 1;` |  |
| L139 | VALIDACIÓN_NULL | `if vopera_speua IS NULL then` |  |
| L154 | VALIDACIÓN_NULL | `if vopera_tef IS NULL then` |  |
| L158 | FÓRMULA | `let contador = contador + 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `consulta` | ACCION | consulta / lee | 🔵 CONVENCIÓN | nombre_sp |
| `banco` | ENTIDAD | banco | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?s` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?s` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `getnextpk`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_getnextpk.sql` |
| **LOC (1er CREATE)** | 12 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "(tipo)" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 3 tabla(s) con operaciones: INSERT, SELECT, UPDATE |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=2 / 4 términos |

### Firma

```sql
CREATE PROCEDURE getnextpk(
  NombreTabla                  varchar(50)
) RETURNING INTEGER
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `NombreTabla` | `varchar(50)` | — | — |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `ctrltablas` | `bdispei` | no | SELECT | L4 |
| `ctrltablas` | `bdispei` | no | INSERT | L6 |
| `ctrltablas` | `bdispei` | no | UPDATE | L10 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `?getne` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `x` | MODIF | por (criterio) | 🔵 CONVENCIÓN | nombre_sp |
| `tp` | MODIF | tipo | 🔵 CONVENCIÓN | nombre_sp |
| `?k` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?getne`, `?k` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `graba_spei`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_graba_spei.sql` |
| **LOC (1er CREATE)** | 149 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "graba" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 4 llamada(s): `spobtenerccc`, `spvalidaccc`, `sp_gencverastreo` |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=0 / 2 términos |

### Firma

```sql
CREATE PROCEDURE graba_spei(
  monto                        money(14,2)
  num_cte                      char(20)
  num_ren                      integer
  referencia                   varchar(255)
  pTrans                       char(4)
) RETURNING char(5), char(30)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `monto` | `money(14,2)` | — | — |
| `num_cte` | `char(20)` | — | — |
| `num_ren` | `integer` | — | — |
| `referencia` | `varchar(255)` | — | — |
| `pTrans` | `char(4)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vt_rastreo` | `char(30)` | L30 |
| `vt_cta_cte` | `varchar(20)` | L31 |
| `vt_cliente` | `integer` | L32 |
| `vt_banco` | `char(4)` | L33 |
| `vt_plaza` | `char(5)` | L34 |
| `vt_sucursal` | `char(5)` | L35 |
| `vt_cta_ben` | `char(20)` | L36 |
| `vt_nom_ben` | `char(30)` | L37 |
| `vt_bco_propio` | `char(4)` | L38 |
| `vt_ordenante` | `char(30)` | L39 |
| `vt_comision` | `money(10,2)` | L40 |
| `vt_clabe` | `char(18)` | L41 |
| `vt_FuenteError` | `char(7)` | L42 |
| `vdtfecha` | `date` | L43 |
| `vt_cod_ret` | `char(5)` | L46 |
| `vintcodret` | `INTEGER` | L47 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `convenio_mn` | `terceros` | ⚠️ sí | SELECT | L78 |
| `si_fechas` | `bdinteg` | ⚠️ sí | SELECT | L101 |
| `tblpago` | `bdispei` | no | UPDATE | L138 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `spobtenerccc` | `bditef` | ⚠️ sí | L87 |
| `spvalidaccc` | `bditef` | ⚠️ sí | L91 |
| `sp_gencverastreo` | `bdispei` | no | L104 |
| `sp_regordenpago` | `bdispei` | no | L111 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L86 | VALIDACIÓN_NULL | `IF vt_clabe IS NULL OR TRIM(vt_clabe) = '' THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `graba` | ACCION | graba / almacena | 🔵 CONVENCIÓN | nombre_sp |
| `spei` | PREFIJO | familia SPEI (pagos interbancarios) | 🔵 CONVENCIÓN | nombre_sp |

---

## `pba_cancelacion`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_pba_cancelacion.sql` |
| **LOC (1er CREATE)** | 94 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "cancela (PBA — sufijo de SPs para Pruebas; confirmado por SME)" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — Tokens confirmados en el vocab pero DML no correlaciona con el propósito |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=0 / 2 términos |

### Firma

```sql
CREATE PROCEDURE pba_cancelacion(
) RETURNING CHAR(30)
```

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vCodRet1` | `CHAR(5)` | L4 |
| `vCodRet2` | `CHAR(5)` | L5 |
| `vSqlErr` | `INTEGER` | L6 |
| `vIsamErr` | `INTEGER` | L7 |
| `wempresa` | `CHAR(3)` | L8 |
| `whora` | `CHAR(15)` | L9 |
| `wserial_folio` | `INTEGER` | L10 |
| `wfolio_suc` | `CHAR(30)` | L11 |
| `wcuenta` | `CHAR(20)` | L12 |
| `wnum_tarjeta` | `CHAR(16)` | L13 |
| `wmaxsec` | `SMALLINT` | L14 |
| `wsucursal` | `CHAR(4)` | L15 |
| `wusuario` | `CHAR(8)` | L16 |
| `wtransacc` | `CHAR(4)` | L17 |
| `wtran_suc` | `CHAR(4)` | L18 |
| `wdivisa` | `CHAR(2)` | L19 |
| `wexiste_mov` | `INTEGER` | L20 |
| `wimporte` | `DECIMAL(12,2)` | L21 |
| `cVarDataErr` | `CHAR(100)` | L22 |
| `vtimestamp` | `LVARCHAR(20)` | L23 |
| `wtimestamp` | `CHAR(20)` | L24 |
| `wcomision` | `DECIMAL(14,2)` | L25 |
| `wcadena_val` | `CHAR (1000)` | L27 |
| `codretfirma` | `INTEGER` | L28 |
| `wvchrcodretcodi` | `CHAR(5)` | L29 |
| *…12 más…* | | |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `pba` | MODIF | PBA — sufijo de SPs para Pruebas; confirmado por SME (Guerra | 🔵 CONVENCIÓN | nombre_sp |
| `cancelacion` | ACCION | cancela | 🔵 CONVENCIÓN | nombre_sp |

---

## `reversion`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_reversion.sql` |
| **LOC (1er CREATE)** | 118 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "reversa" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 4 tabla(s) con operaciones: SELECT, UPDATE, DELETE |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=0 · INFERIDO=0 · SINTÉTICO=0 / 1 términos |

### Firma

```sql
CREATE PROCEDURE reversion(
  psucursal                    CHAR(4)
) RETURNING CHAR(5)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `psucursal` | `CHAR(4)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `v_row` | `INTEGER` | L18 |
| `v_statusenv` | `CHAR(1)` | L19 |
| `v_cveaut` | `CHAR(16)` | L20 |
| `v_codret` | `CHAR(5)` | L21 |
| `sql_err` | `INTEGER` | L22 |
| `vchrParametro` | `VARCHAR(255)` | L23 |
| `vchrFechaHoy` | `VARCHAR(10)` | L24 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tblparametros` | `bdispei` | no | SELECT | L43 |
| `tblpago` | `bdispei` | no | SELECT | L55 |
| `tblpago` | `bdispei` | no | DELETE | L66 |
| `tblpago` | `bdispei` | no | UPDATE | L78 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L46 | FÓRMULA | `LET vchrFechaHoy = SUBSTR(vchrParametro,4,2) \|\| '/' \|\|` |  |
| L59 | VALIDACIÓN_NULL | `IF v_cveaut IS NULL OR v_cveaut = "" THEN` |  |
| L92 | VALIDACIÓN_NULL | `IF v_row IS NULL OR v_row = "" OR v_row = 0 THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `reversion` | ACCION | reversa / rollback | ✅ CÓDIGO | nombre_sp, texto_cuerpo |

---

## `sp_abonocanelapago`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_sp_abonocanelapago.sql` |
| **LOC (1er CREATE)** | 246 |
| **Callgraph** | ✅ fan_in=0 / fan_out=2 |
| **Propósito inferido** | "abono y pago" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 2 llamada(s): `cons_saldo`, `abono_ref` |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=1 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_abonocanelapago(
  p_intpkpago                  INTEGER
) RETURNING char(5), integer, money(16,2)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_intpkpago` | `INTEGER` | `pago`=pago | ✅ CÓDIGO |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `v_codret` | `char(5)` | L16 |
| `sql_err` | `integer` | L17 |
| `v_TransAbono` | `char(4)` | L19 |
| `v_TransSuc` | `char(4)` | L20 |
| `v_AbonaCheq` | `char(1)` | L21 |
| `v_SucursalCentral` | `char(4)` | L22 |
| `v_Usuario` | `char(20)` | L23 |
| `v_DivisaMN` | `char(2)` | L24 |
| `v_intcvetipopago` | `integer` | L26 |
| `v_intcvetpoop` | `integer` | L27 |
| `v_intcvetipocuenta` | `integer` | L28 |
| `v_CveTpoOp` | `char(20)` | L29 |
| `v_TpoCta` | `integer` | L30 |
| `v_ClaveRastreo` | `char(30)` | L31 |
| `v_Importe` | `money(16,2)` | L32 |
| `v_chrFolioLiq` | `varchar(16)` | L33 |
| `v_chrEstatusEnvio` | `char(1)` | L34 |
| `v_vchrcverastrorig` | `varchar(30)` | L35 |
| `v_intpkdev` | `integer` | L36 |
| `v_inttipofuncion` | `integer` | L38 |
| `v_spl` | `char(6)` | L40 |
| `v_Cta` | `varchar(20)` | L41 |
| `v_StatusCta` | `char(1)` | L42 |
| `v_sdoccta` | `money(16,2)` | L43 |
| `v_CodErrStr` | `char(5)` | L44 |
| *…10 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tblpago` | `bdispei` | no | SELECT | L92 |
| `tblparametros` | `bdispei` | no | SELECT | L101 |
| `si_empresas` | `bdinteg` | ⚠️ sí | SELECT | L132 |
| `sc_maechq` | `bdicheq` | ⚠️ sí | SELECT | L153 |
| `sc_tarjeta` | `bdicheq` | ⚠️ sí | SELECT | L160 |
| `tbltipopago` | `bdispei` | no | SELECT | L169 |
| `tbltipocuenta` | `bdispei` | no | SELECT | L179 |
| `dual` | `bdinteg` | ⚠️ sí | SELECT | L195 |
| `tblcausadev` | `bdispei` | no | SELECT | L216 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `cons_saldo` | `bdicheq` | ⚠️ sí | L189 |
| `abono_ref` | `bdicheq` | ⚠️ sí | L206 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L105 | FÓRMULA | `LET v_Usuario = SUBSTR(user,v_size-7, v_size);` |  |
| L173 | VALIDACIÓN_NULL | `IF NOT v_intcvetipopago IS NULL THEN` |  |
| L198 | FÓRMULA | `LET v_chrFolioLiq = trim(v_chrFolioLiq)\|\|SUBSTR(trim(v_vchrconceptopago),-2);` |  |
| L230 | FÓRMULA | `LET v_chrFolioLiq = trim(v_chrFolioLiq)\|\|SUBSTR(trim(v_vchrconceptopago),-2);` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `abono` | ENTIDAD | abono / crédito | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?canela` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `pago` | ENTIDAD | pago | ✅ CÓDIGO | nombre_sp, texto_cuerpo |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?canela` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_abonoordauto`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_sp_abonoordauto.sql` |
| **LOC (1er CREATE)** | 62 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "abono y ordenante (automático)" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 1 llamada(s): `sp_abonoordpago` |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=2 · INFERIDO=1 · SINTÉTICO=0 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_abonoordauto(
  pFechaValor                  date
) RETURNING char(5)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pFechaValor` | `date` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `v_codret` | `char(5)` | L16 |
| `v_monto_abo` | `money(16,2)` | L17 |
| `sql_err` | `integer` | L18 |
| `vintPkPago` | `integer` | L19 |
| `vcausadev` | `INTEGER` | L20 |
| `vmotivo` | `CHAR(40)` | L21 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `vabono` | `bdispei` | no | SELECT | L48 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_abonoordpago` | `bdispei` | no | L53 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `abono` | ENTIDAD | abono / crédito | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `ord` | ENTIDAD | ordenante / orden (SPEI) | 🔵 CONVENCIÓN | nombre_sp |
| `auto` | MODIF | automático (proceso automático / batch — sp_*_auto) | 🟡 INFERIDO | nombre_sp |

---

## `sp_abonoordpago`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_sp_abonoordpago.sql` |
| **LOC (1er CREATE)** | 444 |
| **Callgraph** | ✅ fan_in=1 / fan_out=3 |
| **Propósito inferido** | "abono, ordenante y pago" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 3 llamada(s): `sp_generadevpago`, `cons_saldo`, `abono_ref` |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=0 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_abonoordpago(
  p_intpkpago                  integer
) RETURNING char(5), integer, char(40)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_intpkpago` | `integer` | `pago`=pago | ✅ CÓDIGO |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `v_codret` | `char(5)` | L16 |
| `v_monto_abo` | `money(16,2)` | L17 |
| `sql_err` | `integer` | L18 |
| `v_TransAbono` | `char(4)` | L20 |
| `v_TransSuc` | `char(4)` | L21 |
| `v_AbonaCheq` | `char(1)` | L22 |
| `v_SucursalCentral` | `char(4)` | L23 |
| `v_Usuario` | `char(20)` | L24 |
| `v_DivisaMN` | `char(2)` | L25 |
| `v_intcvetipopago` | `integer` | L27 |
| `v_intcvetpoop` | `integer` | L28 |
| `v_intcvetipocuenta` | `integer` | L29 |
| `v_CveTpoOp` | `char(20)` | L30 |
| `v_TpoCta` | `integer` | L31 |
| `v_CtaBenef` | `char(20)` | L32 |
| `v_NombreBenef` | `char(40)` | L33 |
| `v_ClaveRastreo` | `char(30)` | L34 |
| `v_Importe` | `money(16,2)` | L35 |
| `v_chrFolioLiq` | `varchar(16)` | L36 |
| `v_chrEstatusEnvio` | `char(1)` | L37 |
| `v_vchrcverastrorig` | `varchar(30)` | L38 |
| `v_intpkdev` | `integer` | L39 |
| `v_intpkctabansi` | `integer` | L41 |
| `v_intcvetpopagobsi` | `integer` | L42 |
| `v_intcvetpoopbsi` | `integer` | L43 |
| *…21 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tblpago` | `bdispei` | no | SELECT | L115 |
| `tblparametros` | `bdispei` | no | SELECT | L124 |
| `si_empresas` | `bdinteg` | ⚠️ sí | SELECT | L160 |
| `tbltipopago` | `bdispei` | no | SELECT | L178 |
| `tbltipocuenta` | `bdispei` | no | SELECT | L195 |
| `sc_maechq` | `bdicheq` | ⚠️ sí | SELECT | L239 |
| `sc_ctabloqueo` | `bdicheq` | ⚠️ sí | SELECT | L263 |
| `tblctabansi` | `bdispei` | no | SELECT | L287 |
| `dual` | `bdinteg` | ⚠️ sí | SELECT | L307 |
| `tblcausadev` | `bdispei` | no | SELECT | L332 |
| `tbltipooperacion` | `bdispei` | no | SELECT | L392 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_generadevpago` | `bdispei` | no | L206 |
| `cons_saldo` | `bdicheq` | ⚠️ sí | L300 |
| `abono_ref` | `bdicheq` | ⚠️ sí | L317 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L132 | FÓRMULA | `LET v_Usuario = SUBSTR(user,v_size-7, v_size);` |  |
| L223 | VALIDACIÓN_NULL | `IF NOT v_intcvetipopago IS NULL THEN` |  |
| L254 | VALIDACIÓN_NULL | `IF v_Cta = "" OR v_Cta IS NULL THEN` |  |
| L289 | VALIDACIÓN_NULL | `IF NOT v_intpkctabansi IS NULL THEN` |  |
| L309 | FÓRMULA | `LET v_chrFolioLiq = trim(v_chrFolioLiq)\|\|SUBSTR(trim(v_vchrconceptopago),-2);` |  |
| L335 | VALIDACIÓN_NULL | `IF NOT v_CodErrStr IS NULL THEN` |  |
| L362 | VALIDACIÓN_NULL | `IF NOT v_CodErrStr IS NULL THEN` |  |
| L389 | VALIDACIÓN_NULL | `IF NOT v_intcvetpoop IS NULL OR trim(v_intcvetpoop) <> "" THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `abono` | ENTIDAD | abono / crédito | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `ord` | ENTIDAD | ordenante / orden (SPEI) | 🔵 CONVENCIÓN | nombre_sp |
| `pago` | ENTIDAD | pago | ✅ CÓDIGO | nombre_sp, texto_cuerpo |

---

## `sp_actbancont`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_sp_actbancont.sql` |
| **LOC (1er CREATE)** | 80 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 4 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "actualiza banco" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `actualiza` → `UPDATE` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=1 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_actbancont(
  v_fecha                      DATE
  v_usuario                    VARCHAR(8)
  v_bandera                    INT
) RETURNING CHAR(5)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `v_fecha` | `DATE` | — | — |
| `v_usuario` | `VARCHAR(8)` | — | — |
| `v_bandera` | `INT` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vchrcod_ret` | `CHAR(5)` | L4 |
| `sql_err` | `INTEGER` | L5 |
| `vintflag` | `INTEGER` | L6 |
| `verror_info` | `VARCHAR(100)` | L7 |
| `vintflag_param` | `INTEGER` | L8 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tblparametros` | `bdispei` | no | SELECT | L43 |
| `tblbitalertaspei` | `bdispei` | no | INSERT | L58 |
| `tblparametros` | `bdispei` | no | UPDATE | L60 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L26 | VALIDACIÓN_NULL | `IF (v_fecha IS NULL  OR v_fecha != TODAY OR v_fecha = '') THEN` |  |
| L30 | VALIDACIÓN_NULL | `IF (v_usuario IS NULL OR v_usuario = '') THEN` |  |
| L34 | VALIDACIÓN_NULL | `IF (v_bandera IS NULL OR v_bandera = '') THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `act` | ACCION | actualiza | 🔵 CONVENCIÓN | nombre_sp |
| `banco` | ENTIDAD | banco | 🔵 CONVENCIÓN | nombre_sp |
| `?nt` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?nt` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_actenviopago`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_sp_actenviopago.sql` |
| **LOC (1er CREATE)** | 51 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "actualiza pago" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `actualiza` → `UPDATE` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=4 · INFERIDO=0 · SINTÉTICO=0 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_actenviopago(
  pRowId                       INTEGER
  pintFolioPaquete             INTEGER
  pintFolioPago                INTEGER
) RETURNING CHAR(5)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pRowId` | `INTEGER` | — | — |
| `pintFolioPaquete` | `INTEGER` | — | — |
| `pintFolioPago` | `INTEGER` | `pago`=pago | 🔵 CONVENCIÓN |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `codret` | `CHAR(5)` | L4 |
| `sql_err` | `INTEGER` | L5 |
| `vdtFechaOp` | `DATE` | L6 |
| `vintPkPaqueteEnv` | `INTEGER` | L7 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tblparametros` | `bdispei` | no | SELECT | L21 |
| `tblpaqueteenv` | `bdispei` | no | SELECT | L25 |
| `tblpago` | `bdispei` | no | UPDATE | L41 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L31 | VALIDACIÓN_NULL | `IF vintPkPaqueteEnv IS NULL THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `act` | ACCION | actualiza | 🔵 CONVENCIÓN | nombre_sp |
| `envio` | ACCION | envía | 🔵 CONVENCIÓN | nombre_sp |
| `pago` | ENTIDAD | pago | 🔵 CONVENCIÓN | nombre_sp |

---

## `sp_actestenvspei`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_sp_actestenvspei.sql` |
| **LOC (1er CREATE)** | 51 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "actualiza" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `actualiza` → `UPDATE` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=1 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_actestenvspei(
) RETURNING CHAR(5)
```

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vcodret1` | `CHAR(5)` | L4 |
| `vcodret2` | `CHAR(5)` | L5 |
| `vcodret3` | `CHAR(50)` | L6 |
| `sql_err` | `INTEGER` | L7 |
| `isam_err` | `INTEGER` | L8 |
| `desc_err` | `CHAR(50)` | L9 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tblpago` | `bdispei` | no | UPDATE | L39 |
| `sc_movdia` | `bdicheq` | ⚠️ sí | SELECT | L42 |
| `tblparametros` | `bdispei` | no | SELECT | L43 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `act` | ACCION | actualiza | 🔵 CONVENCIÓN | nombre_sp |
| `?estenv` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `spei` | PREFIJO | familia SPEI (pagos interbancarios) | 🔵 CONVENCIÓN | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?estenv` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_actfolacustrasp`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_sp_actfolacustrasp.sql` |
| **LOC (1er CREATE)** | 45 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "actualiza" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `actualiza` → `UPDATE` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=1 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_actfolacustrasp(
  pintFolioServidor            INTEGER
  pintFolioTraspaso            INTEGER
) RETURNING CHAR(5)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pintFolioServidor` | `INTEGER` | — | — |
| `pintFolioTraspaso` | `INTEGER` | `sp`=stored procedure · `sp`=stored procedure | 🔵 CONVENCIÓN |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `codret` | `CHAR(5)` | L4 |
| `sql_err` | `INTEGER` | L5 |
| `vdtFechaOp` | `DATE` | L6 |
| `vintPkTraspaso` | `INTEGER` | L7 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tblparametros` | `bdispei` | no | SELECT | L21 |
| `tbltraspaso` | `bdispei` | no | SELECT | L25 |
| `tbltraspaso` | `bdispei` | no | UPDATE | L36 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L30 | VALIDACIÓN_NULL | `IF vintpkTraspaso IS NULL THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `act` | ACCION | actualiza | 🔵 CONVENCIÓN | nombre_sp |
| `?folacustra` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?folacustra` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_actfolioacuse`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_sp_actfolioacuse.sql` |
| **LOC (1er CREATE)** | 51 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "actualiza folio" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `actualiza` → `UPDATE` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=1 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_actfolioacuse(
  pintFolioServidor            INTEGER
  pintFolioPaquete             INTEGER
) RETURNING CHAR(5)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pintFolioServidor` | `INTEGER` | `folio`=folio | ✅ CÓDIGO |
| `pintFolioPaquete` | `INTEGER` | `folio`=folio | ✅ CÓDIGO |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `codret` | `CHAR(5)` | L4 |
| `sql_err` | `INTEGER` | L5 |
| `vdtFechaOp` | `DATE` | L6 |
| `vintPkPaqueteEnv` | `INTEGER` | L7 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tblparametros` | `bdispei` | no | SELECT | L21 |
| `tblpaqueteenv` | `bdispei` | no | SELECT | L25 |
| `tblpaqueteenv` | `bdispei` | no | UPDATE | L37 |
| `tblpago` | `bdispei` | no | UPDATE | L43 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L31 | VALIDACIÓN_NULL | `IF vintPkPaqueteEnv IS NULL THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `act` | ACCION | actualiza | 🔵 CONVENCIÓN | nombre_sp |
| `folio` | ENTIDAD | folio | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?acuse` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?acuse` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_acthorarios`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_sp_acthorarios.sql` |
| **LOC (1er CREATE)** | 46 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "actualiza hora" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `actualiza` → `UPDATE` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=1 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_acthorarios(
  phoraini                     char(8)
  phorafin                     char(8)
) RETURNING CHAR(5)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `phoraini` | `char(8)` | `hora`=hora | 🔵 CONVENCIÓN |
| `phorafin` | `char(8)` | `hora`=hora | 🔵 CONVENCIÓN |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vCodRet1` | `CHAR(5)` | L5 |
| `vCodRet2` | `CHAR(5)` | L6 |
| `vSqlErr` | `INTEGER` | L7 |
| `vIsamErr` | `INTEGER` | L8 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `act` | ACCION | actualiza | 🔵 CONVENCIÓN | nombre_sp |
| `hora` | ENTIDAD | hora | 🔵 CONVENCIÓN | nombre_sp |
| `?rios` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?rios` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_actualiza_credspei`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_sp_actualiza_credspei.sql` |
| **LOC (1er CREATE)** | 90 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "actualiza crédito" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `actualiza` → `UPDATE` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=4 · INFERIDO=0 · SINTÉTICO=0 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_actualiza_credspei(
  pCveRastreo                  CHAR(30)
  pMontoPago                   CHAR(18)
  pCtaClabe                    CHAR(18)
  pCodRet                      CHAR(20)
  pClaveBM                     CHAR(3)
  pCodError                    CHAR(5)
  pDescError                   CHAR(100)
  pCteCentral                  CHAR(20)
  pCteOrion                    CHAR(15)
  pRFC                         CHAR(13)
  pNombreCte                   CHAR(40)
) RETURNING CHAR(5)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pCveRastreo` | `CHAR(30)` | — | — |
| `pMontoPago` | `CHAR(18)` | — | — |
| `pCtaClabe` | `CHAR(18)` | — | — |
| `pCodRet` | `CHAR(20)` | — | — |
| `pClaveBM` | `CHAR(3)` | — | — |
| `pCodError` | `CHAR(5)` | — | — |
| `pDescError` | `CHAR(100)` | — | — |
| `pCteCentral` | `CHAR(20)` | — | — |
| `pCteOrion` | `CHAR(15)` | — | — |
| `pRFC` | `CHAR(13)` | — | — |
| `pNombreCte` | `CHAR(40)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(5)` | L14 |
| `cCodRet2` | `CHAR(5)` | L15 |
| `cCodRet3` | `CHAR(5)` | L16 |
| `iSqlErr` | `INTEGER` | L17 |
| `iSamErr` | `INTEGER` | L18 |
| `cDesErr` | `CHAR(50)` | L19 |
| `cStatus` | `CHAR(1)` | L20 |
| `vCodRet` | `INTEGER` | L21 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L51 | VALIDACIÓN_NULL | `IF ( ( pCveRastreo is null OR pCveRastreo = '' ) OR` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `actualiza` | ACCION | actualiza | 🔵 CONVENCIÓN | nombre_sp |
| `cred` | ENTIDAD | crédito | 🔵 CONVENCIÓN | nombre_sp |
| `spei` | PREFIJO | familia SPEI (pagos interbancarios) | 🔵 CONVENCIÓN | nombre_sp |

---

## `sp_actualiza_msjs_spei`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_sp_actualiza_msjs_spei.sql` |
| **LOC (1er CREATE)** | 129 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "actualiza mensaje — abreviación corta de mnsj" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `actualiza` → `UPDATE` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=1 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_actualiza_msjs_spei(
  pempresa                     CHAR(3)
) RETURNING CHAR(5), INTEGER
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pempresa` | `CHAR(3)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet1` | `CHAR(5)` | L4 |
| `cCodRet2` | `CHAR(5)` | L5 |
| `cCodRet3` | `CHAR(80)` | L6 |
| `sql_err` | `INTEGER` | L7 |
| `isam_err` | `INTEGER` | L8 |
| `desc_err` | `CHAR(80)` | L9 |
| `iContador1` | `INTEGER` | L10 |
| `iContador2` | `INTEGER` | L11 |
| `iComienza` | `SMALLINT` | L12 |
| `iTransacc` | `SMALLINT` | L13 |
| `dFechaHoy` | `DATE` | L15 |
| `cNumCte` | `CHAR(20)` | L16 |
| `cTipoMsj` | `CHAR(1)` | L17 |
| `cStr1` | `CHAR(30)` | L18 |
| `cStr2` | `CHAR(30)` | L19 |
| `cStr3` | `CHAR(30)` | L20 |
| `cStr4` | `CHAR(30)` | L21 |
| `cStr5` | `CHAR(150)` | L22 |
| `dFecha1` | `DATETIME YEAR TO FRACTION(3)` | L23 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sc_fechas` | `bdicheq` | ⚠️ sí | SELECT | L70 |
| `tbl_registro_msj` | `bdispei` | no | SELECT | L77 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L33 | FÓRMULA | `LET iComienza    = -1;` |  |
| L101 | FÓRMULA | `LET iContador1 = iContador1 + 1;` |  |
| L102 | FÓRMULA | `LET iContador2 = iContador2 + 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `actualiza` | ACCION | actualiza | 🔵 CONVENCIÓN | nombre_sp |
| `msj` | ENTIDAD | mensaje — abreviación corta de mnsj (sp_validacion_msj) | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `?s_` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `spei` | PREFIJO | familia SPEI (pagos interbancarios) | 🔵 CONVENCIÓN | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?s_` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_alertacargospei`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_sp_alertacargospei.sql` |
| **LOC (1er CREATE)** | 150 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "alerta y cargo" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 8 tabla(s) con operaciones: INSERT, UPDATE, SELECT |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=0 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_alertacargospei(
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
| `vcodret1` | `CHAR(5)` | L4 |
| `vcodret2` | `CHAR(5)` | L5 |
| `vcodret3` | `CHAR(80)` | L6 |
| `sql_err` | `INTEGER` | L7 |
| `isam_err` | `INTEGER` | L8 |
| `desc_err` | `CHAR(80)` | L9 |
| `vcontador1` | `INTEGER` | L10 |
| `vcontador2` | `INTEGER` | L11 |
| `vcomienza` | `SMALLINT` | L12 |
| `ven_transacc` | `SMALLINT` | L13 |
| `vclave_rastreo` | `CHAR(30)` | L14 |
| `vsql` | `CHAR(150)` | L15 |
| `vstmt` | `CHAR(100)` | L16 |
| `vmailx` | `CHAR(250)` | L17 |
| `vexiste_movdia` | `SMALLINT` | L18 |
| `vexiste_movhis` | `SMALLINT` | L19 |
| `vfecha_hoy` | `DATE` | L20 |
| `vfecha_ant` | `DATE` | L21 |
| `vprox_fecha` | `DATE` | L22 |
| `vfecha_ant2` | `DATE` | L23 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `cargosspei` | `bdispei` | no | INSERT | L67 |
| `statistics` | `bdispei` | no | UPDATE | L73 |
| `sc_fechas` | `bdicheq` | ⚠️ sí | SELECT | L77 |
| `cargosspei` | `bdispei` | no | SELECT | L87 |
| `cargosspeihist` | `bdispei` | no | SELECT | L88 |
| `sc_movdia` | `bdicheq` | ⚠️ sí | SELECT | L99 |
| `sc_movhis` | `bdicheq` | ⚠️ sí | SELECT | L109 |
| `cargosspeihist` | `bdispei` | no | INSERT | L121 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L33 | FÓRMULA | `LET vcomienza      = -1;` |  |
| L80 | FÓRMULA | `LET vfecha_ant2 = (vfecha_ant - 2 UNITS DAY);` |  |
| L81 | FÓRMULA | `LET vprox_fecha = (vfecha_hoy + 2 UNITS DAY);` |  |
| L130 | FÓRMULA | `LET vcontador1 = vcontador1 + 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `alerta` | ENTIDAD | alerta | 🔵 CONVENCIÓN | nombre_sp |
| `cargo` | ENTIDAD | cargo / débito | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `spei` | PREFIJO | familia SPEI (pagos interbancarios) | ✅ CÓDIGO | nombre_sp, texto_cuerpo |

---

## `sp_alertacargospei_exp1`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_sp_alertacargospei_exp1.sql` |
| **LOC (1er CREATE)** | 170 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "alerta y cargo (sufijo Exportar — SP genera/exporta archivo de salida)" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `genera` → `INSERT` encontrado en el cuerpo · `genera` → `SELECT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=2 · INFERIDO=1 · SINTÉTICO=1 / 6 términos |

### Firma

```sql
CREATE PROCEDURE sp_alertacargospei_exp1(
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
| `vcodret1` | `CHAR(5)` | L4 |
| `vcodret2` | `CHAR(5)` | L5 |
| `vcodret3` | `CHAR(80)` | L6 |
| `sql_err` | `INTEGER` | L7 |
| `isam_err` | `INTEGER` | L8 |
| `desc_err` | `CHAR(80)` | L9 |
| `vcontador1` | `INTEGER` | L10 |
| `vcontador2` | `INTEGER` | L11 |
| `vcomienza` | `SMALLINT` | L12 |
| `ven_transacc` | `SMALLINT` | L13 |
| `vclave_rastreo` | `CHAR(30)` | L14 |
| `vsql` | `CHAR(150)` | L15 |
| `vstmt` | `CHAR(100)` | L16 |
| `vmailx` | `CHAR(250)` | L17 |
| `vexiste_movdia` | `SMALLINT` | L18 |
| `vexiste_movhis` | `SMALLINT` | L19 |
| `vexiste_tabla` | `SMALLINT` | L20 |
| `vfecha_hoy` | `DATE` | L21 |
| `vfecha_ant` | `DATE` | L22 |
| `vprox_fecha` | `DATE` | L23 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `systabnames` | `sysmaster` | ⚠️ sí | SELECT | L69 |
| `cargosspei` | `bdispei` | no | INSERT | L87 |
| `statistics` | `bdispei` | no | UPDATE | L93 |
| `sc_fechas` | `bdicheq` | ⚠️ sí | SELECT | L97 |
| `cargosspei` | `bdispei` | no | SELECT | L104 |
| `cargosspeihist` | `bdispei` | no | SELECT | L105 |
| `sc_movdia` | `bdicheq` | ⚠️ sí | SELECT | L116 |
| `sc_movhis` | `bdicheq` | ⚠️ sí | SELECT | L128 |
| `cargosspeihist` | `bdispei` | no | INSERT | L143 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L33 | FÓRMULA | `LET vcomienza      = -1;` |  |
| L150 | FÓRMULA | `LET vcontador1 = vcontador1 + 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `alerta` | ENTIDAD | alerta | 🔵 CONVENCIÓN | nombre_sp |
| `cargo` | ENTIDAD | cargo / débito | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `spei` | PREFIJO | familia SPEI (pagos interbancarios) | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `exp` | MODIF | sufijo Exportar — SP genera/exporta archivo de salida (sp_*_ | 🟡 INFERIDO | nombre_sp |
| `?1` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?1` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_alertacargospei_pba`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_sp_alertacargospei_pba.sql` |
| **LOC (1er CREATE)** | 148 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "alerta y cargo (PBA — sufijo de SPs para Pruebas; confirmado por SME)" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `confirma` → `SELECT` encontrado en el cuerpo · `confirma` → `UPDATE` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=0 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_alertacargospei_pba(
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
| `vcodret1` | `CHAR(5)` | L4 |
| `vcodret2` | `CHAR(5)` | L5 |
| `vcodret3` | `CHAR(80)` | L6 |
| `sql_err` | `INTEGER` | L7 |
| `isam_err` | `INTEGER` | L8 |
| `desc_err` | `CHAR(80)` | L9 |
| `vcontador1` | `INTEGER` | L10 |
| `vcontador2` | `INTEGER` | L11 |
| `vcomienza` | `SMALLINT` | L12 |
| `ven_transacc` | `SMALLINT` | L13 |
| `vclave_rastreo` | `CHAR(30)` | L14 |
| `vsql` | `CHAR(150)` | L15 |
| `vstmt` | `CHAR(100)` | L16 |
| `vmailx` | `CHAR(250)` | L17 |
| `vexiste_movdia` | `SMALLINT` | L18 |
| `vexiste_movhis` | `SMALLINT` | L19 |
| `vfecha_hoy` | `DATE` | L20 |
| `vfecha_ant` | `DATE` | L21 |
| `vprox_fecha` | `DATE` | L22 |
| `vfecha_ant2` | `DATE` | L23 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `cargosspei` | `bdispei` | no | INSERT | L67 |
| `statistics` | `bdispei` | no | UPDATE | L73 |
| `sc_fechas` | `bdicheq` | ⚠️ sí | SELECT | L77 |
| `cargosspei` | `bdispei` | no | SELECT | L87 |
| `cargosspeihist` | `bdispei` | no | SELECT | L88 |
| `sc_movdia` | `bdicheq` | ⚠️ sí | SELECT | L99 |
| `sc_movhis` | `bdicheq` | ⚠️ sí | SELECT | L108 |
| `cargosspeihist` | `bdispei` | no | INSERT | L121 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L33 | FÓRMULA | `LET vcomienza      = -1;` |  |
| L80 | FÓRMULA | `LET vfecha_ant2 = (vfecha_ant - 4 UNITS DAY);` |  |
| L81 | FÓRMULA | `LET vprox_fecha = (vfecha_hoy + 4 UNITS DAY);` |  |
| L128 | FÓRMULA | `LET vcontador1 = vcontador1 + 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `alerta` | ENTIDAD | alerta | 🔵 CONVENCIÓN | nombre_sp |
| `cargo` | ENTIDAD | cargo / débito | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `spei` | PREFIJO | familia SPEI (pagos interbancarios) | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `pba` | MODIF | PBA — sufijo de SPs para Pruebas; confirmado por SME (Guerra | 🔵 CONVENCIÓN | nombre_sp |

---

## `sp_alertas_codi`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_sp_alertas_codi.sql` |
| **LOC (1er CREATE)** | 99 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "alertas · CoDi — Cobro Digital" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 1 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=0 / 3 términos |

### Firma

```sql
CREATE PROCEDURE sp_alertas_codi(
) RETURNING CHAR(5), CHAR(150)
```

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `Sql_Err` | `INTEGER` | L4 |
| `Isam_Err` | `INTEGER` | L5 |
| `Desc_Err` | `CHAR(50)` | L6 |
| `cCodRet1` | `CHAR(5)` | L7 |
| `cCodRet2` | `CHAR(5)` | L8 |
| `cCodRet3` | `CHAR(50)` | L9 |
| `iContador1` | `INTEGER` | L10 |
| `iContador2` | `INTEGER` | L11 |
| `iContador3` | `INTEGER` | L12 |
| `iComienza` | `SMALLINT` | L13 |
| `cAbierto` | `CHAR(1)` | L14 |
| `iOperAbono` | `INTEGER` | L15 |
| `iLimAbonos` | `INTEGER` | L16 |
| `iOperCargo` | `INTEGER` | L17 |
| `iLimCargos` | `INTEGER` | L18 |
| `cMensaje` | `CHAR(150)` | L19 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sc_movdia` | `bdispei` | no | SELECT | L60 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L30 | FÓRMULA | `LET iComienza   = -1;` |  |
| L65 | VALIDACIÓN_NULL | `IF iOperAbono is null THEN` |  |
| L77 | VALIDACIÓN_NULL | `IF iOperCargo is null THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `alertas` | ENTIDAD | alertas | 🔵 CONVENCIÓN | nombre_sp |
| `codi` | REG | CoDi — Cobro Digital (Banxico) | ✅ CÓDIGO | nombre_sp, texto_cuerpo |

---

## `sp_alertasabonospei`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_sp_alertasabonospei.sql` |
| **LOC (1er CREATE)** | 150 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "alertas y abono" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 8 tabla(s) con operaciones: INSERT, UPDATE, SELECT |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=0 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_alertasabonospei(
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
| `vcodret1` | `CHAR(5)` | L4 |
| `vcodret2` | `CHAR(5)` | L5 |
| `vcodret3` | `CHAR(80)` | L6 |
| `sql_err` | `INTEGER` | L7 |
| `isam_err` | `INTEGER` | L8 |
| `desc_err` | `CHAR(80)` | L9 |
| `vcontador1` | `INTEGER` | L10 |
| `vcontador2` | `INTEGER` | L11 |
| `vcomienza` | `SMALLINT` | L12 |
| `ven_transacc` | `SMALLINT` | L13 |
| `vclave_rastreo` | `CHAR(30)` | L14 |
| `vsql` | `CHAR(150)` | L15 |
| `vstmt` | `CHAR(100)` | L16 |
| `vmailx` | `CHAR(250)` | L17 |
| `vexiste_movdia` | `SMALLINT` | L18 |
| `vexiste_movhis` | `SMALLINT` | L19 |
| `vfecha_hoy` | `DATE` | L20 |
| `vfecha_ant` | `DATE` | L21 |
| `vprox_fecha` | `DATE` | L22 |
| `vfecha_ant2` | `DATE` | L23 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `abonospei` | `bdispei` | no | INSERT | L67 |
| `statistics` | `bdispei` | no | UPDATE | L73 |
| `sc_fechas` | `bdicheq` | ⚠️ sí | SELECT | L77 |
| `abonospei` | `bdispei` | no | SELECT | L87 |
| `abonospeihist` | `bdispei` | no | SELECT | L88 |
| `sc_movdia` | `bdicheq` | ⚠️ sí | SELECT | L99 |
| `sc_movhis` | `bdicheq` | ⚠️ sí | SELECT | L109 |
| `abonospeihist` | `bdispei` | no | INSERT | L121 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L33 | FÓRMULA | `LET vcomienza      = -1;` |  |
| L80 | FÓRMULA | `LET vfecha_ant2 = (vfecha_ant - 2 UNITS DAY);` |  |
| L81 | FÓRMULA | `LET vprox_fecha = (vfecha_hoy + 2 UNITS DAY);` |  |
| L130 | FÓRMULA | `LET vcontador1 = vcontador1 + 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `alertas` | ENTIDAD | alertas | 🔵 CONVENCIÓN | nombre_sp |
| `abono` | ENTIDAD | abono / crédito | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `spei` | PREFIJO | familia SPEI (pagos interbancarios) | ✅ CÓDIGO | nombre_sp, texto_cuerpo |

---

## `sp_alertasabonosspei`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_sp_alertasabonosspei.sql` |
| **LOC (1er CREATE)** | 150 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "alertas y abono" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 8 tabla(s) con operaciones: INSERT, UPDATE, SELECT |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=1 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_alertasabonosspei(
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
| `vcodret1` | `CHAR(5)` | L4 |
| `vcodret2` | `CHAR(5)` | L5 |
| `vcodret3` | `CHAR(80)` | L6 |
| `sql_err` | `INTEGER` | L7 |
| `isam_err` | `INTEGER` | L8 |
| `desc_err` | `CHAR(80)` | L9 |
| `vcontador1` | `INTEGER` | L10 |
| `vcontador2` | `INTEGER` | L11 |
| `vcomienza` | `SMALLINT` | L12 |
| `ven_transacc` | `SMALLINT` | L13 |
| `vclave_rastreo` | `CHAR(30)` | L14 |
| `vsql` | `CHAR(150)` | L15 |
| `vstmt` | `CHAR(100)` | L16 |
| `vmailx` | `CHAR(250)` | L17 |
| `vexiste_movdia` | `SMALLINT` | L18 |
| `vexiste_movhis` | `SMALLINT` | L19 |
| `vfecha_hoy` | `DATE` | L20 |
| `vfecha_ant` | `DATE` | L21 |
| `vprox_fecha` | `DATE` | L22 |
| `vfecha_ant2` | `DATE` | L23 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `abonospei` | `bdispei` | no | INSERT | L67 |
| `statistics` | `bdispei` | no | UPDATE | L73 |
| `sc_fechas` | `bdicheq` | ⚠️ sí | SELECT | L77 |
| `abonosspei` | `bdispei` | no | SELECT | L87 |
| `abonospeihist` | `bdispei` | no | SELECT | L88 |
| `sc_movdia` | `bdicheq` | ⚠️ sí | SELECT | L99 |
| `sc_movhis` | `bdicheq` | ⚠️ sí | SELECT | L109 |
| `abonospeihist` | `bdispei` | no | INSERT | L121 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L33 | FÓRMULA | `LET vcomienza      = -1;` |  |
| L80 | FÓRMULA | `LET vfecha_ant2 = (vfecha_ant - 2 UNITS DAY);` |  |
| L81 | FÓRMULA | `LET vprox_fecha = (vfecha_hoy + 2 UNITS DAY);` |  |
| L130 | FÓRMULA | `LET vcontador1 = vcontador1 + 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `alertas` | ENTIDAD | alertas | 🔵 CONVENCIÓN | nombre_sp |
| `abono` | ENTIDAD | abono / crédito | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?s` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `spei` | PREFIJO | familia SPEI (pagos interbancarios) | ✅ CÓDIGO | nombre_sp, texto_cuerpo |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?s` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_altactaspei`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_sp_altactaspei.sql` |
| **LOC (1er CREATE)** | 70 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 2 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "da de alta cuentas" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 4 tabla(s) con operaciones: INSERT, SELECT, UPDATE |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=1 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_altactaspei(
  pNoCuentaClabe               CHAR(18)
  pUsuario                     CHAR(8)
) RETURNING CHAR(5) AS codret
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pNoCuentaClabe` | `CHAR(18)` | — | — |
| `pUsuario` | `CHAR(8)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(5)` | L4 |
| `iSqlErr` | `INTEGER` | L5 |
| `cBanco` | `CHAR(3)` | L6 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tblclabebloqueo` | `bdispei` | no | SELECT | L29 |
| `tblclabebloqueo` | `bdispei` | no | UPDATE | L37 |
| `si_bancos` | `bdinteg` | ⚠️ sí | SELECT | L49 |
| `tblclabebloqueo` | `bdispei` | no | INSERT | L51 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L8 | CÓDIGO_RETORNO | `LET cCodRet     = '00000';` |  |
| L24 | CÓDIGO_RETORNO | `LET cCodRet = '00003';` |  |
| L30 | CÓDIGO_RETORNO | `LET cCodRet = '00102';` |  |
| L54 | CÓDIGO_RETORNO | `LET cCodRet = '00101';			RETURN cCodRet;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `alta` | ACCION | da de alta / registra | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `ctas` | ENTIDAD | cuentas | 🔵 CONVENCIÓN | nombre_sp |
| `?pei` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?pei` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_bajactaspei`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_sp_bajactaspei.sql` |
| **LOC (1er CREATE)** | 57 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 1 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "cuentas (de baja)" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 2 tabla(s) con operaciones: SELECT, UPDATE |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=1 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_bajactaspei(
  pNoCuentaClabe               CHAR(18)
  pUsuario                     CHAR(8)
) RETURNING CHAR(5) AS codret
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pNoCuentaClabe` | `CHAR(18)` | — | — |
| `pUsuario` | `CHAR(8)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(5)` | L4 |
| `iSqlErr` | `INTEGER` | L5 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tblclabebloqueo` | `bdispei` | no | SELECT | L27 |
| `tblclabebloqueo` | `bdispei` | no | UPDATE | L35 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L7 | CÓDIGO_RETORNO | `LET cCodRet     = '00000';` |  |
| L22 | CÓDIGO_RETORNO | `LET cCodRet = '00003';` |  |
| L28 | CÓDIGO_RETORNO | `LET cCodRet = '00102';` |  |
| L42 | CÓDIGO_RETORNO | `LET cCodRet = '00103';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `baja` | MODIF | de baja | 🔵 CONVENCIÓN | nombre_sp |
| `ctas` | ENTIDAD | cuentas | 🔵 CONVENCIÓN | nombre_sp |
| `?pei` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?pei` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_borra_operaciones`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_sp_borra_operaciones.sql` |
| **LOC (1er CREATE)** | 85 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "operaciones" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 2 tabla(s) con operaciones: SELECT, DELETE |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=1 / 3 términos |

### Firma

```sql
CREATE PROCEDURE sp_borra_operaciones(
  pfecha                       DATE
) RETURNING CHAR(5), INTEGER
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pfecha` | `DATE` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vcodret1` | `CHAR(5)` | L4 |
| `vcodret2` | `CHAR(5)` | L5 |
| `vcodret3` | `CHAR(50)` | L6 |
| `sql_err` | `INTEGER` | L7 |
| `isam_err` | `INTEGER` | L8 |
| `desc_err` | `CHAR(50)` | L9 |
| `vContador1` | `INTEGER` | L10 |
| `vContador2` | `INTEGER` | L11 |
| `vComienza` | `SMALLINT` | L12 |
| `vAbierto` | `CHAR(1)` | L13 |
| `wvchrclaverastreo` | `VARCHAR(30,0)` | L14 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tblhistpago` | `bdispei` | no | SELECT | L53 |
| `tblhistpago` | `bdispei` | no | DELETE | L62 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L23 | FÓRMULA | `LET vComienza          = -1;` |  |
| L66 | FÓRMULA | `LET vcontador1 = vcontador1 + 1;` |  |
| L67 | FÓRMULA | `LET vcontador2 = vcontador2 + 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `?_borra_` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `operaciones` | ENTIDAD | operaciones (plural) | 🔵 CONVENCIÓN | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_borra_` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_calc_com`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_sp_calc_com.sql` |
| **LOC (1er CREATE)** | 63 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "[polisemia] Cálculo y Comisión bancaria — cobro de comisión sobre cuenta" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 2 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=2 · INFERIDO=1 · SINTÉTICO=1 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_calc_com(
  p_sucursal                   char(4)
  p_importe                    money(16,2)
  p_hora_local                 datetime hour to second
) RETURNING char(5),
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_sucursal` | `char(4)` | — | — |
| `p_importe` | `money(16,2)` | — | — |
| `p_hora_local` | `datetime hour to second` | `cal`=[polisemia] Cálculo (cal_fecha, cal_riesgo_cliente, cal_tradicion — operaciones matemáticas financieras) | Calendario (cal_habil_ant — días hábiles bancarios; bdicheq) | 🟡 INFERIDO |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `v_comision` | `money(14,2)` | L17 |
| `v_ivacom` | `money(14,2)` | L18 |
| `v_iva` | `decimal(5,2)` | L19 |
| `sql_err` | `integer` | L20 |
| `v_codret` | `char(5)` | L21 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_sucursales` | `bdinteg` | ⚠️ sí | SELECT | L38 |
| `tblcomision` | `bdispei` | no | SELECT | L48 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L42 | VALIDACIÓN_NULL | `if v_iva is null then` |  |
| L43 | FÓRMULA | `let v_codret = '004'; --No existe iva parametrizado para la sucursal` |  |
| L52 | FÓRMULA | `LET v_ivacom = v_comision * v_iva;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `cal` | ENTIDAD | [polisemia] Cálculo (cal_fecha, cal_riesgo_cliente, cal_trad | 🟡 INFERIDO | nombre_sp |
| `?c_` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `com` | ENTIDAD | Comisión bancaria — cobro de comisión sobre cuenta (bdicheq: | 🔵 CONVENCIÓN | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?c_` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_calc_comasiva`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_sp_calc_comasiva.sql` |
| **LOC (1er CREATE)** | 329 |
| **Callgraph** | ✅ fan_in=0 / fan_out=1 |
| **Deps concatenadas** | 2 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "[polisemia] Cálculo y Comisión bancaria — cobro de comisión sobre cuenta · IVA" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 1 llamada(s): `sp_cons_sdodisp_x_tpcalculo` |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=2 · INFERIDO=1 · SINTÉTICO=2 / 6 términos |

### Historia del SP

| Tipo | Valor |
|------|-------|
| MODIFICACION | Alejandra Barranco Arenas |

### Firma

```sql
CREATE PROCEDURE sp_calc_comasiva(
  pEmpresa                     CHAR(3)
  pSucursal                    CHAR(4)
  pUsuario                     CHAR(8)
  pImporte                     MONEY(16,2)
  pCuenta                      CHAR(20)
  pTipoCta                     SMALLINT
) RETURNING CHAR(5), CHAR(100), MONEY(14,2), MONEY(14,2), CHAR(70), CHAR(20), CHAR(20)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pEmpresa` | `CHAR(3)` | — | — |
| `pSucursal` | `CHAR(4)` | — | — |
| `pUsuario` | `CHAR(8)` | — | — |
| `pImporte` | `MONEY(16,2)` | — | — |
| `pCuenta` | `CHAR(20)` | — | — |
| `pTipoCta` | `SMALLINT` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `sql_err` | `INTEGER` | L22 |
| `v_codret` | `CHAR(5)` | L23 |
| `vDesErr` | `CHAR(100)` | L24 |
| `vComision` | `MONEY(14,2)` | L25 |
| `vIvacom` | `MONEY(14,2)` | L26 |
| `vIva` | `DECIMAL(5,2)` | L27 |
| `vNombre` | `CHAR(105)` | L28 |
| `vCuenta` | `CHAR(20)` | L29 |
| `vRfc` | `CHAR(20)` | L30 |
| `vStatus` | `CHAR(1)` | L31 |
| `vCargo` | `CHAR(1)` | L32 |
| `vsdo_actual` | `MONEY(14,2)` | L33 |
| `vretenido` | `MONEY(14,2)` | L34 |
| `vcongelado` | `MONEY(14,2)` | L35 |
| `vlimccc` | `MONEY(14,2)` | L36 |
| `vutilccc` | `MONEY(14,2)` | L37 |
| `vdispccc` | `MONEY(14,2)` | L38 |
| `vdisponible` | `MONEY(14,2)` | L39 |
| `vfechaccc` | `DATE` | L40 |
| `vfecha_hoy` | `DATE` | L41 |
| `intcontador` | `INTEGER` | L42 |
| `vproducto` | `CHAR(4)` | L43 |
| `vmotivo` | `CHAR(2)` | L44 |
| `vimpchqsbg` | `MONEY(14,2)` | L45 |
| `vValidaPrd` | `CHAR(4)` | L46 |
| *…6 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tblhorario` | `bdispei` | no | SELECT | L112 |
| `si_sucursales` | `bdinteg` | ⚠️ sí | SELECT | L126 |
| `si_param` | `bdinteg` | ⚠️ sí | SELECT | L133 |
| `tblcomision` | `bdispei` | no | SELECT | L141 |
| `sc_maechq` | `bdicheq` | ⚠️ sí | SELECT | L151 |
| `sc_cuenta_telefono` | `bdicheq` | ⚠️ sí | SELECT | L158 |
| `sc_tarjeta` | `bdicheq` | ⚠️ sí | SELECT | L191 |
| `tblcomision_no_comision` | `bdispei` | no | SELECT | L202 |
| `sn_parametros` | `bdiadminnomina` | ⚠️ sí | SELECT | L221 |
| `sn_cte_cta_nomina` | `bdiadminnomina` | ⚠️ sí | SELECT | L227 |
| `sc_ctabloqueo` | `bdicheq` | ⚠️ sí | SELECT | L253 |
| `sc_bloqueo` | `bdicheq` | ⚠️ sí | SELECT | L259 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_cons_sdodisp_x_tpcalculo` | `bdicheq` | ⚠️ sí | L286 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L77 | FÓRMULA | `LET vValidaCtaNomina 		= 0; 	--ALEBARRANCO` |  |
| L78 | FÓRMULA | `LET vValidaEstatusCtaNom 	= 0;	--ALEBARRANCO` |  |
| L79 | FÓRMULA | `LET vPrjExclusionCtaNom 	= 0;	--ALEBARRANCO` |  |
| L101 | VALIDACIÓN_NULL | `IF ( pCuenta is null OR pCuenta = '' OR pTipoCta is null OR pTipoCta = '' OR pTipoCta NOT IN(40, 3, ` |  |
| L130 | VALIDACIÓN_NULL | `IF vIva IS NULL THEN` |  |
| L145 | FÓRMULA | `LET vIvacom = vComision * vIva;` |  |
| L205 | VALIDACIÓN_NULL | `IF vValidaPrd IS NULL THEN` |  |
| L236 | FÓRMULA | `LET vcomision = (vcomision * vPrjExclusionCtaNom) / 100;` |  |
| L237 | FÓRMULA | `LET vivacom   = (vcomision * vIva * vPrjExclusionCtaNom) /100;` |  |
| L256 | VALIDACIÓN_NULL | `IF vCargo is null THEN` |  |
| L270 | FÓRMULA | `LET vDesErr = "Numero de Cuenta/Tarjeta no registrado o la Tarjeta no encuentra activa.";` |  |
| L275 | FÓRMULA | `LET vdispccc = vlimccc - vutilccc;` |  |
| L277 | VALIDACIÓN_NULL | `IF vfechaccc is null OR vfechaccc = '' THEN` |  |
| L281 | VALIDACIÓN_NULL | `IF vfechaccc < vfecha_hoy OR vdispccc IS NULL THEN` |  |
| L288 | FÓRMULA | `LET vdisponible = vdisponible + vdispccc;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `cal` | ENTIDAD | [polisemia] Cálculo (cal_fecha, cal_riesgo_cliente, cal_trad | 🟡 INFERIDO | nombre_sp |
| `?c_` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `com` | ENTIDAD | Comisión bancaria — cobro de comisión sobre cuenta (bdicheq: | 🔵 CONVENCIÓN | nombre_sp |
| `?as` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `iva` | REG | IVA (impuesto — SAT) | ✅ CÓDIGO | nombre_sp, texto_cuerpo |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?c_`, `?as` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_calc_comasiva_web`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_sp_calc_comasiva_web.sql` |
| **LOC (1er CREATE)** | 306 |
| **Callgraph** | ✅ fan_in=0 / fan_out=1 |
| **Deps concatenadas** | 1 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "[polisemia] Cálculo y Comisión bancaria — cobro de comisión sobre cuenta (canal web) · IVA" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 1 llamada(s): `sp_cons_sdodisp_x_tpcalculo` |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=3 · INFERIDO=1 · SINTÉTICO=2 / 7 términos |

### Firma

```sql
CREATE PROCEDURE sp_calc_comasiva_web(
  pEmpresa                     CHAR(3)
  pSucursal                    CHAR(4)
  pUsuario                     CHAR(8)
  pImporte                     MONEY(16,2)
  pCuenta                      CHAR(20)
  pTipoCta                     SMALLINT
) RETURNING CHAR(5), CHAR(100), MONEY(14,2), MONEY(14,2), CHAR(70), CHAR(20), CHAR(20)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pEmpresa` | `CHAR(3)` | — | — |
| `pSucursal` | `CHAR(4)` | — | — |
| `pUsuario` | `CHAR(8)` | — | — |
| `pImporte` | `MONEY(16,2)` | — | — |
| `pCuenta` | `CHAR(20)` | — | — |
| `pTipoCta` | `SMALLINT` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `sql_err` | `INTEGER` | L20 |
| `v_codret` | `CHAR(5)` | L21 |
| `vDesErr` | `CHAR(100)` | L22 |
| `vComision` | `MONEY(14,2)` | L23 |
| `vIvacom` | `MONEY(14,2)` | L24 |
| `vIva` | `DECIMAL(5,2)` | L25 |
| `vNombre` | `CHAR(105)` | L26 |
| `vCuenta` | `CHAR(20)` | L27 |
| `vRfc` | `CHAR(20)` | L28 |
| `vStatus` | `CHAR(1)` | L29 |
| `vCargo` | `CHAR(1)` | L30 |
| `vsdo_actual` | `MONEY(14,2)` | L31 |
| `vretenido` | `MONEY(14,2)` | L32 |
| `vcongelado` | `MONEY(14,2)` | L33 |
| `vlimccc` | `MONEY(14,2)` | L34 |
| `vutilccc` | `MONEY(14,2)` | L35 |
| `vdispccc` | `MONEY(14,2)` | L36 |
| `vdisponible` | `MONEY(14,2)` | L37 |
| `vfechaccc` | `DATE` | L38 |
| `vfecha_hoy` | `DATE` | L39 |
| `intcontador` | `INTEGER` | L40 |
| `vproducto` | `CHAR(4)` | L41 |
| `vmotivo` | `CHAR(2)` | L42 |
| `vimpchqsbg` | `MONEY(14,2)` | L43 |
| `vValidaPrd` | `CHAR(4)` | L44 |
| *…6 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_sucursales` | `bdinteg` | ⚠️ sí | SELECT | L107 |
| `si_param` | `bdinteg` | ⚠️ sí | SELECT | L114 |
| `tblcomision` | `bdispei` | no | SELECT | L122 |
| `sc_maechq` | `bdicheq` | ⚠️ sí | SELECT | L132 |
| `sc_cuenta_telefono` | `bdicheq` | ⚠️ sí | SELECT | L139 |
| `sc_tarjeta` | `bdicheq` | ⚠️ sí | SELECT | L171 |
| `tblcomision_no_comision` | `bdispei` | no | SELECT | L182 |
| `sn_parametros` | `bdiadminnomina` | ⚠️ sí | SELECT | L201 |
| `sn_cte_cta_nomina` | `bdiadminnomina` | ⚠️ sí | SELECT | L207 |
| `sc_ctabloqueo` | `bdicheq` | ⚠️ sí | SELECT | L233 |
| `sc_bloqueo` | `bdicheq` | ⚠️ sí | SELECT | L239 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_cons_sdodisp_x_tpcalculo` | `bdicheq` | ⚠️ sí | L266 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L56 | CÓDIGO_RETORNO | `LET v_codret    = '00000';` |  |
| L74 | FÓRMULA | `LET vValidaCtaNomina 		= 0; 	--ALEBARRANCO` |  |
| L75 | FÓRMULA | `LET vValidaEstatusCtaNom 	= 0;	--ALEBARRANCO` |  |
| L76 | FÓRMULA | `LET vPrjExclusionCtaNom 	= 0;	--ALEBARRANCO` |  |
| L98 | VALIDACIÓN_NULL | `IF ( pCuenta is null OR pCuenta = '' OR pTipoCta is null OR pTipoCta = '' OR pTipoCta NOT IN(40, 3, ` |  |
| L99 | CÓDIGO_RETORNO | `LET v_codret = '00002';` |  |
| L111 | VALIDACIÓN_NULL | `IF vIva IS NULL THEN` |  |
| L126 | FÓRMULA | `LET vIvacom = vComision * vIva;` |  |
| L142 | CÓDIGO_RETORNO | `LET v_codret = '00003';` |  |
| L185 | VALIDACIÓN_NULL | `IF vValidaPrd IS NULL THEN` |  |
| L216 | FÓRMULA | `LET vcomision = (vcomision * vPrjExclusionCtaNom) / 100;` |  |
| L217 | FÓRMULA | `LET vivacom   = (vcomision * vIva * vPrjExclusionCtaNom) /100;` |  |
| L227 | CÓDIGO_RETORNO | `LET v_codret = '00004';` |  |
| L236 | VALIDACIÓN_NULL | `IF vCargo is null THEN` |  |
| L244 | CÓDIGO_RETORNO | `LET v_codret = '00005';` |  |
| L249 | CÓDIGO_RETORNO | `LET v_codret = '00006';` |  |
| L250 | FÓRMULA | `LET vDesErr = "Numero de Cuenta/Tarjeta no registrado o la Tarjeta no encuentra activa.";` |  |
| L255 | FÓRMULA | `LET vdispccc = vlimccc - vutilccc;` |  |
| L257 | VALIDACIÓN_NULL | `IF vfechaccc is null OR vfechaccc = '' THEN` |  |
| L261 | VALIDACIÓN_NULL | `IF vfechaccc < vfecha_hoy OR vdispccc IS NULL THEN` |  |
| L268 | FÓRMULA | `LET vdisponible = vdisponible + vdispccc;` |  |
| L271 | CÓDIGO_RETORNO | `LET v_codret = '00001';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `cal` | ENTIDAD | [polisemia] Cálculo (cal_fecha, cal_riesgo_cliente, cal_trad | 🟡 INFERIDO | nombre_sp |
| `?c_` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `com` | ENTIDAD | Comisión bancaria — cobro de comisión sobre cuenta (bdicheq: | 🔵 CONVENCIÓN | nombre_sp |
| `?as` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `iva` | REG | IVA (impuesto — SAT) | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `web` | MODIF | canal web | 🔵 CONVENCIÓN | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?c_`, `?as` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_calcula_comision_spei`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_sp_calcula_comision_spei.sql` |
| **LOC (1er CREATE)** | 34 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "calcula · comisión" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — Tokens confirmados en el vocab pero DML no correlaciona con el propósito |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=0 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_calcula_comision_spei(
  pmnymonto                    money
  pchrsucursal                 char(4)
) RETURNING money
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pmnymonto` | `money` | — | — |
| `pchrsucursal` | `char(4)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vmnycomision` | `money` | L20 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L24 | VALIDACIÓN_NULL | `IF (pchrsucursal IS NULL) OR (pchrsucursal='') THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `calcula` | ACCION | calcula (verbo activo — spei_calculointeres) | 🔵 CONVENCIÓN | nombre_sp |
| `comision` | REG | comisión (CONDUSEF — debe estar en RECO) | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `spei` | PREFIJO | familia SPEI (pagos interbancarios) | ✅ CÓDIGO | nombre_sp, texto_cuerpo |

---

## `sp_cambio_fecha`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_sp_cambio_fecha.sql` |
| **LOC (1er CREATE)** | 70 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 2 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "cambio y fecha" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 1 llamada(s): `sp_validafecha` |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=0 / 3 términos |

### Firma

```sql
CREATE PROCEDURE sp_cambio_fecha(
) RETURNING CHAR(5), --codigo
```

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `wchrempresa` | `CHAR(3)` | L7 |
| `wfecha_hoy` | `DATE` | L8 |
| `vcodret` | `CHAR(5)` | L9 |
| `vsqlerr` | `INTEGER` | L10 |
| `wfech_habil` | `DATE` | L11 |
| `wfecha_habil` | `CHAR(10)` | L12 |
| `isam_err` | `INTEGER` | L13 |
| `error_info` | `VARCHAR(100)` | L14 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sc_fechas` | `bdicheq` | ⚠️ sí | SELECT | L35 |
| `tblctrlproceso` | `bdispei` | no | INSERT | L38 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_validafecha` | `bdispei` | no | L42 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L18 | CÓDIGO_RETORNO | `LET vcodret = '00000';` |  |
| L53 | FÓRMULA | `LET wfecha_habil = TO_CHAR(wfech_habil, '%d/%m/%Y');` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `cambio` | ENTIDAD | cambio (de estatus, domicilio, etc.) | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `fecha` | ENTIDAD | fecha | ✅ CÓDIGO | nombre_sp, texto_cuerpo |

---

## `sp_cancelaenvio`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_sp_cancelaenvio.sql` |
| **LOC (1er CREATE)** | 60 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "cancela" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 3 tabla(s) con operaciones: SELECT, UPDATE |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=0 / 3 términos |

### Firma

```sql
CREATE PROCEDURE sp_cancelaenvio(
  pClaveRastreo                VARCHAR(30)
) RETURNING CHAR(5)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pClaveRastreo` | `VARCHAR(30)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `v_row` | `INTEGER` | L9 |
| `v_statusenv` | `CHAR(1)` | L10 |
| `v_codret` | `CHAR(5)` | L11 |
| `sql_err` | `INTEGER` | L12 |
| `vchrParametro` | `VARCHAR(255)` | L13 |
| `vchrFechaHoy` | `VARCHAR(10)` | L14 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tblparametros` | `bdispei` | no | SELECT | L32 |
| `tblpago` | `bdispei` | no | SELECT | L39 |
| `tblpago` | `bdispei` | no | UPDATE | L48 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L35 | FÓRMULA | `LET vchrFechaHoy = SUBSTR(vchrParametro,4,2) \|\| '/' \|\|` |  |
| L42 | VALIDACIÓN_NULL | `IF v_statusenv IS NULL OR v_statusenv = "" THEN` |  |
| L43 | FÓRMULA | `LET v_codret="999";  -- No Existe Usuario Autorizado` |  |
| L51 | FÓRMULA | `LET v_codret="000";          -- Movimineto Cancelado` |  |
| L54 | FÓRMULA | `LET v_codret="145";          -- Usuario Autorizado no existe` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `cancela` | ACCION | cancela | 🔵 CONVENCIÓN | nombre_sp |
| `envio` | ACCION | envía | 🔵 CONVENCIÓN | nombre_sp |

---

## `sp_cargo_val`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_sp_cargo_val.sql` |
| **LOC (1er CREATE)** | 161 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "cargo" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 4 tabla(s) con operaciones: INSERT, SELECT |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=1 / 3 términos |

### Firma

```sql
CREATE PROCEDURE sp_cargo_val(
  pcuenta                      char(20)
) RETURNING char(5)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pcuenta` | `char(20)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vcodret` | `char(5)` | L4 |
| `vsqlerr` | `integer` | L5 |
| `vfecha_hoy` | `date` | L6 |
| `vfecha_ant` | `date` | L7 |
| `vfecha_proceso` | `date` | L8 |
| `vstatus_cta` | `char(1)` | L9 |
| `vretiros` | `money(14,2)` | L10 |
| `vabonos` | `money(14,2)` | L11 |
| `vsdoactual` | `money(14,2)` | L12 |
| `vsdoinicial` | `money(14,2)` | L13 |
| `vsdoretenido` | `money(14,2)` | L14 |
| `vsdodisp` | `money(14,2)` | L15 |
| `vsdocalculado` | `money(14,2)` | L16 |
| `vdiferencia` | `money(14,2)` | L17 |
| `vreferencia` | `char(40)` | L18 |
| `vcuantos` | `smallint` | L19 |
| `vproducto` | `char(4)` | L20 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sc_fechas` | `bdispei` | no | SELECT | L57 |
| `sc_maechq` | `bdispei` | no | SELECT | L61 |
| `sc_movdia` | `bdispei` | no | SELECT | L86 |
| `sc_cuentas_retiro` | `bdispei` | no | INSERT | L130 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L50 | CÓDIGO_RETORNO | `let vcodret = '00000';` |  |
| L66 | CÓDIGO_RETORNO | `let vcodret = '00000';` |  |
| L72 | CÓDIGO_RETORNO | `let vcodret = '00000';` |  |
| L77 | VALIDACIÓN_NULL | `if vfecha_proceso is null or vfecha_proceso = "" then` |  |
| L92 | CÓDIGO_RETORNO | `let vcodret = '00000';` |  |
| L121 | FÓRMULA | `let vsdocalculado = vsdoinicial + vabonos - vretiros;` |  |
| L124 | FÓRMULA | `let vdiferencia = vsdodisp - vsdocalculado;` |  |
| L126 | FÓRMULA | `let vdiferencia = vdiferencia * -1;` |  |
| L132 | CÓDIGO_RETORNO | `let vcodret = '00000';` |  |
| L139 | CÓDIGO_RETORNO | `let vcodret = '00000';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `cargo` | ENTIDAD | cargo / débito | 🔵 CONVENCIÓN | nombre_sp |
| `?_val` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_val` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_coas_envio`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_sp_coas_envio.sql` |
| **LOC (1er CREATE)** | 278 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "envía COAS — Confirmación de Operación y Acuse de Recibo Simplificado" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `confirma` → `SELECT` encontrado en el cuerpo · `confirma` → `UPDATE` encontrado en el cuerpo · `envía` → `INSERT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=0 / 3 términos |

### Firma

```sql
CREATE PROCEDURE sp_coas_envio(
) RETURNING CHAR(5)
```

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vsqlerr` | `INT` | L4 |
| `vcodret` | `CHAR(5)` | L5 |
| `v_vchrvalor` | `DATE` | L8 |
| `v_vchrclaverastreo` | `VARCHAR(30)` | L9 |
| `v_consecutivo` | `SMALLINT` | L10 |
| `v_consecutivo2` | `SMALLINT` | L11 |
| `v_cadena` | `CHAR(600)` | L12 |
| `v_enc_ide1` | `INT` | L13 |
| `v_enc_ide2` | `INT` | L14 |
| `v_total_det` | `INT` | L15 |
| `v_cade_enca` | `CHAR(600)` | L16 |
| `vsql` | `CHAR(500)` | L17 |
| `v_con_archi` | `CHAR(4)` | L18 |
| `v_anio_fin` | `INTEGER` | L19 |
| `v_mes_fin` | `CHAR(2)` | L20 |
| `v_dia_fin` | `CHAR(2)` | L21 |
| `v_f_fin` | `VARCHAR(8)` | L22 |
| `v_fecha_arch` | `CHAR(6)` | L23 |
| `v_identificador` | `CHAR(50)` | L24 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tblparametros` | `bdispei` | no | SELECT | L54 |
| `systabnames` | `sysmaster` | ⚠️ sí | SELECT | L59 |
| `tblfoliocoasenv` | `bdispei` | no | SELECT | L84 |
| `tblfoliocoasenv` | `bdispei` | no | INSERT | L90 |
| `tblfoliocoasenv` | `bdispei` | no | UPDATE | L95 |
| `tbldetalle` | `bdispei` | no | INSERT | L107 |
| `tblpago` | `bdispei` | no | SELECT | L152 |
| `sc_movdia` | `bdicheq` | ⚠️ sí | SELECT | L155 |
| `tblpago` | `bdispei` | no | UPDATE | L166 |
| `tbldetalle` | `bdispei` | no | SELECT | L178 |
| `tbldetalle` | `bdispei` | no | UPDATE | L205 |
| `sc_fechas` | `bdicheq` | ⚠️ sí | SELECT | L230 |
| `tbldetalle` | `bdispei` | no | DELETE | L268 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L87 | VALIDACIÓN_NULL | `IF v_consecutivo IS NULL THEN` |  |
| L93 | FÓRMULA | `LET v_consecutivo = v_consecutivo + 1;` |  |
| L170 | FÓRMULA | `LET v_consecutivo2 = v_consecutivo2 + 1;` |  |
| L182 | FÓRMULA | `LET v_total_det = v_consecutivo2 -1;` |  |
| L243 | FÓRMULA | `LET vsql = "dbaccess bdispei  /resplogifx/conciliachq/spei/consulta.sql";` |  |
| L262 | FÓRMULA | `LET v_consecutivo = v_consecutivo - 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `coas` | ENTIDAD | COAS — Confirmación de Operación y Acuse de Recibo Simplific | 🔵 CONVENCIÓN | nombre_sp |
| `envio` | ACCION | envía | ✅ CÓDIGO | nombre_sp, texto_cuerpo |

---

## `sp_coas_envio_exp1`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_sp_coas_envio_exp1.sql` |
| **LOC (1er CREATE)** | 278 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "envía COAS — Confirmación de Operación y Acuse de Recibo Simplificado (sufijo Exportar — SP genera/exporta archivo de salida)" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `confirma` → `SELECT` encontrado en el cuerpo · `confirma` → `UPDATE` encontrado en el cuerpo · `genera` → `INSERT` encontrado en el cuerpo · `genera` → `SELECT` encontrado en el cuerpo · `envía` → `INSERT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=2 · INFERIDO=1 · SINTÉTICO=1 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_coas_envio_exp1(
) RETURNING CHAR(5)
```

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vsqlerr` | `INT` | L4 |
| `vcodret` | `CHAR(5)` | L5 |
| `v_vchrvalor` | `DATE` | L8 |
| `v_vchrclaverastreo` | `VARCHAR(30)` | L9 |
| `v_consecutivo` | `SMALLINT` | L10 |
| `v_consecutivo2` | `SMALLINT` | L11 |
| `v_cadena` | `CHAR(600)` | L12 |
| `v_enc_ide1` | `INT` | L13 |
| `v_enc_ide2` | `INT` | L14 |
| `v_total_det` | `INT` | L15 |
| `v_cade_enca` | `CHAR(600)` | L16 |
| `vsql` | `CHAR(500)` | L17 |
| `v_con_archi` | `CHAR(4)` | L18 |
| `v_anio_fin` | `INTEGER` | L19 |
| `v_mes_fin` | `CHAR(2)` | L20 |
| `v_dia_fin` | `CHAR(2)` | L21 |
| `v_f_fin` | `VARCHAR(8)` | L22 |
| `v_fecha_arch` | `CHAR(6)` | L23 |
| `v_identificador` | `CHAR(50)` | L24 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tblparametros` | `bdispei` | no | SELECT | L54 |
| `systabnames` | `sysmaster` | ⚠️ sí | SELECT | L59 |
| `tblfoliocoasenv` | `bdispei` | no | SELECT | L84 |
| `tblfoliocoasenv` | `bdispei` | no | INSERT | L90 |
| `tblfoliocoasenv` | `bdispei` | no | UPDATE | L95 |
| `tbldetalle` | `bdispei` | no | INSERT | L107 |
| `tblpago` | `bdispei` | no | SELECT | L152 |
| `sc_movdia` | `bdicheq` | ⚠️ sí | SELECT | L155 |
| `tblpago` | `bdispei` | no | UPDATE | L166 |
| `tbldetalle` | `bdispei` | no | SELECT | L178 |
| `tbldetalle` | `bdispei` | no | UPDATE | L205 |
| `sc_fechas` | `bdicheq` | ⚠️ sí | SELECT | L230 |
| `tbldetalle` | `bdispei` | no | DELETE | L268 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L87 | VALIDACIÓN_NULL | `IF v_consecutivo IS NULL THEN` |  |
| L93 | FÓRMULA | `LET v_consecutivo = v_consecutivo + 1;` |  |
| L170 | FÓRMULA | `LET v_consecutivo2 = v_consecutivo2 + 1;` |  |
| L182 | FÓRMULA | `LET v_total_det = v_consecutivo2 -1;` |  |
| L243 | FÓRMULA | `LET vsql = "dbaccess bdispei  /resplogifx/conciliachq/spei/consulta.sql";` |  |
| L262 | FÓRMULA | `LET v_consecutivo = v_consecutivo - 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `coas` | ENTIDAD | COAS — Confirmación de Operación y Acuse de Recibo Simplific | 🔵 CONVENCIÓN | nombre_sp |
| `envio` | ACCION | envía | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `exp` | MODIF | sufijo Exportar — SP genera/exporta archivo de salida (sp_*_ | 🟡 INFERIDO | nombre_sp |
| `?1` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?1` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_coas_recibidos`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_sp_coas_recibidos.sql` |
| **LOC (1er CREATE)** | 751 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "recepción COAS — Confirmación de Operación y Acuse de Recibo Simplificado y identificador" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `confirma` → `SELECT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=2 / 6 términos |

### Firma

```sql
CREATE PROCEDURE sp_coas_recibidos(
  pNombreArchivo               CHAR(30)
) RETURNING CHAR(5), CHAR(5), CHAR(80)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pNombreArchivo` | `CHAR(30)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vsqlerr` | `INTEGER` | L4 |
| `visamerr` | `INTEGER` | L5 |
| `vdescerr` | `CHAR(50)` | L6 |
| `vcodret` | `CHAR(5)` | L7 |
| `vcodret2` | `CHAR(5)` | L8 |
| `vcodret3` | `CHAR(50)` | L9 |
| `iComienza` | `SMALLINT` | L10 |
| `iTransacc` | `SMALLINT` | L11 |
| `iContador1` | `INTEGER` | L12 |
| `iContador2` | `INTEGER` | L13 |
| `iContador3` | `INTEGER` | L14 |
| `cStmt` | `CHAR(300)` | L15 |
| `cSql` | `CHAR(300)` | L16 |
| `iOperaciones` | `SMALLINT` | L18 |
| `iAbonos` | `SMALLINT` | L19 |
| `iDevols` | `SMALLINT` | L20 |
| `cfolio` | `CHAR(10)` | L21 |
| `ctipo_pago` | `CHAR(2)` | L22 |
| `cclave_particip` | `CHAR(5)` | L23 |
| `cmonto_pago` | `CHAR(19)` | L24 |
| `cfolio_pago` | `CHAR(5)` | L25 |
| `cclave_rastreo` | `CHAR(30)` | L26 |
| `cnombre_orden` | `CHAR(40)` | L27 |
| `ctpo_cta_orden` | `CHAR(2)` | L28 |
| `ccuenta_orden` | `CHAR(20)` | L29 |
| *…34 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `systabnames` | `sysmaster` | ⚠️ sí | SELECT | L149 |
| `tbl_coas_rec` | `bdispei` | no | INSERT | L336 |
| `tbl_coas_rec` | `bdispei` | no | SELECT | L346 |
| `tbl_coas_rec_abono` | `bdispei` | no | INSERT | L362 |
| `tbl_coas_rec_abono5` | `bdispei` | no | INSERT | L365 |
| `tbl_coas_rec_abono7` | `bdispei` | no | INSERT | L368 |
| `tbl_coas_rec_devol` | `bdispei` | no | INSERT | L371 |
| `tbl_coas_rec_devol16` | `bdispei` | no | INSERT | L374 |
| `tbl_coas_rec_pend` | `bdispei` | no | INSERT | L377 |
| `tbl_coas_rec_abono` | `bdispei` | no | SELECT | L403 |
| `tbl_coas_rec_abono5` | `bdispei` | no | SELECT | L415 |
| `tbl_coas_rec_abono7` | `bdispei` | no | SELECT | L427 |
| `tbl_coas_rec_devol` | `bdispei` | no | SELECT | L439 |
| `tbl_coas_rec_devol16` | `bdispei` | no | SELECT | L451 |
| `tbl_encabezado_coas_rec` | `bdispei` | no | INSERT | L466 |
| `tbl_coas_rec_abonos` | `bdispei` | no | INSERT | L485 |
| `tbl_coas_rec_abonos5` | `bdispei` | no | INSERT | L494 |
| `tbl_coas_rec_abonos7` | `bdispei` | no | INSERT | L503 |
| `tbl_coas_rec_devols` | `bdispei` | no | INSERT | L512 |
| `tbl_coas_rec_devols16` | `bdispei` | no | INSERT | L521 |
| `tbl_encabezado_coas_rec` | `bdispei` | no | SELECT | L531 |
| `tbl_coas_rec_abonos` | `bdispei` | no | SELECT | L535 |
| `tbl_coas_rec_devols` | `bdispei` | no | SELECT | L539 |
| `tbl_coas_rec_abonos_proc` | `bdispei` | no | INSERT | L566 |
| `tbl_coas_rec_devueltos` | `bdispei` | no | INSERT | L572 |
| `tbl_coas_rec_abonos5` | `bdispei` | no | SELECT | L592 |
| `tbl_coas_rec_abonos5_proc` | `bdispei` | no | INSERT | L602 |
| `tbl_coas_rec_abonos7` | `bdispei` | no | SELECT | L626 |
| `tblpago` | `bdispei` | no | SELECT | L633 |
| `tbl_coas_rec_abonos7_proc` | `bdispei` | no | INSERT | L642 |
| `tbl_coas_rec_devols_proc` | `bdispei` | no | INSERT | L696 |
| `tbl_coas_rec_devols16` | `bdispei` | no | SELECT | L722 |
| `tbl_coas_rec_devols16_proc` | `bdispei` | no | INSERT | L733 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `spei_recordenpago` | `bdispei` | no | L563 |
| `spei_recdevolucion` | `bdispei` | no | L693 |
| `spei_recextemporanea` | `bdispei` | no | L730 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L71 | FÓRMULA | `LET iComienza  = -1;` |  |
| L352 | FÓRMULA | `LET iCont = iCont + 1;` |  |
| L355 | FÓRMULA | `LET iCont = iCont + 1;` |  |
| L358 | FÓRMULA | `LET iCont = iCont + 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `coas` | ENTIDAD | COAS — Confirmación de Operación y Acuse de Recibo Simplific | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `rec` | ACCION | recepción / recibe | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `?ib` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `id` | ENTIDAD | identificador (de) | 🔵 CONVENCIÓN | nombre_sp |
| `?os` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?ib`, `?os` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_coas_recibidos_exp1`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_sp_coas_recibidos_exp1.sql` |
| **LOC (1er CREATE)** | 751 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "recepción COAS — Confirmación de Operación y Acuse de Recibo Simplificado y identificador (sufijo Exportar — SP genera/exporta archivo de salida)" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `confirma` → `SELECT` encontrado en el cuerpo · `genera` → `INSERT` encontrado en el cuerpo · `genera` → `SELECT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=2 · INFERIDO=1 · SINTÉTICO=3 / 8 términos |

### Firma

```sql
CREATE PROCEDURE sp_coas_recibidos_exp1(
  pNombreArchivo               CHAR(30)
) RETURNING CHAR(5), CHAR(5), CHAR(80)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pNombreArchivo` | `CHAR(30)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vsqlerr` | `INTEGER` | L4 |
| `visamerr` | `INTEGER` | L5 |
| `vdescerr` | `CHAR(50)` | L6 |
| `vcodret` | `CHAR(5)` | L7 |
| `vcodret2` | `CHAR(5)` | L8 |
| `vcodret3` | `CHAR(50)` | L9 |
| `iComienza` | `SMALLINT` | L10 |
| `iTransacc` | `SMALLINT` | L11 |
| `iContador1` | `INTEGER` | L12 |
| `iContador2` | `INTEGER` | L13 |
| `iContador3` | `INTEGER` | L14 |
| `cStmt` | `CHAR(300)` | L15 |
| `cSql` | `CHAR(300)` | L16 |
| `iOperaciones` | `SMALLINT` | L18 |
| `iAbonos` | `SMALLINT` | L19 |
| `iDevols` | `SMALLINT` | L20 |
| `cfolio` | `CHAR(10)` | L21 |
| `ctipo_pago` | `CHAR(2)` | L22 |
| `cclave_particip` | `CHAR(5)` | L23 |
| `cmonto_pago` | `CHAR(19)` | L24 |
| `cfolio_pago` | `CHAR(5)` | L25 |
| `cclave_rastreo` | `CHAR(30)` | L26 |
| `cnombre_orden` | `CHAR(40)` | L27 |
| `ctpo_cta_orden` | `CHAR(2)` | L28 |
| `ccuenta_orden` | `CHAR(20)` | L29 |
| *…34 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `systabnames` | `sysmaster` | ⚠️ sí | SELECT | L149 |
| `tbl_coas_rec` | `bdispei` | no | INSERT | L336 |
| `tbl_coas_rec` | `bdispei` | no | SELECT | L346 |
| `tbl_coas_rec_abono` | `bdispei` | no | INSERT | L362 |
| `tbl_coas_rec_abono5` | `bdispei` | no | INSERT | L365 |
| `tbl_coas_rec_abono7` | `bdispei` | no | INSERT | L368 |
| `tbl_coas_rec_devol` | `bdispei` | no | INSERT | L371 |
| `tbl_coas_rec_devol16` | `bdispei` | no | INSERT | L374 |
| `tbl_coas_rec_pend` | `bdispei` | no | INSERT | L377 |
| `tbl_coas_rec_abono` | `bdispei` | no | SELECT | L403 |
| `tbl_coas_rec_abono5` | `bdispei` | no | SELECT | L415 |
| `tbl_coas_rec_abono7` | `bdispei` | no | SELECT | L427 |
| `tbl_coas_rec_devol` | `bdispei` | no | SELECT | L439 |
| `tbl_coas_rec_devol16` | `bdispei` | no | SELECT | L451 |
| `tbl_encabezado_coas_rec` | `bdispei` | no | INSERT | L466 |
| `tbl_coas_rec_abonos` | `bdispei` | no | INSERT | L485 |
| `tbl_coas_rec_abonos5` | `bdispei` | no | INSERT | L494 |
| `tbl_coas_rec_abonos7` | `bdispei` | no | INSERT | L503 |
| `tbl_coas_rec_devols` | `bdispei` | no | INSERT | L512 |
| `tbl_coas_rec_devols16` | `bdispei` | no | INSERT | L521 |
| `tbl_encabezado_coas_rec` | `bdispei` | no | SELECT | L531 |
| `tbl_coas_rec_abonos` | `bdispei` | no | SELECT | L535 |
| `tbl_coas_rec_devols` | `bdispei` | no | SELECT | L539 |
| `tbl_coas_rec_abonos_proc` | `bdispei` | no | INSERT | L566 |
| `tbl_coas_rec_devueltos` | `bdispei` | no | INSERT | L572 |
| `tbl_coas_rec_abonos5` | `bdispei` | no | SELECT | L592 |
| `tbl_coas_rec_abonos5_proc` | `bdispei` | no | INSERT | L602 |
| `tbl_coas_rec_abonos7` | `bdispei` | no | SELECT | L626 |
| `tblpago` | `bdispei` | no | SELECT | L633 |
| `tbl_coas_rec_abonos7_proc` | `bdispei` | no | INSERT | L642 |
| `tbl_coas_rec_devols_proc` | `bdispei` | no | INSERT | L696 |
| `tbl_coas_rec_devols16` | `bdispei` | no | SELECT | L722 |
| `tbl_coas_rec_devols16_proc` | `bdispei` | no | INSERT | L733 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `spei_recordenpago` | `bdispei` | no | L563 |
| `spei_recdevolucion` | `bdispei` | no | L693 |
| `spei_recextemporanea` | `bdispei` | no | L730 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L71 | FÓRMULA | `LET iComienza  = -1;` |  |
| L352 | FÓRMULA | `LET iCont = iCont + 1;` |  |
| L355 | FÓRMULA | `LET iCont = iCont + 1;` |  |
| L358 | FÓRMULA | `LET iCont = iCont + 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `coas` | ENTIDAD | COAS — Confirmación de Operación y Acuse de Recibo Simplific | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `rec` | ACCION | recepción / recibe | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `?ib` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `id` | ENTIDAD | identificador (de) | 🔵 CONVENCIÓN | nombre_sp |
| `?os_` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `exp` | MODIF | sufijo Exportar — SP genera/exporta archivo de salida (sp_*_ | 🟡 INFERIDO | nombre_sp |
| `?1` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?ib`, `?os_`, `?1` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_con_relordpago`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_sp_con_relordpago.sql` |
| **LOC (1er CREATE)** | 455 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 1 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "consulta ordenante y pago" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=2 · INFERIDO=1 · SINTÉTICO=1 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_con_relordpago(
  pconsulta_tipo               smallint
) RETURNING char(5),        date,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pconsulta_tipo` | `smallint` | `con`=consulta | 🟡 INFERIDO |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vcodret` | `char(5)` | L35 |
| `vsqlerr` | `integer` | L36 |
| `LVintpkpago` | `integer` | L38 |
| `LVdtfechavalor` | `date` | L39 |
| `LVintcvetipopago` | `integer` | L40 |
| `LVtipopago` | `varchar(111,0)` | L41 |
| `LVcvecesifbcoord` | `integer` | L42 |
| `LVcesifbcoord` | `varchar(31,0)` | L43 |
| `LVvchrcuentaord` | `varchar(20,0)` | L44 |
| `LVvchrnombreord` | `varchar(40,0)` | L45 |
| `LVintcvetipoctaord` | `integer` | L46 |
| `LVmnyimporte` | `decimal(19,2)` | L47 |
| `LVcvecesifbcodest` | `integer` | L48 |
| `LVcesifbcodest` | `varchar(31,0)` | L49 |
| `LVvchrcuentabenef` | `varchar(20,0)` | L50 |
| `LVvchrnombrebenef` | `varchar(40,0)` | L51 |
| `LVintcvetipoctabene` | `integer` | L52 |
| `LVvchrclaverastreo` | `varchar(30,0)` | L53 |
| `LVchrestatusenvio` | `varchar(50,0)` | L54 |
| `LVintcvetpooperacion` | `integer` | L55 |
| `LVcvetpooperacion` | `varchar(111,0)` | L56 |
| `LVchrsentidopago` | `char(1)` | L57 |
| `LVsentidopago` | `varchar(10,0)` | L58 |
| `LVvchrdescripcion` | `varchar(250,0)` | L59 |
| `LVintcvecausadev` | `varchar(111,0)` | L60 |
| *…12 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tblpago` | `bdispei` | no | SELECT | L167 |
| `tblhistpago` | `bdispei` | no | SELECT | L188 |
| `tblbanco` | `bdispei` | no | SELECT | L260 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L233 | FÓRMULA | `Let LVtotal_paginas = LVtotal_registros / 100;` |  |
| L236 | FÓRMULA | `Let LVauxiliar_paginas = LVtotal_paginas*100;` |  |
| L237 | FÓRMULA | `Let LVtotal_paginas = LVtotal_paginas + 1;` |  |
| L238 | FÓRMULA | `Let LVauxiliar_paginas = LVtotal_registros + 1;` |  |
| L240 | FÓRMULA | `Let LVtotal_paginas = LVtotal_registros / 100;` |  |
| L245 | FÓRMULA | `Let vultimo_tanto = pregistro + 99 ;` |  |
| L252 | FÓRMULA | `LET LVpagina_actual = pregistro/100;` |  |
| L253 | FÓRMULA | `LET LVpagina_actual = LVpagina_actual +1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `con` | ACCION | consulta | 🟡 INFERIDO | nombre_sp |
| `?_rel` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `ord` | ENTIDAD | ordenante / orden (SPEI) | 🔵 CONVENCIÓN | nombre_sp |
| `pago` | ENTIDAD | pago | ✅ CÓDIGO | nombre_sp, texto_cuerpo |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_rel` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_confenviopaq`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_sp_confenviopaq.sql` |
| **LOC (1er CREATE)** | 47 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "consulta paquete — paquete de pago SPEI" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=1 · INFERIDO=2 · SINTÉTICO=1 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_confenviopaq(
  pintPkPaquete                INTEGER
  pintFolioPaquete             INTEGER
  pmnyMontoPaq                 DECIMAL(19,2)
  pintCantPagos                INTEGER
) RETURNING CHAR(5)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pintPkPaquete` | `INTEGER` | `paq`=paquete — paquete de pago SPEI (bloque/lote de órdenes de transferencia) | 🟡 INFERIDO |
| `pintFolioPaquete` | `INTEGER` | `paq`=paquete — paquete de pago SPEI (bloque/lote de órdenes de transferencia) | 🟡 INFERIDO |
| `pmnyMontoPaq` | `DECIMAL(19,2)` | `paq`=paquete — paquete de pago SPEI (bloque/lote de órdenes de transferencia) | 🟡 INFERIDO |
| `pintCantPagos` | `INTEGER` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `codret` | `CHAR(5)` | L4 |
| `sql_err` | `INTEGER` | L5 |
| `vintpkpaq` | `INTEGER` | L6 |
| `vdtFechaOp` | `DATE` | L7 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tblparametros` | `bdispei` | no | SELECT | L20 |
| `tblpaqueteenv` | `bdispei` | no | UPDATE | L24 |
| `tblpaqueteenv` | `bdispei` | no | SELECT | L34 |
| `tblpago` | `bdispei` | no | UPDATE | L39 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `con` | ACCION | consulta | 🟡 INFERIDO | nombre_sp |
| `?f` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `envio` | ACCION | envía | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `paq` | ENTIDAD | paquete — paquete de pago SPEI (bloque/lote de órdenes de tr | 🟡 INFERIDO | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?f` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_confpagospei`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_sp_confpagospei.sql` |
| **LOC (1er CREATE)** | 139 |
| **Callgraph** | ✅ fan_in=0 / fan_out=1 |
| **Propósito inferido** | "consulta pagos" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=2 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_confpagospei(
  p_sucursal                   CHAR(4)
  p_usuario                    CHAR(8)
  p_folprom                    CHAR(16)
  p_folliq                     CHAR(16)
) RETURNING CHAR(5)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_sucursal` | `CHAR(4)` | — | — |
| `p_usuario` | `CHAR(8)` | — | — |
| `p_folprom` | `CHAR(16)` | — | — |
| `p_folliq` | `CHAR(16)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `v_codret` | `CHAR(5)` | L21 |
| `sql_err` | `INTEGER` | L22 |
| `v_hora` | `datetime HOUR TO SECOND` | L23 |
| `v_importe` | `MONEY(14,2)` | L24 |
| `v_ctapropia` | `CHAR(20)` | L25 |
| `v_producto` | `CHAR(4)` | L26 |
| `v_status` | `CHAR(1)` | L27 |
| `vchrParametro` | `VARCHAR(255)` | L28 |
| `vchrFechaHoy` | `VARCHAR(10)` | L29 |
| `intTpoPago` | `INTEGER` | L30 |
| `chrAbonaChq` | `CHAR(1)` | L31 |
| `chrSucursal` | `CHAR(4)` | L33 |
| `intFolioLiq` | `INTEGER` | L34 |
| `chrCodSistema` | `CHAR(2)` | L35 |
| `chrCodSisSPEI` | `CHAR(2)` | L36 |
| `v_chrtransaccion` | `CHAR(4)` | L39 |
| `v_mnymonto` | `MONEY` | L40 |
| `v_chrtranret` | `CHAR(4)` | L41 |
| `v_dteCobroCom` | `DATE` | L42 |
| `v_mnySdoDisp` | `MONEY` | L43 |
| `v_mnyMontoRet` | `MONEY` | L44 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tblparametros` | `bdispei` | no | SELECT | L64 |
| `tblpago` | `bdispei` | no | SELECT | L79 |
| `tblcomision` | `bdispei` | no | SELECT | L99 |
| `tbltipopago` | `bdispei` | no | SELECT | L108 |
| `tblpago` | `bdispei` | no | UPDATE | L130 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `cargo_ref` | `bdicheq` | ⚠️ sí | L116 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L67 | FÓRMULA | `LET vchrFechaHoy = SUBSTR(vchrParametro,4,2) \|\| '/' \|\|` |  |
| L72 | VALIDACIÓN_NULL | `IF vchrParametro IS NULL OR vchrParametro = '' THEN` |  |
| L103 | VALIDACIÓN_NULL | `IF v_mnymonto IS NULL OR v_mnymonto <= 0 THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `con` | ACCION | consulta | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?f` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `pagos` | ENTIDAD | pagos (plural) | 🔵 CONVENCIÓN | nombre_sp |
| `?pei` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?f`, `?pei` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_cons_comision_ob`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_sp_cons_comision_ob.sql` |
| **LOC (1er CREATE)** | 57 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "consulta · comisión" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=1 / 4 términos |

### Historia del SP

| Tipo | Valor |
|------|-------|
| DESCRIPCION | Obtener la comision para cuentas de otros bancos |
| FECHA | 02/Diciembre/2015 |

### Firma

```sql
CREATE PROCEDURE sp_cons_comision_ob(
) RETURNING char(5), money
```

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vCodRet` | `char(5)` | L14 |
| `sql_err` | `integer` | L15 |
| `vMonto` | `money` | L16 |
| `iCont` | `integer` | L17 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tblcomision` | `bdispei` | no | SELECT | L43 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L20 | CÓDIGO_RETORNO | `LET vCodRet='00000';` |  |
| L52 | CÓDIGO_RETORNO | `LET vCodRet='00001';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `cons` | ACCION | consulta | 🔵 CONVENCIÓN | nombre_sp |
| `comision` | REG | comisión (CONDUSEF — debe estar en RECO) | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?_ob` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_ob` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_cons_ult_pago`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_sp_cons_ult_pago.sql` |
| **LOC (1er CREATE)** | 90 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "consulta pago" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=1 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_cons_ult_pago(
  p_cta_ord                    char(20)
  p_fecha                      date
  p_cta_receptor               char(20)
  p_bco_receptor               char(6)
) RETURNING char(5),char(16),char(40),char(210),char(1),decimal(19,2)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_cta_ord` | `char(20)` | — | — |
| `p_fecha` | `date` | — | — |
| `p_cta_receptor` | `char(20)` | — | — |
| `p_bco_receptor` | `char(6)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `sqlErr` | `INTEGER` | L9 |
| `isamErr` | `INTEGER` | L10 |
| `text` | `varchar(255)` | L11 |
| `Cod_Retorno` | `char(5)` | L13 |
| `vc_CuentaOrdenante` | `CHAR(18)` | L14 |
| `vc_chrfolioprom` | `CHAR(16)` | L17 |
| `vc_vchrnombrebenef` | `CHAR(40)` | L18 |
| `vc_vchrconceppago` | `CHAR(210)` | L19 |
| `vc_chrestatusenvio` | `CHAR(1)` | L20 |
| `dc_mnyimporte` | `DECIMAL(19,2)` | L21 |
| `tmp_NumError` | `INTEGER` | L23 |
| `tmp_FuenteError` | `CHAR(7)` | L24 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tblpago` | `bdispei` | no | SELECT | L75 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `spobtenerccc` | `bditef` | ⚠️ sí | L67 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L35 | EXCEPCIÓN | `raise exception sqlErr, isamErr, text;` |  |
| L60 | VALIDACIÓN_NULL | `IF p_cta_ord  IS NULL OR p_fecha IS NULL OR p_cta_receptor IS NULL OR` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `cons` | ACCION | consulta | 🔵 CONVENCIÓN | nombre_sp |
| `?_ult_` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `pago` | ENTIDAD | pago | 🔵 CONVENCIÓN | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_ult_` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_consbancont`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_sp_consbancont.sql` |
| **LOC (1er CREATE)** | 41 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 3 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "consulta banco" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=1 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_consbancont(
) RETURNING CHAR(5)
```

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vchrcod_ret` | `CHAR(5)` | L3 |
| `sql_err` | `INTEGER` | L4 |
| `vintflag` | `INTEGER` | L5 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tblparametros` | `bdispei` | no | SELECT | L23 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `cons` | ACCION | consulta | 🔵 CONVENCIÓN | nombre_sp |
| `banco` | ENTIDAD | banco | 🔵 CONVENCIÓN | nombre_sp |
| `?nt` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?nt` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_consbancos`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_sp_consbancos.sql` |
| **LOC (1er CREATE)** | 59 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "consulta banco" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=1 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_consbancos(
  ult_reg                      smallint
) RETURNING char(5),	-- CodRet
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `ult_reg` | `smallint` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vchrcod_ret` | `char(5)` | L8 |
| `vintcvecesif` | `integer` | L9 |
| `vvchrnombre` | `varchar(60)` | L10 |
| `vvchrnomCorto` | `varchar(20)` | L11 |
| `sql_err` | `integer` | L12 |
| `vintContador` | `integer` | L13 |
| `vintPermiteCta11` | `integer` | L14 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tblparametros` | `bdispei` | no | SELECT | L33 |
| `tblbanco` | `bdispei` | no | SELECT | L44 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L36 | VALIDACIÓN_NULL | `if vintpermitecta11 is null then` |  |
| L37 | FÓRMULA | `let vchrcod_ret = '021'; --Falta parametro de permite cuenta.` |  |
| L49 | FÓRMULA | `let vintContador = vintContador + 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `cons` | ACCION | consulta | 🔵 CONVENCIÓN | nombre_sp |
| `banco` | ENTIDAD | banco | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?s` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?s` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_consctecte`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_sp_consctecte.sql` |
| **LOC (1er CREATE)** | 891 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "consulta cliente" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=4 · INFERIDO=0 · SINTÉTICO=0 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_consctecte(
  pchrSucursal                 CHAR(4)
  pvchrClaveRastreo            CHAR(30)
  pvchrCuentaOrd               CHAR(20)
  pintContador                 INTEGER
  pfecini                      CHAR(10)
  pfecfin                      CHAR(10)
) RETURNING CHAR(5),  CHAR(100), CHAR(40),      CHAR(20),      CHAR(20),  CHAR(40),
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pchrSucursal` | `CHAR(4)` | — | — |
| `pvchrClaveRastreo` | `CHAR(30)` | — | — |
| `pvchrCuentaOrd` | `CHAR(20)` | — | — |
| `pintContador` | `INTEGER` | — | — |
| `pfecini` | `CHAR(10)` | — | — |
| `pfecfin` | `CHAR(10)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vchrcodret` | `CHAR(5)` | L14 |
| `vchrcodret2` | `CHAR(5)` | L15 |
| `vchrcodret3` | `CHAR(50)` | L16 |
| `sql_err` | `INTEGER` | L17 |
| `isam_err` | `INTEGER` | L18 |
| `desc_err` | `CHAR(50)` | L19 |
| `cVarDataErr` | `CHAR(100)` | L20 |
| `vvchrNombreOrd` | `CHAR(40)` | L22 |
| `vvchrCuentaOrd` | `CHAR(20)` | L23 |
| `vvchrcteOrd` | `CHAR(20)` | L24 |
| `vvchrNombreBenef` | `CHAR(40)` | L25 |
| `vvchrCuentaBenef` | `CHAR(20)` | L26 |
| `vvchrRFCBenef` | `CHAR(18)` | L27 |
| `vvchrConceptoPago2` | `CHAR(40)` | L28 |
| `vintRefNumerica` | `DECIMAL(10,0)` | L29 |
| `vcveCesifbcodest` | `INTEGER` | L30 |
| `vvchrNombrecorto` | `CHAR(20)` | L31 |
| `vvchrEstatusenvio` | `CHAR(20)` | L32 |
| `vvchrClaverastreo` | `CHAR(30)` | L33 |
| `vdtmHoraCargo` | `CHAR(20)` | L34 |
| `vdtmHoraCancela` | `CHAR(20)` | L35 |
| `vvchrMotivodev` | `CHAR(255)` | L36 |
| `lcta` | `SMALLINT` | L37 |
| `btipo` | `SMALLINT` | L38 |
| `vintcontador` | `INTEGER` | L39 |
| *…24 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sc_tarjeta` | `bdicheq` | ⚠️ sí | SELECT | L166 |
| `tblparametros` | `bdispei` | no | SELECT | L213 |
| `tbldetranpago` | `bdispei` | no | SELECT | L284 |
| `sc_maechq` | `bdicheq` | ⚠️ sí | SELECT | L295 |
| `tblcausadev` | `bdispei` | no | SELECT | L334 |
| `sc_cuenta_telefono` | `bdicheq` | ⚠️ sí | SELECT | L359 |
| `sc_maechq_temp` | `bdicheq` | ⚠️ sí | SELECT | L391 |
| `sc_maechq_temp2` | `bdicheq` | ⚠️ sí | SELECT | L486 |
| `tblpago` | `bdispei` | no | SELECT | L676 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L171 | VALIDACIÓN_NULL | `IF TRIM(vcuenta) = '' OR vcuenta IS NULL THEN` |  |
| L216 | VALIDACIÓN_NULL | `IF vtrancomis IS NULL OR vtrancomis = '' THEN` |  |
| L226 | VALIDACIÓN_NULL | `IF vtraniva IS NULL OR vtraniva = '' THEN` |  |
| L236 | FÓRMULA | `LET vfechahoy = vcfechavalor[4,5]\|\|"/"\|\|vcfechavalor[1,2]\|\|"/"\|\|vcfechavalor[7,10];` |  |
| L237 | FÓRMULA | `LET vpri_dia_mes = vcfechavalor[4,5]\|\|'/'\|\|'01'\|\|'/'\|\|vcfechavalor[7,10];` |  |
| L241 | VALIDACIÓN_NULL | `IF pfecini is null OR pfecini = '' OR pfecini = ' ' THEN` |  |
| L242 | FÓRMULA | `LET vfechaini = vpri_dia_mes - 3 UNITS MONTH;` |  |
| L247 | VALIDACIÓN_NULL | `IF pfecfin is null OR pfecfin = '' OR pfecfin = ' ' THEN` |  |
| L248 | FÓRMULA | `LET vfechafin = vfechahoy - 1 UNITS DAY;` |  |
| L255 | VALIDACIÓN_NULL | `IF pfecini is null OR pfecini = '' OR pfecini = ' ' THEN` |  |
| L256 | FÓRMULA | `LET vfechaini = vfechahoy - 2 UNITS MONTH;` |  |
| L262 | VALIDACIÓN_NULL | `IF pfecfin is null OR pfecfin = '' OR pfecfin = ' ' THEN` |  |
| L263 | FÓRMULA | `LET vfechafin = vfechahoy - 1 UNITS DAY;` |  |
| L269 | FÓRMULA | `LET vfechaini_valida =  vfechahoy - 2 UNITS MONTH;` |  |
| L275 | FÓRMULA | `LET vfechaini = vfechahoy - 2 UNITS MONTH;` |  |
| L276 | FÓRMULA | `LET vfechafin = vfechahoy - 1 UNITS DAY;` |  |
| L329 | FÓRMULA | `LET vcfechavalor = TO_CHAR(vdfechavalor, '%d/%m/%Y');` |  |
| L331 | VALIDACIÓN_NULL | `IF NOT (vcausadev IS NULL or vcausadev = 0) THEN` |  |
| L422 | FÓRMULA | `LET vcfechavalor = TO_CHAR(vdfechavalor, '%d/%m/%Y');` |  |
| L424 | VALIDACIÓN_NULL | `IF NOT (vcausadev IS NULL or vcausadev = 0) then` |  |
| L450 | FÓRMULA | `LET vintcontador = vintcontador + 1;` |  |
| L544 | FÓRMULA | `LET vcfechavalor = to_char(vdfechavalor, '%d/%m/%Y');` |  |
| L546 | VALIDACIÓN_NULL | `IF NOT (vcausadev IS NULL or vcausadev = 0) THEN` |  |
| L572 | FÓRMULA | `LET vintcontador = vintcontador + 1;` |  |
| L623 | FÓRMULA | `LET vcfechavalor = to_char(vdfechavalor, '%d/%m/%Y');` |  |
| L625 | VALIDACIÓN_NULL | `IF NOT (vcausadev IS NULL or vcausadev = 0) THEN` |  |
| L651 | FÓRMULA | `LET vintcontador = vintcontador + 1;` |  |
| L728 | FÓRMULA | `LET vcfechavalor = TO_CHAR(vdfechavalor, '%d/%m/%Y');` |  |
| L730 | VALIDACIÓN_NULL | `IF NOT (vcausadev IS NULL or vcausadev = 0) THEN` |  |
| L756 | FÓRMULA | `LET vintcontador = vintcontador + 1;` |  |
| | *…3 más…* | | |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `cons` | ACCION | consulta | 🔵 CONVENCIÓN | nombre_sp |
| `cte` | ENTIDAD | cliente | 🔵 CONVENCIÓN | nombre_sp |
| `cte` | ENTIDAD | cliente | 🔵 CONVENCIÓN | nombre_sp |

---

## `sp_consctecte_exp1`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_sp_consctecte_exp1.sql` |
| **LOC (1er CREATE)** | 891 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "consulta cliente (sufijo Exportar — SP genera/exporta archivo de salida)" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo · `genera` → `SELECT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=4 · INFERIDO=1 · SINTÉTICO=1 / 6 términos |

### Firma

```sql
CREATE PROCEDURE sp_consctecte_exp1(
  pchrSucursal                 CHAR(4)
  pvchrClaveRastreo            CHAR(30)
  pvchrCuentaOrd               CHAR(20)
  pintContador                 INTEGER
  pfecini                      CHAR(10)
  pfecfin                      CHAR(10)
) RETURNING CHAR(5),  CHAR(100), CHAR(40),      CHAR(20),      CHAR(20),  CHAR(40),
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pchrSucursal` | `CHAR(4)` | — | — |
| `pvchrClaveRastreo` | `CHAR(30)` | — | — |
| `pvchrCuentaOrd` | `CHAR(20)` | — | — |
| `pintContador` | `INTEGER` | — | — |
| `pfecini` | `CHAR(10)` | — | — |
| `pfecfin` | `CHAR(10)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vchrcodret` | `CHAR(5)` | L14 |
| `vchrcodret2` | `CHAR(5)` | L15 |
| `vchrcodret3` | `CHAR(50)` | L16 |
| `sql_err` | `INTEGER` | L17 |
| `isam_err` | `INTEGER` | L18 |
| `desc_err` | `CHAR(50)` | L19 |
| `cVarDataErr` | `CHAR(100)` | L20 |
| `vvchrNombreOrd` | `CHAR(40)` | L22 |
| `vvchrCuentaOrd` | `CHAR(20)` | L23 |
| `vvchrcteOrd` | `CHAR(20)` | L24 |
| `vvchrNombreBenef` | `CHAR(40)` | L25 |
| `vvchrCuentaBenef` | `CHAR(20)` | L26 |
| `vvchrRFCBenef` | `CHAR(18)` | L27 |
| `vvchrConceptoPago2` | `CHAR(40)` | L28 |
| `vintRefNumerica` | `DECIMAL(10,0)` | L29 |
| `vcveCesifbcodest` | `INTEGER` | L30 |
| `vvchrNombrecorto` | `CHAR(20)` | L31 |
| `vvchrEstatusenvio` | `CHAR(20)` | L32 |
| `vvchrClaverastreo` | `CHAR(30)` | L33 |
| `vdtmHoraCargo` | `CHAR(20)` | L34 |
| `vdtmHoraCancela` | `CHAR(20)` | L35 |
| `vvchrMotivodev` | `CHAR(255)` | L36 |
| `lcta` | `SMALLINT` | L37 |
| `btipo` | `SMALLINT` | L38 |
| `vintcontador` | `INTEGER` | L39 |
| *…24 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sc_tarjeta` | `bdicheq` | ⚠️ sí | SELECT | L166 |
| `tblparametros` | `bdispei` | no | SELECT | L213 |
| `tbldetranpago` | `bdispei` | no | SELECT | L284 |
| `sc_maechq` | `bdicheq` | ⚠️ sí | SELECT | L295 |
| `tblcausadev` | `bdispei` | no | SELECT | L334 |
| `sc_cuenta_telefono` | `bdicheq` | ⚠️ sí | SELECT | L359 |
| `sc_maechq_temp` | `bdicheq` | ⚠️ sí | SELECT | L391 |
| `sc_maechq_temp2` | `bdicheq` | ⚠️ sí | SELECT | L486 |
| `tblpago` | `bdispei` | no | SELECT | L676 |
| `tblhistpago` | `bdispei` | no | SELECT | L692 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L171 | VALIDACIÓN_NULL | `IF TRIM(vcuenta) = '' OR vcuenta IS NULL THEN` |  |
| L216 | VALIDACIÓN_NULL | `IF vtrancomis IS NULL OR vtrancomis = '' THEN` |  |
| L226 | VALIDACIÓN_NULL | `IF vtraniva IS NULL OR vtraniva = '' THEN` |  |
| L236 | FÓRMULA | `LET vfechahoy = vcfechavalor[4,5]\|\|"/"\|\|vcfechavalor[1,2]\|\|"/"\|\|vcfechavalor[7,10];` |  |
| L237 | FÓRMULA | `LET vpri_dia_mes = vcfechavalor[4,5]\|\|'/'\|\|'01'\|\|'/'\|\|vcfechavalor[7,10];` |  |
| L241 | VALIDACIÓN_NULL | `IF pfecini is null OR pfecini = '' OR pfecini = ' ' THEN` |  |
| L242 | FÓRMULA | `LET vfechaini = vpri_dia_mes - 3 UNITS MONTH;` |  |
| L247 | VALIDACIÓN_NULL | `IF pfecfin is null OR pfecfin = '' OR pfecfin = ' ' THEN` |  |
| L248 | FÓRMULA | `LET vfechafin = vfechahoy - 1 UNITS DAY;` |  |
| L255 | VALIDACIÓN_NULL | `IF pfecini is null OR pfecini = '' OR pfecini = ' ' THEN` |  |
| L256 | FÓRMULA | `LET vfechaini = vfechahoy - 2 UNITS MONTH;` |  |
| L262 | VALIDACIÓN_NULL | `IF pfecfin is null OR pfecfin = '' OR pfecfin = ' ' THEN` |  |
| L263 | FÓRMULA | `LET vfechafin = vfechahoy - 1 UNITS DAY;` |  |
| L269 | FÓRMULA | `LET vfechaini_valida =  vfechahoy - 2 UNITS MONTH;` |  |
| L275 | FÓRMULA | `LET vfechaini = vfechahoy - 2 UNITS MONTH;` |  |
| L276 | FÓRMULA | `LET vfechafin = vfechahoy - 1 UNITS DAY;` |  |
| L329 | FÓRMULA | `LET vcfechavalor = TO_CHAR(vdfechavalor, '%d/%m/%Y');` |  |
| L331 | VALIDACIÓN_NULL | `IF NOT (vcausadev IS NULL or vcausadev = 0) THEN` |  |
| L422 | FÓRMULA | `LET vcfechavalor = TO_CHAR(vdfechavalor, '%d/%m/%Y');` |  |
| L424 | VALIDACIÓN_NULL | `IF NOT (vcausadev IS NULL or vcausadev = 0) then` |  |
| L450 | FÓRMULA | `LET vintcontador = vintcontador + 1;` |  |
| L544 | FÓRMULA | `LET vcfechavalor = to_char(vdfechavalor, '%d/%m/%Y');` |  |
| L546 | VALIDACIÓN_NULL | `IF NOT (vcausadev IS NULL or vcausadev = 0) THEN` |  |
| L572 | FÓRMULA | `LET vintcontador = vintcontador + 1;` |  |
| L623 | FÓRMULA | `LET vcfechavalor = to_char(vdfechavalor, '%d/%m/%Y');` |  |
| L625 | VALIDACIÓN_NULL | `IF NOT (vcausadev IS NULL or vcausadev = 0) THEN` |  |
| L651 | FÓRMULA | `LET vintcontador = vintcontador + 1;` |  |
| L728 | FÓRMULA | `LET vcfechavalor = TO_CHAR(vdfechavalor, '%d/%m/%Y');` |  |
| L730 | VALIDACIÓN_NULL | `IF NOT (vcausadev IS NULL or vcausadev = 0) THEN` |  |
| L756 | FÓRMULA | `LET vintcontador = vintcontador + 1;` |  |
| | *…3 más…* | | |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `cons` | ACCION | consulta | 🔵 CONVENCIÓN | nombre_sp |
| `cte` | ENTIDAD | cliente | 🔵 CONVENCIÓN | nombre_sp |
| `cte` | ENTIDAD | cliente | 🔵 CONVENCIÓN | nombre_sp |
| `exp` | MODIF | sufijo Exportar — SP genera/exporta archivo de salida (sp_*_ | 🟡 INFERIDO | nombre_sp |
| `?1` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?1` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_consctecte_web`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_sp_consctecte_web.sql` |
| **LOC (1er CREATE)** | 900 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "consulta cliente (canal web)" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=5 · INFERIDO=0 · SINTÉTICO=0 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_consctecte_web(
  pchrSucursal                 CHAR(4)
  pvchrClaveRastreo            CHAR(30)
  pvchrCuentaOrd               CHAR(20)
  pintContador                 INTEGER
  pfecini                      CHAR(10)
  pfecfin                      CHAR(10)
) RETURNING CHAR(5),  CHAR(100), CHAR(40),      CHAR(20),      CHAR(20),  CHAR(40),
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pchrSucursal` | `CHAR(4)` | — | — |
| `pvchrClaveRastreo` | `CHAR(30)` | — | — |
| `pvchrCuentaOrd` | `CHAR(20)` | — | — |
| `pintContador` | `INTEGER` | — | — |
| `pfecini` | `CHAR(10)` | — | — |
| `pfecfin` | `CHAR(10)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vchrcodret` | `CHAR(5)` | L14 |
| `vchrcodret2` | `CHAR(5)` | L15 |
| `vchrcodret3` | `CHAR(50)` | L16 |
| `sql_err` | `INTEGER` | L17 |
| `isam_err` | `INTEGER` | L18 |
| `desc_err` | `CHAR(50)` | L19 |
| `cVarDataErr` | `CHAR(100)` | L20 |
| `vvchrNombreOrd` | `CHAR(40)` | L22 |
| `vvchrCuentaOrd` | `CHAR(20)` | L23 |
| `vvchrcteOrd` | `CHAR(20)` | L24 |
| `vvchrNombreBenef` | `CHAR(40)` | L25 |
| `vvchrCuentaBenef` | `CHAR(20)` | L26 |
| `vvchrRFCBenef` | `CHAR(18)` | L27 |
| `vvchrConceptoPago2` | `CHAR(40)` | L28 |
| `vintRefNumerica` | `DECIMAL(10,0)` | L29 |
| `vcveCesifbcodest` | `INTEGER` | L30 |
| `vvchrNombrecorto` | `CHAR(20)` | L31 |
| `vvchrEstatusenvio` | `CHAR(20)` | L32 |
| `vvchrClaverastreo` | `CHAR(30)` | L33 |
| `vdtmHoraCargo` | `CHAR(20)` | L34 |
| `vdtmHoraCancela` | `CHAR(20)` | L35 |
| `vvchrMotivodev` | `CHAR(255)` | L36 |
| `lcta` | `SMALLINT` | L37 |
| `btipo` | `SMALLINT` | L38 |
| `vintcontador` | `INTEGER` | L39 |
| *…24 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sc_tarjeta` | `bdicheq` | ⚠️ sí | SELECT | L166 |
| `tblparametros` | `bdispei` | no | SELECT | L213 |
| `tbldetranpago` | `bdispei` | no | SELECT | L284 |
| `sc_maechq` | `bdicheq` | ⚠️ sí | SELECT | L295 |
| `tblcausadev` | `bdispei` | no | SELECT | L334 |
| `sc_cuenta_telefono` | `bdicheq` | ⚠️ sí | SELECT | L359 |
| `sc_maechq_temp` | `bdicheq` | ⚠️ sí | SELECT | L391 |
| `sc_maechq_temp2` | `bdicheq` | ⚠️ sí | SELECT | L486 |
| `tblpago` | `bdispei` | no | SELECT | L676 |
| `tblhistpago` | `bdispei` | no | SELECT | L693 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L67 | CÓDIGO_RETORNO | `LET vchrcodret 	       = '00000';` |  |
| L171 | VALIDACIÓN_NULL | `IF TRIM(vcuenta) = '' OR vcuenta IS NULL THEN` |  |
| L172 | CÓDIGO_RETORNO | `LET vchrcodret = '00031';` |  |
| L182 | CÓDIGO_RETORNO | `LET vchrcodret = '00031';` |  |
| L193 | CÓDIGO_RETORNO | `LET vchrcodret = '00031';` |  |
| L216 | VALIDACIÓN_NULL | `IF vtrancomis IS NULL OR vtrancomis = '' THEN` |  |
| L226 | VALIDACIÓN_NULL | `IF vtraniva IS NULL OR vtraniva = '' THEN` |  |
| L236 | FÓRMULA | `LET vfechahoy = vcfechavalor[4,5]\|\|"/"\|\|vcfechavalor[1,2]\|\|"/"\|\|vcfechavalor[7,10];` |  |
| L237 | FÓRMULA | `LET vpri_dia_mes = vcfechavalor[4,5]\|\|'/'\|\|'01'\|\|'/'\|\|vcfechavalor[7,10];` |  |
| L241 | VALIDACIÓN_NULL | `IF pfecini is null OR pfecini = '' OR pfecini = ' ' THEN` |  |
| L242 | FÓRMULA | `LET vfechaini = vpri_dia_mes - 3 UNITS MONTH;` |  |
| L247 | VALIDACIÓN_NULL | `IF pfecfin is null OR pfecfin = '' OR pfecfin = ' ' THEN` |  |
| L248 | FÓRMULA | `LET vfechafin = vfechahoy - 1 UNITS DAY;` |  |
| L255 | VALIDACIÓN_NULL | `IF pfecini is null OR pfecini = '' OR pfecini = ' ' THEN` |  |
| L256 | FÓRMULA | `LET vfechaini = vfechahoy - 2 UNITS MONTH;` |  |
| L262 | VALIDACIÓN_NULL | `IF pfecfin is null OR pfecfin = '' OR pfecfin = ' ' THEN` |  |
| L263 | FÓRMULA | `LET vfechafin = vfechahoy - 1 UNITS DAY;` |  |
| L269 | FÓRMULA | `LET vfechaini_valida =  vfechahoy - 2 UNITS MONTH;` |  |
| L275 | FÓRMULA | `LET vfechaini = vfechahoy - 2 UNITS MONTH;` |  |
| L276 | FÓRMULA | `LET vfechafin = vfechahoy - 1 UNITS DAY;` |  |
| L329 | FÓRMULA | `LET vcfechavalor = TO_CHAR(vdfechavalor, '%d/%m/%Y');` |  |
| L331 | VALIDACIÓN_NULL | `IF NOT (vcausadev IS NULL or vcausadev = 0) THEN` |  |
| L422 | FÓRMULA | `LET vcfechavalor = TO_CHAR(vdfechavalor, '%d/%m/%Y');` |  |
| L424 | VALIDACIÓN_NULL | `IF NOT (vcausadev IS NULL or vcausadev = 0) then` |  |
| L450 | FÓRMULA | `LET vintcontador = vintcontador + 1;` |  |
| L544 | FÓRMULA | `LET vcfechavalor = to_char(vdfechavalor, '%d/%m/%Y');` |  |
| L546 | VALIDACIÓN_NULL | `IF NOT (vcausadev IS NULL or vcausadev = 0) THEN` |  |
| L572 | FÓRMULA | `LET vintcontador = vintcontador + 1;` |  |
| L623 | FÓRMULA | `LET vcfechavalor = to_char(vdfechavalor, '%d/%m/%Y');` |  |
| L625 | VALIDACIÓN_NULL | `IF NOT (vcausadev IS NULL or vcausadev = 0) THEN` |  |
| | *…8 más…* | | |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `cons` | ACCION | consulta | 🔵 CONVENCIÓN | nombre_sp |
| `cte` | ENTIDAD | cliente | 🔵 CONVENCIÓN | nombre_sp |
| `cte` | ENTIDAD | cliente | 🔵 CONVENCIÓN | nombre_sp |
| `web` | MODIF | canal web | 🔵 CONVENCIÓN | nombre_sp |

---

## `sp_consctectehist`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_sp_consctectehist.sql` |
| **LOC (1er CREATE)** | 256 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "consulta cliente (histórico/historial)" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=5 · INFERIDO=0 · SINTÉTICO=0 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_consctectehist(
  pSucursal                    CHAR(4)
  pFechaInicial                CHAR(10)
  pFechaFinal                  CHAR(10)
  pContador                    INTEGER
) RETURNING CHAR(5), CHAR(100), CHAR(40), CHAR(20), CHAR(20), CHAR(40),
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pSucursal` | `CHAR(4)` | — | — |
| `pFechaInicial` | `CHAR(10)` | — | — |
| `pFechaFinal` | `CHAR(10)` | — | — |
| `pContador` | `INTEGER` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(5)` | L10 |
| `cCodRet2` | `CHAR(5)` | L11 |
| `cCodRet3` | `CHAR(50)` | L12 |
| `iSql_Err` | `INTEGER` | L13 |
| `iIsam_Err` | `INTEGER` | L14 |
| `cDesc_Err` | `CHAR(50)` | L15 |
| `cDataErr` | `CHAR(100)` | L16 |
| `cNombreOrd` | `CHAR(40)` | L18 |
| `cCuentaOrd` | `CHAR(20)` | L19 |
| `cCteOrd` | `CHAR(20)` | L20 |
| `cNombreBenef` | `CHAR(40)` | L21 |
| `cCuentaBenef` | `CHAR(20)` | L22 |
| `cRFCBenef` | `CHAR(18)` | L23 |
| `cConceptoPago2` | `CHAR(40)` | L24 |
| `iRefNumerica` | `DECIMAL(10,0)` | L25 |
| `vcveCesifbcodest` | `INTEGER` | L26 |
| `cNombrecorto` | `CHAR(20)` | L27 |
| `cEstatusenvio` | `CHAR(20)` | L28 |
| `cClaverastreo` | `CHAR(30)` | L29 |
| `cHoraCargo` | `CHAR(20)` | L30 |
| `cHoraCancela` | `CHAR(20)` | L31 |
| `cMotivodev` | `CHAR(255)` | L32 |
| `lcta` | `SMALLINT` | L33 |
| `btipo` | `SMALLINT` | L34 |
| `icontador` | `INTEGER` | L35 |
| *…13 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tblparametros` | `bdispei` | no | SELECT | L132 |
| `tbldetranpago` | `bdispei` | no | SELECT | L164 |
| `tblhistdetranpago` | `bdispei` | no | SELECT | L182 |
| `sc_maechq` | `bdicheq` | ⚠️ sí | SELECT | L195 |
| `sc_cuenta_telefono` | `bdicheq` | ⚠️ sí | SELECT | L201 |
| `tblcausadev` | `bdispei` | no | SELECT | L219 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L120 | VALIDACIÓN_NULL | `IF TRIM(pSucursal) = '' OR TRIM(pFechaInicial) = '' OR TRIM(pFechaFinal) = '' OR pSucursal IS NULL O` |  |
| L121 | CÓDIGO_RETORNO | `LET cCodRet = '00001';` |  |
| L136 | VALIDACIÓN_NULL | `IF cTranComis IS NULL OR cTranComis = '' THEN` |  |
| L147 | VALIDACIÓN_NULL | `IF cTranIva IS NULL OR cTranIva = '' THEN` |  |
| L214 | FÓRMULA | `LET cFechaValor = TO_CHAR(vdfechavalor, '%d/%m/%Y');` |  |
| L216 | VALIDACIÓN_NULL | `IF NOT (iCausaDev IS NULL OR iCausaDev = 0) THEN` |  |
| L242 | FÓRMULA | `LET icontador = icontador + 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `cons` | ACCION | consulta | 🔵 CONVENCIÓN | nombre_sp |
| `cte` | ENTIDAD | cliente | 🔵 CONVENCIÓN | nombre_sp |
| `cte` | ENTIDAD | cliente | 🔵 CONVENCIÓN | nombre_sp |
| `hist` | MODIF | histórico/historial | 🔵 CONVENCIÓN | nombre_sp |

---

## `sp_consctectehist_exp1`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_sp_consctectehist_exp1.sql` |
| **LOC (1er CREATE)** | 256 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "consulta cliente (histórico/historial, sufijo Exportar — SP genera/exporta archivo de salida)" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo · `genera` → `SELECT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=5 · INFERIDO=1 · SINTÉTICO=1 / 7 términos |

### Firma

```sql
CREATE PROCEDURE sp_consctectehist_exp1(
  pSucursal                    CHAR(4)
  pFechaInicial                CHAR(10)
  pFechaFinal                  CHAR(10)
  pContador                    INTEGER
) RETURNING CHAR(5), CHAR(100), CHAR(40), CHAR(20), CHAR(20), CHAR(40),
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pSucursal` | `CHAR(4)` | — | — |
| `pFechaInicial` | `CHAR(10)` | — | — |
| `pFechaFinal` | `CHAR(10)` | — | — |
| `pContador` | `INTEGER` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(5)` | L10 |
| `cCodRet2` | `CHAR(5)` | L11 |
| `cCodRet3` | `CHAR(50)` | L12 |
| `iSql_Err` | `INTEGER` | L13 |
| `iIsam_Err` | `INTEGER` | L14 |
| `cDesc_Err` | `CHAR(50)` | L15 |
| `cDataErr` | `CHAR(100)` | L16 |
| `cNombreOrd` | `CHAR(40)` | L18 |
| `cCuentaOrd` | `CHAR(20)` | L19 |
| `cCteOrd` | `CHAR(20)` | L20 |
| `cNombreBenef` | `CHAR(40)` | L21 |
| `cCuentaBenef` | `CHAR(20)` | L22 |
| `cRFCBenef` | `CHAR(18)` | L23 |
| `cConceptoPago2` | `CHAR(40)` | L24 |
| `iRefNumerica` | `DECIMAL(10,0)` | L25 |
| `vcveCesifbcodest` | `INTEGER` | L26 |
| `cNombrecorto` | `CHAR(20)` | L27 |
| `cEstatusenvio` | `CHAR(20)` | L28 |
| `cClaverastreo` | `CHAR(30)` | L29 |
| `cHoraCargo` | `CHAR(20)` | L30 |
| `cHoraCancela` | `CHAR(20)` | L31 |
| `cMotivodev` | `CHAR(255)` | L32 |
| `lcta` | `SMALLINT` | L33 |
| `btipo` | `SMALLINT` | L34 |
| `icontador` | `INTEGER` | L35 |
| *…13 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tblparametros` | `bdispei` | no | SELECT | L132 |
| `tbldetranpago` | `bdispei` | no | SELECT | L164 |
| `tblhistdetranpago` | `bdispei` | no | SELECT | L182 |
| `sc_maechq` | `bdicheq` | ⚠️ sí | SELECT | L195 |
| `sc_cuenta_telefono` | `bdicheq` | ⚠️ sí | SELECT | L201 |
| `tblcausadev` | `bdispei` | no | SELECT | L219 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L120 | VALIDACIÓN_NULL | `IF TRIM(pSucursal) = '' OR TRIM(pFechaInicial) = '' OR TRIM(pFechaFinal) = '' OR pSucursal IS NULL O` |  |
| L121 | CÓDIGO_RETORNO | `LET cCodRet = '00001';` |  |
| L136 | VALIDACIÓN_NULL | `IF cTranComis IS NULL OR cTranComis = '' THEN` |  |
| L147 | VALIDACIÓN_NULL | `IF cTranIva IS NULL OR cTranIva = '' THEN` |  |
| L214 | FÓRMULA | `LET cFechaValor = TO_CHAR(vdfechavalor, '%d/%m/%Y');` |  |
| L216 | VALIDACIÓN_NULL | `IF NOT (iCausaDev IS NULL OR iCausaDev = 0) THEN` |  |
| L242 | FÓRMULA | `LET icontador = icontador + 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `cons` | ACCION | consulta | 🔵 CONVENCIÓN | nombre_sp |
| `cte` | ENTIDAD | cliente | 🔵 CONVENCIÓN | nombre_sp |
| `cte` | ENTIDAD | cliente | 🔵 CONVENCIÓN | nombre_sp |
| `hist` | MODIF | histórico/historial | 🔵 CONVENCIÓN | nombre_sp |
| `exp` | MODIF | sufijo Exportar — SP genera/exporta archivo de salida (sp_*_ | 🟡 INFERIDO | nombre_sp |
| `?1` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?1` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_consctectehist_pbas`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_sp_consctectehist_pbas.sql` |
| **LOC (1er CREATE)** | 222 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "consulta cliente (histórico/historial, PBA — sufijo de SPs para Pruebas; confirmado por SME)" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo · `confirma` → `SELECT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=6 · INFERIDO=0 · SINTÉTICO=1 / 7 términos |

### Firma

```sql
CREATE PROCEDURE sp_consctectehist_pbas(
  pSucursal                    CHAR(4)
  pFechaInicial                CHAR(10)
  pFechaFinal                  CHAR(10)
  pContador                    INTEGER
) RETURNING CHAR(5), CHAR(100), CHAR(40), CHAR(20), CHAR(20), CHAR(40),
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pSucursal` | `CHAR(4)` | — | — |
| `pFechaInicial` | `CHAR(10)` | — | — |
| `pFechaFinal` | `CHAR(10)` | — | — |
| `pContador` | `INTEGER` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(5)` | L10 |
| `cCodRet2` | `CHAR(5)` | L11 |
| `cCodRet3` | `CHAR(50)` | L12 |
| `iSql_Err` | `INTEGER` | L13 |
| `iIsam_Err` | `INTEGER` | L14 |
| `cDesc_Err` | `CHAR(50)` | L15 |
| `cDataErr` | `CHAR(100)` | L16 |
| `cNombreOrd` | `CHAR(40)` | L18 |
| `cCuentaOrd` | `CHAR(20)` | L19 |
| `cCteOrd` | `CHAR(20)` | L20 |
| `cNombreBenef` | `CHAR(40)` | L21 |
| `cCuentaBenef` | `CHAR(20)` | L22 |
| `cRFCBenef` | `CHAR(18)` | L23 |
| `cConceptoPago2` | `CHAR(40)` | L24 |
| `iRefNumerica` | `DECIMAL(10,0)` | L25 |
| `vcveCesifbcodest` | `INTEGER` | L26 |
| `cNombrecorto` | `CHAR(20)` | L27 |
| `cEstatusenvio` | `CHAR(20)` | L28 |
| `cClaverastreo` | `CHAR(30)` | L29 |
| `cHoraCargo` | `CHAR(20)` | L30 |
| `cHoraCancela` | `CHAR(20)` | L31 |
| `cMotivodev` | `CHAR(255)` | L32 |
| `lcta` | `SMALLINT` | L33 |
| `btipo` | `SMALLINT` | L34 |
| `icontador` | `INTEGER` | L35 |
| *…13 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tblparametros` | `bdispei` | no | SELECT | L129 |
| `tblhistdetranpago` | `bdispei` | no | SELECT | L161 |
| `tblcausadev` | `bdispei` | no | SELECT | L185 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L117 | VALIDACIÓN_NULL | `IF TRIM(pSucursal) = '' OR TRIM(pFechaInicial) = '' OR TRIM(pFechaFinal) = '' OR pSucursal IS NULL O` |  |
| L118 | CÓDIGO_RETORNO | `LET cCodRet = '00001';` |  |
| L133 | VALIDACIÓN_NULL | `IF cTranComis IS NULL OR cTranComis = '' THEN` |  |
| L144 | VALIDACIÓN_NULL | `IF cTranIva IS NULL OR cTranIva = '' THEN` |  |
| L180 | FÓRMULA | `LET cFechaValor = TO_CHAR(vdfechavalor, '%d/%m/%Y');` |  |
| L182 | VALIDACIÓN_NULL | `IF NOT (iCausaDev IS NULL OR iCausaDev = 0) THEN` |  |
| L208 | FÓRMULA | `LET icontador = icontador + 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `cons` | ACCION | consulta | 🔵 CONVENCIÓN | nombre_sp |
| `cte` | ENTIDAD | cliente | 🔵 CONVENCIÓN | nombre_sp |
| `cte` | ENTIDAD | cliente | 🔵 CONVENCIÓN | nombre_sp |
| `hist` | MODIF | histórico/historial | 🔵 CONVENCIÓN | nombre_sp |
| `pba` | MODIF | PBA — sufijo de SPs para Pruebas; confirmado por SME (Guerra | 🔵 CONVENCIÓN | nombre_sp |
| `?s` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?s` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_consctectehist_web`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_sp_consctectehist_web.sql` |
| **LOC (1er CREATE)** | 308 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "consulta cliente (histórico/historial, canal web)" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=6 · INFERIDO=0 · SINTÉTICO=0 / 6 términos |

### Firma

```sql
CREATE PROCEDURE sp_consctectehist_web(
  pSucursal                    CHAR(4)
  pFechaInicial                CHAR(10)
  pFechaFinal                  CHAR(10)
  pContador                    INTEGER
) RETURNING CHAR(5), CHAR(100), CHAR(40), CHAR(20), CHAR(20), CHAR(40),
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pSucursal` | `CHAR(4)` | — | — |
| `pFechaInicial` | `CHAR(10)` | — | — |
| `pFechaFinal` | `CHAR(10)` | — | — |
| `pContador` | `INTEGER` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(5)` | L11 |
| `cCodRet2` | `CHAR(5)` | L12 |
| `cCodRet3` | `CHAR(50)` | L13 |
| `iSql_Err` | `INTEGER` | L14 |
| `iIsam_Err` | `INTEGER` | L15 |
| `cDesc_Err` | `CHAR(50)` | L16 |
| `cDataErr` | `CHAR(100)` | L17 |
| `cNombreOrd` | `CHAR(40)` | L19 |
| `cCuentaOrd` | `CHAR(20)` | L20 |
| `cCteOrd` | `CHAR(20)` | L21 |
| `cNombreBenef` | `CHAR(40)` | L22 |
| `cCuentaBenef` | `CHAR(20)` | L23 |
| `cRFCBenef` | `CHAR(18)` | L24 |
| `cConceptoPago2` | `CHAR(40)` | L25 |
| `iRefNumerica` | `DECIMAL(10,0)` | L26 |
| `vcveCesifbcodest` | `INTEGER` | L27 |
| `cNombrecorto` | `CHAR(20)` | L28 |
| `cEstatusenvio` | `CHAR(20)` | L29 |
| `cClaverastreo` | `CHAR(30)` | L30 |
| `cHoraCargo` | `CHAR(20)` | L31 |
| `cHoraCancela` | `CHAR(20)` | L32 |
| `cMotivodev` | `CHAR(255)` | L33 |
| `lcta` | `SMALLINT` | L34 |
| `btipo` | `SMALLINT` | L35 |
| `icontador` | `INTEGER` | L36 |
| *…13 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tblparametros` | `bdispei` | no | SELECT | L130 |
| `tbldetranpago` | `bdispei` | no | SELECT | L189 |
| `tblhistdetranpago` | `bdispei` | no | SELECT | L227 |
| `sc_maechq` | `bdicheq` | ⚠️ sí | SELECT | L240 |
| `sc_cuenta_telefono` | `bdicheq` | ⚠️ sí | SELECT | L246 |
| `tblcausadev` | `bdispei` | no | SELECT | L267 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L52 | CÓDIGO_RETORNO | `LET cCodRet 	       	= '00000';` |  |
| L118 | VALIDACIÓN_NULL | `IF TRIM(pSucursal) = '' OR TRIM(pFechaInicial) = '' OR TRIM(pFechaFinal) = '' OR pSucursal IS NULL O` |  |
| L119 | CÓDIGO_RETORNO | `LET cCodRet = '00001';` |  |
| L134 | VALIDACIÓN_NULL | `IF cTranComis IS NULL OR cTranComis = '' THEN` |  |
| L145 | VALIDACIÓN_NULL | `IF cTranIva IS NULL OR cTranIva = '' THEN` |  |
| L262 | FÓRMULA | `LET cFechaValor = TO_CHAR(vdfechavalor, '%d/%m/%Y');` |  |
| L264 | VALIDACIÓN_NULL | `IF NOT (iCausaDev IS NULL OR iCausaDev = 0) THEN` |  |
| L290 | FÓRMULA | `LET icontador = icontador + 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `cons` | ACCION | consulta | 🔵 CONVENCIÓN | nombre_sp |
| `cte` | ENTIDAD | cliente | 🔵 CONVENCIÓN | nombre_sp |
| `cte` | ENTIDAD | cliente | 🔵 CONVENCIÓN | nombre_sp |
| `hist` | MODIF | histórico/historial | 🔵 CONVENCIÓN | nombre_sp |
| `web` | MODIF | canal web | 🔵 CONVENCIÓN | nombre_sp |

---

## `sp_consulta_credspei`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_sp_consulta_credspei.sql` |
| **LOC (1er CREATE)** | 83 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "consulta crédito" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=4 · INFERIDO=0 · SINTÉTICO=0 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_consulta_credspei(
  pEmpresa                     CHAR(3)
) RETURNING CHAR(5), CHAR(30), CHAR(18), DECIMAL(15,2), SMALLINT
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pEmpresa` | `CHAR(3)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(5)` | L4 |
| `cCodRet2` | `CHAR(5)` | L5 |
| `cCodRet3` | `CHAR(50)` | L6 |
| `iSqlErr` | `INTEGER` | L7 |
| `iSamErr` | `INTEGER` | L8 |
| `cDesErr` | `CHAR(50)` | L9 |
| `cCveRastreo` | `CHAR(30)` | L11 |
| `cCuentaClabe` | `CHAR(18)` | L12 |
| `dMonto` | `DECIMAL(15,2)` | L13 |
| `iTpoPago` | `SMALLINT` | L14 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tblpagocred` | `bdispei` | no | SELECT | L50 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `consulta` | ACCION | consulta / lee | 🔵 CONVENCIÓN | nombre_sp |
| `cred` | ENTIDAD | crédito | 🔵 CONVENCIÓN | nombre_sp |
| `spei` | PREFIJO | familia SPEI (pagos interbancarios) | 🔵 CONVENCIÓN | nombre_sp |

---

## `sp_consultamovspei`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_sp_consultamovspei.sql` |
| **LOC (1er CREATE)** | 73 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 1 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "consulta movimientos" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=2 · INFERIDO=1 · SINTÉTICO=1 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_consultamovspei(
  pFecha                       DATE
  pSucursal                    CHAR(4)
) RETURNING CHAR(5) AS rCod_retorno,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pFecha` | `DATE` | — | — |
| `pSucursal` | `CHAR(4)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `iSql_err` | `INTEGER` | L8 |
| `cCod_retorno` | `CHAR(5)` | L9 |
| `cMensaje` | `VARCHAR(50)` | L10 |
| `cClaveRastreo` | `VARCHAR(30)` | L11 |
| `iCount` | `INTEGER` | L13 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `consulta` | ACCION | consulta / lee | 🔵 CONVENCIÓN | nombre_sp |
| `movs` | ENTIDAD | movimientos (abreviación) | 🟡 INFERIDO | nombre_sp |
| `?pei` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?pei` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_depura_tbl_registro_msj`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_sp_depura_tbl_registro_msj.sql` |
| **LOC (1er CREATE)** | 135 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "depura tbl — tabla, registro y mensaje — abreviación corta de mnsj" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `depura` → `DELETE` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=3 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=0 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_depura_tbl_registro_msj(
  pempresa                     CHAR(3)
) RETURNING CHAR(5), INTEGER
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pempresa` | `CHAR(3)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet1` | `CHAR(5)` | L4 |
| `cCodRet2` | `CHAR(5)` | L5 |
| `cCodRet3` | `CHAR(80)` | L6 |
| `sql_err` | `INTEGER` | L7 |
| `isam_err` | `INTEGER` | L8 |
| `desc_err` | `CHAR(80)` | L9 |
| `iContador1` | `INTEGER` | L10 |
| `iContador2` | `INTEGER` | L11 |
| `iComienza` | `SMALLINT` | L12 |
| `iTransacc` | `SMALLINT` | L13 |
| `cNumCte` | `CHAR(20)` | L15 |
| `cTipoMsj` | `CHAR(1)` | L16 |
| `cStr1` | `CHAR(30)` | L17 |
| `cStr2` | `CHAR(30)` | L18 |
| `cStr3` | `CHAR(30)` | L19 |
| `cStr4` | `CHAR(30)` | L20 |
| `cStr5` | `CHAR(150)` | L21 |
| `dFecha1` | `DATETIME YEAR TO FRACTION(3)` | L22 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tbl_registro_msj` | `bdispei` | no | SELECT | L70 |
| `tbl_registro_msj_hist` | `bdispei` | no | INSERT | L82 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L32 | FÓRMULA | `LET iComienza  = -1;` |  |
| L107 | FÓRMULA | `LET iContador1 = iContador1 + 1;` |  |
| L108 | FÓRMULA | `LET iContador2 = iContador2 + 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `depura` | ACCION | depura / limpia | 🔵 CONVENCIÓN | nombre_sp |
| `tbl` | ENTIDAD | tbl — tabla (abreviación — sp_depura_tbl_registro_msj) | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `registro` | ENTIDAD | registro | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `msj` | ENTIDAD | mensaje — abreviación corta de mnsj (sp_validacion_msj) | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |

---

## `sp_ensesion12`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_sp_ensesion12.sql` |
| **LOC (1er CREATE)** | 54 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "sp_ensesion12" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 2 tabla(s) con operaciones: UPDATE |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=1 / 2 términos |

### Firma

```sql
CREATE PROCEDURE sp_ensesion12(
  pcvecesif                    integer
) RETURNING char(5)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pcvecesif` | `integer` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vcodret` | `char(5)` | L21 |
| `vsqlerr` | `int` | L22 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tblbanco` | `bdispei` | no | UPDATE | L39 |
| `tblcertificado` | `bdispei` | no | UPDATE | L43 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `?_ensesion12` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_ensesion12` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_ensesion3`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_sp_ensesion3.sql` |
| **LOC (1er CREATE)** | 59 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "sp_ensesion3" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 3 tabla(s) con operaciones: INSERT, SELECT, UPDATE |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=1 / 2 términos |

### Firma

```sql
CREATE PROCEDURE sp_ensesion3(
  pcvecesif                    integer
  pnomcorto                    varchar(20)
  pintindice                   integer
  pedobco                      char
  pbcoreceptivo                char
) RETURNING char(5)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pcvecesif` | `integer` | — | — |
| `pnomcorto` | `varchar(20)` | — | — |
| `pintindice` | `integer` | — | — |
| `pedobco` | `char` | — | — |
| `pbcoreceptivo` | `char` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vcodret` | `char(5)` | L27 |
| `vsqlerr` | `int` | L28 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tblbanco` | `bdispei` | no | SELECT | L44 |
| `tblbanco` | `bdispei` | no | INSERT | L46 |
| `tblbanco` | `bdispei` | no | UPDATE | L49 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `?_ensesion3` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_ensesion3` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_extraeinfospeua`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_sp_extraeinfospeua.sql` |
| **LOC (1er CREATE)** | 387 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "información" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 2 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=3 / 7 términos |

### Firma

```sql
CREATE PROCEDURE sp_extraeinfospeua(
  ve_fecha                     char(10)
  ve_estatus                   char(1)
  ve_tipomov                   char(2)
  ve_tipocon                   char(1)
) RETURNING char(5),     -- cod_ret
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `ve_fecha` | `char(10)` | — | — |
| `ve_estatus` | `char(1)` | — | — |
| `ve_tipomov` | `char(2)` | — | — |
| `ve_tipocon` | `char(1)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cod_ret` | `char(5)` | L22 |
| `sql_err` | `integer` | L23 |
| `vt_clave_rastreo` | `char(30)` | L24 |
| `vt_importe` | `money(16,2)` | L25 |
| `vt_banco` | `char(4)` | L26 |
| `vt_nombre1` | `char(30)` | L27 |
| `vt_cuenta` | `char(20)` | L28 |
| `vt_nombre2` | `char(30)` | L29 |
| `vt_estatus` | `char(1)` | L30 |
| `vt_fecha` | `date` | L31 |
| `vt_fechaSPEIBco` | `date` | L33 |
| `ve_estatusLiq` | `char(1)` | L34 |
| `ve_estatusXConf` | `char(1)` | L35 |
| `ve_estatusDev` | `char(1)` | L36 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tblparametros` | `bdispei` | no | SELECT | L84 |
| `tblpago` | `bdispei` | no | SELECT | L122 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L62 | VALIDACIÓN_NULL | `if (ve_fecha is null or ve_fecha  = '') or` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `?_e` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `x` | MODIF | por (criterio) | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?trae` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `info` | ENTIDAD | información | 🔵 CONVENCIÓN | nombre_sp |
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `?eua` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_e`, `?trae`, `?eua` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_gen_msj`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_sp_gen_msj.sql` |
| **LOC (1er CREATE)** | 156 |
| **Callgraph** | ✅ fan_in=0 / fan_out=1 |
| **Propósito inferido** | "genera mensaje — abreviación corta de mnsj" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `genera` → `SELECT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=1 · INFERIDO=1 · SINTÉTICO=0 / 3 términos |

### Firma

```sql
CREATE PROCEDURE sp_gen_msj(
  pEmpresa                     CHAR(3)
  pRegistros                   INTEGER
) RETURNING CHAR(5)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pEmpresa` | `CHAR(3)` | — | — |
| `pRegistros` | `INTEGER` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vsqlerr` | `INTEGER` | L4 |
| `vcodret` | `CHAR(5)` | L5 |
| `v_pTipoMsj` | `char(1)` | L7 |
| `v_pIdMsj` | `char(10)` | L8 |
| `v_pIdPlantilla` | `char(12)` | L9 |
| `v_pNumclt` | `char(20)` | L10 |
| `v_pNumcta` | `char(20)` | L11 |
| `v_pNumTarjeta` | `char(16)` | L12 |
| `v_pTipoproc` | `char(1)` | L13 |
| `v_pStr1` | `char(30)` | L14 |
| `v_pStr2` | `char(30)` | L15 |
| `v_pStr3` | `char(30)` | L16 |
| `v_pStr4` | `char (30)` | L17 |
| `v_pStr5` | `char(150)` | L18 |
| `v_pStr6` | `char(100)` | L19 |
| `v_pStr7` | `char(60)` | L20 |
| `v_pStr8` | `char(60)` | L21 |
| `v_pStr9` | `char(15)` | L22 |
| `v_pStr10` | `char(100)` | L23 |
| `v_pcorreo_alterno` | `char(100)` | L24 |
| `v_pcelular_alterno` | `char(10)` | L25 |
| `v_pImporte1` | `money (16,2)` | L26 |
| `v_pImporte2` | `money (16,2)` | L27 |
| `v_pImporte3` | `money (16,2)` | L28 |
| `v_pImporte4` | `money (16,2)` | L29 |
| *…5 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tbl_registro_msj` | `bdispei` | no | SELECT | L71 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_registra_evento` | `bdimnsj` | ⚠️ sí | L80 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `gen` | ACCION | genera / general | 🟡 INFERIDO | nombre_sp |
| `msj` | ENTIDAD | mensaje — abreviación corta de mnsj (sp_validacion_msj) | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |

---

## `sp_gen_msj_mib`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_sp_gen_msj_mib.sql` |
| **LOC (1er CREATE)** | 157 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "genera mensaje — abreviación corta de mnsj y MIB — módulo/canal de integración para cheques y tarjeta" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `genera` → `SELECT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=1 · INFERIDO=3 · SINTÉTICO=0 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_gen_msj_mib(
  pEmpresa                     CHAR(3)
  pRegistros                   INTEGER
) RETURNING CHAR(5)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pEmpresa` | `CHAR(3)` | — | — |
| `pRegistros` | `INTEGER` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vsqlerr` | `INTEGER` | L4 |
| `vcodret` | `CHAR(5)` | L5 |
| `v_pTipoMsj` | `char(1)` | L7 |
| `v_pIdMsj` | `char(10)` | L8 |
| `v_pIdPlantilla` | `char(12)` | L9 |
| `v_pNumclt` | `char(20)` | L10 |
| `v_pNumcta` | `char(20)` | L11 |
| `v_pNumTarjeta` | `char(16)` | L12 |
| `v_pTipoproc` | `char(1)` | L13 |
| `v_pStr1` | `char(30)` | L14 |
| `v_pStr2` | `char(30)` | L15 |
| `v_pStr3` | `char(30)` | L16 |
| `v_pStr4` | `char (30)` | L17 |
| `v_pStr5` | `char(150)` | L18 |
| `v_pStr6` | `char(100)` | L19 |
| `v_pStr7` | `char(60)` | L20 |
| `v_pStr8` | `char(60)` | L21 |
| `v_pStr9` | `char(15)` | L22 |
| `v_pStr10` | `char(100)` | L23 |
| `v_pcorreo_alterno` | `char(100)` | L24 |
| `v_pcelular_alterno` | `char(10)` | L25 |
| `v_pImporte1` | `money (16,2)` | L26 |
| `v_pImporte2` | `money (16,2)` | L27 |
| `v_pImporte3` | `money (16,2)` | L28 |
| `v_pImporte4` | `money (16,2)` | L29 |
| *…5 más…* | | |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `bdimnsj` | `bdispei` | no | L89 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `gen` | ACCION | genera / general | 🟡 INFERIDO | nombre_sp |
| `msj` | ENTIDAD | mensaje — abreviación corta de mnsj (sp_validacion_msj) | 🟡 INFERIDO | nombre_sp |
| `mib` | ENTIDAD | MIB — módulo/canal de integración para cheques y tarjeta (ca | 🟡 INFERIDO | nombre_sp |

---

## `sp_genera_reportes_spei`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_sp_genera_reportes_spei.sql` |
| **LOC (1er CREATE)** | 81 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "genera reportes" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `genera` → `SELECT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=0 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_genera_reportes_spei(
  p_empresa                    char(3)
) RETURNING CHAR(5)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_empresa` | `char(3)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vsqlerr` | `INTEGER` | L4 |
| `iIsamErr` | `INTEGER` | L5 |
| `cErrorInfo` | `CHAR(80)` | L6 |
| `vcodret` | `CHAR(5)` | L7 |
| `vcodret2` | `CHAR(5)` | L8 |
| `vErrorInfo` | `CHAR(80)` | L9 |
| `v_fecha_ini` | `DATE` | L10 |
| `v_codretparam` | `CHAR(5)` | L11 |
| `v_codretparam1` | `CHAR(5)` | L12 |
| `v_codretparam2` | `CHAR(70)` | L13 |
| `vprocesocomp1` | `SMALLINT` | L14 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sc_fechas` | `bdicheq` | ⚠️ sí | SELECT | L49 |
| `tblctrlproceso` | `bdispei` | no | SELECT | L56 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_rptmovsdiariospei` | `bdicheq` | ⚠️ sí | L61 |
| `sp_rptmovsdiariospei_acuenta` | `bdicheq` | ⚠️ sí | L69 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L73 | CÓDIGO_RETORNO | `LET vcodret = '00000';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `genera` | ACCION | genera / produce | 🔵 CONVENCIÓN | nombre_sp |
| `reportes` | ENTIDAD | reportes | 🔵 CONVENCIÓN | nombre_sp |
| `spei` | PREFIJO | familia SPEI (pagos interbancarios) | ✅ CÓDIGO | nombre_sp, texto_cuerpo |

---

## `sp_generaconta`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_sp_generaconta.sql` |
| **LOC (1er CREATE)** | 521 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "genera" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `genera` → `INSERT` encontrado en el cuerpo · `genera` → `SELECT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=1 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_generaconta(
  pFechaOperacion              DATE
) RETURNING CHAR(5)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pFechaOperacion` | `DATE` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `mnyImporteOp` | `MONEY(18,2)` | L15 |
| `intTipoPago` | `INTEGER` | L16 |
| `chrSentido` | `CHAR(1)` | L17 |
| `intCantidad` | `INTEGER` | L18 |
| `chrTransEnv` | `CHAR(4)` | L19 |
| `chrTransRec` | `CHAR(4)` | L20 |
| `chrCodRet` | `CHAR(5)` | L21 |
| `intCodRet` | `INTEGER` | L22 |
| `chrCodTransacc` | `CHAR(4)` | L23 |
| `vchrNumSucursal` | `CHAR(4)` | L24 |
| `chrSucursalOrig` | `CHAR(4)` | L25 |
| `chrempresa` | `CHAR(3)` | L26 |
| `chrc_ccmayor` | `CHAR(4)` | L27 |
| `chrc_ccsub` | `CHAR(2)` | L28 |
| `chrc_ccsubsub` | `CHAR(2)` | L29 |
| `chrc_ccsssub` | `CHAR(2)` | L30 |
| `chrc_ccssssub` | `CHAR(2)` | L31 |
| `chrc_sector` | `CHAR(2)` | L32 |
| `chra_ccmayor` | `CHAR(4)` | L33 |
| `chra_ccsub` | `CHAR(2)` | L34 |
| `chra_ccsubsub` | `CHAR(2)` | L35 |
| `chra_ccsssub` | `CHAR(2)` | L36 |
| `chra_ccssssub` | `CHAR(2)` | L37 |
| `chra_sector` | `CHAR(2)` | L38 |
| `intPKTabla` | `INTEGER` | L39 |
| *…1 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tblpasecont` | `bdispei` | no | SELECT | L60 |
| `tblpasecont` | `bdispei` | no | DELETE | L60 |
| `tblpago` | `bdispei` | no | SELECT | L65 |
| `tblparametros` | `bdispei` | no | SELECT | L75 |
| `si_prodtran` | `bdinteg` | ⚠️ sí | SELECT | L115 |
| `tblpasecont` | `bdispei` | no | INSERT | L132 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L104 | VALIDACIÓN_NULL | `IF chrCodTransacc IS NULL OR chrCodTransacc = '' THEN` |  |
| L121 | VALIDACIÓN_NULL | `IF chrc_ccmayor IS NULL  THEN` |  |
| L124 | FÓRMULA | `LET intPKTabla = intPKTabla + 1;` |  |
| L139 | FÓRMULA | `LET intPKTabla = intPKTabla + 1;` |  |
| L167 | VALIDACIÓN_NULL | `IF chrCodTransacc IS NULL OR chrCodTransacc = '' THEN` |  |
| L183 | VALIDACIÓN_NULL | `IF chrc_ccmayor IS NULL  THEN` |  |
| L186 | FÓRMULA | `LET intPKTabla = intPKTabla + 1;` |  |
| L201 | FÓRMULA | `LET intPKTabla = intPKTabla + 1;` |  |
| L245 | VALIDACIÓN_NULL | `IF chrCodTransacc IS NULL OR chrCodTransacc = '' THEN` |  |
| L262 | VALIDACIÓN_NULL | `IF chrc_ccmayor IS NULL  THEN` |  |
| L265 | FÓRMULA | `LET intPKTabla = intPKTabla + 1;` |  |
| L275 | FÓRMULA | `LET intPKTabla = intPKTabla + 1;` |  |
| L305 | VALIDACIÓN_NULL | `IF chrCodTransacc IS NULL OR chrCodTransacc = '' THEN` |  |
| L321 | VALIDACIÓN_NULL | `IF chrc_ccmayor IS NULL  THEN` |  |
| L324 | FÓRMULA | `LET intPKTabla = intPKTabla + 1;` |  |
| L333 | FÓRMULA | `LET intPKTabla = intPKTabla + 1;` |  |
| L363 | VALIDACIÓN_NULL | `IF chrCodTransacc IS NULL OR chrCodTransacc = '' THEN` |  |
| L379 | VALIDACIÓN_NULL | `IF chrc_ccmayor IS NULL  THEN` |  |
| L382 | FÓRMULA | `LET intPKTabla = intPKTabla + 1;` |  |
| L391 | FÓRMULA | `LET intPKTabla = intPKTabla + 1;` |  |
| L424 | VALIDACIÓN_NULL | `IF chrCodTransacc IS NULL OR chrCodTransacc = '' THEN` |  |
| L441 | VALIDACIÓN_NULL | `IF chrc_ccmayor IS NULL  THEN` |  |
| L444 | FÓRMULA | `LET intPKTabla = intPKTabla + 1;` |  |
| L453 | FÓRMULA | `LET intPKTabla = intPKTabla + 1;` |  |
| L482 | VALIDACIÓN_NULL | `IF chrCodTransacc IS NULL OR chrCodTransacc = '' THEN` |  |
| L498 | VALIDACIÓN_NULL | `IF chrc_ccmayor IS NULL  THEN` |  |
| L501 | FÓRMULA | `LET intPKTabla = intPKTabla + 1;` |  |
| L509 | FÓRMULA | `LET intPKTabla = intPKTabla + 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `genera` | ACCION | genera / produce | 🔵 CONVENCIÓN | nombre_sp |
| `cont` | PREFIJO | familia contabilidad | 🔵 CONVENCIÓN | nombre_sp |
| `?a` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?a` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_generadevpago`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_sp_generadevpago.sql` |
| **LOC (1er CREATE)** | 65 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "genera pago" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `genera` → `INSERT` encontrado en el cuerpo · `genera` → `SELECT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=0 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_generadevpago(
  p_intpkpago                  integer
  p_intcvecausadev             integer
  p_vchrMotivoDev              varchar(255)
) RETURNING char(5)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_intpkpago` | `integer` | `pago`=pago | ✅ CÓDIGO |
| `p_intcvecausadev` | `integer` | `dev`=devolución | 🔵 CONVENCIÓN |
| `p_vchrMotivoDev` | `varchar(255)` | `dev`=devolución | 🔵 CONVENCIÓN |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `v_codret` | `char(5)` | L4 |
| `sql_err` | `integer` | L5 |
| `v_intpkdev` | `integer` | L6 |
| `v_intpkpago` | `integer` | L7 |
| `v_intfoliodev` | `integer` | L8 |
| `vdtFechaOp` | `date` | L9 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tblparametros` | `bdispei` | no | SELECT | L23 |
| `tblpago` | `bdispei` | no | SELECT | L28 |
| `tblpago` | `bdispei` | no | INSERT | L48 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_obtsigfolioop` | `bdispei` | no | L34 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `genera` | ACCION | genera / produce | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `dev` | ACCION | devolución | 🔵 CONVENCIÓN | nombre_sp |
| `pago` | ENTIDAD | pago | ✅ CÓDIGO | nombre_sp, texto_cuerpo |

---

## `sp_inicializa`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_sp_inicializa.sql` |
| **LOC (1er CREATE)** | 43 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "inicializa" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 4 tabla(s) con operaciones: INSERT, UPDATE, DELETE, SELECT |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=0 / 2 términos |

### Firma

```sql
CREATE PROCEDURE sp_inicializa(
  pvchrFase                    varchar(10)
) RETURNING char(5)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pvchrFase` | `varchar(10)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `sql_err` | `integer` | L5 |
| `codret` | `char(5)` | L6 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tblcajero` | `bdispei` | no | UPDATE | L19 |
| `tblhistbitacora` | `bdispei` | no | INSERT | L30 |
| `tblbitacoramsj` | `bdispei` | no | SELECT | L31 |
| `tblbitacoramsj` | `bdispei` | no | DELETE | L33 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `inicializa` | ACCION | inicializa | 🔵 CONVENCIÓN | nombre_sp |

---

## `sp_inserta_credspei`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_sp_inserta_credspei.sql` |
| **LOC (1er CREATE)** | 96 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "inserta crédito" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `inserta` → `INSERT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=4 · INFERIDO=0 · SINTÉTICO=0 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_inserta_credspei(
  pCtaClabe                    CHAR(18)
  pMonto                       DECIMAL(15,2)
  pCveRastreo                  CHAR(30)
) RETURNING CHAR(5)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pCtaClabe` | `CHAR(18)` | — | — |
| `pMonto` | `DECIMAL(15,2)` | — | — |
| `pCveRastreo` | `CHAR(30)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(5)` | L4 |
| `cCodRet2` | `CHAR(5)` | L5 |
| `cCodRet3` | `CHAR(5)` | L6 |
| `iSqlErr` | `INTEGER` | L7 |
| `iSamErr` | `INTEGER` | L8 |
| `cDesErr` | `CHAR(50)` | L9 |
| `cStatus` | `CHAR(1)` | L11 |
| `cCtaClabe` | `CHAR(18)` | L12 |
| `cMonto` | `CHAR(17)` | L13 |
| `iTpoPago` | `SMALLINT` | L14 |
| `cMontoPagoWS` | `CHAR(18)` | L15 |
| `cCtaClabeWS` | `CHAR(18)` | L16 |
| `cCodRetWS` | `CHAR(5)` | L17 |
| `cCveBcoMexWS` | `CHAR(3)` | L18 |
| `cCodErrWS` | `CHAR(5)` | L19 |
| `cDescErrWS` | `CHAR(100)` | L20 |
| `cNoCteCentralWS` | `CHAR(20)` | L21 |
| `cNoCteOrionWS` | `CHAR(15)` | L22 |
| `cRfcCteWS` | `CHAR(13)` | L23 |
| `cNombreCteWS` | `CHAR(40)` | L24 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tblpagocred` | `bdispei` | no | INSERT | L77 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L67 | VALIDACIÓN_NULL | `IF ( pCtaClabe   is null OR  pCtaClabe = '' ) OR` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `inserta` | ACCION | inserta / registra | 🔵 CONVENCIÓN | nombre_sp |
| `cred` | ENTIDAD | crédito | 🔵 CONVENCIÓN | nombre_sp |
| `spei` | PREFIJO | familia SPEI (pagos interbancarios) | 🔵 CONVENCIÓN | nombre_sp |

---

## `sp_marcacancpago`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_sp_marcacancpago.sql` |
| **LOC (1er CREATE)** | 50 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "marca y código postal" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 3 tabla(s) con operaciones: SELECT, UPDATE |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=2 · INFERIDO=1 · SINTÉTICO=2 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_marcacancpago(
  pintFolioPaquete             INTEGER
  pintFolioPago                INTEGER
  pintFolioServCanc            INTEGER
) RETURNING CHAR(5)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pintFolioPaquete` | `INTEGER` | — | — |
| `pintFolioPago` | `INTEGER` | — | — |
| `pintFolioServCanc` | `INTEGER` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `codret` | `CHAR(5)` | L5 |
| `sql_err` | `INTEGER` | L6 |
| `vintPkPaqueteEnv` | `INTEGER` | L7 |
| `intCesifPago` | `INTEGER` | L8 |
| `chrFolioErr` | `CHAR(18)` | L9 |
| `intFolioErr` | `INTEGER` | L10 |
| `vdtFechaOp` | `DATE` | L11 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tblparametros` | `bdispei` | no | SELECT | L24 |
| `tblpaqueteenv` | `bdispei` | no | SELECT | L28 |
| `tblpago` | `bdispei` | no | UPDATE | L39 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L33 | VALIDACIÓN_NULL | `IF vintPkPaqueteEnv IS NULL THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `marca` | ENTIDAD | marca | 🔵 CONVENCIÓN | nombre_sp |
| `?can` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `cp` | ENTIDAD | código postal | 🟡 INFERIDO | nombre_sp |
| `?ago` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?can`, `?ago` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_marcacancpaq`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_sp_marcacancpaq.sql` |
| **LOC (1er CREATE)** | 56 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "marca y código postal" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 3 tabla(s) con operaciones: SELECT, UPDATE |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=2 · INFERIDO=1 · SINTÉTICO=2 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_marcacancpaq(
  pintFolioPaquete             INTEGER
  pintFolioServCanc            INTEGER
) RETURNING CHAR(5)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pintFolioPaquete` | `INTEGER` | — | — |
| `pintFolioServCanc` | `INTEGER` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `codret` | `CHAR(5)` | L4 |
| `sql_err` | `INTEGER` | L5 |
| `vintPkPaqueteEnv` | `INTEGER` | L6 |
| `intCesifPago` | `INTEGER` | L7 |
| `chrFolioErr` | `CHAR(18)` | L8 |
| `intFolioErr` | `INTEGER` | L9 |
| `vdtFechaOp` | `DATE` | L10 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tblparametros` | `bdispei` | no | SELECT | L23 |
| `tblpaqueteenv` | `bdispei` | no | SELECT | L27 |
| `tblpago` | `bdispei` | no | UPDATE | L46 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L32 | VALIDACIÓN_NULL | `IF vintPkPaqueteEnv IS NULL THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `marca` | ENTIDAD | marca | 🔵 CONVENCIÓN | nombre_sp |
| `?can` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `cp` | ENTIDAD | código postal | 🟡 INFERIDO | nombre_sp |
| `?aq` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?can`, `?aq` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_marcaerrpago`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_sp_marcaerrpago.sql` |
| **LOC (1er CREATE)** | 50 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "marca y pago" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 1 llamada(s): `sp_obtsigfolioop` |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=1 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_marcaerrpago(
  pintFolioPago                INTEGER
  pintFolioServidor            INTEGER
  psiCodError                  SMALLINT
) RETURNING CHAR(5), VARCHAR(100)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pintFolioPago` | `INTEGER` | `pago`=pago | ✅ CÓDIGO |
| `pintFolioServidor` | `INTEGER` | — | — |
| `psiCodError` | `SMALLINT` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `codret` | `CHAR(5)` | L4 |
| `sql_err` | `INTEGER` | L5 |
| `intCantidad` | `INTEGER` | L6 |
| `chrFolioErr` | `CHAR(18)` | L7 |
| `DescError` | `VARCHAR(100)` | L8 |
| `intFolioErr` | `INTEGER` | L9 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tblpago` | `bdispei` | no | SELECT | L23 |
| `tblpago` | `bdispei` | no | UPDATE | L33 |
| `tblerrcom` | `bdispei` | no | INSERT | L43 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_obtsigfolioop` | `bdispei` | no | L38 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `marca` | ENTIDAD | marca | 🔵 CONVENCIÓN | nombre_sp |
| `?err` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `pago` | ENTIDAD | pago | ✅ CÓDIGO | nombre_sp, texto_cuerpo |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?err` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_marcaerrpaq`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_sp_marcaerrpaq.sql` |
| **LOC (1er CREATE)** | 51 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "marca y paquete — paquete de pago SPEI" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 2 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=1 · INFERIDO=1 · SINTÉTICO=1 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_marcaerrpaq(
  intFolio                     INTEGER
  siEstado                     SMALLINT
) RETURNING CHAR(5)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `intFolio` | `INTEGER` | — | — |
| `siEstado` | `SMALLINT` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `codret` | `CHAR(5)` | L4 |
| `sql_err` | `INTEGER` | L5 |
| `intCantidad` | `INTEGER` | L6 |
| `intPkPaq` | `INTEGER` | L7 |
| `vdtFechaOp` | `DATE` | L8 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tblparametros` | `bdispei` | no | SELECT | L22 |
| `tblpaqueteenv` | `bdispei` | no | SELECT | L26 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L32 | VALIDACIÓN_NULL | `IF intPkPaq IS NULL THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `marca` | ENTIDAD | marca | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?err` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `paq` | ENTIDAD | paquete — paquete de pago SPEI (bloque/lote de órdenes de tr | 🟡 INFERIDO | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?err` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_marcaliqpago`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_sp_marcaliqpago.sql` |
| **LOC (1er CREATE)** | 83 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "marca, liquidación y pago" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 4 tabla(s) con operaciones: SELECT, UPDATE |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=2 · INFERIDO=1 · SINTÉTICO=0 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_marcaliqpago(
  pintFolioPago                INTEGER
  pintFolioPaquete             INTEGER
  pintFolioCargo               INTEGER
  pintCesifBenef               INTEGER
) RETURNING CHAR(5), money(19,2)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pintFolioPago` | `INTEGER` | `pago`=pago | ✅ CÓDIGO |
| `pintFolioPaquete` | `INTEGER` | — | — |
| `pintFolioCargo` | `INTEGER` | — | — |
| `pintCesifBenef` | `INTEGER` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `codret` | `CHAR(5)` | L4 |
| `sql_err` | `INTEGER` | L5 |
| `intCantidad` | `INTEGER` | L6 |
| `intCesifPago` | `INTEGER` | L7 |
| `vintPkPaqueteEnv` | `INTEGER` | L8 |
| `chrFolioErr` | `CHAR(18)` | L9 |
| `mnyMonto` | `money(19,2)` | L10 |
| `intFolioErr` | `INTEGER` | L11 |
| `vdtFechaOp` | `DATE` | L12 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tblparametros` | `bdispei` | no | SELECT | L32 |
| `tblpaqueteenv` | `bdispei` | no | SELECT | L36 |
| `tblpago` | `bdispei` | no | SELECT | L48 |
| `tblpago` | `bdispei` | no | UPDATE | L71 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L42 | VALIDACIÓN_NULL | `IF vintPkPaqueteEnv IS NULL THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `marca` | ENTIDAD | marca | 🔵 CONVENCIÓN | nombre_sp |
| `liq` | ENTIDAD | liquidación (abreviación — sp_marcaliqpago, spei_recliquidac | 🟡 INFERIDO | nombre_sp |
| `pago` | ENTIDAD | pago | ✅ CÓDIGO | nombre_sp, texto_cuerpo |

---

## `sp_marcaliqpaq`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_sp_marcaliqpaq.sql` |
| **LOC (1er CREATE)** | 59 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "marca, liquidación y paquete — paquete de pago SPEI" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 4 tabla(s) con operaciones: SELECT, UPDATE |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=2 · INFERIDO=2 · SINTÉTICO=0 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_marcaliqpaq(
  pintFolioPaquete             INTEGER
  pintFolioCargo               INTEGER
  pintCesifBenef               INTEGER
) RETURNING CHAR(5), money(19,2)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pintFolioPaquete` | `INTEGER` | `paq`=paquete — paquete de pago SPEI (bloque/lote de órdenes de transferencia) | 🟡 INFERIDO |
| `pintFolioCargo` | `INTEGER` | — | — |
| `pintCesifBenef` | `INTEGER` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `codret` | `CHAR(5)` | L4 |
| `sql_err` | `INTEGER` | L5 |
| `vintPkPaqueteEnv` | `INTEGER` | L6 |
| `intCesifPago` | `INTEGER` | L7 |
| `chrFolioErr` | `CHAR(18)` | L8 |
| `mnyMonto` | `money(19,2)` | L9 |
| `intFolioErr` | `INTEGER` | L10 |
| `vdtFechaOp` | `DATE` | L11 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tblparametros` | `bdispei` | no | SELECT | L27 |
| `tblpaqueteenv` | `bdispei` | no | SELECT | L31 |
| `tblpago` | `bdispei` | no | SELECT | L45 |
| `tblpago` | `bdispei` | no | UPDATE | L49 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L38 | VALIDACIÓN_NULL | `IF vintPkPaqueteEnv IS NULL THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `marca` | ENTIDAD | marca | 🔵 CONVENCIÓN | nombre_sp |
| `liq` | ENTIDAD | liquidación (abreviación — sp_marcaliqpago, spei_recliquidac | 🟡 INFERIDO | nombre_sp |
| `paq` | ENTIDAD | paquete — paquete de pago SPEI (bloque/lote de órdenes de tr | 🟡 INFERIDO | nombre_sp |

---

## `sp_marcaopproc`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_sp_marcaopproc.sql` |
| **LOC (1er CREATE)** | 44 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "marca (PP — Persona a Persona o Pago Programado)" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 2 tabla(s) con operaciones: SELECT, UPDATE |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=3 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_marcaopproc(
  chrfolio                     char(12)
  pintEnReenvio                integer
) RETURNING CHAR(5)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `chrfolio` | `char(12)` | — | — |
| `pintEnReenvio` | `integer` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vchrRegBitacora` | `CHAR` | L4 |
| `codret` | `CHAR(5)` | L5 |
| `sql_err` | `INTEGER` | L6 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tblbitacoramsj` | `bdispei` | no | SELECT | L26 |
| `tblbitacoramsj` | `bdispei` | no | UPDATE | L32 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `marca` | ENTIDAD | marca | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?o` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `pp` | MODIF | PP — Persona a Persona o Pago Programado (sp_regordenctecte_ | 🔴 SINTÉTICO | nombre_sp |
| `?roc` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?o`, `pp`, `?roc` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_msjcatalogos23`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_sp_msjcatalogos23.sql` |
| **LOC (1er CREATE)** | 116 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "mensaje — abreviación corta de mnsj y catálogo" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 4 tabla(s) con operaciones: INSERT, SELECT |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=2 · INFERIDO=1 · SINTÉTICO=1 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_msjcatalogos23(
  pcvetipopago                 integer
  pdescripcion                 varchar(100)
  paceptacionbca               char
  pvalorf                      smallint
  ptipofuncion                 integer
  pvalort                      smallint
  cadena                       char(1000)
) RETURNING char(5), integer
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pcvetipopago` | `integer` | — | — |
| `pdescripcion` | `varchar(100)` | — | — |
| `paceptacionbca` | `char` | — | — |
| `pvalorf` | `smallint` | — | — |
| `ptipofuncion` | `integer` | — | — |
| `pvalort` | `smallint` | — | — |
| `cadena` | `char(1000)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vcodret` | `char(5)` | L33 |
| `vsqlerr` | `integer` | L34 |
| `vstatus` | `integer` | L35 |
| `var1` | `varchar(50)` | L38 |
| `i` | `integer` | L39 |
| `vposini` | `integer` | L40 |
| `vposfin` | `integer` | L41 |
| `v_caracter` | `char(1)` | L42 |
| `bInserto` | `varchar(3)` | L43 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tbltipopago` | `bdispei` | no | SELECT | L60 |
| `tbltipopago` | `bdispei` | no | INSERT | L62 |
| `tbltipopago_bco` | `bdispei` | no | SELECT | L94 |
| `tbltipopago_bco` | `bdispei` | no | INSERT | L97 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L87 | FÓRMULA | `let vposfin = i - vposini;` |  |
| L91 | FÓRMULA | `Let vposini = i +1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `msj` | ENTIDAD | mensaje — abreviación corta de mnsj (sp_validacion_msj) | 🟡 INFERIDO | nombre_sp |
| `catalogo` | ENTIDAD | catálogo | 🔵 CONVENCIÓN | nombre_sp |
| `?s23` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?s23` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_msjcatalogos45`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_sp_msjcatalogos45.sql` |
| **LOC (1er CREATE)** | 105 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "mensaje — abreviación corta de mnsj y catálogo" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 3 tabla(s) con operaciones: INSERT, SELECT |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=2 · INFERIDO=1 · SINTÉTICO=1 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_msjcatalogos45(
  pcvetipocuenta               integer
  pdescripcion                 varchar(100)
  pvalort                      smallint
  cadena                       char(1000)
) RETURNING char(5), integer
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pcvetipocuenta` | `integer` | — | — |
| `pdescripcion` | `varchar(100)` | — | — |
| `pvalort` | `smallint` | — | — |
| `cadena` | `char(1000)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vcodret` | `char(5)` | L29 |
| `vsqlerr` | `integer` | L30 |
| `vstatus` | `integer` | L31 |
| `var1` | `varchar(50)` | L34 |
| `var2` | `varchar(100)` | L35 |
| `var3` | `varchar(50)` | L36 |
| `i` | `integer` | L37 |
| `vposini` | `integer` | L38 |
| `vposfin` | `integer` | L39 |
| `v_caracter` | `char(1)` | L40 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tbltipocuenta` | `bdispei` | no | SELECT | L57 |
| `tbltipocuenta` | `bdispei` | no | INSERT | L59 |
| `tbltctavostro` | `bdispei` | no | INSERT | L93 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L82 | FÓRMULA | `let vposfin = i - vposini;` |  |
| L90 | FÓRMULA | `Let vposini = i +1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `msj` | ENTIDAD | mensaje — abreviación corta de mnsj (sp_validacion_msj) | 🟡 INFERIDO | nombre_sp |
| `catalogo` | ENTIDAD | catálogo | 🔵 CONVENCIÓN | nombre_sp |
| `?s45` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?s45` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_msjcatalogos6`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_sp_msjcatalogos6.sql` |
| **LOC (1er CREATE)** | 57 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "mensaje — abreviación corta de mnsj y catálogo" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 3 tabla(s) con operaciones: INSERT, SELECT, UPDATE |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=2 · INFERIDO=1 · SINTÉTICO=1 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_msjcatalogos6(
  pcvetipoperacion             integer
  pdescripcion                 varchar(100)
  pvalort                      char(1)
) RETURNING char(5), integer
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pcvetipoperacion` | `integer` | — | — |
| `pdescripcion` | `varchar(100)` | — | — |
| `pvalort` | `char(1)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vcodret` | `char(5)` | L24 |
| `vsqlerr` | `int` | L25 |
| `vstatus` | `integer` | L26 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tbltipooperacion` | `bdispei` | no | SELECT | L43 |
| `tbltipooperacion` | `bdispei` | no | INSERT | L45 |
| `tbltipooperacion` | `bdispei` | no | UPDATE | L49 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `msj` | ENTIDAD | mensaje — abreviación corta de mnsj (sp_validacion_msj) | 🟡 INFERIDO | nombre_sp |
| `catalogo` | ENTIDAD | catálogo | 🔵 CONVENCIÓN | nombre_sp |
| `?s6` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?s6` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_msjcatalogos7`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_sp_msjcatalogos7.sql` |
| **LOC (1er CREATE)** | 59 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "mensaje — abreviación corta de mnsj y catálogo" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 2 tabla(s) con operaciones: INSERT, SELECT |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=2 · INFERIDO=1 · SINTÉTICO=1 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_msjcatalogos7(
  pcvecausadev                 integer
  pdescripcion                 varchar(100)
  pvalort                      char(4)
) RETURNING char(5),integer
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pcvecausadev` | `integer` | — | — |
| `pdescripcion` | `varchar(100)` | — | — |
| `pvalort` | `char(4)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vcodret` | `char(5)` | L26 |
| `vsqlerr` | `int` | L27 |
| `vstatus` | `int` | L28 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tblcausadev` | `bdispei` | no | SELECT | L45 |
| `tblcausadev` | `bdispei` | no | INSERT | L47 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `msj` | ENTIDAD | mensaje — abreviación corta de mnsj (sp_validacion_msj) | 🟡 INFERIDO | nombre_sp |
| `catalogo` | ENTIDAD | catálogo | 🔵 CONVENCIÓN | nombre_sp |
| `?s7` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?s7` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_msjcatalogos8`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_sp_msjcatalogos8.sql` |
| **LOC (1er CREATE)** | 59 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "mensaje — abreviación corta de mnsj y catálogo" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 2 tabla(s) con operaciones: INSERT, SELECT |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=2 · INFERIDO=1 · SINTÉTICO=1 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_msjcatalogos8(
  pcvetipotraspaso             integer
  pdescripcion                 varchar(100)
  ptipofuncion                 integer
  pvalort                      smallint
) RETURNING char(5), int
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pcvetipotraspaso` | `integer` | `sp`=stored procedure | 🔵 CONVENCIÓN |
| `pdescripcion` | `varchar(100)` | — | — |
| `ptipofuncion` | `integer` | — | — |
| `pvalort` | `smallint` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vcodret` | `char(5)` | L25 |
| `vsqlerr` | `int` | L26 |
| `vstatus` | `int` | L27 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tbltipotraspaso` | `bdispei` | no | SELECT | L44 |
| `tbltipotraspaso` | `bdispei` | no | INSERT | L46 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `msj` | ENTIDAD | mensaje — abreviación corta de mnsj (sp_validacion_msj) | 🟡 INFERIDO | nombre_sp |
| `catalogo` | ENTIDAD | catálogo | 🔵 CONVENCIÓN | nombre_sp |
| `?s8` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?s8` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_obt_catalogobcos_spei`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_sp_obt_catalogobcos_spei.sql` |
| **LOC (1er CREATE)** | 67 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "obtiene catálogo" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `obtiene` → `SELECT` encontrado en el cuerpo · `obtiene` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=2 · INFERIDO=1 · SINTÉTICO=1 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_obt_catalogobcos_spei(
  p_Registros                  INT
) RETURNING CHAR(5), INT, CHAR(20)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_Registros` | `INT` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `sql_err` | `INTEGER` | L13 |
| `isam_err` | `INTEGER` | L14 |
| `vcodret` | `CHAR(5)` | L15 |
| `vcNomBco` | `CHAR(20)` | L16 |
| `vcCvecesif` | `INT` | L17 |
| `v_ContReg` | `SMALLINT` | L18 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_bancos` | `bdinteg` | ⚠️ sí | SELECT | L43 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L57 | FÓRMULA | `LET v_ContReg = v_ContReg + 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `obt` | ACCION | obtiene | 🟡 INFERIDO | nombre_sp |
| `catalogo` | ENTIDAD | catálogo | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?bcos_` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `spei` | PREFIJO | familia SPEI (pagos interbancarios) | 🔵 CONVENCIÓN | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?bcos_` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_obt_comision`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_sp_obt_comision.sql` |
| **LOC (1er CREATE)** | 39 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "obtiene · comisión" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `obtiene` → `SELECT` encontrado en el cuerpo · `obtiene` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=1 · INFERIDO=1 · SINTÉTICO=0 / 3 términos |

### Historia del SP

| Tipo | Valor |
|------|-------|
| AUTOR | Javier Humberto Calderon Zazueta |
| ACTIVIDAD | Obetener comision |
| FECHA | 17/12/2008 |

### Firma

```sql
CREATE PROCEDURE sp_obt_comision(
  pCveComision                 char(274)
) RETURNING char(5), money(14,2)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pCveComision` | `char(274)` | `comision`=comisión (CONDUSEF — debe estar en RECO) | ✅ CÓDIGO |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vcodret` | `char(5)` | L9 |
| `comision` | `money(14,2)` | L10 |
| `sql_err` | `integer` | L11 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tblcomision` | `bdispei` | no | SELECT | L30 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `obt` | ACCION | obtiene | 🟡 INFERIDO | nombre_sp |
| `comision` | REG | comisión (CONDUSEF — debe estar en RECO) | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |

---

## `sp_obtfoliopaq`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_sp_obtfoliopaq.sql` |
| **LOC (1er CREATE)** | 49 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "obtiene folio y paquete — paquete de pago SPEI" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `obtiene` → `SELECT` encontrado en el cuerpo · `obtiene` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=1 · INFERIDO=2 · SINTÉTICO=0 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_obtfoliopaq(
  pintCveCesif                 INTEGER
  pchrTopologia                CHAR(1)
  pchrPrioridad                CHAR(1)
) RETURNING CHAR(5), INTEGER, INTEGER
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pintCveCesif` | `INTEGER` | — | — |
| `pchrTopologia` | `CHAR(1)` | — | — |
| `pchrPrioridad` | `CHAR(1)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `codret` | `CHAR(5)` | L4 |
| `sql_err` | `INTEGER` | L5 |
| `vintFolioPaquete` | `INTEGER` | L6 |
| `VintPkPaqueteEnv` | `INTEGER` | L7 |
| `vdtFechaOp` | `DATE` | L8 |
| `v_Institucion` | `CHAR(255)` | L9 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tblparametros` | `bdispei` | no | SELECT | L27 |
| `tblpaqueteenv` | `bdispei` | no | INSERT | L40 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_obtsigfolioop` | `bdispei` | no | L38 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `obt` | ACCION | obtiene | 🟡 INFERIDO | nombre_sp |
| `folio` | ENTIDAD | folio | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `paq` | ENTIDAD | paquete — paquete de pago SPEI (bloque/lote de órdenes de tr | 🟡 INFERIDO | nombre_sp |

---

## `sp_obtfoliosuc`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_sp_obtfoliosuc.sql` |
| **LOC (1er CREATE)** | 92 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "obtiene folio (sucursal)" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `obtiene` → `SELECT` encontrado en el cuerpo · `obtiene` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=1 · INFERIDO=1 · SINTÉTICO=0 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_obtfoliosuc(
  pusuario                     CHAR(8)
) RETURNING CHAR(5), INTEGER, CHAR(16)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pusuario` | `CHAR(8)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vCodRet1` | `CHAR(5)` | L4 |
| `vCodRet2` | `CHAR(5)` | L5 |
| `vSqlErr` | `INTEGER` | L6 |
| `vIsamErr` | `INTEGER` | L7 |
| `wfecha_hoy` | `DATE` | L8 |
| `wfecha` | `CHAR(8)` | L9 |
| `wfecha_fol` | `CHAR(4)` | L10 |
| `wserial_folio` | `INTEGER` | L11 |
| `wfolio_suc` | `CHAR(16)` | L12 |
| `intRowId` | `INTEGER` | L13 |
| `intSerial` | `INTEGER` | L14 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sc_fechas` | `bdicheq` | ⚠️ sí | SELECT | L48 |
| `tblserialfolio` | `bdispei` | no | SELECT | L56 |
| `tblserialfolio` | `bdispei` | no | INSERT | L85 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L58 | VALIDACIÓN_NULL | `IF wserial_folio is null OR wserial_folio = '' THEN` |  |
| L62 | FÓRMULA | `LET wserial_folio = wserial_folio + 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `obt` | ACCION | obtiene | 🟡 INFERIDO | nombre_sp |
| `folio` | ENTIDAD | folio | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `suc` | MODIF | sucursal | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |

---

## `sp_obtsigfolioop`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_sp_obtsigfolioop.sql` |
| **LOC (1er CREATE)** | 94 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "obtiene folio" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `obtiene` → `SELECT` encontrado en el cuerpo · `obtiene` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=1 · INFERIDO=1 · SINTÉTICO=2 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_obtsigfolioop(
  chrTipoFolio                 varchar(20)
) RETURNING CHAR(5), integer
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `chrTipoFolio` | `varchar(20)` | `folio`=folio | ✅ CÓDIGO |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `chrCodRet` | `CHAR(5)` | L14 |
| `chrCodRet2` | `CHAR(5)` | L15 |
| `chrCodRet3` | `CHAR(50)` | L16 |
| `vsqlerr` | `INTEGER` | L17 |
| `visamerr` | `INTEGER` | L18 |
| `vdescerr` | `CHAR(50)` | L19 |
| `vtransaccion` | `INTEGER` | L20 |
| `intFolio` | `INTEGER` | L21 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tblparametros` | `bdispei` | no | SELECT | L63 |
| `tblparametros` | `bdispei` | no | INSERT | L67 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L66 | VALIDACIÓN_NULL | `IF intFolio IS NULL THEN` |  |
| L72 | FÓRMULA | `LET intFolio = intFolio + 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `obt` | ACCION | obtiene | 🟡 INFERIDO | nombre_sp |
| `?sig` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `folio` | ENTIDAD | folio | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?op` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?sig`, `?op` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_obttopopaq`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_sp_obttopopaq.sql` |
| **LOC (1er CREATE)** | 37 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "obtiene paquete — paquete de pago SPEI" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `obtiene` → `SELECT` encontrado en el cuerpo · `obtiene` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=1 · INFERIDO=2 · SINTÉTICO=1 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_obttopopaq(
  pintFolioPaquete             INTEGER
  pdtFechaOp                   DATE
) RETURNING CHAR(5), CHAR(1), CHAR(1)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pintFolioPaquete` | `INTEGER` | `paq`=paquete — paquete de pago SPEI (bloque/lote de órdenes de transferencia) | 🟡 INFERIDO |
| `pdtFechaOp` | `DATE` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `codret` | `CHAR(5)` | L4 |
| `sql_err` | `INTEGER` | L5 |
| `vchrTopologia` | `CHAR(1)` | L6 |
| `vchrprioridad` | `CHAR(1)` | L7 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tblpaqueteenv` | `bdispei` | no | SELECT | L23 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `obt` | ACCION | obtiene | 🟡 INFERIDO | nombre_sp |
| `?topo` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `paq` | ENTIDAD | paquete — paquete de pago SPEI (bloque/lote de órdenes de tr | 🟡 INFERIDO | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?topo` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_pasecont`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_sp_pasecont.sql` |
| **LOC (1er CREATE)** | 118 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "realiza el pase contable" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 2 llamada(s): `sp_generaconta`, `sp_pasecontab` |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=0 / 2 términos |

### Firma

```sql
CREATE PROCEDURE sp_pasecont(
  pfecha_hoy                   DATE
) RETURNING CHAR(5), INTEGER
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pfecha_hoy` | `DATE` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `v_codret` | `CHAR(5)` | L9 |
| `v_sucursal` | `CHAR(4)` | L20 |
| `v_ccmayor` | `CHAR(4)` | L21 |
| `v_usuario` | `CHAR(20)` | L22 |
| `v_usuar` | `CHAR(8)` | L23 |
| `v_auxiliar` | `CHAR(9)` | L24 |
| `v_valor` | `MONEY(14,7)` | L32 |
| `sql_err` | `INTEGER` | L35 |
| `v_plaza` | `CHAR(3)` | L36 |
| `v_pendientes` | `SMALLINT` | L37 |
| `v_fecha` | `CHAR(10)` | L38 |
| `v_cantmovs` | `INTEGER` | L39 |
| `v_Size` | `SMALLINT` | L40 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tblpasecont` | `bdispei` | no | SELECT | L79 |
| `tblpago` | `bdispei` | no | SELECT | L86 |
| `si_ejecut` | `bdinteg` | ⚠️ sí | SELECT | L102 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_generaconta` | `bdispei` | no | L72 |
| `sp_pasecontab` | `bdispei` | no | L108 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L98 | FÓRMULA | `LET v_usuario = SUBSTR(user,v_size-7, v_size);` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `pasecont` | ACCION | realiza el pase contable (registro a póliza/mayor) | 🔵 CONVENCIÓN | nombre_sp |

---

## `sp_pasecontab`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_sp_pasecontab.sql` |
| **LOC (1er CREATE)** | 148 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "realiza el pase contable" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 1 llamada(s): `auditapase` |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=1 / 3 términos |

### Firma

```sql
CREATE PROCEDURE sp_pasecontab(
  pempresa                     char(3)
  pfecha_hoy                   date
  pinstancia                   char(1)
) RETURNING char(5)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pempresa` | `char(3)` | — | — |
| `pfecha_hoy` | `date` | — | — |
| `pinstancia` | `char(1)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cod_ret` | `char(5)` | L14 |
| `vw_mca_aplic` | `char(1)` | L15 |
| `vwcosto_orig` | `char(4)` | L20 |
| `vw_ccmayor` | `char(4)` | L21 |
| `vw_usuario` | `char(8)` | L22 |
| `vw_auxiliar` | `char(9)` | L23 |
| `vw_descripcion` | `char(50)` | L24 |
| `v_valor` | `money(14,7)` | L28 |
| `vw_fecha_hoy` | `date` | L30 |
| `w_descripcion` | `char(30)` | L31 |
| `sql_err` | `integer` | L32 |
| `vmensaje` | `char(80)` | L33 |
| `sUsuario` | `CHAR(8)` | L34 |
| `iLongitud` | `smallint` | L35 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_ejecut` | `bdinteg` | ⚠️ sí | SELECT | L75 |
| `tblpaseconthist` | `bdispei` | no | SELECT | L101 |
| `si_sucursales` | `bdinteg` | ⚠️ sí | SELECT | L117 |
| `co_poldet` | `bdicont` | ⚠️ sí | INSERT | L123 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `auditapase` | `bdicont` | ⚠️ sí | L142 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L64 | FÓRMULA | `LET iLongitud = LENGTH(trim(user)) -8 ;` |  |
| L67 | FÓRMULA | `LET sUsuario = substr(user,iLongitud +1,8);` |  |
| L80 | VALIDACIÓN_NULL | `IF vw_usuario is null or vw_suc_usuario is null then` |  |
| L122 | FÓRMULA | `let vw_secuencia = vw_secuencia + 1;` |  |
| L131 | FÓRMULA | `let vw_secuencia = vw_secuencia + 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `pasecont` | ACCION | realiza el pase contable (registro a póliza/mayor) | 🔵 CONVENCIÓN | nombre_sp |
| `?ab` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?ab` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_prueba`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_sp_prueba.sql` |
| **LOC (1er CREATE)** | 21 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "sp_prueba" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 1 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=1 / 2 términos |

### Firma

```sql
CREATE PROCEDURE sp_prueba(
) RETURNING integer
```

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `v_codigos` | `varchar(20)` | L7 |
| `v_cantidad` | `integer` | L8 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_codret` | `bdinteg` | ⚠️ sí | SELECT | L14 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `?_prueba` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_prueba` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_query_cron`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_sp_query_cron.sql` |
| **LOC (1er CREATE)** | 51 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "sp_query_cron" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 2 tabla(s) con operaciones: UPDATE, SELECT |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=1 / 2 términos |

### Firma

```sql
CREATE PROCEDURE sp_query_cron(
  vfechacarga                  DATE
) RETURNING CHAR(5)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `vfechacarga` | `DATE` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vcodret` | `CHAR(5)` | L6 |
| `error_info` | `CHAR(60)` | L7 |
| `vsqlerr` | `INTEGER` | L8 |
| `isam_err` | `SMALLINT` | L9 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tblpago` | `bdispei` | no | UPDATE | L41 |
| `sc_movdia` | `bdicheq` | ⚠️ sí | SELECT | L44 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L12 | CÓDIGO_RETORNO | `LET vcodret       	= '00000';` |  |
| L22 | CÓDIGO_RETORNO | `LET vcodret       	= '00000';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `?_query_cron` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_query_cron` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_query_cron_exp1`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_sp_query_cron_exp1.sql` |
| **LOC (1er CREATE)** | 51 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "(sufijo Exportar — SP genera/exporta archivo de salida)" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `genera` → `SELECT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=1 · INFERIDO=1 · SINTÉTICO=2 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_query_cron_exp1(
  vfechacarga                  DATE
) RETURNING CHAR(5)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `vfechacarga` | `DATE` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vcodret` | `CHAR(5)` | L6 |
| `error_info` | `CHAR(60)` | L7 |
| `vsqlerr` | `INTEGER` | L8 |
| `isam_err` | `SMALLINT` | L9 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tblpago` | `bdispei` | no | UPDATE | L41 |
| `sc_movdia` | `bdicheq` | ⚠️ sí | SELECT | L44 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L12 | CÓDIGO_RETORNO | `LET vcodret       	= '00000';` |  |
| L22 | CÓDIGO_RETORNO | `LET vcodret       	= '00000';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `?_query_cron_` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `exp` | MODIF | sufijo Exportar — SP genera/exporta archivo de salida (sp_*_ | 🟡 INFERIDO | nombre_sp |
| `?1` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_query_cron_`, `?1` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_refrescabonos`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_sp_refrescabonos.sql` |
| **LOC (1er CREATE)** | 153 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "abono" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 1 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=1 · INFERIDO=1 · SINTÉTICO=2 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_refrescabonos(
  pFechaValor                  date
  pStatus1                     CHAR(1)
  pStatus2                     CHAR(1)
  pStatus3                     CHAR(1)
  pStatus4                     CHAR(1)
  pStatus5                     CHAR(1)
  pStatus6                     CHAR(1)
  pStatus7                     CHAR(1)
) RETURNING INTEGER ,CHAR(1),CHAR(1), INTEGER, INTEGER,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pFechaValor` | `date` | — | — |
| `pStatus1` | `CHAR(1)` | — | — |
| `pStatus2` | `CHAR(1)` | — | — |
| `pStatus3` | `CHAR(1)` | — | — |
| `pStatus4` | `CHAR(1)` | — | — |
| `pStatus5` | `CHAR(1)` | — | — |
| `pStatus6` | `CHAR(1)` | — | — |
| `pStatus7` | `CHAR(1)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `v_codret` | `char(5)` | L26 |
| `v_monto_abo` | `money(16,2)` | L27 |
| `sql_err` | `integer` | L28 |
| `vintPkPago` | `integer` | L29 |
| `vcausadev` | `INTEGER` | L30 |
| `vmotivo` | `CHAR(40)` | L31 |
| `vt_intpkpago` | `INTEGER` | L33 |
| `vt_intfoliopago` | `INTEGER` | L34 |
| `vt_cvecesifbcoord` | `INTEGER` | L35 |
| `vt_vchrnombrecorto` | `VARCHAR(20)` | L36 |
| `vt_intcvetpooperacion` | `CHAR(2)` | L37 |
| `vt_vchrdesctipooper` | `VARCHAR(100)` | L38 |
| `vt_mnyimporte` | `decimal(19,2)` | L39 |
| `vt_intcvetipoctaord` | `INTEGER` | L40 |
| `vt_vchrdesctipoctaord` | `VARCHAR(100)` | L41 |
| `vt_intcvetipopago` | `INTEGER` | L42 |
| `vt_vchrdesctipopago` | `VARCHAR(100)` | L43 |
| `vt_chrestatusenvio` | `char(1)` | L44 |
| `vt_vchrnombreord` | `VARCHAR(40)` | L45 |
| `vt_vchrcuentaord` | `VARCHAR(20)` | L46 |
| `vt_vchrrfcord` | `VARCHAR(18)` | L47 |
| `vt_vchrnombrebenef` | `VARCHAR(40)` | L48 |
| `vt_intcvetipoctabene` | `INTEGER` | L49 |
| `vt_intcvetipoctaben` | `INTEGER` | L50 |
| `vt_vchrdesctipoctaben` | `VARCHAR(100)` | L51 |
| *…28 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tblpago` | `bdispei` | no | SELECT | L126 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `ref` | AMBIGUO | referencia | 🟡 INFERIDO | nombre_sp |
| `?resc` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `abono` | ENTIDAD | abono / crédito | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?s` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?resc`, `?s` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_regordenbcobco`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_sp_regordenbcobco.sql` |
| **LOC (1er CREATE)** | 110 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "registro orden" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 1 llamada(s): `sp_regordenpago` |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=1 · INFERIDO=1 · SINTÉTICO=1 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_regordenbcobco(
  pchrUsuario                  CHAR(8)
  pchrSucursal                 CHAR(4)
  pchrFolio                    CHAR(16)
  pmnyImporteOP                MONEY(18,2)
  pintBancoRec                 INTEGER
  pintTipoOper                 INTEGER
  pdtFechaValor                DATE
  pvchrConceptoPago            VARCHAR(210)
  pdecRefNum                   DECIMAL(7,0)
  pchrTrans                    CHAR(4)
) RETURNING CHAR(5), CHAR(30)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pchrUsuario` | `CHAR(8)` | — | — |
| `pchrSucursal` | `CHAR(4)` | — | — |
| `pchrFolio` | `CHAR(16)` | — | — |
| `pmnyImporteOP` | `MONEY(18,2)` | — | — |
| `pintBancoRec` | `INTEGER` | — | — |
| `pintTipoOper` | `INTEGER` | — | — |
| `pdtFechaValor` | `DATE` | — | — |
| `pvchrConceptoPago` | `VARCHAR(210)` | — | — |
| `pdecRefNum` | `DECIMAL(7,0)` | — | — |
| `pchrTrans` | `CHAR(4)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vchrcodret` | `CHAR(5)` | L40 |
| `vintcodret` | `INTEGER` | L41 |
| `vvchrCveRastreo` | `VARCHAR(30)` | L42 |
| `vdtfecha` | `DATE` | L43 |
| `vchrFechaSPEI` | `VARCHAR(10)` | L44 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tblparametros` | `bdispei` | no | SELECT | L61 |
| `tblpago` | `bdispei` | no | UPDATE | L97 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_regordenpago` | `bdispei` | no | L67 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `reg` | ACCION | registro | 🟡 INFERIDO | nombre_sp |
| `orden` | ENTIDAD | orden | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?bcobco` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?bcobco` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_regordenbcocte`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_sp_regordenbcocte.sql` |
| **LOC (1er CREATE)** | 115 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "registro orden y cliente" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 1 llamada(s): `sp_regordenpago` |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=2 · INFERIDO=1 · SINTÉTICO=1 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_regordenbcocte(
  pchrUsuario                  CHAR(8)
  pchrSucursal                 CHAR(4)
  pchrFolio                    CHAR(16)
  pmnyImporteOP                MONEY(18,2)
  pintBancoRec                 INTEGER
  pvchrNombreBenef             VARCHAR(40)
  pintTipoCtaBenef             INTEGER
  pvchrCtaBenef                VARCHAR(20)
  pvchrRFCBenef                VARCHAR(18)
  pdtFechaValor                DATE
  pvchrConceptoPago            VARCHAR(40)
  pdecRefNum                   DECIMAL(7,0)
  pchrTrans                    CHAR(4)
) RETURNING CHAR(5), CHAR(30)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pchrUsuario` | `CHAR(8)` | — | — |
| `pchrSucursal` | `CHAR(4)` | — | — |
| `pchrFolio` | `CHAR(16)` | — | — |
| `pmnyImporteOP` | `MONEY(18,2)` | — | — |
| `pintBancoRec` | `INTEGER` | — | — |
| `pvchrNombreBenef` | `VARCHAR(40)` | — | — |
| `pintTipoCtaBenef` | `INTEGER` | — | — |
| `pvchrCtaBenef` | `VARCHAR(20)` | — | — |
| `pvchrRFCBenef` | `VARCHAR(18)` | — | — |
| `pdtFechaValor` | `DATE` | — | — |
| `pvchrConceptoPago` | `VARCHAR(40)` | — | — |
| `pdecRefNum` | `DECIMAL(7,0)` | — | — |
| `pchrTrans` | `CHAR(4)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vchrcodret` | `CHAR(5)` | L47 |
| `vintcodret` | `INTEGER` | L48 |
| `vvchrCveRastreo` | `VARCHAR(30)` | L49 |
| `vdtfecha` | `DATE` | L50 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tblparametros` | `bdispei` | no | SELECT | L69 |
| `tblpago` | `bdispei` | no | UPDATE | L104 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_regordenpago` | `bdispei` | no | L77 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L67 | VALIDACIÓN_NULL | `if (pdtFechaValor is null) or (pdtFechaValor = '') then` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `reg` | ACCION | registro | 🟡 INFERIDO | nombre_sp |
| `orden` | ENTIDAD | orden | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?bco` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `cte` | ENTIDAD | cliente | 🔵 CONVENCIÓN | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?bco` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_regordenbcoctep`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_sp_regordenbcoctep.sql` |
| **LOC (1er CREATE)** | 102 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "registro orden y cliente" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 1 llamada(s): `sp_regordenpago` |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=2 · INFERIDO=1 · SINTÉTICO=2 / 6 términos |

### Firma

```sql
CREATE PROCEDURE sp_regordenbcoctep(
  pchrUsuario                  CHAR(8)
  pchrSucursal                 CHAR(4)
  pchrFolio                    CHAR(16)
  pmnyImporteOP                MONEY(18,2)
  pintBancoRec                 INTEGER
  pvchrNombreBenef             VARCHAR(40)
  pintTipoCtaBenef             INTEGER
  pvchrCtaBenef                VARCHAR(20)
  pvchrRFCBenef                VARCHAR(18)
  pdtFechaValor                DATE
  pvchrConceptoPago            VARCHAR(40)
  pdecRefNum                   DECIMAL(7,0)
  vvchrCveRastreo              VARCHAR(30)
  pchrTrans                    CHAR(4)
) RETURNING CHAR(5), CHAR(30)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pchrUsuario` | `CHAR(8)` | — | — |
| `pchrSucursal` | `CHAR(4)` | — | — |
| `pchrFolio` | `CHAR(16)` | — | — |
| `pmnyImporteOP` | `MONEY(18,2)` | — | — |
| `pintBancoRec` | `INTEGER` | — | — |
| `pvchrNombreBenef` | `VARCHAR(40)` | — | — |
| `pintTipoCtaBenef` | `INTEGER` | — | — |
| `pvchrCtaBenef` | `VARCHAR(20)` | — | — |
| `pvchrRFCBenef` | `VARCHAR(18)` | — | — |
| `pdtFechaValor` | `DATE` | — | — |
| `pvchrConceptoPago` | `VARCHAR(40)` | — | — |
| `pdecRefNum` | `DECIMAL(7,0)` | — | — |
| `vvchrCveRastreo` | `VARCHAR(30)` | — | — |
| `pchrTrans` | `CHAR(4)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vchrcodret` | `CHAR(5)` | L48 |
| `vintcodret` | `INTEGER` | L49 |
| `vdtfecha` | `DATE` | L51 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tblparametros` | `bdispei` | no | SELECT | L66 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_regordenpago` | `bdispei` | no | L73 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L64 | VALIDACIÓN_NULL | `if (pdtFechaValor is null) or (pdtFechaValor = '') then` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `reg` | ACCION | registro | 🟡 INFERIDO | nombre_sp |
| `orden` | ENTIDAD | orden | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?bco` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `cte` | ENTIDAD | cliente | 🔵 CONVENCIÓN | nombre_sp |
| `?p` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?bco`, `?p` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_regordenctecte`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_sp_regordenctecte.sql` |
| **LOC (1er CREATE)** | 776 |
| **Callgraph** | ✅ fan_in=0 / fan_out=5 |
| **Propósito inferido** | "Regresa Orden Cuenta a Cuenta — operación de transferencia/orden entre cuentas propias del cliente" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 5 llamada(s): `sp_validaspei_bpi`, `sp_validadv`, `sp_regordenpagospei` |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=1 · INFERIDO=1 · SINTÉTICO=0 / 2 términos |

### Firma

```sql
CREATE PROCEDURE sp_regordenctecte(
  pEmpresa                     CHAR(3)
) RETURNING CHAR(5), char(100), CHAR(30)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pEmpresa` | `CHAR(3)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cVarDataErr` | `CHAR(100)` | L25 |
| `vchrcodret` | `CHAR(5)` | L26 |
| `vintcodret` | `INTEGER` | L27 |
| `vchrCveRastreo` | `CHAR(30)` | L28 |
| `vintPermiteCta11` | `INTEGER` | L29 |
| `vchrFuente` | `CHAR(7)` | L30 |
| `vchrTranscargo` | `CHAR(4)` | L31 |
| `vchrComis` | `CHAR(4)` | L32 |
| `vchrIvaComis` | `CHAR(4)` | L33 |
| `vchrtranret` | `CHAR(4)` | L34 |
| `dteFechacargo` | `DATE` | L35 |
| `vmnySdoDisp` | `MONEY(14,2)` | L36 |
| `vmnyMontoRet` | `MONEY(14,2)` | L37 |
| `vchrTarjeta` | `CHAR(20)` | L38 |
| `vtransaccion` | `INTEGER` | L39 |
| `vchrparametro` | `VARCHAR(255)` | L40 |
| `vchrFechaValor` | `VARCHAR(10)` | L41 |
| `dIva` | `DECIMAL(5,3)` | L42 |
| `vmnyMontoLibre` | `MONEY(14,2)` | L43 |
| `vdigitoverifica` | `SMALLINT` | L44 |
| `vexiste_cta` | `CHAR(20)` | L45 |
| `vexiste_suc` | `CHAR(4)` | L46 |
| `vchrCtaOrdClabe` | `VARCHAR(20)` | L47 |
| `vchrCtaOrdtblp` | `VARCHAR(20)` | L48 |
| `vchrTelefono` | `CHAR(10)` | L49 |
| *…33 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sc_fechas` | `bdicheq` | ⚠️ sí | SELECT | L161 |
| `sc_tarjeta` | `bdicheq` | ⚠️ sí | SELECT | L188 |
| `sc_maechq` | `bdicheq` | ⚠️ sí | SELECT | L202 |
| `tf_maecte` | `bditransfer` | ⚠️ sí | SELECT | L213 |
| `si_param` | `bdinteg` | ⚠️ sí | SELECT | L240 |
| `tblparametros` | `bdispei` | no | SELECT | L253 |
| `sc_cuenta_telefono` | `bdicheq` | ⚠️ sí | SELECT | L327 |
| `si_sucursales` | `bdinteg` | ⚠️ sí | SELECT | L489 |
| `si_transacc` | `bdinteg` | ⚠️ sí | SELECT | L501 |
| `tbldetranpago` | `bdispei` | no | INSERT | L550 |
| `sc_movdia` | `bdicheq` | ⚠️ sí | SELECT | L627 |
| `tblpago` | `bdispei` | no | INSERT | L745 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_validaspei_bpi` | `bdispei` | no | L175 |
| `sp_validadv` | `bdispei` | no | L365 |
| `sp_regordenpagospei` | `bdispei` | no | L446 |
| `cargo_ref` | `bdicheq` | ⚠️ sí | L520 |
| `sp_validafecha` | `bdispei` | no | L646 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L193 | VALIDACIÓN_NULL | `IF (vchrTarjeta is null) OR (vchrTarjeta = '') then` |  |
| L222 | VALIDACIÓN_NULL | `IF pvchrCuentaOrd IS NULL OR pvchrCuentaOrd = '' THEN` |  |
| L231 | VALIDACIÓN_NULL | `IF (pdtfechacaptura is null) or (pdtfechacaptura = '') then` |  |
| L244 | VALIDACIÓN_NULL | `IF dIva IS NULL THEN` |  |
| L256 | VALIDACIÓN_NULL | `IF vchrparametro IS NULL THEN` |  |
| L263 | FÓRMULA | `LET vchrFechaValor = SUBSTR(TRIM(vchrparametro),4,2) \|\| '/' \|\| SUBSTR(TRIM(vchrparametro),0,2) \` |  |
| L280 | VALIDACIÓN_NULL | `IF vchrCtaOrdClabe IS NULL THEN` |  |
| L311 | VALIDACIÓN_NULL | `IF vexiste_cta is null OR vexiste_cta = '' THEN` |  |
| L340 | VALIDACIÓN_NULL | `IF vexiste_cta is null OR vexiste_cta = '' THEN` |  |
| L353 | VALIDACIÓN_NULL | `IF pvchrCuentaOrd is null OR pvchrCuentaOrd = '' THEN` |  |
| L384 | VALIDACIÓN_NULL | `IF pvchrCuentaBenef is null OR pvchrCuentaBenef = '' THEN` |  |
| L403 | VALIDACIÓN_NULL | `IF vchrTranscargo IS NULL OR vchrTranscargo = '' THEN` |  |
| L415 | VALIDACIÓN_NULL | `IF vchrComis IS NULL OR vchrCOmis = '' THEN` |  |
| L426 | VALIDACIÓN_NULL | `IF vchrIvaComis IS NULL OR vchrIvaComis = '' THEN` |  |
| L497 | VALIDACIÓN_NULL | `IF vexiste_suc is null OR vexiste_suc = '' THEN` |  |
| L649 | FÓRMULA | `LET vchrFechaValor = to_char(vfechaHabil, '%m/%d/%Y');` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `regordenctecte` | ACCION | Regresa Orden Cuenta a Cuenta — operación de transferencia/o | 🟡 INFERIDO | nombre_sp |

---

## `sp_regordenctecte_bex`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_sp_regordenctecte_bex.sql` |
| **LOC (1er CREATE)** | 931 |
| **Callgraph** | ✅ fan_in=0 / fan_out=8 |
| **Propósito inferido** | "Regresa Orden Cuenta a Cuenta — operación de transferencia/orden entre cuentas propias del cliente BEX — canal o plataforma de Banca Por Internet" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 8 llamada(s): `sp_validaspei_bpi`, `spei_validaoperacion`, `sp_validadv` |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=1 · INFERIDO=2 · SINTÉTICO=0 / 3 términos |

### Firma

```sql
CREATE PROCEDURE sp_regordenctecte_bex(
  pEmpresa                     CHAR(3)
  pchrSucursal                 CHAR(4)
  pchrUsuario                  CHAR(8)
  pintBancoDest                INTEGER
  pmnyImporte                  MONEY(14,2)
  pchrTransuc                  CHAR(4)
  pchrFolioSuc                 CHAR(16)
  pdtfechacaptura              DATE
  pmnyComision                 MONEY(14,2)
  pmnyIvaComis                 MONEY(14,2)
  pvchrNombreOrd               VARCHAR(40)
  pintTipoCtaOrd               INTEGER
  pvchrCuentaOrd               VARCHAR(20)
  pvchrRfcOrd                  VARCHAR(18)
  pvchrNombreBenef             VARCHAR(40)
  pintTipoCtaBenef             INTEGER
  pvchrCtaBenef                VARCHAR(20)
  pvchrRFCBenef                VARCHAR(18)
  pvchrConceptoPago            VARCHAR(40)
  pmnyIVA                      MONEY(14,2)
  pdecRefNum                   DECIMAL(7,0)
  pvchrRefCobranza1            VARCHAR(40)
) RETURNING CHAR(5), CHAR(30)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pEmpresa` | `CHAR(3)` | — | — |
| `pchrSucursal` | `CHAR(4)` | — | — |
| `pchrUsuario` | `CHAR(8)` | — | — |
| `pintBancoDest` | `INTEGER` | — | — |
| `pmnyImporte` | `MONEY(14,2)` | — | — |
| `pchrTransuc` | `CHAR(4)` | — | — |
| `pchrFolioSuc` | `CHAR(16)` | — | — |
| `pdtfechacaptura` | `DATE` | — | — |
| `pmnyComision` | `MONEY(14,2)` | — | — |
| `pmnyIvaComis` | `MONEY(14,2)` | — | — |
| `pvchrNombreOrd` | `VARCHAR(40)` | — | — |
| `pintTipoCtaOrd` | `INTEGER` | — | — |
| `pvchrCuentaOrd` | `VARCHAR(20)` | — | — |
| `pvchrRfcOrd` | `VARCHAR(18)` | — | — |
| `pvchrNombreBenef` | `VARCHAR(40)` | — | — |
| `pintTipoCtaBenef` | `INTEGER` | — | — |
| `pvchrCtaBenef` | `VARCHAR(20)` | — | — |
| `pvchrRFCBenef` | `VARCHAR(18)` | — | — |
| `pvchrConceptoPago` | `VARCHAR(40)` | — | — |
| `pmnyIVA` | `MONEY(14,2)` | — | — |
| `pdecRefNum` | `DECIMAL(7,0)` | — | — |
| `pvchrRefCobranza1` | `VARCHAR(40)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cVarDataErr` | `CHAR(100)` | L62 |
| `vchrcodret` | `CHAR(5)` | L63 |
| `vchrcodret2` | `CHAR(5)` | L64 |
| `vcharcodret3` | `CHAR(50)` | L65 |
| `vintcodret` | `INTEGER` | L66 |
| `vintcodret2` | `INTEGER` | L67 |
| `vchrcodret3` | `CHAR(50)` | L68 |
| `vchrCveRastreo` | `CHAR(30)` | L69 |
| `vintPermiteCta11` | `INTEGER` | L70 |
| `vchrFuente` | `CHAR(7)` | L71 |
| `vchrTranscargo` | `CHAR(4)` | L72 |
| `vchrComis` | `CHAR(4)` | L73 |
| `vchrIvaComis` | `CHAR(4)` | L74 |
| `vchrtranret` | `CHAR(4)` | L75 |
| `dteFechacargo` | `DATE` | L76 |
| `vmnySdoDisp` | `MONEY(14,2)` | L77 |
| `vmnyMontoRet` | `MONEY(14,2)` | L78 |
| `vchrTarjeta` | `CHAR(20)` | L79 |
| `vtransaccion` | `INTEGER` | L80 |
| `vchrparametro` | `VARCHAR(255)` | L81 |
| `vchrFechaValor` | `VARCHAR(10)` | L82 |
| `dIva` | `DECIMAL(5,3)` | L83 |
| `vmnyMontoLibre` | `MONEY(14,2)` | L84 |
| `vdigitoverifica` | `SMALLINT` | L85 |
| `vexiste_suc` | `CHAR(4)` | L86 |
| *…39 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tblspeican` | `bdispei` | no | INSERT | L215 |
| `sc_fechas` | `bdicheq` | ⚠️ sí | SELECT | L229 |
| `tblparametros` | `bdispei` | no | SELECT | L244 |
| `sc_tarjeta` | `bdicheq` | ⚠️ sí | SELECT | L293 |
| `sc_maechq` | `bdicheq` | ⚠️ sí | SELECT | L307 |
| `sc_cuenta_telefono` | `bdicheq` | ⚠️ sí | SELECT | L357 |
| `tf_maecte` | `bditransfer` | ⚠️ sí | SELECT | L363 |
| `si_param` | `bdinteg` | ⚠️ sí | SELECT | L420 |
| `si_sucursales` | `bdinteg` | ⚠️ sí | SELECT | L470 |
| `si_ejecut` | `bdinteg` | ⚠️ sí | SELECT | L482 |
| `tbltipopago` | `bdispei` | no | SELECT | L494 |
| `tbltipooperacion` | `bdispei` | no | SELECT | L512 |
| `tblbanco` | `bdispei` | no | SELECT | L537 |
| `tblpago` | `bdispei` | no | SELECT | L559 |
| `si_transacc` | `bdinteg` | ⚠️ sí | SELECT | L629 |
| `tbldetranpago` | `bdispei` | no | INSERT | L710 |
| `tblpago` | `bdispei` | no | INSERT | L902 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_validaspei_bpi` | `bdispei` | no | L263 |
| `spei_validaoperacion` | `bdispei` | no | L280 |
| `sp_validadv` | `bdispei` | no | L393 |
| `sp_obtsigfolioop` | `bdispei` | no | L653 |
| `digver11` | `bdicheq` | ⚠️ sí | L656 |
| `cargo_ref` | `bdicheq` | ⚠️ sí | L693 |
| `sp_validafecha` | `bdispei` | no | L786 |
| `sp_quitar_acentos` | `bdinteg` | ⚠️ sí | L803 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L205 | VALIDACIÓN_NULL | `IF pvchrNombreOrd IS NULL OR pvchrNombreOrd = '' OR` |  |
| L247 | VALIDACIÓN_NULL | `IF vchrparametro IS NULL THEN` |  |
| L273 | VALIDACIÓN_NULL | `IF (pdtfechacaptura is null) OR (pdtfechacaptura = '') then` |  |
| L298 | VALIDACIÓN_NULL | `IF (vchrTarjeta is null) OR (vchrTarjeta = '') THEN` |  |
| L312 | VALIDACIÓN_NULL | `IF pvchrCuentaOrd IS NULL OR pvchrCuentaOrd = '' THEN` |  |
| L330 | VALIDACIÓN_NULL | `IF vchrCtaOrdClabe IS NULL THEN` |  |
| L360 | VALIDACIÓN_NULL | `IF pvchrCuentaOrd is null OR pvchrCuentaOrd = '' THEN` |  |
| L380 | VALIDACIÓN_NULL | `IF vchrTelefono is null OR vchrTelefono = '' OR pvchrCuentaOrd is null OR pvchrCuentaOrd = '' THEN` |  |
| L424 | VALIDACIÓN_NULL | `IF dIva IS NULL THEN` |  |
| L436 | FÓRMULA | `LET vchrFechaValor = SUBSTR(vchrFechaVal,4,2) \|\| '/' \|\| SUBSTR(vchrFechaVal,1,2) \|\| '/' \|\| S` |  |
| L445 | VALIDACIÓN_NULL | `IF vchrparametro IS NULL THEN` |  |
| L459 | VALIDACIÓN_NULL | `IF vchrparametro IS NULL THEN` |  |
| L465 | FÓRMULA | `LET intBancoOrd = (vchrparametro * 1);` |  |
| L542 | VALIDACIÓN_NULL | `IF vintCveCesif IS NULL THEN` |  |
| L576 | VALIDACIÓN_NULL | `IF vchrTranscargo IS NULL OR vchrTranscargo = '' THEN` |  |
| L593 | VALIDACIÓN_NULL | `IF vchrComis IS NULL OR vchrCOmis = '' THEN` |  |
| L604 | VALIDACIÓN_NULL | `IF vchrIvaComis IS NULL OR vchrIvaComis = '' THEN` |  |
| L625 | VALIDACIÓN_NULL | `IF vexiste_suc is null OR vexiste_suc = '' THEN` |  |
| L687 | VALIDACIÓN_NULL | `IF pdecRefNum IS NULL or pdecRefNum = 0 THEN` |  |
| L688 | FÓRMULA | `LET pdecRefNum = SUBSTR(LPAD(intpktblpago, 12, '0'), -7);` |  |
| L789 | FÓRMULA | `LET vchrFechaValor = to_char(vfechaHabil, '%m/%d/%Y');` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `regordenctecte` | ACCION | Regresa Orden Cuenta a Cuenta — operación de transferencia/o | 🟡 INFERIDO | nombre_sp |
| `bex` | ENTIDAD | BEX — canal o plataforma de Banca Por Internet (bdibpi); ges | 🟡 INFERIDO | nombre_sp |

---

## `sp_regordenctecte_bex_codi`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_sp_regordenctecte_bex_codi.sql` |
| **LOC (1er CREATE)** | 1361 |
| **Callgraph** | ✅ fan_in=0 / fan_out=9 |
| **Deps concatenadas** | 1 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "Regresa Orden Cuenta a Cuenta — operación de transferencia/orden entre cuentas propias del cliente BEX — canal o plataforma de Banca Por Internet · CoDi — Cobro Digital" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 9 llamada(s): `spei_recerrorescodi`, `sp_validaspei_bpi`, `spei_validaoperacion` |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=1 · INFERIDO=2 · SINTÉTICO=0 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_regordenctecte_bex_codi(
  pEmpresa                     CHAR(3)
  pchrSucursal                 CHAR(4)
  pchrUsuario                  CHAR(8)
  pintBancoDest                INTEGER
  pmnyImporte                  MONEY(14,2)
  pchrTransuc                  CHAR(4)
  pchrFolioSuc                 CHAR(16)
  pdtfechacaptura              DATE
  pmnyComision                 MONEY(14,2)
  pmnyIvaComis                 MONEY(14,2)
  pvchrNombreOrd               VARCHAR(40)
  pintTipoCtaOrd               INTEGER
  pvchrCuentaOrd               VARCHAR(20)
  pvchrRfcOrd                  VARCHAR(18)
  pvchrNombreBenef             VARCHAR(40)
  pintTipoCtaBenef             INTEGER
  pvchrCtaBenef                VARCHAR(20)
  pvchrRFCBenef                VARCHAR(18)
  pvchrConceptoPago            VARCHAR(40)
  pmnyIVA                      MONEY(14,2)
  pdecRefNum                   DECIMAL(7,0)
  pvchrRefCobranza1            VARCHAR(40)
  pchartipopago                CHAR(2)
  pnumcelord                   CHAR(10)
  pdigidord                    INTEGER
  pdigidben                    INTEGER
  pfechalimpago                CHAR(16)
  pindbenef                    CHAR(3)
  ppagocomision                INTEGER
  pcomision                    MONEY(14,2)
  pnumseriecert                CHAR(20)
  pfolioplataforma             CHAR(20)
  pchrfchmjc                   CHAR(20)
) RETURNING CHAR(5), CHAR(30)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pEmpresa` | `CHAR(3)` | — | — |
| `pchrSucursal` | `CHAR(4)` | — | — |
| `pchrUsuario` | `CHAR(8)` | — | — |
| `pintBancoDest` | `INTEGER` | — | — |
| `pmnyImporte` | `MONEY(14,2)` | — | — |
| `pchrTransuc` | `CHAR(4)` | — | — |
| `pchrFolioSuc` | `CHAR(16)` | — | — |
| `pdtfechacaptura` | `DATE` | — | — |
| `pmnyComision` | `MONEY(14,2)` | — | — |
| `pmnyIvaComis` | `MONEY(14,2)` | — | — |
| `pvchrNombreOrd` | `VARCHAR(40)` | — | — |
| `pintTipoCtaOrd` | `INTEGER` | — | — |
| `pvchrCuentaOrd` | `VARCHAR(20)` | — | — |
| `pvchrRfcOrd` | `VARCHAR(18)` | — | — |
| `pvchrNombreBenef` | `VARCHAR(40)` | — | — |
| `pintTipoCtaBenef` | `INTEGER` | — | — |
| `pvchrCtaBenef` | `VARCHAR(20)` | — | — |
| `pvchrRFCBenef` | `VARCHAR(18)` | — | — |
| `pvchrConceptoPago` | `VARCHAR(40)` | — | — |
| `pmnyIVA` | `MONEY(14,2)` | — | — |
| `pdecRefNum` | `DECIMAL(7,0)` | — | — |
| `pvchrRefCobranza1` | `VARCHAR(40)` | — | — |
| `pchartipopago` | `CHAR(2)` | — | — |
| `pnumcelord` | `CHAR(10)` | — | — |
| `pdigidord` | `INTEGER` | — | — |
| `pdigidben` | `INTEGER` | — | — |
| `pfechalimpago` | `CHAR(16)` | — | — |
| `pindbenef` | `CHAR(3)` | — | — |
| `ppagocomision` | `INTEGER` | — | — |
| `pcomision` | `MONEY(14,2)` | — | — |
| `pnumseriecert` | `CHAR(20)` | — | — |
| `pfolioplataforma` | `CHAR(20)` | — | — |
| `pchrfchmjc` | `CHAR(20)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cVarDataErr` | `CHAR(100)` | L84 |
| `vcodret` | `char(5)` | L85 |
| `vchrcodret` | `CHAR(5)` | L86 |
| `vchrcodret2` | `CHAR(5)` | L87 |
| `vcharcodret3` | `CHAR(50)` | L88 |
| `vintcodret` | `INTEGER` | L89 |
| `vintcodret2` | `INTEGER` | L90 |
| `vchrcodret3` | `CHAR(50)` | L91 |
| `vchrCveRastreo` | `CHAR(30)` | L92 |
| `vintPermiteCta11` | `INTEGER` | L93 |
| `vchrFuente` | `CHAR(7)` | L94 |
| `vchrTranscargo` | `CHAR(4)` | L95 |
| `vchrComis` | `CHAR(4)` | L96 |
| `vchrIvaComis` | `CHAR(4)` | L97 |
| `vchrtranret` | `CHAR(4)` | L98 |
| `dteFechacargo` | `DATE` | L99 |
| `vmnySdoDisp` | `MONEY(14,2)` | L100 |
| `vmnyMontoRet` | `MONEY(14,2)` | L101 |
| `vchrTarjeta` | `CHAR(20)` | L102 |
| `vtransaccion` | `INTEGER` | L103 |
| `vchrparametro` | `VARCHAR(255)` | L104 |
| `vchrFechaValor` | `VARCHAR(10)` | L105 |
| `dIva` | `DECIMAL(5,3)` | L106 |
| `vmnyMontoLibre` | `MONEY(14,2)` | L107 |
| `vdigitoverifica` | `SMALLINT` | L108 |
| *…55 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tblparametros` | `bdispei` | no | SELECT | L256 |
| `sc_fechas` | `bdicheq` | ⚠️ sí | SELECT | L314 |
| `sc_tarjeta` | `bdicheq` | ⚠️ sí | SELECT | L420 |
| `sc_maechq` | `bdicheq` | ⚠️ sí | SELECT | L441 |
| `sc_cuenta_telefono` | `bdicheq` | ⚠️ sí | SELECT | L519 |
| `tf_maecte` | `bditransfer` | ⚠️ sí | SELECT | L525 |
| `si_param` | `bdinteg` | ⚠️ sí | SELECT | L637 |
| `si_sucursales` | `bdinteg` | ⚠️ sí | SELECT | L688 |
| `si_ejecut` | `bdinteg` | ⚠️ sí | SELECT | L707 |
| `tbltipopago` | `bdispei` | no | SELECT | L726 |
| `tbltipooperacion` | `bdispei` | no | SELECT | L751 |
| `tblbanco` | `bdispei` | no | SELECT | L789 |
| `tblpago` | `bdispei` | no | SELECT | L825 |
| `si_transacc` | `bdinteg` | ⚠️ sí | SELECT | L925 |
| `tbldetranpago` | `bdispei` | no | INSERT | L1019 |
| `tblpago` | `bdispei` | no | INSERT | L1308 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `spei_recerrorescodi` | `bdispei` | no | L267 |
| `sp_validaspei_bpi` | `bdispei` | no | L369 |
| `spei_validaoperacion` | `bdispei` | no | L400 |
| `sp_validadv` | `bdispei` | no | L562 |
| `sp_obtsigfolioop` | `bdispei` | no | L944 |
| `digver11` | `bdicheq` | ⚠️ sí | L947 |
| `cargo_ref` | `bdicheq` | ⚠️ sí | L991 |
| `sp_validafecha` | `bdispei` | no | L1109 |
| `sp_quitar_acentos` | `bdinteg` | ⚠️ sí | L1126 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L259 | FÓRMULA | `LET intBancoOrd = (vchrparametro * 1);` |  |
| L261 | VALIDACIÓN_NULL | `IF vchrparametro IS NULL THEN` |  |
| L265 | FÓRMULA | `LET vtimestamp  = dbinfo('utc_current') * 1000;` |  |
| L275 | VALIDACIÓN_NULL | `IF pvchrNombreOrd IS NULL OR pvchrNombreOrd = '' OR` |  |
| L284 | FÓRMULA | `LET vtimestamp  = dbinfo('utc_current') * 1000;` |  |
| L294 | VALIDACIÓN_NULL | `IF pvchrNombreBenef IS NULL OR pvchrNombreBenef = '' OR` |  |
| L300 | FÓRMULA | `LET vtimestamp  = dbinfo('utc_current') * 1000;` |  |
| L322 | FÓRMULA | `LET vtimestamp  = dbinfo('utc_current') * 1000;` |  |
| L339 | VALIDACIÓN_NULL | `IF vchrparametro IS NULL THEN` |  |
| L342 | FÓRMULA | `LET vtimestamp  = dbinfo('utc_current') * 1000;` |  |
| L355 | FÓRMULA | `LET vtimestamp  = dbinfo('utc_current') * 1000;` |  |
| L373 | FÓRMULA | `LET vtimestamp  = dbinfo('utc_current') * 1000;` |  |
| L386 | VALIDACIÓN_NULL | `IF (pdtfechacaptura is null) OR (pdtfechacaptura = '') then` |  |
| L389 | FÓRMULA | `LET vtimestamp  = dbinfo('utc_current') * 1000;` |  |
| L406 | FÓRMULA | `LET vtimestamp  = dbinfo('utc_current') * 1000;` |  |
| L425 | VALIDACIÓN_NULL | `IF (vchrTarjeta is null) OR (vchrTarjeta = '') THEN` |  |
| L428 | FÓRMULA | `LET vtimestamp  = dbinfo('utc_current') * 1000;` |  |
| L446 | VALIDACIÓN_NULL | `IF pvchrCuentaOrd IS NULL OR pvchrCuentaOrd = '' THEN` |  |
| L449 | FÓRMULA | `LET vtimestamp  = dbinfo('utc_current') * 1000;` |  |
| L471 | VALIDACIÓN_NULL | `IF vchrCtaOrdClabe IS NULL THEN` |  |
| L474 | FÓRMULA | `LET vtimestamp  = dbinfo('utc_current') * 1000;` |  |
| L490 | FÓRMULA | `LET vtimestamp  = dbinfo('utc_current') * 1000;` |  |
| L502 | FÓRMULA | `LET vtimestamp  = dbinfo('utc_current') * 1000;` |  |
| L522 | VALIDACIÓN_NULL | `IF pvchrCuentaOrd is null OR pvchrCuentaOrd = '' THEN` |  |
| L542 | VALIDACIÓN_NULL | `IF vchrTelefono is null OR vchrTelefono = '' OR pvchrCuentaOrd is null OR pvchrCuentaOrd = '' THEN` |  |
| L545 | FÓRMULA | `LET vtimestamp  = dbinfo('utc_current') * 1000;` |  |
| L568 | FÓRMULA | `LET vtimestamp  = dbinfo('utc_current') * 1000;` |  |
| L580 | FÓRMULA | `LET vtimestamp  = dbinfo('utc_current') * 1000;` |  |
| L597 | FÓRMULA | `LET vtimestamp  = dbinfo('utc_current') * 1000;` |  |
| L641 | VALIDACIÓN_NULL | `IF dIva IS NULL THEN` |  |
| | *…29 más…* | | |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `regordenctecte` | ACCION | Regresa Orden Cuenta a Cuenta — operación de transferencia/o | 🟡 INFERIDO | nombre_sp |
| `bex` | ENTIDAD | BEX — canal o plataforma de Banca Por Internet (bdibpi); ges | 🟡 INFERIDO | nombre_sp |
| `codi` | REG | CoDi — Cobro Digital (Banxico) | ✅ CÓDIGO | nombre_sp, texto_cuerpo |

---

## `sp_regordenctecte_bex_codi_exp1`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_sp_regordenctecte_bex_codi_exp1.sql` |
| **LOC (1er CREATE)** | 1305 |
| **Callgraph** | ✅ fan_in=0 / fan_out=10 |
| **Deps concatenadas** | 1 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "Regresa Orden Cuenta a Cuenta — operación de transferencia/orden entre cuentas propias del cliente BEX — canal o plataforma de Banca Por Internet (sufijo Exportar — SP genera/exporta archivo de salida) · CoDi — Cobro Digital" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `genera` → `INSERT` encontrado en el cuerpo · `genera` → `SELECT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=1 · INFERIDO=3 · SINTÉTICO=1 / 6 términos |

### Firma

```sql
CREATE PROCEDURE sp_regordenctecte_bex_codi_exp1(
  pEmpresa                     CHAR(3)
  pchrSucursal                 CHAR(4)
  pchrUsuario                  CHAR(8)
  pintBancoDest                INTEGER
  pmnyImporte                  MONEY(14,2)
  pchrTransuc                  CHAR(4)
  pchrFolioSuc                 CHAR(16)
  pdtfechacaptura              DATE
  pmnyComision                 MONEY(14,2)
  pmnyIvaComis                 MONEY(14,2)
  pvchrNombreOrd               VARCHAR(40)
  pintTipoCtaOrd               INTEGER
  pvchrCuentaOrd               VARCHAR(20)
  pvchrRfcOrd                  VARCHAR(18)
  pvchrNombreBenef             VARCHAR(40)
  pintTipoCtaBenef             INTEGER
  pvchrCtaBenef                VARCHAR(20)
  pvchrRFCBenef                VARCHAR(18)
  pvchrConceptoPago            VARCHAR(40)
  pmnyIVA                      MONEY(14,2)
  pdecRefNum                   DECIMAL(7,0)
  pvchrRefCobranza1            VARCHAR(40)
  pchartipopago                CHAR(2)
  pnumcelord                   CHAR(10)
  pdigidord                    INTEGER
  pdigidben                    INTEGER
  pfechalimpago                CHAR(16)
  pindbenef                    CHAR(3)
  ppagocomision                INTEGER
  pcomision                    MONEY(14,2)
  pnumseriecert                CHAR(20)
  pfolioplataforma             CHAR(20)
  pchrfchmjc                   CHAR(20)
) RETURNING CHAR(5), CHAR(30)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pEmpresa` | `CHAR(3)` | — | — |
| `pchrSucursal` | `CHAR(4)` | — | — |
| `pchrUsuario` | `CHAR(8)` | — | — |
| `pintBancoDest` | `INTEGER` | — | — |
| `pmnyImporte` | `MONEY(14,2)` | — | — |
| `pchrTransuc` | `CHAR(4)` | — | — |
| `pchrFolioSuc` | `CHAR(16)` | — | — |
| `pdtfechacaptura` | `DATE` | — | — |
| `pmnyComision` | `MONEY(14,2)` | — | — |
| `pmnyIvaComis` | `MONEY(14,2)` | — | — |
| `pvchrNombreOrd` | `VARCHAR(40)` | — | — |
| `pintTipoCtaOrd` | `INTEGER` | — | — |
| `pvchrCuentaOrd` | `VARCHAR(20)` | — | — |
| `pvchrRfcOrd` | `VARCHAR(18)` | — | — |
| `pvchrNombreBenef` | `VARCHAR(40)` | — | — |
| `pintTipoCtaBenef` | `INTEGER` | — | — |
| `pvchrCtaBenef` | `VARCHAR(20)` | — | — |
| `pvchrRFCBenef` | `VARCHAR(18)` | — | — |
| `pvchrConceptoPago` | `VARCHAR(40)` | — | — |
| `pmnyIVA` | `MONEY(14,2)` | — | — |
| `pdecRefNum` | `DECIMAL(7,0)` | — | — |
| `pvchrRefCobranza1` | `VARCHAR(40)` | — | — |
| `pchartipopago` | `CHAR(2)` | — | — |
| `pnumcelord` | `CHAR(10)` | — | — |
| `pdigidord` | `INTEGER` | — | — |
| `pdigidben` | `INTEGER` | — | — |
| `pfechalimpago` | `CHAR(16)` | — | — |
| `pindbenef` | `CHAR(3)` | — | — |
| `ppagocomision` | `INTEGER` | — | — |
| `pcomision` | `MONEY(14,2)` | — | — |
| `pnumseriecert` | `CHAR(20)` | — | — |
| `pfolioplataforma` | `CHAR(20)` | — | — |
| `pchrfchmjc` | `CHAR(20)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cVarDataErr` | `CHAR(100)` | L84 |
| `vcodret` | `char(5)` | L85 |
| `vchrcodret` | `CHAR(5)` | L86 |
| `vchrcodret2` | `CHAR(5)` | L87 |
| `vcharcodret3` | `CHAR(50)` | L88 |
| `vintcodret` | `INTEGER` | L89 |
| `vintcodret2` | `INTEGER` | L90 |
| `vchrcodret3` | `CHAR(50)` | L91 |
| `vchrCveRastreo` | `CHAR(30)` | L92 |
| `vintPermiteCta11` | `INTEGER` | L93 |
| `vchrFuente` | `CHAR(7)` | L94 |
| `vchrTranscargo` | `CHAR(4)` | L95 |
| `vchrComis` | `CHAR(4)` | L96 |
| `vchrIvaComis` | `CHAR(4)` | L97 |
| `vchrtranret` | `CHAR(4)` | L98 |
| `dteFechacargo` | `DATE` | L99 |
| `vmnySdoDisp` | `MONEY(14,2)` | L100 |
| `vmnyMontoRet` | `MONEY(14,2)` | L101 |
| `vchrTarjeta` | `CHAR(20)` | L102 |
| `vtransaccion` | `INTEGER` | L103 |
| `vchrparametro` | `VARCHAR(255)` | L104 |
| `vchrFechaValor` | `VARCHAR(10)` | L105 |
| `dIva` | `DECIMAL(5,3)` | L106 |
| `vmnyMontoLibre` | `MONEY(14,2)` | L107 |
| `vdigitoverifica` | `SMALLINT` | L108 |
| *…55 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tblparametros` | `bdispei` | no | SELECT | L257 |
| `sc_fechas` | `bdicheq` | ⚠️ sí | SELECT | L315 |
| `sc_tarjeta` | `bdicheq` | ⚠️ sí | SELECT | L421 |
| `sc_maechq` | `bdicheq` | ⚠️ sí | SELECT | L442 |
| `sc_cuenta_telefono` | `bdicheq` | ⚠️ sí | SELECT | L520 |
| `tf_maecte` | `bditransfer` | ⚠️ sí | SELECT | L526 |
| `si_param` | `bdinteg` | ⚠️ sí | SELECT | L638 |
| `si_sucursales` | `bdinteg` | ⚠️ sí | SELECT | L689 |
| `si_ejecut` | `bdinteg` | ⚠️ sí | SELECT | L708 |
| `tbltipopago` | `bdispei` | no | SELECT | L727 |
| `tbltipooperacion` | `bdispei` | no | SELECT | L752 |
| `tblbanco` | `bdispei` | no | SELECT | L790 |
| `tblpago` | `bdispei` | no | SELECT | L826 |
| `si_transacc` | `bdinteg` | ⚠️ sí | SELECT | L926 |
| `tbldetranpago` | `bdispei` | no | INSERT | L1020 |
| `tblpago` | `bdispei` | no | INSERT | L1254 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `spei_recerrorescodi` | `bdispei` | no | L268 |
| `sp_validaspei_bpi` | `bdispei` | no | L370 |
| `spei_validaoperacion` | `bdispei` | no | L401 |
| `sp_validadv` | `bdispei` | no | L563 |
| `sp_obtsigfolioop` | `bdispei` | no | L945 |
| `digver11` | `bdicheq` | ⚠️ sí | L948 |
| `cargo_ref` | `bdicheq` | ⚠️ sí | L992 |
| `sp_validafecha` | `bdispei` | no | L1110 |
| `sp_quitar_acentos` | `bdinteg` | ⚠️ sí | L1127 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L260 | FÓRMULA | `LET intBancoOrd = (vchrparametro * 1);` |  |
| L262 | VALIDACIÓN_NULL | `IF vchrparametro IS NULL THEN` |  |
| L266 | FÓRMULA | `LET vtimestamp  = dbinfo('utc_current') * 1000;` |  |
| L276 | VALIDACIÓN_NULL | `IF pvchrNombreOrd IS NULL OR pvchrNombreOrd = '' OR` |  |
| L285 | FÓRMULA | `LET vtimestamp  = dbinfo('utc_current') * 1000;` |  |
| L295 | VALIDACIÓN_NULL | `IF pvchrNombreBenef IS NULL OR pvchrNombreBenef = '' OR` |  |
| L301 | FÓRMULA | `LET vtimestamp  = dbinfo('utc_current') * 1000;` |  |
| L323 | FÓRMULA | `LET vtimestamp  = dbinfo('utc_current') * 1000;` |  |
| L340 | VALIDACIÓN_NULL | `IF vchrparametro IS NULL THEN` |  |
| L343 | FÓRMULA | `LET vtimestamp  = dbinfo('utc_current') * 1000;` |  |
| L356 | FÓRMULA | `LET vtimestamp  = dbinfo('utc_current') * 1000;` |  |
| L374 | FÓRMULA | `LET vtimestamp  = dbinfo('utc_current') * 1000;` |  |
| L387 | VALIDACIÓN_NULL | `IF (pdtfechacaptura is null) OR (pdtfechacaptura = '') then` |  |
| L390 | FÓRMULA | `LET vtimestamp  = dbinfo('utc_current') * 1000;` |  |
| L407 | FÓRMULA | `LET vtimestamp  = dbinfo('utc_current') * 1000;` |  |
| L426 | VALIDACIÓN_NULL | `IF (vchrTarjeta is null) OR (vchrTarjeta = '') THEN` |  |
| L429 | FÓRMULA | `LET vtimestamp  = dbinfo('utc_current') * 1000;` |  |
| L447 | VALIDACIÓN_NULL | `IF pvchrCuentaOrd IS NULL OR pvchrCuentaOrd = '' THEN` |  |
| L450 | FÓRMULA | `LET vtimestamp  = dbinfo('utc_current') * 1000;` |  |
| L472 | VALIDACIÓN_NULL | `IF vchrCtaOrdClabe IS NULL THEN` |  |
| L475 | FÓRMULA | `LET vtimestamp  = dbinfo('utc_current') * 1000;` |  |
| L491 | FÓRMULA | `LET vtimestamp  = dbinfo('utc_current') * 1000;` |  |
| L503 | FÓRMULA | `LET vtimestamp  = dbinfo('utc_current') * 1000;` |  |
| L523 | VALIDACIÓN_NULL | `IF pvchrCuentaOrd is null OR pvchrCuentaOrd = '' THEN` |  |
| L543 | VALIDACIÓN_NULL | `IF vchrTelefono is null OR vchrTelefono = '' OR pvchrCuentaOrd is null OR pvchrCuentaOrd = '' THEN` |  |
| L546 | FÓRMULA | `LET vtimestamp  = dbinfo('utc_current') * 1000;` |  |
| L569 | FÓRMULA | `LET vtimestamp  = dbinfo('utc_current') * 1000;` |  |
| L581 | FÓRMULA | `LET vtimestamp  = dbinfo('utc_current') * 1000;` |  |
| L598 | FÓRMULA | `LET vtimestamp  = dbinfo('utc_current') * 1000;` |  |
| L642 | VALIDACIÓN_NULL | `IF dIva IS NULL THEN` |  |
| | *…28 más…* | | |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `regordenctecte` | ACCION | Regresa Orden Cuenta a Cuenta — operación de transferencia/o | 🟡 INFERIDO | nombre_sp |
| `bex` | ENTIDAD | BEX — canal o plataforma de Banca Por Internet (bdibpi); ges | 🟡 INFERIDO | nombre_sp |
| `codi` | REG | CoDi — Cobro Digital (Banxico) | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `exp` | MODIF | sufijo Exportar — SP genera/exporta archivo de salida (sp_*_ | 🟡 INFERIDO | nombre_sp |
| `?1` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?1` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_regordenctecte_bex_exp1`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_sp_regordenctecte_bex_exp1.sql` |
| **LOC (1er CREATE)** | 903 |
| **Callgraph** | ✅ fan_in=0 / fan_out=9 |
| **Propósito inferido** | "Regresa Orden Cuenta a Cuenta — operación de transferencia/orden entre cuentas propias del cliente BEX — canal o plataforma de Banca Por Internet (sufijo Exportar — SP genera/exporta archivo de salida)" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `genera` → `INSERT` encontrado en el cuerpo · `genera` → `SELECT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=1 · INFERIDO=3 · SINTÉTICO=1 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_regordenctecte_bex_exp1(
  pEmpresa                     CHAR(3)
  pchrSucursal                 CHAR(4)
  pchrUsuario                  CHAR(8)
  pintBancoDest                INTEGER
  pmnyImporte                  MONEY(14,2)
  pchrTransuc                  CHAR(4)
  pchrFolioSuc                 CHAR(16)
  pdtfechacaptura              DATE
  pmnyComision                 MONEY(14,2)
  pmnyIvaComis                 MONEY(14,2)
  pvchrNombreOrd               VARCHAR(40)
  pintTipoCtaOrd               INTEGER
  pvchrCuentaOrd               VARCHAR(20)
  pvchrRfcOrd                  VARCHAR(18)
  pvchrNombreBenef             VARCHAR(40)
  pintTipoCtaBenef             INTEGER
  pvchrCtaBenef                VARCHAR(20)
  pvchrRFCBenef                VARCHAR(18)
  pvchrConceptoPago            VARCHAR(40)
  pmnyIVA                      MONEY(14,2)
  pdecRefNum                   DECIMAL(7,0)
  pvchrRefCobranza1            VARCHAR(40)
) RETURNING CHAR(5), CHAR(30)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pEmpresa` | `CHAR(3)` | — | — |
| `pchrSucursal` | `CHAR(4)` | — | — |
| `pchrUsuario` | `CHAR(8)` | — | — |
| `pintBancoDest` | `INTEGER` | — | — |
| `pmnyImporte` | `MONEY(14,2)` | — | — |
| `pchrTransuc` | `CHAR(4)` | — | — |
| `pchrFolioSuc` | `CHAR(16)` | — | — |
| `pdtfechacaptura` | `DATE` | — | — |
| `pmnyComision` | `MONEY(14,2)` | — | — |
| `pmnyIvaComis` | `MONEY(14,2)` | — | — |
| `pvchrNombreOrd` | `VARCHAR(40)` | — | — |
| `pintTipoCtaOrd` | `INTEGER` | — | — |
| `pvchrCuentaOrd` | `VARCHAR(20)` | — | — |
| `pvchrRfcOrd` | `VARCHAR(18)` | — | — |
| `pvchrNombreBenef` | `VARCHAR(40)` | — | — |
| `pintTipoCtaBenef` | `INTEGER` | — | — |
| `pvchrCtaBenef` | `VARCHAR(20)` | — | — |
| `pvchrRFCBenef` | `VARCHAR(18)` | — | — |
| `pvchrConceptoPago` | `VARCHAR(40)` | — | — |
| `pmnyIVA` | `MONEY(14,2)` | — | — |
| `pdecRefNum` | `DECIMAL(7,0)` | — | — |
| `pvchrRefCobranza1` | `VARCHAR(40)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cVarDataErr` | `CHAR(100)` | L62 |
| `vchrcodret` | `CHAR(5)` | L63 |
| `vchrcodret2` | `CHAR(5)` | L64 |
| `vcharcodret3` | `CHAR(50)` | L65 |
| `vintcodret` | `INTEGER` | L66 |
| `vintcodret2` | `INTEGER` | L67 |
| `vchrcodret3` | `CHAR(50)` | L68 |
| `vchrCveRastreo` | `CHAR(30)` | L69 |
| `vintPermiteCta11` | `INTEGER` | L70 |
| `vchrFuente` | `CHAR(7)` | L71 |
| `vchrTranscargo` | `CHAR(4)` | L72 |
| `vchrComis` | `CHAR(4)` | L73 |
| `vchrIvaComis` | `CHAR(4)` | L74 |
| `vchrtranret` | `CHAR(4)` | L75 |
| `dteFechacargo` | `DATE` | L76 |
| `vmnySdoDisp` | `MONEY(14,2)` | L77 |
| `vmnyMontoRet` | `MONEY(14,2)` | L78 |
| `vchrTarjeta` | `CHAR(20)` | L79 |
| `vtransaccion` | `INTEGER` | L80 |
| `vchrparametro` | `VARCHAR(255)` | L81 |
| `vchrFechaValor` | `VARCHAR(10)` | L82 |
| `dIva` | `DECIMAL(5,3)` | L83 |
| `vmnyMontoLibre` | `MONEY(14,2)` | L84 |
| `vdigitoverifica` | `SMALLINT` | L85 |
| `vexiste_suc` | `CHAR(4)` | L86 |
| *…38 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sc_fechas` | `bdicheq` | ⚠️ sí | SELECT | L219 |
| `tblparametros` | `bdispei` | no | SELECT | L234 |
| `sc_tarjeta` | `bdicheq` | ⚠️ sí | SELECT | L283 |
| `sc_maechq` | `bdicheq` | ⚠️ sí | SELECT | L297 |
| `sc_cuenta_telefono` | `bdicheq` | ⚠️ sí | SELECT | L347 |
| `tf_maecte` | `bditransfer` | ⚠️ sí | SELECT | L353 |
| `si_param` | `bdinteg` | ⚠️ sí | SELECT | L410 |
| `si_sucursales` | `bdinteg` | ⚠️ sí | SELECT | L460 |
| `si_ejecut` | `bdinteg` | ⚠️ sí | SELECT | L472 |
| `tbltipopago` | `bdispei` | no | SELECT | L484 |
| `tbltipooperacion` | `bdispei` | no | SELECT | L502 |
| `tblbanco` | `bdispei` | no | SELECT | L527 |
| `tblpago` | `bdispei` | no | SELECT | L549 |
| `si_transacc` | `bdinteg` | ⚠️ sí | SELECT | L619 |
| `tbldetranpago` | `bdispei` | no | INSERT | L696 |
| `tblpago` | `bdispei` | no | INSERT | L880 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_validaspei_bpi` | `bdispei` | no | L253 |
| `spei_validaoperacion` | `bdispei` | no | L270 |
| `sp_validadv` | `bdispei` | no | L383 |
| `sp_obtsigfolioop` | `bdispei` | no | L643 |
| `digver11` | `bdicheq` | ⚠️ sí | L646 |
| `cargo_ref` | `bdicheq` | ⚠️ sí | L679 |
| `sp_validafecha` | `bdispei` | no | L772 |
| `sp_quitar_acentos` | `bdinteg` | ⚠️ sí | L789 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L200 | VALIDACIÓN_NULL | `IF pvchrNombreOrd IS NULL OR pvchrNombreOrd = '' OR` |  |
| L237 | VALIDACIÓN_NULL | `IF vchrparametro IS NULL THEN` |  |
| L263 | VALIDACIÓN_NULL | `IF (pdtfechacaptura is null) OR (pdtfechacaptura = '') then` |  |
| L288 | VALIDACIÓN_NULL | `IF (vchrTarjeta is null) OR (vchrTarjeta = '') THEN` |  |
| L302 | VALIDACIÓN_NULL | `IF pvchrCuentaOrd IS NULL OR pvchrCuentaOrd = '' THEN` |  |
| L320 | VALIDACIÓN_NULL | `IF vchrCtaOrdClabe IS NULL THEN` |  |
| L350 | VALIDACIÓN_NULL | `IF pvchrCuentaOrd is null OR pvchrCuentaOrd = '' THEN` |  |
| L370 | VALIDACIÓN_NULL | `IF vchrTelefono is null OR vchrTelefono = '' OR pvchrCuentaOrd is null OR pvchrCuentaOrd = '' THEN` |  |
| L414 | VALIDACIÓN_NULL | `IF dIva IS NULL THEN` |  |
| L426 | FÓRMULA | `LET vchrFechaValor = SUBSTR(vchrFechaVal,4,2) \|\| '/' \|\| SUBSTR(vchrFechaVal,1,2) \|\| '/' \|\| S` |  |
| L435 | VALIDACIÓN_NULL | `IF vchrparametro IS NULL THEN` |  |
| L449 | VALIDACIÓN_NULL | `IF vchrparametro IS NULL THEN` |  |
| L455 | FÓRMULA | `LET intBancoOrd = (vchrparametro * 1);` |  |
| L532 | VALIDACIÓN_NULL | `IF vintCveCesif IS NULL THEN` |  |
| L566 | VALIDACIÓN_NULL | `IF vchrTranscargo IS NULL OR vchrTranscargo = '' THEN` |  |
| L583 | VALIDACIÓN_NULL | `IF vchrComis IS NULL OR vchrCOmis = '' THEN` |  |
| L594 | VALIDACIÓN_NULL | `IF vchrIvaComis IS NULL OR vchrIvaComis = '' THEN` |  |
| L615 | VALIDACIÓN_NULL | `IF vexiste_suc is null OR vexiste_suc = '' THEN` |  |
| L673 | VALIDACIÓN_NULL | `IF pdecRefNum IS NULL or pdecRefNum = 0 THEN` |  |
| L674 | FÓRMULA | `LET pdecRefNum = SUBSTR(LPAD(intpktblpago, 12, '0'), -7);` |  |
| L775 | FÓRMULA | `LET vchrFechaValor = to_char(vfechaHabil, '%m/%d/%Y');` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `regordenctecte` | ACCION | Regresa Orden Cuenta a Cuenta — operación de transferencia/o | 🟡 INFERIDO | nombre_sp |
| `bex` | ENTIDAD | BEX — canal o plataforma de Banca Por Internet (bdibpi); ges | 🟡 INFERIDO | nombre_sp |
| `exp` | MODIF | sufijo Exportar — SP genera/exporta archivo de salida (sp_*_ | 🟡 INFERIDO | nombre_sp |
| `?1` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?1` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_regordenctecte_exp1`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_sp_regordenctecte_exp1.sql` |
| **LOC (1er CREATE)** | 774 |
| **Callgraph** | ✅ fan_in=0 / fan_out=6 |
| **Propósito inferido** | "Regresa Orden Cuenta a Cuenta — operación de transferencia/orden entre cuentas propias del cliente (sufijo Exportar — SP genera/exporta archivo de salida)" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `genera` → `INSERT` encontrado en el cuerpo · `genera` → `SELECT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=1 · INFERIDO=2 · SINTÉTICO=1 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_regordenctecte_exp1(
  pEmpresa                     CHAR(3)
) RETURNING CHAR(5), char(100), CHAR(30)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pEmpresa` | `CHAR(3)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cVarDataErr` | `CHAR(100)` | L25 |
| `vchrcodret` | `CHAR(5)` | L26 |
| `vintcodret` | `INTEGER` | L27 |
| `vchrCveRastreo` | `CHAR(30)` | L28 |
| `vintPermiteCta11` | `INTEGER` | L29 |
| `vchrFuente` | `CHAR(7)` | L30 |
| `vchrTranscargo` | `CHAR(4)` | L31 |
| `vchrComis` | `CHAR(4)` | L32 |
| `vchrIvaComis` | `CHAR(4)` | L33 |
| `vchrtranret` | `CHAR(4)` | L34 |
| `dteFechacargo` | `DATE` | L35 |
| `vmnySdoDisp` | `MONEY(14,2)` | L36 |
| `vmnyMontoRet` | `MONEY(14,2)` | L37 |
| `vchrTarjeta` | `CHAR(20)` | L38 |
| `vtransaccion` | `INTEGER` | L39 |
| `vchrparametro` | `VARCHAR(255)` | L40 |
| `vchrFechaValor` | `VARCHAR(10)` | L41 |
| `dIva` | `DECIMAL(5,3)` | L42 |
| `vmnyMontoLibre` | `MONEY(14,2)` | L43 |
| `vdigitoverifica` | `SMALLINT` | L44 |
| `vexiste_cta` | `CHAR(20)` | L45 |
| `vexiste_suc` | `CHAR(4)` | L46 |
| `vchrCtaOrdClabe` | `VARCHAR(20)` | L47 |
| `vchrCtaOrdtblp` | `VARCHAR(20)` | L48 |
| `vchrTelefono` | `CHAR(10)` | L49 |
| *…33 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sc_fechas` | `bdicheq` | ⚠️ sí | SELECT | L162 |
| `sc_tarjeta` | `bdicheq` | ⚠️ sí | SELECT | L189 |
| `sc_maechq` | `bdicheq` | ⚠️ sí | SELECT | L203 |
| `tf_maecte` | `bditransfer` | ⚠️ sí | SELECT | L214 |
| `si_param` | `bdinteg` | ⚠️ sí | SELECT | L241 |
| `tblparametros` | `bdispei` | no | SELECT | L254 |
| `sc_cuenta_telefono` | `bdicheq` | ⚠️ sí | SELECT | L328 |
| `si_sucursales` | `bdinteg` | ⚠️ sí | SELECT | L490 |
| `si_transacc` | `bdinteg` | ⚠️ sí | SELECT | L502 |
| `tbldetranpago` | `bdispei` | no | INSERT | L551 |
| `sc_movdia` | `bdicheq` | ⚠️ sí | SELECT | L628 |
| `tblpago` | `bdispei` | no | INSERT | L745 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_validaspei_bpi` | `bdispei` | no | L176 |
| `sp_validadv` | `bdispei` | no | L366 |
| `sp_regordenpagospei` | `bdispei` | no | L447 |
| `cargo_ref` | `bdicheq` | ⚠️ sí | L521 |
| `sp_validafecha` | `bdispei` | no | L647 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L194 | VALIDACIÓN_NULL | `IF (vchrTarjeta is null) OR (vchrTarjeta = '') then` |  |
| L223 | VALIDACIÓN_NULL | `IF pvchrCuentaOrd IS NULL OR pvchrCuentaOrd = '' THEN` |  |
| L232 | VALIDACIÓN_NULL | `IF (pdtfechacaptura is null) or (pdtfechacaptura = '') then` |  |
| L245 | VALIDACIÓN_NULL | `IF dIva IS NULL THEN` |  |
| L257 | VALIDACIÓN_NULL | `IF vchrparametro IS NULL THEN` |  |
| L264 | FÓRMULA | `LET vchrFechaValor = SUBSTR(TRIM(vchrparametro),4,2) \|\| '/' \|\| SUBSTR(TRIM(vchrparametro),0,2) \` |  |
| L281 | VALIDACIÓN_NULL | `IF vchrCtaOrdClabe IS NULL THEN` |  |
| L312 | VALIDACIÓN_NULL | `IF vexiste_cta is null OR vexiste_cta = '' THEN` |  |
| L341 | VALIDACIÓN_NULL | `IF vexiste_cta is null OR vexiste_cta = '' THEN` |  |
| L354 | VALIDACIÓN_NULL | `IF pvchrCuentaOrd is null OR pvchrCuentaOrd = '' THEN` |  |
| L385 | VALIDACIÓN_NULL | `IF pvchrCuentaBenef is null OR pvchrCuentaBenef = '' THEN` |  |
| L404 | VALIDACIÓN_NULL | `IF vchrTranscargo IS NULL OR vchrTranscargo = '' THEN` |  |
| L416 | VALIDACIÓN_NULL | `IF vchrComis IS NULL OR vchrCOmis = '' THEN` |  |
| L427 | VALIDACIÓN_NULL | `IF vchrIvaComis IS NULL OR vchrIvaComis = '' THEN` |  |
| L498 | VALIDACIÓN_NULL | `IF vexiste_suc is null OR vexiste_suc = '' THEN` |  |
| L650 | FÓRMULA | `LET vchrFechaValor = to_char(vfechaHabil, '%m/%d/%Y');` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `regordenctecte` | ACCION | Regresa Orden Cuenta a Cuenta — operación de transferencia/o | 🟡 INFERIDO | nombre_sp |
| `exp` | MODIF | sufijo Exportar — SP genera/exporta archivo de salida (sp_*_ | 🟡 INFERIDO | nombre_sp |
| `?1` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?1` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_regordenctecte_pba`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_sp_regordenctecte_pba.sql` |
| **LOC (1er CREATE)** | 630 |
| **Callgraph** | ✅ fan_in=0 / fan_out=5 |
| **Propósito inferido** | "Regresa Orden Cuenta a Cuenta — operación de transferencia/orden entre cuentas propias del cliente (PBA — sufijo de SPs para Pruebas; confirmado por SME)" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `confirma` → `SELECT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=2 · INFERIDO=1 · SINTÉTICO=0 / 3 términos |

### Firma

```sql
CREATE PROCEDURE sp_regordenctecte_pba(
  pEmpresa                     CHAR(3)
) RETURNING CHAR(5), char(100), CHAR(30)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pEmpresa` | `CHAR(3)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cVarDataErr` | `CHAR(100)` | L25 |
| `vchrcodret` | `CHAR(5)` | L26 |
| `vintcodret` | `INTEGER` | L27 |
| `vchrCveRastreo` | `CHAR(30)` | L28 |
| `vintPermiteCta11` | `INTEGER` | L29 |
| `vchrFuente` | `CHAR(7)` | L30 |
| `vchrTranscargo` | `CHAR(4)` | L31 |
| `vchrComis` | `CHAR(4)` | L32 |
| `vchrIvaComis` | `CHAR(4)` | L33 |
| `vchrtranret` | `CHAR(4)` | L34 |
| `dteFechacargo` | `DATE` | L35 |
| `vmnySdoDisp` | `MONEY(14,2)` | L36 |
| `vmnyMontoRet` | `MONEY(14,2)` | L37 |
| `vchrTarjeta` | `CHAR(20)` | L38 |
| `vtransaccion` | `INTEGER` | L39 |
| `vchrparametro` | `VARCHAR(255)` | L40 |
| `vchrFechaValor` | `VARCHAR(10)` | L41 |
| `dIva` | `DECIMAL(5,3)` | L42 |
| `vmnyMontoLibre` | `MONEY(14,2)` | L43 |
| `vdigitoverifica` | `SMALLINT` | L44 |
| `vexiste_cta` | `CHAR(20)` | L45 |
| `vexiste_suc` | `CHAR(4)` | L46 |
| `vchrCtaOrdClabe` | `VARCHAR(20)` | L47 |
| `vchrCtaOrdtblp` | `VARCHAR(20)` | L48 |
| `vchrTelefono` | `CHAR(10)` | L49 |
| *…15 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sc_fechas` | `bdicheq` | ⚠️ sí | SELECT | L124 |
| `sc_tarjeta` | `bdicheq` | ⚠️ sí | SELECT | L149 |
| `sc_maechq` | `bdicheq` | ⚠️ sí | SELECT | L163 |
| `tf_maecte` | `bditransfer` | ⚠️ sí | SELECT | L174 |
| `si_param` | `bdinteg` | ⚠️ sí | SELECT | L201 |
| `tblparametros` | `bdispei` | no | SELECT | L214 |
| `sc_cuenta_telefono` | `bdicheq` | ⚠️ sí | SELECT | L287 |
| `si_sucursales` | `bdinteg` | ⚠️ sí | SELECT | L449 |
| `si_transacc` | `bdinteg` | ⚠️ sí | SELECT | L461 |
| `tbldetranpago` | `bdispei` | no | INSERT | L510 |
| `sc_movdia` | `bdicheq` | ⚠️ sí | SELECT | L587 |
| `tblpago` | `bdispei` | no | INSERT | L606 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_validaspei_bpi` | `bdispei` | no | L136 |
| `sp_validadv` | `bdispei` | no | L325 |
| `sp_regordenpagospei_pba` | `bdispei` | no | L406 |
| `cargo_ref` | `bdicheq` | ⚠️ sí | L480 |
| `sp_validafecha` | `bdispei` | no | L599 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L154 | VALIDACIÓN_NULL | `IF (vchrTarjeta is null) OR (vchrTarjeta = '') then` |  |
| L183 | VALIDACIÓN_NULL | `IF pvchrCuentaOrd IS NULL OR pvchrCuentaOrd = '' THEN` |  |
| L192 | VALIDACIÓN_NULL | `IF (pdtfechacaptura is null) or (pdtfechacaptura = '') then` |  |
| L205 | VALIDACIÓN_NULL | `IF dIva IS NULL THEN` |  |
| L217 | VALIDACIÓN_NULL | `IF vchrparametro IS NULL THEN` |  |
| L224 | FÓRMULA | `LET vchrFechaValor = SUBSTR(TRIM(vchrparametro),4,2) \|\| '/' \|\| SUBSTR(TRIM(vchrparametro),0,2) \` |  |
| L240 | VALIDACIÓN_NULL | `IF vchrCtaOrdClabe IS NULL THEN` |  |
| L271 | VALIDACIÓN_NULL | `IF vexiste_cta is null OR vexiste_cta = '' THEN` |  |
| L300 | VALIDACIÓN_NULL | `IF vexiste_cta is null OR vexiste_cta = '' THEN` |  |
| L313 | VALIDACIÓN_NULL | `IF pvchrCuentaOrd is null OR pvchrCuentaOrd = '' THEN` |  |
| L344 | VALIDACIÓN_NULL | `IF pvchrCuentaBenef is null OR pvchrCuentaBenef = '' THEN` |  |
| L363 | VALIDACIÓN_NULL | `IF vchrTranscargo IS NULL OR vchrTranscargo = '' THEN` |  |
| L375 | VALIDACIÓN_NULL | `IF vchrComis IS NULL OR vchrCOmis = '' THEN` |  |
| L386 | VALIDACIÓN_NULL | `IF vchrIvaComis IS NULL OR vchrIvaComis = '' THEN` |  |
| L457 | VALIDACIÓN_NULL | `IF vexiste_suc is null OR vexiste_suc = '' THEN` |  |
| L601 | FÓRMULA | `LET vchrFechaValor = to_char(vfechaHabil, '%m/%d/%Y');` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `regordenctecte` | ACCION | Regresa Orden Cuenta a Cuenta — operación de transferencia/o | 🟡 INFERIDO | nombre_sp |
| `pba` | MODIF | PBA — sufijo de SPs para Pruebas; confirmado por SME (Guerra | 🔵 CONVENCIÓN | nombre_sp |

---

## `sp_regordenctecte_pp`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_sp_regordenctecte_pp.sql` |
| **LOC (1er CREATE)** | 1009 |
| **Callgraph** | ✅ fan_in=9 / fan_out=7 |
| **Propósito inferido** | "Regresa Orden Cuenta a Cuenta — operación de transferencia/orden entre cuentas propias del cliente (PP — Persona a Persona o Pago Programado)" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 7 llamada(s): `sp_validaspei_bpi`, `spei_validaoperacion`, `sp_validadv` |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=1 · INFERIDO=1 · SINTÉTICO=1 / 3 términos |

### Firma

```sql
CREATE PROCEDURE sp_regordenctecte_pp(
  pEmpresa                     CHAR(3)
  pchrSucursal                 CHAR(4)
  pchrUsuario                  CHAR(8)
  pintBancoDest                INTEGER
  pmnyImporte                  MONEY(14,2)
  pchrTransuc                  CHAR(4)
  pchrFolioSuc                 CHAR(16)
  pdtfechacaptura              DATE
  pmnyComision                 MONEY(14,2)
  pmnyIvaComis                 MONEY(14,2)
  pvchrNombreOrd               VARCHAR(40)
  pintTipoCtaOrd               INTEGER
  pvchrCuentaOrd               VARCHAR(20)
  pvchrRfcOrd                  VARCHAR(18)
  pvchrNombreBenef             VARCHAR(40)
  pintTipoCtaBenef             INTEGER
  pvchrCtaBenef                VARCHAR(20)
  pvchrRFCBenef                VARCHAR(18)
  pvchrConceptoPago            VARCHAR(40)
  pmnyIVA                      MONEY(14,2)
  pdecRefNum                   DECIMAL(7,0)
  pvchrRefCobranza1            VARCHAR(40)
) RETURNING CHAR(5), CHAR(100), CHAR(30)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pEmpresa` | `CHAR(3)` | — | — |
| `pchrSucursal` | `CHAR(4)` | — | — |
| `pchrUsuario` | `CHAR(8)` | — | — |
| `pintBancoDest` | `INTEGER` | — | — |
| `pmnyImporte` | `MONEY(14,2)` | — | — |
| `pchrTransuc` | `CHAR(4)` | — | — |
| `pchrFolioSuc` | `CHAR(16)` | — | — |
| `pdtfechacaptura` | `DATE` | — | — |
| `pmnyComision` | `MONEY(14,2)` | — | — |
| `pmnyIvaComis` | `MONEY(14,2)` | — | — |
| `pvchrNombreOrd` | `VARCHAR(40)` | — | — |
| `pintTipoCtaOrd` | `INTEGER` | — | — |
| `pvchrCuentaOrd` | `VARCHAR(20)` | — | — |
| `pvchrRfcOrd` | `VARCHAR(18)` | — | — |
| `pvchrNombreBenef` | `VARCHAR(40)` | — | — |
| `pintTipoCtaBenef` | `INTEGER` | — | — |
| `pvchrCtaBenef` | `VARCHAR(20)` | — | — |
| `pvchrRFCBenef` | `VARCHAR(18)` | — | — |
| `pvchrConceptoPago` | `VARCHAR(40)` | — | — |
| `pmnyIVA` | `MONEY(14,2)` | — | — |
| `pdecRefNum` | `DECIMAL(7,0)` | — | — |
| `pvchrRefCobranza1` | `VARCHAR(40)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cVarDataErr` | `CHAR(100)` | L62 |
| `vchrcodret` | `CHAR(5)` | L63 |
| `vchrcodret2` | `CHAR(5)` | L64 |
| `vcharcodret3` | `CHAR(50)` | L65 |
| `vintcodret` | `INTEGER` | L66 |
| `vintcodret2` | `INTEGER` | L67 |
| `vchrcodret3` | `CHAR(50)` | L68 |
| `vchrCveRastreo` | `CHAR(30)` | L69 |
| `vintPermiteCta11` | `INTEGER` | L70 |
| `vchrFuente` | `CHAR(7)` | L71 |
| `vchrTranscargo` | `CHAR(4)` | L72 |
| `vchrComis` | `CHAR(4)` | L73 |
| `vchrIvaComis` | `CHAR(4)` | L74 |
| `vchrtranret` | `CHAR(4)` | L75 |
| `dteFechacargo` | `DATE` | L76 |
| `vmnySdoDisp` | `MONEY(14,2)` | L77 |
| `vmnyMontoRet` | `MONEY(14,2)` | L78 |
| `vchrTarjeta` | `CHAR(20)` | L79 |
| `vtransaccion` | `INTEGER` | L80 |
| `vchrparametro` | `VARCHAR(255)` | L81 |
| `vchrFechaValor` | `VARCHAR(10)` | L82 |
| `dIva` | `DECIMAL(5,3)` | L83 |
| `vmnyMontoLibre` | `MONEY(14,2)` | L84 |
| `vdigitoverifica` | `SMALLINT` | L85 |
| `vexiste_suc` | `CHAR(4)` | L86 |
| *…37 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sc_fechas` | `bdicheq` | ⚠️ sí | SELECT | L220 |
| `tblparametros` | `bdispei` | no | SELECT | L236 |
| `sc_tarjeta` | `bdicheq` | ⚠️ sí | SELECT | L284 |
| `sc_maechq` | `bdicheq` | ⚠️ sí | SELECT | L298 |
| `tf_maecte` | `bditransfer` | ⚠️ sí | SELECT | L304 |
| `sc_cuenta_telefono` | `bdicheq` | ⚠️ sí | SELECT | L360 |
| `si_param` | `bdinteg` | ⚠️ sí | SELECT | L425 |
| `si_sucursales` | `bdinteg` | ⚠️ sí | SELECT | L475 |
| `si_ejecut` | `bdinteg` | ⚠️ sí | SELECT | L487 |
| `tbltipopago` | `bdispei` | no | SELECT | L499 |
| `tbltipooperacion` | `bdispei` | no | SELECT | L517 |
| `tblbanco` | `bdispei` | no | SELECT | L542 |
| `tblpago` | `bdispei` | no | SELECT | L564 |
| `si_transacc` | `bdinteg` | ⚠️ sí | SELECT | L634 |
| `sc_param` | `bdicheq` | ⚠️ sí | SELECT | L654 |
| `tbldetranpago` | `bdispei` | no | INSERT | L711 |
| `sc_movdia` | `bdicheq` | ⚠️ sí | INSERT | L718 |
| `tblpago` | `bdispei` | no | INSERT | L985 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_validaspei_bpi` | `bdispei` | no | L255 |
| `spei_validaoperacion` | `bdispei` | no | L271 |
| `sp_validadv` | `bdispei` | no | L398 |
| `sp_obtsigfolioop` | `bdispei` | no | L659 |
| `digver11` | `bdicheq` | ⚠️ sí | L662 |
| `cargo_ref` | `bdicheq` | ⚠️ sí | L694 |
| `sp_validafecha` | `bdispei` | no | L886 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L201 | VALIDACIÓN_NULL | `IF pvchrNombreOrd IS NULL OR pvchrNombreOrd = '' OR` |  |
| L239 | VALIDACIÓN_NULL | `IF vchrparametro IS NULL THEN` |  |
| L264 | VALIDACIÓN_NULL | `IF (pdtfechacaptura is null) OR (pdtfechacaptura = '') then` |  |
| L289 | VALIDACIÓN_NULL | `IF (vchrTarjeta is null) OR (vchrTarjeta = '') THEN` |  |
| L309 | VALIDACIÓN_NULL | `IF pvchrCuentaOrd IS NULL OR pvchrCuentaOrd = '' THEN` |  |
| L333 | VALIDACIÓN_NULL | `IF vchrCtaOrdClabe IS NULL THEN` |  |
| L363 | VALIDACIÓN_NULL | `IF pvchrCuentaOrd is null OR pvchrCuentaOrd = '' THEN` |  |
| L376 | VALIDACIÓN_NULL | `IF vchrTelefono is null OR vchrTelefono = '' THEN  -- busca en cuentas transfer` |  |
| L385 | VALIDACIÓN_NULL | `IF vchrTelefono is null OR vchrTelefono = '' OR pvchrCuentaOrd is null OR pvchrCuentaOrd = '' THEN` |  |
| L429 | VALIDACIÓN_NULL | `IF dIva IS NULL THEN` |  |
| L441 | FÓRMULA | `LET vchrFechaValor = SUBSTR(vchrFechaVal,4,2) \|\| '/' \|\| SUBSTR(vchrFechaVal,1,2) \|\| '/' \|\| S` |  |
| L450 | VALIDACIÓN_NULL | `IF vchrparametro IS NULL THEN` |  |
| L464 | VALIDACIÓN_NULL | `IF vchrparametro IS NULL THEN` |  |
| L470 | FÓRMULA | `LET intBancoOrd = (vchrparametro * 1);` |  |
| L547 | VALIDACIÓN_NULL | `IF vintCveCesif IS NULL THEN` |  |
| L581 | VALIDACIÓN_NULL | `IF vchrTranscargo IS NULL OR vchrTranscargo = '' THEN` |  |
| L598 | VALIDACIÓN_NULL | `IF vchrComis IS NULL OR vchrCOmis = '' THEN` |  |
| L609 | VALIDACIÓN_NULL | `IF vchrIvaComis IS NULL OR vchrIvaComis = '' THEN` |  |
| L630 | VALIDACIÓN_NULL | `IF vexiste_suc is null OR vexiste_suc = '' THEN` |  |
| L688 | VALIDACIÓN_NULL | `IF pdecRefNum IS NULL or pdecRefNum = 0 THEN` |  |
| L689 | FÓRMULA | `LET pdecRefNum = SUBSTR(LPAD(intpktblpago, 12, '0'), -7);` |  |
| L862 | VALIDACIÓN_NULL | `IF pdecRefNum IS NULL or pdecRefNum = 0 THEN` |  |
| L863 | FÓRMULA | `LET pdecRefNum = substr(LPAD(intpktblpago, 12, '0'), -7);` |  |
| L889 | FÓRMULA | `LET vchrFechaValor = to_char(vfechaHabil, '%m/%d/%Y');` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `regordenctecte` | ACCION | Regresa Orden Cuenta a Cuenta — operación de transferencia/o | 🟡 INFERIDO | nombre_sp |
| `pp` | MODIF | PP — Persona a Persona o Pago Programado (sp_regordenctecte_ | 🔴 SINTÉTICO | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `pp` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_regordenctecte_pp_exp1`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_sp_regordenctecte_pp_exp1.sql` |
| **LOC (1er CREATE)** | 1006 |
| **Callgraph** | ✅ fan_in=0 / fan_out=8 |
| **Propósito inferido** | "Regresa Orden Cuenta a Cuenta — operación de transferencia/orden entre cuentas propias del cliente (PP — Persona a Persona o Pago Programado, sufijo Exportar — SP genera/exporta archivo de salida)" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `genera` → `INSERT` encontrado en el cuerpo · `genera` → `SELECT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=1 · INFERIDO=2 · SINTÉTICO=2 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_regordenctecte_pp_exp1(
  pEmpresa                     CHAR(3)
  pchrSucursal                 CHAR(4)
  pchrUsuario                  CHAR(8)
  pintBancoDest                INTEGER
  pmnyImporte                  MONEY(14,2)
  pchrTransuc                  CHAR(4)
  pchrFolioSuc                 CHAR(16)
  pdtfechacaptura              DATE
  pmnyComision                 MONEY(14,2)
  pmnyIvaComis                 MONEY(14,2)
  pvchrNombreOrd               VARCHAR(40)
  pintTipoCtaOrd               INTEGER
  pvchrCuentaOrd               VARCHAR(20)
  pvchrRfcOrd                  VARCHAR(18)
  pvchrNombreBenef             VARCHAR(40)
  pintTipoCtaBenef             INTEGER
  pvchrCtaBenef                VARCHAR(20)
  pvchrRFCBenef                VARCHAR(18)
  pvchrConceptoPago            VARCHAR(40)
  pmnyIVA                      MONEY(14,2)
  pdecRefNum                   DECIMAL(7,0)
  pvchrRefCobranza1            VARCHAR(40)
) RETURNING CHAR(5), CHAR(100), CHAR(30)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pEmpresa` | `CHAR(3)` | — | — |
| `pchrSucursal` | `CHAR(4)` | — | — |
| `pchrUsuario` | `CHAR(8)` | — | — |
| `pintBancoDest` | `INTEGER` | — | — |
| `pmnyImporte` | `MONEY(14,2)` | — | — |
| `pchrTransuc` | `CHAR(4)` | — | — |
| `pchrFolioSuc` | `CHAR(16)` | — | — |
| `pdtfechacaptura` | `DATE` | — | — |
| `pmnyComision` | `MONEY(14,2)` | — | — |
| `pmnyIvaComis` | `MONEY(14,2)` | — | — |
| `pvchrNombreOrd` | `VARCHAR(40)` | — | — |
| `pintTipoCtaOrd` | `INTEGER` | — | — |
| `pvchrCuentaOrd` | `VARCHAR(20)` | — | — |
| `pvchrRfcOrd` | `VARCHAR(18)` | — | — |
| `pvchrNombreBenef` | `VARCHAR(40)` | — | — |
| `pintTipoCtaBenef` | `INTEGER` | — | — |
| `pvchrCtaBenef` | `VARCHAR(20)` | — | — |
| `pvchrRFCBenef` | `VARCHAR(18)` | — | — |
| `pvchrConceptoPago` | `VARCHAR(40)` | — | — |
| `pmnyIVA` | `MONEY(14,2)` | — | — |
| `pdecRefNum` | `DECIMAL(7,0)` | — | — |
| `pvchrRefCobranza1` | `VARCHAR(40)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cVarDataErr` | `CHAR(100)` | L62 |
| `vchrcodret` | `CHAR(5)` | L63 |
| `vchrcodret2` | `CHAR(5)` | L64 |
| `vcharcodret3` | `CHAR(50)` | L65 |
| `vintcodret` | `INTEGER` | L66 |
| `vintcodret2` | `INTEGER` | L67 |
| `vchrcodret3` | `CHAR(50)` | L68 |
| `vchrCveRastreo` | `CHAR(30)` | L69 |
| `vintPermiteCta11` | `INTEGER` | L70 |
| `vchrFuente` | `CHAR(7)` | L71 |
| `vchrTranscargo` | `CHAR(4)` | L72 |
| `vchrComis` | `CHAR(4)` | L73 |
| `vchrIvaComis` | `CHAR(4)` | L74 |
| `vchrtranret` | `CHAR(4)` | L75 |
| `dteFechacargo` | `DATE` | L76 |
| `vmnySdoDisp` | `MONEY(14,2)` | L77 |
| `vmnyMontoRet` | `MONEY(14,2)` | L78 |
| `vchrTarjeta` | `CHAR(20)` | L79 |
| `vtransaccion` | `INTEGER` | L80 |
| `vchrparametro` | `VARCHAR(255)` | L81 |
| `vchrFechaValor` | `VARCHAR(10)` | L82 |
| `dIva` | `DECIMAL(5,3)` | L83 |
| `vmnyMontoLibre` | `MONEY(14,2)` | L84 |
| `vdigitoverifica` | `SMALLINT` | L85 |
| `vexiste_suc` | `CHAR(4)` | L86 |
| *…37 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sc_fechas` | `bdicheq` | ⚠️ sí | SELECT | L220 |
| `tblparametros` | `bdispei` | no | SELECT | L236 |
| `sc_tarjeta` | `bdicheq` | ⚠️ sí | SELECT | L284 |
| `sc_maechq` | `bdicheq` | ⚠️ sí | SELECT | L298 |
| `tf_maecte` | `bditransfer` | ⚠️ sí | SELECT | L304 |
| `sc_cuenta_telefono` | `bdicheq` | ⚠️ sí | SELECT | L360 |
| `si_param` | `bdinteg` | ⚠️ sí | SELECT | L425 |
| `si_sucursales` | `bdinteg` | ⚠️ sí | SELECT | L475 |
| `si_ejecut` | `bdinteg` | ⚠️ sí | SELECT | L487 |
| `tbltipopago` | `bdispei` | no | SELECT | L499 |
| `tbltipooperacion` | `bdispei` | no | SELECT | L517 |
| `tblbanco` | `bdispei` | no | SELECT | L542 |
| `tblpago` | `bdispei` | no | SELECT | L564 |
| `si_transacc` | `bdinteg` | ⚠️ sí | SELECT | L634 |
| `sc_param` | `bdicheq` | ⚠️ sí | SELECT | L654 |
| `tbldetranpago` | `bdispei` | no | INSERT | L711 |
| `sc_movdia` | `bdicheq` | ⚠️ sí | INSERT | L718 |
| `tblpago` | `bdispei` | no | INSERT | L983 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_validaspei_bpi` | `bdispei` | no | L255 |
| `spei_validaoperacion` | `bdispei` | no | L271 |
| `sp_validadv` | `bdispei` | no | L398 |
| `sp_obtsigfolioop` | `bdispei` | no | L659 |
| `digver11` | `bdicheq` | ⚠️ sí | L662 |
| `cargo_ref` | `bdicheq` | ⚠️ sí | L694 |
| `sp_validafecha` | `bdispei` | no | L886 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L201 | VALIDACIÓN_NULL | `IF pvchrNombreOrd IS NULL OR pvchrNombreOrd = '' OR` |  |
| L239 | VALIDACIÓN_NULL | `IF vchrparametro IS NULL THEN` |  |
| L264 | VALIDACIÓN_NULL | `IF (pdtfechacaptura is null) OR (pdtfechacaptura = '') then` |  |
| L289 | VALIDACIÓN_NULL | `IF (vchrTarjeta is null) OR (vchrTarjeta = '') THEN` |  |
| L309 | VALIDACIÓN_NULL | `IF pvchrCuentaOrd IS NULL OR pvchrCuentaOrd = '' THEN` |  |
| L333 | VALIDACIÓN_NULL | `IF vchrCtaOrdClabe IS NULL THEN` |  |
| L363 | VALIDACIÓN_NULL | `IF pvchrCuentaOrd is null OR pvchrCuentaOrd = '' THEN` |  |
| L376 | VALIDACIÓN_NULL | `IF vchrTelefono is null OR vchrTelefono = '' THEN  -- busca en cuentas transfer` |  |
| L385 | VALIDACIÓN_NULL | `IF vchrTelefono is null OR vchrTelefono = '' OR pvchrCuentaOrd is null OR pvchrCuentaOrd = '' THEN` |  |
| L429 | VALIDACIÓN_NULL | `IF dIva IS NULL THEN` |  |
| L441 | FÓRMULA | `LET vchrFechaValor = SUBSTR(vchrFechaVal,4,2) \|\| '/' \|\| SUBSTR(vchrFechaVal,1,2) \|\| '/' \|\| S` |  |
| L450 | VALIDACIÓN_NULL | `IF vchrparametro IS NULL THEN` |  |
| L464 | VALIDACIÓN_NULL | `IF vchrparametro IS NULL THEN` |  |
| L470 | FÓRMULA | `LET intBancoOrd = (vchrparametro * 1);` |  |
| L547 | VALIDACIÓN_NULL | `IF vintCveCesif IS NULL THEN` |  |
| L581 | VALIDACIÓN_NULL | `IF vchrTranscargo IS NULL OR vchrTranscargo = '' THEN` |  |
| L598 | VALIDACIÓN_NULL | `IF vchrComis IS NULL OR vchrCOmis = '' THEN` |  |
| L609 | VALIDACIÓN_NULL | `IF vchrIvaComis IS NULL OR vchrIvaComis = '' THEN` |  |
| L630 | VALIDACIÓN_NULL | `IF vexiste_suc is null OR vexiste_suc = '' THEN` |  |
| L688 | VALIDACIÓN_NULL | `IF pdecRefNum IS NULL or pdecRefNum = 0 THEN` |  |
| L689 | FÓRMULA | `LET pdecRefNum = SUBSTR(LPAD(intpktblpago, 12, '0'), -7);` |  |
| L862 | VALIDACIÓN_NULL | `IF pdecRefNum IS NULL or pdecRefNum = 0 THEN` |  |
| L863 | FÓRMULA | `LET pdecRefNum = substr(LPAD(intpktblpago, 12, '0'), -7);` |  |
| L889 | FÓRMULA | `LET vchrFechaValor = to_char(vfechaHabil, '%m/%d/%Y');` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `regordenctecte` | ACCION | Regresa Orden Cuenta a Cuenta — operación de transferencia/o | 🟡 INFERIDO | nombre_sp |
| `pp` | MODIF | PP — Persona a Persona o Pago Programado (sp_regordenctecte_ | 🔴 SINTÉTICO | nombre_sp |
| `exp` | MODIF | sufijo Exportar — SP genera/exporta archivo de salida (sp_*_ | 🟡 INFERIDO | nombre_sp |
| `?1` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `pp`, `?1` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_regordenctecte_web`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_sp_regordenctecte_web.sql` |
| **LOC (1er CREATE)** | 774 |
| **Callgraph** | ✅ fan_in=0 / fan_out=5 |
| **Propósito inferido** | "Regresa Orden Cuenta a Cuenta — operación de transferencia/orden entre cuentas propias del cliente (canal web)" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 5 llamada(s): `sp_validaspei_bpi`, `sp_validadv`, `sp_regordenpagospei` |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=2 · INFERIDO=1 · SINTÉTICO=0 / 3 términos |

### Firma

```sql
CREATE PROCEDURE sp_regordenctecte_web(
  pEmpresa                     CHAR(3)
) RETURNING CHAR(5), CHAR(100), CHAR(30)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pEmpresa` | `CHAR(3)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cVarDataErr` | `CHAR(100)` | L25 |
| `vchrcodret` | `CHAR(5)` | L26 |
| `vintcodret` | `INTEGER` | L27 |
| `vchrCveRastreo` | `CHAR(30)` | L28 |
| `vintPermiteCta11` | `INTEGER` | L29 |
| `vchrFuente` | `CHAR(7)` | L30 |
| `vchrTranscargo` | `CHAR(4)` | L31 |
| `vchrComis` | `CHAR(4)` | L32 |
| `vchrIvaComis` | `CHAR(4)` | L33 |
| `vchrtranret` | `CHAR(4)` | L34 |
| `dteFechacargo` | `DATE` | L35 |
| `vmnySdoDisp` | `MONEY(14,2)` | L36 |
| `vmnyMontoRet` | `MONEY(14,2)` | L37 |
| `vchrTarjeta` | `CHAR(20)` | L38 |
| `vtransaccion` | `INTEGER` | L39 |
| `vchrparametro` | `VARCHAR(255)` | L40 |
| `vchrFechaValor` | `VARCHAR(10)` | L41 |
| `dIva` | `DECIMAL(5,3)` | L42 |
| `vmnyMontoLibre` | `MONEY(14,2)` | L43 |
| `vdigitoverifica` | `SMALLINT` | L44 |
| `vexiste_cta` | `CHAR(20)` | L45 |
| `vexiste_suc` | `CHAR(4)` | L46 |
| `vchrCtaOrdClabe` | `VARCHAR(20)` | L47 |
| `vchrCtaOrdtblp` | `VARCHAR(20)` | L48 |
| `vchrTelefono` | `CHAR(10)` | L49 |
| *…33 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sc_fechas` | `bdicheq` | ⚠️ sí | SELECT | L160 |
| `sc_tarjeta` | `bdicheq` | ⚠️ sí | SELECT | L187 |
| `sc_maechq` | `bdicheq` | ⚠️ sí | SELECT | L201 |
| `tf_maecte` | `bditransfer` | ⚠️ sí | SELECT | L212 |
| `si_param` | `bdinteg` | ⚠️ sí | SELECT | L239 |
| `tblparametros` | `bdispei` | no | SELECT | L252 |
| `sc_cuenta_telefono` | `bdicheq` | ⚠️ sí | SELECT | L326 |
| `si_sucursales` | `bdinteg` | ⚠️ sí | SELECT | L488 |
| `si_transacc` | `bdinteg` | ⚠️ sí | SELECT | L500 |
| `tbldetranpago` | `bdispei` | no | INSERT | L549 |
| `sc_movdia` | `bdicheq` | ⚠️ sí | SELECT | L626 |
| `tblpago` | `bdispei` | no | INSERT | L745 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_validaspei_bpi` | `bdispei` | no | L174 |
| `sp_validadv` | `bdispei` | no | L364 |
| `sp_regordenpagospei` | `bdispei` | no | L445 |
| `cargo_ref` | `bdicheq` | ⚠️ sí | L519 |
| `sp_validafecha` | `bdispei` | no | L645 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L148 | CÓDIGO_RETORNO | `LET vchrcodret = '00000';` |  |
| L192 | VALIDACIÓN_NULL | `IF (vchrTarjeta is null) OR (vchrTarjeta = '') then` |  |
| L221 | VALIDACIÓN_NULL | `IF pvchrCuentaOrd IS NULL OR pvchrCuentaOrd = '' THEN` |  |
| L230 | VALIDACIÓN_NULL | `IF (pdtfechacaptura is null) or (pdtfechacaptura = '') then` |  |
| L243 | VALIDACIÓN_NULL | `IF dIva IS NULL THEN` |  |
| L244 | CÓDIGO_RETORNO | `LET vchrcodret = '00011';` |  |
| L255 | VALIDACIÓN_NULL | `IF vchrparametro IS NULL THEN` |  |
| L256 | CÓDIGO_RETORNO | `LET vchrcodret = '00011';` |  |
| L262 | FÓRMULA | `LET vchrFechaValor = SUBSTR(TRIM(vchrparametro),4,2) \|\| '/' \|\| SUBSTR(TRIM(vchrparametro),0,2) \` |  |
| L279 | VALIDACIÓN_NULL | `IF vchrCtaOrdClabe IS NULL THEN` |  |
| L310 | VALIDACIÓN_NULL | `IF vexiste_cta is null OR vexiste_cta = '' THEN` |  |
| L339 | VALIDACIÓN_NULL | `IF vexiste_cta is null OR vexiste_cta = '' THEN` |  |
| L352 | VALIDACIÓN_NULL | `IF pvchrCuentaOrd is null OR pvchrCuentaOrd = '' THEN` |  |
| L383 | VALIDACIÓN_NULL | `IF pvchrCuentaBenef is null OR pvchrCuentaBenef = '' THEN` |  |
| L390 | CÓDIGO_RETORNO | `LET vchrcodret = '01168';` |  |
| L402 | VALIDACIÓN_NULL | `IF vchrTranscargo IS NULL OR vchrTranscargo = '' THEN` |  |
| L414 | VALIDACIÓN_NULL | `IF vchrComis IS NULL OR vchrCOmis = '' THEN` |  |
| L425 | VALIDACIÓN_NULL | `IF vchrIvaComis IS NULL OR vchrIvaComis = '' THEN` |  |
| L496 | VALIDACIÓN_NULL | `IF vexiste_suc is null OR vexiste_suc = '' THEN` |  |
| L648 | FÓRMULA | `LET vchrFechaValor = to_char(vfechaHabil, '%m/%d/%Y');` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `regordenctecte` | ACCION | Regresa Orden Cuenta a Cuenta — operación de transferencia/o | 🟡 INFERIDO | nombre_sp |
| `web` | MODIF | canal web | 🔵 CONVENCIÓN | nombre_sp |

---

## `sp_regordenpago`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_sp_regordenpago.sql` |
| **LOC (1er CREATE)** | 547 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "registro orden de pago" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 4 llamada(s): `sp_obtsigfolioop`, `spobtenerccc`, `spvalidaccc` |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=2 · INFERIDO=1 · SINTÉTICO=0 / 3 términos |

### Firma

```sql
CREATE PROCEDURE sp_regordenpago(
  chrUsuario                   CHAR(8)
  chrSucursal                  CHAR(4)
  chrFolio_suc                 CHAR(16)
  intBancoRec                  INTEGER
  chrvalconvenio               CHAR(1)
  dFechaValor                  DATE
  intTipoPago                  INTEGER
  intTipoOper                  INTEGER
  mnyImporteOP                 MONEY(18,2)
  vchrCuentaOrd                VARCHAR(20)
  vchrNombreBenef              VARCHAR(40)
  vchrCtaBenef                 VARCHAR(20)
  vchrRFCBenef                 VARCHAR(18)
  mnyImporteIVA                MONEY(18,2)
  decRefNum                    DECIMAL(7,0)
  vchrRefCobranza1             VARCHAR(40)
  vchrConceptoPago             VARCHAR(210)
  vchrClavePago                VARCHAR(10)
  vchrNombreBenef2             VARCHAR(40)
  vchrRFCBenef2                VARCHAR(18)
  vchrCtaBenef2                VARCHAR(20)
  vchrConceptoPago2            VARCHAR(40)
  vchrCveRastreo               VARCHAR(30)
  chrTransaccion               CHAR(4)
  vchrNumCte                   VARCHAR(20)
) RETURNING CHAR(5), CHAR(30)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `chrUsuario` | `CHAR(8)` | — | — |
| `chrSucursal` | `CHAR(4)` | — | — |
| `chrFolio_suc` | `CHAR(16)` | — | — |
| `intBancoRec` | `INTEGER` | — | — |
| `chrvalconvenio` | `CHAR(1)` | — | — |
| `dFechaValor` | `DATE` | — | — |
| `intTipoPago` | `INTEGER` | — | — |
| `intTipoOper` | `INTEGER` | — | — |
| `mnyImporteOP` | `MONEY(18,2)` | — | — |
| `vchrCuentaOrd` | `VARCHAR(20)` | — | — |
| `vchrNombreBenef` | `VARCHAR(40)` | — | — |
| `vchrCtaBenef` | `VARCHAR(20)` | — | — |
| `vchrRFCBenef` | `VARCHAR(18)` | — | — |
| `mnyImporteIVA` | `MONEY(18,2)` | — | — |
| `decRefNum` | `DECIMAL(7,0)` | — | — |
| `vchrRefCobranza1` | `VARCHAR(40)` | — | — |
| `vchrConceptoPago` | `VARCHAR(210)` | — | — |
| `vchrClavePago` | `VARCHAR(10)` | — | — |
| `vchrNombreBenef2` | `VARCHAR(40)` | — | — |
| `vchrRFCBenef2` | `VARCHAR(18)` | — | — |
| `vchrCtaBenef2` | `VARCHAR(20)` | — | — |
| `vchrConceptoPago2` | `VARCHAR(40)` | — | — |
| `vchrCveRastreo` | `VARCHAR(30)` | — | — |
| `chrTransaccion` | `CHAR(4)` | — | — |
| `vchrNumCte` | `VARCHAR(20)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vchrparametro` | `VARCHAR(255)` | L38 |
| `chrcodret` | `CHAR(5)` | L39 |
| `intcodret` | `INTEGER` | L40 |
| `vchrFechaOper` | `VARCHAR(10)` | L41 |
| `chrEstadoProceso` | `CHAR(1)` | L42 |
| `intcontador` | `INTEGER` | L43 |
| `inttpooper` | `INTEGER` | L44 |
| `vchrnombre` | `VARCHAR(40)` | L45 |
| `vchrrazonsocial` | `VARCHAR(40)` | L46 |
| `vchrnombreord` | `VARCHAR(40)` | L47 |
| `intpktblpago` | `INTEGER` | L48 |
| `chrspl` | `CHAR(7)` | L49 |
| `chrtopologia` | `CHAR(1)` | L50 |
| `intBancoOrd` | `INTEGER` | L51 |
| `vchrCLABEOrd` | `VARCHAR(18)` | L52 |
| `intTipoCta` | `INTEGER` | L53 |
| `intTpoCtaOpcional` | `INTEGER` | L54 |
| `chrabonachq` | `CHAR(1)` | L55 |
| `chrCodSistema` | `CHAR(2)` | L56 |
| `chrCodSisSPEI` | `CHAR(2)` | L57 |
| `vchrRFCOrd` | `VARCHAR(18)` | L58 |
| `vintCveCesif` | `INTEGER` | L59 |
| `vsintLongCveRast` | `SMALLINT` | L60 |
| `vintfolioop` | `INTEGER` | L61 |
| `v_montomin` | `MONEY` | L62 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tblparametros` | `bdispei` | no | SELECT | L101 |
| `tblhorario` | `bdispei` | no | SELECT | L123 |
| `tblctrlproceso` | `bdispei` | no | SELECT | L148 |
| `si_sucursales` | `bdinteg` | ⚠️ sí | SELECT | L165 |
| `si_ejecut` | `bdinteg` | ⚠️ sí | SELECT | L173 |
| `tbltipopago` | `bdispei` | no | SELECT | L191 |
| `tbltipooperacion` | `bdispei` | no | SELECT | L201 |
| `tblbanco` | `bdispei` | no | SELECT | L216 |
| `si_cliente` | `bdinteg` | ⚠️ sí | SELECT | L229 |
| `tblpago` | `bdispei` | no | SELECT | L250 |
| `tblpago` | `bdispei` | no | INSERT | L323 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_obtsigfolioop` | `bdispei` | no | L95 |
| `spobtenerccc` | `bditef` | ⚠️ sí | L266 |
| `spvalidaccc` | `bditef` | ⚠️ sí | L298 |
| `val_convenio_spei` | `terceros` | ⚠️ sí | L309 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L93 | VALIDACIÓN_NULL | `IF vchrCveRastreo IS NULL OR` |  |
| L103 | VALIDACIÓN_NULL | `IF vchrparametro IS NULL THEN` |  |
| L106 | FÓRMULA | `LET vchrFechaOper = SUBSTR(TRIM(vchrparametro),4,2) \|\| '/' \|\|` |  |
| L113 | VALIDACIÓN_NULL | `IF vchrparametro IS NULL THEN` |  |
| L133 | VALIDACIÓN_NULL | `IF vchrparametro IS NULL THEN` |  |
| L141 | VALIDACIÓN_NULL | `IF vchrparametro IS NULL THEN` |  |
| L144 | FÓRMULA | `LET intBancoOrd = (vchrparametro * 1);` |  |
| L150 | VALIDACIÓN_NULL | `IF chrEstadoProceso IS NULL THEN` |  |
| L183 | VALIDACIÓN_NULL | `IF vchrparametro IS NULL THEN` |  |
| L218 | VALIDACIÓN_NULL | `IF vintCveCesif IS NULL THEN` |  |
| L231 | VALIDACIÓN_NULL | `IF vchrnombre IS NULL OR TRIM(vchrnombre) = '' THEN` |  |
| L232 | VALIDACIÓN_NULL | `IF vchrrazonsocial IS NULL OR TRIM(vchrrazonsocial) = '' THEN` |  |
| L245 | VALIDACIÓN_NULL | `IF chrTransaccion IS NULL OR chrTransaccion = '' THEN` |  |
| L285 | VALIDACIÓN_NULL | `IF vchrCuentaOrd IS NULL OR vchrCuentaOrd = '' OR vchrNombreBenef IS NULL OR` |  |
| L321 | FÓRMULA | `LET decRefNum = substr(LPAD(intpktblpago, 12, '0'), -7);` |  |
| L334 | VALIDACIÓN_NULL | `IF vchrCuentaOrd IS NULL OR vchrCuentaOrd = '' OR vchrNombreBenef IS NULL` |  |
| L345 | FÓRMULA | `LET decRefNum = substr(LPAD(intpktblpago, 12, '0'), -7);` |  |
| L357 | VALIDACIÓN_NULL | `IF vchrCuentaOrd IS NULL OR vchrCuentaOrd = '' OR vchrNombreBenef IS NULL OR vchrNombreBenef = ''` |  |
| L372 | VALIDACIÓN_NULL | `IF NOT vchrCtaBenef2 IS NULL OR LENGTH(vchrCtaBenef2) > 0 THEN` |  |
| L394 | FÓRMULA | `LET decRefNum = substr(LPAD(intpktblpago, 12, '0'), -7);` |  |
| L412 | VALIDACIÓN_NULL | `IF vchrCuentaOrd IS NULL OR vchrCuentaOrd = '' OR intTipoOper IS NULL` |  |
| L423 | FÓRMULA | `LET decRefNum = substr(LPAD(intpktblpago, 12, '0'), -7);` |  |
| L434 | VALIDACIÓN_NULL | `IF vchrNombreBenef IS NULL OR vchrNombreBenef = '' OR vchrCtaBenef IS NULL OR vchrCtaBenef = ''  OR` |  |
| L454 | FÓRMULA | `LET decRefNum = substr(LPAD(intpktblpago, 12, '0'), -7);` |  |
| L467 | VALIDACIÓN_NULL | `IF vchrNombreBenef IS NULL OR vchrNombreBenef = '' OR vchrCtaBenef IS NULL` |  |
| L480 | VALIDACIÓN_NULL | `IF NOT vchrCtaBenef2 IS NULL OR LENGTH(vchrCtaBenef2) > 0 THEN` |  |
| L501 | FÓRMULA | `LET decRefNum = substr(LPAD(intpktblpago, 12, '0'), -7);` |  |
| L516 | VALIDACIÓN_NULL | `IF intTipoOper IS NULL --OR decRefNum IS NULL OR decRefNum = 0` |  |
| L526 | FÓRMULA | `LET decRefNum = substr(LPAD(intpktblpago, 12, '0'), -7);` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `reg` | ACCION | registro | 🟡 INFERIDO | nombre_sp |
| `ordenpago` | ENTIDAD | orden de pago | 🔵 CONVENCIÓN | nombre_sp |

---

## `sp_regordenpago_exp1`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_sp_regordenpago_exp1.sql` |
| **LOC (1er CREATE)** | 547 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "registro orden de pago (sufijo Exportar — SP genera/exporta archivo de salida)" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `genera` → `INSERT` encontrado en el cuerpo · `genera` → `SELECT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=2 · INFERIDO=2 · SINTÉTICO=1 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_regordenpago_exp1(
  chrUsuario                   CHAR(8)
  chrSucursal                  CHAR(4)
  chrFolio_suc                 CHAR(16)
  intBancoRec                  INTEGER
  chrvalconvenio               CHAR(1)
  dFechaValor                  DATE
  intTipoPago                  INTEGER
  intTipoOper                  INTEGER
  mnyImporteOP                 MONEY(18,2)
  vchrCuentaOrd                VARCHAR(20)
  vchrNombreBenef              VARCHAR(40)
  vchrCtaBenef                 VARCHAR(20)
  vchrRFCBenef                 VARCHAR(18)
  mnyImporteIVA                MONEY(18,2)
  decRefNum                    DECIMAL(7,0)
  vchrRefCobranza1             VARCHAR(40)
  vchrConceptoPago             VARCHAR(210)
  vchrClavePago                VARCHAR(10)
  vchrNombreBenef2             VARCHAR(40)
  vchrRFCBenef2                VARCHAR(18)
  vchrCtaBenef2                VARCHAR(20)
  vchrConceptoPago2            VARCHAR(40)
  vchrCveRastreo               VARCHAR(30)
  chrTransaccion               CHAR(4)
  vchrNumCte                   VARCHAR(20)
) RETURNING CHAR(5), CHAR(30)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `chrUsuario` | `CHAR(8)` | — | — |
| `chrSucursal` | `CHAR(4)` | — | — |
| `chrFolio_suc` | `CHAR(16)` | — | — |
| `intBancoRec` | `INTEGER` | — | — |
| `chrvalconvenio` | `CHAR(1)` | — | — |
| `dFechaValor` | `DATE` | — | — |
| `intTipoPago` | `INTEGER` | — | — |
| `intTipoOper` | `INTEGER` | — | — |
| `mnyImporteOP` | `MONEY(18,2)` | — | — |
| `vchrCuentaOrd` | `VARCHAR(20)` | — | — |
| `vchrNombreBenef` | `VARCHAR(40)` | — | — |
| `vchrCtaBenef` | `VARCHAR(20)` | — | — |
| `vchrRFCBenef` | `VARCHAR(18)` | — | — |
| `mnyImporteIVA` | `MONEY(18,2)` | — | — |
| `decRefNum` | `DECIMAL(7,0)` | — | — |
| `vchrRefCobranza1` | `VARCHAR(40)` | — | — |
| `vchrConceptoPago` | `VARCHAR(210)` | — | — |
| `vchrClavePago` | `VARCHAR(10)` | — | — |
| `vchrNombreBenef2` | `VARCHAR(40)` | — | — |
| `vchrRFCBenef2` | `VARCHAR(18)` | — | — |
| `vchrCtaBenef2` | `VARCHAR(20)` | — | — |
| `vchrConceptoPago2` | `VARCHAR(40)` | — | — |
| `vchrCveRastreo` | `VARCHAR(30)` | — | — |
| `chrTransaccion` | `CHAR(4)` | — | — |
| `vchrNumCte` | `VARCHAR(20)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vchrparametro` | `VARCHAR(255)` | L38 |
| `chrcodret` | `CHAR(5)` | L39 |
| `intcodret` | `INTEGER` | L40 |
| `vchrFechaOper` | `VARCHAR(10)` | L41 |
| `chrEstadoProceso` | `CHAR(1)` | L42 |
| `intcontador` | `INTEGER` | L43 |
| `inttpooper` | `INTEGER` | L44 |
| `vchrnombre` | `VARCHAR(40)` | L45 |
| `vchrrazonsocial` | `VARCHAR(40)` | L46 |
| `vchrnombreord` | `VARCHAR(40)` | L47 |
| `intpktblpago` | `INTEGER` | L48 |
| `chrspl` | `CHAR(7)` | L49 |
| `chrtopologia` | `CHAR(1)` | L50 |
| `intBancoOrd` | `INTEGER` | L51 |
| `vchrCLABEOrd` | `VARCHAR(18)` | L52 |
| `intTipoCta` | `INTEGER` | L53 |
| `intTpoCtaOpcional` | `INTEGER` | L54 |
| `chrabonachq` | `CHAR(1)` | L55 |
| `chrCodSistema` | `CHAR(2)` | L56 |
| `chrCodSisSPEI` | `CHAR(2)` | L57 |
| `vchrRFCOrd` | `VARCHAR(18)` | L58 |
| `vintCveCesif` | `INTEGER` | L59 |
| `vsintLongCveRast` | `SMALLINT` | L60 |
| `vintfolioop` | `INTEGER` | L61 |
| `v_montomin` | `MONEY` | L62 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tblparametros` | `bdispei` | no | SELECT | L101 |
| `tblhorario` | `bdispei` | no | SELECT | L123 |
| `tblctrlproceso` | `bdispei` | no | SELECT | L148 |
| `si_sucursales` | `bdinteg` | ⚠️ sí | SELECT | L165 |
| `si_ejecut` | `bdinteg` | ⚠️ sí | SELECT | L173 |
| `tbltipopago` | `bdispei` | no | SELECT | L191 |
| `tbltipooperacion` | `bdispei` | no | SELECT | L201 |
| `tblbanco` | `bdispei` | no | SELECT | L216 |
| `si_cliente` | `bdinteg` | ⚠️ sí | SELECT | L229 |
| `tblpago` | `bdispei` | no | SELECT | L250 |
| `tblpago` | `bdispei` | no | INSERT | L323 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_obtsigfolioop` | `bdispei` | no | L95 |
| `spobtenerccc` | `bditef` | ⚠️ sí | L266 |
| `spvalidaccc` | `bditef` | ⚠️ sí | L298 |
| `val_convenio_spei` | `terceros` | ⚠️ sí | L309 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L93 | VALIDACIÓN_NULL | `IF vchrCveRastreo IS NULL OR` |  |
| L103 | VALIDACIÓN_NULL | `IF vchrparametro IS NULL THEN` |  |
| L106 | FÓRMULA | `LET vchrFechaOper = SUBSTR(TRIM(vchrparametro),4,2) \|\| '/' \|\|` |  |
| L113 | VALIDACIÓN_NULL | `IF vchrparametro IS NULL THEN` |  |
| L133 | VALIDACIÓN_NULL | `IF vchrparametro IS NULL THEN` |  |
| L141 | VALIDACIÓN_NULL | `IF vchrparametro IS NULL THEN` |  |
| L144 | FÓRMULA | `LET intBancoOrd = (vchrparametro * 1);` |  |
| L150 | VALIDACIÓN_NULL | `IF chrEstadoProceso IS NULL THEN` |  |
| L183 | VALIDACIÓN_NULL | `IF vchrparametro IS NULL THEN` |  |
| L218 | VALIDACIÓN_NULL | `IF vintCveCesif IS NULL THEN` |  |
| L231 | VALIDACIÓN_NULL | `IF vchrnombre IS NULL OR TRIM(vchrnombre) = '' THEN` |  |
| L232 | VALIDACIÓN_NULL | `IF vchrrazonsocial IS NULL OR TRIM(vchrrazonsocial) = '' THEN` |  |
| L245 | VALIDACIÓN_NULL | `IF chrTransaccion IS NULL OR chrTransaccion = '' THEN` |  |
| L285 | VALIDACIÓN_NULL | `IF vchrCuentaOrd IS NULL OR vchrCuentaOrd = '' OR vchrNombreBenef IS NULL OR` |  |
| L321 | FÓRMULA | `LET decRefNum = substr(LPAD(intpktblpago, 12, '0'), -7);` |  |
| L334 | VALIDACIÓN_NULL | `IF vchrCuentaOrd IS NULL OR vchrCuentaOrd = '' OR vchrNombreBenef IS NULL` |  |
| L345 | FÓRMULA | `LET decRefNum = substr(LPAD(intpktblpago, 12, '0'), -7);` |  |
| L357 | VALIDACIÓN_NULL | `IF vchrCuentaOrd IS NULL OR vchrCuentaOrd = '' OR vchrNombreBenef IS NULL OR vchrNombreBenef = ''` |  |
| L372 | VALIDACIÓN_NULL | `IF NOT vchrCtaBenef2 IS NULL OR LENGTH(vchrCtaBenef2) > 0 THEN` |  |
| L394 | FÓRMULA | `LET decRefNum = substr(LPAD(intpktblpago, 12, '0'), -7);` |  |
| L412 | VALIDACIÓN_NULL | `IF vchrCuentaOrd IS NULL OR vchrCuentaOrd = '' OR intTipoOper IS NULL` |  |
| L423 | FÓRMULA | `LET decRefNum = substr(LPAD(intpktblpago, 12, '0'), -7);` |  |
| L434 | VALIDACIÓN_NULL | `IF vchrNombreBenef IS NULL OR vchrNombreBenef = '' OR vchrCtaBenef IS NULL OR vchrCtaBenef = ''  OR` |  |
| L454 | FÓRMULA | `LET decRefNum = substr(LPAD(intpktblpago, 12, '0'), -7);` |  |
| L467 | VALIDACIÓN_NULL | `IF vchrNombreBenef IS NULL OR vchrNombreBenef = '' OR vchrCtaBenef IS NULL` |  |
| L480 | VALIDACIÓN_NULL | `IF NOT vchrCtaBenef2 IS NULL OR LENGTH(vchrCtaBenef2) > 0 THEN` |  |
| L501 | FÓRMULA | `LET decRefNum = substr(LPAD(intpktblpago, 12, '0'), -7);` |  |
| L516 | VALIDACIÓN_NULL | `IF intTipoOper IS NULL --OR decRefNum IS NULL OR decRefNum = 0` |  |
| L526 | FÓRMULA | `LET decRefNum = substr(LPAD(intpktblpago, 12, '0'), -7);` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `reg` | ACCION | registro | 🟡 INFERIDO | nombre_sp |
| `ordenpago` | ENTIDAD | orden de pago | 🔵 CONVENCIÓN | nombre_sp |
| `exp` | MODIF | sufijo Exportar — SP genera/exporta archivo de salida (sp_*_ | 🟡 INFERIDO | nombre_sp |
| `?1` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?1` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_regordenpagospei`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_sp_regordenpagospei.sql` |
| **LOC (1er CREATE)** | 386 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "registro orden de pago" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 3 llamada(s): `spei_validaoperacion`, `sp_obtsigfolioop`, `digver11` |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=2 · INFERIDO=1 · SINTÉTICO=0 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_regordenpagospei(
  pEmpresa                     CHAR(3)
  pchrUsuario                  CHAR(8)
  pchrSucursal                 CHAR(4)
  pchrFolioSuc                 CHAR(16)
  pintBancoDestino             INTEGER
  pdFechaCaptura               DATE
  pintTipoPago                 INTEGER
  pintTipoOper                 INTEGER
  pmnyImporteOP                MONEY(18,2)
  pvchrNombreOrd               VARCHAR(40)
  pvchrCuentaOrd               VARCHAR(20)
  pvchrRFCOrd                  VARCHAR(18)
  pvchrNombreBenef             VARCHAR(40)
  pvchrCtaBenef                VARCHAR(20)
  pvchrRFCBenef                VARCHAR(18)
  pmnyImporteIVA               MONEY(18,2)
  pdecRefNum                   DECIMAL(7,0)
  pvchrRefCobranza1            VARCHAR(40)
  pvchrConceptoPago            VARCHAR(210)
  pvchrClavePago               VARCHAR(10)
  pvchrNombreBenef2            VARCHAR(40)
  pvchrRFCBenef2               VARCHAR(18)
  pvchrCtaBenef2               VARCHAR(20)
  pvchrConceptoPago2           VARCHAR(40)
  pchrTransaccion              CHAR(4)
  pintTipoCtaOrd               INTEGER
  pintTipoCtaBenef             INTEGER
) RETURNING CHAR(5), CHAR(100), CHAR(30), INTEGER, VARCHAR(10), CHAR(1), INTEGER, INTEGER, SMALLINT, DECIMAL(7,0)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pEmpresa` | `CHAR(3)` | — | — |
| `pchrUsuario` | `CHAR(8)` | — | — |
| `pchrSucursal` | `CHAR(4)` | — | — |
| `pchrFolioSuc` | `CHAR(16)` | — | — |
| `pintBancoDestino` | `INTEGER` | — | — |
| `pdFechaCaptura` | `DATE` | — | — |
| `pintTipoPago` | `INTEGER` | — | — |
| `pintTipoOper` | `INTEGER` | — | — |
| `pmnyImporteOP` | `MONEY(18,2)` | — | — |
| `pvchrNombreOrd` | `VARCHAR(40)` | — | — |
| `pvchrCuentaOrd` | `VARCHAR(20)` | — | — |
| `pvchrRFCOrd` | `VARCHAR(18)` | — | — |
| `pvchrNombreBenef` | `VARCHAR(40)` | — | — |
| `pvchrCtaBenef` | `VARCHAR(20)` | — | — |
| `pvchrRFCBenef` | `VARCHAR(18)` | — | — |
| `pmnyImporteIVA` | `MONEY(18,2)` | — | — |
| `pdecRefNum` | `DECIMAL(7,0)` | — | — |
| `pvchrRefCobranza1` | `VARCHAR(40)` | — | — |
| `pvchrConceptoPago` | `VARCHAR(210)` | — | — |
| `pvchrClavePago` | `VARCHAR(10)` | — | — |
| `pvchrNombreBenef2` | `VARCHAR(40)` | — | — |
| `pvchrRFCBenef2` | `VARCHAR(18)` | — | — |
| `pvchrCtaBenef2` | `VARCHAR(20)` | — | — |
| `pvchrConceptoPago2` | `VARCHAR(40)` | — | — |
| `pchrTransaccion` | `CHAR(4)` | — | — |
| `pintTipoCtaOrd` | `INTEGER` | — | — |
| `pintTipoCtaBenef` | `INTEGER` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cVarDataErr` | `VARCHAR(100)` | L74 |
| `vchrparametro` | `VARCHAR(255)` | L75 |
| `chrcodret` | `CHAR(5)` | L76 |
| `chrcodret2` | `CHAR(5)` | L77 |
| `charcodret3` | `CHAR(50)` | L78 |
| `intcodret` | `INTEGER` | L79 |
| `intcodret2` | `INTEGER` | L80 |
| `chrcodret3` | `CHAR(50)` | L81 |
| `vchrFechaValor` | `VARCHAR(10)` | L82 |
| `chrEstadoProceso` | `CHAR(1)` | L83 |
| `intcontador` | `INTEGER` | L84 |
| `inttpooper` | `INTEGER` | L85 |
| `intpktblpago` | `INTEGER` | L86 |
| `chrspl` | `CHAR(7)` | L87 |
| `vchrtopologia` | `CHAR(1)` | L88 |
| `intBancoOrd` | `INTEGER` | L89 |
| `vchrCLABEOrd` | `VARCHAR(18)` | L90 |
| `intTpoCtaOpcional` | `INTEGER` | L91 |
| `chrabonachq` | `CHAR(1)` | L92 |
| `vintCveCesif` | `INTEGER` | L93 |
| `vsintLongCveRast` | `SMALLINT` | L94 |
| `vintfolioop` | `INTEGER` | L95 |
| `v_montomin` | `MONEY` | L96 |
| `vchrCveRastreo` | `VARCHAR(30)` | L97 |
| `vdigverif` | `CHAR(1)` | L98 |
| *…3 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tblparametros` | `bdispei` | no | SELECT | L152 |
| `si_sucursales` | `bdinteg` | ⚠️ sí | SELECT | L228 |
| `si_ejecut` | `bdinteg` | ⚠️ sí | SELECT | L240 |
| `tbltipopago` | `bdispei` | no | SELECT | L252 |
| `tbltipooperacion` | `bdispei` | no | SELECT | L270 |
| `tblbanco` | `bdispei` | no | SELECT | L295 |
| `tblpago` | `bdispei` | no | SELECT | L327 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `spei_validaoperacion` | `bdispei` | no | L188 |
| `sp_obtsigfolioop` | `bdispei` | no | L348 |
| `digver11` | `bdicheq` | ⚠️ sí | L364 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L134 | VALIDACIÓN_NULL | `IF pvchrNombreOrd IS NULL OR pvchrNombreOrd = '' OR` |  |
| L155 | VALIDACIÓN_NULL | `IF vchrparametro IS NULL THEN` |  |
| L162 | FÓRMULA | `LET vchrFechaValor = SUBSTR(TRIM(vchrparametro),4,2) \|\| '/' \|\|` |  |
| L173 | VALIDACIÓN_NULL | `IF vchrparametro IS NULL THEN` |  |
| L203 | VALIDACIÓN_NULL | `IF vchrparametro IS NULL THEN` |  |
| L217 | VALIDACIÓN_NULL | `IF vchrparametro IS NULL THEN` |  |
| L223 | FÓRMULA | `LET intBancoOrd = (vchrparametro * 1);` |  |
| L299 | VALIDACIÓN_NULL | `IF vintCveCesif IS NULL THEN` |  |
| L313 | VALIDACIÓN_NULL | `IF pchrTransaccion IS NULL OR pchrTransaccion = '' THEN` |  |
| L356 | VALIDACIÓN_NULL | `IF vdecRefNum IS NULL or vdecRefNum = 0 THEN` |  |
| L357 | FÓRMULA | `LET vdecRefNum = substr(LPAD(intpktblpago, 12, '0'), -7);` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `reg` | ACCION | registro | 🟡 INFERIDO | nombre_sp |
| `ordenpago` | ENTIDAD | orden de pago | 🔵 CONVENCIÓN | nombre_sp |
| `spei` | PREFIJO | familia SPEI (pagos interbancarios) | ✅ CÓDIGO | nombre_sp, texto_cuerpo |

---

## `sp_regordenpagospei_exp1`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_sp_regordenpagospei_exp1.sql` |
| **LOC (1er CREATE)** | 386 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "registro orden de pago (sufijo Exportar — SP genera/exporta archivo de salida)" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `genera` → `SELECT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=2 · INFERIDO=2 · SINTÉTICO=1 / 6 términos |

### Firma

```sql
CREATE PROCEDURE sp_regordenpagospei_exp1(
  pEmpresa                     CHAR(3)
  pchrUsuario                  CHAR(8)
  pchrSucursal                 CHAR(4)
  pchrFolioSuc                 CHAR(16)
  pintBancoDestino             INTEGER
  pdFechaCaptura               DATE
  pintTipoPago                 INTEGER
  pintTipoOper                 INTEGER
  pmnyImporteOP                MONEY(18,2)
  pvchrNombreOrd               VARCHAR(40)
  pvchrCuentaOrd               VARCHAR(20)
  pvchrRFCOrd                  VARCHAR(18)
  pvchrNombreBenef             VARCHAR(40)
  pvchrCtaBenef                VARCHAR(20)
  pvchrRFCBenef                VARCHAR(18)
  pmnyImporteIVA               MONEY(18,2)
  pdecRefNum                   DECIMAL(7,0)
  pvchrRefCobranza1            VARCHAR(40)
  pvchrConceptoPago            VARCHAR(210)
  pvchrClavePago               VARCHAR(10)
  pvchrNombreBenef2            VARCHAR(40)
  pvchrRFCBenef2               VARCHAR(18)
  pvchrCtaBenef2               VARCHAR(20)
  pvchrConceptoPago2           VARCHAR(40)
  pchrTransaccion              CHAR(4)
  pintTipoCtaOrd               INTEGER
  pintTipoCtaBenef             INTEGER
) RETURNING CHAR(5), CHAR(100), CHAR(30), INTEGER, VARCHAR(10), CHAR(1), INTEGER, INTEGER, SMALLINT, DECIMAL(7,0)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pEmpresa` | `CHAR(3)` | — | — |
| `pchrUsuario` | `CHAR(8)` | — | — |
| `pchrSucursal` | `CHAR(4)` | — | — |
| `pchrFolioSuc` | `CHAR(16)` | — | — |
| `pintBancoDestino` | `INTEGER` | — | — |
| `pdFechaCaptura` | `DATE` | — | — |
| `pintTipoPago` | `INTEGER` | — | — |
| `pintTipoOper` | `INTEGER` | — | — |
| `pmnyImporteOP` | `MONEY(18,2)` | — | — |
| `pvchrNombreOrd` | `VARCHAR(40)` | — | — |
| `pvchrCuentaOrd` | `VARCHAR(20)` | — | — |
| `pvchrRFCOrd` | `VARCHAR(18)` | — | — |
| `pvchrNombreBenef` | `VARCHAR(40)` | — | — |
| `pvchrCtaBenef` | `VARCHAR(20)` | — | — |
| `pvchrRFCBenef` | `VARCHAR(18)` | — | — |
| `pmnyImporteIVA` | `MONEY(18,2)` | — | — |
| `pdecRefNum` | `DECIMAL(7,0)` | — | — |
| `pvchrRefCobranza1` | `VARCHAR(40)` | — | — |
| `pvchrConceptoPago` | `VARCHAR(210)` | — | — |
| `pvchrClavePago` | `VARCHAR(10)` | — | — |
| `pvchrNombreBenef2` | `VARCHAR(40)` | — | — |
| `pvchrRFCBenef2` | `VARCHAR(18)` | — | — |
| `pvchrCtaBenef2` | `VARCHAR(20)` | — | — |
| `pvchrConceptoPago2` | `VARCHAR(40)` | — | — |
| `pchrTransaccion` | `CHAR(4)` | — | — |
| `pintTipoCtaOrd` | `INTEGER` | — | — |
| `pintTipoCtaBenef` | `INTEGER` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cVarDataErr` | `VARCHAR(100)` | L74 |
| `vchrparametro` | `VARCHAR(255)` | L75 |
| `chrcodret` | `CHAR(5)` | L76 |
| `chrcodret2` | `CHAR(5)` | L77 |
| `charcodret3` | `CHAR(50)` | L78 |
| `intcodret` | `INTEGER` | L79 |
| `intcodret2` | `INTEGER` | L80 |
| `chrcodret3` | `CHAR(50)` | L81 |
| `vchrFechaValor` | `VARCHAR(10)` | L82 |
| `chrEstadoProceso` | `CHAR(1)` | L83 |
| `intcontador` | `INTEGER` | L84 |
| `inttpooper` | `INTEGER` | L85 |
| `intpktblpago` | `INTEGER` | L86 |
| `chrspl` | `CHAR(7)` | L87 |
| `vchrtopologia` | `CHAR(1)` | L88 |
| `intBancoOrd` | `INTEGER` | L89 |
| `vchrCLABEOrd` | `VARCHAR(18)` | L90 |
| `intTpoCtaOpcional` | `INTEGER` | L91 |
| `chrabonachq` | `CHAR(1)` | L92 |
| `vintCveCesif` | `INTEGER` | L93 |
| `vsintLongCveRast` | `SMALLINT` | L94 |
| `vintfolioop` | `INTEGER` | L95 |
| `v_montomin` | `MONEY` | L96 |
| `vchrCveRastreo` | `VARCHAR(30)` | L97 |
| `vdigverif` | `CHAR(1)` | L98 |
| *…3 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tblparametros` | `bdispei` | no | SELECT | L152 |
| `si_sucursales` | `bdinteg` | ⚠️ sí | SELECT | L228 |
| `si_ejecut` | `bdinteg` | ⚠️ sí | SELECT | L240 |
| `tbltipopago` | `bdispei` | no | SELECT | L252 |
| `tbltipooperacion` | `bdispei` | no | SELECT | L270 |
| `tblbanco` | `bdispei` | no | SELECT | L295 |
| `tblpago` | `bdispei` | no | SELECT | L327 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `spei_validaoperacion` | `bdispei` | no | L188 |
| `sp_obtsigfolioop` | `bdispei` | no | L348 |
| `digver11` | `bdicheq` | ⚠️ sí | L364 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L134 | VALIDACIÓN_NULL | `IF pvchrNombreOrd IS NULL OR pvchrNombreOrd = '' OR` |  |
| L155 | VALIDACIÓN_NULL | `IF vchrparametro IS NULL THEN` |  |
| L162 | FÓRMULA | `LET vchrFechaValor = SUBSTR(TRIM(vchrparametro),4,2) \|\| '/' \|\|` |  |
| L173 | VALIDACIÓN_NULL | `IF vchrparametro IS NULL THEN` |  |
| L203 | VALIDACIÓN_NULL | `IF vchrparametro IS NULL THEN` |  |
| L217 | VALIDACIÓN_NULL | `IF vchrparametro IS NULL THEN` |  |
| L223 | FÓRMULA | `LET intBancoOrd = (vchrparametro * 1);` |  |
| L299 | VALIDACIÓN_NULL | `IF vintCveCesif IS NULL THEN` |  |
| L313 | VALIDACIÓN_NULL | `IF pchrTransaccion IS NULL OR pchrTransaccion = '' THEN` |  |
| L356 | VALIDACIÓN_NULL | `IF vdecRefNum IS NULL or vdecRefNum = 0 THEN` |  |
| L357 | FÓRMULA | `LET vdecRefNum = substr(LPAD(intpktblpago, 12, '0'), -7);` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `reg` | ACCION | registro | 🟡 INFERIDO | nombre_sp |
| `ordenpago` | ENTIDAD | orden de pago | 🔵 CONVENCIÓN | nombre_sp |
| `spei` | PREFIJO | familia SPEI (pagos interbancarios) | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `exp` | MODIF | sufijo Exportar — SP genera/exporta archivo de salida (sp_*_ | 🟡 INFERIDO | nombre_sp |
| `?1` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?1` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_regordenpagospei_pp`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_sp_regordenpagospei_pp.sql` |
| **LOC (1er CREATE)** | 468 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "registro orden de pago (PP — Persona a Persona o Pago Programado)" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 2 llamada(s): `sp_obtsigfolioop`, `sp_quitar_acentos` |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=2 · INFERIDO=1 · SINTÉTICO=1 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_regordenpagospei_pp(
  pEmpresa                     CHAR(3)
  pchrUsuario                  CHAR(8)
  pchrSucursal                 CHAR(4)
  pchrFolioSuc                 CHAR(16)
  pintBancoDestino             INTEGER
  pdFechaCaptura               DATE
  pintTipoPago                 INTEGER
  pintTipoOper                 INTEGER
  pmnyImporteOP                MONEY(18,2)
  pvchrNombreOrd               VARCHAR(40)
  pvchrCuentaOrd               VARCHAR(20)
  pvchrRFCOrd                  VARCHAR(18)
  pvchrNombreBenef             VARCHAR(40)
  pvchrCtaBenef                VARCHAR(20)
  pvchrRFCBenef                VARCHAR(18)
  pmnyImporteIVA               MONEY(18,2)
  pdecRefNum                   DECIMAL(7,0)
  pvchrRefCobranza1            VARCHAR(40)
  pvchrConceptoPago            VARCHAR(210)
  pvchrClavePago               VARCHAR(10)
  pvchrNombreBenef2            VARCHAR(40)
  pvchrRFCBenef2               VARCHAR(18)
  pvchrCtaBenef2               VARCHAR(20)
  pvchrConceptoPago2           VARCHAR(40)
  pchrTransaccion              CHAR(4)
  pintTipoCtaOrd               INTEGER
  pintTipoCtaBenef             INTEGER
) RETURNING CHAR(5), CHAR(100), CHAR(30)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pEmpresa` | `CHAR(3)` | — | — |
| `pchrUsuario` | `CHAR(8)` | — | — |
| `pchrSucursal` | `CHAR(4)` | — | — |
| `pchrFolioSuc` | `CHAR(16)` | — | — |
| `pintBancoDestino` | `INTEGER` | — | — |
| `pdFechaCaptura` | `DATE` | — | — |
| `pintTipoPago` | `INTEGER` | — | — |
| `pintTipoOper` | `INTEGER` | — | — |
| `pmnyImporteOP` | `MONEY(18,2)` | — | — |
| `pvchrNombreOrd` | `VARCHAR(40)` | — | — |
| `pvchrCuentaOrd` | `VARCHAR(20)` | — | — |
| `pvchrRFCOrd` | `VARCHAR(18)` | — | — |
| `pvchrNombreBenef` | `VARCHAR(40)` | — | — |
| `pvchrCtaBenef` | `VARCHAR(20)` | — | — |
| `pvchrRFCBenef` | `VARCHAR(18)` | — | — |
| `pmnyImporteIVA` | `MONEY(18,2)` | — | — |
| `pdecRefNum` | `DECIMAL(7,0)` | — | — |
| `pvchrRefCobranza1` | `VARCHAR(40)` | — | — |
| `pvchrConceptoPago` | `VARCHAR(210)` | — | — |
| `pvchrClavePago` | `VARCHAR(10)` | — | — |
| `pvchrNombreBenef2` | `VARCHAR(40)` | — | — |
| `pvchrRFCBenef2` | `VARCHAR(18)` | — | — |
| `pvchrCtaBenef2` | `VARCHAR(20)` | — | — |
| `pvchrConceptoPago2` | `VARCHAR(40)` | — | — |
| `pchrTransaccion` | `CHAR(4)` | — | — |
| `pintTipoCtaOrd` | `INTEGER` | — | — |
| `pintTipoCtaBenef` | `INTEGER` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cVarDataErr` | `VARCHAR(100)` | L74 |
| `vchrparametro` | `VARCHAR(255)` | L75 |
| `chrcodret` | `CHAR(5)` | L76 |
| `chrcodret2` | `CHAR(5)` | L77 |
| `charcodret3` | `CHAR(50)` | L78 |
| `intcodret` | `INTEGER` | L79 |
| `intcodret2` | `INTEGER` | L80 |
| `chrcodret3` | `CHAR(50)` | L81 |
| `vchrFechaValor` | `VARCHAR(10)` | L82 |
| `chrEstadoProceso` | `CHAR(1)` | L83 |
| `intcontador` | `INTEGER` | L84 |
| `inttpooper` | `INTEGER` | L85 |
| `intpktblpago` | `INTEGER` | L86 |
| `chrspl` | `CHAR(7)` | L87 |
| `chrtopologia` | `CHAR(1)` | L88 |
| `intBancoOrd` | `INTEGER` | L89 |
| `vchrCLABEOrd` | `VARCHAR(18)` | L90 |
| `intTpoCtaOpcional` | `INTEGER` | L91 |
| `chrabonachq` | `CHAR(1)` | L92 |
| `vintCveCesif` | `INTEGER` | L93 |
| `vsintLongCveRast` | `SMALLINT` | L94 |
| `vintfolioop` | `INTEGER` | L95 |
| `v_montomin` | `MONEY` | L96 |
| `vchrCveRastreo` | `VARCHAR(30)` | L97 |
| `wmnyImporte` | `DECIMAL (14,2)` | L98 |
| *…11 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tblparametros` | `bdispei` | no | SELECT | L145 |
| `tblhorario` | `bdispei` | no | SELECT | L156 |
| `tblctrlproceso` | `bdispei` | no | SELECT | L200 |
| `si_sucursales` | `bdinteg` | ⚠️ sí | SELECT | L214 |
| `si_ejecut` | `bdinteg` | ⚠️ sí | SELECT | L226 |
| `tbltipopago` | `bdispei` | no | SELECT | L238 |
| `tbltipooperacion` | `bdispei` | no | SELECT | L256 |
| `tblbanco` | `bdispei` | no | SELECT | L281 |
| `tblpago` | `bdispei` | no | SELECT | L306 |
| `tblpago` | `bdispei` | no | INSERT | L449 |
| `tbldetranpago` | `bdispei` | no | INSERT | L459 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_obtsigfolioop` | `bdispei` | no | L136 |
| `sp_quitar_acentos` | `bdinteg` | ⚠️ sí | L383 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L148 | FÓRMULA | `LET vchrFechaValor = SUBSTR(vchrFechaValor, 4, 2) \|\| '/' \|\| SUBSTR(vchrFechaValor, 1, 2) \|\| '/` |  |
| L174 | VALIDACIÓN_NULL | `IF vchrparametro IS NULL THEN` |  |
| L188 | VALIDACIÓN_NULL | `IF vchrparametro IS NULL THEN` |  |
| L194 | FÓRMULA | `LET intBancoOrd = (vchrparametro * 1);` |  |
| L285 | VALIDACIÓN_NULL | `IF vintCveCesif IS NULL THEN` |  |
| L292 | VALIDACIÓN_NULL | `IF pchrTransaccion IS NULL OR pchrTransaccion = '' THEN` |  |
| L335 | VALIDACIÓN_NULL | `IF pvchrNombreOrd IS NULL OR pvchrNombreOrd = '' OR` |  |
| L371 | VALIDACIÓN_NULL | `IF pdecRefNum IS NULL or pdecRefNum = 0 THEN` |  |
| L372 | FÓRMULA | `LET pdecRefNum = substr(LPAD(intpktblpago, 12, '0'), -7);` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `reg` | ACCION | registro | 🟡 INFERIDO | nombre_sp |
| `ordenpago` | ENTIDAD | orden de pago | 🔵 CONVENCIÓN | nombre_sp |
| `spei` | PREFIJO | familia SPEI (pagos interbancarios) | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `pp` | MODIF | PP — Persona a Persona o Pago Programado (sp_regordenctecte_ | 🔴 SINTÉTICO | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `pp` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_regordenprom`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_sp_regordenprom.sql` |
| **LOC (1er CREATE)** | 139 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "registro orden" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 2 llamada(s): `spobtenerccc`, `sp_regordenpago` |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=1 · INFERIDO=1 · SINTÉTICO=1 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_regordenprom(
  pchrUsuario                  CHAR(8)
  pchrSucursal                 CHAR(4)
  pchrFolio_prom               CHAR(16)
  pvchrCuentaOrd               VARCHAR(20)
  pmnyImporteOP                MONEY(18,2)
  pintBancoRec                 INTEGER
  pvchrNombreBenef             VARCHAR(40)
  pintTipoCtaBenef             INTEGER
  pvchrCtaBenef                VARCHAR(20)
  pvchrRFCBenef                VARCHAR(18)
  pvchrConceptoPago            VARCHAR(40)
  pdecRefNum                   DECIMAL(7,0)
  pvchrRefCobranza1            VARCHAR(40)
  pchrCuenta                   CHAR(11)
  pchrPlaza                    CHAR(5)
  pchrTrans                    CHAR(4)
  pchrvalconvenio              CHAR(1)
) RETURNING CHAR(5), CHAR(30)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pchrUsuario` | `CHAR(8)` | — | — |
| `pchrSucursal` | `CHAR(4)` | — | — |
| `pchrFolio_prom` | `CHAR(16)` | — | — |
| `pvchrCuentaOrd` | `VARCHAR(20)` | — | — |
| `pmnyImporteOP` | `MONEY(18,2)` | — | — |
| `pintBancoRec` | `INTEGER` | — | — |
| `pvchrNombreBenef` | `VARCHAR(40)` | — | — |
| `pintTipoCtaBenef` | `INTEGER` | — | — |
| `pvchrCtaBenef` | `VARCHAR(20)` | — | — |
| `pvchrRFCBenef` | `VARCHAR(18)` | — | — |
| `pvchrConceptoPago` | `VARCHAR(40)` | — | — |
| `pdecRefNum` | `DECIMAL(7,0)` | — | — |
| `pvchrRefCobranza1` | `VARCHAR(40)` | — | — |
| `pchrCuenta` | `CHAR(11)` | — | — |
| `pchrPlaza` | `CHAR(5)` | — | — |
| `pchrTrans` | `CHAR(4)` | — | — |
| `pchrvalconvenio` | `CHAR(1)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vchrcodret` | `CHAR(5)` | L54 |
| `vintcodret` | `INTEGER` | L55 |
| `vvchrCveRastreo` | `VARCHAR(30)` | L56 |
| `vdtfecha` | `DATE` | L57 |
| `vintPermiteCta11` | `INTEGER` | L58 |
| `vchrFuente` | `CHAR(7)` | L59 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_fechas` | `bdinteg` | ⚠️ sí | SELECT | L78 |
| `tblparametros` | `bdispei` | no | SELECT | L86 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `spobtenerccc` | `bditef` | ⚠️ sí | L99 |
| `sp_regordenpago` | `bdispei` | no | L110 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L89 | VALIDACIÓN_NULL | `IF vintpermitecta11 IS NULL THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `reg` | ACCION | registro | 🟡 INFERIDO | nombre_sp |
| `orden` | ENTIDAD | orden | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?prom` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?prom` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_regordenspei`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_sp_regordenspei.sql` |
| **LOC (1er CREATE)** | 146 |
| **Callgraph** | ✅ fan_in=0 / fan_out=2 |
| **Propósito inferido** | "registro orden" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 2 llamada(s): `sp_desc_ret`, `sp_regordenpago` |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=1 · INFERIDO=1 · SINTÉTICO=0 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_regordenspei(
  pchrUsuario                  CHAR(8)
  pchrSucursal                 CHAR(4)
  pchrFolio                    CHAR(16)
  pmnyImporteOP                MONEY(18,2)
  pintBancoRec                 INTEGER
  pvchrNombreBenef             VARCHAR(40)
  pvchrCtaBenef                VARCHAR(20)
  pvchrRFCBenef                VARCHAR(18)
  pvchrNombreBenef2            VARCHAR(40)
  pvchrCtaBenef2               VARCHAR(20)
  pvchrRFCBenef2               VARCHAR(18)
  pdtFechaValor                DATE
  pvchrConceptoPago            VARCHAR(210)
  pdecRefNum                   DECIMAL(7,0)
  pchrTrans                    CHAR(4)
  pintTipoPago                 INTEGER
  pintTipoOper                 INTEGER
  pchrCtaOrd                   VARCHAR(20)
  pvchrRefCobranza1            VARCHAR(40)
  pchrClavePago                VARCHAR(10)
  pchrNumCte                   VARCHAR(20)
) RETURNING CHAR(5), CHAR(60), CHAR(30)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pchrUsuario` | `CHAR(8)` | — | — |
| `pchrSucursal` | `CHAR(4)` | — | — |
| `pchrFolio` | `CHAR(16)` | — | — |
| `pmnyImporteOP` | `MONEY(18,2)` | — | — |
| `pintBancoRec` | `INTEGER` | — | — |
| `pvchrNombreBenef` | `VARCHAR(40)` | — | — |
| `pvchrCtaBenef` | `VARCHAR(20)` | — | — |
| `pvchrRFCBenef` | `VARCHAR(18)` | — | — |
| `pvchrNombreBenef2` | `VARCHAR(40)` | — | — |
| `pvchrCtaBenef2` | `VARCHAR(20)` | — | — |
| `pvchrRFCBenef2` | `VARCHAR(18)` | — | — |
| `pdtFechaValor` | `DATE` | — | — |
| `pvchrConceptoPago` | `VARCHAR(210)` | — | — |
| `pdecRefNum` | `DECIMAL(7,0)` | — | — |
| `pchrTrans` | `CHAR(4)` | — | — |
| `pintTipoPago` | `INTEGER` | — | — |
| `pintTipoOper` | `INTEGER` | — | — |
| `pchrCtaOrd` | `VARCHAR(20)` | — | — |
| `pvchrRefCobranza1` | `VARCHAR(40)` | — | — |
| `pchrClavePago` | `VARCHAR(10)` | — | — |
| `pchrNumCte` | `VARCHAR(20)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vchrcodret` | `CHAR(5)` | L63 |
| `vintcodret` | `INTEGER` | L64 |
| `vvchrCveRastreo` | `VARCHAR(30)` | L65 |
| `vdtfecha` | `DATE` | L66 |
| `cVarDataErr` | `CHAR(60)` | L67 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tblparametros` | `bdispei` | no | SELECT | L90 |
| `tblpago` | `bdispei` | no | UPDATE | L129 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_desc_ret` | `bdinteg` | ⚠️ sí | L94 |
| `sp_regordenpago` | `bdispei` | no | L101 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L88 | VALIDACIÓN_NULL | `if (pdtFechaValor is null) or (pdtFechaValor = '') then` |  |
| L92 | VALIDACIÓN_NULL | `IF (pdtFechaValor is null) or (pdtFechaValor = '') then` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `reg` | ACCION | registro | 🟡 INFERIDO | nombre_sp |
| `orden` | ENTIDAD | orden | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `spei` | PREFIJO | familia SPEI (pagos interbancarios) | ✅ CÓDIGO | nombre_sp, texto_cuerpo |

---

## `sp_regordenspei_exp1`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_sp_regordenspei_exp1.sql` |
| **LOC (1er CREATE)** | 146 |
| **Callgraph** | ✅ fan_in=0 / fan_out=2 |
| **Propósito inferido** | "registro orden (sufijo Exportar — SP genera/exporta archivo de salida)" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `genera` → `SELECT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=1 · INFERIDO=2 · SINTÉTICO=1 / 6 términos |

### Firma

```sql
CREATE PROCEDURE sp_regordenspei_exp1(
  pchrUsuario                  CHAR(8)
  pchrSucursal                 CHAR(4)
  pchrFolio                    CHAR(16)
  pmnyImporteOP                MONEY(18,2)
  pintBancoRec                 INTEGER
  pvchrNombreBenef             VARCHAR(40)
  pvchrCtaBenef                VARCHAR(20)
  pvchrRFCBenef                VARCHAR(18)
  pvchrNombreBenef2            VARCHAR(40)
  pvchrCtaBenef2               VARCHAR(20)
  pvchrRFCBenef2               VARCHAR(18)
  pdtFechaValor                DATE
  pvchrConceptoPago            VARCHAR(210)
  pdecRefNum                   DECIMAL(7,0)
  pchrTrans                    CHAR(4)
  pintTipoPago                 INTEGER
  pintTipoOper                 INTEGER
  pchrCtaOrd                   VARCHAR(20)
  pvchrRefCobranza1            VARCHAR(40)
  pchrClavePago                VARCHAR(10)
  pchrNumCte                   VARCHAR(20)
) RETURNING CHAR(5), CHAR(60), CHAR(30)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pchrUsuario` | `CHAR(8)` | — | — |
| `pchrSucursal` | `CHAR(4)` | — | — |
| `pchrFolio` | `CHAR(16)` | — | — |
| `pmnyImporteOP` | `MONEY(18,2)` | — | — |
| `pintBancoRec` | `INTEGER` | — | — |
| `pvchrNombreBenef` | `VARCHAR(40)` | — | — |
| `pvchrCtaBenef` | `VARCHAR(20)` | — | — |
| `pvchrRFCBenef` | `VARCHAR(18)` | — | — |
| `pvchrNombreBenef2` | `VARCHAR(40)` | — | — |
| `pvchrCtaBenef2` | `VARCHAR(20)` | — | — |
| `pvchrRFCBenef2` | `VARCHAR(18)` | — | — |
| `pdtFechaValor` | `DATE` | — | — |
| `pvchrConceptoPago` | `VARCHAR(210)` | — | — |
| `pdecRefNum` | `DECIMAL(7,0)` | — | — |
| `pchrTrans` | `CHAR(4)` | — | — |
| `pintTipoPago` | `INTEGER` | — | — |
| `pintTipoOper` | `INTEGER` | — | — |
| `pchrCtaOrd` | `VARCHAR(20)` | — | — |
| `pvchrRefCobranza1` | `VARCHAR(40)` | — | — |
| `pchrClavePago` | `VARCHAR(10)` | — | — |
| `pchrNumCte` | `VARCHAR(20)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vchrcodret` | `CHAR(5)` | L63 |
| `vintcodret` | `INTEGER` | L64 |
| `vvchrCveRastreo` | `VARCHAR(30)` | L65 |
| `vdtfecha` | `DATE` | L66 |
| `cVarDataErr` | `CHAR(60)` | L67 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tblparametros` | `bdispei` | no | SELECT | L90 |
| `tblpago` | `bdispei` | no | UPDATE | L129 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_desc_ret` | `bdinteg` | ⚠️ sí | L94 |
| `sp_regordenpago` | `bdispei` | no | L101 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L88 | VALIDACIÓN_NULL | `if (pdtFechaValor is null) or (pdtFechaValor = '') then` |  |
| L92 | VALIDACIÓN_NULL | `IF (pdtFechaValor is null) or (pdtFechaValor = '') then` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `reg` | ACCION | registro | 🟡 INFERIDO | nombre_sp |
| `orden` | ENTIDAD | orden | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `spei` | PREFIJO | familia SPEI (pagos interbancarios) | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `exp` | MODIF | sufijo Exportar — SP genera/exporta archivo de salida (sp_*_ | 🟡 INFERIDO | nombre_sp |
| `?1` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?1` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_reinicia_idsign_spei`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_sp_reinicia_idsign_spei.sql` |
| **LOC (1er CREATE)** | 142 |
| **Callgraph** | ✅ fan_in=0 / fan_out=6 |
| **Deps concatenadas** | 1 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "reinicia identificador" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 4 tabla(s) con operaciones: SELECT, UPDATE |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=1 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_reinicia_idsign_spei(
) RETURNING CHAR(5) AS CodigoRetorno, CHAR(160) AS mensaje
```

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vCodigoRetorno` | `CHAR(5)` | L6 |
| `vMensaje` | `CHAR(160)` | L7 |
| `RUTA` | `VARCHAR(50)` | L8 |
| `vExecuteSQL` | `LVARCHAR(1000)` | L10 |
| `SQLERR` | `INTEGER` | L11 |
| `ISAM_ERR` | `INTEGER` | L12 |
| `ERROR_INFO` | `VARCHAR(80)` | L13 |
| `vsval_spei` | `INTEGER` | L15 |
| `vsvalor` | `VARCHAR(1)` | L16 |
| `vsfecha` | `DATE` | L17 |
| `vs_sec_a` | `INTEGER` | L18 |
| `vs_sec_b` | `INTEGER` | L19 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tblparametros` | `bdispei` | no | SELECT | L64 |
| `td_control_reinicio_spei` | `bdispei` | no | SELECT | L74 |
| `td_control_reinicio_spei` | `bdispei` | no | UPDATE | L78 |
| `secsigns` | `bdispei` | no | SELECT | L82 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `reinicia` | ACCION | reinicia / resetea | 🔵 CONVENCIÓN | nombre_sp |
| `id` | ENTIDAD | identificador (de) | 🔵 CONVENCIÓN | nombre_sp |
| `?sign_` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `spei` | PREFIJO | familia SPEI (pagos interbancarios) | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?sign_` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_stscodiapp`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_sp_stscodiapp.sql` |
| **LOC (1er CREATE)** | 219 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 1 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "(canal app) · CoDi — Cobro Digital" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 1 tabla(s) con operaciones: INSERT |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=1 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_stscodiapp(
  vchridtpa                    CHAR(2)
) RETURNING char(5)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `vchridtpa` | `CHAR(2)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vcodret` | `char(5)` | L22 |
| `vcodret2` | `char(5)` | L23 |
| `vcodret3` | `char(50)` | L24 |
| `sql_err` | `integer` | L25 |
| `isam_err` | `integer` | L26 |
| `desc_err` | `char(80)` | L27 |
| `vchrcode` | `CHAR(2)` | L29 |
| `vchrfchfinpro` | `CHAR(23)` | L30 |
| `vchrcvespeienva` | `CHAR(5)` | L31 |
| `vchrfchenvpro` | `CHAR(23)` | L32 |
| `vtimestamp` | `CHAR(13)` | L33 |
| `longctaord` | `INTEGER` | L34 |
| `longctaben` | `INTEGER` | L35 |
| `wmnyimpo` | `CHAR(1)` | L36 |
| `ret` | `INTEGER` | L38 |
| `wvchrfirma` | `CHAR(512)` | L39 |
| `wchrcadena_00` | `CHAR(3000)` | L40 |
| `wchrcadena_01` | `CHAR(200)` | L41 |
| `wchrcadena_02` | `CHAR(200)` | L42 |
| `wchrcadena_03` | `CHAR(200)` | L43 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tbl_stsprocodi` | `bdispei` | no | INSERT | L204 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L46 | CÓDIGO_RETORNO | `LET vcodret  = '00000';` |  |
| L91 | VALIDACIÓN_NULL | `IF (vchridtpa is null OR vchridtpa = '')   OR` |  |
| L111 | VALIDACIÓN_NULL | `IF vchrconcepto IS NULL OR vchrconcepto = '' THEN` |  |
| L115 | VALIDACIÓN_NULL | `IF vchrfchmjc IS NULL OR vchrfchmjc = ',' THEN --- solo pruebas quitarr este if` |  |
| L119 | VALIDACIÓN_NULL | `IF vchrcveras IS NULL OR vchrcveras = '' THEN` |  |
| L123 | VALIDACIÓN_NULL | `IF vchrrefnum IS NULL OR vchrrefnum = '' OR vchrrefnum = '-'  OR vchrrefnum = 'null'  OR vchrrefnum ` |  |
| L127 | VALIDACIÓN_NULL | `IF vchrcelord IS NULL OR vchrcelord = '' THEN` |  |
| L131 | VALIDACIÓN_NULL | `IF vchrdiveord IS NULL OR vchrdiveord = '' THEN` |  |
| L135 | VALIDACIÓN_NULL | `IF vchrbancoord IS NULL  THEN` |  |
| L139 | VALIDACIÓN_NULL | `IF vchrtpoctaord IS NULL OR vchrtpoctaord = '' THEN` |  |
| L143 | VALIDACIÓN_NULL | `IF vchrctaord IS NULL OR vchrctaord = '' THEN` |  |
| L147 | VALIDACIÓN_NULL | `IF vchrnomord IS NULL OR vchrnomord = '' THEN` |  |
| L151 | VALIDACIÓN_NULL | `IF vchrcelbenf IS NULL OR vchrcelbenf = '' THEN` |  |
| L155 | VALIDACIÓN_NULL | `IF vchrdivebenf IS NULL OR vchrdivebenf = '' THEN` |  |
| L159 | VALIDACIÓN_NULL | `IF vchrbancobenf IS NULL  THEN` |  |
| L163 | VALIDACIÓN_NULL | `IF vchrtpoctabenf IS NULL OR vchrtpoctabenf = '' THEN` |  |
| L167 | VALIDACIÓN_NULL | `IF vchrctabenf IS NULL OR vchrctabenf = '' THEN` |  |
| L171 | VALIDACIÓN_NULL | `IF vhrnombenf IS NULL OR vhrnombenf = '' THEN` |  |
| L178 | FÓRMULA | `LET vtimestamp  = dbinfo('utc_current') * 1000;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `?_sts` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `codi` | REG | CoDi — Cobro Digital (Banxico) | 🔵 CONVENCIÓN | nombre_sp |
| `app` | MODIF | canal app | 🔵 CONVENCIÓN | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_sts` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_tblhistpago_new2024`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_sp_tblhistpago_new2024.sql` |
| **LOC (1er CREATE)** | 94 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "tbl — tabla y pago (histórico/historial)" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 2 tabla(s) con operaciones: SELECT, DELETE |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=3 · INFERIDO=1 · SINTÉTICO=1 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_tblhistpago_new2024(
) RETURNING CHAR(5), INTEGER, INTEGER, INTEGER
```

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vcodret1` | `CHAR(5)` | L3 |
| `vcodret2` | `CHAR(5)` | L4 |
| `vcodret3` | `CHAR(50)` | L5 |
| `sql_err` | `INTEGER` | L6 |
| `isam_err` | `INTEGER` | L7 |
| `desc_err` | `CHAR(50)` | L8 |
| `vcomienza` | `SMALLINT` | L9 |
| `vcontador1` | `INTEGER` | L10 |
| `vcontador2` | `INTEGER` | L11 |
| `vcontador3` | `INTEGER` | L12 |
| `vtransaccion` | `INTEGER` | L13 |
| `vregistros` | `INTEGER` | L14 |
| `vnum_serial` | `INTEGER` | L15 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tblhistpago_new2024` | `bdispei` | no | SELECT | L53 |
| `tblhistpago_new2024` | `bdispei` | no | DELETE | L71 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L23 | FÓRMULA | `LET vcomienza       = -1;` |  |
| L69 | FÓRMULA | `LET vcontador1 = vcontador1 + 1;` |  |
| L76 | FÓRMULA | `LET vcontador2 = vcontador2 + 1;` |  |
| L79 | FÓRMULA | `LET vcontador3 = vcontador3 + 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `tbl` | ENTIDAD | tbl — tabla (abreviación — sp_depura_tbl_registro_msj) | 🟡 INFERIDO | nombre_sp |
| `hist` | MODIF | histórico/historial | 🔵 CONVENCIÓN | nombre_sp |
| `pago` | ENTIDAD | pago | 🔵 CONVENCIÓN | nombre_sp |
| `?_new2024` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_new2024` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_valida_operaciones_spei`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_sp_valida_operaciones_spei.sql` |
| **LOC (1er CREATE)** | 61 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "valida operaciones" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `valida` → `IF` encontrado en el cuerpo · `valida` → `RETURN` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=4 · INFERIDO=0 · SINTÉTICO=0 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_valida_operaciones_spei(
) RETURNING char(5), integer, integer
```

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vcodret` | `char(5)` | L4 |
| `vsqlerr` | `integer` | L5 |
| `vcantidad_op` | `integer` | L7 |
| `vultopreal` | `integer` | L8 |
| `vtotopreal` | `integer` | L9 |
| `vdifopreal` | `integer` | L10 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tblparametros` | `bdispei` | no | SELECT | L34 |
| `tblpago` | `bdispei` | no | SELECT | L43 |
| `tblparametros` | `bdispei` | no | UPDATE | L54 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L48 | FÓRMULA | `let vdifopreal = vtotopreal - vultopreal;` |  |
| L51 | CÓDIGO_RETORNO | `let vcodret = '00001';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `valida` | ACCION | valida | 🔵 CONVENCIÓN | nombre_sp |
| `operaciones` | ENTIDAD | operaciones (plural) | 🔵 CONVENCIÓN | nombre_sp |
| `spei` | PREFIJO | familia SPEI (pagos interbancarios) | 🔵 CONVENCIÓN | nombre_sp |

---

## `sp_validadv`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_sp_validadv.sql` |
| **LOC (1er CREATE)** | 89 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "valida" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `valida` → `IF` encontrado en el cuerpo · `valida` → `RETURN` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=1 / 3 términos |

### Firma

```sql
CREATE PROCEDURE sp_validadv(
  chrccc                       char(18)
) RETURNING char(5), smallint
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `chrccc` | `char(18)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `intCodigoError` | `integer` | L9 |
| `strFuenteError` | `smallint` | L10 |
| `chrCCCvalido` | `char(18)` | L11 |
| `vintpond` | `integer` | L12 |
| `vintdigcontrol` | `integer` | L13 |
| `vintdigitocta` | `integer` | L14 |
| `i` | `integer` | L15 |
| `chrbanco` | `char(3)` | L16 |
| `chrplazatef` | `char(3)` | L17 |
| `intcontador` | `integer` | L18 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tblbancos` | `bdispei` | no | SELECT | L49 |
| `tblplazas` | `bdispei` | no | SELECT | L55 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L66 | FÓRMULA | `let vintdigitocta = substr(chrCCCValido, i, 1)*vintpond;` |  |
| L67 | FÓRMULA | `let vintDigControl = vintDigControl + mod(vintdigitocta,10);` | 🔴 MONEY/aritmética financiera |
| L76 | FÓRMULA | `let vintdigcontrol = 10 - mod(vintdigcontrol,10);` | 🔴 MONEY/aritmética financiera |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `valida` | ACCION | valida | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?dv` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?dv` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_validadv_web`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_sp_validadv_web.sql` |
| **LOC (1er CREATE)** | 93 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "valida (canal web)" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `valida` → `IF` encontrado en el cuerpo · `valida` → `RETURN` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=1 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_validadv_web(
  chrccc                       char(18)
) RETURNING char(5), smallint
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `chrccc` | `char(18)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `intCodigoError` | `integer` | L9 |
| `strFuenteError` | `smallint` | L10 |
| `chrCCCvalido` | `char(18)` | L11 |
| `vintpond` | `integer` | L12 |
| `vintdigcontrol` | `integer` | L13 |
| `vintdigitocta` | `integer` | L14 |
| `i` | `integer` | L15 |
| `chrbanco` | `char(3)` | L16 |
| `chrplazatef` | `char(3)` | L17 |
| `intcontador` | `integer` | L18 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tblbancos` | `bdispei` | no | SELECT | L48 |
| `tblplazas` | `bdispei` | no | SELECT | L54 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L65 | FÓRMULA | `let vintdigitocta = substr(chrCCCValido, i, 1)*vintpond;` |  |
| L66 | FÓRMULA | `let vintDigControl = vintDigControl + mod(vintdigitocta,10);` | 🔴 MONEY/aritmética financiera |
| L75 | FÓRMULA | `let vintdigcontrol = 10 - mod(vintdigcontrol,10);` | 🔴 MONEY/aritmética financiera |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `valida` | ACCION | valida | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?dv_` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `web` | MODIF | canal web | 🔵 CONVENCIÓN | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?dv_` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_validaspei_bpi`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_sp_validaspei_bpi.sql` |
| **LOC (1er CREATE)** | 72 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "valida (Banca Por Internet)" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `valida` → `IF` encontrado en el cuerpo · `valida` → `RETURN` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=4 · INFERIDO=0 · SINTÉTICO=0 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_validaspei_bpi(
  pCtaOrigen                   VARCHAR(20)
  pCtaDestino                  VARCHAR(20)
) RETURNING char(3), varchar(100)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pCtaOrigen` | `VARCHAR(20)` | — | — |
| `pCtaDestino` | `VARCHAR(20)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cod_ret` | `char(3)` | L6 |
| `sql_err` | `integer` | L7 |
| `com_err` | `varchar(100)` | L8 |
| `vCteOrigen` | `varchar(9)` | L9 |
| `vCteDestino` | `varchar(9)` | L10 |
| `vStatusCtaOr` | `varchar(2)` | L11 |
| `cCtaDestino` | `integer` | L12 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sc_maechq` | `bdicheq` | ⚠️ sí | SELECT | L33 |
| `pp_ctasterceros` | `bdiprog` | ⚠️ sí | SELECT | L39 |
| `si_bpinusuales` | `bdinteg` | ⚠️ sí | INSERT | L49 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `valida` | ACCION | valida | 🔵 CONVENCIÓN | nombre_sp |
| `spei` | PREFIJO | familia SPEI (pagos interbancarios) | 🔵 CONVENCIÓN | nombre_sp |
| `bpi` | MODIF | Banca Por Internet (canal web BPI) | 🔵 CONVENCIÓN | nombre_sp |

---

## `sp_valnvoestatus`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_sp_valnvoestatus.sql` |
| **LOC (1er CREATE)** | 64 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "estatus" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 4 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=1 / 3 términos |

### Firma

```sql
CREATE PROCEDURE sp_valnvoestatus(
  pintPkPago                   INTEGER
  pchrNvoEstatus               CHAR
  pchrTipo                     CHAR
) RETURNING CHAR(5)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pintPkPago` | `INTEGER` | — | — |
| `pchrNvoEstatus` | `CHAR` | `estatus`=estatus | ✅ CÓDIGO |
| `pchrTipo` | `CHAR` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `codret` | `CHAR(5)` | L4 |
| `sql_err` | `INTEGER` | L5 |
| `vintPkPaqueteEnv` | `INTEGER` | L6 |
| `intCesifPago` | `INTEGER` | L7 |
| `chrFolioErr` | `CHAR(18)` | L8 |
| `intFolioErr` | `INTEGER` | L9 |
| `vdtFechaOp` | `DATE` | L10 |
| `chrEstatusPago` | `char` | L11 |
| `intValido` | `INTEGER` | L12 |
| `vchrSentido` | `CHAR(1)` | L13 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tblparametros` | `bdispei` | no | SELECT | L29 |
| `tblpago` | `bdispei` | no | SELECT | L35 |
| `tbltraspaso` | `bdispei` | no | SELECT | L40 |
| `tblflujoestatus` | `bdispei` | no | SELECT | L50 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L45 | VALIDACIÓN_NULL | `IF chrEstatusPago is NULL or chrEstatusPago = '' THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `?_valnvo` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `estatus` | ENTIDAD | estatus | ✅ CÓDIGO | nombre_sp, texto_cuerpo |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_valnvo` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `spei_actparticipante`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_spei_actparticipante.sql` |
| **LOC (1er CREATE)** | 73 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "actualiza (anterior)" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `actualiza` → `UPDATE` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=2 / 5 términos |

### Firma

```sql
CREATE PROCEDURE spei_actparticipante(
  pclavebco                    INTEGER
) RETURNING CHAR(5)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pclavebco` | `INTEGER` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vCodRet1` | `CHAR(5)` | L7 |
| `vCodRet2` | `CHAR(5)` | L8 |
| `vSqlErr` | `INTEGER` | L9 |
| `vIsamErr` | `INTEGER` | L10 |
| `vexiste_tblbanco` | `integer` | L11 |
| `vexiste_sibanco` | `CHAR(1)` | L12 |
| `wintindice` | `INTEGER` | L13 |
| `vbanco` | `CHAR(5)` | L14 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tblbanco` | `bdispei` | no | SELECT | L52 |
| `tblbanco` | `bdispei` | no | INSERT | L64 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L43 | VALIDACIÓN_NULL | `IF (pclavebco IS NULL OR pclavebco = '') OR` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `spei` | PREFIJO | familia SPEI (pagos interbancarios) | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `act` | ACCION | actualiza | 🔵 CONVENCIÓN | nombre_sp |
| `?particip` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `ant` | MODIF | anterior | 🔵 CONVENCIÓN | nombre_sp |
| `?e` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?particip`, `?e` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `spei_actualiza_estatus`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_spei_actualiza_estatus.sql` |
| **LOC (1er CREATE)** | 89 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "actualiza estatus" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `actualiza` → `UPDATE` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=0 / 3 términos |

### Firma

```sql
CREATE PROCEDURE spei_actualiza_estatus(
  pRegistros                   INTEGER
  pCantidad                    DECIMAL(14,2)
) RETURNING CHAR(5), INTEGER, INTEGER
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pRegistros` | `INTEGER` | — | — |
| `pCantidad` | `DECIMAL(14,2)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `Sql_Err` | `INTEGER` | L4 |
| `Isam_Err` | `INTEGER` | L5 |
| `Desc_Err` | `CHAR(50)` | L6 |
| `vCodRet1` | `CHAR(5)` | L7 |
| `vCodRet2` | `CHAR(5)` | L8 |
| `vCodRet3` | `CHAR(50)` | L9 |
| `vContador1` | `INTEGER` | L10 |
| `vContador2` | `INTEGER` | L11 |
| `vContador3` | `INTEGER` | L12 |
| `vComienza` | `SMALLINT` | L13 |
| `vAbierto` | `CHAR(1)` | L14 |
| `vcverastreo` | `CHAR(30)` | L15 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tblpago` | `bdispei` | no | SELECT | L57 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L26 | FÓRMULA | `LET vComienza   = -1;` |  |
| L73 | FÓRMULA | `LET vcontador3 = vcontador3 + 1;` |  |
| L76 | FÓRMULA | `LET vcontador1 = vcontador1 + 1;` |  |
| L77 | FÓRMULA | `LET vcontador2 = vcontador2 + 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `spei` | PREFIJO | familia SPEI (pagos interbancarios) | 🔵 CONVENCIÓN | nombre_sp |
| `actualiza` | ACCION | actualiza | 🔵 CONVENCIÓN | nombre_sp |
| `estatus` | ENTIDAD | estatus | 🔵 CONVENCIÓN | nombre_sp |

---

## `spei_actualizamovspeich`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_spei_actualizamovspeich.sql` |
| **LOC (1er CREATE)** | 271 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 1 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "actualiza movimientos" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `actualiza` → `UPDATE` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=1 · INFERIDO=1 · SINTÉTICO=1 / 4 términos |

### Firma

```sql
CREATE PROCEDURE spei_actualizamovspeich(
  pfechaejecuta                date
) RETURNING char(5),char(100)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pfechaejecuta` | `date` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vsql_err` | `integer` | L3 |
| `visam_err` | `integer` | L4 |
| `vcodret` | `char (10)` | L5 |
| `vcodret2` | `char (100)` | L6 |
| `vestadoctrl` | `char(1)` | L7 |
| `vsql` | `char(250)` | L8 |
| `vmes` | `Char(2)` | L9 |
| `vdia` | `Char(2)` | L10 |
| `vanio` | `char(4)` | L11 |
| `vfechaarch` | `char(8)` | L12 |
| `vstmt` | `char(150)` | L13 |
| `vfecha` | `date` | L14 |
| `vclave` | `varchar(30)` | L15 |
| `vmedio` | `integer` | L16 |
| `vusuario` | `varchar(50)` | L17 |
| `vusaut` | `varchar(50)` | L18 |
| `vuscan` | `varchar(50)` | L19 |
| `vhora_cap` | `datetime year to second` | L20 |
| `vhoraliq` | `datetime year to second` | L21 |
| `vhora_dev` | `datetime year to second` | L22 |
| `vchnumcelord` | `char(10)` | L23 |
| `vchnumcelben` | `char(20)` | L24 |
| `vchdigidord` | `char(3)` | L25 |
| `vchdigidben` | `char(3)` | L26 |
| `vchfechalimpago` | `char(16)` | L27 |
| *…11 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `spei_mov_det_re_proceso` | `bdispei` | no | INSERT | L82 |
| `sc_fechas` | `bdicheq` | ⚠️ sí | SELECT | L100 |
| `tblctrlproceso` | `bdispei` | no | SELECT | L107 |
| `tblctrlproceso` | `bdispei` | no | DELETE | L142 |
| `tblctrlproceso` | `bdispei` | no | INSERT | L143 |
| `systabnames` | `sysmaster` | ⚠️ sí | SELECT | L146 |
| `tblhistpagoactuali_temp` | `bdispei` | no | INSERT | L189 |
| `tblhistpagoactuali_temp` | `bdispei` | no | SELECT | L214 |
| `tblhistpago` | `bdispei` | no | UPDATE | L222 |
| `tblctrlproceso` | `bdispei` | no | UPDATE | L242 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L65 | FÓRMULA | `let vComienza = -1;` |  |
| L123 | VALIDACIÓN_NULL | `IF (pfechaejecuta is null) or (pfechaejecuta = '') then` |  |
| L141 | VALIDACIÓN_NULL | `IF (vestadoctrl IS NULL) OR (vestadoctrl = '') OR (vestadoctrl = '0') THEN` |  |
| L189 | FÓRMULA | `let vsql='echo "load from /home/sysspei/DetSPEICH'\|\|vfechaarch\|\|'.txt insert into tblhistpagoact` |  |
| L192 | FÓRMULA | `let vstmt='dbaccess bdispei /home/sysspei/query.sql';` |  |
| L227 | FÓRMULA | `LET vcontador1 = vcontador1 + 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `spei` | PREFIJO | familia SPEI (pagos interbancarios) | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `actualiza` | ACCION | actualiza | 🔵 CONVENCIÓN | nombre_sp |
| `movs` | ENTIDAD | movimientos (abreviación) | 🟡 INFERIDO | nombre_sp |
| `?peich` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?peich` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `spei_actualizamovspeich_2`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_spei_actualizamovspeich_2.sql` |
| **LOC (1er CREATE)** | 244 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "actualiza movimientos" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `actualiza` → `UPDATE` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=2 · INFERIDO=1 · SINTÉTICO=1 / 4 términos |

### Firma

```sql
CREATE PROCEDURE spei_actualizamovspeich_2(
  pfechaejecuta_var            varchar(15)
) RETURNING char(5),char(100)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pfechaejecuta_var` | `varchar(15)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vsql_err` | `integer` | L3 |
| `visam_err` | `integer` | L4 |
| `vcodret` | `char (10)` | L5 |
| `vcodret2` | `char (100)` | L6 |
| `vestadoctrl` | `char(1)` | L7 |
| `vsql` | `char(250)` | L8 |
| `vmes` | `Char(2)` | L9 |
| `vdia` | `Char(2)` | L10 |
| `vanio` | `char(4)` | L11 |
| `vfechaarch` | `char(8)` | L12 |
| `vstmt` | `char(150)` | L13 |
| `vfecha` | `date` | L14 |
| `vclave` | `varchar(30)` | L15 |
| `vmedio` | `integer` | L16 |
| `vusuario` | `varchar(50)` | L17 |
| `vusaut` | `varchar(50)` | L18 |
| `vuscan` | `varchar(50)` | L19 |
| `vhora_cap` | `datetime year to second` | L20 |
| `vhoraliq` | `datetime year to second` | L21 |
| `vhora_dev` | `datetime year to second` | L22 |
| `vchnumcelord` | `char(10)` | L23 |
| `vchnumcelben` | `char(20)` | L24 |
| `vchdigidord` | `char(3)` | L25 |
| `vchdigidben` | `char(3)` | L26 |
| `vchfechalimpago` | `char(16)` | L27 |
| *…11 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sc_fechas` | `bdicheq` | ⚠️ sí | SELECT | L95 |
| `tblctrlproceso` | `bdispei` | no | SELECT | L112 |
| `tblctrlproceso` | `bdispei` | no | DELETE | L127 |
| `tblctrlproceso` | `bdispei` | no | INSERT | L128 |
| `systabnames` | `sysmaster` | ⚠️ sí | SELECT | L133 |
| `tblhistpagoactuali_temp` | `bdispei` | no | INSERT | L175 |
| `tblhistpagoactuali_temp` | `bdispei` | no | SELECT | L198 |
| `tblhistpago` | `bdispei` | no | UPDATE | L207 |
| `tblctrlproceso` | `bdispei` | no | UPDATE | L229 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L65 | FÓRMULA | `let vComienza = -1;` |  |
| L98 | FÓRMULA | `LET pfechaejecuta = to_date(pfechaejecuta_var,'%Y/%m/%d' ); --se ejecuta para prueba controlada` |  |
| L101 | VALIDACIÓN_NULL | `IF (pfechaejecuta is null) or (pfechaejecuta = '') then` |  |
| L124 | VALIDACIÓN_NULL | `IF (vestadoctrl IS NULL) OR (vestadoctrl = '') OR (vestadoctrl = '0') THEN` |  |
| L175 | FÓRMULA | `let vsql='echo "load from /home/sysspei/DetSPEICH'\|\|vfechaarch\|\|'.txt insert into tblhistpagoact` |  |
| L178 | FÓRMULA | `let vstmt='dbaccess bdispei /home/sysspei/query.sql';` |  |
| L212 | FÓRMULA | `LET vcontador1 = vcontador1 + 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `spei` | PREFIJO | familia SPEI (pagos interbancarios) | 🔵 CONVENCIÓN | nombre_sp |
| `actualiza` | ACCION | actualiza | 🔵 CONVENCIÓN | nombre_sp |
| `movs` | ENTIDAD | movimientos (abreviación) | 🟡 INFERIDO | nombre_sp |
| `?peich_2` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?peich_2` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `spei_actualizamovspeich_esp`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_spei_actualizamovspeich_esp.sql` |
| **LOC (1er CREATE)** | 185 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "actualiza movimientos (especial)" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `actualiza` → `UPDATE` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=3 · INFERIDO=1 · SINTÉTICO=1 / 5 términos |

### Firma

```sql
CREATE PROCEDURE spei_actualizamovspeich_esp(
  pfechaejecuta                date
) RETURNING char(5),char(100)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pfechaejecuta` | `date` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vsql_err` | `integer` | L4 |
| `visam_err` | `integer` | L5 |
| `vcodret` | `char (10)` | L6 |
| `vcodret2` | `char (100)` | L7 |
| `vestadoctrl` | `char(1)` | L8 |
| `vsql` | `char(150)` | L9 |
| `vmes` | `Char(2)` | L10 |
| `vdia` | `Char(2)` | L11 |
| `vanio` | `char(4)` | L12 |
| `vfechaarch` | `char(8)` | L13 |
| `vstmt` | `char(150)` | L14 |
| `vfecha` | `date` | L15 |
| `vclave` | `varchar(30)` | L16 |
| `vmedio` | `integer` | L17 |
| `vusuario` | `varchar(50)` | L18 |
| `vusaut` | `varchar(50)` | L19 |
| `vuscan` | `varchar(50)` | L20 |
| `vhora_cap` | `datetime year to second` | L21 |
| `vhoraliq` | `datetime year to second` | L22 |
| `vhora_dev` | `datetime year to second` | L23 |
| `vchnumcelord` | `char(10)` | L24 |
| `vchnumcelben` | `char(20)` | L25 |
| `vchdigidord` | `char(3)` | L26 |
| `vchdigidben` | `char(3)` | L27 |
| `vchfechalimpago` | `char(16)` | L28 |
| *…7 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tblctrlproceso` | `bdispei` | no | SELECT | L88 |
| `tblctrlproceso` | `bdispei` | no | DELETE | L98 |
| `tblctrlproceso` | `bdispei` | no | INSERT | L102 |
| `systabnames` | `sysmaster` | ⚠️ sí | SELECT | L107 |
| `tblhistpagoactuali_temp` | `bdispei` | no | INSERT | L145 |
| `tblhistpagoactuali_temp` | `bdispei` | no | SELECT | L156 |
| `tblhistpago` | `bdispei` | no | UPDATE | L158 |
| `tblctrlproceso` | `bdispei` | no | UPDATE | L170 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L79 | VALIDACIÓN_NULL | `IF (pfechaejecuta is null) or (pfechaejecuta = '') then` |  |
| L97 | VALIDACIÓN_NULL | `IF (vestadoctrl IS NULL) OR (vestadoctrl = '') OR (vestadoctrl = '0') THEN` |  |
| L145 | FÓRMULA | `let vsql='echo "load from /home/sysspei/DetSPEICH'\|\|vfechaarch\|\|'.txt insert into tblhistpagoact` |  |
| L148 | FÓRMULA | `let vstmt='dbaccess bdispei /home/sysspei/query.sql';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `spei` | PREFIJO | familia SPEI (pagos interbancarios) | 🔵 CONVENCIÓN | nombre_sp |
| `actualiza` | ACCION | actualiza | 🔵 CONVENCIÓN | nombre_sp |
| `movs` | ENTIDAD | movimientos (abreviación) | 🟡 INFERIDO | nombre_sp |
| `?peich_` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `esp` | MODIF | especial | 🔵 CONVENCIÓN | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?peich_` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `spei_actualizamovspeich_tmp`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_spei_actualizamovspeich_tmp.sql` |
| **LOC (1er CREATE)** | 100 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "actualiza movimientos" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `actualiza` → `UPDATE` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=2 · INFERIDO=1 · SINTÉTICO=1 / 4 términos |

### Firma

```sql
CREATE PROCEDURE spei_actualizamovspeich_tmp(
) RETURNING char(5),char(100)
```

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vsql_err` | `integer` | L3 |
| `visam_err` | `integer` | L4 |
| `vcodret` | `char (10)` | L5 |
| `vcodret2` | `char (100)` | L6 |
| `vestadoctrl` | `char(1)` | L7 |
| `vsql` | `char(150)` | L8 |
| `vmes` | `Char(2)` | L9 |
| `vdia` | `Char(2)` | L10 |
| `vanio` | `char(4)` | L11 |
| `vfechaarch` | `char(8)` | L12 |
| `vstmt` | `char(150)` | L13 |
| `vfecha` | `date` | L14 |
| `vclave` | `varchar(30)` | L15 |
| `vmedio` | `integer` | L16 |
| `vusuario` | `varchar(50)` | L17 |
| `vusaut` | `varchar(50)` | L18 |
| `vuscan` | `varchar(50)` | L19 |
| `vhora_cap` | `datetime year to second` | L20 |
| `vhoraliq` | `datetime year to second` | L21 |
| `vhora_dev` | `datetime year to second` | L22 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `systabnames` | `sysmaster` | ⚠️ sí | SELECT | L59 |
| `tblhistpagoactuali_temp` | `bdispei` | no | INSERT | L79 |
| `tblhistpagoactuali_temp` | `bdispei` | no | SELECT | L88 |
| `tblhistpago` | `bdispei` | no | UPDATE | L90 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L79 | FÓRMULA | `let vsql='echo "load from /resplogifx/conciliachq/DetSPEICH20150807.txt insert into tblhistpagoactua` |  |
| L82 | FÓRMULA | `let vstmt='dbaccess bdispei /resplogifx/conciliachq/query.sql';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `spei` | PREFIJO | familia SPEI (pagos interbancarios) | 🔵 CONVENCIÓN | nombre_sp |
| `actualiza` | ACCION | actualiza | 🔵 CONVENCIÓN | nombre_sp |
| `movs` | ENTIDAD | movimientos (abreviación) | 🟡 INFERIDO | nombre_sp |
| `?peich_tmp` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?peich_tmp` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `spei_apgbanope`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_spei_apgbanope.sql` |
| **LOC (1er CREATE)** | 70 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 2 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "operación" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 2 tabla(s) con operaciones: SELECT, UPDATE |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=0 · INFERIDO=1 · SINTÉTICO=1 / 3 términos |

### Firma

```sql
CREATE PROCEDURE spei_apgbanope(
) RETURNING CHAR(5), CHAR(100)
```

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `var_valor` | `CHAR(1)` | L9 |
| `vcodret` | `CHAR(5)` | L10 |
| `vSqlErr` | `INTEGER` | L11 |
| `isam_err` | `INTEGER` | L12 |
| `error_info` | `CHAR(100)` | L13 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tblparametros` | `bdispei` | no | SELECT | L40 |
| `tblparametros` | `bdispei` | no | UPDATE | L44 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L16 | CÓDIGO_RETORNO | `LET	vcodret = '00000';` |  |
| L46 | CÓDIGO_RETORNO | `LET vcodret = '00000';` |  |
| L50 | CÓDIGO_RETORNO | `LET vcodret = '01110';` |  |
| L54 | CÓDIGO_RETORNO | `LET vcodret = '11110';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `spei` | PREFIJO | familia SPEI (pagos interbancarios) | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?_apgban` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `ope` | ACCION | operación | 🟡 INFERIDO | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_apgban` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `spei_aplicaordenpago`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_spei_aplicaordenpago.sql` |
| **LOC (1er CREATE)** | 660 |
| **Callgraph** | ✅ fan_in=0 / fan_out=15 |
| **Deps concatenadas** | 7 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "aplica orden de pago" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 5 llamada(s): `sp_obtfoliosuc`, `abono_ref`, `spei_recerrorescodi` |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=0 / 2 términos |

### Firma

```sql
CREATE PROCEDURE spei_aplicaordenpago(
  pRegistros                   INTEGER
  pOrigen                      CHAR(1)
) RETURNING CHAR(5), INTEGER, INTEGER
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pRegistros` | `INTEGER` | — | — |
| `pOrigen` | `CHAR(1)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `iSqlErr` | `INTEGER` | L4 |
| `iIsamErr` | `INTEGER` | L5 |
| `cDescErr` | `CHAR(50)` | L6 |
| `cCodRet1` | `CHAR(5)` | L7 |
| `cCodRet2` | `CHAR(5)` | L8 |
| `cCodRet3` | `CHAR(50)` | L9 |
| `cCodRet4` | `CHAR(5)` | L10 |
| `cCodRet5` | `CHAR(5)` | L11 |
| `cCodRet6` | `CHAR(5)` | L12 |
| `cCodRet7` | `CHAR(5)` | L13 |
| `iContador1` | `INTEGER` | L14 |
| `iContador2` | `INTEGER` | L15 |
| `iComienza` | `SMALLINT` | L16 |
| `iAbierto` | `SMALLINT` | L17 |
| `cDisponible` | `CHAR(1)` | L18 |
| `cStatusProc` | `CHAR(1)` | L19 |
| `cCveRastreo` | `CHAR(30)` | L20 |
| `cCuenta` | `CHAR(20)` | L21 |
| `mMonto` | `DECIMAL(14,2)` | L22 |
| `dFechaVal` | `DATE` | L23 |
| `cCtaBenef` | `CHAR(20)` | L24 |
| `cNumCte` | `CHAR(20)` | L25 |
| `cCtaBenefEmail` | `CHAR(20)` | L26 |
| `cTpoCtaBenefMsg` | `CHAR(25)` | L27 |
| `cTransacc` | `CHAR(4)` | L28 |
| *…43 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tblctrlproceso` | `bdispei` | no | UPDATE | L161 |
| `tblctrlproceso` | `bdispei` | no | SELECT | L194 |
| `sc_fechas` | `bdicheq` | ⚠️ sí | SELECT | L246 |
| `tblabono` | `bdispei` | no | SELECT | L265 |
| `sc_movdia` | `bdicheq` | ⚠️ sí | SELECT | L339 |
| `sc_param` | `bdicheq` | ⚠️ sí | SELECT | L398 |
| `sc_creditohipotecario` | `bdicheq` | ⚠️ sí | UPDATE | L441 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_obtfoliosuc` | `bdispei` | no | L389 |
| `abono_ref` | `bdicheq` | ⚠️ sí | L420 |
| `spei_recerrorescodi` | `bdispei` | no | L452 |
| `sp_registra_evento` | `bdimnsj` | ⚠️ sí | L461 |
| `sp_registra_evento_tmp_spei` | `bdimnsj` | ⚠️ sí | L471 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L89 | FÓRMULA | `LET iComienza       = -1;` |  |
| L117 | FÓRMULA | `LET vtimestamp         = dbinfo('utc_current') * 1000;` |  |
| L249 | VALIDACIÓN_NULL | `IF cDisponible is null OR cDisponible = '' OR cDisponible = '0' THEN` |  |
| L272 | FÓRMULA | `LET iContador1 = iContador1 + 1;` |  |
| L355 | FÓRMULA | `LET iContador2 = iContador2 + 1;` |  |
| L388 | VALIDACIÓN_NULL | `IF cFolioSuc is null OR cFolioSuc = '' THEN` |  |
| L434 | FÓRMULA | `LET iContador2 = iContador2 + 1;` |  |
| L458 | FÓRMULA | `LET cCtaBenefMsg = SUBSTR(cCtaBenef,(LENGTH(cCtaBenef)-3),4);` |  |
| L499 | FÓRMULA | `LET iContador2 = iContador2 + 1;` |  |
| L512 | FÓRMULA | `LET iContador2 = iContador2 + 1;` |  |
| L531 | FÓRMULA | `LET iContador2 = iContador2 + 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `spei` | PREFIJO | familia SPEI (pagos interbancarios) | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `aplicaordenpago` | ACCION | aplica orden de pago | 🔵 CONVENCIÓN | nombre_sp |

---

## `spei_aplicaordenpago_comp`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_spei_aplicaordenpago_comp.sql` |
| **LOC (1er CREATE)** | 463 |
| **Callgraph** | ✅ fan_in=0 / fan_out=5 |
| **Propósito inferido** | "aplica orden de pago (complemento)" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 4 llamada(s): `sp_obtfoliosuc`, `abono_ref`, `spei_recerrorescodi` |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=0 / 3 términos |

### Firma

```sql
CREATE PROCEDURE spei_aplicaordenpago_comp(
  pRegistros                   INTEGER
  pOrigen                      CHAR(1)
) RETURNING CHAR(5), INTEGER, INTEGER
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pRegistros` | `INTEGER` | — | — |
| `pOrigen` | `CHAR(1)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `iSqlErr` | `INTEGER` | L4 |
| `iIsamErr` | `INTEGER` | L5 |
| `cDescErr` | `CHAR(50)` | L6 |
| `cCodRet1` | `CHAR(5)` | L7 |
| `cCodRet2` | `CHAR(5)` | L8 |
| `cCodRet3` | `CHAR(50)` | L9 |
| `cCodRet4` | `CHAR(5)` | L10 |
| `cCodRet5` | `CHAR(5)` | L11 |
| `cCodRet6` | `CHAR(5)` | L12 |
| `cCodRet7` | `CHAR(5)` | L13 |
| `iContador1` | `INTEGER` | L14 |
| `iContador2` | `INTEGER` | L15 |
| `iComienza` | `SMALLINT` | L16 |
| `iAbierto` | `SMALLINT` | L17 |
| `cDisponible` | `CHAR(1)` | L18 |
| `cStatusProc` | `CHAR(1)` | L19 |
| `cCveRastreo` | `CHAR(30)` | L20 |
| `cCuenta` | `CHAR(20)` | L21 |
| `mMonto` | `DECIMAL(14,2)` | L22 |
| `dFechaVal` | `DATE` | L23 |
| `cCtaBenef` | `CHAR(20)` | L24 |
| `cNumCte` | `CHAR(20)` | L25 |
| `cCtaBenefEmail` | `CHAR(20)` | L26 |
| `cTpoCtaBenefMsg` | `CHAR(25)` | L27 |
| `cTransacc` | `CHAR(4)` | L28 |
| *…38 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tblctrlproceso` | `bdispei` | no | SELECT | L163 |
| `tblctrlproceso` | `bdispei` | no | UPDATE | L168 |
| `sc_fechas` | `bdicheq` | ⚠️ sí | SELECT | L174 |
| `tblabono` | `bdispei` | no | SELECT | L193 |
| `sc_movdia` | `bdicheq` | ⚠️ sí | SELECT | L265 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_obtfoliosuc` | `bdispei` | no | L291 |
| `abono_ref` | `bdicheq` | ⚠️ sí | L299 |
| `spei_recerrorescodi` | `bdispei` | no | L317 |
| `sp_registra_evento` | `bdimnsj` | ⚠️ sí | L326 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L82 | FÓRMULA | `LET iComienza       = -1;` |  |
| L110 | FÓRMULA | `LET vtimestamp         = dbinfo('utc_current') * 1000;` |  |
| L177 | VALIDACIÓN_NULL | `IF cDisponible is null OR cDisponible = '' OR cDisponible = '0' THEN` |  |
| L200 | FÓRMULA | `LET iContador1 = iContador1 + 1;` |  |
| L281 | FÓRMULA | `LET iContador2 = iContador2 + 1;` |  |
| L290 | VALIDACIÓN_NULL | `IF cFolioSuc is null OR cFolioSuc = '' THEN` |  |
| L313 | FÓRMULA | `LET iContador2 = iContador2 + 1;` |  |
| L323 | FÓRMULA | `LET cCtaBenefMsg = SUBSTR(cCtaBenef,(LENGTH(cCtaBenef)-3),4);` |  |
| L350 | FÓRMULA | `LET iContador2 = iContador2 + 1;` |  |
| L363 | FÓRMULA | `LET iContador2 = iContador2 + 1;` |  |
| L382 | FÓRMULA | `LET iContador2 = iContador2 + 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `spei` | PREFIJO | familia SPEI (pagos interbancarios) | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `aplicaordenpago` | ACCION | aplica orden de pago | 🔵 CONVENCIÓN | nombre_sp |
| `comp` | MODIF | complemento | 🔵 CONVENCIÓN | nombre_sp |

---

## `spei_aplicaordenpago_dos`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_spei_aplicaordenpago_dos.sql` |
| **LOC (1er CREATE)** | 572 |
| **Callgraph** | ✅ fan_in=0 / fan_out=6 |
| **Propósito inferido** | "aplica orden de pago" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 5 llamada(s): `sp_obtfoliosuc`, `abono_ref`, `spei_recerrorescodi` |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=1 / 3 términos |

### Firma

```sql
CREATE PROCEDURE spei_aplicaordenpago_dos(
  pRegistros                   INTEGER
  pOrigen                      CHAR(1)
) RETURNING CHAR(5), INTEGER, INTEGER
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pRegistros` | `INTEGER` | — | — |
| `pOrigen` | `CHAR(1)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `iSqlErr` | `INTEGER` | L4 |
| `iIsamErr` | `INTEGER` | L5 |
| `cDescErr` | `CHAR(50)` | L6 |
| `cCodRet1` | `CHAR(5)` | L7 |
| `cCodRet2` | `CHAR(5)` | L8 |
| `cCodRet3` | `CHAR(50)` | L9 |
| `cCodRet4` | `CHAR(5)` | L10 |
| `cCodRet5` | `CHAR(5)` | L11 |
| `cCodRet6` | `CHAR(5)` | L12 |
| `cCodRet7` | `CHAR(5)` | L13 |
| `iContador1` | `INTEGER` | L14 |
| `iContador2` | `INTEGER` | L15 |
| `iComienza` | `SMALLINT` | L16 |
| `iAbierto` | `SMALLINT` | L17 |
| `cDisponible` | `CHAR(1)` | L18 |
| `cStatusProc` | `CHAR(1)` | L19 |
| `cCveRastreo` | `CHAR(30)` | L20 |
| `cCuenta` | `CHAR(20)` | L21 |
| `mMonto` | `DECIMAL(14,2)` | L22 |
| `dFechaVal` | `DATE` | L23 |
| `cCtaBenef` | `CHAR(20)` | L24 |
| `cNumCte` | `CHAR(20)` | L25 |
| `cCtaBenefEmail` | `CHAR(20)` | L26 |
| `cTpoCtaBenefMsg` | `CHAR(25)` | L27 |
| `cTransacc` | `CHAR(4)` | L28 |
| *…38 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tblctrlproceso` | `bdispei` | no | UPDATE | L150 |
| `tblctrlproceso` | `bdispei` | no | SELECT | L181 |
| `sc_fechas` | `bdicheq` | ⚠️ sí | SELECT | L229 |
| `tblabono` | `bdispei` | no | SELECT | L248 |
| `sc_movdia` | `bdicheq` | ⚠️ sí | SELECT | L320 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_obtfoliosuc` | `bdispei` | no | L368 |
| `abono_ref` | `bdicheq` | ⚠️ sí | L376 |
| `spei_recerrorescodi` | `bdispei` | no | L394 |
| `sp_registra_evento` | `bdimnsj` | ⚠️ sí | L403 |
| `sp_registra_evento_tmp_spei` | `bdimnsj` | ⚠️ sí | L413 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L82 | FÓRMULA | `LET iComienza       = -1;` |  |
| L110 | FÓRMULA | `LET vtimestamp         = dbinfo('utc_current') * 1000;` |  |
| L232 | VALIDACIÓN_NULL | `IF cDisponible is null OR cDisponible = '' OR cDisponible = '0' THEN` |  |
| L255 | FÓRMULA | `LET iContador1 = iContador1 + 1;` |  |
| L336 | FÓRMULA | `LET iContador2 = iContador2 + 1;` |  |
| L367 | VALIDACIÓN_NULL | `IF cFolioSuc is null OR cFolioSuc = '' THEN` |  |
| L390 | FÓRMULA | `LET iContador2 = iContador2 + 1;` |  |
| L400 | FÓRMULA | `LET cCtaBenefMsg = SUBSTR(cCtaBenef,(LENGTH(cCtaBenef)-3),4);` |  |
| L441 | FÓRMULA | `LET iContador2 = iContador2 + 1;` |  |
| L454 | FÓRMULA | `LET iContador2 = iContador2 + 1;` |  |
| L473 | FÓRMULA | `LET iContador2 = iContador2 + 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `spei` | PREFIJO | familia SPEI (pagos interbancarios) | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `aplicaordenpago` | ACCION | aplica orden de pago | 🔵 CONVENCIÓN | nombre_sp |
| `?_dos` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_dos` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `spei_aplicaordenpago_esp`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_spei_aplicaordenpago_esp.sql` |
| **LOC (1er CREATE)** | 443 |
| **Callgraph** | ✅ fan_in=0 / fan_out=5 |
| **Propósito inferido** | "aplica orden de pago (especial)" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 4 llamada(s): `sp_obtfoliosuc`, `abono_ref`, `spei_recerrorescodi` |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=0 / 3 términos |

### Firma

```sql
CREATE PROCEDURE spei_aplicaordenpago_esp(
  pRegistros                   INTEGER
) RETURNING CHAR(5), INTEGER, INTEGER
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pRegistros` | `INTEGER` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `iSqlErr` | `INTEGER` | L4 |
| `iIsamErr` | `INTEGER` | L5 |
| `cDescErr` | `CHAR(50)` | L6 |
| `cCodRet1` | `CHAR(5)` | L7 |
| `cCodRet2` | `CHAR(5)` | L8 |
| `cCodRet3` | `CHAR(50)` | L9 |
| `cCodRet4` | `CHAR(5)` | L10 |
| `cCodRet5` | `CHAR(5)` | L11 |
| `cCodRet6` | `CHAR(5)` | L12 |
| `cCodRet7` | `CHAR(5)` | L13 |
| `iContador1` | `INTEGER` | L14 |
| `iContador2` | `INTEGER` | L15 |
| `iComienza` | `SMALLINT` | L16 |
| `iAbierto` | `SMALLINT` | L17 |
| `cDisponible` | `CHAR(1)` | L18 |
| `cStatusProc` | `CHAR(1)` | L19 |
| `cCveRastreo` | `CHAR(30)` | L20 |
| `cCuenta` | `CHAR(20)` | L21 |
| `mMonto` | `DECIMAL(14,2)` | L22 |
| `dFechaVal` | `DATE` | L23 |
| `cCtaBenef` | `CHAR(20)` | L24 |
| `cNumCte` | `CHAR(20)` | L25 |
| `cCtaBenefEmail` | `CHAR(20)` | L26 |
| `cTpoCtaBenefMsg` | `CHAR(25)` | L27 |
| `cTransacc` | `CHAR(4)` | L28 |
| *…38 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tblctrlproceso` | `bdispei` | no | SELECT | L163 |
| `sc_fechas` | `bdicheq` | ⚠️ sí | SELECT | L174 |
| `tblabono` | `bdispei` | no | SELECT | L193 |
| `sc_movdia` | `bdicheq` | ⚠️ sí | SELECT | L265 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_obtfoliosuc` | `bdispei` | no | L288 |
| `abono_ref` | `bdicheq` | ⚠️ sí | L296 |
| `spei_recerrorescodi` | `bdispei` | no | L311 |
| `sp_registra_evento` | `bdimnsj` | ⚠️ sí | L320 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L82 | FÓRMULA | `LET iComienza       = -1;` |  |
| L110 | FÓRMULA | `LET vtimestamp         = dbinfo('utc_current') * 1000;` |  |
| L177 | VALIDACIÓN_NULL | `IF cDisponible is null OR cDisponible = '' OR cDisponible = '0' THEN` |  |
| L200 | FÓRMULA | `LET iContador1 = iContador1 + 1;` |  |
| L278 | FÓRMULA | `LET iContador2 = iContador2 + 1;` |  |
| L287 | VALIDACIÓN_NULL | `IF cFolioSuc is null OR cFolioSuc = '' THEN` |  |
| L307 | FÓRMULA | `LET iContador2 = iContador2 + 1;` |  |
| L317 | FÓRMULA | `LET cCtaBenefMsg = SUBSTR(cCtaBenef,(LENGTH(cCtaBenef)-3),4);` |  |
| L336 | FÓRMULA | `LET iContador2 = iContador2 + 1;` |  |
| L346 | FÓRMULA | `LET iContador2 = iContador2 + 1;` |  |
| L362 | FÓRMULA | `LET iContador2 = iContador2 + 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `spei` | PREFIJO | familia SPEI (pagos interbancarios) | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `aplicaordenpago` | ACCION | aplica orden de pago | 🔵 CONVENCIÓN | nombre_sp |
| `esp` | MODIF | especial | 🔵 CONVENCIÓN | nombre_sp |

---

## `spei_aplicaordenpago_juan`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_spei_aplicaordenpago_juan.sql` |
| **LOC (1er CREATE)** | 549 |
| **Callgraph** | ✅ fan_in=0 / fan_out=5 |
| **Propósito inferido** | "aplica orden de pago" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 4 llamada(s): `sp_obtfoliosuc`, `abono_ref`, `spei_recerrorescodi` |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=1 / 3 términos |

### Firma

```sql
CREATE PROCEDURE spei_aplicaordenpago_juan(
  pRegistros                   INTEGER
  pOrigen                      CHAR(1)
) RETURNING CHAR(5), INTEGER, INTEGER
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pRegistros` | `INTEGER` | — | — |
| `pOrigen` | `CHAR(1)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `iSqlErr` | `INTEGER` | L4 |
| `iIsamErr` | `INTEGER` | L5 |
| `cDescErr` | `CHAR(50)` | L6 |
| `cCodRet1` | `CHAR(5)` | L7 |
| `cCodRet2` | `CHAR(5)` | L8 |
| `cCodRet3` | `CHAR(50)` | L9 |
| `cCodRet4` | `CHAR(5)` | L10 |
| `cCodRet5` | `CHAR(5)` | L11 |
| `cCodRet6` | `CHAR(5)` | L12 |
| `cCodRet7` | `CHAR(5)` | L13 |
| `iContador1` | `INTEGER` | L14 |
| `iContador2` | `INTEGER` | L15 |
| `iComienza` | `SMALLINT` | L16 |
| `iAbierto` | `SMALLINT` | L17 |
| `cDisponible` | `CHAR(1)` | L18 |
| `cStatusProc` | `CHAR(1)` | L19 |
| `cCveRastreo` | `CHAR(30)` | L20 |
| `cCuenta` | `CHAR(20)` | L21 |
| `mMonto` | `DECIMAL(14,2)` | L22 |
| `dFechaVal` | `DATE` | L23 |
| `cCtaBenef` | `CHAR(20)` | L24 |
| `cNumCte` | `CHAR(20)` | L25 |
| `cCtaBenefEmail` | `CHAR(20)` | L26 |
| `cTpoCtaBenefMsg` | `CHAR(25)` | L27 |
| `cTransacc` | `CHAR(4)` | L28 |
| *…38 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tblctrlproceso` | `bdispei` | no | UPDATE | L151 |
| `tblctrlproceso` | `bdispei` | no | SELECT | L182 |
| `sc_fechas` | `bdicheq` | ⚠️ sí | SELECT | L229 |
| `tblabono` | `bdispei` | no | SELECT | L243 |
| `paso_spei` | `bdispei` | no | SELECT | L256 |
| `sc_movdia` | `bdicheq` | ⚠️ sí | SELECT | L327 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_obtfoliosuc` | `bdispei` | no | L353 |
| `abono_ref` | `bdicheq` | ⚠️ sí | L361 |
| `spei_recerrorescodi` | `bdispei` | no | L379 |
| `sp_registra_evento` | `bdimnsj` | ⚠️ sí | L388 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L82 | FÓRMULA | `LET iComienza       = -1;` |  |
| L110 | FÓRMULA | `LET vtimestamp         = dbinfo('utc_current') * 1000;` |  |
| L232 | VALIDACIÓN_NULL | `IF cDisponible is null OR cDisponible = '' OR cDisponible = '0' THEN` |  |
| L262 | FÓRMULA | `LET iContador1 = iContador1 + 1;` |  |
| L343 | FÓRMULA | `LET iContador2 = iContador2 + 1;` |  |
| L352 | VALIDACIÓN_NULL | `IF cFolioSuc is null OR cFolioSuc = '' THEN` |  |
| L375 | FÓRMULA | `LET iContador2 = iContador2 + 1;` |  |
| L385 | FÓRMULA | `LET cCtaBenefMsg = SUBSTR(cCtaBenef,(LENGTH(cCtaBenef)-3),4);` |  |
| L416 | FÓRMULA | `LET iContador2 = iContador2 + 1;` |  |
| L429 | FÓRMULA | `LET iContador2 = iContador2 + 1;` |  |
| L448 | FÓRMULA | `LET iContador2 = iContador2 + 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `spei` | PREFIJO | familia SPEI (pagos interbancarios) | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `aplicaordenpago` | ACCION | aplica orden de pago | 🔵 CONVENCIÓN | nombre_sp |
| `?_juan` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_juan` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `spei_aplicaordenpago_mib`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_spei_aplicaordenpago_mib.sql` |
| **LOC (1er CREATE)** | 511 |
| **Callgraph** | ✅ fan_in=0 / fan_out=5 |
| **Propósito inferido** | "aplica orden de pago MIB — módulo/canal de integración para cheques y tarjeta" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 4 llamada(s): `sp_obtfoliosuc`, `abono_ref`, `spei_recerrorescodi` |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=1 · INFERIDO=1 · SINTÉTICO=0 / 3 términos |

### Firma

```sql
CREATE PROCEDURE spei_aplicaordenpago_mib(
  pRegistros                   INTEGER
  pOrigen                      CHAR(1)
) RETURNING CHAR(5), INTEGER, INTEGER
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pRegistros` | `INTEGER` | — | — |
| `pOrigen` | `CHAR(1)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `iSqlErr` | `INTEGER` | L4 |
| `iIsamErr` | `INTEGER` | L5 |
| `cDescErr` | `CHAR(50)` | L6 |
| `cCodRet1` | `CHAR(5)` | L7 |
| `cCodRet2` | `CHAR(5)` | L8 |
| `cCodRet3` | `CHAR(50)` | L9 |
| `cCodRet4` | `CHAR(5)` | L10 |
| `cCodRet5` | `CHAR(5)` | L11 |
| `cCodRet6` | `CHAR(5)` | L12 |
| `cCodRet7` | `CHAR(5)` | L13 |
| `iContador1` | `INTEGER` | L14 |
| `iContador2` | `INTEGER` | L15 |
| `iComienza` | `SMALLINT` | L16 |
| `iAbierto` | `SMALLINT` | L17 |
| `cDisponible` | `CHAR(1)` | L18 |
| `cStatusProc` | `CHAR(1)` | L19 |
| `cCveRastreo` | `CHAR(30)` | L20 |
| `cCuenta` | `CHAR(20)` | L21 |
| `mMonto` | `DECIMAL(14,2)` | L22 |
| `dFechaVal` | `DATE` | L23 |
| `cCtaBenef` | `CHAR(20)` | L24 |
| `cNumCte` | `CHAR(20)` | L25 |
| `cCtaBenefEmail` | `CHAR(20)` | L26 |
| `cTpoCtaBenefMsg` | `CHAR(25)` | L27 |
| `cTransacc` | `CHAR(4)` | L28 |
| *…38 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tblctrlproceso` | `bdispei` | no | SELECT | L162 |
| `tblctrlproceso` | `bdispei` | no | UPDATE | L186 |
| `sc_fechas` | `bdicheq` | ⚠️ sí | SELECT | L209 |
| `tblabono` | `bdispei` | no | SELECT | L228 |
| `sc_movdia` | `bdicheq` | ⚠️ sí | SELECT | L300 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_obtfoliosuc` | `bdispei` | no | L326 |
| `abono_ref` | `bdicheq` | ⚠️ sí | L334 |
| `spei_recerrorescodi` | `bdispei` | no | L352 |
| `sp_registra_evento` | `bdimnsj` | ⚠️ sí | L361 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L82 | FÓRMULA | `LET iComienza       = -1;` |  |
| L110 | FÓRMULA | `LET vtimestamp         = dbinfo('utc_current') * 1000;` |  |
| L212 | VALIDACIÓN_NULL | `IF cDisponible is null OR cDisponible = '' OR cDisponible = '0' THEN` |  |
| L235 | FÓRMULA | `LET iContador1 = iContador1 + 1;` |  |
| L316 | FÓRMULA | `LET iContador2 = iContador2 + 1;` |  |
| L325 | VALIDACIÓN_NULL | `IF cFolioSuc is null OR cFolioSuc = '' THEN` |  |
| L348 | FÓRMULA | `LET iContador2 = iContador2 + 1;` |  |
| L358 | FÓRMULA | `LET cCtaBenefMsg = SUBSTR(cCtaBenef,(LENGTH(cCtaBenef)-3),4);` |  |
| L380 | FÓRMULA | `LET iContador2 = iContador2 + 1;` |  |
| L393 | FÓRMULA | `LET iContador2 = iContador2 + 1;` |  |
| L412 | FÓRMULA | `LET iContador2 = iContador2 + 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `spei` | PREFIJO | familia SPEI (pagos interbancarios) | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `aplicaordenpago` | ACCION | aplica orden de pago | 🔵 CONVENCIÓN | nombre_sp |
| `mib` | ENTIDAD | MIB — módulo/canal de integración para cheques y tarjeta (ca | 🟡 INFERIDO | nombre_sp |

---

## `spei_aplicaordenpago_mib2`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_spei_aplicaordenpago_mib2.sql` |
| **LOC (1er CREATE)** | 572 |
| **Callgraph** | ✅ fan_in=0 / fan_out=6 |
| **Propósito inferido** | "aplica orden de pago MIB — módulo/canal de integración para cheques y tarjeta" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 5 llamada(s): `sp_obtfoliosuc`, `abono_ref`, `spei_recerrorescodi` |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=1 · INFERIDO=1 · SINTÉTICO=1 / 4 términos |

### Firma

```sql
CREATE PROCEDURE spei_aplicaordenpago_mib2(
  pRegistros                   INTEGER
  pOrigen                      CHAR(1)
) RETURNING CHAR(5), INTEGER, INTEGER
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pRegistros` | `INTEGER` | — | — |
| `pOrigen` | `CHAR(1)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `iSqlErr` | `INTEGER` | L4 |
| `iIsamErr` | `INTEGER` | L5 |
| `cDescErr` | `CHAR(50)` | L6 |
| `cCodRet1` | `CHAR(5)` | L7 |
| `cCodRet2` | `CHAR(5)` | L8 |
| `cCodRet3` | `CHAR(50)` | L9 |
| `cCodRet4` | `CHAR(5)` | L10 |
| `cCodRet5` | `CHAR(5)` | L11 |
| `cCodRet6` | `CHAR(5)` | L12 |
| `cCodRet7` | `CHAR(5)` | L13 |
| `iContador1` | `INTEGER` | L14 |
| `iContador2` | `INTEGER` | L15 |
| `iComienza` | `SMALLINT` | L16 |
| `iAbierto` | `SMALLINT` | L17 |
| `cDisponible` | `CHAR(1)` | L18 |
| `cStatusProc` | `CHAR(1)` | L19 |
| `cCveRastreo` | `CHAR(30)` | L20 |
| `cCuenta` | `CHAR(20)` | L21 |
| `mMonto` | `DECIMAL(14,2)` | L22 |
| `dFechaVal` | `DATE` | L23 |
| `cCtaBenef` | `CHAR(20)` | L24 |
| `cNumCte` | `CHAR(20)` | L25 |
| `cCtaBenefEmail` | `CHAR(20)` | L26 |
| `cTpoCtaBenefMsg` | `CHAR(25)` | L27 |
| `cTransacc` | `CHAR(4)` | L28 |
| *…38 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tblctrlproceso` | `bdispei` | no | UPDATE | L150 |
| `tblctrlproceso` | `bdispei` | no | SELECT | L181 |
| `sc_fechas` | `bdicheq` | ⚠️ sí | SELECT | L229 |
| `tblabono` | `bdispei` | no | SELECT | L248 |
| `sc_movdia` | `bdicheq` | ⚠️ sí | SELECT | L320 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_obtfoliosuc` | `bdispei` | no | L368 |
| `abono_ref` | `bdicheq` | ⚠️ sí | L376 |
| `spei_recerrorescodi` | `bdispei` | no | L394 |
| `sp_registra_evento` | `bdimnsj` | ⚠️ sí | L403 |
| `sp_registra_evento_tmp_spei` | `bdimnsj` | ⚠️ sí | L413 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L82 | FÓRMULA | `LET iComienza       = -1;` |  |
| L110 | FÓRMULA | `LET vtimestamp         = dbinfo('utc_current') * 1000;` |  |
| L232 | VALIDACIÓN_NULL | `IF cDisponible is null OR cDisponible = '' OR cDisponible = '0' THEN` |  |
| L255 | FÓRMULA | `LET iContador1 = iContador1 + 1;` |  |
| L336 | FÓRMULA | `LET iContador2 = iContador2 + 1;` |  |
| L367 | VALIDACIÓN_NULL | `IF cFolioSuc is null OR cFolioSuc = '' THEN` |  |
| L390 | FÓRMULA | `LET iContador2 = iContador2 + 1;` |  |
| L400 | FÓRMULA | `LET cCtaBenefMsg = SUBSTR(cCtaBenef,(LENGTH(cCtaBenef)-3),4);` |  |
| L441 | FÓRMULA | `LET iContador2 = iContador2 + 1;` |  |
| L454 | FÓRMULA | `LET iContador2 = iContador2 + 1;` |  |
| L473 | FÓRMULA | `LET iContador2 = iContador2 + 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `spei` | PREFIJO | familia SPEI (pagos interbancarios) | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `aplicaordenpago` | ACCION | aplica orden de pago | 🔵 CONVENCIÓN | nombre_sp |
| `mib` | ENTIDAD | MIB — módulo/canal de integración para cheques y tarjeta (ca | 🟡 INFERIDO | nombre_sp |
| `?2` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?2` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `spei_aplicaordenpago_trace`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_spei_aplicaordenpago_trace.sql` |
| **LOC (1er CREATE)** | 572 |
| **Callgraph** | ✅ fan_in=0 / fan_out=6 |
| **Propósito inferido** | "aplica orden de pago" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 5 llamada(s): `sp_obtfoliosuc`, `abono_ref`, `spei_recerrorescodi` |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=1 / 3 términos |

### Firma

```sql
CREATE PROCEDURE spei_aplicaordenpago_trace(
  pRegistros                   INTEGER
  pOrigen                      CHAR(1)
) RETURNING CHAR(5), INTEGER, INTEGER
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pRegistros` | `INTEGER` | — | — |
| `pOrigen` | `CHAR(1)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `iSqlErr` | `INTEGER` | L4 |
| `iIsamErr` | `INTEGER` | L5 |
| `cDescErr` | `CHAR(50)` | L6 |
| `cCodRet1` | `CHAR(5)` | L7 |
| `cCodRet2` | `CHAR(5)` | L8 |
| `cCodRet3` | `CHAR(50)` | L9 |
| `cCodRet4` | `CHAR(5)` | L10 |
| `cCodRet5` | `CHAR(5)` | L11 |
| `cCodRet6` | `CHAR(5)` | L12 |
| `cCodRet7` | `CHAR(5)` | L13 |
| `iContador1` | `INTEGER` | L14 |
| `iContador2` | `INTEGER` | L15 |
| `iComienza` | `SMALLINT` | L16 |
| `iAbierto` | `SMALLINT` | L17 |
| `cDisponible` | `CHAR(1)` | L18 |
| `cStatusProc` | `CHAR(1)` | L19 |
| `cCveRastreo` | `CHAR(30)` | L20 |
| `cCuenta` | `CHAR(20)` | L21 |
| `mMonto` | `DECIMAL(14,2)` | L22 |
| `dFechaVal` | `DATE` | L23 |
| `cCtaBenef` | `CHAR(20)` | L24 |
| `cNumCte` | `CHAR(20)` | L25 |
| `cCtaBenefEmail` | `CHAR(20)` | L26 |
| `cTpoCtaBenefMsg` | `CHAR(25)` | L27 |
| `cTransacc` | `CHAR(4)` | L28 |
| *…38 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tblctrlproceso` | `bdispei` | no | UPDATE | L150 |
| `tblctrlproceso` | `bdispei` | no | SELECT | L181 |
| `sc_fechas` | `bdicheq` | ⚠️ sí | SELECT | L229 |
| `tblabono` | `bdispei` | no | SELECT | L248 |
| `sc_movdia` | `bdicheq` | ⚠️ sí | SELECT | L320 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_obtfoliosuc` | `bdispei` | no | L368 |
| `abono_ref` | `bdicheq` | ⚠️ sí | L376 |
| `spei_recerrorescodi` | `bdispei` | no | L394 |
| `sp_registra_evento` | `bdimnsj` | ⚠️ sí | L403 |
| `sp_registra_evento_tmp_spei` | `bdimnsj` | ⚠️ sí | L413 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L82 | FÓRMULA | `LET iComienza       = -1;` |  |
| L110 | FÓRMULA | `LET vtimestamp         = dbinfo('utc_current') * 1000;` |  |
| L232 | VALIDACIÓN_NULL | `IF cDisponible is null OR cDisponible = '' OR cDisponible = '0' THEN` |  |
| L255 | FÓRMULA | `LET iContador1 = iContador1 + 1;` |  |
| L336 | FÓRMULA | `LET iContador2 = iContador2 + 1;` |  |
| L367 | VALIDACIÓN_NULL | `IF cFolioSuc is null OR cFolioSuc = '' THEN` |  |
| L390 | FÓRMULA | `LET iContador2 = iContador2 + 1;` |  |
| L400 | FÓRMULA | `LET cCtaBenefMsg = SUBSTR(cCtaBenef,(LENGTH(cCtaBenef)-3),4);` |  |
| L441 | FÓRMULA | `LET iContador2 = iContador2 + 1;` |  |
| L454 | FÓRMULA | `LET iContador2 = iContador2 + 1;` |  |
| L473 | FÓRMULA | `LET iContador2 = iContador2 + 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `spei` | PREFIJO | familia SPEI (pagos interbancarios) | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `aplicaordenpago` | ACCION | aplica orden de pago | 🔵 CONVENCIÓN | nombre_sp |
| `?_trace` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_trace` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `spei_calculointeres`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_spei_calculointeres.sql` |
| **LOC (1er CREATE)** | 170 |
| **Callgraph** | ✅ fan_in=0 / fan_out=2 |
| **Propósito inferido** | "cálculo y interés" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 2 llamada(s): `sp_obtfoliosuc`, `abono_ref` |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=0 / 3 términos |

### Firma

```sql
CREATE PROCEDURE spei_calculointeres(
) RETURNING CHAR(3)
```

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cSqlerr` | `INTEGER` | L5 |
| `cCodret` | `CHAR(5)` | L6 |
| `cTsaPond` | `DECIMAL(9,6)` | L7 |
| `vFechOpe` | `DATE` | L8 |
| `vFechCal` | `DATE` | L9 |
| `vFechaHoy` | `DATE` | L10 |
| `vClavRas` | `CHAR(30)` | L11 |
| `vImporte` | `DECIMAL(19,2)` | L12 |
| `vDifmins` | `INTEGER` | L13 |
| `vDifsegs` | `INTEGER` | L14 |
| `vMontoPgo` | `DECIMAL(19,2)` | L15 |
| `vClavRasPgo` | `CHAR(30)` | L16 |
| `vSucursal` | `CHAR(4)` | L17 |
| `vTransSuc` | `CHAR(4)` | L18 |
| `vTransCen` | `CHAR(4)` | L19 |
| `vFolioTran` | `CHAR(30)` | L20 |
| `vCuenta` | `CHAR(11)` | L21 |
| `vReferencia` | `CHAR(20)` | L22 |
| `vEmpresa` | `CHAR(3)` | L23 |
| `vUsuario` | `CHAR(10)` | L24 |
| `vSerial_folio` | `INTEGER` | L25 |
| `vCtaBenef` | `CHAR(20)` | L26 |
| `vDivisa` | `CHAR(2)` | L27 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sc_fechas` | `bdicheq` | ⚠️ sí | SELECT | L70 |
| `si_fechavalor` | `bdinteg` | ⚠️ sí | SELECT | L76 |
| `tblpago_interespei` | `bdispei` | no | SELECT | L89 |
| `tblpago_interespei` | `bdispei` | no | DELETE | L89 |
| `tblhistpago` | `bdispei` | no | SELECT | L98 |
| `sc_tarjeta` | `bdicheq` | ⚠️ sí | SELECT | L130 |
| `sc_cuenta_telefono` | `bdicheq` | ⚠️ sí | SELECT | L137 |
| `tf_maecte` | `bditransfer` | ⚠️ sí | SELECT | L143 |
| `tblpago_interespei` | `bdispei` | no | INSERT | L159 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_obtfoliosuc` | `bdispei` | no | L117 |
| `abono_ref` | `bdicheq` | ⚠️ sí | L151 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L112 | FÓRMULA | `LET vMontoPgo= ROUND((((cTsaPond * vImporte) * vDifmins ) / 518400),2);` | 🔴 MONEY/aritmética financiera |
| L140 | VALIDACIÓN_NULL | `IF vCuenta is null OR vCuenta = '' THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `spei` | PREFIJO | familia SPEI (pagos interbancarios) | 🔵 CONVENCIÓN | nombre_sp |
| `calculo` | ENTIDAD | cálculo | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `interes` | ENTIDAD | interés | 🔵 CONVENCIÓN | nombre_sp |

---

## `spei_calculointeres_pba`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_spei_calculointeres_pba.sql` |
| **LOC (1er CREATE)** | 170 |
| **Callgraph** | ✅ fan_in=0 / fan_out=2 |
| **Propósito inferido** | "cálculo y interés (PBA — sufijo de SPs para Pruebas; confirmado por SME)" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `confirma` → `SELECT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=0 / 4 términos |

### Firma

```sql
CREATE PROCEDURE spei_calculointeres_pba(
) RETURNING CHAR(3)
```

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cSqlerr` | `INTEGER` | L5 |
| `cCodret` | `CHAR(5)` | L6 |
| `cTsaPond` | `DECIMAL(9,6)` | L7 |
| `vFechOpe` | `DATE` | L8 |
| `vFechCal` | `DATE` | L9 |
| `vFechaHoy` | `DATE` | L10 |
| `vClavRas` | `CHAR(30)` | L11 |
| `vImporte` | `DECIMAL(19,2)` | L12 |
| `vDifmins` | `INTEGER` | L13 |
| `vDifsegs` | `INTEGER` | L14 |
| `vMontoPgo` | `DECIMAL(19,2)` | L15 |
| `vClavRasPgo` | `CHAR(30)` | L16 |
| `vSucursal` | `CHAR(4)` | L17 |
| `vTransSuc` | `CHAR(4)` | L18 |
| `vTransCen` | `CHAR(4)` | L19 |
| `vFolioTran` | `CHAR(30)` | L20 |
| `vCuenta` | `CHAR(11)` | L21 |
| `vReferencia` | `CHAR(20)` | L22 |
| `vEmpresa` | `CHAR(3)` | L23 |
| `vUsuario` | `CHAR(10)` | L24 |
| `vSerial_folio` | `INTEGER` | L25 |
| `vCtaBenef` | `CHAR(20)` | L26 |
| `vDivisa` | `CHAR(2)` | L27 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sc_fechas` | `bdicheq` | ⚠️ sí | SELECT | L70 |
| `si_fechavalor` | `bdinteg` | ⚠️ sí | SELECT | L76 |
| `tblpago_interespei` | `bdispei` | no | SELECT | L89 |
| `tblpago_interespei` | `bdispei` | no | DELETE | L89 |
| `tblhistpago` | `bdispei` | no | SELECT | L98 |
| `sc_tarjeta` | `bdicheq` | ⚠️ sí | SELECT | L130 |
| `sc_cuenta_telefono` | `bdicheq` | ⚠️ sí | SELECT | L137 |
| `tf_maecte` | `bditransfer` | ⚠️ sí | SELECT | L143 |
| `tblpago_interespei` | `bdispei` | no | INSERT | L159 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_obtfoliosuc` | `bdispei` | no | L117 |
| `abono_ref` | `bdicheq` | ⚠️ sí | L151 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L112 | FÓRMULA | `LET vMontoPgo= ROUND((((cTsaPond * vImporte) * vDifmins ) / 518400),2);` | 🔴 MONEY/aritmética financiera |
| L140 | VALIDACIÓN_NULL | `IF vCuenta is null OR vCuenta = '' THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `spei` | PREFIJO | familia SPEI (pagos interbancarios) | 🔵 CONVENCIÓN | nombre_sp |
| `calculo` | ENTIDAD | cálculo | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `interes` | ENTIDAD | interés | 🔵 CONVENCIÓN | nombre_sp |
| `pba` | MODIF | PBA — sufijo de SPs para Pruebas; confirmado por SME (Guerra | 🔵 CONVENCIÓN | nombre_sp |

---

## `spei_concilia_cargos_ef`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_spei_concilia_cargos_ef.sql` |
| **LOC (1er CREATE)** | 249 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "conciliación cargo" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 12 tabla(s) con operaciones: INSERT, SELECT, UPDATE |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=1 / 4 términos |

### Firma

```sql
CREATE PROCEDURE spei_concilia_cargos_ef(
  pEmpresa                     CHAR(3)
) RETURNING CHAR(5)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pEmpresa` | `CHAR(3)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet1` | `CHAR(5)` | L4 |
| `cCodRet2` | `CHAR(5)` | L5 |
| `cCodRet3` | `CHAR(50)` | L6 |
| `iSqlErr` | `INTEGER` | L7 |
| `iSamErr` | `INTEGER` | L8 |
| `iDesErr` | `CHAR(50)` | L9 |
| `iTransacc` | `SMALLINT` | L10 |
| `iExisteTbl` | `SMALLINT` | L11 |
| `cSQL` | `CHAR(500)` | L12 |
| `dFechaHoy` | `DATE` | L13 |
| `dFechaAnt` | `DATE` | L14 |
| `cCveRastreo` | `VARCHAR(40)` | L15 |
| `cCuentaOrd` | `VARCHAR(20)` | L16 |
| `dMonto` | `DECIMAL(19,2)` | L17 |
| `cCuentaChq` | `VARCHAR(20)` | L18 |
| `iExisteTrx` | `SMALLINT` | L19 |
| `i` | `INTEGER` | L20 |
| `j` | `INTEGER` | L21 |
| `iExisteFer` | `SMALLINT` | L22 |
| `dFechaValor` | `DATE` | L23 |
| `dFechaCaptu` | `DATE` | L24 |
| `cTrxOpera` | `CHAR(4)` | L25 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `systabnames` | `sysmaster` | ⚠️ sí | SELECT | L75 |
| `cargos_spei` | `bdispei` | no | INSERT | L90 |
| `statistics` | `bdispei` | no | UPDATE | L96 |
| `sc_fechas` | `bdicheq` | ⚠️ sí | SELECT | L101 |
| `si_feriado` | `bdinteg` | ⚠️ sí | SELECT | L113 |
| `tblpago` | `bdispei` | no | SELECT | L129 |
| `sc_cuenta_telefono` | `bdicheq` | ⚠️ sí | SELECT | L139 |
| `sc_maechq` | `bdicheq` | ⚠️ sí | SELECT | L144 |
| `sc_tarjeta` | `bdicheq` | ⚠️ sí | SELECT | L149 |
| `sc_movdia` | `bdicheq` | ⚠️ sí | SELECT | L166 |
| `sc_movhis` | `bdicheq` | ⚠️ sí | SELECT | L177 |
| `tblconciliacargos` | `bdispei` | no | INSERT | L219 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L108 | FÓRMULA | `LET dFechaAnt = dFechaHoy - j;` |  |
| L122 | FÓRMULA | `LET j = j + 1;` |  |
| L158 | VALIDACIÓN_NULL | `IF cCuentaChq is null OR cCuentaChq = '' THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `spei` | PREFIJO | familia SPEI (pagos interbancarios) | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `concilia` | ACCION | conciliación | 🔵 CONVENCIÓN | nombre_sp |
| `cargo` | ENTIDAD | cargo / débito | 🔵 CONVENCIÓN | nombre_sp |
| `?s_ef` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?s_ef` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `spei_concilia_cargos_ef_exp`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_spei_concilia_cargos_ef_exp.sql` |
| **LOC (1er CREATE)** | 249 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "conciliación cargo (sufijo Exportar — SP genera/exporta archivo de salida)" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `genera` → `INSERT` encontrado en el cuerpo · `genera` → `SELECT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=2 · INFERIDO=1 · SINTÉTICO=1 / 5 términos |

### Firma

```sql
CREATE PROCEDURE spei_concilia_cargos_ef_exp(
  pEmpresa                     CHAR(3)
) RETURNING CHAR(5)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pEmpresa` | `CHAR(3)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet1` | `CHAR(5)` | L4 |
| `cCodRet2` | `CHAR(5)` | L5 |
| `cCodRet3` | `CHAR(50)` | L6 |
| `iSqlErr` | `INTEGER` | L7 |
| `iSamErr` | `INTEGER` | L8 |
| `iDesErr` | `CHAR(50)` | L9 |
| `iTransacc` | `SMALLINT` | L10 |
| `iExisteTbl` | `SMALLINT` | L11 |
| `cSQL` | `CHAR(500)` | L12 |
| `dFechaHoy` | `DATE` | L13 |
| `dFechaAnt` | `DATE` | L14 |
| `cCveRastreo` | `VARCHAR(40)` | L15 |
| `cCuentaOrd` | `VARCHAR(20)` | L16 |
| `dMonto` | `DECIMAL(19,2)` | L17 |
| `cCuentaChq` | `VARCHAR(20)` | L18 |
| `iExisteTrx` | `SMALLINT` | L19 |
| `i` | `INTEGER` | L20 |
| `j` | `INTEGER` | L21 |
| `iExisteFer` | `SMALLINT` | L22 |
| `dFechaValor` | `DATE` | L23 |
| `dFechaCaptu` | `DATE` | L24 |
| `cTrxOpera` | `CHAR(4)` | L25 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `systabnames` | `sysmaster` | ⚠️ sí | SELECT | L75 |
| `cargos_spei` | `bdispei` | no | INSERT | L90 |
| `statistics` | `bdispei` | no | UPDATE | L96 |
| `sc_fechas` | `bdicheq` | ⚠️ sí | SELECT | L101 |
| `si_feriado` | `bdinteg` | ⚠️ sí | SELECT | L113 |
| `tblpago` | `bdispei` | no | SELECT | L129 |
| `sc_cuenta_telefono` | `bdicheq` | ⚠️ sí | SELECT | L139 |
| `sc_maechq` | `bdicheq` | ⚠️ sí | SELECT | L144 |
| `sc_tarjeta` | `bdicheq` | ⚠️ sí | SELECT | L149 |
| `sc_movdia` | `bdicheq` | ⚠️ sí | SELECT | L166 |
| `sc_movhis` | `bdicheq` | ⚠️ sí | SELECT | L177 |
| `tblconciliacargos` | `bdispei` | no | INSERT | L219 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L108 | FÓRMULA | `LET dFechaAnt = dFechaHoy - j;` |  |
| L122 | FÓRMULA | `LET j = j + 1;` |  |
| L158 | VALIDACIÓN_NULL | `IF cCuentaChq is null OR cCuentaChq = '' THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `spei` | PREFIJO | familia SPEI (pagos interbancarios) | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `concilia` | ACCION | conciliación | 🔵 CONVENCIÓN | nombre_sp |
| `cargo` | ENTIDAD | cargo / débito | 🔵 CONVENCIÓN | nombre_sp |
| `?s_ef_` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `exp` | MODIF | sufijo Exportar — SP genera/exporta archivo de salida (sp_*_ | 🟡 INFERIDO | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?s_ef_` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `spei_depuratablas`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_spei_depuratablas.sql` |
| **LOC (1er CREATE)** | 100 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "depura" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 3 llamada(s): `spei_depuratblpago`, `spei_depuratbldetranpago`, `spei_desbloqbandera` |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=0 · INFERIDO=0 · SINTÉTICO=1 / 3 términos |

### Firma

```sql
CREATE PROCEDURE spei_depuratablas(
  pEmpresa                     CHAR(3)
) RETURNING CHAR(5)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pEmpresa` | `CHAR(3)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `sql_err` | `INTEGER` | L4 |
| `isam_err` | `INTEGER` | L5 |
| `desc_err` | `CHAR(80)` | L6 |
| `vcodret1` | `CHAR(5)` | L7 |
| `vcodret2` | `CHAR(5)` | L8 |
| `vcodret3` | `CHAR(80)` | L9 |
| `wfecha_hoy` | `DATE` | L10 |
| `wcierre` | `SMALLINT` | L11 |
| `wtblpago` | `CHAR(5)` | L12 |
| `wtbldetranpago` | `CHAR(5)` | L13 |
| `wdesbloqbandera` | `CHAR(5)` | L14 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sc_fechas` | `bdicheq` | ⚠️ sí | SELECT | L49 |
| `tblctrlproceso` | `bdispei` | no | SELECT | L56 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `spei_depuratblpago` | `bdispei` | no | L63 |
| `spei_depuratbldetranpago` | `bdispei` | no | L72 |
| `spei_desbloqbandera` | `bdispei` | no | L82 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `spei` | PREFIJO | familia SPEI (pagos interbancarios) | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `depura` | ACCION | depura / limpia | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?tablas` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?tablas` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `spei_depuratblabono`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_spei_depuratblabono.sql` |
| **LOC (1er CREATE)** | 212 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "depura tbl — tabla y abono" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `depura` → `DELETE` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=2 · INFERIDO=1 · SINTÉTICO=0 / 4 términos |

### Firma

```sql
CREATE PROCEDURE spei_depuratblabono(
) RETURNING CHAR(5)
```

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `Sql_Err` | `INTEGER` | L4 |
| `Isam_Err` | `INTEGER` | L5 |
| `Desc_Err` | `CHAR(50)` | L6 |
| `vCodRet1` | `CHAR(5)` | L7 |
| `vCodRet2` | `CHAR(5)` | L8 |
| `vCodRet3` | `CHAR(50)` | L9 |
| `vContador1` | `INTEGER` | L10 |
| `vContador2` | `INTEGER` | L11 |
| `vContador3` | `INTEGER` | L12 |
| `vComienza` | `SMALLINT` | L13 |
| `vAbierto` | `CHAR(1)` | L14 |
| `wintnumserial` | `integer` | L15 |
| `wmnyimporte` | `decimal(19,2)` | L16 |
| `wcvecesifbcoord` | `integer` | L17 |
| `wchrestatusenvio` | `char(1)` | L18 |
| `wvchrnombreord` | `varchar(40,0)` | L19 |
| `wvchrcuentaord` | `varchar(20,0)` | L20 |
| `wvchrrfcord` | `varchar(18,0)` | L21 |
| `wintcvetipoctaord` | `integer` | L22 |
| `wvchrnombrebenef` | `varchar(40,0)` | L23 |
| `wintcvetipoctabene` | `integer` | L24 |
| `wvchrcuentabenef` | `varchar(20,0)` | L25 |
| `wintrefnumerica` | `decimal(7,0)` | L26 |
| `wvchrrefcobranza` | `varchar(40,0)` | L27 |
| `wvchrconceptopago2` | `varchar(40,0)` | L28 |
| *…26 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sc_fechas` | `bdicheq` | ⚠️ sí | SELECT | L134 |
| `tblabono` | `bdispei` | no | SELECT | L157 |
| `tblhistabono` | `bdispei` | no | INSERT | L166 |
| `tblabono` | `bdispei` | no | DELETE | L180 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L66 | FÓRMULA | `LET vComienza           = -1;` |  |
| L186 | FÓRMULA | `LET vcontador3 = vcontador3 + 1;` |  |
| L190 | FÓRMULA | `LET vcontador1 = vcontador1 + 1;` |  |
| L191 | FÓRMULA | `LET vcontador2 = vcontador2 + 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `spei` | PREFIJO | familia SPEI (pagos interbancarios) | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `depura` | ACCION | depura / limpia | 🔵 CONVENCIÓN | nombre_sp |
| `tbl` | ENTIDAD | tbl — tabla (abreviación — sp_depura_tbl_registro_msj) | 🟡 INFERIDO | nombre_sp |
| `abono` | ENTIDAD | abono / crédito | 🔵 CONVENCIÓN | nombre_sp |

---

## `spei_depuratblabono_esp`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_spei_depuratblabono_esp.sql` |
| **LOC (1er CREATE)** | 101 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "depura tbl — tabla y abono (especial)" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 1 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=3 · INFERIDO=1 · SINTÉTICO=0 / 5 términos |

### Firma

```sql
CREATE PROCEDURE spei_depuratblabono_esp(
  pFecha1                      DATE
  pFecha2                      DATE
) RETURNING CHAR(5), INTEGER, INTEGER
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pFecha1` | `DATE` | — | — |
| `pFecha2` | `DATE` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `Sql_Err` | `INTEGER` | L4 |
| `Isam_Err` | `INTEGER` | L5 |
| `Desc_Err` | `CHAR(50)` | L6 |
| `vCodRet1` | `CHAR(5)` | L7 |
| `vCodRet2` | `CHAR(5)` | L8 |
| `vCodRet3` | `CHAR(50)` | L9 |
| `vContador1` | `INTEGER` | L10 |
| `vContador2` | `INTEGER` | L11 |
| `vContador3` | `INTEGER` | L12 |
| `vComienza` | `SMALLINT` | L13 |
| `vAbierto` | `CHAR(1)` | L14 |
| `wintnumserial` | `integer` | L15 |
| `wvchrclaverastreo` | `varchar(30,0)` | L16 |
| `iCommit` | `INTEGER` | L17 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tblabono` | `bdispei` | no | SELECT | L60 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L28 | FÓRMULA | `LET vComienza           = -1;` |  |
| L69 | FÓRMULA | `LET vcontador1 = vcontador1 + 1;` |  |
| L77 | FÓRMULA | `LET vcontador2 = vcontador2 + 1;` |  |
| L80 | FÓRMULA | `LET vcontador3 = vcontador3 + 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `spei` | PREFIJO | familia SPEI (pagos interbancarios) | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `depura` | ACCION | depura / limpia | 🔵 CONVENCIÓN | nombre_sp |
| `tbl` | ENTIDAD | tbl — tabla (abreviación — sp_depura_tbl_registro_msj) | 🟡 INFERIDO | nombre_sp |
| `abono` | ENTIDAD | abono / crédito | 🔵 CONVENCIÓN | nombre_sp |
| `esp` | MODIF | especial | 🔵 CONVENCIÓN | nombre_sp |

---

## `spei_depuratblabono_por_dia`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_spei_depuratblabono_por_dia.sql` |
| **LOC (1er CREATE)** | 171 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "depura tbl — tabla y abono (del día)" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `depura` → `DELETE` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=4 · INFERIDO=1 · SINTÉTICO=0 / 6 términos |

### Firma

```sql
CREATE PROCEDURE spei_depuratblabono_por_dia(
) RETURNING CHAR(5)
```

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `Sql_Err` | `INTEGER` | L4 |
| `Isam_Err` | `INTEGER` | L5 |
| `Desc_Err` | `CHAR(50)` | L6 |
| `vCodRet1` | `CHAR(5)` | L7 |
| `vCodRet2` | `CHAR(5)` | L8 |
| `vCodRet3` | `CHAR(50)` | L9 |
| `vContador1` | `INTEGER` | L10 |
| `vContador2` | `INTEGER` | L11 |
| `vContador3` | `INTEGER` | L12 |
| `vComienza` | `SMALLINT` | L13 |
| `vAbierto` | `CHAR(1)` | L14 |
| `wintnumserial` | `integer` | L15 |
| `wmnyimporte` | `decimal(19,2)` | L16 |
| `wcvecesifbcoord` | `integer` | L17 |
| `wchrestatusenvio` | `char(1)` | L18 |
| `wvchrnombreord` | `varchar(40,0)` | L19 |
| `wvchrcuentaord` | `varchar(20,0)` | L20 |
| `wvchrrfcord` | `varchar(18,0)` | L21 |
| `wintcvetipoctaord` | `integer` | L22 |
| `wvchrnombrebenef` | `varchar(40,0)` | L23 |
| `wintcvetipoctabene` | `integer` | L24 |
| `wvchrcuentabenef` | `varchar(20,0)` | L25 |
| `wintrefnumerica` | `decimal(7,0)` | L26 |
| `wvchrrefcobranza` | `varchar(40,0)` | L27 |
| `wvchrconceptopago2` | `varchar(40,0)` | L28 |
| *…26 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tblhistabono` | `bdispei` | no | SELECT | L137 |
| `tblhistabono` | `bdispei` | no | DELETE | L146 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L66 | FÓRMULA | `LET vComienza           = -1;` |  |
| L152 | FÓRMULA | `LET vcontador2 = vcontador2 + 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `spei` | PREFIJO | familia SPEI (pagos interbancarios) | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `depura` | ACCION | depura / limpia | 🔵 CONVENCIÓN | nombre_sp |
| `tbl` | ENTIDAD | tbl — tabla (abreviación — sp_depura_tbl_registro_msj) | 🟡 INFERIDO | nombre_sp |
| `abono` | ENTIDAD | abono / crédito | 🔵 CONVENCIÓN | nombre_sp |
| `por` | MODIF | por (criterio) | 🔵 CONVENCIÓN | nombre_sp |
| `dia` | MODIF | del día | 🔵 CONVENCIÓN | nombre_sp |

---

## `spei_depuratbldetranpago`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_spei_depuratbldetranpago.sql` |
| **LOC (1er CREATE)** | 127 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "depura tbl — tabla, detalle y pago" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `depura` → `DELETE` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=3 · INFERIDO=2 · SINTÉTICO=1 / 6 términos |

### Firma

```sql
CREATE PROCEDURE spei_depuratbldetranpago(
  pfecha_hoy                   DATE
) RETURNING CHAR(5)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pfecha_hoy` | `DATE` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `Sql_Err` | `INTEGER` | L4 |
| `Isam_Err` | `INTEGER` | L5 |
| `Desc_Err` | `CHAR(50)` | L6 |
| `vCodRet1` | `CHAR(5)` | L7 |
| `vCodRet2` | `CHAR(5)` | L8 |
| `vCodRet3` | `CHAR(50)` | L9 |
| `vContador1` | `INTEGER` | L10 |
| `vContador2` | `INTEGER` | L11 |
| `vContador3` | `INTEGER` | L12 |
| `vComienza` | `SMALLINT` | L13 |
| `vAbierto` | `CHAR(1)` | L14 |
| `vnum_serial` | `INTEGER` | L15 |
| `vfolio_suc` | `CHAR(16)` | L16 |
| `vsucursal` | `CHAR(4)` | L17 |
| `vusuario` | `CHAR(8)` | L18 |
| `vfech_alt` | `DATE` | L19 |
| `vtransacc` | `CHAR(4)` | L20 |
| `vempresa` | `CHAR(3)` | L21 |
| `vcuenta` | `CHAR(20)` | L22 |
| `vmonto_tot` | `MONEY(14,2)` | L23 |
| `vclave_rastreo` | `CHAR(30)` | L24 |
| `vtransaccion` | `SMALLINT` | L25 |
| `iCommit` | `INTEGER` | L26 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tbldetranpago` | `bdispei` | no | SELECT | L78 |
| `tblhistdetranpago` | `bdispei` | no | INSERT | L88 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L37 | FÓRMULA | `LET vComienza      = -1;` |  |
| L101 | FÓRMULA | `LET vcontador3 = vcontador3 + 1;` |  |
| L105 | FÓRMULA | `LET vcontador1 = vcontador1 + 1;` |  |
| L106 | FÓRMULA | `LET vcontador2 = vcontador2 + 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `spei` | PREFIJO | familia SPEI (pagos interbancarios) | 🔵 CONVENCIÓN | nombre_sp |
| `depura` | ACCION | depura / limpia | 🔵 CONVENCIÓN | nombre_sp |
| `tbl` | ENTIDAD | tbl — tabla (abreviación — sp_depura_tbl_registro_msj) | 🟡 INFERIDO | nombre_sp |
| `det` | ENTIDAD | detalle | 🟡 INFERIDO | nombre_sp |
| `?ran` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `pago` | ENTIDAD | pago | 🔵 CONVENCIÓN | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?ran` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `spei_depuratblpago`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_spei_depuratblpago.sql` |
| **LOC (1er CREATE)** | 251 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "depura tbl — tabla y pago" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `depura` → `DELETE` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=3 · INFERIDO=1 · SINTÉTICO=0 / 4 términos |

### Firma

```sql
CREATE PROCEDURE spei_depuratblpago(
  pfecha_hoy                   DATE
) RETURNING CHAR(5)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pfecha_hoy` | `DATE` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `Sql_Err` | `INTEGER` | L4 |
| `Isam_Err` | `INTEGER` | L5 |
| `Desc_Err` | `CHAR(50)` | L6 |
| `vCodRet1` | `CHAR(5)` | L7 |
| `vCodRet2` | `CHAR(5)` | L8 |
| `vCodRet3` | `CHAR(50)` | L9 |
| `vContador1` | `INTEGER` | L10 |
| `vContador2` | `INTEGER` | L11 |
| `vContador3` | `INTEGER` | L12 |
| `vComienza` | `SMALLINT` | L13 |
| `vAbierto` | `CHAR(1)` | L14 |
| `vintfoliopago` | `INTEGER` | L15 |
| `vintpkpago` | `INTEGER` | L16 |
| `vintcvecausadev` | `INTEGER` | L17 |
| `vintpkpaqueteenv` | `INTEGER` | L18 |
| `vmnyimporte` | `DECIMAL(19,2)` | L19 |
| `vcvecesifbcoord` | `INTEGER` | L20 |
| `vcvecesifbcodest` | `INTEGER` | L21 |
| `vchrestatusenvio` | `CHAR(1)` | L22 |
| `vvchrnombreord` | `CHAR(40)` | L23 |
| `vvchrcuentaord` | `CHAR(20)` | L24 |
| `vvchrrfcord` | `CHAR(18)` | L25 |
| `vvchrnombrebenef` | `CHAR(40)` | L26 |
| `vintcvetipoctabene` | `INTEGER` | L27 |
| `vvchrcuentabenef` | `CHAR(20)` | L28 |
| *…53 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tblpago` | `bdispei` | no | SELECT | L192 |
| `tblhistpago` | `bdispei` | no | INSERT | L201 |
| `tblpago` | `bdispei` | no | DELETE | L221 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L92 | FÓRMULA | `LET vComienza           = -1;` |  |
| L226 | FÓRMULA | `LET vcontador3 = vcontador3 + 1;` |  |
| L230 | FÓRMULA | `LET vcontador1 = vcontador1 + 1;` |  |
| L231 | FÓRMULA | `LET vcontador2 = vcontador2 + 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `spei` | PREFIJO | familia SPEI (pagos interbancarios) | 🔵 CONVENCIÓN | nombre_sp |
| `depura` | ACCION | depura / limpia | 🔵 CONVENCIÓN | nombre_sp |
| `tbl` | ENTIDAD | tbl — tabla (abreviación — sp_depura_tbl_registro_msj) | 🟡 INFERIDO | nombre_sp |
| `pago` | ENTIDAD | pago | 🔵 CONVENCIÓN | nombre_sp |

---

## `spei_depuratblpago_exp1`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_spei_depuratblpago_exp1.sql` |
| **LOC (1er CREATE)** | 248 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "depura tbl — tabla y pago (sufijo Exportar — SP genera/exporta archivo de salida)" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `depura` → `DELETE` encontrado en el cuerpo · `genera` → `INSERT` encontrado en el cuerpo · `genera` → `SELECT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=3 · INFERIDO=2 · SINTÉTICO=1 / 6 términos |

### Firma

```sql
CREATE PROCEDURE spei_depuratblpago_exp1(
  pfecha_hoy                   DATE
) RETURNING CHAR(5)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pfecha_hoy` | `DATE` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `Sql_Err` | `INTEGER` | L4 |
| `Isam_Err` | `INTEGER` | L5 |
| `Desc_Err` | `CHAR(50)` | L6 |
| `vCodRet1` | `CHAR(5)` | L7 |
| `vCodRet2` | `CHAR(5)` | L8 |
| `vCodRet3` | `CHAR(50)` | L9 |
| `vContador1` | `INTEGER` | L10 |
| `vContador2` | `INTEGER` | L11 |
| `vComienza` | `SMALLINT` | L12 |
| `vAbierto` | `CHAR(1)` | L13 |
| `vintfoliopago` | `INTEGER` | L15 |
| `vintpkpago` | `INTEGER` | L16 |
| `vintcvecausadev` | `INTEGER` | L17 |
| `vintpkpaqueteenv` | `INTEGER` | L18 |
| `vmnyimporte` | `DECIMAL(19,2)` | L19 |
| `vcvecesifbcoord` | `INTEGER` | L20 |
| `vcvecesifbcodest` | `INTEGER` | L21 |
| `vchrestatusenvio` | `CHAR(1)` | L22 |
| `vvchrnombreord` | `CHAR(40)` | L23 |
| `vvchrcuentaord` | `CHAR(20)` | L24 |
| `vvchrrfcord` | `CHAR(18)` | L25 |
| `vvchrnombrebenef` | `CHAR(40)` | L26 |
| `vintcvetipoctabene` | `INTEGER` | L27 |
| `vvchrcuentabenef` | `CHAR(20)` | L28 |
| `vvchrrfcbenef` | `CHAR(18)` | L29 |
| *…51 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tblpago` | `bdispei` | no | SELECT | L192 |
| `tblhistpago` | `bdispei` | no | INSERT | L201 |
| `tblpago` | `bdispei` | no | DELETE | L221 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L90 | FÓRMULA | `LET vComienza           = -1;` |  |
| L226 | FÓRMULA | `LET vcontador1 = vcontador1 + 1;` |  |
| L227 | FÓRMULA | `LET vcontador2 = vcontador2 + 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `spei` | PREFIJO | familia SPEI (pagos interbancarios) | 🔵 CONVENCIÓN | nombre_sp |
| `depura` | ACCION | depura / limpia | 🔵 CONVENCIÓN | nombre_sp |
| `tbl` | ENTIDAD | tbl — tabla (abreviación — sp_depura_tbl_registro_msj) | 🟡 INFERIDO | nombre_sp |
| `pago` | ENTIDAD | pago | 🔵 CONVENCIÓN | nombre_sp |
| `exp` | MODIF | sufijo Exportar — SP genera/exporta archivo de salida (sp_*_ | 🟡 INFERIDO | nombre_sp |
| `?1` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?1` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `spei_depuratblstsprocodi`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_spei_depuratblstsprocodi.sql` |
| **LOC (1er CREATE)** | 163 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "depura tbl — tabla · CoDi — Cobro Digital" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `depura` → `DELETE` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=4 · INFERIDO=0 · SINTÉTICO=2 / 7 términos |

### Firma

```sql
CREATE PROCEDURE spei_depuratblstsprocodi(
  pfecha_hoy                   DATE
) RETURNING CHAR(5)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pfecha_hoy` | `DATE` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `Sql_Err` | `INTEGER` | L4 |
| `Isam_Err` | `INTEGER` | L5 |
| `Desc_Err` | `CHAR(50)` | L6 |
| `vCodRet1` | `CHAR(5)` | L7 |
| `vCodRet2` | `CHAR(5)` | L8 |
| `vCodRet3` | `CHAR(50)` | L9 |
| `vContador1` | `INTEGER` | L10 |
| `vContador2` | `INTEGER` | L11 |
| `vComienza` | `SMALLINT` | L12 |
| `vAbierto` | `CHAR(1)` | L13 |
| `vnum_serial` | `INTEGER` | L15 |
| `vvstatenv` | `CHAR(1)` | L16 |
| `vvchridtpa` | `CHAR(2)` | L17 |
| `vvchrcode` | `CHAR(2)` | L18 |
| `vvchridmjc` | `CHAR(20)` | L19 |
| `vvchrfchmjc` | `CHAR(20)` | L20 |
| `vvchrconcepto` | `CHAR(50)` | L21 |
| `vmnyimporte` | `DECIMAL(12,2)` | L22 |
| `vvchrfchfinpro` | `CHAR(23)` | L23 |
| `vvchrcveras` | `CHAR(30)` | L24 |
| `vvchrrefnum` | `CHAR(7)` | L25 |
| `vvchrcelord` | `CHAR(10)` | L26 |
| `vvchrdiveord` | `CHAR(3)` | L27 |
| `vvchrbancoord` | `CHAR(5)` | L28 |
| `vvchrtpoctaord` | `CHAR(2)` | L29 |
| *…10 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tbl_stsprocodi` | `bdispei` | no | SELECT | L114 |
| `tbl_histstsprocodi` | `bdispei` | no | INSERT | L124 |
| `tbl_stsprocodi` | `bdispei` | no | DELETE | L136 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L49 | FÓRMULA | `LET vComienza           = -1;` |  |
| L141 | FÓRMULA | `LET vcontador1 = vcontador1 + 1;` |  |
| L142 | FÓRMULA | `LET vcontador2 = vcontador2 + 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `spei` | PREFIJO | familia SPEI (pagos interbancarios) | 🔵 CONVENCIÓN | nombre_sp |
| `depura` | ACCION | depura / limpia | 🔵 CONVENCIÓN | nombre_sp |
| `tbl` | ENTIDAD | tbl — tabla (abreviación — sp_depura_tbl_registro_msj) | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `?st` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `?ro` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `codi` | REG | CoDi — Cobro Digital (Banxico) | 🔵 CONVENCIÓN | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?st`, `?ro` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `spei_desbloqbandera`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_spei_desbloqbandera.sql` |
| **LOC (1er CREATE)** | 70 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "desbloqueo (bandera)" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 1 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=1 · INFERIDO=1 · SINTÉTICO=1 / 4 términos |

### Firma

```sql
CREATE PROCEDURE spei_desbloqbandera(
  pEmpresa                     CHAR(3)
) RETURNING CHAR(5)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pEmpresa` | `CHAR(3)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `intSqlErr` | `INTEGER` | L4 |
| `intIsamErr` | `INTEGER` | L5 |
| `chrDescErr` | `CHAR(80)` | L6 |
| `chrCodRet1` | `CHAR(5)` | L7 |
| `chrCodRet2` | `CHAR(5)` | L8 |
| `chrCodRet3` | `CHAR(80)` | L9 |
| `intExiste` | `SMALLINT` | L10 |
| `chrBandera` | `SMALLINT` | L11 |
| `chrHorario` | `CHAR(8)` | L12 |
| `chrSql` | `CHAR(300)` | L13 |
| `intNumSerial` | `INTEGER` | L14 |
| `dteHorario` | `CHAR(8)` | L15 |
| `vcSleep` | `VARCHAR(20)` | L16 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tblparametros` | `bdispei` | no | SELECT | L53 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `spei` | PREFIJO | familia SPEI (pagos interbancarios) | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `desb` | ACCION | desbloqueo | 🟡 INFERIDO | nombre_sp |
| `?loq` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `bandera` | MODIF | bandera / flag (técnico) | 🔵 CONVENCIÓN | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?loq` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `spei_devcodi`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_spei_devcodi.sql` |
| **LOC (1er CREATE)** | 1348 |
| **Callgraph** | ✅ fan_in=0 / fan_out=10 |
| **Deps concatenadas** | 3 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "devolución · CoDi — Cobro Digital" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 8 llamada(s): `spei_recerrorescodi`, `sp_validaspei_bpi`, `spei_validaoperacion` |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=0 / 3 términos |

### Firma

```sql
CREATE PROCEDURE spei_devcodi(
  pchridmjc                    CHAR(20)
  pchridmjcori                 CHAR(20)
  pvchrConceptoPago            CHAR(50)
  pdecImporteori               DECIMAL(12,2)
  pdecImporte                  DECIMAL(12,2)
  pReferenciaBe                CHAR(7)
  pchrtpoaviso                 CHAR(2)
  pchrCveRastreo               CHAR(30)
  pvchrNombreOrd               CHAR(40)
  pvchrCuentaOrd               CHAR(20)
  pchrbancoord                 CHAR(5)
  pintTipoCtaOrd               CHAR(2)
  pdigidord                    CHAR(3)
  pchraliasord                 CHAR(10)
  pvchrNombreBenef             CHAR(40)
  pvchrCtaBenef                CHAR(20)
  pchrbancobenf                CHAR(5)
  pintTipoCtaBenef             CHAR(2)
  pdigidben                    CHAR(3)
  pchraliasben                 CHAR(20)
  pchrfchmjc                   CHAR(20)
  pchartipopago                CHAR(2)
  pchrUsuario                  CHAR(8)
  pintBancoDest                INTEGER
  pchrFolioSuc                 CHAR(16)
  pdtfechacaptura              DATE
  pvchrRFCOrd                  VARCHAR(18)
  pchrRFCBenef                 VARCHAR(18)
) RETURNING CHAR(5), CHAR(30)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pchridmjc` | `CHAR(20)` | — | — |
| `pchridmjcori` | `CHAR(20)` | — | — |
| `pvchrConceptoPago` | `CHAR(50)` | — | — |
| `pdecImporteori` | `DECIMAL(12,2)` | — | — |
| `pdecImporte` | `DECIMAL(12,2)` | — | — |
| `pReferenciaBe` | `CHAR(7)` | — | — |
| `pchrtpoaviso` | `CHAR(2)` | — | — |
| `pchrCveRastreo` | `CHAR(30)` | — | — |
| `pvchrNombreOrd` | `CHAR(40)` | — | — |
| `pvchrCuentaOrd` | `CHAR(20)` | — | — |
| `pchrbancoord` | `CHAR(5)` | — | — |
| `pintTipoCtaOrd` | `CHAR(2)` | — | — |
| `pdigidord` | `CHAR(3)` | — | — |
| `pchraliasord` | `CHAR(10)` | — | — |
| `pvchrNombreBenef` | `CHAR(40)` | — | — |
| `pvchrCtaBenef` | `CHAR(20)` | — | — |
| `pchrbancobenf` | `CHAR(5)` | — | — |
| `pintTipoCtaBenef` | `CHAR(2)` | — | — |
| `pdigidben` | `CHAR(3)` | — | — |
| `pchraliasben` | `CHAR(20)` | — | — |
| `pchrfchmjc` | `CHAR(20)` | — | — |
| `pchartipopago` | `CHAR(2)` | — | — |
| `pchrUsuario` | `CHAR(8)` | — | — |
| `pintBancoDest` | `INTEGER` | — | — |
| `pchrFolioSuc` | `CHAR(16)` | — | — |
| `pdtfechacaptura` | `DATE` | — | — |
| `pvchrRFCOrd` | `VARCHAR(18)` | — | — |
| `pchrRFCBenef` | `VARCHAR(18)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cVarDataErr` | `CHAR(100)` | L65 |
| `vcodret` | `char(5)` | L66 |
| `vchrcodret` | `CHAR(5)` | L67 |
| `vchrcodret2` | `CHAR(5)` | L68 |
| `vcharcodret3` | `CHAR(50)` | L69 |
| `vintcodret` | `INTEGER` | L70 |
| `vintcodret2` | `INTEGER` | L71 |
| `vchrcodret3` | `CHAR(50)` | L72 |
| `vintPermiteCta11` | `INTEGER` | L73 |
| `vchrFuente` | `CHAR(7)` | L74 |
| `vchrTranscargo` | `CHAR(4)` | L75 |
| `vchrComis` | `CHAR(4)` | L76 |
| `vchrIvaComis` | `CHAR(4)` | L77 |
| `vchrtranret` | `CHAR(4)` | L78 |
| `dteFechacargo` | `DATE` | L79 |
| `vmnySdoDisp` | `MONEY(14,2)` | L80 |
| `vmnyMontoRet` | `MONEY(14,2)` | L81 |
| `vchrTarjeta` | `CHAR(20)` | L82 |
| `vtransaccion` | `INTEGER` | L83 |
| `vchrparametro` | `VARCHAR(255)` | L84 |
| `vchrFechaValor` | `VARCHAR(10)` | L85 |
| `dIva` | `DECIMAL(5,3)` | L86 |
| `vmnyMontoLibre` | `MONEY(14,2)` | L87 |
| `vdigitoverifica` | `SMALLINT` | L88 |
| `vexiste_suc` | `CHAR(4)` | L89 |
| *…84 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sc_maechq` | `bdicheq` | ⚠️ sí | SELECT | L300 |
| `si_cliente` | `bdinteg` | ⚠️ sí | SELECT | L313 |
| `sc_tarjeta` | `bdicheq` | ⚠️ sí | SELECT | L364 |
| `sc_cuenta_telefono` | `bdicheq` | ⚠️ sí | SELECT | L464 |
| `tf_maecte` | `bditransfer` | ⚠️ sí | SELECT | L470 |
| `tbl_stsprocodi` | `bdispei` | no | SELECT | L499 |
| `tbl_histstsprocodi` | `bdispei` | no | SELECT | L503 |
| `tblparametros` | `bdispei` | no | SELECT | L568 |
| `sc_fechas` | `bdicheq` | ⚠️ sí | SELECT | L589 |
| `si_param` | `bdinteg` | ⚠️ sí | SELECT | L784 |
| `sc_movdia` | `bdicheq` | ⚠️ sí | SELECT | L810 |
| `sc_movhis` | `bdicheq` | ⚠️ sí | SELECT | L815 |
| `si_sucursales` | `bdinteg` | ⚠️ sí | SELECT | L849 |
| `si_ejecut` | `bdinteg` | ⚠️ sí | SELECT | L868 |
| `tbltipopago` | `bdispei` | no | SELECT | L887 |
| `tbltipooperacion` | `bdispei` | no | SELECT | L912 |
| `tblbanco` | `bdispei` | no | SELECT | L950 |
| `tblpago` | `bdispei` | no | SELECT | L1036 |
| `tblhistpago` | `bdispei` | no | SELECT | L1041 |
| `tbldetranpago` | `bdispei` | no | INSERT | L1095 |
| `tblpago` | `bdispei` | no | INSERT | L1299 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `spei_recerrorescodi` | `bdispei` | no | L335 |
| `sp_validaspei_bpi` | `bdispei` | no | L649 |
| `spei_validaoperacion` | `bdispei` | no | L680 |
| `sp_validadv` | `bdispei` | no | L704 |
| `sp_obtsigfolioop` | `bdispei` | no | L1014 |
| `cargo_ref` | `bdicheq` | ⚠️ sí | L1066 |
| `sp_validafecha` | `bdispei` | no | L1140 |
| `sp_quitar_acentos` | `bdinteg` | ⚠️ sí | L1158 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L324 | VALIDACIÓN_NULL | `IF pvchrNombreOrd IS NULL OR pvchrNombreOrd = '' OR` |  |
| L333 | FÓRMULA | `LET vtimestamp  = dbinfo('utc_current') * 1000;` |  |
| L343 | VALIDACIÓN_NULL | `IF pvchrNombreBenef IS NULL OR pvchrNombreBenef = '' OR` |  |
| L349 | FÓRMULA | `LET vtimestamp  = dbinfo('utc_current') * 1000;` |  |
| L369 | VALIDACIÓN_NULL | `IF (vchrTarjeta is null) OR (vchrTarjeta = '') THEN` |  |
| L372 | FÓRMULA | `LET vtimestamp  = dbinfo('utc_current') * 1000;` |  |
| L391 | VALIDACIÓN_NULL | `IF pvchrCuentaOrd IS NULL OR pvchrCuentaOrd = '' THEN` |  |
| L394 | FÓRMULA | `LET vtimestamp  = dbinfo('utc_current') * 1000;` |  |
| L416 | VALIDACIÓN_NULL | `IF vchrCtaOrdClabe IS NULL THEN` |  |
| L419 | FÓRMULA | `LET vtimestamp  = dbinfo('utc_current') * 1000;` |  |
| L435 | FÓRMULA | `LET vtimestamp  = dbinfo('utc_current') * 1000;` |  |
| L447 | FÓRMULA | `LET vtimestamp  = dbinfo('utc_current') * 1000;` |  |
| L467 | VALIDACIÓN_NULL | `IF pvchrCuentaOrd is null OR pvchrCuentaOrd = '' THEN` |  |
| L481 | VALIDACIÓN_NULL | `IF vchrTelefono is null OR vchrTelefono = '' OR pvchrCuentaOrd is null OR pvchrCuentaOrd = '' THEN` |  |
| L484 | FÓRMULA | `LET vtimestamp  = dbinfo('utc_current') * 1000;` |  |
| L516 | VALIDACIÓN_NULL | `IF (vchrid IS NULL) AND (vchridhist IS NULL) THEN` |  |
| L519 | FÓRMULA | `LET vtimestamp  = dbinfo('utc_current') * 1000;` |  |
| L531 | FÓRMULA | `LET vtimestamp  = dbinfo('utc_current') * 1000;` |  |
| L542 | VALIDACIÓN_NULL | `IF vchrnombrebenaux = '' OR vchrnombrebenaux IS NULL THEN` |  |
| L555 | FÓRMULA | `LET vtimestamp  = dbinfo('utc_current') * 1000;` |  |
| L571 | FÓRMULA | `LET intBancoOrd = (vchrparametro * 1);` |  |
| L573 | VALIDACIÓN_NULL | `IF vchrparametro IS NULL THEN` |  |
| L577 | FÓRMULA | `LET vtimestamp  = dbinfo('utc_current') * 1000;` |  |
| L597 | FÓRMULA | `LET vtimestamp  = dbinfo('utc_current') * 1000;` |  |
| L619 | VALIDACIÓN_NULL | `IF vchrparametro IS NULL THEN` |  |
| L622 | FÓRMULA | `LET vtimestamp  = dbinfo('utc_current') * 1000;` |  |
| L635 | FÓRMULA | `LET vtimestamp  = dbinfo('utc_current') * 1000;` |  |
| L653 | FÓRMULA | `LET vtimestamp  = dbinfo('utc_current') * 1000;` |  |
| L666 | VALIDACIÓN_NULL | `IF (pdtfechacaptura is null) OR (pdtfechacaptura = '') then` |  |
| L669 | FÓRMULA | `LET vtimestamp  = dbinfo('utc_current') * 1000;` |  |
| | *…29 más…* | | |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `spei` | PREFIJO | familia SPEI (pagos interbancarios) | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `dev` | ACCION | devolución | 🔵 CONVENCIÓN | nombre_sp |
| `codi` | REG | CoDi — Cobro Digital (Banxico) | ✅ CÓDIGO | nombre_sp, texto_cuerpo |

---

## `spei_enaviprocodi`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_spei_enaviprocodi.sql` |
| **LOC (1er CREATE)** | 247 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 1 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "ENAVIPRO — tipo de mensaje SPEI · CoDi — Cobro Digital" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 1 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=1 · INFERIDO=1 · SINTÉTICO=0 / 3 términos |

### Firma

```sql
CREATE PROCEDURE spei_enaviprocodi(
) RETURNING CHAR(1500)
```

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vcodret` | `char(5)` | L6 |
| `vcodret2` | `char(5)` | L7 |
| `vcodret3` | `char(50)` | L8 |
| `sql_err` | `integer` | L9 |
| `isam_err` | `integer` | L10 |
| `desc_err` | `char(80)` | L11 |
| `wvchridtpa` | `CHAR(2)` | L13 |
| `wvchrcode` | `CHAR(2)` | L14 |
| `wvchridmjc` | `CHAR(20)` | L15 |
| `wvchrfchmjc` | `CHAR(20)` | L16 |
| `wvchrconcepto` | `CHAR(50)` | L17 |
| `wmnyimporte` | `DECIMAL(12,2)` | L18 |
| `wvchrfchfinpro` | `CHAR(23)` | L19 |
| `wvchrcveras` | `CHAR(30)` | L20 |
| `wvchrrefnum` | `CHAR(7)` | L21 |
| `wvchrcelord` | `CHAR(10)` | L22 |
| `wvchrdiveord` | `CHAR(3)` | L23 |
| `wvchrbancoord` | `CHAR(5)` | L24 |
| `wvchrtpoctaord` | `CHAR(2)` | L25 |
| `wvchrctaord` | `CHAR(20)` | L26 |
| `wvchrnomord` | `CHAR(40)` | L27 |
| `wvchrcelbenf` | `CHAR(20)` | L28 |
| `wvchrdivebenf` | `CHAR(3)` | L29 |
| `wvchrbancobenf` | `CHAR(5)` | L30 |
| `wvchrtpoctabenf` | `CHAR(2)` | L31 |
| *…11 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tbl_stsprocodi` | `bdispei` | no | SELECT | L109 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L44 | CÓDIGO_RETORNO | `LET vcodret  = '00000';` |  |
| L138 | VALIDACIÓN_NULL | `IF wvchrcveras IS NULL OR wvchrcveras = '' THEN` |  |
| L142 | VALIDACIÓN_NULL | `IF wvchrrefnum IS NULL OR wvchrrefnum = '' OR wvchrrefnum = '-' THEN` |  |
| L146 | VALIDACIÓN_NULL | `IF wvchrcelord IS NULL OR wvchrcelord = '' THEN` |  |
| L150 | VALIDACIÓN_NULL | `IF wvchrdiveord IS NULL OR wvchrdiveord = '' THEN` |  |
| L154 | VALIDACIÓN_NULL | `IF wvchrbancoord IS NULL  THEN` |  |
| L158 | VALIDACIÓN_NULL | `IF wvchrtpoctaord IS NULL OR wvchrtpoctaord = '' THEN` |  |
| L162 | VALIDACIÓN_NULL | `IF wvchrctaord IS NULL OR wvchrctaord = '' THEN` |  |
| L166 | VALIDACIÓN_NULL | `IF wvchrnomord IS NULL OR wvchrnomord = '' THEN` |  |
| L170 | VALIDACIÓN_NULL | `IF wvchrcelbenf IS NULL OR wvchrcelbenf = '' THEN` |  |
| L174 | VALIDACIÓN_NULL | `IF wvchrdivebenf IS NULL OR wvchrdivebenf = '' THEN` |  |
| L178 | VALIDACIÓN_NULL | `IF wvchrbancobenf IS NULL  THEN` |  |
| L182 | VALIDACIÓN_NULL | `IF wvchrtpoctabenf IS NULL OR wvchrtpoctabenf = '' THEN` |  |
| L186 | VALIDACIÓN_NULL | `IF wvchrctabef IS NULL OR wvchrctabef = '' THEN` |  |
| L190 | VALIDACIÓN_NULL | `IF wvchrnombenf IS NULL OR wvchrnombenf = '' THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `spei` | PREFIJO | familia SPEI (pagos interbancarios) | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `enavipro` | ENTIDAD | ENAVIPRO — tipo de mensaje SPEI (Envío de Aviso en Proceso / | 🟡 INFERIDO | nombre_sp |
| `codi` | REG | CoDi — Cobro Digital (Banxico) | 🔵 CONVENCIÓN | nombre_sp |

---

## `spei_enaviprocodi_exp1`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_spei_enaviprocodi_exp1.sql` |
| **LOC (1er CREATE)** | 220 |
| **Callgraph** | ✅ fan_in=0 / fan_out=7 |
| **Deps concatenadas** | 1 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "ENAVIPRO — tipo de mensaje SPEI (sufijo Exportar — SP genera/exporta archivo de salida) · CoDi — Cobro Digital" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `genera` → `SELECT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=2 · INFERIDO=2 · SINTÉTICO=1 / 5 términos |

### Firma

```sql
CREATE PROCEDURE spei_enaviprocodi_exp1(
) RETURNING CHAR(1500)
```

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vcodret` | `char(5)` | L4 |
| `vcodret2` | `char(5)` | L5 |
| `vcodret3` | `char(50)` | L6 |
| `sql_err` | `integer` | L7 |
| `isam_err` | `integer` | L8 |
| `desc_err` | `char(80)` | L9 |
| `wvchridtpa` | `CHAR(2)` | L11 |
| `wvchrcode` | `CHAR(2)` | L12 |
| `wvchridmjc` | `CHAR(20)` | L13 |
| `wvchrfchmjc` | `CHAR(20)` | L14 |
| `wvchrconcepto` | `CHAR(50)` | L15 |
| `wmnyimporte` | `DECIMAL(12,2)` | L16 |
| `wvchrfchfinpro` | `CHAR(23)` | L17 |
| `wvchrcveras` | `CHAR(30)` | L18 |
| `wvchrrefnum` | `CHAR(7)` | L19 |
| `wvchrcelord` | `CHAR(10)` | L20 |
| `wvchrdiveord` | `CHAR(3)` | L21 |
| `wvchrbancoord` | `CHAR(5)` | L22 |
| `wvchrtpoctaord` | `CHAR(2)` | L23 |
| `wvchrctaord` | `CHAR(20)` | L24 |
| `wvchrnomord` | `CHAR(40)` | L25 |
| `wvchrcelbenf` | `CHAR(20)` | L26 |
| `wvchrdivebenf` | `CHAR(3)` | L27 |
| `wvchrbancobenf` | `CHAR(5)` | L28 |
| `wvchrtpoctabenf` | `CHAR(2)` | L29 |
| *…11 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tbl_stsprocodi` | `bdispei` | no | SELECT | L106 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L42 | CÓDIGO_RETORNO | `LET vcodret  = '00000';` |  |
| L119 | VALIDACIÓN_NULL | `IF wvchrcveras IS NULL OR wvchrcveras = '' THEN` |  |
| L123 | VALIDACIÓN_NULL | `IF wvchrrefnum IS NULL OR wvchrrefnum = '' OR wvchrrefnum = '-' THEN` |  |
| L127 | VALIDACIÓN_NULL | `IF wvchrcelord IS NULL OR wvchrcelord = '' THEN` |  |
| L131 | VALIDACIÓN_NULL | `IF wvchrdiveord IS NULL OR wvchrdiveord = '' THEN` |  |
| L135 | VALIDACIÓN_NULL | `IF wvchrbancoord IS NULL  THEN` |  |
| L139 | VALIDACIÓN_NULL | `IF wvchrtpoctaord IS NULL OR wvchrtpoctaord = '' THEN` |  |
| L143 | VALIDACIÓN_NULL | `IF wvchrctaord IS NULL OR wvchrctaord = '' THEN` |  |
| L147 | VALIDACIÓN_NULL | `IF wvchrnomord IS NULL OR wvchrnomord = '' THEN` |  |
| L151 | VALIDACIÓN_NULL | `IF wvchrcelbenf IS NULL OR wvchrcelbenf = '' THEN` |  |
| L155 | VALIDACIÓN_NULL | `IF wvchrdivebenf IS NULL OR wvchrdivebenf = '' THEN` |  |
| L159 | VALIDACIÓN_NULL | `IF wvchrbancobenf IS NULL  THEN` |  |
| L163 | VALIDACIÓN_NULL | `IF wvchrtpoctabenf IS NULL OR wvchrtpoctabenf = '' THEN` |  |
| L167 | VALIDACIÓN_NULL | `IF wvchrctabef IS NULL OR wvchrctabef = '' THEN` |  |
| L171 | VALIDACIÓN_NULL | `IF wvchrnombenf IS NULL OR wvchrnombenf = '' THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `spei` | PREFIJO | familia SPEI (pagos interbancarios) | 🔵 CONVENCIÓN | nombre_sp |
| `enavipro` | ENTIDAD | ENAVIPRO — tipo de mensaje SPEI (Envío de Aviso en Proceso / | 🟡 INFERIDO | nombre_sp |
| `codi` | REG | CoDi — Cobro Digital (Banxico) | 🔵 CONVENCIÓN | nombre_sp |
| `exp` | MODIF | sufijo Exportar — SP genera/exporta archivo de salida (sp_*_ | 🟡 INFERIDO | nombre_sp |
| `?1` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?1` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `spei_enaviprocodiweb`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_spei_enaviprocodiweb.sql` |
| **LOC (1er CREATE)** | 246 |
| **Callgraph** | ✅ fan_in=0 / fan_out=5 |
| **Deps concatenadas** | 1 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "ENAVIPRO — tipo de mensaje SPEI (canal web) · CoDi — Cobro Digital" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 1 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=2 · INFERIDO=1 · SINTÉTICO=0 / 4 términos |

### Firma

```sql
CREATE PROCEDURE spei_enaviprocodiweb(
) RETURNING CHAR(1500)
```

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vcodret` | `char(5)` | L6 |
| `vcodret2` | `char(5)` | L7 |
| `vcodret3` | `char(50)` | L8 |
| `sql_err` | `integer` | L9 |
| `isam_err` | `integer` | L10 |
| `desc_err` | `char(80)` | L11 |
| `wvchridtpa` | `CHAR(2)` | L13 |
| `wvchrcode` | `CHAR(2)` | L14 |
| `wvchridmjc` | `CHAR(20)` | L15 |
| `wvchrfchmjc` | `CHAR(20)` | L16 |
| `wvchrconcepto` | `CHAR(50)` | L17 |
| `wmnyimporte` | `DECIMAL(12,2)` | L18 |
| `wvchrfchfinpro` | `CHAR(23)` | L19 |
| `wvchrcveras` | `CHAR(30)` | L20 |
| `wvchrrefnum` | `CHAR(7)` | L21 |
| `wvchrcelord` | `CHAR(10)` | L22 |
| `wvchrdiveord` | `CHAR(3)` | L23 |
| `wvchrbancoord` | `CHAR(5)` | L24 |
| `wvchrtpoctaord` | `CHAR(2)` | L25 |
| `wvchrctaord` | `CHAR(20)` | L26 |
| `wvchrnomord` | `CHAR(40)` | L27 |
| `wvchrcelbenf` | `CHAR(20)` | L28 |
| `wvchrdivebenf` | `CHAR(3)` | L29 |
| `wvchrbancobenf` | `CHAR(5)` | L30 |
| `wvchrtpoctabenf` | `CHAR(2)` | L31 |
| *…11 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tbl_stsprocodi` | `bdispei` | no | SELECT | L109 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L44 | CÓDIGO_RETORNO | `LET vcodret  = '00000';` |  |
| L137 | VALIDACIÓN_NULL | `IF wvchrcveras IS NULL OR wvchrcveras = '' THEN` |  |
| L141 | VALIDACIÓN_NULL | `IF wvchrrefnum IS NULL OR wvchrrefnum = '' OR wvchrrefnum = '-' THEN` |  |
| L145 | VALIDACIÓN_NULL | `IF wvchrcelord IS NULL OR wvchrcelord = '' THEN` |  |
| L149 | VALIDACIÓN_NULL | `IF wvchrdiveord IS NULL OR wvchrdiveord = '' THEN` |  |
| L153 | VALIDACIÓN_NULL | `IF wvchrbancoord IS NULL  THEN` |  |
| L157 | VALIDACIÓN_NULL | `IF wvchrtpoctaord IS NULL OR wvchrtpoctaord = '' THEN` |  |
| L161 | VALIDACIÓN_NULL | `IF wvchrctaord IS NULL OR wvchrctaord = '' THEN` |  |
| L165 | VALIDACIÓN_NULL | `IF wvchrnomord IS NULL OR wvchrnomord = '' THEN` |  |
| L169 | VALIDACIÓN_NULL | `IF wvchrcelbenf IS NULL OR wvchrcelbenf = '' THEN` |  |
| L173 | VALIDACIÓN_NULL | `IF wvchrdivebenf IS NULL OR wvchrdivebenf = '' THEN` |  |
| L177 | VALIDACIÓN_NULL | `IF wvchrbancobenf IS NULL  THEN` |  |
| L181 | VALIDACIÓN_NULL | `IF wvchrtpoctabenf IS NULL OR wvchrtpoctabenf = '' THEN` |  |
| L185 | VALIDACIÓN_NULL | `IF wvchrctabef IS NULL OR wvchrctabef = '' THEN` |  |
| L189 | VALIDACIÓN_NULL | `IF wvchrnombenf IS NULL OR wvchrnombenf = '' THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `spei` | PREFIJO | familia SPEI (pagos interbancarios) | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `enavipro` | ENTIDAD | ENAVIPRO — tipo de mensaje SPEI (Envío de Aviso en Proceso / | 🟡 INFERIDO | nombre_sp |
| `codi` | REG | CoDi — Cobro Digital (Banxico) | 🔵 CONVENCIÓN | nombre_sp |
| `web` | MODIF | canal web | 🔵 CONVENCIÓN | nombre_sp |

---

## `spei_encbanope`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_spei_encbanope.sql` |
| **LOC (1er CREATE)** | 70 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 1 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "operación" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 2 tabla(s) con operaciones: SELECT, UPDATE |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=0 · INFERIDO=1 · SINTÉTICO=1 / 3 términos |

### Firma

```sql
CREATE PROCEDURE spei_encbanope(
) RETURNING CHAR(5), CHAR(100)
```

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `var_valor` | `CHAR(1)` | L9 |
| `vcodret` | `CHAR(5)` | L10 |
| `vSqlErr` | `INTEGER` | L11 |
| `isam_err` | `INTEGER` | L12 |
| `error_info` | `CHAR(100)` | L13 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tblparametros` | `bdispei` | no | SELECT | L40 |
| `tblparametros` | `bdispei` | no | UPDATE | L44 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L16 | CÓDIGO_RETORNO | `LET	vcodret = '00000';` |  |
| L46 | CÓDIGO_RETORNO | `LET vcodret = '00000';` |  |
| L50 | CÓDIGO_RETORNO | `LET vcodret = '01110';` |  |
| L54 | CÓDIGO_RETORNO | `LET vcodret = '11110';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `spei` | PREFIJO | familia SPEI (pagos interbancarios) | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?_encban` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `ope` | ACCION | operación | 🟡 INFERIDO | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_encban` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `spei_entordenespago`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_spei_entordenespago.sql` |
| **LOC (1er CREATE)** | 310 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "órdenes y pago" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 1 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=1 / 4 términos |

### Firma

```sql
CREATE PROCEDURE spei_entordenespago(
) RETURNING CHAR(30),      -- clave de rastreo
```

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vCodRet1` | `CHAR(5)` | L43 |
| `vCodRet2` | `CHAR(5)` | L44 |
| `vSqlErr` | `INTEGER` | L45 |
| `vIsamErr` | `INTEGER` | L46 |
| `wempresa` | `CHAR(3)` | L48 |
| `wvchrclaverastreo` | `CHAR(30)` | L49 |
| `wintcvetipopago` | `CHAR(2)` | L50 |
| `wdtfechavalor` | `DATE` | L51 |
| `wdtfechavalor2` | `CHAR(8)` | L52 |
| `wmnyimporte` | `DECIMAL(17,2)` | L53 |
| `wcvecesifbcodest` | `INTEGER` | L54 |
| `wcvecesifbcoord` | `CHAR(5)` | L55 |
| `wvchrnombreord` | `CHAR(40)` | L56 |
| `wintcvetipoctaord` | `CHAR(2)` | L57 |
| `wvchrcuentaord` | `CHAR(20)` | L58 |
| `wvchrrfcord` | `CHAR(18)` | L59 |
| `wvchrnombrebenef` | `CHAR(40)` | L60 |
| `wintcvetipoctabene` | `CHAR(2)` | L61 |
| `wvchrcuentabenef` | `CHAR(20)` | L62 |
| `wvchrrfcbenef` | `CHAR(18)` | L63 |
| `wvchrnombrebenef2` | `CHAR(40)` | L64 |
| `wintcvetipoctabene2` | `CHAR(2)` | L65 |
| `wvchrrfcbenef2` | `CHAR(18)` | L66 |
| `wvchrconceptopago` | `CHAR(210)` | L67 |
| `wmnyiva` | `DECIMAL(17,2)` | L68 |
| *…37 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tblpago` | `bdispei` | no | SELECT | L227 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `spei` | PREFIJO | familia SPEI (pagos interbancarios) | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?_ent` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `ordenes` | ENTIDAD | órdenes | 🔵 CONVENCIÓN | nombre_sp |
| `pago` | ENTIDAD | pago | ✅ CÓDIGO | nombre_sp, texto_cuerpo |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_ent` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `spei_entordenespago_mib`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_spei_entordenespago_mib.sql` |
| **LOC (1er CREATE)** | 291 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "órdenes, pago y MIB — módulo/canal de integración para cheques y tarjeta" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 1 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=1 · INFERIDO=1 · SINTÉTICO=1 / 5 términos |

### Firma

```sql
CREATE PROCEDURE spei_entordenespago_mib(
) RETURNING CHAR(30),      -- clave de rastreo
```

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vCodRet1` | `CHAR(5)` | L43 |
| `vCodRet2` | `CHAR(5)` | L44 |
| `vSqlErr` | `INTEGER` | L45 |
| `vIsamErr` | `INTEGER` | L46 |
| `wempresa` | `CHAR(3)` | L48 |
| `wvchrclaverastreo` | `CHAR(30)` | L49 |
| `wintcvetipopago` | `CHAR(2)` | L50 |
| `wdtfechavalor` | `DATE` | L51 |
| `wdtfechavalor2` | `CHAR(8)` | L52 |
| `wmnyimporte` | `DECIMAL(17,2)` | L53 |
| `wcvecesifbcodest` | `INTEGER` | L54 |
| `wcvecesifbcoord` | `CHAR(5)` | L55 |
| `wvchrnombreord` | `CHAR(40)` | L56 |
| `wintcvetipoctaord` | `CHAR(2)` | L57 |
| `wvchrcuentaord` | `CHAR(20)` | L58 |
| `wvchrrfcord` | `CHAR(18)` | L59 |
| `wvchrnombrebenef` | `CHAR(40)` | L60 |
| `wintcvetipoctabene` | `CHAR(2)` | L61 |
| `wvchrcuentabenef` | `CHAR(20)` | L62 |
| `wvchrrfcbenef` | `CHAR(18)` | L63 |
| `wvchrnombrebenef2` | `CHAR(40)` | L64 |
| `wintcvetipoctabene2` | `CHAR(2)` | L65 |
| `wvchrrfcbenef2` | `CHAR(18)` | L66 |
| `wvchrconceptopago` | `CHAR(210)` | L67 |
| `wmnyiva` | `DECIMAL(17,2)` | L68 |
| *…36 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tblpago` | `bdispei` | no | SELECT | L219 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `spei` | PREFIJO | familia SPEI (pagos interbancarios) | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?_ent` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `ordenes` | ENTIDAD | órdenes | 🔵 CONVENCIÓN | nombre_sp |
| `pago` | ENTIDAD | pago | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `mib` | ENTIDAD | MIB — módulo/canal de integración para cheques y tarjeta (ca | 🟡 INFERIDO | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_ent` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `spei_entordenespago_oxo`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_spei_entordenespago_oxo.sql` |
| **LOC (1er CREATE)** | 164 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "órdenes, pago y OXXO" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 1 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=1 · INFERIDO=1 · SINTÉTICO=1 / 5 términos |

### Firma

```sql
CREATE PROCEDURE spei_entordenespago_oxo(
) RETURNING CHAR(30),      -- clave de rastreo
```

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vCodRet1` | `CHAR(5)` | L32 |
| `vCodRet2` | `CHAR(5)` | L33 |
| `vSqlErr` | `INTEGER` | L34 |
| `vIsamErr` | `INTEGER` | L35 |
| `wempresa` | `CHAR(3)` | L37 |
| `wvchrclaverastreo` | `CHAR(30)` | L38 |
| `wintcvetipopago` | `CHAR(2)` | L39 |
| `wdtfechavalor` | `DATE` | L40 |
| `wdtfechavalor2` | `CHAR(8)` | L41 |
| `wmnyimporte` | `DECIMAL(17,2)` | L42 |
| `wcvecesifbcodest` | `CHAR(5)` | L43 |
| `wcvecesifbcoord` | `CHAR(5)` | L44 |
| `wvchrnombreord` | `CHAR(40)` | L45 |
| `wintcvetipoctaord` | `CHAR(2)` | L46 |
| `wvchrcuentaord` | `CHAR(20)` | L47 |
| `wvchrrfcord` | `CHAR(18)` | L48 |
| `wvchrnombrebenef` | `CHAR(40)` | L49 |
| `wintcvetipoctabene` | `CHAR(2)` | L50 |
| `wvchrcuentabenef` | `CHAR(20)` | L51 |
| `wvchrrfcbenef` | `CHAR(18)` | L52 |
| `wvchrnombrebenef2` | `CHAR(40)` | L53 |
| `wintcvetipoctabene2` | `CHAR(2)` | L54 |
| `wvchrrfcbenef2` | `CHAR(18)` | L55 |
| `wvchrconceptopago` | `CHAR(210)` | L56 |
| `wmnyiva` | `DECIMAL(17,2)` | L57 |
| *…9 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tblpago` | `bdispei` | no | SELECT | L143 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `spei` | PREFIJO | familia SPEI (pagos interbancarios) | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?_ent` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `ordenes` | ENTIDAD | órdenes | 🔵 CONVENCIÓN | nombre_sp |
| `pago` | ENTIDAD | pago | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `oxo` | ENTIDAD | OXXO (abreviación — spei_entordenespago_oxo) | 🟡 INFERIDO | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_ent` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `spei_envextemporanea`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_spei_envextemporanea.sql` |
| **LOC (1er CREATE)** | 181 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "(extemporánea)" `[partial]` |
| **Propósito verificado** | ❓ NO_VERIFICABLE — Propósito inferido; sin evidencia DML para verificar |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=1 / 3 términos |

### Firma

```sql
CREATE PROCEDURE spei_envextemporanea(
  pClaveRastreo                CHAR(30)
) RETURNING CHAR(30), 		-- folio original del sistema pisa
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pClaveRastreo` | `CHAR(30)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vCodRet1` | `CHAR(5)` | L12 |
| `vCodRet2` | `CHAR(5)` | L13 |
| `vSqlErr` | `INTEGER` | L14 |
| `vIsamErr` | `INTEGER` | L15 |
| `cEmpresa` | `CHAR(3)` | L16 |
| `iSerialFolio` | `INTEGER` | L17 |
| `cNumTarjeta` | `CHAR(16)` | L18 |
| `iMaxSec` | `SMALLINT` | L19 |
| `cSucursal` | `CHAR(4)` | L20 |
| `cUsuario` | `CHAR(8)` | L21 |
| `cDivisa` | `CHAR(2)` | L22 |
| `cTransacc` | `CHAR(4)` | L23 |
| `dtFechaCargo` | `DATE` | L24 |
| `dDispo` | `DECIMAL(18,2)` | L25 |
| `dCargo` | `DECIMAL(18,2)` | L26 |
| `cCuenta` | `CHAR(20)` | L27 |
| `dMontoCgoInt` | `DECIMAL(16,2)` | L28 |
| `dCargoTotal` | `DECIMAL(18,2)` | L29 |
| `vcod_ret` | `char(5)` | L31 |
| `cCuenta1` | `char(20)` | L32 |
| `vnum_cte` | `char(20)` | L33 |
| `vapell_pat` | `char(26)` | L34 |
| `vapell_mat` | `char(26)` | L35 |
| `vnombre1` | `char(26)` | L36 |
| `vnombre2` | `char(26)` | L37 |
| *…26 más…* | | |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L162 | VALIDACIÓN_NULL | `IF (pMonto IS NULL OR pMonto <= 0) OR (pClaveRastreo IS NULL OR pClaveRastreo = "") OR (pCuentaBenef` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `spei` | PREFIJO | familia SPEI (pagos interbancarios) | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?_env` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `extemporanea` | MODIF | extemporánea | 🔵 CONVENCIÓN | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_env` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `spei_pasemovspeich`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_spei_pasemovspeich.sql` |
| **LOC (1er CREATE)** | 474 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 1 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "pase contable movimientos" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 11 tabla(s) con operaciones: INSERT, SELECT, UPDATE, DELETE |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=2 · INFERIDO=1 · SINTÉTICO=1 / 4 términos |

### Firma

```sql
CREATE PROCEDURE spei_pasemovspeich(
  pfechaejecuta                date
) RETURNING char(5),char(100)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pfechaejecuta` | `date` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vsql_err` | `integer` | L4 |
| `visam_err` | `integer` | L5 |
| `vcodret` | `char (10)` | L6 |
| `vcodret2` | `char (100)` | L7 |
| `vestadoctrl` | `char(1)` | L8 |
| `vsql` | `char(250)` | L9 |
| `vmes` | `Char(2)` | L10 |
| `vdia` | `Char(2)` | L11 |
| `vanio` | `char(4)` | L12 |
| `vfechaarch` | `char(8)` | L13 |
| `vstmt` | `char(150)` | L14 |
| `vComienza` | `SMALLINT` | L16 |
| `vAbierto` | `CHAR(1)` | L17 |
| `vContador1` | `INTEGER` | L18 |
| `vContador2` | `INTEGER` | L19 |
| `vintfoliopago` | `INTEGER` | L21 |
| `vintpkpago` | `INTEGER` | L22 |
| `vintcvecausadev` | `INTEGER` | L23 |
| `vintpkpaqueteenv` | `INTEGER` | L24 |
| `vmnyimporte` | `DECIMAL(19,2)` | L25 |
| `vcvecesifbcoord` | `INTEGER` | L26 |
| `vcvecesifbcodest` | `INTEGER` | L27 |
| `vchrestatusenvio` | `CHAR(1)` | L28 |
| `vvchrnombreord` | `CHAR(40)` | L29 |
| `vvchrcuentaord` | `CHAR(20)` | L30 |
| *…64 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sc_fechas` | `bdicheq` | ⚠️ sí | SELECT | L205 |
| `tblctrlproceso` | `bdispei` | no | SELECT | L217 |
| `tblctrlproceso` | `bdispei` | no | DELETE | L227 |
| `tblctrlproceso` | `bdispei` | no | INSERT | L231 |
| `systabnames` | `sysmaster` | ⚠️ sí | SELECT | L236 |
| `tblhistpago_temp` | `bdispei` | no | INSERT | L329 |
| `tblhistpago` | `bdispei` | no | INSERT | L348 |
| `tblhistpago_temp` | `bdispei` | no | SELECT | L350 |
| `tblhistpago_temp` | `bdispei` | no | UPDATE | L383 |
| `tblhistpago` | `bdispei` | no | SELECT | L403 |
| `tblctrlproceso` | `bdispei` | no | UPDATE | L448 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L110 | FÓRMULA | `LET vComienza           = -1;` |  |
| L208 | VALIDACIÓN_NULL | `IF (pfechaejecuta is null) or (pfechaejecuta = '') THEN` |  |
| L226 | VALIDACIÓN_NULL | `IF (vestadoctrl IS NULL) OR (vestadoctrl = '') OR (vestadoctrl = '0') THEN` |  |
| L329 | FÓRMULA | `let vsql = 'echo "load from /home/sysspei/MovSPEICH'\|\|vfechaarch\|\|'.txt insert into tblhistpago_` |  |
| L333 | FÓRMULA | `let vstmt = 'dbaccess bdispei /home/sysspei/query.sql';` |  |
| L381 | VALIDACIÓN_NULL | `IF vdtfechavalor is null OR vdtfechavalor = ' '  THEN` |  |
| L391 | VALIDACIÓN_NULL | `IF vdtfechacaptura is null OR vdtfechacaptura = ' ' THEN` |  |
| L408 | VALIDACIÓN_NULL | `IF v_existe = '' OR v_existe is null OR v_existe <> '1' THEN` |  |
| L431 | FÓRMULA | `LET vcontador1 = vcontador1 + 1;` |  |
| L432 | FÓRMULA | `LET vcontador2 = vcontador2 + 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `spei` | PREFIJO | familia SPEI (pagos interbancarios) | 🔵 CONVENCIÓN | nombre_sp |
| `pase` | ACCION | pase contable (registra/traslada a póliza o mayor) | 🔵 CONVENCIÓN | nombre_sp |
| `movs` | ENTIDAD | movimientos (abreviación) | 🟡 INFERIDO | nombre_sp |
| `?peich` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?peich` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `spei_pasemovspeich_2`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_spei_pasemovspeich_2.sql` |
| **LOC (1er CREATE)** | 492 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "pase contable movimientos" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 11 tabla(s) con operaciones: INSERT, SELECT, UPDATE, DELETE |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=2 · INFERIDO=1 · SINTÉTICO=1 / 4 términos |

### Firma

```sql
CREATE PROCEDURE spei_pasemovspeich_2(
  pfechaejecuta_var            VARCHAR(15)
) RETURNING char(5),char(100)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pfechaejecuta_var` | `VARCHAR(15)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vsql_err` | `integer` | L4 |
| `visam_err` | `integer` | L5 |
| `vcodret` | `char (10)` | L6 |
| `vcodret2` | `char (100)` | L7 |
| `vestadoctrl` | `char(1)` | L8 |
| `vsql` | `char(250)` | L9 |
| `vmes` | `Char(2)` | L10 |
| `vdia` | `Char(2)` | L11 |
| `vanio` | `char(4)` | L12 |
| `vfechaarch` | `char(8)` | L13 |
| `vstmt` | `char(150)` | L14 |
| `pfechaejecuta` | `date` | L16 |
| `vComienza` | `SMALLINT` | L18 |
| `vAbierto` | `CHAR(1)` | L19 |
| `vContador1` | `INTEGER` | L20 |
| `vContador2` | `INTEGER` | L21 |
| `vintfoliopago` | `INTEGER` | L23 |
| `vintpkpago` | `INTEGER` | L24 |
| `vintcvecausadev` | `INTEGER` | L25 |
| `vintpkpaqueteenv` | `INTEGER` | L26 |
| `vmnyimporte` | `DECIMAL(19,2)` | L27 |
| `vcvecesifbcoord` | `INTEGER` | L28 |
| `vcvecesifbcodest` | `INTEGER` | L29 |
| `vchrestatusenvio` | `CHAR(1)` | L30 |
| `vvchrnombreord` | `CHAR(40)` | L31 |
| *…65 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sc_fechas` | `bdicheq` | ⚠️ sí | SELECT | L208 |
| `tblctrlproceso` | `bdispei` | no | SELECT | L225 |
| `tblctrlproceso` | `bdispei` | no | DELETE | L241 |
| `tblctrlproceso` | `bdispei` | no | INSERT | L245 |
| `systabnames` | `sysmaster` | ⚠️ sí | SELECT | L250 |
| `tblhistpago_temp` | `bdispei` | no | INSERT | L344 |
| `tblhistpago` | `bdispei` | no | INSERT | L363 |
| `tblhistpago_temp` | `bdispei` | no | SELECT | L365 |
| `tblhistpago_temp` | `bdispei` | no | UPDATE | L398 |
| `tblhistpago` | `bdispei` | no | SELECT | L425 |
| `tblctrlproceso` | `bdispei` | no | UPDATE | L475 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L112 | FÓRMULA | `LET vComienza           = -1;` |  |
| L211 | FÓRMULA | `LET pfechaejecuta = to_date(pfechaejecuta_var,'%Y/%m/%d' ); --se ejecuta para prueba controlada` |  |
| L214 | VALIDACIÓN_NULL | `IF (pfechaejecuta is null) or (pfechaejecuta = '') THEN` |  |
| L238 | VALIDACIÓN_NULL | `IF (vestadoctrl IS NULL) OR (vestadoctrl = '') OR (vestadoctrl = '0') THEN` |  |
| L344 | FÓRMULA | `let vsql = 'echo "load from /home/sysspei/MovSPEICH'\|\|vfechaarch\|\|'.txt insert into tblhistpago_` |  |
| L348 | FÓRMULA | `let vstmt = 'dbaccess bdispei /home/sysspei/query.sql';` |  |
| L396 | VALIDACIÓN_NULL | `IF vdtfechavalor is null OR vdtfechavalor = ' '  THEN` |  |
| L406 | VALIDACIÓN_NULL | `IF vdtfechacaptura is null OR vdtfechacaptura = ' ' THEN` |  |
| L418 | FÓRMULA | `let vvchrnombreord = replace( replace( replace(vvchrnombreord,'/',' ') , '\\\\\', ' '), '#', ' ');` |  |
| L419 | FÓRMULA | `let vvchrnombrebenef = replace( replace( replace(vvchrnombrebenef,'/',' ') , '\\\\\', ' '), '#', ' '` |  |
| L420 | FÓRMULA | `let vvchrnombrebenef2 = replace( replace( replace(vvchrnombrebenef2,'/',' ') , '\\\\\', ' '), '#', '` |  |
| L421 | FÓRMULA | `let vvchrconceptopago = replace( replace( replace(vvchrconceptopago,'/',' ') , '\\\\\', ' '), '#', '` |  |
| L430 | VALIDACIÓN_NULL | `IF v_existe = '' OR v_existe is null OR v_existe <> '1' THEN` |  |
| L455 | FÓRMULA | `LET vcontador1 = vcontador1 + 1;` |  |
| L456 | FÓRMULA | `LET vcontador2 = vcontador2 + 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `spei` | PREFIJO | familia SPEI (pagos interbancarios) | 🔵 CONVENCIÓN | nombre_sp |
| `pase` | ACCION | pase contable (registra/traslada a póliza o mayor) | 🔵 CONVENCIÓN | nombre_sp |
| `movs` | ENTIDAD | movimientos (abreviación) | 🟡 INFERIDO | nombre_sp |
| `?peich_2` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?peich_2` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `spei_pasemovspeich_esp`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_spei_pasemovspeich_esp.sql` |
| **LOC (1er CREATE)** | 412 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "pase contable movimientos (especial)" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 8 tabla(s) con operaciones: INSERT, SELECT, UPDATE, DELETE |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=3 · INFERIDO=1 · SINTÉTICO=1 / 5 términos |

### Firma

```sql
CREATE PROCEDURE spei_pasemovspeich_esp(
  pfechaejecuta                DATE
) RETURNING char(5),char(100)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pfechaejecuta` | `DATE` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vsql_err` | `integer` | L4 |
| `visam_err` | `integer` | L5 |
| `vcodret` | `char (10)` | L6 |
| `vcodret2` | `char (100)` | L7 |
| `vestadoctrl` | `char(1)` | L8 |
| `vsql` | `char(150)` | L9 |
| `vmes` | `Char(2)` | L10 |
| `vdia` | `Char(2)` | L11 |
| `vanio` | `char(4)` | L12 |
| `vfechaarch` | `char(8)` | L13 |
| `vstmt` | `char(150)` | L14 |
| `vComienza` | `SMALLINT` | L16 |
| `vAbierto` | `CHAR(1)` | L17 |
| `vContador1` | `INTEGER` | L18 |
| `vContador2` | `INTEGER` | L19 |
| `vintfoliopago` | `INTEGER` | L21 |
| `vintpkpago` | `INTEGER` | L22 |
| `vintcvecausadev` | `INTEGER` | L23 |
| `vintpkpaqueteenv` | `INTEGER` | L24 |
| `vmnyimporte` | `DECIMAL(19,2)` | L25 |
| `vcvecesifbcoord` | `INTEGER` | L26 |
| `vcvecesifbcodest` | `INTEGER` | L27 |
| `vchrestatusenvio` | `CHAR(1)` | L28 |
| `vvchrnombreord` | `CHAR(40)` | L29 |
| `vvchrcuentaord` | `CHAR(20)` | L30 |
| *…63 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tblctrlproceso` | `bdispei` | no | SELECT | L208 |
| `tblctrlproceso` | `bdispei` | no | DELETE | L218 |
| `tblctrlproceso` | `bdispei` | no | INSERT | L222 |
| `systabnames` | `sysmaster` | ⚠️ sí | SELECT | L227 |
| `tblhistpago_temp` | `bdispei` | no | INSERT | L319 |
| `tblhistpago_temp` | `bdispei` | no | SELECT | L345 |
| `tblhistpago` | `bdispei` | no | INSERT | L361 |
| `tblctrlproceso` | `bdispei` | no | UPDATE | L397 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L108 | FÓRMULA | `LET vComienza           = -1;` |  |
| L199 | VALIDACIÓN_NULL | `IF (pfechaejecuta is null) or (pfechaejecuta = '') THEN` |  |
| L217 | VALIDACIÓN_NULL | `IF (vestadoctrl IS NULL) OR (vestadoctrl = '') OR (vestadoctrl = '0') THEN` |  |
| L319 | FÓRMULA | `let vsql = 'echo "load from /home/sysspei/MovSPEICH'\|\|vfechaarch\|\|'.txt insert into tblhistpago_` |  |
| L323 | FÓRMULA | `let vstmt = 'dbaccess bdispei /home/sysspei/query.sql';` |  |
| L353 | VALIDACIÓN_NULL | `IF vdtfechavalor is null OR vdtfechavalor = ' '  THEN` |  |
| L357 | VALIDACIÓN_NULL | `IF vdtfechacaptura is null OR vdtfechacaptura = ' ' THEN` |  |
| L382 | FÓRMULA | `LET vcontador1 = vcontador1 + 1;` |  |
| L383 | FÓRMULA | `LET vcontador2 = vcontador2 + 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `spei` | PREFIJO | familia SPEI (pagos interbancarios) | 🔵 CONVENCIÓN | nombre_sp |
| `pase` | ACCION | pase contable (registra/traslada a póliza o mayor) | 🔵 CONVENCIÓN | nombre_sp |
| `movs` | ENTIDAD | movimientos (abreviación) | 🟡 INFERIDO | nombre_sp |
| `?peich_` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `esp` | MODIF | especial | 🔵 CONVENCIÓN | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?peich_` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `spei_realizacargo`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_spei_realizacargo.sql` |
| **LOC (1er CREATE)** | 435 |
| **Callgraph** | ✅ fan_in=0 / fan_out=3 |
| **Propósito inferido** | "realiza cargo" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 3 llamada(s): `cons_sdos1`, `sp_obtfoliosuc`, `cargo_ref` |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=0 · INFERIDO=1 · SINTÉTICO=0 / 3 términos |

### Firma

```sql
CREATE PROCEDURE spei_realizacargo(
  pvchrclaverastreo            CHAR(30)
) RETURNING CHAR(30)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pvchrclaverastreo` | `CHAR(30)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vCodRet1` | `CHAR(5)` | L11 |
| `vCodRet2` | `CHAR(5)` | L12 |
| `vSqlErr` | `INTEGER` | L13 |
| `vIsamErr` | `INTEGER` | L14 |
| `wempresa` | `CHAR(3)` | L16 |
| `whora` | `CHAR(15)` | L17 |
| `wserial_folio` | `INTEGER` | L18 |
| `wfolio_suc` | `CHAR(30)` | L19 |
| `wcuenta` | `CHAR(20)` | L20 |
| `wnum_tarjeta` | `CHAR(16)` | L21 |
| `wmaxsec` | `SMALLINT` | L22 |
| `wsuc_cta` | `CHAR(4)` | L23 |
| `wsucursal` | `CHAR(4)` | L24 |
| `wusuario` | `CHAR(8)` | L25 |
| `wtransacc` | `CHAR(4)` | L26 |
| `wdivisa` | `CHAR(2)` | L27 |
| `vtransacc` | `CHAR(4)` | L28 |
| `vfecha_cargo` | `DATE` | L29 |
| `vdispo` | `DECIMAL(18,2)` | L30 |
| `vcargo` | `DECIMAL(18,2)` | L31 |
| `wexisteclave` | `CHAR(30)` | L32 |
| `vcuenta` | `CHAR(20)` | L33 |
| `wmonto_comision` | `DECIMAL(16,2)` | L34 |
| `wvalor_iva` | `DECIMAL(9,6)` | L35 |
| `wmonto_iva` | `DECIMAL(14,2)` | L36 |
| *…30 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tblpago` | `bdispei` | no | SELECT | L175 |
| `sc_tarjeta` | `bdicheq` | ⚠️ sí | SELECT | L182 |
| `sc_cuenta_telefono` | `bdicheq` | ⚠️ sí | SELECT | L227 |
| `sc_movdia` | `bdicheq` | ⚠️ sí | SELECT | L249 |
| `tf_maecte` | `bditransfer` | ⚠️ sí | SELECT | L263 |
| `sc_maechq` | `bdicheq` | ⚠️ sí | SELECT | L271 |
| `tblcomision` | `bdispei` | no | SELECT | L291 |
| `si_param` | `bdinteg` | ⚠️ sí | SELECT | L296 |
| `tblparametros` | `bdispei` | no | SELECT | L351 |
| `si_transacc` | `bdinteg` | ⚠️ sí | SELECT | L362 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `cons_sdos1` | `bdicheq` | ⚠️ sí | L317 |
| `sp_obtfoliosuc` | `bdispei` | no | L326 |
| `cargo_ref` | `bdicheq` | ⚠️ sí | L341 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L259 | VALIDACIÓN_NULL | `IF wexisteclave is null OR wexisteclave = '' THEN` |  |
| L276 | VALIDACIÓN_NULL | `IF vcuenta is null OR vcuenta = '' THEN` |  |
| L300 | FÓRMULA | `LET wmonto_iva = wmonto_comision * wvalor_iva;` | 🔴 MONEY/aritmética financiera |
| L301 | FÓRMULA | `LET wcargo_total = pmnyimporte + wmonto_comision + wmonto_iva;` | 🔴 MONEY/aritmética financiera |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `spei` | PREFIJO | familia SPEI (pagos interbancarios) | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `realiza` | ACCION | realiza / ejecuta una operación SPEI | 🟡 INFERIDO | nombre_sp |
| `cargo` | ENTIDAD | cargo / débito | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |

---

## `spei_realizacargo_exp1`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_spei_realizacargo_exp1.sql` |
| **LOC (1er CREATE)** | 456 |
| **Callgraph** | ✅ fan_in=0 / fan_out=3 |
| **Propósito inferido** | "realiza cargo (sufijo Exportar — SP genera/exporta archivo de salida)" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `genera` → `SELECT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=0 · INFERIDO=2 · SINTÉTICO=1 / 5 términos |

### Firma

```sql
CREATE PROCEDURE spei_realizacargo_exp1(
  pvchrclaverastreo            CHAR(30)
) RETURNING CHAR(30)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pvchrclaverastreo` | `CHAR(30)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vCodRet1` | `CHAR(5)` | L11 |
| `vCodRet2` | `CHAR(5)` | L12 |
| `vSqlErr` | `INTEGER` | L13 |
| `vIsamErr` | `INTEGER` | L14 |
| `wempresa` | `CHAR(3)` | L16 |
| `whora` | `CHAR(15)` | L17 |
| `wserial_folio` | `INTEGER` | L18 |
| `wfolio_suc` | `CHAR(30)` | L19 |
| `wcuenta` | `CHAR(20)` | L20 |
| `wnum_tarjeta` | `CHAR(16)` | L21 |
| `wmaxsec` | `SMALLINT` | L22 |
| `wsuc_cta` | `CHAR(4)` | L23 |
| `wsucursal` | `CHAR(4)` | L24 |
| `wusuario` | `CHAR(8)` | L25 |
| `wtransacc` | `CHAR(4)` | L26 |
| `wdivisa` | `CHAR(2)` | L27 |
| `vtransacc` | `CHAR(4)` | L28 |
| `vfecha_cargo` | `DATE` | L29 |
| `vdispo` | `DECIMAL(18,2)` | L30 |
| `vcargo` | `DECIMAL(18,2)` | L31 |
| `wexisteclave` | `CHAR(30)` | L32 |
| `vcuenta` | `CHAR(20)` | L33 |
| `wmonto_comision` | `DECIMAL(16,2)` | L34 |
| `wvalor_iva` | `DECIMAL(9,6)` | L35 |
| `wmonto_iva` | `DECIMAL(14,2)` | L36 |
| *…32 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tblpago` | `bdispei` | no | SELECT | L180 |
| `sc_tarjeta` | `bdicheq` | ⚠️ sí | SELECT | L187 |
| `sc_cuenta_telefono` | `bdicheq` | ⚠️ sí | SELECT | L232 |
| `sc_movdia` | `bdicheq` | ⚠️ sí | SELECT | L254 |
| `tf_maecte` | `bditransfer` | ⚠️ sí | SELECT | L268 |
| `sc_maechq` | `bdicheq` | ⚠️ sí | SELECT | L276 |
| `tblcomision` | `bdispei` | no | SELECT | L295 |
| `si_param` | `bdinteg` | ⚠️ sí | SELECT | L300 |
| `sc_producto` | `bdicheq` | ⚠️ sí | SELECT | L306 |
| `sc_maecomtasserv_pm` | `bdicheq` | ⚠️ sí | SELECT | L314 |
| `tblparametros` | `bdispei` | no | SELECT | L372 |
| `si_transacc` | `bdinteg` | ⚠️ sí | SELECT | L383 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `cons_sdos1` | `bdicheq` | ⚠️ sí | L338 |
| `sp_obtfoliosuc` | `bdispei` | no | L347 |
| `cargo_ref` | `bdicheq` | ⚠️ sí | L362 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L264 | VALIDACIÓN_NULL | `IF wexisteclave is null OR wexisteclave = '' THEN` |  |
| L281 | VALIDACIÓN_NULL | `IF vcuenta is null OR vcuenta = '' THEN` |  |
| L322 | FÓRMULA | `LET wmonto_iva = wmonto_comision * wvalor_iva;` | 🔴 MONEY/aritmética financiera |
| L323 | FÓRMULA | `LET wcargo_total = pmnyimporte + wmonto_comision + wmonto_iva;` | 🔴 MONEY/aritmética financiera |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `spei` | PREFIJO | familia SPEI (pagos interbancarios) | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `realiza` | ACCION | realiza / ejecuta una operación SPEI | 🟡 INFERIDO | nombre_sp |
| `cargo` | ENTIDAD | cargo / débito | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `exp` | MODIF | sufijo Exportar — SP genera/exporta archivo de salida (sp_*_ | 🟡 INFERIDO | nombre_sp |
| `?1` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?1` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `spei_reccancelacion`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_spei_reccancelacion.sql` |
| **LOC (1er CREATE)** | 287 |
| **Callgraph** | ✅ fan_in=0 / fan_out=14 |
| **Deps concatenadas** | 6 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "recibe cancelación" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 3 llamada(s): `sp_obtfoliosuc`, `abono_ref`, `spei_recerrorescodi` |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=0 / 2 términos |

### Firma

```sql
CREATE PROCEDURE spei_reccancelacion(
  pvchrclaverastreo            CHAR(30)
  pdigidord                    INTEGER
  pdigidben                    INTEGER
  pfechalimpago                CHAR(16)
  intBancoOrd                  CHAR(5)
  ppagocomision                INTEGER
  pcomision                    DECIMAL(14,2)
  pnumseriecert                CHAR(20)
  pfolioplataforma             CHAR(20)
  pchrfchmjc                   CHAR(20)
  presfirm                     INTEGER
) RETURNING CHAR(30)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pvchrclaverastreo` | `CHAR(30)` | — | — |
| `pdigidord` | `INTEGER` | — | — |
| `pdigidben` | `INTEGER` | — | — |
| `pfechalimpago` | `CHAR(16)` | — | — |
| `intBancoOrd` | `CHAR(5)` | — | — |
| `ppagocomision` | `INTEGER` | — | — |
| `pcomision` | `DECIMAL(14,2)` | — | — |
| `pnumseriecert` | `CHAR(20)` | — | — |
| `pfolioplataforma` | `CHAR(20)` | — | — |
| `pchrfchmjc` | `CHAR(20)` | — | — |
| `presfirm` | `INTEGER` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vCodRet1` | `CHAR(5)` | L22 |
| `vCodRet2` | `CHAR(5)` | L23 |
| `vSqlErr` | `INTEGER` | L24 |
| `vIsamErr` | `INTEGER` | L25 |
| `wempresa` | `CHAR(3)` | L26 |
| `whora` | `CHAR(15)` | L27 |
| `wserial_folio` | `INTEGER` | L28 |
| `wfolio_suc` | `CHAR(30)` | L29 |
| `wcuenta` | `CHAR(20)` | L30 |
| `wnum_tarjeta` | `CHAR(16)` | L31 |
| `wmaxsec` | `SMALLINT` | L32 |
| `wsucursal` | `CHAR(4)` | L33 |
| `wusuario` | `CHAR(8)` | L34 |
| `wtransacc` | `CHAR(4)` | L35 |
| `wtran_suc` | `CHAR(4)` | L36 |
| `wdivisa` | `CHAR(2)` | L37 |
| `wexiste_mov` | `INTEGER` | L38 |
| `wimporte` | `DECIMAL(12,2)` | L39 |
| `cVarDataErr` | `CHAR(100)` | L40 |
| `vtimestamp` | `LVARCHAR(20)` | L41 |
| `wtimestamp` | `CHAR(20)` | L42 |
| `wcomision` | `DECIMAL(14,2)` | L43 |
| `wcadena_val` | `CHAR (1000)` | L45 |
| `codretfirma` | `INTEGER` | L46 |
| `wvchrcodretcodi` | `CHAR(5)` | L47 |
| *…11 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sc_tarjeta` | `bdicheq` | ⚠️ sí | SELECT | L150 |
| `sc_cuenta_telefono` | `bdicheq` | ⚠️ sí | SELECT | L190 |
| `tf_maecte` | `bditransfer` | ⚠️ sí | SELECT | L198 |
| `sc_movdia` | `bdicheq` | ⚠️ sí | SELECT | L207 |
| `tblpago` | `bdispei` | no | SELECT | L222 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_obtfoliosuc` | `bdispei` | no | L226 |
| `abono_ref` | `bdicheq` | ⚠️ sí | L234 |
| `spei_recerrorescodi` | `bdispei` | no | L245 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L82 | FÓRMULA | `LET vtimestamp    = dbinfo('utc_current') * 1000;` |  |
| L195 | VALIDACIÓN_NULL | `IF wcuenta is null OR wcuenta = '' THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `spei` | PREFIJO | familia SPEI (pagos interbancarios) | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `reccancelacion` | ACCION | recibe cancelación | 🔵 CONVENCIÓN | nombre_sp |

---

## `spei_reccancelacion_exp1`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_spei_reccancelacion_exp1.sql` |
| **LOC (1er CREATE)** | 279 |
| **Callgraph** | ✅ fan_in=0 / fan_out=4 |
| **Propósito inferido** | "recibe cancelación (sufijo Exportar — SP genera/exporta archivo de salida)" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `genera` → `SELECT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=1 · INFERIDO=1 · SINTÉTICO=1 / 4 términos |

### Firma

```sql
CREATE PROCEDURE spei_reccancelacion_exp1(
  pvchrclaverastreo            CHAR(30)
  pdigidord                    INTEGER
  pdigidben                    INTEGER
  pfechalimpago                CHAR(16)
  intBancoOrd                  CHAR(5)
  ppagocomision                INTEGER
  pcomision                    DECIMAL(14,2)
  pnumseriecert                CHAR(20)
  pfolioplataforma             CHAR(20)
  pchrfchmjc                   CHAR(20)
) RETURNING CHAR(30)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pvchrclaverastreo` | `CHAR(30)` | — | — |
| `pdigidord` | `INTEGER` | — | — |
| `pdigidben` | `INTEGER` | — | — |
| `pfechalimpago` | `CHAR(16)` | — | — |
| `intBancoOrd` | `CHAR(5)` | — | — |
| `ppagocomision` | `INTEGER` | — | — |
| `pcomision` | `DECIMAL(14,2)` | — | — |
| `pnumseriecert` | `CHAR(20)` | — | — |
| `pfolioplataforma` | `CHAR(20)` | — | — |
| `pchrfchmjc` | `CHAR(20)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vCodRet1` | `CHAR(5)` | L22 |
| `vCodRet2` | `CHAR(5)` | L23 |
| `vSqlErr` | `INTEGER` | L24 |
| `vIsamErr` | `INTEGER` | L25 |
| `wempresa` | `CHAR(3)` | L26 |
| `whora` | `CHAR(15)` | L27 |
| `wserial_folio` | `INTEGER` | L28 |
| `wfolio_suc` | `CHAR(30)` | L29 |
| `wcuenta` | `CHAR(20)` | L30 |
| `wnum_tarjeta` | `CHAR(16)` | L31 |
| `wmaxsec` | `SMALLINT` | L32 |
| `wsucursal` | `CHAR(4)` | L33 |
| `wusuario` | `CHAR(8)` | L34 |
| `wtransacc` | `CHAR(4)` | L35 |
| `wtran_suc` | `CHAR(4)` | L36 |
| `wdivisa` | `CHAR(2)` | L37 |
| `wexiste_mov` | `INTEGER` | L38 |
| `wimporte` | `DECIMAL(12,2)` | L39 |
| `cVarDataErr` | `CHAR(100)` | L40 |
| `vtimestamp` | `LVARCHAR(20)` | L41 |
| `wtimestamp` | `CHAR(20)` | L42 |
| `wcomision` | `DECIMAL(14,2)` | L43 |
| `wcadena_val` | `CHAR (1000)` | L45 |
| `codretfirma` | `INTEGER` | L46 |
| `wvchrcodretcodi` | `CHAR(5)` | L47 |
| *…11 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sc_tarjeta` | `bdicheq` | ⚠️ sí | SELECT | L147 |
| `sc_cuenta_telefono` | `bdicheq` | ⚠️ sí | SELECT | L187 |
| `tf_maecte` | `bditransfer` | ⚠️ sí | SELECT | L195 |
| `sc_movdia` | `bdicheq` | ⚠️ sí | SELECT | L204 |
| `tblpago` | `bdispei` | no | SELECT | L219 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_obtfoliosuc` | `bdispei` | no | L223 |
| `abono_ref` | `bdicheq` | ⚠️ sí | L231 |
| `spei_recerrorescodi` | `bdispei` | no | L242 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L86 | FÓRMULA | `LET vtimestamp    = dbinfo('utc_current') * 1000;` |  |
| L129 | FÓRMULA | `LET codretfirma = 0; --- Para prueba` |  |
| L192 | VALIDACIÓN_NULL | `IF wcuenta is null OR wcuenta = '' THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `spei` | PREFIJO | familia SPEI (pagos interbancarios) | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `reccancelacion` | ACCION | recibe cancelación | 🔵 CONVENCIÓN | nombre_sp |
| `exp` | MODIF | sufijo Exportar — SP genera/exporta archivo de salida (sp_*_ | 🟡 INFERIDO | nombre_sp |
| `?1` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?1` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `spei_reccancelacionpba`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_spei_reccancelacionpba.sql` |
| **LOC (1er CREATE)** | 282 |
| **Callgraph** | ✅ fan_in=0 / fan_out=4 |
| **Propósito inferido** | "recibe cancelación (PBA — sufijo de SPs para Pruebas; confirmado por SME)" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `confirma` → `SELECT` encontrado en el cuerpo · `confirma` → `UPDATE` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=0 / 3 términos |

### Firma

```sql
CREATE PROCEDURE spei_reccancelacionpba(
  pvchrclaverastreo            CHAR(30)
  pdigidord                    INTEGER
  pdigidben                    INTEGER
  pfechalimpago                CHAR(16)
  intBancoOrd                  CHAR(5)
  ppagocomision                INTEGER
  pcomision                    DECIMAL(14,2)
  pnumseriecert                CHAR(20)
  pfolioplataforma             CHAR(20)
  pchrfchmjc                   CHAR(20)
) RETURNING CHAR(30)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pvchrclaverastreo` | `CHAR(30)` | — | — |
| `pdigidord` | `INTEGER` | — | — |
| `pdigidben` | `INTEGER` | — | — |
| `pfechalimpago` | `CHAR(16)` | — | — |
| `intBancoOrd` | `CHAR(5)` | — | — |
| `ppagocomision` | `INTEGER` | — | — |
| `pcomision` | `DECIMAL(14,2)` | — | — |
| `pnumseriecert` | `CHAR(20)` | — | — |
| `pfolioplataforma` | `CHAR(20)` | — | — |
| `pchrfchmjc` | `CHAR(20)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vCodRet1` | `CHAR(5)` | L22 |
| `vCodRet2` | `CHAR(5)` | L23 |
| `vSqlErr` | `INTEGER` | L24 |
| `vIsamErr` | `INTEGER` | L25 |
| `wempresa` | `CHAR(3)` | L26 |
| `whora` | `CHAR(15)` | L27 |
| `wserial_folio` | `INTEGER` | L28 |
| `wfolio_suc` | `CHAR(30)` | L29 |
| `wcuenta` | `CHAR(20)` | L30 |
| `wnum_tarjeta` | `CHAR(16)` | L31 |
| `wmaxsec` | `SMALLINT` | L32 |
| `wsucursal` | `CHAR(4)` | L33 |
| `wusuario` | `CHAR(8)` | L34 |
| `wtransacc` | `CHAR(4)` | L35 |
| `wtran_suc` | `CHAR(4)` | L36 |
| `wdivisa` | `CHAR(2)` | L37 |
| `wexiste_mov` | `INTEGER` | L38 |
| `wimporte` | `DECIMAL(12,2)` | L39 |
| `cVarDataErr` | `CHAR(100)` | L40 |
| `vtimestamp` | `LVARCHAR(20)` | L41 |
| `wtimestamp` | `CHAR(20)` | L42 |
| `wcomision` | `DECIMAL(14,2)` | L43 |
| `wcadena_val` | `CHAR (1000)` | L45 |
| `codretfirma` | `INTEGER` | L46 |
| `wvchrcodretcodi` | `CHAR(5)` | L47 |
| *…11 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sc_tarjeta` | `bdicheq` | ⚠️ sí | SELECT | L149 |
| `sc_cuenta_telefono` | `bdicheq` | ⚠️ sí | SELECT | L189 |
| `tf_maecte` | `bditransfer` | ⚠️ sí | SELECT | L197 |
| `sc_movdia` | `bdicheq` | ⚠️ sí | SELECT | L206 |
| `tblpago` | `bdispei` | no | SELECT | L221 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_obtfoliosuc` | `bdispei` | no | L226 |
| `abono_ref` | `bdicheq` | ⚠️ sí | L234 |
| `spei_recerrorescodi` | `bdispei` | no | L245 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L83 | FÓRMULA | `LET vtimestamp    = dbinfo('utc_current') * 1000;` |  |
| L194 | VALIDACIÓN_NULL | `IF wcuenta is null OR wcuenta = '' THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `spei` | PREFIJO | familia SPEI (pagos interbancarios) | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `reccancelacion` | ACCION | recibe cancelación | 🔵 CONVENCIÓN | nombre_sp |
| `pba` | MODIF | PBA — sufijo de SPs para Pruebas; confirmado por SME (Guerra | 🔵 CONVENCIÓN | nombre_sp |

---

## `spei_reccontabilidad`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_spei_reccontabilidad.sql` |
| **LOC (1er CREATE)** | 302 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "recepción identificador" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 3 llamada(s): `sp_validafecha`, `sp_pasecontab`, `spei_desbloqbandera` |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=2 / 6 términos |

### Firma

```sql
CREATE PROCEDURE spei_reccontabilidad(
  pctacontable                 CHAR(14)
  pccorigen                    CHAR(4)
  pccdestino                   CHAR(4)
  pimporte                     DECIMAL(17,2)
  pnaturaleza                  CHAR(1)
) RETURNING CHAR(5)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pctacontable` | `CHAR(14)` | `cont`=familia contabilidad | ✅ CÓDIGO |
| `pccorigen` | `CHAR(4)` | — | — |
| `pccdestino` | `CHAR(4)` | — | — |
| `pimporte` | `DECIMAL(17,2)` | — | — |
| `pnaturaleza` | `CHAR(1)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `sql_err` | `INTEGER` | L8 |
| `isam_err` | `INTEGER` | L9 |
| `vcodret1` | `CHAR(5)` | L10 |
| `vcodret2` | `CHAR(5)` | L11 |
| `wfecha_hoy` | `DATE` | L13 |
| `wchrempresa` | `CHAR(3)` | L14 |
| `wpendientes` | `INTEGER` | L15 |
| `wintpkpasecont` | `INTEGER` | L16 |
| `wchrsucursal` | `CHAR(4)` | L17 |
| `wccmayor` | `CHAR(4)` | L18 |
| `wccsub` | `CHAR(2)` | L19 |
| `wccsubsub` | `CHAR(2)` | L20 |
| `wccssubsub` | `CHAR(2)` | L21 |
| `wccsssubsub` | `CHAR(2)` | L22 |
| `wccsector` | `CHAR(2)` | L23 |
| `wccauxiliar` | `CHAR(2)` | L24 |
| `wchrtransaccion` | `CHAR(2)` | L25 |
| `wchrdivisa` | `CHAR(2)` | L26 |
| `vexiste` | `CHAR(4)` | L27 |
| `wfech_habil` | `DATE` | L28 |
| `wfecha_habil` | `CHAR(10)` | L29 |
| `wmovimientos` | `INTEGER` | L30 |
| `vcodretrpt1` | `CHAR(5)` | L32 |
| `vcodretrpt2` | `CHAR(5)` | L33 |
| `vcodretrpt3` | `CHAR(50)` | L34 |
| *…14 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sc_fechas` | `bdicheq` | ⚠️ sí | SELECT | L142 |
| `tblctrlproceso` | `bdispei` | no | SELECT | L147 |
| `tblctrlproceso` | `bdispei` | no | INSERT | L152 |
| `tblparametros` | `bdispei` | no | UPDATE | L160 |
| `si_catalog` | `bdinteg` | ⚠️ sí | SELECT | L189 |
| `tblpasecont` | `bdispei` | no | SELECT | L205 |
| `tblpaseconthist` | `bdispei` | no | SELECT | L217 |
| `tblpasecont` | `bdispei` | no | INSERT | L223 |
| `tblpaseconthist` | `bdispei` | no | INSERT | L264 |
| `tblpasecont` | `bdispei` | no | DELETE | L269 |
| `statistics` | `bdispei` | no | UPDATE | L273 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_validafecha` | `bdispei` | no | L155 |
| `sp_pasecontab` | `bdispei` | no | L276 |
| `spei_desbloqbandera` | `bdispei` | no | L285 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L158 | FÓRMULA | `LET wfecha_habil = to_char(wfech_habil, '%d/%m/%Y');` |  |
| L198 | VALIDACIÓN_NULL | `IF vexiste is null OR vexiste = '' THEN` |  |
| L207 | FÓRMULA | `LET wintpkpasecont = wintpkpasecont + 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `spei` | PREFIJO | familia SPEI (pagos interbancarios) | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `rec` | ACCION | recepción / recibe | 🔵 CONVENCIÓN | nombre_sp |
| `cont` | PREFIJO | familia contabilidad | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?abil` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `id` | ENTIDAD | identificador (de) | 🔵 CONVENCIÓN | nombre_sp |
| `?ad` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?abil`, `?ad` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `spei_reccontabilidad_exp1`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_spei_reccontabilidad_exp1.sql` |
| **LOC (1er CREATE)** | 344 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "recepción identificador (sufijo Exportar — SP genera/exporta archivo de salida)" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `genera` → `INSERT` encontrado en el cuerpo · `genera` → `SELECT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=2 · INFERIDO=1 · SINTÉTICO=3 / 8 términos |

### Firma

```sql
CREATE PROCEDURE spei_reccontabilidad_exp1(
  pctacontable                 CHAR(14)
  pccorigen                    CHAR(4)
  pccdestino                   CHAR(4)
  pimporte                     DECIMAL(17,2)
  pnaturaleza                  CHAR(1)
) RETURNING CHAR(5)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pctacontable` | `CHAR(14)` | `cont`=familia contabilidad | ✅ CÓDIGO |
| `pccorigen` | `CHAR(4)` | — | — |
| `pccdestino` | `CHAR(4)` | — | — |
| `pimporte` | `DECIMAL(17,2)` | — | — |
| `pnaturaleza` | `CHAR(1)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `sql_err` | `INTEGER` | L8 |
| `isam_err` | `INTEGER` | L9 |
| `vcodret1` | `CHAR(5)` | L10 |
| `vcodret2` | `CHAR(5)` | L11 |
| `wfecha_hoy` | `DATE` | L13 |
| `wchrempresa` | `CHAR(3)` | L14 |
| `wpendientes` | `INTEGER` | L15 |
| `wintpkpasecont` | `INTEGER` | L16 |
| `wchrsucursal` | `CHAR(4)` | L17 |
| `wccmayor` | `CHAR(4)` | L18 |
| `wccsub` | `CHAR(2)` | L19 |
| `wccsubsub` | `CHAR(2)` | L20 |
| `wccssubsub` | `CHAR(2)` | L21 |
| `wccsssubsub` | `CHAR(2)` | L22 |
| `wccsector` | `CHAR(2)` | L23 |
| `wccauxiliar` | `CHAR(2)` | L24 |
| `wchrtransaccion` | `CHAR(2)` | L25 |
| `wchrdivisa` | `CHAR(2)` | L26 |
| `vexiste` | `CHAR(4)` | L27 |
| `wfech_habil` | `DATE` | L28 |
| `wfecha_habil` | `CHAR(10)` | L29 |
| `wmovimientos` | `INTEGER` | L30 |
| `vcodretrpt1` | `CHAR(5)` | L32 |
| `vcodretrpt2` | `CHAR(5)` | L33 |
| `vcodretrpt3` | `CHAR(50)` | L34 |
| *…14 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sc_fechas` | `bdicheq` | ⚠️ sí | SELECT | L142 |
| `tblctrlproceso` | `bdispei` | no | SELECT | L147 |
| `tblctrlproceso` | `bdispei` | no | INSERT | L152 |
| `tblparametros` | `bdispei` | no | UPDATE | L160 |
| `si_catalog` | `bdinteg` | ⚠️ sí | SELECT | L188 |
| `tblpasecont` | `bdispei` | no | SELECT | L204 |
| `tblpaseconthist` | `bdispei` | no | SELECT | L216 |
| `tblpasecont` | `bdispei` | no | INSERT | L222 |
| `tblpago` | `bdispei` | no | SELECT | L249 |
| `statistics` | `bdispei` | no | UPDATE | L269 |
| `tblpaseconthist` | `bdispei` | no | INSERT | L306 |
| `tblpasecont` | `bdispei` | no | DELETE | L311 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_validafecha` | `bdispei` | no | L155 |
| `spei_depuratblpago` | `bdispei` | no | L266 |
| `spei_depuratbldetranpago` | `bdispei` | no | L272 |
| `sp_pasecontab` | `bdispei` | no | L318 |
| `sp_rptmovsdiariospei` | `bdicheq` | ⚠️ sí | L323 |
| `sp_rptmovsdiariospei_acuenta` | `bdicheq` | ⚠️ sí | L326 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L158 | FÓRMULA | `LET wfecha_habil = to_char(wfech_habil, '%d/%m/%Y');` |  |
| L197 | VALIDACIÓN_NULL | `IF vexiste is null OR vexiste = '' THEN` |  |
| L206 | FÓRMULA | `LET wintpkpasecont = wintpkpasecont + 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `spei` | PREFIJO | familia SPEI (pagos interbancarios) | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `rec` | ACCION | recepción / recibe | 🔵 CONVENCIÓN | nombre_sp |
| `cont` | PREFIJO | familia contabilidad | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?abil` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `id` | ENTIDAD | identificador (de) | 🔵 CONVENCIÓN | nombre_sp |
| `?ad_` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `exp` | MODIF | sufijo Exportar — SP genera/exporta archivo de salida (sp_*_ | 🟡 INFERIDO | nombre_sp |
| `?1` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?abil`, `?ad_`, `?1` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `spei_reccontabilidad_pba`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_spei_reccontabilidad_pba.sql` |
| **LOC (1er CREATE)** | 72 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "recepción identificador (PBA — sufijo de SPs para Pruebas; confirmado por SME)" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 1 llamada(s): `sp_rptmovsdiariospei` |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=5 · INFERIDO=0 · SINTÉTICO=2 / 7 términos |

### Firma

```sql
CREATE PROCEDURE spei_reccontabilidad_pba(
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
| `isam_err` | `INTEGER` | L5 |
| `vcodret1` | `CHAR(5)` | L6 |
| `vcodret2` | `CHAR(5)` | L7 |
| `wfecha_hoy` | `DATE` | L9 |
| `wchrempresa` | `CHAR(3)` | L10 |
| `wpendientes` | `INTEGER` | L11 |
| `wintpkpasecont` | `INTEGER` | L12 |
| `wchrsucursal` | `CHAR(4)` | L13 |
| `wccmayor` | `CHAR(4)` | L14 |
| `wccsub` | `CHAR(2)` | L15 |
| `wccsubsub` | `CHAR(2)` | L16 |
| `wccssubsub` | `CHAR(2)` | L17 |
| `wccsssubsub` | `CHAR(2)` | L18 |
| `wccsector` | `CHAR(2)` | L19 |
| `wccauxiliar` | `CHAR(2)` | L20 |
| `wchrtransaccion` | `CHAR(2)` | L21 |
| `wchrdivisa` | `CHAR(2)` | L22 |
| `vexiste` | `CHAR(4)` | L23 |
| `wfech_habil` | `DATE` | L24 |
| `wfecha_habil` | `CHAR(10)` | L25 |
| `vcodretrpt1` | `CHAR(5)` | L27 |
| `vcodretrpt2` | `CHAR(5)` | L28 |
| `vcodretrpt3` | `CHAR(50)` | L29 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_rptmovsdiariospei` | `bdicheq` | ⚠️ sí | L63 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `spei` | PREFIJO | familia SPEI (pagos interbancarios) | 🔵 CONVENCIÓN | nombre_sp |
| `rec` | ACCION | recepción / recibe | 🔵 CONVENCIÓN | nombre_sp |
| `cont` | PREFIJO | familia contabilidad | 🔵 CONVENCIÓN | nombre_sp |
| `?abil` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `id` | ENTIDAD | identificador (de) | 🔵 CONVENCIÓN | nombre_sp |
| `?ad_` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `pba` | MODIF | PBA — sufijo de SPs para Pruebas; confirmado por SME (Guerra | 🔵 CONVENCIÓN | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?abil`, `?ad_` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `spei_reccontabilidad_ws`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_spei_reccontabilidad_ws.sql` |
| **LOC (1er CREATE)** | 1125 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "recepción identificador" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 2 llamada(s): `sp_validafecha`, `sp_pasecontab` |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=2 / 6 términos |

### Firma

```sql
CREATE PROCEDURE spei_reccontabilidad_ws(
  pctacontable                 CHAR(14)
  pccorigen                    CHAR(4)
  pccdestino                   CHAR(4)
  pimporte                     DECIMAL(17,2)
  pnaturaleza                  CHAR(1)
  pctacontable1                CHAR(14)
  pccorigen1                   CHAR(4)
  pccdestino1                  CHAR(4)
  pimporte1                    DECIMAL(17,2)
  pnaturaleza1                 CHAR(1)
  pctacontable2                CHAR(14)
  pccorigen2                   CHAR(4)
  pccdestino2                  CHAR(4)
  pimporte2                    DECIMAL(17,2)
  pnaturaleza2                 CHAR(1)
  pctacontable3                CHAR(14)
  pccorigen3                   CHAR(4)
  pccdestino3                  CHAR(4)
  pimporte3                    DECIMAL(17,2)
  pnaturaleza3                 CHAR(1)
  pctacontable4                CHAR(14)
  pccorigen4                   CHAR(4)
  pccdestino4                  CHAR(4)
  pimporte4                    DECIMAL(17,2)
  pnaturaleza4                 CHAR(1)
  pctacontable5                CHAR(14)
  pccorigen5                   CHAR(4)
  pccdestino5                  CHAR(4)
  pimporte5                    DECIMAL(17,2)
  pnaturaleza5                 CHAR(1)
  pctacontable6                CHAR(14)
  pccorigen6                   CHAR(4)
  pccdestino6                  CHAR(4)
  pimporte6                    DECIMAL(17,2)
  pnaturaleza6                 CHAR(1)
  pctacontable7                CHAR(14)
  pccorigen7                   CHAR(4)
  pccdestino7                  CHAR(4)
  pimporte7                    DECIMAL(17,2)
  pnaturaleza7                 CHAR(1)
  pinstancia                   CHAR(1)
) RETURNING CHAR(5)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pctacontable` | `CHAR(14)` | `cont`=familia contabilidad | ✅ CÓDIGO |
| `pccorigen` | `CHAR(4)` | — | — |
| `pccdestino` | `CHAR(4)` | — | — |
| `pimporte` | `DECIMAL(17,2)` | — | — |
| `pnaturaleza` | `CHAR(1)` | — | — |
| `pctacontable1` | `CHAR(14)` | `cont`=familia contabilidad | ✅ CÓDIGO |
| `pccorigen1` | `CHAR(4)` | — | — |
| `pccdestino1` | `CHAR(4)` | — | — |
| `pimporte1` | `DECIMAL(17,2)` | — | — |
| `pnaturaleza1` | `CHAR(1)` | — | — |
| `pctacontable2` | `CHAR(14)` | `cont`=familia contabilidad | ✅ CÓDIGO |
| `pccorigen2` | `CHAR(4)` | — | — |
| `pccdestino2` | `CHAR(4)` | — | — |
| `pimporte2` | `DECIMAL(17,2)` | — | — |
| `pnaturaleza2` | `CHAR(1)` | — | — |
| `pctacontable3` | `CHAR(14)` | `cont`=familia contabilidad | ✅ CÓDIGO |
| `pccorigen3` | `CHAR(4)` | — | — |
| `pccdestino3` | `CHAR(4)` | — | — |
| `pimporte3` | `DECIMAL(17,2)` | — | — |
| `pnaturaleza3` | `CHAR(1)` | — | — |
| `pctacontable4` | `CHAR(14)` | `cont`=familia contabilidad | ✅ CÓDIGO |
| `pccorigen4` | `CHAR(4)` | — | — |
| `pccdestino4` | `CHAR(4)` | — | — |
| `pimporte4` | `DECIMAL(17,2)` | — | — |
| `pnaturaleza4` | `CHAR(1)` | — | — |
| `pctacontable5` | `CHAR(14)` | `cont`=familia contabilidad | ✅ CÓDIGO |
| `pccorigen5` | `CHAR(4)` | — | — |
| `pccdestino5` | `CHAR(4)` | — | — |
| `pimporte5` | `DECIMAL(17,2)` | — | — |
| `pnaturaleza5` | `CHAR(1)` | — | — |
| `pctacontable6` | `CHAR(14)` | `cont`=familia contabilidad | ✅ CÓDIGO |
| `pccorigen6` | `CHAR(4)` | — | — |
| `pccdestino6` | `CHAR(4)` | — | — |
| `pimporte6` | `DECIMAL(17,2)` | — | — |
| `pnaturaleza6` | `CHAR(1)` | — | — |
| `pctacontable7` | `CHAR(14)` | `cont`=familia contabilidad | ✅ CÓDIGO |
| `pccorigen7` | `CHAR(4)` | — | — |
| `pccdestino7` | `CHAR(4)` | — | — |
| `pimporte7` | `DECIMAL(17,2)` | — | — |
| `pnaturaleza7` | `CHAR(1)` | — | — |
| `pinstancia` | `CHAR(1)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `sql_err` | `INTEGER` | L44 |
| `isam_err` | `INTEGER` | L45 |
| `vcodret1` | `CHAR(5)` | L46 |
| `vcodret2` | `CHAR(5)` | L47 |
| `wfecha_hoy` | `DATE` | L49 |
| `wchrempresa` | `CHAR(3)` | L50 |
| `wpendientes` | `INTEGER` | L51 |
| `wintpkpasecont` | `INTEGER` | L52 |
| `wchrsucursal` | `CHAR(4)` | L53 |
| `wccmayor` | `CHAR(4)` | L54 |
| `wccsub` | `CHAR(2)` | L55 |
| `wccsubsub` | `CHAR(2)` | L56 |
| `wccssubsub` | `CHAR(2)` | L57 |
| `wccsssubsub` | `CHAR(2)` | L58 |
| `wccsector` | `CHAR(2)` | L59 |
| `wccauxiliar` | `CHAR(2)` | L60 |
| `wchrtransaccion` | `CHAR(2)` | L61 |
| `wchrdivisa` | `CHAR(2)` | L62 |
| `vexiste` | `CHAR(4)` | L63 |
| `wfech_habil` | `DATE` | L64 |
| `wfecha_habil` | `CHAR(10)` | L65 |
| `wmovimientos` | `INTEGER` | L66 |
| `vcodretrpt1` | `CHAR(5)` | L68 |
| `vcodretrpt2` | `CHAR(5)` | L69 |
| `vcodretrpt3` | `CHAR(50)` | L70 |
| *…14 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sc_fechas` | `bdicheq` | ⚠️ sí | SELECT | L169 |
| `tblctrlproceso` | `bdispei` | no | SELECT | L174 |
| `tblctrlproceso` | `bdispei` | no | INSERT | L179 |
| `tblparametros` | `bdispei` | no | UPDATE | L187 |
| `si_catalog` | `bdinteg` | ⚠️ sí | SELECT | L242 |
| `tblpasecont` | `bdispei` | no | SELECT | L258 |
| `tblpaseconthist` | `bdispei` | no | SELECT | L271 |
| `tblpasecont` | `bdispei` | no | INSERT | L278 |
| `tblpaseconthist` | `bdispei` | no | INSERT | L638 |
| `tblpasecont` | `bdispei` | no | DELETE | L644 |
| `statistics` | `bdispei` | no | UPDATE | L648 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_validafecha` | `bdispei` | no | L182 |
| `sp_pasecontab` | `bdispei` | no | L651 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L185 | FÓRMULA | `LET wfecha_habil = to_char(wfech_habil, '%d/%m/%Y');` |  |
| L220 | VALIDACIÓN_NULL | `IF ( LENGTH( TRIM(pctacontable)  ) <> 14 OR pctacontable  is null ) OR ( LENGTH( TRIM(pccdestino)  )` |  |
| L251 | VALIDACIÓN_NULL | `IF vexiste is null OR vexiste = '' THEN` |  |
| L260 | FÓRMULA | `LET wintpkpasecont = wintpkpasecont + 1;` |  |
| L303 | VALIDACIÓN_NULL | `IF vexiste is null OR vexiste = '' THEN` |  |
| L308 | FÓRMULA | `LET wintpkpasecont = wintpkpasecont + 1;` |  |
| L351 | VALIDACIÓN_NULL | `IF vexiste is null OR vexiste = '' THEN` |  |
| L356 | FÓRMULA | `LET wintpkpasecont = wintpkpasecont + 1;` |  |
| L399 | VALIDACIÓN_NULL | `IF vexiste is null OR vexiste = '' THEN` |  |
| L404 | FÓRMULA | `LET wintpkpasecont = wintpkpasecont + 1;` |  |
| L447 | VALIDACIÓN_NULL | `IF vexiste is null OR vexiste = '' THEN` |  |
| L452 | FÓRMULA | `LET wintpkpasecont = wintpkpasecont + 1;` |  |
| L495 | VALIDACIÓN_NULL | `IF vexiste is null OR vexiste = '' THEN` |  |
| L500 | FÓRMULA | `LET wintpkpasecont = wintpkpasecont + 1;` |  |
| L543 | VALIDACIÓN_NULL | `IF vexiste is null OR vexiste = '' THEN` |  |
| L548 | FÓRMULA | `LET wintpkpasecont = wintpkpasecont + 1;` |  |
| L591 | VALIDACIÓN_NULL | `IF vexiste is null OR vexiste = '' THEN` |  |
| L596 | FÓRMULA | `LET wintpkpasecont = wintpkpasecont + 1;` |  |
| L700 | VALIDACIÓN_NULL | `IF vexiste is null OR vexiste = '' THEN` |  |
| L709 | FÓRMULA | `LET wintpkpasecont = wintpkpasecont + 1;` |  |
| L752 | VALIDACIÓN_NULL | `IF vexiste is null OR vexiste = '' THEN` |  |
| L757 | FÓRMULA | `LET wintpkpasecont = wintpkpasecont + 1;` |  |
| L800 | VALIDACIÓN_NULL | `IF vexiste is null OR vexiste = '' THEN` |  |
| L805 | FÓRMULA | `LET wintpkpasecont = wintpkpasecont + 1;` |  |
| L848 | VALIDACIÓN_NULL | `IF vexiste is null OR vexiste = '' THEN` |  |
| L853 | FÓRMULA | `LET wintpkpasecont = wintpkpasecont + 1;` |  |
| L885 | VALIDACIÓN_NULL | `IF wccmayor IS NULL or wccmayor = " " OR wccmayor = "0000" THEN` |  |
| L897 | VALIDACIÓN_NULL | `IF vexiste is null OR vexiste = '' THEN` |  |
| L902 | FÓRMULA | `LET wintpkpasecont = wintpkpasecont + 1;` |  |
| L935 | VALIDACIÓN_NULL | `IF wccmayor IS NULL or wccmayor = " " OR wccmayor = "0000" THEN` |  |
| | *…8 más…* | | |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `spei` | PREFIJO | familia SPEI (pagos interbancarios) | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `rec` | ACCION | recepción / recibe | 🔵 CONVENCIÓN | nombre_sp |
| `cont` | PREFIJO | familia contabilidad | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?abil` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `id` | ENTIDAD | identificador (de) | 🔵 CONVENCIÓN | nombre_sp |
| `?ad_ws` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?abil`, `?ad_ws` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `spei_recdevolucion`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_spei_recdevolucion.sql` |
| **LOC (1er CREATE)** | 222 |
| **Callgraph** | ✅ fan_in=2 / fan_out=14 |
| **Deps concatenadas** | 5 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "recibe devolución" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 2 llamada(s): `sp_obtfoliosuc`, `abono_ref` |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=0 / 2 términos |

### Firma

```sql
CREATE PROCEDURE spei_recdevolucion(
  pvchrclaverastreo            CHAR(30)
  22                           pcharfirma  	  CHAR(512)
) RETURNING CHAR(30)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pvchrclaverastreo` | `CHAR(30)` | — | — |
| `22` | `pcharfirma  	  CHAR(512)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vCodRet1` | `CHAR(5)` | L12 |
| `vCodRet2` | `CHAR(5)` | L13 |
| `vSqlErr` | `INTEGER` | L14 |
| `vIsamErr` | `INTEGER` | L15 |
| `wempresa` | `CHAR(3)` | L16 |
| `whora` | `CHAR(15)` | L17 |
| `wserial_folio` | `INTEGER` | L18 |
| `wfolio_suc` | `CHAR(30)` | L19 |
| `wcuenta` | `CHAR(20)` | L20 |
| `wnum_tarjeta` | `CHAR(16)` | L21 |
| `wmaxsec` | `SMALLINT` | L22 |
| `wsucursal` | `CHAR(4)` | L23 |
| `wusuario` | `CHAR(8)` | L24 |
| `wtransacc` | `CHAR(4)` | L25 |
| `wtran_suc` | `CHAR(4)` | L26 |
| `wdivisa` | `CHAR(2)` | L27 |
| `wexiste` | `CHAR(30)` | L28 |
| `wmovdia` | `SMALLINT` | L29 |
| `wcadena_val` | `CHAR (1000)` | L31 |
| `codretfirma` | `INTEGER` | L32 |
| `wcausa_dev` | `CHAR(2)` | L33 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tblpago` | `bdispei` | no | SELECT | L96 |
| `sc_tarjeta` | `bdicheq` | ⚠️ sí | SELECT | L109 |
| `sc_cuenta_telefono` | `bdicheq` | ⚠️ sí | SELECT | L149 |
| `tf_maecte` | `bditransfer` | ⚠️ sí | SELECT | L157 |
| `sc_movdia` | `bdicheq` | ⚠️ sí | SELECT | L171 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_obtfoliosuc` | `bdispei` | no | L182 |
| `abono_ref` | `bdicheq` | ⚠️ sí | L190 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L99 | VALIDACIÓN_NULL | `IF wexiste is null OR wexiste = '' THEN` |  |
| L154 | VALIDACIÓN_NULL | `IF wcuenta is null OR wcuenta = '' THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `spei` | PREFIJO | familia SPEI (pagos interbancarios) | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `recdevolucion` | ACCION | recibe devolución | 🔵 CONVENCIÓN | nombre_sp |

---

## `spei_recerrorescodi`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_spei_recerrorescodi.sql` |
| **LOC (1er CREATE)** | 417 |
| **Callgraph** | ✅ fan_in=27 / fan_out=10 |
| **Deps concatenadas** | 2 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "recepción error · CoDi — Cobro Digital" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 1 tabla(s) con operaciones: INSERT |
| **Evidencia vocab** | CÓDIGO=3 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=1 / 5 términos |

### Firma

```sql
CREATE PROCEDURE spei_recerrorescodi(
  pvchrcodretc                 CHAR(5)
) RETURNING char(5)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pvchrcodretc` | `CHAR(5)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vcodret` | `char(5)` | L26 |
| `vcodret2` | `char(5)` | L27 |
| `vcodret3` | `char(50)` | L28 |
| `sql_err` | `integer` | L29 |
| `isam_err` | `integer` | L30 |
| `desc_err` | `char(80)` | L31 |
| `vchrcode` | `CHAR(2)` | L33 |
| `vchrfchfinpro` | `CHAR(23)` | L34 |
| `vchrcvespeienva` | `CHAR(5)` | L35 |
| `vchrfchenvpro` | `CHAR(23)` | L36 |
| `vchridtpa` | `CHAR(2)` | L37 |
| `vtimestamp` | `CHAR(13)` | L38 |
| `ret` | `INTEGER` | L41 |
| `wvchrfirma` | `CHAR(512)` | L42 |
| `wchrcadena_00` | `CHAR(3000)` | L43 |
| `wchrcadena_01` | `CHAR(200)` | L44 |
| `wchrcadena_02` | `CHAR(200)` | L45 |
| `wchrcadena_03` | `CHAR(200)` | L46 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tbl_stsprocodi` | `bdispei` | no | INSERT | L394 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L49 | CÓDIGO_RETORNO | `LET vcodret  = '00000';` |  |
| L315 | FÓRMULA | `LET vtimestamp  = dbinfo('utc_current') * 1000;` |  |
| L318 | VALIDACIÓN_NULL | `IF pvchrfchmjc IS NULL OR pvchrfchmjc ='' THEN` |  |
| L321 | VALIDACIÓN_NULL | `IF pvchrconcepto IS NULL OR pvchrconcepto = '' THEN` |  |
| L325 | VALIDACIÓN_NULL | `IF pvchrcveras IS NULL OR pvchrcveras = '' THEN` |  |
| L329 | VALIDACIÓN_NULL | `IF pvchrrefnum IS NULL OR pvchrrefnum = '' OR pvchrrefnum = '-'  OR pvchrrefnum = 'null'  OR pvchrre` |  |
| L333 | VALIDACIÓN_NULL | `IF pvchrcelord IS NULL OR pvchrcelord = '' THEN` |  |
| L337 | VALIDACIÓN_NULL | `IF pvchrdiveord IS NULL OR pvchrdiveord = '' THEN` |  |
| L341 | VALIDACIÓN_NULL | `IF pvchrbancoord IS NULL  THEN` |  |
| L345 | VALIDACIÓN_NULL | `IF pvchrtpoctaord IS NULL OR pvchrtpoctaord = '' THEN` |  |
| L349 | VALIDACIÓN_NULL | `IF pvchrctaord IS NULL OR pvchrctaord = '' THEN` |  |
| L353 | VALIDACIÓN_NULL | `IF pvchrnomord IS NULL OR pvchrnomord = '' THEN` |  |
| L357 | VALIDACIÓN_NULL | `IF pvchrcelbenf IS NULL OR pvchrcelbenf = '' THEN` |  |
| L361 | VALIDACIÓN_NULL | `IF pvchrdivebenf IS NULL OR pvchrdivebenf = '' THEN` |  |
| L365 | VALIDACIÓN_NULL | `IF pvchrbancobenf IS NULL  THEN` |  |
| L369 | VALIDACIÓN_NULL | `IF pvchrtpoctabenf IS NULL OR pvchrtpoctabenf = '' THEN` |  |
| L373 | VALIDACIÓN_NULL | `IF pvchrctabenf IS NULL OR pvchrctabenf = '' THEN` |  |
| L377 | VALIDACIÓN_NULL | `IF pvhrnombenf IS NULL OR pvhrnombenf = '' THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `spei` | PREFIJO | familia SPEI (pagos interbancarios) | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `rec` | ACCION | recepción / recibe | 🔵 CONVENCIÓN | nombre_sp |
| `error` | ENTIDAD | error | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?es` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `codi` | REG | CoDi — Cobro Digital (Banxico) | ✅ CÓDIGO | nombre_sp, texto_cuerpo |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?es` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `spei_recerrorescodi_ws`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_spei_recerrorescodi_ws.sql` |
| **LOC (1er CREATE)** | 311 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "recepción error · CoDi — Cobro Digital" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 2 tabla(s) con operaciones: INSERT, SELECT |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=2 / 6 términos |

### Firma

```sql
CREATE PROCEDURE spei_recerrorescodi_ws(
  pvchrcodretc                 CHAR(5)
) RETURNING CHAR(5),          -- codigo de retorno
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pvchrcodretc` | `CHAR(5)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vcodret` | `char(5)` | L48 |
| `vcodret2` | `char(5)` | L49 |
| `vcodret3` | `char(50)` | L50 |
| `sql_err` | `integer` | L51 |
| `isam_err` | `integer` | L52 |
| `desc_err` | `char(80)` | L53 |
| `vchrcode` | `CHAR(2)` | L55 |
| `vchrfchfinpro` | `CHAR(23)` | L56 |
| `vchrcvespeienva` | `CHAR(5)` | L57 |
| `vchrfchenvpro` | `CHAR(23)` | L58 |
| `vchridtpa` | `CHAR(2)` | L59 |
| `vtimestamp` | `CHAR(13)` | L60 |
| `vnumserial` | `INTEGER` | L61 |
| `ret` | `INTEGER` | L64 |
| `wvchrfirma` | `CHAR(512)` | L65 |
| `wchrcadena_00` | `CHAR(3000)` | L66 |
| `wchrcadena_01` | `CHAR(200)` | L67 |
| `wchrcadena_02` | `CHAR(200)` | L68 |
| `wchrcadena_03` | `CHAR(200)` | L69 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tbl_stsprocodi` | `bdispei` | no | INSERT | L294 |
| `tbl_stsprocodi` | `bdispei` | no | SELECT | L300 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L71 | CÓDIGO_RETORNO | `LET vcodret  = '00000';` |  |
| L218 | FÓRMULA | `LET vtimestamp  = dbinfo('utc_current') * 1000;` |  |
| L221 | VALIDACIÓN_NULL | `IF pvchrconcepto IS NULL OR pvchrconcepto = '' THEN` |  |
| L225 | VALIDACIÓN_NULL | `IF pvchrcveras IS NULL OR pvchrcveras = '' THEN` |  |
| L229 | VALIDACIÓN_NULL | `IF pvchrrefnum IS NULL OR pvchrrefnum = '' OR pvchrrefnum = '-'  OR pvchrrefnum = 'null'  OR pvchrre` |  |
| L233 | VALIDACIÓN_NULL | `IF pvchrcelord IS NULL OR pvchrcelord = '' THEN` |  |
| L237 | VALIDACIÓN_NULL | `IF pvchrdiveord IS NULL OR pvchrdiveord = '' THEN` |  |
| L241 | VALIDACIÓN_NULL | `IF pvchrbancoord IS NULL  THEN` |  |
| L245 | VALIDACIÓN_NULL | `IF pvchrtpoctaord IS NULL OR pvchrtpoctaord = '' THEN` |  |
| L249 | VALIDACIÓN_NULL | `IF pvchrctaord IS NULL OR pvchrctaord = '' THEN` |  |
| L253 | VALIDACIÓN_NULL | `IF pvchrnomord IS NULL OR pvchrnomord = '' THEN` |  |
| L257 | VALIDACIÓN_NULL | `IF pvchrcelbenf IS NULL OR pvchrcelbenf = '' THEN` |  |
| L261 | VALIDACIÓN_NULL | `IF pvchrdivebenf IS NULL OR pvchrdivebenf = '' THEN` |  |
| L265 | VALIDACIÓN_NULL | `IF pvchrbancobenf IS NULL  THEN` |  |
| L269 | VALIDACIÓN_NULL | `IF pvchrtpoctabenf IS NULL OR pvchrtpoctabenf = '' THEN` |  |
| L273 | VALIDACIÓN_NULL | `IF pvchrctabenf IS NULL OR pvchrctabenf = '' THEN` |  |
| L277 | VALIDACIÓN_NULL | `IF pvhrnombenf IS NULL OR pvhrnombenf = '' THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `spei` | PREFIJO | familia SPEI (pagos interbancarios) | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `rec` | ACCION | recepción / recibe | 🔵 CONVENCIÓN | nombre_sp |
| `error` | ENTIDAD | error | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?es` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `codi` | REG | CoDi — Cobro Digital (Banxico) | 🔵 CONVENCIÓN | nombre_sp |
| `?_ws` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?es`, `?_ws` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `spei_recextemporanea`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_spei_recextemporanea.sql` |
| **LOC (1er CREATE)** | 319 |
| **Callgraph** | ✅ fan_in=2 / fan_out=14 |
| **Deps concatenadas** | 4 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "recibe orden extemporánea" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 2 llamada(s): `sp_obtfoliosuc`, `abono_ref` |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=0 / 2 términos |

### Firma

```sql
CREATE PROCEDURE spei_recextemporanea(
  pCveRastreo                  CHAR(30)
) RETURNING CHAR(30)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pCveRastreo` | `CHAR(30)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vCodRet1` | `CHAR(5)` | L13 |
| `vCodRet2` | `CHAR(5)` | L14 |
| `vCodRet3` | `CHAR(50)` | L15 |
| `vSqlErr` | `INTEGER` | L16 |
| `vIsamErr` | `INTEGER` | L17 |
| `vDescErr` | `CHAR(50)` | L18 |
| `iSerialFolio` | `INTEGER` | L20 |
| `cDivisa` | `CHAR(2)` | L21 |
| `iExisteMov` | `INTEGER` | L22 |
| `iCodRet` | `INTEGER` | L23 |
| `iVueltas` | `SMALLINT` | L24 |
| `cFolioOrigen` | `CHAR(30)` | L25 |
| `cIndDisponible` | `CHAR(1)` | L26 |
| `cSucursal` | `CHAR(4)` | L27 |
| `cUsuario` | `CHAR(8)` | L28 |
| `cTranAbono` | `CHAR(4)` | L29 |
| `cTranAbonoInt` | `CHAR(4)` | L30 |
| `cTranSuc` | `CHAR(4)` | L31 |
| `cCuenta` | `CHAR(20)` | L32 |
| `cNumTarjeta` | `CHAR(16)` | L33 |
| `cNumCte` | `CHAR(20)` | L34 |
| `wcadena_val` | `CHAR (1000)` | L36 |
| `codretfirma` | `INTEGER` | L37 |
| `wfolio_suc` | `CHAR(30)` | L38 |
| `wcausa_dev` | `CHAR(2)` | L39 |
| *…2 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sc_fechas` | `bdicheq` | ⚠️ sí | SELECT | L111 |
| `tblparametros` | `bdispei` | no | SELECT | L117 |
| `sc_tarjeta` | `bdicheq` | ⚠️ sí | SELECT | L143 |
| `tf_maecte` | `bditransfer` | ⚠️ sí | SELECT | L157 |
| `sc_maechq` | `bdicheq` | ⚠️ sí | SELECT | L163 |
| `sc_cuenta_telefono` | `bdicheq` | ⚠️ sí | SELECT | L226 |
| `sc_movdia` | `bdicheq` | ⚠️ sí | SELECT | L247 |
| `tblintfallo` | `bdispei` | no | INSERT | L305 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_obtfoliosuc` | `bdispei` | no | L267 |
| `abono_ref` | `bdicheq` | ⚠️ sí | L276 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L131 | VALIDACIÓN_NULL | `IF (pCveRastreo IS NULL OR pCveRastreo = "") OR (pCtaOrdenante IS NULL OR LENGTH(TRIM(pCtaOrdenante)` |  |
| L153 | VALIDACIÓN_NULL | `IF ( cNumCte is null OR cNumCte = '' OR cNumCte = ' ' ) THEN` |  |
| L175 | VALIDACIÓN_NULL | `IF ( cNumCte is null OR cNumCte = '' OR cNumCte = ' ' ) THEN` |  |
| L208 | VALIDACIÓN_NULL | `IF ( cNumCte is null OR cNumCte = '' OR cNumCte = ' ' ) THEN` |  |
| L231 | VALIDACIÓN_NULL | `IF cCuenta is null OR cCuenta = '' THEN` |  |
| L289 | FÓRMULA | `LET iVueltas = iVueltas + 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `spei` | PREFIJO | familia SPEI (pagos interbancarios) | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `recextemporanea` | ACCION | recibe orden extemporánea | 🔵 CONVENCIÓN | nombre_sp |

---

## `spei_recliquidacion`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_spei_recliquidacion.sql` |
| **LOC (1er CREATE)** | 51 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "recepción liquidación" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 1 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=0 / 3 términos |

### Firma

```sql
CREATE PROCEDURE spei_recliquidacion(
  pvchrclaverastreo            CHAR(30)
) RETURNING CHAR(5)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pvchrclaverastreo` | `CHAR(30)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vCodRet1` | `CHAR(5)` | L4 |
| `vCodRet2` | `CHAR(5)` | L5 |
| `vSqlErr` | `INTEGER` | L6 |
| `vIsamErr` | `INTEGER` | L7 |
| `wexiste` | `CHAR(30)` | L9 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tblpago` | `bdispei` | no | SELECT | L38 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `spei` | PREFIJO | familia SPEI (pagos interbancarios) | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `rec` | ACCION | recepción / recibe | 🔵 CONVENCIÓN | nombre_sp |
| `liquidacion` | ENTIDAD | liquidación | 🔵 CONVENCIÓN | nombre_sp |

---

## `spei_recliquidacion_exp1`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_spei_recliquidacion_exp1.sql` |
| **LOC (1er CREATE)** | 52 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "recepción liquidación (sufijo Exportar — SP genera/exporta archivo de salida)" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `genera` → `SELECT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=2 · INFERIDO=1 · SINTÉTICO=1 / 5 términos |

### Firma

```sql
CREATE PROCEDURE spei_recliquidacion_exp1(
  pvchrclaverastreo            CHAR(30)
) RETURNING CHAR(5)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pvchrclaverastreo` | `CHAR(30)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vCodRet1` | `CHAR(5)` | L5 |
| `vCodRet2` | `CHAR(5)` | L6 |
| `vSqlErr` | `INTEGER` | L7 |
| `vIsamErr` | `INTEGER` | L8 |
| `wexiste` | `CHAR(30)` | L10 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tblpago` | `bdispei` | no | SELECT | L39 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `spei` | PREFIJO | familia SPEI (pagos interbancarios) | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `rec` | ACCION | recepción / recibe | 🔵 CONVENCIÓN | nombre_sp |
| `liquidacion` | ENTIDAD | liquidación | 🔵 CONVENCIÓN | nombre_sp |
| `exp` | MODIF | sufijo Exportar — SP genera/exporta archivo de salida (sp_*_ | 🟡 INFERIDO | nombre_sp |
| `?1` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?1` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `spei_recordenpago`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_spei_recordenpago.sql` |
| **LOC (1er CREATE)** | 1121 |
| **Callgraph** | ✅ fan_in=2 / fan_out=14 |
| **Deps concatenadas** | 3 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "recibe orden de pago" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 6 llamada(s): `spei_recerrorescodi`, `sp_inserta_credspei`, `sp_valida_spei_cred` |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=0 / 2 términos |

### Firma

```sql
CREATE PROCEDURE spei_recordenpago(
  pvchrclaverastreo            CHAR(30)
  pnumcelben                   CHAR (20)
  pdigidord                    INTEGER
  pdigidben                    INTEGER
  pfechalimpago                CHAR(16)
  intBancoOrd                  CHAR(5)
  ppagocomision                INTEGER
  pcomision                    DECIMAL(14,2)
  pnumseriecert                CHAR(20)
  pfolioplataforma             CHAR(20)
  pchridmjc                    CHAR(20)
  pchrfchmjc                   CHAR(20)
  pvchrNombreOrd               CHAR(40)
  pintTipoCtaBenef             CHAR(2)
  pvchrNombreBenef             CHAR(40)
  presfirm                     INTEGER
) RETURNING CHAR(30), -- folio
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pvchrclaverastreo` | `CHAR(30)` | — | — |
| `pnumcelben` | `CHAR (20)` | — | — |
| `pdigidord` | `INTEGER` | — | — |
| `pdigidben` | `INTEGER` | — | — |
| `pfechalimpago` | `CHAR(16)` | — | — |
| `intBancoOrd` | `CHAR(5)` | — | — |
| `ppagocomision` | `INTEGER` | — | — |
| `pcomision` | `DECIMAL(14,2)` | — | — |
| `pnumseriecert` | `CHAR(20)` | — | — |
| `pfolioplataforma` | `CHAR(20)` | — | — |
| `pchridmjc` | `CHAR(20)` | — | — |
| `pchrfchmjc` | `CHAR(20)` | — | — |
| `pvchrNombreOrd` | `CHAR(40)` | — | — |
| `pintTipoCtaBenef` | `CHAR(2)` | — | — |
| `pvchrNombreBenef` | `CHAR(40)` | — | — |
| `presfirm` | `INTEGER` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vCodRet1` | `CHAR(5)` | L34 |
| `vCodRet2` | `CHAR(5)` | L35 |
| `vCodRet3` | `CHAR(50)` | L36 |
| `vSqlErr` | `INTEGER` | L37 |
| `vIsamErr` | `INTEGER` | L38 |
| `vDescErr` | `CHAR(50)` | L39 |
| `wempresa` | `CHAR(3)` | L40 |
| `whora` | `CHAR(15)` | L41 |
| `wserial_folio` | `INTEGER` | L42 |
| `wfolio_suc` | `CHAR(30)` | L43 |
| `wcausa_dev` | `CHAR(2)` | L44 |
| `wcuenta` | `CHAR(20)` | L45 |
| `vcuenta` | `CHAR(20)` | L46 |
| `wnum_tarjeta` | `CHAR(16)` | L47 |
| `wmaxsec` | `SMALLINT` | L48 |
| `wsuc_cta` | `CHAR(4)` | L49 |
| `wsucursal` | `CHAR(4)` | L50 |
| `wusuario` | `CHAR(8)` | L51 |
| `wtransacc` | `CHAR(4)` | L52 |
| `wtran_suc` | `CHAR(4)` | L53 |
| `wdivisa` | `CHAR(2)` | L54 |
| `wexiste_mov` | `INTEGER` | L55 |
| `vrfc` | `CHAR(18)` | L56 |
| `vnombre_cte` | `CHAR(40)` | L57 |
| `wnumcte` | `CHAR(20)` | L58 |
| *…55 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tblabono` | `bdispei` | no | INSERT | L266 |
| `sc_maechq` | `bdicheq` | ⚠️ sí | SELECT | L287 |
| `sc_tarjeta` | `bdicheq` | ⚠️ sí | SELECT | L299 |
| `sd_cat_prod_finac` | `bdicred` | ⚠️ sí | SELECT | L311 |
| `tblpagocred` | `bdispei` | no | SELECT | L331 |
| `sc_cuenta_telefono` | `bdicheq` | ⚠️ sí | SELECT | L407 |
| `sc_limites_producto` | `bdicheq` | ⚠️ sí | SELECT | L483 |
| `sc_transacc_exentas_limprod` | `bdicheq` | ⚠️ sí | SELECT | L489 |
| `si_tpcambio` | `bdinteg` | ⚠️ sí | SELECT | L497 |
| `sc_param` | `bdicheq` | ⚠️ sí | SELECT | L561 |
| `sc_acummesctanvl2` | `bdicheq` | ⚠️ sí | SELECT | L594 |
| `tblclabebloqueo` | `bdispei` | no | SELECT | L649 |
| `tblintfallo` | `bdispei` | no | INSERT | L659 |
| `sc_fechas` | `bdicheq` | ⚠️ sí | SELECT | L685 |
| `tblparametros` | `bdispei` | no | SELECT | L745 |
| `sc_ctabloqueo` | `bdicheq` | ⚠️ sí | SELECT | L754 |
| `sc_bloqueo` | `bdicheq` | ⚠️ sí | SELECT | L791 |
| `si_cliente` | `bdinteg` | ⚠️ sí | SELECT | L876 |
| `si_ctepm` | `bdinteg` | ⚠️ sí | SELECT | L901 |
| `sc_movdia` | `bdicheq` | ⚠️ sí | SELECT | L914 |
| `tblcdev_codret` | `bdispei` | no | SELECT | L1004 |
| `tblbancoabono` | `bdispei` | no | SELECT | L1030 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `spei_recerrorescodi` | `bdispei` | no | L261 |
| `sp_inserta_credspei` | `bdispei` | no | L325 |
| `sp_valida_spei_cred` | `bdicred` | ⚠️ sí | L350 |
| `sp_obtfoliosuc` | `bdispei` | no | L358 |
| `abono_ref` | `bdicheq` | ⚠️ sí | L964 |
| `sp_registra_evento` | `bdimnsj` | ⚠️ sí | L993 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L164 | FÓRMULA | `LET vtimestamp    = dbinfo('utc_current') * 1000;` |  |
| L339 | FÓRMULA | `LET vciclo = vciclo + 1;` |  |
| L346 | VALIDACIÓN_NULL | `IF cStatus is null OR cStatus = '' OR cStatus IN('N','E','X') THEN` |  |
| L502 | VALIDACIÓN_NULL | `IF vhoramax is null OR vhoramax = '' THEN` |  |
| L521 | VALIDACIÓN_NULL | `IF vprecio_udi is null OR vprecio_udi = '' THEN` |  |
| L538 | VALIDACIÓN_NULL | `IF vhoramax is null OR vhoramax = '' THEN` |  |
| L565 | VALIDACIÓN_NULL | `IF vnomaxudis is null THEN` |  |
| L597 | VALIDACIÓN_NULL | `IF vmtoacumcta is null THEN` |  |
| L602 | FÓRMULA | `LET vmonto_udi = pmnyimporte / vprecio_udi;` | 🔴 MONEY/aritmética financiera |
| L605 | FÓRMULA | `LET vmtopagosudi = vmtoacumcta / vprecio_udi;` |  |
| L608 | FÓRMULA | `LET vlim_cuenta = vmonto_udi + vmtopagosudi;` | 🔴 MONEY/aritmética financiera |
| L715 | VALIDACIÓN_NULL | `IF ( ( pmnyimporte <= 0.00 ) OR ( pchrstatus is null OR pchrstatus = '' OR LENGTH(TRIM(pchrstatus)) ` |  |
| L748 | FÓRMULA | `LET vfech_val = SUBSTR(vfech_spei,4,2)\|\|'/'\|\|SUBSTR(vfech_spei,1,2)\|\|'/'\|\|SUBSTR(vfech_spei,` |  |
| L847 | VALIDACIÓN_NULL | `IF wnumcte is null OR wnumcte = '' THEN` |  |
| L977 | FÓRMULA | `LET ivueltas = ivueltas + 1;` |  |
| L989 | FÓRMULA | `LET wcuentabenefmsg = substr(pvchrcuentabenef,(length(pvchrcuentabenef)-3),4);` |  |
| L1034 | VALIDACIÓN_NULL | `IF wvchrorigen is null OR wvchrorigen = '' OR wvchrorigen = ' ' THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `spei` | PREFIJO | familia SPEI (pagos interbancarios) | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `recordenpago` | ACCION | recibe orden de pago | 🔵 CONVENCIÓN | nombre_sp |

---

## `spei_recordenpago_exp1`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_spei_recordenpago_exp1.sql` |
| **LOC (1er CREATE)** | 744 |
| **Callgraph** | ✅ fan_in=0 / fan_out=7 |
| **Propósito inferido** | "recibe orden de pago (sufijo Exportar — SP genera/exporta archivo de salida)" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `genera` → `INSERT` encontrado en el cuerpo · `genera` → `SELECT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=1 · INFERIDO=1 · SINTÉTICO=1 / 4 términos |

### Firma

```sql
CREATE PROCEDURE spei_recordenpago_exp1(
  pvchrclaverastreo            CHAR(30)
  pdigidord                    INTEGER
  pdigidben                    INTEGER
  pfechalimpago                CHAR(16)
  intBancoOrd                  CHAR(5)
  ppagocomision                INTEGER
  pcomision                    DECIMAL(14,2)
  pnumseriecert                CHAR(20)
  pfolioplataforma             CHAR(20)
  pchrfchmjc                   CHAR(20)
  pvchrNombreOrd               CHAR(40)
  pintTipoCtaBenef             CHAR(2)
  pvchrNombreBenef             CHAR(40)
) RETURNING CHAR(30), -- folio
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pvchrclaverastreo` | `CHAR(30)` | — | — |
| `pdigidord` | `INTEGER` | — | — |
| `pdigidben` | `INTEGER` | — | — |
| `pfechalimpago` | `CHAR(16)` | — | — |
| `intBancoOrd` | `CHAR(5)` | — | — |
| `ppagocomision` | `INTEGER` | — | — |
| `pcomision` | `DECIMAL(14,2)` | — | — |
| `pnumseriecert` | `CHAR(20)` | — | — |
| `pfolioplataforma` | `CHAR(20)` | — | — |
| `pchrfchmjc` | `CHAR(20)` | — | — |
| `pvchrNombreOrd` | `CHAR(40)` | — | — |
| `pintTipoCtaBenef` | `CHAR(2)` | — | — |
| `pvchrNombreBenef` | `CHAR(40)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vCodRet1` | `CHAR(5)` | L33 |
| `vCodRet2` | `CHAR(5)` | L34 |
| `vCodRet3` | `CHAR(50)` | L35 |
| `vSqlErr` | `INTEGER` | L36 |
| `vIsamErr` | `INTEGER` | L37 |
| `vDescErr` | `CHAR(50)` | L38 |
| `wempresa` | `CHAR(3)` | L39 |
| `whora` | `CHAR(15)` | L40 |
| `wserial_folio` | `INTEGER` | L41 |
| `wfolio_suc` | `CHAR(30)` | L42 |
| `wcausa_dev` | `CHAR(2)` | L43 |
| `wcuenta` | `CHAR(20)` | L44 |
| `vcuenta` | `CHAR(20)` | L45 |
| `wnum_tarjeta` | `CHAR(16)` | L46 |
| `wmaxsec` | `SMALLINT` | L47 |
| `wsuc_cta` | `CHAR(4)` | L48 |
| `wsucursal` | `CHAR(4)` | L49 |
| `wusuario` | `CHAR(8)` | L50 |
| `wtransacc` | `CHAR(4)` | L51 |
| `wtran_suc` | `CHAR(4)` | L52 |
| `wdivisa` | `CHAR(2)` | L53 |
| `wexiste_mov` | `INTEGER` | L54 |
| `vrfc` | `CHAR(18)` | L55 |
| `vnombre_cte` | `CHAR(40)` | L56 |
| `wnumcte` | `CHAR(20)` | L57 |
| *…36 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tblbcobloqueo` | `bdispei` | no | SELECT | L256 |
| `tblintfallo` | `bdispei` | no | INSERT | L266 |
| `tblclabebloqueo` | `bdispei` | no | SELECT | L284 |
| `sc_fechas` | `bdicheq` | ⚠️ sí | SELECT | L311 |
| `tblparametros` | `bdispei` | no | SELECT | L351 |
| `sc_maechq` | `bdicheq` | ⚠️ sí | SELECT | L362 |
| `tf_maecte` | `bditransfer` | ⚠️ sí | SELECT | L371 |
| `sc_tarjeta` | `bdicheq` | ⚠️ sí | SELECT | L382 |
| `sd_cat_prod_finac` | `bdicred` | ⚠️ sí | SELECT | L404 |
| `tblpagocred` | `bdispei` | no | SELECT | L423 |
| `si_cliente` | `bdinteg` | ⚠️ sí | SELECT | L466 |
| `sc_cuenta_telefono` | `bdicheq` | ⚠️ sí | SELECT | L521 |
| `si_ctepm` | `bdinteg` | ⚠️ sí | SELECT | L574 |
| `sc_movdia` | `bdicheq` | ⚠️ sí | SELECT | L587 |
| `tblcdev_codret` | `bdispei` | no | SELECT | L697 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `spei_recerrorescodi` | `bdispei` | no | L269 |
| `sp_inserta_credspei` | `bdispei` | no | L417 |
| `sp_valida_spei_cred` | `bdicred` | ⚠️ sí | L442 |
| `sp_obtfoliosuc` | `bdispei` | no | L450 |
| `abono_ref` | `bdicheq` | ⚠️ sí | L653 |
| `sp_registra_evento` | `bdimnsj` | ⚠️ sí | L685 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L142 | FÓRMULA | `LET vtimestamp    = dbinfo('utc_current') * 1000;` |  |
| L331 | VALIDACIÓN_NULL | `IF ( ( pmnyimporte <= 0.00 ) OR ( pchrstatus is null OR pchrstatus = '' OR LENGTH(TRIM(pchrstatus)) ` |  |
| L354 | FÓRMULA | `LET vfech_val = SUBSTR(vfech_spei, 4, 2) \|\| '/' \|\| SUBSTR(vfech_spei, 1,2) \|\| '/' \|\| SUBSTR(` |  |
| L367 | VALIDACIÓN_NULL | `IF ( wnumcte is null OR wnumcte = '' OR wnumcte = ' ' ) THEN` |  |
| L385 | VALIDACIÓN_NULL | `IF ( wnumcte is null OR wnumcte = '' OR wnumcte = ' ' ) THEN` |  |
| L431 | FÓRMULA | `LET vciclo = vciclo + 1;` |  |
| L438 | VALIDACIÓN_NULL | `IF cStatus is null OR cStatus = '' OR cStatus IN('N','E','X') THEN` |  |
| L495 | VALIDACIÓN_NULL | `IF ( wnumcte is null OR wnumcte = '' OR wnumcte = ' ' ) THEN` |  |
| L504 | VALIDACIÓN_NULL | `IF (wnumcte1 is null OR wnumcte1 = '' OR wnumcte1 = ' ' ) THEN` |  |
| L526 | VALIDACIÓN_NULL | `IF vcuenta is null OR vcuenta = '' THEN` |  |
| L538 | VALIDACIÓN_NULL | `IF wnumcte is null OR wnumcte = '' THEN` |  |
| L666 | FÓRMULA | `LET ivueltas = ivueltas + 1;` |  |
| L682 | FÓRMULA | `LET wcuentabenefmsg = substr(pvchrcuentabenef,(length(pvchrcuentabenef)-3),4);` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `spei` | PREFIJO | familia SPEI (pagos interbancarios) | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `recordenpago` | ACCION | recibe orden de pago | 🔵 CONVENCIÓN | nombre_sp |
| `exp` | MODIF | sufijo Exportar — SP genera/exporta archivo de salida (sp_*_ | 🟡 INFERIDO | nombre_sp |
| `?1` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?1` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `spei_recordenpago_hmdtest`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_spei_recordenpago_hmdtest.sql` |
| **LOC (1er CREATE)** | 743 |
| **Callgraph** | ✅ fan_in=0 / fan_out=7 |
| **Propósito inferido** | "recibe orden de pago" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 6 llamada(s): `spei_recerrorescodi`, `sp_inserta_credspei`, `sp_valida_spei_cred` |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=1 / 3 términos |

### Firma

```sql
CREATE PROCEDURE spei_recordenpago_hmdtest(
  pvchrclaverastreo            CHAR(30)
  pdigidord                    INTEGER
  pdigidben                    INTEGER
  pfechalimpago                CHAR(16)
  intBancoOrd                  CHAR(5)
  ppagocomision                INTEGER
  pcomision                    DECIMAL(14,2)
  pnumseriecert                CHAR(20)
  pfolioplataforma             CHAR(20)
  pchrfchmjc                   CHAR(20)
  pvchrNombreOrd               CHAR(40)
  pintTipoCtaBenef             CHAR(2)
  pvchrNombreBenef             CHAR(40)
) RETURNING CHAR(30), -- folio
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pvchrclaverastreo` | `CHAR(30)` | — | — |
| `pdigidord` | `INTEGER` | — | — |
| `pdigidben` | `INTEGER` | — | — |
| `pfechalimpago` | `CHAR(16)` | — | — |
| `intBancoOrd` | `CHAR(5)` | — | — |
| `ppagocomision` | `INTEGER` | — | — |
| `pcomision` | `DECIMAL(14,2)` | — | — |
| `pnumseriecert` | `CHAR(20)` | — | — |
| `pfolioplataforma` | `CHAR(20)` | — | — |
| `pchrfchmjc` | `CHAR(20)` | — | — |
| `pvchrNombreOrd` | `CHAR(40)` | — | — |
| `pintTipoCtaBenef` | `CHAR(2)` | — | — |
| `pvchrNombreBenef` | `CHAR(40)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vCodRet1` | `CHAR(5)` | L33 |
| `vCodRet2` | `CHAR(5)` | L34 |
| `vCodRet3` | `CHAR(50)` | L35 |
| `vSqlErr` | `INTEGER` | L36 |
| `vIsamErr` | `INTEGER` | L37 |
| `vDescErr` | `CHAR(50)` | L38 |
| `wempresa` | `CHAR(3)` | L39 |
| `whora` | `CHAR(15)` | L40 |
| `wserial_folio` | `INTEGER` | L41 |
| `wfolio_suc` | `CHAR(30)` | L42 |
| `wcausa_dev` | `CHAR(2)` | L43 |
| `wcuenta` | `CHAR(20)` | L44 |
| `vcuenta` | `CHAR(20)` | L45 |
| `wnum_tarjeta` | `CHAR(16)` | L46 |
| `wmaxsec` | `SMALLINT` | L47 |
| `wsuc_cta` | `CHAR(4)` | L48 |
| `wsucursal` | `CHAR(4)` | L49 |
| `wusuario` | `CHAR(8)` | L50 |
| `wtransacc` | `CHAR(4)` | L51 |
| `wtran_suc` | `CHAR(4)` | L52 |
| `wdivisa` | `CHAR(2)` | L53 |
| `wexiste_mov` | `INTEGER` | L54 |
| `vrfc` | `CHAR(18)` | L55 |
| `vnombre_cte` | `CHAR(40)` | L56 |
| `wnumcte` | `CHAR(20)` | L57 |
| *…36 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tblbcobloqueo` | `bdispei` | no | SELECT | L256 |
| `tblintfallo` | `bdispei` | no | INSERT | L266 |
| `tblclabebloqueo` | `bdispei` | no | SELECT | L284 |
| `sc_fechas` | `bdicheq` | ⚠️ sí | SELECT | L311 |
| `tblparametros` | `bdispei` | no | SELECT | L351 |
| `sc_maechq` | `bdicheq` | ⚠️ sí | SELECT | L362 |
| `tf_maecte` | `bditransfer` | ⚠️ sí | SELECT | L371 |
| `sc_tarjeta` | `bdicheq` | ⚠️ sí | SELECT | L382 |
| `sd_cat_prod_finac` | `bdicred` | ⚠️ sí | SELECT | L404 |
| `tblpagocred` | `bdispei` | no | SELECT | L423 |
| `si_cliente` | `bdinteg` | ⚠️ sí | SELECT | L466 |
| `sc_cuenta_telefono` | `bdicheq` | ⚠️ sí | SELECT | L521 |
| `si_ctepm` | `bdinteg` | ⚠️ sí | SELECT | L574 |
| `sc_movdia` | `bdicheq` | ⚠️ sí | SELECT | L587 |
| `tblcdev_codret` | `bdispei` | no | SELECT | L696 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `spei_recerrorescodi` | `bdispei` | no | L269 |
| `sp_inserta_credspei` | `bdispei` | no | L417 |
| `sp_valida_spei_cred` | `bdicred` | ⚠️ sí | L442 |
| `sp_obtfoliosuc` | `bdispei` | no | L450 |
| `abono_ref` | `bdicheq` | ⚠️ sí | L653 |
| `sp_registra_evento` | `bdimnsj` | ⚠️ sí | L675 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L142 | FÓRMULA | `LET vtimestamp    = dbinfo('utc_current') * 1000;` |  |
| L331 | VALIDACIÓN_NULL | `IF ( ( pmnyimporte <= 0.00 ) OR ( pchrstatus is null OR pchrstatus = '' OR LENGTH(TRIM(pchrstatus)) ` |  |
| L354 | FÓRMULA | `LET vfech_val = SUBSTR(vfech_spei, 4, 2) \|\| '/' \|\| SUBSTR(vfech_spei, 1,2) \|\| '/' \|\| SUBSTR(` |  |
| L367 | VALIDACIÓN_NULL | `IF ( wnumcte is null OR wnumcte = '' OR wnumcte = ' ' ) THEN` |  |
| L385 | VALIDACIÓN_NULL | `IF ( wnumcte is null OR wnumcte = '' OR wnumcte = ' ' ) THEN` |  |
| L431 | FÓRMULA | `LET vciclo = vciclo + 1;` |  |
| L438 | VALIDACIÓN_NULL | `IF cStatus is null OR cStatus = '' OR cStatus IN('N','E','X') THEN` |  |
| L495 | VALIDACIÓN_NULL | `IF ( wnumcte is null OR wnumcte = '' OR wnumcte = ' ' ) THEN` |  |
| L504 | VALIDACIÓN_NULL | `IF (wnumcte1 is null OR wnumcte1 = '' OR wnumcte1 = ' ' ) THEN` |  |
| L526 | VALIDACIÓN_NULL | `IF vcuenta is null OR vcuenta = '' THEN` |  |
| L538 | VALIDACIÓN_NULL | `IF wnumcte is null OR wnumcte = '' THEN` |  |
| L666 | FÓRMULA | `LET ivueltas = ivueltas + 1;` |  |
| L672 | FÓRMULA | `LET wcuentabenefmsg = substr(pvchrcuentabenef,(length(pvchrcuentabenef)-3),4);` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `spei` | PREFIJO | familia SPEI (pagos interbancarios) | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `recordenpago` | ACCION | recibe orden de pago | 🔵 CONVENCIÓN | nombre_sp |
| `?_hmdtest` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_hmdtest` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `spei_recordenpago_ws`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_spei_recordenpago_ws.sql` |
| **LOC (1er CREATE)** | 1403 |
| **Callgraph** | ✅ fan_in=0 / fan_out=12 |
| **Deps concatenadas** | 2 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "recibe orden de pago" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 6 llamada(s): `spei_recerrorescodi_ws`, `sp_inserta_credspei`, `sp_valida_spei_cred` |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=1 / 3 términos |

### Firma

```sql
CREATE PROCEDURE spei_recordenpago_ws(
  pvchrclaverastreo            CHAR(30)
  pnumcelben                   CHAR (20)
  pdigidord                    INTEGER
  pdigidben                    INTEGER
  pfechalimpago                CHAR(16)
  intBancoOrd                  CHAR(5)
  ppagocomision                INTEGER
  pcomision                    DECIMAL(14,2)
  pnumseriecert                CHAR(20)
  pfolioplataforma             CHAR(20)
  pchridmjc                    CHAR(20)
  pchrfchmjc                   CHAR(20)
  pvchrNombreOrd               CHAR(40)
  pintTipoCtaBenef             CHAR(2)
  pvchrNombreBenef             CHAR(40)
  presfirm                     INTEGER
) RETURNING CHAR(30),         -- folio
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pvchrclaverastreo` | `CHAR(30)` | — | — |
| `pnumcelben` | `CHAR (20)` | — | — |
| `pdigidord` | `INTEGER` | — | — |
| `pdigidben` | `INTEGER` | — | — |
| `pfechalimpago` | `CHAR(16)` | — | — |
| `intBancoOrd` | `CHAR(5)` | — | — |
| `ppagocomision` | `INTEGER` | — | — |
| `pcomision` | `DECIMAL(14,2)` | — | — |
| `pnumseriecert` | `CHAR(20)` | — | — |
| `pfolioplataforma` | `CHAR(20)` | — | — |
| `pchridmjc` | `CHAR(20)` | — | — |
| `pchrfchmjc` | `CHAR(20)` | — | — |
| `pvchrNombreOrd` | `CHAR(40)` | — | — |
| `pintTipoCtaBenef` | `CHAR(2)` | — | — |
| `pvchrNombreBenef` | `CHAR(40)` | — | — |
| `presfirm` | `INTEGER` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vCodRet1` | `CHAR(5)` | L56 |
| `vCodRet2` | `CHAR(5)` | L57 |
| `vCodRet3` | `CHAR(50)` | L58 |
| `vSqlErr` | `INTEGER` | L59 |
| `vIsamErr` | `INTEGER` | L60 |
| `vDescErr` | `CHAR(50)` | L61 |
| `wempresa` | `CHAR(3)` | L62 |
| `whora` | `CHAR(15)` | L63 |
| `wserial_folio` | `INTEGER` | L64 |
| `wfolio_suc` | `CHAR(30)` | L65 |
| `wcausa_dev` | `CHAR(2)` | L66 |
| `wcuenta` | `CHAR(20)` | L67 |
| `vcuenta` | `CHAR(20)` | L68 |
| `wnum_tarjeta` | `CHAR(16)` | L69 |
| `wmaxsec` | `SMALLINT` | L70 |
| `wsuc_cta` | `CHAR(4)` | L71 |
| `wsucursal` | `CHAR(4)` | L72 |
| `wusuario` | `CHAR(8)` | L73 |
| `wtransacc` | `CHAR(4)` | L74 |
| `wtran_suc` | `CHAR(4)` | L75 |
| `wdivisa` | `CHAR(2)` | L76 |
| `wexiste_mov` | `INTEGER` | L77 |
| `vrfc` | `CHAR(18)` | L78 |
| `vnombre_cte` | `CHAR(40)` | L79 |
| `wnumcte` | `CHAR(20)` | L80 |
| *…82 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tblabono` | `bdispei` | no | INSERT | L367 |
| `sc_maechq` | `bdicheq` | ⚠️ sí | SELECT | L394 |
| `sc_tarjeta` | `bdicheq` | ⚠️ sí | SELECT | L403 |
| `sd_cat_prod_finac` | `bdicred` | ⚠️ sí | SELECT | L413 |
| `sc_param` | `bdicheq` | ⚠️ sí | SELECT | L417 |
| `tblpagocred` | `bdispei` | no | SELECT | L444 |
| `sc_cuenta_telefono` | `bdicheq` | ⚠️ sí | SELECT | L535 |
| `tblclabebloqueo` | `bdispei` | no | SELECT | L634 |
| `tblintfallo` | `bdispei` | no | INSERT | L644 |
| `sc_fechas` | `bdicheq` | ⚠️ sí | SELECT | L680 |
| `tblparametros` | `bdispei` | no | SELECT | L758 |
| `sc_ctabloqueo` | `bdicheq` | ⚠️ sí | SELECT | L767 |
| `sc_bloqueo` | `bdicheq` | ⚠️ sí | SELECT | L813 |
| `si_cliente` | `bdinteg` | ⚠️ sí | SELECT | L925 |
| `si_ctepm` | `bdinteg` | ⚠️ sí | SELECT | L950 |
| `sc_movdia` | `bdicheq` | ⚠️ sí | SELECT | L963 |
| `sc_limites_producto` | `bdicheq` | ⚠️ sí | SELECT | L1007 |
| `sc_transacc_exentas_limprod` | `bdicheq` | ⚠️ sí | SELECT | L1013 |
| `si_tpcambio` | `bdinteg` | ⚠️ sí | SELECT | L1021 |
| `sc_acummesctanvl2` | `bdicheq` | ⚠️ sí | SELECT | L1125 |
| `tblcdev_codret` | `bdispei` | no | SELECT | L1243 |
| `tblbancoabono` | `bdispei` | no | SELECT | L1278 |
| `sc_creditohipotecario` | `bdicheq` | ⚠️ sí | INSERT | L1283 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `spei_recerrorescodi_ws` | `bdispei` | no | L360 |
| `sp_inserta_credspei` | `bdispei` | no | L438 |
| `sp_valida_spei_cred` | `bdicred` | ⚠️ sí | L463 |
| `sp_obtfoliosuc` | `bdispei` | no | L471 |
| `abono_ref` | `bdicheq` | ⚠️ sí | L1198 |
| `sp_registra_evento` | `bdimnsj` | ⚠️ sí | L1227 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L217 | FÓRMULA | `LET vtimestamp    = dbinfo('utc_current') * 1000;` |  |
| L452 | FÓRMULA | `LET vciclo = vciclo + 1;` |  |
| L459 | VALIDACIÓN_NULL | `IF cStatus is null OR cStatus = '' OR cStatus IN('N','E','X') THEN` |  |
| L719 | VALIDACIÓN_NULL | `IF ( ( pmnyimporte <= 0.00 ) OR ( pchrstatus is null OR pchrstatus = '' OR LENGTH(TRIM(pchrstatus)) ` |  |
| L761 | FÓRMULA | `LET vfech_val = SUBSTR(vfech_spei,4,2)\|\|'/'\|\|SUBSTR(vfech_spei,1,2)\|\|'/'\|\|SUBSTR(vfech_spei,` |  |
| L887 | VALIDACIÓN_NULL | `IF wnumcte is null OR wnumcte = '' THEN` |  |
| L1026 | VALIDACIÓN_NULL | `IF vhoramax is null OR vhoramax = '' THEN` |  |
| L1045 | VALIDACIÓN_NULL | `IF vprecio_udi is null OR vprecio_udi = '' THEN` |  |
| L1062 | VALIDACIÓN_NULL | `IF vhoramax is null OR vhoramax = '' THEN` |  |
| L1089 | VALIDACIÓN_NULL | `IF vnomaxudis is null THEN` |  |
| L1128 | VALIDACIÓN_NULL | `IF vmtoacumcta is null THEN` |  |
| L1133 | FÓRMULA | `LET vmonto_udi = pmnyimporte / vprecio_udi;` | 🔴 MONEY/aritmética financiera |
| L1136 | FÓRMULA | `LET vmtopagosudi = vmtoacumcta / vprecio_udi;` |  |
| L1139 | FÓRMULA | `LET vlim_cuenta = vmonto_udi + vmtopagosudi;` | 🔴 MONEY/aritmética financiera |
| L1209 | FÓRMULA | `LET ivueltas = ivueltas + 1;` |  |
| L1224 | FÓRMULA | `LET wcuentabenefmsg = substr(pvchrcuentabenef,(length(pvchrcuentabenef)-3),4);` |  |
| L1291 | VALIDACIÓN_NULL | `IF ( wvchrorigen is null OR wvchrorigen = '' OR wvchrorigen = ' ' ) THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `spei` | PREFIJO | familia SPEI (pagos interbancarios) | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `recordenpago` | ACCION | recibe orden de pago | 🔵 CONVENCIÓN | nombre_sp |
| `?_ws` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_ws` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `spei_regresa_estatus`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_spei_regresa_estatus.sql` |
| **LOC (1er CREATE)** | 91 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "registro estatus" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 1 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=2 · INFERIDO=1 · SINTÉTICO=1 / 4 términos |

### Firma

```sql
CREATE PROCEDURE spei_regresa_estatus(
  pRegistros                   INTEGER
) RETURNING CHAR(5), INTEGER, INTEGER
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pRegistros` | `INTEGER` | `reg`=registro | 🟡 INFERIDO |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `Sql_Err` | `INTEGER` | L4 |
| `Isam_Err` | `INTEGER` | L5 |
| `Desc_Err` | `CHAR(50)` | L6 |
| `vCodRet1` | `CHAR(5)` | L7 |
| `vCodRet2` | `CHAR(5)` | L8 |
| `vCodRet3` | `CHAR(50)` | L9 |
| `vContador1` | `INTEGER` | L10 |
| `vContador2` | `INTEGER` | L11 |
| `vContador3` | `INTEGER` | L12 |
| `vComienza` | `SMALLINT` | L13 |
| `vAbierto` | `CHAR(1)` | L14 |
| `vcverastreo` | `CHAR(30)` | L15 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tblpago` | `bdispei` | no | SELECT | L56 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L26 | FÓRMULA | `LET vComienza   = -1;` |  |
| L75 | FÓRMULA | `LET vcontador3 = vcontador3 + 1;` |  |
| L78 | FÓRMULA | `LET vcontador1 = vcontador1 + 1;` |  |
| L79 | FÓRMULA | `LET vcontador2 = vcontador2 + 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `spei` | PREFIJO | familia SPEI (pagos interbancarios) | 🔵 CONVENCIÓN | nombre_sp |
| `reg` | ACCION | registro | 🟡 INFERIDO | nombre_sp |
| `?resa_` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `estatus` | ENTIDAD | estatus | 🔵 CONVENCIÓN | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?resa_` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `spei_upd_status_firma_envio`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_spei_upd_status_firma_envio.sql` |
| **LOC (1er CREATE)** | 120 |
| **Callgraph** | ✅ fan_in=0 / fan_out=5 |
| **Deps concatenadas** | 1 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "actualiza estatus" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `actualiza` → `UPDATE` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=1 · INFERIDO=1 · SINTÉTICO=1 / 5 términos |

### Firma

```sql
CREATE PROCEDURE spei_upd_status_firma_envio(
  presfirm                     INTEGER
  pvchrclaverastreo            CHAR(30)
) RETURNING CHAR(5)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `presfirm` | `INTEGER` | — | — |
| `pvchrclaverastreo` | `CHAR(30)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `iSqlErr` | `INTEGER` | L4 |
| `cCodRet1` | `CHAR(5)` | L5 |
| `vtransaccion` | `INTEGER` | L6 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `en` | `bdispei` | no | UPDATE | L117 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `spei` | PREFIJO | familia SPEI (pagos interbancarios) | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `upd` | ACCION | actualiza (update) | 🟡 INFERIDO | nombre_sp |
| `status` | ENTIDAD | estatus | 🔵 CONVENCIÓN | nombre_sp |
| `?_firma_` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `envio` | ACCION | envía | ✅ CÓDIGO | nombre_sp, texto_cuerpo |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_firma_` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `spei_validafecha`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_spei_validafecha.sql` |
| **LOC (1er CREATE)** | 69 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "valida fecha" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `valida` → `IF` encontrado en el cuerpo · `valida` → `RETURN` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=0 / 3 términos |

### Firma

```sql
CREATE PROCEDURE spei_validafecha(
) RETURNING CHAR(5)
```

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `sql_err` | `INTEGER` | L5 |
| `isam_err` | `INTEGER` | L6 |
| `vcodret1` | `CHAR(5)` | L7 |
| `vcodret2` | `CHAR(5)` | L8 |
| `wfecha_hoy` | `CHAR(10)` | L10 |
| `wfecha_spei` | `CHAR(10)` | L11 |
| `wfecha_habil` | `CHAR(10)` | L12 |
| `wvchrvalor` | `CHAR(1)` | L13 |
| `iFlagDiaLabo` | `INTEGER` | L14 |
| `cEmpresa` | `CHAR(3)` | L15 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tblparametros` | `bdispei` | no | UPDATE | L61 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `spei` | PREFIJO | familia SPEI (pagos interbancarios) | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `valida` | ACCION | valida | 🔵 CONVENCIÓN | nombre_sp |
| `fecha` | ENTIDAD | fecha | ✅ CÓDIGO | nombre_sp, texto_cuerpo |

---

## `spei_validaoperacion`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_spei_validaoperacion.sql` |
| **LOC (1er CREATE)** | 165 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "valida" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `valida` → `IF` encontrado en el cuerpo · `valida` → `RETURN` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=0 / 3 términos |

### Firma

```sql
CREATE PROCEDURE spei_validaoperacion(
  pcuenta                      char(20)
  pmonto                       decimal(17,2)
  pcanal                       char(4)
) RETURNING CHAR(5),  --CODIGO RETORNO
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pcuenta` | `char(20)` | — | — |
| `pmonto` | `decimal(17,2)` | — | — |
| `pcanal` | `char(4)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cSqlerr` | `INTEGER` | L5 |
| `cCodret` | `CHAR(5)` | L6 |
| `cFlagSpei` | `CHAR(1)` | L7 |
| `iMaxSec` | `INTEGER` | L8 |
| `cEmpresa` | `CHAR(3)` | L9 |
| `cCtaOper` | `CHAR(11)` | L10 |
| `cCtaMovil` | `CHAR(10)` | L11 |
| `cTpoCta` | `CHAR(2)` | L12 |
| `vmonto` | `VARCHAR(10)` | L13 |
| `iFlagDiaFeria` | `INTEGER` | L14 |
| `iMontoMax` | `INTEGER` | L15 |
| `iMontoDiaCta` | `INTEGER` | L16 |
| `iMontoDiaTot` | `INTEGER` | L17 |
| `iFlagDiaLabo` | `INTEGER` | L18 |
| `iHorario` | `INTEGER` | L19 |
| `vchrparametro` | `VARCHAR(255)` | L20 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tblparametros` | `bdispei` | no | SELECT | L69 |
| `sc_tarjeta` | `bdicheq` | ⚠️ sí | SELECT | L104 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L59 | VALIDACIÓN_NULL | `IF length(pcuenta) = 0 OR vmonto = 0 OR vmonto is null  THEN` |  |
| L72 | VALIDACIÓN_NULL | `IF vchrparametro IS NULL THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `spei` | PREFIJO | familia SPEI (pagos interbancarios) | 🔵 CONVENCIÓN | nombre_sp |
| `valida` | ACCION | valida | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `operacion` | ACCION | operación | 🔵 CONVENCIÓN | nombre_sp |

---

## `spei_validaoperacion_pba`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_spei_validaoperacion_pba.sql` |
| **LOC (1er CREATE)** | 161 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "valida (PBA — sufijo de SPs para Pruebas; confirmado por SME)" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `valida` → `IF` encontrado en el cuerpo · `valida` → `RETURN` encontrado en el cuerpo · `confirma` → `SELECT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=0 / 4 términos |

### Firma

```sql
CREATE PROCEDURE spei_validaoperacion_pba(
  pcuenta                      char(20)
  pmonto                       decimal(17,2)
  pcanal                       char(4)
) RETURNING CHAR(5),  --CODIGO RETORNO
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pcuenta` | `char(20)` | — | — |
| `pmonto` | `decimal(17,2)` | — | — |
| `pcanal` | `char(4)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cSqlerr` | `INTEGER` | L5 |
| `cCodret` | `CHAR(5)` | L6 |
| `cFlagSpei` | `CHAR(1)` | L7 |
| `iMaxSec` | `INTEGER` | L8 |
| `cEmpresa` | `CHAR(3)` | L9 |
| `cCtaOper` | `CHAR(11)` | L10 |
| `cCtaMovil` | `CHAR(10)` | L11 |
| `cTpoCta` | `CHAR(2)` | L12 |
| `vmonto` | `VARCHAR(10)` | L13 |
| `iFlagDiaFeria` | `INTEGER` | L14 |
| `iMontoMax` | `INTEGER` | L15 |
| `iMontoDiaCta` | `INTEGER` | L16 |
| `iMontoDiaTot` | `INTEGER` | L17 |
| `iFlagDiaLabo` | `INTEGER` | L18 |
| `iHorario` | `INTEGER` | L19 |
| `vchrparametro` | `VARCHAR(255)` | L20 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tblparametros` | `bdispei` | no | SELECT | L67 |
| `sc_tarjeta` | `bdicheq` | ⚠️ sí | SELECT | L100 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L59 | VALIDACIÓN_NULL | `IF length(pcuenta) = 0 OR vmonto = 0 OR vmonto is null  THEN` |  |
| L70 | VALIDACIÓN_NULL | `IF vchrparametro IS NULL THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `spei` | PREFIJO | familia SPEI (pagos interbancarios) | 🔵 CONVENCIÓN | nombre_sp |
| `valida` | ACCION | valida | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `operacion` | ACCION | operación | 🔵 CONVENCIÓN | nombre_sp |
| `pba` | MODIF | PBA — sufijo de SPs para Pruebas; confirmado por SME (Guerra | 🔵 CONVENCIÓN | nombre_sp |

---

## `spei_validaoperacion_prue99jjv`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_spei_validaoperacion_prue99jjv.sql` |
| **LOC (1er CREATE)** | 165 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "valida" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `valida` → `IF` encontrado en el cuerpo · `valida` → `RETURN` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=1 / 4 términos |

### Firma

```sql
CREATE PROCEDURE spei_validaoperacion_prue99jjv(
  pcuenta                      char(20)
  pmonto                       decimal(17,2)
  pcanal                       char(4)
) RETURNING CHAR(5),  --CODIGO RETORNO
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pcuenta` | `char(20)` | — | — |
| `pmonto` | `decimal(17,2)` | — | — |
| `pcanal` | `char(4)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cSqlerr` | `INTEGER` | L5 |
| `cCodret` | `CHAR(5)` | L6 |
| `cFlagSpei` | `CHAR(1)` | L7 |
| `iMaxSec` | `INTEGER` | L8 |
| `cEmpresa` | `CHAR(3)` | L9 |
| `cCtaOper` | `CHAR(11)` | L10 |
| `cCtaMovil` | `CHAR(10)` | L11 |
| `cTpoCta` | `CHAR(2)` | L12 |
| `vmonto` | `VARCHAR(10)` | L13 |
| `iFlagDiaFeria` | `INTEGER` | L14 |
| `iMontoMax` | `INTEGER` | L15 |
| `iMontoDiaCta` | `INTEGER` | L16 |
| `iMontoDiaTot` | `INTEGER` | L17 |
| `iFlagDiaLabo` | `INTEGER` | L18 |
| `iHorario` | `INTEGER` | L19 |
| `vchrparametro` | `VARCHAR(255)` | L20 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tblparametros` | `bdispei` | no | SELECT | L69 |
| `sc_tarjeta` | `bdicheq` | ⚠️ sí | SELECT | L104 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L59 | VALIDACIÓN_NULL | `IF length(pcuenta) = 0 OR vmonto = 0 OR vmonto is null  THEN` |  |
| L72 | VALIDACIÓN_NULL | `IF vchrparametro IS NULL THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `spei` | PREFIJO | familia SPEI (pagos interbancarios) | 🔵 CONVENCIÓN | nombre_sp |
| `valida` | ACCION | valida | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `operacion` | ACCION | operación | 🔵 CONVENCIÓN | nombre_sp |
| `?_prue99jjv` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_prue99jjv` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `spei_validaoperacion_pruejjv`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_spei_validaoperacion_pruejjv.sql` |
| **LOC (1er CREATE)** | 158 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "valida" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `valida` → `IF` encontrado en el cuerpo · `valida` → `RETURN` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=1 / 4 términos |

### Firma

```sql
CREATE PROCEDURE spei_validaoperacion_pruejjv(
  pcuenta                      CHAR(20)
  pmonto                       DECIMAL(17,2)
) RETURNING CHAR(5),  --CODIGO RETORNO
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pcuenta` | `CHAR(20)` | — | — |
| `pmonto` | `DECIMAL(17,2)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cSqlerr` | `INTEGER` | L5 |
| `cCodret` | `CHAR(5)` | L6 |
| `cFlagSpei` | `CHAR(1)` | L7 |
| `iMaxSec` | `INTEGER` | L8 |
| `cEmpresa` | `CHAR(3)` | L9 |
| `cCtaOper` | `CHAR(11)` | L10 |
| `cCtaMovil` | `CHAR(10)` | L11 |
| `cTpoCta` | `CHAR(2)` | L12 |
| `vmonto` | `VARCHAR(10)` | L13 |
| `iFlagDiaFeria` | `INTEGER` | L14 |
| `iMontoMax` | `INTEGER` | L15 |
| `iMontoDiaCta` | `INTEGER` | L16 |
| `iMontoDiaTot` | `INTEGER` | L17 |
| `iFlagDiaLabo` | `INTEGER` | L18 |
| `vchrparametro` | `VARCHAR(255)` | L19 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tblparametros` | `bdispei` | no | SELECT | L67 |
| `sc_tarjeta` | `bdicheq` | ⚠️ sí | SELECT | L102 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L57 | VALIDACIÓN_NULL | `IF length(pcuenta) = 0 OR vmonto = 0 OR vmonto is null  THEN` |  |
| L70 | VALIDACIÓN_NULL | `IF vchrparametro IS NULL THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `spei` | PREFIJO | familia SPEI (pagos interbancarios) | 🔵 CONVENCIÓN | nombre_sp |
| `valida` | ACCION | valida | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `operacion` | ACCION | operación | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?_pruejjv` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_pruejjv` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `speicentral`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_speicentral.sql` |
| **LOC (1er CREATE)** | 66 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "(central)" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 2 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=0 / 2 términos |

### Firma

```sql
CREATE PROCEDURE speicentral(
) RETURNING CHAR(5)
```

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `sql_err` | `INTEGER` | L5 |
| `isam_err` | `INTEGER` | L6 |
| `vcodret1` | `CHAR(5)` | L7 |
| `vexiste` | `INTEGER` | L8 |
| `vcountresult` | `INTEGER` | L11 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_feriado` | `bdinteg` | ⚠️ sí | SELECT | L39 |
| `tblpago` | `bdispei` | no | SELECT | L46 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `spei` | PREFIJO | familia SPEI (pagos interbancarios) | 🔵 CONVENCIÓN | nombre_sp |
| `central` | MODIF | central | 🔵 CONVENCIÓN | nombre_sp |

---

## `speicentral_exp1`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_speicentral_exp1.sql` |
| **LOC (1er CREATE)** | 65 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "(central, sufijo Exportar — SP genera/exporta archivo de salida)" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `genera` → `SELECT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=2 · INFERIDO=1 · SINTÉTICO=1 / 4 términos |

### Firma

```sql
CREATE PROCEDURE speicentral_exp1(
) RETURNING CHAR(5)
```

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `sql_err` | `INTEGER` | L5 |
| `isam_err` | `INTEGER` | L6 |
| `vcodret1` | `CHAR(5)` | L7 |
| `vexiste` | `INTEGER` | L8 |
| `vcountresult` | `INTEGER` | L11 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_feriado` | `bdinteg` | ⚠️ sí | SELECT | L39 |
| `tblpago` | `bdispei` | no | SELECT | L46 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `spei` | PREFIJO | familia SPEI (pagos interbancarios) | 🔵 CONVENCIÓN | nombre_sp |
| `central` | MODIF | central | 🔵 CONVENCIÓN | nombre_sp |
| `exp` | MODIF | sufijo Exportar — SP genera/exporta archivo de salida (sp_*_ | 🟡 INFERIDO | nombre_sp |
| `?1` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?1` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `spl_devolucionspei`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_spl_devolucionspei.sql` |
| **LOC (1er CREATE)** | 111 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "devuelve" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 1 llamada(s): `sp_obtsigfolioop` |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=1 / 4 términos |

### Firma

```sql
CREATE PROCEDURE spl_devolucionspei(
  lngPkPagoOriginal            integer
  intFolioPaquete              integer
  mlngFolioPago                integer
  mstrMotivoDevolucion         char(1)
) RETURNING char(5)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `lngPkPagoOriginal` | `integer` | — | — |
| `intFolioPaquete` | `integer` | — | — |
| `mlngFolioPago` | `integer` | — | — |
| `mstrMotivoDevolucion` | `char(1)` | `devolucion`=devuelve | 🔵 CONVENCIÓN |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `v_codret` | `char(5)` | L8 |
| `intpkpaqueteenv1` | `integer` | L9 |
| `intPkPago1` | `integer` | L10 |
| `dtFechaOp` | `date` | L13 |
| `lngCveCesifOrd` | `integer` | L14 |
| `lngCveCesifBenef` | `integer` | L15 |
| `bytPrioridad` | `char(1)` | L16 |
| `mcurMonto` | `decimal(19,0)` | L17 |
| `mstrClaveRastreo` | `varchar(30)` | L18 |
| `mnyImportepaquete` | `decimal(19,0)` | L20 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tblpago` | `bdispei` | no | SELECT | L39 |
| `tblpaqueteenv` | `bdispei` | no | INSERT | L42 |
| `tblpago` | `bdispei` | no | INSERT | L68 |
| `tblpaqueteenv` | `bdispei` | no | UPDATE | L106 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_obtsigfolioop` | `bdispei` | no | L29 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `?l_` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `devolucion` | ACCION | devuelve | 🔵 CONVENCIÓN | nombre_sp |
| `spei` | PREFIJO | familia SPEI (pagos interbancarios) | 🔵 CONVENCIÓN | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?l_` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `valida_spei`

| Campo | Valor |
|-------|-------|
| **Dominio** | D08 · `bdispei` · SPEI |
| **Archivo fuente** | `bdispei_valida_spei.sql` |
| **LOC (1er CREATE)** | 63 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "valida" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `valida` → `IF` encontrado en el cuerpo · `valida` → `RETURN` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=0 / 2 términos |

### Firma

```sql
CREATE PROCEDURE valida_spei(
  monto                        money(14,2)
  num_cte                      char(20)
  num_ren                      integer
) RETURNING char(5), char(20)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `monto` | `money(14,2)` | — | — |
| `num_cte` | `char(20)` | — | — |
| `num_ren` | `integer` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vt_cod_ret` | `char(5)` | L11 |
| `vt_cuenta` | `char(20)` | L12 |
| `vt_bloq_prom` | `char(1)` | L13 |
| `vt_status` | `char(1)` | L14 |
| `vt_monto_min` | `money(14,2)` | L15 |
| `vt_monto_max` | `money(14,2)` | L16 |
| `vt_banco` | `integer` | L17 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `convenio_mn` | `terceros` | ⚠️ sí | SELECT | L41 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L26 | FÓRMULA | `let vt_banco = 0;    --FRA 20/10/1999` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `valida` | ACCION | valida | 🔵 CONVENCIÓN | nombre_sp |
| `spei` | PREFIJO | familia SPEI (pagos interbancarios) | 🔵 CONVENCIÓN | nombre_sp |

---

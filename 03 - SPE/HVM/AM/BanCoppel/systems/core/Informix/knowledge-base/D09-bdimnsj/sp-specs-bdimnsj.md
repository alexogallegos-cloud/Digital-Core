# SP Specs — D09 · `bdimnsj` · Mensajería

> Generado por `build-sp-specs.py` · Grounding Pass v1.0
> Objetivo: verificar el conocimiento del Gemelo Cognitivo contra el código fuente real
> **Convención:** solo se analiza el PRIMER `CREATE PROCEDURE` de cada archivo
> (los siguientes son dependencias concatenadas — ver memoria del proyecto)

## Resumen de validación del dominio

| Métrica | Valor |
|---------|-------|
| SPs analizados | **47** |
| Presentes en callgraph | 1 |
| SPs aislados (⚠️ no estaban en el análisis previo) | 46 |
| Propósito **VERIFICADO** | 37 |
| Propósito **PARCIAL** | 9 |
| Propósito **NO_VERIFICABLE** | 1 |
| SPs con tokens **SINTÉTICOS** detectados | 20 |

> Los **46 SPs aislados** no aparecen en el callgraph y por tanto
> **no fueron incluidos en el análisis de journeys, reglas ni vocabulario previo**.
> Este grounding pass los analiza por primera vez directamente desde el código.

---

## `sp_act_susc_ctes`

| Campo | Valor |
|-------|-------|
| **Dominio** | D09 · `bdimnsj` · Mensajería |
| **Archivo fuente** | `bdimnsj_sp_act_susc_ctes.sql` |
| **LOC (1er CREATE)** | 142 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "actualiza suscriptor y clientes" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 3 tabla(s) con operaciones: SELECT, DELETE, INSERT |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=0 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_act_susc_ctes(
  pNumCte                      CHAR(20)
  pCod1                        CHAR(1)
  pCod2                        CHAR(1)
  pCod3                        CHAR(1)
  pCod4                        CHAR(1)
  pCod5                        CHAR(1)
  pCod6                        CHAR(1)
  pCod7                        CHAR(1)
  pCod8                        CHAR(1)
) RETURNING CHAR(5)   AS cCodRet,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pNumCte` | `CHAR(20)` | — | — |
| `pCod1` | `CHAR(1)` | — | — |
| `pCod2` | `CHAR(1)` | — | — |
| `pCod3` | `CHAR(1)` | — | — |
| `pCod4` | `CHAR(1)` | — | — |
| `pCod5` | `CHAR(1)` | — | — |
| `pCod6` | `CHAR(1)` | — | — |
| `pCod7` | `CHAR(1)` | — | — |
| `pCod8` | `CHAR(1)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR (5)` | L8 |
| `cMensaje` | `CHAR (40)` | L9 |
| `cNumCte` | `CHAR (20)` | L10 |
| `vCod1` | `CHAR (1)` | L11 |
| `vCod2` | `CHAR (1)` | L12 |
| `vCod3` | `CHAR (1)` | L13 |
| `vCod4` | `CHAR (1)` | L14 |
| `vCod5` | `CHAR (1)` | L15 |
| `vCod6` | `CHAR (1)` | L16 |
| `vCod7` | `CHAR (1)` | L17 |
| `vCod8` | `CHAR (1)` | L18 |
| `vCod` | `CHAR (3)` | L19 |
| `iSqlErr` | `INTEGER` | L20 |
| `iCont` | `INTEGER` | L21 |
| `sCodigo` | `CHAR(3)` | L22 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `mnsjr_suscripcion_ctes` | `bdimnsj` | no | SELECT | L69 |
| `mnsjr_suscripcion_ctes` | `bdimnsj` | no | INSERT | L92 |
| `mnsjr_suscripcion_ctes` | `bdimnsj` | no | DELETE | L94 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L25 | CÓDIGO_RETORNO | `LET cCodRet 	= '00000';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `act` | ACCION | actualiza | 🔵 CONVENCIÓN | nombre_sp |
| `susc` | ENTIDAD | suscriptor / suscripción (alertas SMS/email — tablas mnsjr_s | 🔵 CONVENCIÓN | nombre_sp |
| `ctes` | ENTIDAD | clientes | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |

---

## `sp_actstatus_mnsj`

| Campo | Valor |
|-------|-------|
| **Dominio** | D09 · `bdimnsj` · Mensajería |
| **Archivo fuente** | `bdimnsj_sp_actstatus_mnsj.sql` |
| **LOC (1er CREATE)** | 74 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "actualiza estatus" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `actualiza` → `UPDATE` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=0 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_actstatus_mnsj(
  psecuencial                  INTEGER
  pid_mensaje                  CHAR(10)
  ptransactionid               CHAR(24)
  pestatus                     INTEGER
  pfecha_recup                 DATE
)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `psecuencial` | `INTEGER` | — | — |
| `pid_mensaje` | `CHAR(10)` | — | — |
| `ptransactionid` | `CHAR(24)` | `act`=actualiza | 🔵 CONVENCIÓN |
| `pestatus` | `INTEGER` | `status`=estatus | ✅ CÓDIGO |
| `pfecha_recup` | `DATE` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `viSqlError` | `INTEGER` | L10 |
| `isam_error` | `INTEGER` | L11 |
| `vsMensaje` | `CHAR(200)` | L12 |
| `vsCodRetorno` | `CHAR (5)` | L13 |
| `visam_error` | `INTEGER` | L14 |
| `vdFechaHoy` | `DATETIME YEAR TO FRACTION(5)` | L15 |
| `vscompara` | `CHAR(3)` | L16 |
| `vexiste` | `INTEGER` | L17 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `mnsj_errores` | `bdimnsj` | no | INSERT | L42 |
| `mnsj_transacc_status` | `bdimnsj` | no | SELECT | L54 |
| `mnsj_transacc_status` | `bdimnsj` | no | UPDATE | L59 |
| `mnsj_transacc_status` | `bdimnsj` | no | INSERT | L65 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L30 | FÓRMULA | `LET vdFechaHoy = CAST('1900-01-01 12:00:00' AS DATETIME YEAR TO FRACTION(5));` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `act` | ACCION | actualiza | 🔵 CONVENCIÓN | nombre_sp |
| `status` | ENTIDAD | estatus | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `mnsj` | PREFIJO | mensajería / notificaciones (dominio bdimnsj) | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |

---

## `sp_chi_notifica_resultados`

| Campo | Valor |
|-------|-------|
| **Dominio** | D09 · `bdimnsj` · Mensajería |
| **Archivo fuente** | `bdimnsj_sp_chi_notifica_resultados.sql` |
| **LOC (1er CREATE)** | 192 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "notifica CHI — formato/protocolo de consulta al Buró de Crédito y resultado" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo · `notifica` → `INSERT` encontrado en el cuerpo · `notifica` → `EXECUTE` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=1 / 5 términos |

### Historia del SP

| Tipo | Valor |
|------|-------|
| FECHA | 23/03/2021 |
| MODIFICACION | Isaac Flores Ruiz |
| FECHA | 08/07/2021, 24/11/2021 |
| MODIFICACION | Obtención de fecha current en lugar de fecha sistema de bdicred:sd_fechas. |

### Firma

```sql
CREATE PROCEDURE sp_chi_notifica_resultados(
  p_ccodproc                   CHAR(3)
  p_cstatusproc                CHAR(5)
) RETURNING CHAR(5) AS codigo_retorno
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_ccodproc` | `CHAR(3)` | — | — |
| `p_cstatusproc` | `CHAR(5)` | `sp`=stored procedure | 🔵 CONVENCIÓN |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `sql_err` | `INTEGER` | L20 |
| `isam_err` | `INTEGER` | L21 |
| `error_info` | `CHAR(40)` | L22 |
| `cod_ret` | `CHAR(5)` | L23 |
| `mensaje_ret` | `VARCHAR(255)` | L24 |
| `v_cempresa` | `CHAR(3)` | L28 |
| `v_cdesc_area` | `VARCHAR(20)` | L29 |
| `v_cnombre_proc` | `VARCHAR(60)` | L30 |
| `v_ctipoMsj` | `CHAR(1)` | L31 |
| `v_cidMsj` | `VARCHAR(10)` | L32 |
| `v_cidPlantilla` | `VARCHAR(12)` | L33 |
| `v_cnumclt` | `VARCHAR(20)` | L34 |
| `v_cnumcta` | `VARCHAR(20)` | L35 |
| `v_cnumTarjeta` | `VARCHAR(16)` | L36 |
| `v_ctipoproc` | `CHAR(1)` | L37 |
| `v_cstr1` | `CHAR(30)` | L38 |
| `v_cstr2` | `VARCHAR(30)` | L39 |
| `v_cstr3` | `VARCHAR(30)` | L40 |
| `v_cstr4` | `VARCHAR(30)` | L41 |
| `v_cstr5` | `VARCHAR(150)` | L42 |
| `v_cstr6` | `VARCHAR(100)` | L43 |
| `v_cstr7` | `VARCHAR(60)` | L44 |
| `v_cstr8` | `VARCHAR(60)` | L45 |
| `v_cstr9` | `VARCHAR(15)` | L46 |
| `v_cstr10` | `VARCHAR(100)` | L47 |
| *…14 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sd_fechas` | `bdicred` | ⚠️ sí | SELECT | L134 |
| `mnsj_chi_notifica_resultados` | `bdimnsj` | no | SELECT | L152 |
| `mnsj_chi_notifica_resultados_hist` | `bdimnsj` | no | SELECT | L170 |
| `mnsj_chi_notifica_resultados_hist` | `bdimnsj` | no | INSERT | L174 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_registra_evento` | `bdimnsj` | no | L158 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L136 | FÓRMULA | `LET v_cfechahoy = v_cdia \|\| '/' \|\| v_cmes \|\| '/' \|\| v_cyear;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `chi` | ENTIDAD | CHI — formato/protocolo de consulta al Buró de Crédito (bdib | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `notifica` | ACCION | notifica | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `resultado` | ENTIDAD | resultado | 🔵 CONVENCIÓN | nombre_sp |
| `?s` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?s` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_con_susc_ctes`

| Campo | Valor |
|-------|-------|
| **Dominio** | D09 · `bdimnsj` · Mensajería |
| **Archivo fuente** | `bdimnsj_sp_con_susc_ctes.sql` |
| **LOC (1er CREATE)** | 170 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "consulta suscriptor y clientes" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=2 · INFERIDO=1 · SINTÉTICO=0 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_con_susc_ctes(
  pTipo                        CHAR(1)
  pNumCte                      CHAR(20)
  pNumCta                      CHAR(20)
  pNumTarjeta                  CHAR(16)
) RETURNING CHAR(5)   AS cCodRet,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pTipo` | `CHAR(1)` | — | — |
| `pNumCte` | `CHAR(20)` | — | — |
| `pNumCta` | `CHAR(20)` | — | — |
| `pNumTarjeta` | `CHAR(16)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `VARCHAR (5)` | L16 |
| `cMensaje` | `VARCHAR(40)` | L17 |
| `vCod1` | `VARCHAR (2)` | L18 |
| `vCod2` | `VARCHAR (2)` | L19 |
| `vCod3` | `VARCHAR (2)` | L20 |
| `vCod4` | `VARCHAR (2)` | L21 |
| `vCod5` | `VARCHAR (2)` | L22 |
| `vCod6` | `VARCHAR (2)` | L23 |
| `vCod7` | `VARCHAR (2)` | L24 |
| `vCod8` | `VARCHAR (2)` | L25 |
| `vCod` | `VARCHAR (3)` | L26 |
| `vNumCte` | `CHAR(20)` | L27 |
| `vNombre1` | `VARCHAR(26)` | L28 |
| `vNombre2` | `VARCHAR(26)` | L29 |
| `vApellPat` | `VARCHAR(26)` | L30 |
| `vApellMat` | `VARCHAR(26)` | L31 |
| `vNombre` | `VARCHAR(107)` | L32 |
| `iSqlErr` | `INTEGER` | L33 |
| `vCodAct` | `CHAR(3)` | L34 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sc_maechq` | `bdicheq` | ⚠️ sí | SELECT | L91 |
| `sd_maecred` | `bdicred` | ⚠️ sí | SELECT | L97 |
| `sc_tarjeta` | `bdicheq` | ⚠️ sí | SELECT | L104 |
| `sd_tarjeta` | `bdicred` | ⚠️ sí | SELECT | L110 |
| `si_cliente` | `bdinteg` | ⚠️ sí | SELECT | L119 |
| `mnsjr_cat_suscripcion` | `bdimnsj` | no | SELECT | L132 |
| `mnsjr_suscripcion_ctes` | `bdimnsj` | no | SELECT | L150 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L38 | CÓDIGO_RETORNO | `LET cCodRet = '00000';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `con` | ACCION | consulta | 🟡 INFERIDO | nombre_sp |
| `susc` | ENTIDAD | suscriptor / suscripción (alertas SMS/email — tablas mnsjr_s | 🔵 CONVENCIÓN | nombre_sp |
| `ctes` | ENTIDAD | clientes | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |

---

## `sp_confirma_evento`

| Campo | Valor |
|-------|-------|
| **Dominio** | D09 · `bdimnsj` · Mensajería |
| **Archivo fuente** | `bdimnsj_sp_confirma_evento.sql` |
| **LOC (1er CREATE)** | 273 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "confirma evento/notificación" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `confirma` → `SELECT` encontrado en el cuerpo · `confirma` → `UPDATE` encontrado en el cuerpo · `notifica` → `INSERT` encontrado en el cuerpo · `notifica` → `EXECUTE` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=0 / 3 términos |

### Firma

```sql
CREATE PROCEDURE sp_confirma_evento(
  pid_pos_atm                  char(2)
  pid_deb_cre                  char(2)
  pid_reverso                  char(1)
  pno_tarjeta                  char(16)
  pno_autorizacion             char(12)
  pinfreceptor                 char(40)
  pimporte                     money(16,2)
  pimp_comision                money(16,2)
  pfecha_aut                   datetime year to fraction(3)
  psecuencia_ext               char(16)
  pcajero_propio               char(1)
) RETURNING CHAR(5) as cCodRet
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pid_pos_atm` | `char(2)` | — | — |
| `pid_deb_cre` | `char(2)` | — | — |
| `pid_reverso` | `char(1)` | — | — |
| `pno_tarjeta` | `char(16)` | — | — |
| `pno_autorizacion` | `char(12)` | — | — |
| `pinfreceptor` | `char(40)` | — | — |
| `pimporte` | `money(16,2)` | — | — |
| `pimp_comision` | `money(16,2)` | — | — |
| `pfecha_aut` | `datetime year to fraction(3)` | — | — |
| `psecuencia_ext` | `char(16)` | — | — |
| `pcajero_propio` | `char(1)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(5)` | L10 |
| `cid_mensaje1` | `CHAR(10)` | L11 |
| `cid_mensaje2` | `CHAR(10)` | L12 |
| `ccajero` | `CHAR(20)` | L13 |
| `vsqlerr` | `INTEGER` | L14 |
| `dSecuencia` | `DECIMAL(12,0)` | L15 |
| `SQL_ERR` | `INTEGER` | L17 |
| `ISAM_ERR` | `INTEGER` | L18 |
| `ERROR_INFO` | `VARCHAR(80)` | L19 |
| `bandera` | `CHAR(100)` | L20 |
| `stmt` | `LVARCHAR(2000)` | L22 |
| `vTablaNotif` | `varchar (50)` | L23 |
| `pfecha_aut_aux` | `varchar (10)` | L24 |
| `pimporte_aux` | `varchar (20)` | L25 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `mnsjr_bitacora_err` | `bdimnsj` | no | INSERT | L42 |
| `mnsj_param` | `bdimnsj` | no | SELECT | L57 |
| `notif_cfg` | `bdimnsj` | no | SELECT | L118 |
| `stmt` | `bdimnsj` | no | SELECT | L139 |
| `mnsjr_trx_online` | `bdimnsj` | no | SELECT | L151 |
| `mnsjr_trx_online` | `bdimnsj` | no | UPDATE | L176 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L29 | CÓDIGO_RETORNO | `LET cCodRet = '00000';` |  |
| L93 | VALIDACIÓN_NULL | `IF (pno_tarjeta IS NULL) THEN` |  |
| L96 | VALIDACIÓN_NULL | `IF (pno_autorizacion IS NULL) THEN` |  |
| L99 | VALIDACIÓN_NULL | `IF (pinfreceptor IS NULL) THEN` |  |
| L102 | VALIDACIÓN_NULL | `IF (pimporte IS NULL) THEN` |  |
| L105 | VALIDACIÓN_NULL | `IF (pimp_comision IS NULL) THEN` |  |
| L108 | VALIDACIÓN_NULL | `IF (psecuencia_ext IS NULL) THEN` |  |
| L111 | VALIDACIÓN_NULL | `IF (pcajero_propio IS NULL) THEN` |  |
| L123 | VALIDACIÓN_NULL | `IF (vTablaNotif IS NULL OR vTablaNotif = '') THEN` |  |
| L159 | VALIDACIÓN_NULL | `IF (dSecuencia IS NULL) THEN` |  |
| L162 | VALIDACIÓN_NULL | `IF dSecuencia > 0 AND NOT dSecuencia IS NULL THEN` |  |
| L199 | VALIDACIÓN_NULL | `IF (vTablaNotif IS NULL OR vTablaNotif = '') THEN` |  |
| L239 | VALIDACIÓN_NULL | `IF (dSecuencia IS NULL) THEN` |  |
| L242 | VALIDACIÓN_NULL | `IF dSecuencia > 0 AND NOT dSecuencia IS NULL THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `confirma` | ACCION | confirma | 🔵 CONVENCIÓN | nombre_sp |
| `evento` | ENTIDAD | evento/notificación | 🔵 CONVENCIÓN | nombre_sp |

---

## `sp_confirma_evento_pba`

| Campo | Valor |
|-------|-------|
| **Dominio** | D09 · `bdimnsj` · Mensajería |
| **Archivo fuente** | `bdimnsj_sp_confirma_evento_pba.sql` |
| **LOC (1er CREATE)** | 128 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "confirma evento/notificación (PBA — sufijo de SPs para Pruebas; confirmado por SME)" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `confirma` → `SELECT` encontrado en el cuerpo · `confirma` → `UPDATE` encontrado en el cuerpo · `notifica` → `INSERT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=4 · INFERIDO=0 · SINTÉTICO=0 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_confirma_evento_pba(
  pid_pos_atm                  char(2)
  pid_deb_cre                  char(2)
  pid_reverso                  char(1)
  pno_tarjeta                  char(16)
  pno_autorizacion             char(12)
  pinfreceptor                 char(40)
  pimporte                     money(16,2)
  pimp_comision                money(16,2)
  pfecha_aut                   datetime year to fraction(3)
  psecuencia_ext               char(16)
  pcajero_propio               char(1)
) RETURNING CHAR(5) as cCodRet
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pid_pos_atm` | `char(2)` | — | — |
| `pid_deb_cre` | `char(2)` | — | — |
| `pid_reverso` | `char(1)` | — | — |
| `pno_tarjeta` | `char(16)` | — | — |
| `pno_autorizacion` | `char(12)` | — | — |
| `pinfreceptor` | `char(40)` | — | — |
| `pimporte` | `money(16,2)` | — | — |
| `pimp_comision` | `money(16,2)` | — | — |
| `pfecha_aut` | `datetime year to fraction(3)` | — | — |
| `psecuencia_ext` | `char(16)` | — | — |
| `pcajero_propio` | `char(1)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(5)` | L10 |
| `cid_mensaje1` | `CHAR(10)` | L11 |
| `cid_mensaje2` | `CHAR(10)` | L12 |
| `ccajero` | `CHAR(20)` | L13 |
| `vsqlerr` | `INTEGER` | L14 |
| `dSecuencia` | `DECIMAL(12,0)` | L15 |
| `SQL_ERR` | `INTEGER` | L17 |
| `ISAM_ERR` | `INTEGER` | L18 |
| `ERROR_INFO` | `VARCHAR(80)` | L19 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `mnsjr_bitacora_err` | `bdimnsj` | no | INSERT | L33 |
| `mnsjr_trx_online` | `bdimnsj` | no | SELECT | L71 |
| `mnsjr_trx_online` | `bdimnsj` | no | UPDATE | L87 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L22 | CÓDIGO_RETORNO | `LET cCodRet = '00000';` |  |
| L78 | VALIDACIÓN_NULL | `IF dSecuencia > 0 AND NOT dSecuencia IS NULL THEN` |  |
| L106 | VALIDACIÓN_NULL | `IF dSecuencia > 0 AND NOT dSecuencia IS NULL THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `confirma` | ACCION | confirma | 🔵 CONVENCIÓN | nombre_sp |
| `evento` | ENTIDAD | evento/notificación | 🔵 CONVENCIÓN | nombre_sp |
| `pba` | MODIF | PBA — sufijo de SPs para Pruebas; confirmado por SME (Guerra | 🔵 CONVENCIÓN | nombre_sp |

---

## `sp_confirmasms`

| Campo | Valor |
|-------|-------|
| **Dominio** | D09 · `bdimnsj` · Mensajería |
| **Archivo fuente** | `bdimnsj_sp_confirmasms.sql` |
| **LOC (1er CREATE)** | 39 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "confirma vía SMS" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `confirma` → `SELECT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=0 / 2 términos |

### Firma

```sql
CREATE PROCEDURE sp_confirmasms(
  pTelCel                      CHAR(10)
  pCodigo                      CHAR(4)
) RETURNING CHAR(5) 	 AS cCodRet
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pTelCel` | `CHAR(10)` | — | — |
| `pCodigo` | `CHAR(4)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `iSqlErr` | `INTEGER` | L5 |
| `cCodRet` | `CHAR(5)` | L6 |
| `cSitEsp` | `CHAR(5)` | L7 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `mnsjr_trx_online` | `bdimnsj` | no | SELECT | L30 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L31 | CÓDIGO_RETORNO | `LET cCodRet='00000';` |  |
| L33 | CÓDIGO_RETORNO | `LET cCodRet='00001';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `confirmasms` | ACCION | confirma vía SMS (2FA) | 🔵 CONVENCIÓN | nombre_sp |

---

## `sp_confirmasmscte`

| Campo | Valor |
|-------|-------|
| **Dominio** | D09 · `bdimnsj` · Mensajería |
| **Archivo fuente** | `bdimnsj_sp_confirmasmscte.sql` |
| **LOC (1er CREATE)** | 46 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "confirma vía SMS cliente" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `confirma` → `SELECT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=0 / 3 términos |

### Firma

```sql
CREATE PROCEDURE sp_confirmasmscte(
  pTelCel                      CHAR(10)
  pNumCte                      CHAR(9)
) RETURNING CHAR(4) 	 AS sCodSMS
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pTelCel` | `CHAR(10)` | — | — |
| `pNumCte` | `CHAR(9)` | `cte`=cliente | 🔵 CONVENCIÓN |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `iSqlErr` | `INTEGER` | L5 |
| `cCodRet` | `CHAR(5)` | L6 |
| `cSitEsp` | `CHAR(5)` | L7 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_bitsmstels` | `bdinteg` | ⚠️ sí | SELECT | L29 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `confirmasms` | ACCION | confirma vía SMS (2FA) | 🔵 CONVENCIÓN | nombre_sp |
| `cte` | ENTIDAD | cliente | 🔵 CONVENCIÓN | nombre_sp |

---

## `sp_confirmasmscte_6dig`

| Campo | Valor |
|-------|-------|
| **Dominio** | D09 · `bdimnsj` · Mensajería |
| **Archivo fuente** | `bdimnsj_sp_confirmasmscte_6dig.sql` |
| **LOC (1er CREATE)** | 47 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "confirma vía SMS cliente" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `confirma` → `SELECT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=1 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_confirmasmscte_6dig(
  pTelCel                      CHAR(10)
  pNumCte                      CHAR(9)
  pSucursal                    CHAR(5)
) RETURNING CHAR(6) 	 AS sCodSMS
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pTelCel` | `CHAR(10)` | — | — |
| `pNumCte` | `CHAR(9)` | `cte`=cliente | 🔵 CONVENCIÓN |
| `pSucursal` | `CHAR(5)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `iSqlErr` | `INTEGER` | L4 |
| `cCodRet` | `CHAR(6)` | L5 |
| `cSitEsp` | `CHAR(5)` | L6 |
| `iExist` | `INTEGER` | L7 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_bitsmstelsms_bpi` | `bdinteg` | ⚠️ sí | SELECT | L29 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `confirmasms` | ACCION | confirma vía SMS (2FA) | 🔵 CONVENCIÓN | nombre_sp |
| `cte` | ENTIDAD | cliente | 🔵 CONVENCIÓN | nombre_sp |
| `?_6dig` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_6dig` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_confirmasmscte_bpi2`

| Campo | Valor |
|-------|-------|
| **Dominio** | D09 · `bdimnsj` · Mensajería |
| **Archivo fuente** | `bdimnsj_sp_confirmasmscte_bpi2.sql` |
| **LOC (1er CREATE)** | 77 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "confirma vía SMS cliente (Banca Por Internet)" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `confirma` → `SELECT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=1 / 5 términos |

### Historia del SP

| Tipo | Valor |
|------|-------|
| MODIFICACION | Se agrega validacin para que tambin busque la clave enviada al usuario en la tabla: si_bitsmstelsms_bpi |
| FECHA | 19/12/2016 |

### Firma

```sql
CREATE PROCEDURE sp_confirmasmscte_bpi2(
  pTelCel                      CHAR(10)
  pNumCte                      CHAR(9)
) RETURNING CHAR(4) AS sCod4Digitos, -- CÃÂ³digo verificador de 4 dÃÂ­gitos
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pTelCel` | `CHAR(10)` | — | — |
| `pNumCte` | `CHAR(9)` | `cte`=cliente | 🔵 CONVENCIÓN |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `iSqlErr` | `INTEGER` | L14 |
| `cCodRet` | `CHAR(5)` | L15 |
| `cSitEsp` | `CHAR(5)` | L16 |
| `cCodRet2` | `CHAR(6)` | L17 |
| `iExist` | `INTEGER` | L18 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_bitsmstelsms` | `bdinteg` | ⚠️ sí | SELECT | L43 |
| `si_bitsmstelsms_bpi` | `bdinteg` | ⚠️ sí | SELECT | L58 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `confirmasms` | ACCION | confirma vía SMS (2FA) | 🔵 CONVENCIÓN | nombre_sp |
| `cte` | ENTIDAD | cliente | 🔵 CONVENCIÓN | nombre_sp |
| `bpi` | MODIF | Banca Por Internet (canal web BPI) | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `?2` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?2` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_confirmasmscte_mvl`

| Campo | Valor |
|-------|-------|
| **Dominio** | D09 · `bdimnsj` · Mensajería |
| **Archivo fuente** | `bdimnsj_sp_confirmasmscte_mvl.sql` |
| **LOC (1er CREATE)** | 62 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "confirma vía SMS cliente (canal móvil)" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `confirma` → `SELECT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=4 · INFERIDO=0 · SINTÉTICO=0 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_confirmasmscte_mvl(
  pTelCel                      CHAR(10)
  pNumCte                      CHAR(9)
) RETURNING CHAR(6) 	 AS sCodSMS
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pTelCel` | `CHAR(10)` | — | — |
| `pNumCte` | `CHAR(9)` | `cte`=cliente | 🔵 CONVENCIÓN |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `iSqlErr` | `INTEGER` | L4 |
| `cCodRet` | `CHAR(6)` | L5 |
| `cSitEsp` | `CHAR(5)` | L6 |
| `iExist` | `INTEGER` | L7 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_bitsmstelsms` | `bdinteg` | ⚠️ sí | SELECT | L28 |
| `si_bitsmstelsms_bpi` | `bdinteg` | ⚠️ sí | SELECT | L44 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `confirmasms` | ACCION | confirma vía SMS (2FA) | 🔵 CONVENCIÓN | nombre_sp |
| `cte` | ENTIDAD | cliente | 🔵 CONVENCIÓN | nombre_sp |
| `mvl` | MODIF | canal móvil | 🔵 CONVENCIÓN | nombre_sp |

---

## `sp_depura_ctetel_invalido`

| Campo | Valor |
|-------|-------|
| **Dominio** | D09 · `bdimnsj` · Mensajería |
| **Archivo fuente** | `bdimnsj_sp_depura_ctetel_invalido.sql` |
| **LOC (1er CREATE)** | 174 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "depura cliente y teléfono" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 1 llamada(s): `sp_generaarch` |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=4 · INFERIDO=1 · SINTÉTICO=2 / 7 términos |

### Historia del SP

| Tipo | Valor |
|------|-------|
| DESCRIPCION | Se depuran cliente de plataforma, con telefono invalido. |
| FECHA | 17/05/2012 |

### Firma

```sql
CREATE PROCEDURE sp_depura_ctetel_invalido(
) RETURNING CHAR(5) AS CodRetorno,
```

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `viSqlError` | `INTEGER` | L17 |
| `vsCodRetorno` | `CHAR (5)` | L18 |
| `vsMensaje` | `CHAR(200)` | L19 |
| `vdFechaHoy` | `DATE` | L20 |
| `pFecha` | `DATE` | L21 |
| `cMaxregistros` | `CHAR(6)` | L22 |
| `cCompany` | `CHAR (100)` | L23 |
| `valruta` | `INTEGER` | L24 |
| `vsDia` | `CHAR(2)` | L25 |
| `vsMes` | `CHAR(2)` | L26 |
| `vsAnio` | `CHAR(2)` | L27 |
| `vsnumcte` | `CHAR (20)` | L28 |
| `vsStmt1` | `CHAR (500)` | L29 |
| `viRegistros` | `INTEGER` | L30 |
| `vArch` | `INTEGER` | L31 |
| `vsNombreArchivo` | `CHAR(50)` | L32 |
| `visam_error` | `INTEGER` | L33 |
| `isam_error` | `INTEGER` | L34 |
| `vstelcom` | `CHAR(13)` | L35 |
| `vscorreocomp` | `CHAR(100)` | L36 |
| `vsfechacomp` | `CHAR(10)` | L37 |
| `vistatus` | `INTEGER` | L38 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `mnsj_errores` | `bdimnsj` | no | INSERT | L73 |
| `mnsj_procesos` | `bdimnsj` | no | INSERT | L83 |
| `mnsj_param` | `bdimnsj` | no | SELECT | L104 |
| `si_telefonos_actual` | `bdinteg` | ⚠️ sí | SELECT | L122 |
| `mnsj_susc_paso` | `bdimnsj` | no | INSERT | L132 |
| `mnsj_procesos` | `bdimnsj` | no | UPDATE | L167 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_generaarch` | `bdimnsj` | no | L140 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L135 | FÓRMULA | `LET viRegistros = viRegistros +1;` |  |
| L142 | FÓRMULA | `LET vArch = vArch +1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `depura` | ACCION | depura / limpia | 🔵 CONVENCIÓN | nombre_sp |
| `cte` | ENTIDAD | cliente | 🔵 CONVENCIÓN | nombre_sp |
| `tel` | ENTIDAD | teléfono | 🔵 CONVENCIÓN | nombre_sp |
| `?_in` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `valid` | ACCION | valida | 🟡 INFERIDO | nombre_sp |
| `?o` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_in`, `?o` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_depura_mensajes`

| Campo | Valor |
|-------|-------|
| **Dominio** | D09 · `bdimnsj` · Mensajería |
| **Archivo fuente** | `bdimnsj_sp_depura_mensajes.sql` |
| **LOC (1er CREATE)** | 686 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "depura mensajes" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `depura` → `DELETE` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=0 / 3 términos |

### Firma

```sql
CREATE PROCEDURE sp_depura_mensajes(
  pdFecha                      DATE
) RETURNING CHAR(5) as Codigoretorno,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pdFecha` | `DATE` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `viSqlError` | `INTEGER` | L8 |
| `vsCodRetorno` | `CHAR (5)` | L9 |
| `vsMensaje` | `CHAR(200)` | L10 |
| `isam_error` | `INTEGER` | L11 |
| `vsecuencial` | `INTEGER` | L12 |
| `vsCont` | `INTEGER` | L15 |
| `vscount` | `INTEGER` | L16 |
| `visam_error` | `INTEGER` | L17 |
| `vistatus` | `INTEGER` | L18 |
| `iContBorra` | `INTEGER` | L19 |
| `pProceso` | `VARCHAR(10)` | L20 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `mnsj_errores` | `bdimnsj` | no | INSERT | L49 |
| `mnsj_procesos` | `bdimnsj` | no | INSERT | L61 |
| `notif_online_default` | `bdimnsj` | no | SELECT | L76 |
| `notif_online_default` | `bdimnsj` | no | DELETE | L82 |
| `mnsj_procesos` | `bdimnsj` | no | UPDATE | L99 |
| `notif_batch_default` | `bdimnsj` | no | SELECT | L132 |
| `notif_batch_default` | `bdimnsj` | no | DELETE | L138 |
| `notif_online_icard` | `bdimnsj` | no | SELECT | L189 |
| `notif_online_icard` | `bdimnsj` | no | DELETE | L195 |
| `notif_online_oper_bancarias` | `bdimnsj` | no | SELECT | L246 |
| `notif_online_oper_bancarias` | `bdimnsj` | no | DELETE | L252 |
| `notif_online_remesas` | `bdimnsj` | no | SELECT | L302 |
| `notif_online_remesas` | `bdimnsj` | no | DELETE | L308 |
| `notif_online_spei` | `bdimnsj` | no | SELECT | L360 |
| `notif_online_spei` | `bdimnsj` | no | DELETE | L366 |
| `notif_online_tokens` | `bdimnsj` | no | SELECT | L417 |
| `notif_online_tokens` | `bdimnsj` | no | DELETE | L423 |
| `notif_online_fon_insuf` | `bdimnsj` | no | SELECT | L474 |
| `notif_online_fon_insuf` | `bdimnsj` | no | DELETE | L480 |
| `notif_batch_masivos` | `bdimnsj` | no | SELECT | L532 |
| `notif_batch_masivos` | `bdimnsj` | no | DELETE | L538 |
| `notif_online_97000_98000` | `bdimnsj` | no | SELECT | L590 |
| `notif_online_97000_98000` | `bdimnsj` | no | DELETE | L596 |
| `notif_online_monitoreo` | `bdimnsj` | no | SELECT | L648 |
| `notif_online_monitoreo` | `bdimnsj` | no | DELETE | L654 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L80 | FÓRMULA | `LET vsCont = vsCont + 1;` |  |
| L83 | FÓRMULA | `LET iContBorra = iContBorra + 1;` |  |
| L136 | FÓRMULA | `LET vsCont = vsCont + 1;` |  |
| L139 | FÓRMULA | `LET iContBorra = iContBorra + 1;` |  |
| L193 | FÓRMULA | `LET vsCont = vsCont + 1;` |  |
| L196 | FÓRMULA | `LET iContBorra = iContBorra + 1;` |  |
| L250 | FÓRMULA | `LET vsCont = vsCont + 1;` |  |
| L253 | FÓRMULA | `LET iContBorra = iContBorra + 1;` |  |
| L306 | FÓRMULA | `LET vsCont = vsCont + 1;` |  |
| L309 | FÓRMULA | `LET iContBorra = iContBorra + 1;` |  |
| L364 | FÓRMULA | `LET vsCont = vsCont + 1;` |  |
| L367 | FÓRMULA | `LET iContBorra = iContBorra + 1;` |  |
| L421 | FÓRMULA | `LET vsCont = vsCont + 1;` |  |
| L424 | FÓRMULA | `LET iContBorra = iContBorra + 1;` |  |
| L478 | FÓRMULA | `LET vsCont = vsCont + 1;` |  |
| L481 | FÓRMULA | `LET iContBorra = iContBorra + 1;` |  |
| L536 | FÓRMULA | `LET vsCont = vsCont + 1;` |  |
| L539 | FÓRMULA | `LET iContBorra = iContBorra + 1;` |  |
| L594 | FÓRMULA | `LET vsCont = vsCont + 1;` |  |
| L597 | FÓRMULA | `LET iContBorra = iContBorra + 1;` |  |
| L652 | FÓRMULA | `LET vsCont = vsCont + 1;` |  |
| L655 | FÓRMULA | `LET iContBorra = iContBorra + 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `depura` | ACCION | depura / limpia | 🔵 CONVENCIÓN | nombre_sp |
| `mensajes` | ENTIDAD | mensajes | 🔵 CONVENCIÓN | nombre_sp |

---

## `sp_depura_mnsjr_bitacora_sms`

| Campo | Valor |
|-------|-------|
| **Dominio** | D09 · `bdimnsj` · Mensajería |
| **Archivo fuente** | `bdimnsj_sp_depura_mnsjr_bitacora_sms.sql` |
| **LOC (1er CREATE)** | 140 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "depura bitácora y SMS" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `depura` → `DELETE` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=3 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=0 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_depura_mnsjr_bitacora_sms(
) RETURNING CHAR(5) as Codigoretorno,
```

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `viSqlError` | `INTEGER` | L8 |
| `vsCodRetorno` | `CHAR (5)` | L9 |
| `vsMensaje` | `CHAR(200)` | L10 |
| `isam_error` | `INTEGER` | L11 |
| `vdfechasolicitud` | `DATETIME YEAR TO SECOND` | L14 |
| `vsproceso` | `VARCHAR(30)` | L15 |
| `vstexto_msj` | `VARCHAR(30)` | L16 |
| `vsusuario` | `VARCHAR(10)` | L17 |
| `vspass` | `VARCHAR(10)` | L18 |
| `vscel` | `VARCHAR(10)` | L19 |
| `vscompania` | `VARCHAR(10)` | L20 |
| `vsresp_solic` | `VARCHAR(250)` | L21 |
| `vsnumcte` | `VARCHAR(20)` | L22 |
| `vssucursal` | `VARCHAR(10)` | L23 |
| `vsparam1` | `VARCHAR(20)` | L24 |
| `vsparam2` | `VARCHAR(20)` | L25 |
| `vsparam3` | `VARCHAR(20)` | L26 |
| `vsCont` | `INTEGER` | L29 |
| `vscount` | `INTEGER` | L30 |
| `visam_error` | `INTEGER` | L31 |
| `vistatus` | `INTEGER` | L32 |
| `iContBorra` | `INTEGER` | L33 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `mnsj_errores` | `bdimnsj` | no | INSERT | L75 |
| `mnsjr_bitacora_sms` | `bdimnsj` | no | SELECT | L99 |
| `mnsjr_bitacora_sms_hist` | `bdimnsj` | no | INSERT | L102 |
| `mnsjr_bitacora_sms` | `bdimnsj` | no | DELETE | L110 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L108 | FÓRMULA | `LET vsCont = vsCont + 1;` |  |
| L111 | FÓRMULA | `LET iContBorra = iContBorra + 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `depura` | ACCION | depura / limpia | 🔵 CONVENCIÓN | nombre_sp |
| `mnsjr` | PREFIJO | mensajería registrada / tabla de transacciones de mensajería | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `bitacora` | ENTIDAD | bitácora | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `sms` | ENTIDAD | SMS | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |

---

## `sp_errormensaje`

| Campo | Valor |
|-------|-------|
| **Dominio** | D09 · `bdimnsj` · Mensajería |
| **Archivo fuente** | `bdimnsj_sp_errormensaje.sql` |
| **LOC (1er CREATE)** | 37 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "error y mensaje" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 1 tabla(s) con operaciones: UPDATE |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=0 / 3 términos |

### Historia del SP

| Tipo | Valor |
|------|-------|
| AUTOR | Ricardo Abel Gomez Velazquez |
| PROYECTO | Replica Errores Latinia. |
| ACTIVIDAD | Se actualiza el estatus de los mensajes que no fueron enviados por la plataforma marcandolo con un estatus 2. |
| FECHA | 16/07/2014 |

### Firma

```sql
CREATE PROCEDURE sp_errormensaje(
  Isecuencial                  INT
) RETURNING CHAR(5) as cCodRet
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `Isecuencial` | `INT` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(5)` | L6 |
| `vsqlerr` | `INTEGER` | L7 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `mnsjr_trx_online` | `bdimnsj` | no | UPDATE | L32 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L10 | CÓDIGO_RETORNO | `LET cCodRet = '00001';` |  |
| L26 | VALIDACIÓN_NULL | `IF (Isecuencial IS NULL OR Isecuencial = 0)` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `error` | ENTIDAD | error | 🔵 CONVENCIÓN | nombre_sp |
| `mensaje` | ENTIDAD | mensaje | 🔵 CONVENCIÓN | nombre_sp |

---

## `sp_espacios_blancos2`

| Campo | Valor |
|-------|-------|
| **Dominio** | D09 · `bdimnsj` · Mensajería |
| **Archivo fuente** | `bdimnsj_sp_espacios_blancos2.sql` |
| **LOC (1er CREATE)** | 43 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "(especial)" `[partial]` |
| **Propósito verificado** | ❓ NO_VERIFICABLE — Propósito inferido; sin evidencia DML para verificar |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=1 / 3 términos |

### Firma

```sql
CREATE PROCEDURE sp_espacios_blancos2(
  pcadena                      CHAR(50)
) RETURNING CHAR(30) as posicion
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pcadena` | `CHAR(50)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `isqlerr` | `INTEGER` | L4 |
| `ciclo` | `INTEGER` | L5 |
| `l` | `INTEGER` | L6 |
| `vp` | `INTEGER` | L7 |
| `cont` | `INTEGER` | L8 |
| `aux` | `INTEGER` | L9 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L34 | FÓRMULA | `let cont =vp + 1;` |  |
| L35 | FÓRMULA | `let aux = aux + 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `esp` | MODIF | especial | 🔵 CONVENCIÓN | nombre_sp |
| `?acios_blancos2` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?acios_blancos2` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_genera_reporte_sms`

| Campo | Valor |
|-------|-------|
| **Dominio** | D09 · `bdimnsj` · Mensajería |
| **Archivo fuente** | `bdimnsj_sp_genera_reporte_sms.sql` |
| **LOC (1er CREATE)** | 248 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "genera reporte y SMS" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `genera` → `INSERT` encontrado en el cuerpo · `genera` → `SELECT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=0 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_genera_reporte_sms(
) RETURNING VARCHAR(40) AS cMensaje,
```

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cSucursal` | `VARCHAR(10)` | L6 |
| `cCiudad` | `VARCHAR(60,1)` | L7 |
| `cNomCiudad` | `VARCHAR(60,1)` | L8 |
| `cEstado` | `VARCHAR(30)` | L9 |
| `cNomEstado` | `VARCHAR(30)` | L10 |
| `cSaldo` | `VARCHAR(10)` | L11 |
| `cPago` | `VARCHAR(10)` | L12 |
| `cInversion` | `VARCHAR(10)` | L13 |
| `cSolicitud` | `VARCHAR(10)` | L14 |
| `cCelular` | `VARCHAR(10)` | L15 |
| `cPrestamoMonto` | `INTEGER` | L17 |
| `cPrestamoDisponible` | `INTEGER` | L18 |
| `cPrestamoConsulta` | `INTEGER` | L19 |
| `cFlexibleMonto` | `INTEGER` | L20 |
| `cFlexibleDisponible` | `INTEGER` | L21 |
| `cFlexibleConsulta` | `INTEGER` | L22 |
| `cIncremento` | `INTEGER` | L23 |
| `cAnticipo` | `INTEGER` | L24 |
| `cPagosFijosFolio` | `INTEGER` | L25 |
| `cPagosFijosSaldo` | `INTEGER` | L26 |
| `cDiferir` | `VARCHAR(10)` | L28 |
| `cRobo` | `VARCHAR(10)` | L29 |
| `cExtravio` | `VARCHAR(10)` | L30 |
| `cConfirma` | `VARCHAR(10)` | L31 |
| `cAclaracion` | `VARCHAR(10)` | L32 |
| *…19 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `mnsjr_reporte_sms` | `bdimnsj` | no | INSERT | L140 |
| `mnsjr_bitacora_sms` | `bdimnsj` | no | SELECT | L148 |
| `statistics` | `bdimnsj` | no | UPDATE | L151 |
| `temp_mnsjr_bit_sms` | `bdimnsj` | no | SELECT | L189 |
| `si_sucursales` | `bdinteg` | ⚠️ sí | SELECT | L197 |
| `si_ptf` | `bdinteg` | ⚠️ sí | SELECT | L201 |
| `si_ciudades` | `bdinteg` | ⚠️ sí | SELECT | L205 |
| `si_estados` | `bdinteg` | ⚠️ sí | SELECT | L209 |
| `mnsjr_reporte_sms` | `bdimnsj` | no | SELECT | L231 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L105 | FÓRMULA | `LET vDia_Anterior =  EXTEND(TODAY-1);` |  |
| L127 | FÓRMULA | `LET vMesAnterior = vFecha_Actual - 1 UNITS MONTH;` |  |
| L212 | FÓRMULA | `LET cPrestamoMonto = cPrestamoMonto - cPrestamoDisponible - cPrestamoConsulta;` | 🔴 MONEY/aritmética financiera |
| L213 | FÓRMULA | `LET cFlexibleMonto = cFlexibleMonto - cFlexibleDisponible - cFlexibleConsulta;` | 🔴 MONEY/aritmética financiera |
| L215 | FÓRMULA | `LET cPagosFijosFolio = cPagosFijosFolio - cPagosFijosSaldo;` |  |
| L217 | FÓRMULA | `LET cTotal = cSaldo + cPago + cInversion + cCelular + cSolicitud + cPrestamoMonto + cPrestamoDisponi` | 🔴 MONEY/aritmética financiera |
| L218 | FÓRMULA | `LET cTotal = cTotal + cFlexibleMonto + cFlexibleDisponible + cFlexibleConsulta + cIncremento + cAnti` | 🔴 MONEY/aritmética financiera |
| L227 | FÓRMULA | `LET iCont=iCont+1;` |  |
| L240 | CÓDIGO_RETORNO | `LET cCodRet = '00000';` |  |
| L244 | CÓDIGO_RETORNO | `LET cCodRet = '00001';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `genera` | ACCION | genera / produce | 🔵 CONVENCIÓN | nombre_sp |
| `reporte` | ENTIDAD | reporte | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `sms` | ENTIDAD | SMS | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |

---

## `sp_generaarch`

| Campo | Valor |
|-------|-------|
| **Dominio** | D09 · `bdimnsj` · Mensajería |
| **Archivo fuente** | `bdimnsj_sp_generaarch.sql` |
| **LOC (1er CREATE)** | 70 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "genera archivo" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `genera` → `SELECT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=2 · INFERIDO=1 · SINTÉTICO=0 / 3 términos |

### Firma

```sql
CREATE PROCEDURE sp_generaarch(
  pNombrearch                  char(50)
) RETURNING CHAR(5) AS CodRetorno
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pNombrearch` | `char(50)` | `arch`=archivo | 🟡 INFERIDO |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `viSqlError` | `INTEGER` | L7 |
| `vsCodRetorno` | `CHAR (5)` | L8 |
| `cSQL1` | `CHAR(500)` | L9 |
| `cSQL` | `CHAR(500)` | L10 |
| `vsRutaArchRep` | `CHAR(150)` | L11 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `mnsj_param` | `bdimnsj` | no | SELECT | L42 |
| `mnsj_susc_paso` | `bdimnsj` | no | SELECT | L47 |
| `statistics` | `bdimnsj` | no | UPDATE | L64 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L36 | VALIDACIÓN_NULL | `IF (pNombrearch is null) or (pNombrearch = '') THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `genera` | ACCION | genera / produce | 🔵 CONVENCIÓN | nombre_sp |
| `arch` | ENTIDAD | archivo | 🟡 INFERIDO | nombre_sp |

---

## `sp_generar_reporte_innovattia`

| Campo | Valor |
|-------|-------|
| **Dominio** | D09 · `bdimnsj` · Mensajería |
| **Archivo fuente** | `bdimnsj_sp_generar_reporte_innovattia.sql` |
| **LOC (1er CREATE)** | 108 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "genera reporte" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `genera` → `INSERT` encontrado en el cuerpo · `genera` → `SELECT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=2 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_generar_reporte_innovattia(
) RETURNING VARCHAR(6) AS cCodRet,
```

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `VARCHAR(6)` | L9 |
| `cMensaje` | `VARCHAR(40)` | L10 |
| `cRegistros` | `VARCHAR(40)` | L11 |
| `vsNombreArchivo` | `VARCHAR(50)` | L12 |
| `cSQL` | `VARCHAR(250)` | L13 |
| `cSQL1` | `LVARCHAR(500)` | L14 |
| `iCont` | `INTEGER` | L15 |
| `iSqlErr` | `INTEGER` | L16 |
| `vTelefono` | `VARCHAR(13)` | L17 |
| `dFecha_hora` | `DATETIME YEAR TO SECOND` | L18 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `mnsjr_trx_online` | `bdimnsj` | no | SELECT | L62 |
| `tmp_sms_innovattia` | `bdimnsj` | no | INSERT | L70 |
| `tmp_sms_innovattia` | `bdimnsj` | no | SELECT | L91 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L68 | FÓRMULA | `LET iCont=iCont+1;` |  |
| L84 | FÓRMULA | `LET iCont=iCont+1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `genera` | ACCION | genera / produce | 🔵 CONVENCIÓN | nombre_sp |
| `?r_` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `reporte` | ENTIDAD | reporte | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?_innovattia` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?r_`, `?_innovattia` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_monitor_ckpt`

| Campo | Valor |
|-------|-------|
| **Dominio** | D09 · `bdimnsj` · Mensajería |
| **Archivo fuente** | `bdimnsj_sp_monitor_ckpt.sql` |
| **LOC (1er CREATE)** | 66 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "monitor" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 1 llamada(s): `sp_registra_evento_prod` |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=1 / 3 términos |

### Firma

```sql
CREATE PROCEDURE sp_monitor_ckpt(
) RETURNING CHAR(5),
```

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `sql_err` | `int` | L6 |
| `vintvl` | `int` | L7 |
| `vclock_time` | `char(20)` | L8 |
| `vcp_time` | `char(10)` | L9 |
| `venviado` | `char(1)` | L10 |
| `existe` | `int` | L11 |
| `mensaje` | `varchar(50)` | L12 |
| `cod_ret` | `char(5)` | L13 |
| `cod_ret2` | `char(5)` | L14 |
| `vtchkp` | `varchar(150)` | L15 |
| `vcaller` | `varchar(20)` | L16 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `syscheckpoint` | `sysmaster` | ⚠️ sí | SELECT | L38 |
| `tblckpt` | `bdimnsj` | no | SELECT | L51 |
| `tblckpt` | `bdimnsj` | no | INSERT | L56 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_registra_evento_prod` | `bdimnsj` | no | L58 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `monitor` | ENTIDAD | monitor | 🔵 CONVENCIÓN | nombre_sp |
| `?_ckpt` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_ckpt` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_monitoreo_sms`

| Campo | Valor |
|-------|-------|
| **Dominio** | D09 · `bdimnsj` · Mensajería |
| **Archivo fuente** | `bdimnsj_sp_monitoreo_sms.sql` |
| **LOC (1er CREATE)** | 85 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "monitor y SMS" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 1 llamada(s): `sp_registra_evento` |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=1 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_monitoreo_sms(
) RETURNING CHAR(5) AS CodRetorno,
```

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vsCodRetorno` | `CHAR (5)` | L6 |
| `vsMensaje` | `CHAR(200)` | L7 |
| `sql_err` | `SMALLINT` | L8 |
| `isam_err` | `SMALLINT` | L9 |
| `error_info` | `CHAR(40)` | L10 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_registra_evento` | `bdimnsj` | no | L36 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `monitor` | ENTIDAD | monitor | 🔵 CONVENCIÓN | nombre_sp |
| `?eo_` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `sms` | ENTIDAD | SMS | 🔵 CONVENCIÓN | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?eo_` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_mover_mensajes`

| Campo | Valor |
|-------|-------|
| **Dominio** | D09 · `bdimnsj` · Mensajería |
| **Archivo fuente** | `bdimnsj_sp_mover_mensajes.sql` |
| **LOC (1er CREATE)** | 253 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "movimiento y mensajes" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 9 tabla(s) con operaciones: UPDATE, SELECT, DELETE, INSERT |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=1 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_mover_mensajes(
  pProceso                     VARCHAR(10)
  pdFecha                      DATE
) RETURNING CHAR(5) as Codigoretorno,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pProceso` | `VARCHAR(10)` | — | — |
| `pdFecha` | `DATE` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `viSqlError` | `INTEGER` | L8 |
| `vsCodRetorno` | `CHAR (5)` | L9 |
| `vsMensaje` | `CHAR(200)` | L10 |
| `isam_error` | `INTEGER` | L11 |
| `vsecuencial` | `INTEGER` | L12 |
| `vstipomensaje` | `CHAR(1)` | L13 |
| `vsidmensaje` | `CHAR(10)` | L14 |
| `vidplantilla` | `VARCHAR(12)` | L15 |
| `vtransactionid` | `CHAR(24)` | L16 |
| `vscliente` | `CHAR(20)` | L17 |
| `vscuenta` | `CHAR(20)` | L18 |
| `vstarjeta` | `CHAR(16)` | L19 |
| `vsestatus` | `INTEGER` | L20 |
| `vdfechahora` | `DATETIME YEAR TO SECOND` | L21 |
| `vdfechahorarecu` | `DATETIME YEAR TO SECOND` | L22 |
| `vsString1` | `CHAR(30)` | L23 |
| `vsString2` | `CHAR(30)` | L24 |
| `vsString3` | `CHAR(30)` | L25 |
| `vsString4` | `CHAR(30)` | L26 |
| `vsString5` | `CHAR(150)` | L27 |
| `vsString6` | `CHAR(100)` | L28 |
| `vsString7` | `CHAR(60)` | L29 |
| `vsString8` | `CHAR(60)` | L30 |
| `vsString9` | `CHAR(15)` | L31 |
| `vsString10` | `CHAR(100)` | L32 |
| *…17 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `mnsj_errores` | `bdimnsj` | no | INSERT | L110 |
| `mnsj_procesos` | `bdimnsj` | no | INSERT | L119 |
| `mnsjr_trx_online` | `bdimnsj` | no | SELECT | L144 |
| `mnsjr_trx_online_his` | `bdimnsj` | no | INSERT | L147 |
| `mnsjr_trx_online` | `bdimnsj` | no | DELETE | L157 |
| `mnsjr_trx_batch` | `bdimnsj` | no | SELECT | L203 |
| `mnsjr_trx_batch_his` | `bdimnsj` | no | INSERT | L206 |
| `mnsjr_trx_batch` | `bdimnsj` | no | DELETE | L216 |
| `mnsj_procesos` | `bdimnsj` | no | UPDATE | L245 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L155 | FÓRMULA | `LET vsCont = vsCont + 1;` |  |
| L158 | FÓRMULA | `LET iContBorra = iContBorra + 1;` |  |
| L214 | FÓRMULA | `LET vsCont2 = vsCont2 + 1;` |  |
| L217 | FÓRMULA | `LET iContBorra = iContBorra + 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `mov` | ENTIDAD | movimiento | 🔵 CONVENCIÓN | nombre_sp |
| `?er_` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `mensajes` | ENTIDAD | mensajes | 🔵 CONVENCIÓN | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?er_` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_movregistroshist`

| Campo | Valor |
|-------|-------|
| **Dominio** | D09 · `bdimnsj` · Mensajería |
| **Archivo fuente** | `bdimnsj_sp_movregistroshist.sql` |
| **LOC (1er CREATE)** | 102 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "movimiento y registros (histórico/historial)" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 2 llamada(s): `sp_mover_mensajes`, `sp_depura_mensajes` |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=4 · INFERIDO=0 · SINTÉTICO=0 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_movregistroshist(
) RETURNING CHAR(5) as Codigoretorno,
```

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `viSqlError` | `INTEGER` | L8 |
| `vsCodRetorno` | `CHAR(5)` | L9 |
| `vsCodRetOnline` | `CHAR(5)` | L10 |
| `vsCodRetBatch` | `CHAR(5)` | L11 |
| `vsCodRetNotif` | `CHAR(5)` | L12 |
| `vsMensajeOnline` | `CHAR(50)` | L13 |
| `vsMensajeBatch` | `CHAR(50)` | L14 |
| `vsMensajeNotif` | `CHAR(50)` | L15 |
| `vsMensaje` | `CHAR(200)` | L16 |
| `isam_error` | `INTEGER` | L17 |
| `vsCont` | `INTEGER` | L18 |
| `vsCont2` | `INTEGER` | L19 |
| `vscountonline` | `INTEGER` | L20 |
| `vscountbatch` | `INTEGER` | L21 |
| `visam_error` | `INTEGER` | L22 |
| `vistatus` | `INTEGER` | L23 |
| `vistatusO` | `INTEGER` | L24 |
| `vistatusB` | `INTEGER` | L25 |
| `iContBorra` | `INTEGER` | L26 |
| `vdFecha` | `DATE` | L27 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `mnsj_errores` | `bdimnsj` | no | INSERT | L63 |
| `mnsj_procesos` | `bdimnsj` | no | INSERT | L73 |
| `mnsj_procesos` | `bdimnsj` | no | UPDATE | L84 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_mover_mensajes` | `bdimnsj` | no | L77 |
| `sp_depura_mensajes` | `bdimnsj` | no | L81 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `mov` | ENTIDAD | movimiento | 🔵 CONVENCIÓN | nombre_sp |
| `registros` | ENTIDAD | registros | 🔵 CONVENCIÓN | nombre_sp |
| `hist` | MODIF | histórico/historial | 🔵 CONVENCIÓN | nombre_sp |

---

## `sp_notifica_resultados`

| Campo | Valor |
|-------|-------|
| **Dominio** | D09 · `bdimnsj` · Mensajería |
| **Archivo fuente** | `bdimnsj_sp_notifica_resultados.sql` |
| **LOC (1er CREATE)** | 191 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "notifica resultado" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `notifica` → `INSERT` encontrado en el cuerpo · `notifica` → `EXECUTE` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=1 / 4 términos |

### Historia del SP

| Tipo | Valor |
|------|-------|
| FECHA | 27/12/2021 |

### Firma

```sql
CREATE PROCEDURE sp_notifica_resultados(
  p_ccodproc                   CHAR(3)
  p_cstatusproc                CHAR(5)
) RETURNING CHAR(5) AS codigo_retorno
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_ccodproc` | `CHAR(3)` | — | — |
| `p_cstatusproc` | `CHAR(5)` | `sp`=stored procedure | 🔵 CONVENCIÓN |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `sql_err` | `INTEGER` | L19 |
| `isam_err` | `INTEGER` | L20 |
| `error_info` | `CHAR(40)` | L21 |
| `cod_ret` | `CHAR(5)` | L22 |
| `mensaje_ret` | `VARCHAR(255)` | L23 |
| `v_cempresa` | `CHAR(3)` | L27 |
| `v_cdesc_area` | `VARCHAR(20)` | L28 |
| `v_cnombre_proc` | `VARCHAR(60)` | L29 |
| `v_ctipoMsj` | `CHAR(1)` | L30 |
| `v_cidMsj` | `VARCHAR(10)` | L31 |
| `v_cidPlantilla` | `VARCHAR(12)` | L32 |
| `v_cnumclt` | `VARCHAR(20)` | L33 |
| `v_cnumcta` | `VARCHAR(20)` | L34 |
| `v_cnumTarjeta` | `VARCHAR(16)` | L35 |
| `v_ctipoproc` | `CHAR(1)` | L36 |
| `v_cstr1` | `CHAR(30)` | L37 |
| `v_cstr2` | `VARCHAR(30)` | L38 |
| `v_cstr3` | `VARCHAR(30)` | L39 |
| `v_cstr4` | `VARCHAR(30)` | L40 |
| `v_cstr5` | `VARCHAR(150)` | L41 |
| `v_cstr6` | `VARCHAR(100)` | L42 |
| `v_cstr7` | `VARCHAR(60)` | L43 |
| `v_cstr8` | `VARCHAR(60)` | L44 |
| `v_cstr9` | `VARCHAR(15)` | L45 |
| `v_cstr10` | `VARCHAR(100)` | L46 |
| *…14 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sd_fechas` | `bdicred` | ⚠️ sí | SELECT | L133 |
| `mnsj_notifica_resultados` | `bdimnsj` | no | SELECT | L151 |
| `mnsj_notifica_resultados_hist` | `bdimnsj` | no | SELECT | L169 |
| `mnsj_notifica_resultados_hist` | `bdimnsj` | no | INSERT | L173 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_registra_evento` | `bdimnsj` | no | L157 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L135 | FÓRMULA | `LET v_cfechahoy = v_cdia \|\| '/' \|\| v_cmes \|\| '/' \|\| v_cyear;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `notifica` | ACCION | notifica | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `resultado` | ENTIDAD | resultado | 🔵 CONVENCIÓN | nombre_sp |
| `?s` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?s` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_recupera_cuentatelefono`

| Campo | Valor |
|-------|-------|
| **Dominio** | D09 · `bdimnsj` · Mensajería |
| **Archivo fuente** | `bdimnsj_sp_recupera_cuentatelefono.sql` |
| **LOC (1er CREATE)** | 39 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "recupera estado cuenta y teléfono" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `recupera` → `SELECT` encontrado en el cuerpo · `recupera` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=0 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_recupera_cuentatelefono(
  pcel                         CHAR(10)
) RETURNING CHAR(5) AS codret, CHAR(160) AS estatus
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pcel` | `CHAR(10)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vcodret` | `CHAR(5)` | L6 |
| `vTermCta` | `CHAR(5)` | L7 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sc_cuenta_telefono` | `bdicheq` | ⚠️ sí | SELECT | L29 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L9 | CÓDIGO_RETORNO | `LET vcodret    		= '00000';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `recupera` | ACCION | recupera estado | 🔵 CONVENCIÓN | nombre_sp |
| `cuenta` | ENTIDAD | cuenta | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `telefono` | ENTIDAD | teléfono | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |

---

## `sp_recupera_estatussolic`

| Campo | Valor |
|-------|-------|
| **Dominio** | D09 · `bdimnsj` · Mensajería |
| **Archivo fuente** | `bdimnsj_sp_recupera_estatussolic.sql` |
| **LOC (1er CREATE)** | 153 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "recupera estado estatus de solicitud" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `recupera` → `SELECT` encontrado en el cuerpo · `recupera` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=0 / 3 términos |

### Firma

```sql
CREATE PROCEDURE sp_recupera_estatussolic(
  pcel                         CHAR(10)
) RETURNING CHAR(5) AS codret, CHAR(160) AS estatus
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pcel` | `CHAR(10)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vcodret` | `CHAR(5)` | L6 |
| `vTermSolic` | `CHAR(4)` | L7 |
| `vSolicitud` | `CHAR(20)` | L8 |
| `vStatusSolic` | `CHAR(50)` | L9 |
| `vNumProducto` | `CHAR(4)` | L10 |
| `vNombProducto` | `CHAR(80)` | L11 |
| `vcadena` | `CHAR(500)` | L12 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_telefonos_actual` | `bdinteg` | ⚠️ sí | SELECT | L44 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L14 | CÓDIGO_RETORNO | `LET vcodret    		= '00000';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `recupera` | ACCION | recupera estado | 🔵 CONVENCIÓN | nombre_sp |
| `estatussolic` | ENTIDAD | estatus de solicitud | 🔵 CONVENCIÓN | nombre_sp |

---

## `sp_recupera_pago`

| Campo | Valor |
|-------|-------|
| **Dominio** | D09 · `bdimnsj` · Mensajería |
| **Archivo fuente** | `bdimnsj_sp_recupera_pago.sql` |
| **LOC (1er CREATE)** | 116 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "recupera estado pago" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `recupera` → `SELECT` encontrado en el cuerpo · `recupera` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=0 / 3 términos |

### Firma

```sql
CREATE PROCEDURE sp_recupera_pago(
  pcel                         CHAR(10)
) RETURNING CHAR(5) as codret, CHAR(160) as saldo
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pcel` | `CHAR(10)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vcodret` | `CHAR(5)` | L4 |
| `vtermcdto` | `CHAR(4)` | L5 |
| `vCredito` | `CHAR(20)` | L7 |
| `cEmpresa` | `CHAR(3)` | L8 |
| `vcadena` | `CHAR(500)` | L9 |
| `cCodRetSp` | `CHAR (5)` | L11 |
| `dPagoMinimo` | `DECIMAL(18,2)` | L12 |
| `dSdoActCap` | `DECIMAL(18,2)` | L13 |
| `dPagoNoIntereses` | `DECIMAL(14,2)` | L14 |
| `vSaldoGenNull` | `INTEGER` | L16 |
| `vSaldoGenOK` | `INTEGER` | L17 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_telefonos_actual` | `bdinteg` | ⚠️ sí | SELECT | L51 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L19 | CÓDIGO_RETORNO | `LET vcodret    = '00000';` |  |
| L91 | FÓRMULA | `LET vSaldoGenNull = vSaldoGenNull + 1;` |  |
| L98 | FÓRMULA | `LET vSaldoGenOK = vSaldoGenOK + 1;` |  |
| L99 | FÓRMULA | `LET vcadena = TRIM(vcadena) \|\| " ***" \|\| vtermcdto \|\| " SALDO: " \|\| TO_CHAR(dSdoActCap, "$<<` | 🔴 MONEY/aritmética financiera |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `recupera` | ACCION | recupera estado | 🔵 CONVENCIÓN | nombre_sp |
| `pago` | ENTIDAD | pago | ✅ CÓDIGO | nombre_sp, texto_cuerpo |

---

## `sp_recupera_saldo`

| Campo | Valor |
|-------|-------|
| **Dominio** | D09 · `bdimnsj` · Mensajería |
| **Archivo fuente** | `bdimnsj_sp_recupera_saldo.sql` |
| **LOC (1er CREATE)** | 85 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "recupera estado saldo" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `recupera` → `SELECT` encontrado en el cuerpo · `recupera` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=0 / 3 términos |

### Firma

```sql
CREATE PROCEDURE sp_recupera_saldo(
  pcel                         CHAR(10)
) RETURNING CHAR(5) as codret, CHAR(160) as saldo_disp
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pcel` | `CHAR(10)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vcodret` | `CHAR(5)` | L4 |
| `vtermcta` | `CHAR(4)` | L5 |
| `vcant` | `INTEGER` | L6 |
| `iSqlErr` | `INT` | L8 |
| `iIsamErr` | `INT` | L9 |
| `cInfoErr` | `CHAR` | L10 |
| `vcuenta` | `CHAR(20)` | L12 |
| `vsdodisp` | `DECIMAL(18,2)` | L13 |
| `vcadena` | `CHAR(500)` | L14 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_telefonos_actual` | `bdinteg` | ⚠️ sí | SELECT | L42 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L77 | FÓRMULA | `LET vcadena = TRIM(vcadena) \|\| " ***" \|\| vtermcta \|\| ": " \|\| TO_CHAR(vsdodisp, "$<<<,<<<,<<<` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `recupera` | ACCION | recupera estado | 🔵 CONVENCIÓN | nombre_sp |
| `saldo` | ENTIDAD | saldo | ✅ CÓDIGO | nombre_sp, texto_cuerpo |

---

## `sp_recupera_saldo_inv`

| Campo | Valor |
|-------|-------|
| **Dominio** | D09 · `bdimnsj` · Mensajería |
| **Archivo fuente** | `bdimnsj_sp_recupera_saldo_inv.sql` |
| **LOC (1er CREATE)** | 211 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "recupera estado saldo" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `recupera` → `SELECT` encontrado en el cuerpo · `recupera` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=1 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_recupera_saldo_inv(
  pcel                         CHAR(10)
) RETURNING CHAR(5) as codret, CHAR(160) as saldo_inv
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pcel` | `CHAR(10)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vcodret` | `CHAR(5)` | L4 |
| `vtermctainver` | `CHAR(4)` | L5 |
| `vcadenaI` | `CHAR(500)` | L7 |
| `vcadenaP` | `CHAR(500)` | L8 |
| `vcuenta` | `CHAR(20)` | L9 |
| `vtermcta` | `CHAR(4)` | L10 |
| `vsdodisp` | `DECIMAL(18,2)` | L11 |
| `vdivisor` | `CHAR(3)` | L12 |
| `cEmpresa` | `CHAR(3)` | L14 |
| `cCodRet` | `CHAR(5)` | L15 |
| `cCliente` | `CHAR(20)` | L16 |
| `cSecuencia` | `CHAR(6)` | L17 |
| `cNombreCliente` | `CHAR(104)` | L18 |
| `cTpPersona` | `CHAR(2)` | L19 |
| `cDescTpPersona` | `CHAR(20)` | L20 |
| `cCalle` | `CHAR(35)` | L21 |
| `cColonia` | `CHAR(35)` | L22 |
| `cDelegacion` | `CHAR(35)` | L23 |
| `cPoblacion` | `CHAR(20)` | L24 |
| `cCodPostal` | `CHAR(5)` | L25 |
| `cTelefono` | `CHAR(14)` | L26 |
| `cInstrumento` | `CHAR(4)` | L27 |
| `cDescInstrumento` | `CHAR(40)` | L28 |
| `cMoneda` | `CHAR(12)` | L29 |
| `cDescMoneda` | `CHAR(30)` | L30 |
| *…24 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_telefonos_actual` | `bdinteg` | ⚠️ sí | SELECT | L134 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `cons_sdo` | `bdinvers` | ⚠️ sí | L196 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L56 | CÓDIGO_RETORNO | `LET vcodret    = '00000';` |  |
| L185 | FÓRMULA | `LET vcadenaI = TRIM(vcadenaI) \|\| " ***" \|\| vtermcta \|\| ": " \|\| TO_CHAR(vsdodisp, "$<<<,<<<,<` |  |
| L203 | FÓRMULA | `LET vcadenaI = TRIM(vcadenaI) \|\| " ***" \|\| vtermctainver \|\| " SALDO: " \|\| TO_CHAR(mCapital, ` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `recupera` | ACCION | recupera estado | 🔵 CONVENCIÓN | nombre_sp |
| `saldo` | ENTIDAD | saldo | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?_inv` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_inv` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_registra_correotel`

| Campo | Valor |
|-------|-------|
| **Dominio** | D09 · `bdimnsj` · Mensajería |
| **Archivo fuente** | `bdimnsj_sp_registra_correotel.sql` |
| **LOC (1er CREATE)** | 76 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "registra correo electrónico y teléfono" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 1 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=0 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_registra_correotel(
) RETURNING char(5) as vsCodret
```

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vsnumcte` | `CHAR(20)` | L6 |
| `vstelefono` | `CHAR(13)` | L7 |
| `vscorreo` | `CHAR(100)` | L8 |
| `vsCodret` | `CHAR(5)` | L9 |
| `vsCodret1` | `CHAR(3)` | L10 |
| `vsCodret2` | `CHAR(3)` | L11 |
| `viSqlError` | `INTEGER` | L12 |
| `isam_error` | `INTEGER` | L13 |
| `visam_error` | `integer` | L14 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_ctepf` | `bdinteg` | ⚠️ sí | SELECT | L47 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `registra` | ACCION | registra | 🔵 CONVENCIÓN | nombre_sp |
| `correo` | ENTIDAD | correo electrónico | 🔵 CONVENCIÓN | nombre_sp |
| `tel` | ENTIDAD | teléfono | ✅ CÓDIGO | nombre_sp, texto_cuerpo |

---

## `sp_registra_evento`

| Campo | Valor |
|-------|-------|
| **Dominio** | D09 · `bdimnsj` · Mensajería |
| **Archivo fuente** | `bdimnsj_sp_registra_evento.sql` |
| **LOC (1er CREATE)** | 446 |
| **Callgraph** | ✅ fan_in=1404 / fan_out=0 |
| **Principales callers** | `bloqueo_cta`, `reversion`, `sp_bitacora`, `sp_consultareportepagoscre`, `sp_generararchivo_rst` |
| **Propósito inferido** | "registra evento/notificación" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `registra` → `INSERT` encontrado en el cuerpo · `notifica` → `INSERT` encontrado en el cuerpo · `notifica` → `EXECUTE` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=0 / 3 términos |

### Historia del SP

| Tipo | Valor |
|------|-------|
| AUTOR | Angel Rene de la Llave |
| PROYECTO | Latinia registro de eventos. |
| ACTIVIDAD | Se registran los eventos para el env???????o de mnsjr y emails a un cliente |
| FECHA | 26/03/2012 |
| MODIFICACION | Incluir campos string adicionales. JGP-19/09/2012 |
| FECHA | 19/09/2012 |
| MODIFICACION | Incluir registro de eventos pendientes de confirmar "PENDIENTE", hasta que sean |
| FECHA | 09/11/2012 |
| AUTOR | Manuel Osuna V. |
| MODIFICACION | Se agrega parametro pIdPlantilla,para que explotar la funcionalidad de que una alerta |
| FECHA | 15/10/2013 |
| AUTOR | Cristo Lugo |
| MODIFICACION | Se agrega validaci???n pIdMsj,para que evitar enviar la misma alerta durante el dia. |
| FECHA | 28/08/2014 |

### Firma

```sql
CREATE PROCEDURE sp_registra_evento(
  pTipoMsj                     char(1)
  pIdMsj                       char(10)
  pIdPlantilla                 char(12)
  pNumclt                      char(20)
  pNumcta                      char(20)
  pNumTarjeta                  char(16)
  pTipoproc                    char(1)
  pStr1                        char(30)
  pStr2                        char(30)
  pStr3                        char(30)
  pStr4                        char (30)
  pStr5                        char(150)
  pStr6                        char(100)
  pStr7                        char(60)
  pStr8                        char(60)
  pStr9                        char(15)
  pStr10                       char(100)
  pcorreo_alterno              char(100)
  pcelular_alterno             char(10)
  pImporte1                    money (16,2)
  pImporte2                    money (16,2)
  pImporte3                    money (16,2)
  pImporte4                    money (16,2)
  pImporte5                    money (16,2)
  pfecha1                      datetime year to fraction(3)
  pfecha2                      datetime year to fraction(3)
) RETURNING CHAR(5) as cCodRet
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pTipoMsj` | `char(1)` | — | — |
| `pIdMsj` | `char(10)` | — | — |
| `pIdPlantilla` | `char(12)` | — | — |
| `pNumclt` | `char(20)` | — | — |
| `pNumcta` | `char(20)` | — | — |
| `pNumTarjeta` | `char(16)` | — | — |
| `pTipoproc` | `char(1)` | — | — |
| `pStr1` | `char(30)` | — | — |
| `pStr2` | `char(30)` | — | — |
| `pStr3` | `char(30)` | — | — |
| `pStr4` | `char (30)` | — | — |
| `pStr5` | `char(150)` | — | — |
| `pStr6` | `char(100)` | — | — |
| `pStr7` | `char(60)` | — | — |
| `pStr8` | `char(60)` | — | — |
| `pStr9` | `char(15)` | — | — |
| `pStr10` | `char(100)` | — | — |
| `pcorreo_alterno` | `char(100)` | — | — |
| `pcelular_alterno` | `char(10)` | — | — |
| `pImporte1` | `money (16,2)` | — | — |
| `pImporte2` | `money (16,2)` | — | — |
| `pImporte3` | `money (16,2)` | — | — |
| `pImporte4` | `money (16,2)` | — | — |
| `pImporte5` | `money (16,2)` | — | — |
| `pfecha1` | `datetime year to fraction(3)` | — | — |
| `pfecha2` | `datetime year to fraction(3)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(5)` | L36 |
| `iexiste` | `INTEGER` | L37 |
| `iexiste2` | `INTEGER` | L38 |
| `iexiste3` | `INTEGER` | L39 |
| `iexistec` | `INTEGER` | L40 |
| `vnumcte` | `CHAR(20)` | L41 |
| `vsqlerr` | `INTEGER` | L42 |
| `vtransaction_id` | `CHAR(12)` | L43 |
| `cDia` | `CHAR (2)` | L44 |
| `cAnio` | `CHAR (4)` | L45 |
| `cMes` | `CHAR(2)` | L46 |
| `cMes1` | `CHAR (10)` | L47 |
| `cFechaH` | `CHAR (10)` | L48 |
| `bandera` | `CHAR(100)` | L49 |
| `cStr1` | `CHAR(30)` | L50 |
| `cStr5` | `CHAR(150)` | L51 |
| `iprioridad` | `INTEGER` | L52 |
| `vTablaNotif` | `varchar (50)` | L55 |
| `vInsStmt` | `lvarchar (2000)` | L56 |
| `vEstatus` | `nvarchar(20)` | L57 |
| `pfecha1Aux` | `varchar(100)` | L58 |
| `pfecha2Aux` | `varchar(100)` | L59 |
| `pNumTarjetaAux` | `varchar(18)` | L60 |
| `pNumctaAux` | `varchar(22)` | L61 |
| `vPermiteInsertar` | `varchar(1)` | L62 |
| *…2 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `mnsj_param` | `bdimnsj` | no | SELECT | L103 |
| `si_fechas` | `bdinteg` | ⚠️ sí | SELECT | L140 |
| `bdimnsj` | `bdimnsj` | no | INSERT | L209 |
| `si_cliente` | `bdinteg` | ⚠️ sí | SELECT | L237 |
| `sc_maechq` | `bdicheq` | ⚠️ sí | SELECT | L245 |
| `sd_maecred` | `bdicred` | ⚠️ sí | SELECT | L247 |
| `tarjeta` | `intercard` | ⚠️ sí | SELECT | L250 |
| `mnsjr_cat_prioridades` | `bdimnsj` | no | SELECT | L287 |
| `notif_cfg` | `bdimnsj` | no | SELECT | L297 |
| `mnsjr_cat_suscripcion` | `bdimnsj` | no | SELECT | L332 |
| `mnsjr_suscripcion_ctes` | `bdimnsj` | no | SELECT | L334 |
| `mnsjr_trx_online` | `bdimnsj` | no | SELECT | L343 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L69 | CÓDIGO_RETORNO | `LET cCodRet = '00000';` |  |
| L110 | VALIDACIÓN_NULL | `IF (pTipoMsj IS NULL OR pTipoMsj = '') OR` |  |
| L114 | CÓDIGO_RETORNO | `LET cCodRet = '00005';` |  |
| L120 | CÓDIGO_RETORNO | `LET cCodRet = '00020';` |  |
| L126 | CÓDIGO_RETORNO | `LET cCodRet = '00103';` |  |
| L130 | VALIDACIÓN_NULL | `IF (pNumclt IS NULL OR pNumclt = '') AND (pNumcta IS NULL OR pNumcta ='') AND (pNumTarjeta IS NULL O` |  |
| L131 | CÓDIGO_RETORNO | `LET cCodRet = '00110';` |  |
| L156 | FÓRMULA | `LET pStr5 = trim(cDia)\|\|'-'\|\|trim(cMes1)\|\|'-'\|\|trim(cAnio);` |  |
| L238 | VALIDACIÓN_NULL | `IF (iexistec = 0 or iexistec is null) then` |  |
| L239 | CÓDIGO_RETORNO | `LET cCodRet = '00100';` |  |
| L246 | VALIDACIÓN_NULL | `IF (iexiste = 0 or iexiste is null) THEN` |  |
| L248 | VALIDACIÓN_NULL | `IF (iexiste2 = 0 or iexiste2 is null) THEN` |  |
| L251 | VALIDACIÓN_NULL | `IF (iexiste3 = 0 or iexiste3 is null) then` |  |
| L252 | CÓDIGO_RETORNO | `LET cCodRet = '00115';` |  |
| L256 | CÓDIGO_RETORNO | `LET cCodRet = '00100';` |  |
| L263 | VALIDACIÓN_NULL | `IF (iexiste3 = 0 or iexiste3 is null) then` |  |
| L264 | CÓDIGO_RETORNO | `LET cCodRet = '00115';` |  |
| L268 | VALIDACIÓN_NULL | `IF (iexiste = 0 or iexiste is null) and (iexiste2 = 0 or iexiste2 is null) and (iexiste3 = 0 or iexi` |  |
| L269 | CÓDIGO_RETORNO | `LET cCodRet = '00112';` |  |
| L274 | VALIDACIÓN_NULL | `if vnumcte = '' or vnumcte is null  then` |  |
| L289 | VALIDACIÓN_NULL | `IF (iprioridad IS NULL OR iprioridad ='') THEN` |  |
| L302 | VALIDACIÓN_NULL | `IF (vTablaNotif IS NULL OR vTablaNotif = '') THEN` |  |
| L321 | CÓDIGO_RETORNO | `LET cCodRet = '00201';` |  |
| L347 | VALIDACIÓN_NULL | `IF (vtransaction_id IS NULL) THEN` |  |
| L353 | VALIDACIÓN_NULL | `IF (pImporte1 IS NULL or pImporte1 = '') THEN` |  |
| L356 | VALIDACIÓN_NULL | `IF (pImporte2 IS NULL or pImporte2 = '') THEN` |  |
| L359 | VALIDACIÓN_NULL | `IF (pImporte3 IS NULL or pImporte3 = '') THEN` |  |
| L362 | VALIDACIÓN_NULL | `IF (pImporte4 IS NULL or pImporte4 = '') THEN` |  |
| L365 | VALIDACIÓN_NULL | `IF (pImporte5 IS NULL or pImporte5 = '') THEN` |  |
| L368 | VALIDACIÓN_NULL | `IF (pfecha1 IS NULL or pfecha1 = '') THEN` |  |
| | *…17 más…* | | |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `registra` | ACCION | registra | 🔵 CONVENCIÓN | nombre_sp |
| `evento` | ENTIDAD | evento/notificación | 🔵 CONVENCIÓN | nombre_sp |

---

## `sp_registra_evento2018`

| Campo | Valor |
|-------|-------|
| **Dominio** | D09 · `bdimnsj` · Mensajería |
| **Archivo fuente** | `bdimnsj_sp_registra_evento2018.sql` |
| **LOC (1er CREATE)** | 222 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "registra evento/notificación" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `registra` → `INSERT` encontrado en el cuerpo · `notifica` → `INSERT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=1 / 4 términos |

### Historia del SP

| Tipo | Valor |
|------|-------|
| AUTOR | Angel Rene de la Llave |
| PROYECTO | Latinia registro de eventos. |
| ACTIVIDAD | Se registran los eventos para el env??? de mnsjr y emails a un cliente |
| FECHA | 26/03/2012 |
| MODIFICACION | Incluir campos string adicionales. JGP-19/09/2012 |
| FECHA | 19/09/2012 |
| MODIFICACION | Incluir registro de eventos pendientes de confirmar "PENDIENTE", hasta que sean |
| FECHA | 09/11/2012 |
| AUTOR | Manuel Osuna V. |
| MODIFICACION | Se agrega parametro pIdPlantilla,para que explotar la funcionalidad de que una alerta |
| FECHA | 15/10/2013 |
| AUTOR | Cristo Lugo |
| MODIFICACION | Se agrega validaci? pIdMsj,para que evitar enviar la misma alerta durante el dia. |
| FECHA | 28/08/2014 |

### Firma

```sql
CREATE PROCEDURE sp_registra_evento2018(
  pTipoMsj                     char(1)
  pIdMsj                       char(10)
  pIdPlantilla                 char(12)
  pNumclt                      char(20)
  pNumcta                      char(20)
  pNumTarjeta                  char(16)
  pTipoproc                    char(1)
  pStr1                        char(30)
  pStr2                        char(30)
  pStr3                        char(30)
  pStr4                        char (30)
  pStr5                        char(150)
  pStr6                        char(100)
  pStr7                        char(60)
  pStr8                        char(60)
  pStr9                        char(15)
  pStr10                       char(100)
  pcorreo_alterno              char(100)
  pcelular_alterno             char(10)
  pImporte1                    money (16,2)
  pImporte2                    money (16,2)
  pImporte3                    money (16,2)
  pImporte4                    money (16,2)
  pImporte5                    money (16,2)
  pfecha1                      datetime year to fraction(3)
  pfecha2                      datetime year to fraction(3)
) RETURNING CHAR(5) as cCodRet
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pTipoMsj` | `char(1)` | — | — |
| `pIdMsj` | `char(10)` | — | — |
| `pIdPlantilla` | `char(12)` | — | — |
| `pNumclt` | `char(20)` | — | — |
| `pNumcta` | `char(20)` | — | — |
| `pNumTarjeta` | `char(16)` | — | — |
| `pTipoproc` | `char(1)` | — | — |
| `pStr1` | `char(30)` | — | — |
| `pStr2` | `char(30)` | — | — |
| `pStr3` | `char(30)` | — | — |
| `pStr4` | `char (30)` | — | — |
| `pStr5` | `char(150)` | — | — |
| `pStr6` | `char(100)` | — | — |
| `pStr7` | `char(60)` | — | — |
| `pStr8` | `char(60)` | — | — |
| `pStr9` | `char(15)` | — | — |
| `pStr10` | `char(100)` | — | — |
| `pcorreo_alterno` | `char(100)` | — | — |
| `pcelular_alterno` | `char(10)` | — | — |
| `pImporte1` | `money (16,2)` | — | — |
| `pImporte2` | `money (16,2)` | — | — |
| `pImporte3` | `money (16,2)` | — | — |
| `pImporte4` | `money (16,2)` | — | — |
| `pImporte5` | `money (16,2)` | — | — |
| `pfecha1` | `datetime year to fraction(3)` | — | — |
| `pfecha2` | `datetime year to fraction(3)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(5)` | L36 |
| `iexiste` | `INTEGER` | L37 |
| `iexiste2` | `INTEGER` | L38 |
| `iexiste3` | `INTEGER` | L39 |
| `iexistec` | `INTEGER` | L40 |
| `vnumcte` | `CHAR(20)` | L41 |
| `vsqlerr` | `INTEGER` | L42 |
| `vtransaction_id` | `CHAR(10)` | L43 |
| `cDia` | `CHAR (2)` | L44 |
| `cAnio` | `CHAR (4)` | L45 |
| `cMes` | `CHAR(2)` | L46 |
| `cMes1` | `CHAR (10)` | L47 |
| `cFechaH` | `CHAR (10)` | L48 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_fechas` | `bdinteg` | ⚠️ sí | SELECT | L109 |
| `si_cliente` | `bdinteg` | ⚠️ sí | SELECT | L134 |
| `sc_maechq` | `bdicheq` | ⚠️ sí | SELECT | L142 |
| `sd_maecred` | `bdicred` | ⚠️ sí | SELECT | L144 |
| `tarjeta` | `intercard` | ⚠️ sí | SELECT | L147 |
| `mnsjr_trx_batch` | `bdimnsj` | no | SELECT | L190 |
| `mnsjr_trx_batch` | `bdimnsj` | no | INSERT | L191 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L52 | CÓDIGO_RETORNO | `LET cCodRet = '00000';` |  |
| L79 | VALIDACIÓN_NULL | `IF (pTipoMsj IS NULL OR pTipoMsj = '') OR` |  |
| L83 | CÓDIGO_RETORNO | `LET cCodRet = '00005';` |  |
| L89 | CÓDIGO_RETORNO | `LET cCodRet = '00020';` |  |
| L95 | CÓDIGO_RETORNO | `LET cCodRet = '00103';` |  |
| L99 | VALIDACIÓN_NULL | `IF (pNumclt IS NULL OR pNumclt = '') AND (pNumcta IS NULL OR pNumcta ='') AND (pNumTarjeta IS NULL O` |  |
| L100 | CÓDIGO_RETORNO | `LET cCodRet = '00110';` |  |
| L125 | FÓRMULA | `LET pStr5 = trim(cDia)\|\|'-'\|\|trim(cMes1)\|\|'-'\|\|trim(cAnio);` |  |
| L135 | VALIDACIÓN_NULL | `IF (iexistec = 0 or iexistec is null) then` |  |
| L136 | CÓDIGO_RETORNO | `LET cCodRet = '00100';` |  |
| L143 | VALIDACIÓN_NULL | `IF (iexiste = 0 or iexiste is null) THEN` |  |
| L145 | VALIDACIÓN_NULL | `IF (iexiste2 = 0 or iexiste2 is null) THEN` |  |
| L148 | VALIDACIÓN_NULL | `IF (iexiste3 = 0 or iexiste3 is null) then` |  |
| L149 | CÓDIGO_RETORNO | `LET cCodRet = '00115';` |  |
| L153 | CÓDIGO_RETORNO | `LET cCodRet = '00100';` |  |
| L160 | VALIDACIÓN_NULL | `IF (iexiste3 = 0 or iexiste3 is null) then` |  |
| L161 | CÓDIGO_RETORNO | `LET cCodRet = '00115';` |  |
| L165 | VALIDACIÓN_NULL | `IF (iexiste = 0 or iexiste is null) and (iexiste2 = 0 or iexiste2 is null) and (iexiste3 = 0 or iexi` |  |
| L166 | CÓDIGO_RETORNO | `LET cCodRet = '00112';` |  |
| L171 | VALIDACIÓN_NULL | `if vnumcte = '' or vnumcte is null  then` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `registra` | ACCION | registra | 🔵 CONVENCIÓN | nombre_sp |
| `evento` | ENTIDAD | evento/notificación | 🔵 CONVENCIÓN | nombre_sp |
| `?2018` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?2018` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_registra_evento_bpi`

| Campo | Valor |
|-------|-------|
| **Dominio** | D09 · `bdimnsj` · Mensajería |
| **Archivo fuente** | `bdimnsj_sp_registra_evento_bpi.sql` |
| **LOC (1er CREATE)** | 60 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "registra evento/notificación (Banca Por Internet)" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 1 llamada(s): `sp_registra_evento` |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=0 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_registra_evento_bpi(
  pTipoMsj                     char(1)
  pIdMsj                       char(10)
  pNumclt                      char(20)
  pNumcta                      char(20)
  pNumTarjeta                  char(16)
  pTipoproc                    char(1)
  pStr1                        char(30)
  pStr2                        char(30)
  pStr3                        char(30)
  pStr4                        char (30)
  pStr5                        char(150)
  pStr6                        char(100)
  pStr7                        char(60)
  pStr8                        char(60)
  pStr9                        char(15)
  pStr10                       char(100)
  pcorreo_alterno              char(100)
  pcelular_alterno             char(10)
  pImporte1                    money (16,2)
  pImporte2                    money (16,2)
  pImporte3                    money (16,2)
  pImporte4                    money (16,2)
  pImporte5                    money (16,2)
  pfecha1                      datetime year to fraction(3)
  pfecha2                      datetime year to fraction(3)
) RETURNING CHAR(5) as cCodRet
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pTipoMsj` | `char(1)` | — | — |
| `pIdMsj` | `char(10)` | — | — |
| `pNumclt` | `char(20)` | — | — |
| `pNumcta` | `char(20)` | — | — |
| `pNumTarjeta` | `char(16)` | — | — |
| `pTipoproc` | `char(1)` | — | — |
| `pStr1` | `char(30)` | — | — |
| `pStr2` | `char(30)` | — | — |
| `pStr3` | `char(30)` | — | — |
| `pStr4` | `char (30)` | — | — |
| `pStr5` | `char(150)` | — | — |
| `pStr6` | `char(100)` | — | — |
| `pStr7` | `char(60)` | — | — |
| `pStr8` | `char(60)` | — | — |
| `pStr9` | `char(15)` | — | — |
| `pStr10` | `char(100)` | — | — |
| `pcorreo_alterno` | `char(100)` | — | — |
| `pcelular_alterno` | `char(10)` | — | — |
| `pImporte1` | `money (16,2)` | — | — |
| `pImporte2` | `money (16,2)` | — | — |
| `pImporte3` | `money (16,2)` | — | — |
| `pImporte4` | `money (16,2)` | — | — |
| `pImporte5` | `money (16,2)` | — | — |
| `pfecha1` | `datetime year to fraction(3)` | — | — |
| `pfecha2` | `datetime year to fraction(3)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(5)` | L15 |
| `vsqlerr` | `INTEGER` | L16 |
| `pIdPlantilla` | `CHAR(12)` | L17 |
| `vIdMsj` | `CHAR(10)` | L18 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_registra_evento` | `bdimnsj` | no | L49 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L21 | CÓDIGO_RETORNO | `LET cCodRet = '00000';` |  |
| L46 | CÓDIGO_RETORNO | `LET cCodRet = '00001';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `registra` | ACCION | registra | 🔵 CONVENCIÓN | nombre_sp |
| `evento` | ENTIDAD | evento/notificación | 🔵 CONVENCIÓN | nombre_sp |
| `bpi` | MODIF | Banca Por Internet (canal web BPI) | ✅ CÓDIGO | nombre_sp, texto_cuerpo |

---

## `sp_registra_evento_leo`

| Campo | Valor |
|-------|-------|
| **Dominio** | D09 · `bdimnsj` · Mensajería |
| **Archivo fuente** | `bdimnsj_sp_registra_evento_leo.sql` |
| **LOC (1er CREATE)** | 362 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "registra evento/notificación" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `registra` → `INSERT` encontrado en el cuerpo · `notifica` → `INSERT` encontrado en el cuerpo · `notifica` → `EXECUTE` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=1 / 4 términos |

### Historia del SP

| Tipo | Valor |
|------|-------|
| AUTOR | Angel Rene de la Llave |
| PROYECTO | Latinia registro de eventos. |
| ACTIVIDAD | Se registran los eventos para el env??? de mnsjr y emails a un cliente |
| FECHA | 26/03/2012 |
| MODIFICACION | Incluir campos string adicionales. JGP-19/09/2012 |
| FECHA | 19/09/2012 |
| MODIFICACION | Incluir registro de eventos pendientes de confirmar "PENDIENTE", hasta que sean |
| FECHA | 09/11/2012 |
| AUTOR | Manuel Osuna V. |
| MODIFICACION | Se agrega parametro pIdPlantilla,para que explotar la funcionalidad de que una alerta |
| FECHA | 15/10/2013 |
| AUTOR | Cristo Lugo |
| MODIFICACION | Se agrega validaci? pIdMsj,para que evitar enviar la misma alerta durante el dia. |
| FECHA | 28/08/2014 |

### Firma

```sql
CREATE PROCEDURE sp_registra_evento_leo(
  pTipoMsj                     char(1)
  pIdMsj                       char(10)
  pIdPlantilla                 char(12)
  pNumclt                      char(20)
  pNumcta                      char(20)
  pNumTarjeta                  char(16)
  pTipoproc                    char(1)
  pStr1                        char(30)
  pStr2                        char(30)
  pStr3                        char(30)
  pStr4                        char (30)
  pStr5                        char(150)
  pStr6                        char(100)
  pStr7                        char(60)
  pStr8                        char(60)
  pStr9                        char(15)
  pStr10                       char(100)
  pcorreo_alterno              char(100)
  pcelular_alterno             char(10)
  pImporte1                    money (16,2)
  pImporte2                    money (16,2)
  pImporte3                    money (16,2)
  pImporte4                    money (16,2)
  pImporte5                    money (16,2)
  pfecha1                      datetime year to fraction(3)
  pfecha2                      datetime year to fraction(3)
) RETURNING CHAR(5) as cCodRet
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pTipoMsj` | `char(1)` | — | — |
| `pIdMsj` | `char(10)` | — | — |
| `pIdPlantilla` | `char(12)` | — | — |
| `pNumclt` | `char(20)` | — | — |
| `pNumcta` | `char(20)` | — | — |
| `pNumTarjeta` | `char(16)` | — | — |
| `pTipoproc` | `char(1)` | — | — |
| `pStr1` | `char(30)` | — | — |
| `pStr2` | `char(30)` | — | — |
| `pStr3` | `char(30)` | — | — |
| `pStr4` | `char (30)` | — | — |
| `pStr5` | `char(150)` | — | — |
| `pStr6` | `char(100)` | — | — |
| `pStr7` | `char(60)` | — | — |
| `pStr8` | `char(60)` | — | — |
| `pStr9` | `char(15)` | — | — |
| `pStr10` | `char(100)` | — | — |
| `pcorreo_alterno` | `char(100)` | — | — |
| `pcelular_alterno` | `char(10)` | — | — |
| `pImporte1` | `money (16,2)` | — | — |
| `pImporte2` | `money (16,2)` | — | — |
| `pImporte3` | `money (16,2)` | — | — |
| `pImporte4` | `money (16,2)` | — | — |
| `pImporte5` | `money (16,2)` | — | — |
| `pfecha1` | `datetime year to fraction(3)` | — | — |
| `pfecha2` | `datetime year to fraction(3)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(5)` | L36 |
| `iexiste` | `INTEGER` | L37 |
| `iexiste2` | `INTEGER` | L38 |
| `iexiste3` | `INTEGER` | L39 |
| `iexistec` | `INTEGER` | L40 |
| `vnumcte` | `CHAR(20)` | L41 |
| `vsqlerr` | `INTEGER` | L42 |
| `vtransaction_id` | `CHAR(12)` | L43 |
| `cDia` | `CHAR (2)` | L44 |
| `cAnio` | `CHAR (4)` | L45 |
| `cMes` | `CHAR(2)` | L46 |
| `cMes1` | `CHAR (10)` | L47 |
| `cFechaH` | `CHAR (10)` | L48 |
| `bandera` | `CHAR(100)` | L49 |
| `vTablaNotif` | `varchar (50)` | L52 |
| `vInsStmt` | `lvarchar (2000)` | L53 |
| `vEstatus` | `nvarchar(20)` | L54 |
| `pfecha1Aux` | `varchar(100)` | L55 |
| `pfecha2Aux` | `varchar(100)` | L56 |
| `pNumTarjetaAux` | `varchar(18)` | L57 |
| `pNumctaAux` | `varchar(22)` | L58 |
| `vPermiteInsertar` | `varchar(1)` | L59 |
| `cCodAlerta` | `VARCHAR(3)` | L61 |
| `iActInac` | `INTEGER` | L62 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `mnsj_param` | `bdimnsj` | no | SELECT | L97 |
| `si_fechas` | `bdinteg` | ⚠️ sí | SELECT | L134 |
| `si_cliente` | `bdinteg` | ⚠️ sí | SELECT | L165 |
| `sc_maechq` | `bdicheq` | ⚠️ sí | SELECT | L173 |
| `sd_maecred` | `bdicred` | ⚠️ sí | SELECT | L175 |
| `tarjeta` | `intercard` | ⚠️ sí | SELECT | L178 |
| `notif_cfg` | `bdimnsj` | no | SELECT | L216 |
| `mnsjr_cat_suscripcion` | `bdimnsj` | no | SELECT | L251 |
| `mnsjr_suscripcion_ctes` | `bdimnsj` | no | SELECT | L253 |
| `mnsjr_trx_online` | `bdimnsj` | no | SELECT | L262 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L66 | CÓDIGO_RETORNO | `LET cCodRet = '00000';` |  |
| L104 | VALIDACIÓN_NULL | `IF (pTipoMsj IS NULL OR pTipoMsj = '') OR` |  |
| L108 | CÓDIGO_RETORNO | `LET cCodRet = '00005';` |  |
| L114 | CÓDIGO_RETORNO | `LET cCodRet = '00020';` |  |
| L120 | CÓDIGO_RETORNO | `LET cCodRet = '00103';` |  |
| L124 | VALIDACIÓN_NULL | `IF (pNumclt IS NULL OR pNumclt = '') AND (pNumcta IS NULL OR pNumcta ='') AND (pNumTarjeta IS NULL O` |  |
| L125 | CÓDIGO_RETORNO | `LET cCodRet = '00110';` |  |
| L150 | FÓRMULA | `LET pStr5 = trim(cDia)\|\|'-'\|\|trim(cMes1)\|\|'-'\|\|trim(cAnio);` |  |
| L166 | VALIDACIÓN_NULL | `IF (iexistec = 0 or iexistec is null) then` |  |
| L167 | CÓDIGO_RETORNO | `LET cCodRet = '00100';` |  |
| L174 | VALIDACIÓN_NULL | `IF (iexiste = 0 or iexiste is null) THEN` |  |
| L176 | VALIDACIÓN_NULL | `IF (iexiste2 = 0 or iexiste2 is null) THEN` |  |
| L179 | VALIDACIÓN_NULL | `IF (iexiste3 = 0 or iexiste3 is null) then` |  |
| L180 | CÓDIGO_RETORNO | `LET cCodRet = '00115';` |  |
| L184 | CÓDIGO_RETORNO | `LET cCodRet = '00100';` |  |
| L191 | VALIDACIÓN_NULL | `IF (iexiste3 = 0 or iexiste3 is null) then` |  |
| L192 | CÓDIGO_RETORNO | `LET cCodRet = '00115';` |  |
| L196 | VALIDACIÓN_NULL | `IF (iexiste = 0 or iexiste is null) and (iexiste2 = 0 or iexiste2 is null) and (iexiste3 = 0 or iexi` |  |
| L197 | CÓDIGO_RETORNO | `LET cCodRet = '00112';` |  |
| L202 | VALIDACIÓN_NULL | `if vnumcte = '' or vnumcte is null  then` |  |
| L221 | VALIDACIÓN_NULL | `IF (vTablaNotif IS NULL OR vTablaNotif = '') THEN` |  |
| L240 | CÓDIGO_RETORNO | `LET cCodRet = '00201';` |  |
| L266 | VALIDACIÓN_NULL | `IF (vtransaction_id IS NULL) THEN` |  |
| L272 | VALIDACIÓN_NULL | `IF (pImporte1 IS NULL or pImporte1 = '') THEN` |  |
| L275 | VALIDACIÓN_NULL | `IF (pImporte2 IS NULL or pImporte2 = '') THEN` |  |
| L278 | VALIDACIÓN_NULL | `IF (pImporte3 IS NULL or pImporte3 = '') THEN` |  |
| L281 | VALIDACIÓN_NULL | `IF (pImporte4 IS NULL or pImporte4 = '') THEN` |  |
| L284 | VALIDACIÓN_NULL | `IF (pImporte5 IS NULL or pImporte5 = '') THEN` |  |
| L287 | VALIDACIÓN_NULL | `IF (pfecha1 IS NULL or pfecha1 = '') THEN` |  |
| L292 | VALIDACIÓN_NULL | `IF (pfecha2 IS NULL or pfecha2 = '') THEN` |  |
| | *…16 más…* | | |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `registra` | ACCION | registra | 🔵 CONVENCIÓN | nombre_sp |
| `evento` | ENTIDAD | evento/notificación | 🔵 CONVENCIÓN | nombre_sp |
| `?_leo` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_leo` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_registra_evento_prod`

| Campo | Valor |
|-------|-------|
| **Dominio** | D09 · `bdimnsj` · Mensajería |
| **Archivo fuente** | `bdimnsj_sp_registra_evento_prod.sql` |
| **LOC (1er CREATE)** | 103 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "registra evento/notificación y producto" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `notifica` → `EXECUTE` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=3 · INFERIDO=1 · SINTÉTICO=0 / 4 términos |

### Historia del SP

| Tipo | Valor |
|------|-------|
| AUTOR | Manuel Osuna Valencia |
| PROYECTO | Latinia registro de eventos. |
| ACTIVIDAD | Se registran los eventos Productivos para el envío de mensajes a grupo de usuarios |

### Firma

```sql
CREATE PROCEDURE sp_registra_evento_prod(
  pTipoMsj                     char(1)
  pIdMsj                       char(10)
  pIdPlantilla                 char(12)
  pNumclt                      char(20)
  pNumcta                      char(20)
  pNumTarjeta                  char(16)
  pTipoproc                    char(1)
  pStr1                        char(30)
  pStr2                        char(30)
  pStr3                        char(30)
  pStr4                        char (30)
  pStr5                        char(150)
  pStr6                        char(100)
  pStr7                        char(60)
  pStr8                        char(60)
  pStr9                        char(15)
  pStr10                       char(100)
  pcorreo_alterno              char(100)
  pcelular_alterno             char(10)
  pImporte1                    money (16,2)
  pImporte2                    money (16,2)
  pImporte3                    money (16,2)
  pImporte4                    money (16,2)
  pImporte5                    money (16,2)
  pfecha1                      datetime year to fraction(3)
  pfecha2                      datetime year to fraction(3)
) RETURNING CHAR(5) as cCodRet
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pTipoMsj` | `char(1)` | — | — |
| `pIdMsj` | `char(10)` | — | — |
| `pIdPlantilla` | `char(12)` | — | — |
| `pNumclt` | `char(20)` | — | — |
| `pNumcta` | `char(20)` | — | — |
| `pNumTarjeta` | `char(16)` | — | — |
| `pTipoproc` | `char(1)` | — | — |
| `pStr1` | `char(30)` | — | — |
| `pStr2` | `char(30)` | — | — |
| `pStr3` | `char(30)` | — | — |
| `pStr4` | `char (30)` | — | — |
| `pStr5` | `char(150)` | — | — |
| `pStr6` | `char(100)` | — | — |
| `pStr7` | `char(60)` | — | — |
| `pStr8` | `char(60)` | — | — |
| `pStr9` | `char(15)` | — | — |
| `pStr10` | `char(100)` | — | — |
| `pcorreo_alterno` | `char(100)` | — | — |
| `pcelular_alterno` | `char(10)` | — | — |
| `pImporte1` | `money (16,2)` | — | — |
| `pImporte2` | `money (16,2)` | — | — |
| `pImporte3` | `money (16,2)` | — | — |
| `pImporte4` | `money (16,2)` | — | — |
| `pImporte5` | `money (16,2)` | — | — |
| `pfecha1` | `datetime year to fraction(3)` | — | — |
| `pfecha2` | `datetime year to fraction(3)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(5)` | L22 |
| `vsqlerr` | `INTEGER` | L23 |
| `vfecha1` | `datetime year to fraction(3)` | L24 |
| `sUsuario` | `CHAR(20)` | L25 |
| `sCelular` | `CHAR(10)` | L26 |
| `sCorreo` | `CHAR(100)` | L27 |
| `sUserGen` | `CHAR(10)` | L28 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `mnsjr_trx_online` | `bdimnsj` | no | SELECT | L76 |
| `mnsj_grupos_usuarios` | `bdimnsj` | no | SELECT | L88 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_registra_evento` | `bdimnsj` | no | L91 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L31 | CÓDIGO_RETORNO | `LET cCodRet = '00000';` |  |
| L45 | VALIDACIÓN_NULL | `IF (pTipoMsj IS NULL OR pTipoMsj = '') OR` |  |
| L49 | CÓDIGO_RETORNO | `LET cCodRet = '00005';` |  |
| L55 | CÓDIGO_RETORNO | `LET cCodRet = '00020';` |  |
| L61 | CÓDIGO_RETORNO | `LET cCodRet = '00103';` |  |
| L65 | VALIDACIÓN_NULL | `IF (pNumclt IS NULL OR pNumclt = '') AND (pNumcta IS NULL OR pNumcta ='') AND (pNumTarjeta IS NULL O` |  |
| L66 | CÓDIGO_RETORNO | `LET cCodRet = '00110';` |  |
| L82 | CÓDIGO_RETORNO | `LET cCodRet = '00005';` |  |
| L95 | CÓDIGO_RETORNO | `LET cCodRet = '00007';			END IF;` |  |
| L98 | CÓDIGO_RETORNO | `LET cCodRet = '00006';	END IF;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `registra` | ACCION | registra | 🔵 CONVENCIÓN | nombre_sp |
| `evento` | ENTIDAD | evento/notificación | 🔵 CONVENCIÓN | nombre_sp |
| `prod` | ENTIDAD | producto | 🟡 INFERIDO | nombre_sp |

---

## `sp_registra_evento_pru3`

| Campo | Valor |
|-------|-------|
| **Dominio** | D09 · `bdimnsj` · Mensajería |
| **Archivo fuente** | `bdimnsj_sp_registra_evento_pru3.sql` |
| **LOC (1er CREATE)** | 446 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "registra evento/notificación" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `registra` → `INSERT` encontrado en el cuerpo · `notifica` → `INSERT` encontrado en el cuerpo · `notifica` → `EXECUTE` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=1 / 4 términos |

### Historia del SP

| Tipo | Valor |
|------|-------|
| AUTOR | Angel Rene de la Llave |
| PROYECTO | Latinia registro de eventos. |
| ACTIVIDAD | Se registran los eventos para el env???????o de mnsjr y emails a un cliente |
| FECHA | 26/03/2012 |
| MODIFICACION | Incluir campos string adicionales. JGP-19/09/2012 |
| FECHA | 19/09/2012 |
| MODIFICACION | Incluir registro de eventos pendientes de confirmar "PENDIENTE", hasta que sean |
| FECHA | 09/11/2012 |
| AUTOR | Manuel Osuna V. |
| MODIFICACION | Se agrega parametro pIdPlantilla,para que explotar la funcionalidad de que una alerta |
| FECHA | 15/10/2013 |
| AUTOR | Cristo Lugo |
| MODIFICACION | Se agrega validaci???n pIdMsj,para que evitar enviar la misma alerta durante el dia. |
| FECHA | 28/08/2014 |

### Firma

```sql
CREATE PROCEDURE sp_registra_evento_pru3(
  pTipoMsj                     char(1)
  pIdMsj                       char(10)
  pIdPlantilla                 char(12)
  pNumclt                      char(20)
  pNumcta                      char(20)
  pNumTarjeta                  char(16)
  pTipoproc                    char(1)
  pStr1                        char(30)
  pStr2                        char(30)
  pStr3                        char(30)
  pStr4                        char (30)
  pStr5                        char(150)
  pStr6                        char(100)
  pStr7                        char(60)
  pStr8                        char(60)
  pStr9                        char(15)
  pStr10                       char(100)
  pcorreo_alterno              char(100)
  pcelular_alterno             char(10)
  pImporte1                    money (16,2)
  pImporte2                    money (16,2)
  pImporte3                    money (16,2)
  pImporte4                    money (16,2)
  pImporte5                    money (16,2)
  pfecha1                      datetime year to fraction(3)
  pfecha2                      datetime year to fraction(3)
) RETURNING CHAR(5) as cCodRet
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pTipoMsj` | `char(1)` | — | — |
| `pIdMsj` | `char(10)` | — | — |
| `pIdPlantilla` | `char(12)` | — | — |
| `pNumclt` | `char(20)` | — | — |
| `pNumcta` | `char(20)` | — | — |
| `pNumTarjeta` | `char(16)` | — | — |
| `pTipoproc` | `char(1)` | — | — |
| `pStr1` | `char(30)` | — | — |
| `pStr2` | `char(30)` | — | — |
| `pStr3` | `char(30)` | — | — |
| `pStr4` | `char (30)` | — | — |
| `pStr5` | `char(150)` | — | — |
| `pStr6` | `char(100)` | — | — |
| `pStr7` | `char(60)` | — | — |
| `pStr8` | `char(60)` | — | — |
| `pStr9` | `char(15)` | — | — |
| `pStr10` | `char(100)` | — | — |
| `pcorreo_alterno` | `char(100)` | — | — |
| `pcelular_alterno` | `char(10)` | — | — |
| `pImporte1` | `money (16,2)` | — | — |
| `pImporte2` | `money (16,2)` | — | — |
| `pImporte3` | `money (16,2)` | — | — |
| `pImporte4` | `money (16,2)` | — | — |
| `pImporte5` | `money (16,2)` | — | — |
| `pfecha1` | `datetime year to fraction(3)` | — | — |
| `pfecha2` | `datetime year to fraction(3)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(5)` | L36 |
| `iexiste` | `INTEGER` | L37 |
| `iexiste2` | `INTEGER` | L38 |
| `iexiste3` | `INTEGER` | L39 |
| `iexistec` | `INTEGER` | L40 |
| `vnumcte` | `CHAR(20)` | L41 |
| `vsqlerr` | `INTEGER` | L42 |
| `vtransaction_id` | `CHAR(12)` | L43 |
| `cDia` | `CHAR (2)` | L44 |
| `cAnio` | `CHAR (4)` | L45 |
| `cMes` | `CHAR(2)` | L46 |
| `cMes1` | `CHAR (10)` | L47 |
| `cFechaH` | `CHAR (10)` | L48 |
| `bandera` | `CHAR(100)` | L49 |
| `cStr1` | `CHAR(30)` | L50 |
| `cStr5` | `CHAR(150)` | L51 |
| `iprioridad` | `INTEGER` | L52 |
| `vTablaNotif` | `varchar (50)` | L55 |
| `vInsStmt` | `lvarchar (2000)` | L56 |
| `vEstatus` | `nvarchar(20)` | L57 |
| `pfecha1Aux` | `varchar(100)` | L58 |
| `pfecha2Aux` | `varchar(100)` | L59 |
| `pNumTarjetaAux` | `varchar(18)` | L60 |
| `pNumctaAux` | `varchar(22)` | L61 |
| `vPermiteInsertar` | `varchar(1)` | L62 |
| *…2 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `mnsj_param` | `bdimnsj` | no | SELECT | L103 |
| `si_fechas` | `bdinteg` | ⚠️ sí | SELECT | L140 |
| `bdimnsj` | `bdimnsj` | no | INSERT | L209 |
| `si_cliente` | `bdinteg` | ⚠️ sí | SELECT | L237 |
| `sc_maechq` | `bdicheq` | ⚠️ sí | SELECT | L245 |
| `sd_maecred` | `bdicred` | ⚠️ sí | SELECT | L247 |
| `tarjeta` | `intercard` | ⚠️ sí | SELECT | L250 |
| `mnsjr_cat_prioridades` | `bdimnsj` | no | SELECT | L287 |
| `notif_cfg` | `bdimnsj` | no | SELECT | L297 |
| `mnsjr_cat_suscripcion` | `bdimnsj` | no | SELECT | L332 |
| `mnsjr_suscripcion_ctes` | `bdimnsj` | no | SELECT | L334 |
| `mnsjr_trx_online` | `bdimnsj` | no | SELECT | L343 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L69 | CÓDIGO_RETORNO | `LET cCodRet = '00000';` |  |
| L110 | VALIDACIÓN_NULL | `IF (pTipoMsj IS NULL OR pTipoMsj = '') OR` |  |
| L114 | CÓDIGO_RETORNO | `LET cCodRet = '00005';` |  |
| L120 | CÓDIGO_RETORNO | `LET cCodRet = '00020';` |  |
| L126 | CÓDIGO_RETORNO | `LET cCodRet = '00103';` |  |
| L130 | VALIDACIÓN_NULL | `IF (pNumclt IS NULL OR pNumclt = '') AND (pNumcta IS NULL OR pNumcta ='') AND (pNumTarjeta IS NULL O` |  |
| L131 | CÓDIGO_RETORNO | `LET cCodRet = '00110';` |  |
| L156 | FÓRMULA | `LET pStr5 = trim(cDia)\|\|'-'\|\|trim(cMes1)\|\|'-'\|\|trim(cAnio);` |  |
| L238 | VALIDACIÓN_NULL | `IF (iexistec = 0 or iexistec is null) then` |  |
| L239 | CÓDIGO_RETORNO | `LET cCodRet = '00100';` |  |
| L246 | VALIDACIÓN_NULL | `IF (iexiste = 0 or iexiste is null) THEN` |  |
| L248 | VALIDACIÓN_NULL | `IF (iexiste2 = 0 or iexiste2 is null) THEN` |  |
| L251 | VALIDACIÓN_NULL | `IF (iexiste3 = 0 or iexiste3 is null) then` |  |
| L252 | CÓDIGO_RETORNO | `LET cCodRet = '00115';` |  |
| L256 | CÓDIGO_RETORNO | `LET cCodRet = '00100';` |  |
| L263 | VALIDACIÓN_NULL | `IF (iexiste3 = 0 or iexiste3 is null) then` |  |
| L264 | CÓDIGO_RETORNO | `LET cCodRet = '00115';` |  |
| L268 | VALIDACIÓN_NULL | `IF (iexiste = 0 or iexiste is null) and (iexiste2 = 0 or iexiste2 is null) and (iexiste3 = 0 or iexi` |  |
| L269 | CÓDIGO_RETORNO | `LET cCodRet = '00112';` |  |
| L274 | VALIDACIÓN_NULL | `if vnumcte = '' or vnumcte is null  then` |  |
| L289 | VALIDACIÓN_NULL | `IF (iprioridad IS NULL OR iprioridad ='') THEN` |  |
| L302 | VALIDACIÓN_NULL | `IF (vTablaNotif IS NULL OR vTablaNotif = '') THEN` |  |
| L321 | CÓDIGO_RETORNO | `LET cCodRet = '00201';` |  |
| L347 | VALIDACIÓN_NULL | `IF (vtransaction_id IS NULL) THEN` |  |
| L353 | VALIDACIÓN_NULL | `IF (pImporte1 IS NULL or pImporte1 = '') THEN` |  |
| L356 | VALIDACIÓN_NULL | `IF (pImporte2 IS NULL or pImporte2 = '') THEN` |  |
| L359 | VALIDACIÓN_NULL | `IF (pImporte3 IS NULL or pImporte3 = '') THEN` |  |
| L362 | VALIDACIÓN_NULL | `IF (pImporte4 IS NULL or pImporte4 = '') THEN` |  |
| L365 | VALIDACIÓN_NULL | `IF (pImporte5 IS NULL or pImporte5 = '') THEN` |  |
| L368 | VALIDACIÓN_NULL | `IF (pfecha1 IS NULL or pfecha1 = '') THEN` |  |
| | *…17 más…* | | |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `registra` | ACCION | registra | 🔵 CONVENCIÓN | nombre_sp |
| `evento` | ENTIDAD | evento/notificación | 🔵 CONVENCIÓN | nombre_sp |
| `?_pru3` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_pru3` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_registra_evento_prue2jjv`

| Campo | Valor |
|-------|-------|
| **Dominio** | D09 · `bdimnsj` · Mensajería |
| **Archivo fuente** | `bdimnsj_sp_registra_evento_prue2jjv.sql` |
| **LOC (1er CREATE)** | 355 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "registra evento/notificación" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `registra` → `INSERT` encontrado en el cuerpo · `notifica` → `INSERT` encontrado en el cuerpo · `notifica` → `EXECUTE` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=1 / 4 términos |

### Historia del SP

| Tipo | Valor |
|------|-------|
| AUTOR | Angel Rene de la Llave |
| PROYECTO | Latinia registro de eventos. |
| ACTIVIDAD | Se registran los eventos para el envo de mnsjr y emails a un cliente |
| FECHA | 26/03/2012 |
| MODIFICACION | Incluir campos string adicionales. JGP-19/09/2012 |
| FECHA | 19/09/2012 |
| MODIFICACION | Incluir registro de eventos pendientes de confirmar "PENDIENTE", hasta que sean |
| FECHA | 09/11/2012 |

### Firma

```sql
CREATE PROCEDURE sp_registra_evento_prue2jjv(
  pTipoMsj                     char(1)
  pIdMsj                       char(10)
  pNumclt                      char(20)
  pNumcta                      char(20)
  pNumTarjeta                  char(16)
  pTipoproc                    char(1)
  pStr1                        char(30)
  pStr2                        char(30)
  pStr3                        char(30)
  pStr4                        char (30)
  pStr5                        char(150)
  pStr6                        char(100)
  pStr7                        char(60)
  pStr8                        char(60)
  pStr9                        char(15)
  pStr10                       char(100)
  pcorreo_alterno              char(100)
  pcelular_alterno             char(10)
  pImporte1                    money (16,2)
  pImporte2                    money (16,2)
  pImporte3                    money (16,2)
  pImporte4                    money (16,2)
  pImporte5                    money (16,2)
  pfecha1                      datetime year to fraction(3)
  PFECHA2                      datetime year to fraction(3)
) RETURNING CHAR(5) as cCodRet
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pTipoMsj` | `char(1)` | — | — |
| `pIdMsj` | `char(10)` | — | — |
| `pNumclt` | `char(20)` | — | — |
| `pNumcta` | `char(20)` | — | — |
| `pNumTarjeta` | `char(16)` | — | — |
| `pTipoproc` | `char(1)` | — | — |
| `pStr1` | `char(30)` | — | — |
| `pStr2` | `char(30)` | — | — |
| `pStr3` | `char(30)` | — | — |
| `pStr4` | `char (30)` | — | — |
| `pStr5` | `char(150)` | — | — |
| `pStr6` | `char(100)` | — | — |
| `pStr7` | `char(60)` | — | — |
| `pStr8` | `char(60)` | — | — |
| `pStr9` | `char(15)` | — | — |
| `pStr10` | `char(100)` | — | — |
| `pcorreo_alterno` | `char(100)` | — | — |
| `pcelular_alterno` | `char(10)` | — | — |
| `pImporte1` | `money (16,2)` | — | — |
| `pImporte2` | `money (16,2)` | — | — |
| `pImporte3` | `money (16,2)` | — | — |
| `pImporte4` | `money (16,2)` | — | — |
| `pImporte5` | `money (16,2)` | — | — |
| `pfecha1` | `datetime year to fraction(3)` | — | — |
| `PFECHA2` | `datetime year to fraction(3)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(5)` | L44 |
| `iexiste` | `INTEGER` | L45 |
| `iexiste2` | `INTEGER` | L46 |
| `iexiste3` | `INTEGER` | L47 |
| `iexistec` | `INTEGER` | L48 |
| `vnumcte` | `CHAR(20)` | L49 |
| `vsqlerr` | `INTEGER` | L50 |
| `vtransaction_id` | `CHAR(12)` | L51 |
| `bandera` | `CHAR(100)` | L52 |
| `iprioridad` | `INTEGER` | L53 |
| `vTablaNotif` | `varchar (50)` | L56 |
| `vInsStmt` | `lvarchar (2000)` | L57 |
| `vEstatus` | `nvarchar(20)` | L58 |
| `pfecha1Aux` | `varchar(100)` | L59 |
| `pfecha2Aux` | `varchar(100)` | L60 |
| `pNumTarjetaAux` | `varchar(18)` | L61 |
| `pNumctaAux` | `varchar(22)` | L62 |
| `vPermiteInsertar` | `varchar(1)` | L63 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `mnsj_param` | `bdimnsj` | no | SELECT | L90 |
| `si_cliente` | `bdinteg` | ⚠️ sí | SELECT | L126 |
| `sc_maechq` | `bdicheq` | ⚠️ sí | SELECT | L134 |
| `sd_maecred` | `bdicred` | ⚠️ sí | SELECT | L136 |
| `tarjeta` | `intercard` | ⚠️ sí | SELECT | L139 |
| `mnsjr_cat_prioridades` | `bdimnsj` | no | SELECT | L189 |
| `notif_cfg` | `bdimnsj` | no | SELECT | L199 |
| `mnsjr_trx_online` | `bdimnsj` | no | INSERT | L331 |
| `mnsjr_trx_batch` | `bdimnsj` | no | INSERT | L341 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_registra_evento_bpi` | `bdimnsj` | no | L176 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L67 | CÓDIGO_RETORNO | `LET cCodRet = '00000';` |  |
| L97 | VALIDACIÓN_NULL | `IF (pTipoMsj IS NULL OR pTipoMsj = '') OR` |  |
| L100 | CÓDIGO_RETORNO | `LET cCodRet = '00005';` |  |
| L106 | CÓDIGO_RETORNO | `LET cCodRet = '00020';` |  |
| L112 | CÓDIGO_RETORNO | `LET cCodRet = '00103';` |  |
| L116 | VALIDACIÓN_NULL | `IF (pNumclt IS NULL OR pNumclt = '') AND (pNumcta IS NULL OR pNumcta ='') AND (pNumTarjeta IS NULL O` |  |
| L117 | CÓDIGO_RETORNO | `LET cCodRet = '00110';` |  |
| L127 | VALIDACIÓN_NULL | `IF (iexistec = 0 or iexistec is null) then` |  |
| L128 | CÓDIGO_RETORNO | `LET cCodRet = '00100';` |  |
| L135 | VALIDACIÓN_NULL | `IF (iexiste = 0 or iexiste is null) THEN` |  |
| L137 | VALIDACIÓN_NULL | `IF (iexiste2 = 0 or iexiste2 is null) THEN` |  |
| L140 | VALIDACIÓN_NULL | `IF (iexiste3 = 0 or iexiste3 is null) then` |  |
| L141 | CÓDIGO_RETORNO | `LET cCodRet = '00115';` |  |
| L145 | CÓDIGO_RETORNO | `LET cCodRet = '00100';` |  |
| L152 | VALIDACIÓN_NULL | `IF (iexiste3 = 0 or iexiste3 is null) then` |  |
| L153 | CÓDIGO_RETORNO | `LET cCodRet = '00115';` |  |
| L157 | VALIDACIÓN_NULL | `IF (iexiste = 0 or iexiste is null) and (iexiste2 = 0 or iexiste2 is null) and (iexiste3 = 0 or iexi` |  |
| L158 | CÓDIGO_RETORNO | `LET cCodRet = '00112';` |  |
| L163 | VALIDACIÓN_NULL | `if vnumcte = '' or vnumcte is null  then` |  |
| L191 | VALIDACIÓN_NULL | `IF (iprioridad IS NULL OR iprioridad ='') THEN` |  |
| L204 | VALIDACIÓN_NULL | `IF (vTablaNotif IS NULL OR vTablaNotif = '') THEN` |  |
| L224 | CÓDIGO_RETORNO | `LET cCodRet = '00201';` |  |
| L233 | VALIDACIÓN_NULL | `IF (vtransaction_id IS NULL) THEN` |  |
| L238 | VALIDACIÓN_NULL | `IF (pImporte1 IS NULL or pImporte1 = '') THEN` |  |
| L241 | VALIDACIÓN_NULL | `IF (pImporte2 IS NULL or pImporte2 = '') THEN` |  |
| L244 | VALIDACIÓN_NULL | `IF (pImporte3 IS NULL or pImporte3 = '') THEN` |  |
| L247 | VALIDACIÓN_NULL | `IF (pImporte4 IS NULL or pImporte4 = '') THEN` |  |
| L250 | VALIDACIÓN_NULL | `IF (pImporte5 IS NULL or pImporte5 = '') THEN` |  |
| L253 | VALIDACIÓN_NULL | `IF (pfecha1 IS NULL or pfecha1 = '') THEN` |  |
| L258 | VALIDACIÓN_NULL | `IF (pfecha2 IS NULL or pfecha2 = '') THEN` |  |
| | *…16 más…* | | |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `registra` | ACCION | registra | 🔵 CONVENCIÓN | nombre_sp |
| `evento` | ENTIDAD | evento/notificación | 🔵 CONVENCIÓN | nombre_sp |
| `?_prue2jjv` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_prue2jjv` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_registra_evento_pruejjv`

| Campo | Valor |
|-------|-------|
| **Dominio** | D09 · `bdimnsj` · Mensajería |
| **Archivo fuente** | `bdimnsj_sp_registra_evento_pruejjv.sql` |
| **LOC (1er CREATE)** | 316 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "registra evento/notificación" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `registra` → `INSERT` encontrado en el cuerpo · `notifica` → `INSERT` encontrado en el cuerpo · `notifica` → `EXECUTE` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=1 / 4 términos |

### Historia del SP

| Tipo | Valor |
|------|-------|
| AUTOR | Angel Rene de la Llave |
| PROYECTO | Latinia registro de eventos. |
| ACTIVIDAD | Se registran los eventos para el env de mnsjr y emails a un cliente |
| FECHA | 26/03/2012 |

### Firma

```sql
CREATE PROCEDURE sp_registra_evento_pruejjv(
  pTipoMsj                     char(1)
  pIdMsj                       char(10)
  pNumclt                      char(20)
  pNumcta                      char(20)
  pNumTarjeta                  char(16)
  pTipoproc                    char(1)
  pStr1                        char(30)
  pStr2                        char(30)
  pStr3                        char(30)
  pStr4                        char (30)
  pStr5                        char(150)
  pImporte1                    money (16,2)
  pImporte2                    money (16,2)
  pImporte3                    money (16,2)
  pImporte4                    money (16,2)
  pImporte5                    money (16,2)
  pfecha1                      datetime year to fraction(3)
  pfecha2                      datetime year to fraction(3)
) RETURNING CHAR(5) as cCodRet
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pTipoMsj` | `char(1)` | — | — |
| `pIdMsj` | `char(10)` | — | — |
| `pNumclt` | `char(20)` | — | — |
| `pNumcta` | `char(20)` | — | — |
| `pNumTarjeta` | `char(16)` | — | — |
| `pTipoproc` | `char(1)` | — | — |
| `pStr1` | `char(30)` | — | — |
| `pStr2` | `char(30)` | — | — |
| `pStr3` | `char(30)` | — | — |
| `pStr4` | `char (30)` | — | — |
| `pStr5` | `char(150)` | — | — |
| `pImporte1` | `money (16,2)` | — | — |
| `pImporte2` | `money (16,2)` | — | — |
| `pImporte3` | `money (16,2)` | — | — |
| `pImporte4` | `money (16,2)` | — | — |
| `pImporte5` | `money (16,2)` | — | — |
| `pfecha1` | `datetime year to fraction(3)` | — | — |
| `pfecha2` | `datetime year to fraction(3)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(5)` | L22 |
| `iexiste` | `INTEGER` | L23 |
| `iexiste2` | `INTEGER` | L24 |
| `iexiste3` | `INTEGER` | L25 |
| `iexistec` | `INTEGER` | L26 |
| `vnumcte` | `CHAR(20)` | L27 |
| `vsqlerr` | `INTEGER` | L28 |
| `cDia` | `CHAR (2)` | L29 |
| `cAnio` | `CHAR (4)` | L30 |
| `cMes` | `CHAR(2)` | L31 |
| `cMes1` | `CHAR (10)` | L32 |
| `cFechaH` | `CHAR (10)` | L33 |
| `bandera` | `CHAR(100)` | L34 |
| `iprioridad` | `INTEGER` | L35 |
| `vTablaNotif` | `varchar (50)` | L38 |
| `vInsStmt` | `lvarchar (2000)` | L39 |
| `vEstatus` | `nvarchar(20)` | L40 |
| `pfecha1Aux` | `varchar(100)` | L41 |
| `pfecha2Aux` | `varchar(100)` | L42 |
| `pNumTarjetaAux` | `varchar(18)` | L43 |
| `pNumctaAux` | `varchar(22)` | L44 |
| `vPermiteInsertar` | `varchar(1)` | L45 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `mnsj_param` | `bdimnsj` | no | SELECT | L79 |
| `si_fechas` | `bdinteg` | ⚠️ sí | SELECT | L116 |
| `si_cliente` | `bdinteg` | ⚠️ sí | SELECT | L138 |
| `sc_maechq` | `bdicheq` | ⚠️ sí | SELECT | L145 |
| `sd_maecred` | `bdicred` | ⚠️ sí | SELECT | L147 |
| `tarjeta` | `intercard` | ⚠️ sí | SELECT | L150 |
| `mnsjr_cat_prioridades` | `bdimnsj` | no | SELECT | L180 |
| `notif_cfg` | `bdimnsj` | no | SELECT | L189 |
| `mnsjr_trx_online` | `bdimnsj` | no | INSERT | L296 |
| `mnsjr_trx_batch` | `bdimnsj` | no | INSERT | L305 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L50 | CÓDIGO_RETORNO | `LET cCodRet = '00000';` |  |
| L86 | VALIDACIÓN_NULL | `IF (pTipoMsj IS NULL OR pTipoMsj = '') OR` |  |
| L89 | CÓDIGO_RETORNO | `LET cCodRet = '00005';` |  |
| L95 | CÓDIGO_RETORNO | `LET cCodRet = '00020';` |  |
| L101 | CÓDIGO_RETORNO | `LET cCodRet = '00103';` |  |
| L105 | VALIDACIÓN_NULL | `IF (pNumclt IS NULL OR pNumclt = '') AND (pNumcta IS NULL OR pNumcta ='') AND (pNumTarjeta IS NULL O` |  |
| L106 | CÓDIGO_RETORNO | `LET cCodRet = '00110';` |  |
| L132 | FÓRMULA | `LET pStr5 = trim(cDia)\|\|'-'\|\|trim(cMes1)\|\|'-'\|\|trim(cAnio);` |  |
| L139 | VALIDACIÓN_NULL | `IF (iexistec = 0 or iexistec is null) then` |  |
| L140 | CÓDIGO_RETORNO | `LET cCodRet = '00100';` |  |
| L146 | VALIDACIÓN_NULL | `IF (iexiste = 0 or iexiste is null) THEN` |  |
| L148 | VALIDACIÓN_NULL | `IF (iexiste2 = 0 or iexiste2 is null) THEN` |  |
| L151 | VALIDACIÓN_NULL | `IF (iexiste3 = 0 or iexiste3 is null) then` |  |
| L152 | CÓDIGO_RETORNO | `LET cCodRet = '00115';` |  |
| L156 | CÓDIGO_RETORNO | `LET cCodRet = '00100';` |  |
| L163 | VALIDACIÓN_NULL | `IF (iexiste3 = 0 or iexiste3 is null) then` |  |
| L164 | CÓDIGO_RETORNO | `LET cCodRet = '00115';` |  |
| L168 | VALIDACIÓN_NULL | `IF (iexiste = 0 or iexiste is null) and (iexiste2 = 0 or iexiste2 is null) and (iexiste3 = 0 or iexi` |  |
| L169 | CÓDIGO_RETORNO | `LET cCodRet = '00112';` |  |
| L174 | VALIDACIÓN_NULL | `if vnumcte = '' or vnumcte is null then` |  |
| L182 | VALIDACIÓN_NULL | `IF (iprioridad IS NULL OR iprioridad ='') THEN` |  |
| L194 | VALIDACIÓN_NULL | `IF (vTablaNotif IS NULL OR vTablaNotif = '') THEN` |  |
| L213 | CÓDIGO_RETORNO | `LET cCodRet = '00201';` |  |
| L218 | VALIDACIÓN_NULL | `IF (pEstatus IS NULL) THEN` |  |
| L224 | VALIDACIÓN_NULL | `IF (pImporte1 IS NULL or pImporte1 = '') THEN` |  |
| L227 | VALIDACIÓN_NULL | `IF (pImporte2 IS NULL or pImporte2 = '') THEN` |  |
| L230 | VALIDACIÓN_NULL | `IF (pImporte3 IS NULL or pImporte3 = '') THEN` |  |
| L233 | VALIDACIÓN_NULL | `IF (pImporte4 IS NULL or pImporte4 = '') THEN` |  |
| L236 | VALIDACIÓN_NULL | `IF (pImporte5 IS NULL or pImporte5 = '') THEN` |  |
| L239 | VALIDACIÓN_NULL | `IF (pfecha1 IS NULL or pfecha1 = '') THEN` |  |
| | *…10 más…* | | |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `registra` | ACCION | registra | 🔵 CONVENCIÓN | nombre_sp |
| `evento` | ENTIDAD | evento/notificación | 🔵 CONVENCIÓN | nombre_sp |
| `?_pruejjv` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_pruejjv` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_registra_evento_tmp_spei`

| Campo | Valor |
|-------|-------|
| **Dominio** | D09 · `bdimnsj` · Mensajería |
| **Archivo fuente** | `bdimnsj_sp_registra_evento_tmp_spei.sql` |
| **LOC (1er CREATE)** | 447 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "registra evento/notificación" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `registra` → `INSERT` encontrado en el cuerpo · `notifica` → `INSERT` encontrado en el cuerpo · `notifica` → `EXECUTE` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=4 · INFERIDO=0 · SINTÉTICO=1 / 5 términos |

### Historia del SP

| Tipo | Valor |
|------|-------|
| AUTOR | Angel Rene de la Llave |
| PROYECTO | Latinia registro de eventos. |
| ACTIVIDAD | Se registran los eventos para el env???????o de mnsjr y emails a un cliente |
| FECHA | 26/03/2012 |
| MODIFICACION | Incluir campos string adicionales. JGP-19/09/2012 |
| FECHA | 19/09/2012 |
| MODIFICACION | Incluir registro de eventos pendientes de confirmar "PENDIENTE", hasta que sean |
| FECHA | 09/11/2012 |
| AUTOR | Manuel Osuna V. |
| MODIFICACION | Se agrega parametro pIdPlantilla,para que explotar la funcionalidad de que una alerta |
| FECHA | 15/10/2013 |
| AUTOR | Cristo Lugo |
| MODIFICACION | Se agrega validaci???n pIdMsj,para que evitar enviar la misma alerta durante el dia. |
| FECHA | 28/08/2014 |

### Firma

```sql
CREATE PROCEDURE sp_registra_evento_tmp_spei(
  pTipoMsj                     char(1)
  pIdMsj                       char(10)
  pIdPlantilla                 char(12)
  pNumclt                      char(20)
  pNumcta                      char(20)
  pNumTarjeta                  char(16)
  pTipoproc                    char(1)
  pStr1                        char(30)
  pStr2                        char(30)
  pStr3                        char(30)
  pStr4                        char (30)
  pStr5                        char(150)
  pStr6                        char(100)
  pStr7                        char(60)
  pStr8                        char(60)
  pStr9                        char(15)
  pStr10                       char(100)
  pcorreo_alterno              char(100)
  pcelular_alterno             char(10)
  pImporte1                    money (16,2)
  pImporte2                    money (16,2)
  pImporte3                    money (16,2)
  pImporte4                    money (16,2)
  pImporte5                    money (16,2)
  pfecha1                      datetime year to fraction(3)
  pfecha2                      datetime year to fraction(3)
) RETURNING CHAR(5) as cCodRet
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pTipoMsj` | `char(1)` | — | — |
| `pIdMsj` | `char(10)` | — | — |
| `pIdPlantilla` | `char(12)` | — | — |
| `pNumclt` | `char(20)` | — | — |
| `pNumcta` | `char(20)` | — | — |
| `pNumTarjeta` | `char(16)` | — | — |
| `pTipoproc` | `char(1)` | — | — |
| `pStr1` | `char(30)` | — | — |
| `pStr2` | `char(30)` | — | — |
| `pStr3` | `char(30)` | — | — |
| `pStr4` | `char (30)` | — | — |
| `pStr5` | `char(150)` | — | — |
| `pStr6` | `char(100)` | — | — |
| `pStr7` | `char(60)` | — | — |
| `pStr8` | `char(60)` | — | — |
| `pStr9` | `char(15)` | — | — |
| `pStr10` | `char(100)` | — | — |
| `pcorreo_alterno` | `char(100)` | — | — |
| `pcelular_alterno` | `char(10)` | — | — |
| `pImporte1` | `money (16,2)` | — | — |
| `pImporte2` | `money (16,2)` | — | — |
| `pImporte3` | `money (16,2)` | — | — |
| `pImporte4` | `money (16,2)` | — | — |
| `pImporte5` | `money (16,2)` | — | — |
| `pfecha1` | `datetime year to fraction(3)` | — | — |
| `pfecha2` | `datetime year to fraction(3)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(5)` | L36 |
| `iexiste` | `INTEGER` | L37 |
| `iexiste2` | `INTEGER` | L38 |
| `iexiste3` | `INTEGER` | L39 |
| `iexistec` | `INTEGER` | L40 |
| `vnumcte` | `CHAR(20)` | L41 |
| `vsqlerr` | `INTEGER` | L42 |
| `vtransaction_id` | `CHAR(12)` | L43 |
| `cDia` | `CHAR (2)` | L44 |
| `cAnio` | `CHAR (4)` | L45 |
| `cMes` | `CHAR(2)` | L46 |
| `cMes1` | `CHAR (10)` | L47 |
| `cFechaH` | `CHAR (10)` | L48 |
| `bandera` | `CHAR(100)` | L49 |
| `cStr1` | `CHAR(30)` | L50 |
| `cStr5` | `CHAR(150)` | L51 |
| `iprioridad` | `INTEGER` | L52 |
| `vTablaNotif` | `varchar (50)` | L55 |
| `vInsStmt` | `lvarchar (2000)` | L56 |
| `vEstatus` | `nvarchar(20)` | L57 |
| `pfecha1Aux` | `varchar(100)` | L58 |
| `pfecha2Aux` | `varchar(100)` | L59 |
| `pNumTarjetaAux` | `varchar(18)` | L60 |
| `pNumctaAux` | `varchar(22)` | L61 |
| `vPermiteInsertar` | `varchar(1)` | L62 |
| *…2 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `mnsj_param` | `bdimnsj` | no | SELECT | L103 |
| `si_fechas` | `bdinteg` | ⚠️ sí | SELECT | L140 |
| `bdimnsj` | `bdimnsj` | no | INSERT | L209 |
| `si_cliente` | `bdinteg` | ⚠️ sí | SELECT | L237 |
| `sc_maechq` | `bdicheq` | ⚠️ sí | SELECT | L245 |
| `sd_maecred` | `bdicred` | ⚠️ sí | SELECT | L247 |
| `tarjeta` | `intercard` | ⚠️ sí | SELECT | L250 |
| `notif_cfg` | `bdimnsj` | no | SELECT | L297 |
| `mnsjr_cat_suscripcion` | `bdimnsj` | no | SELECT | L332 |
| `mnsjr_suscripcion_ctes` | `bdimnsj` | no | SELECT | L334 |
| `mnsjr_trx_online` | `bdimnsj` | no | SELECT | L343 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L69 | CÓDIGO_RETORNO | `LET cCodRet = '00000';` |  |
| L110 | VALIDACIÓN_NULL | `IF (pTipoMsj IS NULL OR pTipoMsj = '') OR` |  |
| L114 | CÓDIGO_RETORNO | `LET cCodRet = '00005';` |  |
| L120 | CÓDIGO_RETORNO | `LET cCodRet = '00020';` |  |
| L126 | CÓDIGO_RETORNO | `LET cCodRet = '00103';` |  |
| L130 | VALIDACIÓN_NULL | `IF (pNumclt IS NULL OR pNumclt = '') AND (pNumcta IS NULL OR pNumcta ='') AND (pNumTarjeta IS NULL O` |  |
| L131 | CÓDIGO_RETORNO | `LET cCodRet = '00110';` |  |
| L156 | FÓRMULA | `LET pStr5 = trim(cDia)\|\|'-'\|\|trim(cMes1)\|\|'-'\|\|trim(cAnio);` |  |
| L238 | VALIDACIÓN_NULL | `IF (iexistec = 0 or iexistec is null) then` |  |
| L239 | CÓDIGO_RETORNO | `LET cCodRet = '00100';` |  |
| L246 | VALIDACIÓN_NULL | `IF (iexiste = 0 or iexiste is null) THEN` |  |
| L248 | VALIDACIÓN_NULL | `IF (iexiste2 = 0 or iexiste2 is null) THEN` |  |
| L251 | VALIDACIÓN_NULL | `IF (iexiste3 = 0 or iexiste3 is null) then` |  |
| L252 | CÓDIGO_RETORNO | `LET cCodRet = '00115';` |  |
| L256 | CÓDIGO_RETORNO | `LET cCodRet = '00100';` |  |
| L263 | VALIDACIÓN_NULL | `IF (iexiste3 = 0 or iexiste3 is null) then` |  |
| L264 | CÓDIGO_RETORNO | `LET cCodRet = '00115';` |  |
| L268 | VALIDACIÓN_NULL | `IF (iexiste = 0 or iexiste is null) and (iexiste2 = 0 or iexiste2 is null) and (iexiste3 = 0 or iexi` |  |
| L269 | CÓDIGO_RETORNO | `LET cCodRet = '00112';` |  |
| L274 | VALIDACIÓN_NULL | `if vnumcte = '' or vnumcte is null  then` |  |
| L289 | VALIDACIÓN_NULL | `IF (iprioridad IS NULL OR iprioridad ='') THEN` |  |
| L302 | VALIDACIÓN_NULL | `IF (vTablaNotif IS NULL OR vTablaNotif = '') THEN` |  |
| L321 | CÓDIGO_RETORNO | `LET cCodRet = '00201';` |  |
| L347 | VALIDACIÓN_NULL | `IF (vtransaction_id IS NULL) THEN` |  |
| L353 | VALIDACIÓN_NULL | `IF (pImporte1 IS NULL or pImporte1 = '') THEN` |  |
| L356 | VALIDACIÓN_NULL | `IF (pImporte2 IS NULL or pImporte2 = '') THEN` |  |
| L359 | VALIDACIÓN_NULL | `IF (pImporte3 IS NULL or pImporte3 = '') THEN` |  |
| L362 | VALIDACIÓN_NULL | `IF (pImporte4 IS NULL or pImporte4 = '') THEN` |  |
| L365 | VALIDACIÓN_NULL | `IF (pImporte5 IS NULL or pImporte5 = '') THEN` |  |
| L368 | VALIDACIÓN_NULL | `IF (pfecha1 IS NULL or pfecha1 = '') THEN` |  |
| | *…17 más…* | | |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `registra` | ACCION | registra | 🔵 CONVENCIÓN | nombre_sp |
| `evento` | ENTIDAD | evento/notificación | 🔵 CONVENCIÓN | nombre_sp |
| `?_tmp_` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `spei` | PREFIJO | familia SPEI (pagos interbancarios) | 🔵 CONVENCIÓN | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_tmp_` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_registra_eventopba`

| Campo | Valor |
|-------|-------|
| **Dominio** | D09 · `bdimnsj` · Mensajería |
| **Archivo fuente** | `bdimnsj_sp_registra_eventopba.sql` |
| **LOC (1er CREATE)** | 138 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "registra evento/notificación (PBA — sufijo de SPs para Pruebas; confirmado por SME)" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `registra` → `INSERT` encontrado en el cuerpo · `confirma` → `SELECT` encontrado en el cuerpo · `notifica` → `INSERT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=4 · INFERIDO=0 · SINTÉTICO=0 / 4 términos |

### Historia del SP

| Tipo | Valor |
|------|-------|
| AUTOR | Angel Rene de la Llave |
| PROYECTO | Latinia registro de eventos. |
| ACTIVIDAD | Se registran los eventos para el envío de mnsjr y emails a un cliente |
| FECHA | 26/03/2012 |

### Firma

```sql
CREATE PROCEDURE sp_registra_eventopba(
  pTipoMsj                     char(1)
  pIdMsj                       char(10)
  pNumclt                      char(20)
  pNumcta                      char(20)
  pNumTarjeta                  char(16)
  pTipoproc                    char(1)
  pStr1                        char(30)
  pStr2                        char(30)
  pStr3                        char(30)
  pStr4                        char (30)
  pStr5                        char(150)
  pImporte1                    money (16,2)
  pImporte2                    money (16,2)
  pImporte3                    money (16,2)
  pImporte4                    money (16,2)
  pImporte5                    money (16,2)
  pfecha1                      datetime year to fraction(3)
  pfecha2                      datetime year to fraction(3)
) RETURNING CHAR(5) as cCodRet
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pTipoMsj` | `char(1)` | — | — |
| `pIdMsj` | `char(10)` | — | — |
| `pNumclt` | `char(20)` | — | — |
| `pNumcta` | `char(20)` | — | — |
| `pNumTarjeta` | `char(16)` | — | — |
| `pTipoproc` | `char(1)` | — | — |
| `pStr1` | `char(30)` | — | — |
| `pStr2` | `char(30)` | — | — |
| `pStr3` | `char(30)` | — | — |
| `pStr4` | `char (30)` | — | — |
| `pStr5` | `char(150)` | — | — |
| `pImporte1` | `money (16,2)` | — | — |
| `pImporte2` | `money (16,2)` | — | — |
| `pImporte3` | `money (16,2)` | — | — |
| `pImporte4` | `money (16,2)` | — | — |
| `pImporte5` | `money (16,2)` | — | — |
| `pfecha1` | `datetime year to fraction(3)` | — | — |
| `pfecha2` | `datetime year to fraction(3)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(5)` | L22 |
| `iexiste` | `INTEGER` | L23 |
| `iexiste2` | `INTEGER` | L24 |
| `iexiste3` | `INTEGER` | L25 |
| `iexistec` | `INTEGER` | L26 |
| `vnumcte` | `CHAR(20)` | L27 |
| `vsqlerr` | `INTEGER` | L28 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_cliente` | `bdinteg` | ⚠️ sí | SELECT | L75 |
| `sc_maechq` | `bdicheq` | ⚠️ sí | SELECT | L82 |
| `sd_maecred` | `bdicred` | ⚠️ sí | SELECT | L84 |
| `tarjeta` | `intercard` | ⚠️ sí | SELECT | L87 |
| `mnsjr_trx_online` | `bdimnsj` | no | INSERT | L118 |
| `mnsjr_trx_batch` | `bdimnsj` | no | INSERT | L127 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L31 | CÓDIGO_RETORNO | `LET cCodRet = '00000';` |  |
| L49 | VALIDACIÓN_NULL | `IF (pTipoMsj IS NULL OR pTipoMsj = '') OR` |  |
| L52 | CÓDIGO_RETORNO | `LET cCodRet = '00005';` |  |
| L58 | CÓDIGO_RETORNO | `LET cCodRet = '00020';` |  |
| L64 | CÓDIGO_RETORNO | `LET cCodRet = '00103';` |  |
| L68 | VALIDACIÓN_NULL | `IF (pNumclt IS NULL OR pNumclt = '') AND (pNumcta IS NULL OR pNumcta ='') AND (pNumTarjeta IS NULL O` |  |
| L69 | CÓDIGO_RETORNO | `LET cCodRet = '00110';` |  |
| L76 | VALIDACIÓN_NULL | `IF (iexistec = 0 or iexistec is null) then` |  |
| L77 | CÓDIGO_RETORNO | `LET cCodRet = '00100';` |  |
| L83 | VALIDACIÓN_NULL | `IF (iexiste = 0 or iexiste is null) THEN` |  |
| L85 | VALIDACIÓN_NULL | `IF (iexiste2 = 0 or iexiste2 is null) THEN` |  |
| L88 | VALIDACIÓN_NULL | `IF (iexiste3 = 0 or iexiste3 is null) then` |  |
| L89 | CÓDIGO_RETORNO | `LET cCodRet = '00115';` |  |
| L93 | CÓDIGO_RETORNO | `LET cCodRet = '00100';` |  |
| L100 | VALIDACIÓN_NULL | `IF (iexiste3 = 0 or iexiste3 is null) then` |  |
| L101 | CÓDIGO_RETORNO | `LET cCodRet = '00115';` |  |
| L105 | VALIDACIÓN_NULL | `IF (iexiste = 0 or iexiste is null) and (iexiste2 = 0 or iexiste2 is null) and (iexiste3 = 0 or iexi` |  |
| L106 | CÓDIGO_RETORNO | `LET cCodRet = '00112';` |  |
| L111 | VALIDACIÓN_NULL | `if vnumcte = '' or vnumcte is null then` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `registra` | ACCION | registra | 🔵 CONVENCIÓN | nombre_sp |
| `evento` | ENTIDAD | evento/notificación | 🔵 CONVENCIÓN | nombre_sp |
| `pba` | MODIF | PBA — sufijo de SPs para Pruebas; confirmado por SME (Guerra | 🔵 CONVENCIÓN | nombre_sp |

---

## `sp_suscriptores`

| Campo | Valor |
|-------|-------|
| **Dominio** | D09 · `bdimnsj` · Mensajería |
| **Archivo fuente** | `bdimnsj_sp_suscriptores.sql` |
| **LOC (1er CREATE)** | 265 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "gestiona suscriptores" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `suscriptores` → `SELECT` encontrado en el cuerpo · `suscriptores` → `INSERT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=0 / 2 términos |

### Historia del SP

| Tipo | Valor |
|------|-------|
| DESCRIPCION | Generación de archivo de suscriptores. |
| FECHA | 17/05/2012 |

### Firma

```sql
CREATE PROCEDURE sp_suscriptores(
) RETURNING CHAR(5) AS CodRetorno,
```

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `viSqlError` | `INTEGER` | L17 |
| `vsCodRetorno` | `CHAR (5)` | L18 |
| `vsMensaje` | `CHAR(200)` | L19 |
| `vdFechaHoy` | `DATETIME YEAR TO FRACTION(5)` | L20 |
| `cMaxregistros` | `CHAR(6)` | L21 |
| `cCompany` | `CHAR (100)` | L22 |
| `valruta` | `INTEGER` | L23 |
| `vsDia` | `CHAR(2)` | L24 |
| `vsMes` | `CHAR(2)` | L25 |
| `vsAnio` | `CHAR(2)` | L26 |
| `cMax` | `CHAR(10)` | L27 |
| `vsnumcte` | `CHAR (20)` | L28 |
| `vsapaterno` | `CHAR(26)` | L29 |
| `vsamaterno` | `CHAR(26)` | L30 |
| `vsnombre1` | `CHAR(26)` | L31 |
| `vsnombre2` | `CHAR(26)` | L32 |
| `vsSexo` | `CHAR(26)` | L33 |
| `vstelefono` | `CHAR(13)` | L34 |
| `vstipotel` | `SMALLINT` | L35 |
| `vsSecuencia` | `SMALLINT` | L36 |
| `vsStatustel` | `CHAR(1)` | L37 |
| `vsextension` | `CHAR(5)` | L38 |
| `vscarrier` | `SMALLINT` | L39 |
| `vsnombrecarrier` | `CHAR(20)` | L40 |
| `vsStatusvalidacion` | `SMALLINT` | L41 |
| *…18 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `mnsj_errores` | `bdimnsj` | no | INSERT | L116 |
| `si_fechas` | `bdinteg` | ⚠️ sí | SELECT | L135 |
| `mnsj_param` | `bdimnsj` | no | SELECT | L138 |
| `si_cliente` | `bdinteg` | ⚠️ sí | SELECT | L158 |
| `mnsj_bitacora_susc` | `bdimnsj` | no | INSERT | L196 |
| `mnsj_susc_paso` | `bdimnsj` | no | INSERT | L200 |
| `bdimnsj` | `bdimnsj` | no | INSERT | L208 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_consulta_telefonos` | `bdinteg` | ⚠️ sí | L169 |
| `sp_consulta_correos` | `bdinteg` | ⚠️ sí | L182 |
| `sp_generaarch` | `bdimnsj` | no | L236 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L68 | FÓRMULA | `LET vdFechaHoy = CAST('1900-01-01 12:00:00' AS DATETIME YEAR TO FRACTION(5));` |  |
| L231 | FÓRMULA | `LET viRegistros = viRegistros +1;` |  |
| L238 | FÓRMULA | `LET vArch = vArch +1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `suscriptores` | ACCION | gestiona suscriptores | ✅ CÓDIGO | nombre_sp, texto_cuerpo |

---

## `sp_suscriptores_act`

| Campo | Valor |
|-------|-------|
| **Dominio** | D09 · `bdimnsj` · Mensajería |
| **Archivo fuente** | `bdimnsj_sp_suscriptores_act.sql` |
| **LOC (1er CREATE)** | 404 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "gestiona suscriptores" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `suscriptores` → `SELECT` encontrado en el cuerpo · `suscriptores` → `UPDATE` encontrado en el cuerpo · `suscriptores` → `INSERT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=0 / 3 términos |

### Historia del SP

| Tipo | Valor |
|------|-------|
| DESCRIPCION | Generacin de actualizacin de suscriptores. |
| FECHA | 17/05/2012 |
| MODIFICACION | Se agrega la logica, para no tomar los correos que aun no han sido validados en el proceso StrikeIron |
| FECHA | 10/01/2024 |

### Firma

```sql
CREATE PROCEDURE sp_suscriptores_act(
) RETURNING CHAR(5) AS CodRetorno,
```

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `viSqlError` | `INTEGER` | L23 |
| `vsCodRetorno` | `CHAR (5)` | L24 |
| `vsCodRetorno2` | `CHAR (5)` | L25 |
| `vsMensaje` | `CHAR(200)` | L26 |
| `vdFechaHoy` | `DATE` | L27 |
| `pFecha` | `DATE` | L28 |
| `pFecha2` | `DATE` | L29 |
| `cMaxregistros` | `CHAR(6)` | L30 |
| `cCompany` | `CHAR (100)` | L31 |
| `valruta` | `INTEGER` | L32 |
| `vsDia` | `CHAR(2)` | L33 |
| `vsMes` | `CHAR(2)` | L34 |
| `vsAnio` | `CHAR(2)` | L35 |
| `vsDia2` | `CHAR(2)` | L36 |
| `vsMes2` | `CHAR(2)` | L37 |
| `vsAnio2` | `CHAR(2)` | L38 |
| `cMax` | `CHAR(10)` | L39 |
| `vsnumcte` | `CHAR (20)` | L40 |
| `vsapaterno` | `CHAR(26)` | L41 |
| `vsamaterno` | `CHAR(26)` | L42 |
| `vsnombre1` | `CHAR(26)` | L43 |
| `vsnombre2` | `CHAR(26)` | L44 |
| `vsSexo` | `CHAR(26)` | L45 |
| `vstelefono` | `CHAR(13)` | L46 |
| `vstipotel` | `SMALLINT` | L47 |
| *…31 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `mnsj_errores` | `bdimnsj` | no | INSERT | L150 |
| `mnsj_procesos` | `bdimnsj` | no | INSERT | L162 |
| `mnsj_param` | `bdimnsj` | no | SELECT | L187 |
| `si_cliente` | `bdinteg` | ⚠️ sí | SELECT | L206 |
| `si_telefonos_actual` | `bdinteg` | ⚠️ sí | SELECT | L233 |
| `si_correos` | `bdinteg` | ⚠️ sí | SELECT | L245 |
| `mnsj_bitacora_susc` | `bdimnsj` | no | INSERT | L262 |
| `mnsj_susc_paso` | `bdimnsj` | no | INSERT | L268 |
| `bdimnsj` | `bdimnsj` | no | INSERT | L276 |
| `mnsj_procesos` | `bdimnsj` | no | UPDATE | L397 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_registra_evento_prod` | `bdimnsj` | no | L153 |
| `sp_consulta_telefonos` | `bdinteg` | ⚠️ sí | L230 |
| `sp_generaarch` | `bdimnsj` | no | L370 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L89 | FÓRMULA | `LET pFecha2 = today-1;` |  |
| L247 | VALIDACIÓN_NULL | `IF (vsvalido IS NULL OR vsvalido != '1') THEN -- Se verifica si el correo del cliente es invalido pa` |  |
| L265 | VALIDACIÓN_NULL | `IF vscorreo IS NULL OR vscorreo = '' THEN` |  |
| L295 | FÓRMULA | `LET viRegistros = viRegistros +1;` |  |
| L327 | FÓRMULA | `LET viRegistros = viRegistros +1;` |  |
| L363 | FÓRMULA | `LET viRegistros = viRegistros +1;` |  |
| L372 | FÓRMULA | `LET vArch = vArch +1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `suscriptores` | ACCION | gestiona suscriptores | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `act` | ACCION | actualiza | 🔵 CONVENCIÓN | nombre_sp |

---

## `sp_suscriptores_act_pba`

| Campo | Valor |
|-------|-------|
| **Dominio** | D09 · `bdimnsj` · Mensajería |
| **Archivo fuente** | `bdimnsj_sp_suscriptores_act_pba.sql` |
| **LOC (1er CREATE)** | 307 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "gestiona suscriptores (PBA — sufijo de SPs para Pruebas; confirmado por SME)" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `confirma` → `SELECT` encontrado en el cuerpo · `confirma` → `UPDATE` encontrado en el cuerpo · `suscriptores` → `SELECT` encontrado en el cuerpo · `suscriptores` → `UPDATE` encontrado en el cuerpo · `suscriptores` → `INSERT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=0 / 4 términos |

### Historia del SP

| Tipo | Valor |
|------|-------|
| DESCRIPCION | Generación de actualización de suscriptores. |
| FECHA | 17/05/2012 |

### Firma

```sql
CREATE PROCEDURE sp_suscriptores_act_pba(
) RETURNING CHAR(5) AS CodRetorno,
```

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `viSqlError` | `INTEGER` | L17 |
| `vsCodRetorno` | `CHAR (5)` | L18 |
| `vsCodRetorno2` | `CHAR (5)` | L19 |
| `vsMensaje` | `CHAR(200)` | L20 |
| `vdFechaHoy` | `DATE` | L21 |
| `pFecha` | `DATE` | L22 |
| `cMaxregistros` | `CHAR(6)` | L23 |
| `cCompany` | `CHAR (100)` | L24 |
| `valruta` | `INTEGER` | L25 |
| `vsDia` | `CHAR(2)` | L26 |
| `vsMes` | `CHAR(2)` | L27 |
| `vsAnio` | `CHAR(2)` | L28 |
| `cMax` | `CHAR(10)` | L29 |
| `vsnumcte` | `CHAR (20)` | L30 |
| `vsapaterno` | `CHAR(26)` | L31 |
| `vsamaterno` | `CHAR(26)` | L32 |
| `vsnombre1` | `CHAR(26)` | L33 |
| `vsnombre2` | `CHAR(26)` | L34 |
| `vsSexo` | `CHAR(26)` | L35 |
| `vstelefono` | `CHAR(13)` | L36 |
| `vstipotel` | `SMALLINT` | L37 |
| `vsSecuencia` | `SMALLINT` | L38 |
| `vsStatustel` | `CHAR(1)` | L39 |
| `vsextension` | `CHAR(5)` | L40 |
| `vscarrier` | `SMALLINT` | L41 |
| *…25 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `mnsj_errores` | `bdimnsj` | no | INSERT | L132 |
| `mnsj_procesos` | `bdimnsj` | no | INSERT | L144 |
| `mnsj_param` | `bdimnsj` | no | SELECT | L165 |
| `si_cliente` | `bdinteg` | ⚠️ sí | SELECT | L184 |
| `si_telefonos_actual` | `bdinteg` | ⚠️ sí | SELECT | L208 |
| `si_correos` | `bdinteg` | ⚠️ sí | SELECT | L220 |
| `mnsj_bitacora_susc` | `bdimnsj` | no | INSERT | L233 |
| `mnsj_susc_paso` | `bdimnsj` | no | INSERT | L237 |
| `bdimnsj` | `bdimnsj` | no | INSERT | L245 |
| `mnsj_procesos` | `bdimnsj` | no | UPDATE | L300 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_registra_evento_prod` | `bdimnsj` | no | L135 |
| `sp_consulta_telefonos` | `bdinteg` | ⚠️ sí | L205 |
| `sp_generaarch` | `bdimnsj` | no | L273 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L268 | FÓRMULA | `LET viRegistros = viRegistros +1;` |  |
| L275 | FÓRMULA | `LET vArch = vArch +1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `suscriptores` | ACCION | gestiona suscriptores | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `act` | ACCION | actualiza | 🔵 CONVENCIÓN | nombre_sp |
| `pba` | MODIF | PBA — sufijo de SPs para Pruebas; confirmado por SME (Guerra | 🔵 CONVENCIÓN | nombre_sp |

---

## `sp_suscriptores_act_xfecha`

| Campo | Valor |
|-------|-------|
| **Dominio** | D09 · `bdimnsj` · Mensajería |
| **Archivo fuente** | `bdimnsj_sp_suscriptores_act_xfecha.sql` |
| **LOC (1er CREATE)** | 295 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "gestiona suscriptores fecha" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `suscriptores` → `SELECT` encontrado en el cuerpo · `suscriptores` → `UPDATE` encontrado en el cuerpo · `suscriptores` → `INSERT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=0 / 5 términos |

### Historia del SP

| Tipo | Valor |
|------|-------|
| DESCRIPCION | Generación de actualización de suscriptores. |
| FECHA | 17/05/2012 |

### Firma

```sql
CREATE PROCEDURE sp_suscriptores_act_xfecha(
  pFecha                       DATE
) RETURNING CHAR(5) AS CodRetorno,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pFecha` | `DATE` | `fecha`=fecha | ✅ CÓDIGO |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `viSqlError` | `INTEGER` | L17 |
| `vsCodRetorno` | `CHAR (5)` | L18 |
| `vsMensaje` | `CHAR(200)` | L19 |
| `vdFechaHoy` | `DATE` | L20 |
| `cMaxregistros` | `CHAR(6)` | L21 |
| `cCompany` | `CHAR (100)` | L22 |
| `valruta` | `INTEGER` | L23 |
| `vsDia` | `CHAR(2)` | L24 |
| `vsMes` | `CHAR(2)` | L25 |
| `vsAnio` | `CHAR(2)` | L26 |
| `cMax` | `CHAR(10)` | L27 |
| `vsnumcte` | `CHAR (20)` | L28 |
| `vsapaterno` | `CHAR(26)` | L29 |
| `vsamaterno` | `CHAR(26)` | L30 |
| `vsnombre1` | `CHAR(26)` | L31 |
| `vsnombre2` | `CHAR(26)` | L32 |
| `vsSexo` | `CHAR(26)` | L33 |
| `vstelefono` | `CHAR(13)` | L34 |
| `vstipotel` | `SMALLINT` | L35 |
| `vsSecuencia` | `SMALLINT` | L36 |
| `vsStatustel` | `CHAR(1)` | L37 |
| `vsextension` | `CHAR(5)` | L38 |
| `vscarrier` | `SMALLINT` | L39 |
| `vsnombrecarrier` | `CHAR(20)` | L40 |
| `vsStatusvalidacion` | `SMALLINT` | L41 |
| *…23 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `mnsj_errores` | `bdimnsj` | no | INSERT | L127 |
| `mnsj_procesos` | `bdimnsj` | no | INSERT | L136 |
| `mnsj_param` | `bdimnsj` | no | SELECT | L155 |
| `si_cliente` | `bdinteg` | ⚠️ sí | SELECT | L173 |
| `si_telefonos_actual` | `bdinteg` | ⚠️ sí | SELECT | L197 |
| `si_correos` | `bdinteg` | ⚠️ sí | SELECT | L217 |
| `mnsj_bitacora_susc` | `bdimnsj` | no | INSERT | L224 |
| `mnsj_susc_paso` | `bdimnsj` | no | INSERT | L228 |
| `bdimnsj` | `bdimnsj` | no | INSERT | L236 |
| `mnsj_procesos` | `bdimnsj` | no | UPDATE | L289 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_consulta_telefonos` | `bdinteg` | ⚠️ sí | L194 |
| `sp_generaarch` | `bdimnsj` | no | L264 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L259 | FÓRMULA | `LET viRegistros = viRegistros +1;` |  |
| L266 | FÓRMULA | `LET vArch = vArch +1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `suscriptores` | ACCION | gestiona suscriptores | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `act` | ACCION | actualiza | 🔵 CONVENCIÓN | nombre_sp |
| `x` | MODIF | por (criterio) | 🔵 CONVENCIÓN | nombre_sp |
| `fecha` | ENTIDAD | fecha | ✅ CÓDIGO | nombre_sp, texto_cuerpo |

---

## `sp_suscriptores_tmp`

| Campo | Valor |
|-------|-------|
| **Dominio** | D09 · `bdimnsj` · Mensajería |
| **Archivo fuente** | `bdimnsj_sp_suscriptores_tmp.sql` |
| **LOC (1er CREATE)** | 266 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "gestiona suscriptores" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `suscriptores` → `SELECT` encontrado en el cuerpo · `suscriptores` → `INSERT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=1 / 3 términos |

### Historia del SP

| Tipo | Valor |
|------|-------|
| DESCRIPCION | Generación de archivo de suscriptores. |
| FECHA | 17/05/2012 |

### Firma

```sql
CREATE PROCEDURE sp_suscriptores_tmp(
) RETURNING CHAR(5) AS CodRetorno,
```

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `viSqlError` | `INTEGER` | L17 |
| `vsCodRetorno` | `CHAR (5)` | L18 |
| `vsMensaje` | `CHAR(200)` | L19 |
| `vdFechaHoy` | `DATETIME YEAR TO FRACTION(5)` | L20 |
| `cMaxregistros` | `CHAR(6)` | L21 |
| `cCompany` | `CHAR (100)` | L22 |
| `valruta` | `INTEGER` | L23 |
| `vsDia` | `CHAR(2)` | L24 |
| `vsMes` | `CHAR(2)` | L25 |
| `vsAnio` | `CHAR(2)` | L26 |
| `cMax` | `CHAR(10)` | L27 |
| `vsnumcte` | `CHAR (20)` | L28 |
| `vsapaterno` | `CHAR(26)` | L29 |
| `vsamaterno` | `CHAR(26)` | L30 |
| `vsnombre1` | `CHAR(26)` | L31 |
| `vsnombre2` | `CHAR(26)` | L32 |
| `vsSexo` | `CHAR(26)` | L33 |
| `vstelefono` | `CHAR(13)` | L34 |
| `vstipotel` | `SMALLINT` | L35 |
| `vsSecuencia` | `SMALLINT` | L36 |
| `vsStatustel` | `CHAR(1)` | L37 |
| `vsextension` | `CHAR(5)` | L38 |
| `vscarrier` | `SMALLINT` | L39 |
| `vsnombrecarrier` | `CHAR(20)` | L40 |
| `vsStatusvalidacion` | `SMALLINT` | L41 |
| *…18 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `mnsj_errores` | `bdimnsj` | no | INSERT | L117 |
| `si_fechas` | `bdinteg` | ⚠️ sí | SELECT | L136 |
| `mnsj_param` | `bdimnsj` | no | SELECT | L139 |
| `si_cliente` | `bdinteg` | ⚠️ sí | SELECT | L158 |
| `mnsj_bitacora_susc` | `bdimnsj` | no | INSERT | L197 |
| `mnsj_susc_paso` | `bdimnsj` | no | INSERT | L201 |
| `bdimnsj` | `bdimnsj` | no | INSERT | L209 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_consulta_telefonos` | `bdinteg` | ⚠️ sí | L170 |
| `sp_consulta_correos` | `bdinteg` | ⚠️ sí | L183 |
| `sp_generaarch` | `bdimnsj` | no | L237 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L68 | FÓRMULA | `LET vdFechaHoy = CAST('1900-01-01 12:00:00' AS DATETIME YEAR TO FRACTION(5));` |  |
| L232 | FÓRMULA | `LET viRegistros = viRegistros +1;` |  |
| L239 | FÓRMULA | `LET vArch = vArch +1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `suscriptores` | ACCION | gestiona suscriptores | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?_tmp` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_tmp` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_valida_esnumerico`

| Campo | Valor |
|-------|-------|
| **Dominio** | D09 · `bdimnsj` · Mensajería |
| **Archivo fuente** | `bdimnsj_sp_valida_esnumerico.sql` |
| **LOC (1er CREATE)** | 37 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "valida número" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `valida` → `IF` encontrado en el cuerpo · `valida` → `RETURN` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=2 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_valida_esnumerico(
  pscadena                     CHAR(20)
) RETURNING CHAR (01) as numerico
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pscadena` | `CHAR(20)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vsRespuesta` | `CHAR (1)` | L5 |
| `visqlerr` | `INTEGER` | L8 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `valida` | ACCION | valida | 🔵 CONVENCIÓN | nombre_sp |
| `?_es` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `num` | ENTIDAD | número (de) | 🔵 CONVENCIÓN | nombre_sp |
| `?erico` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_es`, `?erico` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_validacion_msj`

| Campo | Valor |
|-------|-------|
| **Dominio** | D09 · `bdimnsj` · Mensajería |
| **Archivo fuente** | `bdimnsj_sp_validacion_msj.sql` |
| **LOC (1er CREATE)** | 737 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "validación" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `valida` → `IF` encontrado en el cuerpo · `valida` → `RETURN` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=1 / 3 términos |

### Firma

```sql
CREATE PROCEDURE sp_validacion_msj(
  pTexto_msj                   CHAR(160)
  pUsuario                     CHAR(10)
  pPass                        CHAR(10)
  pCel                         CHAR(10)
  pCompania                    CHAR(10)
) RETURNING CHAR (5) AS cReturnCode,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pTexto_msj` | `CHAR(160)` | — | — |
| `pUsuario` | `CHAR(10)` | — | — |
| `pPass` | `CHAR(10)` | — | — |
| `pCel` | `CHAR(10)` | — | — |
| `pCompania` | `CHAR(10)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `iSqlErr` | `INTEGER` | L13 |
| `cPCodRet5` | `CHAR(6)` | L15 |
| `cReturnCode` | `CHAR (5)` | L16 |
| `cErrorDescription` | `CHAR (256)` | L17 |
| `vRetornoDescription` | `VARCHAR (100)` | L18 |
| `vcodret` | `CHAR(50)` | L19 |
| `cFechaSolitud` | `DATETIME YEAR TO SECOND` | L20 |
| `cFecha` | `CHAR(10)` | L21 |
| `cHora` | `CHAR(10)` | L22 |
| `iParam` | `INTEGER` | L23 |
| `iNParam` | `INTEGER` | L24 |
| `sMsgError` | `VARCHAR(100)` | L25 |
| `vImporte` | `VARCHAR(160)` | L26 |
| `vImporte2` | `CHAR(160)` | L27 |
| `PARAM1` | `VARCHAR(40)` | L28 |
| `PARAM2` | `VARCHAR(40)` | L29 |
| `PARAM3` | `VARCHAR(40)` | L30 |
| `PARAM4` | `VARCHAR(40)` | L31 |
| `PARAM5` | `VARCHAR(40)` | L32 |
| `PARAM6` | `VARCHAR(40)` | L33 |
| `PARAM7` | `VARCHAR(40)` | L34 |
| `PARAM8` | `VARCHAR(40)` | L35 |
| `PARAM9` | `VARCHAR(40)` | L36 |
| `PARAM10` | `VARCHAR(40)` | L37 |
| `texto_msj_par` | `VARCHAR(30)` | L38 |
| *…20 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `mnsjr_bitacora_sms` | `bdimnsj` | no | INSERT | L118 |
| `mnsj_cat_sinonimos` | `bdimnsj` | no | SELECT | L147 |
| `mnsjr_cat_smsin` | `bdimnsj` | no | SELECT | L174 |
| `si_telefonos_actual` | `bdinteg` | ⚠️ sí | SELECT | L200 |
| `si_cliente` | `bdinteg` | ⚠️ sí | SELECT | L205 |
| `sysshmvals` | `sysmaster` | ⚠️ sí | SELECT | L214 |
| `12` | `bdimnsj` | no | SELECT | L351 |
| `si_telefonos` | `bdinteg` | ⚠️ sí | UPDATE | L608 |
| `si_bitacora_huella_ine` | `bdinteg` | ⚠️ sí | SELECT | L626 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_espacios_blancos2` | `bdimnsj` | no | L131 |
| `sp_recupera_saldo` | `bdimnsj` | no | L209 |
| `sp_registra_evento` | `bdimnsj` | no | L222 |
| `sp_valida_esnumerico` | `bdimnsj` | no | L231 |
| `sp_validaradn_multicanal` | `bdisolic` | ⚠️ sí | L233 |
| `sp_recupera_pago` | `bdimnsj` | no | L254 |
| `sp_recupera_saldo_inv` | `bdimnsj` | no | L273 |
| `sp_recupera_estatussolic` | `bdimnsj` | no | L291 |
| `sp_recupera_cuentatelefono` | `bdimnsj` | no | L310 |
| `sp_diferir` | `bdicred` | ⚠️ sí | L331 |
| `sp_cancelatarjeta_canales` | `intercard` | ⚠️ sí | L354 |
| `sp_prestamoflex_sms` | `bdisolic` | ⚠️ sí | L387 |
| `sp_credisol_contrata_x_sms_sdos` | `bdicred` | ⚠️ sí | L538 |
| `sp_credisol_contrata_x_sms` | `bdicred` | ⚠️ sí | L541 |
| `sp_rep_aumlincred_sms` | `bdisolic` | ⚠️ sí | L568 |
| `sp_consulta_aclaracion_sms` | `bdiaclaracion` | ⚠️ sí | L578 |
| `sp_diferir_cancela` | `bdicred` | ⚠️ sí | L649 |
| `sp_actualiza_linea_pdigital` | `bdicred` | ⚠️ sí | L692 |
| `sp_obtener_tarjeta_incremento_inflacion` | `bdicred` | ⚠️ sí | L715 |
| `sp_actualizar_linea_credito_tc_inflacion` | `bdicred` | ⚠️ sí | L722 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L66 | CÓDIGO_RETORNO | `LET cPCodRet = '00000';` |  |
| L134 | FÓRMULA | `LET iCont = iCont + 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `validacion` | ACCION | validación | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?_msj` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_msj` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

# SP Specs — D15 · `bdilide` · LIDE / PLD

> Generado por `build-sp-specs.py` · Grounding Pass v1.0
> Objetivo: verificar el conocimiento del Gemelo Cognitivo contra el código fuente real
> **Convención:** solo se analiza el PRIMER `CREATE PROCEDURE` de cada archivo
> (los siguientes son dependencias concatenadas — ver memoria del proyecto)

## Resumen de validación del dominio

| Métrica | Valor |
|---------|-------|
| SPs analizados | **101** |
| Presentes en callgraph | 5 |
| SPs aislados (⚠️ no estaban en el análisis previo) | 96 |
| Propósito **VERIFICADO** | 47 |
| Propósito **PARCIAL** | 53 |
| Propósito **NO_VERIFICABLE** | 1 |
| SPs con tokens **SINTÉTICOS** detectados | 93 |

> Los **96 SPs aislados** no aparecen en el callgraph y por tanto
> **no fueron incluidos en el análisis de journeys, reglas ni vocabulario previo**.
> Este grounding pass los analiza por primera vez directamente desde el código.

---

## `borramovs_movefechis`

| Campo | Valor |
|-------|-------|
| **Dominio** | D15 · `bdilide` · LIDE / PLD |
| **Archivo fuente** | `bdilide_borramovs_movefechis.sql` |
| **LOC (1er CREATE)** | 84 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "borra movimientos, movimiento y CHI — formato/protocolo de consulta al Buró de Crédito" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=1 · INFERIDO=3 · SINTÉTICO=2 / 6 términos |

### Firma

```sql
CREATE PROCEDURE borramovs_movefechis(
  paniomes                     CHAR(6)
) RETURNING CHAR(5), CHAR(5), INTEGER
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `paniomes` | `CHAR(6)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vcodret1` | `CHAR(5)` | L4 |
| `vcodret2` | `CHAR(5)` | L5 |
| `vcodret3` | `CHAR(50)` | L6 |
| `sql_err` | `INTEGER` | L7 |
| `isam_err` | `INTEGER` | L8 |
| `desc_err` | `CHAR(50)` | L9 |
| `vcontador` | `INTEGER` | L10 |
| `vcontador1` | `INTEGER` | L11 |
| `vnum_serial` | `INTEGER` | L12 |
| `vcomienza` | `SMALLINT` | L13 |
| `vabierto` | `CHAR(1)` | L14 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sl_movefec_his` | `bdilide` | no | SELECT | L51 |
| `sl_movefec_his` | `bdilide` | no | DELETE | L62 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L24 | FÓRMULA | `LET vcomienza       = -1;` |  |
| L65 | FÓRMULA | `LET vcontador = vcontador + 1;` |  |
| L66 | FÓRMULA | `LET vcontador1 = vcontador1 + 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `borra` | ACCION | borra / elimina registros (borramovs_movhis, borramovscfd*) | 🟡 INFERIDO | nombre_sp |
| `movs` | ENTIDAD | movimientos (abreviación) | 🟡 INFERIDO | nombre_sp |
| `mov` | ENTIDAD | movimiento | 🔵 CONVENCIÓN | nombre_sp |
| `?efe` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `chi` | ENTIDAD | CHI — formato/protocolo de consulta al Buró de Crédito (bdib | 🟡 INFERIDO | nombre_sp |
| `?s` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?efe`, `?s` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `ejecutor_diario`

| Campo | Valor |
|-------|-------|
| **Dominio** | D15 · `bdilide` · LIDE / PLD |
| **Archivo fuente** | `bdilide_ejecutor_diario.sql` |
| **LOC (1er CREATE)** | 41 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "(diario)" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 7 tabla(s) con operaciones: SELECT, UPDATE, INSERT |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=1 / 2 términos |

### Firma

```sql
CREATE PROCEDURE ejecutor_diario(
  pFechaProceso                DATE
  pCve_Usuario                 CHAR(8)
) RETURNING CHAR(5)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pFechaProceso` | `DATE` | — | — |
| `pCve_Usuario` | `CHAR(8)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `v_cCod_Ret` | `CHAR(5)` | L6 |
| `vsqlerr` | `INTEGER` | L7 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_fechas` | `bdinteg` | ⚠️ sí | UPDATE | L25 |
| `sd_fechas` | `bdicred` | ⚠️ sí | UPDATE | L26 |
| `sc_fechas` | `bdicheq` | ⚠️ sí | UPDATE | L27 |
| `sc_movdia` | `bdicheq` | ⚠️ sí | INSERT | L31 |
| `sc_movhis` | `bdicheq` | ⚠️ sí | SELECT | L34 |
| `sd_movhis` | `bdicred` | ⚠️ sí | SELECT | L37 |
| `sd_movdia` | `bdicred` | ⚠️ sí | INSERT | L37 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `?ejecutor_` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `diario` | MODIF | diario | 🔵 CONVENCIÓN | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?ejecutor_` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_actparamtraspmovefec`

| Campo | Valor |
|-------|-------|
| **Dominio** | D15 · `bdilide` · LIDE / PLD |
| **Archivo fuente** | `bdilide_sp_actparamtraspmovefec.sql` |
| **LOC (1er CREATE)** | 115 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "actualiza parámetro y movimiento" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `actualiza` → `UPDATE` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=5 · INFERIDO=0 · SINTÉTICO=2 / 7 términos |

### Firma

```sql
CREATE PROCEDURE sp_actparamtraspmovefec(
  pFechaIni                    DATE
  pFechaFin                    DATE
) RETURNING CHAR(5)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pFechaIni` | `DATE` | — | — |
| `pFechaFin` | `DATE` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vcodret` | `CHAR(5)` | L13 |
| `vcodret2` | `CHAR(5)` | L14 |
| `vcodret3` | `CHAR(50)` | L15 |
| `vsqlerr` | `INTEGER` | L16 |
| `isam_err` | `INTEGER` | L17 |
| `error_info` | `CHAR(50)` | L18 |
| `vpromedio` | `INTEGER` | L19 |
| `vcont` | `SMALLINT` | L20 |
| `vbrinca` | `INTEGER` | L21 |
| `vserial` | `INTEGER` | L22 |
| `vparam_serial` | `CHAR(60)` | L23 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sl_movefec` | `bdilide` | no | SELECT | L58 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L77 | VALIDACIÓN_NULL | `IF vparam_serial is null OR vparam_serial = '' THEN` |  |
| L86 | FÓRMULA | `LET vbrinca = vpromedio * 2;` |  |
| L97 | VALIDACIÓN_NULL | `IF vparam_serial is null OR vparam_serial = '' THEN` |  |
| L106 | FÓRMULA | `LET vcont = vcont + 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `act` | ACCION | actualiza | 🔵 CONVENCIÓN | nombre_sp |
| `param` | ENTIDAD | parámetro | 🔵 CONVENCIÓN | nombre_sp |
| `?tra` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `mov` | ENTIDAD | movimiento | 🔵 CONVENCIÓN | nombre_sp |
| `?efec` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?tra`, `?efec` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_actualizacodfechaenvio`

| Campo | Valor |
|-------|-------|
| **Dominio** | D15 · `bdilide` · LIDE / PLD |
| **Archivo fuente** | `bdilide_sp_actualizacodfechaenvio.sql` |
| **LOC (1er CREATE)** | 134 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "actualiza código y fecha" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `actualiza` → `UPDATE` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=3 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=0 / 5 términos |

### Historia del SP

| Tipo | Valor |
|------|-------|
| ACTIVIDAD | Realiza actualización del campo fecha_envio y cod_envio. |
| FECHA | 08/OCT/2008 --* |

### Firma

```sql
CREATE PROCEDURE sp_actualizacodfechaenvio(
  pTipo                        CHAR(1)
  pNomArch                     CHAR(16)
  pCod_Envio                   CHAR(5)
  pStatus                      CHAR(1)
) RETURNING CHAR(6)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pTipo` | `CHAR(1)` | — | — |
| `pNomArch` | `CHAR(16)` | — | — |
| `pCod_Envio` | `CHAR(5)` | `cod`=código · `envio`=envía | 🔵 CONVENCIÓN / ✅ CÓDIGO |
| `pStatus` | `CHAR(1)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vcCodRet` | `CHAR(6)` | L14 |
| `sql_err` | `INTEGER` | L15 |
| `vdFechaError` | `DATE` | L16 |
| `vcMensaje` | `CHAR(100)` | L17 |
| `cErrorSP` | `CHAR(6)` | L18 |
| `vcArchivoCT` | `CHAR(16)` | L19 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_fechas` | `bdinteg` | ⚠️ sí | SELECT | L73 |
| `sl_archsat` | `bdilide` | no | UPDATE | L74 |
| `sl_consat` | `bdilide` | no | UPDATE | L105 |
| `sl_procesos` | `bdilide` | no | UPDATE | L109 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_grabarerrores` | `bdilide` | no | L50 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L112 | FÓRMULA | `LET vcArchivoCT = trim(vcArchivoCT) \|\| trim(substr(pNomArch,3,length(pNomArch)-2));` |  |
| L123 | FÓRMULA | `LET vcArchivoCT = trim(vcArchivoCT) \|\| trim(substr(pNomArch,3,length(pNomArch)-2));` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `actualiza` | ACCION | actualiza | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `cod` | ENTIDAD | código | 🔵 CONVENCIÓN | nombre_sp |
| `fecha` | ENTIDAD | fecha | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `envio` | ACCION | envía | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |

---

## `sp_actualizaide_31052013`

| Campo | Valor |
|-------|-------|
| **Dominio** | D15 · `bdilide` · LIDE / PLD |
| **Archivo fuente** | `bdilide_sp_actualizaide_31052013.sql` |
| **LOC (1er CREATE)** | 108 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "actualiza identificador" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `actualiza` → `UPDATE` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=1 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_actualizaide_31052013(
  pcEmpresa                    CHAR(3)
) RETURNING CHAR(5)  AS vcCodret1,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pcEmpresa` | `CHAR(3)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vcCodret1` | `CHAR(5)` | L7 |
| `vcCodret2` | `CHAR(5)` | L8 |
| `vcCodret3` | `CHAR(50)` | L9 |
| `viSqlErr` | `INTEGER` | L10 |
| `viIsamErr` | `INTEGER` | L11 |
| `vcDescErr` | `CHAR(50)` | L12 |
| `viContador1` | `INTEGER` | L13 |
| `viContCommit` | `INTEGER` | L14 |
| `vComienza` | `SMALLINT` | L15 |
| `viTransacc` | `SMALLINT` | L16 |
| `vcCuenta` | `CHAR(20)` | L17 |
| `vdMonto` | `MONEY(16,2)` | L18 |
| `vcRefer` | `CHAR(20)` | L19 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sc_movhis` | `bdicheq` | ⚠️ sí | SELECT | L60 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L29 | FÓRMULA | `LET vComienza    = -1;` |  |
| L85 | FÓRMULA | `LET viContador1 = viContador1 + 1;` |  |
| L86 | FÓRMULA | `LET viContCommit = viContCommit + 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `actualiza` | ACCION | actualiza | 🔵 CONVENCIÓN | nombre_sp |
| `id` | ENTIDAD | identificador (de) | 🔵 CONVENCIÓN | nombre_sp |
| `?e_31052013` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?e_31052013` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_actualizainformesat`

| Campo | Valor |
|-------|-------|
| **Dominio** | D15 · `bdilide` · LIDE / PLD |
| **Archivo fuente** | `bdilide_sp_actualizainformesat.sql` |
| **LOC (1er CREATE)** | 55 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "actualiza información y Mesa de Control — equipo de revisión y autorización de solicitudes de crédito; status codes MC/CM; valida comprobantes de ingreso; comentario explícito en código" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `actualiza` → `UPDATE` encontrado en el cuerpo · `valida` → `IF` encontrado en el cuerpo · `valida` → `RETURN` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=2 / 6 términos |

### Firma

```sql
CREATE PROCEDURE sp_actualizainformesat(
  pRFC                         CHAR(13)
) RETURNING CHAR(6), CHAR(60)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pRFC` | `CHAR(13)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(6)` | L5 |
| `iSql_Err` | `INTEGER` | L6 |
| `cMensaje` | `CHAR(60)` | L7 |
| `dFechaHoy` | `DATE` | L8 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sc_fechas` | `bdicheq` | ⚠️ sí | SELECT | L33 |
| `sl_exentos` | `bdilide` | no | UPDATE | L37 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `actualiza` | ACCION | actualiza | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `info` | ENTIDAD | información | 🔵 CONVENCIÓN | nombre_sp |
| `?r` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `mesa` | ENTIDAD | Mesa de Control — equipo de revisión y autorización de solic | 🔵 CONVENCIÓN | nombre_sp |
| `?t` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?r`, `?t` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_actualizaresultadosat`

| Campo | Valor |
|-------|-------|
| **Dominio** | D15 · `bdilide` · LIDE / PLD |
| **Archivo fuente** | `bdilide_sp_actualizaresultadosat.sql` |
| **LOC (1er CREATE)** | 99 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "actualiza resultado · SAT — Servicio de Administración Tributaria" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `actualiza` → `UPDATE` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=0 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_actualizaresultadosat(
  pRFC                         CHAR(13)
) RETURNING CHAR(6), CHAR(60)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pRFC` | `CHAR(13)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(6)` | L5 |
| `iSql_Err` | `INTEGER` | L6 |
| `cMensaje` | `CHAR(60)` | L7 |
| `dFechaHoy` | `DATE` | L8 |
| `cNumCte` | `CHAR(20)` | L9 |
| `cStatus` | `CHAR(1)` | L10 |
| `vexiste` | `INTEGER` | L11 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sc_fechas` | `bdicheq` | ⚠️ sí | SELECT | L39 |
| `sl_consat` | `bdilide` | no | SELECT | L44 |
| `sl_consat` | `bdilide` | no | UPDATE | L50 |
| `sl_exentos` | `bdilide` | no | SELECT | L58 |
| `sl_exentostemp` | `bdilide` | no | SELECT | L65 |
| `sl_exentos` | `bdilide` | no | UPDATE | L68 |
| `sl_exentos` | `bdilide` | no | INSERT | L75 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `actualiza` | ACCION | actualiza | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `resultado` | ENTIDAD | resultado | 🔵 CONVENCIÓN | nombre_sp |
| `sat` | REG | SAT — Servicio de Administración Tributaria (CFDI, ISR, IVA) | 🔵 CONVENCIÓN | nombre_sp |

---

## `sp_actualizarfclide`

| Campo | Valor |
|-------|-------|
| **Dominio** | D15 · `bdilide` · LIDE / PLD |
| **Archivo fuente** | `bdilide_sp_actualizarfclide.sql` |
| **LOC (1er CREATE)** | 142 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "actualiza RFC y identificador" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `actualiza` → `UPDATE` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=2 / 6 términos |

### Firma

```sql
CREATE PROCEDURE sp_actualizarfclide(
  cNumCte                      CHAR(20)
  cRfcAnt                      CHAR(13)
  cRfcActual                   CHAR(13)
  cAnioMes1                    CHAR(6)
  cAnioMes2                    CHAR(6)
) RETURNING CHAR(5) -- DATOS A REGRESAR --
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `cNumCte` | `CHAR(20)` | — | — |
| `cRfcAnt` | `CHAR(13)` | `rfc`=RFC (registro fiscal) | ✅ CÓDIGO |
| `cRfcActual` | `CHAR(13)` | `rfc`=RFC (registro fiscal) | ✅ CÓDIGO |
| `cAnioMes1` | `CHAR(6)` | — | — |
| `cAnioMes2` | `CHAR(6)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `iSql_Err` | `INTEGER` | L9 |
| `cCodRet` | `CHAR(5)` | L10 |
| `cAnioConsat` | `CHAR(4)` | L11 |
| `vexiste1` | `INTEGER` | L12 |
| `vexiste2` | `INTEGER` | L13 |
| `vexiste3` | `INTEGER` | L14 |
| `vexiste4` | `INTEGER` | L15 |
| `vexiste5` | `INTEGER` | L16 |
| `vexiste6` | `INTEGER` | L17 |
| `vexiste7` | `INTEGER` | L18 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sl_movefec` | `bdilide` | no | SELECT | L49 |
| `sl_retlide` | `bdilide` | no | SELECT | L65 |
| `sl_detlide` | `bdilide` | no | SELECT | L80 |
| `sl_constancias` | `bdilide` | no | SELECT | L95 |
| `sl_consat` | `bdilide` | no | SELECT | L112 |
| `sl_exentos` | `bdilide` | no | SELECT | L125 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `actualiza` | ACCION | actualiza | 🔵 CONVENCIÓN | nombre_sp |
| `rfc` | ENTIDAD | RFC (registro fiscal) | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?l` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `id` | ENTIDAD | identificador (de) | 🔵 CONVENCIÓN | nombre_sp |
| `?e` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?l`, `?e` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_actualizarfclide_pba`

| Campo | Valor |
|-------|-------|
| **Dominio** | D15 · `bdilide` · LIDE / PLD |
| **Archivo fuente** | `bdilide_sp_actualizarfclide_pba.sql` |
| **LOC (1er CREATE)** | 149 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "actualiza RFC y identificador (PBA — sufijo de SPs para Pruebas; confirmado por SME)" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `actualiza` → `UPDATE` encontrado en el cuerpo · `confirma` → `SELECT` encontrado en el cuerpo · `confirma` → `UPDATE` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=4 · INFERIDO=0 · SINTÉTICO=2 / 7 términos |

### Firma

```sql
CREATE PROCEDURE sp_actualizarfclide_pba(
  cNumCte                      CHAR(20)
  cRfcAnt                      CHAR(13)
  cRfcActual                   CHAR(13)
  cAnioMes1                    CHAR(6)
  cAnioMes2                    CHAR(6)
) RETURNING CHAR(5) -- DATOS A REGRESAR --
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `cNumCte` | `CHAR(20)` | — | — |
| `cRfcAnt` | `CHAR(13)` | `rfc`=RFC (registro fiscal) | ✅ CÓDIGO |
| `cRfcActual` | `CHAR(13)` | `rfc`=RFC (registro fiscal) | ✅ CÓDIGO |
| `cAnioMes1` | `CHAR(6)` | — | — |
| `cAnioMes2` | `CHAR(6)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `iSql_Err` | `INTEGER` | L9 |
| `cCodRet` | `CHAR(5)` | L10 |
| `cAnioConsat` | `CHAR(4)` | L11 |
| `vexiste1` | `INTEGER` | L12 |
| `vexiste2` | `INTEGER` | L13 |
| `vexiste3` | `INTEGER` | L14 |
| `vexiste4` | `INTEGER` | L15 |
| `vexiste5` | `INTEGER` | L16 |
| `vexiste6` | `INTEGER` | L17 |
| `vexiste7` | `INTEGER` | L18 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sl_movefec` | `bdilide` | no | SELECT | L49 |
| `sl_retlide` | `bdilide` | no | SELECT | L67 |
| `sl_detlide` | `bdilide` | no | SELECT | L83 |
| `sl_constancias` | `bdilide` | no | SELECT | L99 |
| `sl_consat` | `bdilide` | no | SELECT | L117 |
| `sl_exentos` | `bdilide` | no | SELECT | L131 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `actualiza` | ACCION | actualiza | 🔵 CONVENCIÓN | nombre_sp |
| `rfc` | ENTIDAD | RFC (registro fiscal) | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?l` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `id` | ENTIDAD | identificador (de) | 🔵 CONVENCIÓN | nombre_sp |
| `?e_` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `pba` | MODIF | PBA — sufijo de SPs para Pruebas; confirmado por SME (Guerra | 🔵 CONVENCIÓN | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?l`, `?e_` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_acumulacionoperaciones`

| Campo | Valor |
|-------|-------|
| **Dominio** | D15 · `bdilide` · LIDE / PLD |
| **Archivo fuente** | `bdilide_sp_acumulacionoperaciones.sql` |
| **LOC (1er CREATE)** | 229 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "operaciones" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 12 tabla(s) con operaciones: INSERT, UPDATE, DELETE, SELECT |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=1 / 3 términos |

### Historia del SP

| Tipo | Valor |
|------|-------|
| AUTOR | Aymme Osuna |
| ACTIVIDAD | Realizar el redondeo en el cálculo |
| FECHA | 06/NOV/2008 |

### Firma

```sql
CREATE PROCEDURE sp_acumulacionoperaciones(
  pEmpresa                     CHAR(3)
  pFechaProceso                DATE
  pCve_Usuario                 CHAR(8)
  pFechaultimodia              DATE
) RETURNING CHAR(4)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pEmpresa` | `CHAR(3)` | — | — |
| `pFechaProceso` | `DATE` | — | — |
| `pCve_Usuario` | `CHAR(8)` | — | — |
| `pFechaultimodia` | `DATE` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vcCodRet` | `CHAR(4)` | L19 |
| `vcAnioMes2` | `CHAR(6)` | L20 |
| `vcNumCte` | `CHAR(20)` | L21 |
| `vcRfc` | `CHAR(13)` | L22 |
| `vcUserInsert` | `CHAR(8)` | L23 |
| `vdFechaInsert` | `DATE` | L24 |
| `vcProceso` | `CHAR(10)` | L25 |
| `vcStatusEODeb` | `INTEGER` | L26 |
| `vcStatusEOCrd` | `INTEGER` | L27 |
| `vcStatus` | `CHAR(1)` | L28 |
| `vmImpTot` | `MONEY(16,2)` | L29 |
| `vdFechaMov` | `DATE` | L30 |
| `vcTipoCta` | `CHAR(1)` | L31 |
| `vmMontLimite` | `MONEY(16,2)` | L32 |
| `viPorcaRecau` | `MONEY(16,2)` | L33 |
| `vsqlerr` | `INTEGER` | L34 |
| `vdAnioMesAntTemp` | `DATE` | L35 |
| `vcAnioMesAnt` | `CHAR(6)` | L36 |
| `vmImpTotDep` | `MONEY` | L37 |
| `vmImpTotIde` | `MONEY` | L38 |
| `vmImpGrabar` | `MONEY` | L39 |
| `vmMontoRecaudar` | `MONEY` | L40 |
| `vcNumReferencia` | `CHAR(20)` | L41 |
| `viFalgRecau` | `INTEGER` | L42 |
| `vdUltimoDiaMes` | `DATE` | L43 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_fechas` | `bdinteg` | ⚠️ sí | SELECT | L92 |
| `sl_procesos` | `bdilide` | no | SELECT | L102 |
| `sl_retlide` | `bdilide` | no | SELECT | L147 |
| `sl_retlide` | `bdilide` | no | DELETE | L147 |
| `sl_procesos` | `bdilide` | no | INSERT | L152 |
| `sl_parametros` | `bdilide` | no | SELECT | L159 |
| `sl_movefec` | `bdilide` | no | SELECT | L181 |
| `si_cliente` | `bdinteg` | ⚠️ sí | SELECT | L187 |
| `sl_retlide` | `bdilide` | no | INSERT | L201 |
| `sl_movefec` | `bdilide` | no | UPDATE | L205 |
| `sl_procesos` | `bdilide` | no | UPDATE | L215 |
| `sx_contproc` | `bdinteg` | ⚠️ sí | INSERT | L221 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L85 | VALIDACIÓN_NULL | `IF pFechaProceso IS  NULL OR pFechaProceso = "" THEN` |  |
| L126 | FÓRMULA | `LET  vcCodRet = "018"; -- El proceso de recaudacion diaria ya se ejecuto anteriormente` |  |
| L162 | VALIDACIÓN_NULL | `IF vmMontLimite = 0 OR vmMontLimite IS NULL THEN` |  |
| L171 | VALIDACIÓN_NULL | `IF viPorcaRecau = 0 OR viPorcaRecau IS NULL THEN` |  |
| L192 | FÓRMULA | `LET vmImpGrabar  = vmImpTotIde - vmMontLimite;` |  |
| L193 | FÓRMULA | `LET vmMontoRecaudar = vmImpGrabar * viPorcaRecau;` | 🔴 MONEY/aritmética financiera |
| L194 | FÓRMULA | `LET vmMontoRecaudar = ROUND(vmMontoRecaudar - 0.01); --- Esta linea se agrego para solucionar lo del` | 🔴 MONEY/aritmética financiera |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `?_acumulacion` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `operaciones` | ENTIDAD | operaciones (plural) | ✅ CÓDIGO | nombre_sp, texto_cuerpo |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_acumulacion` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_cargainformesat`

| Campo | Valor |
|-------|-------|
| **Dominio** | D15 · `bdilide` · LIDE / PLD |
| **Archivo fuente** | `bdilide_sp_cargainformesat.sql` |
| **LOC (1er CREATE)** | 166 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "carga información y Mesa de Control — equipo de revisión y autorización de solicitudes de crédito; status codes MC/CM; valida comprobantes de ingreso; comentario explícito en código" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `valida` → `IF` encontrado en el cuerpo · `valida` → `RETURN` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=2 / 6 términos |

### Firma

```sql
CREATE PROCEDURE sp_cargainformesat(
) RETURNING CHAR(6), CHAR(60)
```

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(6)` | L5 |
| `cCodRet2` | `CHAR(6)` | L6 |
| `iSql_Err` | `INTEGER` | L7 |
| `cMensajeRetorno` | `CHAR(60)` | L8 |
| `cFechaHoy` | `CHAR(8)` | L9 |
| `dFechaHoy2` | `DATE` | L10 |
| `cNombreArchivo` | `CHAR(20)` | L11 |
| `cNombreArchivoCtrl` | `CHAR(20)` | L12 |
| `cSQL` | `CHAR(350)` | L13 |
| `cDirectorio` | `CHAR(50)` | L14 |
| `cCASFIM` | `CHAR(20)` | L15 |
| `iRegs` | `INTEGER` | L16 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sc_fechas` | `bdicheq` | ⚠️ sí | SELECT | L51 |
| `sl_procesos` | `bdilide` | no | SELECT | L56 |
| `sl_parametros` | `bdilide` | no | SELECT | L68 |
| `sl_archivoconsulta` | `bdilide` | no | SELECT | L76 |
| `sl_archivoconsulta` | `bdilide` | no | DELETE | L76 |
| `sl_archivocontrol` | `bdilide` | no | SELECT | L77 |
| `sl_archivocontrol` | `bdilide` | no | DELETE | L77 |
| `sl_archivoconsulta` | `bdilide` | no | INSERT | L93 |
| `sl_archivocontrol` | `bdilide` | no | INSERT | L118 |
| `sl_procesos` | `bdilide` | no | INSERT | L137 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_validaarchivoinforme` | `bdilide` | no | L141 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L87 | FÓRMULA | `LET cSQL = "sed -e 's/EOF$//g' "\|\|TRIM(cDirectorio)\|\|TRIM(cNombreArchivo)\|\|" > "\|\|TRIM(cDire` |  |
| L102 | FÓRMULA | `LET cSQL = "rm -rf "\|\|TRIM(cDirectorio)\|\|""\|\| TRIM(cNombreArchivo)\|\|'N';` |  |
| L112 | FÓRMULA | `LET cSQL = "sed -e 's/EOF$//g' "\|\|TRIM(cDirectorio)\|\|TRIM(cNombreArchivoCtrl)\|\|" > "\|\|TRIM(c` |  |
| L127 | FÓRMULA | `LET cSQL = "rm -rf "\|\|TRIM(cDirectorio)\|\|""\|\| TRIM(cNombreArchivoCtrl)\|\|'N';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `carga` | ACCION | carga / ingresa | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `info` | ENTIDAD | información | 🔵 CONVENCIÓN | nombre_sp |
| `?r` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `mesa` | ENTIDAD | Mesa de Control — equipo de revisión y autorización de solic | 🔵 CONVENCIÓN | nombre_sp |
| `?t` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?r`, `?t` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_cargaresultadosat`

| Campo | Valor |
|-------|-------|
| **Dominio** | D15 · `bdilide` · LIDE / PLD |
| **Archivo fuente** | `bdilide_sp_cargaresultadosat.sql` |
| **LOC (1er CREATE)** | 174 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "carga resultado · SAT — Servicio de Administración Tributaria" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 1 llamada(s): `sp_validaarchivoresultado` |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=0 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_cargaresultadosat(
) RETURNING CHAR(6), CHAR(60)
```

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(6)` | L5 |
| `cCodRet2` | `CHAR(6)` | L6 |
| `iSql_Err` | `INTEGER` | L7 |
| `cMensajeRetorno` | `CHAR(60)` | L8 |
| `cFechaHoy` | `CHAR(8)` | L9 |
| `dFechaHoy2` | `DATE` | L10 |
| `cNombreArchivo` | `CHAR(20)` | L11 |
| `cNombreArchivoCtrl` | `CHAR(20)` | L12 |
| `cSQL` | `CHAR(350)` | L13 |
| `cDirectorio` | `CHAR(50)` | L14 |
| `cCASFIM` | `CHAR(20)` | L15 |
| `iRegs` | `INTEGER` | L16 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sc_fechas` | `bdicheq` | ⚠️ sí | SELECT | L54 |
| `sl_procesos` | `bdilide` | no | SELECT | L59 |
| `sl_parametros` | `bdilide` | no | SELECT | L71 |
| `sl_archivoconsulta` | `bdilide` | no | SELECT | L78 |
| `sl_archivoconsulta` | `bdilide` | no | DELETE | L78 |
| `sl_archivocontrol` | `bdilide` | no | SELECT | L79 |
| `sl_archivocontrol` | `bdilide` | no | DELETE | L79 |
| `sl_archivoconsulta` | `bdilide` | no | INSERT | L95 |
| `sl_archivocontrol` | `bdilide` | no | INSERT | L124 |
| `sl_procesos` | `bdilide` | no | INSERT | L146 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_validaarchivoresultado` | `bdilide` | no | L149 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L88 | FÓRMULA | `LET cSQL = "sed -e 's/EOF$//g' "\|\|TRIM(cDirectorio)\|\|TRIM(cNombreArchivo)\|\|" > "\|\|TRIM(cDire` |  |
| L106 | FÓRMULA | `LET cSQL = "rm -rf "\|\|TRIM(cDirectorio)\|\|""\|\| TRIM(cNombreArchivo)\|\|'N';` |  |
| L117 | FÓRMULA | `LET cSQL = "sed -e 's/EOF$//g' "\|\|TRIM(cDirectorio)\|\|TRIM(cNombreArchivoCtrl)\|\|" > "\|\|TRIM(c` |  |
| L135 | FÓRMULA | `LET cSQL = "rm -rf "\|\|TRIM(cDirectorio)\|\|""\|\| TRIM(cNombreArchivoCtrl)\|\|'N';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `carga` | ACCION | carga / ingresa | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `resultado` | ENTIDAD | resultado | 🔵 CONVENCIÓN | nombre_sp |
| `sat` | REG | SAT — Servicio de Administración Tributaria (CFDI, ISR, IVA) | 🔵 CONVENCIÓN | nombre_sp |

---

## `sp_checacurp`

| Campo | Valor |
|-------|-------|
| **Dominio** | D15 · `bdilide` · LIDE / PLD |
| **Archivo fuente** | `bdilide_sp_checacurp.sql` |
| **LOC (1er CREATE)** | 96 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "sp_checacurp" `[partial]` |
| **Propósito verificado** | ❓ NO_VERIFICABLE — Propósito inferido; sin evidencia DML para verificar |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=1 · INFERIDO=1 · SINTÉTICO=2 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_checacurp(
  pCurp                        CHAR(18)
  pRfc                         CHAR(13)
) RETURNING CHAR(6),char(80)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pCurp` | `CHAR(18)` | — | — |
| `pRfc` | `CHAR(13)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vcRfc` | `CHAR(13)` | L5 |
| `vcNumero` | `CHAR(10)` | L6 |
| `I` | `SMALLINT` | L7 |
| `J` | `SMALLINT` | L8 |
| `vcConsonantes` | `CHAR(30)` | L9 |
| `iConsonantes` | `smallint` | L10 |
| `iNumeros` | `smallint` | L11 |
| `cSiglasEdos` | `char(2)` | L12 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L49 | FÓRMULA | `LET iConsonantes = iConsonantes + 1;` |  |
| L53 | FÓRMULA | `LET iConsonantes = iConsonantes + 1;` |  |
| L57 | FÓRMULA | `LET iConsonantes = iConsonantes + 1;` |  |
| L60 | FÓRMULA | `LET J = J + 1;` |  |
| L69 | FÓRMULA | `LET iNumeros = iNumeros + 1;` |  |
| L73 | FÓRMULA | `LET iNumeros = iNumeros + 1;` |  |
| L76 | FÓRMULA | `LET I = I + 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `?_che` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `cac` | PREFIJO | familia crédito (CAC) | 🟡 INFERIDO | nombre_sp |
| `?urp` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_che`, `?urp` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_conrecaudaciones`

| Campo | Valor |
|-------|-------|
| **Dominio** | D15 · `bdilide` · LIDE / PLD |
| **Archivo fuente** | `bdilide_sp_conrecaudaciones.sql` |
| **LOC (1er CREATE)** | 46 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "consulta auditoría" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=2 · INFERIDO=2 · SINTÉTICO=1 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_conrecaudaciones(
  pNumCte                      CHAR(20)
  pPeriodo                     CHAR(6)
  pTipo                        CHAR(2)
) RETURNING CHAR(5), DATE, CHAR(20), CHAR(6), MONEY(10,2)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pNumCte` | `CHAR(20)` | — | — |
| `pPeriodo` | `CHAR(6)` | — | — |
| `pTipo` | `CHAR(2)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(5)` | L5 |
| `dFecha` | `DATE` | L6 |
| `cNumCta` | `CHAR(20)` | L7 |
| `cPeriodo` | `CHAR(6)` | L8 |
| `mImpuestoRec` | `MONEY(10,2)` | L9 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sl_detlide` | `bdilide` | no | SELECT | L31 |
| `systabnames` | `sysmaster` | ⚠️ sí | SELECT | L37 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L18 | VALIDACIÓN_NULL | `IF pNumCte = "" OR pNumCte IS NULL THEN` |  |
| L22 | VALIDACIÓN_NULL | `IF pPeriodo = "" OR pPeriodo IS NULL THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `con` | ACCION | consulta | 🟡 INFERIDO | nombre_sp |
| `rec` | ACCION | recepción / recibe | 🔵 CONVENCIÓN | nombre_sp |
| `aud` | ENTIDAD | auditoría | 🟡 INFERIDO | nombre_sp |
| `?aciones` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?aciones` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_consalperant`

| Campo | Valor |
|-------|-------|
| **Dominio** | D15 · `bdilide` · LIDE / PLD |
| **Archivo fuente** | `bdilide_sp_consalperant.sql` |
| **LOC (1er CREATE)** | 38 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "consulta (anterior)" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=1 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_consalperant(
  pNumCte                      CHAR(20)
  pPeriodo1                    CHAR(6)
  pPeriodo2                    CHAR(6)
) RETURNING CHAR(5), MONEY
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pNumCte` | `CHAR(20)` | — | — |
| `pPeriodo1` | `CHAR(6)` | — | — |
| `pPeriodo2` | `CHAR(6)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vCodRet` | `CHAR(5)` | L6 |
| `vcPeriodosAnt` | `MONEY` | L7 |
| `vsqlerr` | `integer` | L8 |
| `vcIniciaTran` | `CHAR(1)` | L9 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sl_detlide` | `bdilide` | no | SELECT | L32 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `cons` | ACCION | consulta | 🔵 CONVENCIÓN | nombre_sp |
| `?alper` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `ant` | MODIF | anterior | 🔵 CONVENCIÓN | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?alper` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_consimpide`

| Campo | Valor |
|-------|-------|
| **Dominio** | D15 · `bdilide` · LIDE / PLD |
| **Archivo fuente** | `bdilide_sp_consimpide.sql` |
| **LOC (1er CREATE)** | 65 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "consulta Impago — pago vencido o fallido; confirmado: n_impagos_consec y identificador" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo · `confirma` → `SELECT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=4 · INFERIDO=0 · SINTÉTICO=1 / 5 términos |

### Historia del SP

| Tipo | Valor |
|------|-------|
| ACTIVIDAD | Consulta importe acumulado, importe excedente, importe recaudado |
| FECHA | 15-08-2008 |

### Firma

```sql
CREATE PROCEDURE sp_consimpide(
  pNumeroCliente               CHAR(20)
  pPeriodo                     CHAR(6)
) RETURNING CHAR(3), --Codigo de Retorno
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pNumeroCliente` | `CHAR(20)` | — | — |
| `pPeriodo` | `CHAR(6)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vcCodRet` | `CHAR(3)` | L16 |
| `vmImpGrabado` | `MONEY(10,2)` | L17 |
| `vmImpArecaudar` | `MONEY(10,2)` | L18 |
| `vmImpRecaudado` | `MONEY(10,2)` | L19 |
| `vmImpPendiente` | `MONEY(10,2)` | L20 |
| `vmImpAcumulado` | `MONEY(10,2)` | L21 |
| `vsqlerr` | `INTEGER` | L22 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sl_retlide` | `bdilide` | no | SELECT | L54 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L46 | VALIDACIÓN_NULL | `IF pNumeroCliente IS NULL OR pNumeroCliente = "" THEN` |  |
| L47 | FÓRMULA | `LET vcCodRet = "100"; --Parametro Invalido` |  |
| L50 | FÓRMULA | `LET vcCodRet = "100"; --Parametro Invalido` |  |
| L60 | FÓRMULA | `LET vcCodRet = "200"; --Numero de Cliente no existe para el mes consultado` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `cons` | ACCION | consulta | 🔵 CONVENCIÓN | nombre_sp |
| `imp` | ENTIDAD | Impago — pago vencido o fallido; confirmado: n_impagos_conse | 🔵 CONVENCIÓN | nombre_sp |
| `id` | ENTIDAD | identificador (de) | 🔵 CONVENCIÓN | nombre_sp |
| `?e` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?e` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_consultacterfc`

| Campo | Valor |
|-------|-------|
| **Dominio** | D15 · `bdilide` · LIDE / PLD |
| **Archivo fuente** | `bdilide_sp_consultacterfc.sql` |
| **LOC (1er CREATE)** | 116 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "consulta cliente y RFC" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=0 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_consultacterfc(
  pNumCte                      CHAR(20)
) RETURNING CHAR(6),CHAR(20),CHAR(100),CHAR(1),CHAR(1),CHAR(13),INTEGER
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pNumCte` | `CHAR(20)` | `cte`=cliente | 🔵 CONVENCIÓN |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(6)` | L5 |
| `isql_err` | `INTEGER` | L6 |
| `cMensaje` | `CHAR(100)` | L7 |
| `cExentoIDE` | `CHAR(1)` | L8 |
| `cEstado` | `CHAR(1)` | L9 |
| `cRfc` | `CHAR(13)` | L10 |
| `cRfc_alterno` | `CHAR(13)` | L11 |
| `cRfc_final` | `CHAR(13)` | L12 |
| `cCuenta` | `CHAR(20)` | L13 |
| `iExentos` | `INTEGER` | L14 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sc_maechq` | `bdicheq` | ⚠️ sí | SELECT | L49 |
| `sl_exentos` | `bdilide` | no | SELECT | L56 |
| `si_cliente` | `bdinteg` | ⚠️ sí | SELECT | L78 |
| `sl_consat` | `bdilide` | no | SELECT | L89 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L41 | VALIDACIÓN_NULL | `IF TRIM(pNumCte) = '' OR pNumCte IS NULL THEN` |  |
| L73 | VALIDACIÓN_NULL | `IF TRIM(cRfc) = '' OR cRfc IS NULL THEN` |  |
| L81 | VALIDACIÓN_NULL | `IF cRfc_alterno IS NULL OR cRfc_alterno = '' THEN` |  |
| L103 | VALIDACIÓN_NULL | `IF cEstado IS NULL THEN` |  |
| L107 | VALIDACIÓN_NULL | `IF cExentoIDE IS NULL THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `consulta` | ACCION | consulta / lee | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `cte` | ENTIDAD | cliente | 🔵 CONVENCIÓN | nombre_sp |
| `rfc` | ENTIDAD | RFC (registro fiscal) | ✅ CÓDIGO | nombre_sp, texto_cuerpo |

---

## `sp_consultaparamlide`

| Campo | Valor |
|-------|-------|
| **Dominio** | D15 · `bdilide` · LIDE / PLD |
| **Archivo fuente** | `bdilide_sp_consultaparamlide.sql` |
| **LOC (1er CREATE)** | 216 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "consulta parámetro y identificador" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=2 / 6 términos |

### Firma

```sql
CREATE PROCEDURE sp_consultaparamlide(
) RETURNING CHAR(3) 	AS Codigo_Retorno,
```

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(3)` | L21 |
| `dFecha_hoy` | `DATE` | L22 |
| `cServer_ifx` | `CHAR(50)` | L23 |
| `cUsuario_ifx` | `CHAR(50)` | L24 |
| `cPassword_ifx` | `CHAR(50)` | L25 |
| `cRuta_Origen_ifx` | `CHAR(50)` | L26 |
| `cPC_Envio_SAT` | `CHAR(50)` | L27 |
| `cUsuario_Envio_SAT` | `CHAR(50)` | L28 |
| `cRuta_Envio_SAT` | `CHAR(50)` | L29 |
| `cPC_Recibo_SAT` | `CHAR(50)` | L30 |
| `cUsuario_Recibo_SAT` | `CHAR(50)` | L31 |
| `cPassword_Recibo_SAT` | `CHAR(50)` | L32 |
| `cRuta_Recibo_SAT` | `CHAR(50)` | L33 |
| `cNum_Max_Ejec` | `CHAR(50)` | L34 |
| `cCasFim` | `CHAR(50)` | L35 |
| `cRuta_Recibo_Envio` | `CHAR(50)` | L36 |
| `iSQLerr` | `INTEGER` | L37 |
| `iRegsResulSat` | `INTEGER` | L38 |
| `iRegsInforSat` | `INTEGER` | L39 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sc_fechas` | `bdicheq` | ⚠️ sí | SELECT | L84 |
| `sl_parametros` | `bdilide` | no | SELECT | L89 |
| `sl_procesos` | `bdilide` | no | SELECT | L187 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L199 | VALIDACIÓN_NULL | `IF cServer_ifx IS NULL OR cServer_ifx = '' OR cUsuario_ifx IS NULL OR cUsuario_ifx = '' OR cPassword` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `consulta` | ACCION | consulta / lee | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `param` | ENTIDAD | parámetro | 🔵 CONVENCIÓN | nombre_sp |
| `?l` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `id` | ENTIDAD | identificador (de) | 🔵 CONVENCIÓN | nombre_sp |
| `?e` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?l`, `?e` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_consultarecaudacioneslide`

| Campo | Valor |
|-------|-------|
| **Dominio** | D15 · `bdilide` · LIDE / PLD |
| **Archivo fuente** | `bdilide_sp_consultarecaudacioneslide.sql` |
| **LOC (1er CREATE)** | 46 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "consultar auditoría y identificador" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=3 · INFERIDO=1 · SINTÉTICO=3 / 7 términos |

### Firma

```sql
CREATE PROCEDURE sp_consultarecaudacioneslide(
  cNumCte                      CHAR(20)
  cRfc                         CHAR(13)
  cAnioMes1                    CHAR(6)
  cAnioMes2                    CHAR(6)
) RETURNING CHAR(5) -- DATOS A REGRESAR --
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `cNumCte` | `CHAR(20)` | — | — |
| `cRfc` | `CHAR(13)` | — | — |
| `cAnioMes1` | `CHAR(6)` | — | — |
| `cAnioMes2` | `CHAR(6)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `iSql_Err` | `INTEGER` | L5 |
| `cCodRet` | `CHAR(5)` | L6 |
| `vexiste` | `INTEGER` | L7 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sl_retlide` | `bdilide` | no | SELECT | L31 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `consultar` | ACCION | consultar | 🔵 CONVENCIÓN | nombre_sp |
| `?ec` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `aud` | ENTIDAD | auditoría | 🟡 INFERIDO | nombre_sp |
| `?acionesl` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `id` | ENTIDAD | identificador (de) | 🔵 CONVENCIÓN | nombre_sp |
| `?e` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?ec`, `?acionesl`, `?e` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_consultaslconsat`

| Campo | Valor |
|-------|-------|
| **Dominio** | D15 · `bdilide` · LIDE / PLD |
| **Archivo fuente** | `bdilide_sp_consultaslconsat.sql` |
| **LOC (1er CREATE)** | 58 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "consulta" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=2 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_consultaslconsat(
  cRfc                         CHAR(13)
  cAnio                        CHAR(6)
) RETURNING CHAR(5),    -- Codigo de Retorno
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `cRfc` | `CHAR(13)` | — | — |
| `cAnio` | `CHAR(6)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `iSql_Err` | `INTEGER` | L8 |
| `cCodRet` | `CHAR(5)` | L9 |
| `dFechaCons` | `DATE` | L10 |
| `cExento` | `CHAR(1)` | L11 |
| `cEstado` | `CHAR(1)` | L12 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sl_consat` | `bdilide` | no | SELECT | L39 |
| `sl_exentos` | `bdilide` | no | SELECT | L45 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L48 | VALIDACIÓN_NULL | `IF cExento is null  THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `consulta` | ACCION | consulta / lee | 🔵 CONVENCIÓN | nombre_sp |
| `?sl` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `cons` | ACCION | consulta | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?at` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?sl`, `?at` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_correccionrecaudacion`

| Campo | Valor |
|-------|-------|
| **Dominio** | D15 · `bdilide` · LIDE / PLD |
| **Archivo fuente** | `bdilide_sp_correccionrecaudacion.sql` |
| **LOC (1er CREATE)** | 438 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "recepción auditoría" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 15 tabla(s) con operaciones: INSERT, UPDATE, SELECT |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=3 · INFERIDO=1 · SINTÉTICO=3 / 7 términos |

### Historia del SP

| Tipo | Valor |
|------|-------|
| AUTOR | Aymme Osuna y Alejandro Osuna |
| PROYECTO | Correción Recaudacion del LIDE |
| ACTIVIDAD | Ejecuta el proceso de correción de movimientos que no se debieron de haberce cobrado al cliente en un periodo de |
| FECHA | Julio de 2008 |
| AUTOR | Alejandro Osuna |
| PROYECTO | Correción Recaudacion del LIDE |
| ACTIVIDAD | Se modifico para tomar en cuenta a las diferente tipos de personas y grabar en la carta de devolucion.. |
| FECHA | Agosto de 2008 |
| AUTOR | Alejandro Osuna |
| PROYECTO | Correción Recaudacion del LIDE |
| ACTIVIDAD | Se modifico para realizar el redondeo del calculo del IDE.. |
| FECHA | 06 Noviembre de 2008 |

### Firma

```sql
CREATE PROCEDURE sp_correccionrecaudacion(
  pNumeroCliente               CHAR(20)
  pAnoMes                      CHAR(6)
  pNumeroFolio                 CHAR(12)
  pTipoPendiente               CHAR(1)
  pUsuario                     CHAR(8)
) RETURNING CHAR(5), CHAR(100)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pNumeroCliente` | `CHAR(20)` | — | — |
| `pAnoMes` | `CHAR(6)` | — | — |
| `pNumeroFolio` | `CHAR(12)` | — | — |
| `pTipoPendiente` | `CHAR(1)` | — | — |
| `pUsuario` | `CHAR(8)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(5)` | L29 |
| `sql_err` | `SMALLINT` | L30 |
| `cMensaje` | `CHAR(100)` | L31 |
| `cRfc` | `CHAR(13)` | L32 |
| `cNombre1` | `CHAR(26)` | L33 |
| `cNombre2` | `CHAR(26)` | L34 |
| `cApell_Paterno` | `CHAR(26)` | L35 |
| `cApell_Materno` | `CHAR(26)` | L36 |
| `cNombre` | `CHAR(60)` | L37 |
| `mImp_Acumulado` | `MONEY(16,2)` | L38 |
| `mImp_Recaudado` | `MONEY(16,2)` | L39 |
| `mImp_Exceso` | `MONEY(16,2)` | L40 |
| `dFecha_Insert` | `DATE` | L41 |
| `mSumaGrid` | `MONEY(16,2)` | L42 |
| `mSumaMov` | `MONEY(16,2)` | L43 |
| `mPorciento` | `MONEY(16,2)` | L44 |
| `mTotalDep` | `MONEY(16,2)` | L45 |
| `mLimiteLide` | `MONEY(16,2)` | L46 |
| `mGravado` | `MONEY(16,2)` | L47 |
| `sNum_Serial` | `INTEGER` | L48 |
| `cRef_Ret` | `CHAR(20)` | L49 |
| `cTipo_Cta` | `CHAR(1)` | L50 |
| `dFecha_Mov` | `DATE` | L51 |
| `mImp_Tot_Dep` | `MONEY(16,2)` | L52 |
| `mImp_Ide` | `MONEY(16,2)` | L53 |
| *…34 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sl_cartadev` | `bdilide` | no | SELECT | L174 |
| `si_cliente` | `bdinteg` | ⚠️ sí | SELECT | L185 |
| `sl_retlide` | `bdilide` | no | SELECT | L201 |
| `sl_movgrid` | `bdilide` | no | SELECT | L205 |
| `sl_movefec` | `bdilide` | no | SELECT | L207 |
| `sl_parametros` | `bdilide` | no | SELECT | L211 |
| `sl_cartadev` | `bdilide` | no | INSERT | L229 |
| `sl_histmov` | `bdilide` | no | INSERT | L244 |
| `sl_histret` | `bdilide` | no | INSERT | L256 |
| `sl_detlide` | `bdilide` | no | SELECT | L298 |
| `sl_histdet` | `bdilide` | no | INSERT | L302 |
| `sl_retlide` | `bdilide` | no | UPDATE | L306 |
| `sl_histcons` | `bdilide` | no | INSERT | L312 |
| `sl_constancias` | `bdilide` | no | SELECT | L314 |
| `sl_constancias` | `bdilide` | no | UPDATE | L400 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L136 | FÓRMULA | `LET cPosit  = -1;` |  |
| L157 | VALIDACIÓN_NULL | `IF (pNumeroCliente = "") OR (pNumeroCliente is NULL) THEN` |  |
| L214 | FÓRMULA | `LET mTotalDep = mSumaMov - mSumaGrid;` |  |
| L216 | FÓRMULA | `LET mGravado = mTotalDep - mLimiteLide;` |  |
| L222 | FÓRMULA | `LET mPorciento = (mGravado) * (0.02);` |  |
| L223 | FÓRMULA | `LET mPorciento = ( mPorciento) - (.01);` |  |
| L226 | FÓRMULA | `LET mImp_Exceso = mImp_Recaudado - mPorciento;` |  |
| L285 | FÓRMULA | `LET mTotalDep = mSumaMov - mSumaGrid;` |  |
| L287 | FÓRMULA | `LET mGravado = mTotalDep - mLimiteLide;` |  |
| L341 | FÓRMULA | `LET mPorciento = (mGravado) * (0.02);` |  |
| L342 | FÓRMULA | `LET mPorciento = (mPorciento) - (.01);` |  |
| L345 | FÓRMULA | `LET mImp_Exceso = mImp_Recaudado - mPorciento;` |  |
| L382 | FÓRMULA | `LET mImpPendFIn = mImpAreFin - mImpRecFin;` |  |
| L416 | FÓRMULA | `LET    mImpPenConst = mImpDetConst - mImpRecConst;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `?_cor` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `rec` | ACCION | recepción / recibe | 🔵 CONVENCIÓN | nombre_sp |
| `?cion` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `rec` | ACCION | recepción / recibe | 🔵 CONVENCIÓN | nombre_sp |
| `aud` | ENTIDAD | auditoría | 🟡 INFERIDO | nombre_sp |
| `?acion` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_cor`, `?cion`, `?acion` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_eliminaarchivo`

| Campo | Valor |
|-------|-------|
| **Dominio** | D15 · `bdilide` · LIDE / PLD |
| **Archivo fuente** | `bdilide_sp_eliminaarchivo.sql` |
| **LOC (1er CREATE)** | 316 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "elimina archivo" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `elimina` → `DELETE` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=0 / 3 términos |

### Firma

```sql
CREATE PROCEDURE sp_eliminaarchivo(
  cTipoArchivo                 CHAR(2)
  pUsuario                     CHAR(8)
  cNomArchivo                  VARCHAR (20)
  cArchivoControl              VARCHAR (20)
) RETURNING CHAR(6)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `cTipoArchivo` | `CHAR(2)` | `archivo`=archivo | ✅ CÓDIGO |
| `pUsuario` | `CHAR(8)` | — | — |
| `cNomArchivo` | `VARCHAR (20)` | `archivo`=archivo | ✅ CÓDIGO |
| `cArchivoControl` | `VARCHAR (20)` | `archivo`=archivo | ✅ CÓDIGO |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vsqlerr` | `INTEGER` | L4 |
| `cCodRet` | `CHAR(6)` | L5 |
| `sRutaArchivo` | `CHAR(30)` | L6 |
| `vsSQLC` | `CHAR (1000)` | L7 |
| `cNombre` | `CHAR(20)` | L8 |
| `cNombreControl` | `CHAR(20)` | L9 |
| `cNombreAcuseA` | `CHAR(20)` | L10 |
| `cNombreAcuseN` | `CHAR(20)` | L11 |
| `cPrefijo` | `char(2)` | L12 |
| `cPrefijoControl` | `char(2)` | L13 |
| `pTipoError` | `CHAR(1)` | L14 |
| `pSpLlamado` | `CHAR(40)` | L15 |
| `pMostrado` | `CHAR(1)` | L16 |
| `cNombreError` | `CHAR(20)` | L17 |
| `sBanderaError` | `char(2)` | L18 |
| `cErrorSP` | `CHAR(6)` | L19 |
| `pMensaje` | `CHAR(100)` | L20 |
| `cFechaSer` | `CHAR(10)` | L21 |
| `vsSQL1C` | `CHAR (300)` | L22 |
| `vsSQL2C` | `CHAR (400)` | L23 |
| `vsSQL3C` | `CHAR (150)` | L24 |
| `vIpDest` | `CHAR(30)` | L25 |
| `vUsuarioDestino` | `CHAR(30)` | L26 |
| `cClaveBan` | `CHAR(5)` | L27 |
| `cLetraInicial` | `CHAR(1)` | L28 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sl_archsat` | `bdilide` | no | UPDATE | L64 |
| `sl_parametros` | `bdilide` | no | SELECT | L91 |
| `si_fechas` | `bdinteg` | ⚠️ sí | SELECT | L97 |
| `systabnames` | `sysmaster` | ⚠️ sí | SELECT | L240 |
| `sl_procesos` | `bdilide` | no | INSERT | L258 |
| `sl_acuse` | `bdilide` | no | INSERT | L260 |
| `sl_acuse` | `bdilide` | no | SELECT | L263 |
| `sl_archsat` | `bdilide` | no | INSERT | L283 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_grabarerrores` | `bdilide` | no | L67 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `elimina` | ACCION | elimina | 🔵 CONVENCIÓN | nombre_sp |
| `archivo` | ENTIDAD | archivo | ✅ CÓDIGO | nombre_sp, texto_cuerpo |

---

## `sp_eliminacanceladoside`

| Campo | Valor |
|-------|-------|
| **Dominio** | D15 · `bdilide` · LIDE / PLD |
| **Archivo fuente** | `bdilide_sp_eliminacanceladoside.sql` |
| **LOC (1er CREATE)** | 81 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "elimina OS — Originación de Solicitudes y identificador" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `elimina` → `DELETE` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=4 · INFERIDO=1 · SINTÉTICO=2 / 7 términos |

### Historia del SP

| Tipo | Valor |
|------|-------|
| FECHA | 02-07-2008 |
| DESCRIPCION | El proceso se encarga de eliminar movimientos que esten cancelados |

### Firma

```sql
CREATE PROCEDURE sp_eliminacanceladoside(
) RETURNING CHAR(5), CHAR(80)
```

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vcCodRet` | `CHAR(5)` | L4 |
| `vcMensaje` | `CHAR(80)` | L5 |
| `SQL_ERR` | `INTEGER` | L6 |
| `ISAM_ERR` | `INTEGER` | L7 |
| `ERROR_INFO` | `VARCHAR(200)` | L8 |
| `vcNumCte` | `CHAR(20)` | L9 |
| `vcNumSerial` | `INTEGER` | L10 |
| `vcTipoCuenta` | `CHAR(1)` | L11 |
| `vcNumCuenta` | `CHAR(20)` | L12 |
| `vdFechaMov` | `DATE` | L13 |
| `vcCancelado` | `CHAR(1)` | L14 |
| `vcReversado` | `CHAR(1)` | L15 |
| `vcEmpresa` | `CHAR(3)` | L16 |
| `vcSucursal` | `CHAR(4)` | L17 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sl_movefec` | `bdilide` | no | SELECT | L54 |
| `sc_movhis` | `bdicheq` | ⚠️ sí | SELECT | L58 |
| `sl_movefec` | `bdilide` | no | DELETE | L62 |
| `sd_movhis` | `bdicred` | ⚠️ sí | SELECT | L67 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `elimina` | ACCION | elimina | 🔵 CONVENCIÓN | nombre_sp |
| `cancela` | ACCION | cancela | 🔵 CONVENCIÓN | nombre_sp |
| `?d` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `os` | ENTIDAD | OS — Originación de Solicitudes / subsistema de ofertas (sp_ | 🟡 INFERIDO | nombre_sp |
| `id` | ENTIDAD | identificador (de) | 🔵 CONVENCIÓN | nombre_sp |
| `?e` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?d`, `?e` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_eoetarjetacredito`

| Campo | Valor |
|-------|-------|
| **Dominio** | D15 · `bdilide` · LIDE / PLD |
| **Archivo fuente** | `bdilide_sp_eoetarjetacredito.sql` |
| **LOC (1er CREATE)** | 305 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "tarjeta y crédito" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 12 tabla(s) con operaciones: INSERT, SELECT |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=1 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_eoetarjetacredito(
  pEmpresa                     CHAR(3)
  pFechaProceso                DATE
  pCveUsuario                  CHAR(8)
) RETURNING CHAR(4)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pEmpresa` | `CHAR(3)` | — | — |
| `pFechaProceso` | `DATE` | — | — |
| `pCveUsuario` | `CHAR(8)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vmSalDisp` | `DECIMAL(14,2)` | L13 |
| `vcCodRet` | `CHAR(5)` | L14 |
| `vcAnioMes` | `CHAR(6)` | L15 |
| `vcNumCte` | `CHAR(20)` | L16 |
| `viNumSerial` | `INTEGER` | L17 |
| `vcRfc` | `CHAR(13)` | L18 |
| `vcTipoCta` | `CHAR(1)` | L19 |
| `vcNumCta` | `CHAR(20)` | L20 |
| `vdFechaMov` | `DATE` | L21 |
| `vmImpTotDep` | `MONEY(10,2)` | L22 |
| `vmImpIde` | `MONEY(10,2)` | L23 |
| `vcStatus` | `CHAR(1)` | L24 |
| `vcProceso` | `CHAR(10)` | L25 |
| `vmSaldo` | `MONEY(10,2)` | L26 |
| `vmSaldoAnt` | `MONEY(10,2)` | L27 |
| `vmNumTarjeta` | `CHAR(12)` | L28 |
| `vsqlerr` | `INTEGER` | L29 |
| `vcTransaccSuc` | `CHAR(4)` | L30 |
| `vcCodigoFun` | `CHAR(4)` | L31 |
| `viCodigoRef` | `INTEGER` | L32 |
| `vcTpoPersona` | `CHAR(2)` | L33 |
| `vcCodFun` | `CHAR(6)` | L34 |
| `vcCodRef` | `CHAR(6)` | L35 |
| `vcEmpresa` | `CHAR(3)` | L36 |
| `vcAplicaLide` | `CHAR(1)` | L37 |
| *…3 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sl_procesos` | `bdilide` | no | SELECT | L99 |
| `sl_movefec` | `bdilide` | no | SELECT | L126 |
| `sl_procesos` | `bdilide` | no | INSERT | L132 |
| `sd_maesdos` | `bdicred` | ⚠️ sí | SELECT | L139 |
| `sl_parametros` | `bdilide` | no | SELECT | L148 |
| `tmp_sdofavor` | `bdilide` | no | SELECT | L183 |
| `sd_movdia` | `bdicred` | ⚠️ sí | SELECT | L188 |
| `sd_maecred` | `bdicred` | ⚠️ sí | SELECT | L217 |
| `si_cliente` | `bdinteg` | ⚠️ sí | SELECT | L223 |
| `sl_exentos` | `bdilide` | no | SELECT | L254 |
| `sl_movefec` | `bdilide` | no | INSERT | L259 |
| `sx_contproc` | `bdinteg` | ⚠️ sí | INSERT | L295 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L87 | VALIDACIÓN_NULL | `IF pFechaProceso IS NULL  OR pFechaProceso = ""  then` |  |
| L104 | VALIDACIÓN_NULL | `IF vcStatus = "0" OR vcStatus IS NULL OR vcStatus = "" THEN` |  |
| L105 | FÓRMULA | `LET vcCodRet = "100"; -- El proceso de EOTD no se ha ejecutado` |  |
| L151 | VALIDACIÓN_NULL | `IF vcTransaccSuc = ""  OR vcTransaccSuc IS NULL THEN` |  |
| L162 | VALIDACIÓN_NULL | `IF vcCodigoFun = "" OR vcCodigoFun IS NULL THEN` |  |
| L173 | VALIDACIÓN_NULL | `IF viCodigoRef = 0  OR viCodigoRef  IS NULL THEN` |  |
| L201 | FÓRMULA | `LET vmSaldo = vmSalDisp  * -1;` |  |
| L247 | VALIDACIÓN_NULL | `IF vSucursal is null then` |  |
| L258 | VALIDACIÓN_NULL | `IF (vcStatusExento IS NULL) OR ( vcStatusExento = '0') THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `?_eoe` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `tarjeta` | ENTIDAD | tarjeta | 🔵 CONVENCIÓN | nombre_sp |
| `credito` | ENTIDAD | crédito | 🔵 CONVENCIÓN | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_eoe` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_eoetarjetacredito_esp`

| Campo | Valor |
|-------|-------|
| **Dominio** | D15 · `bdilide` · LIDE / PLD |
| **Archivo fuente** | `bdilide_sp_eoetarjetacredito_esp.sql` |
| **LOC (1er CREATE)** | 309 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "tarjeta y crédito (especial)" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 11 tabla(s) con operaciones: INSERT, SELECT |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=4 · INFERIDO=0 · SINTÉTICO=1 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_eoetarjetacredito_esp(
  pEmpresa                     CHAR(3)
  pFechaProceso                DATE
  pCveUsuario                  CHAR(8)
) RETURNING CHAR(4)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pEmpresa` | `CHAR(3)` | — | — |
| `pFechaProceso` | `DATE` | — | — |
| `pCveUsuario` | `CHAR(8)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vmSalDisp` | `DECIMAL(14,2)` | L14 |
| `vcCodRet` | `CHAR(5)` | L15 |
| `vcAnioMes` | `CHAR(6)` | L16 |
| `vcNumCte` | `CHAR(20)` | L17 |
| `viNumSerial` | `INTEGER` | L18 |
| `vcRfc` | `CHAR(13)` | L19 |
| `vcTipoCta` | `CHAR(1)` | L20 |
| `vcNumCta` | `CHAR(20)` | L21 |
| `vdFechaMov` | `DATE` | L22 |
| `vmImpTotDep` | `MONEY(10,2)` | L23 |
| `vmImpIde` | `MONEY(10,2)` | L24 |
| `vcStatus` | `CHAR(1)` | L25 |
| `vcProceso` | `CHAR(10)` | L26 |
| `vmSaldo` | `MONEY(10,2)` | L27 |
| `vmSaldoAnt` | `MONEY(10,2)` | L28 |
| `vmNumTarjeta` | `CHAR(12)` | L29 |
| `vsqlerr` | `INTEGER` | L30 |
| `vcTransaccSuc` | `CHAR(4)` | L31 |
| `vcCodigoFun` | `CHAR(4)` | L32 |
| `viCodigoRef` | `INTEGER` | L33 |
| `vcTpoPersona` | `CHAR(2)` | L34 |
| `vcCodFun` | `CHAR(6)` | L35 |
| `vcCodRef` | `CHAR(6)` | L36 |
| `vcEmpresa` | `CHAR(3)` | L37 |
| `vcAplicaLide` | `CHAR(1)` | L38 |
| *…3 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sl_procesos` | `bdilide` | no | SELECT | L99 |
| `sl_movefec` | `bdilide` | no | SELECT | L125 |
| `sl_procesos` | `bdilide` | no | INSERT | L131 |
| `sd_maesdos` | `bdicred` | ⚠️ sí | SELECT | L138 |
| `sl_parametros` | `bdilide` | no | SELECT | L148 |
| `tmp_sdofavor` | `bdilide` | no | SELECT | L183 |
| `sd_movhis16122009` | `bdicred` | ⚠️ sí | SELECT | L188 |
| `sd_maecred` | `bdicred` | ⚠️ sí | SELECT | L215 |
| `si_cliente` | `bdinteg` | ⚠️ sí | SELECT | L221 |
| `sl_exentos` | `bdilide` | no | SELECT | L254 |
| `sl_movefec` | `bdilide` | no | INSERT | L260 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L88 | VALIDACIÓN_NULL | `IF pFechaProceso IS NULL  OR pFechaProceso = ""  then` |  |
| L104 | VALIDACIÓN_NULL | `IF vcStatus = "0" OR vcStatus IS NULL OR vcStatus = "" THEN` |  |
| L105 | FÓRMULA | `LET vcCodRet = "100"; -- El proceso de EOTD no se ha ejecutado` |  |
| L151 | VALIDACIÓN_NULL | `IF vcTransaccSuc = ""  OR vcTransaccSuc IS NULL THEN` |  |
| L162 | VALIDACIÓN_NULL | `IF vcCodigoFun = "" OR vcCodigoFun IS NULL THEN` |  |
| L173 | VALIDACIÓN_NULL | `IF viCodigoRef = 0  OR viCodigoRef  IS NULL THEN` |  |
| L199 | FÓRMULA | `LET vmSaldo = vmSalDisp  * -1;` |  |
| L247 | VALIDACIÓN_NULL | `IF vSucursal is null then` |  |
| L259 | VALIDACIÓN_NULL | `IF (vcStatusExento IS NULL) OR ( vcStatusExento = '0') THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `?_eoe` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `tarjeta` | ENTIDAD | tarjeta | 🔵 CONVENCIÓN | nombre_sp |
| `credito` | ENTIDAD | crédito | 🔵 CONVENCIÓN | nombre_sp |
| `esp` | MODIF | especial | 🔵 CONVENCIÓN | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_eoe` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_eoetarjetadebito`

| Campo | Valor |
|-------|-------|
| **Dominio** | D15 · `bdilide` · LIDE / PLD |
| **Archivo fuente** | `bdilide_sp_eoetarjetadebito.sql` |
| **LOC (1er CREATE)** | 167 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "tarjeta y débito" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 8 tabla(s) con operaciones: INSERT, SELECT |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=1 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_eoetarjetadebito(
  pEmpresa                     CHAR(3)
  pFechaProceso                DATE
  pCve_Usuario                 CHAR(8)
) RETURNING CHAR(4)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pEmpresa` | `CHAR(3)` | — | — |
| `pFechaProceso` | `DATE` | — | — |
| `pCve_Usuario` | `CHAR(8)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `v_cCod_Ret` | `CHAR(4)` | L10 |
| `v_cStatus` | `CHAR(1)` | L11 |
| `vsqlerr` | `INTEGER` | L12 |
| `v_cAniomes` | `CHAR(6)` | L13 |
| `v_cNumCte` | `CHAR(20)` | L14 |
| `v_iSerial` | `INTEGER` | L15 |
| `v_cRfc` | `CHAR(13)` | L16 |
| `v_dFecha` | `DATE` | L17 |
| `v_mMontoTot` | `MONEY(10,2)` | L18 |
| `v_cCuenta` | `CHAR(20)` | L19 |
| `vcRfc2` | `CHAR(13)` | L20 |
| `vcProceso` | `CHAR(10)` | L21 |
| `viDepositoEfect` | `CHAR(4)` | L22 |
| `vcTpoPersona` | `CHAR(2)` | L23 |
| `vcStatusExento` | `CHAR(1)` | L24 |
| `vSucursal` | `char(4)` | L25 |
| `vTranCentral` | `CHAR(4)` | L26 |
| `v_cTransaccSuc` | `CHAR(4)` | L27 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sl_procesos` | `bdilide` | no | SELECT | L71 |
| `sl_movefec` | `bdilide` | no | SELECT | L84 |
| `sl_procesos` | `bdilide` | no | INSERT | L90 |
| `sl_parametros` | `bdilide` | no | SELECT | L102 |
| `sc_movdia` | `bdicheq` | ⚠️ sí | SELECT | L110 |
| `sl_exentos` | `bdilide` | no | SELECT | L127 |
| `sl_movefec` | `bdilide` | no | INSERT | L132 |
| `sx_contproc` | `bdinteg` | ⚠️ sí | INSERT | L154 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L96 | FÓRMULA | `LET v_cAniomes = REPLACE( SUBSTRING(pFechaProceso  from 7 for 4),'/','')  \|\| SUBSTRING(pFechaProce` |  |
| L131 | VALIDACIÓN_NULL | `IF (vcStatusExento IS NULL) OR ( vcStatusExento = '0') THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `?_eoe` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `tarjeta` | ENTIDAD | tarjeta | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `debito` | ENTIDAD | débito | 🔵 CONVENCIÓN | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_eoe` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_eoetarjetadebito_2200`

| Campo | Valor |
|-------|-------|
| **Dominio** | D15 · `bdilide` · LIDE / PLD |
| **Archivo fuente** | `bdilide_sp_eoetarjetadebito_2200.sql` |
| **LOC (1er CREATE)** | 115 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "tarjeta y débito" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 4 tabla(s) con operaciones: INSERT, SELECT |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=2 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_eoetarjetadebito_2200(
) RETURNING CHAR(4)
```

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `v_cCod_Ret` | `CHAR(4)` | L4 |
| `v_cStatus` | `CHAR(1)` | L5 |
| `vsqlerr` | `INTEGER` | L6 |
| `v_cAniomes` | `CHAR(6)` | L7 |
| `v_cNumCte` | `CHAR(20)` | L8 |
| `v_iSerial` | `INTEGER` | L9 |
| `v_cRfc` | `CHAR(13)` | L10 |
| `v_dFecha` | `DATE` | L11 |
| `v_mMontoTot` | `MONEY(10,2)` | L12 |
| `v_cCuenta` | `CHAR(20)` | L13 |
| `vcRfc2` | `CHAR(13)` | L14 |
| `vcProceso` | `CHAR(10)` | L15 |
| `viDepositoEfect` | `CHAR(4)` | L16 |
| `vcTpoPersona` | `CHAR(2)` | L17 |
| `vcStatusExento` | `CHAR(1)` | L18 |
| `vSucursal` | `char(4)` | L19 |
| `vTranCentral` | `CHAR(4)` | L20 |
| `pCve_Usuario` | `CHAR(10)` | L21 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sl_parametros` | `bdilide` | no | SELECT | L63 |
| `sc_movhis` | `bdicheq` | ⚠️ sí | SELECT | L72 |
| `sl_exentos` | `bdilide` | no | SELECT | L89 |
| `sl_movefec` | `bdilide` | no | INSERT | L94 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L93 | VALIDACIÓN_NULL | `IF (vcStatusExento IS NULL) OR ( vcStatusExento = '0') THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `?_eoe` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `tarjeta` | ENTIDAD | tarjeta | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `debito` | ENTIDAD | débito | 🔵 CONVENCIÓN | nombre_sp |
| `?_2200` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_eoe`, `?_2200` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_eoetarjetadebito_pba`

| Campo | Valor |
|-------|-------|
| **Dominio** | D15 · `bdilide` · LIDE / PLD |
| **Archivo fuente** | `bdilide_sp_eoetarjetadebito_pba.sql` |
| **LOC (1er CREATE)** | 161 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "tarjeta y débito (PBA — sufijo de SPs para Pruebas; confirmado por SME)" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `confirma` → `SELECT` encontrado en el cuerpo · `confirma` → `UPDATE` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=1 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_eoetarjetadebito_pba(
  pEmpresa                     CHAR(3)
  pFechaProceso                DATE
  pCve_Usuario                 CHAR(8)
) RETURNING CHAR(4)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pEmpresa` | `CHAR(3)` | — | — |
| `pFechaProceso` | `DATE` | — | — |
| `pCve_Usuario` | `CHAR(8)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `v_cCod_Ret` | `CHAR(4)` | L10 |
| `v_cStatus` | `CHAR(1)` | L11 |
| `vsqlerr` | `INTEGER` | L12 |
| `v_cAniomes` | `CHAR(6)` | L13 |
| `v_cNumCte` | `CHAR(20)` | L14 |
| `v_iSerial` | `INTEGER` | L15 |
| `v_cRfc` | `CHAR(13)` | L16 |
| `v_dFecha` | `DATE` | L17 |
| `v_mMontoTot` | `MONEY(10,2)` | L18 |
| `v_cCuenta` | `CHAR(20)` | L19 |
| `vcRfc2` | `CHAR(13)` | L20 |
| `vcProceso` | `CHAR(10)` | L21 |
| `viDepositoEfect` | `CHAR(4)` | L22 |
| `vcTpoPersona` | `CHAR(2)` | L23 |
| `vcStatusExento` | `CHAR(1)` | L24 |
| `vSucursal` | `char(4)` | L25 |
| `vTranCentral` | `CHAR(4)` | L26 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sl_procesos` | `bdilide` | no | SELECT | L69 |
| `sl_movefec` | `bdilide` | no | SELECT | L82 |
| `sl_procesos` | `bdilide` | no | INSERT | L88 |
| `sc_movdia` | `bdicheq` | ⚠️ sí | SELECT | L101 |
| `sl_parametros` | `bdilide` | no | SELECT | L109 |
| `sl_exentos` | `bdilide` | no | SELECT | L122 |
| `sl_movefec` | `bdilide` | no | INSERT | L127 |
| `sx_contproc` | `bdinteg` | ⚠️ sí | INSERT | L148 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L94 | FÓRMULA | `LET v_cAniomes = REPLACE( SUBSTRING(pFechaProceso  from 7 for 4),'/','')  \|\| SUBSTRING(pFechaProce` |  |
| L126 | VALIDACIÓN_NULL | `IF (vcStatusExento IS NULL) OR ( vcStatusExento = '0') THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `?_eoe` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `tarjeta` | ENTIDAD | tarjeta | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `debito` | ENTIDAD | débito | 🔵 CONVENCIÓN | nombre_sp |
| `pba` | MODIF | PBA — sufijo de SPs para Pruebas; confirmado por SME (Guerra | 🔵 CONVENCIÓN | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_eoe` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_eoetarjetadebito_prod`

| Campo | Valor |
|-------|-------|
| **Dominio** | D15 · `bdilide` · LIDE / PLD |
| **Archivo fuente** | `bdilide_sp_eoetarjetadebito_prod.sql` |
| **LOC (1er CREATE)** | 161 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "tarjeta, débito y producto" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 8 tabla(s) con operaciones: INSERT, SELECT |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=2 · INFERIDO=1 · SINTÉTICO=1 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_eoetarjetadebito_prod(
  pEmpresa                     CHAR(3)
  pFechaProceso                DATE
  pCve_Usuario                 CHAR(8)
) RETURNING CHAR(4)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pEmpresa` | `CHAR(3)` | — | — |
| `pFechaProceso` | `DATE` | — | — |
| `pCve_Usuario` | `CHAR(8)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `v_cCod_Ret` | `CHAR(4)` | L10 |
| `v_cStatus` | `CHAR(1)` | L11 |
| `vsqlerr` | `INTEGER` | L12 |
| `v_cAniomes` | `CHAR(6)` | L13 |
| `v_cNumCte` | `CHAR(20)` | L14 |
| `v_iSerial` | `INTEGER` | L15 |
| `v_cRfc` | `CHAR(13)` | L16 |
| `v_dFecha` | `DATE` | L17 |
| `v_mMontoTot` | `MONEY(10,2)` | L18 |
| `v_cCuenta` | `CHAR(20)` | L19 |
| `vcRfc2` | `CHAR(13)` | L20 |
| `vcProceso` | `CHAR(10)` | L21 |
| `viDepositoEfect` | `CHAR(4)` | L22 |
| `vcTpoPersona` | `CHAR(2)` | L23 |
| `vcStatusExento` | `CHAR(1)` | L24 |
| `vSucursal` | `char(4)` | L25 |
| `vTranCentral` | `CHAR(4)` | L26 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sl_procesos` | `bdilide` | no | SELECT | L69 |
| `sl_movefec` | `bdilide` | no | SELECT | L82 |
| `sl_procesos` | `bdilide` | no | INSERT | L88 |
| `sc_movdia` | `bdicheq` | ⚠️ sí | SELECT | L101 |
| `sl_parametros` | `bdilide` | no | SELECT | L109 |
| `sl_exentos` | `bdilide` | no | SELECT | L122 |
| `sl_movefec` | `bdilide` | no | INSERT | L127 |
| `sx_contproc` | `bdinteg` | ⚠️ sí | INSERT | L148 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L94 | FÓRMULA | `LET v_cAniomes = REPLACE( SUBSTRING(pFechaProceso  from 7 for 4),'/','')  \|\| SUBSTRING(pFechaProce` |  |
| L126 | VALIDACIÓN_NULL | `IF (vcStatusExento IS NULL) OR ( vcStatusExento = '0') THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `?_eoe` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `tarjeta` | ENTIDAD | tarjeta | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `debito` | ENTIDAD | débito | 🔵 CONVENCIÓN | nombre_sp |
| `prod` | ENTIDAD | producto | 🟡 INFERIDO | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_eoe` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_eotd_pend`

| Campo | Valor |
|-------|-------|
| **Dominio** | D15 · `bdilide` · LIDE / PLD |
| **Archivo fuente** | `bdilide_sp_eotd_pend.sql` |
| **LOC (1er CREATE)** | 158 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "sp_eotd_pend" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 7 tabla(s) con operaciones: INSERT, SELECT |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=1 / 2 términos |

### Firma

```sql
CREATE PROCEDURE sp_eotd_pend(
  pEmpresa                     CHAR(3)
  pFechaProceso                DATE
  pCve_Usuario                 CHAR(8)
) RETURNING CHAR(4)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pEmpresa` | `CHAR(3)` | — | — |
| `pFechaProceso` | `DATE` | — | — |
| `pCve_Usuario` | `CHAR(8)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `v_cCod_Ret` | `CHAR(4)` | L11 |
| `v_cStatus` | `CHAR(1)` | L12 |
| `vsqlerr` | `INTEGER` | L13 |
| `v_cAniomes` | `CHAR(6)` | L14 |
| `v_cNumCte` | `CHAR(20)` | L15 |
| `v_iSerial` | `INTEGER` | L16 |
| `v_cRfc` | `CHAR(13)` | L17 |
| `v_dFecha` | `DATE` | L18 |
| `v_mMontoTot` | `MONEY(10,2)` | L19 |
| `v_cCuenta` | `CHAR(20)` | L20 |
| `vcRfc2` | `CHAR(13)` | L21 |
| `vcProceso` | `CHAR(15)` | L22 |
| `viDepositoEfect` | `CHAR(4)` | L23 |
| `vcTpoPersona` | `CHAR(2)` | L24 |
| `vcStatusExento` | `CHAR(1)` | L25 |
| `vSucursal` | `char(4)` | L26 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sl_procesos` | `bdilide` | no | SELECT | L63 |
| `sl_movefec` | `bdilide` | no | SELECT | L76 |
| `sl_procesos` | `bdilide` | no | INSERT | L83 |
| `sl_parametros` | `bdilide` | no | SELECT | L93 |
| `sc_movhis` | `bdicheq` | ⚠️ sí | SELECT | L101 |
| `sl_exentos` | `bdilide` | no | SELECT | L124 |
| `sl_movefec` | `bdilide` | no | INSERT | L129 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L87 | FÓRMULA | `LET v_cAniomes = REPLACE( SUBSTRING(pFechaProceso  from 7 for 4),'/','')  \|\| SUBSTRING(pFechaProce` |  |
| L128 | VALIDACIÓN_NULL | `IF (vcStatusExento IS NULL) OR ( vcStatusExento = '0') THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `?_eotd_pend` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_eotd_pend` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_escribirarchivodedeclaracionide`

| Campo | Valor |
|-------|-------|
| **Dominio** | D15 · `bdilide` · LIDE / PLD |
| **Archivo fuente** | `bdilide_sp_escribirarchivodedeclaracionide.sql` |
| **LOC (1er CREATE)** | 72 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "archivo, declaración y identificador" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 2 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=4 · INFERIDO=0 · SINTÉTICO=3 / 7 términos |

### Firma

```sql
CREATE PROCEDURE sp_escribirarchivodedeclaracionide(
  p_cArchivo                   CHAR(20)
) RETURNING CHAR(6),CHAR(25)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_cArchivo` | `CHAR(20)` | `archivo`=archivo | 🔵 CONVENCIÓN |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `v_cCodRet` | `CHAR(6)` | L5 |
| `iSqlErr` | `INTEGER` | L6 |
| `v_cStmt` | `CHAR(250)` | L8 |
| `v_cFile` | `CHAR(25)` | L9 |
| `v_cFileTemp` | `CHAR(25)` | L10 |
| `v_cFileGz` | `CHAR(25)` | L11 |
| `v_cRutaServer` | `CHAR(67)` | L12 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sl_parametros` | `bdilide` | no | SELECT | L27 |
| `sl_archivoxml` | `bdilide` | no | SELECT | L40 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L18 | FÓRMULA | `LET v_cFileTemp = SUBSTRING(TRIM(p_cArchivo) FROM 1 FOR LENGTH(TRIM(p_cArchivo)) - 4) \|\|'.tmp';` |  |
| L19 | FÓRMULA | `LET v_cFileGz = SUBSTRING(TRIM(p_cArchivo) FROM 1 FOR LENGTH(TRIM(p_cArchivo)) - 4) \|\|'.gz';` |  |
| L52 | FÓRMULA | `LET v_cStmt = "sed 's/\|$//g' "\|\| TRIM(v_cRutaServer) \|\| TRIM(v_cFileTemp)\|\| " > " \|\| TRIM(v` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `?_escribir` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `archivo` | ENTIDAD | archivo | 🔵 CONVENCIÓN | nombre_sp |
| `?de` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `declaracion` | ENTIDAD | declaración | 🔵 CONVENCIÓN | nombre_sp |
| `id` | ENTIDAD | identificador (de) | 🔵 CONVENCIÓN | nombre_sp |
| `?e` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_escribir`, `?de`, `?e` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_escribirarchivodedeclaracionide2`

| Campo | Valor |
|-------|-------|
| **Dominio** | D15 · `bdilide` · LIDE / PLD |
| **Archivo fuente** | `bdilide_sp_escribirarchivodedeclaracionide2.sql` |
| **LOC (1er CREATE)** | 95 |
| **Callgraph** | ✅ fan_in=360 / fan_out=0 |
| **Principales callers** | `sp_bitacora`, `sp_consultareportepagoscre`, `sp_generararchivo_rst`, `sp_abm_canal_cobro`, `sp_activardesactivarproductos` |
| **Propósito inferido** | "archivo, declaración y identificador" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 2 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=4 · INFERIDO=0 · SINTÉTICO=3 / 7 términos |

### Firma

```sql
CREATE PROCEDURE sp_escribirarchivodedeclaracionide2(
  p_cArchivo                   CHAR(20)
) RETURNING CHAR(6),CHAR(25)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_cArchivo` | `CHAR(20)` | `archivo`=archivo | 🔵 CONVENCIÓN |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `v_cCodRet` | `CHAR(6)` | L5 |
| `iSqlErr` | `INTEGER` | L6 |
| `v_cStmt` | `CHAR(250)` | L8 |
| `v_cFile` | `CHAR(25)` | L9 |
| `v_cFileTemp` | `CHAR(25)` | L10 |
| `v_cFileGz` | `CHAR(25)` | L11 |
| `v_cRutaServer` | `CHAR(67)` | L12 |
| `bTransaccion` | `BOOLEAN` | L14 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sl_parametros` | `bdilide` | no | SELECT | L35 |
| `sl_archivoxml` | `bdilide` | no | SELECT | L58 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L20 | FÓRMULA | `LET v_cFileTemp = SUBSTRING(TRIM(p_cArchivo) FROM 1 FOR LENGTH(TRIM(p_cArchivo)) - 4) \|\|'.tmp';` |  |
| L21 | FÓRMULA | `LET v_cFileGz = SUBSTRING(TRIM(p_cArchivo) FROM 1 FOR LENGTH(TRIM(p_cArchivo)) - 4) \|\|'.gz';` |  |
| L71 | FÓRMULA | `LET v_cStmt = "sed 's/\|$//g' "\|\| TRIM(v_cRutaServer) \|\| TRIM(v_cFileTemp)\|\| " > " \|\| TRIM(v` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `?_escribir` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `archivo` | ENTIDAD | archivo | 🔵 CONVENCIÓN | nombre_sp |
| `?de` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `declaracion` | ENTIDAD | declaración | 🔵 CONVENCIÓN | nombre_sp |
| `id` | ENTIDAD | identificador (de) | 🔵 CONVENCIÓN | nombre_sp |
| `?e2` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_escribir`, `?de`, `?e2` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_existeconstanciaanual`

| Campo | Valor |
|-------|-------|
| **Dominio** | D15 · `bdilide` · LIDE / PLD |
| **Archivo fuente** | `bdilide_sp_existeconstanciaanual.sql` |
| **LOC (1er CREATE)** | 48 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "consulta" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=3 / 6 términos |

### Firma

```sql
CREATE PROCEDURE sp_existeconstanciaanual(
  pFechaAnio                   CHAR(4)
) RETURNING CHAR(6)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pFechaAnio` | `CHAR(4)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vCodRet` | `CHAR(6)` | L10 |
| `dFechaInicial` | `date` | L11 |
| `dFechaFinal` | `date` | L12 |
| `sAuxFecha` | `char(10)` | L13 |
| `iCuantos` | `smallint` | L14 |
| `vsqlerr` | `integer` | L15 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sl_procesos` | `bdilide` | no | SELECT | L35 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L27 | FÓRMULA | `Let sAuxFecha   =  '01-01-' \|\| trim((pFechaAnio + 1)::char(4)); --Formato y` |  |
| L30 | FÓRMULA | `Let sAuxFecha   =  '02-10-' \|\| trim((pFechaAnio + 1)::char(4)); --Formato y` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `?_e` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `x` | MODIF | por (criterio) | 🔵 CONVENCIÓN | nombre_sp |
| `?iste` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `cons` | ACCION | consulta | 🔵 CONVENCIÓN | nombre_sp |
| `?tanciaanual` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_e`, `?iste`, `?tanciaanual` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_formararchivodedeclaracion`

| Campo | Valor |
|-------|-------|
| **Dominio** | D15 · `bdilide` · LIDE / PLD |
| **Archivo fuente** | `bdilide_sp_formararchivodedeclaracion.sql` |
| **LOC (1er CREATE)** | 1192 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "construye archivo y declaración" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 24 tabla(s) con operaciones: INSERT, UPDATE, SELECT |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=1 · INFERIDO=1 · SINTÉTICO=2 / 6 términos |

### Firma

```sql
CREATE PROCEDURE sp_formararchivodedeclaracion(
  p_cFechaXML                  VARCHAR(6)
  p_cDeclaracion               CHAR(1)
  p_cTipoDeclaracion           CHAR(1)
) RETURNING VARCHAR(6),VARCHAR(20)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_cFechaXML` | `VARCHAR(6)` | — | — |
| `p_cDeclaracion` | `CHAR(1)` | `declaracion`=declaración | ✅ CÓDIGO |
| `p_cTipoDeclaracion` | `CHAR(1)` | `declaracion`=declaración | ✅ CÓDIGO |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `v_cRetorno` | `VARCHAR(6)` | L5 |
| `iSqlError` | `INTEGER` | L6 |
| `v_cFiller` | `VARCHAR(32)` | L7 |
| `v_cNumReg` | `CHAR(1)` | L8 |
| `v_iNumComplementaria` | `INTEGER` | L9 |
| `v_cDomicilio` | `VARCHAR(90)` | L10 |
| `v_cArchivo` | `VARCHAR(20)` | L11 |
| `v_dFechaPres` | `DATE` | L12 |
| `v_cNumFolioAnt` | `VARCHAR(20)` | L13 |
| `v_cDiaUltimo` | `CHAR(2)` | L14 |
| `v_cVarPrueba1` | `VARCHAR(128)` | L15 |
| `v_cVarPrueba2` | `VARCHAR(128)` | L16 |
| `v_cVarPrueba3` | `VARCHAR(128)` | L17 |
| `v_cVarPrueba4` | `VARCHAR(128)` | L18 |
| `v_cMes` | `CHAR(2)` | L19 |
| `v_cAnio` | `VARCHAR(4)` | L20 |
| `v_dFechOper` | `DATE` | L21 |
| `v_mMontoOper` | `MONEY(16,2)` | L22 |
| `v_cTipoOper` | `CHAR(2)` | L23 |
| `v_iContador` | `INTEGER` | L24 |
| `v_cCliente` | `VARCHAR(20)` | L26 |
| `v_cTipoPersona` | `CHAR(2)` | L27 |
| `v_cRfc` | `VARCHAR(13)` | L28 |
| `v_cCurp` | `VARCHAR(20)` | L29 |
| `v_cRazonSocial` | `VARCHAR(60)` | L30 |
| *…50 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sl_parametros` | `bdilide` | no | SELECT | L217 |
| `sl_menxml` | `bdilide` | no | SELECT | L271 |
| `sl_declinfor` | `bdilide` | no | SELECT | L280 |
| `sl_archivoxml` | `bdilide` | no | INSERT | L293 |
| `si_telefonos_actual` | `bdinteg` | ⚠️ sí | SELECT | L372 |
| `sl_movefec_his` | `bdilide` | no | SELECT | L429 |
| `sl_anualxml` | `bdilide` | no | SELECT | L659 |
| `stattmp_anualxmlfisica` | `bdilide` | no | INSERT | L688 |
| `stattmp_anualxmlmoral` | `bdilide` | no | INSERT | L695 |
| `stattmp_ctasfisicas` | `bdilide` | no | INSERT | L703 |
| `stattmp_anualxmlfisica` | `bdilide` | no | SELECT | L706 |
| `stattmp_ctasmorales` | `bdilide` | no | INSERT | L710 |
| `stattmp_anualxmlmoral` | `bdilide` | no | SELECT | L713 |
| `stattmp_movctasfisicas` | `bdilide` | no | INSERT | L718 |
| `stattmp_ctasfisicas` | `bdilide` | no | SELECT | L721 |
| `stattmp_movctasmorales` | `bdilide` | no | INSERT | L726 |
| `stattmp_ctasmorales` | `bdilide` | no | SELECT | L729 |
| `sc_producto` | `bdicheq` | ⚠️ sí | SELECT | L881 |
| `sc_maechq` | `bdicheq` | ⚠️ sí | SELECT | L882 |
| `sd_definicion` | `bdicred` | ⚠️ sí | SELECT | L888 |
| `sd_maecred` | `bdicred` | ⚠️ sí | SELECT | L889 |
| `stattmp_movctasfisicas` | `bdilide` | no | SELECT | L911 |
| `statistics` | `bdilide` | no | UPDATE | L937 |
| `stattmp_movctasmorales` | `bdilide` | no | SELECT | L1100 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L181 | FÓRMULA | `LET iTransOpen = 0; --DSB 09/01/2020` |  |
| L411 | VALIDACIÓN_NULL | `IF v_cDomicilio = ' ' OR v_cDomicilio IS NULL THEN` |  |
| L432 | FÓRMULA | `LET v_iContador = v_iContador  + 1;` |  |
| L480 | FÓRMULA | `LET v_iContador = 0; --DSB 09/01/2020` |  |
| L544 | VALIDACIÓN_NULL | `IF v_cDomicilio = ' ' OR v_cDomicilio IS NULL THEN` |  |
| L566 | FÓRMULA | `LET v_iContador = v_iContador  + 1;` |  |
| L844 | VALIDACIÓN_NULL | `IF v_cDomicilio = ' ' OR v_cDomicilio IS NULL THEN` |  |
| L917 | FÓRMULA | `LET v_iContador = v_iContador  + 1;` |  |
| L971 | FÓRMULA | `LET v_iContador = 0; --DSB 09/01/2020` |  |
| L1033 | VALIDACIÓN_NULL | `IF v_cDomicilio = ' ' OR v_cDomicilio IS NULL THEN` |  |
| L1107 | FÓRMULA | `LET v_iContador = v_iContador  + 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `forma` | ACCION | construye / arma | 🟡 INFERIDO | nombre_sp |
| `?r` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `archivo` | ENTIDAD | archivo | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?de` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `declaracion` | ENTIDAD | declaración | ✅ CÓDIGO | nombre_sp, texto_cuerpo |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?r`, `?de` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_formararchivodedeclaracion2`

| Campo | Valor |
|-------|-------|
| **Dominio** | D15 · `bdilide` · LIDE / PLD |
| **Archivo fuente** | `bdilide_sp_formararchivodedeclaracion2.sql` |
| **LOC (1er CREATE)** | 1251 |
| **Callgraph** | ✅ fan_in=358 / fan_out=0 |
| **Principales callers** | `sp_bitacora`, `sp_consultareportepagoscre`, `sp_generararchivo_rst`, `sp_abm_canal_cobro`, `sp_activardesactivarproductos` |
| **Propósito inferido** | "construye archivo y declaración" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 24 tabla(s) con operaciones: INSERT, UPDATE, SELECT |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=1 · INFERIDO=1 · SINTÉTICO=3 / 7 términos |

### Firma

```sql
CREATE PROCEDURE sp_formararchivodedeclaracion2(
  p_cFechaXML                  VARCHAR(6)
  p_cDeclaracion               CHAR(1)
  p_cTipoDeclaracion           CHAR(1)
) RETURNING VARCHAR(6),VARCHAR(20)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_cFechaXML` | `VARCHAR(6)` | — | — |
| `p_cDeclaracion` | `CHAR(1)` | `declaracion`=declaración | ✅ CÓDIGO |
| `p_cTipoDeclaracion` | `CHAR(1)` | `declaracion`=declaración | ✅ CÓDIGO |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `v_cRetorno` | `VARCHAR(6)` | L5 |
| `iSqlError` | `INTEGER` | L6 |
| `v_cFiller` | `VARCHAR(32)` | L7 |
| `v_cNumReg` | `CHAR(1)` | L8 |
| `v_iNumComplementaria` | `INTEGER` | L9 |
| `v_cDomicilio` | `VARCHAR(90)` | L10 |
| `v_cArchivo` | `VARCHAR(20)` | L11 |
| `v_dFechaPres` | `DATE` | L12 |
| `v_cNumFolioAnt` | `VARCHAR(20)` | L13 |
| `v_cDiaUltimo` | `CHAR(2)` | L14 |
| `v_cVarPrueba1` | `VARCHAR(128)` | L15 |
| `v_cVarPrueba2` | `VARCHAR(128)` | L16 |
| `v_cVarPrueba3` | `VARCHAR(128)` | L17 |
| `v_cVarPrueba4` | `VARCHAR(128)` | L18 |
| `v_cMes` | `CHAR(2)` | L19 |
| `v_cAnio` | `VARCHAR(4)` | L20 |
| `v_dFechOper` | `DATE` | L21 |
| `v_mMontoOper` | `MONEY(16,2)` | L22 |
| `v_cTipoOper` | `CHAR(2)` | L23 |
| `v_iContador` | `INTEGER` | L24 |
| `v_cCliente` | `VARCHAR(20)` | L26 |
| `v_cTipoPersona` | `CHAR(2)` | L27 |
| `v_cRfc` | `VARCHAR(13)` | L28 |
| `v_cCurp` | `VARCHAR(20)` | L29 |
| `v_cRazonSocial` | `VARCHAR(60)` | L30 |
| *…52 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sl_parametros` | `bdilide` | no | SELECT | L238 |
| `sl_menxml` | `bdilide` | no | SELECT | L292 |
| `sl_declinfor` | `bdilide` | no | SELECT | L301 |
| `sl_archivoxml` | `bdilide` | no | INSERT | L318 |
| `si_telefonos_actual` | `bdinteg` | ⚠️ sí | SELECT | L397 |
| `sl_movefec_his` | `bdilide` | no | SELECT | L454 |
| `sl_anualxml` | `bdilide` | no | SELECT | L684 |
| `stattmp_anualxmlfisica` | `bdilide` | no | INSERT | L729 |
| `stattmp_anualxmlmoral` | `bdilide` | no | INSERT | L736 |
| `stattmp_ctasfisicas` | `bdilide` | no | INSERT | L744 |
| `stattmp_anualxmlfisica` | `bdilide` | no | SELECT | L747 |
| `stattmp_ctasmorales` | `bdilide` | no | INSERT | L751 |
| `stattmp_anualxmlmoral` | `bdilide` | no | SELECT | L754 |
| `stattmp_movctasfisicas` | `bdilide` | no | INSERT | L759 |
| `stattmp_ctasfisicas` | `bdilide` | no | SELECT | L762 |
| `stattmp_movctasmorales` | `bdilide` | no | INSERT | L767 |
| `stattmp_ctasmorales` | `bdilide` | no | SELECT | L770 |
| `sc_producto` | `bdicheq` | ⚠️ sí | SELECT | L922 |
| `sc_maechq` | `bdicheq` | ⚠️ sí | SELECT | L923 |
| `sd_definicion` | `bdicred` | ⚠️ sí | SELECT | L929 |
| `sd_maecred` | `bdicred` | ⚠️ sí | SELECT | L930 |
| `stattmp_movctasfisicas` | `bdilide` | no | SELECT | L952 |
| `statistics` | `bdilide` | no | UPDATE | L978 |
| `stattmp_movctasmorales` | `bdilide` | no | SELECT | L1141 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L184 | FÓRMULA | `LET iTransOpen = 0; --DSB 09/01/2020` |  |
| L436 | VALIDACIÓN_NULL | `IF v_cDomicilio = ' ' OR v_cDomicilio IS NULL THEN` |  |
| L457 | FÓRMULA | `LET v_iContador = v_iContador  + 1;` |  |
| L505 | FÓRMULA | `LET v_iContador = 0; --DSB 09/01/2020` |  |
| L569 | VALIDACIÓN_NULL | `IF v_cDomicilio = ' ' OR v_cDomicilio IS NULL THEN` |  |
| L591 | FÓRMULA | `LET v_iContador = v_iContador  + 1;` |  |
| L885 | VALIDACIÓN_NULL | `IF v_cDomicilio = ' ' OR v_cDomicilio IS NULL THEN` |  |
| L958 | FÓRMULA | `LET v_iContador = v_iContador  + 1;` |  |
| L1012 | FÓRMULA | `LET v_iContador = 0; --DSB 09/01/2020` |  |
| L1074 | VALIDACIÓN_NULL | `IF v_cDomicilio = ' ' OR v_cDomicilio IS NULL THEN` |  |
| L1148 | FÓRMULA | `LET v_iContador = v_iContador  + 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `forma` | ACCION | construye / arma | 🟡 INFERIDO | nombre_sp |
| `?r` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `archivo` | ENTIDAD | archivo | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?de` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `declaracion` | ENTIDAD | declaración | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?2` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?r`, `?de`, `?2` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_formararchivodedeclaracion_pba`

| Campo | Valor |
|-------|-------|
| **Dominio** | D15 · `bdilide` · LIDE / PLD |
| **Archivo fuente** | `bdilide_sp_formararchivodedeclaracion_pba.sql` |
| **LOC (1er CREATE)** | 1071 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "construye archivo y declaración (PBA — sufijo de SPs para Pruebas; confirmado por SME)" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `confirma` → `SELECT` encontrado en el cuerpo · `confirma` → `UPDATE` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=2 · INFERIDO=1 · SINTÉTICO=2 / 7 términos |

### Firma

```sql
CREATE PROCEDURE sp_formararchivodedeclaracion_pba(
  p_cFechaXML                  CHAR(6)
  p_cDeclaracion               CHAR(1)
  p_cTipoDeclaracion           CHAR(1)
) RETURNING CHAR(6),CHAR(20)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_cFechaXML` | `CHAR(6)` | — | — |
| `p_cDeclaracion` | `CHAR(1)` | `declaracion`=declaración | ✅ CÓDIGO |
| `p_cTipoDeclaracion` | `CHAR(1)` | `declaracion`=declaración | ✅ CÓDIGO |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `v_cRetorno` | `CHAR(6)` | L5 |
| `iSqlError` | `INTEGER` | L6 |
| `v_cFiller` | `CHAR(32)` | L7 |
| `v_cNumReg` | `CHAR(1)` | L8 |
| `v_iNumComplementaria` | `INTEGER` | L9 |
| `v_cDomicilio` | `CHAR(90)` | L10 |
| `v_cArchivo` | `CHAR(20)` | L11 |
| `v_dFechaPres` | `DATE` | L12 |
| `v_cNumFolioAnt` | `CHAR(20)` | L13 |
| `v_cDiaUltimo` | `CHAR(2)` | L14 |
| `v_cVarPrueba1` | `CHAR(128)` | L15 |
| `v_cVarPrueba2` | `CHAR(128)` | L16 |
| `v_cVarPrueba3` | `CHAR(128)` | L17 |
| `v_cVarPrueba4` | `CHAR(128)` | L18 |
| `v_cMes` | `CHAR(2)` | L19 |
| `v_cAnio` | `CHAR(4)` | L20 |
| `v_dFechOper` | `DATE` | L21 |
| `v_mMontoOper` | `MONEY(16,2)` | L22 |
| `v_cTipoOper` | `CHAR(2)` | L23 |
| `v_iContador` | `INT` | L24 |
| `v_cCliente` | `CHAR(20)` | L26 |
| `v_cTipoPersona` | `CHAR(2)` | L27 |
| `v_cRfc` | `CHAR(13)` | L28 |
| `v_cCurp` | `CHAR(20)` | L29 |
| `v_cRazonSocial` | `CHAR(60)` | L30 |
| *…50 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sl_parametros` | `bdilide` | no | SELECT | L209 |
| `sl_menxml` | `bdilide` | no | SELECT | L263 |
| `sl_declinfor` | `bdilide` | no | SELECT | L272 |
| `sl_archivoxml` | `bdilide` | no | SELECT | L282 |
| `sl_archivoxml` | `bdilide` | no | DELETE | L282 |
| `sl_archivoxml` | `bdilide` | no | INSERT | L284 |
| `si_telefonos_actual` | `bdinteg` | ⚠️ sí | SELECT | L363 |
| `sl_movefec_his` | `bdilide` | no | SELECT | L420 |
| `sl_anualxml` | `bdilide` | no | SELECT | L603 |
| `stattmp_anualxmlfisica` | `bdilide` | no | INSERT | L631 |
| `stattmp_anualxmlmoral` | `bdilide` | no | INSERT | L638 |
| `stattmp_ctasfisicas` | `bdilide` | no | INSERT | L646 |
| `stattmp_anualxmlfisica` | `bdilide` | no | SELECT | L648 |
| `stattmp_ctasmorales` | `bdilide` | no | INSERT | L652 |
| `stattmp_anualxmlmoral` | `bdilide` | no | SELECT | L654 |
| `stattmp_movctasfisicas` | `bdilide` | no | INSERT | L659 |
| `stattmp_ctasfisicas` | `bdilide` | no | SELECT | L661 |
| `stattmp_movctasmorales` | `bdilide` | no | INSERT | L666 |
| `stattmp_ctasmorales` | `bdilide` | no | SELECT | L668 |
| `sc_producto` | `bdicheq` | ⚠️ sí | SELECT | L820 |
| `sc_maechq` | `bdicheq` | ⚠️ sí | SELECT | L821 |
| `sd_definicion` | `bdicred` | ⚠️ sí | SELECT | L827 |
| `sd_maecred` | `bdicred` | ⚠️ sí | SELECT | L828 |
| `stattmp_movctasfisicas` | `bdilide` | no | SELECT | L850 |
| `statistics` | `bdilide` | no | UPDATE | L860 |
| `stattmp_movctasmorales` | `bdilide` | no | SELECT | L1009 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L402 | VALIDACIÓN_NULL | `IF v_cDomicilio = ' ' OR v_cDomicilio IS NULL THEN` |  |
| L510 | VALIDACIÓN_NULL | `IF v_cDomicilio = ' ' OR v_cDomicilio IS NULL THEN` |  |
| L783 | VALIDACIÓN_NULL | `IF v_cDomicilio = ' ' OR v_cDomicilio IS NULL THEN` |  |
| L857 | FÓRMULA | `LET v_iContador = v_iContador  + 1 ;` |  |
| L942 | VALIDACIÓN_NULL | `IF v_cDomicilio = ' ' OR v_cDomicilio IS NULL THEN` |  |
| L1017 | FÓRMULA | `LET v_iContador = v_iContador  + 1 ;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `forma` | ACCION | construye / arma | 🟡 INFERIDO | nombre_sp |
| `?r` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `archivo` | ENTIDAD | archivo | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?de` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `declaracion` | ENTIDAD | declaración | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `pba` | MODIF | PBA — sufijo de SPs para Pruebas; confirmado por SME (Guerra | 🔵 CONVENCIÓN | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?r`, `?de` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_ftc_folioresp`

| Campo | Valor |
|-------|-------|
| **Dominio** | D15 · `bdilide` · LIDE / PLD |
| **Archivo fuente** | `bdilide_sp_ftc_folioresp.sql` |
| **LOC (1er CREATE)** | 53 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "FTC — módulo de configuración de transferencia de archivos y folio (especial)" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 1 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=1 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_ftc_folioresp(
  v_periodo                    CHAR(04)
) RETURNING CHAR (5), CHAR(50)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `v_periodo` | `CHAR(04)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `iSqlErr` | `INTEGER` | L5 |
| `cVarDataErr` | `CHAR(300)` | L6 |
| `cCodRet` | `CHAR(05)` | L9 |
| `v_vlr_prm` | `VARCHAR(100)` | L10 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sl_ftc_prm` | `bdilide` | no | SELECT | L34 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L39 | CÓDIGO_RETORNO | `LET cCodret = '00001';` |  |
| L48 | CÓDIGO_RETORNO | `LET cCodret = '00000';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `ftc` | ENTIDAD | FTC — módulo de configuración de transferencia de archivos ( | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `folio` | ENTIDAD | folio | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?r` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `esp` | MODIF | especial | 🔵 CONVENCIÓN | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?r` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_ftc_ipsftp`

| Campo | Valor |
|-------|-------|
| **Dominio** | D15 · `bdilide` · LIDE / PLD |
| **Archivo fuente** | `bdilide_sp_ftc_ipsftp.sql` |
| **LOC (1er CREATE)** | 54 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "FTC — módulo de configuración de transferencia de archivos (tipo)" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 1 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=1 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_ftc_ipsftp(
  v_periodo                    CHAR(04)
) RETURNING CHAR (5), CHAR(100)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `v_periodo` | `CHAR(04)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `iSqlErr` | `INTEGER` | L5 |
| `cVarDataErr` | `CHAR(300)` | L6 |
| `cCodRet` | `CHAR(05)` | L9 |
| `v_vlr_prm` | `VARCHAR(100)` | L10 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sl_ftc_prm` | `bdilide` | no | SELECT | L34 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L39 | CÓDIGO_RETORNO | `LET cCodret = '00001';` |  |
| L49 | CÓDIGO_RETORNO | `LET cCodret = '00000';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `ftc` | ENTIDAD | FTC — módulo de configuración de transferencia de archivos ( | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `?_ipsf` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `tp` | MODIF | tipo | 🔵 CONVENCIÓN | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_ipsf` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_ftc_ipsoky`

| Campo | Valor |
|-------|-------|
| **Dominio** | D15 · `bdilide` · LIDE / PLD |
| **Archivo fuente** | `bdilide_sp_ftc_ipsoky.sql` |
| **LOC (1er CREATE)** | 53 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "FTC — módulo de configuración de transferencia de archivos" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 1 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=1 / 3 términos |

### Firma

```sql
CREATE PROCEDURE sp_ftc_ipsoky(
  v_periodo                    CHAR(04)
) RETURNING CHAR (5), CHAR(100)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `v_periodo` | `CHAR(04)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `iSqlErr` | `INTEGER` | L5 |
| `cVarDataErr` | `CHAR(300)` | L6 |
| `cCodRet` | `CHAR(05)` | L9 |
| `v_vlr_prm` | `VARCHAR(100)` | L10 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sl_ftc_prm` | `bdilide` | no | SELECT | L34 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L39 | CÓDIGO_RETORNO | `LET cCodret = '00001';` |  |
| L48 | CÓDIGO_RETORNO | `LET cCodret = '00000';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `ftc` | ENTIDAD | FTC — módulo de configuración de transferencia de archivos ( | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `?_ipsoky` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_ipsoky` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_ftc_pswproxy`

| Campo | Valor |
|-------|-------|
| **Dominio** | D15 · `bdilide` · LIDE / PLD |
| **Archivo fuente** | `bdilide_sp_ftc_pswproxy.sql` |
| **LOC (1er CREATE)** | 54 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "FTC — módulo de configuración de transferencia de archivos, sw — SoftWare/Switch y ro — Rol Operativo" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 1 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=5 / 8 términos |

### Firma

```sql
CREATE PROCEDURE sp_ftc_pswproxy(
  v_periodo                    CHAR(04)
) RETURNING CHAR (5), CHAR(100)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `v_periodo` | `CHAR(04)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `iSqlErr` | `INTEGER` | L5 |
| `cVarDataErr` | `CHAR(300)` | L6 |
| `cCodRet` | `CHAR(05)` | L9 |
| `v_vlr_prm` | `VARCHAR(100)` | L10 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sl_ftc_prm` | `bdilide` | no | SELECT | L34 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L39 | CÓDIGO_RETORNO | `LET cCodret = '00001';` |  |
| L49 | CÓDIGO_RETORNO | `LET cCodret = '00000';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `ftc` | ENTIDAD | FTC — módulo de configuración de transferencia de archivos ( | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `?_p` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `sw` | ENTIDAD | sw — SoftWare/Switch (subsistema sp_sw_ro_* — bdicnweb) | 🔴 SINTÉTICO | nombre_sp |
| `?p` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `ro` | ENTIDAD | ro — Rol Operativo (subsistema sp_sw_ro_* — bdicnweb) | 🔴 SINTÉTICO | nombre_sp |
| `x` | MODIF | por (criterio) | 🔵 CONVENCIÓN | nombre_sp |
| `?y` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_p`, `sw`, `?p`, `ro`, `?y` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_ftc_pswsftpdep`

| Campo | Valor |
|-------|-------|
| **Dominio** | D15 · `bdilide` · LIDE / PLD |
| **Archivo fuente** | `bdilide_sp_ftc_pswsftpdep.sql` |
| **LOC (1er CREATE)** | 54 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "FTC — módulo de configuración de transferencia de archivos, sw — SoftWare/Switch y depósito (tipo)" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 1 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=2 · INFERIDO=1 · SINTÉTICO=3 / 7 términos |

### Firma

```sql
CREATE PROCEDURE sp_ftc_pswsftpdep(
  v_periodo                    CHAR(04)
) RETURNING CHAR (5), CHAR(100)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `v_periodo` | `CHAR(04)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `iSqlErr` | `INTEGER` | L5 |
| `cVarDataErr` | `CHAR(300)` | L6 |
| `cCodRet` | `CHAR(05)` | L9 |
| `v_vlr_prm` | `VARCHAR(100)` | L10 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sl_ftc_prm` | `bdilide` | no | SELECT | L34 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L39 | CÓDIGO_RETORNO | `LET cCodret = '00001';` |  |
| L49 | CÓDIGO_RETORNO | `LET cCodret = '00000';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `ftc` | ENTIDAD | FTC — módulo de configuración de transferencia de archivos ( | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `?_p` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `sw` | ENTIDAD | sw — SoftWare/Switch (subsistema sp_sw_ro_* — bdicnweb) | 🔴 SINTÉTICO | nombre_sp |
| `?sf` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `tp` | MODIF | tipo | 🔵 CONVENCIÓN | nombre_sp |
| `dep` | ENTIDAD | depósito | 🟡 INFERIDO | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_p`, `sw`, `?sf` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_ftc_pswsftpext`

| Campo | Valor |
|-------|-------|
| **Dominio** | D15 · `bdilide` · LIDE / PLD |
| **Archivo fuente** | `bdilide_sp_ftc_pswsftpext.sql` |
| **LOC (1er CREATE)** | 54 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "FTC — módulo de configuración de transferencia de archivos y sw — SoftWare/Switch (tipo)" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 1 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=5 / 9 términos |

### Firma

```sql
CREATE PROCEDURE sp_ftc_pswsftpext(
  v_periodo                    CHAR(04)
) RETURNING CHAR (5), CHAR(100)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `v_periodo` | `CHAR(04)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `iSqlErr` | `INTEGER` | L5 |
| `cVarDataErr` | `CHAR(300)` | L6 |
| `cCodRet` | `CHAR(05)` | L9 |
| `v_vlr_prm` | `VARCHAR(100)` | L10 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sl_ftc_prm` | `bdilide` | no | SELECT | L34 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L39 | CÓDIGO_RETORNO | `LET cCodret = '00001';` |  |
| L49 | CÓDIGO_RETORNO | `LET cCodret = '00000';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `ftc` | ENTIDAD | FTC — módulo de configuración de transferencia de archivos ( | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `?_p` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `sw` | ENTIDAD | sw — SoftWare/Switch (subsistema sp_sw_ro_* — bdicnweb) | 🔴 SINTÉTICO | nombre_sp |
| `?sf` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `tp` | MODIF | tipo | 🔵 CONVENCIÓN | nombre_sp |
| `?e` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `x` | MODIF | por (criterio) | 🔵 CONVENCIÓN | nombre_sp |
| `?t` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_p`, `sw`, `?sf`, `?e`, `?t` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_ftc_ptoproxy`

| Campo | Valor |
|-------|-------|
| **Dominio** | D15 · `bdilide` · LIDE / PLD |
| **Archivo fuente** | `bdilide_sp_ftc_ptoproxy.sql` |
| **LOC (1er CREATE)** | 54 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "FTC — módulo de configuración de transferencia de archivos y ro — Rol Operativo" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 1 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=3 / 6 términos |

### Firma

```sql
CREATE PROCEDURE sp_ftc_ptoproxy(
  v_periodo                    CHAR(04)
) RETURNING CHAR (5), CHAR(100)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `v_periodo` | `CHAR(04)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `iSqlErr` | `INTEGER` | L5 |
| `cVarDataErr` | `CHAR(300)` | L6 |
| `cCodRet` | `CHAR(05)` | L9 |
| `v_vlr_prm` | `VARCHAR(100)` | L10 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sl_ftc_prm` | `bdilide` | no | SELECT | L34 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L39 | CÓDIGO_RETORNO | `LET cCodret = '00001';` |  |
| L49 | CÓDIGO_RETORNO | `LET cCodret = '00000';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `ftc` | ENTIDAD | FTC — módulo de configuración de transferencia de archivos ( | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `?_ptop` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `ro` | ENTIDAD | ro — Rol Operativo (subsistema sp_sw_ro_* — bdicnweb) | 🔴 SINTÉTICO | nombre_sp |
| `x` | MODIF | por (criterio) | 🔵 CONVENCIÓN | nombre_sp |
| `?y` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_ptop`, `ro`, `?y` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_ftc_ptosftp`

| Campo | Valor |
|-------|-------|
| **Dominio** | D15 · `bdilide` · LIDE / PLD |
| **Archivo fuente** | `bdilide_sp_ftc_ptosftp.sql` |
| **LOC (1er CREATE)** | 54 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "FTC — módulo de configuración de transferencia de archivos y OS — Originación de Solicitudes (tipo)" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 1 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=2 · INFERIDO=1 · SINTÉTICO=2 / 6 términos |

### Firma

```sql
CREATE PROCEDURE sp_ftc_ptosftp(
  v_periodo                    CHAR(04)
) RETURNING CHAR (5), CHAR(100)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `v_periodo` | `CHAR(04)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `iSqlErr` | `INTEGER` | L5 |
| `cVarDataErr` | `CHAR(300)` | L6 |
| `cCodRet` | `CHAR(05)` | L9 |
| `v_vlr_prm` | `VARCHAR(100)` | L10 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sl_ftc_prm` | `bdilide` | no | SELECT | L34 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L39 | CÓDIGO_RETORNO | `LET cCodret = '00001';` |  |
| L49 | CÓDIGO_RETORNO | `LET cCodret = '00000';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `ftc` | ENTIDAD | FTC — módulo de configuración de transferencia de archivos ( | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `?_pt` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `os` | ENTIDAD | OS — Originación de Solicitudes / subsistema de ofertas (sp_ | 🟡 INFERIDO | nombre_sp |
| `?f` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `tp` | MODIF | tipo | 🔵 CONVENCIÓN | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_pt`, `?f` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_ftc_rutadep`

| Campo | Valor |
|-------|-------|
| **Dominio** | D15 · `bdilide` · LIDE / PLD |
| **Archivo fuente** | `bdilide_sp_ftc_rutadep.sql` |
| **LOC (1er CREATE)** | 53 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "FTC — módulo de configuración de transferencia de archivos, ruta y depósito" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 1 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=1 · INFERIDO=1 · SINTÉTICO=0 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_ftc_rutadep(
  v_periodo                    CHAR(04)
) RETURNING CHAR (5), CHAR(50)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `v_periodo` | `CHAR(04)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `iSqlErr` | `INTEGER` | L5 |
| `cVarDataErr` | `CHAR(300)` | L6 |
| `cCodRet` | `CHAR(05)` | L9 |
| `v_vlr_prm` | `VARCHAR(100)` | L10 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sl_ftc_prm` | `bdilide` | no | SELECT | L34 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L39 | CÓDIGO_RETORNO | `LET cCodret = '00001';` |  |
| L48 | CÓDIGO_RETORNO | `LET cCodret = '00000';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `ftc` | ENTIDAD | FTC — módulo de configuración de transferencia de archivos ( | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `ruta` | ENTIDAD | ruta (de archivo) | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `dep` | ENTIDAD | depósito | 🟡 INFERIDO | nombre_sp |

---

## `sp_ftc_rutaext`

| Campo | Valor |
|-------|-------|
| **Dominio** | D15 · `bdilide` · LIDE / PLD |
| **Archivo fuente** | `bdilide_sp_ftc_rutaext.sql` |
| **LOC (1er CREATE)** | 53 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "FTC — módulo de configuración de transferencia de archivos y ruta" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 1 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=2 / 6 términos |

### Firma

```sql
CREATE PROCEDURE sp_ftc_rutaext(
  v_periodo                    CHAR(04)
) RETURNING CHAR (5), CHAR(100)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `v_periodo` | `CHAR(04)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `iSqlErr` | `INTEGER` | L5 |
| `cVarDataErr` | `CHAR(300)` | L6 |
| `cCodRet` | `CHAR(05)` | L9 |
| `v_vlr_prm` | `VARCHAR(100)` | L10 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sl_ftc_prm` | `bdilide` | no | SELECT | L34 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L39 | CÓDIGO_RETORNO | `LET cCodret = '00001';` |  |
| L48 | CÓDIGO_RETORNO | `LET cCodret = '00000';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `ftc` | ENTIDAD | FTC — módulo de configuración de transferencia de archivos ( | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `ruta` | ENTIDAD | ruta (de archivo) | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?e` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `x` | MODIF | por (criterio) | 🔵 CONVENCIÓN | nombre_sp |
| `?t` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?e`, `?t` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_ftc_usrproxy`

| Campo | Valor |
|-------|-------|
| **Dominio** | D15 · `bdilide` · LIDE / PLD |
| **Archivo fuente** | `bdilide_sp_ftc_usrproxy.sql` |
| **LOC (1er CREATE)** | 53 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "FTC — módulo de configuración de transferencia de archivos y ro — Rol Operativo" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 1 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=3 / 6 términos |

### Firma

```sql
CREATE PROCEDURE sp_ftc_usrproxy(
  v_periodo                    CHAR(04)
) RETURNING CHAR (5), CHAR(100)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `v_periodo` | `CHAR(04)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `iSqlErr` | `INTEGER` | L5 |
| `cVarDataErr` | `CHAR(300)` | L6 |
| `cCodRet` | `CHAR(05)` | L9 |
| `v_vlr_prm` | `VARCHAR(100)` | L10 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sl_ftc_prm` | `bdilide` | no | SELECT | L34 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L39 | CÓDIGO_RETORNO | `LET cCodret = '00001';` |  |
| L48 | CÓDIGO_RETORNO | `LET cCodret = '00000';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `ftc` | ENTIDAD | FTC — módulo de configuración de transferencia de archivos ( | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `?_usrp` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `ro` | ENTIDAD | ro — Rol Operativo (subsistema sp_sw_ro_* — bdicnweb) | 🔴 SINTÉTICO | nombre_sp |
| `x` | MODIF | por (criterio) | 🔵 CONVENCIÓN | nombre_sp |
| `?y` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_usrp`, `ro`, `?y` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_ftc_usrsftpdep`

| Campo | Valor |
|-------|-------|
| **Dominio** | D15 · `bdilide` · LIDE / PLD |
| **Archivo fuente** | `bdilide_sp_ftc_usrsftpdep.sql` |
| **LOC (1er CREATE)** | 53 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "FTC — módulo de configuración de transferencia de archivos y depósito (tipo)" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 1 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=2 · INFERIDO=1 · SINTÉTICO=1 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_ftc_usrsftpdep(
  v_periodo                    CHAR(04)
) RETURNING CHAR (5), CHAR(100)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `v_periodo` | `CHAR(04)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `iSqlErr` | `INTEGER` | L5 |
| `cVarDataErr` | `CHAR(300)` | L6 |
| `cCodRet` | `CHAR(05)` | L9 |
| `v_vlr_prm` | `VARCHAR(100)` | L10 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sl_ftc_prm` | `bdilide` | no | SELECT | L34 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L39 | CÓDIGO_RETORNO | `LET cCodret = '00001';` |  |
| L48 | CÓDIGO_RETORNO | `LET cCodret = '00000';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `ftc` | ENTIDAD | FTC — módulo de configuración de transferencia de archivos ( | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `?_usrsf` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `tp` | MODIF | tipo | 🔵 CONVENCIÓN | nombre_sp |
| `dep` | ENTIDAD | depósito | 🟡 INFERIDO | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_usrsf` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_ftc_usrsftpext`

| Campo | Valor |
|-------|-------|
| **Dominio** | D15 · `bdilide` · LIDE / PLD |
| **Archivo fuente** | `bdilide_sp_ftc_usrsftpext.sql` |
| **LOC (1er CREATE)** | 53 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "FTC — módulo de configuración de transferencia de archivos (tipo)" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 1 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=3 / 7 términos |

### Firma

```sql
CREATE PROCEDURE sp_ftc_usrsftpext(
  v_periodo                    CHAR(04)
) RETURNING CHAR (5), CHAR(100)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `v_periodo` | `CHAR(04)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `iSqlErr` | `INTEGER` | L5 |
| `cVarDataErr` | `CHAR(300)` | L6 |
| `cCodRet` | `CHAR(05)` | L9 |
| `v_vlr_prm` | `VARCHAR(100)` | L10 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sl_ftc_prm` | `bdilide` | no | SELECT | L34 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L39 | CÓDIGO_RETORNO | `LET cCodret = '00001';` |  |
| L48 | CÓDIGO_RETORNO | `LET cCodret = '00000';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `ftc` | ENTIDAD | FTC — módulo de configuración de transferencia de archivos ( | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `?_usrsf` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `tp` | MODIF | tipo | 🔵 CONVENCIÓN | nombre_sp |
| `?e` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `x` | MODIF | por (criterio) | 🔵 CONVENCIÓN | nombre_sp |
| `?t` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_usrsf`, `?e`, `?t` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_ftc_usrsokydep`

| Campo | Valor |
|-------|-------|
| **Dominio** | D15 · `bdilide` · LIDE / PLD |
| **Archivo fuente** | `bdilide_sp_ftc_usrsokydep.sql` |
| **LOC (1er CREATE)** | 54 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "FTC — módulo de configuración de transferencia de archivos y depósito" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 1 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=1 · INFERIDO=1 · SINTÉTICO=1 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_ftc_usrsokydep(
  v_periodo                    CHAR(04)
) RETURNING CHAR (5), CHAR(100)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `v_periodo` | `CHAR(04)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `iSqlErr` | `INTEGER` | L5 |
| `cVarDataErr` | `CHAR(300)` | L6 |
| `cCodRet` | `CHAR(05)` | L9 |
| `v_vlr_prm` | `VARCHAR(100)` | L10 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sl_ftc_prm` | `bdilide` | no | SELECT | L34 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L39 | CÓDIGO_RETORNO | `LET cCodret = '00001';` |  |
| L49 | CÓDIGO_RETORNO | `LET cCodret = '00000';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `ftc` | ENTIDAD | FTC — módulo de configuración de transferencia de archivos ( | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `?_usrsoky` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `dep` | ENTIDAD | depósito | 🟡 INFERIDO | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_usrsoky` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_ftc_usrsokyext`

| Campo | Valor |
|-------|-------|
| **Dominio** | D15 · `bdilide` · LIDE / PLD |
| **Archivo fuente** | `bdilide_sp_ftc_usrsokyext.sql` |
| **LOC (1er CREATE)** | 53 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "FTC — módulo de configuración de transferencia de archivos" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 1 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=2 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_ftc_usrsokyext(
  v_periodo                    CHAR(04)
) RETURNING CHAR (5), CHAR(100)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `v_periodo` | `CHAR(04)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `iSqlErr` | `INTEGER` | L5 |
| `cVarDataErr` | `CHAR(300)` | L6 |
| `cCodRet` | `CHAR(05)` | L9 |
| `v_vlr_prm` | `VARCHAR(100)` | L10 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sl_ftc_prm` | `bdilide` | no | SELECT | L34 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L39 | CÓDIGO_RETORNO | `LET cCodret = '00001';` |  |
| L48 | CÓDIGO_RETORNO | `LET cCodret = '00000';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `ftc` | ENTIDAD | FTC — módulo de configuración de transferencia de archivos ( | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `?_usrsokye` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `x` | MODIF | por (criterio) | 🔵 CONVENCIÓN | nombre_sp |
| `?t` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_usrsokye`, `?t` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_ftc_valcanal`

| Campo | Valor |
|-------|-------|
| **Dominio** | D15 · `bdilide` · LIDE / PLD |
| **Archivo fuente** | `bdilide_sp_ftc_valcanal.sql` |
| **LOC (1er CREATE)** | 54 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "FTC — módulo de configuración de transferencia de archivos y canal" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 1 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=1 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_ftc_valcanal(
  v_periodo                    CHAR(04)
) RETURNING CHAR (5), CHAR(50)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `v_periodo` | `CHAR(04)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `iSqlErr` | `INTEGER` | L5 |
| `cVarDataErr` | `CHAR(300)` | L6 |
| `cCodRet` | `CHAR(05)` | L9 |
| `v_vlr_prm` | `VARCHAR(100)` | L10 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sl_ftc_prm` | `bdilide` | no | SELECT | L34 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L39 | CÓDIGO_RETORNO | `LET cCodret = '00001';` |  |
| L49 | CÓDIGO_RETORNO | `LET cCodret = '00000';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `ftc` | ENTIDAD | FTC — módulo de configuración de transferencia de archivos ( | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `?_val` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `canal` | ENTIDAD | canal (de distribución) | ✅ CÓDIGO | nombre_sp, texto_cuerpo |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_val` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_ftc_valnombre`

| Campo | Valor |
|-------|-------|
| **Dominio** | D15 · `bdilide` · LIDE / PLD |
| **Archivo fuente** | `bdilide_sp_ftc_valnombre.sql` |
| **LOC (1er CREATE)** | 53 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "FTC — módulo de configuración de transferencia de archivos y nombre" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 1 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=1 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_ftc_valnombre(
  v_periodo                    CHAR(04)
) RETURNING CHAR (5), CHAR(50)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `v_periodo` | `CHAR(04)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `iSqlErr` | `INTEGER` | L5 |
| `cVarDataErr` | `CHAR(300)` | L6 |
| `cCodRet` | `CHAR(05)` | L9 |
| `v_vlr_prm` | `VARCHAR(100)` | L10 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sl_ftc_prm` | `bdilide` | no | SELECT | L34 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L39 | CÓDIGO_RETORNO | `LET cCodret = '00001';` |  |
| L48 | CÓDIGO_RETORNO | `LET cCodret = '00000';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `ftc` | ENTIDAD | FTC — módulo de configuración de transferencia de archivos ( | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `?_val` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `nombre` | ENTIDAD | nombre | ✅ CÓDIGO | nombre_sp, texto_cuerpo |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_val` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_generaarchivoconsultaide`

| Campo | Valor |
|-------|-------|
| **Dominio** | D15 · `bdilide` · LIDE / PLD |
| **Archivo fuente** | `bdilide_sp_generaarchivoconsultaide.sql` |
| **LOC (1er CREATE)** | 191 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "genera archivo y identificador" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `genera` → `INSERT` encontrado en el cuerpo · `genera` → `SELECT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=3 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=1 / 6 términos |

### Firma

```sql
CREATE PROCEDURE sp_generaarchivoconsultaide(
) RETURNING CHAR(6), CHAR(60)
```

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(6)` | L5 |
| `iSql_Err` | `INTEGER` | L6 |
| `iVeces` | `INTEGER` | L7 |
| `iRegs` | `INTEGER` | L8 |
| `cNumCte` | `CHAR(20)` | L9 |
| `cRfc` | `CHAR(12)` | L10 |
| `cDirectorio` | `CHAR(50)` | L11 |
| `dFechaHoy` | `DATE` | L12 |
| `cFechaHoy2` | `CHAR(8)` | L13 |
| `cSQL` | `CHAR(250)` | L14 |
| `cMensajeRetorno` | `CHAR(60)` | L15 |
| `cNombreArchivo` | `CHAR(20)` | L16 |
| `cNombreArchivoCtrl` | `CHAR(20)` | L17 |
| `cUsuario` | `CHAR(20)` | L18 |
| `cCASFIM` | `CHAR(20)` | L19 |
| `iRfc` | `INTEGER` | L20 |
| `vexiste` | `INTEGER` | L21 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sc_fechas` | `bdicheq` | ⚠️ sí | SELECT | L57 |
| `sl_procesos` | `bdilide` | no | SELECT | L61 |
| `sl_parametros` | `bdilide` | no | SELECT | L67 |
| `sl_archivoconsulta` | `bdilide` | no | SELECT | L93 |
| `sl_archivoconsulta` | `bdilide` | no | DELETE | L93 |
| `sl_archivocontrol` | `bdilide` | no | SELECT | L94 |
| `sl_archivocontrol` | `bdilide` | no | DELETE | L94 |
| `sl_consat` | `bdilide` | no | SELECT | L104 |
| `sl_archivoconsulta` | `bdilide` | no | INSERT | L110 |
| `sl_archivocontrol` | `bdilide` | no | INSERT | L151 |
| `sl_procesos` | `bdilide` | no | INSERT | L170 |
| `sl_consat` | `bdilide` | no | UPDATE | L174 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L83 | VALIDACIÓN_NULL | `IF (dFechaHoy IS NULL OR dFechaHoy = '') OR (iVeces IS NULL OR iVeces = '') OR (cDirectorio IS NULL ` |  |
| L89 | VALIDACIÓN_NULL | `IF iRegs IS NULL THEN` |  |
| L118 | FÓRMULA | `LET iRegs = iRegs - 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `genera` | ACCION | genera / produce | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `archivo` | ENTIDAD | archivo | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `consulta` | ACCION | consulta / lee | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `id` | ENTIDAD | identificador (de) | 🔵 CONVENCIÓN | nombre_sp |
| `?e` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?e` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_generaarchivosat`

| Campo | Valor |
|-------|-------|
| **Dominio** | D15 · `bdilide` · LIDE / PLD |
| **Archivo fuente** | `bdilide_sp_generaarchivosat.sql` |
| **LOC (1er CREATE)** | 924 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "genera archivos" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `genera` → `INSERT` encontrado en el cuerpo · `genera` → `SELECT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=1 / 4 términos |

### Historia del SP

| Tipo | Valor |
|------|-------|
| AUTOR | Alejandro Osuna |
| PROYECTO | Excencion de personas morales |
| ACTIVIDAD | Se crean los diferentes archivos de envio al SAT |
| FECHA | 08 de septiembre de 2008 |

### Firma

```sql
CREATE PROCEDURE sp_generaarchivosat(
  cTipoArchivo                 CHAR(2)
  pUsuario                     CHAR(8)
  cNomArchivo                  VARCHAR (20)
  cArchivoControl              VARCHAR (20)
) RETURNING CHAR(6), CHAR(20), CHAR(1), CHAR(40),CHAR(200), CHAR(1)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `cTipoArchivo` | `CHAR(2)` | — | — |
| `pUsuario` | `CHAR(8)` | — | — |
| `cNomArchivo` | `VARCHAR (20)` | — | — |
| `cArchivoControl` | `VARCHAR (20)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vsqlerr` | `INTEGER` | L11 |
| `cCodRet` | `CHAR(6)` | L12 |
| `pTipoError` | `CHAR(1)` | L13 |
| `pSpLlamado` | `CHAR(40)` | L14 |
| `pMostrado` | `CHAR(1)` | L15 |
| `tHora` | `CHAR (25)` | L16 |
| `cHora` | `CHAR (2)` | L17 |
| `cNumArchivo` | `CHAR(1)` | L18 |
| `cPrefijo` | `CHAR(2)` | L19 |
| `cClaveBan` | `CHAR(5)` | L20 |
| `cFechaArc` | `CHAR(8)` | L21 |
| `cFechaSer` | `CHAR(10)` | L22 |
| `cNombre` | `CHAR(16)` | L23 |
| `sRuta` | `CHAR(90)` | L24 |
| `sRutaFinal` | `CHAR(90)` | L25 |
| `vsSQL` | `CHAR (1000)` | L26 |
| `vsSQL1` | `CHAR (300)` | L27 |
| `vsSQL2` | `CHAR (400)` | L28 |
| `vsSQL3` | `CHAR (150)` | L29 |
| `vsSQLC` | `CHAR (1000)` | L30 |
| `vsSQL1C` | `CHAR (300)` | L31 |
| `vsSQL2C` | `CHAR (400)` | L32 |
| `vsSQL3C` | `CHAR (150)` | L33 |
| `cFechaRes` | `DATE` | L34 |
| `cStatus` | `CHAR(1)` | L35 |
| *…43 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sl_archsat` | `bdilide` | no | UPDATE | L163 |
| `sl_consat` | `bdilide` | no | UPDATE | L164 |
| `sl_parametros` | `bdilide` | no | SELECT | L226 |
| `si_fechas` | `bdinteg` | ⚠️ sí | SELECT | L234 |
| `sl_consat` | `bdilide` | no | SELECT | L242 |
| `sl_archsat` | `bdilide` | no | SELECT | L244 |
| `sl_procesos` | `bdilide` | no | INSERT | L276 |
| `sl_archsat` | `bdilide` | no | INSERT | L278 |
| `systabnames` | `sysmaster` | ⚠️ sí | SELECT | L312 |
| `sl_controlconsulta` | `bdilide` | no | INSERT | L320 |
| `sl_controlconsulta` | `bdilide` | no | SELECT | L331 |
| `sl_archivoscontrolsatresp` | `bdilide` | no | INSERT | L403 |
| `sl_archivossatresp` | `bdilide` | no | INSERT | L421 |
| `sl_archivoscontrolsat` | `bdilide` | no | INSERT | L443 |
| `sl_archivossat` | `bdilide` | no | INSERT | L463 |
| `sl_archivoscontrolsatresp` | `bdilide` | no | SELECT | L475 |
| `sl_archivoscontrolsat` | `bdilide` | no | SELECT | L478 |
| `sl_archivossatresp` | `bdilide` | no | SELECT | L479 |
| `sl_acuse` | `bdilide` | no | INSERT | L500 |
| `sl_acuse` | `bdilide` | no | SELECT | L506 |
| `sl_procesos` | `bdilide` | no | UPDATE | L546 |
| `sl_archivossat` | `bdilide` | no | SELECT | L560 |
| `sl_procesos` | `bdilide` | no | SELECT | L592 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_grabarerrores` | `bdilide` | no | L175 |
| `sp_eliminaarchivo` | `bdilide` | no | L176 |
| `sp_procesasat` | `bdilide` | no | L627 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L153 | VALIDACIÓN_NULL | `IF (cNombreError = '') or (cNombreError is null) THEN` |  |
| L156 | VALIDACIÓN_NULL | `IF (pMensaje = '') or (pMensaje is null) THEN` |  |
| L217 | VALIDACIÓN_NULL | `IF cTipoArchivo = "" or cTipoArchivo is NULL THEN` |  |
| L371 | VALIDACIÓN_NULL | `IF (cNomArchivo = "" OR cNomArchivo IS NULL)  OR ( cArchivoControl = "" OR cArchivoControl IS NULL) ` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `genera` | ACCION | genera / produce | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `archivos` | ENTIDAD | archivos | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?at` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?at` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_generaarchivosatsegundo`

| Campo | Valor |
|-------|-------|
| **Dominio** | D15 · `bdilide` · LIDE / PLD |
| **Archivo fuente** | `bdilide_sp_generaarchivosatsegundo.sql` |
| **LOC (1er CREATE)** | 802 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "genera archivos y [polisemia] Seguridad" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `genera` → `INSERT` encontrado en el cuerpo · `genera` → `SELECT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=2 / 6 términos |

### Historia del SP

| Tipo | Valor |
|------|-------|
| AUTOR | Alejandro Osuna |
| PROYECTO | Excencion de personas morales |
| ACTIVIDAD | Se crean los diferentes archivos de envio al SAT |
| FECHA | 08 de septiembre de 2008 |

### Firma

```sql
CREATE PROCEDURE sp_generaarchivosatsegundo(
  cTipoArchivo                 CHAR(2)
  pUsuario                     CHAR(8)
  cNomArchivo                  VARCHAR (20)
  cArchivoControl              VARCHAR (20)
) RETURNING CHAR(6), CHAR(20), CHAR(1), CHAR(40),CHAR(200), CHAR(1)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `cTipoArchivo` | `CHAR(2)` | — | — |
| `pUsuario` | `CHAR(8)` | — | — |
| `cNomArchivo` | `VARCHAR (20)` | — | — |
| `cArchivoControl` | `VARCHAR (20)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vsqlerr` | `INTEGER` | L11 |
| `cCodRet` | `CHAR(6)` | L12 |
| `pTipoError` | `CHAR(1)` | L13 |
| `pSpLlamado` | `CHAR(40)` | L14 |
| `pMostrado` | `CHAR(1)` | L15 |
| `tHora` | `CHAR (25)` | L16 |
| `cHora` | `CHAR (2)` | L17 |
| `cNumArchivo` | `CHAR(1)` | L18 |
| `cPrefijo` | `CHAR(2)` | L19 |
| `cClaveBan` | `CHAR(5)` | L20 |
| `cFechaArc` | `CHAR(8)` | L21 |
| `cFechaSer` | `CHAR(10)` | L22 |
| `cNombre` | `CHAR(16)` | L23 |
| `sRuta` | `CHAR(90)` | L24 |
| `sRutaFinal` | `CHAR(90)` | L25 |
| `vsSQL` | `CHAR (1000)` | L26 |
| `vsSQL1` | `CHAR (300)` | L27 |
| `vsSQL2` | `CHAR (400)` | L28 |
| `vsSQL3` | `CHAR (150)` | L29 |
| `vsSQLC` | `CHAR (1000)` | L30 |
| `vsSQL1C` | `CHAR (300)` | L31 |
| `vsSQL2C` | `CHAR (400)` | L32 |
| `vsSQL3C` | `CHAR (150)` | L33 |
| `cFechaRes` | `DATE` | L34 |
| `cStatus` | `CHAR(1)` | L35 |
| *…43 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sl_archsat` | `bdilide` | no | UPDATE | L160 |
| `sl_parametros` | `bdilide` | no | SELECT | L228 |
| `si_fechas` | `bdinteg` | ⚠️ sí | SELECT | L236 |
| `systabnames` | `sysmaster` | ⚠️ sí | SELECT | L260 |
| `sl_acuse` | `bdilide` | no | INSERT | L283 |
| `sl_procesos` | `bdilide` | no | SELECT | L285 |
| `sl_procesos` | `bdilide` | no | INSERT | L292 |
| `sl_archsat` | `bdilide` | no | SELECT | L295 |
| `sl_acuse` | `bdilide` | no | SELECT | L306 |
| `sl_archsat` | `bdilide` | no | INSERT | L320 |
| `sl_archivossatresp` | `bdilide` | no | INSERT | L362 |
| `sl_archivoscontrolsat` | `bdilide` | no | INSERT | L376 |
| `sl_archivoscontrolsat` | `bdilide` | no | SELECT | L384 |
| `sl_archivossatresp` | `bdilide` | no | SELECT | L388 |
| `sl_procesos` | `bdilide` | no | UPDATE | L490 |
| `sl_consat` | `bdilide` | no | UPDATE | L735 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_grabarerrores` | `bdilide` | no | L168 |
| `sp_eliminaarchivo` | `bdilide` | no | L177 |
| `sp_procesasat` | `bdilide` | no | L450 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L152 | VALIDACIÓN_NULL | `IF (cNombreError = '') or (cNombreError is null) THEN` |  |
| L155 | VALIDACIÓN_NULL | `IF (pMensaje = '') or (pMensaje is null) THEN` |  |
| L220 | VALIDACIÓN_NULL | `IF cTipoArchivo = "" or cTipoArchivo is NULL THEN` |  |
| L243 | VALIDACIÓN_NULL | `IF (cNomArchivo = "") OR (cNomArchivo IS NULL) THEN` |  |
| L248 | VALIDACIÓN_NULL | `IF (cArchivoControl = "") OR (cArchivoControl IS NULL) THEN` |  |
| L342 | VALIDACIÓN_NULL | `IF (cNomArchivo = "" OR cNomArchivo IS NULL)   OR ( cArchivoControl = "" OR cArchivoControl IS NULL)` |  |
| L649 | VALIDACIÓN_NULL | `IF (pUsuario  = "" or pUsuario is NULL) OR (cNomArchivo = "" or cNomArchivo IS NULL)  THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `genera` | ACCION | genera / produce | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `archivos` | ENTIDAD | archivos | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?at` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `seg` | ENTIDAD | [polisemia] Seguridad (bdicnweb: usuarios, perfiles, app móv | 🔵 CONVENCIÓN | nombre_sp |
| `?undo` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?at`, `?undo` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_generafoliorepide`

| Campo | Valor |
|-------|-------|
| **Dominio** | D15 · `bdilide` · LIDE / PLD |
| **Archivo fuente** | `bdilide_sp_generafoliorepide.sql` |
| **LOC (1er CREATE)** | 49 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "genera folio y identificador" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `genera` → `SELECT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=5 · INFERIDO=0 · SINTÉTICO=1 / 6 términos |

### Firma

```sql
CREATE PROCEDURE sp_generafoliorepide(
  pClave                       CHAR(2)
) RETURNING CHAR(5) AS retorno,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pClave` | `CHAR(2)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `iSqlErr` | `INTEGER` | L5 |
| `cValRetorno` | `CHAR(5)` | L6 |
| `cValor` | `CHAR(8)` | L7 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sl_parametros` | `bdilide` | no | SELECT | L33 |
| `sl_parametros` | `bdilide` | no | UPDATE | L38 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L36 | FÓRMULA | `LET cValor = cValor + 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `genera` | ACCION | genera / produce | 🔵 CONVENCIÓN | nombre_sp |
| `folio` | ENTIDAD | folio | 🔵 CONVENCIÓN | nombre_sp |
| `rep` | ACCION | reporte | 🔵 CONVENCIÓN | nombre_sp |
| `id` | ENTIDAD | identificador (de) | 🔵 CONVENCIÓN | nombre_sp |
| `?e` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?e` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_grabararchivoproceso`

| Campo | Valor |
|-------|-------|
| **Dominio** | D15 · `bdilide` · LIDE / PLD |
| **Archivo fuente** | `bdilide_sp_grabararchivoproceso.sql` |
| **LOC (1er CREATE)** | 75 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "graba archivo y proceso" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 1 llamada(s): `sp_grabarerrores` |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=1 / 5 términos |

### Historia del SP

| Tipo | Valor |
|------|-------|
| ACTIVIDAD | Realiza registro a la tabla bdilide:sl_archsat y sl_procesos. |
| FECHA | 10/OCT/2008 --* |

### Firma

```sql
CREATE PROCEDURE sp_grabararchivoproceso(
  pTipo                        CHAR(1)
  pArchivo1                    CHAR(16)
  pArchivo2                    CHAR(16)
  pStatus                      CHAR(1)
  pUsuario                     CHAR(8)
) RETURNING CHAR(6)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pTipo` | `CHAR(1)` | — | — |
| `pArchivo1` | `CHAR(16)` | `archivo`=archivo | ✅ CÓDIGO |
| `pArchivo2` | `CHAR(16)` | `archivo`=archivo | ✅ CÓDIGO |
| `pStatus` | `CHAR(1)` | — | — |
| `pUsuario` | `CHAR(8)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vcCodRet` | `CHAR(6)` | L12 |
| `sql_err` | `INTEGER` | L13 |
| `vdFechaHoy` | `DATE` | L14 |
| `vcMensaje` | `CHAR(100)` | L15 |
| `cErrorSP` | `CHAR(6)` | L16 |
| `vcErrorTipo` | `CHAR(2)` | L17 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_fechas` | `bdinteg` | ⚠️ sí | SELECT | L50 |
| `sl_archsat` | `bdilide` | no | INSERT | L55 |
| `sl_procesos` | `bdilide` | no | SELECT | L60 |
| `sl_procesos` | `bdilide` | no | INSERT | L61 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_grabarerrores` | `bdilide` | no | L34 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `graba` | ACCION | graba / almacena | 🔵 CONVENCIÓN | nombre_sp |
| `?r` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `archivo` | ENTIDAD | archivo | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `proceso` | ENTIDAD | proceso | ✅ CÓDIGO | nombre_sp, texto_cuerpo |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?r` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_grabarerrores`

| Campo | Valor |
|-------|-------|
| **Dominio** | D15 · `bdilide` · LIDE / PLD |
| **Archivo fuente** | `bdilide_sp_grabarerrores.sql` |
| **LOC (1er CREATE)** | 47 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "graba error" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 2 tabla(s) con operaciones: INSERT, SELECT |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=2 / 5 términos |

### Historia del SP

| Tipo | Valor |
|------|-------|
| ACTIVIDAD | Realiza registro a la tabla bdilide:sl_errores. |
| FECHA | 10/SEP/2008 --* |

### Firma

```sql
CREATE PROCEDURE sp_grabarerrores(
  pArchivo                     CHAR(16)
  pCodigoError                 CHAR(6)
  pTipoError                   CHAR(1)
  pSPllamdo                    CHAR(40)
  pMensaje                     CHAR(200)
  pMostrado                    CHAR(1)
) RETURNING CHAR(6)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pArchivo` | `CHAR(16)` | — | — |
| `pCodigoError` | `CHAR(6)` | `error`=error | 🔵 CONVENCIÓN |
| `pTipoError` | `CHAR(1)` | `error`=error | 🔵 CONVENCIÓN |
| `pSPllamdo` | `CHAR(40)` | `sp`=stored procedure | 🔵 CONVENCIÓN |
| `pMensaje` | `CHAR(200)` | — | — |
| `pMostrado` | `CHAR(1)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vcCodRet` | `CHAR(6)` | L11 |
| `sql_err` | `INTEGER` | L12 |
| `vdFechaError` | `DATE` | L13 |
| `vdHoraError` | `DATETIME hour to fraction(3)` | L14 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sl_archsat` | `bdilide` | no | SELECT | L35 |
| `sl_errores` | `bdilide` | no | INSERT | L43 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L30 | VALIDACIÓN_NULL | `IF (pArchivo = '' or pArchivo IS NULL) or (pCodigoError = '' or pCodigoError IS NULL) or (pTipoError` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `graba` | ACCION | graba / almacena | 🔵 CONVENCIÓN | nombre_sp |
| `?r` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `error` | ENTIDAD | error | 🔵 CONVENCIÓN | nombre_sp |
| `?es` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?r`, `?es` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_grabarsat`

| Campo | Valor |
|-------|-------|
| **Dominio** | D15 · `bdilide` · LIDE / PLD |
| **Archivo fuente** | `bdilide_sp_grabarsat.sql` |
| **LOC (1er CREATE)** | 65 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "graba · SAT — Servicio de Administración Tributaria" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 2 tabla(s) con operaciones: INSERT, SELECT |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=1 / 4 términos |

### Historia del SP

| Tipo | Valor |
|------|-------|
| ACTIVIDAD | Realiza registro a la tabla bdilide:sl_constat. |
| FECHA | 02/SEP/2008 --* |

### Firma

```sql
CREATE PROCEDURE sp_grabarsat(
  pNumCte                      CHAR(20)
  pRFC                         CHAR(13)
  pFechaCons                   DATE
  pUserInsert                  CHAR(8)
) RETURNING CHAR(6)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pNumCte` | `CHAR(20)` | — | — |
| `pRFC` | `CHAR(13)` | — | — |
| `pFechaCons` | `DATE` | — | — |
| `pUserInsert` | `CHAR(8)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(6)` | L15 |
| `isql_err` | `INTEGER` | L16 |
| `dFechaInsert` | `DATE` | L17 |
| `vexiste` | `INTEGER` | L18 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sl_consat` | `bdilide` | no | SELECT | L47 |
| `sl_consat` | `bdilide` | no | INSERT | L57 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L40 | VALIDACIÓN_NULL | `IF (pNumCte = '' OR pNumCte IS NULL) OR (pRFC = '' OR pRFC IS NULL) OR (pFechaCons = '' OR pFechaCon` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `graba` | ACCION | graba / almacena | 🔵 CONVENCIÓN | nombre_sp |
| `?r` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `sat` | REG | SAT — Servicio de Administración Tributaria (CFDI, ISR, IVA) | 🔵 CONVENCIÓN | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?r` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_ideconstancias`

| Campo | Valor |
|-------|-------|
| **Dominio** | D15 · `bdilide` · LIDE / PLD |
| **Archivo fuente** | `bdilide_sp_ideconstancias.sql` |
| **LOC (1er CREATE)** | 198 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "consulta identificador" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=2 / 5 términos |

### Historia del SP

| Tipo | Valor |
|------|-------|
| AUTOR | Alejandro Osuna |
| PROYECTO | Correción Recaudacion del LIDE |
| ACTIVIDAD | Se modifico en el caso de que cuando el cliente sólo tuvo recaudación de periodos |
| FECHA | 01 de Septiembre de 2008 |
| MODIFICACION | Alejandro Osuna |
| ACTIVIDAD | Se modifico todas las variables money, se pasaron de (10,2) a (16,2) |
| FECHA | 07 de Enero de 2008 |
| MODIFICACION | Martin Miranda |
| ACTIVIDAD | Se modifico para tomar en cuenta el campo rfc_alterno y si este no existe tomara el campo rfc |
| FECHA | 11 de marzo del 2011 |

### Firma

```sql
CREATE PROCEDURE sp_ideconstancias(
  pTipo                        SMALLINT
  pNumeroCliente               CHAR(20)
  pFecha                       CHAR(6)
) RETURNING CHAR(5),  -- Codigo de Retorno
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pTipo` | `SMALLINT` | — | — |
| `pNumeroCliente` | `CHAR(20)` | — | — |
| `pFecha` | `CHAR(6)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(5)` | L41 |
| `cRfccontribuyente` | `CHAR(13)` | L42 |
| `cCurpcopntribuyente` | `CHAR(20)` | L43 |
| `cApellpaterno` | `CHAR(26)` | L44 |
| `cApellmaterno` | `CHAR(26)` | L45 |
| `cNombre1` | `CHAR(26)` | L46 |
| `cNombre2` | `CHAR(26)` | L47 |
| `cRazoncontribuyente` | `CHAR(60)` | L48 |
| `cRfcinstitucion` | `CHAR(13)` | L49 |
| `cRazoninstitucion` | `CHAR(60)` | L50 |
| `mImpacumulado` | `MONEY(16,2)` | L51 |
| `mImparecaudar` | `MONEY(16,2)` | L52 |
| `mImprecaudado` | `MONEY(16,2)` | L53 |
| `mImppendiente` | `MONEY(16,2)` | L54 |
| `mImpremanente` | `MONEY(16,2)` | L55 |
| `mTipocambio` | `CHAR(2)` | L56 |
| `cAuxFecha` | `CHAR(6)` | L57 |
| `cFolio` | `CHAR(20)` | L58 |
| `cTpo_persona` | `CHAR(2)` | L59 |
| `vexiste` | `INTEGER` | L60 |
| `cDesSufijo` | `CHAR(60)` | L61 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_cliente` | `bdinteg` | ⚠️ sí | SELECT | L95 |
| `si_sufijos` | `bdinteg` | ⚠️ sí | SELECT | L125 |
| `sl_parametros` | `bdilide` | no | SELECT | L134 |
| `sl_constancias` | `bdilide` | no | SELECT | L148 |
| `sl_retlide` | `bdilide` | no | SELECT | L156 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `id` | ENTIDAD | identificador (de) | 🔵 CONVENCIÓN | nombre_sp |
| `?e` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `cons` | ACCION | consulta | 🔵 CONVENCIÓN | nombre_sp |
| `?tancias` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?e`, `?tancias` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_ideconsultageneral`

| Campo | Valor |
|-------|-------|
| **Dominio** | D15 · `bdilide` · LIDE / PLD |
| **Archivo fuente** | `bdilide_sp_ideconsultageneral.sql` |
| **LOC (1er CREATE)** | 89 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "consulta identificador (general)" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo · `genera` → `SELECT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=1 / 5 términos |

### Historia del SP

| Tipo | Valor |
|------|-------|
| MODIFICACION | Juan A Coronel - Junio 2008 |
| MODIFICACION | Alejandro Osuna |
| ACTIVIDAD | Se modifico todas las variables money, se pasaron de (10,2) a (16,2) |
| FECHA | 07 de Enero de 2008 |

### Firma

```sql
CREATE PROCEDURE sp_ideconsultageneral(
  pNumeroCliente               CHAR(20)
  pFechaDepositos              CHAR(6)
  pFechaRecaudacion            CHAR(6)
) RETURNING CHAR(5),     -- Codigo de Retorno
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pNumeroCliente` | `CHAR(20)` | — | — |
| `pFechaDepositos` | `CHAR(6)` | — | — |
| `pFechaRecaudacion` | `CHAR(6)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vCodRet` | `CHAR(5)` | L23 |
| `vImpacumulado` | `MONEY(16,2)` | L24 |
| `vImprecaudado` | `MONEY(16,2)` | L25 |
| `vImppendiente` | `MONEY(16,2)` | L26 |
| `vImpperiodosant` | `MONEY(16,2)` | L27 |
| `vAno` | `CHAR(4)` | L28 |
| `vPorcentaje` | `CHAR(5)` | L29 |
| `vImpGravado` | `MONEY(16,2)` | L30 |
| `vImpaRecaudar` | `MONEY(16,2)` | L31 |
| `dDiaprimero` | `date` | L32 |
| `dDiaUltimo` | `date` | L33 |
| `AuxvCodRet` | `char(6)` | L34 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sl_retlide` | `bdilide` | no | SELECT | L54 |
| `sl_detlide` | `bdilide` | no | SELECT | L66 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_diaprimeroultimomesanio` | `bdinteg` | ⚠️ sí | L71 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L73 | FÓRMULA | `Let vCodRet = '200'; --Error al calcular rangos de fechas` |  |
| L86 | FÓRMULA | `Let vImppendiente = vImpaRecaudar - vImprecaudado;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `id` | ENTIDAD | identificador (de) | 🔵 CONVENCIÓN | nombre_sp |
| `?e` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `consulta` | ACCION | consulta / lee | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `general` | MODIF | general | 🔵 CONVENCIÓN | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?e` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_ideconsultamovofi`

| Campo | Valor |
|-------|-------|
| **Dominio** | D15 · `bdilide` · LIDE / PLD |
| **Archivo fuente** | `bdilide_sp_ideconsultamovofi.sql` |
| **LOC (1er CREATE)** | 171 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "consulta identificador, movimiento y oficio" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=4 · INFERIDO=1 · SINTÉTICO=1 / 6 términos |

### Historia del SP

| Tipo | Valor |
|------|-------|
| MODIFICACION | Clemente Angulo |
| ACTIVIDAD | Se valido el hecho que si el cliente presenta mas de 500 movimientos durante el mes, se manden subtotales diarios. |
| FECHA | 26 de Febrero de 2009 |

### Firma

```sql
CREATE PROCEDURE sp_ideconsultamovofi(
  pNumeroCliente               CHAR(20)
  pFecha                       CHAR(6)
  pSigRegistro                 SMALLINT
) RETURNING CHAR(5),    -- Codigo de Retorno
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pNumeroCliente` | `CHAR(20)` | — | — |
| `pFecha` | `CHAR(6)` | — | — |
| `pSigRegistro` | `SMALLINT` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vCantReg` | `SMALLINT` | L15 |
| `vCodRet` | `CHAR(5)` | L16 |
| `vCodRet2` | `CHAR(5)` | L17 |
| `vCodRet3` | `CHAR(50)` | L18 |
| `vFechamovM` | `DATE` | L19 |
| `vNumctaM` | `CHAR(20)` | L20 |
| `vSucursalM` | `CHAR(4)` | L21 |
| `vImpdepM` | `MONEY(16,2)` | L22 |
| `vNumreg` | `SMALLINT` | L23 |
| `vContMovtos` | `INTEGER` | L24 |
| `vDiasMes` | `SMALLINT` | L25 |
| `vCont` | `CHAR(2)` | L26 |
| `vTotDepDiarioM` | `MONEY(16,2)` | L27 |
| `iSQL_ERR` | `INTEGER` | L28 |
| `isam_ERR` | `INTEGER` | L29 |
| `desc_err` | `CHAR(50)` | L30 |
| `vMaxMovtos` | `CHAR(8)` | L31 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `systabnames` | `sysmaster` | ⚠️ sí | SELECT | L66 |
| `sl_parametros` | `bdilide` | no | SELECT | L72 |
| `sl_movefec_his` | `bdilide` | no | SELECT | L83 |
| `tmp_movtos_lide` | `bdilide` | no | INSERT | L137 |
| `statistics` | `bdilide` | no | UPDATE | L146 |
| `tmp_movtos_lide` | `bdilide` | no | SELECT | L151 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L75 | VALIDACIÓN_NULL | `IF vMaxMovtos IS NULL THEN` |  |
| L87 | VALIDACIÓN_NULL | `IF vContMovtos IS NULL THEN` |  |
| L101 | FÓRMULA | `LET vNumreg = vNumreg + 1;` |  |
| L105 | VALIDACIÓN_NULL | `IF vFechamovM IS NULL THEN` |  |
| L108 | VALIDACIÓN_NULL | `IF vNumctaM IS NULL THEN` |  |
| L111 | VALIDACIÓN_NULL | `IF vSucursalM IS NULL THEN` |  |
| L114 | VALIDACIÓN_NULL | `IF vImpdepM IS NULL THEN` |  |
| L118 | FÓRMULA | `LET vCantReg = vCantReg + 1;` |  |
| L154 | VALIDACIÓN_NULL | `IF vFechamovM IS NULL THEN` |  |
| L157 | VALIDACIÓN_NULL | `IF vNumctaM IS NULL THEN` |  |
| L160 | VALIDACIÓN_NULL | `IF vTotDepDiarioM IS NULL THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `id` | ENTIDAD | identificador (de) | 🔵 CONVENCIÓN | nombre_sp |
| `?e` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `consulta` | ACCION | consulta / lee | 🔵 CONVENCIÓN | nombre_sp |
| `mov` | ENTIDAD | movimiento | 🔵 CONVENCIÓN | nombre_sp |
| `ofi` | ENTIDAD | oficio | 🟡 INFERIDO | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?e` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_ideconsultarecofi`

| Campo | Valor |
|-------|-------|
| **Dominio** | D15 · `bdilide` · LIDE / PLD |
| **Archivo fuente** | `bdilide_sp_ideconsultarecofi.sql` |
| **LOC (1er CREATE)** | 87 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "consultar identificador y oficio" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=3 · INFERIDO=1 · SINTÉTICO=2 / 6 términos |

### Historia del SP

| Tipo | Valor |
|------|-------|
| MODIFICACION | Alejandro Osuna |
| ACTIVIDAD | Se modifico todas las variables money, se pasaron de (10,2) a (16,2) |
| FECHA | 07 de Enero de 2008 |

### Firma

```sql
CREATE PROCEDURE sp_ideconsultarecofi(
  pNumeroCliente               CHAR(20)
  pFecha                       CHAR(6)
  pSigRegistro                 SMALLINT
) RETURNING CHAR(5),    -- Codigo de Retorno
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pNumeroCliente` | `CHAR(20)` | — | — |
| `pFecha` | `CHAR(6)` | — | — |
| `pSigRegistro` | `SMALLINT` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vCantReg` | `SMALLINT` | L18 |
| `vCodRet` | `CHAR(5)` | L19 |
| `AuxvCodRet` | `CHAR(6)` | L20 |
| `vFechainsR` | `DATE` | L21 |
| `vNumctaR` | `CHAR(20)` | L22 |
| `vPeriodoR` | `CHAR(6)` | L23 |
| `vImprecR` | `MONEY(16,2)` | L24 |
| `vNumreg` | `SMALLINT` | L25 |
| `dDiaprimero` | `date` | L26 |
| `dDiaUltimo` | `date` | L27 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_diaprimeroultimomesanio` | `bdinteg` | ⚠️ sí | L38 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L40 | FÓRMULA | `Let vCodRet = '200'; --Error al calcular rangos de fechas` |  |
| L58 | FÓRMULA | `LET vNumreg = vNumreg + 1;` |  |
| L63 | VALIDACIÓN_NULL | `IF vFechainsR IS NULL THEN` |  |
| L66 | VALIDACIÓN_NULL | `IF vNumctaR IS NULL THEN` |  |
| L69 | VALIDACIÓN_NULL | `IF vPeriodoR IS NULL  THEN` |  |
| L72 | VALIDACIÓN_NULL | `IF vImprecR IS NULL THEN` |  |
| L75 | FÓRMULA | `LET vCantReg = vCantReg + 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `id` | ENTIDAD | identificador (de) | 🔵 CONVENCIÓN | nombre_sp |
| `?e` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `consultar` | ACCION | consultar | 🔵 CONVENCIÓN | nombre_sp |
| `?ec` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `ofi` | ENTIDAD | oficio | 🟡 INFERIDO | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?e`, `?ec` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_idegeneracmensual_2`

| Campo | Valor |
|-------|-------|
| **Dominio** | D15 · `bdilide` · LIDE / PLD |
| **Archivo fuente** | `bdilide_sp_idegeneracmensual_2.sql` |
| **LOC (1er CREATE)** | 127 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "genera identificador (mensual)" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `genera` → `INSERT` encontrado en el cuerpo · `genera` → `SELECT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=3 / 7 términos |

### Firma

```sql
CREATE PROCEDURE sp_idegeneracmensual_2(
  pEmpresa                     CHAR(3)
  pFecha                       DATE
  pUsuario                     CHAR(8)
  pFechaultimodia              DATE
) RETURNING CHAR(5)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pEmpresa` | `CHAR(3)` | — | — |
| `pFecha` | `DATE` | — | — |
| `pUsuario` | `CHAR(8)` | — | — |
| `pFechaultimodia` | `DATE` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vCodRet` | `CHAR(5)` | L8 |
| `vNumcliente` | `CHAR(20)` | L9 |
| `vRfc` | `CHAR(13)` | L10 |
| `vImpacumulado` | `MONEY(16,2)` | L11 |
| `vImparecaudar` | `MONEY(16,2)` | L12 |
| `vImprecaudado` | `MONEY(16,2)` | L13 |
| `vImppendiente` | `MONEY(16,2)` | L14 |
| `vImpanterior` | `MONEY(16,2)` | L15 |
| `vTipocambio` | `MONEY(16,2)` | L16 |
| `vAniomes` | `CHAR(6)` | L17 |
| `vProceso` | `CHAR(10)` | L18 |
| `vcStatus` | `CHAR(1)` | L19 |
| `vmImpGrabado` | `MONEY(16,2)` | L20 |
| `vdUltimoDiaMes` | `DATE` | L21 |
| `vsqlerr` | `integer` | L22 |
| `vcAnio` | `CHAR(4)` | L23 |
| `vcIniciaTran` | `CHAR(1)` | L24 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sl_procesos` | `bdilide` | no | SELECT | L66 |
| `sl_procesos` | `bdilide` | no | INSERT | L73 |
| `sl_constancias` | `bdilide` | no | SELECT | L75 |
| `sl_constancias` | `bdilide` | no | DELETE | L75 |
| `sl_detlide` | `bdilide` | no | SELECT | L87 |
| `sl_retlide` | `bdilide` | no | SELECT | L95 |
| `sl_constancias` | `bdilide` | no | INSERT | L111 |
| `sl_procesos` | `bdilide` | no | UPDATE | L116 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L72 | VALIDACIÓN_NULL | `IF vcStatus IS NULL THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `id` | ENTIDAD | identificador (de) | 🔵 CONVENCIÓN | nombre_sp |
| `?e` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `genera` | ACCION | genera / produce | 🔵 CONVENCIÓN | nombre_sp |
| `?c` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `mensual` | MODIF | mensual | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?_2` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?e`, `?c`, `?_2` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_idegeneraconstanciaanual`

| Campo | Valor |
|-------|-------|
| **Dominio** | D15 · `bdilide` · LIDE / PLD |
| **Archivo fuente** | `bdilide_sp_idegeneraconstanciaanual.sql` |
| **LOC (1er CREATE)** | 185 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "genera identificador" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `genera` → `INSERT` encontrado en el cuerpo · `genera` → `SELECT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=4 · INFERIDO=0 · SINTÉTICO=2 / 6 términos |

### Firma

```sql
CREATE PROCEDURE sp_idegeneraconstanciaanual(
  pFecha                       DATE
  pUsuario                     CHAR(8)
) RETURNING CHAR(5)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pFecha` | `DATE` | — | — |
| `pUsuario` | `CHAR(8)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vCodRet` | `CHAR(5)` | L8 |
| `vNumcliente` | `CHAR(20)` | L9 |
| `vRfc` | `CHAR(13)` | L10 |
| `vSumImpGrabado` | `MONEY(16,2)` | L11 |
| `vSumImparecaudar` | `MONEY(16,2)` | L12 |
| `vSumImprecaudado` | `MONEY(16,2)` | L13 |
| `vSumImppendiente` | `MONEY(16,2)` | L14 |
| `vSumImpanterior` | `MONEY(16,2)` | L15 |
| `vTipocambio` | `MONEY(16,2)` | L16 |
| `vAniomes` | `CHAR(6)` | L17 |
| `vAnio` | `CHAR(4)` | L18 |
| `vcAnioActual` | `CHAR(4)` | L19 |
| `vMesActual` | `CHAR(2)` | L20 |
| `vcMes` | `CHAR(2)` | L21 |
| `vcDia` | `CHAR(2)` | L22 |
| `vcDiaActual` | `CHAR(2)` | L23 |
| `vProceso` | `CHAR(10)` | L24 |
| `vsqlerr` | `INTEGER` | L25 |
| `vdAnioPasado` | `DATE` | L26 |
| `vcStatus` | `CHAR(1)` | L27 |
| `vcAnioAnterior` | `INT` | L28 |
| `vdFecha` | `char(10)` | L29 |
| `vdFechaActual` | `DATE` | L30 |
| `viFechaRecibida` | `INT` | L31 |
| `viFechaInicio` | `INT` | L32 |
| *…3 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_fechas` | `bdinteg` | ⚠️ sí | SELECT | L86 |
| `sl_procesos` | `bdilide` | no | SELECT | L118 |
| `sl_procesos` | `bdilide` | no | INSERT | L126 |
| `sl_constancias` | `bdilide` | no | SELECT | L130 |
| `sl_constancias` | `bdilide` | no | DELETE | L130 |
| `sl_retlide` | `bdilide` | no | SELECT | L148 |
| `si_cliente` | `bdinteg` | ⚠️ sí | SELECT | L152 |
| `sl_constancias` | `bdilide` | no | INSERT | L157 |
| `sl_procesos` | `bdilide` | no | UPDATE | L163 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L38 | CÓDIGO_RETORNO | `LET vCodRet = '00000';` |  |
| L94 | FÓRMULA | `LET vcAnioAnterior   = vcAnioActual -1;` |  |
| L112 | CÓDIGO_RETORNO | `LET vCodRet = '22222';` |  |
| L124 | VALIDACIÓN_NULL | `IF vcStatus IS NULL THEN` |  |
| L133 | CÓDIGO_RETORNO | `LET vCodRet = '00002';` |  |
| L154 | FÓRMULA | `LET  vSumImppendiente = (NVL(vSumImparecaudar,0) - NVL(vSumImprecaudado,0) );` |  |
| L167 | CÓDIGO_RETORNO | `LET vCodRet = '00001';` |  |
| L172 | CÓDIGO_RETORNO | `LET  vCodRet  = '11111';` |  |
| L179 | CÓDIGO_RETORNO | `LET  vCodRet  = '55555';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `id` | ENTIDAD | identificador (de) | 🔵 CONVENCIÓN | nombre_sp |
| `?e` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `genera` | ACCION | genera / produce | 🔵 CONVENCIÓN | nombre_sp |
| `cons` | ACCION | consulta | 🔵 CONVENCIÓN | nombre_sp |
| `?tanciaanual` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?e`, `?tanciaanual` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_idegeneraconstanciaanual_esp`

| Campo | Valor |
|-------|-------|
| **Dominio** | D15 · `bdilide` · LIDE / PLD |
| **Archivo fuente** | `bdilide_sp_idegeneraconstanciaanual_esp.sql` |
| **LOC (1er CREATE)** | 206 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "genera identificador (especial)" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `genera` → `INSERT` encontrado en el cuerpo · `genera` → `SELECT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=5 · INFERIDO=0 · SINTÉTICO=2 / 7 términos |

### Firma

```sql
CREATE PROCEDURE sp_idegeneraconstanciaanual_esp(
  pFecha                       DATE
  pUsuario                     CHAR(8)
) RETURNING CHAR(5)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pFecha` | `DATE` | — | — |
| `pUsuario` | `CHAR(8)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vCodRet` | `CHAR(5)` | L8 |
| `vNumcliente` | `CHAR(20)` | L9 |
| `vRfc` | `CHAR(13)` | L10 |
| `vSumImpGrabado` | `MONEY(16,2)` | L11 |
| `vSumImparecaudar` | `MONEY(16,2)` | L12 |
| `vSumImprecaudado` | `MONEY(16,2)` | L13 |
| `vSumImppendiente` | `MONEY(16,2)` | L14 |
| `vSumImpanterior` | `MONEY(16,2)` | L15 |
| `vTipocambio` | `MONEY(16,2)` | L16 |
| `vAniomes` | `CHAR(6)` | L17 |
| `vAnio` | `CHAR(4)` | L18 |
| `vcAnioActual` | `CHAR(4)` | L19 |
| `vMesActual` | `CHAR(2)` | L20 |
| `vcMes` | `CHAR(2)` | L21 |
| `vcDia` | `CHAR(2)` | L22 |
| `vcDiaActual` | `CHAR(2)` | L23 |
| `vProceso` | `CHAR(10)` | L24 |
| `vsqlerr` | `INTEGER` | L25 |
| `vdAnioPasado` | `DATE` | L26 |
| `vcStatus` | `CHAR(1)` | L27 |
| `vcAnioAnterior` | `INT` | L28 |
| `vdFecha` | `char(10)` | L29 |
| `vdFechaActual` | `DATE` | L30 |
| `viFechaRecibida` | `INT` | L31 |
| `viFechaInicio` | `INT` | L32 |
| *…5 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sl_procesos` | `bdilide` | no | SELECT | L124 |
| `sl_procesos` | `bdilide` | no | INSERT | L132 |
| `sl_constancias` | `bdilide` | no | SELECT | L136 |
| `sl_constancias` | `bdilide` | no | DELETE | L136 |
| `sl_retlide` | `bdilide` | no | SELECT | L150 |
| `si_cliente` | `bdinteg` | ⚠️ sí | SELECT | L160 |
| `sl_constancias` | `bdilide` | no | INSERT | L165 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L40 | CÓDIGO_RETORNO | `LET vCodRet = '00000';` |  |
| L58 | FÓRMULA | `LET vcomienza = -1;` |  |
| L99 | FÓRMULA | `LET vcAnioAnterior   = vcAnioActual -1;` |  |
| L117 | CÓDIGO_RETORNO | `LET vCodRet = '22222';` |  |
| L130 | VALIDACIÓN_NULL | `IF vcStatus IS NULL THEN` |  |
| L139 | CÓDIGO_RETORNO | `LET vCodRet = '00002';` |  |
| L162 | FÓRMULA | `LET  vSumImppendiente = (NVL(vSumImparecaudar,0) - NVL(vSumImprecaudado,0) );` |  |
| L168 | FÓRMULA | `LET vcontador = vcontador + 1;` |  |
| L192 | CÓDIGO_RETORNO | `LET  vCodRet  = '11111';` |  |
| L199 | CÓDIGO_RETORNO | `LET  vCodRet  = '55555';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `id` | ENTIDAD | identificador (de) | 🔵 CONVENCIÓN | nombre_sp |
| `?e` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `genera` | ACCION | genera / produce | 🔵 CONVENCIÓN | nombre_sp |
| `cons` | ACCION | consulta | 🔵 CONVENCIÓN | nombre_sp |
| `?tanciaanual_` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `esp` | MODIF | especial | 🔵 CONVENCIÓN | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?e`, `?tanciaanual_` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_idegeneraconstanciamensual`

| Campo | Valor |
|-------|-------|
| **Dominio** | D15 · `bdilide` · LIDE / PLD |
| **Archivo fuente** | `bdilide_sp_idegeneraconstanciamensual.sql` |
| **LOC (1er CREATE)** | 261 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "genera identificador (mensual)" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `genera` → `INSERT` encontrado en el cuerpo · `genera` → `SELECT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=4 · INFERIDO=0 · SINTÉTICO=2 / 7 términos |

### Firma

```sql
CREATE PROCEDURE sp_idegeneraconstanciamensual(
) RETURNING CHAR(5), INTEGER
```

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vCodRet` | `CHAR(5)` | L4 |
| `vCodRet2` | `CHAR(5)` | L5 |
| `vCodRet3` | `CHAR(50)` | L6 |
| `vsqlerr` | `INTEGER` | L7 |
| `visamerr` | `INTEGER` | L8 |
| `vdescerr` | `CHAR(50)` | L9 |
| `vcomienza` | `SMALLINT` | L10 |
| `vcontador` | `INTEGER` | L11 |
| `vcIniciaTran` | `CHAR(1)` | L12 |
| `pEmpresa` | `CHAR(3)` | L13 |
| `pFecha` | `DATE` | L14 |
| `vdUltimoDiaMes` | `DATE` | L15 |
| `vpri_dia_mes` | `DATE` | L16 |
| `vult_dia_mes` | `DATE` | L17 |
| `vfecha_hoy` | `DATE` | L18 |
| `vdia` | `CHAR(2)` | L19 |
| `vfecha_valida` | `DATE` | L20 |
| `vfecha_validada` | `DATE` | L21 |
| `vAniomes` | `CHAR(6)` | L22 |
| `vexiste` | `CHAR(25)` | L23 |
| `vcStatus` | `CHAR(1)` | L24 |
| `vmin_numcte` | `CHAR(20)` | L25 |
| `vmax_numcte` | `CHAR(20)` | L26 |
| `vNumcliente` | `CHAR(20)` | L27 |
| `vRfc` | `CHAR(13)` | L28 |
| *…8 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_fechas` | `bdinteg` | ⚠️ sí | SELECT | L96 |
| `sl_detlide` | `bdilide` | no | SELECT | L124 |
| `sl_procesos` | `bdilide` | no | SELECT | L129 |
| `sl_procesos` | `bdilide` | no | INSERT | L144 |
| `sl_constancias` | `bdilide` | no | SELECT | L149 |
| `sl_constancias` | `bdilide` | no | DELETE | L149 |
| `si_cliente` | `bdinteg` | ⚠️ sí | SELECT | L173 |
| `sl_retlide` | `bdilide` | no | SELECT | L193 |
| `sl_constancias` | `bdilide` | no | INSERT | L216 |
| `sl_procesos` | `bdilide` | no | UPDATE | L237 |
| `sx_contproc` | `bdinteg` | ⚠️ sí | INSERT | L248 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_valfechabil` | `bdicheq` | ⚠️ sí | L106 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L44 | FÓRMULA | `LET vcomienza       = -1;` |  |
| L104 | FÓRMULA | `LET vfecha_validada = vfecha_valida - 1;` |  |
| L112 | FÓRMULA | `LET vpri_dia_mes = vpri_dia_mes - 1;` |  |
| L143 | VALIDACIÓN_NULL | `IF vcStatus IS NULL THEN` |  |
| L176 | VALIDACIÓN_NULL | `IF vRfc is null THEN` |  |
| L187 | VALIDACIÓN_NULL | `IF vImpanterior is null THEN` |  |
| L197 | VALIDACIÓN_NULL | `IF vImpacumulado is null THEN` |  |
| L201 | VALIDACIÓN_NULL | `IF vmImpGrabado is null THEN` |  |
| L205 | VALIDACIÓN_NULL | `IF vImparecaudar is null THEN` |  |
| L209 | VALIDACIÓN_NULL | `IF vImprecaudado is null THEN` |  |
| L213 | FÓRMULA | `LET vImppendiente = vImparecaudar - vImprecaudado;` |  |
| L221 | FÓRMULA | `LET vcontador = vcontador + 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `id` | ENTIDAD | identificador (de) | 🔵 CONVENCIÓN | nombre_sp |
| `?e` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `genera` | ACCION | genera / produce | 🔵 CONVENCIÓN | nombre_sp |
| `cons` | ACCION | consulta | 🔵 CONVENCIÓN | nombre_sp |
| `?tancia` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `mensual` | MODIF | mensual | ✅ CÓDIGO | nombre_sp, texto_cuerpo |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?e`, `?tancia` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_idegeneraconstanciamensual_1011`

| Campo | Valor |
|-------|-------|
| **Dominio** | D15 · `bdilide` · LIDE / PLD |
| **Archivo fuente** | `bdilide_sp_idegeneraconstanciamensual_1011.sql` |
| **LOC (1er CREATE)** | 269 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "genera identificador (mensual)" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `genera` → `INSERT` encontrado en el cuerpo · `genera` → `SELECT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=4 · INFERIDO=0 · SINTÉTICO=3 / 8 términos |

### Firma

```sql
CREATE PROCEDURE sp_idegeneraconstanciamensual_1011(
) RETURNING CHAR(5), INTEGER
```

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vCodRet` | `CHAR(5)` | L5 |
| `vNumcliente` | `CHAR(20)` | L6 |
| `vRfc` | `CHAR(13)` | L7 |
| `vImpacumulado` | `MONEY(16,2)` | L8 |
| `vImparecaudar` | `MONEY(16,2)` | L9 |
| `vImprecaudado` | `MONEY(16,2)` | L10 |
| `vImppendiente` | `MONEY(16,2)` | L11 |
| `vImpanterior` | `MONEY(16,2)` | L12 |
| `vTipocambio` | `MONEY(16,2)` | L13 |
| `vAniomes` | `CHAR(6)` | L14 |
| `vProceso` | `CHAR(10)` | L15 |
| `vcStatus` | `CHAR(1)` | L16 |
| `vmImpGrabado` | `MONEY(16,2)` | L17 |
| `vdUltimoDiaMes` | `DATE` | L18 |
| `vsqlerr` | `INTEGER` | L19 |
| `vcIniciaTran` | `CHAR(1)` | L20 |
| `vexiste` | `CHAR(25)` | L21 |
| `vpri_dia_mes` | `DATE` | L22 |
| `vult_dia_mes` | `DATE` | L23 |
| `vmax_aniomes` | `CHAR(6)` | L24 |
| `vmin_aniomes` | `CHAR(6)` | L25 |
| `vmin_cuenta` | `CHAR(20)` | L26 |
| `vmax_cuenta` | `CHAR(20)` | L27 |
| `vcontador` | `INTEGER` | L28 |
| `vcuantos` | `INTEGER` | L29 |
| *…9 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_fechas` | `bdinteg` | ⚠️ sí | SELECT | L90 |
| `sl_detlide` | `bdilide` | no | SELECT | L131 |
| `sl_procesos` | `bdilide` | no | SELECT | L136 |
| `sl_procesos` | `bdilide` | no | INSERT | L151 |
| `sl_constancias` | `bdilide` | no | SELECT | L154 |
| `sl_constancias` | `bdilide` | no | DELETE | L154 |
| `si_cliente` | `bdinteg` | ⚠️ sí | SELECT | L178 |
| `sl_retlide` | `bdilide` | no | SELECT | L198 |
| `sl_constancias` | `bdilide` | no | INSERT | L221 |
| `sl_procesos` | `bdilide` | no | UPDATE | L241 |
| `sx_contproc` | `bdinteg` | ⚠️ sí | INSERT | L253 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_valfechabil` | `bdicheq` | ⚠️ sí | L102 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L62 | FÓRMULA | `LET vcontador = -1;` |  |
| L100 | FÓRMULA | `LET vfecha_validada = vfecha_valida - 1;` |  |
| L150 | VALIDACIÓN_NULL | `IF vcStatus IS NULL THEN` |  |
| L181 | VALIDACIÓN_NULL | `IF vRfc is null THEN` |  |
| L192 | VALIDACIÓN_NULL | `IF vImpanterior is null THEN` |  |
| L202 | VALIDACIÓN_NULL | `IF vImpacumulado is null THEN` |  |
| L206 | VALIDACIÓN_NULL | `IF vmImpGrabado is null THEN` |  |
| L210 | VALIDACIÓN_NULL | `IF vImparecaudar is null THEN` |  |
| L214 | VALIDACIÓN_NULL | `IF vImprecaudado is null THEN` |  |
| L218 | FÓRMULA | `LET vImppendiente = vImparecaudar - vImprecaudado;` |  |
| L226 | FÓRMULA | `LET vcontador = vcontador + 1;` |  |
| L247 | FÓRMULA | `LET vcuantos = vcuantos + vcontador;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `id` | ENTIDAD | identificador (de) | 🔵 CONVENCIÓN | nombre_sp |
| `?e` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `genera` | ACCION | genera / produce | 🔵 CONVENCIÓN | nombre_sp |
| `cons` | ACCION | consulta | 🔵 CONVENCIÓN | nombre_sp |
| `?tancia` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `mensual` | MODIF | mensual | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?_1011` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?e`, `?tancia`, `?_1011` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_idegeneraconstanciamensual_201212`

| Campo | Valor |
|-------|-------|
| **Dominio** | D15 · `bdilide` · LIDE / PLD |
| **Archivo fuente** | `bdilide_sp_idegeneraconstanciamensual_201212.sql` |
| **LOC (1er CREATE)** | 195 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "genera identificador (mensual)" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `genera` → `INSERT` encontrado en el cuerpo · `genera` → `SELECT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=4 · INFERIDO=0 · SINTÉTICO=3 / 8 términos |

### Firma

```sql
CREATE PROCEDURE sp_idegeneraconstanciamensual_201212(
) RETURNING CHAR(5), INTEGER
```

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vCodRet` | `CHAR(5)` | L4 |
| `vCodRet2` | `CHAR(5)` | L5 |
| `vCodRet3` | `CHAR(50)` | L6 |
| `vsqlerr` | `INTEGER` | L7 |
| `visamerr` | `INTEGER` | L8 |
| `vdescerr` | `CHAR(50)` | L9 |
| `vcomienza` | `SMALLINT` | L10 |
| `vcontador` | `INTEGER` | L11 |
| `vcIniciaTran` | `CHAR(1)` | L12 |
| `pFecha` | `DATE` | L14 |
| `vdUltimoDiaMes` | `DATE` | L15 |
| `vpri_dia_mes` | `DATE` | L16 |
| `vult_dia_mes` | `DATE` | L17 |
| `vfecha_hoy` | `DATE` | L18 |
| `vAniomes` | `CHAR(6)` | L19 |
| `vNumcliente` | `CHAR(20)` | L21 |
| `vexiste_cons` | `CHAR(25)` | L22 |
| `vRfc` | `CHAR(13)` | L23 |
| `vImpanterior` | `MONEY(16,2)` | L24 |
| `vImpacumulado` | `MONEY(16,2)` | L25 |
| `vmImpGrabado` | `MONEY(16,2)` | L26 |
| `vImparecaudar` | `MONEY(16,2)` | L27 |
| `vImprecaudado` | `MONEY(16,2)` | L28 |
| `vImppendiente` | `MONEY(16,2)` | L29 |
| `vTipocambio` | `MONEY(16,2)` | L30 |
| *…1 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sl_detlide` | `bdilide` | no | SELECT | L96 |
| `sl_constancias` | `bdilide` | no | SELECT | L108 |
| `sl_constancias` | `bdilide` | no | DELETE | L114 |
| `si_cliente` | `bdinteg` | ⚠️ sí | SELECT | L122 |
| `sl_retlide` | `bdilide` | no | SELECT | L142 |
| `sl_constancias` | `bdilide` | no | INSERT | L165 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L39 | FÓRMULA | `LET vcomienza    = -1;` |  |
| L125 | VALIDACIÓN_NULL | `IF vRfc is null THEN` |  |
| L136 | VALIDACIÓN_NULL | `IF vImpanterior is null THEN` |  |
| L146 | VALIDACIÓN_NULL | `IF vImpacumulado is null THEN` |  |
| L150 | VALIDACIÓN_NULL | `IF vmImpGrabado is null THEN` |  |
| L154 | VALIDACIÓN_NULL | `IF vImparecaudar is null THEN` |  |
| L158 | VALIDACIÓN_NULL | `IF vImprecaudado is null THEN` |  |
| L162 | FÓRMULA | `LET vImppendiente = vImparecaudar - vImprecaudado;` |  |
| L170 | FÓRMULA | `LET vcontador = vcontador + 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `id` | ENTIDAD | identificador (de) | 🔵 CONVENCIÓN | nombre_sp |
| `?e` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `genera` | ACCION | genera / produce | 🔵 CONVENCIÓN | nombre_sp |
| `cons` | ACCION | consulta | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `?tancia` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `mensual` | MODIF | mensual | 🔵 CONVENCIÓN | nombre_sp |
| `?_201212` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?e`, `?tancia`, `?_201212` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_idegeneraconstanciamensual_esp`

| Campo | Valor |
|-------|-------|
| **Dominio** | D15 · `bdilide` · LIDE / PLD |
| **Archivo fuente** | `bdilide_sp_idegeneraconstanciamensual_esp.sql` |
| **LOC (1er CREATE)** | 227 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "genera identificador (mensual, especial)" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `genera` → `INSERT` encontrado en el cuerpo · `genera` → `SELECT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=6 · INFERIDO=0 · SINTÉTICO=2 / 8 términos |

### Firma

```sql
CREATE PROCEDURE sp_idegeneraconstanciamensual_esp(
  pFechaIni                    DATE
  pFechaFin                    DATE
) RETURNING CHAR(5), INTEGER
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pFechaIni` | `DATE` | — | — |
| `pFechaFin` | `DATE` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vCodRet` | `CHAR(5)` | L4 |
| `vCodRet2` | `CHAR(5)` | L5 |
| `vCodRet3` | `CHAR(50)` | L6 |
| `vsqlerr` | `INTEGER` | L7 |
| `visamerr` | `INTEGER` | L8 |
| `vdescerr` | `CHAR(50)` | L9 |
| `vAniomes` | `CHAR(6)` | L10 |
| `vpri_dia_mes` | `DATE` | L11 |
| `vult_dia_mes` | `DATE` | L12 |
| `vConstancias` | `INTEGER` | L13 |
| `vcNumCte` | `CHAR(20)` | L14 |
| `vcRfc` | `CHAR(13)` | L15 |
| `vComienza` | `SMALLINT` | L16 |
| `viTransacc` | `SMALLINT` | L17 |
| `viContCommit` | `INTEGER` | L18 |
| `vmin_aniomes` | `CHAR(6)` | L19 |
| `vmax_aniomes` | `CHAR(6)` | L20 |
| `vmin_cuenta` | `CHAR(20)` | L21 |
| `vmax_cuenta` | `CHAR(20)` | L22 |
| `vNumcliente` | `CHAR(20)` | L23 |
| `vRfc` | `CHAR(13)` | L24 |
| `vImpacumulado` | `MONEY(16,2)` | L25 |
| `vImparecaudar` | `MONEY(16,2)` | L26 |
| `vImprecaudado` | `MONEY(16,2)` | L27 |
| `vImppendiente` | `MONEY(16,2)` | L28 |
| *…6 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sl_constancias` | `bdilide` | no | SELECT | L97 |
| `sl_constancias` | `bdilide` | no | DELETE | L117 |
| `sl_detlide` | `bdilide` | no | SELECT | L144 |
| `si_cliente` | `bdinteg` | ⚠️ sí | SELECT | L162 |
| `sl_retlide` | `bdilide` | no | SELECT | L184 |
| `sl_constancias` | `bdilide` | no | INSERT | L207 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L48 | FÓRMULA | `LET vComienza = -1;` |  |
| L65 | FÓRMULA | `LET vcontador = -1;` |  |
| L123 | FÓRMULA | `LET viContCommit = viContCommit + 1;` |  |
| L165 | VALIDACIÓN_NULL | `IF vRfc is null THEN` |  |
| L178 | VALIDACIÓN_NULL | `IF vImpanterior is null THEN` |  |
| L188 | VALIDACIÓN_NULL | `IF vImpacumulado is null THEN` |  |
| L192 | VALIDACIÓN_NULL | `IF vmImpGrabado is null THEN` |  |
| L196 | VALIDACIÓN_NULL | `IF vImparecaudar is null THEN` |  |
| L200 | VALIDACIÓN_NULL | `IF vImprecaudado is null THEN` |  |
| L204 | FÓRMULA | `LET vImppendiente = vImparecaudar - vImprecaudado;` |  |
| L212 | FÓRMULA | `LET vcontador = vcontador + 1;` |  |
| L218 | FÓRMULA | `LET vcuantos = vcuantos + vcontador;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `id` | ENTIDAD | identificador (de) | 🔵 CONVENCIÓN | nombre_sp |
| `?e` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `genera` | ACCION | genera / produce | 🔵 CONVENCIÓN | nombre_sp |
| `cons` | ACCION | consulta | 🔵 CONVENCIÓN | nombre_sp |
| `?tancia` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `mensual` | MODIF | mensual | 🔵 CONVENCIÓN | nombre_sp |
| `esp` | MODIF | especial | 🔵 CONVENCIÓN | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?e`, `?tancia` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_idetraspasomovtoshistorico`

| Campo | Valor |
|-------|-------|
| **Dominio** | D15 · `bdilide` · LIDE / PLD |
| **Archivo fuente** | `bdilide_sp_idetraspasomovtoshistorico.sql` |
| **LOC (1er CREATE)** | 234 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "traspaso entre cuentas identificador y movimiento (histórico)" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 1 llamada(s): `sp_actparamtraspmovefec` |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=4 · INFERIDO=0 · SINTÉTICO=2 / 7 términos |

### Firma

```sql
CREATE PROCEDURE sp_idetraspasomovtoshistorico(
) RETURNING CHAR(6)  AS codigo_retorno,
```

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(6)` | L5 |
| `cCodRet2` | `CHAR(6)` | L6 |
| `cCodRet3` | `CHAR(60)` | L7 |
| `iSqlErr` | `INTEGER` | L8 |
| `iIsamErr` | `INTEGER` | L9 |
| `cErrorInfo` | `CHAR(80)` | L10 |
| `cMensajeRet` | `CHAR(80)` | L11 |
| `cUser` | `CHAR(10)` | L12 |
| `dtFechaHoy` | `DATE` | L13 |
| `dtFechaAnt` | `DATE` | L14 |
| `dtPriDiaMes` | `DATE` | L15 |
| `dtUltDiaMes` | `DATE` | L16 |
| `dtFechaIni` | `DATE` | L17 |
| `dtFechaFin` | `DATE` | L18 |
| `viRegsTotxTrasp` | `INTEGER` | L19 |
| `iExisteGenCons` | `INTEGER` | L20 |
| `iExisteFecha` | `INTEGER` | L21 |
| `iRegsTot` | `INTEGER` | L22 |
| `iExisteProc` | `SMALLINT` | L23 |
| `vcCodRetParam` | `CHAR(5)` | L24 |
| `viSerialFinal` | `INTEGER` | L25 |
| `viRegsxTraspasar` | `INTEGER` | L26 |
| `dtFecha_mov` | `DATE` | L27 |
| `iNum_serial` | `INTEGER` | L28 |
| `iCont` | `INTEGER` | L29 |
| *…3 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_fechas` | `bdinteg` | ⚠️ sí | SELECT | L86 |
| `sl_movefec` | `bdilide` | no | SELECT | L95 |
| `sl_procesos` | `bdilide` | no | SELECT | L108 |
| `sl_trasp_movefec_movefechis` | `bdilide` | no | SELECT | L122 |
| `sl_trasp_movefec_movefechis` | `bdilide` | no | INSERT | L132 |
| `sl_procesos` | `bdilide` | no | INSERT | L144 |
| `sl_parametros` | `bdilide` | no | SELECT | L174 |
| `sl_movefec_his` | `bdilide` | no | INSERT | L195 |
| `sl_movefec` | `bdilide` | no | DELETE | L202 |
| `sl_movefec_his` | `bdilide` | no | SELECT | L214 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_actparamtraspmovefec` | `bdilide` | no | L156 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L89 | FÓRMULA | `LET dtFechaIni = dtPriDiaMes - 1 UNITS MONTH;` |  |
| L90 | FÓRMULA | `LET dtFechaFin = dtPriDiaMes - 1 UNITS DAY;` |  |
| L206 | FÓRMULA | `LET iCont = iCont +1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `id` | ENTIDAD | identificador (de) | 🔵 CONVENCIÓN | nombre_sp |
| `?e` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `traspaso` | ACCION | traspaso entre cuentas | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `movto` | ENTIDAD | movimiento | 🔵 CONVENCIÓN | nombre_sp |
| `?s` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `historico` | MODIF | histórico | 🔵 CONVENCIÓN | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?e`, `?s` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_idetraspasomovtoshistorico_esp`

| Campo | Valor |
|-------|-------|
| **Dominio** | D15 · `bdilide` · LIDE / PLD |
| **Archivo fuente** | `bdilide_sp_idetraspasomovtoshistorico_esp.sql` |
| **LOC (1er CREATE)** | 157 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "traspaso entre cuentas identificador y movimiento (histórico, especial)" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 6 tabla(s) con operaciones: INSERT, DELETE, SELECT |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=5 · INFERIDO=0 · SINTÉTICO=2 / 8 términos |

### Firma

```sql
CREATE PROCEDURE sp_idetraspasomovtoshistorico_esp(
  dtFecha                      DATE
) RETURNING CHAR(6)  AS codigo_retorno,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `dtFecha` | `DATE` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(6)` | L7 |
| `cMensajeRet` | `CHAR(80)` | L8 |
| `iSqlErr` | `INTEGER` | L9 |
| `iIsamErr` | `INTEGER` | L10 |
| `cErrorInfo` | `CHAR(80)` | L11 |
| `cUser` | `CHAR(10)` | L12 |
| `dtFechaUltDiaMes` | `DATE` | L14 |
| `cAniomes` | `CHAR(6)` | L15 |
| `cNum_cte` | `CHAR(20)` | L16 |
| `iNum_serial` | `INTEGER` | L17 |
| `cRfc` | `CHAR(13)` | L18 |
| `cRef_ret` | `CHAR(13)` | L19 |
| `cTipo_cta` | `CHAR(1)` | L20 |
| `cSucursal` | `CHAR(4)` | L21 |
| `cNum_cta` | `CHAR(20)` | L22 |
| `dtFecha_mov` | `DATE` | L23 |
| `ctran_central` | `CHAR(4)` | L24 |
| `mImp_tot_dep` | `MONEY(16,2)` | L25 |
| `mImp_ide` | `MONEY(16,2)` | L26 |
| `cUser_insert` | `CHAR(8)` | L27 |
| `dtFecha_insert` | `DATE` | L28 |
| `iCont` | `INTEGER` | L29 |
| `iBandera` | `INTEGER` | L30 |
| `cCommit` | `CHAR(1)` | L31 |
| `cStatus` | `CHAR(1)` | L32 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_fechas` | `bdinteg` | ⚠️ sí | SELECT | L80 |
| `sl_procesos` | `bdilide` | no | SELECT | L86 |
| `sl_procesos` | `bdilide` | no | INSERT | L97 |
| `sl_movefec` | `bdilide` | no | SELECT | L115 |
| `sl_movefec_his` | `bdilide` | no | INSERT | L120 |
| `sl_movefec` | `bdilide` | no | DELETE | L124 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L126 | FÓRMULA | `LET iCont= iCont +1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `id` | ENTIDAD | identificador (de) | 🔵 CONVENCIÓN | nombre_sp |
| `?e` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `traspaso` | ACCION | traspaso entre cuentas | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `movto` | ENTIDAD | movimiento | 🔵 CONVENCIÓN | nombre_sp |
| `?s` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `historico` | MODIF | histórico | 🔵 CONVENCIÓN | nombre_sp |
| `esp` | MODIF | especial | 🔵 CONVENCIÓN | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?e`, `?s` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_idetraspasomovtoshistoricocomp1`

| Campo | Valor |
|-------|-------|
| **Dominio** | D15 · `bdilide` · LIDE / PLD |
| **Archivo fuente** | `bdilide_sp_idetraspasomovtoshistoricocomp1.sql` |
| **LOC (1er CREATE)** | 208 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "traspaso entre cuentas identificador y movimiento (histórico, complemento)" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 7 tabla(s) con operaciones: INSERT, DELETE, SELECT |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=5 · INFERIDO=0 · SINTÉTICO=3 / 9 términos |

### Firma

```sql
CREATE PROCEDURE sp_idetraspasomovtoshistoricocomp1(
) RETURNING CHAR(6)  AS codigo_retorno,
```

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(6)` | L5 |
| `cCodRet2` | `CHAR(6)` | L6 |
| `cCodRet3` | `CHAR(60)` | L7 |
| `iSqlErr` | `INTEGER` | L8 |
| `iIsamErr` | `INTEGER` | L9 |
| `cErrorInfo` | `CHAR(80)` | L10 |
| `cMensajeRet` | `CHAR(80)` | L11 |
| `cUser` | `CHAR(10)` | L12 |
| `dtFechaHoy` | `DATE` | L13 |
| `dtFechaAnt` | `DATE` | L14 |
| `dtPriDiaMes` | `DATE` | L15 |
| `dtUltDiaMes` | `DATE` | L16 |
| `dtFechaIni` | `DATE` | L17 |
| `dtFechaFin` | `DATE` | L18 |
| `viRegsTotxTrasp` | `INTEGER` | L19 |
| `iExisteGenCons` | `INTEGER` | L20 |
| `iInicioProc` | `SMALLINT` | L21 |
| `iExisteFecha` | `INTEGER` | L22 |
| `iRegsTot` | `INTEGER` | L23 |
| `viSerialInicial` | `INTEGER` | L24 |
| `viSerialFinal` | `INTEGER` | L25 |
| `viRegsxTraspasar` | `INTEGER` | L26 |
| `dtFecha_mov` | `DATE` | L27 |
| `iNum_serial` | `INTEGER` | L28 |
| `iCont` | `INTEGER` | L29 |
| *…3 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_fechas` | `bdinteg` | ⚠️ sí | SELECT | L86 |
| `sl_movefec` | `bdilide` | no | SELECT | L95 |
| `sl_procesos` | `bdilide` | no | SELECT | L108 |
| `sl_parametros` | `bdilide` | no | SELECT | L132 |
| `sl_movefec_his` | `bdilide` | no | INSERT | L167 |
| `sl_movefec` | `bdilide` | no | DELETE | L174 |
| `sl_movefec_his` | `bdilide` | no | SELECT | L186 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L89 | FÓRMULA | `LET dtFechaIni = dtPriDiaMes - 1 UNITS MONTH;` |  |
| L90 | FÓRMULA | `LET dtFechaFin = dtPriDiaMes - 1 UNITS DAY;` |  |
| L178 | FÓRMULA | `LET iCont = iCont +1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `id` | ENTIDAD | identificador (de) | 🔵 CONVENCIÓN | nombre_sp |
| `?e` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `traspaso` | ACCION | traspaso entre cuentas | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `movto` | ENTIDAD | movimiento | 🔵 CONVENCIÓN | nombre_sp |
| `?s` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `historico` | MODIF | histórico | 🔵 CONVENCIÓN | nombre_sp |
| `comp` | MODIF | complemento | 🔵 CONVENCIÓN | nombre_sp |
| `?1` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?e`, `?s`, `?1` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_idetraspasomovtoshistoricocomp1_mod`

| Campo | Valor |
|-------|-------|
| **Dominio** | D15 · `bdilide` · LIDE / PLD |
| **Archivo fuente** | `bdilide_sp_idetraspasomovtoshistoricocomp1_mod.sql` |
| **LOC (1er CREATE)** | 208 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "traspaso entre cuentas identificador y movimiento (histórico, complemento)" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 7 tabla(s) con operaciones: INSERT, DELETE, SELECT |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=5 · INFERIDO=0 · SINTÉTICO=3 / 9 términos |

### Firma

```sql
CREATE PROCEDURE sp_idetraspasomovtoshistoricocomp1_mod(
) RETURNING CHAR(6)  AS codigo_retorno,
```

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(6)` | L5 |
| `cCodRet2` | `CHAR(6)` | L6 |
| `cCodRet3` | `CHAR(60)` | L7 |
| `iSqlErr` | `INTEGER` | L8 |
| `iIsamErr` | `INTEGER` | L9 |
| `cErrorInfo` | `CHAR(80)` | L10 |
| `cMensajeRet` | `CHAR(80)` | L11 |
| `cUser` | `CHAR(10)` | L12 |
| `dtFechaHoy` | `DATE` | L13 |
| `dtFechaAnt` | `DATE` | L14 |
| `dtPriDiaMes` | `DATE` | L15 |
| `dtUltDiaMes` | `DATE` | L16 |
| `dtFechaIni` | `DATE` | L17 |
| `dtFechaFin` | `DATE` | L18 |
| `viRegsTotxTrasp` | `INTEGER` | L19 |
| `iExisteGenCons` | `INTEGER` | L20 |
| `iInicioProc` | `SMALLINT` | L21 |
| `iExisteFecha` | `INTEGER` | L22 |
| `iRegsTot` | `INTEGER` | L23 |
| `viSerialInicial` | `INTEGER` | L24 |
| `viSerialFinal` | `INTEGER` | L25 |
| `viRegsxTraspasar` | `INTEGER` | L26 |
| `dtFecha_mov` | `DATE` | L27 |
| `iNum_serial` | `INTEGER` | L28 |
| `iCont` | `INTEGER` | L29 |
| *…3 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_fechas` | `bdinteg` | ⚠️ sí | SELECT | L86 |
| `sl_movefec` | `bdilide` | no | SELECT | L95 |
| `sl_procesos` | `bdilide` | no | SELECT | L108 |
| `sl_parametros` | `bdilide` | no | SELECT | L132 |
| `sl_movefec_his` | `bdilide` | no | INSERT | L167 |
| `sl_movefec` | `bdilide` | no | DELETE | L174 |
| `sl_movefec_his` | `bdilide` | no | SELECT | L186 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L89 | FÓRMULA | `LET dtFechaIni = dtPriDiaMes - 1 UNITS MONTH;` |  |
| L90 | FÓRMULA | `LET dtFechaFin = dtPriDiaMes - 1 UNITS DAY;` |  |
| L178 | FÓRMULA | `LET iCont = iCont +1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `id` | ENTIDAD | identificador (de) | 🔵 CONVENCIÓN | nombre_sp |
| `?e` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `traspaso` | ACCION | traspaso entre cuentas | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `movto` | ENTIDAD | movimiento | 🔵 CONVENCIÓN | nombre_sp |
| `?s` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `historico` | MODIF | histórico | 🔵 CONVENCIÓN | nombre_sp |
| `comp` | MODIF | complemento | 🔵 CONVENCIÓN | nombre_sp |
| `?1_mod` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?e`, `?s`, `?1_mod` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_idetraspasomovtoshistoricocomp2`

| Campo | Valor |
|-------|-------|
| **Dominio** | D15 · `bdilide` · LIDE / PLD |
| **Archivo fuente** | `bdilide_sp_idetraspasomovtoshistoricocomp2.sql` |
| **LOC (1er CREATE)** | 199 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "traspaso entre cuentas identificador y movimiento (histórico, complemento)" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 7 tabla(s) con operaciones: INSERT, DELETE, SELECT |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=5 · INFERIDO=0 · SINTÉTICO=3 / 9 términos |

### Firma

```sql
CREATE PROCEDURE sp_idetraspasomovtoshistoricocomp2(
) RETURNING CHAR(6)  AS codigo_retorno,
```

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(6)` | L5 |
| `cCodRet2` | `CHAR(6)` | L6 |
| `cCodRet3` | `CHAR(60)` | L7 |
| `iSqlErr` | `INTEGER` | L8 |
| `iIsamErr` | `INTEGER` | L9 |
| `cErrorInfo` | `CHAR(80)` | L10 |
| `cMensajeRet` | `CHAR(80)` | L11 |
| `cUser` | `CHAR(10)` | L12 |
| `dtFechaHoy` | `DATE` | L13 |
| `dtFechaAnt` | `DATE` | L14 |
| `dtPriDiaMes` | `DATE` | L15 |
| `dtUltDiaMes` | `DATE` | L16 |
| `dtFechaIni` | `DATE` | L17 |
| `dtFechaFin` | `DATE` | L18 |
| `viRegsTotxTrasp` | `INTEGER` | L19 |
| `iExisteGenCons` | `INTEGER` | L20 |
| `iInicioProc` | `SMALLINT` | L21 |
| `iExisteFecha` | `INTEGER` | L22 |
| `iRegsTot` | `INTEGER` | L23 |
| `viSerialInicial` | `INTEGER` | L24 |
| `viSerialFinal` | `INTEGER` | L25 |
| `viRegsxTraspasar` | `INTEGER` | L26 |
| `dtFecha_mov` | `DATE` | L27 |
| `iNum_serial` | `INTEGER` | L28 |
| `iCont` | `INTEGER` | L29 |
| *…3 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_fechas` | `bdinteg` | ⚠️ sí | SELECT | L86 |
| `sl_movefec` | `bdilide` | no | SELECT | L95 |
| `sl_procesos` | `bdilide` | no | SELECT | L108 |
| `sl_parametros` | `bdilide` | no | SELECT | L132 |
| `sl_movefec_his` | `bdilide` | no | INSERT | L160 |
| `sl_movefec` | `bdilide` | no | DELETE | L167 |
| `sl_movefec_his` | `bdilide` | no | SELECT | L179 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L89 | FÓRMULA | `LET dtFechaIni = dtPriDiaMes - 1 UNITS MONTH;` |  |
| L90 | FÓRMULA | `LET dtFechaFin = dtPriDiaMes - 1 UNITS DAY;` |  |
| L171 | FÓRMULA | `LET iCont = iCont +1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `id` | ENTIDAD | identificador (de) | 🔵 CONVENCIÓN | nombre_sp |
| `?e` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `traspaso` | ACCION | traspaso entre cuentas | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `movto` | ENTIDAD | movimiento | 🔵 CONVENCIÓN | nombre_sp |
| `?s` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `historico` | MODIF | histórico | 🔵 CONVENCIÓN | nombre_sp |
| `comp` | MODIF | complemento | 🔵 CONVENCIÓN | nombre_sp |
| `?2` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?e`, `?s`, `?2` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_idetraspasomovtoshistoricocomp2_mod`

| Campo | Valor |
|-------|-------|
| **Dominio** | D15 · `bdilide` · LIDE / PLD |
| **Archivo fuente** | `bdilide_sp_idetraspasomovtoshistoricocomp2_mod.sql` |
| **LOC (1er CREATE)** | 199 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "traspaso entre cuentas identificador y movimiento (histórico, complemento)" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 7 tabla(s) con operaciones: INSERT, DELETE, SELECT |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=5 · INFERIDO=0 · SINTÉTICO=3 / 9 términos |

### Firma

```sql
CREATE PROCEDURE sp_idetraspasomovtoshistoricocomp2_mod(
) RETURNING CHAR(6)  AS codigo_retorno,
```

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(6)` | L5 |
| `cCodRet2` | `CHAR(6)` | L6 |
| `cCodRet3` | `CHAR(60)` | L7 |
| `iSqlErr` | `INTEGER` | L8 |
| `iIsamErr` | `INTEGER` | L9 |
| `cErrorInfo` | `CHAR(80)` | L10 |
| `cMensajeRet` | `CHAR(80)` | L11 |
| `cUser` | `CHAR(10)` | L12 |
| `dtFechaHoy` | `DATE` | L13 |
| `dtFechaAnt` | `DATE` | L14 |
| `dtPriDiaMes` | `DATE` | L15 |
| `dtUltDiaMes` | `DATE` | L16 |
| `dtFechaIni` | `DATE` | L17 |
| `dtFechaFin` | `DATE` | L18 |
| `viRegsTotxTrasp` | `INTEGER` | L19 |
| `iExisteGenCons` | `INTEGER` | L20 |
| `iInicioProc` | `SMALLINT` | L21 |
| `iExisteFecha` | `INTEGER` | L22 |
| `iRegsTot` | `INTEGER` | L23 |
| `viSerialInicial` | `INTEGER` | L24 |
| `viSerialFinal` | `INTEGER` | L25 |
| `viRegsxTraspasar` | `INTEGER` | L26 |
| `dtFecha_mov` | `DATE` | L27 |
| `iNum_serial` | `INTEGER` | L28 |
| `iCont` | `INTEGER` | L29 |
| *…3 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_fechas` | `bdinteg` | ⚠️ sí | SELECT | L86 |
| `sl_movefec` | `bdilide` | no | SELECT | L95 |
| `sl_procesos` | `bdilide` | no | SELECT | L108 |
| `sl_parametros` | `bdilide` | no | SELECT | L132 |
| `sl_movefec_his` | `bdilide` | no | INSERT | L160 |
| `sl_movefec` | `bdilide` | no | DELETE | L167 |
| `sl_movefec_his` | `bdilide` | no | SELECT | L179 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L89 | FÓRMULA | `LET dtFechaIni = dtPriDiaMes - 1 UNITS MONTH;` |  |
| L90 | FÓRMULA | `LET dtFechaFin = dtPriDiaMes - 1 UNITS DAY;` |  |
| L171 | FÓRMULA | `LET iCont = iCont +1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `id` | ENTIDAD | identificador (de) | 🔵 CONVENCIÓN | nombre_sp |
| `?e` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `traspaso` | ACCION | traspaso entre cuentas | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `movto` | ENTIDAD | movimiento | 🔵 CONVENCIÓN | nombre_sp |
| `?s` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `historico` | MODIF | histórico | 🔵 CONVENCIÓN | nombre_sp |
| `comp` | MODIF | complemento | 🔵 CONVENCIÓN | nombre_sp |
| `?2_mod` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?e`, `?s`, `?2_mod` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_insdel`

| Campo | Valor |
|-------|-------|
| **Dominio** | D15 · `bdilide` · LIDE / PLD |
| **Archivo fuente** | `bdilide_sp_insdel.sql` |
| **LOC (1er CREATE)** | 27 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "insertar" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `inserta` → `INSERT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=1 · INFERIDO=1 · SINTÉTICO=1 / 3 términos |

### Firma

```sql
CREATE PROCEDURE sp_insdel(
  pTipoOpera                   CHAR(1)
  pNumCte                      CHAR(20)
  pFechaCargo                  CHAR(10)
  pCuenta                      CHAR(20)
  pPeriodo                     CHAR(7)
  pImporte                     MONEY
) RETURNING CHAR (5)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pTipoOpera` | `CHAR(1)` | — | — |
| `pNumCte` | `CHAR(20)` | — | — |
| `pFechaCargo` | `CHAR(10)` | — | — |
| `pCuenta` | `CHAR(20)` | — | — |
| `pPeriodo` | `CHAR(7)` | — | — |
| `pImporte` | `MONEY` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vcCodRet` | `CHAR(5)` | L5 |
| `vsqlerr` | `integer` | L6 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sl_recaudaciones` | `bdilide` | no | INSERT | L23 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `ins` | ACCION | insertar | 🟡 INFERIDO | nombre_sp |
| `?del` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?del` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_llamadogenera`

| Campo | Valor |
|-------|-------|
| **Dominio** | D15 · `bdilide` · LIDE / PLD |
| **Archivo fuente** | `bdilide_sp_llamadogenera.sql` |
| **LOC (1er CREATE)** | 86 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "genera" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `genera` → `SELECT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=1 / 3 términos |

### Firma

```sql
CREATE PROCEDURE sp_llamadogenera(
) RETURNING char(10),CHAR(6), CHAR(20), CHAR(1), CHAR(40),CHAR(200), CHAR(1)
```

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cNombreArch` | `CHAR(20)` | L4 |
| `cNombreArchSp` | `CHAR(20)` | L5 |
| `cNombreConSp` | `CHAR(20)` | L6 |
| `cCompleArch` | `CHAR(15)` | L7 |
| `cNombreCon` | `CHAR(20)` | L8 |
| `cCompleCon` | `CHAR(15)` | L9 |
| `cNumArch` | `CHAR(1)` | L10 |
| `cNumCon` | `CHAR(1)` | L11 |
| `cMensaje` | `CHAR(10)` | L12 |
| `cCodRet` | `CHAR(6)` | L13 |
| `cNombreError` | `CHAR(20)` | L14 |
| `pTipoError` | `CHAR(1)` | L15 |
| `pSpLLamado` | `CHAR(40)` | L16 |
| `pMensaje` | `CHAR(200)` | L17 |
| `pMostrado` | `CHAR(1)` | L18 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sl_archsat` | `bdilide` | no | SELECT | L37 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_generaarchivosat` | `bdilide` | no | L52 |
| `sp_generaarchivosatsegundo` | `bdilide` | no | L58 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `?_llamado` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `genera` | ACCION | genera / produce | 🔵 CONVENCIÓN | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_llamado` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_mes_siguiente`

| Campo | Valor |
|-------|-------|
| **Dominio** | D15 · `bdilide` · LIDE / PLD |
| **Archivo fuente** | `bdilide_sp_mes_siguiente.sql` |
| **LOC (1er CREATE)** | 64 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "mes" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 1 llamada(s): `sp_valfechabil` |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=1 / 3 términos |

### Firma

```sql
CREATE PROCEDURE sp_mes_siguiente(
  pFechaInicial                DATE
) RETURNING CHAR(5),-->Codigo de Retorno
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pFechaInicial` | `DATE` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vcodret` | `CHAR(5)` | L11 |
| `vsqlerr` | `INTEGER` | L12 |
| `vFechaCorte` | `DATE` | L14 |
| `vUltimoDiaMes` | `DATE` | L15 |
| `vDiaTras` | `INT` | L16 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_valfechabil` | `bdilide` | no | L57 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L38 | FÓRMULA | `LET vFechaCorte = MONTH(pFechaInicial) \|\|"/01/"\|\| YEAR(pFechaInicial);` |  |
| L39 | FÓRMULA | `LET vFechaCorte = vFechaCorte + pMeses UNITS MONTH;` |  |
| L43 | FÓRMULA | `LET vFechaCorte = MONTH(vFechaCorte) \|\|"/"\|\| "29" \|\|"/"\|\| YEAR(vFechaCorte);` |  |
| L45 | FÓRMULA | `LET vFechaCorte = MONTH(vFechaCorte) \|\|"/"\|\| "28" \|\|"/"\|\| YEAR(vFechaCorte);` |  |
| L48 | FÓRMULA | `LET vUltimoDiaMes = (vFechaCorte + 1 UNITS MONTH) - 1 UNITS DAY;` | 🔴 MONEY/aritmética financiera |
| L50 | FÓRMULA | `LET vFechaCorte = MONTH(vFechaCorte) \|\|"/"\|\| pDiaFechaCorte \|\|"/"\|\| YEAR(vFechaCorte);` |  |
| L52 | FÓRMULA | `LET vFechaCorte = MONTH(vFechaCorte) \|\|"/"\|\| DAY(vUltimoDiaMes) \|\|"/"\|\| YEAR(vFechaCorte);` | 🔴 MONEY/aritmética financiera |
| L58 | FÓRMULA | `LET vDiaTras = vFechaCorte - pFechaInicial;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `mes` | ENTIDAD | mes | 🔵 CONVENCIÓN | nombre_sp |
| `?_siguiente` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_siguiente` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_obtiene_movs_ide`

| Campo | Valor |
|-------|-------|
| **Dominio** | D15 · `bdilide` · LIDE / PLD |
| **Archivo fuente** | `bdilide_sp_obtiene_movs_ide.sql` |
| **LOC (1er CREATE)** | 350 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "obtiene movimientos y identificador" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `obtiene` → `SELECT` encontrado en el cuerpo · `obtiene` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=2 · INFERIDO=1 · SINTÉTICO=1 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_obtiene_movs_ide(
  pEmpresa                     CHAR(3)
) RETURNING CHAR(5) AS vCodRet1,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pEmpresa` | `CHAR(3)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vCodRet1` | `CHAR(5)` | L6 |
| `vCodRet2` | `CHAR(5)` | L7 |
| `vCodRet3` | `CHAR(50)` | L8 |
| `vSqlErr` | `INTEGER` | L9 |
| `vIsamErr` | `INTEGER` | L10 |
| `vDescErr` | `CHAR(50)` | L11 |
| `vFechaHoy` | `DATE` | L12 |
| `vPriDiaMes` | `DATE` | L13 |
| `vFechaIni` | `DATE` | L14 |
| `vFechaFin` | `DATE` | L15 |
| `vAnioMes` | `CHAR(6)` | L16 |
| `vExisteProceso` | `SMALLINT` | L17 |
| `vExisteProcesoFin` | `SMALLINT` | L18 |
| `vNoDepVent` | `INTEGER` | L19 |
| `vMtoDepVent` | `DECIMAL(18,2)` | L20 |
| `vNoDepCorr` | `INTEGER` | L21 |
| `vMtoDepCorr` | `DECIMAL(18,2)` | L22 |
| `vNoDep` | `INTEGER` | L23 |
| `vMtoDep` | `DECIMAL(18,2)` | L24 |
| `vMtoIdePorRecaudar` | `DECIMAL(18,2)` | L25 |
| `vMtoIdeVent1` | `DECIMAL(18,2)` | L26 |
| `vMtoIdeVent2` | `DECIMAL(18,2)` | L27 |
| `vMtoIdeVent3` | `DECIMAL(18,2)` | L28 |
| `vMtoIdeVent4` | `DECIMAL(18,2)` | L29 |
| `vMtoIdeVent5` | `DECIMAL(18,2)` | L30 |
| *…7 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sl_depmensuales` | `bdilide` | no | SELECT | L82 |
| `sl_depmensuales` | `bdilide` | no | DELETE | L82 |
| `sl_depmensuales_vent_rangos` | `bdilide` | no | SELECT | L83 |
| `sl_depmensuales_vent_rangos` | `bdilide` | no | DELETE | L83 |
| `sl_depmensuales_corr_rangos` | `bdilide` | no | SELECT | L84 |
| `sl_depmensuales_corr_rangos` | `bdilide` | no | DELETE | L84 |
| `sc_fechas` | `bdicheq` | ⚠️ sí | SELECT | L99 |
| `sl_procesos` | `bdilide` | no | SELECT | L108 |
| `sl_procesos` | `bdilide` | no | INSERT | L114 |
| `si_codret` | `bdinteg` | ⚠️ sí | SELECT | L136 |
| `sl_movefec_his` | `bdilide` | no | SELECT | L148 |
| `sl_retlide` | `bdilide` | no | SELECT | L170 |
| `sl_depmensuales` | `bdilide` | no | INSERT | L181 |
| `statistics` | `bdilide` | no | UPDATE | L194 |
| `tmp_lide` | `bdilide` | no | SELECT | L199 |
| `sl_depmensuales_vent_rangos` | `bdilide` | no | INSERT | L250 |
| `sl_depmensuales_corr_rangos` | `bdilide` | no | INSERT | L307 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L102 | FÓRMULA | `LET vFechaIni = vPriDiaMes - 1 UNITS MONTH;` |  |
| L103 | FÓRMULA | `LET vFechaFin = vPriDiaMes - 1 UNITS DAY;` |  |
| L162 | FÓRMULA | `LET vNoDep = vNoDepVent + vNoDepCorr;` |  |
| L164 | FÓRMULA | `LET vMtoDep = vMtoDepVent + vMtoDepCorr;` |  |
| L173 | VALIDACIÓN_NULL | `IF vAnioMes IS NULL THEN` |  |
| L177 | VALIDACIÓN_NULL | `IF vMtoIdePorRecaudar is null THEN` |  |
| L203 | VALIDACIÓN_NULL | `IF vMtoIdeVent1 is null THEN` |  |
| L214 | VALIDACIÓN_NULL | `IF vMtoIdeVent2 is null THEN` |  |
| L225 | VALIDACIÓN_NULL | `IF vMtoIdeVent3 is null THEN` |  |
| L236 | VALIDACIÓN_NULL | `IF vMtoIdeVent4 is null THEN` |  |
| L246 | VALIDACIÓN_NULL | `IF vMtoIdeVent5 is null THEN` |  |
| L260 | VALIDACIÓN_NULL | `IF vMtoIdeCorr1 is null THEN` |  |
| L271 | VALIDACIÓN_NULL | `IF vMtoIdeCorr2 is null THEN` |  |
| L282 | VALIDACIÓN_NULL | `IF vMtoIdeCorr3 is null THEN` |  |
| L293 | VALIDACIÓN_NULL | `IF vMtoIdeCorr4 is null THEN` |  |
| L303 | VALIDACIÓN_NULL | `IF vMtoIdeCorr5 is null THEN` |  |
| L317 | FÓRMULA | `LET vsql = "/ifxsif01/bin/dbaccess bdilide /resplogifx/conciliachq/depmentot.sql";` |  |
| L327 | FÓRMULA | `LET vsql = "/ifxsif01/bin/dbaccess bdilide /resplogifx/conciliachq/depmenvent.sql";` |  |
| L337 | FÓRMULA | `LET vsql = "/ifxsif01/bin/dbaccess bdilide /resplogifx/conciliachq/depmencorr.sql";` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `obtiene` | ACCION | obtiene / recupera | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `movs` | ENTIDAD | movimientos (abreviación) | 🟡 INFERIDO | nombre_sp |
| `id` | ENTIDAD | identificador (de) | 🔵 CONVENCIÓN | nombre_sp |
| `?e` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?e` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_obtieneinfide`

| Campo | Valor |
|-------|-------|
| **Dominio** | D15 · `bdilide` · LIDE / PLD |
| **Archivo fuente** | `bdilide_sp_obtieneinfide.sql` |
| **LOC (1er CREATE)** | 510 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "obtiene información y identificador" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `obtiene` → `SELECT` encontrado en el cuerpo · `obtiene` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=3 · INFERIDO=1 · SINTÉTICO=1 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_obtieneinfide(
  pempresa                     char(3)
  pfechaini                    DATE
  pfechafin                    DATE
) RETURNING CHAR(5), CHAR(5), CHAR(40)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pempresa` | `char(3)` | — | — |
| `pfechaini` | `DATE` | — | — |
| `pfechafin` | `DATE` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vcodret1` | `char(5)` | L4 |
| `vcodret2` | `char(5)` | L5 |
| `vcodret3` | `char(40)` | L6 |
| `vsqlerr` | `integer` | L7 |
| `isam_err` | `integer` | L8 |
| `desc_err` | `char(40)` | L9 |
| `vcontador1` | `integer` | L10 |
| `vcontador2` | `integer` | L11 |
| `ven_transacc` | `smallint` | L12 |
| `vcomienza` | `smallint` | L13 |
| `vaniomes` | `CHAR(6)` | L14 |
| `vfecha_movhis` | `CHAR(10)` | L15 |
| `vfecha_movhisold` | `CHAR(10)` | L16 |
| `vfecha_movhisold2` | `CHAR(10)` | L17 |
| `vnum_serial` | `INTEGER` | L19 |
| `vnum_cta` | `CHAR(20)` | L20 |
| `vfecha_mov` | `DATE` | L21 |
| `vimp_tot_dep` | `DECIMAL(18,2)` | L22 |
| `vtransacc` | `CHAR(4)` | L23 |
| `vtransacc_corresp` | `INTEGER` | L24 |
| `vmonto_corresp` | `DECIMAL(18,2)` | L25 |
| `vtransacc_suc` | `INTEGER` | L26 |
| `vmonto_suc` | `DECIMAL(18,2)` | L27 |
| `vnum_cte` | `CHAR(20)` | L29 |
| `vno_regs` | `INTEGER` | L30 |
| *…18 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sc_param` | `bdicheq` | ⚠️ sí | SELECT | L128 |
| `statistics` | `bdilide` | no | UPDATE | L156 |
| `sl_movefec` | `bdilide` | no | SELECT | L176 |
| `sc_movhis_old3` | `bdicheq` | ⚠️ sí | SELECT | L191 |
| `sc_movhis_old2` | `bdicheq` | ⚠️ sí | SELECT | L203 |
| `sc_movhis_old` | `bdicheq` | ⚠️ sí | SELECT | L215 |
| `sc_movhis` | `bdicheq` | ⚠️ sí | SELECT | L227 |
| `depositos_ventanilla` | `bdilide` | no | INSERT | L255 |
| `depositos_corresponsal` | `bdilide` | no | INSERT | L258 |
| `sl_retlide` | `bdilide` | no | SELECT | L286 |
| `depositos_ide` | `bdilide` | no | INSERT | L330 |
| `depositos_ide_sucursal` | `bdilide` | no | INSERT | L487 |
| `tmp_depositos_ide_corresponsal` | `bdilide` | no | INSERT | L490 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L62 | FÓRMULA | `LET vcomienza    = -1;` |  |
| L238 | FÓRMULA | `LET vtransacc_corresp = vtransacc_corresp + 1;` |  |
| L239 | FÓRMULA | `LET vmonto_corresp = vmonto_corresp + vimp_tot_dep;` | 🔴 MONEY/aritmética financiera |
| L241 | FÓRMULA | `LET vtransacc_suc = vtransacc_suc + 1;` |  |
| L242 | FÓRMULA | `LET vmonto_suc = vmonto_suc + vimp_tot_dep;` | 🔴 MONEY/aritmética financiera |
| L281 | FÓRMULA | `LET vcomienza = -1;` |  |
| L310 | FÓRMULA | `LET vmonto_excedente = vmonto_dep - 15000;` | 🔴 MONEY/aritmética financiera |
| L313 | FÓRMULA | `LET vmonto_ide = vmonto_excedente * 0.03;` | 🔴 MONEY/aritmética financiera |
| L315 | FÓRMULA | `LET vno_transacc = vno_transacc + vno_regs;` |  |
| L316 | FÓRMULA | `LET vmonto_transacc = vmonto_transacc + vmonto_dep;` | 🔴 MONEY/aritmética financiera |
| L317 | FÓRMULA | `LET vmonto_acum_ide = vmonto_acum_ide + vmonto_ide;` | 🔴 MONEY/aritmética financiera |
| L372 | FÓRMULA | `LET vcomienza = -1;` |  |
| L450 | FÓRMULA | `LET vregs_suc_15 = vregs_suc_15 + 1;` |  |
| L452 | FÓRMULA | `LET vregs_suc_15a20 = vregs_suc_15a20 + 1;` |  |
| L454 | FÓRMULA | `LET vregs_suc_20a25 = vregs_suc_20a25 + 1;` |  |
| L456 | FÓRMULA | `LET vregs_suc_25a30 = vregs_suc_25a30 + 1;` |  |
| L458 | FÓRMULA | `LET vregs_suc_30 = vregs_suc_30 + 1;` |  |
| L462 | FÓRMULA | `LET vregs_corresp_15 = vregs_corresp_15 + 1;` |  |
| L464 | FÓRMULA | `LET vregs_corresp_15a20 = vregs_corresp_15a20 + 1;` |  |
| L466 | FÓRMULA | `LET vregs_corresp_20a25 = vregs_corresp_20a25 + 1;` |  |
| L468 | FÓRMULA | `LET vregs_corresp_25a30 = vregs_corresp_25a30 + 1;` |  |
| L470 | FÓRMULA | `LET vregs_corresp_30 = vregs_corresp_30 + 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `obtiene` | ACCION | obtiene / recupera | 🔵 CONVENCIÓN | nombre_sp |
| `inf` | ENTIDAD | información | 🟡 INFERIDO | nombre_sp |
| `id` | ENTIDAD | identificador (de) | 🔵 CONVENCIÓN | nombre_sp |
| `?e` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?e` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_ope_sldecanual`

| Campo | Valor |
|-------|-------|
| **Dominio** | D15 · `bdilide` · LIDE / PLD |
| **Archivo fuente** | `bdilide_sp_ope_sldecanual.sql` |
| **LOC (1er CREATE)** | 91 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "operación" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 1 llamada(s): `spsldecanual2` |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=1 · INFERIDO=1 · SINTÉTICO=1 / 3 términos |

### Firma

```sql
CREATE PROCEDURE sp_ope_sldecanual(
  pUsuario                     CHAR(8)
  pIdFuncion                   CHAR(10)
  pFechaProceso                DATE
  pTipoDecl                    CHAR(1)
  pFechaPresentacion           DATE
  pNumFolio                    VARCHAR(16)
) RETURNING CHAR(5) AS codret,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pUsuario` | `CHAR(8)` | — | — |
| `pIdFuncion` | `CHAR(10)` | — | — |
| `pFechaProceso` | `DATE` | — | — |
| `pTipoDecl` | `CHAR(1)` | — | — |
| `pFechaPresentacion` | `DATE` | — | — |
| `pNumFolio` | `VARCHAR(16)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(5)` | L5 |
| `iSqlErr` | `INTEGER` | L6 |
| `cCodRetSp` | `CHAR(5)` | L7 |
| `iCodRetSp` | `INTEGER` | L8 |
| `cMensaje` | `CHAR(80)` | L9 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sw_verificastatusdeclide` | `bdicnweb` | ⚠️ sí | SELECT | L39 |
| `sw_verificastatusdeclide` | `bdicnweb` | ⚠️ sí | DELETE | L39 |
| `sw_verificastatusdeclide` | `bdicnweb` | ⚠️ sí | INSERT | L41 |
| `sw_bitacoraprocedimientoside` | `bdicnweb` | ⚠️ sí | INSERT | L43 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `spsldecanual2` | `bdilide` | no | L49 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L11 | CÓDIGO_RETORNO | `LET cCodRet = '00000';` |  |
| L35 | CÓDIGO_RETORNO | `LET cCodRet = '00003';` |  |
| L63 | EXCEPCIÓN | `RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP spsldecanual";` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `ope` | ACCION | operación | 🟡 INFERIDO | nombre_sp |
| `?_sldecanual` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_sldecanual` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_ope_sldecmensual`

| Campo | Valor |
|-------|-------|
| **Dominio** | D15 · `bdilide` · LIDE / PLD |
| **Archivo fuente** | `bdilide_sp_ope_sldecmensual.sql` |
| **LOC (1er CREATE)** | 92 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "operación (mensual)" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 1 llamada(s): `spsldecmensual2` |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=2 · INFERIDO=1 · SINTÉTICO=1 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_ope_sldecmensual(
  pUsuario                     CHAR(8)
  pIdFuncion                   CHAR(10)
  pFechaProceso                DATE
  pTipoDecl                    CHAR(1)
  pFechaPresentacion           DATE
  pNumFolio                    CHAR(16)
) RETURNING CHAR(5) AS codret,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pUsuario` | `CHAR(8)` | — | — |
| `pIdFuncion` | `CHAR(10)` | — | — |
| `pFechaProceso` | `DATE` | — | — |
| `pTipoDecl` | `CHAR(1)` | — | — |
| `pFechaPresentacion` | `DATE` | — | — |
| `pNumFolio` | `CHAR(16)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(5)` | L5 |
| `iSqlErr` | `INTEGER` | L6 |
| `cCodRetSp` | `CHAR(6)` | L7 |
| `iCodRetSp` | `INTEGER` | L8 |
| `cMensaje` | `CHAR(80)` | L9 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sw_bitacoraprocedimientoside` | `bdicnweb` | ⚠️ sí | UPDATE | L21 |
| `sw_verificastatusdeclide` | `bdicnweb` | ⚠️ sí | SELECT | L45 |
| `sw_verificastatusdeclide` | `bdicnweb` | ⚠️ sí | DELETE | L45 |
| `sw_verificastatusdeclide` | `bdicnweb` | ⚠️ sí | INSERT | L47 |
| `sw_bitacoraprocedimientoside` | `bdicnweb` | ⚠️ sí | INSERT | L49 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `spsldecmensual2` | `bdilide` | no | L56 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L11 | CÓDIGO_RETORNO | `LET cCodRet = '00000';` |  |
| L35 | VALIDACIÓN_NULL | `IF pUsuario = '' OR pIdFuncion = '' OR pFechaProceso IS NULL OR pTipoDecl = '' THEN` |  |
| L36 | CÓDIGO_RETORNO | `LET cCodRet = '00003';` |  |
| L64 | EXCEPCIÓN | `RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP spsldecmensual";` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `ope` | ACCION | operación | 🟡 INFERIDO | nombre_sp |
| `?_sldec` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `mensual` | MODIF | mensual | 🔵 CONVENCIÓN | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_sldec` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_procesasat`

| Campo | Valor |
|-------|-------|
| **Dominio** | D15 · `bdilide` · LIDE / PLD |
| **Archivo fuente** | `bdilide_sp_procesasat.sql` |
| **LOC (1er CREATE)** | 135 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "procesa · SAT — Servicio de Administración Tributaria" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 8 tabla(s) con operaciones: INSERT, UPDATE, SELECT |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=0 / 3 términos |

### Historia del SP

| Tipo | Valor |
|------|-------|
| AUTOR | Alejandro Osuna |
| PROYECTO | Excencion de personas morales |
| ACTIVIDAD | Se procesa la informiacion, se cambia el status en las tablas correspondientes |
| FECHA | 11 de septiembre de 2008 |

### Firma

```sql
CREATE PROCEDURE sp_procesasat(
  pUsuario                     CHAR(8)
  cNomArchivo                  VARCHAR (20)
  cArchivoControl              VARCHAR (20)
) RETURNING CHAR(4)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pUsuario` | `CHAR(8)` | — | — |
| `cNomArchivo` | `VARCHAR (20)` | — | — |
| `cArchivoControl` | `VARCHAR (20)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(4)` | L10 |
| `sql_err` | `integer` | L11 |
| `cRfc` | `CHAR(13)` | L12 |
| `cEstado` | `CHAR(1)` | L13 |
| `cFechaSer` | `CHAR (12)` | L14 |
| `cNumCte` | `CHAR(20)` | L15 |
| `cStatus` | `CHAR(1)` | L16 |
| `vsSQLC` | `CHAR(50)` | L17 |
| `sRutaArchivo` | `CHAR(20)` | L18 |
| `sConsulRfc` | `CHAR(13)` | L19 |
| `cPrefijo` | `CHAR(2)` | L20 |
| `cPrefijoControl` | `CHAR(2)` | L21 |
| `cNombre` | `CHAR(20)` | L22 |
| `cNombreControl` | `CHAR(20)` | L23 |
| `cNombreRechazo` | `CHAR(20)` | L24 |
| `cPrefijoLetra` | `char(2)` | L25 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sl_parametros` | `bdilide` | no | SELECT | L60 |
| `si_fechas` | `bdinteg` | ⚠️ sí | SELECT | L63 |
| `sl_archivossatresp` | `bdilide` | no | SELECT | L70 |
| `sl_consat` | `bdilide` | no | UPDATE | L72 |
| `sl_exentos` | `bdilide` | no | SELECT | L75 |
| `sl_exentos` | `bdilide` | no | UPDATE | L76 |
| `si_cliente` | `bdinteg` | ⚠️ sí | SELECT | L81 |
| `sl_exentos` | `bdilide` | no | INSERT | L82 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L55 | VALIDACIÓN_NULL | `IF (pUsuario = '' Or pUsuario IS NULL)  THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `procesa` | ACCION | procesa | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `sat` | REG | SAT — Servicio de Administración Tributaria (CFDI, ISR, IVA) | 🔵 CONVENCIÓN | nombre_sp |

---

## `sp_reporteerroresproceso`

| Campo | Valor |
|-------|-------|
| **Dominio** | D15 · `bdilide` · LIDE / PLD |
| **Archivo fuente** | `bdilide_sp_reporteerroresproceso.sql` |
| **LOC (1er CREATE)** | 71 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "reporte, error y ro — Rol Operativo (especial)" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 1 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=4 · INFERIDO=0 · SINTÉTICO=2 / 6 términos |

### Historia del SP

| Tipo | Valor |
|------|-------|
| ACTIVIDAD | Obtiene registros de los últimos treintas sobre la tabla sl_errores. |
| FECHA | 03/SEP/2008 --* |

### Firma

```sql
CREATE PROCEDURE sp_reporteerroresproceso(
  pFechaReporte                DATE
) RETURNING CHAR(6) as codRet,DATE as fechaInicial,CHAR(16) as archivo,DATE as fecha_error, CHAR(5) as cod_error,CHAR(1) as tipo_error,CHAR(40) as sp_llamado ,CHAR(200) as mensaje_error
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pFechaReporte` | `DATE` | `reporte`=reporte | 🔵 CONVENCIÓN |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vcCodRet` | `CHAR(3)` | L13 |
| `vdFechaInicial` | `DATE` | L14 |
| `sql_err` | `INTEGER` | L15 |
| `vcArchivo` | `CHAR(16)` | L16 |
| `vmFechaErr` | `DATE` | L17 |
| `vcCodErr` | `CHAR(5)` | L18 |
| `vcTpoErr` | `CHAR(16)` | L19 |
| `vcSP_llamado` | `CHAR(40)` | L20 |
| `vcMensajeErr` | `CHAR(200)` | L21 |
| `vINumRegistros` | `SMALLINT` | L22 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sl_errores` | `bdilide` | no | SELECT | L59 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L48 | VALIDACIÓN_NULL | `IF pFechaReporte IS NULL THEN` |  |
| L54 | FÓRMULA | `Let vdFechaInicial = pFechaReporte - interval(30) day to day;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `reporte` | ENTIDAD | reporte | 🔵 CONVENCIÓN | nombre_sp |
| `error` | ENTIDAD | error | 🔵 CONVENCIÓN | nombre_sp |
| `esp` | MODIF | especial | 🔵 CONVENCIÓN | nombre_sp |
| `ro` | ENTIDAD | ro — Rol Operativo (subsistema sp_sw_ro_* — bdicnweb) | 🔴 SINTÉTICO | nombre_sp |
| `?ceso` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `ro`, `?ceso` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_retdialide`

| Campo | Valor |
|-------|-------|
| **Dominio** | D15 · `bdilide` · LIDE / PLD |
| **Archivo fuente** | `bdilide_sp_retdialide.sql` |
| **LOC (1er CREATE)** | 834 |
| **Callgraph** | ✅ fan_in=0 / fan_out=5 |
| **Propósito inferido** | "identificador (del día)" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 5 llamada(s): `reversion`, `sp_cons_sdodisp_x_tpcalculo`, `cargo_ref` |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=3 / 6 términos |

### Firma

```sql
CREATE PROCEDURE sp_retdialide(
  pEmpresa                     CHAR(3)
  dFecha                       DATE
  cUsuario                     CHAR(10)
) RETURNING VARCHAR(4), VARCHAR(80), CHAR(11)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pEmpresa` | `CHAR(3)` | — | — |
| `dFecha` | `DATE` | — | — |
| `cUsuario` | `CHAR(10)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `SQL_ERR` | `INTEGER` | L4 |
| `ISAM_ERR` | `INTEGER` | L5 |
| `ERROR_INFO` | `VARCHAR(80)` | L6 |
| `P_COD_RET` | `VARCHAR(4)` | L7 |
| `P_COD_RET2` | `VARCHAR(4)` | L8 |
| `P_MENSAJE` | `VARCHAR(80)` | L9 |
| `iStatus` | `INTEGER` | L11 |
| `cNumcte` | `VARCHAR(20)` | L12 |
| `cCuenta` | `VARCHAR(20)` | L13 |
| `mSaldo_ant` | `MONEY(14,2)` | L14 |
| `mRecaudar` | `MONEY(14,2)` | L15 |
| `mRecaudartot` | `MONEY(14,2)` | L16 |
| `mRsaldo_act` | `MONEY(14,2)` | L17 |
| `vcAnioMes` | `CHAR(6)` | L18 |
| `vcTipoCta` | `CHAR(1)` | L19 |
| `vcCuenta` | `CHAR(20)` | L20 |
| `vcEmpresa` | `CHAR(3)` | L21 |
| `vcSucursal` | `CHAR(4)` | L22 |
| `vcTransaccion` | `CHAR(4)` | L23 |
| `vcTransaccSuc` | `CHAR(4)` | L24 |
| `vcTransaccSucCred` | `CHAR(4)` | L25 |
| `vcDivisa` | `CHAR(2)` | L26 |
| `vcNumTarjeta` | `CHAR(16)` | L27 |
| `vcTime` | `CHAR(8)` | L28 |
| `vcFolioSuc` | `CHAR(16)` | L29 |
| *…30 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_fechas` | `bdinteg` | ⚠️ sí | SELECT | L178 |
| `sl_procesos` | `bdilide` | no | SELECT | L185 |
| `sl_procesos` | `bdilide` | no | INSERT | L222 |
| `sl_parametros` | `bdilide` | no | SELECT | L231 |
| `sl_pasoctas` | `bdilide` | no | INSERT | L271 |
| `sc_maechq` | `bdicheq` | ⚠️ sí | SELECT | L277 |
| `sd_maecred` | `bdicred` | ⚠️ sí | SELECT | L292 |
| `sl_retespeciales` | `bdilide` | no | SELECT | L317 |
| `12` | `bdilide` | no | SELECT | L357 |
| `sc_tarjeta` | `bdicheq` | ⚠️ sí | SELECT | L362 |
| `sl_detlide` | `bdilide` | no | SELECT | L400 |
| `sl_retlide` | `bdilide` | no | SELECT | L407 |
| `sl_detlide` | `bdilide` | no | INSERT | L412 |
| `sl_pasoctas` | `bdilide` | no | SELECT | L481 |
| `sd_maesdos` | `bdicred` | ⚠️ sí | SELECT | L622 |
| `sd_tarjeta` | `bdicred` | ⚠️ sí | SELECT | L674 |
| `sx_contproc` | `bdinteg` | ⚠️ sí | INSERT | L783 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `reversion` | `bdicheq` | ⚠️ sí | L134 |
| `sp_cons_sdodisp_x_tpcalculo` | `bdicheq` | ⚠️ sí | L336 |
| `cargo_ref` | `bdicheq` | ⚠️ sí | L374 |
| `cargo_cred` | `bdicred` | ⚠️ sí | L697 |
| `spslgenreporteentero` | `bdilide` | no | L769 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L221 | VALIDACIÓN_NULL | `IF iStatus IS NULL THEN` |  |
| L235 | VALIDACIÓN_NULL | `IF vcEmpresa = "" OR vcEmpresa IS NULL THEN` |  |
| L243 | VALIDACIÓN_NULL | `IF vcTransaccion = "" OR vcTransaccion IS NULL THEN` |  |
| L252 | VALIDACIÓN_NULL | `IF vcTransaccSucCred = "" OR vcTransaccSucCred IS NULL THEN` |  |
| L260 | VALIDACIÓN_NULL | `IF vcDivisa = "" OR vcDivisa IS NULL THEN` |  |
| L343 | FÓRMULA | `LET mRecaudar = mRecaudar - vmImporteCargo; --- Pendiente a recaudar para que se lo cobre de otra cu` | 🔴 MONEY/aritmética financiera |
| L348 | FÓRMULA | `LET vmImporteCargo = ROUND(vmImporteCargo - 0.01);` | 🔴 MONEY/aritmética financiera |
| L451 | FÓRMULA | `LET mRecaudar = mRecaudar + vmImporteCargo;` | 🔴 MONEY/aritmética financiera |
| L518 | FÓRMULA | `LET mRsaldo_act    = mSaldo_ant - vmImporteCargo;` | 🔴 MONEY/aritmética financiera |
| L519 | FÓRMULA | `LET mRecaudar      = mRecaudar - vmImporteCargo; --- Pendiente a recaudar para que se lo cobre de ot` | 🔴 MONEY/aritmética financiera |
| L524 | FÓRMULA | `LET vmImporteCargo = ROUND(vmImporteCargo - 0.01);` | 🔴 MONEY/aritmética financiera |
| L525 | FÓRMULA | `LET mRsaldo_act    = mSaldo_ant - vmImporteCargo;` | 🔴 MONEY/aritmética financiera |
| L612 | FÓRMULA | `LET mRecaudar = mRecaudar + vmImporteCargo;` | 🔴 MONEY/aritmética financiera |
| L635 | FÓRMULA | `LET mRsaldo_act    = mSaldo_ant - vmImporteCargo;` | 🔴 MONEY/aritmética financiera |
| L636 | FÓRMULA | `LET mRecaudar      = mRecaudar - vmImporteCargo;` | 🔴 MONEY/aritmética financiera |
| L646 | FÓRMULA | `LET mRsaldo_act    = mSaldo_ant - vmImporteCargo;` | 🔴 MONEY/aritmética financiera |
| L647 | FÓRMULA | `LET mRecaudar      = mRecaudar - vmImporteCargo;` | 🔴 MONEY/aritmética financiera |
| L656 | FÓRMULA | `LET mRecaudar      = mRecaudar - mSaldo_ant;` |  |
| L661 | FÓRMULA | `LET mRsaldo_act    = mSaldo_ant - vmImporteCargo;` | 🔴 MONEY/aritmética financiera |
| L749 | FÓRMULA | `LET mRecaudar = mRecaudar + vmImporteCargo;` | 🔴 MONEY/aritmética financiera |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `?_ret` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `dia` | MODIF | del día | 🔵 CONVENCIÓN | nombre_sp |
| `?l` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `id` | ENTIDAD | identificador (de) | 🔵 CONVENCIÓN | nombre_sp |
| `?e` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_ret`, `?l`, `?e` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_retdialide_dia_ant`

| Campo | Valor |
|-------|-------|
| **Dominio** | D15 · `bdilide` · LIDE / PLD |
| **Archivo fuente** | `bdilide_sp_retdialide_dia_ant.sql` |
| **LOC (1er CREATE)** | 813 |
| **Callgraph** | ✅ fan_in=0 / fan_out=5 |
| **Propósito inferido** | "identificador (del día, anterior)" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 5 llamada(s): `reversion`, `sp_cons_sdodisp_x_tpcalculo`, `cargo_ref` |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=4 · INFERIDO=0 · SINTÉTICO=3 / 8 términos |

### Firma

```sql
CREATE PROCEDURE sp_retdialide_dia_ant(
  pEmpresa                     CHAR(3)
  dFecha                       DATE
  dFecha_hoy                   DATE
  cUsuario                     CHAR(10)
) RETURNING VARCHAR(4), VARCHAR(80), CHAR(11)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pEmpresa` | `CHAR(3)` | — | — |
| `dFecha` | `DATE` | — | — |
| `dFecha_hoy` | `DATE` | — | — |
| `cUsuario` | `CHAR(10)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `SQL_ERR` | `INTEGER` | L5 |
| `ISAM_ERR` | `INTEGER` | L6 |
| `ERROR_INFO` | `VARCHAR(80)` | L7 |
| `P_COD_RET` | `VARCHAR(4)` | L8 |
| `P_MENSAJE` | `VARCHAR(80)` | L9 |
| `iStatus` | `INTEGER` | L11 |
| `cNumcte` | `VARCHAR(20)` | L12 |
| `cCuenta` | `VARCHAR(20)` | L13 |
| `mSaldo_ant` | `MONEY(14,2)` | L14 |
| `mRecaudar` | `MONEY(14,2)` | L15 |
| `mRecaudartot` | `MONEY(14,2)` | L16 |
| `mRsaldo_act` | `MONEY(14,2)` | L17 |
| `vcAnioMes` | `CHAR(6)` | L18 |
| `vcTipoCta` | `CHAR(1)` | L19 |
| `vcCuenta` | `CHAR(20)` | L20 |
| `vcEmpresa` | `CHAR(3)` | L21 |
| `vcSucursal` | `CHAR(4)` | L22 |
| `vcTransaccion` | `CHAR(4)` | L23 |
| `vcTransaccSuc` | `CHAR(4)` | L24 |
| `vcTransaccSucCred` | `CHAR(4)` | L25 |
| `vcDivisa` | `CHAR(2)` | L26 |
| `vcNumTarjeta` | `CHAR(16)` | L27 |
| `vcTime` | `CHAR(8)` | L28 |
| `vcFolioSuc` | `CHAR(16)` | L29 |
| `vcCodRetTemp` | `CHAR(3)` | L30 |
| *…26 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_fechas` | `bdinteg` | ⚠️ sí | SELECT | L165 |
| `sl_procesos` | `bdilide` | no | SELECT | L172 |
| `sl_parametros` | `bdilide` | no | SELECT | L197 |
| `sl_procesos` | `bdilide` | no | INSERT | L241 |
| `sl_pasoctas` | `bdilide` | no | INSERT | L252 |
| `sc_maechq` | `bdicheq` | ⚠️ sí | SELECT | L258 |
| `sd_maecred` | `bdicred` | ⚠️ sí | SELECT | L273 |
| `sl_retespeciales` | `bdilide` | no | SELECT | L298 |
| `12` | `bdilide` | no | SELECT | L335 |
| `sc_tarjeta` | `bdicheq` | ⚠️ sí | SELECT | L340 |
| `sl_detlide` | `bdilide` | no | SELECT | L380 |
| `sl_retlide` | `bdilide` | no | SELECT | L387 |
| `sl_detlide` | `bdilide` | no | INSERT | L392 |
| `sl_pasoctas` | `bdilide` | no | SELECT | L460 |
| `sd_maesdos` | `bdicred` | ⚠️ sí | SELECT | L602 |
| `sd_tarjeta` | `bdicred` | ⚠️ sí | SELECT | L654 |
| `sx_contproc` | `bdinteg` | ⚠️ sí | INSERT | L762 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `reversion` | `bdicheq` | ⚠️ sí | L128 |
| `sp_cons_sdodisp_x_tpcalculo` | `bdicheq` | ⚠️ sí | L314 |
| `cargo_ref` | `bdicheq` | ⚠️ sí | L352 |
| `cargo_cred` | `bdicred` | ⚠️ sí | L677 |
| `spslgenreporteentero` | `bdilide` | no | L748 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L177 | VALIDACIÓN_NULL | `IF vcStatus2 = 0  or  vcStatus2 IS NULL THEN` |  |
| L189 | VALIDACIÓN_NULL | `IF vcStatus2 = 0 or  vcStatus2 IS NULL THEN` |  |
| L201 | VALIDACIÓN_NULL | `IF vcEmpresa = "" OR vcEmpresa IS NULL THEN` |  |
| L209 | VALIDACIÓN_NULL | `IF vcTransaccion = "" OR vcTransaccion IS NULL THEN` |  |
| L218 | VALIDACIÓN_NULL | `IF vcTransaccSucCred = "" OR vcTransaccSucCred IS NULL THEN` |  |
| L226 | VALIDACIÓN_NULL | `IF vcDivisa = "" OR vcDivisa IS NULL THEN` |  |
| L240 | VALIDACIÓN_NULL | `IF iStatus IS NULL THEN` |  |
| L321 | FÓRMULA | `LET mRecaudar = mRecaudar - vmImporteCargo; --- Pendiente a recaudar para que se lo cobre de otra cu` | 🔴 MONEY/aritmética financiera |
| L326 | FÓRMULA | `LET vmImporteCargo = ROUND(vmImporteCargo - 0.01);` | 🔴 MONEY/aritmética financiera |
| L433 | FÓRMULA | `LET mRecaudar = mRecaudar + vmImporteCargo;` | 🔴 MONEY/aritmética financiera |
| L494 | FÓRMULA | `LET mRsaldo_act    = mSaldo_ant - vmImporteCargo;` | 🔴 MONEY/aritmética financiera |
| L495 | FÓRMULA | `LET mRecaudar      = mRecaudar - vmImporteCargo; --- Pendiente a recaudar para que se lo cobre de ot` | 🔴 MONEY/aritmética financiera |
| L500 | FÓRMULA | `LET vmImporteCargo = ROUND(vmImporteCargo - 0.01);` | 🔴 MONEY/aritmética financiera |
| L501 | FÓRMULA | `LET mRsaldo_act    = mSaldo_ant - vmImporteCargo;` | 🔴 MONEY/aritmética financiera |
| L592 | FÓRMULA | `LET mRecaudar = mRecaudar + vmImporteCargo;` | 🔴 MONEY/aritmética financiera |
| L615 | FÓRMULA | `LET mRsaldo_act    = mSaldo_ant - vmImporteCargo;` | 🔴 MONEY/aritmética financiera |
| L616 | FÓRMULA | `LET mRecaudar      = mRecaudar - vmImporteCargo;` | 🔴 MONEY/aritmética financiera |
| L626 | FÓRMULA | `LET mRsaldo_act    = mSaldo_ant - vmImporteCargo;` | 🔴 MONEY/aritmética financiera |
| L627 | FÓRMULA | `LET mRecaudar      = mRecaudar - vmImporteCargo;` | 🔴 MONEY/aritmética financiera |
| L636 | FÓRMULA | `LET mRecaudar      = mRecaudar - mSaldo_ant;` |  |
| L641 | FÓRMULA | `LET mRsaldo_act    = mSaldo_ant - vmImporteCargo;` | 🔴 MONEY/aritmética financiera |
| L733 | FÓRMULA | `LET mRecaudar = mRecaudar + vmImporteCargo;` | 🔴 MONEY/aritmética financiera |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `?_ret` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `dia` | MODIF | del día | 🔵 CONVENCIÓN | nombre_sp |
| `?l` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `id` | ENTIDAD | identificador (de) | 🔵 CONVENCIÓN | nombre_sp |
| `?e_` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `dia` | MODIF | del día | 🔵 CONVENCIÓN | nombre_sp |
| `ant` | MODIF | anterior | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_ret`, `?l`, `?e_` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_retdialide_esp`

| Campo | Valor |
|-------|-------|
| **Dominio** | D15 · `bdilide` · LIDE / PLD |
| **Archivo fuente** | `bdilide_sp_retdialide_esp.sql` |
| **LOC (1er CREATE)** | 790 |
| **Callgraph** | ✅ fan_in=0 / fan_out=5 |
| **Propósito inferido** | "identificador (del día, especial)" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 5 llamada(s): `reversion`, `sp_cons_sdodisp_x_tpcalculo`, `cargo_ref` |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=4 · INFERIDO=0 · SINTÉTICO=3 / 7 términos |

### Firma

```sql
CREATE PROCEDURE sp_retdialide_esp(
  pEmpresa                     CHAR(3)
  dFecha                       date
  cUsuario                     char(10)
) RETURNING VARCHAR(4),VARCHAR(80), char(11)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pEmpresa` | `CHAR(3)` | — | — |
| `dFecha` | `date` | — | — |
| `cUsuario` | `char(10)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `SQL_ERR` | `INTEGER` | L17 |
| `ISAM_ERR` | `INTEGER` | L18 |
| `ERROR_INFO` | `VARCHAR(80)` | L19 |
| `P_COD_RET` | `VARCHAR(4)` | L20 |
| `P_MENSAJE` | `VARCHAR(80)` | L21 |
| `iStatus` | `INTEGER` | L22 |
| `cNumcte` | `VARCHAR(20)` | L23 |
| `cCuenta` | `VARCHAR(20)` | L24 |
| `mSaldo_ant` | `MONEY(14,2)` | L25 |
| `mRecaudar` | `MONEY(14,2)` | L26 |
| `mRecaudartot` | `MONEY(14,2)` | L27 |
| `mRsaldo_act` | `MONEY(14,2)` | L28 |
| `vcAnioMes` | `CHAR(6)` | L29 |
| `vcTipoCta` | `CHAR(1)` | L30 |
| `vcCuenta` | `CHAR(20)` | L31 |
| `vcEmpresa` | `CHAR(3)` | L32 |
| `vcSucursal` | `CHAR(4)` | L33 |
| `vcTransaccion` | `CHAR(4)` | L34 |
| `vcTransaccSuc` | `CHAR(4)` | L35 |
| `vcTransaccSucCred` | `CHAR(4)` | L36 |
| `vcDivisa` | `CHAR(2)` | L37 |
| `vcNumTarjeta` | `CHAR(16)` | L38 |
| `vcTime` | `CHAR(8)` | L39 |
| `vcFolioSuc` | `CHAR(16)` | L40 |
| `vcCodRetTemp` | `CHAR(3)` | L41 |
| *…26 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_fechas` | `bdinteg` | ⚠️ sí | SELECT | L165 |
| `sl_procesos` | `bdilide` | no | SELECT | L172 |
| `sl_parametros` | `bdilide` | no | SELECT | L200 |
| `sl_procesos` | `bdilide` | no | INSERT | L243 |
| `sl_pasoctas` | `bdilide` | no | INSERT | L255 |
| `sc_maechq` | `bdicheq` | ⚠️ sí | SELECT | L261 |
| `sd_maecred` | `bdicred` | ⚠️ sí | SELECT | L276 |
| `sl_retespeciales` | `bdilide` | no | SELECT | L301 |
| `12` | `bdilide` | no | SELECT | L347 |
| `sc_tarjeta` | `bdicheq` | ⚠️ sí | SELECT | L352 |
| `sl_detlide` | `bdilide` | no | SELECT | L376 |
| `sl_retlide` | `bdilide` | no | SELECT | L383 |
| `sl_detlide` | `bdilide` | no | INSERT | L388 |
| `sl_pasoctas` | `bdilide` | no | SELECT | L464 |
| `sd_maesdos` | `bdicred` | ⚠️ sí | SELECT | L610 |
| `sd_tarjeta` | `bdicred` | ⚠️ sí | SELECT | L630 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `reversion` | `bdicheq` | ⚠️ sí | L128 |
| `sp_cons_sdodisp_x_tpcalculo` | `bdicheq` | ⚠️ sí | L318 |
| `cargo_ref` | `bdicheq` | ⚠️ sí | L364 |
| `cargo_cred` | `bdicred` | ⚠️ sí | L658 |
| `spslgenreporteentero` | `bdilide` | no | L721 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L177 | VALIDACIÓN_NULL | `IF vcStatus2 = 0  or  vcStatus2 IS NULL THEN` |  |
| L190 | VALIDACIÓN_NULL | `IF vcStatus2 = 0 or  vcStatus2 IS NULL THEN` |  |
| L203 | VALIDACIÓN_NULL | `IF vcEmpresa = "" OR vcEmpresa IS NULL THEN` |  |
| L211 | VALIDACIÓN_NULL | `IF vcTransaccion = "" OR vcTransaccion IS NULL THEN` |  |
| L220 | VALIDACIÓN_NULL | `IF vcTransaccSucCred = "" OR vcTransaccSucCred IS NULL THEN` |  |
| L228 | VALIDACIÓN_NULL | `IF vcDivisa = "" OR vcDivisa IS NULL THEN` |  |
| L242 | VALIDACIÓN_NULL | `IF iStatus IS NULL THEN` |  |
| L328 | FÓRMULA | `LET mRecaudar = mRecaudar - mSaldo_ant;` |  |
| L333 | FÓRMULA | `LET vmImporteCargo = ROUND(vmImporteCargo - 0.01);` | 🔴 MONEY/aritmética financiera |
| L428 | FÓRMULA | `LET mRecaudar = mRecaudar + vmImporteCargo;` | 🔴 MONEY/aritmética financiera |
| L504 | FÓRMULA | `LET mRecaudar = mRecaudar - mSaldo_ant;` |  |
| L509 | FÓRMULA | `LET vmImporteCargo = ROUND(vmImporteCargo - 0.01);` | 🔴 MONEY/aritmética financiera |
| L510 | FÓRMULA | `LET mRsaldo_act = mSaldo_ant - vmImporteCargo;` | 🔴 MONEY/aritmética financiera |
| L593 | FÓRMULA | `LET mRecaudar = mRecaudar + vmImporteCargo;` | 🔴 MONEY/aritmética financiera |
| L618 | FÓRMULA | `LET mRecaudar = mRecaudar - mSaldo_ant;` |  |
| L623 | FÓRMULA | `LET mRsaldo_act = mSaldo_ant - vmImporteCargo;` | 🔴 MONEY/aritmética financiera |
| L700 | FÓRMULA | `LET mRecaudar = mRecaudar + vmImporteCargo;` | 🔴 MONEY/aritmética financiera |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `?_ret` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `dia` | MODIF | del día | 🔵 CONVENCIÓN | nombre_sp |
| `?l` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `id` | ENTIDAD | identificador (de) | 🔵 CONVENCIÓN | nombre_sp |
| `?e_` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `esp` | MODIF | especial | 🔵 CONVENCIÓN | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_ret`, `?l`, `?e_` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_validaarchivoinforme`

| Campo | Valor |
|-------|-------|
| **Dominio** | D15 · `bdilide` · LIDE / PLD |
| **Archivo fuente** | `bdilide_sp_validaarchivoinforme.sql` |
| **LOC (1er CREATE)** | 117 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "valida archivo y información" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `valida` → `IF` encontrado en el cuerpo · `valida` → `RETURN` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=1 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_validaarchivoinforme(
  pNombreArchivo               CHAR(20)
) RETURNING CHAR(6), CHAR(60)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pNombreArchivo` | `CHAR(20)` | `archivo`=archivo | ✅ CÓDIGO |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(6)` | L5 |
| `cCodRet2` | `CHAR(6)` | L6 |
| `iSql_Err` | `INTEGER` | L7 |
| `cMensajeRet` | `CHAR(60)` | L8 |
| `dFechaHoy` | `DATE` | L9 |
| `cEstado` | `CHAR(1)` | L10 |
| `cNumCte` | `CHAR(20)` | L11 |
| `cRfc` | `CHAR(13)` | L12 |
| `iNumRegsRes` | `INT8` | L13 |
| `iNumRegsCtrl` | `INT8` | L14 |
| `cRetornoSPdias` | `CHAR(6)` | L15 |
| `cFecha` | `CHAR(8)` | L16 |
| `dDiaPrimero` | `DATE` | L17 |
| `dDiaUltimo` | `CHAR(10)` | L18 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sc_fechas` | `bdicheq` | ⚠️ sí | SELECT | L57 |
| `sl_archivoconsulta` | `bdilide` | no | SELECT | L62 |
| `sl_archivocontrol` | `bdilide` | no | SELECT | L67 |
| `sl_exentos` | `bdilide` | no | SELECT | L85 |
| `sl_ctrlerror` | `bdilide` | no | INSERT | L96 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_diaprimeroultimomesanio` | `bdinteg` | ⚠️ sí | L69 |
| `sp_actualizainformesat` | `bdilide` | no | L102 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `valida` | ACCION | valida | 🔵 CONVENCIÓN | nombre_sp |
| `archivo` | ENTIDAD | archivo | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `info` | ENTIDAD | información | 🔵 CONVENCIÓN | nombre_sp |
| `?rme` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?rme` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_validaarchivoresultado`

| Campo | Valor |
|-------|-------|
| **Dominio** | D15 · `bdilide` · LIDE / PLD |
| **Archivo fuente** | `bdilide_sp_validaarchivoresultado.sql` |
| **LOC (1er CREATE)** | 149 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "valida archivo y resultado" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `valida` → `IF` encontrado en el cuerpo · `valida` → `RETURN` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=0 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_validaarchivoresultado(
  pNombreArchivo               CHAR(20)
) RETURNING CHAR(6), CHAR(60)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pNombreArchivo` | `CHAR(20)` | `archivo`=archivo | ✅ CÓDIGO |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(6)` | L5 |
| `cCodRet2` | `CHAR(6)` | L6 |
| `iSql_Err` | `INTEGER` | L7 |
| `cMensajeRet` | `CHAR(60)` | L8 |
| `dFechaHoy` | `DATE` | L9 |
| `cEstado` | `CHAR(1)` | L10 |
| `cNumCte` | `CHAR(20)` | L11 |
| `cRfc` | `CHAR(13)` | L12 |
| `iNumRegsRes` | `INT8` | L13 |
| `iNumRegsCtrl` | `INT8` | L14 |
| `cRetornoSPdias` | `CHAR(6)` | L15 |
| `cFecha` | `CHAR(8)` | L16 |
| `dDiaPrimero` | `DATE` | L17 |
| `cDiaUltimo` | `CHAR(10)` | L18 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sc_fechas` | `bdicheq` | ⚠️ sí | SELECT | L57 |
| `systables` | `bdilide` | no | SELECT | L60 |
| `sl_archivoconsulta` | `bdilide` | no | SELECT | L77 |
| `sl_archivocontrol` | `bdilide` | no | SELECT | L82 |
| `sl_consat` | `bdilide` | no | SELECT | L100 |
| `sl_ctrlerror` | `bdilide` | no | INSERT | L112 |
| `sl_exentostemp` | `bdilide` | no | INSERT | L118 |
| `statistics` | `bdilide` | no | UPDATE | L128 |
| `sl_exentostemp` | `bdilide` | no | SELECT | L133 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_diaprimeroultimomesanio` | `bdinteg` | ⚠️ sí | L84 |
| `sp_actualizaresultadosat` | `bdilide` | no | L137 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `valida` | ACCION | valida | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `archivo` | ENTIDAD | archivo | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `resultado` | ENTIDAD | resultado | 🔵 CONVENCIÓN | nombre_sp |

---

## `sp_validasolicitudide`

| Campo | Valor |
|-------|-------|
| **Dominio** | D15 · `bdilide` · LIDE / PLD |
| **Archivo fuente** | `bdilide_sp_validasolicitudide.sql` |
| **LOC (1er CREATE)** | 94 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "valida solicitud y identificador" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `valida` → `IF` encontrado en el cuerpo · `valida` → `RETURN` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=1 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_validasolicitudide(
  pRFC                         CHAR(13)
  pfecha                       CHAR(10)
) RETURNING CHAR(6), CHAR(60)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pRFC` | `CHAR(13)` | — | — |
| `pfecha` | `CHAR(10)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(6)` | L5 |
| `isql_err` | `INTEGER` | L6 |
| `cMensaje` | `CHAR(60)` | L7 |
| `vFechaSolic` | `VARCHAR(10)` | L8 |
| `vexiste` | `INTEGER` | L9 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sl_consat` | `bdilide` | no | SELECT | L41 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L59 | VALIDACIÓN_NULL | `IF vFechaSolic IS NULL OR vFechaSolic = '' THEN` |  |
| L65 | VALIDACIÓN_NULL | `IF vFechaSolic IS NULL THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `valida` | ACCION | valida | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `solicitud` | ENTIDAD | solicitud | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `id` | ENTIDAD | identificador (de) | 🔵 CONVENCIÓN | nombre_sp |
| `?e` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?e` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `spslactreporteentero`

| Campo | Valor |
|-------|-------|
| **Dominio** | D15 · `bdilide` · LIDE / PLD |
| **Archivo fuente** | `bdilide_spslactreporteentero.sql` |
| **LOC (1er CREATE)** | 55 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "actualiza reporte y ro — Rol Operativo" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `actualiza` → `UPDATE` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=2 · INFERIDO=1 · SINTÉTICO=3 / 6 términos |

### Historia del SP

| Tipo | Valor |
|------|-------|
| MODIFICACION | Anselmo Verdugo --* |
| ACTIVIDAD | Se actualiza el campo num_operacion y fech_operacion en la tabla sl_enteros. |
| FECHA | 14/AGO/2008 --* |

### Firma

```sql
CREATE PROCEDURE spslactreporteentero(
  p_dfechareporte              DATE
  p_susuario                   CHAR(8)
  p_snum_operacion             CHAR(20)
  p_dfecha_operacion           DATE
) RETURNING CHAR(5), CHAR(80)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_dfechareporte` | `DATE` | `reporte`=reporte | 🔵 CONVENCIÓN |
| `p_susuario` | `CHAR(8)` | — | — |
| `p_snum_operacion` | `CHAR(20)` | — | — |
| `p_dfecha_operacion` | `DATE` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `v_scodret` | `CHAR(5)` | L10 |
| `v_smensaje` | `CHAR(80)` | L11 |
| `sql_err` | `INTEGER` | L13 |
| `isam_err` | `INTEGER` | L14 |
| `error_info` | `CHAR(40)` | L15 |
| `v_sstatus` | `CHAR(1)` | L16 |
| `v_dfechahoy` | `DATE` | L17 |
| `v_snum_operacion` | `CHAR(20)` | L18 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sl_enteros` | `bdilide` | no | SELECT | L41 |
| `sl_enteros` | `bdilide` | no | UPDATE | L43 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L23 | FÓRMULA | `LET v_smensaje = sql_err\|\|" * "\|\|isam_err\|\| " * "\|\|error_info;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sps` | PREFIJO | sps — prefijo alternativo de SP en bdibei (posiblemente 'sto | 🟡 INFERIDO | nombre_sp |
| `?l` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `act` | ACCION | actualiza | 🔵 CONVENCIÓN | nombre_sp |
| `reporte` | ENTIDAD | reporte | 🔵 CONVENCIÓN | nombre_sp |
| `?ente` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `ro` | ENTIDAD | ro — Rol Operativo (subsistema sp_sw_ro_* — bdicnweb) | 🔴 SINTÉTICO | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?l`, `?ente`, `ro` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `spslconreporteentero`

| Campo | Valor |
|-------|-------|
| **Dominio** | D15 · `bdilide` · LIDE / PLD |
| **Archivo fuente** | `bdilide_spslconreporteentero.sql` |
| **LOC (1er CREATE)** | 72 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "consulta reporte y ro — Rol Operativo" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=0 · INFERIDO=1 · SINTÉTICO=3 / 6 términos |

### Historia del SP

| Tipo | Valor |
|------|-------|
| MODIFICACION | Anselmo Verdugo --* |
| ACTIVIDAD | Se recupera la cantidad enterada para la fecha dada, así como el número de operación y la fecha de operación. |
| FECHA | 14/AGO/2008 --* |
| MODIFICACION | Aymme Osuna |
| ACTIVIDAD | Se agregan validaciones para el caso que no este dado de alta el registro del entero pero que en la sl_procesos |
| FECHA | 15/AGO/2008 |

### Firma

```sql
CREATE PROCEDURE spslconreporteentero(
  p_dfechareporte              DATE
) RETURNING CHAR(5), CHAR(80), MONEY(16,2), CHAR(20),DATE
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_dfechareporte` | `DATE` | `reporte`=reporte | ✅ CÓDIGO |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `v_scodret` | `CHAR(5)` | L17 |
| `v_smensaje` | `CHAR(80)` | L18 |
| `v_mrecaudado` | `MONEY(16,2);	DEFINE v_snum_operacion	      CHAR(20)` | L20 |
| `sql_err` | `INTEGER` | L22 |
| `isam_err` | `INTEGER` | L23 |
| `error_info` | `CHAR(40)` | L24 |
| `v_sstatus` | `CHAR(1)` | L25 |
| `v_dfechahoy` | `DATE` | L26 |
| `v_dFechaOperacion` | `DATE` | L27 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sl_procesos` | `bdilide` | no | SELECT | L50 |
| `sl_enteros` | `bdilide` | no | SELECT | L58 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L31 | FÓRMULA | `LET v_smensaje = sql_err\|\|" * "\|\|isam_err\|\| " * "\|\|error_info;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sps` | PREFIJO | sps — prefijo alternativo de SP en bdibei (posiblemente 'sto | 🟡 INFERIDO | nombre_sp |
| `?l` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `con` | ACCION | consulta | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `reporte` | ENTIDAD | reporte | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?ente` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `ro` | ENTIDAD | ro — Rol Operativo (subsistema sp_sw_ro_* — bdicnweb) | 🔴 SINTÉTICO | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?l`, `?ente`, `ro` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `spsldecanual`

| Campo | Valor |
|-------|-------|
| **Dominio** | D15 · `bdilide` · LIDE / PLD |
| **Archivo fuente** | `bdilide_spsldecanual.sql` |
| **LOC (1er CREATE)** | 514 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "spsldecanual" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 19 tabla(s) con operaciones: INSERT, UPDATE, SELECT |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=0 · INFERIDO=1 · SINTÉTICO=1 / 2 términos |

### Historia del SP

| Tipo | Valor |
|------|-------|
| MODIFICACION | Anselmo Verdugo |
| ACTIVIDAD | Hace el llenado a las tablas para la generación del archivo XML anual. |
| FECHA | 05/SEP/2008 |
| MODIFICACION | Marcos Cuevas |
| ACTIVIDAD | Se elimina la validacion que indicaba si el monto del movimiento era mayor o igual al monto minimo y se optimiza. |
| FECHA | 16/04/2010 |

### Firma

```sql
CREATE PROCEDURE spsldecanual(
  pFechaProceso                DATE
  pUsuario                     VARCHAR(8)
  pTipoDecl                    CHAR(1)
  pFechaPresentacion           DATE
  pNumFolio                    VARCHAR(16)
) RETURNING VARCHAR(5), VARCHAR (80)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pFechaProceso` | `DATE` | — | — |
| `pUsuario` | `VARCHAR(8)` | — | — |
| `pTipoDecl` | `CHAR(1)` | — | — |
| `pFechaPresentacion` | `DATE` | — | — |
| `pNumFolio` | `VARCHAR(16)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `v_scodret` | `VARCHAR(5)` | L19 |
| `v_smensaje` | `VARCHAR(80)` | L20 |
| `sql_err` | `INTEGER` | L21 |
| `isam_err` | `INTEGER` | L22 |
| `error_info` | `VARCHAR(40)` | L23 |
| `v_sstatus` | `CHAR(1)` | L24 |
| `v_sstatusmen` | `CHAR(1)` | L25 |
| `v_ianio` | `INTEGER` | L26 |
| `v_saniomes` | `VARCHAR(6)` | L27 |
| `v_smesenero` | `VARCHAR(6)` | L28 |
| `v_dfecha_hoy` | `DATE` | L29 |
| `viNumComple` | `INTEGER` | L30 |
| `vTable1` | `VARCHAR(70)` | L32 |
| `vAnioMes` | `VARCHAR(6)` | L33 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `systables` | `bdilide` | no | SELECT | L61 |
| `sl_declinfor` | `bdilide` | no | SELECT | L107 |
| `sl_procesos` | `bdilide` | no | SELECT | L149 |
| `sl_procesos` | `bdilide` | no | INSERT | L178 |
| `sl_procesos` | `bdilide` | no | UPDATE | L195 |
| `sysindices` | `bdilide` | no | SELECT | L213 |
| `tmp_paso_datos_anualxml` | `bdilide` | no | INSERT | L220 |
| `sl_menxml` | `bdilide` | no | SELECT | L226 |
| `statistics` | `bdilide` | no | UPDATE | L242 |
| `sl_anualxml` | `bdilide` | no | INSERT | L261 |
| `tmp_paso_datos_anualxml` | `bdilide` | no | SELECT | L269 |
| `tmp_insertadatoslidecte` | `bdilide` | no | INSERT | L295 |
| `sl_detlide` | `bdilide` | no | SELECT | L298 |
| `sl_movefec_his` | `bdilide` | no | SELECT | L315 |
| `sl_movctas` | `bdilide` | no | INSERT | L397 |
| `tmp_insertadatoslidecte` | `bdilide` | no | SELECT | L400 |
| `sl_ctas` | `bdilide` | no | INSERT | L414 |
| `sl_declinfor` | `bdilide` | no | INSERT | L446 |
| `sl_anualxml` | `bdilide` | no | SELECT | L453 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L36 | CÓDIGO_RETORNO | `LET v_scodret    = '00001';` |  |
| L44 | FÓRMULA | `LET v_saniomes   = v_ianio \|\| '13'; --LPAD(v_imes,2,0); --` |  |
| L57 | FÓRMULA | `LET v_smensaje = sql_err\|\|" * "\|\|isam_err\|\| " * "\|\|error_info\|\| v_smensaje;` |  |
| L121 | CÓDIGO_RETORNO | `LET v_scodret = '00007';` |  |
| L139 | CÓDIGO_RETORNO | `LET v_scodret = '00006';` |  |
| L203 | CÓDIGO_RETORNO | `LET v_scodret = '00001';` |  |
| L500 | CÓDIGO_RETORNO | `LET v_scodret = '00000';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sps` | PREFIJO | sps — prefijo alternativo de SP en bdibei (posiblemente 'sto | 🟡 INFERIDO | nombre_sp |
| `?ldecanual` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?ldecanual` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `spsldecmensual`

| Campo | Valor |
|-------|-------|
| **Dominio** | D15 · `bdilide` · LIDE / PLD |
| **Archivo fuente** | `bdilide_spsldecmensual.sql` |
| **LOC (1er CREATE)** | 830 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "(mensual)" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 2 llamada(s): `sp_dia_primero_ultimo_mes_anio`, `sp_checacurp` |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=0 · INFERIDO=1 · SINTÉTICO=1 / 3 términos |

### Firma

```sql
CREATE PROCEDURE spsldecmensual(
  p_dfechaproceso              DATE
  p_susuario                   CHAR(8)
  pTipoDecl                    CHAR(1)
  pFechaPresentacion           DATE
  pNumFolio                    CHAR(16)
) RETURNING CHAR(6), CHAR(80)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_dfechaproceso` | `DATE` | — | — |
| `p_susuario` | `CHAR(8)` | — | — |
| `pTipoDecl` | `CHAR(1)` | — | — |
| `pFechaPresentacion` | `DATE` | — | — |
| `pNumFolio` | `CHAR(16)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `v_scodret` | `VARCHAR(5)` | L8 |
| `v_smensaje` | `VARCHAR(80)` | L9 |
| `sql_err` | `INTEGER` | L11 |
| `isam_err` | `INTEGER` | L12 |
| `error_info` | `VARCHAR(40)` | L13 |
| `v_icount` | `INTEGER` | L15 |
| `v_sstatus` | `VARCHAR(1)` | L16 |
| `v_dfech_proceso` | `DATE` | L17 |
| `v_snum_operacion` | `VARCHAR(20)` | L18 |
| `v_dfech_operacion` | `DATE` | L19 |
| `v_snum_cte` | `VARCHAR(20)` | L21 |
| `v_dfecha_ret` | `DATE` | L22 |
| `v_dfecha_ret_pas` | `DATE` | L23 |
| `v_mimp_gravado` | `MONEY(16,2)` | L24 |
| `v_mimp_arecaudar` | `MONEY(16,2)` | L25 |
| `v_mimp_recaudado` | `MONEY(16,2)` | L26 |
| `v_mimp_remanente` | `MONEY(16,2)` | L27 |
| `v_stpo_persona` | `VARCHAR(2)` | L29 |
| `v_sapell_paterno` | `VARCHAR(26)` | L30 |
| `v_sapell_materno` | `VARCHAR(26)` | L31 |
| `v_snombre1` | `VARCHAR(26)` | L32 |
| `v_snombre2` | `VARCHAR(26)` | L33 |
| `v_srazon_social` | `VARCHAR(60)` | L34 |
| `v_srfc` | `VARCHAR(13)` | L35 |
| `v_scurp` | `VARCHAR(20)` | L36 |
| *…54 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `systables` | `bdilide` | no | SELECT | L203 |
| `sl_declinfor` | `bdilide` | no | SELECT | L239 |
| `sl_procesos` | `bdilide` | no | SELECT | L258 |
| `sl_procesos` | `bdilide` | no | INSERT | L262 |
| `sl_menxml` | `bdilide` | no | SELECT | L270 |
| `sl_procesos` | `bdilide` | no | UPDATE | L275 |
| `statistics` | `bdilide` | no | UPDATE | L315 |
| `sl_retlide` | `bdilide` | no | SELECT | L331 |
| `tmp_iderecaudacionesctemensual` | `bdilide` | no | INSERT | L336 |
| `sl_detlide` | `bdilide` | no | SELECT | L352 |
| `si_cliente` | `bdinteg` | ⚠️ sí | SELECT | L407 |
| `tmp_datosclienteside` | `bdilide` | no | INSERT | L412 |
| `si_direcciones_actual` | `bdinteg` | ⚠️ sí | SELECT | L455 |
| `tmp_direccionesclienteside` | `bdilide` | no | INSERT | L465 |
| `tmp_iderecaudacionesctemensual` | `bdilide` | no | SELECT | L482 |
| `tmp_sl_detliderecant` | `bdilide` | no | SELECT | L496 |
| `tmp_datosclienteside` | `bdilide` | no | SELECT | L514 |
| `tmp_direccionesclienteside` | `bdilide` | no | SELECT | L529 |
| `sl_menxml` | `bdilide` | no | INSERT | L536 |
| `sl_enteros` | `bdilide` | no | SELECT | L800 |
| `sl_declinfor` | `bdilide` | no | INSERT | L813 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_dia_primero_ultimo_mes_anio` | `bdicheq` | ⚠️ sí | L318 |
| `sp_checacurp` | `bdilide` | no | L518 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L106 | FÓRMULA | `LET v_smensaje = v_snum_cte \|\| " * " \|\| v_dfecha_ret \|\| " * " \|\| v_smensaje;` |  |
| L113 | CÓDIGO_RETORNO | `LET v_scodret 				= '00001';` |  |
| L232 | FÓRMULA | `LET dFormatoFechaPeriodo=MONTH(TODAY)\|\|'/'\|\|'01'\|\|'/'\|\|YEAR(TODAY);` |  |
| L233 | FÓRMULA | `LET dFecha_primer_dia_anterior=dFormatoFechaPeriodo - 1 UNITS MONTH;` |  |
| L241 | CÓDIGO_RETORNO | `LET v_scodret = '00007';` |  |
| L251 | CÓDIGO_RETORNO | `LET v_scodret = '00006';` |  |
| L261 | VALIDACIÓN_NULL | `IF v_sstatus IS NULL THEN` |  |
| L487 | VALIDACIÓN_NULL | `IF v_dfecha_ret IS NULL THEN` |  |
| L505 | FÓRMULA | `LET mRecPendiente = ROUND(NVL(v_mimp_arecaudar,0)) - ROUND(NVL(v_mimp_recaudado,0));` | 🔴 MONEY/aritmética financiera |
| L532 | VALIDACIÓN_NULL | `IF v_snumerointcalle IS NULL AND v_snombrezona IS NULL THEN` |  |
| L542 | FÓRMULA | `LET nCont = nCont + 1;` |  |
| L597 | VALIDACIÓN_NULL | `IF v_snumerointcalle IS NULL AND v_snombrezona IS NULL THEN` |  |
| L607 | FÓRMULA | `LET nCont = nCont + 1;` |  |
| L666 | FÓRMULA | `LET v_saniomesant =  v_ianio \|\| LPAD((v_imes - 1),2,0); --DSB 25/03/2013` |  |
| L766 | FÓRMULA | `LET v_mtotrecaudado = v_mtotrecaudado + ROUND(v_mimp_recaudado,0);` | 🔴 MONEY/aritmética financiera |
| L768 | FÓRMULA | `LET v_mtotsaldopenrec = v_mtotsaldopenrec + ROUND(v_msaldopenrec,0);` | 🔴 MONEY/aritmética financiera |
| L788 | FÓRMULA | `LET v_mtotpendiente = v_mtotdeterminado - v_mtotrecaudado;` |  |
| L819 | CÓDIGO_RETORNO | `LET v_scodret = '00000';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sps` | PREFIJO | sps — prefijo alternativo de SP en bdibei (posiblemente 'sto | 🟡 INFERIDO | nombre_sp |
| `?ldec` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `mensual` | MODIF | mensual | ✅ CÓDIGO | nombre_sp, texto_cuerpo |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?ldec` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `spsldecmensual2`

| Campo | Valor |
|-------|-------|
| **Dominio** | D15 · `bdilide` · LIDE / PLD |
| **Archivo fuente** | `bdilide_spsldecmensual2.sql` |
| **LOC (1er CREATE)** | 733 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "(mensual)" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 2 llamada(s): `sp_dia_primero_ultimo_mes_anio`, `sp_checacurp` |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=0 · INFERIDO=1 · SINTÉTICO=2 / 4 términos |

### Firma

```sql
CREATE PROCEDURE spsldecmensual2(
  p_dfechaproceso              DATE
  p_susuario                   CHAR(8)
  pTipoDecl                    CHAR(1)
  pFechaPresentacion           DATE
  pNumFolio                    CHAR(16)
) RETURNING CHAR(6), CHAR(80)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_dfechaproceso` | `DATE` | — | — |
| `p_susuario` | `CHAR(8)` | — | — |
| `pTipoDecl` | `CHAR(1)` | — | — |
| `pFechaPresentacion` | `DATE` | — | — |
| `pNumFolio` | `CHAR(16)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `v_scodret` | `VARCHAR(5)` | L8 |
| `v_smensaje` | `VARCHAR(80)` | L9 |
| `sql_err` | `INTEGER` | L11 |
| `isam_err` | `INTEGER` | L12 |
| `error_info` | `VARCHAR(40)` | L13 |
| `v_icount` | `INTEGER` | L15 |
| `v_sstatus` | `VARCHAR(1)` | L16 |
| `v_dfech_proceso` | `DATE` | L17 |
| `v_snum_operacion` | `VARCHAR(20)` | L18 |
| `v_dfech_operacion` | `DATE` | L19 |
| `v_snum_cte` | `VARCHAR(20)` | L21 |
| `v_dfecha_ret` | `DATE` | L22 |
| `v_dfecha_ret_pas` | `DATE` | L23 |
| `v_mimp_gravado` | `MONEY(16,2)` | L24 |
| `v_mimp_arecaudar` | `MONEY(16,2)` | L25 |
| `v_mimp_recaudado` | `MONEY(16,2)` | L26 |
| `v_mimp_remanente` | `MONEY(16,2)` | L27 |
| `v_stpo_persona` | `VARCHAR(2)` | L29 |
| `v_sapell_paterno` | `VARCHAR(26)` | L30 |
| `v_sapell_materno` | `VARCHAR(26)` | L31 |
| `v_snombre1` | `VARCHAR(26)` | L32 |
| `v_snombre2` | `VARCHAR(26)` | L33 |
| `v_srazon_social` | `VARCHAR(60)` | L34 |
| `v_srfc` | `VARCHAR(13)` | L35 |
| `v_scurp` | `VARCHAR(20)` | L36 |
| *…55 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `systables` | `bdilide` | no | SELECT | L220 |
| `sl_declinfor` | `bdilide` | no | SELECT | L256 |
| `sl_procesos` | `bdilide` | no | SELECT | L275 |
| `sl_procesos` | `bdilide` | no | INSERT | L279 |
| `sl_menxml` | `bdilide` | no | SELECT | L289 |
| `sl_procesos` | `bdilide` | no | UPDATE | L296 |
| `statistics` | `bdilide` | no | UPDATE | L336 |
| `sl_retlide` | `bdilide` | no | SELECT | L352 |
| `tmp_iderecaudacionesctemensual` | `bdilide` | no | INSERT | L357 |
| `si_cliente` | `bdinteg` | ⚠️ sí | SELECT | L404 |
| `tmp_datosclienteside` | `bdilide` | no | INSERT | L409 |
| `si_direcciones_actual` | `bdinteg` | ⚠️ sí | SELECT | L455 |
| `tmp_direccionesclienteside` | `bdilide` | no | INSERT | L465 |
| `tmp_iderecaudacionesctemensual` | `bdilide` | no | SELECT | L482 |
| `tmp_datosclienteside` | `bdilide` | no | SELECT | L501 |
| `tmp_direccionesclienteside` | `bdilide` | no | SELECT | L516 |
| `sl_menxml` | `bdilide` | no | INSERT | L523 |
| `sl_enteros` | `bdilide` | no | SELECT | L704 |
| `sl_declinfor` | `bdilide` | no | INSERT | L710 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_dia_primero_ultimo_mes_anio` | `bdicheq` | ⚠️ sí | L339 |
| `sp_checacurp` | `bdilide` | no | L505 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L103 | CÓDIGO_RETORNO | `LET v_scodret 				= '00001';` |  |
| L190 | FÓRMULA | `LET v_smensaje = v_snum_cte \|\| " * " \|\| v_dfecha_ret \|\| " * " \|\| v_smensaje;` |  |
| L245 | FÓRMULA | `LET dFormatoFechaPeriodo=MONTH(TODAY)\|\|'/'\|\|'01'\|\|'/'\|\|YEAR(TODAY);` |  |
| L246 | FÓRMULA | `LET dFecha_primer_dia_anterior=dFormatoFechaPeriodo - 1 UNITS MONTH;` |  |
| L257 | CÓDIGO_RETORNO | `LET v_scodret = '00007';` |  |
| L278 | VALIDACIÓN_NULL | `IF v_sstatus IS NULL THEN` |  |
| L487 | VALIDACIÓN_NULL | `IF v_dfecha_ret IS NULL THEN` |  |
| L492 | FÓRMULA | `LET mRecPendiente = ROUND(NVL(v_mimp_arecaudar,0)) - ROUND(NVL(v_mimp_recaudado,0));` | 🔴 MONEY/aritmética financiera |
| L519 | VALIDACIÓN_NULL | `IF v_snumerointcalle IS NULL AND v_snombrezona IS NULL THEN` |  |
| L529 | FÓRMULA | `LET nCont = nCont + 1;` |  |
| L586 | FÓRMULA | `LET v_saniomesant =  v_ianio \|\| LPAD((v_imes - 1),2,0); --DSB 25/03/2013` |  |
| L670 | FÓRMULA | `LET v_mtotrecaudado = v_mtotrecaudado + ROUND(v_mimp_recaudado,0);` | 🔴 MONEY/aritmética financiera |
| L672 | FÓRMULA | `LET v_mtotsaldopenrec = v_mtotsaldopenrec + ROUND(v_msaldopenrec,0);` | 🔴 MONEY/aritmética financiera |
| L692 | FÓRMULA | `LET v_mtotpendiente = v_mtotdeterminado - v_mtotrecaudado;` |  |
| L716 | CÓDIGO_RETORNO | `LET v_scodret = '00000';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sps` | PREFIJO | sps — prefijo alternativo de SP en bdibei (posiblemente 'sto | 🟡 INFERIDO | nombre_sp |
| `?ldec` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `mensual` | MODIF | mensual | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?2` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?ldec`, `?2` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `spsldecmensual_gen`

| Campo | Valor |
|-------|-------|
| **Dominio** | D15 · `bdilide` · LIDE / PLD |
| **Archivo fuente** | `bdilide_spsldecmensual_gen.sql` |
| **LOC (1er CREATE)** | 61 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "genera (mensual)" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 1 llamada(s): `spsldecmensual` |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=1 · INFERIDO=2 · SINTÉTICO=1 / 4 términos |

### Firma

```sql
CREATE PROCEDURE spsldecmensual_gen(
) RETURNING CHAR (5), CHAR(500)
```

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `iSqlErr` | `INTEGER` | L5 |
| `cCodret` | `CHAR(5)` | L6 |
| `cVarDataErr1` | `CHAR(500)` | L7 |
| `dFormatoFechaPeriodo` | `DATE` | L9 |
| `dFechaUltimodia` | `DATE` | L10 |
| `vVnumEmp` | `VARCHAR(8)` | L11 |
| `vTipoDeclaracion` | `CHAR(1)` | L12 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `spsldecmensual` | `bdilide` | no | L43 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L38 | FÓRMULA | `LET dFormatoFechaPeriodo = MONTH(TODAY)\|\|'/'\|\|'01'\|\|'/'\|\|YEAR(TODAY);` |  |
| L39 | FÓRMULA | `LET dFechaUltimodia = dFormatoFechaPeriodo -1 UNITS MONTH;` | 🔴 MONEY/aritmética financiera |
| L40 | FÓRMULA | `LET dFechaUltimodia = MONTH(dFechaUltimodia)\|\|'/'\|\|DAY(LAST_DAY(dFechaUltimodia))\|\|'/'\|\|YEAR` | 🔴 MONEY/aritmética financiera |
| L48 | CÓDIGO_RETORNO | `LET cCodret = '00000';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sps` | PREFIJO | sps — prefijo alternativo de SP en bdibei (posiblemente 'sto | 🟡 INFERIDO | nombre_sp |
| `?ldec` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `mensual` | MODIF | mensual | 🔵 CONVENCIÓN | nombre_sp |
| `gen` | ACCION | genera / general | 🟡 INFERIDO | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?ldec` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `spsldetreporteentero`

| Campo | Valor |
|-------|-------|
| **Dominio** | D15 · `bdilide` · LIDE / PLD |
| **Archivo fuente** | `bdilide_spsldetreporteentero.sql` |
| **LOC (1er CREATE)** | 48 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "detalle, reporte y ro — Rol Operativo" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 2 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=1 · INFERIDO=2 · SINTÉTICO=3 / 6 términos |

### Firma

```sql
CREATE PROCEDURE spsldetreporteentero(
  p_dfechareporte              DATE
) RETURNING CHAR(5), CHAR(20), CHAR(20), DATE, MONEY(16,2)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_dfechareporte` | `DATE` | `reporte`=reporte | 🔵 CONVENCIÓN |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `v_scodret` | `CHAR(5)` | L6 |
| `v_snum_cte` | `CHAR(20)` | L7 |
| `v_scuenta_ret` | `CHAR(20)` | L8 |
| `v_dfecha_ret` | `DATE` | L9 |
| `v_mrecaudado` | `MONEY (16,2)` | L10 |
| `sql_err` | `INTEGER` | L12 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sl_enteros` | `bdilide` | no | SELECT | L31 |
| `sl_detlide` | `bdilide` | no | SELECT | L37 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sps` | PREFIJO | sps — prefijo alternativo de SP en bdibei (posiblemente 'sto | 🟡 INFERIDO | nombre_sp |
| `?l` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `det` | ENTIDAD | detalle | 🟡 INFERIDO | nombre_sp |
| `reporte` | ENTIDAD | reporte | 🔵 CONVENCIÓN | nombre_sp |
| `?ente` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `ro` | ENTIDAD | ro — Rol Operativo (subsistema sp_sw_ro_* — bdicnweb) | 🔴 SINTÉTICO | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?l`, `?ente`, `ro` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `spslgenreporteentero`

| Campo | Valor |
|-------|-------|
| **Dominio** | D15 · `bdilide` · LIDE / PLD |
| **Archivo fuente** | `bdilide_spslgenreporteentero.sql` |
| **LOC (1er CREATE)** | 105 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "genera reporte ro — Rol Operativo" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `genera` → `INSERT` encontrado en el cuerpo · `genera` → `SELECT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=0 · INFERIDO=2 · SINTÉTICO=3 / 5 términos |

### Firma

```sql
CREATE PROCEDURE spslgenreporteentero(
  p_sempresa                   CHAR(3)
  p_dfechareporte              DATE
  p_susuario                   CHAR(8)
) RETURNING CHAR(3), CHAR(80)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_sempresa` | `CHAR(3)` | — | — |
| `p_dfechareporte` | `DATE` | — | — |
| `p_susuario` | `CHAR(8)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `v_scodret` | `CHAR(3)` | L7 |
| `v_smensaje` | `CHAR(80)` | L8 |
| `sql_err` | `INTEGER` | L9 |
| `isam_err` | `INTEGER` | L10 |
| `error_info` | `CHAR(40)` | L11 |
| `v_sstatus` | `CHAR(1)` | L12 |
| `v_mrecaudado` | `MONEY(18,2)` | L13 |
| `v_dfechahoy` | `DATE` | L14 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sl_procesos` | `bdilide` | no | SELECT | L36 |
| `sl_enteros` | `bdilide` | no | SELECT | L42 |
| `sl_enteros` | `bdilide` | no | DELETE | L42 |
| `sl_detlide` | `bdilide` | no | SELECT | L47 |
| `sl_enteros` | `bdilide` | no | INSERT | L57 |
| `sl_procesos` | `bdilide` | no | UPDATE | L60 |
| `sl_procesos` | `bdilide` | no | INSERT | L94 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L18 | FÓRMULA | `LET v_smensaje = sql_err\|\|" * "\|\|isam_err\|\| " * "\|\|error_info;` |  |
| L53 | VALIDACIÓN_NULL | `IF v_mrecaudado IS NULL THEN` |  |
| L87 | VALIDACIÓN_NULL | `IF v_mrecaudado IS NULL THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sps` | PREFIJO | sps — prefijo alternativo de SP en bdibei (posiblemente 'sto | 🟡 INFERIDO | nombre_sp |
| `?l` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `genrep` | ACCION | genera reporte (abreviación genrep) | 🟡 INFERIDO | nombre_sp |
| `?orteente` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `ro` | ENTIDAD | ro — Rol Operativo (subsistema sp_sw_ro_* — bdicnweb) | 🔴 SINTÉTICO | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?l`, `?orteente`, `ro` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `spslgenreporteentero_esp`

| Campo | Valor |
|-------|-------|
| **Dominio** | D15 · `bdilide` · LIDE / PLD |
| **Archivo fuente** | `bdilide_spslgenreporteentero_esp.sql` |
| **LOC (1er CREATE)** | 81 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "genera reporte ro — Rol Operativo (especial)" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `genera` → `INSERT` encontrado en el cuerpo · `genera` → `SELECT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=1 · INFERIDO=2 · SINTÉTICO=3 / 6 términos |

### Firma

```sql
CREATE PROCEDURE spslgenreporteentero_esp(
  p_dfechareporte              DATE
) RETURNING CHAR(3), CHAR(80)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `p_dfechareporte` | `DATE` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `v_scodret` | `CHAR(5)` | L4 |
| `v_scodret2` | `CHAR(5)` | L5 |
| `v_scodret3` | `CHAR(50)` | L6 |
| `sql_err` | `INTEGER` | L7 |
| `isam_err` | `INTEGER` | L8 |
| `error_info` | `CHAR(50)` | L9 |
| `v_smensaje` | `CHAR(80)` | L10 |
| `v_mrecaudado` | `MONEY(18,2)` | L11 |
| `v_dfechahoy` | `DATE` | L12 |
| `vExiste` | `INTEGER` | L13 |
| `vctemin` | `CHAR(20)` | L14 |
| `vctemax` | `CHAR(20)` | L15 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sl_enteros` | `bdilide` | no | SELECT | L48 |
| `sl_enteros` | `bdilide` | no | DELETE | L52 |
| `sl_detlide` | `bdilide` | no | SELECT | L58 |
| `sl_enteros` | `bdilide` | no | INSERT | L71 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L36 | FÓRMULA | `LET v_smensaje = sql_err\|\|" * "\|\|isam_err\|\| " * "\|\|error_info;` |  |
| L67 | VALIDACIÓN_NULL | `IF v_mrecaudado IS NULL THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sps` | PREFIJO | sps — prefijo alternativo de SP en bdibei (posiblemente 'sto | 🟡 INFERIDO | nombre_sp |
| `?l` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `genrep` | ACCION | genera reporte (abreviación genrep) | 🟡 INFERIDO | nombre_sp |
| `?orteente` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `ro` | ENTIDAD | ro — Rol Operativo (subsistema sp_sw_ro_* — bdicnweb) | 🔴 SINTÉTICO | nombre_sp |
| `esp` | MODIF | especial | 🔵 CONVENCIÓN | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?l`, `?orteente`, `ro` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

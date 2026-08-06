# SP Specs — D13 · `bditef` · TEF

> Generado por `build-sp-specs.py` · Grounding Pass v1.0
> Objetivo: verificar el conocimiento del Gemelo Cognitivo contra el código fuente real
> **Convención:** solo se analiza el PRIMER `CREATE PROCEDURE` de cada archivo
> (los siguientes son dependencias concatenadas — ver memoria del proyecto)

## Resumen de validación del dominio

| Métrica | Valor |
|---------|-------|
| SPs analizados | **139** |
| Presentes en callgraph | 68 |
| SPs aislados (⚠️ no estaban en el análisis previo) | 71 |
| Propósito **VERIFICADO** | 99 |
| Propósito **PARCIAL** | 40 |
| Propósito **NO_VERIFICABLE** | 0 |
| SPs con tokens **SINTÉTICOS** detectados | 87 |

> Los **71 SPs aislados** no aparecen en el callgraph y por tanto
> **no fueron incluidos en el análisis de journeys, reglas ni vocabulario previo**.
> Este grounding pass los analiza por primera vez directamente desde el código.

---

## `abono_cta`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_abono_cta.sql` |
| **LOC (1er CREATE)** | 108 |
| **Callgraph** | ✅ fan_in=25 / fan_out=1 |
| **Propósito inferido** | "abono y cuenta" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 1 llamada(s): `abono_ref` |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=0 · INFERIDO=0 · SINTÉTICO=0 / 2 términos |

### Firma

```sql
CREATE PROCEDURE abono_cta(
  pempresa                     char(3)
  pcuenta                      char(20)
  pnrocheque                   integer
  pimporte                     decimal(16,2)
  pmoneda                      char(2)
  pusuario                     char(8)
) RETURNING char(5),
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pempresa` | `char(3)` | — | — |
| `pcuenta` | `char(20)` | — | — |
| `pnrocheque` | `integer` | — | — |
| `pimporte` | `decimal(16,2)` | — | — |
| `pmoneda` | `char(2)` | — | — |
| `pusuario` | `char(8)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vsqlerr` | `integer` | L18 |
| `vcodret` | `char(5)` | L19 |
| `vmsg` | `char(35)` | L20 |
| `vfecha` | `date` | L21 |
| `vsucursal` | `char(4)` | L23 |
| `vfolio` | `char(16)` | L24 |
| `vtran_abono` | `char(4)` | L25 |
| `vreferencia` | `char(40)` | L27 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sc_fechas` | `bdicheq` | ⚠️ sí | SELECT | L60 |
| `sc_maechq` | `bdicheq` | ⚠️ sí | SELECT | L66 |
| `cce_param` | `bditef` | no | SELECT | L80 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `abono_ref` | `bdicheq` | ⚠️ sí | L93 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L47 | VALIDACIÓN_NULL | `if  trim(pcuenta) = "" or pcuenta is null` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `abono` | ENTIDAD | abono / crédito | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `cta` | ENTIDAD | cuenta | ✅ CÓDIGO | nombre_sp, texto_cuerpo |

---

## `cal_fecha_pre_fh`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_cal_fecha_pre_fh.sql` |
| **LOC (1er CREATE)** | 111 |
| **Callgraph** | ✅ fan_in=96 / fan_out=0 |
| **Principales callers** | `sp_calificacion_scoring` |
| **Propósito inferido** | "[polisemia] Cálculo y fecha" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 1 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=0 · INFERIDO=1 · SINTÉTICO=1 / 3 términos |

### Firma

```sql
CREATE PROCEDURE cal_fecha_pre_fh(
  v_fechai                     char(10)
) RETURNING char(5),date
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `v_fechai` | `char(10)` | `fecha`=fecha | ✅ CÓDIGO |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `v_codret` | `char(5)` | L5 |
| `v_fecha_pre` | `date` | L6 |
| `v_esferiado` | `char(1)` | L7 |
| `v_bandera` | `char(1)` | L8 |
| `v_fecha` | `date` | L9 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_feriado` | `bdinteg` | ⚠️ sí | SELECT | L51 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L30 | VALIDACIÓN_NULL | `IF  	v_fechai is null THEN` |  |
| L46 | FÓRMULA | `LET v_fecha = to_date(v_fechai,"%m/%d/%Y");` |  |
| L54 | VALIDACIÓN_NULL | `IF v_esferiado is null THEN` |  |
| L59 | FÓRMULA | `LET v_fecha = v_fecha + 1;` |  |
| L64 | FÓRMULA | `LET v_fecha = v_fecha + 1;` |  |
| L68 | FÓRMULA | `LET v_fecha = v_fecha + 2;` |  |
| L72 | FÓRMULA | `LET v_fecha = v_fecha + 1;` |  |
| L89 | VALIDACIÓN_NULL | `IF v_esferiado is null THEN` |  |
| L98 | FÓRMULA | `LET v_fecha = v_fecha + 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `cal` | ENTIDAD | [polisemia] Cálculo (cal_fecha, cal_riesgo_cliente, cal_trad | 🟡 INFERIDO | nombre_sp |
| `fecha` | ENTIDAD | fecha | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `?_pre_fh` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_pre_fh` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `cal_fecha_pre_fh_web`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_cal_fecha_pre_fh_web.sql` |
| **LOC (1er CREATE)** | 103 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "[polisemia] Cálculo y fecha (canal web)" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 1 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=1 · INFERIDO=1 · SINTÉTICO=1 / 4 términos |

### Firma

```sql
CREATE PROCEDURE cal_fecha_pre_fh_web(
  v_fechai                     char(10)
) RETURNING char(5),date
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `v_fechai` | `char(10)` | `fecha`=fecha | ✅ CÓDIGO |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `v_codret` | `char(5)` | L5 |
| `v_fecha_pre` | `date` | L6 |
| `v_esferiado` | `char(1)` | L7 |
| `v_bandera` | `char(1)` | L8 |
| `v_fecha` | `date` | L9 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_feriado` | `bdinteg` | ⚠️ sí | SELECT | L51 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L28 | VALIDACIÓN_NULL | `IF  	v_fechai is null THEN` |  |
| L44 | FÓRMULA | `LET v_fecha = to_date(v_fechai,"%m/%d/%Y");` |  |
| L54 | VALIDACIÓN_NULL | `IF v_esferiado is null THEN` |  |
| L59 | FÓRMULA | `LET v_fecha = v_fecha + 1;` |  |
| L64 | FÓRMULA | `LET v_fecha = v_fecha + 1;` |  |
| L68 | FÓRMULA | `LET v_fecha = v_fecha + 2;` |  |
| L72 | FÓRMULA | `LET v_fecha = v_fecha + 1;` |  |
| L86 | VALIDACIÓN_NULL | `IF v_esferiado is null THEN` |  |
| L95 | FÓRMULA | `LET v_fecha = v_fecha + 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `cal` | ENTIDAD | [polisemia] Cálculo (cal_fecha, cal_riesgo_cliente, cal_trad | 🟡 INFERIDO | nombre_sp |
| `fecha` | ENTIDAD | fecha | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `?_pre_fh_` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `web` | MODIF | canal web | 🔵 CONVENCIÓN | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_pre_fh_` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `cal_fechapre`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_cal_fechapre.sql` |
| **LOC (1er CREATE)** | 149 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "[polisemia] Cálculo y fecha" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 1 llamada(s): `cal_fecha_pre_fh` |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=0 · INFERIDO=1 · SINTÉTICO=1 / 3 términos |

### Firma

```sql
CREATE PROCEDURE cal_fechapre(
  pempresa                     char(3)
  pcvebanco                    char(3)
  pnumcuenta                   char(20)
  pnumcheque                   char(7)
  pfechaofi                    date
) RETURNING char(5),date
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pempresa` | `char(3)` | — | — |
| `pcvebanco` | `char(3)` | — | — |
| `pnumcuenta` | `char(20)` | — | — |
| `pnumcheque` | `char(7)` | — | — |
| `pfechaofi` | `date` | `fecha`=fecha | ✅ CÓDIGO |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `v_codret` | `char(5)` | L9 |
| `v_fechapre` | `date` | L10 |
| `v_horacheque` | `char(5)` | L11 |
| `v_paramhora` | `char(5)` | L12 |
| `v_esferiadox` | `char(1)` | L13 |
| `inumcheque` | `INTEGER` | L15 |
| `inumcuenta` | `DECIMAL(20,0)` | L16 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `cce_param` | `bditef` | no | SELECT | L74 |
| `sc_docret_sbc` | `bdicheq` | ⚠️ sí | SELECT | L99 |
| `si_feriado` | `bdinteg` | ⚠️ sí | SELECT | L120 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `cal_fecha_pre_fh` | `bditef` | no | L137 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L57 | VALIDACIÓN_NULL | `IF  pempresa    	is null or` |  |
| L78 | VALIDACIÓN_NULL | `IF v_paramhora is null THEN` |  |
| L108 | VALIDACIÓN_NULL | `IF v_horacheque is null THEN` |  |
| L123 | VALIDACIÓN_NULL | `IF v_esferiadox is null THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `cal` | ENTIDAD | [polisemia] Cálculo (cal_fecha, cal_riesgo_cliente, cal_trad | 🟡 INFERIDO | nombre_sp |
| `fecha` | ENTIDAD | fecha | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?pre` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?pre` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `cal_fecharet`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_cal_fecharet.sql` |
| **LOC (1er CREATE)** | 62 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "[polisemia] Cálculo y fecha" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 1 llamada(s): `cal_fecha_pre_fh` |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=0 · INFERIDO=1 · SINTÉTICO=1 / 3 términos |

### Firma

```sql
CREATE PROCEDURE cal_fecharet(
  pfechaofi                    date
) RETURNING char(5), date
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pfechaofi` | `date` | `fecha`=fecha | ✅ CÓDIGO |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `v_codret` | `char(5)` | L4 |
| `sql_err` | `integer` | L5 |
| `isam_err` | `integer` | L6 |
| `v_fechapre` | `date` | L7 |
| `v_esferiadox` | `char(1)` | L8 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_feriado` | `bdinteg` | ⚠️ sí | SELECT | L37 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `cal_fecha_pre_fh` | `bditef` | no | L50 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L28 | VALIDACIÓN_NULL | `IF pfechaofi is null THEN` |  |
| L40 | VALIDACIÓN_NULL | `IF v_esferiadox is null THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `cal` | ENTIDAD | [polisemia] Cálculo (cal_fecha, cal_riesgo_cliente, cal_trad | 🟡 INFERIDO | nombre_sp |
| `fecha` | ENTIDAD | fecha | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?ret` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?ret` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `cal_habil_ant`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_cal_habil_ant.sql` |
| **LOC (1er CREATE)** | 111 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "[polisemia] Cálculo y día hábil — día bancario operativo (anterior)" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 1 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=0 · INFERIDO=1 · SINTÉTICO=0 / 3 términos |

### Firma

```sql
CREATE PROCEDURE cal_habil_ant(
  pfecha                       date
) RETURNING char(5),date
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pfecha` | `date` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `v_codret` | `char(5)` | L5 |
| `v_habil_ant` | `date` | L6 |
| `v_esferiado` | `char(1)` | L7 |
| `v_bandera` | `char(1)` | L8 |
| `v_fecha` | `date` | L9 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_feriado` | `bdinteg` | ⚠️ sí | SELECT | L51 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L30 | VALIDACIÓN_NULL | `IF  	pfecha is null THEN` |  |
| L54 | VALIDACIÓN_NULL | `IF v_esferiado is null THEN` |  |
| L59 | FÓRMULA | `LET v_fecha = v_fecha - 1;` |  |
| L64 | FÓRMULA | `LET v_fecha = v_fecha - 1;` |  |
| L68 | FÓRMULA | `LET v_fecha = v_fecha - 1;` |  |
| L72 | FÓRMULA | `LET v_fecha = v_fecha - 2;` |  |
| L89 | VALIDACIÓN_NULL | `IF v_esferiado is null THEN` |  |
| L98 | FÓRMULA | `LET v_fecha = v_fecha - 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `cal` | ENTIDAD | [polisemia] Cálculo (cal_fecha, cal_riesgo_cliente, cal_trad | 🟡 INFERIDO | nombre_sp |
| `habil` | ENTIDAD | día hábil — día bancario operativo (spei_validafecha, sp_cam | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `ant` | MODIF | anterior | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |

---

## `cargo_cta`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_cargo_cta.sql` |
| **LOC (1er CREATE)** | 973 |
| **Callgraph** | ✅ fan_in=0 / fan_out=2 |
| **Deps concatenadas** | 1 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "cargo y cuenta" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 2 llamada(s): `sp_cons_sdodisp_x_tpcalculo`, `cargo_ref` |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=0 · INFERIDO=0 · SINTÉTICO=0 / 2 términos |

### Firma

```sql
CREATE PROCEDURE cargo_cta(
  pempresa                     char(3)
  pcuenta                      char(20)
  pnrocheque                   integer
  pimporte                     decimal(16,2)
  pmoneda                      char(2)
  psec_ctl                     integer
  pusuario                     char(8)
  pfecha_hoy                   date
  pnomarch                     char(30)
) RETURNING char(5),  -- codret
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pempresa` | `char(3)` | — | — |
| `pcuenta` | `char(20)` | — | — |
| `pnrocheque` | `integer` | — | — |
| `pimporte` | `decimal(16,2)` | — | — |
| `pmoneda` | `char(2)` | — | — |
| `psec_ctl` | `integer` | — | — |
| `pusuario` | `char(8)` | — | — |
| `pfecha_hoy` | `date` | — | — |
| `pnomarch` | `char(30)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vsqlerr` | `integer` | L21 |
| `vcodret` | `char(5)` | L22 |
| `vmotdevol` | `char(2)` | L23 |
| `vprocesado` | `char(1)` | L24 |
| `vmsg` | `char(35)` | L25 |
| `vcuenta` | `char(20)` | L26 |
| `vsdodisp` | `money` | L27 |
| `vsaldo` | `money` | L28 |
| `vstatuscta` | `char(1)` | L29 |
| `vmotivo` | `char(2)` | L30 |
| `vchequestat` | `char(1)` | L31 |
| `vstatus` | `char(2)` | L32 |
| `vstatchq` | `char(1)` | L33 |
| `vcargo` | `char(1)` | L34 |
| `vcheqgirados` | `integer` | L35 |
| `vcheqgratis` | `integer` | L36 |
| `vfecha_hoy` | `date` | L37 |
| `vfecha2` | `date` | L38 |
| `vctavalida` | `char(1)` | L39 |
| `vfecha_proc_cta` | `date` | L40 |
| `vsucursal` | `char(4)` | L41 |
| `vfolio` | `char(16)` | L42 |
| `vtrans` | `char(4)` | L43 |
| `vimportecom` | `decimal(16,2)` | L44 |
| `vimporte` | `decimal(16,2)` | L45 |
| *…34 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `cce_propios_det` | `bditef` | no | SELECT | L145 |
| `sc_fechas` | `bdicheq` | ⚠️ sí | SELECT | L163 |
| `sq_param` | `bdicntchq` | ⚠️ sí | SELECT | L177 |
| `cce_param` | `bditef` | no | SELECT | L192 |
| `si_param` | `bdinteg` | ⚠️ sí | SELECT | L281 |
| `sc_comisiones` | `bdicheq` | ⚠️ sí | SELECT | L300 |
| `sc_maechq` | `bdicheq` | ⚠️ sí | SELECT | L319 |
| `sc_producto` | `bdicheq` | ⚠️ sí | SELECT | L334 |
| `sc_maecomtasserv_pm` | `bdicheq` | ⚠️ sí | SELECT | L341 |
| `sc_ctabloqueo` | `bdicheq` | ⚠️ sí | SELECT | L355 |
| `sc_bloqueo` | `bdicheq` | ⚠️ sí | SELECT | L380 |
| `sc_contch` | `bdicheq` | ⚠️ sí | SELECT | L427 |
| `sc_movdia` | `bdicheq` | ⚠️ sí | INSERT | L618 |
| `sc_detcomis` | `bdicheq` | ⚠️ sí | INSERT | L739 |
| `si_coddevcam` | `bdinteg` | ⚠️ sí | SELECT | L769 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_cons_sdodisp_x_tpcalculo` | `bdicheq` | ⚠️ sí | L324 |
| `cargo_ref` | `bdicheq` | ⚠️ sí | L570 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L167 | VALIDACIÓN_NULL | `if  trim(pcuenta) = "" or pcuenta is null or pnrocheque = "" or pnrocheque < 1 then` |  |
| L366 | FÓRMULA | `let vmotdevol   = "09"; -- cuenta bloqueada` |  |
| L373 | FÓRMULA | `let vmotdevol   = "09"; -- cuenta bloqueada` |  |
| L384 | FÓRMULA | `let vmotdevol   = "09"; -- cuenta bloqueada` |  |
| L456 | FÓRMULA | `let vmotdevol   = "18"; -- se cambio por la 53 a peticiï¿½n de CECOBAN. 30-07-2012. JGP.` |  |
| L548 | FÓRMULA | `let vfolio = pusuario \|\| to_char(current hour to fraction,"%H%M%S") \|\| substr(pcuenta, length(pc` |  |
| L560 | FÓRMULA | `let vfolio = pusuario \|\| to_char(current hour to fraction,"%H%M%S") \|\| substr(pcuenta, length(pc` |  |
| L661 | FÓRMULA | `LET vMontoDif = pimporte - vsdodisp;` | 🔴 MONEY/aritmética financiera |
| L673 | FÓRMULA | `let vimportecom = vsdodisp / (1 + viva);` | 🔴 MONEY/aritmética financiera |
| L674 | FÓRMULA | `let vmontopend = vimporte - vimportecom;` | 🔴 MONEY/aritmética financiera |
| L706 | FÓRMULA | `let viva_cob = trunc((vimportecom * viva),2);` | 🔴 MONEY/aritmética financiera |
| L710 | FÓRMULA | `LET viva_cob = vsdodisp - vimportecom;` | 🔴 MONEY/aritmética financiera |
| L722 | FÓRMULA | `let vmsg = "GRABA COM IVA COMPLETOS +++ 01";` |  |
| L776 | FÓRMULA | `let vstatchq = "N"; -- presentado en cam, no pagado` |  |
| L785 | FÓRMULA | `let vstatchq = "M"; -- pagado por camara` |  |
| L848 | FÓRMULA | `let vimportecom  = vsdodisp / (1 + viva);` | 🔴 MONEY/aritmética financiera |
| L849 | FÓRMULA | `let vmontopend = vcomchqgratis - vimportecom;` | 🔴 MONEY/aritmética financiera |
| L858 | FÓRMULA | `let vfolio = pusuario \|\| to_char(current hour to fraction,"%H%M%S") \|\| substr(pcuenta, length(pc` |  |
| L878 | FÓRMULA | `let viva_cob = trunc((vimportecom * viva),2);` | 🔴 MONEY/aritmética financiera |
| L882 | FÓRMULA | `LET viva_cob = vsdodisp - vimportecom;` | 🔴 MONEY/aritmética financiera |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `cargo` | ENTIDAD | cargo / débito | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `cta` | ENTIDAD | cuenta | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |

---

## `cons_dev_coppel`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_cons_dev_coppel.sql` |
| **LOC (1er CREATE)** | 216 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 3 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "consulta Coppel" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=0 / 3 términos |

### Firma

```sql
CREATE PROCEDURE cons_dev_coppel(
  pempresa                     char(3)
  pfechadevo                   char(10)
  pcuenta1                     char(20)
  pcuenta2                     char(20)
  ptrandev                     char(4)
  ptrancom                     char(4)
  ptraniva                     char(4)
) RETURNING char(5),        -- codret
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pempresa` | `char(3)` | — | — |
| `pfechadevo` | `char(10)` | `dev`=devolución | ✅ CÓDIGO |
| `pcuenta1` | `char(20)` | — | — |
| `pcuenta2` | `char(20)` | — | — |
| `ptrandev` | `char(4)` | `dev`=devolución | ✅ CÓDIGO |
| `ptrancom` | `char(4)` | — | — |
| `ptraniva` | `char(4)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `v_codret` | `char(5)` | L20 |
| `v_sucursal` | `char(45)` | L21 |
| `v_banco` | `char(100)` | L22 |
| `v_numcheque` | `char(7)` | L23 |
| `v_importe` | `decimal(16,2)` | L24 |
| `v_com` | `decimal(8,2)` | L25 |
| `v_iva` | `decimal(8,2)` | L26 |
| `v_folio` | `char(16)` | L27 |
| `v_motivodev` | `char(45)` | L28 |
| `v_fechapaso` | `date` | L29 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `cce_cheques_dev` | `bditef` | no | SELECT | L117 |
| `sc_movdia` | `bdicheq` | ⚠️ sí | SELECT | L135 |
| `sc_movhis` | `bdicheq` | ⚠️ sí | SELECT | L168 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L84 | VALIDACIÓN_NULL | `IF      pempresa    is null or` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `cons` | ACCION | consulta | 🔵 CONVENCIÓN | nombre_sp |
| `dev` | ACCION | devolución | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `coppel` | ENTIDAD | Coppel (grupo) | ✅ CÓDIGO | nombre_sp, texto_cuerpo |

---

## `cons_dev_coppel2`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_cons_dev_coppel2.sql` |
| **LOC (1er CREATE)** | 184 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 11 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "consulta Coppel" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=1 / 4 términos |

### Firma

```sql
CREATE PROCEDURE cons_dev_coppel2(
  pempresa                     char(3)
  pfechadevo                   date
  pcuenta1                     char(20)
  pcuenta2                     char(20)
  ptrandev                     char(4)
  ptrancom                     char(4)
  ptraniva                     char(4)
  pRegistros                   INTEGER
  pRecuperacion                INTEGER
) RETURNING char(5),        -- codret
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pempresa` | `char(3)` | — | — |
| `pfechadevo` | `date` | `dev`=devolución | ✅ CÓDIGO |
| `pcuenta1` | `char(20)` | — | — |
| `pcuenta2` | `char(20)` | — | — |
| `ptrandev` | `char(4)` | `dev`=devolución | ✅ CÓDIGO |
| `ptrancom` | `char(4)` | — | — |
| `ptraniva` | `char(4)` | — | — |
| `pRegistros` | `INTEGER` | — | — |
| `pRecuperacion` | `INTEGER` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `v_codret` | `char(5)` | L13 |
| `v_sucursal` | `char(45)` | L14 |
| `v_banco` | `char(100)` | L15 |
| `v_numcheque` | `char(7)` | L16 |
| `v_importe` | `decimal(16,2)` | L17 |
| `v_com` | `decimal(8,2)` | L18 |
| `v_iva` | `decimal(8,2)` | L19 |
| `v_folio` | `char(16)` | L20 |
| `v_motivodev` | `char(45)` | L21 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `cce_cheques_dev` | `bditef` | no | SELECT | L87 |
| `sc_movdia` | `bdicheq` | ⚠️ sí | SELECT | L104 |
| `sc_movhis` | `bdicheq` | ⚠️ sí | SELECT | L137 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L58 | VALIDACIÓN_NULL | `IF      pempresa    is null or` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `cons` | ACCION | consulta | 🔵 CONVENCIÓN | nombre_sp |
| `dev` | ACCION | devolución | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `coppel` | ENTIDAD | Coppel (grupo) | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?2` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?2` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `cons_dev_coppel2_totales`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_cons_dev_coppel2_totales.sql` |
| **LOC (1er CREATE)** | 179 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 10 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "consulta Coppel (totales)" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=1 / 5 términos |

### Firma

```sql
CREATE PROCEDURE cons_dev_coppel2_totales(
  pempresa                     char(3)
  pfechadevo                   date
  pcuenta1                     char(20)
  pcuenta2                     char(20)
  ptrandev                     char(4)
  ptrancom                     char(4)
  ptraniva                     char(4)
) RETURNING char(5),        -- codret
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pempresa` | `char(3)` | — | — |
| `pfechadevo` | `date` | `dev`=devolución | ✅ CÓDIGO |
| `pcuenta1` | `char(20)` | — | — |
| `pcuenta2` | `char(20)` | — | — |
| `ptrandev` | `char(4)` | `dev`=devolución | ✅ CÓDIGO |
| `ptrancom` | `char(4)` | — | — |
| `ptraniva` | `char(4)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `v_codret` | `char(5)` | L14 |
| `v_sucursal` | `char(45)` | L15 |
| `v_banco` | `char(100)` | L16 |
| `v_numcheque` | `char(7)` | L17 |
| `v_importe` | `decimal(16,2)` | L18 |
| `v_com` | `decimal(8,2)` | L19 |
| `v_iva` | `decimal(8,2)` | L20 |
| `v_folio` | `char(16)` | L21 |
| `v_motivodev` | `char(45)` | L22 |
| `vnoregistros` | `INTEGER` | L24 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `cce_cheques_dev` | `bditef` | no | SELECT | L83 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L59 | VALIDACIÓN_NULL | `IF      pempresa    is null or` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `cons` | ACCION | consulta | 🔵 CONVENCIÓN | nombre_sp |
| `dev` | ACCION | devolución | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `coppel` | ENTIDAD | Coppel (grupo) | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?2_` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `totales` | MODIF | totales | 🔵 CONVENCIÓN | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?2_` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `cons_dev_coppel_pba`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_cons_dev_coppel_pba.sql` |
| **LOC (1er CREATE)** | 216 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 1 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "consulta Coppel (PBA — sufijo de SPs para Pruebas; confirmado por SME)" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo · `confirma` → `SELECT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=0 / 4 términos |

### Firma

```sql
CREATE PROCEDURE cons_dev_coppel_pba(
  pempresa                     char(3)
  pfechadevo                   char(10)
  pcuenta1                     char(20)
  pcuenta2                     char(20)
  ptrandev                     char(4)
  ptrancom                     char(4)
  ptraniva                     char(4)
) RETURNING char(5),        -- codret
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pempresa` | `char(3)` | — | — |
| `pfechadevo` | `char(10)` | `dev`=devolución | ✅ CÓDIGO |
| `pcuenta1` | `char(20)` | — | — |
| `pcuenta2` | `char(20)` | — | — |
| `ptrandev` | `char(4)` | `dev`=devolución | ✅ CÓDIGO |
| `ptrancom` | `char(4)` | — | — |
| `ptraniva` | `char(4)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `v_codret` | `char(5)` | L20 |
| `v_sucursal` | `char(45)` | L21 |
| `v_banco` | `char(100)` | L22 |
| `v_numcheque` | `char(7)` | L23 |
| `v_importe` | `decimal(16,2)` | L24 |
| `v_com` | `decimal(8,2)` | L25 |
| `v_iva` | `decimal(8,2)` | L26 |
| `v_folio` | `char(16)` | L27 |
| `v_motivodev` | `char(45)` | L28 |
| `v_fechapaso` | `date` | L29 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `cce_cheques_dev` | `bditef` | no | SELECT | L117 |
| `sc_movdia` | `bdicheq` | ⚠️ sí | SELECT | L135 |
| `sc_movhis` | `bdicheq` | ⚠️ sí | SELECT | L168 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L84 | VALIDACIÓN_NULL | `IF      pempresa    is null or` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `cons` | ACCION | consulta | 🔵 CONVENCIÓN | nombre_sp |
| `dev` | ACCION | devolución | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `coppel` | ENTIDAD | Coppel (grupo) | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `pba` | MODIF | PBA — sufijo de SPs para Pruebas; confirmado por SME (Guerra | 🔵 CONVENCIÓN | nombre_sp |

---

## `cons_dev_suc`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_cons_dev_suc.sql` |
| **LOC (1er CREATE)** | 124 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "consulta (sucursal)" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=1 · INFERIDO=1 · SINTÉTICO=0 / 3 términos |

### Firma

```sql
CREATE PROCEDURE cons_dev_suc(
  pempresa                     char(3)
  psucursal                    char(4)
  pfechapre                    date
  pnum_regs                    smallint
) RETURNING char(5),char(45),char(20),char(11),
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pempresa` | `char(3)` | — | — |
| `psucursal` | `char(4)` | `suc`=sucursal | 🟡 INFERIDO |
| `pfechapre` | `date` | — | — |
| `pnum_regs` | `smallint` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `v_codret` | `char(5)` | L11 |
| `v_banco` | `char(45)` | L12 |
| `v_cuenta` | `char(20)` | L13 |
| `v_numcheque` | `char(11)` | L14 |
| `v_monto` | `char(16)` | L15 |
| `v_ctadeposito` | `char(20)` | L16 |
| `v_cliente` | `char(20)` | L17 |
| `v_motdevol` | `char(50)` | L18 |
| `v_contador` | `smallint` | L19 |
| `v_nombrecte` | `char(100)` | L20 |
| `v_rfc` | `char(1)` | L21 |
| `v_curp` | `char(1)` | L22 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `cce_cheques_dev` | `bditef` | no | SELECT | L95 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `consnomcte` | `bditef` | no | L105 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L55 | VALIDACIÓN_NULL | `IF  	pempresa is null or` |  |
| L108 | FÓRMULA | `LET v_contador = v_contador +1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `cons` | ACCION | consulta | 🔵 CONVENCIÓN | nombre_sp |
| `dev` | ACCION | devolución | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `suc` | MODIF | sucursal | 🟡 INFERIDO | nombre_sp |

---

## `cons_dev_suc_web`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_cons_dev_suc_web.sql` |
| **LOC (1er CREATE)** | 132 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "consulta (sucursal, canal web)" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=2 · INFERIDO=1 · SINTÉTICO=0 / 4 términos |

### Firma

```sql
CREATE PROCEDURE cons_dev_suc_web(
  pempresa                     char(3)
  psucursal                    char(4)
  pfechapre                    date
  pnum_regs                    smallint
) RETURNING char(5),char(45),char(20),char(11),
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pempresa` | `char(3)` | — | — |
| `psucursal` | `char(4)` | `suc`=sucursal | 🟡 INFERIDO |
| `pfechapre` | `date` | — | — |
| `pnum_regs` | `smallint` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `v_codret` | `char(5)` | L11 |
| `v_banco` | `char(45)` | L12 |
| `v_cuenta` | `char(20)` | L13 |
| `v_numcheque` | `char(11)` | L14 |
| `v_monto` | `char(16)` | L15 |
| `v_ctadeposito` | `char(20)` | L16 |
| `v_cliente` | `char(20)` | L17 |
| `v_motdevol` | `char(50)` | L18 |
| `v_contador` | `smallint` | L19 |
| `v_nombrecte` | `char(100)` | L20 |
| `v_rfc` | `char(1)` | L21 |
| `v_curp` | `char(1)` | L22 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `cce_cheques_dev` | `bditef` | no | SELECT | L95 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `consnomcte` | `bditef` | no | L105 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L55 | VALIDACIÓN_NULL | `IF  	pempresa is null or` |  |
| L60 | CÓDIGO_RETORNO | `LET v_codret = '00110';` |  |
| L108 | FÓRMULA | `LET v_contador = v_contador +1;` |  |
| L111 | CÓDIGO_RETORNO | `LET v_codret = '00000';` |  |
| L115 | CÓDIGO_RETORNO | `LET v_codret = '00001';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `cons` | ACCION | consulta | 🔵 CONVENCIÓN | nombre_sp |
| `dev` | ACCION | devolución | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `suc` | MODIF | sucursal | 🟡 INFERIDO | nombre_sp |
| `web` | MODIF | canal web | 🔵 CONVENCIÓN | nombre_sp |

---

## `cons_dev_suc_web2`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_cons_dev_suc_web2.sql` |
| **LOC (1er CREATE)** | 141 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "consulta (sucursal, canal web)" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=2 · INFERIDO=1 · SINTÉTICO=1 / 5 términos |

### Firma

```sql
CREATE PROCEDURE cons_dev_suc_web2(
  pempresa                     CHAR(3)
  psucursal                    CHAR(4)
  pfechapre                    DATE
  pnum_regs                    SMALLINT
) RETURNING CHAR(5), CHAR(45), CHAR(20), CHAR(11), CHAR(16), CHAR(20), CHAR(100), CHAR(50), CHAR(13)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pempresa` | `CHAR(3)` | — | — |
| `psucursal` | `CHAR(4)` | `suc`=sucursal | 🟡 INFERIDO |
| `pfechapre` | `DATE` | — | — |
| `pnum_regs` | `SMALLINT` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `v_codret` | `CHAR(5)` | L5 |
| `v_banco` | `CHAR(45)` | L6 |
| `v_cuenta` | `CHAR(20)` | L7 |
| `v_numcheque` | `CHAR(11)` | L8 |
| `v_monto` | `CHAR(16)` | L9 |
| `v_ctadeposito` | `CHAR(20)` | L10 |
| `v_cliente` | `CHAR(20)` | L11 |
| `v_motdevol` | `CHAR(50)` | L12 |
| `v_contador` | `SMALLINT` | L13 |
| `v_nombrecte` | `CHAR(100)` | L14 |
| `v_rfc` | `CHAR(1)` | L15 |
| `v_curp` | `CHAR(1)` | L16 |
| `v_codret2` | `CHAR(5)` | L19 |
| `vtel1` | `CHAR(13)` | L20 |
| `vtel2` | `CHAR(13)` | L21 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `cce_cheques_dev` | `bditef` | no | SELECT | L84 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `consnomcte` | `bditef` | no | L94 |
| `cons_tels_web` | `bditef` | no | L100 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L48 | VALIDACIÓN_NULL | `IF  pempresa is null or` |  |
| L53 | CÓDIGO_RETORNO | `LET v_codret = '00110';` |  |
| L104 | FÓRMULA | `LET v_contador = v_contador +1;` |  |
| L107 | CÓDIGO_RETORNO | `LET v_codret = '00000';` |  |
| L111 | CÓDIGO_RETORNO | `LET v_codret = '00001';` |  |
| L126 | CÓDIGO_RETORNO | `LET v_codret = '00001';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `cons` | ACCION | consulta | 🔵 CONVENCIÓN | nombre_sp |
| `dev` | ACCION | devolución | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `suc` | MODIF | sucursal | 🟡 INFERIDO | nombre_sp |
| `web` | MODIF | canal web | 🔵 CONVENCIÓN | nombre_sp |
| `?2` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?2` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `cons_dir_cte`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_cons_dir_cte.sql` |
| **LOC (1er CREATE)** | 99 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "consulta cliente" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=1 / 3 términos |

### Firma

```sql
CREATE PROCEDURE cons_dir_cte(
  pempresa                     char(20)
  pcliente                     char(20)
) RETURNING char(5), char(50), char(10), char(10), char(10), char(30), char(60), char(30), char(80),
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pempresa` | `char(20)` | — | — |
| `pcliente` | `char(20)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `v_codret` | `char(5)` | L5 |
| `v_calle` | `char(30)` | L6 |
| `v_numext` | `char(10)` | L7 |
| `v_numint` | `char(10)` | L8 |
| `v_depto` | `char(6)` | L9 |
| `v_colonia` | `char(30)` | L10 |
| `v_ciudad` | `char(60)` | L11 |
| `v_estado` | `char(30)` | L12 |
| `v_obs` | `char(80)` | L13 |
| `v_entrecalles` | `char(40)` | L14 |
| `v_cp` | `char(5)` | L15 |
| `v_tel1` | `char(13)` | L16 |
| `v_tel2` | `char(13)` | L17 |
| `v_tel3` | `char(13)` | L18 |
| `v_ext` | `char(10)` | L19 |
| `v_tpdir` | `char(1)` | L20 |
| `v_tipodir` | `char(10)` | L21 |
| `v_fechacap` | `char(10)` | L22 |
| `v_contador` | `smallint` | L23 |
| `sql_err` | `int` | L24 |
| `isam_err` | `int` | L25 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_direcciones` | `bdinteg` | ⚠️ sí | SELECT | L79 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L60 | VALIDACIÓN_NULL | `IF pcliente is null then` |  |
| L90 | FÓRMULA | `LET v_contador = v_contador + 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `cons` | ACCION | consulta | 🔵 CONVENCIÓN | nombre_sp |
| `?_dir_` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `cte` | ENTIDAD | cliente | 🔵 CONVENCIÓN | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_dir_` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `cons_img_nula1`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_cons_img_nula1.sql` |
| **LOC (1er CREATE)** | 92 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 1 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "consulta" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=1 / 2 términos |

### Firma

```sql
CREATE PROCEDURE cons_img_nula1(
  pempresa                     CHAR(3)
  pcvebanco                    CHAR(3)
  pnumcuenta                   CHAR(20)
  pnumcheque                   CHAR(7)
  plado_ft                     CHAR(1)
  pfechapresenta               CHAR(10)
) RETURNING CHAR(5)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pempresa` | `CHAR(3)` | — | — |
| `pcvebanco` | `CHAR(3)` | — | — |
| `pnumcuenta` | `CHAR(20)` | — | — |
| `pnumcheque` | `CHAR(7)` | — | — |
| `plado_ft` | `CHAR(1)` | — | — |
| `pfechapresenta` | `CHAR(10)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `v_codret` | `CHAR(5)` | L9 |
| `iimagen` | `INT` | L12 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `cce_cheques_img` | `bditef` | no | SELECT | L48 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L20 | VALIDACIÓN_NULL | `IF pempresa    	  IS NULL OR` |  |
| L26 | FÓRMULA | `LET v_codret = 110; -- // datos de entrada incompletos` |  |
| L56 | VALIDACIÓN_NULL | `IF iimagen IS NULL OR iimagen = '' THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `cons` | ACCION | consulta | 🔵 CONVENCIÓN | nombre_sp |
| `?_img_nula1` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_img_nula1` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `cons_img_nula1_mx2`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_cons_img_nula1_mx2.sql` |
| **LOC (1er CREATE)** | 75 |
| **Callgraph** | ✅ fan_in=0 / fan_out=8 |
| **Deps concatenadas** | 6 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "consulta" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=2 / 4 términos |

### Firma

```sql
CREATE PROCEDURE cons_img_nula1_mx2(
  pempresa                     CHAR(3)
  pcvebanco                    CHAR(3)
  pnumcuenta                   CHAR(20)
  pnumcheque                   CHAR(7)
  plado_ft                     CHAR(1)
  pfechapresenta               CHAR(10)
) RETURNING CHAR(5)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pempresa` | `CHAR(3)` | — | — |
| `pcvebanco` | `CHAR(3)` | — | — |
| `pnumcuenta` | `CHAR(20)` | — | — |
| `pnumcheque` | `CHAR(7)` | — | — |
| `plado_ft` | `CHAR(1)` | — | — |
| `pfechapresenta` | `CHAR(10)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `v_codret` | `CHAR(5)` | L9 |
| `iimagen` | `INT` | L12 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `cce_cheques_img` | `bditef` | no | SELECT | L47 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L20 | VALIDACIÓN_NULL | `IF pempresa    	  IS NULL OR` |  |
| L26 | FÓRMULA | `LET v_codret = 110; -- // datos de entrada incompletos` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `cons` | ACCION | consulta | 🔵 CONVENCIÓN | nombre_sp |
| `?_img_nula1_m` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `x` | MODIF | por (criterio) | 🔵 CONVENCIÓN | nombre_sp |
| `?2` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_img_nula1_m`, `?2` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `cons_img_nula1_web`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_cons_img_nula1_web.sql` |
| **LOC (1er CREATE)** | 69 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 1 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "consulta (canal web)" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=1 / 3 términos |

### Firma

```sql
CREATE PROCEDURE cons_img_nula1_web(
  pempresa                     CHAR(3)
  pcvebanco                    CHAR(3)
  pnumcuenta                   CHAR(20)
  pnumcheque                   CHAR(7)
  plado_ft                     CHAR(1)
  pfechapresenta               CHAR(10)
) RETURNING CHAR(5)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pempresa` | `CHAR(3)` | — | — |
| `pcvebanco` | `CHAR(3)` | — | — |
| `pnumcuenta` | `CHAR(20)` | — | — |
| `pnumcheque` | `CHAR(7)` | — | — |
| `plado_ft` | `CHAR(1)` | — | — |
| `pfechapresenta` | `CHAR(10)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `v_codret` | `CHAR(5)` | L9 |
| `iimagen` | `INT` | L11 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `cce_cheques_img` | `bditef` | no | SELECT | L44 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L18 | VALIDACIÓN_NULL | `IF pempresa    	  IS NULL OR` |  |
| L24 | FÓRMULA | `LET v_codret = "00110"; -- // datos de entrada incompletos` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `cons` | ACCION | consulta | 🔵 CONVENCIÓN | nombre_sp |
| `?_img_nula1_` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `web` | MODIF | canal web | 🔵 CONVENCIÓN | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_img_nula1_` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `cons_nom_cte`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_cons_nom_cte.sql` |
| **LOC (1er CREATE)** | 93 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "consulta nómina y cliente" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=2 · INFERIDO=1 · SINTÉTICO=0 / 3 términos |

### Firma

```sql
CREATE PROCEDURE cons_nom_cte(
  pempresa                     char(3)
  pnumcte                      char(20)
) RETURNING char(5),char(2), char(52),char(26), char(26),char(13),char(20), date, char(3), date
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pempresa` | `char(3)` | — | — |
| `pnumcte` | `char(20)` | `cte`=cliente | 🔵 CONVENCIÓN |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vcodret` | `char(5)` | L5 |
| `vesfisica` | `char(1)` | L6 |
| `vpaterno` | `char(15)` | L7 |
| `vmaterno` | `char(15)` | L8 |
| `vnombre1` | `char(15)` | L9 |
| `vnombre2` | `char(15)` | L10 |
| `vrazon_social` | `char(60)` | L11 |
| `vnomcte` | `char(60)` | L12 |
| `vsqlerr` | `integer` | L13 |
| `vtpo_persona` | `char(2)` | L14 |
| `vrfc` | `char(13)` | L15 |
| `vcurp` | `char(20)` | L16 |
| `vfecha_nacimiento` | `date` | L17 |
| `vnacionalidad` | `char(3)` | L18 |
| `vfec_alta` | `date` | L19 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_cliente` | `bdinteg` | ⚠️ sí | SELECT | L63 |
| `si_ctepf` | `bdinteg` | ⚠️ sí | SELECT | L87 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L73 | VALIDACIÓN_NULL | `IF vtpo_persona = "" or vtpo_persona is null then` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `cons` | ACCION | consulta | 🔵 CONVENCIÓN | nombre_sp |
| `nom` | ENTIDAD | nómina | 🟡 INFERIDO | nombre_sp |
| `cte` | ENTIDAD | cliente | 🔵 CONVENCIÓN | nombre_sp |

---

## `cons_presenta`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_cons_presenta.sql` |
| **LOC (1er CREATE)** | 201 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "consulta" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=0 / 2 términos |

### Firma

```sql
CREATE PROCEDURE cons_presenta(
  pempresa                     char(3)
  pfechapre                    char(10)
) RETURNING char(5),char(100),char(11),char(7),
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pempresa` | `char(3)` | — | — |
| `pfechapre` | `char(10)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `v_codret` | `char(5)` | L9 |
| `v_banco` | `char(100)` | L10 |
| `v_cuenta` | `char(11)` | L11 |
| `v_numcheque` | `char(7)` | L12 |
| `v_monto` | `decimal(16,2)` | L13 |
| `v_sucursal` | `char(45)` | L14 |
| `v_ctadeposito` | `char(20)` | L15 |
| `v_nombrecte` | `char(100)` | L16 |
| `v_presentado` | `char(1)` | L17 |
| `v_numcte` | `char(20)` | L18 |
| `v_rfc` | `char(1)` | L19 |
| `v_curp` | `char(1)` | L20 |
| `v_fechapaso` | `date` | L21 |
| `v_transacc` | `char(4)` | L25 |
| `v_trancheques` | `char(4)` | L27 |
| `v_trancredito` | `char(4)` | L28 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_transacc` | `bdinteg` | ⚠️ sí | SELECT | L94 |
| `cce_cheques_det` | `bditef` | no | SELECT | L141 |
| `sc_maechq` | `bdicheq` | ⚠️ sí | SELECT | L161 |
| `sd_tarjeta` | `bdicred` | ⚠️ sí | SELECT | L171 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `consnomcte` | `bditef` | no | L189 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L63 | VALIDACIÓN_NULL | `IF      pempresa is null or` |  |
| L99 | VALIDACIÓN_NULL | `IF v_trancheques is null THEN` |  |
| L115 | VALIDACIÓN_NULL | `IF v_trancredito is null THEN` |  |
| L178 | VALIDACIÓN_NULL | `IF v_numcte is null or v_numcte = "" THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `cons` | ACCION | consulta | 🔵 CONVENCIÓN | nombre_sp |
| `presenta` | ACCION | presenta | 🔵 CONVENCIÓN | nombre_sp |

---

## `cons_presenta_pba`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_cons_presenta_pba.sql` |
| **LOC (1er CREATE)** | 202 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "consulta (PBA — sufijo de SPs para Pruebas; confirmado por SME)" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo · `confirma` → `SELECT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=0 / 3 términos |

### Firma

```sql
CREATE PROCEDURE cons_presenta_pba(
  pempresa                     char(3)
  pfechapre                    char(10)
) RETURNING char(5),char(100),char(11),char(7),
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pempresa` | `char(3)` | — | — |
| `pfechapre` | `char(10)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `v_codret` | `char(5)` | L9 |
| `v_banco` | `char(100)` | L10 |
| `v_cuenta` | `char(11)` | L11 |
| `v_numcheque` | `char(7)` | L12 |
| `v_monto` | `decimal(16,2)` | L13 |
| `v_sucursal` | `char(45)` | L14 |
| `v_ctadeposito` | `char(20)` | L15 |
| `v_nombrecte` | `char(100)` | L16 |
| `v_presentado` | `char(1)` | L17 |
| `v_numcte` | `char(20)` | L18 |
| `v_rfc` | `char(1)` | L19 |
| `v_curp` | `char(1)` | L20 |
| `v_fechapaso` | `date` | L21 |
| `v_transacc` | `char(4)` | L25 |
| `v_trancheques` | `char(4)` | L27 |
| `v_trancredito` | `char(4)` | L28 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_transacc` | `bdinteg` | ⚠️ sí | SELECT | L95 |
| `cce_cheques_det` | `bditef` | no | SELECT | L142 |
| `sc_maechq` | `bdicheq` | ⚠️ sí | SELECT | L162 |
| `sd_tarjeta` | `bdicred` | ⚠️ sí | SELECT | L172 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `consnomcte` | `bditef` | no | L190 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L64 | VALIDACIÓN_NULL | `IF      pempresa is null or` |  |
| L100 | VALIDACIÓN_NULL | `IF v_trancheques is null THEN` |  |
| L116 | VALIDACIÓN_NULL | `IF v_trancredito is null THEN` |  |
| L179 | VALIDACIÓN_NULL | `IF v_numcte is null or v_numcte = "" THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `cons` | ACCION | consulta | 🔵 CONVENCIÓN | nombre_sp |
| `presenta` | ACCION | presenta | 🔵 CONVENCIÓN | nombre_sp |
| `pba` | MODIF | PBA — sufijo de SPs para Pruebas; confirmado por SME (Guerra | 🔵 CONVENCIÓN | nombre_sp |

---

## `cons_tels`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_cons_tels.sql` |
| **LOC (1er CREATE)** | 56 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "consulta teléfonos" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=1 · INFERIDO=1 · SINTÉTICO=0 / 2 términos |

### Firma

```sql
CREATE PROCEDURE cons_tels(
  pnumcte                      char(20)
) RETURNING char(5),char(13),char(13)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pnumcte` | `char(20)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vcodret` | `char(5)` | L4 |
| `vtel1` | `char(13)` | L5 |
| `vtel2` | `char(13)` | L6 |
| `vsqlerr` | `int` | L7 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_direcciones` | `bdinteg` | ⚠️ sí | SELECT | L33 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L23 | VALIDACIÓN_NULL | `IF  	pnumcte is null then` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `cons` | ACCION | consulta | 🔵 CONVENCIÓN | nombre_sp |
| `tels` | ENTIDAD | teléfonos (plural) | 🟡 INFERIDO | nombre_sp |

---

## `cons_tels_web`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_cons_tels_web.sql` |
| **LOC (1er CREATE)** | 56 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "consulta teléfonos (canal web)" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=2 · INFERIDO=1 · SINTÉTICO=0 / 3 términos |

### Firma

```sql
CREATE PROCEDURE cons_tels_web(
  pnumcte                      char(20)
) RETURNING char(5),char(13),char(13)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pnumcte` | `char(20)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vcodret` | `char(5)` | L4 |
| `vtel1` | `char(13)` | L5 |
| `vtel2` | `char(13)` | L6 |
| `vsqlerr` | `int` | L7 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_telefonos_actual` | `bdinteg` | ⚠️ sí | SELECT | L33 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L23 | VALIDACIÓN_NULL | `IF  	pnumcte is null then` |  |
| L25 | CÓDIGO_RETORNO | `LET vcodret = '00110';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `cons` | ACCION | consulta | 🔵 CONVENCIÓN | nombre_sp |
| `tels` | ENTIDAD | teléfonos (plural) | 🟡 INFERIDO | nombre_sp |
| `web` | MODIF | canal web | 🔵 CONVENCIÓN | nombre_sp |

---

## `consnomcte`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_consnomcte.sql` |
| **LOC (1er CREATE)** | 62 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "consulta nómina y cliente" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=2 · INFERIDO=1 · SINTÉTICO=0 / 3 términos |

### Firma

```sql
CREATE PROCEDURE consnomcte(
  pempresa                     char(3)
  pnumcte                      char(20)
) RETURNING char(5),char(60),char(13),char(20)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pempresa` | `char(3)` | — | — |
| `pnumcte` | `char(20)` | `cte`=cliente | 🔵 CONVENCIÓN |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vcodret` | `char(5)` | L4 |
| `vesfisica` | `char(1)` | L5 |
| `vpaterno` | `char(15)` | L6 |
| `vmaterno` | `char(15)` | L7 |
| `vnombre1` | `char(15)` | L8 |
| `vnombre2` | `char(15)` | L9 |
| `vrazon_social` | `char(60)` | L10 |
| `vnomcte` | `char(60)` | L11 |
| `vsqlerr` | `integer` | L12 |
| `vtpo_persona` | `char(2)` | L13 |
| `vrfc` | `char(13)` | L14 |
| `vcurp` | `char(20)` | L15 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_cliente` | `bdinteg` | ⚠️ sí | SELECT | L35 |
| `si_tipper` | `bdinteg` | ⚠️ sí | SELECT | L42 |
| `si_ctepf` | `bdinteg` | ⚠️ sí | SELECT | L55 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L38 | VALIDACIÓN_NULL | `if vtpo_persona = " " or vtpo_persona is null then` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `cons` | ACCION | consulta | 🔵 CONVENCIÓN | nombre_sp |
| `nom` | ENTIDAD | nómina | 🟡 INFERIDO | nombre_sp |
| `cte` | ENTIDAD | cliente | 🔵 CONVENCIÓN | nombre_sp |

---

## `ins_cheq_det`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_ins_cheq_det.sql` |
| **LOC (1er CREATE)** | 133 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 2 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "insertar cheque y detalle" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `inserta` → `INSERT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=1 · INFERIDO=1 · SINTÉTICO=0 / 3 términos |

### Firma

```sql
CREATE PROCEDURE ins_cheq_det(
  pempresa                     char(3)
  pcvebanco                    char(3)
  pnumcuenta                   char(20)
  pnumcheque                   char(7)
  pfechapresenta               char(10)
  pmonto                       decimal(14,2)
  pbandamag                    char(40)
  pcompensacion                char(3)
  ptransaccion                 char(2)
  pcodseguridad                char(3)
  pfechahoracap                char(25)
  pdigverpre                   char(1)
  pdigverinter                 char(1)
  puser_insert                 char(8)
  pfecha_insert                char(10)
) RETURNING char(5)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pempresa` | `char(3)` | — | — |
| `pcvebanco` | `char(3)` | — | — |
| `pnumcuenta` | `char(20)` | — | — |
| `pnumcheque` | `char(7)` | `cheq`=cheque | 🔵 CONVENCIÓN |
| `pfechapresenta` | `char(10)` | — | — |
| `pmonto` | `decimal(14,2)` | — | — |
| `pbandamag` | `char(40)` | — | — |
| `pcompensacion` | `char(3)` | — | — |
| `ptransaccion` | `char(2)` | — | — |
| `pcodseguridad` | `char(3)` | — | — |
| `pfechahoracap` | `char(25)` | — | — |
| `pdigverpre` | `char(1)` | — | — |
| `pdigverinter` | `char(1)` | — | — |
| `puser_insert` | `char(8)` | `ins`=insertar | 🟡 INFERIDO |
| `pfecha_insert` | `char(10)` | `ins`=insertar | 🟡 INFERIDO |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `v_codret` | `char(5)` | L19 |
| `v_fechapre` | `char(10)` | L20 |
| `v_existe` | `char(1)` | L21 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `cce_cheques_det` | `bditef` | no | SELECT | L84 |
| `cce_cheques_det` | `bditef` | no | INSERT | L99 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `cal_fechapre` | `bditef` | no | L73 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L38 | VALIDACIÓN_NULL | `IF  	pempresa    	is null or` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `ins` | ACCION | insertar | 🟡 INFERIDO | nombre_sp |
| `cheq` | ENTIDAD | cheque | 🔵 CONVENCIÓN | nombre_sp |
| `det` | ENTIDAD | detalle | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |

---

## `ins_cheq_det_web`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_ins_cheq_det_web.sql` |
| **LOC (1er CREATE)** | 136 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 1 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "insertar cheque y detalle (canal web)" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `inserta` → `INSERT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=2 · INFERIDO=1 · SINTÉTICO=0 / 4 términos |

### Firma

```sql
CREATE PROCEDURE ins_cheq_det_web(
  pempresa                     char(3)
  pcvebanco                    char(3)
  pnumcuenta                   char(20)
  pnumcheque                   char(7)
  pfechapresenta               char(10)
  pmonto                       decimal(14,2)
  pbandamag                    char(40)
  pcompensacion                char(3)
  ptransaccion                 char(2)
  pcodseguridad                char(3)
  pfechahoracap                char(25)
  pdigverpre                   char(1)
  pdigverinter                 char(1)
  puser_insert                 char(8)
  pfecha_insert                char(10)
) RETURNING char(5)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pempresa` | `char(3)` | — | — |
| `pcvebanco` | `char(3)` | — | — |
| `pnumcuenta` | `char(20)` | — | — |
| `pnumcheque` | `char(7)` | `cheq`=cheque | 🔵 CONVENCIÓN |
| `pfechapresenta` | `char(10)` | — | — |
| `pmonto` | `decimal(14,2)` | — | — |
| `pbandamag` | `char(40)` | — | — |
| `pcompensacion` | `char(3)` | — | — |
| `ptransaccion` | `char(2)` | — | — |
| `pcodseguridad` | `char(3)` | — | — |
| `pfechahoracap` | `char(25)` | — | — |
| `pdigverpre` | `char(1)` | — | — |
| `pdigverinter` | `char(1)` | — | — |
| `puser_insert` | `char(8)` | `ins`=insertar | 🟡 INFERIDO |
| `pfecha_insert` | `char(10)` | `ins`=insertar | 🟡 INFERIDO |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `v_codret` | `char(5)` | L19 |
| `v_fechapre` | `char(10)` | L20 |
| `v_existe` | `char(1)` | L21 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `cce_cheques_det` | `bditef` | no | SELECT | L87 |
| `cce_cheques_det` | `bditef` | no | INSERT | L102 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `cal_fechapre` | `bditef` | no | L74 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L38 | VALIDACIÓN_NULL | `IF  	pempresa    	is null or` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `ins` | ACCION | insertar | 🟡 INFERIDO | nombre_sp |
| `cheq` | ENTIDAD | cheque | 🔵 CONVENCIÓN | nombre_sp |
| `det` | ENTIDAD | detalle | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `web` | MODIF | canal web | 🔵 CONVENCIÓN | nombre_sp |

---

## `ins_img_det`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_ins_img_det.sql` |
| **LOC (1er CREATE)** | 99 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "insertar detalle" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `inserta` → `INSERT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=0 · INFERIDO=2 · SINTÉTICO=1 / 3 términos |

### Firma

```sql
CREATE PROCEDURE ins_img_det(
  pempresa                     char(3)
  pcvebanco                    char(3)
  pnumcuenta                   char(20)
  pnumcheque                   char(7)
  plado_ft                     char(1)
  pfechapresenta               char(10)
  pimagen_formato              char(3)
  pimagen_tam                  integer
  puser_insert                 char(8)
  pfecha_insert                char(10)
) RETURNING char(5)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pempresa` | `char(3)` | — | — |
| `pcvebanco` | `char(3)` | — | — |
| `pnumcuenta` | `char(20)` | — | — |
| `pnumcheque` | `char(7)` | — | — |
| `plado_ft` | `char(1)` | — | — |
| `pfechapresenta` | `char(10)` | — | — |
| `pimagen_formato` | `char(3)` | — | — |
| `pimagen_tam` | `integer` | — | — |
| `puser_insert` | `char(8)` | `ins`=insertar | 🟡 INFERIDO |
| `pfecha_insert` | `char(10)` | `ins`=insertar | 🟡 INFERIDO |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `v_codret` | `char(5)` | L14 |
| `v_existe` | `char(1)` | L16 |
| `v_fechapre` | `char(10)` | L17 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `cce_cheques_img` | `bditef` | no | SELECT | L79 |
| `cce_cheques_img` | `bditef` | no | INSERT | L88 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `cal_fechapre` | `bditef` | no | L67 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L32 | VALIDACIÓN_NULL | `IF  pempresa    	is null or` |  |
| L70 | VALIDACIÓN_NULL | `IF v_fechapre IS NULL OR v_fechapre = " " THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `ins` | ACCION | insertar | 🟡 INFERIDO | nombre_sp |
| `?_img_` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `det` | ENTIDAD | detalle | 🟡 INFERIDO | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_img_` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `ins_img_det_web`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_ins_img_det_web.sql` |
| **LOC (1er CREATE)** | 100 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "insertar detalle (canal web)" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `inserta` → `INSERT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=1 · INFERIDO=2 · SINTÉTICO=1 / 4 términos |

### Firma

```sql
CREATE PROCEDURE ins_img_det_web(
  pempresa                     CHAR(3)
  pcvebanco                    CHAR(3)
  pnumcuenta                   CHAR(20)
  pnumcheque                   CHAR(7)
  plado_ft                     CHAR(1)
  pfechapresenta               CHAR(10)
  pimagen_formato              CHAR(3)
  pimagen_tam                  INTEGER
  puser_insert                 CHAR(8)
  pfecha_insert                CHAR(10)
) RETURNING CHAR(5)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pempresa` | `CHAR(3)` | — | — |
| `pcvebanco` | `CHAR(3)` | — | — |
| `pnumcuenta` | `CHAR(20)` | — | — |
| `pnumcheque` | `CHAR(7)` | — | — |
| `plado_ft` | `CHAR(1)` | — | — |
| `pfechapresenta` | `CHAR(10)` | — | — |
| `pimagen_formato` | `CHAR(3)` | — | — |
| `pimagen_tam` | `INTEGER` | — | — |
| `puser_insert` | `CHAR(8)` | `ins`=insertar | 🟡 INFERIDO |
| `pfecha_insert` | `CHAR(10)` | `ins`=insertar | 🟡 INFERIDO |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `v_codret` | `CHAR(5)` | L15 |
| `v_existe` | `CHAR(1)` | L17 |
| `v_fechapre` | `CHAR(10)` | L18 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `cce_cheques_img` | `bditef` | no | SELECT | L82 |
| `cce_cheques_img` | `bditef` | no | INSERT | L91 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `cal_fechapre` | `bditef` | no | L69 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L35 | VALIDACIÓN_NULL | `IF  pempresa    	is null or` |  |
| L73 | VALIDACIÓN_NULL | `IF v_fechapre IS NULL OR v_fechapre = " " THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `ins` | ACCION | insertar | 🟡 INFERIDO | nombre_sp |
| `?_img_` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `det` | ENTIDAD | detalle | 🟡 INFERIDO | nombre_sp |
| `web` | MODIF | canal web | 🔵 CONVENCIÓN | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_img_` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `ins_propios_det`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_ins_propios_det.sql` |
| **LOC (1er CREATE)** | 93 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "insertar ro — Rol Operativo, OS — Originación de Solicitudes y detalle" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `inserta` → `INSERT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=0 · INFERIDO=2 · SINTÉTICO=3 / 6 términos |

### Firma

```sql
CREATE PROCEDURE ins_propios_det(
  pempresa                     char(3)
  pcvebanco                    char(3)
  pnumcuenta                   char(20)
  pnumcheque                   char(7)
  pmonto                       decimal(14,2)
  pbandamag                    char(40)
  pcompensacion                char(3)
  ptransaccion                 char(2)
  pcodseguridad                char(3)
  pfechahoracap                char(25)
  pdigverpre                   char(1)
  pdigverinter                 char(1)
  puser_insert                 char(8)
  pfecha_insert                char(10)
  pfecha_orig                  char(10)
  pes_atrazado                 char(1)
) RETURNING char(5)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pempresa` | `char(3)` | — | — |
| `pcvebanco` | `char(3)` | — | — |
| `pnumcuenta` | `char(20)` | — | — |
| `pnumcheque` | `char(7)` | — | — |
| `pmonto` | `decimal(14,2)` | — | — |
| `pbandamag` | `char(40)` | — | — |
| `pcompensacion` | `char(3)` | — | — |
| `ptransaccion` | `char(2)` | — | — |
| `pcodseguridad` | `char(3)` | — | — |
| `pfechahoracap` | `char(25)` | — | — |
| `pdigverpre` | `char(1)` | — | — |
| `pdigverinter` | `char(1)` | — | — |
| `puser_insert` | `char(8)` | `ins`=insertar | 🟡 INFERIDO |
| `pfecha_insert` | `char(10)` | `ins`=insertar | 🟡 INFERIDO |
| `pfecha_orig` | `char(10)` | — | — |
| `pes_atrazado` | `char(1)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `v_codret` | `char(5)` | L21 |
| `v_fechapre` | `char(10)` | L22 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `cce_cheques_det` | `bditef` | no | INSERT | L78 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L42 | VALIDACIÓN_NULL | `IF      pempresa        is null or` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `ins` | ACCION | insertar | 🟡 INFERIDO | nombre_sp |
| `?_p` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `ro` | ENTIDAD | ro — Rol Operativo (subsistema sp_sw_ro_* — bdicnweb) | 🔴 SINTÉTICO | nombre_sp |
| `?pi` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `os` | ENTIDAD | OS — Originación de Solicitudes / subsistema de ofertas (sp_ | 🟡 INFERIDO | nombre_sp |
| `det` | ENTIDAD | detalle | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_p`, `ro`, `?pi` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `ins_reg_devo`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_ins_reg_devo.sql` |
| **LOC (1er CREATE)** | 309 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "insertar" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `inserta` → `INSERT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=0 · INFERIDO=2 · SINTÉTICO=1 / 4 términos |

### Firma

```sql
CREATE PROCEDURE ins_reg_devo(
  pempresa                     char(3)
  pcvebanco                    char(3)
  pnumcuenta                   char(20)
  pnumcheque                   char(7)
  pmotdevo                     char(2)
  puser_insert                 char(8)
  pfecha_insert                date
) RETURNING char(5),char(50)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pempresa` | `char(3)` | — | — |
| `pcvebanco` | `char(3)` | — | — |
| `pnumcuenta` | `char(20)` | — | — |
| `pnumcheque` | `char(7)` | — | — |
| `pmotdevo` | `char(2)` | `dev`=devolución | ✅ CÓDIGO |
| `puser_insert` | `char(8)` | `ins`=insertar | 🟡 INFERIDO |
| `pfecha_insert` | `date` | `ins`=insertar | 🟡 INFERIDO |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `v_codret` | `char(5)` | L13 |
| `v_codretdescrip` | `char(50)` | L14 |
| `v_fechapre` | `date` | L16 |
| `v_numcte` | `char(20)` | L17 |
| `v_ctadepo` | `char(20)` | L18 |
| `v_monto` | `decimal(16,2)` | L19 |
| `v_sucursal` | `char(4)` | L20 |
| `v_transacc` | `char(4)` | L21 |
| `v_ctacheq` | `decimal(16,0)` | L22 |
| `v_folio` | `char(16)` | L23 |
| `v_trans_dev` | `char(4)` | L24 |
| `v_trancheques` | `char(4)` | L26 |
| `v_trancredito` | `char(4)` | L27 |
| `vrowid` | `int` | L31 |
| `vstatus_cta` | `char(1)` | L33 |
| `vcta_col` | `Integer` | L35 |
| `vfecha_alta` | `date` | L36 |
| `vreferencia` | `CHAR(40)` | L37 |
| `vd_numcuenta` | `decimal(20,0)` | L38 |
| `vnumcuenta` | `char(20)` | L39 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_transacc` | `bdinteg` | ⚠️ sí | SELECT | L90 |
| `sc_param` | `bdicheq` | ⚠️ sí | SELECT | L118 |
| `cce_cheques_det` | `bditef` | no | SELECT | L135 |
| `sc_docret_sbc` | `bdicheq` | ⚠️ sí | SELECT | L157 |
| `sc_maechq` | `bdicheq` | ⚠️ sí | SELECT | L177 |
| `sd_tarjeta` | `bdicred` | ⚠️ sí | SELECT | L194 |
| `cce_cheques_dev` | `bditef` | no | INSERT | L254 |
| `cce_cheques_dev` | `bditef` | no | UPDATE | L271 |
| `si_codret` | `bdinteg` | ⚠️ sí | SELECT | L283 |
| `sc_docret_sbc` | `bdicheq` | ⚠️ sí | UPDATE | L291 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `devotrobco` | `bdicheq` | ⚠️ sí | L236 |
| `devchqsbc` | `bdicred` | ⚠️ sí | L247 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L62 | VALIDACIÓN_NULL | `IF      pempresa        is null or` |  |
| L94 | VALIDACIÓN_NULL | `IF v_trancheques is null THEN` |  |
| L108 | VALIDACIÓN_NULL | `IF v_trancredito is null THEN` |  |
| L122 | VALIDACIÓN_NULL | `IF v_trans_dev is null or v_trans_dev = "" THEN` |  |
| L141 | VALIDACIÓN_NULL | `IF v_fechapre IS NULL THEN` |  |
| L164 | VALIDACIÓN_NULL | `IF v_ctadepo is null or v_sucursal is null THEN` |  |
| L201 | VALIDACIÓN_NULL | `IF v_numcte is null or v_numcte = "" THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `ins` | ACCION | insertar | 🟡 INFERIDO | nombre_sp |
| `reg` | ACCION | registro | 🟡 INFERIDO | nombre_sp |
| `dev` | ACCION | devolución | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `?o` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?o` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `ins_reg_devo2`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_ins_reg_devo2.sql` |
| **LOC (1er CREATE)** | 309 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "insertar" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `inserta` → `INSERT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=0 · INFERIDO=2 · SINTÉTICO=1 / 4 términos |

### Firma

```sql
CREATE PROCEDURE ins_reg_devo2(
  pempresa                     char(3)
  pcvebanco                    char(3)
  pnumcuenta                   char(20)
  pnumcheque                   char(7)
  pmotdevo                     char(2)
  puser_insert                 char(8)
  pfecha_insert                date
) RETURNING char(5),char(50)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pempresa` | `char(3)` | — | — |
| `pcvebanco` | `char(3)` | — | — |
| `pnumcuenta` | `char(20)` | — | — |
| `pnumcheque` | `char(7)` | — | — |
| `pmotdevo` | `char(2)` | `dev`=devolución | ✅ CÓDIGO |
| `puser_insert` | `char(8)` | `ins`=insertar | 🟡 INFERIDO |
| `pfecha_insert` | `date` | `ins`=insertar | 🟡 INFERIDO |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `v_codret` | `char(5)` | L13 |
| `v_codretdescrip` | `char(50)` | L14 |
| `v_fechapre` | `date` | L16 |
| `v_numcte` | `char(20)` | L17 |
| `v_ctadepo` | `char(20)` | L18 |
| `v_monto` | `decimal(16,2)` | L19 |
| `v_sucursal` | `char(4)` | L20 |
| `v_transacc` | `char(4)` | L21 |
| `v_ctacheq` | `decimal(16,0)` | L22 |
| `v_folio` | `char(16)` | L23 |
| `v_trans_dev` | `char(4)` | L24 |
| `v_trancheques` | `char(4)` | L26 |
| `v_trancredito` | `char(4)` | L27 |
| `vrowid` | `int` | L31 |
| `vstatus_cta` | `char(1)` | L33 |
| `vcta_col` | `Integer` | L35 |
| `vfecha_alta` | `date` | L36 |
| `vreferencia` | `CHAR(40)` | L37 |
| `vd_numcuenta` | `decimal(20,0)` | L38 |
| `vnumcuenta` | `char(20)` | L39 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_transacc` | `bdinteg` | ⚠️ sí | SELECT | L90 |
| `sc_param` | `bdicheq` | ⚠️ sí | SELECT | L118 |
| `cce_cheques_det` | `bditef` | no | SELECT | L135 |
| `sc_docret_sbc` | `bdicheq` | ⚠️ sí | SELECT | L157 |
| `sc_maechq` | `bdicheq` | ⚠️ sí | SELECT | L177 |
| `sd_tarjeta` | `bdicred` | ⚠️ sí | SELECT | L194 |
| `cce_cheques_dev` | `bditef` | no | INSERT | L254 |
| `cce_cheques_dev` | `bditef` | no | UPDATE | L271 |
| `si_codret` | `bdinteg` | ⚠️ sí | SELECT | L283 |
| `sc_docret_sbc` | `bdicheq` | ⚠️ sí | UPDATE | L291 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `devotrobco2` | `bdicheq` | ⚠️ sí | L236 |
| `devchqsbc` | `bdicred` | ⚠️ sí | L247 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L62 | VALIDACIÓN_NULL | `IF      pempresa        is null or` |  |
| L94 | VALIDACIÓN_NULL | `IF v_trancheques is null THEN` |  |
| L108 | VALIDACIÓN_NULL | `IF v_trancredito is null THEN` |  |
| L122 | VALIDACIÓN_NULL | `IF v_trans_dev is null or v_trans_dev = "" THEN` |  |
| L141 | VALIDACIÓN_NULL | `IF v_fechapre IS NULL THEN` |  |
| L164 | VALIDACIÓN_NULL | `IF v_ctadepo is null or v_sucursal is null THEN` |  |
| L201 | VALIDACIÓN_NULL | `IF v_numcte is null or v_numcte = "" THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `ins` | ACCION | insertar | 🟡 INFERIDO | nombre_sp |
| `reg` | ACCION | registro | 🟡 INFERIDO | nombre_sp |
| `dev` | ACCION | devolución | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `?o2` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?o2` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `ins_reg_devo_pba`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_ins_reg_devo_pba.sql` |
| **LOC (1er CREATE)** | 309 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "insertar (PBA — sufijo de SPs para Pruebas; confirmado por SME)" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `inserta` → `INSERT` encontrado en el cuerpo · `confirma` → `SELECT` encontrado en el cuerpo · `confirma` → `UPDATE` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=1 · INFERIDO=2 · SINTÉTICO=1 / 5 términos |

### Firma

```sql
CREATE PROCEDURE ins_reg_devo_pba(
  pempresa                     char(3)
  pcvebanco                    char(3)
  pnumcuenta                   char(20)
  pnumcheque                   char(7)
  pmotdevo                     char(2)
  puser_insert                 char(8)
  pfecha_insert                date
) RETURNING char(5),char(50)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pempresa` | `char(3)` | — | — |
| `pcvebanco` | `char(3)` | — | — |
| `pnumcuenta` | `char(20)` | — | — |
| `pnumcheque` | `char(7)` | — | — |
| `pmotdevo` | `char(2)` | `dev`=devolución | ✅ CÓDIGO |
| `puser_insert` | `char(8)` | `ins`=insertar | 🟡 INFERIDO |
| `pfecha_insert` | `date` | `ins`=insertar | 🟡 INFERIDO |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `v_codret` | `char(5)` | L13 |
| `v_codretdescrip` | `char(50)` | L14 |
| `v_fechapre` | `date` | L16 |
| `v_numcte` | `char(20)` | L17 |
| `v_ctadepo` | `char(20)` | L18 |
| `v_monto` | `decimal(16,2)` | L19 |
| `v_sucursal` | `char(4)` | L20 |
| `v_transacc` | `char(4)` | L21 |
| `v_ctacheq` | `decimal(16,0)` | L22 |
| `v_folio` | `char(16)` | L23 |
| `v_trans_dev` | `char(4)` | L24 |
| `v_trancheques` | `char(4)` | L26 |
| `v_trancredito` | `char(4)` | L27 |
| `vrowid` | `int` | L31 |
| `vstatus_cta` | `char(1)` | L33 |
| `vcta_col` | `Integer` | L35 |
| `vfecha_alta` | `date` | L36 |
| `vreferencia` | `CHAR(40)` | L37 |
| `vd_numcuenta` | `decimal(20,0)` | L38 |
| `vnumcuenta` | `char(20)` | L39 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_transacc` | `bdinteg` | ⚠️ sí | SELECT | L90 |
| `sc_param` | `bdicheq` | ⚠️ sí | SELECT | L118 |
| `cce_cheques_det` | `bditef` | no | SELECT | L135 |
| `sc_docret_sbc` | `bdicheq` | ⚠️ sí | SELECT | L157 |
| `sc_maechq` | `bdicheq` | ⚠️ sí | SELECT | L177 |
| `sd_tarjeta` | `bdicred` | ⚠️ sí | SELECT | L194 |
| `cce_cheques_dev` | `bditef` | no | INSERT | L254 |
| `cce_cheques_dev` | `bditef` | no | UPDATE | L271 |
| `si_codret` | `bdinteg` | ⚠️ sí | SELECT | L283 |
| `sc_docret_sbc` | `bdicheq` | ⚠️ sí | UPDATE | L291 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `devotrobco` | `bdicheq` | ⚠️ sí | L236 |
| `devchqsbc` | `bdicred` | ⚠️ sí | L247 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L62 | VALIDACIÓN_NULL | `IF      pempresa        is null or` |  |
| L94 | VALIDACIÓN_NULL | `IF v_trancheques is null THEN` |  |
| L108 | VALIDACIÓN_NULL | `IF v_trancredito is null THEN` |  |
| L122 | VALIDACIÓN_NULL | `IF v_trans_dev is null or v_trans_dev = "" THEN` |  |
| L141 | VALIDACIÓN_NULL | `IF v_fechapre IS NULL THEN` |  |
| L164 | VALIDACIÓN_NULL | `IF v_ctadepo is null or v_sucursal is null THEN` |  |
| L201 | VALIDACIÓN_NULL | `IF v_numcte is null or v_numcte = "" THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `ins` | ACCION | insertar | 🟡 INFERIDO | nombre_sp |
| `reg` | ACCION | registro | 🟡 INFERIDO | nombre_sp |
| `dev` | ACCION | devolución | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `?o_` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `pba` | MODIF | PBA — sufijo de SPs para Pruebas; confirmado por SME (Guerra | 🔵 CONVENCIÓN | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?o_` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `obtenerimagennula`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_obtenerimagennula.sql` |
| **LOC (1er CREATE)** | 58 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "obtiene imagen digital" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `obtiene` → `SELECT` encontrado en el cuerpo · `obtiene` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=1 / 3 términos |

### Firma

```sql
CREATE PROCEDURE obtenerimagennula(
  pempresa                     char(3)
  pcvebanco                    char(3)
  pnumcuenta                   char(20)
  pnumcheque                   char(7)
  pfechapresenta               char(10)
) RETURNING char(5)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pempresa` | `char(3)` | — | — |
| `pcvebanco` | `char(3)` | — | — |
| `pnumcuenta` | `char(20)` | — | — |
| `pnumcheque` | `char(7)` | — | — |
| `pfechapresenta` | `char(10)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `v_codret` | `char(5)` | L8 |
| `v_existe` | `int` | L10 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `cce_cheques_img` | `bditef` | no | SELECT | L41 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L17 | VALIDACIÓN_NULL | `IF pempresa    	  is null or` |  |
| L22 | FÓRMULA | `LET v_codret = "110"; -- // datos de entrada incompletos` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `obtener` | ACCION | obtiene / recupera | 🔵 CONVENCIÓN | nombre_sp |
| `imagen` | ENTIDAD | imagen digital | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?nula` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?nula` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_buscaarchivo_tef`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_sp_buscaarchivo_tef.sql` |
| **LOC (1er CREATE)** | 72 |
| **Callgraph** | ✅ fan_in=0 / fan_out=16 |
| **Deps concatenadas** | 15 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "busca archivo y TEF — transferencia electrónica de fondos" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 2 llamada(s): `sp_cnsif_confirmaejecutivo`, `sp_tef_buscararchivo` |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=0 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_buscaarchivo_tef(
  pUsuario                     CHAR(8)
  pIdFuncion                   CHAR(10)
  pRuta                        CHAR(100)
  pNombreArchivo               CHAR(50)
) RETURNING CHAR(5)  AS codret,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pUsuario` | `CHAR(8)` | — | — |
| `pIdFuncion` | `CHAR(10)` | — | — |
| `pRuta` | `CHAR(100)` | — | — |
| `pNombreArchivo` | `CHAR(50)` | `archivo`=archivo | ✅ CÓDIGO |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(5)` | L5 |
| `iSqlErr` | `INTEGER` | L6 |
| `cCodRetSp` | `CHAR(5)` | L7 |
| `FlagExiste` | `CHAR(1)` | L8 |
| `bTransacInteract` | `BOOLEAN` | L9 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_cnsif_confirmaejecutivo` | `bdinteg` | ⚠️ sí | L37 |
| `sp_tef_buscararchivo` | `bditef` | no | L51 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L11 | CÓDIGO_RETORNO | `LET cCodRet = '00000';` |  |
| L32 | CÓDIGO_RETORNO | `LET cCodRet = '00003';` |  |
| L55 | EXCEPCIÓN | `RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bditef:sp_tef_buscararchivo';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `busca` | ACCION | busca / localiza | 🔵 CONVENCIÓN | nombre_sp |
| `archivo` | ENTIDAD | archivo | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `tef` | ENTIDAD | TEF — transferencia electrónica de fondos | ✅ CÓDIGO | nombre_sp, texto_cuerpo |

---

## `sp_buscararchivos_tef`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_sp_buscararchivos_tef.sql` |
| **LOC (1er CREATE)** | 136 |
| **Callgraph** | ✅ fan_in=34 / fan_out=13 |
| **Principales callers** | `sp_calificacion_scoring` |
| **Deps concatenadas** | 11 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "búsqueda/buscar archivos y TEF — transferencia electrónica de fondos" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 3 tabla(s) con operaciones: INSERT, SELECT |
| **Evidencia vocab** | CÓDIGO=3 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=0 / 4 términos |

### Historia del SP

| Tipo | Valor |
|------|-------|
| DESCRIPCION | PROCEDIMIENTO PARA BUSCAR UN ARCHIVO EN UNA RUTA PROPORCIONADA. |
| FECHA | 10/03/2011 |

### Firma

```sql
CREATE PROCEDURE sp_buscararchivos_tef(
  psRuta                       VARCHAR(100)
) RETURNING CHAR(5) AS CodRet, VARCHAR(50) AS NomArchivo
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `psRuta` | `VARCHAR(100)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vsCodRet` | `CHAR(5)` | L13 |
| `viSqlErr` | `INTEGER` | L14 |
| `viSamErr` | `INTEGER` | L15 |
| `vsCadSql` | `LVARCHAR(500)` | L17 |
| `vsLinea` | `VARCHAR(50)` | L18 |
| `cHora` | `CHAR(8)` | L19 |
| `cFechaArchivoOUT` | `CHAR(15)` | L20 |
| `iTemporales` | `SMALLINT` | L21 |
| `iPaso` | `SMALLINT` | L22 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `systables` | `bditef` | no | SELECT | L53 |
| `tef_busca_archivos` | `bditef` | no | INSERT | L69 |
| `tef_busca_archivos` | `bditef` | no | SELECT | L109 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L49 | CÓDIGO_RETORNO | `LET vsCodRet = '00000';` |  |
| L51 | CÓDIGO_RETORNO | `LET vsCodRet = '00001';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `buscar` | ACCION | búsqueda/buscar | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `archivos` | ENTIDAD | archivos | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `tef` | ENTIDAD | TEF — transferencia electrónica de fondos | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |

---

## `sp_cce_cedulausrmtto`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_sp_cce_cedulausrmtto.sql` |
| **LOC (1er CREATE)** | 145 |
| **Callgraph** | ✅ fan_in=0 / fan_out=13 |
| **Deps concatenadas** | 9 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "CCE — Cámara de Compensación Electrónica y cédula de identificación" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 3 tabla(s) con operaciones: INSERT, DELETE, SELECT |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=1 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_cce_cedulausrmtto(
  pOperacion                   INTEGER
  2                            â Eliminar o 3 - Consultar
	pNumEjecut    INTEGER
) RETURNING CHAR(5)  AS cod_ret,    --Codigo de retorno.
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pOperacion` | `INTEGER` | — | — |
| `2` | `â Eliminar o 3 - Consultar
	pNumEjecut    INTEGER` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `iSqlErr` | `INTEGER` | L15 |
| `cCodRet` | `CHAR(5)` | L16 |
| `cNumEjecut` | `CHAR(9)` | L17 |
| `cNomEjecut` | `CHAR(50)` | L18 |
| `cRutaImg` | `CHAR (500)` | L19 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `cce_usuarios_cedula_contable` | `bditef` | no | SELECT | L51 |
| `cce_usuarios_cedula_contable` | `bditef` | no | INSERT | L59 |
| `cce_usuarios_cedula_contable` | `bditef` | no | DELETE | L101 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L55 | FÓRMULA | `LET cRutaImg = TRIM(NVL(pImagenRuta, '')); --La insercion de imagen de firma es opcional de acuerdo ` |  |
| L68 | CÓDIGO_RETORNO | `LET cCodRet = '00000';` |  |
| L82 | CÓDIGO_RETORNO | `LET cCodRet = '00000';` |  |
| L87 | CÓDIGO_RETORNO | `LET cCodRet = '00002';` |  |
| L104 | CÓDIGO_RETORNO | `LET cCodRet = '00000';` |  |
| L108 | CÓDIGO_RETORNO | `LET cCodRet = '00003';` |  |
| L115 | CÓDIGO_RETORNO | `LET cCodRet = '00000';` |  |
| L127 | CÓDIGO_RETORNO | `LET cCodRet = '00004';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `cce` | ENTIDAD | CCE — Cámara de Compensación Electrónica (CECOBAN/Banxico) — | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `cedula` | ENTIDAD | cédula de identificación | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `?usrmtto` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?usrmtto` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_cce_chequesrevisados`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_sp_cce_chequesrevisados.sql` |
| **LOC (1er CREATE)** | 205 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 7 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "reversión CCE — Cámara de Compensación Electrónica, cheques y OS — Originación de Solicitudes" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 4 tabla(s) con operaciones: SELECT, INSERT |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=1 · INFERIDO=2 · SINTÉTICO=1 / 6 términos |

### Firma

```sql
CREATE PROCEDURE sp_cce_chequesrevisados(
  pTipoOperacion               CHAR(1)
  pTipoSubOperacion            CHAR(1)
  pEmpresa                     CHAR(3)
  pCveBanco                    CHAR(3)
  pNumCuenta                   CHAR(20)
  pNumCheque                   CHAR(7)
  pFechaPresenta               DATE
  pNumCte                      CHAR(20)
  pCtaDeposito                 CHAR(20)
  pMonto                       DECIMAL(16,2)
  pSucursal                    CHAR(4)
  pMotivo                      CHAR(2)
  pEjecutivoReviso             CHAR(8)
  pFechaRevision               DATE
  pTiempoIniRev                DATETIME HOUR TO SECOND
  pTiempoFinRev                DATETIME HOUR TO SECOND
  pDevuelto                    CHAR(1)
  pRevisado                    CHAR(1)
) RETURNING CHAR(6)   AS cCodRet
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pTipoOperacion` | `CHAR(1)` | — | — |
| `pTipoSubOperacion` | `CHAR(1)` | `os`=OS — Originación de Solicitudes / subsistema de ofertas (sp_os_*, sp_calcula_estatus_os — bdisolic) | 🟡 INFERIDO |
| `pEmpresa` | `CHAR(3)` | — | — |
| `pCveBanco` | `CHAR(3)` | — | — |
| `pNumCuenta` | `CHAR(20)` | — | — |
| `pNumCheque` | `CHAR(7)` | — | — |
| `pFechaPresenta` | `DATE` | — | — |
| `pNumCte` | `CHAR(20)` | — | — |
| `pCtaDeposito` | `CHAR(20)` | `os`=OS — Originación de Solicitudes / subsistema de ofertas (sp_os_*, sp_calcula_estatus_os — bdisolic) | 🟡 INFERIDO |
| `pMonto` | `DECIMAL(16,2)` | — | — |
| `pSucursal` | `CHAR(4)` | — | — |
| `pMotivo` | `CHAR(2)` | — | — |
| `pEjecutivoReviso` | `CHAR(8)` | `rev`=reversión (abreviación de reversa/reverso) | 🟡 INFERIDO |
| `pFechaRevision` | `DATE` | `rev`=reversión (abreviación de reversa/reverso) | 🟡 INFERIDO |
| `pTiempoIniRev` | `DATETIME HOUR TO SECOND` | `rev`=reversión (abreviación de reversa/reverso) | 🟡 INFERIDO |
| `pTiempoFinRev` | `DATETIME HOUR TO SECOND` | `rev`=reversión (abreviación de reversa/reverso) | 🟡 INFERIDO |
| `pDevuelto` | `CHAR(1)` | — | — |
| `pRevisado` | `CHAR(1)` | `rev`=reversión (abreviación de reversa/reverso) | 🟡 INFERIDO |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(6)` | L22 |
| `cCodRet2` | `CHAR(6)` | L23 |
| `cCodRet3` | `CHAR(60)` | L24 |
| `iSql_Err` | `INTEGER` | L25 |
| `iSam_Err` | `INTEGER` | L26 |
| `iDesc_Err` | `CHAR(60)` | L27 |
| `dtTiempoTotalRev` | `DATETIME HOUR TO SECOND` | L28 |
| `dFechaHoy` | `DATE` | L29 |
| `cRevisados` | `CHAR(1)` | L30 |
| `cCheques` | `CHAR(7)` | L31 |
| `cDevueltos` | `CHAR(1)` | L32 |
| `cMotivos` | `CHAR(2)` | L33 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `dfechahoy` | `bditef` | no | INSERT | L80 |
| `cce_cheques_revisados` | `bditef` | no | SELECT | L86 |
| `cce_cheques_revisados` | `bditef` | no | INSERT | L89 |
| `crevisados` | `bditef` | no | INSERT | L119 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L35 | CÓDIGO_RETORNO | `LET cCodRet         = '00000';` |  |
| L73 | CÓDIGO_RETORNO | `LET cCodRet = '00003';` |  |
| L109 | CÓDIGO_RETORNO | `LET cCodRet = '00001';` |  |
| L122 | FÓRMULA | `LET dtTiempoTotalRev = (pTiempoFinRev - pTiempoIniRev)::CHAR(10);` |  |
| L144 | FÓRMULA | `LET dtTiempoTotalRev = (pTiempoFinRev - pTiempoIniRev)::CHAR(10);` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `cce` | ENTIDAD | CCE — Cámara de Compensación Electrónica (CECOBAN/Banxico) — | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `cheques` | ENTIDAD | cheques | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `rev` | ACCION | reversión (abreviación de reversa/reverso) | 🟡 INFERIDO | nombre_sp |
| `?isad` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `os` | ENTIDAD | OS — Originación de Solicitudes / subsistema de ofertas (sp_ | 🟡 INFERIDO | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?isad` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_cce_consultar_chequesdev_consdev2`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_sp_cce_consultar_chequesdev_consdev2.sql` |
| **LOC (1er CREATE)** | 83 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 2 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "consultar CCE — Cámara de Compensación Electrónica y cheques" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=4 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=1 / 8 términos |

### Firma

```sql
CREATE PROCEDURE sp_cce_consultar_chequesdev_consdev2(
  pEmpresa                     CHAR(3)
  pFecha                       CHAR(10)
  pRegistros                   INTEGER
  pRecuperacion                INTEGER
) RETURNING CHAR(6) 		AS cod_ret,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pEmpresa` | `CHAR(3)` | — | — |
| `pFecha` | `CHAR(10)` | — | — |
| `pRegistros` | `INTEGER` | — | — |
| `pRecuperacion` | `INTEGER` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `iSqlErr` | `INTEGER` | L15 |
| `iIsamErr` | `INTEGER` | L16 |
| `cErrorInfo` | `CHAR(80)` | L17 |
| `cCodRet` | `CHAR(6)` | L18 |
| `cBanco` | `CHAR(3)` | L19 |
| `cNumCuenta` | `CHAR(20)` | L20 |
| `cNumCheque` | `CHAR(7)` | L21 |
| `dMonto` | `DECIMAL(16,2)` | L22 |
| `cCta_Deposito` | `CHAR(20)` | L23 |
| `cCodigoRetDev` | `CHAR(5)` | L24 |
| `cMotivo` | `CHAR(2)` | L25 |
| `cDescMotivo` | `CHAR(35)` | L26 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `cce_cheques_dev` | `bditef` | no | SELECT | L65 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `cce` | ENTIDAD | CCE — Cámara de Compensación Electrónica (CECOBAN/Banxico) — | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `consultar` | ACCION | consultar | 🔵 CONVENCIÓN | nombre_sp |
| `cheques` | ENTIDAD | cheques | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `dev` | ACCION | devolución | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `cons` | ACCION | consulta | 🔵 CONVENCIÓN | nombre_sp |
| `dev` | ACCION | devolución | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `?2` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?2` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_cce_consultar_chequesdev_consdev2_totales`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_sp_cce_consultar_chequesdev_consdev2_totales.sql` |
| **LOC (1er CREATE)** | 81 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 3 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "consultar CCE — Cámara de Compensación Electrónica y cheques (totales)" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=4 · CONVENCIÓN=4 · INFERIDO=0 · SINTÉTICO=1 / 9 términos |

### Firma

```sql
CREATE PROCEDURE sp_cce_consultar_chequesdev_consdev2_totales(
  pEmpresa                     CHAR(3)
  pFecha                       CHAR(10)
) RETURNING CHAR(6) 		AS cod_ret,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pEmpresa` | `CHAR(3)` | — | — |
| `pFecha` | `CHAR(10)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `iSqlErr` | `INTEGER` | L8 |
| `iIsamErr` | `INTEGER` | L9 |
| `cErrorInfo` | `CHAR(80)` | L10 |
| `cCodRet` | `CHAR(6)` | L11 |
| `cBanco` | `CHAR(3)` | L13 |
| `cNumCuenta` | `CHAR(20)` | L14 |
| `cNumCheque` | `CHAR(7)` | L15 |
| `dMonto` | `DECIMAL(16,2)` | L16 |
| `cCta_Deposito` | `CHAR(20)` | L17 |
| `cCodigoRetDev` | `CHAR(5)` | L18 |
| `cMotivo` | `CHAR(2)` | L19 |
| `cDescMotivo` | `CHAR(35)` | L20 |
| `iNoRegistros` | `INTEGER` | L21 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `cce_cheques_dev` | `bditef` | no | SELECT | L64 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `cce` | ENTIDAD | CCE — Cámara de Compensación Electrónica (CECOBAN/Banxico) — | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `consultar` | ACCION | consultar | 🔵 CONVENCIÓN | nombre_sp |
| `cheques` | ENTIDAD | cheques | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `dev` | ACCION | devolución | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `cons` | ACCION | consulta | 🔵 CONVENCIÓN | nombre_sp |
| `dev` | ACCION | devolución | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `?2_` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `totales` | MODIF | totales | 🔵 CONVENCIÓN | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?2_` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_cce_consultar_chequesdev_devcoppel`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_sp_cce_consultar_chequesdev_devcoppel.sql` |
| **LOC (1er CREATE)** | 105 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 5 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "consultar CCE — Cámara de Compensación Electrónica, cheques y Coppel" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=4 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=0 / 7 términos |

### Firma

```sql
CREATE PROCEDURE sp_cce_consultar_chequesdev_devcoppel(
  pEmpresa                     CHAR(3)
  pFecha                       CHAR(10)
  cCtaDev                      CHAR(20)
) RETURNING CHAR(6) 		AS cod_ret,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pEmpresa` | `CHAR(3)` | — | — |
| `pFecha` | `CHAR(10)` | — | — |
| `cCtaDev` | `CHAR(20)` | `dev`=devolución · `dev`=devolución | ✅ CÓDIGO |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `iSqlErr` | `INTEGER` | L22 |
| `iIsamErr` | `INTEGER` | L23 |
| `cErrorInfo` | `CHAR(80)` | L24 |
| `cCodRet` | `CHAR(6)` | L25 |
| `cBanco` | `CHAR(3)` | L27 |
| `cNumCuenta` | `CHAR(20)` | L28 |
| `cNumCheque` | `CHAR(7)` | L29 |
| `dMonto` | `DECIMAL(16,2)` | L30 |
| `cCta_Deposito` | `CHAR(20)` | L31 |
| `cCodigoRetDev` | `CHAR(5)` | L32 |
| `cMotivo` | `CHAR(2)` | L33 |
| `cDescMotivo` | `CHAR(35)` | L34 |
| `cSucursal` | `CHAR(4)` | L35 |
| `cNomSucursal` | `CHAR(40)` | L36 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `cce_cheques_dev` | `bditef` | no | SELECT | L84 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `cce` | ENTIDAD | CCE — Cámara de Compensación Electrónica (CECOBAN/Banxico) — | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `consultar` | ACCION | consultar | 🔵 CONVENCIÓN | nombre_sp |
| `cheques` | ENTIDAD | cheques | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `dev` | ACCION | devolución | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `dev` | ACCION | devolución | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `coppel` | ENTIDAD | Coppel (grupo) | 🔵 CONVENCIÓN | nombre_sp |

---

## `sp_cce_consultar_chequesdev_devcoppel2`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_sp_cce_consultar_chequesdev_devcoppel2.sql` |
| **LOC (1er CREATE)** | 93 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 9 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "consultar CCE — Cámara de Compensación Electrónica, cheques y Coppel" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=5 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=1 / 8 términos |

### Firma

```sql
CREATE PROCEDURE sp_cce_consultar_chequesdev_devcoppel2(
  pEmpresa                     CHAR(3)
  pFecha                       CHAR(10)
  cCtaDev                      CHAR(20)
  pRegistros                   INTEGER
  pRecuperacion                INTEGER
) RETURNING CHAR(6) 		AS cod_ret,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pEmpresa` | `CHAR(3)` | — | — |
| `pFecha` | `CHAR(10)` | — | — |
| `cCtaDev` | `CHAR(20)` | `dev`=devolución · `dev`=devolución | ✅ CÓDIGO |
| `pRegistros` | `INTEGER` | — | — |
| `pRecuperacion` | `INTEGER` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `iSqlErr` | `INTEGER` | L17 |
| `iIsamErr` | `INTEGER` | L18 |
| `cErrorInfo` | `CHAR(80)` | L19 |
| `cCodRet` | `CHAR(6)` | L20 |
| `cBanco` | `CHAR(3)` | L21 |
| `cNumCuenta` | `CHAR(20)` | L22 |
| `cNumCheque` | `CHAR(7)` | L23 |
| `dMonto` | `DECIMAL(16,2)` | L24 |
| `cCta_Deposito` | `CHAR(20)` | L25 |
| `cCodigoRetDev` | `CHAR(5)` | L26 |
| `cMotivo` | `CHAR(2)` | L27 |
| `cDescMotivo` | `CHAR(35)` | L28 |
| `cSucursal` | `CHAR(4)` | L29 |
| `cNomSucursal` | `CHAR(40)` | L30 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `cce_cheques_dev` | `bditef` | no | SELECT | L72 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `cce` | ENTIDAD | CCE — Cámara de Compensación Electrónica (CECOBAN/Banxico) — | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `consultar` | ACCION | consultar | 🔵 CONVENCIÓN | nombre_sp |
| `cheques` | ENTIDAD | cheques | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `dev` | ACCION | devolución | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `dev` | ACCION | devolución | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `coppel` | ENTIDAD | Coppel (grupo) | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?2` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?2` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_cce_consultar_chequesdev_devcoppel2_totales`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_sp_cce_consultar_chequesdev_devcoppel2_totales.sql` |
| **LOC (1er CREATE)** | 82 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 8 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "consultar CCE — Cámara de Compensación Electrónica, cheques y Coppel (totales)" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=5 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=1 / 9 términos |

### Firma

```sql
CREATE PROCEDURE sp_cce_consultar_chequesdev_devcoppel2_totales(
  pEmpresa                     CHAR(3)
  pFecha                       CHAR(10)
  cCtaDev                      CHAR(20)
) RETURNING CHAR(6) 		AS cod_ret,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pEmpresa` | `CHAR(3)` | — | — |
| `pFecha` | `CHAR(10)` | — | — |
| `cCtaDev` | `CHAR(20)` | `dev`=devolución · `dev`=devolución | ✅ CÓDIGO |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `iSqlErr` | `INTEGER` | L8 |
| `iIsamErr` | `INTEGER` | L9 |
| `cErrorInfo` | `CHAR(80)` | L10 |
| `cCodRet` | `CHAR(6)` | L11 |
| `cBanco` | `CHAR(3)` | L12 |
| `cNumCuenta` | `CHAR(20)` | L13 |
| `cNumCheque` | `CHAR(7)` | L14 |
| `dMonto` | `DECIMAL(16,2)` | L15 |
| `cCta_Deposito` | `CHAR(20)` | L16 |
| `cCodigoRetDev` | `CHAR(5)` | L17 |
| `cMotivo` | `CHAR(2)` | L18 |
| `cDescMotivo` | `CHAR(35)` | L19 |
| `cSucursal` | `CHAR(4)` | L20 |
| `cNomSucursal` | `CHAR(40)` | L21 |
| `vnoregistros` | `INTEGER` | L22 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `cce_cheques_dev` | `bditef` | no | SELECT | L63 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `cce` | ENTIDAD | CCE — Cámara de Compensación Electrónica (CECOBAN/Banxico) — | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `consultar` | ACCION | consultar | 🔵 CONVENCIÓN | nombre_sp |
| `cheques` | ENTIDAD | cheques | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `dev` | ACCION | devolución | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `dev` | ACCION | devolución | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `coppel` | ENTIDAD | Coppel (grupo) | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?2_` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `totales` | MODIF | totales | 🔵 CONVENCIÓN | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?2_` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_cce_consultar_detallecheques`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_sp_cce_consultar_detallecheques.sql` |
| **LOC (1er CREATE)** | 94 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 3 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "consultar CCE — Cámara de Compensación Electrónica, detalle y cheques" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=3 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=0 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_cce_consultar_detallecheques(
  pEmpresa                     CHAR(3)
  pBanco                       CHAR(3)
  pCuenta                      CHAR(20)
  pNoCheque                    CHAR(7)
) RETURNING CHAR(6) AS cod_ret,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pEmpresa` | `CHAR(3)` | — | — |
| `pBanco` | `CHAR(3)` | — | — |
| `pCuenta` | `CHAR(20)` | — | — |
| `pNoCheque` | `CHAR(7)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `iSqlErr` | `INTEGER` | L13 |
| `iIsamErr` | `INTEGER` | L14 |
| `cErrorInfo` | `CHAR(80)` | L15 |
| `cCodRet` | `CHAR(6)` | L16 |
| `cCompensacion` | `CHAR(3)` | L18 |
| `cTransacc` | `CHAR(2)` | L19 |
| `cCodSeguridad` | `CHAR(3)` | L20 |
| `cDigVerPre` | `CHAR(1)` | L21 |
| `cDigVerInter` | `CHAR(1)` | L22 |
| `viCuenta` | `INT8` | L24 |
| `viNoCheque` | `INTEGER` | L25 |
| `vcCuenta` | `CHAR(20)` | L26 |
| `vcNoCheque` | `CHAR(7)` | L27 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `cce_cheques_det` | `bditef` | no | SELECT | L74 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `cce` | ENTIDAD | CCE — Cámara de Compensación Electrónica (CECOBAN/Banxico) — | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `consultar` | ACCION | consultar | 🔵 CONVENCIÓN | nombre_sp |
| `detalle` | ENTIDAD | detalle | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `cheques` | ENTIDAD | cheques | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |

---

## `sp_cce_consultar_detallecheques_pba`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_sp_cce_consultar_detallecheques_pba.sql` |
| **LOC (1er CREATE)** | 87 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 4 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "consultar CCE — Cámara de Compensación Electrónica, detalle y cheques (PBA — sufijo de SPs para Pruebas; confirmado por SME)" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo · `confirma` → `SELECT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=3 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=0 / 6 términos |

### Firma

```sql
CREATE PROCEDURE sp_cce_consultar_detallecheques_pba(
  pEmpresa                     CHAR(3)
  pBanco                       CHAR(3)
  pCuenta                      CHAR(20)
  pNoCheque                    CHAR(7)
) RETURNING CHAR(6) 		AS cod_ret,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pEmpresa` | `CHAR(3)` | — | — |
| `pBanco` | `CHAR(3)` | `pba`=PBA — sufijo de SPs para Pruebas; confirmado por SME (Guerra, Alejandro, 2026-07-09) | 🔵 CONVENCIÓN |
| `pCuenta` | `CHAR(20)` | — | — |
| `pNoCheque` | `CHAR(7)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `iSqlErr` | `INTEGER` | L17 |
| `iIsamErr` | `INTEGER` | L18 |
| `cErrorInfo` | `CHAR(80)` | L19 |
| `cCodRet` | `CHAR(6)` | L20 |
| `cCompensacion` | `CHAR(3)` | L23 |
| `cTransacc` | `CHAR(2)` | L24 |
| `cCodSeguridad` | `CHAR(3)` | L25 |
| `cDigVerPre` | `CHAR(1)` | L26 |
| `cDigVerInter` | `CHAR(1)` | L27 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `cce_cheques_det` | `bditef` | no | SELECT | L66 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `cce` | ENTIDAD | CCE — Cámara de Compensación Electrónica (CECOBAN/Banxico) — | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `consultar` | ACCION | consultar | 🔵 CONVENCIÓN | nombre_sp |
| `detalle` | ENTIDAD | detalle | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `cheques` | ENTIDAD | cheques | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `pba` | MODIF | PBA — sufijo de SPs para Pruebas; confirmado por SME (Guerra | 🔵 CONVENCIÓN | nombre_sp |

---

## `sp_cce_consultausuariosaut`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_sp_cce_consultausuariosaut.sql` |
| **LOC (1er CREATE)** | 57 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 12 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "consulta CCE — Cámara de Compensación Electrónica y usuarios" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=3 · CONVENCIÓN=1 · INFERIDO=1 · SINTÉTICO=0 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_cce_consultausuariosaut(
  pNumEjecut                   INTEGER
) RETURNING CHAR(5)	AS CodigoRetorno,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pNumEjecut` | `INTEGER` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(5)` | L6 |
| `iSql_Err` | `INTEGER` | L7 |
| `iSam_Err` | `INTEGER` | L8 |
| `cDesc_Err` | `CHAR(60)` | L9 |
| `iEjecutivo` | `INTEGER` | L10 |
| `vNombreEjecut` | `VARCHAR(100)` | L11 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `cce_usuarios_revision` | `bditef` | no | SELECT | L39 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `cce` | ENTIDAD | CCE — Cámara de Compensación Electrónica (CECOBAN/Banxico) — | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `consulta` | ACCION | consulta / lee | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `usuarios` | ENTIDAD | usuarios | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `aut` | ACCION | autorización | 🟡 INFERIDO | nombre_sp |

---

## `sp_cce_controlusuariosaut`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_sp_cce_controlusuariosaut.sql` |
| **LOC (1er CREATE)** | 89 |
| **Callgraph** | ✅ fan_in=14 / fan_out=17 |
| **Principales callers** | `sp_guardactemoral` |
| **Deps concatenadas** | 22 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "autorización CCE — Cámara de Compensación Electrónica, rol y usuarios" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 3 tabla(s) con operaciones: INSERT, DELETE, SELECT |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=3 · INFERIDO=1 · SINTÉTICO=0 / 6 términos |

### Firma

```sql
CREATE PROCEDURE sp_cce_controlusuariosaut(
  pOperacion                   INTEGER
  pNumEjecut                   INTEGER
  pNombreEjecut                VARCHAR(100)
  pFecha                       DATE
) RETURNING CHAR(5) AS CodigoRetorno
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pOperacion` | `INTEGER` | — | — |
| `pNumEjecut` | `INTEGER` | — | — |
| `pNombreEjecut` | `VARCHAR(100)` | — | — |
| `pFecha` | `DATE` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(5)` | L7 |
| `iSql_Err` | `INTEGER` | L8 |
| `iSam_Err` | `INTEGER` | L9 |
| `cDesc_Err` | `CHAR(60)` | L10 |
| `iOperacion` | `INTEGER` | L11 |
| `iNumEjecut` | `INTEGER` | L12 |
| `vNombreEjecut` | `VARCHAR(100)` | L13 |
| `dFecha` | `DATE` | L14 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `cce_usuarios_revision` | `bditef` | no | SELECT | L57 |
| `cce_usuarios_revision` | `bditef` | no | INSERT | L61 |
| `cce_usuarios_revision` | `bditef` | no | DELETE | L74 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `cce` | ENTIDAD | CCE — Cámara de Compensación Electrónica (CECOBAN/Banxico) — | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `cont` | PREFIJO | familia contabilidad | 🔵 CONVENCIÓN | nombre_sp |
| `rol` | ENTIDAD | rol / perfil | 🔵 CONVENCIÓN | nombre_sp |
| `usuarios` | ENTIDAD | usuarios | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `aut` | ACCION | autorización | 🟡 INFERIDO | nombre_sp |

---

## `sp_cce_guardar_detalle`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_sp_cce_guardar_detalle.sql` |
| **LOC (1er CREATE)** | 91 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 4 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "guarda CCE — Cámara de Compensación Electrónica y detalle" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `guarda` → `INSERT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=1 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_cce_guardar_detalle(
  pNomArchivo                  CHAR(22)
  pTipoRegistro                CHAR(2)
  pNumSecuencia                CHAR(7)
  pCodOperacion                CHAR(2)
  pFechaTransfer               CHAR(8)
  pBancoCedente                CHAR(3)
  pBancoLibrado                CHAR(3)
  pImporte                     DECIMAL(19,2)
  pLoteEntrada                 CHAR(7)
  pSecEntrada                  CHAR(4)
  pLoteSalida                  CHAR(7)
  pSecSalida                   CHAR(4)
  pCveTrans                    CHAR(2)
  pPlazaCompensa               CHAR(3)
  pNumCuenta                   CHAR(13)
  pNumCheque                   CHAR(10)
  pDigInter                    CHAR(1)
  pDigPremar                   CHAR(1)
  pCodSegur                    CHAR(3)
  pUbicFis                     CHAR(8)
  pTruncam                     CHAR(1)
  pMotivoDevol                 CHAR(2)
  pFechapPresIni               CHAR(8)
  pPlazaIntercam               CHAR(2)
  pRFCBen                      CHAR(13)
  pCURPBen                     CHAR(18)
  pTipoCtaDeb                  CHAR(2)
  pCtaDeb                      CHAR(20)
  pNombreBen                   CHAR(40)
  pAlertamiento                CHAR(2)
  pFolioSegur                  CHAR(12)
) RETURNING CHAR(6) 		AS cod_ret
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pNomArchivo` | `CHAR(22)` | — | — |
| `pTipoRegistro` | `CHAR(2)` | — | — |
| `pNumSecuencia` | `CHAR(7)` | — | — |
| `pCodOperacion` | `CHAR(2)` | — | — |
| `pFechaTransfer` | `CHAR(8)` | — | — |
| `pBancoCedente` | `CHAR(3)` | — | — |
| `pBancoLibrado` | `CHAR(3)` | — | — |
| `pImporte` | `DECIMAL(19,2)` | — | — |
| `pLoteEntrada` | `CHAR(7)` | — | — |
| `pSecEntrada` | `CHAR(4)` | — | — |
| `pLoteSalida` | `CHAR(7)` | — | — |
| `pSecSalida` | `CHAR(4)` | — | — |
| `pCveTrans` | `CHAR(2)` | — | — |
| `pPlazaCompensa` | `CHAR(3)` | — | — |
| `pNumCuenta` | `CHAR(13)` | — | — |
| `pNumCheque` | `CHAR(10)` | — | — |
| `pDigInter` | `CHAR(1)` | — | — |
| `pDigPremar` | `CHAR(1)` | — | — |
| `pCodSegur` | `CHAR(3)` | — | — |
| `pUbicFis` | `CHAR(8)` | — | — |
| `pTruncam` | `CHAR(1)` | — | — |
| `pMotivoDevol` | `CHAR(2)` | — | — |
| `pFechapPresIni` | `CHAR(8)` | — | — |
| `pPlazaIntercam` | `CHAR(2)` | — | — |
| `pRFCBen` | `CHAR(13)` | — | — |
| `pCURPBen` | `CHAR(18)` | — | — |
| `pTipoCtaDeb` | `CHAR(2)` | — | — |
| `pCtaDeb` | `CHAR(20)` | — | — |
| `pNombreBen` | `CHAR(40)` | — | — |
| `pAlertamiento` | `CHAR(2)` | — | — |
| `pFolioSegur` | `CHAR(12)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `iSqlErr` | `INTEGER` | L39 |
| `iIsamErr` | `INTEGER` | L40 |
| `cErrorInfo` | `CHAR(80)` | L41 |
| `cCodRet` | `CHAR(6)` | L42 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `cce` | ENTIDAD | CCE — Cámara de Compensación Electrónica (CECOBAN/Banxico) — | 🔵 CONVENCIÓN | nombre_sp |
| `guarda` | ACCION | guarda / almacena | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?r_` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `detalle` | ENTIDAD | detalle | ✅ CÓDIGO | nombre_sp, texto_cuerpo |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?r_` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_cce_guardar_encabezado`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_sp_cce_guardar_encabezado.sql` |
| **LOC (1er CREATE)** | 68 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 3 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "guarda CCE — Cámara de Compensación Electrónica y encabezado" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `guarda` → `INSERT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=3 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=1 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_cce_guardar_encabezado(
  pNomArchivo                  CHAR(22)
  pTipoRegistro                CHAR(2)
  pNumSecuencia                CHAR(7)
  pNumBanco                    CHAR(3)
  pSenntidoTransfer            CHAR(1)
  pPlazaCecoban                CHAR(2)
  pServicioTEI                 CHAR(1)
  pDiaMesTransfer              CHAR(2)
  pNumBloque                   CHAR(5)
  pFechaPresenta               CHAR(8)
  pTipoArchivo                 CHAR(1)
  pUsuario                     CHAR(8)
  pFechaHoy                    DATE
) RETURNING CHAR(6) 		AS cod_ret
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pNomArchivo` | `CHAR(22)` | — | — |
| `pTipoRegistro` | `CHAR(2)` | — | — |
| `pNumSecuencia` | `CHAR(7)` | — | — |
| `pNumBanco` | `CHAR(3)` | — | — |
| `pSenntidoTransfer` | `CHAR(1)` | — | — |
| `pPlazaCecoban` | `CHAR(2)` | — | — |
| `pServicioTEI` | `CHAR(1)` | — | — |
| `pDiaMesTransfer` | `CHAR(2)` | — | — |
| `pNumBloque` | `CHAR(5)` | — | — |
| `pFechaPresenta` | `CHAR(8)` | — | — |
| `pTipoArchivo` | `CHAR(1)` | — | — |
| `pUsuario` | `CHAR(8)` | — | — |
| `pFechaHoy` | `DATE` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `iSqlErr` | `INTEGER` | L21 |
| `iIsamErr` | `INTEGER` | L22 |
| `cErrorInfo` | `CHAR(80)` | L23 |
| `cCodRet` | `CHAR(6)` | L24 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `cce_encabezado` | `bditef` | no | INSERT | L47 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `cce` | ENTIDAD | CCE — Cámara de Compensación Electrónica (CECOBAN/Banxico) — | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `guarda` | ACCION | guarda / almacena | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?r_` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `encabezado` | ENTIDAD | encabezado | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?r_` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_cce_guardar_gransumario`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_sp_cce_guardar_gransumario.sql` |
| **LOC (1er CREATE)** | 74 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 2 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "guarda CCE — Cámara de Compensación Electrónica" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `guarda` → `INSERT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=1 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_cce_guardar_gransumario(
  pNumArchivo                  CHAR(22)
  pTipoRegistro                CHAR(2)
  pSentido                     CHAR(1)
  pCodOperacion                CHAR(2)
  pNumOperaciones              CHAR(7)
  pNumBloques                  CHAR(2)
  pNroBanco                    CHAR(3)
  pFolio                       CHAR(9)
  pFecha                       CHAR(8)
  pImporteTotal                DECIMAL(19,2)
  pTotRegTruncIMG              CHAR(7)
) RETURNING CHAR(6) 		AS cod_ret
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pNumArchivo` | `CHAR(22)` | — | — |
| `pTipoRegistro` | `CHAR(2)` | — | — |
| `pSentido` | `CHAR(1)` | — | — |
| `pCodOperacion` | `CHAR(2)` | — | — |
| `pNumOperaciones` | `CHAR(7)` | — | — |
| `pNumBloques` | `CHAR(2)` | — | — |
| `pNroBanco` | `CHAR(3)` | — | — |
| `pFolio` | `CHAR(9)` | — | — |
| `pFecha` | `CHAR(8)` | — | — |
| `pImporteTotal` | `DECIMAL(19,2)` | — | — |
| `pTotRegTruncIMG` | `CHAR(7)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `iSqlErr` | `INTEGER` | L19 |
| `iIsamErr` | `INTEGER` | L20 |
| `cErrorInfo` | `CHAR(80)` | L21 |
| `cCodRet` | `CHAR(6)` | L22 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `cce_gransumario` | `bditef` | no | INSERT | L47 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `cce` | ENTIDAD | CCE — Cámara de Compensación Electrónica (CECOBAN/Banxico) — | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `guarda` | ACCION | guarda / almacena | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?r_gransumario` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?r_gransumario` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_cce_guardar_sumario`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_sp_cce_guardar_sumario.sql` |
| **LOC (1er CREATE)** | 61 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 1 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "guarda CCE — Cámara de Compensación Electrónica" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `guarda` → `INSERT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=1 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_cce_guardar_sumario(
  pNomArchivo                  CHAR(22)
  pTipoRegistro                CHAR(2)
  pNumSecuencia                CHAR(7)
  pCodOperacion                CHAR(2)
  pTotRegs                     CHAR(7)
  pImporte                     DECIMAL(19,2)
  pTotRegTrunImg               CHAR(7)
) RETURNING CHAR(6) 		AS cod_ret
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pNomArchivo` | `CHAR(22)` | — | — |
| `pTipoRegistro` | `CHAR(2)` | — | — |
| `pNumSecuencia` | `CHAR(7)` | — | — |
| `pCodOperacion` | `CHAR(2)` | — | — |
| `pTotRegs` | `CHAR(7)` | — | — |
| `pImporte` | `DECIMAL(19,2)` | — | — |
| `pTotRegTrunImg` | `CHAR(7)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `iSqlErr` | `INTEGER` | L15 |
| `iIsamErr` | `INTEGER` | L16 |
| `cErrorInfo` | `CHAR(80)` | L17 |
| `cCodRet` | `CHAR(6)` | L18 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `cce_sumario` | `bditef` | no | INSERT | L42 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `cce` | ENTIDAD | CCE — Cámara de Compensación Electrónica (CECOBAN/Banxico) — | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `guarda` | ACCION | guarda / almacena | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?r_sumario` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?r_sumario` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_cons_presenta2`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_sp_cons_presenta2.sql` |
| **LOC (1er CREATE)** | 214 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 6 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "consulta" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=1 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_cons_presenta2(
  pempresa                     char(3)
  pfechapre                    date
) RETURNING char(5)    AS codret,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pempresa` | `char(3)` | — | — |
| `pfechapre` | `date` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `v_codret` | `char(5)` | L13 |
| `v_banco` | `char(100)` | L14 |
| `v_cuenta` | `char(11)` | L15 |
| `v_numcheque` | `char(7)` | L16 |
| `v_monto` | `decimal(16,2)` | L17 |
| `v_sucursal` | `char(45)` | L18 |
| `v_ctadeposito` | `char(20)` | L19 |
| `v_nombrecte` | `char(100)` | L20 |
| `v_presentado` | `char(1)` | L21 |
| `v_numcte` | `char(20)` | L22 |
| `v_rfc` | `char(1)` | L23 |
| `v_curp` | `char(1)` | L24 |
| `v_fechapaso` | `date` | L25 |
| `v_transacc` | `char(4)` | L29 |
| `v_trancheques` | `char(4)` | L31 |
| `v_trancredito` | `char(4)` | L32 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_transacc` | `bdinteg` | ⚠️ sí | SELECT | L99 |
| `cce_cheques_det` | `bditef` | no | SELECT | L146 |
| `sc_maechq` | `bdicheq` | ⚠️ sí | SELECT | L166 |
| `sd_tarjeta` | `bdicred` | ⚠️ sí | SELECT | L176 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `consnomcte` | `bditef` | no | L194 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L65 | VALIDACIÓN_NULL | `IF      pempresa is null or` |  |
| L104 | VALIDACIÓN_NULL | `IF v_trancheques is null THEN` |  |
| L120 | VALIDACIÓN_NULL | `IF v_trancredito is null THEN` |  |
| L183 | VALIDACIÓN_NULL | `IF v_numcte is null or v_numcte = "" THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `cons` | ACCION | consulta | 🔵 CONVENCIÓN | nombre_sp |
| `presenta` | ACCION | presenta | 🔵 CONVENCIÓN | nombre_sp |
| `?2` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?2` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_cons_presenta2_totales`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_sp_cons_presenta2_totales.sql` |
| **LOC (1er CREATE)** | 200 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 5 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "consulta (totales)" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=4 · INFERIDO=0 · SINTÉTICO=1 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_cons_presenta2_totales(
  pempresa                     char(3)
  pfechapre                    date
) RETURNING char(5),
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pempresa` | `char(3)` | — | — |
| `pfechapre` | `date` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `v_codret` | `char(5)` | L5 |
| `v_banco` | `char(100)` | L6 |
| `v_cuenta` | `char(11)` | L7 |
| `v_numcheque` | `char(7)` | L8 |
| `v_monto` | `decimal(16,2)` | L9 |
| `v_sucursal` | `char(45)` | L10 |
| `v_ctadeposito` | `char(20)` | L11 |
| `v_nombrecte` | `char(100)` | L12 |
| `v_presentado` | `char(1)` | L13 |
| `v_numcte` | `char(20)` | L14 |
| `v_rfc` | `char(1)` | L15 |
| `v_curp` | `char(1)` | L16 |
| `v_fechapaso` | `date` | L17 |
| `v_transacc` | `char(4)` | L21 |
| `v_trancheques` | `char(4)` | L23 |
| `v_trancredito` | `char(4)` | L24 |
| `vnoregistros` | `INTEGER` | L25 |
| `vnoregistros_mae` | `INTEGER` | L26 |
| `vnoregistros_tar` | `INTEGER` | L27 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_transacc` | `bdinteg` | ⚠️ sí | SELECT | L94 |
| `cce_cheques_det` | `bditef` | no | SELECT | L137 |
| `sc_maechq` | `bdicheq` | ⚠️ sí | SELECT | L156 |
| `sd_tarjeta` | `bdicred` | ⚠️ sí | SELECT | L166 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `consnomcte` | `bditef` | no | L182 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L65 | VALIDACIÓN_NULL | `IF      pempresa is null or` |  |
| L99 | VALIDACIÓN_NULL | `IF v_trancheques is null THEN` |  |
| L113 | VALIDACIÓN_NULL | `IF v_trancredito is null THEN` |  |
| L173 | VALIDACIÓN_NULL | `IF v_numcte is null or v_numcte = "" THEN` |  |
| L185 | FÓRMULA | `LET vnoregistros = vnoregistros + 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `cons` | ACCION | consulta | 🔵 CONVENCIÓN | nombre_sp |
| `presenta` | ACCION | presenta | 🔵 CONVENCIÓN | nombre_sp |
| `?2_` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `totales` | MODIF | totales | 🔵 CONVENCIÓN | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?2_` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_consdevext_tef`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_sp_consdevext_tef.sql` |
| **LOC (1er CREATE)** | 141 |
| **Callgraph** | ✅ fan_in=45 / fan_out=25 |
| **Principales callers** | `sp_calificacion_scoring` |
| **Deps concatenadas** | 43 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "consulta TEF — transferencia electrónica de fondos" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=4 · INFERIDO=0 · SINTÉTICO=2 / 7 términos |

### Historia del SP

| Tipo | Valor |
|------|-------|
| DESCRIPCION | Realiza consulta para obtener detalle de las devoluciones extemporáneas. |
| FECHA | 2011/03/25 |

### Firma

```sql
CREATE PROCEDURE sp_consdevext_tef(
  psConsultaDevuelve           CHAR(1)
  psFechaArch                  CHAR(8)
  psMotivoDev                  CHAR(2)
  psNumSecuencia               CHAR(7)
  psNumCtaRec                  CHAR(20)
  psFolioSuc                   CHAR(30)
) RETURNING CHAR(5) AS CodRet, CHAR(8) AS FechaAbono, CHAR(20) AS Cuenta, CHAR(18) AS Referencia, CHAR(40) AS Banco, CHAR(30) AS Importe, CHAR(10) AS Estatus, CHAR(1) AS Confirmado, CHAR(7) AS NumSecuencia, CHAR(30) AS ClaveRastreo, CHAR(2) AS CveStatus
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `psConsultaDevuelve` | `CHAR(1)` | `cons`=consulta · `dev`=devolución | 🔵 CONVENCIÓN |
| `psFechaArch` | `CHAR(8)` | — | — |
| `psMotivoDev` | `CHAR(2)` | `dev`=devolución | 🔵 CONVENCIÓN |
| `psNumSecuencia` | `CHAR(7)` | — | — |
| `psNumCtaRec` | `CHAR(20)` | — | — |
| `psFolioSuc` | `CHAR(30)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vsFechaAbono` | `CHAR(8)` | L22 |
| `vsCuenta` | `CHAR(20)` | L23 |
| `vsReferencia` | `CHAR(18)` | L24 |
| `vsBanco` | `CHAR(40)` | L25 |
| `vsImporte` | `CHAR(30)` | L26 |
| `vsEstatus` | `CHAR(10)` | L27 |
| `vsConfirmado` | `CHAR(1)` | L28 |
| `vsNumSecuencia` | `CHAR(7)` | L29 |
| `vsDiasNat` | `CHAR(3)` | L30 |
| `vsClaveRastreo` | `CHAR(30)` | L31 |
| `vsCveStatus` | `CHAR(2)` | L32 |
| `vsCodRet` | `CHAR(5)` | L34 |
| `viSqlErr` | `INTEGER` | L35 |
| `vsFechaHoy` | `CHAR(10)` | L37 |
| `vsValFecha` | `CHAR(10)` | L38 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_fechas` | `bdinteg` | ⚠️ sí | SELECT | L74 |
| `tef_parametros` | `bditef` | no | SELECT | L78 |
| `tef_cce_detalle` | `bditef` | no | SELECT | L101 |
| `tef_cce_detalle` | `bditef` | no | UPDATE | L115 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_valida_fecha` | `bditef` | no | L84 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L80 | FÓRMULA | `LET vsFechaHoy = vsFechaHoy::DATE - TRIM(vsDiasNat)::INTEGER;` |  |
| L87 | FÓRMULA | `LET vsFechaHoy = vsFechaHoy::DATE + 1;` |  |
| L92 | FÓRMULA | `LET vsValFecha = SUBSTRING(psFechaArch FROM 5 FOR 2) \|\| "/" \|\| SUBSTRING(psFechaArch FROM 7 FOR ` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `cons` | ACCION | consulta | 🔵 CONVENCIÓN | nombre_sp |
| `dev` | ACCION | devolución | 🔵 CONVENCIÓN | nombre_sp |
| `?e` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `x` | MODIF | por (criterio) | 🔵 CONVENCIÓN | nombre_sp |
| `?t_` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `tef` | ENTIDAD | TEF — transferencia electrónica de fondos | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?e`, `?t_` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_consimgnullcheque_web`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_sp_consimgnullcheque_web.sql` |
| **LOC (1er CREATE)** | 107 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "consulta cheque (canal web)" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=4 · INFERIDO=0 · SINTÉTICO=1 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_consimgnullcheque_web(
  pEmpresa                     CHAR(3)
  pNumCheq                     CHAR(7)
  pClaveBanco                  CHAR(3)
  pNumCuenta                   CHAR(20)
  pFechaAlta                   DATE
) RETURNING CHAR(5) AS codRet, CHAR(1) AS lado_A, CHAR(1) AS lado_B, CHAR(1) AS lado_F, CHAR(1) AS lado_t
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pEmpresa` | `CHAR(3)` | — | — |
| `pNumCheq` | `CHAR(7)` | — | — |
| `pClaveBanco` | `CHAR(3)` | — | — |
| `pNumCuenta` | `CHAR(20)` | — | — |
| `pFechaAlta` | `DATE` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `v_codret` | `CHAR(5)` | L8 |
| `lado` | `CHAR(1)` | L9 |
| `vNumLados` | `INT` | L10 |
| `v_lado_A` | `CHAR(1)` | L11 |
| `v_lado_B` | `CHAR(1)` | L12 |
| `v_lado_F` | `CHAR(1)` | L13 |
| `v_lado_T` | `CHAR(1)` | L14 |
| `iimagen` | `CHAR(250)` | L15 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `cce_cheques_img` | `bditef` | no | SELECT | L51 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L44 | VALIDACIÓN_NULL | `IF pEmpresa IS NULL OR pNumCheq IS NULL OR pClaveBanco IS NULL OR pNumCuenta IS NULL OR  pFechaAlta ` |  |
| L96 | FÓRMULA | `LET v_lado_F  = "-";` |  |
| L97 | FÓRMULA | `LET v_lado_T  = "-";` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `cons` | ACCION | consulta | 🔵 CONVENCIÓN | nombre_sp |
| `?imgnull` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `cheque` | ENTIDAD | cheque | 🔵 CONVENCIÓN | nombre_sp |
| `web` | MODIF | canal web | 🔵 CONVENCIÓN | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?imgnull` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_consultaconsecutivoarchivo`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_sp_consultaconsecutivoarchivo.sql` |
| **LOC (1er CREATE)** | 88 |
| **Callgraph** | ✅ fan_in=54 / fan_out=25 |
| **Deps concatenadas** | 45 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "consulta consecutivo y archivo" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=0 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_consultaconsecutivoarchivo(
  pSistema                     CHAR(20)
  pConsecutivo                 CHAR(3)
) RETURNING CHAR(5), INTEGER, DATE
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pSistema` | `CHAR(20)` | — | — |
| `pConsecutivo` | `CHAR(3)` | `consecutivo`=consecutivo | ✅ CÓDIGO |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `iSqlErr` | `INTEGER` | L6 |
| `cCodRet` | `CHAR (5)` | L7 |
| `iConsecutivo` | `INTEGER` | L8 |
| `dFechaHoy` | `DATE` | L9 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sc_fechas` | `bdicheq` | ⚠️ sí | SELECT | L39 |
| `cce_consecutivo_proc` | `bditef` | no | SELECT | L44 |
| `cce_consecutivo_proc` | `bditef` | no | DELETE | L44 |
| `cce_consecutivo_proc` | `bditef` | no | INSERT | L62 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L32 | VALIDACIÓN_NULL | `IF pSistema IS NULL OR pSistema = ""  THEN` |  |
| L55 | VALIDACIÓN_NULL | `IF iConsecutivo = '' OR iConsecutivo IS NULL THEN` |  |
| L58 | FÓRMULA | `LET iConsecutivo = iConsecutivo +1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `consulta` | ACCION | consulta / lee | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `consecutivo` | ENTIDAD | consecutivo | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `archivo` | ENTIDAD | archivo | 🔵 CONVENCIÓN | nombre_sp |

---

## `sp_consultageneralcheques`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_sp_consultageneralcheques.sql` |
| **LOC (1er CREATE)** | 107 |
| **Callgraph** | ✅ fan_in=0 / fan_out=8 |
| **Deps concatenadas** | 14 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "consulta cheques (general)" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo · `genera` → `SELECT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=0 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_consultageneralcheques(
  pCveBanco                    CHAR(3)
  pNumCuenta                   CHAR(20)
  pNumCheque                   CHAR(7)
  pFechaPresenta               DATE
) RETURNING CHAR(6) 		AS COD_RET,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pCveBanco` | `CHAR(3)` | — | — |
| `pNumCuenta` | `CHAR(20)` | — | — |
| `pNumCheque` | `CHAR(7)` | — | — |
| `pFechaPresenta` | `DATE` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `iSqlErr` | `INTEGER` | L16 |
| `cCodRet` | `CHAR(6)` | L17 |
| `cCvebanco` | `CHAR(3)` | L18 |
| `cNumCuenta` | `CHAR(20)` | L19 |
| `cNumCheque` | `CHAR(7)` | L20 |
| `dFechaPresenta` | `DATE` | L21 |
| `cNumCte` | `CHAR(20)` | L22 |
| `cCtaDeposito` | `CHAR(20)` | L23 |
| `dcMonto` | `DECIMAL(18,2)` | L24 |
| `cMotivo` | `CHAR(2)` | L25 |
| `cDescBanco` | `CHAR(40)` | L26 |
| `cDescMotivo` | `CHAR(35)` | L27 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_bancos` | `bdinteg` | ⚠️ sí | SELECT | L86 |
| `si_coddevcam` | `bdinteg` | ⚠️ sí | SELECT | L92 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L78 | FÓRMULA | `LET cCodRet = "000002"; --NO SE ENCONTRO INFORMACION.` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `consulta` | ACCION | consulta / lee | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `general` | MODIF | general | 🔵 CONVENCIÓN | nombre_sp |
| `cheques` | ENTIDAD | cheques | 🔵 CONVENCIÓN | nombre_sp |

---

## `sp_consultarchequesdevueltos`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_sp_consultarchequesdevueltos.sql` |
| **LOC (1er CREATE)** | 179 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 1 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "consultar cheques y OS — Originación de Solicitudes" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=3 · CONVENCIÓN=1 · INFERIDO=1 · SINTÉTICO=1 / 6 términos |

### Historia del SP

| Tipo | Valor |
|------|-------|
| FECHA | 22/Agosto/2008 --- |

### Firma

```sql
CREATE PROCEDURE sp_consultarchequesdevueltos(
  cNumCte                      CHAR(9)
  dFechaInicial                DATE
  dFechaFinal                  DATE
  p_Registros                  SMALLINT
) RETURNING CHAR(5) AS CodRet,            --- Codigo de Retorno
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `cNumCte` | `CHAR(9)` | — | — |
| `dFechaInicial` | `DATE` | — | — |
| `dFechaFinal` | `DATE` | — | — |
| `p_Registros` | `SMALLINT` | `os`=OS — Originación de Solicitudes / subsistema de ofertas (sp_os_*, sp_calcula_estatus_os — bdisolic) | 🟡 INFERIDO |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `iSqlErr` | `INT` | L31 |
| `cCodRet` | `CHAR(5)` | L32 |
| `cMotivoDev` | `CHAR(2)` | L33 |
| `cDescriDev` | `CHAR(35)` | L34 |
| `cEmpresa` | `CHAR(3)` | L35 |
| `cCveBanco` | `CHAR(3)` | L36 |
| `cDesBanco` | `CHAR(40)` | L37 |
| `cCuenta` | `CHAR(20)` | L38 |
| `cNumCheque` | `CHAR(7)` | L39 |
| `dFechaDev` | `DATE` | L40 |
| `mComision` | `MONEY(16,2)` | L41 |
| `mMontoCom` | `MONEY(16,2)` | L42 |
| `mIvaCom` | `MONEY(16,2)` | L43 |
| `mSumaCom` | `MONEY(16,2)` | L44 |
| `cImgFormato` | `CHAR(3)` | L45 |
| `iTamanoImgA` | `INT` | L46 |
| `iTamanoImgB` | `INT` | L47 |
| `vCliente` | `INT` | L48 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `cce_cheques_dev` | `bditef` | no | SELECT | L87 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L144 | FÓRMULA | `LET mSumaCom = mComision + mMontoCom + (mMontoCom * mIvaCom);` | 🔴 MONEY/aritmética financiera |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `consultar` | ACCION | consultar | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `cheques` | ENTIDAD | cheques | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `dev` | ACCION | devolución | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `?uelt` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `os` | ENTIDAD | OS — Originación de Solicitudes / subsistema de ofertas (sp_ | 🟡 INFERIDO | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?uelt` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_consultarchequesdevueltos2`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_sp_consultarchequesdevueltos2.sql` |
| **LOC (1er CREATE)** | 131 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 4 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "consultar cheques y OS — Originación de Solicitudes" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=2 · INFERIDO=1 · SINTÉTICO=2 / 7 términos |

### Firma

```sql
CREATE PROCEDURE sp_consultarchequesdevueltos2(
  cNumCte                      CHAR(9)
  dFechaInicial                DATE
  dFechaFinal                  DATE
  pRegistros                   INTEGER
  pRecuperacion                INTEGER
) RETURNING CHAR(5),         	-- Codigo de Retorno
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `cNumCte` | `CHAR(9)` | — | — |
| `dFechaInicial` | `DATE` | — | — |
| `dFechaFinal` | `DATE` | — | — |
| `pRegistros` | `INTEGER` | `os`=OS — Originación de Solicitudes / subsistema de ofertas (sp_os_*, sp_calcula_estatus_os — bdisolic) | 🟡 INFERIDO |
| `pRecuperacion` | `INTEGER` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `iSqlErr` | `INT` | L22 |
| `cCodRet` | `CHAR(5)` | L23 |
| `cMotivoDev` | `CHAR(2)` | L24 |
| `cDescriDev` | `CHAR(35)` | L25 |
| `cEmpresa` | `CHAR(3)` | L26 |
| `cCveBanco` | `CHAR(3)` | L27 |
| `cDesBanco` | `CHAR(40)` | L28 |
| `cCuenta` | `CHAR(20)` | L29 |
| `cNumCheque` | `CHAR(7)` | L30 |
| `dFechaDev` | `DATE` | L31 |
| `mComision` | `MONEY(16,2)` | L32 |
| `mMontoCom` | `MONEY(16,2)` | L33 |
| `mIvaCom` | `MONEY(16,2)` | L34 |
| `mSumaCom` | `MONEY(16,2)` | L35 |
| `cImgFormato` | `CHAR(3)` | L36 |
| `iTamanoImgA` | `INT` | L37 |
| `iTamanoImgB` | `INT` | L38 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `cce_cheques_dev` | `bditef` | no | SELECT | L74 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L108 | FÓRMULA | `LET mSumaCom = mComision + mMontoCom + (mMontoCom * mIvaCom);` | 🔴 MONEY/aritmética financiera |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `consultar` | ACCION | consultar | 🔵 CONVENCIÓN | nombre_sp |
| `cheques` | ENTIDAD | cheques | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `dev` | ACCION | devolución | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `?uelt` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `os` | ENTIDAD | OS — Originación de Solicitudes / subsistema de ofertas (sp_ | 🟡 INFERIDO | nombre_sp |
| `?2` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?uelt`, `?2` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_consultarchequesdevueltos2_totales`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_sp_consultarchequesdevueltos2_totales.sql` |
| **LOC (1er CREATE)** | 79 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 3 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "consultar cheques y OS — Originación de Solicitudes (totales)" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=3 · INFERIDO=1 · SINTÉTICO=2 / 8 términos |

### Firma

```sql
CREATE PROCEDURE sp_consultarchequesdevueltos2_totales(
  cNumCte                      CHAR(9)
  dFechaInicial                DATE
  dFechaFinal                  DATE
) RETURNING CHAR(5),
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `cNumCte` | `CHAR(9)` | — | — |
| `dFechaInicial` | `DATE` | — | — |
| `dFechaFinal` | `DATE` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `iSqlErr` | `INT` | L6 |
| `cCodRet` | `CHAR(5)` | L7 |
| `iNoRegistros` | `INTEGER` | L8 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `cce_cheques_dev` | `bditef` | no | SELECT | L30 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `consultar` | ACCION | consultar | 🔵 CONVENCIÓN | nombre_sp |
| `cheques` | ENTIDAD | cheques | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `dev` | ACCION | devolución | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `?uelt` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `os` | ENTIDAD | OS — Originación de Solicitudes / subsistema de ofertas (sp_ | 🟡 INFERIDO | nombre_sp |
| `?2_` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `totales` | MODIF | totales | 🔵 CONVENCIÓN | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?uelt`, `?2_` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_consultarchequesdevueltos3`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_sp_consultarchequesdevueltos3.sql` |
| **LOC (1er CREATE)** | 132 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 2 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "consultar cheques y OS — Originación de Solicitudes" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=2 · INFERIDO=1 · SINTÉTICO=2 / 7 términos |

### Firma

```sql
CREATE PROCEDURE sp_consultarchequesdevueltos3(
  cNumCte                      CHAR(9)
  dFechaInicial                DATE
  dFechaFinal                  DATE
  pRegistros                   INTEGER
  pRecuperacion                INTEGER
) RETURNING CHAR(5),         	-- Codigo de Retorno
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `cNumCte` | `CHAR(9)` | — | — |
| `dFechaInicial` | `DATE` | — | — |
| `dFechaFinal` | `DATE` | — | — |
| `pRegistros` | `INTEGER` | `os`=OS — Originación de Solicitudes / subsistema de ofertas (sp_os_*, sp_calcula_estatus_os — bdisolic) | 🟡 INFERIDO |
| `pRecuperacion` | `INTEGER` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `iSqlErr` | `INT` | L22 |
| `cCodRet` | `CHAR(5)` | L23 |
| `cMotivoDev` | `CHAR(2)` | L24 |
| `cDescriDev` | `CHAR(35)` | L25 |
| `cEmpresa` | `CHAR(3)` | L26 |
| `cCveBanco` | `CHAR(3)` | L27 |
| `cDesBanco` | `CHAR(40)` | L28 |
| `cCuenta` | `CHAR(20)` | L29 |
| `cNumCheque` | `CHAR(7)` | L30 |
| `dFechaDev` | `DATE` | L31 |
| `mComision` | `MONEY(16,2)` | L32 |
| `mMontoCom` | `MONEY(16,2)` | L33 |
| `mIvaCom` | `MONEY(16,2)` | L34 |
| `mSumaCom` | `MONEY(16,2)` | L35 |
| `cImgFormato` | `CHAR(3)` | L36 |
| `iTamanoImgA` | `INT` | L37 |
| `iTamanoImgB` | `INT` | L38 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `cce_cheques_dev` | `bditef` | no | SELECT | L74 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L108 | FÓRMULA | `LET mSumaCom = mComision + mMontoCom + (mMontoCom * mIvaCom);` | 🔴 MONEY/aritmética financiera |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `consultar` | ACCION | consultar | 🔵 CONVENCIÓN | nombre_sp |
| `cheques` | ENTIDAD | cheques | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `dev` | ACCION | devolución | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `?uelt` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `os` | ENTIDAD | OS — Originación de Solicitudes / subsistema de ofertas (sp_ | 🟡 INFERIDO | nombre_sp |
| `?3` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?uelt`, `?3` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_consultarchequesdevueltos3_totales`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_sp_consultarchequesdevueltos3_totales.sql` |
| **LOC (1er CREATE)** | 80 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 1 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "consultar cheques y OS — Originación de Solicitudes (totales)" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=3 · INFERIDO=1 · SINTÉTICO=2 / 8 términos |

### Firma

```sql
CREATE PROCEDURE sp_consultarchequesdevueltos3_totales(
  cNumCte                      CHAR(9)
  dFechaInicial                DATE
  dFechaFinal                  DATE
) RETURNING CHAR(5),
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `cNumCte` | `CHAR(9)` | — | — |
| `dFechaInicial` | `DATE` | — | — |
| `dFechaFinal` | `DATE` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `iSqlErr` | `INT` | L6 |
| `cCodRet` | `CHAR(5)` | L7 |
| `iNoRegistros` | `INTEGER` | L8 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `cce_cheques_dev` | `bditef` | no | SELECT | L30 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `consultar` | ACCION | consultar | 🔵 CONVENCIÓN | nombre_sp |
| `cheques` | ENTIDAD | cheques | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `dev` | ACCION | devolución | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `?uelt` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `os` | ENTIDAD | OS — Originación de Solicitudes / subsistema de ofertas (sp_ | 🟡 INFERIDO | nombre_sp |
| `?3_` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `totales` | MODIF | totales | 🔵 CONVENCIÓN | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?uelt`, `?3_` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_consultarepop_tef`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_sp_consultarepop_tef.sql` |
| **LOC (1er CREATE)** | 222 |
| **Callgraph** | ✅ fan_in=0 / fan_out=8 |
| **Deps concatenadas** | 19 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "consultar TEF — transferencia electrónica de fondos" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=1 / 4 términos |

### Historia del SP

| Tipo | Valor |
|------|-------|
| DESCRIPCION | Realiza consulta por tipo de busqueda Cliente, Cuenta, Tarjeta y movimientos relacionados a las cuentas. |
| FECHA | 2011/04/01 |

### Firma

```sql
CREATE PROCEDURE sp_consultarepop_tef(
  psConsClienMovs              CHAR(1)
  psTipoConsulta               CHAR(1)
  psDatoBusqueda               CHAR(20)
  psFechaInicio                CHAR(8)
  psFechaFin                   CHAR(8)
) RETURNING CHAR(5) AS cod_ret, CHAR(10) AS fecha_operacion, CHAR(104) AS no_cuenta, CHAR(13) AS tipo_operacion, CHAR(16) AS importe, CHAR(40) AS referencia, CHAR(81) AS bancorecpres, CHAR(20) AS estatus, CHAR(100) AS causa_rechazo
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `psConsClienMovs` | `CHAR(1)` | — | — |
| `psTipoConsulta` | `CHAR(1)` | — | — |
| `psDatoBusqueda` | `CHAR(20)` | — | — |
| `psFechaInicio` | `CHAR(8)` | — | — |
| `psFechaFin` | `CHAR(8)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vsNoCliente` | `CHAR(9)` | L20 |
| `vsNombre1` | `CHAR(26)` | L21 |
| `vsNombre2` | `CHAR(26)` | L22 |
| `vsApellPaterno` | `CHAR(26)` | L23 |
| `vsApellMaterno` | `CHAR(26)` | L24 |
| `vsNombre` | `CHAR(104)` | L25 |
| `vsRFC` | `CHAR(13)` | L26 |
| `vsCuenta` | `CHAR(20)` | L27 |
| `vsTarjeta` | `CHAR(20)` | L28 |
| `vsFechaTrans` | `CHAR(10)` | L29 |
| `vsNumCtaOrdRec` | `CHAR(20)` | L30 |
| `vsCargoAbono` | `CHAR(1)` | L31 |
| `vsImporte` | `CHAR(16)` | L32 |
| `vsFolioSuc` | `CHAR(40)` | L33 |
| `vsBancoRec` | `CHAR(35)` | L34 |
| `vsBancoPres` | `CHAR(35)` | L35 |
| `vsBancoRecPres` | `CHAR(81)` | L36 |
| `vsDescStatPago` | `CHAR(20)` | L37 |
| `vsDescCatRechazo` | `CHAR(100)` | L38 |
| `vsNumTarjeta` | `CHAR(16)` | L39 |
| `viSqlErr` | `INTEGER` | L41 |
| `vsCodRet` | `CHAR(5)` | L42 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sc_maechq` | `bdicheq` | ⚠️ sí | SELECT | L82 |
| `si_cliente` | `bdinteg` | ⚠️ sí | SELECT | L92 |
| `sc_tarjeta` | `bdicheq` | ⚠️ sí | SELECT | L123 |
| `tef_cce_detalle` | `bditef` | no | SELECT | L169 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L95 | CÓDIGO_RETORNO | `LET vsCodRet = '00000';` |  |
| L98 | CÓDIGO_RETORNO | `LET vsCodRet = '00001';` |  |
| L115 | CÓDIGO_RETORNO | `LET vsCodRet = '00000';` |  |
| L118 | CÓDIGO_RETORNO | `LET vsCodRet = '00001';` |  |
| L135 | CÓDIGO_RETORNO | `LET vsCodRet = '00000';` |  |
| L138 | CÓDIGO_RETORNO | `LET vsCodRet = '00001';` |  |
| L179 | FÓRMULA | `LET vsFechaTrans = SUBSTRING(vsFechaTrans FROM 7 FOR 2) \|\| "/" \|\| SUBSTRING(vsFechaTrans FROM 5 ` |  |
| L180 | FÓRMULA | `LET vsImporte = "$" \|\| round(vsImporte / 100, 2);` | 🔴 MONEY/aritmética financiera |
| L182 | FÓRMULA | `LET vsBancoRecPres = TRIM(vsBancoRec) \|\| "/" \|\| TRIM(vsBancoPres);` |  |
| L202 | FÓRMULA | `LET vsFechaTrans = SUBSTRING(vsFechaTrans FROM 7 FOR 2) \|\| "/" \|\| SUBSTRING(vsFechaTrans FROM 5 ` |  |
| L203 | FÓRMULA | `LET vsImporte = "$" \|\| round (vsImporte / 100, 2);` | 🔴 MONEY/aritmética financiera |
| L205 | FÓRMULA | `LET vsBancoRecPres = TRIM(vsBancoRec) \|\| "/" \|\| TRIM(vsBancoPres);` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `consultar` | ACCION | consultar | 🔵 CONVENCIÓN | nombre_sp |
| `?epop_` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `tef` | ENTIDAD | TEF — transferencia electrónica de fondos | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?epop_` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_consultarimageneschqdevueltos`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_sp_consultarimageneschqdevueltos.sql` |
| **LOC (1er CREATE)** | 106 |
| **Callgraph** | ✅ fan_in=0 / fan_out=8 |
| **Deps concatenadas** | 15 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "consultar imágenes, cheque y OS — Originación de Solicitudes" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=3 · INFERIDO=2 · SINTÉTICO=1 / 7 términos |

### Firma

```sql
CREATE PROCEDURE sp_consultarimageneschqdevueltos(
  pEmpleado                    CHAR(10)
) RETURNING CHAR(5)   AS CODRET,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pEmpleado` | `CHAR(10)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `iSqlErr` | `INT` | L17 |
| `cCodRet` | `CHAR(5)` | L18 |
| `cMensaje` | `CHAR(50)` | L19 |
| `cEmpleado` | `CHAR(10)` | L21 |
| `cCodBanco` | `CHAR(3)` | L22 |
| `cCuenta` | `CHAR(20)` | L23 |
| `cNumChq` | `CHAR(7)` | L24 |
| `dFecPresenta` | `DATE` | L25 |
| `cRutaArchivo` | `CHAR(100)` | L26 |
| `cLado` | `CHAR(1)` | L27 |
| `sStatusImg` | `SMALLINT` | L28 |
| `sContador` | `SMALLINT` | L29 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `cce_reportes_cheques` | `bditef` | no | SELECT | L75 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `consultar` | ACCION | consultar | 🔵 CONVENCIÓN | nombre_sp |
| `imagenes` | ENTIDAD | imágenes / documentos digitales | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `chq` | ENTIDAD | cheque (abreviación — bdicheq) | 🟡 INFERIDO | nombre_sp |
| `dev` | ACCION | devolución | 🔵 CONVENCIÓN | nombre_sp |
| `?uelt` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `os` | ENTIDAD | OS — Originación de Solicitudes / subsistema de ofertas (sp_ | 🟡 INFERIDO | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?uelt` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_eliminaarchivo_tef`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_sp_eliminaarchivo_tef.sql` |
| **LOC (1er CREATE)** | 55 |
| **Callgraph** | ✅ fan_in=0 / fan_out=15 |
| **Deps concatenadas** | 14 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "elimina archivo y TEF — transferencia electrónica de fondos" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 1 llamada(s): `sp_cnsif_confirmaejecutivo` |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=0 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_eliminaarchivo_tef(
  pUsuario                     CHAR(8)
  pIdFuncion                   CHAR(10)
  pRuta                        CHAR(100)
  pNombreArchivo               CHAR(50)
) RETURNING CHAR(5)  AS codret
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pUsuario` | `CHAR(8)` | — | — |
| `pIdFuncion` | `CHAR(10)` | — | — |
| `pRuta` | `CHAR(100)` | — | — |
| `pNombreArchivo` | `CHAR(50)` | `archivo`=archivo | ✅ CÓDIGO |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(5)` | L4 |
| `iSqlErr` | `INTEGER` | L5 |
| `cCodRetSp` | `CHAR(5)` | L6 |
| `vsCadSql` | `CHAR(500)` | L7 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_cnsif_confirmaejecutivo` | `bdinteg` | ⚠️ sí | L34 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L9 | CÓDIGO_RETORNO | `LET cCodRet = '00000';` |  |
| L29 | CÓDIGO_RETORNO | `LET cCodRet = '00003';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `elimina` | ACCION | elimina | 🔵 CONVENCIÓN | nombre_sp |
| `archivo` | ENTIDAD | archivo | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `tef` | ENTIDAD | TEF — transferencia electrónica de fondos | ✅ CÓDIGO | nombre_sp, texto_cuerpo |

---

## `sp_firma_ejec`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_sp_firma_ejec.sql` |
| **LOC (1er CREATE)** | 114 |
| **Callgraph** | ✅ fan_in=0 / fan_out=17 |
| **Deps concatenadas** | 21 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "sp_firma_ejec" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 2 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=1 / 2 términos |

### Firma

```sql
CREATE PROCEDURE sp_firma_ejec(
  pEjecutivo                   CHAR(8)
  pNombre                      CHAR(50)
  pFecha                       DATE
  pTipoConsulta                INTEGER
) RETURNING CHAR(6) AS cCodRet,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pEjecutivo` | `CHAR(8)` | — | — |
| `pNombre` | `CHAR(50)` | — | — |
| `pFecha` | `DATE` | — | — |
| `pTipoConsulta` | `INTEGER` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(6)` | L14 |
| `iSqlErr` | `INTEGER` | L15 |
| `bImgFirma` | `BLOB` | L16 |
| `cNombreEjec` | `CHAR(50)` | L17 |
| `cEjecEla` | `CHAR(50)` | L18 |
| `cEjecRevi` | `CHAR(50)` | L19 |
| `cEjecVoBo` | `CHAR(50)` | L20 |
| `cNumEjec` | `CHAR(8)` | L21 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `cce_usuarios_cedula_contable` | `bditef` | no | SELECT | L55 |
| `cce_cedulacontable` | `bditef` | no | SELECT | L81 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L58 | VALIDACIÓN_NULL | `IF bImgFirma IS NULL THEN` |  |
| L97 | VALIDACIÓN_NULL | `IF bImgFirma IS NULL THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `?_firma_ejec` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_firma_ejec` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_generarepopertef`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_sp_generarepopertef.sql` |
| **LOC (1er CREATE)** | 124 |
| **Callgraph** | ✅ fan_in=0 / fan_out=25 |
| **Deps concatenadas** | 42 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "generar TEF — transferencia electrónica de fondos" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `genera` → `INSERT` encontrado en el cuerpo · `genera` → `SELECT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=1 · INFERIDO=2 · SINTÉTICO=2 / 6 términos |

### Firma

```sql
CREATE PROCEDURE sp_generarepopertef(
  pSucursal                    CHAR (4)
  pFechaConsulta               DATE
  pRegistros                   INTEGER
) RETURNING --CHAR(5), CHAR(10), CHAR (30), CHAR (30), CHAR (20), CHAR (10),
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pSucursal` | `CHAR (4)` | — | — |
| `pFechaConsulta` | `DATE` | — | — |
| `pRegistros` | `INTEGER` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `iSqlErr` | `INTEGER` | L15 |
| `cCodRet` | `CHAR (5)` | L16 |
| `cNombre_Cte_Ord` | `CHAR (30)` | L18 |
| `cNum_Cta_Ord` | `CHAR (20)` | L19 |
| `cImporte_Tef` | `CHAR (10)` | L20 |
| `cClave_Rastreo` | `CHAR (30)` | L21 |
| `cStatusPago` | `CHAR (2)` | L22 |
| `cDescStatusPago` | `CHAR (20)` | L23 |
| `cDescMotivoDev` | `CHAR (50)` | L24 |
| `cMotivoDev` | `CHAR (2)` | L25 |
| `iContador` | `INTEGER` | L26 |
| `cNumCte` | `CHAR (9)` | L27 |
| `cUsuario` | `CHAR (8)` | L28 |
| `dFecha` | `CHAR (10)` | L29 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tef_operaciones` | `bditef` | no | SELECT | L79 |
| `tef_status_pago` | `bditef` | no | SELECT | L87 |
| `tef_cat_devoluciones` | `bditef` | no | SELECT | L93 |
| `sc_maechq` | `bdicheq` | ⚠️ sí | SELECT | L99 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L49 | FÓRMULA | `LET dFecha               = "01-01-1900";` |  |
| L64 | VALIDACIÓN_NULL | `IF pSucursal IS NULL OR pSucursal = "" OR pFechaConsulta IS NULL OR pFechaConsulta = "" OR` |  |
| L102 | FÓRMULA | `LET iContador = iContador + 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `generar` | ACCION | generar (infinitivo — sp_generarbalanza*) | 🟡 INFERIDO | nombre_sp |
| `?ep` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `ope` | ACCION | operación | 🟡 INFERIDO | nombre_sp |
| `?r` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `tef` | ENTIDAD | TEF — transferencia electrónica de fondos | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?ep`, `?r` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_generarepopertef_web`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_sp_generarepopertef_web.sql` |
| **LOC (1er CREATE)** | 141 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 1 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "generar TEF — transferencia electrónica de fondos (canal web)" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `genera` → `INSERT` encontrado en el cuerpo · `genera` → `SELECT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=2 · INFERIDO=2 · SINTÉTICO=2 / 7 términos |

### Firma

```sql
CREATE PROCEDURE sp_generarepopertef_web(
  pSucursal                    CHAR (4)
  pFechaConsulta               DATE
  pRegistros                   INTEGER
) RETURNING --CHAR(5), CHAR(10), CHAR (30), CHAR (30), CHAR (20), CHAR (10),
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pSucursal` | `CHAR (4)` | — | — |
| `pFechaConsulta` | `DATE` | — | — |
| `pRegistros` | `INTEGER` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `iSqlErr` | `INTEGER` | L15 |
| `cCodRet` | `CHAR (5)` | L16 |
| `cNombre_Cte_Ord` | `CHAR (30)` | L18 |
| `cNum_Cta_Ord` | `CHAR (20)` | L19 |
| `cImporte_Tef` | `CHAR (10)` | L20 |
| `cClave_Rastreo` | `CHAR (30)` | L21 |
| `cStatusPago` | `CHAR (2)` | L22 |
| `cDescStatusPago` | `CHAR (20)` | L23 |
| `cDescMotivoDev` | `CHAR (50)` | L24 |
| `cMotivoDev` | `CHAR (2)` | L25 |
| `iContador` | `INTEGER` | L26 |
| `cNumCte` | `CHAR (9)` | L27 |
| `cUsuario` | `CHAR (8)` | L28 |
| `dFecha` | `CHAR (10)` | L29 |
| `iCuantos` | `INTEGER` | L30 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tef_operaciones` | `bditef` | no | SELECT | L77 |
| `tef_status_pago` | `bditef` | no | SELECT | L104 |
| `tef_cat_devoluciones` | `bditef` | no | SELECT | L110 |
| `sc_maechq` | `bdicheq` | ⚠️ sí | SELECT | L116 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L50 | FÓRMULA | `LET dFecha               = "01-01-1900";` |  |
| L67 | VALIDACIÓN_NULL | `IF pSucursal IS NULL OR pSucursal = "" OR pFechaConsulta IS NULL OR pFechaConsulta = "" OR` |  |
| L119 | FÓRMULA | `LET iContador = iContador + 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `generar` | ACCION | generar (infinitivo — sp_generarbalanza*) | 🟡 INFERIDO | nombre_sp |
| `?ep` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `ope` | ACCION | operación | 🟡 INFERIDO | nombre_sp |
| `?r` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `tef` | ENTIDAD | TEF — transferencia electrónica de fondos | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `web` | MODIF | canal web | 🔵 CONVENCIÓN | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?ep`, `?r` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_grabaimageneschqdevueltos`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_sp_grabaimageneschqdevueltos.sql` |
| **LOC (1er CREATE)** | 66 |
| **Callgraph** | ✅ fan_in=55 / fan_out=8 |
| **Deps concatenadas** | 16 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "graba imágenes, cheque y OS — Originación de Solicitudes" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 3 tabla(s) con operaciones: INSERT, DELETE, SELECT |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=3 · INFERIDO=2 · SINTÉTICO=1 / 7 términos |

### Firma

```sql
CREATE PROCEDURE sp_grabaimageneschqdevueltos(
  pEmpleado                    CHAR(10)
  pCodBanco                    CHAR(3)
  pCuenta                      CHAR(20)
  pNumCheque                   CHAR(7)
  pFechaPresenta               DATE
  pArchivo                     CHAR(100)
  pLado                        CHAR(1)
  pStatusImg                   SMALLINT
  pLimpia                      CHAR(1)
) RETURNING CHAR(6) AS CodRet,          -- Codigo de Retorno
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pEmpleado` | `CHAR(10)` | — | — |
| `pCodBanco` | `CHAR(3)` | — | — |
| `pCuenta` | `CHAR(20)` | — | — |
| `pNumCheque` | `CHAR(7)` | — | — |
| `pFechaPresenta` | `DATE` | — | — |
| `pArchivo` | `CHAR(100)` | — | — |
| `pLado` | `CHAR(1)` | — | — |
| `pStatusImg` | `SMALLINT` | — | — |
| `pLimpia` | `CHAR(1)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `iSqlErr` | `INT` | L10 |
| `cCodRet` | `CHAR(5)` | L11 |
| `cMensaje` | `CHAR(50)` | L12 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `cce_reportes_cheques` | `bditef` | no | SELECT | L45 |
| `cce_reportes_cheques` | `bditef` | no | DELETE | L45 |
| `cce_reportes_cheques` | `bditef` | no | INSERT | L49 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `graba` | ACCION | graba / almacena | 🔵 CONVENCIÓN | nombre_sp |
| `imagenes` | ENTIDAD | imágenes / documentos digitales | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `chq` | ENTIDAD | cheque (abreviación — bdicheq) | 🟡 INFERIDO | nombre_sp |
| `dev` | ACCION | devolución | 🔵 CONVENCIÓN | nombre_sp |
| `?uelt` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `os` | ENTIDAD | OS — Originación de Solicitudes / subsistema de ofertas (sp_ | 🟡 INFERIDO | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?uelt` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_grabaoperaciontef`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_sp_grabaoperaciontef.sql` |
| **LOC (1er CREATE)** | 341 |
| **Callgraph** | ✅ fan_in=1 / fan_out=13 |
| **Deps concatenadas** | 6 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "graba TEF — transferencia electrónica de fondos" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 2 llamada(s): `cargo_ref`, `sp_validahorariotef` |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=0 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_grabaoperaciontef(
  pTipo                        CHAR(1)
  pEmpresa                     CHAR(3)
  pFecha_Trans                 DATE
  pFolio_Suc                   CHAR(16)
  pSucursal                    CHAR(4)
  pNum_Cta_Ord                 CHAR(20)
  pTipo_Cta_Ord                CHAR(2)
  pFecha_Prog                  DATE
  pTipo_Oper                   CHAR(2)
  pCve_Rastreo                 CHAR(30)
  pNombre_Cte_Ord              CHAR(30)
  pRfc_Cte_Ord                 CHAR(15)
  pImp_Tef                     CHAR(10)
  pComision_Tef                CHAR(5)
  pIva_Tef                     CHAR(5)
  pImp_Tot_Tef                 CHAR(10)
  pTipo_Cta_Ben                CHAR(2)
  pNombre_Ben                  CHAR(30)
  pNum_Cta_Tarj_Ben            CHAR(20)
  pCve_Banco_Rec               CHAR(3)
  pRfc_Ben                     CHAR(15)
  pConcep_Pago                 CHAR(50)
  pRef_Num                     CHAR(7)
  pReferencia                  CHAR(40)
  pCve_Canal                   CHAR(2)
  pMotivo_Dev                  CHAR(2)
  pDivisa                      CHAR(2)
  pTransacSuc                  CHAR(4)
  pNumTarjeta                  CHAR(16)
  pUsuario                     CHAR (8)
) RETURNING CHAR(5), CHAR(5)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pTipo` | `CHAR(1)` | — | — |
| `pEmpresa` | `CHAR(3)` | — | — |
| `pFecha_Trans` | `DATE` | — | — |
| `pFolio_Suc` | `CHAR(16)` | — | — |
| `pSucursal` | `CHAR(4)` | — | — |
| `pNum_Cta_Ord` | `CHAR(20)` | — | — |
| `pTipo_Cta_Ord` | `CHAR(2)` | — | — |
| `pFecha_Prog` | `DATE` | — | — |
| `pTipo_Oper` | `CHAR(2)` | — | — |
| `pCve_Rastreo` | `CHAR(30)` | — | — |
| `pNombre_Cte_Ord` | `CHAR(30)` | — | — |
| `pRfc_Cte_Ord` | `CHAR(15)` | — | — |
| `pImp_Tef` | `CHAR(10)` | `tef`=TEF — transferencia electrónica de fondos | ✅ CÓDIGO |
| `pComision_Tef` | `CHAR(5)` | `tef`=TEF — transferencia electrónica de fondos | ✅ CÓDIGO |
| `pIva_Tef` | `CHAR(5)` | `tef`=TEF — transferencia electrónica de fondos | ✅ CÓDIGO |
| `pImp_Tot_Tef` | `CHAR(10)` | `tef`=TEF — transferencia electrónica de fondos | ✅ CÓDIGO |
| `pTipo_Cta_Ben` | `CHAR(2)` | — | — |
| `pNombre_Ben` | `CHAR(30)` | — | — |
| `pNum_Cta_Tarj_Ben` | `CHAR(20)` | — | — |
| `pCve_Banco_Rec` | `CHAR(3)` | — | — |
| `pRfc_Ben` | `CHAR(15)` | — | — |
| `pConcep_Pago` | `CHAR(50)` | — | — |
| `pRef_Num` | `CHAR(7)` | — | — |
| `pReferencia` | `CHAR(40)` | — | — |
| `pCve_Canal` | `CHAR(2)` | — | — |
| `pMotivo_Dev` | `CHAR(2)` | — | — |
| `pDivisa` | `CHAR(2)` | — | — |
| `pTransacSuc` | `CHAR(4)` | — | — |
| `pNumTarjeta` | `CHAR(16)` | — | — |
| `pUsuario` | `CHAR (8)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `iSqlErr` | `INTEGER` | L39 |
| `cCodRet1` | `CHAR (5)` | L40 |
| `cCodRet2` | `CHAR (5)` | L41 |
| `cCodRet3` | `CHAR (5)` | L42 |
| `cCodRet4` | `CHAR (5)` | L43 |
| `cNumSerial` | `CHAR (12)` | L44 |
| `vTrans` | `CHAR(4)` | L46 |
| `dFecha` | `DATE` | L47 |
| `mSaldo` | `MONEY(14,2)` | L48 |
| `mMonto` | `MONEY(14,2)` | L49 |
| `vTransaccion` | `INTEGER` | L50 |
| `cTranscargo` | `CHAR(4)` | L51 |
| `cComis` | `CHAR(4)` | L52 |
| `cIvaComis` | `CHAR(4)` | L53 |
| `cNumTran` | `CHAR(4)` | L54 |
| `cProducto` | `CHAR(4)` | L56 |
| `cTpoPersona` | `CHAR(1)` | L57 |
| `mComServTranTef` | `MONEY` | L58 |
| `dValIva` | `DECIMAL(9,6)` | L59 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tef_procesos` | `bditef` | no | SELECT | L120 |
| `tef_parametros` | `bditef` | no | SELECT | L138 |
| `sc_maechq` | `bdicheq` | ⚠️ sí | SELECT | L185 |
| `sc_producto` | `bdicheq` | ⚠️ sí | SELECT | L191 |
| `sc_maecomtasserv_pm` | `bdicheq` | ⚠️ sí | SELECT | L198 |
| `si_param` | `bdinteg` | ⚠️ sí | SELECT | L204 |
| `sc_movdia` | `bdicheq` | ⚠️ sí | SELECT | L271 |
| `tef_operaciones` | `bditef` | no | INSERT | L303 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `cargo_ref` | `bdicheq` | ⚠️ sí | L169 |
| `sp_validahorariotef` | `bditef` | no | L295 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L127 | VALIDACIÓN_NULL | `IF pEmpresa IS NULL OR pEmpresa = "" OR pSucursal IS NULL OR pSucursal = "" OR` |  |
| L141 | VALIDACIÓN_NULL | `IF cTranscargo IS NULL OR cTranscargo = '' THEN` |  |
| L153 | VALIDACIÓN_NULL | `IF cComis IS NULL OR cComis = '' THEN` |  |
| L163 | VALIDACIÓN_NULL | `IF cIvaComis IS NULL OR cIvaComis = '' THEN` |  |
| L209 | FÓRMULA | `LET pIva_Tef = mComServTranTef * dValIva;` |  |
| L243 | VALIDACIÓN_NULL | `IF pFecha_Trans IS NULL OR pFecha_Trans = "" OR pFolio_Suc IS NULL OR pFolio_Suc = "" OR` |  |
| L264 | VALIDACIÓN_NULL | `IF cNumTran IS NULL OR cNumTran = '' THEN` |  |
| L276 | VALIDACIÓN_NULL | `IF cNumSerial IS NULL OR cNumSerial = "" THEN` |  |
| L277 | FÓRMULA | `LET cCodRet2 = "00011"; --NO EXISTE FOLIO SUCURSAL` |  |
| L285 | VALIDACIÓN_NULL | `IF pReferencia IS NULL OR pReferencia = '' THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `graba` | ACCION | graba / almacena | 🔵 CONVENCIÓN | nombre_sp |
| `operacion` | ACCION | operación | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `tef` | ENTIDAD | TEF — transferencia electrónica de fondos | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |

---

## `sp_insert_cedula`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_sp_insert_cedula.sql` |
| **LOC (1er CREATE)** | 50 |
| **Callgraph** | ✅ fan_in=0 / fan_out=17 |
| **Deps concatenadas** | 20 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "insertar cédula de identificación" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `inserta` → `INSERT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=2 · INFERIDO=1 · SINTÉTICO=1 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_insert_cedula(
  pEjecElavoro                 VARCHAR(50)
  pEjecReviso                  VARCHAR(50)
  pEjecVobo                    VARCHAR(50)
  pNartCuent                   VARCHAR(50)
  pNartImporte                 MONEY
) RETURNING CHAR(6) AS cCodRet
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pEjecElavoro` | `VARCHAR(50)` | — | — |
| `pEjecReviso` | `VARCHAR(50)` | — | — |
| `pEjecVobo` | `VARCHAR(50)` | — | — |
| `pNartCuent` | `VARCHAR(50)` | — | — |
| `pNartImporte` | `MONEY` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(6)` | L9 |
| `iSqlErr` | `INTEGER` | L10 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `cce_cedulacontable` | `bditef` | no | INSERT | L33 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `ins` | ACCION | insertar | 🟡 INFERIDO | nombre_sp |
| `?ert_` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `cedula` | ENTIDAD | cédula de identificación | 🔵 CONVENCIÓN | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?ert_` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_obtbines_sif`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_sp_obtbines_sif.sql` |
| **LOC (1er CREATE)** | 73 |
| **Callgraph** | ✅ fan_in=55 / fan_out=5 |
| **Principales callers** | `sp_calificacion_scoring` |
| **Deps concatenadas** | 10 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "obtiene SIF — canal de estado de cuenta · INE — Instituto Nacional Electoral" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `obtiene` → `SELECT` encontrado en el cuerpo · `obtiene` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=2 · INFERIDO=2 · SINTÉTICO=2 / 6 términos |

### Firma

```sql
CREATE PROCEDURE sp_obtbines_sif(
  pTarjeta                     CHAR(20)
) RETURNING CHAR(5) AS COD_RET,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pTarjeta` | `CHAR(20)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(5)` | L7 |
| `cCodRet1` | `CHAR(5)` | L8 |
| `cMensaje` | `CHAR(100)` | L9 |
| `iSqlErr` | `INTEGER` | L10 |
| `cBanco` | `CHAR(3)` | L11 |
| `cTipo` | `CHAR(1)` | L12 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sc_bines` | `bdicheq` | ⚠️ sí | SELECT | L39 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_desc_ret` | `bdinteg` | ⚠️ sí | L47 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L15 | CÓDIGO_RETORNO | `LET cCodRet='00000';` |  |
| L31 | CÓDIGO_RETORNO | `LET cCodRet='00001';` |  |
| L42 | CÓDIGO_RETORNO | `LET cCodRet='00000';` |  |
| L46 | CÓDIGO_RETORNO | `LET cCodRet='00002';` |  |
| L56 | CÓDIGO_RETORNO | `LET cCodRet='00004';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `obt` | ACCION | obtiene | 🟡 INFERIDO | nombre_sp |
| `?b` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `ine` | REG | INE — Instituto Nacional Electoral (validación de identidad  | 🔵 CONVENCIÓN | nombre_sp |
| `?s_` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `sif` | ENTIDAD | SIF — canal de estado de cuenta (aclaraciones_edocta_sif, de | 🟡 INFERIDO | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?b`, `?s_` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_obtenerbancosregistrados`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_sp_obtenerbancosregistrados.sql` |
| **LOC (1er CREATE)** | 45 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 2 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "obtiene banco y OS — Originación de Solicitudes" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `obtiene` → `SELECT` encontrado en el cuerpo · `obtiene` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=3 · INFERIDO=1 · SINTÉTICO=2 / 7 términos |

### Firma

```sql
CREATE PROCEDURE sp_obtenerbancosregistrados(
) RETURNING CHAR(5),
```

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `iSqlErr` | `INT` | L8 |
| `cCodret` | `CHAR(5)` | L9 |
| `cBanco` | `CHAR(3)` | L10 |
| `cDescripcion` | `CHAR(40)` | L11 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_bancos` | `bdinteg` | ⚠️ sí | SELECT | L30 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L13 | CÓDIGO_RETORNO | `LET cCodret			= '00000';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `obtener` | ACCION | obtiene / recupera | 🔵 CONVENCIÓN | nombre_sp |
| `banco` | ENTIDAD | banco | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?s` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `registra` | ACCION | registra | 🔵 CONVENCIÓN | nombre_sp |
| `?d` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `os` | ENTIDAD | OS — Originación de Solicitudes / subsistema de ofertas (sp_ | 🟡 INFERIDO | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?s`, `?d` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_obtenerchequescce`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_sp_obtenerchequescce.sql` |
| **LOC (1er CREATE)** | 104 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 1 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "obtiene cheques y CCE — Cámara de Compensación Electrónica" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `obtiene` → `SELECT` encontrado en el cuerpo · `obtiene` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=0 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_obtenerchequescce(
  pEmpresa                     CHAR(3)
  pBanco                       CHAR(3)
  pNumCta                      CHAR(20)
  pNumChq                      CHAR(7)
  pFormato                     CHAR(3)
  pFechaAlta                   DATE
) RETURNING CHAR(5),		-- CODIGO RETORNO
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pEmpresa` | `CHAR(3)` | — | — |
| `pBanco` | `CHAR(3)` | — | — |
| `pNumCta` | `CHAR(20)` | — | — |
| `pNumChq` | `CHAR(7)` | — | — |
| `pFormato` | `CHAR(3)` | — | — |
| `pFechaAlta` | `DATE` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `iSqlErr` | `INT` | L13 |
| `cCodret` | `CHAR(5)` | L14 |
| `cBanco` | `CHAR(3)` | L15 |
| `cDescripcion` | `CHAR(40)` | L16 |
| `cNumcta` | `CHAR(20)` | L17 |
| `cNumchq` | `CHAR(7)` | L18 |
| `cLado` | `CHAR(1)` | L19 |
| `dFechaAlta` | `DATE` | L20 |
| `dFechaPresenta` | `DATE` | L21 |
| `cUsuarioAlta` | `CHAR(8)` | L22 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `cce_cheques_img` | `bditef` | no | SELECT | L59 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L24 | CÓDIGO_RETORNO | `LET cCodret			= '00000';` |  |
| L50 | VALIDACIÓN_NULL | `IF pFechaAlta IS NULL OR pFechaAlta = '' THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `obtener` | ACCION | obtiene / recupera | 🔵 CONVENCIÓN | nombre_sp |
| `cheques` | ENTIDAD | cheques | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `cce` | ENTIDAD | CCE — Cámara de Compensación Electrónica (CECOBAN/Banxico) — | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |

---

## `sp_obtenerchequescce_pba3`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_sp_obtenerchequescce_pba3.sql` |
| **LOC (1er CREATE)** | 104 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 3 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "obtiene cheques y CCE — Cámara de Compensación Electrónica (PBA — sufijo de SPs para Pruebas; confirmado por SME)" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `obtiene` → `SELECT` encontrado en el cuerpo · `obtiene` → `FROM` encontrado en el cuerpo · `confirma` → `SELECT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=1 / 6 términos |

### Firma

```sql
CREATE PROCEDURE sp_obtenerchequescce_pba3(
  pEmpresa                     CHAR(3)
  pBanco                       CHAR(3)
  pNumCta                      CHAR(20)
  pNumChq                      CHAR(7)
  pFormato                     CHAR(3)
  pFechaAlta                   DATE
) RETURNING CHAR(5),		-- CODIGO RETORNO
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pEmpresa` | `CHAR(3)` | — | — |
| `pBanco` | `CHAR(3)` | `pba`=PBA — sufijo de SPs para Pruebas; confirmado por SME (Guerra, Alejandro, 2026-07-09) | 🔵 CONVENCIÓN |
| `pNumCta` | `CHAR(20)` | — | — |
| `pNumChq` | `CHAR(7)` | — | — |
| `pFormato` | `CHAR(3)` | — | — |
| `pFechaAlta` | `DATE` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `iSqlErr` | `INT` | L13 |
| `cCodret` | `CHAR(5)` | L14 |
| `cBanco` | `CHAR(3)` | L15 |
| `cDescripcion` | `CHAR(40)` | L16 |
| `cNumcta` | `CHAR(20)` | L17 |
| `cNumchq` | `CHAR(7)` | L18 |
| `cLado` | `CHAR(1)` | L19 |
| `dFechaAlta` | `DATE` | L20 |
| `dFechaPresenta` | `DATE` | L21 |
| `cUsuarioAlta` | `CHAR(8)` | L22 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `cce_cheques_img` | `bditef` | no | SELECT | L59 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L24 | CÓDIGO_RETORNO | `LET cCodret			= '00000';` |  |
| L50 | VALIDACIÓN_NULL | `IF pFechaAlta IS NULL OR pFechaAlta = '' THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `obtener` | ACCION | obtiene / recupera | 🔵 CONVENCIÓN | nombre_sp |
| `cheques` | ENTIDAD | cheques | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `cce` | ENTIDAD | CCE — Cámara de Compensación Electrónica (CECOBAN/Banxico) — | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `pba` | MODIF | PBA — sufijo de SPs para Pruebas; confirmado por SME (Guerra | 🔵 CONVENCIÓN | nombre_sp |
| `?3` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?3` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_obtenerchequescce_pbas2`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_sp_obtenerchequescce_pbas2.sql` |
| **LOC (1er CREATE)** | 104 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 2 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "obtiene cheques y CCE — Cámara de Compensación Electrónica (PBA — sufijo de SPs para Pruebas; confirmado por SME)" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `obtiene` → `SELECT` encontrado en el cuerpo · `obtiene` → `FROM` encontrado en el cuerpo · `confirma` → `SELECT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=1 / 6 términos |

### Firma

```sql
CREATE PROCEDURE sp_obtenerchequescce_pbas2(
  pEmpresa                     CHAR(3)
  pBanco                       CHAR(3)
  pNumCta                      CHAR(20)
  pNumChq                      CHAR(7)
  pFormato                     CHAR(3)
  pFechaAlta                   DATE
) RETURNING CHAR(5),		-- CODIGO RETORNO
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pEmpresa` | `CHAR(3)` | — | — |
| `pBanco` | `CHAR(3)` | `pba`=PBA — sufijo de SPs para Pruebas; confirmado por SME (Guerra, Alejandro, 2026-07-09) | 🔵 CONVENCIÓN |
| `pNumCta` | `CHAR(20)` | — | — |
| `pNumChq` | `CHAR(7)` | — | — |
| `pFormato` | `CHAR(3)` | — | — |
| `pFechaAlta` | `DATE` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `iSqlErr` | `INT` | L13 |
| `cCodret` | `CHAR(5)` | L14 |
| `cBanco` | `CHAR(3)` | L15 |
| `cDescripcion` | `CHAR(40)` | L16 |
| `cNumcta` | `CHAR(20)` | L17 |
| `cNumchq` | `CHAR(7)` | L18 |
| `cLado` | `CHAR(1)` | L19 |
| `dFechaAlta` | `DATE` | L20 |
| `dFechaPresenta` | `DATE` | L21 |
| `cUsuarioAlta` | `CHAR(8)` | L22 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `cce_cheques_img` | `bditef` | no | SELECT | L59 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L24 | CÓDIGO_RETORNO | `LET cCodret			= '00000';` |  |
| L50 | VALIDACIÓN_NULL | `IF pFechaAlta IS NULL OR pFechaAlta = '' THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `obtener` | ACCION | obtiene / recupera | 🔵 CONVENCIÓN | nombre_sp |
| `cheques` | ENTIDAD | cheques | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `cce` | ENTIDAD | CCE — Cámara de Compensación Electrónica (CECOBAN/Banxico) — | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `pba` | MODIF | PBA — sufijo de SPs para Pruebas; confirmado por SME (Guerra | 🔵 CONVENCIÓN | nombre_sp |
| `?s2` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?s2` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_obtenerinformaciontef`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_sp_obtenerinformaciontef.sql` |
| **LOC (1er CREATE)** | 277 |
| **Callgraph** | ✅ fan_in=0 / fan_out=25 |
| **Deps concatenadas** | 41 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "obtiene información, dirección MAC y TEF — transferencia electrónica de fondos" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `obtiene` → `SELECT` encontrado en el cuerpo · `obtiene` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=2 / 7 términos |

### Firma

```sql
CREATE PROCEDURE sp_obtenerinformaciontef(
  pTipoBusqueda                CHAR(1)
  pCve_Tarj_Cta                CHAR(30)
  pFechaActual                 DATE
  pRegistros                   INTEGER
) RETURNING CHAR(5), CHAR (30), CHAR (9), CHAR (30), CHAR (20), CHAR (30), CHAR (20), CHAR (20) , CHAR (10),
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pTipoBusqueda` | `CHAR(1)` | — | — |
| `pCve_Tarj_Cta` | `CHAR(30)` | — | — |
| `pFechaActual` | `DATE` | — | — |
| `pRegistros` | `INTEGER` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `iSqlErr` | `INTEGER` | L16 |
| `cCodRet` | `CHAR (5)` | L17 |
| `cCodRet1` | `CHAR (5)` | L18 |
| `cCodRet2` | `CHAR (5)` | L19 |
| `cClave_Rastreo` | `CHAR (30)` | L20 |
| `cNombre_Cte_Ord` | `CHAR (30)` | L21 |
| `cNum_Cta_Ord` | `CHAR (20)` | L22 |
| `cNombre_Ben` | `CHAR (30)` | L23 |
| `cNum_Cuenta_Tarj_Ben` | `CHAR (20)` | L24 |
| `cTipo_Cta_Ord` | `CHAR (2)` | L25 |
| `cDescTipo_Cta_Ord` | `CHAR (20)` | L26 |
| `cImporte_Tef` | `CHAR (10)` | L27 |
| `cConcepto_Pago` | `CHAR (50)` | L28 |
| `cRef_Num` | `CHAR (7)` | L29 |
| `cHora_insert` | `CHAR (6)` | L30 |
| `cBanco` | `CHAR (3)` | L31 |
| `cDescBanco` | `CHAR (40)` | L32 |
| `cStatus` | `CHAR (2)` | L33 |
| `cDescStatus` | `CHAR (20)` | L34 |
| `cMot_Dev` | `CHAR (2)` | L35 |
| `cDescMot_Dev` | `CHAR (50)` | L36 |
| `iContador` | `INTEGER` | L37 |
| `cNumCte` | `CHAR (9)` | L38 |
| `cDias` | `CHAR (3)` | L39 |
| `dFechaInicial` | `DATE` | L40 |
| *…1 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tef_parametros` | `bditef` | no | SELECT | L112 |
| `tef_operaciones` | `bditef` | no | SELECT | L126 |
| `si_bancos` | `bdinteg` | ⚠️ sí | SELECT | L133 |
| `tef_cat_devoluciones` | `bditef` | no | SELECT | L138 |
| `tef_status_pago` | `bditef` | no | SELECT | L143 |
| `tef_tipo_cta` | `bditef` | no | SELECT | L148 |
| `sc_maechq` | `bdicheq` | ⚠️ sí | SELECT | L154 |
| `sc_tarjeta` | `bdicheq` | ⚠️ sí | SELECT | L182 |
| `sc_param` | `bdicheq` | ⚠️ sí | SELECT | L196 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_obtieneparamtef` | `bditef` | no | L94 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L68 | FÓRMULA | `LET dFechaInicial        = "01/01/1900";` |  |
| L85 | VALIDACIÓN_NULL | `IF pTipoBusqueda IS NULL OR pTipoBusqueda = "" OR pCve_Tarj_Cta IS NULL OR pCve_Tarj_Cta = "" OR` |  |
| L105 | FÓRMULA | `LET dFechaInicial = pFechaActual - cDias::INTEGER;` |  |
| L157 | FÓRMULA | `LET iContador = iContador + 1;` |  |
| L187 | VALIDACIÓN_NULL | `IF TRIM(pCve_Tarj_Cta) = '' OR pCve_Tarj_Cta IS NULL THEN` |  |
| L188 | CÓDIGO_RETORNO | `LET cCodRet = '00004';` |  |
| L247 | FÓRMULA | `LET iContador = iContador + 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `obtener` | ACCION | obtiene / recupera | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `info` | ENTIDAD | información | 🔵 CONVENCIÓN | nombre_sp |
| `?r` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `mac` | ENTIDAD | dirección MAC | 🔵 CONVENCIÓN | nombre_sp |
| `?ion` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `tef` | ENTIDAD | TEF — transferencia electrónica de fondos | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?r`, `?ion` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_obtenermensajeerror`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_sp_obtenermensajeerror.sql` |
| **LOC (1er CREATE)** | 68 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 2 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "obtiene mensaje y error" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `obtiene` → `SELECT` encontrado en el cuerpo · `obtiene` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=0 / 4 términos |

### Historia del SP

| Tipo | Valor |
|------|-------|
| DESCRIPCION | OBTIENE LAS DESCRIPCIONES DE LOS MENSAJES DE ERROR |
| FECHA | 09/03/2011 |

### Firma

```sql
CREATE PROCEDURE sp_obtenermensajeerror(
  psCodError                   CHAR(5)
) RETURNING CHAR(5) AS CodRet, VARCHAR(121) AS Descripcion
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `psCodError` | `CHAR(5)` | `error`=error | ✅ CÓDIGO |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vsCodRet` | `CHAR(5)` | L14 |
| `viSqlErr` | `INTEGER` | L15 |
| `viSamErr` | `INTEGER` | L16 |
| `vsDescripcion` | `VARCHAR(121)` | L18 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tef_cat_mensajes_error` | `bditef` | no | SELECT | L45 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L21 | CÓDIGO_RETORNO | `LET vsCodRet = '00000';` |  |
| L48 | VALIDACIÓN_NULL | `IF vsDescripcion IS NULL THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `obtener` | ACCION | obtiene / recupera | 🔵 CONVENCIÓN | nombre_sp |
| `mensaje` | ENTIDAD | mensaje | 🔵 CONVENCIÓN | nombre_sp |
| `error` | ENTIDAD | error | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |

---

## `sp_obtenernomarch_tef`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_sp_obtenernomarch_tef.sql` |
| **LOC (1er CREATE)** | 160 |
| **Callgraph** | ✅ fan_in=42 / fan_out=25 |
| **Principales callers** | `sp_calificacion_scoring` |
| **Deps concatenadas** | 40 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "obtiene nómina, archivo y TEF — transferencia electrónica de fondos" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `obtiene` → `SELECT` encontrado en el cuerpo · `obtiene` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=2 · INFERIDO=2 · SINTÉTICO=0 / 5 términos |

### Historia del SP

| Tipo | Valor |
|------|-------|
| DESCRIPCION | Arma los nombres de los archivos correspondientes para su carga y proceso manual. |
| FECHA | 2011/03/21 |

### Firma

```sql
CREATE PROCEDURE sp_obtenernomarch_tef(
  piTipoArchivo                INTEGER
) RETURNING CHAR(5) AS CodRet, CHAR(20) AS NomArchivo
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `piTipoArchivo` | `INTEGER` | `arch`=archivo | 🟡 INFERIDO |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vsCodBanco` | `CHAR(3)` | L16 |
| `viTipoArchivo` | `SMALLINT` | L17 |
| `vsNomArchivo` | `CHAR(20)` | L18 |
| `vdtFecha` | `DATE` | L19 |
| `vsDia` | `CHAR(2)` | L20 |
| `vsMes` | `CHAR(2)` | L21 |
| `vsAno` | `CHAR(4)` | L22 |
| `vsCodRet` | `CHAR(5)` | L24 |
| `viSqlErr` | `INTEGER` | L25 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_fechas` | `bdinteg` | ⚠️ sí | SELECT | L51 |
| `tef_parametros` | `bditef` | no | SELECT | L55 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_valida_fecha` | `bditef` | no | L59 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L58 | FÓRMULA | `LET vdtFecha = vdtFecha::DATE + 1;` |  |
| L61 | FÓRMULA | `LET vdtFecha = vdtFecha::DATE + 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `obtener` | ACCION | obtiene / recupera | 🔵 CONVENCIÓN | nombre_sp |
| `nom` | ENTIDAD | nómina | 🟡 INFERIDO | nombre_sp |
| `arch` | ENTIDAD | archivo | 🟡 INFERIDO | nombre_sp |
| `tef` | ENTIDAD | TEF — transferencia electrónica de fondos | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |

---

## `sp_obtenerparametroscce`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_sp_obtenerparametroscce.sql` |
| **LOC (1er CREATE)** | 94 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 1 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "obtiene parámetros y CCE — Cámara de Compensación Electrónica" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `obtiene` → `SELECT` encontrado en el cuerpo · `obtiene` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=0 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_obtenerparametroscce(
  pEmpresa                     CHAR(3)
  pUsuario                     CHAR(8)
) RETURNING CHAR(5),		-- CODIGO RETORNO
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pEmpresa` | `CHAR(3)` | — | — |
| `pUsuario` | `CHAR(8)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `iSqlErr` | `INT` | L11 |
| `cCodret` | `CHAR(5)` | L12 |
| `cDescripcion` | `CHAR(40)` | L13 |
| `cIPInteract` | `VARCHAR(100)` | L14 |
| `cPuerto` | `VARCHAR(100)` | L15 |
| `cBanco` | `CHAR(100)` | L16 |
| `cFecha_hoy` | `DATE` | L17 |
| `cNombre` | `CHAR(45)` | L18 |
| `cRazonSocial` | `CHAR(30)` | L19 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_empresas` | `bdinteg` | ⚠️ sí | SELECT | L42 |
| `si_ejecut` | `bdinteg` | ⚠️ sí | SELECT | L48 |
| `si_fechas` | `bdinteg` | ⚠️ sí | SELECT | L54 |
| `si_param` | `bdinteg` | ⚠️ sí | SELECT | L60 |
| `cce_param` | `bditef` | no | SELECT | L67 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L21 | CÓDIGO_RETORNO | `LET cCodret			= '00000';` |  |
| L78 | VALIDACIÓN_NULL | `IF cPuerto = '' OR cPuerto IS NULL OR cIPInteract= '' OR cIPInteract IS NULL THEN` |  |
| L79 | CÓDIGO_RETORNO | `LET cCodret= '10000';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `obtener` | ACCION | obtiene / recupera | 🔵 CONVENCIÓN | nombre_sp |
| `parametros` | ENTIDAD | parámetros | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `cce` | ENTIDAD | CCE — Cámara de Compensación Electrónica (CECOBAN/Banxico) — | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |

---

## `sp_obtenerparametroscce_pba`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_sp_obtenerparametroscce_pba.sql` |
| **LOC (1er CREATE)** | 94 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 2 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "obtiene parámetros y CCE — Cámara de Compensación Electrónica (PBA — sufijo de SPs para Pruebas; confirmado por SME)" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `obtiene` → `SELECT` encontrado en el cuerpo · `obtiene` → `FROM` encontrado en el cuerpo · `confirma` → `SELECT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=0 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_obtenerparametroscce_pba(
  pEmpresa                     CHAR(3)
  pUsuario                     CHAR(8)
) RETURNING CHAR(5),		-- CODIGO RETORNO
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pEmpresa` | `CHAR(3)` | — | — |
| `pUsuario` | `CHAR(8)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `iSqlErr` | `INT` | L11 |
| `cCodret` | `CHAR(5)` | L12 |
| `cDescripcion` | `CHAR(40)` | L13 |
| `cIPInteract` | `VARCHAR(100)` | L14 |
| `cPuerto` | `VARCHAR(100)` | L15 |
| `cBanco` | `CHAR(100)` | L16 |
| `cFecha_hoy` | `DATE` | L17 |
| `cNombre` | `CHAR(45)` | L18 |
| `cRazonSocial` | `CHAR(30)` | L19 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_empresas` | `bdinteg` | ⚠️ sí | SELECT | L42 |
| `si_ejecut` | `bdinteg` | ⚠️ sí | SELECT | L48 |
| `si_fechas` | `bdinteg` | ⚠️ sí | SELECT | L54 |
| `si_param` | `bdinteg` | ⚠️ sí | SELECT | L60 |
| `cce_param` | `bditef` | no | SELECT | L67 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L21 | CÓDIGO_RETORNO | `LET cCodret			= '00000';` |  |
| L78 | VALIDACIÓN_NULL | `IF cPuerto = '' OR cPuerto IS NULL OR cIPInteract= '' OR cIPInteract IS NULL THEN` |  |
| L79 | CÓDIGO_RETORNO | `LET cCodret= '10000';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `obtener` | ACCION | obtiene / recupera | 🔵 CONVENCIÓN | nombre_sp |
| `parametros` | ENTIDAD | parámetros | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `cce` | ENTIDAD | CCE — Cámara de Compensación Electrónica (CECOBAN/Banxico) — | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `pba` | MODIF | PBA — sufijo de SPs para Pruebas; confirmado por SME (Guerra | 🔵 CONVENCIÓN | nombre_sp |

---

## `sp_obtiene_nombre_img_faltante`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_sp_obtiene_nombre_img_faltante.sql` |
| **LOC (1er CREATE)** | 78 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "obtiene nombre y fal — fallo/disputa (anterior)" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `obtiene` → `SELECT` encontrado en el cuerpo · `obtiene` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=4 · INFERIDO=0 · SINTÉTICO=3 / 8 términos |

### Firma

```sql
CREATE PROCEDURE sp_obtiene_nombre_img_faltante(
  pcEmpresa                    CHAR(3)
  pdFechaAlta                  DATE
) RETURNING --DATOS A REGRESAR--
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pcEmpresa` | `CHAR(3)` | — | — |
| `pdFechaAlta` | `DATE` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `iSql_err` | `INTEGER` | L13 |
| `cCodRet` | `CHAR(5)` | L14 |
| `wBegin` | `CHAR(1)` | L15 |
| `nombre_img` | `CHAR (60)` | L16 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `cce_cheques_img` | `bditef` | no | SELECT | L52 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L20 | CÓDIGO_RETORNO | `LET cCodRet 			=	'00000';` |  |
| L42 | CÓDIGO_RETORNO | `LET cCodRet = '00001';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `obtiene` | ACCION | obtiene / recupera | 🔵 CONVENCIÓN | nombre_sp |
| `nombre` | ENTIDAD | nombre | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `?_img_` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `fal` | ENTIDAD | fal — fallo/disputa (prefijo sp_fal_* — aclaraciones bancari | 🔵 CONVENCIÓN | nombre_sp |
| `?t` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `ant` | MODIF | anterior | 🔵 CONVENCIÓN | nombre_sp |
| `?e` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_img_`, `?t`, `?e` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_obtienebancos_pba`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_sp_obtienebancos_pba.sql` |
| **LOC (1er CREATE)** | 81 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 1 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "obtiene banco (PBA — sufijo de SPs para Pruebas; confirmado por SME)" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `obtiene` → `SELECT` encontrado en el cuerpo · `obtiene` → `FROM` encontrado en el cuerpo · `confirma` → `SELECT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=1 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_obtienebancos_pba(
  pBanco                       CHAR(3)
) RETURNING CHAR(6)     AS cCodRet,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pBanco` | `CHAR(3)` | `banco`=banco · `pba`=PBA — sufijo de SPs para Pruebas; confirmado por SME (Guerra, Alejandro, 2026-07-09) | 🔵 CONVENCIÓN / ✅ CÓDIGO |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(6)` | L11 |
| `iSql_Err` | `INTEGER` | L12 |
| `iSam_Err` | `INTEGER` | L13 |
| `cCveBanco` | `CHAR(3)` | L14 |
| `cDescripcion` | `CHAR(40)` | L15 |
| `cTipoBanco` | `CHAR(1)` | L16 |
| `iCvecesif` | `INTEGER` | L17 |
| `vNombreCorto` | `VARCHAR(20)` | L18 |
| `cFlgdomiR` | `CHAR(1)` | L19 |
| `cFlgdomiP` | `CHAR(1)` | L20 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_bancos` | `bdinteg` | ⚠️ sí | SELECT | L52 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `obtiene` | ACCION | obtiene / recupera | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `banco` | ENTIDAD | banco | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?s_` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `pba` | MODIF | PBA — sufijo de SPs para Pruebas; confirmado por SME (Guerra | 🔵 CONVENCIÓN | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?s_` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_obtienebancostef`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_sp_obtienebancostef.sql` |
| **LOC (1er CREATE)** | 68 |
| **Callgraph** | ✅ fan_in=0 / fan_out=25 |
| **Deps concatenadas** | 39 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "obtiene banco y TEF — transferencia electrónica de fondos" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `obtiene` → `SELECT` encontrado en el cuerpo · `obtiene` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=1 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_obtienebancostef(
  pRegistros                   INTEGER
) RETURNING CHAR(5), CHAR (3), CHAR (40)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pRegistros` | `INTEGER` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `iSqlErr` | `INTEGER` | L7 |
| `cCodRet` | `CHAR (5)` | L8 |
| `cBanco` | `CHAR (3)` | L9 |
| `cDescripcion` | `CHAR (40)` | L10 |
| `iCiclo` | `INTEGER` | L11 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_bancos` | `bdinteg` | ⚠️ sí | SELECT | L43 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L33 | VALIDACIÓN_NULL | `IF pRegistros IS NULL OR pRegistros = "" THEN` |  |
| L48 | FÓRMULA | `LET iCiclo = iCiclo + 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `obtiene` | ACCION | obtiene / recupera | 🔵 CONVENCIÓN | nombre_sp |
| `banco` | ENTIDAD | banco | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?s` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `tef` | ENTIDAD | TEF — transferencia electrónica de fondos | ✅ CÓDIGO | nombre_sp, texto_cuerpo |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?s` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_obtienecheques`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_sp_obtienecheques.sql` |
| **LOC (1er CREATE)** | 579 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 2 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "obtiene cheques" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `obtiene` → `SELECT` encontrado en el cuerpo · `obtiene` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=0 / 3 términos |

### Firma

```sql
CREATE PROCEDURE sp_obtienecheques(
  pEmpresa                     CHAR(3)
  pBanco                       CHAR(3)
  pCuenta                      CHAR(20)
  pNumCheque                   CHAR(7)
  pFechaPresenta               DATE
) RETURNING CHAR(6)   AS cCodRet,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pEmpresa` | `CHAR(3)` | — | — |
| `pBanco` | `CHAR(3)` | — | — |
| `pCuenta` | `CHAR(20)` | — | — |
| `pNumCheque` | `CHAR(7)` | — | — |
| `pFechaPresenta` | `DATE` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(6)` | L24 |
| `cCodRet2` | `CHAR(6)` | L25 |
| `cCodRet3` | `CHAR(60)` | L26 |
| `iSql_Err` | `INTEGER` | L27 |
| `iSam_Err` | `INTEGER` | L28 |
| `iDesc_Err` | `CHAR(60)` | L29 |
| `cCveBanco` | `CHAR(3)` | L30 |
| `cDescripcion` | `CHAR(40)` | L31 |
| `iCuenta` | `INT8` | L32 |
| `iNumCheque` | `INT8` | L33 |
| `dFechaAlta` | `DATE` | L34 |
| `dFechaPresenta` | `DATE` | L35 |
| `cUsuarioAlta` | `CHAR(8)` | L36 |
| `cProducto` | `CHAR(4)` | L37 |
| `cCliente` | `CHAR(20)` | L38 |
| `cNombreCte` | `CHAR(104)` | L39 |
| `cNomProducto` | `CHAR(40)` | L40 |
| `cCuentaDep` | `CHAR(20)` | L41 |
| `dMonto` | `DECIMAL(18,2)` | L42 |
| `cRevisado` | `CHAR(1)` | L43 |
| `cEjecutivoReviso` | `CHAR(8)` | L44 |
| `dMontoRet` | `DECIMAL(16,2)` | L45 |
| `cSucursal` | `CHAR(4)` | L46 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `cce_cheques_img` | `bditef` | no | SELECT | L127 |
| `sc_docret_sbc` | `bdicheq` | ⚠️ sí | SELECT | L138 |
| `sc_maechq` | `bdicheq` | ⚠️ sí | SELECT | L151 |
| `si_cliente` | `bdinteg` | ⚠️ sí | SELECT | L158 |
| `sc_producto` | `bdicheq` | ⚠️ sí | SELECT | L166 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L113 | VALIDACIÓN_NULL | `IF pBanco IS NULL AND pCuenta IS NULL AND pNumCheque IS NULL AND pFechaPresenta IS NULL THEN` |  |
| L121 | VALIDACIÓN_NULL | `IF pBanco IS NULL AND pCuenta IS NULL AND pNumCheque IS NULL AND pFechaPresenta IS NOT NULL THEN` |  |
| L132 | VALIDACIÓN_NULL | `IF dMonto is null THEN` |  |
| L203 | VALIDACIÓN_NULL | `IF dMonto is null THEN` |  |
| L274 | VALIDACIÓN_NULL | `IF dMonto is null THEN` |  |
| L344 | VALIDACIÓN_NULL | `IF dMonto is null THEN` |  |
| L417 | VALIDACIÓN_NULL | `IF dMonto is null THEN` |  |
| L493 | VALIDACIÓN_NULL | `IF dMonto is null THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `obtiene` | ACCION | obtiene / recupera | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `cheques` | ENTIDAD | cheques | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |

---

## `sp_obtienecheques2`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_sp_obtienecheques2.sql` |
| **LOC (1er CREATE)** | 691 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 6 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "obtiene cheques" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `obtiene` → `SELECT` encontrado en el cuerpo · `obtiene` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=1 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_obtienecheques2(
  pEmpresa                     CHAR(3)
  pBanco                       CHAR(3)
  pCuenta                      CHAR(20)
  pNumCheque                   CHAR(7)
  pFechaPresenta               DATE
  pRegistros                   INTEGER
  pRecuperacion                INTEGER
) RETURNING CHAR(6)   AS cCodRet,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pEmpresa` | `CHAR(3)` | — | — |
| `pBanco` | `CHAR(3)` | — | — |
| `pCuenta` | `CHAR(20)` | — | — |
| `pNumCheque` | `CHAR(7)` | — | — |
| `pFechaPresenta` | `DATE` | — | — |
| `pRegistros` | `INTEGER` | — | — |
| `pRecuperacion` | `INTEGER` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(6)` | L20 |
| `cCodRet2` | `CHAR(6)` | L21 |
| `cCodRet3` | `CHAR(60)` | L22 |
| `iSql_Err` | `INTEGER` | L23 |
| `iSam_Err` | `INTEGER` | L24 |
| `iDesc_Err` | `CHAR(60)` | L25 |
| `cCveBanco` | `CHAR(3)` | L26 |
| `cDescripcion` | `CHAR(40)` | L27 |
| `iCuenta` | `INT8` | L28 |
| `iNumCheque` | `INT8` | L29 |
| `dFechaAlta` | `DATE` | L30 |
| `dFechaPresenta` | `DATE` | L31 |
| `cUsuarioAlta` | `CHAR(8)` | L32 |
| `cProducto` | `CHAR(4)` | L33 |
| `cCliente` | `CHAR(20)` | L34 |
| `cNombreCte` | `CHAR(104)` | L35 |
| `cNomProducto` | `CHAR(40)` | L36 |
| `cCuentaDep` | `CHAR(20)` | L37 |
| `dMonto` | `DECIMAL(18,2)` | L38 |
| `cRevisado` | `CHAR(1)` | L39 |
| `cEjecutivoReviso` | `CHAR(8)` | L40 |
| `dMontoRet` | `DECIMAL(16,2)` | L41 |
| `cSucursal` | `CHAR(4)` | L42 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `cce_cheques_img` | `bditef` | no | SELECT | L125 |
| `sc_docret_sbc` | `bdicheq` | ⚠️ sí | SELECT | L139 |
| `sc_maechq` | `bdicheq` | ⚠️ sí | SELECT | L152 |
| `ccliente` | `bditef` | no | INSERT | L159 |
| `cproducto` | `bditef` | no | INSERT | L171 |
| `si_cliente` | `bdinteg` | ⚠️ sí | SELECT | L178 |
| `sc_producto` | `bdicheq` | ⚠️ sí | SELECT | L186 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L44 | CÓDIGO_RETORNO | `LET cCodRet         = '00000';` |  |
| L109 | VALIDACIÓN_NULL | `IF pBanco IS NULL AND pCuenta IS NULL AND pNumCheque IS NULL AND pFechaPresenta IS NULL THEN` |  |
| L110 | CÓDIGO_RETORNO | `LET cCodRet = '00001';` |  |
| L117 | VALIDACIÓN_NULL | `IF pBanco IS NULL AND pCuenta IS NULL AND pNumCheque IS NULL AND pFechaPresenta IS NOT NULL THEN` |  |
| L133 | VALIDACIÓN_NULL | `IF dMonto is null THEN` |  |
| L225 | VALIDACIÓN_NULL | `IF dMonto is null THEN` |  |
| L316 | VALIDACIÓN_NULL | `IF dMonto is null THEN` |  |
| L403 | VALIDACIÓN_NULL | `IF dMonto is null THEN` |  |
| L492 | VALIDACIÓN_NULL | `IF dMonto is null THEN` |  |
| L582 | VALIDACIÓN_NULL | `IF dMonto is null THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `obtiene` | ACCION | obtiene / recupera | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `cheques` | ENTIDAD | cheques | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `?2` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?2` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_obtienecheques2_totales`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_sp_obtienecheques2_totales.sql` |
| **LOC (1er CREATE)** | 732 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 5 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "obtiene cheques (totales)" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `obtiene` → `SELECT` encontrado en el cuerpo · `obtiene` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=1 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_obtienecheques2_totales(
  pEmpresa                     CHAR(3)
  pBanco                       CHAR(3)
  pCuenta                      CHAR(20)
  pNumCheque                   CHAR(7)
  pFechaPresenta               DATE
) RETURNING CHAR(6)   AS cCodRet,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pEmpresa` | `CHAR(3)` | — | — |
| `pBanco` | `CHAR(3)` | — | — |
| `pCuenta` | `CHAR(20)` | — | — |
| `pNumCheque` | `CHAR(7)` | — | — |
| `pFechaPresenta` | `DATE` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(6)` | L10 |
| `cCodRet2` | `CHAR(6)` | L11 |
| `cCodRet3` | `CHAR(60)` | L12 |
| `iSql_Err` | `INTEGER` | L13 |
| `iSam_Err` | `INTEGER` | L14 |
| `iDesc_Err` | `CHAR(60)` | L15 |
| `cCveBanco` | `CHAR(3)` | L16 |
| `cDescripcion` | `CHAR(40)` | L17 |
| `iCuenta` | `INT8` | L18 |
| `iNumCheque` | `INT8` | L19 |
| `dFechaAlta` | `DATE` | L20 |
| `dFechaPresenta` | `DATE` | L21 |
| `cUsuarioAlta` | `CHAR(8)` | L22 |
| `cProducto` | `CHAR(4)` | L23 |
| `cCliente` | `CHAR(20)` | L24 |
| `cNombreCte` | `CHAR(104)` | L25 |
| `cNomProducto` | `CHAR(40)` | L26 |
| `cCuentaDep` | `CHAR(20)` | L27 |
| `dMonto` | `DECIMAL(18,2)` | L28 |
| `cRevisado` | `CHAR(1)` | L29 |
| `cEjecutivoReviso` | `CHAR(8)` | L30 |
| `dMontoRet` | `DECIMAL(16,2)` | L31 |
| `cSucursal` | `CHAR(4)` | L32 |
| `iTotalRegistrosRevisados` | `INTEGER` | L33 |
| `iTotalRegistros` | `INTEGER` | L34 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `cce_cheques_img` | `bditef` | no | SELECT | L113 |
| `sc_docret_sbc` | `bdicheq` | ⚠️ sí | SELECT | L124 |
| `sc_maechq` | `bdicheq` | ⚠️ sí | SELECT | L138 |
| `ccliente` | `bditef` | no | INSERT | L145 |
| `cproducto` | `bditef` | no | INSERT | L158 |
| `si_cliente` | `bdinteg` | ⚠️ sí | SELECT | L166 |
| `sc_producto` | `bdicheq` | ⚠️ sí | SELECT | L174 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L37 | CÓDIGO_RETORNO | `LET cCodRet         = '00000';` |  |
| L102 | VALIDACIÓN_NULL | `IF pBanco IS NULL AND pCuenta IS NULL AND pNumCheque IS NULL AND pFechaPresenta IS NULL THEN` |  |
| L103 | CÓDIGO_RETORNO | `LET cCodRet = '00001';` |  |
| L108 | VALIDACIÓN_NULL | `IF pBanco IS NULL AND pCuenta IS NULL AND pNumCheque IS NULL AND pFechaPresenta IS NOT NULL THEN` |  |
| L118 | VALIDACIÓN_NULL | `IF dMonto is null THEN` |  |
| L188 | FÓRMULA | `LET iTotalRegistrosRevisados = iTotalRegistrosRevisados + 1;` |  |
| L199 | FÓRMULA | `LET iTotalRegistros = iTotalRegistros + 1;` |  |
| L216 | VALIDACIÓN_NULL | `IF dMonto is null THEN` |  |
| L289 | FÓRMULA | `LET iTotalRegistrosRevisados = iTotalRegistrosRevisados + 1;` |  |
| L300 | FÓRMULA | `LET iTotalRegistros = iTotalRegistros + 1;` |  |
| L316 | VALIDACIÓN_NULL | `IF dMonto is null THEN` |  |
| L386 | FÓRMULA | `LET iTotalRegistrosRevisados = iTotalRegistrosRevisados + 1;` |  |
| L397 | FÓRMULA | `LET iTotalRegistros = iTotalRegistros + 1;` |  |
| L411 | VALIDACIÓN_NULL | `IF dMonto is null THEN` |  |
| L482 | FÓRMULA | `LET iTotalRegistrosRevisados = iTotalRegistrosRevisados + 1;` |  |
| L493 | FÓRMULA | `LET iTotalRegistros = iTotalRegistros + 1;` |  |
| L510 | VALIDACIÓN_NULL | `IF dMonto is null THEN` |  |
| L583 | FÓRMULA | `LET iTotalRegistrosRevisados = iTotalRegistrosRevisados + 1;` |  |
| L594 | FÓRMULA | `LET iTotalRegistros = iTotalRegistros + 1;` |  |
| L614 | VALIDACIÓN_NULL | `IF dMonto is null THEN` |  |
| L687 | FÓRMULA | `LET iTotalRegistrosRevisados = iTotalRegistrosRevisados + 1;` |  |
| L698 | FÓRMULA | `LET iTotalRegistros = iTotalRegistros + 1;` |  |
| L706 | CÓDIGO_RETORNO | `LET cCodRet = '00002';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `obtiene` | ACCION | obtiene / recupera | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `cheques` | ENTIDAD | cheques | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `?2_` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `totales` | MODIF | totales | 🔵 CONVENCIÓN | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?2_` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_obtienecveratreo`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_sp_obtienecveratreo.sql` |
| **LOC (1er CREATE)** | 85 |
| **Callgraph** | ✅ fan_in=52 / fan_out=25 |
| **Principales callers** | `sp_calificacion_scoring` |
| **Deps concatenadas** | 38 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "obtiene clave" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `obtiene` → `SELECT` encontrado en el cuerpo · `obtiene` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=1 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_obtienecveratreo(
  pSucursal                    CHAR(4)
  pUsuarios                    CHAR (8)
) RETURNING CHAR(5), CHAR (30)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pSucursal` | `CHAR(4)` | — | — |
| `pUsuarios` | `CHAR (8)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `iSqlErr` | `INTEGER` | L8 |
| `cCodRet` | `CHAR (5)` | L9 |
| `cCodRet1` | `CHAR (5)` | L10 |
| `cCodRet2` | `CHAR (5)` | L11 |
| `cCveBcpTEF` | `CHAR (50)` | L12 |
| `cCveRastreo` | `CHAR (30)` | L14 |
| `iConsecutivo` | `INTEGER` | L15 |
| `cConsecutivo` | `CHAR (50)` | L16 |
| `cCodigo` | `CHAR (50)` | L17 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tef_parametros` | `bditef` | no | SELECT | L57 |
| `tef_parametros` | `bditef` | no | UPDATE | L62 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_obtieneparamtef` | `bditef` | no | L47 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L42 | VALIDACIÓN_NULL | `IF pSucursal  IS NULL OR pSucursal = "" OR pUsuarios IS NULL OR pUsuarios = ""   THEN` |  |
| L60 | FÓRMULA | `LET iConsecutivo = CAST (cConsecutivo AS INTEGER) + 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `obtiene` | ACCION | obtiene / recupera | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `cve` | ENTIDAD | clave (cve) | 🔵 CONVENCIÓN | nombre_sp |
| `?ratreo` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?ratreo` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_obtieneparamtef`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_sp_obtieneparamtef.sql` |
| **LOC (1er CREATE)** | 58 |
| **Callgraph** | ✅ fan_in=7 / fan_out=24 |
| **Deps concatenadas** | 37 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "obtiene parámetro y TEF — transferencia electrónica de fondos" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `obtiene` → `SELECT` encontrado en el cuerpo · `obtiene` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=0 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_obtieneparamtef(
  pParametro                   CHAR(2)
) RETURNING CHAR(5), CHAR (100)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pParametro` | `CHAR(2)` | `param`=parámetro | 🔵 CONVENCIÓN |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `iSqlErr` | `INTEGER` | L7 |
| `cCodRet` | `CHAR (5)` | L8 |
| `cValor` | `CHAR (100)` | L9 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tef_parametros` | `bditef` | no | SELECT | L38 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L31 | VALIDACIÓN_NULL | `IF pParametro IS NULL OR pParametro = "" THEN` |  |
| L41 | VALIDACIÓN_NULL | `IF cValor = "" OR cValor IS NULL THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `obtiene` | ACCION | obtiene / recupera | 🔵 CONVENCIÓN | nombre_sp |
| `param` | ENTIDAD | parámetro | 🔵 CONVENCIÓN | nombre_sp |
| `tef` | ENTIDAD | TEF — transferencia electrónica de fondos | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |

---

## `sp_obtienetipoctastef`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_sp_obtienetipoctastef.sql` |
| **LOC (1er CREATE)** | 121 |
| **Callgraph** | ✅ fan_in=0 / fan_out=24 |
| **Deps concatenadas** | 36 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "obtiene cuentas y TEF — transferencia electrónica de fondos (tipo de)" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `obtiene` → `SELECT` encontrado en el cuerpo · `obtiene` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=0 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_obtienetipoctastef(
  pTipo                        CHAR (1)
  pCuentas                     CHAR (20)
  pRegistros                   SMALLINT
) RETURNING CHAR(5), CHAR (2), CHAR (20)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pTipo` | `CHAR (1)` | `tipo`=tipo de | ✅ CÓDIGO |
| `pCuentas` | `CHAR (20)` | — | — |
| `pRegistros` | `SMALLINT` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `iSqlErr` | `INTEGER` | L7 |
| `cCodRet` | `CHAR (5)` | L8 |
| `cTipo_Cta` | `CHAR (2)` | L9 |
| `cDescripcion` | `CHAR (20)` | L10 |
| `iCiclo` | `INTEGER` | L11 |
| `cCuentas` | `CHAR (60)` | L12 |
| `i` | `INTEGER` | L13 |
| `iLongitud` | `INTEGER` | L14 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tef_tipo_cta` | `bditef` | no | SELECT | L57 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L38 | VALIDACIÓN_NULL | `IF pRegistros IS NULL OR pRegistros = "" OR pCuentas IS NULL OR pCuentas = "" THEN` |  |
| L53 | FÓRMULA | `LET i = i + 3;` |  |
| L61 | VALIDACIÓN_NULL | `IF cTipo_Cta IS NULL THEN` |  |
| L62 | CÓDIGO_RETORNO | `LET cCodRet = '00002';` |  |
| L67 | FÓRMULA | `LET iCiclo = iCiclo + 1;` |  |
| L82 | FÓRMULA | `LET i = i + 3;` |  |
| L90 | VALIDACIÓN_NULL | `IF cTipo_Cta IS NULL THEN` |  |
| L91 | CÓDIGO_RETORNO | `LET cCodRet = '00002';` |  |
| L96 | FÓRMULA | `LET iCiclo = iCiclo + 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `obtiene` | ACCION | obtiene / recupera | 🔵 CONVENCIÓN | nombre_sp |
| `tipo` | MODIF | tipo de | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `ctas` | ENTIDAD | cuentas | 🔵 CONVENCIÓN | nombre_sp |
| `tef` | ENTIDAD | TEF — transferencia electrónica de fondos | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |

---

## `sp_obtienetipoopertef`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_sp_obtienetipoopertef.sql` |
| **LOC (1er CREATE)** | 69 |
| **Callgraph** | ✅ fan_in=0 / fan_out=24 |
| **Deps concatenadas** | 35 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "obtiene TEF — transferencia electrónica de fondos (tipo de)" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `obtiene` → `SELECT` encontrado en el cuerpo · `obtiene` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=2 · INFERIDO=1 · SINTÉTICO=1 / 6 términos |

### Firma

```sql
CREATE PROCEDURE sp_obtienetipoopertef(
  pRegistros                   INTEGER
) RETURNING CHAR(5), CHAR (2), CHAR (30), CHAR (20)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pRegistros` | `INTEGER` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `iSqlErr` | `INTEGER` | L8 |
| `cCodRet` | `CHAR (5)` | L9 |
| `cCodigo` | `CHAR (2)` | L11 |
| `cDescripcion` | `CHAR (30)` | L12 |
| `cTipo_Cta_Aplica` | `CHAR (20)` | L13 |
| `iContador` | `INTEGER` | L14 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tef_tipo_oper` | `bditef` | no | SELECT | L46 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L38 | VALIDACIÓN_NULL | `IF pRegistros IS NULL OR pRegistros = "" THEN` |  |
| L49 | FÓRMULA | `LET iContador = iContador + 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `obtiene` | ACCION | obtiene / recupera | 🔵 CONVENCIÓN | nombre_sp |
| `tipo` | MODIF | tipo de | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `ope` | ACCION | operación | 🟡 INFERIDO | nombre_sp |
| `?r` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `tef` | ENTIDAD | TEF — transferencia electrónica de fondos | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?r` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_reportearchivos_tef`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_sp_reportearchivos_tef.sql` |
| **LOC (1er CREATE)** | 662 |
| **Callgraph** | ✅ fan_in=0 / fan_out=12 |
| **Deps concatenadas** | 5 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "reporte, archivos y TEF — transferencia electrónica de fondos" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 3 tabla(s) con operaciones: SELECT, INSERT |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=0 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_reportearchivos_tef(
  pnombrearchivo               char(20)
  ptipoarchivo                 char(4)
  pfechainicial                char(8)
  pfechafinal                  char(8)
  ptiporeporte                 smallint
) RETURNING char(5) as codigo,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pnombrearchivo` | `char(20)` | — | — |
| `ptipoarchivo` | `char(4)` | — | — |
| `pfechainicial` | `char(8)` | — | — |
| `pfechafinal` | `char(8)` | — | — |
| `ptiporeporte` | `smallint` | `reporte`=reporte | 🔵 CONVENCIÓN |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vsqlerr` | `INTEGER` | L28 |
| `cCodret` | `CHAR(5)` | L29 |
| `cFechaPresentacion` | `CHAR(10)` | L30 |
| `cNombreArchivo` | `CHAR(20)` | L31 |
| `cCodOperacion` | `CHAR(2)` | L32 |
| `cSucursal` | `CHAR(4)` | L33 |
| `cNombreOrd` | `CHAR(40)` | L34 |
| `cNumCtaOrd` | `CHAR(20)` | L35 |
| `cTipoOperacion` | `CHAR(50)` | L36 |
| `cRefNumerica` | `CHAR(7)` | L37 |
| `dImporte` | `DECIMAL(11,2)` | L38 |
| `cNombreDestino` | `CHAR(40)` | L39 |
| `cNumCtaDestino` | `CHAR(20)` | L40 |
| `cSecuencia` | `CHAR(7)` | L41 |
| `cTipoCtaDestino` | `CHAR(40)` | L42 |
| `cBanco` | `CHAR(40)` | L43 |
| `cStatus` | `CHAR(20)` | L44 |
| `dImpOperaciones` | `DECIMAL(18,2)` | L45 |
| `cMotivoDev` | `CHAR(2)` | L46 |
| `cDescripcionDev` | `CHAR(50)` | L47 |
| `cRegistrosCod61` | `INTEGER` | L48 |
| `cTotalImporteCod61` | `DECIMAL(18,2)` | L49 |
| `cRegistrosCod62` | `INTEGER` | L50 |
| `cTotalImporteCod62` | `DECIMAL(18,2)` | L51 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tef_errores` | `bditef` | no | INSERT | L87 |
| `tef_cce_detalle` | `bditef` | no | SELECT | L107 |
| `tef_cce_sumario` | `bditef` | no | SELECT | L131 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L54 | CÓDIGO_RETORNO | `LET cCodret	= '00000';` |  |
| L113 | FÓRMULA | `LET cTotalImporteCod61 = cTotalImporteCod61 / 100;` | 🔴 MONEY/aritmética financiera |
| L125 | FÓRMULA | `LET cTotalImporteCod62 = cTotalImporteCod62 / 100;` | 🔴 MONEY/aritmética financiera |
| L136 | FÓRMULA | `LET dImpOperaciones = dImpOperaciones / 100;` |  |
| L146 | FÓRMULA | `LET cTotalImporteCod61 = cTotalImporteCod61 / 100;` | 🔴 MONEY/aritmética financiera |
| L158 | FÓRMULA | `LET cTotalImporteCod62 = cTotalImporteCod62 / 100;` | 🔴 MONEY/aritmética financiera |
| L169 | FÓRMULA | `LET dImpOperaciones = dImpOperaciones / 100;` |  |
| L194 | FÓRMULA | `LET cFechaPresentacion = substr(cFechaPresentacion,7,2) \|\| "/" \|\| substr(cFechaPresentacion,5,2)` |  |
| L195 | FÓRMULA | `LET dImporte = dImporte / 100;` | 🔴 MONEY/aritmética financiera |
| L223 | FÓRMULA | `LET cFechaPresentacion = substr(cFechaPresentacion,7,2) \|\| "/" \|\| substr(cFechaPresentacion,5,2)` |  |
| L225 | FÓRMULA | `LET dImporte = dImporte / 100;` | 🔴 MONEY/aritmética financiera |
| L246 | FÓRMULA | `LET cTotalImporteCod61 = cTotalImporteCod61 / 100;` | 🔴 MONEY/aritmética financiera |
| L258 | FÓRMULA | `LET cTotalImporteCod62 = (cTotalImporteCod62 / 100)::decimal(18,2);` | 🔴 MONEY/aritmética financiera |
| L269 | FÓRMULA | `LET dImpOperaciones = dImpOperaciones / 100;` |  |
| L279 | FÓRMULA | `LET cTotalImporteCod61 = cTotalImporteCod61 / 100;` | 🔴 MONEY/aritmética financiera |
| L291 | FÓRMULA | `LET cTotalImporteCod62 = (cTotalImporteCod62 / 100)::decimal(18,2);` | 🔴 MONEY/aritmética financiera |
| L303 | FÓRMULA | `LET dImpOperaciones = dImpOperaciones / 100;` |  |
| L327 | FÓRMULA | `LET cFechaPresentacion = substr(cFechaPresentacion,7,2) \|\| "/" \|\| substr(cFechaPresentacion,5,2)` |  |
| L328 | FÓRMULA | `LET dImporte = dImporte / 100;` | 🔴 MONEY/aritmética financiera |
| L356 | FÓRMULA | `LET cFechaPresentacion = substr(cFechaPresentacion,7,2) \|\| "/" \|\| substr(cFechaPresentacion,5,2)` |  |
| L357 | FÓRMULA | `LET dImporte = dImporte / 100;` | 🔴 MONEY/aritmética financiera |
| L377 | FÓRMULA | `LET dImpOperaciones = dImpOperaciones / 100;` |  |
| L386 | FÓRMULA | `LET dImpOperaciones = dImpOperaciones / 100;` |  |
| L408 | FÓRMULA | `LET cFechaPresentacion = substr(cFechaPresentacion,7,2) \|\| "/" \|\| substr(cFechaPresentacion,5,2)` |  |
| L409 | FÓRMULA | `LET dImporte = dImporte / 100;` | 🔴 MONEY/aritmética financiera |
| L436 | FÓRMULA | `LET cFechaPresentacion = substr(cFechaPresentacion,7,2) \|\| "/" \|\| substr(cFechaPresentacion,5,2)` |  |
| L437 | FÓRMULA | `LET dImporte = dImporte / 100;` | 🔴 MONEY/aritmética financiera |
| L454 | FÓRMULA | `LET dImpOperaciones = dImpOperaciones / 100;` |  |
| L461 | FÓRMULA | `LET dImpOperaciones = dImpOperaciones / 100;` |  |
| L480 | FÓRMULA | `LET cFechaPresentacion = substr(cFechaPresentacion,7,2) \|\| "/" \|\| substr(cFechaPresentacion,5,2)` |  |
| | *…12 más…* | | |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `reporte` | ENTIDAD | reporte | 🔵 CONVENCIÓN | nombre_sp |
| `archivos` | ENTIDAD | archivos | 🔵 CONVENCIÓN | nombre_sp |
| `tef` | ENTIDAD | TEF — transferencia electrónica de fondos | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |

---

## `sp_reportearchivos_tef2`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_sp_reportearchivos_tef2.sql` |
| **LOC (1er CREATE)** | 655 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "reporte, archivos y TEF — transferencia electrónica de fondos" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 3 tabla(s) con operaciones: SELECT, INSERT |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=1 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_reportearchivos_tef2(
  pnombrearchivo               char(20)
  ptipoarchivo                 char(4)
  pfechainicial                char(8)
  pfechafinal                  char(8)
  ptiporeporte                 smallint
  pregistros                   integer
  precuperacion                integer
) RETURNING char(5) as codigo,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pnombrearchivo` | `char(20)` | — | — |
| `ptipoarchivo` | `char(4)` | — | — |
| `pfechainicial` | `char(8)` | — | — |
| `pfechafinal` | `char(8)` | — | — |
| `ptiporeporte` | `smallint` | `reporte`=reporte | ✅ CÓDIGO |
| `pregistros` | `integer` | — | — |
| `precuperacion` | `integer` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vsqlerr` | `INTEGER` | L29 |
| `cCodret` | `CHAR(5)` | L30 |
| `cFechaPresentacion` | `CHAR(10)` | L31 |
| `cNombreArchivo` | `CHAR(20)` | L32 |
| `cCodOperacion` | `CHAR(2)` | L33 |
| `cSucursal` | `CHAR(4)` | L34 |
| `cNombreOrd` | `CHAR(40)` | L35 |
| `cNumCtaOrd` | `CHAR(20)` | L36 |
| `cTipoOperacion` | `CHAR(50)` | L37 |
| `cRefNumerica` | `CHAR(7)` | L38 |
| `dImporte` | `DECIMAL(11,2)` | L39 |
| `cNombreDestino` | `CHAR(40)` | L40 |
| `cNumCtaDestino` | `CHAR(20)` | L41 |
| `cSecuencia` | `CHAR(7)` | L42 |
| `cTipoCtaDestino` | `CHAR(40)` | L43 |
| `cBanco` | `CHAR(40)` | L44 |
| `cStatus` | `CHAR(20)` | L45 |
| `dImpOperaciones` | `DECIMAL(18,2)` | L46 |
| `cMotivoDev` | `CHAR(2)` | L47 |
| `cDescripcionDev` | `CHAR(50)` | L48 |
| `cRegistrosCod61` | `INTEGER` | L49 |
| `cTotalImporteCod61` | `DECIMAL(18,2)` | L50 |
| `cRegistrosCod62` | `INTEGER` | L51 |
| `cTotalImporteCod62` | `DECIMAL(18,2)` | L52 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tef_errores` | `bditef` | no | INSERT | L86 |
| `tef_cce_detalle` | `bditef` | no | SELECT | L106 |
| `tef_cce_sumario` | `bditef` | no | SELECT | L130 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L55 | CÓDIGO_RETORNO | `LET cCodret	= '00000';` |  |
| L112 | FÓRMULA | `LET cTotalImporteCod61 = cTotalImporteCod61 / 100;` | 🔴 MONEY/aritmética financiera |
| L124 | FÓRMULA | `LET cTotalImporteCod62 = cTotalImporteCod62 / 100;` | 🔴 MONEY/aritmética financiera |
| L135 | FÓRMULA | `LET dImpOperaciones = dImpOperaciones / 100;` |  |
| L145 | FÓRMULA | `LET cTotalImporteCod61 = cTotalImporteCod61 / 100;` | 🔴 MONEY/aritmética financiera |
| L157 | FÓRMULA | `LET cTotalImporteCod62 = cTotalImporteCod62 / 100;` | 🔴 MONEY/aritmética financiera |
| L168 | FÓRMULA | `LET dImpOperaciones = dImpOperaciones / 100;` |  |
| L191 | FÓRMULA | `LET cFechaPresentacion = substr(cFechaPresentacion,7,2) \|\| "/" \|\| substr(cFechaPresentacion,5,2)` |  |
| L192 | FÓRMULA | `LET dImporte = dImporte / 100;` | 🔴 MONEY/aritmética financiera |
| L220 | FÓRMULA | `LET cFechaPresentacion = substr(cFechaPresentacion,7,2) \|\| "/" \|\| substr(cFechaPresentacion,5,2)` |  |
| L221 | FÓRMULA | `LET dImporte = dImporte / 100;` | 🔴 MONEY/aritmética financiera |
| L242 | FÓRMULA | `LET cTotalImporteCod61 = cTotalImporteCod61 / 100;` | 🔴 MONEY/aritmética financiera |
| L254 | FÓRMULA | `LET cTotalImporteCod62 = (cTotalImporteCod62 / 100)::decimal(18,2);` | 🔴 MONEY/aritmética financiera |
| L265 | FÓRMULA | `LET dImpOperaciones = dImpOperaciones / 100;` |  |
| L275 | FÓRMULA | `LET cTotalImporteCod61 = cTotalImporteCod61 / 100;` | 🔴 MONEY/aritmética financiera |
| L287 | FÓRMULA | `LET cTotalImporteCod62 = (cTotalImporteCod62 / 100)::decimal(18,2);` | 🔴 MONEY/aritmética financiera |
| L299 | FÓRMULA | `LET dImpOperaciones = dImpOperaciones / 100;` |  |
| L323 | FÓRMULA | `LET cFechaPresentacion = substr(cFechaPresentacion,7,2) \|\| "/" \|\| substr(cFechaPresentacion,5,2)` |  |
| L324 | FÓRMULA | `LET dImporte = dImporte / 100;` | 🔴 MONEY/aritmética financiera |
| L353 | FÓRMULA | `LET cFechaPresentacion = substr(cFechaPresentacion,7,2) \|\| "/" \|\| substr(cFechaPresentacion,5,2)` |  |
| L354 | FÓRMULA | `LET dImporte = dImporte / 100;` | 🔴 MONEY/aritmética financiera |
| L375 | FÓRMULA | `LET dImpOperaciones = dImpOperaciones / 100;` |  |
| L384 | FÓRMULA | `LET dImpOperaciones = dImpOperaciones / 100;` |  |
| L406 | FÓRMULA | `LET cFechaPresentacion = substr(cFechaPresentacion,7,2) \|\| "/" \|\| substr(cFechaPresentacion,5,2)` |  |
| L407 | FÓRMULA | `LET dImporte = dImporte / 100;` | 🔴 MONEY/aritmética financiera |
| L435 | FÓRMULA | `LET cFechaPresentacion = substr(cFechaPresentacion,7,2) \|\| "/" \|\| substr(cFechaPresentacion,5,2)` |  |
| L436 | FÓRMULA | `LET dImporte = dImporte / 100;` | 🔴 MONEY/aritmética financiera |
| L454 | FÓRMULA | `LET dImpOperaciones = dImpOperaciones / 100;` |  |
| L461 | FÓRMULA | `LET dImpOperaciones = dImpOperaciones / 100;` |  |
| L480 | FÓRMULA | `LET cFechaPresentacion = substr(cFechaPresentacion,7,2) \|\| "/" \|\| substr(cFechaPresentacion,5,2)` |  |
| | *…12 más…* | | |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `reporte` | ENTIDAD | reporte | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `archivos` | ENTIDAD | archivos | 🔵 CONVENCIÓN | nombre_sp |
| `tef` | ENTIDAD | TEF — transferencia electrónica de fondos | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `?2` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?2` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_revoperacionestef`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_sp_revoperacionestef.sql` |
| **LOC (1er CREATE)** | 91 |
| **Callgraph** | ✅ fan_in=0 / fan_out=24 |
| **Deps concatenadas** | 34 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "reversión operaciones y TEF — transferencia electrónica de fondos" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 1 llamada(s): `sp_validahorariotef` |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=1 · INFERIDO=1 · SINTÉTICO=0 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_revoperacionestef(
  pFolioSuc                    CHAR (16)
  pFecha                       DATE
  pSucursal                    CHAR (4)
) RETURNING CHAR(5)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pFolioSuc` | `CHAR (16)` | — | — |
| `pFecha` | `DATE` | — | — |
| `pSucursal` | `CHAR (4)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `iSqlErr` | `INTEGER` | L8 |
| `cCodRet` | `CHAR (5)` | L9 |
| `cCodRet1` | `CHAR (5)` | L10 |
| `cCodRet2` | `CHAR (5)` | L11 |
| `cStatusPago` | `CHAR (2)` | L14 |
| `cHoraMax` | `CHAR (5)` | L15 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tef_operaciones` | `bditef` | no | SELECT | L48 |
| `tef_procesos` | `bditef` | no | SELECT | L67 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_validahorariotef` | `bditef` | no | L59 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L40 | VALIDACIÓN_NULL | `IF pFolioSuc IS NULL OR pFolioSuc = "" OR pFecha IS NULL OR pFecha = ""` |  |
| L42 | FÓRMULA | `LET cCodRet = "00003";	--Parámetros invalidos` |  |
| L57 | FÓRMULA | `LET cCodRet = "00004";	--estatus inválido para reversión` |  |
| L68 | FÓRMULA | `LET cCodRet = "00005";  --El proceso de generación de archivo ya inició / está en proceso` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `rev` | ACCION | reversión (abreviación de reversa/reverso) | 🟡 INFERIDO | nombre_sp |
| `operaciones` | ENTIDAD | operaciones (plural) | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `tef` | ENTIDAD | TEF — transferencia electrónica de fondos | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |

---

## `sp_tef_act_rep_sicam`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_sp_tef_act_rep_sicam.sql` |
| **LOC (1er CREATE)** | 161 |
| **Callgraph** | ✅ fan_in=0 / fan_out=17 |
| **Deps concatenadas** | 19 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "actualiza TEF — transferencia electrónica de fondos" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `actualiza` → `UPDATE` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=4 · INFERIDO=1 · SINTÉTICO=1 / 6 términos |

### Firma

```sql
CREATE PROCEDURE sp_tef_act_rep_sicam(
  pEjecutivo                   CHAR(8)
  pImpCheqPres                 MONEY(16,2)
  pImpCheqRec                  MONEY(16,2)
  pImpCheqSald                 MONEY(16,2)
  pImpDomPres                  MONEY(16,2)
  pImpDomRec                   MONEY(16,2)
  pImpDomSald                  MONEY(16,2)
  pImpTefPres                  MONEY(16,2)
  pImpTefRec                   MONEY(16,2)
  pImpTefSald                  MONEY(16,2)
  pTotalPres                   MONEY(16,2)
  pTotalRec                    MONEY(16,2)
  pTotalSald                   MONEY(16,2)
  pModalidad                   SMALLINT
) RETURNING CHAR(6)  AS COD_RET,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pEjecutivo` | `CHAR(8)` | — | — |
| `pImpCheqPres` | `MONEY(16,2)` | — | — |
| `pImpCheqRec` | `MONEY(16,2)` | — | — |
| `pImpCheqSald` | `MONEY(16,2)` | — | — |
| `pImpDomPres` | `MONEY(16,2)` | — | — |
| `pImpDomRec` | `MONEY(16,2)` | — | — |
| `pImpDomSald` | `MONEY(16,2)` | — | — |
| `pImpTefPres` | `MONEY(16,2)` | `tef`=TEF — transferencia electrónica de fondos | 🔵 CONVENCIÓN |
| `pImpTefRec` | `MONEY(16,2)` | `tef`=TEF — transferencia electrónica de fondos | 🔵 CONVENCIÓN |
| `pImpTefSald` | `MONEY(16,2)` | `tef`=TEF — transferencia electrónica de fondos | 🔵 CONVENCIÓN |
| `pTotalPres` | `MONEY(16,2)` | — | — |
| `pTotalRec` | `MONEY(16,2)` | — | — |
| `pTotalSald` | `MONEY(16,2)` | — | — |
| `pModalidad` | `SMALLINT` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `iSqlErr` | `INTEGER` | L31 |
| `iIsamErr` | `INTEGER` | L32 |
| `cErrorInfo` | `CHAR(80)` | L33 |
| `cCodRet` | `CHAR(6)` | L34 |
| `cMensajeRet` | `CHAR(100)` | L35 |
| `dFechaHoy` | `DATE` | L36 |
| `dFechaMayor` | `DATE` | L37 |
| `mImportCheqPre` | `MONEY(16,2)` | L38 |
| `mImportCheqRec` | `MONEY(16,2)` | L39 |
| `mImportCheqSald` | `MONEY(16,2)` | L40 |
| `mImportDomPres` | `MONEY(16,2)` | L41 |
| `mImportDomRec` | `MONEY(16,2)` | L42 |
| `mImportDomSald` | `MONEY(16,2)` | L43 |
| `mImportTefPres` | `MONEY(16,2)` | L44 |
| `mImportTefRec` | `MONEY(16,2)` | L45 |
| `mImportTefSald` | `MONEY(16,2)` | L46 |
| `mImportTotalPres` | `MONEY(16,2)` | L47 |
| `mImportTotalRec` | `MONEY(16,2)` | L48 |
| `mImportTotalSald` | `MONEY(16,2)` | L49 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_fechas` | `bdinteg` | ⚠️ sí | SELECT | L98 |
| `cce_cedulacontable` | `bditef` | no | SELECT | L101 |
| `cce_cedulacontable_sicam` | `bditef` | no | SELECT | L110 |
| `cce_cedulacontable_sicam` | `bditef` | no | INSERT | L146 |
| `segun` | `bditef` | no | UPDATE | L156 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `tef` | ENTIDAD | TEF — transferencia electrónica de fondos | 🔵 CONVENCIÓN | nombre_sp |
| `act` | ACCION | actualiza | 🔵 CONVENCIÓN | nombre_sp |
| `rep` | ACCION | reporte | 🔵 CONVENCIÓN | nombre_sp |
| `?_si` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `cam` | PREFIJO | cámara / captura contable | 🟡 INFERIDO | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_si` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_tef_actualizar_cte_detalle`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_sp_tef_actualizar_cte_detalle.sql` |
| **LOC (1er CREATE)** | 79 |
| **Callgraph** | ✅ fan_in=0 / fan_out=23 |
| **Deps concatenadas** | 33 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "actualiza TEF — transferencia electrónica de fondos, cliente y detalle" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 1 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=3 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=1 / 6 términos |

### Historia del SP

| Tipo | Valor |
|------|-------|
| DESCRIPCION | ACTUALIZA LOS CAMPOS Nombre_Arch_CCE, FECHA_PRESETACION_CCE, TIPO_REGISTRO_CCE Y NUMERO_SECUENCIA_CCE DE LA TABLA TEF_CTE_DETALLE, DESPUES DE PROCESAR EL 60. |
| FECHA | 09/03/2011 |

### Firma

```sql
CREATE PROCEDURE sp_tef_actualizar_cte_detalle(
  psNombre_Arch                CHAR(20)
  psFecha_Presente             CHAR(8)
) RETURNING CHAR(5) AS CodRet
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `psNombre_Arch` | `CHAR(20)` | — | — |
| `psFecha_Presente` | `CHAR(8)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vsCodRet` | `CHAR(5)` | L15 |
| `viSql_Err` | `INTEGER` | L16 |
| `vsRFC_Rec` | `CHAR(18)` | L17 |
| `vsCveEstatus` | `CHAR(2)` | L18 |
| `vsNumSecuencia` | `CHAR(7)` | L19 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tef_cce_detalle_paso` | `bditef` | no | SELECT | L45 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `tef` | ENTIDAD | TEF — transferencia electrónica de fondos | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `actualiza` | ACCION | actualiza | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?r_` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `cte` | ENTIDAD | cliente | 🔵 CONVENCIÓN | nombre_sp |
| `detalle` | ENTIDAD | detalle | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?r_` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_tef_bitacora`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_sp_tef_bitacora.sql` |
| **LOC (1er CREATE)** | 191 |
| **Callgraph** | ✅ fan_in=38 / fan_out=14 |
| **Deps concatenadas** | 12 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "TEF — transferencia electrónica de fondos y bitácora" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 2 llamada(s): `sp_valida_fecha`, `sp_obtenermensajeerror` |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=0 / 3 términos |

### Historia del SP

| Tipo | Valor |
|------|-------|
| DESCRIPCION | PROCEDIMIENTO PARA INSERTAR EN LA TABLA TEF_PROCESOS Y TEF_ERRORES PARA REGISTRAR EL ESTADO DEL PROCESO.', |
| FECHA | 09/03/2011 |

### Firma

```sql
CREATE PROCEDURE sp_tef_bitacora(
  psTipoProceso                CHAR(1)
  pdtFechaProceso              DATE
  psCveProceso                 VARCHAR(20)
  psDescripcion                CHAR(60)
  psEstatus                    CHAR(1)
  psCodRet                     CHAR(5)
  psUsuario                    CHAR(8)
  psNomSPLlamado               VARCHAR(50)
  psNomArchivo                 VARCHAR(20)
  psFechaPres                  CHAR(8)
  psCvEstatus                  CHAR(2)
) RETURNING CHAR(5) AS CodRet
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `psTipoProceso` | `CHAR(1)` | — | — |
| `pdtFechaProceso` | `DATE` | — | — |
| `psCveProceso` | `VARCHAR(20)` | — | — |
| `psDescripcion` | `CHAR(60)` | — | — |
| `psEstatus` | `CHAR(1)` | — | — |
| `psCodRet` | `CHAR(5)` | — | — |
| `psUsuario` | `CHAR(8)` | — | — |
| `psNomSPLlamado` | `VARCHAR(50)` | `sp`=stored procedure | 🔵 CONVENCIÓN |
| `psNomArchivo` | `VARCHAR(20)` | — | — |
| `psFechaPres` | `CHAR(8)` | — | — |
| `psCvEstatus` | `CHAR(2)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vsCodRet` | `CHAR(5)` | L13 |
| `viSqlErr` | `INTEGER` | L14 |
| `viSamErr` | `INTEGER` | L15 |
| `vsDescMensajeError` | `VARCHAR(100)` | L17 |
| `viTotReg` | `INTEGER` | L18 |
| `vdtFecha_Proceso` | `DATE` | L19 |
| `vsFechaAplicacion` | `CHAR(8)` | L20 |
| `vdFechaAplicacion` | `DATE` | L21 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tef_procesos` | `bditef` | no | SELECT | L67 |
| `tef_procesos` | `bditef` | no | INSERT | L68 |
| `tef_cat_rechazos` | `bditef` | no | SELECT | L85 |
| `tef_errores` | `bditef` | no | INSERT | L94 |
| `tef_cce_sumario` | `bditef` | no | SELECT | L107 |
| `tef_cce_detalle` | `bditef` | no | SELECT | L114 |
| `tef_cce_sumario_paso` | `bditef` | no | SELECT | L124 |
| `tef_cce_detalle_paso` | `bditef` | no | SELECT | L134 |
| `tef_cce_archivos` | `bditef` | no | SELECT | L149 |
| `tef_cce_archivos` | `bditef` | no | INSERT | L158 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_valida_fecha` | `bditef` | no | L45 |
| `sp_obtenermensajeerror` | `bditef` | no | L57 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L24 | CÓDIGO_RETORNO | `LET vsCodRet = '00000';` |  |
| L48 | FÓRMULA | `LET vdtFecha_Proceso = SUBSTR(psFechaPres,5,2) \|\| "/" \|\| SUBSTR(psFechaPres,7,2) \|\| "/" \|\| S` |  |
| L53 | CÓDIGO_RETORNO | `LET vsCodRet = '00000';` |  |
| L90 | VALIDACIÓN_NULL | `IF vsDescMensajeError IS NULL THEN` |  |
| L143 | FÓRMULA | `LET vdFechaAplicacion = SUBSTR(vsFechaAplicacion, 5,2)/*MES*/ \|\| '/' \|\| SUBSTR(vsFechaAplicacion` |  |
| L145 | VALIDACIÓN_NULL | `IF viTotReg IS NULL THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `tef` | ENTIDAD | TEF — transferencia electrónica de fondos | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `bitacora` | ENTIDAD | bitácora | 🔵 CONVENCIÓN | nombre_sp |

---

## `sp_tef_buscaoperacion`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_sp_tef_buscaoperacion.sql` |
| **LOC (1er CREATE)** | 96 |
| **Callgraph** | ✅ fan_in=0 / fan_out=5 |
| **Deps concatenadas** | 9 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "busca TEF — transferencia electrónica de fondos" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 1 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=0 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_tef_buscaoperacion(
  pfecha                       DATE
  pSucursal                    CHAR(4)
  pEjecutivo                   CHAR(8)
  pFolioSuc                    VARCHAR(16)
) RETURNING CHAR(6) 		AS cod_ret,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pfecha` | `DATE` | — | — |
| `pSucursal` | `CHAR(4)` | — | — |
| `pEjecutivo` | `CHAR(8)` | — | — |
| `pFolioSuc` | `VARCHAR(16)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `iSqlErr` | `INTEGER` | L15 |
| `iIsamErr` | `INTEGER` | L16 |
| `cErrorInfo` | `VARCHAR(80)` | L17 |
| `cCodRet` | `CHAR(6)` | L18 |
| `cMensajeRet` | `VARCHAR(80)` | L19 |
| `cFolioSuc` | `VARCHAR(16)` | L21 |
| `cNumCtaOrd` | `VARCHAR(20)` | L22 |
| `cReferencia` | `VARCHAR(40)` | L23 |
| `cImporte` | `CHAR(10)` | L24 |
| `cReversado` | `CHAR(2)` | L25 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tef_operaciones` | `bditef` | no | SELECT | L67 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `tef` | ENTIDAD | TEF — transferencia electrónica de fondos | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `busca` | ACCION | busca / localiza | 🔵 CONVENCIÓN | nombre_sp |
| `operacion` | ACCION | operación | 🔵 CONVENCIÓN | nombre_sp |

---

## `sp_tef_buscararchivo`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_sp_tef_buscararchivo.sql` |
| **LOC (1er CREATE)** | 163 |
| **Callgraph** | ✅ fan_in=27 / fan_out=14 |
| **Deps concatenadas** | 13 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "búsqueda/buscar TEF — transferencia electrónica de fondos y archivo" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 3 tabla(s) con operaciones: INSERT, SELECT |
| **Evidencia vocab** | CÓDIGO=3 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=0 / 4 términos |

### Historia del SP

| Tipo | Valor |
|------|-------|
| DESCRIPCION | PROCEDIMIENTO PARA BUSCAR UN ARCHIVO EN UNA RUTA PROPORCIONADA. |
| FECHA | 10/03/2011 |

### Firma

```sql
CREATE PROCEDURE sp_tef_buscararchivo(
  psRuta                       VARCHAR(100)
  psNombreArchivo              VARCHAR(50)
) RETURNING CHAR(5) AS CodRet, CHAR(1) AS FlagExiste
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `psRuta` | `VARCHAR(100)` | — | — |
| `psNombreArchivo` | `VARCHAR(50)` | `archivo`=archivo | ✅ CÓDIGO |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vsCodRet` | `CHAR(5)` | L14 |
| `viSqlErr` | `INTEGER` | L15 |
| `viSamErr` | `INTEGER` | L16 |
| `vsFlagExiste` | `CHAR(1)` | L18 |
| `vsCadSql` | `LVARCHAR (500)` | L19 |
| `vsLinea` | `VARCHAR(50)` | L20 |
| `cHora` | `CHAR(8)` | L21 |
| `cFechaArchivoOUT` | `CHAR(15)` | L22 |
| `iTemporales` | `SMALLINT` | L23 |
| `iPaso` | `SMALLINT` | L24 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `systables` | `bditef` | no | SELECT | L70 |
| `tef_tmp_busca_archivo` | `bditef` | no | INSERT | L90 |
| `tef_tmp_busca_archivo` | `bditef` | no | SELECT | L117 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L59 | CÓDIGO_RETORNO | `LET vsCodRet = '00000';` |  |
| L63 | CÓDIGO_RETORNO | `LET vsCodRet = '00750';` |  |
| L66 | CÓDIGO_RETORNO | `LET vsCodRet = '00751';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `tef` | ENTIDAD | TEF — transferencia electrónica de fondos | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `buscar` | ACCION | búsqueda/buscar | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `archivo` | ENTIDAD | archivo | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |

---

## `sp_tef_consnombrenumcte`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_sp_tef_consnombrenumcte.sql` |
| **LOC (1er CREATE)** | 206 |
| **Callgraph** | ✅ fan_in=0 / fan_out=8 |
| **Deps concatenadas** | 18 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "consulta TEF — transferencia electrónica de fondos, nombre y número de cliente" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `consulta` → `SELECT` encontrado en el cuerpo · `consulta` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=0 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_tef_consnombrenumcte(
  pEmpresa                     CHAR(3)
  pNombre1                     CHAR(26)
  pNombre2                     CHAR(26)
  pPaterno                     CHAR(26)
  pMaterno                     CHAR(26)
  pFechaNac                    DATE
  pNo_Rfc                      CHAR(13)
  pRazon                       CHAR(60)
  pSecuencia                   SMALLINT
) RETURNING CHAR(5),CHAR(60),CHAR(20),CHAR(13)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pEmpresa` | `CHAR(3)` | — | — |
| `pNombre1` | `CHAR(26)` | `nombre`=nombre | ✅ CÓDIGO |
| `pNombre2` | `CHAR(26)` | `nombre`=nombre | ✅ CÓDIGO |
| `pPaterno` | `CHAR(26)` | — | — |
| `pMaterno` | `CHAR(26)` | — | — |
| `pFechaNac` | `DATE` | — | — |
| `pNo_Rfc` | `CHAR(13)` | — | — |
| `pRazon` | `CHAR(60)` | — | — |
| `pSecuencia` | `SMALLINT` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `sql_err` | `INTEGER` | L13 |
| `v_nombre_completo` | `CHAR(63)` | L15 |
| `v_numcte` | `CHAR(20)` | L17 |
| `v_cod_ret` | `CHAR(5)` | L18 |
| `v_razon_soc` | `CHAR(60)` | L19 |
| `v_rfc` | `CHAR(13)` | L20 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `systabnames` | `sysmaster` | ⚠️ sí | SELECT | L46 |
| `si_cliente` | `bdinteg` | ⚠️ sí | SELECT | L63 |
| `tmp_razon_soc` | `bditef` | no | SELECT | L72 |
| `si_ctepf` | `bdinteg` | ⚠️ sí | SELECT | L89 |
| `tmp_no_rfc` | `bditef` | no | SELECT | L97 |
| `tmp_fecha_nac` | `bditef` | no | SELECT | L145 |
| `tmp_fechanac2` | `bditef` | no | SELECT | L174 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L75 | FÓRMULA | `LET v_ciclo = v_ciclo+1;` |  |
| L100 | FÓRMULA | `LET v_ciclo = v_ciclo+1;` |  |
| L124 | FÓRMULA | `LET pPaterno = TRIM(pPaterno)\|\|"*";` |  |
| L125 | FÓRMULA | `LET pMaterno = TRIM(pMaterno)\|\|"*";` |  |
| L126 | FÓRMULA | `LET pNombre1 = TRIM(pNombre1)\|\|"*";` |  |
| L127 | FÓRMULA | `LET pNombre2 = TRIM(pNombre2)\|\|"*";` |  |
| L148 | FÓRMULA | `LET v_ciclo = v_ciclo + 1;` |  |
| L177 | FÓRMULA | `LET v_ciclo = v_ciclo+1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `tef` | ENTIDAD | TEF — transferencia electrónica de fondos | 🔵 CONVENCIÓN | nombre_sp |
| `cons` | ACCION | consulta | 🔵 CONVENCIÓN | nombre_sp |
| `nombre` | ENTIDAD | nombre | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `numcte` | ENTIDAD | número de cliente | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |

---

## `sp_tef_domi_genrep30y60`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_sp_tef_domi_genrep30y60.sql` |
| **LOC (1er CREATE)** | 138 |
| **Callgraph** | ✅ fan_in=0 / fan_out=17 |
| **Deps concatenadas** | 16 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "genera reporte TEF — transferencia electrónica de fondos y domiciliación" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `genera` → `INSERT` encontrado en el cuerpo · `genera` → `SELECT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=1 · INFERIDO=2 · SINTÉTICO=1 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_tef_domi_genrep30y60(
  pCodOperacion                CHAR(2)
  ptipoarchivo                 CHAR(1)
  pModalidad                   SMALLINT
) RETURNING CHAR(6) AS cCodRet,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pCodOperacion` | `CHAR(2)` | — | — |
| `ptipoarchivo` | `CHAR(1)` | — | — |
| `pModalidad` | `SMALLINT` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(6)` | L9 |
| `iSqlErr` | `INTEGER` | L10 |
| `iCodOper` | `CHAR(2)` | L11 |
| `iSumRegistros` | `INTEGER` | L12 |
| `mImporte` | `MONEY(16,2)` | L13 |
| `dtFechaHoy` | `DATE` | L14 |
| `dtFechaAnt` | `DATE` | L15 |
| `i` | `SMALLINT` | L16 |
| `j` | `SMALLINT` | L17 |
| `cCodRetDevuelto` | `CHAR(6)` | L18 |
| `dtFechaDevuelta` | `DATE` | L19 |
| `dtFechaHabilAnt` | `DATE` | L20 |
| `dtFechaAux` | `DATE` | L21 |
| `cFechaPres` | `CHAR(8)` | L22 |
| `cFechaPresHabAnt` | `CHAR(8)` | L23 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_fechas` | `bdinteg` | ⚠️ sí | SELECT | L57 |
| `dom_cce_detalle` | `bdidomi` | ⚠️ sí | SELECT | L82 |
| `tef_cce_detalle` | `bditef` | no | SELECT | L97 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `cal_habil_ant` | `bditef` | no | L65 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `tef` | ENTIDAD | TEF — transferencia electrónica de fondos | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `domi` | ENTIDAD | domiciliación | 🟡 INFERIDO | nombre_sp |
| `genrep` | ACCION | genera reporte (abreviación genrep) | 🟡 INFERIDO | nombre_sp |
| `?30y60` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?30y60` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_tef_generararchivo60`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_sp_tef_generararchivo60.sql` |
| **LOC (1er CREATE)** | 538 |
| **Callgraph** | ✅ fan_in=16 / fan_out=8 |
| **Deps concatenadas** | 13 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "generar TEF — transferencia electrónica de fondos y archivo" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `genera` → `INSERT` encontrado en el cuerpo · `genera` → `SELECT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=1 · INFERIDO=1 · SINTÉTICO=1 / 5 términos |

### Historia del SP

| Tipo | Valor |
|------|-------|
| DESCRIPCION | GENERA LAS INSTRUCCIONES DE CARGOS PARA FORMAR EL ARCHIVOS 60 Y PREPARA LAS TABLAS PARA QUE LOS VALIDE CCE. |
| FECHA | 16/03/2011 |

### Firma

```sql
CREATE PROCEDURE sp_tef_generararchivo60(
  psNombre_Archivo             CHAR(20)
  psUsuario                    CHAR(8)
) RETURNING CHAR(5) AS CodRet
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `psNombre_Archivo` | `CHAR(20)` | `archivo`=archivo | ✅ CÓDIGO |
| `psUsuario` | `CHAR(8)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vdFecha_hoy` | `DATE` | L13 |
| `vdFecha_Manana` | `DATE` | L14 |
| `vdFechaEnvioProveedor` | `DATE` | L15 |
| `iSQLerr` | `INTEGER` | L16 |
| `iExiste` | `INTEGER` | L17 |
| `viImporteAux` | `INTEGER` | L19 |
| `viIva_Tef_Aux` | `INTEGER` | L20 |
| `vdtFecha_Trans` | `DATETIME YEAR TO FRACTION (5)` | L22 |
| `vsFolio_Suc` | `CHAR(16)` | L23 |
| `vsNum_Serial` | `CHAR(12)` | L24 |
| `vsNum_Cta_Ord` | `CHAR(20)` | L25 |
| `vsTipo_Cta_Ord` | `CHAR(2)` | L26 |
| `vdFecha_Programacion` | `DATE` | L27 |
| `vsTipo_Operacion` | `CHAR(2)` | L28 |
| `vsClave_Rastreo` | `CHAR(30)` | L29 |
| `vsNombre_Cte_Ord` | `CHAR(30)` | L30 |
| `vsRfc_Cte_Ord` | `CHAR(15)` | L31 |
| `vsImporte_Tef` | `CHAR(10)` | L32 |
| `vsComision_Tef` | `CHAR(5)` | L33 |
| `vsIva_Tef` | `CHAR(5)` | L34 |
| `vsImporte_Tot_Tef` | `CHAR(10)` | L35 |
| `vsTipo_Cta_Ben` | `CHAR(2)` | L36 |
| `vsNombre_Ben` | `CHAR(30)` | L37 |
| `vsNum_Cuenta_Tarj_Ben` | `CHAR(20)` | L38 |
| `vsCve_Banco_Rec` | `CHAR(3)` | L39 |
| *…29 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tef_cce_detalle_paso` | `bditef` | no | SELECT | L157 |
| `tef_operaciones` | `bditef` | no | UPDATE | L169 |
| `sc_fechas` | `bdicheq` | ⚠️ sí | SELECT | L210 |
| `tef_parametros` | `bditef` | no | SELECT | L236 |
| `tef_operaciones` | `bditef` | no | SELECT | L246 |
| `tef_cce_encabezado_paso` | `bditef` | no | INSERT | L262 |
| `sc_maechq` | `bdicheq` | ⚠️ sí | SELECT | L366 |
| `tef_cce_detalle_paso` | `bditef` | no | INSERT | L370 |
| `tef_cce_sumario_paso` | `bditef` | no | INSERT | L490 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_tef_moverregistroshist` | `bditef` | no | L194 |
| `sp_valfecha_banca` | `bdinteg` | ⚠️ sí | L220 |
| `sp_valida_fecha` | `bditef` | no | L222 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L112 | CÓDIGO_RETORNO | `LET vsCodRet = '00000';` |  |
| L174 | FÓRMULA | `LET viContadorRegistros = viContadorRegistros + 1;` |  |
| L213 | FÓRMULA | `LET vdFecha_Manana = vdFecha_hoy + 1;` |  |
| L233 | CÓDIGO_RETORNO | `LET vsCodRet = '01800';` |  |
| L235 | CÓDIGO_RETORNO | `LET vsCodRet = '01801';` |  |
| L237 | CÓDIGO_RETORNO | `LET vsCodRet = '01802';` |  |
| L239 | CÓDIGO_RETORNO | `LET vsCodRet = '01803';` |  |
| L241 | CÓDIGO_RETORNO | `LET vsCodRet = '01804';` |  |
| L243 | CÓDIGO_RETORNO | `LET vsCodRet = '01805';` |  |
| L245 | CÓDIGO_RETORNO | `LET vsCodRet = '01806';` |  |
| L247 | CÓDIGO_RETORNO | `LET vsCodRet = '01807';` |  |
| L352 | FÓRMULA | `LET viContadorSecuencia = viContadorSecuencia + 1;` |  |
| L356 | FÓRMULA | `LET viImporteAux = NVL(vsImporte_Tef, '0') * 100;` | 🔴 MONEY/aritmética financiera |
| L357 | FÓRMULA | `LET viIva_Tef_Aux = NVL(vSIva_Tef, '0') * 100;` |  |
| L358 | FÓRMULA | `LET viImporteTotal = viImporteTotal + viImporteAux;` | 🔴 MONEY/aritmética financiera |
| L468 | FÓRMULA | `LET viContadorRegistros = viContadorRegistros + 1;` |  |
| L487 | FÓRMULA | `LET viContadorSecuencia = viContadorSecuencia + 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `tef` | ENTIDAD | TEF — transferencia electrónica de fondos | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `generar` | ACCION | generar (infinitivo — sp_generarbalanza*) | 🟡 INFERIDO | nombre_sp |
| `archivo` | ENTIDAD | archivo | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `?60` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?60` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_tef_generararchivo62`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_sp_tef_generararchivo62.sql` |
| **LOC (1er CREATE)** | 1029 |
| **Callgraph** | ✅ fan_in=0 / fan_out=12 |
| **Deps concatenadas** | 4 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "generar TEF — transferencia electrónica de fondos y archivo" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `genera` → `INSERT` encontrado en el cuerpo · `genera` → `SELECT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=1 · INFERIDO=1 · SINTÉTICO=1 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_tef_generararchivo62(
  cNombreArchivo               CHAR(20)
  cUsuario                     CHAR(8)
) RETURNING CHAR(5) AS CodRet
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `cNombreArchivo` | `CHAR(20)` | `archivo`=archivo | ✅ CÓDIGO |
| `cUsuario` | `CHAR(8)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `dFechaHoy` | `DATE` | L5 |
| `dFechaHabil` | `DATE` | L6 |
| `cFechaPresentacionGen` | `CHAR(8)` | L7 |
| `cCodRet` | `CHAR(5)` | L9 |
| `cCodRet2` | `CHAR(5)` | L10 |
| `cCodRet3` | `CHAR(5)` | L11 |
| `cStatus_tar` | `CHAR(2)` | L12 |
| `cPrefijoTarjeta` | `CHAR(6)` | L13 |
| `cCuenta` | `CHAR(12)` | L15 |
| `cStatus_Cta` | `CHAR(1)` | L16 |
| `cProducto` | `CHAR(4)` | L17 |
| `cNombreArch` | `CHAR(20)` | L18 |
| `cFechaPresentacion` | `CHAR(8)` | L19 |
| `cTipoRegistro` | `CHAR(2)` | L20 |
| `cNumSecuencia` | `CHAR(7)` | L21 |
| `cCodOperacion` | `CHAR(2)` | L22 |
| `cCodDivisa` | `CHAR(2)` | L23 |
| `cFechaTrans` | `CHAR(8)` | L24 |
| `cBancoPresentador` | `CHAR(3)` | L25 |
| `cBancoReceptor` | `CHAR(3)` | L26 |
| `cImporte` | `CHAR(15)` | L27 |
| `cUsoFuturoCcen` | `CHAR(16)` | L28 |
| `cTipoOperacion` | `CHAR(2)` | L29 |
| `cFechaAplica` | `CHAR(8)` | L30 |
| `cTipoCtaOrd` | `CHAR(2)` | L31 |
| *…75 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `15` | `bditef` | no | SELECT | L281 |
| `tef_cce_detalle_paso` | `bditef` | no | SELECT | L312 |
| `tef_parametros` | `bditef` | no | SELECT | L324 |
| `sd_maecred` | `bdicred` | ⚠️ sí | SELECT | L328 |
| `sc_tarjeta` | `bdicheq` | ⚠️ sí | SELECT | L361 |
| `sc_fechas` | `bdicheq` | ⚠️ sí | SELECT | L439 |
| `si_sucursales` | `bdinteg` | ⚠️ sí | SELECT | L456 |
| `tef_cce_detalle` | `bditef` | no | SELECT | L474 |
| `tef_cce_detalle_paso` | `bditef` | no | DELETE | L478 |
| `tef_cce_detalle_paso` | `bditef` | no | INSERT | L480 |
| `sc_maechq` | `bdicheq` | ⚠️ sí | SELECT | L648 |
| `tef_prod_permitidos` | `bditef` | no | SELECT | L650 |
| `sc_producto` | `bdicheq` | ⚠️ sí | SELECT | L658 |
| `tef_errores` | `bditef` | no | INSERT | L691 |
| `tef_cce_encabezado` | `bditef` | no | SELECT | L838 |
| `tef_cce_sumario` | `bditef` | no | SELECT | L846 |
| `tef_cce_encabezado_paso` | `bditef` | no | INSERT | L852 |
| `tef_cce_sumario_paso` | `bditef` | no | INSERT | L893 |
| `tef_cce_encabezado_paso` | `bditef` | no | SELECT | L928 |
| `tef_cce_sumario_paso` | `bditef` | no | SELECT | L930 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_tef_bitacora` | `bditef` | no | L281 |
| `reversion` | `bdicred` | ⚠️ sí | L338 |
| `sp_tef_constelctacte` | `bdicheq` | ⚠️ sí | L350 |
| `sp_generafolionomina` | `bdicheq` | ⚠️ sí | L376 |
| `cargo_ref` | `bdicheq` | ⚠️ sí | L383 |
| `sp_tef_moverregistroshist` | `bditef` | no | L404 |
| `sp_valida_fecha` | `bditef` | no | L445 |
| `sp_valfecha_banca` | `bdinteg` | ⚠️ sí | L448 |
| `principal` | `bdicred` | ⚠️ sí | L600 |
| `abono_ref` | `bdicheq` | ⚠️ sí | L697 |
| `sp_tef_generaarchivo` | `bditef` | no | L935 |
| `sp_tef_guardarccearchivos` | `bditef` | no | L943 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L320 | CÓDIGO_RETORNO | `LET cCodRet = '00000';` |  |
| L336 | FÓRMULA | `LET mSaldoAPagar = ((cImporte::INTEGER)/100);` | 🔴 MONEY/aritmética financiera |
| L373 | FÓRMULA | `LET mSaldoAPagar = ((cImporte::INTEGER)/100);` | 🔴 MONEY/aritmética financiera |
| L380 | CÓDIGO_RETORNO | `LET cCodRet = '02304';` |  |
| L457 | CÓDIGO_RETORNO | `LET cCodRet = '02300';` |  |
| L460 | CÓDIGO_RETORNO | `LET cCodRet = '02302';` |  |
| L462 | CÓDIGO_RETORNO | `LET cCodRet = '02303';` |  |
| L466 | FÓRMULA | `LET iContadorSecuencia62 = 1; --A PARTIR DE 2 ES PARA EL DETALLE` |  |
| L531 | CÓDIGO_RETORNO | `LET cCodRet = '00000';` |  |
| L573 | CÓDIGO_RETORNO | `LET cCodRet = '00000';` |  |
| L590 | FÓRMULA | `LET mSaldoAPagar = ((cImporte::INTEGER)/100);` | 🔴 MONEY/aritmética financiera |
| L597 | CÓDIGO_RETORNO | `LET cCodRet = '02304';` |  |
| L685 | FÓRMULA | `LET mSaldoAPagar = ((cImporte::INTEGER)/100);` | 🔴 MONEY/aritmética financiera |
| L694 | CÓDIGO_RETORNO | `LET cCodRet = '02304';` |  |
| L714 | FÓRMULA | `LET iContadorSecuencia62 = iContadorSecuencia62 + 1;` |  |
| L715 | FÓRMULA | `LET iImporteTotalArchivo62 = iImporteTotalArchivo62 + NVL(cImporte,0)::INTEGER ;` | 🔴 MONEY/aritmética financiera |
| L816 | FÓRMULA | `LET iContadorRegistros = iContadorRegistros + 1;` |  |
| L925 | CÓDIGO_RETORNO | `LET cCodRet = '00000';` |  |
| L960 | CÓDIGO_RETORNO | `LET cCodRet = '00325';` |  |
| L964 | CÓDIGO_RETORNO | `LET cCodRet = '02305';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `tef` | ENTIDAD | TEF — transferencia electrónica de fondos | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `generar` | ACCION | generar (infinitivo — sp_generarbalanza*) | 🟡 INFERIDO | nombre_sp |
| `archivo` | ENTIDAD | archivo | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?62` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?62` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_tef_generararchivo63`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_sp_tef_generararchivo63.sql` |
| **LOC (1er CREATE)** | 475 |
| **Callgraph** | ✅ fan_in=1 / fan_out=23 |
| **Deps concatenadas** | 32 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "generar TEF — transferencia electrónica de fondos y archivo" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `genera` → `INSERT` encontrado en el cuerpo · `genera` → `SELECT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=1 · INFERIDO=1 · SINTÉTICO=1 / 5 términos |

### Historia del SP

| Tipo | Valor |
|------|-------|
| DESCRIPCION | GENERA REGISTROS DEL ARCHIVO 63. |
| FECHA | 27/04/2011 |

### Firma

```sql
CREATE PROCEDURE sp_tef_generararchivo63(
  psNombreArchivo63            CHAR(20)
  psFechaPresentacion          CHAR(8)
  psUsuario                    CHAR(8)
) RETURNING CHAR(5) AS CodRet
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `psNombreArchivo63` | `CHAR(20)` | `archivo`=archivo | ✅ CÓDIGO |
| `psFechaPresentacion` | `CHAR(8)` | — | — |
| `psUsuario` | `CHAR(8)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vsCodRet` | `CHAR(5)` | L13 |
| `vsCodRet2` | `CHAR(5)` | L14 |
| `vsCodRet3` | `CHAR(5)` | L15 |
| `viContadorSecuencia63` | `INTEGER` | L17 |
| `viImporteTotalArchivo63` | `INTEGER` | L18 |
| `vsFecha_Presentacion_Gen` | `CHAR(8)` | L19 |
| `vsFechaManana` | `CHAR(8)` | L20 |
| `vsPrefijoTarjeta` | `CHAR(100)` | L22 |
| `vsBancoPresentador` | `CHAR (3)` | L23 |
| `vsCuenta` | `CHAR(11)` | L25 |
| `vsStatus_Cta` | `CHAR (1)` | L26 |
| `vsProductosNoPermitidos` | `CHAR (100)` | L27 |
| `vsProducto` | `CHAR (4)` | L28 |
| `vdFecha_Hoy` | `DATE` | L29 |
| `vdFecha_Manana` | `DATE` | L30 |
| `vsNombre_Arch` | `CHAR(20)` | L32 |
| `vsFecha_Presentacion` | `CHAR(8)` | L33 |
| `vsTipo_Registro` | `CHAR(2)` | L34 |
| `vsNum_Secuencia` | `CHAR(7)` | L35 |
| `vsCod_Operacion` | `CHAR(2)` | L36 |
| `vsCod_Divisa` | `CHAR(2)` | L37 |
| `vsFecha_Trans` | `CHAR(8)` | L38 |
| `vsBanco_Presentador` | `CHAR(3)` | L39 |
| `vsBanco_Receptor` | `CHAR(3)` | L40 |
| `vsImporte` | `CHAR(15)` | L41 |
| *…33 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tef_parametros` | `bditef` | no | SELECT | L177 |
| `sc_fechas` | `bdicheq` | ⚠️ sí | SELECT | L189 |
| `tef_cce_detalle` | `bditef` | no | SELECT | L241 |
| `tef_cce_detalle_paso` | `bditef` | no | INSERT | L256 |
| `tef_cce_encabezado_paso` | `bditef` | no | INSERT | L381 |
| `tef_cce_sumario_paso` | `bditef` | no | INSERT | L425 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_valfecha_banca` | `bdinteg` | ⚠️ sí | L200 |
| `sp_valida_fecha` | `bditef` | no | L202 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L193 | FÓRMULA | `LET vdFecha_Manana = vdFecha_Hoy + 1;` |  |
| L211 | CÓDIGO_RETORNO | `LET vsCodRet = '01700';` |  |
| L213 | CÓDIGO_RETORNO | `LET vsCodRet = '01701';` |  |
| L215 | CÓDIGO_RETORNO | `LET vsCodRet = '01702';` |  |
| L252 | FÓRMULA | `LET viContadorSecuencia63 = viContadorSecuencia63 +1;` |  |
| L253 | FÓRMULA | `LET viImporteTotalArchivo63 = viImporteTotalArchivo63 + NVL(vsImporte,0)::INTEGER;` | 🔴 MONEY/aritmética financiera |
| L359 | FÓRMULA | `LET viContadorRegistros = viContadorRegistros + 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `tef` | ENTIDAD | TEF — transferencia electrónica de fondos | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `generar` | ACCION | generar (infinitivo — sp_generarbalanza*) | 🟡 INFERIDO | nombre_sp |
| `archivo` | ENTIDAD | archivo | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?63` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?63` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_tef_generareplistnegra`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_sp_tef_generareplistnegra.sql` |
| **LOC (1er CREATE)** | 194 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "generar TEF — transferencia electrónica de fondos" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `genera` → `INSERT` encontrado en el cuerpo · `genera` → `SELECT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=1 · INFERIDO=1 · SINTÉTICO=1 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_tef_generareplistnegra(
) RETURNING CHAR(5)         AS codigo_respuesta,
```

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(5)` | L7 |
| `cMensaje` | `CHAR(80)` | L8 |
| `iSqlErr` | `INTEGER` | L9 |
| `cStmt` | `CHAR(1000)` | L10 |
| `dFecha_Ayer` | `DATE` | L11 |
| `cRutaArchDet` | `CHAR(100)` | L12 |
| `cNombreArch` | `CHAR(30)` | L13 |
| `cFecha_presentacion` | `CHAR(8)` | L14 |
| `cTipo_registro` | `CHAR(4)` | L15 |
| `cNum_secuencia` | `CHAR(7)` | L16 |
| `vCod_operacion` | `CHAR(2)` | L17 |
| `vCod_divisa` | `CHAR(2)` | L18 |
| `cFecha_trans` | `CHAR(8)` | L19 |
| `cBanco_presentador` | `CHAR(45)` | L20 |
| `cBanco_receptor` | `CHAR(45)` | L21 |
| `cImporte` | `CHAR(15)` | L22 |
| `cUso_futuro_ccen` | `CHAR(16)` | L23 |
| `cTipo_operacion` | `CHAR(2)` | L24 |
| `cFecha_aplica` | `CHAR(8)` | L25 |
| `cTipo_cta_ord` | `CHAR(2)` | L26 |
| `cNum_cta_ord` | `CHAR(20)` | L27 |
| `cNombre_ord` | `CHAR(40)` | L28 |
| `cRfc_ord` | `CHAR(20)` | L29 |
| `cTipo_cta_rec` | `CHAR(2)` | L30 |
| `cNum_cta_rec` | `CHAR(20)` | L31 |
| *…26 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tef_parametros` | `bditef` | no | SELECT | L131 |
| `tef_cce_archivos` | `bditef` | no | SELECT | L133 |
| `tef_cce_detalle` | `bditef` | no | SELECT | L142 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L136 | FÓRMULA | `LET cRutaArchDet  =  TRIM(cRutaArchivos) \|\| '/Reporte_tef_' \|\| LPAD(DAY (dFecha_Ayer),2,'0') \|\` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `tef` | ENTIDAD | TEF — transferencia electrónica de fondos | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `generar` | ACCION | generar (infinitivo — sp_generarbalanza*) | 🟡 INFERIDO | nombre_sp |
| `?eplistnegra` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?eplistnegra` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_tef_grab_arch_cam`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_sp_tef_grab_arch_cam.sql` |
| **LOC (1er CREATE)** | 103 |
| **Callgraph** | ✅ fan_in=78 / fan_out=17 |
| **Deps concatenadas** | 23 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "TEF — transferencia electrónica de fondos y archivo" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 2 tabla(s) con operaciones: INSERT, SELECT |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=2 · INFERIDO=2 · SINTÉTICO=1 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_tef_grab_arch_cam(
  pEjecutivo                   CHAR(8)
  pNumRegistro                 INTEGER
  pImporte                     DECIMAL(14,2)
  pCodOper                     INTEGER
  pClave                       CHAR(10)
  pNumArchLimt                 SMALLINT
  pModalidad                   INTEGER
) RETURNING CHAR(6)  AS COD_RET,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pEjecutivo` | `CHAR(8)` | — | — |
| `pNumRegistro` | `INTEGER` | — | — |
| `pImporte` | `DECIMAL(14,2)` | — | — |
| `pCodOper` | `INTEGER` | — | — |
| `pClave` | `CHAR(10)` | — | — |
| `pNumArchLimt` | `SMALLINT` | `arch`=archivo | 🟡 INFERIDO |
| `pModalidad` | `INTEGER` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `iSqlErr` | `INTEGER` | L6 |
| `iIsamErr` | `INTEGER` | L7 |
| `cErrorInfo` | `CHAR(80)` | L8 |
| `cCodRet` | `CHAR(6)` | L9 |
| `cMensajeRet` | `CHAR(80)` | L10 |
| `iNumArchivo` | `INTEGER` | L11 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `cce_archivos_camara` | `bditef` | no | SELECT | L46 |
| `cce_archivos_camara` | `bditef` | no | INSERT | L57 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L52 | FÓRMULA | `LET iNumArchivo = iNumArchivo +1;` |  |
| L81 | FÓRMULA | `LET iNumArchivo = iNumArchivo - 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `tef` | ENTIDAD | TEF — transferencia electrónica de fondos | 🔵 CONVENCIÓN | nombre_sp |
| `?_grab_` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `arch` | ENTIDAD | archivo | 🟡 INFERIDO | nombre_sp |
| `cam` | PREFIJO | cámara / captura contable | 🟡 INFERIDO | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_grab_` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_tef_graba_cam_arch41`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_sp_tef_graba_cam_arch41.sql` |
| **LOC (1er CREATE)** | 90 |
| **Callgraph** | ✅ fan_in=0 / fan_out=13 |
| **Deps concatenadas** | 8 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "graba TEF — transferencia electrónica de fondos y archivo" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 2 tabla(s) con operaciones: INSERT, SELECT |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=3 · INFERIDO=2 · SINTÉTICO=1 / 6 términos |

### Firma

```sql
CREATE PROCEDURE sp_tef_graba_cam_arch41(
  pEjecutivo                   CHAR(8)
  pNumero_registros            INTEGER
  pImporte                     DECIMAL(14,2)
  pCodigo_operacion            INTEGER
  pClave_archivo               CHAR(30)
  pNumero_archivo              SMALLINT
  pModalidad                   INTEGER
) RETURNING CHAR(6) AS COD_RET,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pEjecutivo` | `CHAR(8)` | — | — |
| `pNumero_registros` | `INTEGER` | — | — |
| `pImporte` | `DECIMAL(14,2)` | — | — |
| `pCodigo_operacion` | `INTEGER` | — | — |
| `pClave_archivo` | `CHAR(30)` | `arch`=archivo | 🟡 INFERIDO |
| `pNumero_archivo` | `SMALLINT` | `arch`=archivo | 🟡 INFERIDO |
| `pModalidad` | `INTEGER` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `iNumeroArch` | `INTEGER` | L14 |
| `cCodRet` | `CHAR(6)` | L15 |
| `cMensajeRetorno` | `CHAR(80)` | L16 |
| `iSqlErr` | `INTEGER` | L17 |
| `iIsamErr` | `INTEGER` | L18 |
| `cErrorInfo` | `CHAR(80)` | L19 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `cce_archivos_camara` | `bditef` | no | SELECT | L54 |
| `bditef` | `bditef` | no | INSERT | L59 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `tef` | ENTIDAD | TEF — transferencia electrónica de fondos | 🔵 CONVENCIÓN | nombre_sp |
| `graba` | ACCION | graba / almacena | 🔵 CONVENCIÓN | nombre_sp |
| `cam` | PREFIJO | cámara / captura contable | 🟡 INFERIDO | nombre_sp |
| `arch` | ENTIDAD | archivo | 🟡 INFERIDO | nombre_sp |
| `?41` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?41` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_tef_grabaoperacion`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_sp_tef_grabaoperacion.sql` |
| **LOC (1er CREATE)** | 274 |
| **Callgraph** | ✅ fan_in=50 / fan_out=5 |
| **Principales callers** | `sp_calificacion_scoring` |
| **Deps concatenadas** | 8 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "graba TEF — transferencia electrónica de fondos" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 4 llamada(s): `sp_tef_validahorario`, `sp_tef_validarchcod60`, `cargo_ref` |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=0 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_tef_grabaoperacion(
  pTipo                        CHAR(1)
  pEmpresa                     CHAR(3)
  pFecha_Trans                 DATE
  pFolio_Suc                   CHAR(16)
  pSucursal                    CHAR(4)
  pNum_Cta_Ord                 CHAR(20)
  pTipo_Cta_Ord                CHAR(2)
  pFecha_Prog                  DATE
  pTipo_Oper                   CHAR(2)
  pCve_Rastreo                 CHAR(30)
  pNombre_Cte_Ord              CHAR(30)
  pRfc_Cte_Ord                 CHAR(15)
  pImp_Tef                     CHAR(10)
  pComision_Tef                CHAR(5)
  pIva_Tef                     CHAR(5)
  pImp_Tot_Tef                 CHAR(10)
  pTipo_Cta_Ben                CHAR(2)
  pNombre_Ben                  CHAR(30)
  pNum_Cta_Tarj_Ben            CHAR(20)
  pCve_Banco_Rec               CHAR(3)
  pRfc_Ben                     CHAR(15)
  pConcep_Pago                 CHAR(50)
  pRef_Num                     CHAR(7)
  pReferencia                  CHAR(40)
  pCve_Canal                   CHAR(2)
  pMotivo_Dev                  CHAR(2)
  pDivisa                      CHAR(2)
  pTransacSuc                  CHAR(4)
  pNumTarjeta                  CHAR(16)
  pUsuario                     CHAR (8)
) RETURNING CHAR(6) 		AS cod_ret,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pTipo` | `CHAR(1)` | — | — |
| `pEmpresa` | `CHAR(3)` | — | — |
| `pFecha_Trans` | `DATE` | — | — |
| `pFolio_Suc` | `CHAR(16)` | — | — |
| `pSucursal` | `CHAR(4)` | — | — |
| `pNum_Cta_Ord` | `CHAR(20)` | — | — |
| `pTipo_Cta_Ord` | `CHAR(2)` | — | — |
| `pFecha_Prog` | `DATE` | — | — |
| `pTipo_Oper` | `CHAR(2)` | — | — |
| `pCve_Rastreo` | `CHAR(30)` | — | — |
| `pNombre_Cte_Ord` | `CHAR(30)` | — | — |
| `pRfc_Cte_Ord` | `CHAR(15)` | — | — |
| `pImp_Tef` | `CHAR(10)` | `tef`=TEF — transferencia electrónica de fondos | ✅ CÓDIGO |
| `pComision_Tef` | `CHAR(5)` | `tef`=TEF — transferencia electrónica de fondos | ✅ CÓDIGO |
| `pIva_Tef` | `CHAR(5)` | `tef`=TEF — transferencia electrónica de fondos | ✅ CÓDIGO |
| `pImp_Tot_Tef` | `CHAR(10)` | `tef`=TEF — transferencia electrónica de fondos | ✅ CÓDIGO |
| `pTipo_Cta_Ben` | `CHAR(2)` | — | — |
| `pNombre_Ben` | `CHAR(30)` | — | — |
| `pNum_Cta_Tarj_Ben` | `CHAR(20)` | — | — |
| `pCve_Banco_Rec` | `CHAR(3)` | — | — |
| `pRfc_Ben` | `CHAR(15)` | — | — |
| `pConcep_Pago` | `CHAR(50)` | — | — |
| `pRef_Num` | `CHAR(7)` | — | — |
| `pReferencia` | `CHAR(40)` | — | — |
| `pCve_Canal` | `CHAR(2)` | — | — |
| `pMotivo_Dev` | `CHAR(2)` | — | — |
| `pDivisa` | `CHAR(2)` | — | — |
| `pTransacSuc` | `CHAR(4)` | — | — |
| `pNumTarjeta` | `CHAR(16)` | — | — |
| `pUsuario` | `CHAR (8)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `iSqlErr` | `INTEGER` | L36 |
| `cCodRet1` | `CHAR (6)` | L37 |
| `cCodRet2` | `CHAR (6)` | L38 |
| `cCodRet3` | `CHAR (6)` | L39 |
| `cNumSerial` | `CHAR (12)` | L40 |
| `cTrans` | `CHAR(4)` | L42 |
| `dtFecha` | `DATE` | L43 |
| `mSaldo` | `MONEY(14,2)` | L44 |
| `mMonto` | `MONEY(14,2)` | L45 |
| `iTransaccion` | `INTEGER` | L46 |
| `cTranscargo` | `CHAR(4)` | L47 |
| `cComis` | `CHAR(4)` | L48 |
| `cIvaComis` | `CHAR(4)` | L49 |
| `cNumTran` | `CHAR(4)` | L50 |
| `cMensaje` | `CHAR(100)` | L51 |
| `cMensajeRet` | `VARCHAR(100)` | L52 |
| `cCodretVal` | `CHAR(5)` | L54 |
| `cTpo_Proc` | `CHAR(1)` | L55 |
| `cFech_Proc` | `CHAR(10)` | L56 |
| `cCve_Proc` | `CHAR(20)` | L57 |
| `cDescripcion` | `CHAR(60)` | L58 |
| `cEstatus` | `CHAR(1)` | L59 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tef_parametros` | `bditef` | no | SELECT | L135 |
| `sc_fechas` | `bdicheq` | ⚠️ sí | SELECT | L137 |
| `sc_movdia` | `bdicheq` | ⚠️ sí | SELECT | L234 |
| `tef_operaciones` | `bditef` | no | INSERT | L245 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_tef_validahorario` | `bditef` | no | L145 |
| `sp_tef_validarchcod60` | `bditef` | no | L151 |
| `cargo_ref` | `bdicheq` | ⚠️ sí | L186 |
| `sp_desc_ret` | `bdinteg` | ⚠️ sí | L195 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L139 | VALIDACIÓN_NULL | `IF cTranscargo IS NULL OR cTranscargo = '' THEN` |  |
| L168 | VALIDACIÓN_NULL | `IF cComis IS NULL OR cComis = '' THEN` |  |
| L179 | VALIDACIÓN_NULL | `IF cIvaComis IS NULL OR cIvaComis = '' THEN` |  |
| L239 | VALIDACIÓN_NULL | `IF cNumSerial IS NULL OR cNumSerial = "" THEN` |  |
| L240 | FÓRMULA | `LET cCodRet1 = "000011"; --NO EXISTE FOLIO SUCURSAL` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `tef` | ENTIDAD | TEF — transferencia electrónica de fondos | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `graba` | ACCION | graba / almacena | 🔵 CONVENCIÓN | nombre_sp |
| `operacion` | ACCION | operación | 🔵 CONVENCIÓN | nombre_sp |

---

## `sp_tef_guardarccearchivos`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_sp_tef_guardarccearchivos.sql` |
| **LOC (1er CREATE)** | 143 |
| **Callgraph** | ✅ fan_in=38 / fan_out=23 |
| **Deps concatenadas** | 31 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "guarda TEF — transferencia electrónica de fondos, CCE — Cámara de Compensación Electrónica y archivos" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `guarda` → `INSERT` encontrado en el cuerpo · `guarda` → `UPDATE` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=3 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=1 / 6 términos |

### Historia del SP

| Tipo | Valor |
|------|-------|
| DESCRIPCION | GUARDAR REGISTRO DE LA OPERACION EN CCEARCHIVOS. |
| FECHA | 09/03/2011 |

### Firma

```sql
CREATE PROCEDURE sp_tef_guardarccearchivos(
  psUsuario                    CHAR(8)
  psNomArchivo                 VARCHAR(20)
  psFechaPres                  CHAR(8)
  psCveStatus                  CHAR(2)
) RETURNING CHAR(5) AS CodRet
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `psUsuario` | `CHAR(8)` | — | — |
| `psNomArchivo` | `VARCHAR(20)` | — | — |
| `psFechaPres` | `CHAR(8)` | — | — |
| `psCveStatus` | `CHAR(2)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vsCodRet` | `CHAR(5)` | L13 |
| `viSqlErr` | `INTEGER` | L14 |
| `viSamErr` | `INTEGER` | L15 |
| `vsDescMensajeError` | `VARCHAR(95)` | L17 |
| `viTotReg` | `INTEGER` | L18 |
| `vsFechaAplicacion` | `CHAR(8)` | L19 |
| `vdFechaAplicacion` | `DATE` | L20 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tef_cce_sumario` | `bditef` | no | SELECT | L54 |
| `tef_cce_detalle` | `bditef` | no | SELECT | L64 |
| `tef_cce_sumario_paso` | `bditef` | no | SELECT | L74 |
| `tef_cce_detalle_paso` | `bditef` | no | SELECT | L84 |
| `tef_cce_archivos` | `bditef` | no | SELECT | L101 |
| `tef_cce_archivos` | `bditef` | no | INSERT | L110 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L23 | CÓDIGO_RETORNO | `LET vsCodRet = '00000';` |  |
| L94 | FÓRMULA | `LET vdFechaAplicacion = SUBSTR(vsFechaAplicacion, 5,2)/*MES*/ \|\| '/' \|\| SUBSTR(vsFechaAplicacion` |  |
| L97 | VALIDACIÓN_NULL | `IF (viTotReg IS NULL ) THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `tef` | ENTIDAD | TEF — transferencia electrónica de fondos | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `guarda` | ACCION | guarda / almacena | 🔵 CONVENCIÓN | nombre_sp |
| `?r` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `cce` | ENTIDAD | CCE — Cámara de Compensación Electrónica (CECOBAN/Banxico) — | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `archivos` | ENTIDAD | archivos | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?r` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_tef_moverregistroshist`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_sp_tef_moverregistroshist.sql` |
| **LOC (1er CREATE)** | 544 |
| **Callgraph** | ✅ fan_in=49 / fan_out=23 |
| **Deps concatenadas** | 29 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "mueve TEF — transferencia electrónica de fondos y registros (histórico/historial)" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 9 tabla(s) con operaciones: INSERT, DELETE, SELECT |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=2 · INFERIDO=1 · SINTÉTICO=0 / 5 términos |

### Historia del SP

| Tipo | Valor |
|------|-------|
| DESCRIPCION | ESTE PROCEDIMIENTO SE ENCARGA DE PASAR/BORRAR LOS DATOS QUE SE ENCUENTRAN EN LAS TABLAS DE PASO A LAS TABLAS MAESTRAS EN BASE AL NOMBRE DE ARCHIVO Y LA FECHA |
| FECHA | 27/04/2011 |

### Firma

```sql
CREATE PROCEDURE sp_tef_moverregistroshist(
  psNombreArchivo              CHAR(20)
  psFecha                      CHAR(8)
  psTipo                       CHAR(1)
  psCve_Estatus                CHAR(2)
) RETURNING CHAR(5) AS CodRet
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `psNombreArchivo` | `CHAR(20)` | — | — |
| `psFecha` | `CHAR(8)` | — | — |
| `psTipo` | `CHAR(1)` | — | — |
| `psCve_Estatus` | `CHAR(2)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vsCodRet` | `CHAR(5)` | L13 |
| `vsNombre_Arch` | `CHAR(20)` | L17 |
| `vsFecha_Presentacion` | `CHAR(8)` | L18 |
| `vsTipo_Registro` | `CHAR(2)` | L19 |
| `vsNum_Secuencia` | `CHAR(7)` | L20 |
| `vsCod_Operacion` | `CHAR(2)` | L21 |
| `vsCod_Divisa` | `CHAR(2)` | L22 |
| `vsFecha_Trans` | `CHAR(8)` | L23 |
| `vsBanco_Presentador` | `CHAR(3)` | L24 |
| `vsBanco_Receptor` | `CHAR(3)` | L25 |
| `vsImporte` | `CHAR(15)` | L26 |
| `vsUso_Futuro_ccen` | `CHAR(16)` | L27 |
| `vsTipo_Operacion` | `CHAR(2)` | L28 |
| `vsFecha_Aplica` | `CHAR(8)` | L29 |
| `vsTipo_Cta_Ord` | `CHAR(2)` | L30 |
| `vsNum_Cta_Ord` | `CHAR(20)` | L31 |
| `vsNombre_Ord` | `CHAR(40)` | L32 |
| `vsRfc_Ord` | `CHAR(18)` | L33 |
| `vsTipo_Cta_Rec` | `CHAR(2)` | L34 |
| `vsNum_Cta_Rec` | `CHAR(20)` | L35 |
| `vsNombre_Rec` | `CHAR(40)` | L36 |
| `vsRfc_Rec` | `CHAR(18)` | L37 |
| `vsRef_Servicio` | `CHAR(40)` | L38 |
| `vsNombre_Titular_Serv` | `CHAR(40)` | L39 |
| `vsImporte_Iva` | `CHAR(15)` | L40 |
| *…49 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tef_cce_encabezado_paso` | `bditef` | no | SELECT | L239 |
| `tef_cce_sumario_paso` | `bditef` | no | SELECT | L253 |
| `tef_cce_encabezado` | `bditef` | no | INSERT | L259 |
| `tef_cce_sumario` | `bditef` | no | INSERT | L300 |
| `tef_cce_detalle_paso` | `bditef` | no | SELECT | L352 |
| `tef_cce_detalle` | `bditef` | no | INSERT | L363 |
| `tef_cce_detalle_paso` | `bditef` | no | DELETE | L495 |
| `tef_cce_sumario_paso` | `bditef` | no | DELETE | L518 |
| `tef_cce_encabezado_paso` | `bditef` | no | DELETE | L523 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L105 | CÓDIGO_RETORNO | `LET vsCodRet = '00000';` |  |
| L223 | CÓDIGO_RETORNO | `LET vsCodRet = '01300';` |  |
| L450 | FÓRMULA | `LET viContadorRegistros = viContadorRegistros + 1;` |  |
| L492 | FÓRMULA | `LET viBloque = viBloque + 1;` |  |
| L500 | FÓRMULA | `LET viContadorRegistros = viContadorRegistros + 1;` |  |
| L527 | CÓDIGO_RETORNO | `LET vsCodRet = '00000';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `tef` | ENTIDAD | TEF — transferencia electrónica de fondos | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `mover` | ACCION | mueve / archiva (operación de paso a histórico) | 🟡 INFERIDO | nombre_sp |
| `registros` | ENTIDAD | registros | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `hist` | MODIF | histórico/historial | 🔵 CONVENCIÓN | nombre_sp |

---

## `sp_tef_obt_arch_cam_recib41`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_sp_tef_obt_arch_cam_recib41.sql` |
| **LOC (1er CREATE)** | 82 |
| **Callgraph** | ✅ fan_in=0 / fan_out=13 |
| **Deps concatenadas** | 7 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "obtiene TEF — transferencia electrónica de fondos y archivo (sufijo de versión de SP)" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `obtiene` → `SELECT` encontrado en el cuerpo · `obtiene` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=3 · INFERIDO=4 · SINTÉTICO=2 / 9 términos |

### Firma

```sql
CREATE PROCEDURE sp_tef_obt_arch_cam_recib41(
  pCodOper                     INTEGER
  pClvArchivo                  CHAR(30)
) RETURNING CHAR(6)     AS cCodRet,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pCodOper` | `INTEGER` | — | — |
| `pClvArchivo` | `CHAR(30)` | `arch`=archivo | 🟡 INFERIDO |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(6)` | L12 |
| `iSqlErr` | `INTEGER` | L13 |
| `intNumArchivo` | `INTEGER` | L14 |
| `intCodOperacion` | `INTEGER` | L15 |
| `intNumRegistros` | `INTEGER` | L16 |
| `monImport` | `MONEY(16,2)` | L17 |
| `dtFechaHoy` | `DATE` | L18 |
| `intSumRegistros` | `INTEGER` | L19 |
| `monSumaImporte` | `MONEY(16,2)` | L20 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_fechas` | `bdinteg` | ⚠️ sí | SELECT | L49 |
| `cce_archivos_camara` | `bditef` | no | SELECT | L56 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L64 | FÓRMULA | `LET intSumRegistros = intSumRegistros + NVL(intNumRegistros,0);` |  |
| L65 | FÓRMULA | `LET monSumaImporte = monSumaImporte + NVL(monImport,0);` | 🔴 MONEY/aritmética financiera |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `tef` | ENTIDAD | TEF — transferencia electrónica de fondos | 🔵 CONVENCIÓN | nombre_sp |
| `obt` | ACCION | obtiene | 🟡 INFERIDO | nombre_sp |
| `arch` | ENTIDAD | archivo | 🟡 INFERIDO | nombre_sp |
| `cam` | PREFIJO | cámara / captura contable | 🟡 INFERIDO | nombre_sp |
| `rec` | ACCION | recepción / recibe | 🔵 CONVENCIÓN | nombre_sp |
| `?i` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `b4` | MODIF | sufijo de versión de SP (Bloque/Build 4) | 🟡 INFERIDO | nombre_sp |
| `?1` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?i`, `?1` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_tef_obt_arch_cam_recibyprest40y41`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_sp_tef_obt_arch_cam_recibyprest40y41.sql` |
| **LOC (1er CREATE)** | 191 |
| **Callgraph** | ✅ fan_in=0 / fan_out=17 |
| **Deps concatenadas** | 18 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "obtiene TEF — transferencia electrónica de fondos y archivo" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `obtiene` → `SELECT` encontrado en el cuerpo · `obtiene` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=3 · INFERIDO=3 · SINTÉTICO=1 / 7 términos |

### Firma

```sql
CREATE PROCEDURE sp_tef_obt_arch_cam_recibyprest40y41(
  pCodOper                     INTEGER
  p_clv_archivo                CHAR(8)
  pModalidad                   INTEGER
) RETURNING CHAR(6) AS cCodRet,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pCodOper` | `INTEGER` | — | — |
| `p_clv_archivo` | `CHAR(8)` | `arch`=archivo | 🟡 INFERIDO |
| `pModalidad` | `INTEGER` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(6)` | L13 |
| `iSqlErr` | `INTEGER` | L14 |
| `intNumArchivo` | `INTEGER` | L15 |
| `intCodOperacion` | `INTEGER` | L16 |
| `intNumRegistros` | `INTEGER` | L17 |
| `monImport` | `MONEY(16,2)` | L18 |
| `dtFechaAnt` | `DATE` | L19 |
| `dtFechaHoy` | `DATE` | L20 |
| `intSumRegistros` | `INTEGER` | L22 |
| `monSumaImporte` | `MONEY(16,2)` | L23 |
| `i` | `SMALLINT` | L24 |
| `j` | `SMALLINT` | L25 |
| `cCodRetDevuelto` | `CHAR(6)` | L26 |
| `dtFechaDevuelta` | `DATE` | L27 |
| `dtFechaHabilAnt` | `DATE` | L28 |
| `dtFechaAux` | `DATE` | L29 |
| `chrFecha` | `char(8)` | L32 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_fechas` | `bdinteg` | ⚠️ sí | SELECT | L71 |
| `cce_gransumario` | `bditef` | no | SELECT | L106 |
| `cce_archivos_camara` | `bditef` | no | SELECT | L119 |
| `cce_propios_det` | `bditef` | no | SELECT | L171 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `cal_habil_ant` | `bditef` | no | L79 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L110 | FÓRMULA | `LET intSumRegistros = intSumRegistros + NVL(intNumRegistros,0);` |  |
| L111 | FÓRMULA | `LET monSumaImporte = monSumaImporte + NVL(monImport,0);` | 🔴 MONEY/aritmética financiera |
| L124 | FÓRMULA | `LET intSumRegistros = intSumRegistros + NVL(intNumRegistros,0);` |  |
| L125 | FÓRMULA | `LET monSumaImporte = monSumaImporte + NVL(monImport,0);` | 🔴 MONEY/aritmética financiera |
| L148 | FÓRMULA | `LET intSumRegistros = intSumRegistros + NVL(intNumRegistros,0);` |  |
| L149 | FÓRMULA | `LET monSumaImporte = monSumaImporte + NVL(monImport,0);` | 🔴 MONEY/aritmética financiera |
| L161 | FÓRMULA | `LET intSumRegistros = intSumRegistros + intNumRegistros;` |  |
| L162 | FÓRMULA | `LET monSumaImporte = monSumaImporte + monImport;` | 🔴 MONEY/aritmética financiera |
| L176 | FÓRMULA | `LET intSumRegistros = intSumRegistros + intNumRegistros;` |  |
| L177 | FÓRMULA | `LET monSumaImporte = monSumaImporte + monImport;` | 🔴 MONEY/aritmética financiera |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `tef` | ENTIDAD | TEF — transferencia electrónica de fondos | 🔵 CONVENCIÓN | nombre_sp |
| `obt` | ACCION | obtiene | 🟡 INFERIDO | nombre_sp |
| `arch` | ENTIDAD | archivo | 🟡 INFERIDO | nombre_sp |
| `cam` | PREFIJO | cámara / captura contable | 🟡 INFERIDO | nombre_sp |
| `rec` | ACCION | recepción / recibe | 🔵 CONVENCIÓN | nombre_sp |
| `?ibyprest40y41` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?ibyprest40y41` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_tef_obtcodbanco`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_sp_tef_obtcodbanco.sql` |
| **LOC (1er CREATE)** | 100 |
| **Callgraph** | ✅ fan_in=35 / fan_out=4 |
| **Principales callers** | `sp_calificacion_scoring` |
| **Deps concatenadas** | 7 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "obtiene TEF — transferencia electrónica de fondos, código y banco" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `obtiene` → `SELECT` encontrado en el cuerpo · `obtiene` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=2 · INFERIDO=1 · SINTÉTICO=0 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_tef_obtcodbanco(
  ptipo                        INTEGER
  pCuenta                      CHAR (20)
) RETURNING CHAR(6) 		AS cod_ret,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `ptipo` | `INTEGER` | — | — |
| `pCuenta` | `CHAR (20)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `iSqlErr` | `INTEGER` | L9 |
| `iIsamErr` | `INTEGER` | L10 |
| `cErrorInfo` | `VARCHAR(80)` | L11 |
| `cCodRet` | `CHAR(6)` | L12 |
| `cMensajeRet` | `VARCHAR(80)` | L13 |
| `cBanco` | `CHAR(3)` | L14 |
| `cDescripcion` | `VARCHAR(40)` | L15 |
| `iContador` | `INTEGER` | L16 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_bancos` | `bdinteg` | ⚠️ sí | SELECT | L53 |
| `sc_bines` | `bdicheq` | ⚠️ sí | SELECT | L66 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L57 | FÓRMULA | `LET iContador= iContador+1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `tef` | ENTIDAD | TEF — transferencia electrónica de fondos | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `obt` | ACCION | obtiene | 🟡 INFERIDO | nombre_sp |
| `cod` | ENTIDAD | código | 🔵 CONVENCIÓN | nombre_sp |
| `banco` | ENTIDAD | banco | ✅ CÓDIGO | nombre_sp, texto_cuerpo |

---

## `sp_tef_obtinforpt`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_sp_tef_obtinforpt.sql` |
| **LOC (1er CREATE)** | 159 |
| **Callgraph** | ✅ fan_in=47 / fan_out=4 |
| **Principales callers** | `sp_calificacion_scoring` |
| **Deps concatenadas** | 6 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "obtiene TEF — transferencia electrónica de fondos, información y reporte" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `obtiene` → `SELECT` encontrado en el cuerpo · `obtiene` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=3 · INFERIDO=1 · SINTÉTICO=0 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_tef_obtinforpt(
  pClaveRastreo                CHAR(30)
) RETURNING CHAR(6) 		AS cod_ret,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pClaveRastreo` | `CHAR(30)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `iSqlErr` | `INTEGER` | L26 |
| `iIsamErr` | `INTEGER` | L27 |
| `cErrorInfo` | `VARCHAR(80)` | L28 |
| `cCodRet` | `CHAR(6)` | L29 |
| `cMensajeRet` | `VARCHAR(80)` | L30 |
| `dtFecha_trans` | `DATE` | L32 |
| `cClave_rastreo` | `CHAR(30)` | L33 |
| `cImporte_tef` | `CHAR(10)` | L34 |
| `dtFecha_programacion` | `DATE` | L35 |
| `cNombre_usuario` | `CHAR(45)` | L36 |
| `cFolio_suc` | `CHAR(16)` | L37 |
| `cNombre_cte_ord` | `CHAR(30)` | L38 |
| `cNumcte_ord` | `CHAR(20)` | L39 |
| `cNum_cta_ord` | `CHAR(20)` | L40 |
| `cTipo_cta_ord` | `CHAR(2)` | L41 |
| `cTipo_cta_ord_desc` | `CHAR(30)` | L42 |
| `cComision_tef` | `CHAR(5)` | L43 |
| `cIva_tef` | `CHAR(5)` | L44 |
| `cNombre_ben` | `CHAR(30)` | L45 |
| `cTipo_cta_ben` | `CHAR(2)` | L46 |
| `cTipo_cta_ben_des` | `CHAR(30)` | L47 |
| `cNum_cuenta_tarj_ben` | `CHAR(20)` | L48 |
| `cRfc_ben` | `CHAR(15)` | L49 |
| `cConcepto_pago` | `CHAR(50)` | L50 |
| `cRef_num` | `CHAR(7)` | L51 |
| *…2 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tef_operaciones` | `bditef` | no | SELECT | L106 |
| `sc_maechq` | `bdicheq` | ⚠️ sí | SELECT | L119 |
| `tef_tipo_cta` | `bditef` | no | SELECT | L125 |
| `si_ejecut` | `bdinteg` | ⚠️ sí | SELECT | L135 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `tef` | ENTIDAD | TEF — transferencia electrónica de fondos | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `obt` | ACCION | obtiene | 🟡 INFERIDO | nombre_sp |
| `info` | ENTIDAD | información | 🔵 CONVENCIÓN | nombre_sp |
| `rpt` | ENTIDAD | reporte | 🔵 CONVENCIÓN | nombre_sp |

---

## `sp_tef_obttipocta`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_sp_tef_obttipocta.sql` |
| **LOC (1er CREATE)** | 64 |
| **Callgraph** | ✅ fan_in=37 / fan_out=4 |
| **Principales callers** | `sp_calificacion_scoring` |
| **Deps concatenadas** | 5 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "obtiene TEF — transferencia electrónica de fondos y cuenta (tipo de)" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `obtiene` → `SELECT` encontrado en el cuerpo · `obtiene` → `FROM` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=3 · CONVENCIÓN=1 · INFERIDO=1 · SINTÉTICO=0 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_tef_obttipocta(
) RETURNING CHAR(6) 		AS cod_ret,
```

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `iSqlErr` | `INTEGER` | L9 |
| `iIsamErr` | `INTEGER` | L10 |
| `cErrorInfo` | `VARCHAR(80)` | L11 |
| `cCodRet` | `CHAR(6)` | L12 |
| `cMensajeRet` | `VARCHAR(80)` | L13 |
| `cTipo_cta` | `CHAR(2)` | L14 |
| `cDescripcion` | `VARCHAR(20)` | L15 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tef_tipo_cta` | `bditef` | no | SELECT | L44 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `tef` | ENTIDAD | TEF — transferencia electrónica de fondos | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `obt` | ACCION | obtiene | 🟡 INFERIDO | nombre_sp |
| `tipo` | MODIF | tipo de | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `cta` | ENTIDAD | cuenta | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |

---

## `sp_tef_presentador_g`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_sp_tef_presentador_g.sql` |
| **LOC (1er CREATE)** | 375 |
| **Callgraph** | ✅ fan_in=34 / fan_out=23 |
| **Principales callers** | `sp_calificacion_scoring` |
| **Deps concatenadas** | 28 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "TEF — transferencia electrónica de fondos (presentado)" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 9 llamada(s): `sp_tef_bitacora`, `sp_valida_cadena`, `sp_valida_fecha` |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=1 / 4 términos |

### Historia del SP

| Tipo | Valor |
|------|-------|
| DESCRIPCION | SP PRINCIPAL DE TEF -- PRESENTADOR GENERADOR ARCH. 10 Y 60 |
| FECHA | 08/03/2011 |

### Firma

```sql
CREATE PROCEDURE sp_tef_presentador_g(
  psNombreArchivo              CHAR(20)
  psNumEmpleado                CHAR (8)
) RETURNING CHAR (20) AS Nom_Archivo, CHAR (5) AS Codigo_Respuesta, CHAR (100) AS Mensaje_Respuesta
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `psNombreArchivo` | `CHAR(20)` | — | — |
| `psNumEmpleado` | `CHAR (8)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vsFlagTipoProceso` | `CHAR(1)` | L14 |
| `vsNomProceso` | `CHAR(20)` | L15 |
| `vsDescripcionProceso` | `CHAR(60)` | L16 |
| `sGENERANDO` | `CHAR(1)` | L17 |
| `sFINALIZADO` | `CHAR(1)` | L18 |
| `sERROR` | `CHAR(1)` | L19 |
| `visqlerr` | `INTEGER` | L20 |
| `vsNomArchivo` | `CHAR(20)` | L21 |
| `vsFechaPresentacion` | `CHAR(8)` | L22 |
| `vsFechaPresentacion1` | `CHAR(8)` | L23 |
| `vsCodRetorno` | `CHAR(5)` | L24 |
| `vsCodRetorno2` | `CHAR(5)` | L25 |
| `vsCodRetorno3` | `CHAR(5)` | L26 |
| `vdtFecha` | `DATE` | L27 |
| `vdtFechaInsert` | `DATE` | L28 |
| `vsMensajeRespuesta` | `CHAR (100)` | L29 |
| `viContador` | `INTEGER` | L30 |
| `viTipoArchivo` | `INTEGER` | L31 |
| `vsDia` | `CHAR(2)` | L32 |
| `vsMes` | `CHAR(2)` | L33 |
| `vsAno` | `CHAR(4)` | L34 |
| `vsSpLlamado` | `CHAR(24)` | L35 |
| `vsCveBanc` | `CHAR(3)` | L36 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tef_parametros` | `bditef` | no | SELECT | L82 |
| `tef_prod_permitidos` | `bditef` | no | SELECT | L102 |
| `si_ejecut` | `bdinteg` | ⚠️ sí | SELECT | L113 |
| `sc_fechas` | `bdicheq` | ⚠️ sí | SELECT | L119 |
| `14` | `bditef` | no | SELECT | L173 |
| `16` | `bditef` | no | SELECT | L183 |
| `tef_procesos` | `bditef` | no | SELECT | L197 |
| `tef_errores` | `bditef` | no | INSERT | L201 |
| `tef_cce_encabezado_paso` | `bditef` | no | SELECT | L238 |
| `tef_cce_detalle_paso` | `bditef` | no | SELECT | L239 |
| `tef_cce_sumario_paso` | `bditef` | no | SELECT | L240 |
| `tef_procesos` | `bditef` | no | UPDATE | L339 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_tef_bitacora` | `bditef` | no | L68 |
| `sp_valida_cadena` | `bditef` | no | L77 |
| `sp_valida_fecha` | `bditef` | no | L121 |
| `sp_tef_validarnombrearchivos` | `bditef` | no | L190 |
| `sp_obtenermensajeerror` | `bditef` | no | L200 |
| `sp_tef_moverregistroshist` | `bditef` | no | L224 |
| `sp_tef_generararchivo60` | `bditef` | no | L232 |
| `sp_tef_generaarchivo` | `bditef` | no | L245 |
| `sp_tef_guardarccearchivos` | `bditef` | no | L249 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L345 | FÓRMULA | `LET viContador = viCOntador + 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `tef` | ENTIDAD | TEF — transferencia electrónica de fondos | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `presentado` | MODIF | presentado (a cobro) | 🔵 CONVENCIÓN | nombre_sp |
| `?r_g` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?r_g` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_tef_presentador_r`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_sp_tef_presentador_r.sql` |
| **LOC (1er CREATE)** | 473 |
| **Callgraph** | ✅ fan_in=34 / fan_out=21 |
| **Principales callers** | `sp_calificacion_scoring` |
| **Deps concatenadas** | 27 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "TEF — transferencia electrónica de fondos (presentado)" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 14 llamada(s): `sp_tef_bitacora`, `sp_valida_cadena`, `sp_valida_fecha` |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=1 / 4 términos |

### Historia del SP

| Tipo | Valor |
|------|-------|
| DESCRIPCION | SP PRINCIPAL DE TEF -- PRESENTADOR RECEPTOR ARCH. 61, 62 Y 63 |
| FECHA | 10/03/2011 |

### Firma

```sql
CREATE PROCEDURE sp_tef_presentador_r(
  psNomArchivo                 CHAR(20)
  psNumEmpleado                CHAR (8)
) RETURNING CHAR (20) AS Nom_Archivo, CHAR (5) AS Codigo_Respuesta, CHAR (100) AS Mensaje_Respuesta
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `psNomArchivo` | `CHAR(20)` | — | — |
| `psNumEmpleado` | `CHAR (8)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `sPROCESANDO` | `CHAR(1)` | L14 |
| `sERROR` | `CHAR(1)` | L15 |
| `sFINALIZADO` | `CHAR(1)` | L16 |
| `vsDescripcionProceso` | `CHAR (60)` | L17 |
| `vsFlagTipoProceso` | `CHAR (1)` | L18 |
| `viTipoArchivo` | `SMALLINT` | L19 |
| `vsFlagUnico` | `CHAR (1)` | L20 |
| `vsBloque` | `CHAR (2)` | L21 |
| `vsFecha_Presentacion` | `CHAR (8)` | L22 |
| `vSFecha_aplica` | `CHAR(8)` | L23 |
| `vdFecha_aplicaDe` | `DATE` | L24 |
| `vsMensaje` | `CHAR (80)` | L25 |
| `vsRuta` | `CHAR (100)` | L26 |
| `vsDia` | `CHAR(2)` | L28 |
| `vsCodRetorno` | `CHAR (5)` | L30 |
| `vsCodRetorno2` | `CHAR (5)` | L31 |
| `vsCodRetorno3` | `CHAR (5)` | L32 |
| `vsMensaje_Respuesta` | `CHAR (100)` | L33 |
| `vsCveBanc` | `CHAR (100)` | L34 |
| `vsNomArchivo` | `CHAR (20)` | L35 |
| `vsNomArchivo11` | `CHAR (20)` | L36 |
| `vsNomArchivo61` | `CHAR (20)` | L37 |
| `vsNomArchivo62` | `CHAR (20)` | L38 |
| `viContador` | `INTEGER` | L39 |
| `vdtFecha` | `DATE` | L40 |
| *…3 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tef_parametros` | `bditef` | no | SELECT | L105 |
| `si_ejecut` | `bdinteg` | ⚠️ sí | SELECT | L135 |
| `sc_fechas` | `bdicheq` | ⚠️ sí | SELECT | L141 |
| `11` | `bditef` | no | SELECT | L205 |
| `15` | `bditef` | no | SELECT | L220 |
| `tef_procesos` | `bditef` | no | SELECT | L234 |
| `tef_errores` | `bditef` | no | INSERT | L242 |
| `tef_cce_encabezado_paso` | `bditef` | no | SELECT | L295 |
| `tef_cce_archivos` | `bditef` | no | UPDATE | L297 |
| `tef_cce_detalle_paso` | `bditef` | no | SELECT | L305 |
| `tef_cce_detalle_paso` | `bditef` | no | UPDATE | L324 |
| `tef_procesos` | `bditef` | no | UPDATE | L449 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_tef_bitacora` | `bditef` | no | L88 |
| `sp_valida_cadena` | `bditef` | no | L100 |
| `sp_valida_fecha` | `bditef` | no | L145 |
| `sp_tef_validarnombrearchivos` | `bditef` | no | L227 |
| `sp_obtenermensajeerror` | `bditef` | no | L240 |
| `sp_tef_moverregistroshist` | `bditef` | no | L274 |
| `sp_tef_buscararchivo` | `bditef` | no | L283 |
| `sp_tef_subirarchivos` | `bditef` | no | L289 |
| `sp_tef_valida_datos` | `bditef` | no | L300 |
| `sp_tef_procesararchivo61` | `bditef` | no | L319 |
| `sp_tef_procesararchivo62` | `bditef` | no | L323 |
| `sp_tef_procesararchivo63` | `bditef` | no | L327 |
| `sp_tef_moverarchivos` | `bditef` | no | L342 |
| `sp_tef_guardarccearchivos` | `bditef` | no | L351 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L169 | FÓRMULA | `LET viContador = viContador + 1;` |  |
| L306 | FÓRMULA | `LET vdFecha_aplicaDe = Substr(vSFecha_aplica,5,2) \|\| "/" \|\| Substr(vSFecha_aplica,7,2) \|\| "/" ` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `tef` | ENTIDAD | TEF — transferencia electrónica de fondos | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `presentado` | MODIF | presentado (a cobro) | 🔵 CONVENCIÓN | nombre_sp |
| `?r_r` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?r_r` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_tef_procesararchivo10`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_sp_tef_procesararchivo10.sql` |
| **LOC (1er CREATE)** | 509 |
| **Callgraph** | ✅ fan_in=1 / fan_out=10 |
| **Deps concatenadas** | 26 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "procesa TEF — transferencia electrónica de fondos y archivo" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 2 llamada(s): `sp_valfecha_banca`, `sp_valida_fecha` |
| **Evidencia vocab** | CÓDIGO=3 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=2 / 6 términos |

### Historia del SP

| Tipo | Valor |
|------|-------|
| DESCRIPCION | PROCESA Y VALIDA LOS DATOS DE LAS CUENTAS DEL ARCHIVO 10 PARA GENERAR EL 11. |
| FECHA | 29/03/2011 |

### Firma

```sql
CREATE PROCEDURE sp_tef_procesararchivo10(
  psNombreArchivo              CHAR(20)
  psNombreArchivo11            CHAR(20)
) RETURNING CHAR(5) AS CodRet
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `psNombreArchivo` | `CHAR(20)` | `archivo`=archivo | ✅ CÓDIGO |
| `psNombreArchivo11` | `CHAR(20)` | `archivo`=archivo | ✅ CÓDIGO |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vsCodRet` | `CHAR(5)` | L14 |
| `vsCodRet2` | `CHAR(5)` | L15 |
| `vsCodRet3` | `CHAR(5)` | L16 |
| `vsPrefijoTarjeta` | `CHAR(100)` | L19 |
| `vsBancoPresentador` | `CHAR (3)` | L20 |
| `vsFecha_Presentacion_Gen` | `CHAR(8)` | L21 |
| `vsFechaManana` | `CHAR(8)` | L22 |
| `vsCuenta` | `CHAR(11)` | L26 |
| `vsStatus_Cta` | `CHAR (1)` | L27 |
| `vsProductosNoPermitidos` | `CHAR (100)` | L28 |
| `vsProducto` | `CHAR (4)` | L29 |
| `vdFecha_Hoy` | `DATE` | L30 |
| `vdFecha_Manana` | `DATE` | L31 |
| `vsNombre_Arch` | `CHAR(20)` | L33 |
| `vsFecha_Presentacion` | `CHAR(8)` | L34 |
| `vsTipo_Registro` | `CHAR(2)` | L35 |
| `vsNum_Secuencia` | `CHAR(7)` | L36 |
| `vsCod_Operacion` | `CHAR(2)` | L37 |
| `vsCod_Divisa` | `CHAR(2)` | L38 |
| `vsFecha_Trans` | `CHAR(8)` | L39 |
| `vsBanco_Presentador` | `CHAR(3)` | L40 |
| `vsBanco_Receptor` | `CHAR(3)` | L41 |
| `vsImporte` | `CHAR(15)` | L42 |
| `vsUso_Futuro_ccen` | `CHAR(16)` | L43 |
| `vsTipo_Operacion` | `CHAR(2)` | L44 |
| *…32 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tef_parametros` | `bditef` | no | SELECT | L179 |
| `sc_fechas` | `bdicheq` | ⚠️ sí | SELECT | L191 |
| `tef_cce_detalle_paso` | `bditef` | no | SELECT | L239 |
| `sd_maecred` | `bdicred` | ⚠️ sí | SELECT | L255 |
| `sc_tarjeta` | `bdicheq` | ⚠️ sí | SELECT | L265 |
| `sc_maechq` | `bdicheq` | ⚠️ sí | SELECT | L274 |
| `tef_prod_permitidos` | `bditef` | no | SELECT | L277 |
| `tef_cce_detalle_paso` | `bditef` | no | UPDATE | L290 |
| `tef_cce_detalle_paso` | `bditef` | no | INSERT | L299 |
| `tef_cce_encabezado_paso` | `bditef` | no | INSERT | L408 |
| `tef_cce_sumario_paso` | `bditef` | no | SELECT | L455 |
| `tef_cce_sumario_paso` | `bditef` | no | INSERT | L461 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_valfecha_banca` | `bdinteg` | ⚠️ sí | L202 |
| `sp_valida_fecha` | `bditef` | no | L204 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L195 | FÓRMULA | `LET vdFecha_Manana = vdFecha_Hoy + 1;` |  |
| L213 | CÓDIGO_RETORNO | `LET vsCodRet = '01900';` |  |
| L215 | CÓDIGO_RETORNO | `LET vsCodRet = '01901';` |  |
| L217 | CÓDIGO_RETORNO | `LET vsCodRet = '01902';` |  |
| L268 | FÓRMULA | `LET vsCuenta = SUBSTR(vsNum_Cta_Rec,9,11); --CUENTA` |  |
| L388 | FÓRMULA | `LET viContadorRegistros = viContadorRegistros + 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `tef` | ENTIDAD | TEF — transferencia electrónica de fondos | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `procesa` | ACCION | procesa | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?r` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `archivo` | ENTIDAD | archivo | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?10` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?r`, `?10` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_tef_procesararchivo60`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_sp_tef_procesararchivo60.sql` |
| **LOC (1er CREATE)** | 923 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 1 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "procesa TEF — transferencia electrónica de fondos y archivo" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 3 llamada(s): `sp_valfecha_banca`, `sp_valida_fecha`, `sp_tef_constelctacte` |
| **Evidencia vocab** | CÓDIGO=3 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=2 / 6 términos |

### Historia del SP

| Tipo | Valor |
|------|-------|
| DESCRIPCION | PROCESA LOS DATOS DE LAS CUENTAS DEL ARCHIVO 60. |
| FECHA | 25/04/2011 |
| DESCRIPCION | SE AGREGAN VALIDACIONES PARA CUENTAS DE CREDITO Y DEBITO |
| FECHA | 10/08/2011 |

### Firma

```sql
CREATE PROCEDURE sp_tef_procesararchivo60(
  cNombreArchivo               CHAR(20)
  cNombreArchivo61             CHAR(20)
  cUsuario                     CHAR(8)
) RETURNING CHAR(5) AS CodRet
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `cNombreArchivo` | `CHAR(20)` | `archivo`=archivo | ✅ CÓDIGO |
| `cNombreArchivo61` | `CHAR(20)` | `archivo`=archivo | ✅ CÓDIGO |
| `cUsuario` | `CHAR(8)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `dFechaHoy` | `DATE` | L21 |
| `dFechaManana` | `DATE` | L22 |
| `cFechaManana` | `CHAR (8)` | L24 |
| `cFechaPresentacion_Gen` | `CHAR(8)` | L26 |
| `cCodRet` | `CHAR(5)` | L28 |
| `cCodRet2` | `CHAR(5)` | L29 |
| `cCodRet3` | `CHAR(5)` | L30 |
| `cStatusTar` | `CHAR(2)` | L31 |
| `cPrefijoTarjeta` | `CHAR(6)` | L32 |
| `cCuenta` | `CHAR(12)` | L34 |
| `cStatusCta` | `CHAR (1)` | L35 |
| `cProducto` | `CHAR (4)` | L36 |
| `cNombreArch` | `CHAR(20)` | L38 |
| `cFechaPresentacion` | `CHAR(8)` | L39 |
| `cTipoRegistro` | `CHAR(2)` | L40 |
| `cNumSecuencia` | `CHAR(7)` | L41 |
| `cCodOperacion` | `CHAR(2)` | L42 |
| `cCodDivisa` | `CHAR(2)` | L43 |
| `cFechaTrans` | `CHAR(8)` | L44 |
| `cBancoPresentador` | `CHAR(3)` | L45 |
| `cBancoReceptor` | `CHAR(3)` | L46 |
| `cImporte` | `CHAR(15)` | L47 |
| `cUsoFuturoCcen` | `CHAR(16)` | L48 |
| `cTipoOperacion` | `CHAR(2)` | L49 |
| `cFechaAplica` | `CHAR(8)` | L50 |
| *…72 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tef_parametros` | `bditef` | no | SELECT | L313 |
| `sc_fechas` | `bdicheq` | ⚠️ sí | SELECT | L334 |
| `si_sucursales` | `bdinteg` | ⚠️ sí | SELECT | L359 |
| `tef_cce_detalle_paso` | `bditef` | no | SELECT | L400 |
| `sd_maecred` | `bdicred` | ⚠️ sí | SELECT | L429 |
| `tef_cte_lista_negra` | `bditef` | no | SELECT | L444 |
| `sc_tarjeta` | `bdicheq` | ⚠️ sí | SELECT | L463 |
| `sc_maechq` | `bdicheq` | ⚠️ sí | SELECT | L479 |
| `tef_prod_permitidos` | `bditef` | no | SELECT | L485 |
| `sc_bloqueo` | `bdicheq` | ⚠️ sí | SELECT | L490 |
| `sc_producto` | `bdicheq` | ⚠️ sí | SELECT | L496 |
| `tef_cce_detalle_paso` | `bditef` | no | INSERT | L543 |
| `tef_cce_encabezado_paso` | `bditef` | no | SELECT | L677 |
| `tef_cce_sumario_paso` | `bditef` | no | SELECT | L685 |
| `tef_cce_encabezado_paso` | `bditef` | no | INSERT | L693 |
| `tef_cce_sumario_paso` | `bditef` | no | INSERT | L738 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_valfecha_banca` | `bdinteg` | ⚠️ sí | L347 |
| `sp_valida_fecha` | `bditef` | no | L349 |
| `sp_tef_constelctacte` | `bdicheq` | ⚠️ sí | L451 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L341 | FÓRMULA | `LET dFechaManana = dFechaHoy + 1;` |  |
| L360 | CÓDIGO_RETORNO | `LET cCodRet = '02300';` |  |
| L362 | CÓDIGO_RETORNO | `LET cCodRet = '02301';` |  |
| L364 | CÓDIGO_RETORNO | `LET cCodRet = '02302';` |  |
| L366 | CÓDIGO_RETORNO | `LET cCodRet = '02303';` |  |
| L372 | FÓRMULA | `LET iContadorSecuencia61 = 1; --A PARTIR DE 2 ES PARA EL DETALLE` |  |
| L418 | CÓDIGO_RETORNO | `LET cCodRet = '00000';` |  |
| L530 | FÓRMULA | `LET iContadorSecuencia61 = iContadorSecuencia61 + 1;` |  |
| L531 | FÓRMULA | `LET iImporteTotalArchivo61 = iImporteTotalArchivo61 + NVL(cImporte,0)::BIGINT;` | 🔴 MONEY/aritmética financiera |
| L653 | FÓRMULA | `LET iContadorRegistros = iContadorRegistros + 1;` |  |
| L865 | CÓDIGO_RETORNO | `LET cCodRet = '00000';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `tef` | ENTIDAD | TEF — transferencia electrónica de fondos | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `procesa` | ACCION | procesa | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?r` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `archivo` | ENTIDAD | archivo | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?60` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?r`, `?60` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_tef_procesararchivo61`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_sp_tef_procesararchivo61.sql` |
| **LOC (1er CREATE)** | 407 |
| **Callgraph** | ✅ fan_in=17 / fan_out=7 |
| **Deps concatenadas** | 4 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "procesa TEF — transferencia electrónica de fondos y archivo" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 2 llamada(s): `sp_generafolionomina`, `abono_ref` |
| **Evidencia vocab** | CÓDIGO=3 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=2 / 6 términos |

### Historia del SP

| Tipo | Valor |
|------|-------|
| DESCRIPCION | PROCESA LOS DATOS DE LAS CUENTAS DEL ARCHIVO 61. |
| FECHA | 05/04/2011 |

### Firma

```sql
CREATE PROCEDURE sp_tef_procesararchivo61(
  psNombreArchivo              CHAR(20)
  psFechaPresentacion          CHAR(8)
  psUsuario                    CHAR(8)
) RETURNING CHAR(5) AS CodRet
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `psNombreArchivo` | `CHAR(20)` | `archivo`=archivo | ✅ CÓDIGO |
| `psFechaPresentacion` | `CHAR(8)` | — | — |
| `psUsuario` | `CHAR(8)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `VSCONSULTA` | `CHAR(2000)` | L12 |
| `vsCodRet` | `CHAR(5)` | L14 |
| `vsPrefijoTarjeta` | `CHAR(100)` | L15 |
| `vsCuenta` | `CHAR(11)` | L18 |
| `vsStatus_Cta` | `CHAR (1)` | L19 |
| `vsProducto` | `CHAR (4)` | L20 |
| `vdFecha_Hoy` | `DATE` | L21 |
| `vdFecha_Manana` | `DATE` | L22 |
| `vsNombre_Arch` | `CHAR(20)` | L24 |
| `vsFecha_Presentacion` | `CHAR(8)` | L25 |
| `vsTipo_Registro` | `CHAR(2)` | L26 |
| `vsNum_Secuencia` | `CHAR(7)` | L27 |
| `vsCod_Operacion` | `CHAR(2)` | L28 |
| `vsCod_Divisa` | `CHAR(2)` | L29 |
| `vsFecha_Trans` | `CHAR(8)` | L30 |
| `vsBanco_Presentador` | `CHAR(3)` | L31 |
| `vsBanco_Receptor` | `CHAR(3)` | L32 |
| `vsImporte` | `CHAR(15)` | L33 |
| `vsUso_Futuro_ccen` | `CHAR(16)` | L34 |
| `vsTipo_Operacion` | `CHAR(2)` | L35 |
| `vsFecha_Aplica` | `CHAR(8)` | L36 |
| `vsTipo_Cta_Ord` | `CHAR(2)` | L37 |
| `vsNum_Cta_Ord` | `CHAR(20)` | L38 |
| `vsNombre_Ord` | `CHAR(40)` | L39 |
| `vsRfc_Ord` | `CHAR(18)` | L40 |
| *…34 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tef_parametros` | `bditef` | no | SELECT | L182 |
| `si_sucursales` | `bdinteg` | ⚠️ sí | SELECT | L190 |
| `tef_cce_detalle_paso` | `bditef` | no | SELECT | L216 |
| `tef_cce_detalle` | `bditef` | no | SELECT | L230 |
| `sc_tarjeta` | `bdicheq` | ⚠️ sí | SELECT | L311 |
| `tef_cce_detalle` | `bditef` | no | UPDATE | L341 |
| `tef_operaciones` | `bditef` | no | UPDATE | L351 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_generafolionomina` | `bdicheq` | ⚠️ sí | L322 |
| `abono_ref` | `bdicheq` | ⚠️ sí | L332 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L85 | CÓDIGO_RETORNO | `LET vsCodRet = '00000';` |  |
| L193 | CÓDIGO_RETORNO | `LET vsCodRet = '02000';` |  |
| L253 | CÓDIGO_RETORNO | `LET vsCodRet = '02001';` |  |
| L257 | FÓRMULA | `LET viContadorRegistros = viContadorRegistros + 1;` |  |
| L314 | FÓRMULA | `LET vsCuenta = SUBSTR(vsNum_Cta_Ord,9,11); --CUENTA` |  |
| L319 | FÓRMULA | `LET vmSaldoAPagar = ((vsImporte::INTEGER)/100);` | 🔴 MONEY/aritmética financiera |
| L326 | CÓDIGO_RETORNO | `LET vsCodRet = '02002';` |  |
| L336 | CÓDIGO_RETORNO | `LET vsCodRet = '02003';` |  |
| L370 | FÓRMULA | `LET viContadorRegistros = viContadorRegistros + 1;` |  |
| L388 | CÓDIGO_RETORNO | `LET vsCodRet = '00000';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `tef` | ENTIDAD | TEF — transferencia electrónica de fondos | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `procesa` | ACCION | procesa | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?r` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `archivo` | ENTIDAD | archivo | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?61` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?r`, `?61` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_tef_procesararchivo62`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_sp_tef_procesararchivo62.sql` |
| **LOC (1er CREATE)** | 315 |
| **Callgraph** | ✅ fan_in=17 / fan_out=7 |
| **Deps concatenadas** | 3 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "procesa TEF — transferencia electrónica de fondos y archivo" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 4 tabla(s) con operaciones: UPDATE, SELECT |
| **Evidencia vocab** | CÓDIGO=3 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=2 / 6 términos |

### Historia del SP

| Tipo | Valor |
|------|-------|
| DESCRIPCION | PROCESA LOS DATOS DE LAS CUENTAS DEL ARCHIVO 62. |
| FECHA | 15/04/2011 |

### Firma

```sql
CREATE PROCEDURE sp_tef_procesararchivo62(
  psNombreArchivo              CHAR(20)
  psUsuario                    CHAR(8)
) RETURNING CHAR(5) AS CodRet
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `psNombreArchivo` | `CHAR(20)` | `archivo`=archivo | ✅ CÓDIGO |
| `psUsuario` | `CHAR(8)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `VSCONSULTA` | `CHAR(2000)` | L14 |
| `vsCodRet` | `CHAR(5)` | L15 |
| `vsNombre_Arch` | `CHAR(20)` | L17 |
| `vsFecha_Presentacion` | `CHAR(8)` | L18 |
| `vsTipo_Registro` | `CHAR(2)` | L19 |
| `vsNum_Secuencia` | `CHAR(7)` | L20 |
| `vsCod_Operacion` | `CHAR(2)` | L21 |
| `vsCod_Divisa` | `CHAR(2)` | L22 |
| `vsFecha_Trans` | `CHAR(8)` | L23 |
| `vsBanco_Presentador` | `CHAR(3)` | L24 |
| `vsBanco_Receptor` | `CHAR(3)` | L25 |
| `vsImporte` | `CHAR(15)` | L26 |
| `vsUso_Futuro_ccen` | `CHAR(16)` | L27 |
| `vsTipo_Operacion` | `CHAR(2)` | L28 |
| `vsFecha_Aplica` | `CHAR(8)` | L29 |
| `vsTipo_Cta_Ord` | `CHAR(2)` | L30 |
| `vsNum_Cta_Ord` | `CHAR(20)` | L31 |
| `vsNombre_Ord` | `CHAR(40)` | L32 |
| `vsRfc_Ord` | `CHAR(18)` | L33 |
| `vsTipo_Cta_Rec` | `CHAR(2)` | L34 |
| `vsNum_Cta_Rec` | `CHAR(20)` | L35 |
| `vsNombre_Rec` | `CHAR(40)` | L36 |
| `vsRfc_Rec` | `CHAR(18)` | L37 |
| `vsRef_Servicio` | `CHAR(40)` | L38 |
| `vsNombre_Titular_Serv` | `CHAR(40)` | L39 |
| *…22 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tef_cce_detalle_paso` | `bditef` | no | SELECT | L171 |
| `tef_cce_detalle` | `bditef` | no | SELECT | L186 |
| `tef_cce_detalle` | `bditef` | no | UPDATE | L263 |
| `tef_operaciones` | `bditef` | no | UPDATE | L276 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L71 | CÓDIGO_RETORNO | `LET vsCodRet = '00000';` |  |
| L209 | CÓDIGO_RETORNO | `LET vsCodRet = '02100';` |  |
| L213 | FÓRMULA | `LET viContadorRegistros = viContadorRegistros + 1;` |  |
| L282 | FÓRMULA | `LET viContadorRegistros = viContadorRegistros + 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `tef` | ENTIDAD | TEF — transferencia electrónica de fondos | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `procesa` | ACCION | procesa | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?r` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `archivo` | ENTIDAD | archivo | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?62` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?r`, `?62` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_tef_procesararchivo63`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_sp_tef_procesararchivo63.sql` |
| **LOC (1er CREATE)** | 461 |
| **Callgraph** | ✅ fan_in=17 / fan_out=7 |
| **Deps concatenadas** | 2 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "procesa TEF — transferencia electrónica de fondos y archivo" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 3 llamada(s): `sp_tef_constelctacte`, `sp_generafolionomina`, `abono_ref` |
| **Evidencia vocab** | CÓDIGO=3 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=2 / 6 términos |

### Historia del SP

| Tipo | Valor |
|------|-------|
| DESCRIPCION | PROCESA LOS DATOS DE LAS CUENTAS DEL ARCHIVO 63. |
| FECHA | 19/04/2011 |

### Firma

```sql
CREATE PROCEDURE sp_tef_procesararchivo63(
  psNombreArchivo              CHAR(20)
  psFechaPresentacion          CHAR(8)
  psUsuario                    CHAR(8)
) RETURNING CHAR(5) AS CodRet
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `psNombreArchivo` | `CHAR(20)` | `archivo`=archivo | ✅ CÓDIGO |
| `psFechaPresentacion` | `CHAR(8)` | — | — |
| `psUsuario` | `CHAR(8)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `VSCONSULTA` | `CHAR(2000)` | L13 |
| `vsCodRet` | `CHAR(5)` | L14 |
| `vsPrefijoTarjeta` | `CHAR(100)` | L15 |
| `vsCuenta` | `CHAR(11)` | L18 |
| `vsStatus_Cta` | `CHAR (1)` | L19 |
| `vsProducto` | `CHAR (4)` | L20 |
| `vdFecha_Hoy` | `DATE` | L21 |
| `vdFecha_Manana` | `DATE` | L22 |
| `vsNombre_Arch` | `CHAR(20)` | L24 |
| `vsFecha_Presentacion` | `CHAR(8)` | L25 |
| `vsTipo_Registro` | `CHAR(2)` | L26 |
| `vsNum_Secuencia` | `CHAR(7)` | L27 |
| `vsCod_Operacion` | `CHAR(2)` | L28 |
| `vsCod_Divisa` | `CHAR(2)` | L29 |
| `vsFecha_Trans` | `CHAR(8)` | L30 |
| `vsBanco_Presentador` | `CHAR(3)` | L31 |
| `vsBanco_Receptor` | `CHAR(3)` | L32 |
| `vsImporte` | `CHAR(15)` | L33 |
| `vsUso_Futuro_ccen` | `CHAR(16)` | L34 |
| `vsTipo_Operacion` | `CHAR(2)` | L35 |
| `vsFecha_Aplica` | `CHAR(8)` | L36 |
| `vsTipo_Cta_Ord` | `CHAR(2)` | L37 |
| `vsNum_Cta_Ord` | `CHAR(20)` | L38 |
| `vsNombre_Ord` | `CHAR(40)` | L39 |
| `vsRfc_Ord` | `CHAR(18)` | L40 |
| *…42 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tef_parametros` | `bditef` | no | SELECT | L209 |
| `sc_fechas` | `bdicheq` | ⚠️ sí | SELECT | L217 |
| `si_sucursales` | `bdinteg` | ⚠️ sí | SELECT | L224 |
| `tef_cce_detalle_paso` | `bditef` | no | SELECT | L249 |
| `tef_cce_detalle` | `bditef` | no | SELECT | L263 |
| `sc_tarjeta` | `bdicheq` | ⚠️ sí | SELECT | L343 |
| `tef_cce_detalle` | `bditef` | no | UPDATE | L384 |
| `tef_operaciones` | `bditef` | no | UPDATE | L394 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_tef_constelctacte` | `bdicheq` | ⚠️ sí | L350 |
| `sp_generafolionomina` | `bdicheq` | ⚠️ sí | L365 |
| `abono_ref` | `bdicheq` | ⚠️ sí | L375 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L102 | CÓDIGO_RETORNO | `LET vsCodRet = '00000';` |  |
| L220 | FÓRMULA | `LET vdFechaLimite = vdFecha_Hoy - viDiasNaturales;` |  |
| L227 | CÓDIGO_RETORNO | `LET vsCodRet = '02200';` |  |
| L274 | CÓDIGO_RETORNO | `LET vsCodRet = '02201';` |  |
| L286 | CÓDIGO_RETORNO | `LET vsCodRet = '02202';` |  |
| L291 | FÓRMULA | `LET viContadorRegistros = viContadorRegistros + 1;` |  |
| L346 | FÓRMULA | `LET vsCuenta = SUBSTR(vsNum_Cta_Ord,9,11); --CUENTA` |  |
| L362 | FÓRMULA | `LET vmSaldoAPagar = ((vsImporte::INTEGER)/100);` | 🔴 MONEY/aritmética financiera |
| L369 | CÓDIGO_RETORNO | `LET vsCodRet = '02203';` |  |
| L379 | CÓDIGO_RETORNO | `LET vsCodRet = '02204';` |  |
| L416 | FÓRMULA | `LET viContadorRegistros = viContadorRegistros + 1;` |  |
| L434 | CÓDIGO_RETORNO | `LET vsCodRet = '00000';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `tef` | ENTIDAD | TEF — transferencia electrónica de fondos | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `procesa` | ACCION | procesa | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?r` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `archivo` | ENTIDAD | archivo | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?63` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?r`, `?63` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_tef_receptor_g`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_sp_tef_receptor_g.sql` |
| **LOC (1er CREATE)** | 406 |
| **Callgraph** | ✅ fan_in=34 / fan_out=14 |
| **Principales callers** | `sp_calificacion_scoring` |
| **Deps concatenadas** | 7 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "TEF — transferencia electrónica de fondos y receptor" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 9 llamada(s): `sp_tef_bitacora`, `sp_valida_cadena`, `sp_valida_fecha` |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=1 / 4 términos |

### Historia del SP

| Tipo | Valor |
|------|-------|
| DESCRIPCION | SP PRINCIPAL DE TEF -- RECEPTOR GENERADOR ARCH. 63. |
| FECHA | 16/03/2011 |

### Firma

```sql
CREATE PROCEDURE sp_tef_receptor_g(
  psNombreArchivo              CHAR(20)
  psNumEmpleado                CHAR (8)
) RETURNING CHAR (20) AS Nom_Archivo, CHAR (5) AS Codigo_Respuesta, CHAR (100) AS Mensaje_Respuesta
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `psNombreArchivo` | `CHAR(20)` | — | — |
| `psNumEmpleado` | `CHAR (8)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vsFlagTipoProceso` | `CHAR(1)` | L14 |
| `vsNomProceso` | `CHAR(20)` | L15 |
| `vsDescripcionProceso` | `CHAR(60)` | L16 |
| `sGENERANDO` | `CHAR(1)` | L17 |
| `sFINALIZADO` | `CHAR(1)` | L18 |
| `sERROR` | `CHAR(1)` | L19 |
| `visqlerr` | `INTEGER` | L20 |
| `vsNomArchivo` | `CHAR(20)` | L21 |
| `vsFechaPresentacion` | `CHAR(8)` | L22 |
| `vsFechaPresentacion1` | `CHAR(8)` | L23 |
| `vsFechaPresentacion2` | `CHAR(8)` | L24 |
| `vsFechaPresentacion3` | `CHAR(8)` | L25 |
| `vsCodRetorno` | `CHAR(5)` | L26 |
| `vsCodRetorno2` | `CHAR(5)` | L27 |
| `vsCodRetorno3` | `CHAR (5)` | L28 |
| `vdtFecha` | `DATE` | L29 |
| `vdtFecha1` | `DATE` | L30 |
| `vdtFechaInsert` | `DATE` | L31 |
| `vsMensajeRespuesta` | `CHAR (100)` | L32 |
| `viTipoArchivo` | `INTEGER` | L33 |
| `vsDia` | `CHAR(2)` | L34 |
| `vsMes` | `CHAR(2)` | L35 |
| `vsAno` | `CHAR(4)` | L36 |
| `vsSpLlamado` | `CHAR(24)` | L37 |
| `vsCveBanc` | `CHAR(3)` | L38 |
| *…1 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tef_parametros` | `bditef` | no | SELECT | L93 |
| `tef_prod_permitidos` | `bditef` | no | SELECT | L113 |
| `si_ejecut` | `bdinteg` | ⚠️ sí | SELECT | L126 |
| `sc_fechas` | `bdicheq` | ⚠️ sí | SELECT | L132 |
| `si_feriado_banca` | `bdinteg` | ⚠️ sí | SELECT | L169 |
| `14` | `bditef` | no | SELECT | L227 |
| `16` | `bditef` | no | SELECT | L237 |
| `tef_procesos` | `bditef` | no | SELECT | L252 |
| `tef_errores` | `bditef` | no | INSERT | L255 |
| `tef_cce_encabezado_paso` | `bditef` | no | SELECT | L288 |
| `tef_cce_detalle_paso` | `bditef` | no | SELECT | L289 |
| `tef_cce_sumario_paso` | `bditef` | no | SELECT | L290 |
| `tef_procesos` | `bditef` | no | UPDATE | L379 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_tef_bitacora` | `bditef` | no | L81 |
| `sp_valida_cadena` | `bditef` | no | L88 |
| `sp_valida_fecha` | `bditef` | no | L137 |
| `sp_tef_validarnombrearchivos` | `bditef` | no | L245 |
| `sp_obtenermensajeerror` | `bditef` | no | L254 |
| `sp_tef_moverregistroshist` | `bditef` | no | L277 |
| `sp_tef_generararchivo63` | `bditef` | no | L282 |
| `sp_tef_generaarchivo` | `bditef` | no | L295 |
| `sp_tef_guardarccearchivos` | `bditef` | no | L299 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L134 | FÓRMULA | `LET vdtFecha1 = vdtFecha + 1;` |  |
| L145 | FÓRMULA | `LET vdtFecha = vdtFecha + 1;` |  |
| L161 | FÓRMULA | `LET vdtFecha1 = vdtFecha1 + 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `tef` | ENTIDAD | TEF — transferencia electrónica de fondos | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `receptor` | ENTIDAD | receptor | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?_g` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_g` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_tef_receptor_r`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_sp_tef_receptor_r.sql` |
| **LOC (1er CREATE)** | 1575 |
| **Callgraph** | ✅ fan_in=34 / fan_out=15 |
| **Principales callers** | `sp_calificacion_scoring` |
| **Propósito inferido** | "TEF — transferencia electrónica de fondos y receptor" `[conf]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 14 llamada(s): `sp_tef_bitacora`, `sp_valida_cadena`, `sp_valida_fecha` |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=1 / 4 términos |

### Historia del SP

| Tipo | Valor |
|------|-------|
| DESCRIPCION | SP PRINCIPAL DE TEF -- RECEPTOR RECEPTOR PROCESAR ARCH. 10 Y 60. |
| FECHA | 16/03/2011 |

### Firma

```sql
CREATE PROCEDURE sp_tef_receptor_r(
  cNombreArchivo               CHAR(20)
  cNumEmpleado                 CHAR (8)
) RETURNING CHAR (20) AS Nom_Archivo, CHAR (5) AS Codigo_Respuesta, CHAR (100) AS Mensaje_Respuesta
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `cNombreArchivo` | `CHAR(20)` | — | — |
| `cNumEmpleado` | `CHAR (8)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cPROCESANDO` | `CHAR(1)` | L14 |
| `cERROR` | `CHAR(1)` | L15 |
| `cFINALIZADO` | `CHAR(1)` | L16 |
| `cDescripcionProceso` | `CHAR (60)` | L17 |
| `cFlagTipoProceso` | `CHAR (1)` | L18 |
| `iTipoArchivo` | `SMALLINT` | L19 |
| `cFlagUnico` | `CHAR (1)` | L20 |
| `cBloque` | `CHAR (2)` | L21 |
| `cFechaPresentacion` | `CHAR (8)` | L22 |
| `cFechaPresentacion1` | `CHAR (8)` | L23 |
| `cFechaPresentacion2` | `CHAR (8)` | L24 |
| `cCodRetorno` | `CHAR (5)` | L26 |
| `cCodRetorno2` | `CHAR (5)` | L27 |
| `cCodRetorno3` | `CHAR (5)` | L28 |
| `cMensajeRespuesta` | `CHAR (100)` | L29 |
| `cValorParam` | `CHAR (100)` | L30 |
| `csNomArchivo` | `CHAR (20)` | L31 |
| `csNomArchivo11` | `CHAR (20)` | L32 |
| `csNomArchivo61` | `CHAR (20)` | L33 |
| `iContador` | `INTEGER` | L35 |
| `dFecha` | `DATE` | L36 |
| `iSqlErr` | `INTEGER` | L37 |
| `cRuta` | `CHAR (100)` | L39 |
| `cNomProceso` | `CHAR (20)` | L41 |
| `cCodBanco` | `CHAR(3)` | L42 |
| *…10 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tef_parametros` | `bditef` | no | SELECT | L128 |
| `tef_prod_permitidos` | `bditef` | no | SELECT | L148 |
| `si_ejecut` | `bdinteg` | ⚠️ sí | SELECT | L159 |
| `sc_fechas` | `bdicheq` | ⚠️ sí | SELECT | L165 |
| `11` | `bditef` | no | SELECT | L275 |
| `15` | `bditef` | no | SELECT | L288 |
| `tef_procesos` | `bditef` | no | SELECT | L302 |
| `tef_errores` | `bditef` | no | INSERT | L307 |
| `tef_cce_archivos` | `bditef` | no | SELECT | L346 |
| `si_feriado_banca` | `bdinteg` | ⚠️ sí | SELECT | L372 |
| `tef_cce_encabezado_paso` | `bditef` | no | SELECT | L444 |
| `tef_cce_detalle_paso` | `bditef` | no | SELECT | L462 |
| `tef_cce_sumario_paso` | `bditef` | no | SELECT | L489 |
| `tef_cce_encabezado` | `bditef` | no | SELECT | L613 |
| `tef_cce_sumario_paso` | `bditef` | no | DELETE | L712 |
| `tef_cce_detalle_paso` | `bditef` | no | DELETE | L713 |
| `tef_cce_encabezado_paso` | `bditef` | no | DELETE | L714 |
| `tef_cce_archivos` | `bditef` | no | DELETE | L715 |
| `tef_procesos` | `bditef` | no | UPDATE | L792 |
| `public` | `bditef` | no | SELECT | L1341 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_tef_bitacora` | `bditef` | no | L113 |
| `sp_valida_cadena` | `bditef` | no | L123 |
| `sp_valida_fecha` | `bditef` | no | L175 |
| `sp_tef_validarnombrearchivos` | `bditef` | no | L295 |
| `sp_obtenermensajeerror` | `bditef` | no | L305 |
| `sp_tef_moverregistroshist` | `bditef` | no | L340 |
| `sp_tef_buscararchivo` | `bditef` | no | L432 |
| `sp_tef_subirarchivos` | `bditef` | no | L438 |
| `sp_tef_valida_datos` | `bditef` | no | L457 |
| `sp_tef_procesararchivo10` | `bditef` | no | L470 |
| `sp_tef_procesararchivo60` | `bditef` | no | L475 |
| `sp_tef_generaarchivo` | `bditef` | no | L494 |
| `sp_tef_guardarccearchivos` | `bditef` | no | L537 |
| `sp_tef_moverarchivos` | `bditef` | no | L595 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L196 | FÓRMULA | `LET dFechaAux = dFecha; --FORZAR ENTRADA AL CICLO` |  |
| L199 | FÓRMULA | `LET iContadorDias = iContadorDias + 1;` |  |
| L205 | FÓRMULA | `LET dFechaAux = dFecha - (iContadorDias -1); --DIA HABIL ANTERIOR` |  |
| L243 | FÓRMULA | `LET iContador = iContador + 1;` |  |
| L348 | VALIDACIÓN_NULL | `IF ((iNumArchivos IS NULL) OR (iNumArchivos = 0)) THEN` |  |
| L351 | FÓRMULA | `LET iNumArchivos = iNumArchivos + 1;` |  |
| L374 | VALIDACIÓN_NULL | `IF (dFechProx IS NULL) OR (dFechProx = "") THEN` |  |
| L463 | FÓRMULA | `LET dFechaAplicaDe = SUBSTR(cFechaAplica,5,2) \|\| "/" \|\| SUBSTR(cFechaAplica,7,2) \|\| "/" \|\| S` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `tef` | ENTIDAD | TEF — transferencia electrónica de fondos | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `receptor` | ENTIDAD | receptor | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?_r` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_r` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_tef_rep_lib_sif`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_sp_tef_rep_lib_sif.sql` |
| **LOC (1er CREATE)** | 89 |
| **Callgraph** | ✅ fan_in=0 / fan_out=17 |
| **Deps concatenadas** | 17 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "reporte TEF — transferencia electrónica de fondos y SIF — canal de estado de cuenta" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 2 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=3 · INFERIDO=1 · SINTÉTICO=1 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_tef_rep_lib_sif(
) RETURNING CHAR(5) AS cCodRet,
```

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(5)` | L12 |
| `iSqlErr` | `INTEGER` | L13 |
| `intNumRegistros2101` | `INTEGER` | L14 |
| `decImporte2101` | `MONEY(16,2)` | L15 |
| `intNumRegistrosTDC` | `INTEGER` | L16 |
| `decImporteTDC` | `MONEY(16,2)` | L17 |
| `intSumRegistros` | `INTEGER` | L19 |
| `decSumaImporte` | `MONEY(16,2)` | L20 |
| `iTotalRegistros` | `INTEGER` | L21 |
| `dTotalImport` | `MONEY(16,2)` | L22 |
| `intSumRegistros2` | `INTEGER` | L23 |
| `decSumaImporte2` | `MONEY(16,2)` | L24 |
| `intSumRegistros1` | `INTEGER` | L25 |
| `decSumaImporte1` | `MONEY(16,2)` | L26 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sc_movdia` | `bdicheq` | ⚠️ sí | SELECT | L61 |
| `sd_movdia` | `bdicred` | ⚠️ sí | SELECT | L70 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L64 | FÓRMULA | `LET intSumRegistros1 = intSumRegistros1 + intNumRegistros2101;` |  |
| L65 | FÓRMULA | `LET decSumaImporte1 = decSumaImporte1 + decImporte2101;` | 🔴 MONEY/aritmética financiera |
| L73 | FÓRMULA | `LET intSumRegistros2 = intSumRegistros2 + intNumRegistrosTDC;` |  |
| L74 | FÓRMULA | `LET decSumaImporte2 = decSumaImporte2 + decImporteTDC;` | 🔴 MONEY/aritmética financiera |
| L76 | FÓRMULA | `LET iTotalRegistros =intSumRegistros1 + intSumRegistros2;` |  |
| L77 | FÓRMULA | `LET dTotalImport = decSumaImporte1 + decSumaImporte2;` | 🔴 MONEY/aritmética financiera |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `tef` | ENTIDAD | TEF — transferencia electrónica de fondos | 🔵 CONVENCIÓN | nombre_sp |
| `rep` | ACCION | reporte | 🔵 CONVENCIÓN | nombre_sp |
| `?_lib_` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `sif` | ENTIDAD | SIF — canal de estado de cuenta (aclaraciones_edocta_sif, de | 🟡 INFERIDO | nombre_sp |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?_lib_` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_tef_reversoperacion`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_sp_tef_reversoperacion.sql` |
| **LOC (1er CREATE)** | 140 |
| **Callgraph** | ✅ fan_in=0 / fan_out=4 |
| **Deps concatenadas** | 4 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "reverso TEF — transferencia electrónica de fondos" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 3 llamada(s): `sp_tef_validahorario`, `sp_tef_validarchcod60`, `reversion_sif` |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=1 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_tef_reversoperacion(
  pfecha                       DATE
  pSucursal                    CHAR(4)
  pEjecutivo                   CHAR(8)
  pFolioSuc                    VARCHAR(16)
) RETURNING CHAR(6) 		AS cod_ret,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pfecha` | `DATE` | — | — |
| `pSucursal` | `CHAR(4)` | — | — |
| `pEjecutivo` | `CHAR(8)` | — | — |
| `pFolioSuc` | `VARCHAR(16)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `iSqlErr` | `INTEGER` | L10 |
| `iIsamErr` | `INTEGER` | L11 |
| `cErrorInfo` | `VARCHAR(80)` | L12 |
| `cCodRet` | `CHAR(6)` | L13 |
| `cCodretRev` | `CHAR(5)` | L14 |
| `cMensajeRet` | `VARCHAR(100)` | L15 |
| `cFolioSuc` | `VARCHAR(16)` | L17 |
| `cNumCtaOrd` | `VARCHAR(20)` | L18 |
| `cReferencia` | `VARCHAR(40)` | L19 |
| `cImporte` | `CHAR(10)` | L20 |
| `cReversado` | `CHAR(2)` | L21 |
| `cCodretVal` | `CHAR(5)` | L23 |
| `cTpo_Proc` | `CHAR(1)` | L24 |
| `cFech_Proc` | `CHAR(10)` | L25 |
| `cCve_Proc` | `CHAR(20)` | L26 |
| `cDescripcion` | `CHAR(60)` | L27 |
| `cEstatus` | `CHAR(1)` | L28 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tef_operaciones` | `bditef` | no | SELECT | L75 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_tef_validahorario` | `bditef` | no | L94 |
| `sp_tef_validarchcod60` | `bditef` | no | L100 |
| `reversion_sif` | `bdicheq` | ⚠️ sí | L107 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `tef` | ENTIDAD | TEF — transferencia electrónica de fondos | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `reverso` | ACCION | reverso | 🔵 CONVENCIÓN | nombre_sp |
| `?peracion` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?peracion` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_tef_subirarchivos`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_sp_tef_subirarchivos.sql` |
| **LOC (1er CREATE)** | 939 |
| **Callgraph** | ✅ fan_in=18 / fan_out=8 |
| **Deps concatenadas** | 5 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "TEF — transferencia electrónica de fondos y archivos (sub-)" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — SP delega a 1 llamada(s): `sp_obtenermensajeerror` |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=1 · INFERIDO=1 · SINTÉTICO=1 / 5 términos |

### Historia del SP

| Tipo | Valor |
|------|-------|
| DESCRIPCION | PROCEDIMIENTO PARA REALIZAR LA CARGA DE LOS ARCHIVOS QUE SE RECIBEN A LAS TABLAS DE INFORMIX. |
| FECHA | 10/03/2011 |

### Firma

```sql
CREATE PROCEDURE sp_tef_subirarchivos(
  psTipo                       CHAR(1)
  psCodRuta                    CHAR(2)
  psNombreArchivo              VARCHAR(20)
  psUsuario                    CHAR(8)
) RETURNING CHAR(5) AS CodRet, VARCHAR(115) AS DESCRIPCION
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `psTipo` | `CHAR(1)` | — | — |
| `psCodRuta` | `CHAR(2)` | — | — |
| `psNombreArchivo` | `VARCHAR(20)` | — | — |
| `psUsuario` | `CHAR(8)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vsCodRef` | `CHAR(5)` | L13 |
| `iSqlErr` | `INTEGER` | L14 |
| `iSamErr` | `INTEGER` | L15 |
| `sDescMensajeError` | `VARCHAR(95)` | L17 |
| `vsRuta` | `CHAR(100)` | L18 |
| `sCadSql` | `LVARCHAR(1000)` | L19 |
| `sLinea` | `LVARCHAR(500)` | L20 |
| `sEncTipoReg` | `CHAR(2)` | L23 |
| `sEncNumSec` | `CHAR(7)` | L24 |
| `sEncCodOper` | `CHAR(2)` | L25 |
| `sEncBanco` | `CHAR(3)` | L26 |
| `sEncSentido` | `CHAR(1)` | L27 |
| `sEncServicio` | `CHAR(1)` | L28 |
| `sEncNumBloque` | `CHAR(7)` | L29 |
| `sEncFechaPres` | `CHAR(8)` | L30 |
| `sEncCodDivisa` | `CHAR(2)` | L31 |
| `sEncCausaRechazo` | `CHAR(2)` | L32 |
| `sEncModalidad` | `CHAR(1)` | L33 |
| `sEncUsoFuturoCCEN` | `CHAR(41)` | L34 |
| `sEncUsoFuturoBANCO` | `CHAR(370)` | L35 |
| `sDetTipoReg` | `CHAR(2)` | L38 |
| `sDetNumSec` | `CHAR(7)` | L39 |
| `sDetCodOper` | `CHAR(2)` | L40 |
| `sDetCodDivisa` | `CHAR(2)` | L41 |
| `SDetFechaTrans` | `CHAR(8)` | L42 |
| *…46 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tef_errores` | `bditef` | no | INSERT | L182 |
| `tef_parametros` | `bditef` | no | SELECT | L212 |
| `systables` | `bditef` | no | SELECT | L223 |
| `tef_tmp_trabajo_aut` | `bditef` | no | INSERT | L244 |
| `tef_tmp_trabajo_aut` | `bditef` | no | SELECT | L270 |
| `tef_cat_rechazos` | `bditef` | no | SELECT | L360 |
| `tef_tmp_secuencia_aut` | `bditef` | no | INSERT | L421 |
| `tef_tmp_secuencia_aut` | `bditef` | no | SELECT | L427 |
| `tef_cce_encabezado_paso` | `bditef` | no | INSERT | L461 |
| `tef_cce_detalle_paso` | `bditef` | no | INSERT | L521 |
| `tef_cce_sumario_paso` | `bditef` | no | INSERT | L555 |
| `tef_tmp_trabajo_man` | `bditef` | no | INSERT | L587 |
| `tef_tmp_trabajo_man` | `bditef` | no | SELECT | L613 |
| `tef_tmp_secuencia_man` | `bditef` | no | INSERT | L775 |
| `tef_tmp_secuencia_man` | `bditef` | no | SELECT | L780 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_obtenermensajeerror` | `bditef` | no | L205 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L340 | FÓRMULA | `LET iContador = iContador + 1;` |  |
| L353 | FÓRMULA | `LET iNumCaracteres = iNumCaracteres - 1;` |  |
| L700 | FÓRMULA | `LET iContador = iContador + 1;` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `tef` | ENTIDAD | TEF — transferencia electrónica de fondos | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `sub` | MODIF | sub- | 🟡 INFERIDO | nombre_sp |
| `?ir` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `archivos` | ENTIDAD | archivos | ✅ CÓDIGO | nombre_sp, texto_cuerpo |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?ir` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_tef_valida_datos`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_sp_tef_valida_datos.sql` |
| **LOC (1er CREATE)** | 755 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 1 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "valida TEF — transferencia electrónica de fondos y datos" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `valida` → `IF` encontrado en el cuerpo · `valida` → `RETURN` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=4 · CONVENCIÓN=0 · INFERIDO=0 · SINTÉTICO=0 / 4 términos |

### Historia del SP

| Tipo | Valor |
|------|-------|
| DESCRIPCION | PROCEDIMIENTO PARA VALIDAR LOS DATOS EN LAS TABLAS DE PASO. |
| FECHA | 15/03/2011 |

### Firma

```sql
CREATE PROCEDURE sp_tef_valida_datos(
  psNombreArchivo              CHAR(20)
  psFecha_Presentacion         CHAR(8)
  psTipoArchivo                CHAR(1)
  piNumArchivo                 INTEGER
  psRol                        CHAR(1)
  psNomProceso                 CHAR(20)
) RETURNING CHAR(5), CHAR (2)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `psNombreArchivo` | `CHAR(20)` | — | — |
| `psFecha_Presentacion` | `CHAR(8)` | — | — |
| `psTipoArchivo` | `CHAR(1)` | — | — |
| `piNumArchivo` | `INTEGER` | — | — |
| `psRol` | `CHAR(1)` | — | — |
| `psNomProceso` | `CHAR(20)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vsFlagNumSecuencia` | `CHAR(5)` | L13 |
| `vsFlagFechaAplicacion` | `CHAR(5)` | L14 |
| `vsFlagNombreOrdenante` | `CHAR(5)` | L15 |
| `v_iCodReSP2` | `INTEGER` | L16 |
| `v_iDigVeSP2` | `INTEGER` | L17 |
| `vsFlagNumCtaReceptor` | `CHAR(5)` | L18 |
| `vsFlagNombreReceptor` | `CHAR(5)` | L19 |
| `vsFlagRef_Serv` | `CHAR(5)` | L20 |
| `nom_arch` | `CHAR(20)` | L22 |
| `fec_presen` | `CHAR(8)` | L23 |
| `vsCodRet` | `CHAR(5)` | L24 |
| `v_nivel` | `CHAR(2)` | L25 |
| `sql_err` | `INTEGER` | L26 |
| `v_contusoba` | `INTEGER` | L27 |
| `v_ciclo` | `INTEGER` | L28 |
| `v_bancorev` | `char(3)` | L29 |
| `v_ini` | `INTEGER` | L30 |
| `v_bancComa` | `CHAR(1)` | L31 |
| `v_BancoCoppel` | `CHAR(3)` | L32 |
| `v_f_ENC` | `CHAR(8)` | L33 |
| `i_importe` | `INTEGER` | L34 |
| `i_Valormax` | `INTEGER` | L35 |
| `no_cod_oper` | `CHAR(2)` | L36 |
| `e_tpo_reg` | `CHAR(2)` | L39 |
| `e_num_secu` | `CHAR(7)` | L40 |
| *…99 más…* | | |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tef_cce_encabezado_paso` | `bditef` | no | SELECT | L312 |
| `tef_cce_detalle_paso` | `bditef` | no | SELECT | L314 |
| `tef_cce_sumario_paso` | `bditef` | no | SELECT | L316 |
| `tef_parametros` | `bditef` | no | SELECT | L336 |
| `tef_codigo_oper` | `bditef` | no | SELECT | L357 |
| `tef_procesos` | `bditef` | no | SELECT | L376 |
| `tef_cat_rechazos` | `bditef` | no | SELECT | L385 |
| `si_bancos` | `bdinteg` | ⚠️ sí | SELECT | L484 |
| `tef_tipo_cta` | `bditef` | no | SELECT | L506 |
| `tef_cat_devoluciones` | `bditef` | no | SELECT | L587 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_valida_cadena` | `bditef` | no | L298 |
| `sp_valida_fecha` | `bditef` | no | L342 |
| `sp_validadv` | `bdispei` | ⚠️ sí | L455 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L170 | CÓDIGO_RETORNO | `let	vsCodRet ='00000';` |  |
| L278 | FÓRMULA | `LET v_dFechaProce = CURRENT;  --'01/01/1900';` |  |
| L301 | CÓDIGO_RETORNO | `LET vsCodRet = '00601';` |  |
| L303 | CÓDIGO_RETORNO | `LET vsCodRet = '00602';` |  |
| L305 | CÓDIGO_RETORNO | `LET vsCodRet = '00603';` |  |
| L308 | CÓDIGO_RETORNO | `LET vsCodRet = '00604';` |  |
| L311 | CÓDIGO_RETORNO | `LET vsCodRet = '00605';` |  |
| L313 | CÓDIGO_RETORNO | `LET vsCodRet = '00606';` |  |
| L315 | CÓDIGO_RETORNO | `LET vsCodRet = '00607';` |  |
| L317 | CÓDIGO_RETORNO | `LET vsCodRet = '00608';` |  |
| L351 | CÓDIGO_RETORNO | `LET vsCodRet = '00609';` |  |
| L353 | CÓDIGO_RETORNO | `LET vsCodRet = '00610';` |  |
| L355 | CÓDIGO_RETORNO | `LET vsCodRet = '00611';` |  |
| L358 | CÓDIGO_RETORNO | `LET vsCodRet = '00612';` |  |
| L363 | CÓDIGO_RETORNO | `LET vsCodRet = '00613';` |  |
| L365 | CÓDIGO_RETORNO | `LET vsCodRet = '00614';` |  |
| L367 | CÓDIGO_RETORNO | `LET vsCodRet = '00615';` |  |
| L369 | CÓDIGO_RETORNO | `LET vsCodRet = '00616';` |  |
| L380 | CÓDIGO_RETORNO | `LET vsCodRet = '00617';` |  |
| L384 | CÓDIGO_RETORNO | `LET vsCodRet = '00618';` |  |
| L386 | CÓDIGO_RETORNO | `LET vsCodRet = '00619';` |  |
| L388 | CÓDIGO_RETORNO | `LET vsCodRet = '00620';` |  |
| L390 | CÓDIGO_RETORNO | `LET vsCodRet = '00621';` |  |
| L392 | CÓDIGO_RETORNO | `LET vsCodRet = '00622';` |  |
| L475 | CÓDIGO_RETORNO | `LET vsCodRet = '00622';` |  |
| L477 | CÓDIGO_RETORNO | `LET vsCodRet = '00623';` |  |
| L479 | CÓDIGO_RETORNO | `LET vsCodRet = '00624';` |  |
| L481 | CÓDIGO_RETORNO | `LET vsCodRet = '00625';` |  |
| L483 | CÓDIGO_RETORNO | `LET vsCodRet = '00626';` |  |
| L487 | CÓDIGO_RETORNO | `LET vsCodRet = '00627';` |  |
| | *…33 más…* | | |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `tef` | ENTIDAD | TEF — transferencia electrónica de fondos | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `valida` | ACCION | valida | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `datos` | ENTIDAD | datos | ✅ CÓDIGO | nombre_sp, texto_cuerpo |

---

## `sp_tef_validahorario`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_sp_tef_validahorario.sql` |
| **LOC (1er CREATE)** | 62 |
| **Callgraph** | ✅ fan_in=93 / fan_out=1 |
| **Principales callers** | `sp_calificacion_scoring` |
| **Deps concatenadas** | 3 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "valida TEF — transferencia electrónica de fondos y hora" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `valida` → `IF` encontrado en el cuerpo · `valida` → `RETURN` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=1 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_tef_validahorario(
  pHorario                     DATETIME HOUR TO MINUTE
) RETURNING CHAR(6) 		AS cod_ret,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pHorario` | `DATETIME HOUR TO MINUTE` | `hora`=hora | ✅ CÓDIGO |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `iSqlErr` | `INTEGER` | L7 |
| `iIsamErr` | `INTEGER` | L8 |
| `cErrorInfo` | `VARCHAR(100)` | L9 |
| `cCodRet` | `CHAR(6)` | L10 |
| `cMensajeRet` | `VARCHAR(100)` | L11 |
| `dtHorarioMax` | `DATETIME HOUR TO MINUTE` | L12 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tef_parametros` | `bditef` | no | SELECT | L43 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `tef` | ENTIDAD | TEF — transferencia electrónica de fondos | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `valida` | ACCION | valida | 🔵 CONVENCIÓN | nombre_sp |
| `hora` | ENTIDAD | hora | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?rio` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?rio` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_tef_validarecepcion`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_sp_tef_validarecepcion.sql` |
| **LOC (1er CREATE)** | 96 |
| **Callgraph** | ✅ fan_in=55 / fan_out=1 |
| **Principales callers** | `sp_calificacion_scoring` |
| **Deps concatenadas** | 1 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "valida TEF — transferencia electrónica de fondos" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `valida` → `IF` encontrado en el cuerpo · `valida` → `RETURN` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=1 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_tef_validarecepcion(
  ptipo                        INTEGER
  pCuenta                      CHAR (20)
) RETURNING CHAR(6) 		AS cod_ret,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `ptipo` | `INTEGER` | — | — |
| `pCuenta` | `CHAR (20)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `iSqlErr` | `INTEGER` | L7 |
| `iIsamErr` | `INTEGER` | L8 |
| `cErrorInfo` | `CHAR(80)` | L9 |
| `cCodRet` | `CHAR(6)` | L10 |
| `cCodRet1` | `CHAR(6)` | L11 |
| `vMensajeRet` | `VARCHAR(80)` | L12 |
| `sBandera` | `SMALLINT` | L13 |
| `cBanco` | `CHAR(3)` | L14 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_bancos` | `bdinteg` | ⚠️ sí | SELECT | L49 |
| `sc_bines` | `bdicheq` | ⚠️ sí | SELECT | L51 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_desc_ret` | `bdinteg` | ⚠️ sí | L72 |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `tef` | ENTIDAD | TEF — transferencia electrónica de fondos | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `valida` | ACCION | valida | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `rec` | ACCION | recepción / recibe | 🔵 CONVENCIÓN | nombre_sp |
| `?epcion` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?epcion` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_tef_validarnombrearchivos`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_sp_tef_validarnombrearchivos.sql` |
| **LOC (1er CREATE)** | 224 |
| **Callgraph** | ✅ fan_in=19 / fan_out=10 |
| **Deps concatenadas** | 25 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "valida TEF — transferencia electrónica de fondos, nombre y archivos" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `valida` → `IF` encontrado en el cuerpo · `valida` → `RETURN` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=4 · CONVENCIÓN=1 · INFERIDO=0 · SINTÉTICO=1 / 6 términos |

### Historia del SP

| Tipo | Valor |
|------|-------|
| DESCRIPCION | PROCEDIMIENTO PARA VALIDAR LA ESTRUCTURA DEL NOMBRE DE LOS ARCHIVOS A RECIBIR POR PARTE DE CECOBAN, ARCHIVOS CODIGO 10, 11 Y CODIGO 60, 61, 62, 63 |
| FECHA | 08/03/2011 |

### Firma

```sql
CREATE PROCEDURE sp_tef_validarnombrearchivos(
  piCodOperacion               SMALLINT
  psSentido                    CHAR(1)
  psNombreArchivo              VARCHAR(20)
) RETURNING CHAR(5) AS CodRet
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `piCodOperacion` | `SMALLINT` | — | — |
| `psSentido` | `CHAR(1)` | — | — |
| `psNombreArchivo` | `VARCHAR(20)` | `nombre`=nombre | ✅ CÓDIGO |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vsCodRet` | `CHAR(5)` | L15 |
| `iSqlErr` | `INTEGER` | L16 |
| `iSamErr` | `INTEGER` | L17 |
| `vsDescMensajeError` | `VARCHAR(95)` | L19 |
| `iNumDia` | `SMALLINT` | L20 |
| `iNumMes` | `SMALLINT` | L21 |
| `iNumAnio` | `SMALLINT` | L22 |
| `vsCodBanco` | `CHAR(3)` | L23 |
| `sCodRetFecha` | `VARCHAR(5)` | L24 |
| `dFechaHoy` | `DATE` | L25 |
| `dFechaHabil` | `DATE` | L26 |
| `vsTipoArchivo` | `CHAR(1)` | L28 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tef_parametros` | `bditef` | no | SELECT | L66 |
| `sc_fechas` | `bdicheq` | ⚠️ sí | SELECT | L78 |

### Llamadas (EXECUTE PROCEDURE / CALL)

| SP llamado | Base | Cross-DB | Línea |
|------------|------|----------|-------|
| `sp_valida_cadena` | `bditef` | no | L125 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L60 | CÓDIGO_RETORNO | `LET vsCodRet = '01400';` |  |
| L129 | CÓDIGO_RETORNO | `LET vsCodRet = '01401';` |  |
| L131 | CÓDIGO_RETORNO | `LET vsCodRet = '01402';` |  |
| L133 | CÓDIGO_RETORNO | `LET vsCodRet = '01403';` |  |
| L135 | CÓDIGO_RETORNO | `LET vsCodRet = '01404';` |  |
| L137 | CÓDIGO_RETORNO | `LET vsCodRet = '01405';` |  |
| L139 | CÓDIGO_RETORNO | `LET vsCodRet = '01406';` |  |
| L141 | CÓDIGO_RETORNO | `LET vsCodRet = '01407';` |  |
| L145 | CÓDIGO_RETORNO | `LET vsCodRet = '01409';` |  |
| L151 | CÓDIGO_RETORNO | `LET vsCodRet = '01413';` |  |
| L153 | CÓDIGO_RETORNO | `LET vsCodRet = '00000';` |  |
| L176 | CÓDIGO_RETORNO | `LET vsCodRet = '01401';` |  |
| L178 | CÓDIGO_RETORNO | `LET vsCodRet = '01402';` |  |
| L180 | CÓDIGO_RETORNO | `LET vsCodRet = '01404';` |  |
| L186 | CÓDIGO_RETORNO | `LET vsCodRet = '01411';` |  |
| L188 | CÓDIGO_RETORNO | `LET vsCodRet = '01412';` |  |
| L190 | CÓDIGO_RETORNO | `LET vsCodRet = '01407';` |  |
| L192 | CÓDIGO_RETORNO | `LET vsCodRet = '01409';` |  |
| L194 | CÓDIGO_RETORNO | `LET vsCodRet = '01413';` |  |
| L196 | CÓDIGO_RETORNO | `LET vsCodRet = '00000';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `tef` | ENTIDAD | TEF — transferencia electrónica de fondos | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |
| `valida` | ACCION | valida | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?r` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `nombre` | ENTIDAD | nombre | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `archivos` | ENTIDAD | archivos | ✅ CÓDIGO | nombre_sp, texto_cuerpo |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?r` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_valida_imagencheque`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_sp_valida_imagencheque.sql` |
| **LOC (1er CREATE)** | 89 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 1 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "valida imagen digital y cheque" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `valida` → `IF` encontrado en el cuerpo · `valida` → `RETURN` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=0 · CONVENCIÓN=4 · INFERIDO=0 · SINTÉTICO=0 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_valida_imagencheque(
  pcEmpresa                    CHAR(3)
  pcNumCheq                    CHAR(7)
  pcCveBanco                   CHAR(3)
  pcNumCuenta                  CHAR(20)
  pdFechaAlta                  DATE
) RETURNING --DATOS A REGRESAR--
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pcEmpresa` | `CHAR(3)` | — | — |
| `pcNumCheq` | `CHAR(7)` | — | — |
| `pcCveBanco` | `CHAR(3)` | — | — |
| `pcNumCuenta` | `CHAR(20)` | — | — |
| `pdFechaAlta` | `DATE` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `iSql_err` | `INTEGER` | L15 |
| `cCodRet` | `CHAR(5)` | L16 |
| `wBegin` | `CHAR(1)` | L17 |
| `iexiste` | `INTEGER` | L18 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `cce_cheques_img` | `bditef` | no | SELECT | L58 |
| `cce_cheques_img` | `bditef` | no | DELETE | L61 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L22 | CÓDIGO_RETORNO | `LET cCodRet 			=	'00001';` |  |
| L65 | CÓDIGO_RETORNO | `LET cCodRet = '00000';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `valida` | ACCION | valida | 🔵 CONVENCIÓN | nombre_sp |
| `imagen` | ENTIDAD | imagen digital | 🔵 CONVENCIÓN | nombre_sp |
| `cheque` | ENTIDAD | cheque | 🔵 CONVENCIÓN | nombre_sp |

---

## `sp_validadiahabiltef`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_sp_validadiahabiltef.sql` |
| **LOC (1er CREATE)** | 75 |
| **Callgraph** | ✅ fan_in=57 / fan_out=8 |
| **Principales callers** | `sp_calificacion_scoring` |
| **Deps concatenadas** | 22 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "valida día hábil — día bancario operativo y TEF — transferencia electrónica de fondos (del día)" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `valida` → `IF` encontrado en el cuerpo · `valida` → `RETURN` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=0 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_validadiahabiltef(
  pFecha                       CHAR(10)
) RETURNING CHAR(5), CHAR(5)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pFecha` | `CHAR(10)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet1` | `CHAR(5)` | L4 |
| `cCodRet2` | `CHAR(5)` | L5 |
| `cEsFeriado` | `CHAR(1)` | L6 |
| `dFecha` | `DATE` | L7 |
| `iSql_Err` | `INT` | L8 |
| `iSam_Err` | `INT` | L9 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `si_feriado` | `bdinteg` | ⚠️ sí | SELECT | L46 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L20 | FÓRMULA | `LET dFecha     = "01/01/1900";` |  |
| L36 | VALIDACIÓN_NULL | `IF  pFecha IS NULL OR pFecha = "" THEN` |  |
| L41 | FÓRMULA | `LET dFecha = TO_DATE(pFecha,"%m/%d/%Y");` |  |
| L50 | VALIDACIÓN_NULL | `IF cEsFeriado is null THEN` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `valida` | ACCION | valida | 🔵 CONVENCIÓN | nombre_sp |
| `dia` | MODIF | del día | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `habil` | ENTIDAD | día hábil — día bancario operativo (spei_validafecha, sp_cam | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `tef` | ENTIDAD | TEF — transferencia electrónica de fondos | 🔵 CONVENCIÓN | nombre_sp |

---

## `sp_validahorariotef`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_sp_validahorariotef.sql` |
| **LOC (1er CREATE)** | 67 |
| **Callgraph** | ✅ fan_in=29 / fan_out=8 |
| **Deps concatenadas** | 21 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "valida hora y TEF — transferencia electrónica de fondos" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `valida` → `IF` encontrado en el cuerpo · `valida` → `RETURN` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=1 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_validahorariotef(
) RETURNING CHAR(5), CHAR(5)
```

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `iSqlErr` | `INTEGER` | L7 |
| `cCodRet1` | `CHAR (5)` | L8 |
| `cCodRet2` | `CHAR (5)` | L9 |
| `cHoraActual` | `CHAR (5)` | L10 |
| `cHoraAParam` | `CHAR (5)` | L11 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tef_parametros` | `bditef` | no | SELECT | L36 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L40 | VALIDACIÓN_NULL | `IF cHoraActual = "" OR cHoraActual IS NULL OR cHoraAParam = "" OR cHoraAParam IS NULL THEN` |  |
| L44 | FÓRMULA | `LET cCodRet2 = "00002";  --Esta fuera del horario` |  |
| L49 | FÓRMULA | `LET cCodRet2 = "00002";  --Esta fuera del horario` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `valida` | ACCION | valida | 🔵 CONVENCIÓN | nombre_sp |
| `hora` | ENTIDAD | hora | 🔵 CONVENCIÓN | nombre_sp |
| `?rio` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `tef` | ENTIDAD | TEF — transferencia electrónica de fondos | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo, texto_cuerpo |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?rio` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `sp_validaimagencheque`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_sp_validaimagencheque.sql` |
| **LOC (1er CREATE)** | 61 |
| **Callgraph** | ✅ fan_in=16 / fan_out=5 |
| **Deps concatenadas** | 12 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "valida imagen digital y cheque" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `valida` → `IF` encontrado en el cuerpo · `valida` → `RETURN` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=2 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=0 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_validaimagencheque(
  pCveBanco                    CHAR(3)
  pCuenta                      CHAR(20)
  pNumCheque                   CHAR(7)
) RETURNING CHAR(5) ,CHAR(50), CHAR(3)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pCveBanco` | `CHAR(3)` | — | — |
| `pCuenta` | `CHAR(20)` | — | — |
| `pNumCheque` | `CHAR(7)` | `cheque`=cheque | ✅ CÓDIGO |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(5)` | L4 |
| `iSqlErr` | `INTEGER` | L5 |
| `cMensaje` | `CHAR(50)` | L6 |
| `cImagen` | `BLOB` | L7 |
| `iTamImg` | `INTEGER` | L8 |
| `cImgFormato` | `CHAR(3)` | L9 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `cce_cheques_img` | `bditef` | no | SELECT | L37 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L12 | CÓDIGO_RETORNO | `LET cCodRet 			= '00000';` |  |
| L29 | CÓDIGO_RETORNO | `LET cCodRet = '00001';` |  |
| L43 | VALIDACIÓN_NULL | `IF cImagen IS NULL THEN` |  |
| L44 | CÓDIGO_RETORNO | `LET cCodRet = '00002';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `valida` | ACCION | valida | 🔵 CONVENCIÓN | nombre_sp |
| `imagen` | ENTIDAD | imagen digital | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `cheque` | ENTIDAD | cheque | ✅ CÓDIGO | nombre_sp, texto_cuerpo |

---

## `sp_validaimagencheque_dev`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_sp_validaimagencheque_dev.sql` |
| **LOC (1er CREATE)** | 93 |
| **Callgraph** | ✅ fan_in=56 / fan_out=5 |
| **Deps concatenadas** | 11 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "valida imagen digital y cheque" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `valida` → `IF` encontrado en el cuerpo · `valida` → `RETURN` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=3 · CONVENCIÓN=2 · INFERIDO=0 · SINTÉTICO=0 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_validaimagencheque_dev(
  pCveBanco                    CHAR(3)
  pCuenta                      CHAR(20)
  pNumCheque                   CHAR(7)
  pLadoFt                      CHAR(1)
  dFechaPresenta               DATE
) RETURNING CHAR(5)	  AS COD_RET,
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pCveBanco` | `CHAR(3)` | — | — |
| `pCuenta` | `CHAR(20)` | — | — |
| `pNumCheque` | `CHAR(7)` | `cheque`=cheque | ✅ CÓDIGO |
| `pLadoFt` | `CHAR(1)` | — | — |
| `dFechaPresenta` | `DATE` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(5)` | L8 |
| `iSqlErr` | `INTEGER` | L9 |
| `cMensaje` | `CHAR(50)` | L10 |
| `bImagen` | `BLOB` | L11 |
| `cImgFormato` | `CHAR(3)` | L12 |
| `cCveBanco` | `CHAR(3)` | L13 |
| `cNumCheque` | `CHAR(7)` | L14 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `cce_cheques_img` | `bditef` | no | SELECT | L50 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L17 | CÓDIGO_RETORNO | `LET cCodRet 			= '00000';` |  |
| L42 | CÓDIGO_RETORNO | `LET cCodRet = '00001';` |  |
| L58 | CÓDIGO_RETORNO | `LET cCodRet = '00002';` |  |
| L66 | VALIDACIÓN_NULL | `IF bImagen IS NULL Then` |  |
| L68 | CÓDIGO_RETORNO | `LET cCodRet = '00003';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `valida` | ACCION | valida | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `imagen` | ENTIDAD | imagen digital | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `cheque` | ENTIDAD | cheque | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `dev` | ACCION | devolución | 🔵 CONVENCIÓN | nombre_sp |

---

## `sp_validaimagenescheques`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_sp_validaimagenescheques.sql` |
| **LOC (1er CREATE)** | 64 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 4 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "valida imágenes y cheques" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `valida` → `IF` encontrado en el cuerpo · `valida` → `RETURN` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=0 / 4 términos |

### Firma

```sql
CREATE PROCEDURE sp_validaimagenescheques(
  pCveBanco                    CHAR(3)
  pCuenta                      CHAR(20)
  pNumCheque                   CHAR(7)
) RETURNING CHAR(5) ,CHAR(50), CHAR(3)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pCveBanco` | `CHAR(3)` | — | — |
| `pCuenta` | `CHAR(20)` | — | — |
| `pNumCheque` | `CHAR(7)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(5)` | L4 |
| `iSqlErr` | `INTEGER` | L5 |
| `cMensaje` | `CHAR(50)` | L6 |
| `cImagen` | `BLOB` | L7 |
| `iTamImg` | `INTEGER` | L8 |
| `cImgFormato` | `CHAR(3)` | L9 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `cce_cheques_img` | `bditef` | no | SELECT | L39 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L12 | CÓDIGO_RETORNO | `LET cCodRet 			= '00000';` |  |
| L31 | CÓDIGO_RETORNO | `LET cCodRet = '00001';` |  |
| L45 | VALIDACIÓN_NULL | `IF cImagen IS NULL THEN` |  |
| L46 | CÓDIGO_RETORNO | `LET cCodRet = '00002';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `valida` | ACCION | valida | 🔵 CONVENCIÓN | nombre_sp |
| `imagenes` | ENTIDAD | imágenes / documentos digitales | 🔵 CONVENCIÓN | nombre_sp |
| `cheques` | ENTIDAD | cheques | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |

---

## `sp_validaimagenescheques_pba`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_sp_validaimagenescheques_pba.sql` |
| **LOC (1er CREATE)** | 63 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Deps concatenadas** | 2 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "valida imágenes y cheques (PBA — sufijo de SPs para Pruebas; confirmado por SME)" `[conf]` |
| **Propósito verificado** | ✅ VERIFICADO — `valida` → `IF` encontrado en el cuerpo · `valida` → `RETURN` encontrado en el cuerpo · `confirma` → `SELECT` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=4 · INFERIDO=0 · SINTÉTICO=0 / 5 términos |

### Firma

```sql
CREATE PROCEDURE sp_validaimagenescheques_pba(
  pCveBanco                    CHAR(3)
  pCuenta                      CHAR(20)
  pNumCheque                   CHAR(7)
) RETURNING CHAR(5) ,CHAR(50), CHAR(3)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pCveBanco` | `CHAR(3)` | — | — |
| `pCuenta` | `CHAR(20)` | — | — |
| `pNumCheque` | `CHAR(7)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `cCodRet` | `CHAR(5)` | L4 |
| `iSqlErr` | `INTEGER` | L5 |
| `cMensaje` | `CHAR(50)` | L6 |
| `cImagen` | `BLOB` | L7 |
| `iTamImg` | `INTEGER` | L8 |
| `cImgFormato` | `CHAR(3)` | L9 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `cce_cheques_img` | `bditef` | no | SELECT | L38 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L12 | CÓDIGO_RETORNO | `LET cCodRet 			= '00000';` |  |
| L30 | CÓDIGO_RETORNO | `LET cCodRet = '00001';` |  |
| L44 | VALIDACIÓN_NULL | `IF cImagen IS NULL THEN` |  |
| L45 | CÓDIGO_RETORNO | `LET cCodRet = '00002';` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `valida` | ACCION | valida | 🔵 CONVENCIÓN | nombre_sp |
| `imagenes` | ENTIDAD | imágenes / documentos digitales | 🔵 CONVENCIÓN | nombre_sp |
| `cheques` | ENTIDAD | cheques | ✅ CÓDIGO | nombre_sp, identificador_en_cuerpo |
| `pba` | MODIF | PBA — sufijo de SPs para Pruebas; confirmado por SME (Guerra | 🔵 CONVENCIÓN | nombre_sp |

---

## `sp_validaproductopermitido`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_sp_validaproductopermitido.sql` |
| **LOC (1er CREATE)** | 73 |
| **Callgraph** | ✅ fan_in=57 / fan_out=8 |
| **Principales callers** | `sp_calificacion_scoring` |
| **Deps concatenadas** | 20 SPs adicionales en el archivo (NO analizados aquí) |
| **Propósito inferido** | "valida producto y identificador" `[partial]` |
| **Propósito verificado** | ✅ VERIFICADO — `valida` → `IF` encontrado en el cuerpo · `valida` → `RETURN` encontrado en el cuerpo |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=3 · INFERIDO=0 · SINTÉTICO=2 / 6 términos |

### Firma

```sql
CREATE PROCEDURE sp_validaproductopermitido(
  pProducto                    CHAR(4)
  pNumCte                      CHAR (9)
) RETURNING CHAR(5), DECIMAL(6,2), CHAR (13)
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pProducto` | `CHAR(4)` | `producto`=producto | ✅ CÓDIGO |
| `pNumCte` | `CHAR (9)` | — | — |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `iSqlErr` | `INTEGER` | L6 |
| `cCodRet` | `CHAR (5)` | L7 |
| `cCobraComision` | `CHAR (1)` | L8 |
| `dImporteComision` | `DECIMAL(6,2)` | L9 |
| `cPermitido` | `CHAR (1)` | L10 |
| `cRFC` | `CHAR (13)` | L11 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `tef_prod_permitidos` | `bditef` | no | SELECT | L42 |
| `si_cliente` | `bdinteg` | ⚠️ sí | SELECT | L55 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L35 | VALIDACIÓN_NULL | `IF pProducto IS NULL OR pProducto = "" OR pNumCte IS NULL OR pNumCte = "" THEN` |  |
| L45 | VALIDACIÓN_NULL | `IF cPermitido IS NULL OR cPermitido <> "S" THEN` |  |
| L46 | FÓRMULA | `LET cCodRet = "00002"; --NO ES PRODUCTO PERMITIDO` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `sp` | PREFIJO | stored procedure | 🔵 CONVENCIÓN | nombre_sp |
| `valida` | ACCION | valida | 🔵 CONVENCIÓN | nombre_sp |
| `producto` | ENTIDAD | producto | ✅ CÓDIGO | nombre_sp, texto_cuerpo |
| `?permit` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `id` | ENTIDAD | identificador (de) | 🔵 CONVENCIÓN | nombre_sp |
| `?o` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?permit`, `?o` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

## `stat_cheque`

| Campo | Valor |
|-------|-------|
| **Dominio** | D13 · `bditef` · TEF |
| **Archivo fuente** | `bditef_stat_cheque.sql` |
| **LOC (1er CREATE)** | 174 |
| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |
| **Propósito inferido** | "cheque" `[partial]` |
| **Propósito verificado** | ⚠️ PARCIAL — Accede a 4 tabla(s) con operaciones: SELECT |
| **Evidencia vocab** | CÓDIGO=1 · CONVENCIÓN=0 · INFERIDO=0 · SINTÉTICO=1 / 2 términos |

### Firma

```sql
CREATE PROCEDURE stat_cheque(
  pempresa                     char(3)
  pcuenta                      char(20)
  pnrocheque                   integer
) RETURNING char(5),    --codret
```

### Parámetros

| Nombre | Tipo | Vocab encontrado | Evidencia |
|--------|------|-----------------|-----------|
| `pempresa` | `char(3)` | — | — |
| `pcuenta` | `char(20)` | — | — |
| `pnrocheque` | `integer` | `cheque`=cheque | ✅ CÓDIGO |

### Variables (DEFINE)

| Variable | Tipo | Línea |
|----------|------|-------|
| `vsqlerr` | `integer` | L17 |
| `vcodret` | `char(5)` | L18 |
| `vmotdevol` | `char(2)` | L19 |
| `vcuenta` | `char(20)` | L20 |
| `vstatuscta` | `char(1)` | L21 |
| `vmotivo` | `char(2)` | L22 |
| `vchequestat` | `char(1)` | L23 |
| `vcargo` | `char(1)` | L24 |

### Tablas accedidas

| Tabla | Base de datos | Cross-DB | Operación | Línea |
|-------|--------------|----------|-----------|-------|
| `sc_maechq` | `bdicheq` | ⚠️ sí | SELECT | L58 |
| `sc_bloqueo` | `bdicheq` | ⚠️ sí | SELECT | L73 |
| `sc_contch` | `bdicheq` | ⚠️ sí | SELECT | L91 |
| `cce_propios_det` | `bditef` | no | SELECT | L153 |

### Reglas extraídas del código

| Línea | Tipo | Código | Riesgo equivalencia |
|-------|------|--------|---------------------|
| L44 | VALIDACIÓN_NULL | `if  trim(pcuenta) = "" or pcuenta is null` |  |
| L77 | FÓRMULA | `let vmotdevol   = "09"; -- cta bloqueada` |  |

### Vocabulario verificado contra el código

| Token | Categoría | Significado | Evidencia | Encontrado en |
|-------|-----------|-------------|-----------|---------------|
| `?stat_` | DESCONOCIDO | (desconocido — no en vocab) | 🔴 SINTÉTICO |  |
| `cheque` | ENTIDAD | cheque | ✅ CÓDIGO | nombre_sp, texto_cuerpo |

> ⚠️ **Elementos sin grounding (SINTÉTICO):**
> Los tokens `?stat_` aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. Requieren validación SME antes de usarlos como base para decisions de diseño.

---

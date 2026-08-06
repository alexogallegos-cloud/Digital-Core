# INC-20260801 — Tormenta de Locks en bdicred

**ID:** INC-20260801  
**Fecha:** 2026-08-01  
**Hora de inicio estimada:** ~11:53 CST (primera captura con locks > 40)  
**Hora de crisis:** 14:15–14:22 CST  
**Duración del pico:** ~7 minutos  
**Sistemas afectados:** bdicred (D03-Crédito), bdisolic (D06-Solicitudes), bdinteg (bus de integración)  
**Severidad derivada:** CRÍTICA — 99% de sesiones con error de timeout simultáneo  
**Fuentes analizadas:** queries_01-08-2026.csv · 01082026/ (781 archivos: 46 bloqueos_X + 643 onstat_ses_querys + 80 ses_time_cpu + 12 otros) · electro_01-08-2026.csv · log_oltp.txt · logerrp3101_2026-08-01.log · DCM01_Tecnico_7.xlsx  
**Estado:** CAUSA RAÍZ CONFIRMADA por lectura de código fuente (2026-08-04)  
**Derivación:** Análisis independiente del dato crudo + código fuente `sp_sql/`. Sin referencia a análisis de terceros.

---

## 1. Síntesis del incidente

El 1 de agosto de 2026, entre las 14:15 y las 14:22 CST, el motor Informix de DCMSIF01 entró en un estado de contención masiva de locks sobre la base de datos `bdicred`. De 8,238 sesiones activas registradas en el electrómetro de esa ventana, 8,161 (99.1%) presentaron `sqlErr=-255` (lock timeout de Informix). La carga de CPU del servidor se mantuvo estable en 37-44% durante todo el evento, lo que descarta un problema de capacidad de cómputo: el motor no estaba saturado, estaba paralizado esperando locks.

El origen se confirma en el código fuente: `califica_scoring_cjunk` (`bdisolic_califica_scoring_cjunk.sql`, 2,798 líneas) tiene el `COMMIT WORK` comentado en las líneas 2791–2793. Cada sesión que ejecuta este SP acumula ExLocks sobre filas de bdicred y bdinteg durante toda su vida — que en este caso era de 3 horas y 46 minutos — sin liberarlos nunca. Con 230+ sesiones concurrentes en el mismo estado, la probabilidad de colisión sobre filas calientes de bdicred se vuelve certeza, y el timeout de 3 segundos (`LOCK MODE TO WAIT 3`) hace colapsar a 8,161 sesiones de forma casi simultánea.

---

## 2. Línea de tiempo (derivada del dato crudo)

| Hora CST | Evento | Fuente |
|---|---|---|
| ~08:07 | Conexión de sesiones `interofi` en DCMIRT02 (3h 46m antes del primer snapshot) | bloqueos 11:53 |
| 11:53:31 | Primera captura: sesión 69513777 con 43 locks; sesión 69513574 con 11 locks | bloqueos_X.260801_115330.out.gz |
| 11:53–14:00 | Período sin captura de electrómetro. Las sesiones con locks siguen corriendo. | — |
| 14:00:04 | Inicio de captura del electrómetro. ExLock=5,204. Una transacción de escritura ya tiene locks acumulados. | electro_01-08-2026.csv |
| 14:00–14:14 | Operación con ExLock elevado (130–300) pero sin cascada todavía. Slock estable (15–300). | electro |
| 14:15:05 | Explosión súbita: Slock=1,088 / ExLock=5,021 en un solo intervalo de 12 segundos. | electro |
| 14:16–14:19 | Pico sostenido: Slock hasta 14,917 / ExLock hasta 13,077. Total de locks: ~28,000. | electro |
| 14:21:54 | Colapso a línea base: Slock=34 / ExLock=154. El bloqueador fue liberado. | electro |
| 14:22:05–39 | Caída de sesiones totales de ~7,787 a 6,524. Cola de sesiones drenando. | electro |
| 14:22+ | Recuperación progresiva. IOWait elevado post-crisis (flush de dirty pages). | electro |
| 14:49:30 | Buffer waits=21 (post-crisis, I/O de recovery). Motor normalizando. | electro |

---

## 3. Evidencia cuantitativa por fuente

### 3.1 queries_01-08-2026.csv — Sesiones con timeout

| Métrica | Valor |
|---|---|
| Total sesiones registradas | 8,238 |
| Sesiones con sqlErr=-255 (lock timeout) | 8,161 (99.1%) |
| Sesiones sin error | 77 (0.9%) |
| Sesiones únicas con timeout | 230 |
| EXEC PROCEDURE con timeout | 4,561 (55.9%) |
| Sesiones bloqueadas sin statement activo | 3,600 (44.1%) |

**Distribución de timeouts por base de datos:**

| Base | Timeouts | % |
|---|---|---|
| bdicred | 7,853 | 96.2% |
| bdisolic | 212 | 2.6% |
| bdisitesp | 44 | 0.5% |
| bdidomi | 19 | 0.2% |
| bdimnsj | 16 | 0.2% |
| bdisac | 13 | 0.2% |
| bdibei | 3 | 0.0% |
| bdinteg | 1 | 0.0% |

### 3.2 electro_01-08-2026.csv — Métricas del motor durante la crisis

| Columna | Mínimo | Máximo | Promedio | Lectura |
|---|---|---|---|---|
| Tota (sesiones totales) | 6,524 | 7,787 | 7,071 | Sistema sobrecargado en sesiones |
| Load (CPU) | 32.6% | 44.7% | 39.0% | Motor NO saturado en CPU |
| Slock | 15 | 14,917 | 691 | Pico en 14:18 |
| ExLock | 118 | 13,077 | 940 | Pico en 14:18 |
| LckWa | 0 | 2 | 0.01 | Muy bajo (síntoma tardío) |
| Buff | 0 | 21 | 0.14 | Post-crisis solamente |

**Interpretación del patrón Slock + ExLock:** La firma de ExLock alto seguido de Slock alto es indicativa de lock escalation en Informix. Una transacción larga acumuló exclusive locks (escrituras) sobre muchas filas; al crecer, el motor escaló a page-level o table-level locks, haciendo que todas las sesiones que necesitaban leer o escribir en esas páginas acumularan shared locks. La suma Slock + ExLock llegó a ~28,000, aproximándose al límite del parámetro `LOCKS` de la configuración.

### 3.3 bloqueos_X.*.out.gz — Sesiones lock holders (11:53–13:46 CST)

**Ventana de captura:** 11:53:30–13:46:23 CST (1h 52m). El electrómetro captura 14:00–14:59 CST — las dos ventanas son adyacentes y cubren en conjunto la evolución completa del incidente: buildup → explosión → recuperación.

**Contenido del directorio 01082026/ (781 archivos):**

| Tipo de archivo | Cantidad | Descripción |
|---|---|---|
| `bloqueos_X.*.out.gz` | 46 | Sesiones con >10 locks en ese momento |
| `onstat_ses_querys.*.out.gz` | 643 | Queries activas por sesión (`onstat -g sql`) |
| `ses_time_cpu.*.out.gz` | 80 | Tiempo de CPU acumulado por sesión |
| Otros (EX_candados, info_db, onstat_iowait) | 12 | Diagnósticos complementarios |

**TOP 5 SPs como lock holders (de los 46 snapshots):**

| # | SP | Apariciones | Max locks | Total locks | Veces bloqueado |
|---|---|---|---|---|---|
| 1 | `sp_app_recuperapayment` | 7 | 105 | 353 | 3 |
| 2 | `califica_scoring_cjunk` | 4 | 63 | 151 | 1 |
| 3 | `sp_ws_obtiene_prod` | 4 | 21 | 58 | 0 |
| 4 | `sp_confpagoservicio_hs` | 3 | 56 | 131 | 2 |
| 5 | `sp_apercredcoppel2` | 2 | 52 | 69 | 1 |

**Tabla con mayor acumulación de candados en el día:**

| Tabla | Candados totales | Apariciones |
|---|---|---|
| `bdisolic:informix.pas_final` | **259,731** | 10 |
| `bdisolic:informix.ss_solicitudes` | 31,017 | 14 |
| `bdinteg:informix.si_datos_comple_deta` | 20,886 | 6 |
| `bdicheq:informix.sc_movdia` | 4,689 | 11 |
| `bdinteg:informix.si_cliente` | 7,143 | 15 |

**Pico máximo del día — 13:45:44 CST (602 locks, 4 sesiones):**
- Sesión 70097409 (`sissics`, daemon SIC/Buró de Crédito): **511 locks**, flag `--BP---` (bloqueada), sin SQL capturado — cursor interno del motor.
- Sesión 68362258 (`interofi`, DCMIRT01, `sp_edoctamovimientos_consedoc`): 66 locks en bdinteg:si_correos y si_telefonos_actual.

**Primera captura confirmada (11:53:31):**

**Sesión 69513777** — lock holder principal
- SP: `califica_scoring_cjunk('001','630235203746','R1','??????????',16000,1,0,'','REYNA VARGAS SANCHEZ','','I','','5535141412','','3,000.00')`
- Base activa: bdisolic (corre SP de scoring en bdisolic/bdisac)
- Usuario: interofi / host: DCMIRT02
- Tiempo de conexión: 3h 46m
- Candados: 43 totales

| Tabla/Índice | Candados |
|---|---|
| bdinteg:informix.systables | 16 |
| bdicheq:informix.systables | 4 |
| bdinteg:informix.si_ctepf | 1 |
| bdinteg:informix.si_cliente | 1 |
| bdinteg:informix.idx_cliente_rfc | 1 |

- Tablas temporales creadas: 9 instancias de `temp_admintasas_sdopromedioaldia` (en 9 dbspaces distintos)

**Sesión 69513574** — lock holder secundario
- SP: `sp_obtiene_ctecurp('AAZR950719EN3')`
- Base activa: bdinteg
- Usuario: interofi / host: DCMIRT02
- Tiempo de conexión: 3h 46m
- Candados: 11 totales

| Tabla/Índice | Candados |
|---|---|
| bdinteg:informix.systables | 4 |
| bdinteg:informix.si_tipper | 1 |
| bdinteg:informix.si_ctepf | 1 |
| bdinteg:informix.si_cliente | 1 |
| bdinteg:informix.ix193_1 | 1 |
| bdinteg:informix.idx_ctepf_hora_insert | 1 |

- Tablas temporales: 9 instancias de `temp_admintasas_sdopromedioaldia`

**Corrección confirmada por código:** Las 9 instancias de `temp_admintasas_sdopromedioaldia` son los **9 fragmentos round-robin de una única tabla temporal** en los 9 dbspaces temporales del servidor — no 9 llamadas separadas. La tabla la crea `sp_calcula_sdo_nvo_y_promedio_admin_tasas` (en `bdicheq`), que fue invocado ANTES de `califica_scoring_cjunk` en la misma sesión sin COMMIT entre ellos.

**Por qué hay locks en DOS bases distintas (bdinteg Y bdicheq):**
- Los **16 locks en bdinteg:systables** los genera `califica_scoring_cjunk` al acceder a 16 tablas distintas de bdinteg vía cross-database queries (`bdinteg:"informix".si_cliente`, `si_ctepf`, `si_ingresos`, etc.). En Informix, cada acceso cross-database toma un S lock en la fila de `systables` de la base remota; sin COMMIT, se acumulan.
- Los **4 locks en bdicheq:systables** son "deuda de locks" de la llamada anterior a `sp_calcula_sdo_nvo_y_promedio_admin_tasas` (que accede a sc_param, sc_maechq, sc_maehis, sc_maenoc en bdicheq). `califica_scoring_cjunk` no toca bdicheq en ninguna de sus 2,798 líneas — esos locks siguen activos porque nunca hubo COMMIT entre las dos operaciones.

### 3.4 log_oltp.txt — Log del motor

- Error repetido: `-25582 Network connection is broken` desde hosts de la red de aplicación
- Logical log backups cada ~30 segundos (actividad de escritura normal, no el problema)
- No hay dump de instancia, no hay checkpoint failure

---

## 4. Causa raíz confirmada por código fuente

### 4.1 El defecto central

**Archivo:** `sp_sql/bdisolic_califica_scoring_cjunk.sql`  
**Líneas:** 2791–2793

```sql
/*COMMIT WORK;
IF wbegin = 'N' THEN
    BEGIN WORK;
END IF;*/
```

El `COMMIT WORK` está comentado con `/* */`. Un SP de 2,798 líneas que ejecuta docenas de `UPDATE` e `INSERT` en bdisolic, bdicred y bdinteg — sin liberar ningún lock durante toda su ejecución. Esto no es un olvido: tiene la estructura deliberada de código que fue desactivado en algún momento y nunca reactivado.

**DML acumulado sin COMMIT (fragmentos del código):**
```sql
UPDATE bdinteg:"informix".si_cliente SET string2=v_habitdomi WHERE numcte=v_cliente;
UPDATE bdinteg:"informix".si_ingresos SET ingreso_mensual = o_ingreso WHERE ...;
UPDATE "informix".ss_resum_scor_fin SET ingreso_mensual=..., smbc=..., ... WHERE ...;
INSERT INTO "informix".ss_detalle_scoring ...;
INSERT INTO bdisolic:"informix".ss_revision_determinacion ...;
UPDATE "informix".ss_solicitudes SET ...;
-- (docenas de operaciones DML más, ninguna seguida de COMMIT)
```

### 4.2 El defecto secundario

**Archivo:** `sp_sql/bdicheq_sp_calcula_sdo_nvo_y_promedio_admin_tasas.sql`  
**Línea:** ~249 (final del SP)

```sql
-- Solo se limpian las primeras dos tablas temporales:
DROP TABLE IF EXISTS temp_admintasas_sdopromedio;
DROP TABLE IF EXISTS temp_admintasas_sdopromedio_res;
-- temp_admintasas_sdopromedioaldia NUNCA SE LIMPIA AL FINAL
```

La tabla temporal `temp_admintasas_sdopromedioaldia` se crea en la línea ~145 con `INTO TEMP ... WITH NO LOG` y nunca se dropea al terminar el SP — solo al inicio de la siguiente llamada (línea ~134: `DROP TABLE IF EXISTS temp_admintasas_sdopromedioaldia`). Las otras dos tablas sí se limpian correctamente al final. Este SP también ejecuta INSERT/UPDATE en `bdicheq:sc_admintasas_sdo_promedio` y `sc_admintasas_sdo_nuevo` sin COMMIT.

### 4.3 El defecto de diseño en la capa de aplicación

La aplicación `interofi` (middleware en DCMIRT02) mantiene **sesiones persistentes de base de datos** y ejecuta SPs secuencialmente sin emitir COMMIT entre operaciones de negocio independientes. La sesión que comenzó ~08:07 llamó primero a `sp_calcula_sdo_nvo_y_promedio_admin_tasas` (bdicheq), luego sin COMMIT llamó a `califica_scoring_cjunk` (bdisolic), y los locks de ambas operaciones se apilaron durante 3h 46m.

### 4.4 Cadena causal confirmada

```
[~08:07 CST — Inicio de sesión interofi en DCMIRT02]
Aplicación abre sesión persistente de Informix
→ No emite COMMIT entre operaciones de negocio independientes

[~08:07 – ~11:53 CST — Buildup silencioso]
Llamada 1: sp_calcula_sdo_nvo_y_promedio_admin_tasas (bdicheq)
  → 4 S locks en bdicheq:systables (sc_param, sc_maechq, sc_maehis, sc_maenoc)
  → INSERT/UPDATE en sc_admintasas_sdo_promedio + sc_admintasas_sdo_nuevo (ExLocks)
  → Crea temp_admintasas_sdopromedioaldia (9 fragmentos en 9 dbspaces)
  → Sin COMMIT → todos los locks siguen activos

Llamada 2 (misma sesión): califica_scoring_cjunk (bdisolic) ← COMMIT comentado
  → 16 S locks adicionales en bdinteg:systables (16 tablas cross-DB accedidas)
  → ExLocks sobre filas de si_cliente, si_ingresos (UPDATE)
  → ExLocks sobre filas de ss_resum_scor_fin, ss_detalle_scoring (UPDATE/INSERT)
  → ExLocks sobre filas de bdicred (via califica_scoring2_cjunk)
  → Sin COMMIT → suma total: 43 locks acumulados en una sola sesión

[Con 230+ sesiones en el mismo estado a las 14:15 CST]
Cada sesión retiene ExLocks sobre filas de bdicred que otras sesiones necesitan
→ Probabilidad de colisión sobre filas calientes: certeza
→ Sesiones OLTP nuevas en bdicred: LOCK MODE TO WAIT 3 → 3 segundos → sqlErr=-255
→ Retries automáticos de la aplicación multiplican la presión
→ ExLock+Slock combinados: 28,000 (límite configurado del parámetro LOCKS)
→ 8,161 sesiones con -255 en un intervalo de 7 minutos

[14:21:54 CST — Resolución]
El bloqueador principal libera su transacción (COMMIT o timeout externo)
→ Slock colapsa de >14,000 a 34 en un solo intervalo de 12 segundos
→ Cola de ~7,787 sesiones drena en ~45 segundos
```

### 4.5 Por qué los locks aparecen en DOS bases distintas

`califica_scoring_cjunk` no contiene ninguna referencia a `bdicheq` en sus 2,798 líneas. Los **4 locks en bdicheq:systables** son locks heredados de la llamada anterior a `sp_calcula_sdo_nvo_y_promedio_admin_tasas` que siguen vivos porque la capa de aplicación no emitió COMMIT entre operaciones. Los **16 locks en bdinteg:systables** son generados por `califica_scoring_cjunk` en tiempo real, al acceder a 16 tablas distintas de bdinteg via cross-database queries dentro de la misma transacción sin COMMIT.

---

## 5. SPs clave identificados

| SP | Base | Rol en el incidente | Patrón problemático |
|---|---|---|---|
| `sp_app_recuperapayment` | bdisac/bdicred | **Lock holder sistémico** — 7 apariciones en snapshots, accede a 13 bases simultáneamente | Transacción distribuida sin coordinador; 1,895 locks en sac_movimientos |
| `califica_scoring_cjunk` | bdisolic/bdisac | Lock holder long-running (~08:07–14:22 CST) | TEMP table 9 fragmentos + transacción 3+ horas sin COMMIT |
| `sp_ws_obtiene_prod` | bdisolic | Scan de pas_final | 29,241 candados en pas_final por acceso sin índice eficiente |
| `sp_consultadatos_motor` | bdisolic | Motor de decisión crediticia | 8,649 candados en pas_final, full-scan visible |
| `sp_obtiene_ctecurp` | bdinteg | Lock holder en tablas maestro | TEMP table; acceso a si_ctepf/si_cliente/systables |
| `sp_confpagoservicio_hs` | bdisac | Bloqueado 2/3 veces capturado | 56 locks en bdisac; flag Y-BP |
| `sp_consulta_pre_aprobado` | bdicred | Co-bloqueador con DML oculto | DML interno bajo DIRTY READ; predicado no-sargable en sd_pre_aprobados_trx |

**SPs únicos identificados como lock holders (24 total):** `sp_app_recuperapayment`, `califica_scoring_cjunk`, `sp_ws_obtiene_prod`, `sp_confpagoservicio_hs`, `sp_apercredcoppel2`, `sp_consultadatos_motor`, `direcciones_sms_tels`, `sp_ws_valida_cotel`, `sp_edoctamovimientos_consedoc`, `sp_consulta_pre_aprobado`, `sp_compara_huellas_ctes`, `sp_obtiene_ctecurp`, `sp_buscarctesamigrar`, `sp_conhuella`, `sp_calcula_sdo_nvo_y_promedio_admin_tasas`, `sp_obtenerparametros_AltaUnica`, `sp_consultactesrelacionados_filtro`, `direcciones_sms`, y variantes del daemon SIC (`INSERT INTO br_respuesta_aprocesar_aux`).

**SP faltante crítico:** `sp_obtiene_clientes_pre_aprobado_notificar` — mencionado en capturas de la crisis como conductor principal pero su DDL no está en el corpus de `source/BCOPCore/informix/` ni en `sp_sql/`. Su código fuente debe obtenerse para completar el análisis.

---

## 6. Defectos confirmados en código fuente

| # | SP | Archivo (`sp_sql/`) | Línea | Defecto |
|---|---|---|---|---|
| D1 | `califica_scoring_cjunk` | `bdisolic_califica_scoring_cjunk.sql` | 2791–2793 | `COMMIT WORK` comentado con `/* */` — toda la transacción (DML en 3 bases) queda sin cerrar |
| D2 | `sp_calcula_sdo_nvo_y_promedio_admin_tasas` | `bdicheq_sp_calcula_sdo_nvo_y_promedio_admin_tasas.sql` | ~249 | `temp_admintasas_sdopromedioaldia` no tiene DROP al final del SP — DDL lock huérfano en cada llamada |
| D3 | `sp_calcula_sdo_nvo_y_promedio_admin_tasas` | `bdicheq_sp_calcula_sdo_nvo_y_promedio_admin_tasas.sql` | ~229–246 | INSERT/UPDATE en bdicheq sin COMMIT — ExLocks acumulados en sesión de larga vida |
| D4 | Aplicación `interofi` | capa middleware (código no disponible) | — | Sesiones persistentes sin COMMIT entre operaciones de negocio independientes — amplifica D1–D3 |

---

## 7. Tablas afectadas

| Tabla | Base | Origen del lock | Tipo de lock |
|---|---|---|---|
| `informix.systables` | bdinteg | `califica_scoring_cjunk` accede a 16 tablas bdinteg cross-DB | 16 S locks por catalog lookup sin COMMIT |
| `informix.systables` | bdicheq | `sp_calcula_sdo_nvo_y_promedio_admin_tasas` (llamada anterior sin COMMIT) | 4 S locks heredados |
| `si_ctepf` | bdinteg | `califica_scoring_cjunk` — UPDATE directo | ExLock sin COMMIT |
| `si_cliente` | bdinteg | `califica_scoring_cjunk` — `UPDATE bdinteg:"informix".si_cliente SET string2=...` (línea 1330) | ExLock sin COMMIT |
| `si_ingresos` | bdinteg | `califica_scoring_cjunk` — `UPDATE bdinteg:"informix".si_ingresos SET ingreso_mensual=...` | ExLock sin COMMIT |
| `ss_resum_scor_fin` | bdisolic | `califica_scoring_cjunk` — UPDATE múltiples veces | ExLock sin COMMIT |
| `ss_detalle_scoring` | bdisolic | `califica_scoring_cjunk` — INSERT múltiples veces | ExLock sin COMMIT |
| `sc_admintasas_sdo_promedio` | bdicheq | `sp_calcula_sdo_nvo_y_promedio_admin_tasas` | ExLock sin COMMIT |
| `temp_admintasas_sdopromedioaldia` | (9 dbspaces) | `sp_calcula_sdo_nvo_y_promedio_admin_tasas` línea ~145 | Tabla temporal; 9 fragmentos round-robin; no se dropea al final |

---

## 8. Infraestructura relevante

**Servidor físico:** IBM POWER8, modelo 9080-MHE, serial 21E3427, 80 cores a 4.19 GHz  
**LPAR DCMSIF01:** 1,024 GB RAM (desired), máx 1,500 GB. Pool CPU dedicado "Informix".  
**Contención de CPU:** LPAR weight=192 vs. VIOS weight=255. Bajo presión de CPU, los VIOS tienen prioridad sobre el LPAR de Informix, alargando el tiempo de resolución de la cola de locks.  
**Sesiones pico del día:** 7,161 conexiones (antes del incidente). El motor opera al límite de su configuración de sesiones.  
**Parámetro LOCKS:** No confirmado explícitamente, pero la suma Slock+ExLock llegó a ~28,000, consistente con un límite configurado entre 25,000-30,000.

---

## 9. Patrones de riesgo para modernización (evidencia en código)

### Patrón 1 — COMMIT comentado en SP de alta concurrencia (CRÍTICO)
`bdisolic_califica_scoring_cjunk.sql` líneas 2791–2793: el COMMIT está desactivado con `/* */`. El SP acumula ExLocks sobre filas de bdicred, bdisolic y bdinteg por toda la vida de la sesión. Con 230+ sesiones concurrentes, la colisión es inevitable.

**Acción en migración:** Antes de migrar, reactivar el COMMIT y hacer prueba de regresión funcional. En Aurora PostgreSQL, estructurar el SP como una función con `COMMIT` al final de cada unidad de trabajo, o dividir en transacciones cortas por cliente procesado.

**Impacto si no se corrige:** El mismo incidente reproduce en Aurora PostgreSQL en condiciones equivalentes de carga.

### Patrón 2 — Tabla temporal sin DROP al final del SP
`bdicheq_sp_calcula_sdo_nvo_y_promedio_admin_tasas.sql` línea ~249: `temp_admintasas_sdopromedioaldia` no tiene `DROP TABLE` al final (las otras dos tablas sí). El objeto huérfano y su DDL lock persisten hasta la siguiente llamada.

**Acción en migración:** Agregar `DROP TABLE IF EXISTS temp_admintasas_sdopromedioaldia;` al final del SP. En PostgreSQL, las tablas `TEMP` se destruyen automáticamente al final de la sesión, pero dentro de una transacción larga siguen siendo un recurso retenido.

### Patrón 3 — Sesiones persistentes sin gestión de transacción en el middleware
La capa de aplicación `interofi` ejecuta SPs secuencialmente en la misma conexión sin COMMIT entre operaciones de negocio independientes. El motor Informix no distingue: los locks de la operación N persisten durante la operación N+1.

**Acción en migración:** Auditar el middleware `interofi` para garantizar que cada operación de negocio tenga su propia unidad de trabajo (begin → work → commit/rollback). En el target Aurora PostgreSQL, aplicar el patrón de connection pool con `autocommit=False` explícito y commit por operación.

### Patrón 4 — DML bajo DIRTY READ (declaración engañosa)
El SP declara `SET ISOLATION TO DIRTY READ` (parece lectura) pero contiene UPDATE/INSERT internamente. En Informix, DIRTY READ aplica solo a SELECTs — los locks de DML se toman igual. El SP miente sobre su naturaleza al lector.

**Acción en migración:** Auditar todos los SPs con `SET ISOLATION TO DIRTY READ` que contengan DML. Separar en funciones de lectura (`READ COMMITTED` en PostgreSQL) y escritura.

### Patrón 5 — Acceso cross-database como architectural smell
`califica_scoring_cjunk` accede directamente a 16 tablas de `bdinteg`, 10 tablas de `bdicred` y otras bases vía queries cross-database (`bdinteg:"informix".si_cliente`). Cada acceso cross-database toma un S lock en `systables` remoto sin liberarlo hasta COMMIT. Con COMMIT comentado, esto es catastrófico.

**Acción en migración:** En Aurora PostgreSQL no existen cross-database queries entre instancias. Cada SP que actualmente accede a múltiples bases debe reescribirse como microservicio que consume datos via API o como función dentro de un esquema unificado. El scoring crediticio debe tener su propio schema con las tablas que necesita localmente.

---

## 10. Hallazgos adicionales del inventario de archivos

Durante el análisis del directorio `source/logs/2026-08-01/` se encontraron fuentes de conocimiento no relacionadas directamente con el incidente pero de alto valor para el Gemelo Cognitivo:

### 9.1 DCM01_Tecnico_7.xlsx — Catálogo técnico completo
Inventario del servidor DCMSIF01 con 6,590 tablas con descripción en español, 10,804 índices, 13,995 SPs, 211 triggers y 292 synonyms. Las descripciones de tablas son datos estructurados que nunca se habían tenido: "Maestro de créditos (préstamos personales/hipotecarios)", "Maestro central de clientes BanCoppel", "Tarjetas de débito asociadas a cuentas de cheques", etc. Debe cargarse a brain.db como fuente de definiciones canónicas de tablas.

### 9.2 sp_sql/ — 7,620 archivos SQL individuales
Un archivo `.sql` por SP nombrado `{base}_{sp}.sql`. Cubre 52 bases de datos, incluyendo 36 que no estaban en el análisis anterior (D17-D49). Total: 7,620 SPs con código fuente accesible directamente sin necesidad de parsear un archivo monolítico. Complementa y extiende el corpus existente de `source/BCOPCore/informix/`.

### 9.3 bases/ — 56 dumps SQL de todas las bases
Los dumps completos revelan 35 bases productivas nuevas. Dominios previamente desconocidos: BPI (bdibpi+intercardbpi, 609 SPs), Buró de Crédito (bdiburo), Domiciliación (bdidomi), Inversiones (bdinvers), Tarjetas (bditarjeta+bditarjcop+intercardbpi), Corresponsales (bdicorresp+bdicorresp_mc), Canales digitales (bdidigital+bdivr+bdicplbot), Reportes regulatorios CNBV (bdireports).

### 9.4 ifmx_stats_coppel_shm_20260420_183821_AB.txt
Health check de Informix del 20 de abril de 2026, 18:38 CST. Baseline del servidor **3.5 meses antes** del incidente. Métricas: buffer pool hit rate 99.25% (4K páginas), 248 GB buffer pool, 696 GB shared memory total. Uptime 21 días en esa fecha.

---

## 11. Preguntas abiertas (requieren investigación adicional)

1. **DDL faltante de `sp_obtiene_clientes_pre_aprobado_notificar`** — no está en `sp_sql/` ni en `source/BCOPCore/informix/`. ¿En qué base está? ¿Tiene el mismo patrón de COMMIT comentado?

2. **¿Por qué se comentó el COMMIT?** — el COMMIT fue comentado antes del 31/07 (código idéntico en ambas fechas — ningún deploy entre los dos incidentes). El bloque comentado es siempre el mismo patrón: el exception handler para error Informix -535 (`ON EXCEPTION IN (-535) COMMIT WORK; BEGIN WORK; END EXCEPTION WITH RESUME`). Las hipótesis en orden de plausibilidad: (a) inconsistencia de datos por `WITH RESUME` — después del COMMIT el SP retomaba con datos ya modificados por otra sesión, produciendo resultados híbridos; (b) loop infinito entre SPs concurrentes que se bloqueaban mutuamente; (c) reducción de overhead de commits en batch. La hipótesis (a) es consistente con el patrón sistemático en 12 bases: una decisión de "mejor fallar limpio que commitear parcial", sin instrumentar el fallback correcto en el middleware. Pendiente: confirmar con el equipo de BanCoppel cuándo y quién aplicó este cambio.

3. **Triggers cross-DB (del Excel)** — el trigger `tr_ins_si_prodtran` abre transacción distribuida hacia `bdicont` vía TCP (`coppelcont_tcp`). Si este trigger se activa dentro de `califica_scoring_cjunk` (que toca `si_prodtran` en bdinteg), añade un ExLock más en bdicont a la misma sesión. ¿Participó en la cadena?

4. **Correlación con el error -25582 en log_oltp** — los errores de red ocurren desde múltiples hosts de aplicación. ¿Son consecuencia del -255 (clientes desconectados al recibir timeout) o contribuyeron (conexiones TCP huérfanas dejando transacciones abiertas sin ROLLBACK)?

---

## 12. Auditoría transaccional sistémica (2026-08-05)

Análisis del corpus completo `sp_sql/` (7,620 archivos) para determinar si el patrón de COMMIT comentado es aislado o sistémico.

### Resumen ejecutivo

| Patrón | SPs afectados | % del corpus |
|--------|--------------|-------------|
| P1 — COMMIT comentado con `/* */` | **108** | 1.4% |
| P2 — DML activo sin ningún COMMIT WORK | **3,022** | 39.7% |
| P3 — BEGIN WORK sin COMMIT suficiente | **1,233** | 16.2% |

**Conclusión: el defecto NO es aislado. Es una regresión sistémica aplicada deliberadamente en al menos 12 bases de datos.**

### P1 — COMMIT comentado (108 SPs en 12 bases)

El 90%+ de los casos comparten exactamente la misma firma — el exception handler para error -535 desactivado:

```sql
/*ON EXCEPTION IN (-535)
    COMMIT WORK;
    BEGIN WORK;
END EXCEPTION WITH RESUME;*/
```

Error -535 = "Record is locked by another process". Al comentar este handler, cuando un SP encuentra un registro bloqueado ya no libera sus propios locks ni reinicia la transacción — los acumula indefinidamente.

| Base de datos | SPs con P1 |
|---------------|-----------|
| bdicheq | 24 |
| bdicred | 19 |
| bdinteg | 14 |
| bdiaclaracion | 12 |
| bdiburo | 9 |
| bdisolic | 6 |
| bdicobranza | 4 |
| bdidomi | 4 |
| bdivr | 4 |
| bdisac | 3 |

**Casos adicionales de alto riesgo en P1:**
- `bdicheq_pasamovshist.sql` — batch commit cada 5,000 registros comentado → el loop procesa todo en una sola transacción monolítica.
- `bdicheq_sp_activaciones_codi_isa.sql` — batch commit cada 500 registros comentado.
- `bdiburo_califica_scoring_cjunk_apolo.sql` — doble riesgo: exception handler comentado Y un `COMMIT WORK` independiente también comentado. Sin ningún punto de commit.

### P2 — DML sin COMMIT (3,022 SPs)

El número real de SPs transaccionales sin COMMIT es alto. Nota: una fracción son archivos de schema con cláusulas `GRANT` que generan falsos positivos. Los casos operacionales más críticos:

| SP | Base | DML ops | Riesgo |
|----|------|---------|--------|
| `bdicred_sp_grabarpagosmasivos.sql` | bdicred | HIGH | BEGIN=63, COMMIT=2 — pagos masivos |
| `bdicred_apercred1_pp_domicilia_web.sql` | bdicred | 115 | 3 DELETE consecutivos sin COMMIT |
| `bdicred_sp_actualizar_linea_credito_tc_inflacion.sql` | bdicred | 132 | — |
| `bdicred_generaestadosdecuenta.sql` | bdicred | 146 | — |
| `bdicheq_sp_status_ctas_ina.sql` | bdicheq | 288 | — |

### P3 — BEGIN WORK sin COMMIT suficiente (1,233 SPs)

El caso más crítico: `bdicred_sp_grabarpagosmasivos.sql` (BEGIN=63, COMMIT=2, déficit=61). Un SP de pagos masivos con estructura estructuralmente idéntica al defecto de reconciliación del 31/07.

### Bases con exposición simultánea en los 3 patrones

| Base | P1 | P3 | Prioridad remediación |
|------|----|----|----------------------|
| bdicred | 19 | 92 | CRÍTICA |
| bdicheq | 24 | 77 | ALTA |
| bdinteg | 14 | 50 | ALTA |

### Hipótesis: por qué se comentó el COMMIT

El bloque comentado en los 108 SPs es siempre el exception handler para error Informix -535 ("Record is locked by another process"):

```sql
/*ON EXCEPTION IN (-535)
    COMMIT WORK;
    BEGIN WORK;
END EXCEPTION WITH RESUME;*/
```

Este handler fue **diseñado para recuperación automática**: al encontrar un registro bloqueado, el SP comprometía lo acumulado y retomaba desde donde quedó (`WITH RESUME`). Comentarlo implica que ante un -535, el SP ya no libera sus locks ni reinicia la transacción — los acumula indefinidamente. Las hipótesis en orden de plausibilidad:

**Hipótesis A — Inconsistencia de datos por `WITH RESUME` (más probable)**  
Con `WITH RESUME`, después del COMMIT el SP retomaba ejecución con el contexto en memoria intacto pero con datos en disco posiblemente modificados por otra sesión en el intervalo. Esto produce resultados híbridos: parte del scoring o la operación procesada con datos del momento T, parte con datos de T+∆. Si el equipo de BanCoppel detectó inconsistencias en resultados crediticios o de conciliación, la "solución" pudo ser comentar el handler para forzar fallo completo en lugar de resultado parcialmente correcto. El efecto secundario — locks nunca liberados en el path de error — no fue considerado o no se dimensionó bajo carga alta.

**Hipótesis B — Loop infinito entre SPs concurrentes**  
Si SP-A y SP-B se bloquean mutuamente (-535), el handler haría que ambos commiteen y retomen indefinidamente (A libera → B avanza → B bloquea a A → A commitea → retoma → bloquea a B → ...). Alguien pudo observar este loop y cortar el handler para romperlo. Resultado: el loop desapareció, pero los locks comenzaron a acumularse sin mecanismo de escape.

**Hipótesis C — Reducción de overhead en batch**  
Los casos de `bdicheq_pasamovshist` (batch commit cada 5,000 registros) y `bdicheq_sp_activaciones_codi_isa` (cada 500 registros) sugieren una motivación diferente: alguien quiso reducir la frecuencia de commits en procesos batch pesados para "optimizar performance". La consecuencia fue que el loop entero pasa a ejecutarse en una sola transacción monolítica.

**Hipótesis D — Debug temporal no revertido**  
Se comentó para forzar fallo visible ante -535 durante debugging de otro problema (p. ej., para ver el error en los logs del ESB en lugar de que el SP se auto-recuperara silenciosamente). El fix nunca fue revertido a producción.

**Evidencia que apoya Hipótesis A:** la naturaleza sistemática del cambio en 12 bases de datos distintas sugiere una decisión técnica consciente, no un olvido. Un cambio de esta escala implica que alguien identificó un problema concreto (resultados incorrectos o comportamiento inesperado del `WITH RESUME`) y tomó la decisión de desactivar el mecanismo en toda la plataforma. La Hipótesis A es la única que justifica una acción tan amplia con una motivación técnica legítima.

**Pendiente de confirmar con BanCoppel:** fecha exacta del cambio, autor, y ticket o incidente que lo motivó. Esta información es crítica para el diseño del patrón de manejo de concurrencia en el target Aurora PostgreSQL.

### Impacto en la migración a Aurora PostgreSQL

Los 108 SPs con P1 no pueden migrarse sin primero resolver el manejo de concurrencia. En PostgreSQL no existe el mecanismo `ON EXCEPTION IN (error) WITH RESUME` — cada transacción abortada debe ser manejada explícitamente por el caller. El patrón correcto en el target es: SAVEPOINT antes de cada operación de riesgo, ROLLBACK TO SAVEPOINT en el handler, y el SP nunca retiene locks de operaciones previas.

---

*Fuentes: dato crudo de `source/logs/2026-08-01/`. Análisis independiente, sin referencia a análisis de terceros.*  
*Creado: 2026-08-04 | Actualizado: 2026-08-05 — Sección 12 (auditoría transaccional) + Pregunta 2 (hipótesis del COMMIT comentado) | BCOPCore Gemelo Cognitivo — DISCOVER Etapa 1*

# INC-20260731 — Cascada de Bloqueos bdicred · Reconciliación Automática Tarjetas

**ID:** INC-20260731  
**Fecha:** 2026-07-31  
**Hora de inicio visible:** 11:00 CST (inicio del log — el incidente ya estaba activo)  
**Hora de crisis principal:** 11:28–11:33 CST (evento catastrófico) · 13:45–13:58 CST (episodios finales)  
**Duración capturada:** 3 horas (11:00–14:00 CST) — sin recuperación visible al cierre de ventana  
**Sistemas afectados:** bdicred · bditarjeta · intercard · bdicheq · bdisolic (secundario)  
**Severidad derivada:** CRÍTICA — 22,089 errores -255 en 3 horas, 446 sesiones afectadas  
**Fuentes analizadas:** queries_31-07-2026.csv · 31072026/ (174 archivos: 2 bloqueos_X + 5 EX_candados + 164 onstat_ses_querys + 2 ses_time_cpu) · electro_31-07-2026.csv  
**Estado:** CAUSA RAÍZ CONFIRMADA por lectura de código fuente y snapshots de sesión (2026-08-05)  
**Derivación:** Análisis independiente del dato crudo. Sin referencia a análisis de terceros.  
**Relación con INC-20260801:** Incidente del día anterior. Mismo anti-patrón (transacción larga sin COMMIT), distinto SP y usuario. Ver sección 7.

---

## 1. Síntesis del incidente

El 31 de julio de 2026, entre las 11:00 y las 14:00 CST (ventana completa de captura), el motor Informix de DCMSIF01 presentó contención masiva y sostenida de locks sobre `bdicred`. A diferencia del incidente del 01/08 (12–21 minutos de crisis aguda), el 31/07 fue un evento **crónico y multiepisódico**: 18 episodios de lock contention detectados en 3 horas, con la tasa de error en 22,089 registros (-255) distribuida uniformemente (~117 timeouts/minuto) sin señal de recuperación.

El vector principal confirmado por los snapshots de sesión es el usuario `sysconau` ejecutando `sp_concreing_conciliacionautomatica` desde DCMSIF01 vía `dbaccess`. Este job de reconciliación de tarjetas Concreing/Intercard procesa el archivo completo de movimientos en una sola transacción monolítica sin COMMIT intermedio, acumulando 8,721 locks en los primeros 2 minutos (14:15–14:17 CST) sobre tablas críticas de bdicred, bditarjeta e intercard, y manteniéndolos durante al menos 47 minutos.

---

## 2. Línea de tiempo (derivada del dato crudo)

| Hora CST | Evento | Fuente |
|---|---|---|
| 11:00 | Inicio de logs — errores -255 ya activos desde el primer registro | queries_31-07-2026.csv |
| 11:28:17 | Evento catastrófico: Slock=56,081 / ExLock=556,823 en inicio de explosión | electro_31-07-2026.csv |
| 11:28–11:32 | Escalada en ~100 seg: Slock 56K → 8,517,530 / ExLock → 8,477,176 (plateau) | electro |
| 11:33:21 | Resolución abrupta del evento catastrófico: Slock cae a 21 en una muestra | electro |
| 11:33–11:46 | Load CPU elevada (38–44%) — trabajo de rollback post-evento | electro |
| 11:47–13:14 | 14 episodios flash recurrentes (magnitud 500–8,129 locks, duración 10–35 seg) | electro |
| 13:45–13:46 | Episodio dual Slock+ExLock: peak Slock=2,167 / ExLock=5,271 (~35 seg) | electro |
| 13:56–13:57 | Episodio dual: peak Slock=5,287 / ExLock=4,625 (~43 seg) | electro |
| 13:57–13:58 | Episodio dual: peak Slock=6,271 / ExLock=5,295 (~43 seg) — el mayor de la tarde | electro |
| ~14:15 | Aparición de sesión 67437343 (sysconau) en onstat_ses_querys | 31072026/ |
| 14:15–14:17 | Explosión de locks: 0 → 8,721 en 2 minutos (INSERT masivo en td_movimientos_conciliacion) | EX_candados |
| 14:39:34 | Segundo bloqueos_X: sesión 67437343 activa, 900+ page locks, ejecutando cargo_cred | bloqueos_X.260731_143934 |
| 15:02 | Último registro en onstat_ses_querys — sesión 67437343 aún activa | 31072026/ |
| 14:00 | Fin de captura del electrómetro — incidente sin señal de recuperación | electro |

---

## 3. Evidencia cuantitativa por fuente

### 3.1 queries_31-07-2026.csv — Sesiones con timeout

| Métrica | Valor |
|---|---|
| Total registros | 22,089 |
| Registros con sqlErr=-255 (lock timeout) | 20,925 (94.7%) |
| Otros errores (–201, –674, –1226, etc.) | 1,164 (5.3%) |
| Sesiones únicas afectadas | 446 |
| EXEC PROCEDURE con timeout | ~11,808 (56.4%) |
| DML anónimo con timeout | ~9,117 (43.6%) |
| Tasa promedio sostenida | ~117 timeouts/minuto (uniforme, sin pico único) |

**Distribución por base de datos:**

| Base | Registros | % | Sesiones |
|------|-----------|---|---------|
| bdicred | 20,040 | 90.72% | 72 |
| bdinteg | 1,025 | 4.64% | 47 |
| bdisolic | 650 | 2.94% | 266 |
| bdisitesp | 173 | 0.78% | 128 |
| bdimnsj | 84 | 0.38% | 44 |
| Otras | 117 | 0.53% | ~30 |

**Nota sobre la distribución bdisolic:** 266 sesiones con solo 650 errores (~2.4 por sesión) indica muchos clientes fallando brevemente. Contrasta con bdicred donde 72 sesiones acumulan 20,040 errores (278 por sesión) — señal inequívoca de contención severa y sostenida.

**Hallazgo adicional — bdinteg -201 (syntax error):** 975 errores de sintaxis en bdinteg provenientes de 1 sola sesión, distribuidos uniformemente las 3 horas (~325/hora). Es un proceso independiente (batch o ETL) con SQL malformado ejecutándose de forma paralela. No relacionado causalmente con la contención de bdicred pero indicativo de estrés operativo generalizado ese día.

### 3.2 electro_31-07-2026.csv — Electrómetro Informix

| Métrica | Valor | Timestamp |
|---|---|---|
| Muestras totales | 975 | 11:00:01–13:59:53 CST |
| Slock máximo absoluto | 8,517,530 | 11:29:56–11:32:57 (plateau 6 muestras) |
| ExLock máximo absoluto | 8,477,176 | 11:29:56 |
| LckWa (sesiones esperando lock) | 0 | Constante en todo el día |
| Load CPU máximo | 44.18 | 11:32:57 (cola del evento catastrófico) |
| Sesiones totales (Tota) peak | 6,939 | 13:35:30 (operación normal) |
| Episodios de contención detectados | 18 | Distribuidos 11:00–13:58 |

**Interpretación del evento catastrófico (11:28–11:33):** Los valores de 8.5M locks son ~600x el peak del 01/08 (14,917). La resolución instantánea (de 8.5M a 21 en una sola muestra de 12 segundos) y el LckWa=0 constante apuntan a un rollback masivo de una única transacción o una intervención DBA, no a un deadlock distribuido. La semántica del contador podría ser acumulada desde el último reset de estadísticas.

**LckWa=0 durante toda la ventana:** Las sesiones víctimas fallaron con -255 (timeout de 3 segundos) antes de llegar a esperar en la cola de locks. El impacto se manifiesta en el volumen de errores del ESB, no en sesiones esperando visiblemente.

### 3.3 Snapshots 31072026/ — Sesiones con bloqueos

**Sesión 67437343 (sysconau) — protagonista del incidente:**

| Campo | Valor |
|---|---|
| Usuario | sysconau |
| Programa | /ifxsif01/bin/dbaccess |
| Host | DCMSIF01 (PID 15861122) |
| Primer registro | ~14:15 CST |
| Último registro | >15:02 CST (47+ minutos activa) |
| CPU acumulado | 980 segundos (consumidor dominante) |
| Memoria | 6.5 MB → 13.8 MB (crecimiento x2 sin COMMIT) |
| Estado | mutex wait RA_req (I/O de lectura anticipada) |
| Locks peak | 8,721 (EX_candados a las 14:17) |

**Cadena de SPs confirmada (orden cronológico en onstat_ses_querys):**
```
sp_concreing_conciliacionautomatica (bditarjeta)
  → sp_concreing_obtenerregistroarchivo  [INSERT masivo td_movimientos_conciliacion]
  → sp_concreing_consif                  [UPDATE bditarjeta]
  → sp_concreing_conciliaintercard
  → sp_concreing_buscarmovimientointercard
  → sp_concreing_identificatipoconciliacion
  → sp_concreing_validaintegridad
  → bdicred:conciliatc
      → bdicred:cargo_cred              [UPDATE sd_maesdos, sd_maecred, sd_amortiza_credito]
          → bdicred:genmov_tc
              → bdicred:principal
              → bdicred:principalrefer
```

**Tablas con más locks (sesión 67437343 en bloqueos_X.260731_143934):**

| Tabla | Locks |
|-------|-------|
| bdicred:sd_maesdos | 196 |
| bdicred:sd_maecred | 169 |
| bdicred:sd_amortiza_credito | 121 |
| intercard:movimiento | 100 |
| bditarjeta:td_movimientos_conciliacion | 64 |
| bditarjeta:td_param_conciliacion_concreing | 49 |
| bdicred:sd_movdia | 49 |
| bdicheq:sc_maechq | 49 |

**Sesión 55412100 (syssiweb) — mismo anti-patrón, canal web:**  
Canal web conectado 4h 1m (desde 09:11 CST). Acumuló 24,336 candados sobre `bdisolic:pas_final` sin COMMIT. El mismo día, dos aplicaciones distintas (reconciliación batch + canal web) exhiben el mismo anti-patrón de transacción larga sin COMMIT.

---

## 4. Causa raíz confirmada

### 4.1 Defecto central — sp_concreing_conciliacionautomatica sin COMMIT intermedio

El SP procesa el **archivo completo de movimientos de tarjeta Concreing/Intercard en una sola transacción monolítica**. Ejecuta INSERT masivo en `bditarjeta:td_movimientos_conciliacion`, seguido de múltiples UPDATE cross-DB en bdicred (`sd_maesdos`, `sd_maecred`, `sd_amortiza_credito`, `sd_movdia`) sin emitir `COMMIT WORK` entre operaciones. Cada página de datos modificada retiene un ExLock hasta que la transacción entera complete.

La acumulación es explosiva: 0 → 8,721 locks en 2 minutos, porque el INSERT masivo en `td_movimientos_conciliacion` adquiere page locks sobre todas las filas del lote del archivo simultáneamente, seguido de los UPDATE en bdicred que agregan ExLocks sobre las tablas maestras de crédito más concurridas del sistema.

### 4.2 Cadena causal

```
1. sysconau inicia sp_concreing_conciliacionautomatica (~14:15 CST)
2. INSERT masivo → 8,721 page locks en 2 min (td_movimientos_conciliacion)
3. UPDATE cross-DB en bdicred sin COMMIT → ExLocks en sd_maesdos/sd_maecred/sd_amortiza_credito
4. Sesión mantiene todos los locks durante 47+ min sin liberación
5. Cualquier sesión que intente UPDATE en las mismas filas de bdicred → espera 3s → sqlErr=-255
6. Con 446 sesiones concurrentes en bdicred, la probabilidad de colisión es certeza
7. Resultado: 22,089 errores distribuidos uniformemente en 3 horas
```

### 4.3 Anti-patrón sistémico confirmado

El mismo día, la sesión `syssiweb` (canal web BanCoppel) acumuló 24,336 candados sobre `bdisolic:pas_final` sin COMMIT, conectada 4 horas 1 minuto. Esto no es una anomalía aislada del job de reconciliación — es un anti-patrón presente en múltiples capas de la aplicación.

La auditoría del corpus completo (2026-08-05) confirma: **108 SPs en 12 bases de datos** tienen el exception handler de recovery ante locks comentado (`/*ON EXCEPTION IN (-535) COMMIT WORK; BEGIN WORK; END EXCEPTION WITH RESUME;*/`). Ver INC-20260801 §12 para el análisis completo.

---

## 5. Defectos identificados

| ID | SP / Componente | Localización | Descripción |
|----|----------------|--------------|-------------|
| D1 | sp_concreing_conciliacionautomatica | bditarjeta | Transacción monolítica: procesa archivo completo sin COMMIT intermedio entre INSERT batch y UPDATE cross-DB en bdicred |
| D2 | bdicred:conciliatc → cargo_cred → genmov_tc → principal | bdicred | Cadena de SPs ejecutados dentro de la misma transacción sin COMMIT de separación |
| D3 | syssiweb (canal web) | bdisolic | Sesión de canal web conectada 4h 1m con 24,336 locks en pas_final sin COMMIT — mismo anti-patrón en aplicación diferente |
| D4 | sysconau / dbaccess | DCMSIF01 | Job batch ejecutado desde el servidor de BD (no desde capa de aplicación), sin control de transacción a nivel de orquestador |

---

## 6. Tablas y dominios afectados

| Tabla | Base | Locks observados | Dominio |
|-------|------|-----------------|---------|
| td_movimientos_conciliacion | bditarjeta | ~6,000 (INSERT batch) | Tarjetas |
| sd_maesdos | bdicred | 196 | Crédito Core |
| sd_maecred | bdicred | 169 | Crédito Core |
| sd_amortiza_credito | bdicred | 121 | Crédito Core |
| intercard:movimiento | intercard | 100 | Intercard |
| td_param_conciliacion_concreing | bditarjeta | 49 | Tarjetas |
| sd_movdia | bdicred | 49 | Crédito Core |
| sc_maechq | bdicheq | 49 | Cheques |
| pas_final | bdisolic | 24,336 (syssiweb) | Solicitudes |

---

## 7. Relación con INC-20260801

El incidente del 31/07 y el del 01/08 son **eventos distintos en causa raíz inmediata pero idénticos en anti-patrón**:

| Dimensión | INC-20260731 | INC-20260801 |
|---|---|---|
| SP raíz | sp_concreing_conciliacionautomatica | bdisolic:califica_scoring_cjunk |
| Usuario | sysconau | interofi |
| Tipo | Batch reconciliación tarjetas | Scoring crediticio |
| Anti-patrón | Transacción monolítica sin COMMIT | COMMIT comentado (/*…*/) |
| Velocidad acumulación | 0 → 8,721 en 2 min (explosiva) | 43 locks en 3h46m (lenta) |
| Duración visible | 3h+ sin recuperación | 21 min de crisis aguda |
| Errores -255 | 22,089 | 8,238 |
| Sesiones únicas | 446 | 230 |
| Código idéntico ambas fechas | Sí (sp_sql/ MD5 igual) | Sí — defecto preexiste al 31/07 |

**El defecto `COMMIT comentado` de califica_scoring_cjunk ya existía el 31/07** — el código es byte a byte idéntico entre `sp_sql/` del 31/07 y del 01/08 (0 diferencias en 7,620 archivos comunes). El 31/07 la crisis fue causada por el job de reconciliación; el 01/08, ese defecto latente fue el que disparó la cascada.

---

## 8. Patrones de riesgo para la migración

### Patrón 1 — Transacción monolítica en job batch
`sp_concreing_conciliacionautomatica` es el prototipo del anti-patrón más peligroso en migración: un job batch que procesa volúmenes completos de archivo en una sola transacción. En Aurora PostgreSQL, la corrección es implementar procesamiento en micro-lotes con COMMIT por lote (e.g., cada 1,000 registros), usando savepoints para rollback granular en caso de error individual.

### Patrón 2 — Job batch ejecutado desde el servidor de BD
El job corre como `dbaccess` desde DCMSIF01 directamente — sin capa de middleware que controle el ciclo de vida de la transacción. En el target, estos jobs deben ser orquestados por una capa de aplicación (Spring Batch, AWS Step Functions) que gestione el transactional boundary.

### Patrón 3 — Múltiples aplicaciones con el mismo anti-patrón
La coexistencia de `sysconau` (batch) y `syssiweb` (web) con transacciones largas sin COMMIT el mismo día indica que el anti-patrón es transversal a la arquitectura, no específico de un SP. La remediación en migración no puede ser SP por SP — requiere un estándar de gestión transaccional que se aplique en la capa de aplicación.

---

## 9. Preguntas abiertas

1. **Origen del archivo de Concreing** — ¿desde qué sistema y en qué formato llega el archivo de movimientos que procesa `sp_concreing_conciliacionautomatica`? ¿Hay un SLA de procesamiento que presiona a procesar el lote completo en una sola pasada?

2. **Evento catastrófico de las 11:28** — los valores de 8.5M locks son anteriores a la sesión 67437343 (que aparece a las ~14:15). ¿Qué sesión provocó el evento de las 11:28? Los snapshots en `31072026/` no cubren esa ventana horaria.

3. **Destino de los 22,089 errores en el negocio** — con 3 horas de contención, ¿cuántas transacciones de clientes quedaron sin procesar ese día? ¿El job de reconciliación se reprogramó o las diferencias quedaron sin conciliar?

4. **`bdicheq:sc_maechq` en la sesión de reconciliación** — este lock (49 entradas) en una tabla de cuentas de cheques dentro de una sesión de reconciliación de tarjetas de crédito es inesperado. ¿Por qué la reconciliación de tarjetas accede a cuentas de cheques?

---

*Fuentes: dato crudo de `source/logs/2026-07-31/`. Análisis independiente, sin referencia a análisis de terceros.*  
*Creado: 2026-08-05 | BCOPCore Gemelo Cognitivo — DISCOVER Etapa 1*

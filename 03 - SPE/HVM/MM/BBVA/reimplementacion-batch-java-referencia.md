# Reimplementación de Batch de Alto Volumen en Java — Arquitectura de Referencia
> Cómo se reimplementa un proceso batch masivo de mainframe (COBOL/JCL) en tecnologías Java **sin caer en el anti-patrón de microservicios chatty** ni en la degradación 1:10.
> Companion de [analisis-desempeno-mainframe-a-java.md](analisis-desempeno-mainframe-a-java.md). Contexto: bloque de contabilidad BBVA (Altamira → Java).

---

## Principio Rector

> **Se preserva el _modelo de ejecución_, no el _código_.** El COBOL batch es: lectura secuencial en streaming + procesamiento en memoria de asignación fija + escritura masiva + co-localización con los datos + checkpoint para reinicio. La reimplementación Java debe replicar **ese modelo**, no traducir línea por línea. La granularidad de distribución es la **partición** (miles de registros), nunca el **registro individual**.

Regla de oro que separa el éxito del fracaso:

| ✅ Correcto | ❌ Anti-patrón (el error de Kyndryl) |
|------------|--------------------------------------|
| Batch cohesivo que hace stream-chunk-bulk localmente | Descomponer el batch en microservicios que se llaman por REST |
| Distribuir por partición (branch, rango de cuenta) | Distribuir por registro (una llamada de red por asiento) |
| Escritura masiva (`executeBatch`, `COPY`) | INSERT fila por fila |
| Catálogos en memoria cargados una vez | Query a BD por cada lookup |
| `BigDecimal` con escala/rounding fijos | `double`, o `BigDecimal` sin control de escala |

---

## El Modelo Mental: Stream → Chunk → Bulk → Local

```
COBOL/JCL (AS-IS)                    Java Batch (TO-BE, correcto)
─────────────────                    ───────────────────────────
OPEN INPUT archivo          ──►      ItemReader (cursor/stream, fetchSize alto)
PERFORM UNTIL fin                    
  READ archivo              ──►        read()  → 1 item
  (working-storage tables)  ──►        lookup en HashMap en memoria (cargado 1 vez)
  compute (COMP-3)          ──►        process() → BigDecimal
  WRITE salida              ──►        buffer en chunk (N items)
  cada N: CHKPT             ──►        commit del chunk (commit-interval = N)
END-PERFORM                          ItemWriter → executeBatch() (bulk)
CLOSE                                JobRepository persiste el último chunk (restart)
```

El COBOL nunca cargó todo el archivo en memoria ni hizo I/O por registro contra una BD remota. La versión Java tampoco debe.

---

## Stack de Referencia

### Framework de batch

| Opción | Cuándo usarla | Nota BBVA |
|--------|---------------|-----------|
| **Spring Batch (5.x / Spring Boot 3)** | Default de industria. Modelo chunk-oriented, restart, partitioning, tolerancia a fallos, listeners. | Recomendado para batch cloud-native standalone. |
| **Jakarta Batch (JSR-352 / JBeret)** | Estándar Jakarta EE, mismo modelo chunk (reader/processor/writer). | **Encaja en el runtime Java EE que APX ya usa** — puede ser el fit natural dentro del stack existente BBVA. |
| **Java puro + librerías** | Control extremo, latencia mínima. | Solo si el framework estorba; raro. |
| **Apache Spark** | Batch analítico/agregación masiva (no transaccional). | Overkill y riesgoso semánticamente para un ledger contable. Reservar para el workload correcto. |

> **Decisión clave para BBVA:** el batch de contabilidad debería correr en un **tier de batch dedicado y separado del tier online transaccional de APX**. Meter batch de alto volumen dentro de una plataforma de servicios request/response (APX) es parte de lo que degrada el desempeño (causa G-1). Puede seguir siendo Java, incluso Jakarta Batch sobre el mismo runtime, pero como aplicación batch aislada, no como servicio online.

### Acceso a datos

- **JDBC plano / jOOQ / MyBatis** para el camino de datos batch. **NO ORM (Hibernate/JPA)** en el hot path — el ORM introduce N+1, lazy loading y dirty-checking (causa F-1).
- **Bulk writers**: `JdbcBatchItemWriter` (usa `addBatch`/`executeBatch`), o `COPY` de Postgres vía `CopyManager` para cargas masivas.

### Decodificación de formato mainframe

- **JRecord / Cobrix** para leer copybooks COBOL con COMP-3, zoned decimal, EBCDIC, OCCURS, REDEFINES. Se decodifica **una vez en la capa de ingesta** a tipos Java nativos (resuelve A-2, A-3, P-01, T-03).

---

## Anatomía de un Batch de Alto Volumen

### 1. Reader — Streaming, nunca "cargar todo"

- **Desde BD**: `JdbcCursorItemReader` (cursor server-side, un barrido secuencial) o `JdbcPagingItemReader` (paginado, compatible con partitioning). Fijar `fetchSize` alto (p.ej. 1000–10000) para replicar el blocking factor del mainframe (resuelve B-2).
- **Desde archivo**: `FlatFileItemReader` (ancho fijo/delimitado) o reader custom con copybook (JRecord) para datos COMP-3.
- **Regla:** nunca `SELECT *` a un `List` de millones de filas. Siempre stream.

### 2. Processor — Lógica de negocio, lookups en memoria

- Catálogos y tablas paramétricas se cargan **una sola vez** al inicio del step (en `@BeforeStep` / `StepExecutionListener.beforeStep()`) a un `HashMap`. Elimina el N+1 de lookups (resuelve B-3).
- Dinero siempre en `BigDecimal` con escala y `RoundingMode` **idénticos al COBOL** (resuelve A-1, A-4).
- Evitar object churn: reutilizar buffers, evitar autoboxing en el loop caliente (resuelve E-1, E-3).
- Lo que sea agregación/filtro de conjunto: empujarlo a SQL (set-based), no hacerlo item por item (resuelve I-1, I-2).

### 3. Writer — Escritura masiva

- `JdbcBatchItemWriter` acumula y ejecuta en lote (`executeBatch`). El tamaño del lote = el commit-interval del chunk (resuelve B-1, F-3).
- Para volúmenes extremos: `COPY` (Postgres) o bulk load nativo del motor.
- **Nunca** un INSERT/UPDATE por registro.

### 4. Chunk + Commit

- `.chunk(N)` procesa N items en una transacción y hace **un** commit. N típico: 1000–10000, calibrado por benchmark. Reemplaza el commit-por-registro (resuelve D-1).

---

## Escalamiento Sin Romper la Semántica Contable

El orden de aplicación de asientos es **semántica**, no detalle. El paralelismo debe respetarlo. Modelos de Spring Batch, de menor a mayor complejidad:

| Modelo | Cómo escala | Preserva orden | Uso para ledger |
|--------|-------------|----------------|-----------------|
| **Single-threaded chunk** | Un hilo, secuencial | ✅ Perfecto | Baseline seguro |
| **Multi-threaded step** | Varios hilos sobre el mismo step | ❌ Rompe orden | ⛔ Peligroso para contabilidad |
| **Partitioning** ⭐ | Divide en particiones **independientes** (por sucursal, rango de cuenta, producto); orden preservado **dentro** de cada partición | ✅ Dentro de partición | ✅ **El patrón correcto** |
| **Remote partitioning** | Distribuye particiones a nodos worker vía cola de mensajes; cada worker procesa su partición end-to-end local | ✅ Dentro de partición | ✅ Para volumen que no cabe en un nodo |

> **La distinción clave con el anti-patrón chatty:** en remote partitioning la unidad de distribución es la **partición** (miles de registros procesados localmente por el worker), **no el registro** (que sería una llamada de red por asiento). Es distribución **coarse-grained**, no fine-grained. Así se obtiene paralelismo sin la degradación de G-1.

Criterio de particionamiento para contabilidad: por dimensión donde los asientos son **independientes entre sí** (típicamente por cuenta o por sucursal). Si hay dependencia de orden global, esa dimensión no se puede particionar — se procesa secuencial.

---

## SORT / JOINKEYS

No reimplementar DFSORT ingenuamente (causa C-1, C-2):

| Necesidad mainframe | Reimplementación Java |
|---------------------|----------------------|
| SORT de dataset grande | Push-down: `ORDER BY` en la BD (el motor está optimizado), o external merge-sort para archivos |
| JOINKEYS (merge-join) | Merge-join sobre dos streams **pre-ordenados**, o hash-join cargando el lado pequeño en `HashMap`. Nunca nested-loop O(n²) |
| SORT con INREC/OUTREC/SUM | Una sola pasada: hacer filtro+transformación+agregación en el `ORDER BY`/`GROUP BY` de la query, no en múltiples barridos Java |
| Ordenamiento implícito previo al match | Documentar y replicar el sort key exacto del JCL antes del join (resuelve C-4) |

---

## Orquestación — Reemplazo del JCL

El grafo de dependencias del JCL (JOB → STEPs encadenados) se mapea a:

| Opción | Cuándo |
|--------|--------|
| **Spring Batch job flow** (step→step, flujos condicionales) | Orquestación intra-job simple |
| **Control-M / Autosys** | Bancos ya los tienen; migración natural del scheduling de JCL |
| **AWS Step Functions / Argo Workflows / Airflow** | Orquestación cloud-native de DAGs de jobs |

Cada `EXEC PGM` del JCL → un Step o un Job; las condiciones `COND`/`IF` del JCL → transiciones condicionales del flujo.

---

## Restart / Checkpoint

- El **JobRepository** de Spring Batch persiste el estado de ejecución (último chunk commiteado). Ante un fallo, el job reinicia **desde el punto de fallo**, no desde cero. Es el análogo directo del CHKPT/restart del mainframe (resuelve D-5).
- Configurar políticas de skip/retry (`.faultTolerant()`) para registros individuales problemáticos sin abortar todo el batch.

---

## Tabla de Mapeo — COBOL/JCL → Java

| Construcción mainframe | Equivalente Java | Causa que resuelve |
|------------------------|------------------|--------------------|
| JCL JOB | Spring Batch `Job` / DAG de scheduler | — |
| JCL STEP (`EXEC PGM`) | `Step` | — |
| `OPEN`/`READ` secuencial | `ItemReader` (cursor/stream, fetchSize alto) | B-2 |
| Tablas en `WORKING-STORAGE` | `HashMap` en memoria cargado en `@BeforeStep` | B-3 |
| `PERFORM UNTIL` loop | Chunk read-process-write | B-1 |
| Aritmética `COMP-3` | `BigDecimal` (escala/rounding fijos) | A-1, A-4 |
| `WRITE` a archivo/BD | `JdbcBatchItemWriter` (bulk) / `COPY` | B-1, F-3 |
| `CHKPT` / restart | `JobRepository` (restart desde último chunk) | D-1, D-5 |
| `SORT` / `JOINKEYS` | `ORDER BY`/merge-join en BD, o merge-sort | C-1, C-2 |
| Jobs paralelos (initiators) | Partitioning / remote partitioning | D-3, G-1 |
| Campos `COMP-3` / EBCDIC | Decodificación en ingesta (JRecord/Cobrix) | A-2, A-3, P-01 |
| `REDEFINES` | Union/tagged-type o BitBuffer | T-03 |
| `LOW-VALUES`/`HIGH-VALUES` | Constantes `byte` 0x00/0xFF explícitas | T-06 |

---

## Esqueleto de Código (Spring Batch 5, ilustrativo)

```java
// ── STEP: chunk-oriented, commit cada 5000 ──────────────────────────────
@Bean
public Step postingStep(JobRepository jobRepository,
                        PlatformTransactionManager txManager,
                        ItemReader<AsientoRaw> reader,
                        ItemProcessor<AsientoRaw, AsientoPosted> processor,
                        ItemWriter<AsientoPosted> writer) {
    return new StepBuilder("postingStep", jobRepository)
        .<AsientoRaw, AsientoPosted>chunk(5000, txManager)   // ← commit por chunk, no por registro
        .reader(reader)
        .processor(processor)
        .writer(writer)
        .faultTolerant().skipLimit(100).skip(AsientoInvalidoException.class)
        .build();
}

// ── READER: cursor server-side, streaming, ordenado ─────────────────────
@Bean
@StepScope
public JdbcCursorItemReader<AsientoRaw> reader(DataSource ds) {
    return new JdbcCursorItemReaderBuilder<AsientoRaw>()
        .name("asientoReader")
        .dataSource(ds)
        .sql("SELECT cuenta, secuencia, monto, tipo " +
             "FROM asientos_pendientes ORDER BY cuenta, secuencia")  // ← orden determinista
        .fetchSize(5000)                                             // ← blocking factor
        .rowMapper(new AsientoRowMapper())
        .build();
}

// ── PROCESSOR: catálogo en memoria (1 sola carga) + BigDecimal ──────────
public class PostingProcessor implements ItemProcessor<AsientoRaw, AsientoPosted> {
    private Map<String, Cuenta> catalogo;   // cargado una vez, no query por registro

    @BeforeStep
    public void cargarReferencia(StepExecution se) {
        this.catalogo = cuentaRepo.cargarTodoEnMapa();     // ← una query, no N+1
    }

    @Override
    public AsientoPosted process(AsientoRaw raw) {
        Cuenta c = catalogo.get(raw.getCuenta());          // ← lookup en memoria
        BigDecimal nuevoSaldo = c.getSaldo()
            .add(raw.getMonto())
            .setScale(2, RoundingMode.HALF_UP);            // ← escala/rounding idénticos al COBOL
        return new AsientoPosted(raw, nuevoSaldo);
    }
}

// ── WRITER: escritura masiva (executeBatch) ─────────────────────────────
@Bean
public JdbcBatchItemWriter<AsientoPosted> writer(DataSource ds) {
    return new JdbcBatchItemWriterBuilder<AsientoPosted>()
        .dataSource(ds)
        .sql("INSERT INTO libro_mayor (cuenta, secuencia, monto, saldo) " +
             "VALUES (:cuenta, :secuencia, :monto, :saldo)")
        .beanMapped()
        .build();                                          // ← addBatch/executeBatch, no fila por fila
}

// ── PARALELISMO: partitioning por rango de cuenta (orden preservado por partición) ──
@Bean
public Step masterStep(JobRepository jobRepository, Step postingStep,
                       TaskExecutor taskExecutor) {
    return new StepBuilder("masterStep", jobRepository)
        .partitioner("postingStep", new RangePartitioner("cuenta"))  // ← partición independiente
        .step(postingStep)
        .gridSize(8)
        .taskExecutor(taskExecutor)
        .build();
}
```

Los cinco puntos que este esqueleto hace bien y que el anti-patrón hace mal: **(1)** commit por chunk, **(2)** reader en streaming ordenado, **(3)** catálogo en memoria una vez, **(4)** writer masivo, **(5)** paralelismo por partición (no por registro).

---

## Arquitectura de Despliegue

```
┌──────────────────────────────────────────────────────────────┐
│  TIER ONLINE (APX / microservicios)                          │
│  Request/response · REST · baja latencia · consultas          │
│  ── NO es donde vive el batch de alto volumen ──             │
└──────────────────────────────────────────────────────────────┘
                    │ (comparten datos, no request path)
┌──────────────────────────────────────────────────────────────┐
│  TIER BATCH (dedicado, aislado)                              │
│  Spring/Jakarta Batch · chunk-oriented · partitioning         │
│  Co-localizado con su BD (misma VPC/AZ, réplica local)        │
│  Contenedor right-sized o nodo dedicado para la ventana batch │
│  Orquestado por Control-M / Step Functions / Argo             │
└──────────────────────────────────────────────────────────────┘
                    │
┌──────────────────────────────────────────────────────────────┐
│  DATOS: Postgres/Aurora · índices correctos · bulk load       │
│  Co-localizado con el tier batch (minimizar round-trips)      │
└──────────────────────────────────────────────────────────────┘
```

Consideraciones de infra: contenedores right-sized (evitar CPU throttling de K8s — H-3), GraalVM native image para batches cortos que no calientan el JIT (E-2), GC tuning (G1/ZGC) para el object churn (E-1).

---

## Anti-Patrones a Evitar (Recap)

1. ⛔ Descomponer el batch en microservicios que se llaman por REST (G-1)
2. ⛔ Distribuir por registro en vez de por partición
3. ⛔ INSERT/UPDATE fila por fila (B-1, F-3)
4. ⛔ Query a BD por cada lookup de catálogo (B-3)
5. ⛔ ORM en el hot path del batch (F-1)
6. ⛔ Commit por registro (D-1)
7. ⛔ `double` para dinero, o `BigDecimal` sin escala fija (A-4)
8. ⛔ Cargar millones de filas a un `List` en memoria (usar streaming)
9. ⛔ Multi-threaded step donde el orden importa (romper C-4)
10. ⛔ Correr el batch dentro del tier online transaccional

---

## Aplicación a BBVA — Bloque de Contabilidad

1. **Runtime:** Jakarta Batch sobre el runtime Java EE existente (fit con APX) **o** Spring Batch standalone — pero en un **tier de batch dedicado, no dentro de los servicios online de APX.**
2. **Reader:** cursor ordenado por (cuenta, secuencia) para preservar el orden de asientos.
3. **Processor:** catálogo de cuentas en memoria; `BigDecimal` con escala idéntica al COBOL de Altamira.
4. **Writer:** bulk insert al libro mayor.
5. **Paralelismo:** partitioning por rango de cuenta/sucursal (asientos independientes); secuencial donde haya dependencia de orden global.
6. **Ingesta:** decodificar COMP-3/EBCDIC de los archivos de Altamira una sola vez a tipos Java.
7. **Gate:** equivalencia contable ≥ 99.99% registro-a-registro contra la salida de Altamira antes de cualquier cutover.

---

*Última actualización: 2026-07-07 · v1.0 · Arquitectura de referencia de batch de alto volumen en Java. Companion del análisis de desempeño.*
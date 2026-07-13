# Análisis de Desempeño — Migración Mainframe (COBOL/z-OS) → Código Abierto (Java)
> Catálogo de causas de degradación de desempeño + alternativas de solución.
> Contexto: BBVA México — bloque de contabilidad Altamira → APX. Diagnóstico del fallo del incumbente (Kyndryl) y roadmap de remediación Accenture.
> Este documento respalda el **Performance Diagnosis Assessment** como oferta de entrada.

---

## Tesis Central

> **El problema de desempeño casi nunca es "Java es lento". El problema es que se traduce el _código_ pero no se re-ingeniería el _modelo de ejecución_.** Un mainframe z/OS no es solo un lenguaje (COBOL): es una máquina diseñada durante 50 años para throughput de batch — I/O secuencial de altísimo ancho de banda, aritmética decimal por hardware, motores de SORT en assembler, y co-localización de cómputo y datos. Cuando se migra COBOL a Java con traducción literal 1:1, se pierde todo eso y aparece la degradación 1:10 observada en BBVA.

La buena noticia: **cada causa tiene un patrón de remediación conocido.** La mala para Kyndryl: hay que conocer cómo funcionaba el sistema original (Altamira) para saber qué re-ingeniar. Accenture lo construyó.

---

## PARTE 1 — Taxonomía Completa de Causas de Degradación

Nueve categorías. Cada causa incluye: **mecanismo**, **por qué aparece**, **síntoma observable**, **severidad típica**.

---

### A. Aritmética y Representación de Datos

| # | Causa | Mecanismo | Síntoma | Severidad |
|---|-------|-----------|---------|-----------|
| A-1 | **Packed decimal por software** | z/Architecture ejecuta aritmética decimal (`COMP-3`, zoned) con **instrucciones de hardware** (decimal arithmetic, DFP). Java `BigDecimal` es 100% software: cada suma/multiplicación es un método con allocation de objeto. | En batch contable con millones de asientos, la aritmética domina la CPU. Latencia lineal con el volumen. | 🔴 Alta |
| A-2 | **Decodificación EBCDIC ↔ ASCII/UTF** | El mainframe almacena en EBCDIC. Cada lectura/escritura de campo requiere transcodificación si el pipeline Java trabaja en UTF-8. | Overhead por campo, por registro. Invisible individualmente, masivo en agregado. | 🟠 Media |
| A-3 | **Conversión de binario/COMP y endianness** | Campos `COMP`/`COMP-4` son binarios big-endian del mainframe; x86/JVM manejan su propia representación. Conversión por campo. | CPU extra en parsing de cada registro. | 🟠 Media |
| A-4 | **Uso incorrecto de `double` en vez de `BigDecimal`** | Si el agente/dev traduce packed decimal a `double` (rápido pero impreciso), gana velocidad pero **rompe la equivalencia contable** por rounding. La "solución" a A-1 introduce error financiero. | Rápido pero incorrecto — descuadres de centavos que el regulador no perdona. | 🔴 Alta (correctitud) |

---

### B. Modelo de I/O — **La Causa #1**

| # | Causa | Mecanismo | Síntoma | Severidad |
|---|-------|-----------|---------|-----------|
| B-1 | **Anti-patrón N+1 (file secuencial → query por registro)** | El COBOL lee un dataset secuencial (QSAM/VSAM) de millones de registros en un solo barrido a velocidad de canal. La traducción ingenua hace **un `SELECT` por registro** contra la base de datos. | **Degradación de 10× a 100×.** Es la explicación más probable del caso Kyndryl. | 🔴🔴 Crítica |
| B-2 | **Pérdida de blocking factor / buffering** | El mainframe lee bloques grandes (BLKSIZE, BUFNO alto) — pocas operaciones de I/O físicas para muchos registros lógicos. Java con `BufferedReader` de tamaño default hace muchas más operaciones de I/O. | I/O-bound donde el original era CPU-bound. | 🟠 Media |
| B-3 | **Tablas de referencia recargadas** | COBOL carga catálogos/tablas paramétricas en `WORKING-STORAGE` **una vez** al inicio y hace lookups en memoria. Java las consulta a BD **en cada iteración**. | Multiplica queries por volumen × #lookups. Variante de N+1. | 🔴 Alta |
| B-4 | **Random access VSAM KSDS → SQL** | Acceso por clave en VSAM (índice B-tree en el mismo LPAR) reemplazado por SQL sobre red. El access path cambia radicalmente. | Latencia de red por cada acceso a registro. | 🟠 Media-Alta |
| B-5 | **Pérdida de data locality** | DB2 vivía en el mismo LPAR que el batch COBOL — acceso vía cross-memory services (microsegundos, sin red). En arquitectura distribuida (APX), cada acceso a datos es un round-trip de red. | Latencia de red × número de accesos. Devastador con N+1. | 🔴 Alta |

---

### C. Utilerías de SORT / Merge (DFSORT, SyncSort, ICETOOL)

| # | Causa | Mecanismo | Síntoma | Severidad |
|---|-------|-----------|---------|-----------|
| C-1 | **DFSORT/SyncSort reemplazado por sort genérico** | Estos son motores de ordenamiento en assembler, optimizados 40+ años, con hardware sort assist y uso masivo de memoria. `Collections.sort()` o `ORDER BY` genérico no se acercan en volumen grande. | Ordenamientos que tardaban minutos ahora tardan horas. | 🔴 Alta |
| C-2 | **JOINKEYS (merge-join sobre datos pre-ordenados)** | El SORT hace merge-join en una sola pasada sobre archivos ya ordenados. La reimplementación como nested-loop join en Java es O(n²) donde el original era O(n). | Explosión de tiempo en matches entre archivos grandes. | 🔴 Alta |
| C-3 | **Transformación en una sola pasada (INREC/OUTREC/SUM FIELDS)** | El SORT del mainframe filtra, transforma y agrega **durante** el ordenamiento en un solo paso. La versión Java suele hacer múltiples pasadas separadas. | Múltiples barridos de datos donde había uno. | 🟠 Media |
| C-4 | **Ordenamiento implícito no replicado** | El match de archivos depende de un orden previo que la utilería garantiza implícitamente. Si Java no replica ese sort, el resultado del join es **incorrecto** (no solo lento). | Resultados divergentes + retrabajos. | 🔴 Alta (correctitud) |

---

### D. Modelo de Procesamiento Batch

| # | Causa | Mecanismo | Síntoma | Severidad |
|---|-------|-----------|---------|-----------|
| D-1 | **Commit por registro en vez de por chunk** | Batch mainframe usa checkpoint/restart (CHKPT) eficiente con commits espaciados. Java con transacción por registro paga overhead de commit millones de veces. | Cada commit es un fsync + log write. Domina el tiempo. | 🔴 Alta |
| D-2 | **Overhead transaccional JEE/JTA** | Contenedor Java EE con transacciones gestionadas, JTA, y peor aún XA/two-phase-commit, agrega latencia por unidad de trabajo. | Overhead constante por transacción. | 🟠 Media-Alta |
| D-3 | **Pérdida del paralelismo de jobs** | El mainframe corre múltiples jobs batch en paralelo orquestados por el scheduler (initiators). Java single-threaded no aprovecha; o mal paralelizado genera contención. | Subutilización de CPU o deadlocks. | 🟠 Media |
| D-4 | **Contención del connection pool** | Si el batch se paraleliza sin dimensionar el pool JDBC, los hilos compiten por conexiones → esperas y a veces deadlocks en el motor de BD. | Threads bloqueados esperando conexión. | 🟠 Media |
| D-5 | **Restart-ability perdida** | Sin checkpoint equivalente, un fallo a mitad del batch obliga a reprocesar todo — no es degradación de velocidad pura, pero infla el tiempo efectivo de la ventana. | Ventana batch no cierra ante cualquier incidente. | 🟠 Media |

---

### E. Runtime JVM / Garbage Collection

| # | Causa | Mecanismo | Síntoma | Severidad |
|---|-------|-----------|---------|-----------|
| E-1 | **Object churn → presión de GC** | COBOL usa `WORKING-STORAGE` estático: **cero allocation** en el loop. Java crea un grafo de objetos por registro (record → POJO → campos). Millones de registros = millones de objetos = GC constante. | Pausas de GC, CPU gastada en recolección, no en negocio. | 🔴 Alta |
| E-2 | **JIT cold / sin warmup** | Un batch que corre una vez no calienta el JIT: gran parte se ejecuta interpretado o con compilación tardía. El mainframe COBOL es código nativo compilado desde el inicio. | Primeras (y a veces todas las) ejecuciones lentas. | 🟠 Media |
| E-3 | **Autoboxing en loops calientes** | `Integer`/`Long`/`BigDecimal` boxing crea objetos en el hot path. | Amplifica E-1. | 🟠 Media |
| E-4 | **Inmutabilidad de String + parsing** | Crear un `String` por campo (inmutable) genera basura y copia. INSPECT/STRING/UNSTRING traducidos ingenuamente empeoran esto. | Allocation + CPU de parsing. | 🟠 Media |
| E-5 | **Overhead de frameworks (Spring/ORM/DI)** | Reflection, proxies, interceptores y dirty-checking de ORM en el camino de datos. | Latencia por invocación, multiplicada por volumen. | 🟠 Media-Alta |

---

### F. Capa de Base de Datos (si VSAM → RDBMS)

| # | Causa | Mecanismo | Síntoma | Severidad |
|---|-------|-----------|---------|-----------|
| F-1 | **ORM (Hibernate/JPA) en batch** | Lazy loading, gestión de sesión, dirty checking y N+1 automático del ORM. No diseñado para batch de alto volumen. | N+1 encubierto, memoria de sesión, lentitud. | 🔴 Alta |
| F-2 | **Impedance mismatch relacional** | El registro plano COBOL (con OCCURS, REDEFINES) no mapea 1:1 a tablas normalizadas. Joins nuevos donde antes había un solo registro. | Joins costosos inexistentes en el original. | 🟠 Media-Alta |
| F-3 | **Sin operaciones bulk** | INSERT/UPDATE fila por fila en vez de JDBC batch / bulk load / COPY. | Round-trips a BD por registro. | 🔴 Alta |
| F-4 | **Índices ausentes o equivocados** | El access path VSAM no se tradujo a los índices correctos. | Full scans, lentitud. | 🟠 Media |
| F-5 | **Lock escalation / row locking** | El RDBMS escala locks bajo carga batch; contención donde VSAM tenía otro modelo de concurrencia. | Esperas, deadlocks. | 🟠 Media |

---

### G. Distribución y Arquitectura (APX / Microservicios) — **Sospechoso Principal en APX**

| # | Causa | Mecanismo | Síntoma | Severidad |
|---|-------|-----------|---------|-----------|
| G-1 | **Monolito batch → llamadas distribuidas ("chatty")** | Si un programa COBOL único se descompuso en microservicios que se llaman entre sí, cada interacción intra-programa se vuelve un round-trip HTTP. Un loop que hacía millones de PERFORM internos ahora hace millones de llamadas de red. | **Degradación catastrófica** — cada PERFORM ≈ una llamada REST. | 🔴🔴 Crítica |
| G-2 | **Overhead de REST/JSON** | Serializar/deserializar JSON millones de veces; parsing y allocation constantes. | CPU y GC en serialización, no en negocio. | 🔴 Alta |
| G-3 | **Llamadas síncronas bloqueantes** | Cadenas de servicios síncronos donde cada uno espera al siguiente. Latencias se suman. | Latencia acumulada por hop. | 🟠 Media-Alta |
| G-4 | **Hops de middleware** | API Gateway + service mesh + load balancer + auth por llamada. Cada hop agrega latencia fija. | Latencia constante × número de llamadas. | 🟠 Media |

> **Nota BBVA/APX:** APX es una plataforma de backend transaccional distribuida. Si el bloque de contabilidad de Altamira (batch masivo, secuencial, monolítico por diseño) se forzó al modelo transaccional/distribuido de APX sin re-ingeniar el batch, **G-1 + B-1 juntos explican por sí solos una degradación 1:10 o peor.** Esta es la hipótesis de causa raíz de mayor probabilidad.

---

### H. Infraestructura y Hardware

| # | Causa | Mecanismo | Síntoma | Severidad |
|---|-------|-----------|---------|-----------|
| H-1 | **Throughput single-thread y ancho de banda de I/O de z** | Los canales de I/O, PAV (Parallel Access Volumes) y el subsistema DASD del mainframe tienen ancho de banda difícil de igualar en commodity/cloud. | I/O-bound en la plataforma nueva. | 🟠 Media |
| H-2 | **Latencia de almacenamiento cloud** | EBS/S3/almacenamiento de red vs. DASD local del mainframe. | Latencia por acceso. | 🟠 Media |
| H-3 | **Contenedores mal dimensionados** | Límites de CPU/memoria en pods OpenShift que estrangulan el batch; CPU throttling de Kubernetes. | Batch estrangulado artificialmente. | 🟠 Media |
| H-4 | **Noisy neighbor** | Otros workloads en el mismo nodo compiten por recursos. | Variabilidad de desempeño. | 🟢 Baja-Media |

---

### I. Traducción Algorítmica / Semántica

| # | Causa | Mecanismo | Síntoma | Severidad |
|---|-------|-----------|---------|-----------|
| I-1 | **Traducción literal fila-por-fila** | El agente/dev preserva la lógica procedimental registro-a-registro del COBOL en vez de usar operaciones de conjunto (set-based) donde el motor de datos lo haría eficientemente. | Se hereda el peor patrón posible. | 🔴 Alta |
| I-2 | **No usar SQL set-based** | Agregaciones/filtros que el RDBMS haría en una sentencia se hacen en loops Java. | Datos viajan a Java para lo que la BD haría en sitio. | 🟠 Media-Alta |
| I-3 | **Recálculo redundante / sin cache** | No se memoiza lo que el COBOL calculaba una vez. | CPU repetida. | 🟠 Media |
| I-4 | **Estructuras de datos equivocadas** | `ArrayList` con búsqueda lineal donde se necesita `HashMap`; O(n²) oculto. | Escala mal con volumen. | 🟠 Media |

---

## Matriz de Diagnóstico Rápido (Síntoma → Causa Probable)

| Síntoma observado | Causas candidatas (orden de probabilidad) |
|-------------------|-------------------------------------------|
| Degradación proporcional al volumen (10×, 100×) | B-1, B-3, G-1, F-1, F-3 |
| CPU al 100% sin I/O alto | A-1, E-1, G-2, I-1 |
| Muchas conexiones/queries a BD | B-1, B-3, F-1, F-3 |
| Mucho tráfico de red interno | G-1, G-2, B-5 |
| Pausas periódicas / GC alto | E-1, E-3, E-4 |
| Resultados **incorrectos** (no solo lentos) | A-4, C-4, C-2 |
| Lento solo en la primera corrida | E-2 |
| Ordenamientos/joins muy lentos | C-1, C-2, C-3 |
| Deadlocks / esperas | D-4, F-5 |

**Instrumentación mínima del assessment:** profiler de JVM (async-profiler / JFR), conteo de queries a BD (p.ej. datasource proxy), trazas distribuidas (si APX es microservicios), métricas de GC, y comparación de plan de I/O contra el JCL/COBOL original.

---

## PARTE 2 — Alternativas: Cómo Lograrlo para un Banco como BBVA

Dos niveles de decisión: **(1) estrategia de migración** (qué tan lejos del mainframe) y **(2) patrones técnicos** (cómo hacerlo rápido y correcto).

---

### 2.1 — Alternativas Estratégicas (las "R" de modernización)

Ordenadas de **menor a mayor riesgo de desempeño/regresión**:

| Estrategia | Qué es | Desempeño esperado | Riesgo regulatorio | Aplicabilidad a BBVA |
|-----------|--------|--------------------|--------------------|----------------------|
| **1. Replatform / Rehost** (recompilar COBOL fuera del mainframe) | Micro Focus / OpenText Enterprise Server, AWS Mainframe Modernization (Micro Focus engine), Heirloom (COBOL→bytecode JVM), LzLabs. El COBOL sigue siendo COBOL, corre en x86/cloud. | **Cercano al mainframe** — preserva el modelo de I/O y batch. Heirloom reclama paridad. | Bajo — la lógica no cambia, equivalencia casi por construcción. | **Puente ideal para el ledger.** Sale del MIPS sin reescribir. Menor time-to-value. |
| **2. Refactor automatizado bien hecho** (COBOL→Java re-ingeniado) | AWS Blu Age, TSRI JANUS, IBM watsonx Code Assistant for Z, transpilers + agentes **con re-ingeniería del modelo de ejecución**. | **Bueno si se re-ingeniería** (chunk, bulk, set-based); **catastrófico si es literal 1:1** (el error de Kyndryl). | Medio — requiere equivalencia rigurosa. | Ruta objetivo cloud-native. Es lo que se intenta; debe hacerse con los patrones de §2.2. |
| **3. Rearchitect / Rewrite** (rediseño cloud-native) | Reescritura a microservicios/event-driven, posible ledger moderno (event sourcing / CQRS). | Excelente si se diseña bien; alto riesgo si se descompone mal el batch (G-1). | Alto — mayor superficie de divergencia. | Solo para dominios donde el valor justifica el riesgo. El ledger contable rara vez es el primer candidato. |
| **4. Replace** (core empaquetado) | Temenos, Thought Machine, Finxact, etc. | N/A — es otro producto. | Muy alto — cambio de sistema de registro. | Improbable para Altamira completo; posible para dominios acotados. Handoff a `Core Banking Transformation` SME. |
| **5. Encapsulate / Retain** (API-fy, dejar el batch donde está) | z/OS Connect / APIs sobre el batch existente. | Sin cambio (sigue en mainframe). | Nulo. | Para lo que no urge mover. APX ya hizo esto con las consultas. |

> **Recomendación de secuencia para BBVA:** Para el **bloque de contabilidad** específicamente, evaluar seriamente **Replatform (Heirloom/Micro Focus) como paso 1** para salir del mainframe con riesgo bajo y desempeño preservado, y **luego** refactorizar a Java cloud-native dominio por dominio (paso 2) con los patrones de §2.2. Intentar el salto directo COBOL→microservicios-distribuidos (lo que aparenta haber hecho Kyndryl) es el camino de mayor riesgo de desempeño para el dominio más crítico del banco.

---

### 2.2 — Patrones Técnicos de Remediación (para hacerlo bien en Java)

Estos son los patrones que convierten un refactor de 1:10 en uno de <3:1. Mapeados contra las causas que resuelven:

| Patrón | Qué resuelve | Detalle de implementación |
|--------|--------------|---------------------------|
| **Chunk-oriented processing (Spring Batch / Jakarta Batch)** | B-1, D-1, D-5 | Read-process-write en chunks con commit-interval calibrado (p.ej. 1,000–10,000). Restart-ability nativa. Reemplaza el commit-por-registro. |
| **Operaciones bulk / JDBC batch / bulk loaders** | B-1, F-3 | `addBatch()`/`executeBatch()`, `COPY` (Postgres), bulk load nativo. Nunca INSERT fila por fila. |
| **Reference data en memoria** | B-3 | Cargar catálogos una vez al inicio en `HashMap`/estructuras inmutables. Elimina lookups repetidos a BD. |
| **Procesamiento set-based (push-down a SQL)** | I-1, I-2 | Filtros/agregaciones/joins que el motor de datos hace mejor → SQL. Java orquesta, la BD procesa. |
| **Decimal correcto y eficiente** | A-1, A-4 | `BigDecimal` **obligatorio** para dinero (nunca `double`). Considerar librerías de decimal rápido; fijar escala/rounding idénticos al COBOL. |
| **Decodificación de formato en ingesta** | A-2, A-3, P-01 | Capa de ingestión que decodifica COMP-3/EBCDIC/binario **una vez** a tipos Java nativos antes del procesamiento. Copybooks como fuente de layout (herramientas: JRecord, Cobol-to-POJO). |
| **Sort/merge de alto desempeño** | C-1, C-2, C-3 | External merge-sort optimizado o push-down del ORDER BY/JOIN a la BD. Preservar el sort key exacto del JCL. Para JOINKEYS: merge-join sobre streams pre-ordenados, no nested-loop. |
| **Preservar ordenamiento determinista** | C-4, + correctitud contable | El orden de aplicación de asientos es semántica, no detalle. Documentar y replicar cada sort implícito. Test de equivalencia registro-a-registro. |
| **Minimizar object churn** | E-1, E-3, E-4 | Reutilizar buffers, evitar autoboxing en hot loops, streaming en vez de cargar todo en memoria, arrays primitivos donde aplique. GC tuning (G1/ZGC). |
| **Evitar ORM en batch** | F-1 | JDBC plano, jOOQ o MyBatis para el camino de datos batch. Reservar JPA para lo online/CRUD. |
| **GraalVM native image** | E-2 | Para batches cortos que no calientan el JIT, native image elimina el warmup. |
| **Batch monolítico, no distribuido** | G-1, G-2, G-3, G-4 | **El batch de alto volumen NO debe descomponerse en microservicios chatty.** Un servicio batch cohesivo que procesa en memoria/BD local. La descomposición en microservicios es para el plano online, no para el ledger batch. |
| **Co-localizar cómputo y datos** | B-5, H-2 | El batch corre cerca de su base de datos (misma AZ/VPC, réplica local). Minimizar round-trips de red. |
| **Particionamiento con orden preservado** | D-3, H-1 | Spring Batch partitioning por rangos **independientes** (p.ej. por sucursal/cuenta) donde el orden intra-partición se respeta. Paralelismo sin romper la semántica contable. |
| **Right-sizing de contenedores** | H-3, H-4 | CPU/memoria del pod dimensionados al batch; evitar CPU throttling; nodos dedicados para la ventana batch si aplica. |

---

### 2.3 — Tooling / Vendors Relevantes para BBVA

| Herramienta | Categoría | Nota para BBVA |
|-------------|-----------|----------------|
| **AWS Mainframe Modernization** (Blu Age + Micro Focus) | Refactor automatizado + Replatform | BBVA ya opera en AWS (plataforma ADA). Alineación natural con el cloud target. |
| **Heirloom Computing** | Replatform (COBOL→JVM bytecode) | Reclama desempeño cercano al mainframe preservando COBOL. Fuerte candidato para el ledger como paso 1. |
| **Micro Focus / OpenText Enterprise Server** | Replatform | Maduro, ampliamente usado en banca. |
| **IBM watsonx Code Assistant for Z** | Refactor COBOL→Java asistido por IA | Del propio IBM; útil como acelerador con revisión humana. |
| **TSRI JANUS** | Refactor automatizado | Transformación con refactor arquitectónico. |
| **Red Hat OpenShift** | Runtime de contenedores | BBVA ya lo usa; destino de los servicios Java. |
| **Spring Batch / Jakarta Batch** | Framework de batch | El estándar para el patrón chunk-oriented. |
| **JRecord / Cobrix** | Decodificación COMP-3/copybooks | Para la capa de ingestión (A-2, A-3, P-01). |

---

### 2.4 — Decisión Clave: ¿Mover el Ledger Fuera del Mainframe?

Una recomendación honesta que diferencia a Accenture de un vendor que solo empuja "todo a la nube":

> **No todo dominio debe salir del mainframe al mismo tiempo, y el ledger contable batch es el candidato más delicado.** El desempeño de DFSORT + VSAM secuencial + DB2 co-localizado es genuinamente difícil de igualar. Muchos bancos tier-1 **modernizan alrededor del ledger** (API-fy, canales, online) y dejan/replatforman el núcleo batch contable como último paso, precisamente para evitar el escenario Kyndryl.

Para BBVA, el marco de decisión por dominio:

1. **¿Es batch de alto volumen y secuencial?** → Replatform primero, refactor después. (Ledger, cierres, EOD)
2. **¿Es online/transaccional de baja latencia?** → Refactor a microservicios cloud-native. (Consultas — ya en APX)
3. **¿Es lógica de negocio estable y crítica?** → Equivalencia ≥ 99.99% + parallel-run largo, sin importar la estrategia.
4. **¿El driver es reducir MIPS ya?** → Replatform da el ahorro sin el riesgo del rewrite.

---

## Resumen Ejecutivo — Aplicación al Caso BBVA/Kyndryl

1. **Causa raíz más probable del fallo:** combinación de **B-1 (N+1)** + **G-1 (batch monolítico forzado a microservicios distribuidos de APX)**, agravado por **A-1 (decimal por software)** y **E-1 (object churn/GC)**. Explican por sí solas la degradación 1:10.
2. **Por qué Kyndryl no lo resolvió en 8 meses:** el diagnóstico requiere conocer el modelo de ejecución original de Altamira (cómo hacía el I/O, el sort, el orden de asientos). Kyndryl no lo construyó.
3. **Oferta de entrada Accenture:** Performance Diagnosis Assessment (4–6 semanas) — instrumentar, identificar cuáles de estas causas aplican, y entregar roadmap de remediación con los patrones de §2.2.
4. **Recomendación técnica probable:** re-ingeniar el bloque de contabilidad como **batch cohesivo chunk-oriented** (no microservicios chatty), con bulk I/O, decimal correcto, e ingesta que decodifica COMP-3 — o evaluar **replatform (Heirloom) como puente** si el time-to-value manda.
5. **Gate innegociable:** equivalencia contable ≥ 99.99% registro-a-registro antes de cualquier cutover.

---

*Última actualización: 2026-07-07 · v1.0 · Catálogo de causas + alternativas. Respalda el Performance Diagnosis Assessment como oferta de entrada a BBVA.*
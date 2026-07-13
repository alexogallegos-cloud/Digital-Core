# Modernización de Batch COBOL a Java
## Enfoque, Retos y Consideraciones Críticas
> Documento de posicionamiento para BBVA · Accenture Technology — High Velocity Modernization
> **Framework-agnóstico**: aplica a Java sobre Spring Boot, Quarkus, Jakarta Batch u otro runtime.

---

> ⚠️ **Nota interna (no incluir en la versión al cliente):** este documento es la versión sanitizada/client-facing. Deliberadamente **no menciona APX** ni al incumbente. El análisis interno completo vive en `analisis-desempeno-mainframe-a-java.md` y `reimplementacion-batch-java-referencia.md`. Borrar esta nota antes de compartir.

---

## 1. Mensaje Central

> **El reto de modernizar COBOL a Java no está en el lenguaje. Está en el modelo de ejecución.**

Un mainframe no es solo COBOL: es una máquina afinada durante décadas para throughput de batch — aritmética decimal por hardware, entrada/salida secuencial de alto ancho de banda, motores de ordenamiento optimizados y co-localización de cómputo y datos. Cuando una migración traduce el *código* pero no re-ingeniería el *modelo de ejecución*, el resultado típico es **funcionalmente correcto pero con desempeño degradado**: procesos que cerraban su ventana en el mainframe ahora la exceden.

Este documento presenta los retos que Accenture anticipa y gestiona para que la modernización entregue **la misma exactitud y una ventana de proceso igual o mejor** — no solo código en un lenguaje nuevo.

---

## 2. Por qué las Migraciones COBOL→Java Decepcionan en Desempeño

En migraciones de esta naturaleza es común observar un patrón recurrente:

1. Se traduce el COBOL a Java de forma **literal, registro por registro**.
2. El resultado pasa las pruebas funcionales de bajo volumen.
3. Al escalar a volumen productivo, el desempeño se desploma — relaciones de **1:10 o peores** frente al COBOL original.
4. La causa raíz es difícil de aislar porque no está en una línea de código, sino en decisiones arquitectónicas distribuidas por todo el diseño.

La lección de industria es clara: **la migración de batch de alto volumen debe diseñarse como re-ingeniería del proceso, no como transpilación**. El lenguaje destino (Java) es capaz de igualar al mainframe — pero solo si se respetan los patrones correctos.

---

## 3. Los Retos Comunes — y Cómo se Gestionan

Ocho familias de retos. Para cada una: qué ocurre, el impacto de negocio, y el enfoque de gestión.

---

### Reto 1 · Aritmética Financiera Exacta

| | |
|---|---|
| **Qué ocurre** | COBOL usa *packed decimal* (`COMP-3`) con aritmética acelerada por hardware. Java requiere `BigDecimal`, que es software y más costoso en CPU. La tentación de usar `double` "por desempeño" introduce errores de redondeo. |
| **Impacto** | Descuadres de centavos = error contable auditable. En banca, un solo asiento mal redondeado es un hallazgo regulatorio. |
| **Gestión Accenture** | `BigDecimal` obligatorio con **escala y modo de redondeo idénticos** al COBOL original; prohibición de `double` para importes; pruebas de equivalencia aritmética como criterio de aceptación. |

---

### Reto 2 · Representación y Decodificación de Datos

| | |
|---|---|
| **Qué ocurre** | Los datos del mainframe vienen en EBCDIC, packed/zoned decimal, binario big-endian, con estructuras `REDEFINES` (misma memoria, distintos tipos) y `OCCURS`. Java no los interpreta nativamente. |
| **Impacto** | Si no se decodifican correctamente, los valores son erróneos **desde el primer registro** — y las pruebas iniciales pueden no detectarlo. |
| **Gestión Accenture** | Una **capa de ingesta** que decodifica los formatos mainframe a tipos Java nativos **una sola vez**, basada en los copybooks originales. Tratamiento explícito de `REDEFINES` y valores especiales (`LOW-VALUES`/`HIGH-VALUES`). |

---

### Reto 3 · Modelo de Acceso a Datos e I/O — *El reto crítico*

| | |
|---|---|
| **Qué ocurre** | COBOL lee archivos secuenciales de millones de registros en un solo barrido a velocidad de canal. La traducción ingenua reemplaza esto por **una consulta a base de datos por registro** (anti-patrón "N+1"). |
| **Impacto** | Es la causa #1 de degradación 10×–100×. Adicionalmente, si la base de datos ya no está co-localizada, cada acceso se vuelve un viaje de red. |
| **Gestión Accenture** | Lectura en **streaming** (cursores, no cargar todo en memoria); catálogos y tablas de referencia cargados **una vez en memoria** (elimina lookups repetidos); escritura **masiva** (bulk) en lote; co-localización de proceso y datos. |

---

### Reto 4 · Utilerías de Ordenamiento y Match

| | |
|---|---|
| **Qué ocurre** | Los motores de SORT del mainframe (y operaciones tipo JOINKEYS) están extraordinariamente optimizados y aplican ordenamientos **implícitos** antes de los matches entre archivos. |
| **Impacto** | Reimplementados ingenuamente son lentos (un merge-join O(n) se convierte en un nested-loop O(n²)) **o incorrectos** si no se replica el orden previo — los saldos intermedios divergen aunque cada operación sea válida. |
| **Gestión Accenture** | Empujar el ordenamiento y el join al motor de datos (optimizado para ello); merge-join sobre flujos pre-ordenados; **documentar y replicar el criterio de orden exacto** de cada utilería del proceso original. |

---

### Reto 5 · Modelo de Procesamiento Batch

| | |
|---|---|
| **Qué ocurre** | El batch mainframe hace *commits* espaciados con checkpoint/restart eficiente. La traducción suele hacer **commit por registro**, con enorme overhead, y pierde la capacidad de reinicio ante fallos. |
| **Impacto** | Cada commit es una operación costosa; multiplicado por millones de registros, domina el tiempo. Sin restart, cualquier fallo obliga a reprocesar todo. |
| **Gestión Accenture** | Procesamiento **chunk-oriented** (leer-procesar-escribir en lotes con un commit por lote); persistencia de estado de ejecución para **reinicio desde el punto de fallo** (equivalente al checkpoint del mainframe). |

---

### Reto 6 · Runtime de Java (Memoria y Arranque)

| | |
|---|---|
| **Qué ocurre** | COBOL trabaja con memoria de asignación fija: cero *allocation* en el loop. Java crea objetos por cada registro, generando presión de recolección de basura (GC). Además, un batch de corta duración no "calienta" el compilador JIT. |
| **Impacto** | Pausas de GC y CPU gastada en recolección en lugar de negocio; arranque lento en procesos cortos. |
| **Gestión Accenture** | Minimizar creación de objetos en el hot path (reutilización de buffers, evitar autoboxing); afinamiento de GC (G1/ZGC); **imagen nativa (GraalVM)** para procesos cortos que no se benefician del JIT. |

---

### Reto 7 · Arquitectura: Cohesión vs. Distribución

| | |
|---|---|
| **Qué ocurre** | Existe la tentación de descomponer un proceso batch monolítico en microservicios que se comunican por red. Para un batch de alto volumen esto es un error: cada iteración interna se convierte en una llamada de red (HTTP + serialización). |
| **Impacto** | Degradación catastrófica — lo que eran millones de operaciones en memoria se vuelven millones de llamadas de red. |
| **Gestión Accenture** | **Batch cohesivo**, no chatty. La distribución para escalar se hace por **partición** (miles de registros procesados localmente por cada nodo), **nunca por registro**. El tier de batch se despliega **separado del tier de servicios online**. |

> **Principio:** los microservicios distribuidos son el patrón correcto para el plano *online* (baja latencia, request/response). El batch de alto volumen quiere cohesión y localidad de datos. Son dos problemas de diseño distintos.

---

### Reto 8 · Equivalencia Funcional y Lógica de Negocio Embebida

| | |
|---|---|
| **Qué ocurre** | Parte de la lógica de negocio no vive en el código COBOL, sino en el flujo de control del scheduler y en utilerías. Las fórmulas críticas (p.ej. cálculo de intereses) están *hardcoded* con reglas específicas del banco. |
| **Impacto** | Herramientas automatizadas —incluidas las basadas en IA— tienden a "rellenar" con conocimiento genérico del dominio (una fórmula estándar de mercado) en lugar de replicar la regla exacta del sistema. El resultado se ve razonable pero es incorrecto. |
| **Gestión Accenture** | Extracción de reglas **línea a línea desde el código original**, no desde documentación genérica; validación por especialistas de negocio bancario; y **equivalencia de resultados ≥ 99.99% registro a registro** contra el sistema origen como gate de salida. |

---

## 4. La Decisión de Framework: No Hay Uno "Correcto" Universal

Accenture es **agnóstico al framework** y elige por workload, no por preferencia. Las opciones más relevantes para banca:

| Framework | Fortaleza principal | Mejor ajuste |
|-----------|---------------------|--------------|
| **Spring Boot + Spring Batch** | El ecosistema de batch más maduro: restart, partitioning y tolerancia a fallos nativos; el mayor pool de talento del mercado | **Batch transaccional de alto volumen** (cierres, contabilidad, EOD) |
| **Quarkus** | Arranque muy rápido, baja huella de memoria, imagen nativa (GraalVM); alta densidad de contenedores y eficiencia de costo | **Servicios online cloud-native** y workloads sensibles a costo/arranque |
| **Jakarta Batch (JSR-352)** | Estándar portable entre runtimes de Java | Independencia de proveedor; entornos Java EE existentes |

**Guía de decisión:**
- Para **batch de alto volumen** (el caso del núcleo contable), la madurez del ecosistema de batch suele ser el factor decisivo → Spring Batch o Jakarta Batch.
- Para **servicios online** de baja latencia y despliegue denso en contenedores → Quarkus por eficiencia de recursos.
- La arquitectura correcta frecuentemente **combina ambos**: Quarkus para el plano online, un runtime de batch maduro para el plano de proceso masivo — desplegados en tiers separados.

> Lo que importa no es el logo del framework, sino aplicar los **patrones correctos** (streaming, chunk, bulk, partición, decimal exacto) sobre el que se elija.

---

## 5. El Enfoque Accenture — Cómo De-riesgamos la Modernización

```
┌────────────┐   ┌────────────┐   ┌────────────┐   ┌────────────┐
│ 1 DISCOVER │──▶│ 2 DISEÑO   │──▶│ 3 BUILD    │──▶│ 4 EQUIV. + │
│ del proceso│   │ del modelo │   │ patrones   │   │ PARALLEL   │
│ real       │   │ de ejec.   │   │ correctos  │   │ RUN        │
└────────────┘   └────────────┘   └────────────┘   └────────────┘
```

1. **Discover del proceso real** — Ingeniería inversa de la lógica de negocio *tal como está implementada*, no como se documentó. Identificación de reglas embebidas en utilerías y fórmulas hardcoded.
2. **Diseño del modelo de ejecución** — Antes de escribir Java, se decide: dónde hay streaming, qué se carga en memoria, dónde se hace bulk, cómo se particiona sin romper el orden, qué framework por workload.
3. **Build con patrones correctos** — Reimplementación chunk-oriented, decimal exacto, ingesta que decodifica formatos, batch cohesivo. IA como **acelerador**, con **revisión humana obligatoria** sobre toda lógica financiera y regulatoria.
4. **Equivalencia + Parallel-run** — Comparación de salidas ≥ 99.99% registro a registro, y ventana de coexistencia con el sistema origen antes de cualquier cutover — alineado a las expectativas del regulador.

---

## 6. Factores Críticos de Éxito

- ✅ **Re-ingeniería del modelo de ejecución**, no transpilación literal.
- ✅ **Exactitud aritmética** verificada contra el original (no fórmulas genéricas).
- ✅ **Patrones de alto volumen**: streaming, lookups en memoria, bulk I/O, chunk-commit.
- ✅ **Batch cohesivo** con distribución por partición — nunca chatty por registro.
- ✅ **Framework elegido por workload**, tiers online y batch separados.
- ✅ **IA acelera, humano valida** la lógica crítica.
- ✅ **Equivalencia ≥ 99.99%** y parallel-run como gate innegociable.

---

## 7. Anti-Patrones que Evitamos (Resumen Ejecutivo)

| Anti-patrón | Consecuencia |
|-------------|--------------|
| Traducción literal registro por registro | Se hereda el peor patrón de desempeño |
| Una consulta a BD por registro (N+1) | Degradación 10×–100× |
| Descomponer batch en microservicios chatty | Degradación catastrófica por red |
| INSERT/UPDATE fila por fila | Round-trips masivos a la BD |
| `double` para importes | Error contable auditable |
| Commit por registro | Overhead que domina el tiempo |
| Interpretar reglas con conocimiento genérico de IA | Resultado plausible pero incorrecto |

---

## 8. Cierre

Modernizar COBOL a Java para una institución de la escala de BBVA es alcanzable con **la misma exactitud y una ventana de proceso igual o mejor** — siempre que se trate como una **re-ingeniería del modelo de ejecución** y se respeten los patrones de alto volumen. Accenture aporta el método, la disciplina de equivalencia regulatoria y la experiencia de haber navegado estos retos en núcleos bancarios de misión crítica.

El primer paso recomendado es un **diagnóstico focalizado** que identifique, sobre un proceso representativo, cuáles de estos retos están presentes y cuál es el camino de remediación con mayor retorno y menor riesgo.

---

*Accenture Technology · High Velocity Modernization · Documento de posicionamiento · v1.0 · 2026-07-07*
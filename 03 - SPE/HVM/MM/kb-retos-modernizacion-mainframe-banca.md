# Knowledge Base — Retos de Modernización Mainframe en Banca
> Síntesis de experiencia real en engagement de modernización de core bancario IBM z/OS (COBOL/JCL/VSAM) hacia código abierto (Java).
> Aplicable a cualquier banco Tier-1 con plataforma mainframe en producción.
> Fuente: engagement activo BBVA México (Proyecto Gamma) + análisis técnico acumulado del offering HVM.

---

## Cómo usar este documento

Este KB está organizado en **10 capítulos temáticos** que cubren el espectro completo de retos: técnicos, arquitectónicos, de datos, de pruebas, organizacionales, de knowledge, y regulatorios. Cada capítulo incluye:

- **El reto** — qué ocurre y por qué
- **Evidencia de campo** — lo que la experiencia real confirma
- **Implicaciones** — consecuencias si se ignora
- **Cómo abordarlo** — patrón o práctica de remediación

**Principio rector de todo el KB:**
> El problema casi nunca es "el lenguaje de destino es lento". El problema es que se traduce el _código_ pero no se re-ingeniería el _modelo de ejecución_. El mainframe IBM z/OS no es solo un lenguaje — es una máquina diseñada 50+ años para throughput de batch: I/O secuencial de alto ancho de banda, aritmética decimal por hardware, motores de SORT en assembler, y co-localización de cómputo y datos. Cuando se migra COBOL a Java con traducción literal 1:1, se pierde todo eso.

---

## Capítulo 1 — La Arquitectura del Problema: Tres Capas, Tres Desafíos Diferentes

### El reto

El error más frecuente al iniciar un programa de modernización mainframe es tratar el sistema como **un problema homogéneo**. En la práctica, un core bancario mainframe tiene tres capas con naturalezas radicalmente distintas, cada una requiere un enfoque diferente:

| Capa | Descripción | Naturaleza técnica | Dificultad |
|------|------------|-------------------|------------|
| **Online / Línea** | Transacciones operativas del cliente: consultas de saldo, movimientos, productos. | Stateless, request/response, baja latencia, sin estado persistente entre llamadas. | ⚡ Media — soluble con microservicios REST |
| **Conversacional** | Pantallas de terminal CICS, 3270, navegación por flujos. Representan **~70% del código** del mainframe. | Stateful, orientado a sesión, lógica de presentación entretejida con negocio. | 🔶 Alta — requiere enfoque diferente al online |
| **Batch de alto volumen** | Procesos nocturnos masivos: cierre contable (EOD), liquidación, reportes regulatorios, conciliación. | Masivo, secuencial, ordenado, dependiente del orden de aplicación de registros. | 🔴 Muy alta — donde el mainframe es imbatible |

### Evidencia de campo

En un banco Tier-1 de México con más de 130 millones de líneas de código en mainframe:
- La capa **online** se resolvió durante 10–12 años construyendo servicios REST stateless — funcionó. Al inicio del programa tenían target de 4,000 servicios; construyeron 9,000.
- La capa **conversacional** (las pantallas de terminal) bloqueó durante años. Un intento con Angular fue "un desastre, no se podía mantener." Eventualmente se resolvió con agentes de IA que auto-generan la capa de presentación.
- La capa **batch** (bloque de contabilidad) lleva años sin solución satisfactoria de performance. Es donde han fallado múltiples proveedores.

### Implicaciones

Los programas que mezclan las tres capas en un solo enfoque metodológico fracasan porque lo que resuelve el problema online (microservicios chatty, REST) es exactamente el anti-patrón que destruye el performance del batch. Un banco que ya "migró" 9,000 servicios online no ha resuelto el problema mainframe — ha resuelto el problema más fácil.

### Cómo abordarlo

**Diagnóstico primero**: mapear qué porcentaje del código vive en cada capa antes de proponer un roadmap. Las tres capas requieren metodologías, herramientas, y patrones de equivalencia distintos. Un programa de modernización mainframe bien diseñado tiene **tres tracks paralelos**, no uno.

---

## Capítulo 2 — Performance en Batch: El Talón de Aquiles

El batch de alto volumen es donde el mainframe IBM z/OS tiene ventajas estructurales que la arquitectura distribuida no replica automáticamente. Esta sección cataloga las causas de degradación de performance más comunes.

### 2.1 El Anti-Patrón N+1 a Escala Masiva — **La Causa #1**

**El reto**: El COBOL lee un dataset secuencial (QSAM/VSAM) de millones de registros en un solo barrido a velocidad de canal de datos. La traducción ingenua hace **un `SELECT` por registro** contra la base de datos.

**Evidencia de campo**: Un banco con 120 millones de operaciones de contabilidad por noche comprobó que esta traducción colapsa la red. No es metáfora — la red literalmente satura. Lo que el mainframe procesa en una ventana batch definida tarda múltiplos de esa ventana en Java por este único anti-patrón.

**Por qué ocurre**: Los desarrolladores Java piensan en objetos y repositorios, no en streaming de archivos. Los agentes de IA hacen el mismo error: traducen `READ` a `findById()`.

**Degradación típica**: 10× a 100× sobre el tiempo de mainframe para el mismo volumen.

**Cómo abordarlo**: Nunca row-by-row. Siempre streaming cursor (cursor server-side con `fetchSize` alto). Un barrido secuencial como hacía el COBOL, no una query por registro.

---

### 2.2 El SORT en Hardware vs. Software

**El reto**: DFSORT/SyncSort en IBM z/OS son motores de ordenamiento escritos en assembler, optimizados durante 40+ años, con hardware sort-assist y acceso directo a los canales de I/O del mainframe. No hay equivalente en x86/JVM que se acerque en volúmenes grandes.

**Evidencia de campo**: En un banco real, probaron la utilería SORT convertida a Java sobre **un servidor dedicado con todos los procesadores, sin ninguna carga concurrente, sin servicios compitiendo**. Resultado: corre a **un cuarto de la velocidad del mainframe**. Esto solo, sin el resto de los problemas, es inaceptable para cerrar una ventana batch nocturna.

**Por qué ocurre**: `Collections.sort()` y `ORDER BY` genérico son algoritmos correctos pero no tienen acceso al hardware de I/O del mainframe ni a la optimización de 40 años de DFSORT.

**Variante crítica — JOINKEYS**: El SORT hace merge-join en una sola pasada sobre archivos ya ordenados (O(n)). La reimplementación como nested-loop join en Java es O(n²). Para archivos de millones de registros, la diferencia es catastrófica.

**Variante de correctitud — Ordenamiento implícito**: El match de archivos en JCL depende de un orden previo que la utilería garantiza implícitamente. Si Java no replica ese sort previo al join, el resultado del match es **incorrecto**, no solo lento.

**Cómo abordarlo**: Push-down del ordenamiento al motor de base de datos (`ORDER BY` + índices correctos) siempre que sea posible. Para merge-join, implementar merge-join sobre dos streams pre-ordenados, no nested-loop. Documentar explícitamente cada sort key implícito del JCL antes de iniciar la conversión.

---

### 2.3 Aritmética Decimal: COMP-3 vs. BigDecimal

**El reto**: z/Architecture ejecuta aritmética decimal (`COMP-3`, packed decimal) con instrucciones de hardware específicas (decimal arithmetic facility, DFP). `java.math.BigDecimal` es correcto pero 100% software — cada suma o multiplicación es un método Java con allocation de objeto.

**Variante de correctitud (más grave)**: Si el desarrollador o agente de IA traduce COMP-3 a `double` para ganar velocidad, el resultado es rápido pero **rompe la equivalencia contable** por errores de redondeo. Un descuadre de centavos en el ledger de un banco es un hallazgo de auditoría.

**Evidencia de campo**: Los bancos han comprobado que "la conversión de los tipos de datos y regresarlos al formato y volver a regresarlos" acumula latencia en cada cálculo. En batch de 120 millones de asientos, cada microsegundo de overhead por cálculo se multiplica en minutos o horas.

**Por qué ocurre**: Los desarrolladores Java usan `double` por hábito o velocidad. Los agentes de IA traducen literalmente a tipos primitivos. Ninguno conoce la semántica financiera de COMP-3.

**Cómo abordarlo**: `BigDecimal` **obligatorio** para todo campo monetario — sin excepción, sin `double`. Fijar escala y `RoundingMode` idénticos al comportamiento del COBOL original. Para la conversión de los datos en sí, usar bibliotecas de decodificación de copybooks (JRecord, Cobrix) que decodifican COMP-3 a `BigDecimal` directamente.

---

### 2.4 Data Locality: LPAR vs. Arquitectura Distribuida

**El reto**: DB2 en un LPAR mainframe vive en el mismo sistema físico que el batch COBOL. El acceso es vía cross-memory services — microsegundos, sin red. En arquitectura distribuida, cada acceso a datos es un round-trip de red.

**Por qué importa**: Combinado con el anti-patrón N+1, esto convierte microsegundos en milisegundos por operación, multiplicado por 120 millones de operaciones. El resultado es la diferencia entre minutos y días.

**Cómo abordarlo**: El tier de batch debe co-localizarse con sus datos (misma VPC/AZ, réplica local). La distancia entre el proceso y los datos no es un detalle de despliegue — es parte del diseño de performance.

---

### 2.5 El Batch Monolítico Forzado a Microservicios — La Causa Estructural

**El reto**: Si el programa COBOL de contabilidad (monolítico por diseño) se descompone en microservicios que se llaman entre sí, cada interacción intra-programa se convierte en un round-trip HTTP. Un loop que hacía millones de `PERFORM` internos ahora hace millones de llamadas de red.

**Evidencia de campo**: Esta es la hipótesis de mayor probabilidad para explicar los fallos de performance del bloque de contabilidad. Una plataforma de backend transaccional distribuida fue elegida como destino para un proceso batch masivo y secuencial. El modelo de ejecución del batch (un proceso cohesivo que opera sobre millones de registros en memoria) es incompatible con el modelo de ejecución de la plataforma online (muchos servicios stateless request/response).

**Por qué ocurre**: Los proyectos de modernización asumen que "microservicios es mejor" para todo. Los arquitectos de servicios online diseñan el batch con el mismo patrón que los servicios online.

**Degradación típica**: Catastrófica — potencialmente infinita en el sentido de que el batch nunca termina dentro de la ventana.

**Cómo abordarlo**: El batch de alto volumen **no se descompone en microservicios chatty**. Es un proceso cohesivo chunk-oriented que opera localmente sobre sus datos. La descomposición en microservicios es correcta para el plano online, no para el ledger batch. Si se necesita paralelismo, la unidad de distribución es la **partición** (miles de registros), no el registro individual.

---

## Capítulo 3 — Conversión de Código: "Modernizar No Es Traducir"

### 3.1 La Paradoja de la Conversión Determinística

**El reto**: Los convertidores determinísticos (herramientas que transforman COBOL a Java automáticamente, "un botón y 1.5 millones de líneas convertidas") producen código que es **funcionalmente correcto** pero **performáticamente inaceptable**.

**Evidencia de campo**: En un banco real, un proveedor especializado en conversión determinística entregó una migración "funcionalmente perfecta, totalmente cuadrada" del bloque de contabilidad. El sistema producía los mismos asientos que el mainframe. El problema: el tiempo de procesamiento hacía inviable la ventana batch nocturna.

**Por qué ocurre**: Los convertidores determinísticos replican la lógica — no el modelo de ejecución. Traducen `PERFORM UNTIL` a `while`, `READ` a `findById()`, `COMPUTE` a expresiones Java. El código es correcto; el patrón de ejecución es fatal para volúmenes bancarios.

**Implicación**: La equivalencia funcional es una condición necesaria pero no suficiente. La equivalencia de performance es igualmente obligatoria. Un programa de modernización que solo verifica equivalencia funcional está destinado a fallar en producción bajo carga real.

---

### 3.2 Los Agentes de IA Cometen el Mismo Error

**El reto**: Los agentes de IA para conversión de código (GitHub Copilot, Amazon Q, Claude, etc.) tienen el mismo problema que la conversión determinística: tienden a hacer traducción literal. El agente no conoce la diferencia entre un `READ` secuencial de archivo y una query JDBC.

**Implicaciones adicionales de los agentes de IA**:

| Error de IA | Descripción | Consecuencia |
|-------------|-------------|--------------|
| **Nombre de variable = regla de negocio** | El agente usa el nombre de la variable COBOL como definición de la regla, en vez de inferirla de la lógica del código. | Especificaciones funcionales incorrectas o ambiguas. |
| **Complemento con conocimiento general** | Al interpretar el objetivo de un componente, el agente rellena con información genérica del dominio bancario. | Ej.: calcula el interés moratorio con la fórmula estándar del sector en vez de la fórmula exacta hardcodeada en el COBOL. Para contabilidad bancaria, la fórmula del agente ≠ la fórmula real = error auditable. |
| **Lógica en JCL invisible al agente** | El agente analiza los programas COBOL pero no el control flow del JCL. Las reglas de negocio embebidas en SORT/JOINKEYS/condiciones JCL son invisibles. | Código Java que produce resultados correctos para los casos que el agente vio, incorrectos para los casos que viven en el JCL. |

**Cómo abordarlo**: Los agentes de IA son aceleradores, no sustitutos del entendimiento del sistema. Toda salida funcional del agente debe validarse por un experto bancario contra el comportamiento real del programa, no contra su nombre. Las fórmulas financieras se extraen línea a línea del COBOL, no se infieren del dominio.

---

### 3.3 Los Constructos COBOL/JCL Sin Traducción Literal

Hay al menos 25 constructos COBOL/JCL que no pueden traducirse literalmente a Java — requieren un patrón de reimplementación explícito. Los más críticos:

| Construct | Problema de traducción | Patrón correcto |
|-----------|----------------------|-----------------|
| **JOINKEYS (SORT utility)** | El agente no replica correctamente el match entre archivos — puede perder registros, duplicar, o no respetar el orden de join. | Implementar merge-join sobre streams pre-ordenados; verificar equivalencia registro a registro. |
| **DFSORT instrucciones propietarias** (`COUNT`, `SKIP`, `NODUP`, `EDIT`) | El agente no conoce estas instrucciones IBM de forma nativa — genera código que no replica el comportamiento. | Crear catálogo de equivalencias IBM-utility → Java por instrucción usada en el sistema. |
| **`REDEFINES`** | Una misma posición de memoria con tipos de dato diferentes según contexto. El agente crea clases separadas que rompen la semántica compartida de memoria. | Union/tagged-union en Java, o BitBuffer. Validar con test de igualdad de bytes en memoria. |
| **`STRING` / `UNSTRING`** | Concatenación y división de strings con delimitadores y manejo de overflow que Java no replica con operaciones estándar. | Helpers Java verificados con pruebas de comportamiento borde. |
| **`INSPECT`** | Recuento y sustitución de caracteres en posiciones específicas — semántica distinta a `String.replace()`. | Mapear cada uso a su equivalente exacto; no usar traducción automática. |
| **`LOW-VALUES` / `HIGH-VALUES`** | Representan el byte mínimo (0x00) y máximo (0xFF). Sin equivalente directo en Java String. | Constantes `byte[]` o `char` con valor explícito 0x00/0xFF; nunca traducir a `""` o `null`. |
| **Ordenamientos implícitos pre-match** | El SORT ordena los archivos antes del match implícitamente. Si Java no replica ese orden, el join produce resultados incorrectos aunque la lógica de join sea correcta. | Todo match entre colecciones en Java debe ir precedido del mismo criterio de ordenamiento del JCL. |
| **`COMP-3` / Packed Decimal** | No existe equivalente nativo en Java. | Capa de decodificación en ingesta con JRecord/Cobrix. Nunca tratar como texto plano. |
| **`EBCDIC` encoding** | El mainframe almacena en EBCDIC; Java trabaja en UTF-8/Unicode. | Decodificar EBCDIC a Java una vez en la capa de ingesta. |
| **Aritmética de fechas julianas** | COBOL usa fechas julianas y períodos contables propios del sistema. | Mapear a `java.time` con conversión explícita y pruebas de casos borde en cierres de período. |

---

### 3.4 La Lógica de Negocio Oculta en JCL

**El reto**: En sistemas mainframe bancarios, una fracción significativa de la lógica de negocio no vive en los programas COBOL — vive en el **control flow del JCL** vía utilerías: condiciones de inclusión/omisión de registros (`INCLUDE`/`OMIT`), transformaciones de datos durante el sort (`INREC`/`OUTREC`), joins entre archivos (`JOINKEYS`), y reglas de conditional step execution.

**Evidencia de campo**: Los agentes de interpretación tratan estas construcciones como instrucciones técnicas de orquestación, no como reglas de negocio. Un agente que analiza COBOL sin analizar el JCL está viendo solo parte del sistema.

**Implicación**: Requiere analista con conocimiento bancario que decodifique la intención de cada step JCL con utilerías. No es automatizable con agentes de IA sin contexto adicional.

**Cómo abordarlo**: El análisis de equivalencia debe incluir el JCL completo como parte del sistema, no solo los programas COBOL. Cada utilería SORT con condiciones debe documentarse como regla de negocio explícita antes de la conversión.

---

## Capítulo 4 — Equivalencia y Pruebas

### 4.1 La Doble Equivalencia: Funcional Y de Performance

El marco de pruebas de equivalencia debe cubrir **dos dimensiones independientes**:

| Dimensión | Qué mide | Por qué importa |
|-----------|----------|-----------------|
| **Equivalencia funcional** | ¿El sistema Java produce exactamente los mismos asientos, saldos, y reportes que el mainframe? | El CNBV y los auditores van a verificar esto. Es condición necesaria para el cutover. |
| **Equivalencia de performance** | ¿El sistema Java termina dentro de la ventana batch? ¿Los SLAs de respuesta online se cumplen? | Un sistema funcionalmente correcto que no termina a tiempo es inútil en producción. |

**Lección crítica**: La equivalencia funcional puede lograrse con una conversión literal. La equivalencia de performance requiere re-ingeniería del modelo de ejecución. Un programa que solo verifica funcional puede declarar éxito y fallar en producción.

---

### 4.2 COMP-3 en Datos de Prueba — El Bloqueante Silencioso

**El reto**: Los archivos de prueba extraídos del mainframe contienen campos en formato packed decimal (COMP-3). Java no lee COMP-3 nativamente. El agente o desarrollador que no implementa un decoder COMP-3 trata estos campos como texto plano → todos los valores son incorrectos desde el primer registro.

**Implicación**: Antes de cualquier prueba de equivalencia, se requiere una etapa de transformación de datos de prueba: convertir los archivos de COMP-3 a formato legible por Java, o implementar un decoder COMP-3 en el reader del batch.

**Cómo abordarlo**: Usar JRecord o Cobrix para decodificar los copybooks COBOL y producir datos de prueba en formato Java antes de ejecutar cualquier prueba de equivalencia. Esta etapa no es opcional.

---

### 4.3 Precisión Decimal — El Descuadre de Centavos

**El reto**: Si el sistema migrado usa `double` o `float` para aritmética financiera, producirá resultados que difieren del mainframe en fracciones de centavo por operación. En un ledger contable con millones de asientos y saldos acumulados, estos errores de redondeo se acumulan.

**Evidencia de campo**: Los equipos de control interno son "muy incisivos" en este punto. Un descuadre de centavos en el cierre contable es un hallazgo de auditoría que puede paralizar la certificación regulatoria.

**Cómo abordarlo**: `BigDecimal` con escala y `RoundingMode` **idénticos** al COBOL original. La escala y el modo de redondeo no son parámetros de implementación — son parte de la especificación funcional que debe documentarse.

---

### 4.4 El "Piloto de Laptop" vs. El Piloto Real

**El reto**: Existe una diferencia abismal entre un piloto que "demuestra" la conversión en un ambiente controlado (dos programas corriendo en una laptop, resultados firmados por el proveedor) y una prueba real en el ambiente de desarrollo del banco con los volúmenes reales del sistema.

**Evidencia de campo**: En un banco Tier-1, la diferencia entre el piloto de un proveedor europeo (dos programas en laptop + reporte firmado) y los requerimientos del equipo local (convertir Y probar en el ambiente DEV del banco con datos reales) fue "como la noche y el día." El proveedor europeo pasó su piloto; no tenía nada que ver con las condiciones reales de producción.

**Implicación para propuestas**: Cualquier piloto de conversión debe definir explícitamente: ¿qué ambiente?, ¿qué volumen?, ¿qué criterio de aceptación? "Funciona en mi laptop" no es evidencia de nada para un core bancario.

---

### 4.5 REDEFINES — Los Múltiples Layouts del Mismo Campo

**El reto**: `REDEFINES` permite que la misma posición de memoria tenga múltiples interpretaciones de tipo de dato según el contexto de uso. Los casos de prueba deben cubrir **todos** los layouts posibles del REDEFINES.

**Por qué falla**: El agente y el desarrollador típicamente prueban solo el layout principal. Los layouts secundarios solo se ejercitan bajo condiciones específicas del negocio — que pueden no aparecer en los datos de prueba estándar.

**Cómo abordarlo**: Generar casos de prueba explícitos para cada rama del REDEFINES. La cobertura de equivalencia debe incluir todos los tipos de dato del overlay.

---

## Capítulo 5 — Retos de la Capa de Datos

### 5.1 DB2 → RDBMS — Más Manejable, Pero No Trivial

**El reto**: La migración de DB2 (mainframe) a un RDBMS relacional moderno (Oracle, PostgreSQL) es la parte más manejable del problema de datos. Los modelos son compatibles y hay herramientas maduras.

**Evidencia de campo**: En un banco real, la migración de DB2 a Oracle funcionó bien con pocos cambios — principalmente ajustes de tipos de dato. Los únicos errores fueron errores de dedo humano, no errores de conversión técnica.

**Lo que sí requiere cuidado**:
- Equivalencia de tipos de dato (especialmente fechas, decimales, y campos BLOB/CLOB)
- Diferencias en semántica de NULL, manejo de vacíos, y comparaciones
- Funciones propietarias de DB2 sin equivalente directo en el RDBMS destino
- Índices: el access path de DB2 no mapea automáticamente a los índices correctos del destino

---

### 5.2 VSAM KSDS → SQL — Cambio de Modelo de Acceso

**El reto**: VSAM KSDS (Key Sequence Data Set) es un índice B-tree en el mismo LPAR, con acceso por clave en microsegundos. Reemplazarlo por SQL sobre red cambia fundamentalmente el modelo de acceso.

**Cómo abordarlo**: Cada acceso VSAM debe analizarse para determinar si el patrón es secuencial (→ cursor streaming en SQL) o aleatorio por clave (→ índice primario + query puntual). El patrón de acceso determina el diseño del índice en el RDBMS destino.

---

### 5.3 ORM en Batch — El Error Clásico del Desarrollador Java

**El reto**: Los desarrolladores Java usan ORM (Hibernate/JPA) por defecto para todo acceso a datos. El ORM introduce N+1 automático (lazy loading), dirty-checking de la sesión, y gestión de caché que son correctos para aplicaciones CRUD pero **fatales** para batch de alto volumen.

**Cómo abordarlo**: JDBC plano, jOOQ, o MyBatis para el camino de datos batch. Reservar JPA/Hibernate para el plano online/CRUD. Esta es una regla no negociable para batch bancario.

---

### 5.4 Utilerías IBM como Tablas Relacionales — Complejidad No Requerida

**El reto**: Cuando el agente o desarrollador no puede replicar directamente una utilería IBM (SORT, JOINKEYS, ICETOOL), a veces propone crear tablas adicionales en la base de datos como sustituto. Esto aumenta la complejidad, introduce dependencias nuevas, y cambia el modelo de datos.

**Cómo abordarlo**: Evaluar caso a caso si la tabla es el reemplazo correcto, o si existe una solución en memoria (colecciones Java) que preserve la semántica original sin persistencia adicional. La complejidad adicional tiene costo de mantenimiento a largo plazo.

---

## Capítulo 6 — Retos Arquitectónicos

### 6.1 La Plataforma de Destino También Puede Volverse Legado

**El reto**: En programas de modernización de larga duración (3–5+ años), la plataforma de destino elegida al inicio puede convertirse en legado antes de que el programa termine. La tecnología evoluciona más rápido que los programas de transformación bancaria.

**Evidencia de campo**: Un banco que empezó a usar Java EE como capa de desacoplamiento del mainframe descubrió que esa misma capa era considerada "legado generacional" años después. La solución transitoria se convirtió en el siguiente problema a modernizar.

**Una variante más aguda**: "cuando arranca el proyecto de modernización, tu plataforma de destino resulta que tiene 8 años de obsolescencia." Un programa de 3 años puede terminar en una plataforma que ya tiene 8 años desde su última versión mayor.

**Cómo abordarlo**: La elección de la plataforma de destino debe considerar no solo el estado actual sino el roadmap de la plataforma a 5–7 años. Los estándares abiertos (Jakarta EE, Spring, Kubernetes) tienen mejor longevidad que las plataformas propietarias. Considerar separar la "capa de modernización temporal" de la "arquitectura cloud-native final".

---

### 6.2 Mezcla de Estrategias Sin Governance Claro

**El reto**: Los programas de modernización bancaria raramente son una sola estrategia. En la práctica coexisten:
- **Migration lane**: Migrar sistemas existentes que deben seguir existiendo (el ledger contable)
- **Rebuild lane**: Construir sistemas nuevos desde cero para dominios donde el valor justifica el riesgo (medios de pago, base de clientes)
- **Retain/encapsulate**: API-fy sobre el mainframe sin mover nada

Sin governance explícito que determine qué sistema va a qué lane, los equipos toman decisiones inconsistentes que generan deuda técnica y conflictos de roadmap.

**Cómo abordarlo**: Definir explícitamente los criterios de clasificación por lane **antes** de iniciar la ejecución:
1. ¿Es batch de alto volumen y secuencial? → Migration (replatform primero, refactor después)
2. ¿Es online/transaccional stateless? → Migration o rebuild según volumen de cambio del negocio
3. ¿Tiene alto volumen de cambio de negocio? → Rebuild (el código legacy ya no representa el negocio actual)
4. ¿El driver es reducir MIPS ya? → Replatform da el ahorro sin el riesgo del rewrite

---

### 6.3 Decisiones de Negocio que Invalidan Decisiones Técnicas

**El reto**: Una decisión técnica bien fundamentada puede quedar obsoleta por una decisión de negocio. Si el banco decide adoptar una plataforma empaquetada para el destino (p.ej. un core banking SaaS con soporte de multidivisa), toda la arquitectura de migración puede cambiar.

**Evidencia de campo**: Un banco con una plataforma multidivisa en evaluación como destino alternativo enfrenta que si el negocio la adopta, el proyecto técnico de migración "cambia a sordo" — la decisión ya no es técnica sino de negocio, y puede beneficiar al banco aunque complique el programa de modernización.

**Implicación**: Los programas de modernización deben tener checkpoints de validación de supuestos de negocio. Una arquitectura de migración construida sobre supuestos de destino que luego cambian es arquitectura desperdiciada.

---

### 6.4 La Fragmentación de Dominios en Códigos Aplicativos

**El reto**: Los sistemas mainframe bancarios suelen organizar la funcionalidad en "códigos aplicativos" — módulos identificados por código que implementan partes de un mismo dominio de negocio. Un solo dominio puede tener 9 o más códigos aplicativos que históricamente evolucionaron de forma independiente.

**Evidencia de campo**: Un banco identificó que "cuentas personales" tiene 9 códigos aplicativos distintos. Si cada uno se migra como un servicio separado, el resultado es 9 microservicios que duplican lógica, comparten estado de forma implícita, y son difíciles de gobernar.

**Cómo abordarlo**: Antes de la migración, consolidar el dominio funcional. La regla fue: "lo que le voy a entregar al servicio de cuentas personales va a ser un código aplicativo — pero voy a dar 9 versiones del código." La consolidación funcional precede a la migración técnica.

---

## Capítulo 7 — Retos de Governance y Portfolio

### 7.1 El Problema de los 150 Sistemas

**El reto**: Los bancos Tier-1 con mainframe IBM z/OS raramente tienen solo uno o dos sistemas a modernizar. El inventario real suele incluir decenas o cientos de sistemas, con tecnologías diversas: COBOL, Java antiguo, VISAM-leasing, aplicaciones de terceros embebidas, sistemas de seguros, pensiones, fiduciarios, medios de pago, y más.

**Evidencia de campo**: Un banco con un portfolio de 150 sistemas legacy (COBOL, Java antiguo, y otras tecnologías) enfrentó la pregunta fundamental: ¿cómo se prioriza? ¿Qué entra primero? ¿Qué se puede dejar por ahora? ¿Qué nunca debería migrarse?

**Por qué es difícil**: No todos los sistemas tienen el mismo urgencia, riesgo, o valor de modernización. Algunos sistemas ("un tal Paquiño y un amigo suyo se le pegan hace 20 años y sigue el pie") llevan décadas estables y no son candidatos reales de modernización — aunque aparecen en el inventario.

**Cómo abordarlo**: Segmentar el portfolio antes de proponer un roadmap:
1. **Alta urgencia, alta complejidad**: Ledger contable, batch EOD (Proyecto Gamma equivalente)
2. **Alta urgencia, media complejidad**: Canales, servicios online ya en proceso
3. **Media urgencia, alta complejidad**: Sistemas SIVA (lógica de negocio en BD, no en código)
4. **Baja urgencia**: Sistemas estables, bajo cambio, sin presión de MIPS
5. **No modernizar**: Sistemas con bajo riesgo y bajo valor de modernización

---

### 7.2 La Falta de Destino Claro Como Bloqueante

**El reto**: Los programas que no definen un destino claro ("¿a dónde vas?") desde el inicio acumulan trabajo en la dirección equivocada.

**Evidencia de campo**: Un banco pasó meses analizando un sistema sin tener claridad sobre si el destino era una plataforma propia, una plataforma empaquetada, o una solución cloud-native. El análisis fue correcto; el destino estaba indefinido. Recursos invertidos en un roadmap que cambió cuando se definió el destino.

**Cómo abordarlo**: La primera pregunta de cualquier programa de modernización no es "¿cómo migro?" sino "¿a dónde migro?" y "¿por qué ese destino y no otro?" La respuesta debe estar documentada como un ADR (Architectural Decision Record) antes de iniciar el análisis técnico detallado.

---

### 7.3 Sistemas Detenidos — La Pérdida de Momentum

**El reto**: Los programas de modernización que no muestran valor rápido pierden momentum político. Un sistema que lleva meses en análisis sin resultado visible pierde el apoyo de los patrocinadores.

**Evidencia de campo**: Iniciativas de modernización de sistemas específicos (Fiduciarios) fueron lanzadas y luego se detuvieron: "no vemos claro." La falta de claridad sobre el enfoque, combinada con la complejidad del sistema, bloqueó el programa sin producir resultado alguno.

**Cómo abordarlo**: Definir el MVP de cada track de modernización. ¿Cuál es el primer resultado demostrable (no solo análisis)? Para batch: ¿cuál es el primer programa que corre en el nuevo ambiente con equivalencia comprobada? El valor demostrable es el antídoto contra la pérdida de momentum.

---

## Capítulo 8 — Retos Organizacionales

### 8.1 Ningún Proveedor Resuelve Todo El Problema Solo

**El reto**: Los programas de modernización mainframe atraen múltiples proveedores con capacidades complementarias. Ninguno tiene todo: el que convierte código a escala no tiene el expertise de performance; el que tiene el expertise bancario no tiene el volumen de conversión; el que tiene las herramientas de IA no tiene el conocimiento del sistema original.

**Evidencia de campo**: Un banco gestionó simultáneamente conversión determinística masiva, agentes de IA de conversión, herramientas de modernización de Holding/España, y el conocimiento de quien construyó el sistema original. "Un solo proveedor, empresa, no me puede resolver todo — si se asociaban entre ellos, la propuesta no necesariamente es uno."

**Implicación para Accenture**: El posicionamiento correcto no es "hacemos todo" — es "somos el integrador que sabe qué herramienta usar en qué momento, y tenemos el conocimiento del sistema original que ningún otro tiene."

---

### 8.2 El Sesgo del Optimismo

**El reto**: Los programas de modernización bancaria son sistemáticamente más difíciles de lo que se anticipa. Los equipos (cliente y proveedores) tienden al optimismo en la estimación inicial.

**Evidencia de campo**: "En toda la cadena éramos todos optimistas hasta que llegamos al final." No es anecdótico — es un patrón observado consistentemente: el análisis parece manejable, los primeros módulos funcionan, y luego el penúltimo paso revela complejidad no anticipada (infraestructura no lista, sistema de destino obsoleto, lógica de negocio no documentada en JCL).

**Mitigación**: Incorporar explícitamente tiempo de "descubrimiento de complejidad oculta" en el plan. Suponer que el 20–30% adicional de esfuerzo aparecerá en los stages finales de cada módulo, no en los primeros.

---

### 8.3 El Requerimiento de 100% Automatizado — La Tensión Político-Técnica

**El reto**: El cliente quiere conversión 100% automatizada — un proceso donde un desarrollador humano no toca el código convertido. La justificación es velocidad y reproducibilidad. El problema técnico: para el bloque de contabilidad (alta criticidad, COMP-3, lógica en JCL), la conversión 100% automatizada que también tiene performance aceptable no existe todavía.

**Evidencia de campo**: "Quiero hacer un proceso de conversión al cien por cien — un programa que yo pico sin que nadie lo toque, tiene que funcionar perfecto." Esta expectativa choca con la realidad de que los 25+ patrones de reimplementación (Capítulo 3.3) requieren decisiones de diseño que el automatismo actual no puede tomar.

**La tensión real**: La automatización es correcta para la conversión del código de lógica de negocio (el problema que los agentes de IA resuelven razonablemente). No es correcta aún para la re-ingeniería del modelo de ejecución del batch (el problema de performance).

**Cómo manejarlo**: Separar conceptualmente lo que se puede automatizar (conversión de lógica, generación de scaffolding, verificación de equivalencia funcional) de lo que requiere decisión de diseño experto (modelo de ejecución del batch, patrones de I/O, paralelismo). Presentar la automatización como un continuo, no un binario.

---

### 8.4 La Infraestructura Que Se Olvidó

**El reto**: Los programas de modernización mainframe se enfocan en el código y la arquitectura lógica. La infraestructura de staging (ambientes de desarrollo, testing, parallel-run) suele subestimarse o dejarse para después.

**Evidencia de campo**: "A alguien se le olvidaron los ambientes y la infraestructura." Un equipo que terminó la primera etapa de conversión se encontró bloqueado porque los ambientes para probar no estaban listos. La infraestructura es parte del programa — no un detalle de implementación.

**Cómo abordarlo**: El plan de infraestructura (ambientes, pipelines de CI/CD, herramientas de equivalencia, acceso a datos de prueba) debe planificarse en paralelo con el plan técnico, no como un paso posterior.

---

### 8.5 El Conocimiento del Builder vs. El Conocimiento del Converter

**El reto**: El proveedor que construyó el sistema original tiene un conocimiento estructural del que ningún convertidor externo dispone: sabe qué hace cada módulo, qué reglas de negocio están embebidas en qué programa, y dónde están los puntos de riesgo. Este conocimiento reduce dramáticamente el esfuerzo de Reverse Engineering.

**Evidencia de campo**: Un convertidor externo (Kyndryl) pasó 8 meses sin entender la causa raíz del problema de performance en el bloque de contabilidad. El equipo que construyó el sistema puede identificar la causa en semanas — porque sabe cómo funciona el modelo de I/O original, cómo está organizado el procesamiento de asientos, y qué hace el JCL.

**Cuantificación**: La asimetría de conocimiento del builder representa una reducción del 40–60% en el esfuerzo de Reverse Engineering vs. un competidor externo.

---

## Capítulo 9 — Retos de Conocimiento y Talento

### 9.1 Nadie Conoce Todo el Código

**El reto**: Los sistemas mainframe bancarios de más de 20 años de antigüedad tienen documentación incompleta, desarrolladores originales que ya no trabajan en la organización, y lógica de negocio acumulada que nadie tiene en mente de forma completa.

**Evidencia de campo**: Un banco con 136 millones de líneas de código de COBOL en GitHub no tiene ningún individuo que conozca completamente el sistema. El conocimiento está distribuido y parcializado.

**Implicación**: El Reverse Engineering no es un paso previo al proyecto — es una disciplina continua durante todo el programa. Cada módulo que se migra requiere un ciclo completo de RE antes de la conversión.

---

### 9.2 Los SMEs de Negocio Son Un Gate Obligatorio

**El reto**: La lógica de negocio bancaria (cálculo de interés, reglas de liquidación, condiciones de moratorio) no puede inferirse solo del código COBOL. El agente o desarrollador que no tiene acceso a un SME de negocio tomará decisiones incorrectas sobre la semántica de los programas.

**Por qué**: El nombre de la variable COBOL describe lo que el desarrollador original creyó que significaba — no necesariamente lo que el negocio espera. Las reglas cambian con el tiempo; el código puede estar desactualizado respecto a la política actual, o viceversa.

**Cómo abordarlo**: Incluir un SME de negocio bancario en el review de cada componente migrado, específicamente para validar las fórmulas financieras, los criterios de clasificación de asientos, y las reglas de cierre. No es un paso opcional para el ledger contable.

---

### 9.3 La Deuda Técnica Acumulada Es Mayor de Lo Visible

**El reto**: Los sistemas mainframe de 20+ años tienen capas de parches, workarounds, y lógica duplicada que el análisis inicial no detecta. La deuda técnica "aparece" cuando se intenta migrar.

**Evidencia de campo**: El proceso de carga del código a GitHub reveló duplicación de código aplicativo que nadie había notado. La migración forzó la consolidación de módulos que existían como duplicados por razones históricas que nadie recordaba.

**Cómo abordarlo**: Incluir un paso de análisis de deuda técnica (static analysis, detección de código duplicado) antes de iniciar la conversión. Las decisiones de consolidación son decisiones de arquitectura — tomarlas antes de la migración, no durante.

---

## Capítulo 10 — Retos Regulatorios

### 10.1 Parallel-Run Obligatorio — No Es Opcional Ni Corto

**El reto**: En México (CNBV, Banxico) y en la mayoría de las jurisdicciones bancarias, cualquier cambio en el sistema de registro contable requiere un período de operación paralela entre el sistema legacy y el sistema nuevo, antes de poder hacer el cutover definitivo.

**Implicación de duración**: El parallel-run para un ledger contable bancario no es de días ni semanas — puede ser de meses. Durante ese período, ambos sistemas deben procesar y producir resultados idénticos, con reconciliación diaria.

**Costo del parallel-run**: El banco opera el doble de infraestructura, el doble de capacidad operativa, y mantiene procesos de reconciliación continuos. Este costo debe estar en el business case desde el inicio.

**Cómo abordarlo**: Diseñar el parallel-run como parte del plan desde el primer día, no como un afterthought regulatorio. Definir los criterios de equivalencia que terminan el parallel-run (p.ej. ≥99.99% de equivalencia por N días consecutivos sin incidentes).

---

### 10.2 Certificaciones de Pagos — SPEI, CECOBAN, y Equivalentes

**El reto**: Los sistemas bancarios que procesan pagos interbancarios (SPEI en México, SEPA en Europa, etc.) están integrados con infraestructura regulada. Cualquier cambio arquitectónico en el sistema que genera o procesa mensajes SPEI requiere certificación con el regulador (Banxico en México).

**Implicación**: La certificación de pagos no se puede hacer "al final" del programa — tarda meses y debe planificarse con el regulador desde las etapas tempranas. El regulador tiene su propio calendario; el programa debe adaptarse.

---

### 10.3 La Contabilidad Como Dominio de Máxima Criticidad Regulatoria

**El reto**: El libro mayor contable (ledger) es el registro oficial de las operaciones del banco. Cualquier discrepancia entre el sistema legacy y el sistema migrado durante el parallel-run es un hallazgo de auditoría, no un bug a corregir silenciosamente.

**Implicación de la equivalencia**: La tolerancia de error es prácticamente cero para el ledger. La equivalencia ≥99.99% registro-a-registro no es un objetivo aspiracional — es el mínimo requerido para cumplir con los estándares contables bancarios y pasar la auditoría del CNBV.

**Cómo abordarlo**: Definir el criterio de equivalencia contable como gate de salida de la fase de testing, antes de habilitar el parallel-run. El criterio debe ser revisado y aprobado por el área de Control Interno del banco.

---

## Checklist Rápido — Gate de Calidad Pre-Entrega de Componente Migrado

Aplicar antes de declarar cualquier componente COBOL→Java listo para parallel-run:

**Correctitud**
- [ ] Fórmulas financieras verificadas línea a línea contra el COBOL original (no contra documentación genérica)
- [ ] Toda lógica de JCL con utilerías documentada como regla de negocio explícita, aprobada por SME bancario
- [ ] REDEFINES implementados como Union/BitBuffer con tests para cada layout
- [ ] STRING/UNSTRING/INSPECT con helpers Java verificados en casos borde
- [ ] LOW-VALUES/HIGH-VALUES con constantes byte explícitas — sin traducción a null/empty
- [ ] Ordenamientos JCL implícitos documentados y replicados antes del match
- [ ] Datos de prueba transformados de COMP-3 a formato Java antes de ejecutar equivalencia
- [ ] Equivalencia de output ≥ 99.99% registro a registro

**Performance**
- [ ] Procesamiento batch en modo chunk/streaming — prohibido row-by-row JDBC para volúmenes > 10K registros
- [ ] Writer en modo bulk (executeBatch / COPY) — prohibido INSERT/UPDATE fila por fila
- [ ] Catálogos de referencia cargados en memoria una vez — prohibido query por registro
- [ ] SORT/JOINKEYS reimplementados como merge-join o push-down SQL — prohibido nested-loop O(n²)
- [ ] Ratio de tiempo COBOL vs. Java medido y dentro de ventana batch (objetivo: < 3:1; máximo tolerable: 5:1)
- [ ] Batch corriendo en tier dedicado separado del tier online transaccional
- [ ] BigDecimal con escala/RoundingMode idénticos al COBOL — prohibido double para campos monetarios

**Arquitectura**
- [ ] Equivalencias IBM-utility catalogadas y probadas: SORT, JOINKEYS, COUNT, SKIP, NODUP, EDIT
- [ ] Paralelismo implementado como partitioning por rangos independientes (no multi-threaded sobre registros con dependencia de orden)
- [ ] Infraestructura de parallel-run definida y lista

---

## Matriz de Diagnóstico Rápido — Síntoma → Causa

| Síntoma observado | Causas candidatas (orden de probabilidad) |
|-------------------|-------------------------------------------|
| Degradación proporcional al volumen (10×–100×) | N+1, catálogos recargados, escritura fila por fila |
| Red saturada bajo carga batch | N+1, batch forzado a microservicios distribuidos |
| CPU al 100% sin I/O alto | Aritmética BigDecimal, GC, serialización JSON |
| Muchos queries a BD | N+1, ORM en batch, catálogos sin caché |
| Mucho tráfico interno entre servicios | Batch descompuesto en microservicios |
| Pausas periódicas | GC por object churn |
| Resultados incorrectos (no solo lentos) | double en lugar de BigDecimal, ordenamiento implícito no replicado |
| Ordenamientos/joins muy lentos | SORT software vs. hardware, JOINKEYS como nested-loop |
| Lento solo en la primera corrida | JVM sin warmup (batchs cortos sin GraalVM native) |
| Deadlocks / esperas en BD | Connection pool subdimensionado, lock escalation |

---

*Última actualización: 2026-07-08 · v1.0 · KB inicial — síntesis de experiencia real en engagement bancario (Proyecto Gamma + análisis técnico HVM). Cubre 10 dimensiones de retos: performance batch, conversión, equivalencia, datos, arquitectura, portfolio, organización, conocimiento, y regulatorio.*
# Propuesta de arquitectura en AWS para la flota de gemelos cognitivos

> Proyecto: BanCoppel Application Modernization, `SPE-AM-001`
> Alcance: mover el almacén de los cerebros de SQLite a PostgreSQL administrado y ejecutar los Digital Twins en funciones Lambda.
> Estado: propuesta para revisión. No hay nada desplegado.
> Diagrama: `blueprint-arquitectura-bancoppel-aws-2026-11-25.html`, generado por `generators/build-aws-blueprint.py`.

---

## 1. Punto de partida, medido

El inventario no es una estimación; lo cuenta el generador del diagrama cada vez que corre, recorriendo el árbol del proyecto.

| Dimensión | Hoy |
|---|---|
| Cerebros SQLite | 37 archivos `brain.db`, 103 MB en total |
| Tablas | 609 |
| Filas | 509,639 |
| Concentración | Informix aporta 444,239 filas, el 87 por ciento del total, en un archivo de 86 MB |
| Gemelos digitales declarados | 63, entre carpetas con carta de identidad y markdown sueltos en `dt/` |
| Documentos de conocimiento | 907 markdown bajo `knowledge-base/` |
| Generadores | 199 scripts de Python |
| Páginas de portal generadas | 359 |
| Interfaz de consulta | `brain.py` con 43 consultas públicas en Informix, 42 en `bank-brain.py` |
| Búsqueda | 5 tablas virtuales FTS5 solo en el cerebro de Informix |

Tres límites del arreglo actual justifican el movimiento, y conviene nombrarlos con precisión porque son los que la arquitectura tiene que resolver.

El primero es el techo de federación. SQLite viene compilado con `SQLITE_MAX_ATTACHED = 10` y ese valor no se puede subir en tiempo de ejecución. Con 37 cerebros, la Regla B4 ya no cabe en una conexión, de modo que `bank-brain.py` recorre la flota en lotes de nueve y agrega en Python lo que debería ser un `UNION` de SQL. Funciona, pero convierte una consulta en un programa.

El segundo es la heterogeneidad silenciosa. Conviven tres formas de declarar una dependencia entre sistemas, y antes de que la federación armara la consulta por cerebro, los tres que más aristas declaran quedaban fuera sin avisar. Un esquema compartido con vistas explícitas convierte ese problema en algo que se declara en el modelo en vez de resolverse en cada lectura.

El tercero es el modo de ejecución de los gemelos. Un Digital Twin es una declaración en texto que hoy alguien ejecuta a mano en una sesión de su laptop. No hay concurrencia, no hay registro de qué se preguntó, no hay costo medido por corrida, y el resultado de un enjambre depende de que la persona coordine bien diez conversaciones.

---

## 2. Decisión 1: el almacén

### Qué servicio

**Aurora PostgreSQL Serverless v2 con escalado a cero**, una sola base de datos, un clúster. La alternativa seria es una instancia pequeña de RDS PostgreSQL encendida todo el tiempo, y conviene decir con franqueza que para 103 MB de datos las dos sirven.

La razón para preferir Aurora Serverless v2 no es el tamaño sino la forma de la carga: ráfagas cortas de consultas cuando alguien trabaja, silencio durante horas, y picos largos cuando corre una reconstrucción. Una instancia fija paga el silencio. El escalado a cero lo evita, al precio de unos segundos de arranque en la primera consulta tras el reposo, que para este uso es irrelevante.

La segunda razón pesa más que la primera: Aurora ofrece la **API de datos**, un punto de acceso por HTTP con autenticación de IAM. Eso permite que las funciones Lambda consulten la base sin vivir dentro de la red virtual, sin un servidor de conexiones intermedio y sin el problema clásico de agotar el grupo de conexiones cuando cien invocaciones concurrentes abren cien sesiones de PostgreSQL. Con RDS, resolver lo mismo exige RDS Proxy, que cuesta más que la base de datos misma en este tamaño.

Si el proyecto termina exigiendo que todo tráfico quede dentro de la red virtual por política del engagement, la arquitectura no cambia de forma: las funciones entran a subredes privadas y se agregan puntos de enlace de PrivateLink para los servicios que usen. Es una decisión de postura de seguridad, no de diseño de datos, y se puede tomar después.

### Cómo se organiza la base

Una base de datos, **un esquema por cerebro**, más tres esquemas de servicio.

```
bcop_brain
├── informix, appmovil, siweb, bus, e_global, interact, control_m, ... (37 esquemas)
├── bank_brain         el cerebro federado del programa
├── registry           qué cerebro es cuál, su versión y su fecha de construcción
├── federation         vistas que normalizan lo heterogéneo
└── ops                bitácora de consultas, corridas de enjambre y costo
```

Con esto, cruzar dos cerebros deja de ser una maniobra sobre archivos y se vuelve `SELECT ... FROM informix.sps JOIN e_global.codret ...`. El techo de diez desaparece por construcción, no por un recorrido por lotes.

`registry.brains` guarda el identificador que **declara el cerebro en su propio `system_info.slug`**, nunca el nombre de la carpeta. Esa distinción ya costó caro una vez: la carpeta dice `CajeroATM` y el sistema se llama `cajero-atm`, la carpeta dice `EGlobal` y el sistema se llama `e-global`. Indexar por carpeta rompe el cruce con los nodos de dependencias.

`federation` resuelve el problema de los tres esquemas de `cross_dependencies` con una vista por forma y una vista canónica que las une:

```sql
CREATE VIEW federation.dependencies AS
  SELECT slug, other_system, relationship, direction, evidence, 'b12' AS forma
    FROM federation.deps_b12
  UNION ALL
  SELECT slug, other_system, dependency_type, direction, evidence, 'previa'
    FROM federation.deps_previas
  UNION ALL
  SELECT slug, target_system, 'calls', 'outbound', evidence, 'appmovil'
    FROM federation.deps_appmovil;
```

Lo que no se pueda mapear queda registrado en `federation.excepciones` con su motivo. Una lectura que no se puede hacer tiene que aparecer como excepción, no como ausencia.

### Búsqueda de texto

Las tablas virtuales de FTS5 no tienen equivalente directo. Se traducen a columnas generadas de tipo `tsvector` con índice GIN, usando la configuración en español y la extensión `unaccent` para que "crédito" y "credito" encuentren lo mismo:

```sql
ALTER TABLE informix.sps
  ADD COLUMN busqueda tsvector
  GENERATED ALWAYS AS (
    to_tsvector('spanish', unaccent(coalesce(business_name,'') || ' ' || coalesce(cuerpo,'')))
  ) STORED;
CREATE INDEX ON informix.sps USING GIN (busqueda);
```

Se agrega `pg_trgm` para la coincidencia aproximada sobre nombres de procedimiento y prefijos húngaros, que es un caso real de este proyecto y que FTS5 nunca resolvió bien.

Y se agrega `pgvector` para indexar los 907 documentos de conocimiento. Eso tiene una consecuencia práctica: el patrón de asistente conversacional que se usó en Banamex necesitaba un servicio externo de vectores, y aquí deja de hacer falta. Un solo almacén guarda la estructura, el texto y los vectores.

### Separar lo interno de lo que ve el cliente

Esta base va a contener dos clases de conocimiento que hoy conviven en archivos pero que no pueden convivir en un servicio con varios lectores. Por un lado el análisis del AS-IS, que es del programa. Por otro el destino de migración de cada procedimiento y las posturas de cada participante extraídas de las minutas, que son análisis interno de Accenture dentro de un programa donde **EY es competidor**.

La separación se implementa con seguridad a nivel de fila sobre las tablas sensibles, con dos roles de base de datos y una columna de clasificación. No es un refinamiento posterior: es condición de entrada para poner esta base en un servicio compartido.

---

## 3. Decisión 2: construir el cerebro no es consultarlo

La ingesta corre en **tareas de ECS Fargate**, no en Lambda, y la razón es cuantitativa. El cerebro de Informix analiza 11,391 procedimientos y produce 200,761 referencias de tabla; esa corrida no cabe en los quince minutos de una función ni en su almacenamiento temporal de forma confiable. Las corridas de los otros treinta y seis cerebros sí cabrían, pero no tiene sentido mantener dos caminos para lo mismo.

La fuente vive en S3 con versionado y cifrado. EventBridge dispara la reconstrucción cuando entra fuente nueva o por calendario. CodeBuild corre los 199 generadores y publica las 359 páginas del portal.

La idempotencia se conserva tal como está hoy. Cada `build-brain.py` recibe un parámetro de reinicio y reescribe su propio esquema dentro de una transacción. El cambio que hay que hacer en el código es acotado y vale la pena nombrarlo: la capa de conexión deja de ser `sqlite3` directo y pasa a un adaptador delgado. No es una reescritura del pipeline, es un cambio en la función que abre la conexión y en las pocas sentencias que usan sintaxis específica de SQLite.

**La migración no se hace volcando los archivos, se hace apuntando el constructor a PostgreSQL.** El cerebro es reproducible desde la fuente, así que el camino limpio es reconstruirlo en el destino y comparar. El volcado directo queda como red de seguridad para verificar, no como método.

---

## 4. Decisión 3: los gemelos en Lambda

### Una función, no sesenta y tres

El instinto es hacer una función por gemelo. Sería un error: sesenta y tres unidades de despliegue, sesenta y tres roles de permisos y sesenta y tres arranques en frío para ejecutar exactamente el mismo código.

Un gemelo digital no es un programa, es una declaración. Tiene una carta de identidad, un cuerpo de conocimiento y un conjunto de consultas que sabe hacer. Entonces la plataforma necesita **una función de ejecución de gemelos** que reciba el identificador, cargue su declaración desde S3 o desde la base, arme su cinturón de herramientas y actúe.

```
POST /dt/{dt_id}/consulta
   la función carga dt-reglas, su carta y sus herramientas
   razona con el modelo
   llama a la función de consulta cuando necesita un dato
   devuelve la respuesta con la procedencia de cada dato citado
```

### La segunda función es la que habla con la base

`brain-query` expone las 43 consultas publicadas de `brain.py` como herramientas invocables. Es la única que tiene credenciales de base de datos, lo que concentra el control de acceso en un solo lugar y permite registrar en `ops` qué consulta pidió qué gemelo y para quién.

Esta función es también lo que se expone como servidor de Protocolo de Contexto de Modelo, para que las sesiones de trabajo en la laptop sigan funcionando igual que hoy pero contra la nube. Eso importa más de lo que parece: la adopción de esta plataforma depende de que la forma de trabajo actual no se rompa el primer día.

### El enjambre lo coordina Step Functions

La metodología de extracción reparte el trabajo en agentes con diez reglas cada uno y junta los resultados. Ese patrón de abanico con control de concurrencia, reintento y recolección es exactamente un mapa distribuido de Step Functions. Hacerlo con una función orquestadora obliga a llevar el estado a mano y muere al minuto quince.

Una cola de SQS entre la puerta de entrada y el enjambre absorbe las ráfagas y da cola de descartes. El registro de enriquecimiento que ya existe en los scripts de la capa estratégica se mueve a una tabla de `ops`, de modo que un enjambre interrumpido se reanuda sin repetir trabajo.

### El modelo

Bedrock, con una nota de experiencia del patrón anterior: los modelos Claude en Bedrock requieren un formulario de caso de uso en la consola, mientras que Nova Pro no lo requiere. La recomendación es levantar ese trámite en la primera semana del proyecto y declarar a Nova Pro como salida si no se aprueba a tiempo, para que la fase de gemelos no quede bloqueada por un papel.

---

## 5. Decisión 4: acceso y portal

Las 359 páginas se siguen generando desde el cerebro, como manda la regla. Lo que cambia es que las produce CodeBuild contra PostgreSQL en vez de un script contra un archivo local, y que se entregan por CloudFront con control de acceso al bucket en vez de por un servidor local.

Se agrega identidad con Cognito. Un portal con el mapa de dependencias del banco, sus reglas de negocio y su registro de riesgos no puede quedar en una dirección pública sin autenticación, que es lo que hoy ocurre con los portales publicados en S3 estático.

Se agrega también una ruta dinámica: la puerta de entrada de API conecta el portal con la función de consulta, de modo que una página pueda preguntar en vivo en vez de leer un JSON horneado en el momento de la construcción. Eso habilita vistas que hoy no son prácticas, como filtrar las 200,761 referencias de tabla sin generar un archivo por combinación.

---

## 6. Seguridad y gobierno

| Qué | Cómo |
|---|---|
| Cifrado | Llave propia de KMS para la base, los buckets y los registros |
| Credenciales | Autenticación de IAM contra Aurora, sin contraseña en código; Secrets Manager para lo que no la admita |
| Red | Subredes privadas para la base; sin dirección pública; puntos de enlace de PrivateLink si las funciones entran a la red virtual |
| Quién consultó qué | CloudTrail con eventos de datos, más la bitácora propia en `ops` |
| Separación de conocimiento | Seguridad a nivel de fila con dos roles, por la presencia de un competidor en el programa |
| Respaldo | Instantáneas automáticas y recuperación a un punto en el tiempo de siete días |
| Cuenta | Cuenta dedicada del engagement. La cuenta personal 909212333016 sirve para probar el patrón, no para alojar conocimiento del cliente |

---

## 7. Costo mensual estimado

Cifras de referencia para us-east-1, en el orden de magnitud de un entorno de trabajo de un equipo de arquitectura.

| Concepto | Estimado | Supuesto |
|---|---|---|
| Aurora PostgreSQL Serverless v2 | 15 a 40 dólares | Escalado a cero en reposo, unas pocas horas diarias a una unidad de capacidad |
| Alternativa con RDS t4g.small | 25 a 30 dólares | Encendida todo el tiempo, más 20 GB de almacenamiento |
| Lambda, Step Functions y SQS | menos de 5 dólares | Volumen de un equipo, no de una carga productiva |
| Fargate para la ingesta | menos de 5 dólares | Corridas esporádicas de minutos |
| S3 y CloudFront | menos de 5 dólares | 103 MB de fuente, portal estático, tráfico interno |
| Modelo de lenguaje en Bedrock | Variable, el renglón a vigilar | Depende del volumen de enjambres |

La infraestructura suma del orden de 50 a 70 dólares al mes, comparable con lo que esa cuenta ya gasta hoy. **El renglón que puede sorprender es el consumo del modelo**: un enjambre de diez agentes sobre un corpus grande cuesta en una corrida más que la infraestructura en un mes. El control de presupuesto va ahí, con medición por corrida desde la primera semana y un tope declarado por proyecto.

---

## 8. Plan de migración

Cada fase cierra con una comprobación que se ejecuta, no con una opinión.

| Fase | Alcance | Duración | Criterio de corte |
|---|---|---|---|
| 1. Piloto | `bank-brain`, 14,992 filas, con la API de datos y un gemelo funcionando | 2 semanas | Paridad de filas tabla por tabla y cinco consultas que devuelvan lo mismo que hoy |
| 2. Flota | Los 36 cerebros restantes, con Informix al final | 4 a 6 semanas | `capability_gap()` federado devuelve 198, el mismo número que la federación por lotes |
| 3. Gemelos | Ejecución genérica, cinturón de herramientas y tres enjambres en operación | 4 semanas | Un enjambre reproduce un resultado ya conocido, con la misma procedencia |
| 4. Acceso | Construcción del portal, entrega con identidad, seguridad a nivel de fila y bitácora | 3 semanas | Un usuario sin permiso no ve las tablas internas, y el intento queda registrado |

El orden importa. Informix va al final de la fase 2 no por dificultad técnica sino porque concentra el 87 por ciento de las filas: cuando llegue, el camino ya está probado con treinta y seis cerebros de bajo riesgo.

---

## 9. Riesgos

**El orden de los resultados de búsqueda va a cambiar.** FTS5 y `tsvector` no puntúan igual. Las consultas que hoy devuelven los primeros veinte resultados por relevancia van a devolver otro orden, y eso no se detecta contando filas. Hay que fijar un conjunto de consultas de referencia con su resultado esperado antes de migrar, y recalibrar contra él.

**Un solo cerebro concentra el riesgo del corte.** El plan de corte es, en la práctica, el plan de corte de Informix.

**Lo interno y lo del cliente quedan en la misma base.** Con un competidor dentro del programa, la seguridad a nivel de fila no es una mejora opcional.

**El acceso al modelo tiene trámite.** Conviene levantarlo en la primera semana.

**Aparece gobierno donde hoy hay un archivo.** Un archivo en una carpeta sincronizada no tiene credenciales que rotar ni ventanas de mantenimiento. Un servicio sí. Es una ganancia, pero cuesta trabajo operativo que hoy no existe y conviene decirlo desde el principio en vez de descubrirlo en el tercer mes.

---

## 10. Lo que falta decidir

Tres puntos cambian el diseño según la respuesta, y ninguno se puede resolver desde el código.

La cuenta de AWS donde vive esto: si es una cuenta del engagement con las políticas del cliente o una cuenta de Accenture para el equipo de arquitectura. De eso depende si las funciones entran a la red virtual desde el primer día o si la API de datos es suficiente.

Quién consulta el portal: solo el equipo de Accenture, o también personas de BanCoppel. Si entran personas del banco, la seguridad a nivel de fila y la clasificación del conocimiento pasan de la fase 4 a la fase 1.

Si esto es una plataforma del proyecto o un activo reusable. Hoy el árbol de BanCoppel tiene 37 cerebros, pero existen Banamex, Liverpool, MONEX, AXA y los demás con la misma estructura. Si la intención es que la plataforma sirva a todos, el esquema por cerebro se convierte en esquema por cliente y por cerebro, y conviene decidirlo antes de escribir el primer `CREATE SCHEMA`, no después.

---

*Propuesta escrita el 2026-11-25. El inventario se recalcula en cada corrida de `generators/build-aws-blueprint.py`; las cifras de este documento corresponden a esa fecha.*

# DT — Observabilidad y Capacidad Forense

> **Proyecto**: BanCoppel Application Modernization, `SPE-AM-001`
> **Digital Twin**: `dt-observabilidad/` — Gemelo de lo que el sistema puede y no puede contar sobre sí mismo
> **Versión**: 0.1.0, 2026-10-09
> **SME heredado**: IT Operating Model (`SME/Framework/IT Operating Model/`)
> **Brain propietario**: `digital-brain/brain.db` (tablas propuestas: `obs_coverage`, `obs_gaps`)

---

## Identidad y Propósito

Soy el **Digital Twin de Observabilidad**. No analizo incidentes: analizo **la capacidad del sistema para que un incidente sea analizable**. Mi objeto de estudio es el conjunto de registros, su retención, su alcance y sus puntos ciegos.

Este DT nace de una constatación incómoda del incidente del 8 de octubre de 2026. La ventana crítica, de 12:44 a 12:55, no estaba en el log de depuración del gestor de clúster cuando se recolectó la evidencia: ese archivo rota cada veintiocho segundos y conserva, entre todas sus copias, poco más de tres minutos de historia. La reconstrucción fue posible solo porque el historial de eventos y la salida de scripts sí persisten. De haber dependido del log de depuración, el incidente habría sido irreconstruible.

**Principio rector**: la retención efectiva de un registro, no su existencia, determina si un incidente podrá explicarse. Un log que rota más rápido que el tiempo de detección humana no es observabilidad, es decoración.

---

## SME Heredado

| SME | Ruta | Qué aporta |
|-----|------|-----------|
| IT Operating Model | `SME/Framework/IT Operating Model/` | Encuadre de Service Operations, definición de SLO y práctica de monitoreo |

---

## Inventario de Cobertura (evidencia 2026-10-08, clúster DCMSIF)

| Fuente | Retención efectiva | Veredicto |
|--------|--------------------|-----------|
| `adm/history/cluster.MMDDYYYY` | Un archivo por día, histórico | Adecuada. Fuente canónica de línea de tiempo |
| `log/hacmp.out` | 356,283 líneas, de abril de 2023 a octubre de 2026 | Adecuada. Aquí vive la causa de los fallos |
| `availability/clavailability.log` | Desde 2021, con resolución de milisegundos | Adecuada y subutilizada |
| `log/clstrmgr.debug` más 7 rotaciones | 24 a 28 segundos por archivo, **3 min 17 s en total** | **Insuficiente** para análisis forense por sí sola |
| Paquetes FFDC `.pax.Z` | Copia congelada en el instante del fallo. Conservan `clstrmgr.debug` de 12:40:54 a 12:50:59 y la familia `.long` de 12:23:15 a 12:50:58 | **Adecuada.** Es lo que rescató la ventana que el log activo ya había rotado |
| `adm/cluster.log` del nodo que actuó | Dejó de escribirse el 8-oct a las 03:04:16, casi diez horas antes del incidente | **Punto ciego** |
| `errpt` capturado por FFDC | Con año explícito, cubre de 04:30 a 12:51 del día | Adecuada |
| `log/clutils.log` | `clfileprop` cada diez minutos | Adecuada. Acota cortes de comunicación entre nodos |
| Evidencia del nodo declarado caído | **Inexistente** | **Brecha crítica** |
| nmon | Existe para una máquina de otro clúster. 788 de 1,440 muestras, corte a las 13:12 | **No aplicable al incidente** |
| Captura `clverify.2026.10.08.*` | Arrastra un ERROR de 2019; no es una verificación del día | Engañosa. No usar como hallazgo |

---

## Brechas Detectadas

**OBS-G01 — La recolección mezcló dos clústeres y nadie lo advirtió.**
El paquete entregado contiene artefactos del clúster `DCMSIF`, que es el que falló, y del clúster `DCMSIF01_cluster`, que no participó. Las carpetas están rotuladas por dirección IP, lo que indujo a tratarlas como dos nodos del mismo clúster. Cuatro conclusiones del primer análisis se construyeron sobre esa confusión antes de detectarla. Es la brecha de mayor impacto: no es falta de datos, es datos correctos mal atribuidos.

**OBS-G02 — No existe evidencia del nodo declarado caído.**
Del nodo DCMSIF01 del clúster DCMSIF no hay un solo archivo. El incidente completo está documentado por el nodo que decidió, que es la parte interesada. Un procedimiento de recolección debe exigir ambos lados por identidad de clúster, no por etiqueta de carpeta.

**OBS-G03 — El log de depuración del gestor de clúster rota en 28 segundos.**
Ocho archivos cubren 3 minutos 17 segundos. El log activo nunca servirá para un análisis forense que empiece más de cuatro minutos después del evento. Lo rescatable vino del paquete FFDC, no del log vivo.

**OBS-G04 — El `cluster.log` del nodo que actuó dejó de escribirse diez horas antes.**
Su última entrada del 8 de octubre es de las 03:04:16 y el incidente fue a las 12:44. En la captura de procesos conviven `syslogd` y `rsyslogd`, lo que sugiere dos demonios de syslog compitiendo. El efecto práctico es que la fuente que un operador consultaría primero estaba muda.

**OBS-G05 — `/var` opera permanentemente en su umbral de alerta.**
`CL_VAR_FULL` al 75% sobre umbral 75% se dispara con recurso CAA, dos veces solo el 8 de octubre. Una alerta que suena todos los días deja de ser alerta, y el propio mensaje advierte que RSCT puede fallar si `/var` se llena.

**OBS-G06 — La captura FFDC se genera y no se consume.**
PowerHA produjo automáticamente `eventlogs.2026.10.08.12.50.59.pax.Z` y `eventlogs.2026.10.08.12.55.12.pax.Z` en el instante de los fallos, y son la única fuente que conservó el razonamiento interno del gestor durante la partición. No formaban parte de la evidencia solicitada inicialmente. Se abren con `gzip -dc` seguido de `tar -xf`; no hace falta `pax`.

**OBS-G07 — `cluster.log` es una trampa de atribución de año.**
El archivo es acumulativo desde 2019 y el formato syslog de AIX no escribe el año. Filtrar por `Oct  8` devuelve entradas de 2023, 2024 y 2026 mezcladas. El sello interno de `clstrmgrES` dentro de cada línea sí lleva año y es el dato fiable. En el primer análisis esto produjo una ventana de mantenimiento inexistente.

**OBS-G08 — Capturas de diagnóstico que arrastran material obsoleto.**
El archivo `clverify.2026.10.08.12.50.59` no es una verificación de ese día: es un resumen que recoge líneas de rotaciones antiguas, y su único ERROR procede de un archivo de junio de 2019. Leerlo como hallazgo del incidente es un error inducido por el propio nombre del archivo.

**OBS-G09 — No hay telemetría de ninguno de los dos nodos del clúster que falló.**
El único nmon disponible pertenece a una máquina de otro clúster. Del clúster DCMSIF no hay CPU, red, disco ni procesos.

---

## Reglas de Diagnóstico

**OBS-R01 — Medir retención efectiva, no existencia.**
Para cada fuente, calcular el lapso real que cubre el conjunto de archivos conservados. Comparar contra el tiempo típico de detección y escalamiento. Si la retención es menor, la fuente no sirve para análisis forense.

**OBS-R02 — Toda recolección debe cubrir ambos nodos y sellar el origen por identidad de clúster.**
El procedimiento debe capturar `HACMPcluster.name`, `HACMPcluster.id`, hostname, LPAR y marca de tiempo del propio nodo. Nunca confiar en el nombre de la carpeta ni en la dirección IP con que se rotula.

**OBS-R05 — Ningún log sin año es fuente primaria de fecha.**
Cuando un archivo use formato syslog sin año, anclar siempre contra un sello interno con año o contra un archivo de historial fechado. Esto aplica a `cluster.log` y a cualquier log de AIX con el mismo formato.

**OBS-R06 — Un nombre de archivo con fecha no garantiza que el contenido sea de esa fecha.**
Las capturas automáticas pueden resumir material histórico. Verificar el contenido antes de atribuirlo al incidente.

**OBS-R03 — Una alerta que se repite a diario perdió su función.**
Revisar umbrales que disparan de forma crónica. Corregir la condición de fondo o recalibrar el umbral, pero no dejar el ruido.

**OBS-R04 — Recolectar siempre el FFDC.**
Cuando exista `config_too_long` o `event_error`, el paquete FFDC correspondiente es la primera pieza a pedir.

---

## Esquema Propuesto en brain.db

```sql
CREATE TABLE IF NOT EXISTS obs_coverage (
    source_name     TEXT,      -- clstrmgr.debug
    host            TEXT,
    path            TEXT,
    rotation_policy TEXT,
    effective_span  TEXT,      -- "3 min 44 s"
    span_seconds    INTEGER,
    verdict         TEXT,      -- adecuada | parcial | insuficiente | punto-ciego
    evidence_date   TEXT
);

CREATE TABLE IF NOT EXISTS obs_gaps (
    gap_id          TEXT,      -- OBS-G01
    title           TEXT,
    description     TEXT,
    impact          TEXT,
    detected_at     TEXT,
    incident_id     TEXT,
    remediation     TEXT,
    status          TEXT       -- open | closed
);
```

---

## Qué Produce Este DT

| Output | Descripción | Destino |
|--------|-------------|---------|
| Inventario de cobertura | Fuente, retención efectiva y veredicto | `obs_coverage` |
| Catálogo de brechas | Puntos ciegos con impacto y remediación | `obs_gaps`, alimenta `dt-riesgos` |
| Procedimiento de recolección | Qué pedir, de qué nodos y con qué sellado de origen | `runbook-recoleccion-evidencia.md` |
| Lista de alertas degradadas | Umbrales que disparan de forma crónica | Alimenta `dt-itom` |

---

## Preguntas que Este DT Puede Responder

- Si ocurre un incidente ahora, ¿podremos explicarlo mañana?
- ¿Qué fuentes caducan antes de que alguien note el problema?
- ¿Qué no se está midiendo en absoluto?
- ¿Qué alertas perdieron significado por repetición?
- ¿Qué debe pedirse al cliente en la próxima recolección de evidencia?

---

## Restricciones

- Este DT evalúa la observabilidad existente. No diseña la plataforma de observabilidad objetivo, que corresponde al SME de IT Operating Model junto con el cliente.
- Los veredictos de retención se calculan sobre la evidencia recibida. Si el cliente conserva copias adicionales que no se entregaron, el veredicto cambia.
- Existe un mensaje `Unable to connect to SNMP after 62 retries, giving up` del 25 de septiembre de 2026, pero pertenece al nodo DCMSIF02N2 del clúster `DCMSIF01_cluster`. **No dice nada sobre el estado del monitoreo del clúster DCMSIF.** Queda como dato requerido para ese otro clúster, no como brecha del incidente.

---

*Versión 0.2.0, 2026-10-09. Corrige la v0.1.0, que atribuía al clúster DCMSIF una falla de SNMP de otro clúster, daba por perdida una ventana que el FFDC sí conservaba, y sostenía una asimetría entre nodos basada en un bundle equivocado. Alineada con `incident-log-powerha-dcmsif.md` v2.0.*

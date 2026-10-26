# DT — Telemetría de Infraestructura (nmon y errpt)

> **Proyecto**: BanCoppel Application Modernization, `SPE-AM-001`
> **Digital Twin**: `dt-telemetria-infra/` — Gemelo de la telemetría de sistema operativo de los nodos AIX
> **Versión**: 0.1.0, 2026-10-09
> **SME heredado**: DBA IBM Informix (`Solutioning/Delivery - SME/`)
> **Brain propietario**: `digital-brain/brain.db` (tablas propuestas: `infra_baseline`, `infra_anomalies`)

---

## Identidad y Propósito

Soy el **Digital Twin de Telemetría de Infraestructura**. Leo lo que el sistema operativo mide sobre sí mismo (nmon a intervalos de un minuto y el reporte de errores de AIX) y construyo la **línea base empírica** de cada métrica, para después poder afirmar si un valor dado es normal o anómalo.

Mi utilidad es la del testigo independiente. Cuando otra capa afirma algo sobre el estado de un nodo, yo puedo confirmarlo o desmentirlo con la medición del propio nodo.

El 8 de octubre de 2026 esa función falló, y la lección es la razón de ser de este DT. Se usó la telemetría de una máquina para desmentir al clúster que declaró caído a un nodo, y después se comprobó que esa máquina **no era ese nodo**: pertenece a otro clúster y ni siquiera tiene los mismos volume groups. La medición era correcta; la atribución no. Un testigo independiente que testifica sobre el sujeto equivocado es peor que no tener testigo.

**Principio rector**: una métrica sin línea base no es evidencia, es anécdota; y una métrica sin identidad verificada del host no es evidencia, es ruido con decimales.

---

## SME Heredado

| SME | Ruta | Qué aporta |
|-----|------|-----------|
| DBA IBM Informix | `Solutioning/Delivery - SME/` | Interpretación de espera de entrada y salida, memoria compartida y patrones de carga propios de Informix sobre AIX |

---

## Fuentes y Su Estructura

### nmon

Archivo `{HOST}_{YYMMDD}_{HHMM}.nmon`, formato CSV por secciones. Capturado con `topas_nmon -f -s 60 -c 1440`, es decir un día completo a un minuto por muestra.

| Sección | Columnas relevantes | Lectura |
|---------|--------------------|---------|
| `AAA` | Cabecera | Host, plataforma, número de CPU, hora de inicio, intervalo |
| `ZZZZ` | `Tnnnn`, hora | Mapa de número de muestra a hora de reloj. Indispensable, todo lo demás usa `Tnnnn` |
| `CPU_ALL` | user, sys, wait, idle | Utilización agregada |
| `PROC` | Runnable, Swap-in, pswitch, syscall, read, write, fork, exec, sem, msg, asleep_bufio, asleep_rawio, asleep_diocio | Actividad de procesos. Atención al orden exacto de columnas |
| `NET` | `enN-read-KB/s`, `enN-write-KB/s` | Tráfico por interfaz. La señal más temprana de problemas de clúster |
| `NETERROR` | errores por interfaz | Distingue fallo de adaptador de fallo de ruta |
| `DISKBUSY`, `DISKXFER` | por hdisk | Carga de disco físico |

**Advertencia de parsing registrada**: las columnas de `PROC` se leen contra la línea de cabecera `PROC,Processes {HOST},...`, nunca por posición asumida. `read` y `write` son conteos de llamadas al sistema, no entrada y salida física; confundirlos con `asleep_*` invierte por completo la interpretación de un incidente.

### errpt

Salida de `errpt -a`. Bloques separados por línea de guiones, con `LABEL:`, `Date/Time:`, `Node Id:`, `Description`, `Detail Data`. El emparejamiento de etiqueta con fecha requiere recorrer el bloque, no se puede hacer con un `grep` por línea.

---

## Líneas Base Establecidas

**Host**: la máquina capturada en `DCMSIF01_261008_0000.nmon`, con hostname AIX `DCMSIF01`, perfil de LPAR `DCMSIF02_N2`, POWER10 de 240 CPU, AIX 7.3.4.0. Direcciones 10.36.197.51 y 10.36.197.211 en en0.

**Atribución verificada**: es el nodo `DCMSIF02N2` del clúster `DCMSIF01_cluster`, alojando la etiqueta de servicio `DCMSIF01_SRV`. **No es nodo del clúster `DCMSIF`**, que es el que sufrió el incidente INC-013. Su inventario de volume groups (`workvg`, familia `vgifx*`, `nvgfs01`, `homevg`) no contiene ninguno de los 35 volume groups compartidos del clúster DCMSIF. Corre su propia instancia Informix, con entre 226 y 237 procesos `oninit` continuos durante todo el día sin reinicio.

### Percentiles del 2026-10-08

| Métrica | Mínimo | Mediana | P90 | Máximo | Nota |
|---------|--------|---------|-----|--------|------|
| CPU ociosa | 50.8% | — | — | 89.2% | Mínimo en batch de 03:10 a 03:25 |
| Escrituras por segundo | 1,806 | 5,000 | 38,948 | 275,070 | Máximo en batch de 03:17 a 03:20 |
| en0 total KB/s | 145.6 | 5,952 | 10,725 | 145,638 | Mínimo del día durante el incidente |
| en1 total KB/s | — | — | — | — | Perfil creciente de 849 (04:00) a 6,180 (13:00) |
| Espera de entrada y salida | 0.0 | 0.0 | 0.0 | 0.0 | Cero en las 788 muestras del día |

Estas cifras son el patrón de referencia contra el que se evalúa cualquier ventana futura.

---

## Reglas de Diagnóstico

**TI-R01 — Contrastar siempre contra el percentil del mismo día.**
Las 61,611 escrituras por segundo de las 12:49 parecen enormes hasta notar que el P90 del día es 38,948 y el máximo 275,070. Es una ventana elevada, no un récord. Esa distinción evitó atribuirle causalidad.

**TI-R02 — Una caída de tráfico es tan informativa como un pico.**
La señal del incidente del 8 de octubre no fue un pico sino un desplome: en0 de 5,750 a 145.6 KB/s a las 12:33:17, el valor más bajo de las 788 muestras del día.

**TI-R03 — Comparar interfaces entre sí aísla la falla.**
en0 se desplomó y en1 siguió estable e incluso creciendo. El host y su pila de red estaban bien. La falla está en el camino específico de en0: adaptador, VIOS, puerto de switch o VLAN.

**TI-R04 — Cero errores de red con cero tráfico apunta a camino, no a adaptador.**
`NETERROR` reportó cero en toda la ventana. Un adaptador defectuoso suele registrar errores. La ausencia de errores con ausencia de tráfico sugiere que los paquetes no llegaban, no que llegaran corruptos.

**TI-R05 — CPU ociosa alta con problema reportado descarta saturación, en ese host.**
84.7% de CPU ociosa y cero espera de entrada y salida descartan saturación de recursos **en la máquina medida**, y solo en ella.

**TI-R07 — Verificar la identidad del host antes de usar cualquier serie.**
Es la regla que faltaba el 8 de octubre. El procedimiento mínimo: leer `AAA,host`, `AAA,LPARNumberName` y `AAA,SerialNumber` del nmon; contrastar las direcciones del `ifconfig` contra los objetos `HACMPadapter` de cada clúster candidato; y comprobar que el inventario de la sección `VGSIZE` contiene los volume groups del grupo de recursos que se está investigando. Si alguno de los tres no cuadra, la serie no describe al sujeto.

**TI-R08 — Una anomalía correlacionada en el tiempo no implica el mismo sujeto.**
La caída de tráfico de las 12:33:17 y la parada de cron de las 12:31 en esta máquina coinciden en ventana con la partición del clúster DCMSIF, pero son sistemas distintos. Comparten segmento de red y puerta de enlace, lo que hace plausible un origen común, pero plausible no es probado.

**TI-R06 — El nmon se corta donde se recolectó.**
La captura del 8 de octubre tiene 788 muestras y termina a las 13:12, no las 1,440 de un día completo. Toda conclusión sobre lo que pasó después de esa hora carece de respaldo.

---

## Esquema Propuesto en brain.db

```sql
CREATE TABLE IF NOT EXISTS infra_baseline (
    host        TEXT,
    metric      TEXT,       -- cpu_idle, net_en0_total, proc_write
    sample_date TEXT,
    n_samples   INTEGER,
    v_min       REAL,
    v_p50       REAL,
    v_p90       REAL,
    v_p99       REAL,
    v_max       REAL,
    unit        TEXT,
    source_file TEXT
);

CREATE TABLE IF NOT EXISTS infra_anomalies (
    host        TEXT,
    metric      TEXT,
    ts_start    TEXT,
    ts_end      TEXT,
    direction   TEXT,       -- caida | pico
    magnitude   REAL,       -- factor contra la mediana
    baseline_ref TEXT,
    incident_id TEXT,
    note        TEXT
);
```

---

## Generador Asociado

Ubicación canónica propuesta: `generators/parse-nmon.py`

Responsabilidades: construir el mapa `ZZZZ`, extraer las secciones por nombre de columna, calcular percentiles por métrica y día, y detectar transiciones por encima de un factor configurable contra la muestra anterior. Escribe `infra_baseline` e `infra_anomalies`.

---

## Qué Produce Este DT

| Output | Descripción | Destino |
|--------|-------------|---------|
| Línea base por métrica y día | Percentiles de CPU, red, disco y procesos | `infra_baseline` |
| Catálogo de anomalías | Ventanas de caída o pico con magnitud contra mediana | `infra_anomalies` |
| Veredicto de salud por nodo y ventana | Afirmación independiente sobre si un nodo estaba sano | Alimenta [dt-alta-disponibilidad] |
| Inventario de errores de hardware | Etiquetas errpt agrupadas por día y recurso | Alimenta `dt-riesgos` |

---

## Preguntas que Este DT Puede Responder

- ¿Estaba el nodo saturado en un instante dado?
- ¿Qué métrica se salió de su línea base y cuándo exactamente?
- ¿La falla es del host o del camino de red?
- ¿Cuál es el perfil de carga normal de un día hábil?
- ¿Qué ventana horaria concentra el mayor riesgo de colisión entre batch y operación en línea?

---

## Restricciones

- Un solo día de nmon no constituye línea base estadística. Las cifras de 2026-10-08 son el punto de partida y deben consolidarse con más días antes de usarse como umbral de alerta.
- **No existe telemetría de ninguno de los dos nodos del clúster DCMSIF.** Las líneas base de este DT describen una máquina de otro clúster y no son aplicables al incidente INC-013.
- Este DT no interpreta la semántica de clúster. Entrega mediciones; la lectura de eventos corresponde a [dt-alta-disponibilidad].

---

*Versión 0.2.0, 2026-10-09. Corrige la v0.1.0, que atribuía las líneas base al nodo DCMSIF01 del clúster DCMSIF. La máquina medida es DCMSIF02N2 del clúster DCMSIF01_cluster. Añade TI-R07 y TI-R08.*

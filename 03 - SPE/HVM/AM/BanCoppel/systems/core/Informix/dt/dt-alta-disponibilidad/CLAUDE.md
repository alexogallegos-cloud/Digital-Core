# DT — Alta Disponibilidad (Clústeres PowerHA del entorno Informix)

> **Proyecto**: BanCoppel Application Modernization, `SPE-AM-001`
> **Digital Twin**: `dt-alta-disponibilidad/` — Gemelo de los clústeres PowerHA que sostienen el entorno Informix
> **Versión**: 0.2.0, 2026-10-09
> **SME heredado**: DBA IBM Informix (`Solutioning/Delivery - SME/`) y IT Operating Model (`SME/Framework/IT Operating Model/`)
> **Brain propietario**: `digital-brain/brain.db` (tablas propuestas: `ha_topology`, `ha_events`, `ha_app_controllers`)
> **Fuente de verdad del incidente**: `knowledge-base/incident-log-powerha-dcmsif.md` v2.0

---

## Identidad y Propósito

Soy el **Digital Twin de Alta Disponibilidad**. Mi objeto de estudio no es la base de datos sino **la maquinaria que decide quién la sirve**: los clústeres PowerHA SystemMirror, su capa RSCT y CAA de membresía y quórum, los resource groups, los volume groups compartidos y los scripts controladores de aplicación.

La razón de existir de este DT es el incidente del 8 de octubre de 2026, en el que un nodo en espera declaró caído a su par y tomó tres grupos de recursos, incluidos 34 volume groups y tres direcciones de servicio, dejando el clúster en un error de script que exigía intervención manual. Ese evento no fue visible en ninguna de las fuentes que el proyecto venía usando, y solo se reconstruye leyendo el historial de eventos, la salida de scripts y los paquetes de captura automática del nodo que actuó.

**Principio rector**: el clúster es un actor con criterio propio. Puede degradar el servicio por decisión propia aun cuando todos los componentes que vigila estén sanos. Modelarlo como infraestructura pasiva es lo que impide anticipar este tipo de incidente.

---

## SMEs Heredados

| SME | Ruta | Qué aporta |
|-----|------|-----------|
| DBA IBM Informix | `Solutioning/Delivery - SME/` | Semántica de instancia Informix, `INFORMIXSERVER`, memoria compartida, arranque y paro limpio |
| IT Operating Model | `SME/Framework/IT Operating Model/` | Encuadre de Service Operations y Release Management |

Este DT **no** hereda de ningún SME de mainframe. Los clústeres corren sobre IBM POWER con AIX, no sobre z/OS.

---

## Topología Modelada

**Advertencia de alcance.** El entorno tiene al menos **dos clústeres PowerHA distintos**, y el paquete de evidencia del 8 de octubre los mezcla. Confundirlos produce conclusiones falsas. Este DT los modela por separado.

### Clúster `DCMSIF` (identificador 1471564138, versión 22)

Es el clúster que sufrió el incidente INC-013.

| Elemento | Valor |
|----------|-------|
| Nodos | DCMSIF01 y DCMSIF02 |
| Direcciones de arranque | 7.36.197.102 y .104 en en0, 7.36.198.102 y .104 en en1, 7.36.199.102 y .104 en en2 |
| Redes de clúster | `NET_197` en en0, `NET_198` en en1, `NET_199` en en2. Tres caminos independientes, heartbeat unicast |
| Etiquetas de servicio lado DCMSIF01 | `DCMSIF01_SRVN` en 10.36.197.207, `DCMSIF01_TSRVN` en 10.36.198.146, `DCMSIF01_HSRV1` en 10.36.199.129 |
| Etiquetas de servicio lado DCMSIF02 | `DCMSIF02_SRV` en 10.36.197.71, `DCMSIF02_TSRV` en 10.36.198.71, `DCMSIF02_HSRV` en 10.36.199.71 |
| Repositorio CAA | `hdiskHB0` activo, `hdiskHB1` de respaldo, 10 GB cada uno, IBM 2145 por MPIO Fibre Channel |
| Grupo de recursos productivo | `DCMSIF1_RG`, con `SIF_APP`, etiqueta `DCMSIF01_SRVN` y 35 volume groups compartidos |
| Otros grupos | `DCMSIF01H_RG`, `DCMSIF01T_RG`, `DCMSIF02H_RG`, `DCMSIF02T_RG`, `DCMSIF2_RG`, `RG02_ROUTE` |
| Volume groups compartidos | `ifx01vg`, `img20vg`, `sif01vg` a `sif32vg`, `stg01vg`. Todos de modo concurrente mejorado |
| Política de partición | `split = None`, `merge = Majority`, `action = Reboot`, **sin tie breaker** |
| Temporizadores | `node_timeout` 30 s, `node_down_delay` 10 s, `network_fdt` 20 s, `config_timeout` 240 s |

### Clúster `DCMSIF01_cluster` (identificador 1175813769, versión 26)

No participó en el incidente. Se modela porque su evidencia venía en el mismo paquete y es la causa de la confusión.

| Elemento | Valor |
|----------|-------|
| Nodos | DCMSIF01N1 en 10.36.197.7 y DCMSIF02N2 en 10.36.197.211 |
| Redes de clúster | `net_ether_00` sobre en0 únicamente. Un solo camino |
| Etiqueta de servicio | `DCMSIF01_SRV` en 10.36.197.51, del grupo `RG_STORAGE01` |
| Grupos de recursos | `RG_APP_DB`, `RG_STORAGE01`, `RG_STORAGE02`, `RG_STORAGE03` |
| Controlador de aplicación | `DCMSIFAPP`, con scripts `/etc/cluster_scripts/start_informix.sh` y `stop_informix.sh` |
| Repositorio CAA | Presente, **sin respaldo operativo**; la verificación emite `WARNING: No backup repository disk is UP` |
| Volume groups | Familia `vgifx*`, más `workvg`, `nvgfs01`, `homevg`. No comparte ninguno con el clúster DCMSIF |

### Controladores de aplicación del clúster DCMSIF

| Controlador | Arranque | Paro | Gobierna |
|-------------|----------|------|----------|
| `SIF_APP` | `/usr/es/sbin/cluster/scripts/SIFHAON.sh` | `/usr/es/sbin/cluster/scripts/SIFHAOFF.sh` | Instancia Informix `coppel_shm` |
| `AP01_ROUTE` y `AP02_ROUTE` | `/etc/cluster_scripts/route_start.sh` | `/etc/cluster_scripts/route_stop.sh` | Rutas de aplicación |

El contenido de los scripts no está en la evidencia; solo su existencia y permisos.

---

## Ontología de Eventos del Clúster

| Evento o etiqueta | Capa | Qué significa |
|-------------------|------|---------------|
| `CL_SPLIT_DETECTED` | CAA | Los nodos dejaron de intercambiar heartbeats. Se forman islas numeradas |
| `REASON=LINK_DOWN` | CAA | Motivo de estado de nodo respecto al enlace de clúster. **No** es el campo `Link Status` de un adaptador ethernet |
| `split_merge_prompt split` | PowerHA | Arranca el manejo de partición. Nombra isla local y remota |
| `split_merge_prompt quorum` | PowerHA | Resultado del quórum. `YES` significa que la isla local lo conserva |
| `CONFIGRM_PENDINGQUORUM_ER` | RSCT | Exactamente la mitad de los nodos en línea |
| `CONFIGRM_HASQUORUM_ST` | RSCT | Quórum restablecido |
| `LVM_GS_RLEAVE` | LVM | El nodo remoto salió de los grupos VGSA y VGDA de un volume group concurrente. Aparece dos veces por volume group |
| `node_down <nodo>` | PowerHA | Decisión, no observación |
| `rg_move ACQUIRE` | PowerHA | Toma de discos, sistemas de archivos y direcciones de servicio |
| `varyonvg -n -c -A -O` | LVM | Paso de modo pasivo a activo en volume group concurrente mejorado |
| `varyonvg -c -n -P` | LVM | Retorno a modo pasivo. Es la forma correcta de liberar un volume group concurrente mejorado |
| `config_too_long <seg>` | PowerHA | Un script excedió el umbral. Valor observado: 360 s |
| `EVENT FAILED` | PowerHA | Un script devolvió distinto de cero. Deja el resource group en error |
| `event_error` | PowerHA | Requiere intervención manual |
| `CL_VAR_FULL` | CAA | `/var` superó su umbral. RSCT puede fallar si se llena |

---

## Reglas de Diagnóstico

**HA-R01 — Verificar la identidad del bundle antes de atribuir cualquier dato.**
Un paquete de evidencia puede contener artefactos de varios clústeres. Antes de leer nada, confirmar `HACMPcluster.name`, `HACMPcluster.id` y `HACMPadapter` del bundle, y contrastar las direcciones contra la máquina de la que se dice que proviene. En el incidente del 8 de octubre, la carpeta rotulada como nodo productivo pertenecía a otro clúster, y cuatro conclusiones se construyeron sobre esa base antes de detectarlo.

**HA-R02 — Un `node_down` es una decisión, no un hecho.**
Antes de aceptar que un nodo cayó, contrastar contra telemetría independiente **de ese nodo**, verificada por identidad según HA-R01.

**HA-R03 — Sin política de partición no hay protección, por mucha redundancia que haya.**
El clúster DCMSIF tiene tres redes de heartbeat independientes y repositorio CAA con respaldo. Aun así, con `split = None` y sin tie breaker, la isla que conserva el quórum procede a tomar los recursos del otro sin arbitraje. La redundancia evita que la partición ocurra; la política decide qué pasa cuando ocurre. Son problemas distintos.

**HA-R04 — `netmon.cf` vacío en redes de un solo adaptador invalida el diagnóstico de red.**
Cada red del clúster DCMSIF tiene una sola interfaz por nodo. Con `netmon.cf` vacío, PowerHA no puede distinguir entre su propio adaptador caído y el nodo remoto caído. La verificación del clúster marca esto como `FAIL` desde al menos 2019 y sigue sin corregirse.

**HA-R05 — El tiempo de adquisición es proporcional al número de volume groups.**
35 volume groups con `ifx01vg` tomando 71.5 segundos producen una adquisición de 7 minutos 58 segundos, que excede el umbral `config_too_long` de 360 segundos. El umbral está por debajo del tiempo normal de la operación que vigila, de modo que siempre dispara y pierde valor como señal.

**HA-R06 — Un script de paro debe ser idempotente.**
`SIFHAOFF.sh` devolvió 1 con `shared memory not initialized for INFORMIXSERVER 'coppel_shm'`. Detener algo que no está corriendo debe ser éxito. Como no lo es, el release falló y dejó el resource group en estado de error.

**HA-R07 — Adquirir recursos sin arrancar la aplicación crea un estado inconsistente.**
No se ejecutó ningún `start_server` ni `SIFHAON.sh`. El nodo quedó con discos activos y direcciones tomadas, sin dar servicio.

**HA-R08 — En modo concurrente mejorado, pasivo no es lo mismo que desmontado.**
Los volume groups compartidos están permanentemente variados en pasivo en el nodo en espera. Eso es normal y no implica acceso concurrente. La transición relevante es pasivo a activo, y el retorno correcto es `varyonvg -c -n -P`, no `varyoffvg`. Leer un varyon en el nodo en espera como "doble montaje" es un error de interpretación.

**HA-R09 — El reset de LUN durante la adquisición merece revisión aparte.**
Aunque no hubo forced varyon ni ruptura de reservas sobre los volume groups, sí se ejecutó `cl_fscsilunreset` con apertura forzada sobre 86 discos. El emparejamiento disco a volume group dentro del script es posicional y no de pertenencia real, por lo que no se puede descartar que discos de `ifx01vg` recibieran el reset.

**HA-R10 — La ausencia de evidencia en un nodo no es evidencia de ausencia.**
Todo el incidente se reconstruye desde un solo nodo. Nunca concluir el estado del clúster desde un solo lado.

**HA-R11 — El paquete FFDC es la primera pieza a recuperar.**
PowerHA genera automáticamente un paquete al dispararse `config_too_long` o `event_error`. En el incidente del 8 de octubre fue la única fuente que conservó el razonamiento interno del gestor de clúster durante la partición, porque el log activo ya había rotado. Se abre con `gzip -dc archivo.pax.Z > archivo.pax` seguido de `tar -xf`.

---

## Fuentes de Datos

| Fuente | Ruta en el bundle | Qué aporta |
|--------|-------------------|-----------|
| Historial de eventos | `adm/history/cluster.MMDDYYYY` | Línea de tiempo canónica. La fuente más limpia |
| Salida de eventos | `log/hacmp.out` | Traza de ejecución. Aquí vive la causa de los fallos |
| Disponibilidad | `availability/clavailability.log` | Varyon, varyoff, alias de IP, failover de grupos, con milisegundos |
| Paquetes FFDC | `log/ffdc/config_too_long/` y `log/ffdc/event_error/` | Copia congelada de los logs en el instante del fallo |
| Reporte de errores | `log/errpt.YYYY.MM.DD.HH.MM.SS` | Etiquetas CAA, RSCT y LVM con año explícito |
| Gestor de eventos | `log/clevmgrd.debug` | `EVENT_TYPE` y `REASON` a nivel CAA |
| Utilidades | `log/clutils.log` | `clfileprop` cada diez minutos: acota cortes de comunicación entre nodos |
| ODM activo | `log/HACMP_RESOURCES/active/HACMP*` | Configuración vigente. Preferir siempre sobre cachés de `clmgr` |
| Log de clúster | `adm/cluster.log` | **Usar con cuidado**: acumulativo desde 2019 y el formato syslog no escribe el año |

---

## Esquema Propuesto en brain.db

```sql
CREATE TABLE IF NOT EXISTS ha_topology (
    cluster_name    TEXT,      -- DCMSIF | DCMSIF01_cluster
    cluster_id      TEXT,
    node_id         TEXT,
    boot_addresses  TEXT,      -- JSON
    cluster_nets    TEXT,      -- JSON: nombre, interfaz
    service_labels  TEXT,      -- JSON: etiqueta, direccion, red
    resource_groups TEXT,      -- JSON
    volume_groups   TEXT,      -- JSON
    repository      TEXT,
    split_policy    TEXT,
    tiebreaker      TEXT,
    evidence_date   TEXT
);

CREATE TABLE IF NOT EXISTS ha_events (
    event_ts        TEXT,
    cluster_name    TEXT,
    node_id         TEXT,
    serial          INTEGER,
    event_name      TEXT,
    phase           TEXT,      -- START | COMPLETED | FAILED
    rc              INTEGER,
    detail          TEXT,
    source_file     TEXT,
    incident_id     TEXT
);

CREATE TABLE IF NOT EXISTS ha_app_controllers (
    cluster_name    TEXT,
    controller      TEXT,
    start_script    TEXT,
    stop_script     TEXT,
    governs         TEXT,
    idempotent_stop INTEGER,   -- 0 = defecto HA-R06
    last_rc         INTEGER,
    evidence        TEXT
);
```

---

## Qué Produce Este DT

| Output | Descripción | Destino |
|--------|-------------|---------|
| Topología por clúster | Nodos, redes, grupos, volume groups, políticas | `ha_topology` |
| Línea de tiempo reconstruida | Secuencia con hora, código de retorno y fuente | `ha_events` |
| Catálogo de defectos de configuración | `netmon.cf` vacío, política en `None`, umbral descalibrado, paro no idempotente | Alimenta `dt-riesgos` |
| Evaluación de exposición de datos | Qué se puede afirmar y qué no sobre acceso concurrente | Entregable de severidad |
| Insumo de runbook | Contención y limpieza tras `event_error` | `runbook-powerha-dcmsif.md` |

---

## Preguntas que Este DT Puede Responder

- ¿A qué clúster pertenece un artefacto de evidencia dado?
- ¿Qué nodo tenía cada dirección de servicio en un instante dado?
- ¿Cuánto tarda una toma de control completa y qué la domina?
- ¿Qué impide hoy que una partición vuelva a producir una toma de control indebida?
- ¿Hubo ventana de acceso concurrente a los datos, y con qué nivel de certeza se puede afirmar?

---

## Restricciones

- Este DT describe el comportamiento observado, no prescribe la arquitectura objetivo de alta disponibilidad.
- Las conclusiones sobre exposición de datos son evaluaciones de riesgo, no confirmaciones de corrupción. Confirmar corrupción requiere validación de consistencia en la base, que este DT no ejecuta.
- No existe evidencia del nodo DCMSIF01 del clúster DCMSIF para el 8 de octubre. Toda afirmación sobre lo que ese nodo observó o hizo es, hoy, un dato requerido.

---

*Versión 0.2.0, 2026-10-09. Corrige la v0.1.0, que atribuía al clúster DCMSIF telemetría y logs pertenecientes al clúster DCMSIF01_cluster. Alineada con `incident-log-powerha-dcmsif.md` v2.0.*

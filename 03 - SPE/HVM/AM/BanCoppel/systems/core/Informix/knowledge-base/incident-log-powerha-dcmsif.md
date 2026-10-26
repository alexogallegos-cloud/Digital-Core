# Incident Log — Clúster PowerHA DCMSIF

> **Proyecto**: BanCoppel Application Modernization, `SPE-AM-001`
> **Componente**: Clúster PowerHA SystemMirror `DCMSIF` (identificador 1471564138)
> **Incidente**: INC-013, 8 de octubre de 2026
> **Versión del documento**: 2.0, 2026-10-09
> **Método**: análisis independiente sobre evidencia cruda, verificado por enjambre de siete agentes con cruce de contradicciones

---

## Cómo leer este documento

Cada afirmación está clasificada. **HECHO** significa que existe una cita literal en un archivo de la evidencia, con ruta y línea o sello de tiempo. **INFERENCIA** significa que es una lectura razonada de varios hechos, y se marca como tal. **DATO-REQUERIDO** significa que no se puede determinar con la evidencia entregada, y se indica qué archivo haría falta.

La versión 1.0 de este análisis contenía cuatro errores de atribución que se corrigen aquí y se listan explícitamente en la sección final. Se conservan para que nadie vuelva a cometerlos.

---

## 1. Advertencia de integridad de la evidencia

**HECHO.** El paquete entregado contiene artefactos de **dos clústeres PowerHA distintos**, no de dos nodos del mismo clúster.

| | Clúster `DCMSIF` | Clúster `DCMSIF01_cluster` |
|---|---|---|
| Identificador | 1471564138 | 1175813769 |
| Versión de clúster | 22 | 26 |
| Nodos | DCMSIF01, DCMSIF02 | DCMSIF01N1, DCMSIF02N2 |
| Direcciones de arranque | 7.36.197.102 y .104, 7.36.198.102 y .104, 7.36.199.102 y .104 | 10.36.197.7 y 10.36.197.211 |
| Direcciones de servicio | 10.36.197.207, 10.36.198.146, 10.36.199.129, 10.36.197.71, 10.36.198.71, 10.36.199.71 | 10.36.197.51 |
| Redes de clúster | NET_197 en en0, NET_198 en en1, NET_199 en en2 | net_ether_00 en en0 solamente |
| Grupos de recursos | DCMSIF1_RG, DCMSIF01H_RG, DCMSIF01T_RG, DCMSIF02H_RG, DCMSIF02T_RG, DCMSIF2_RG, RG02_ROUTE | RG_APP_DB, RG_STORAGE01, RG_STORAGE02, RG_STORAGE03 |
| Repositorio CAA | hdiskHB0 activo, hdiskHB1 respaldo | hdiskHB0, sin respaldo operativo |

Fuentes: `log/HACMP_RESOURCES/active/HACMPcluster`, `HACMPadapter`, `HACMPnetwork` y `HACMPsircol` de cada bundle, más `clverify/clverify.log`.

**HECHO.** El bundle de la carpeta rotulada `P8 NPasivo 10.36.197.65` es del nodo **DCMSIF02 del clúster DCMSIF**. Es el único que registró el incidente.

**HECHO.** El bundle de la carpeta rotulada `P10 PROD 10.36.197.51` es del clúster **DCMSIF01_cluster**. Su último evento de clúster es del 25 de septiembre de 2026 y no existe archivo de historial del 8 de octubre. No contiene nada del incidente.

**HECHO.** La máquina de la que existe telemetría nmon tiene configuradas en en0 las direcciones `10.36.197.51` y `10.36.197.211`, y **ninguna dirección del clúster DCMSIF**. Esas dos direcciones son, respectivamente, la etiqueta de servicio `DCMSIF01_SRV` y la dirección de arranque del nodo `DCMSIF02N2`, ambas del clúster nuevo.

**INFERENCIA.** La máquina con telemetría es el nodo DCMSIF02N2 del clúster `DCMSIF01_cluster`, alojando la dirección de servicio de ese clúster. No es un nodo del clúster que se partió.

**Consecuencia operativa.** Del nodo DCMSIF01 del clúster DCMSIF, que es el que fue declarado caído y al que se le quitaron los recursos, **no existe un solo archivo en la evidencia**. Todo el incidente está documentado por un único testigo, que además es la parte interesada.

---

## 2. Configuración relevante del clúster DCMSIF

**HECHO, redundancia de heartbeat.** Tres redes de clúster independientes, todas ethernet con heartbeat unicast: `NET_197` sobre en0, `NET_198` sobre en1, `NET_199` sobre en2, con una interfaz por nodo en cada una. No hay red de tipo `diskhb`. Existe disco de repositorio CAA `hdiskHB0` con respaldo `hdiskHB1`, ambos de 10 GB sobre IBM 2145 por MPIO Fibre Channel, y ambos reportados en estado 1 por `clverify/ver_bdisk_status.log` del 7 de octubre a las 23:56.

**HECHO, defecto de configuración 1.** El archivo `/usr/es/sbin/cluster/netmon.cf` está **vacío** en ambos nodos: mide dos bytes, un espacio y un salto de línea. La verificación del clúster lo marca como fallo explícito para las tres redes y en los dos nodos, con el texto literal `WARNING: File 'netmon.cf' is missing or empty on the following nodes:`. La condición está registrada tanto en la verificación del clúster DCMSIF como en la del clúster nuevo, fechada el 25 de septiembre de 2026.

Por qué importa: cada red tiene un solo adaptador por nodo. Sin objetivos en `netmon.cf`, PowerHA no puede distinguir entre su propio adaptador caído y el nodo remoto caído.

**HECHO, defecto de configuración 2.** Política de partición en `HACMPsplitmerge`, capturada en el snapshot del 7 de octubre a las 23:55, trece horas antes del evento: `split = None`, `merge = Majority`, `action = Reboot`. No hay tie breaker configurado; la consulta en tiempo de ejecución devuelve vacío (`clodmget -q 'policy = tiebreaker' -f value -n HACMPsplitmerge` seguido de `tiebreaker=''`).

**HECHO, temporizadores.** `node_timeout = 30` segundos, `node_down_delay = 10`, `network_fdt = 20`, `config_timeout = 240`, `monitor_ifs = 0`, `deadman_mode = 0`, `repos_mode = 1`. A nivel CAA, el valor en reposo es `node_timeout = 30000 ms` y `network_fdt = 20000 ms`.

**HECHO, umbral config_too_long.** El valor 360 aparece en los logs desde 2020 y es invariante en las trece ocurrencias registradas. **No existe en ningún objeto de configuración del bundle**: la clase `HACMPcustom` está vacía y los 83 registros de `HACMPevent` tienen `event_duration = 0`. La única fuente que menciona duraciones es una caché de `clmgr` de enero de 2023 con `MAX_EVENT_TIME=180` y `MAX_RG_PROCESSING_TIME=180`.

**INFERENCIA.** El 360 es probablemente la suma de los dos parámetros de 180, aplicada por omisión. No está probado.

**HECHO, grupo de recursos productivo.** `DCMSIF1_RG` agrupa el controlador de aplicación `SIF_APP`, la etiqueta de servicio `DCMSIF01_SRVN` en 10.36.197.207 y 34 volume groups, entre ellos `ifx01vg`. Los scripts del controlador son `/usr/es/sbin/cluster/scripts/SIFHAON.sh` para arranque y `SIFHAOFF.sh` para paro. El contenido de ambos **no está en la evidencia**.

---

## 3. Cronología del 8 de octubre de 2026

Todas las horas son CST, zona confirmada por los sellos literales de `clutils.log`. Todos los registros provienen de DCMSIF02.

| Hora | Evento | Código | Fuente |
|---|---|---|---|
| 04:30:12 | `CL_VAR_FULL`, `/var` al 75% sobre umbral 75%, recurso CAA | PERM | errpt capturado |
| 12:44:19 | `CL_SPLIT_DETECTED`, `SUBTYPE=LOCAL`, isla local 1 es DCMSIF02, isla remota 2 es DCMSIF01 | PEND | errpt capturado |
| 12:44:19 | `CONFIGRM_SUBCLUSTER` y `CONFIGRM_PENDINGQUORUM` | — | errpt capturado |
| 12:44:19 | 70 eventos `LVM_GS_RLEAVE`, mismo segundo | — | errpt capturado |
| 12:44:19 | `EVENT_TYPE=NODE_DOWN`, `REASON=LINK_DOWN`, nodo 2 | — | `clevmgrd.debug` |
| 12:44:25 | `split_merge_prompt split` completado | 0 | `cluster.10082026` |
| 12:44:49 | `Split policy is None`, `split_none=1`, `quarantine=0`, `In split, running FSM with NEW_EVENT for FAIL_NODE id 2` | — | `clstrmgr.debug.1` dentro del FFDC |
| 12:44:49 | `CONFIGRM_HASQUORUM` | INFO | errpt capturado |
| 12:44:50 | `node_down DCMSIF01` iniciado y completado | 0 | `cluster.10082026` |
| 12:44:52 a 12:44:56 | `rg_move_release DCMSIF02 1`, grupo DCMSIF01H_RG | 0 | `cluster.10082026` |
| 12:44:59 | `rg_move_acquire DCMSIF02 5`, grupo DCMSIF1_RG | — | `cluster.10082026` |
| 12:45:00 a 12:45:02 | Alias de tres direcciones de servicio: 10.36.199.129, 10.36.198.146, 10.36.197.207 | 0 | `clavailability.log` |
| 12:45:08 | `clfileprop: ERROR, A communication error ... Please make sure clcomd is running` | — | `clutils.log` |
| 12:45:23 a 12:49:51 | Varyon de 34 volume groups. `ifx01vg` toma 71.5 segundos | — | `clavailability.log` |
| 12:50:47 | `FS:MOUNT:FAILURE` en `/home/syspld` | ERROR | `clavailability.log` |
| 12:50:59 | `config_too_long 360 TE_RG_MOVE_ACQUIRE` y `cluster_ffdc -c 10031` | — | `cluster.10082026` |
| 12:50:59 | Segundo `CL_VAR_FULL` | PERM | errpt capturado |
| 12:52:57 | `rg_move DCMSIF02 5 ACQUIRE` completado, duración 7 min 58 s | 0 | `cluster.10082026` |
| 12:53:01 | `RG:FAILOVER:END` de DCMSIF01H_RG y DCMSIF01T_RG, origen DCMSIF01, destino DCMSIF02 | — | `clavailability.log` |
| 12:53:07 | `rg_move_release DCMSIF02 5` iniciado | — | `cluster.10082026` |
| 12:53:08 | `stop_server SIF_APP` **FALLA**. `SIFHAOFF.sh` devuelve 1 con `shared memory not initialized for INFORMIXSERVER 'coppel_shm'` y `writing to routing socket: No such process` | **1** | `hacmp.out` líneas 341214 a 341293 |
| 12:53:11 a 12:55:09 | Desmontaje y varyoff de los 34 volume groups | — | `clavailability.log` |
| 12:55:11 | `Removing aliased IP address 10.36.197.207 from adapter en0`, `release_takeover_addr` completado | 0 | `hacmp.out` línea 355270 |
| 12:55:12 | `rg_move DCMSIF02 5 RELEASE` **FALLA** y `rg_move_release DCMSIF02 5` **FALLA** | **1** | `cluster.10082026` |
| 12:55:12 | `event_error 1 TE_RG_MOVE` y `cluster_ffdc -e 10036` | 0 | `cluster.10082026` |
| 12:59:07 | `config_too_long 360 TE_RG_MOVE_RELEASE`, **sin evento de cierre en ninguna fuente** | sin RC | `cluster.10082026`, última línea |
| 13:15:07 | Último `clfileprop` con error de comunicación | — | `clutils.log` |
| 13:25:04 | `clfileprop` vuelve a la normalidad | — | `clutils.log` |
| hasta 13:44 | 53 avisos `running recovery program 'TE_RG_MOVE_RELEASE'`, el último con 3,060 segundos, junto a `WARNING: node DCMSIF02 has encountered a fatal event script error. Manual intervention is required.` | — | `hacmp.out` |

**HECHO.** La comunicación entre nodos estaba sana a las 12:35:05 y rota a las 12:45:08, y no se restablece hasta entre las 13:15:07 y las 13:25:04.

**HECHO.** La captura automática de procesos de las 12:50:59 en DCMSIF02 **no contiene ningún proceso `oninit`, `onstat`, `onbar`, `onmode` ni `ontape`**. Las dos únicas apariciones de la cadena informix son procesos de correo.

**HECHO.** No existe ningún evento `start_server` el 8 de octubre, y `SIFHAON.sh` no aparece ejecutado ni una vez.

**HECHO.** Se aliasaron tres direcciones de servicio y solo consta la liberación de una, la 10.36.197.207. Las otras dos no tienen registro de liberación porque el release falló antes de llegar a ellas.

---

## 3b. Qué pasó realmente con los volume groups

Esta sección responde la pregunta de exposición de datos, que es la de mayor severidad potencial.

**HECHO.** Los 35 volume groups compartidos son de modo concurrente mejorado. Antes de la adquisición ya estaban variados en DCMSIF02 en **modo pasivo**, que es el estado normal de un nodo en espera. El script lo verifica y lo registra: `vg_on_mode=passive` en los 34 procesados, sin una sola excepción.

**HECHO.** La adquisición los pasó de pasivo a activo con `varyonvg -n -c -A -O`, modo concurrente en estado activo con override del estado registrado por LVM. Para `ifx01vg` el varyon corrió de 12:45:23.783 a 12:46:35.268 y devolvió cero.

**HECHO.** **No hubo forced varyon.** La variable `FORCEON` se evaluó 34 veces y valía cadena vacía en todas. El atributo `FORCED_VARYON` está en `false` para todos los grupos, igual que `SSA_DISK_FENCING`. SCSI Persistent Reserve no está habilitado en el clúster: `SCSIPR_ENABLED=''`.

**HECHO.** Sí se bajó la altura de fencing del volume group a lectura y escritura: `cl_set_vg_fence_height -c ifx01vg rw` con retorno cero.

**HECHO.** Sí se ejecutó un **reset de LUN SCSI-3 sobre 86 discos**, con apertura forzada: 85 ocurrencias de `openx(hdiskNN, O_RDWR, 0, 0 + SC_FORCED_OPEN_LUN)` y 86 de `ioctl SCIOLSTART`. Para los discos pertenecientes a volume groups ya variados en pasivo el script decidió explícitamente no romper reservas, pero el emparejamiento disco a volume group dentro del script es **posicional**, no de pertenencia real: hay 122 discos y 36 nombres de volume group, y al agotarse la lista de nombres los 86 discos restantes pasaron a la rama de reset.

**HECHO.** En la liberación, los volume groups **no se desactivaron sino que volvieron a modo pasivo**, con `varyonvg -c -n -P`, que es el comportamiento correcto para modo concurrente mejorado. De los 35, treinta y cuatro devolvieron cero. El único con retorno distinto fue `sif32vg`, que recibió un `varyoffvg` real y quedó desactivado. `cl_deactivate_vgs` terminó con código cero.

**HECHO.** Después del fallo de las 12:55:12 no se ejecutó ningún `umount`, ningún `varyoffvg` ni ningún `varyonvg` adicional en DCMSIF02. Los volume groups quedaron en modo pasivo, que es su estado de reposo correcto.

**HECHO.** Los 70 eventos `LVM_GS_RLEAVE` corresponden a 35 identificadores distintos de volume group, cada uno repetido dos veces, y ese conjunto de 35 es exactamente el conjunto de volume groups compartidos de `DCMSIF1_RG`. En los 70 el campo `Remote Node Name` vale `DCMSIF01` y el campo `SENSE DATA` es cero. Ocurrieron a las 12:44:19, **31 segundos antes** del `node_down` y 40 segundos antes del inicio de la adquisición.

**HECHO.** El inventario de volume groups de la máquina con telemetría, leído de la sección `VGSIZE` del nmon, es `workvg, vgifxhdat4_1, vgifxer4_1, vgifxoidx8_1, vgifxtmp4_4, nvgfs01, page02vg, homevg, page01vg, caavg_private, rootvg`. **No contiene `ifx01vg` ni ninguno de los `sif01vg` a `sif32vg`, ni `img20vg`, ni `stg01vg`.** Es un servidor Informix distinto, con su propia familia de volume groups `vgifx*`.

**DATO-REQUERIDO, y es el que cierra la pregunta de exposición.** No se puede determinar si DCMSIF01 tenía `ifx01vg` activo mientras DCMSIF02 lo activaba. El único indicio sobre el estado remoto son los `LVM_GS_RLEAVE`, que afirman que el nodo remoto **abandonó** los grupos VGSA y VGDA, no que los tuviera activos. Hace falta `lsvg -o` y `lsvg -L ifx01vg` de DCMSIF01 dentro de la ventana, o su `hacmp.out` y `clstrmgr.debug` con cobertura de 12:33 a 13:05.

**INFERENCIA, con la incertidumbre anterior.** El riesgo de doble acceso es menor de lo que la primera lectura sugería. Los volume groups son de modo concurrente mejorado, diseñados precisamente para que dos nodos los tengan abiertos con uno solo en activo. No hubo forzado ni ruptura de reserva sobre ellos, no hay en el reporte de errores de ninguno de los dos nodos una sola entrada de pérdida de quórum de volume group, de fallo de entrada y salida de LVM ni de corrupción de JFS2 ese día, y el release los devolvió limpiamente a pasivo. Lo que queda abierto no es la corrupción, que no tiene evidencia, sino el reset de LUN sobre 86 discos cuya pertenencia a `ifx01vg` no se puede descartar.

---

## 4. Hallazgos

| ID | Clase | Hallazgo | Evidencia |
|---|---|---|---|
| F-01 | Configuración, crítico | `netmon.cf` vacío en ambos nodos con redes de un solo adaptador. La verificación del clúster lo marca como fallo desde al menos 2019 | `filebackup/usr/es/sbin/cluster/netmon.cf` de 2 bytes; `clverify.log` con `FAIL` en las tres redes |
| F-02 | Configuración, crítico | Política de partición en `None` y sin tie breaker. Ante un split, nada arbitra | `HACMPsplitmerge` del 7-oct 23:55; `clodmget` en runtime devuelve vacío |
| F-03 | Código, crítico | `SIFHAOFF.sh` no es idempotente: detener una instancia que no corre devuelve 1 y aborta el release | `hacmp.out` 341214 a 341293 |
| F-04 | Operación, crítico | El release falló dejando dos direcciones de servicio sin liberar y el clúster en error de script pidiendo intervención manual | `clavailability.log`; `hacmp.out` últimas líneas |
| F-05 | Diseño, alto | Umbral `config_too_long` de 360 s frente a una adquisición real de 478 s. La alerta siempre dispara en una toma de control legítima | `cluster.10082026`; duraciones de `clavailability.log` |
| F-06 | Evidencia, alto | El paquete mezcla dos clústeres. No hay evidencia del nodo declarado caído | Sección 1 |
| F-07 | Observabilidad, medio | `clstrmgr.debug` rota cada 24 a 28 segundos; las ocho copias cubren 3 min 17 s | Cobertura temporal verificada archivo por archivo |
| F-08 | Observabilidad, medio | `adm/cluster.log` de DCMSIF02 dejó de escribirse el 8-oct a las 03:04:16, casi diez horas antes del incidente. Conviven `syslogd` y `rsyslogd` | mtime del archivo; captura de procesos |
| F-09 | Observabilidad, medio | `/var` en el umbral de 75% desde la madrugada, con recurso CAA. El mensaje advierte que RSCT puede fallar si se llena | errpt, dos ocurrencias el 8-oct |
| F-10 | Operación, bajo | Falla de montaje de `/home/syspld` durante la adquisición | `clavailability.log` línea 765 |
| F-11 | Evidencia, informativo | La captura `clverify.2026.10.08.*` no es una verificación del día: arrastra un ERROR de 2019 sobre `DCMSIF1_RG`. No debe leerse como hallazgo del incidente | mtime de `clverify.log.1` en 2019-06-18 |

---

## 5. Qué causó el incidente

### 5.0 Causa identificada (actualización del 10 de octubre de 2026)

**HECHO, aportado por el equipo de telecomunicaciones.** El rastreador de endpoints de APIC muestra la dirección `10.36.197.51` aprendida de forma simultánea en dos vPC distintos: `vPC_BC_IBMPower880` (puertos 1/101-1/102), que corresponde al chasis POWER8, y `vPC_BC_IBMPOWER10_Po3` (puertos 1/125-1/126), que corresponde al POWER10. Mismo tenant `BanCoppel`, misma aplicación `AP_BanCoppel`, mismo EPG `EPG_1_USUARIOS`. Una captura posterior, ya remediada, muestra un único aprendizaje en el vPC del POWER10.

**HECHO, aportado por el usuario.** A las **12:32** empieza a fallar el ping a `10.36.197.51`.

**HECHO, verificado en la evidencia.** La `10.36.197.51` fue la dirección de servicio del **clúster viejo DCMSIF**. Su verificación la valida literalmente como `DCMSIF01_SRV (10.36.197.51) PASS`, en registros de 2019. En la configuración vigente al 7 de octubre de 2026 ese clúster ya no la referencia ni una vez: su etiqueta es `DCMSIF01_SRVN` en `10.36.197.207`. Hubo por tanto una renumeración de `.51` a `.207`, de `.198.51` a `.198.146` y de `.199.51` a `.199.129`, con las etiquetas renombradas con sufijo `N` y `1`, y las tres direcciones liberadas se reasignaron al clúster nuevo.

**HECHO, condición habilitante.** El `/etc/hosts` conserva ambos juegos de direcciones simultáneamente, con un bloque rotulado literalmente `# IPs PowerHA Cluster (Migracion)`:

```
# IPs PowerHA Cluster (Migracion)
10.36.197.51    DCMSIF01_SRV
10.36.198.51    DCMSIF01_TSRV
10.36.199.51    DCMSIF01_HSRV

#RED HACMP USUARIOS
10.36.197.51    DCMSIF01_SRV      (repetida)
10.36.197.64    DCMSIF01_BT
10.36.197.65    DCMSIF02_BT

#RED HACMP TRANSACCIONES
10.36.198.146   DCMSIF01_TSRV     (misma etiqueta, otra dirección)
```

La etiqueta `DCMSIF01_TSRV` resuelve a dos direcciones distintas según el bloque que se lea primero, y `DCMSIF01_SRV` sigue resolviendo a la `.51`, que hoy pertenece al clúster nuevo.

**INFERENCIA.** Cualquier script, alias de arranque o invocación del lado POWER8 que use la etiqueta `DCMSIF01_SRV` levanta la `10.36.197.51`, colisionando con la dirección productiva del otro servidor. Es el mecanismo más económico que explica la duplicidad observada por APIC.

**DATO-REQUERIDO.** Qué levantó concretamente la `.51` en el POWER8 entre las 12:15 y las 12:32. De ese nodo no se recolectó ningún registro de autenticación ni de comandos, su `cluster.log` dejó de escribirse a las 03:04:16 y sus trazas de clúster no tienen nada antes de las 12:44.

### 5.1 Reclasificación de causa y consecuencia

**HECHO.** No existe ningún `clrm_stop_request` el 8 de octubre de 2026. Los logs del POWER8 muestran su nodo de clúster activo hasta al menos las 13:45, y su recolección `ctsnap` terminó a las **14:01:06**. El apagado del nodo, realizado como remediación, es por tanto **posterior a las 14:01**.

Con eso, la secuencia se ordena así:

| Tramo | Clasificación |
|-------|---------------|
| 12:15 a 12:32 | Ventana del disparador. Sin evidencia |
| 12:32 | Síntoma en servicio: falla el ping a la `.51` |
| 12:34:08 a 12:43 | Reacción humana: ocho sesiones y diagnósticos de red |
| 12:44:19 a 12:55:12 | Efecto de segundo orden: partición del clúster viejo y toma de recursos |
| Posterior a 14:01 | Remediación: apagado del nodo POWER8 |

Las anomalías registradas en la máquina del clúster nuevo, descritas en la sección 6, se releen ahora como **efecto de la pérdida de alcance a la `.51`**, no como causa.

### 5.2 Lectura anterior, conservada



**HECHO.** El clúster registró como motivo de la caída de nodo `REASON=LINK_DOWN`, y el reporte de errores dice `Nodes are not able to exchange heartbeats`.

**HECHO.** No hay en el reporte de errores de ninguno de los dos nodos, el 8 de octubre, una sola entrada de adaptador ethernet, de enlace, de disco de repositorio ni de ruta MPIO.

**HECHO.** El clúster tenía tres caminos de heartbeat IP independientes más disco de repositorio con respaldo.

**INFERENCIA.** Perder el heartbeat por los tres caminos a la vez no se explica con la falla de una interfaz. Las lecturas compatibles con la evidencia son dos: un evento de red que afectó al segmento completo, o un problema del propio nodo DCMSIF01. **La evidencia disponible no permite distinguirlas**, porque no existe ningún archivo de DCMSIF01.

**HECHO.** Lo que sí está probado es que la configuración no tenía nada que impidiera la toma de control: sin `netmon.cf` el clúster no puede validar si el problema es local, y con la política en `None` y sin tie breaker, la isla que conserva el quórum procede sin arbitraje.

**Formulación responsable de la causa**: el disparador no está determinado. El mecanismo que convirtió el disparador en una toma de control indebida con reversión fallida **sí lo está**, y son los defectos F-01, F-02 y F-03.

---

## 6. Anomalías concurrentes en otra máquina

Se registran aparte porque corresponden a un sistema distinto y su relación con el incidente no está establecida.

**HECHO.** En la máquina DCMSIF02N2 del clúster nuevo, el mismo día: la cadencia de cron se detuvo entre las 12:31:01 y las 13:02:07; el tráfico de en0 cayó de 5,750 a 145.6 KB/s a las 12:33:17 y se recuperó hacia las 13:02; la carga de CPU bajó de 23% a 11% en esa ventana; ocho sesiones interactivas humanas entraron entre las 12:34:08 y las 12:39:51; los diagnósticos de red fuera de cadencia empezaron a las 12:38:13.

**HECHO.** Esa máquina mantuvo entre 226 y 237 procesos `oninit` de forma continua todo el día, sin reinicio del motor.

**INFERENCIA.** La coincidencia temporal entre ambas anomalías es estrecha y los dos sistemas comparten el segmento 10.36.197.0/24 y la misma puerta de enlace. Un evento de red de segmento explicaría ambas. **No está probado.**

---

## 7. Datos requeridos

### Equipo de redes, prioridad uno

**R1.** Historial de la tabla `State Transitions` para `10.36.197.51` el 8 de octubre entre las 11:45 y las 13:30, **con las direcciones MAC de cada aprendizaje**. Sale vacía en las dos capturas aportadas, y es justo donde vive el historial. La MAC identifica qué adaptador físico reclamó la dirección, y con eso se cierra el origen.

**R2.** Faults de movimiento de endpoint y activación de **Rogue Endpoint Control** sobre el EPG `EPG_1_USUARIOS` y los vPC `vPC_BC_IBMPower880` y `vPC_BC_IBMPOWER10_Po3` en esa ventana. Importa porque, si la fabric puso el endpoint en cuarentena, la acción pudo afectar al vPC completo y no solo a la `.51`, lo que explicaría la pérdida de heartbeat de las 12:44 en las redes `7.36.x`, que no tienen relación con la dirección duplicada.

**R3.** ¿Se duplicaron también `10.36.198.51` y `10.36.199.51`? Es un discriminador de alto valor: si las tres se duplicaron juntas, el disparador levantó el juego completo de etiquetas de migración, lo que apunta a un mecanismo de clúster o de arranque. Si solo se duplicó la `.51`, apunta a una acción puntual.

### Caso abierto con IBM

**I1.** Qué puede configurar la etiqueta `DCMSIF01_SRV` en el nodo del clúster viejo: resource group residual, alias en `/etc/rc.net`, script de arranque o entrada heredada.

**I2.** Los tres defectos de configuración documentados aquí, que son hallazgos válidos para el mismo caso: `netmon.cf` vacío, política de partición en `None` sin desempate, y `SIFHAOFF.sh` no idempotente.

### Evidencia pendiente

1. `/var/hacmp/` completo del nodo **DCMSIF01 del clúster DCMSIF**, identificador 1471564138, del 8 de octubre, más su `errpt -a` y su telemetría.
2. `lscluster -i`, `lscluster -m`, `lscluster -d` y `clctrl -tune -a` de ambos nodos del clúster DCMSIF.
3. Contenido de `SIFHAON.sh` y `SIFHAOFF.sh`.
4. Logs del VIOS que da servicio a las LPAR y del switch, ventana 12:30 a 13:05. Las interfaces son virtuales l-lan y ninguna es troncal, por lo que el estado del enlace físico solo existe en el VIOS.
5. `clmgr query cluster` posterior al incidente, para confirmar que la política no cambió durante la recuperación y para establecer el origen del valor 360.
6. Confirmación de cómo se cerró el `TE_RG_MOVE_RELEASE` que quedó abierto, y si las direcciones 10.36.198.146 y 10.36.199.129 fueron liberadas manualmente.
7. Mapeo autoritativo de LPAR, hostname AIX y nodo PowerHA para los cuatro servidores involucrados.

---

## 8. Errores de la versión 1.0, corregidos aquí

Se dejan registrados para que no se repitan.

**E-01.** Se afirmó que el nodo pasivo tomó la dirección `DCMSIF01_SRV` en 10.36.197.51. Falso. Tomó `DCMSIF01_SRVN` en 10.36.197.207. El error vino de leer una caché de configuración de enero de 2023 en lugar del ODM vigente.

**E-02.** Se afirmó que hubo una parada administrativa del clúster entre las 02:25 y las 03:53 de esa madrugada. Falso. Esos eventos son del 8 de octubre de **2023**. El `cluster.log` de AIX es acumulativo desde 2019 y el formato syslog no escribe el año. Verificado por el sello interno de `clstrmgrES` y por la existencia de un archivo `cluster.10082023` separado.

**E-03.** Se afirmó que el clúster llevaba dos semanas sin reportar a SNMP. El mensaje es real y de 2026, pero pertenece al nodo DCMSIF02N2 del clúster nuevo, no al clúster DCMSIF.

**E-04.** Se afirmó que la ventana del incidente se había perdido por rotación de `clstrmgr.debug`. La rotación es real, pero el paquete FFDC conservó copias que cubren de 12:23:15 a 12:50:59. La evidencia estaba disponible.

**E-05.** Se afirmó que la asimetría entre nodos estaba probada porque el nodo productivo no registró nada. Inválido: el bundle usado como nodo productivo pertenece a otro clúster.

**Lección de método.** Dos agentes del enjambre cometieron además un error cada uno, detectados por contraste: uno negó que `hacmp.out` tuviera entradas del 8 de octubre de 2026 (tiene 86, mezcladas con 52 de 2023) y otro negó que el errpt del nodo pasivo tuviera entradas de ese día (tiene 76). Ningún resultado de agente debe incorporarse sin cruce.

---

*Versión 3.0, 2026-10-12. Incorpora la evidencia de APIC aportada por el equipo de telecomunicaciones, identifica la causa como duplicidad de `10.36.197.51` entre el POWER8 y el POWER10 con la renumeración incompleta del `/etc/hosts` como condición habilitante, y reclasifica los eventos del clúster a partir de las 12:44 como efecto de segundo orden. Sustituye la v2.0 del 9 de octubre, que dejaba el disparador sin determinar, y la v1.0, cuyas atribuciones eran incorrectas.*

# BUS — Application Modernization Agent
# togaf_type: integration
# togaf_state: baseline
# togaf_system_of: record
# togaf_abb: enterprise-service-bus
# bian_domains: ["Channel Activity Analysis", "Transaction Engine"]

> **Estado:** `[STATE: ACTIVE]` — sistema abierto el 2026-11-04 por **Regla B9**, con brain v1.0.0 construido el mismo día.
> **Evidencia fundacional:** `source/logs/revision-bus-20261030` y `revision-bus-20261031`, 44 archivos con 4,132,180 trazas.
> **Descubierto al clasificar** dos capturas del canal de sucursal que traían mezclados los logs de tres capas distintas.

---

## Qué es este sistema

El BUS es el **bus de servicios empresarial** de BanCoppel. Es la capa por la que los canales llegan a los sistemas de negocio: la sucursal, la app móvil, los corresponsales, los pagos de servicios y las remesas entran por aquí.

Es **IBM Integration Bus**, no MuleSoft. El análisis de código de SIWEB ya lo había identificado como `IBM BUS (IIB/ACE)`, siglas de IBM Integration Bus y de su sucesor App Connect Enterprise; esta captura confirma el producto en ejecución, aunque no cuál de las dos versiones. La evidencia es directa: los stack traces de error traen `com.ibm.broker`, que es el paquete del broker de IBM, junto con código propio del banco en `com.bancoppel.huellas` y `com.bancoppel.one`. El log es XML con el namespace `http://www.bancoppel.com/Logger`, un formato de bitácora construido en casa.

Esto deja clara una frontera del inventario: existe `systems/integration/MuleSoft/` en estado `DISCOVERED` desde agosto, y son productos distintos. Queda pendiente confirmar con el equipo de integración cómo delimitan uno frente al otro.

Lo que aporta de nuevo esta evidencia no es el nombre del producto sino **la magnitud y la forma del tráfico**: qué servicios expone, quién los llama, con qué volumen y qué se rompe.

### Nodos observados

Corre distribuido sobre PureSystems, en cuatro nodos rotulados por el equipo como BUS1 a BUS4.

| Nodo | Servidor |
|------|----------|
| BUS1 | `puresys10` |
| BUS2 | `puresys13` |
| BUS3 | `puresys23` |
| BUS4 | `puresys24` |

### Cómo llega el tráfico: el plugin del IBM HTTP Server

Esto no sale del log de este sistema sino del `plugin-cfg.xml` de los servidores web que están al frente, y es la pieza que faltaba para entender la capacidad. **IBM HTTP Server**, el servidor web de IBM, corre en puresys14 y puresys22 frente al bus: ahí llegan los POST de la sucursal a `/bancoppel/{Servicio}`, y su **plugin** —el componente que decide a qué clúster y a qué puerto va cada ruta— los enruta a un clúster por servicio, cada uno en su propio puerto.

| Clúster | Servicio | Puerto | Servidores | Límites |
|---------|----------|--------|-----------|---------|
| `Cluster_6` | Caja | 7806 | puresys13, 10, 24, 23 | **MaxConnections 80/90 por proceso del servidor web**, ConnectTimeout 20 s, ServerIOTimeout 120 s, ServerIOTimeoutRetry -1, RetryInterval 60 |
| `Cluster_29/42` | CajaCliente | 7826 | 4 nodos | Sin límites |
| `Cluster_3` | Cliente2 | 7803 | 4 nodos | Sin límites |
| `Cluster_8` | Huella REST | 7080 | solo puresys13 y 10 | Sin límites |
| `Cluster_27` | CajaReportería y BiometriaFacial | 7824 | puresys13 y 10 | Sin límites |

**`Cluster_6` es el único de los 72 clústeres con límites por servidor.** Sus cuatro servidores son los cuatro nodos de este sistema. Eso explica por qué Caja se cae y `CajaCliente` y `Cliente2` no, aunque corran sobre los mismos nodos: el estrangulamiento está en el plugin, no en el bus.

### El punto ciego de esta evidencia

**Cuando el plugin no logra conectar, el bus no registra nada.** El diagnóstico de octubre lo verificó: durante las horas de degradación no hay errores de Caja en el log del bus, porque las conexiones fallidas nunca llegan al flujo. El cuello está en el listener HTTP del grupo de ejecución, en el backlog o en la red entre el servidor web y los nodos.

La consecuencia para este brain es directa: **mide lo que entró, no lo que fue rechazado en la puerta**. Las capturas del 30 y 31 de octubre caen dentro de la ventana del patrón diario, con las 11 y las 12 horas como horas pico, y el 30 estaba marcado como día de riesgo alto en el pronóstico de ese mismo diagnóstico. No aparece nada anómalo en el log, y eso no significa que no haya pasado: significa exactamente lo que el diagnóstico predice. Para ver ese evento hay que leer el `http_plugin.log` y el `error.log` del servidor web, no este sistema.

---

## Lo que dice la evidencia

Dos capturas de cuatro a cinco horas cada una, del 30 y 31 de octubre de 2026, en la franja de las 10 a las 14 horas.

| Métrica | Valor |
|---------|-------|
| Trazas registradas | 4,132,180 |
| Trazas con `estatus` de error | 324,872 |
| Proporción con estatus de error | 7.9% |
| Servicios distintos | 110 |
| Operaciones distintas | 685 |
| Stored procedures del core invocados | 684, de los cuales 595 confirmados contra el brain de Informix |
| Pares servicio a procedure | 701 |

### Los servicios con más tráfico

| Servicio | Llamadas | Con estatus de error |
|----------|---------|---------------------|
| `Caja` | 745,066 | 1.6% |
| `CajaCliente` | 455,728 | 13.3% |
| `Fecha` | 312,002 | 0.0% |
| `SERVICIO` | 306,742 | 0.7% |
| `Caja2` | 261,286 | **63.7%** |
| `Huellas442` | 207,872 | 0.8% |
| `Cliente2` | 189,738 | 4.1% |
| `EdoCtaYMov` | 183,800 | 0.0% |
| `SolCred` | 168,445 | 0.5% |
| `CuentaAhorroCoppel` | 156,888 | 23.0% |

Los cuatro primeros son del canal de sucursal, y entre ellos suman más de la mitad del tráfico. `NameMatching` apunta a verificación de listas, `TokenizacionThales` al proveedor del HSM, y `NotificacionCUBVentanilla` a una obligación regulatoria de la Circular Única de Bancos.

## Advertencia sobre el campo `estatus`

**No es una métrica de salud.** El campo mezcla dos cosas que no se parecen: la falla técnica y la ausencia de datos. Las firmas de error más frecuentes lo dejan claro, porque son consultas de información opcional que legítimamente vuelven vacías:

| Firma | Veces | Qué consulta |
|-------|------|--------------|
| `ifx_bdicobranza call informix.sp_obtener_datos_cv_web` | 95,469 | Datos de cobranza del cliente |
| `ifx_bdinteg call informix.sp_consultacten2` | 59,479 | Cuenta del cliente |
| `ifx_bdicred call informix.sp_consulta_pre_aprobado` | 48,876 | Crédito preaprobado |
| `ifx_bdicheq call informix.sp_whatscoppel_consdos` | 35,732 | Alta en el canal de WhatsApp |

Que `sp_consulta_pre_aprobado` devuelva error en la mayoría de los casos es lo esperado: la mayoría de los clientes no trae un crédito preaprobado. Lo mismo con cobranza.

El contraste lo confirma. Los servicios que resuelven algo que siempre existe tienen error prácticamente nulo: `Fecha` 0.0% sobre 312,002 llamadas, `EdoCtaYMov` 0.0% sobre 183,800, `Login` 0.1%. Si `Caja2` estuviera realmente roto al 63.7%, la red de sucursales estaría detenida, y `Caja` responde con 1.6%.

**Lectura correcta:** el 7.9% global es la proporción de trazas cuyo resultado de negocio fue "sin datos" o falló, no la indisponibilidad del bus. Para medir salud real hay que separar las dos semánticas, y eso exige una sesión con el equipo de integración para clasificar por servicio cuál es cuál.

---

## La dependencia con el core, cuantificada

Esto es lo que más aporta este sistema al programa. El campo `trama` de cada traza trae la llamada literal al core, con su datasource y su stored procedure. De ahí sale el mapa que faltaba.

| Datasource | Base del core | Llamadas |
|-----------|---------------|---------|
| sin declarar | — | 1,468,693 |
| `ifx_bdinteg` | Integración, dominio D02 | 950,671 |
| `ifx_bdicheq` | Captación y cheques, dominio D04 | 533,252 |
| `ifx_bdicred` | Crédito, dominio D03 | 329,024 |
| `ifx_bdisac_remesas` | Remesas | 127,609 |
| `ifx_bdicobranza` | Cobranza | 105,111 |
| `ifx_bdisolic` | Solicitudes | 59,706 |
| `ifx_bdicheq_sd` | Captación, sobres digitales | 39,559 |
| `ifx_bdinteg_inyau` | Integración, inscripción y autorización | 33,656 |
| `ifx_bdisac` | Servicios al cliente | 29,062 |
| `ifx_intercard` | Tarjetas, dominio D16 | 20,838 |

Son **684 pares de datasource y procedure distintos**, sobre 615 procedures con nombre único y 25 datasources declarados, y **595 están confirmados contra el brain de Informix**. Los 89 restantes suman 98,340 llamadas, el 2.6 por ciento del volumen, y no aparecen en el catálogo del core: o son posteriores al snapshot del brain, o viven en bases que aún no se han inventariado. Vale revisarlos uno por uno.

El mapa completo de qué servicio resuelve contra qué procedure vive en la tabla `service_sp_map`, con 701 pares. Se consulta con `python digital-brain/brain.py rules <servicio>`.

---

### Quién entra por el BUS

El campo `sistemaOrigen` identifica al llamador, y la sucursal lo domina: `OFI_WEB` concentra 2,171,891 invocaciones, el 53 por ciento del total.

| Sistema origen | Invocaciones |
|---------------|-------------|
| `OFI_WEB` | 2,171,891 |
| `CUB_VENTANILLA` | 107,385 |
| `PAGO_SERVICIOS` | 95,463 |
| `REM_AUT_APZ` | 94,647 |
| `SOBRES_DIGITALES` | 40,187 |
| `APP_TOKENIZACION` | 28,377 |
| `OFI_WEBC` | 24,983 |
| `AU_PPCOPPEL` | 17,593 |
| `DOMICILIACION_APP` | 8,831 |
| `GEX_ROGELIO_PP` | 8,673 |
| `WSCSICGRANDATA` | 7,462 |
| `BEX` | 5,750 |

---

## Advertencia sobre el campo `sistemaOrigen`

**No sirve como inventario de sistemas sin normalizar.** Tiene 621 valores distintos, pero solo 37 tienen forma de nombre de sistema, y esos 37 cubren el 64 por ciento del volumen. El resto es ruido de tres clases:

1. **Valores vacíos o triviales.** El guion `-` aparece 511,481 veces y el literal `1` otras 162,619. Juntos son el 16 por ciento del tráfico sin origen declarado.
2. **Nombres de operación en lugar de sistema.** Entradas como `0SpObtCtesPreAprobadosNotificar`, `0AdmConsultaSuc` o `4141SpConsSolicCredMovilPopup` son operaciones, no sistemas. Algún llamador está poblando mal el campo.
3. **El mismo sistema escrito de varias formas.** `OFI_WEB`, `OFI_WEBC` y `OFIWEB` son tres grafías del canal de sucursal y hay que consolidarlas.

El extractor normaliza antes de contar, y la tabla `origin_systems` guarda la clase de cada valor. Concluir que por el BUS pasan 621 sistemas sería falso.

---

## Hallazgo operativo

**`Huellas442` falla con un `NullPointerException` cada sesenta segundos exactos.** Las referencias de la bitácora van `huellas_api_20261030_100041`, `100141`, `100240`, `100341`, sin saltarse un minuto. El mensaje es siempre `Unhandled exception in plugin method`, en `com.bancoppel.huellas`.

Son 468 errores del servicio en la captura. Sumando `HuellasHC` con 176, la biometría concentra el 78 por ciento de los 824 errores registrados.

La cadencia de un minuto clavado no parece tráfico de usuario sino un proceso programado, probablemente un chequeo de disponibilidad, golpeando un endpoint que revienta siempre en el mismo punto. Conviene descartarlo antes de que alguien lo investigue como una falla de captura de huellas de clientes.

**`Caja2` concentra el grueso de los estatus de error, y la causa es una sola consulta.** De sus 261,286 llamadas, 104,115 van a `ifx_bdicobranza.sp_obtener_datos_cv_web` y 66,495 a `ifx_bdicred.sp_consulta_pre_aprobado`. Ambas son consultas de datos opcionales, así que lo más probable es que no sea una falla sino la semántica del campo `estatus`. Confirmarlo es el primer punto del trabajo pendiente.

### Errores por servicio

| Servicio | Errores |
|----------|--------|
| `Huellas442` | 468 |
| `HuellasHC` | 176 |
| `PagoRemesasWU` | 68 |
| `EdoCtaYMov` | 31 |
| `OneClickTdc` | 30 |
| `CoppelCom` | 12 |
| `TarjetasPersonalizadas` | 7 |
| `FabricaPagoServicios` | 6 |
| `SolCred` | 5 |
| `RemesasAPPRIZAAutomaticas` | 5 |

---

## Glosario de este sistema

Los términos de infraestructura que aparecen arriba están definidos en `knowledge-base/vocab/vocab-bus-v1.json`, y desde ahí entran al vocabulario del programa como propuestas (Regla V1: este sistema aporta, bank-brain cura). Se consultan con `SELECT meaning FROM terms WHERE term = ?` contra `bank-brain.db`.

El que más vale aclarar, porque es el centro del diagnóstico de capacidad:

**Grupo de ejecución** (*Execution Group*, a veces abreviado EG, renombrado **Integration Server** por IBM a partir de la versión 10). Es el proceso que ejecuta los flujos de mensajes. No es una agrupación lógica: es un proceso del sistema operativo, con su propia máquina virtual de Java, su propio pool de hilos y su propio listener HTTP en su propio puerto. De ahí sale el mapa de puertos de la tabla de arriba, un grupo de ejecución por familia de servicios.

**Es la unidad que se satura**, y eso explica lo que de otro modo no cuadra: por qué el 16 de octubre de 2026 se cayó Caja y no CajaCliente ni Cliente2, si los tres corren en los mismos cuatro nodos. Corren en el mismo hardware pero en procesos distintos, con pools de hilos distintos. El vecino saturado no contagia al de al lado.

Los otros trece términos del archivo cubren el servidor web y su plugin, `MaxConnections`, el backlog, el listener, el servidor de aplicaciones y su WebContainer, la partición lógica, el entitlement y la consola de administración de hardware.

---

## Relación con otros sistemas

| Sistema | Relación | Dirección | Evidencia |
|---------|----------|-----------|-----------|
| `SIWEB` | `calls` | `inbound` | `OFI_WEB` origina 2,171,891 invocaciones, el 53 por ciento del tráfico |
| `informix` | `calls` | `outbound` | 615 procedures distintos, 684 pares con datasource, sobre 25 datasources declarados; el detalle en `informix_sp_calls` y `service_sp_map` |

El canal de sucursal no toca Informix de forma directa: pasa por aquí. Eso ya estaba registrado como conocimiento tribal y esta captura lo cuantifica por primera vez.

---

## Evidencia previa en otro sistema

Existe una captura anterior de este mismo artefacto en `systems/core/Informix/source/logs/2026-04-24/`, con 13 archivos `errores_bus_20260424_*.txt`. Es la que alimentó `output/log-analysis/sp-frequency.json` y las columnas `sps.prod_*` del brain de Informix. Pertenece a este sistema y conviene reubicarla o, al menos, declarar que el BUS es su generador.

---

## Lotes de evidencia

| Lote | Fecha | Nodos | Archivos | Carpeta de origen |
|------|-------|-------|----------|-------------------|
| `revision-bus-20261030` | 2026-10-30, 10 a 14 h | BUS1 a BUS4 | 36 procesados de 37 | `REVISION-SIWEB-30OCT26` |
| `revision-bus-20261031` | 2026-10-31, 10 a 13 h | `puresys24` | 8 | `REVISION-IHS17y18-31OCT2026` |

Ambas capturas llegaron rotuladas como revisiones de otros sistemas, con los logs de tres capas mezclados en la misma carpeta. Se separaron por capa tecnológica: el servidor web IBM HTTP Server fue a SIWEB, el servidor de aplicaciones WebSphere Application Server a Informix y el bus aquí.

El lote del 30 incluye un `var.logt.tar` de 0.43 GB en BUS3 que no se ha abierto.

En ese mismo lote, `transacciones_bus_20261030_11.txt` de BUS4 llegó duplicado con sufijo `(1)`, idéntico byte a byte. El extractor lo descarta por firma de contenido; contarlo habría inflado la volumetría en 184,457 trazas. El archivo se conserva en `source/` porque la evidencia no se modifica.

La carga está bien repartida entre los cuatro nodos del 30 de octubre: entre 773,046 y 982,012 trazas cada uno.

---

## Pipeline de reconstrucción

```bash
python generators/parse-bus.py              # destila los logs a digital-brain/data/
python digital-brain/build-brain.py --reset # construye el brain
python digital-brain/brain.py               # verifica
```

### El log viene sucio y hay que acotarlo

El escritor del BUS corta líneas a la mitad y concatena el siguiente registro en la misma línea. Si los campos se capturan sin acotar, la lectura cruza la frontera del registro y se traga el XML completo del siguiente, incluido su `idTrxGlobal`. Eso ensuciaba los catálogos con claves falsas y arrastraba identificadores de cliente a los artefactos. Los campos de texto se leen con `[^<]*` por esa razón, y el `trama` se corta en cuanto aparece el marcador del registro siguiente.

Además, algunos procedures devuelven bloques hexadecimales y bytes nulos en crudo, entre ellos los de PIN como `sp_confirmapinoffline`. La firma de error normaliza todo eso: quita caracteres de control, enmascara tiras hexadecimales y sustituye números y valores entre comillas.

El extractor descarta archivos duplicados por firma de contenido antes de procesar, porque las descargas de Drive repiten archivos con sufijo `(1)`. En este lote descartó uno de 82 MB que inflaba la volumetría en 184,457 trazas.

El build cruza cada procedure contra el brain de Informix en tiempo de construcción y guarda el resultado localmente, así que el brain sigue siendo autosuficiente (Regla B1).

Consultas útiles: `brain.py rules <servicio>` para el mapa de ruteo, `brain.py core` para los procedures, `brain.py origins` para los sistemas origen ya clasificados, `brain.py unconfirmed` para los procedures que el core no reconoce, `brain.py errors` para las firmas.

---

## Sobre el catálogo ETB

El catálogo describe capacidades de **negocio**, y un bus de integración no es una de ellas: es el habilitador técnico por el que otros sistemas ejercen las suyas. Por eso ninguna L3 se marca como propia de este sistema. El catálogo se embebe igual, porque es el vocabulario compartido de la flota y permite federar (Regla B2).

Su aporte se ve en las capacidades de los sistemas que conecta, no en una fila propia.

---

## Lo que declaran las fuentes documentales

Todo lo anterior sale de las trazas. Hay cuatro fuentes documentales que hablan del BUS, y conviene tenerlas al lado no porque agreguen volumen, sino porque donde no coinciden con el log está lo que falta por ver.

### El SUD y la tecnología declarada

`Bancoppel_SUD_IBM_BUS_20250425.docx`, resumido en el As-Is del banco, declara IBM Integration Bus como motor, IBM MQ para las colas, SOAP y REST de entrada, XML y JSON como formatos, y mapeos XSLT y XSD para las transformaciones. El desarrollo se hace con IBM Integration Toolkit y MQ Explorer; la operación se administra desde la consola web y se observa con tableros de trazabilidad de extremo a extremo.

Confirma por documento lo que los stack traces ya mostraban con `com.ibm.broker`.

### La arquitectura declarada, contra la observada

El SUD describe múltiples instancias en alta disponibilidad dentro de la red privada, cada nodo ejecutando uno o más grupos de ejecución que procesan los flujos entrantes y salientes. El log confirma los cuatro nodos sobre PureSystems. El diagrama de infraestructura del As-Is muestra dos instancias de IBM HTTP Server al frente, cuatro de Integration Bus detrás, convergencia en DB2 y salida a la nube por AWS Transfer Family con SFTP.

Ninguna de las dos fuentes da el número vigente de grupos de ejecución, y ésa es la unidad que se satura.

### Los 1,700 procedimientos declarados, contra los 684 observados

El As-Is dice que el BUS consume alrededor de 1,700 procedimientos almacenados, sobre tres bases: la central, la de imágenes y la de huellas de empleados. Estas dos capturas observan 684 pares distintos de datasource y procedure.

La diferencia no es una contradicción, es cobertura: las capturas cubren de 10 a 14 horas de dos días. Si la cifra declarada es correcta, falta por ver cerca del 60 por ciento del repertorio, y lo que falta son los procedimientos de baja frecuencia, que es justo donde viven los cierres y los procesos de excepción. Refuerza el pendiente de conseguir una captura de día completo.

Las bases de imágenes y de huellas no aparecen entre los datasources observados. O no se usaron en la ventana capturada, o entran por otra vía.

### El catálogo de interfaces se queda corto

El Catálogo de Interfaces AS-IS del Anexo 5 documenta diez interfaces para el BUS. Ocho entrantes, desde la App móvil, los motores de rostros y de huellas, SIWEB por dos vías distintas, el autenticador de BanCoppel y Coppel, los pagos de la Afore y el pago de remesas Appriza. Dos salientes, hacia DB2 para trazas y persistencia de integración, y hacia Informix para transacción y movimiento de core.

El log observa 37 sistemas origen con forma de nombre. El documento declara diez. Donde el catálogo sea la única fuente, como ocurre con la mayoría de los sistemas de la flota, conviene recordar este contraste: aquí subdeclara en una proporción de uno a tres.

Hay un cruce que importa. `OFI_WEB`, que concentra el 53 por ciento del tráfico, es la aplicación 58 del Anexo 5, la Oficina Financiera Integral. En el grafo de dependencias figura como `ofi-tradicional` y sigue sin carpeta propia, siendo el mayor consumidor de este sistema.

### El riesgo de la temporada

El análisis de estacionalidad de noviembre de 2026 a enero de 2027 coloca a Caja como el servicio peor parado de todo el banco para la temporada: uso esperado cercano al 193 por ciento contra su techo y fecha crítica el 16 de noviembre. La remediación propuesta es ampliar la capacidad antes del evento.

El diagnóstico post-incidente de octubre precisa dónde está ese techo, y no es donde yo lo había escrito. El `80 de 90` no es un límite del grupo de ejecución: es `MaxConnections` del plugin del servidor web hacia `Cluster_6`, declarado en `plugin-cfg.xml` de puresys14 y 22. `Cluster_6` es **el único de los 72 clústeres con límites por servidor**, y sus cuatro servidores son exactamente los cuatro nodos de este sistema: puresys13, 10, 24 y 23. Cuando Caja sube a unos 5 segundos, la concurrencia rebasa ese máximo en los cuatro y el plugin responde 5xx sin encontrar servidor.

El log da la contraparte: `Caja` acumula 745,066 llamadas y `CajaCliente` otras 455,728. Lo que se agota son hilos y conexiones, no CPU ni memoria, que es el patrón del legado entero: `MaxConnections` del plugin hacia Caja, el WebContainer de WebSphere y los hilos del propio servidor web. Ninguna capa satura procesador.

Es el argumento más fuerte para que este brain crezca rápido. El sistema con la mejor evidencia de ejecución del ecosistema es también el que el banco señala como el que más puede tumbar la temporada.

### Dónde están estas fuentes

| Fuente | Qué aporta |
|--------|-----------|
| `projects/unity/source/docs/DocumentosTrabajo/ArquitecturaAplicativaAsIs/BanCoppel_ASIS_Base_Conocimiento_y_Regeneracion_2.md` | Sección de KT del IBM BUS, tecnología, arquitectura, bases y topología de infraestructura |
| `.../ArquitecturaAplicativaAsIs/BanCoppel_Unity_Catalogo_Interfaces_ASIS_2_jeap.xlsx` | Las diez interfaces, con protocolo, sincronía, entidad y nivel de confianza |
| `source/docs/BanCoppel_Estrategia_Analisis_Operacion_Estacionalidad_v3 1.html`, en la raíz del proyecto | Techo observado del contexto de Caja y su uso esperado en la temporada |
| `Bancoppel_SUD_IBM_BUS_20250425.docx` | Pendiente de conseguir completo, con la hoja de interfaces que referencia |

---

## Trabajo pendiente

- [ ] Separar en el campo `estatus` la falla técnica de la ausencia de datos, servicio por servicio. Sin eso no hay métrica de salud.
- [ ] Revisar los 89 procedures que el brain del core no reconoce.
- [ ] Abrir el `var.logt.tar` de BUS3, 0.43 GB sin procesar.
- [ ] Conseguir una captura de día completo. Estas dos cubren de 10 a 14 horas y ya se vio en e-global que una franja no representa el día.
- [ ] Cargar la volumetría por procedure en `sp_metrics_daily` del brain de Informix, con fecha de evidencia propia.
- [ ] Reubicar o declarar la captura del 2026-04-24 que hoy vive bajo Informix.
- [ ] Confirmar con el equipo de integración la frontera entre este BUS y MuleSoft.
- [ ] Mapear los 37 sistemas origen reales contra el inventario de `systems/` y abrir los que falten (Regla B9).
- [x] Normalizar las grafías de `OFI_WEB`, `OFI_WEBC` y `OFIWEB`: confirmado el 2026-11-04 que las tres son **SIWEB**, el frente web. El cliente servidor se llama **OFI**, es otro aplicativo y no entra por el BUS, sino por SPL directo e InterAct. La convención del programa es nombrarlos OFI y SIWEB, nunca OFIWeb.
- [ ] Documentar el inventario de contextos de ejecución, empezando por el de Caja, antes del 16 de noviembre.
- [ ] Contrastar los 684 pares observados contra los ~1,700 procedimientos que declara el SUD, y explicar la diferencia por cobertura o por vía de acceso.
- [ ] Confirmar si las bases de imágenes y de huellas que declara el SUD entran por el BUS o por otra ruta.
- [ ] Conseguir el `Bancoppel_SUD_IBM_BUS_20250425.docx` completo y la hoja de interfaces que referencia.

---

## Seeds Emitidos

| Receptor | Archivo | Evidencias |
|----------|---------|-----------|
| `informix` | `digital-brain/seeds/informix-seed.json` | 684 procedures con datasource, dominio y volumetría |
| `siweb` | `digital-brain/seeds/siweb-seed.json` | 112 servicios con volumen y errores |

## Registro en el bank-brain

Registrado el 2026-11-04 en la tabla `systems` del bank-brain con el id `bus`, y en `system_dependencies` con dos aristas: `bus-pisa-core` hacia el core y `siweb-bus-sucursal` desde el canal de sucursal. La segunda es el primer tramo de `siweb-pisa-via-bus`, que hasta hoy se declaraba de punta a punta porque este sistema no tenía entrada propia en el inventario.

Queda una diferencia por conciliar: el brain de SIWEB cuenta 2,175,659 invocaciones hacia el bus y éste cuenta 2,175,664 sumando las grafías `OFI_WEB` y `OFIWEB`. Cinco trazas, pero la dirección que declara SIWEB es `unknown` y conviene cerrarla.

El catálogo ETB se embebe por Regla B2 sin marcar ninguna L3 como propia, así que este brain aparece en `capability_alignment()` pero no aporta cobertura.

---

---

*Creado 2026-11-04 por Regla B9, a partir de la clasificación de dos capturas del canal de sucursal. Brain v1.0.0 el mismo día.*

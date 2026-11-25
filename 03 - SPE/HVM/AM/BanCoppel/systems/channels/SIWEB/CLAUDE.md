# SIWEB — Canal de Sucursal, Ventanilla y Caja (Application Modernization)
# togaf_type: channels
# togaf_state: active
# togaf_system_of: differentiation
# togaf_abb: branch-teller-web

> **Descubierto por:** Inventario de Arquitectura Aplicativa As-Is (ID 60, `OFI_WEB`) y track `siweb` del programa Unity R4.
> **Fecha de apertura de estructura:** 2026-11-04 (Regla B9).
> **Estado:** `[STATE: ACTIVE]` — brain construido sobre el fuente real. Snapshot `siweb-plataforma-promotoria-develop`, rama develop al 2026-10-08, 6,102 archivos.
> **Última actualización:** 2026-11-04 — brain v1.0.0: 858 servicios de core catalogados, 28 puentes a bases Informix, 1,390 URLs, 492 pantallas.

---

## Qué es SIWEB

SIWEB es la operación de cajero y ventanilla de las sucursales BanCoppel. Cubre caja, depósitos, retiros, remesas, alta única de clientes y productos, mantenimiento de servicios, procesos de fin de día y conciliación. En el inventario As-Is aparece como ID 60 con el alias `OFI_WEB`, clasificado como Aplicación de Canal, y es uno de los dos frentes en que se desglosa OFI (Oficina Financiera Integral): OFI Tradicional es el cliente pesado en Visual Basic 6 que origina y da de alta clientes y productos, y OFI Web, que es SIWEB, es la operación transaccional diaria de la ventanilla.

**Nota de nomenclatura, y es la confusión más cara de este sistema:** SIWEB no es un portal de banca por internet para el titular. Es el sistema que usan los ejecutivos y cajeros de sucursal. El canal de banca por internet para clientes está modelado aparte, en [BancaInternet](../BancaInternet/CLAUDE.md), descubierto por seed de Informix con 89 endpoints. Son dos sistemas distintos y no deben fusionarse sin evidencia.

---

## Metadata TOGAF

| Campo | Valor |
|-------|-------|
| `togaf_type` | `channels` |
| `togaf_state` | `active` |
| `togaf_system_of` | `differentiation` |
| `togaf_abb` | `branch-teller-web` |
| `bian_domains` | — *(pendiente de mapeo)* |
| Alias en el As-Is | `OFI_WEB` (ID 60) |
| Nombre del producto en el código | CPlaSu, "BanCoppel Sucursales" |
| Proveedor | Solser, `groupId mx.com.solser.cplasu` |

---

## Dos correcciones que el código impone sobre la documentación

**El stack no es Angular.** El inventario As-Is describe SIWEB como Angular sobre WebSphere. El fuente es otra cosa: un cliente de escritorio JavaFX, con 492 vistas FXML, distribuido a las sucursales por Java Web Start mediante un JNLP que publica el módulo web `CPlaSuApp`. El backend es Spring MVC empaquetado como EAR. No hay una sola línea de Angular en el repositorio. Lo que sí hay de web es el envoltorio de distribución del cliente, y es probable que de ahí venga la confusión y el nombre del sistema.

**El proveedor no es interno.** El DT del track en Unity R4 registra "Proveedor: Interno BanCoppel" y concluye que eso elimina el riesgo de contratación. El `groupId` de los diez módulos Maven es `mx.com.solser.cplasu` y el módulo de controles de interfaz se llama `ControlesSolser`: el desarrollo es de Solser. Conviene validarlo con el equipo antes de mover el riesgo del track, porque la operación sí puede ser interna aunque el desarrollo no lo sea.

---

## La arquitectura que gobierna el brain: SIWEB no toca Informix

Esta es la pieza que decide cómo se modela todo lo demás. SIWEB no abre conexiones JDBC contra el core. Cada operación de core se pide al BUS por un identificador numérico de web service, declarado en el enum `IdentificadorWebService`, desde un DAO dedicado por base de datos en `persistence/databases/ws/`. El transporte no es JAX-WS: es XML armado a mano, enviado con Apache HttpClient y leído de vuelta con Jsoup. La URL del BUS no vive en el repositorio, se lee en arranque de un archivo de propiedades externo (`Parametros.java`).

Eso confirma al pie de la letra lo que decía el As-Is: las vías válidas al core son tres y SIWEB usa la del IBM BUS. Para la modernización significa que el contrato a preservar no es un inventario de stored procedures sino **858 identificadores de servicio**, cada uno con su firma de parámetros y su mapeo de respuesta.

Existe además una capa anterior, de acceso directo: quince enums `SP*.java` con 240 sentencias `EXECUTE PROCEDURE` contra bases Informix. **Ninguna está en uso.** La única referencia en todo el código está comentada, en `BDIntegWs.java`. Es el fósil del acceso directo previo al BUS y el brain lo conserva marcado como `sin-uso` para que nadie lo lea como dependencia viva ni como inventario de SPs del canal.

---

## Estado del brain (2026-11-04)

| Métrica | Valor |
|---------|-------|
| Versión | `1.0.0` |
| Snapshot del fuente | `siweb-plataforma-promotoria-develop`, rama develop al 2026-10-08 |
| Archivos del fuente | 6,102 (4,975 Java, 492 FXML, 10 reportes Jasper) |
| Módulos Maven | 10 en un reactor |
| Servicios de core catalogados | **858** identificadores, 810 de ellos invocados |
| Invocaciones de servicio | 872, atribuidas a su método |
| Puentes a bases de datos | **28** |
| URLs del canal | 1,390 en `UrlConstantes`, 1,297 publicadas por un controlador |
| Pantallas FXML | 492 en 29 áreas funcionales |
| Stored procedures heredados | 240 en 15 bases, 0 en uso |
| Integraciones fuera del catálogo | 72 |
| Cross-dependencies documentales | 9 |

### Reparto por módulo

| Módulo | Empaque | Java | Rol |
|--------|---------|------|-----|
| `CPlaSuCommons` | jar | 2,999 | Beans de request y response, utilerías y el catálogo de URLs |
| `CPlaSuFX` | jar | 857 | Cliente JavaFX de ventanilla: vistas, controladores y servicios de interfaz |
| `CPlaSuService` | war | 636 | Backend Spring MVC con los 1,297 endpoints publicados |
| `CPlaSuPersistence` | jar | 430 | DAOs contra el BUS, enums heredados y clientes HTTP |
| `ControlesSolser` | jar | 52 | Controles de interfaz del proveedor, comentado fuera del reactor |
| `CPlaSuApp` | war | 0 | Publica el cliente por Java Web Start (JNLP) |
| `EARCPlaSuApp`, `EARCPlaSuService` | ear | 0 | Empaquetado para el servidor de aplicaciones |
| `report-compiler` | jar | 1 | Compilador de reportes JasperReports |

### Puentes al core, por volumen de servicios distintos

| Base | DAO | Servicios | Lectura |
|------|-----|-----------|---------|
| `BDINTEG` | `BDIntegWs` | 223 | Cliente, catálogos, huella y validaciones. Es el corazón del canal |
| `BDICRED` | `BDIcredWs` | 124 | Crédito y préstamos |
| `BDICHEQ` | `BDIcheqWs` | 117 | Cheques y cámara de compensación |
| `BDISOLIC` | `BDIsolicWs` | 74 | Solicitudes y originación |
| `BDISUC` | `BDIsucWs` | 54 | Operación de sucursal, caja, billetes y monedas |
| `BDISAC`, `INTERAPI`, `BDIPROG`, `BDIBPI` | — | 17 a 24 | Captación, API interna, programación de transacciones y BPI |
| 19 bases más | — | 1 a 16 | Incluye `AIDABAN` y `COPPEL`, que no son bases Informix del core y hay que clasificar |

---

## Federación: cómo encaja este brain con el resto de la flota

El brain es autosuficiente (Regla B1) y al mismo tiempo está conectado por las dos vías que usa el ecosistema. Su esquema es el de la flota: `system_info`, `cross_dependencies` con `other_system` y `relationship`, y `signals`, las mismas columnas que declara el brain de e-global, que es el precedente de un brain maduro nacido de un seed.

| Pieza | Estado | Dónde |
|-------|--------|-------|
| API de agente, cinco métodos de Regla B1 | Activa | [brain.py](digital-brain/brain.py) con `coverage`, `components`, `search`, `rules` y `domains`, más métodos propios del canal |
| Seeds emitidos (Regla B11) | 4 | `digital-brain/seeds/` hacia Informix, SmartVista, e-global y Western Union |
| Seeds recibidos (Regla B12) | 1 | Informix declara a SIWEB como consumidor crítico y el seed entra como `cross_dependency` con `emitter = informix` |
| Registro en el federador | Activo | `bank-brain` tabla `systems` como `siweb`, más dos filas en `system_dependencies` |
| Lado de Informix (Regla B10) | Declarado | `pisa-siweb-ventanilla`, crítico, inbound, en el `cross_dependencies` del brain del core |

El seed que SIWEB le manda a Informix no es una lista de stored procedures, porque el canal no los invoca. Es el censo de bases de datos alcanzadas a través del BUS, con cuántos servicios y métodos las atienden, y una nota que dice explícitamente que el destino lo declara el DAO y no una conexión JDBC. Mentir ahí habría contaminado el inventario del core.

Para que Informix supiera de SIWEB hubo que declararlo a mano en su lado. El canal no aparecía en su tabla `external_systems` porque ese censo se arma del tráfico del ESB, donde SIWEB llega mezclado y sin nombre propio. Inventar una fila ahí habría sido falsificar evidencia; la dependencia declarada, con su cita, es el registro honesto.

**`emitter` distingue lo propio de lo ajeno.** Cada fila de `cross_dependencies` dice qué brain la escribió. Lo que este pipeline deduce se recalcula en cada build; lo que sembró otro sistema sobrevive al `--reset`. Sin esa columna, cada reconstrucción borraría la mitad ajena del puente.

---

## Cross-dependencies conocidas antes del código

Estas vienen de documentación y se conservan como capa documental del brain, separadas de lo que probó el código.

| Sistema | Relación | Dirección | Evidencia |
|---------|----------|-----------|-----------|
| Informix PISA | `calls` | outbound | En consultas desde SIWEB el BUS consulta Informix para datos del cliente y validaciones de existencia y lista negra |
| IBM BUS (IIB/ACE) | `calls` | outbound | Vía válida al core. **Confirmada por el código**: todo el acceso a datos pasa por ahí |
| Gestor Central de Huellas | `calls` | outbound | Web Service de autenticación por huella para OFI y SIWEB, contra `bdinteg` |
| BTS Monterrey (remesas) | `calls` | outbound | Ruta F5, IHS 15.27.31.14:7801, JBoss Remesas WEB BTS, nube GlobalPlatform |
| Western Union Culiacán | `calls` | outbound | Ruta F5, IHS 10.27.30.28:7808, gateway `eugateway2.westernunion.net` |
| Banca Empresarial | `peer` | unknown | Las órdenes de pago entre sucursales se generan desde SIWEB o desde Banca Empresarial |
| SmartVista | `calls` | outbound | Transacción 623 de compras diferidas MCI, vía DPP |
| E-Global | `calls` | outbound | Compras diferidas MSI |
| OFI Tradicional | `peer` | unknown | El As-Is marca el enlace canal a canal como probable falso positivo. Validar contra SUD |

---

## Evidencia de producción: logs del front HTTP (2026-11-04)

Llegaron dos capturas del canal, del 30 y 31 de octubre de 2026, rotuladas como revisiones y con los logs de tres capas mezclados en la misma carpeta. Se separaron por capa tecnológica. A este sistema le corresponde el **IBM HTTP Server**, que vive en `source/logs/revision-sucursal-20261030` y `revision-sucursal-20261031`, sobre los nodos `puresys14`, `puresys17`, `puresys18` y `puresys22`.

Las otras dos capas fueron a donde corresponde: el WebSphere del clúster `OfiWeb` a `systems/core/Informix/source/logs/revision-ofiweb-*`, por continuidad con el análisis de la capa SOAP que ya existe ahí, y el bus al sistema nuevo `systems/integration/BUS/`.

### Lo que confirman los accesos

Las rutas más pedidas en la franja de las 10 a las 14 horas son las del canal:

| Ruta | Peticiones en un día |
|------|---------------------|
| `POST /bancoppel/Caja` | 802,643 |
| `POST /bancoppel/CajaCliente` | 570,052 |
| `POST /bancoppel/CajaCaptacion` | 389,340 |
| `POST /bancoppel/ObtenerFec` | 377,627 |
| `POST /bancoppel/SolicitudesCred` | 288,552 |
| `POST /bancoppel/Caja2` | 266,111 |

En los nodos `puresys17` y `puresys18` el perfil es distinto y revela el otro frente del canal: `/CajaNacionalApp/` y `/CajaNacionalServ/*.go` con cientos de miles de llamadas, más `/BcplSucApp/`, que es desde donde la terminal de sucursal descarga `CPlaSuFX.jar`. Es la confirmación operativa de que el cliente JavaFX se distribuye por este mismo front.

También aparecen `PUT /v1/huellas/clientes` con 507,871 peticiones y `POST /notificacion/cub/ventanilla/v1/actualiza` con 348,960, que son las dos rutas REST modernas conviviendo con los servlets.

### El BUS quedó identificado y cuantificado

La tabla de arriba registraba `IBM BUS (IIB/ACE)` como la vía válida al core. La captura lo confirma en ejecución: los stack traces del bus traen `com.ibm.broker`, o sea IBM Integration Bus, y ahora existe `systems/integration/BUS/` con su propia evidencia.

Lo que aporta de nuevo es la magnitud de esta dependencia. En 4,315,800 invocaciones registradas en el bus, el sistema origen `OFI_WEB` aparece **2,289,003 veces, el 53 por ciento del tráfico total**. El canal de sucursal no es un cliente más del bus: es su carga principal. Para la modernización eso sube el peso de los 858 identificadores de servicio como contrato a preservar.

---

## Alcance en el programa Unity R4

El track `siweb` del programa vive en [dt-siweb.md](../../../projects/unity/dt/dt-siweb.md) y en `projects/unity/digital-brain/brain.db`. Son 5 User Stories, todas Should, sobre compras diferidas MCI y MSI operadas desde caja, en RAG amarillo general y rojo en integraciones, bloqueadas esperando las APIs de Apificación. Ese track describe el futuro de SIWEB en R4. Este sistema describe el presente: lo que el código hace hoy. Los dos brains conviven y no se sustituyen.

---

## Pipeline

```bash
python rebuild-portal.py            # brain y portal de punta a punta
python rebuild-portal.py --portal   # solo las vistas, sin tocar el brain
python digital-brain/build-brain.py --reset   # solo el brain
```

Reproducible e idempotente. Lee de `source/code/` y no escribe nada fuera de `digital-brain/brain.db` y `portal/`. Tarda alrededor de diez segundos en recorrer los 4,975 archivos Java.

| Patrón | Qué extrae | Estado |
|--------|-----------|--------|
| W1 | Constantes del enum `IdentificadorWebService`, con su sección funcional | Activo |
| W2 | Usos de cada servicio, atribuidos a su DAO, base de datos y método | Activo |
| E1 | Enums `SP*.java` con `EXECUTE PROCEDURE`, marcados por uso real | Activo |
| E3 | Constantes de `UrlConstantes` | Activo |
| E4 | Mapeos Spring que publican cada URL y clases que la consumen | Activo |
| V1 | Vistas FXML y su área funcional | Activo |
| I1 | Clientes HTTP, parseo Jsoup, JDBC directo y URLs embebidas | Activo |
| B11 | Emisión de seeds a los vecinos al cerrar el build | Activo |
| B12 | Consumo de los seeds dirigidos a SIWEB y preservación de lo ajeno en el `--reset` | Activo |

---

## Portal

Sigue el canon del portal de Informix: dos arquetipos, una landing con barra de navegación y páginas de contenido con barra superior, migaja y filtros. El chrome vive en `generators/_canon.py` con la paleta del Design Studio. Ninguna cifra se escribe a mano en el HTML, todas salen de `brain.db`.

Servir con `python -m http.server 3200 --bind 127.0.0.1` desde la carpeta del sistema. El puerto 3200 es el de SIWEB, igual que el 3100 es el de AppMovil.

| Página | Generador | Qué muestra |
|--------|-----------|-------------|
| [index.html](portal/index.html) | `build-portal.py` | Landing: cifras del canal, el hallazgo de arquitectura, las correcciones y los hallazgos abiertos |
| [core-siweb.html](portal/core-siweb.html) | `build-core-portal.py` | Los 28 puentes de datos y los 858 servicios de core, con el DAO y el método de cada invocación |
| [endpoints-siweb.html](portal/endpoints-siweb.html) | `build-endpoints-portal.py` | Las 1,390 URLs del canal, cuáles publica un controlador y cuáles no |
| [pantallas-siweb.html](portal/pantallas-siweb.html) | `build-views-portal.py` | Las 492 pantallas FXML agrupadas en 29 áreas funcionales |

Cada vista deja su JSON y su CSV en `portal/data/`, así que el dato se puede llevar a Excel sin volver a consultar el brain.

---

## Hallazgos abiertos

- **18 identificadores de servicio comparten número con otro.** El id `0` lo usan cuatro constantes distintas. Puede ser alias legítimo o error de catálogo; hasta resolverlo, el número no es clave única y el brain usa el nombre de la constante.
- **48 servicios declarados nunca se invocan.** Candidatos a catálogo muerto, a confirmar contra el BUS.
- **93 URLs declaradas sin controlador que las publique.** Mismo patrón que el anterior, del lado del canal.
- **`AIDABAN` y `COPPEL` aparecen como puentes de datos** junto a las bases Informix. No son bases del core bancario y hay que clasificarlas antes de usar el conteo de 28 como número de bases Informix tocadas.
- **La URL del BUS no está en el repositorio.** Vive en un archivo de propiedades de despliegue. Sin él no se puede reconstruir el mapa de ambientes.

---

## Próximos pasos

- [ ] Clasificar los 28 puentes: cuáles son bases Informix del core y cuáles son otro sistema
- [ ] Reconciliar los 858 servicios contra el inventario de SPs del brain de Informix, para saber qué toca realmente cada uno
- [ ] Resolver los 18 identificadores compartidos con el equipo del BUS
- [ ] Resolver si el IBM BUS merece sistema propio bajo `systems/integration/`: hoy es la única vía de SIWEB al core y no tiene carpeta ni brain
- [ ] Emitir seed hacia BancaInternet si se confirma que comparten algo, que hoy no está probado
- [ ] Abrir los Digital Twins del canal, empezando por el puente al core y por las áreas de caja y alta única
- [ ] Confirmar o descartar el enlace OFI y SIWEB contra el SUD
- [ ] Verificar con el equipo si Solser es el proveedor de desarrollo, y corregir el riesgo de contratación del track en Unity

---

*Estructura abierta por Regla B9 el 2026-11-04. Evidencia de descubrimiento: inventario As-Is ID 60 y track `siweb` de Unity R4. Brain construido sobre el fuente el mismo día.*

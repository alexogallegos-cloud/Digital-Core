# Vocabulario AppMovil — Canal Móvil BanCoppel
> **Artefacto central de**: `dt-vocabulario`
> **Proyecto**: BanCoppel Application Modernization · `SPE-AM-001`
> **Versión**: 0.2.0 — 2026-08-14
> **Fase**: DISCOVER
> **Total de términos**: 194
> **Semilla**: vocabulario Informix `knowledge-base/vocabulary-inventory.json` (438 términos, capa core)
> **Metodología**: `methodology/metodologia-vocabulario-am.md` v1.0.0

---

## Metodología

Vocabulario construido en tres pasadas siguiendo `metodologia-vocabulario-am.md`:

1. **Semilla Informix** (F1 cross-sistema) — 12 términos del `vocabulary-inventory.json` de Informix (tabla `terms` del brain.db) que también aparecen en el canal móvil. Marcados como `HERENCIA-INFORMIX`.

2. **Minería del canal — F3 configuración** (v0.1.0) — Constants.java, EntityConstants.java, `application-dev.properties` de los MSAs de pago, sesión y depósitos. 97 términos de arquitectura, seguridad, pagos e infraestructura.

3. **Segmentación greedy de SPs — F1 identificadores** (v0.2.0) — aplicación del motor greedy longest-match a los 50 nombres de SPs del catálogo completo. Extrae términos de negocio no capturados en las pasadas anteriores. 85 términos nuevos: 40 SPs adicionales + 25 conceptos de negocio + 10 prefijos de dominio MSA + 4 BDs adicionales + 6 ítems de infraestructura Informix reclasificados.

### Esquema de cada término

| Campo | Descripción |
|-------|-------------|
| `term` | Forma canónica — como aparece en el código o properties |
| `cat` | Categoría: ENTIDAD / ACCION / PREFIJO / MODIF / REG / CONFIGURACION / ERROR / INFRAESTRUCTURA |
| `est` | Estado de evidencia: `conf` (código fuente) / `inf` (inferido) / `gap` (requiere SME) |
| `scope` | `enterprise` (cross-sistema BanCoppel) / `system` (específico AppMovil) / `review` |
| `mean` | Significado en contexto BanCoppel |
| `fuente` | Archivo donde se evidencia |

---

## Sección 1 — Términos heredados de Informix (semilla)

Términos del core Informix **referenciados** desde el canal: el canal los invoca pero la lógica vive en el SP.

| `term` | `cat` | `est` | `scope` | `mean` | `fuente` |
|--------|-------|-------|---------|--------|----------|
| `sp` | PREFIJO | conf | system | Stored Procedure de Informix invocado desde el canal vía `CallableStatement`. Todos los SPs del canal terminan en `_bex` (canal BEX) o `_bpi` (pagos interbancarios) | `Constants.java` (SP_CALL = `{call `) |
| `consulta` | ACCION | conf | enterprise | Consulta de estado de cuenta, saldo o movimientos; la capa D del canal invoca SPs de consulta en Informix — los resultados se mapean a DTOs | `msadp-d-domain-deposit-accounts` |
| `usuario` | ENTIDAD | conf | enterprise | Cliente BanCoppel que accede al canal móvil; identificado por número de cliente de 9 dígitos (`CUSTOMER_NUMBER_REGEX = "\\d{9}"`) | `msacm-p-security-session-management` |
| `empresa` | ENTIDAD | conf | enterprise | Entidad bancaria BanCoppel; `BUSINESS = "001"` — identificador de empresa en los SPs de transferencia | `msach-d-business-transfer-interbank-account` |
| `reversion` | ACCION | conf | enterprise | Reversión de una transacción; SP `bdicheq:reversion` con `type.reversion=A` — tipo A es reversión automática | `msapy-d-domain-codi-payment` properties |
| `cargo` | ACCION | conf | enterprise | Cargo/débito a cuenta del cliente; SP `bdicheq:cargo_ref` — usado en flujos de pago CoDi intrabank y servicios | `constants.api.name.spcargo=bdicheq:cargo_ref` |
| `abono` | ACCION | conf | enterprise | Abono/crédito a cuenta del beneficiario; SP `bdicheq:abono_ref` — contraparte del cargo en flujos intrabank | `constants.api.name.spabono=bdicheq:abono_ref` |
| `bitacora` | ENTIDAD | conf | enterprise | Registro de auditoría de operaciones; SP `bdicheq:sp_bitacoramtu_bpi` registra las operaciones MTU para control de límites | `constants.api.name.spMtuLog` |
| `folio` | ENTIDAD | conf | enterprise | Identificador único de una operación; `folioSuc` = folio de sucursal (≤16 chars); `BPI` = folio del sistema interbancario (≤24 chars) | `INVALID_LONGITUDE_FOLIO` en Constants.java |
| `saldo` | ENTIDAD | conf | enterprise | Saldo disponible en cuenta de depósito; consultado vía SPs de Informix D04 antes de autorizar pagos | `msadp-d-domain-deposit-accounts` |
| `cuenta` | ENTIDAD | conf | enterprise | Cuenta bancaria del cliente; identificada por CLABE (18 dígitos) o número de cuenta interno | `ACCOUNT_TYPE_STRING = "accountType"` |
| `movimientos` | ENTIDAD | conf | enterprise | Historial de transacciones de una cuenta; consultado vía SPs D04 (depósito) o D03 (crédito) | `msadp-d-domain-deposit-accounts-movements` |

---

## Sección 2 — Términos propios del canal: Arquitectura de microservicios

| `term` | `cat` | `est` | `scope` | `mean` | `fuente` |
|--------|-------|-------|---------|--------|----------|
| `msa` | PREFIJO | conf | system | Prefijo universal de todos los microservicios de AppMovil (`msa{domain}-{layer}-{function}`); abreviatura de microservicio | naming convention |
| `capa-b` | PREFIJO | conf | system | Capa Business (`-b-`): orquestación de lógica de negocio; coordina múltiples servicios de dominio; no accede a Informix directamente | naming convention |
| `capa-d` | PREFIJO | conf | system | Capa Domain (`-d-`): lógica de dominio y acceso a datos; es la **única capa que invoca SPs Informix** vía JDBC `CallableStatement` | naming convention |
| `capa-p` | PREFIJO | conf | system | Capa Platform (`-p-`): servicios de plataforma transversales — sesión, seguridad de la aplicación, configuración | naming convention |
| `capa-o` | PREFIJO | conf | system | Capa Orchestration (`-o-`): orquestación de flujos complejos multi-sistema (ej: enrolamiento de dispositivo) | naming convention |
| `@HandledProcedure` | ENTIDAD | conf | system | Anotación propia BanCoppel que marca métodos que invocan SPs Informix; nombre de la constante se declara en el atributo `name` | `msapy-d-domain-codi-payment` Constants.java |
| `doReturningWork` | ACCION | conf | system | Método de Hibernate/Spring que ejecuta código directo sobre la conexión JDBC; patrón usado por todos los MSAs de capa D para invocar `CallableStatement` | `IntrabankPayment.java` |
| `SpResponse` | ENTIDAD | conf | system | Clase de respuesta canónica de un SP Informix; encapsula el `ResultSet` retornado por el SP | referenciado en DTs |
| `CallableStatement` | ENTIDAD | conf | system | Interfaz JDBC Java para llamar SPs; se prepara con `conn.prepareCall("{call sp_name(?,?...)}")` | `Constants.java` — SP_CALL = `{call ` |
| `SP_CALL` | CONFIGURACION | conf | system | Constante `"{call "` — prefijo estándar para preparar un `CallableStatement`; todos los SPs del canal usan este patrón | `Constants.java` de múltiples MSAs |
| `SUCCESSFULL` | CONFIGURACION | conf | system | `"000"` — código de éxito retornado por los SPs Informix; el canal verifica este código antes de confirmar la operación al cliente | `Constants.java` msapy-d-domain-codi-payment |
| `ambar` | INFRAESTRUCTURA | conf | system | Plataforma interna de logging/trazabilidad de BanCoppel; el formato JSON de logs debe cumplir el schema de AMBAR; mensajes de error del canal lo referencian | `MSG_ERROR_FORMAT` en múltiples Constants.java |
| `Feign` | ENTIDAD | conf | system | Cliente HTTP declarativo (Spring Cloud OpenFeign) para llamadas inter-microservicio; errores generan `MicroserviceClientException` (código 000914) | `ERROR_FEIGN_DETAILS`, `feign.hystrix.enabled` |
| `Hystrix` | INFRAESTRUCTURA | conf | system | Circuit breaker (Netflix Hystrix); timeout default = 20,000ms; strategy SEMAPHORE; maxConcurrentRequests = 65; protege llamadas a Informix | `application-dev.properties` msapy |
| `HikariCP` | INFRAESTRUCTURA | conf | system | Pool de conexiones JDBC a Informix; max-pool-size = 8; min-idle = 3; connection-timeout = 20s; idle-timeout = 1h | `spring.datasource.hikari.*` |
| `DownstreamException` | ENTIDAD | conf | system | Excepción que indica fallo en sistema aguas abajo (Informix, MongoDB, Redis); mapeada a `000915 ExternalResourceException` | `DOWN_STREAM_EXCEPTION_NAME` en Constants.java |

---

## Sección 3 — Términos propios del canal: Seguridad y acceso

| `term` | `cat` | `est` | `scope` | `mean` | `fuente` |
|--------|-------|-------|---------|--------|----------|
| `BEX` | PREFIJO | conf | system | "BanCoppel Express" — canal principal de la app móvil; el único canal que activa el BEX Interceptor; los SPs del canal terminan en `_bex` | `valid.channels=bex,wallet,n2`, nombres de SPs |
| `BEF` | PREFIJO | conf | system | "BanCoppel Electronic Front" — nombre del cliente de la app en el User-Agent; regex: `^BanCoppel BEF/[^/]+(/(android|ios)[-][0-9]+...)?$` | `USER_AGENT_REGEX` en msacm-p-security-session-management |
| `channel_id` | CONFIGURACION | conf | system | Header HTTP que identifica el canal de acceso; valores válidos: `bex`, `wallet`, `n2`; el BEX Interceptor valida este header en cada request | `valid.channels`, `validate.channels` en properties |
| `wallet` | CONFIGURACION | conf | system | Canal de wallet digital de BanCoppel; valor válido de `channel_id`; no activa el BEX Interceptor | `valid.channels=bex,wallet,n2` |
| `n2` | CONFIGURACION | conf | system | Canal nivel 2 — acceso limitado; valor válido de `channel_id` | `valid.channels=bex,wallet,n2` |
| `JWT` | ENTIDAD | conf | system | JSON Web Token — token de autenticación del cliente; header `Authorization: Bearer {token}`; expiración genera `000902 UnauthorizedException` | `VALUE_BEARER = "BEARER"`, `BEARER = "Bearer "` |
| `Bearer` | PREFIJO | conf | system | Esquema de autenticación HTTP usado por el JWT; prefijo `Bearer ` en el header `Authorization` | `BEARER = "Bearer "` en Constants.java |
| `deviceId` | ENTIDAD | conf | system | Header HTTP con el identificador único del dispositivo móvil del cliente; validado en cada request junto con `channel_id` y `uuid` | `validate.headers=Accept,Authorization,deviceId,channel_id,uuid` |
| `uuid` | ENTIDAD | conf | system | Header HTTP de correlación de requests; generado por el cliente para trazar una petición de extremo a extremo; almacenado en MDC con clave `mdc.uuid` | `UUID_MDC_LABEL = "mdc.uuid"` |
| `MDC` | INFRAESTRUCTURA | conf | system | Mapped Diagnostic Context — contexto de logging de SLF4J; el `uuid` del request se inyecta en el MDC para que aparezca en todos los logs de la petición | `UUID_MDC_LABEL`, logging.pattern.console |
| `SSO` | INFRAESTRUCTURA | conf | system | Single Sign-On vía Keycloak (`realms.apps.bcpl-bex-osd`); el canal se autentica con Keycloak usando `grant_type=password` | `MSG_SSO_EXCEPTION`, `constants.sso.credentials.*` |
| `session_context` | CONFIGURACION | conf | system | Clave Redis donde se almacena el contexto de sesión del cliente; TTL = 1,200 segundos (20 minutos) | `constants.redis.session.context=session_context` |
| `cellphone_session_validations` | ENTIDAD | conf | system | Colección MongoDB que registra los intentos de inicio de sesión por número de celular; para prevención de fraude y bloqueos | `MONGO_COLLECTION_LOGIN_TRIES` en msacm |
| `CUSTOMER_NUMBER_REGEX` | CONFIGURACION | conf | system | `"\\d{9}"` — patrón que valida que el número de cliente BanCoppel sea exactamente 9 dígitos | `msacm-p-security-session-management` |
| `CUSTOMER_CELLPHONE_NUMBER_REGEX` | CONFIGURACION | conf | system | `"\\d{10}"` — patrón que valida que el número de celular sea exactamente 10 dígitos | `msacm-p-security-session-management` |
| `DEVICE_INFORMATION_REGEX` | CONFIGURACION | conf | system | `"^[^/]+/[^/]+(/[^/]+)*$"` — formato del header de información del dispositivo | `msacm-p-security-session-management` |
| `000028` | ERROR | conf | system | Código de sesión activa — se retorna cuando ya existe una sesión válida para el cliente | `constants.code.session.active=000028` |
| `409` | ERROR | conf | system | HTTP 409 Conflict — sesión activa en el mismo canal | `constants.code.error.activeSessionSameChannel=409` |
| `431` | ERROR | conf | system | Código de sesión activa en otro canal | `constants.code.error.activeSessionOtherChannel=431` |

---

## Sección 4 — Términos propios del canal: Pagos y SPEI

| `term` | `cat` | `est` | `scope` | `mean` | `fuente` |
|--------|-------|-------|---------|--------|----------|
| `CoDi` | REG | conf | enterprise | Cobros Digitales — sistema de pagos QR de Banxico; el canal procesa intrabank (mismo banco) e interbank (otro banco vía SPEI) | `BUSINESS_SERVICE`, `DATABASE_CALL_INTRABANK` |
| `SPEI` | REG | conf | enterprise | Sistema de Pagos Electrónicos Interbancarios; gestionado por Banxico vía CECOBAN | `bdispei:sp_regordenctecte_bex`, properties |
| `intrabank` | CONFIGURACION | conf | system | Operación dentro del mismo banco (BanCoppel → BanCoppel); `SAME_BANK_VALUE = 16` — código de banco propio en el SP | `DATABASE_CALL_INTRABANK`, `SAME_BANK_VALUE = 16` |
| `interbank` | CONFIGURACION | conf | system | Operación entre bancos distintos; `DIFFERENT_BANK_VALUE = 24` — código de banco externo en el SP | `DATABASE_CALL_INTERBANK`, `DIFFERENT_BANK_VALUE = 24` |
| `MTU` | ENTIDAD | conf | enterprise | Monto de Transacción Unitaria — límite máximo por operación individual; validado con SP `bdicheq:sp_validacionmtu_bpi` antes de ejecutar el pago | `DATABASE_CALL_MTU`, `SPECIFIC_PATH_MTU` |
| `BPI` | PREFIJO | conf | system | "BanCoppel Pagos Interbancarios" — sufijo de SPs de control de pagos y folio del sistema interbancario (≤24 chars) | nombres de SPs en properties |
| `CLABE` | REG | conf | enterprise | Clave Bancaria Estandarizada — 18 dígitos; identifica una cuenta bancaria para SPEI | referenciado en flujo SPEI |
| `pindbenef` | CONFIGURACION | conf | system | `constants.api.pindbenef=02` — código de identificación del beneficiario en el SP de CoDi; `02` = persona física | `application-dev.properties` msapy-d-domain-codi-payment |
| `payment.comission` | CONFIGURACION | conf | system | `constants.api.payment.comission=0` — comisión cobrada al cliente por la operación; 0 = sin comisión | `application-dev.properties` msapy |
| `type.reversion` | CONFIGURACION | conf | system | `constants.api.type.reversion=A` — tipo de reversión; `A` = automática (iniciada por el sistema en caso de fallo) | `application-dev.properties` msapy |
| `status.charge` | CONFIGURACION | conf | system | `constants.api.status.charge=962,100,777,404,200,614,400` — códigos de retorno del SP de cargo que el canal acepta como respuesta válida | `application-dev.properties` msapy |
| `InterCircuitBreaker` | CONFIGURACION | conf | system | Nombre del circuit breaker para llamadas CoDi interbank; se activa cuando el SP Informix no responde dentro del timeout | `INTERCIRCUITBREAKET` en Constants.java |
| `IntraCircuitBreaker` | CONFIGURACION | conf | system | Nombre del circuit breaker para llamadas CoDi intrabank | `INTRACIRCUITBREAKET` en Constants.java |
| `cellphone` | ENTIDAD | conf | enterprise | Número de celular del cliente (10 dígitos); usado como identificador en flujos de CoDi y mensajería OTP | `CELLPHONE = "cellphone"` en Constants.java |

---

## Sección 5 — Bases de datos Informix accedidas por el canal

Las diez bases de datos con llamadas JDBC confirmadas en código fuente. Cuatro (bdinvers, bdibpi, bdinteg, intercard) no estaban en el inventario original.

| `term` | `cat` | `est` | `scope` | `mean` | `fuente` |
|--------|-------|-------|---------|--------|----------|
| `bdicheq` | ENTIDAD | conf | system | Cuentas de cheques y depósitos (Dominio D04); contiene SPs de cargo, abono, transferencia intrabank, MTU y apertura CRECE — 8 SPs | `constants.api.name.spcargo=bdicheq:cargo_ref` |
| `bdispei` | ENTIDAD | conf | system | SPEI y CoDi (Dominio D08); registro de órdenes de pago y estado de operaciones CoDi — 3 SPs | `sp_regordenctecte_bex`, `sp_stscodiapp` |
| `bdicred` | ENTIDAD | conf | system | Crédito personal y tarjetas de crédito (Dominio D03); saldos, amortizaciones, disposiciones y upgrade TDC — 12 SPs | `spring.datasource.url jdbc:informix-sqli://10.28.212.229:30501/bdicred` |
| `bdiprog` | ENTIDAD | conf | system | Programas y transacciones — contiene el SP de CoDi intrabank (spsctransctaspropiascodi_bex) — 1 SP | `msapy-d-domain-codi-payment/…/Constants.java:261` |
| `bdisac` | ENTIDAD | conf | system | Servicios adicionales y captureline — pagos de servicios, familia sp_decodifica_* (12 SPs) y comisiones — 16 SPs | `ServicePaymentsConstants.java`, `captureline-operations/application-dev.properties` |
| `bdisolic` | ENTIDAD | conf | system | Solicitudes de crédito — proyección de préstamos y apertura ADN; comparte host con bdicred — 2 SPs | `msaxd-d-domain-amortization-information/application-dev.properties` |
| `bdimnsj` | ENTIDAD | conf | system | Mensajería — eventos de SMS y notificaciones push; accedida por MSAs Quarkus de mensajería — 1 SP | `msasr-d-domain-messaging-notifications/application-dev.properties:129` |
| `bdinvers` | ENTIDAD | conf | system | Inversiones y pagarés — alta de cuentas de inversión a plazo (sp_altainversion, 45 params) — 1 SP | `msadp-d-domain-promissory-account-opening/application-dev.properties:167` |
| `bdibpi` | ENTIDAD | conf | system | Pagos interbancarios de tarjeta — pago de TDC en otros bancos (sp_pgotarcredotrobco_bex) — 1 SP | `msapy-d-domain-interbank-card-payment/application-dev.properties:109` |
| `bdinteg` | ENTIDAD | conf | system | Integración — banderas SMS del cliente y validaciones de celular cancelado — 2 SPs | `msacm-b-domain-sms-cellphone-control`, `msacm-d-domain-customer-cellphone-operations` |
| `intercard` | ENTIDAD | conf | system | Sistema ICCAT — tarjetas físicas, activación y CVV dinámico; conexión JDBC separada con autenticación diferente al resto del canal — 3 SPs | `msasr-d-domain-cvv-client-cards/…/DomainConstants.java:99` |

---

## Sección 6 — SPs Informix llamados directamente por el canal

Los 50 SPs con llamada JDBC confirmada en código fuente, organizados por dominio funcional. Referencia completa con parámetros y MSAs en `portal/sp-dependencies.html`.

### py · Pagos CoDi y SPEI

| `term` | `cat` | `est` | `mean` | `BD` | `fuente` |
|--------|-------|-------|--------|------|----------|
| `spsctransctaspropiascodi_bex` | ENTIDAD | conf | Pago CoDi intrabank entre cuentas BanCoppel — 38 parámetros | bdiprog | Constants.java:261 |
| `sp_regordenctecte_bex` | ENTIDAD | conf | SPEI saliente y CoDi interbank — registra la orden de transferencia | bdispei | ApiConstants.java:271 |
| `sp_regordenctecte_bex_codi` | ENTIDAD | conf | Pago CoDi interbank — variante CoDi del sp anterior, 34 parámetros | bdispei | Constants.java:239 |
| `sp_validacionmtu_bpi` | ENTIDAD | conf | Valida que el monto no excede el límite MTU del cliente antes de autorizar | bdicheq | Constants.java:268 |
| `sp_bitacoramtu_bpi` | ENTIDAD | conf | Registra resultado de validación MTU en bitácora — 9 parámetros | bdicheq | Constants.java:280 |
| `sp_stscodiapp` | ENTIDAD | conf | Consulta estado y log de operaciones CoDi en la aplicación | bdispei | CodiLogOptionsStoreProcedure.java:97 |

### py · Pagos de servicios

| `term` | `cat` | `est` | `mean` | `BD` | `fuente` |
|--------|-------|-------|--------|------|----------|
| `cargo_ref` | ENTIDAD | conf | Cargo/débito a cuenta origen — paso 1 del flujo de pago de servicio | bdicheq | ChargeRefDao.java |
| `abono_ref` | ENTIDAD | conf | Abono/crédito a cuenta destino — paso 2 del flujo de pago de servicio | bdicheq | Constants.java:399 |
| `reversion` | ENTIDAD | conf | Reversión de transacción cuando falla abono_ref — compensación ACID | bdicheq | ReversionRefDao.java:86 |
| `sp_calcula_comisiones` | ENTIDAD | conf | Calcula comisiones a aplicar en el pago de servicio | bdisac | ServicePaymentsConstants.java:71 |
| `sp_grabapagoservicio` | ENTIDAD | conf | Graba y persiste el pago de servicio realizado | bdisac | ServicePaymentsConstants.java:76 |
| `sp_grabapgserv_dina` | ENTIDAD | conf | Graba pago de servicio para productos dinámicos (catálogo variable) | bdisac | ServicePaymentsConstants.java:101 |
| `sp_confpgserv_dina` | ENTIDAD | conf | Confirma el pago de servicio dinámico tras la autorización | bdisac | ServicePaymentsConstants.java:138 |
| `sp_calculadv` | ENTIDAD | conf | Calcula dígito verificador para validar cuentas de servicio | bdisac | ApiConstants.java:228 |

### py · Pagos de tarjetas de crédito

| `term` | `cat` | `est` | `mean` | `BD` | `fuente` |
|--------|-------|-------|--------|------|----------|
| `sp_pgotarcredotrobco_bex` | ENTIDAD | conf | Pago de tarjeta de crédito en otro banco (interbancario) | bdibpi | application-dev.properties:109 |
| `spsdpagotarcredpropia` | ENTIDAD | conf | Pago de tarjeta de crédito propia BanCoppel (intrabancario) — 16 parámetros | bdicred | Constants.java:92 |

### lo · Crédito y préstamos personales

| `term` | `cat` | `est` | `mean` | `BD` | `fuente` |
|--------|-------|-------|--------|------|----------|
| `comdistdc` | ENTIDAD | conf | Disposición de efectivo con cargo a crédito — 4 parámetros | bdicred | application-dev.properties:157 |
| `sp_evaldispefec_cred` | ENTIDAD | conf | Evalúa validez de disposición de efectivo antes de autorizar | bdicred | application-dev.properties:155 |
| `sp_consulta_saldos_general` | ENTIDAD | conf | Consulta saldos de préstamo por empresa y número de préstamo | bdicred | ApiConstants.java:191 |
| `sp_prestamoflex_multicanal` | ENTIDAD | conf | Provisionamiento de préstamo digital flex multicanal — 10 parámetros | bdicred | SqlConstants.java:33 |
| `sp_proyecta_prestamos` | ENTIDAD | conf | Proyecta condiciones y cuotas de préstamo — 10 parámetros | bdisolic | application-dev.properties:189 |
| `sp_proyecta_prest_credisol` | ENTIDAD | conf | Proyecta condiciones para crédito solidario | bdicred | AmortizationInformationRepository.java:68 |
| `sp_obtiene_tabla_amortizacion_pp` | ENTIDAD | conf | Tabla de amortización para préstamos personales — 4 parámetros | bdicred | application-dev.properties:193 |
| `sp_obtiene_tabla_amortizacion` | ENTIDAD | conf | Tabla de amortización variante PDN — 4 parámetros | bdicred | application-dev.properties:194 |
| `sp_adn_guardasolicitudcuenta` | ENTIDAD | conf | Guarda solicitud de cuenta para activación de adelanto de nómina — 6 parámetros | bdisolic | application-dev.properties:137 |

### dp · Apertura de cuentas de inversión

| `term` | `cat` | `est` | `mean` | `BD` | `fuente` |
|--------|-------|-------|--------|------|----------|
| `sp_altactascrece` | ENTIDAD | conf | Alta de cuenta de inversión CRECE — 46 parámetros | bdicheq | application-dev.properties:122 |
| `sp_altainversion` | ENTIDAD | conf | Alta de cuenta de pagaré (inversión a plazo) — 45 parámetros | bdinvers | application-dev.properties:167 |

### cr · Tarjetas de crédito

| `term` | `cat` | `est` | `mean` | `BD` | `fuente` |
|--------|-------|-------|--------|------|----------|
| `sp_consultasaldocortemin` | ENTIDAD | conf | Consulta saldo de corte mínimo de tarjeta de crédito | bdicred | application-dev.properties:89 |
| `sp_consulta_msi` | ENTIDAD | conf | Consulta opciones de meses sin intereses disponibles para la TDC | bdicred | application-dev.properties:122 |
| `sp_graba_prod_upgrade` | ENTIDAD | conf | Marcaje para upgrade de producto de crédito | bdicred | Constants.java:285 |
| `sp_clona_tdc_upgrade` | ENTIDAD | conf | Traspasa información del crédito anterior durante upgrade de TDC | bdicred | Constants.java:285 |

### cm · Operaciones de cliente

| `term` | `cat` | `est` | `mean` | `BD` | `fuente` |
|--------|-------|-------|--------|------|----------|
| `sp_verifica_bandera_sms_bex` | ENTIDAD | conf | Verifica si la bandera SMS del cliente está activa para operaciones móviles | bdinteg | BusinessConstants.java:98 |
| `sp_valida_celular_cancelado` | ENTIDAD | conf | Valida si el número de celular del cliente tiene estatus cancelado | bdinteg | EntityConstants.java:157 |

### sr · Tarjetas físicas — sistema ICCAT

| `term` | `cat` | `est` | `mean` | `BD` | `fuente` |
|--------|-------|-------|--------|------|----------|
| `sp_consulta_cte_cvv2din_tjts` | ENTIDAD | conf | Consulta datos de tarjeta para generación de CVV dinámico | intercard | DomainConstants.java:99 |
| `sp_registro_cte_cvv2din` | ENTIDAD | conf | Registra al cliente para activar el servicio de CVV dinámico | intercard | RegisterConstants.java:58 |
| `sp_activatarjeta_iccat` | ENTIDAD | conf | Activación de tarjeta física mediante el sistema ICCAT | intercard | EntityConstants.java:147 |

### sr · Servicios generales

| `term` | `cat` | `est` | `mean` | `BD` | `fuente` |
|--------|-------|-------|--------|------|----------|
| `sp_registra_evento` | ENTIDAD | conf | Registra evento de mensajería (SMS, notificación push) — 26 parámetros | bdimnsj | application-dev.properties:129 |
| `sp_registra_crecta_cobroaut` | ENTIDAD | conf | Registra cuenta para domiciliación (cobro automático periódico) — 6 parámetros | bdisac | Constants.java:351 |

### sr · Captureline — decodificación de líneas de captura gubernamentales

| `term` | `cat` | `est` | `mean` | `BD` | `fuente` |
|--------|-------|-------|--------|------|----------|
| `sp_decodifica_linea_base_licencias` | ENTIDAD | conf | Decodifica línea de captura de licencias de conducir | bdisac | application-dev.properties:139 |
| `sp_decodificadatospermisosadmintemrevo` | ENTIDAD | conf | Decodifica permisos administrativos temporales y revocación | bdisac | application-dev.properties:140 |
| `sp_decodificaDatosTramitesVehiculares` | ENTIDAD | conf | Decodifica trámites vehiculares (verificación, emplacamiento) | bdisac | application-dev.properties:141 |
| `sp_decodifica_linea_base_multas` | ENTIDAD | conf | Decodifica multas de tránsito | bdisac | application-dev.properties:142 |
| `sp_decodifica_linea_base_medio` | ENTIDAD | conf | Decodifica infracciones ambientales (verificación ambiental) | bdisac | application-dev.properties:143 |
| `sp_decodificaDatosRegistroCivil` | ENTIDAD | conf | Decodifica trámites de registro civil (actas, CURP) | bdisac | application-dev.properties:144 |
| `sp_decodificaDatosServicioPolicia` | ENTIDAD | conf | Decodifica servicios y trámites de policía | bdisac | application-dev.properties:145 |
| `sp_decodificaDatosImpuestoPredial` | ENTIDAD | conf | Decodifica impuesto predial municipal | bdisac | application-dev.properties:146 |
| `sp_decodificaDatosServicioAgua` | ENTIDAD | conf | Decodifica servicio de agua potable | bdisac | application-dev.properties:147 |
| `sp_decodifica_linea_base_vehicular` | ENTIDAD | conf | Decodifica tenencia vehicular | bdisac | application-dev.properties:148 |
| `sp_decodifica_linea_base_otras` | ENTIDAD | conf | Decodifica otros servicios gubernamentales | bdisac | application-dev.properties:149 |
| `sp_decodifica_linea_base_licencias_permanentes` | ENTIDAD | conf | Decodifica licencias de conducir permanentes | bdisac | configMap.yml:192 |

---

## Sección 7 — Operación y configuración del canal

| `term` | `cat` | `est` | `scope` | `mean` | `fuente` |
|--------|-------|-------|---------|--------|----------|
| `operation_id` | CONFIGURACION | conf | system | Identificador del tipo de operación para el log transaccional; 9003=validate, 9004=retrieve, 9070=agreement, 9055=consulta Redis | `constants.log.operationId.*` |
| `branchId` | CONFIGURACION | conf | system | `constants.log.branchId=5011` — sucursal virtual asignada al canal digital BEX para efectos de registro operacional | `application-dev.properties` msach |
| `bdibex` | ENTIDAD | conf | system | Base de datos MongoDB principal del canal (`bancoppelapp-xanjk.mongodb.net/bdibex`); almacena mensajes sensoriales, intentos de sesión y contratos T&C | `spring.data.mongodb.uri` |
| `mensaje_sensorial` | ENTIDAD | conf | enterprise | Metadata del dispositivo del cliente (sistema operativo, versión de app, timestamp, IP) capturada en cada sesión; almacenada en MongoDB `bdibex`; requerida por CNBV para trazabilidad | `/api/chnn/app/msg`, operation_id 9003/9004 |
| `T&C` | ENTIDAD | conf | system | Términos y Condiciones del canal; el cliente debe aceptar la versión vigente antes de operar; almacenados en MongoDB | `/api/chnn/app/agrmt`, `ContractNoDataAccessException` |
| `accountType` | CONFIGURACION | conf | system | Tipo de cuenta disponible en el perfil del cliente; valores: `debit,credit,loan,promissory,investment` | `constants.api.cached.available.accounts.default` |
| `t0` | CONFIGURACION | conf | system | Timestamp de inicio del request almacenado en `req.t0`; usado para calcular el tiempo de respuesta total | `T0_REQ_ATTRIBUTE = "req.t0"` |
| `TIME_FORMAT_BEX` | CONFIGURACION | conf | system | `"HH:mm:ss"` — formato de hora usado en logs del canal BEX | `msacm-p-security-session-management` |
| `Prometheus` | INFRAESTRUCTURA | conf | system | Sistema de métricas habilitado en todos los microservicios; expone métricas de SLA HTTP | `management.endpoint.prometheus.enabled=true` |
| `Actuator` | INFRAESTRUCTURA | conf | system | Spring Boot Actuator expuesto en puerto 8181; endpoints: health, metrics, prometheus, shutdown | `management.server.port=8181` |
| `sleuth` | INFRAESTRUCTURA | conf | system | Spring Cloud Sleuth — trazado distribuido; deshabilitado en DEV | `logging.level.org.springframework.cloud.sleuth=off` |

---

## Sección 8 — Infraestructura del canal e Informix

| `term` | `cat` | `est` | `scope` | `mean` | `fuente` |
|--------|-------|-------|---------|--------|----------|
| `OpenShift` | INFRAESTRUCTURA | conf | system | Plataforma de despliegue de los microservicios AppMovil; BanCoppel usa OpenShift en su nube privada (`bcpl-bex-osd`) | JKube plugin, Keycloak URL |
| `bcpl-bex-osd` | INFRAESTRUCTURA | conf | system | Nombre del clúster OpenShift de BanCoppel que sirve al canal BEX (`apps.bcpl-bex-osd.v49u.p1.openshiftapps.com`) | URL Keycloak SSO |
| `JKube` | INFRAESTRUCTURA | conf | system | Plugin Maven para despliegue en OpenShift (`oc:build`, `oc:deploy`); genera los manifiestos de Kubernetes/OpenShift | `pom.xml` msach-b-business-application-data |
| `Keycloak` | INFRAESTRUCTURA | conf | system | Servidor de identidad SSO; emite y valida JWT del canal BEX | `MSG_SSO_EXCEPTION`, `constants.sso.credentials.*` |
| `Quarkus` | INFRAESTRUCTURA | conf | system | Framework alternativo usado por `msamg-*` (mensajería); usa AMQ Broker; perfiles dev/prd/qa/drp/local | `msamg-d-security-messaging-otp-notification` properties |
| `AMQ` | INFRAESTRUCTURA | conf | system | ActiveMQ Broker (`tcp://localhost:61616`) — broker de mensajes JMS usado por los MSAs Quarkus de mensajería | `msamg-*` properties |
| `MongoDB Atlas` | INFRAESTRUCTURA | conf | system | Servicio cloud de MongoDB (`bancoppelapp-xanjk.mongodb.net`) donde reside `bdibex` | `spring.data.mongodb.uri` |
| `Redis` | INFRAESTRUCTURA | conf | system | Cache en memoria para gestión de sesiones (`session_context`, TTL=1,200s); instancia en `localhost:6390` | `spring.redis.*` properties |
| `coppelsm_shm` | INFRAESTRUCTURA | conf | system | Nombre del servidor Informix (`INFORMIXSERVER=coppelsm_shm`); `shm` = shared memory — modo de conexión de alto rendimiento de Informix | `spring.datasource.url` |
| `sysmaster` | ENTIDAD | conf | system | Base de datos del sistema de Informix; la connection-test-query del Hikari pool consulta `sysmaster:sysshmvals` para verificar que el servidor está activo | `connection-test-query` en properties |
| `sysshmvals` | ENTIDAD | conf | system | Tabla de valores de shared memory de Informix en `sysmaster`; usada como health check del pool JDBC | `connection-test-query` |
| `interact` | CONFIGURACION | conf | system | Usuario de base de datos JDBC con el que el canal se conecta a Informix | `spring.datasource.username=interact` |
| `Informix10Dialect` | INFRAESTRUCTURA | conf | system | Dialecto Hibernate para Informix 10 (`org.hibernate.community.dialect.Informix10Dialect`); define la sintaxis SQL compatible con el motor Informix | `spring.jpa.database-platform` |

---

## Sección 9 — Códigos de error del canal

| `term` | `cat` | `est` | `scope` | `mean` | `fuente` |
|--------|-------|-------|---------|--------|----------|
| `000901` | ERROR | conf | system | `NoDataFoundException` — No se encontró el dato solicitado (HTTP 404) | properties msach |
| `000902` | ERROR | conf | system | `UnauthorizedException` — Credenciales inválidas o expiradas (HTTP 401) | properties msach |
| `000903` | ERROR | conf | system | `ForbiddenException` / `ClaimException` — Sin autorización para la funcionalidad (HTTP 403) | properties msach |
| `000904` | ERROR | conf | system | `BadRequestException` — Request o headers incorrectos (HTTP 400) | properties msach |
| `000905` | ERROR | conf | system | `NotHandlerFoundException` — Recurso no encontrado (HTTP 404) | properties msach |
| `000913` | ERROR | conf | system | `HystrixRuntimeException` — Circuit breaker activado; SP Informix no respondió dentro del timeout (HTTP 500) | properties msach |
| `000914` | ERROR | conf | system | `MicroserviceClientException` — Error en llamada Feign entre microservicios (HTTP 500) | properties msach |
| `000915` | ERROR | conf | system | `ExternalResourceException` — Error en recurso externo (Informix, MongoDB, Redis) (HTTP 500) | properties msach |
| `000916` | ERROR | conf | system | `RequestTimeoutException` — SP Informix o servicio externo superó el timeout (HTTP 408) | properties msach |
| `000031` | ERROR | conf | system | `Exception` — Error genérico no clasificado; fallback de último recurso (HTTP 500) | properties msach |
| `000121` | ERROR | conf | system | `ChannelValidationException` — Canal inválido o no autorizado en el BEX Interceptor | properties msach |
| `000122` | ERROR | conf | system | `ContractNoDataAccessException` — El cliente no tiene T&C aceptado en MongoDB | properties msach |
| `databaseTimeoutException` | ERROR | conf | system | `constants.errorResolver.errorCodes.databaseTimeoutException=408` — timeout específico de base de datos Informix | `application-dev.properties` msapy |
| `LegacyError` | ERROR | conf | system | Label para errores provenientes del sistema legado (Informix); prefijo en logs: `"LegacyError :"` | `constants.errorResolver.messages.legacyErrorLabel` |

---

## Sección 10 — Términos de negocio extraídos por segmentación

Términos nuevos descubiertos al aplicar el motor greedy longest-match a los 50 nombres de SPs. Representan conceptos de negocio **no capturados en las secciones anteriores** pero presentes en el sistema.

### Crédito y préstamos

| `term` | `cat` | `est` | `scope` | `mean` | `fuente SP` |
|--------|-------|-------|---------|--------|-------------|
| `disposición de efectivo` | ENTIDAD | conf | enterprise | Retiro de dinero con cargo al crédito disponible; en BanCoppel se llama `comdistdc` (disposición con TDC); requiere evaluación previa con sp_evaldispefec_cred | comdistdc, sp_evaldispefec_cred |
| `préstamo flex` | ENTIDAD | conf | enterprise | Modalidad de préstamo digital otorgado y provisionado directamente en el canal móvil; `multicanal` = disponible en BEX, n2 y wallet | sp_prestamoflex_multicanal |
| `crédito solidario` | ENTIDAD | inf | enterprise | Préstamo grupal donde los integrantes se aval entre sí; producto Coppel extendido al canal móvil | sp_proyecta_prest_credisol |
| `amortización` | ENTIDAD | conf | enterprise | Tabla de pagos programados del préstamo que muestra cuota, capital e intereses por periodo; dos variantes: préstamo personal (pp) y PDN | sp_obtiene_tabla_amortizacion_pp, sp_obtiene_tabla_amortizacion |
| `ADN` | PREFIJO | conf | system | Adelanto de Nómina — producto que permite al cliente disponer de su salario antes de la fecha de pago; la solicitud se guarda con sp_adn_guardasolicitudcuenta | sp_adn_guardasolicitudcuenta |
| `adelanto de nómina` | ENTIDAD | inf | enterprise | Disposición anticipada del salario domiciliado en BanCoppel; el cliente solicita activar el acceso a este producto desde el canal móvil | sp_adn_guardasolicitudcuenta |
| `proyección de préstamo` | ENTIDAD | conf | enterprise | Simulación de condiciones (monto, plazo, tasa, cuota) antes de formalizar el crédito; dos SPs: general y específico para crédito solidario | sp_proyecta_prestamos, sp_proyecta_prest_credisol |

### Tarjetas

| `term` | `cat` | `est` | `scope` | `mean` | `fuente SP` |
|--------|-------|-------|---------|--------|-------------|
| `CVV dinámico` | ENTIDAD | conf | enterprise | Código de seguridad de tarjeta (CVV) que cambia periódicamente; prefijo en SPs: `cvv2din`; el sistema ICCAT genera y distribuye estos códigos | sp_consulta_cte_cvv2din_tjts, sp_registro_cte_cvv2din |
| `cvv2din` | PREFIJO | conf | system | Token del sistema Informix para CVV dinámico de segunda generación; aparece en los dos SPs del sistema ICCAT | sp_consulta_cte_cvv2din_tjts, sp_registro_cte_cvv2din |
| `ICCAT` | PREFIJO | conf | system | Sistema de Identificación y Control de Tarjetas — plataforma de activación de tarjetas físicas BanCoppel; accedida vía base de datos `intercard` con autenticación separada | sp_activatarjeta_iccat, intercard |
| `MSI` | ENTIDAD | conf | enterprise | Meses Sin Intereses — plan de financiamiento para compras con tarjeta de crédito; el canal consulta las opciones disponibles para la TDC del cliente | sp_consulta_msi |
| `corte mínimo` | ENTIDAD | conf | enterprise | Pago mínimo requerido en el ciclo de facturación de la tarjeta de crédito; saldo consultado antes de mostrar opciones de pago al cliente | sp_consultasaldocortemin |
| `upgrade TDC` | ENTIDAD | inf | enterprise | Proceso de migración de la tarjeta de crédito del cliente a un producto superior; involucra marcaje del producto (sp_graba_prod_upgrade) y clonación de datos (sp_clona_tdc_upgrade) | sp_graba_prod_upgrade, sp_clona_tdc_upgrade |

### Inversiones

| `term` | `cat` | `est` | `scope` | `mean` | `fuente SP` |
|--------|-------|-------|---------|--------|-------------|
| `CRECE` | ENTIDAD | conf | enterprise | Cuenta de ahorro con rendimiento de BanCoppel; apertura vía canal móvil con 46 parámetros; base de datos bdicheq | sp_altactascrece |
| `pagaré` | ENTIDAD | conf | enterprise | Instrumento de inversión a plazo fijo con rendimiento pactado; apertura digital desde el canal; base de datos bdinvers (separada) | sp_altainversion |

### Servicios y pagos gubernamentales

| `term` | `cat` | `est` | `scope` | `mean` | `fuente SP` |
|--------|-------|-------|---------|--------|-------------|
| `pago de servicio` | ENTIDAD | conf | enterprise | Pago de recibos de servicios públicos y privados (Telmex, CFE, agua) a través del canal; flujo: cargo_ref → sp_grabapagoservicio | sp_grabapagoservicio, sp_grabapgserv_dina |
| `servicio dinámico` | ENTIDAD | conf | system | Variante de pago de servicio donde los parámetros del producto (monto, referencia) son variables según el catálogo; diferente al servicio fijo | sp_grabapgserv_dina, sp_confpgserv_dina |
| `comisión` | ENTIDAD | conf | enterprise | Cargo adicional por operación bancaria; calculado antes de ejecutar el pago de servicio; actualmente configurado en cero (`payment.comission=0`) para CoDi | sp_calcula_comisiones |
| `captureline` | ENTIDAD | conf | enterprise | Referencia numérica impresa en recibos gubernamentales para pago en banco o canal digital; 12 variantes: licencias, multas, predial, agua, vehicular, policía, registro civil, etc. | familia sp_decodifica_* (SPs 39-50) |
| `dígito verificador` | ENTIDAD | conf | enterprise | Control de integridad de un número de cuenta o referencia; calculado con módulo 10 u otro algoritmo; validado antes de enviar el pago | sp_calculadv |
| `domiciliación` | ENTIDAD | inf | enterprise | Autorización del cliente para que BanCoppel cargue automáticamente un servicio o préstamo desde su cuenta; también llamada cobro automático | sp_registra_crecta_cobroaut |
| `trámite vehicular` | ENTIDAD | conf | enterprise | Pago gubernamental relacionado con vehículos: verificación ambiental, emplacamiento, tenencia | sp_decodificaDatosTramitesVehiculares, sp_decodifica_linea_base_vehicular |
| `predial` | ENTIDAD | conf | enterprise | Impuesto municipal sobre bienes inmuebles; pagable a través del canal con captureline | sp_decodificaDatosImpuestoPredial |
| `multa de tránsito` | ENTIDAD | conf | enterprise | Sanción por infracción vial; pagable a través del canal con línea de captura | sp_decodifica_linea_base_multas |

### Control de cliente

| `term` | `cat` | `est` | `scope` | `mean` | `fuente SP` |
|--------|-------|-------|---------|--------|-------------|
| `bandera SMS` | ENTIDAD | conf | system | Indicador booleano en Informix (bdinteg) que determina si el cliente tiene activas las alertas por SMS; verificado antes de enviar mensajes transaccionales | sp_verifica_bandera_sms_bex |
| `celular cancelado` | ENTIDAD | conf | system | Estado de la línea telefónica del cliente en bdinteg; si está cancelado, el canal bloquea operaciones que requieren OTP por SMS | sp_valida_celular_cancelado |

---

## Sección 11 — Prefijos de dominio MSA

Los dominios que forman el `{domain}` en el naming convention `msa{domain}-{layer}-{function}`. Extraídos del catálogo de 216 MSAs.

| `term` | `cat` | `est` | `scope` | `mean` | `fuente` |
|--------|-------|-------|---------|--------|----------|
| `py` | PREFIJO | conf | system | Dominio Pagos — CoDi, SPEI, servicios, transferencias, pagos de tarjeta | naming convention de MSAs msapy-* |
| `cm` | PREFIJO | conf | system | Dominio Cliente — gestión de sesión, seguridad, registro de celular, alertas SMS | naming convention de MSAs msacm-* |
| `dp` | PREFIJO | conf | system | Dominio Depósitos — apertura de cuentas de inversión (CRECE, pagaré), consulta de depósitos | naming convention de MSAs msadp-* |
| `cr` | PREFIJO | conf | system | Dominio Crédito / Tarjetas — tarjetas de crédito, saldos, MSI, upgrade TDC | naming convention de MSAs msacr-* |
| `lo` | PREFIJO | conf | system | Dominio Préstamos — crédito personal, disposición, flex, crédito solidario, ADN | naming convention de MSAs msalo-* |
| `sr` | PREFIJO | conf | system | Dominio Servicios — ICCAT, CVV dinámico, captureline, domiciliación, mensajería | naming convention de MSAs msasr-* |
| `xd` | PREFIJO | conf | system | Dominio Amortización / Extra data — tablas de amortización, proyección de préstamos | naming convention de MSAs msaxd-* |
| `ch` | PREFIJO | conf | system | Dominio Canal — configuración del canal, datos de aplicación, mensajes sensoriales | naming convention de MSAs msach-* |
| `mg` | PREFIJO | conf | system | Dominio Mensajería — OTP, notificaciones; implementado en Quarkus (no Spring Boot) | naming convention de MSAs msamg-* |
| `im` | PREFIJO | inf | review | Dominio identificado en code review — posible inversiones/mensajería; requiere validación del equipo BanCoppel | naming convention de MSAs msaim-* |

---

## Índice de términos por sección

| Sección | Contenido | Total |
|---------|-----------|-------|
| 1 — Heredados de Informix | sp, consulta, usuario, empresa, reversion, cargo, abono, bitacora, folio, saldo, cuenta, movimientos | 12 |
| 2 — Arquitectura de microservicios | msa, capa-b/d/p/o, @HandledProcedure, doReturningWork, SpResponse, CallableStatement, SP_CALL, SUCCESSFULL, ambar, Feign, Hystrix, HikariCP, DownstreamException | 16 |
| 3 — Seguridad y acceso | BEX, BEF, channel_id, wallet, n2, JWT, Bearer, deviceId, uuid, MDC, SSO, session_context, cellphone_session_validations, CUSTOMER_NUMBER_REGEX, CUSTOMER_CELLPHONE_NUMBER_REGEX, DEVICE_INFORMATION_REGEX, 000028, 409, 431 | 19 |
| 4 — Pagos y SPEI | CoDi, SPEI, intrabank, interbank, MTU, BPI, CLABE, pindbenef, payment.comission, type.reversion, status.charge, InterCircuitBreaker, IntraCircuitBreaker, cellphone | 14 |
| 5 — Bases de datos Informix | bdicheq, bdispei, bdicred, bdiprog, bdisac, bdisolic, bdimnsj, bdinvers, bdibpi, bdinteg, intercard | 11 |
| 6 — SPs Informix (50 total) | py·CoDi/SPEI(6), py·Servicios(8), py·Tarjetas(2), lo·Crédito(9), dp·Inversiones(2), cr·TDC(4), cm·Cliente(2), sr·ICCAT(3), sr·Servicios(2), sr·Captureline(12) | 50 |
| 7 — Operación y configuración | operation_id, branchId, bdibex, mensaje_sensorial, T&C, accountType, t0, TIME_FORMAT_BEX, Prometheus, Actuator, sleuth | 11 |
| 8 — Infraestructura | OpenShift, bcpl-bex-osd, JKube, Keycloak, Quarkus, AMQ, MongoDB Atlas, Redis, coppelsm_shm, sysmaster, sysshmvals, interact, Informix10Dialect | 13 |
| 9 — Códigos de error | 000901-000916, 000031, 000121-000122, databaseTimeoutException, LegacyError | 14 |
| 10 — Términos de negocio (segmentación) | disposición de efectivo, préstamo flex, crédito solidario, amortización, ADN, adelanto de nómina, proyección de préstamo, CVV dinámico, cvv2din, ICCAT, MSI, corte mínimo, upgrade TDC, CRECE, pagaré, pago de servicio, servicio dinámico, comisión, captureline, dígito verificador, domiciliación, trámite vehicular, predial, multa de tránsito, bandera SMS, celular cancelado | 26 |
| 11 — Prefijos de dominio MSA | py, cm, dp, cr, lo, sr, xd, ch, mg, im | 10 |
| **Total** | | **196** |

---

## Cross-reference con vocabulario Informix

Términos del vocabulario de Informix (`vocabulary-inventory.json`) que aparecen también en el canal y deben estar alineados durante la modernización:

| Término Informix | Uso en AppMovil | Alineación requerida |
|-----------------|-----------------|---------------------|
| `sp` | Canal invoca SPs vía JDBC | El SP debe existir en Informix hasta que el microservicio migre |
| `consulta` | La capa D consulta estado de cuenta vía SP | El SP de consulta debe retornar el mismo schema de datos |
| `usuario` | El cliente del canal es el mismo usuario del core | El `número_cliente` (9 dígitos) debe ser el mismo identificador |
| `empresa` | `BUSINESS = "001"` se pasa como parámetro al SP | Si cambia el código de empresa en el sistema target, el SP falla |
| `cargo` | `bdicheq:cargo_ref` debita la cuenta | El sistema target debe implementar la misma semántica |
| `abono` | `bdicheq:abono_ref` acredita la cuenta | El sistema target debe implementar la misma semántica |
| `folio` | `folioSuc` (≤16) y `BPI` (≤24) como parámetros del SP | El sistema target debe mantener los mismos formatos de folio |
| `amortización` | sp_obtiene_tabla_amortizacion en Informix bdicred | El schema de respuesta de la tabla de amortización debe ser idéntico |
| `comisión` | sp_calcula_comisiones en Informix bdisac | Las reglas de cálculo de comisiones deben replicarse en el sistema target |

---

## Worklist de SME — términos a validar

| Término | Contexto | Pregunta | Dominio | Prioridad |
|---------|----------|---------|---------|----------|
| `crédito solidario` | sp_proyecta_prest_credisol — no hay MSA documentado | ¿El canal móvil actualmente expone este producto? ¿Está activo? | Industry Banking | ALTA |
| `upgrade TDC` | sp_graba_prod_upgrade + sp_clona_tdc_upgrade | ¿El upgrade se inicia desde la app o solo desde sucursal? | Industry Banking | MEDIA |
| `im` (prefijo MSA) | msaim-* encontrado en code review | ¿Qué significa `im` como dominio funcional? | Equipo AppMovil | MEDIA |
| `comdistdc` | nombre sin underscores — no sigue la convención | ¿Es un SP antiguo con naming pre-convención o tiene significado acrónimo propio? | DBA IBM Informix | MEDIA |
| `domiciliación` | sp_registra_crecta_cobroaut | ¿Cuál es el flujo completo de cobro automático? ¿Hay SP de cancelación? | Industry Banking | BAJA |

---

*v0.2.0 · 2026-08-14 · AppMovil DT-Vocabulario · Metodología: methodology/metodologia-vocabulario-am.md v1.0.0 · 194 términos base en semilla Informix + minería F1-F3 + segmentación greedy de 50 SPs*

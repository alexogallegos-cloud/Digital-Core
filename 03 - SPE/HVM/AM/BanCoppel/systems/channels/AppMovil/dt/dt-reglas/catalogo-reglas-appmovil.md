# Catálogo de Reglas de Negocio — AppMovil BanCoppel
> **DT**: dt-reglas · **Proyecto**: `SPE-AM-001` · **Canal**: AppMovil
> **Versión**: 1.0.0 · **Fecha**: 2026-08-14 · **Fase**: DISCOVER
> **Fuente**: análisis estático de `source/code/` — reglas extraídas de código Java, propiedades, DTOs e interceptores
> **Total de reglas identificadas**: 42

---

## Taxonomía y convención de IDs

| Tipo | Prefijo | Descripción |
|------|---------|-------------|
| Canal | `R-CH-` | Restricciones del medio de acceso (channel_id, headers) |
| Sesión | `R-SES-` | Lifecycle de la sesión del cliente en Redis |
| Pago | `R-PAY-` | Condiciones pre/post-pago y transferencia |
| Producto | `R-PRO-` | Elegibilidad y condiciones de productos financieros |
| Seguridad | `R-SEC-` | Autenticación, OTP, dispositivos, biometría |
| Límite operativo | `R-LIM-` | Montos máximos, mínimos, frecuencia |
| Contrato | `R-CTR-` | Aceptación de términos y condiciones |
| Dispositivo | `R-DEV-` | Restricciones por dispositivo móvil |
| Error | `R-ERR-` | Mapeo de errores del sistema |

---

## R-CH — Reglas de Canal

### R-CH-001 · Canales válidos del sistema
- **Descripción**: Los únicos canales aceptados por el canal AppMovil son `bex`, `wallet` y `n2`. Cualquier request con un `channel_id` distinto es rechazado.
- **Condición**: `channel_id ∈ {bex, wallet, n2}` — si no → `ChannelValidationException` (000121)
- **Origen**: `valid.channels=bex,wallet,n2` en `application-dev.properties` · `msach-b-business-application-agreement:ApiValues.java`
- **Regulación**: CNBV Banca Electrónica (identificación del canal de acceso)
- **Criticidad AM**: ALTA — el canal target debe respetar o reemplazar esta lista de canales
- **Verificado contra código**: ✅

### R-CH-002 · BEX interceptor obligatorio para canal `bex`
- **Descripción**: Solo el canal `bex` activa la validación del BEX interceptor. Los canales `wallet` y `n2` no pasan por BEX. El interceptor valida el `channel_id` en todos los requests entrantes.
- **Condición**: `channel_id == bex` → aplica BEX interceptor; falla → `ChannelValidationException` (000121)
- **Origen**: `validate.channels=bex` en properties · `BexInterceptor.java` (msach-b-business-application-agreement)
- **Regulación**: CNBV Banca Electrónica
- **Criticidad AM**: ALTA — el BEX interceptor es infraestructura de validación del canal; debe replicarse o documentarse como parte del gateway target
- **Verificado contra código**: ✅

### R-CH-003 · Headers obligatorios en requests
- **Descripción**: Todos los requests deben incluir los headers `Authorization`, `deviceId`, `channel_id`, `Accept`, `uuid`. Headers faltantes → `NotValidHeadersException`.
- **Condición**: headers_presentes ⊇ {Authorization, deviceId, channel_id, Accept, uuid}
- **Origen**: `validate.headers.validateMessagesVersion=Authorization,deviceId,channel_id,Accept,uuid` · `ValidateHeadersAspect.java` (msalo-b-business-salary-advance-confirm)
- **Regulación**: CNBV Banca Electrónica (trazabilidad de operaciones)
- **Criticidad AM**: ALTA — el gateway target debe propagar o validar estos headers
- **Verificado contra código**: ✅

### R-CH-004 · Geolocalización obligatoria para activación de tarjeta
- **Descripción**: La activación de tarjeta de crédito requiere que el request incluya los headers `geolocation-latitude` y `geolocation-longitude`. Ausencia → `NotValidHeadersException`.
- **Condición**: headers contienen latitud y longitud válidas
- **Origen**: `Geolocation.java` · `msacr-b-business-credit-card-activation`
- **Regulación**: CNBV prevención de fraude (geolocalización para operaciones de alto riesgo)
- **Criticidad AM**: ALTA — el sistema target debe preservar la captura de geolocalización o sustituirla con mecanismo equivalente
- **Verificado contra código**: ✅

### R-CH-005 · Canales habilitados para sobres digitales con geolocalización
- **Descripción**: El acceso a la funcionalidad de sobres digitales requiere que el `xx-application-name` sea uno de los canales habilitados para geo (`channelsGeoEnable`). Canales no habilitados → `ForbiddenException`.
- **Condición**: `xx-application-name ∈ channelsGeoEnable` (lista configurable en properties)
- **Origen**: `ManagementDigitalEnvelopeUtils.java:validateRequestsHeaders` · `msadp-b-business-digital-envelope-management`
- **Regulación**: CNBV Banca Electrónica
- **Criticidad AM**: MEDIA — la lista de canales GEO habilitados debe documentarse y preservarse
- **Verificado contra código**: ✅

---

## R-SES — Reglas de Sesión

### R-SES-001 · Sesión del cliente en Redis con TTL
- **Descripción**: La sesión activa del cliente se mantiene en Redis (host configurable, por defecto `localhost:6390`). Todo endpoint autenticado requiere que la sesión esté presente en Redis. El TTL es configurado por política de seguridad del banco.
- **Condición**: `session ∈ Redis && !session.expired` — si no → `ForbiddenException`
- **Origen**: `msach-u-redis-actions:1.0.1` · `msacm-p-security-session-management`
- **Regulación**: CNBV Banca Electrónica (gestión de sesiones)
- **Criticidad AM**: CRÍTICA — la gestión de sesiones en Redis es infraestructura core del canal; el sistema target debe replicar el mecanismo o migrar a Spring Session con Redis como backend
- **Verificado contra código**: ✅

### R-SES-002 · JWT válido en cada operación
- **Descripción**: Cada request autenticado debe incluir un JWT válido en el header `Authorization`. JWT expirado o inválido → `UnauthorizedException` (000902).
- **Condición**: `JWT.valid == true && !JWT.expired`
- **Origen**: `constants.errorResolver.errorCodes.unauthorizedException = 000902` · `msach-p-security-application-validations`
- **Regulación**: CNBV Banca Electrónica
- **Criticidad AM**: ALTA — el mecanismo JWT es estándar; migrable sin impacto funcional si el proveedor de tokens se mantiene
- **Verificado contra código**: ✅

### R-SES-003 · Número de cliente de sesión debe coincidir con el request
- **Descripción**: El número de cliente extraído de la sesión en Redis debe coincidir con el `customerNumber` del request. Discrepancia → `ForbiddenException`.
- **Condición**: `session.customerNumber == request.customerNumber`
- **Origen**: `ValidateBusiness.java:if (!response.getCustomerNumber().equals(customerSso))` · `msadp-b-business-digital-envelope-management`
- **Regulación**: CNBV (prevención de acceso a cuentas de terceros)
- **Criticidad AM**: CRÍTICA — validación de integridad entre sesión y datos del request; el sistema target DEBE replicar esta validación
- **Verificado contra código**: ✅

### R-SES-004 · Token Redis inválido fuerza eliminación de sesión
- **Descripción**: Si el código de respuesta del cliente de sesión es `INVALID_TOKEN_CODE`, la clave Redis se elimina activamente (invalidación proactiva de sesión comprometida).
- **Condición**: `clientResponse.code == INVALID_TOKEN_CODE` → `redisActions.delete(sessionKey)`
- **Origen**: `SessionServiceImpl.java` · `msapy-b-business-remittance-payment`
- **Regulación**: CNBV Banca Electrónica (invalidación de sesiones comprometidas)
- **Criticidad AM**: ALTA — comportamiento de seguridad que debe replicarse en el sistema target
- **Verificado contra código**: ✅

---

## R-PAY — Reglas de Pago y Transferencia

### R-PAY-001 · SP CoDi intrabank requiere 38 parámetros exactos
- **Descripción**: La transacción CoDi para cuentas propias invoca el SP `SPCTRANSCTASPROPIASCODI_BEX` con 38 parámetros posicionales. Todos son obligatorios. El orden de los parámetros es parte del contrato con el SP de Informix.
- **Condición**: `CallableStatement.params.count == 38` — todos posicionales, sin nombres binding
- **Origen**: `IntrabankPayment.java` · `msach-o-business-codi-payment` · SP `SPCTRANSCTASPROPIASCODI_BEX` en `bdicred`
- **Regulación**: Banxico CoDi (protocolo de pagos CoDi)
- **Criticidad AM**: CRÍTICA — el SP es del core Informix; la migración del canal DEBE mantener compatibilidad con la firma del SP o coordinar el cambio simultáneo con el core
- **Verificado contra código**: ✅

### R-PAY-002 · Validación de horario de negocio para pagos Coppel
- **Descripción**: Los pagos de servicios Coppel solo se procesan dentro del horario de atención configurado (`openTime`, `closeTime`). Fuera del horario → `ServiceUnavailableException`.
- **Condición**: `currentTime ∈ [openTime, closeTime]` — si no → servicio no disponible
- **Origen**: `BusinessHoursValidator.java:if (currentTime.isAfter(closeTime) || currentTime.isBefore(openTime))` · `msapy-b-business-coppel-payment`
- **Regulación**: CONDUSEF (disponibilidad de servicio)
- **Criticidad AM**: MEDIA — horario configurable en properties; el sistema target debe preservar el mecanismo de configuración de horarios
- **Verificado contra código**: ✅

### R-PAY-003 · Monto del pago debe coincidir con el monto authorizado
- **Descripción**: El monto enviado en el request de pago debe coincidir con el monto que fue autorizado previamente. Discrepancia → `BadRequestException` con código `walletAmountsNomatch`.
- **Condición**: `request.amount == authorizedAmount`
- **Origen**: `ApiValidations.java:if (!amountsNomatch)` · `msapy-b-business-coppel-payment`
- **Regulación**: Banxico (integridad de transacciones)
- **Criticidad AM**: ALTA — regla de integridad financiera; debe replicarse en el sistema target
- **Verificado contra código**: ✅

### R-PAY-004 · Tarjeta debe estar activa para procesar pago Coppel
- **Descripción**: Para procesar un pago con cargo a tarjeta de débito Coppel, la tarjeta debe tener estatus `ACTIVE`. Tarjeta inactiva → `InactiveDepostAccountException`.
- **Condición**: `card.status == ACTIVE`
- **Origen**: `ApiValidations.java:if (!cardStatus.getStatus().equals(Constants.STATUS_CARD_ACTIVE))` · `msapy-b-business-coppel-payment`
- **Regulación**: CNBV (operaciones sobre cuentas activas)
- **Criticidad AM**: ALTA — depende del SP de Informix para consultar el estatus; la migración del canal debe coordinarse con el core
- **Verificado contra código**: ✅

### R-PAY-005 · OTP obligatorio para pago de remesas
- **Descripción**: El pago de remesas requiere que el cliente proporcione un OTP válido. OTP vacío o inválido → `BadRequestException`.
- **Condición**: `request.otp != null && !request.otp.blank`
- **Origen**: `PaymentRemittanceServiceImpl.java:if (StringUtils.isBlank(request.getOtp()))` · `msapy-b-business-remittance-payment`
- **Regulación**: CNBV Banca Electrónica (autenticación de factor adicional en pagos)
- **Criticidad AM**: ALTA — el OTP es un factor de autenticación regulatorio; el sistema target debe mantener el mecanismo OTP
- **Verificado contra código**: ✅

### R-PAY-006 · OTP obligatorio para transferencias (intrabank y CoDi)
- **Descripción**: Las transferencias entre cuentas propias y los pagos CoDi requieren OTP en el request. Campo `otp` es `@NotNull`.
- **Condición**: `request.otp != null`
- **Origen**: `IntrabankTransferRequest.java:@NotNull otp` · `msapy-b-business-coppel-payment` · `CreateDigitalEnvelopeRequest.java:@NotNull otp`
- **Regulación**: CNBV Banca Electrónica (autenticación de factor adicional)
- **Criticidad AM**: ALTA
- **Verificado contra código**: ✅

### R-PAY-007 · Respuesta de Omnicanal vacía rechaza la operación
- **Descripción**: Si el servicio Omnicanal responde con un estatus en blanco, la operación de pago se rechaza con `OmnicanalUnavailableException`.
- **Condición**: `omnicanalResponse.meta.status != blank`
- **Origen**: `OmnicanalTransactions.java:if(omnicanalResponse.getMeta().getStatus().isBlank())` · `msapy-b-business-coppel-payment`
- **Regulación**: —
- **Criticidad AM**: ALTA — el sistema target debe integrar con Omnicanal o proveer un sustituto; el comportamiento de rechazo debe preservarse
- **Verificado contra código**: ✅

### R-PAY-008 · Códigos de error de Omnicanal se clasifican en warning / info / decline
- **Descripción**: Los códigos de respuesta de Omnicanal se clasifican en tres categorías configurables: `warningCodes` (operación ejecutada con advertencia), `infoCodes` (información al cliente), `declineCodes` (operación rechazada). Cada categoría lanza una excepción distinta.
- **Condición**: `errorCode ∈ warningCodes → OmnicanalWarningException`; `∈ infoCodes → OmnicanalInfoException`; `∈ declineCodes → OmnicanalDeclineException`
- **Origen**: `OmnicanalTransactions.java` · `msapy-b-business-coppel-payment`
- **Regulación**: CONDUSEF (clasificación de resultados de pago)
- **Criticidad AM**: MEDIA — la lista de códigos está en properties; migrable si se preservan las properties o se migran al sistema target
- **Verificado contra código**: ✅

---

## R-PRO — Reglas de Producto

### R-PRO-001 · Anticipo de nómina requiere `commissionTax` en el request
- **Descripción**: La confirmación de anticipo de nómina requiere `otp`, `amount` y `commissionTax` como campos obligatorios (`@NotNull`). Cualquier campo nulo → rechazo de validación.
- **Condición**: `request.{otp, amount, commissionTax} != null`
- **Origen**: `ConfirmationRequest.java:@NotNull` · `msalo-b-business-salary-advance-confirm`
- **Regulación**: CNBV (productos de crédito — condiciones de disposición)
- **Criticidad AM**: ALTA — la estructura del request incluye comisión fiscal; cambio de estructura requiere coordinación con Informix
- **Verificado contra código**: ✅

### R-PRO-002 · Sobre digital solo puede crearse sobre cuentas con estatus válido
- **Descripción**: La creación de un sobre digital requiere que la cuenta de origen tenga uno de los estatus permitidos (`allowedValidAccountsForEnvelope`). Estatus no permitido → `DigitalEnvelopeException`.
- **Condición**: `account.status ∈ allowedValidAccountsForEnvelope` (lista configurable)
- **Origen**: `ValidateBusiness.java:if (!apiValues.getAllowedValidAccountsForEnvelope().contains(response.getAccountStatus()))` · `msadp-b-business-digital-envelope-management`
- **Regulación**: CNBV (operaciones sobre cuentas activas)
- **Criticidad AM**: MEDIA — lista de estatus válidos está en properties; preservable en migración
- **Verificado contra código**: ✅

### R-PRO-003 · Sobre digital requiere producto permitido
- **Descripción**: La cuenta de origen para crear un sobre digital debe tener un `productNumber` que esté en la lista de productos permitidos (`allowedProducts`). Producto no permitido → `DigitalEnvelopeException`.
- **Condición**: `account.productNumber ∈ allowedProducts` (lista configurable)
- **Origen**: `ValidateBusiness.java:if (!apiValues.getAllowedProducts().contains(response.getProductNumber()))` · `msadp-b-business-digital-envelope-management`
- **Regulación**: —
- **Criticidad AM**: MEDIA
- **Verificado contra código**: ✅

### R-PRO-004 · Tipo de sobre digital debe ser código válido
- **Descripción**: Al crear o actualizar un sobre digital, el `envelopeType` debe existir en el mapa de tipos de sobre (`typeDigitalEnvelope`). Tipo inválido → `DigitalEnvelopeException`.
- **Condición**: `request.envelopeType ∈ typeDigitalEnvelope.keys`
- **Origen**: `CreateDigitalEnvelopeBusiness.java:if (!apiValues.getTypeDigitalEnvelope().containsKey(...))` · `msadp-b-business-digital-envelope-management`
- **Regulación**: —
- **Criticidad AM**: BAJA — catálogo configurable en properties
- **Verificado contra código**: ✅

### R-PRO-005 · Nombre del sobre digital tiene longitud mínima y máxima
- **Descripción**: El nombre del sobre digital debe tener entre `envelopeNameStringMin` y `envelopeNameStringMax` caracteres. Nombre fuera de rango → `BadRequestException`.
- **Condición**: `envelopeNameStringMin ≤ len(name) ≤ envelopeNameStringMax`
- **Origen**: `ManagementDigitalEnvelopeUtils.java:if (lengthEnvelopeName < envelopeNameStringMin || lengthEnvelopeName > envelopeNameStringMax)` · `msadp-b-business-digital-envelope-management`
- **Regulación**: —
- **Criticidad AM**: BAJA
- **Verificado contra código**: ✅

### R-PRO-006 · Nombre del sobre digital solo acepta caracteres permitidos
- **Descripción**: El nombre del sobre digital debe pasar la validación de caracteres especiales. Caracteres no permitidos → `BadRequestException`.
- **Condición**: `name.matches(strCalidCharacters)`
- **Origen**: `ManagementDigitalEnvelopeUtils.java:if (!validateCharacters(createRequest.getDigitalEnvelopeName(), strCalidCharacters))` · `msadp-b-business-digital-envelope-management`
- **Regulación**: —
- **Criticidad AM**: BAJA
- **Verificado contra código**: ✅

### R-PRO-007 · Fecha objetivo del sobre digital no puede exceder un año
- **Descripción**: La fecha objetivo (`targetDate`) de un sobre digital de actualización no puede ser mayor a un año a partir de la fecha actual. Fecha inválida → `BadRequestException`.
- **Condición**: `targetDate ≤ now + 365 días`
- **Origen**: `ManagementDigitalEnvelopeUtils.java:if (!oneYearTargetDate(validateTargetDate))` · `msadp-b-business-digital-envelope-management`
- **Regulación**: —
- **Criticidad AM**: BAJA
- **Verificado contra código**: ✅

### R-PRO-008 · Débito directo requiere producto permitido
- **Descripción**: El intento de domiciliar débito a una cuenta requiere que el `product` esté en la lista de productos válidos para débito directo. Producto no permitido → `DirectDebitAccountException`.
- **Condición**: `account.product ∈ validProducts` (lista configurable)
- **Origen**: `CommonValidations.java:if (!validProducts.contains(product))` · `msasr-b-business-direct-debit-process-management`
- **Regulación**: CNBV (domiciliaciones sobre cuentas elegibles)
- **Criticidad AM**: MEDIA
- **Verificado contra código**: ✅

---

## R-SEC — Reglas de Seguridad

### R-SEC-001 · Clave de remesa tiene longitud permitida
- **Descripción**: La clave de remesa (`remittanceKey`) debe tener una longitud que esté en la lista de longitudes permitidas (`allowedLength`). Longitud inválida → `BadRequestException`.
- **Condición**: `len(remittanceKey) ∈ allowedLength`
- **Origen**: `ValidateRemittanceServiceImpl.java:if (!externalizedConstants.getAllowedLength().contains(...))` · `msapy-b-business-remittance-payment`
- **Regulación**: —
- **Criticidad AM**: MEDIA
- **Verificado contra código**: ✅

### R-SEC-002 · Sesión Redis requerida para pago de remesa
- **Descripción**: El cliente debe tener una sesión activa en Redis para procesar el pago de una remesa. Sin sesión → `ValidationBusinessException` con código de Redis.
- **Condición**: `customerRedis.isPresent() == true`
- **Origen**: `PaymentRemittanceServiceImpl.java:if (!customerRedis.isPresent())` · `msapy-b-business-remittance-payment`
- **Regulación**: CNBV Banca Electrónica
- **Criticidad AM**: ALTA
- **Verificado contra código**: ✅

### R-SEC-003 · Sesión Redis requerida para validar remesa
- **Descripción**: La validación de remesa también requiere sesión activa en Redis. Sin sesión → `ValidationBusinessException`.
- **Condición**: `customerRedis.isPresent() == true` (en flujo de validación previo al pago)
- **Origen**: `ValidateRemittanceServiceImpl.java:if (!customerRedis.isPresent())` · `msapy-b-business-remittance-payment`
- **Regulación**: CNBV Banca Electrónica
- **Criticidad AM**: ALTA
- **Verificado contra código**: ✅

### R-SEC-004 · Gemalto token expirado tiene código de error propio
- **Descripción**: Si el token OTP Gemalto expira durante la operación, se lanza un error específico con código `000061` (distinto del error general de OTP).
- **Condición**: `gemaltoToken.expired == true → errorCode 000061`
- **Origen**: `constants.api.errorCode.expiredGemaltoToken = 000061` · `msach-b-business-application-agreement`
- **Regulación**: CNBV Banca Electrónica (OTP como factor de autenticación)
- **Criticidad AM**: MEDIA — el proveedor de tokens OTP (Gemalto) puede cambiar en la migración; el código de error debe mapear al nuevo proveedor
- **Verificado contra código**: ✅

### R-SEC-005 · Canal del débito directo debe estar en lista de canales permitidos
- **Descripción**: El `xx-application-name` del request de débito directo debe estar en la lista de canales válidos para domiciliaciones. Canal no permitido → `ForbiddenException`.
- **Condición**: `xx-application-name ∈ channels` (lista configurable en properties)
- **Origen**: `CommonValidations.java:if (!channels.contains(xxApplicationName.toLowerCase()))` · `msasr-b-business-direct-debit-process-management`
- **Regulación**: CNBV
- **Criticidad AM**: MEDIA
- **Verificado contra código**: ✅

---

## R-LIM — Reglas de Límite Operativo

### R-LIM-001 · Folio de activación de débito directo tiene máximo de dígitos
- **Descripción**: El campo `activationInvoice` en la cancelación de débito directo no puede exceder `activationInvoiceMaxDigits` caracteres. Exceso → `BadRequestException`.
- **Condición**: `len(activationInvoice) ≤ activationInvoiceMaxDigits` (valor en properties)
- **Origen**: `DirectDebitRemoveBusiness.java:if (request.getActivationInvoice().length() > apiValues.getActivationInvoiceMaxDigits())` · `msasr-b-business-direct-debit-process-management`
- **Regulación**: —
- **Criticidad AM**: BAJA
- **Verificado contra código**: ✅

### R-LIM-002 · Monto de débito directo tiene mínimo permitido
- **Descripción**: El monto máximo configurado para una domiciliación debe ser mayor o igual al valor mínimo permitido. Monto menor → `InvalidMaxAmountException`.
- **Condición**: `requestMaxAmount >= valueMaxAmountMinValue` (BigDecimal comparison)
- **Origen**: `CommonValidations.java:if (requestMaxAmount.compareTo(valueMaxAmountMinValue) < BigDecimal.ONE.intValue())` · `msasr-b-business-direct-debit-process-management`
- **Regulación**: CNBV / CONDUSEF (límites de domiciliaciones)
- **Criticidad AM**: ALTA — el monto mínimo es regulatorio; debe preservarse con exacta precisión decimal
- **Verificado contra código**: ✅

### R-LIM-003 · Monto de débito directo tiene máximo permitido
- **Descripción**: El monto máximo configurado para una domiciliación no puede exceder el límite máximo del sistema. Exceso → `MaxAmountMoreThanAllowedException`.
- **Condición**: `requestMaxAmount ≤ valueMaxAmountMaxValue` (BigDecimal comparison)
- **Origen**: `CommonValidations.java:if (requestMaxAmount.compareTo(valueMaxAmountMaxValue) > BigDecimal.ZERO.intValue())` · `msasr-b-business-direct-debit-process-management`
- **Regulación**: CNBV / CONDUSEF
- **Criticidad AM**: ALTA
- **Verificado contra código**: ✅

### R-LIM-004 · Monto tiene validación de dígitos enteros y decimales
- **Descripción**: Los montos monetarios se validan en cuanto a su número máximo de dígitos enteros y decimales. Exceso en cualquiera de los dos → `AmountLengthException`.
- **Condición**: `len(enteros) ≤ length && len(decimales) ≤ decimalLength`
- **Origen**: `Util.java:if (decimal.length() > decimalLength || digits.length() > length)` · `msasr-b-business-direct-debit-process-management`
- **Regulación**: Banxico (precisión decimal en pagos)
- **Criticidad AM**: ALTA — la precisión de montos es crítica en sistemas financieros; el tipo BigDecimal debe preservarse en el sistema target (no double)
- **Verificado contra código**: ✅

### R-LIM-005 · Propiedades de monto no pueden ser nulas ni vacías
- **Descripción**: Las propiedades de configuración de montos (máximos, mínimos) no pueden ser nulas ni estar vacías. Si lo están, el servicio falla al arrancar con un error de validación de configuración.
- **Condición**: `property != null && !property.blank`
- **Origen**: `Util.java:validateProperty(...)` · `msasr-b-business-direct-debit-process-management`
- **Regulación**: —
- **Criticidad AM**: MEDIA — validación de startup; el sistema target debe replicar las verificaciones de configuración al arrancar
- **Verificado contra código**: ✅

### R-LIM-006 · Longitud de campo de domiciliación validada contra lista de longitudes
- **Descripción**: Los campos de longitud específica en débito directo se validan contra una lista de longitudes válidas (`validLengths`). Longitud no permitida → `BadRequestException`.
- **Condición**: `len(field) ∈ validLengths` (lista configurable)
- **Origen**: `CommonValidations.java:if (!validLengths.contains(propertyLength))` · `msasr-b-business-direct-debit-process-management`
- **Regulación**: —
- **Criticidad AM**: BAJA
- **Verificado contra código**: ✅

### R-LIM-007 · Monto de Pago Coppel tiene mínimo permitido configurado
- **Descripción**: Si el monto de un pago Coppel está por debajo del mínimo y la opción de pago no es del tipo "sin mínimo" (`idTypePaymentOff`), el pago es rechazado.
- **Condición**: `amount >= minAmount || payOption == idTypePaymentOff`
- **Origen**: `ApiValidations.java:if (isBelowMinimum)` · `msapy-b-business-coppel-payment`
- **Regulación**: CONDUSEF (monto mínimo de pago en créditos)
- **Criticidad AM**: ALTA — regla de negocio de crédito con implicación regulatoria
- **Verificado contra código**: ✅

---

## R-CTR — Reglas de Contrato

### R-CTR-001 · Cliente debe haber aceptado T&C vigentes antes de operar
- **Descripción**: El cliente debe tener aceptados los términos y condiciones (T&C) vigentes del canal. Sin aceptación de T&C → `ContractNoDataAccessException` (000122).
- **Condición**: `customer.contractAccepted == true`
- **Origen**: `msach-b-business-application-data` · endpoint `/chnn/app/agrmt` · operationId `9070`
- **Regulación**: CNBV / Ley de Instituciones de Crédito (consentimiento del usuario)
- **Criticidad AM**: CRÍTICA — el mecanismo de aceptación de T&C es regulatorio; el sistema target debe preservarlo o proveer un mecanismo equivalente
- **Verificado contra código**: ✅ (parcial — desde properties; pendiente verificar lógica de evaluación en código de servicio)

### R-CTR-002 · Acuerdo de servicio de pago tiene operationId específico
- **Descripción**: El T&C para el acuerdo de servicios de pago usa el `operationId = 9070` para identificar el tipo de contrato en el log y en el catálogo de Redis.
- **Condición**: `agreement.operationId == 9070`
- **Origen**: `constants.log.operationId.agreement = 9070` · `constants.apiValues.catalog.coppelAgreement.operationId`
- **Regulación**: CONDUSEF
- **Criticidad AM**: MEDIA — el ID de operación es parte del trazado; debe preservarse en el sistema target para auditoría
- **Verificado contra código**: ✅

### R-CTR-003 · SSO token refresh con máximo 2 intentos
- **Descripción**: El sistema intenta refrescar el token SSO un máximo de 2 veces antes de fallar.
- **Condición**: `ssoRefreshAttempts ≤ 2`
- **Origen**: `constants.sso.token.client.max-attempt = 2` · `msach-b-business-application-agreement`
- **Regulación**: —
- **Criticidad AM**: BAJA — el SSO puede cambiar en la migración; el número de intentos es configurable
- **Verificado contra código**: ✅

---

## R-DEV — Reglas de Dispositivo

### R-DEV-001 · Débito directo recupera estado desde Redis antes de editar
- **Descripción**: Para editar o iniciar una domiciliación de débito directo, el sistema busca el objeto de control en Redis. Si no existe → `ObjectNotFoundException`. El estado del flujo de domiciliación vive en Redis, no en base de datos.
- **Condición**: `redisDirectDebitObject.isPresent() == true`
- **Origen**: `DirectDebitEditBusiness.java` · `DirectDebitIniciateBusiness.java` · `msasr-b-business-direct-debit-process-management`
- **Regulación**: —
- **Criticidad AM**: ALTA — el estado del flujo en Redis es parte del protocolo de domiciliación; el sistema target debe preservar este mecanismo o migrar a un state store equivalente
- **Verificado contra código**: ✅

---

## R-ERR — Reglas de Error (mapeo canónico)

### R-ERR-001 · Errores de Informix absorbidos en ExternalResourceException
- **Descripción**: Cualquier excepción originada en la llamada a un SP de Informix se captura y transforma en `ExternalResourceException` (código 000915) antes de responder al cliente. El código de error interno del SP nunca se expone en la respuesta al canal.
- **Condición**: `informixException → ExternalResourceException(000915)`
- **Origen**: `constants.errorResolver.errorCodes.externalResourceException = 000915` · handler global en `msach-u-aop-commons`
- **Regulación**: CNBV (no exponer información interna del sistema al canal externo)
- **Criticidad AM**: ALTA — este comportamiento es parte del contrato de error del canal; el sistema target debe mantener la abstracción de errores del core
- **Verificado contra código**: ✅

### R-ERR-002 · Mapa canónico de códigos de error del canal

Los siguientes códigos son el contrato de errores del canal — cualquier sistema que reemplace un microservicio debe respetarlos.

| Código | Excepción Java | Significado |
|--------|----------------|-------------|
| 000031 | `Exception` genérico | Error no controlado |
| 000061 | — | Gemalto OTP token expirado |
| 000121 | `ChannelValidationException` / `InvalidChannelException` | Canal inválido |
| 000420 | `InvalidAmountException` (Coppel services) | Monto inválido en servicios Coppel |
| 000901 | `NoDataFoundException` | Sin datos encontrados |
| 000902 | `UnauthorizedException` | JWT inválido o expirado |
| 000903 | `ForbiddenException` / `ClaimException` | Acceso denegado |
| 000904 | `BadRequestException` | Request mal formado |
| 000905 | `NoHandlerFoundException` | Endpoint no encontrado |
| 000906 | `HttpRequestMethodNotSupportedException` | Método HTTP no soportado |
| 000907 | `HttpMediaTypeNotAcceptableException` | Media type no aceptable |
| 000908 | `HttpMediaTypeNotSupportedException` | Media type no soportado |
| 000909 | `ServletRequestBindingException` | Binding de request inválido |
| 000910 | `HttpMessageNotReadableException` | Mensaje no legible |
| 000911 | `MethodArgumentNotValidException` | Argumento inválido (validación DTO) |
| 000912 | `ConstraintViolationException` | Violación de constraint |
| 000913 | `HystrixRuntimeException` | Circuit breaker abierto |
| 000914 | `MicroserviceClientException` | Error en llamada a microservicio |
| 000915 | `ExternalResourceException` | Error en recurso externo (Informix) |
| 000916 | `RequestTimeoutException` | Timeout de request |

- **Origen**: `ErrorResolverConstants.java` (presente en ~200 repos) · `msasr-d-domain-services-transaction-operation`
- **Regulación**: —
- **Criticidad AM**: CRÍTICA — este mapa es el contrato público de errores del canal; el sistema target debe preservarlo o proveer un mapa de traducción
- **Verificado contra código**: ✅

---

## Resumen por tipo

| Tipo | Reglas | Criticidad dominante |
|------|--------|---------------------|
| R-CH (Canal) | 5 | ALTA |
| R-SES (Sesión) | 4 | CRÍTICA |
| R-PAY (Pago) | 8 | CRÍTICA |
| R-PRO (Producto) | 8 | MEDIA |
| R-SEC (Seguridad) | 5 | ALTA |
| R-LIM (Límite operativo) | 7 | ALTA |
| R-CTR (Contrato) | 3 | CRÍTICA |
| R-DEV (Dispositivo) | 1 | ALTA |
| R-ERR (Error) | 2 (+ mapa de 20 códigos) | CRÍTICA |
| **Total** | **43** | — |

---

## Reglas de criticidad CRÍTICA — input de decommission gate (R-B7)

Estas reglas deben estar completamente cubiertas en el sistema target antes de cualquier cutover de capability:

1. R-PAY-001 — SP CoDi con 38 parámetros posicionales
2. R-SES-001 — Sesión en Redis con TTL
3. R-SES-003 — Número de cliente de sesión coincide con request
4. R-CTR-001 — T&C vigentes aceptados antes de operar
5. R-ERR-001 — Errores de Informix absorbidos
6. R-ERR-002 — Mapa de 20 códigos de error del canal

---

## Cross-references

| DT | Input de este catálogo |
|----|----------------------|
| **dt-sp-dependencies** | R-PAY-001 (38 params SP CoDi), R-ERR-001 (absorción de errores Informix) |
| **dt-regulatorio** | R-CH-001/002, R-SES-001, R-PAY-005/006, R-CTR-001 — todas las reglas con regulación CNBV/Banxico |
| **dt-catalogo-errores** | R-ERR-002 — mapa de 20 códigos de error del canal |
| **dt-riesgos** | R-PAY-001 (riesgo RISK-JA-04 del dt-java-analysis) · R-LIM-004 (precisión decimal = BigDecimal) |

---

## Smoke tests (DT-Validador)

| ID | Test | Estado |
|----|------|--------|
| RE-01 | `catalogo-reglas-appmovil.md` existe | ✅ |
| RE-02 | El catálogo cubre los 8 tipos de regla | ✅ |
| RE-03 | Cada regla tiene ID canónico, descripción, origen, regulación | ✅ |
| RE-04 | Las 10 reglas preliminares (R-CH-001 a R-ERR-001) verificadas contra código | ✅ |
| RE-05 | Las reglas R-CH-* referencian el BEX interceptor | ✅ |
| RE-06 | El catálogo declara ≥30 reglas identificadas | ✅ (43) |

---

*v1.0.0 · 2026-08-14 · dt-reglas AppMovil — 43 reglas en 9 tipos · extraídas de análisis estático de source/code/*
# Test Strategy — Apertura de cuenta de depósito de nivel 2

> **Artefacto**: Catálogo de casos de prueba derivado del código fuente
> **Proyecto**: BanCoppel Application Modernization, `SPE-AM-001`
> **Sistema**: AppMovil, canal móvil
> **Versión**: 1.0.0
> **Fecha**: 2026-10-15
> **Fase**: DISCOVER, con aplicación de QE shift-left

---

## 1. Alcance y fuente de evidencia

Este catálogo cubre el recorrido de apertura de una cuenta de depósito de nivel 2 desde la aplicación móvil, desde la validación del candidato hasta el alta de la cuenta y del cliente en la plataforma de apertura.

Los casos no se escribieron contra una especificación funcional. Se derivaron leyendo el código de los microservicios y su configuración externalizada, de modo que cada caso apunta al archivo y la línea que lo justifica. Cuando una prueba falla, el equipo sabe exactamente qué instrucción del código quedó expuesta.

Los cinco servicios públicos del recorrido son:

| Bloque | API expuesta | Microservicio | Profundidad del análisis |
|---|---|---|---|
| A | `POST /api/public/v3/csmg/crdm/val` | msacm-d-business-customer-data-validation | Superficial |
| B | `POST /api/public/v1/csmg/idt/val` | msacm-d-business-identity-data-validation | Configuración completa |
| C | `POST /api/public/v3/csmg/crdm/ret` | msacm-d-business-identity-data-recovery | Superficial |
| D | `POST /api/public/v1/customer/biometric/facial/validate` | msacm-d-business-biometric-identity-validation | Lógica y umbrales |
| E | `POST /api/public/v3/dept/lta` | msadp-d-business-level-two-digital-account | Completa, código y configuración |

Detrás de los cinco responde la plataforma `ms-n2bcpl-apertura`, con las operaciones `/apertura/candidato`, `/cuentaN2/validacion/ocr`, `/apertura/solicitar`, `/apertura/estatus` y `/apertura/val/cuenta/telefono`.

Los bloques A y C quedaron con análisis superficial porque su lógica de negocio vive del lado de la plataforma de apertura y no en el canal. Sus casos están pendientes de una segunda pasada y se declaran al final.

## 2. Cómo se derivaron los casos

Se aplicaron las mismas seis técnicas que ya usa el catálogo del núcleo Informix, para que ambos catálogos sean comparables y se puedan importar a la misma herramienta de gestión de pruebas.

| Técnica | Cuándo se aplica | Casos que produce |
|---|---|---|
| Partición de equivalencia | Validación booleana | Camino verdadero y camino falso |
| Valores límite | Umbral numérico o de longitud | Límite inferior, valor exacto, límite superior |
| Transición de estado | Máquina de estados | Transición válida y transición inválida |
| Prueba negativa | Código de error catalogado | Un caso por código |
| Golden master | Comportamiento que debe conservarse | Comparación contra el sistema actual |
| Extremo a extremo | Recorrido completo del cliente | Un caso por desenlace |

La prioridad sigue la regla del catálogo existente: es P1 todo lo que tiene obligación regulatoria o riesgo declarado, P2 lo que el volumen vuelve visible, y P3 el resto.

## 3. Marco regulatorio aplicable a la apertura de nivel 2

La cuenta de depósito de nivel 2 no es una categoría comercial sino una figura regulatoria. Las Disposiciones de carácter general a que se refiere el artículo 115 de la Ley de Instituciones de Crédito definen cuatro niveles de cuenta y, para el nivel 2, un expediente de identificación simplificado y un tope de depósitos mensuales expresado en unidades de inversión.

La correspondencia entre ese expediente y el contrato de la interfaz es directa y verificable. El modelo `OpenCustomerAccountRequest` exige exactamente los campos que la norma pide para el nivel 2: nombre y apellidos, fecha de nacimiento, género, Clave Única de Registro de Población, entidad federativa de nacimiento, nacionalidad, domicilio completo y tipo de identificación presentada. Esa coincidencia es la que convierte a las validaciones de longitud en pruebas regulatorias y no en pruebas cosméticas.

| Marco | Qué exige en este recorrido | Dónde se implementa |
|---|---|---|
| Disposiciones artículo 115 de la Ley de Instituciones de Crédito | Expediente de identificación simplificado completo y consistente | `OpenCustomerAccountRequest` |
| Comisión Nacional Bancaria y de Valores, identificación no presencial | Verificación biométrica contra la identificación oficial, control de intentos, datos del dispositivo | Bloques B y D, encabezados del bloque E |
| Comisión Nacional Bancaria y de Valores, banca electrónica DGSCM-BI-12/2011 | Segundo factor de autenticación, dispositivo registrado, bitácora de la operación | Validación de contraseña de un solo uso y bitácora web |
| Ley Federal de Protección de Datos Personales en Posesión de los Particulares | Consentimiento expreso para tratar datos biométricos e integridad del dato | `consentIdentityDataVerification` y verificación MD5 |
| Ley de Protección y Defensa al Usuario de Servicios Financieros | Aceptación informada del contrato de adhesión, del aviso de privacidad y de los términos, y su conservación | `validateContracts` y `CustomerAgreementsInfoEntity` |

Las referencias a artículos concretos deben validarse con el SME de Regulatory/CNBV antes de usarse en un entregable al cliente. Lo que sí está verificado contra el código es la obligación funcional que cada caso prueba.

---

## 4. Catálogo de casos

### Bloque E1 — Encabezados y cifrado de la petición

| ID | Caso | Téc. | Pri | Regulador | Resultado esperado | Evidencia |
|---|---|---|---|---|---|---|
| TC-N2-E-001 | El encabezado de información del dispositivo trae menos de tres segmentos separados por diagonal | EQ | P1 | CNBV banca electrónica | Se rechaza con excepción de encabezados incorrectos | `OpenClientServiceImpl:434` |
| TC-N2-E-002 | El encabezado de información del dispositivo trae tres segmentos | EQ | P1 | CNBV banca electrónica | La petición continúa | `OpenClientServiceImpl:434` |
| TC-N2-E-003 | El agente de usuario trae menos de tres segmentos | EQ | P1 | CNBV banca electrónica | Se rechaza con excepción de encabezados incorrectos | `OpenClientServiceImpl:436` |
| TC-N2-E-004 | El tercer segmento del agente de usuario no tiene dos partes separadas por guion | BVA | P1 | CNBV banca electrónica | Se rechaza con excepción de encabezados incorrectos | `OpenClientServiceImpl:437` |
| TC-N2-E-005 | El cuerpo cifrado no se puede descifrar con la llave privada del servidor | NEG | P1 | | Se rechaza con excepción de seguridad criptográfica | `OpenClientServiceImpl:175` |

### Bloque E2 — Máquina de estados de la sesión de apertura

La sesión se identifica con una llave en memoria calculada como el resumen MD5 de la concatenación del identificador de dispositivo y el número de teléfono. El estado previo obligatorio es `DATA_VALIDATION`.

| ID | Caso | Téc. | Pri | Regulador | Resultado esperado | Evidencia |
|---|---|---|---|---|---|---|
| TC-N2-E-006 | La llave de sesión no existe en memoria | ST | P1 | CNBV identificación no presencial | Se rechaza con código 000312 | `OpenClientServiceImpl:549` |
| TC-N2-E-007 | La llave existe pero su valor está vacío | ST | P1 | | Se rechaza con código 000312 | `OpenClientServiceImpl:557` |
| TC-N2-E-008 | El valor almacenado no es un objeto interpretable | NEG | P2 | | Se rechaza con código 000312 | `OpenClientServiceImpl:566` |
| TC-N2-E-009 | El mapa de sesión no contiene la clave de estado actual | ST | P1 | | Se rechaza con código 000312 | `OpenClientServiceImpl:570` |
| TC-N2-E-010 | El estado de la sesión es distinto de `DATA_VALIDATION` | ST | P1 | CNBV identificación no presencial | Se rechaza con código 000312 | `OpenClientServiceImpl:583` |
| TC-N2-E-011 | El estado de la sesión es `DATA_VALIDATION` | ST | P1 | CNBV identificación no presencial | La petición continúa al siguiente control | `OpenClientServiceImpl:583` |
| TC-N2-E-012 | La bandera de validación de estado está apagada en configuración | NEG | P1 | CNBV identificación no presencial | Documentar el comportamiento: la apertura procede sin comprobar que el cliente pasó por la validación de datos | `OpenClientServiceImpl:183` |

### Bloque E3 — Segundo factor de autenticación

| ID | Caso | Téc. | Pri | Regulador | Resultado esperado | Evidencia |
|---|---|---|---|---|---|---|
| TC-N2-E-013 | No existe contraseña de un solo uso vigente para el teléfono y el dispositivo | NEG | P1 | CNBV banca electrónica | Se rechaza con código 000312 y se registra la telemetría de la apertura abandonada | `OpenClientServiceImpl:190` |
| TC-N2-E-014 | Existe contraseña de un solo uso vigente | EQ | P1 | CNBV banca electrónica | La petición continúa | `OpenClientServiceImpl:190` |
| TC-N2-E-015 | Un control posterior falla después de haber recuperado la contraseña de un solo uso | ST | P1 | CNBV banca electrónica | La contraseña queda marcada como usada y no se puede reutilizar en un segundo intento | `OpenClientServiceImpl:211` |

### Bloque E4 — Integridad de la imagen biométrica

| ID | Caso | Téc. | Pri | Regulador | Resultado esperado | Evidencia |
|---|---|---|---|---|---|---|
| TC-N2-E-016 | El resumen MD5 calculado sobre la imagen coincide con el enviado en el campo correspondiente | EQ | P1 | LFPDPPP | La petición continúa | `OpenClientServiceImpl:209` |
| TC-N2-E-017 | El resumen MD5 calculado no coincide con el enviado | EQ | P1 | LFPDPPP | Se rechaza con código 000289, se consume la contraseña de un solo uso, se borra la sesión y se registra la telemetría | `OpenClientServiceImpl:209-217` |
| TC-N2-E-018 | La imagen enviada no se puede leer ni convertir a base64 | NEG | P2 | | Se rechaza como petición incorrecta | `OpenClientServiceImpl:205` |

### Bloque E5 — Consentimientos contractuales

El servicio exige que los cinco consentimientos lleguen aceptados. Basta uno en falso para abortar la apertura. Cada uno se prueba por separado porque el rechazo es colectivo y un defecto en uno solo quedaría oculto.

| ID | Caso | Téc. | Pri | Regulador | Resultado esperado | Evidencia |
|---|---|---|---|---|---|---|
| TC-N2-E-019 | El contrato de apertura de cuenta llega sin aceptar | EQ | P1 | CONDUSEF | Se rechaza con excepción de contratos inválidos y se consume la contraseña de un solo uso | `OpenClientServiceImpl:477` |
| TC-N2-E-020 | Los términos y condiciones del código de verificación dinámico llegan sin aceptar | EQ | P1 | CONDUSEF | Se rechaza con excepción de contratos inválidos | `OpenClientServiceImpl:478` |
| TC-N2-E-021 | El contrato de servicios digitales llega sin aceptar | EQ | P1 | CONDUSEF | Se rechaza con excepción de contratos inválidos | `OpenClientServiceImpl:479` |
| TC-N2-E-022 | El aviso de privacidad llega sin aceptar | EQ | P1 | LFPDPPP | Se rechaza con excepción de contratos inválidos | `OpenClientServiceImpl:480` |
| TC-N2-E-023 | Los términos y condiciones generales llegan sin aceptar | EQ | P1 | CONDUSEF | Se rechaza con excepción de contratos inválidos | `OpenClientServiceImpl:481` |
| TC-N2-E-024 | Los cinco consentimientos llegan aceptados | EQ | P1 | CONDUSEF | La petición continúa y se construye el objeto de acuerdos | `OpenClientServiceImpl:469-489` |
| TC-N2-E-025 | Tras una apertura exitosa se consulta la evidencia de consentimiento del cliente | GM | P1 | CONDUSEF | Los cinco consentimientos quedan persistidos y son recuperables con fecha y cliente | `ValidateStatusBusiness:257, CustomerAgreementsInfoEntity` |

### Bloque E6 — Antifraude conductual

| ID | Caso | Téc. | Pri | Regulador | Resultado esperado | Evidencia |
|---|---|---|---|---|---|---|
| TC-N2-E-026 | La política antifraude resuelve rechazar la sesión | NEG | P1 | | Se rechaza con código 000628 | `configMap:259, 274` |
| TC-N2-E-027 | La política antifraude resuelve pedir autenticación adicional | NEG | P1 | | Se responde con código 000702 solicitando autenticación | `configMap:260, 275` |
| TC-N2-E-028 | La bandera de aplicación de política antifraude está apagada | NEG | P1 | | Documentar el comportamiento: se obtiene la calificación pero no se aplica ni el rechazo ni la autenticación adicional | `configMap:273` |
| TC-N2-E-029 | La petición al proveedor antifraude viaja con tipo de actividad de apertura de cuenta nueva y plataforma de aplicación móvil | GM | P2 | | Ambos valores llegan al proveedor sin alteración | `configMap:245-246` |
| TC-N2-E-030 | El proveedor antifraude responde con un estado de error catalogado | NEG | P2 | | La apertura no se bloquea por el error del proveedor ni se aprueba sin evaluación | `configMap:253` |

### Bloque E7 — Desenlaces de la solicitud de apertura

El canal llama a `/apertura/solicitar` y traduce la respuesta de la plataforma. Los valores de negocio son la cadena `Aprobada` y la cadena `Rechazada`, y el código de rechazo es `00047`.

| ID | Caso | Téc. | Pri | Regulador | Resultado esperado | Evidencia |
|---|---|---|---|---|---|---|
| TC-N2-E-031 | La plataforma responde con éxito y solicitud `Aprobada` | ST | P1 | | Se devuelve 200 y continúa la validación de estatus | `OpenClientServiceImpl:344-349` |
| TC-N2-E-032 | La plataforma responde con éxito y solicitud `Rechazada` | ST | P1 | | Se devuelve 403 con código 000127, se consume la contraseña de un solo uso, se borra la sesión y se registra la telemetría | `OpenClientServiceImpl:352-367` |
| TC-N2-E-033 | La plataforma responde cuenta aprobada con código de retorno `00047` | ST | P1 | | Se devuelve 403 con código 000127 | `OpenClientServiceImpl:370-387` |
| TC-N2-E-034 | La plataforma responde cuenta aprobada con código de retorno distinto de `00047` | ST | P1 | | Se devuelve 201 con código 000127, indicando que el solicitante ya tiene una cuenta de nivel 2 | `OpenClientServiceImpl:389-393` |
| TC-N2-E-035 | La plataforma responde solicitud en proceso | ST | P1 | | Se devuelve 202 y el cliente queda en espera | `OpenClientServiceImpl:395-398` |
| TC-N2-E-036 | La plataforma responde con cuerpo nulo | NEG | P1 | | Se rechaza con código 000122 y se registra la telemetría | `OpenClientServiceImpl:328-337` |
| TC-N2-E-037 | La plataforma responde con un código distinto de 200, 201 y 202 | NEG | P1 | | Caso de defecto latente: hoy el estado devuelto queda nulo y ninguna rama lo captura | `OpenClientServiceImpl:340-402` |
| TC-N2-E-038 | La llamada a la plataforma agota el tiempo de espera o es reintentable | NEG | P1 | CNBV trazabilidad | Se rechaza por tiempo agotado, se escribe bitácora con código 000915 y se registra la telemetría | `OpenClientServiceImpl:269-277` |
| TC-N2-E-039 | La plataforma responde con un error de sistema descendente | NEG | P1 | CNBV trazabilidad | Se rechaza con código 000122 y se escribe bitácora | `OpenClientServiceImpl:278-286` |

### Bloque E8 — Estatus final de la apertura

| ID | Caso | Téc. | Pri | Regulador | Resultado esperado | Evidencia |
|---|---|---|---|---|---|---|
| TC-N2-E-040 | El estatus de la solicitud es el código de rechazo | ST | P1 | | Se responde rechazo con código 000127 | `ValidateStatusBusiness:215-227` |
| TC-N2-E-041 | El estatus de la solicitud es el código de espera | ST | P1 | | Se responde espera con código 000136 | `ValidateStatusBusiness:229-236` |
| TC-N2-E-042 | El estatus de la solicitud es favorable | ST | P1 | | Se responde 200 con los datos de la cuenta abierta | `ValidateStatusBusiness:242` |
| TC-N2-E-043 | La consulta de estatus responde con tiempo agotado | NEG | P1 | | Se rechaza por tiempo agotado | `ValidateStatusBusiness:174-177` |
| TC-N2-E-044 | El canal que solicita tiene habilitada la captura de geolocalización | EQ | P1 | CNBV identificación no presencial | La geolocalización se captura y queda en la bitácora de la apertura | `ValidateStatusBusiness:298` |

### Bloque E9 — Expediente de identificación simplificado

Todos los casos de este bloque son regulatorios. Cada campo del contrato de la interfaz es un dato del expediente de identificación que la norma exige para el nivel 2, y las longitudes declaradas son el control que impide que el expediente se forme mal.

| ID | Caso | Téc. | Pri | Regulador | Resultado esperado | Evidencia |
|---|---|---|---|---|---|---|
| TC-N2-E-045 | La Clave Única de Registro de Población trae 17 caracteres | BVA | P1 | Disposiciones artículo 115 | Se rechaza con código 000911 o 000912 | `OpenCustomerAccountRequest:80` |
| TC-N2-E-046 | La Clave Única de Registro de Población trae 18 caracteres | BVA | P1 | Disposiciones artículo 115 | Se acepta | `OpenCustomerAccountRequest:80` |
| TC-N2-E-047 | La Clave Única de Registro de Población trae 19 caracteres | BVA | P1 | Disposiciones artículo 115 | Se rechaza | `OpenCustomerAccountRequest:80` |
| TC-N2-E-048 | El género trae más de un carácter | BVA | P1 | Disposiciones artículo 115 | Se rechaza | `OpenCustomerAccountRequest:73` |
| TC-N2-E-049 | La entidad federativa de nacimiento trae uno o tres caracteres | BVA | P1 | Disposiciones artículo 115 | Se rechaza, el campo exige exactamente dos | `OpenCustomerAccountRequest:188` |
| TC-N2-E-050 | El número de teléfono trae una longitud distinta de diez dígitos | BVA | P1 | CNBV banca electrónica | Se rechaza como petición incorrecta | `ValidateStatusBusiness:285` |
| TC-N2-E-051 | El código postal trae seis caracteres | BVA | P1 | Disposiciones artículo 115 | Se rechaza, el máximo es cinco | `OpenCustomerAccountRequest:129` |
| TC-N2-E-052 | La calle trae 40 y luego 41 caracteres | BVA | P1 | Disposiciones artículo 115 | Se acepta con 40 y se rechaza con 41 | `OpenCustomerAccountRequest:108` |
| TC-N2-E-053 | La colonia trae 60 y luego 61 caracteres | BVA | P1 | Disposiciones artículo 115 | Se acepta con 60 y se rechaza con 61 | `OpenCustomerAccountRequest:115` |
| TC-N2-E-054 | El municipio trae 40 y luego 41 caracteres | BVA | P1 | Disposiciones artículo 115 | Se acepta con 40 y se rechaza con 41 | `OpenCustomerAccountRequest:122` |
| TC-N2-E-055 | La nacionalidad llega como `001` y luego con cuatro caracteres | BVA | P1 | Disposiciones artículo 115 | Se acepta `001` y se rechaza la de cuatro | `OpenCustomerAccountRequest:87` |
| TC-N2-E-056 | El código de identificación llega como `A`, correspondiente a la credencial para votar | EQ | P1 | Disposiciones artículo 115 | Se acepta | `OpenCustomerAccountRequest:94` |
| TC-N2-E-057 | El tipo de validación llega como `1`, como `2` y como `3` | EQ | P1 | Disposiciones artículo 115 | Se aceptan credencial para votar y pasaporte, y se rechaza el tercer valor | `OpenCustomerAccountRequest:174` |
| TC-N2-E-058 | Cada campo obligatorio del expediente se envía vacío, uno por ejecución | EQ | P1 | Disposiciones artículo 115 | Se rechaza con código 000911 en los veinte campos marcados como no vacíos y en los siete marcados como no nulos | `OpenCustomerAccountRequest:44-237` |
| TC-N2-E-059 | El número de cliente se envía vacío o con un valor arbitrario | NEG | P1 | Disposiciones artículo 115 | Caso de hueco de control: el campo no declara validación alguna y hoy se acepta cualquier valor | `OpenCustomerAccountRequest:39` |
| TC-N2-E-060 | El correo electrónico se envía sin formato válido | NEG | P2 | | Caso de hueco de control: el campo solo exige que no esté vacío, sin validación de formato | `OpenCustomerAccountRequest:167` |
| TC-N2-E-061 | La fecha de nacimiento se envía con un formato distinto de año, mes y día | NEG | P1 | Disposiciones artículo 115 | Caso de hueco de control: el campo solo exige que no esté vacío, el formato documentado no se valida | `OpenCustomerAccountRequest:66` |
| TC-N2-E-062 | Se inspecciona la petición que el canal envía a la plataforma de apertura | GM | P1 | Disposiciones artículo 115 | Caso de defecto: el canal vacía el estado civil y pone en cero la actividad y la subactividad económica antes de enviar, de modo que el expediente llega sin esos datos | `OpenClientServiceImpl:253-256` |

### Bloque E10 — Trazabilidad

| ID | Caso | Téc. | Pri | Regulador | Resultado esperado | Evidencia |
|---|---|---|---|---|---|---|
| TC-N2-E-063 | Cualquier rechazo del recorrido ocurre durante una apertura en curso | GM | P1 | CNBV trazabilidad | Se registra la telemetría con identificador de la sesión, teléfono y tiempo transcurrido de la apertura | `OpenClientServiceImpl:193, 214, 334` |
| TC-N2-E-064 | Cualquier desenlace del recorrido se consulta en la bitácora | GM | P1 | CNBV trazabilidad | Existe una entrada con el código de error, el estado devuelto y el número de cliente | `OpenClientServiceImpl:416-421` |

### Bloque D — Validación facial

El umbral de similitud configurado es 92.000 por ciento y el número de intentos permitidos es tres.

| ID | Caso | Téc. | Pri | Regulador | Resultado esperado | Evidencia |
|---|---|---|---|---|---|---|
| TC-N2-D-065 | El consentimiento para verificar la identidad con datos biométricos llega en falso | EQ | P1 | LFPDPPP | Se rechaza como petición incorrecta sin enviar la imagen al proveedor | `FacialValidationBusiness` |
| TC-N2-D-066 | El consentimiento para verificar la identidad con datos biométricos llega en verdadero | EQ | P1 | LFPDPPP | La validación procede | `FacialValidationBusiness` |
| TC-N2-D-067 | El resumen MD5 de la imagen del perfil biométrico no coincide | EQ | P1 | LFPDPPP | Se rechaza por resumen inválido | `FacialValidationBusiness` |
| TC-N2-D-068 | La similitud devuelta es 91.999 | BVA | P1 | CNBV identificación no presencial | Se rechaza la validación facial | `configMap:152` |
| TC-N2-D-069 | La similitud devuelta es exactamente 92.000 | BVA | P1 | CNBV identificación no presencial | Se acepta la validación facial | `configMap:152` |
| TC-N2-D-070 | La similitud devuelta es 92.001 | BVA | P1 | CNBV identificación no presencial | Se acepta la validación facial | `configMap:152` |
| TC-N2-D-071 | El cliente consume el tercer intento de validación facial | BVA | P1 | CNBV identificación no presencial | El tercer intento todavía se procesa | `configMap:146` |
| TC-N2-D-072 | El cliente intenta una cuarta validación facial | BVA | P1 | CNBV identificación no presencial | Se rechaza con código 000376 por intentos rebasados | `configMap:110, 146` |
| TC-N2-D-073 | El servicio de validación facial agota el tiempo de espera | NEG | P2 | | Se responde error de negocio por tiempo agotado | `FacialValidationBusiness` |
| TC-N2-D-074 | La sesión en memoria del cliente no existe al momento de validar | ST | P1 | | Se rechaza por sesión inválida | `FacialValidationBusiness` |

### Bloque B — Validación de la identificación oficial

El tamaño máximo de la imagen en base64 es 2000 y el número de intentos es tres. La sesión de validación vive 900 segundos.

| ID | Caso | Téc. | Pri | Regulador | Resultado esperado | Evidencia |
|---|---|---|---|---|---|---|
| TC-N2-B-075 | La imagen en base64 mide exactamente el tamaño máximo permitido | BVA | P2 | | Se acepta | `configMap:147` |
| TC-N2-B-076 | La imagen en base64 supera el tamaño máximo permitido | BVA | P2 | | Se rechaza con código 000372 | `configMap:110, 147` |
| TC-N2-B-077 | El resumen MD5 de la imagen de la identificación no coincide | EQ | P1 | LFPDPPP | Se rechaza con código 000369 | `configMap:112` |
| TC-N2-B-078 | La petición no trae datos que validar | NEG | P2 | | Se rechaza con código 000370 | `configMap:113` |
| TC-N2-B-079 | No se encuentran los datos del cliente a validar | NEG | P1 | Disposiciones artículo 115 | Se rechaza con código 000380 | `configMap:114` |
| TC-N2-B-080 | Los datos de la identificación no resultan válidos | NEG | P1 | Disposiciones artículo 115 | Se rechaza con código 000381 | `configMap:115` |
| TC-N2-B-081 | El solicitante nació en el extranjero | NEG | P1 | Disposiciones artículo 115 | Se rechaza con código 000401, el nivel 2 digital no admite ese supuesto por esta vía | `configMap:118` |
| TC-N2-B-082 | El cliente intenta una cuarta validación de la identificación | BVA | P1 | CNBV identificación no presencial | Se rechaza con código 000376 | `configMap:117, 149` |
| TC-N2-B-083 | Han transcurrido 899 segundos desde que inició la validación | BVA | P2 | | La sesión sigue viva | `configMap:145` |
| TC-N2-B-084 | Han transcurrido 901 segundos desde que inició la validación | BVA | P2 | | La sesión expiró y el cliente debe reiniciar | `configMap:145` |
| TC-N2-B-085 | El servicio de reconocimiento óptico no está disponible | NEG | P2 | | Se rechaza con código 000411 | `configMap:116` |
| TC-N2-B-086 | El servicio de reconocimiento óptico agota el tiempo de espera | NEG | P2 | | Se rechaza con código 000371 | `configMap:111` |

### Bloque de recorrido completo

| ID | Caso | Téc. | Pri | Regulador | Resultado esperado | Evidencia |
|---|---|---|---|---|---|---|
| TC-N2-E2E-087 | Un cliente nuevo completa el recorrido con datos válidos, identificación legible, rostro coincidente y los cinco consentimientos aceptados | E2E | P1 | Disposiciones artículo 115 | La cuenta de nivel 2 queda abierta, el cliente dado de alta y los consentimientos conservados | Recorrido completo |
| TC-N2-E2E-088 | La plataforma rechaza la solicitud por criterios de negocio | E2E | P1 | | El cliente recibe el rechazo, la contraseña de un solo uso queda consumida y la sesión borrada | Bloques E3, E5 y E7 |
| TC-N2-E2E-089 | El solicitante ya tiene una cuenta de nivel 2 aprobada | E2E | P1 | | Se responde 201 informando la cuenta existente sin crear una segunda | Bloque E7 |
| TC-N2-E2E-090 | El solicitante ya tiene una solicitud en proceso | E2E | P1 | | Se responde 202 y no se duplica la solicitud | Bloque E7 |
| TC-N2-E2E-091 | El cliente reintenta la apertura inmediatamente después de un rechazo | E2E | P1 | CNBV banca electrónica | El reintento falla en el control de sesión porque la contraseña fue consumida y la sesión borrada, obligando a reiniciar desde el primer paso | Bloques E2 y E3 |

---

## 5. Resumen del catálogo

| Dimensión | Conteo |
|---|---|
| Casos totales | 91 |
| Casos regulatorios | 57 |
| Casos no regulatorios | 34 |
| Prioridad P1 | 78 |
| Prioridad P2 | 13 |

Distribución por técnica: 24 de prueba negativa, 22 de valores límite, 20 de partición de equivalencia, 15 de transición de estado, 5 de golden master y 5 de recorrido completo. Prueba negativa y valores límite dominan por dos razones distintas: el recorrido está densamente cubierto de códigos de error catalogados, y el expediente de identificación se defiende con longitudes exactas que merecen sus tres casos cada una.

Reparto de los casos regulatorios por marco:

| Marco | Casos |
|---|---|
| Disposiciones artículo 115 de la Ley de Instituciones de Crédito | 20 |
| Comisión Nacional Bancaria y de Valores, banca electrónica y trazabilidad | 13 |
| Comisión Nacional Bancaria y de Valores, identificación no presencial | 11 |
| Ley Federal de Protección de Datos Personales en Posesión de los Particulares | 7 |
| Ley de Protección y Defensa al Usuario de Servicios Financieros | 6 |

Un caso puede responder a más de un marco; el reparto asigna a cada uno su marco predominante.

## 6. Hallazgos que el catálogo expone

La derivación desde el código dejó a la vista cinco cosas que no son casos de prueba sino problemas, y que conviene resolver antes de ejecutar la campaña.

El canal vacía el estado civil y pone en cero la actividad y la subactividad económica justo antes de enviar la solicitud a la plataforma de apertura. El expediente de identificación llega sin esos datos y la pérdida es silenciosa porque ocurre después de la validación de la petición. Es el hallazgo con mayor exposición regulatoria del recorrido.

El número de cliente no declara ninguna validación en el contrato de la interfaz. Los demás campos sin anotación son opcionales por diseño: el segundo nombre, el apellido materno y el tiempo transcurrido de la apertura. El número de cliente no lo es, y hoy es el único dato identificatorio que entra sin control de forma.

La política del proveedor antifraude está apagada en la configuración. La calificación de riesgo se obtiene pero ni el rechazo ni la petición de autenticación adicional se aplican, de modo que el control existe en el código y no en la operación.

La validación del estado de la sesión depende de una bandera que puede apagarse. Con la bandera apagada, una apertura puede llegar al alta sin haber pasado por la validación de datos previa.

Cuando la plataforma responde con un código distinto de 200, 201 y 202, ninguna rama del método que interpreta la respuesta la captura y el estado devuelto queda nulo. El comportamiento resultante no está definido.

## 7. Pendientes

Los bloques A y C, validación del candidato y recuperación de los datos de la identificación, están declarados en el alcance pero sin casos derivados. Su lógica vive en la plataforma de apertura y el canal solo la reexpone, de modo que derivar casos útiles exige leer el lado de la plataforma, que no está en este repositorio. Quedan para una segunda pasada.

El tope de depósitos mensuales de la cuenta de nivel 2 no se valida en el canal y no apareció en ningún microservicio del recorrido. Hay que confirmar con la plataforma de apertura o con el núcleo dónde se aplica, porque es una obligación de la misma norma que define el nivel.

Las referencias a artículos regulatorios concretos requieren validación del SME de Regulatory/CNBV antes de incluirse en un entregable al cliente.

---

*v1.0.0 · 2026-10-15 · AppMovil · Derivado del código fuente de los microservicios de apertura*

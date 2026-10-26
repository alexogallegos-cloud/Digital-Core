# Test Strategy — Cadena de valor de tarjeta de crédito

> **Artefacto**: Catálogo de casos de prueba de la cadena de valor, con casuísticas
> **Versión**: 1.0.0
> **Fecha**: 2026-10-16
> **Registro**: Lenguaje de negocio. Sin nombres de sistemas, proveedores ni componentes técnicos.

---

## Cómo leer este documento

La cadena de valor de una tarjeta de crédito tiene ocho líneas, desde que una persona la pide hasta que el banco recupera lo que le prestó. Cada línea tiene casos de prueba de dos naturalezas distintas.

Los **funcionales** verifican que el banco hace lo que ofreció: que aprueba o niega bien, que cobra lo que corresponde, que informa lo que debe. Los **no funcionales** verifican que lo hace en condiciones aceptables: a tiempo, de forma continua y sin exponer información de nadie.

Cruzado con eso, cada caso es o no **regulatorio**. Lo es cuando lo que prueba es algo que una norma exige, no algo que el banco prefiere. Son dos ejes independientes: hay casos funcionales regulatorios y no funcionales regulatorios, igual que los hay de ambos tipos sin obligación normativa.

Las **casuísticas** son las variantes que cada caso debe recorrer. Un caso con cinco casuísticas no es una prueba, son cinco ejecuciones del mismo caso con situaciones distintas.

| Línea | Casos | Funcionales | No funcionales | Regulatorios |
|---|---|---|---|---|
| 1 Originación | 8 | 4 | 4 | 5 |
| 2 Emisión | 7 | 3 | 4 | 4 |
| 3 Activación | 5 | 2 | 3 | 4 |
| 4 Autorización | 7 | 1 | 6 | 4 |
| 5 Transacciones | 6 | 2 | 4 | 2 |
| 6 Pagos | 7 | 3 | 4 | 6 |
| 7 Contabilidad | 6 | 3 | 3 | 6 |
| 8 Cobranza | 7 | 4 | 3 | 6 |
| **Total** | **53** | **22** | **31** | **37** |

De los 53, veintinueve ya estaban identificados y veinticuatro se agregan aquí, todos ellos no funcionales. Las líneas de pagos, contabilidad y cobranza no tenían ninguna prueba no funcional hasta ahora.

---

## 1. Originación

La línea donde una persona pide la tarjeta y el banco decide si se la da.

### OR-01. El banco resuelve la solicitud en la misma sesión
**Funcional. Regulatorio.** Una persona solicita la tarjeta por el canal digital y obtiene una respuesta sin tener que acudir a una sucursal ni esperar días.

Casuísticas: solicitante sin historial crediticio previo; solicitante con historial favorable y capacidad de pago suficiente; solicitante que ya es cliente del banco con otro producto; solicitante que abandona a medio camino y retoma después; solicitante aprobado por un monto menor al que pidió.

### OR-02. El cliente conoce el costo antes de firmar
**Funcional. Regulatorio.** Antes de que la persona firme, el banco le muestra de forma destacada cuánto le va a costar la tarjeta al año, y no le permite firmar si no lo ha visto y aceptado.

Casuísticas: tarjeta con anualidad; tarjeta sin anualidad o con anualidad condonada; intento de firmar sin haber aceptado el costo; cambio del monto autorizado después de mostrar el costo, que obliga a recalcularlo y volver a mostrarlo; contrato disponible para consulta y descarga por el cliente.

### OR-03. La negativa por historial se comunica sin exponer el historial
**Funcional. Regulatorio.** Cuando el banco niega la tarjeta por el historial crediticio, avisa con claridad, no revela el detalle y le informa a la persona que tiene derecho a consultarlo por su cuenta.

Casuísticas: negativa por atrasos vigentes; negativa por un quebranto antiguo; persona sin historial suficiente para evaluar; verificación de que el detalle consultado no queda almacenado; mensaje que incluye cómo ejercer el derecho a revisar el historial propio.

### OR-04. La solicitud de una persona con cargo público no se resuelve sola
**Funcional. Regulatorio.** Cuando quien solicita ocupa o ha ocupado un cargo público relevante, la solicitud se detiene y pasa a revisión reforzada en lugar de resolverse automáticamente.

Casuísticas: persona que ocupa un cargo público actualmente; persona que lo ocupó en el pasado reciente; familiar directo o asociado cercano de alguien con cargo público; coincidencia parcial de nombre, que debe resolverse sin bloquear a un homónimo; registro de la decisión y de quién la tomó.

### OR-05. La respuesta llega en menos de cinco minutos
**No funcional. No regulatorio.** La persona obtiene respuesta sin esperar más de cinco minutos desde que empieza a capturar sus datos.

Casuísticas: solicitud en horario de baja demanda; solicitud en hora pico; solicitud mientras una de las consultas externas responde con lentitud; solicitud durante una campaña comercial con volumen elevado.

### OR-06. La información sensible de la decisión queda protegida
**No funcional. Regulatorio.** El historial crediticio y el resultado de la revisión contra listas viajan protegidos y no se guardan más allá de lo que la decisión requiere.

Casuísticas: verificación de que el detalle del historial no queda en registros de operación; verificación de que el resultado de la revisión contra listas solo es visible para quien debe verlo; intento de acceso desde un perfil sin autorización; borrado de la información temporal una vez resuelta la solicitud.

### OR-07. El proceso sostiene el volumen de una campaña
**No funcional. No regulatorio.** El proceso de solicitud aguanta el volumen de una campaña comercial sin que las personas vean errores ni esperas inaceptables.

Casuísticas: volumen de un día normal; volumen de campaña con el pico proyectado; volumen por encima del pico, para encontrar el punto de quiebre; recuperación del servicio una vez que el pico pasa.

### OR-08. La caída de un tercero no deja al cliente sin respuesta
**No funcional. No regulatorio.** Si alguno de los terceros que el banco consulta para decidir deja de responder, la solicitud no se pierde ni deja a la persona esperando indefinidamente.

Casuísticas: caída de la consulta de historial crediticio; caída de la evaluación de riesgo; caída de la revisión contra listas; caída del registro único de clientes; caída simultánea de dos de ellos.

---

## 2. Emisión

La línea donde la aprobación se convierte en un plástico en manos del cliente.

### EM-01. El banco arma el pedido de fabricación del día
**Funcional. Regulatorio.** Las tarjetas aprobadas del día se agrupan y se prepara el pedido para que el fabricante las produzca.

Casuísticas: pedido con tarjetas de un solo tipo de producto; pedido que mezcla tarjeta nueva, reposición y renovación; pedido de un día sin aprobaciones; pedido que supera el tamaño habitual; corrección de un pedido antes de enviarlo.

### EM-02. El pedido llega al fabricante sin intervención manual
**Funcional. Regulatorio.** El pedido se entrega al fabricante de forma automática, sin que una persona tenga que enviarlo.

Casuísticas: envío exitoso en la ventana habitual; envío cuando el fabricante no está disponible y debe reintentarse; envío duplicado, que el fabricante debe rechazar; confirmación de recepción por parte del fabricante. Hoy este envío se hace de forma manual, de modo que el caso documenta una brecha.

### EM-03. La sucursal recibe y puede cancelar lotes
**Funcional. No regulatorio.** La sucursal recibe los lotes de tarjetas producidas y puede cancelar un lote cuando corresponde.

Casuísticas: recepción completa del lote; recepción parcial con faltantes; cancelación de un lote antes de recibirlo; cancelación de un lote ya recibido; consulta del estado de un lote por sucursal.

### EM-04. Los datos de las tarjetas viajan cifrados
**No funcional. Regulatorio.** El archivo con los datos de las tarjetas viaja cifrado y nadie que lo intercepte puede leerlo.

Casuísticas: archivo cifrado correctamente y legible solo por el fabricante; archivo alterado en tránsito, que debe detectarse; intento de abrirlo sin la llave correcta; verificación de que el archivo no queda sin cifrar en ningún punto intermedio.

### EM-05. El día de mayor emisión cabe en la ventana nocturna
**No funcional. No regulatorio.** El pedido del día de mayor emisión del año se prepara y se envía dentro de la ventana nocturna disponible.

Casuísticas: volumen de un día promedio; volumen del día pico del año; volumen acumulado de dos días, cuando el proceso falló el día anterior; medición del margen restante de la ventana al terminar.

### EM-06. El proceso de emisión está disponible cuando se necesita
**No funcional. No regulatorio.** El proceso de preparación y envío está disponible prácticamente todos los días del mes y falla muy rara vez.

Casuísticas: disponibilidad medida en un mes completo; comportamiento ante una interrupción programada; comportamiento ante una interrupción no programada; tiempo de recuperación tras la interrupción.

### EM-07. Las llaves que protegen las tarjetas se custodian y se renuevan
**No funcional. Regulatorio.** Las llaves que protegen los datos de las tarjetas se guardan en un dispositivo dedicado, se renuevan periódicamente, y el número de tarjeta nunca aparece en los registros de operación.

Casuísticas: verificación de que la llave no sale del dispositivo; renovación de llave sin interrumpir la operación; revisión de registros de operación en busca del número de tarjeta; intento de uso de una llave vencida.

---

## 3. Activación

La línea donde el cliente enciende su tarjeta y la vuelve utilizable.

### AC-01. La tarjeta llega apagada
**Funcional. Regulatorio.** La tarjeta llega a manos del cliente sin servir para comprar, hasta que él mismo la enciende.

Casuísticas: intento de compra con la tarjeta recién recibida y sin activar; intento de retiro en cajero sin activar; activación por el titular y primera compra posterior; tarjeta de reposición, que también debe llegar apagada; tarjeta adicional de un usuario autorizado.

### AC-02. El cliente activa desde la aplicación comprobando que es él
**Funcional. Regulatorio.** El cliente activa su tarjeta desde la aplicación del banco comprobando su identidad, y queda lista para usarse de inmediato.

Casuísticas: activación de tarjeta digital; activación de tarjeta física; cliente sin la aplicación instalada, que debe poder activar por otro canal; activación de una tarjeta que ya estaba activa; activación de una tarjeta cancelada, que debe rechazarse.

### AC-03. Varios intentos fallidos bloquean y protegen al titular
**No funcional. Regulatorio.** Si alguien intenta activar una tarjeta varias veces sin comprobar su identidad, el banco bloquea el intento.

Casuísticas: primer y segundo intento fallido, que todavía permiten reintentar; tercer intento fallido, que bloquea; bloqueo que persiste al cambiar de dispositivo; desbloqueo por el canal de atención; aviso al titular de que hubo intentos fallidos.

### AC-04. La activación se resuelve en el momento
**No funcional. No regulatorio.** El cliente no percibe espera al activar.

Casuísticas: activación en horario normal; activación en hora pico, típicamente al final del día; activación cuando la comprobación de identidad tarda más de lo normal; activaciones simultáneas tras una entrega masiva de tarjetas.

### AC-05. El servicio de activación está disponible de forma continua
**No funcional. Regulatorio.** Un cliente que recibe su tarjeta y no puede activarla la abandona, de modo que el servicio debe estar disponible casi sin interrupción.

Casuísticas: disponibilidad medida en un mes completo; activación durante una ventana de mantenimiento; recuperación tras una interrupción; qué ve el cliente en la aplicación cuando el servicio no responde.

---

## 4. Autorización

La línea donde cada compra se aprueba o se rechaza en tiempo real.

### AU-01. La compra que excede la línea se rechaza con un motivo claro
**Funcional. No regulatorio.** Cuando el cliente intenta una compra que supera su línea disponible, se rechaza y el comercio recibe un motivo correcto.

Casuísticas: compra que supera la línea por poco; compra que la supera ampliamente; compra que cabe justo en la línea disponible; compra que cabría pero otra operación en curso ya apartó el monto; compra rechazada y reintentada por un importe menor que sí cabe.

### AU-02. El comercio recibe respuesta casi al instante
**No funcional. Regulatorio.** El comercio obtiene la respuesta de autorización prácticamente de inmediato, incluso en las operaciones más lentas del día.

Casuísticas: compra presencial en terminal; compra por internet; compra en el pico de temporada alta; compra mientras la evaluación de riesgo está trabajando; medición del comportamiento de la cola de operaciones más lentas.

### AU-03. El código de seguridad se valida sin quedar expuesto
**No funcional. Regulatorio.** El código de seguridad de la tarjeta se valida dentro de un dispositivo protegido y nunca queda visible.

Casuísticas: compra por internet con código correcto; compra por internet con código incorrecto; compra con código de un solo uso; verificación de que el código no aparece en ningún registro; intento de validarlo sin pasar por el dispositivo protegido.

### AU-04. La autorización funciona a toda hora y se recupera rápido
**No funcional. Regulatorio.** El servicio opera todos los días a cualquier hora, y si se interrumpe vuelve en minutos.

Casuísticas: operación en fin de semana y día festivo; operación durante la ventana de mantenimiento nocturno; caída del nodo principal y paso al alterno; medición del tiempo de recuperación; qué ocurre con las operaciones en vuelo al momento de la caída.

### AU-05. La operación típica es mucho más rápida que el máximo tolerado
**No funcional. No regulatorio.** No basta con cumplir el techo: la experiencia habitual del comercio debe estar muy por debajo de él.

Casuísticas: medición de la operación típica en carga normal; medición en hora pico; comparación contra el máximo tolerado; degradación progresiva conforme sube la carga.

### AU-06. Bajo carga sostenida las fallas técnicas se mantienen acotadas
**No funcional. No regulatorio.** La proporción de operaciones que fallan por causas técnicas se mantiene por debajo de lo tolerado aunque la carga se sostenga.

Casuísticas: carga sostenida durante una hora; carga sostenida durante un día completo; carga con un tercero degradado; conteo y clasificación de las fallas observadas.

### AU-07. El canal con la red de pagos está cifrado con una versión vigente
**No funcional. Regulatorio.** Las operaciones viajan por un canal cifrado con una versión del protocolo que la industria considera vigente.

Casuísticas: conexión establecida con la versión vigente; intento de conexión con una versión obsoleta, que debe rechazarse; renovación del certificado sin interrumpir la operación; comportamiento ante un certificado vencido.

---

## 5. Transacciones

La línea donde el cliente consulta su saldo, sus movimientos y su estado de cuenta.

### TR-01. El estado de cuenta cumple el formato que la norma exige
**Funcional. Regulatorio.** El cliente recibe su estado de cuenta con el formato y los conceptos obligatorios, sin costo y a tiempo.

Casuísticas: mes con movimientos; mes sin movimientos; mes con compras a meses; mes con una aclaración en curso; plazo entre la fecha de corte y la fecha límite de pago; entrega por el canal digital y disponibilidad para descarga.

### TR-02. La consulta telefónica entrega la misma información que la aplicación
**Funcional. No regulatorio.** El cliente consulta sus movimientos por teléfono y escucha lo mismo que vería en la aplicación.

Casuísticas: consulta de los últimos movimientos; consulta de un periodo anterior; consulta de una cuenta sin movimientos; cliente con más de una tarjeta; identificación del cliente antes de entregar información.

### TR-03. El saldo aparece apenas el cliente abre la aplicación
**No funcional. No regulatorio.** La consulta de saldo no hace esperar al cliente.

Casuísticas: consulta en horario normal; consulta en el pico posterior a la fecha de corte; cliente con muchos movimientos; consulta mientras el estado de cuenta se está generando. Hay un conflicto abierto entre dos objetivos de tiempo distintos que debe resolverse antes de ejecutar este caso.

### TR-04. El mensaje de error aparece de inmediato y es el correcto
**No funcional. No regulatorio.** Cuando algo sale mal, el cliente ve el mensaje adecuado sin demora.

Casuísticas: mensaje ante una operación rechazada; mensaje ante indisponibilidad temporal; consistencia de tono y redacción entre canales; tiempo de respuesta del catálogo de mensajes.

### TR-05. El número de tarjeta aparece oculto en todas partes
**No funcional. Regulatorio.** En cualquier pantalla, comprobante o estado de cuenta, el número de la tarjeta se muestra oculto salvo los últimos dígitos.

Casuísticas: consulta de saldo en la aplicación; estado de cuenta descargado; comprobante de una operación; atención telefónica, donde el ejecutivo tampoco debe ver el número completo; registros internos de operación.

### TR-06. El pico posterior al corte no degrada la consulta
**No funcional. No regulatorio.** El día en que todos los clientes consultan a la vez, el servicio sostiene el volumen.

Casuísticas: volumen del día posterior al corte; volumen del día de fecha límite; ambos picos coincidiendo; recuperación tras el pico.

---

## 6. Pagos

La línea donde el cliente devuelve lo que usó.

### PA-01. El pago se refleja en la línea disponible en minutos
**Funcional. Regulatorio.** El cliente paga desde la aplicación y el dinero se refleja en su línea disponible en minutos.

Casuísticas: pago del total; pago del mínimo; pago de un monto intermedio; pago mayor al saldo, que genera saldo a favor; pago desde una cuenta de otro banco; pago realizado fuera del horario de la red interbancaria.

### PA-02. El cliente sabe cuánto y hasta cuándo pagar
**Funcional. Regulatorio.** El pago mínimo y la fecha límite se comunican con claridad y con la anticipación que la norma exige.

Casuísticas: primer estado de cuenta de una tarjeta nueva; estado de cuenta con compras a meses; cliente con pago vencido del periodo anterior; fecha límite que cae en fin de semana o día festivo; verificación del plazo mínimo entre corte y fecha límite.

### PA-03. Un pago fallido no deja al cliente sin su dinero
**Funcional. Regulatorio.** Si un pago falla a medio camino, el dinero regresa al cliente y no se le cobra dos veces.

Casuísticas: falla después de descontar el dinero; falla antes de descontarlo; pago reintentado por el cliente tras una falla; dos pagos idénticos enviados casi al mismo tiempo; verificación del saldo del cliente al cierre del día.

### PA-04. El pago se confirma sin espera perceptible
**No funcional. No regulatorio.** El cliente recibe la confirmación de su pago de inmediato.

Casuísticas: pago en horario normal; pago el día de la fecha límite; pago desde otro banco; pago mientras el proceso de cierre está corriendo.

### PA-05. La acreditación cumple el plazo incluso en el día de mayor volumen
**No funcional. Regulatorio.** El pago se acredita dentro del plazo que la norma marca, también cuando el volumen es máximo.

Casuísticas: acreditación en día normal; acreditación el día de fecha límite; acreditación en el último minuto antes del cierre; acreditación cuando la red interbancaria está congestionada.

### PA-06. En el pico de pagos nadie recibe un cobro duplicado
**No funcional. Regulatorio.** El día en que todos pagan al mismo tiempo, ningún cliente pierde su pago ni se le cobra dos veces.

Casuísticas: pico de pagos del día de fecha límite; el mismo cliente pagando desde dos canales a la vez; pago reenviado por el cliente al no ver confirmación; conciliación de los pagos del día contra lo acreditado.

### PA-07. Los datos de tarjeta en el pago cumplen el estándar de la industria
**No funcional. Regulatorio.** La información de la tarjeta que interviene en el pago se trata conforme al estándar de medios de pago.

Casuísticas: pago con tarjeta propia; pago con tarjeta de otro banco; almacenamiento de la tarjeta para pagos futuros; revisión de registros en busca de datos sensibles.

---

## 7. Contabilidad

La línea invisible para el cliente y decisiva para el regulador.

### CO-01. Lo autorizado en el día queda en los libros ese mismo día
**Funcional. Regulatorio.** Todo lo que se autorizó queda registrado el mismo día y los totales cuadran.

Casuísticas: día de operación normal; día con una operación reversada; día con una operación autorizada tarde que cae en el corte; día con una diferencia detectada, y su resolución; cierre de mes.

### CO-02. Los movimientos llegan íntegros a los libros del banco
**Funcional. Regulatorio.** Los movimientos del producto llegan completos desde donde se procesan hasta los libros contables.

Casuísticas: envío del día completo; envío con un movimiento de ajuste; envío interrumpido y reenviado; envío vacío, en un día sin movimientos; verificación de totales en ambos extremos.

### CO-03. Cada tipo de movimiento tiene su clasificación contable correcta
**Funcional. Regulatorio.** Cada movimiento del producto está clasificado contablemente de forma correcta y documentada.

Casuísticas: compra; pago; comisión y anualidad; interés ordinario e interés moratorio; reversa y ajuste; quebranto. La guía contable está pendiente de entrega, de modo que el caso documenta una brecha.

### CO-04. Los asientos están disponibles pocas horas después del cierre
**No funcional. Regulatorio.** Las áreas que dependen del cierre reciben los asientos dentro de las primeras horas.

Casuísticas: cierre de un día normal; cierre de fin de mes; cierre del día de mayor volumen del año; cierre tras una interrupción del proceso.

### CO-05. El envío del día pico llega completo y a tiempo
**No funcional. Regulatorio.** El envío del día de mayor volumen cabe en la ventana disponible y llega íntegro.

Casuísticas: volumen de un día promedio; volumen del día pico; volumen acumulado de dos días; verificación de integridad en el destino.

### CO-06. Un reintento no duplica ni pierde movimientos
**No funcional. Regulatorio.** Si el envío se reintenta, los movimientos no se duplican ni se pierden.

Casuísticas: reintento tras una interrupción de red; reintento tras un rechazo del destino; el mismo envío enviado dos veces; conciliación posterior al reintento.

---

## 8. Cobranza

La línea que cierra el ciclo del crédito y determina la salud de la cartera.

### CB-01. A los treinta días sin pago la cuenta cambia de condición
**Funcional. Regulatorio.** Cuando un cliente llega a treinta días sin pagar, su cuenta pasa a cartera vencida.

Casuísticas: cliente que llega a treinta días exactos; cliente que paga el día veintinueve; cliente que paga parcialmente; cliente que cae y se recupera dentro del mismo mes; cliente con dos tarjetas, una al corriente y otra vencida.

### CB-02. El contacto ocurre solo en el horario permitido
**Funcional. Regulatorio.** El banco contacta al cliente únicamente dentro del horario que la norma autoriza, y deja constancia de cada contacto.

Casuísticas: contacto dentro del horario permitido; intento de contacto fuera del horario, que debe bloquearse; contacto en día festivo; cliente en una zona con horario distinto; registro del contacto y de su resultado.

### CB-03. Antes de reportar se ofrece una alternativa
**Funcional. Regulatorio.** Antes de reportar a un cliente, el banco le ofrece una forma de regularizarse y deja constancia de la oferta.

Casuísticas: oferta aceptada; oferta rechazada; cliente ilocalizable; cliente que acepta y luego incumple la alternativa; constancia de la oferta en el expediente.

### CB-04. El reporte mensual de cartera vencida cuadra con los libros
**Funcional. Regulatorio.** Cada mes el banco informa el estado de su cartera vencida con cifras consistentes con su contabilidad.

Casuísticas: mes con altas y bajas de cartera vencida; mes sin cambios; corrección de un reporte ya enviado; cuadre del reporte contra los libros contables. No hay evidencia de diseño de este reporte, de modo que el caso documenta una brecha.

### CB-05. El proceso nocturno de clasificación termina a tiempo
**No funcional. Regulatorio.** El proceso que clasifica la cartera por antigüedad termina dentro de su ventana, incluso cuando la cartera crece.

Casuísticas: cartera del tamaño actual; cartera del tamaño proyectado a tres años; proceso que arranca tarde por una demora previa; medición del margen restante de la ventana.

### CB-06. La cobranza se somete a una prueba de intrusión antes de operar
**No funcional. Regulatorio.** El módulo se somete a una prueba de intrusión antes de salir a producción.

Casuísticas: prueba sobre el acceso de los gestores; prueba sobre la información del cliente en mora; prueba sobre el canal de contacto automatizado; corrección de los hallazgos y nueva prueba. La prueba ocupa el único ambiente disponible durante su ventana, lo que bloquea el resto de las pruebas de esta línea.

### CB-07. El motor de gestión está disponible durante la jornada
**No funcional. No regulatorio.** El motor que dirige la gestión está disponible durante la jornada de trabajo de los gestores.

Casuísticas: disponibilidad en jornada de gestión; qué hace el gestor cuando el motor no responde; recuperación tras una interrupción. Esta capacidad todavía no tiene un objetivo de nivel de servicio acordado.

---

## Advertencias sobre el alcance

Los treinta y un casos no funcionales de este catálogo se apoyan en objetivos de nivel de servicio que todavía no están acordados. Diez están propuestos y cuatro bloqueados, ninguno confirmado. Hasta que se acuerden, los umbrales concretos de cada caso son provisionales y los casos deben ejecutarse para establecer una línea base, no para dar un resultado de aprobado o reprobado.

Dos capacidades de la cadena no tienen objetivo de nivel de servicio, ni obligaciones de cumplimiento registradas, ni plan de pruebas: la originación digital y el motor de gestión de cobranza. La primera es el primer eslabón de toda la cadena.

Tres casos documentan brechas conocidas en lugar de verificar una función que existe: el envío automático al fabricante, la guía de clasificación contable y el reporte mensual de cartera vencida. Deben ejecutarse igual, porque su resultado es la evidencia formal de la brecha.

---

*v1.0.0 — 2026-10-16 — 53 casos, 240 casuísticas — Registro de negocio, sin nombres de sistemas*

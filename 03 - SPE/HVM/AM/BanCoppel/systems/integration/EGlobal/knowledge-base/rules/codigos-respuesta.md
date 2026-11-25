# Códigos de respuesta del autorizador

El autorizador responde a la red de marca con un código ISO 8583 de dos dígitos. Ese código no lo inventa: en la mayoría de los casos lo deriva del código de retorno que le entrega el core Informix. Este documento recoge ambos catálogos y la regla de traducción entre ellos.

> Generado desde `digital-brain/brain.db` por `generators/build-knowledge-base.py`. No editar a mano. Construido el 2026-11-04.
> Las cifras agregan 2 lote(s) de evidencia, 2,861,405 transacciones en total:
> - `authorizerj.eglobal.20261104`: 16,412 transacciones en 20 minutos (00:02:40 a 00:22:39), 30 archivos.
> - `eglobal.authorizer.20261103`: 2,844,993 transacciones en 1438 minutos (00:00:00 a 23:57:42), 118 archivos.

---

## Traducción del código del core al código de la red

Esta es la regla de negocio central del documento. La columna de significado en el core proviene del `codret_dictionary` del brain de Informix, cruzada en tiempo de construcción.

| Código del core | Significado en el core | Respuesta ISO | Qué ve el cliente | Volumen |
|-----------------|------------------------|---------------|-------------------|--------|
| `00000` | Si no encontro concurrencias manda 0(no existe). | `00` | Aprobada | 2,216,361 |
| `00400` | Operación rechazada por regla de negocio (fondos, límites o estado) (ej: Fondos insuficientes débito) | `51` | Fondos insuficientes | 447,068 |
| `00005` | No existe el documento | `51` | Fondos insuficientes | 23,087 |
| `00207` | Intento de cargo con crédito vencido "BT" y bloqueado | `62` | Tarjeta restringida | 12,356 |
| `00300` | Entidad o cuenta no encontrada en el sistema (ej: Cuenta bloqueada) | `57` | Transacción no permitida para la tarjeta | 582 |
| `00035` | Sin registro en el diccionario del core | `61` | Excede el límite de monto | 81 |
| `-243` | Sin registro en el diccionario del core | `96` | Falla del sistema | 16 |
| `00120` | Parámetro de configuración no proporcionado (ej: Fecha inicio no deve ser mayor a fecha fin) | `14` | Número de tarjeta inválido | 12 |
| `00200` | Registro no localizado en la base de datos (ej: // FECHA INVALIDA) | `57` | Transacción no permitida para la tarjeta | 3 |
| `00208` | Sin registro en el diccionario del core | `78` | Tarjeta bloqueada o sin activar en su primer uso | 3 |
| `00307` | Condición de retorno no clasificada | `57` | Transacción no permitida para la tarjeta | 2 |
| `00100` | Parámetro de entrada obligatorio no proporcionado (ej: los registros ya fueron enviados a la tabla historica) | `14` | Número de tarjeta inválido | 1 |

El autorizador rellena con ceros a la izquierda el código de tres dígitos que emite el core hasta dejarlo en cinco. Por eso el `400` del diccionario de Informix aparece aquí como `00400`.

Dos salvedades sobre la columna del core. La entrada de `00000` en el diccionario de Informix quedó con una descripción imprecisa, tomada de una muestra ajena a la ruta de tarjetas; la evidencia del propio diccionario muestra que el valor significa que el procedure terminó correctamente. Y la entrada de `00005` proviene de dominios que nada tienen que ver con autorización, así que su significado en esta ruta está sin confirmar pese a aparecer 120 veces.

## Códigos ISO observados

| Código | Significado | Volumen | Participación |
|--------|-------------|---------|---------------|
| `00` | Aprobada | 2,216,369 | 77.5% |
| `51` | Fondos insuficientes | 470,155 | 16.4% |
| `82` | CVV incorrecto | 51,197 | 1.8% |
| `59` | Sospecha de fraude | 37,502 | 1.3% |
| `03` | Comercio inválido | 24,571 | 0.9% |
| `14` | Número de tarjeta inválido | 18,667 | 0.7% |
| `62` | Tarjeta restringida | 12,566 | 0.4% |
| `61` | Excede el límite de monto | 10,689 | 0.4% |
| `54` | Tarjeta vencida | 6,928 | 0.2% |
| `65` | Excede el límite de frecuencia de uso | 6,346 | 0.2% |
| `75` | Excedido el número de intentos de NIP | 2,639 | 0.1% |
| `55` | NIP incorrecto | 1,745 | 0.1% |
| `57` | Transacción no permitida para la tarjeta | 867 | 0.0% |
| `43` | Tarjeta reportada como robada | 445 | 0.0% |
| `41` | Tarjeta reportada como extraviada | 392 | 0.0% |
| `96` | Falla del sistema | 247 | 0.0% |
| `78` | Tarjeta bloqueada o sin activar en su primer uso | 3 | 0.0% |

## Resultado por tipo de transacción

| Tipo de transacción | Total | Aprobadas | Tasa de aprobación |
|---------------------|-------|-----------|--------------------|
| Compra pos | 2,593,267 | 1,984,235 | 76.5% |
| Cash back pos | 132,325 | 118,588 | 89.6% |
| Retiro atm | 65,143 | 54,200 | 83.2% |
| Validacion cuenta | 35,766 | 25,903 | 72.4% |
| Reversa pos | 23,311 | 22,884 | 98.2% |
| Consulta atm | 10,935 | 10,015 | 91.6% |
| Reversa atm | 443 | 442 | 99.8% |
| Sin etiqueta | 215 | 102 | 47.4% |

## Desglose de rechazos

| Tipo de transacción | Resultado | Código ISO | Volumen |
|---------------------|-----------|------------|--------|
| Compra pos | Rechazada | `51` | 449,591 |
| Compra pos | Autorizacion rechazada | `82` | 46,698 |
| Compra pos | Autorizacion rechazada | `59` | 34,382 |
| Compra pos | Autorizacion rechazada | `03` | 23,055 |
| Compra pos | Autorizacion rechazada | `14` | 17,660 |
| Cash back pos | Rechazada | `51` | 12,811 |
| Compra pos | Rechazada | `62` | 12,262 |
| Compra pos | Autorizacion rechazada | `61` | 9,371 |
| Retiro atm | Rechazada | `51` | 7,376 |
| Compra pos | Autorizacion rechazada | `65` | 6,323 |
| Compra pos | Autorizacion rechazada | `54` | 5,163 |
| Validacion cuenta | Autorizacion rechazada | `82` | 4,338 |
| Compra pos | Autorizacion rechazada | `75` | 2,578 |
| Validacion cuenta | Autorizacion rechazada | `54` | 1,622 |
| Validacion cuenta | Autorizacion rechazada | `59` | 1,562 |
| Validacion cuenta | Autorizacion rechazada | `03` | 1,506 |
| Retiro atm | Autorizacion rechazada | `55` | 1,425 |
| Retiro atm | Autorizacion rechazada | `61` | 1,050 |
| Validacion cuenta | Autorizacion rechazada | `14` | 687 |
| Compra pos | Rechazada | `57` | 544 |
| Cash back pos | Autorizacion rechazada | `59` | 522 |
| Retiro atm | Autorizacion rechazada | `59` | 520 |
| Compra pos | Autorizacion rechazada | `43` | 424 |
| Reversa pos | Autorizacion rechazada | `59` | 421 |
| Compra pos | Autorizacion rechazada | `41` | 379 |

# e-global — Application Modernization Agent
# togaf_type: integration
# togaf_state: baseline
# togaf_system_of: record
# togaf_abb: payment-authorization
# bian_domains: ["Card Authorization", "Card Transaction Switch", "Fraud Detection"]

> **Estado:** `[STATE: ACTIVE]` — brain propio construido el 2026-11-04 sobre logs de producción.
> **Evidencia:** un día completo de operación más una ventana de control. 2,861,405 transacciones.
> **Sustituye** el estado `DISCOVERED` que tenía desde el seed de Informix del 2026-08-12.

---

## Qué es este sistema

e-global es el **autorizador de pagos con tarjeta** de BanCoppel. Recibe cada solicitud del front-end InterAct, aplica el conjunto de validaciones de negocio del emisor, consulta y afecta el saldo del cliente invocando stored procedures de Informix, y devuelve el resultado para que InterAct lo convierta en respuesta ISO 8583.

Es el sistema que decide si una compra en el punto de venta, un retiro en cajero o un cargo recurrente se aprueban o se rechazan. Casi tres millones de decisiones al día.

Su clasificación TOGAF es `integration` por su posición en la arquitectura, pero se comporta como **System of Record** de la autorización: la decisión que toma es el hecho de negocio, no un ruteo.

---

## Lo que el brain sabe hoy

Construido con `generators/parse-authorizerj.py`, que destila conocimiento de negocio sin persistir datos de tarjetahabiente.

| Dimensión | Contenido |
|-----------|-----------|
| Transacciones observadas | 2,861,405, de las cuales 2,844,993 son un día completo |
| Validaciones de negocio | 114 identificadores distintos en el ciclo de autorización |
| Funciones del autorizador | 95, con su grafo de llamadas real y su latencia |
| Tipos de transacción | 7 reconocidos, de compra en punto de venta a reversa de cajero |
| Códigos de respuesta ISO | 17 observados, con su distribución real |
| Traducción de códigos | 12 reglas que convierten el código del core en respuesta a la red |
| Stored procedures del core | 6 invocados, 3,503,441 veces en el día |
| Giros de negocio | 338 códigos de comercio distintos |

Consulta: `python digital-brain/brain.py` para el resumen, o los comandos `mix`, `codes`, `mapping`, `core`, `rules`, `search`.

---

## Hallazgos de negocio

### Tres de cada cuatro transacciones se aprueban, y el rechazo tiene una causa dominante

En el día completo la aprobación global es del 77.5 por ciento. El rechazo no se reparte: fondos insuficientes explica el 16.4 por ciento de todas las transacciones, más que todas las demás causas juntas. Le siguen CVV incorrecto con 1.8 por ciento y sospecha de fraude con 1.3.

Por tipo de transacción la aprobación varía de forma reveladora:

| Tipo | Volumen diario | Aprobación |
|------|---------------|-----------|
| Compra en punto de venta | 2,577,811 | 76.6% |
| Cash back en punto de venta | 132,154 | 89.6% |
| Retiro en cajero | 64,966 | 83.2% |
| Validación de cuenta | 35,323 | 72.4% |
| Reversa en punto de venta | 23,189 | 98.2% |
| Consulta en cajero | 10,898 | 91.6% |
| Reversa en cajero | 440 | 99.8% |

El retiro en cajero aprueba mejor que la compra porque el cliente consulta su saldo antes de retirar.

### Una ventana de veinte minutos no representa el día

Vale registrarlo como lección de método. La primera evidencia que entró al brain fueron veinte minutos de madrugada: ahí la aprobación era del 59 por ciento y fondos insuficientes pesaba el 31.8. El día completo corrige ambas cifras a 77.5 y 16.4. De madrugada corren los cargos recurrentes contra saldos agotados, y eso deforma el retrato.

Los dos lotes se conservan por separado en el brain, cada uno con su ventana declarada, precisamente para que una muestra no se confunda con la realidad del día.

### El autorizador traduce el código del core a la red

El core Informix responde con su propio código y el autorizador lo convierte al código ISO que la red entiende. Son doce reglas observadas, verificadas contra el diccionario de códigos del brain de Informix. Las cinco con volumen significativo:

| Código del core | Significado en el core | Respuesta ISO | Qué ve el cliente | Volumen diario |
|-----------------|------------------------|---------------|-------------------|---------------|
| `00000` | Terminó correctamente | `00` | Aprobada | 2,206,659 |
| `00400` | Rechazo por regla de negocio, típicamente fondos insuficientes | `51` | Fondos insuficientes | 441,976 |
| `00005` | Sin significado estable en el diccionario | `51` | Fondos insuficientes | 22,967 |
| `00207` | Cargo con crédito vencido y bloqueado | `62` | Tarjeta restringida | 12,305 |
| `00300` | Cuenta bloqueada o entidad no encontrada | `57` | Transacción no permitida | 577 |

El autorizador rellena a cinco dígitos el código de tres que emite el core.

### Un error del motor Informix llega al tarjetahabiente como falla de sistema

Entre los códigos traducidos aparece `-243`, dieciséis veces en el día, que sale a la red como ISO 96. El diccionario de códigos de negocio del core no tiene **ningún** código negativo: los 329 catalogados son valores de retorno de los stored procedures. La numeración negativa pertenece a los errores del motor Informix, así que lo que viaja hasta la terminal es un fallo de base de datos sin traducir. La muestra capturada tardó 2,937 milisegundos, frente a los cien escasos de una transacción normal.

Las otras 231 respuestas con ISO 96 del día no traen código del core en absoluto: el core no contestó. Conviene confirmar el significado exacto de `-243` con el equipo de base de datos y revisar si corresponde a contención de bloqueos.

### El autorizador es el llamador que le faltaba a varios procedures de Informix

El análisis estático del core dejó a `cargo_ref_cel`, `cons_saldo_cel` y `reversiontd_cel` sin ningún llamador conocido. El log demuestra quién los llama y con qué intensidad.

| Stored procedure | Base en el log | Llamadas en el día | Papel |
|------------------|----------------|-------------------|-------|
| `cargo_ref_cel` | sin prefijo | 2,771,874 | Aplica el cargo de la compra |
| `sp_registra_evento` | `intercard` | 638,424 | Registra el evento del rechazo |
| `cons_saldo_cel` | sin prefijo | 46,220 | Consulta el saldo disponible |
| `reversiontd_cel` | sin prefijo | 23,740 | Aplica la reversa |
| `abono_ref` | sin prefijo | 80 | Aplica el abono |
| `sp_registra_evento` | `bdimnsj` | 3 | Registra el evento en mensajería |

Solo `sp_registra_evento` llega al log con la base escrita por delante. Los otros se invocan sin prefijo y resuelven contra la conexión por omisión del autorizador, que el log no revela. Como varios de esos nombres están replicados en `bdicheq`, `bdicred` e `intercard`, la atribución a una copia concreta sigue abierta.

### El chip domina, pero uno de cada tres cobros sigue siendo manual

| Modo de entrada | Volumen diario | Participación |
|-----------------|---------------|---------------|
| Chip leído con CVV confiable | 1,111,995 | 38.9% |
| Manual | 898,423 | 31.4% |
| Contactless EMV | 562,359 | 19.7% |
| Tarjeta en archivo | 263,883 | 9.2% |
| Fallback | 738 | 0.0% |

Chip y contactless suman 58.6 por ciento. La entrada manual, que incluye comercio electrónico y cargos digitados, sostiene casi un tercio del volumen.

---

## Dónde se valida la criptografía

El autorizador **no calcula** el NIP, ni el CVV, ni el CVV2, ni el criptograma EMV. Los recibe ya resueltos del sistema InterAct, que ejecuta esa validación contra el HSM antes de entregar el mensaje. El autorizador solo lee el resultado en los campos `PINRc`, `CVCRc`, `CVC2Rc`, `ARQCRc` y `CAVVRc`, donde `FF` significa que la validación no aplicaba.

| Campo | Qué valida | Transacciones donde aplicó | Dónde |
|-------|------------|---------------------------|-------|
| `CVCRc` | CVV de banda o chip | 1,674,392 | Punto de venta y cajero |
| `ARQCRc` | Criptograma EMV | 1,674,281 | Punto de venta y cajero |
| `CVC2Rc` | CVV2 impreso | 232,249 | Compra y validación de cuenta |
| `PINRc` | NIP | 75,373 | **Solo cajero** |
| `CAVVRc` | Autenticación 3D Secure | 2,942 | Compra en punto de venta |

Esto verifica la política que InterAct declara en prosa y acota el trabajo pendiente: las 114 validaciones numeradas del autorizador son **todas de negocio**, ninguna criptográfica.

---

## Relación con otros sistemas

| Sistema | Relación | Dirección | Volumen | Evidencia |
|---------|----------|-----------|---------|-----------|
| `informix` | `calls` | `outbound` | 3,503,441 invocaciones diarias | `source/logs/eglobal.authorizer.20261103` |
| `interact` | `calls` | `inbound` | Pareado uno a uno | `source/logs/authorizerj.eglobal.20261104` |

Ambas declaradas en los dos lados conforme a la Regla B10. El seed hacia Informix vive en `digital-brain/seeds/informix-seed.json` conforme a la Regla B11.

---

## Tratamiento de datos sensibles

El log crudo contiene número de tarjeta completo, datos de banda, nombre del tarjetahabiente y saldos, todo en claro. Eso impone dos reglas que ningún generador de este sistema puede saltarse.

1. **Nada de eso sale del log.** El extractor conserva del número de tarjeta únicamente el BIN de seis dígitos y los últimos cuatro, que es lo que PCI-DSS permite para análisis. Nombres y saldos se descartan en la lectura, no después. Los importes se guardan agrupados en bandas, nunca individuales.
2. **El log crudo no se versiona.** Vive bajo `source/`, que está en `.gitignore` del repositorio. Quien reconstruya este brain necesita el log original; quien lea el repositorio no lo recibe.

---

## Pipeline de reconstrucción

```bash
python generators/parse-authorizerj.py      # destila los logs a digital-brain/data/
python digital-brain/build-brain.py --reset # construye el brain
python generators/build-knowledge-base.py   # proyecta los documentos de conocimiento
python digital-brain/brain.py               # verifica
```

El extractor paraleliza por archivo y lee los `.log.gz` en streaming, sin descomprimir a disco. El lote de día completo son 4.1 GB comprimidos, cerca de 50 GB de texto, y se procesa en unos minutos.

El build es idempotente, con o sin `--reset`. Preserva las dependencias y señales sembradas por otros brains (Regla B12) y recalcula únicamente lo propio.

---

## Lotes de evidencia

| Lote | Ventana | Archivos | Transacciones |
|------|---------|----------|---------------|
| `eglobal.authorizer.20261103` | Día completo del 2026-11-03 | 118 | 2,844,993 |
| `authorizerj.eglobal.20261104` | 2026-11-04, 00:02 a 00:22 | 30 | 16,412 |

Cada lote conserva su ventana declarada. Las cifras agregadas del brain suman ambos; las tablas guardan una fila por lote para que nunca se confundan dos observaciones distintas.

Los archivos de un mismo lote son **instancias paralelas**, no rotaciones: el autorizador corre con treinta hilos concurrentes.

---

## Trabajo pendiente

- [ ] Ingerir los 30 archivos `authorizerj_detail_*`, que traen el SQL real contra Informix con su latencia por sentencia. Son otro formato y requieren un extractor propio. Es la evidencia directa de qué tablas toca el autorizador.
- [ ] Dar significado de negocio a los 114 identificadores de validación. El log entrega el número y el orden, no el nombre. Requiere documentación del vendor o sesión con el equipo de tarjetas.
- [ ] Confirmar el significado del código `00005`, que aparece 22,967 veces al día y el diccionario del core solo documenta en dominios ajenos a tarjetas.
- [ ] Confirmar `-243` con el equipo de base de datos y revisar si es contención de bloqueos.
- [ ] Resolver contra qué base resuelven los procedures invocados sin prefijo.
- [ ] Cargar la volumetría en `sp_metrics_daily` del brain de Informix, con fecha de evidencia propia para no mezclarla con la evidencia ESB del 2026-04-24.
- [ ] Evaluar el resto del catálogo ETB. Hoy hay cuatro capacidades valoradas y 257 en `NOT_ASSESSED`.
- [ ] Construir `generators/build-portal.py` si se requiere visualización, nunca HTML escrito a mano.

---

## Seeds Recibidos

| Emisor | Versión | Fecha | Artefacto origen |
|--------|---------|-------|-----------------|
| `informix` | `Informix v1.8.0` | 2026-08-12 | `digital-brain/brain.db::cross_dependencies` |
| `interact` | `InterAct brain v1.0.0` | 2026-11-04 | `digital-brain/seeds/e-global-seed.json` |

## Seeds Emitidos

| Receptor | Archivo | Evidencias |
|----------|---------|-----------|
| `informix` | `digital-brain/seeds/informix-seed.json` | 6 stored procedures con volumetría |

## Registro en el bank-brain

Registrado el 2026-11-04 en la tabla `systems` del bank-brain con el id `e-global`, y en `system_dependencies` con la arista `eglobal-pisa-core` hacia el core. Sustituye en evidencia a `pisa-eglobal-auth`, que venía del seed de agosto sin volumetría.

El federador alcanza este brain por `ATTACH` en modo lectura y lo cuenta entre los cuatro que llevan el catálogo ETB. Su aporte al gate de decommission es concreto: `3.5.6 Switching` figuraba como hueco mientras la consulta leía sólo el brain del core, y la cubre este sistema junto con InterAct.

---

---

*Actualizado 2026-11-04. Brain v1.0.0 sobre un día completo de producción más una ventana de control. Sustituye el registro generado por `bootstrap-from-seeds.py` el 2026-08-12.*

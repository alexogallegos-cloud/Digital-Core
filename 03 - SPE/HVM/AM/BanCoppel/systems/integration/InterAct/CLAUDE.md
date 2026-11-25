# InterAct — Application Modernization Agent
# togaf_type: integration
# togaf_state: baseline
# togaf_system_of: record
# togaf_abb: payment-switching
# bian_domains: ["Card Transaction Switch", "Card Authorization", "Fraud Detection"]

> **Estado:** `[STATE: ACTIVE]` — sistema abierto el 2026-11-04 por **Regla B9**, con brain propio desde el primer día.
> **Evidencia fundacional:** `source/logs/interact.20261104`, 79 archivos de los cinco procesos de la suite.
> **Descubierto al analizar e-global:** los logs llegaron rotulados como del cajero automático. La evidencia de volumen demostró que no lo son.

---

## Qué es este sistema

InterAct es el **front-end ISO 8583 de la plataforma de tarjetas** de BanCoppel. Es el producto que recibe el tráfico de la red de marca, lo valida criptográficamente contra el HSM, se lo entrega al autorizador e-global y arma el mensaje de respuesta que sale de vuelta.

Es software de vendor, versión 031300, instalado en `/pisa/pisabanco/pisa_ftes/syndein/coppel/InterAct`, sobre la misma infraestructura PISA que aloja el core Informix.

### Por qué es un sistema propio y no una capa de e-global

Los logs se recibieron en una carpeta llamada `logs.cfg.20261104_ATMs`, lo que sugería que eran del canal de cajeros. No lo son, y la evidencia es cuantitativa: en la misma ventana de veinte minutos en que el autorizador procesó 16,412 transacciones, InterAct movió 14,922 mensajes. Es tráfico pareado uno a uno con toda la plataforma de tarjetas. El cajero automático, en cambio, representa cerca del uno por ciento de ese volumen. InterAct no es el canal del cajero: es por donde pasa todo.

Tiene versión propia, procesos propios, política propia y logs propios. Por Regla B9 eso basta para abrir el sistema.

---

## La suite y el flujo

| Proceso | Instancias | Papel |
|---------|-----------|-------|
| `intertcps` | 6 | Recibe el tráfico entrante de la red en crudo, sobre TCP |
| `intertcpn` | 1 | Atiende el enlace con la red de marca |
| `interserv` | 1 | Puente entre el enlace nativo y el resto de la suite |
| `intersec` | 1 | Aplica la política de validación criptográfica de NIP, CVV y CVV2 contra el HSM |
| `interapp` | 30 | Recibe la respuesta del autorizador y arma el mensaje ISO de salida |

El flujo de una transacción recorre la suite completa y vuelve:

```
Red de marca  →  intertcps  →  interserv  →  intersec  →  e-global (icard)  →  Informix
                                             (HSM)        (autorizador)        (core)
                                                               ↓
Red de marca  ←──────────────  interapp  ←─────────────────────┘
```

Las treinta instancias de `interapp` corren en paralelo, igual que los treinta hilos del autorizador. El log nombra al autorizador como `icard`.

---

## La política de validación criptográfica

Es el conocimiento de mayor valor que entrega este sistema. El módulo de seguridad escribe su política en prosa, en inglés, cada vez que la aplica. Esto es la matriz de qué se valida, por canal y por tipo de mensaje.

| Canal | Mensaje ISO | Qué valida | Veces en veinte minutos |
|-------|-------------|------------|------------------------|
| Punto de venta | `0200` | CVV obligatorio cuando la tarjeta se desliza o se lee el chip, CVV2 condicional | 14,555 |
| Cajero automático | `0200` | NIP y CVV, ambos obligatorios | 192 |
| Indistinto | `0220`, `0221`, `0420`, `0421` | Nada. Los avisos y reversos no se validan | 108 |
| Indistinto | `0420`, `0421` | Nada | 3 |
| Punto de venta | modo de entrada 80 | Nada. El fallback no ejecuta validaciones | 1 |
| Indistinto | — | La marca del BIN. Si no resuelve, la transacción se invalida | 4 |

### La política se verificó contra el autorizador

La prosa dice qué debería pasar. Los resultados del HSM que recibe el autorizador dicen qué pasó. Cuadran exactamente, sobre la ventana de veinte minutos del 2026-11-04:

| Lo que dice la política | Lo que muestra el autorizador |
|------------------------|------------------------------|
| El NIP se valida en cajero | `PINRc` resuelto en 213 transacciones. Las transacciones de cajero de esa ventana son 217 |
| El CVV se valida con banda o chip | `CVCRc` resuelto en 4,222 transacciones. Las de chip más contactless son 2,602 y 1,620, que suman 4,222 |
| El CVV2 es condicional | `CVC2Rc` resuelto en 2,346, contra 2,820 mensajes que declaran traer CVV2 |

Coincidencia exacta en los dos primeros casos. La política no es documentación aspiracional: es lo que el sistema ejecuta.

### Consecuencia para el entendimiento del autorizador

El autorizador **no calcula** NIP, CVV, CVV2 ni criptograma EMV. Los recibe ya resueltos en los campos `PINRc`, `CVCRc`, `CVC2Rc`, `ARQCRc` y `CAVVRc`, donde el valor `FF` significa que esa validación no aplicaba. Por lo tanto las 114 validaciones numeradas del autorizador son **todas de negocio**: límites, estatus de tarjeta, producto, comercio, giro. Ninguna es criptográfica.

Esto acota el trabajo pendiente de darles nombre: hay que buscar reglas de negocio, no de seguridad.

---

## Hallazgos de riesgo

**El fallback no ejecuta ninguna validación.** Cuando el chip falla y la terminal cae a banda magnética, el modo de entrada 80 pasa sin validación criptográfica. Es el vector clásico de fraude por clonación: se degrada el chip a propósito para evitar el criptograma. En la ventana de InterAct ocurrió una sola vez, pero el brain de e-global, que tiene un día completo, registra **738 transacciones en modo fallback al día**. Conviene confirmar con el equipo de tarjetas si existe un control compensatorio aguas arriba, un límite de monto o un tope de frecuencia para fallback.

**Un código de retorno de cabecera no nulo aparece en cerca del cuatro por ciento de los mensajes.** El valor `504` se observó 4,518 veces contra 102,896 con código `0`. Falta determinar si corresponde a una condición esperada del protocolo o a una degradación. Es la primera pregunta para la sesión con el equipo de la plataforma.

**Dos tokens del campo 63 se buscan y no se encuentran de forma sistemática.** El token `B4` falla 10,891 veces y el `C0` 2,997. El autorizador registra esos mismos ausentes como informativos. Hay que confirmar si la ausencia es normal para el tipo de transacción o si hay comercios que no los están enviando.

---

## Relación con otros sistemas

| Sistema | Relación | Dirección | Evidencia |
|---------|----------|-----------|-----------|
| `e-global` | `calls` | `outbound` | 29,780 mensajes en veinte minutos, pareados con el tráfico del autorizador |

Declarada en ambos lados conforme a la Regla B10. El seed hacia e-global vive en `digital-brain/seeds/e-global-seed.json` y lleva la matriz de políticas como evidencia.

La suite se apoya en un HSM para las operaciones criptográficas. No tiene brain propio y queda como dependencia externa pendiente de documentar.

---

## Tratamiento de datos sensibles

El log contiene mensajes ISO completos, volcados hexadecimales del tráfico de red y el campo 63 con sus tokens. Ahí viaja el número de tarjeta y los datos de banda en claro.

El extractor **no persiste ningún mensaje crudo ni valor de token**. Guarda estructura, catálogos y conteos: qué tokens aparecen, cuántas veces, qué tipos de mensaje, qué política se aplicó. Nada que permita reconstruir una tarjeta.

El log crudo vive bajo `source/`, que está en `.gitignore`.

---

## Pipeline de reconstrucción

```bash
python generators/parse-interact.py          # destila los logs a digital-brain/data/
python digital-brain/build-brain.py --reset  # construye el brain
```

---

## Lotes de evidencia

| Lote | Ventana | Archivos | Mensajes | Carpeta de origen |
|------|---------|----------|----------|-------------------|
| `interact.20261104` | 2026-11-04, 00:00 a 00:20 | 79 | 29,780 | `logs.cfg.20261104_ATMs` |

El nombre original de la carpeta se conserva aquí como procedencia. El lote se renombró porque el rótulo original atribuía los logs al canal de cajeros, cosa que la evidencia desmiente.

---

## Trabajo pendiente

- [ ] Conseguir un lote de día completo. Veinte minutos de madrugada no representan el perfil diario, como quedó demostrado en e-global.
- [ ] Determinar qué significa el código de retorno `504` de la cabecera nativa.
- [ ] Confirmar si el fallback sin validación tiene control compensatorio.
- [ ] Dar significado a los 20 tokens del campo 63. Hoy se documentaron 12 por deducción y faltan 8.
- [ ] Obtener documentación del vendor. La versión es 031300 y el instalador vive en la ruta `syndein`.
- [ ] Construir `brain.py` con la interfaz estándar de cinco métodos.
- [ ] Evaluar el resto del catálogo ETB. Hoy hay cuatro capacidades valoradas y 257 en `NOT_ASSESSED`.

---

## Seeds Emitidos

| Receptor | Archivo | Evidencias |
|----------|---------|-----------|
| `e-global` | `digital-brain/seeds/e-global-seed.json` | 6 políticas de validación con canal y tipo de mensaje |

## Registro en el bank-brain

Registrado el 2026-11-04 en la tabla `systems` del bank-brain con el id `interact`, y en `system_dependencies` con la arista `interact-eglobal-iso` hacia el autorizador, declarada por los dos brains.

El federador alcanza este brain por `ATTACH` en modo lectura y lo cuenta entre los cuatro que llevan el catálogo ETB. Junto con e-global es el que cubre `3.5.6 Switching`, que el brain del core marca como no cubierta.

---

---

*Creado 2026-11-04. Brain v1.0.0 construido desde logs de producción de la suite.*

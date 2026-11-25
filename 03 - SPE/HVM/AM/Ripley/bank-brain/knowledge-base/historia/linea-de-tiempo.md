# Estudio Histórico de Banco Ripley — Línea de Tiempo

> Artefacto de R0 del análisis de la situación. Regla B26: todo brain comienza con el estudio histórico de la organización, desde su fundación hasta hoy, porque la historia explica el porqué del código.
> Versión 1.0, 2026-10-27. Fuentes públicas, todas citadas. Nivel declarado por hito.

---

## Por qué este banco nació de una tienda

La secuencia importa más que las fechas. Primero hubo una casa comercial, después un sistema de crédito para vender más ropa, y solo al final un banco. Eso no es anecdótico: significa que el núcleo histórico del negocio financiero es **la cuenta de un cliente que compra a crédito en la tienda**, y que la licencia bancaria llegó a formalizar algo que ya existía y ya tenía sistemas corriendo.

Un core bancario que nace así suele cargar dos cosas: una representación del cliente heredada del retail, y un motor de crédito revolvente que precede a la contabilidad bancaria en lugar de derivarse de ella. Es la misma genealogía de BanCoppel en México, y es la razón por la que este brain se construye con el eje producto puesto en la tarjeta.

---

## Hitos

| Fecha | Hito | Nivel | Fuente |
|-------|------|-------|--------|
| 1956 | Los hermanos Marcelo y Alberto Calderón crean "Calderón y Confecciones", origen del grupo | silver | Sitio de Banco Ripley Perú |
| 1964 | Primera tienda Ripley en el centro de Santiago | silver | Sitio de Banco Ripley Perú |
| 1972-07-25 | Se constituye Inversiones Centro Limitada, sociedad que con el tiempo se convierte en CAR S.A. | silver | Sitio de Banco Ripley, sección de filiales |
| 1976 | Comienza la venta de productos con crédito semiautomático en cada sucursal | silver | Sitio de Banco Ripley Perú |
| 2001-03-30 | Inversiones Centro se transforma en sociedad anónima cerrada | silver | Sitio de Banco Ripley, sección de filiales |
| 2002-05-02 | Resolución N°40 aprueba los estatutos de Banco Ripley como sociedad anónima especial | **gold** | Memoria Banco Ripley 2024 |
| 2002-05-13 | El banco queda autorizado para comenzar actividades | **gold** | Memoria Banco Ripley 2024 |
| 2002-05-17 | Inicio de operaciones comerciales de Banco Ripley | **gold** | Memoria Banco Ripley 2024 |
| 2025-02-20 | Banco Ripley anuncia el cierre de Chek, su cuenta digital | silver | Prensa financiera chilena |
| 2025-05-31 | Chek deja de operar; sus servicios se integran a los demás productos del banco | silver | Prensa financiera chilena |
| 2026-05-04 | Falla operativa que afecta transferencias electrónicas recibidas entre el 30 de abril y el 3 de mayo, con descuentos, reversas, movimientos duplicados y saldos negativos en cuentas corrientes y vista | **gold** con fecha | Comunicado del SERNAC |
| 2026-08-10 | El SERNAC anuncia un Procedimiento Voluntario Colectivo, propuesto por el propio banco, para compensar a los clientes afectados | **gold** con fecha | Comunicado del SERNAC |

---

## Tres cosas que esta historia ya le dice al análisis

**La tarjeta no la emite el banco.** CAR S.A. es la sociedad de apoyo al giro que emite la Tarjeta de Crédito Banco Ripley, y es una persona jurídica distinta con historia propia que arranca en 1972, treinta años antes que el banco. Ontológicamente esto importa: el sistema de registro del producto principal puede no vivir dentro del perímetro del banco. Queda declarado como dependencia cruzada y como pregunta abierta.

**Chek cerró y su funcionalidad se absorbió.** Era una cuenta de provisión de fondos operando bajo la licencia del banco, con transferencias entre usuarios, pagos con código QR, recarga de tarjeta de transporte y pago de cuentas. Cuando un producto se apaga y su funcionalidad se absorbe en otro, lo que queda en los sistemas rara vez es limpio: quedan tablas, rutas de integración y reglas que ya no tienen producto que las justifique. Es la definición de deuda sin propósito, que es uno de los tres tipos de hallazgo de R3.

**El incidente de mayo de 2026 es la mejor evidencia pública que existe sobre la tecnología del banco.** Descuentos, reversas, movimientos duplicados y saldos negativos sobre transferencias recibidas apuntan a la capa de abono y conciliación, no a un canal. Es un hecho con fecha, declarado por el propio banco ante una autoridad, y es el primer insumo real que tiene `dt-service-operations-lead` para R2. No se carga como hallazgo todavía, porque R0 no produce hallazgos; se cataloga como fuente.

---

## Lo que falta de la historia

El estudio está incompleto y conviene decir dónde. No hay todavía fecha de lanzamiento de la Tarjeta Ripley como producto, ni la de la apertura del banco en Perú, ni ninguna decisión tecnológica documentada: ni cuándo se implantó el core actual, ni si hubo reemplazos, ni qué quedó de la plataforma del retail dentro del banco. Esa última ausencia es la más cara, porque es justamente la que explica el porqué del código.

Hay además una discrepancia menor registrada: la Wikipedia en inglés fecha la creación del banco en 2003, contra las fechas oficiales de 2002 de la memoria anual. Gana la memoria.

---

*Artefacto de R0. Regla B26. El asset declara esta regla sin artefacto verificable; esta es la primera instancia.*

# dt-productos — Portafolio de Productos MONEX
> Digital Twin federado de monex-brain

**Pregunta central**: ¿Qué vende MONEX hoy y cómo mueve dinero cada producto? Correlación producto × tipo de pago.

---

## ROL

Mantiene el catálogo vivo de los productos comerciales de MONEX y su correlación con los tipos de pago
y rieles de liquidación. Es conocimiento de empresa (cruza los dos holdings: Grupo Financiero Monex y MNI Holding),
reutilizable por todas las iniciativas del programa Apolo, no solo por el proyecto de pagos.

## PREGUNTAS QUE RESPONDE

1. ¿Cuántos productos comerciales tiene MONEX y en qué familias?
2. ¿Qué producto pertenece a cuál entidad y holding?
3. ¿Qué tipo de pago o liquidación dispara cada producto?
4. ¿Cuál es el blast-radius de migrar un riel — qué familias de producto se ven afectadas?
5. ¿Qué productos NO tocan el motor de pagos (liquidan por Indeval)?

## FUENTES

- `monex-brain.db` tablas `products`, `product_families`, `payment_rails`, `family_rail` — fuente de verdad
- `panorama_data.py` — datos AS-IS recabados por investigación pública (catálogo, rieles, correlación)
- Investigación pública: monex.com.mx, monexglobal.com, HR Ratings 2024, Monex S.A.P.I. 4T24, BMV

## DATOS CLAVE

- **~64 productos** en 17 familias, dos bloques (no-mercados ~43, mercados ~21)
- **12 rieles** de liquidación; correlación en la tabla `family_rail`
- **Hallazgo estructural**: los brazos internacionales (Monex Europe, Monex Global, Tempus) se separaron
  del Grupo Financiero Monex en 2017 y hoy cuelgan de MNI Holding. El alcance del RFP cruza los dos holdings.
- **Señal de scope**: el bloque de inversión (casa de bolsa, fondos, wealth) liquida por Indeval, no por el motor de pagos.

## CONSUMO

La correlación producto × riel es insumo de:
- `dt-motor-pagos/` — blast-radius de migración de rieles
- `projects/payments-modernization/dt/dt-capability-map/` — orden de olas del cutover
- `projects/payments-modernization/dt/dt-cutover-plan/` — riesgo por capability

## PORTAL

El panorama AS-IS / TO-BE / RFP se genera con `generators/build-panorama.py` desde el brain a `portal/panorama.html`.

## ESTADO

`[ACTIVE]` — catálogo poblado desde investigación pública 2026-09-22. Pendiente validación de insider MONEX
(mezcla de volumen por producto, roster completo de fondos, rieles exactos por producto de crédito).

---

*v1.0 · 2026-09-22 · Catálogo inicial desde investigación pública*

# dt-as-is-payments — AS-IS del Motor de Pagos
> Digital Twin del proyecto Payments Modernization

**Pregunta central**: ¿Cuáles son exactamente las capabilities del payments-legacy y cuál es su estado técnico?

---

## ROL

Mapea el sistema de pagos actual (payments-legacy) capability por capability — antes de decidir
qué migra, qué se reescribe y qué se retira.

## PREGUNTAS QUE RESPONDE

1. ¿Qué rieles de pago soporta hoy el motor legacy (SPEI, SWIFT, otros)?
2. ¿Cuáles capabilities tienen STP real y cuáles requieren intervención manual?
3. ¿Qué volúmenes maneja cada capability (transacciones/día, monto promedio)?
4. ¿Qué dependencias tiene el motor con otros sistemas (MuleSoft, FX Engine, Treasury)?
5. ¿Qué deuda técnica tiene el motor legacy según ISO 5055?

## FUENTES

- `source/docs/` — documentación técnica del payments-legacy
- `source/rfp/` — requerimientos del proceso de selección
- `systems/core/payments-legacy/` — brain del sistema origen
- `knowledge-base/capabilities/` — catálogo de capabilities

## ESTADO

`[SCAFFOLD]` — activar cuando lleguen documentos del sistema origen.

---

*v1.0 · 2026-09-22 · Scaffold inicial*

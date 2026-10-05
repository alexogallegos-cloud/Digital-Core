# dt-capability-map — Mapa de Capabilities AS-IS → TO-BE
> Digital Twin del proyecto Payments Modernization

**Pregunta central**: ¿Qué capabilities migran a cuál riel o sistema en el diseño TO-BE?

---

## ROL

Traduce el inventario de capabilities del payments-legacy en decisiones de migración:
qué va al motor nuevo, qué se retira, qué se reescribe desde cero, qué se delega
a un sistema adyacente (MuleSoft, SPEI connector, Treasury).

## PREGUNTAS QUE RESPONDE

1. ¿Cuál es la decisión 7R (Rehost/Replatform/Refactor/Retire) por capability?
2. ¿Qué capabilities son prerequisito de otras (orden de migración)?
3. ¿Qué capabilities requieren parallel-run obligatorio (criticidad regulatoria)?
4. ¿Cuál es el wave plan — qué migra primero, qué espera?
5. ¿Qué gaps (capacidades inexistentes hoy) debe incorporar el motor nuevo?

## FUENTES

- `dt-as-is-payments/` — inventario de capabilities del sistema origen
- `knowledge-base/capabilities/` — catálogo completo
- `knowledge-base/evaluation/` — decisiones de plataforma target

## ESTADO

`[SCAFFOLD]` — activar después de dt-as-is-payments.

---

*v1.0 · 2026-09-22 · Scaffold inicial*

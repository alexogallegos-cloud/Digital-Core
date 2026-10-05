# dt-cutover-plan — Plan de Cutover por Capability
> Digital Twin del proyecto Payments Modernization

**Pregunta central**: ¿Cuál es el plan de cutover capability por capability con parallel-run y rollback?

---

## ROL

Diseña y valida el plan de cutover del payments-legacy al motor nuevo, capability por capability,
asegurando que cada transición tiene parallel-run completado, rollback probado, y aprobación CAB.

## PREGUNTAS QUE RESPONDE

1. ¿En qué orden se migran las capabilities (wave plan)?
2. ¿Cuántos sprints de parallel-run requiere cada capability?
3. ¿Cuál es el criterio de éxito del parallel-run (STP, latencia, equivalencia)?
4. ¿Cuál es el plan de rollback por capability y quién lo aprueba?
5. ¿Qué capabilities tienen dependencias regulatorias que requieren notificación a CNBV/Banxico?

## FUENTES

- `dt-capability-map/` — decisiones 7R y orden de migración
- `dt-as-is-payments/` — SLAs baseline del sistema origen
- `knowledge-base/requirements/` — requisitos de disponibilidad y STP

## ESTADO

`[SCAFFOLD]` — activar después de dt-capability-map y decisión de plataforma.

---

*v1.0 · 2026-09-22 · Scaffold inicial*

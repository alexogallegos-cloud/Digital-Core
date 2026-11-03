# ADR-EB-008 — Cuerpo calloso: puente Change–Run entre hemisferios

> Estado: **APROBADO** · Propuesto: 2026-10-01 · Aprobado: 2026-10-02 · Asset: Enterprise Brain · Digital Core


<!-- PROPAGACION
templates/schema.sql :: CREATE TABLE IF NOT EXISTS transitions
templates/callosum.py :: transitions
-->

---

## Contexto

El brain tiene dos hemisferios: Change the Business (brains de proyecto, en `projects/`) y Run the Business (brains de sistema, en `systems/`). Los dos razonan contra la misma ontología, la definición del negocio (ETB) y su habilitador de TI (IT Operating Model). Sin embargo, el canon v2.0 no definía cómo se comunican entre sí.

Lo que Change decide tiene que llegar a Run: qué se migra, a dónde, cuándo, quién lo operará y qué tiene que estar listo antes. Lo que Run aprende tiene que volver a Change: incidentes, recurrencias, deuda y patrones descubiertos en producción. Sin ese puente, cada hemisferio razona con una mitad de la verdad.

### Evidencia

**Siete brains resolvieron por su cuenta la mitad de ida, con siete contratos incompatibles.**

| Brain | Estructura | Filas | Qué aporta al canon |
|-------|-----------|-------|---------------------|
| bank-brain | `migrations` | 11,391 | `target_sys` y `confidence` por componente |
| Unity | `informix_migration_map` | 20 | `migration_fate` y `migration_status` por dominio |
| Unity | `capability_routing` · `coexistence_rules` | 11 · 9 | Ruta antes y después, mecanismo de switch, parallel run, condición de coexistencia |
| Unity | `capability_prr` | 14 | Gates de readiness: runbook, on-call, SLO, rollback, DRP, PRR |
| Unity · Coppel | `capability_slos` · `slos` | 14 · 5 | Target comprometido y current medido |
| Exodus | `ams_support_proposal` | 8 | Quién opera tras el cutover: AMS-dev o AMS-ops, nivel de cobertura |
| Coppel | `platform_capabilities` | 15 | Plataforma actual y destino por capacidad |
| Banamex | `sevenr_decisions` | 5 | Decisión 7R con encapsulate |
| Liverpool | `components.migration_fate` | 7 valores | 7R por componente |

**La mitad de regreso no existe en ningún brain.** Run sí registra lo que aprende: Informix en `tribal_knowledge`, Banamex en `hallazgos` (178), Liverpool en `ticket_recurrence` (4,833) y AXA en `pain_points` (33). Pero ninguna de esas tablas tiene llave hacia el backlog de un proyecto.

**La ruptura ya está ocurriendo.** Al razonar el puente entre Unity e Informix con el contrato propuesto, sobre datos reales copiados en solo lectura, aparecieron tres rupturas:

1. El patrón de particionamiento de `intercard:movimiento`, descubierto en el incidente productivo del 2026-09-14, toca SPs del dominio D03. Unity está migrando D03 a SmartVista (`in_progress`) y el hallazgo nunca le llegó.
2. Unity marca D01, D02 y D04 como `done` hacia Transact, pero Informix sigue con 5,743 SPs activos en esos dominios. "Done" significa algo distinto en cada hemisferio.
3. Esas tres transiciones cerradas no tienen dueño operativo ni readiness registrada, porque el PRR de Unity está por capability y no por transición. El brain no puede probar que Run estaba listo para heredarlas.

## Decisión

**1. Cada hemisferio declara su lado del puente**, desde su propia perspectiva (Regla B1):

- **Proyecto (Change → Run):** `plateaus`, `transitions`, `readiness_gates` y `slos`.
- **Sistema (Run → Change):** `findings` (con ruteo) y `slos`.
- **Trazabilidad en ambos extremos:** `components.origin_transition_id`, `user_stories.origin_finding_id` y `risks.origin_finding_id`.

**2. El cruce lo razona el enterprise brain**, no se copia. `templates/callosum.py` federa los brains vía ATTACH (ADR-EB-003), en solo lectura, y detecta seis rupturas: C1 a C4 en la dirección Change → Run, y R1 y R2 en la dirección Run → Change (detalle en la Regla B24). Es una función de razonamiento, no una consulta: ningún brain individual puede responderla.

**3. Vocabularios cerrados**, con el valor original del cliente preservado aparte:

- `fate` (7R más encapsulate), original en `fate_source`.
- `severity` (blocker, critical, high, medium, low), original en `severity_source`.
- Estados de transición, de gate y de ruteo.

**4. Plateaus de ArchiMate** como estados de arquitectura (as_is, transition, to_be). Se mapean a `togaf_state`, que el canon ya usa.

**5. El Brain Auditor gana la dimensión D8**, que valida el lado del puente de cada brain. El lado del puente entra a D1 como tablas obligatorias por `brain_type`.

## Alternativas consideradas

| Alternativa | Por qué no |
|-------------|-----------|
| Tabla de puente única en el enterprise brain | Rompe la autonomía de cada brain (B1). El brain de proyecto dejaría de saber qué entrega. |
| Copiar transiciones al brain de Run en cada build | Duplica la verdad y crea deriva entre copias. ATTACH ya resuelve la federación. |
| Seguir con las estructuras propias de cada brain | Siete contratos incompatibles hacen imposible razonar el cruce a nivel cliente. |
| Mantener readiness como columnas, al estilo `capability_prr` | No permite registrar evidencia, aprobador ni fecha por gate. Normalizar en filas cuesta poco. |

## Consecuencias

**Positivas.**
- El brain puede responder dos preguntas que hoy nadie responde: qué sabe Run que Change ignora, y qué dio por terminado Change que Run sigue operando.
- Los cutovers se vuelven auditables por gate.
- El SLO conecta formalmente el compromiso de diseño con la medición en producción.

**Costos.**
- Los brains de proyecto existentes deben exponer `transitions` y `plateaus`. Por la Regla B16 se hace con vistas de compatibilidad sobre sus tablas actuales, sin reescribir pipelines.
- Los brains de sistema deben exponer `findings`.
- Algunas severidades del estate no son mapeables sin juicio humano (por ejemplo, `tribal_knowledge` no tiene severidad). Se registran con `confidence='inferred'` hasta que las valide el SME.

**`[VERIFICADO 2026-11-03]` La validación que este ADR puso como condición nunca se hizo, y el contrato no se cumple.** Se contrastaron las dos tablas contra los 25 campos del contrato canónico `transitions`: `bank-brain.migrations` tiene 9 campos y comparte exactamente uno (`confidence`) sobre 11,391 filas; `exodus.ams_support_proposal` tiene 21 campos y comparte exactamente uno (`id`) sobre 8 filas. Los dos brains que este ADR nombró siguen operando con las estructuras propias que decía venir a unificar.

El ADR **se mantiene en APROBADO** porque el contrato en sí es sano y ya vive en el CORE, pero la condición deja de redactarse como requisito previo y pasa a ser **deuda declarada**: 
- Migrar `bank-brain.migrations` y `exodus.ams_support_proposal` al contrato canónico `transitions`. Sin eso, el razonamiento cross-brain del puente sigue sin poder ejecutarse sobre esos dos.
- Federar SmartVista, Transact, Cobranza y Atlas como brains de Run. Hoy C1 marca 9 transiciones de Unity hacia sistemas sin brain.

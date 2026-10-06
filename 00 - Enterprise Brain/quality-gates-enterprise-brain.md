# Quality Gates — Enterprise Brain
> Versión 2.0 · 2026-10-05 · Digital Core · Accenture México
> Reescrito desde la v1.0. Esa versión tenía tres gates inejecutables, porque consultaban `souls` y `etb_l3`, tablas que el canon retiró. Ver la nota de cambios al final.

---

## Regla que gobierna todos los gates: nivel mínimo de conocimiento

Antes de cualquier criterio específico aplica esta condición, que viene de la Regla B37. **Una decisión de gate no se sostiene sobre conocimiento que todavía puede cambiar.**

| Tipo de decisión | Nivel mínimo exigido |
|------------------|---------------------|
| Decommission (B7), cutover o cierre de transición (B32), gate de readiness en `done`, afirmación de cumplimiento regulatorio | **gold** |
| Planeación, priorización, estimación, hipótesis de impacto | silver, declarado como tal |
| Cualquier salida al cliente | nunca bronze, salvo marcado explícitamente como "por validar" |

Verificación, ejecutable contra cualquier `brain.db`:

```sql
-- Toda afirmación que sostiene una decisión de gate debe ser gold con fuente.
SELECT COUNT(*) AS gold_sin_fuente
FROM knowledge_lineage
WHERE tier = 'gold' AND (source_ref IS NULL OR source_ref = '');
-- Debe ser 0. La dimensión D9 del DT-Validador lo reporta como bloqueante.
```

```sql
-- Regla B40 — ningún sistema se apaga mientras el brain lo sostenga como vigente.
SELECT COUNT(*) AS afirmaciones_vigentes_del_sistema_que_se_apaga
FROM knowledge_lineage
WHERE tier = 'gold' AND valid_to IS NULL AND entity_id LIKE :prefijo_del_sistema;
-- Debe ser 0 antes de cerrar un decommission o un cutover.
```

---

## Gates por fase SDLC

Todas las consultas son ejecutables contra el schema canónico (`templates/schema.sql`, 15 tablas en el CORE).

### DISCOVER

| Gate | Criterio medible | Bloqueante |
|------|-----------------|-----------|
| Schema canónico presente | Las 18 tablas del CORE existen, más la extensión que corresponde por `brain_type` y el lado del puente. Lo verifica D1 | **SÍ** |
| Ontología anclada | `SELECT COUNT(*) FROM ontology_bindings WHERE role='primary'` devuelve exactamente 1 (Reglas B20, B21) | **SÍ** |
| Corpus fuente declarado | `system_info.source_of_truth` no vacío (Regla B31) | **SÍ** si el estado es `active` |
| Estudio histórico iniciado | `knowledge-base/history/` existe con al menos las cinco dimensiones esbozadas (Regla B26) | NO (advertencia) |
| Productos declarados | `SELECT COUNT(*) FROM products` mayor que 0. Sin producto, ningún KPI sabe por qué importa (Regla B27) | NO (advertencia) |
| Vocabulario mínimo | `SELECT COUNT(*) FROM vocabulary WHERE maturity='confirmed'` al menos 50 | NO (advertencia) |

### DESIGN

| Gate | Criterio medible | Bloqueante |
|------|-----------------|-----------|
| Roster canónico de DTs | Los 20 DTs de la Regla B41 existen en `dt/` con su `CLAUDE.md`. Una carpeta sin `CLAUDE.md` no cuenta: no es invocable ni verificable | **SÍ** |
| Cobertura del modelo operativo | `dt/cobertura-dt.md` sin proceso ITOM huérfano. Hoy la cobertura canónica es 38 de 38 | **SÍ** |
| ITOM anclado | `SELECT COUNT(*) FROM itom_layer` mayor que 0 para brains en estado `active` (Regla B23) | **SÍ** si el estado es `active` |
| Almas identificadas | `SELECT COUNT(*) FROM components WHERE is_soul=1` al menos 2. `is_soul` es columna, no tabla | NO (advertencia) |

### BUILD

| Gate | Criterio medible | Bloqueante |
|------|-----------------|-----------|
| business_name coverage | `SELECT COUNT(*) FROM rules WHERE business_name IS NULL OR business_name=''` igual a 0, más detector anti-genérico sin hallazgos (Regla B30) | **SÍ** |
| Clase coverage | `SELECT COUNT(*) FROM rules WHERE clase IS NULL` igual a 0 | **SÍ** |
| Regulación coverage | `SELECT COUNT(*) FROM rules WHERE reg IS NULL` igual a 0. La cadena vacía es válida cuando no aplica regulación; NULL no | **SÍ** |
| Linaje poblado | `SELECT COUNT(*) FROM knowledge_lineage` mayor que 0. Un brain sin linaje no es un brain honesto: es un volcado sin procedencia (Regla B37). `build-brain.py` lo verifica con `assert_lineage()` | **SÍ** |
| Niveles declarados | Ninguna tabla de conocimiento con `tier` inválido. Lo verifica D9 | **SÍ** |
| Trazabilidad a proceso | Conocimiento huérfano sin `process_id` por tabla. Lo verifica D7 (Regla B22) | **SÍ** |
| Cobertura de capabilities | `SELECT CAST(SUM(coverage_status='COVERED') AS REAL)/COUNT(*) FROM capabilities` al menos 0.60. Reemplaza al gate que consultaba `etb_l3` | NO (advertencia) |
| Vigencia declarada | Proporción de `knowledge_lineage` con `valid_from` no nulo, en el conocimiento que se razona en el tiempo (Regla B40) | NO (advertencia) |

### TEST

| Gate | Criterio medible | Bloqueante |
|------|-----------------|-----------|
| DT-Validador PASS | 0 errores y 0 advertencias bloqueantes en las **9 dimensiones**, D1 a D9 | **SÍ, gate de salida** |

### RELEASE

| Gate | Criterio medible | Bloqueante |
|------|-----------------|-----------|
| Nivel mínimo por decisión | Toda afirmación que sostiene un gate de este release es gold con fuente y versión (Regla B37) | **SÍ** |
| Transiciones con dueño en Run | `SELECT COUNT(*) FROM transitions WHERE status IN ('cutover','done') AND (run_owner IS NULL OR run_owner='')` igual a 0 (Regla B32) | **SÍ** |
| Seeds emitidos | Un archivo `digital-brain/seeds/{receptor}-seed.json` por cada sistema con dependencia conocida (Regla B11) | **SÍ** |
| Portal generado | `portal/*.html` producido por `build-portal.py`, nunca editado a mano (Regla P4) | **SÍ** |
| Contrato de `brain.py` | Los 5 métodos obligatorios implementados y devolviendo datos del brain activo (Regla B1). En brains de proyecto, `rules()` devuelve vacío por diseño: esa extensión no tiene la tabla | **SÍ** |
| `brain.db` ignorado | `git check-ignore digital-brain/brain.db` devuelve positivo (Regla P5) | **SÍ** |
| SLOs con KPI | `SELECT COUNT(*) FROM slos WHERE kpi_id IS NULL` reportado. Cada SLO de TI debería declarar el KPI de negocio que habilita (Regla B36) | NO (advertencia) |

### ITERATE y fin de vida

| Gate | Criterio medible | Bloqueante |
|------|-----------------|-----------|
| Archivado con huecos resueltos | Ningún `knowledge_gap` abierto queda sin transferir ni sin `resolution_action` que declare por qué ya no es contestable (Reglas B17 y B44) | **SÍ** |
| Vecinos notificados | Cada brain que lo federa marcó la federación como archivada, y cerró su lado de `cross_dependencies` con `valid_to` en lugar de borrarlo (Reglas B5 y B44) | **SÍ** |
| Historia preservada | El brain archivado sigue respondiendo `snapshot(date)` sobre su periodo de vigencia (Reglas B40 y B44) | **SÍ** |
| Ventana cumplida | Pasó la ventana que fijó el cliente desde el cutover, por defecto doce meses | **SÍ** |

El archivado es decisión de nivel A3 y no baja de ahí por historial (Regla B39): apagar la memoria de un sistema es irreversible.

### OPERATE y OBSERVE

| Gate | Criterio medible | Bloqueante |
|------|-----------------|-----------|
| Frescura frente a la empresa | Latencia bitemporal: diferencia entre `valid_from` y `recorded_at` en `knowledge_lineage`. Es más exacta que la fecha del último build (Reglas B40, B43) | NO (alerta) |
| Frescura del build | `brain_freshness_days` no mayor a 30 cuando hay cambios en `source/` desde el último build | NO (alerta) |
| Hallazgos ruteados | Hallazgo grave abierto que toca una entidad en transición y no llegó al brain de proyecto. Lo verifica D8, código R1 (Regla B24) | **SÍ** |
| Cola de validación atendida | Pendientes de `hitl_queue()` con plazo vencido (Regla B37, operado por `dt-hitl`) | NO (alerta) |

---

## Definition of Done — Enterprise Brain

Los doce identificadores son estables y se referencian en otros documentos. Del 01 al 10 vienen del canon v1.0; el 11 y el 12 se agregaron con las reglas B37, B40 y B41.

- [ ] **DoD-EB-01**: brain.db construido desde pipeline idempotente (`build-brain.py`), no hand-crafted ni editado con INSERT manual fuera del pipeline (Reglas P1, P2).
- [ ] **DoD-EB-02**: 0 reglas con business_name vacío o genérico. Síntesis LLM source-read completada con `enrichment_method='llm_synthesis_source_read'`. Detector anti-genérico corrido y sin hallazgos (Regla B30).
- [ ] **DoD-EB-03**: `clase` clasificada en 100% de reglas, con su distribución documentada.
- [ ] **DoD-EB-04**: `reg` anotada en 100% de reglas. Los componentes sin regulación aplicable llevan cadena vacía, nunca NULL.
- [ ] **DoD-EB-05**: DT-Validador PASS, 0 errores y 0 advertencias bloqueantes en las **9 dimensiones** D1 a D9, incluidas D7 trazabilidad a proceso, D8 puente Change-Run y D9 calidad y linaje.
- [ ] **DoD-EB-06**: Seeds emitidos para todos los sistemas con dependencia conocida, como `seeds/{receptor}-seed.json` (Regla B11).
- [ ] **DoD-EB-07**: Portal HTML generado desde brain.db por `build-portal.py`. Ningún `portal/*.html` editado a mano, confirmable con `git log -- portal/` (Regla P4, ADR-EB-005).
- [ ] **DoD-EB-08**: `brain.py` expone la interfaz estándar de 5 métodos (`coverage`, `components`, `search`, `rules`, `domains`) devolviendo datos reales (Regla B1).
- [ ] **DoD-EB-09**: Cadena de valor recorrible: todo componente traza hasta un proceso, y de ahí hasta un KPI y un producto. Lo que no traza se declara en `knowledge_gaps` (Reglas B22, B27).
- [ ] **DoD-EB-10**: Brain de nivel cliente actualizado con ATTACH del nuevo brain.db y `capabilities_consolidated()` probado. Aplica solo si el cliente tiene brain enterprise.
- [ ] **DoD-EB-11**: `knowledge_lineage` poblada. Toda afirmación declara nivel y fuente; ninguna gold sin `source_ref`; ninguna gold por validación sin `validated_by`; los hechos irrefutables entran gold por origen (Reglas B37, B40).
- [ ] **DoD-EB-12**: Los 20 DTs canónicos existen con su `CLAUDE.md`, y `dt/cobertura-dt.md` no deja ningún proceso del modelo operativo sin dueño (Regla B41).

---

## Gates declarados y todavía no exigibles

Estas reglas forman parte del canon pero **no tienen implementación**, así que exigirlas hoy convertiría este documento en lo que era: una lista de criterios que nada puede verificar. Se declaran aquí para que su ausencia sea visible y deliberada.

| Regla | Gate que exigirá | Qué falta para poder exigirlo |
|-------|-----------------|------------------------------|
| **B39** | Toda acción A2 o A3 se sustenta en gold, y los cuatro tipos irreversibles nunca bajan de A3 | No existe registro de acciones con su nivel de autonomía, su aprobador y su resultado |
| **B42** | Ninguna consulta cruza una frontera sin propósito declarado y autorizado | `brain.py` no tiene parámetro de propósito ni filtro de acceso; `knowledge_lineage` no tiene columna de propósito |
| **B43** | Toda decisión de gate queda trazable a su evidencia y a su resultado | No existe registro de decisiones con opciones descartadas, conocimiento que las sostuvo y desenlace |
| **B40** | Consulta de estado en una fecha dada | `snapshot(date)` no existe en `brain.py` |
| **B45** | Ninguna consulta cruza una frontera sin propósito declarado, y toda decisión se rastrea hasta la respuesta que la motivó | No existe el objeto consulta: ni tabla, ni identificador, ni registro |

---

## Métricas DORA del Brain

| Métrica | Definición para Enterprise Brain | Target |
|---------|----------------------------------|--------|
| Deployment Frequency | Frecuencia de rebuild exitoso con DT-Validador PASS | Semanal o más durante BUILD activo; mensual o más en OPERATE |
| Lead Time | Desde nueva ola de corpus hasta brain.db activo con PASS | 3 días o menos para olas de 500 componentes o menos; una semana o menos por encima de eso |
| Change Failure Rate | Builds que requieren rollback por datos incorrectos | 5% o menos |
| MTTR | Desde detección de brain incorrecto hasta corrección aplicada | 4 horas o menos puntual; un día o menos para rebuild completo |

---

## SLOs canónicos del asset

Los identificadores SLO-EB-01 a 04 son estables. SLO-EB-05 se agrega con la Regla B40.

- **SLO-EB-01**: `brain_freshness_days` no mayor a 30 cuando hay cambios en `source/`.
- **SLO-EB-02**: `business_name_null_pct` igual a 0%.
- **SLO-EB-03**: cobertura de capabilities al menos 60%, medida sobre `capabilities.coverage_status`.
- **SLO-EB-04**: `dt_query_latency_p95` menor a 500 ms.
- **SLO-EB-05**: latencia bitemporal mediana no mayor a 15 días, es decir la diferencia entre cuándo algo fue verdad en la empresa y cuándo el brain lo supo (Reglas B40, B43). Es la medida honesta de frescura, porque un brain reconstruido ayer puede tener conocimiento de hace seis meses.

---

## Checklist del CLAUDE.md de un nuevo deployment

- [ ] Metadata: `togaf_type`, `togaf_state`, `brain_type`, `hemisphere`, `industry`, `industry_sme`.
- [ ] Ontología declarada: `capability_model`, `process_ontology` y `ontology_bindings` con exactamente una primaria.
- [ ] SMEs por fase, con rutas canónicas.
- [ ] Los 20 DTs canónicos, con el estado de cada uno, SCAFFOLD o ACTIVE.
- [ ] Estado actual de la fase del lifecycle.
- [ ] Bloqueantes activos, si los hay.
- [ ] Pipeline canónico de rebuild documentado.
- [ ] `portal/` nunca editado a mano.
- [ ] `brain.db` en `.gitignore` confirmado.
- [ ] `source_of_truth` declarado.

---

## Nota de cambios respecto a la v1.0

La versión anterior quedó inejecutable al evolucionar el canon, y el QA del 2026-10-05 lo documentó. Lo que cambió:

- **Tres gates consultaban tablas retiradas.** El de schema exigía la existencia de dos tablas que el canon ya había retirado. El de almas contaba filas sobre una tabla de almas, cuando la realidad es que `is_soul` es una columna de `components`. El de cobertura ETB contaba sobre una tabla de niveles L3 que hoy es `capabilities`. Los tres se reescribieron contra el schema real y quedaron verificados como ejecutables.
- **El gate de schema listaba las tablas a mano y omitía casi todo el CORE.** Ese fue el mecanismo por el que se desincronizó, así que ahora delega en D1, que es quien tiene la lista canónica y la deriva del DDL.
- **DoD-EB-05 exigía seis dimensiones cuando el validador tiene nueve**, dejando fuera justo D7, D8 y D9. El gate de salida se cumplía sin verificar trazabilidad a proceso, puente Change-Run ni calidad del conocimiento.
- **Faltaba el nivel mínimo de conocimiento por decisión**, que desde B37 gobierna todos los gates y por eso ahora abre el documento.
- **La ruta del generador del portal era `generators/build-portal.py`**, carpeta que no existe en el asset. Se dejó el nombre del script sin prefijo de carpeta, porque la ubicación difiere entre el asset y un brain implementado.
- **El gate de seeds apuntaba a `seeds/manifest.json`**, archivo que la Regla B11 no define. El contrato real es un archivo por receptor.
- **Se agregaron DoD-EB-11 y 12, y SLO-EB-05.** Y se declararon por separado los gates que el canon pide pero nada puede verificar todavía, para que su ausencia sea deliberada y no un olvido.

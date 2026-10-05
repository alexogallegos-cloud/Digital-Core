# Quality Gates — Enterprise Brain
> Versión 1.0 · 2026-09-29 · Digital Core · Accenture México

---

## Gates por Fase SDLC

| Gate | Fase | Criterio medible | Bloqueante |
|------|------|-----------------|-----------|
| Schema canónico presente | DISCOVER | Todas las tablas canónicas existen en brain.db (system_info, components, rules, vocabulary, journeys, souls, etb_l3, cross_dependencies) | SÍ |
| Vocabulario mínimo | DISCOVER | `SELECT COUNT(*) FROM vocabulary WHERE maturity='confirmed' >= 50` | NO (advertencia) |
| Almas identificadas | DESIGN | `SELECT COUNT(*) FROM souls WHERE status='active' >= 2` | NO (advertencia) |
| DT roster definido | DESIGN | CLAUDE.md de cada DT en `dt/` con SMEs declarados | SÍ |
| business_name coverage | BUILD | `SELECT COUNT(*) FROM rules WHERE business_name IS NULL OR business_name='' = 0` | **SÍ — gate bloqueante** |
| Clase coverage | BUILD | `SELECT COUNT(*) FROM rules WHERE clase IS NULL = 0` | SÍ |
| Regulación coverage | BUILD | `SELECT COUNT(*) FROM rules WHERE reg IS NULL = 0` (vacío es válido si no aplica) | SÍ |
| ETB L3 coverage | BUILD | `SELECT COUNT(DISTINCT l3_id) FROM etb_l3 WHERE coverage_status='COVERED' / 261 >= 0.60` | NO (advertencia) |
| DT-Validador PASS | TEST | 0 errores, 0 advertencias bloqueantes — las 9 dimensiones | **SÍ — gate de salida** |
| Seeds emitidos | RELEASE | `digital-brain/seeds/manifest.json` con ≥ 1 receptor por sistema externo conocido | SÍ |
| Portal generado | RELEASE | `portal/index.html` existe y fue generado por `generators/build-portal.py` | SÍ |
| brain.py contrato | RELEASE | 5 métodos obligatorios implementados y retornan datos del brain.db activo | SÍ |
| brain.db en .gitignore | RELEASE | `git check-ignore digital-brain/brain.db` retorna positivo | SÍ |
| Brain freshness | OBSERVE | `brain_freshness_days <= 30` si hay commits en source/ desde el último build | NO (alerta) |

---

## Definition of Done — Enterprise Brain

Adicional a DoD universal §2.2 (13 criterios):

- [ ] **DoD-EB-01**: brain.db construido desde pipeline idempotente (build-brain.py) — no hand-crafted ni editado con INSERT manual fuera del pipeline.
- [ ] **DoD-EB-02**: 0 reglas con business_name vacío o genérico. Síntesis LLM source-read completada con `method='llm_synthesis_source_read'`. Detector anti-genérico corrido y sin hallazgos.
- [ ] **DoD-EB-03**: Clasificación de naturaleza (`clase`) en 100% de reglas. Distribución documentada (NEGOCIO N%, INFRAESTRUCTURA N%, ENSAMBLAJE N%, PRESENTACION N%).
- [ ] **DoD-EB-04**: Regulación anotada (`reg`) en 100% de reglas. Los SPs sin regulación aplicable tienen `reg=''` — no NULL.
- [ ] **DoD-EB-05**: DT-Validador PASS — 0 errores, 0 advertencias bloqueantes en las **9** dimensiones (D1 a D9, incluidas D7 trazabilidad a proceso, D8 puente Change-Run y D9 calidad y linaje).
- [ ] **DoD-EB-06**: Seeds emitidos para todos los sistemas con dependencia conocida. `digital-brain/seeds/manifest.json` actualizado.
- [ ] **DoD-EB-07**: Portal HTML generado desde brain.db por `generators/build-portal.py`. Ningún `portal/*.html` editado a mano. Confirmado con `git log -- portal/` si el portal ya existía.
- [ ] **DoD-EB-08**: `brain.py` expone interfaz estándar de 5 métodos (`coverage`, `components`, `search`, `rules`, `domains`) y todos retornan datos reales del brain.db.
- [ ] **DoD-EB-09**: Taxonomía de negocio del cliente usada como hilo conductor: todos los DTs, reglas y journeys mapeados a nodos de la taxonomía (dominio → subdominio → capacidad).
- [ ] **DoD-EB-10**: bank-brain federado actualizado con ATTACH del nuevo brain.db y `capabilities_consolidated()` probado. (Aplica solo si el proyecto tiene bank-brain.)

---

## Métricas DORA del Brain

| Métrica DORA | Definición para Enterprise Brain | Target |
|-------------|----------------------------------|--------|
| Deployment Frequency | Frecuencia de rebuild exitoso del brain | ≥ semanal durante BUILD activo · ≥ mensual en OPERATE |
| Lead Time | Tiempo desde nueva ola de código fuente hasta brain.db activo con DT-Validador PASS | ≤ 3 días para olas ≤ 500 componentes · ≤ 1 semana para olas > 500 |
| Change Failure Rate | % de builds que requieren rollback por datos incorrectos (business_name erróneos, schema roto) | ≤ 5% |
| MTTR | Tiempo para corregir un brain con datos incorrectos detectados en OBSERVE | ≤ 4 horas para correcciones puntuales · ≤ 1 día para rebuild completo |

---

## SLOs Canónicos del Asset

- **SLO-EB-01**: `brain_freshness_days ≤ 30` cuando hay cambios en `source/` — el brain está al día con el código fuente.
- **SLO-EB-02**: `business_name_null_pct = 0%` — 100% de reglas con nombre de negocio sintetizado.
- **SLO-EB-03**: `etb_coverage_pct ≥ 60%` — al menos 60% de los componentes del sistema tienen ETB L3 asignado.
- **SLO-EB-04**: `dt_query_latency_p95 < 500ms` — el 95% de las consultas de DTs al brain responden en menos de 500ms.

---

## Checklist de Calidad del CLAUDE.md de Nuevo Deployment

Antes de activar un nuevo Enterprise Brain deployment, verificar que su CLAUDE.md de sistema incluye:

- [ ] Metadata TOGAF: `togaf_type`, `togaf_state`, `togaf_abb`, `bian_domains`
- [ ] SMEs por fase (roster explícito con rutas canónicas)
- [ ] DT roster con versión de cada DT
- [ ] Estado actual de la fase SDLC (`[STATE: DISCOVER/DESIGN/BUILD/...]`)
- [ ] Bloqueantes activos (si los hay)
- [ ] Pipeline canónico de rebuild documentado
- [ ] Regla sobre portal/: nunca hand-authored
- [ ] brain.db en .gitignore confirmado

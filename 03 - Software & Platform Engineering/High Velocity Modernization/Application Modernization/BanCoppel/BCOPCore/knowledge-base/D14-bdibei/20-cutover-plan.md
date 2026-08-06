# D14 · Banca Electrónica Institucional (BEI) — Plan de Cutover

> **Componente:** BCOPCore · SPE-AM-001 · RELEASE Phase
> **Base de datos:** bdibei
> **Wave:** Wave 3 · Riesgo: CRÍTICO (batch nómina)
> **Última actualización:** 2026-08-03

---
**SME responsable:**
- SRE & AIOps (coordinación operativa del cutover) ← OWNER de la ejecución
- Core Banking Transformation (diseño del plan y decisiones arquitectónicas)
- Domain Expert — BanCoppel (validación del impacto en operaciones BEI)
- DBA — IBM Informix IDS (cutover de datos, CDC final, read-only legacy)
- QA Lead — Equivalencia Funcional (criterio go/no-go final)
- Industry Banking (impacto regulatorio)
- Cybersecurity (validación de controles de seguridad post-cutover)

> **ADVERTENCIA MÁXIMA:** El cutover del dominio D14-bdibei es el de mayor riesgo empresarial de todo el proyecto BCOPCore. Cualquier error que afecte el batch de nómina implica que empleados de empresas clientes de BanCoppel no recibirán su pago. Este plan es mandatorio — no hay shortcuts.
---

## RESTRICCIÓN CRÍTICA — VENTANA DE CUTOVER

### El cutover de D14-bdibei ESTÁ PROHIBIDO en los siguientes días:

```
╔═══════════════════════════════════════════════════════════════╗
║  DÍAS PROHIBIDOS PARA CUTOVER — CICLO QUINCENAL ACTIVO        ║
║                                                               ║
║  QUINCENA 1:   Días  1  –  3  de cada mes                    ║
║  QUINCENA 2:   Días 15  – 18  de cada mes                    ║
║                                                               ║
║  Razón: el batch de nómina se ejecuta en esos días.           ║
║  Un fallo en el cutover durante ciclo activo deja a           ║
║  empleados de empresas clientes SIN PAGO DE NÓMINA.           ║
║                                                               ║
║  Esto generaría reclamaciones CONDUSEF masivas y              ║
║  podría comprometer la licencia operativa de BanCoppel.        ║
╚═══════════════════════════════════════════════════════════════╝
```

### Ventana autorizada para cutover

| Días del mes | Estado |
|-------------|--------|
| Días 1–3 | PROHIBIDO — quincena 1 activa |
| Días 4 | Buffer post-quincena — PROHIBIDO (riesgo de retardos) |
| **Días 5–13** | **AUTORIZADO** — ventana segura primera quincena |
| Días 14 | Buffer pre-quincena — PROHIBIDO |
| Días 15–18 | PROHIBIDO — quincena 2 activa |
| Días 19 | Buffer post-quincena — PROHIBIDO |
| **Días 20–28** | **AUTORIZADO** — ventana segura segunda quincena |
| Días 29–31 | `[SME-PENDING]` — confirmar si hay cierres de mes que restrinjan |

**Ventana de tiempo dentro del día autorizado:**
- Inicio: 21:00 h CDMX (después de cierre de operaciones BEI del día)
- Fin de ventana de cutover: 05:00 h CDMX (antes de apertura del día siguiente)
- Duración máxima del cutover: 4 horas
- Buffer de rollback: 2 horas (hasta las 05:00 h, última oportunidad de rollback antes del horario BEI)

---

## Pre-requisitos para autorizar el cutover

Los siguientes criterios son TODOS obligatorios (no hay excepciones sin `[BREAK-GLASS]`):

### Técnicos
- [ ] **Golden master verde:** ≥ 99.95% de equivalencia funcional verificada sobre dataset histórico.
- [ ] **Parallel-run completado:** mínimo 15 días de parallel-run, incluyendo al menos UN ciclo quincenal completo de batch de nómina ejecutado exitosamente en el target.
- [ ] **Performance batch:** duración del batch en target ≤ duración en Informix × 1.2, verificada en parallel-run.
- [ ] **Circuit breakers probados:** los 5 códigos ESB de INC-006 han sido probados y se manejan correctamente (test de chaos engineering verde).
- [ ] **Rollback plan probado:** el rollback al Informix legacy ha sido ejecutado exitosamente en STG (no solo documentado).
- [ ] **CDC drenado:** todos los eventos de CDC de Debezium están aplicados en Aurora antes de cambiar el tráfico (lag = 0).
- [ ] **Seeds de secuencias ajustados:** `setval` ejecutado en Aurora para inicializar secuencias en `MAX(id) + 1`.
- [ ] **IAM y seguridad:** Cybersecurity ha verificado controles de acceso, TLS 1.3, OTP criptográfico funcionando.

### Operacionales
- [ ] **CAB aprobado:** Change Advisory Board de BanCoppel ha aprobado el cambio.
- [ ] **Doble on-call activo:** SRE + DBA Informix en línea durante todo el cutover y las 48 horas siguientes.
- [ ] **Domain Expert disponible:** operaciones BEI de BanCoppel disponibles durante el cutover y el primer día post-cutover.
- [ ] **Canal de comunicación establecido:** war room activo (Teams/Zoom) con todos los owners.
- [ ] **Notificación a empresas piloto:** al menos 2 empresas clientes BEI seleccionadas como piloto están notificadas del mantenimiento.
- [ ] **Plan B confirmado:** si hay rollback, las empresas pueden seguir usando el sistema Informix sin degradación.

### Regulatorios
- [ ] **Ventana confirmada:** la fecha del cutover está en días 5–13 o 20–28 del mes (verificar con Domain Expert BanCoppel que no haya excepción de quincena ese mes).
- [ ] **CNBV notificación** (si aplica): confirmar con Industry Banking si CNBV requiere notificación previa de cambios en sistemas de procesamiento de pagos masivos.

**Aprobaciones finales requeridas:**

| Aprobador | Rol | Firma requerida |
|-----------|-----|----------------|
| QA Lead — Equivalencia Funcional | Soberano de go/no-go técnico | Obligatoria |
| SRE Lead | Owner operativo del cutover | Obligatoria |
| Domain Expert BanCoppel | Owner de negocio BEI | Obligatoria |
| Risk Officer BanCoppel | Aprobación de riesgo empresarial | Obligatoria |
| CAB BanCoppel | Change Advisory Board | Obligatoria |

---

## Runbook del cutover

### T-7 días — Preparación

- [ ] Confirmar ventana de cutover en calendario (días 5–13 o 20–28).
- [ ] Notificar a empresas clientes piloto BEI de la ventana de mantenimiento.
- [ ] Verificar que el parallel-run ha completado ≥ 1 ciclo quincenal.
- [ ] Ejecutar prueba de rollback completa en STG.
- [ ] Validar que todos los pre-requisitos están marcados.

### T-24 horas — Pre-cutover

- [ ] Confirmar que no hay dispersiones pendientes de proceso en Informix.
- [ ] Verificar lag de Debezium CDC: debe ser < 100 mensajes.
- [ ] Confirmar war room activo (DBA + SRE + Domain Expert + Core Banking).
- [ ] Activar monitoreo intensivo en CloudWatch (alarmas en 15 minutos en lugar de 5).
- [ ] Congelar cambios en el target: no deployar nuevas versiones en las 24h previas al cutover.

### T-0 — Inicio del cutover (21:00 h CDMX)

| Paso | Responsable | Duración est. | Verificación |
|------|-------------|---------------|-------------|
| 1. Anuncio en canal war room: "Cutover D14-BEI iniciado" | SRE Lead | 2 min | — |
| 2. Detener la escritura en Informix bdibei (modo read-only) | DBA Informix | 5 min | `UPDATE bdibei.bei_param SET valor='READONLY'` |
| 3. Drenar eventos de Debezium CDC (lag = 0) | DBA + Data Architect | 15 min | Kafka consumer offset = producer offset |
| 4. Snapshot final de datos (count check por tabla) | DBA | 10 min | Reconciliación Aurora vs Informix |
| 5. Ajustar seeds de secuencias en Aurora | DBA PostgreSQL | 5 min | `SELECT setval(...)` por cada secuencia BEI |
| 6. Cambiar routing en API Gateway de Informix → Aurora | SRE Lead | 5 min | Smoke test de endpoint `/bei/v1/health` |
| 7. Smoke test operacional completo | QA Lead | 20 min | Ver checklist de smoke tests abajo |
| 8. Activar EventBridge Scheduler para batch BEI | DevOps | 5 min | Verificar que el job está programado para próxima quincena |
| 9. **Decisión go/no-go** (T+67 min) | QA Lead + SRE + Domain Expert | 5 min | Si GO → paso 10; si NO GO → rollback |
| 10. Anuncio: "Cutover D14-BEI completado exitosamente" | SRE Lead | 2 min | — |

**Duración total del cutover:** ~70 minutos (ventana disponible: 4 horas)

---

## Checklist de smoke tests post-cutover

- [ ] `GET /bei/v1/convenios/{numConvenio}` — responde con datos correctos de un convenio real.
- [ ] `POST /bei/v1/auth/otp/generar` — genera OTP criptográfico (SecureRandom, no LCG).
- [ ] `GET /bei/v1/dispersiones/{folio}` — consulta dispersión histórica devuelve datos correctos.
- [ ] `POST /bei/v1/dispersiones` — crea una dispersión de prueba de $1.00 con empresa piloto.
- [ ] Verificar que EventBridge Scheduler tiene el job de batch de nómina configurado para la próxima quincena.
- [ ] Verificar que la dispersión de prueba aparece en `bei_bitacora` (audit trail activo).
- [ ] Verificar que CloudWatch alarmas están activas (no en estado INSUFFICIENT_DATA).
- [ ] Verificar que el API de Informix bdibei ya no acepta escrituras (solo lectura confirmada).

---

## Plan de rollback

Si cualquiera de los smoke tests falla, o si QA Lead declara NO GO:

### Rollback inmediato (antes de T+120 min)

| Paso | Responsable | Duración |
|------|-------------|----------|
| 1. Anuncio: "ROLLBACK D14-BEI iniciado" | SRE Lead | 1 min |
| 2. Cambiar routing API Gateway de Aurora → Informix | SRE Lead | 5 min |
| 3. Reactivar escritura en Informix bdibei | DBA Informix | 2 min |
| 4. Verificar que operaciones BEI responden desde Informix | QA Lead | 10 min |
| 5. Aplicar en Informix cualquier operación que se procesó en Aurora durante el cutover | DBA | 15 min |
| 6. Anuncio: "ROLLBACK completado — bdibei opera desde Informix" | SRE Lead | 1 min |
| 7. Postmortem del fallo en cutover (en las 48h siguientes) | Equipo completo | — |

**Condición de rollback automático:** si el smoke test de creación de dispersión de prueba falla, rollback sin esperar decisión manual.

### Registro de datos durante la ventana de cutover

Los datos escritos en Aurora durante el cutover (pasos 6-8) que generan dispersiones en el período de smoke test deben ser reconciliados si hay rollback. El SP de reconciliación debe verificar:
- ¿Alguna dispersión de la empresa piloto se procesó en Aurora pero no en Informix?
- Si sí → ejecutar el reverso en Aurora y notificar a la empresa piloto.

---

## Post-cutover — Primeras 48 horas

| Actividad | Frecuencia | Responsable |
|-----------|-----------|-------------|
| Monitoreo intensivo de errores BEI | Cada 15 minutos | SRE on-call |
| Verificación de lag CDC (ya en modo read → solo auditoría) | Hora | DBA |
| Chequeo de dispersiones pendientes (0 al final del día) | Fin del día hábil | Domain Expert |
| Verificación de integridad de datos Aurora vs Informix | Diario | Data Architect |
| Comunicación de estado a empresas piloto | Diario | Domain Expert BanCoppel |

---

## Primera quincena post-cutover — Gate crítico

El primer ciclo de batch de nómina después del cutover es el **test real de producción más importante del dominio BEI**. Debe monitorearse con intensidad máxima:

| Monitoreo | Herramienta | Umbral de alerta |
|-----------|------------|-----------------|
| Inicio del batch (EventBridge dispara el job) | CloudWatch Events | Si el job no inicia en ±5 min del horario → P1 |
| Progreso del batch (% de beneficiarios procesados) | Step Functions + CloudWatch | Si el progreso se detiene > 10 min → P1 |
| Errores ESB durante el batch | CloudWatch alarms | Si hay error 4394 → P1 inmediato |
| Completitud final del batch | Reporte de `BatchNominaService` | Si < 99.9% de beneficiarios OK → P1 |
| Confirmaciones SPEI recibidas | D08 SPEIService | Si hay dispersiones interbancarias sin confirmar → P2 |

**Coordinación especial para la primera quincena:**
- SRE Lead disponible durante toda la ventana del batch (aunque sea nocturno).
- Domain Expert BanCoppel disponible al día siguiente para confirmar que las empresas piloto recibieron la nómina correctamente.
- Teléfono de emergencia del DBA Informix activo en caso de necesitar comparar datos con el legacy.

---

## Período de coexistencia y decommission

| Período | Estado del legacy Informix | Estado del target Aurora |
|---------|--------------------------|------------------------|
| Día 0 (cutover) hasta mes 6 | Read-only — solo para auditoría | Activo — toda operación |
| Mes 6 | `[STATE: DEPRECATED]` | Activo + observado |
| Mes 12 (si no hay issues) | `[STATE: SUNSET]` inicio | Activo + estable |
| Mes 12+ | Cierre de auditoría CNBV | Activo |
| Mes 18 (si CNBV sign-off) | Apagado del dominio en Informix | Único activo |

---
*Generado por: SRE & AIOps + Core Banking Transformation + DT-Riesgos · 2026-08-03 · Fuente: INC-006, sp-specs-bdibei.md, migration-risk-register.md, patrón operativo batch quincenal BEI*

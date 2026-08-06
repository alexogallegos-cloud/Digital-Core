# D13 · Transferencias Electrónicas de Fondos (TEF) — Plan de Cutover

> **Componente:** BCOPCore · SPE-AM-001 · Etapa 5 — Release
> **Base de datos:** `bditef`
> **Wave:** Wave 3 · Riesgo: ALTO
> **Última actualización:** 2026-08-03

---
**SME responsable:**
- SME — Core Banking Transformation (estrategia de cutover)
- SME — SRE & AIOps (operabilidad y rollback)
- Domain Expert — BanCoppel (aprobación de ventana y go/no-go)
- SME Regulatorio — CNBV (obligaciones regulatorias durante la transición)

> Este plan es un borrador de alto nivel. Debe refinarse en Etapa 5 con la participación del Domain Expert BanCoppel y el equipo de operaciones. Todas las ventanas horarias son `[SME-PENDING]`.
---

## Restricciones de cutover del dominio TEF

El dominio TEF es de **altísima criticidad** por las siguientes razones:

1. **Ventana CECOBAN:** El ciclo de cámara tiene horarios estrictos. El cutover no puede ocurrir durante un ciclo de procesamiento activo.
2. **Coordinación con `bdicheq`:** Los SPs `cargo_cta` y `abono_cta` dependen de `bdicheq`. El cutover debe ser simultáneo o coordinado con el dominio D[X] Cheques.
3. **Regulatorio:** Cualquier interrupción en la capacidad de procesar transferencias TEF durante días hábiles puede implicar incumplimiento regulatorio (CNBV).
4. **Sin rollback parcial:** Una vez que los archivos CECOBAN del día han sido enviados desde el sistema target, no se puede hacer rollback parcial sin coordinar con CECOBAN.

---

## Ventana recomendada para cutover

| Criterio | Valor |
|----------|-------|
| Tipo de día | Viernes o víspera de feriado bancario prolongado (mínimo 3 días) |
| Hora de inicio | Después del último ciclo de cámara CECOBAN del día (`[SME-PENDING]` estimado 20:00 hrs) |
| Duración máxima de la ventana | `[SME-PENDING]` — estimado 8 horas |
| Fecha tentativa | `[SME-PENDING]` — coordinación con BanCoppel y CECOBAN |

---

## Fases del cutover

### Fase 0 — Pre-cutover (T-7 días)

| Tarea | Responsable | Criterio de completitud |
|-------|-------------|------------------------|
| Migración de datos maestros (Categoría A) completada | DBA IBM Informix + Data Architect | Validación de integridad aprobada |
| Golden master tests TC-D13-001 a TC-D13-020 pasando | QA Lead | 100% |
| Equivalencia financiera TC-D13-EQ-001 a TC-D13-EQ-005 confirmada | QA Lead | Cero diferencia en centavos |
| `TransferenciasService` desplegado en AWS (pre-producción) | DevOps | Smoke tests pasando |
| Formato de archivos CECOBAN certificado | Architect Target + CECOBAN | Confirmación por escrito de CECOBAN |
| Circuit breaker y observabilidad configurados | SRE | Alertas activas en CloudWatch |
| Credenciales SFTP CECOBAN migradas a Secrets Manager | SME Cybersecurity | Validación con SFTP de prueba |
| Comunicación a CECOBAN de la fecha de cutover | Domain Expert BanCoppel | Acuse de recibo de CECOBAN |

### Fase 1 — Congelamiento del sistema legacy (T-0, 20:00 hrs)

| Tarea | Responsable | Duración estimada |
|-------|-------------|------------------|
| Confirmar que no hay ciclos de cámara CECOBAN activos | Operaciones BanCoppel | 5 min |
| Congelar entrada de nuevas transferencias en el canal | ESB Owner | 5 min |
| Esperar vaciado de cola del ESB | SRE | `[SME-PENDING]` — estimado 15 min |
| Ejecutar `sp_tef_moverregistroshist` final en Informix | DBA IBM Informix | `[DATO-REQUERIDO]` |
| Snapshot final de `tef_operaciones` (datos activos Categoría C) | DBA IBM Informix | `[DATO-REQUERIDO]` |

### Fase 2 — Migración de datos activos (T+30 min)

| Tarea | Responsable | Duración estimada |
|-------|-------------|------------------|
| Exportar datos activos de `tef_operaciones` | DBA IBM Informix | `[DATO-REQUERIDO]` |
| Cargar datos activos en Aurora PostgreSQL | Data Architect | `[DATO-REQUERIDO]` |
| Validar integridad: conteo de registros + suma de importes | Data Architect | 30 min |
| Confirmar que `cce_param` y datos maestros están correctos | DBA IBM Informix | 15 min |

### Fase 3 — Activación del target (T+2 hrs)

| Tarea | Responsable | Duración estimada |
|-------|-------------|------------------|
| Activar `TransferenciasService` en AWS ECS | DevOps | 10 min |
| Activar AWS Transfer Family (SFTP CECOBAN) | DevOps | 10 min |
| Ejecutar smoke tests de `TransferenciasService` | QA Lead | 15 min |
| Redirigir ESB al nuevo endpoint de `TransferenciasService` | ESB Owner | 15 min |
| Ejecutar transacción de prueba de extremo a extremo | Domain Expert BanCoppel | 30 min |

### Fase 4 — Validación post-cutover (T+3 hrs)

| Tarea | Responsable | Criterio de go |
|-------|-------------|---------------|
| Verificar primer ciclo de cámara CECOBAN en el target | Operaciones + SRE | Archivo generado y enviado sin errores |
| Monitoreo de errores ESB por 2 horas | SRE | Error rate < 0.5% |
| Verificar que `tef_bitacora` está registrando correctamente | QA Lead | Al menos 10 registros creados |
| Confirmar con CECOBAN que los archivos son válidos | Domain Expert BanCoppel | Acuse de recibo de CECOBAN |

---

## Plan de rollback

### Criterios de activación del rollback

| Evento | Acción |
|--------|--------|
| Error en validación de integridad de datos (Fase 2) | Abortar — no activar el target |
| Smoke tests fallando (Fase 3) | Abortar — no redirigir el ESB |
| Error rate > 5% en los primeros 30 minutos (Fase 4) | Activar rollback |
| CECOBAN rechaza el primer archivo generado por el target | Activar rollback inmediato |

### Procedimiento de rollback

1. Redirigir el ESB de vuelta al endpoint legacy de Informix (< 5 minutos).
2. Desactivar `TransferenciasService` en AWS ECS.
3. Notificar a CECOBAN del retorno al sistema anterior.
4. Analizar la causa raíz antes de reprogramar el cutover.

**Tiempo máximo de rollback:** 15 minutos (desde la decisión hasta el sistema legacy operativo).

---

## Go/No-Go — comité de decisión

| Rol | Responsable | Autoridad |
|-----|-------------|-----------|
| Domain Expert BanCoppel | `[SME-PENDING]` | Go/No-Go final |
| Architect Target BCOPCore | Accenture | Go/No-Go técnico |
| SME CNBV | `[SME-PENDING]` | Go/No-Go regulatorio |
| SRE Lead | Accenture | Go/No-Go operabilidad |
| CECOBAN | Externo | Confirmación de formato |

---

## `[SME-PENDING]`

- [ ] Confirmar la fecha tentativa de cutover Wave 3 con BanCoppel.
- [ ] Confirmar el horario del último ciclo de cámara CECOBAN del día de cutover.
- [ ] Confirmar el proceso de notificación a CECOBAN del cambio de sistema.
- [ ] Definir el período exacto de convivencia (cuántos días el sistema legacy permanece en standby post-cutover).
- [ ] Confirmar si el cutover de `bditef` debe ser simultáneo con `bdicheq` o puede ser escalonado.

---
*Generado por análisis de dependencias del dominio + restricciones CECOBAN + estrategia Wave 3 BCOPCore*

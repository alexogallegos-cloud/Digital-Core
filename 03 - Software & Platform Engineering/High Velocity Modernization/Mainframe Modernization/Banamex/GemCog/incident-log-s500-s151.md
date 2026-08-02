# Incident Log — S500 + S151 · Banamex GemCog
> Gemelo Cognitivo · Sistemas Unisys ClearPath MCP
> Requerido por: rollback-plan.md §7 — debe existir antes de Wave 0-A (BC-04 ACL)
> Owner: equipo de operaciones Banamex · SME Mainframe Migration
> Actualizado: 2026-07-21 · v0.1-STUB · sin incidentes de wave registrados

---

## Propósito

Este log registra incidentes en S500 y S151 durante **parallel-run y cutover por wave**. Es pre-requisito del Plan de Rollback (§7): toda decisión de activar rollback debe referenciar un incident ID de este log.

Documenta también incidentes históricos relevantes para el diseño de golden masters de equivalencia.

---

## Incidentes activos

> No hay incidentes activos registrados.

---

## Incidentes históricos relevantes para migración

| ID | Fecha | Sistema | Severidad | Descripción | Impacto observado | Causa raíz |
|----|-------|---------|-----------|-------------|-------------------|------------|
| INC-S151-HIST-001 | pendiente HITL | S151/P680 | DEFECTO-PROD | TRZ-008: MOVE CUENORD TO CUENREC — campo origen/destino invertido | Asientos contables con cuentas intercambiadas | Bug latente — requiere confirmación equipo Banamex |
| INC-S500-HIST-001 | pendiente HITL | S500/P109 | INFORMATIVO | TRZ-007: abort comentado en P109 — no ejecuta ante error GL | Continuación de procesamiento ante condición de error | Requiere confirmación equipo Banamex |

---

## Registro de incidentes Wave 0-A (BC-04 ACL)

> Activar esta sección cuando Wave 0-A entre en parallel-run.

| ID | Fecha/Hora | Severidad | Componente | Descripción | Detectado por | Estado |
|----|-----------|-----------|-----------|-------------|---------------|--------|
| — | — | — | — | Sin incidentes de wave | — | — |

---

## Template de incidente

```
### INC-{S500|S151}-{NNNN}

**ID:** INC-{S500|S151}-{NNNN}
**Fecha/Hora detectado:** YYYY-MM-DD HH:MM (hora Ciudad de México)
**Sistema(s) afectado(s):** S500 | S151 | ambos
**Severidad:** DEFECTO-PROD | CRÍTICO | ALTO | MEDIO | BAJO
**Wave:** 0-A | 0-B | 1 | 2 | 3 | 4 | pre-wave (histórico)
**Componente:** {programa / librería / WFL / DASDL afectado}

**Descripción:**
{Comportamiento observado}

**Impacto:**
- Operativo: {descripción}
- Regulatorio: {CNBV/Banxico/CONDUSEF si aplica}
- Financiero: {estimación si aplica}

**Causa raíz:**
{Causa o [INVESTIGANDO]}

**Evidencia:**
- RN-IDs relacionados: {RN-S500-NNN · RN-S151-NNN}
- Logs: {rutas relevantes}

**Acciones tomadas:**
1. {Acción — fecha/responsable}

**Resolución:**
{Descripción o [ABIERTO]}

**Fecha resolución:** YYYY-MM-DD | [ABIERTO]
**Rollback activado:** SÍ | NO
**Referencia rollback-plan.md §:** {sección si aplica}
**Postmortem requerido:** SÍ | NO
```

---

## Umbrales de escalación

| Condición | Acción |
|-----------|--------|
| Divergencia equivalencia > 0.01% en parallel-run | Escalar a risk officer · documentar como CRÍTICO |
| DEFECTO-PROD confirmado en sistema target | Suspender wave · activar rollback per rollback-plan.md §7 |
| Error en reconciliación contable diaria | Documentar + notificar finance/auditoría interna |
| Incidente afecta reportes CNBV | Documentar + notificar equipo regulatorio (CUB Circular 29/2010) |
| 3 incidentes ALTO sin resolución en una wave | Revisión de gate equivalencia antes de continuar |

---

## Referencia cruzada con migration-risk-register.md

Los incidentes que materializan un riesgo catalogado deben actualizar [migration-risk-register.md](migration-risk-register.md) con el incident ID.

| Incidente | Riesgos relacionados en migration-risk-register.md |
|-----------|-----------------------------------------------------|
| INC-S151-HIST-001 | Riesgos 🔴 DEFECTO-PROD cap-tar (P655) |

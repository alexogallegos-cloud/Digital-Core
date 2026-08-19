# DT: Ops Readiness y Go-Live — Unity R4
> **Digital Twin** · Fuente: RAID v2.0 · SME SRE & AIOps · SME IT Operating Model · SME Core Banking Transformation
> **Versión**: v1.0.0 · 2026-08-16
> **Propósito**: Production Readiness Review por capability, runbooks, on-call model, DRP, hypercare N1-N3, rollback plan y handoff AMS

---

## Principio de Ops Readiness

> Un componente que no tiene runbook, on-call rotation definida, y rollback plan probado **no está listo para producción**. El "último 10%" — observabilidad, runbook, rollback — representa el 50% del valor del go-live para el negocio.

Este DT es el gate final antes del go-live. Cada capability debe pasar la Production Readiness Review (PRR) con evidencia, no con declaraciones.

---

## Production Readiness Review (PRR) — Gate diciembre 2026

### Checklist PRR por capability (debe completarse para todas las 14 antes del go-live)

| Capability | Runbook documentado | On-call asignado | Rollback plan probado | SLO configurado + alertas | PRR aprobado |
|-----------|--------------------|-----------------|-----------------------|--------------------------|-------------|
| CAP-CARD-MANUFACTURING | Pendiente | DATO-REQUERIDO | Pendiente | Pendiente | ❌ |
| CAP-AUTHORIZATION | Pendiente | DATO-REQUERIDO | Pendiente | Pendiente | ❌ |
| CAP-CARD-LIFECYCLE | Pendiente | DATO-REQUERIDO | Pendiente | Pendiente | ❌ |
| CAP-OVERPAYMENT | Pendiente | DATO-REQUERIDO | Pendiente | Pendiente | ❌ |
| CAP-DEFERRED-PURCHASE | N/A (no en scope R4) | — | — | — | N/A |
| CAP-BALANCE-STATEMENT | Pendiente | DATO-REQUERIDO | Pendiente | Pendiente | ❌ |
| CAP-PAYMENT | Pendiente | DATO-REQUERIDO | Pendiente | Pendiente | ❌ |
| CAP-CUSTOMER-PROFILE | Pendiente | DATO-REQUERIDO | Pendiente | Pendiente | ❌ |
| CAP-CHANNEL-SELFSERVICE | Bloqueado (CAT) 🔴 | — | — | — | ❌ Bloqueado |
| CAP-AUTHENTICATION | Pendiente | DATO-REQUERIDO | Pendiente | Pendiente | ❌ |
| CAP-COLLECTIONS-AGING | Pendiente | DATO-REQUERIDO | Pendiente | Pendiente | ❌ |
| CAP-FEE-COMMISSION | Pendiente | DATO-REQUERIDO | Pendiente | Pendiente | ❌ |
| CAP-ACCOUNTING-INTEGRATION | Pendiente | DATO-REQUERIDO | Pendiente | Pendiente | ❌ |
| CAP-ERROR-CATALOG | Pendiente | DATO-REQUERIDO | Pendiente | Pendiente | ❌ |

**Target**: 100% PRR aprobado antes del 15 de diciembre 2026.

---

## Estructura de Runbooks

### Template canónico (cada capability debe tener su runbook)

Cada runbook sigue esta estructura — diseñado para que un ingeniero nuevo pueda operar el sistema bajo presión:

```markdown
# Runbook: [Nombre de Capability]
## Identificación rápida (< 5 minutos)
  - Alertas que activan este runbook
  - Cómo verificar que la capability está afectada
  - Dashboard URL de observabilidad

## Severidad
  - P1 (impacto negocio total): criterios
  - P2 (degradación significativa): criterios
  - P3/P4: criterios

## Acciones reversibles primero (< 10 minutos)
  - Feature flag OFF para la capability afectada
  - Rollback a versión anterior (si aplica)
  - Circuit breaker activation

## Escalación (si las acciones reversibles no resuelven)
  - L1 BanCoppel Ops: [contacto DATO-REQUERIDO]
  - L2 ACN On-call: [contacto DATO-REQUERIDO]
  - L3 Vendor (BPC/Appwhere): [contacto DATO-REQUERIDO]
  - CNBV report (P1 obligatorio): plazo < 2 horas desde detección

## Diagnóstico
  - Queries de verificación en SmartVista
  - Logs a revisar (ubicación, filtros)
  - Tabla de síntoma → causa probable

## Resolución y cierre
  - Pasos de remediación conocidos
  - Cómo validar que la capability está restaurada
  - Qué documentar en el incident log post-resolución
```

> **Regla CNBV**: cualquier incidente P1 que afecte operaciones regulatorias debe reportarse a la CNBV en menos de 2 horas. Los runbooks deben incluir explícitamente este paso.

---

## On-Call Model — Por Periodo

### Periodo 1: Go-Live War Room (Días 1-7, enero 2027)

```
War Room 24/7 presencial o virtual
  │
  ├── ACN Delivery Lead (comandante del war room)
  ├── BPC On-Call (SmartVista — contacto directo, no ticket)
  ├── Appwhere On-Call (APOLO — contacto directo)
  ├── ACN Tech Lead (Apificación + integración)
  ├── BanCoppel Ops Rep (acceso a sistemas producción)
  └── Proveedor CAT On-Call (si CAT en go-live)

Escalación en este periodo: directa a todos los actores sin ticket
Tiempo de respuesta P1: < 15 minutos
```

### Periodo 2: Semanas 2-4 (hypercare intensivo)

| Turno | Responsable | Cobertura |
|-------|------------|-----------|
| Horario hábil | ACN Tech Lead + BanCoppel Ops | Monitoreo activo |
| Fuera de horario | ACN On-Call rotativo | Página solo para P1/P2 |
| Escalación a vendors | ACN → vendor en < 30 min para P1 | Via contacto directo |

### Periodo 3: Meses 2-3 (hypercare estándar)

| Severidad | Tiempo respuesta | On-call primary | Escalación |
|-----------|-----------------|-----------------|-----------|
| P1 | < 30 min | BanCoppel Ops | ACN en < 45 min → Vendor en < 1h |
| P2 | < 1 hora | BanCoppel Ops | ACN en < 2h |
| P3/P4 | Horario hábil | BanCoppel Ops | Next business day |

### Periodo 4: Post-Hypercare (AMS Steady-State)

| Aspecto | Modelo |
|---------|--------|
| Owner principal | BanCoppel Ops (modelo AMS definido por BanCoppel) |
| Soporte L2 vendor | Via ticket estándar con SLA contractual |
| Soporte ACN | DATO-REQUERIDO (¿AMS por ACN o internalizado?) |

---

## DRP — Plan de Recuperación ante Desastres

### Situación actual — RIESGO ACTIVO

**RISK activo**: sin responsable único para el DRP del sistema en producción. El DRP no puede aprobarse sin un owner nombrado.

| Parámetro | Objetivo | Status |
|-----------|---------|--------|
| RTO (Recovery Time Objective) — SmartVista | DATO-REQUERIDO | No definido |
| RPO (Recovery Point Objective) — SmartVista | DATO-REQUERIDO | No definido |
| Owner del DRP | DATO-REQUERIDO | **Sin asignar** 🔴 |
| Prueba del DRP | Antes del go-live | No realizada |

### Escenarios de DRP que deben documentarse

| Escenario | Impacto | Tiempo objetivo de recuperación |
|-----------|---------|--------------------------------|
| Caída de SmartVista SVBO | TDC Digital sin operación | DATO-REQUERIDO |
| Caída de SVIP (gateway) | Todos los canales sin acceso a SmartVista | DATO-REQUERIDO |
| Caída de APOLO | Originación bloqueada | DATO-REQUERIDO |
| Corrupción de datos en SmartVista | Reversión a snapshot previo | DATO-REQUERIDO |
| Falla del datacenter principal | Failover a DR site | DATO-REQUERIDO |
| Compromiso de seguridad PCI-DSS | Aislamiento + notificación PCI + CNBV | < 2 horas notificación |

---

## Rollback Plan — Criterios y Procedimiento

El rollback es la capacidad de volver a CMS/Intercard en caso de falla catastrófica en SmartVista post-go-live.

### Criterios de activación del rollback

| Condición | Umbral | Tiempo de decisión |
|-----------|--------|-------------------|
| Error rate SmartVista | > 5% por más de 15 minutos | Inmediato — war room decide |
| Latencia P99 > threshold | > 10,000ms por más de 10 minutos | Inmediato |
| Pérdida de datos confirmada | Cualquier caso | Inmediato + CNBV |
| Incidente de seguridad PCI | Cualquier breach confirmado | Inmediato + CNBV + Visa |

### Procedimiento de rollback (debe probarse en SIT)

```
1. Activar feature flags para redirigir tráfico de vuelta a CMS/Intercard
2. Verificar que CMS/Intercard acepta tráfico (no fue apagado — DATO-REQUERIDO: ¿cuándo se apaga CMS?)
3. Conciliar transacciones en SmartVista durante el periodo de falla
4. Notificar a CNBV si el rollback afecta reportería
5. War room permanece activo hasta estabilización de CMS/Intercard
6. Postmortem obligatorio en < 5 días hábiles
```

> **Ventana de rollback**: ¿Por cuánto tiempo se mantiene CMS/Intercard operable post-go-live? Si CMS se apaga el día 1, el rollback no es posible. Este es un parámetro crítico que el plan director debe decidir.

---

## Hypercare N1-N3 — Modelo de Soporte

| Nivel | Definición | Quién atiende | SLA |
|-------|-----------|--------------|-----|
| N1 — Soporte básico | Incidentes resueltos con runbook estándar | BanCoppel Ops | P1: 30 min · P2: 1h · P3: NBD |
| N2 — Soporte técnico | Requiere análisis técnico del componente | ACN On-Call | P1: 45 min · P2: 2h |
| N3 — Soporte de vendor | Defecto de plataforma en SmartVista/APOLO | BPC/Appwhere | Según contrato de soporte |

### Handoff a AMS

El handoff de la operación del Producto 4900 al modelo AMS de BanCoppel debe completarse con:

| Artefacto | Estado |
|-----------|--------|
| Runbooks completos (14 capabilities) | Pendiente |
| Training a BanCoppel Ops en SmartVista | Pendiente |
| Dashboard de observabilidad configurado | Pendiente |
| Contactos de escalación de vendors documentados | Parcial |
| Contratos de soporte L3 con BPC y Appwhere | DATO-REQUERIDO |
| Modelo AMS post-hypercare definido | DATO-REQUERIDO |

---

## Gate Go/No-Go — Diciembre 2026

Este es el checklist final que el Go/No-Go Committee debe revisar:

| Gate | Criterio | Status |
|------|---------|--------|
| SIT exitoso | ≥ 95% casos críticos pasando, 0 defectos críticos abiertos | ❌ No iniciado |
| UAT firmado | Sign-off BanCoppel PO por capability | ❌ No iniciado |
| PCI-DSS | RoC firmado por QSA | ❌ No iniciado |
| CNBV | Notificación Art. 76 LIC enviada y (si aplica) autorizada | ❌ Pendiente |
| SLOs configurados | 100% capabilities con alertas activas | ❌ No iniciado |
| Runbooks completos | 100% capabilities | ❌ No iniciado |
| On-call definido | War room día 1 con todos los vendors | ❌ No iniciado |
| DRP probado | ≥ 1 simulacro completo | ❌ No iniciado |
| Rollback probado | ≥ 1 simulacro en SIT/STG | ❌ No iniciado |
| CAT contratado | Proveedor firmado + en SIT | ❌ Bloqueado |
| BYU0039 cerrado | Dictamen BPC formal | ❌ Abierto |
| Maquiladores certificados | ≥ 1 maquilador (GID/Forza/TGS) con layout certificado | ❌ No iniciado |
| Capacitación completada | CAT, SIWEB, Cobranza, TI Ops | ❌ No iniciado |

---

## DATO-REQUERIDO — Información crítica faltante

1. Owner del DRP nombrado formalmente
2. RTO/RPO formal del Producto 4900 (requerimiento CNBV)
3. ¿Cuándo se apaga CMS/Intercard? ¿Cuánto tiempo se mantiene operable post-go-live?
4. Modelo AMS post-hypercare: ¿BanCoppel internaliza o contrata AMS con ACN?
5. Contratos de soporte L3 con BPC y Appwhere (SLA, contactos, tiempos de respuesta)
6. Contactos de on-call de BPC y Appwhere para el war room día 1
7. Duración formal del periodo de hypercare (¿90 días? ¿6 meses?)
8. Owner de la decisión de rollback (¿CTO? ¿PMO? ¿war room colectivo?)

---

*Creado: 2026-08-16 — Digital Twin Ops Readiness y Go-Live Unity R4 v1.0.0*

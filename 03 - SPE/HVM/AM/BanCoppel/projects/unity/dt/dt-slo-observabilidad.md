# DT: SLOs y Observabilidad — Unity R4
> **Digital Twin** · Fuente: RAID v2.0 · SME SRE & AIOps · SME Core Banking Transformation
> **Versión**: v1.0.0 · 2026-08-16
> **Propósito**: SLIs/SLOs por componente, criterios cuantitativos de cutover, stack de observabilidad y baseline de comparación Informix vs. SmartVista

---

## Principio Guía

Un programa que no define SLOs antes del go-live no tiene criterios objetivos de éxito ni de rollback. Los SLOs de este DT son los **criterios de entrada a producción** — si no se cumplen en el periodo de estabilización post-SIT, no hay go-live.

---

## SLOs por Componente — Propuesta

### SmartVista (BPC) — Core TDC

| SLI | SLO objetivo | Ventana de medición | Baseline Informix (referencia) |
|-----|-------------|--------------------|-----------------------------|
| Disponibilidad del servicio SVIP | ≥ 99.9% | Mensual | DATO-REQUERIDO |
| Latencia P95 — Autorización | ≤ 800ms | Ventana de 5 min | DATO-REQUERIDO |
| Latencia P99 — Autorización | ≤ 2,000ms | Ventana de 5 min | DATO-REQUERIDO |
| Error rate — Autorizaciones | ≤ 0.1% | Diario | DATO-REQUERIDO |
| TPS pico soportado | ≥ DATO-REQUERIDO | Hora pico | DATO-REQUERIDO |

### APOLO (Appwhere) — Originación Digital

| SLI | SLO objetivo | Ventana | Nota |
|-----|-------------|---------|------|
| Disponibilidad APOLO API | ≥ 99.5% | Mensual | — |
| Latencia P95 — Onboarding | ≤ 5,000ms | Ventana de 5 min | Hoy: 9,000ms en PROD — **fuera de SLO** |
| Latencia P95 — Consulta saldo | ≤ 3,000ms | Ventana de 5 min | Hoy: 9,000ms en PROD — **fuera de SLO** |
| Latencia QA (base) | ≤ 5,000ms | — | Hoy: 30,000ms — **muy fuera** |
| Tasa de abandono por timeout | ≤ 2% | Diario | — |

> **Acción urgente**: Appwhere debe comprometer SLA de latencia y fecha de corrección antes de SIT. Sin mejora de latencia, APOLO no pasa el criterio de cutover.

### App / AppMovil — Canal Digital

| SLI | SLO objetivo | Ventana |
|-----|-------------|---------|
| Disponibilidad App (funciones TDC) | ≥ 99.5% | Mensual |
| Latencia P95 — Consulta saldo TDC | ≤ 3,000ms | Ventana de 5 min |
| Tasa de error (crashes + API errors) | ≤ 0.5% | Diario |
| Cobertura funcional TDC respecto a Crédito Coppel | ≥ 95% | Pre-go-live |

### CAT — Contact Center (bloqueado)

Los SLOs de CAT no pueden definirse hasta que el proveedor sea contratado (RISK-001 abierto). Los parámetros esperados:

| SLI | SLO esperado |
|-----|-------------|
| Disponibilidad IVR | ≥ 99.9% |
| Latencia consulta saldo en IVR | ≤ 3,000ms |
| Tasa de autenticación exitosa (ANI + DTMF + OTP) | ≥ 98% |

> DATO-REQUERIDO: SLOs formales post-contratación del proveedor CAT.

### SIWEB — Sucursales

| SLI | SLO objetivo |
|-----|-------------|
| Disponibilidad SIWEB (funciones TDC) | ≥ 99.5% |
| Latencia P95 — Operaciones TDC en sucursal | ≤ 5,000ms |

---

## Criterios Cuantitativos de Cutover

Para que el Go/No-Go Committee apruebe el go-live en diciembre 2026, **todos** los siguientes criterios deben cumplirse simultáneamente:

| Criterio | Umbral mínimo | Fuente de evidencia |
|----------|--------------|---------------------|
| Equivalencia funcional SmartVista vs. caso de prueba | ≥ 99.95% de casos SIT pasando | Reporte SIT — dt-sit-uat |
| Latencia P95 autorización en ambiente pre-prod | ≤ 800ms | Dashboard observabilidad |
| Error rate en SIT ≤ threshold | ≤ 0.5% defectos críticos abiertos | Herramienta de gestión de defectos |
| APOLO latencia P95 corregida | ≤ 5,000ms | Prueba de carga pre-go-live |
| Cobertura de observabilidad (componentes con alertas configuradas) | ≥ 100% componentes críticos | Stack de monitoreo |
| Runbooks operativos entregados | 100% de componentes | dt-ops-readiness |
| Certificación PCI-DSS SmartVista | Aprobada | dt-compliance |
| CAT contratado y en SIT | Sí | dt-vendors |
| BYU0039 cerrado o workaround aceptado | Sí | dt-vendors |

---

## Stack de Observabilidad

### Estado actual

El stack de monitoreo para Unity R4 **no está definido formalmente**. Este es un gap de delivery que debe cerrarse antes de SIT.

| Componente | Herramienta de monitoreo | Status |
|-----------|------------------------|--------|
| SmartVista (SVBO, SVFE, SVIP) | DATO-REQUERIDO | No definido |
| APOLO | DATO-REQUERIDO | No definido |
| App / AppMovil | DATO-REQUERIDO (Firebase? AppDynamics?) | No definido |
| CAT | DATO-REQUERIDO (depende del proveedor) | Bloqueado |
| SIWEB | DATO-REQUERIDO | No definido |
| Apificación (middleware) | DATO-REQUERIDO | No definido |
| Infraestructura (cloud/on-prem) | DATO-REQUERIDO | No definido |

> Referencia: BanCoppel usa Dynatrace para KOF (proyecto activo en SME SRE). Evaluar si aplica para Unity R4.

### Señales mínimas requeridas (Production Readiness)

Antes del go-live, cada componente crítico debe tener al menos:

| Señal | Descripción |
|-------|-------------|
| Health check endpoint | Responde en <5s; retorna status UP/DOWN |
| Availability metric | Medida por monitoreo externo (synthetic monitoring) |
| Latency histogram P50/P95/P99 | Por operación crítica |
| Error rate counter | Por tipo de error (4xx, 5xx, timeout, business) |
| Alert de threshold | Dispara si latencia P95 > 2x SLO por >5 min |
| Dashboard consolidado | Vista de todos los componentes en un solo panel |
| Runbook de incidente vinculado | Cada alert tiene runbook asociado |

---

## Business Observability — KPIs de Negocio

Además de los SLIs técnicos, el negocio necesita monitorear:

| KPI | Descripción | Frecuencia | Umbral alerta |
|-----|-------------|-----------|--------------|
| Tasa de autorización TDC | % de autorizaciones aprobadas vs. solicitadas | Tiempo real | < 85% dispara P2 |
| Volumen de transacciones TDC por hora | TPS promedio y pico | Por hora | > 2x promedio = alerta |
| Tasa de activación TDC Digital | Tarjetas activadas / emitidas | Diario | < 60% a los 7 días |
| Pagos procesados correctamente | % de pagos con confirmación exitosa | Tiempo real | < 99% dispara P2 |
| Onboarding completados (APOLO) | % de solicitudes completadas vs. iniciadas | Diario | < 70% dispara revisión |
| Incidentes regulatorios | Operaciones con falla que requieren reporte CNBV | Tiempo real | Cualquier evento = P1 |

---

## Observabilidad para el Periodo de Hypercare (90 días)

Durante los primeros 90 días, el umbral de alerta es más estricto:

| Periodo | Umbral error rate | Umbral latencia | Respuesta |
|---------|-----------------|-----------------|-----------|
| Días 1-7 (war room) | > 0.01% | > 500ms P95 | Escala inmediata |
| Semana 2-4 | > 0.05% | > 700ms P95 | Escala en <30 min |
| Mes 2-3 | > 0.1% | > 800ms P95 | Escala en <1h |
| Post-hypercare (AMS) | > 0.5% (SLO normal) | > 800ms P95 | SLA de incidente |

---

## Integración con bank-brain

El brain.db de Unity debe conectarse a las métricas de observabilidad para responder preguntas como:

| Pregunta | Fuente |
|----------|--------|
| ¿Qué capability tiene mayor error rate hoy? | dashboard → brain::delivery_state |
| ¿Cuántos SLOs está violando SmartVista en este momento? | observabilidad → brain::program_capabilities |
| ¿Qué runbook aplica para este alert? | brain::vocabulary + dt-ops-readiness |

---

## DATO-REQUERIDO — Información crítica faltante

1. Stack de monitoreo seleccionado para cada componente (¿Dynatrace? ¿otro?)
2. Baseline de latencia actual de Informix para los SPs equivalentes (benchmark de comparación)
3. TPS pico histórico del producto de Crédito Coppel en Informix (dimensionamiento SmartVista)
4. SLA de latencia que Appwhere compromete para APOLO post-correcciones
5. SLOs formales del proveedor CAT (bloqueados hasta contratación)
6. Herramienta de alerta y dashboard seleccionada (¿integrada con ITSM de BanCoppel?)
7. Owner de observabilidad en producción (BanCoppel Ops vs. ACN durante hypercare)
8. RTO/RPO formal del Producto 4900 (requerimiento regulatorio CNBV)

---

*Creado: 2026-08-16 — Digital Twin SLOs y Observabilidad Unity R4 v1.0.0*

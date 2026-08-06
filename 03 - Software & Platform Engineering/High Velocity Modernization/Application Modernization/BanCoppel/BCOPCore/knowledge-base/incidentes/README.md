# Registro de Incidentes — BCOPCore · BanCoppel Application Modernization

> **Fuente de verdad:** este directorio contiene el análisis estructurado de todos los incidentes observados en producción durante el período de captura de logs del proyecto. Los incidentes se derivan directamente de los logs ESB (`errores_bus_*.txt`, `transacciones_bus_*.txt`) y del análisis de código fuente.
>
> **Complemento:** cada INC tiene su página de diagnóstico visual en `portal/incidents/` y su runbook operacional en `knowledge-base/D{NN}-{db}/21-observability-runbook.md`.

---

## Inventario completo de incidentes

### Captura 2026-04-24 — Logs ESB (ventana completa 24 horas)

| ID | Slug | Severidad | Dominio | SP / Sistema | Estado |
|----|------|-----------|---------|--------------|--------|
| [INC-20260424-001](INC-20260424-001-appriza-loop-sin-circuitbreaker.md) | appriza-loop | N3 | D05 bdisac | sp_app_confirmpayment | ACTIVO |
| [INC-20260424-002](INC-20260424-002-cobranza-cv-char5-defecto-produccion.md) | cobranza-cv CHAR5 | N4 | D11 bdicobranza | sp_obtener_datos_cv_web | ACTIVO |
| [INC-20260424-003](INC-20260424-003-defecto-prod-p655-bdicnweb.md) | defecto-prod P655 | **N5** | D01 bdicnweb | P655-R001/R002 | BLOQUEANTE |
| [INC-20260424-004/005/006](INC-20260424-004-005-006-esb-codigos-no-documentados.md) | ESB códigos no doc. | N3 | D08/D13/D14 | ESB transversal | ACTIVO |
| [INC-20260424-007](INC-20260424-007-huellas-biometricas-stale.md) | huellas-stale | N2 | D02 bdinteg | sp_consulta_huella_actual | ACTIVO |
| [INC-20260424-008](INC-20260424-008-aceptporta-sftp-auth-failure.md) | ACEPTPORTA SFTP | N2 | D02 bdinteg | sp_inserta_reg_expediente | ACTIVO |

**Evidencia cuantitativa 2026-04-24 (logs ESB — 24 archivos, ventana completa):**

| Sistema / Código | Errores/día | Observación |
|-----------------|------------|-------------|
| ACEPTPORTA (3381) | 3,244 | 100% auth failure — INC-008 |
| Código 4395 (sin desc.) | 3,980 | Mayor en Huellas442 (1,440) — INC-007 |
| IBM MQ 4394 | 2,452 | Pico 19:00 CST (1,629/hr) — INC-004/005/006 |
| sp_obtener_datos_cv_web | ~48,390 | 97.37% falla (defecto CHAR5) — INC-002 |
| APPRIZA/REM_AUT_APZ | 447 | Pico 19:00 CST (297) — INC-001 |

---

### Captura 2026-07-31 — Logs Informix (ventana 11:00–14:00 CST)

| ID | Slug | Severidad | Dominio | SP / Sistema | Estado |
|----|------|-----------|---------|--------------|--------|
| [INC-20260731](INC-20260731-lock-cascade-bdicred-reconciliacion.md) | lock-cascade bdicred | CRÍTICA | D03/D16 bdicred/bditarjeta | sp_concreing_conciliacionautomatica | ANALIZADO |

**Síntesis:** 22,089 errores -255 (lock timeout) en 3 horas. 8.5M locks en evento catastrófico 11:28–11:33 CST. Causa: transacción monolítica sin COMMIT en reconciliación automática de tarjetas.

---

### Captura 2026-08-01 — Logs Informix (ventana 3 horas)

| ID | Slug | Severidad | Dominio | SP / Sistema | Estado |
|----|------|-----------|---------|--------------|--------|
| [INC-20260801](INC-20260801-lock-cascade-bdicred.md) | lock-cascade scoring | CRÍTICA | D06/D03 bdisolic/bdicred | califica_scoring_cjunk | ANALIZADO |

**Síntesis:** 8,238 errores -255. COMMIT comentado (`/*...*/`) en SP de scoring crediticio. Anti-patrón idéntico al 20260731. El defecto existía desde antes del 31/07 — código byte a byte idéntico en ambas fechas.

---

## Relaciones entre incidentes

```
INC-20260731 ←→ INC-20260801
  Mismo anti-patrón: transacción larga sin COMMIT
  Distinto SP: sp_concreing_conciliacion ↔ califica_scoring_cjunk
  108 SPs con el mismo patrón en 12 BDs (hallazgo INC-20260801 §12)

INC-20260424-004/005/006 ←→ INC-20260424-007
  Código 4395: mayor en Huellas442 (INC-007)
  Posible relación causal entre código ESB no documentado y datos stale

INC-20260424-001 (APPRIZA SSL) ←→ INC-20260424-004 (código 3165 SSL)
  Mismo tipo de error (SSL socket error)
  Posible certificado compartido o degradación del mismo componente de red

INC-20260424-002 (CWE-390) ←→ INC-20260731/20260801 (COMMIT comentado)
  Clase de defecto: código que silencia errores o acumula estado sin liberar
  Anti-patrón sistémico transversal al corpus completo
```

---

## Distribución de severidad

| Severidad | Incidentes | IDs |
|-----------|-----------|-----|
| CRÍTICA | 2 | INC-20260731, INC-20260801 |
| **N5** | 1 | INC-20260424-003 |
| N4 | 1 | INC-20260424-002 |
| N3 | 2 | INC-20260424-001, INC-20260424-004/005/006 |
| N2 | 2 | INC-20260424-007, INC-20260424-008 |

---

*Última actualización: 2026-08-06 | BCOPCore Gemelo Cognitivo — DISCOVER Etapa 1*

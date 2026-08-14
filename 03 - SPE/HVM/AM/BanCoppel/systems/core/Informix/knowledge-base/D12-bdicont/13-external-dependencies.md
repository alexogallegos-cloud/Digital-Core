# D12 · Contabilidad — Dependencias Externas y Terceros

> **Componente:** Informix · SPE-AM-001 · Etapa 1
> **Base de datos:** `bdicont` · IBM Informix IDS 14.10 / POWER-AIX
> **Wave:** Wave 4 · Riesgo: **ALTO**
> **Última actualización:** 2026-07-03

---
**SME responsable:**
- Specialist — Informix SPL Analysis (análisis estático, code extraction)
- DBA — IBM Informix IDS (schema real vía syscolumns — Etapa 2) ← NUEVO
- Industry Banking + Domain Expert BanCoppel (validación funcional)
- Cybersecurity (riesgos PII, regulación CNBV/LFPDPPP)
- QA Lead — Equivalencia Funcional (estrategia de pruebas) ← NUEVO
- Cloud Architect AWS Banking (arquitectura target) ← NUEVO
> [SME-PENDING] = requiere sesión de validación antes de Etapa 2.
---

## Por qué no hay package.json en Informix SPL

Las dependencias externas en SPL se manifiestan como: (1) nombres de proveedores en comentarios,
(2) nombres de SPs que revelan integraciones, (3) cross-DB calls, (4) tablas temporales de intercambio,
(5) funciones built-in del motor sin equivalente PostgreSQL.

## Resumen de dependencias detectadas

| # | Dependencia | Tipo | Criticidad | Evidencia |
|---|------------|------|-----------|----------|
| DEP-01 | IBM Informix IDS 14.10 | Motor de BD (a reemplazar) | 🔴 CRÍTICA | Todo el dominio |
| DEP-02 | Scheduler AIX (cron/UC4/Control-M) | Orquestación batch | 🔴 CRÍTICA | SPs batch sin caller |
| DEP-03 | `bdicont` (Contabilidad) | Cross-DB call (dominio interno) | 🔴 CRÍTICA | 26 SPs hacen cross-DB |
| DEP-04 | `bdinteg` (Integración/Auth) | Cross-DB call (dominio interno) | 🔴 CRÍTICA | 28 SPs hacen cross-DB |
| DEP-05 | `bdirepaut` (BDIREPAUT) | Cross-DB call (dominio interno) | 🟡 MEDIA | 1 SPs hacen cross-DB |
| DEP-06 | `sysmaster` (Sysmaster (Informix interno)) | Cross-DB call (dominio interno) | 🟡 MEDIA | 1 SPs hacen cross-DB |
| DEP-07 | CNBV (reportes regulatorios) | Sistema externo | 🟠 ALTA | Detectado en comentarios / nombres de SP |
| DEP-08 | Auditoría externa (Deloitte/KPMG) | Sistema externo | 🟠 ALTA | Detectado en comentarios / nombres de SP |
| DEP-09 | SAT (contabilidad electrónica) | Sistema externo | 🟠 ALTA | Detectado en comentarios / nombres de SP |

---
## DEP-01 · IBM Informix IDS 14.10 — Motor de BD (a reemplazar)

**Criticidad:** 🔴 CRÍTICA — todo el dominio `bdicont` es SPL nativo de Informix.

| Atributo | Valor |
|----------|-------|
| Motor actual | IBM Informix IDS 14.10 FC10W2 / POWER-AIX |
| Motor target | Aurora PostgreSQL 15+ o Amazon RDS PostgreSQL |
| Funciones SPL a reescribir | Ver sección de built-ins |
| Tipos de datos críticos | MONEY, DATETIME YEAR TO FRACTION, SERIAL |

---
## DEP-02 · Scheduler AIX — Orquestación Batch

**Criticidad:** 🔴 CRÍTICA — sin scheduler los procesos batch no se ejecutan.

| Atributo | Valor |
|----------|-------|
| Herramienta actual | [SME-PENDING] — UC4, Control-M, o cron nativo AIX |
| SPs orquestados | Ver 11-batch-processes.md |
| Target equivalente | AWS EventBridge Scheduler + Step Functions |

**Acción urgente:**
```bash
crontab -u informix -l
find /opt /home -name "*.cron" 2>/dev/null | head -20
```

---
## Dependencias cross-DB detectadas

### `bdinteg` — Integración/Auth

**Criticidad:** 🔴 CRÍTICA — 28 SPs de `bdicont` hacen cross-DB call

| SP de `bdicont` | Tablas accedidas en `bdinteg` | Tipo |
|----|----|----|  
| `detmauxsuc` | `bdinteg:si_divisas`, `bdinteg:si_catalog` | R |
| `gen_balprevreg` | `bdinteg:si_plazas`, `bdinteg:si_sucursales`, `bdinteg:si_catalog` | R |
| `gen_balprevcc` | `bdinteg:si_plazas`, `bdinteg:si_sucursales`, `bdinteg:si_catalog` | R |
| `corrige_saldos` | `bdinteg:si_catalog` | R |
| `auditapase_ant` | `bdinteg:si_regional`, `bdinteg:si_sucursales`, `bdinteg:si_catalog` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `Integración/AuthService`. Requiere definir contrato OpenAPI.

### `bdicont` — Contabilidad

**Criticidad:** 🔴 CRÍTICA — 26 SPs de `bdicont` hacen cross-DB call

| SP de `bdicont` | Tablas accedidas en `bdicont` | Tipo |
|----|----|----|  
| `libromayor_historicos` | `bdicont:tmp_monedas`, `bdicont:tmp_saldos`, `bdicont:tmp_saldosfinales` | R |
| `pase_act_hist` | `bdicont:co_fechas` | R |
| `del_co_histsdodias` | `bdicont:co_histsdodias` | R |
| `inicializa` | `bdicont:co_histsdodias`, `bdicont:co_param`, `bdicont:co_historico` | R |
| `corrige_saldos` | `bdicont:co_histsdodias`, `bdicont:co_fechas` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `ContabilidadService`. Requiere definir contrato OpenAPI.

### `bdirepaut` — BDIREPAUT

**Criticidad:** 🟡 MEDIA — 1 SPs de `bdicont` hacen cross-DB call

| SP de `bdicont` | Tablas accedidas en `bdirepaut` | Tipo |
|----|----|----|  
| `gen_totalbalanza` | `bdirepaut:sp_preciocontable` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `BDIREPAUTService`. Requiere definir contrato OpenAPI.

### `sysmaster` — Sysmaster (Informix interno)

**Criticidad:** 🟡 MEDIA — 1 SPs de `bdicont` hacen cross-DB call

| SP de `bdicont` | Tablas accedidas en `sysmaster` | Tipo |
|----|----|----|  
| `libromayaux_old` | `sysmaster:systabnames` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `Sysmaster (Informix interno)Service`. Requiere definir contrato OpenAPI.

---
## Funciones Built-in de Informix (sin equivalente directo en PostgreSQL)

| Función Informix | Usos detectados | Equivalente PostgreSQL | Riesgo |
|-----------------|-----------------|----------------------|--------|
| `TRIM()` | 34 usos | `TRIM / BTRIM` | 🟡 Ajuste menor |
| `MONTH()` | 31 usos | `EXTRACT(MONTH FROM date)` | 🟡 Ajuste menor |
| `YEAR()` | 30 usos | `EXTRACT(YEAR FROM date)` | 🟡 Ajuste menor |
| `CURRENT()` | 30 usos | `NOW() / CURRENT_TIMESTAMP` | 🟡 Ajuste menor |
| `DATETIME()` | 6 usos | `TIMESTAMP` | 🟡 Ajuste de sintaxis |
| `MDY()` | 2 usos | `MAKE_DATE(y,m,d)` | 🟡 Ajuste menor |

---
## Matriz de impacto en cutover

| Dependencia | ¿Bloquea cutover? | Plan de continuidad | Owner |
|------------|-------------------|---------------------|-------|
| IBM Informix IDS | ✅ SÍ (es el motor) | Aurora PostgreSQL 15+ | DBA + Cloud Architect |
| Scheduler AIX | ✅ SÍ (batch jobs) | AWS EventBridge Scheduler | DevOps / Infra |
| `bdicont` cross-DB | ✅ SÍ si no tiene API | API interna de `ContabilidadService` | Architect AM |
| `bdinteg` cross-DB | ✅ SÍ si no tiene API | API interna de `Integración/AuthService` | Architect AM |
| `bdirepaut` cross-DB | ✅ SÍ si no tiene API | API interna de `BDIREPAUTService` | Architect AM |
| `sysmaster` cross-DB | ✅ SÍ si no tiene API | API interna de `Sysmaster (Informix interno)Service` | Architect AM |
| CNBV (reportes regulatorios) | 🟡 Parcial | Evaluar reemplazo o mantener integración | Architect AM |
| Auditoría externa (Deloitte/KPMG) | 🟡 Parcial | Evaluar reemplazo o mantener integración | Architect AM |
| SAT (contabilidad electrónica) | 🟡 Parcial | Evaluar reemplazo o mantener integración | Architect AM |
| Built-ins SPL | 🟡 Parcial (reescritura) | Mapping en capa de aplicación | Dev Team |


---
*Generado por: Specialist — Informix SPL Analysis · 2026-07-03 · Evidencia: source/informix/bdicont_*.sql (análisis estático de 70 archivos SQL) · análisis estático de archivos SQL*

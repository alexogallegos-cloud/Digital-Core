# D10 · Sucursales — Dependencias Externas y Terceros

> **Componente:** Informix · SPE-AM-001 · Etapa 1
> **Base de datos:** `bdisuc` · IBM Informix IDS 14.10 / POWER-AIX
> **Wave:** Wave 3 · Riesgo: **ALTO**
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
| DEP-03 | `bdicont` (Contabilidad) | Cross-DB call (dominio interno) | 🟠 ALTA | 10 SPs hacen cross-DB |
| DEP-04 | `bdinteg` (Integración/Auth) | Cross-DB call (dominio interno) | 🔴 CRÍTICA | 52 SPs hacen cross-DB |
| DEP-05 | `bdisuc` (Sucursales) | Cross-DB call (dominio interno) | 🔴 CRÍTICA | 58 SPs hacen cross-DB |
| DEP-06 | `sysmaster` (Sysmaster (Informix interno)) | Cross-DB call (dominio interno) | 🟠 ALTA | 6 SPs hacen cross-DB |
| DEP-07 | Brinks/G4S (transportadora de valores) | Sistema externo | 🟠 ALTA | Detectado en comentarios / nombres de SP |
| DEP-08 | SmartVista (retiro en caja) | Sistema externo | 🟠 ALTA | Detectado en comentarios / nombres de SP |
| DEP-09 | Intercard | Sistema externo | 🟠 ALTA | Detectado en comentarios / nombres de SP |

---
## DEP-01 · IBM Informix IDS 14.10 — Motor de BD (a reemplazar)

**Criticidad:** 🔴 CRÍTICA — todo el dominio `bdisuc` es SPL nativo de Informix.

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

### `bdisuc` — Sucursales

**Criticidad:** 🔴 CRÍTICA — 58 SPs de `bdisuc` hacen cross-DB call

| SP de `bdisuc` | Tablas accedidas en `bdisuc` | Tipo |
|----|----|----|  
| `sp_cargaredtcat` | `bdisuc:ss_atm`, `bdisuc:`, `bdisuc:ss_bitacora_corteadmin` | R |
| `pasecajag` | `bdisuc:ss_mae_entradasalida`, `bdisuc:ss_poliza`, `bdisuc:ss_ctrlpasecg` | R |
| `sp_concensuc_web` | `bdisuc:ss_operaciones`, `bdisuc:`, `bdisuc:ss_proveedores` | R |
| `sp_admon_documentos` | `bdisuc:` | R |
| `reversion_sobrante` | `bdisuc:` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `SucursalesService`. Requiere definir contrato OpenAPI.

### `bdinteg` — Integración/Auth

**Criticidad:** 🔴 CRÍTICA — 52 SPs de `bdisuc` hacen cross-DB call

| SP de `bdisuc` | Tablas accedidas en `bdinteg` | Tipo |
|----|----|----|  
| `sp_cargaredtcat` | `bdinteg:si_fechas` | R |
| `pasecajag` | `bdinteg:si_ejecut`, `bdinteg:si_plazas`, `bdinteg:si_fechas` | R |
| `sp_admon_documentos` | `bdinteg:` | R |
| `reversion_sobrante` | `bdinteg:` | R |
| `sp_actualizapieza_bym` | `bdinteg:` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `Integración/AuthService`. Requiere definir contrato OpenAPI.

### `bdicont` — Contabilidad

**Criticidad:** 🟠 ALTA — 10 SPs de `bdisuc` hacen cross-DB call

| SP de `bdisuc` | Tablas accedidas en `bdicont` | Tipo |
|----|----|----|  
| `pasecajag_esp` | `bdicont:co_poldet`, `bdicont:co_poliza`, `bdicont:co_detpol` | R |
| `pasecajag` | `bdicont:co_poldet`, `bdicont:co_poliza`, `bdicont:co_detpol` | R |
| `pasecont` | `bdicont:co_poldet` | R |
| `pasecajag_fec` | `bdicont:co_poldet`, `bdicont:co_poliza`, `bdicont:co_detpol` | R |
| `sp_actualizapieza_bym` | `bdicont:co_histsdodias`, `bdicont:co_sdodias`, `bdicont:co_fechas` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `ContabilidadService`. Requiere definir contrato OpenAPI.

### `sysmaster` — Sysmaster (Informix interno)

**Criticidad:** 🟠 ALTA — 6 SPs de `bdisuc` hacen cross-DB call

| SP de `bdisuc` | Tablas accedidas en `sysmaster` | Tipo |
|----|----|----|  
| `sp_actestatuscajacap` | `sysmaster:sysshmvals` | R |
| `sp_actestatuscaja` | `sysmaster:`, `sysmaster:sysshmvals` | R |
| `reversion_sobrante` | `sysmaster:sysshmvals` | R |
| `sp_actestatuscajaras` | `sysmaster:sysshmvals` | R |
| `sp_consul_dotacion2` | `sysmaster:sysshmvals` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `Sysmaster (Informix interno)Service`. Requiere definir contrato OpenAPI.

---
## Funciones Built-in de Informix (sin equivalente directo en PostgreSQL)

| Función Informix | Usos detectados | Equivalente PostgreSQL | Riesgo |
|-----------------|-----------------|----------------------|--------|
| `NVL()` | 182 usos | `COALESCE` | 🟡 Ajuste menor |
| `TRIM()` | 135 usos | `TRIM / BTRIM` | 🟡 Ajuste menor |
| `CURRENT()` | 28 usos | `NOW() / CURRENT_TIMESTAMP` | 🟡 Ajuste menor |
| `DBINFO()` | 12 usos | `txid_current() / session_user` | 🔴 Sin equiv. directo |
| `DATETIME()` | 11 usos | `TIMESTAMP` | 🟡 Ajuste de sintaxis |
| `YEAR()` | 5 usos | `EXTRACT(YEAR FROM date)` | 🟡 Ajuste menor |
| `MDY()` | 5 usos | `MAKE_DATE(y,m,d)` | 🟡 Ajuste menor |
| `EXTEND()` | 4 usos | `CAST(x AS TIMESTAMP(n))` | 🟡 Ajuste menor |
| `TODAY()` | 2 usos | `CURRENT_DATE` | 🟢 Directo |

---
## Matriz de impacto en cutover

| Dependencia | ¿Bloquea cutover? | Plan de continuidad | Owner |
|------------|-------------------|---------------------|-------|
| IBM Informix IDS | ✅ SÍ (es el motor) | Aurora PostgreSQL 15+ | DBA + Cloud Architect |
| Scheduler AIX | ✅ SÍ (batch jobs) | AWS EventBridge Scheduler | DevOps / Infra |
| `bdicont` cross-DB | ✅ SÍ si no tiene API | API interna de `ContabilidadService` | Architect AM |
| `bdinteg` cross-DB | ✅ SÍ si no tiene API | API interna de `Integración/AuthService` | Architect AM |
| `bdisuc` cross-DB | ✅ SÍ si no tiene API | API interna de `SucursalesService` | Architect AM |
| `sysmaster` cross-DB | ✅ SÍ si no tiene API | API interna de `Sysmaster (Informix interno)Service` | Architect AM |
| Brinks/G4S (transportadora de valores) | 🟡 Parcial | Evaluar reemplazo o mantener integración | Architect AM |
| SmartVista (retiro en caja) | 🟡 Parcial | Evaluar reemplazo o mantener integración | Architect AM |
| Intercard | 🟡 Parcial | Evaluar reemplazo o mantener integración | Architect AM |
| Built-ins SPL | 🟡 Parcial (reescritura) | Mapping en capa de aplicación | Dev Team |


---
*Generado por: Specialist — Informix SPL Analysis · 2026-07-03 · Evidencia: source/informix/bdisuc_*.sql (análisis estático de 70 archivos SQL) · análisis estático de archivos SQL*

<!-- LOG-DATA-BEGIN -->
## Sistemas externos observados en logs — 2026-04-24
> Fuente: `source/logs/errores_bus_2026-04-24_*.txt` · Incorporado: 2026-08-01

| Sistema externo | Protocolo | Llamadas observadas | Notas |
|-----------------|-----------|---------------------|-------|
| APPRIZA — CFPA | SOAP/HTTPS | 1 | Servicio ESB: `RemesasAPPRIZA` |

### Errores de comunicación con externos (SSL / timeout / JNI)

| Código | Descripción | Volumen/día | Servicios |
|--------|-------------|-------------|-----------|
| `3743` | Handle Timed-out — timeout en conexión SOAP/JNI con sis | 18 | AdmonSuC |

*Generado por generate-kb-from-logs.py · 2026-08-01*
<!-- LOG-DATA-END -->

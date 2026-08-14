# D06 · Solicitudes — Dependencias Externas y Terceros

> **Componente:** Informix · SPE-AM-001 · Etapa 1
> **Base de datos:** `bdisolic` · IBM Informix IDS 14.10 / POWER-AIX
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
| DEP-03 | `BDISOLIC` (BDISOLIC) | Cross-DB call (dominio interno) | 🟡 MEDIA | 1 SPs hacen cross-DB |
| DEP-04 | `bdINteg` (BDINTEG) | Cross-DB call (dominio interno) | 🟡 MEDIA | 1 SPs hacen cross-DB |
| DEP-05 | `bdicheq` (Cheques/Cuentas) | Cross-DB call (dominio interno) | 🟠 ALTA | 8 SPs hacen cross-DB |
| DEP-06 | `bdicnweb` (Canal Digital Web) | Cross-DB call (dominio interno) | 🟡 MEDIA | 3 SPs hacen cross-DB |
| DEP-07 | `bdicobranza` (Cobranza) | Cross-DB call (dominio interno) | 🟠 ALTA | 6 SPs hacen cross-DB |
| DEP-08 | `bdicred` (Créditos) | Cross-DB call (dominio interno) | 🔴 CRÍTICA | 23 SPs hacen cross-DB |
| DEP-09 | `bdinteg` (Integración/Auth) | Cross-DB call (dominio interno) | 🔴 CRÍTICA | 31 SPs hacen cross-DB |
| DEP-10 | `bdiprospectos` (BDIPROSPECTOS) | Cross-DB call (dominio interno) | 🟡 MEDIA | 3 SPs hacen cross-DB |
| DEP-11 | `bdisolic` (Solicitudes) | Cross-DB call (dominio interno) | 🔴 CRÍTICA | 42 SPs hacen cross-DB |
| DEP-12 | `sysmaster` (Sysmaster (Informix interno)) | Cross-DB call (dominio interno) | 🟡 MEDIA | 2 SPs hacen cross-DB |
| DEP-13 | Buró de Crédito | Sistema externo | 🟠 ALTA | Detectado en comentarios / nombres de SP |
| DEP-14 | RENAPO | Sistema externo | 🟠 ALTA | Detectado en comentarios / nombres de SP |
| DEP-15 | SAT | Sistema externo | 🟠 ALTA | Detectado en comentarios / nombres de SP |
| DEP-16 | Telecheck | Sistema externo | 🟠 ALTA | Detectado en comentarios / nombres de SP |

---
## DEP-01 · IBM Informix IDS 14.10 — Motor de BD (a reemplazar)

**Criticidad:** 🔴 CRÍTICA — todo el dominio `bdisolic` es SPL nativo de Informix.

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

### `bdisolic` — Solicitudes

**Criticidad:** 🔴 CRÍTICA — 42 SPs de `bdisolic` hacen cross-DB call

| SP de `bdisolic` | Tablas accedidas en `bdisolic` | Tipo |
|----|----|----|  
| `sp_actualiza_tipoparametrico` | `bdisolic:ss_solicitudes` | R |
| `sp_asigna_solicitud_soc_costo` | `bdisolic:ss_solicitudes_mc`, `bdisolic:`, `bdisolic:ss_solicitudes` | R |
| `sp_asigna_solicitud_soc_ratj` | `bdisolic:ss_resum_scor_fin`, `bdisolic:ss_resumen_scoring`, `bdisolic:` | R |
| `asigna_numsol_web` | `bdisolic:ss_solic_producto` | R |
| `sp_actualiza_solicitudes_inserta_datos` | `bdisolic:ss_autorizacion_especial`, `bdisolic:ss_solicitudes` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `SolicitudesService`. Requiere definir contrato OpenAPI.

### `bdinteg` — Integración/Auth

**Criticidad:** 🔴 CRÍTICA — 31 SPs de `bdisolic` hacen cross-DB call

| SP de `bdisolic` | Tablas accedidas en `bdinteg` | Tipo |
|----|----|----|  
| `sp_asigna_solicitud_soc_costo` | `bdinteg:si_sucursales`, `bdinteg:si_bitacora_ife` | R |
| `sp_asigna_solicitud_soc_ratj` | `bdinteg:si_bitacora_ife`, `bdinteg:si_sucursales` | R |
| `sp_adn_inforeportes_web` | `bdinteg:` | R |
| `sp_asigna_solicitud_soc_2p_ratj` | `bdinteg:si_sucursales`, `bdinteg:si_bitacora_ife` | R |
| `alta_sol_tc_cjunk_multicanal` | `bdinteg:si_actsubact`, `bdinteg:si_cliente`, `bdinteg:si_edocivil` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `Integración/AuthService`. Requiere definir contrato OpenAPI.

### `bdicred` — Créditos

**Criticidad:** 🔴 CRÍTICA — 23 SPs de `bdisolic` hacen cross-DB call

| SP de `bdisolic` | Tablas accedidas en `bdicred` | Tipo |
|----|----|----|  
| `sp_adn_inforeportes_web` | `bdicred:`, `bdicred:sd_definicion` | R |
| `asigna_numsolp` | `bdicred:sd_param` | R |
| `asigna_numsol_web` | `bdicred:sd_param` | R |
| `sp_adn_calculalinea` | `bdicred:` | R |
| `sp_adn_obtenerctanomina` | `bdicred:` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `CréditosService`. Requiere definir contrato OpenAPI.

### `bdicheq` — Cheques/Cuentas

**Criticidad:** 🟠 ALTA — 8 SPs de `bdisolic` hacen cross-DB call

| SP de `bdisolic` | Tablas accedidas en `bdicheq` | Tipo |
|----|----|----|  
| `sp_adn_incrementa_lincred_pbajj` | `bdicheq:` | R |
| `sp_adn_obtienectas` | `bdicheq:` | R |
| `sp_adn_evalua_ing` | `bdicheq:` | R |
| `sp_adn_calculalinea` | `bdicheq:` | R |
| `sp_adn_obtenerctanomina` | `bdicheq:` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `Cheques/CuentasService`. Requiere definir contrato OpenAPI.

### `bdicobranza` — Cobranza

**Criticidad:** 🟠 ALTA — 6 SPs de `bdisolic` hacen cross-DB call

| SP de `bdisolic` | Tablas accedidas en `bdicobranza` | Tipo |
|----|----|----|  
| `sp_asigna_solicitud_soc_3p_ratj` | `bdicobranza:` | R |
| `sp_asigna_solicitud_soc_costo` | `bdicobranza:` | R |
| `sp_asigna_solicitud_soc_ratj` | `bdicobranza:` | R |
| `sp_asigna_solicitud_soc_2p_ratj` | `bdicobranza:` | R |
| `sp_asigna_solicitud_soc` | `bdicobranza:` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `CobranzaService`. Requiere definir contrato OpenAPI.

### `bdiprospectos` — BDIPROSPECTOS

**Criticidad:** 🟡 MEDIA — 3 SPs de `bdisolic` hacen cross-DB call

| SP de `bdisolic` | Tablas accedidas en `bdiprospectos` | Tipo |
|----|----|----|  
| `sp_actualiza_respuestacoppel_cteprosp` | `bdiprospectos:` | R |
| `sp_apercredcoppel2` | `bdiprospectos:` | R |
| `sp_actualiza_status_sol` | `bdiprospectos:` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `BDIPROSPECTOSService`. Requiere definir contrato OpenAPI.

### `bdicnweb` — Canal Digital Web

**Criticidad:** 🟡 MEDIA — 3 SPs de `bdisolic` hacen cross-DB call

| SP de `bdisolic` | Tablas accedidas en `bdicnweb` | Tipo |
|----|----|----|  
| `sp_asigna_solicitud_soc_3p_ratj` | `bdicnweb:` | R |
| `sp_asigna_solicitud_soc_ratj` | `bdicnweb:` | R |
| `sp_asigna_solicitud_soc` | `bdicnweb:` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `Canal Digital WebService`. Requiere definir contrato OpenAPI.

### `sysmaster` — Sysmaster (Informix interno)

**Criticidad:** 🟡 MEDIA — 2 SPs de `bdisolic` hacen cross-DB call

| SP de `bdisolic` | Tablas accedidas en `sysmaster` | Tipo |
|----|----|----|  
| `sp_actualiza_solicitudes` | `sysmaster:` | R |
| `sp_actualiza_status_sol` | `sysmaster:sysshmvals` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `Sysmaster (Informix interno)Service`. Requiere definir contrato OpenAPI.

### `bdINteg` — BDINTEG

**Criticidad:** 🟡 MEDIA — 1 SPs de `bdisolic` hacen cross-DB call

| SP de `bdisolic` | Tablas accedidas en `bdINteg` | Tipo |
|----|----|----|  
| `sp_actualiza_status_sol` | `bdINteg:si_cliente` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `BDINTEGService`. Requiere definir contrato OpenAPI.

### `BDISOLIC` — BDISOLIC

**Criticidad:** 🟡 MEDIA — 1 SPs de `bdisolic` hacen cross-DB call

| SP de `bdisolic` | Tablas accedidas en `BDISOLIC` | Tipo |
|----|----|----|  
| `sp_actualiza_status_sol` | `BDISOLIC:ss_solicitud_os` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `BDISOLICService`. Requiere definir contrato OpenAPI.

---
## Funciones Built-in de Informix (sin equivalente directo en PostgreSQL)

| Función Informix | Usos detectados | Equivalente PostgreSQL | Riesgo |
|-----------------|-----------------|----------------------|--------|
| `NVL()` | 244 usos | `COALESCE` | 🟡 Ajuste menor |
| `TRIM()` | 95 usos | `TRIM / BTRIM` | 🟡 Ajuste menor |
| `DATETIME()` | 22 usos | `TIMESTAMP` | 🟡 Ajuste de sintaxis |
| `YEAR()` | 12 usos | `EXTRACT(YEAR FROM date)` | 🟡 Ajuste menor |
| `MONTH()` | 10 usos | `EXTRACT(MONTH FROM date)` | 🟡 Ajuste menor |
| `DBINFO()` | 7 usos | `txid_current() / session_user` | 🔴 Sin equiv. directo |
| `TODAY()` | 7 usos | `CURRENT_DATE` | 🟢 Directo |
| `CURRENT()` | 6 usos | `NOW() / CURRENT_TIMESTAMP` | 🟡 Ajuste menor |
| `MDY()` | 5 usos | `MAKE_DATE(y,m,d)` | 🟡 Ajuste menor |
| `EXTEND()` | 1 usos | `CAST(x AS TIMESTAMP(n))` | 🟡 Ajuste menor |

---
## Matriz de impacto en cutover

| Dependencia | ¿Bloquea cutover? | Plan de continuidad | Owner |
|------------|-------------------|---------------------|-------|
| IBM Informix IDS | ✅ SÍ (es el motor) | Aurora PostgreSQL 15+ | DBA + Cloud Architect |
| Scheduler AIX | ✅ SÍ (batch jobs) | AWS EventBridge Scheduler | DevOps / Infra |
| `BDISOLIC` cross-DB | ✅ SÍ si no tiene API | API interna de `BDISOLICService` | Architect AM |
| `bdINteg` cross-DB | ✅ SÍ si no tiene API | API interna de `BDINTEGService` | Architect AM |
| `bdicheq` cross-DB | ✅ SÍ si no tiene API | API interna de `Cheques/CuentasService` | Architect AM |
| `bdicnweb` cross-DB | ✅ SÍ si no tiene API | API interna de `Canal Digital WebService` | Architect AM |
| `bdicobranza` cross-DB | ✅ SÍ si no tiene API | API interna de `CobranzaService` | Architect AM |
| Buró de Crédito | 🟡 Parcial | Evaluar reemplazo o mantener integración | Architect AM |
| RENAPO | 🟡 Parcial | Evaluar reemplazo o mantener integración | Architect AM |
| SAT | 🟡 Parcial | Evaluar reemplazo o mantener integración | Architect AM |
| Built-ins SPL | 🟡 Parcial (reescritura) | Mapping en capa de aplicación | Dev Team |


---
*Generado por: Specialist — Informix SPL Analysis · 2026-07-03 · Evidencia: source/informix/bdisolic_*.sql (análisis estático de 70 archivos SQL) · análisis estático de archivos SQL*

<!-- LOG-DATA-BEGIN -->
## Sistemas externos observados en logs — 2026-04-24
> Fuente: `source/logs/errores_bus_2026-04-24_*.txt` · Incorporado: 2026-08-01

| Sistema externo | Protocolo | Llamadas observadas | Notas |
|-----------------|-----------|---------------------|-------|
| APPRIZA — CFPA (batch) | SOAP/HTTPS | 3 | Servicio ESB: `RemesasAPPRIZAAutomaticas` |
| PostgreSQL Huellas (target migrado) | JDBC | 1 | Servicio ESB: `Huellas442` |

*Generado por generate-kb-from-logs.py · 2026-08-01*
<!-- LOG-DATA-END -->

# D03 · Créditos — Dependencias Externas y Terceros

> **Componente:** Informix · SPE-AM-001 · Etapa 1
> **Base de datos:** `bdicred` · IBM Informix IDS 14.10 / POWER-AIX
> **Wave:** Wave 4 · Riesgo: **CRÍTICO**
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
| DEP-04 | `bdiburo` (BDIBURO) | Cross-DB call (dominio interno) | 🟡 MEDIA | 1 SPs hacen cross-DB |
| DEP-05 | `bdicheq` (Cheques/Cuentas) | Cross-DB call (dominio interno) | 🔴 CRÍTICA | 11 SPs hacen cross-DB |
| DEP-06 | `bdicobranza` (Cobranza) | Cross-DB call (dominio interno) | 🟠 ALTA | 4 SPs hacen cross-DB |
| DEP-07 | `bdicred` (Créditos) | Cross-DB call (dominio interno) | 🔴 CRÍTICA | 57 SPs hacen cross-DB |
| DEP-08 | `bdimnsj` (Mensajería) | Cross-DB call (dominio interno) | 🟡 MEDIA | 2 SPs hacen cross-DB |
| DEP-09 | `bdinteg` (Integración/Auth) | Cross-DB call (dominio interno) | 🔴 CRÍTICA | 38 SPs hacen cross-DB |
| DEP-10 | `bdisitesp` (BDISITESP) | Cross-DB call (dominio interno) | 🟡 MEDIA | 3 SPs hacen cross-DB |
| DEP-11 | `bdisolic` (Solicitudes) | Cross-DB call (dominio interno) | 🔴 CRÍTICA | 19 SPs hacen cross-DB |
| DEP-12 | `bditransfer` (BDITRANSFER) | Cross-DB call (dominio interno) | 🟡 MEDIA | 1 SPs hacen cross-DB |
| DEP-13 | `intercard` (Intercard (POS/ATM)) | Cross-DB call (dominio interno) | 🟠 ALTA | 6 SPs hacen cross-DB |
| DEP-14 | `lineas` (LINEAS) | Cross-DB call (dominio interno) | 🟡 MEDIA | 1 SPs hacen cross-DB |
| DEP-15 | `sysmaster` (Sysmaster (Informix interno)) | Cross-DB call (dominio interno) | 🟠 ALTA | 6 SPs hacen cross-DB |
| DEP-16 | Buró de Crédito (CIEC) | Sistema externo | 🟠 ALTA | Detectado en comentarios / nombres de SP |
| DEP-17 | Telecheck | Sistema externo | 🟠 ALTA | Detectado en comentarios / nombres de SP |
| DEP-18 | INFONAVIT | Sistema externo | 🟠 ALTA | Detectado en comentarios / nombres de SP |
| DEP-19 | SmartVista (líneas de crédito) | Sistema externo | 🟠 ALTA | Detectado en comentarios / nombres de SP |

---
## DEP-01 · IBM Informix IDS 14.10 — Motor de BD (a reemplazar)

**Criticidad:** 🔴 CRÍTICA — todo el dominio `bdicred` es SPL nativo de Informix.

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

### `bdicred` — Créditos

**Criticidad:** 🔴 CRÍTICA — 57 SPs de `bdicred` hacen cross-DB call

| SP de `bdicred` | Tablas accedidas en `bdicred` | Tipo |
|----|----|----|  
| `aclaraciones_edoctacrd` | `bdicred:sd_mensajes_edoctacrd`, `bdicred:`, `bdicred:sd_reporte_calificacion` | R |
| `act_amortiza_mes` | `bdicred:sd_amortiza_credito` | R |
| `sp_actualizar_bitacora_pba` | `bdicred:`, `bdicred:sd_maesdoscrd`, `bdicred:sd_maesdos` | R |
| `act_pagmin` | `bdicred:sd_movdia`, `bdicred:sd_movhis` | R |
| `sp_adn_disposicion` | `bdicred:sd_movhis_calif`, `bdicred:`, `bdicred:sd_hist_reserva_old` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `CréditosService`. Requiere definir contrato OpenAPI.

### `bdinteg` — Integración/Auth

**Criticidad:** 🔴 CRÍTICA — 38 SPs de `bdicred` hacen cross-DB call

| SP de `bdicred` | Tablas accedidas en `bdinteg` | Tipo |
|----|----|----|  
| `aclaraciones_edoctacrd` | `bdinteg:si_empresas`, `bdinteg:si_cliente`, `bdinteg:si_estados` | R |
| `sp_actualizar_bitacora_pba` | `bdinteg:si_huella_temp` | R |
| `sp_adn_disposicion` | `bdinteg:` | R |
| `aclaraciones_edoctacrd_sif` | `bdinteg:` | R |
| `sp_administra_tarjetas_ppass_web` | `bdinteg:` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `Integración/AuthService`. Requiere definir contrato OpenAPI.

### `bdisolic` — Solicitudes

**Criticidad:** 🔴 CRÍTICA — 19 SPs de `bdicred` hacen cross-DB call

| SP de `bdicred` | Tablas accedidas en `bdisolic` | Tipo |
|----|----|----|  
| `sp_adn_disposicion` | `bdisolic:` | R |
| `aclaraciones_edoctacrd_sif` | `bdisolic:` | R |
| `sp_administra_tarjetas_ppass_web` | `bdisolic:ss_solicitudes` | R |
| `sp_adicionalcreditopendiente` | `bdisolic:` | R |
| `sp_actsdodiariocrd` | `bdisolic:ss_autorizacion`, `bdisolic:` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `SolicitudesService`. Requiere definir contrato OpenAPI.

### `bdicheq` — Cheques/Cuentas

**Criticidad:** 🔴 CRÍTICA — 11 SPs de `bdicred` hacen cross-DB call

| SP de `bdicred` | Tablas accedidas en `bdicheq` | Tipo |
|----|----|----|  
| `sp_adn_cobroautomatico` | `bdicheq:` | R |
| `aclaraciones_edoctacrd` | `bdicheq:` | R |
| `sp_actualizar_bitacora` | `bdicheq:` | R |
| `aclaraciones_edoctacrd_sif` | `bdicheq:`, `bdicheq:sc_docret_sbc` | R |
| `sp_administra_tarjetas_ppass_web` | `bdicheq:` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `Cheques/CuentasService`. Requiere definir contrato OpenAPI.

### `intercard` — Intercard (POS/ATM)

**Criticidad:** 🟠 ALTA — 6 SPs de `bdicred` hacen cross-DB call

| SP de `bdicred` | Tablas accedidas en `intercard` | Tipo |
|----|----|----|  
| `sp_act_historica_cac_aumlincred` | `intercard:` | R |
| `sp_actualiza_vigenciatc` | `intercard:movimiento`, `intercard:movimientohistorico` | R |
| `sp_actualiza_creditos` | `intercard:bitacoracambiosstatustarjeta`, `intercard:bitasignacionactivaciontarjeta`, `intercard:bitacoracambiostarjeta` | R |
| `sp_actualizasolicmc_lineas` | `intercard:` | R |
| `sp_actestatustarjeta` | `intercard:productotarjeta`, `intercard:`, `intercard:tarjetacuenta` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `Intercard (POS/ATM)Service`. Requiere definir contrato OpenAPI.

### `sysmaster` — Sysmaster (Informix interno)

**Criticidad:** 🟠 ALTA — 6 SPs de `bdicred` hacen cross-DB call

| SP de `bdicred` | Tablas accedidas en `sysmaster` | Tipo |
|----|----|----|  
| `aclaraciones_edoctacrd` | `sysmaster:systabnames` | R |
| `sp_adn_disposicion` | `sysmaster:sysshmvals` | R |
| `sp_actualiza_creditos` | `sysmaster:` | R |
| `sp_actestatustarjeta` | `sysmaster:sysshmvals` | R |
| `sp_adn_cobroautomatico_manual` | `sysmaster:sysshmvals` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `Sysmaster (Informix interno)Service`. Requiere definir contrato OpenAPI.

### `bdicobranza` — Cobranza

**Criticidad:** 🟠 ALTA — 4 SPs de `bdicred` hacen cross-DB call

| SP de `bdicred` | Tablas accedidas en `bdicobranza` | Tipo |
|----|----|----|  
| `aclaraciones_edocta` | `bdicobranza:` | R |
| `aclaraciones_edoctacrd_sif` | `bdicobranza:` | R |
| `aclaraciones_edocta_sif` | `bdicobranza:` | R |
| `sp_actualizasaldos_cred` | `bdicobranza:` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `CobranzaService`. Requiere definir contrato OpenAPI.

### `bdisitesp` — BDISITESP

**Criticidad:** 🟡 MEDIA — 3 SPs de `bdicred` hacen cross-DB call

| SP de `bdicred` | Tablas accedidas en `bdisitesp` | Tipo |
|----|----|----|  
| `sp_administra_reestructura_pp` | `bdisitesp:se_ctessitespcred` | R |
| `sp_actualizar_bitacora` | `bdisitesp:se_ctessitespcred` | R |
| `sp_activa_insertos_fijos` | `bdisitesp:se_ctessitespcred`, `bdisitesp:se_ctessitespcred_his` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `BDISITESPService`. Requiere definir contrato OpenAPI.

### `bdimnsj` — Mensajería

**Criticidad:** 🟡 MEDIA — 2 SPs de `bdicred` hacen cross-DB call

| SP de `bdicred` | Tablas accedidas en `bdimnsj` | Tipo |
|----|----|----|  
| `sp_adn_sms` | `bdimnsj:mnsjr_trx_online`, `bdimnsj:mnsjr_trx_online_his` | R |
| `sp_adn_disposicion` | `bdimnsj:mnsjr_trx_online`, `bdimnsj:mnsjr_trx_online_his` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `MensajeríaService`. Requiere definir contrato OpenAPI.

### `bditransfer` — BDITRANSFER

**Criticidad:** 🟡 MEDIA — 1 SPs de `bdicred` hacen cross-DB call

| SP de `bdicred` | Tablas accedidas en `bditransfer` | Tipo |
|----|----|----|  
| `sp_actestatustarjeta` | `bditransfer:` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `BDITRANSFERService`. Requiere definir contrato OpenAPI.

### `bdiburo` — BDIBURO

**Criticidad:** 🟡 MEDIA — 1 SPs de `bdicred` hacen cross-DB call

| SP de `bdicred` | Tablas accedidas en `bdiburo` | Tipo |
|----|----|----|  
| `sp_adn_cobroautomatico_manual` | `bdiburo:br_variables_cc_cnr` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `BDIBUROService`. Requiere definir contrato OpenAPI.

### `BDISOLIC` — BDISOLIC

**Criticidad:** 🟡 MEDIA — 1 SPs de `bdicred` hacen cross-DB call

| SP de `bdicred` | Tablas accedidas en `BDISOLIC` | Tipo |
|----|----|----|  
| `abreax` | `BDISOLIC:SS_SOLICITUDES` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `BDISOLICService`. Requiere definir contrato OpenAPI.

### `lineas` — LINEAS

**Criticidad:** 🟡 MEDIA — 1 SPs de `bdicred` hacen cross-DB call

| SP de `bdicred` | Tablas accedidas en `lineas` | Tipo |
|----|----|----|  
| `act_lineas` | `lineas:sl_ctegpo`, `lineas:sl_ctepro`, `lineas:sl_grupos` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `LINEASService`. Requiere definir contrato OpenAPI.

---
## Funciones Built-in de Informix (sin equivalente directo en PostgreSQL)

| Función Informix | Usos detectados | Equivalente PostgreSQL | Riesgo |
|-----------------|-----------------|----------------------|--------|
| `NVL()` | 140 usos | `COALESCE` | 🟡 Ajuste menor |
| `TRIM()` | 39 usos | `TRIM / BTRIM` | 🟡 Ajuste menor |
| `MDY()` | 29 usos | `MAKE_DATE(y,m,d)` | 🟡 Ajuste menor |
| `YEAR()` | 28 usos | `EXTRACT(YEAR FROM date)` | 🟡 Ajuste menor |
| `MONTH()` | 28 usos | `EXTRACT(MONTH FROM date)` | 🟡 Ajuste menor |
| `CURRENT()` | 11 usos | `NOW() / CURRENT_TIMESTAMP` | 🟡 Ajuste menor |
| `DBINFO()` | 10 usos | `txid_current() / session_user` | 🔴 Sin equiv. directo |
| `DATETIME()` | 10 usos | `TIMESTAMP` | 🟡 Ajuste de sintaxis |
| `TODAY()` | 8 usos | `CURRENT_DATE` | 🟢 Directo |

---
## Matriz de impacto en cutover

| Dependencia | ¿Bloquea cutover? | Plan de continuidad | Owner |
|------------|-------------------|---------------------|-------|
| IBM Informix IDS | ✅ SÍ (es el motor) | Aurora PostgreSQL 15+ | DBA + Cloud Architect |
| Scheduler AIX | ✅ SÍ (batch jobs) | AWS EventBridge Scheduler | DevOps / Infra |
| `BDISOLIC` cross-DB | ✅ SÍ si no tiene API | API interna de `BDISOLICService` | Architect AM |
| `bdiburo` cross-DB | ✅ SÍ si no tiene API | API interna de `BDIBUROService` | Architect AM |
| `bdicheq` cross-DB | ✅ SÍ si no tiene API | API interna de `Cheques/CuentasService` | Architect AM |
| `bdicobranza` cross-DB | ✅ SÍ si no tiene API | API interna de `CobranzaService` | Architect AM |
| `bdicred` cross-DB | ✅ SÍ si no tiene API | API interna de `CréditosService` | Architect AM |
| Buró de Crédito (CIEC) | 🟡 Parcial | Evaluar reemplazo o mantener integración | Architect AM |
| Telecheck | 🟡 Parcial | Evaluar reemplazo o mantener integración | Architect AM |
| INFONAVIT | 🟡 Parcial | Evaluar reemplazo o mantener integración | Architect AM |
| Built-ins SPL | 🟡 Parcial (reescritura) | Mapping en capa de aplicación | Dev Team |


---
*Generado por: Specialist — Informix SPL Analysis · 2026-07-03 · Evidencia: source/informix/bdicred_*.sql (análisis estático de 70 archivos SQL) · análisis estático de archivos SQL*

<!-- LOG-DATA-BEGIN -->
## Sistemas externos observados en logs — 2026-04-24
> Fuente: `source/logs/errores_bus_2026-04-24_*.txt` · Incorporado: 2026-08-01

| Sistema externo | Protocolo | Llamadas observadas | Notas |
|-----------------|-----------|---------------------|-------|
| APPRIZA — CFPA (batch) | SOAP/HTTPS | 2 | Servicio ESB: `RemesasAPPRIZAAutomaticas` |

### Errores de comunicación con externos (SSL / timeout / JNI)

| Código | Descripción | Volumen/día | Servicios |
|--------|-------------|-------------|-----------|
| `3743` | Handle Timed-out — timeout en conexión SOAP/JNI con sis | 10 | SistemaCredito |
| `3701` | Error en JNI Call — Axis2Invoker fallo de comunicación  | 1 | SistemaCredito |

*Generado por generate-kb-from-logs.py · 2026-08-01*
<!-- LOG-DATA-END -->

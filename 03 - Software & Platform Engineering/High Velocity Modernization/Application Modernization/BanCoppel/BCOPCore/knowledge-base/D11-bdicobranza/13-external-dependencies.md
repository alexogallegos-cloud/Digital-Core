# D11 · Cobranza — Dependencias Externas y Terceros

> **Componente:** BCOPCore · SPE-AM-001 · Etapa 1
> **Base de datos:** `bdicobranza` · IBM Informix IDS 14.10 / POWER-AIX
> **Wave:** Wave 2 · Riesgo: **MEDIO**
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
| DEP-03 | `BDICOBRANZA` (BDICOBRANZA) | Cross-DB call (dominio interno) | 🟡 MEDIA | 1 SPs hacen cross-DB |
| DEP-04 | `BDINTEG` (BDINTEG) | Cross-DB call (dominio interno) | 🟡 MEDIA | 3 SPs hacen cross-DB |
| DEP-05 | `Bdicobranza` (BDICOBRANZA) | Cross-DB call (dominio interno) | 🟠 ALTA | 7 SPs hacen cross-DB |
| DEP-06 | `Bdinteg` (BDINTEG) | Cross-DB call (dominio interno) | 🟡 MEDIA | 1 SPs hacen cross-DB |
| DEP-07 | `bdiaclaracion` (Aclaraciones) | Cross-DB call (dominio interno) | 🟡 MEDIA | 1 SPs hacen cross-DB |
| DEP-08 | `bdicheq` (Cheques/Cuentas) | Cross-DB call (dominio interno) | 🟡 MEDIA | 2 SPs hacen cross-DB |
| DEP-09 | `bdicobranza` (Cobranza) | Cross-DB call (dominio interno) | 🔴 CRÍTICA | 64 SPs hacen cross-DB |
| DEP-10 | `bdicred` (Créditos) | Cross-DB call (dominio interno) | 🔴 CRÍTICA | 52 SPs hacen cross-DB |
| DEP-11 | `bdimnsj` (Mensajería) | Cross-DB call (dominio interno) | 🟡 MEDIA | 3 SPs hacen cross-DB |
| DEP-12 | `bdinteg` (Integración/Auth) | Cross-DB call (dominio interno) | 🔴 CRÍTICA | 50 SPs hacen cross-DB |
| DEP-13 | `bdinvers` (BDINVERS) | Cross-DB call (dominio interno) | 🟡 MEDIA | 2 SPs hacen cross-DB |
| DEP-14 | `bdisitesp` (BDISITESP) | Cross-DB call (dominio interno) | 🔴 CRÍTICA | 17 SPs hacen cross-DB |
| DEP-15 | `bdisolic` (Solicitudes) | Cross-DB call (dominio interno) | 🟠 ALTA | 6 SPs hacen cross-DB |
| DEP-16 | `sysmaster` (Sysmaster (Informix interno)) | Cross-DB call (dominio interno) | 🔴 CRÍTICA | 18 SPs hacen cross-DB |
| DEP-17 | Agencias de cobranza externas | Sistema externo | 🟠 ALTA | Detectado en comentarios / nombres de SP |
| DEP-18 | Buró de Crédito (reporte negativo) | Sistema externo | 🟠 ALTA | Detectado en comentarios / nombres de SP |
| DEP-19 | CONDUSEF (queja) | Sistema externo | 🟠 ALTA | Detectado en comentarios / nombres de SP |

---
## DEP-01 · IBM Informix IDS 14.10 — Motor de BD (a reemplazar)

**Criticidad:** 🔴 CRÍTICA — todo el dominio `bdicobranza` es SPL nativo de Informix.

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

### `bdicobranza` — Cobranza

**Criticidad:** 🔴 CRÍTICA — 64 SPs de `bdicobranza` hacen cross-DB call

| SP de `bdicobranza` | Tablas accedidas en `bdicobranza` | Tipo |
|----|----|----|  
| `sp_cat_consulta_ultimo_convenio` | `bdicobranza:cb_param_campania`, `bdicobranza:cb_medidor_compac`, `bdicobranza:cb_compac_his` | R |
| `sp_carga_movimientos_ivr` | `bdicobranza:cb_param_campania`, `bdicobranza:cb_movimientos_ivr` | R |
| `sp_cat_graba_respuesta_llamada` | `bdicobranza:` | R |
| `sp_cat_auronix_target_phone` | `bdicobranza:cb_info_administrativa`, `bdicobranza:cb_telefonos`, `bdicobranza:cb_cat_directorio_cte` | R |
| `sp_cargatelefonosburo` | `bdicobranza:tmp_telefonos_buro_2`, `bdicobranza:cb_param` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `CobranzaService`. Requiere definir contrato OpenAPI.

### `bdicred` — Créditos

**Criticidad:** 🔴 CRÍTICA — 52 SPs de `bdicobranza` hacen cross-DB call

| SP de `bdicobranza` | Tablas accedidas en `bdicred` | Tipo |
|----|----|----|  
| `sp_cat_consulta_ultimo_convenio` | `bdicred:` | R |
| `sp_carga_movimientos_ivr` | `bdicred:sd_fechas` | R |
| `sp_cat_auronix_target_phone` | `bdicred:sd_amortiza_credito`, `bdicred:sd_maesdos` | R |
| `sp_cargatelefonosburo` | `bdicred:sd_maecred` | R |
| `sp_cat_ivr_gen_archbase_tco` | `bdicred:sd_maecredanexo`, `bdicred:sd_maecred` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `CréditosService`. Requiere definir contrato OpenAPI.

### `bdinteg` — Integración/Auth

**Criticidad:** 🔴 CRÍTICA — 50 SPs de `bdicobranza` hacen cross-DB call

| SP de `bdicobranza` | Tablas accedidas en `bdinteg` | Tipo |
|----|----|----|  
| `sp_cat_consulta_ultimo_convenio` | `bdinteg:si_sucursales`, `bdinteg:` | R |
| `sp_cat_graba_respuesta_llamada` | `bdinteg:` | R |
| `sp_cat_auronix_target_phone` | `bdinteg:si_direcciones`, `bdinteg:si_cliente`, `bdinteg:si_catciudades` | R |
| `sp_cargatelefonosburo` | `bdinteg:si_fechas` | R |
| `sp_cat_ivr_gen_archbase_tco` | `bdinteg:si_empresas`, `bdinteg:si_telefonos_actual`, `bdinteg:si_cliente` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `Integración/AuthService`. Requiere definir contrato OpenAPI.

### `sysmaster` — Sysmaster (Informix interno)

**Criticidad:** 🔴 CRÍTICA — 18 SPs de `bdicobranza` hacen cross-DB call

| SP de `bdicobranza` | Tablas accedidas en `sysmaster` | Tipo |
|----|----|----|  
| `sp_archivo_compac` | `sysmaster:systabnames` | R |
| `sp_calcula_cobranza_administrativa` | `sysmaster:sysshmvals` | R |
| `sp_cargatelefonosburo` | `sysmaster:systabnames` | R |
| `sp_actualiza_catdirectoriocte` | `sysmaster:sysshmvals` | R |
| `sp_calcularcobranzapreventiva_contingencia` | `sysmaster:sysshmvals` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `Sysmaster (Informix interno)Service`. Requiere definir contrato OpenAPI.

### `bdisitesp` — BDISITESP

**Criticidad:** 🔴 CRÍTICA — 17 SPs de `bdicobranza` hacen cross-DB call

| SP de `bdicobranza` | Tablas accedidas en `bdisitesp` | Tipo |
|----|----|----|  
| `sp_actualiza_saldos_admin_tco` | `bdisitesp:` | R |
| `sp_actualiza_saldos_admin` | `bdisitesp:` | R |
| `sp_calcula_cobranza_administrativa` | `bdisitesp:se_situacionaccion`, `bdisitesp:se_ctessitespcte` | R |
| `sp_cat_gen_info_prev` | `bdisitesp:` | R |
| `sp_cat_modstadocte` | `bdisitesp:` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `BDISITESPService`. Requiere definir contrato OpenAPI.

### `Bdicobranza` — BDICOBRANZA

**Criticidad:** 🟠 ALTA — 7 SPs de `bdicobranza` hacen cross-DB call

| SP de `bdicobranza` | Tablas accedidas en `Bdicobranza` | Tipo |
|----|----|----|  
| `sp_cat_cambia_estatus_cte` | `Bdicobranza:` | R |
| `sp_cat_consparamcampania` | `Bdicobranza:` | R |
| `sp_cat_cargacartera` | `Bdicobranza:` | R |
| `fn_formaretiquetaxml` | `Bdicobranza:cb_param`, `Bdicobranza:cb_gestion_telefonica`, `Bdicobranza:` | R |
| `sp_cat_consulta_pagos_tc` | `Bdicobranza:` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `BDICOBRANZAService`. Requiere definir contrato OpenAPI.

### `bdisolic` — Solicitudes

**Criticidad:** 🟠 ALTA — 6 SPs de `bdicobranza` hacen cross-DB call

| SP de `bdicobranza` | Tablas accedidas en `bdisolic` | Tipo |
|----|----|----|  
| `sp_carga_telefonos` | `bdisolic:` | R |
| `sp_calcularcobranzapreventiva_contingencia` | `bdisolic:ss_refpersonales` | R |
| `fn_formaretiquetaxml` | `bdisolic:ss_solicitudes`, `bdisolic:ss_detalle_scoring`, `bdisolic:ss_refpersonales` | R |
| `sp_cat_consulta_generales` | `bdisolic:ss_refpersonales`, `bdisolic:ss_resum_scor_fin`, `bdisolic:ss_param` | R |
| `sp_calcularcobranzapreventiva` | `bdisolic:ss_refpersonales` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `SolicitudesService`. Requiere definir contrato OpenAPI.

### `BDINTEG` — BDINTEG

**Criticidad:** 🟡 MEDIA — 3 SPs de `bdicobranza` hacen cross-DB call

| SP de `bdicobranza` | Tablas accedidas en `BDINTEG` | Tipo |
|----|----|----|  
| `sp_cat_consulta_ultimo_convenio` | `BDINTEG:si_sucursales` | R |
| `sp_actualiza_catdirectoriocte_pba` | `BDINTEG:si_sucursales` | R |
| `fn_formaretiquetaxml` | `BDINTEG:si_sucursales` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `BDINTEGService`. Requiere definir contrato OpenAPI.

### `bdimnsj` — Mensajería

**Criticidad:** 🟡 MEDIA — 3 SPs de `bdicobranza` hacen cross-DB call

| SP de `bdicobranza` | Tablas accedidas en `bdimnsj` | Tipo |
|----|----|----|  
| `sp_actualiza_saldos_admin_tco` | `bdimnsj:mnsjr_trx_batch` | R |
| `sp_actualiza_saldos_admin` | `bdimnsj:mnsjr_trx_batch` | R |
| `fn_formaretiquetaxml` | `bdimnsj:mnsjr_trx_batch`, `bdimnsj:mnsjr_trx_batch_his` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `MensajeríaService`. Requiere definir contrato OpenAPI.

### `bdicheq` — Cheques/Cuentas

**Criticidad:** 🟡 MEDIA — 2 SPs de `bdicobranza` hacen cross-DB call

| SP de `bdicobranza` | Tablas accedidas en `bdicheq` | Tipo |
|----|----|----|  
| `sp_actualiza_catdirectoriocte_pba` | `bdicheq:sc_maechq` | R |
| `fn_formaretiquetaxml` | `bdicheq:sc_maechq` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `Cheques/CuentasService`. Requiere definir contrato OpenAPI.

### `bdinvers` — BDINVERS

**Criticidad:** 🟡 MEDIA — 2 SPs de `bdicobranza` hacen cross-DB call

| SP de `bdicobranza` | Tablas accedidas en `bdinvers` | Tipo |
|----|----|----|  
| `sp_actualiza_catdirectoriocte_pba` | `bdinvers:sv_maeinv` | R |
| `fn_formaretiquetaxml` | `bdinvers:sv_maeinv` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `BDINVERSService`. Requiere definir contrato OpenAPI.

### `BDICOBRANZA` — BDICOBRANZA

**Criticidad:** 🟡 MEDIA — 1 SPs de `bdicobranza` hacen cross-DB call

| SP de `bdicobranza` | Tablas accedidas en `BDICOBRANZA` | Tipo |
|----|----|----|  
| `fn_formaretiquetaxml` | `BDICOBRANZA:CB_COMPAC` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `BDICOBRANZAService`. Requiere definir contrato OpenAPI.

### `Bdinteg` — BDINTEG

**Criticidad:** 🟡 MEDIA — 1 SPs de `bdicobranza` hacen cross-DB call

| SP de `bdicobranza` | Tablas accedidas en `Bdinteg` | Tipo |
|----|----|----|  
| `fn_formaretiquetaxml` | `Bdinteg:si_direcciones` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `BDINTEGService`. Requiere definir contrato OpenAPI.

### `bdiaclaracion` — Aclaraciones

**Criticidad:** 🟡 MEDIA — 1 SPs de `bdicobranza` hacen cross-DB call

| SP de `bdicobranza` | Tablas accedidas en `bdiaclaracion` | Tipo |
|----|----|----|  
| `sp_cat_consulta_disponibilidad_cliente` | `bdiaclaracion:acl_aclaracion`, `bdiaclaracion:acl_producto` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `AclaracionesService`. Requiere definir contrato OpenAPI.

---
## Funciones Built-in de Informix (sin equivalente directo en PostgreSQL)

| Función Informix | Usos detectados | Equivalente PostgreSQL | Riesgo |
|-----------------|-----------------|----------------------|--------|
| `NVL()` | 53 usos | `COALESCE` | 🟡 Ajuste menor |
| `DATETIME()` | 38 usos | `TIMESTAMP` | 🟡 Ajuste de sintaxis |
| `YEAR()` | 33 usos | `EXTRACT(YEAR FROM date)` | 🟡 Ajuste menor |
| `MONTH()` | 21 usos | `EXTRACT(MONTH FROM date)` | 🟡 Ajuste menor |
| `TRIM()` | 15 usos | `TRIM / BTRIM` | 🟡 Ajuste menor |
| `CURRENT()` | 11 usos | `NOW() / CURRENT_TIMESTAMP` | 🟡 Ajuste menor |
| `DBINFO()` | 8 usos | `txid_current() / session_user` | 🔴 Sin equiv. directo |
| `MDY()` | 8 usos | `MAKE_DATE(y,m,d)` | 🟡 Ajuste menor |
| `TODAY()` | 6 usos | `CURRENT_DATE` | 🟢 Directo |

---
## Matriz de impacto en cutover

| Dependencia | ¿Bloquea cutover? | Plan de continuidad | Owner |
|------------|-------------------|---------------------|-------|
| IBM Informix IDS | ✅ SÍ (es el motor) | Aurora PostgreSQL 15+ | DBA + Cloud Architect |
| Scheduler AIX | ✅ SÍ (batch jobs) | AWS EventBridge Scheduler | DevOps / Infra |
| `BDICOBRANZA` cross-DB | ✅ SÍ si no tiene API | API interna de `BDICOBRANZAService` | Architect AM |
| `BDINTEG` cross-DB | ✅ SÍ si no tiene API | API interna de `BDINTEGService` | Architect AM |
| `Bdicobranza` cross-DB | ✅ SÍ si no tiene API | API interna de `BDICOBRANZAService` | Architect AM |
| `Bdinteg` cross-DB | ✅ SÍ si no tiene API | API interna de `BDINTEGService` | Architect AM |
| `bdiaclaracion` cross-DB | ✅ SÍ si no tiene API | API interna de `AclaracionesService` | Architect AM |
| Agencias de cobranza externas | 🟡 Parcial | Evaluar reemplazo o mantener integración | Architect AM |
| Buró de Crédito (reporte negativo) | 🟡 Parcial | Evaluar reemplazo o mantener integración | Architect AM |
| CONDUSEF (queja) | 🟡 Parcial | Evaluar reemplazo o mantener integración | Architect AM |
| Built-ins SPL | 🟡 Parcial (reescritura) | Mapping en capa de aplicación | Dev Team |


---
*Generado por: Specialist — Informix SPL Analysis · 2026-07-03 · Evidencia: source/BCOPCore/informix/bdicobranza_*.sql (análisis estático de 70 archivos SQL) · análisis estático de archivos SQL*

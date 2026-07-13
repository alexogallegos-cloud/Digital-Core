# D02 · Integración y Autenticación — Dependencias Externas y Terceros

> **Componente:** BCOPCore · SPE-AM-001 · Etapa 1
> **Base de datos:** `bdinteg` · IBM Informix IDS 14.10 / POWER-AIX
> **Wave:** Wave 5 · Riesgo: **CRÍTICO**
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
| DEP-03 | `BDICHEQ` (BDICHEQ) | Cross-DB call (dominio interno) | 🟡 MEDIA | 1 SPs hacen cross-DB |
| DEP-04 | `BDINTEG` (BDINTEG) | Cross-DB call (dominio interno) | 🟠 ALTA | 4 SPs hacen cross-DB |
| DEP-05 | `BDISITESP` (BDISITESP) | Cross-DB call (dominio interno) | 🟡 MEDIA | 1 SPs hacen cross-DB |
| DEP-06 | `BdInteg` (BDINTEG) | Cross-DB call (dominio interno) | 🟡 MEDIA | 1 SPs hacen cross-DB |
| DEP-07 | `bdibei` (BDIBEI) | Cross-DB call (dominio interno) | 🟡 MEDIA | 1 SPs hacen cross-DB |
| DEP-08 | `bdibpi` (BDIBPI) | Cross-DB call (dominio interno) | 🟠 ALTA | 7 SPs hacen cross-DB |
| DEP-09 | `bdicheq` (Cheques/Cuentas) | Cross-DB call (dominio interno) | 🔴 CRÍTICA | 16 SPs hacen cross-DB |
| DEP-10 | `bdicntchq` (BDICNTCHQ) | Cross-DB call (dominio interno) | 🟡 MEDIA | 1 SPs hacen cross-DB |
| DEP-11 | `bdicobranza` (Cobranza) | Cross-DB call (dominio interno) | 🟡 MEDIA | 1 SPs hacen cross-DB |
| DEP-12 | `bdicont` (Contabilidad) | Cross-DB call (dominio interno) | 🟡 MEDIA | 3 SPs hacen cross-DB |
| DEP-13 | `bdicred` (Créditos) | Cross-DB call (dominio interno) | 🔴 CRÍTICA | 15 SPs hacen cross-DB |
| DEP-14 | `bdidomi` (BDIDOMI) | Cross-DB call (dominio interno) | 🟡 MEDIA | 1 SPs hacen cross-DB |
| DEP-15 | `bdilide` (LIDE) | Cross-DB call (dominio interno) | 🟡 MEDIA | 2 SPs hacen cross-DB |
| DEP-16 | `bdinteg` (Integración/Auth) | Cross-DB call (dominio interno) | 🔴 CRÍTICA | 56 SPs hacen cross-DB |
| DEP-17 | `bdinvers` (BDINVERS) | Cross-DB call (dominio interno) | 🔴 CRÍTICA | 11 SPs hacen cross-DB |
| DEP-18 | `bdiprog` (BDIPROG) | Cross-DB call (dominio interno) | 🟡 MEDIA | 2 SPs hacen cross-DB |
| DEP-19 | `bdiprospectos` (BDIPROSPECTOS) | Cross-DB call (dominio interno) | 🟡 MEDIA | 2 SPs hacen cross-DB |
| DEP-20 | `bdisac` (Saldos/Cuentas) | Cross-DB call (dominio interno) | 🟡 MEDIA | 2 SPs hacen cross-DB |
| DEP-21 | `bdisitesp` (BDISITESP) | Cross-DB call (dominio interno) | 🟡 MEDIA | 2 SPs hacen cross-DB |
| DEP-22 | `bdisolic` (Solicitudes) | Cross-DB call (dominio interno) | 🟠 ALTA | 8 SPs hacen cross-DB |
| DEP-23 | `bdispeua` (BDISPEUA) | Cross-DB call (dominio interno) | 🟡 MEDIA | 3 SPs hacen cross-DB |
| DEP-24 | `bditarjcop` (BDITARJCOP) | Cross-DB call (dominio interno) | 🟡 MEDIA | 2 SPs hacen cross-DB |
| DEP-25 | `bditransfer` (BDITRANSFER) | Cross-DB call (dominio interno) | 🟡 MEDIA | 3 SPs hacen cross-DB |
| DEP-26 | `intercard` (Intercard (POS/ATM)) | Cross-DB call (dominio interno) | 🟠 ALTA | 5 SPs hacen cross-DB |
| DEP-27 | `sysmaster` (Sysmaster (Informix interno)) | Cross-DB call (dominio interno) | 🟠 ALTA | 10 SPs hacen cross-DB |
| DEP-28 | Buró de Crédito (CIEC) | Sistema externo | 🟠 ALTA | Detectado en comentarios / nombres de SP |
| DEP-29 | RENAPO (CURP) | Sistema externo | 🟠 ALTA | Detectado en comentarios / nombres de SP |
| DEP-30 | SAT (RFC) | Sistema externo | 🟠 ALTA | Detectado en comentarios / nombres de SP |
| DEP-31 | Banxico (CLABE) | Sistema externo | 🔴 CRÍTICA | Detectado en comentarios / nombres de SP |

---
## DEP-01 · IBM Informix IDS 14.10 — Motor de BD (a reemplazar)

**Criticidad:** 🔴 CRÍTICA — todo el dominio `bdinteg` es SPL nativo de Informix.

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

**Criticidad:** 🔴 CRÍTICA — 56 SPs de `bdinteg` hacen cross-DB call

| SP de `bdinteg` | Tablas accedidas en `bdinteg` | Tipo |
|----|----|----|  
| `sp_activausuario_bpi` | `bdinteg:si_bpiusuarios`, `bdinteg:si_cambiostcte`, `bdinteg:` | R |
| `sp_actbex` | `bdinteg:si_telefonos`, `bdinteg:bitacora_activacion_bex` | R |
| `sp_actualiza_identifi` | `bdinteg:` | R |
| `sp_actualiza_lugarnac` | `bdinteg:` | R |
| `sp_actualiza_id_consulta_pdf` | `bdinteg:` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `Integración/AuthService`. Requiere definir contrato OpenAPI.

### `bdicheq` — Cheques/Cuentas

**Criticidad:** 🔴 CRÍTICA — 16 SPs de `bdinteg` hacen cross-DB call

| SP de `bdinteg` | Tablas accedidas en `bdicheq` | Tipo |
|----|----|----|  
| `sp_actbex` | `bdicheq:` | R |
| `sp_actualiza_cta_calificacion` | `bdicheq:` | R |
| `sp_actualiza_info_cliente_opt` | `bdicheq:sc_movhis_old`, `bdicheq:`, `bdicheq:sc_movhis` | R |
| `sp_actualiza_act_subact` | `bdicheq:` | R |
| `sp_acivarserviciobpi_apolo` | `bdicheq:`, `bdicheq:sc_tarjeta`, `bdicheq:sc_maechq` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `Cheques/CuentasService`. Requiere definir contrato OpenAPI.

### `bdicred` — Créditos

**Criticidad:** 🔴 CRÍTICA — 15 SPs de `bdinteg` hacen cross-DB call

| SP de `bdinteg` | Tablas accedidas en `bdicred` | Tipo |
|----|----|----|  
| `sp_actbex` | `bdicred:` | R |
| `sp_actualiza_cta_calificacion` | `bdicred:` | R |
| `sp_actualiza_info_cliente_opt` | `bdicred:sd_movdia`, `bdicred:`, `bdicred:sd_maecred` | R |
| `sp_actualiza_lugarnac` | `bdicred:` | R |
| `sp_acivarserviciobpi_apolo` | `bdicred:sd_definicion`, `bdicred:`, `bdicred:sd_maecred` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `CréditosService`. Requiere definir contrato OpenAPI.

### `bdinvers` — BDINVERS

**Criticidad:** 🔴 CRÍTICA — 11 SPs de `bdinteg` hacen cross-DB call

| SP de `bdinteg` | Tablas accedidas en `bdinvers` | Tipo |
|----|----|----|  
| `sp_actualiza_identifi` | `bdinvers:sv_movhis`, `bdinvers:sv_ctascontinv` | R |
| `sp_actualiza_cta_calificacion` | `bdinvers:` | R |
| `sp_actualiza_info_cliente_opt` | `bdinvers:sv_movdia`, `bdinvers:sv_maeinv`, `bdinvers:sv_movhis` | R |
| `sp_actualiza_act_subact` | `bdinvers:` | R |
| `sp_acivarserviciobpi_apolo` | `bdinvers:`, `bdinvers:sv_maeinv` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `BDINVERSService`. Requiere definir contrato OpenAPI.

### `sysmaster` — Sysmaster (Informix interno)

**Criticidad:** 🟠 ALTA — 10 SPs de `bdinteg` hacen cross-DB call

| SP de `bdinteg` | Tablas accedidas en `sysmaster` | Tipo |
|----|----|----|  
| `sp_actualiza_estadoine` | `sysmaster:` | R |
| `sp_actualiza_premio` | `sysmaster:sysshmvals` | R |
| `sp_activarserviciobm` | `sysmaster:sysshmvals` | R |
| `sp_actualiza_info_cliente` | `sysmaster:sysshmvals` | R |
| `sp_actualiza_calle` | `sysmaster:sysshmvals` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `Sysmaster (Informix interno)Service`. Requiere definir contrato OpenAPI.

### `bdisolic` — Solicitudes

**Criticidad:** 🟠 ALTA — 8 SPs de `bdinteg` hacen cross-DB call

| SP de `bdinteg` | Tablas accedidas en `bdisolic` | Tipo |
|----|----|----|  
| `sp_actualiza_identifi` | `bdisolic:` | R |
| `sp_actualiza_info_cliente_opt` | `bdisolic:` | R |
| `sp_actualiza_premio` | `bdisolic:` | R |
| `alta_sol_tc_cjunk` | `bdisolic:` | R |
| `sp_actualiza_info_cliente` | `bdisolic:` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `SolicitudesService`. Requiere definir contrato OpenAPI.

### `bdibpi` — BDIBPI

**Criticidad:** 🟠 ALTA — 7 SPs de `bdinteg` hacen cross-DB call

| SP de `bdinteg` | Tablas accedidas en `bdibpi` | Tipo |
|----|----|----|  
| `sp_actbex` | `bdibpi:bpi_activacion_bex` | R |
| `sp_acivarserviciobpi` | `bdibpi:` | R |
| `sp_actualiza_numerocalle` | `bdibpi:` | R |
| `bm_nuevo_usuario` | `bdibpi:` | R |
| `sp_activarserviciobm` | `bdibpi:` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `BDIBPIService`. Requiere definir contrato OpenAPI.

### `intercard` — Intercard (POS/ATM)

**Criticidad:** 🟠 ALTA — 5 SPs de `bdinteg` hacen cross-DB call

| SP de `bdinteg` | Tablas accedidas en `intercard` | Tipo |
|----|----|----|  
| `sp_actbex` | `intercard:tarjeta` | R |
| `sp_actualiza_cta_calificacion` | `intercard:` | R |
| `sp_acivarserviciobpi_apolo` | `intercard:tarjeta`, `intercard:statustarjeta` | R |
| `sp_actualiza_id_consulta_pdf` | `intercard:` | R |
| `sp_actualiza_campos_uh` | `intercard:` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `Intercard (POS/ATM)Service`. Requiere definir contrato OpenAPI.

### `BDINTEG` — BDINTEG

**Criticidad:** 🟠 ALTA — 4 SPs de `bdinteg` hacen cross-DB call

| SP de `bdinteg` | Tablas accedidas en `BDINTEG` | Tipo |
|----|----|----|  
| `sp_actualiza_numerocalle` | `BDINTEG:si_catzonas` | R |
| `sp_actstatusctecopnvoparam_club` | `BDINTEG:SI_CLIENTE`, `BDINTEG:`, `BDINTEG:SI_FUSCLIENTE` | R |
| `sp_acivarserviciobpi` | `BDINTEG:si_catzonas` | R |
| `sp_actcatalogos_sitesp` | `BDINTEG:SI_ESTADOS`, `BDINTEG:SI_CATCALLES`, `BDINTEG:SI_CATCIUDADES` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `BDINTEGService`. Requiere definir contrato OpenAPI.

### `bditransfer` — BDITRANSFER

**Criticidad:** 🟡 MEDIA — 3 SPs de `bdinteg` hacen cross-DB call

| SP de `bdinteg` | Tablas accedidas en `bditransfer` | Tipo |
|----|----|----|  
| `sp_acivarserviciobpi_apolo` | `bditransfer:tf_account_balance_customer`, `bditransfer:tf_maecte`, `bditransfer:` | R |
| `sp_actualiza_campos_uh` | `bditransfer:tf_maecte` | R |
| `sp_actualiza_info_cliente_opt` | `bditransfer:tf_maecte` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `BDITRANSFERService`. Requiere definir contrato OpenAPI.

### `bdispeua` — BDISPEUA

**Criticidad:** 🟡 MEDIA — 3 SPs de `bdinteg` hacen cross-DB call

| SP de `bdinteg` | Tablas accedidas en `bdispeua` | Tipo |
|----|----|----|  
| `actividad` | `bdispeua:sp_pagoenviar` | R |
| `alta_nip` | `bdispeua:sp_pagoenviar` | R |
| `act_encab` | `bdispeua:sp_pagoenviar` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `BDISPEUAService`. Requiere definir contrato OpenAPI.

### `bdicont` — Contabilidad

**Criticidad:** 🟡 MEDIA — 3 SPs de `bdinteg` hacen cross-DB call

| SP de `bdinteg` | Tablas accedidas en `bdicont` | Tipo |
|----|----|----|  
| `actividad` | `bdicont:co_poliza`, `bdicont:co_detpol` | R |
| `alta_nip` | `bdicont:co_poliza`, `bdicont:co_detpol` | R |
| `act_encab` | `bdicont:co_poliza`, `bdicont:co_detpol` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `ContabilidadService`. Requiere definir contrato OpenAPI.

### `bdilide` — LIDE

**Criticidad:** 🟡 MEDIA — 2 SPs de `bdinteg` hacen cross-DB call

| SP de `bdinteg` | Tablas accedidas en `bdilide` | Tipo |
|----|----|----|  
| `sp_actualiza_campos_uh` | `bdilide:`, `bdilide:sl_detlide`, `bdilide:sl_retlide` | R |
| `sp_actnomcterfcalterno` | `bdilide:` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `LIDEService`. Requiere definir contrato OpenAPI.

### `bdisac` — Saldos/Cuentas

**Criticidad:** 🟡 MEDIA — 2 SPs de `bdinteg` hacen cross-DB call

| SP de `bdinteg` | Tablas accedidas en `bdisac` | Tipo |
|----|----|----|  
| `sp_actstatusctecopnvoparam_club` | `bdisac:` | R |
| `actualiza_indicadores` | `bdisac:sac_fechas` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `Saldos/CuentasService`. Requiere definir contrato OpenAPI.

### `bdisitesp` — BDISITESP

**Criticidad:** 🟡 MEDIA — 2 SPs de `bdinteg` hacen cross-DB call

| SP de `bdinteg` | Tablas accedidas en `bdisitesp` | Tipo |
|----|----|----|  
| `sp_actualiza_campos_uh` | `bdisitesp:se_catsitesp`, `bdisitesp:se_ctessitespcte_his`, `bdisitesp:se_ctessitespcte` | R |
| `sp_actualiza_curp` | `bdisitesp:` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `BDISITESPService`. Requiere definir contrato OpenAPI.

### `bdiprog` — BDIPROG

**Criticidad:** 🟡 MEDIA — 2 SPs de `bdinteg` hacen cross-DB call

| SP de `bdinteg` | Tablas accedidas en `bdiprog` | Tipo |
|----|----|----|  
| `actualizaguardaconyuge_cjunk` | `bdiprog:` | R |
| `sp_actualiza_campos_uh` | `bdiprog:` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `BDIPROGService`. Requiere definir contrato OpenAPI.

### `bditarjcop` — BDITARJCOP

**Criticidad:** 🟡 MEDIA — 2 SPs de `bdinteg` hacen cross-DB call

| SP de `bdinteg` | Tablas accedidas en `bditarjcop` | Tipo |
|----|----|----|  
| `sp_actualiza_premio` | `bditarjcop:` | R |
| `sp_actualiza_info_cliente` | `bditarjcop:` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `BDITARJCOPService`. Requiere definir contrato OpenAPI.

### `bdiprospectos` — BDIPROSPECTOS

**Criticidad:** 🟡 MEDIA — 2 SPs de `bdinteg` hacen cross-DB call

| SP de `bdinteg` | Tablas accedidas en `bdiprospectos` | Tipo |
|----|----|----|  
| `sp_actualiza_premio` | `bdiprospectos:` | R |
| `sp_actualiza_info_cliente` | `bdiprospectos:` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `BDIPROSPECTOSService`. Requiere definir contrato OpenAPI.

### `bdicobranza` — Cobranza

**Criticidad:** 🟡 MEDIA — 1 SPs de `bdinteg` hacen cross-DB call

| SP de `bdinteg` | Tablas accedidas en `bdicobranza` | Tipo |
|----|----|----|  
| `sp_actnomcterfcalterno` | `bdicobranza:cb_param` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `CobranzaService`. Requiere definir contrato OpenAPI.

### `BDICHEQ` — BDICHEQ

**Criticidad:** 🟡 MEDIA — 1 SPs de `bdinteg` hacen cross-DB call

| SP de `bdinteg` | Tablas accedidas en `BDICHEQ` | Tipo |
|----|----|----|  
| `sp_actstatusctecopnvoparam_club` | `BDICHEQ:` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `BDICHEQService`. Requiere definir contrato OpenAPI.

### `BdInteg` — BDINTEG

**Criticidad:** 🟡 MEDIA — 1 SPs de `bdinteg` hacen cross-DB call

| SP de `bdinteg` | Tablas accedidas en `BdInteg` | Tipo |
|----|----|----|  
| `sp_actstatusctecopnvoparam_club` | `BdInteg:tmpxmlarchclientecoppel` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `BDINTEGService`. Requiere definir contrato OpenAPI.

### `BDISITESP` — BDISITESP

**Criticidad:** 🟡 MEDIA — 1 SPs de `bdinteg` hacen cross-DB call

| SP de `bdinteg` | Tablas accedidas en `BDISITESP` | Tipo |
|----|----|----|  
| `sp_actualiza_bitacora_ine` | `BDISITESP:SE_CTESSITESPCTE` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `BDISITESPService`. Requiere definir contrato OpenAPI.

### `bdidomi` — BDIDOMI

**Criticidad:** 🟡 MEDIA — 1 SPs de `bdinteg` hacen cross-DB call

| SP de `bdinteg` | Tablas accedidas en `bdidomi` | Tipo |
|----|----|----|  
| `sp_actualiza_campos_uh` | `bdidomi:` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `BDIDOMIService`. Requiere definir contrato OpenAPI.

### `bdicntchq` — BDICNTCHQ

**Criticidad:** 🟡 MEDIA — 1 SPs de `bdinteg` hacen cross-DB call

| SP de `bdinteg` | Tablas accedidas en `bdicntchq` | Tipo |
|----|----|----|  
| `sp_actualiza_campos_uh` | `bdicntchq:` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `BDICNTCHQService`. Requiere definir contrato OpenAPI.

### `bdibei` — BDIBEI

**Criticidad:** 🟡 MEDIA — 1 SPs de `bdinteg` hacen cross-DB call

| SP de `bdinteg` | Tablas accedidas en `bdibei` | Tipo |
|----|----|----|  
| `sp_actualiza_id_consulta_pdf` | `bdibei:` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `BDIBEIService`. Requiere definir contrato OpenAPI.

---
## Funciones Built-in de Informix (sin equivalente directo en PostgreSQL)

| Función Informix | Usos detectados | Equivalente PostgreSQL | Riesgo |
|-----------------|-----------------|----------------------|--------|
| `NVL()` | 75 usos | `COALESCE` | 🟡 Ajuste menor |
| `TRIM()` | 67 usos | `TRIM / BTRIM` | 🟡 Ajuste menor |
| `CURRENT()` | 47 usos | `NOW() / CURRENT_TIMESTAMP` | 🟡 Ajuste menor |
| `YEAR()` | 40 usos | `EXTRACT(YEAR FROM date)` | 🟡 Ajuste menor |
| `DATETIME()` | 35 usos | `TIMESTAMP` | 🟡 Ajuste de sintaxis |
| `DBINFO()` | 9 usos | `txid_current() / session_user` | 🔴 Sin equiv. directo |
| `MDY()` | 8 usos | `MAKE_DATE(y,m,d)` | 🟡 Ajuste menor |
| `EXTEND()` | 7 usos | `CAST(x AS TIMESTAMP(n))` | 🟡 Ajuste menor |
| `TODAY()` | 5 usos | `CURRENT_DATE` | 🟢 Directo |

---
## Matriz de impacto en cutover

| Dependencia | ¿Bloquea cutover? | Plan de continuidad | Owner |
|------------|-------------------|---------------------|-------|
| IBM Informix IDS | ✅ SÍ (es el motor) | Aurora PostgreSQL 15+ | DBA + Cloud Architect |
| Scheduler AIX | ✅ SÍ (batch jobs) | AWS EventBridge Scheduler | DevOps / Infra |
| `BDICHEQ` cross-DB | ✅ SÍ si no tiene API | API interna de `BDICHEQService` | Architect AM |
| `BDINTEG` cross-DB | ✅ SÍ si no tiene API | API interna de `BDINTEGService` | Architect AM |
| `BDISITESP` cross-DB | ✅ SÍ si no tiene API | API interna de `BDISITESPService` | Architect AM |
| `BdInteg` cross-DB | ✅ SÍ si no tiene API | API interna de `BDINTEGService` | Architect AM |
| `bdibei` cross-DB | ✅ SÍ si no tiene API | API interna de `BDIBEIService` | Architect AM |
| Buró de Crédito (CIEC) | 🟡 Parcial | Evaluar reemplazo o mantener integración | Architect AM |
| RENAPO (CURP) | 🟡 Parcial | Evaluar reemplazo o mantener integración | Architect AM |
| SAT (RFC) | 🟡 Parcial | Evaluar reemplazo o mantener integración | Architect AM |
| Built-ins SPL | 🟡 Parcial (reescritura) | Mapping en capa de aplicación | Dev Team |


---
*Generado por: Specialist — Informix SPL Analysis · 2026-07-03 · Evidencia: source/BCOPCore/informix/bdinteg_*.sql (análisis estático de 70 archivos SQL) · análisis estático de archivos SQL*

# D05 · Saldos y Cuentas — Dependencias Externas y Terceros

> **Componente:** BCOPCore · SPE-AM-001 · Etapa 1
> **Base de datos:** `bdisac` · IBM Informix IDS 14.10 / POWER-AIX
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
| DEP-03 | `BDISAC` (BDISAC) | Cross-DB call (dominio interno) | 🟠 ALTA | 6 SPs hacen cross-DB |
| DEP-04 | `BdiCheq` (BDICHEQ) | Cross-DB call (dominio interno) | 🟡 MEDIA | 2 SPs hacen cross-DB |
| DEP-05 | `BdiSac` (BDISAC) | Cross-DB call (dominio interno) | 🟡 MEDIA | 2 SPs hacen cross-DB |
| DEP-06 | `Bdisac` (BDISAC) | Cross-DB call (dominio interno) | 🟡 MEDIA | 2 SPs hacen cross-DB |
| DEP-07 | `bdiauditor` (BDIAUDITOR) | Cross-DB call (dominio interno) | 🟠 ALTA | 9 SPs hacen cross-DB |
| DEP-08 | `bdicheq` (Cheques/Cuentas) | Cross-DB call (dominio interno) | 🔴 CRÍTICA | 22 SPs hacen cross-DB |
| DEP-09 | `bdicont` (Contabilidad) | Cross-DB call (dominio interno) | 🟡 MEDIA | 2 SPs hacen cross-DB |
| DEP-10 | `bdicred` (Créditos) | Cross-DB call (dominio interno) | 🟠 ALTA | 8 SPs hacen cross-DB |
| DEP-11 | `bdinteg` (Integración/Auth) | Cross-DB call (dominio interno) | 🔴 CRÍTICA | 31 SPs hacen cross-DB |
| DEP-12 | `bdisac` (Saldos/Cuentas) | Cross-DB call (dominio interno) | 🔴 CRÍTICA | 48 SPs hacen cross-DB |
| DEP-13 | `bdisitesp` (BDISITESP) | Cross-DB call (dominio interno) | 🟡 MEDIA | 3 SPs hacen cross-DB |
| DEP-14 | `bdisolic` (Solicitudes) | Cross-DB call (dominio interno) | 🟡 MEDIA | 1 SPs hacen cross-DB |
| DEP-15 | `sysmaster` (Sysmaster (Informix interno)) | Cross-DB call (dominio interno) | 🟡 MEDIA | 1 SPs hacen cross-DB |
| DEP-16 | SmartVista (inversiones) | Sistema externo | ALTA | Detectado en comentarios / nombres de SP |
| DEP-17 | Western Union (remesas) | Sistema externo | ALTA | Detectado en comentarios / nombres de SP |
| DEP-18 | SOFOM (productos SAC) | Sistema externo | ALTA | Detectado en comentarios / nombres de SP |
| DEP-19 | APPRIZA — CFPA (Confirmación Fondos Para Acreditación) | Sistema externo — remesas internacionales | CRITICA | Logs producción 2026-04-24 · P655-R003 |

---

## DEP-19 · APPRIZA — Confirmación de Fondos Para Acreditación (CFPA)

> **Fuente:** `source/logs/transacciones_bus_20260424_*.log` · Incorporado: 2026-08-01

**Criticidad:** CRITICA — integración obligatoria para toda remesa internacional. Sin confirmación APPRIZA la remesa queda en estado PENDIENTE indefinido.

| Atributo | Valor |
|----------|-------|
| Tipo | Sistema externo de confirmación de remesas internacionales (CFPA) |
| Protocolo | HTTP/SOAP vía ESB BanCoppel |
| SP que lo invoca | `sp_app_confirmpayment` (DSN: `ifx_bdisac_remesas`) |
| Job batch que lo usa | `RemesasAPPRIZAAutomaticas` (ver BATCH-D05-01 en 11-batch-processes.md) |
| Volumen producción | 61,280 llamadas/día · 8.7% tasa de error |
| Códigos de respuesta | `0000` = éxito CFPA confirmada · `9999` = error inesperado |
| UUID de sesión | `22e4e9ee-32ea-484e-b89f-2573549bc625` fijo en todas las llamadas batch |
| Problema SSL conocido | `RemesasAPPRIZACanalesExternos` sufre timeouts ~30s (código ESB 3165, 7 instancias/hora) |
| Riesgo regulatorio | Banxico Circular 14/2017 — notificar fallo en transferencias al exterior en máx. 2 días hábiles |

**Impacto de fallo:**
El cliente ya fue debitado. El destinatario no recibe fondos. La remesa queda `PENDIENTE` en `sp_app_recordorder` sin notificación automática ni devolución. Aprox. 400 clientes afectados por día.

**Plan de mitigación para target:**
1. Circuit breaker (Resilience4j) para llamadas a APPRIZA
2. `max_retries=3` con backoff exponencial en el batch
3. Tabla `reconciliacion_remesas` para pendientes que superen max_retries
4. Notificación automática al cliente y flag regulatorio CNBV al exceder plazo
5. Validar con APPRIZA si el UUID compartido es el diseño correcto de autenticación batch

---
## DEP-01 · IBM Informix IDS 14.10 — Motor de BD (a reemplazar)

**Criticidad:** 🔴 CRÍTICA — todo el dominio `bdisac` es SPL nativo de Informix.

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

### `bdisac` — Saldos/Cuentas

**Criticidad:** 🔴 CRÍTICA — 48 SPs de `bdisac` hacen cross-DB call

| SP de `bdisac` | Tablas accedidas en `bdisac` | Tipo |
|----|----|----|  
| `sp_actualizafechassac` | `bdisac:sac_fechas`, `bdisac:sac_movimientosdetalle`, `bdisac:sac_movimientos` | R |
| `sp_alta_cardif` | `bdisac:` | R |
| `sp_app_recuperapayment` | `bdisac:sac_fechas`, `bdisac:`, `bdisac:sac_convenios` | R |
| `sp_actualiza_cte_remesa` | `bdisac:` | R |
| `sp_bitacoragdf` | `bdisac:`, `bdisac:sac_enviosdineroya`, `bdisac:sac_param` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `Saldos/CuentasService`. Requiere definir contrato OpenAPI.

### `bdinteg` — Integración/Auth

**Criticidad:** 🔴 CRÍTICA — 31 SPs de `bdisac` hacen cross-DB call

| SP de `bdisac` | Tablas accedidas en `bdinteg` | Tipo |
|----|----|----|  
| `sp_actualizafechassac` | `bdinteg:si_feriado` | R |
| `sp_app_recuperapayment` | `bdinteg:` | R |
| `sp_actualiza_cte_remesa` | `bdinteg:` | R |
| `sp_bitacoragdf` | `bdinteg:si_feriado_banca` | R |
| `sp_app_valmonto_aut` | `bdinteg:` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `Integración/AuthService`. Requiere definir contrato OpenAPI.

### `bdicheq` — Cheques/Cuentas

**Criticidad:** 🔴 CRÍTICA — 22 SPs de `bdisac` hacen cross-DB call

| SP de `bdisac` | Tablas accedidas en `bdicheq` | Tipo |
|----|----|----|  
| `sp_actualizafechassac` | `bdicheq:` | R |
| `sp_app_recuperapayment` | `bdicheq:sc_movdia` | R |
| `sp_bitacoragdf` | `bdicheq:`, `bdicheq:sc_maechq`, `bdicheq:sc_movdia` | R |
| `sp_app_valmonto_aut` | `bdicheq:` | R |
| `sp_app_aplicapagos_cred` | `bdicheq:` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `Cheques/CuentasService`. Requiere definir contrato OpenAPI.

### `bdiauditor` — BDIAUDITOR

**Criticidad:** 🟠 ALTA — 9 SPs de `bdisac` hacen cross-DB call

| SP de `bdisac` | Tablas accedidas en `bdiauditor` | Tipo |
|----|----|----|  
| `sp_app_recuperapayment` | `bdiauditor:` | R |
| `sp_asignaanio` | `bdiauditor:` | R |
| `sp_app_valmonto_aut` | `bdiauditor:` | R |
| `sp_app_valmonto_cpl` | `bdiauditor:` | R |
| `sp_aplica_pago_con_cargo_msw` | `bdiauditor:` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `BDIAUDITORService`. Requiere definir contrato OpenAPI.

### `bdicred` — Créditos

**Criticidad:** 🟠 ALTA — 8 SPs de `bdisac` hacen cross-DB call

| SP de `bdisac` | Tablas accedidas en `bdicred` | Tipo |
|----|----|----|  
| `sp_app_recuperapayment` | `bdicred:sd_movdia` | R |
| `sp_asignacuenta_edomex` | `bdicred:` | R |
| `sp_actualiza_sac_bts_sdep` | `bdicred:sd_movdia`, `bdicred:sd_movhis` | R |
| `sp_aplica_pago_con_cargo_msw` | `bdicred:sd_movdia` | R |
| `sp_asignaanio` | `bdicred:sd_movdia`, `bdicred:sd_movhis` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `CréditosService`. Requiere definir contrato OpenAPI.

### `BDISAC` — BDISAC

**Criticidad:** 🟠 ALTA — 6 SPs de `bdisac` hacen cross-DB call

| SP de `bdisac` | Tablas accedidas en `BDISAC` | Tipo |
|----|----|----|  
| `sp_altascambioscentral_pba` | `BDISAC:sac_convenios` | R |
| `sp_actualizastatusconvenio` | `BDISAC:sac_convenios` | R |
| `sp_actualizaregsuc` | `BDISAC:sac_convenios` | R |
| `sp_actualizastatusconvenio_pba` | `BDISAC:sac_convenios` | R |
| `sp_asignaanio` | `BDISAC:` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `BDISACService`. Requiere definir contrato OpenAPI.

### `bdisitesp` — BDISITESP

**Criticidad:** 🟡 MEDIA — 3 SPs de `bdisac` hacen cross-DB call

| SP de `bdisac` | Tablas accedidas en `bdisitesp` | Tipo |
|----|----|----|  
| `sp_app_valmonto_cpl` | `bdisitesp:` | R |
| `sp_asignaanio` | `bdisitesp:` | R |
| `sp_asignaaniopredial` | `bdisitesp:` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `BDISITESPService`. Requiere definir contrato OpenAPI.

### `BdiCheq` — BDICHEQ

**Criticidad:** 🟡 MEDIA — 2 SPs de `bdisac` hacen cross-DB call

| SP de `bdisac` | Tablas accedidas en `BdiCheq` | Tipo |
|----|----|----|  
| `sp_app_getorder` | `BdiCheq:Sc_Bines`, `BdiCheq:Sc_Fechas`, `BdiCheq:Sc_MovHis` | R |
| `sp_app_confirmorder` | `BdiCheq:Sc_Bines`, `BdiCheq:Sc_Fechas`, `BdiCheq:Sc_MovHis` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `BDICHEQService`. Requiere definir contrato OpenAPI.

### `BdiSac` — BDISAC

**Criticidad:** 🟡 MEDIA — 2 SPs de `bdisac` hacen cross-DB call

| SP de `bdisac` | Tablas accedidas en `BdiSac` | Tipo |
|----|----|----|  
| `sp_app_getorder` | `BdiSac:Sac_EGlobal_Detalle`, `BdiSac:Sac_EGlobal_Banco`, `BdiSac:Sac_EGlobal_Encabezado` | R |
| `sp_app_confirmorder` | `BdiSac:Sac_EGlobal_Detalle`, `BdiSac:Sac_EGlobal_Banco`, `BdiSac:Sac_EGlobal_Encabezado` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `BDISACService`. Requiere definir contrato OpenAPI.

### `Bdisac` — BDISAC

**Criticidad:** 🟡 MEDIA — 2 SPs de `bdisac` hacen cross-DB call

| SP de `bdisac` | Tablas accedidas en `Bdisac` | Tipo |
|----|----|----|  
| `sp_app_mensajes` | `Bdisac:` | R |
| `sp_app_submitpayreversal` | `Bdisac:` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `BDISACService`. Requiere definir contrato OpenAPI.

### `bdicont` — Contabilidad

**Criticidad:** 🟡 MEDIA — 2 SPs de `bdisac` hacen cross-DB call

| SP de `bdisac` | Tablas accedidas en `bdicont` | Tipo |
|----|----|----|  
| `sp_app_recordorder` | `bdicont:co_sdodias` | R |
| `sp_bitacoragdf` | `bdicont:co_sdodias` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `ContabilidadService`. Requiere definir contrato OpenAPI.

### `sysmaster` — Sysmaster (Informix interno)

**Criticidad:** 🟡 MEDIA — 1 SPs de `bdisac` hacen cross-DB call

| SP de `bdisac` | Tablas accedidas en `sysmaster` | Tipo |
|----|----|----|  
| `sp_actualiza_datos` | `sysmaster:` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `Sysmaster (Informix interno)Service`. Requiere definir contrato OpenAPI.

### `bdisolic` — Solicitudes

**Criticidad:** 🟡 MEDIA — 1 SPs de `bdisac` hacen cross-DB call

| SP de `bdisac` | Tablas accedidas en `bdisolic` | Tipo |
|----|----|----|  
| `sp_app_obtieneinfoidentificacion` | `bdisolic:ss_solicitudes` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `SolicitudesService`. Requiere definir contrato OpenAPI.

---
## Funciones Built-in de Informix (sin equivalente directo en PostgreSQL)

| Función Informix | Usos detectados | Equivalente PostgreSQL | Riesgo |
|-----------------|-----------------|----------------------|--------|
| `NVL()` | 89 usos | `COALESCE` | 🟡 Ajuste menor |
| `TRIM()` | 67 usos | `TRIM / BTRIM` | 🟡 Ajuste menor |
| `CURRENT()` | 35 usos | `NOW() / CURRENT_TIMESTAMP` | 🟡 Ajuste menor |
| `TODAY()` | 25 usos | `CURRENT_DATE` | 🟢 Directo |
| `YEAR()` | 15 usos | `EXTRACT(YEAR FROM date)` | 🟡 Ajuste menor |
| `MONTH()` | 12 usos | `EXTRACT(MONTH FROM date)` | 🟡 Ajuste menor |
| `DATETIME()` | 11 usos | `TIMESTAMP` | 🟡 Ajuste de sintaxis |
| `MDY()` | 10 usos | `MAKE_DATE(y,m,d)` | 🟡 Ajuste menor |
| `DBINFO()` | 10 usos | `txid_current() / session_user` | 🔴 Sin equiv. directo |

---
## Matriz de impacto en cutover

| Dependencia | ¿Bloquea cutover? | Plan de continuidad | Owner |
|------------|-------------------|---------------------|-------|
| IBM Informix IDS | ✅ SÍ (es el motor) | Aurora PostgreSQL 15+ | DBA + Cloud Architect |
| Scheduler AIX | ✅ SÍ (batch jobs) | AWS EventBridge Scheduler | DevOps / Infra |
| `BDISAC` cross-DB | ✅ SÍ si no tiene API | API interna de `BDISACService` | Architect AM |
| `BdiCheq` cross-DB | ✅ SÍ si no tiene API | API interna de `BDICHEQService` | Architect AM |
| `BdiSac` cross-DB | ✅ SÍ si no tiene API | API interna de `BDISACService` | Architect AM |
| `Bdisac` cross-DB | ✅ SÍ si no tiene API | API interna de `BDISACService` | Architect AM |
| `bdiauditor` cross-DB | ✅ SÍ si no tiene API | API interna de `BDIAUDITORService` | Architect AM |
| SmartVista (inversiones) | 🟡 Parcial | Evaluar reemplazo o mantener integración | Architect AM |
| Western Union (remesas) | 🟡 Parcial | Evaluar reemplazo o mantener integración | Architect AM |
| SOFOM (productos SAC) | 🟡 Parcial | Evaluar reemplazo o mantener integración | Architect AM |
| Built-ins SPL | 🟡 Parcial (reescritura) | Mapping en capa de aplicación | Dev Team |


---
*Generado por: Specialist — Informix SPL Analysis · 2026-07-03 · Evidencia: source/BCOPCore/informix/bdisac_*.sql (análisis estático de 58 archivos SQL) · análisis estático de archivos SQL*

<!-- LOG-DATA-BEGIN -->
## Sistemas externos observados en logs — 2026-04-24
> Fuente: `source/logs/errores_bus_2026-04-24_*.txt` · Incorporado: 2026-08-01

| Sistema externo | Protocolo | Llamadas observadas | Notas |
|-----------------|-----------|---------------------|-------|
| APPRIZA — Canales Externos | SOAP/HTTPS | 2,525 | Servicio ESB: `RemesasAPPRIZACanalesExternos` |
| APPRIZA — CFPA | SOAP/HTTPS | 17,967 | Servicio ESB: `RemesasAPPRIZA` |
| Fábrica de Pagos ESB | SOAP/JNI | 256,336 | Servicio ESB: `FabricaPagoServicios` |
| APPRIZA — CFPA (batch) | SOAP/HTTPS | 182,786 | Servicio ESB: `RemesasAPPRIZAAutomaticas` |
| PostgreSQL Huellas (target migrado) | JDBC | 1 | Servicio ESB: `Huellas442` |

### Errores de comunicación con externos (SSL / timeout / JNI)

| Código | Descripción | Volumen/día | Servicios |
|--------|-------------|-------------|-----------|
| `3743` | Handle Timed-out — timeout en conexión SOAP/JNI con sis | 340 | Caja, Caja2, Caja3 |
| `3701` | Error en JNI Call — Axis2Invoker fallo de comunicación  | 331 | Caja, Caja2, CajaCliente |
| `3166` | SSL timeout — timeout durante operación TLS con endpoin | 7 | RemesasAPPRIZA, RemesasAPPRIZACanalesExternos |

*Generado por generate-kb-from-logs.py · 2026-08-01*
<!-- LOG-DATA-END -->

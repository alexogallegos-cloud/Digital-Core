# D04 · Cheques / Cuentas — Dependencias Externas y Terceros

> **Componente:** Informix · SPE-AM-001 · Etapa 1
> **Base de datos:** `bdicheq` · IBM Informix IDS 14.10 / POWER-AIX
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
| DEP-03 | `BDICHEQ` (BDICHEQ) | Cross-DB call (dominio interno) | 🟡 MEDIA | 2 SPs hacen cross-DB |
| DEP-04 | `BDICRED` (BDICRED) | Cross-DB call (dominio interno) | 🟡 MEDIA | 1 SPs hacen cross-DB |
| DEP-05 | `BDINTEG` (BDINTEG) | Cross-DB call (dominio interno) | 🟡 MEDIA | 1 SPs hacen cross-DB |
| DEP-06 | `bdiaclaracion` (Aclaraciones) | Cross-DB call (dominio interno) | 🟠 ALTA | 4 SPs hacen cross-DB |
| DEP-07 | `bdicheq` (Cheques/Cuentas) | Cross-DB call (dominio interno) | 🔴 CRÍTICA | 25 SPs hacen cross-DB |
| DEP-08 | `bdicntchq` (BDICNTCHQ) | Cross-DB call (dominio interno) | 🟡 MEDIA | 1 SPs hacen cross-DB |
| DEP-09 | `bdicred` (Créditos) | Cross-DB call (dominio interno) | 🟠 ALTA | 4 SPs hacen cross-DB |
| DEP-10 | `bdiedoelec` (BDIEDOELEC) | Cross-DB call (dominio interno) | 🟡 MEDIA | 1 SPs hacen cross-DB |
| DEP-11 | `bdinteg` (Integración/Auth) | Cross-DB call (dominio interno) | 🔴 CRÍTICA | 21 SPs hacen cross-DB |
| DEP-12 | `bdinvers` (BDINVERS) | Cross-DB call (dominio interno) | 🟡 MEDIA | 2 SPs hacen cross-DB |
| DEP-13 | `bdisac` (Saldos/Cuentas) | Cross-DB call (dominio interno) | 🟡 MEDIA | 3 SPs hacen cross-DB |
| DEP-14 | `bdisolic` (Solicitudes) | Cross-DB call (dominio interno) | 🟡 MEDIA | 2 SPs hacen cross-DB |
| DEP-15 | `bdispei` (SPEI) | Cross-DB call (dominio interno) | 🟠 ALTA | 6 SPs hacen cross-DB |
| DEP-16 | `bditransfer` (BDITRANSFER) | Cross-DB call (dominio interno) | 🟡 MEDIA | 3 SPs hacen cross-DB |
| DEP-17 | `sysmaster` (Sysmaster (Informix interno)) | Cross-DB call (dominio interno) | 🔴 CRÍTICA | 14 SPs hacen cross-DB |
| DEP-18 | SmartVista (tarjetas débito) | Sistema externo | 🟠 ALTA | Detectado en comentarios / nombres de SP |
| DEP-19 | Intercard (POS/ATM) | Sistema externo | 🟠 ALTA | Detectado en comentarios / nombres de SP |
| DEP-20 | Banxico (SPEI) | Sistema externo | 🔴 CRÍTICA | Detectado en comentarios / nombres de SP |
| DEP-21 | CECOBAN (compensación) | Sistema externo | 🟠 ALTA | Detectado en comentarios / nombres de SP |

---
## DEP-01 · IBM Informix IDS 14.10 — Motor de BD (a reemplazar)

**Criticidad:** 🔴 CRÍTICA — todo el dominio `bdicheq` es SPL nativo de Informix.

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

### `bdicheq` — Cheques/Cuentas

**Criticidad:** 🔴 CRÍTICA — 25 SPs de `bdicheq` hacen cross-DB call

| SP de `bdicheq` | Tablas accedidas en `bdicheq` | Tipo |
|----|----|----|  
| `sp_abono_sd` | `bdicheq:sc_nominamovimientos_bpi`, `bdicheq:sc_fechas`, `bdicheq:sc_tarjeta` | R |
| `sp_actualizar_registros_indicadores` | `bdicheq:` | R |
| `sp_actualiza_portabilidad` | `bdicheq:` | R |
| `sp_actualizakelloggs` | `bdicheq:sc_fechas`, `bdicheq:sc_ctabloqueo`, `bdicheq:sc_maeinstrucc` | R |
| `sp_actsdodiarioc` | `bdicheq:sc_producto`, `bdicheq:`, `bdicheq:sc_maechq` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `Cheques/CuentasService`. Requiere definir contrato OpenAPI.

### `bdinteg` — Integración/Auth

**Criticidad:** 🔴 CRÍTICA — 21 SPs de `bdicheq` hacen cross-DB call

| SP de `bdicheq` | Tablas accedidas en `bdinteg` | Tipo |
|----|----|----|  
| `sp_abono_sd` | `bdinteg:`, `bdinteg:si_cliente`, `bdinteg:si_param` | R |
| `sp_actualizar_registros_indicadores` | `bdinteg:` | R |
| `sp_actualizakelloggs` | `bdinteg:si_telefonos_actual`, `bdinteg:si_cliente`, `bdinteg:si_correos` | R |
| `abono_web` | `bdinteg:si_ejecut`, `bdinteg:si_transacc` | R |
| `sp_actsdodiarioc` | `bdinteg:si_fechavalor`, `bdinteg:si_cliente`, `bdinteg:si_profesion` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `Integración/AuthService`. Requiere definir contrato OpenAPI.

### `sysmaster` — Sysmaster (Informix interno)

**Criticidad:** 🔴 CRÍTICA — 14 SPs de `bdicheq` hacen cross-DB call

| SP de `bdicheq` | Tablas accedidas en `sysmaster` | Tipo |
|----|----|----|  
| `abono_ctas` | `sysmaster:systabnames` | R |
| `abono_ctas_comis` | `sysmaster:systabnames` | R |
| `sp_actualiza_reg_porta` | `sysmaster:systabnames` | R |
| `sp_abonos_operaciones_esp` | `sysmaster:systabnames` | R |
| `sp_abonos_operaciones` | `sysmaster:systabnames` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `Sysmaster (Informix interno)Service`. Requiere definir contrato OpenAPI.

### `bdispei` — SPEI

**Criticidad:** 🟠 ALTA — 6 SPs de `bdicheq` hacen cross-DB call

| SP de `bdicheq` | Tablas accedidas en `bdispei` | Tipo |
|----|----|----|  
| `sp_actualiza_reg_porta` | `bdispei:` | R |
| `sp_actualiza_control_cobranza_automatica` | `bdispei:tblparametros` | R |
| `abono_ref_web` | `bdispei:tblparametros` | R |
| `abono_ref` | `bdispei:tblparametros` | R |
| `abono_ref_pos` | `bdispei:tblparametros` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `SPEIService`. Requiere definir contrato OpenAPI.

### `bdiaclaracion` — Aclaraciones

**Criticidad:** 🟠 ALTA — 4 SPs de `bdicheq` hacen cross-DB call

| SP de `bdicheq` | Tablas accedidas en `bdiaclaracion` | Tipo |
|----|----|----|  
| `abono_ref_web` | `bdiaclaracion:acl_aclaracion` | R |
| `abono_ref` | `bdiaclaracion:acl_aclaracion` | R |
| `sp_actualiza_control_cobranza_automatica` | `bdiaclaracion:acl_aclaracion` | R |
| `abono_ref_pos` | `bdiaclaracion:acl_aclaracion` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `AclaracionesService`. Requiere definir contrato OpenAPI.

### `bdicred` — Créditos

**Criticidad:** 🟠 ALTA — 4 SPs de `bdicheq` hacen cross-DB call

| SP de `bdicheq` | Tablas accedidas en `bdicred` | Tipo |
|----|----|----|  
| `sp_actualizaobservaciones` | `bdicred:` | R |
| `sp_actualiza_est_reg_contr_evid_notif_porta` | `bdicred:sd_ctascarg`, `bdicred:sd_maesdos` | R |
| `sp_actualizar_registros_indicadores_1` | `bdicred:` | R |
| `sp_actualizar_registros_indicadores` | `bdicred:` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `CréditosService`. Requiere definir contrato OpenAPI.

### `bditransfer` — BDITRANSFER

**Criticidad:** 🟡 MEDIA — 3 SPs de `bdicheq` hacen cross-DB call

| SP de `bdicheq` | Tablas accedidas en `bditransfer` | Tipo |
|----|----|----|  
| `abono_ref_web` | `bditransfer:tf_maecte` | R |
| `abono_ref` | `bditransfer:tf_maecte` | R |
| `sp_actualiza_control_cobranza_automatica` | `bditransfer:tf_maecte` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `BDITRANSFERService`. Requiere definir contrato OpenAPI.

### `bdisac` — Saldos/Cuentas

**Criticidad:** 🟡 MEDIA — 3 SPs de `bdicheq` hacen cross-DB call

| SP de `bdicheq` | Tablas accedidas en `bdisac` | Tipo |
|----|----|----|  
| `abono_ref_web` | `bdisac:sac_movimientos` | R |
| `abono_ref` | `bdisac:sac_movimientos` | R |
| `sp_actualiza_control_cobranza_automatica` | `bdisac:sac_movimientos` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `Saldos/CuentasService`. Requiere definir contrato OpenAPI.

### `bdinvers` — BDINVERS

**Criticidad:** 🟡 MEDIA — 2 SPs de `bdicheq` hacen cross-DB call

| SP de `bdicheq` | Tablas accedidas en `bdinvers` | Tipo |
|----|----|----|  
| `sp_actualizakelloggs` | `bdinvers:sv_maeinv` | R |
| `sp_abono_sd` | `bdinvers:sv_gat` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `BDINVERSService`. Requiere definir contrato OpenAPI.

### `BDICHEQ` — BDICHEQ

**Criticidad:** 🟡 MEDIA — 2 SPs de `bdicheq` hacen cross-DB call

| SP de `bdicheq` | Tablas accedidas en `BDICHEQ` | Tipo |
|----|----|----|  
| `sp_actualiza_est_reg_contr_evid_notif_porta` | `BDICHEQ:`, `BDICHEQ:sc_portaarchtemp`, `BDICHEQ:sc_param` | R |
| `sp_abono_sd_pbajlh` | `BDICHEQ:sc_tarjeta` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `BDICHEQService`. Requiere definir contrato OpenAPI.

### `bdisolic` — Solicitudes

**Criticidad:** 🟡 MEDIA — 2 SPs de `bdicheq` hacen cross-DB call

| SP de `bdicheq` | Tablas accedidas en `bdisolic` | Tipo |
|----|----|----|  
| `sp_actualiza_est_reg_contr_evid_notif_porta` | `bdisolic:ss_adn_solicitudcuenta` | R |
| `sp_abono_sd_pbajlh` | `bdisolic:ss_prestamoscoppel` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `SolicitudesService`. Requiere definir contrato OpenAPI.

### `bdiedoelec` — BDIEDOELEC

**Criticidad:** 🟡 MEDIA — 1 SPs de `bdicheq` hacen cross-DB call

| SP de `bdicheq` | Tablas accedidas en `bdiedoelec` | Tipo |
|----|----|----|  
| `sp_actsdodiarioc` | `bdiedoelec:` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `BDIEDOELECService`. Requiere definir contrato OpenAPI.

### `BDICRED` — BDICRED

**Criticidad:** 🟡 MEDIA — 1 SPs de `bdicheq` hacen cross-DB call

| SP de `bdicheq` | Tablas accedidas en `BDICRED` | Tipo |
|----|----|----|  
| `sp_actualiza_est_reg_contr_evid_notif_porta` | `BDICRED:sd_maecred`, `BDICRED:sd_maecredcrd` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `BDICREDService`. Requiere definir contrato OpenAPI.

### `BDINTEG` — BDINTEG

**Criticidad:** 🟡 MEDIA — 1 SPs de `bdicheq` hacen cross-DB call

| SP de `bdicheq` | Tablas accedidas en `BDINTEG` | Tipo |
|----|----|----|  
| `sp_actualiza_est_reg_contr_evid_notif_porta` | `BDINTEG:si_telefonos_actual` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `BDINTEGService`. Requiere definir contrato OpenAPI.

### `bdicntchq` — BDICNTCHQ

**Criticidad:** 🟡 MEDIA — 1 SPs de `bdicheq` hacen cross-DB call

| SP de `bdicheq` | Tablas accedidas en `bdicntchq` | Tipo |
|----|----|----|  
| `abonoref_td` | `bdicntchq:sq_param` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `BDICNTCHQService`. Requiere definir contrato OpenAPI.

---
## Funciones Built-in de Informix (sin equivalente directo en PostgreSQL)

| Función Informix | Usos detectados | Equivalente PostgreSQL | Riesgo |
|-----------------|-----------------|----------------------|--------|
| `NVL()` | 31 usos | `COALESCE` | 🟡 Ajuste menor |
| `DBINFO()` | 12 usos | `txid_current() / session_user` | 🔴 Sin equiv. directo |
| `DATETIME()` | 11 usos | `TIMESTAMP` | 🟡 Ajuste de sintaxis |
| `CURRENT()` | 9 usos | `NOW() / CURRENT_TIMESTAMP` | 🟡 Ajuste menor |
| `YEAR()` | 7 usos | `EXTRACT(YEAR FROM date)` | 🟡 Ajuste menor |
| `MONTH()` | 4 usos | `EXTRACT(MONTH FROM date)` | 🟡 Ajuste menor |
| `TODAY()` | 4 usos | `CURRENT_DATE` | 🟢 Directo |
| `TRIM()` | 3 usos | `TRIM / BTRIM` | 🟡 Ajuste menor |

---
## Matriz de impacto en cutover

| Dependencia | ¿Bloquea cutover? | Plan de continuidad | Owner |
|------------|-------------------|---------------------|-------|
| IBM Informix IDS | ✅ SÍ (es el motor) | Aurora PostgreSQL 15+ | DBA + Cloud Architect |
| Scheduler AIX | ✅ SÍ (batch jobs) | AWS EventBridge Scheduler | DevOps / Infra |
| `BDICHEQ` cross-DB | ✅ SÍ si no tiene API | API interna de `BDICHEQService` | Architect AM |
| `BDICRED` cross-DB | ✅ SÍ si no tiene API | API interna de `BDICREDService` | Architect AM |
| `BDINTEG` cross-DB | ✅ SÍ si no tiene API | API interna de `BDINTEGService` | Architect AM |
| `bdiaclaracion` cross-DB | ✅ SÍ si no tiene API | API interna de `AclaracionesService` | Architect AM |
| `bdicheq` cross-DB | ✅ SÍ si no tiene API | API interna de `Cheques/CuentasService` | Architect AM |
| SmartVista (tarjetas débito) | 🟡 Parcial | Evaluar reemplazo o mantener integración | Architect AM |
| Intercard (POS/ATM) | 🟡 Parcial | Evaluar reemplazo o mantener integración | Architect AM |
| Banxico (SPEI) | 🟡 Parcial | Evaluar reemplazo o mantener integración | Architect AM |
| Built-ins SPL | 🟡 Parcial (reescritura) | Mapping en capa de aplicación | Dev Team |


---
*Generado por: Specialist — Informix SPL Analysis · 2026-07-03 · Evidencia: source/informix/bdicheq_*.sql (análisis estático de 70 archivos SQL) · análisis estático de archivos SQL*

<!-- LOG-DATA-BEGIN -->
## Sistemas externos observados en logs — 2026-04-24
> Fuente: `source/logs/errores_bus_2026-04-24_*.txt` · Incorporado: 2026-08-01

| Sistema externo | Protocolo | Llamadas observadas | Notas |
|-----------------|-----------|---------------------|-------|
| APPRIZA — CFPA (batch) | SOAP/HTTPS | 8 | Servicio ESB: `RemesasAPPRIZAAutomaticas` |
| APPRIZA — CFPA | SOAP/HTTPS | 3 | Servicio ESB: `RemesasAPPRIZA` |
| PostgreSQL Huellas (target migrado) | JDBC | 3 | Servicio ESB: `Huellas442` |
| Fábrica de Pagos ESB | SOAP/JNI | 2 | Servicio ESB: `FabricaPagoServicios` |

### Errores de comunicación con externos (SSL / timeout / JNI)

| Código | Descripción | Volumen/día | Servicios |
|--------|-------------|-------------|-----------|
| `3743` | Handle Timed-out — timeout en conexión SOAP/JNI con sis | 42 | Tarjeta |

*Generado por generate-kb-from-logs.py · 2026-08-01*
<!-- LOG-DATA-END -->

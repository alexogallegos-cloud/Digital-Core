# D01 · Canal Digital Web — Dependencias Externas y Terceros

> **Componente:** LegacyCore · SPE-AM-001 · Etapa 1
> **Base de datos:** `bdicnweb` · IBM Informix IDS 14.10 / POWER-AIX
> **Wave:** ÚLTIMO · Riesgo: **ALTO**
> **Última actualización:** 2026-07-03

---
**SME responsable:**
- Specialist — Informix SPL Analysis (análisis estático, code extraction)
- DBA — IBM Informix IDS (schema real vía syscolumns — Etapa 2) ← NUEVO
- Industry Banking + Domain Expert LegacyCore (validación funcional)
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
| DEP-03 | `BDIDIGITAL` (BDIDIGITAL) | Cross-DB call (dominio interno) | 🟡 MEDIA | 1 SPs hacen cross-DB |
| DEP-04 | `BdiSac` (BDISAC) | Cross-DB call (dominio interno) | 🟡 MEDIA | 3 SPs hacen cross-DB |
| DEP-05 | `Bdinteg` (BDINTEG) | Cross-DB call (dominio interno) | 🟡 MEDIA | 3 SPs hacen cross-DB |
| DEP-06 | `Intercard` (INTERCARD) | Cross-DB call (dominio interno) | 🟡 MEDIA | 3 SPs hacen cross-DB |
| DEP-07 | `bdiaclaracion` (Aclaraciones) | Cross-DB call (dominio interno) | 🟠 ALTA | 5 SPs hacen cross-DB |
| DEP-08 | `bdibei` (BDIBEI) | Cross-DB call (dominio interno) | 🟡 MEDIA | 1 SPs hacen cross-DB |
| DEP-09 | `bdiburo` (BDIBURO) | Cross-DB call (dominio interno) | 🟡 MEDIA | 3 SPs hacen cross-DB |
| DEP-10 | `bdicheq` (Cheques/Cuentas) | Cross-DB call (dominio interno) | 🔴 CRÍTICA | 50 SPs hacen cross-DB |
| DEP-11 | `bdicntchq` (BDICNTCHQ) | Cross-DB call (dominio interno) | 🟡 MEDIA | 1 SPs hacen cross-DB |
| DEP-12 | `bdicnweb` (Canal Digital Web) | Cross-DB call (dominio interno) | 🔴 CRÍTICA | 45 SPs hacen cross-DB |
| DEP-13 | `bdicobranza` (Cobranza) | Cross-DB call (dominio interno) | 🟡 MEDIA | 3 SPs hacen cross-DB |
| DEP-14 | `bdicont` (Contabilidad) | Cross-DB call (dominio interno) | 🟠 ALTA | 6 SPs hacen cross-DB |
| DEP-15 | `bdicred` (Créditos) | Cross-DB call (dominio interno) | 🔴 CRÍTICA | 35 SPs hacen cross-DB |
| DEP-16 | `bdidigital` (BDIDIGITAL) | Cross-DB call (dominio interno) | 🟡 MEDIA | 1 SPs hacen cross-DB |
| DEP-17 | `bdilide` (LIDE) | Cross-DB call (dominio interno) | 🟠 ALTA | 9 SPs hacen cross-DB |
| DEP-18 | `bdinteg` (Integración/Auth) | Cross-DB call (dominio interno) | 🔴 CRÍTICA | 49 SPs hacen cross-DB |
| DEP-19 | `bdinvers` (BDINVERS) | Cross-DB call (dominio interno) | 🔴 CRÍTICA | 20 SPs hacen cross-DB |
| DEP-20 | `bdiprog` (BDIPROG) | Cross-DB call (dominio interno) | 🟡 MEDIA | 3 SPs hacen cross-DB |
| DEP-21 | `bdirech` (BDIRECH) | Cross-DB call (dominio interno) | 🟠 ALTA | 7 SPs hacen cross-DB |
| DEP-22 | `bdirst` (BDIRST) | Cross-DB call (dominio interno) | 🟠 ALTA | 7 SPs hacen cross-DB |
| DEP-23 | `bdisac` (Saldos/Cuentas) | Cross-DB call (dominio interno) | 🔴 CRÍTICA | 27 SPs hacen cross-DB |
| DEP-24 | `bdisitesp` (BDISITESP) | Cross-DB call (dominio interno) | 🟠 ALTA | 8 SPs hacen cross-DB |
| DEP-25 | `bdisolic` (Solicitudes) | Cross-DB call (dominio interno) | 🔴 CRÍTICA | 23 SPs hacen cross-DB |
| DEP-26 | `bdispei` (SPEI) | Cross-DB call (dominio interno) | 🟡 MEDIA | 2 SPs hacen cross-DB |
| DEP-27 | `bdisuc` (Sucursales) | Cross-DB call (dominio interno) | 🔴 CRÍTICA | 33 SPs hacen cross-DB |
| DEP-28 | `bditarjeta` (BDITARJETA) | Cross-DB call (dominio interno) | 🟡 MEDIA | 3 SPs hacen cross-DB |
| DEP-29 | `bditef` (BDITEF) | Cross-DB call (dominio interno) | 🔴 CRÍTICA | 14 SPs hacen cross-DB |
| DEP-30 | `bditransfer` (BDITRANSFER) | Cross-DB call (dominio interno) | 🔴 CRÍTICA | 12 SPs hacen cross-DB |
| DEP-31 | `intercard` (Intercard (POS/ATM)) | Cross-DB call (dominio interno) | 🔴 CRÍTICA | 13 SPs hacen cross-DB |
| DEP-32 | `sysmaster` (Sysmaster (Informix interno)) | Cross-DB call (dominio interno) | 🟠 ALTA | 8 SPs hacen cross-DB |
| DEP-33 | SmartVista (tarjetas) | Sistema externo | 🟠 ALTA | Detectado en comentarios / nombres de SP |
| DEP-34 | Intercard (POS/ATM) | Sistema externo | 🟠 ALTA | Detectado en comentarios / nombres de SP |
| DEP-35 | Latinia (SMS) | Sistema externo | 🟠 ALTA | Detectado en comentarios / nombres de SP |
| DEP-36 | Banxico SPEI | Sistema externo | 🔴 CRÍTICA | Detectado en comentarios / nombres de SP |

---
## DEP-01 · IBM Informix IDS 14.10 — Motor de BD (a reemplazar)

**Criticidad:** 🔴 CRÍTICA — todo el dominio `bdicnweb` es SPL nativo de Informix.

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

**Criticidad:** 🔴 CRÍTICA — 50 SPs de `bdicnweb` hacen cross-DB call

| SP de `bdicnweb` | Tablas accedidas en `bdicheq` | Tipo |
|----|----|----|  
| `sp_admintasas_consultapagare` | `bdicheq:sc_sdomensualc`, `bdicheq:`, `bdicheq:sc_admintasas_inv_estatus` | R |
| `sp_adm_consultabitacora_usuarios_totales` | `bdicheq:` | R |
| `sp_actualizapagocheque` | `bdicheq:` | R |
| `sp_actualizaproghorariosccl` | `bdicheq:sc_cedulacontable` | R |
| `sp_actualizacuentasdormidas` | `bdicheq:`, `bdicheq:sc_maenoc`, `bdicheq:sc_histbloq` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `Cheques/CuentasService`. Requiere definir contrato OpenAPI.

### `bdinteg` — Integración/Auth

**Criticidad:** 🔴 CRÍTICA — 49 SPs de `bdicnweb` hacen cross-DB call

| SP de `bdicnweb` | Tablas accedidas en `bdinteg` | Tipo |
|----|----|----|  
| `sp_abm_canal_cobro` | `bdinteg:si_sistema`, `bdinteg:si_catalog`, `bdinteg:si_prodtran` | R |
| `sp_admintasas_consultapagare` | `bdinteg:si_cliente`, `bdinteg:si_ctepm`, `bdinteg:` | R |
| `sp_adm_consultabitacora_usuarios_totales` | `bdinteg:si_sistema`, `bdinteg:si_seg_usuarios`, `bdinteg:si_catalog` | R |
| `sp_actualizapagocheque` | `bdinteg:` | R |
| `sp_actualizacuentasdormidas` | `bdinteg:si_cliente`, `bdinteg:` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `Integración/AuthService`. Requiere definir contrato OpenAPI.

### `bdicnweb` — Canal Digital Web

**Criticidad:** 🔴 CRÍTICA — 45 SPs de `bdicnweb` hacen cross-DB call

| SP de `bdicnweb` | Tablas accedidas en `bdicnweb` | Tipo |
|----|----|----|  
| `sp_abm_canal_cobro` | `bdicnweb:`, `bdicnweb:sw_cg_billetesfalsos`, `bdicnweb:sw_verificastatusarchivodeclaracionide` | R |
| `sp_admintasas_consultapagare` | `bdicnweb:`, `bdicnweb:si_cliente_emp_pru` | R |
| `sp_adm_consultabitacora_usuarios_totales` | `bdicnweb:sw_cg_billetesfalsos`, `bdicnweb:sw_verificastatusarchivodeclaracionide`, `bdicnweb:sw_verificastatusentradasalida` | R |
| `sp_actualizapagocheque` | `bdicnweb:` | R |
| `sp_actualizacuentasdormidas` | `bdicnweb:sw_verificastatusarqueosucaja`, `bdicnweb:sw_cg_arqueosucajatmp`, `bdicnweb:` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `Canal Digital WebService`. Requiere definir contrato OpenAPI.

### `bdicred` — Créditos

**Criticidad:** 🔴 CRÍTICA — 35 SPs de `bdicnweb` hacen cross-DB call

| SP de `bdicnweb` | Tablas accedidas en `bdicred` | Tipo |
|----|----|----|  
| `sp_admintasas_consultapagare` | `bdicred:sd_ctascarg`, `bdicred:sd_maecred`, `bdicred:sd_maecredcrd` | R |
| `sp_adm_consultabitacora_usuarios_totales` | `bdicred:` | R |
| `sp_actualizacuentasdormidas` | `bdicred:` | R |
| `sp_actualizatipo_gcb` | `bdicred:sd_movhis`, `bdicred:sd_movdia`, `bdicred:` | R |
| `sp_actualizadomiciliocte` | `bdicred:sd_definicion`, `bdicred:`, `bdicred:sd_param` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `CréditosService`. Requiere definir contrato OpenAPI.

### `bdisuc` — Sucursales

**Criticidad:** 🔴 CRÍTICA — 33 SPs de `bdicnweb` hacen cross-DB call

| SP de `bdicnweb` | Tablas accedidas en `bdisuc` | Tipo |
|----|----|----|  
| `sp_abm_canal_cobro` | `bdisuc:` | R |
| `sp_adm_consultabitacora_usuarios_totales` | `bdisuc:` | R |
| `sp_actualizatipo_gcb` | `bdisuc:` | R |
| `sp_actualizasdosucursalcaja` | `bdisuc:`, `bdisuc:ss_pase_sucursal`, `bdisuc:ss_cajageneral` | R |
| `sp_actualizaclasificacion_gcb` | `bdisuc:` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `SucursalesService`. Requiere definir contrato OpenAPI.

### `bdisac` — Saldos/Cuentas

**Criticidad:** 🔴 CRÍTICA — 27 SPs de `bdicnweb` hacen cross-DB call

| SP de `bdicnweb` | Tablas accedidas en `bdisac` | Tipo |
|----|----|----|  
| `sp_abm_canal_cobro` | `bdisac:sac_reportediario_seg` | R |
| `sp_adm_consultabitacora_usuarios_totales` | `bdisac:sac_reportediario_seg` | R |
| `sp_actualizacuentasdormidas` | `bdisac:sac_reportediario_seg`, `bdisac:` | R |
| `sp_actualizadomiciliocte` | `bdisac:sac_bts_catmensajes`, `bdisac:sac_bts_catstatusremesas`, `bdisac:sac_param` | R |
| `sp_actualizasdosucursalcaja` | `bdisac:sac_movimientoshistorial` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `Saldos/CuentasService`. Requiere definir contrato OpenAPI.

### `bdisolic` — Solicitudes

**Criticidad:** 🔴 CRÍTICA — 23 SPs de `bdicnweb` hacen cross-DB call

| SP de `bdicnweb` | Tablas accedidas en `bdisolic` | Tipo |
|----|----|----|  
| `sp_adm_consultabitacora_usuarios_totales` | `bdisolic:` | R |
| `sp_actualizatipo_gcb` | `bdisolic:ss_emp_revingresos_mc`, `bdisolic:` | R |
| `sp_actualizasdosucursalcaja` | `bdisolic:ss_solicitudes_mc`, `bdisolic:ss_cte_procesando` | R |
| `sp_actualizaclasificacion_gcb` | `bdisolic:ss_emp_revingresos_mc`, `bdisolic:` | R |
| `sp_actualizacionctepmsnom2` | `bdisolic:` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `SolicitudesService`. Requiere definir contrato OpenAPI.

### `bdinvers` — BDINVERS

**Criticidad:** 🔴 CRÍTICA — 20 SPs de `bdicnweb` hacen cross-DB call

| SP de `bdicnweb` | Tablas accedidas en `bdinvers` | Tipo |
|----|----|----|  
| `sp_admintasas_consultapagare` | `bdinvers:sv_admintasas_estatus`, `bdinvers:`, `bdinvers:sv_admintasas_pagare` | R |
| `sp_actualizadatoscheque` | `bdinvers:si_admintasas_inv_tasames`, `bdinvers:sv_sucursales_promocion`, `bdinvers:` | R |
| `sp_actualizacionctepmsnom2` | `bdinvers:` | R |
| `sp_admintasas_actualizastatuspagare` | `bdinvers:sv_admintasas_estatus`, `bdinvers:`, `bdinvers:sv_admintasas_pagare` | R |
| `sp_admintasas_consultabitacora` | `bdinvers:sv_movdia`, `bdinvers:`, `bdinvers:sv_maeinv` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `BDINVERSService`. Requiere definir contrato OpenAPI.

### `bditef` — BDITEF

**Criticidad:** 🔴 CRÍTICA — 14 SPs de `bdicnweb` hacen cross-DB call

| SP de `bdicnweb` | Tablas accedidas en `bditef` | Tipo |
|----|----|----|  
| `sp_actualizadomiciliocte2` | `bditef:cce_encabezado`, `bditef:cce_cheques_dev`, `bditef:` | R |
| `sp_actualizastatusmonitorproceso` | `bditef:`, `bditef:cce_detalle`, `bditef:cce_cheques_dev` | R |
| `sp_actualiza_admintransaciones` | `bditef:tef_parametros`, `bditef:` | R |
| `sp_actualizaregistrodevolverext_tef` | `bditef:tef_parametros`, `bditef:` | R |
| `sp_actualizaprocesoconau` | `bditef:` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `BDITEFService`. Requiere definir contrato OpenAPI.

### `intercard` — Intercard (POS/ATM)

**Criticidad:** 🔴 CRÍTICA — 13 SPs de `bdicnweb` hacen cross-DB call

| SP de `bdicnweb` | Tablas accedidas en `intercard` | Tipo |
|----|----|----|  
| `sp_actualizadomiciliocte2` | `intercard:movimiento`, `intercard:movimientohistorico`, `intercard:bitacora_msi` | R |
| `sp_ac_actualizactas` | `intercard:` | R |
| `sp_actualizazona_gcb` | `intercard:` | R |
| `sp_ac_desbloquoctas` | `intercard:` | R |
| `sp_ac_busquedacuentas_total` | `intercard:` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `Intercard (POS/ATM)Service`. Requiere definir contrato OpenAPI.

### `bditransfer` — BDITRANSFER

**Criticidad:** 🔴 CRÍTICA — 12 SPs de `bdicnweb` hacen cross-DB call

| SP de `bdicnweb` | Tablas accedidas en `bditransfer` | Tipo |
|----|----|----|  
| `sp_actualizastatusmonitorproceso` | `bditransfer:` | R |
| `sp_adminitasas_cargarchivo` | `bditransfer:tf_account_balance_customer`, `bditransfer:tf_maecte` | R |
| `sp_admintasas_consultapagare` | `bditransfer:tf_account_balance_customer`, `bditransfer:tf_maecte` | R |
| `sp_actinfosolicitudmc` | `bditransfer:tf_maecte` | R |
| `sp_admintasas_bitacoraerror` | `bditransfer:` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `BDITRANSFERService`. Requiere definir contrato OpenAPI.

### `bdilide` — LIDE

**Criticidad:** 🟠 ALTA — 9 SPs de `bdicnweb` hacen cross-DB call

| SP de `bdicnweb` | Tablas accedidas en `bdilide` | Tipo |
|----|----|----|  
| `sp_abono_ref_masivo` | `bdilide:` | R |
| `sp_abm_canal_cobro` | `bdilide:` | R |
| `sp_adm_consultabitacora_usuarios` | `bdilide:` | R |
| `sp_adm_validacampos` | `bdilide:` | R |
| `sp_adm_consultabitacora_usuarios_totales` | `bdilide:` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `LIDEService`. Requiere definir contrato OpenAPI.

### `bdisitesp` — BDISITESP

**Criticidad:** 🟠 ALTA — 8 SPs de `bdicnweb` hacen cross-DB call

| SP de `bdicnweb` | Tablas accedidas en `bdisitesp` | Tipo |
|----|----|----|  
| `sp_actualizazona_gcb` | `bdisitesp:` | R |
| `sp_actualizasucursal` | `bdisitesp:` | R |
| `sp_activardesactivarproductos` | `bdisitesp:` | R |
| `sp_actualizatipo_gcb` | `bdisitesp:` | R |
| `sp_actualizaformato_gcb` | `bdisitesp:` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `BDISITESPService`. Requiere definir contrato OpenAPI.

### `sysmaster` — Sysmaster (Informix interno)

**Criticidad:** 🟠 ALTA — 8 SPs de `bdicnweb` hacen cross-DB call

| SP de `bdicnweb` | Tablas accedidas en `sysmaster` | Tipo |
|----|----|----|  
| `sp_actualizazona_gcb` | `sysmaster:sysshmvals` | R |
| `sp_actualizacalificaestatus` | `sysmaster:sysshmvals` | R |
| `sp_actualizasucursal` | `sysmaster:sysshmvals` | R |
| `sp_actualizatipo_gcb` | `sysmaster:sysshmvals` | R |
| `sp_actualizaformato_gcb` | `sysmaster:sysshmvals` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `Sysmaster (Informix interno)Service`. Requiere definir contrato OpenAPI.

### `bdirst` — BDIRST

**Criticidad:** 🟠 ALTA — 7 SPs de `bdicnweb` hacen cross-DB call

| SP de `bdicnweb` | Tablas accedidas en `bdirst` | Tipo |
|----|----|----|  
| `sp_abm_canal_cobro` | `bdirst:` | R |
| `sp_adm_consultabitacora_usuarios` | `bdirst:` | R |
| `sp_adm_validacampos` | `bdirst:` | R |
| `sp_adm_consultabitacora_usuarios_totales` | `bdirst:` | R |
| `sp_activardesactivarproductos` | `bdirst:` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `BDIRSTService`. Requiere definir contrato OpenAPI.

### `bdirech` — BDIRECH

**Criticidad:** 🟠 ALTA — 7 SPs de `bdicnweb` hacen cross-DB call

| SP de `bdicnweb` | Tablas accedidas en `bdirech` | Tipo |
|----|----|----|  
| `sp_actualizazona_gcb` | `bdirech:rec_confaltante`, `bdirech:rec_faltantesarch`, `bdirech:` | R |
| `sp_actualizasucursal` | `bdirech:rec_confaltante`, `bdirech:rec_faltantesarch`, `bdirech:` | R |
| `sp_actualizatipo_gcb` | `bdirech:rec_confaltante`, `bdirech:rec_faltantesarch`, `bdirech:` | R |
| `sp_actualizaformato_gcb` | `bdirech:rec_confaltante`, `bdirech:rec_faltantesarch`, `bdirech:` | R |
| `sp_actualizaclasificacion_gcb` | `bdirech:rec_confaltante`, `bdirech:rec_faltantesarch`, `bdirech:` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `BDIRECHService`. Requiere definir contrato OpenAPI.

### `bdicont` — Contabilidad

**Criticidad:** 🟠 ALTA — 6 SPs de `bdicnweb` hacen cross-DB call

| SP de `bdicnweb` | Tablas accedidas en `bdicont` | Tipo |
|----|----|----|  
| `sp_actualizaregistrocaja` | `bdicont:` | R |
| `sp_actualizasdosucursalcaja` | `bdicont:` | R |
| `sp_actualizadatoscheque` | `bdicont:` | R |
| `sp_actualizacentrallincred` | `bdicont:` | R |
| `sp_actualizacambiobilletescaja` | `bdicont:` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `ContabilidadService`. Requiere definir contrato OpenAPI.

### `bdiaclaracion` — Aclaraciones

**Criticidad:** 🟠 ALTA — 5 SPs de `bdicnweb` hacen cross-DB call

| SP de `bdicnweb` | Tablas accedidas en `bdiaclaracion` | Tipo |
|----|----|----|  
| `sp_adminitasas_cargarchivo` | `bdiaclaracion:acl_producto`, `bdiaclaracion:acl_aclaracion` | R |
| `sp_admintasas_consultapagare` | `bdiaclaracion:acl_aclaracion`, `bdiaclaracion:acl_producto` | R |
| `sp_admintasas_actualizastatuspagare` | `bdiaclaracion:acl_aclaracion`, `bdiaclaracion:acl_producto` | R |
| `sp_adminitasas_ope_guardainfo` | `bdiaclaracion:acl_producto`, `bdiaclaracion:acl_aclaracion` | R |
| `sp_actualizadatoscheque` | `bdiaclaracion:acl_producto`, `bdiaclaracion:acl_aclaracion` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `AclaracionesService`. Requiere definir contrato OpenAPI.

### `bdiburo` — BDIBURO

**Criticidad:** 🟡 MEDIA — 3 SPs de `bdicnweb` hacen cross-DB call

| SP de `bdicnweb` | Tablas accedidas en `bdiburo` | Tipo |
|----|----|----|  
| `sp_ac_desbloquoctas` | `bdiburo:` | R |
| `sp_ac_actualizactas` | `bdiburo:` | R |
| `sp_ac_busquedacuentas_total` | `bdiburo:` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `BDIBUROService`. Requiere definir contrato OpenAPI.

### `bdicobranza` — Cobranza

**Criticidad:** 🟡 MEDIA — 3 SPs de `bdicnweb` hacen cross-DB call

| SP de `bdicnweb` | Tablas accedidas en `bdicobranza` | Tipo |
|----|----|----|  
| `sp_activalidaciontelefono` | `bdicobranza:cb_param` | R |
| `sp_actinfosolicitudmc` | `bdicobranza:cb_param` | R |
| `sp_actualizadomiciliocte` | `bdicobranza:cb_rep_cart_quebrantar` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `CobranzaService`. Requiere definir contrato OpenAPI.

### `Bdinteg` — BDINTEG

**Criticidad:** 🟡 MEDIA — 3 SPs de `bdicnweb` hacen cross-DB call

| SP de `bdicnweb` | Tablas accedidas en `Bdinteg` | Tipo |
|----|----|----|  
| `sp_actualizasufijospm` | `Bdinteg:si_fechas` | R |
| `sp_actualiza_admintransaciones` | `Bdinteg:si_fechas` | R |
| `sp_actualizaregistrodevolverext_tef` | `Bdinteg:si_fechas` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `BDINTEGService`. Requiere definir contrato OpenAPI.

### `bdiprog` — BDIPROG

**Criticidad:** 🟡 MEDIA — 3 SPs de `bdicnweb` hacen cross-DB call

| SP de `bdicnweb` | Tablas accedidas en `bdiprog` | Tipo |
|----|----|----|  
| `sp_actualizasufijospm` | `bdiprog:pp_Encabezado` | R |
| `sp_actualiza_admintransaciones` | `bdiprog:pp_Encabezado` | R |
| `sp_actualizaregistrodevolverext_tef` | `bdiprog:pp_Encabezado` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `BDIPROGService`. Requiere definir contrato OpenAPI.

### `BdiSac` — BDISAC

**Criticidad:** 🟡 MEDIA — 3 SPs de `bdicnweb` hacen cross-DB call

| SP de `bdicnweb` | Tablas accedidas en `BdiSac` | Tipo |
|----|----|----|  
| `sp_actualizastatusmonitorproceso` | `BdiSac:Sac_MovimientosHistorial`, `BdiSac:Sac_BTS_Payi` | R |
| `sp_actualizacion_cheques_presentar` | `BdiSac:Sac_MovimientosHistorial`, `BdiSac:Sac_BTS_Payi` | R |
| `sp_administradorespm_complementoinfo` | `BdiSac:Sac_MovimientosHistorial`, `BdiSac:Sac_BTS_Payi` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `BDISACService`. Requiere definir contrato OpenAPI.

### `Intercard` — INTERCARD

**Criticidad:** 🟡 MEDIA — 3 SPs de `bdicnweb` hacen cross-DB call

| SP de `bdicnweb` | Tablas accedidas en `Intercard` | Tipo |
|----|----|----|  
| `sp_actualizaparametrosccl` | `Intercard:` | R |
| `sp_actualizaproghorariosccl` | `Intercard:` | R |
| `sp_actualizaprocesoconau` | `Intercard:` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `INTERCARDService`. Requiere definir contrato OpenAPI.

### `bditarjeta` — BDITARJETA

**Criticidad:** 🟡 MEDIA — 3 SPs de `bdicnweb` hacen cross-DB call

| SP de `bdicnweb` | Tablas accedidas en `bditarjeta` | Tipo |
|----|----|----|  
| `sp_actualizaparametrosccl` | `bditarjeta:` | R |
| `sp_actualizaproghorariosccl` | `bditarjeta:` | R |
| `sp_actualizaprocesoconau` | `bditarjeta:` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `BDITARJETAService`. Requiere definir contrato OpenAPI.

### `bdispei` — SPEI

**Criticidad:** 🟡 MEDIA — 2 SPs de `bdicnweb` hacen cross-DB call

| SP de `bdicnweb` | Tablas accedidas en `bdispei` | Tipo |
|----|----|----|  
| `sp_actualizacalificaestatus` | `bdispei:` | R |
| `sp_administradorespm_complementoinfo` | `bdispei:tblhistpago` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `SPEIService`. Requiere definir contrato OpenAPI.

### `bdicntchq` — BDICNTCHQ

**Criticidad:** 🟡 MEDIA — 1 SPs de `bdicnweb` hacen cross-DB call

| SP de `bdicnweb` | Tablas accedidas en `bdicntchq` | Tipo |
|----|----|----|  
| `sp_actualizacionctepmsnom` | `bdicntchq:` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `BDICNTCHQService`. Requiere definir contrato OpenAPI.

### `BDIDIGITAL` — BDIDIGITAL

**Criticidad:** 🟡 MEDIA — 1 SPs de `bdicnweb` hacen cross-DB call

| SP de `bdicnweb` | Tablas accedidas en `BDIDIGITAL` | Tipo |
|----|----|----|  
| `sp_actualizacionctepmsnom2` | `BDIDIGITAL:dg_params` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `BDIDIGITALService`. Requiere definir contrato OpenAPI.

### `bdibei` — BDIBEI

**Criticidad:** 🟡 MEDIA — 1 SPs de `bdicnweb` hacen cross-DB call

| SP de `bdicnweb` | Tablas accedidas en `bdibei` | Tipo |
|----|----|----|  
| `sp_administradorespm_complementoinfo` | `bdibei:bei_contratacion`, `bdibei:bei_servicio` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `BDIBEIService`. Requiere definir contrato OpenAPI.

### `bdidigital` — BDIDIGITAL

**Criticidad:** 🟡 MEDIA — 1 SPs de `bdicnweb` hacen cross-DB call

| SP de `bdicnweb` | Tablas accedidas en `bdidigital` | Tipo |
|----|----|----|  
| `inserta_img_previo_soc2` | `bdidigital:` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `BDIDIGITALService`. Requiere definir contrato OpenAPI.

---
## Funciones Built-in de Informix (sin equivalente directo en PostgreSQL)

| Función Informix | Usos detectados | Equivalente PostgreSQL | Riesgo |
|-----------------|-----------------|----------------------|--------|
| `TRIM()` | 137 usos | `TRIM / BTRIM` | 🟡 Ajuste menor |
| `NVL()` | 25 usos | `COALESCE` | 🟡 Ajuste menor |
| `DATETIME()` | 20 usos | `TIMESTAMP` | 🟡 Ajuste de sintaxis |
| `YEAR()` | 17 usos | `EXTRACT(YEAR FROM date)` | 🟡 Ajuste menor |
| `DBINFO()` | 17 usos | `txid_current() / session_user` | 🔴 Sin equiv. directo |
| `CURRENT()` | 14 usos | `NOW() / CURRENT_TIMESTAMP` | 🟡 Ajuste menor |
| `MDY()` | 1 usos | `MAKE_DATE(y,m,d)` | 🟡 Ajuste menor |
| `TODAY()` | 1 usos | `CURRENT_DATE` | 🟢 Directo |

---
## Matriz de impacto en cutover

| Dependencia | ¿Bloquea cutover? | Plan de continuidad | Owner |
|------------|-------------------|---------------------|-------|
| IBM Informix IDS | ✅ SÍ (es el motor) | Aurora PostgreSQL 15+ | DBA + Cloud Architect |
| Scheduler AIX | ✅ SÍ (batch jobs) | AWS EventBridge Scheduler | DevOps / Infra |
| `BDIDIGITAL` cross-DB | ✅ SÍ si no tiene API | API interna de `BDIDIGITALService` | Architect AM |
| `BdiSac` cross-DB | ✅ SÍ si no tiene API | API interna de `BDISACService` | Architect AM |
| `Bdinteg` cross-DB | ✅ SÍ si no tiene API | API interna de `BDINTEGService` | Architect AM |
| `Intercard` cross-DB | ✅ SÍ si no tiene API | API interna de `INTERCARDService` | Architect AM |
| `bdiaclaracion` cross-DB | ✅ SÍ si no tiene API | API interna de `AclaracionesService` | Architect AM |
| SmartVista (tarjetas) | 🟡 Parcial | Evaluar reemplazo o mantener integración | Architect AM |
| Intercard (POS/ATM) | 🟡 Parcial | Evaluar reemplazo o mantener integración | Architect AM |
| Latinia (SMS) | 🟡 Parcial | Evaluar reemplazo o mantener integración | Architect AM |
| Built-ins SPL | 🟡 Parcial (reescritura) | Mapping en capa de aplicación | Dev Team |


---
*Generado por: Specialist — Informix SPL Analysis · 2026-07-03 · Evidencia: source/LegacyCore/informix/bdicnweb_*.sql (análisis estático de 57 archivos SQL) · análisis estático de archivos SQL*

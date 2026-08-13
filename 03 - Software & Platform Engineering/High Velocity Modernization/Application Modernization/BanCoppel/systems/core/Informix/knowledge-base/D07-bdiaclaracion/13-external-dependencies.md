# D07 · Aclaraciones — Dependencias Externas y Terceros

> **Componente:** Informix · SPE-AM-001 · Etapa 1
> **Base de datos:** `bdiaclaracion` · IBM Informix IDS 14.10 / POWER-AIX
> **Wave:** Wave 2 · Riesgo: **ALTO**
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
| DEP-03 | `BDINTEG` (BDINTEG) | Cross-DB call (dominio interno) | 🟡 MEDIA | 2 SPs hacen cross-DB |
| DEP-04 | `bdiaclaracion` (Aclaraciones) | Cross-DB call (dominio interno) | 🔴 CRÍTICA | 39 SPs hacen cross-DB |
| DEP-05 | `bdicheq` (Cheques/Cuentas) | Cross-DB call (dominio interno) | 🔴 CRÍTICA | 24 SPs hacen cross-DB |
| DEP-06 | `bdicred` (Créditos) | Cross-DB call (dominio interno) | 🔴 CRÍTICA | 28 SPs hacen cross-DB |
| DEP-07 | `bdidomi` (BDIDOMI) | Cross-DB call (dominio interno) | 🔴 CRÍTICA | 11 SPs hacen cross-DB |
| DEP-08 | `bdimnsj` (Mensajería) | Cross-DB call (dominio interno) | 🟠 ALTA | 4 SPs hacen cross-DB |
| DEP-09 | `bdinteg` (Integración/Auth) | Cross-DB call (dominio interno) | 🔴 CRÍTICA | 52 SPs hacen cross-DB |
| DEP-10 | `bdinvers` (BDINVERS) | Cross-DB call (dominio interno) | 🔴 CRÍTICA | 16 SPs hacen cross-DB |
| DEP-11 | `bditarjeta` (BDITARJETA) | Cross-DB call (dominio interno) | 🟠 ALTA | 7 SPs hacen cross-DB |
| DEP-12 | `bditransfer` (BDITRANSFER) | Cross-DB call (dominio interno) | 🔴 CRÍTICA | 22 SPs hacen cross-DB |
| DEP-13 | `intercard` (Intercard (POS/ATM)) | Cross-DB call (dominio interno) | 🔴 CRÍTICA | 49 SPs hacen cross-DB |
| DEP-14 | CONDUSEF (portal regulatorio) | Sistema externo | 🟠 ALTA | Detectado en comentarios / nombres de SP |
| DEP-15 | CNBV (reportes R27) | Sistema externo | 🟠 ALTA | Detectado en comentarios / nombres de SP |
| DEP-16 | SmartVista (cargos) | Sistema externo | 🟠 ALTA | Detectado en comentarios / nombres de SP |
| DEP-17 | Banxico SPEI | Sistema externo | 🔴 CRÍTICA | Detectado en comentarios / nombres de SP |

---
## DEP-01 · IBM Informix IDS 14.10 — Motor de BD (a reemplazar)

**Criticidad:** 🔴 CRÍTICA — todo el dominio `bdiaclaracion` es SPL nativo de Informix.

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

**Criticidad:** 🔴 CRÍTICA — 52 SPs de `bdiaclaracion` hacen cross-DB call

| SP de `bdiaclaracion` | Tablas accedidas en `bdinteg` | Tipo |
|----|----|----|  
| `sp_busca_producto_transfer_telefono` | `bdinteg:si_estados`, `bdinteg:si_catzonas`, `bdinteg:si_cliente` | R |
| `sp_busca_nombre_core` | `bdinteg:si_cliente`, `bdinteg:` | R |
| `sp_bitacorasistema` | `bdinteg:si_ctepf`, `bdinteg:` | R |
| `sp_acl_consulta_perfil_usuario` | `bdinteg:si_ejecut`, `bdinteg:si_estados`, `bdinteg:si_sucursales` | R |
| `sp_buscaqueda_folio_csuac` | `bdinteg:si_direcciones_actual`, `bdinteg:si_fechas`, `bdinteg:si_municipios` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `Integración/AuthService`. Requiere definir contrato OpenAPI.

### `intercard` — Intercard (POS/ATM)

**Criticidad:** 🔴 CRÍTICA — 49 SPs de `bdiaclaracion` hacen cross-DB call

| SP de `bdiaclaracion` | Tablas accedidas en `intercard` | Tipo |
|----|----|----|  
| `sp_busca_producto_transfer_telefono` | `intercard:tarjeta`, `intercard:tarjetacuenta` | R |
| `sp_buscar_movimientos_cheques_his_canales` | `intercard:bitacoracambiosstatustarjeta`, `intercard:tarjeta_indicadores`, `intercard:movimientohistorico` | R |
| `sp_buscaqueda_folio_csuac` | `intercard:bitacoracambiosstatustarjeta`, `intercard:`, `intercard:movimientohistorico` | R |
| `sp_busca_aclaraciones_canales` | `intercard:movimiento`, `intercard:movimientohistorico` | R |
| `sp_busca_aclaraciones_promotor` | `intercard:movimiento`, `intercard:bines`, `intercard:movimientohistorico` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `Intercard (POS/ATM)Service`. Requiere definir contrato OpenAPI.

### `bdiaclaracion` — Aclaraciones

**Criticidad:** 🔴 CRÍTICA — 39 SPs de `bdiaclaracion` hacen cross-DB call

| SP de `bdiaclaracion` | Tablas accedidas en `bdiaclaracion` | Tipo |
|----|----|----|  
| `sp_bitacorasistema` | `bdiaclaracion:acl_movimiento`, `bdiaclaracion:acl_aclaracion`, `bdiaclaracion:` | R |
| `sp_acl_consulta_perfil_usuario` | `bdiaclaracion:acl_usuario`, `bdiaclaracion:acl_perfil_usuario`, `bdiaclaracion:acl_perfil` | R |
| `sp_aplicar_cancelacion_por_recuperacion_creddeb` | `bdiaclaracion:acl_usuario`, `bdiaclaracion:` | R |
| `sp_busca_aclaraciones_canales` | `bdiaclaracion:` | R |
| `sp_buscaqueda_folio_csuac` | `bdiaclaracion:`, `bdiaclaracion:acl_tipo_codigo_resolucion` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `AclaracionesService`. Requiere definir contrato OpenAPI.

### `bdicred` — Créditos

**Criticidad:** 🔴 CRÍTICA — 28 SPs de `bdiaclaracion` hacen cross-DB call

| SP de `bdiaclaracion` | Tablas accedidas en `bdicred` | Tipo |
|----|----|----|  
| `sp_buscar_movimientos_cheques_his_canales` | `bdicred:sd_movhiscrd`, `bdicred:sd_movhis`, `bdicred:sd_movhiscrd_old` | R |
| `sp_buscaqueda_folio_csuac` | `bdicred:sd_movhis`, `bdicred:sd_movdia`, `bdicred:` | R |
| `sp_aplicar_cancelacion_por_recuperacion_creddeb` | `bdicred:sd_maesdos` | R |
| `sp_acl_validarpreguntasautenticacion` | `bdicred:sd_definicion`, `bdicred:sd_maecred`, `bdicred:sd_tarjeta` | R |
| `sp_busca_producto_cred_cuenta_crd` | `bdicred:sd_definicion`, `bdicred:sd_maecred`, `bdicred:sd_tarjeta` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `CréditosService`. Requiere definir contrato OpenAPI.

### `bdicheq` — Cheques/Cuentas

**Criticidad:** 🔴 CRÍTICA — 24 SPs de `bdiaclaracion` hacen cross-DB call

| SP de `bdiaclaracion` | Tablas accedidas en `bdicheq` | Tipo |
|----|----|----|  
| `sp_busca_producto_transfer_telefono` | `bdicheq:sc_tarjeta`, `bdicheq:sc_producto`, `bdicheq:sc_maechq` | R |
| `sp_busca_nombre_core` | `bdicheq:`, `bdicheq:sc_maechq` | R |
| `sp_buscaqueda_folio_csuac` | `bdicheq:sc_movdia`, `bdicheq:sc_movhis` | R |
| `sp_buscar_movimientos_cheques_his_canales` | `bdicheq:sc_movhis_old`, `bdicheq:sc_movhis` | R |
| `sp_aplicar_cancelacion_por_recuperacion_creddeb` | `bdicheq:` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `Cheques/CuentasService`. Requiere definir contrato OpenAPI.

### `bditransfer` — BDITRANSFER

**Criticidad:** 🔴 CRÍTICA — 22 SPs de `bdiaclaracion` hacen cross-DB call

| SP de `bdiaclaracion` | Tablas accedidas en `bditransfer` | Tipo |
|----|----|----|  
| `sp_busca_producto_transfer_telefono` | `bditransfer:tf_maecte` | R |
| `sp_busca_nombre_core` | `bditransfer:tf_maecte` | R |
| `sp_busca_producto_deb_cheq_cliente` | `bditransfer:tf_maecte` | R |
| `sp_busca_producto_transfer_cuenta` | `bditransfer:tf_maecte` | R |
| `sp_busca_producto_transfer_tarjeta` | `bditransfer:tf_maecte` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `BDITRANSFERService`. Requiere definir contrato OpenAPI.

### `bdinvers` — BDINVERS

**Criticidad:** 🔴 CRÍTICA — 16 SPs de `bdiaclaracion` hacen cross-DB call

| SP de `bdiaclaracion` | Tablas accedidas en `bdinvers` | Tipo |
|----|----|----|  
| `sp_acl_es_cliente_sv` | `bdinvers:sv_movdia`, `bdinvers:sv_movhis` | R |
| `sp_busca_nombre_core` | `bdinvers:` | R |
| `sp_buscaqueda_folio_csuac` | `bdinvers:sv_movdia`, `bdinvers:sv_movhis` | R |
| `sp_buscar_movimientos_cheques_his_canales` | `bdinvers:sv_movdia`, `bdinvers:sv_movhis` | R |
| `sp_buscar_movimientos_credito_dia_canales` | `bdinvers:sv_movdia`, `bdinvers:sv_movhis` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `BDINVERSService`. Requiere definir contrato OpenAPI.

### `bdidomi` — BDIDOMI

**Criticidad:** 🔴 CRÍTICA — 11 SPs de `bdiaclaracion` hacen cross-DB call

| SP de `bdiaclaracion` | Tablas accedidas en `bdidomi` | Tipo |
|----|----|----|  
| `sp_acl_obtenerlogpreguntas` | `bdidomi:` | R |
| `sp_busca_cte_domiciliacion` | `bdidomi:` | R |
| `sp_busca_producto_cred_cliente_crd` | `bdidomi:` | R |
| `sp_acl_actualizaempaclaracion` | `bdidomi:` | R |
| `sp_acl_obtenernombreestados` | `bdidomi:` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `BDIDOMIService`. Requiere definir contrato OpenAPI.

### `bditarjeta` — BDITARJETA

**Criticidad:** 🟠 ALTA — 7 SPs de `bdiaclaracion` hacen cross-DB call

| SP de `bdiaclaracion` | Tablas accedidas en `bditarjeta` | Tipo |
|----|----|----|  
| `sp_acl_consultadevolucion` | `bditarjeta:td_movimientos_conciliacion` | R |
| `sp_busca_producto_cred_cliente` | `bditarjeta:td_movimientos_conciliacion` | R |
| `sp_bitacora_siem` | `bditarjeta:td_movimientos_conciliacion` | R |
| `sp_acl_valida_dfa_devo` | `bditarjeta:td_movimientos_conciliacion` | R |
| `sp_acl_busca_datos_3410_fda` | `bditarjeta:td_movimientos_conciliacion` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `BDITARJETAService`. Requiere definir contrato OpenAPI.

### `bdimnsj` — Mensajería

**Criticidad:** 🟠 ALTA — 4 SPs de `bdiaclaracion` hacen cross-DB call

| SP de `bdiaclaracion` | Tablas accedidas en `bdimnsj` | Tipo |
|----|----|----|  
| `sp_buscaempleadohuella_alta` | `bdimnsj:mnsjr_trx_online`, `bdimnsj:mnsjr_trx_online_his` | R |
| `sp_bloqueocuenta_cred` | `bdimnsj:mnsjr_trx_online`, `bdimnsj:mnsjr_trx_online_his` | R |
| `sp_acl_consulta_ciudades` | `bdimnsj:mnsjr_trx_online`, `bdimnsj:mnsjr_trx_online_his` | R |
| `sp_bloqueo_cta_debito` | `bdimnsj:mnsjr_trx_online`, `bdimnsj:mnsjr_trx_online_his` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `MensajeríaService`. Requiere definir contrato OpenAPI.

### `BDINTEG` — BDINTEG

**Criticidad:** 🟡 MEDIA — 2 SPs de `bdiaclaracion` hacen cross-DB call

| SP de `bdiaclaracion` | Tablas accedidas en `BDINTEG` | Tipo |
|----|----|----|  
| `sp_busca_acl_por_folio_canales` | `BDINTEG:` | R |
| `sp_busca_aclaraciones_canales` | `BDINTEG:` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `BDINTEGService`. Requiere definir contrato OpenAPI.

---
## Funciones Built-in de Informix (sin equivalente directo en PostgreSQL)

| Función Informix | Usos detectados | Equivalente PostgreSQL | Riesgo |
|-----------------|-----------------|----------------------|--------|
| `DATETIME()` | 84 usos | `TIMESTAMP` | 🟡 Ajuste de sintaxis |
| `YEAR()` | 51 usos | `EXTRACT(YEAR FROM date)` | 🟡 Ajuste menor |
| `TRIM()` | 42 usos | `TRIM / BTRIM` | 🟡 Ajuste menor |
| `CURRENT()` | 18 usos | `NOW() / CURRENT_TIMESTAMP` | 🟡 Ajuste menor |
| `TODAY()` | 9 usos | `CURRENT_DATE` | 🟢 Directo |
| `DBINFO()` | 7 usos | `txid_current() / session_user` | 🔴 Sin equiv. directo |
| `NVL()` | 7 usos | `COALESCE` | 🟡 Ajuste menor |

---
## Matriz de impacto en cutover

| Dependencia | ¿Bloquea cutover? | Plan de continuidad | Owner |
|------------|-------------------|---------------------|-------|
| IBM Informix IDS | ✅ SÍ (es el motor) | Aurora PostgreSQL 15+ | DBA + Cloud Architect |
| Scheduler AIX | ✅ SÍ (batch jobs) | AWS EventBridge Scheduler | DevOps / Infra |
| `BDINTEG` cross-DB | ✅ SÍ si no tiene API | API interna de `BDINTEGService` | Architect AM |
| `bdiaclaracion` cross-DB | ✅ SÍ si no tiene API | API interna de `AclaracionesService` | Architect AM |
| `bdicheq` cross-DB | ✅ SÍ si no tiene API | API interna de `Cheques/CuentasService` | Architect AM |
| `bdicred` cross-DB | ✅ SÍ si no tiene API | API interna de `CréditosService` | Architect AM |
| `bdidomi` cross-DB | ✅ SÍ si no tiene API | API interna de `BDIDOMIService` | Architect AM |
| CONDUSEF (portal regulatorio) | 🟡 Parcial | Evaluar reemplazo o mantener integración | Architect AM |
| CNBV (reportes R27) | 🟡 Parcial | Evaluar reemplazo o mantener integración | Architect AM |
| SmartVista (cargos) | 🟡 Parcial | Evaluar reemplazo o mantener integración | Architect AM |
| Built-ins SPL | 🟡 Parcial (reescritura) | Mapping en capa de aplicación | Dev Team |


---
*Generado por: Specialist — Informix SPL Analysis · 2026-07-03 · Evidencia: source/informix/bdiaclaracion_*.sql (análisis estático de 70 archivos SQL) · análisis estático de archivos SQL*

<!-- LOG-DATA-BEGIN -->
## Sistemas externos observados en logs — 2026-04-24
> Fuente: `source/logs/errores_bus_2026-04-24_*.txt` · Incorporado: 2026-08-01

> Sin sistemas externos identificados en los logs para este dominio.
<!-- LOG-DATA-END -->

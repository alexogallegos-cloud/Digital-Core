# D08 · SPEI — Dependencias Externas y Terceros

> **Componente:** LegacyCore · SPE-AM-001 · Etapa 1
> **Base de datos:** `bdispei` · IBM Informix IDS 14.10 / POWER-AIX
> **Wave:** Wave 2 · Riesgo: **CRÍTICO**
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
| DEP-03 | `bdiSPEI` (BDISPEI) | Cross-DB call (dominio interno) | 🟡 MEDIA | 1 SPs hacen cross-DB |
| DEP-04 | `bdiadminnomina` (BDIADMINNOMINA) | Cross-DB call (dominio interno) | 🟡 MEDIA | 2 SPs hacen cross-DB |
| DEP-05 | `bdicheq` (Cheques/Cuentas) | Cross-DB call (dominio interno) | 🔴 CRÍTICA | 26 SPs hacen cross-DB |
| DEP-06 | `bdinteg` (Integración/Auth) | Cross-DB call (dominio interno) | 🔴 CRÍTICA | 11 SPs hacen cross-DB |
| DEP-07 | `bdispei` (SPEI) | Cross-DB call (dominio interno) | 🔴 CRÍTICA | 16 SPs hacen cross-DB |
| DEP-08 | `bdispeua` (BDISPEUA) | Cross-DB call (dominio interno) | 🟡 MEDIA | 1 SPs hacen cross-DB |
| DEP-09 | `paginterban` (PAGINTERBAN) | Cross-DB call (dominio interno) | 🟡 MEDIA | 1 SPs hacen cross-DB |
| DEP-10 | `sysmaster` (Sysmaster (Informix interno)) | Cross-DB call (dominio interno) | 🟠 ALTA | 6 SPs hacen cross-DB |
| DEP-11 | `terceros` (Terceros / Convenios) | Cross-DB call (dominio interno) | 🟡 MEDIA | 1 SPs hacen cross-DB |
| DEP-12 | Banxico (protocolo SPEI certificado) | Sistema externo | 🔴 CRÍTICA | Detectado en comentarios / nombres de SP |
| DEP-13 | CECOBAN | Sistema externo | 🟠 ALTA | Detectado en comentarios / nombres de SP |
| DEP-14 | Banco destino (interbancario) | Sistema externo | 🟠 ALTA | Detectado en comentarios / nombres de SP |
| DEP-15 | SmartVista | Sistema externo | 🟠 ALTA | Detectado en comentarios / nombres de SP |

---
## DEP-01 · IBM Informix IDS 14.10 — Motor de BD (a reemplazar)

**Criticidad:** 🔴 CRÍTICA — todo el dominio `bdispei` es SPL nativo de Informix.

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

**Criticidad:** 🔴 CRÍTICA — 26 SPs de `bdispei` hacen cross-DB call

| SP de `bdispei` | Tablas accedidas en `bdicheq` | Tipo |
|----|----|----|  
| `sp_consbancont` | `bdicheq:sc_fechas` | R |
| `sp_consctecte_web` | `bdicheq:sc_tarjeta`, `bdicheq:sc_maechq_temp`, `bdicheq:sc_maechq` | R |
| `sp_alertacargospei_pba` | `bdicheq:sc_movdia`, `bdicheq:sc_fechas`, `bdicheq:sc_movhis` | R |
| `sp_actbancont` | `bdicheq:sc_fechas` | R |
| `sp_alertacargospei` | `bdicheq:sc_movdia`, `bdicheq:sc_fechas`, `bdicheq:sc_movhis` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `Cheques/CuentasService`. Requiere definir contrato OpenAPI.

### `bdispei` — SPEI

**Criticidad:** 🔴 CRÍTICA — 16 SPs de `bdispei` hacen cross-DB call

| SP de `bdispei` | Tablas accedidas en `bdispei` | Tipo |
|----|----|----|  
| `sp_acthorarios` | `bdispei:` | R |
| `sp_altactaspei` | `bdispei:tblclabebloqueo` | R |
| `sp_gen_msj` | `bdispei:tbl_registro_msj` | R |
| `sp_coas_envio_exp1` | `bdispei:tbldetalle`, `bdispei:tblfoliocoasenv`, `bdispei:tblpago` | R |
| `sp_genera_reportes_spei` | `bdispei:tblctrlproceso` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `SPEIService`. Requiere definir contrato OpenAPI.

### `bdinteg` — Integración/Auth

**Criticidad:** 🔴 CRÍTICA — 11 SPs de `bdispei` hacen cross-DB call

| SP de `bdispei` | Tablas accedidas en `bdinteg` | Tipo |
|----|----|----|  
| `sp_abonocanelapago` | `bdinteg:si_empresas`, `bdinteg:dual` | R |
| `sp_generaconta` | `bdinteg:si_prodtran` | R |
| `sp_altactaspei` | `bdinteg:si_bancos` | R |
| `sp_calc_comasiva` | `bdinteg:` | R |
| `graba_spei` | `bdinteg:si_fechas` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `Integración/AuthService`. Requiere definir contrato OpenAPI.

### `sysmaster` — Sysmaster (Informix interno)

**Criticidad:** 🟠 ALTA — 6 SPs de `bdispei` hacen cross-DB call

| SP de `bdispei` | Tablas accedidas en `sysmaster` | Tipo |
|----|----|----|  
| `sp_coas_recibidos` | `sysmaster:systabnames` | R |
| `sp_coas_envio_exp1` | `sysmaster:systabnames` | R |
| `sp_cambio_fecha` | `sysmaster:systabnames` | R |
| `sp_alertacargospei_exp1` | `sysmaster:systabnames` | R |
| `sp_coas_recibidos_exp1` | `sysmaster:systabnames` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `Sysmaster (Informix interno)Service`. Requiere definir contrato OpenAPI.

### `bdiadminnomina` — BDIADMINNOMINA

**Criticidad:** 🟡 MEDIA — 2 SPs de `bdispei` hacen cross-DB call

| SP de `bdispei` | Tablas accedidas en `bdiadminnomina` | Tipo |
|----|----|----|  
| `sp_calc_comasiva` | `bdiadminnomina:` | R |
| `sp_calc_comasiva_web` | `bdiadminnomina:` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `BDIADMINNOMINAService`. Requiere definir contrato OpenAPI.

### `bdispeua` — BDISPEUA

**Criticidad:** 🟡 MEDIA — 1 SPs de `bdispei` hacen cross-DB call

| SP de `bdispei` | Tablas accedidas en `bdispeua` | Tipo |
|----|----|----|  
| `consulta_bancos` | `bdispeua:bancos` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `BDISPEUAService`. Requiere definir contrato OpenAPI.

### `paginterban` — PAGINTERBAN

**Criticidad:** 🟡 MEDIA — 1 SPs de `bdispei` hacen cross-DB call

| SP de `bdispei` | Tablas accedidas en `paginterban` | Tipo |
|----|----|----|  
| `consulta_bancos` | `paginterban:bancos` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `PAGINTERBANService`. Requiere definir contrato OpenAPI.

### `terceros` — Terceros / Convenios

**Criticidad:** 🟡 MEDIA — 1 SPs de `bdispei` hacen cross-DB call

| SP de `bdispei` | Tablas accedidas en `terceros` | Tipo |
|----|----|----|  
| `graba_spei` | `terceros:convenio_mn` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `Terceros / ConveniosService`. Requiere definir contrato OpenAPI.

### `bdiSPEI` — BDISPEI

**Criticidad:** 🟡 MEDIA — 1 SPs de `bdispei` hacen cross-DB call

| SP de `bdispei` | Tablas accedidas en `bdiSPEI` | Tipo |
|----|----|----|  
| `sp_generadevpago` | `bdiSPEI:tblPago` | R |

**En el target:** cada cross-DB call se convierte en llamada API interna a `BDISPEIService`. Requiere definir contrato OpenAPI.

---
## Funciones Built-in de Informix (sin equivalente directo en PostgreSQL)

| Función Informix | Usos detectados | Equivalente PostgreSQL | Riesgo |
|-----------------|-----------------|----------------------|--------|
| `TRIM()` | 58 usos | `TRIM / BTRIM` | 🟡 Ajuste menor |
| `CURRENT()` | 23 usos | `NOW() / CURRENT_TIMESTAMP` | 🟡 Ajuste menor |
| `DATETIME()` | 19 usos | `TIMESTAMP` | 🟡 Ajuste de sintaxis |
| `YEAR()` | 17 usos | `EXTRACT(YEAR FROM date)` | 🟡 Ajuste menor |
| `EXTEND()` | 14 usos | `CAST(x AS TIMESTAMP(n))` | 🟡 Ajuste menor |
| `NVL()` | 7 usos | `COALESCE` | 🟡 Ajuste menor |
| `DBINFO()` | 6 usos | `txid_current() / session_user` | 🔴 Sin equiv. directo |
| `TODAY()` | 3 usos | `CURRENT_DATE` | 🟢 Directo |

---
## Matriz de impacto en cutover

| Dependencia | ¿Bloquea cutover? | Plan de continuidad | Owner |
|------------|-------------------|---------------------|-------|
| IBM Informix IDS | ✅ SÍ (es el motor) | Aurora PostgreSQL 15+ | DBA + Cloud Architect |
| Scheduler AIX | ✅ SÍ (batch jobs) | AWS EventBridge Scheduler | DevOps / Infra |
| `bdiSPEI` cross-DB | ✅ SÍ si no tiene API | API interna de `BDISPEIService` | Architect AM |
| `bdiadminnomina` cross-DB | ✅ SÍ si no tiene API | API interna de `BDIADMINNOMINAService` | Architect AM |
| `bdicheq` cross-DB | ✅ SÍ si no tiene API | API interna de `Cheques/CuentasService` | Architect AM |
| `bdinteg` cross-DB | ✅ SÍ si no tiene API | API interna de `Integración/AuthService` | Architect AM |
| `bdispei` cross-DB | ✅ SÍ si no tiene API | API interna de `SPEIService` | Architect AM |
| Banxico (protocolo SPEI certificado) | 🟡 Parcial | Evaluar reemplazo o mantener integración | Architect AM |
| CECOBAN | 🟡 Parcial | Evaluar reemplazo o mantener integración | Architect AM |
| Banco destino (interbancario) | 🟡 Parcial | Evaluar reemplazo o mantener integración | Architect AM |
| Built-ins SPL | 🟡 Parcial (reescritura) | Mapping en capa de aplicación | Dev Team |


---
*Generado por: Specialist — Informix SPL Analysis · 2026-07-03 · Evidencia: source/LegacyCore/informix/bdispei_*.sql (análisis estático de 70 archivos SQL) · análisis estático de archivos SQL*

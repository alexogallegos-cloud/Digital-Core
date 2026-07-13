# D09 · Mensajería — Dependencias Externas y Terceros

> **Componente:** BCOPCore · SPE-AM-001 · Etapa 1  
> **Base de datos:** `bdimnsj` · IBM Informix IDS 14.10 / POWER-AIX  
> **Última actualización:** 2026-07-03

---
**SME responsable:** Specialist SPL Analysis · Architect AM · Proveedor Latinia/StrikeIron · Security Officer
> Toda dependencia externa es un **bloqueador potencial del cutover** — requiere plan de continuidad.
---

## Por qué no hay package.json en Informix SPL

Las dependencias externas en SPL se manifiestan como: (1) nombres de proveedores en comentarios, 
(2) nombres de SPs que revelan integraciones, (3) cross-DB calls, (4) tablas temporales de intercambio, 
(5) funciones built-in del motor sin equivalente PostgreSQL.

## Resumen de dependencias detectadas

| # | Dependencia | Tipo | Criticidad | Evidencia |
|---|------------|------|-----------|----------|
| DEP-01 | Latinia | Plataforma mensajería externa | 🔴 CRÍTICA | `sp_suscriptores_act` (mod. ene-2024), comentarios |
| DEP-02 | StrikeIron | Validación de email | 🟠 ALTA | Comentarios en `sp_suscriptores_act` |
| DEP-03 | Innovattia | Reportería externa | 🟡 MEDIA | `sp_generar_reporte_innovattia`, tabla `tmp_sms_innovattia` |
| DEP-04 | Intercard | Pagos POS/ATM | 🟠 ALTA | `sp_confirma_evento`, cross-DB reads (8 SPs) |
| DEP-05 | Scheduler AIX | Orquestación batch | 🔴 CRÍTICA | SPs batch sin caller — invocados por scheduler externo |
| DEP-06 | IBM Informix IDS 14.10 | Motor de BD (a reemplazar) | 🔴 CRÍTICA | Todo el dominio |
| DEP-07 | Funciones SPL (7 tipos) | Built-ins sin equiv. PG | 🟠 ALTA | Detectadas en análisis estático |
| DEP-08 | bdinteg (cross-DB) | Backbone de autenticación | 🔴 CRÍTICA | 27 lecturas cross-DB — mayor dependencia externa |

---
## DEP-01 · Latinia — Plataforma de Mensajería (SMS / Email)

**Criticidad:** 🔴 CRÍTICA — el dominio `bdimnsj` existe para alimentar a Latinia.

| Atributo | Valor |
|----------|-------|
| Rol | Plataforma externa de envío de SMS y email a clientes BanCoppel |
| SPs de integración | `sp_suscriptores_act` (sync), `sp_registra_evento` (eventos) |
| Última modificación | Enero 2024 — integración activa y evolucionando |
| Datos transmitidos | Teléfonos, correos, nombres de clientes (**PII — LFPDPPP**) |
| Tabla de intercambio | `mnsjr_suscripcion_ctes`, `mnsjr_trx_online`, `mnsjr_trx_batch` |
| Riesgo cutover | Si el target usa AWS SNS/Pinpoint, todos los suscriptores deben migrarse |

**Evidencia en código:**

| SP | Contexto |
|----|---------|
| `sp_errormensaje` | `omez Velazquez     -- Proyecto  : Replica Errores Latinia.     -- Actividad : Se actualiza` |
| `sp_movregistroshist` | `iÃ³n de Tablas del proceso binario synMsgsProc de Latinia 	EXECUTE PROCEDURE "informix".sp` |
| `sp_registra_evento` | `alizo   :Angel Rene de la Llave     -- Proyecto : Latinia registro de eventos.     -- Acti` |
| `sp_registra_evento2018` | `alizo   :Angel Rene de la Llave     -- Proyecto : Latinia registro de eventos.     -- Acti` |

**Plan de acción:**
- [ ] Obtener contrato actual con Latinia: endpoints, API key, SLA, costo/mensaje
- [ ] Decidir: ¿se mantiene Latinia en target o se migra a AWS SNS/Pinpoint?
- [ ] Confirmar ubicación de servidores Latinia (¿México?) — LFPDPPP transferencia internacional
- [ ] Plan de migración de suscriptores durante parallel-run

---
## DEP-02 · StrikeIron — Validación de Email

**Criticidad:** 🟠 ALTA — valida correos antes de registrar suscriptores.

| Atributo | Valor |
|----------|-------|
| Rol | Validación de sintaxis y existencia de correos electrónicos |
| SP | `sp_suscriptores_act` (referencia en comentarios, ene-2024) |
| Datos transmitidos | Direcciones email (**PII**) |
| Riesgo | StrikeIron fue adquirido por Informatica en 2014 — verificar si sigue operativo |

**Evidencia:**

| SP | Contexto |
|----|---------|
| `sp_suscriptores_act` | `rreos que aun no han sido validados en el proceso StrikeIron -- y se procesen el dÃÂ­a si` |

**Plan de acción:**
- [ ] Confirmar si StrikeIron sigue activo en producción BanCoppel
- [ ] Evaluar alternativas: AWS SES validation, ZeroBounce, NeverBounce
- [ ] Definir comportamiento si el servicio no responde

---
## DEP-03 · Innovattia — Reportería

**Criticidad:** 🟡 MEDIA — genera reporte para integración con plataforma Innovattia.

| Atributo | Valor |
|----------|-------|
| SP | `sp_generar_reporte_innovattia` (107 LOC) |
| Tabla de intercambio | `tmp_sms_innovattia` (tabla temporal dedicada) |
| Fan-in | 0 — probablemente batch schedulado |
| Riesgo | Si Innovattia está inactivo, este SP es código muerto |

**Plan de acción:**
- [ ] Confirmar con BanCoppel si Innovattia sigue siendo proveedor activo
- [ ] Si activo: replicar como Lambda/Glue job en target
- [ ] Si inactivo: mover a lista de código muerto confirmado

---
## DEP-04 · Intercard — Procesamiento POS/ATM

**Criticidad:** 🟠 ALTA — `sp_confirma_evento` recibe confirmaciones de Intercard.

| Atributo | Valor |
|----------|-------|
| Rol | Confirmación de transacciones POS/ATM con tarjeta BanCoppel |
| DB propia | `intercard`, `intercardbpi` (en la misma instancia Informix) |
| SP clave | `sp_confirma_evento` — recibe pid_pos_atm, pid_deb_cre, pno_tarjeta, pimporte |
| Feature flag | `mnsj_param cod_param=5` — activa/desactiva la confirmación |
| Cross-DB reads | 8 SPs de `bdimnsj` leen datos de `intercard` |

**Plan de acción:**
- [ ] Definir si Intercard migra simultáneamente o en wave posterior
- [ ] Si migra después: ACL debe exponer `sp_confirma_evento` como REST endpoint
- [ ] Validar el feature flag cod_param=5 en producción

---
## DEP-05 · Scheduler (cron AIX / UC4) — Orquestación Batch

**Criticidad:** 🔴 CRÍTICA — sin scheduler los 8 jobs batch no se ejecutan.

| Atributo | Valor |
|----------|-------|
| Herramienta | [SME-PENDING] — UC4, Control-M, o cron nativo AIX |
| SPs orquestados | `sp_depura_mensajes`, `sp_suscriptores_act`, `sp_mover_mensajes`, `sp_genera_reporte_sms`, otros |
| Target equivalente | AWS EventBridge Scheduler + Step Functions |

**Acción urgente — inventario del scheduler:**
```bash
crontab -u informix -l 2>/dev/null
ls -la /var/spool/cron/crontabs/
find /opt /home -name "*.cron" 2>/dev/null | head -20
```

---
## DEP-06 · Funciones Built-in de Informix (a reemplazar en target)

**7 funciones Informix** detectadas en `bdimnsj` sin equivalente directo en PostgreSQL:

| Función Informix | Usos | Equivalente PostgreSQL | Riesgo |
|-----------------|------|----------------------|--------|
| `TRIM()` | 373 | `TRIM / BTRIM` | 🟡 Requiere ajuste |
| `NVL()` | 177 | `COALESCE` | 🟡 Requiere ajuste |
| `YEAR()` | 14 | `EXTRACT(YEAR FROM date)` | 🟡 Requiere ajuste |
| `MONTH()` | 14 | `EXTRACT(MONTH FROM date)` | 🟡 Requiere ajuste |
| `EXTEND()` | 6 | `CAST(x AS TIMESTAMP(n))` | 🟡 Requiere ajuste |
| `MDY()` | 3 | `MAKE_DATE(y,m,d)` | 🟡 Requiere ajuste |
| `DBINFO()` | 3 | `No equiv. directo — usar txid_current()` | 🔴 Sin equiv. directo |

---
## DEP-07 · `bdinteg` — Backbone de Autenticación (cross-DB)

**Criticidad:** 🔴 CRÍTICA — 27 SPs de `bdimnsj` leen de `bdinteg`.

Aunque `bdinteg` es un dominio interno (D02), su acceso cross-DB desde `bdimnsj` lo convierte en una
**dependencia de runtime** que debe resolverse antes de que `bdimnsj` pueda migrar.

| Atributo | Valor |
|----------|-------|
| Lecturas cross-DB | 27 SPs de `bdimnsj` leen catálogos y configuración de `bdinteg` |
| Tipo de acceso | Solo lectura (catálogos, configuración de plantillas, validaciones) |
| Impacto en wave | `bdimnsj` es Wave 1, pero depende de que `bdinteg` exponga una API de catálogos |
| Solución target | API de catálogos de `bdinteg` disponible antes o en paralelo con Wave 1 |

> **[SME-PENDING]** ¿Qué tablas específicas de `bdinteg` lee `bdimnsj`? Necesario para definir el contrato API mínimo que desbloquea Wave 1.

---
## Matriz de impacto en cutover

| Dependencia | ¿Bloquea cutover Wave 1? | Plan de continuidad | Owner |
|------------|-------------------------|---------------------|-------|
| Latinia | ✅ SÍ | Mantener Latinia o migrar a AWS SNS antes del cutover | Architect AM |
| StrikeIron | 🟡 Parcial (solo validación email) | Reemplazar por servicio alternativo | Architect AM |
| Innovattia | ❓ Validar si activo | Confirmar con BanCoppel | Domain Expert |
| Intercard | ✅ SÍ si migra antes | Exponer ACL endpoint para confirmación POS/ATM | Architect AM |
| Scheduler AIX | ✅ SÍ (batch jobs) | AWS EventBridge Scheduler | DevOps / Infra |
| IBM Informix IDS | ✅ SÍ (es el motor) | Aurora PostgreSQL 15+ | DBA |
| Built-ins SPL (7) | 🟡 Parcial (reescritura) | Mapping en capa de aplicación | Dev Team |
| bdinteg cross-DB | ✅ SÍ (27 lecturas) | API de catálogos bdinteg disponible | Architect AM |

---
*Generado por: Specialist — Informix SPL Analysis · 2026-07-03 · Evidencia: análisis estático de 47 archivos SQL*

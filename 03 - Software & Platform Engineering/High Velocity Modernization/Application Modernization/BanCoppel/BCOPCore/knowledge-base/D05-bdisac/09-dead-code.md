# D05 · Saldos y Cuentas — Análisis de Código Muerto

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

## Resumen ejecutivo

| Categoría | Cantidad | LOC (muestra) | Recomendación |
|-----------|---------|--------------|--------------|
| **Código muerto confirmado** | 19 SPs | 19,048 | **No migrar** — confirmar con SME |
| **Probablemente muerto** | 26 SPs | 22,010 | Validar con SME antes de excluir |
| **Riesgo ejecución dinámica** | 5 SPs | 7,107 | Verificar con trazas dinámicas |
| **Procesos batch** (ver 11-batch) | 0 SPs | 0 | **No son código muerto** — son scheduled |
| **SPs activos** (fan-in > 0) | 8 SPs | — | Migrar como microservicio/función |
| **Total muestra analizada** | 58 SPs | 61,079 | |

> **Ahorro potencial si se confirma el código muerto:** ~31.2% del LOC de la muestra (19,048 LOC) quedaría fuera del scope de migración.

> **Nota:** Análisis basado en 58 archivos SQL de los 563 totales del dominio. El porcentaje real puede variar.

## Riesgo crítico: llamadas dinámicas (`EXECUTE PROCEDURE` con variable)

`sp_actualizafechassac` (702 LOC) usa `EXECUTE PROCEDURE` con nombre variable — puede invocar SPs no detectados estáticamente.
`sp_actualizaregsuc` (418 LOC) usa `EXECUTE PROCEDURE` con nombre variable — puede invocar SPs no detectados estáticamente.
`sp_actualizastatusconvenio` (385 LOC) usa `EXECUTE PROCEDURE` con nombre variable — puede invocar SPs no detectados estáticamente.
`sp_asignaanio` (2833 LOC) usa `EXECUTE PROCEDURE` con nombre variable — puede invocar SPs no detectados estáticamente.
`sp_asignaaniopredial` (2769 LOC) usa `EXECUTE PROCEDURE` con nombre variable — puede invocar SPs no detectados estáticamente.

> **[SME-PENDING]** Verificar con DBA BanCoppel en `sysmaster:syssessions` qué SPs fueron ejecutados en los últimos 90 días.

## Código muerto confirmado (19 SPs)

Estos SPs tienen **fan-in=0** y nombres que indican copias de prueba, versiones obsoletas o código de desarrollador.

| SP | LOC | Lecturas | Escrituras | Razón |
|----|-----|----------|-----------|-------|
| `sp_app_valmonto_cpl` | 10833 | 19 tablas | 6 tablas | Iniciales de desarrollador: _cpl |
| `sp_aplica_pago_con_cargo_msw` | 2219 | 16 tablas | 4 tablas | Iniciales de desarrollador: _msw |
| `sp_app_aplicapagos_cred` | 1082 | 17 tablas | 2 tablas | Iniciales de desarrollador: _cred |
| `sp_app_consrevrem_web` | 639 | 2 tablas | 1 tablas | Iniciales de desarrollador: _web |
| `extrae_cont` | 561 | 4 tablas | 3 tablas | Iniciales de desarrollador: _cont |
| `sp_app_submitpayment_web` | 548 | 2 tablas | 1 tablas | Iniciales de desarrollador: _web |
| `sp_bitacoraws_antad` | 536 | 4 tablas | 1 tablas | Sufijo _ant indica copia de prueba/desarrollo |
| `sp_benefremesas_bts` | 500 | 1 tablas | 2 tablas | Iniciales de desarrollador: _bts |
| `sp_benefremesas_wu` | 359 | 2 tablas | 2 tablas | Iniciales de desarrollador: _wu |
| `sp_app_queryorder_prue` | 281 | 1 tablas | 1 tablas | Sufijo _pru indica copia de prueba/desarrollo |
| `sp_altascambioscentral_pba` | 253 | 4 tablas | 2 tablas | Sufijo _pba indica copia de prueba/desarrollo |
| `sp_app_valmonto_aut` | 250 | 5 tablas | 1 tablas | Iniciales de desarrollador: _aut |
| `sp_actualiza_sac_bts_sdep` | 239 | 12 tablas | 2 tablas | Iniciales de desarrollador: _sdep |
| `sp_actualizastatusconvenio_pba` | 153 | 2 tablas | 2 tablas | Sufijo _pba indica copia de prueba/desarrollo |
| `sp_actualizasac_bts_qryi` | 145 | 1 tablas | 2 tablas | Iniciales de desarrollador: _qryi |
| `sp_actualizasac_bts_sdep` | 119 | 0 tablas | 1 tablas | Iniciales de desarrollador: _sdep |
| `sp_actualizasac_wu_pay` | 115 | 0 tablas | 1 tablas | Iniciales de desarrollador: _pay |
| `sp_actualizasac_bts_payi` | 109 | 0 tablas | 1 tablas | Iniciales de desarrollador: _payi |
| `sp_actualizasac_bts_payc` | 107 | 0 tablas | 1 tablas | Iniciales de desarrollador: _payc |

> **[SME-PENDING]** Confirmar con DBA BanCoppel que ninguno es invocado desde job scheduler externo, script shell o trigger de base de datos.

## Probablemente código muerto (26 SPs)

Fan-in=0 en el callgraph estático. Pueden ser dead code o estar invocados dinámicamente / por scheduler externo.

| SP | LOC | R/W tablas | Clasificación preliminar |
|----|-----|-----------|-------------------------|
| `sp_bitacoragdf` | 3725 | R:12 W:3 | Fan-in=0 — validar con DBA |
| `sp_asignacuenta_edomex` | 2487 | R:13 W:3 | Fan-in=0 — validar con DBA |
| `sp_app_recordorder` | 2236 | R:24 W:3 | Fan-in=0 — validar con DBA |
| `sp_app_getorder` | 1659 | R:15 W:8 | Fan-in=0 — validar con DBA |
| `sp_altascambioscentral` | 1569 | R:5 W:2 | Fan-in=0 — validar con DBA |
| `sp_app_confirmorder` | 1455 | R:15 W:8 | Fan-in=0 — validar con DBA |
| `sp_app_recuperapayment` | 1344 | R:14 W:3 | Fan-in=0 — validar con DBA |
| `sp_app_mensajes` | 1244 | R:4 W:2 | Fan-in=0 — validar con DBA |
| `sp_asignabimestre` | 980 | R:2 W:1 | Fan-in=0 — validar con DBA |
| `sp_actualizaremesa` | 784 | R:10 W:4 | Fan-in=0 — validar con DBA |
| `sp_app_valmonto` | 562 | R:4 W:1 | Fan-in=0 — validar con DBA |
| `sp_axtel_validadv` | 526 | R:2 W:0 | Fan-in=0 — validar con DBA |
| `sp_app_paymentrejection` | 525 | R:1 W:1 | Fan-in=0 — validar con DBA |
| `sp_act_ine_bdrem` | 507 | R:4 W:1 | Fan-in=0 — validar con DBA |
| `sp_actualiza_cte_remesa` | 473 | R:4 W:2 | Fan-in=0 — validar con DBA |
| `sp_actualiza_datos` | 465 | R:9 W:2 | Fan-in=0 — validar con DBA |
| `sac_bts_movspaso` | 391 | R:9 W:3 | Fan-in=0 — validar con DBA |
| `sp_app_confirmpayment` | 305 | R:1 W:1 | Fan-in=0 — validar con DBA |
| `sp_app_consrevrem` | 183 | R:2 W:1 | Fan-in=0 — validar con DBA |
| `sp_alta_cardif` | 127 | R:3 W:1 | Fan-in=0 — validar con DBA |

> **[SME-PENDING]** Para cada SP: buscar en logs de ejecución si fue invocado en los últimos 90 días en producción.

## Impacto en el scope de migración

```
Total SPs analizados:          58
Código muerto confirmado:      19  (no migrar — pendiente confirmación SME)
Probable código muerto:        26  (validar)
Procesos batch:                0  (migrar como jobs — ver 11-batch-processes.md)
Riesgo dinámico:               5  (investigar)
SPs activos (fan-in > 0):      8
─────────────────────────────────────────────
Scope mínimo de migración:     ~8  SPs (activos + batch)
Scope máximo:                  ~39  SPs (excluyendo solo muerto confirmado)
```

> El scope real requiere validación con Domain Expert BanCoppel antes de comprometer al cliente.


---
*Generado por: Specialist — Informix SPL Analysis · 2026-07-03 · Evidencia: source/BCOPCore/informix/bdisac_*.sql (análisis estático de 58 archivos SQL) · callgraph-data.json (fan_in) + análisis de nombres*

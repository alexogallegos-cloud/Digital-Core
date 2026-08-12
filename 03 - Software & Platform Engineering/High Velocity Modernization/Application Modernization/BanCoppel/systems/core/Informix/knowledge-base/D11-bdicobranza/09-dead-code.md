# D11 · Cobranza — Análisis de Código Muerto

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

## Resumen ejecutivo

| Categoría | Cantidad | LOC (muestra) | Recomendación |
|-----------|---------|--------------|--------------|
| **Código muerto confirmado** | 21 SPs | 9,867 | **No migrar** — confirmar con SME |
| **Probablemente muerto** | 34 SPs | 13,214 | Validar con SME antes de excluir |
| **Riesgo ejecución dinámica** | 2 SPs | 33,645 | Verificar con trazas dinámicas |
| **Procesos batch** (ver 11-batch) | 10 SPs | 4,074 | **No son código muerto** — son scheduled |
| **SPs activos** (fan-in > 0) | 3 SPs | — | Migrar como microservicio/función |
| **Total muestra analizada** | 70 SPs | 64,198 | |

> **Ahorro potencial si se confirma el código muerto:** ~15.4% del LOC de la muestra (9,867 LOC) quedaría fuera del scope de migración.

> **Nota:** Análisis basado en 70 archivos SQL de los 311 totales del dominio. El porcentaje real puede variar.

## Riesgo crítico: llamadas dinámicas (`EXECUTE PROCEDURE` con variable)

`fn_formaretiquetaxml` (32559 LOC) usa `EXECUTE PROCEDURE` con nombre variable — puede invocar SPs no detectados estáticamente.
`sp_cat_conscartera` (1086 LOC) usa `EXECUTE PROCEDURE` con nombre variable — puede invocar SPs no detectados estáticamente.

> **[SME-PENDING]** Verificar con DBA BanCoppel en `sysmaster:syssessions` qué SPs fueron ejecutados en los últimos 90 días.

## Código muerto confirmado (21 SPs)

Estos SPs tienen **fan-in=0** y nombres que indican copias de prueba, versiones obsoletas o código de desarrollador.

| SP | LOC | Lecturas | Escrituras | Razón |
|----|-----|----------|-----------|-------|
| `sp_actualiza_catdirectoriocte_pba` | 3866 | 42 tablas | 12 tablas | Sufijo _pba indica copia de prueba/desarrollo |
| `sp_cat_cambia_estatus_cte` | 996 | 13 tablas | 3 tablas | Iniciales de desarrollador: _cte |
| `sp_asigna_cartera_agex` | 725 | 4 tablas | 1 tablas | Iniciales de desarrollador: _agex |
| `sp_actualiza_saldos_admin_tco` | 617 | 15 tablas | 2 tablas | Iniciales de desarrollador: _tco |
| `sp_cat_gen_info_prev` | 426 | 11 tablas | 2 tablas | Iniciales de desarrollador: _prev |
| `sp_carga_tabla_movimientos_agex` | 397 | 2 tablas | 1 tablas | Iniciales de desarrollador: _agex |
| `sp_cat_consulta_pagos_tc` | 354 | 9 tablas | 0 tablas | Iniciales de desarrollador: _tc |
| `sp_carga_tabla_movimientos_peticion_org` | 329 | 1 tablas | 2 tablas | Iniciales de desarrollador: _org |
| `sp_carga_tabla_movimientos_peticion_pba` | 328 | 1 tablas | 2 tablas | Sufijo _pba indica copia de prueba/desarrollo |
| `sp_cat_genera_testigo` | 307 | 3 tablas | 1 tablas | Sufijo _test indica copia de prueba/desarrollo |
| `sp_cat_ivr_gen_archmora_tco` | 306 | 7 tablas | 0 tablas | Iniciales de desarrollador: _tco |
| `sp_cat_ivr_gen_archbase_tco` | 277 | 9 tablas | 0 tablas | Iniciales de desarrollador: _tco |
| `sp_cargatelefonosburo_pba` | 214 | 7 tablas | 2 tablas | Sufijo _pba indica copia de prueba/desarrollo |
| `sp_archivo_compac_pba` | 196 | 7 tablas | 1 tablas | Sufijo _pba indica copia de prueba/desarrollo |
| `sp_carga_movimientos_ivr` | 105 | 2 tablas | 1 tablas | Iniciales de desarrollador: _ivr |
| `sp_cat_gen_nr_prev` | 104 | 5 tablas | 1 tablas | Iniciales de desarrollador: _prev |
| `sp_cat_graba_respuesta_llamada` | 99 | 1 tablas | 1 tablas | Sufijo _resp indica copia de prueba/desarrollo |
| `sp_auronix_msj` | 91 | 4 tablas | 0 tablas | Iniciales de desarrollador: _msj |
| `sp_cat_actualiza_resultado_gestion_his` | 73 | 1 tablas | 1 tablas | Iniciales de desarrollador: _his |
| `sp_carga_resultado_cat` | 44 | 1 tablas | 1 tablas | Iniciales de desarrollador: _cat |

> **[SME-PENDING]** Confirmar con DBA BanCoppel que ninguno es invocado desde job scheduler externo, script shell o trigger de base de datos.

## Probablemente código muerto (34 SPs)

Fan-in=0 en el callgraph estático. Pueden ser dead code o estar invocados dinámicamente / por scheduler externo.

| SP | LOC | R/W tablas | Clasificación preliminar |
|----|-----|-----------|-------------------------|
| `sp_cat_consulta_totales` | 1387 | R:25 W:2 | Fan-in=0 — validar con DBA |
| `sp_cat_ejecuta_mensaje` | 1242 | R:11 W:1 | Fan-in=0 — validar con DBA |
| `sp_cat_consulta_saldostc` | 1162 | R:22 W:5 | Fan-in=0 — validar con DBA |
| `sp_cat_modstadocte` | 987 | R:14 W:4 | Fan-in=0 — validar con DBA |
| `sp_cat_consparamcampania` | 945 | R:13 W:2 | Fan-in=0 — validar con DBA |
| `sp_cat_consulta_disponibilidad_cliente` | 838 | R:19 W:3 | Fan-in=0 — validar con DBA |
| `sp_cat_consulta_ultimo_convenio` | 766 | R:7 W:3 | Fan-in=0 — validar con DBA |
| `sp_actualiza_catdirectoriocte` | 630 | R:13 W:5 | Fan-in=0 — validar con DBA |
| `sp_carga_tabla_movimientos_peticion` | 411 | R:2 W:1 | Fan-in=0 — validar con DBA |
| `sp_cat_cargacartera` | 401 | R:11 W:2 | Fan-in=0 — validar con DBA |
| `sp_cat_carproductos` | 373 | R:7 W:0 | Fan-in=0 — validar con DBA |
| `sp_campania_experiencia_cliente` | 346 | R:11 W:1 | Fan-in=0 — validar con DBA |
| `sp_cat_cartelefonos` | 328 | R:6 W:2 | Fan-in=0 — validar con DBA |
| `sp_cat_ivr_gen_archmora1` | 313 | R:7 W:0 | Fan-in=0 — validar con DBA |
| `sp_cat_ivr_gen_archtgc` | 288 | R:9 W:0 | Fan-in=0 — validar con DBA |
| `sp_archivo_compac` | 285 | R:14 W:1 | Fan-in=0 — validar con DBA |
| `sp_cat_gb_pp_genarchex` | 261 | R:7 W:0 | Fan-in=0 — validar con DBA |
| `sp_cat_ivr_gen_arcctesexcluidos` | 259 | R:8 W:0 | Fan-in=0 — validar con DBA |
| `sp_cat_gen_nr_admin` | 214 | R:7 W:1 | Fan-in=0 — validar con DBA |
| `sp_actualiza_ejecutivoscat` | 199 | R:6 W:2 | Fan-in=0 — validar con DBA |

> **[SME-PENDING]** Para cada SP: buscar en logs de ejecución si fue invocado en los últimos 90 días en producción.

## Impacto en el scope de migración

```
Total SPs analizados:          70
Código muerto confirmado:      21  (no migrar — pendiente confirmación SME)
Probable código muerto:        34  (validar)
Procesos batch:                10  (migrar como jobs — ver 11-batch-processes.md)
Riesgo dinámico:               2  (investigar)
SPs activos (fan-in > 0):      3
─────────────────────────────────────────────
Scope mínimo de migración:     ~13  SPs (activos + batch)
Scope máximo:                  ~49  SPs (excluyendo solo muerto confirmado)
```

> El scope real requiere validación con Domain Expert BanCoppel antes de comprometer al cliente.


---
*Generado por: Specialist — Informix SPL Analysis · 2026-07-03 · Evidencia: source/BCOPCore/informix/bdicobranza_*.sql (análisis estático de 70 archivos SQL) · callgraph-data.json (fan_in) + análisis de nombres*

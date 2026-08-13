# D04 · Cheques / Cuentas — Análisis de Código Muerto

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

## Resumen ejecutivo

| Categoría | Cantidad | LOC (muestra) | Recomendación |
|-----------|---------|--------------|--------------|
| **Código muerto confirmado** | 28 SPs | 14,564 | **No migrar** — confirmar con SME |
| **Probablemente muerto** | 32 SPs | 7,447 | Validar con SME antes de excluir |
| **Riesgo ejecución dinámica** | 3 SPs | 4,494 | Verificar con trazas dinámicas |
| **Procesos batch** (ver 11-batch) | 5 SPs | 840 | **No son código muerto** — son scheduled |
| **SPs activos** (fan-in > 0) | 2 SPs | — | Migrar como microservicio/función |
| **Total muestra analizada** | 70 SPs | 29,065 | |

> **Ahorro potencial si se confirma el código muerto:** ~50.1% del LOC de la muestra (14,564 LOC) quedaría fuera del scope de migración.

> **Nota:** Análisis basado en 70 archivos SQL de los 1535 totales del dominio. El porcentaje real puede variar.

## Riesgo crítico: llamadas dinámicas (`EXECUTE PROCEDURE` con variable)

`sp_actualiza_control_cobranza_automatica` (1544 LOC) usa `EXECUTE PROCEDURE` con nombre variable — puede invocar SPs no detectados estáticamente.
`sp_actualiza_est_reg_contr_evid_notif_porta` (1456 LOC) usa `EXECUTE PROCEDURE` con nombre variable — puede invocar SPs no detectados estáticamente.
`sp_actualizaobservaciones` (1494 LOC) usa `EXECUTE PROCEDURE` con nombre variable — puede invocar SPs no detectados estáticamente.

> **[SME-PENDING]** Verificar con DBA BanCoppel en `sysmaster:syssessions` qué SPs fueron ejecutados en los últimos 90 días.

## Código muerto confirmado (28 SPs)

Estos SPs tienen **fan-in=0** y nombres que indican copias de prueba, versiones obsoletas o código de desarrollador.

| SP | LOC | Lecturas | Escrituras | Razón |
|----|-----|----------|-----------|-------|
| `abonoref_td` | 4319 | 38 tablas | 15 tablas | Iniciales de desarrollador: _td |
| `sp_abono_sd` | 3760 | 12 tablas | 2 tablas | Iniciales de desarrollador: _sd |
| `abono_ref_web` | 1475 | 34 tablas | 10 tablas | Iniciales de desarrollador: _web |
| `abono_ref_pos` | 766 | 17 tablas | 5 tablas | Iniciales de desarrollador: _pos |
| `sp_abono_sd_pbajlh` | 560 | 4 tablas | 0 tablas | Sufijo _pba indica copia de prueba/desarrollo |
| `abono_cred` | 455 | 15 tablas | 8 tablas | Iniciales de desarrollador: _cred |
| `sp_actualiza_chq_cap` | 313 | 5 tablas | 2 tablas | Iniciales de desarrollador: _cap |
| `abono_web` | 302 | 9 tablas | 2 tablas | Iniciales de desarrollador: _web |
| `sp_actmsje_edocta_cfd` | 213 | 2 tablas | 1 tablas | Iniciales de desarrollador: _cfd |
| `abono_atm` | 213 | 4 tablas | 0 tablas | Iniciales de desarrollador: _atm |
| `sp_actparamcierre_mib` | 201 | 2 tablas | 1 tablas | Iniciales de desarrollador: _mib |
| `sp_actualiza_portabilidad_web` | 185 | 4 tablas | 4 tablas | Iniciales de desarrollador: _web |
| `sp_actualiza_portabilidad_pba` | 179 | 1 tablas | 1 tablas | Sufijo _pba indica copia de prueba/desarrollo |
| `sp_activaciones_codi_isa` | 160 | 6 tablas | 2 tablas | Iniciales de desarrollador: _isa |
| `abono_ctas_comis_pba` | 142 | 3 tablas | 1 tablas | Sufijo _pba indica copia de prueba/desarrollo |
| `abono_ctas_ivas` | 142 | 3 tablas | 1 tablas | Iniciales de desarrollador: _ivas |
| `abono_ctas_ivas_pba` | 142 | 3 tablas | 1 tablas | Sufijo _pba indica copia de prueba/desarrollo |
| `sp_actparamcierre_alt` | 141 | 2 tablas | 1 tablas | Iniciales de desarrollador: _alt |
| `sp_actualizafechaconci_atm` | 110 | 2 tablas | 1 tablas | Iniciales de desarrollador: _atm |
| `sp_actualiza_retenidos_pos` | 106 | 5 tablas | 3 tablas | Iniciales de desarrollador: _pos |

> **[SME-PENDING]** Confirmar con DBA BanCoppel que ninguno es invocado desde job scheduler externo, script shell o trigger de base de datos.

## Probablemente código muerto (32 SPs)

Fan-in=0 en el callgraph estático. Pueden ser dead code o estar invocados dinámicamente / por scheduler externo.

| SP | LOC | R/W tablas | Clasificación preliminar |
|----|-----|-----------|-------------------------|
| `sp_actualizar_registros_indicadores` | 990 | R:8 W:4 | Fan-in=0 — validar con DBA |
| `sp_actualizar_registros_indicadores_1` | 917 | R:8 W:4 | Fan-in=0 — validar con DBA |
| `sp_actsdodiarioc` | 759 | R:14 W:3 | Fan-in=0 — validar con DBA |
| `sp_actualizar_indicadores` | 702 | R:2 W:0 | Fan-in=0 — validar con DBA |
| `abono` | 315 | R:9 W:2 | Fan-in=0 — validar con DBA |
| `sp_actualiza_portabilidad` | 307 | R:1 W:1 | Fan-in=0 — validar con DBA |
| `sp_actualizakelloggs` | 289 | R:10 W:3 | Fan-in=0 — validar con DBA |
| `sp_actsdomensualc` | 282 | R:6 W:4 | Fan-in=0 — validar con DBA |
| `sp_actualiza_reg_porta` | 218 | R:7 W:0 | Fan-in=0 — validar con DBA |
| `sp_actparampasomovshisold` | 196 | R:1 W:1 | Fan-in=0 — validar con DBA |
| `sp_actparamconcilchq` | 188 | R:2 W:1 | Fan-in=0 — validar con DBA |
| `sp_actparamactsdos` | 174 | R:2 W:1 | Fan-in=0 — validar con DBA |
| `sp_actparampasomovshis` | 172 | R:2 W:1 | Fan-in=0 — validar con DBA |
| `sp_actmarhuella` | 171 | R:4 W:1 | Fan-in=0 — validar con DBA |
| `sp_actparamactsdos_especial` | 150 | R:2 W:1 | Fan-in=0 — validar con DBA |
| `sp_actualiza_retenidos_spei_interpza` | 143 | R:5 W:3 | Fan-in=0 — validar con DBA |
| `abono_ctas_comis` | 142 | R:3 W:1 | Fan-in=0 — validar con DBA |
| `sp_abonos_operaciones` | 129 | R:1 W:1 | Fan-in=0 — validar con DBA |
| `sp_act_cuentas_bloqueadas` | 117 | R:5 W:3 | Fan-in=0 — validar con DBA |
| `sp_actsdotrimestralc` | 112 | R:2 W:1 | Fan-in=0 — validar con DBA |

> **[SME-PENDING]** Para cada SP: buscar en logs de ejecución si fue invocado en los últimos 90 días en producción.

## Impacto en el scope de migración

```
Total SPs analizados:          70
Código muerto confirmado:      28  (no migrar — pendiente confirmación SME)
Probable código muerto:        32  (validar)
Procesos batch:                5  (migrar como jobs — ver 11-batch-processes.md)
Riesgo dinámico:               3  (investigar)
SPs activos (fan-in > 0):      2
─────────────────────────────────────────────
Scope mínimo de migración:     ~7  SPs (activos + batch)
Scope máximo:                  ~42  SPs (excluyendo solo muerto confirmado)
```

> El scope real requiere validación con Domain Expert BanCoppel antes de comprometer al cliente.


---
*Generado por: Specialist — Informix SPL Analysis · 2026-07-03 · Evidencia: source/informix/bdicheq_*.sql (análisis estático de 70 archivos SQL) · callgraph-data.json (fan_in) + análisis de nombres*

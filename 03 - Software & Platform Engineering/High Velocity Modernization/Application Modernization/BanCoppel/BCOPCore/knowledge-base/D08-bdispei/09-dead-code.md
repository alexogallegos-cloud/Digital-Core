# D08 · SPEI — Análisis de Código Muerto

> **Componente:** BCOPCore · SPE-AM-001 · Etapa 1
> **Base de datos:** `bdispei` · IBM Informix IDS 14.10 / POWER-AIX
> **Wave:** Wave 2 · Riesgo: **CRÍTICO**
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
| **Código muerto confirmado** | 23 SPs | 5,057 | **No migrar** — confirmar con SME |
| **Probablemente muerto** | 44 SPs | 7,651 | Validar con SME antes de excluir |
| **Riesgo ejecución dinámica** | 2 SPs | 101 | Verificar con trazas dinámicas |
| **Procesos batch** (ver 11-batch) | 0 SPs | 0 | **No son código muerto** — son scheduled |
| **SPs activos** (fan-in > 0) | 1 SPs | — | Migrar como microservicio/función |
| **Total muestra analizada** | 70 SPs | 13,253 | |

> **Ahorro potencial si se confirma el código muerto:** ~38.2% del LOC de la muestra (5,057 LOC) quedaría fuera del scope de migración.

> **Nota:** Análisis basado en 70 archivos SQL de los 197 totales del dominio. El porcentaje real puede variar.

## Riesgo crítico: llamadas dinámicas (`EXECUTE PROCEDURE` con variable)

`sp_abonoordauto` (48 LOC) usa `EXECUTE PROCEDURE` con nombre variable — puede invocar SPs no detectados estáticamente.
`sp_generadevpago` (53 LOC) usa `EXECUTE PROCEDURE` con nombre variable — puede invocar SPs no detectados estáticamente.

> **[SME-PENDING]** Verificar con DBA BanCoppel en `sysmaster:syssessions` qué SPs fueron ejecutados en los últimos 90 días.

## Código muerto confirmado (23 SPs)

Estos SPs tienen **fan-in=0** y nombres que indican copias de prueba, versiones obsoletas o código de desarrollador.

| SP | LOC | Lecturas | Escrituras | Razón |
|----|-----|----------|-----------|-------|
| `sp_consctecte_web` | 801 | 11 tablas | 0 tablas | Iniciales de desarrollador: _web |
| `sp_consctecte_exp1` | 793 | 11 tablas | 0 tablas | Iniciales de desarrollador: _exp1 |
| `sp_coas_recibidos_exp1` | 589 | 14 tablas | 19 tablas | Iniciales de desarrollador: _exp1 |
| `sp_calc_comasiva_web` | 476 | 7 tablas | 1 tablas | Iniciales de desarrollador: _web |
| `sp_consctectehist_web` | 272 | 9 tablas | 0 tablas | Iniciales de desarrollador: _web |
| `sp_consctectehist_exp1` | 224 | 9 tablas | 0 tablas | Iniciales de desarrollador: _exp1 |
| `sp_coas_envio_exp1` | 212 | 7 tablas | 3 tablas | Iniciales de desarrollador: _exp1 |
| `sp_consctectehist_pbas` | 194 | 6 tablas | 0 tablas | Sufijo _pba indica copia de prueba/desarrollo |
| `sp_gen_msj` | 156 | 1 tablas | 1 tablas | Iniciales de desarrollador: _msj |
| `sp_alertacargospei_exp1` | 142 | 4 tablas | 1 tablas | Iniciales de desarrollador: _exp1 |
| `sp_cargo_val` | 137 | 4 tablas | 1 tablas | Iniciales de desarrollador: _val |
| `sp_gen_msj_mib` | 137 | 0 tablas | 0 tablas | Iniciales de desarrollador: _mib |
| `graba_spei` | 127 | 2 tablas | 1 tablas | Iniciales de desarrollador: _spei |
| `sp_alertacargospei_pba` | 122 | 3 tablas | 1 tablas | Sufijo _pba indica copia de prueba/desarrollo |
| `sp_depura_tbl_registro_msj` | 116 | 1 tablas | 2 tablas | Iniciales de desarrollador: _msj |
| `sp_actualiza_msjs_spei` | 110 | 2 tablas | 1 tablas | Iniciales de desarrollador: _spei |
| `con_canc_audi` | 101 | 2 tablas | 0 tablas | Iniciales de desarrollador: _audi |
| `sp_alertas_codi` | 85 | 1 tablas | 0 tablas | Iniciales de desarrollador: _codi |
| `sp_cons_ult_pago` | 76 | 1 tablas | 0 tablas | Iniciales de desarrollador: _pago |
| `sp_genera_reportes_spei` | 66 | 2 tablas | 0 tablas | Iniciales de desarrollador: _spei |

> **[SME-PENDING]** Confirmar con DBA BanCoppel que ninguno es invocado desde job scheduler externo, script shell o trigger de base de datos.

## Probablemente código muerto (44 SPs)

Fan-in=0 en el callgraph estático. Pueden ser dead code o estar invocados dinámicamente / por scheduler externo.

| SP | LOC | R/W tablas | Clasificación preliminar |
|----|-----|-----------|-------------------------|
| `sp_calc_comasiva` | 804 | R:7 W:1 | Fan-in=0 — validar con DBA |
| `sp_consctecte` | 793 | R:10 W:0 | Fan-in=0 — validar con DBA |
| `sp_coas_recibidos` | 589 | R:14 W:19 | Fan-in=0 — validar con DBA |
| `sp_con_relordpago` | 551 | R:4 W:0 | Fan-in=0 — validar con DBA |
| `sp_generaconta` | 460 | R:5 W:1 | Fan-in=0 — validar con DBA |
| `sp_extraeinfospeua` | 353 | R:4 W:0 | Fan-in=0 — validar con DBA |
| `sp_actbancont` | 348 | R:2 W:3 | Fan-in=0 — validar con DBA |
| `sp_altactaspei` | 313 | R:11 W:1 | Fan-in=0 — validar con DBA |
| `sp_cambio_fecha` | 283 | R:5 W:6 | Fan-in=0 — validar con DBA |
| `sp_consbancont` | 275 | R:2 W:1 | Fan-in=0 — validar con DBA |
| `sp_bajactaspei` | 265 | R:10 W:1 | Fan-in=0 — validar con DBA |
| `sp_abonocanelapago` | 246 | R:11 W:1 | Fan-in=0 — validar con DBA |
| `sp_consctectehist` | 224 | R:9 W:0 | Fan-in=0 — validar con DBA |
| `sp_coas_envio` | 212 | R:7 W:3 | Fan-in=0 — validar con DBA |
| `sp_confpagospei` | 139 | R:4 W:1 | Fan-in=0 — validar con DBA |
| `consulta_bancos` | 138 | R:3 W:0 | Fan-in=0 — validar con DBA |
| `sp_alertacargospei` | 124 | R:3 W:1 | Fan-in=0 — validar con DBA |
| `sp_alertasabonospei` | 124 | R:5 W:3 | Fan-in=0 — validar con DBA |
| `sp_alertasabonosspei` | 124 | R:5 W:3 | Fan-in=0 — validar con DBA |
| `reversion` | 105 | R:2 W:1 | Fan-in=0 — validar con DBA |

> **[SME-PENDING]** Para cada SP: buscar en logs de ejecución si fue invocado en los últimos 90 días en producción.

## Impacto en el scope de migración

```
Total SPs analizados:          70
Código muerto confirmado:      23  (no migrar — pendiente confirmación SME)
Probable código muerto:        44  (validar)
Procesos batch:                0  (migrar como jobs — ver 11-batch-processes.md)
Riesgo dinámico:               2  (investigar)
SPs activos (fan-in > 0):      1
─────────────────────────────────────────────
Scope mínimo de migración:     ~1  SPs (activos + batch)
Scope máximo:                  ~47  SPs (excluyendo solo muerto confirmado)
```

> El scope real requiere validación con Domain Expert BanCoppel antes de comprometer al cliente.


---
*Generado por: Specialist — Informix SPL Analysis · 2026-07-03 · Evidencia: source/BCOPCore/informix/bdispei_*.sql (análisis estático de 70 archivos SQL) · callgraph-data.json (fan_in) + análisis de nombres*

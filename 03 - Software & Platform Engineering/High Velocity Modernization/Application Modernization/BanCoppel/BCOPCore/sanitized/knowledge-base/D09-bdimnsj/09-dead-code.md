# D09 · Mensajería — Análisis de Código Muerto

> **Componente:** LegacyCore · SPE-AM-001 · Etapa 1
> **Base de datos:** `bdimnsj` · IBM Informix IDS 14.10 / POWER-AIX
> **Última actualización:** 2026-07-03

---
**SME responsable:**
- Specialist — Informix SPL Analysis (análisis estático)
- Domain Expert — LegacyCore / Mensajería (validación funcional)
- Architect — Application Modernization (diseño target EventBus/AsyncAPI)
- QA Lead — Equivalencia funcional (casos de prueba)

> Secciones `[SME-PENDING]` requieren sesión de validación antes de Etapa 2.
---


## Resumen ejecutivo

| Categoría | Cantidad | LOC | Recomendación |
|-----------|---------|-----|--------------|
| **Código muerto confirmado** | 13 SPs | 3,214 | **No migrar** — confirmar con SME |
| **Probablemente muerto** | 18 SPs | 2,361 | Validar con SME antes de excluir |
| **Riesgo ejecución dinámica** | 1 SPs | 272 | Verificar si es llamado por `EXECUTE PROCEDURE` variable |
| **Procesos batch** (ver 11-batch) | 14 SPs | 3,000 | **No son código muerto** — son scheduled |
| **SP público activo** | 1 SP | 445 | `sp_registra_evento` (1,404 callers) |
| **Total dominio** | 47 SPs | 9,292 | |

> **Ahorro potencial si se confirma el código muerto:** ~34% del LOC total del dominio (3,214 LOC) quedaría fuera del scope de migración.

## ⚠️ Riesgo crítico: llamadas dinámicas invisibles

`sp_validacion_msj` (736 LOC) usa `EXECUTE PROCEDURE` con variable de nombre:
```sql
-- Patrón detectado en sp_validacion_msj:
EXECUTE PROCEDURE nombre_variable(...);
```
Esto significa que **cualquier SP del dominio puede estar siendo llamado en runtime** sin aparecer en el call graph estático. El análisis de código muerto es preliminar — requiere verificación con trazas dinámicas o revisión manual del catálogo de valores en `mnsj_param`.

## Código muerto confirmado (13 SPs)

Estos SPs son **copias de prueba o versiones obsoletas** de `sp_registra_evento` — misma firma, variaciones menores en implementación, sin callers externos. Seguros para excluir del scope de migración.

| SP | LOC | R/W | Últ. modificación | Razón |
|----|-----|-----|------------------|-------|
| `sp_confirma_evento_pba` | 127 | R:1 W:1 | N/D | Sufijo indica ambiente de prueba o versión obsoleta |
| `sp_confirmasmscte_bpi2` | 76 | R:1 W:0 | 19/12/2016 | Sufijo indica ambiente de prueba o versión obsoleta |
| `sp_registra_evento2018` | 221 | R:5 W:1 | 28/08/2014 | Copia de prueba/desarrollo de sp_registra_evento |
| `sp_registra_evento_bpi` | 59 | R:0 W:0 | N/D | Copia de prueba/desarrollo de sp_registra_evento |
| `sp_registra_evento_leo` | 361 | R:7 W:0 | 28/08/2014 | Copia de prueba/desarrollo de sp_registra_evento |
| `sp_registra_evento_prod` | 102 | R:1 W:0 | N/D | Copia de prueba/desarrollo de sp_registra_evento |
| `sp_registra_evento_pru3` | 445 | R:7 W:1 | 28/08/2014 | Copia de prueba/desarrollo de sp_registra_evento |
| `sp_registra_evento_prue2jjv` | 354 | R:6 W:1 | 09/11/2012 | Copia de prueba/desarrollo de sp_registra_evento |
| `sp_registra_evento_pruejjv` | 315 | R:6 W:1 | 26/03/2012 | Copia de prueba/desarrollo de sp_registra_evento |
| `sp_registra_evento_tmp_spei` | 446 | R:7 W:1 | 28/08/2014 | Copia de prueba/desarrollo de sp_registra_evento |
| `sp_registra_eventopba` | 137 | R:4 W:1 | 26/03/2012 | Copia de prueba/desarrollo de sp_registra_evento |
| `sp_suscriptores_act_pba` | 306 | R:2 W:1 | 17/05/2012 | Sufijo indica ambiente de prueba o versión obsoleta |
| `sp_suscriptores_tmp` | 265 | R:2 W:1 | 17/05/2012 | Sufijo indica ambiente de prueba o versión obsoleta |

**Evidencia de que son dead code:**
- `sp_registra_evento2018`: `vtransaction_id CHAR(10)` vs `CHAR(12)` en el SP activo — congelado en 2018
- `sp_registra_evento_pruejjv` / `sp_registra_evento_prue2jjv`: sufijo `jjv` = iniciales de desarrollador
- `sp_registra_evento_tmp_spei`: sufijo `_tmp` = temporal, proyecto SPEI antiguo
- `sp_registra_evento_leo`: nombre de desarrollador (`leo`) en el SP
- `sp_registra_evento_pru3`: sufijo `_pru3` = prueba número 3

> **[SME-PENDING]** Confirmar con DBA LegacyCore que ninguno de estos SPs es invocado desde algún proceso no documentado (job scheduler, script externo, Latinia callback).

## Probablemente código muerto (18 SPs)

Fan-in = 0 en el call graph estático. Pueden ser dead code o estar llamados dinámicamente.

| SP | LOC | R/W | Últ. modificación | Clasificación preliminar |
|----|-----|-----|------------------|--------------------------|
| `sp_act_susc_ctes` | 141 | R:1 W:0 | N/D | Fan-in=0 en call graph estático |
| `sp_actstatus_mnsj` | 73 | R:1 W:1 | N/D | Fan-in=0 en call graph estático |
| `sp_con_susc_ctes` | 169 | R:4 W:0 | N/D | Fan-in=0 en call graph estático |
| `sp_confirmasms` | 38 | R:1 W:0 | N/D | Fan-in=0 en call graph estático |
| `sp_confirmasmscte` | 45 | R:1 W:0 | N/D | Fan-in=0 en call graph estático |
| `sp_confirmasmscte_6dig` | 46 | R:1 W:0 | N/D | Fan-in=0 en call graph estático |
| `sp_confirmasmscte_mvl` | 61 | R:1 W:0 | N/D | Fan-in=0 en call graph estático |
| `sp_errormensaje` | 36 | R:0 W:1 | 16/07/2014 | Fan-in=0 en call graph estático |
| `sp_espacios_blancos2` | 42 | R:0 W:0 | N/D | Fan-in=0 en call graph estático |
| `sp_recupera_cuentatelefono` | 38 | R:1 W:0 | N/D | Fan-in=0 en call graph estático |
| `sp_recupera_estatussolic` | 152 | R:1 W:0 | N/D | Fan-in=0 en call graph estático |
| `sp_recupera_pago` | 115 | R:2 W:0 | N/D | Fan-in=0 en call graph estático |
| `sp_recupera_saldo` | 84 | R:1 W:0 | N/D | Fan-in=0 en call graph estático |
| `sp_recupera_saldo_inv` | 210 | R:1 W:0 | N/D | Fan-in=0 en call graph estático |
| `sp_registra_correotel` | 75 | R:1 W:0 | N/D | Fan-in=0 en call graph estático |
| `sp_suscriptores` | 264 | R:2 W:1 | 17/05/2012 | Fan-in=0 en call graph estático |
| `sp_valida_esnumerico` | 36 | R:0 W:0 | N/D | Fan-in=0 en call graph estático |
| `sp_validacion_msj` | 736 | R:7 W:2 | N/D | Fan-in=0 en call graph estático |

> **[SME-PENDING]** Para cada SP: buscar en logs de Informix (`sysmaster:syssessions`) si fue ejecutado en los últimos 90 días.

## Riesgo ejecución dinámica (1 SPs)

Estos SPs tienen fan-in=0 en el call graph estático **pero usan `EXECUTE PROCEDURE` con nombre variable** — pueden ser orquestadores de otros SPs sin que el análisis estático lo detecte.

| SP | LOC | Patrón dinámico | Impacto |
|----|-----|----------------|---------|
| `sp_confirma_evento` | 272 | EXECUTE PROCEDURE variable | Puede orquestar SPs no detectados |


## Impacto en el scope de migración

```
Total SPs en D09:           47
Código muerto confirmado:   13  (no migrar — pendiente confirmación SME)
Probable código muerto:     18  (validar)
Procesos batch:             14  (migrar como jobs — ver 11-batch-processes.md)
Riesgo dinámico:             1  (investigar)
SP público activo:           1  (sp_registra_evento → NotificationService API)
─────────────────────────────
Scope mínimo de migración:   1  SP (sin contar batch)
Scope máximo:                34  SP (excluyendo solo muerto confirmado)
```

---
*Generado por: Specialist — Informix SPL Analysis · 2026-07-03 · Evidencia: callgraph-data.json (fan_in) + análisis de nombres y firmas*

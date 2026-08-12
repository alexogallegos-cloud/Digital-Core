# D12 · Contabilidad — Análisis de Código Muerto

> **Componente:** LegacyCore · SPE-AM-001 · Etapa 1
> **Base de datos:** `bdicont` · IBM Informix IDS 14.10 / POWER-AIX
> **Wave:** Wave 4 · Riesgo: **ALTO**
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

## Resumen ejecutivo

| Categoría | Cantidad | LOC (muestra) | Recomendación |
|-----------|---------|--------------|--------------|
| **Código muerto confirmado** | 10 SPs | 2,102 | **No migrar** — confirmar con SME |
| **Probablemente muerto** | 32 SPs | 6,429 | Validar con SME antes de excluir |
| **Riesgo ejecución dinámica** | 0 SPs | 0 | Verificar con trazas dinámicas |
| **Procesos batch** (ver 11-batch) | 28 SPs | 11,098 | **No son código muerto** — son scheduled |
| **SPs activos** (fan-in > 0) | 0 SPs | — | Migrar como microservicio/función |
| **Total muestra analizada** | 70 SPs | 19,629 | |

> **Ahorro potencial si se confirma el código muerto:** ~10.7% del LOC de la muestra (2,102 LOC) quedaría fuera del scope de migración.

> **Nota:** Análisis basado en 70 archivos SQL de los 168 totales del dominio. El porcentaje real puede variar.

## Código muerto confirmado (10 SPs)

Estos SPs tienen **fan-in=0** y nombres que indican copias de prueba, versiones obsoletas o código de desarrollador.

| SP | LOC | Lecturas | Escrituras | Razón |
|----|-----|----------|-----------|-------|
| `libromayaux_old` | 1163 | 15 tablas | 4 tablas | Sufijo _old indica copia de prueba/desarrollo |
| `auditapase_ant` | 349 | 9 tablas | 5 tablas | Sufijo _ant indica copia de prueba/desarrollo |
| `act_sdom` | 176 | 3 tablas | 2 tablas | Iniciales de desarrollador: _sdom |
| `act_hist` | 109 | 4 tablas | 2 tablas | Iniciales de desarrollador: _hist |
| `act_mens` | 68 | 3 tablas | 2 tablas | Iniciales de desarrollador: _mens |
| `pase_act_hist` | 65 | 2 tablas | 1 tablas | Iniciales de desarrollador: _hist |
| `ins_act_hist` | 61 | 1 tablas | 1 tablas | Iniciales de desarrollador: _hist |
| `act_encab_ant` | 59 | 1 tablas | 1 tablas | Sufijo _ant indica copia de prueba/desarrollo |
| `depura_ctas` | 42 | 4 tablas | 2 tablas | Iniciales de desarrollador: _ctas |
| `factor_nat` | 10 | 0 tablas | 0 tablas | Iniciales de desarrollador: _nat |

> **[SME-PENDING]** Confirmar con DBA LegacyCore que ninguno es invocado desde job scheduler externo, script shell o trigger de base de datos.

## Probablemente código muerto (32 SPs)

Fan-in=0 en el callgraph estático. Pueden ser dead code o estar invocados dinámicamente / por scheduler externo.

| SP | LOC | R/W tablas | Clasificación preliminar |
|----|-----|-----------|-------------------------|
| `cancela_resultados` | 988 | R:18 W:9 | Fan-in=0 — validar con DBA |
| `llenareport` | 607 | R:7 W:2 | Fan-in=0 — validar con DBA |
| `libromayaux_diarios` | 452 | R:12 W:7 | Fan-in=0 — validar con DBA |
| `libromayaux_historicos` | 452 | R:10 W:7 | Fan-in=0 — validar con DBA |
| `inicializa` | 379 | R:15 W:8 | Fan-in=0 — validar con DBA |
| `ctasgiradas` | 337 | R:5 W:1 | Fan-in=0 — validar con DBA |
| `corrige_saldos` | 239 | R:3 W:2 | Fan-in=0 — validar con DBA |
| `nivelacion_ccostos` | 236 | R:2 W:1 | Fan-in=0 — validar con DBA |
| `detmauxsuc` | 235 | R:8 W:2 | Fan-in=0 — validar con DBA |
| `detmauxcon` | 231 | R:8 W:2 | Fan-in=0 — validar con DBA |
| `libmaysuc` | 230 | R:7 W:4 | Fan-in=0 — validar con DBA |
| `libmaycon` | 228 | R:7 W:4 | Fan-in=0 — validar con DBA |
| `act_histsdos` | 223 | R:5 W:3 | Fan-in=0 — validar con DBA |
| `movlocal` | 211 | R:7 W:2 | Fan-in=0 — validar con DBA |
| `act_sdomux` | 178 | R:3 W:2 | Fan-in=0 — validar con DBA |
| `contcie2` | 169 | R:4 W:2 | Fan-in=0 — validar con DBA |
| `ctas_nuevas` | 161 | R:3 W:1 | Fan-in=0 — validar con DBA |
| `ctas_nuevascc` | 160 | R:5 W:1 | Fan-in=0 — validar con DBA |
| `corestsucur` | 144 | R:2 W:2 | Fan-in=0 — validar con DBA |
| `act_sdodias` | 110 | R:4 W:2 | Fan-in=0 — validar con DBA |

> **[SME-PENDING]** Para cada SP: buscar en logs de ejecución si fue invocado en los últimos 90 días en producción.

## Impacto en el scope de migración

```
Total SPs analizados:          70
Código muerto confirmado:      10  (no migrar — pendiente confirmación SME)
Probable código muerto:        32  (validar)
Procesos batch:                28  (migrar como jobs — ver 11-batch-processes.md)
Riesgo dinámico:               0  (investigar)
SPs activos (fan-in > 0):      0
─────────────────────────────────────────────
Scope mínimo de migración:     ~28  SPs (activos + batch)
Scope máximo:                  ~60  SPs (excluyendo solo muerto confirmado)
```

> El scope real requiere validación con Domain Expert LegacyCore antes de comprometer al cliente.


---
*Generado por: Specialist — Informix SPL Analysis · 2026-07-03 · Evidencia: source/LegacyCore/informix/bdicont_*.sql (análisis estático de 70 archivos SQL) · callgraph-data.json (fan_in) + análisis de nombres*

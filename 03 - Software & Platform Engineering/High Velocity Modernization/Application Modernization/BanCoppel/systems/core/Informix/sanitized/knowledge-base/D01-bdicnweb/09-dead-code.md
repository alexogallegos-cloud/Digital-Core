# D01 · Canal Digital Web — Análisis de Código Muerto

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

## Resumen ejecutivo

| Categoría | Cantidad | LOC (muestra) | Recomendación |
|-----------|---------|--------------|--------------|
| **Código muerto confirmado** | 8 SPs | 121,970 | **No migrar** — confirmar con SME |
| **Probablemente muerto** | 34 SPs | 222,283 | Validar con SME antes de excluir |
| **Riesgo ejecución dinámica** | 2 SPs | 8,928 | Verificar con trazas dinámicas |
| **Procesos batch** (ver 11-batch) | 7 SPs | 39,801 | **No son código muerto** — son scheduled |
| **SPs activos** (fan-in > 0) | 6 SPs | — | Migrar como microservicio/función |
| **Total muestra analizada** | 57 SPs | 416,028 | |

> **Ahorro potencial si se confirma el código muerto:** ~29.3% del LOC de la muestra (121,970 LOC) quedaría fuera del scope de migración.

> **Nota:** Análisis basado en 57 archivos SQL de los 2184 totales del dominio. El porcentaje real puede variar.

## Riesgo crítico: llamadas dinámicas (`EXECUTE PROCEDURE` con variable)

`sp_actualizadomiciliocte` (3001 LOC) usa `EXECUTE PROCEDURE` con nombre variable — puede invocar SPs no detectados estáticamente.
`sp_adminitasas_cargarchivo` (5927 LOC) usa `EXECUTE PROCEDURE` con nombre variable — puede invocar SPs no detectados estáticamente.

> **[SME-PENDING]** Verificar con DBA LegacyCore en `sysmaster:syssessions` qué SPs fueron ejecutados en los últimos 90 días.

## Código muerto confirmado (8 SPs)

Estos SPs tienen **fan-in=0** y nombres que indican copias de prueba, versiones obsoletas o código de desarrollador.

| SP | LOC | Lecturas | Escrituras | Razón |
|----|-----|----------|-----------|-------|
| `sp_actualizacatczb_rh` | 19937 | 44 tablas | 14 tablas | Iniciales de desarrollador: _rh |
| `sp_actualizacatgcb_rh` | 19811 | 44 tablas | 14 tablas | Iniciales de desarrollador: _rh |
| `sp_actualizaclasificacion_gcb` | 19683 | 44 tablas | 14 tablas | Iniciales de desarrollador: _gcb |
| `sp_actualizaformato_gcb` | 19593 | 44 tablas | 14 tablas | Iniciales de desarrollador: _gcb |
| `sp_actualizatipo_gcb` | 19176 | 44 tablas | 14 tablas | Iniciales de desarrollador: _gcb |
| `sp_actualizazona_gcb` | 19091 | 44 tablas | 14 tablas | Iniciales de desarrollador: _gcb |
| `sp_actualizaregistrodevolverext_tef` | 4599 | 9 tablas | 3 tablas | Iniciales de desarrollador: _tef |
| `inserta_img_previo_soc2` | 80 | 1 tablas | 1 tablas | Iniciales de desarrollador: _soc2 |

> **[SME-PENDING]** Confirmar con DBA LegacyCore que ninguno es invocado desde job scheduler externo, script shell o trigger de base de datos.

## Probablemente código muerto (34 SPs)

Fan-in=0 en el callgraph estático. Pueden ser dead code o estar invocados dinámicamente / por scheduler externo.

| SP | LOC | R/W tablas | Clasificación preliminar |
|----|-----|-----------|-------------------------|
| `sp_activardesactivarproductos` | 25759 | R:33 W:12 | Fan-in=0 — validar con DBA |
| `sp_actualizasucursal` | 19502 | R:44 W:14 | Fan-in=0 — validar con DBA |
| `sp_actualizacalificaestatus` | 12747 | R:30 W:7 | Fan-in=0 — validar con DBA |
| `eliminasolicusuariomc` | 11482 | R:26 W:8 | Fan-in=0 — validar con DBA |
| `sp_actualizacionctepmsnom` | 11417 | R:26 W:9 | Fan-in=0 — validar con DBA |
| `sp_activalidaciontelefono` | 10406 | R:62 W:15 | Fan-in=0 — validar con DBA |
| `sp_administradorespm_complementoinfo` | 9441 | R:54 W:5 | Fan-in=0 — validar con DBA |
| `sp_actualizadomiciliocte2` | 8676 | R:31 W:5 | Fan-in=0 — validar con DBA |
| `sp_adm_validacampos` | 8593 | R:17 W:7 | Fan-in=0 — validar con DBA |
| `sp_actualizasufijospm` | 8518 | R:25 W:7 | Fan-in=0 — validar con DBA |
| `sp_actualizacambiobilletescaja` | 6995 | R:30 W:5 | Fan-in=0 — validar con DBA |
| `sp_actualizacentrallincred` | 6850 | R:30 W:5 | Fan-in=0 — validar con DBA |
| `sp_actualizacomprasdepositoscaja` | 6760 | R:29 W:5 | Fan-in=0 — validar con DBA |
| `sp_actualizaregistrocaja` | 6651 | R:29 W:5 | Fan-in=0 — validar con DBA |
| `sp_actualizasdosucursalcaja` | 6532 | R:29 W:5 | Fan-in=0 — validar con DBA |
| `sp_actualizacion_cheques_presentar` | 6392 | R:43 W:4 | Fan-in=0 — validar con DBA |
| `sp_actualizacionctepmsnom2` | 6025 | R:12 W:6 | Fan-in=0 — validar con DBA |
| `sp_abm_canal_cobro` | 5264 | R:12 W:5 | Fan-in=0 — validar con DBA |
| `sp_actualiza_admintransaciones` | 4735 | R:10 W:4 | Fan-in=0 — validar con DBA |
| `sp_actualizaparametrosccl` | 4672 | R:4 W:1 | Fan-in=0 — validar con DBA |

> **[SME-PENDING]** Para cada SP: buscar en logs de ejecución si fue invocado en los últimos 90 días en producción.

## Impacto en el scope de migración

```
Total SPs analizados:          57
Código muerto confirmado:      8  (no migrar — pendiente confirmación SME)
Probable código muerto:        34  (validar)
Procesos batch:                7  (migrar como jobs — ver 11-batch-processes.md)
Riesgo dinámico:               2  (investigar)
SPs activos (fan-in > 0):      6
─────────────────────────────────────────────
Scope mínimo de migración:     ~13  SPs (activos + batch)
Scope máximo:                  ~49  SPs (excluyendo solo muerto confirmado)
```

> El scope real requiere validación con Domain Expert LegacyCore antes de comprometer al cliente.


---
*Generado por: Specialist — Informix SPL Analysis · 2026-07-03 · Evidencia: source/LegacyCore/informix/bdicnweb_*.sql (análisis estático de 57 archivos SQL) · callgraph-data.json (fan_in) + análisis de nombres*

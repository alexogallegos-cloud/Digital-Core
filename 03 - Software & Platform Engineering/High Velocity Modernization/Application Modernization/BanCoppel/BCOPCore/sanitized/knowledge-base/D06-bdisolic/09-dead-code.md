# D06 · Solicitudes — Análisis de Código Muerto

> **Componente:** LegacyCore · SPE-AM-001 · Etapa 1
> **Base de datos:** `bdisolic` · IBM Informix IDS 14.10 / POWER-AIX
> **Wave:** Wave 3 · Riesgo: **ALTO**
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
| **Código muerto confirmado** | 23 SPs | 4,380 | **No migrar** — confirmar con SME |
| **Probablemente muerto** | 40 SPs | 5,627 | Validar con SME antes de excluir |
| **Riesgo ejecución dinámica** | 0 SPs | 0 | Verificar con trazas dinámicas |
| **Procesos batch** (ver 11-batch) | 3 SPs | 348 | **No son código muerto** — son scheduled |
| **SPs activos** (fan-in > 0) | 4 SPs | — | Migrar como microservicio/función |
| **Total muestra analizada** | 70 SPs | 11,821 | |

> **Ahorro potencial si se confirma el código muerto:** ~37.1% del LOC de la muestra (4,380 LOC) quedaría fuera del scope de migración.

> **Nota:** Análisis basado en 70 archivos SQL de los 549 totales del dominio. El porcentaje real puede variar.

## Código muerto confirmado (23 SPs)

Estos SPs tienen **fan-in=0** y nombres que indican copias de prueba, versiones obsoletas o código de desarrollador.

| SP | LOC | Lecturas | Escrituras | Razón |
|----|-----|----------|-----------|-------|
| `sp_adn_incrementa_lincred_pbajj` | 652 | 6 tablas | 3 tablas | Sufijo _pba indica copia de prueba/desarrollo |
| `sp_asigna_solicitud_soc_3p_ratj` | 439 | 9 tablas | 1 tablas | Iniciales de desarrollador: _ratj |
| `sp_asigna_solicitud_soc_ratj` | 439 | 9 tablas | 1 tablas | Iniciales de desarrollador: _ratj |
| `alta_sol_tc_cjunk_rodo` | 436 | 4 tablas | 1 tablas | Iniciales de desarrollador: _rodo |
| `alta_sol_tc_cjunk_web` | 436 | 4 tablas | 1 tablas | Iniciales de desarrollador: _web |
| `sp_asigna_solicitud_soc_2p_ratj` | 314 | 7 tablas | 1 tablas | Iniciales de desarrollador: _ratj |
| `alta_sol_tc` | 219 | 5 tablas | 1 tablas | Iniciales de desarrollador: _tc |
| `sp_asigna_solicitudaleatoria_mc` | 165 | 5 tablas | 1 tablas | Iniciales de desarrollador: _mc |
| `sp_adn_reporteinfodisp_web` | 144 | 1 tablas | 0 tablas | Iniciales de desarrollador: _web |
| `sp_adn_cosultacuenta_web` | 133 | 2 tablas | 0 tablas | Iniciales de desarrollador: _web |
| `sp_adn_inforeportes_web` | 128 | 3 tablas | 0 tablas | Iniciales de desarrollador: _web |
| `actualiza_solos_pba` | 127 | 2 tablas | 3 tablas | Sufijo _pba indica copia de prueba/desarrollo |
| `sp_altaclientehuellatitular_web` | 108 | 1 tablas | 0 tablas | Iniciales de desarrollador: _web |
| `asigna_numsol_web` | 108 | 2 tablas | 1 tablas | Iniciales de desarrollador: _web |
| `asigna_numsol_rodo` | 104 | 2 tablas | 1 tablas | Iniciales de desarrollador: _rodo |
| `sp_actualiza_statusmttobcycc_pba` | 101 | 2 tablas | 0 tablas | Sufijo _pba indica copia de prueba/desarrollo |
| `sp_adn_evalua_ing` | 62 | 1 tablas | 0 tablas | Iniciales de desarrollador: _ing |
| `sp_asigna_solicitud_mc` | 59 | 0 tablas | 0 tablas | Iniciales de desarrollador: _mc |
| `sp_actualiza_info_cac` | 50 | 0 tablas | 1 tablas | Iniciales de desarrollador: _cac |
| `sp_actualiza_respuestagrupo_cteprosp` | 49 | 0 tablas | 2 tablas | Sufijo _resp indica copia de prueba/desarrollo |

> **[SME-PENDING]** Confirmar con DBA LegacyCore que ninguno es invocado desde job scheduler externo, script shell o trigger de base de datos.

## Probablemente código muerto (40 SPs)

Fan-in=0 en el callgraph estático. Pueden ser dead code o estar invocados dinámicamente / por scheduler externo.

| SP | LOC | R/W tablas | Clasificación preliminar |
|----|-----|-----------|-------------------------|
| `sp_adn_incrementa_lincred` | 652 | R:6 W:3 | Fan-in=0 — validar con DBA |
| `alta_sol_tc_cjunk_rodo2` | 441 | R:5 W:1 | Fan-in=0 — validar con DBA |
| `alta_sol_tc_cjunk` | 438 | R:4 W:1 | Fan-in=0 — validar con DBA |
| `sp_actualiza_monto_lineas` | 343 | R:13 W:5 | Fan-in=0 — validar con DBA |
| `sp_adn_calculalinea` | 327 | R:4 W:0 | Fan-in=0 — validar con DBA |
| `sp_asigna_solicitud_soc_costo` | 314 | R:7 W:1 | Fan-in=0 — validar con DBA |
| `alta_sol_tc_cjunk_multicanal` | 250 | R:8 W:2 | Fan-in=0 — validar con DBA |
| `actualiza_solos` | 241 | R:5 W:3 | Fan-in=0 — validar con DBA |
| `sp_actualiza_solicitudes` | 172 | R:7 W:1 | Fan-in=0 — validar con DBA |
| `alta_sol_tcpba` | 158 | R:5 W:1 | Fan-in=0 — validar con DBA |
| `sp_actualizagrupo` | 150 | R:2 W:1 | Fan-in=0 — validar con DBA |
| `sp_adn_cosultacuenta` | 133 | R:2 W:0 | Fan-in=0 — validar con DBA |
| `sp_busca_sol_supervision` | 124 | R:2 W:1 | Fan-in=0 — validar con DBA |
| `sp_actualiza_resumscorfin` | 117 | R:1 W:1 | Fan-in=0 — validar con DBA |
| `sp_actualizanumsalariominimo` | 112 | R:4 W:2 | Fan-in=0 — validar con DBA |
| `sp_adn_obtenerctanomina` | 112 | R:2 W:0 | Fan-in=0 — validar con DBA |
| `sp_bitacora_motor` | 110 | R:2 W:1 | Fan-in=0 — validar con DBA |
| `sp_altaclientehuellaadicional` | 108 | R:1 W:0 | Fan-in=0 — validar con DBA |
| `sp_altaclientehuellatitular` | 108 | R:1 W:0 | Fan-in=0 — validar con DBA |
| `sp_apercredgrupo2` | 104 | R:5 W:2 | Fan-in=0 — validar con DBA |

> **[SME-PENDING]** Para cada SP: buscar en logs de ejecución si fue invocado en los últimos 90 días en producción.

## Impacto en el scope de migración

```
Total SPs analizados:          70
Código muerto confirmado:      23  (no migrar — pendiente confirmación SME)
Probable código muerto:        40  (validar)
Procesos batch:                3  (migrar como jobs — ver 11-batch-processes.md)
Riesgo dinámico:               0  (investigar)
SPs activos (fan-in > 0):      4
─────────────────────────────────────────────
Scope mínimo de migración:     ~7  SPs (activos + batch)
Scope máximo:                  ~47  SPs (excluyendo solo muerto confirmado)
```

> El scope real requiere validación con Domain Expert LegacyCore antes de comprometer al cliente.


---
*Generado por: Specialist — Informix SPL Analysis · 2026-07-03 · Evidencia: source/LegacyCore/informix/bdisolic_*.sql (análisis estático de 70 archivos SQL) · callgraph-data.json (fan_in) + análisis de nombres*

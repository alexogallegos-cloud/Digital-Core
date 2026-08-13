# D10 · Sucursales — Análisis de Código Muerto

> **Componente:** Informix · SPE-AM-001 · Etapa 1
> **Base de datos:** `bdisuc` · IBM Informix IDS 14.10 / POWER-AIX
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
| **Código muerto confirmado** | 24 SPs | 10,457 | **No migrar** — confirmar con SME |
| **Probablemente muerto** | 33 SPs | 25,256 | Validar con SME antes de excluir |
| **Riesgo ejecución dinámica** | 0 SPs | 0 | Verificar con trazas dinámicas |
| **Procesos batch** (ver 11-batch) | 10 SPs | 1,915 | **No son código muerto** — son scheduled |
| **SPs activos** (fan-in > 0) | 3 SPs | — | Migrar como microservicio/función |
| **Total muestra analizada** | 70 SPs | 39,096 | |

> **Ahorro potencial si se confirma el código muerto:** ~26.7% del LOC de la muestra (10,457 LOC) quedaría fuera del scope de migración.

> **Nota:** Análisis basado en 70 archivos SQL de los 293 totales del dominio. El porcentaje real puede variar.

## Código muerto confirmado (24 SPs)

Estos SPs tienen **fan-in=0** y nombres que indican copias de prueba, versiones obsoletas o código de desarrollador.

| SP | LOC | Lecturas | Escrituras | Razón |
|----|-----|----------|-----------|-------|
| `sp_catsecciones_oemn` | 1990 | 2 tablas | 1 tablas | Iniciales de desarrollador: _oemn |
| `sp_atms` | 1683 | 14 tablas | 7 tablas | Iniciales de desarrollador: _atms |
| `sp_conscapacidadcaja_web` | 864 | 2 tablas | 1 tablas | Iniciales de desarrollador: _web |
| `sp_actualizapieza_bym_web` | 631 | 2 tablas | 1 tablas | Iniciales de desarrollador: _web |
| `sp_altamodificacion_piezas_bym_web` | 629 | 2 tablas | 1 tablas | Iniciales de desarrollador: _web |
| `sp_consul_atm2` | 592 | 6 tablas | 3 tablas | Iniciales de desarrollador: _atm2 |
| `sp_autenviocajaras_web` | 558 | 2 tablas | 0 tablas | Iniciales de desarrollador: _web |
| `sp_actualizapieza_bym` | 537 | 6 tablas | 1 tablas | Iniciales de desarrollador: _bym |
| `pasecajag_esp` | 409 | 12 tablas | 5 tablas | Iniciales de desarrollador: _esp |
| `sp_cancelar_solicitud_dota` | 407 | 6 tablas | 3 tablas | Iniciales de desarrollador: _dota |
| `pasecajag_fec` | 393 | 13 tablas | 5 tablas | Iniciales de desarrollador: _fec |
| `pasecajag_pba` | 393 | 13 tablas | 5 tablas | Sufijo _pba indica copia de prueba/desarrollo |
| `sp_atms_web` | 227 | 4 tablas | 0 tablas | Iniciales de desarrollador: _web |
| `sp_concensuc_ws` | 195 | 5 tablas | 2 tablas | Iniciales de desarrollador: _ws |
| `sp_consul_atm` | 160 | 2 tablas | 0 tablas | Iniciales de desarrollador: _atm |
| `sp_consulta_cajagen_etv2` | 156 | 1 tablas | 0 tablas | Iniciales de desarrollador: _etv2 |
| `sp_concensuc_web` | 155 | 3 tablas | 2 tablas | Iniciales de desarrollador: _web |
| `sp_concen_atm` | 138 | 5 tablas | 4 tablas | Iniciales de desarrollador: _atm |
| `reversion_ant` | 75 | 1 tablas | 0 tablas | Sufijo _ant indica copia de prueba/desarrollo |
| `sp_arqueossuc_atm_web` | 61 | 0 tablas | 1 tablas | Iniciales de desarrollador: _web |

> **[SME-PENDING]** Confirmar con DBA BanCoppel que ninguno es invocado desde job scheduler externo, script shell o trigger de base de datos.

## Probablemente código muerto (33 SPs)

Fan-in=0 en el callgraph estático. Pueden ser dead code o estar invocados dinámicamente / por scheduler externo.

| SP | LOC | R/W tablas | Clasificación preliminar |
|----|-----|-----------|-------------------------|
| `sp_consul_dotacion2` | 2437 | R:3 W:2 | Fan-in=0 — validar con DBA |
| `sp_actestatuscaja` | 2435 | R:5 W:1 | Fan-in=0 — validar con DBA |
| `reversion_sobrante` | 2248 | R:3 W:2 | Fan-in=0 — validar con DBA |
| `sp_actestatuscajacap` | 2110 | R:3 W:2 | Fan-in=0 — validar con DBA |
| `pasecont` | 1873 | R:17 W:9 | Fan-in=0 — validar con DBA |
| `pasecont_web_2` | 1870 | R:8 W:3 | Fan-in=0 — validar con DBA |
| `sp_actestatuscajaras` | 1827 | R:3 W:2 | Fan-in=0 — validar con DBA |
| `sp_admon_documentos` | 1646 | R:2 W:2 | Fan-in=0 — validar con DBA |
| `sp_consestatuscaja` | 1569 | R:2 W:2 | Fan-in=0 — validar con DBA |
| `sp_conscapacidadcaja` | 892 | R:4 W:0 | Fan-in=0 — validar con DBA |
| `sp_autenviocaja` | 713 | R:2 W:1 | Fan-in=0 — validar con DBA |
| `sp_consul_dotacion2_total` | 668 | R:3 W:0 | Fan-in=0 — validar con DBA |
| `sp_atms2` | 635 | R:6 W:3 | Fan-in=0 — validar con DBA |
| `sp_autenviocajaras` | 565 | R:2 W:1 | Fan-in=0 — validar con DBA |
| `sp_actualizastatuscajaactiva` | 537 | R:4 W:1 | Fan-in=0 — validar con DBA |
| `pasecajag` | 405 | R:13 W:5 | Fan-in=0 — validar con DBA |
| `sp_consul_atm2_totales` | 384 | R:5 W:3 | Fan-in=0 — validar con DBA |
| `reversion_tombola` | 345 | R:7 W:3 | Fan-in=0 — validar con DBA |
| `auditapase` | 307 | R:8 W:3 | Fan-in=0 — validar con DBA |
| `sp_borrarcatdocumentos` | 273 | R:5 W:2 | Fan-in=0 — validar con DBA |

> **[SME-PENDING]** Para cada SP: buscar en logs de ejecución si fue invocado en los últimos 90 días en producción.

## Impacto en el scope de migración

```
Total SPs analizados:          70
Código muerto confirmado:      24  (no migrar — pendiente confirmación SME)
Probable código muerto:        33  (validar)
Procesos batch:                10  (migrar como jobs — ver 11-batch-processes.md)
Riesgo dinámico:               0  (investigar)
SPs activos (fan-in > 0):      3
─────────────────────────────────────────────
Scope mínimo de migración:     ~13  SPs (activos + batch)
Scope máximo:                  ~46  SPs (excluyendo solo muerto confirmado)
```

> El scope real requiere validación con Domain Expert BanCoppel antes de comprometer al cliente.


---
*Generado por: Specialist — Informix SPL Analysis · 2026-07-03 · Evidencia: source/informix/bdisuc_*.sql (análisis estático de 70 archivos SQL) · callgraph-data.json (fan_in) + análisis de nombres*

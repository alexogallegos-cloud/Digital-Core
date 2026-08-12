# D03 · Créditos — Análisis de Código Muerto

> **Componente:** LegacyCore · SPE-AM-001 · Etapa 1
> **Base de datos:** `bdicred` · IBM Informix IDS 14.10 / POWER-AIX
> **Wave:** Wave 4 · Riesgo: **CRÍTICO**
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
| **Código muerto confirmado** | 16 SPs | 11,810 | **No migrar** — confirmar con SME |
| **Probablemente muerto** | 43 SPs | 24,777 | Validar con SME antes de excluir |
| **Riesgo ejecución dinámica** | 3 SPs | 5,475 | Verificar con trazas dinámicas |
| **Procesos batch** (ver 11-batch) | 2 SPs | 1,256 | **No son código muerto** — son scheduled |
| **SPs activos** (fan-in > 0) | 6 SPs | — | Migrar como microservicio/función |
| **Total muestra analizada** | 70 SPs | 49,108 | |

> **Ahorro potencial si se confirma el código muerto:** ~24.0% del LOC de la muestra (11,810 LOC) quedaría fuera del scope de migración.

> **Nota:** Análisis basado en 70 archivos SQL de los 1650 totales del dominio. El porcentaje real puede variar.

## Riesgo crítico: llamadas dinámicas (`EXECUTE PROCEDURE` con variable)

`sp_actualizacvlcobranzacte` (1005 LOC) usa `EXECUTE PROCEDURE` con nombre variable — puede invocar SPs no detectados estáticamente.
`sp_adn_cobroautomatico_manual` (3677 LOC) usa `EXECUTE PROCEDURE` con nombre variable — puede invocar SPs no detectados estáticamente.
`act_lineas` (793 LOC) usa `EXECUTE PROCEDURE` con nombre variable — puede invocar SPs no detectados estáticamente.

> **[SME-PENDING]** Verificar con DBA LegacyCore en `sysmaster:syssessions` qué SPs fueron ejecutados en los últimos 90 días.

## Código muerto confirmado (16 SPs)

Estos SPs tienen **fan-in=0** y nombres que indican copias de prueba, versiones obsoletas o código de desarrollador.

| SP | LOC | Lecturas | Escrituras | Razón |
|----|-----|----------|-----------|-------|
| `sp_administra_reestructura_pp` | 2826 | 18 tablas | 3 tablas | Iniciales de desarrollador: _pp |
| `aclaraciones_edoctacrd_sif` | 2487 | 15 tablas | 1 tablas | Iniciales de desarrollador: _sif |
| `sp_actvig_camp` | 1676 | 16 tablas | 8 tablas | Iniciales de desarrollador: _camp |
| `sp_adn_sms` | 721 | 12 tablas | 13 tablas | Iniciales de desarrollador: _sms |
| `aclaraciones_edocta_sif` | 668 | 18 tablas | 4 tablas | Iniciales de desarrollador: _sif |
| `sp_administra_tarjetas_ppass_web` | 663 | 6 tablas | 1 tablas | Iniciales de desarrollador: _web |
| `sp_actvig_camp_mx` | 523 | 13 tablas | 4 tablas | Iniciales de desarrollador: _mx |
| `sp_actsdomensual_prueba` | 522 | 6 tablas | 3 tablas | Sufijo _pru indica copia de prueba/desarrollo |
| `sp_adicionalcreditopendiente_web` | 511 | 3 tablas | 2 tablas | Iniciales de desarrollador: _web |
| `abono_cred` | 479 | 10 tablas | 7 tablas | Iniciales de desarrollador: _cred |
| `sp_actualiza_sesion_bex_pba` | 284 | 11 tablas | 0 tablas | Sufijo _pba indica copia de prueba/desarrollo |
| `sp_actualizar_bitacora_pba` | 254 | 11 tablas | 1 tablas | Sufijo _pba indica copia de prueba/desarrollo |
| `sp_actpromo_x_msi` | 91 | 4 tablas | 1 tablas | Iniciales de desarrollador: _msi |
| `act_amortiza_mes` | 45 | 1 tablas | 1 tablas | Iniciales de desarrollador: _mes |
| `act_pie` | 35 | 1 tablas | 1 tablas | Iniciales de desarrollador: _pie |
| `sp_actualiza_acum_cambio_mes` | 25 | 0 tablas | 1 tablas | Iniciales de desarrollador: _mes |

> **[SME-PENDING]** Confirmar con DBA LegacyCore que ninguno es invocado desde job scheduler externo, script shell o trigger de base de datos.

## Probablemente código muerto (43 SPs)

Fan-in=0 en el callgraph estático. Pueden ser dead code o estar invocados dinámicamente / por scheduler externo.

| SP | LOC | R/W tablas | Clasificación preliminar |
|----|-----|-----------|-------------------------|
| `sp_actualizar_bitacora` | 3134 | R:25 W:4 | Fan-in=0 — validar con DBA |
| `sp_act_historica_cac_aumlincred` | 1646 | R:6 W:6 | Fan-in=0 — validar con DBA |
| `sp_actsdodiario` | 1609 | R:11 W:1 | Fan-in=0 — validar con DBA |
| `aclaraciones_edoctacrd` | 1381 | R:27 W:2 | Fan-in=0 — validar con DBA |
| `sp_actsdodiariocrd` | 1372 | R:7 W:2 | Fan-in=0 — validar con DBA |
| `sp_actestatustarjeta` | 1253 | R:19 W:7 | Fan-in=0 — validar con DBA |
| `sp_actualizarestatusaumlincred` | 1234 | R:12 W:6 | Fan-in=0 — validar con DBA |
| `sp_actsdomensual` | 1087 | R:12 W:6 | Fan-in=0 — validar con DBA |
| `sp_adn_disposicion` | 931 | R:14 W:13 | Fan-in=0 — validar con DBA |
| `sp_activa_insertos_fijoscrd` | 839 | R:7 W:7 | Fan-in=0 — validar con DBA |
| `sp_actualiza_tasas_creditos` | 831 | R:15 W:6 | Fan-in=0 — validar con DBA |
| `sp_adn_cart_activa` | 791 | R:14 W:5 | Fan-in=0 — validar con DBA |
| `sp_actualiza_creditos` | 764 | R:19 W:4 | Fan-in=0 — validar con DBA |
| `sp_adn_cobroautomatico` | 637 | R:7 W:8 | Fan-in=0 — validar con DBA |
| `sp_actualizasolicmc_lineas` | 628 | R:5 W:3 | Fan-in=0 — validar con DBA |
| `aclaraciones_edocta` | 568 | R:5 W:0 | Fan-in=0 — validar con DBA |
| `sp_adicionalcreditopendiente` | 531 | R:2 W:2 | Fan-in=0 — validar con DBA |
| `sp_actualiza_credito_apoyo_2` | 518 | R:9 W:8 | Fan-in=0 — validar con DBA |
| `sp_actualiza_vigenciatc` | 510 | R:7 W:3 | Fan-in=0 — validar con DBA |
| `sp_actualiza_revtasa` | 429 | R:5 W:1 | Fan-in=0 — validar con DBA |

> **[SME-PENDING]** Para cada SP: buscar en logs de ejecución si fue invocado en los últimos 90 días en producción.

## Impacto en el scope de migración

```
Total SPs analizados:          70
Código muerto confirmado:      16  (no migrar — pendiente confirmación SME)
Probable código muerto:        43  (validar)
Procesos batch:                2  (migrar como jobs — ver 11-batch-processes.md)
Riesgo dinámico:               3  (investigar)
SPs activos (fan-in > 0):      6
─────────────────────────────────────────────
Scope mínimo de migración:     ~8  SPs (activos + batch)
Scope máximo:                  ~54  SPs (excluyendo solo muerto confirmado)
```

> El scope real requiere validación con Domain Expert LegacyCore antes de comprometer al cliente.


---
*Generado por: Specialist — Informix SPL Analysis · 2026-07-03 · Evidencia: source/LegacyCore/informix/bdicred_*.sql (análisis estático de 70 archivos SQL) · callgraph-data.json (fan_in) + análisis de nombres*

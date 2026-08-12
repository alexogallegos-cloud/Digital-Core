# D02 · Integración y Autenticación — Análisis de Código Muerto

> **Componente:** BCOPCore · SPE-AM-001 · Etapa 1
> **Base de datos:** `bdinteg` · IBM Informix IDS 14.10 / POWER-AIX
> **Wave:** Wave 5 · Riesgo: **CRÍTICO**
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
| **Código muerto confirmado** | 17 SPs | 10,964 | **No migrar** — confirmar con SME |
| **Probablemente muerto** | 50 SPs | 30,373 | Validar con SME antes de excluir |
| **Riesgo ejecución dinámica** | 1 SPs | 2,934 | Verificar con trazas dinámicas |
| **Procesos batch** (ver 11-batch) | 0 SPs | 0 | **No son código muerto** — son scheduled |
| **SPs activos** (fan-in > 0) | 2 SPs | — | Migrar como microservicio/función |
| **Total muestra analizada** | 70 SPs | 44,996 | |

> **Ahorro potencial si se confirma el código muerto:** ~24.4% del LOC de la muestra (10,964 LOC) quedaría fuera del scope de migración.

> **Nota:** Análisis basado en 70 archivos SQL de los 2034 totales del dominio. El porcentaje real puede variar.

## Riesgo crítico: llamadas dinámicas (`EXECUTE PROCEDURE` con variable)

`sp_acivarserviciobpi_apolo` (2934 LOC) usa `EXECUTE PROCEDURE` con nombre variable — puede invocar SPs no detectados estáticamente.

> **[SME-PENDING]** Verificar con DBA BanCoppel en `sysmaster:syssessions` qué SPs fueron ejecutados en los últimos 90 días.

## Código muerto confirmado (17 SPs)

Estos SPs tienen **fan-in=0** y nombres que indican copias de prueba, versiones obsoletas o código de desarrollador.

| SP | LOC | Lecturas | Escrituras | Razón |
|----|-----|----------|-----------|-------|
| `alta_nip` | 4043 | 59 tablas | 12 tablas | Iniciales de desarrollador: _nip |
| `sp_actualiza_campos_uh` | 1603 | 40 tablas | 43 tablas | Iniciales de desarrollador: _uh |
| `sp_actstatusctecopnvoparam_club` | 1360 | 16 tablas | 11 tablas | Iniciales de desarrollador: _club |
| `sp_actualiza_info_cliente_opt` | 1187 | 22 tablas | 2 tablas | Iniciales de desarrollador: _opt |
| `sp_actualiza_id_consulta_pdf` | 838 | 6 tablas | 2 tablas | Iniciales de desarrollador: _pdf |
| `sp_actualiza_curp` | 738 | 3 tablas | 2 tablas | Iniciales de desarrollador: _curp |
| `sp_actcatalogos_sitesp_prb` | 237 | 2 tablas | 1 tablas | Iniciales de desarrollador: _prb |
| `sp_actualiza_cp_buro` | 155 | 3 tablas | 2 tablas | Iniciales de desarrollador: _buro |
| `sp_actualiza_domicilio_cac` | 148 | 2 tablas | 1 tablas | Iniciales de desarrollador: _cac |
| `sp_actualiza_contadores_ivr_web` | 131 | 2 tablas | 1 tablas | Iniciales de desarrollador: _web |
| `sp_actualiza_bitacora_ine` | 107 | 4 tablas | 3 tablas | Iniciales de desarrollador: _ine |
| `sp_actualiza_contadores_ivr` | 104 | 1 tablas | 0 tablas | Iniciales de desarrollador: _ivr |
| `sp_actualiza_mensajes_cel` | 98 | 1 tablas | 1 tablas | Iniciales de desarrollador: _cel |
| `sp_actualiza_mensajes_cel_web` | 98 | 1 tablas | 1 tablas | Iniciales de desarrollador: _web |
| `sp_actualiza_lugar_nac` | 43 | 1 tablas | 0 tablas | Iniciales de desarrollador: _nac |
| `sp_activausuario_bpi` | 42 | 2 tablas | 2 tablas | Sufijo _bpi indica copia de prueba/desarrollo |
| `sp_activausuario_bei` | 32 | 1 tablas | 1 tablas | Iniciales de desarrollador: _bei |

> **[SME-PENDING]** Confirmar con DBA BanCoppel que ninguno es invocado desde job scheduler externo, script shell o trigger de base de datos.

## Probablemente código muerto (50 SPs)

Fan-in=0 en el callgraph estático. Pueden ser dead code o estar invocados dinámicamente / por scheduler externo.

| SP | LOC | R/W tablas | Clasificación preliminar |
|----|-----|-----------|-------------------------|
| `act_encab` | 4164 | R:60 W:12 | Fan-in=0 — validar con DBA |
| `actividad` | 4078 | R:60 W:12 | Fan-in=0 — validar con DBA |
| `sp_actualiza_premio` | 3151 | R:15 W:6 | Fan-in=0 — validar con DBA |
| `sp_actualiza_identifi` | 2832 | R:6 W:4 | Fan-in=0 — validar con DBA |
| `sp_actualiza_info_cliente` | 2101 | R:24 W:5 | Fan-in=0 — validar con DBA |
| `bm_obten_lista_cuentas` | 1220 | R:3 W:2 | Fan-in=0 — validar con DBA |
| `sp_actcatalogos_sitesp` | 1203 | R:12 W:1 | Fan-in=0 — validar con DBA |
| `sp_actualiza_numerocalle` | 1163 | R:14 W:3 | Fan-in=0 — validar con DBA |
| `sp_acivarserviciobpi` | 1037 | R:14 W:3 | Fan-in=0 — validar con DBA |
| `sp_actnomcterfcalterno` | 918 | R:6 W:3 | Fan-in=0 — validar con DBA |
| `sp_actualiza_estadoine` | 918 | R:5 W:1 | Fan-in=0 — validar con DBA |
| `sp_actualiza_ctemovil` | 769 | R:3 W:4 | Fan-in=0 — validar con DBA |
| `sp_actstatenviocpel` | 529 | R:2 W:2 | Fan-in=0 — validar con DBA |
| `sp_activarserviciobm` | 439 | R:5 W:4 | Fan-in=0 — validar con DBA |
| `sp_actualiza_act_subact` | 433 | R:3 W:1 | Fan-in=0 — validar con DBA |
| `sp_actualiza_dominio_correos` | 419 | R:9 W:2 | Fan-in=0 — validar con DBA |
| `sp_act_sucursalsorteo` | 411 | R:6 W:2 | Fan-in=0 — validar con DBA |
| `sp_activadesactivaproductos` | 332 | R:5 W:2 | Fan-in=0 — validar con DBA |
| `sp_actualiza_cta_calificacion` | 313 | R:7 W:1 | Fan-in=0 — validar con DBA |
| `sp_actdepctesbcplcpl` | 303 | R:1 W:1 | Fan-in=0 — validar con DBA |

> **[SME-PENDING]** Para cada SP: buscar en logs de ejecución si fue invocado en los últimos 90 días en producción.

## Impacto en el scope de migración

```
Total SPs analizados:          70
Código muerto confirmado:      17  (no migrar — pendiente confirmación SME)
Probable código muerto:        50  (validar)
Procesos batch:                0  (migrar como jobs — ver 11-batch-processes.md)
Riesgo dinámico:               1  (investigar)
SPs activos (fan-in > 0):      2
─────────────────────────────────────────────
Scope mínimo de migración:     ~2  SPs (activos + batch)
Scope máximo:                  ~53  SPs (excluyendo solo muerto confirmado)
```

> El scope real requiere validación con Domain Expert BanCoppel antes de comprometer al cliente.


---
*Generado por: Specialist — Informix SPL Analysis · 2026-07-03 · Evidencia: source/BCOPCore/informix/bdinteg_*.sql (análisis estático de 70 archivos SQL) · callgraph-data.json (fan_in) + análisis de nombres*

# D07 · Aclaraciones — Análisis de Código Muerto

> **Componente:** Informix · SPE-AM-001 · Etapa 1
> **Base de datos:** `bdiaclaracion` · IBM Informix IDS 14.10 / POWER-AIX
> **Wave:** Wave 2 · Riesgo: **ALTO**
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
| **Código muerto confirmado** | 19 SPs | 26,162 | **No migrar** — confirmar con SME |
| **Probablemente muerto** | 46 SPs | 63,935 | Validar con SME antes de excluir |
| **Riesgo ejecución dinámica** | 0 SPs | 0 | Verificar con trazas dinámicas |
| **Procesos batch** (ver 11-batch) | 3 SPs | 2,355 | **No son código muerto** — son scheduled |
| **SPs activos** (fan-in > 0) | 2 SPs | — | Migrar como microservicio/función |
| **Total muestra analizada** | 70 SPs | 93,730 | |

> **Ahorro potencial si se confirma el código muerto:** ~27.9% del LOC de la muestra (26,162 LOC) quedaría fuera del scope de migración.

> **Nota:** Análisis basado en 70 archivos SQL de los 232 totales del dominio. El porcentaje real puede variar.

## Código muerto confirmado (19 SPs)

Estos SPs tienen **fan-in=0** y nombres que indican copias de prueba, versiones obsoletas o código de desarrollador.

| SP | LOC | Lecturas | Escrituras | Razón |
|----|-----|----------|-----------|-------|
| `sp_buscar_movimientos_cheques_his_old_canales` | 3784 | 46 tablas | 4 tablas | Sufijo _old indica copia de prueba/desarrollo |
| `sp_bitacora_siem` | 2414 | 41 tablas | 6 tablas | Iniciales de desarrollador: _siem |
| `sp_acl_busca_datos_3410_fda` | 2171 | 38 tablas | 2 tablas | Iniciales de desarrollador: _fda |
| `sp_acl_valida_dfa_devo` | 1875 | 38 tablas | 1 tablas | Sufijo _dev indica copia de prueba/desarrollo |
| `sp_busca_datos_3410_mx` | 1667 | 26 tablas | 4 tablas | Iniciales de desarrollador: _mx |
| `sp_busca_producto_cred_cliente_crd` | 1636 | 19 tablas | 3 tablas | Iniciales de desarrollador: _crd |
| `sp_busca_producto_cred_cuenta_crd` | 1590 | 19 tablas | 3 tablas | Iniciales de desarrollador: _crd |
| `sp_acl_reporte_log` | 1555 | 28 tablas | 1 tablas | Iniciales de desarrollador: _log |
| `sp_busca_producto_cred_tarjeta_crd` | 1540 | 19 tablas | 3 tablas | Iniciales de desarrollador: _crd |
| `sp_buscaempleadohuella_alta` | 1379 | 24 tablas | 0 tablas | Iniciales de desarrollador: _alta |
| `sp_busca_datos_3410_fda` | 1367 | 24 tablas | 1 tablas | Iniciales de desarrollador: _fda |
| `sp_bloqueocuenta_cred` | 974 | 14 tablas | 0 tablas | Iniciales de desarrollador: _cred |
| `sp_acl_busca_cliente_sv` | 951 | 15 tablas | 2 tablas | Iniciales de desarrollador: _sv |
| `sp_busca_nombre_core` | 920 | 23 tablas | 4 tablas | Iniciales de desarrollador: _core |
| `sp_acl_montototal_sv` | 874 | 14 tablas | 2 tablas | Iniciales de desarrollador: _sv |
| `sp_aplica_validacion_msi` | 752 | 21 tablas | 3 tablas | Iniciales de desarrollador: _msi |
| `sp_acl_es_cliente_sv` | 422 | 26 tablas | 1 tablas | Iniciales de desarrollador: _sv |
| `sp_acl_regulatorio27_mx` | 252 | 11 tablas | 1 tablas | Iniciales de desarrollador: _mx |
| `sp_actualiza_estatus_acl_eglobal_respondida` | 39 | 1 tablas | 0 tablas | Sufijo _resp indica copia de prueba/desarrollo |

> **[SME-PENDING]** Confirmar con DBA BanCoppel que ninguno es invocado desde job scheduler externo, script shell o trigger de base de datos.

## Probablemente código muerto (46 SPs)

Fan-in=0 en el callgraph estático. Pueden ser dead code o estar invocados dinámicamente / por scheduler externo.

| SP | LOC | R/W tablas | Clasificación preliminar |
|----|-----|-----------|-------------------------|
| `sp_buscar_movimientos_credito_his_canales` | 5103 | R:49 W:4 | Fan-in=0 — validar con DBA |
| `sp_buscar_movimientos_credito_dia_canales` | 4779 | R:49 W:4 | Fan-in=0 — validar con DBA |
| `sp_buscar_movimientos_cheques_dia_canales` | 4442 | R:48 W:4 | Fan-in=0 — validar con DBA |
| `sp_buscar_movimientos_cheques_his_canales` | 4113 | R:47 W:4 | Fan-in=0 — validar con DBA |
| `sp_buscar_movimientos_inversion_dia_canales` | 3134 | R:41 W:4 | Fan-in=0 — validar con DBA |
| `sp_busca_producto_cred_cliente` | 2774 | R:53 W:6 | Fan-in=0 — validar con DBA |
| `sp_busca_producto_cred_tarjeta` | 2712 | R:53 W:6 | Fan-in=0 — validar con DBA |
| `sp_acl_obtenerlogpreguntas` | 2187 | R:32 W:4 | Fan-in=0 — validar con DBA |
| `sp_acl_obtenernombreestados` | 2058 | R:32 W:4 | Fan-in=0 — validar con DBA |
| `sp_acl_actualizaempaclaracion` | 2018 | R:31 W:4 | Fan-in=0 — validar con DBA |
| `sp_acl_consultadevolucion` | 1989 | R:38 W:1 | Fan-in=0 — validar con DBA |
| `sp_acl_obtenerpreguntasiniciosesion` | 1988 | R:31 W:4 | Fan-in=0 — validar con DBA |
| `sp_acl_consultafectacion` | 1916 | R:38 W:1 | Fan-in=0 — validar con DBA |
| `sp_acl_validarnumerorespuestas` | 1873 | R:29 W:4 | Fan-in=0 — validar con DBA |
| `sp_buscaqueda_folio_csuac` | 1862 | R:43 W:3 | Fan-in=0 — validar con DBA |
| `sp_acl_validarpreguntasautenticacion` | 1774 | R:29 W:4 | Fan-in=0 — validar con DBA |
| `sp_acl_validacion_abonoinmediato` | 1712 | R:25 W:6 | Fan-in=0 — validar con DBA |
| `sp_acl_insertalog` | 1678 | R:20 W:4 | Fan-in=0 — validar con DBA |
| `sp_acl_consultatipoeventosabono` | 1444 | R:26 W:1 | Fan-in=0 — validar con DBA |
| `sp_busca_aclaraciones_canales` | 1431 | R:26 W:1 | Fan-in=0 — validar con DBA |

> **[SME-PENDING]** Para cada SP: buscar en logs de ejecución si fue invocado en los últimos 90 días en producción.

## Impacto en el scope de migración

```
Total SPs analizados:          70
Código muerto confirmado:      19  (no migrar — pendiente confirmación SME)
Probable código muerto:        46  (validar)
Procesos batch:                3  (migrar como jobs — ver 11-batch-processes.md)
Riesgo dinámico:               0  (investigar)
SPs activos (fan-in > 0):      2
─────────────────────────────────────────────
Scope mínimo de migración:     ~5  SPs (activos + batch)
Scope máximo:                  ~51  SPs (excluyendo solo muerto confirmado)
```

> El scope real requiere validación con Domain Expert BanCoppel antes de comprometer al cliente.


---
*Generado por: Specialist — Informix SPL Analysis · 2026-07-03 · Evidencia: source/informix/bdiaclaracion_*.sql (análisis estático de 70 archivos SQL) · callgraph-data.json (fan_in) + análisis de nombres*

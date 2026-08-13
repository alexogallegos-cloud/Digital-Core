# D15 · LIDE/PLD (Prevención de Lavado de Dinero) — Matriz SP × Tabla

> **Componente:** Informix · SPE-AM-001 · Etapa 2 — Schema Analysis
> **Base de datos:** bdilide
> **Wave:** Wave 4 · Riesgo: CRÍTICO (regulatorio — PLD/CNBV/SHCP)
> **Última actualización:** 2026-08-03

---

## Leyenda

| Símbolo | Operación |
|---------|-----------|
| R | SELECT (lectura) |
| I | INSERT |
| U | UPDATE |
| D | DELETE |
| X | Cross-DB (tabla en otra base de datos) |

## Matriz SP × Tabla (SPs analizados con tablas identificadas)

| SP | sl_movefec | sl_movefec_his | sl_retlide | sl_detlide | sl_constancias | sl_consat | sl_exentos | sl_exentostemp | sl_procesos | sl_parametros | sl_archsat | sl_archivoconsulta | sl_archivocontrol | si_fechas (X) | si_cliente (X) | sx_contproc (X) | sc_fechas (X) | sc_movdia (X) | sc_movhis (X) | sd_fechas (X) | sd_movhis (X) | sd_movdia (X) |
|----|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| `borramovs_movefechis` | | R/D | | | | | | | | | | | | | | | | | | | | |
| `ejecutor_diario` | | | | | | | | | | | | | | U | | | U | I | R | U | R | I |
| `sp_actparamtraspmovefec` | R | | | | | | | | | | | | | | | | | | | | | |
| `sp_actualizacodfechaenvio` | | | | | | | | | | | R | | | U | | | | | | | | |
| Nota: sl_archsat | | | | | | | | | | | U | | | | | | | | | | | |
| `sp_actualizaide_31052013` | | | | | | | | | | | | | | | | | R | | | | | |
| `sp_actualizainformesat` | | | | | | | U | | | | | | | R | | | | | | | | |
| `sp_actualizaresultadosat` | | | | | | R/U | U/I | R | | | | | | R | | | | | | | | |
| `sp_actualizarfclide` | R | | R | R | R | R | R | | | | | | | | | | | | | | | |
| `sp_actualizarfclide_pba` | R | | R | R | R | R | R | | | | | | | | | | | | | | | |
| `sp_acumulacionoperaciones` | R/U | | R/I/D | | | | | | R/I/U | R | | | | R | R | I | | | | | | |
| `sp_cargainformesat` | | | | | | | | | R/I | R | | R/D/I | R/D/I | | | | R | | | | | |
| `sp_cargaresultadosat` | | | | | | | | | R/I | R | | R/D/I | R/D/I | | | | R | | | | | |
| `sp_checacurp` | | | | | | | | | | | | | | | | | | | | | | |

> Nota: `sp_checacurp` accede a tablas que no fueron completamente capturadas en la muestra de análisis (`[DATO-REQUERIDO]`).

## Tablas por nivel de criticidad (basado en número de escrituras)

| Tabla | SPs que escriben (I/U/D) | Impacto de corrupción | Nivel |
|-------|:------------------------:|----------------------|:-----:|
| `sl_retlide` | 3+ | Retenciones PLD incorrectas → reporte SHCP erróneo | 🔴 CRÍTICO |
| `sl_exentos` | 2+ | Clientes exentos mal clasificados → reporte SAT incorrecto | 🔴 CRÍTICO |
| `sl_procesos` | 3+ | Control de procesos perdido → reprocesamiento indebido | 🔴 CRÍTICO |
| `sl_movefec` | 2+ | Movimientos PLD corruptos → análisis erróneo | 🔴 CRÍTICO |
| `sl_consat` | 2+ | Historial SAT corrupto → consulta incorrecta | 🔴 CRÍTICO |
| `sl_archivoconsulta` | 2+ (I/D ciclo) | Archivos de intercambio SAT perdidos | 🔴 CRÍTICO |
| `sl_archivocontrol` | 2+ (I/D ciclo) | Archivos de control SAT perdidos | 🔴 CRÍTICO |
| `si_fechas` (cross-DB) | 1 | Fecha de proceso inconsistente entre dominios | 🟠 ALTO |

## Hotspots de concurrencia

Los siguientes SPs ejecutan DELETE + INSERT sobre la misma tabla en el mismo proceso (patrón "limpiar y reinsertar"), lo que puede generar condiciones de carrera si se ejecutan en paralelo:

| SP | Tabla | Patrón |
|----|-------|--------|
| `sp_acumulacionoperaciones` | `sl_retlide` | DELETE existentes → INSERT nuevos |
| `sp_cargainformesat` | `sl_archivoconsulta`, `sl_archivocontrol` | DELETE → INSERT |
| `sp_cargaresultadosat` | `sl_archivoconsulta`, `sl_archivocontrol` | DELETE → INSERT |

> `[SME-PENDING]` — Confirmar con DBA si estos SPs tienen control de concurrencia (locks, semáforos en `sl_procesos`) o si el diseño asume ejecución en serie. En el target, este patrón requiere manejo explícito de concurrencia o transacciones optimistas.

## `[DATO-REQUERIDO]` — Ampliar la matriz

Esta matriz cubre solo los SPs con tablas identificadas en el análisis inicial. Los 96 SPs aislados requieren análisis adicional para completar la matriz. Instrucción para el DBA IBM Informix:

```sql
-- Extraer todas las tablas accedidas por SPs del dominio bdilide:
SELECT p.procname, p.procid, s.tabname, 'R' AS op
FROM sysprocplan sp
JOIN sysprocedures p ON sp.procid = p.procid
JOIN systables s ON sp.seqno = s.tabid
WHERE p.owner = 'bdilide'
ORDER BY p.procname, s.tabname;
```

---
*Generado: análisis estático bdilide · 2026-08-03*

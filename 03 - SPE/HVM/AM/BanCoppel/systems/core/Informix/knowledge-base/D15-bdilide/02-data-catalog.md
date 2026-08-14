# D15 · LIDE/PLD (Prevención de Lavado de Dinero) — Catálogo de Datos

> **Componente:** Informix · SPE-AM-001 · Etapa 2 — Schema Analysis
> **Base de datos:** bdilide
> **Wave:** Wave 4 · Riesgo: CRÍTICO (regulatorio — PLD/CNBV/SHCP)
> **Última actualización:** 2026-08-03

---

## Inventario de tablas identificadas en `bdilide`

Las tablas fueron identificadas mediante análisis estático del código de los 101 SPs. El prefijo `sl_` es la convención del dominio (`s`=sistema, `l`=LIDE).

| Tabla | Operaciones detectadas | SPs que la acceden (muestra) | Propósito inferido |
|-------|----------------------|------------------------------|-------------------|
| `sl_movefec` | SELECT, UPDATE | `sp_acumulacionoperaciones`, `sp_actparamtraspmovefec`, `sp_actualizarfclide` | Movimientos por fecha — registro central de transacciones PLD |
| `sl_movefec_his` | SELECT, DELETE | `borramovs_movefechis` | Histórico de movimientos por fecha (archivo) |
| `sl_retlide` | SELECT, INSERT, DELETE | `sp_acumulacionoperaciones`, `sp_actualizarfclide` | Retenciones LIDE — montos retenidos por criterio PLD |
| `sl_detlide` | SELECT | `sp_actualizarfclide`, `sp_actualizarfclide_pba` | Detalle LIDE — desglose de transacciones bajo vigilancia |
| `sl_constancias` | SELECT | `sp_actualizarfclide` | Constancias emitidas a clientes (LIDE/SAT) |
| `sl_consat` | SELECT, UPDATE, INSERT | `sp_actualizaresultadosat`, `sp_actualizarfclide` | Consultas al SAT — historial de intercambio de información |
| `sl_exentos` | SELECT, UPDATE, INSERT | `sp_actualizainformesat`, `sp_actualizaresultadosat`, `sp_actualizarfclide` | Clientes exentos del IDE (SAT) |
| `sl_exentostemp` | SELECT | `sp_actualizaresultadosat` | Exentos temporales (archivo de trabajo) |
| `sl_procesos` | SELECT, INSERT, UPDATE | `sp_acumulacionoperaciones`, `sp_cargainformesat`, `sp_cargaresultadosat` | Control de ejecución de procesos batch PLD |
| `sl_parametros` | SELECT | `sp_acumulacionoperaciones`, `sp_cargainformesat` | Parámetros del motor PLD (umbrales, porcentajes) |
| `sl_archsat` | UPDATE | `sp_actualizacodfechaenvio` | Archivos SAT — control de envíos al SAT |
| `sl_archivoconsulta` | SELECT, INSERT, DELETE | `sp_cargainformesat`, `sp_cargaresultadosat` | Archivos de consulta SAT (intercambio) |
| `sl_archivocontrol` | SELECT, INSERT, DELETE | `sp_cargainformesat`, `sp_cargaresultadosat` | Archivos de control SAT (cabecera del intercambio) |

## Tablas cross-DB accedidas por `bdilide`

| Tabla | Base de datos | Tipo de acceso | Propósito |
|-------|--------------|----------------|----------|
| `si_fechas` | `bdinteg` | SELECT, UPDATE | Fecha de proceso compartida entre dominios |
| `si_cliente` | `bdinteg` | SELECT | Datos del cliente para análisis PLD |
| `sx_contproc` | `bdinteg` | INSERT | Registro de control de procesos (integración) |
| `sd_fechas` | `bdicred` | UPDATE | Sincronización fecha de proceso en crédito |
| `sc_fechas` | `bdicheq` | SELECT, UPDATE | Sincronización fecha en cuentas de cheques |
| `sc_movdia` | `bdicheq` | INSERT | Movimientos del día en cuentas de cheques |
| `sc_movhis` | `bdicheq` | SELECT | Historial de movimientos en cuentas de cheques |
| `sd_movhis` | `bdicred` | SELECT | Historial de movimientos en crédito |
| `sd_movdia` | `bdicred` | INSERT | Movimientos del día en crédito |

## Tablas adicionales inferidas (pendiente de confirmar en syscolumns)

Las siguientes tablas se infieren por convención de nomenclatura del dominio. `[DATO-REQUERIDO]` — confirmar existencia y schema real con DBA IBM Informix:

| Tabla estimada | Propósito probable |
|----------------|-------------------|
| `sl_lide` | Registro central de clientes en lista LIDE |
| `sl_detalle_lide` | Detalle de la causal de inclusión en LIDE |
| `sl_operaciones_inusuales` | Operaciones marcadas como inusuales (CNBV) |
| `sl_operaciones_relevantes` | Operaciones relevantes (>$7,500 USD — SHCP) |
| `sl_operaciones_preocupantes` | Operaciones preocupantes (FATF R8) |
| `sl_reportes_cnbv` | Control de reportes enviados a CNBV |
| `sl_listas_ofac` | Screening contra lista OFAC |
| `sl_listas_onu` | Screening contra lista ONU |
| `sl_bitacora_pld` | Bitácora de decisiones del motor PLD |

## `[SME-PENDING]`

- [ ] DBA IBM Informix: ejecutar `SELECT tabname FROM systables WHERE tabname LIKE 'sl_%'` en `bdilide` para obtener el catálogo completo de tablas.
- [ ] Confirmar qué tablas son de producción activa vs. tablas de archivo o históricas.
- [ ] Identificar tablas temporales de trabajo (sufijo `temp`, `_tmp`).
- [ ] Documentar el volumen de registros por tabla (crítico para el plan de migración de datos).

---
*Generado: análisis estático bdilide · 2026-08-03*

# 21 — Latencia Individual por SP · Informix (v2)
> **Fuente**: `transacciones_bus_20260424_*.txt` (24h producción)
> **Metodología v2**: brecha entre eventos consecutivos del mismo `idTrxGlobal`.
>   Cada SP recibe como latencia el tiempo entre SU ejecución completando y la siguiente llamada del ESB.
>   Esto aproxima la latencia individual de cada SP (excluyendo overhead ESB < 1s).
>   Resolución: 1 segundo. `zero_pct` = % de brechas que terminaron en el mismo segundo (sub-1s).
> **v1 (referencia)**: duración total del flujo asignada al primer SP — ver `20-latency-baseline.md`.
> 🗺️ = SP que aparece en el mapa de journeys (131 SPs expuestos al ESB)

> **Cobertura**: 128 SPs con latencia medible (v2)  |  64 SPs (v1)  |  136 SPs únicos

---

## 🔴 SPs LENTOS — P95 ≥ 10s (43 SPs)

| SP | N brechas | P50 | P95 | P99 | Max | zero% |
|----|-----------|-----|-----|-----|-----|-------|
| `sp_ws_autenticacionafore` | 31 | 81.0s | 253.5s | 273.9s | 279s | 0.0% |
| `sp_registra_cte_domiciliacion` | 35 | 105.0s | 245.9s | 273.0s | 275s | 0.0% |
| `sp_consultainforoi` | 143 | 65.0s | 237.9s | 287.7s | 295s | 1.4% |
| `sp_obtienelimitecreditosolicitud` | 401 | 53.0s | 186.0s | 271.0s | 283s | 0.5% |
| `sp_retiro_sd` | 3,412 | 28.0s | 185.4s | 264.9s | 300s | 1.3% |
| `sp_consulta_cardif` | 709 | 72.0s | 181.6s | 247.8s | 296s | 7.6% |
| `sp_consmov_sd` | 706 | 30.5s | 178.8s | 267.8s | 297s | 0.7% |
| `sp_consulta_appriza_web` | 5,719 | 59.0s | 171.0s | 244.0s | 300s | 0.0% |
| `sp_abono_sd` | 3,116 | 31.0s | 163.2s | 250.5s | 293s | 1.1% |
| `sp_consulta_bts_web` | 12 | 88.5s | 157.0s | 157.0s | 157s | 0.0% |
| `sp_perso_sd` | 150 | 23.0s | 153.3s | 242.2s | 295s | 0.0% |
| `sp_edic_sd` | 291 | 28.0s | 133.5s | 195.0s | 300s | 0.0% |
| `sp_reverso_msw` | 3,811 | 4.0s | 133.0s | 148.0s | 288s | 2.8% |
| `sp_consultasucursalAppriza` | 51 | 34.0s | 121.0s | 134.5s | 135s | 2.0% |
| `sp_prestamoflex_multicanal` | 1,800 | 14.0s | 108.0s | 206.0s | 286s | 7.7% |
| `sp_crea_sd` | 3,071 | 9.0s | 97.5s | 190.0s | 294s | 10.9% |
| `sp_app_confirmpayment` | 4,460 | 17.0s | 92.0s | 155.4s | 287s | 5.6% |
| `sp_consulta_pre_aprobado` | 7 | 15.0s | 79.7s | 91.9s | 95s | 28.6% |
| `cons_expediente2_expcte_web` | 358 | 16.0s | 78.1s | 157.8s | 218s | 3.1% |
| `inserta_img_previo` | 310 | 11.5s | 77.7s | 131.4s | 257s | 11.6% |
| `totcomp2_web` | 8 | 7.0s | 77.0s | 77.0s | 77s | 0.0% |
| `inserta_reg_expediente` | 298 | 13.0s | 73.1s | 143.0s | 176s | 7.4% |
| `sp_pago_wu_web` | 795 | 15.0s | 73.0s | 143.9s | 295s | 0.3% |
| `sp_pago_appriza_web` | 3,506 | 15.0s | 72.8s | 124.0s | 266s | 0.3% |
| `sp_renovacion_cardif` | 111 | 19.0s | 66.0s | 130.8s | 227s | 1.8% |
| `sp_app_recordorder` | 22,482 | 31.0s | 59.0s | 120.4s | 300s | 0.1% |
| `sp_consflagretarj` | 7 | 7.0s | 56.8s | 72.2s | 76s | 14.3% |
| `sp_app_getorder` | 36,046 | 1.0s | 54.0s | 61.0s | 300s | 23.8% |
| `sp_bts_registracdep` | 21 | 12.0s | 54.0s | 57.2s | 58s | 0.0% |
| `reversion_web` | 19 | 3.0s | 48.3s | 100.9s | 114s | 15.8% |
| `sp_bts_registrasdep` | 28 | 0.0s | 44.5s | 56.5s | 60s | 60.7% |
| `sp_pago_bts_web` | 10 | 18.5s | 42.5s | 46.1s | 47s | 0.0% |
| `sp_consulta_remesas_cpl` | 5 | 26.0s | 41.2s | 44.2s | 45s | 0.0% |
| `sp_pago_wu_abmt` | 7 | 12.0s | 40.0s | 47.2s | 49s | 0.0% |
| `sp_inser_alerta_exlimblo` | 11 | 2.0s | 40.0s | 67.2s | 74s | 0.0% |
| `sp_arqueossuc_web` | 207 | 1.0s | 36.7s | 174.1s | 245s | 30.9% |
| `abono_ref_web` | 4,522 | 4.0s | 31.0s | 125.0s | 298s | 25.2% |
| `sp_consulta_wu_abmt` | 18 | 10.0s | 26.3s | 32.5s | 34s | 0.0% |
| `sp_consclientenumcte` | 5 | 1.0s | 25.8s | 28.4s | 29s | 40.0% |
| `sp_app_confirmorder` | 116 | 4.0s | 24.5s | 55.0s | 90s | 5.2% |
| `sp_trama_pago_antad` | 10 | 8.0s | 18.3s | 23.7s | 25s | 0.0% |
| `sp_app_recuperapayment` | 6,743 | 3.0s | 17.0s | 35.0s | 254s | 9.8% |
| `sp_ws_valida_cotel` | 20,815 | 2.0s | 13.0s | 39.0s | 263s | 13.2% |

## 🟡 SPs MODERADOS — P95 3–9s (23 SPs)

| SP | N brechas | P50 | P95 | P99 | Max | zero% |
|----|-----------|-----|-----|-----|-----|-------|
| `sp_valida_session` | 6,842 | 1.0s | 9.0s | 24.0s | 247s | 26.4% |
| `sp_adm_cons_ejecutivo` | 2,137 | 2.0s | 9.0s | 18.6s | 119s | 18.8% |
| `sp_ws_inyeccion_au` | 6,140 | 1.0s | 8.0s | 26.0s | 137s | 30.9% |
| `val_fechas_web` | 4,905 | 1.0s | 8.0s | 18.0s | 251s | 31.3% |
| `sp_adm_consulta_suc` | 12,350 | 1.0s | 8.0s | 16.0s | 286s | 26.0% |
| `sp_ws_obtiene_prod` | 18,129 | 1.0s | 7.0s | 20.0s | 128s | 27.4% |
| `sp_conssolicitudescredito_online` | 183 | 1.0s | 7.0s | 17.2s | 31s | 30.6% |
| `sp_obtenerfechahoy` | 2,841 | 1.0s | 7.0s | 18.0s | 180s | 47.5% |
| `sp_tramaconsulta_dish` | 4 | 5.5s | 7.0s | 7.0s | 7s | 0.0% |
| `sp_val_clubproteccion_web` | 7 | 0.0s | 6.5s | 7.7s | 8s | 71.4% |
| `sp_consultadatos_motor_web` | 1,459 | 1.0s | 5.0s | 11.0s | 21s | 31.3% |
| `sp_conssolic_credmovil_popup` | 3 | 0.0s | 4.5s | 4.9s | 5s | 66.7% |
| `consnumcte` | 4 | 0.5s | 4.4s | 4.9s | 5s | 50.0% |
| `sp_actualizadatos_reevaluacion_web` | 181 | 1.0s | 4.0s | 7.4s | 18s | 38.1% |
| `sp_obtienedatos_reevaluacion_web` | 227 | 1.0s | 4.0s | 7.7s | 14s | 32.2% |
| `sp_cons_mov_atm` | 1,020 | 0.0s | 4.0s | 80.7s | 217s | 71.7% |
| `sp_pago_credito_atm` | 57 | 0.0s | 4.0s | 18.6s | 22s | 71.9% |
| `sp_grabapagocoppel_td` | 20 | 3.0s | 4.0s | 4.0s | 4s | 0.0% |
| `sp_inserta_msw_respuesta` | 10 | 0.0s | 4.0s | 4.0s | 4s | 70.0% |
| `sp_confpagoservicio` | 30 | 0.0s | 3.6s | 4.0s | 4s | 73.3% |
| `sp_registradatos_motor` | 33 | 1.0s | 3.4s | 8.8s | 11s | 30.3% |
| `sp_situacionesclientescoppelporenviar_web` | 312 | 1.0s | 3.0s | 7.9s | 10s | 48.4% |
| `sp_valida_status_dictamen_unificado` | 145 | 2.0s | 3.0s | 4.1s | 10s | 6.2% |

## 🟢 SPs RÁPIDOS — P95 1–2s (55 SPs)

| SP | N brechas | P50 | P95 | P99 | Max | zero% |
|----|-----------|-----|-----|-----|-----|-------|
| `sp_guardar_bitacora_rostro` | 3 | 1.0s | 2.8s | 3.0s | 3s | 33.3% |
| `sp_bts_recuperacdep` | 69 | 0.0s | 2.6s | 16.6s | 20s | 60.9% |
| `sp_consulta_telefonos_web` | 379 | 1.0s | 2.0s | 4.2s | 6s | 31.9% |
| `sp_situacionespecialcte_cpl_web` | 155 | 0.0s | 2.0s | 4.0s | 10s | 51.0% |
| `sp_actualizaestatussolic` | 157 | 0.0s | 2.0s | 3.0s | 27s | 63.1% |
| `abono_ref` | 7,265 | 0.0s | 2.0s | 13.0s | 202s | 72.5% |
| `sp_consulta_saldos_general` | 59 | 0.0s | 2.0s | 4.1s | 7s | 78.0% |
| `sp_edoctaencabezado` | 141 | 0.0s | 2.0s | 3.6s | 5s | 75.2% |
| `sp_obtienedetalle_edoctacap` | 99 | 0.0s | 2.0s | 4.1s | 7s | 74.7% |
| `sp_guardaresptelmex` | 49 | 1.0s | 2.0s | 3.0s | 3s | 36.7% |
| `sp_confpgserv_dina` | 360 | 0.0s | 2.0s | 8.0s | 42s | 74.4% |
| `sp_grabapagoservicio` | 698 | 0.0s | 2.0s | 5.1s | 139s | 54.6% |
| `sp_guardasolpagosky` | 14 | 2.0s | 2.0s | 2.0s | 2s | 0.0% |
| `sp_solpagoskyonline` | 26 | 1.0s | 2.0s | 2.0s | 2s | 46.2% |
| `sp_mini21` | 318 | 1.0s | 2.0s | 8.0s | 130s | 36.8% |
| `obt_datos_caratula` | 10 | 0.0s | 2.0s | 2.0s | 2s | 70.0% |
| `sp_insertarespuestacuestionario` | 22 | 1.0s | 2.0s | 19.4s | 24s | 45.5% |
| `sp_edoctamovimientos_consedoc` | 163 | 0.0s | 1.9s | 6.8s | 14s | 69.3% |
| `sp_bts_recuperapayc` | 23 | 1.0s | 1.9s | 16.8s | 21s | 43.5% |
| `sp_dom_cancela_autorizacion` | 3 | 0.0s | 1.8s | 2.0s | 2s | 66.7% |
| `cargo_comisiones_per_web` | 5 | 1.0s | 1.8s | 2.0s | 2s | 20.0% |
| `sp_consulta_credito_atm` | 111 | 0.0s | 1.5s | 16.9s | 18s | 73.9% |
| `sp_cons_param_banderaprod_web` | 7 | 0.0s | 1.4s | 1.9s | 2s | 85.7% |
| `sp_cat_carac_tae` | 20 | 0.0s | 1.1s | 1.8s | 2s | 90.0% |
| `sp_obtener_datos_cv_web` | 51,037 | 0.0s | 1.0s | 1.0s | 199s | 81.1% |
| `cons_sdos3` | 6,707 | 0.0s | 1.0s | 6.0s | 202s | 72.7% |
| `sp_obtenernumproducto` | 82,994 | 0.0s | 1.0s | 1.0s | 128s | 80.4% |
| `sp_ofi_consultasdos` | 4,058 | 0.0s | 1.0s | 2.0s | 24s | 81.2% |
| `sp_conssdoticket_web` | 9,294 | 0.0s | 1.0s | 1.0s | 55s | 82.9% |
| `sp_consultanombre_serv_edoctaelec` | 3,682 | 0.0s | 1.0s | 2.0s | 18s | 78.6% |
| `cons_sdos1` | 2,089 | 0.0s | 1.0s | 2.0s | 40s | 80.0% |
| `sp_alta_cardif` | 819 | 0.0s | 1.0s | 1.0s | 3s | 83.5% |
| `sp_obtiene_param` | 91 | 0.0s | 1.0s | 1.0s | 1s | 80.2% |
| `sp_obtiene_tabla_amortizacion_web` | 456 | 0.0s | 1.0s | 1.4s | 4s | 79.6% |
| `sp_proac_edocta` | 50 | 0.0s | 1.0s | 1.5s | 2s | 58.0% |
| `cons_tarjeta_credcte` | 138 | 0.0s | 1.0s | 1.6s | 6s | 83.3% |
| `movimientos_edocta` | 43 | 0.0s | 1.0s | 1.6s | 2s | 62.8% |
| `sp_app_queryorder` | 33 | 0.0s | 1.0s | 1.0s | 1s | 81.8% |
| `sp_consctas_cfdi` | 307 | 0.0s | 1.0s | 2.9s | 6s | 73.6% |
| `reversion` | 22 | 0.0s | 1.0s | 1.0s | 1s | 72.7% |
| `sp_conssdoedos` | 60 | 0.0s | 1.0s | 2.8s | 4s | 71.7% |
| `sp_obtenerdatos_edomovtos` | 50 | 0.0s | 1.0s | 3.5s | 5s | 76.0% |
| `clientes_edocta_suc` | 45 | 0.0s | 1.0s | 3.2s | 5s | 86.7% |
| `sp_concensuc_web` | 14 | 0.0s | 1.0s | 1.0s | 1s | 64.3% |
| `sp_ctanvl2_gencta` | 117 | 0.0s | 1.0s | 1.0s | 1s | 77.8% |
| `sp_confpagoservicio_hs` | 1,762 | 0.0s | 1.0s | 1.0s | 9s | 94.5% |
| `sp_whatscoppel_enrola` | 385 | 0.0s | 1.0s | 1.0s | 2s | 93.8% |
| `sp_grabapgserv_dina` | 495 | 0.0s | 1.0s | 4.1s | 59s | 75.8% |
| `ConsNomTitTar_web` | 9 | 0.0s | 1.0s | 1.0s | 1s | 77.8% |
| `consnomtit` | 4 | 0.5s | 1.0s | 1.0s | 1s | 50.0% |
| `sp_registro_ctetitular_cv_web` | 10 | 0.0s | 1.0s | 1.0s | 1s | 60.0% |
| `sp_whatscoppel_envotp` | 3 | 1.0s | 1.0s | 1.0s | 1s | 33.3% |
| `sp_notif_cub_vent_upd` | 4 | 0.0s | 0.9s | 1.0s | 1s | 75.0% |
| `sp_app_submitpayment_web` | 7 | 0.0s | 0.7s | 0.9s | 1s | 85.7% |
| `sp_consulta_huella_actual` | 7 | 0.0s | 0.7s | 0.9s | 1s | 85.7% |

## ⚡ SPs SUB-SEGUNDO — P95 = 0s (7 SPs, invisibles a resolución 1s)

| SP | N brechas | P50 | P95 | P99 | Max | zero% |
|----|-----------|-----|-----|-----|-----|-------|
| `sp_domi_consulta_autorizacionesactivas` | 869 | 0.0s | 0.0s | 1.0s | 1s | 96.8% |
| `sp_obtclavetarjeta` | 3 | 0.0s | 0.0s | 0.0s | 0s | 100.0% |
| `sp_bitacorawstae` | 889 | 0.0s | 0.0s | 3.0s | 60s | 95.5% |
| `sp_aplica_pago_con_cargo_msw` | 1,774 | 0.0s | 0.0s | 1.0s | 14s | 95.8% |
| `sp_grabacomparacionhuelladec` | 41 | 0.0s | 0.0s | 0.6s | 1s | 97.6% |
| `sp_DinYa_InsDatoEnv` | 7 | 0.0s | 0.0s | 0.0s | 0s | 100.0% |
| `sp_valida_es_cliente_remesa` | 3 | 0.0s | 0.0s | 0.0s | 0s | 100.0% |

## SPs solo en v1 (primer SP del flujo, sin brecha previa) — 8 SPs
> Para estos SPs la duración es el flujo completo, no la latencia individual.

| SP | N flujos | P50 (flujo) | P95 (flujo) | P99 (flujo) | Max |
|----|---------|-------------|-------------|-------------|-----|
| `sp_pago_cardif` | 77 | 1.0s | 135.2s | 164.4s | 229s |
| `sp_sorteobancoppel_web` | 8 | 16.5s | 125.3s | 143.4s | 148s |
| `trans_prestamo2` | 63 | 1.0s | 55.7s | 58.0s | 58s |
| `trans_prestamo` | 45 | 1.0s | 53.8s | 58.1s | 59s |
| `rev_trans_prestamo` | 47 | 2.0s | 45.7s | 49.6s | 51s |
| `sp_confirma_prestamo_cpl` | 37 | 1.0s | 2.6s | 5.0s | 5s |
| `sp_whatscoppel_consdos` | 701 | 1.0s | 1.0s | 49.0s | 60s |
| `sp_registra_evento` | 3 | 1.0s | 1.0s | 1.0s | 1s |

---

## Notas metodológicas

1. **zero%**: porcentaje de brechas donde el SP siguiente completó en el mismo segundo.
   Un zero% alto indica que el SP es sub-segundo (o que hay muchas llamadas rápidas en el mismo flujo).
2. **P95 de la brecha ≠ P95 de Informix**: incluye ESB overhead (~50-200ms). A resolución de 1s esto es despreciable.
3. **Último SP en cada flujo**: no recibe brecha. Para medir su latencia se necesita el tiempo de respuesta final del flujo,
   que se puede aproximar como `duración_total_flujo - suma_de_brechas_previas`.
4. **Cobertura teórica máxima**: solo SPs expuestos directamente al ESB (llamados desde el bus).
   Los ~9,800 SPs internos (llamados desde SPL, no desde el ESB) son invisibles en los logs.
5. **Para latencia en ms**: instrumentar con OpenTelemetry en el target o acceder a `sysmaster` de Informix con DBA.

*Generado por: analyze-latency-v2.py · 2026-08-03 · Fuente: logs producción 2026-04-24*
# 20 — Latency Baseline · BCOPCore
> **Fuente**: `transacciones_bus_20260424_*.txt` (24h producción)
> **Metodología**: latencia medida como duración de flujos multi-SP con mismo `idTrxGlobal`
> **Granularidad**: 1 segundo (resolución del timestamp en campo `referencia`)
> **Generado por**: analyze-latency.py
> **Nota**: P50/P95/P99 expresados en segundos. Latencias < 1s no son distinguibles con esta fuente.

---

## Resumen ejecutivo

| Métrica | Valor |
|---------|-------|
| Transacciones únicas parseadas | 2,464,040 |
| Flujos multi-SP con latencia medible | 135,969 |
| SPs con datos de latencia | 78 |
| Latencia P50 global (flujos completos) | 1.0s |
| Latencia P95 global (flujos completos) | 74.0s |
| Latencia P99 global (flujos completos) | 184.3s |
| Latencia máxima observada | 300s |
| Hora pico | 12:00 CDMX (320,574 llamadas/hora · 89.0 llamadas/seg promedio) |

> **Límite de la fuente**: la resolución de 1 segundo significa que flujos que terminan
> en el mismo segundo que empezaron aparecen con latencia 0s y **no se incluyen** en esta
> tabla. Los SPs más rápidos del sistema son invisibles aquí — eso es bueno: significa que
> están por debajo del umbral de alarma de 1 segundo.

---

## SLO-AM-02 — Referencia para el target

> El target no puede degradar la latencia respecto al baseline legacy (SLO-AM-02).
> Cualquier SP que en el target supere su P95 legacy requiere investigación antes de cutover.

## 🔴 SPs LENTOS — P95 ≥ 10s (prioridad alta en optimización del target)

| SP | N flujos | P50 | P95 | P99 | Max |
|----|---------|-----|-----|-----|-----|
| `sp_consulta_huella_actual` | 5 | 2.0s | 274.8s | 290.2s | 294s |
| `sp_app_confirmpayment` | 42 | 103.5s | 229.9s | 245.4s | 254s |
| `sp_consmov_sd` | 458 | 44.0s | 220.3s | 282.6s | 297s |
| `sp_retiro_sd` | 2,671 | 35.0s | 208.5s | 270.3s | 300s |
| `sp_perso_sd` | 77 | 23.0s | 201.6s | 236.6s | 248s |
| `sp_abono_sd` | 2,012 | 37.0s | 188.5s | 262.0s | 297s |
| `sp_edic_sd` | 205 | 35.0s | 187.2s | 273.8s | 275s |
| `sp_consulta_appriza_web` | 5,701 | 68.0s | 183.0s | 250.0s | 298s |
| `sp_consulta_bts_web` | 12 | 91.5s | 167.8s | 178.4s | 181s |
| `sp_reverso_msw` | 1,870 | 10.0s | 144.5s | 273.0s | 288s |
| `sp_crea_sd` | 2,612 | 10.0s | 144.0s | 251.0s | 299s |
| `sp_consultasucursalAppriza` | 18 | 64.0s | 134.3s | 135.7s | 136s |
| `sp_sorteobancoppel_web` | 8 | 16.5s | 125.3s | 143.4s | 148s |
| `sp_consulta_cardif` | 5,821 | 1.0s | 86.0s | 168.0s | 298s |
| `__no_sp__` | 16,058 | 1.0s | 80.1s | 219.3s | 300s |
| `sp_consulta_pre_aprobado` | 7 | 15.0s | 79.7s | 91.9s | 95s |
| `totcomp2_web` | 9 | 7.0s | 77.0s | 77.0s | 77s |
| `sp_pago_wu_web` | 795 | 16.0s | 74.0s | 144.9s | 295s |
| `sp_pago_appriza_web` | 1,803 | 16.0s | 72.0s | 124.0s | 266s |
| `sp_consflagretarj` | 6 | 11.0s | 64.0s | 73.6s | 76s |

## 🟡 SPs MODERADOS — P95 3–9s (monitorear en parallel-run)

| SP | N flujos | P50 | P95 | P99 | Max |
|----|---------|-----|-----|-----|-----|
| `sp_val_clubproteccion_web` | 4 | 2.0s | 7.1s | 7.8s | 8s |
| `sp_conssolic_credmovil_popup` | 3 | 0.0s | 4.5s | 4.9s | 5s |
| `sp_mini21` | 166 | 1.0s | 4.0s | 21.2s | 130s |
| `sp_confpagoservicio` | 20 | 0.0s | 4.0s | 4.0s | 4s |
| `sp_grabapagocoppel_td` | 12 | 3.0s | 3.4s | 3.9s | 4s |
| `sp_grabapgserv_dina` | 361 | 0.0s | 3.0s | 9.8s | 59s |
| `sp_grabapagoservicio` | 696 | 1.0s | 3.0s | 8.0s | 139s |

## 🟢 SPs RÁPIDOS — P95 < 3s (baseline saludable)

| SP | N flujos | P50 | P95 | P99 | Max |
|----|---------|-----|-----|-----|-----|
| `cargo_comisiones_per_web` | 3 | 1.0s | 2.8s | 3.0s | 3s |
| `sp_guardar_bitacora_rostro` | 3 | 1.0s | 2.8s | 3.0s | 3s |
| `sp_guardaresptelmex` | 49 | 1.0s | 2.0s | 3.0s | 3s |
| `sp_confpgserv_dina` | 201 | 0.0s | 2.0s | 8.0s | 34s |
| `sp_solpagoskyonline` | 6 | 1.5s | 2.0s | 2.0s | 2s |
| `obt_datos_caratula` | 10 | 0.0s | 2.0s | 2.0s | 2s |
| `sp_insertarespuestacuestionario` | 21 | 1.0s | 2.0s | 19.6s | 24s |
| `sp_whatscoppel_envotp` | 3 | 2.0s | 2.0s | 2.0s | 2s |
| `sp_bts_recuperapayc` | 23 | 1.0s | 1.9s | 16.8s | 21s |
| `sp_adm_consulta_suc` | 17 | 0.0s | 1.4s | 2.7s | 3s |
| `sp_cat_carac_tae` | 20 | 0.0s | 1.1s | 1.8s | 2s |
| `sp_ctanvl2_gencta` | 117 | 0.0s | 1.0s | 1.0s | 1s |
| `sp_confpagoservicio_hs` | 1,710 | 0.0s | 1.0s | 3.0s | 14s |
| `sp_whatscoppel_enrola` | 392 | 0.0s | 1.0s | 1.0s | 2s |
| `trans_prestamo2` | 856 | 0.0s | 1.0s | 45.8s | 58s |
| `sp_obtenerfechahoy` | 6 | 0.0s | 1.0s | 1.0s | 1s |
| `ConsNomTitTar_web` | 9 | 0.0s | 1.0s | 1.0s | 1s |
| `sp_registra_evento` | 22 | 0.0s | 1.0s | 1.0s | 1s |
| `sp_obtenernumproducto` | 3 | 1.0s | 1.0s | 1.0s | 1s |
| `consnomtit` | 4 | 0.5s | 1.0s | 1.0s | 1s |

## Top 20 SPs por volumen con latencia medible

| Rank | SP | N flujos | P50 | P95 | P99 |
|------|----|---------|-----|-----|-----|
| 1 | `sp_app_getorder` | 33,889 | 15.0s | 58.0s | 66.0s |
| 2 | `sp_whatscoppel_consdos` | 31,755 | 0.0s | 0.0s | 1.0s |
| 3 | `__no_sp__` | 16,058 | 1.0s | 80.1s | 219.3s |
| 4 | `sp_app_recordorder` | 12,931 | 31.0s | 59.0s | 128.0s |
| 5 | `sp_consulta_cardif` | 5,821 | 1.0s | 86.0s | 168.0s |
| 6 | `sp_consulta_appriza_web` | 5,701 | 68.0s | 183.0s | 250.0s |
| 7 | `abono_ref_web` | 4,279 | 5.0s | 33.0s | 127.0s |
| 8 | `sp_retiro_sd` | 2,671 | 35.0s | 208.5s | 270.3s |
| 9 | `sp_crea_sd` | 2,612 | 10.0s | 144.0s | 251.0s |
| 10 | `sp_abono_sd` | 2,012 | 37.0s | 188.5s | 262.0s |
| 11 | `sp_reverso_msw` | 1,870 | 10.0s | 144.5s | 273.0s |
| 12 | `sp_pago_appriza_web` | 1,803 | 16.0s | 72.0s | 124.0s |
| 13 | `sp_confirma_prestamo_cpl` | 1,802 | 0.0s | 0.0s | 1.0s |
| 14 | `sp_aplica_pago_con_cargo_msw` | 1,745 | 0.0s | 0.0s | 3.0s |
| 15 | `sp_confpagoservicio_hs` | 1,710 | 0.0s | 1.0s | 3.0s |
| 16 | `trans_prestamo` | 900 | 0.0s | 0.0s | 19.0s |
| 17 | `sp_app_recuperapayment` | 897 | 43.0s | 58.0s | 61.1s |
| 18 | `sp_domi_consulta_autorizacionesactivas` | 869 | 0.0s | 0.0s | 1.0s |
| 19 | `sp_bitacorawstae` | 859 | 0.0s | 0.0s | 6.0s |
| 20 | `trans_prestamo2` | 856 | 0.0s | 1.0s | 45.8s |
| 21 | `sp_pago_wu_web` | 795 | 16.0s | 74.0s | 144.9s |
| 22 | `sp_grabapagoservicio` | 696 | 1.0s | 3.0s | 8.0s |
| 23 | `sp_consmov_sd` | 458 | 44.0s | 220.3s | 282.6s |
| 24 | `sp_pago_cardif` | 418 | 0.0s | 43.3s | 134.8s |
| 25 | `sp_whatscoppel_enrola` | 392 | 0.0s | 1.0s | 1.0s |
| 26 | `sp_grabapgserv_dina` | 361 | 0.0s | 3.0s | 9.8s |
| 27 | `rev_trans_prestamo` | 238 | 0.0s | 12.5s | 45.6s |
| 28 | `sp_edic_sd` | 205 | 35.0s | 187.2s | 273.8s |
| 29 | `sp_confpgserv_dina` | 201 | 0.0s | 2.0s | 8.0s |
| 30 | `sp_mini21` | 166 | 1.0s | 4.0s | 21.2s |

---

## Limitaciones y próximos pasos

1. **Resolución 1s**: flujos sub-segundo no son medibles. Para P50/P95/P99 en ms se requiere
   instrumentación APM (OpenTelemetry / Dynatrace) en el target.
2. **Latencia legacy ≠ latencia SP**: lo que medimos es la duración del *flujo ESB completo*
   (desde primera hasta última llamada del mismo `idTrxGlobal`), que incluye tiempo de red
   del ESB + tiempo de Informix + lógica del bus. El tiempo puro del SP es menor.
3. **Cobertura**: solo flujos multi-SP son medibles. SPs invocados en flujos de 1 sola llamada
   no aparecen aquí aunque sean lentos internamente.
4. **Acción**: usar esta tabla como **criterio de aceptación del parallel-run** —
   si el target tiene P95 > legacy para cualquier SP de la tabla roja/amarilla, bloquear cutover.

*Generado por: analyze-latency.py · 2026-08-03 · Fuente: logs producción 2026-04-24*
# 19 — Performance Baseline · BCOPCore
> **Fuente**: logs de producción del Bus de Servicios — 2026-04-24 (24 horas)
> **Generado por**: analyze-logs.py
> **Nota**: métricas de latencia p50/p95/p99 requieren instrumentación APM — marcadas [APM-PENDING]

---

## Volumen de llamadas — 2026-04-24

| Métrica | Valor |
|---------|-------|
| Total transacciones parseadas | 3,353,645 |
| SPs distintos observados en producción | 632 |
| Pares sistema×servicio distintos | 626 |
| Hora pico | 12:00 CDMX (172,572 llamadas a Informix) |

---

## Patrón horario (llamadas a Informix por hora)

| Hora CDMX | Volumen total | Dominio más activo |
|-----------|--------------|-------------------|
| 00:00 | 5,169 | D05-bdisac (4,052) |
| 01:00 | 3,063 | D05-bdisac (2,289) |
| 02:00 | 1,404 | D05-bdisac (824) |
| 03:00 | 905 | D05-bdisac (518) |
| 04:00 | 797 | D05-bdisac (420) |
| 05:00 | 1,477 | D05-bdisac (952) |
| 06:00 | 6,159 | D05-bdisac (5,400) |
| 07:00 | 13,197 | D05-bdisac (11,642) |
| 08:00 | 20,392 | D05-bdisac (17,881) |
| 09:00 | 26,914 | D05-bdisac (21,027) |
| 10:00 | 61,198 | D02-bdinteg (25,781) |
| 11:00 | 153,330 | D02-bdinteg (76,743) |
| 12:00 | 172,572 | D02-bdinteg (86,532) |
| 13:00 | 161,170 | D02-bdinteg (78,941) |
| 14:00 | 150,485 | D02-bdinteg (72,114) |
| 15:00 | 142,484 | D02-bdinteg (68,941) |
| 16:00 | 138,414 | D02-bdinteg (66,610) |
| 17:00 | 139,163 | D02-bdinteg (67,327) |
| 18:00 | 127,134 | D02-bdinteg (63,043) |
| 19:00 | 57,885 | D02-bdinteg (32,857) |
| 20:00 | 95,649 | D02-bdinteg (46,880) |
| 21:00 | 59,413 | D02-bdinteg (20,848) |
| 22:00 | 24,334 | D05-bdisac (11,712) |
| 23:00 | 14,699 | D05-bdisac (8,381) |

---

## Volumen por dominio — total día

| Dominio | Llamadas totales | % del total |
|---------|-----------------|-------------|
| D02-bdinteg | 727,350 | 46.1% |
| D04-bdicheq | 321,664 | 20.4% |
| D05-bdisac | 296,684 | 18.8% |
| D03-bdicred | 126,766 | 8.0% |
| D11-bdicobranza | 54,736 | 3.5% |
| D06-bdisolic | 45,122 | 2.9% |
| D10-bdisuc | 4,903 | 0.3% |
| D07-bdiaclaracion | 136 | 0.0% |
| D09-bdimnsj | 44 | 0.0% |
| D01-bdicnweb | 2 | 0.0% |

---

## Top 20 SPs por volumen de llamadas

| Rank | SP | Llamadas | Errores | Error% | Dominios |
|------|----|----------|---------|--------|---------|
| 1 | `sp_consulta_huella_actual` | 205,079 | 136 | 0.07% | D02-bdinteg |
| 2 | `sp_obtenerfechahoy` | 161,665 | 0 | 0.0% | — |
| 3 | `cons_sdos2_web` | 97,248 | 1,104 | 1.14% | D04-bdicheq |
| 4 | `sp_consflagretarj` | 95,044 | 0 | 0.0% | D02-bdinteg |
| 5 | `sp_obtenernumproducto` | 82,999 | 0 | 0.0% | — |
| 6 | `sp_bitacorawstae` | 80,880 | 570 | 0.7% | D05-bdisac |
| 7 | `sp_aplica_pago_con_cargo_msw` | 80,638 | 297 | 0.37% | D05-bdisac |
| 8 | `sp_confpagoservicio_hs` | 77,405 | 0 | 0.0% | D05-bdisac |
| 9 | `sp_notif_cub_vent_upd` | 69,482 | 4 | 0.01% | D04-bdicheq |
| 10 | `sp_app_confirmpayment` | 61,280 | 5,333 | 8.7% | — |
| 11 | `sp_conhuella` | 59,911 | 49 | 0.08% | D02-bdinteg |
| 12 | `sp_val_clubproteccion_web` | 56,729 | 1 | 0.0% | — |
| 13 | `sp_app_recordorder` | 56,626 | 13 | 0.02% | — |
| 14 | `sp_app_getorder` | 55,126 | 0 | 0.0% | — |
| 15 | `sp_obtengrupocliente` | 51,600 | 0 | 0.0% | — |
| 16 | `sp_obtener_datos_cv_web` | 51,038 | 49,697 | 97.37% | D11-bdicobranza |
| 17 | `sp_obtparamsorteo` | 47,054 | 1 | 0.0% | D02-bdinteg |
| 18 | `consnumcte` | 46,367 | 0 | 0.0% | D02-bdinteg |
| 19 | `sp_validar_rostro_cliente` | 43,515 | 1 | 0.0% | D02-bdinteg |
| 20 | `sp_obtenerparametro` | 42,981 | 0 | 0.0% | — |

---

## Métricas de latencia

> **[APM-PENDING]** — Los logs del Bus no contienen timestamps de inicio/fin por llamada.
> Para poblar p50/p95/p99 se requiere instrumentación APM (Dynatrace, Datadog, o X-Ray).
> Alternativa: activar `SET DEBUG FILE TO '/tmp/sp_timing.log'` en Informix para los SPs críticos.

| SP | p50 | p95 | p99 | Umbral de alerta | Estado |
|----|-----|-----|-----|-----------------|--------|
| `sp_consulta_huella_actual` | [APM-PENDING] | [APM-PENDING] | [APM-PENDING] | [SME-PENDING] | — |
| `sp_obtenerfechahoy` | [APM-PENDING] | [APM-PENDING] | [APM-PENDING] | [SME-PENDING] | — |
| `cons_sdos2_web` | [APM-PENDING] | [APM-PENDING] | [APM-PENDING] | [SME-PENDING] | — |
| `sp_consflagretarj` | [APM-PENDING] | [APM-PENDING] | [APM-PENDING] | [SME-PENDING] | — |
| `sp_obtenernumproducto` | [APM-PENDING] | [APM-PENDING] | [APM-PENDING] | [SME-PENDING] | — |
| `sp_bitacorawstae` | [APM-PENDING] | [APM-PENDING] | [APM-PENDING] | [SME-PENDING] | — |
| `sp_aplica_pago_con_cargo_msw` | [APM-PENDING] | [APM-PENDING] | [APM-PENDING] | [SME-PENDING] | — |
| `sp_confpagoservicio_hs` | [APM-PENDING] | [APM-PENDING] | [APM-PENDING] | [SME-PENDING] | — |
| `sp_notif_cub_vent_upd` | [APM-PENDING] | [APM-PENDING] | [APM-PENDING] | [SME-PENDING] | — |
| `sp_app_confirmpayment` | [APM-PENDING] | [APM-PENDING] | [APM-PENDING] | [SME-PENDING] | — |

---

## Errores silenciosos en producción

Detectados en errores_bus_* con recurrencia sistemática:

| Código | Descripción | Volumen/día |
|--------|-------------|-------------|
| 4395 | Huellas442 NullPointerException — postg_huellasemps (bug en target PostgreSQL) | 3,979 |
| 3381 | ACEPTPORTA SFTP auth failure — sysportabnominaapp credenciales inválidas | 3,244 |

---

*Generado automáticamente por analyze-logs.py — 2026-07-31*
*Validar contra código fuente: `source/BCOPCore/informix/{sp_name}.sql`*
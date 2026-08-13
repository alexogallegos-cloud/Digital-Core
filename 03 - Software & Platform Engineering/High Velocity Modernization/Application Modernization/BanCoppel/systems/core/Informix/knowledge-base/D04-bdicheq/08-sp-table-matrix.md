# D04 · Cheques / Cuentas — Matriz SP × Tabla (READ / WRITE)

> **Componente:** Informix · SPE-AM-001 · Etapa 1
> **Base de datos:** `bdicheq` · IBM Informix IDS 14.10 / POWER-AIX
> **Wave:** Wave 4 · Riesgo: **CRÍTICO**
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

## Importancia para Etapa 2 (Data RE)

Esta matriz determina:
1. **Ownership de datos**: qué SP (y por ende qué microservicio target) es dueño de cada tabla
2. **Tablas compartidas**: múltiples SPs escriben → punto de contención → candidatas a patrón CQRS
3. **Prioridad CDC**: tablas con más escritores priorizan la configuración de Debezium / DMS
4. **Scope de migración**: tablas que solo leen SPs de código muerto pueden excluirse del scope

> 🔄 = SP usa `EXECUTE PROCEDURE` con variable — puede leer/escribir tablas adicionales no detectadas estáticamente.

## Resumen de tablas propias de `bdicheq`

| Tabla | Tipo | Lectores | Escritores | Ownership |
|-------|------|----------|-----------|-----------|
| `sc_maechq` | Maestro | 33 | 17 | 🔴 17 SPs escriben |
| `sc_fechas` | Transaccional | 26 | 0 | 🟢 Solo lectura |
| `sc_param` | Catálogo / Config | 9 | 12 | 🔴 12 SPs escriben |
| `STATISTICS` | Transaccional | 0 | 16 | 🔴 16 SPs escriben |
| `sc_movdia` | Transaccional | 5 | 9 | 🔴 9 SPs escriben |
| `sc_depinterpza` | Transaccional | 6 | 4 | 🟠 4 SPs escriben |
| `sc_depositosefectivo` | Transaccional | 4 | 4 | 🟠 4 SPs escriben |
| `sc_depositospei` | Transaccional | 5 | 3 | 🟠 3 SPs escriben |
| `sc_transfer_online` | Transaccional | 4 | 4 | 🟠 4 SPs escriben |
| `sc_limite_sbg` | Transaccional | 4 | 4 | 🟠 4 SPs escriben |
| `sc_ctabloqueo` | Transaccional | 6 | 2 | 🟠 2 SPs escriben |
| `sc_bloqueo` | Transaccional | 7 | 0 | 🟢 Solo lectura |
| `sc_tarjeta` | Transaccional | 6 | 1 | 🟠 1 SPs escriben |
| `sc_maenoc` | Maestro | 2 | 4 | 🟠 4 SPs escriben |
| `sc_acummesctanvl2` | Transaccional | 3 | 3 | 🟠 3 SPs escriben |
| `sc_transcomis` | Transaccional | 6 | 0 | 🟢 Solo lectura |
| `sc_movhis` | Transaccional | 5 | 0 | 🟢 Solo lectura |
| `sc_sdodiarioc` | Transaccional | 3 | 2 | 🟠 2 SPs escriben |
| `sc_producto` | Transaccional | 5 | 0 | 🟢 Solo lectura |
| `sc_premio` | Transaccional | 0 | 4 | 🟠 4 SPs escriben |

> **[SME-PENDING]** Confirmar nombre exacto en producción, volumen de registros, política de retención y campos PII con DBA BanCoppel.

## Matriz completa SP × Tabla

| SP | LOC | Fan-in | Tablas que LEE | Tablas que ESCRIBE |
|----|-----|--------|---------------|-------------------|
| `sp_abono_sd` | 3760 | 0 | `bdicheq:sc_fechas`  ⚠️ext, `bdicheq:sc_gat`  ⚠️ext, `bdicheq:sc_maechq`  ⚠️ext, `bdicheq:sc_nominaempresas`  ⚠️ext, `bdicheq:sc_nominaencabezadosumario_bpi`  ⚠️ext, `bdicheq:sc_nominaexcentocomision`  ⚠️ext | `bdicheq:sc_nominaencabezadosumario_bpi`  ⚠️ext, `bdicheq:sc_nominamovimientos_bpi`  ⚠️ext |
| `abono_ref` | 1654 | 520 | `bdiaclaracion:acl_aclaracion`  ⚠️ext, `bdinteg:`  ⚠️ext, `bdinteg:si_cliente`  ⚠️ext, `bdinteg:si_cliente_nivel`  ⚠️ext, `bdinteg:si_ejecut`  ⚠️ext, `bdinteg:si_ptf`  ⚠️ext | `sc_acummesctanvl2`, `sc_bit_error_cobranza_automatica`, `sc_depinterpza`, `sc_depositosefectivo` | 🔄
| `sp_actualizaobservaciones` | 1494 | 0 | `SC_MAECHQ`, `bdicheq:`  ⚠️ext, `bdicred:`  ⚠️ext, `bdinteg:`  ⚠️ext, `bdinteg:si_cliente`  ⚠️ext, `bdinteg:si_correos`  ⚠️ext | `bdicheq:`  ⚠️ext, `bdicheq:sc_detalle_edocta_factelect_old`  ⚠️ext, `sc_encabezado2_edocta_factelect`, `sc_encabezado2_edocta_factelect_old` | 🔄
| `sp_actualiza_est_reg_contr_evid_notif_porta` | 1456 | 0 | `BDICHEQ:`  ⚠️ext, `BDICHEQ:sc_param`  ⚠️ext, `BDICHEQ:sc_portaarchtemp`  ⚠️ext, `BDICHEQ:sc_portacec_solicitud`  ⚠️ext, `BDICRED:sd_maecred`  ⚠️ext, `BDICRED:sd_maecredcrd`  ⚠️ext | `BDICHEQ:sc_portaarchtemp`  ⚠️ext, `porta_tmp2`, `sc_control_evidencia_notif_portab`, `sc_portaarchtemp` | 🔄
| `sp_abono_sd_pbajlh` | 560 | 0 | `BDICHEQ:sc_tarjeta`  ⚠️ext, `bdicheq:sc_movdia`  ⚠️ext, `bdinteg:`  ⚠️ext, `bdisolic:ss_prestamoscoppel`  ⚠️ext | — |
| `sp_actintisrxprodcedula` | 66 | 18 | `bdicheq:sc_intisrxprodcedula`  ⚠️ext | `bdicheq:sc_intisrxprodcedula`  ⚠️ext |
| `sp_abonos_operaciones` | 129 | 0 | `sysmaster:systabnames`  ⚠️ext | `STATISTICS` |
| `sp_abonos_operaciones_esp` | 81 | 0 | `sysmaster:systabnames`  ⚠️ext | `STATISTICS`, `sc_maechq` |
| `sp_act_cuentas_bloqueadas` | 117 | 0 | `bdicheq:sc_histbloq`  ⚠️ext, `ctas_bloqueadas_universo`, `tmp_cta_fecha`, `tmp_cta_fecha_hora`, `tmp_cuenta_vs_maechq` | `STATISTICS`, `bdicheq:sc_maechq`  ⚠️ext, `ctas_bloqueadas_universo` |
| `sp_activaciones_codi_isa` | 160 | 0 | `bdicheq:sc_activa_codi_isa`  ⚠️ext, `bdicheq:sc_activaciones_codi`  ⚠️ext, `bdinteg:si_bpiusuarios`  ⚠️ext, `bdinteg:si_ingresos`  ⚠️ext, `sc_fechas`, `sysmaster:`  ⚠️ext | `sc_activa_codi_isa`, `sc_activaciones_codi` |
| `sp_activacuentas` | 105 | 0 | `sc_fechas`, `sysmaster:systabnames`  ⚠️ext | `STATISTICS`, `sc_maechq`, `sc_maenoc` |
| `sp_actmarhuella` | 171 | 0 | `bdicheq:sc_maechq`  ⚠️ext, `bdicheq:sc_producto`  ⚠️ext, `bdicheq:sc_tarjeta`  ⚠️ext, `bdinteg:si_cliente`  ⚠️ext | `bdicheq:sc_maechq`  ⚠️ext |
| `sp_actmsje_edocta_cfd` | 213 | 0 | `sc_mensajes_producto`, `sc_piepagina_edocta_factelect` | `sc_piepagina_edocta_factelect` |
| `sp_actnumcheques` | 45 | 0 | `sc_contch`, `sc_maechq` | — |
| `sp_actparamactsdos` | 174 | 0 | `sc_fechas`, `sc_maechq` | `sc_param` |
| `sp_actparamactsdos_especial` | 150 | 0 | `sc_fechas`, `sc_maechq` | `sc_param` |
| `sp_actparamcierre` | 266 | 0 | `sc_fechas`, `sc_maechq` | `sc_param` |
| `sp_actparamcierre_alt` | 141 | 0 | `sc_fechas`, `sc_maechq` | `sc_param` |
| `sp_actparamcierre_melleva` | 201 | 0 | `sc_fechas`, `sc_maechq` | `sc_param` |
| `sp_actparamcierre_mib` | 201 | 0 | `sc_fechas`, `sc_maechq` | `sc_param` |
| `sp_actparamcierre_vb` | 73 | 0 | `sc_fechas`, `sc_maechq` | `sc_param` |
| `sp_actparamconcilchq` | 188 | 0 | `sc_fechas`, `sc_maechq` | `sc_param` |
| `sp_actparamhistmovchq` | 111 | 0 | `sc_movdia_concil` | `sc_param` |
| `sp_actparampasecheq` | 131 | 0 | `bdicheq:sc_movdia_concil`  ⚠️ext | `bdicheq:sc_param`  ⚠️ext |
| `sp_actparampasecheqhis` | 131 | 0 | `sc_movhis` | `sc_param` |
| `sp_actparampasomovshis` | 172 | 0 | `sc_fechas`, `sc_movdia` | `sc_param` |
| `sp_actparampasomovshisold` | 196 | 0 | `sc_movhis` | `sc_param` |
| `sp_actsdodiarioc` | 759 | 0 | `bdicheq:`  ⚠️ext, `bdicheq:sc_maechq`  ⚠️ext, `bdicheq:sc_maenoc`  ⚠️ext, `bdicheq:sc_movhis`  ⚠️ext, `bdicheq:sc_producto`  ⚠️ext, `bdiedoelec:`  ⚠️ext | `bdicheq:`  ⚠️ext, `sc_riesgoscap`, `sc_sdodiarioc` |
| `sp_actsdomensualc` | 282 | 0 | `invcrecxcancelar`, `sc_maechq`, `sc_movhis`, `sc_sdodiarioc`, `sc_sdomensualc`, `sysmaster:systabnames`  ⚠️ext | `STATISTICS`, `invcrecxcancelar`, `sc_maechq`, `sc_sdomensualc` |
| `sp_actsdotrimestralc` | 112 | 0 | `sc_sdomensualc`, `sc_sdotrimestralc` | `sc_sdotrimestralc` |
| `sp_actsdotrimestralc_esp` | 89 | 0 | `sc_sdomensualc` | `sc_sdotrimestralc` |
| `sp_actual_ctaclabe` | 90 | 0 | `sc_maechq` | `sc_maechq` |
| `sp_actual_ctasconc` | 68 | 0 | `sc_maechq` | `sc_maechq` |
| `sp_actualfechas_invscrecs` | 111 | 0 | `sc_maenoc`, `sc_param`, `sc_tasa_variable`, `sc_valcierre_his`, `tmp_invs_incidencia` | `STATISTICS`, `sc_maenoc`, `sc_tasa_variable` |
| `sp_actualiza_acumtrapres` | 63 | 0 | `sc_acumtrapres`, `sc_maechq` | `sc_acumtrapres` |
| `sp_actualiza_chq_cap` | 313 | 0 | `bdicheq:`  ⚠️ext, `bdinteg:`  ⚠️ext, `sysmaster:`  ⚠️ext, `tmp_captacion_cap`, `tmp_captacion_vpn` | `bdicheq:`  ⚠️ext, `bdiunica` |
| `sp_actualiza_control_cobranza_automatica` | 1544 | 0 | `bdiaclaracion:acl_aclaracion`  ⚠️ext, `bdinteg:`  ⚠️ext, `bdinteg:si_cliente`  ⚠️ext, `bdinteg:si_cliente_nivel`  ⚠️ext, `bdinteg:si_ejecut`  ⚠️ext, `bdinteg:si_ptf`  ⚠️ext | `sc_acummesctanvl2`, `sc_bit_error_cobranza_automatica`, `sc_control_cobranza_automatica`, `sc_depinterpza` | 🔄
| `sp_actualiza_ctasconsbg` | 60 | 0 | `sc_limite_sbg` | `sc_limite_sbg`, `sc_limite_sbg_resp` |
| `sp_actualiza_ctassbg` | 63 | 0 | `sc_limite_sbg` | `sc_limite_sbg`, `sc_limite_sbg_resp` |
| `sp_actualiza_instruccionvencimiento` | 107 | 0 | `bdicheq:`  ⚠️ext, `bdicheq:sc_maechq`  ⚠️ext, `sc_maeinstrucc` | `bdicheq:`  ⚠️ext |
| `sp_actualiza_invscrecs` | 89 | 0 | `sc_fechas`, `sc_maeinstrucc`, `sc_movhis`, `sc_valcierre_his`, `tmp_ctaseje` | `sc_maechq`, `sc_movdia` |
| `sp_actualiza_isr` | 59 | 0 | `sc_encabezado2_edocta_factelect_old`, `sc_fechas`, `sc_isr`, `tmp_sc_encabezado2_edocta_factelect_old` | `sc_encabezado2_edocta_factelect_old` |
| `sp_actualiza_limite_sbg` | 67 | 0 | `sc_limite_sbg` | `sc_limite_sbg` |
| `sp_actualiza_portabilidad` | 307 | 0 | `bdicheq:`  ⚠️ext | `bdicheq:`  ⚠️ext |
| `sp_actualiza_portabilidad_pba` | 179 | 0 | `bdicheq:`  ⚠️ext | `bdicheq:`  ⚠️ext |
| `sp_actualiza_portabilidad_web` | 185 | 0 | `bdicheq:`  ⚠️ext, `bdinteg:si_cliente`  ⚠️ext, `sc_firmantes`, `sc_maechq` | `bdicheq:`  ⚠️ext, `bdinteg:si_cterelacionado`  ⚠️ext, `sc_firmantes`, `sc_maenoc` |
| `sp_actualiza_reg_porta` | 218 | 0 | `bdicheq:`  ⚠️ext, `bdinteg:`  ⚠️ext, `bdispei:`  ⚠️ext, `sc_fechas`, `sc_portacec_solicitud`, `sysmaster:systabnames`  ⚠️ext | — |
| `sp_actualiza_retenidos_pos` | 106 | 0 | `sc_depinterpza`, `sc_depositospei`, `sc_docret`, `sc_maechq`, `tmp_ctas_excluidas` | `STATISTICS`, `sc_maechq`, `tmp_ctas_excluidas` |
| `sp_actualiza_retenidos_spei_interpza` | 143 | 0 | `sc_depinterpza`, `sc_depositospei`, `sc_docret`, `sc_maechq`, `tmp_ctas_retenidos` | `STATISTICS`, `sc_maechq`, `tmp_ctas_retenidos` |
| `sp_actualiza_saldos` | 93 | 0 | `sc_sdodiarioc` | `sc_sdodiarioc` |

## Tablas compartidas (múltiples escritores) — riesgo de contención en parallel-run

- **`sc_maechq`**: escrita por `sp_actualiza_retenidos_pos`, `abono_ref_web`, `sp_abonos_operaciones_esp`, `sp_actualiza_invscrecs`, `sp_actsdomensualc` ... y 12 más
- **`STATISTICS`**: escrita por `sp_actualiza_retenidos_pos`, `abono_ctas`, `abono_ctas_comis`, `sp_abonos_operaciones_esp`, `sp_abonos_operaciones` ... y 11 más
- **`sc_param`**: escrita por `sp_actparamcierre_vb`, `sp_actparamcierre_alt`, `sp_actparamcierre_melleva`, `sp_actparampasomovshisold`, `sp_actparamcierre_mib` ... y 7 más
- **`bdicheq:`**: escrita por `sp_actualiza_portabilidad_web`, `sp_actualiza_instruccionvencimiento`, `sp_actualizaobservaciones`, `sp_actualizar_registros_indicadores_1`, `sp_actualizar_registros_indicadores` ... y 4 más
- **`sc_movdia`**: escrita por `sp_actualiza_invscrecs`, `abono`, `sp_actualiza_control_cobranza_automatica`, `abono_ref_web`, `abono_ref` ... y 4 más

## Tablas candidatas a CDC prioritario (Debezium / AWS DMS)

| Tabla | SPs escritores | Prioridad CDC |
|-------|---------------|---------------|
| `sc_maechq` | `sp_actualiza_retenidos_pos`, `abono_ref_web`, `sp_abonos_operaciones_esp` | 🔴 PRIMERA |
| `STATISTICS` | `sp_actualiza_retenidos_pos`, `abono_ctas`, `abono_ctas_comis` | 🔴 PRIMERA |
| `sc_param` | `sp_actparamcierre_vb`, `sp_actparamcierre_alt`, `sp_actparamcierre_melleva` | 🔴 PRIMERA |
| `sc_movdia` | `sp_actualiza_invscrecs`, `abono`, `sp_actualiza_control_cobranza_automatica` | 🔴 PRIMERA |
| `sc_maenoc` | `sp_actualiza_portabilidad_web`, `sp_actualfechas_invscrecs`, `sp_activacuentas` | 🟠 SEGUNDA |
| `sc_depinterpza` | `abono_ref_web`, `abono_ref`, `sp_actualiza_control_cobranza_automatica` | 🟠 SEGUNDA |
| `sc_depositosefectivo` | `abono_ref_web`, `abono_ref`, `sp_actualiza_control_cobranza_automatica` | 🟠 SEGUNDA |
| `sc_premio` | `abono_ref_web`, `abono_ref`, `sp_actualiza_control_cobranza_automatica` | 🟠 SEGUNDA |

## Tablas externas accedidas (cross-DB)

- `BDICHEQ:` (R) — desde `sp_actualiza_est_reg_contr_evid_notif_porta`
- `BDICHEQ:sc_param` (R) — desde `sp_actualiza_est_reg_contr_evid_notif_porta`
- `BDICHEQ:sc_portaarchtemp` (R+W) — desde `sp_actualiza_est_reg_contr_evid_notif_porta`
- `BDICHEQ:sc_portacec_solicitud` (R) — desde `sp_actualiza_est_reg_contr_evid_notif_porta`
- `BDICHEQ:sc_tarjeta` (R) — desde `sp_abono_sd_pbajlh`
- `BDICRED:sd_maecred` (R) — desde `sp_actualiza_est_reg_contr_evid_notif_porta`
- `BDICRED:sd_maecredcrd` (R) — desde `sp_actualiza_est_reg_contr_evid_notif_porta`
- `BDINTEG:si_telefonos_actual` (R) — desde `sp_actualiza_est_reg_contr_evid_notif_porta`
- `bdiaclaracion:acl_aclaracion` (R) — desde `abono_ref_web`, `abono_ref`, `sp_actualiza_control_cobranza_automatica`
- `bdicheq:` (R+W) — desde `sp_actualiza_instruccionvencimiento`, `sp_actualizar_registros_indicadores`, `sp_actualiza_portabilidad`
- `bdicheq:sc_activa_codi_isa` (R) — desde `sp_activaciones_codi_isa`
- `bdicheq:sc_activaciones_codi` (R) — desde `sp_activaciones_codi_isa`
- `bdicheq:sc_bloqueo` (R) — desde `abono_cred`
- `bdicheq:sc_contproc` (R+W) — desde `sp_actualizafechaconci_atm`
- `bdicheq:sc_ctabloqueo` (R+W) — desde `sp_actualizakelloggs`
- `bdicheq:sc_ctabloqueohist` (R+W) — desde `sp_actualizakelloggs`
- `bdicheq:sc_detalle_edocta_factelect_old` (R+W) — desde `sp_actualizaobservaciones`
- `bdicntchq:sq_param` (R) — desde `abonoref_td`
- `bdicred:` (R) — desde `sp_actualizaobservaciones`, `sp_actualizar_registros_indicadores_1`, `sp_actualizar_registros_indicadores`
- `bdicred:sd_ctascarg` (R) — desde `sp_actualiza_est_reg_contr_evid_notif_porta`
- `bdicred:sd_maesdos` (R) — desde `sp_actualiza_est_reg_contr_evid_notif_porta`
- `bdiedoelec:` (R) — desde `sp_actsdodiarioc`
- `bdinteg:` (R) — desde `sp_abono_sd`, `abono_ref_web`, `abonoref_td`
- `bdinteg:si_bancos` (R) — desde `sp_actualiza_est_reg_contr_evid_notif_porta`
- `bdinteg:si_bpiusuarios` (R) — desde `sp_activaciones_codi_isa`
- `bdinteg:si_canales` (R) — desde `abonoref_td`
- `bdinteg:si_catciudades` (R) — desde `sp_actsdodiarioc`
- `bdinteg:si_cliente` (R) — desde `sp_actualiza_portabilidad_web`, `sp_abono_sd`, `abono_ref_web`
- `bdinteg:si_cliente_nivel` (R) — desde `abono_ref_web`, `abono_ref`, `sp_actualiza_control_cobranza_automatica`
- `bdinteg:si_codret` (R) — desde `sp_actualiza_est_reg_contr_evid_notif_porta`
- `bdinvers:sv_gat` (R) — desde `sp_abono_sd`
- `bdinvers:sv_maeinv` (R) — desde `sp_actualizakelloggs`
- `bdisac:sac_movimientos` (R) — desde `abono_ref_web`, `abono_ref`, `sp_actualiza_control_cobranza_automatica`
- `bdisolic:ss_adn_solicitudcuenta` (R) — desde `sp_actualiza_est_reg_contr_evid_notif_porta`
- `bdisolic:ss_prestamoscoppel` (R) — desde `sp_abono_sd_pbajlh`
- `bdispei:` (R) — desde `sp_actualiza_reg_porta`
- `bdispei:tblparametros` (R) — desde `sp_actualiza_control_cobranza_automatica`, `abono_ref_web`, `abono_ref`
- `bditransfer:tf_maecte` (R) — desde `abono_ref_web`, `abono_ref`, `sp_actualiza_control_cobranza_automatica`
- `sysmaster:` (R) — desde `sp_actualiza_chq_cap`, `sp_activaciones_codi_isa`
- `sysmaster:systabnames` (R) — desde `abono_ctas`, `abono_ctas_comis`, `sp_actualiza_reg_porta`

---
*Generado por: Specialist — Informix SPL Analysis · 2026-07-03 · Evidencia: source/informix/bdicheq_*.sql (análisis estático de 70 archivos SQL) · análisis estático de cláusulas FROM/INSERT/UPDATE/DELETE*

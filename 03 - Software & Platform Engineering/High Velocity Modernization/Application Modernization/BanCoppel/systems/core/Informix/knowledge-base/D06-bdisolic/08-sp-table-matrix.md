# D06 · Solicitudes — Matriz SP × Tabla (READ / WRITE)

> **Componente:** Informix · SPE-AM-001 · Etapa 1
> **Base de datos:** `bdisolic` · IBM Informix IDS 14.10 / POWER-AIX
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

## Importancia para Etapa 2 (Data RE)

Esta matriz determina:
1. **Ownership de datos**: qué SP (y por ende qué microservicio target) es dueño de cada tabla
2. **Tablas compartidas**: múltiples SPs escriben → punto de contención → candidatas a patrón CQRS
3. **Prioridad CDC**: tablas con más escritores priorizan la configuración de Debezium / DMS
4. **Scope de migración**: tablas que solo leen SPs de código muerto pueden excluirse del scope

> 🔄 = SP usa `EXECUTE PROCEDURE` con variable — puede leer/escribir tablas adicionales no detectadas estáticamente.

## Resumen de tablas propias de `bdisolic`

| Tabla | Tipo | Lectores | Escritores | Ownership |
|-------|------|----------|-----------|-----------|
| `ss_solicitudes` | Transaccional | 3 | 4 | 🟠 4 SPs escriben |
| `ss_autorizacion` | Transaccional | 3 | 3 | 🟠 3 SPs escriben |
| `ss_param` | Catálogo / Config | 5 | 0 | 🟢 Solo lectura |
| `ss_resum_scor_fin` | Transaccional | 1 | 2 | 🟠 2 SPs escriben |
| `bdidigital` | Transaccional | 3 | 0 | 🟢 Solo lectura |
| `paso_incrementoadn` | Transaccional | 2 | 0 | 🟢 Solo lectura |
| `ss_tp_solicitud` | Transaccional | 2 | 0 | 🟢 Solo lectura |
| `si_tmphistdiv` | Reportería / Temporal | 1 | 1 | 🟠 1 SPs escriben |
| `STATISTICS` | Transaccional | 0 | 2 | 🟠 2 SPs escriben |
| `ss_solsuperv_paso` | Transaccional | 1 | 1 | 🟠 1 SPs escriben |
| `ss_autorizacion_especial` | Transaccional | 1 | 1 | 🟠 1 SPs escriben |
| `ss_cont_norecuperados` | Transaccional | 0 | 1 | 🟠 1 SPs escriben |
| `systables` | Transaccional | 1 | 0 | 🟢 Solo lectura |
| `AX_PASO` | Transaccional | 0 | 1 | 🟠 1 SPs escriben |
| `dual` | Transaccional | 1 | 0 | 🟢 Solo lectura |
| `ss_anexosol` | Transaccional | 0 | 1 | 🟠 1 SPs escriben |
| `tmp_solicitudes_dif` | Transaccional | 1 | 0 | 🟢 Solo lectura |
| `ss_solicitudes_mc` | Transaccional | 1 | 0 | 🟢 Solo lectura |
| `bdiunica` | Transaccional | 0 | 1 | 🟠 1 SPs escriben |
| `ss_soltrat` | Transaccional | 0 | 1 | 🟠 1 SPs escriben |

> **[SME-PENDING]** Confirmar nombre exacto en producción, volumen de registros, política de retención y campos PII con DBA BanCoppel.

## Matriz completa SP × Tabla

| SP | LOC | Fan-in | Tablas que LEE | Tablas que ESCRIBE |
|----|-----|--------|---------------|-------------------|
| `sp_actualiza_status_sol` | 653 | 100 | `BDISOLIC:ss_solicitud_os`  ⚠️ext, `bdicred:sd_fechas`  ⚠️ext, `bdinteg:`  ⚠️ext, `bdiprospectos:`  ⚠️ext, `bdisolic:`  ⚠️ext, `bdisolic:informix`  ⚠️ext | `BDISOLIC:ss_solicitud_os`  ⚠️ext, `bdINteg:si_cliente`  ⚠️ext, `bdinteg:si_solicitud_movil`  ⚠️ext, `bdisolic:`  ⚠️ext |
| `sp_adn_incrementa_lincred` | 652 | 0 | `bdicheq:`  ⚠️ext, `bdicred:`  ⚠️ext, `bdicred:sd_definicion`  ⚠️ext, `bdinteg:si_empresas`  ⚠️ext, `bdisolic:`  ⚠️ext, `paso_incrementoadn` | `STATISTICS`, `bdicred:`  ⚠️ext, `bdisolic:`  ⚠️ext |
| `sp_adn_incrementa_lincred_pbajj` | 652 | 0 | `bdicheq:`  ⚠️ext, `bdicred:`  ⚠️ext, `bdicred:sd_definicion`  ⚠️ext, `bdinteg:si_empresas`  ⚠️ext, `bdisolic:`  ⚠️ext, `paso_incrementoadn` | `STATISTICS`, `bdicred:`  ⚠️ext, `bdisolic:`  ⚠️ext |
| `sp_asigna_solicitud_soc` | 571 | 236 | `bdicnweb:`  ⚠️ext, `bdicobranza:`  ⚠️ext, `bdidigital`, `bdinteg:si_bitacora_ife`  ⚠️ext, `bdinteg:si_sucursales`  ⚠️ext, `bdisolic:`  ⚠️ext | `bdisolic:ss_solicitudes_mc`  ⚠️ext |
| `sp_actualiza_monto_lineas` | 343 | 0 | `bdicred:sd_fechas`  ⚠️ext, `bdicred:sd_maecred`  ⚠️ext, `bdicred:sd_maesdos`  ⚠️ext, `bdicred:sd_tarjeta`  ⚠️ext, `bdinteg:si_ctepf`  ⚠️ext, `bdinteg:si_ingresos`  ⚠️ext | `AX_PASO`, `bdicred:sd_maesdos`  ⚠️ext, `bdicred:sd_tarjeta`  ⚠️ext, `ss_autorizacion_especial` |
| `sp_adn_obtienectas_web` | 125 | 1 | `bdicheq:`  ⚠️ext, `bdicheq:sc_portacec_solicitud`  ⚠️ext | — |
| `sp_actualiza_statusmttobcycc` | 117 | 9 | `bdicred:`  ⚠️ext, `bdisolic:`  ⚠️ext | — |
| `sp_adn_obtenerctanomina` | 112 | 0 | `bdicheq:`  ⚠️ext, `bdicred:`  ⚠️ext | — |
| `sp_act_norecuperados` | 19 | 0 | — | `ss_cont_norecuperados` |
| `sp_actualiza_estatus_sol_canal` | 39 | 0 | `bdisolic:ss_solicitudes`  ⚠️ext | — |
| `sp_actualiza_info_cac` | 50 | 0 | — | `bdisolic:`  ⚠️ext |
| `sp_actualiza_respuestacoppel_cteprosp` | 49 | 0 | — | `bdiprospectos:`  ⚠️ext, `bdisolic:`  ⚠️ext |
| `sp_actualiza_resumscorfin` | 117 | 0 | `bdisolic:`  ⚠️ext | `bdisolic:`  ⚠️ext |
| `sp_actualiza_solicitudes` | 172 | 0 | `TABLE`, `bdisolic:`  ⚠️ext, `bdisolic:tmp_solicitudes`  ⚠️ext, `sysmaster:`  ⚠️ext, `tmp_solicitudes_ap`, `tmp_solicitudes_at` | `bdiunica` |
| `sp_actualiza_solicitudes_inserta_datos` | 65 | 0 | — | `bdisolic:ss_autorizacion_especial`  ⚠️ext, `bdisolic:ss_solicitudes`  ⚠️ext |
| `sp_actualiza_statusmttobcycc_pba` | 101 | 0 | `bdicred:`  ⚠️ext, `bdisolic:`  ⚠️ext | — |
| `sp_actualiza_tipoparametrico` | 35 | 0 | `bdisolic:ss_solicitudes`  ⚠️ext | `bdisolic:ss_solicitudes`  ⚠️ext |
| `sp_actualizacanalsol` | 41 | 0 | `bdicred:sd_maecred`  ⚠️ext, `bdisolic:ss_solicitudes`  ⚠️ext | `bdisolic:ss_solicitudes`  ⚠️ext |
| `sp_actualizadatos_reevaluacion` | 51 | 0 | — | — |
| `sp_actualizadatos_reevaluacion_web` | 45 | 0 | — | — |
| `sp_actualizagrupo` | 150 | 0 | `bdicred:sd_fechas`  ⚠️ext, `bdisolic:ss_resum_scor_fin`  ⚠️ext | `bdisolic:ss_resum_scor_fin`  ⚠️ext |
| `sp_actualizanumsalariominimo` | 112 | 0 | `bdinteg:si_histdiv`  ⚠️ext, `bdisolic:ss_resum_scor_fin`  ⚠️ext, `si_tmphistdiv`, `systables` | `bdisolic:ss_resum_scor_fin`  ⚠️ext, `si_tmphistdiv` |
| `sp_actualizapuntajesol` | 48 | 0 | `bdisolic:`  ⚠️ext, `bdisolic:ss_nuevo_parametrico`  ⚠️ext | `bdisolic:ss_nuevo_parametrico`  ⚠️ext |
| `sp_actualizasolicitudes_motor` | 26 | 0 | — | — |
| `sp_actualizasolicitudes_motor_adn` | 36 | 0 | `bdisolic:`  ⚠️ext | `bdisolic:`  ⚠️ext |
| `sp_actualizasolicitudes_motor_pp` | 26 | 0 | — | — |
| `sp_actualizasolicmc` | 92 | 0 | `bdicobranza:`  ⚠️ext, `bdinteg:`  ⚠️ext | — |
| `sp_actualizasolicmc_lineas` | 60 | 0 | — | — |
| `sp_adn_calculalinea` | 327 | 0 | `bdicheq:`  ⚠️ext, `bdicred:`  ⚠️ext, `bdisolic:`  ⚠️ext, `bdisolic:ss_param`  ⚠️ext | — |
| `sp_adn_cosultacuenta` | 133 | 0 | `bdinteg:`  ⚠️ext, `bdisolic:ss_solicitudes`  ⚠️ext | — |
| `sp_adn_cosultacuenta_web` | 133 | 0 | `bdinteg:`  ⚠️ext, `bdisolic:ss_solicitudes`  ⚠️ext | — |
| `sp_adn_evalua_ing` | 62 | 0 | `bdicheq:`  ⚠️ext | — |
| `sp_adn_guardasolicitudcuenta` | 81 | 0 | `bdinteg:`  ⚠️ext, `bdinteg:si_carriers`  ⚠️ext | — |
| `sp_adn_inforeportes` | 128 | 0 | `bdicred:`  ⚠️ext, `bdicred:sd_definicion`  ⚠️ext, `bdinteg:`  ⚠️ext | — |
| `sp_adn_inforeportes_web` | 128 | 0 | `bdicred:`  ⚠️ext, `bdicred:sd_definicion`  ⚠️ext, `bdinteg:`  ⚠️ext | — |
| `sp_adn_obtienectas` | 68 | 0 | `bdicheq:`  ⚠️ext, `bdisolic:`  ⚠️ext | — |
| `sp_adn_obtienectasflex` | 75 | 0 | `bdicheq:`  ⚠️ext | — |
| `sp_adn_reeimpresion` | 85 | 0 | `bdicred:`  ⚠️ext, `bdinteg:`  ⚠️ext | — |
| `sp_adn_repgeneral` | 76 | 0 | — | — |
| `sp_adn_reporteinfodisp` | 144 | 0 | `bdicred:`  ⚠️ext | — |
| `sp_adn_reporteinfodisp_web` | 144 | 0 | `bdicred:`  ⚠️ext | — |
| `sp_altaclientehuellaadicional` | 108 | 0 | `bdinteg:`  ⚠️ext | — |
| `sp_altaclientehuellatitular` | 108 | 0 | `bdinteg:`  ⚠️ext | — |
| `sp_altaclientehuellatitular_web` | 108 | 0 | `bdinteg:`  ⚠️ext | — |
| `sp_apercredcoppel` | 70 | 0 | `bdinteg:`  ⚠️ext, `bdisolic:`  ⚠️ext | `bdinteg:`  ⚠️ext, `bdisolic:`  ⚠️ext, `bdisolic:ss_autorizacion`  ⚠️ext |
| `sp_apercredcoppel2` | 104 | 0 | `bdinteg:`  ⚠️ext, `bdiprospectos:`  ⚠️ext, `bdisolic:ss_autorizacion`  ⚠️ext, `bdisolic:ss_nuevo_parametrico`  ⚠️ext, `bdisolic:ss_param`  ⚠️ext | `bdinteg:`  ⚠️ext, `bdisolic:`  ⚠️ext |
| `sp_asigna_solicitud_mc` | 59 | 0 | — | — |
| `sp_asigna_solicitud_soc_2p_ratj` | 314 | 0 | `bdicobranza:`  ⚠️ext, `bdinteg:si_bitacora_ife`  ⚠️ext, `bdinteg:si_sucursales`  ⚠️ext, `bdisolic:`  ⚠️ext, `bdisolic:ss_resum_scor_fin`  ⚠️ext, `bdisolic:ss_resumen_scoring`  ⚠️ext | `bdisolic:ss_solicitudes_mc`  ⚠️ext |
| `sp_asigna_solicitud_soc_3p_ratj` | 439 | 0 | `bdicnweb:`  ⚠️ext, `bdicobranza:`  ⚠️ext, `bdidigital`, `bdinteg:si_bitacora_ife`  ⚠️ext, `bdinteg:si_sucursales`  ⚠️ext, `bdisolic:`  ⚠️ext | `bdisolic:ss_solicitudes_mc`  ⚠️ext |
| `sp_asigna_solicitud_soc_costo` | 314 | 0 | `bdicobranza:`  ⚠️ext, `bdinteg:si_bitacora_ife`  ⚠️ext, `bdinteg:si_sucursales`  ⚠️ext, `bdisolic:`  ⚠️ext, `bdisolic:ss_resum_scor_fin`  ⚠️ext, `bdisolic:ss_resumen_scoring`  ⚠️ext | `bdisolic:ss_solicitudes_mc`  ⚠️ext |

## Tablas compartidas (múltiples escritores) — riesgo de contención en parallel-run

- **`bdisolic:`**: escrita por `sp_adn_incrementa_lincred_pbajj`, `sp_apercredcoppel2`, `sp_actualiza_info_cac`, `sp_actualiza_respuestacoppel_cteprosp`, `actualiza_solos_pba` ... y 12 más
- **`bdisolic:ss_solicitudes_mc`**: escrita por `sp_asigna_solicitud_soc_3p_ratj`, `sp_asigna_solicitud_soc_ratj`, `sp_asigna_solicitud_soc_costo`, `sp_asigna_solicitud_soc_2p_ratj`, `sp_asigna_solicitudaleatoria_mc` ... y 1 más
- **`bdisolic:ss_solicitudes`**: escrita por `sp_actualiza_tipoparametrico`, `sp_actualiza_solicitudes_inserta_datos`, `alta_sol_tc_cjunk_multicanal`, `sp_actualiza_status_sol`, `sp_actualizacanalsol`
- **`ss_solicitudes`**: escrita por `actualiza_solos`, `sp_actualiza_status_sol`, `actualiza_solos_pba`, `sp_actualiza_monto_lineas`
- **`ss_autorizacion`**: escrita por `actualiza_solos`, `actualiza_solos_pba`, `sp_actualiza_status_sol`

## Tablas candidatas a CDC prioritario (Debezium / AWS DMS)

| Tabla | SPs escritores | Prioridad CDC |
|-------|---------------|---------------|
| `ss_solicitudes` | `actualiza_solos`, `sp_actualiza_status_sol`, `actualiza_solos_pba` | 🟠 SEGUNDA |
| `ss_autorizacion` | `actualiza_solos`, `actualiza_solos_pba`, `sp_actualiza_status_sol` | 🟠 SEGUNDA |
| `STATISTICS` | `sp_adn_incrementa_lincred_pbajj`, `sp_adn_incrementa_lincred` | 🟡 TERCERA |
| `ss_resum_scor_fin` | `alta_sol_tcpba`, `alta_sol_tc` | 🟡 TERCERA |
| `ss_cont_norecuperados` | `sp_act_norecuperados` | 🟡 TERCERA |
| `ss_autorizacion_especial` | `sp_actualiza_monto_lineas` | 🟡 TERCERA |
| `AX_PASO` | `sp_actualiza_monto_lineas` | 🟡 TERCERA |
| `bdiunica` | `sp_actualiza_solicitudes` | 🟡 TERCERA |

## Tablas externas accedidas (cross-DB)

- `BDISOLIC:ss_solicitud_os` (R+W) — desde `sp_actualiza_status_sol`
- `bdINteg:si_cliente` (R+W) — desde `sp_actualiza_status_sol`
- `bdicheq:` (R) — desde `sp_adn_incrementa_lincred_pbajj`, `sp_adn_obtienectas`, `sp_adn_evalua_ing`
- `bdicheq:sc_portacec_solicitud` (R) — desde `sp_adn_obtienectas_web`
- `bdicnweb:` (R) — desde `sp_asigna_solicitud_soc_3p_ratj`, `sp_asigna_solicitud_soc_ratj`, `sp_asigna_solicitud_soc`
- `bdicobranza:` (R) — desde `sp_asigna_solicitud_soc_3p_ratj`, `sp_asigna_solicitud_soc_costo`, `sp_asigna_solicitud_soc_ratj`
- `bdicred:` (R+W) — desde `sp_adn_incrementa_lincred_pbajj`, `sp_adn_inforeportes_web`, `sp_adn_calculalinea`
- `bdicred:sd_definicion` (R) — desde `sp_adn_incrementa_lincred_pbajj`, `sp_adn_incrementa_lincred`, `sp_adn_inforeportes_web`
- `bdicred:sd_fechas` (R) — desde `sp_actualizagrupo`, `sp_actualiza_status_sol`, `sp_actualiza_monto_lineas`
- `bdicred:sd_maecred` (R) — desde `sp_actualizacanalsol`, `sp_actualiza_monto_lineas`
- `bdicred:sd_maesdos` (R+W) — desde `sp_actualiza_monto_lineas`
- `bdicred:sd_param` (R+W) — desde `asigna_numsolp`, `asigna_numsol_web`, `asigna_numsol`
- `bdicred:sd_tarjeta` (R+W) — desde `sp_actualiza_monto_lineas`
- `bdinteg:` (R+W) — desde `sp_adn_inforeportes_web`, `sp_adn_reeimpresion`, `sp_adn_cosultacuenta`
- `bdinteg:si_actsubact` (R) — desde `alta_sol_tc_cjunk_multicanal`
- `bdinteg:si_bitacora_ife` (R) — desde `sp_asigna_solicitud_soc_3p_ratj`, `sp_asigna_solicitud_soc_ratj`, `sp_asigna_solicitud_soc_costo`
- `bdinteg:si_carriers` (R) — desde `sp_adn_guardasolicitudcuenta`
- `bdinteg:si_cliente` (R) — desde `sp_asigna_solicitudaleatoria_mc`, `alta_sol_tc_cjunk_multicanal`
- `bdinteg:si_ctepf` (R) — desde `alta_sol_tc`, `alta_sol_tcpba`, `alta_sol_tc_cjunk_multicanal`
- `bdinteg:si_direcciones` (R) — desde `alta_sol_tc_cjunk_rodo2`, `alta_sol_tc_cjunk`, `alta_sol_tc_cjunk_web`
- `bdinteg:si_edocivil` (R) — desde `alta_sol_tc_cjunk_multicanal`
- `bdiprospectos:` (R+W) — desde `sp_actualiza_respuestacoppel_cteprosp`, `sp_apercredcoppel2`, `sp_actualiza_status_sol`
- `bdisolic:` (R+W) — desde `sp_asigna_solicitud_soc_costo`, `sp_asigna_solicitud_soc_ratj`, `sp_actualiza_info_cac`
- `bdisolic:informix` (R+W) — desde `sp_actualiza_status_sol`
- `bdisolic:ss_analistaenatencion` (R) — desde `sp_asigna_solicitudaleatoria_mc`
- `bdisolic:ss_autorizacion` (R+W) — desde `sp_apercredcoppel`, `sp_apercredcoppel2`, `sp_actualiza_status_sol`
- `bdisolic:ss_autorizacion_especial` (R+W) — desde `sp_actualiza_solicitudes_inserta_datos`
- `bdisolic:ss_clienteslargos` (R+W) — desde `sp_actualiza_status_sol`
- `bdisolic:ss_cte_procesando` (R) — desde `sp_asigna_solicitudaleatoria_mc`
- `bdisolic:ss_detalle_scoring` (R+W) — desde `alta_sol_tc_cjunk_multicanal`
- `sysmaster:` (R) — desde `sp_actualiza_solicitudes`
- `sysmaster:sysshmvals` (R) — desde `sp_actualiza_status_sol`

---
*Generado por: Specialist — Informix SPL Analysis · 2026-07-03 · Evidencia: source/informix/bdisolic_*.sql (análisis estático de 70 archivos SQL) · análisis estático de cláusulas FROM/INSERT/UPDATE/DELETE*

# D05 · Saldos y Cuentas — Matriz SP × Tabla (READ / WRITE)

> **Componente:** LegacyCore · SPE-AM-001 · Etapa 1
> **Base de datos:** `bdisac` · IBM Informix IDS 14.10 / POWER-AIX
> **Wave:** Wave 3 · Riesgo: **ALTO**
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

## Importancia para Etapa 2 (Data RE)

Esta matriz determina:
1. **Ownership de datos**: qué SP (y por ende qué microservicio target) es dueño de cada tabla
2. **Tablas compartidas**: múltiples SPs escriben → punto de contención → candidatas a patrón CQRS
3. **Prioridad CDC**: tablas con más escritores priorizan la configuración de Debezium / DMS
4. **Scope de migración**: tablas que solo leen SPs de código muerto pueden excluirse del scope

> 🔄 = SP usa `EXECUTE PROCEDURE` con variable — puede leer/escribir tablas adicionales no detectadas estáticamente.

## Resumen de tablas propias de `bdisac`

| Tabla | Tipo | Lectores | Escritores | Ownership |
|-------|------|----------|-----------|-----------|
| `sac_remesas_estadistica` | Transaccional | 10 | 3 | 🟠 3 SPs escriben |
| `sac_app_getorder` | Transaccional | 6 | 3 | 🟠 3 SPs escriben |
| `sac_procesos_jobs` | Log / Bitácora | 0 | 9 | 🔴 9 SPs escriben |
| `sac_convenios` | Transaccional | 2 | 6 | 🔴 6 SPs escriben |
| `sac_fechas` | Transaccional | 7 | 0 | 🟢 Solo lectura |
| `sac_mensajeerror` | Transaccional | 0 | 6 | 🔴 6 SPs escriben |
| `sac_param` | Catálogo / Config | 6 | 0 | 🟢 Solo lectura |
| `STATISTICS` | Transaccional | 0 | 6 | 🔴 6 SPs escriben |
| `TABLE` | Transaccional | 6 | 0 | 🟢 Solo lectura |
| `sac_paises_permitidos` | Transaccional | 5 | 0 | 🟢 Solo lectura |
| `sac_movimientoshistorial` | Transaccional | 5 | 0 | 🟢 Solo lectura |
| `sac_controlarchivoscobranza` | Control batch | 0 | 5 | 🟠 5 SPs escriben |
| `temp_reporteenrolamiento58` | Reportería / Temporal | 2 | 2 | 🟠 2 SPs escriben |
| `tablaTemporal` | Transaccional | 2 | 2 | 🟠 2 SPs escriben |
| `temp988_sac_wu_pay` | Transaccional | 2 | 2 | 🟠 2 SPs escriben |
| `sac_cte_remesas` | Transaccional | 3 | 1 | 🟠 1 SPs escriben |
| `sac_app_pemporal2` | Transaccional | 3 | 0 | 🟢 Solo lectura |
| `sac_remesaslimitepld_app` | Transaccional | 3 | 0 | 🟢 Solo lectura |
| `sac_pagostae` | Transaccional | 3 | 0 | 🟢 Solo lectura |
| `temp988_sac_movimientoshistorial` | Transaccional | 2 | 0 | 🟢 Solo lectura |

> **[SME-PENDING]** Confirmar nombre exacto en producción, volumen de registros, política de retención y campos PII con DBA LegacyCore.

## Matriz completa SP × Tabla

| SP | LOC | Fan-in | Tablas que LEE | Tablas que ESCRIBE |
|----|-----|--------|---------------|-------------------|
| `sp_app_aplicapago` | 5367 | 2 | `bdiauditor:`  ⚠️ext, `bdicheq:`  ⚠️ext, `bdicheq:sc_movdia`  ⚠️ext, `bdinteg:`  ⚠️ext, `bdinteg:si_cliente`  ⚠️ext, `bdinteg:si_estados`  ⚠️ext | `STATISTICS`, `bdisac:`  ⚠️ext, `sac_procesos_jobs`, `temp988_sac_wu_pay` | 🔄
| `sp_bitacoragdf` | 3725 | 0 | `bdicheq:`  ⚠️ext, `bdicheq:sc_maechq`  ⚠️ext, `bdicheq:sc_movdia`  ⚠️ext, `bdicont:co_sdodias`  ⚠️ext, `bdinteg:si_feriado_banca`  ⚠️ext, `bdisac:`  ⚠️ext | `bdisac:`  ⚠️ext, `sac_convenios`, `sac_mensajeerror` |
| `sp_actualizahistoricodetransacciones` | 3417 | 3 | `bdicheq:`  ⚠️ext, `bdicheq:sc_movdia`  ⚠️ext, `bdinteg:`  ⚠️ext, `bdinteg:si_cliente`  ⚠️ext, `bdinteg:si_estados`  ⚠️ext, `bdinteg:si_ptf`  ⚠️ext | `STATISTICS`, `bdisac:`  ⚠️ext, `sac_procesos_jobs`, `temp988_sac_wu_pay` | 🔄
| `sp_app_recordorder` | 2236 | 0 | `TABLE`, `bdicheq:`  ⚠️ext, `bdicheq:sc_maechq`  ⚠️ext, `bdicont:co_sdodias`  ⚠️ext, `bdinteg:`  ⚠️ext, `bdinteg:si_paises_remesadoras`  ⚠️ext | `bdisac:`  ⚠️ext, `sac_mensajeerror`, `tablaTemporal` |
| `sp_aplica_pago_con_cargo_msw` | 2219 | 0 | `bdiauditor:`  ⚠️ext, `bdicheq:`  ⚠️ext, `bdicheq:sc_movdia`  ⚠️ext, `bdicred:sd_movdia`  ⚠️ext, `bdinteg:`  ⚠️ext, `bdisac:`  ⚠️ext | `bdisac:`  ⚠️ext, `sac_app_getorder`, `sac_mensajeerror`, `sac_movimientos_detalle_td` | 🔄
| `sp_altascambioscentral` | 1569 | 0 | `bdicheq:sc_movdia`  ⚠️ext, `bdinteg:si_feriado_banca`  ⚠️ext, `bdisac:`  ⚠️ext, `bdisac:sac_convenios`  ⚠️ext, `bdisac:sac_param`  ⚠️ext | `bdisac:`  ⚠️ext, `sac_convenios` |
| `sp_app_obtieneinfoidentificacion` | 1325 | 152 | `CTECREDITOSOL`, `CTECREDITOSOL2`, `CTECUENTAS`, `CTE_HUELLA`, `TB_CONTEO`, `TB_SAC_ALTACTES_MINUTO_CTEPF` | `TB_SAC_FOLIO_CONFIRMADO_TMP`, `TMP_MINUTOS`, `bdinteg:`  ⚠️ext, `bdisac:`  ⚠️ext |
| `sp_app_aplicapagos_cred` | 1082 | 0 | `TABLE`, `bdicheq:`  ⚠️ext, `bdinteg:`  ⚠️ext, `bdinteg:si_paises_remesadoras`  ⚠️ext, `bdisac:`  ⚠️ext, `bdisac:sac_app_estatusrem`  ⚠️ext | `bdisac:`  ⚠️ext, `tablaTemporal` |
| `sp_app_submitpayreversal` | 884 | 156 | `Bdisac:`  ⚠️ext, `bdicheq:`  ⚠️ext, `bdisac:`  ⚠️ext, `sac_fechas` | `bdisac:`  ⚠️ext, `sac_mensajeerror` |
| `sp_app_queryorder` | 711 | 154 | `bdinteg:`  ⚠️ext, `bdisac:`  ⚠️ext, `sac_param`, `sac_sky_wsgpago` | `bdisac:`  ⚠️ext |
| `sp_aplica_pago_msw` | 524 | 1 | `bdicheq:`  ⚠️ext, `bdinteg:`  ⚠️ext, `sac_movimientoshistorial`, `sac_servicios_cpl` | — | 🔄
| `sp_app_submitpayment` | 379 | 155 | `bdisac:`  ⚠️ext | `bdisac:`  ⚠️ext |
| `sp_app_valdigito` | 307 | 157 | `bdisac:`  ⚠️ext, `bdisac:sac_intrfz_serv`  ⚠️ext, `sac_movimientos`, `sac_movimientoshistorial`, `sac_pagostae` | `bdinteg:`  ⚠️ext |
| `sp_act_ine_bdrem` | 507 | 0 | `CHARINDEX`, `bdinteg:`  ⚠️ext, `bdinteg:si_ctepf`  ⚠️ext, `bdisac:`  ⚠️ext | `bdisac:`  ⚠️ext |
| `sp_actualiza_cte_remesa` | 473 | 0 | `bdinteg:`  ⚠️ext, `bdisac:`  ⚠️ext, `sac_pagostae`, `tmp_movtos_ws_ta` | `bdinteg:`  ⚠️ext, `bdisac:`  ⚠️ext |
| `sp_actualiza_datos` | 465 | 0 | `bdicred:`  ⚠️ext, `bdinteg:`  ⚠️ext, `bdinteg:tmp_correos_unica`  ⚠️ext, `bdisac:`  ⚠️ext, `bdisac:tmp_clientes_unica`  ⚠️ext, `bdisac:tmp_creditos_unica`  ⚠️ext | `bdisac:`  ⚠️ext, `bdiunica` |
| `sp_actualiza_estatus_cardif` | 52 | 0 | `bdisac:`  ⚠️ext, `sac_param` | `bdisac:`  ⚠️ext |
| `sp_actualiza_sac_bts_sdep` | 239 | 0 | `bdicheq:sc_movdia`  ⚠️ext, `bdicheq:sc_movhis`  ⚠️ext, `bdicred:sd_movdia`  ⚠️ext, `bdicred:sd_movhis`  ⚠️ext, `bdisac:`  ⚠️ext, `bdisac:sac_ws_errores`  ⚠️ext | `bdisac:`  ⚠️ext, `sac_app_getorder` |
| `sp_actualizacteremesafh` | 79 | 0 | `TBL_CLIENTES_TMP`, `sac_cte_remesas` | `sac_cte_remesas`, `sac_procesos_jobs` |
| `sp_actualizafechassac` | 702 | 0 | `bdicheq:`  ⚠️ext, `bdinteg:si_feriado`  ⚠️ext, `bdisac:`  ⚠️ext, `bdisac:sac_fechas`  ⚠️ext, `bdisac:sac_movimientos`  ⚠️ext, `bdisac:sac_movimientos_detalle_td`  ⚠️ext | `STATISTICS`, `bdisac:sac_fechas`  ⚠️ext, `bdisac:sac_movimientos`  ⚠️ext, `bdisac:sac_movimientos_detalle_td`  ⚠️ext | 🔄
| `sp_actualizaregsuc` | 418 | 0 | `BDISAC:sac_convenios`  ⚠️ext, `bdinteg:si_estados`  ⚠️ext, `bdinteg:si_feriado`  ⚠️ext, `bdisac:sac_convenios`  ⚠️ext, `bdisac:sac_fechas`  ⚠️ext, `bdisac:sac_tiporeferencia`  ⚠️ext | `sac_actualizacionsucursales`, `sac_controlarchivoscobranza`, `sac_convenios` | 🔄
| `sp_actualizaremesa` | 784 | 0 | `bdicheq:`  ⚠️ext, `bdicred:`  ⚠️ext, `bdicred:sd_maecred`  ⚠️ext, `bdicred:sd_maecredcrd`  ⚠️ext, `bdinteg:si_cliente`  ⚠️ext, `bdinteg:si_ctepf`  ⚠️ext | `STATISTICS`, `sac_bts_qryi`, `sac_remesas_adic`, `sac_remesas_estadistica` |
| `sp_actualizasac_bts_payc` | 107 | 0 | — | `sac_procesos_jobs` |
| `sp_actualizasac_bts_payi` | 109 | 0 | — | `sac_procesos_jobs` |
| `sp_actualizasac_bts_qryi` | 145 | 0 | `temp988_sac_bts_remesas` | `sac_bts_qryi_old`, `sac_procesos_jobs` |
| `sp_actualizasac_bts_sdep` | 119 | 0 | — | `sac_procesos_jobs` |
| `sp_actualizasac_wu_pay` | 115 | 0 | — | `sac_procesos_jobs` |
| `sp_actualizasac_wu_search` | 115 | 0 | — | `sac_procesos_jobs` |
| `sp_actualizastatusconvenio` | 385 | 0 | `BDISAC:sac_convenios`  ⚠️ext, `bdinteg:si_estados`  ⚠️ext, `bdinteg:si_feriado`  ⚠️ext, `bdisac:sac_convenios`  ⚠️ext, `bdisac:sac_fechas`  ⚠️ext, `bdisac:sac_tiporeferencia`  ⚠️ext | `sac_controlarchivoscobranza`, `sac_convenios` | 🔄
| `sp_actualizastatusconvenio_pba` | 153 | 0 | `BDISAC:sac_convenios`  ⚠️ext, `bdisac:sac_fechas`  ⚠️ext | `sac_controlarchivoscobranza`, `sac_convenios` | 🔄
| `sp_alta_cardif` | 127 | 0 | `bdisac:`  ⚠️ext, `iIniContra`, `iInicio` | `bdisac:`  ⚠️ext |
| `sp_altascambioscentral_pba` | 253 | 0 | `BDISAC:sac_convenios`  ⚠️ext, `bdisac:sac_convenios`  ⚠️ext, `bdisac:sac_fechas`  ⚠️ext, `sac_convenios` | `sac_controlarchivoscobranza`, `sac_convenios` | 🔄
| `sp_app_confirmorder` | 1455 | 0 | `BdiCheq:Sc_Bines`  ⚠️ext, `BdiCheq:Sc_Fechas`  ⚠️ext, `BdiCheq:Sc_MovDia`  ⚠️ext, `BdiCheq:Sc_MovHis`  ⚠️ext, `BdiCheq:Sc_Movhis`  ⚠️ext, `BdiSac:Sac_EGlobal_Archivos`  ⚠️ext | `BdiSac:Sac_EGlobal_Archivos`  ⚠️ext, `BdiSac:Sac_EGlobal_Detalle`  ⚠️ext, `BdiSac:Sac_EGlobal_Encabezado`  ⚠️ext, `BdiSac:Sac_EGlobal_NoConcil`  ⚠️ext |
| `sp_app_confirmpayment` | 305 | 0 | `bdisac:`  ⚠️ext | `bdisac:`  ⚠️ext |
| `sp_app_consrevrem` | 183 | 0 | `bdisac:`  ⚠️ext, `bdisac:sac_fechas`  ⚠️ext | `bdisac:sac_monitor`  ⚠️ext |
| `sp_app_consrevrem_web` | 639 | 0 | `bdisac:`  ⚠️ext, `sac_param` | `bdisac:`  ⚠️ext |
| `sp_app_getorder` | 1659 | 0 | `BdiCheq:Sc_Bines`  ⚠️ext, `BdiCheq:Sc_Fechas`  ⚠️ext, `BdiCheq:Sc_MovDia`  ⚠️ext, `BdiCheq:Sc_MovHis`  ⚠️ext, `BdiCheq:Sc_Movhis`  ⚠️ext, `BdiSac:Sac_EGlobal_Archivos`  ⚠️ext | `BdiSac:Sac_EGlobal_Archivos`  ⚠️ext, `BdiSac:Sac_EGlobal_Detalle`  ⚠️ext, `BdiSac:Sac_EGlobal_Encabezado`  ⚠️ext, `BdiSac:Sac_EGlobal_NoConcil`  ⚠️ext |
| `sp_app_getorderstoreprocess` | 114 | 0 | `bdisac:`  ⚠️ext | `bdisac:`  ⚠️ext |
| `sp_app_mensajes` | 1244 | 0 | `Bdisac:`  ⚠️ext, `bdicheq:`  ⚠️ext, `bdisac:`  ⚠️ext, `sac_fechas` | `bdisac:`  ⚠️ext, `sac_mensajeerror` |
| `sp_app_paymentrejection` | 525 | 0 | `bdisac:`  ⚠️ext | `bdisac:`  ⚠️ext |
| `sp_app_queryorder_prue` | 281 | 0 | `bdinteg:`  ⚠️ext | `bdisac:`  ⚠️ext |
| `sp_app_recuperapayment` | 1344 | 0 | `bdiauditor:`  ⚠️ext, `bdicheq:sc_movdia`  ⚠️ext, `bdicred:sd_movdia`  ⚠️ext, `bdinteg:`  ⚠️ext, `bdisac:`  ⚠️ext, `bdisac:sac_convenios`  ⚠️ext | `bdisac:`  ⚠️ext, `sac_app_getorder`, `sac_mensajeerror` |
| `sp_app_submitpayment_web` | 548 | 0 | `bdinteg:`  ⚠️ext, `bdisac:`  ⚠️ext | `bdisac:`  ⚠️ext |
| `sp_app_valmonto` | 562 | 0 | `bdiauditor:`  ⚠️ext, `bdinteg:`  ⚠️ext, `bdisac:`  ⚠️ext, `sac_remesas_estadistica` | `bdisac:`  ⚠️ext |
| `sp_app_valmonto_aut` | 250 | 0 | `bdiauditor:`  ⚠️ext, `bdicheq:`  ⚠️ext, `bdinteg:`  ⚠️ext, `bdisac:`  ⚠️ext, `sac_remesas_estadistica` | `bdisac:`  ⚠️ext |
| `sp_app_valmonto_cpl` | 10833 | 0 | `TABLE`, `bdiauditor:`  ⚠️ext, `bdicheq:`  ⚠️ext, `bdicheq:sc_movdia`  ⚠️ext, `bdicheq:sc_movhis`  ⚠️ext, `bdinteg:`  ⚠️ext | `bdisac:`  ⚠️ext, `bdisac:sac_movimientoshistorial`  ⚠️ext, `bdisac:sac_totalmovimientosdetallehistorial`  ⚠️ext, `bdisac:tmpSac_MovimientosDetalleHistorial`  ⚠️ext | 🔄
| `sp_asignaanio` | 2833 | 0 | `BDISAC:`  ⚠️ext, `TABLE`, `bdiauditor:`  ⚠️ext, `bdicheq:sc_movhis`  ⚠️ext, `bdicheq:sc_movhis_old`  ⚠️ext, `bdicheq:sc_param`  ⚠️ext | `bdisac:`  ⚠️ext, `sac_remesas_estadistica` | 🔄
| `sp_asignaaniopredial` | 2769 | 0 | `BDISAC:`  ⚠️ext, `TABLE`, `bdiauditor:`  ⚠️ext, `bdicheq:sc_movhis`  ⚠️ext, `bdicheq:sc_movhis_old`  ⚠️ext, `bdicheq:sc_param`  ⚠️ext | `bdisac:`  ⚠️ext, `sac_remesas_estadistica` | 🔄
| `sp_asignabimestre` | 980 | 0 | `bdinteg:si_feriado_banca`  ⚠️ext, `bdisac:`  ⚠️ext | `bdisac:`  ⚠️ext |
| `sp_asignacuenta_edomex` | 2487 | 0 | `TABLE`, `bdicheq:`  ⚠️ext, `bdicheq:sc_movdia`  ⚠️ext, `bdicheq:sc_movhis`  ⚠️ext, `bdicred:`  ⚠️ext, `bdinteg:`  ⚠️ext | `bdisac:`  ⚠️ext, `bdisac:sac_movimientoshistorial`  ⚠️ext, `bdisac:sac_procesos`  ⚠️ext |

## Tablas compartidas (múltiples escritores) — riesgo de contención en parallel-run

- **`bdisac:`**: escrita por `sp_alta_cardif`, `sp_app_recuperapayment`, `sp_actualiza_cte_remesa`, `sp_bitacoragdf`, `sp_app_valmonto_aut` ... y 33 más
- **`sac_procesos_jobs`**: escrita por `sp_actualizasac_bts_payi`, `sp_actualizasac_bts_payc`, `sp_actualizasac_bts_qryi`, `sp_actualizacteremesafh`, `sp_actualizasac_wu_pay` ... y 4 más
- **`STATISTICS`**: escrita por `sp_benefremesas_bts`, `sp_actualizafechassac`, `sp_benefremesas_wu`, `sp_app_aplicapago`, `sp_actualizahistoricodetransacciones` ... y 1 más
- **`sac_convenios`**: escrita por `sp_altascambioscentral_pba`, `sp_bitacoragdf`, `sp_actualizastatusconvenio`, `sp_actualizaregsuc`, `sp_altascambioscentral` ... y 1 más
- **`sac_mensajeerror`**: escrita por `sp_app_recuperapayment`, `sp_bitacoragdf`, `sp_aplica_pago_con_cargo_msw`, `sp_app_mensajes`, `sp_app_submitpayreversal` ... y 1 más

## Tablas candidatas a CDC prioritario (Debezium / AWS DMS)

| Tabla | SPs escritores | Prioridad CDC |
|-------|---------------|---------------|
| `sac_procesos_jobs` | `sp_actualizasac_bts_payi`, `sp_actualizasac_bts_payc`, `sp_actualizasac_bts_qryi` | 🔴 PRIMERA |
| `STATISTICS` | `sp_benefremesas_bts`, `sp_actualizafechassac`, `sp_benefremesas_wu` | 🔴 PRIMERA |
| `sac_convenios` | `sp_altascambioscentral_pba`, `sp_bitacoragdf`, `sp_actualizastatusconvenio` | 🔴 PRIMERA |
| `sac_mensajeerror` | `sp_app_recuperapayment`, `sp_bitacoragdf`, `sp_aplica_pago_con_cargo_msw` | 🔴 PRIMERA |
| `sac_controlarchivoscobranza` | `sp_altascambioscentral_pba`, `sp_actualizastatusconvenio`, `sp_actualizaregsuc` | 🔴 PRIMERA |
| `sac_app_getorder` | `sp_aplica_pago_con_cargo_msw`, `sp_app_recuperapayment`, `sp_actualiza_sac_bts_sdep` | 🟠 SEGUNDA |
| `sac_remesas_estadistica` | `sp_asignaanio`, `sp_asignaaniopredial`, `sp_actualizaremesa` | 🟠 SEGUNDA |
| `temp_reporteenrolamiento58` | `sp_app_aplicapago`, `sp_actualizahistoricodetransacciones` | 🟡 TERCERA |

## Tablas externas accedidas (cross-DB)

- `BDISAC:` (R) — desde `sp_asignaanio`, `sp_asignaaniopredial`
- `BDISAC:sac_convenios` (R) — desde `sp_actualizastatusconvenio`, `sp_altascambioscentral_pba`, `sp_actualizaregsuc`
- `BdiCheq:Sc_Bines` (R) — desde `sp_app_getorder`, `sp_app_confirmorder`
- `BdiCheq:Sc_Fechas` (R) — desde `sp_app_getorder`, `sp_app_confirmorder`
- `BdiCheq:Sc_MovDia` (R) — desde `sp_app_getorder`, `sp_app_confirmorder`
- `BdiCheq:Sc_MovHis` (R) — desde `sp_app_getorder`, `sp_app_confirmorder`
- `BdiCheq:Sc_Movhis` (R) — desde `sp_app_getorder`, `sp_app_confirmorder`
- `BdiSac:Sac_EGlobal_Archivos` (R+W) — desde `sp_app_getorder`, `sp_app_confirmorder`
- `BdiSac:Sac_EGlobal_Banco` (R) — desde `sp_app_getorder`, `sp_app_confirmorder`
- `BdiSac:Sac_EGlobal_Detalle` (R+W) — desde `sp_app_getorder`, `sp_app_confirmorder`
- `BdiSac:Sac_EGlobal_Encabezado` (R+W) — desde `sp_app_getorder`, `sp_app_confirmorder`
- `BdiSac:Sac_EGlobal_Mensajes_Error` (R) — desde `sp_app_getorder`, `sp_app_confirmorder`
- `BdiSac:Sac_EGlobal_NoConcil` (R+W) — desde `sp_app_getorder`, `sp_app_confirmorder`
- `BdiSac:Sac_EGlobal_Sumario` (R+W) — desde `sp_app_getorder`, `sp_app_confirmorder`
- `BdiSac:Sac_Param` (R) — desde `sp_app_getorder`, `sp_app_confirmorder`
- `Bdisac:` (R) — desde `sp_app_mensajes`, `sp_app_submitpayreversal`
- `bdiauditor:` (R) — desde `sp_app_recuperapayment`, `sp_asignaanio`, `sp_app_valmonto_aut`
- `bdicheq:` (R) — desde `sp_actualizafechassac`, `sp_asignacuenta_edomex`, `sp_bitacoragdf`
- `bdicheq:sc_contab` (R+W) — desde `extrae_cont`
- `bdicheq:sc_maechq` (R) — desde `sp_app_recordorder`, `sp_bitacoragdf`
- `bdicheq:sc_maenoc` (R) — desde `sp_app_obtieneinfoidentificacion`
- `bdicheq:sc_movdia` (R) — desde `sp_app_recuperapayment`, `sp_asignacuenta_edomex`, `sp_bitacoragdf`
- `bdicheq:sc_movhis` (R) — desde `sp_app_valmonto_cpl`, `sp_asignacuenta_edomex`, `sp_actualiza_sac_bts_sdep`
- `bdicheq:sc_movhis_old` (R) — desde `sp_app_obtieneinfoidentificacion`, `sp_asignaanio`, `sp_asignaaniopredial`
- `bdicheq:sc_param` (R) — desde `sp_asignaanio`, `sp_asignaaniopredial`
- `bdicont:co_sdodias` (R) — desde `sp_app_recordorder`, `sp_bitacoragdf`
- `bdicred:` (R) — desde `sp_asignacuenta_edomex`, `sp_actualiza_datos`, `sp_actualizaremesa`
- `bdicred:sd_maecred` (R) — desde `sp_actualizaremesa`
- `bdicred:sd_maecredcrd` (R) — desde `sp_actualizaremesa`
- `bdicred:sd_movdia` (R) — desde `sp_app_recuperapayment`, `sp_aplica_pago_con_cargo_msw`, `sp_actualiza_sac_bts_sdep`
- `bdicred:sd_movhis` (R) — desde `sp_asignaanio`, `sp_actualiza_sac_bts_sdep`, `sp_asignaaniopredial`
- `bdinteg:` (R+W) — desde `sp_app_recuperapayment`, `sp_actualiza_cte_remesa`, `sp_act_ine_bdrem`
- `bdinteg:si_catalog` (R) — desde `extrae_cont`
- `bdinteg:si_cliente` (R) — desde `sp_actualizaremesa`, `sp_asignaaniopredial`, `sp_asignaanio`
- `bdinteg:si_cte_huella` (R) — desde `sp_app_obtieneinfoidentificacion`, `sp_asignaanio`, `sp_asignaaniopredial`
- `bdinteg:si_ctepf` (R) — desde `sp_asignaaniopredial`, `sp_asignaanio`, `sp_act_ine_bdrem`
- `bdinteg:si_direcciones_actual` (R) — desde `sp_asignaanio`, `sp_asignaaniopredial`
- `bdinteg:si_estados` (R) — desde `sp_actualizastatusconvenio`, `sp_app_aplicapago`, `sp_actualizaregsuc`
- `bdinteg:si_feriado` (R) — desde `sp_actualizastatusconvenio`, `sp_actualizafechassac`, `sp_actualizaregsuc`
- `bdisac:` (R+W) — desde `sp_actualizafechassac`, `sp_actualiza_cte_remesa`, `sp_bitacoragdf`
- `bdisac:sac_Procesos` (R) — desde `sp_asignacuenta_edomex`, `sac_bts_movspaso`
- `bdisac:sac_app_catestados` (R) — desde `sp_asignaanio`, `sp_asignaaniopredial`
- `bdisac:sac_app_estatusrem` (R) — desde `sp_app_recordorder`, `sp_app_aplicapagos_cred`
- `bdisac:sac_app_nacionalidad` (R) — desde `sp_asignaanio`, `sp_asignaaniopredial`
- `bdisac:sac_app_qryi` (R) — desde `sp_app_recordorder`, `sp_app_aplicapagos_cred`
- `bdisac:sac_bts_catstatusremesas` (R) — desde `sp_app_recordorder`, `sp_app_aplicapagos_cred`
- `bdisac:sac_bts_qryi` (R) — desde `sp_app_recordorder`, `sp_app_aplicapagos_cred`
- `bdisitesp:` (R) — desde `sp_app_valmonto_cpl`, `sp_asignaanio`, `sp_asignaaniopredial`
- `bdisolic:ss_solicitudes` (R) — desde `sp_app_obtieneinfoidentificacion`
- `sysmaster:` (R) — desde `sp_actualiza_datos`

---
*Generado por: Specialist — Informix SPL Analysis · 2026-07-03 · Evidencia: source/LegacyCore/informix/bdisac_*.sql (análisis estático de 58 archivos SQL) · análisis estático de cláusulas FROM/INSERT/UPDATE/DELETE*

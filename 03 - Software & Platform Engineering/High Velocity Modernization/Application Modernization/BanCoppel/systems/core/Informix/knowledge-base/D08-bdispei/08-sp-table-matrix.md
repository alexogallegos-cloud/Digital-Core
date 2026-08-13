# D08 · SPEI — Matriz SP × Tabla (READ / WRITE)

> **Componente:** Informix · SPE-AM-001 · Etapa 1
> **Base de datos:** `bdispei` · IBM Informix IDS 14.10 / POWER-AIX
> **Wave:** Wave 2 · Riesgo: **CRÍTICO**
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

## Resumen de tablas propias de `bdispei`

| Tabla | Tipo | Lectores | Escritores | Ownership |
|-------|------|----------|-----------|-----------|
| `tblpago` | Transaccional | 20 | 10 | 🔴 10 SPs escriben |
| `tblparametros` | Transaccional | 19 | 2 | 🟠 2 SPs escriben |
| `tblhistpago` | Transaccional | 10 | 2 | 🟠 2 SPs escriben |
| `tblParametros` | Transaccional | 11 | 0 | 🟢 Solo lectura |
| `tblcausadev` | Transaccional | 11 | 0 | 🟢 Solo lectura |
| `tblbanco` | Transaccional | 9 | 2 | 🟠 2 SPs escriben |
| `tbl_registro_msj` | Transaccional | 4 | 4 | 🟠 4 SPs escriben |
| `tbldetranpago` | Transaccional | 8 | 0 | 🟢 Solo lectura |
| `tblPago` | Transaccional | 1 | 5 | 🟠 5 SPs escriben |
| `tblhistdetranpago` | Transaccional | 6 | 0 | 🟢 Solo lectura |
| `STATISTICS` | Transaccional | 0 | 5 | 🟠 5 SPs escriben |
| `tblPaqueteEnv` | Transaccional | 3 | 2 | 🟠 2 SPs escriben |
| `tbl_encabezado_coas_rec` | Transaccional | 2 | 2 | 🟠 2 SPs escriben |
| `tbl_coas_rec_abono7` | Transaccional | 2 | 2 | 🟠 2 SPs escriben |
| `tbl_coas_rec_devols16` | Transaccional | 2 | 2 | 🟠 2 SPs escriben |
| `tblpagocred` | Transaccional | 1 | 3 | 🟠 3 SPs escriben |
| `tbl_coas_rec_devol16` | Transaccional | 2 | 2 | 🟠 2 SPs escriben |
| `tbl_coas_rec` | Transaccional | 2 | 2 | 🟠 2 SPs escriben |
| `tbl_coas_rec_abonos5` | Transaccional | 2 | 2 | 🟠 2 SPs escriben |
| `abonospeihist` | Transaccional | 2 | 2 | 🟠 2 SPs escriben |

> **[SME-PENDING]** Confirmar nombre exacto en producción, volumen de registros, política de retención y campos PII con DBA BanCoppel.

## Matriz completa SP × Tabla

| SP | LOC | Fan-in | Tablas que LEE | Tablas que ESCRIBE |
|----|-----|--------|---------------|-------------------|
| `sp_calc_comasiva` | 804 | 0 | `bdiadminnomina:`  ⚠️ext, `bdicheq:`  ⚠️ext, `bdicheq:sc_ctabloqueo`  ⚠️ext, `bdicheq:sc_cuenta_telefono`  ⚠️ext, `bdinteg:`  ⚠️ext, `bdispei:tblcomision_no_comision`  ⚠️ext | `tblhistabono` |
| `sp_calc_comasiva_web` | 476 | 0 | `bdiadminnomina:`  ⚠️ext, `bdicheq:`  ⚠️ext, `bdicheq:sc_ctabloqueo`  ⚠️ext, `bdicheq:sc_cuenta_telefono`  ⚠️ext, `bdinteg:`  ⚠️ext, `bdispei:tblcomision_no_comision`  ⚠️ext | `tblhistabono` |
| `sp_abonoordpago` | 444 | 1 | `bdicheq:sc_ctabloqueo`  ⚠️ext, `bdicheq:sc_maechq`  ⚠️ext, `bdinteg:dual`  ⚠️ext, `bdinteg:si_empresas`  ⚠️ext, `tblCtaBansi`, `tblParametros` | `tblPago`, `tblpago` | 🔄
| `sp_abonocanelapago` | 246 | 0 | `bdicheq:sc_maechq`  ⚠️ext, `bdicheq:sc_tarjeta`  ⚠️ext, `bdinteg:dual`  ⚠️ext, `bdinteg:si_empresas`  ⚠️ext, `tblParametros`, `tblcausadev` | `tblPago` |
| `sp_gen_msj` | 156 | 0 | `bdispei:tbl_registro_msj`  ⚠️ext | `bdispei:tbl_registro_msj`  ⚠️ext |
| `sp_confpagospei` | 139 | 0 | `tblcomision`, `tblpago`, `tblparametros`, `tbltipopago` | `tblpago` |
| `callsyn_procsign` | 8 | 0 | — | — |
| `cancelacion` | 71 | 0 | `tblpago`, `tblparametros` | `tblpago` |
| `con_canc_audi` | 101 | 0 | `bdinteg:si_cliente`  ⚠️ext, `bdispei:tblpago`  ⚠️ext | — |
| `consulta_bancos` | 138 | 0 | `bdispeua:bancos`  ⚠️ext, `paginterban:bancos`  ⚠️ext, `tblparametros` | — |
| `fn_datediffextemporanea` | 32 | 0 | — | — |
| `fn_datediffminute` | 44 | 0 | — | — |
| `fn_datediffsecond` | 44 | 0 | — | — |
| `getnextpk` | 11 | 0 | `CTRLTABLAS` | `CTRLTABLAS` |
| `graba_spei` | 127 | 0 | `bdinteg:si_fechas`  ⚠️ext, `terceros:convenio_mn`  ⚠️ext | `tblpago` | 🔄
| `pba_cancelacion` | 81 | 0 | — | — |
| `reversion` | 105 | 0 | `tblpago`, `tblparametros` | `tblpago` |
| `sp_abonoordauto` | 48 | 0 | — | — | 🔄
| `sp_actbancont` | 348 | 0 | `bdicheq:sc_fechas`  ⚠️ext, `tbl_registro_msj` | `tbl_registro_msj`, `tblbitalertaspei`, `tblparametros` |
| `sp_actenviopago` | 39 | 0 | `tblPaqueteEnv`, `tblParametros` | `tblPago` |
| `sp_actestenvspei` | 41 | 0 | `bdicheq:sc_movdia`  ⚠️ext, `tblparametros` | `tblpago` |
| `sp_actfolacustrasp` | 34 | 0 | `tblParametros`, `tblTraspaso` | `tblTraspaso` |
| `sp_actfolioacuse` | 39 | 0 | `tblPaqueteEnv`, `tblParametros` | `tblPago`, `tblPaqueteEnv` |
| `sp_acthorarios` | 34 | 0 | — | `bdispei:`  ⚠️ext |
| `sp_actualiza_credspei` | 77 | 0 | — | `tblpagocred` |
| `sp_actualiza_msjs_spei` | 110 | 0 | `bdicheq:sc_fechas`  ⚠️ext, `tbl_registro_msj` | `tbl_registro_msj` |
| `sp_alertacargospei` | 124 | 0 | `bdicheq:sc_fechas`  ⚠️ext, `bdicheq:sc_movdia`  ⚠️ext, `bdicheq:sc_movhis`  ⚠️ext | `STATISTICS` |
| `sp_alertacargospei_exp1` | 142 | 0 | `bdicheq:sc_fechas`  ⚠️ext, `bdicheq:sc_movdia`  ⚠️ext, `bdicheq:sc_movhis`  ⚠️ext, `sysmaster:systabnames`  ⚠️ext | `STATISTICS` |
| `sp_alertacargospei_pba` | 122 | 0 | `bdicheq:sc_fechas`  ⚠️ext, `bdicheq:sc_movdia`  ⚠️ext, `bdicheq:sc_movhis`  ⚠️ext | `STATISTICS` |
| `sp_alertas_codi` | 85 | 0 | `sc_movdia` | — |
| `sp_alertasabonospei` | 124 | 0 | `abonospei`, `abonospeihist`, `bdicheq:sc_fechas`  ⚠️ext, `bdicheq:sc_movdia`  ⚠️ext, `bdicheq:sc_movhis`  ⚠️ext | `STATISTICS`, `abonospei`, `abonospeihist` |
| `sp_alertasabonosspei` | 124 | 0 | `abonospeihist`, `abonosspei`, `bdicheq:sc_fechas`  ⚠️ext, `bdicheq:sc_movdia`  ⚠️ext, `bdicheq:sc_movhis`  ⚠️ext | `STATISTICS`, `abonospei`, `abonospeihist` |
| `sp_altactaspei` | 313 | 0 | `bdicheq:sc_cuenta_telefono`  ⚠️ext, `bdicheq:sc_maechq`  ⚠️ext, `bdinteg:si_bancos`  ⚠️ext, `bdispei:tblclabebloqueo`  ⚠️ext, `tblbanco`, `tblcausadev` | `bdispei:tblclabebloqueo`  ⚠️ext |
| `sp_bajactaspei` | 265 | 0 | `bdicheq:sc_cuenta_telefono`  ⚠️ext, `bdicheq:sc_maechq`  ⚠️ext, `bdispei:tblclabebloqueo`  ⚠️ext, `tblbanco`, `tblcausadev`, `tbldetranpago` | `bdispei:tblclabebloqueo`  ⚠️ext |
| `sp_borra_operaciones` | 70 | 0 | `tblhistpago` | `tblhistpago` |
| `sp_calc_com` | 53 | 0 | `bdinteg:si_sucursales`  ⚠️ext, `tblcomision` | — |
| `sp_calcula_comision_spei` | 25 | 0 | `informix` | — |
| `sp_cambio_fecha` | 283 | 0 | `bdicheq:sc_fechas`  ⚠️ext, `bdispei:tblctrlproceso`  ⚠️ext, `sysmaster:systabnames`  ⚠️ext, `tblctrlproceso`, `tblhistpagoactuali_temp` | `bdispei:spei_mov_det_re_proceso`  ⚠️ext, `bdispei:tblparametros`  ⚠️ext, `tblctrlproceso`, `tblhistpago` |
| `sp_cancelaenvio` | 52 | 0 | `tblpago`, `tblparametros` | `tblpago` |
| `sp_cargo_val` | 137 | 0 | `bdinteg:si_transacc`  ⚠️ext, `sc_fechas`, `sc_maechq`, `sc_movdia` | `sc_cuentas_retiro` |
| `sp_coas_envio` | 212 | 0 | `bdicheq:sc_fechas`  ⚠️ext, `bdicheq:sc_movdia`  ⚠️ext, `bdispei:tbldetalle`  ⚠️ext, `bdispei:tblfoliocoasenv`  ⚠️ext, `bdispei:tblpago`  ⚠️ext, `bdispei:tblparametros`  ⚠️ext | `bdispei:tbldetalle`  ⚠️ext, `bdispei:tblfoliocoasenv`  ⚠️ext, `bdispei:tblpago`  ⚠️ext |
| `sp_coas_envio_exp1` | 212 | 0 | `bdicheq:sc_fechas`  ⚠️ext, `bdicheq:sc_movdia`  ⚠️ext, `bdispei:tbldetalle`  ⚠️ext, `bdispei:tblfoliocoasenv`  ⚠️ext, `bdispei:tblpago`  ⚠️ext, `bdispei:tblparametros`  ⚠️ext | `bdispei:tbldetalle`  ⚠️ext, `bdispei:tblfoliocoasenv`  ⚠️ext, `bdispei:tblpago`  ⚠️ext |
| `sp_coas_recibidos` | 589 | 0 | `sysmaster:systabnames`  ⚠️ext, `tbl_coas_rec`, `tbl_coas_rec_abono`, `tbl_coas_rec_abono5`, `tbl_coas_rec_abono7`, `tbl_coas_rec_abonos` | `tbl_coas_rec`, `tbl_coas_rec_abono`, `tbl_coas_rec_abono5`, `tbl_coas_rec_abono7` |
| `sp_coas_recibidos_exp1` | 589 | 0 | `sysmaster:systabnames`  ⚠️ext, `tbl_coas_rec`, `tbl_coas_rec_abono`, `tbl_coas_rec_abono5`, `tbl_coas_rec_abono7`, `tbl_coas_rec_abonos` | `tbl_coas_rec`, `tbl_coas_rec_abono`, `tbl_coas_rec_abono5`, `tbl_coas_rec_abono7` |
| `sp_con_relordpago` | 551 | 0 | `tblbanco`, `tblhistpago`, `tblpago`, `tbltipopago` | — |
| `sp_confenviopaq` | 37 | 0 | `tblParametros` | `tblPaqueteEnv`, `tblpago` |
| `sp_cons_comision_ob` | 43 | 0 | `bdispei:`  ⚠️ext | — |
| `sp_cons_ult_pago` | 76 | 0 | `bdispei:tblpago`  ⚠️ext | — |
| `sp_consbancont` | 275 | 0 | `bdicheq:sc_fechas`  ⚠️ext, `tbl_registro_msj` | `tbl_registro_msj` |
| `sp_consbancos` | 52 | 0 | `tblbanco`, `tblparametros` | — |

## Tablas compartidas (múltiples escritores) — riesgo de contención en parallel-run

- **`tblpago`**: escrita por `sp_cancelaenvio`, `graba_spei`, `reversion`, `sp_confenviopaq`, `sp_actestenvspei` ... y 5 más
- **`tblPago`**: escrita por `sp_abonocanelapago`, `sp_actfolioacuse`, `sp_actenviopago`, `sp_generadevpago`, `sp_abonoordpago`
- **`STATISTICS`**: escrita por `sp_alertacargospei_pba`, `sp_alertacargospei`, `sp_alertasabonospei`, `sp_alertasabonosspei`, `sp_alertacargospei_exp1`
- **`tbl_registro_msj`**: escrita por `sp_consbancont`, `sp_actualiza_msjs_spei`, `sp_depura_tbl_registro_msj`, `sp_actbancont`
- **`tblpagocred`**: escrita por `sp_inserta_credspei`, `sp_actualiza_credspei`, `sp_consulta_credspei`

## Tablas candidatas a CDC prioritario (Debezium / AWS DMS)

| Tabla | SPs escritores | Prioridad CDC |
|-------|---------------|---------------|
| `tblpago` | `sp_cancelaenvio`, `graba_spei`, `reversion` | 🔴 PRIMERA |
| `tblPago` | `sp_abonocanelapago`, `sp_actfolioacuse`, `sp_actenviopago` | 🔴 PRIMERA |
| `STATISTICS` | `sp_alertacargospei_pba`, `sp_alertacargospei`, `sp_alertasabonospei` | 🔴 PRIMERA |
| `tbl_registro_msj` | `sp_consbancont`, `sp_actualiza_msjs_spei`, `sp_depura_tbl_registro_msj` | 🟠 SEGUNDA |
| `tblpagocred` | `sp_inserta_credspei`, `sp_actualiza_credspei`, `sp_consulta_credspei` | 🟠 SEGUNDA |
| `tblparametros` | `sp_inicializa`, `sp_actbancont` | 🟡 TERCERA |
| `tblPaqueteEnv` | `sp_confenviopaq`, `sp_actfolioacuse` | 🟡 TERCERA |
| `abonospei` | `sp_alertasabonospei`, `sp_alertasabonosspei` | 🟡 TERCERA |

## Tablas externas accedidas (cross-DB)

- `bdiSPEI:tblPago` (R+W) — desde `sp_generadevpago`
- `bdiadminnomina:` (R) — desde `sp_calc_comasiva`, `sp_calc_comasiva_web`
- `bdicheq:` (R) — desde `sp_calc_comasiva`, `sp_calc_comasiva_web`
- `bdicheq:sc_ctabloqueo` (R) — desde `sp_abonoordpago`, `sp_calc_comasiva_web`, `sp_calc_comasiva`
- `bdicheq:sc_cuenta_telefono` (R) — desde `sp_consctecte_web`, `sp_consctectehist_exp1`, `sp_altactaspei`
- `bdicheq:sc_fechas` (R) — desde `sp_consbancont`, `sp_alertacargospei_pba`, `sp_actbancont`
- `bdicheq:sc_maechq` (R) — desde `sp_abonocanelapago`, `sp_consctecte_web`, `sp_consctectehist_exp1`
- `bdicheq:sc_maechq_temp` (R) — desde `sp_consctecte_exp1`, `sp_consctecte_web`, `sp_consctecte`
- `bdicheq:sc_maechq_temp2` (R) — desde `sp_consctecte_exp1`, `sp_consctecte_web`, `sp_consctecte`
- `bdicheq:sc_movdia` (R) — desde `sp_alertacargospei_pba`, `sp_alertacargospei`, `sp_alertasabonospei`
- `bdinteg:` (R) — desde `sp_calc_comasiva`, `sp_calc_comasiva_web`
- `bdinteg:dual` (R) — desde `sp_abonocanelapago`, `sp_abonoordpago`
- `bdinteg:si_bancos` (R) — desde `sp_altactaspei`
- `bdinteg:si_cliente` (R) — desde `con_canc_audi`
- `bdinteg:si_empresas` (R) — desde `sp_abonocanelapago`, `sp_abonoordpago`
- `bdinteg:si_fechas` (R) — desde `graba_spei`
- `bdinteg:si_feriado` (R) — desde `sp_consultamovspei`
- `bdinteg:si_prodtran` (R) — desde `sp_generaconta`
- `bdispei:` (R+W) — desde `sp_cons_comision_ob`, `sp_consultamovspei`, `sp_acthorarios`
- `bdispei:spei_mov_det_re_proceso` (R+W) — desde `sp_cambio_fecha`
- `bdispei:tbl_registro_msj` (R+W) — desde `sp_gen_msj`
- `bdispei:tblbanco` (R) — desde `sp_extraeinfospeua`
- `bdispei:tblclabebloqueo` (R+W) — desde `sp_altactaspei`, `sp_bajactaspei`
- `bdispei:tblcomision_no_comision` (R) — desde `sp_calc_comasiva`, `sp_calc_comasiva_web`
- `bdispei:tblctabansi` (R) — desde `sp_generaconta`, `sp_extraeinfospeua`
- `bdispei:tblctrlproceso` (R) — desde `sp_genera_reportes_spei`, `sp_cambio_fecha`
- `bdispeua:bancos` (R) — desde `consulta_bancos`
- `paginterban:bancos` (R) — desde `consulta_bancos`
- `sysmaster:systabnames` (R) — desde `sp_coas_envio`, `sp_coas_recibidos_exp1`, `sp_coas_recibidos`
- `terceros:convenio_mn` (R) — desde `graba_spei`

---
*Generado por: Specialist — Informix SPL Analysis · 2026-07-03 · Evidencia: source/informix/bdispei_*.sql (análisis estático de 70 archivos SQL) · análisis estático de cláusulas FROM/INSERT/UPDATE/DELETE*

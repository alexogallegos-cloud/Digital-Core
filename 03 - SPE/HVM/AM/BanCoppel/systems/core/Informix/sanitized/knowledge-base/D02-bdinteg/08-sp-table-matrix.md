# D02 · Integración y Autenticación — Matriz SP × Tabla (READ / WRITE)

> **Componente:** LegacyCore · SPE-AM-001 · Etapa 1
> **Base de datos:** `bdinteg` · IBM Informix IDS 14.10 / POWER-AIX
> **Wave:** Wave 5 · Riesgo: **CRÍTICO**
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

## Resumen de tablas propias de `bdinteg`

| Tabla | Tipo | Lectores | Escritores | Ownership |
|-------|------|----------|-----------|-----------|
| `si_cliente` | Transaccional | 11 | 1 | 🟠 1 SPs escriben |
| `si_param` | Catálogo / Config | 6 | 3 | 🟠 3 SPs escriben |
| `si_sucursales` | Transaccional | 7 | 2 | 🟠 2 SPs escriben |
| `si_solicitud_movil` | Transaccional | 5 | 2 | 🟠 2 SPs escriben |
| `si_direcciones` | Transaccional | 5 | 2 | 🟠 2 SPs escriben |
| `si_ejecut` | Transaccional | 6 | 1 | 🟠 1 SPs escriben |
| `si_codigopostal` | Transaccional | 3 | 3 | 🟠 3 SPs escriben |
| `RMONTO_FINANCIADO` | Transaccional | 3 | 3 | 🟠 3 SPs escriben |
| `ss_contproc` | Transaccional | 3 | 3 | 🟠 3 SPs escriben |
| `si_servcte` | Transaccional | 3 | 3 | 🟠 3 SPs escriben |
| `si_refcomer` | Transaccional | 3 | 3 | 🟠 3 SPs escriben |
| `informix` | Transaccional | 3 | 3 | 🟠 3 SPs escriben |
| `si_refper` | Transaccional | 3 | 3 | 🟠 3 SPs escriben |
| `si_fechas` | Transaccional | 5 | 0 | 🟢 Solo lectura |
| `si_ctepf` | Transaccional | 2 | 2 | 🟠 2 SPs escriben |
| `td_numCliente` | Transaccional | 2 | 2 | 🟠 2 SPs escriben |
| `si_empresas` | Transaccional | 3 | 0 | 🟢 Solo lectura |
| `ss_resum_scor_fin` | Transaccional | 3 | 0 | 🟢 Solo lectura |
| `si_tprefcomer` | Transaccional | 3 | 0 | 🟢 Solo lectura |
| `sd_maecontrato` | Maestro | 3 | 0 | 🟢 Solo lectura |

> **[SME-PENDING]** Confirmar nombre exacto en producción, volumen de registros, política de retención y campos PII con DBA LegacyCore.

## Matriz completa SP × Tabla

| SP | LOC | Fan-in | Tablas que LEE | Tablas que ESCRIBE |
|----|-----|--------|---------------|-------------------|
| `sp_acivarserviciobpi_apolo` | 2934 | 0 | `TRIM`, `bdicheq:`  ⚠️ext, `bdicheq:sc_maechq`  ⚠️ext, `bdicheq:sc_tarjeta`  ⚠️ext, `bdicred:`  ⚠️ext, `bdicred:sd_bitacorabloqueocta`  ⚠️ext | `bdinteg:`  ⚠️ext, `informix`, `si_tempoctas` | 🔄
| `bm_obten_lista_cuentas` | 1220 | 0 | `bdicheq:`  ⚠️ext, `bdicred:`  ⚠️ext, `bdinteg:`  ⚠️ext | `bdinteg:`  ⚠️ext, `informix` |
| `sp_actualiza_ctemovil` | 769 | 0 | `bdinteg:`  ⚠️ext, `bdinteg:si_correos`  ⚠️ext, `sysmaster:`  ⚠️ext | `bdinteg:`  ⚠️ext, `si_bitacora_celular_registrado_am`, `si_bitacora_lista_negra`, `si_telefonos` |
| `sp_actualiza_curp` | 738 | 0 | `bdinteg:`  ⚠️ext, `bdisitesp:`  ⚠️ext, `si_bitacora_renapob` | `bdinteg:si_ctepf`  ⚠️ext, `bdisitesp:`  ⚠️ext |
| `alta_sol_tc_cjunk` | 580 | 3 | `bdicheq:`  ⚠️ext, `bdicred:`  ⚠️ext, `bdinteg:`  ⚠️ext, `bdinteg:si_direcciones`  ⚠️ext, `bdisolic:`  ⚠️ext | `bdinteg:`  ⚠️ext, `bdisolic:`  ⚠️ext |
| `sp_actbex` | 145 | 4 | `bdibpi:bpi_activacion_bex`  ⚠️ext, `bdicheq:`  ⚠️ext, `bdicred:`  ⚠️ext, `bdinteg:si_telefonos`  ⚠️ext, `intercard:tarjeta`  ⚠️ext | `bdibpi:bpi_activacion_bex`  ⚠️ext, `bdinteg:bitacora_activacion_bex`  ⚠️ext |
| `sp_actualiza_mensajes_cel` | 98 | 0 | `bdinteg:`  ⚠️ext | `si_ctepf` |
| `sp_actualiza_mensajes_cel_web` | 98 | 0 | `bdinteg:`  ⚠️ext | `si_ctepf` |
| `sp_acivarserviciobpi` | 1037 | 0 | `BDINTEG:si_catzonas`  ⚠️ext, `bdibpi:`  ⚠️ext, `bdinteg:`  ⚠️ext, `bdinteg:si_cliente`  ⚠️ext, `bdinteg:si_fechas`  ⚠️ext, `bdinteg:si_param`  ⚠️ext | `bdinteg:`  ⚠️ext, `si_ctanvl2_ctrlrep`, `td_numCliente` |
| `sp_act_declidir` | 93 | 0 | `log_fusionclientes`, `si_direcciones` | `bdinteg:si_direcciones_actual`  ⚠️ext |
| `sp_act_dirmovil` | 43 | 0 | `bdinteg:si_catzonas`  ⚠️ext, `bdinteg:si_ciudades`  ⚠️ext, `bdinteg:si_estados`  ⚠️ext | — |
| `sp_act_folio_procesado_solicitudes_movil` | 34 | 0 | `si_fechas` | `si_solicitud_movil` |
| `sp_act_sucursalsorteo` | 411 | 0 | `bdinteg:`  ⚠️ext, `si_bitacora_ife`, `si_indicadores_idbox`, `si_sucursales`, `si_tmp_ctes_titulares_idbox`, `sysmaster:`  ⚠️ext | `bdinteg:`  ⚠️ext, `si_indicadores_idbox` |
| `sp_actcatalogos_sitesp` | 1203 | 0 | `BDINTEG:SI_CATCALLES`  ⚠️ext, `BDINTEG:SI_CATCIUDADES`  ⚠️ext, `BDINTEG:SI_CATZONAS`  ⚠️ext, `BDINTEG:SI_DIRECCIONES_ACTUAL`  ⚠️ext, `BDINTEG:SI_ESTADOS`  ⚠️ext, `bdinteg:`  ⚠️ext | `bdinteg:`  ⚠️ext |
| `sp_actcatalogos_sitesp_prb` | 237 | 0 | `bdinteg:`  ⚠️ext, `si_solicitud_movil` | `bdinteg:`  ⚠️ext |
| `sp_actdepctesbcplcpl` | 303 | 0 | `bdinteg:`  ⚠️ext | `bdinteg:`  ⚠️ext |
| `sp_activadesactivaproductos` | 332 | 0 | `bdinteg:`  ⚠️ext, `bdinteg:si_localidades`  ⚠️ext, `bdinteg:si_ptf`  ⚠️ext, `bdinteg:si_sucursales`  ⚠️ext, `bdisolic:`  ⚠️ext | `bdinteg:`  ⚠️ext, `bdisolic:`  ⚠️ext |
| `sp_activarserviciobm` | 439 | 0 | `bdibpi:`  ⚠️ext, `bdinteg:`  ⚠️ext, `bdinteg:si_direcciones_actual`  ⚠️ext, `bdinteg:si_por_asignar`  ⚠️ext, `sysmaster:sysshmvals`  ⚠️ext | `bdibpi:`  ⚠️ext, `bdinteg:`  ⚠️ext, `bdinteg:si_bitacora_dom`  ⚠️ext, `bdinteg:si_direcciones`  ⚠️ext |
| `sp_activausuario_bei` | 32 | 0 | `bdinteg:`  ⚠️ext | `bdinteg:`  ⚠️ext |
| `sp_activausuario_bpi` | 42 | 0 | `bdinteg:`  ⚠️ext, `bdinteg:si_bpiusuarios`  ⚠️ext | `bdinteg:si_bpiusuarios`  ⚠️ext, `bdinteg:si_cambiostcte`  ⚠️ext |
| `sp_actnomcterfcalterno` | 918 | 0 | `bdicheq:sc_tarjeta`  ⚠️ext, `bdicobranza:cb_param`  ⚠️ext, `bdicred:sd_maecred`  ⚠️ext, `bdilide:`  ⚠️ext, `bdinteg:`  ⚠️ext, `bdinteg:si_catcalles`  ⚠️ext | `bdinteg:`  ⚠️ext, `del`, `si_refdirecciones` |
| `sp_actstatenviocpel` | 529 | 0 | `bdinteg:`  ⚠️ext, `bdisolic:`  ⚠️ext | `bdinteg:`  ⚠️ext, `bdisolic:`  ⚠️ext |
| `sp_actstatusctecopnvoparam_club` | 1360 | 0 | `BDICHEQ:`  ⚠️ext, `BDINTEG:`  ⚠️ext, `BDINTEG:SI_CLIENTE`  ⚠️ext, `BDINTEG:SI_FUSCLIENTE`  ⚠️ext, `BdInteg:tmpxmlarchclientegrupo`  ⚠️ext, `bdicheq:`  ⚠️ext | `bdinteg:`  ⚠️ext, `bdinteg:cte_grupo_huella`  ⚠️ext, `bdinteg:sp_temphuella`  ⚠️ext, `clientes_grupo_envia_xml` |
| `sp_actstatusmensajeenviar` | 52 | 0 | `bdinteg:si_mensajes_enviar`  ⚠️ext | `bdinteg:si_mensajes_enviar`  ⚠️ext |
| `sp_actual_gerente` | 44 | 0 | `si_sucursales` | `si_sucursales` |
| `sp_actualiza_act_subact` | 433 | 0 | `bdicheq:`  ⚠️ext, `bdinteg:`  ⚠️ext, `bdinvers:`  ⚠️ext | `bdinteg:`  ⚠️ext |
| `sp_actualiza_aprcf` | 74 | 0 | `si_solicitud_movil` | — |
| `sp_actualiza_bitacora_ine` | 107 | 0 | `BDISITESP:SE_CTESSITESPCTE`  ⚠️ext, `SI_BITACORA_IFE`, `TMPSI_BITACORA_IFE20181103`, `TMPSI_BITACORA_IFE20181118` | `TMPSI_BITACORA_IFE20181103`, `TMPSI_BITACORA_IFE20181118`, `bdinteg:si_bitacora_ife`  ⚠️ext |
| `sp_actualiza_calle` | 170 | 0 | `bdinteg:si_direcciones_actual`  ⚠️ext, `bdinteg:si_por_asignar`  ⚠️ext, `sysmaster:sysshmvals`  ⚠️ext | `bdinteg:si_bitacora_dom`  ⚠️ext, `bdinteg:si_direcciones`  ⚠️ext |
| `sp_actualiza_campos_uh` | 1603 | 0 | `bdilide:`  ⚠️ext, `bdinteg:`  ⚠️ext, `bdinteg:si_cte_huella`  ⚠️ext, `bdinteg:si_fus_club_beneficiario`  ⚠️ext, `bdinteg:si_fusctessitespcte`  ⚠️ext, `bdinteg:si_fusctessitespcte_his`  ⚠️ext | `SI_DIRECCIONES`, `SI_DIRECCIONES_actual`, `bdibpi:`  ⚠️ext, `bdicheq:`  ⚠️ext |
| `sp_actualiza_catcalles` | 37 | 0 | `si_temp_catcalles` | `si_direcciones`, `si_direcciones_actual` |
| `sp_actualiza_catcalles2` | 37 | 0 | `si_temp_catcalles` | `si_direcciones`, `si_direcciones_actual` |
| `sp_actualiza_clubproteccion` | 161 | 0 | `bdinteg:`  ⚠️ext, `bdinteg:si_cliente`  ⚠️ext, `si_param` | `bdinteg:`  ⚠️ext, `si_ctessat` |
| `sp_actualiza_contadores_ivr` | 104 | 0 | `si_estadistica_fusiones` | — |
| `sp_actualiza_contadores_ivr_web` | 131 | 0 | `bdinteg:si_fechas`  ⚠️ext, `si_bitacora_actividades` | `si_bitacora_actividades` |
| `sp_actualiza_cp_buro` | 155 | 0 | `bdinteg:si_direcciones`  ⚠️ext, `bdinteg:si_direcciones_actual`  ⚠️ext, `bdinteg:si_por_asignar`  ⚠️ext | `bdinteg:si_direcciones`  ⚠️ext, `bdinteg:si_por_asignar`  ⚠️ext |
| `sp_actualiza_cta_calificacion` | 313 | 0 | `bdicheq:`  ⚠️ext, `bdicred:`  ⚠️ext, `bdinteg:`  ⚠️ext, `bdinvers:`  ⚠️ext, `intercard:`  ⚠️ext, `si_cte_grado_riesgo` | `si_cte_grado_riesgo` |
| `sp_actualiza_direcciones` | 251 | 0 | `si_direcciones_actual`, `si_direcciones_tmp` | `bdinteg:si_direcciones_actual`  ⚠️ext |
| `sp_actualiza_direcciones_2` | 219 | 0 | `si_direcciones`, `si_direcciones_tmp` | — |
| `sp_actualiza_domicilio` | 219 | 0 | `bdinteg:si_catcalles`  ⚠️ext, `bdinteg:si_catciudades`  ⚠️ext, `bdinteg:si_catzonas`  ⚠️ext, `bdinteg:si_direcciones_actual`  ⚠️ext, `bdinteg:si_estados`  ⚠️ext, `bdinteg:si_por_asignar`  ⚠️ext | `bdinteg:si_por_asignar`  ⚠️ext |
| `sp_actualiza_domicilio_cac` | 148 | 0 | `bdinteg:si_direcciones`  ⚠️ext, `bdinteg:si_direcciones_actual`  ⚠️ext | `bdinteg:si_direcciones`  ⚠️ext |
| `sp_actualiza_domicilio_colonia` | 159 | 0 | `bdinteg:si_direcciones`  ⚠️ext, `bdinteg:si_direcciones_actual`  ⚠️ext, `bdinteg:si_por_asignar`  ⚠️ext, `si_catcalles` | `bdinteg:si_direcciones`  ⚠️ext |
| `sp_actualiza_domicilio_porcolumn` | 222 | 0 | `bdinteg:si_catcalles`  ⚠️ext, `bdinteg:si_catzonas`  ⚠️ext, `bdinteg:si_ciudades`  ⚠️ext, `bdinteg:si_direcciones_actual`  ⚠️ext, `bdinteg:si_estados`  ⚠️ext, `bdinteg:si_por_asignar`  ⚠️ext | `bdinteg:si_direcciones`  ⚠️ext |
| `sp_actualiza_dominio_correos` | 419 | 0 | `bdinteg:si_ejecut`  ⚠️ext, `bdinteg:tmp_correos_incompletos`  ⚠️ext, `informix`, `si_cliente`, `si_huella_temp`, `si_huella_temp_hist2018` | `informix`, `temp_si_huella_temp` |
| `sp_actualiza_estadoine` | 918 | 0 | `TABLE`, `bdinteg:`  ⚠️ext, `sysmaster:`  ⚠️ext, `temp_bpiusuarios`, `temp_ivrusuarios` | `bdiunica` |
| `sp_actualiza_estatus_correos` | 79 | 0 | `si_correos` | `si_correos` |
| `sp_actualiza_gerentes` | 82 | 0 | `si_ejecut`, `si_fechas`, `si_sucursales` | `si_sucursales` |
| `sp_actualiza_id_consulta_pdf` | 838 | 0 | `bdibei:`  ⚠️ext, `bdicheq:`  ⚠️ext, `bdicred:`  ⚠️ext, `bdinteg:`  ⚠️ext, `intercard:`  ⚠️ext, `resultadosrfc` | `bdinteg:`  ⚠️ext, `si_cliente` |
| `sp_actualiza_identifi` | 2832 | 0 | `bdinteg:`  ⚠️ext, `bdinvers:sv_ctascontinv`  ⚠️ext, `bdinvers:sv_movhis`  ⚠️ext, `bdisolic:`  ⚠️ext, `sv_maeinv`, `tmp_concilia` | `STATISTICS`, `bdinteg:`  ⚠️ext, `tmp_conciliainv`, `tmp_conciliainvdif` |
| `sp_actualiza_info_cliente` | 2101 | 0 | `SI_CORREOS`, `SI_CTEPF`, `bdicheq:`  ⚠️ext, `bdicred:`  ⚠️ext, `bdinteg:`  ⚠️ext, `bdinteg:informix`  ⚠️ext | `bdinteg:`  ⚠️ext, `bdinteg:si_bitacora_dom`  ⚠️ext, `bdinteg:si_bitacora_replica_sucs`  ⚠️ext, `bdinteg:si_catzonas_suc`  ⚠️ext |

## Tablas compartidas (múltiples escritores) — riesgo de contención en parallel-run

- **`bdinteg:`**: escrita por `sp_actualiza_identifi`, `sp_actualiza_lugarnac`, `sp_actualiza_id_consulta_pdf`, `sp_actualiza_ctemovil`, `sp_actualiza_clubproteccion` ... y 25 más
- **`bdinteg:si_direcciones`**: escrita por `sp_actualiza_domicilio_porcolumn`, `sp_activarserviciobm`, `sp_actualiza_domicilio_colonia`, `sp_actualiza_calle`, `sp_actualiza_domicilio_cac` ... y 1 más
- **`bdisolic:`**: escrita por `sp_actstatenviocpel`, `sp_actualiza_campos_uh`, `sp_activadesactivaproductos`, `alta_sol_tc_cjunk`
- **`bdibpi:`**: escrita por `sp_activarserviciobm`, `bm_inicializa_diario`, `sp_actualiza_campos_uh`, `bm_nuevo_usuario`
- **`informix`**: escrita por `sp_acivarserviciobpi_apolo`, `sp_actualiza_dominio_correos`, `bm_obten_lista_cuentas`

## Tablas candidatas a CDC prioritario (Debezium / AWS DMS)

| Tabla | SPs escritores | Prioridad CDC |
|-------|---------------|---------------|
| `informix` | `sp_acivarserviciobpi_apolo`, `sp_actualiza_dominio_correos`, `bm_obten_lista_cuentas` | 🟠 SEGUNDA |
| `ss_contproc` | `actividad`, `alta_nip`, `act_encab` | 🟠 SEGUNDA |
| `si_codigopostal` | `actividad`, `alta_nip`, `act_encab` | 🟠 SEGUNDA |
| `si_refper` | `actividad`, `alta_nip`, `act_encab` | 🟠 SEGUNDA |
| `RMONTO_FINANCIADO` | `actividad`, `alta_nip`, `act_encab` | 🟠 SEGUNDA |
| `si_refcomer` | `actividad`, `alta_nip`, `act_encab` | 🟠 SEGUNDA |
| `si_servcte` | `actividad`, `alta_nip`, `act_encab` | 🟠 SEGUNDA |
| `si_param` | `actividad`, `alta_nip`, `act_encab` | 🟠 SEGUNDA |

## Tablas externas accedidas (cross-DB)

- `BDICHEQ:` (R) — desde `sp_actstatusctecopnvoparam_club`
- `BDINTEG:` (R) — desde `sp_actstatusctecopnvoparam_club`
- `BDINTEG:SI_CATCALLES` (R) — desde `sp_actcatalogos_sitesp`
- `BDINTEG:SI_CATCIUDADES` (R) — desde `sp_actcatalogos_sitesp`
- `BDINTEG:SI_CATZONAS` (R) — desde `sp_actcatalogos_sitesp`
- `BDINTEG:SI_CLIENTE` (R) — desde `sp_actstatusctecopnvoparam_club`
- `BDINTEG:SI_DIRECCIONES_ACTUAL` (R) — desde `sp_actcatalogos_sitesp`
- `BDINTEG:SI_ESTADOS` (R) — desde `sp_actcatalogos_sitesp`
- `BDINTEG:SI_FUSCLIENTE` (R) — desde `sp_actstatusctecopnvoparam_club`
- `BDISITESP:SE_CTESSITESPCTE` (R) — desde `sp_actualiza_bitacora_ine`
- `BdInteg:tmpxmlarchclientegrupo` (R) — desde `sp_actstatusctecopnvoparam_club`
- `bdibei:` (R) — desde `sp_actualiza_id_consulta_pdf`
- `bdibpi:` (R+W) — desde `sp_acivarserviciobpi`, `sp_actualiza_numerocalle`, `bm_nuevo_usuario`
- `bdibpi:bpi_activacion_bex` (R+W) — desde `sp_actbex`
- `bdicheq:` (R+W) — desde `sp_actbex`, `sp_actualiza_cta_calificacion`, `sp_actualiza_info_cliente_opt`
- `bdicheq:sc_cuenta_telefono` (R+W) — desde `sp_actualiza_campos_uh`
- `bdicheq:sc_fechas` (R+W) — desde `actualiza_indicadores`
- `bdicheq:sc_maechq` (R) — desde `sp_acivarserviciobpi_apolo`, `sp_actualiza_info_cliente_opt`
- `bdicheq:sc_movdia` (R) — desde `sp_actualiza_info_cliente_opt`
- `bdicheq:sc_movhis` (R) — desde `sp_actualiza_info_cliente_opt`
- `bdicheq:sc_movhis_old` (R) — desde `sp_actualiza_info_cliente_opt`
- `bdicheq:sc_producto` (R) — desde `actividad`, `alta_nip`, `act_encab`
- `bdicntchq:` (R+W) — desde `sp_actualiza_campos_uh`
- `bdicobranza:cb_param` (R) — desde `sp_actnomcterfcalterno`
- `bdicont:co_detpol` (R+W) — desde `actividad`, `alta_nip`, `act_encab`
- `bdicont:co_poliza` (R+W) — desde `actividad`, `alta_nip`, `act_encab`
- `bdicred:` (R+W) — desde `sp_actbex`, `sp_actualiza_cta_calificacion`, `sp_actualiza_info_cliente_opt`
- `bdicred:sd_bitacorabloqueocta` (R) — desde `sp_acivarserviciobpi_apolo`
- `bdicred:sd_definicion` (R) — desde `actividad`, `alta_nip`, `sp_acivarserviciobpi_apolo`
- `bdicred:sd_fechas` (R+W) — desde `actualiza_indicadores`
- `bdicred:sd_maecred` (R) — desde `actividad`, `alta_nip`, `act_encab`
- `bdicred:sd_maecredcrd` (R) — desde `sp_acivarserviciobpi_apolo`, `sp_actualiza_info_cliente_opt`
- `bdicred:sd_maesdos` (R) — desde `actividad`, `alta_nip`, `sp_acivarserviciobpi_apolo`
- `bdicred:sd_maesdoscrd` (R) — desde `sp_acivarserviciobpi_apolo`
- `bdidomi:` (R+W) — desde `sp_actualiza_campos_uh`
- `bdilide:` (R+W) — desde `sp_actualiza_campos_uh`, `sp_actnomcterfcalterno`
- `bdilide:sl_detlide` (R+W) — desde `sp_actualiza_campos_uh`
- `bdilide:sl_retlide` (R+W) — desde `sp_actualiza_campos_uh`
- `bdinteg:` (R+W) — desde `sp_activausuario_bpi`, `sp_actualiza_identifi`, `sp_actualiza_lugarnac`
- `bdinteg:bitacora_activacion_bex` (R+W) — desde `sp_actbex`
- `bdinteg:cte_grupo_huella` (R+W) — desde `sp_actstatusctecopnvoparam_club`
- `bdinteg:informix` (R) — desde `sp_actualiza_info_cliente`
- `bdinteg:si_archivoscopdiario` (R) — desde `sp_actualiza_premio`
- `bdinteg:si_bitacora_dom` (R+W) — desde `sp_activarserviciobm`, `sp_actualiza_info_cliente`, `sp_actualiza_calle`
- `bdinteg:si_bitacora_ife` (R+W) — desde `sp_actualiza_bitacora_ine`
- `bdinteg:si_bitacora_replica_sucs` (R+W) — desde `sp_actualiza_info_cliente`
- `bdinvers:` (R+W) — desde `sp_actualiza_info_cliente`, `sp_actualiza_campos_uh`, `sp_actualiza_cta_calificacion`
- `bdinvers:sv_ctascontinv` (R) — desde `sp_actualiza_identifi`
- `bdinvers:sv_fechas` (R+W) — desde `actualiza_indicadores`
- `bdinvers:sv_maeinv` (R) — desde `actividad`, `alta_nip`, `act_encab`
- `bdinvers:sv_movdia` (R) — desde `sp_actualiza_info_cliente_opt`
- `bdinvers:sv_movhis` (R) — desde `sp_actualiza_identifi`, `sp_actualiza_info_cliente_opt`
- `bdiprog:` (R+W) — desde `actualizaguardaconyuge_cjunk`, `sp_actualiza_campos_uh`
- `bdiprospectos:` (R) — desde `sp_actualiza_premio`, `sp_actualiza_info_cliente`
- `bdisac:` (R) — desde `sp_actstatusctecopnvoparam_club`
- `bdisac:sac_fechas` (R+W) — desde `actualiza_indicadores`
- `bdisitesp:` (R+W) — desde `sp_actualiza_curp`
- `bdisitesp:se_catsitesp` (R) — desde `sp_actualiza_campos_uh`
- `bdisitesp:se_ctessitespcte` (R+W) — desde `sp_actualiza_campos_uh`
- `bdisitesp:se_ctessitespcte_his` (R+W) — desde `sp_actualiza_campos_uh`
- `bdisolic:` (R+W) — desde `sp_actualiza_identifi`, `sp_actualiza_info_cliente_opt`, `sp_actualiza_premio`
- `bdispeua:sp_pagoenviar` (R+W) — desde `actividad`, `alta_nip`, `act_encab`
- `bditarjcop:` (R) — desde `sp_actualiza_premio`, `sp_actualiza_info_cliente`
- `bditransfer:` (R) — desde `sp_acivarserviciobpi_apolo`
- `bditransfer:tf_account_balance_customer` (R) — desde `sp_acivarserviciobpi_apolo`
- `bditransfer:tf_maecte` (R+W) — desde `sp_acivarserviciobpi_apolo`, `sp_actualiza_campos_uh`, `sp_actualiza_info_cliente_opt`
- `intercard:` (R+W) — desde `sp_actualiza_campos_uh`, `sp_actualiza_cta_calificacion`, `sp_actualiza_id_consulta_pdf`
- `intercard:statustarjeta` (R) — desde `sp_acivarserviciobpi_apolo`
- `intercard:tarjeta` (R) — desde `sp_acivarserviciobpi_apolo`, `sp_actbex`
- `sysmaster:` (R) — desde `sp_act_sucursalsorteo`, `sp_actualiza_dominio_correos`, `sp_actualiza_estadoine`
- `sysmaster:SysTabNames` (R) — desde `sp_actstatusctecopnvoparam_club`
- `sysmaster:sysshmvals` (R) — desde `sp_activarserviciobm`, `sp_actualiza_info_cliente`, `sp_actualiza_calle`
- `sysmaster:systabnames` (R) — desde `sp_actualiza_campos_uh`

---
*Generado por: Specialist — Informix SPL Analysis · 2026-07-03 · Evidencia: source/LegacyCore/informix/bdinteg_*.sql (análisis estático de 70 archivos SQL) · análisis estático de cláusulas FROM/INSERT/UPDATE/DELETE*

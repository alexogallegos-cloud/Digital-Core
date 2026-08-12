# D10 · Sucursales — Matriz SP × Tabla (READ / WRITE)

> **Componente:** LegacyCore · SPE-AM-001 · Etapa 1
> **Base de datos:** `bdisuc` · IBM Informix IDS 14.10 / POWER-AIX
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

## Resumen de tablas propias de `bdisuc`

| Tabla | Tipo | Lectores | Escritores | Ownership |
|-------|------|----------|-----------|-----------|
| `ss_param_cajagen` | Catálogo / Config | 15 | 9 | 🔴 9 SPs escriben |
| `ss_proveedores` | Transaccional | 8 | 1 | 🟠 1 SPs escriben |
| `ss_poliza` | Transaccional | 4 | 4 | 🟠 4 SPs escriben |
| `ss_operaciones` | Transaccional | 5 | 3 | 🟠 3 SPs escriben |
| `ss_mae_entradasalida` | Maestro | 5 | 2 | 🟠 2 SPs escriben |
| `ss_atm` | Transaccional | 3 | 3 | 🟠 3 SPs escriben |
| `ss_atm_rec` | Transaccional | 2 | 2 | 🟠 2 SPs escriben |
| `co_detpol` | Transaccional | 2 | 2 | 🟠 2 SPs escriben |
| `ss_saldossuc` | Transaccional | 0 | 4 | 🟠 4 SPs escriben |
| `co_poliza` | Transaccional | 2 | 2 | 🟠 2 SPs escriben |
| `co_auditpase` | Log / Bitácora | 2 | 2 | 🟠 2 SPs escriben |
| `co_auxiliar` | Transaccional | 2 | 0 | 🟢 Solo lectura |
| `ss_contproc` | Transaccional | 1 | 1 | 🟠 1 SPs escriben |
| `SS_Param_cajagen` | Catálogo / Config | 2 | 0 | 🟢 Solo lectura |
| `co_poldet` | Transaccional | 2 | 0 | 🟢 Solo lectura |
| `ss_cajageneral` | Transaccional | 1 | 1 | 🟠 1 SPs escriben |
| `ss_catstatus` | Transaccional | 2 | 0 | 🟢 Solo lectura |
| `systables` | Transaccional | 1 | 0 | 🟢 Solo lectura |
| `syscolumns` | Transaccional | 1 | 0 | 🟢 Solo lectura |
| `ss_saldossuc_arqueo` | Transaccional | 0 | 1 | 🟠 1 SPs escriben |

> **[SME-PENDING]** Confirmar nombre exacto en producción, volumen de registros, política de retención y campos PII con DBA LegacyCore.

## Matriz completa SP × Tabla

| SP | LOC | Fan-in | Tablas que LEE | Tablas que ESCRIBE |
|----|-----|--------|---------------|-------------------|
| `sp_catsecciones_oemn` | 1990 | 0 | `bdinteg:`  ⚠️ext, `bdisuc:`  ⚠️ext | `bdisuc:`  ⚠️ext |
| `pasecont_web_2` | 1870 | 0 | `bdicont:`  ⚠️ext, `bdicont:co_fechas`  ⚠️ext, `bdicont:co_poldet_20240518`  ⚠️ext, `bdinteg:`  ⚠️ext, `bdinteg:si_sucursales`  ⚠️ext, `bdisuc:`  ⚠️ext | `bdicont:`  ⚠️ext, `bdisuc:`  ⚠️ext, `ss_saldossuc_arqueo` |
| `sp_consulta_catdenominacion_bym` | 1052 | 374 | `bdicont:co_fechas`  ⚠️ext, `bdicont:co_histsdodias`  ⚠️ext, `bdicont:co_sdodias`  ⚠️ext, `bdinteg:`  ⚠️ext, `bdisuc:`  ⚠️ext, `bdisuc:ss_saldossuc`  ⚠️ext | `bdisuc:`  ⚠️ext |
| `sp_altamodificacion_piezas_bym` | 332 | 373 | `bdinteg:`  ⚠️ext, `bdisuc:`  ⚠️ext | `bdisuc:`  ⚠️ext |
| `sp_consulta_cajageneral` | 136 | 0 | `bdicont:co_fechas`  ⚠️ext, `bdicont:co_poldet_20240518`  ⚠️ext, `bdisuc:`  ⚠️ext | — |
| `reversion` | 84 | 12 | `bdinteg:`  ⚠️ext, `bdisuc:`  ⚠️ext | `bdisuc:`  ⚠️ext |
| `auditapase` | 307 | 0 | `bdinteg:si_catalog`  ⚠️ext, `bdinteg:si_regional`  ⚠️ext, `bdinteg:si_sucursales`  ⚠️ext, `co_auditpase`, `co_auxiliar`, `co_detpol` | `co_auditpase`, `co_detpol`, `co_poliza` |
| `columna_indice` | 10 | 0 | `syscolumns`, `systables` | — |
| `consentradassalidas` | 62 | 0 | `bdinteg:si_sucursales`  ⚠️ext, `ss_mae_entradasalida` | — |
| `consulta_saldos` | 217 | 0 | `bdinteg:si_fechas`  ⚠️ext, `bdinteg:si_plazas_cajagen`  ⚠️ext, `bdinteg:si_sucursales`  ⚠️ext, `bdisuc:`  ⚠️ext, `bdisuc:ss_cajageneral`  ⚠️ext, `bdisuc:ss_mae_entradasalida`  ⚠️ext | — |
| `consultacajageneral` | 192 | 0 | `bdinteg:si_divisas`  ⚠️ext, `bdinteg:si_plazas_cajagen`  ⚠️ext, `bdisuc:ss_cajageneral`  ⚠️ext, `bdisuc:ss_proveedores`  ⚠️ext, `ss_proveedores` | — |
| `consultacajageneral2` | 247 | 0 | `bdinteg:si_divisas`  ⚠️ext, `bdinteg:si_plazas_cajagen`  ⚠️ext, `bdisuc:`  ⚠️ext, `bdisuc:ss_cajageneral`  ⚠️ext, `bdisuc:ss_proveedores`  ⚠️ext, `ss_proveedores` | — |
| `consultacajageneral2_totales` | 155 | 0 | `bdinteg:`  ⚠️ext, `bdinteg:si_divisas`  ⚠️ext, `bdinteg:si_plazas_cajagen`  ⚠️ext, `bdisuc:`  ⚠️ext, `bdisuc:ss_cajageneral`  ⚠️ext, `bdisuc:ss_proveedores`  ⚠️ext | — |
| `gen_encab` | 42 | 0 | `bdicont:co_detpol`  ⚠️ext | `bdicont:co_poliza`  ⚠️ext |
| `genera_update_index` | 33 | 0 | `sysindexes` | `statistics` |
| `manejacajageneral` | 426 | 0 | `bdinteg:si_catalog`  ⚠️ext, `bdinteg:si_regional`  ⚠️ext, `bdinteg:si_sucursales`  ⚠️ext, `co_auditpase`, `co_auxiliar`, `co_detpol` | `co_auditpase`, `co_detpol`, `co_poliza`, `ss_cajageneral` |
| `pasecajag` | 405 | 0 | `bdicont:co_detpol`  ⚠️ext, `bdicont:co_poldet`  ⚠️ext, `bdicont:co_poliza`  ⚠️ext, `bdinteg:si_ejecut`  ⚠️ext, `bdinteg:si_fechas`  ⚠️ext, `bdinteg:si_param`  ⚠️ext | `bdicont:co_detpol`  ⚠️ext, `bdicont:co_poldet`  ⚠️ext, `bdicont:co_poliza`  ⚠️ext, `bdisuc:ss_ctrlpasecg`  ⚠️ext |
| `pasecajag_esp` | 409 | 0 | `bdicont:co_detpol`  ⚠️ext, `bdicont:co_poldet`  ⚠️ext, `bdicont:co_poliza`  ⚠️ext, `bdinteg:si_ejecut`  ⚠️ext, `bdinteg:si_param`  ⚠️ext, `bdinteg:si_plazas`  ⚠️ext | `bdicont:co_detpol`  ⚠️ext, `bdicont:co_poldet`  ⚠️ext, `bdicont:co_poliza`  ⚠️ext, `bdisuc:ss_ctrlpasecg`  ⚠️ext |
| `pasecajag_fec` | 393 | 0 | `bdicont:co_detpol`  ⚠️ext, `bdicont:co_poldet`  ⚠️ext, `bdicont:co_poliza`  ⚠️ext, `bdinteg:si_ejecut`  ⚠️ext, `bdinteg:si_fechas`  ⚠️ext, `bdinteg:si_param`  ⚠️ext | `bdicont:co_detpol`  ⚠️ext, `bdicont:co_poldet`  ⚠️ext, `bdicont:co_poliza`  ⚠️ext, `bdisuc:ss_ctrlpasecg`  ⚠️ext |
| `pasecajag_pba` | 393 | 0 | `bdicont:co_detpol`  ⚠️ext, `bdicont:co_poldet`  ⚠️ext, `bdicont:co_poliza`  ⚠️ext, `bdinteg:si_ejecut`  ⚠️ext, `bdinteg:si_fechas`  ⚠️ext, `bdinteg:si_param`  ⚠️ext | `bdicont:co_detpol`  ⚠️ext, `bdicont:co_poldet`  ⚠️ext, `bdicont:co_poliza`  ⚠️ext, `bdisuc:ss_ctrlpasecg`  ⚠️ext |
| `pasecont` | 1873 | 0 | `SS_Param_cajagen`, `bdicont:co_poldet`  ⚠️ext, `bdinteg:`  ⚠️ext, `bdinteg:si_metales`  ⚠️ext, `bdinteg:si_sucursales`  ⚠️ext, `bdisuc:`  ⚠️ext | `bdicont:co_poldet`  ⚠️ext, `bdisuc:`  ⚠️ext, `bdisuc:ss_mae_entradasalida`  ⚠️ext, `ss_atm` |
| `reversion_ant` | 75 | 0 | `bdinteg:`  ⚠️ext | — |
| `reversion_sobrante` | 2248 | 0 | `bdinteg:`  ⚠️ext, `bdisuc:`  ⚠️ext, `sysmaster:sysshmvals`  ⚠️ext | `bdinteg:`  ⚠️ext, `bdisuc:`  ⚠️ext |
| `reversion_tombola` | 345 | 0 | `bdinteg:`  ⚠️ext, `bdinteg:si_sucursales`  ⚠️ext, `bdisuc:`  ⚠️ext, `bdisuc:ss_catcardcarriers`  ⚠️ext, `bdisuc:ss_catdocumentos`  ⚠️ext, `bdisuc:ss_catstatusdoc`  ⚠️ext | `bdisuc:`  ⚠️ext, `bdisuc:ss_catdocumentos`  ⚠️ext, `bdisuc:ss_cattipocarpeta`  ⚠️ext |
| `sp_accesodot` | 24 | 0 | — | — |
| `sp_actestatuscaja` | 2435 | 0 | `bdinteg:`  ⚠️ext, `bdisuc:`  ⚠️ext, `bdisuc:ss_proveedores`  ⚠️ext, `sysmaster:`  ⚠️ext, `sysmaster:sysshmvals`  ⚠️ext | `bdisuc:`  ⚠️ext |
| `sp_actestatuscajacap` | 2110 | 0 | `bdinteg:`  ⚠️ext, `bdisuc:`  ⚠️ext, `sysmaster:sysshmvals`  ⚠️ext | `bdinteg:`  ⚠️ext, `bdisuc:`  ⚠️ext |
| `sp_actestatuscajaras` | 1827 | 0 | `bdinteg:`  ⚠️ext, `bdisuc:`  ⚠️ext, `sysmaster:sysshmvals`  ⚠️ext | `bdinteg:`  ⚠️ext, `bdisuc:`  ⚠️ext |
| `sp_actualizapieza_bym` | 537 | 0 | `bdicont:co_fechas`  ⚠️ext, `bdicont:co_histsdodias`  ⚠️ext, `bdicont:co_sdodias`  ⚠️ext, `bdinteg:`  ⚠️ext, `bdisuc:`  ⚠️ext, `bdisuc:ss_saldossuc`  ⚠️ext | `bdisuc:`  ⚠️ext |
| `sp_actualizapieza_bym_web` | 631 | 0 | `bdinteg:`  ⚠️ext, `bdisuc:`  ⚠️ext | `bdisuc:`  ⚠️ext |
| `sp_actualizastatuscajaactiva` | 537 | 0 | `bdinteg:`  ⚠️ext, `bdinteg:si_fechas`  ⚠️ext, `bdisuc:`  ⚠️ext, `bdisuc:ss_corteadminview`  ⚠️ext | `bdisuc:`  ⚠️ext |
| `sp_admon_documentos` | 1646 | 0 | `bdinteg:`  ⚠️ext, `bdisuc:`  ⚠️ext | `bdinteg:`  ⚠️ext, `bdisuc:`  ⚠️ext |
| `sp_afecta_cajageneral` | 368 | 0 | `bdinteg:`  ⚠️ext, `bdisuc:`  ⚠️ext, `bdisuc:ss_cajageneral`  ⚠️ext | `bdisuc:`  ⚠️ext |
| `sp_altamodificacion_piezas_bym_web` | 629 | 0 | `bdinteg:`  ⚠️ext, `bdisuc:`  ⚠️ext | `bdisuc:`  ⚠️ext |
| `sp_arqueo_atm` | 53 | 0 | `bdisuc:ss_atm`  ⚠️ext, `bdisuc:ss_operaciones`  ⚠️ext | — |
| `sp_arqueoatms` | 127 | 0 | `bdinteg:si_sucursales`  ⚠️ext, `bdisuc:ss_corteadminview`  ⚠️ext, `bdisuc:ss_relacionccid`  ⚠️ext, `ss_operaciones` | — |
| `sp_arqueocedulacontable` | 171 | 0 | `bdisuc:`  ⚠️ext, `ss_reportecedula` | `ss_arqueo_panamericano` |
| `sp_arqueossuc` | 60 | 0 | — | `ss_saldossuc` |
| `sp_arqueossuc_atm` | 59 | 0 | — | `ss_saldossuc` |
| `sp_arqueossuc_atm_web` | 61 | 0 | — | `ss_saldossuc` |
| `sp_arqueossuc_web` | 60 | 0 | — | `ss_saldossuc` |
| `sp_atms` | 1683 | 0 | `SS_Param_cajagen`, `bdinteg:`  ⚠️ext, `bdinteg:si_sucursales`  ⚠️ext, `bdisuc:`  ⚠️ext, `bdisuc:ss_mae_entradasalida`  ⚠️ext, `bdisuc:ss_operaciones`  ⚠️ext | `bdisuc:`  ⚠️ext, `bdisuc:ss_mae_entradasalida`  ⚠️ext, `ss_atm`, `ss_atm_rec` |
| `sp_atms2` | 635 | 0 | `bdinteg:`  ⚠️ext, `bdisuc:`  ⚠️ext, `bdisuc:ss_mae_entradasalida`  ⚠️ext, `bdisuc:ss_operaciones`  ⚠️ext, `bdisuc:ss_proveedores`  ⚠️ext, `ss_param_cajagen` | `bdisuc:`  ⚠️ext, `bdisuc:ss_mae_entradasalida`  ⚠️ext, `ss_param_cajagen` |
| `sp_atms_web` | 227 | 0 | `bdinteg:si_sucursales`  ⚠️ext, `bdisuc:`  ⚠️ext, `ss_mae_entradasalida`, `ss_operaciones` | — |
| `sp_autenviocaja` | 713 | 0 | `bdinteg:`  ⚠️ext, `bdisuc:`  ⚠️ext | `bdisuc:`  ⚠️ext |
| `sp_autenviocajaras` | 565 | 0 | `bdinteg:`  ⚠️ext, `bdisuc:`  ⚠️ext | `bdisuc:`  ⚠️ext |
| `sp_autenviocajaras_web` | 558 | 0 | `bdinteg:`  ⚠️ext, `bdisuc:`  ⚠️ext | — |
| `sp_bitacora_atm` | 32 | 0 | `bdinteg:si_fechas`  ⚠️ext | `bdisuc:`  ⚠️ext |
| `sp_borrarcatdocumentos` | 273 | 0 | `bdinteg:si_sucursales`  ⚠️ext, `bdisuc:ss_catcardcarriers`  ⚠️ext, `bdisuc:ss_catdocumentos`  ⚠️ext, `bdisuc:ss_catstatusdoc`  ⚠️ext, `bdisuc:ss_cattipocarpeta`  ⚠️ext | `bdisuc:ss_catdocumentos`  ⚠️ext, `bdisuc:ss_cattipocarpeta`  ⚠️ext |
| `sp_borrarcattipocarpeta` | 236 | 0 | `bdinteg:si_sucursales`  ⚠️ext, `bdisuc:ss_catcardcarriers`  ⚠️ext, `bdisuc:ss_catstatusdoc`  ⚠️ext, `bdisuc:ss_cattipocarpeta`  ⚠️ext | `bdisuc:ss_cattipocarpeta`  ⚠️ext |

## Tablas compartidas (múltiples escritores) — riesgo de contención en parallel-run

- **`bdisuc:`**: escrita por `sp_cargaredtcat`, `sp_concensuc_web`, `sp_admon_documentos`, `reversion_sobrante`, `sp_actualizapieza_bym` ... y 29 más
- **`ss_param_cajagen`**: escrita por `sp_concensuc_web`, `pasecont`, `sp_consul_atm2`, `sp_atms`, `sp_concensuc` ... y 4 más
- **`bdisuc:ss_mae_entradasalida`**: escrita por `sp_consul_atm2`, `pasecont`, `sp_atms`, `sp_concen_atm`, `sp_atms2` ... y 1 más
- **`bdinteg:`**: escrita por `sp_actestatuscajacap`, `sp_admon_documentos`, `reversion_sobrante`, `sp_actestatuscajaras`, `sp_consestatuscaja` ... y 1 más
- **`bdicont:co_poliza`**: escrita por `pasecajag_esp`, `pasecajag`, `pasecajag_fec`, `gen_encab`, `pasecajag_pba`

## Tablas candidatas a CDC prioritario (Debezium / AWS DMS)

| Tabla | SPs escritores | Prioridad CDC |
|-------|---------------|---------------|
| `ss_param_cajagen` | `sp_concensuc_web`, `pasecont`, `sp_consul_atm2` | 🔴 PRIMERA |
| `ss_poliza` | `pasecajag_esp`, `pasecajag`, `pasecajag_fec` | 🟠 SEGUNDA |
| `ss_saldossuc` | `sp_arqueossuc_web`, `sp_arqueossuc_atm`, `sp_arqueossuc` | 🟠 SEGUNDA |
| `ss_operaciones` | `sp_atms`, `pasecont`, `sp_cancelar_solicitud_dota` | 🟠 SEGUNDA |
| `ss_atm` | `sp_atms`, `pasecont`, `sp_cancelar_solicitud_dota` | 🟠 SEGUNDA |
| `co_auditpase` | `manejacajageneral`, `auditapase` | 🟡 TERCERA |
| `co_detpol` | `manejacajageneral`, `auditapase` | 🟡 TERCERA |
| `co_poliza` | `manejacajageneral`, `auditapase` | 🟡 TERCERA |

## Tablas externas accedidas (cross-DB)

- `bdicont:` (R+W) — desde `pasecont_web_2`
- `bdicont:co_detpol` (R+W) — desde `pasecajag_esp`, `pasecajag`, `pasecajag_fec`
- `bdicont:co_fechas` (R) — desde `pasecont_web_2`, `sp_actualizapieza_bym`, `sp_consulta_catdenominacion_bym`
- `bdicont:co_histsdodias` (R) — desde `sp_actualizapieza_bym`, `sp_consulta_catdenominacion_bym`
- `bdicont:co_poldet` (R+W) — desde `pasecajag_esp`, `pasecajag`, `pasecont`
- `bdicont:co_poldet_20240518` (R) — desde `pasecont_web_2`, `sp_consulta_cajageneral`
- `bdicont:co_poliza` (R+W) — desde `pasecajag_esp`, `pasecajag`, `pasecajag_fec`
- `bdicont:co_sdodias` (R) — desde `sp_actualizapieza_bym`, `sp_consulta_catdenominacion_bym`
- `bdinteg:` (R+W) — desde `sp_admon_documentos`, `reversion_sobrante`, `sp_actualizapieza_bym`
- `bdinteg:si_catalog` (R) — desde `manejacajageneral`, `auditapase`
- `bdinteg:si_divisas` (R) — desde `consultacajageneral`, `consultacajageneral2`, `consultacajageneral2_totales`
- `bdinteg:si_ejecut` (R) — desde `pasecajag_esp`, `pasecajag`, `pasecajag_fec`
- `bdinteg:si_fechas` (R) — desde `sp_cargaredtcat`, `pasecajag`, `pasecajag_fec`
- `bdinteg:si_metales` (R) — desde `pasecont`
- `bdinteg:si_param` (R) — desde `pasecajag_esp`, `pasecajag`, `pasecajag_fec`
- `bdinteg:si_plazas` (R) — desde `pasecajag_esp`, `pasecajag`, `pasecajag_fec`
- `bdisuc:` (R+W) — desde `sp_cargaredtcat`, `sp_concensuc_web`, `sp_admon_documentos`
- `bdisuc:ss_atm` (R+W) — desde `sp_concen_crg_masiva`, `sp_cargaredtcat`, `sp_concen_atm`
- `bdisuc:ss_atms_sucursal` (R) — desde `sp_concen_atm`, `sp_cancelar_solicitud_dota`
- `bdisuc:ss_bitacora_corteadmin` (R+W) — desde `sp_cargaredtcat`
- `bdisuc:ss_cajageneral` (R) — desde `consultacajageneral`, `consultacajageneral2_totales`, `sp_afecta_cajageneral`
- `bdisuc:ss_catcardcarriers` (R) — desde `reversion_tombola`, `sp_borrarcattipocarpeta`, `sp_borrarcatdocumentos`
- `bdisuc:ss_catdocumentos` (R+W) — desde `reversion_tombola`, `sp_borrarcatdocumentos`
- `bdisuc:ss_catstatusdoc` (R) — desde `reversion_tombola`, `sp_borrarcattipocarpeta`, `sp_borrarcatdocumentos`
- `sysmaster:` (R) — desde `sp_actestatuscaja`, `sp_conscapacidadcaja`
- `sysmaster:sysshmvals` (R) — desde `sp_actestatuscajacap`, `sp_actestatuscaja`, `sp_actestatuscajaras`

---
*Generado por: Specialist — Informix SPL Analysis · 2026-07-03 · Evidencia: source/LegacyCore/informix/bdisuc_*.sql (análisis estático de 70 archivos SQL) · análisis estático de cláusulas FROM/INSERT/UPDATE/DELETE*

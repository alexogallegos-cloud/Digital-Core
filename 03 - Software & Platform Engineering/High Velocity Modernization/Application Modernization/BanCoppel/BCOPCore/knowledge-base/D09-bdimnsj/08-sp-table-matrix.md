# D09 · Mensajería — Matriz SP × Tabla (READ / WRITE)

> **Componente:** BCOPCore · SPE-AM-001 · Etapa 1
> **Base de datos:** `bdimnsj` · IBM Informix IDS 14.10 / POWER-AIX
> **Última actualización:** 2026-07-03

---
**SME responsable:**
- Specialist — Informix SPL Analysis (análisis estático)
- Domain Expert — BanCoppel / Mensajería (validación funcional)
- Architect — Application Modernization (diseño target EventBus/AsyncAPI)
- QA Lead — Equivalencia funcional (casos de prueba)

> Secciones `[SME-PENDING]` requieren sesión de validación antes de Etapa 2.
---


## Importancia para Etapa 2 (Data RE)

Esta matriz determina:
1. **Ownership de datos**: qué SP (y por ende qué microservicio target) es dueño de cada tabla
2. **Tablas compartidas**: múltiples SPs escriben → punto de contención → candidatas a patrón CQRS
3. **Prioridad CDC**: tablas con más escritores priorizan la configuración de Debezium
4. **Scope de migración**: tablas que solo leen SPs de código muerto pueden excluirse

> 🔄 = SP usa `EXECUTE PROCEDURE` dinámico — puede leer/escribir tablas adicionales no detectadas en el análisis estático.

## Resumen de tablas propias de `bdimnsj`

| Tabla | DB propietaria | Ownership | Lectores | Escritores |
|-------|---------------|-----------|----------|-----------|
| `12` | `bdimnsj` | 🟢 Solo lectura | 1 SPs | 0 SPs |
| `bdicheq` | `bdimnsj` | 🟢 Solo lectura | 9 SPs | 0 SPs |
| `bdicred` | `bdimnsj` | 🟢 Solo lectura | 9 SPs | 0 SPs |
| `bdimnsj` | `bdimnsj` | 🔴 25 SPs escriben | 26 SPs | 25 SPs |
| `bdinteg` | `bdimnsj` | 🟢 Solo lectura | 20 SPs | 0 SPs |
| `mnsj_cat_sinonimos` | `bdimnsj` | 🟢 Solo lectura | 1 SPs | 0 SPs |
| `mnsj_param` | `bdimnsj` | 🟢 Solo lectura | 7 SPs | 0 SPs |
| `mnsjr_bitacora_sms` | `bdimnsj` | 🟢 Solo lectura | 1 SPs | 0 SPs |
| `mnsjr_trx_online` | `bdimnsj` | 🟢 Solo lectura | 1 SPs | 0 SPs |
| `notif_cfg` | `bdimnsj` | 🟢 Solo lectura | 7 SPs | 0 SPs |
| `statistics` | `bdimnsj` | 🟠 2 SPs escriben | 0 SPs | 2 SPs |
| `stmt` | `bdimnsj` | 🟢 Solo lectura | 1 SPs | 0 SPs |
| `sysmaster` | `bdimnsj` | 🟢 Solo lectura | 1 SPs | 0 SPs |
| `table` | `bdimnsj` | 🟢 Solo lectura | 2 SPs | 0 SPs |
| `tblckpt` | `bdimnsj` | 🟢 **sp_monitor_ckpt** | 1 SPs | 1 SPs |
| `temp_mnsjr_bit_sms` | `bdimnsj` | 🟢 Solo lectura | 1 SPs | 0 SPs |

> **[SME-PENDING]** Para cada tabla: confirmar nombre exacto en producción, volumen de registros, política de retención, y si contiene datos PII (teléfonos, correos = datos personales bajo LFPDPPP).

## Matriz completa SP × Tabla

| SP | LOC | Fan-in | Tablas que LEE | Tablas que ESCRIBE |
|----|-----|--------|---------------|-------------------|
| `sp_validacion_msj` | 736 | 0 | `12`, `bdimnsj`, `bdinteg`, `mnsj_cat_sinonimos`, `sysmaster`, `table`, `bdinteg:si_cliente` ⚠️ext | `bdimnsj`, `bdinteg:si_telefonos` ⚠️ext |
| `sp_depura_mensajes` | 685 | 0 | `bdimnsj` | `bdimnsj` |
| `sp_registra_evento_tmp_spei` | 446 | 0 | `bdicheq`, `bdicred`, `bdimnsj`, `bdinteg`, `mnsj_param`, `notif_cfg`, `intercard:tarjeta` ⚠️ext | `bdimnsj` |
| `sp_registra_evento` | 445 | 1,404 | `bdicheq`, `bdicred`, `bdimnsj`, `bdinteg`, `mnsj_param`, `notif_cfg`, `intercard:tarjeta` ⚠️ext | `bdimnsj` |
| `sp_registra_evento_pru3` | 445 | 0 | `bdicheq`, `bdicred`, `bdimnsj`, `bdinteg`, `mnsj_param`, `notif_cfg`, `intercard:tarjeta` ⚠️ext | `bdimnsj` |
| `sp_suscriptores_act` | 403 | 0 | `bdimnsj`, `bdinteg` | `bdimnsj` |
| `sp_registra_evento_leo` | 361 | 0 | `bdicheq`, `bdicred`, `bdimnsj`, `bdinteg`, `mnsj_param`, `notif_cfg`, `intercard:tarjeta` ⚠️ext | — |
| `sp_registra_evento_prue2jjv` | 354 | 0 | `bdicheq`, `bdicred`, `bdinteg`, `mnsj_param`, `notif_cfg`, `intercard:tarjeta` ⚠️ext | `bdimnsj` |
| `sp_registra_evento_pruejjv` | 315 | 0 | `bdicheq`, `bdicred`, `bdinteg`, `mnsj_param`, `notif_cfg`, `intercard:tarjeta` ⚠️ext | `bdimnsj` |
| `sp_suscriptores_act_pba` | 306 | 0 | `bdimnsj`, `bdinteg` | `bdimnsj` |
| `sp_suscriptores_act_xfecha` | 294 | 0 | `bdimnsj`, `bdinteg` | `bdimnsj` |
| `sp_confirma_evento` | 272 | 0 | `bdimnsj`, `mnsj_param`, `notif_cfg`, `stmt` | `bdimnsj` | 🔄
| `sp_suscriptores_tmp` | 265 | 0 | `bdimnsj`, `bdinteg` | `bdimnsj` |
| `sp_suscriptores` | 264 | 0 | `bdimnsj`, `bdinteg` | `bdimnsj` |
| `sp_mover_mensajes` | 252 | 0 | `bdimnsj` | `bdimnsj` |
| `sp_genera_reporte_sms` | 247 | 0 | `bdimnsj`, `mnsjr_bitacora_sms`, `temp_mnsjr_bit_sms`, `bdinteg:si_ciudades` ⚠️ext, `bdinteg:si_estados` ⚠️ext, `bdinteg:si_ptf` ⚠️ext, `bdinteg:si_sucursales` ⚠️ext | `bdimnsj`, `statistics` |
| `sp_registra_evento2018` | 221 | 0 | `bdicheq`, `bdicred`, `bdimnsj`, `bdinteg`, `intercard:tarjeta` ⚠️ext | `bdimnsj` |
| `sp_recupera_saldo_inv` | 210 | 0 | `bdinteg` | — |
| `sp_chi_notifica_resultados` | 191 | 0 | `bdimnsj`, `bdicred:sd_fechas` ⚠️ext | `bdimnsj` |
| `sp_notifica_resultados` | 190 | 0 | `bdimnsj`, `bdicred:sd_fechas` ⚠️ext | `bdimnsj` |
| `sp_depura_ctetel_invalido` | 173 | 0 | `bdimnsj`, `bdinteg:si_telefonos_actual` ⚠️ext | `bdimnsj` |
| `sp_con_susc_ctes` | 169 | 0 | `bdicheq`, `bdicred`, `bdimnsj`, `bdinteg` | — |
| `sp_recupera_estatussolic` | 152 | 0 | `bdinteg:si_telefonos_actual` ⚠️ext | — |
| `sp_act_susc_ctes` | 141 | 0 | `bdimnsj` | — |
| `sp_depura_mnsjr_bitacora_sms` | 139 | 0 | `bdimnsj` | `bdimnsj` |
| `sp_registra_eventopba` | 137 | 0 | `bdicheq`, `bdicred`, `bdinteg`, `intercard:tarjeta` ⚠️ext | `bdimnsj` |
| `sp_confirma_evento_pba` | 127 | 0 | `bdimnsj` | `bdimnsj` |
| `sp_recupera_pago` | 115 | 0 | `table`, `bdinteg:si_telefonos_actual` ⚠️ext | — |
| `sp_generar_reporte_innovattia` | 107 | 0 | `bdimnsj` | — |
| `sp_registra_evento_prod` | 102 | 0 | `bdimnsj` | — |
| `sp_movregistroshist` | 101 | 0 | `bdinteg` | `bdimnsj` |
| `sp_monitoreo_sms` | 84 | 0 | — | — |
| `sp_recupera_saldo` | 84 | 0 | `bdinteg:si_telefonos_actual` ⚠️ext | — |
| `sp_confirmasmscte_bpi2` | 76 | 0 | `bdinteg` | — |
| `sp_registra_correotel` | 75 | 0 | `bdinteg:si_ctepf` ⚠️ext | — |
| `sp_actstatus_mnsj` | 73 | 0 | `bdimnsj` | `bdimnsj` |
| `sp_generaarch` | 69 | 0 | `bdimnsj` | `statistics` |
| `sp_monitor_ckpt` | 65 | 0 | `tblckpt`, `sysmaster:syscheckpoint` ⚠️ext | `tblckpt` |
| `sp_confirmasmscte_mvl` | 61 | 0 | `bdinteg` | — |
| `sp_registra_evento_bpi` | 59 | 0 | — | — |
| `sp_confirmasmscte_6dig` | 46 | 0 | `bdinteg` | — |
| `sp_confirmasmscte` | 45 | 0 | `bdinteg:si_bitsmstels` ⚠️ext | — |
| `sp_espacios_blancos2` | 42 | 0 | — | — |
| `sp_confirmasms` | 38 | 0 | `mnsjr_trx_online` | — |
| `sp_recupera_cuentatelefono` | 38 | 0 | `bdicheq:sc_cuenta_telefono` ⚠️ext | — |
| `sp_errormensaje` | 36 | 0 | — | `bdimnsj` |
| `sp_valida_esnumerico` | 36 | 0 | — | — |

## Tablas compartidas (múltiples escritores) — riesgo de contención

- **`bdimnsj`**: escrita por `sp_validacion_msj`, `sp_depura_mensajes`, `sp_registra_evento_tmp_spei`, `sp_registra_evento`, `sp_registra_evento_pru3`, `sp_suscriptores_act`, `sp_registra_evento_prue2jjv`, `sp_registra_evento_pruejjv`, `sp_suscriptores_act_pba`, `sp_suscriptores_act_xfecha`, `sp_confirma_evento`, `sp_suscriptores_tmp`, `sp_suscriptores`, `sp_mover_mensajes`, `sp_genera_reporte_sms`, `sp_registra_evento2018`, `sp_chi_notifica_resultados`, `sp_notifica_resultados`, `sp_depura_ctetel_invalido`, `sp_depura_mnsjr_bitacora_sms`, `sp_registra_eventopba`, `sp_confirma_evento_pba`, `sp_movregistroshist`, `sp_actstatus_mnsj`, `sp_errormensaje` — candidata a lock contention en parallel-run
- **`statistics`**: escrita por `sp_genera_reporte_sms`, `sp_generaarch` — candidata a lock contention en parallel-run


## Tablas candidatas a CDC prioritario

Las tablas con escrituras desde el SP público (`sp_registra_evento`) son las primeras a capturar con Debezium:

| Tabla | SP escritor | Prioridad CDC |
|-------|-------------|--------------|
| `bdimnsj` | `sp_registra_evento` | 🔴 PRIMERA | 


## Tablas externas accedidas por `bdimnsj`

- `bdicred:sd_fechas` — acceso de lectura desde `sp_chi_notifica_resultados`
- `bdinteg:si_bitsmstels` — acceso de lectura desde `sp_confirmasmscte`
- `bdinteg:si_telefonos_actual` — acceso de lectura desde `sp_depura_ctetel_invalido`
- `bdinteg:si_ciudades` — acceso de lectura desde `sp_genera_reporte_sms`
- `bdinteg:si_estados` — acceso de lectura desde `sp_genera_reporte_sms`
- `bdinteg:si_ptf` — acceso de lectura desde `sp_genera_reporte_sms`
- `bdinteg:si_sucursales` — acceso de lectura desde `sp_genera_reporte_sms`
- `sysmaster:syscheckpoint` — acceso de lectura desde `sp_monitor_ckpt`
- `bdicred:sd_fechas` — acceso de lectura desde `sp_notifica_resultados`
- `bdicheq:sc_cuenta_telefono` — acceso de lectura desde `sp_recupera_cuentatelefono`
- `bdinteg:si_telefonos_actual` — acceso de lectura desde `sp_recupera_estatussolic`
- `bdinteg:si_telefonos_actual` — acceso de lectura desde `sp_recupera_pago`
- `bdinteg:si_telefonos_actual` — acceso de lectura desde `sp_recupera_saldo`
- `bdinteg:si_ctepf` — acceso de lectura desde `sp_registra_correotel`
- `intercard:tarjeta` — acceso de lectura desde `sp_registra_evento`
- `intercard:tarjeta` — acceso de lectura desde `sp_registra_evento2018`
- `intercard:tarjeta` — acceso de lectura desde `sp_registra_evento_leo`
- `intercard:tarjeta` — acceso de lectura desde `sp_registra_evento_pru3`
- `intercard:tarjeta` — acceso de lectura desde `sp_registra_evento_prue2jjv`
- `intercard:tarjeta` — acceso de lectura desde `sp_registra_evento_pruejjv`
- `intercard:tarjeta` — acceso de lectura desde `sp_registra_evento_tmp_spei`
- `intercard:tarjeta` — acceso de lectura desde `sp_registra_eventopba`
- `bdinteg:si_cliente` — acceso de lectura desde `sp_validacion_msj`


---
*Generado por: Specialist — Informix SPL Analysis · 2026-07-03 · Evidencia: source/BCOPCore/informix/bdimnsj_*.sql (análisis estático de cláusulas FROM/INSERT/UPDATE/DELETE)*

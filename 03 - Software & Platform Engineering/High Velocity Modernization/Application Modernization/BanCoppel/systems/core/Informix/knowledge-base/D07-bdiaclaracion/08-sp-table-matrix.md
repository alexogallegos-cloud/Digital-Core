# D07 · Aclaraciones — Matriz SP × Tabla (READ / WRITE)

> **Componente:** BCOPCore · SPE-AM-001 · Etapa 1
> **Base de datos:** `bdiaclaracion` · IBM Informix IDS 14.10 / POWER-AIX
> **Wave:** Wave 2 · Riesgo: **ALTO**
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

## Resumen de tablas propias de `bdiaclaracion`

| Tabla | Tipo | Lectores | Escritores | Ownership |
|-------|------|----------|-----------|-----------|
| `acl_aclaracion` | Transaccional | 43 | 15 | 🔴 15 SPs escriben |
| `acl_producto` | Transaccional | 40 | 0 | 🟢 Solo lectura |
| `acl_movimiento` | Transaccional | 37 | 1 | 🟠 1 SPs escriben |
| `systables` | Transaccional | 37 | 0 | 🟢 Solo lectura |
| `acl_tipo_evento` | Transaccional | 37 | 0 | 🟢 Solo lectura |
| `acl_origen_evento` | Transaccional | 34 | 0 | 🟢 Solo lectura |
| `acl_tipo_producto` | Transaccional | 32 | 0 | 🟢 Solo lectura |
| `acl_estatus_corporativo` | Transaccional | 26 | 0 | 🟢 Solo lectura |
| `acl_usuario` | Transaccional | 22 | 3 | 🟠 3 SPs escriben |
| `acl_entrada_bitacora` | Log / Bitácora | 5 | 16 | 🔴 16 SPs escriben |
| `tblAclaraciones` | Transaccional | 10 | 10 | 🔴 10 SPs escriben |
| `acl_tipo_movimiento` | Transaccional | 20 | 0 | 🟢 Solo lectura |
| `acl_resolucion` | Transaccional | 17 | 0 | 🟢 Solo lectura |
| `temp_solic` | Transaccional | 8 | 7 | 🔴 7 SPs escriben |
| `acl_estatus_aclaracion` | Transaccional | 15 | 0 | 🟢 Solo lectura |
| `temp_respues` | Transaccional | 8 | 7 | 🔴 7 SPs escriben |
| `temp_aclara` | Transaccional | 8 | 7 | 🔴 7 SPs escriben |
| `bdiaclaracion` | Transaccional | 11 | 4 | 🟠 4 SPs escriben |
| `acl_rango_importe` | Transaccional | 12 | 0 | 🟢 Solo lectura |
| `TABLE` | Transaccional | 12 | 0 | 🟢 Solo lectura |

> **[SME-PENDING]** Confirmar nombre exacto en producción, volumen de registros, política de retención y campos PII con DBA BanCoppel.

## Matriz completa SP × Tabla

| SP | LOC | Fan-in | Tablas que LEE | Tablas que ESCRIBE |
|----|-----|--------|---------------|-------------------|
| `sp_buscar_movimientos_credito_his_canales` | 5103 | 0 | `acl_aclaracion`, `acl_asociacion_origen_evento_canal`, `acl_estatus_aclaracion`, `acl_estatus_canales`, `acl_estatus_corporativo`, `acl_movimiento` | `statistics`, `temp_aclara`, `temp_respues`, `temp_solic` |
| `sp_buscar_movimientos_credito_dia_canales` | 4779 | 0 | `acl_aclaracion`, `acl_asociacion_origen_evento_canal`, `acl_estatus_aclaracion`, `acl_estatus_canales`, `acl_estatus_corporativo`, `acl_movimiento` | `statistics`, `temp_aclara`, `temp_respues`, `temp_solic` |
| `sp_buscar_movimientos_cheques_dia_canales` | 4442 | 0 | `acl_aclaracion`, `acl_asociacion_origen_evento_canal`, `acl_estatus_aclaracion`, `acl_estatus_canales`, `acl_estatus_corporativo`, `acl_movimiento` | `statistics`, `temp_aclara`, `temp_respues`, `temp_solic` |
| `sp_buscar_movimientos_cheques_his_canales` | 4113 | 0 | `acl_aclaracion`, `acl_asociacion_origen_evento_canal`, `acl_estatus_aclaracion`, `acl_estatus_canales`, `acl_estatus_corporativo`, `acl_movimiento` | `statistics`, `temp_aclara`, `temp_respues`, `temp_solic` |
| `sp_buscar_movimientos_cheques_his_old_canales` | 3784 | 0 | `acl_aclaracion`, `acl_asociacion_origen_evento_canal`, `acl_estatus_aclaracion`, `acl_estatus_canales`, `acl_estatus_corporativo`, `acl_movimiento` | `statistics`, `temp_aclara`, `temp_respues`, `temp_solic` |
| `sp_buscar_movimientos_inversion_dia_canales` | 3134 | 0 | `acl_aclaracion`, `acl_asociacion_origen_evento_canal`, `acl_estatus_aclaracion`, `acl_estatus_canales`, `acl_estatus_corporativo`, `acl_movimiento` | `statistics`, `temp_aclara`, `temp_respues`, `temp_solic` |
| `sp_aplica_cierre_preventivo` | 1979 | 0 | `ACL_RECUPERACION_SALDOS`, `acl_aclaracion`, `acl_cat_tipo_aclaracion`, `acl_documento`, `acl_estatus_corporativo`, `acl_folio_aclaracion_acl_aclaracion` | `acl_aclaracion`, `acl_entrada_bitacora`, `acl_movimiento` |
| `sp_acl_validacion_abonoinmediato` | 1712 | 0 | `acl_aclaracion`, `acl_cierre_masivo`, `acl_estatus_aclaracion`, `acl_estatus_corporativo`, `acl_movimiento`, `acl_producto` | `acl_aclaracion`, `acl_cierre_masivo`, `acl_entrada_bitacora`, `bdiaclaracion:`  ⚠️ext |
| `sp_busca_datos_3410_mx` | 1667 | 0 | `acl_aclaracion`, `acl_estatus_aclaracion`, `acl_estatus_canales`, `acl_estatus_corporativo`, `acl_movimiento`, `acl_no_procedenterbt` | `statistics`, `temp_aclara`, `temp_respues`, `temp_solic` |
| `sp_buscaempleadohuella_alta` | 1379 | 0 | `acl_concentrado_robo_identidad`, `acl_entrada_bitacora`, `bdiaclaracion:acl_aclaracion`  ⚠️ext, `bdiaclaracion:acl_movimiento`  ⚠️ext, `bdicheq:sc_bloqueo`  ⚠️ext, `bdicheq:sc_mae_estatus`  ⚠️ext | — |
| `sp_acl_consulta_ciudades` | 1286 | 0 | `acl_concentrado_robo_identidad`, `acl_entrada_bitacora`, `bdiaclaracion:acl_aclaracion`  ⚠️ext, `bdiaclaracion:acl_movimiento`  ⚠️ext, `bdicheq:sc_bloqueo`  ⚠️ext, `bdicheq:sc_mae_estatus`  ⚠️ext | — |
| `sp_aplica_cierre_masivo` | 1013 | 2 | `acl_aclaracion`, `acl_cierre_masivo`, `acl_estatus_aclaracion`, `acl_estatus_corporativo`, `acl_movimiento`, `acl_producto` | `acl_aclaracion`, `acl_cierre_masivo`, `acl_entrada_bitacora` |
| `sp_bloqueocuenta_cred` | 974 | 0 | `acl_concentrado_robo_identidad`, `acl_entrada_bitacora`, `bdiaclaracion:acl_aclaracion`  ⚠️ext, `bdiaclaracion:acl_movimiento`  ⚠️ext, `bdicheq:sc_mae_estatus`  ⚠️ext, `bdicheq:sc_maechq`  ⚠️ext | — |
| `sp_bloqueo_cta_debito` | 918 | 0 | `acl_concentrado_robo_identidad`, `acl_entrada_bitacora`, `bdiaclaracion:acl_aclaracion`  ⚠️ext, `bdiaclaracion:acl_movimiento`  ⚠️ext, `bdicheq:sc_mae_estatus`  ⚠️ext, `bdicheq:sc_maechq`  ⚠️ext | — |
| `sp_aplica_validacion_msi` | 752 | 0 | `acl_aclaracion`, `acl_cierre_masivo`, `acl_estatus_aclaracion`, `acl_estatus_corporativo`, `acl_movimiento`, `acl_producto` | `acl_aclaracion`, `acl_cierre_masivo`, `acl_entrada_bitacora` |
| `sp_aplicar_cancelacion_por_recuperacion_creddeb` | 265 | 2 | `acl_aclaracion`, `acl_control_cuentas_pendientes_cancelar`, `acl_producto`, `acl_tipo_producto`, `bdiaclaracion:`  ⚠️ext, `bdiaclaracion:acl_usuario`  ⚠️ext | `bdiaclaracion:`  ⚠️ext |
| `sp_bloqueodesbloqueo_cuentas_por_recuperacion_creddeb` | 64 | 0 | `bdicheq:`  ⚠️ext | — |
| `sp_acl_actualizaempaclaracion` | 2018 | 0 | `acl_aclaracion`, `acl_movimiento`, `acl_origen_evento`, `acl_producto`, `acl_rango_importe`, `acl_resolucion` | `acl_entrada_bitacora`, `bdiaclaracion:`  ⚠️ext, `bdidomi:`  ⚠️ext, `tblAclaraciones` |
| `sp_acl_asosacionorigentransaccion` | 1412 | 0 | `TABLE`, `acl_aclaracion`, `acl_cat_bines`, `acl_cat_datosnoconv`, `acl_cat_tokenPY`, `acl_estatus_corporativo` | `acl_aclaracion` |
| `sp_acl_busca_cliente_sv` | 951 | 0 | `bdiaclaracion:`  ⚠️ext, `bdiaclaracion:acl_aclaracion`  ⚠️ext, `bdiaclaracion:acl_movimiento`  ⚠️ext, `bdiaclaracion:acl_origen_evento`  ⚠️ext, `bdiaclaracion:acl_producto`  ⚠️ext, `bdiaclaracion:acl_tipo_evento`  ⚠️ext | `bdiaclaracion:`  ⚠️ext, `bdiaclaracion:acl_movimiento`  ⚠️ext |
| `sp_acl_busca_datos_3410_fda` | 2171 | 0 | `TABLE`, `acl_aclaracion`, `acl_cat_bines`, `acl_cat_datosnoconv`, `acl_cat_tokenPY`, `acl_estatus_corporativo` | `acl_aclaracion`, `bdiaclaracion` |
| `sp_acl_consulta_ciudad_estado_formobjeccion` | 259 | 0 | `acl_aclaracion`, `acl_resolucion`, `bdiaclaracion:`  ⚠️ext, `bdiaclaracion:acl_perfil`  ⚠️ext, `bdiaclaracion:acl_perfil_usuario`  ⚠️ext, `bdiaclaracion:acl_usuario`  ⚠️ext | `acl_entrada_bitacora`, `acl_notificacion_det` |
| `sp_acl_consulta_perfil_usuario` | 211 | 0 | `acl_aclaracion`, `acl_resolucion`, `bdiaclaracion:`  ⚠️ext, `bdiaclaracion:acl_perfil`  ⚠️ext, `bdiaclaracion:acl_perfil_usuario`  ⚠️ext, `bdiaclaracion:acl_usuario`  ⚠️ext | `acl_entrada_bitacora`, `acl_notificacion_det` |
| `sp_acl_consultadevolucion` | 1989 | 0 | `TABLE`, `acl_aclaracion`, `acl_cat_bines`, `acl_cat_datosnoconv`, `acl_cat_tokenPY`, `acl_estatus_corporativo` | `acl_aclaracion` |
| `sp_acl_consultafectacion` | 1916 | 0 | `TABLE`, `acl_aclaracion`, `acl_cat_bines`, `acl_cat_datosnoconv`, `acl_cat_tokenPY`, `acl_estatus_corporativo` | `acl_aclaracion` |
| `sp_acl_consultatipoeventosabono` | 1444 | 0 | `TABLE`, `acl_aclaracion`, `acl_cat_bines`, `acl_cat_datosnoconv`, `acl_cat_tokenPY`, `acl_estatus_corporativo` | `acl_aclaracion` |
| `sp_acl_es_cliente_sv` | 422 | 0 | `acl_aclaracion`, `acl_producto`, `acl_reporte_evidencia_3410`, `acl_tipo_movimiento`, `acl_tipo_producto`, `bdicheq:sc_movdia`  ⚠️ext | `acl_reporte_evidencia_3410` |
| `sp_acl_insertalog` | 1678 | 0 | `acl_aclaracion`, `acl_movimiento`, `acl_origen_evento`, `acl_producto`, `acl_rango_importe`, `acl_resolucion` | `acl_entrada_bitacora`, `bdiaclaracion:`  ⚠️ext, `bdidomi:`  ⚠️ext, `tblAclaraciones` |
| `sp_acl_montototal_sv` | 874 | 0 | `bdiaclaracion:`  ⚠️ext, `bdiaclaracion:acl_aclaracion`  ⚠️ext, `bdiaclaracion:acl_movimiento`  ⚠️ext, `bdiaclaracion:acl_origen_evento`  ⚠️ext, `bdiaclaracion:acl_producto`  ⚠️ext, `bdiaclaracion:acl_tipo_evento`  ⚠️ext | `bdiaclaracion:`  ⚠️ext, `bdiaclaracion:acl_movimiento`  ⚠️ext |
| `sp_acl_obtenerlogpreguntas` | 2187 | 0 | `acl_aclaracion`, `acl_movimiento`, `acl_origen_evento`, `acl_producto`, `acl_rango_importe`, `acl_resolucion` | `acl_entrada_bitacora`, `bdiaclaracion:`  ⚠️ext, `bdidomi:`  ⚠️ext, `tblAclaraciones` |
| `sp_acl_obtenernombreestados` | 2058 | 0 | `acl_aclaracion`, `acl_movimiento`, `acl_origen_evento`, `acl_producto`, `acl_rango_importe`, `acl_resolucion` | `acl_entrada_bitacora`, `bdiaclaracion:`  ⚠️ext, `bdidomi:`  ⚠️ext, `tblAclaraciones` |
| `sp_acl_obtenerpreguntasiniciosesion` | 1988 | 0 | `acl_aclaracion`, `acl_movimiento`, `acl_origen_evento`, `acl_producto`, `acl_rango_importe`, `acl_resolucion` | `acl_entrada_bitacora`, `bdiaclaracion:`  ⚠️ext, `bdidomi:`  ⚠️ext, `tblAclaraciones` |
| `sp_acl_regulatorio27` | 265 | 0 | `acl_aclaracion`, `acl_estatus_aclaracion`, `acl_estatus_corporativo`, `acl_movimiento`, `acl_origen_evento`, `acl_producto` | `acl_regulatorio27` |
| `sp_acl_regulatorio27_mx` | 252 | 0 | `acl_aclaracion`, `acl_estatus_aclaracion`, `acl_estatus_corporativo`, `acl_movimiento`, `acl_origen_evento`, `acl_producto` | `acl_regulatorio27` |
| `sp_acl_reporte_log` | 1555 | 0 | `TABLE`, `acl_aclaracion`, `acl_cat_bines`, `acl_cat_datosnoconv`, `acl_cat_tokenPY`, `acl_estatus_corporativo` | `acl_aclaracion` |
| `sp_acl_transacc_movs_origen` | 835 | 0 | `bdiaclaracion:`  ⚠️ext, `bdiaclaracion:acl_aclaracion`  ⚠️ext, `bdiaclaracion:acl_movimiento`  ⚠️ext, `bdiaclaracion:acl_origen_evento`  ⚠️ext, `bdiaclaracion:acl_producto`  ⚠️ext, `bdiaclaracion:acl_tipo_evento`  ⚠️ext | `bdiaclaracion:`  ⚠️ext, `bdiaclaracion:acl_movimiento`  ⚠️ext |
| `sp_acl_valida_dfa_devo` | 1875 | 0 | `TABLE`, `acl_aclaracion`, `acl_cat_bines`, `acl_cat_datosnoconv`, `acl_cat_tokenPY`, `acl_estatus_corporativo` | `acl_aclaracion` |
| `sp_acl_validarnumerorespuestas` | 1873 | 0 | `acl_aclaracion`, `acl_movimiento`, `acl_origen_evento`, `acl_producto`, `acl_rango_importe`, `acl_resolucion` | `acl_entrada_bitacora`, `bdiaclaracion:`  ⚠️ext, `bdidomi:`  ⚠️ext, `tblAclaraciones` |
| `sp_acl_validarpreguntasautenticacion` | 1774 | 0 | `acl_aclaracion`, `acl_movimiento`, `acl_origen_evento`, `acl_producto`, `acl_rango_importe`, `acl_resolucion` | `acl_entrada_bitacora`, `bdiaclaracion:`  ⚠️ext, `bdidomi:`  ⚠️ext, `tblAclaraciones` |
| `sp_acl_validarpreguntasiniciosesion` | 793 | 0 | `bdiaclaracion:`  ⚠️ext, `bdiaclaracion:acl_aclaracion`  ⚠️ext, `bdiaclaracion:acl_movimiento`  ⚠️ext, `bdiaclaracion:acl_origen_evento`  ⚠️ext, `bdiaclaracion:acl_producto`  ⚠️ext, `bdiaclaracion:acl_tipo_evento`  ⚠️ext | `bdiaclaracion:`  ⚠️ext, `bdiaclaracion:acl_movimiento`  ⚠️ext |
| `sp_actualiza_estatus_acl_eglobal_respondida` | 39 | 0 | `acl_aclaracion` | — |
| `sp_actualiza_folio_error_cierre` | 111 | 0 | `bdinteg:si_sucursales`  ⚠️ext | — |
| `sp_actualiza_monto_movimiento` | 24 | 0 | — | `bdiaclaracion:acl_movimiento`  ⚠️ext |
| `sp_aplica_credito_smartvista` | 681 | 0 | `bdiaclaracion:`  ⚠️ext, `bdiaclaracion:acl_aclaracion`  ⚠️ext, `bdiaclaracion:acl_movimiento`  ⚠️ext, `bdiaclaracion:acl_origen_evento`  ⚠️ext, `bdiaclaracion:acl_producto`  ⚠️ext, `bdiaclaracion:acl_tipo_evento`  ⚠️ext | `bdiaclaracion:`  ⚠️ext, `bdiaclaracion:acl_movimiento`  ⚠️ext |
| `sp_bitacora_siem` | 2414 | 0 | `TABLE`, `acl_aclaracion`, `acl_bitacora_cambio_pass`, `acl_bitacora_eventos_siem`, `acl_cat_bines`, `acl_cat_datosnoconv` | `acl_aclaracion`, `acl_bitacora_cambio_pass`, `acl_bitacora_eventos_siem`, `acl_usuario` |
| `sp_bitacorasistema` | 463 | 0 | `acl_aclaracion`, `acl_producto`, `acl_regla_negocio`, `bdiaclaracion:`  ⚠️ext, `bdinteg:`  ⚠️ext, `bdinteg:si_ctepf`  ⚠️ext | `bdiaclaracion:`  ⚠️ext, `bdiaclaracion:acl_aclaracion`  ⚠️ext, `bdiaclaracion:acl_movimiento`  ⚠️ext, `bdiaclaracion:acl_recuperacion_saldos`  ⚠️ext |
| `sp_busca_acl_por_folio_canales` | 1068 | 0 | `BDINTEG:`  ⚠️ext, `acl_aclaracion`, `acl_control_r27`, `acl_estatus_aclaracion`, `acl_folio_Aclaracion`, `acl_folio_aclaracion_acl_aclaracion` | `bdiaclaracion:`  ⚠️ext |
| `sp_busca_aclaraciones_canales` | 1431 | 0 | `BDINTEG:`  ⚠️ext, `acl_aclaracion`, `acl_control_r27`, `acl_documento`, `acl_estatus_aclaracion`, `acl_estatus_corporativo` | `bdiaclaracion:`  ⚠️ext |
| `sp_busca_aclaraciones_gerente` | 383 | 0 | `acl_cat_tipo_aclaracion`, `acl_usuario`, `bdinteg:si_ciudades`  ⚠️ext, `bdinteg:si_direcciones_actual`  ⚠️ext, `bdinteg:si_ejecut`  ⚠️ext, `bdinteg:si_estados`  ⚠️ext | — |
| `sp_busca_aclaraciones_promotor` | 331 | 0 | `acl_cat_tipo_aclaracion`, `acl_usuario`, `bdinteg:si_ciudades`  ⚠️ext, `bdinteg:si_direcciones_actual`  ⚠️ext, `bdinteg:si_ejecut`  ⚠️ext, `bdinteg:si_estados`  ⚠️ext | — |

## Tablas compartidas (múltiples escritores) — riesgo de contención en parallel-run

- **`bdiaclaracion:`**: escrita por `sp_acl_obtenerlogpreguntas`, `sp_acl_transacc_movs_origen`, `sp_aplica_credito_smartvista`, `sp_bitacorasistema`, `sp_aplicar_cancelacion_por_recuperacion_creddeb` ... y 13 más
- **`acl_entrada_bitacora`**: escrita por `sp_acl_obtenerlogpreguntas`, `sp_aplica_cierre_preventivo`, `sp_acl_validacion_abonoinmediato`, `sp_acl_consulta_perfil_usuario`, `sp_busca_producto_cred_cliente_crd` ... y 11 más
- **`acl_aclaracion`**: escrita por `sp_busca_producto_cred_tarjeta`, `sp_aplica_cierre_preventivo`, `sp_acl_consultadevolucion`, `sp_acl_asosacionorigentransaccion`, `sp_busca_producto_cred_cliente` ... y 10 más
- **`bdidomi:`**: escrita por `sp_acl_obtenerlogpreguntas`, `sp_busca_cte_domiciliacion`, `sp_busca_producto_cred_cliente_crd`, `sp_acl_actualizaempaclaracion`, `sp_acl_obtenernombreestados` ... y 6 más
- **`tblAclaraciones`**: escrita por `sp_acl_obtenerlogpreguntas`, `sp_busca_producto_cred_cliente_crd`, `sp_acl_actualizaempaclaracion`, `sp_acl_obtenernombreestados`, `sp_acl_validarpreguntasautenticacion` ... y 5 más

## Tablas candidatas a CDC prioritario (Debezium / AWS DMS)

| Tabla | SPs escritores | Prioridad CDC |
|-------|---------------|---------------|
| `acl_entrada_bitacora` | `sp_acl_obtenerlogpreguntas`, `sp_aplica_cierre_preventivo`, `sp_acl_validacion_abonoinmediato` | 🔴 PRIMERA |
| `acl_aclaracion` | `sp_busca_producto_cred_tarjeta`, `sp_aplica_cierre_preventivo`, `sp_acl_consultadevolucion` | 🔴 PRIMERA |
| `tblAclaraciones` | `sp_acl_obtenerlogpreguntas`, `sp_busca_producto_cred_cliente_crd`, `sp_acl_actualizaempaclaracion` | 🔴 PRIMERA |
| `temp_aclara` | `sp_buscar_movimientos_cheques_his_canales`, `sp_buscar_movimientos_inversion_dia_canales`, `sp_buscar_movimientos_cheques_his_old_canales` | 🔴 PRIMERA |
| `temp_solic` | `sp_buscar_movimientos_cheques_his_canales`, `sp_buscar_movimientos_inversion_dia_canales`, `sp_buscar_movimientos_cheques_his_old_canales` | 🔴 PRIMERA |
| `temp_respues` | `sp_buscar_movimientos_cheques_his_canales`, `sp_buscar_movimientos_inversion_dia_canales`, `sp_buscar_movimientos_cheques_his_old_canales` | 🔴 PRIMERA |
| `statistics` | `sp_buscar_movimientos_cheques_his_canales`, `sp_buscar_movimientos_inversion_dia_canales`, `sp_buscar_movimientos_cheques_his_old_canales` | 🔴 PRIMERA |
| `bdiaclaracion` | `sp_bitacora_siem`, `sp_acl_busca_datos_3410_fda`, `sp_busca_producto_cred_tarjeta` | 🟠 SEGUNDA |

## Tablas externas accedidas (cross-DB)

- `BDINTEG:` (R) — desde `sp_busca_acl_por_folio_canales`, `sp_busca_aclaraciones_canales`
- `bdiaclaracion:` (R+W) — desde `sp_bitacorasistema`, `sp_acl_consulta_perfil_usuario`, `sp_aplicar_cancelacion_por_recuperacion_creddeb`
- `bdiaclaracion:acl_aclaracion` (R+W) — desde `sp_acl_transacc_movs_origen`, `sp_bitacorasistema`, `sp_acl_consulta_ciudades`
- `bdiaclaracion:acl_bitacora_fda_3410` (R) — desde `sp_acl_consultadevolucion`, `sp_busca_producto_cred_cliente`, `sp_bitacora_siem`
- `bdiaclaracion:acl_entrada_bitacora` (R+W) — desde `sp_acl_valida_dfa_devo`, `sp_acl_consultadevolucion`, `sp_acl_busca_datos_3410_fda`
- `bdiaclaracion:acl_estatus_aclaracion` (R) — desde `sp_acl_validacion_abonoinmediato`
- `bdiaclaracion:acl_estatus_corporativo` (R) — desde `sp_acl_validacion_abonoinmediato`
- `bdiaclaracion:acl_movimiento` (R+W) — desde `sp_acl_transacc_movs_origen`, `sp_bitacorasistema`, `sp_actualiza_monto_movimiento`
- `bdiaclaracion:acl_origen_evento` (R) — desde `sp_busca_producto_cred_tarjeta`, `sp_acl_transacc_movs_origen`, `sp_acl_consultadevolucion`
- `bdicheq:` (R) — desde `sp_busca_nombre_core`, `sp_bloqueodesbloqueo_cuentas_por_recuperacion_creddeb`, `sp_aplicar_cancelacion_por_recuperacion_creddeb`
- `bdicheq:sc_bloqueo` (R) — desde `sp_buscaempleadohuella_alta`, `sp_acl_consulta_ciudades`
- `bdicheq:sc_mae_estatus` (R) — desde `sp_buscaempleadohuella_alta`, `sp_bloqueocuenta_cred`, `sp_acl_consulta_ciudades`
- `bdicheq:sc_maechq` (R) — desde `sp_busca_producto_transfer_telefono`, `sp_busca_nombre_core`, `sp_busca_producto_transfer_cliente`
- `bdicheq:sc_maenoc` (R) — desde `sp_buscaempleadohuella_alta`, `sp_bloqueocuenta_cred`, `sp_acl_consulta_ciudades`
- `bdicheq:sc_movdia` (R) — desde `sp_acl_es_cliente_sv`, `sp_buscar_movimientos_credito_dia_canales`, `sp_buscaqueda_folio_csuac`
- `bdicheq:sc_movhis` (R) — desde `sp_acl_es_cliente_sv`, `sp_buscar_movimientos_cheques_his_canales`, `sp_buscaqueda_folio_csuac`
- `bdicheq:sc_movhis_old` (R) — desde `sp_buscar_movimientos_credito_dia_canales`, `sp_buscar_movimientos_cheques_his_canales`, `sp_buscar_movimientos_cheques_his_old_canales`
- `bdicred:` (R+W) — desde `sp_buscaqueda_folio_csuac`, `sp_busca_producto_cred_tarjeta`, `sp_busca_producto_cred_cliente`
- `bdicred:sd_bloqueoscuenta` (R) — desde `sp_buscaempleadohuella_alta`, `sp_acl_consulta_ciudades`
- `bdicred:sd_causa_bloqueo` (R) — desde `sp_buscaempleadohuella_alta`, `sp_acl_consulta_ciudades`
- `bdicred:sd_definicion` (R) — desde `sp_acl_obtenerlogpreguntas`, `sp_busca_producto_cred_cliente`, `sp_busca_producto_cred_cliente_crd`
- `bdicred:sd_maecred` (R) — desde `sp_acl_obtenerlogpreguntas`, `sp_acl_actualizaempaclaracion`, `sp_acl_validarpreguntasautenticacion`
- `bdicred:sd_maecredcrd` (R) — desde `sp_acl_obtenerlogpreguntas`, `sp_busca_producto_cred_cliente_crd`, `sp_acl_actualizaempaclaracion`
- `bdicred:sd_maesdos` (R) — desde `sp_aplicar_cancelacion_por_recuperacion_creddeb`
- `bdicred:sd_movdia` (R) — desde `sp_acl_es_cliente_sv`, `sp_buscar_movimientos_credito_dia_canales`, `sp_buscaqueda_folio_csuac`
- `bdidomi:` (R+W) — desde `sp_acl_obtenerlogpreguntas`, `sp_busca_cte_domiciliacion`, `sp_busca_producto_cred_cliente_crd`
- `bdimnsj:mnsjr_trx_online` (R) — desde `sp_buscaempleadohuella_alta`, `sp_bloqueocuenta_cred`, `sp_acl_consulta_ciudades`
- `bdimnsj:mnsjr_trx_online_his` (R) — desde `sp_buscaempleadohuella_alta`, `sp_bloqueocuenta_cred`, `sp_acl_consulta_ciudades`
- `bdinteg:` (R) — desde `sp_acl_obtenerlogpreguntas`, `sp_acl_es_cliente_sv`, `sp_aplica_cierre_preventivo`
- `bdinteg:si_catcalles` (R) — desde `sp_busca_producto_transfer_telefono`, `sp_acl_obtenerlogpreguntas`, `sp_buscar_movimientos_cheques_his_canales`
- `bdinteg:si_catzonas` (R) — desde `sp_busca_producto_transfer_telefono`, `sp_acl_obtenerlogpreguntas`, `sp_buscar_movimientos_cheques_his_canales`
- `bdinteg:si_ciudades` (R) — desde `sp_buscaempleadohuella_alta`, `sp_buscaempleadohuella`, `sp_busca_aclaraciones_gerente`
- `bdinteg:si_cliente` (R) — desde `sp_busca_producto_transfer_telefono`, `sp_busca_nombre_core`, `sp_buscar_movimientos_cheques_his_canales`
- `bdinteg:si_correos` (R) — desde `sp_busca_producto_transfer_telefono`, `sp_acl_obtenerlogpreguntas`, `sp_buscar_movimientos_cheques_his_canales`
- `bdinteg:si_credito_sv` (R) — desde `sp_acl_es_cliente_sv`, `sp_acl_transacc_movs_origen`, `sp_acl_validarpreguntasiniciosesion`
- `bdinteg:si_ctepf` (R) — desde `sp_busca_producto_transfer_telefono`, `sp_acl_obtenerlogpreguntas`, `sp_buscar_movimientos_cheques_his_canales`
- `bdinvers:` (R) — desde `sp_busca_nombre_core`
- `bdinvers:sv_instrum` (R) — desde `sp_busca_productos_catalogo`
- `bdinvers:sv_maeinv` (R) — desde `sp_buscaempleadohuella_alta`, `sp_busca_producto_cred_cliente`, `sp_bloqueocuenta_cred`
- `bdinvers:sv_movdia` (R) — desde `sp_acl_es_cliente_sv`, `sp_buscar_movimientos_cheques_his_canales`, `sp_buscaqueda_folio_csuac`
- `bdinvers:sv_movhis` (R) — desde `sp_acl_es_cliente_sv`, `sp_buscar_movimientos_cheques_his_canales`, `sp_buscaqueda_folio_csuac`
- `bditarjeta:td_movimientos_conciliacion` (R) — desde `sp_acl_valida_dfa_devo`, `sp_acl_consultadevolucion`, `sp_acl_busca_datos_3410_fda`
- `bditransfer:tf_maecte` (R) — desde `sp_busca_producto_transfer_telefono`, `sp_busca_nombre_core`, `sp_busca_producto_deb_cheq_cliente`
- `intercard:` (R) — desde `sp_acl_es_cliente_sv`, `sp_buscaqueda_folio_csuac`, `sp_busca_producto_cred_tarjeta`
- `intercard:bines` (R) — desde `sp_busca_aclaraciones_promotor`, `sp_buscaempleadohuella`, `sp_busca_aclaraciones_gerente`
- `intercard:binproducto` (R) — desde `sp_busca_producto_cred_tarjeta`, `sp_busca_producto_cred_cuenta`, `sp_aplica_validacion_msi`
- `intercard:bit_pinoffline` (R) — desde `sp_buscar_movimientos_cheques_his_canales`, `sp_buscaqueda_folio_csuac`, `sp_buscar_movimientos_cheques_his_old_canales`
- `intercard:bitacora_fda` (R) — desde `sp_busca_producto_cred_tarjeta`, `sp_acl_consultadevolucion`, `sp_acl_asosacionorigentransaccion`
- `intercard:bitacoracambiosstatustarjeta` (R) — desde `sp_buscar_movimientos_cheques_his_canales`, `sp_buscaqueda_folio_csuac`, `sp_buscar_movimientos_cheques_his_old_canales`
- `intercard:bitacoracambiostarjeta` (R) — desde `sp_buscar_movimientos_cheques_his_canales`, `sp_buscar_movimientos_cheques_his_old_canales`, `sp_acl_reporte_log`
- `intercard:bitacoracancelaciontarjetas` (R) — desde `sp_acl_es_cliente_sv`, `sp_buscaqueda_folio_csuac`

---
*Generado por: Specialist — Informix SPL Analysis · 2026-07-03 · Evidencia: source/BCOPCore/informix/bdiaclaracion_*.sql (análisis estático de 70 archivos SQL) · análisis estático de cláusulas FROM/INSERT/UPDATE/DELETE*

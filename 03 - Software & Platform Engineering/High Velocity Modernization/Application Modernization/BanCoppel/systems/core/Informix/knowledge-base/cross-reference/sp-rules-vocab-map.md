> **Componente:** Informix · SPE-AM-001 · Etapa 3 — Cross-Reference KB · Generado: 2026-08-02

# SP — Reglas — Vocabulario: Mapa Central

Mapa cruzado de los procedimientos almacenados con mayor concentración de conocimiento de negocio, indexado por categoría funcional y por regulador. La densidad de conocimiento se calcula como: `rule_count × 2 + vocab_terms_únicos × 3 + fan_in / 100`.

---

## Sección A — Top 100 SPs por Densidad de Conocimiento

Ordenados por densidad descendente. Para cada SP se muestra el perfil completo de reglas, vocabulario referenciado y posición en el callgraph.

#### `sp_mueve_aclaraciones_historico` · bdiaclaracion · D07

- **Reglas**: 107 (tipos: FÓRMULA 107)
- **Categoría dominante**: REGULATORIO
- **Reguladores**: CNBV, CONDUSEF
- **Riesgo equiv.**: no
- **Vocabulario** (8 términos únicos): aclaraciones (aclaraciones (proceso de disputas/reclamaciones de cliente)), aclaracion (aclaración bancaria — proceso de disputa o reclamación del cliente), bitacora (bitácora), recuperacion (recuperación (cobranza)), respuesta, solicitud, movimiento, sistema
- **Explicación representativa**: Fórmula: aclaraciones (proceso de disputas/reclamaciones de cliente) · aclaración bancaria — proceso de disputa o reclamación del cliente (conf: formula)
- **Llamado por** (fan_in=0, top 3 de 0): —
- **Llama a** (top 3 de 1): `sp_registra_evento`

#### `sp_envio_camp_ctes_ctaspzo` · bdicobranza · D11

- **Reglas**: 40 (tipos: FÓRMULA 40)
- **Categoría dominante**: REGULATORIO
- **Reguladores**: CNBV
- **Riesgo equiv.**: no
- **Vocabulario** (2 términos únicos): numcte (número de cliente), fecha
- **Explicación representativa**: CUB CNBV (conf: norma)
- **Llamado por** (fan_in=0, top 3 de 0): —
- **Llama a** (top 3 de 1): `sp_registra_evento`

#### `sp_envio_camp_ctes_ctasrev` · bdicobranza · D11

- **Reglas**: 38 (tipos: FÓRMULA 38)
- **Categoría dominante**: REGULATORIO
- **Reguladores**: CNBV
- **Riesgo equiv.**: no
- **Vocabulario** (2 términos únicos): numcte (número de cliente), fecha
- **Explicación representativa**: CUB CNBV (conf: norma)
- **Llamado por** (fan_in=0, top 3 de 0): —
- **Llama a** (top 3 de 1): `sp_registra_evento`

#### `sp_txrechazo` · intercard · intercard

- **Reglas**: 20 (tipos: FÓRMULA 20)
- **Categoría dominante**: CALCULO_FINANCIERO
- **Reguladores**: —
- **Riesgo equiv.**: no
- **Vocabulario** (9 términos únicos): captura, monto, periodo, producto, descripcion (descripción), fecha, tarjeta, nombre, comercio (comercio afiliado)
- **Explicación representativa**: Cálculo con umbral/factor 10 (conf: formula)
- **Llamado por** (fan_in=0, top 3 de 0): —
- **Llama a** (top 3 de 0): —

#### `sp_geninsumos_calif_parte` · bdicred · D03

- **Reglas**: 21 (tipos: FÓRMULA 20, UMBRAL 1)
- **Categoría dominante**: REGULATORIO
- **Reguladores**: CNBV, SAT
- **Riesgo equiv.**: sí
- **Vocabulario** (8 términos únicos): modificacion (modificación), primer, modifica, corte (corte (fecha de corte / período)), diario, saldo, activos, cambio (cambio (de estatus, domicilio, etc.))
- **Explicación representativa**: Criterios contables CNBV + GAT (conf: norma)
- **Llamado por** (fan_in=0, top 3 de 0): —
- **Llama a** (top 3 de 0): —

#### `sp_bedito_rechazo` · intercard · intercar

- **Reglas**: 15 (tipos: FÓRMULA 15)
- **Categoría dominante**: CALCULO_FINANCIERO
- **Reguladores**: —
- **Riesgo equiv.**: no
- **Vocabulario** (11 términos únicos): captura, producto, fecha, motivo (motivo / causa), tarjeta, monto, origen, cliente, saldo, hora (+1 más)
- **Explicación representativa**: Fórmula: captura · producto · fecha (conf: formula)
- **Llamado por** (fan_in=0, top 3 de 0): —
- **Llama a** (top 3 de 0): —

#### `generaestadosdecuenta` · bdicred · D03

- **Reglas**: 31 (tipos: FÓRMULA 29, UMBRAL 2)
- **Categoría dominante**: REGULATORIO
- **Reguladores**: CNBV, CONDUSEF, SAT
- **Riesgo equiv.**: sí
- **Vocabulario**: —
- **Explicación representativa**: Criterios contables CNBV + GAT (conf: norma)
- **Llamado por** (fan_in=10, top 3 de 0): —
- **Llama a** (top 3 de 3): `abono_ref`, `sp_generafolionomina`, `reversion`

#### `sp_txrechazo_pba` · intercard · intercar

- **Reglas**: 20 (tipos: FÓRMULA 20)
- **Categoría dominante**: CALCULO_FINANCIERO
- **Reguladores**: —
- **Riesgo equiv.**: no
- **Vocabulario** (7 términos únicos): captura, monto, periodo, producto, descripcion (descripción), fecha, tarjeta
- **Explicación representativa**: Cálculo con umbral/factor 10 (conf: formula)
- **Llamado por** (fan_in=0, top 3 de 0): —
- **Llama a** (top 3 de 0): —

#### `determina_lincred_tc_cjunk` · bdisolic · D06

- **Reglas**: 18 (tipos: FÓRMULA 18)
- **Categoría dominante**: CALCULO_FINANCIERO
- **Reguladores**: CNBV
- **Riesgo equiv.**: sí
- **Vocabulario** (5 términos únicos): tasa (tasa (de interés)), interes (interés), calculo (cálculo), plazo (plazo (depósito / crédito a plazo)), producto
- **Explicación representativa**: Cálculo con umbral/factor 10 (conf: formula)
- **Llamado por** (fan_in=208, top 3 de 200): `califica_scoring2_cjunk`, `sp_sw_ro_ofiocioalta`, `ins_consulta_buro2_motor_pp`
- **Llama a** (top 3 de 2): `sp_obtienegrupo`, `sp_obtiene_tasa_int_diferenciadas`
- **Perfil funcional profundo**: [D06-bdisolic/sp-profile-determina_lincred_tc_cjunk.md](../D06-bdisolic/sp-profile-determina_lincred_tc_cjunk.md)

#### `provisionlineacred_parte` · bdicred · D03

- **Reglas**: 23 (tipos: FÓRMULA 22, VALIDACIÓN 1)
- **Categoría dominante**: REGULATORIO
- **Reguladores**: CNBV
- **Riesgo equiv.**: sí
- **Vocabulario** (2 términos únicos): modificacion (modificación), pago
- **Explicación representativa**: Criterios contables CNBV + GAT (conf: norma)
- **Llamado por** (fan_in=0, top 3 de 0): —
- **Llama a** (top 3 de 0): —

#### `proyecta_pba` · bdicred · D03

- **Reglas**: 24 (tipos: FÓRMULA 23, UMBRAL 1)
- **Categoría dominante**: REGULATORIO
- **Reguladores**: CNBV
- **Riesgo equiv.**: sí
- **Vocabulario**: —
- **Explicación representativa**: Criterios contables CNBV + GAT (conf: norma)
- **Llamado por** (fan_in=0, top 3 de 0): —
- **Llama a** (top 3 de 0): —

#### `sp_gen_report_articulo_51` · bdinteg · D02

- **Reglas**: 6 (tipos: FÓRMULA 6)
- **Categoría dominante**: CALCULO_FINANCIERO
- **Reguladores**: CNBV
- **Riesgo equiv.**: no
- **Vocabulario** (12 términos únicos): causa (causa / motivo), numcte (número de cliente), descripcion (descripción), nombre, situacion (situación), sucursal, fecha, validacion (validación), transaccion (transacción), consulta (consulta / lee) (+2 más)
- **Explicación representativa**: Set isolation to dirty read; set lock mode to wait 3; unload to (conf: literal)
- **Llamado por** (fan_in=0, top 3 de 0): —
- **Llama a** (top 3 de 0): —

#### `sp_dispercionnomina_bpi` · bdicheq · D04

- **Reglas**: 10 (tipos: VALIDACIÓN 5, FÓRMULA 5)
- **Categoría dominante**: OPERACIONAL
- **Reguladores**: CONDUSEF, SAT
- **Riesgo equiv.**: no
- **Vocabulario** (9 términos únicos): archivo, encabezado, estatus, valor, cuenta, datos, forma (construye / arma), calcular (calcula (infinitivo)), registros
- **Explicación representativa**: LTOSF Art.17 (CAT) + RECO (conf: norma)
- **Llamado por** (fan_in=0, top 3 de 0): —
- **Llama a** (top 3 de 0): —

#### `sp_conciliainv` · bdicheq · D04

- **Reglas**: 9 (tipos: FÓRMULA 9)
- **Categoría dominante**: CALCULO_FINANCIERO
- **Reguladores**: CNBV
- **Riesgo equiv.**: no
- **Vocabulario** (9 términos únicos): conciliachq (conciliación de cheques), cuenta, transacc (código de transacción), sucursal, producto, transaccion (transacción), secuencia, empresa (empresa (entidad bancaria)), sistema
- **Explicación representativa**: Fórmula: conciliación de cheques (conf: formula)
- **Llamado por** (fan_in=0, top 3 de 0): —
- **Llama a** (top 3 de 0): —

#### `sp_cat_consulta_saldostc` · bdicobranza · D11

- **Reglas**: 6 (tipos: VALIDACIÓN 3, ESTADO 2, FÓRMULA 1)
- **Categoría dominante**: PARAMETRIA
- **Reguladores**: —
- **Riesgo equiv.**: no
- **Vocabulario** (11 términos únicos): tipo (tipo de), general, error, datos, ejecutar (ejecutar (infinitivo)), consulta (consulta / lee), cuenta, cobranza, tarjeta, obtiene (obtiene / recupera) (+1 más)
- **Explicación representativa**: Ocurrió un error al ejecutar la consulta de datos general (conf: literal)
- **Llamado por** (fan_in=0, top 3 de 0): —
- **Llama a** (top 3 de 1): `sp_consulta_saldos_general`

#### `sp_proyecta_creditos_web` · bdicred · D03

- **Reglas**: 22 (tipos: FÓRMULA 21, VALIDACIÓN 1)
- **Categoría dominante**: REGULATORIO
- **Reguladores**: CNBV
- **Riesgo equiv.**: sí
- **Vocabulario**: —
- **Explicación representativa**: Criterios contables CNBV + GAT (conf: norma)
- **Llamado por** (fan_in=0, top 3 de 0): —
- **Llama a** (top 3 de 0): —

#### `sp_dispercionnominaautomatico` · bdicheq · D04

- **Reglas**: 8 (tipos: VALIDACIÓN 5, FÓRMULA 3)
- **Categoría dominante**: OPERACIONAL
- **Reguladores**: CONDUSEF, SAT
- **Riesgo equiv.**: no
- **Vocabulario** (9 términos únicos): archivo, encabezado, estatus, valor, cuenta, datos, forma (construye / arma), calcular (calcula (infinitivo)), registros
- **Explicación representativa**: LTOSF Art.17 (CAT) + RECO (conf: norma)
- **Llamado por** (fan_in=0, top 3 de 0): —
- **Llama a** (top 3 de 0): —

#### `sp_dispercionnominaautomatico_pba` · bdicheq · D04

- **Reglas**: 8 (tipos: VALIDACIÓN 5, FÓRMULA 3)
- **Categoría dominante**: OPERACIONAL
- **Reguladores**: CONDUSEF, SAT
- **Riesgo equiv.**: no
- **Vocabulario** (9 términos únicos): archivo, encabezado, estatus, valor, cuenta, datos, forma (construye / arma), calcular (calcula (infinitivo)), registros
- **Explicación representativa**: LTOSF Art.17 (CAT) + RECO (conf: norma)
- **Llamado por** (fan_in=0, top 3 de 0): —
- **Llama a** (top 3 de 0): —

#### `sp_geninsumos_calif_oyp` · bdicred · D03

- **Reglas**: 17 (tipos: FÓRMULA 16, UMBRAL 1)
- **Categoría dominante**: REGULATORIO
- **Reguladores**: CNBV
- **Riesgo equiv.**: sí
- **Vocabulario** (3 términos únicos): primer, modifica, cambio (cambio (de estatus, domicilio, etc.))
- **Explicación representativa**: Criterios contables CNBV + GAT (conf: norma)
- **Llamado por** (fan_in=0, top 3 de 0): —
- **Llama a** (top 3 de 0): —

#### `sp_gerenasenalizacion` · intercard · intercar

- **Reglas**: 8 (tipos: FÓRMULA 8)
- **Categoría dominante**: CALCULO_FINANCIERO
- **Reguladores**: —
- **Riesgo equiv.**: no
- **Vocabulario** (9 términos únicos): mensual, credito (crédito), linea (línea (de crédito)), tarjetas (tarjetas (plural)), saldo, monto, ciudad, sucursal, periodo
- **Explicación representativa**: Fórmula: mensual · crédito · línea (de crédito) (conf: formula)
- **Llamado por** (fan_in=0, top 3 de 0): —
- **Llama a** (top 3 de 0): —

#### `sp_sac_app_depuracion` · bdisac · D05

- **Reglas**: 21 (tipos: FÓRMULA 21)
- **Categoría dominante**: REGULATORIO
- **Reguladores**: CONDUSEF
- **Riesgo equiv.**: no
- **Vocabulario**: —
- **Explicación representativa**: Cálculo con umbral/factor 621028 (conf: formula)
- **Llamado por** (fan_in=0, top 3 de 0): —
- **Llama a** (top 3 de 0): —

#### `sp_reportenegocio_pba` · intercard · intercar

- **Reglas**: 12 (tipos: FÓRMULA 12)
- **Categoría dominante**: CALCULO_FINANCIERO
- **Reguladores**: —
- **Riesgo equiv.**: no
- **Vocabulario** (6 términos únicos): periodo, producto, total, monto, comercio (comercio afiliado), desc ([polisemia] Descripción (sp_desc_ret: devuelve descripción del código de retorno) | Descarga (sp_desc_archivos_cfdi/conc: descarga archivos CFDI y conciliación))
- **Explicación representativa**: Fórmula: periodo · producto · total (conf: formula)
- **Llamado por** (fan_in=0, top 3 de 0): —
- **Llama a** (top 3 de 0): —

#### `sp_reportenegocio` · intercardbpi · intercar

- **Reglas**: 12 (tipos: FÓRMULA 12)
- **Categoría dominante**: CALCULO_FINANCIERO
- **Reguladores**: —
- **Riesgo equiv.**: no
- **Vocabulario** (6 términos únicos): periodo, producto, total, monto, comercio (comercio afiliado), desc ([polisemia] Descripción (sp_desc_ret: devuelve descripción del código de retorno) | Descarga (sp_desc_archivos_cfdi/conc: descarga archivos CFDI y conciliación))
- **Explicación representativa**: Fórmula: periodo · producto · total (conf: formula)
- **Llamado por** (fan_in=0, top 3 de 0): —
- **Llama a** (top 3 de 0): —

#### `sp_cnsif_genarchmovimientos` · bdicnweb · D01

- **Reglas**: 5 (tipos: FÓRMULA 4, VALIDACIÓN 1)
- **Categoría dominante**: CALCULO_FINANCIERO
- **Reguladores**: —
- **Riesgo equiv.**: no
- **Vocabulario** (10 términos únicos): folio, referencia, fecha, usuario, saldo, hora, monto, sucursal, error, ejecucion (ejecución (de proceso))
- **Explicación representativa**: Fórmula: folio · referencia · fecha (conf: formula)
- **Llamado por** (fan_in=18, top 3 de 0): —
- **Llama a** (top 3 de 2): `sp_cnsif_confirmaejecutivo`, `sp_registra_evento`

#### `generaestadosdecuenta_repro` · bdicred · D03

- **Reglas**: 20 (tipos: FÓRMULA 18, UMBRAL 2)
- **Categoría dominante**: REGULATORIO
- **Reguladores**: CNBV, CONDUSEF
- **Riesgo equiv.**: sí
- **Vocabulario**: —
- **Explicación representativa**: Criterios contables CNBV + GAT (conf: norma)
- **Llamado por** (fan_in=0, top 3 de 0): —
- **Llama a** (top 3 de 0): —

#### `sp_sac_insertaremesasnoconciliadaswu` · bdisac · D05

- **Reglas**: 20 (tipos: FÓRMULA 20)
- **Categoría dominante**: REGULATORIO
- **Reguladores**: CONDUSEF
- **Riesgo equiv.**: no
- **Vocabulario**: —
- **Explicación representativa**: RECA/SAC (conf: norma)
- **Llamado por** (fan_in=0, top 3 de 0): —
- **Llama a** (top 3 de 3): `cargo_ref`, `abono_ref`, `reversion`

#### `spsp_generaconsol` · bdirepaut · bdirepau

- **Reglas**: 19 (tipos: FÓRMULA 19)
- **Categoría dominante**: CALCULO_FINANCIERO
- **Reguladores**: —
- **Riesgo equiv.**: sí
- **Vocabulario**: —
- **Explicación representativa**: —
- **Llamado por** (fan_in=0, top 3 de 0): —
- **Llama a** (top 3 de 0): —

#### `sp_registraoperacion` · bdibei · bdibei

- **Reglas**: 5 (tipos: VALIDACIÓN 5)
- **Categoría dominante**: OPERACIONAL
- **Reguladores**: —
- **Riesgo equiv.**: no
- **Vocabulario** (9 términos únicos): operacion (operación), valor, usuario, servicio, numcte (número de cliente), cliente, origen, cuenta, destino
- **Explicación representativa**: La operacion no puede ser un valor nulo o vacio (conf: literal)
- **Llamado por** (fan_in=0, top 3 de 0): —
- **Llama a** (top 3 de 0): —

#### `sp_msi_genrepmsigrid` · bdicnweb · D01

- **Reglas**: 2 (tipos: FÓRMULA 2)
- **Categoría dominante**: CALCULO_FINANCIERO
- **Reguladores**: —
- **Riesgo equiv.**: no
- **Vocabulario** (11 términos únicos): folio, referencia, plazo (plazo (depósito / crédito a plazo)), fecha, transaccion (transacción), pago, saldo, tarjeta, status (estatus), usuario (+1 más)
- **Explicación representativa**: Fórmula: folio · estatus · referencia (conf: formula)
- **Llamado por** (fan_in=0, top 3 de 0): —
- **Llama a** (top 3 de 1): `sp_cnsif_confirmaejecutivo`

#### `gencartconsumo` · bdicred · D03

- **Reglas**: 14 (tipos: FÓRMULA 13, UMBRAL 1)
- **Categoría dominante**: REGULATORIO
- **Reguladores**: CNBV
- **Riesgo equiv.**: sí
- **Vocabulario** (3 términos únicos): periodo, inicio, monto
- **Explicación representativa**: Criterios contables CNBV + GAT (conf: norma)
- **Llamado por** (fan_in=0, top 3 de 0): —
- **Llama a** (top 3 de 0): —

#### `sp_pagopp_quitacondona` · bdicred · D03

- **Reglas**: 8 (tipos: FÓRMULA 8)
- **Categoría dominante**: REGULATORIO
- **Reguladores**: CNBV, SAT
- **Riesgo equiv.**: sí
- **Vocabulario** (7 términos únicos): interes (interés), obtiene (obtiene / recupera), intereses, total, pago, obtener (obtiene / recupera), monto
- **Explicación representativa**: CUB CNBV (conf: norma)
- **Llamado por** (fan_in=0, top 3 de 0): —
- **Llama a** (top 3 de 0): —

#### `sp_cnsif_genarchmovimientos2` · bdicnweb · D01

- **Reglas**: 3 (tipos: FÓRMULA 2, VALIDACIÓN 1)
- **Categoría dominante**: CALCULO_FINANCIERO
- **Reguladores**: —
- **Riesgo equiv.**: no
- **Vocabulario** (10 términos únicos): folio, referencia, fecha, saldo, concepto (concepto de pago), hora, monto, ordenante (ordenante (pagador que emite la orden SPEI)), error, ejecucion (ejecución (de proceso))
- **Explicación representativa**: Fórmula: folio · referencia · fecha (conf: formula)
- **Llamado por** (fan_in=7, top 3 de 0): —
- **Llama a** (top 3 de 4): `sp_cnsif_confirmaejecutivo`, `sp_cnsif_permisosejecutivo`, `sp_sac_consucursales`

#### `provisionlineacred_parte_inc` · bdicred · D03

- **Reglas**: 18 (tipos: FÓRMULA 17, VALIDACIÓN 1)
- **Categoría dominante**: REGULATORIO
- **Reguladores**: CNBV
- **Riesgo equiv.**: sí
- **Vocabulario**: —
- **Explicación representativa**: Criterios contables CNBV + GAT (conf: norma)
- **Llamado por** (fan_in=0, top 3 de 0): —
- **Llama a** (top 3 de 0): —

#### `provisionlineacred_parte_mx` · bdicred · D03

- **Reglas**: 18 (tipos: FÓRMULA 17, VALIDACIÓN 1)
- **Categoría dominante**: REGULATORIO
- **Reguladores**: CNBV
- **Riesgo equiv.**: sí
- **Vocabulario**: —
- **Explicación representativa**: Criterios contables CNBV + GAT (conf: norma)
- **Llamado por** (fan_in=0, top 3 de 0): —
- **Llama a** (top 3 de 0): —

#### `sp_apertura_credito_aut` · bdicred · D03

- **Reglas**: 11 (tipos: FÓRMULA 7, VALIDACIÓN 4)
- **Categoría dominante**: REGULATORIO
- **Reguladores**: CNBV
- **Riesgo equiv.**: no
- **Vocabulario** (4 términos únicos): solicitud, cliente, credito (crédito), registro
- **Explicación representativa**: Criterios contables CNBV + GAT (conf: norma)
- **Llamado por** (fan_in=1, top 3 de 0): —
- **Llama a** (top 3 de 2): `cargo_ref`, `abono_ref`

#### `sp_apertura_credito_restructura_prestamo` · bdicred · D03

- **Reglas**: 11 (tipos: FÓRMULA 7, VALIDACIÓN 4)
- **Categoría dominante**: REGULATORIO
- **Reguladores**: CNBV
- **Riesgo equiv.**: no
- **Vocabulario** (4 términos únicos): solicitud, cliente, credito (crédito), registro
- **Explicación representativa**: Criterios contables CNBV + GAT (conf: norma)
- **Llamado por** (fan_in=1, top 3 de 0): —
- **Llama a** (top 3 de 2): `cargo_ref`, `abono_ref`

#### `sp_repctasinactivasart61` · bdicnweb · D01

- **Reglas**: 2 (tipos: FÓRMULA 1, VALIDACIÓN 1)
- **Categoría dominante**: REGULATORIO
- **Reguladores**: CNBV
- **Riesgo equiv.**: no
- **Vocabulario** (10 términos únicos): movimiento, producto, fecha, cliente, cuenta, interes (interés), activa, concentracion (concentración de fondos), error, ejecucion (ejecución (de proceso))
- **Explicación representativa**: Fecha de consulta (conf: literal)
- **Llamado por** (fan_in=0, top 3 de 0): —
- **Llama a** (top 3 de 2): `sp_cnsif_confirmaejecutivo`, `sp_registra_evento`

#### `sp_apertura_credito` · bdicred · D03

- **Reglas**: 11 (tipos: FÓRMULA 7, VALIDACIÓN 4)
- **Categoría dominante**: REGULATORIO
- **Reguladores**: CNBV
- **Riesgo equiv.**: no
- **Vocabulario** (4 términos únicos): solicitud, cliente, credito (crédito), registro
- **Explicación representativa**: Criterios contables CNBV + GAT (conf: norma)
- **Llamado por** (fan_in=0, top 3 de 0): —
- **Llama a** (top 3 de 2): `cargo_ref`, `abono_ref`

#### `sp_apertura_credito_restructura_prestamo_web` · bdicred · D03

- **Reglas**: 11 (tipos: FÓRMULA 7, VALIDACIÓN 4)
- **Categoría dominante**: REGULATORIO
- **Reguladores**: CNBV
- **Riesgo equiv.**: no
- **Vocabulario** (4 términos únicos): solicitud, cliente, credito (crédito), registro
- **Explicación representativa**: Criterios contables CNBV + GAT (conf: norma)
- **Llamado por** (fan_in=0, top 3 de 0): —
- **Llama a** (top 3 de 2): `cargo_ref`, `abono_ref`

#### `sp_geninsumos_calif_pp_parte` · bdicred · D03

- **Reglas**: 17 (tipos: FÓRMULA 17)
- **Categoría dominante**: CALCULO_FINANCIERO
- **Reguladores**: CNBV
- **Riesgo equiv.**: sí
- **Vocabulario**: —
- **Explicación representativa**: Criterios contables CNBV + GAT (conf: norma)
- **Llamado por** (fan_in=0, top 3 de 0): —
- **Llama a** (top 3 de 0): —

#### `sp_rep_men_increm_auto_hist` · bdicred · D03

- **Reglas**: 8 (tipos: FÓRMULA 8)
- **Categoría dominante**: REGULATORIO
- **Reguladores**: CNBV, CONDUSEF
- **Riesgo equiv.**: no
- **Vocabulario** (6 términos únicos): fecha, monto, origen, linea (línea (de crédito)), saldo, pagos (pagos (plural))
- **Explicación representativa**: LTOSF Art.17 (conf: norma)
- **Llamado por** (fan_in=0, top 3 de 0): —
- **Llama a** (top 3 de 0): —

#### `sp_integracion_cuenta` · bdiaclaracion · D07

- **Reglas**: 6 (tipos: FÓRMULA 6)
- **Categoría dominante**: REGULATORIO
- **Reguladores**: CONDUSEF
- **Riesgo equiv.**: no
- **Vocabulario** (7 términos únicos): tarjeta, concepto (concepto de pago), procede, comision (comisión (CONDUSEF — debe estar en RECO)), folio, cuenta, monto
- **Explicación representativa**: RECA/SAC (conf: norma)
- **Llamado por** (fan_in=0, top 3 de 0): —
- **Llama a** (top 3 de 0): —

#### `sp_indicadores_credito` · bdicred · D03

- **Reglas**: 3 (tipos: FÓRMULA 3)
- **Categoría dominante**: CALCULO_FINANCIERO
- **Reguladores**: —
- **Riesgo equiv.**: no
- **Vocabulario** (9 términos únicos): reestructura (reestructura crédito), solicitudes (solicitudes (plural)), fecha, total, nomina (nómina), prestamo (préstamo (Personal / Nómina / Digital BanCoppel)), coppel (Coppel (grupo)), canal (canal (de distribución)), producto
- **Explicación representativa**: Begin {fs= (conf: literal)
- **Llamado por** (fan_in=0, top 3 de 0): —
- **Llama a** (top 3 de 1): `sp_generafolionomina`

#### `sp_sorteo_registra_ganadores` · bdinteg · D02

- **Reglas**: 3 (tipos: FÓRMULA 3)
- **Categoría dominante**: CALCULO_FINANCIERO
- **Reguladores**: —
- **Riesgo equiv.**: no
- **Vocabulario** (9 términos únicos): sorteo, estado (estado (entidad federativa / estatus)), caja (caja / ventanilla), origen, producto, fecha, cliente, cuenta, tienda (tienda Coppel — punto de venta físico / sucursal de tienda)
- **Explicación representativa**: Fórmula: sorteo (conf: formula)
- **Llamado por** (fan_in=0, top 3 de 0): —
- **Llama a** (top 3 de 0): —

#### `sp_proyecta_prestamos` · bdicred · D03

- **Reglas**: 16 (tipos: FÓRMULA 15, UMBRAL 1)
- **Categoría dominante**: REGULATORIO
- **Reguladores**: CNBV
- **Riesgo equiv.**: sí
- **Vocabulario**: —
- **Explicación representativa**: Criterios contables CNBV + GAT (conf: norma)
- **Llamado por** (fan_in=33, top 3 de 0): —
- **Llama a** (top 3 de 1): `monthadd`

#### `proyecta` · bdicred · D03

- **Reglas**: 16 (tipos: FÓRMULA 15, UMBRAL 1)
- **Categoría dominante**: REGULATORIO
- **Reguladores**: CNBV
- **Riesgo equiv.**: sí
- **Vocabulario**: —
- **Explicación representativa**: Criterios contables CNBV + GAT (conf: norma)
- **Llamado por** (fan_in=1, top 3 de 0): —
- **Llama a** (top 3 de 1): `sp_inserta_bitacora_cob`

#### `sp_genera_cintas_semanales` · bdiburo · bdiburo

- **Reglas**: 16 (tipos: FÓRMULA 16)
- **Categoría dominante**: REGULATORIO
- **Reguladores**: CNBV, CONDUSEF
- **Riesgo equiv.**: no
- **Vocabulario**: —
- **Explicación representativa**: LRSIC (conf: norma)
- **Llamado por** (fan_in=0, top 3 de 0): —
- **Llama a** (top 3 de 0): —

#### `sp_genera_cintas_semanales_clon` · bdiburo · bdiburo

- **Reglas**: 16 (tipos: FÓRMULA 16)
- **Categoría dominante**: REGULATORIO
- **Reguladores**: CNBV, CONDUSEF
- **Riesgo equiv.**: no
- **Vocabulario**: —
- **Explicación representativa**: LRSIC (conf: norma)
- **Llamado por** (fan_in=0, top 3 de 0): —
- **Llama a** (top 3 de 0): —

#### `sp_genera_cintas_semanales_cnr` · bdiburo · bdiburo

- **Reglas**: 16 (tipos: FÓRMULA 16)
- **Categoría dominante**: REGULATORIO
- **Reguladores**: CNBV, CONDUSEF
- **Riesgo equiv.**: no
- **Vocabulario**: —
- **Explicación representativa**: LRSIC (conf: norma)
- **Llamado por** (fan_in=0, top 3 de 0): —
- **Llama a** (top 3 de 0): —

#### `proyecta_web` · bdicred · D03

- **Reglas**: 16 (tipos: FÓRMULA 15, UMBRAL 1)
- **Categoría dominante**: REGULATORIO
- **Reguladores**: CNBV
- **Riesgo equiv.**: sí
- **Vocabulario**: —
- **Explicación representativa**: Criterios contables CNBV + GAT (conf: norma)
- **Llamado por** (fan_in=0, top 3 de 0): —
- **Llama a** (top 3 de 0): —

#### `sp_rpt_sol_movil` · bdinteg · D02

- **Reglas**: 4 (tipos: FÓRMULA 4)
- **Categoría dominante**: CALCULO_FINANCIERO
- **Reguladores**: —
- **Riesgo equiv.**: no
- **Vocabulario** (8 términos únicos): folio, zona, telefono (teléfono), producto, ejecutivo, numcte (número de cliente), nombre, sucursal
- **Explicación representativa**: Fórmula: folio · zona · teléfono (conf: formula)
- **Llamado por** (fan_in=0, top 3 de 0): —
- **Llama a** (top 3 de 0): —

#### `sp_actualizasolicitudmc` · bdicnweb · D01

- **Reglas**: 5 (tipos: VALIDACIÓN 5)
- **Categoría dominante**: OPERACIONAL
- **Reguladores**: —
- **Riesgo equiv.**: no
- **Vocabulario** (7 términos únicos): solicitud, usuario, envio (envía), supervision (supervisión), sistema, calle (calle (domicilio)), orden
- **Explicación representativa**: La solicitud ya esta siendo atendida por otro usuario (conf: literal)
- **Llamado por** (fan_in=0, top 3 de 0): —
- **Llama a** (top 3 de 1): `sp_cnsif_confirmaejecutivo`

#### `gencartconsumo_p` · bdicred · D03

- **Reglas**: 11 (tipos: FÓRMULA 9, VALIDACIÓN 2)
- **Categoría dominante**: REGULATORIO
- **Reguladores**: CNBV
- **Riesgo equiv.**: no
- **Vocabulario** (3 términos únicos): periodo, inicio, monto
- **Explicación representativa**: Criterios contables CNBV + GAT (conf: norma)
- **Llamado por** (fan_in=0, top 3 de 0): —
- **Llama a** (top 3 de 0): —

#### `sp_coas_recibidos` · bdispei · D08

- **Reglas**: 11 (tipos: FÓRMULA 10, VALIDACIÓN 1)
- **Categoría dominante**: CALCULO_FINANCIERO
- **Reguladores**: —
- **Riesgo equiv.**: no
- **Vocabulario** (3 términos únicos): conciliachq (conciliación de cheques), abono (abono / crédito), spei (familia SPEI (pagos interbancarios))
- **Explicación representativa**: Fórmula: conciliación de cheques · familia SPEI (pagos interbancarios) (conf: formula)
- **Llamado por** (fan_in=0, top 3 de 0): —
- **Llama a** (top 3 de 0): —

#### `sp_coas_recibidos_exp1` · bdispei · D08

- **Reglas**: 11 (tipos: FÓRMULA 10, VALIDACIÓN 1)
- **Categoría dominante**: CALCULO_FINANCIERO
- **Reguladores**: —
- **Riesgo equiv.**: no
- **Vocabulario** (3 términos únicos): conciliachq (conciliación de cheques), abono (abono / crédito), spei (familia SPEI (pagos interbancarios))
- **Explicación representativa**: Fórmula: conciliación de cheques · familia SPEI (pagos interbancarios) (conf: formula)
- **Llamado por** (fan_in=0, top 3 de 0): —
- **Llama a** (top 3 de 0): —

#### `ordpago` · bditrans · bditrans

- **Reglas**: 14 (tipos: FÓRMULA 12, VALIDACIÓN 2)
- **Categoría dominante**: CALCULO_FINANCIERO
- **Reguladores**: CONDUSEF
- **Riesgo equiv.**: no
- **Vocabulario** (1 términos únicos): orden
- **Explicación representativa**: LTOSF Art.17 (CAT) + RECO (conf: norma)
- **Llamado por** (fan_in=0, top 3 de 0): —
- **Llama a** (top 3 de 0): —

#### `sp_aforearchconfob` · bdiprog · bdiprog

- **Reglas**: 6 (tipos: VALIDACIÓN 5, FÓRMULA 1)
- **Categoría dominante**: OPERACIONAL
- **Reguladores**: Banxico
- **Riesgo equiv.**: no
- **Vocabulario** (6 términos únicos): archivo, error, clabe (CLABE interbancaria), obtiene (obtiene / recupera), proceso, activa
- **Explicación representativa**: Errores (conf: literal)
- **Llamado por** (fan_in=6, top 3 de 0): —
- **Llama a** (top 3 de 6): `cargo_ref`, `abono_ref`, `sp_generafolionomina`

#### `sp_obtiene_aproximacion` · bdisolic · D06

- **Reglas**: 15 (tipos: FÓRMULA 15)
- **Categoría dominante**: REGULATORIO
- **Reguladores**: CNBV
- **Riesgo equiv.**: sí
- **Vocabulario**: —
- **Explicación representativa**: Criterios contables CNBV + GAT (conf: norma)
- **Llamado por** (fan_in=6, top 3 de 0): —
- **Llama a** (top 3 de 1): `monthadd`

#### `sp_reporte_concilia_seguros` · bdicheq · D04

- **Reglas**: 3 (tipos: FÓRMULA 3)
- **Categoría dominante**: CALCULO_FINANCIERO
- **Reguladores**: —
- **Riesgo equiv.**: no
- **Vocabulario** (8 términos únicos): folio, fecha, cuenta, transaccion (transacción), monto, tarjeta, referencia, hora
- **Explicación representativa**: Fórmula: folio · tarjeta (conf: formula)
- **Llamado por** (fan_in=0, top 3 de 0): —
- **Llama a** (top 3 de 0): —

#### `generaedosctacrd` · bdicred · D03

- **Reglas**: 12 (tipos: FÓRMULA 10, UMBRAL 2)
- **Categoría dominante**: CALCULO_FINANCIERO
- **Reguladores**: CNBV, SAT
- **Riesgo equiv.**: sí
- **Vocabulario** (2 términos únicos): pago, cargo (cargo / débito)
- **Explicación representativa**: Cálculo con umbral/factor 360 (conf: formula)
- **Llamado por** (fan_in=0, top 3 de 0): —
- **Llama a** (top 3 de 0): —

#### `generaedosctacrd_pp` · bdicred · D03

- **Reglas**: 15 (tipos: FÓRMULA 14, UMBRAL 1)
- **Categoría dominante**: REGULATORIO
- **Reguladores**: CNBV, SAT
- **Riesgo equiv.**: sí
- **Vocabulario**: —
- **Explicación representativa**: CFDI/Retenciones bancarias (conf: norma)
- **Llamado por** (fan_in=0, top 3 de 0): —
- **Llama a** (top 3 de 0): —

#### `provisionlineacred_parte_pba` · bdicred · D03

- **Reglas**: 15 (tipos: FÓRMULA 14, VALIDACIÓN 1)
- **Categoría dominante**: REGULATORIO
- **Reguladores**: CNBV
- **Riesgo equiv.**: sí
- **Vocabulario**: —
- **Explicación representativa**: Criterios contables CNBV + GAT (conf: norma)
- **Llamado por** (fan_in=0, top 3 de 0): —
- **Llama a** (top 3 de 0): —

#### `sp_actcatalogos_sitesp` · bdinteg · D02

- **Reglas**: 15 (tipos: FÓRMULA 15)
- **Categoría dominante**: CALCULO_FINANCIERO
- **Reguladores**: —
- **Riesgo equiv.**: no
- **Vocabulario**: —
- **Explicación representativa**: Load from (conf: literal)
- **Llamado por** (fan_in=0, top 3 de 0): —
- **Llama a** (top 3 de 0): —

#### `sp_actcatalogos_sitesp_prb` · bdinteg · D02

- **Reglas**: 15 (tipos: FÓRMULA 15)
- **Categoría dominante**: CALCULO_FINANCIERO
- **Reguladores**: —
- **Riesgo equiv.**: no
- **Vocabulario**: —
- **Explicación representativa**: Load from (conf: literal)
- **Llamado por** (fan_in=0, top 3 de 0): —
- **Llama a** (top 3 de 0): —

#### `sp_archivo_central` · intercard · intercar

- **Reglas**: 3 (tipos: FÓRMULA 3)
- **Categoría dominante**: CALCULO_FINANCIERO
- **Reguladores**: —
- **Riesgo equiv.**: no
- **Vocabulario** (8 términos únicos): conciliacion (conciliación), convenio (convenio (nómina/empresarial)), referencia, transaccion (transacción), numtarjeta (número de tarjeta), documento, central, divisa
- **Explicación representativa**: Unload to (conf: literal)
- **Llamado por** (fan_in=0, top 3 de 0): —
- **Llama a** (top 3 de 0): —

#### `gencartconsumo_reproc` · bdicred · D03

- **Reglas**: 10 (tipos: FÓRMULA 10)
- **Categoría dominante**: REGULATORIO
- **Reguladores**: CNBV
- **Riesgo equiv.**: sí
- **Vocabulario** (3 términos únicos): periodo, inicio, monto
- **Explicación representativa**: Criterios contables CNBV + GAT (conf: norma)
- **Llamado por** (fan_in=0, top 3 de 0): —
- **Llama a** (top 3 de 0): —

#### `sp_geninsumos_calif_pdig` · bdicred · D03

- **Reglas**: 10 (tipos: FÓRMULA 10)
- **Categoría dominante**: CALCULO_FINANCIERO
- **Reguladores**: CNBV
- **Riesgo equiv.**: sí
- **Vocabulario** (3 términos únicos): cierre, modifica, saldo
- **Explicación representativa**: Criterios contables CNBV + GAT (conf: norma)
- **Llamado por** (fan_in=0, top 3 de 0): —
- **Llama a** (top 3 de 0): —

#### `sp_ejecutartransacciones` · bdiprog · bdiprog

- **Reglas**: 10 (tipos: FÓRMULA 7, VALIDACIÓN 3)
- **Categoría dominante**: REGULATORIO
- **Reguladores**: CONDUSEF
- **Riesgo equiv.**: no
- **Vocabulario** (3 términos únicos): spei (familia SPEI (pagos interbancarios)), error, pagos (pagos (plural))
- **Explicación representativa**: LTOSF Art.17 (CAT) + RECO (conf: norma)
- **Llamado por** (fan_in=0, top 3 de 0): —
- **Llama a** (top 3 de 5): `cargo_ref`, `abono_ref`, `sp_cons_sdodisp_x_tpcalculo`

#### `sp_ejecutartransacciones_inc` · bdiprog · bdiprog

- **Reglas**: 10 (tipos: FÓRMULA 7, VALIDACIÓN 3)
- **Categoría dominante**: REGULATORIO
- **Reguladores**: CONDUSEF
- **Riesgo equiv.**: no
- **Vocabulario** (3 términos únicos): spei (familia SPEI (pagos interbancarios)), error, pagos (pagos (plural))
- **Explicación representativa**: LTOSF Art.17 (CAT) + RECO (conf: norma)
- **Llamado por** (fan_in=0, top 3 de 0): —
- **Llama a** (top 3 de 5): `cargo_ref`, `abono_ref`, `sp_cons_sdodisp_x_tpcalculo`

#### `sp_ejecutartransacciones_pba` · bdiprog · bdiprog

- **Reglas**: 10 (tipos: FÓRMULA 7, VALIDACIÓN 3)
- **Categoría dominante**: REGULATORIO
- **Reguladores**: CONDUSEF
- **Riesgo equiv.**: no
- **Vocabulario** (3 términos únicos): spei (familia SPEI (pagos interbancarios)), error, pagos (pagos (plural))
- **Explicación representativa**: LTOSF Art.17 (CAT) + RECO (conf: norma)
- **Llamado por** (fan_in=0, top 3 de 0): —
- **Llama a** (top 3 de 4): `cargo_ref`, `abono_ref`, `reversion`

#### `sp_calcula_caratulaproducto_pba` · intercard · intercar

- **Reglas**: 4 (tipos: FÓRMULA 4)
- **Categoría dominante**: REGULATORIO
- **Reguladores**: CONDUSEF
- **Riesgo equiv.**: no
- **Vocabulario** (7 términos únicos): retiro, producto, operacion (operación), tipo (tipo de), monto, retiros, total
- **Explicación representativa**: LTOSF Art.17 (CAT) + RECO (conf: norma)
- **Llamado por** (fan_in=0, top 3 de 0): —
- **Llama a** (top 3 de 0): —

#### `sp_reportenegocio_pbajj` · intercard · intercar

- **Reglas**: 4 (tipos: FÓRMULA 4)
- **Categoría dominante**: CALCULO_FINANCIERO
- **Reguladores**: —
- **Riesgo equiv.**: no
- **Vocabulario** (7 términos únicos): periodo, producto, total, descripcion (descripción), monto, comercio (comercio afiliado), desc ([polisemia] Descripción (sp_desc_ret: devuelve descripción del código de retorno) | Descarga (sp_desc_archivos_cfdi/conc: descarga archivos CFDI y conciliación))
- **Explicación representativa**: Fórmula: periodo · producto · total (conf: formula)
- **Llamado por** (fan_in=0, top 3 de 0): —
- **Llama a** (top 3 de 0): —

#### `sp_validaexistenciatarjetasbandachip` · intercard · intercar

- **Reglas**: 4 (tipos: VALIDACIÓN 4)
- **Categoría dominante**: OPERACIONAL
- **Reguladores**: —
- **Riesgo equiv.**: no
- **Vocabulario** (7 términos únicos): tarjetas (tarjetas (plural)), clave, asigna, tipo (tipo de), tarjeta, registros, lote (lote (proceso batch))
- **Explicación representativa**: Parámetros de entrada vacíos (conf: literal)
- **Llamado por** (fan_in=0, top 3 de 0): —
- **Llama a** (top 3 de 1): `sp_registra_evento`

#### `sp_reporte_atm_acl_extra` · bdiaclaracion · D07

- **Reglas**: 2 (tipos: FÓRMULA 2)
- **Categoría dominante**: CALCULO_FINANCIERO
- **Reguladores**: CONDUSEF
- **Riesgo equiv.**: no
- **Vocabulario** (8 términos únicos): telefono (teléfono), status (estatus), origen, producto, fecha, evento (evento/notificación), secuencia, sucursal
- **Explicación representativa**: RECA/SAC (conf: norma)
- **Llamado por** (fan_in=0, top 3 de 0): —
- **Llama a** (top 3 de 2): `bloqueo_cta`, `sp_cons_sdodisp_x_tpcalculo`

#### `sp_consultaglobalchqpropios` · bdicheq · D04

- **Reglas**: 5 (tipos: VALIDACIÓN 5)
- **Categoría dominante**: PARAMETRIA
- **Reguladores**: —
- **Riesgo equiv.**: no
- **Vocabulario** (6 términos únicos): fecha, mayor (mayor contable), final, inicial, registros, consulta (consulta / lee)
- **Explicación representativa**: Fecha inicial no debe ser mayor a la fecha final (conf: literal)
- **Llamado por** (fan_in=0, top 3 de 0): —
- **Llama a** (top 3 de 0): —

#### `sp_cg_reporteenviodotaciones` · bdicnweb · D01

- **Reglas**: 2 (tipos: FÓRMULA 1, VALIDACIÓN 1)
- **Categoría dominante**: CALCULO_FINANCIERO
- **Reguladores**: —
- **Riesgo equiv.**: no
- **Vocabulario** (8 términos únicos): envio (envía), status (estatus), fecha, operacion (operación), usuario, mensaje, monto, dotacion (dotación de efectivo (a cajero/sucursal))
- **Explicación representativa**: Fórmula: envía · estatus · fecha (conf: formula)
- **Llamado por** (fan_in=0, top 3 de 0): —
- **Llama a** (top 3 de 3): `sp_cnsif_confirmaejecutivo`, `reversion`, `sp_registra_evento`

#### `sp_reportecancelacionctasmasivocre` · bdicnweb · D01

- **Reglas**: 2 (tipos: FÓRMULA 1, VALIDACIÓN 1)
- **Categoría dominante**: CALCULO_FINANCIERO
- **Reguladores**: —
- **Riesgo equiv.**: no
- **Vocabulario** (8 términos únicos): producto, fecha, cuenta, ejecutivo, saldo, numcte (número de cliente), descripcion (descripción), nombre
- **Explicación representativa**: Select a.id_registro, a.lote, a.numcte, nvl(trim(trim(trim(b.nombre1)|| (conf: literal)
- **Llamado por** (fan_in=0, top 3 de 0): —
- **Llama a** (top 3 de 1): `sp_cnsif_confirmaejecutivo`

#### `sp_reportecargosctasmasivocre` · bdicnweb · D01

- **Reglas**: 2 (tipos: FÓRMULA 1, VALIDACIÓN 1)
- **Categoría dominante**: CALCULO_FINANCIERO
- **Reguladores**: —
- **Riesgo equiv.**: no
- **Vocabulario** (8 términos únicos): folio, producto, cuenta, transaccion (transacción), numcte (número de cliente), descripcion (descripción), nombre, resultado
- **Explicación representativa**: Fórmula: folio · producto · cuenta (conf: formula)
- **Llamado por** (fan_in=0, top 3 de 0): —
- **Llama a** (top 3 de 1): `sp_cnsif_confirmaejecutivo`

#### `sp_reportecargosreversoctasmasivocre` · bdicnweb · D01

- **Reglas**: 2 (tipos: FÓRMULA 1, VALIDACIÓN 1)
- **Categoría dominante**: CALCULO_FINANCIERO
- **Reguladores**: —
- **Riesgo equiv.**: no
- **Vocabulario** (8 términos únicos): folio, status (estatus), reverso, producto, cuenta, transaccion (transacción), numcte (número de cliente), descripcion (descripción)
- **Explicación representativa**: Select a.id_registro, a.lote, b.folio_grupo, a.numcte, nvl(trim(trim(trim(c.nombre1)|| (conf: literal)
- **Llamado por** (fan_in=0, top 3 de 0): —
- **Llama a** (top 3 de 1): `sp_cnsif_confirmaejecutivo`

#### `sp_reportemantolineasmasivocre` · bdicnweb · D01

- **Reglas**: 2 (tipos: FÓRMULA 1, VALIDACIÓN 1)
- **Categoría dominante**: CALCULO_FINANCIERO
- **Reguladores**: —
- **Riesgo equiv.**: no
- **Vocabulario** (8 términos únicos): producto, cuenta, numcte (número de cliente), descripcion (descripción), nombre, resultado, lote (lote (proceso batch)), sucursal
- **Explicación representativa**: Select a.id_registro, a.lote, nvl(a.numcte, (conf: literal)
- **Llamado por** (fan_in=0, top 3 de 0): —
- **Llama a** (top 3 de 3): `sp_cnsif_confirmaejecutivo`, `reversion`, `sp_registra_evento`

#### `sp_reportepagosctasmasivocre` · bdicnweb · D01

- **Reglas**: 2 (tipos: FÓRMULA 1, VALIDACIÓN 1)
- **Categoría dominante**: CALCULO_FINANCIERO
- **Reguladores**: —
- **Riesgo equiv.**: no
- **Vocabulario** (8 términos únicos): folio, producto, cuenta, transaccion (transacción), usuario, numcte (número de cliente), descripcion (descripción), nombre
- **Explicación representativa**: Fórmula: folio · producto · cuenta (conf: formula)
- **Llamado por** (fan_in=0, top 3 de 0): —
- **Llama a** (top 3 de 77): `sp_cnsif_confirmaejecutivo`, `sp_valida_perfil_usuario`, `sp_consultadatospiezas_bym3`

#### `sp_reportepagosreversoctasmasivocre` · bdicnweb · D01

- **Reglas**: 2 (tipos: FÓRMULA 1, VALIDACIÓN 1)
- **Categoría dominante**: CALCULO_FINANCIERO
- **Reguladores**: —
- **Riesgo equiv.**: no
- **Vocabulario** (8 términos únicos): folio, status (estatus), reverso, producto, cuenta, transaccion (transacción), usuario, numcte (número de cliente)
- **Explicación representativa**: Fórmula: folio · estatus · reverso (conf: formula)
- **Llamado por** (fan_in=0, top 3 de 0): —
- **Llama a** (top 3 de 3): `sp_cnsif_confirmaejecutivo`, `cargo_ref`, `abono_ref`

#### `sp_domi_valida_alta` · bdidomi · bdidomi

- **Reglas**: 5 (tipos: VALIDACIÓN 5)
- **Categoría dominante**: PAGOS_TRANSFERENCIAS
- **Reguladores**: —
- **Riesgo equiv.**: no
- **Vocabulario** (6 términos únicos): parametros (parámetros), canal (canal (de distribución)), tipo (tipo de), cuenta, credito (crédito), activa
- **Explicación representativa**: Se validan los parametros de entrada (conf: literal)
- **Llamado por** (fan_in=0, top 3 de 0): —
- **Llama a** (top 3 de 0): —

#### `sp_reporte_clientes_titulares_upgrade` · bdinteg · D02

- **Reglas**: 2 (tipos: FÓRMULA 2)
- **Categoría dominante**: CALCULO_FINANCIERO
- **Reguladores**: —
- **Riesgo equiv.**: no
- **Vocabulario** (8 términos únicos): solicitudes (solicitudes (plural)), fecha, cobranza, clientes (clientes (plural)), total, alta (da de alta / registra), upgrade (actualiza producto (upgrade)), situaciones (situaciones de cuenta)
- **Explicación representativa**: Cálculo con umbral/factor 01 (conf: formula)
- **Llamado por** (fan_in=0, top 3 de 0): —
- **Llama a** (top 3 de 0): —

#### `sp_reporte_clientes_titulares_upgrade_2` · bdinteg · D02

- **Reglas**: 2 (tipos: FÓRMULA 2)
- **Categoría dominante**: CALCULO_FINANCIERO
- **Reguladores**: —
- **Riesgo equiv.**: no
- **Vocabulario** (8 términos únicos): solicitudes (solicitudes (plural)), fecha, cobranza, clientes (clientes (plural)), total, alta (da de alta / registra), upgrade (actualiza producto (upgrade)), situaciones (situaciones de cuenta)
- **Explicación representativa**: Cálculo con umbral/factor 01 (conf: formula)
- **Llamado por** (fan_in=0, top 3 de 0): —
- **Llama a** (top 3 de 0): —

#### `sp_reporte_clientes_titulares_upgrade_3` · bdinteg · D02

- **Reglas**: 2 (tipos: FÓRMULA 2)
- **Categoría dominante**: CALCULO_FINANCIERO
- **Reguladores**: —
- **Riesgo equiv.**: no
- **Vocabulario** (8 términos únicos): solicitudes (solicitudes (plural)), fecha, cobranza, clientes (clientes (plural)), total, alta (da de alta / registra), upgrade (actualiza producto (upgrade)), situaciones (situaciones de cuenta)
- **Explicación representativa**: Cálculo con umbral/factor 01 (conf: formula)
- **Llamado por** (fan_in=0, top 3 de 0): —
- **Llama a** (top 3 de 0): —

#### `sp_archivo_coppcnc` · intercardbpi · intercar

- **Reglas**: 8 (tipos: FÓRMULA 8)
- **Categoría dominante**: CALCULO_FINANCIERO
- **Reguladores**: —
- **Riesgo equiv.**: no
- **Vocabulario** (4 términos únicos): fecha, tipo (tipo de), transacc (código de transacción), prestamos (préstamos)
- **Explicación representativa**: Fórmula: fecha · tipo de · código de transacción (conf: formula)
- **Llamado por** (fan_in=0, top 3 de 0): —
- **Llama a** (top 3 de 0): —

#### `sp_rep_sac_reportedomiciliacion` · bdicnweb · D01

- **Reglas**: 3 (tipos: FÓRMULA 3)
- **Categoría dominante**: CALCULO_FINANCIERO
- **Reguladores**: —
- **Riesgo equiv.**: no
- **Vocabulario** (7 términos únicos): periodo, fecha, domiciliacion (domiciliación), club (Club de Protección — producto de seguro grupal BanCoppel; movimientos históricos en bdisac:sac_movimientoshistorial; ventas en sp_rep_vtas_club_proteccion), reporte, sucursal, numcte (número de cliente)
- **Explicación representativa**: Fórmula: número de cliente (conf: formula)
- **Llamado por** (fan_in=0, top 3 de 0): —
- **Llama a** (top 3 de 1): `sp_cnsif_confirmaejecutivo`

#### `sp_activaserviciosdomi_lmpba` · bdidomi · bdidomi

- **Reglas**: 3 (tipos: VALIDACIÓN 3)
- **Categoría dominante**: OPERACIONAL
- **Reguladores**: —
- **Riesgo equiv.**: no
- **Vocabulario** (7 términos únicos): parametros (parámetros), pago, tipo (tipo de), domiciliacion (domiciliación), cliente, alta (da de alta / registra), servicio
- **Explicación representativa**: Parametros de entrada estan en blanco. (conf: literal)
- **Llamado por** (fan_in=0, top 3 de 0): —
- **Llama a** (top 3 de 0): —

#### `sp_aforegenerararchivocifrascontrol` · bdiprog · bdiprog

- **Reglas**: 6 (tipos: VALIDACIÓN 5, FÓRMULA 1)
- **Categoría dominante**: OPERACIONAL
- **Reguladores**: —
- **Riesgo equiv.**: no
- **Vocabulario** (5 términos únicos): archivo, error, proceso, mensaje, activa
- **Explicación representativa**: -------------------errores (conf: literal)
- **Llamado por** (fan_in=0, top 3 de 0): —
- **Llama a** (top 3 de 0): —

#### `sp_inicremesas` · bdisac · D05

- **Reglas**: 9 (tipos: FÓRMULA 9)
- **Categoría dominante**: CALCULO_FINANCIERO
- **Reguladores**: —
- **Riesgo equiv.**: no
- **Vocabulario** (3 términos únicos): referencia, origen, usuario
- **Explicación representativa**: Cálculo con umbral/factor 19 (conf: formula)
- **Llamado por** (fan_in=0, top 3 de 0): —
- **Llama a** (top 3 de 0): —

#### `sp_aforevalidacargaarchivo` · bdiprog · bdiprog

- **Reglas**: 10 (tipos: FÓRMULA 5, VALIDACIÓN 5)
- **Categoría dominante**: CALCULO_FINANCIERO
- **Reguladores**: —
- **Riesgo equiv.**: no
- **Vocabulario** (2 términos únicos): pagos (pagos (plural)), activa
- **Explicación representativa**: Cálculo con umbral/factor 18,2 (conf: formula)
- **Llamado por** (fan_in=58, top 3 de 1): `sp_calificacion_scoring`
- **Llama a** (top 3 de 0): —

#### `sp_consultadetallechqpropio` · bdicheq · D04

- **Reglas**: 4 (tipos: VALIDACIÓN 4)
- **Categoría dominante**: PARAMETRIA
- **Reguladores**: —
- **Riesgo equiv.**: no
- **Vocabulario** (6 términos únicos): fecha, mayor (mayor contable), final, inicial, registros, consulta (consulta / lee)
- **Explicación representativa**: Fecha inicial no debe ser mayor a la fecha final (conf: literal)
- **Llamado por** (fan_in=0, top 3 de 0): —
- **Llama a** (top 3 de 0): —

#### `sp_generareporteconciliaaperturapagarescargo` · bdicnweb · D01

- **Reglas**: 1 (tipos: FÓRMULA 1)
- **Categoría dominante**: CALCULO_FINANCIERO
- **Reguladores**: —
- **Riesgo equiv.**: no
- **Vocabulario** (8 términos únicos): folio, fecha, cuenta, transaccion (transacción), usuario, apertura (apertura (de cuenta/crédito)), alta (da de alta / registra), sucursal
- **Explicación representativa**: Fecha alta (conf: literal)
- **Llamado por** (fan_in=0, top 3 de 0): —
- **Llama a** (top 3 de 84): `sp_cnsif_confirmaejecutivo`, `sp_valida_perfil_usuario`, `sp_consultadatospiezas_bym3`

#### `sp_pp_generareporteportafolio` · bdicnweb · D01

- **Reglas**: 1 (tipos: FÓRMULA 1)
- **Categoría dominante**: CALCULO_FINANCIERO
- **Reguladores**: —
- **Riesgo equiv.**: no
- **Vocabulario** (8 términos únicos): fecha, categoria (categoría), credito (crédito), tarjeta, titular (titular de cuenta), nombre, estatus, anio (año)
- **Explicación representativa**: Numero de credito (conf: literal)
- **Llamado por** (fan_in=0, top 3 de 0): —
- **Llama a** (top 3 de 83): `sp_cnsif_confirmaejecutivo`, `sp_valida_perfil_usuario`, `sp_consultadatospiezas_bym3`

#### `sp_reportebloqueoctascap` · bdicnweb · D01

- **Reglas**: 1 (tipos: FÓRMULA 1)
- **Categoría dominante**: CALCULO_FINANCIERO
- **Reguladores**: —
- **Riesgo equiv.**: no
- **Vocabulario** (8 términos únicos): producto, fecha, cuenta, usuario, numcte (número de cliente), nombre, resultado, lote (lote (proceso batch))
- **Explicación representativa**: Lote, numcte, nombre, cuenta, nvl(trim(to_char(sdo_actual, (conf: literal)
- **Llamado por** (fan_in=0, top 3 de 0): —
- **Llama a** (top 3 de 1): `sp_cnsif_confirmaejecutivo`

#### `sp_reportedesbloqueoctascap` · bdicnweb · D01

- **Reglas**: 1 (tipos: FÓRMULA 1)
- **Categoría dominante**: CALCULO_FINANCIERO
- **Reguladores**: —
- **Riesgo equiv.**: no
- **Vocabulario** (8 términos únicos): producto, fecha, cuenta, usuario, numcte (número de cliente), nombre, resultado, lote (lote (proceso batch))
- **Explicación representativa**: Lote, trim(numcte), trim(nombre), trim(cuenta), nvl(trim(to_char(sdo_actual, (conf: literal)
- **Llamado por** (fan_in=0, top 3 de 0): —
- **Llama a** (top 3 de 3): `sp_cnsif_confirmaejecutivo`, `bloqueo_cta`, `sp_registra_evento`

#### `sp_reporteretiroctasmasivo` · bdicnweb · D01

- **Reglas**: 1 (tipos: FÓRMULA 1)
- **Categoría dominante**: CALCULO_FINANCIERO
- **Reguladores**: —
- **Riesgo equiv.**: no
- **Vocabulario** (8 términos únicos): folio, referencia, producto, cuenta, transaccion (transacción), numcte (número de cliente), descripcion (descripción), nombre
- **Explicación representativa**: Select cm.id_registro, lote, trim(nvl(cm.numcte, (conf: literal)
- **Llamado por** (fan_in=0, top 3 de 0): —
- **Llama a** (top 3 de 1): `sp_cnsif_confirmaejecutivo`

#### `sp_sac_reportedetalletransucursal` · bdicnweb · D01

- **Reglas**: 1 (tipos: FÓRMULA 1)
- **Categoría dominante**: REGULATORIO
- **Reguladores**: CONDUSEF, SAT
- **Riesgo equiv.**: no
- **Vocabulario** (8 términos únicos): comision (comisión (CONDUSEF — debe estar en RECO)), convenio (convenio (nómina/empresarial)), referencia, cliente, cuenta, forma (construye / arma), pago, usuario
- **Explicación representativa**: Secuencia (conf: literal)
- **Llamado por** (fan_in=0, top 3 de 0): —
- **Llama a** (top 3 de 6): `sp_cnsif_confirmaejecutivo`, `sp_consulta_saldos_general`, `determina_lincred_tc_cjunk`

#### `sp_cierre_tarjeta` · bdicred · D03

- **Reglas**: 13 (tipos: FÓRMULA 13)
- **Categoría dominante**: REGULATORIO
- **Reguladores**: CNBV
- **Riesgo equiv.**: sí
- **Vocabulario**: —
- **Explicación representativa**: Criterios contables CNBV + GAT (conf: norma)
- **Llamado por** (fan_in=0, top 3 de 0): —
- **Llama a** (top 3 de 0): —

---

## Sección B — Índice por Categoría

Para cada categoría funcional, los 20 SPs con mayor número de reglas de esa categoría.

### CALCULO_FINANCIERO

| SP | DB | # Reglas | Explicación representativa |
|----|----|----------|----------------------------|
| `sp_txrechazo` | intercard | 20 | Cálculo con umbral/factor 10 |
| `sp_txrechazo_pba` | intercard | 20 | Cálculo con umbral/factor 10 |
| `spsp_generaconsol` | bdirepaut | 19 |  |
| `sp_geninsumos_calif_pp_parte` | bdicred | 15 | Criterios contables CNBV + GAT |
| `sp_actcatalogos_sitesp` | bdinteg | 15 | Load from |
| `sp_actcatalogos_sitesp_prb` | bdinteg | 15 | Load from |
| `sp_bedito_rechazo` | intercard | 15 | Fórmula: captura · producto · fecha |
| `sp_valida_saldos_credinomq_tablatemp` | bdimonitorcob | 12 |  |
| `sp_reportenegocio_pba` | intercard | 12 | Fórmula: periodo · producto · total |
| `sp_reportenegocio` | intercardbpi | 12 | Fórmula: periodo · producto · total |
| `sp_oper_corr_oxxo_eleven_aut` | intercard | 11 | Cálculo con umbral/factor 01 |
| `generaestadosdecuenta` | bdicred | 10 | Criterios contables CNBV + GAT |
| `provisionlineacred_parte` | bdicred | 10 | Criterios contables CNBV + GAT |
| `sp_geninsumos_calif_an` | bdicred | 10 | Criterios contables CNBV + GAT |
| `sp_geninsumos_calif_parte` | bdicred | 10 | Criterios contables CNBV + GAT |
| `sp_rep_estadisticas_tdc` | bdicred | 10 | Unload to |
| `sp_rep_pagosydisposiciones` | bdicred | 10 | Unload to |
| `sp_rep_pagosydisposiciones_archivo` | bdicred | 10 | Unload to |
| `sp_rep_pagosydisposiciones_menu` | bdicred | 10 | Unload to |
| `sp_generararchivoplano` | bdinteg | 10 | Fórmula: envíos |

### REGULATORIO

| SP | DB | # Reglas | Explicación representativa |
|----|----|----------|----------------------------|
| `sp_mueve_aclaraciones_historico` | bdiaclaracion | 107 | Fórmula: aclaraciones (proceso de disputas/reclamaciones de cliente) · aclaració... |
| `sp_envio_camp_ctes_ctaspzo` | bdicobranza | 38 | CUB CNBV |
| `sp_envio_camp_ctes_ctasrev` | bdicobranza | 36 | CUB CNBV |
| `sp_sac_app_depuracion` | bdisac | 21 | Cálculo con umbral/factor 621028 |
| `sp_sac_insertaremesasnoconciliadaswu` | bdisac | 20 | RECA/SAC |
| `generaestadosdecuenta` | bdicred | 19 | Criterios contables CNBV + GAT |
| `proyecta_pba` | bdicred | 17 | Criterios contables CNBV + GAT |
| `sp_proyecta_creditos_web` | bdicred | 17 | Criterios contables CNBV + GAT |
| `sp_genera_cintas_semanales` | bdiburo | 16 | LRSIC |
| `sp_genera_cintas_semanales_clon` | bdiburo | 16 | LRSIC |
| `sp_genera_cintas_semanales_cnr` | bdiburo | 16 | LRSIC |
| `sp_burofisicas_cortos_cnr` | bdiburo | 12 | LRSIC |
| `generaestadosdecuenta_repro` | bdicred | 12 | Criterios contables CNBV + GAT |
| `provisionlineacred_parte` | bdicred | 12 | Criterios contables CNBV + GAT |
| `gencartconsumo` | bdicred | 11 | Criterios contables CNBV + GAT |
| `proyecta` | bdicred | 11 | Criterios contables CNBV + GAT |
| `proyecta_web` | bdicred | 11 | Criterios contables CNBV + GAT |
| `sp_obtiene_amortizacion` | bdicred | 11 | Criterios contables CNBV + GAT |
| `sp_proyecta_prestamos` | bdicred | 11 | Criterios contables CNBV + GAT |
| `sp_tasaefectiva` | bdicred | 11 | Criterios contables CNBV + GAT |

### OPERACIONAL

| SP | DB | # Reglas | Explicación representativa |
|----|----|----------|----------------------------|
| `sp_validartipodatos` | bdicobranza | 7 |  |
| `sp_registraoperacion` | bdibei | 5 | La operacion no puede ser un valor nulo o vacio |
| `sp_maxdelq0to11mos_motor` | bdiburo | 5 |  |
| `arrpagoint_18082010` | bdicheq | 5 | Cálculo con umbral/factor 00 |
| `cargo_ref` | bdicheq | 5 | Retorna código de error 100 |
| `cargo_ref_mib` | bdicheq | 5 | Retorna código de error 999 |
| `cargon_ref` | bdicheq | 5 | Pagado |
| `cargon_ref_mx1` | bdicheq | 5 | Pagado |
| `cargon_ref_web` | bdicheq | 5 | Pagado |
| `sp_dispercionnominamanual` | bdicheq | 5 | LTOSF Art.17 (CAT) + RECO |
| `sp_validadatostempnomina` | bdicheq | 5 | No existen los datos en la tabla temporal del encabaezado |
| `sp_validadatostempnomina_bpi` | bdicheq | 5 | No existen los datos en la tabla temporal del encabaezado |
| `sp_actualizasolicitudmc` | bdicnweb | 5 | La solicitud ya esta siendo atendida por otro usuario |
| `sp_checacurp` | bdilide | 5 | Longitud no es de 13 caracteres para rfc |
| `sp_validacion_msj` | bdimnsj | 5 | No existe palabra clave |
| `sp_ws_valida_cotel` | bdinteg | 5 | Retorna código de error 118 |
| `sp_aforecancelarprocejecpagos` | bdiprog | 5 | Dsb 25/03/2014 |
| `sp_aforegenerararchivocifrascontrol` | bdiprog | 5 | -------------------errores |
| `sp_aforevalidacargaarchivo` | bdiprog | 5 | Cálculo con umbral/factor 18,2 |
| `sp_soe_baja_admin` | bdibei | 4 | Error en la ejecucion del sp sp_soe_obtenertoken |

### PARAMETRIA

| SP | DB | # Reglas | Explicación representativa |
|----|----|----------|----------------------------|
| `sp_consultaglobalchqpropios` | bdicheq | 5 | Fecha inicial no debe ser mayor a la fecha final |
| `sp_cnt_detallecatalogos` | bdicnweb | 5 | Error en la ejecucion del sp sp_consultarcatsucursales2 |
| `sp_cat_consulta_saldostc` | bdicobranza | 5 | Ocurrió un error al ejecutar la consulta de datos general |
| `sp_consulta_instruccinversioncreciente` | bdicheq | 4 | // parámetro de entrada vacío // |
| `sp_consultadetallechqpropio` | bdicheq | 4 | Fecha inicial no debe ser mayor a la fecha final |
| `sp_consultarinversioncreciente` | bdicheq | 4 | Parámetros de entrada vacíos |
| `sp_consdetallesolsupervision` | bdicnweb | 3 | Error en la ejecución del sp bdisolic:sp_busca_sol_supervision |
| `sp_cat_consulta_disponibilidad_cliente` | bdicobranza | 3 | CUB CNBV |
| `sp_cat_gb_pp_genarchex` | bdicobranza | 3 | Validacion de los datos de entrada |
| `sp_cat_ivr_gen_arcctesexcluidos` | bdicobranza | 3 | Validacion de los datos de entrada |
| `sp_consultacredbloqfallecimiento` | bdicred | 3 | -control de errores en caso que no se proporcione ningún parámetro-- |
| `sp_cat_ctes_activ_bnca_movil` | bdinteg | 3 | Retorna código de error 102005 |
| `sp_obtiene_periodo_vigencia_preingreso` | bdiaclaracion | 2 | La invocaciã³n debe tener algãºn valor |
| `sp_consulta_firmasregistradas` | bdicheq | 2 | Parámetro de entrada vacío |
| `sp_consulta_instruccionautoridad` | bdicheq | 2 | Parámetro de entrada vacío |
| `sp_consulta_instruccionvencimiento` | bdicheq | 2 | Parámetro de entrada vacío |
| `sp_obtienemovtosdiarios` | bdicheq | 2 | Faltan parametros para su ejecucion. |
| `sp_consultaestatuscheques` | bdicntchq | 2 | ********************************************************************************... |
| `sp_catalogosuctrancaja` | bdicnweb | 2 | Valida nã?mero de caja general |
| `sp_catalogosucxcg` | bdicnweb | 2 | Error en la ejecución del sp bdisuc:sp_consulta_sucxcg2 |

### RIESGO_CREDITO

| SP | DB | # Reglas | Explicación representativa |
|----|----|----------|----------------------------|
| `altatarcred_v_1` | bdicred | 4 | Enviar codigo de respuesta 151 |
| `altatarrepos_n` | bdicred | 4 | Retorna código de error 100 |
| `principal` | bdicred | 4 | Let codret = '296';  -- codigo de error en la si_codret |
| `sp_apertura_credito` | bdicred | 4 | Criterios contables CNBV + GAT |
| `sp_apertura_credito_aut` | bdicred | 4 | Criterios contables CNBV + GAT |
| `sp_apertura_credito_restructura_prestamo` | bdicred | 4 | Criterios contables CNBV + GAT |
| `sp_apertura_credito_restructura_prestamo_web` | bdicred | 4 | Criterios contables CNBV + GAT |
| `altatarrepos` | bdicred | 3 | Retorna código de error 100 |
| `capital` | bdicred | 3 |  |
| `con_anexo` | bdicred | 3 | ############################################################################ |
| `conscteeliminaadicional` | bdicred | 3 | La cuenta no existe |
| `principal_jose` | bdicred | 3 | Let codret = '296';  -- codigo de error en la si_codret |
| `sp_carga_ctes_clean_behavior` | bdicred | 3 | Retorna código de error 102005 |
| `sp_carga_ctes_clean_behavior_mx` | bdicred | 3 | Retorna código de error 102005 |
| `sp_rep_cartera_quebrantar_optim` | bdicred | 3 | Punto 2.2 rqm 09 274 inciso b |
| `sp_rep_excluidos_ctesclean_behavior` | bdicred | 3 | Retorna código de error 102005 |
| `sp_rep_pp_auto_no_utilizado` | bdicred | 3 | Retorna código de error 102005 |
| `sp_rep_transac_1eruso_tdc` | bdicred | 3 | Retorna código de error 102005 |
| `sp_sd_ri_cb` | bdicred | 3 |  |
| `sp_pld_chq_crg_xml_head` | bdiauditor | 2 | No se encontro el organismo regulador en la tabla bdiauditor:param |

### PAGOS_TRANSFERENCIAS

| SP | DB | # Reglas | Explicación representativa |
|----|----|----------|----------------------------|
| `sp_domi_valida_alta` | bdidomi | 5 | Se validan los parametros de entrada |
| `sp_domi_valida_alta_ob` | bdidomi | 5 | Se validan los parametros de entrada |
| `sp_aplicaaclaradebito` | bdicheq | 4 | Intento de cargo con crã?ã?ã?ãâ©dito vencido "bt" y bloqueado |
| `sp_aplicaaclaradebito_prueba` | bdicheq | 4 | Intento de cargo con crã?ã?ã?ãâ©dito vencido "bt" y bloqueado |
| `sp_domi_alta_cuentas_registradas` | bdidomi | 3 | Valida si los parametros requeridos de entrada vienen vacios |
| `sp_domi_conciliacontable2` | bdidomi | 3 |  |
| `sp_domi_consulta_autorizacioncliente_ob` | bdidomi | 3 | Algun parametro de entrada requerido este en blanco. |
| `sp_domi_createtablascte` | bdidomi | 3 | Cálculo con umbral/factor 15 |
| `sp_domi_createtablascte_ob` | bdidomi | 3 | Cálculo con umbral/factor 15 |
| `sp_domi_cuentas_registradas_ob` | bdidomi | 3 | Parametro de entrada requerido estã?? en blanco. |
| `sp_domi_guardararchivo_manual` | bdidomi | 3 | Parametros de entrada estan en blanco. |
| `sp_domi_proximo_pago` | bdidomi | 3 | Valida parametros de entrada |
| `sp_aplicadevol_cod41_ccep` | bdicnweb | 2 | Error en la ejecucion del sp ins_reg_devo |
| `sp_atms_actualizarecepdota` | bdicnweb | 2 | Error en la ejecución del sp bdisuc:sp_recepdota_atm |
| `sp_atms_catplazacajero` | bdicnweb | 2 | Error en la ejecución del sp bdisuc:sp_atms |
| `sp_atms_catpzaatmoperaciones` | bdicnweb | 2 | Error en la ejecución del sp bdisuc:sp_atms2 |
| `sp_atms_detalleoperaciones` | bdicnweb | 2 | Error en la ejecución del sp bdisuc:sp_consul_atm2 |
| `sp_rem_consparametrostransaccionbts` | bdicnweb | 2 | Error en la ejecución del sp bdisac:sp_consinfobtssif |
| `sp_rem_validaprocesosbts` | bdicnweb | 2 | Error en la ejecución del sp bdinteg:sp_obtenfechahrasistema |
| `sp_domi_consulta_parametros` | bdidomi | 2 | Validar parametros de entrada. |

### CONTABILIDAD_REPORTES

| SP | DB | # Reglas | Explicación representativa |
|----|----|----------|----------------------------|
| `sp_reporte_ctes_dirty_behavior` | bdicred | 3 | Retorna código de error 102005 |
| `sp_cnsif_genarchmovimientos_masivo` | bdicnweb | 2 | Error en la ejecucion del sp bdicnweb:sp_cnsif_consdetallemovimientos_totales |
| `sp_cnsif_genreportes_aumlimcred_mc` | bdicnweb | 2 | Error en la ejecucion del sp bdicnweb:sp_consultagralautaumlincred_rep |
| `sp_fc_respaldacargaimg` | bdicnweb | 2 | Error en la ejecucion del sp bdidigital:sp_respalda_img |
| `sp_fc_respaldacargaimg2` | bdicnweb | 2 | Error en la ejecucion del sp bdidigital:sp_respalda_img2 |
| `sp_fc_respaldacargaimg3` | bdicnweb | 2 | Error en la ejecucion del sp bdidigital:sp_respalda_img3 |
| `sp_reportefechaclaveblodescre` | bdicnweb | 2 | Error en la ejecucion del sp sp_consultaclave |
| `sp_reportes_agex_resultado` | bdicobranza | 2 | Fórmula: número de cliente · canal (de distribución) |
| `cancela_resultados` | bdicont | 2 | --mescierre1 |
| `valfecha_pol` | bdicont | 2 | Retorna código de error 999 |
| `sp_cnsif_buscacterfc` | bdinteg | 2 | El cliente no existe con el r.f.c. capturado |
| `sp_cnsif_repmovtoside` | bdinteg | 2 | Retorna código de error 200 |
| `sp_cnsif_cons_expediente2` | bdicnweb | 1 | Retorna código de error 1001 |
| `sp_cnsif_consarchivosgenerados` | bdicnweb | 1 | Retorna código de error 1001 |
| `sp_cnsif_consdetallemovimientos` | bdicnweb | 1 | Retorna código de error 1001 |
| `sp_cnsif_consdetallemovimientos2` | bdicnweb | 1 | Retorna código de error 1001 |
| `sp_cnsif_consdetallemovimientos_totales` | bdicnweb | 1 | Error en la ejecucion del sp bdinteg:sp_cnsif_consultatotalmovtosdiarioscta_2 |
| `sp_cnsif_consultatotalmovtosdiarioscta` | bdicnweb | 1 |  |
| `sp_cnsif_consultatotalmovtosdiarioscta_2` | bdicnweb | 1 |  |
| `sp_cnsif_genarch_aumlimcred_mc` | bdicnweb | 1 | Error en la ejecucion del sp bdimnsj:sp_registra_evento |

### FLUJO_OPERATIVO

| SP | DB | # Reglas | Explicación representativa |
|----|----|----------|----------------------------|
| `sp_ejecutartransacciones` | bdiprog | 3 | LTOSF Art.17 (CAT) + RECO |
| `sp_ejecutartransacciones_inc` | bdiprog | 3 | LTOSF Art.17 (CAT) + RECO |
| `sp_ejecutartransacciones_pba` | bdiprog | 3 | LTOSF Art.17 (CAT) + RECO |
| `sp_cat_ejecuta_mensaje` | bdicat | 2 | Validacion que los parametros de entrada no esten vacios |
| `sp_buscarchivosprocesarafore` | bdicnweb | 2 | Error en la ejecuciãn del sp bdiprog:sp_aforebuscararchivosprocesar2 |
| `sp_genera_archivo_presencod47` | bdicnweb | 2 | Error en la ejecucion del sp bditef:sp_cce_guardar_encabezado |
| `sp_procesarsolicitudmc` | bdicnweb | 2 | Error en la ejecucion del sp bdicnweb:sp_solicitudprocesandomc |
| `sp_ro_procesararchivoxml` | bdicnweb | 2 | Error en la ejecucion del sp |
| `sp_genera_folioactivacion_bpi` | bdinteg | 2 | Cálculo con umbral/factor 60 |
| `sp_portabprocesaalta` | bdicheq | 1 | Se valida que el estatus no este cancelada |
| `sp_actualizaprocesoconau` | bdicnweb | 1 | Error en la ejecucion del sp bditarjeta:sp_concreing_actualizaproceso |
| `sp_ca_detallearchivosxmlnoprocesados` | bdicnweb | 1 | Retorna código de error 1001 |
| `sp_ca_detallearchivosxmlprocesados` | bdicnweb | 1 | Retorna código de error 1001 |
| `sp_ca_ejecutacargaautomaticaxml` | bdicnweb | 1 | Error en la ejecucion del sp bdimnsj:sp_registra_evento |
| `sp_ca_ejecutacargaautomaticaxmlpba` | bdicnweb | 1 | Error en la ejecucion del sp bdimnsj:sp_registra_evento |
| `sp_ca_ejecutacargaautomaticaxmlpbanew` | bdicnweb | 1 | Error en la ejecucion del sp bdimnsj:sp_registra_evento |
| `sp_ca_procesaarchivoxml` | bdicnweb | 1 | Error en la ejecucion del sp |
| `sp_conslotesmasivo` | bdicnweb | 1 | No se obtuvieron resultados |
| `sp_consultasolicitudprocesomc` | bdicnweb | 1 | Retorna código de error 90000 |
| `sp_consultausuariocteprocesandomc` | bdicnweb | 1 | Retorna código de error 90000 |

### ATENCION_CLIENTE

| SP | DB | # Reglas | Explicación representativa |
|----|----|----------|----------------------------|
| `sp_cargoxajuste_debcred` | bdiaclaracion | 3 | Intento de cargo con crédito vencido "bt" y bloqueado |
| `sp_registra_comentario_cliente` | bdiaclaracion | 3 | La invocaciã³n debe tener algãºn valor |
| `sp_relaciona_folioacl_idacl` | bdiaclaracion | 3 | La invocaciã³n debe tener algãºn valor |
| `sp_validapassword` | bdiaclaracion | 2 | El usuario no existe |
| `sp_acl_insertalog` | bdiaclaracion | 1 | Retorna código de error 99999 |
| `sp_acl_transacc_movs_origen` | bdiaclaracion | 1 |  |
| `sp_buscaqueda_folio_csuac` | bdiaclaracion | 1 | Retorna código de error 1001 |
| `sp_change_password` | bdiaclaracion | 1 | Retorna código de error 99999 |
| `sp_documentos_faltantes` | bdiaclaracion | 1 |  |
| `sp_documentos_faltantes_canales` | bdiaclaracion | 1 |  |
| `sp_obten_estatus_canales` | bdiaclaracion | 1 | El estatus de la aclaración no puede ser nulo |
| `sp_obten_estatus_canales_sms` | bdiaclaracion | 1 | El estatus de la aclaraciã³n no puede ser nulo |
| `sp_validafuncionalidades2` | bdiaclaracion | 1 | Retorna código de error 1001 |

---

## Sección C — Índice Regulatorio

Para cada organismo regulador, los 15 SPs con mayor número de reglas con anotación de ese regulador.

### Banxico

| SP | DB | # Reglas reg. | Top norma |
|----|----|--------------|-----------|
| `spei_pasemovspeich_2` | bdispei | 4 | SPEI Reglas técnicas — irrevocabilidad, clave rastreo, ventana 07:00-17:30, SLA ... |
| `spei_actualizamovspeich` | bdispei | 3 | SPEI Reglas técnicas — irrevocabilidad, clave rastreo, ventana 07:00-17:30, SLA ... |
| `spei_devcodi` | bdispei | 3 | SPEI Reglas técnicas — irrevocabilidad, clave rastreo, ventana 07:00-17:30, SLA ... |
| `spei_pasemovspeich` | bdispei | 3 | SPEI Reglas técnicas — irrevocabilidad, clave rastreo, ventana 07:00-17:30, SLA ... |
| `sp_genrep_cons_spei_aud` | bdicnweb | 2 | SPEI Reglas técnicas — irrevocabilidad, clave rastreo, ventana 07:00-17:30, SLA ... |
| `sp_regordenpagospei_pp` | bdispei | 2 | SPEI Reglas técnicas — irrevocabilidad, clave rastreo, ventana 07:00-17:30, SLA ... |
| `spei_actualizamovspeich_2` | bdispei | 2 | SPEI Reglas técnicas — irrevocabilidad, clave rastreo, ventana 07:00-17:30, SLA ... |
| `spei_calculointeres` | bdispei | 2 | SPEI Reglas técnicas — irrevocabilidad, clave rastreo, ventana 07:00-17:30, SLA ... |
| `spei_calculointeres_pba` | bdispei | 2 | SPEI Reglas técnicas — irrevocabilidad, clave rastreo, ventana 07:00-17:30, SLA ... |
| `spei_concilia_cargos_ef` | bdispei | 2 | SPEI Reglas técnicas — irrevocabilidad, clave rastreo, ventana 07:00-17:30, SLA ... |
| `spei_concilia_cargos_ef_exp` | bdispei | 2 | SPEI Reglas técnicas — irrevocabilidad, clave rastreo, ventana 07:00-17:30, SLA ... |
| `spei_recordenpago` | bdispei | 2 | SPEI Reglas técnicas — irrevocabilidad, clave rastreo, ventana 07:00-17:30, SLA ... |
| `spei_recordenpago_ws` | bdispei | 2 | SPEI Reglas técnicas — irrevocabilidad, clave rastreo, ventana 07:00-17:30, SLA ... |
| `spei_ctaspropiasdevcodi` | bdicheq | 1 | SPEI Reglas técnicas — irrevocabilidad, clave rastreo, ventana 07:00-17:30, SLA ... |
| `sp_cg_actbancont` | bdicnweb | 1 | SPEI — confirmación bancos operadores; extemporáneo > 17:30 |

### CNBV

| SP | DB | # Reglas reg. | Top norma |
|----|----|--------------|-----------|
| `sp_mueve_aclaraciones_historico` | bdiaclaracion | 72 | Art.78 LIC — conservación de información 5 años (bitácoras y movimientos) |
| `sp_envio_camp_ctes_ctaspzo` | bdicobranza | 38 | CUB CNBV — calificación cartera vencida y constitución de reservas |
| `sp_envio_camp_ctes_ctasrev` | bdicobranza | 36 | CUB CNBV — calificación cartera vencida y constitución de reservas |
| `generaestadosdecuenta` | bdicred | 17 | CUB CNBV — calificación cartera vencida y constitución de reservas |
| `proyecta_pba` | bdicred | 17 | Criterios contables CNBV + GAT — cálculo de intereses/rendimientos |
| `sp_proyecta_creditos_web` | bdicred | 17 | Criterios contables CNBV + GAT — cálculo de intereses/rendimientos |
| `sp_genera_cintas_semanales` | bdiburo | 16 | LRSIC — Buró de Crédito; evaluación crediticia |
| `sp_genera_cintas_semanales_clon` | bdiburo | 16 | LRSIC — Buró de Crédito; evaluación crediticia |
| `sp_genera_cintas_semanales_cnr` | bdiburo | 16 | LRSIC — Buró de Crédito; evaluación crediticia |
| `sp_burofisicas_cortos_cnr` | bdiburo | 12 | LRSIC — Buró de Crédito; evaluación crediticia |
| `provisionlineacred_parte` | bdicred | 12 | CUB CNBV — calificación cartera vencida y constitución de reservas |
| `gencartconsumo` | bdicred | 11 | CUB B-5 — Reservas crediticias; Reserva = Saldo × PI × Severidad × Exposición |
| `generaestadosdecuenta_repro` | bdicred | 11 | CUB CNBV — calificación cartera vencida y constitución de reservas |
| `proyecta` | bdicred | 11 | Criterios contables CNBV + GAT — cálculo de intereses/rendimientos |
| `proyecta_web` | bdicred | 11 | Criterios contables CNBV + GAT — cálculo de intereses/rendimientos |

### CONDUSEF

| SP | DB | # Reglas reg. | Top norma |
|----|----|--------------|-----------|
| `sp_mueve_aclaraciones_historico` | bdiaclaracion | 107 | RECA/SAC — Reclamaciones; resolución ≤ 45 días calendario |
| `sp_sac_app_depuracion` | bdisac | 21 | RECA/SAC — Reclamaciones; resolución ≤ 45 días calendario |
| `sp_sac_insertaremesasnoconciliadaswu` | bdisac | 20 | RECA/SAC — Reclamaciones; resolución ≤ 45 días calendario |
| `sp_sv_aprovisionamiento_aclaraciones` | bdiaclaracion | 8 | RECA/SAC — Reclamaciones; resolución ≤ 45 días calendario |
| `sp_reportediarioacl` | bdiaclaracion | 7 | RECA/SAC — Reclamaciones; resolución ≤ 45 días calendario |
| `sp_reportediarioacl_2day` | bdiaclaracion | 7 | RECA/SAC — Reclamaciones; resolución ≤ 45 días calendario |
| `sp_calculaintaclaraciones` | bdicheq | 7 | RECA/SAC — Reclamaciones; resolución ≤ 45 días calendario |
| `sp_cierres_masivos_afectacion` | bdiaclaracion | 6 | RECA/SAC — Reclamaciones; resolución ≤ 45 días calendario |
| `sp_top20acl` | bdiaclaracion | 6 | RECA/SAC — Reclamaciones; resolución ≤ 45 días calendario |
| `sp_cargoxcomision_pm` | bdicheq | 6 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada en CONDUSEF |
| `sp_cargoxcomision_pm_comp2` | bdicheq | 6 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada en CONDUSEF |
| `sp_cargoxcomision_pm_esp` | bdicheq | 6 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada en CONDUSEF |
| `sp_cargoxcomision_pmcomp` | bdicheq | 6 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada en CONDUSEF |
| `sp_ejecutartransacciones` | bdiprog | 6 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada en CONDUSEF |
| `sp_ejecutartransacciones_inc` | bdiprog | 6 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada en CONDUSEF |

### IPAB

| SP | DB | # Reglas reg. | Top norma |
|----|----|--------------|-----------|
| `sp_repipab_parte1` | bdinteg | 8 | LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs por titular; etiquet... |
| `sp_repipab_parte10` | bdinteg | 8 | LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs por titular; etiquet... |
| `sp_repipab_parte4` | bdinteg | 8 | LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs por titular; etiquet... |
| `sp_repipab_parte5` | bdinteg | 8 | LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs por titular; etiquet... |
| `sp_repipab_parte6` | bdinteg | 8 | LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs por titular; etiquet... |
| `sp_repipab_parte7` | bdinteg | 8 | LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs por titular; etiquet... |
| `sp_repipab_parte8` | bdinteg | 8 | LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs por titular; etiquet... |
| `sp_repipab_parte9` | bdinteg | 8 | LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs por titular; etiquet... |
| `sp_repchequesipab_temp` | bdinteg | 7 | LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs por titular; etiquet... |
| `sp_repchequesipab_temp_esp` | bdinteg | 7 | LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs por titular; etiquet... |
| `sp_repchequesipab_temp_esp2` | bdinteg | 7 | LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs por titular; etiquet... |
| `sp_repipab_direc_pte1` | bdinteg | 5 | LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs por titular; etiquet... |
| `sp_repipab_direc_pte2` | bdinteg | 5 | LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs por titular; etiquet... |
| `sp_repipab_direc_pte3` | bdinteg | 5 | LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs por titular; etiquet... |
| `sp_ipab_prueba` | bdinteg | 4 | LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs por titular; etiquet... |

### SAT

| SP | DB | # Reglas reg. | Top norma |
|----|----|--------------|-----------|
| `sp_genera_reporte_tc_inactivas` | bdicred | 10 | LIVA — IVA sobre comisiones (16% / 8% frontera) |
| `sp_genera_reporte_tc_inactivas_pba` | bdicred | 10 | LIVA — IVA sobre comisiones (16% / 8% frontera) |
| `sp_generaredoctaeje_factelect_esp` | bdicheq | 5 | LISR Art.54/135 — retención ISR sobre intereses (tasa 2026 = 0.90% anual) |
| `sp_calcsdo_ctasinactivas` | bdicheq | 4 | LISR Art.54/135 — retención ISR sobre intereses (tasa 2026 = 0.90% anual) |
| `sp_generaredoctaeje_factelect_cuenta` | bdicheq | 4 | LISR Art.54/135 — retención ISR sobre intereses (tasa 2026 = 0.90% anual) |
| `sp_generaredoctaeje_factelect_esp_pru` | bdicheq | 4 | LISR Art.54/135 — retención ISR sobre intereses (tasa 2026 = 0.90% anual) |
| `sp_generaredoctaeje_factelectxcuenta` | bdicheq | 4 | LISR Art.54/135 — retención ISR sobre intereses (tasa 2026 = 0.90% anual) |
| `sp_repchequesipab_temp` | bdinteg | 4 | LISR Art.54/135 — retención ISR sobre intereses (tasa 2026 = 0.90% anual) |
| `sp_repchequesipab_temp_esp` | bdinteg | 4 | LISR Art.54/135 — retención ISR sobre intereses (tasa 2026 = 0.90% anual) |
| `sp_repchequesipab_temp_esp2` | bdinteg | 4 | LISR Art.54/135 — retención ISR sobre intereses (tasa 2026 = 0.90% anual) |
| `sp_generaredoctaeje_factelect_transfer` | bditransfer | 4 | LISR Art.54/135 — retención ISR sobre intereses (tasa 2026 = 0.90% anual) |
| `calc_isr` | bdicheq | 3 | LISR Art.54/135 — retención ISR sobre intereses (tasa 2026 = 0.90% anual) |
| `cargo_ref_cel_pba` | bdicheq | 3 | LIVA — IVA sobre comisiones (16% / 8% frontera) |
| `sp_calcsdoctainactiva` | bdicheq | 3 | LISR Art.54/135 — retención ISR sobre intereses (tasa 2026 = 0.90% anual) |
| `sp_calculaintaclaraciones` | bdicheq | 3 | LISR Art.54/135 — retención ISR sobre intereses (tasa 2026 = 0.90% anual) |

### TESOFE

| SP | DB | # Reglas reg. | Top norma |
|----|----|--------------|-----------|
| `sp_afore_dispersion` | bdiprog | 4 | LTF — dispersión de recursos federales (pensiones, becas, apoyos) |
| `sp_dispersionnominavalidacionestatus` | bdicheq | 2 | LTF — dispersión de recursos federales (pensiones, becas, apoyos) |
| `sp_dispersionnominavalidacionestatus_bpi` | bdicheq | 2 | LTF — dispersión de recursos federales (pensiones, becas, apoyos) |
| `sp_aforedispersionautomatica` | bdiprog | 2 | LTF — dispersión de recursos federales (pensiones, becas, apoyos) |
| `sp_concilia_donativos_becalos` | bdicheq | 1 | LTF — dispersión de recursos federales (pensiones, becas, apoyos) |
| `sp_conciliaciondispersionnomina_his` | bdicheq | 1 | LTF — dispersión de recursos federales (pensiones, becas, apoyos) |
| `sp_dispersionlinea_bei` | bdicheq | 1 | LTF — dispersión de recursos federales (pensiones, becas, apoyos) |
| `sp_dispersionlinea_bpi` | bdicheq | 1 | LTF — dispersión de recursos federales (pensiones, becas, apoyos) |
| `sp_dispersionlinea_bpi_pba2` | bdicheq | 1 | LTF — dispersión de recursos federales (pensiones, becas, apoyos) |
| `sp_dispersionnominatransacciones` | bdicheq | 1 | LTF — dispersión de recursos federales (pensiones, becas, apoyos) |
| `sp_cg_cattipoconcentracion` | bdicnweb | 1 | LTF — concentración/dispersión fondos gobierno; conciliación diaria folio GDF |
| `sp_cg_conslistasolicitudesconcentracion` | bdicnweb | 1 | LTF — concentración/dispersión fondos gobierno; conciliación diaria folio GDF |
| `sp_cg_detallealtatipoconcentracion` | bdicnweb | 1 | LTF — concentración/dispersión fondos gobierno; conciliación diaria folio GDF |
| `sp_cg_detallebajatipoconcentracion` | bdicnweb | 1 | LTF — concentración/dispersión fondos gobierno; conciliación diaria folio GDF |
| `sp_cg_detallebitacoratipoconcentracion` | bdicnweb | 1 | LTF — concentración/dispersión fondos gobierno; conciliación diaria folio GDF |


# BCOPCore · Catálogo de Journeys y Términos de Negocio

> **Componente:** BCOPCore · SPE-AM-001 · Etapa 3 — Business Logic Extraction  
> **Base:** IBM Informix IDS 14.10 FC10W2 / POWER-AIX · **Evidencia:** `callgraph-data.json` + `journeys-data.json`  
> **Generado:** 2026-07-03 · **Método:** tokenización de nombres de SP contra vocabulario bancario es-MX (`sp_vocab.py`)  

> ⚠ **Los objetivos son inferidos por composición de tokens** — la estructura (cadena de SPs) es real; el nombre de negocio requiere validación `[CONSULTAR→NEGOCIO]`.  
> Marcas de confianza: `◔` = parcial (algún token inferido o fragmento no reconocido) · `🔶` = ambiguo, requiere DBA/Domain Expert.

---

## A · Lista de journeys por dominio

### D01 — Canal Digital Web  
`2122 SPs`

| SP (entry point) | Objetivo inferido | fan_out | reg |
|---|---|--:|:--:|
| `sp_cedulacontablenombre` | cédula contable y nombre ◔ | 124 |  |
| `sp_conscedulasusuariosccl` | consulta cédulas usuarios ◔ | 124 |  |
| `sp_consreportesctasinactivasart61` | consulta reportes cuentas inactivas · Art. 61 LIC | 124 |  |
| `sp_consreportesctasinactivasart61_totales` | consulta reportes cuentas inactivas (totales) · Art. 61 LIC | 124 |  |
| `sp_consultafechasart61` | consulta fechas · Art. 61 LIC | 124 |  |
| `sp_consultainforeportebc_detalleconsultas` | consulta información, reporte y detalle | 124 |  |
| `sp_obtieneultimasimagenesdigicte` | obtiene imágenes y cliente (últimas) ◔ | 124 |  |
| `sp_reportebloqueoctasmasivocre` | bloquea cuenta reporte, cuentas y crédito (masivo) ◔ | 124 |  |
| `sp_reportedesbloqueoctasmasivocre` | desbloquea cuenta reporte, cuentas y crédito (masivo) ◔ | 124 |  |
| `sp_usuariocedulacons` | consulta usuario y cédula de identificación | 124 |  |

### D02 — Integración y Auth  
`220 SPs` · reg: CNBV

| SP (entry point) | Objetivo inferido | fan_out | reg |
|---|---|--:|:--:|
| `sp_cuentadoctos_soc` | cuenta, documentos y Sistema Operativo Central | 2 |  |
| `sp_dicta_consultactesdictamen2` | consulta clientes y dictamen ◔ | 3 |  |
| `sp_doctosfusionados` | documentos (fusionados) | 5 |  |
| `sp_obthuellasactes` | obtiene huellas biométricas ◔ | 2 |  |
| `sp_desbctasfus_consctas` | desbloqueo cuentas ◔ | 4 |  |
| `sp_desbctasfus` | desbloqueo cuentas ◔ | 2 |  |
| `sp_desbctasfus_obtnombresupana` | desbloqueo cuentas y nombre ◔ | 4 |  |
| `sp_cnsif_consprodcte` | consulta producto de cliente ◔ | 15 |  |
| `sp_bloqueactas` | bloquea cuenta cuentas | 3 |  |
| `sp_dicta_modificaciondictamen` | modificación dictamen ◔ | 2 |  |

**Servicios expuestos (endpoints — sinks con alto fan-in):**

| SP | Objetivo inferido | callers ext | reg |
|---|---|--:|:--:|
| `sp_valida_perfil_usuario` | valida perfil de usuario y usuario | 388 |  |
| `sp_desc_ret` | sp_desc_ret ◔ | 356 |  |
| `sp_consultacoloniascp` | consulta colonias y código postal ◔ | 281 |  |
| `sp_dicta_actualizastatusalerta` | actualiza estatus y alerta ◔ | 270 |  |
| `sp_consultaciudades` | consulta ciudades | 265 |  |
| `sp_fustraspasotelefonos_soc` | fusión de cuentas teléfonos y Sistema Operativo Central ◔ | 239 |  |

### D03 — Créditos  
`380 SPs` · reg: CNBV · SAT · CONDUSEF

| SP (entry point) | Objetivo inferido | fan_out | reg |
|---|---|--:|:--:|
| `sp_mon_buro_conssolcredlincred2` | consulta Buró de Crédito, solicitud, crédito y línea de crédito ◔ | 6 |  |
| `sp_consulta_saldos_general` | consulta saldos (general) | 4 |  |
| `sp_consulta_subproducto` | consulta sub-producto | 8 |  |
| `sp_obtenerdoctosdigitalizar` | obtiene documentos | 4 |  |
| `sp_inserta_subproducto` | inserta sub-producto | 8 |  |
| `sp_consulta_productos` | consulta productos | 8 |  |
| `sp_consultacredbloqfallecimiento` | consulta crédito (por fallecimiento) ◔ | 3 |  |
| `sp_traspasocuentas_cred_soc` | traspaso entre cuentas cuenta, crédito y Sistema Operativo Central | 2 |  |
| `sp_consulta_sdo_apoyo` | consulta saldo ◔ | 4 |  |
| `sp_cac_consultasolincrelincred` | consulta solicitud de crédito, crédito y línea de crédito ◔ | 2 |  |

**Servicios expuestos (endpoints — sinks con alto fan-in):**

| SP | Objetivo inferido | callers ext | reg |
|---|---|--:|:--:|
| `sp_inserta_productos` | inserta productos | 304 |  |
| `sp_consulta_frecpago` | consulta frecuencia de pago | 303 |  |
| `sp_conspoliticacreditoprod` | consulta política de crédito, crédito y producto ◔ | 303 |  |
| `sp_mensajes_activos` | mensaje (activos) | 299 |  |
| `sp_eliminatemp` | elimina (temporal) | 286 |  |
| `sp_obtenctasmedioacceso` | obtiene cuentas y medio de acceso | 285 |  |

### D04 — Cheques / Cuentas  
`111 SPs` · reg: CNBV · TESOFE · IPAB · CONDUSEF

| SP (entry point) | Objetivo inferido | fan_out | reg |
|---|---|--:|:--:|
| `cargo_ref` | cargo ◔ | 27 |  |
| `abono_ref` | abono ◔ | 7 |  |
| `reversion` | reversa | 18 |  |
| `bloqueo_cta` | bloquea cuenta cuenta | 14 |  |
| `ischar` | ischar ◔ | 97 |  |
| `cargo_ref_pos` | cargo y punto de venta ◔ | 28 |  |
| `cargon_ref` | cargo ◔ | 24 |  |
| `cargon_ref_web` | cargo (canal web) ◔ | 24 |  |
| `sp_nom_gendata_disp` | genera nómina ◔ | 23 |  |
| `sp_nom_gen_mov_mes` | genera nómina, movimiento y mes ◔ | 23 |  |

**Servicios expuestos (endpoints — sinks con alto fan-in):**

| SP | Objetivo inferido | callers ext | reg |
|---|---|--:|:--:|
| `sp_cons_sdodisp_x_tpcalculo` | consulta saldo disponible y tipo de cálculo | 55 |  |

### D05 — Saldos y Cuentas  
`145 SPs` · reg: CNBV · IPAB · SAT

| SP (entry point) | Objetivo inferido | fan_out | reg |
|---|---|--:|:--:|
| `sp_validanombenefbts` | valida nómina, beneficiario y beneficiarios ◔ | 3 |  |
| `sp_obtieneparametro` | obtiene parámetro | 3 |  |
| `sp_validarembtsensac` | valida beneficiarios ◔ | 7 |  |
| `sp_app_queryorder` | ordenante (canal app) ◔ | 14 |  |
| `sp_sac_wu_guardarespuesta_search` | guarda respuesta y archivo ◔ | 3 |  |
| `sp_app_valdigito` | dígito verificador (canal app) ◔ | 3 |  |
| `sp_app_submitpayreversal` | (canal app, sub-, tipo) ◔ | 2 |  |
| `sp_app_submitpayment` | (canal app, sub-, tipo) ◔ | 2 |  |
| `sp_app_obtieneinfoidentificacion` | obtiene información y identificación (canal app) | 5 |  |
| `sp_bts_obtieneinfoidentificacion` | obtiene beneficiarios, información y identificación ◔ | 2 |  |

**Servicios expuestos (endpoints — sinks con alto fan-in):**

| SP | Objetivo inferido | callers ext | reg |
|---|---|--:|:--:|
| `sp_validabts` | valida beneficiarios ◔ | 182 |  |
| `sp_consinfobtssif` | consulta información y beneficiarios ◔ | 162 |  |
| `sp_sac_consucursales` | consulta ◔ | 157 |  |

### D06 — Solicitudes  
`84 SPs` · reg: CNBV · CONDUSEF

| SP (entry point) | Objetivo inferido | fan_out | reg |
|---|---|--:|:--:|
| `determina_lincred_tc_cjunk` | determina línea de crédito ◔ | 6 |  |
| `califica_scoring2_cjunk` | califica scoring crediticio ◔ | 19 |  |
| `califica_scoring_cjunk` | califica scoring crediticio ◔ | 17 |  |
| `califica_scoring_cjunk_motor` | califica scoring crediticio y motor de decisión ◔ | 16 |  |
| `califica_scoring_cjunk_precal_opt` | califica scoring crediticio ◔ | 16 |  |
| `califica_scoring_cjunk_pbagh` | califica scoring crediticio ◔ | 15 |  |
| `califica_scoring_cjunk_precal` | califica scoring crediticio ◔ | 15 |  |
| `califica_scoring_cjunk_precal_opt_motor` | califica scoring crediticio y motor de decisión ◔ | 15 |  |
| `califica_scoring_cjunk_pba` | califica scoring crediticio ◔ | 14 |  |
| `sp_obtiene_productos` | obtiene productos | 9 |  |

**Servicios expuestos (endpoints — sinks con alto fan-in):**

| SP | Objetivo inferido | callers ext | reg |
|---|---|--:|:--:|
| `sp_asigna_solicitud_soc` | asigna solicitud y Sistema Operativo Central | 236 |  |
| `sp_consultarfacturacionos2` | consulta facturación ◔ | 168 |  |
| `sp_cons_empleado_mc` | consulta empleado | 148 |  |
| `sp_elimina_emp_mc` | elimina ◔ | 144 |  |
| `sp_obtienecompingresos_mc` | obtiene ingreso (complemento) | 139 |  |

### D07 — Aclaraciones  
`84 SPs` · reg: CONDUSEF · CNBV

| SP (entry point) | Objetivo inferido | fan_out | reg |
|---|---|--:|:--:|
| `sp_fal_busca_beneficiarios_por_cuenta` | busca beneficiarios y cuenta ◔ | 20 |  |
| `sp_fal_busca_documentos_faltantes` | busca documentos (faltantes) ◔ | 20 |  |
| `sp_fal_busca_pagares_cliente` | busca pagarés y cliente ◔ | 20 |  |
| `sp_fal_busca_producto_deb_cheq_cliente` | busca producto, cheque y cliente (débito) ◔ | 20 |  |
| `sp_fal_busca_producto_deb_cheq_cliente_1` | busca producto, cheque y cliente (débito) ◔ | 20 |  |
| `sp_fal_busca_producto_deb_cheq_cliente_2` | busca producto, cheque y cliente (débito) ◔ | 20 |  |
| `sp_fal_busca_producto_deb_cheq_cliente_3` | busca producto, cheque y cliente (débito) ◔ | 20 |  |
| `sp_fal_busca_producto_pcuenta_deb_cte_fallecido` | busca producto, cuenta, cliente y identificador (débito) ◔ | 20 |  |
| `sp_fal_cancelacion_cuenta_debito` | cancela cuenta (débito) ◔ | 20 |  |
| `sp_fal_consulta_ciudades` | consulta ciudades ◔ | 17 |  |

### D08 — SPEI  
`46 SPs` · reg: Banxico

| SP (entry point) | Objetivo inferido | fan_out | reg |
|---|---|--:|:--:|
| `spei_aplicaordenpago` | aplica orden de pago | 15 | 🔴 |
| `spei_reccancelacion` | recibe cancelación | 14 | 🔴 |
| `spei_recdevolucion` | recibe devolución | 14 | 🔴 |
| `spei_recextemporanea` | recibe orden extemporánea | 14 | 🔴 |
| `spei_recordenpago` | recibe orden de pago | 14 | 🔴 |
| `spei_recordenpago_ws` | recibe orden de pago | 12 | 🔴 |
| `spei_devcodi` | devolución · CoDi — Cobro Digital | 10 | 🔴 |
| `spei_recerrorescodi` | recepción error · CoDi — Cobro Digital | 10 | 🔴 |
| `sp_regordenctecte_bex_codi_exp1` | orden y cliente · CoDi — Cobro Digital ◔ | 10 |  |
| `sp_regordenctecte_bex_codi` | orden y cliente · CoDi — Cobro Digital ◔ | 9 |  |

### D09 — Mensajería  
`1 SPs` · reg: CNBV · CONDUSEF

**Servicios expuestos (endpoints — sinks con alto fan-in):**

| SP | Objetivo inferido | callers ext | reg |
|---|---|--:|:--:|
| `sp_registra_evento` | registra evento/notificación | 1398 |  |

### D10 — Sucursales  
`37 SPs` · reg: CNBV

| SP (entry point) | Objetivo inferido | fan_out | reg |
|---|---|--:|:--:|
| `pasecont_web_2` | realiza el pase contable (canal web) | 2 |  |
| `sp_reiniciapaseatm` | reinicia cajero automático | 2 |  |

**Servicios expuestos (endpoints — sinks con alto fan-in):**

| SP | Objetivo inferido | callers ext | reg |
|---|---|--:|:--:|
| `sp_consultadatospiezas_bym3` | consulta datos, piezas de efectivo y Billetes y Monedas ◔ | 381 |  |
| `sp_consutacat_dictamen_bym` | consulta catálogo [typo] dictamen y Billetes y Monedas ◔ | 378 |  |
| `sp_consultadatospiezas_bym3_totales` | consulta datos, piezas de efectivo y Billetes y Monedas (totales) ◔ | 376 |  |
| `sp_consultadatospiezas_bym2` | consulta datos, piezas de efectivo y Billetes y Monedas ◔ | 376 |  |
| `sp_consultacat_estatus_bym` | consulta catálogo, estatus y Billetes y Monedas ◔ | 375 |  |
| `sp_consulta_catdenominacion_bym` | consulta catálogo de denominaciones y Billetes y Monedas ◔ | 374 |  |

### D11 — Cobranza  
`82 SPs` · reg: CNBV · CONDUSEF

| SP (entry point) | Objetivo inferido | fan_out | reg |
|---|---|--:|:--:|
| `fn_formaretiquetaxml` | construye etiqueta y XML ◔ | 43 |  |
| `sp_generafechpagoreestructura_baja` | genera fecha de pago de reestructura (de baja) | 8 |  |
| `sp_cilocconsultaalertas` | consulta local alertas | 6 |  |
| `sp_cilocconsultamarcas` | consulta local marcas de cuenta | 6 |  |
| `sp_cilocconsultasituacionesmarcas` | consulta local situaciones de cuenta y marcas de cuenta | 6 |  |
| `sp_cilocgenerarptalertascte` | genera reporte, alertas y cliente ◔ | 6 |  |
| `sp_cilocgenerarptmarcascte` | genera reporte, marcas de cuenta y cliente ◔ | 6 |  |
| `sp_cilocgenerarptsituacioncausacte` | genera reporte, causa y cliente ◔ | 6 |  |
| `sp_cilocgenerarpttotalalarmas` | genera reporte (total) ◔ | 6 |  |
| `sp_cilocgenerarpttotalmarcas` | genera reporte y marcas de cuenta (total) ◔ | 6 |  |

**Servicios expuestos (endpoints — sinks con alto fan-in):**

| SP | Objetivo inferido | callers ext | reg |
|---|---|--:|:--:|
| `sp_inserta_bitacora_cob` | inserta bitácora ◔ | 197 |  |

### D12 — Contabilidad  
`19 SPs` · reg: SAT · IPAB · CNBV

| SP (entry point) | Objetivo inferido | fan_out | reg |
|---|---|--:|:--:|
| `sp_cont_conssaldosdiariosb4` | consulta saldos diarios ◔ | 84 |  |
| `sp_cont_productotransaccionb5` | producto-transacción ◔ | 72 |  |
| `sp_cont_cargamovimientob3` | carga movimiento ◔ | 63 |  |
| `sp_cont_catalogob3` | catálogo ◔ | 55 |  |
| `sp_cont_divisasb4` | divisas ◔ | 55 |  |
| `sp_cont_empresasb3` | empresas ◔ | 55 |  |
| `sp_gen_devob3` | genera ◔ | 55 |  |
| `sp_si_empresasb4` | empresas ◔ | 55 |  |
| `sp_cam_cargamanualb3` | carga manual ◔ | 50 |  |
| `sp_cam_monitorarchivosb3` | monitor y archivo ◔ | 37 |  |

---

## B · Catálogo de términos (glosario tokenizado)

Cada nombre de SP se descompone en **prefijo + acción + entidad + modificador**. Este glosario permite componer el objetivo de cualquier SP nuevo sin re-analizarlo a mano — editar `sp_vocab.py` y re-correr `extract-journeys.py` + `build-catalog.py`.

Estado: `conf` = confirmado por evidencia · `inf` = inferido (probable) · `gap` = ambiguo, requiere SME/DBA.

### Prefijos / familia

| Término | Significado | Estado | Frec |
|---|---|:--:|--:|
| `sp` | stored procedure | conf | 105 |
| `fal` | faltantes / documentación de expediente | inf | 11 |
| `spei` | familia SPEI (pagos interbancarios) | conf | 8 |
| `cont` | familia contabilidad | conf | 6 |
| `ciloc` | consulta local de cobranza | inf | 5 |
| `dicta` | dictamen (aclaraciones/crédito) | inf | 3 |
| `cam` | cámara / captura contable | inf | 2 |
| `cac` | familia crédito (CAC) | inf | 1 |
| `cnsif` | consulta SIF (bus de integración) | inf | 1 |
| `fn` | función SQL | conf | 1 |
| `mon` | monitor / módulo | inf | 1 |
| `acl` | familia aclaraciones | conf | 0 |

### Acciones (verbos)

| Término | Significado | Estado | Frec |
|---|---|:--:|--:|
| `consulta` | consulta / lee | conf | 20 |
| `busca` | busca / localiza | conf | 8 |
| `califica` | califica / evalúa (scoring) | conf | 8 |
| `cons` | consulta | conf | 8 |
| `obtiene` | obtiene / recupera | conf | 6 |
| `genera` | genera / produce | conf | 5 |
| `fus` | fusión de cuentas | inf | 4 |
| `rec` | recepción / recibe | conf | 4 |
| `valida` | valida | conf | 4 |
| `desb` | desbloqueo | inf | 3 |
| `gen` | genera / general | inf | 3 |
| `inserta` | inserta / registra | conf | 3 |
| `bloqueo` | bloquea cuenta | conf | 2 |
| `consreportes` | consulta reportes | conf | 2 |
| `dev` | devolución | conf | 2 |
| `elimina` | elimina | conf | 2 |
| `obt` | obtiene | inf | 2 |
| `traspaso` | traspaso entre cuentas | conf | 2 |
| `act` | actualiza | conf | 1 |
| `actualiza` | actualiza | conf | 1 |
| `asigna` | asigna | conf | 1 |
| `bloq` | bloqueo | inf | 1 |
| `bloquea` | bloquea cuenta | conf | 1 |
| `cancelacion` | cancela | conf | 1 |
| `desbloqueo` | desbloquea cuenta | conf | 1 |
| `determina` | determina | conf | 1 |
| `digi` | digitalización | inf | 1 |
| `digitalizar` | digitaliza documento | conf | 1 |
| `forma` | construye / arma | inf | 1 |
| `guarda` | guarda / almacena | conf | 1 |
| `modificacion` | modificación | conf | 1 |
| `obten` | obtiene / recupera | conf | 1 |
| `obtener` | obtiene / recupera | conf | 1 |
| `pase` | pase contable (registra/traslada a póliza o mayor) | conf | 1 |
| `pasecont` | realiza el pase contable (registro a póliza/mayor) | conf | 1 |
| `registra` | registra | conf | 1 |
| `reinicia` | reinicia / resetea | conf | 1 |
| `reversion` | reversa / rollback | conf | 1 |
| `activa` | activa | conf | 0 |
| `activar` | activar | conf | 0 |
| `alta` | da de alta / registra | conf | 0 |
| `aplica` | aplica / ejecuta | conf | 0 |
| `aplicar` | aplica / ejecuta | conf | 0 |
| `autoriza` | autoriza | conf | 0 |
| `busqueda` | búsqueda | conf | 0 |
| `cancela` | cancela | conf | 0 |
| `captura` | captura | conf | 0 |
| `carga` | carga / ingresa | conf | 0 |
| `cierre` | cierre | conf | 0 |
| `cns` | consulta | inf | 0 |
| `con` | consulta | inf | 0 |
| `concentracion` | concentración de fondos | conf | 0 |
| `conciliacion` | conciliación | conf | 0 |
| `confirma` | confirma | conf | 0 |
| `consreporte` | consulta reporte | conf | 0 |
| `consuta` | consulta [typo] | conf | 0 |
| `decodifica` | decodifica | conf | 0 |
| `decodificar` | decodifica | conf | 0 |
| `depura` | depura / limpia | conf | 0 |
| `depuracion` | depuración | conf | 0 |
| `desbloquea` | desbloquea cuenta | conf | 0 |
| `devolucion` | devuelve | conf | 0 |
| `envia` | envía | conf | 0 |
| `envio` | envía | conf | 0 |
| `fusion` | fusiona cuentas | conf | 0 |
| `graba` | graba / almacena | conf | 0 |
| `inicia` | inicia | conf | 0 |
| `inicializa` | inicializa | conf | 0 |
| `inicializar` | inicializa | conf | 0 |
| `modifica` | modifica | conf | 0 |
| `notifi` | notifica | inf | 0 |
| `notifica` | notifica | conf | 0 |
| `ope` | operación | inf | 0 |
| `operacion` | operación | conf | 0 |
| `pasecheq` | pase de cheque (a compensación/conciliación) | conf | 0 |
| `presenta` | presenta | conf | 0 |
| `procede` | procede | conf | 0 |
| `procesa` | procesa | conf | 0 |
| `recupera` | recupera estado | conf | 0 |
| `recuperacion` | recuperación (cobranza) | conf | 0 |
| `reestructura` | reestructura crédito | conf | 0 |
| `reinicio` | reinicio | conf | 0 |
| `reverso` | reverso | conf | 0 |
| `suscriptores` | gestiona suscriptores | conf | 0 |
| `traspas` | traspaso | inf | 0 |
| `upgrade` | actualiza producto (upgrade) | inf | 0 |
| `valid` | valida | inf | 0 |
| `validacion` | validación | conf | 0 |
| `verifica` | verifica | conf | 0 |

### Entidades (objetos de negocio)

| Término | Significado | Estado | Frec |
|---|---|:--:|--:|
| `cte` | cliente | conf | 9 |
| `ctas` | cuentas | conf | 8 |
| `scoring` | scoring crediticio | conf | 8 |
| `bts` | beneficiarios (BTS) | inf | 5 |
| `cliente` | cliente | conf | 5 |
| `cuenta` | cuenta | conf | 5 |
| `producto` | producto | conf | 5 |
| `rpt` | reporte | conf | 5 |
| `cargo` | cargo / débito | conf | 4 |
| `cheq` | cheque | conf | 4 |
| `info` | información | conf | 4 |
| `marcas` | marcas de cuenta | conf | 4 |
| `soc` | Sistema Operativo Central (SOC) — confirmado SME | conf | 4 |
| `bym` | Billetes y Monedas (efectivo en sucursal — evidencia: 'piezas' + 'denominación') | inf | 3 |
| `cre` | crédito | inf | 3 |
| `cred` | crédito | conf | 3 |
| `datos` | datos | conf | 3 |
| `dictamen` | dictamen | conf | 3 |
| `doctos` | documentos | conf | 3 |
| `lincred` | línea de crédito | conf | 3 |
| `nom` | nómina | inf | 3 |
| `piezas` | piezas de efectivo (billetes y monedas) | conf | 3 |
| `productos` | productos | conf | 3 |
| `reporte` | reporte | conf | 3 |
| `alertas` | alertas | conf | 2 |
| `bym3` | Billetes y Monedas (v3) | inf | 2 |
| `ciudades` | ciudades (catálogo) | conf | 2 |
| `empresas` | empresas (nómina empresarial) | conf | 2 |
| `identificacion` | identificación | conf | 2 |
| `motor` | motor de decisión | conf | 2 |
| `nombre` | nombre | conf | 2 |
| `orden` | orden | conf | 2 |
| `subproducto` | sub-producto | conf | 2 |
| `usuario` | usuario | conf | 2 |
| `abono` | abono / crédito | conf | 1 |
| `alerta` | alerta | conf | 1 |
| `arch` | archivo | inf | 1 |
| `archivo` | archivo | conf | 1 |
| `atm` | cajero automático (ATM) | conf | 1 |
| `benef` | beneficiario | conf | 1 |
| `beneficiarios` | beneficiarios | conf | 1 |
| `bitacora` | bitácora | conf | 1 |
| `buro` | Buró de Crédito | conf | 1 |
| `bym2` | Billetes y Monedas (v2) | inf | 1 |
| `cat` | catálogo | conf | 1 |
| `catalogo` | catálogo | conf | 1 |
| `catdenominacion` | catálogo de denominaciones | conf | 1 |
| `causa` | causa / motivo | conf | 1 |
| `cedula` | cédula de identificación | conf | 1 |
| `colonias` | colonias (catálogo domicilio) | conf | 1 |
| `cp` | código postal | inf | 1 |
| `credito` | crédito | conf | 1 |
| `cta` | cuenta | conf | 1 |
| `ctes` | clientes | conf | 1 |
| `detalle` | detalle | conf | 1 |
| `digito` | dígito verificador | conf | 1 |
| `divisas` | divisas | conf | 1 |
| `documentos` | documentos | conf | 1 |
| `empleado` | empleado | conf | 1 |
| `error` | error | conf | 1 |
| `estatus` | estatus | conf | 1 |
| `etiqueta` | etiqueta | conf | 1 |
| `evento` | evento/notificación | conf | 1 |
| `facturacion` | facturación | conf | 1 |
| `fechas` | fechas | conf | 1 |
| `frecpago` | frecuencia de pago | conf | 1 |
| `huellas` | huellas biométricas | conf | 1 |
| `id` | identificador (de) | conf | 1 |
| `imagenes` | imágenes / documentos digitales | conf | 1 |
| `ingreso` | ingreso (del solicitante) | conf | 1 |
| `medioacceso` | medio de acceso | conf | 1 |
| `mensaje` | mensaje | conf | 1 |
| `mes` | mes | conf | 1 |
| `monitor` | monitor | conf | 1 |
| `mov` | movimiento | conf | 1 |
| `ord` | ordenante / orden (SPEI) | conf | 1 |
| `pagares` | pagarés | conf | 1 |
| `parametro` | parámetro | conf | 1 |
| `perfil` | perfil de usuario | conf | 1 |
| `politica` | política de crédito | inf | 1 |
| `pos` | punto de venta (POS) | conf | 1 |
| `prod` | producto | inf | 1 |
| `respuesta` | respuesta | conf | 1 |
| `saldos` | saldos | conf | 1 |
| `sdo` | saldo | conf | 1 |
| `sdodisp` | saldo disponible | conf | 1 |
| `situaciones` | situaciones de cuenta | conf | 1 |
| `sol` | solicitud | inf | 1 |
| `solicitud` | solicitud | conf | 1 |
| `solin` | solicitud de crédito | inf | 1 |
| `status` | estatus | conf | 1 |
| `telefonos` | teléfonos | conf | 1 |
| `tpcalculo` | tipo de cálculo | conf | 1 |
| `usuarios` | usuarios | conf | 1 |
| `xml` | XML | conf | 1 |
| `acceso` | acceso | inf | 0 |
| `afore` | AFORE (Afore Coppel — 2ª mayor de México, ~14.5M cuentas) | conf | 0 |
| `analista` | analista | conf | 0 |
| `anio` | año | conf | 0 |
| `apell` | apellido | inf | 0 |
| `apellido` | apellido | conf | 0 |
| `apertura` | apertura (de cuenta/crédito) | conf | 0 |
| `apoderado` | apoderado | conf | 0 |
| `asiento` | asiento contable | conf | 0 |
| `atms` | cajeros automáticos (ATM) | conf | 0 |
| `aud` | auditoría | inf | 0 |
| `auditoria` | auditoría | conf | 0 |
| `autenticacion` | autenticación | conf | 0 |
| `aval` | aval / garante | conf | 0 |
| `banco` | banco | conf | 0 |
| `beneficiario` | beneficiario (receptor del pago SPEI) | conf | 0 |
| `biometrico` | biométrico | conf | 0 |
| `boveda` | bóveda | conf | 0 |
| `caja` | caja / ventanilla | conf | 0 |
| `calculo` | cálculo | conf | 0 |
| `calle` | calle (domicilio) | conf | 0 |
| `canal` | canal | conf | 0 |
| `cant` | cantidad | conf | 0 |
| `cantidad` | cantidad | conf | 0 |
| `cartera` | cartera de crédito | conf | 0 |
| `categoria` | categoría | conf | 0 |
| `cedulas` | cédulas | conf | 0 |
| `cel` | celular | conf | 0 |
| `cep` | Comprobante Electrónico de Pago (SPEI · Banxico) | conf | 0 |
| `cheque` | cheque | conf | 0 |
| `cheques` | cheques | conf | 0 |
| `cita` | cita | conf | 0 |
| `citas` | citas | conf | 0 |
| `ciudad` | ciudad | conf | 0 |
| `clabe` | CLABE interbancaria | conf | 0 |
| `clave` | clave | conf | 0 |
| `claverastreo` | clave de rastreo SPEI (hasta 30 posiciones alfanuméricas, Banxico) | conf | 0 |
| `clic` | BanCoppel Clic (tarjeta digital instantánea) | conf | 0 |
| `cod` | código | conf | 0 |
| `codificacion` | codificación | conf | 0 |
| `codigo` | código | conf | 0 |
| `codigos` | códigos | conf | 0 |
| `combo` | combo / lista desplegable (control de UI en app) | conf | 0 |
| `comercio` | comercio afiliado | conf | 0 |
| `concentradora` | cuenta concentradora | conf | 0 |
| `concepto` | concepto de pago | conf | 0 |
| `conciliadora` | conciliadora | inf | 0 |
| `consecutivo` | consecutivo | conf | 0 |
| `convenio` | convenio (nómina/empresarial) | conf | 0 |
| `conyuge` | cónyuge (solicitud crédito) | conf | 0 |
| `coppel` | Coppel (grupo) | conf | 0 |
| `correo` | correo electrónico | conf | 0 |
| `corresponsal` | corresponsal | conf | 0 |
| `ctaclabe` | cuenta CLABE | conf | 0 |
| `cve` | clave (cve) | conf | 0 |
| `declaracion` | declaración | conf | 0 |
| `denominacion` | denominación (valor facial del billete/moneda) | conf | 0 |
| `denominaciones` | denominaciones | conf | 0 |
| `descarga` | descarga | conf | 0 |
| `descripcion` | descripción | conf | 0 |
| `destino` | destino | conf | 0 |
| `digitalizacion` | digitalización de documentos | conf | 0 |
| `direccion` | dirección | conf | 0 |
| `direcciones` | direcciones | conf | 0 |
| `divisa` | divisa | conf | 0 |
| `division` | división | conf | 0 |
| `docto` | documento | conf | 0 |
| `documento` | documento | conf | 0 |
| `domi` | domiciliación | inf | 0 |
| `domiciliacion` | domiciliación | conf | 0 |
| `domicilio` | domicilio | conf | 0 |
| `dotacion` | dotación de efectivo (a cajero/sucursal) | conf | 0 |
| `dotaciones` | dotaciones de efectivo | conf | 0 |
| `edo` | estado | inf | 0 |
| `efectiva` | Cuenta Efectiva Digital (débito BanCoppel) | conf | 0 |
| `efectivo` | efectivo | conf | 0 |
| `ejecucion` | ejecución (de proceso) | conf | 0 |
| `ejecutivo` | ejecutivo | conf | 0 |
| `emisor` | emisor | conf | 0 |
| `empresa` | empresa (entidad bancaria) | conf | 0 |
| `empresarial` | empresarial (nómina) | conf | 0 |
| `encabezado` | encabezado | conf | 0 |
| `estado` | estado (entidad federativa / estatus) | inf | 0 |
| `estatussolic` | estatus de solicitud | conf | 0 |
| `expediente` | expediente | conf | 0 |
| `factura` | factura | conf | 0 |
| `fecha` | fecha | conf | 0 |
| `fechaconsulta` | fecha de consulta | conf | 0 |
| `fechafin` | fecha fin | conf | 0 |
| `fechafinal` | fecha final | conf | 0 |
| `fechainicial` | fecha inicial | conf | 0 |
| `fechainicio` | fecha inicio | conf | 0 |
| `firmas` | firmas mancomunadas | conf | 0 |
| `folio` | folio | conf | 0 |
| `folsuc` | folio de sucursal | conf | 0 |
| `garantia` | garantía | conf | 0 |
| `grupo` | grupo | conf | 0 |
| `hipoteca` | crédito hipotecario (digital, desde 2025) | conf | 0 |
| `hipotecario` | crédito hipotecario | conf | 0 |
| `hora` | hora | conf | 0 |
| `huella` | huella biométrica | conf | 0 |
| `idfuncion` | id de funcionalidad | conf | 0 |
| `idfuncionc` | id de funcionalidad | conf | 0 |
| `imagen` | imagen digital | conf | 0 |
| `importe` | importe | conf | 0 |
| `inf` | información | inf | 0 |
| `int` | interés | inf | 0 |
| `intercambio` | intercambio (interbancario) | conf | 0 |
| `interes` | interés | conf | 0 |
| `intereses` | intereses | conf | 0 |
| `inversion` | inversión (pagaré / plazo) | conf | 0 |
| `lin` | línea (de crédito) | inf | 0 |
| `linea` | línea (de crédito) | conf | 0 |
| `liquidacion` | liquidación | conf | 0 |
| `lote` | lote (proceso batch) | conf | 0 |
| `mac` | dirección MAC | conf | 0 |
| `mail` | correo electrónico | conf | 0 |
| `marca` | marca | conf | 0 |
| `mayor` | mayor contable | inf | 0 |
| `monto` | monto | conf | 0 |
| `motivo` | motivo / causa | conf | 0 |
| `movimiento` | movimiento | conf | 0 |
| `movimientos` | movimientos | conf | 0 |
| `movto` | movimiento | conf | 0 |
| `msi` | meses sin intereses (MSI) | conf | 0 |
| `msjafore` | mensaje AFORE | inf | 0 |
| `nacionalidad` | nacionalidad | conf | 0 |
| `nombreref` | nombre de referencia | conf | 0 |
| `nomina` | nómina | conf | 0 |
| `num` | número (de) | conf | 0 |
| `numcliente` | número de cliente | conf | 0 |
| `numcred` | número de crédito | conf | 0 |
| `numcredito` | número de crédito | conf | 0 |
| `numcte` | número de cliente | conf | 0 |
| `numcuenta` | número de cuenta | conf | 0 |
| `numempleado` | número de empleado | conf | 0 |
| `numerocliente` | número de cliente | conf | 0 |
| `numproducto` | número de producto | conf | 0 |
| `numsol` | número de solicitud | conf | 0 |
| `numsolicitud` | número de solicitud | conf | 0 |
| `numsucursal` | número de sucursal | conf | 0 |
| `numtarjeta` | número de tarjeta | conf | 0 |
| `ofi` | oficio | inf | 0 |
| `oficio` | oficio (requerimiento judicial/autoridad) | conf | 0 |
| `opcion` | opción | conf | 0 |
| `ordenante` | ordenante (pagador que emite la orden SPEI) | conf | 0 |
| `ordenes` | órdenes | conf | 0 |
| `ordenpago` | orden de pago | conf | 0 |
| `origen` | origen | conf | 0 |
| `oxxo` | OXXO (red de depósito/retiro) | conf | 0 |
| `pagare` | pagaré | conf | 0 |
| `pago` | pago | conf | 0 |
| `pais` | país | conf | 0 |
| `param` | parámetro | conf | 0 |
| `parametros` | parámetros | conf | 0 |
| `parentesco` | parentesco (referencia) | conf | 0 |
| `periodo` | periodo | conf | 0 |
| `pieza` | pieza de efectivo (billete/moneda) | conf | 0 |
| `pin` | PIN dinámico (tarjeta digital) | conf | 0 |
| `plantilla` | plantilla | conf | 0 |
| `plaza` | plaza (regional) | conf | 0 |
| `plazo` | plazo (depósito / crédito a plazo) | conf | 0 |
| `poliza` | póliza contable | conf | 0 |
| `presentacion` | presentación | conf | 0 |
| `prestamo` | préstamo (Personal / Nómina / Digital BanCoppel) | conf | 0 |
| `prestamos` | préstamos | conf | 0 |
| `proc` | proceso | inf | 0 |
| `proceso` | proceso | conf | 0 |
| `promocion` | promoción | conf | 0 |
| `propuesta` | propuesta | conf | 0 |
| `puntos` | puntos (recompensas) | conf | 0 |
| `quincena` | quincena (periodo de pago nómina/crédito Coppel) | conf | 0 |
| `rastreo` | rastreo (SPEI) | conf | 0 |
| `receptor` | receptor | conf | 0 |
| `recompensa` | recompensa / cashback (Coppel Max) | inf | 0 |
| `referencia` | referencia | conf | 0 |
| `region` | región | conf | 0 |
| `registro` | registro | conf | 0 |
| `registros` | registros | conf | 0 |
| `remesa` | remesa (Western Union / MoneyGram) | conf | 0 |
| `remesadora` | remesadora (envío de remesas) | conf | 0 |
| `remesas` | remesas internacionales | conf | 0 |
| `reportes` | reportes | conf | 0 |
| `resultado` | resultado | conf | 0 |
| `retiro` | retiro | conf | 0 |
| `retiros` | retiros | conf | 0 |
| `revision` | revisión | conf | 0 |
| `rfc` | RFC (registro fiscal) | conf | 0 |
| `rol` | rol / perfil | conf | 0 |
| `ruta` | ruta (de archivo) | conf | 0 |
| `saldo` | saldo | conf | 0 |
| `salida` | salida | conf | 0 |
| `sbc` | saldo básico de cuenta (SBC) | inf | 0 |
| `secuencia` | secuencia | conf | 0 |
| `servicio` | servicio | conf | 0 |
| `sistema` | sistema | conf | 0 |
| `sms` | SMS | conf | 0 |
| `solic` | solicitud | conf | 0 |
| `sorteo` | sorteo | conf | 0 |
| `sucursal` | sucursal | conf | 0 |
| `supervision` | supervisión | conf | 0 |
| `tarjeta` | tarjeta | conf | 0 |
| `tasa` | tasa (de interés) | conf | 0 |
| `tdc` | tarjeta de crédito (TDC) | conf | 0 |
| `tef` | TEF — transferencia electrónica de fondos | conf | 0 |
| `tel` | teléfono | conf | 0 |
| `telefono` | teléfono | conf | 0 |
| `titular` | titular de cuenta | conf | 0 |
| `titulo` | título | conf | 0 |
| `token` | token (autenticación) | conf | 0 |
| `transacc` | código de transacción | conf | 0 |
| `transaccion` | transacción | conf | 0 |
| `transportadora` | transportadora de valores (traslado de efectivo) | conf | 0 |
| `valor` | valor | conf | 0 |
| `venc` | vencimiento | inf | 0 |
| `vencimiento` | vencimiento | conf | 0 |
| `venio` | convenio | inf | 0 |
| `zona` | zona | conf | 0 |

### Modificadores

| Término | Significado | Estado | Frec |
|---|---|:--:|--:|
| `deb` | débito | conf | 6 |
| `app` | canal app | conf | 5 |
| `masivo` | masivo | conf | 2 |
| `sub` | sub- | inf | 2 |
| `total` | total | conf | 2 |
| `totales` | totales | conf | 2 |
| `tp` | tipo | conf | 2 |
| `web` | canal web | conf | 2 |
| `activos` | activos | conf | 1 |
| `baja` | de baja | conf | 1 |
| `comp` | complemento | conf | 1 |
| `fallecimiento` | por fallecimiento | conf | 1 |
| `faltantes` | faltantes | conf | 1 |
| `fusionados` | fusionados | conf | 1 |
| `general` | general | conf | 1 |
| `por` | por (criterio) | conf | 1 |
| `temp` | temporal | conf | 1 |
| `ultimas` | últimas | inf | 1 |
| `agendadas` | agendadas | conf | 0 |
| `aum` | aumento | inf | 0 |
| `aumento` | aumento | inf | 0 |
| `bandera` | bandera / flag (técnico) | conf | 0 |
| `bpi` | Banca Por Internet (canal web BPI) | conf | 0 |
| `central` | central | conf | 0 |
| `dia` | del día | conf | 0 |
| `diario` | diario | conf | 0 |
| `diarios` | diarios | conf | 0 |
| `dormidas` | cuentas dormidas (inactivas) | conf | 0 |
| `esp` | especial | conf | 0 |
| `extemporanea` | extemporánea | conf | 0 |
| `final` | final | conf | 0 |
| `firme` | monto firme | inf | 0 |
| `fisica` | persona física | conf | 0 |
| `fisicas` | personas físicas | conf | 0 |
| `forzada` | forzada | conf | 0 |
| `gral` | general | conf | 0 |
| `historico` | histórico | conf | 0 |
| `hoy` | de hoy / fecha actual | conf | 0 |
| `inactiv` | inactiva | conf | 0 |
| `inactivas` | inactivas (art.61) | conf | 0 |
| `inicial` | inicial | conf | 0 |
| `inicio` | inicio | conf | 0 |
| `inmediato` | inmediato | conf | 0 |
| `ivr` | canal IVR (telefónico) | conf | 0 |
| `local` | local | conf | 0 |
| `manual` | manual | conf | 0 |
| `masiva` | masiva | conf | 0 |
| `max` | máximo | conf | 0 |
| `mensual` | mensual | conf | 0 |
| `moral` | persona moral | conf | 0 |
| `movil` | canal móvil | conf | 0 |
| `mvl` | canal móvil | conf | 0 |
| `periodicidad` | periodicidad | conf | 0 |
| `presentado` | presentado (a cobro) | conf | 0 |
| `preventivo` | preventivo | conf | 0 |
| `primer` | primer | conf | 0 |
| `remanente` | remanente | inf | 0 |
| `suc` | sucursal | inf | 0 |
| `telefonico` | telefónico | conf | 0 |
| `tipo` | tipo de | conf | 0 |
| `visual` | visual | conf | 0 |

### Regulatorio

| Término | Significado | Estado | Frec |
|---|---|:--:|--:|
| `codi` | CoDi — Cobro Digital (Banxico) | conf | 4 |
| `art61` | Art. 61 LIC (cuentas inactivas cuyos saldos, tras años sin movimiento, prescriben a favor de la beneficencia pública) | conf | 3 |
| `comision` | comisión (CONDUSEF — debe estar en RECO) | conf | 0 |
| `fatca` | FATCA (reporte fiscal cuentas EE.UU. — SAT/IRS) | conf | 0 |
| `impuesto` | impuesto (SAT) | conf | 0 |
| `isr` | ISR — Impuesto Sobre la Renta (retención · SAT) | conf | 0 |
| `iva` | IVA (impuesto — SAT) | conf | 0 |
| `ivasart61` | IVA sobre operaciones del Art. 61 LIC (alcance fiscal por confirmar con el SME) | gap | 0 |

### Ambiguos — requieren validación SME/DBA

| Término | Significado | Estado | Frec |
|---|---|:--:|--:|
| `cjunk` | variable temporal (ruido de código, se ignora) | gap | 9 |
| `b3` | sufijo b3 — ¿bloque/build/versión? — por confirmar con el DBA | gap | 6 |
| `ref` | referencia | inf | 5 |
| `b4` | sufijo b4 — por confirmar con el DBA | gap | 3 |
| `sac` | sistema saldos/cuentas (bdisac) o sufijo | inf | 3 |
| `pba` | ¿prueba/PBA? — por confirmar con el SME | gap | 2 |
| `b5` | sufijo b5 — por confirmar con el DBA | gap | 1 |
| `ccl` | CCL — por confirmar con el SME | gap | 1 |
| `desc` | ¿descripción / descuento / descarga? — por confirmar con el SME | gap | 1 |
| `emp` | ¿empresa / empleado? — por confirmar con el SME | gap | 1 |
| `admin` | ¿administración / administrador? — por confirmar con el SME | gap | 0 |
| `adn` | ADN — por confirmar con el SME | gap | 0 |
| `cap` | ¿captura / captación / capacidad? — por confirmar con el SME | gap | 0 |
| `cnt` | ¿contador / cuenta contable? — por confirmar con el SME | gap | 0 |
| `dic` | ¿diciembre / dictamen? — por confirmar con el SME | gap | 0 |
| `fus2` | fusión v2 | inf | 0 |
| `imp` | ¿importe / impuesto / impresión? — por confirmar con el SME | gap | 0 |
| `mesa` | ¿mesa de control / mesa de dinero? — por confirmar con el SME | gap | 0 |
| `mesas` | ¿mesa de control / mesa de dinero? — por confirmar con el SME | gap | 0 |
| `oro` | ¿producto Oro / metal? — por confirmar con el SME | gap | 0 |
| `ris` | ¿riesgo? — por confirmar con el SME | gap | 0 |
| `seg` | ¿seguro / seguridad / segundo? — por confirmar con el SME | gap | 0 |
| `soe` | prefijo SOE (bdibei) — por confirmar con el SME | gap | 0 |
| `tco` | TCO — por confirmar con el SME | gap | 0 |
| `trans` | ¿transacción / transferencia? — por confirmar con el SME | gap | 0 |

---

## C · Regla de composición del objetivo

```
OBJETIVO = [ACCION principal] + [ENTIDAD(es)] + ([MODIFICADOR(es)]) + [· REGULATORIO]

Ejemplos:
  spei_aplicaordenpago         -> aplica + orden de pago                -> "aplica orden de pago"
  sp_fal_busca_pagares_cliente -> busca + pagarés + cliente             -> "busca pagarés + cliente"
  sp_consreportesctasinactivasart61 -> consulta reportes + cuentas inactivas · Art.61 LIC
  cargo_ref                    -> cargo/débito (ref)                    -> "cargo/débito"
```

**Cobertura:** 102 journeys orquestadores + 29 servicios expuestos = 131 flujos · 508 términos en catálogo.

## D · Pendientes de validación `[CONSULTAR→NEGOCIO / DBA]`

- Sufijos `b3`/`b4`/`b5` (contabilidad y BYM): ¿versión de release, número de bloque, o fase contable?
- Familia `bym`/`bym2`/`bym3` (sucursales): ¿qué significa el acrónimo BYM?
- `soc` → **Sistema Operativo Central** (confirmado SME 2026-07-03) — ya no ambiguo.
- `pba`, `tco`, `bpi`, `mc`, `ccl`: acrónimos sin expansión confirmada.
- `ivasart61`: confirmar si es IVA fiscal o Art. 61 LIC (cuentas inactivas cuyos saldos prescriben a favor de la beneficencia pública).
- **D01** presenta journeys con `fan_out=124` idéntico (patrón de reporteo repetido) — revisar si son genuinos o artefacto del análisis.

*Generado por Specialist — Informix SPL Analysis · Etapa 3 · fuente: journeys-data.json + sp_vocab.py + build-catalog.py*
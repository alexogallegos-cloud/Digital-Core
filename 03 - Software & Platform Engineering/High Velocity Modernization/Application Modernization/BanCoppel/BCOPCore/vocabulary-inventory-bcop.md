# BCOPCore · Inventario de Términos del Vocabulario

> **Componente:** BCOPCore · SPE-AM-001 · Etapa 3 — Business Logic Extraction  
> **Corpus:** 3,761 SPs conectados (nombres + parámetros del código fuente) · **Vocabulario:** `sp_vocab.py`  
> **Generado:** 2026-07-03 por `build-vocab-inventory.py`  

**Confiabilidad:** 🟢 Alta (confirmada por código/param o significado inequívoco) · 🟡 Media (inferida por convención) · 🔴 Ambigua (requiere SME/DBA) · ⚪ Candidato (sin clasificar).  
**Columnas:** `frec-nom` = veces que aparece en nombres de SP · `frec-par` = veces como parámetro (evidencia de código).

Totales: **586 términos atómicos** · **61 términos compuestos** · **60 candidatos sin clasificar**.

---

## A · Términos atómicos (individuales)

Morfemas irreducibles — los building blocks del vocabulario.

| Término | Categoría | Significado | Confiab. | frec-nom | frec-par |
|---|---|---|---|--:|--:|
| `sp` | prefijo | stored procedure | 🟢 Alta | 3599 | 0 |
| `usuario` | entidad | usuario | 🟢 Alta | 34 | 2221 |
| `idfuncion` | entidad | id de funcionalidad | 🟢 Alta | 0 | 2103 |
| `consulta` | acción | consulta / lee | 🟢 Alta | 650 | 12 |
| `registros` | entidad | registros | 🟢 Alta | 9 | 526 |
| `recuperacion` | acción | recuperación (cobranza) | 🟢 Alta | 6 | 519 |
| `empresa` | entidad | empresa (entidad bancaria) | 🟢 Alta | 1 | 426 |
| `cons` | acción | consulta | 🟢 Alta | 384 | 0 |
| `sucursal` | entidad | sucursal | 🟢 Alta | 53 | 286 |
| `fechafin` | entidad | fecha fin | 🟢 Alta | 0 | 273 |
| `status` | entidad | estatus | 🟢 Alta | 176 | 96 |
| `totales` | modificador | totales | 🟢 Alta | 244 | 0 |
| `tipo` | modificador | tipo de | 🟢 Alta | 79 | 115 |
| `ope` | acción | operación | 🟡 Media | 189 | 0 |
| `fecha` | entidad | fecha | 🟢 Alta | 29 | 152 |
| `cuenta` | entidad | cuenta | 🟢 Alta | 51 | 125 |
| `detalle` | entidad | detalle | 🟢 Alta | 155 | 0 |
| `reporte` | entidad | reporte | 🟢 Alta | 149 | 4 |
| `valida` | acción | valida | 🟢 Alta | 149 | 1 |
| `cte` | entidad | cliente | 🟢 Alta | 145 | 3 |
| `rep` | acción | reporte | 🟢 Alta | 126 | 0 |
| `actualiza` | acción | actualiza | 🟢 Alta | 124 | 0 |
| `producto` | entidad | producto | 🟢 Alta | 24 | 100 |
| `sac` | entidad | Servicios de Atención al Cliente — subsistema de atención en sucursal (ventanilla, domiciliación, abonos ATM, remesas WU); base de datos propia bdisac: con tabla sac_movimientoshistorial | 🟡 Media | 120 | 0 |
| `archivo` | entidad | archivo | 🟢 Alta | 106 | 13 |
| `cat` | entidad | catálogo | 🟢 Alta | 114 | 0 |
| `genera` | acción | genera / produce | 🟢 Alta | 111 | 0 |
| `consultar` | acción | consultar | 🟢 Alta | 109 | 0 |
| `verifica` | acción | verifica | 🟢 Alta | 104 | 0 |
| `cap` | entidad | Captación — cuentas de ahorro/depósito; evidencia: sp_cap_genrepcancelacioncuentascaptacion, nCtaCap, recalculagat1200 (GAT = Ganancia Anual Total regulado por Banxico) | 🟢 Alta | 102 | 0 |
| `bandera` | modificador | bandera / flag (técnico) | 🟢 Alta | 1 | 100 |
| `cre` | entidad | crédito | 🟡 Media | 99 | 0 |
| `catalogo` | entidad | catálogo | 🟢 Alta | 97 | 0 |
| `monto` | entidad | monto | 🟢 Alta | 20 | 77 |
| `cred` | entidad | crédito | 🟢 Alta | 95 | 0 |
| `id` | entidad | identificador (de) | 🟢 Alta | 95 | 0 |
| `fechafinal` | entidad | fecha final | 🟢 Alta | 0 | 94 |
| `ejecutivo` | entidad | ejecutivo | 🟢 Alta | 4 | 88 |
| `ctas` | entidad | cuentas | 🟢 Alta | 91 | 0 |
| `numcredito` | entidad | número de crédito | 🟢 Alta | 0 | 89 |
| `web` | modificador | canal web | 🟢 Alta | 87 | 0 |
| `caja` | entidad | caja / ventanilla | 🟢 Alta | 81 | 3 |
| `con` | acción | consulta | 🟡 Media | 84 | 0 |
| `obtiene` | acción | obtiene / recupera | 🟢 Alta | 82 | 0 |
| `tef` | entidad | TEF — transferencia electrónica de fondos | 🟢 Alta | 78 | 0 |
| `guarda` | acción | guarda / almacena | 🟢 Alta | 77 | 0 |
| `info` | entidad | información | 🟢 Alta | 77 | 0 |
| `lote` | entidad | lote (proceso batch) | 🟢 Alta | 11 | 66 |
| `ofi` | entidad | oficio | 🟡 Media | 76 | 0 |
| `cliente` | entidad | cliente | 🟢 Alta | 33 | 42 |
| `ant` | modificador | anterior | 🟢 Alta | 70 | 0 |
| `ccl` | entidad | módulo de Cédulas de Captación e inversión — pagaré, ISR, saldos diarios, inversión auto-creciente (bdicnweb:sp_ccl_*) | 🟡 Media | 67 | 0 |
| `comp` | modificador | complemento | 🟢 Alta | 67 | 0 |
| `cp` | entidad | código postal | 🟡 Media | 67 | 0 |
| `fal` | prefijo | faltantes / documentación de expediente | 🟡 Media | 67 | 0 |
| `pago` | entidad | pago | 🟢 Alta | 67 | 0 |
| `cta` | entidad | cuenta | 🟢 Alta | 66 | 0 |
| `sol` | entidad | solicitud | 🟡 Media | 66 | 0 |
| `estatus` | entidad | estatus | 🟢 Alta | 28 | 37 |
| `rem` | entidad | remesa (forma corta) | 🟡 Media | 65 | 0 |
| `pba` | modificador | PBA — sufijo de SPs para Pruebas; confirmado por SME (Guerra, Alejandro, 2026-07-09) | 🟢 Alta | 64 | 0 |
| `tdc` | entidad | tarjeta de crédito (TDC) | 🟢 Alta | 64 | 0 |
| `carga` | acción | carga / ingresa | 🟢 Alta | 63 | 0 |
| `cuentas` | entidad | cuentas (plural) | 🟢 Alta | 62 | 1 |
| `credito` | entidad | crédito | 🟢 Alta | 49 | 13 |
| `act` | acción | actualiza | 🟢 Alta | 60 | 0 |
| `solicitud` | entidad | solicitud | 🟢 Alta | 50 | 8 |
| `tarjeta` | entidad | tarjeta | 🟢 Alta | 24 | 34 |
| `transaccion` | entidad | transacción | 🟢 Alta | 30 | 28 |
| `codigo` | entidad | código | 🟢 Alta | 8 | 49 |
| `esp` | modificador | especial | 🟢 Alta | 57 | 0 |
| `folio` | entidad | folio | 🟢 Alta | 14 | 43 |
| `nombre` | entidad | nombre | 🟢 Alta | 25 | 31 |
| `datos` | entidad | datos | 🟢 Alta | 54 | 0 |
| `masivo` | modificador | masivo | 🟢 Alta | 54 | 0 |
| `cheques` | entidad | cheques | 🟢 Alta | 50 | 3 |
| `arch` | entidad | archivo | 🟡 Media | 50 | 0 |
| `bitacora` | entidad | bitácora | 🟢 Alta | 50 | 0 |
| `por` | modificador | por (criterio) | 🟢 Alta | 50 | 0 |
| `rev` | acción | reversión (abreviación de reversa/reverso) | 🟡 Media | 49 | 0 |
| `cargo` | entidad | cargo / débito | 🟢 Alta | 48 | 0 |
| `graba` | acción | graba / almacena | 🟢 Alta | 48 | 0 |
| `numsolicitud` | entidad | número de solicitud | 🟢 Alta | 1 | 46 |
| `alta` | acción | da de alta / registra | 🟢 Alta | 40 | 6 |
| `ctes` | entidad | clientes | 🟢 Alta | 46 | 0 |
| `inserta` | acción | inserta / registra | 🟢 Alta | 46 | 0 |
| `operacion` | acción | operación | 🟢 Alta | 16 | 30 |
| `productos` | entidad | productos | 🟢 Alta | 46 | 0 |
| `suc` | modificador | sucursal | 🟡 Media | 42 | 4 |
| `gen` | acción | genera / general | 🟡 Media | 45 | 0 |
| `registra` | acción | registra | 🟢 Alta | 45 | 0 |
| `secuencia` | entidad | secuencia | 🟢 Alta | 1 | 44 |
| `cac` | prefijo | familia crédito (CAC) | 🟡 Media | 44 | 0 |
| `obtener` | acción | obtiene / recupera | 🟢 Alta | 44 | 0 |
| `param` | entidad | parámetro | 🟢 Alta | 42 | 2 |
| `origen` | entidad | origen | 🟢 Alta | 6 | 37 |
| `total` | modificador | total | 🟢 Alta | 43 | 0 |
| `atms` | entidad | cajeros automáticos (ATM) | 🟢 Alta | 42 | 0 |
| `canal` | entidad | canal (de distribución) | 🟢 Alta | 10 | 32 |
| `cnsif` | prefijo | consulta SIF (bus de integración) | 🟡 Media | 42 | 0 |
| `tar` | entidad | Tarjeta (abreviación — bdicheq/bdicred: cons_cta_o_tar, mover_his_tar, obtener_cta_con_num_tar) | 🟡 Media | 42 | 0 |
| `referencia` | entidad | referencia | 🟢 Alta | 5 | 35 |
| `dic` | entidad | [polisemia] Dictamen (bdicnweb:sp_dic_* — decisión crediticia, analista de dictamen, hawk) | Diciembre (columna dic en tablas de series mensuales ene…dic) | 🟢 Alta | 39 | 0 |
| `importe` | entidad | importe | 🟢 Alta | 1 | 38 |
| `sms` | entidad | SMS | 🟢 Alta | 39 | 0 |
| `spei` | prefijo | familia SPEI (pagos interbancarios) | 🟢 Alta | 38 | 1 |
| `bts` | entidad | beneficiarios (BTS) | 🟡 Media | 38 | 0 |
| `cont` | prefijo | familia contabilidad | 🟢 Alta | 38 | 0 |
| `procesa` | acción | procesa | 🟢 Alta | 38 | 0 |
| `rec` | acción | recepción / recibe | 🟢 Alta | 38 | 0 |
| `coppel` | entidad | Coppel (grupo) | 🟢 Alta | 31 | 6 |
| `soe` | entidad | SOE — Soporte Operativo EmpresaNet; confirmado por SME (Jorge Isaac Díaz, 2026-07-09) | 🟢 Alta | 37 | 0 |
| `aud` | entidad | auditoría | 🟡 Media | 36 | 0 |
| `cambio` | entidad | cambio (de estatus, domicilio, etc.) | 🟢 Alta | 36 | 0 |
| `causa` | entidad | causa / motivo | 🟢 Alta | 13 | 23 |
| `opcion` | entidad | opción | 🟢 Alta | 0 | 36 |
| `det` | entidad | detalle | 🟡 Media | 35 | 0 |
| `envio` | acción | envía | 🟢 Alta | 32 | 3 |
| `ins` | acción | insertar | 🟡 Media | 35 | 0 |
| `cancela` | acción | cancela | 🟢 Alta | 34 | 0 |
| `descripcion` | entidad | descripción | 🟢 Alta | 3 | 31 |
| `error` | entidad | error | 🟢 Alta | 28 | 6 |
| `linea` | entidad | línea (de crédito) | 🟢 Alta | 31 | 3 |
| `mov` | entidad | movimiento | 🟢 Alta | 34 | 0 |
| `cheque` | entidad | cheque | 🟢 Alta | 16 | 17 |
| `prod` | entidad | producto | 🟡 Media | 33 | 0 |
| `solicitudes` | entidad | solicitudes (plural) | 🟢 Alta | 28 | 5 |
| `admin` | entidad | Administrador — rol de usuario con privilegios administrativos (pIdAdmin INTEGER en bdibei/bdibpi); también administración de tasas y procesos | 🟢 Alta | 32 | 0 |
| `elimina` | acción | elimina | 🟢 Alta | 32 | 0 |
| `int` | entidad | interés | 🟡 Media | 32 | 0 |
| `mac` | entidad | dirección MAC | 🟢 Alta | 13 | 19 |
| `moral` | modificador | persona moral | 🟢 Alta | 32 | 0 |
| `movimientos` | entidad | movimientos | 🟢 Alta | 32 | 0 |
| `reportes` | entidad | reportes | 🟢 Alta | 32 | 0 |
| `xml` | entidad | XML | 🟢 Alta | 32 | 0 |
| `archivos` | entidad | archivos | 🟢 Alta | 31 | 0 |
| `obten` | acción | obtiene / recupera | 🟢 Alta | 31 | 0 |
| `sistema` | entidad | sistema | 🟢 Alta | 6 | 25 |
| `banco` | entidad | banco | 🟢 Alta | 26 | 4 |
| `clave` | entidad | clave | 🟢 Alta | 10 | 20 |
| `general` | modificador | general | 🟢 Alta | 30 | 0 |
| `saldos` | entidad | saldos | 🟢 Alta | 29 | 1 |
| `servicio` | entidad | servicio | 🟢 Alta | 22 | 8 |
| `aplica` | acción | aplica / ejecuta | 🟢 Alta | 28 | 1 |
| `app` | modificador | canal app | 🟢 Alta | 29 | 0 |
| `cartera` | entidad | cartera de crédito | 🟢 Alta | 29 | 0 |
| `dev` | acción | devolución | 🟢 Alta | 29 | 0 |
| `estado` | entidad | estado (entidad federativa / estatus) | 🟢 Alta | 12 | 17 |
| `monitor` | entidad | monitor | 🟢 Alta | 28 | 1 |
| `rfc` | entidad | RFC (registro fiscal) | 🟢 Alta | 5 | 24 |
| `abono` | entidad | abono / crédito | 🟢 Alta | 28 | 0 |
| `cancelacion` | acción | cancela | 🟢 Alta | 28 | 0 |
| `cjunk` | ambiguo | variable temporal (ruido de código, se ignora) | 🔴 Ambigua | 28 | 0 |
| `conciliacion` | acción | conciliación | 🟢 Alta | 27 | 1 |
| `dep` | entidad | depósito | 🟡 Media | 28 | 0 |
| `domi` | entidad | domiciliación | 🟡 Media | 28 | 0 |
| `msi` | entidad | meses sin intereses (MSI) | 🟢 Alta | 28 | 0 |
| `notifica` | acción | notifica | 🟢 Alta | 28 | 0 |
| `periodo` | entidad | periodo | 🟢 Alta | 5 | 23 |
| `iva` | regulatorio | IVA (impuesto — SAT) | 🟢 Alta | 26 | 1 |
| `mail` | entidad | correo electrónico | 🟢 Alta | 27 | 0 |
| `remesas` | entidad | remesas internacionales | 🟢 Alta | 27 | 0 |
| `respuesta` | entidad | respuesta | 🟢 Alta | 26 | 1 |
| `comision` | regulatorio | comisión (CONDUSEF — debe estar en RECO) | 🟢 Alta | 22 | 4 |
| `desc` | entidad | [polisemia] Descripción (sp_desc_ret: devuelve descripción del código de retorno) | Descarga (sp_desc_archivos_cfdi/conc: descarga archivos CFDI y conciliación) | 🟢 Alta | 25 | 1 |
| `ejecucion` | entidad | ejecución (de proceso) | 🟢 Alta | 4 | 22 |
| `mes` | entidad | mes | 🟢 Alta | 13 | 13 |
| `proceso` | entidad | proceso | 🟢 Alta | 22 | 4 |
| `reverso` | acción | reverso | 🟢 Alta | 26 | 0 |
| `dinya` | entidad | DINYA — sistema/plataforma de remesas domésticas en sucursal; retorna nombre_remitente, sucursal_origen, importe_eviado (bdicnweb:sp_*dinya*) | 🟡 Media | 25 | 0 |
| `historico` | modificador | histórico | 🟢 Alta | 24 | 1 |
| `busca` | acción | busca / localiza | 🟢 Alta | 24 | 0 |
| `marca` | entidad | marca | 🟢 Alta | 10 | 14 |
| `oficio` | entidad | oficio (requerimiento judicial/autoridad) | 🟢 Alta | 22 | 2 |
| `operaciones` | entidad | operaciones (plural) | 🟢 Alta | 24 | 0 |
| `tasa` | entidad | tasa (de interés) | 🟢 Alta | 18 | 6 |
| `telefono` | entidad | teléfono | 🟢 Alta | 8 | 16 |
| `gral` | modificador | general | 🟢 Alta | 23 | 0 |
| `pos` | entidad | punto de venta (POS) | 🟢 Alta | 23 | 0 |
| `usuarios` | entidad | usuarios | 🟢 Alta | 22 | 1 |
| `analista` | entidad | analista | 🟢 Alta | 13 | 9 |
| `asigna` | acción | asigna | 🟢 Alta | 22 | 0 |
| `auto` | modificador | automático (proceso automático / batch — sp_*_auto) | 🟡 Media | 22 | 0 |
| `dia` | modificador | del día | 🟢 Alta | 22 | 0 |
| `empleado` | entidad | empleado | 🟢 Alta | 13 | 9 |
| `imp` | entidad | Impago — pago vencido o fallido; confirmado: n_impagos_consec (impagos consecutivos), n_imp_hist_6m (historial 6 meses) en motor de scoring crediticio (bdicred) | 🟢 Alta | 22 | 0 |
| `trans` | entidad | [polisemia] Transferencia (bditransfer, bditrans: transferencias y remesas con campos pbco_dest/ppais_dest) | Transacción (sufijo genérico en SPs de reversión y procesamiento) | 🟢 Alta | 22 | 0 |
| `transfer` | entidad | transferencia (forma larga de 'trans') | 🟢 Alta | 22 | 0 |
| `upgrade` | acción | actualiza producto (upgrade) | 🟡 Media | 22 | 0 |
| `cel` | entidad | celular | 🟢 Alta | 20 | 1 |
| `chi` | entidad | CHI — formato/protocolo de consulta al Buró de Crédito (bdiburo/bdicred:sp_chi_cre_consulta_sic, sp_chi_cre_layout_sics, sp_chi_cre_result_consulta_sic; SICS = Sociedad de Información Crediticia) | 🟡 Media | 21 | 0 |
| `cod` | entidad | código | 🟢 Alta | 21 | 0 |
| `emp` | entidad | Empresa — empleadora del cliente; vinculada a crédito de nómina (ADN); SPs: sp_consulta_datos_emp_bei (phone+address), sp_genera_emp_gc (Grupo Coppel), inserta_rel_cte_emp | 🟢 Alta | 21 | 0 |
| `fatca` | regulatorio | FATCA (reporte fiscal cuentas EE.UU. — SAT/IRS) | 🟢 Alta | 21 | 0 |
| `huella` | entidad | huella biométrica | 🟢 Alta | 13 | 8 |
| `inf` | entidad | información | 🟡 Media | 21 | 0 |
| `pagos` | entidad | pagos (plural) | 🟢 Alta | 21 | 0 |
| `parametros` | entidad | parámetros | 🟢 Alta | 21 | 0 |
| `reg` | acción | registro | 🟡 Media | 21 | 0 |
| `saldo` | entidad | saldo | 🟢 Alta | 15 | 6 |
| `afore` | entidad | AFORE (Afore Coppel — 2ª mayor de México, ~14.5M cuentas) | 🟢 Alta | 20 | 0 |
| `bloqueo` | acción | bloquea cuenta | 🟢 Alta | 19 | 1 |
| `calle` | entidad | calle (domicilio) | 🟢 Alta | 7 | 13 |
| `concilia` | acción | conciliación | 🟢 Alta | 20 | 0 |
| `consecutivo` | entidad | consecutivo | 🟢 Alta | 6 | 14 |
| `soc` | entidad | Sistema Operativo Central (SOC) — confirmado SME | 🟢 Alta | 20 | 0 |
| `tarjetas` | entidad | tarjetas (plural) | 🟢 Alta | 20 | 0 |
| `token` | entidad | token (autenticación) | 🟢 Alta | 20 | 0 |
| `transacc` | entidad | código de transacción | 🟢 Alta | 2 | 18 |
| `adn` | acción | Adelanto de Nómina — producto de crédito al consumo liquidable vía descuento automático de nómina (cierre diario + cobro automático sobre bdicred) | 🟢 Alta | 19 | 0 |
| `anio` | entidad | año | 🟢 Alta | 4 | 15 |
| `categoria` | entidad | categoría | 🟢 Alta | 5 | 14 |
| `concentracion` | acción | concentración de fondos | 🟢 Alta | 18 | 1 |
| `crd` | entidad | crédito (abreviación) | 🟡 Media | 19 | 0 |
| `deb` | modificador | débito | 🟢 Alta | 19 | 0 |
| `fusion` | acción | fusiona cuentas | 🟢 Alta | 17 | 2 |
| `oro` | entidad | Tier medio de la Tarjeta de Crédito BanCoppel — jerarquía Clásica < Oro < Platino; path de upgrade desde crédito Grupo Coppel | 🟢 Alta | 19 | 0 |
| `ris` | entidad | Riesgo — módulo de gestión de riesgo crediticio (bdicnweb:sp_ris_*); confirmado en código: nivel_riesgo, grado_riesgo, califica_riesgo | 🟢 Alta | 19 | 0 |
| `situacion` | entidad | situación | 🟢 Alta | 9 | 10 |
| `tel` | entidad | teléfono | 🟢 Alta | 18 | 1 |
| `atm` | entidad | cajero automático (ATM) | 🟢 Alta | 18 | 0 |
| `bpi` | modificador | Banca Por Internet (canal web BPI) | 🟢 Alta | 18 | 0 |
| `cal` | entidad | [polisemia] Cálculo (cal_fecha, cal_riesgo_cliente, cal_tradicion — operaciones matemáticas financieras) | Calendario (cal_habil_ant — días hábiles bancarios; bdicheq) | 🟡 Media | 18 | 0 |
| `cnt` | entidad | CNT — módulo de convenios y control de descuentos de nómina de empleados (sp_cnt_catconvenio, detallefaltdescemp, genreportesolcred — bdicnweb) | 🟡 Media | 18 | 0 |
| `digitalizacion` | entidad | digitalización de documentos | 🟢 Alta | 18 | 0 |
| `divisa` | entidad | divisa | 🟢 Alta | 2 | 16 |
| `ingreso` | entidad | ingreso (del solicitante) | 🟢 Alta | 8 | 10 |
| `movto` | entidad | movimiento | 🟢 Alta | 18 | 0 |
| `plaza` | entidad | plaza (regional) | 🟢 Alta | 8 | 10 |
| `ref` | ambiguo | referencia | 🔴 Ambigua | 18 | 0 |
| `ruta` | entidad | ruta (de archivo) | 🟢 Alta | 2 | 16 |
| `seg` | entidad | [polisemia] Seguridad (bdicnweb: usuarios, perfiles, app móvil) | Seguro (bdisac: pólizas — sac_abono_seg, sac_cons_seg; poliza + cantidadseguros + claveseguro) | 🟢 Alta | 18 | 0 |
| `baja` | modificador | de baja | 🟢 Alta | 17 | 0 |
| `busqueda` | acción | búsqueda | 🟢 Alta | 17 | 0 |
| `cce` | entidad | CCE — Cámara de Compensación Electrónica (CECOBAN/Banxico) — sistema de compensación interbancaria de cheques; SPs: sp_cce_consultar_cheques40/46, chequespresentados (bdicheq) | 🟢 Alta | 17 | 0 |
| `cedula` | entidad | cédula de identificación | 🟢 Alta | 11 | 6 |
| `consreportes` | acción | consulta reportes | 🟢 Alta | 17 | 0 |
| `doctos` | entidad | documentos | 🟢 Alta | 17 | 0 |
| `dotacion` | entidad | dotación de efectivo (a cajero/sucursal) | 🟢 Alta | 17 | 0 |
| `dotaciones` | entidad | dotaciones de efectivo | 🟢 Alta | 17 | 0 |
| `encabezado` | entidad | encabezado | 🟢 Alta | 17 | 0 |
| `exp` | modificador | sufijo Exportar — SP genera/exporta archivo de salida (sp_*_exp: generaarchivocuentasnomina_exp, perfisica_listanegra_exp, reversion_exp) | 🟡 Media | 17 | 0 |
| `isr` | regulatorio | ISR — Impuesto Sobre la Renta (retención · SAT) | 🟢 Alta | 17 | 0 |
| `motivo` | entidad | motivo / causa | 🟢 Alta | 10 | 7 |
| `obt` | acción | obtiene | 🟡 Media | 17 | 0 |
| `parametro` | entidad | parámetro | 🟢 Alta | 10 | 7 |
| `reversa` | acción | Reversión — anula/revierte una operación (bdibei:sp_reversa_solicitudes_bei, sp_reversa_tokenasociados_bei) | 🟢 Alta | 17 | 0 |
| `sat` | regulatorio | SAT — Servicio de Administración Tributaria (CFDI, ISR, IVA) | 🟢 Alta | 17 | 0 |
| `sdo` | entidad | saldo | 🟢 Alta | 17 | 0 |
| `solic` | entidad | solicitud | 🟢 Alta | 17 | 0 |
| `valor` | entidad | valor | 🟢 Alta | 4 | 13 |
| `autoriza` | acción | autoriza | 🟢 Alta | 16 | 0 |
| `buscar` | acción | búsqueda/buscar | 🟢 Alta | 16 | 0 |
| `chq` | entidad | cheque (abreviación — bdicheq) | 🟡 Media | 16 | 0 |
| `com` | entidad | Comisión bancaria — cobro de comisión sobre cuenta (bdicheq:sp_cobra_com, sp_com_manejo_cta_cobro_*; también en OXXO) | 🟢 Alta | 16 | 0 |
| `dictamen` | entidad | dictamen | 🟢 Alta | 9 | 7 |
| `envios` | entidad | envíos | 🟢 Alta | 16 | 0 |
| `masiva` | modificador | masiva | 🟢 Alta | 16 | 0 |
| `mensual` | modificador | mensual | 🟢 Alta | 16 | 0 |
| `movil` | modificador | canal móvil | 🟢 Alta | 16 | 0 |
| `sif` | entidad | SIF — canal de estado de cuenta (aclaraciones_edocta_sif, detalle_edocta_sif); procesa aclaraciones de TDC por tarjeta+fecha de emisión | 🟡 Media | 16 | 0 |
| `tp` | modificador | tipo | 🟢 Alta | 16 | 0 |
| `buro` | entidad | Buró de Crédito | 🟢 Alta | 15 | 0 |
| `cam` | prefijo | cámara / captura contable | 🟡 Media | 15 | 0 |
| `camp` | entidad | Campaña — campaña de cobranza o crédito (sp_envio_camp_ctes, sp_actvig_camp — bdicobranza + bdicred) | 🟢 Alta | 15 | 0 |
| `clientes` | entidad | clientes (plural) | 🟢 Alta | 15 | 0 |
| `corresp` | entidad | Corresponsal — corresponsal bancario; red de puntos de servicio no-sucursal regulada por CNBV (bdicheq:sp_corresp_*, sp_generar_acum_corresponsal_mc) | 🟢 Alta | 15 | 0 |
| `diario` | modificador | diario | 🟢 Alta | 15 | 0 |
| `hist` | modificador | histórico/historial | 🟢 Alta | 15 | 0 |
| `ivr` | modificador | canal IVR (telefónico) | 🟢 Alta | 15 | 0 |
| `mensaje` | entidad | mensaje | 🟢 Alta | 6 | 9 |
| `prestamo` | entidad | préstamo (Personal / Nómina / Digital BanCoppel) | 🟢 Alta | 15 | 0 |
| `reversion` | acción | reversa / rollback | 🟢 Alta | 15 | 0 |
| `rol` | entidad | rol / perfil | 🟢 Alta | 13 | 2 |
| `apertura` | entidad | apertura (de cuenta/crédito) | 🟢 Alta | 14 | 0 |
| `bloquea` | acción | bloquea cuenta | 🟢 Alta | 14 | 0 |
| `califica` | acción | califica / evalúa (scoring) | 🟢 Alta | 14 | 0 |
| `captura` | acción | captura | 🟢 Alta | 6 | 8 |
| `central` | modificador | central | 🟢 Alta | 14 | 0 |
| `desbloqueo` | acción | desbloquea cuenta | 🟢 Alta | 14 | 0 |
| `devolucion` | acción | devuelve | 🟢 Alta | 14 | 0 |
| `hora` | entidad | hora | 🟢 Alta | 8 | 6 |
| `motor` | entidad | motor de decisión | 🟢 Alta | 14 | 0 |
| `nom` | entidad | nómina | 🟡 Media | 14 | 0 |
| `numerocliente` | entidad | número de cliente | 🟢 Alta | 0 | 14 |
| `pais` | entidad | país | 🟢 Alta | 5 | 9 |
| `perfil` | entidad | perfil de usuario | 🟢 Alta | 13 | 1 |
| `zona` | entidad | zona | 🟢 Alta | 9 | 5 |
| `combo` | entidad | combo / lista desplegable (control de UI en app) | 🟢 Alta | 13 | 0 |
| `desb` | acción | desbloqueo | 🟡 Media | 13 | 0 |
| `direcciones` | entidad | direcciones | 🟢 Alta | 13 | 0 |
| `edo` | entidad | estado | 🟡 Media | 13 | 0 |
| `faltantes` | modificador | faltantes | 🟢 Alta | 13 | 0 |
| `pagares` | entidad | pagarés | 🟢 Alta | 13 | 0 |
| `puntos` | entidad | puntos (recompensas) | 🟢 Alta | 11 | 2 |
| `remesa` | entidad | remesa (Western Union / MoneyGram) | 🟢 Alta | 11 | 2 |
| `venc` | entidad | vencimiento | 🟡 Media | 13 | 0 |
| `cierre` | acción | cierre | 🟢 Alta | 12 | 0 |
| `clon` | entidad | [polisemia] Clon de SP (réplica funcional para variante de entorno o canal — similar a _pba; bdiburo:burofisicas_clon, bdibpi:sp_consultarctepmempresanet_clon) | Clonación fraudulenta (bdiauditor:sp_pld_chq_addfolio_clon — fraude de clonación de cheques/documentos en PLD) | 🟡 Media | 12 | 0 |
| `cobro` | acción | cobro | 🟢 Alta | 12 | 0 |
| `evento` | entidad | evento/notificación | 🟢 Alta | 12 | 0 |
| `grupo` | entidad | grupo | 🟢 Alta | 4 | 8 |
| `his` | modificador | histórico | 🟡 Media | 12 | 0 |
| `identificacion` | entidad | identificación | 🟢 Alta | 5 | 7 |
| `ipab` | regulatorio | IPAB — Instituto para la Protección al Ahorro Bancario (seguro de depósitos hasta 400,000 UDIs por depositante; Banxico/CNBV) | 🟢 Alta | 12 | 0 |
| `mon` | prefijo | monitor / módulo | 🟡 Media | 12 | 0 |
| `ord` | entidad | ordenante / orden (SPEI) | 🟢 Alta | 12 | 0 |
| `pagare` | entidad | pagaré | 🟢 Alta | 12 | 0 |
| `poliza` | entidad | póliza contable | 🟢 Alta | 12 | 0 |
| `proc` | entidad | proceso | 🟡 Media | 12 | 0 |
| `retiro` | entidad | retiro | 🟢 Alta | 12 | 0 |
| `rpt` | entidad | reporte | 🟢 Alta | 12 | 0 |
| `traspaso` | acción | traspaso entre cuentas | 🟢 Alta | 12 | 0 |
| `aut` | acción | autorización | 🟡 Media | 11 | 0 |
| `b3` | modificador | sufijo de versión de SP (Bloque/Build 3) — patrón Informix: no existe ALTER PROCEDURE, se crea nueva versión con sufijo _b3/_b4/_b5 | 🟡 Media | 11 | 0 |
| `bloq` | acción | bloqueo | 🟡 Media | 11 | 0 |
| `bym` | entidad | Billetes y Monedas (efectivo en sucursal — evidencia: 'piezas' + 'denominación') | 🟡 Media | 11 | 0 |
| `club` | entidad | Club de Protección — producto de seguro grupal BanCoppel; movimientos históricos en bdisac:sac_movimientoshistorial; ventas en sp_rep_vtas_club_proteccion | 🟢 Alta | 11 | 0 |
| `ctepr` | entidad | Cliente Prospecto — cliente potencial aún sin cuenta abierta (sp_catalogoscteprospecto, sp_consdireccionescteprospecto, sp_cancelaperturacteprospecto — bdicnweb) | 🟢 Alta | 11 | 0 |
| `depura` | acción | depura / limpia | 🟢 Alta | 11 | 0 |
| `diarios` | modificador | diarios | 🟢 Alta | 11 | 0 |
| `domicilio` | entidad | domicilio | 🟢 Alta | 8 | 3 |
| `expediente` | entidad | expediente | 🟢 Alta | 10 | 1 |
| `inversion` | entidad | inversión (pagaré / plazo) | 🟢 Alta | 11 | 0 |
| `manual` | modificador | manual | 🟢 Alta | 11 | 0 |
| `modificacion` | acción | modificación | 🟢 Alta | 10 | 1 |
| `num` | entidad | número (de) | 🟢 Alta | 10 | 1 |
| `portanom` | entidad | Portabilidad de Nómina — portabilidad de domiciliación de nómina entre bancos (CNBV); gestiona solicitudes y archivos (bdicheq:sp_portanom_*) | 🟢 Alta | 11 | 0 |
| `scoring` | entidad | scoring crediticio | 🟢 Alta | 11 | 0 |
| `sorteo` | entidad | sorteo | 🟢 Alta | 11 | 0 |
| `tco` | entidad | TCO — Tarjetas Coppel / TCoppel (producto de crédito Grupo Coppel); confirmado por SME (Jorge Isaac Díaz, 2026-07-09) | 🟢 Alta | 11 | 0 |
| `acl` | prefijo | familia aclaraciones | 🟢 Alta | 10 | 0 |
| `bccc` | entidad | BCCC — formato o protocolo de consulta al Buró de Crédito (bdiburo:sp_reenvio_sols_bccc9; catproducto, catcomentario) | 🟡 Media | 10 | 0 |
| `bex` | entidad | BEX — canal o plataforma de Banca Por Internet (bdibpi); gestiona sesiones, preguntas de seguridad, cuentas cap/cred (sp_*_bex, sp_ini_session_bex) | 🟡 Media | 10 | 0 |
| `ciloc` | prefijo | consulta local de cobranza | 🟡 Media | 10 | 0 |
| `ciudad` | entidad | ciudad | 🟢 Alta | 1 | 9 |
| `corte` | entidad | corte (fecha de corte / período) | 🟢 Alta | 10 | 0 |
| `creditos` | entidad | créditos (plural) | 🟢 Alta | 10 | 0 |
| `evc` | entidad | EVC — Evaluación/Cartera a Quebrantar (write-off de cartera vencida; sp_evc_cartera_quebrantar, sp_evc_consexclusionlote — bdicnweb) | 🟡 Media | 10 | 0 |
| `fusionados` | modificador | fusionados | 🟢 Alta | 10 | 0 |
| `imagen` | entidad | imagen digital | 🟢 Alta | 10 | 0 |
| `imagenes` | entidad | imágenes / documentos digitales | 🟢 Alta | 10 | 0 |
| `ine` | regulatorio | INE — Instituto Nacional Electoral (validación de identidad del cliente) | 🟢 Alta | 10 | 0 |
| `mensajes` | entidad | mensajes | 🟢 Alta | 10 | 0 |
| `plazo` | entidad | plazo (depósito / crédito a plazo) | 🟢 Alta | 3 | 7 |
| `registro` | entidad | registro | 🟢 Alta | 7 | 3 |
| `b5` | modificador | sufijo de versión de SP (Bloque/Build 5) | 🟡 Media | 9 | 0 |
| `canales` | entidad | canales (de distribución) | 🟢 Alta | 9 | 0 |
| `cedulas` | entidad | cédulas | 🟢 Alta | 9 | 0 |
| `correo` | entidad | correo electrónico | 🟢 Alta | 7 | 2 |
| `ctamec` | entidad | Cuenta Mecánica — tipo de cuenta de cheques empresarial para nómina y pagos automáticos (bdicheq:sp_ctamec_*) | 🟢 Alta | 9 | 0 |
| `debito` | entidad | débito | 🟢 Alta | 8 | 1 |
| `firmas` | entidad | firmas mancomunadas | 🟢 Alta | 9 | 0 |
| `iccat` | entidad | ICCAT — canal de atención al cliente en BPI; gestiona solicitudes de entrega y reposición de token, desbloqueo de acceso (bdibpi:sp_iccat_*, sp_*_iccat) | 🟡 Media | 9 | 0 |
| `liquidacion` | entidad | liquidación | 🟢 Alta | 9 | 0 |
| `periodicidad` | modificador | periodicidad | 🟢 Alta | 1 | 8 |
| `plantilla` | entidad | plantilla | 🟢 Alta | 1 | 8 |
| `presentado` | modificador | presentado (a cobro) | 🟢 Alta | 9 | 0 |
| `primer` | modificador | primer | 🟢 Alta | 9 | 0 |
| `region` | entidad | región | 🟢 Alta | 1 | 8 |
| `telefonos` | entidad | teléfonos | 🟢 Alta | 9 | 0 |
| `upd` | acción | actualiza (update) | 🟡 Media | 9 | 0 |
| `validacion` | acción | validación | 🟢 Alta | 8 | 1 |
| `calculo` | entidad | cálculo | 🟢 Alta | 8 | 0 |
| `ciudades` | entidad | ciudades (catálogo) | 🟢 Alta | 8 | 0 |
| `concepto` | entidad | concepto de pago | 🟢 Alta | 1 | 7 |
| `conyuge` | entidad | cónyuge (solicitud crédito) | 🟢 Alta | 0 | 8 |
| `decodifica` | acción | decodifica | 🟢 Alta | 8 | 0 |
| `digi` | acción | digitalización | 🟡 Media | 8 | 0 |
| `docto` | entidad | documento | 🟢 Alta | 1 | 7 |
| `fechas` | entidad | fechas | 🟢 Alta | 8 | 0 |
| `fus` | acción | fusión de cuentas | 🟡 Media | 8 | 0 |
| `indicadores` | entidad | indicadores | 🟢 Alta | 6 | 2 |
| `revision` | entidad | revisión | 🟢 Alta | 8 | 0 |
| `salida` | entidad | salida | 🟢 Alta | 8 | 0 |
| `sbc` | entidad | saldo básico de cuenta (SBC) | 🟡 Media | 8 | 0 |
| `sdos` | entidad | saldos (abreviación) | 🟡 Media | 8 | 0 |
| `art61` | regulatorio | Art. 61 LIC (cuentas inactivas cuyos saldos, tras años sin movimiento, prescriben a favor de la beneficencia pública) | 🟢 Alta | 7 | 0 |
| `cheq` | entidad | cheque | 🟢 Alta | 7 | 0 |
| `concreing` | entidad | Conciliación de Reingresos — proceso de conciliación de tarjetas reingresadas (bditarjeta:sp_concreing_*; gestiona archivos ATM, usuarios, horarios, parámetros) | 🟡 Media | 7 | 0 |
| `confirma` | acción | confirma | 🟢 Alta | 6 | 1 |
| `descarga` | entidad | descarga | 🟢 Alta | 7 | 0 |
| `efectivo` | entidad | efectivo | 🟢 Alta | 5 | 2 |
| `envia` | acción | envía | 🟢 Alta | 7 | 0 |
| `facturacion` | entidad | facturación | 🟢 Alta | 7 | 0 |
| `orden` | entidad | orden | 🟢 Alta | 5 | 2 |
| `piezas` | entidad | piezas de efectivo (billetes y monedas) | 🟢 Alta | 7 | 0 |
| `procede` | acción | procede | 🟢 Alta | 3 | 4 |
| `sps` | prefijo | sps — prefijo alternativo de SP en bdibei (posiblemente 'stored procedure set' o convención local del equipo; vs el 'sp' estándar) | 🟡 Media | 7 | 0 |
| `aclaraciones` | entidad | aclaraciones (proceso de disputas/reclamaciones de cliente) | 🟢 Alta | 6 | 0 |
| `aum` | modificador | aumento | 🟡 Media | 6 | 0 |
| `bei` | entidad | BEI — Banca En Internet; canal digital principal de BanCoppel; base de datos bdibei con 279+ SPs de operaciones, autenticación, transferencias y mancomunidad | 🟢 Alta | 6 | 0 |
| `cep` | entidad | Comprobante Electrónico de Pago (SPEI · Banxico) | 🟢 Alta | 6 | 0 |
| `cnr` | entidad | CNR — tipo o formato de consulta al Buró de Crédito para personas físicas (bdiburo:burofisicas_cnr; vcredito_maximo) | 🟡 Media | 6 | 0 |
| `cobranza` | entidad | cobranza | 🟢 Alta | 6 | 0 |
| `declaracion` | entidad | declaración | 🟢 Alta | 5 | 1 |
| `dicta` | prefijo | dictamen (aclaraciones/crédito) | 🟡 Media | 6 | 0 |
| `documentos` | entidad | documentos | 🟢 Alta | 6 | 0 |
| `etiqueta` | entidad | etiqueta | 🟢 Alta | 1 | 5 |
| `final` | modificador | final | 🟢 Alta | 6 | 0 |
| `forma` | acción | construye / arma | 🟡 Media | 6 | 0 |
| `huellas` | entidad | huellas biométricas | 🟢 Alta | 6 | 0 |
| `interes` | entidad | interés | 🟢 Alta | 6 | 0 |
| `max` | modificador | máximo | 🟢 Alta | 6 | 0 |
| `mayor` | entidad | mayor contable | 🟡 Media | 6 | 0 |
| `promocion` | entidad | promoción | 🟢 Alta | 0 | 6 |
| `prospectos` | entidad | prospectos (nuevos clientes potenciales) | 🟢 Alta | 6 | 0 |
| `quincena` | entidad | quincena (periodo de pago nómina/crédito Coppel) | 🟢 Alta | 6 | 0 |
| `reestructura` | acción | reestructura crédito | 🟢 Alta | 5 | 1 |
| `remesadora` | entidad | remesadora (envío de remesas) | 🟢 Alta | 2 | 4 |
| `traspas` | acción | traspaso | 🟡 Media | 6 | 0 |
| `vencimiento` | entidad | vencimiento | 🟢 Alta | 6 | 0 |
| `alertas` | entidad | alertas | 🟢 Alta | 5 | 0 |
| `benef` | entidad | beneficiario | 🟢 Alta | 5 | 0 |
| `campana` | entidad | campaña | 🟢 Alta | 5 | 0 |
| `clabe` | entidad | CLABE interbancaria | 🟢 Alta | 4 | 1 |
| `compac` | entidad | Compromisos de Pago en Cobranza — acuerdos/convenios de pago activos o cumplidos el mismo día; historial en cb_compac_his (bdicobranza:sp_archivo_compac, sp_compac_consultacompromisosvigente) | 🟢 Alta | 5 | 0 |
| `correos` | entidad | correos electrónicos (email) | 🟢 Alta | 5 | 0 |
| `digito` | entidad | dígito verificador | 🟢 Alta | 5 | 0 |
| `domiciliacion` | entidad | domiciliación | 🟢 Alta | 5 | 0 |
| `inicia` | acción | inicia | 🟢 Alta | 0 | 5 |
| `inicio` | modificador | inicio | 🟢 Alta | 1 | 4 |
| `marcas` | entidad | marcas de cuenta | 🟢 Alta | 5 | 0 |
| `movimiento` | entidad | movimiento | 🟢 Alta | 5 | 0 |
| `nacionalidad` | entidad | nacionalidad | 🟢 Alta | 1 | 4 |
| `recupera` | acción | recupera estado | 🟢 Alta | 5 | 0 |
| `reserva` | entidad | reserva | 🟢 Alta | 5 | 0 |
| `retenido` | modificador | retenido (fondos en retención) | 🟢 Alta | 5 | 0 |
| `sub` | modificador | sub- | 🟡 Media | 5 | 0 |
| `supervision` | entidad | supervisión | 🟢 Alta | 5 | 0 |
| `acceso` | entidad | acceso | 🟡 Media | 4 | 0 |
| `adm` | acción | administración/administrar (abreviación de admin) | 🟡 Media | 4 | 0 |
| `alerta` | entidad | alerta | 🟢 Alta | 4 | 0 |
| `apellido` | entidad | apellido | 🟢 Alta | 2 | 2 |
| `autenticacion` | entidad | autenticación | 🟢 Alta | 4 | 0 |
| `b4` | modificador | sufijo de versión de SP (Bloque/Build 4) | 🟡 Media | 4 | 0 |
| `cantidad` | entidad | cantidad | 🟢 Alta | 2 | 2 |
| `codi` | regulatorio | CoDi — Cobro Digital (Banxico) | 🟢 Alta | 4 | 0 |
| `colonias` | entidad | colonias (catálogo domicilio) | 🟢 Alta | 4 | 0 |
| `corresponsal` | entidad | corresponsal | 🟢 Alta | 4 | 0 |
| `factura` | entidad | factura | 🟢 Alta | 2 | 2 |
| `hoy` | modificador | de hoy / fecha actual | 🟢 Alta | 4 | 0 |
| `idfuncionc` | entidad | id de funcionalidad | 🟢 Alta | 0 | 4 |
| `mib` | entidad | MIB — módulo/canal de integración para cheques y tarjeta (cargo_ref_mib, cancelar_activar_cheque_mib — bdicheq + bdibpi) | 🟡 Media | 4 | 0 |
| `politica` | entidad | política de crédito | 🟡 Media | 4 | 0 |
| `prestamos` | entidad | préstamos | 🟢 Alta | 4 | 0 |
| `principal` | entidad | principal — capital principal de deuda / titular principal de cuenta | 🟢 Alta | 4 | 0 |
| `retiros` | entidad | retiros | 🟢 Alta | 4 | 0 |
| `tels` | entidad | teléfonos (plural) | 🟡 Media | 4 | 0 |
| `temp` | modificador | temporal | 🟢 Alta | 4 | 0 |
| `valid` | acción | valida | 🟡 Media | 4 | 0 |
| `activar` | acción | activar | 🟢 Alta | 3 | 0 |
| `aplicar` | acción | aplica / ejecuta | 🟢 Alta | 3 | 0 |
| `apoderado` | entidad | apoderado | 🟢 Alta | 3 | 0 |
| `arr` | entidad | ARR — producto de ahorro/inversión recurrente (CLABE, interés acumulado, inversión creciente, pago de interés — bdicheq:arr_*) | 🟡 Media | 3 | 0 |
| `batch` | modificador | proceso batch (por lotes) | 🟢 Alta | 3 | 0 |
| `beneficiario` | entidad | beneficiario (receptor del pago SPEI) | 🟢 Alta | 3 | 0 |
| `cedulacontable` | entidad | cédula contable | 🟡 Media | 3 | 0 |
| `cita` | entidad | cita | 🟢 Alta | 3 | 0 |
| `conciliadora` | entidad | conciliadora | 🟡 Media | 3 | 0 |
| `credisoluciones` | entidad | CrediSoluciones — producto/segmento de crédito BanCoppel (sp_carga_ctes_credisoluciones, sp_credisoluciones_crd — bdicred) | 🟡 Media | 3 | 0 |
| `cve` | entidad | clave (cve) | 🟢 Alta | 3 | 0 |
| `determina` | acción | determina | 🟢 Alta | 3 | 0 |
| `direccion` | entidad | dirección | 🟢 Alta | 3 | 0 |
| `dormidas` | modificador | cuentas dormidas (inactivas) | 🟢 Alta | 3 | 0 |
| `ics` | entidad | ICS — sistema de cuotas/mensualidades de crédito (sp_ics_cuotas, sp_ics_compara_secuencias, sp_ics_genera_control — bdicred) | 🟡 Media | 3 | 0 |
| `inactivas` | modificador | inactivas (art.61) | 🟢 Alta | 3 | 0 |
| `lin` | entidad | línea (de crédito) | 🟡 Media | 3 | 0 |
| `local` | modificador | local | 🟢 Alta | 3 | 0 |
| `mesa` | entidad | Mesa de Control — equipo de revisión y autorización de solicitudes de crédito; status codes MC/CM; valida comprobantes de ingreso; comentario explícito en código | 🟢 Alta | 3 | 0 |
| `modifica` | acción | modifica | 🟢 Alta | 3 | 0 |
| `movs` | entidad | movimientos (abreviación) | 🟡 Media | 3 | 0 |
| `nomina` | entidad | nómina | 🟢 Alta | 2 | 1 |
| `parentesco` | entidad | parentesco (referencia) | 🟢 Alta | 0 | 3 |
| `receptor` | entidad | receptor | 🟢 Alta | 3 | 0 |
| `solin` | entidad | solicitud de crédito | 🟡 Media | 3 | 0 |
| `ultimas` | modificador | últimas | 🟡 Media | 3 | 0 |
| `activos` | modificador | activos | 🟢 Alta | 2 | 0 |
| `beneficiarios` | entidad | beneficiarios | 🟢 Alta | 2 | 0 |
| `bym3` | entidad | Billetes y Monedas (v3) | 🟡 Media | 2 | 0 |
| `cant` | entidad | cantidad | 🟢 Alta | 2 | 0 |
| `cpl` | entidad | CPL — segmento o producto de cliente (sp_dictamina_ctes_cpl, sp_afore_ctes_cpl, sp_situacionespecialcte_cpl — bdinteg) | 🟡 Media | 2 | 0 |
| `ctanvl2` | entidad | Cuenta Nivel 2 (CNBV Circular Única de Bancos) — categoría regulatoria de cuenta bancaria con KYC; valida documentos digitales y huellas (sp_ctanvl2_*, DoctosCtaNvl2/) | 🟢 Alta | 2 | 0 |
| `denominaciones` | entidad | denominaciones | 🟢 Alta | 2 | 0 |
| `desbloquea` | acción | desbloquea cuenta | 🟢 Alta | 2 | 0 |
| `digitalizar` | acción | digitaliza documento | 🟢 Alta | 2 | 0 |
| `empresas` | entidad | empresas (nómina empresarial) | 🟢 Alta | 2 | 0 |
| `estadisticas` | entidad | estadísticas | 🟢 Alta | 2 | 0 |
| `fn` | prefijo | función SQL | 🟢 Alta | 2 | 0 |
| `garantia` | entidad | garantía | 🟢 Alta | 2 | 0 |
| `generafechpagoreestructura` | acción | genera fecha de pago de reestructura | 🟢 Alta | 2 | 0 |
| `medioacceso` | entidad | medio de acceso | 🟢 Alta | 2 | 0 |
| `pase` | acción | pase contable (registra/traslada a póliza o mayor) | 🟢 Alta | 2 | 0 |
| `portabilidad` | entidad | portabilidad (de nómina o número) | 🟢 Alta | 2 | 0 |
| `presenta` | acción | presenta | 🟢 Alta | 2 | 0 |
| `reinicia` | acción | reinicia / resetea | 🟢 Alta | 2 | 0 |
| `transportadora` | entidad | transportadora de valores (traslado de efectivo) | 🟢 Alta | 2 | 0 |
| `agendadas` | modificador | agendadas | 🟢 Alta | 1 | 0 |
| `avatar` | entidad | avatar (foto de perfil del usuario en app) | 🟢 Alta | 1 | 0 |
| `bym2` | entidad | Billetes y Monedas (v2) | 🟡 Media | 1 | 0 |
| `citas` | entidad | citas | 🟢 Alta | 1 | 0 |
| `clic` | entidad | BanCoppel Clic (tarjeta digital instantánea) | 🟢 Alta | 1 | 0 |
| `codigos` | entidad | códigos | 🟢 Alta | 1 | 0 |
| `ctefisico` | entidad | Cliente Físico — persona física (tp_persona CHAR(2)); distingue de persona moral; maneja datos de identidad y afiliación (bdibpi+bdinteg:ctefisico, ctefisico_mib*) | 🟢 Alta | 1 | 0 |
| `destino` | entidad | destino | 🟢 Alta | 0 | 1 |
| `divisas` | entidad | divisas | 🟢 Alta | 1 | 0 |
| `division` | entidad | división | 🟢 Alta | 1 | 0 |
| `documento` | entidad | documento | 🟢 Alta | 1 | 0 |
| `emisor` | entidad | emisor | 🟢 Alta | 1 | 0 |
| `extemporanea` | modificador | extemporánea | 🟢 Alta | 1 | 0 |
| `fallecimiento` | modificador | por fallecimiento | 🟢 Alta | 1 | 0 |
| `fisica` | modificador | persona física | 🟢 Alta | 0 | 1 |
| `folsuc` | entidad | folio de sucursal | 🟢 Alta | 0 | 1 |
| `frecpago` | entidad | frecuencia de pago | 🟢 Alta | 1 | 0 |
| `intercambio` | entidad | intercambio (interbancario) | 🟢 Alta | 1 | 0 |
| `intereses` | entidad | intereses | 🟢 Alta | 0 | 1 |
| `msjafore` | entidad | mensaje AFORE | 🟡 Media | 1 | 0 |
| `preventivo` | modificador | preventivo | 🟢 Alta | 1 | 0 |
| `rastreo` | entidad | rastreo (SPEI) | 🟢 Alta | 1 | 0 |
| `reproceso` | acción | reproceso | 🟢 Alta | 1 | 0 |
| `resultado` | entidad | resultado | 🟢 Alta | 1 | 0 |
| `sdodisp` | entidad | saldo disponible | 🟢 Alta | 1 | 0 |
| `situaciones` | entidad | situaciones de cuenta | 🟢 Alta | 1 | 0 |
| `telefonico` | modificador | telefónico | 🟢 Alta | 1 | 0 |
| `titular` | entidad | titular de cuenta | 🟢 Alta | 1 | 0 |
| `titulo` | entidad | título | 🟢 Alta | 0 | 1 |
| `visual` | modificador | visual | 🟢 Alta | 1 | 0 |
| `apell` | entidad | apellido | 🟡 Media | 0 | 0 |
| `asiento` | entidad | asiento contable | 🟢 Alta | 0 | 0 |
| `auditoria` | entidad | auditoría | 🟢 Alta | 0 | 0 |
| `aumento` | modificador | aumento | 🟡 Media | 0 | 0 |
| `aval` | entidad | aval / garante | 🟢 Alta | 0 | 0 |
| `biometrico` | entidad | biométrico | 🟢 Alta | 0 | 0 |
| `boveda` | entidad | bóveda | 🟢 Alta | 0 | 0 |
| `calif` | entidad | calificación | 🟡 Media | 0 | 0 |
| `cfdi` | regulatorio | CFDI — Comprobante Fiscal Digital por Internet (SAT · factura electrónica) | 🟢 Alta | 0 | 0 |
| `cnc` | entidad | CNC — sistema de configuración de planes fijos de Tarjetas Coppel (plazos_fijos, Buen Fin, carga de archivos, stat06 — bditarjeta:sp_cnc_*) | 🟡 Media | 0 | 0 |
| `cns` | acción | consulta | 🟡 Media | 0 | 0 |
| `codificacion` | entidad | codificación | 🟢 Alta | 0 | 0 |
| `comercio` | entidad | comercio afiliado | 🟢 Alta | 0 | 0 |
| `concentradora` | entidad | cuenta concentradora | 🟢 Alta | 0 | 0 |
| `consuta` | acción | consulta [typo] | 🟢 Alta | 0 | 0 |
| `corrige` | acción | corrige — acción de corrección de datos (bdicred:sp_corrige_*) | 🟡 Media | 0 | 0 |
| `decodificar` | acción | decodifica | 🟢 Alta | 0 | 0 |
| `denominacion` | entidad | denominación (valor facial del billete/moneda) | 🟢 Alta | 0 | 0 |
| `depuracion` | acción | depuración | 🟢 Alta | 0 | 0 |
| `efectiva` | entidad | Cuenta Efectiva Digital (débito BanCoppel) | 🟢 Alta | 0 | 0 |
| `empresarial` | entidad | empresarial (nómina) | 🟢 Alta | 0 | 0 |
| `factelect` | entidad | Factura Electrónica / CFDI | 🟢 Alta | 0 | 0 |
| `firme` | modificador | monto firme | 🟡 Media | 0 | 0 |
| `fisicas` | modificador | personas físicas | 🟢 Alta | 0 | 0 |
| `forzada` | modificador | forzada | 🟢 Alta | 0 | 0 |
| `ftc` | entidad | FTC — módulo de configuración de transferencia de archivos (SFTP/FTP IPs, passwords de proxy, SFTP depósito — bdilide:sp_ftc_*) | 🟡 Media | 0 | 0 |
| `fus2` | ambiguo | fusión v2 | 🔴 Ambigua | 0 | 0 |
| `generaredoctaeje` | acción | Genera Estado de Cuenta Ejecutivo — proceso de generación de EdoCta para cheques/captación; incluye variante con CFDI (bdicheq:sp_generaredoctaeje, sp_generaredoctaeje_factelect) | 🟢 Alta | 0 | 0 |
| `hipoteca` | entidad | crédito hipotecario (digital, desde 2025) | 🟢 Alta | 0 | 0 |
| `hipotecario` | entidad | crédito hipotecario | 🟢 Alta | 0 | 0 |
| `impuesto` | regulatorio | impuesto (SAT) | 🟢 Alta | 0 | 0 |
| `inactiv` | modificador | inactiva | 🟢 Alta | 0 | 0 |
| `inicial` | modificador | inicial | 🟢 Alta | 0 | 0 |
| `inicializa` | acción | inicializa | 🟢 Alta | 0 | 0 |
| `inicializar` | acción | inicializa | 🟢 Alta | 0 | 0 |
| `inmediato` | modificador | inmediato | 🟢 Alta | 0 | 0 |
| `ivasart61` | regulatorio | IVA sobre operaciones del Art. 61 LIC (alcance fiscal por confirmar con el SME) | 🔴 Ambigua | 0 | 0 |
| `manco` | entidad | Mancomunidad — cuenta u operación con múltiples titulares autorizados; requiere autorización de todos (bdibei:sp_*_manco_bei; DESCRIPCION: 'Actualiza Status Mancomunidad') | 🟢 Alta | 0 | 0 |
| `mesas` | entidad | Mesas de Control — equipo de revisión y autorización de solicitudes de crédito (plural de Mesa de Control) | 🟢 Alta | 0 | 0 |
| `mvl` | modificador | canal móvil | 🟢 Alta | 0 | 0 |
| `notifi` | acción | notifica | 🟡 Media | 0 | 0 |
| `ordenante` | entidad | ordenante (pagador que emite la orden SPEI) | 🟢 Alta | 0 | 0 |
| `ordenes` | entidad | órdenes | 🟢 Alta | 0 | 0 |
| `oxxo` | entidad | OXXO (red de depósito/retiro) | 🟢 Alta | 0 | 0 |
| `pieza` | entidad | pieza de efectivo (billete/moneda) | 🟢 Alta | 0 | 0 |
| `pin` | entidad | PIN dinámico (tarjeta digital) | 🟢 Alta | 0 | 0 |
| `pld` | regulatorio | PLD — Prevención de Lavado de Dinero (AML) | 🟢 Alta | 0 | 0 |
| `presentacion` | entidad | presentación | 🟢 Alta | 0 | 0 |
| `proac` | entidad | PROAC — producto de cuenta de ahorro con inscripción y ciclo anual (sp_proac_consultarincripcioncuentaproac, sp_proac_calc_proximoanio — bdicheq) | 🟡 Media | 0 | 0 |
| `propuesta` | entidad | propuesta | 🟢 Alta | 0 | 0 |
| `rcda` | entidad | RCDA — producto de captación/ahorro (apertura, incremento de saldo, acumulación mensual); gestionado en bdmis (sp_rcda_apert, sp_rcda_acumsdo_mes) | 🟡 Media | 0 | 0 |
| `recompensa` | entidad | recompensa / cashback (Coppel Max) | 🟡 Media | 0 | 0 |
| `reinicio` | acción | reinicio | 🟢 Alta | 0 | 0 |
| `remanente` | modificador | remanente | 🟡 Media | 0 | 0 |
| `stat06` | entidad | Stat06 — tipo/código de archivo de carga en procesamiento de tarjetas Coppel (bditarjeta:sp_cnc_cga_stat06; parámetros: ruta, nombre archivo, sistema, layout) | 🟡 Media | 0 | 0 |
| `suscriptores` | acción | gestiona suscriptores | 🟢 Alta | 0 | 0 |
| `synmotor` | entidad | SynMotor — motor de procesamiento de Syndein (empresa externa fintech); gestiona campos, parámetros y WSDL (intercard:sp_synmotor_*) | 🟡 Media | 0 | 0 |
| `tdd` | entidad | TDD — Tarjeta de Débito | 🟢 Alta | 0 | 0 |
| `venio` | entidad | convenio | 🟡 Media | 0 | 0 |

---

## B · Términos compuestos

Términos lexicalizados que se descomponen en átomos conocidos.

| Compuesto | Descomposición | Significado | Confiab. | frec-nom | frec-par |
|---|---|---|---|--:|--:|
| `numcte` | num + cte | número de cliente | 🟢 Alta | 1 | 268 |
| `fechainicio` | fecha + inicio | fecha inicio | 🟢 Alta | 0 | 181 |
| `numcliente` | num + cliente | número de cliente | 🟢 Alta | 0 | 131 |
| `fechainicial` | fecha + inicial | fecha inicial | 🟢 Alta | 0 | 90 |
| `numcuenta` | num + cuenta | número de cuenta | 🟢 Alta | 0 | 66 |
| `numtarjeta` | num + tarjeta | número de tarjeta | 🟢 Alta | 0 | 59 |
| `convenio` | con + venio | convenio (nómina/empresarial) | 🟢 Alta | 3 | 54 |
| `numempleado` | num + empleado | número de empleado | 🟢 Alta | 0 | 35 |
| `numsol` | num + sol | número de solicitud | 🟢 Alta | 1 | 31 |
| `fechaconsulta` | fecha + consulta | fecha de consulta | 🟢 Alta | 0 | 25 |
| `numcred` | num + cred | número de crédito | 🟢 Alta | 0 | 22 |
| `numproducto` | num + producto | número de producto | 🟢 Alta | 0 | 22 |
| `numsucursal` | num + sucursal | número de sucursal | 🟢 Alta | 0 | 20 |
| `genrep` | gen + rep | genera reporte (abreviación genrep) | 🟡 Media | 18 | 0 |
| `burofisicas` | buro + fisicas | Buró Personas Físicas — consulta al Buró de Crédito para personas físicas (bdiburo:burofisicas_cnr, burofisicas_clon, burofisicas_concilia_clon) | 🟢 Alta | 15 | 0 |
| `aumlincred` | aum + lincred | Aumento de Línea de Crédito — proceso de incremento del límite crediticio; 26+ SPs en bdicred (sp_*_aumlincred) | 🟢 Alta | 10 | 0 |
| `regordenctecte` | reg + orden + cte + cte | Regresa Orden Cuenta a Cuenta — operación de transferencia/orden entre cuentas propias del cliente (bdicheq:sp_regordenctecte, sp_regordenctecte_bex, sp_regordenctecte_web, sp_regordenctecte_pp) | 🟡 Media | 10 | 0 |
| `aplicaordenpago` | aplica + ordenpago | aplica orden de pago | 🟢 Alta | 8 | 0 |
| `edocta` | edo + cta | Estado de Cuenta — documento periódico de movimientos y saldos; generado como PDF (sp_ctanvl2_generapdf_pba) y enviado por email automático (bdinteg) | 🟢 Alta | 7 | 0 |
| `lincred` | lin + cred | línea de crédito | 🟢 Alta | 5 | 1 |
| `activa` | act + iva | activa | 🟢 Alta | 4 | 0 |
| `consprodcte` | cons + prod + cte | consulta producto de cliente | 🟢 Alta | 4 | 0 |
| `debcred` | deb + cred | débito/crédito (movimiento) | 🟡 Media | 4 | 0 |
| `recordenpago` | rec + ordenpago | recibe orden de pago | 🟢 Alta | 4 | 0 |
| `subproducto` | sub + producto | sub-producto | 🟢 Alta | 2 | 1 |
| `catdenominacion` | cat + denominacion | catálogo de denominaciones | 🟢 Alta | 2 | 0 |
| `claverastreo` | clave + rastreo | clave de rastreo SPEI (hasta 30 posiciones alfanuméricas, Banxico) | 🟢 Alta | 0 | 2 |
| `consutacat` | consuta + cat | consulta catálogo [typo] | 🟢 Alta | 2 | 0 |
| `ctaclabe` | cta + clabe | cuenta CLABE | 🟢 Alta | 1 | 1 |
| `edoctacrd` | edocta + crd | Estado de Cuenta Crédito — documento de movimientos y saldos de crédito; carga de movhis y gestión de aclaraciones (bdicred:carga_movhis_edoctacrd, aclaraciones_edoctacrd_sif) | 🟢 Alta | 2 | 0 |
| `reccancelacion` | rec + cancelacion | recibe cancelación | 🟢 Alta | 2 | 0 |
| `abonoinmediato` | abono + inmediato | abono inmediato | 🟢 Alta | 1 | 0 |
| `datosdia` | datos + dia | datos del día | 🟢 Alta | 1 | 0 |
| `generafolionomina` | genera + folionomina | genera folio de nómina | 🟢 Alta | 1 | 0 |
| `movhis` | mov + his | Movimientos Históricos — tabla/proceso de historial de movimientos (bdicheq:arrmovhis, borra_movhis; bdicred:carga_movhis_edoctacrd) | 🟢 Alta | 1 | 0 |
| `pasecont` | pase + cont | realiza el pase contable (registro a póliza/mayor) | 🟢 Alta | 1 | 0 |
| `recdevolucion` | rec + devolucion | recibe devolución | 🟢 Alta | 1 | 0 |
| `recextemporanea` | rec + extemporanea | recibe orden extemporánea | 🟢 Alta | 1 | 0 |
| `tpcalculo` | tp + calculo | tipo de cálculo | 🟢 Alta | 1 | 0 |
| `admtoken` | adm + token | AdmToken — módulo de administración de tokens de autenticación para personas morales (empresas) en BEI; gestiona solicitudes, estados, devoluciones y comentarios (bdibei:sp_*_admtoken_bei) | 🟢 Alta | 0 | 0 |
| `archsdos` | arch + sdos | Archivos de Saldos — comentario explícito: 'Genera archivos de saldos diarios y mensuales' (bdicheq:gen_archsdos) | 🟢 Alta | 0 | 0 |
| `cargamanual` | carga + manual | carga manual | 🟢 Alta | 0 | 0 |
| `cargamovimiento` | carga + movimiento | carga movimiento | 🟢 Alta | 0 | 0 |
| `cilocconsulta` | ciloc + consulta | consulta local (cobranza) | 🟢 Alta | 0 | 0 |
| `conciliachq` | concilia + chq | conciliación de cheques | 🟡 Media | 0 | 0 |
| `confirmasms` | confirma + sms | confirma vía SMS (2FA) | 🟢 Alta | 0 | 0 |
| `conscedulas` | cons + cedulas | consulta cédulas | 🟢 Alta | 0 | 0 |
| `consreporte` | cons + reporte | consulta reporte | 🟢 Alta | 0 | 0 |
| `conssaldosdiarios` | cons + saldos + diarios | consulta saldos diarios | 🟢 Alta | 0 | 0 |
| `ctasinactivas` | ctas + inactivas | cuentas inactivas | 🟢 Alta | 0 | 0 |
| `devforzada` | dev + forzada | devolución forzada | 🟢 Alta | 0 | 0 |
| `edocuenta` | edo + cuenta | Estado de Cuenta (variante ortográfica de edocta — bdicheq/bdisolic:sp_*edocuenta*) | 🟡 Media | 0 | 0 |
| `estatussolic` | estatus + solic | estatus de solicitud | 🟢 Alta | 0 | 0 |
| `folionomina` | folio + nomina | folio de nómina | 🟢 Alta | 0 | 0 |
| `monitorsol` | monitor + sol | Monitor de Solicitudes — sistema de monitoreo de solicitudes de crédito por sucursal/empresa; parámetros: empresa, sucursal, status_solicitud, num_producto (bdicred+bdisolic:envia_monitorsol) | 🟢 Alta | 0 | 0 |
| `nombreref` | nombre + ref | nombre de referencia | 🟢 Alta | 0 | 0 |
| `obtenerctas` | obtener + ctas | obtener cuentas (bdicheq:sp_obtenerctas_*) | 🟡 Media | 0 | 0 |
| `ordenpago` | orden + pago | orden de pago | 🟢 Alta | 0 | 0 |
| `pasecheq` | pase + cheq | pase de cheque (a compensación/conciliación) | 🟢 Alta | 0 | 0 |
| `productotransaccion` | producto + transaccion | producto-transacción | 🟢 Alta | 0 | 0 |
| `repipab` | rep + ipab | Reporte IPAB — reporte regulatorio de seguimiento de depósitos (bdibei:sp_repipab_*) | 🟢 Alta | 0 | 0 |

---

## C · Candidatos sin clasificar (fragmentos frecuentes)

Fragmentos que el segmentador no reconoce y aparecen ≥ 4 veces. Son los **próximos términos a clasificar con el SME** — cada uno agregado a `sp_vocab.py` sube la cobertura de todos los SPs que lo contienen.

| Fragmento | Frecuencia | Hipótesis (por confirmar) |
|---|--:|---|
| `ini` | 112 | — |
| `ert` | 56 | — |
| `orte` | 29 | — |
| `limite` | 26 | — |
| `tot` | 24 | — |
| `area` | 24 | — |
| `dos` | 22 | — |
| `prov` | 21 | — |
| `funcion` | 21 | — |
| `can` | 18 | — |
| `user` | 18 | — |
| `padre` | 18 | — |
| `iso` | 17 | — |
| `skip` | 17 | — |
| `osito` | 16 | — |
| `das` | 16 | — |
| `tra` | 15 | — |
| `ositos` | 15 | — |
| `colonia` | 15 | — |
| `fin` | 15 | — |
| `pei` | 15 | — |
| `ital` | 15 | — |
| `usejecuta` | 15 | — |
| `ret` | 14 | — |
| `pro` | 14 | — |
| `cla` | 14 | — |
| `mento` | 14 | — |
| `dir` | 14 | — |
| `address` | 14 | — |
| `entrada` | 13 | — |
| `efec` | 13 | — |
| `res` | 13 | — |
| `osicion` | 13 | — |
| `prove` | 13 | — |
| `per` | 13 | — |
| `municipio` | 13 | — |
| `ejecut` | 13 | — |
| `acc` | 13 | — |
| `cor` | 12 | — |
| `observaciones` | 12 | — |
| `usu` | 12 | — |
| `tension` | 12 | — |
| `partner` | 12 | — |
| `ccc` | 12 | — |
| `pca` | 12 | — |
| `cualquier` | 12 | — |
| `msj` | 11 | — |
| `bit` | 11 | — |
| `uento` | 11 | — |
| `ago` | 11 | — |
| `curp` | 11 | — |
| `ular` | 11 | — |
| `mtcn` | 11 | — |
| `nametype` | 11 | — |
| `paterno` | 11 | — |
| `materno` | 11 | — |
| `ejercicio` | 11 | — |
| `itente` | 11 | — |
| `flujo` | 10 | — |
| `mod` | 10 | — |

---

## D · Resumen de confiabilidad

| Nivel | Términos | % |
|---|--:|--:|
| 🟢 Alta | 530 | 81% |
| 🟡 Media | 113 | 17% |
| 🔴 Ambigua | 4 | 0% |
| **Total clasificado** | **647** | |
| ⚪ Candidatos pendientes | 60 | |

*Generado por Specialist — Informix SPL Analysis · Etapa 3 · fuente: callgraph-data.json + source/ + sp_vocab.py*
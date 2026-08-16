# Informix · Inventario de Términos del Vocabulario

> **Componente:** Informix · SPE-AM-001 · Etapa 3 — Business Logic Extraction  
> **Corpus:** 3,761 SPs conectados (nombres + parámetros del código fuente) · **Vocabulario:** `sp_vocab.py`  
> **Generado:** 2026-07-03 por `build-vocab-inventory.py`  

**Confiabilidad:** 🟢 Alta (confirmada por código/param o significado inequívoco) · 🟡 Media (inferida por convención) · 🔴 Ambigua (requiere SME/DBA) · ⚪ Candidato (sin clasificar).  
**Columnas:** `frec-nom` = veces que aparece en nombres de SP · `frec-par` = veces como parámetro (evidencia de código).

Totales: **635 términos atómicos** · **55 términos compuestos** · **60 candidatos sin clasificar**.

---

## A · Términos atómicos (individuales)

Morfemas irreducibles — los building blocks del vocabulario.

| Término | Categoría | Significado | Confiab. | frec-nom | frec-par |
|---|---|---|---|--:|--:|
| `sp` | prefijo | stored procedure | 🟢 Alta | 3951 | 0 |
| `consulta` | acción | consulta / proyecta estado de entidad; sp_consulta_saldos_general (bdicred, fi=435) devuelve 47 campos del snapshot financiero de un crédito (cap vig/trans/vdo, int, IVA, comisiones, línea disponible, bloqueos) usando DIRTY READ | 🟢 Alta | 822 | 0 |
| `cons` | acción | consulta | 🟢 Alta | 417 | 0 |
| `os` | entidad | OS — Originación de Solicitudes / subsistema de ofertas (sp_os_*, sp_calcula_estatus_os — bdisolic) | 🟢 Alta | 288 | 0 |
| `totales` | modificador | Modificador: variante de un SP que devuelve el conteo agregado para paginación | 🟢 Alta | 245 | 0 |
| `ro` | entidad | Oficios y requerimientos judiciales: búsqueda de personas, expedientes e imágenes certificadas atendidos bajo oficio (subsistema sw_ro_*) | 🟢 Alta | 227 | 0 |
| `ope` | acción | operación | 🟢 Alta | 189 | 0 |
| `rep` | acción | reporte | 🟢 Alta | 172 | 0 |
| `valida` | acción | valida acceso o condición antes de proceder; sp_valida_perfil_usuario (bdinteg, fi=388) consulta si_perfil_ejecut para perfiles 602/707/109/2001 y determina qué reporte muestra el ejecutivo; patrón: NVL check → tabla referencia → código+mensaje+bandera | 🟢 Alta | 170 | 0 |
| `reporte` | entidad | Salida estructurada de datos para consumo regulatorio, operativo o de negocio (ej. sp_reporte_usuarios_amov) | 🟢 Alta | 169 | 0 |
| `detalle` | entidad | Desglose renglón por renglón de una operación o consulta | 🟢 Alta | 158 | 0 |
| `cte` | entidad | cliente | 🟢 Alta | 151 | 0 |
| `actualiza` | acción | actualiza campo de estado en registro existente; sp_dicta_actualizastatusalerta (bdinteg, fi=270) escribe veredicto del analista de fraudes (status_alerta + analista_fraudes) en si_bitacora_comparaciones; verifica sqlerrd2≠0 para detectar fila no afectada | 🟢 Alta | 149 | 0 |
| `mc` | entidad | Mesa de Control: área que autoriza, atiende y da seguimiento a solicitudes de crédito | 🟢 Alta | 140 | 0 |
| `genera` | acción | genera artefacto de salida; sp_generararchivo_rst (bdicnweb, fi=345) descarga tablas a .txt en /RESPALDOSNEW/archivosRST/ vía SYSTEM+dbaccess (patrón RST de unload); sp_generafolionomina (bdicheq, fi=253) emite folios secuenciales de nómina | 🟢 Alta | 137 | 0 |
| `sac` | entidad | Servicios de Atención al Cliente — subsistema de atención en sucursal (ventanilla, domiciliación, abonos ATM, remesas WU); base de datos propia bdisac: con tabla sac_movimientoshistorial; confirmado por SME (2026-08-02) | 🟢 Alta | 125 | 0 |
| `cat` | entidad | catálogo | 🟢 Alta | 123 | 0 |
| `archivo` | entidad | Fichero de intercambio por lote (nómina, TEF, domiciliación, Buró de Crédito) | 🟢 Alta | 113 | 0 |
| `verifica` | acción | Acción: comprueba estatus, validez o consistencia de un dato o proceso | 🟢 Alta | 111 | 0 |
| `id` | entidad | identificador (de) | 🟢 Alta | 108 | 0 |
| `info` | entidad | información | 🟢 Alta | 107 | 0 |
| `con` | acción | consulta | 🟢 Alta | 106 | 0 |
| `cre` | entidad | crédito | 🟢 Alta | 105 | 0 |
| `ant` | modificador | anterior | 🟢 Alta | 104 | 0 |
| `cap` | entidad | Captación — cuentas de ahorro/depósito; evidencia: sp_cap_genrepcancelacioncuentascaptacion, nCtaCap, recalculagat1200 (GAT = Ganancia Anual Total regulado por Banxico) | 🟢 Alta | 104 | 0 |
| `web` | modificador | canal web | 🟢 Alta | 103 | 0 |
| `catalogo` | entidad | catálogo | 🟢 Alta | 97 | 0 |
| `obtiene` | acción | obtiene / recupera | 🟢 Alta | 97 | 0 |
| `cred` | entidad | crédito — productos financieros de préstamo en bdicred; familia dominante: consulta al Buró de Crédito para solicitudes de línea (sp_mon_buro_conssolcredlincred2, fi=325) con paginación, segmento/etiqueta y asignación a analista via SQL dinámico (5000 chars) | 🟢 Alta | 95 | 0 |
| `fal` | entidad | fal — fallo/disputa (prefijo sp_fal_* — aclaraciones bancarias — bdiaclaracion) | 🟢 Alta | 94 | 0 |
| `ctas` | entidad | cuentas | 🟢 Alta | 89 | 0 |
| `cg` | entidad | cg — Canal/Cuenta General (subsistema sp_cg_* — bdicnweb) | 🟢 Alta | 88 | 0 |
| `caja` | entidad | caja / ventanilla | 🟢 Alta | 84 | 0 |
| `sw` | entidad | sw — SoftWare/Switch (subsistema sp_sw_ro_* — bdicnweb) | 🟢 Alta | 83 | 0 |
| `guarda` | acción | guarda / almacena | 🟢 Alta | 82 | 0 |
| `tipo` | modificador | tipo de | 🟢 Alta | 80 | 0 |
| `tef` | entidad | TEF — transferencia electrónica de fondos | 🟢 Alta | 78 | 0 |
| `ofi` | entidad | oficio | 🟢 Alta | 76 | 0 |
| `carga` | acción | carga / ingresa | 🟢 Alta | 75 | 0 |
| `pba` | modificador | PBA — sufijo de SPs para Pruebas; confirmado por SME (Guerra, Alejandro, 2026-07-09) | 🟢 Alta | 73 | 0 |
| `act` | acción | actualiza | 🟢 Alta | 70 | 0 |
| `pago` | entidad | Abono que liquida total o parcialmente una obligación de crédito o servicio | 🟢 Alta | 70 | 0 |
| `rem` | entidad | remesa (forma corta) | 🟢 Alta | 70 | 0 |
| `cc` | entidad | Cuenta corriente/concentradora: administración de sucursales, plazas y CLABE de la cuenta | 🟢 Alta | 69 | 0 |
| `cp` | entidad | código postal | 🟢 Alta | 69 | 0 |
| `cta` | entidad | cuenta | 🟢 Alta | 68 | 0 |
| `ccl` | entidad | módulo de Cédulas de Captación e inversión — pagaré, ISR, saldos diarios, inversión auto-creciente (bdicnweb:sp_ccl_*) | 🟢 Alta | 67 | 0 |
| `comp` | modificador | complemento | 🟢 Alta | 67 | 0 |
| `tdc` | entidad | tarjeta de crédito (TDC) | 🟢 Alta | 65 | 0 |
| `pp` | entidad | PP — Pago Programado / domiciliación (apercred1_pp, generaedosctacrd_pp — D03; envia_monitorsol_pp — D06) | 🟢 Alta | 64 | 0 |
| `cuentas` | entidad | cuentas (plural) | 🟢 Alta | 62 | 0 |
| `esp` | modificador | especial | 🟢 Alta | 61 | 0 |
| `sol` | entidad | solicitud | 🟢 Alta | 61 | 0 |
| `arch` | entidad | archivo | 🟢 Alta | 60 | 0 |
| `ss` | entidad | ss — subsistema / canal de monitoreo (abreviación — envia_monitorsol_*_ss_* — bdisolic) | 🟢 Alta | 60 | 0 |
| `cuenta` | entidad | Contrato bancario del cliente (cheques, ahorro, crédito) identificado por número o CLABE | 🟢 Alta | 58 | 0 |
| `graba` | acción | graba / almacena | 🟢 Alta | 55 | 0 |
| `masivo` | modificador | Modificador: procesamiento por lote de múltiples registros en una sola corrida | 🟢 Alta | 55 | 0 |
| `rev` | acción | reversión (abreviación de reversa/reverso) | 🟢 Alta | 54 | 0 |
| `sucursal` | entidad | Oficina física de atención al cliente; unidad operativa que opera caja | 🟢 Alta | 54 | 0 |
| `cac` | prefijo | familia crédito (CAC) | 🟢 Alta | 52 | 0 |
| `datos` | entidad | Conjunto de campos o atributos que describen una entidad de negocio | 🟢 Alta | 52 | 0 |
| `credito` | entidad | crédito | 🟢 Alta | 51 | 0 |
| `gen` | acción | genera / general | 🟢 Alta | 51 | 0 |
| `bitacora` | entidad | bitácora | 🟢 Alta | 50 | 0 |
| `cheques` | entidad | Títulos de pago librados contra una cuenta; se compensan y devuelven vía CCE | 🟢 Alta | 50 | 0 |
| `inserta` | acción | inserta registro nuevo en tabla; sp_inserta_bitacora_cob (bdicobranza, fi=406) escribe en cb_bitacora con 3 tipos de ejecución: 01=inicio de proceso, 02=estado intermedio, 03=fin; obtiene timestamp UTC de sysmaster:sysshmvals | 🟢 Alta | 50 | 0 |
| `registra` | acción | Acción: da de alta y persiste un dato, evento o documento en el sistema | 🟢 Alta | 50 | 0 |
| `cargo` | entidad | cargo / débito | 🟢 Alta | 48 | 0 |
| `obtener` | acción | obtiene / recupera | 🟢 Alta | 48 | 0 |
| `aumlincred` | acción | Aumento de Línea de Crédito — proceso de incremento del límite crediticio; 26+ SPs en bdicred (sp_*_aumlincred) | 🟢 Alta | 47 | 0 |
| `ctes` | entidad | clientes | 🟢 Alta | 46 | 0 |
| `productos` | entidad | Catálogo de instrumentos bancarios (crédito, cuenta, seguro) con sus comisiones y versiones | 🟢 Alta | 46 | 0 |
| `rcda` | entidad | RCDA — producto de captación/ahorro (apertura, incremento de saldo, acumulación mensual); gestionado en bdmis (sp_rcda_apert, sp_rcda_acumsdo_mes) | 🟢 Alta | 45 | 0 |
| `solicitud` | entidad | Petición del cliente de un producto o servicio que sigue flujo de originación y autorización | 🟢 Alta | 45 | 0 |
| `atms` | entidad | cajeros automáticos (ATM) | 🟢 Alta | 44 | 0 |
| `cont` | prefijo | familia contabilidad | 🟢 Alta | 44 | 0 |
| `param` | entidad | parámetro | 🟢 Alta | 44 | 0 |
| `total` | modificador | Modificador: cifra agregada o conteo global de una consulta o cálculo, no el detalle línea a línea | 🟢 Alta | 44 | 0 |
| `cnsif` | entidad | SIF — Sistema de Información Financiero (sp_cnsif_confirmaejecutivo fan_in=2400 — #1 SP Informix; tablas si_seg_usuarios_funciones; confirmado SPE 2026-08-08) | 🟢 Alta | 42 | 0 |
| `rec` | acción | recepción / recibe | 🟢 Alta | 42 | 0 |
| `int` | entidad | interés | 🟢 Alta | 41 | 0 |
| `procesa` | acción | Acción: transformar y aplicar el contenido de archivos, tramas o solicitudes al core | 🟢 Alta | 41 | 0 |
| `alta` | acción | da de alta / registra | 🟢 Alta | 40 | 0 |
| `mov` | entidad | movimiento | 🟢 Alta | 40 | 0 |
| `coppel` | entidad | Coppel (grupo) | 🟢 Alta | 39 | 0 |
| `bts` | entidad | Bancomer Transfer Services — canal de transferencias BBVA; base de datos propia bdibts; confirmado por SME (2026-08-02) | 🟢 Alta | 38 | 0 |
| `cliente` | entidad | Persona física o moral titular de productos bancarios BanCoppel | 🟢 Alta | 38 | 0 |
| `ins` | acción | insertar | 🟢 Alta | 38 | 0 |
| `por` | modificador | por (criterio) | 🟢 Alta | 38 | 0 |
| `sms` | entidad | Mensaje de texto al celular del cliente para avisos y confirmaciones | 🟢 Alta | 38 | 0 |
| `tar` | entidad | Tarjeta (abreviación — bdicheq/bdicred: cons_cta_o_tar, mover_his_tar, obtener_cta_con_num_tar) | 🟢 Alta | 38 | 0 |
| `fc` | entidad | fc — Fuentes Combinadas (subsistema sp_fc_*; biométricos — bdicnweb) | 🟢 Alta | 37 | 0 |
| `prod` | entidad | producto | 🟢 Alta | 37 | 0 |
| `reportes` | entidad | Salidas estructuradas de datos para consumo regulatorio, operativo o de negocio | 🟢 Alta | 37 | 0 |
| `sd` | entidad | sd — saldo disponible (abreviación en código de crédito) | 🟢 Alta | 37 | 0 |
| `soe` | entidad | SOE — Soporte Operativo EmpresaNet; confirmado por SME (Jorge Isaac Díaz, 2026-07-09) | 🟢 Alta | 37 | 0 |
| `spei` | prefijo | familia SPEI — pagos interbancarios certificados Banxico; sp_cons_spei_aud (bdinteg, fi=122) audita transacciones por rango de fecha devolviendo folio+monto+referencia con paginación (skip/límite); bdispei contiene recepción de errores CoDi y devoluciones | 🟢 Alta | 37 | 0 |
| `aud` | entidad | auditoría | 🟢 Alta | 36 | 0 |
| `cambio` | entidad | cambio (de estatus, domicilio, etc.) | 🟢 Alta | 36 | 0 |
| `dic` | entidad | [polisemia] Dictamen (bdicnweb:sp_dic_* — decisión crediticia, analista de dictamen, hawk) | Diciembre (columna dic en tablas de series mensuales ene…dic) | 🟢 Alta | 36 | 0 |
| `envio` | acción | envía | 🟢 Alta | 36 | 0 |
| `usuario` | entidad | Empleado u operador con perfil y permisos para operar el sistema | 🟢 Alta | 36 | 0 |
| `aplica` | acción | aplica / ejecuta | 🟢 Alta | 35 | 0 |
| `archivos` | entidad | Ficheros de intercambio cargados o generados para procesos batch (TEF, CCE, AFORE, domiciliación) | 🟢 Alta | 35 | 0 |
| `elimina` | acción | Acción: borra o depura registros de tablas operativas o temporales | 🟢 Alta | 35 | 0 |
| `suc` | modificador | sucursal | 🟢 Alta | 35 | 0 |
| `cancela` | acción | Acción: anula una cuenta, crédito, tarjeta, token o servicio | 🟢 Alta | 34 | 0 |
| `desc` | entidad | [polisemia] Descripción (sp_desc_ret: devuelve descripción del código de retorno) | Descarga (sp_desc_archivos_cfdi/conc: descarga archivos CFDI y conciliación) | 🟢 Alta | 34 | 0 |
| `reg` | acción | registro | 🟢 Alta | 34 | 0 |
| `det` | entidad | detalle | 🟢 Alta | 33 | 0 |
| `fecha` | entidad | Dato de calendario que acota o sella una operación o proceso | 🟢 Alta | 33 | 0 |
| `reverso` | acción | Acción: reversión de una operación aplicada para dejarla sin efecto (pagos, cargos, transferencias) | 🟢 Alta | 33 | 0 |
| `saldos` | entidad | Importes disponibles o adeudados por cuenta; base del devengo de intereses y del corte | 🟢 Alta | 33 | 0 |
| `admin` | entidad | Administrador — rol de usuario con privilegios administrativos (pIdAdmin INTEGER en bdibei/bdibpi); también administración de tasas y procesos | 🟢 Alta | 32 | 0 |
| `cjunk` | ambiguo | variable temporal (ruido de código, se ignora) | 🔴 Ambigua | 32 | 0 |
| `error` | entidad | Condición de fallo registrada en bitácora con código y descripción para diagnóstico y reenvío | 🟢 Alta | 32 | 0 |
| `linea` | entidad | línea (de crédito) | 🟢 Alta | 32 | 0 |
| `moral` | modificador | persona moral | 🟢 Alta | 32 | 0 |
| `movimientos` | entidad | Cargos y abonos registrados en una cuenta o crédito; base del estado de cuenta y la conciliación | 🟢 Alta | 32 | 0 |
| `obten` | acción | obtiene / recupera | 🟢 Alta | 32 | 0 |
| `xml` | entidad | Formato de intercambio de mensajes estructurados entre sistemas | 🟢 Alta | 32 | 0 |
| `dia` | modificador | del día | 🟢 Alta | 31 | 0 |
| `transaccion` | entidad | transacción | 🟢 Alta | 31 | 0 |
| `estatus` | entidad | estado de un objeto de negocio; en bdicred: estatus_cred (activo/bloqueado/vencido), en bdinteg: status_alerta (veredicto antifraude en si_bitacora_comparaciones), en bdicnweb: estatus de solicitud y proceso; valor siempre CHAR(1-2) codificado | 🟢 Alta | 30 | 0 |
| `general` | modificador | Modificador: alcance amplio o consolidado, sin filtros específicos | 🟢 Alta | 30 | 0 |
| `app` | modificador | canal app | 🟢 Alta | 29 | 0 |
| `cartera` | entidad | cartera de crédito | 🟢 Alta | 29 | 0 |
| `ctepr` | entidad | Cliente Prospecto — cliente potencial aún sin cuenta abierta (sp_catalogoscteprospecto, sp_consdireccionescteprospecto, sp_cancelaperturacteprospecto — bdicnweb) | 🟢 Alta | 29 | 0 |
| `msi` | entidad | meses sin intereses (MSI) | 🟢 Alta | 29 | 0 |
| `notifica` | acción | Acción: comunica al cliente o usuario un evento por SMS, correo u otro canal | 🟢 Alta | 29 | 0 |
| `abono` | entidad | abono / crédito | 🟢 Alta | 28 | 0 |
| `cancelacion` | acción | cancela | 🟢 Alta | 28 | 0 |
| `dep` | entidad | depósito | 🟢 Alta | 28 | 0 |
| `dev` | acción | devolución | 🟢 Alta | 28 | 0 |
| `domi` | entidad | domiciliación | 🟢 Alta | 28 | 0 |
| `mail` | entidad | correo electrónico | 🟢 Alta | 28 | 0 |
| `monitor` | entidad | Tablero de seguimiento en tiempo real del estatus de procesos, operaciones y efectivo en caja | 🟢 Alta | 28 | 0 |
| `ref` | ambiguo | referencia | 🔴 Ambigua | 28 | 0 |
| `solicitudes` | entidad | solicitudes (plural) | 🟢 Alta | 28 | 0 |
| `wu` | entidad | Western Union — servicio de remesas/transferencias internacionales (bdisac) | 🟢 Alta | 28 | 0 |
| `asigna` | acción | Acción: vincula una solicitud, usuario o recurso a un analista o responsable | 🟢 Alta | 27 | 0 |
| `banco` | entidad | Institución bancaria contraparte en transferencias interbancarias (TEF, SPEI); catálogo de bancos participantes | 🟢 Alta | 27 | 0 |
| `conciliacion` | acción | conciliación | 🟢 Alta | 27 | 0 |
| `historico` | modificador | histórico | 🟢 Alta | 27 | 0 |
| `producto` | entidad | Instrumento bancario ofertado (crédito, cuenta, seguro) definido en catálogo | 🟢 Alta | 27 | 0 |
| `remesas` | entidad | remesas internacionales | 🟢 Alta | 27 | 0 |
| `iva` | regulatorio | IVA (impuesto — SAT) | 🟢 Alta | 26 | 0 |
| `obt` | acción | obtiene | 🟢 Alta | 26 | 0 |
| `parametros` | entidad | parámetros | 🟢 Alta | 26 | 0 |
| `respuesta` | entidad | Registro del resultado devuelto por un servicio o contraparte (Buró, Western Union, validaciones PAYI/REVI) | 🟢 Alta | 26 | 0 |
| `busca` | acción | busca / localiza | 🟢 Alta | 25 | 0 |
| `deb` | modificador | débito | 🟢 Alta | 25 | 0 |
| `dinya` | entidad | DINYA — sistema/plataforma de remesas domésticas en sucursal; retorna nombre_remitente, sucursal_origen, importe_eviado (bdicnweb:sp_*dinya*) | 🟢 Alta | 25 | 0 |
| `faltantes` | modificador | Modificador: elementos ausentes (documentos del expediente, efectivo de caja o cajero) | 🟢 Alta | 25 | 0 |
| `mac` | entidad | dirección MAC | 🟢 Alta | 25 | 0 |
| `nombre` | entidad | Denominación textual de una persona, archivo o entidad | 🟢 Alta | 25 | 0 |
| `pos` | entidad | punto de venta (POS) | 🟢 Alta | 25 | 0 |
| `auto` | modificador | automático (proceso automático / batch — sp_*_auto) | 🟢 Alta | 24 | 0 |
| `concilia` | acción | conciliación | 🟢 Alta | 24 | 0 |
| `imp` | entidad | Impago — pago vencido o fallido; confirmado: n_impagos_consec (impagos consecutivos), n_imp_hist_6m (historial 6 meses) en motor de scoring crediticio (bdicred) | 🟢 Alta | 24 | 0 |
| `operaciones` | entidad | operaciones (plural) | 🟢 Alta | 24 | 0 |
| `tarjeta` | entidad | Plástico de débito o crédito asociado a una cuenta del cliente | 🟢 Alta | 24 | 0 |
| `exp` | modificador | sufijo Exportar — SP genera/exporta archivo de salida (sp_*_exp: generaarchivocuentasnomina_exp, perfisica_listanegra_exp, reversion_exp) | 🟢 Alta | 23 | 0 |
| `gral` | modificador | general | 🟢 Alta | 23 | 0 |
| `pagos` | entidad | pagos (plural) | 🟢 Alta | 23 | 0 |
| `tel` | entidad | teléfono | 🟢 Alta | 23 | 0 |
| `trans` | entidad | [polisemia] Transferencia (bditransfer, bditrans: transferencias y remesas con campos pbco_dest/ppais_dest) | Transacción (sufijo genérico en SPs de reversión y procesamiento) | 🟢 Alta | 23 | 0 |
| `comision` | regulatorio | comisión (CONDUSEF — debe estar en RECO) | 🟢 Alta | 22 | 0 |
| `emp` | entidad | Empresa — empleadora del cliente; vinculada a crédito de nómina (ADN); SPs: sp_consulta_datos_emp_bei (phone+address), sp_genera_emp_gc (Grupo Coppel), inserta_rel_cte_emp | 🟢 Alta | 22 | 0 |
| `oficio` | entidad | oficio (requerimiento judicial/autoridad) | 🟢 Alta | 22 | 0 |
| `proceso` | entidad | Corrida batch o flujo operativo con estatus rastreable vía monitor (conciliación, cierre, generación de archivos) | 🟢 Alta | 22 | 0 |
| `sdo` | entidad | saldo | 🟢 Alta | 22 | 0 |
| `servicio` | entidad | Producto o funcionalidad contratable activable por canal (EmpresaNet, BEI); alta/baja/consulta | 🟢 Alta | 22 | 0 |
| `transfer` | entidad | transferencia (forma larga de 'trans') | 🟢 Alta | 22 | 0 |
| `upgrade` | acción | actualiza producto (upgrade) | 🟢 Alta | 22 | 0 |
| `usuarios` | entidad | Empleados u operadores con perfil y permisos; sujetos de bitácora y control de acceso | 🟢 Alta | 22 | 0 |
| `afore` | entidad | AFORE (Afore Coppel — 2ª mayor de México, ~14.5M cuentas) | 🟢 Alta | 21 | 0 |
| `bpi` | modificador | Banca Por Internet (canal web BPI) | 🟢 Alta | 21 | 0 |
| `chi` | entidad | CHI — formato/protocolo de consulta al Buró de Crédito (bdiburo/bdicred:sp_chi_cre_consulta_sic, sp_chi_cre_layout_sics, sp_chi_cre_result_consulta_sic; SICS = Sociedad de Información Crediticia) | 🟢 Alta | 21 | 0 |
| `cod` | entidad | código | 🟢 Alta | 21 | 0 |
| `digitalizacion` | entidad | digitalización de documentos | 🟢 Alta | 21 | 0 |
| `expediente` | entidad | Conjunto de documentos digitalizados del cliente por producto, base del dictamen crediticio | 🟢 Alta | 21 | 0 |
| `fatca` | regulatorio | FATCA (reporte fiscal cuentas EE.UU. — SAT/IRS) | 🟢 Alta | 21 | 0 |
| `inf` | entidad | información | 🟢 Alta | 21 | 0 |
| `poliza` | entidad | póliza contable | 🟢 Alta | 21 | 0 |
| `cel` | entidad | celular | 🟢 Alta | 20 | 0 |
| `edo` | entidad | estado | 🟢 Alta | 20 | 0 |
| `monto` | entidad | Valor monetario de una operación, límite o convenio | 🟢 Alta | 20 | 0 |
| `saldo` | entidad | Importe disponible o adeudado en una cuenta a una fecha dada | 🟢 Alta | 20 | 0 |
| `seg` | entidad | [polisemia] Seguridad (bdicnweb: usuarios, perfiles, app móvil) | Seguro (bdisac: pólizas — sac_abono_seg, sac_cons_seg; poliza + cantidadseguros + claveseguro) | 🟢 Alta | 20 | 0 |
| `soc` | entidad | Sistema Operativo Central (SOC) — confirmado SME | 🟢 Alta | 20 | 0 |
| `tarjetas` | entidad | tarjetas (plural) | 🟢 Alta | 20 | 0 |
| `token` | entidad | token (autenticación) | 🟢 Alta | 20 | 0 |
| `adn` | acción | Adelanto de Nómina — producto de crédito al consumo liquidable vía descuento automático de nómina (cierre diario + cobro automático sobre bdicred) | 🟢 Alta | 19 | 0 |
| `baja` | modificador | de baja | 🟢 Alta | 19 | 0 |
| `bloqueo` | acción | bloquea cuenta | 🟢 Alta | 19 | 0 |
| `concentracion` | acción | concentración de fondos | 🟢 Alta | 19 | 0 |
| `crd` | entidad | crédito (abreviación) | 🟢 Alta | 19 | 0 |
| `doctos` | entidad | documentos | 🟢 Alta | 19 | 0 |
| `mes` | entidad | Periodo mensual base del cálculo de saldos promedio, devengos e indicadores; unidad de cierre contable | 🟢 Alta | 19 | 0 |
| `nom` | entidad | nómina | 🟢 Alta | 19 | 0 |
| `oro` | entidad | Tier medio de la Tarjeta de Crédito BanCoppel — jerarquía Clásica < Oro < Platino; path de upgrade desde crédito Grupo Coppel | 🟢 Alta | 19 | 0 |
| `ris` | entidad | Riesgo — módulo de gestión de riesgo crediticio (bdicnweb:sp_ris_*); confirmado en código: nivel_riesgo, grado_riesgo, califica_riesgo | 🟢 Alta | 19 | 0 |
| `solic` | entidad | solicitud | 🟢 Alta | 19 | 0 |
| `apertura` | entidad | apertura (de cuenta/crédito) | 🟢 Alta | 18 | 0 |
| `atm` | entidad | cajero automático (ATM) | 🟢 Alta | 18 | 0 |
| `cierre` | acción | Acción: proceso batch que consolida saldos y devenga intereses de un periodo (diario o masivo) | 🟢 Alta | 18 | 0 |
| `cnt` | entidad | CNT — módulo de convenios y control de descuentos de nómina de empleados (sp_cnt_catconvenio, detallefaltdescemp, genreportesolcred — bdicnweb) | 🟢 Alta | 18 | 0 |
| `cob` | entidad | cob — cobranza (abreviación de dominio — sp_repcob_*, sp_obtienecob_* — bdicobranza) | 🟢 Alta | 18 | 0 |
| `direcciones` | entidad | Domicilios y datos de contacto del cliente (postal, SMS, teléfonos) capturados y validados | 🟢 Alta | 18 | 0 |
| `fusion` | acción | fusiona cuentas | 🟢 Alta | 18 | 0 |
| `his` | modificador | histórico | 🟢 Alta | 18 | 0 |
| `movto` | entidad | movimiento | 🟢 Alta | 18 | 0 |
| `rol` | entidad | rol / perfil | 🟢 Alta | 18 | 0 |
| `tasa` | entidad | tasa (de interés) | 🟢 Alta | 18 | 0 |
| `buscar` | acción | búsqueda/buscar | 🟢 Alta | 17 | 0 |
| `busqueda` | acción | búsqueda | 🟢 Alta | 17 | 0 |
| `cce` | entidad | CCE — Cámara de Compensación Electrónica (CECOBAN/Banxico) — sistema de compensación interbancaria de cheques; SPs: sp_cce_consultar_cheques40/46, chequespresentados (bdicheq) | 🟢 Alta | 17 | 0 |
| `cheque` | entidad | Título de pago librado contra una cuenta; se compensa vía CCE | 🟢 Alta | 17 | 0 |
| `clientes` | entidad | clientes (plural) | 🟢 Alta | 17 | 0 |
| `consreportes` | acción | consulta reportes | 🟢 Alta | 17 | 0 |
| `diario` | modificador | Modificador: proceso o reporte que corre una vez al día | 🟢 Alta | 17 | 0 |
| `encabezado` | entidad | Bloque de cabecera con totales y datos de control de un archivo, lote o estado de cuenta | 🟢 Alta | 17 | 0 |
| `isr` | regulatorio | ISR — Impuesto Sobre la Renta (retención · SAT) | 🟢 Alta | 17 | 0 |
| `operacion` | acción | operación | 🟢 Alta | 17 | 0 |
| `reversa` | acción | Reversión — anula/revierte una operación (bdibei:sp_reversa_solicitudes_bei, sp_reversa_tokenasociados_bei) | 🟢 Alta | 17 | 0 |
| `autoriza` | acción | Acción: aprueba una operación o eleva su nivel de permiso | 🟢 Alta | 16 | 0 |
| `chq` | entidad | cheque (abreviación — bdicheq) | 🟢 Alta | 16 | 0 |
| `com` | entidad | Comisión bancaria — cobro de comisión sobre cuenta (bdicheq:sp_cobra_com, sp_com_manejo_cta_cobro_*; también en OXXO) | 🟢 Alta | 16 | 0 |
| `dotacion` | entidad | dotación de efectivo (a cajero/sucursal) | 🟢 Alta | 16 | 0 |
| `envios` | entidad | envíos | 🟢 Alta | 16 | 0 |
| `masiva` | modificador | Modificador: procesamiento por lote de múltiples registros en una sola corrida (altas, cargas, cancelaciones) | 🟢 Alta | 16 | 0 |
| `mensual` | modificador | Modificador: periodicidad de mes para reportes, cargas y cierres de saldo promedio | 🟢 Alta | 16 | 0 |
| `motor` | entidad | motor de decisión | 🟢 Alta | 16 | 0 |
| `movil` | modificador | canal móvil | 🟢 Alta | 16 | 0 |
| `reversion` | acción | reversa / rollback | 🟢 Alta | 16 | 0 |
| `tp` | modificador | tipo | 🟢 Alta | 16 | 0 |
| `buro` | entidad | Buró de Crédito | 🟢 Alta | 15 | 0 |
| `cal` | entidad | [polisemia] Cálculo (cal_fecha, cal_riesgo_cliente, cal_tradicion — operaciones matemáticas financieras) | Calendario (cal_habil_ant — días hábiles bancarios; bdicheq) | 🟢 Alta | 15 | 0 |
| `calcula` | acción | calcula (verbo activo — spei_calculointeres) | 🟢 Alta | 15 | 0 |
| `cam` | prefijo | cámara / captura contable | 🟢 Alta | 15 | 0 |
| `camp` | entidad | Campaña — campaña de cobranza o crédito (sp_envio_camp_ctes, sp_actvig_camp — bdicobranza + bdicred) | 🟢 Alta | 15 | 0 |
| `central` | modificador | Modificador: procesamiento o cuenta centralizada del core, frente a la operación por sucursal o local | 🟢 Alta | 15 | 0 |
| `club` | entidad | Club de Protección — producto de seguro grupal BanCoppel; movimientos históricos en bdisac:sac_movimientoshistorial; ventas en sp_rep_vtas_club_proteccion | 🟢 Alta | 15 | 0 |
| `corresp` | entidad | Corresponsal — corresponsal bancario; red de puntos de servicio no-sucursal regulada por CNBV (bdicheq:sp_corresp_*, sp_generar_acum_corresponsal_mc) | 🟢 Alta | 15 | 0 |
| `dotaciones` | entidad | dotaciones de efectivo | 🟢 Alta | 15 | 0 |
| `ejecuta` | acción | ejecuta (verbo — proceso / operación) | 🟢 Alta | 15 | 0 |
| `empleado` | entidad | Persona trabajadora de una empresa empleadora, sujeta a nómina y descuentos; también operador interno del banco | 🟢 Alta | 15 | 0 |
| `folio` | entidad | Identificador consecutivo único de una operación, solicitud o aclaración para su rastreo | 🟢 Alta | 15 | 0 |
| `hist` | modificador | histórico/historial | 🟢 Alta | 15 | 0 |
| `huella` | entidad | huella biométrica | 🟢 Alta | 15 | 0 |
| `ivr` | modificador | canal IVR (telefónico) | 🟢 Alta | 15 | 0 |
| `lincred` | entidad | línea de crédito | 🟢 Alta | 15 | 0 |
| `prestamo` | entidad | préstamo (Personal / Nómina / Digital BanCoppel) | 🟢 Alta | 15 | 0 |
| `reproceso` | acción | Acción: volver a ejecutar un proceso batch fallido o pendiente (cierre diario, reportes, emergentes) | 🟢 Alta | 15 | 0 |
| `sat` | regulatorio | SAT — Servicio de Administración Tributaria (CFDI, ISR, IVA) | 🟢 Alta | 15 | 0 |
| `sps` | prefijo | sps — prefijo alternativo de SP en bdibei (posiblemente 'stored procedure set' o convención local del equipo; vs el 'sp' estándar) | 🟢 Alta | 15 | 0 |
| `bloquea` | acción | bloquea cuenta | 🟢 Alta | 14 | 0 |
| `califica` | acción | califica / evalúa (scoring) | 🟢 Alta | 14 | 0 |
| `desbloqueo` | acción | desbloquea cuenta | 🟢 Alta | 14 | 0 |
| `devolucion` | acción | devuelve | 🟢 Alta | 14 | 0 |
| `quincena` | entidad | quincena (periodo de pago nómina/crédito Coppel) | 🟢 Alta | 14 | 0 |
| `revision` | entidad | revisión | 🟢 Alta | 14 | 0 |
| `sif` | entidad | SIF — canal de estado de cuenta (aclaraciones_edocta_sif, detalle_edocta_sif); procesa aclaraciones de TDC por tarjeta+fecha de emisión | 🟢 Alta | 14 | 0 |
| `analista` | entidad | Operador de Mesa de Control que revisa, dictamina y autoriza solicitudes de crédito y aumentos de línea | 🟢 Alta | 13 | 0 |
| `causa` | entidad | causa / motivo | 🟢 Alta | 13 | 0 |
| `cobranza` | entidad | Gestión de recuperación de cartera vencida: campañas telefónicas, convenios y marcación | 🟢 Alta | 13 | 0 |
| `combo` | entidad | combo / lista desplegable (control de UI en app) | 🟢 Alta | 13 | 0 |
| `depura` | acción | depura / purga registros expirados de tabla operativa; patrón observado en bdicred: FOREACH+DELETE+COMMIT por fila con contador iCuentasaDepurar, UPDATE STATISTICS al cierre; controla ventana horaria via sd_param cod_param=119 y soporta reinicio | 🟢 Alta | 13 | 0 |
| `desb` | acción | desbloqueo | 🟢 Alta | 13 | 0 |
| `estado` | entidad | estado (entidad federativa / estatus) | 🟡 Media | 13 | 0 |
| `pagares` | entidad | pagarés | 🟢 Alta | 13 | 0 |
| `perfil` | entidad | perfil de usuario | 🟢 Alta | 13 | 0 |
| `puntos` | entidad | puntos (recompensas) | 🟢 Alta | 13 | 0 |
| `upd` | acción | actualiza (update) | 🟢 Alta | 13 | 0 |
| `aut` | acción | autorización | 🟢 Alta | 12 | 0 |
| `clon` | entidad | [polisemia] Clon de SP (réplica funcional para variante de entorno o canal — similar a _pba; bdiburo:burofisicas_clon, bdibpi:sp_consultarctepmempresanet_clon) | Clonación fraudulenta (bdiauditor:sp_pld_chq_addfolio_clon — fraude de clonación de cheques/documentos en PLD) | 🟢 Alta | 12 | 0 |
| `evento` | entidad | evento/notificación | 🟢 Alta | 12 | 0 |
| `imagen` | entidad | imagen digital | 🟢 Alta | 12 | 0 |
| `ipab` | regulatorio | IPAB — Instituto para la Protección al Ahorro Bancario (seguro de depósitos hasta 400,000 UDIs por depositante; Banxico/CNBV) | 🟢 Alta | 12 | 0 |
| `marca` | entidad | Bandera aplicada a una cuenta o cliente por situación especial (IPAB, PLD, precalificación) | 🟢 Alta | 12 | 0 |
| `mon` | prefijo | monitor / módulo | 🟢 Alta | 12 | 0 |
| `num` | entidad | número (de) | 🟢 Alta | 12 | 0 |
| `ord` | entidad | ordenante / orden (SPEI) | 🟢 Alta | 12 | 0 |
| `registros` | entidad | Renglones de datos de una tabla; unidades de resultado en consultas paginadas | 🟢 Alta | 12 | 0 |
| `retiro` | entidad | Disposición de efectivo de una cuenta (cajero, sucursal, corresponsal); afecta saldo disponible | 🟢 Alta | 12 | 0 |
| `rpt` | entidad | reporte | 🟢 Alta | 12 | 0 |
| `traspaso` | acción | traspaso entre cuentas | 🟢 Alta | 12 | 0 |
| `venc` | entidad | vencimiento | 🟢 Alta | 12 | 0 |
| `b3` | modificador | sufijo de versión de SP (Bloque/Build 3) — patrón Informix: no existe ALTER PROCEDURE, se crea nueva versión con sufijo _b3/_b4/_b5 | 🟢 Alta | 11 | 0 |
| `bex` | entidad | BEX — canal o plataforma de Banca Por Internet (bdibpi); gestiona sesiones, preguntas de seguridad, cuentas cap/cred (sp_*_bex, sp_ini_session_bex) | 🟢 Alta | 11 | 0 |
| `bloq` | acción | bloqueo | 🟢 Alta | 11 | 0 |
| `borra` | acción | borra / elimina registros (borramovs_movhis, borramovscfd*) | 🟢 Alta | 11 | 0 |
| `bym` | entidad | Billetes y Monedas (efectivo en sucursal — evidencia: 'piezas' + 'denominación') | 🟢 Alta | 11 | 0 |
| `cedula` | entidad | cédula de identificación | 🟢 Alta | 11 | 0 |
| `debito` | entidad | débito | 🟢 Alta | 11 | 0 |
| `fechas` | entidad | Rango o conjunto de datos de calendario que acota consultas, cortes y quincenas | 🟢 Alta | 11 | 0 |
| `ine` | regulatorio | INE — Instituto Nacional Electoral (validación de identidad del cliente) | 🟢 Alta | 11 | 0 |
| `inv` | entidad | inv — inversión (abreviación — calsdoinvcrec, cierrechqinvcrec) | 🟢 Alta | 11 | 0 |
| `inversion` | entidad | inversión (pagaré / plazo) | 🟢 Alta | 11 | 0 |
| `lote` | entidad | lote (proceso batch) | 🟢 Alta | 11 | 0 |
| `manual` | modificador | Modificador: operación capturada o ejecutada por un operador, no automatizada | 🟢 Alta | 11 | 0 |
| `pagare` | entidad | pagaré | 🟢 Alta | 11 | 0 |
| `parametro` | entidad | parámetro | 🟢 Alta | 11 | 0 |
| `portanom` | entidad | Portabilidad de Nómina — portabilidad de domiciliación de nómina entre bancos (CNBV); gestiona solicitudes y archivos (bdicheq:sp_portanom_*) | 🟢 Alta | 11 | 0 |
| `proc` | entidad | proceso | 🟢 Alta | 11 | 0 |
| `remesa` | entidad | remesa (Western Union / MoneyGram) | 🟢 Alta | 11 | 0 |
| `scoring` | entidad | scoring crediticio | 🟢 Alta | 11 | 0 |
| `sdos` | entidad | saldos (abreviación) | 🟢 Alta | 11 | 0 |
| `sorteo` | entidad | Sorteo de efectivo BanCoppel: asignación de folios de premio según saldo, reportable al SAT | 🟢 Alta | 11 | 0 |
| `tco` | entidad | TCO — Tarjetas Coppel / TCoppel (producto de crédito Grupo Coppel); confirmado por SME (Jorge Isaac Díaz, 2026-07-09) | 🟢 Alta | 11 | 0 |
| `bccc` | entidad | BCCC — formato o protocolo de consulta al Buró de Crédito (bdiburo:sp_reenvio_sols_bccc9; catproducto, catcomentario) | 🟢 Alta | 10 | 0 |
| `canal` | entidad | canal (de distribución) | 🟢 Alta | 10 | 0 |
| `ciloc` | prefijo | consulta local de cobranza | 🟢 Alta | 10 | 0 |
| `clave` | entidad | Código identificador (CLABE, clave de retiro, homoclave) o credencial de acceso | 🟢 Alta | 10 | 0 |
| `corte` | entidad | corte (fecha de corte / período) | 🟢 Alta | 10 | 0 |
| `creditos` | entidad | créditos (plural) | 🟢 Alta | 10 | 0 |
| `diarios` | modificador | Modificador: proceso o dato con periodicidad de un día (cierre, saldos, movimientos) | 🟢 Alta | 10 | 0 |
| `evc` | entidad | EVC — Evaluación/Cartera a Quebrantar (write-off de cartera vencida; sp_evc_cartera_quebrantar, sp_evc_consexclusionlote — bdicnweb) | 🟢 Alta | 10 | 0 |
| `fusionados` | modificador | Modificador: clientes o documentos consolidados tras unificar expedientes duplicados | 🟢 Alta | 10 | 0 |
| `imagenes` | entidad | imágenes / documentos digitales | 🟢 Alta | 10 | 0 |
| `ingreso` | entidad | ingreso (del solicitante) | 🟢 Alta | 10 | 0 |
| `liquidacion` | entidad | liquidación | 🟢 Alta | 10 | 0 |
| `mensajes` | entidad | Conjunto de avisos o notificaciones al cliente u operador (SMS, estado de cuenta, cartera externa) | 🟢 Alta | 10 | 0 |
| `modificacion` | acción | modificación | 🟢 Alta | 10 | 0 |
| `motivo` | entidad | motivo / causa | 🟢 Alta | 10 | 0 |
| `telefonos` | entidad | teléfonos | 🟢 Alta | 10 | 0 |
| `acl` | prefijo | familia aclaraciones | 🟢 Alta | 9 | 0 |
| `canales` | entidad | canales (de distribución) | 🟢 Alta | 9 | 0 |
| `cedulas` | entidad | cédulas | 🟢 Alta | 9 | 0 |
| `ctamec` | entidad | Cuenta Mecánica — tipo de cuenta de cheques empresarial para nómina y pagos automáticos (bdicheq:sp_ctamec_*) | 🟢 Alta | 9 | 0 |
| `dictamen` | entidad | Resolución u opinión formal sobre crédito, fraude (HAWK) o situación del cliente | 🟢 Alta | 9 | 0 |
| `digi` | acción | digitalización | 🟢 Alta | 9 | 0 |
| `documentos` | entidad | Comprobantes que integran el expediente del cliente o de una solicitud | 🟢 Alta | 9 | 0 |
| `firmas` | entidad | firmas mancomunadas | 🟢 Alta | 9 | 0 |
| `iccat` | entidad | ICCAT — canal de atención al cliente en BPI; gestiona solicitudes de entrega y reposición de token, desbloqueo de acceso (bdibpi:sp_iccat_*, sp_*_iccat) | 🟢 Alta | 9 | 0 |
| `max` | modificador | máximo | 🟢 Alta | 9 | 0 |
| `presentado` | modificador | presentado (a cobro) | 🟢 Alta | 9 | 0 |
| `primer` | modificador | Modificador: primera ocurrencia de un evento del cliente (primer uso, primer consumo, primera compra) | 🟢 Alta | 9 | 0 |
| `situacion` | entidad | situación | 🟢 Alta | 9 | 0 |
| `zona` | entidad | Segmento territorial (zona, colonia, calle) usado para catalogar y validar el domicilio del cliente | 🟢 Alta | 9 | 0 |
| `calculo` | entidad | cálculo | 🟢 Alta | 8 | 0 |
| `ciudades` | entidad | ciudades (catálogo) | 🟢 Alta | 8 | 0 |
| `codigo` | entidad | código | 🟢 Alta | 8 | 0 |
| `compromiso` | entidad | compromiso de pago — promesa formal de liquidación (sp_consultacompromisosvigente) | 🟢 Alta | 8 | 0 |
| `decodifica` | acción | Acción: interpreta y separa los campos de una línea de captura o cadena codificada | 🟢 Alta | 8 | 0 |
| `domicilio` | entidad | Dirección registrada del cliente, validada contra INE/SAT/SEPOMEX y usada en KYC y notificaciones | 🟢 Alta | 8 | 0 |
| `final` | modificador | Modificador: marca de cierre o última fase de un proceso ya ejecutado (pase contable final, finalización de cédula) | 🟢 Alta | 8 | 0 |
| `fus` | acción | fusión de cuentas | 🟢 Alta | 8 | 0 |
| `gdf` | entidad | Gobierno de la CDMX: convenio de pago de impuestos y servicios (predial, agua, tenencia, licencias, derechos) — confirmado por código bdisac | 🟢 Alta | 8 | 0 |
| `hora` | entidad | Momento u horario límite que condiciona la ejecución de operaciones (TEF, remesas, cortes) | 🟢 Alta | 8 | 0 |
| `layout` | entidad | layout — formato de archivo de intercambio interbancario | 🟢 Alta | 8 | 0 |
| `plaza` | entidad | plaza (regional) | 🟢 Alta | 8 | 0 |
| `prospectos` | entidad | prospectos (nuevos clientes potenciales) | 🟢 Alta | 8 | 0 |
| `respalda` | acción | respalda / garantiza — aval o garantía de crédito (respalda_creditocrd, respaldacrd) | 🟢 Alta | 8 | 0 |
| `rfc` | entidad | RFC (registro fiscal) | 🟢 Alta | 8 | 0 |
| `salida` | entidad | Egreso de efectivo o dato producido; par de entrada/salida en caja, o output de un reporte | 🟢 Alta | 8 | 0 |
| `sbc` | entidad | saldo básico de cuenta (SBC) | 🟢 Alta | 8 | 0 |
| `telefono` | entidad | teléfono | 🟢 Alta | 8 | 0 |
| `art61` | regulatorio | Art. 61 LIC (cuentas inactivas cuyos saldos, tras años sin movimiento, prescriben a favor de la beneficencia pública) | 🟢 Alta | 7 | 0 |
| `calle` | entidad | calle (domicilio) | 🟢 Alta | 7 | 0 |
| `cheq` | entidad | cheque | 🟢 Alta | 7 | 0 |
| `cobra` | acción | cobra / aplica cobro / genera cargo | 🟢 Alta | 7 | 0 |
| `concreing` | entidad | Conciliación de Reingresos — proceso de conciliación de tarjetas reingresadas (bditarjeta:sp_concreing_*; gestiona archivos ATM, usuarios, horarios, parámetros) | 🟢 Alta | 7 | 0 |
| `correo` | entidad | correo electrónico | 🟢 Alta | 7 | 0 |
| `envia` | acción | envía | 🟢 Alta | 7 | 0 |
| `facturacion` | entidad | facturación | 🟢 Alta | 7 | 0 |
| `origen` | entidad | Canal o fuente de donde proviene una operación, solicitud o archivo | 🟢 Alta | 7 | 0 |
| `piezas` | entidad | piezas de efectivo (billetes y monedas) | 🟢 Alta | 7 | 0 |
| `referencia` | entidad | Dato que identifica un pago frecuente, beneficiario o tasa de referencia | 🟢 Alta | 7 | 0 |
| `registro` | entidad | Renglón o asiento individual almacenado en tabla; unidad mínima de dato persistido y rastreable | 🟢 Alta | 7 | 0 |
| `validacion` | acción | validación | 🟢 Alta | 7 | 0 |
| `aclaraciones` | entidad | aclaraciones (proceso de disputas/reclamaciones de cliente) | 🟢 Alta | 6 | 0 |
| `bei` | entidad | BEI — Banca En Internet; canal digital principal de BanCoppel; base de datos bdibei con 279+ SPs de operaciones, autenticación, transferencias y mancomunidad | 🟢 Alta | 6 | 0 |
| `benef` | entidad | beneficiario | 🟢 Alta | 6 | 0 |
| `captura` | acción | Acción: ingreso y persistencia de datos al sistema por un operador o carga (FATCA, crédito, parámetros) | 🟢 Alta | 6 | 0 |
| `cep` | entidad | Comprobante Electrónico de Pago (SPEI · Banxico) | 🟢 Alta | 6 | 0 |
| `cnr` | entidad | CNR — tipo o formato de consulta al Buró de Crédito para personas físicas (bdiburo:burofisicas_cnr; vcredito_maximo) | 🟢 Alta | 6 | 0 |
| `confirma` | acción | Acción: valida y da por firme una operación, pago o ejecutivo previamente capturado | 🟢 Alta | 6 | 0 |
| `consecutivo` | entidad | Número secuencial que identifica y ordena archivos o registros para su control y rastreo | 🟢 Alta | 6 | 0 |
| `correos` | entidad | correos electrónicos (email) | 🟢 Alta | 6 | 0 |
| `cpl` | entidad | CPL — segmento o producto de cliente (sp_dictamina_ctes_cpl, sp_afore_ctes_cpl, sp_situacionespecialcte_cpl — bdinteg) | 🟢 Alta | 6 | 0 |
| `descarga` | entidad | Extracción de archivos, imágenes o información desde el core para consumo externo (estados de cuenta, conciliación) | 🟢 Alta | 6 | 0 |
| `dicta` | entidad | subsistema de dictaminación antifraude en bdinteg (sp_dicta_*, fi≥270); gestiona veredictos de comparación biométrica en si_bitacora_comparaciones y alertas activas en si_bitacora_alerta_tmp; el analista_fraudes asigna status_alerta tras revisar la huella | 🟢 Alta | 6 | 0 |
| `forma` | acción | construye / arma | 🟡 Media | 6 | 0 |
| `habil` | entidad | día hábil — día bancario operativo (spei_validafecha, sp_cambio_fecha) | 🟢 Alta | 6 | 0 |
| `huellas` | entidad | huellas biométricas | 🟢 Alta | 6 | 0 |
| `indicadores` | entidad | Métricas de comportamiento del cliente o producto usadas en cartera, scoring y monitoreo (SPEI) | 🟢 Alta | 6 | 0 |
| `interes` | entidad | interés | 🟢 Alta | 6 | 0 |
| `mayor` | entidad | mayor contable | 🟢 Alta | 6 | 0 |
| `mensaje` | entidad | Texto o notificación enviada al cliente o al operador (SMS, avisos, mensajes de estado de cuenta) | 🟢 Alta | 6 | 0 |
| `msj` | entidad | mensaje — abreviación corta de mnsj (sp_validacion_msj) | 🟢 Alta | 6 | 0 |
| `parametrico` | entidad | paramétrico — parametrización de modelos (envío paramétrico) | 🟢 Alta | 6 | 0 |
| `recupera` | acción | recupera estado | 🟢 Alta | 6 | 0 |
| `recuperacion` | acción | recuperación (cobranza) | 🟢 Alta | 6 | 0 |
| `respaldo` | entidad | respaldo / garantía de crédito (aval) | 🟢 Alta | 6 | 0 |
| `sistema` | entidad | Módulo o subsistema aplicativo del core, o el reloj/fecha del entorno; ámbito de una operación (ej. sp_bitacorasistema) | 🟢 Alta | 6 | 0 |
| `supervision` | entidad | supervisión | 🟢 Alta | 6 | 0 |
| `trae` | acción | trae / recupera (verbo — sp_*_trae — bdisuc) | 🟢 Alta | 6 | 0 |
| `traspas` | acción | traspaso | 🟢 Alta | 6 | 0 |
| `vencimiento` | entidad | Fecha límite de una obligación o instrucción (pagaré, inversión); condiciona reinversión o exigibilidad | 🟢 Alta | 6 | 0 |
| `acceso` | entidad | Medio y permisos con que un usuario o cliente ingresa a un canal, cuenta o módulo | 🟢 Alta | 5 | 0 |
| `alertas` | entidad | Notificaciones de eventos que requieren atención (SPEI, CoDi, dictamen, PLD) | 🟢 Alta | 5 | 0 |
| `campana` | entidad | campaña | 🟢 Alta | 5 | 0 |
| `categoria` | entidad | categoría | 🟢 Alta | 5 | 0 |
| `compac` | entidad | Compromisos de Pago en Cobranza — acuerdos/convenios de pago activos o cumplidos el mismo día; historial en cb_compac_his (bdicobranza:sp_archivo_compac, sp_compac_consultacompromisosvigente) | 🟢 Alta | 5 | 0 |
| `declaracion` | entidad | declaración | 🟢 Alta | 5 | 0 |
| `digito` | entidad | dígito verificador | 🟢 Alta | 5 | 0 |
| `domiciliacion` | entidad | domiciliación | 🟢 Alta | 5 | 0 |
| `efectivo` | entidad | Dinero en billetes y monedas manejado en caja, cajero o traslado de valores | 🟢 Alta | 5 | 0 |
| `identificacion` | entidad | identificación | 🟢 Alta | 5 | 0 |
| `inicio` | modificador | Modificador: marca de comienzo de un periodo o proceso (inicio de mes, inicio de sesión) | 🟢 Alta | 5 | 0 |
| `marcas` | entidad | marcas de cuenta | 🟢 Alta | 5 | 0 |
| `mib` | entidad | MIB — módulo/canal de integración para cheques y tarjeta (cargo_ref_mib, cancelar_activar_cheque_mib — bdicheq + bdibpi) | 🟢 Alta | 5 | 0 |
| `movimiento` | entidad | Transacción individual (cargo o abono) registrada en una cuenta | 🟢 Alta | 5 | 0 |
| `orden` | entidad | Instrucción de pago o transferencia entre cuentas (SPEI, CoDi, host-to-host) | 🟢 Alta | 5 | 0 |
| `pais` | entidad | país | 🟢 Alta | 5 | 0 |
| `periodo` | entidad | Rango de fechas que acota facturación, corte o consulta | 🟢 Alta | 5 | 0 |
| `realiza` | acción | realiza / ejecuta una operación SPEI | 🟢 Alta | 5 | 0 |
| `reestructura` | acción | reestructura crédito | 🟢 Alta | 5 | 0 |
| `reserva` | entidad | Reserva preventiva crediticia CNBV: provisión por probabilidad de incumplimiento y severidad de la pérdida | 🟢 Alta | 5 | 0 |
| `retenido` | modificador | retenido (fondos en retención) | 🟢 Alta | 5 | 0 |
| `ruta` | entidad | ruta (de archivo) | 🟢 Alta | 5 | 0 |
| `sub` | modificador | sub- | 🟡 Media | 5 | 0 |
| `sv` | entidad | sv — supervisión/servicio (abreviación — bdiaclaracion) | 🟡 Media | 5 | 0 |
| `temp` | modificador | temporal | 🟢 Alta | 5 | 0 |
| `adm` | acción | administración/administrar (abreviación de admin) | 🟢 Alta | 4 | 0 |
| `alerta` | entidad | Notificación de un evento que requiere atención o seguimiento (PLD, fraude, dictamen) | 🟢 Alta | 4 | 0 |
| `anio` | entidad | año | 🟢 Alta | 4 | 0 |
| `autenticacion` | entidad | autenticación | 🟢 Alta | 4 | 0 |
| `cadena` | entidad | cadena — string / cadena de texto (sp_split_cadena) | 🟢 Alta | 4 | 0 |
| `clabe` | entidad | CLABE interbancaria | 🟢 Alta | 4 | 0 |
| `codi` | regulatorio | CoDi — Cobro Digital (Banxico) | 🟢 Alta | 4 | 0 |
| `colonias` | entidad | colonias (catálogo domicilio) | 🟢 Alta | 4 | 0 |
| `corresponsal` | entidad | Corresponsal bancario: red de puntos de servicio (Coppel) que operan retiros y depósitos con comisión | 🟢 Alta | 4 | 0 |
| `dv` | entidad | dv — divisa (abreviación — bdisac) | 🟢 Alta | 4 | 0 |
| `ejecucion` | entidad | ejecución (de proceso) | 🟢 Alta | 4 | 0 |
| `ejecutivo` | entidad | Empleado de sucursal o promotoría que atiende clientes y solicitudes (validado en CNSIF) | 🟢 Alta | 4 | 0 |
| `grupo` | entidad | Segmento de clasificación del cliente por comportamiento o demografía, usado en scoring y reportes | 🟢 Alta | 4 | 0 |
| `hoy` | modificador | de hoy / fecha actual | 🟢 Alta | 4 | 0 |
| `liq` | entidad | liquidación (abreviación — sp_marcaliqpago, spei_recliquidacion) | 🟢 Alta | 4 | 0 |
| `maquila` | entidad | maquila — proceso de externalización de solicitudes TDC | 🟢 Alta | 4 | 0 |
| `modifica` | acción | Acción: actualiza datos, parámetros o catálogos ya existentes | 🟢 Alta | 4 | 0 |
| `nomina` | entidad | nómina | 🟢 Alta | 4 | 0 |
| `politica` | entidad | política de crédito | 🟢 Alta | 4 | 0 |
| `portab` | entidad | portabilidad — portabilidad de nómina (sp_generarchivoportab_*, sp_notif_cambios_portacec) | 🟢 Alta | 4 | 0 |
| `prestamos` | entidad | préstamos | 🟢 Alta | 4 | 0 |
| `principal` | entidad | principal — capital principal de deuda / titular principal de cuenta | 🟢 Alta | 4 | 0 |
| `retiros` | entidad | Conjunto de disposiciones de efectivo consultadas o parametrizadas por cuenta, canal o límite | 🟢 Alta | 4 | 0 |
| `tels` | entidad | teléfonos (plural) | 🟢 Alta | 4 | 0 |
| `valor` | entidad | Dato o importe puntual leído de parámetros, tramas XML o servicios; magnitud a aplicar en un cálculo | 🟢 Alta | 4 | 0 |
| `aclaracion` | entidad | aclaración bancaria — proceso de disputa o reclamación del cliente | 🟢 Alta | 3 | 0 |
| `activar` | acción | Acción: habilitar un producto, servicio, token o línea de crédito para su uso | 🟢 Alta | 3 | 0 |
| `activos` | modificador | Modificador: registros vigentes o habilitados (convenios, mensajes, productos) | 🟢 Alta | 3 | 0 |
| `apoderado` | entidad | Persona física facultada para operar en representación de una cuenta de persona moral | 🟢 Alta | 3 | 0 |
| `aval` | entidad | aval / garante | 🟢 Alta | 3 | 0 |
| `bandera` | modificador | bandera / flag (técnico) | 🟢 Alta | 3 | 0 |
| `batch` | modificador | proceso batch (por lotes) | 🟢 Alta | 3 | 0 |
| `beneficiario` | entidad | beneficiario (receptor del pago SPEI) | 🟢 Alta | 3 | 0 |
| `cedulacontable` | entidad | cédula contable | 🟢 Alta | 3 | 0 |
| `cita` | entidad | Agendamiento de trámite o atención en sucursal, con estatus y horario asignados | 🟢 Alta | 3 | 0 |
| `credisoluciones` | entidad | CrediSoluciones — producto/segmento de crédito BanCoppel (sp_carga_ctes_credisoluciones, sp_credisoluciones_crd — bdicred) | 🟢 Alta | 3 | 0 |
| `ctefisico` | entidad | Cliente Físico — persona física (tp_persona CHAR(2)); distingue de persona moral; maneja datos de identidad y afiliación (bdibpi+bdinteg:ctefisico, ctefisico_mib*) | 🟢 Alta | 3 | 0 |
| `cve` | entidad | clave (cve) | 🟢 Alta | 3 | 0 |
| `descripcion` | entidad | descripción | 🟢 Alta | 3 | 0 |
| `determina` | acción | Acción: calcular y fijar un valor de negocio, típicamente la línea de crédito de tarjeta o el valor UDI | 🟢 Alta | 3 | 0 |
| `direccion` | entidad | dirección | 🟢 Alta | 3 | 0 |
| `dispersion` | entidad | dispersión — dispersión de nómina (sp_dispercionnomina_bpi) | 🟢 Alta | 3 | 0 |
| `dormidas` | modificador | cuentas dormidas (inactivas) | 🟢 Alta | 3 | 0 |
| `ics` | entidad | ICS — sistema de cuotas/mensualidades de crédito (sp_ics_cuotas, sp_ics_compara_secuencias, sp_ics_genera_control — bdicred) | 🟢 Alta | 3 | 0 |
| `inactivas` | modificador | inactivas (art.61) | 🟢 Alta | 3 | 0 |
| `indicador` | entidad | indicador — marcador de estado o condición (sp_ambientar_indicador_*, sp_actualiza_indicadorcred) | 🟢 Alta | 3 | 0 |
| `local` | modificador | Modificador: ámbito acotado o localización geográfica; contrasta con procesamiento central | 🟢 Alta | 3 | 0 |
| `movs` | entidad | movimientos (abreviación) | 🟢 Alta | 3 | 0 |
| `nip` | entidad | NIP — Número de Identificación Personal (PIN bancario) | 🟢 Alta | 3 | 0 |
| `online` | entidad | online — transferencia en línea (sp_transfer_online_* — canal digital SPEI) | 🟢 Alta | 3 | 0 |
| `plazo` | entidad | plazo (depósito / crédito a plazo) | 🟢 Alta | 3 | 0 |
| `procede` | acción | Acción: validar la procedencia o viabilidad de una operación antes de ejecutarla (fusión, aclaración) | 🟢 Alta | 3 | 0 |
| `receptor` | entidad | Contraparte que recibe una transferencia electrónica de fondos (rol receptor en TEF) | 🟢 Alta | 3 | 0 |
| `region` | entidad | región | 🟢 Alta | 3 | 0 |
| `reinicia` | acción | reinicia / resetea | 🟢 Alta | 3 | 0 |
| `remesadora` | entidad | remesadora (envío de remesas) | 🟢 Alta | 3 | 0 |
| `rst` | entidad | rst — formato RST (sp_generararchivo_rst fan_in=345 — NO_VERIFICABLE) | 🟡 Media | 3 | 0 |
| `secuencia` | entidad | Contador consecutivo que genera folios o identificadores únicos | 🟢 Alta | 3 | 0 |
| `solin` | entidad | solicitud de crédito | 🟢 Alta | 3 | 0 |
| `ultimas` | modificador | últimas | 🟡 Media | 3 | 0 |
| `apellido` | entidad | Componente del nombre del cliente, validado contra RFC y usado en búsquedas e identificación | 🟢 Alta | 2 | 0 |
| `avatar` | entidad | avatar (foto de perfil del usuario en app) | 🟢 Alta | 2 | 0 |
| `beneficiarios` | entidad | Personas designadas para recibir los recursos de una cuenta o inversión por fallecimiento | 🟢 Alta | 2 | 0 |
| `bym3` | entidad | Billetes y Monedas (v3) | 🟢 Alta | 2 | 0 |
| `cant` | entidad | cantidad | 🟢 Alta | 2 | 0 |
| `cantidad` | entidad | Número de elementos o unidades contadas (registros, adicionales del crédito, campos) | 🟢 Alta | 2 | 0 |
| `concepto` | entidad | concepto de pago | 🟢 Alta | 2 | 0 |
| `consutacat` | acción | consulta catálogo [typo] | 🟢 Alta | 2 | 0 |
| `ctanvl2` | entidad | Cuenta Nivel 2 (CNBV Circular Única de Bancos) — categoría regulatoria de cuenta bancaria con KYC; valida documentos digitales y huellas (sp_ctanvl2_*, DoctosCtaNvl2/) | 🟢 Alta | 2 | 0 |
| `denominaciones` | entidad | Valores nominales de billetes y monedas para el conteo de efectivo en caja | 🟢 Alta | 2 | 0 |
| `desbloquea` | acción | desbloquea cuenta | 🟢 Alta | 2 | 0 |
| `digitalizar` | acción | digitaliza documento | 🟢 Alta | 2 | 0 |
| `divisa` | entidad | Moneda extranjera y su cotización para operaciones cambiarias | 🟢 Alta | 2 | 0 |
| `docto` | entidad | documento | 🟢 Alta | 2 | 0 |
| `documento` | entidad | Comprobante individual del expediente del cliente o anexado a una aclaración/bitácora | 🟢 Alta | 2 | 0 |
| `empresas` | entidad | empresas (nómina empresarial) | 🟢 Alta | 2 | 0 |
| `estadisticas` | entidad | estadísticas | 🟢 Alta | 2 | 0 |
| `factura` | entidad | Comprobante de facturación asociado a la originación de solicitudes y al devengo de intereses del crédito | 🟢 Alta | 2 | 0 |
| `fn` | prefijo | función SQL | 🟢 Alta | 2 | 0 |
| `garantia` | entidad | garantía | 🟢 Alta | 2 | 0 |
| `generafechpagoreestructura` | acción | genera fecha de pago de reestructura | 🟢 Alta | 2 | 0 |
| `medioacceso` | entidad | medio de acceso | 🟢 Alta | 2 | 0 |
| `mesa` | entidad | Mesa de Control — equipo de revisión y autorización de solicitudes de crédito; status codes MC/CM; valida comprobantes de ingreso; comentario explícito en código | 🟢 Alta | 2 | 0 |
| `pasa` | acción | pasa / mueve (verbo — pasamovshist* — archiva movimientos a histórico) | 🟢 Alta | 2 | 0 |
| `pase` | acción | pase contable (registra/traslada a póliza o mayor) | 🟢 Alta | 2 | 0 |
| `periodicidad` | modificador | Modificador: frecuencia con que se repite un cargo o proceso | 🟢 Alta | 2 | 0 |
| `portabilidad` | entidad | portabilidad (de nómina o número) | 🟢 Alta | 2 | 0 |
| `presenta` | acción | Acción: enviar documentos a compensación o cobro ante la cámara (cheques, domiciliaciones a CCE) | 🟢 Alta | 2 | 0 |
| `regex` | entidad | regex — motor de expresiones regulares Informix SPL (infraestructura bdinteg — 8 SPs ~34MB EXCLUIR de análisis) | 🟢 Alta | 2 | 0 |
| `split` | acción | split — divide/parsea cadena (sp_split_cadena fan_in=857 — #2 SP bdicnweb) | 🟢 Alta | 2 | 0 |
| `transacc` | entidad | código de transacción | 🟢 Alta | 2 | 0 |
| `transportadora` | entidad | transportadora de valores (traslado de efectivo) | 🟢 Alta | 2 | 0 |
| `agendadas` | modificador | Modificador: citas o transacciones programadas con fecha y hora previamente reservadas | 🟢 Alta | 1 | 0 |
| `arr` | entidad | ARR — producto de ahorro/inversión recurrente (CLABE, interés acumulado, inversión creciente, pago de interés — bdicheq:arr_*) | 🟢 Alta | 1 | 0 |
| `bym2` | entidad | Billetes y Monedas (v2) | 🟢 Alta | 1 | 0 |
| `citas` | entidad | Conjunto de agendamientos de trámite o atención en sucursal consultados por cliente | 🟢 Alta | 1 | 0 |
| `ciudad` | entidad | Nivel geográfico del domicilio, catalogado y conciliado contra SEPOMEX para validar direcciones | 🟢 Alta | 1 | 0 |
| `clic` | entidad | BanCoppel Clic (tarjeta digital instantánea) | 🟢 Alta | 1 | 0 |
| `codigos` | entidad | códigos | 🟢 Alta | 1 | 0 |
| `colonia` | entidad | colonia — colonia postal para validación de domicilio (sp_consultacoloniascp fan_in=281) | 🟢 Alta | 1 | 0 |
| `depuracion` | acción | depuración | 🟢 Alta | 1 | 0 |
| `divisas` | entidad | Monedas extranjeras y su cotización para operaciones cambiarias (Billetes y Monedas) | 🟢 Alta | 1 | 0 |
| `division` | entidad | división | 🟢 Alta | 1 | 0 |
| `emisor` | entidad | Institución emisora de la tarjeta identificada por su BIN; contraparte en operaciones de tarjeta | 🟢 Alta | 1 | 0 |
| `empresa` | entidad | empresa (entidad bancaria) | 🟢 Alta | 1 | 0 |
| `etiqueta` | entidad | Nodo o campo (tag) de un mensaje XML que se arma o del que se extrae valor | 🟢 Alta | 1 | 0 |
| `extemporanea` | modificador | extemporánea | 🟢 Alta | 1 | 0 |
| `fallecimiento` | modificador | por fallecimiento | 🟢 Alta | 1 | 0 |
| `fisica` | modificador | persona física | 🟢 Alta | 1 | 0 |
| `frecpago` | entidad | frecuencia de pago | 🟢 Alta | 1 | 0 |
| `hipoteca` | entidad | crédito hipotecario (digital, desde 2025) | 🟢 Alta | 1 | 0 |
| `importe` | entidad | Cantidad monetaria de una operación | 🟢 Alta | 1 | 0 |
| `intercambio` | entidad | intercambio (interbancario) | 🟢 Alta | 1 | 0 |
| `libro` | entidad | libro mayor / libro contable — general ledger (libromayor_diarios, libromayor_historicos) | 🟢 Alta | 1 | 0 |
| `mnsj` | prefijo | mensajería / notificaciones (dominio bdimnsj) | 🟢 Alta | 1 | 0 |
| `mover` | acción | mueve / archiva (operación de paso a histórico) | 🟢 Alta | 1 | 0 |
| `mueve` | acción | mueve / traslada (verbo complemento de mover) | 🟢 Alta | 1 | 0 |
| `nacionalidad` | entidad | País de origen del cliente, catalogado para requisitos KYC y clasificación FATCA | 🟢 Alta | 1 | 0 |
| `numsolicitud` | entidad | número de solicitud | 🟢 Alta | 1 | 0 |
| `plantilla` | entidad | Formato precargado reutilizable, típicamente de nómina y empleados, para agilizar altas y dispersiones en BPI | 🟢 Alta | 1 | 0 |
| `preventivo` | modificador | Modificador: acción anticipada para evitar un riesgo (ej. cierre preventivo de cuenta) | 🟢 Alta | 1 | 0 |
| `rastreo` | entidad | rastreo (SPEI) | 🟢 Alta | 1 | 0 |
| `resultado` | entidad | Desenlace de una gestión o proceso registrado y catalogado (cobranza, fin de ejercicio, validación SAT) | 🟢 Alta | 1 | 0 |
| `sdodisp` | entidad | saldo disponible | 🟢 Alta | 1 | 0 |
| `situaciones` | entidad | situaciones de cuenta | 🟢 Alta | 1 | 0 |
| `tbl` | entidad | tbl — tabla (abreviación — sp_depura_tbl_registro_msj) | 🟢 Alta | 1 | 0 |
| `telefonico` | modificador | telefónico | 🟢 Alta | 1 | 0 |
| `titular` | entidad | titular de cuenta | 🟢 Alta | 1 | 0 |
| `visual` | modificador | Modificador: revisión por inspección directa (ej. cotejo visual de firmas en cheques) | 🟢 Alta | 1 | 0 |
| `6dig` | modificador | OTP/token de 6 dígitos — autenticación fuerte SMS | 🟢 Alta | 0 | 0 |
| `acuerdo` | entidad | acuerdo de pago — convenio de cobranza con el cliente (sp_grabacompromisosacuerdos) | 🟢 Alta | 0 | 0 |
| `asiento` | entidad | asiento contable | 🟢 Alta | 0 | 0 |
| `auditoria` | entidad | auditoría | 🟢 Alta | 0 | 0 |
| `aumento` | modificador | Modificador: incremento de un valor, típicamente de la línea de crédito autorizada al cliente | 🟢 Alta | 0 | 0 |
| `auxiliar` | entidad | auxiliar contable — sub-ledger contable (sdos_auxiliar, sp_validaauxiliar) | 🟢 Alta | 0 | 0 |
| `balanza` | entidad | balanza de comprobación — trial balance (sp_generarbalanza* — bdicont) | 🟢 Alta | 0 | 0 |
| `biometrico` | entidad | biométrico | 🟢 Alta | 0 | 0 |
| `boveda` | entidad | bóveda | 🟢 Alta | 0 | 0 |
| `calif` | entidad | calificación | 🟢 Alta | 0 | 0 |
| `cfdi` | regulatorio | CFDI — Comprobante Fiscal Digital por Internet (SAT · factura electrónica) | 🟢 Alta | 0 | 0 |
| `circulo` | entidad | Círculo de Crédito — buró de crédito para personas físicas (México) | 🟢 Alta | 0 | 0 |
| `ckpt` | modificador | checkpoint — evento de checkpointing del motor Informix | 🟢 Alta | 0 | 0 |
| `cnc` | entidad | CNC — sistema de configuración de planes fijos de Tarjetas Coppel (plazos_fijos, Buen Fin, carga de archivos, stat06 — bditarjeta:sp_cnc_*) | 🟢 Alta | 0 | 0 |
| `coas` | entidad | COAS — Confirmación de Operación y Acuse de Recibo Simplificado (mensaje de protocolo SPEI / Banxico) | 🟢 Alta | 0 | 0 |
| `codificacion` | entidad | codificación | 🟢 Alta | 0 | 0 |
| `comercio` | entidad | comercio afiliado | 🟢 Alta | 0 | 0 |
| `concentradora` | entidad | cuenta concentradora | 🟢 Alta | 0 | 0 |
| `conyuge` | entidad | cónyuge (solicitud crédito) | 🟢 Alta | 0 | 0 |
| `corrige` | acción | corrige — acción de corrección de datos (bdicred:sp_corrige_*) | 🟢 Alta | 0 | 0 |
| `denominacion` | entidad | denominación (valor facial del billete/moneda) | 🟢 Alta | 0 | 0 |
| `destino` | entidad | Cuenta, banco o plaza receptora de una operación, contraparte del origen en una transferencia | 🟢 Alta | 0 | 0 |
| `disper` | entidad | disper — dispersión (abreviación — sp_dispercionnomina_*) | 🟢 Alta | 0 | 0 |
| `efectiva` | entidad | Cuenta Efectiva Digital (débito BanCoppel) | 🟢 Alta | 0 | 0 |
| `empresarial` | entidad | empresarial (nómina) | 🟢 Alta | 0 | 0 |
| `factelect` | entidad | Factura Electrónica / CFDI | 🟢 Alta | 0 | 0 |
| `fechafin` | entidad | fecha fin | 🟢 Alta | 0 | 0 |
| `fechafinal` | entidad | fecha final | 🟢 Alta | 0 | 0 |
| `fisicas` | modificador | personas físicas | 🟢 Alta | 0 | 0 |
| `folsuc` | entidad | folio de sucursal | 🟢 Alta | 0 | 0 |
| `forzada` | modificador | Modificador: transacción aplicada sin autorización en línea, forzando su procesamiento | 🟢 Alta | 0 | 0 |
| `ftc` | entidad | FTC — módulo de configuración de transferencia de archivos (SFTP/FTP IPs, passwords de proxy, SFTP depósito — bdilide:sp_ftc_*) | 🟢 Alta | 0 | 0 |
| `fus2` | ambiguo | fusión v2 | 🔴 Ambigua | 0 | 0 |
| `generaredoctaeje` | acción | Genera Estado de Cuenta Ejecutivo — proceso de generación de EdoCta para cheques/captación; incluye variante con CFDI (bdicheq:sp_generaredoctaeje, sp_generaredoctaeje_factelect) | 🟢 Alta | 0 | 0 |
| `hipotecario` | entidad | crédito hipotecario | 🟢 Alta | 0 | 0 |
| `idfuncion` | entidad | id de funcionalidad | 🟢 Alta | 0 | 0 |
| `idfuncionc` | entidad | id de funcionalidad | 🟢 Alta | 0 | 0 |
| `impuesto` | regulatorio | impuesto (SAT) | 🟢 Alta | 0 | 0 |
| `inactiv` | modificador | inactiva | 🟢 Alta | 0 | 0 |
| `inicia` | acción | Acción: arrancar un proceso, sesión o secuencia; también reiniciar secuencias y folios | 🟢 Alta | 0 | 0 |
| `inicial` | modificador | Modificador: correspondiente al arranque de un proceso o periodo (carga inicial, saldo inicial) | 🟢 Alta | 0 | 0 |
| `inicializa` | acción | Acción: poner en estado base tablas, saldos o acumuladores al comienzo de un periodo o corrida | 🟢 Alta | 0 | 0 |
| `inmediato` | modificador | Modificador: aplicación en tiempo real, sin diferimiento (ej. abono inmediato) | 🟢 Alta | 0 | 0 |
| `innovattia` | entidad | Innovattia — proveedor externo de notificaciones SMS/email para BanCoppel | 🟢 Alta | 0 | 0 |
| `intereses` | entidad | Rédito devengado o provisionado sobre saldos y créditos según tasa y días transcurridos | 🟢 Alta | 0 | 0 |
| `invalido` | modificador | inválido — dato o estado no válido | 🟢 Alta | 0 | 0 |
| `ivasart61` | regulatorio | IVA sobre operaciones del Art. 61 LIC (alcance fiscal por confirmar con el SME) | 🔴 Ambigua | 0 | 0 |
| `manco` | entidad | Mancomunidad — cuenta u operación con múltiples titulares autorizados; requiere autorización de todos (bdibei:sp_*_manco_bei; DESCRIPCION: 'Actualiza Status Mancomunidad') | 🟢 Alta | 0 | 0 |
| `mesas` | entidad | Mesas de Control — equipo de revisión y autorización de solicitudes de crédito (plural de Mesa de Control) | 🟢 Alta | 0 | 0 |
| `mnsjr` | prefijo | mensajería registrada / tabla de transacciones de mensajería | 🟢 Alta | 0 | 0 |
| `monitoreo` | entidad | monitoreo — proceso de vigilancia/seguimiento operativo | 🟢 Alta | 0 | 0 |
| `notifi` | acción | notifica | 🟢 Alta | 0 | 0 |
| `numcredito` | entidad | número de crédito | 🟢 Alta | 0 | 0 |
| `opcion` | entidad | opción | 🟢 Alta | 0 | 0 |
| `ordenante` | entidad | ordenante (pagador que emite la orden SPEI) | 🟢 Alta | 0 | 0 |
| `ordenes` | entidad | órdenes | 🟢 Alta | 0 | 0 |
| `oxo` | entidad | OXXO (abreviación — spei_entordenespago_oxo) | 🟢 Alta | 0 | 0 |
| `oxxo` | entidad | OXXO (red de depósito/retiro) | 🟢 Alta | 0 | 0 |
| `parentesco` | entidad | parentesco (referencia) | 🟢 Alta | 0 | 0 |
| `pieza` | entidad | pieza de efectivo (billete/moneda) | 🟢 Alta | 0 | 0 |
| `pin` | entidad | PIN dinámico (tarjeta digital) | 🟢 Alta | 0 | 0 |
| `pld` | regulatorio | PLD — Prevención de Lavado de Dinero (AML) | 🟢 Alta | 0 | 0 |
| `presentacion` | entidad | presentación | 🟢 Alta | 0 | 0 |
| `proac` | entidad | PROAC — producto de cuenta de ahorro con inscripción y ciclo anual (sp_proac_consultarincripcioncuentaproac, sp_proac_calc_proximoanio — bdicheq) | 🟢 Alta | 0 | 0 |
| `promocion` | entidad | promoción | 🟢 Alta | 0 | 0 |
| `propuesta` | entidad | Oferta u ofrecimiento generado al cliente, típicamente de crédito o producto, sujeto a aceptación | 🟢 Alta | 0 | 0 |
| `recompensa` | entidad | recompensa / cashback (Coppel Max) | 🟡 Media | 0 | 0 |
| `reevaluacion` | acción | reevaluación de crédito | 🟢 Alta | 0 | 0 |
| `reinicio` | acción | Acción: reiniciar un contador, secuencia o proceso a su estado inicial para una nueva corrida | 🟢 Alta | 0 | 0 |
| `remanente` | modificador | Modificador: saldo o importe residual pendiente tras un pago o proceso | 🟢 Alta | 0 | 0 |
| `stat06` | entidad | Stat06 — tipo/código de archivo de carga en procesamiento de tarjetas Coppel (bditarjeta:sp_cnc_cga_stat06; parámetros: ruta, nombre archivo, sistema, layout) | 🟢 Alta | 0 | 0 |
| `susc` | entidad | suscriptor / suscripción (alertas SMS/email — tablas mnsjr_suscriptores) | 🟢 Alta | 0 | 0 |
| `suscriptores` | acción | gestiona suscriptores | 🟢 Alta | 0 | 0 |
| `synmotor` | entidad | SynMotor — motor de procesamiento de Syndein (empresa externa fintech); gestiona campos, parámetros y WSDL (intercard:sp_synmotor_*) | 🟢 Alta | 0 | 0 |
| `tdd` | entidad | TDD — Tarjeta de Débito | 🟢 Alta | 0 | 0 |
| `tienda` | entidad | tienda Coppel — punto de venta físico / sucursal de tienda | 🟢 Alta | 0 | 0 |
| `tiir` | entidad | Tasa de Interés Interna de Retorno (IRR del crédito — base del cálculo CAT; bdicred:sp_calculo_tiir bisección iterativa VPN=0; confirmado SME 2026-08-08) | 🟢 Alta | 0 | 0 |
| `titulo` | entidad | título | 🟢 Alta | 0 | 0 |
| `venio` | entidad | convenio | 🟢 Alta | 0 | 0 |

---

## B · Términos compuestos

Términos lexicalizados que se descomponen en átomos conocidos.

| Compuesto | Descomposición | Significado | Confiab. | frec-nom | frec-par |
|---|---|---|---|--:|--:|
| `genrep` | gen + rep | genera reporte (abreviación genrep) | 🟡 Media | 18 | 0 |
| `burofisicas` | buro + fisicas | Buró Personas Físicas — consulta al Buró de Crédito para personas físicas (bdiburo:burofisicas_cnr, burofisicas_clon, burofisicas_concilia_clon) | 🟢 Alta | 15 | 0 |
| `regordenctecte` | reg + orden + cte + cte | Regresa Orden Cuenta a Cuenta — operación de transferencia/orden entre cuentas propias del cliente (bdicheq:sp_regordenctecte, sp_regordenctecte_bex, sp_regordenctecte_web, sp_regordenctecte_pp) | 🟡 Media | 10 | 0 |
| `aplicaordenpago` | aplica + ordenpago | aplica orden de pago | 🟢 Alta | 8 | 0 |
| `edocta` | edo + cta | Estado de Cuenta — documento periódico de movimientos y saldos; generado como PDF (sp_ctanvl2_generapdf_pba) y enviado por email automático (bdinteg) | 🟢 Alta | 7 | 0 |
| `cobro` | cob + ro | Acción: aplicación de un cargo por comisión, interés o servicio, a menudo automático sobre saldo | 🟢 Alta | 6 | 0 |
| `activa` | act + iva | Acción: habilitar o poner en operación un elemento; también atributo de estatus vigente (cuenta/mensaje activo) | 🟢 Alta | 4 | 0 |
| `consprodcte` | cons + prod + cte | consulta producto de cliente | 🟢 Alta | 4 | 0 |
| `recordenpago` | rec + ordenpago | recibe orden de pago | 🟢 Alta | 4 | 0 |
| `convenio` | con + venio | convenio (nómina/empresarial) | 🟢 Alta | 3 | 0 |
| `catdenominacion` | cat + denominacion | catálogo de denominaciones | 🟢 Alta | 2 | 0 |
| `edoctacrd` | edocta + crd | Estado de Cuenta Crédito — documento de movimientos y saldos de crédito; carga de movhis y gestión de aclaraciones (bdicred:carga_movhis_edoctacrd, aclaraciones_edoctacrd_sif) | 🟢 Alta | 2 | 0 |
| `reccancelacion` | rec + cancelacion | recibe cancelación | 🟢 Alta | 2 | 0 |
| `subproducto` | sub + producto | sub-producto | 🟢 Alta | 2 | 0 |
| `abonoinmediato` | abono + inmediato | abono inmediato | 🟢 Alta | 1 | 0 |
| `ctaclabe` | cta + clabe | cuenta CLABE | 🟢 Alta | 1 | 0 |
| `datosdia` | datos + dia | datos del día | 🟢 Alta | 1 | 0 |
| `generafolionomina` | genera + folionomina | genera folio de nómina | 🟢 Alta | 1 | 0 |
| `movhis` | mov + his | Movimientos Históricos — tabla/proceso de historial de movimientos (bdicheq:arrmovhis, borra_movhis; bdicred:carga_movhis_edoctacrd) | 🟢 Alta | 1 | 0 |
| `numcte` | num + cte | número de cliente | 🟢 Alta | 1 | 0 |
| `numsol` | num + sol | número de solicitud | 🟢 Alta | 1 | 0 |
| `pasecont` | pase + cont | realiza el pase contable (registro a póliza/mayor) | 🟢 Alta | 1 | 0 |
| `recdevolucion` | rec + devolucion | recibe devolución | 🟢 Alta | 1 | 0 |
| `recextemporanea` | rec + extemporanea | recibe orden extemporánea | 🟢 Alta | 1 | 0 |
| `tpcalculo` | tp + calculo | tipo de cálculo | 🟢 Alta | 1 | 0 |
| `admtoken` | adm + token | AdmToken — módulo de administración de tokens de autenticación para personas morales (empresas) en BEI; gestiona solicitudes, estados, devoluciones y comentarios (bdibei:sp_*_admtoken_bei) | 🟢 Alta | 0 | 0 |
| `archsdos` | arch + sdos | Archivos de Saldos — comentario explícito: 'Genera archivos de saldos diarios y mensuales' (bdicheq:gen_archsdos) | 🟢 Alta | 0 | 0 |
| `cargamanual` | carga + manual | carga manual | 🟢 Alta | 0 | 0 |
| `cargamovimiento` | carga + movimiento | carga movimiento | 🟢 Alta | 0 | 0 |
| `cilocconsulta` | ciloc + consulta | consulta local (cobranza) | 🟢 Alta | 0 | 0 |
| `claverastreo` | clave + rastreo | clave de rastreo SPEI (hasta 30 posiciones alfanuméricas, Banxico) | 🟢 Alta | 0 | 0 |
| `conciliachq` | concilia + chq | conciliación de cheques | 🟡 Media | 0 | 0 |
| `confirmasms` | confirma + sms | confirma vía SMS (2FA) | 🟢 Alta | 0 | 0 |
| `conscedulas` | cons + cedulas | consulta cédulas | 🟢 Alta | 0 | 0 |
| `consreporte` | cons + reporte | consulta reporte | 🟢 Alta | 0 | 0 |
| `conssaldosdiarios` | cons + saldos + diarios | consulta saldos diarios | 🟢 Alta | 0 | 0 |
| `ctasinactivas` | ctas + inactivas | cuentas inactivas | 🟢 Alta | 0 | 0 |
| `devforzada` | dev + forzada | devolución forzada | 🟢 Alta | 0 | 0 |
| `estatussolic` | estatus + solic | estatus de solicitud | 🟢 Alta | 0 | 0 |
| `fechaconsulta` | fecha + consulta | fecha de consulta | 🟢 Alta | 0 | 0 |
| `fechainicial` | fecha + inicial | fecha inicial | 🟢 Alta | 0 | 0 |
| `fechainicio` | fecha + inicio | fecha inicio | 🟢 Alta | 0 | 0 |
| `folionomina` | folio + nomina | folio de nómina | 🟢 Alta | 0 | 0 |
| `monitorsol` | monitor + sol | Monitor de Solicitudes — sistema de monitoreo de solicitudes de crédito por sucursal/empresa; parámetros: empresa, sucursal, status_solicitud, num_producto (bdicred+bdisolic:envia_monitorsol) | 🟢 Alta | 0 | 0 |
| `nombreref` | nombre + ref | nombre de referencia | 🟢 Alta | 0 | 0 |
| `numcred` | num + cred | número de crédito | 🟢 Alta | 0 | 0 |
| `numcuenta` | num + cuenta | número de cuenta | 🟢 Alta | 0 | 0 |
| `numempleado` | num + empleado | número de empleado | 🟢 Alta | 0 | 0 |
| `numproducto` | num + producto | número de producto | 🟢 Alta | 0 | 0 |
| `numsucursal` | num + sucursal | número de sucursal | 🟢 Alta | 0 | 0 |
| `numtarjeta` | num + tarjeta | número de tarjeta | 🟢 Alta | 0 | 0 |
| `ordenpago` | orden + pago | orden de pago | 🟢 Alta | 0 | 0 |
| `pasecheq` | pase + cheq | pase de cheque (a compensación/conciliación) | 🟢 Alta | 0 | 0 |
| `productotransaccion` | producto + transaccion | producto-transacción | 🟢 Alta | 0 | 0 |
| `repipab` | rep + ipab | Reporte IPAB — reporte regulatorio de seguimiento de depósitos (bdibei:sp_repipab_*) | 🟢 Alta | 0 | 0 |

---

## C · Candidatos sin clasificar (fragmentos frecuentes)

Fragmentos que el segmentador no reconoce y aparecen ≥ 4 veces. Son los **próximos términos a clasificar con el SME** — cada uno agregado a `sp_vocab.py` sube la cobertura de todos los SPs que lo contienen.

| Fragmento | Frecuencia | Hipótesis (por confirmar) |
|---|--:|---|
| `status` | 129 | — |
| `statu` | 39 | — |
| `orte` | 32 | — |
| `tot` | 18 | — |
| `das` | 15 | — |
| `pei` | 13 | — |
| `can` | 12 | — |
| `lica` | 12 | — |
| `bit` | 11 | — |
| `cla` | 11 | — |
| `limite` | 10 | — |
| `ret` | 9 | — |
| `jlh` | 9 | — |
| `uelt` | 9 | — |
| `pendientes` | 9 | — |
| `ald` | 9 | — |
| `quebr` | 9 | — |
| `asig` | 9 | — |
| `aper` | 9 | — |
| `ecial` | 9 | — |
| `val` | 8 | — |
| `tra` | 8 | — |
| `mod` | 8 | — |
| `dmi` | 8 | — |
| `lista` | 8 | — |
| `car` | 7 | — |
| `pre` | 7 | — |
| `ras` | 7 | — |
| `cli` | 7 | — |
| `lemento` | 7 | — |
| `ortes` | 7 | — |
| `pecto` | 7 | — |
| `melb` | 7 | — |
| `trar` | 7 | — |
| `ate` | 7 | — |
| `emanal` | 7 | — |
| `redito` | 7 | — |
| `rcifra` | 7 | — |
| `gra` | 7 | — |
| `ert` | 7 | — |
| `sin` | 6 | — |
| `funcional` | 6 | — |
| `cort` | 6 | — |
| `vent` | 6 | — |
| `matica` | 6 | — |
| `net` | 6 | — |
| `red` | 6 | — |
| `blq` | 6 | — |
| `tad` | 6 | — |
| `dor` | 6 | — |
| `arque` | 6 | — |
| `listasnegat` | 6 | — |
| `ara` | 6 | — |
| `sup` | 6 | — |
| `bus` | 6 | — |
| `img` | 6 | — |
| `tri` | 6 | — |
| `ticket` | 6 | — |
| `mento` | 6 | — |
| `base` | 6 | — |

---

## D · Resumen de confiabilidad

| Nivel | Términos | % |
|---|--:|--:|
| 🟢 Alta | 676 | 97% |
| 🟡 Media | 10 | 1% |
| 🔴 Ambigua | 4 | 0% |
| **Total clasificado** | **690** | |
| ⚪ Candidatos pendientes | 60 | |

*Generado por Specialist — Informix SPL Analysis · Etapa 3 · fuente: callgraph-data.json + source/ + sp_vocab.py*
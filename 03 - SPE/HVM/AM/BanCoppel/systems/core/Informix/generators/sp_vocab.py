#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
sp_vocab.py — Vocabulario y composición de objetivos de negocio a partir de
nombres de Stored Procedures Informix SPL (BanCoppel Informix).

Fuente ÚNICA de verdad del catálogo de términos. Importado por:
  - extract-journeys.py  (campo "biz" del journeys-data.json)
  - build-catalog.py     (journeys-catalog-bcop.md)

Método: cada nombre de SP se descompone en prefijo + acción + entidad +
modificador; el objetivo se compone concatenando los significados.
Estado por término: conf (confirmado) · inf (inferido) · gap (ambiguo, requiere validación del SME).

Etapa 3 — Business Logic Extraction · Specialist Informix SPL · SPE-AM-001
"""

# token -> (categoria, significado, estado)
# categorias: PREFIJO · ACCION · ENTIDAD · MODIF · REG · AMBIGUO
CAT = {
 # ── PREFIJOS / FAMILIA ──
 "sp":("PREFIJO","stored procedure","conf"),"fn":("PREFIJO","función SQL","conf"),
 "spei": ("PREFIJO", "familia SPEI — pagos interbancarios certificados Banxico; sp_cons_spei_aud (bdinteg, fi=122) audita transacciones por rango de fecha devolviendo folio+monto+referencia con paginación (skip/límite); bdispei contiene recepción de errores CoDi y devoluciones", "conf"),
 "cont":("PREFIJO","familia contabilidad","conf"),"cam":("PREFIJO","cámara / captura contable","conf"),
 "fal":("PREFIJO","faltantes / documentación de expediente","inf"),
 "acl":("PREFIJO","familia aclaraciones","conf"),"ciloc":("PREFIJO","consulta local de cobranza","conf"),
 "cnsif":("PREFIJO","Consulta SIF (Sistema de Información Financiero) — confirmado SPE 2026-08-08; tablas si_seg_* en bdinteg","conf"),"cac":("PREFIJO","familia crédito (CAC)","conf"),
 "mon":("PREFIJO","monitor / módulo","conf"),"dicta": ("ENTIDAD", "subsistema de dictaminación antifraude en bdinteg (sp_dicta_*, fi≥270); gestiona veredictos de comparación biométrica en si_bitacora_comparaciones y alertas activas en si_bitacora_alerta_tmp; el analista_fraudes asigna status_alerta tras revisar la huella", "conf"),
 # abreviaturas de dominio (prefijos de BD) — añadidas 2026-07-11 en grounding pass D09
 "mnsj":("PREFIJO","mensajería / notificaciones (dominio bdimnsj)","conf"),
 "mnsjr":("PREFIJO","mensajería registrada / tabla de transacciones de mensajería","conf"),
 "susc":("ENTIDAD","suscriptor / suscripción (alertas SMS/email — tablas mnsjr_suscriptores)","conf"),
 "chi":("PREFIJO","CHI — integración con Buró de Crédito (Credit History Interface)","conf"),
 # términos descubiertos en grounding pass D01+D02 (bdicnweb+bdinteg) 2026-07-11
 "split":       ("ACCION", "split — divide/parsea cadena (sp_split_cadena fan_in=857 — #2 SP bdicnweb)","conf"),
 "cadena":      ("ENTIDAD","cadena — string / cadena de texto (sp_split_cadena)","conf"),
 "reporte":     ("ENTIDAD","Salida estructurada de datos para consumo regulatorio, operativo o de negocio (ej. sp_reporte_usuarios_amov)","conf"),
 "cg":          ("ENTIDAD","cg — Canal/Cuenta General (subsistema sp_cg_* — bdicnweb)","conf"),
 "sw":          ("ENTIDAD","sw — SoftWare/Switch (subsistema sp_sw_ro_* — bdicnweb)","conf"),
 "ro":          ("ENTIDAD","Oficios y requerimientos judiciales: búsqueda de personas, expedientes e imágenes certificadas atendidos bajo oficio (subsistema sw_ro_*)","conf"),
 "fc":          ("ENTIDAD","fc — Fuentes Combinadas (subsistema sp_fc_*; biométricos — bdicnweb)","conf"),
 "cc":          ("ENTIDAD","Cuenta corriente/concentradora: administración de sucursales, plazas y CLABE de la cuenta","conf"),
 "masivo":      ("ENTIDAD","Modificador: procesamiento por lote de múltiples registros en una sola corrida","inf"),
 "apoderado":   ("ENTIDAD","Persona física facultada para operar en representación de una cuenta de persona moral","conf"),
 "rst":         ("ENTIDAD","rst — formato RST (sp_generararchivo_rst fan_in=345 — NO_VERIFICABLE)","inf"),
 "atms":        ("ENTIDAD","atms — ATM / cajero automático (sp_atms_* — bdicnweb)","conf"),
 "cnsif":       ("ENTIDAD","SIF — Sistema de Información Financiero (sp_cnsif_confirmaejecutivo fan_in=2400 — #1 SP Informix; tablas si_seg_usuarios_funciones; confirmado SPE 2026-08-08)","conf"),
 "tiir":        ("ENTIDAD","Tasa de Interés Interna de Retorno (IRR del crédito — base del cálculo CAT; bdicred:sp_calculo_tiir bisección iterativa VPN=0; confirmado SME 2026-08-08)","conf"),
 "dicta": ("ENTIDAD", "subsistema de dictaminación antifraude en bdinteg (sp_dicta_*, fi≥270); gestiona veredictos de comparación biométrica en si_bitacora_comparaciones y alertas activas en si_bitacora_alerta_tmp; el analista_fraudes asigna status_alerta tras revisar la huella", "conf"),
 "colonia":     ("ENTIDAD","colonia — colonia postal para validación de domicilio (sp_consultacoloniascp fan_in=281)","conf"),
 "cp":          ("ENTIDAD","cp — código postal (sp_consultacoloniascp — bdinteg)","conf"),
 "regex":       ("ENTIDAD","regex — motor de expresiones regulares Informix SPL (infraestructura bdinteg — 8 SPs ~34MB EXCLUIR de análisis)","conf"),
 # términos descubiertos en grounding pass D04 (bdicheq) 2026-07-11
 "cargo":       ("ACCION", "cargo — débito / cargo a cuenta (cargo_ref fan_in=561 — #1 SP del sistema)","conf"),
 "abono":       ("ACCION", "abono — crédito / abono a cuenta (abono_ref fan_in=520 — #2 SP del sistema)","conf"),
 "reversion":   ("ACCION", "reversión de transacción (reversion fan_in=377 — bdicheq)","conf"),
 "bloqueo":     ("ACCION", "bloqueo de cuenta (bloqueo_cta fan_in=184)","conf"),
 "nomina":      ("ENTIDAD","nómina — pago de salarios (sp_generafolionomina fan_in=253 — portabilidad Banxico)","conf"),
 "folio":       ("ENTIDAD","Identificador consecutivo único de una operación, solicitud o aclaración para su rastreo","conf"),
 "clabe":       ("ENTIDAD","CLABE — Clave Bancaria Estandarizada (18 dígitos — Banxico — digverclabe)","conf"),
 "portab":      ("ENTIDAD","portabilidad — portabilidad de nómina (sp_generarchivoportab_*, sp_notif_cambios_portacec)","conf"),
 "pasa":        ("ACCION", "pasa / mueve (verbo — pasamovshist* — archiva movimientos a histórico)","conf"),
 "borra":       ("ACCION", "borra / elimina registros (borramovs_movhis, borramovscfd*)","conf"),
 "inv":         ("ENTIDAD","inv — inversión (abreviación — calsdoinvcrec, cierrechqinvcrec)","conf"),
 "dispersion":  ("ENTIDAD","dispersión — dispersión de nómina (sp_dispercionnomina_bpi)","conf"),
 "disper":      ("ENTIDAD","disper — dispersión (abreviación — sp_dispercionnomina_*)","conf"),
 "online":      ("ENTIDAD","online — transferencia en línea (sp_transfer_online_* — canal digital SPEI)","conf"),
 # términos descubiertos en grounding pass D05+D07+D10 (bdisac+bdiaclaracion+bdisuc) 2026-07-11
 "wu":          ("ENTIDAD","Western Union — servicio de remesas/transferencias internacionales (bdisac)","conf"),
 "bts":         ("ENTIDAD","BTS — sistema de beneficiarios/servicios SAC (sp_validabts, sp_consinfobtssif)","inf"),
 "sif":         ("ENTIDAD","SIF — Sistema de Información Financiero (sp_consinfobtssif — bdisac; sp_cnsif_* — bdinteg)","conf"),
 "dv":          ("ENTIDAD","dv — divisa (abreviación — bdisac)","conf"),
 "gdf":         ("ENTIDAD","Gobierno de la CDMX: convenio de pago de impuestos y servicios (predial, agua, tenencia, licencias, derechos) — confirmado por código bdisac","conf"),
 "sac":         ("ENTIDAD","SAC — Servicio de Atención al Cliente (prefijo sp_sac_* — bdisac)","conf"),
 "fal":         ("ENTIDAD","fal — fallo/disputa (prefijo sp_fal_* — aclaraciones bancarias — bdiaclaracion)","conf"),
 "aclaracion":  ("ENTIDAD","aclaración bancaria — proceso de disputa o reclamación del cliente","conf"),
 "sv":          ("ENTIDAD","sv — supervisión/servicio (abreviación — bdiaclaracion)","inf"),
 "bym":         ("ENTIDAD","BYM — Bienes y Mercancías (sistema de inventario sucursal — sp_*_bym* — bdisuc)","conf"),
 "piezas":      ("ENTIDAD","piezas — unidades de mercancía en sucursal (sp_consultadatospiezas_bym*)","conf"),
 "dictamen":    ("ENTIDAD","Resolución u opinión formal sobre crédito, fraude (HAWK) o situación del cliente","conf"),
 "trae":        ("ACCION", "trae / recupera (verbo — sp_*_trae — bdisuc)","conf"),
 "suc":         ("ENTIDAD","suc — sucursal (abreviación — dominio bdisuc)","conf"),
 # términos descubiertos en grounding pass D11+D12 (bdicobranza+bdicont) 2026-07-11
 "cob":         ("ENTIDAD","cob — cobranza (abreviación de dominio — sp_repcob_*, sp_obtienecob_* — bdicobranza)","conf"),
 "cobranza":    ("ENTIDAD","Gestión de recuperación de cartera vencida: campañas telefónicas, convenios y marcación","conf"),
 "compromiso":  ("ENTIDAD","compromiso de pago — promesa formal de liquidación (sp_consultacompromisosvigente)","conf"),
 "acuerdo":     ("ENTIDAD","acuerdo de pago — convenio de cobranza con el cliente (sp_grabacompromisosacuerdos)","conf"),
 "libro":       ("ENTIDAD","libro mayor / libro contable — general ledger (libromayor_diarios, libromayor_historicos)","conf"),
 "auxiliar":    ("ENTIDAD","auxiliar contable — sub-ledger contable (sdos_auxiliar, sp_validaauxiliar)","conf"),
 "balanza":     ("ENTIDAD","balanza de comprobación — trial balance (sp_generarbalanza* — bdicont)","conf"),
 # términos descubiertos en grounding pass D06+D03 re-run Round 4 (2026-07-11)
 "os":         ("ENTIDAD","OS — Originación de Solicitudes / subsistema de ofertas (sp_os_*, sp_calcula_estatus_os — bdisolic)","conf"),
 "respalda":   ("ACCION", "respalda / garantiza — aval o garantía de crédito (respalda_creditocrd, respaldacrd)","conf"),
 "respaldo":   ("ENTIDAD","respaldo / garantía de crédito (aval)","conf"),
 "indicador":  ("ENTIDAD","indicador — marcador de estado o condición (sp_ambientar_indicador_*, sp_actualiza_indicadorcred)","conf"),
 "edocta":     ("ENTIDAD","edo cta — estado de cuenta (abreviación compuesta — execmuestraedocta, generaedosctacrd)","inf"),
 "ss":         ("ENTIDAD","ss — subsistema / canal de monitoreo (abreviación — envia_monitorsol_*_ss_* — bdisolic)","conf"),
 # términos descubiertos en grounding pass D06+D03 (bdisolic+bdicred) 2026-07-11
 "cobra":      ("ACCION", "cobra / aplica cobro / genera cargo","conf"),
 "mueve":      ("ACCION", "mueve / traslada (verbo complemento de mover)","conf"),
 "ejecuta":    ("ACCION", "ejecuta (verbo — proceso / operación)","conf"),
 "mc":         ("ENTIDAD","Mesa de Control: área que autoriza, atiende y da seguimiento a solicitudes de crédito","conf"),
 "circulo":    ("ENTIDAD","Círculo de Crédito — buró de crédito para personas físicas (México)","conf"),
 "layout":     ("ENTIDAD","layout — formato de archivo de intercambio interbancario","conf"),
 "maquila":    ("ENTIDAD","maquila — proceso de externalización de solicitudes TDC","conf"),
 "nip":        ("ENTIDAD","NIP — Número de Identificación Personal (PIN bancario)","conf"),
 "tienda":     ("ENTIDAD","tienda Coppel — punto de venta físico / sucursal de tienda","conf"),
 "reevaluacion":("ACCION","reevaluación de crédito","conf"),
 "parametrico":("ENTIDAD","paramétrico — parametrización de modelos (envío paramétrico)","conf"),
 "sd":         ("ENTIDAD","sd — saldo disponible (abreviación en código de crédito)","conf"),
 # términos descubiertos en grounding pass D08 (bdispei) 2026-07-11
 "coas":      ("ENTIDAD","COAS — Confirmación de Operación y Acuse de Recibo Simplificado (mensaje de protocolo SPEI / Banxico)","conf"),
 "liq":       ("ENTIDAD","liquidación (abreviación — sp_marcaliqpago, spei_recliquidacion)","conf"),
 "habil":     ("ENTIDAD","día hábil — día bancario operativo (spei_validafecha, sp_cambio_fecha)","conf"),
 "realiza":   ("ACCION", "realiza / ejecuta una operación SPEI","conf"),
 "calcula":   ("ACCION", "calcula (verbo activo — spei_calculointeres)","conf"),
 "oxo":       ("ENTIDAD","OXXO (abreviación — spei_entordenespago_oxo)","conf"),
 "pp":        ("ENTIDAD","PP — Pago Programado / domiciliación (apercred1_pp, generaedosctacrd_pp — D03; envia_monitorsol_pp — D06)","conf"),
 "tbl":       ("ENTIDAD","tbl — tabla (abreviación — sp_depura_tbl_registro_msj)","conf"),
 # términos descubiertos en grounding pass D09 (bdimnsj) 2026-07-11
 "ckpt":      ("MODIF",  "checkpoint — evento de checkpointing del motor Informix","conf"),
 "msj":       ("ENTIDAD","mensaje — abreviación corta de mnsj (sp_validacion_msj)","conf"),
 "6dig":      ("MODIF",  "OTP/token de 6 dígitos — autenticación fuerte SMS","conf"),
 "innovattia":("ENTIDAD","Innovattia — proveedor externo de notificaciones SMS/email para BanCoppel","conf"),
 "monitoreo": ("ENTIDAD","monitoreo — proceso de vigilancia/seguimiento operativo","conf"),
 "mover":     ("ACCION", "mueve / archiva (operación de paso a histórico)","conf"),
 "invalido":  ("MODIF",  "inválido — dato o estado no válido","conf"),
 # ── ACCIONES (verbos) ──
 "consulta": ("ACCION", "consulta / proyecta estado de entidad; sp_consulta_saldos_general (bdicred, fi=435) devuelve 47 campos del snapshot financiero de un crédito (cap vig/trans/vdo, int, IVA, comisiones, línea disponible, bloqueos) usando DIRTY READ", "conf"),"cons":("ACCION","consulta","conf"),"con":("ACCION","consulta","conf"),"consreportes":("ACCION","consulta reportes","conf"),"consreporte":("ACCION","consulta reporte","conf"),
 "obtiene":("ACCION","obtiene / recupera","conf"),"obtener":("ACCION","obtiene / recupera","conf"),
 "obten":("ACCION","obtiene / recupera","conf"),"obt":("ACCION","obtiene","conf"),
 "recupera":("ACCION","recupera estado","conf"),"busca":("ACCION","busca / localiza","conf"),
 "aplica":("ACCION","aplica / ejecuta","conf"),"rec":("ACCION","recepción / recibe","conf"),"valida": ("ACCION", "valida acceso o condición antes de proceder; sp_valida_perfil_usuario (bdinteg, fi=388) consulta si_perfil_ejecut para perfiles 602/707/109/2001 y determina qué reporte muestra el ejecutivo; patrón: NVL check → tabla referencia → código+mensaje+bandera", "conf"),
 "validacion":("ACCION","validación","conf"),"carga":("ACCION","carga / ingresa","conf"),"inserta": ("ACCION", "inserta registro nuevo en tabla; sp_inserta_bitacora_cob (bdicobranza, fi=406) escribe en cb_bitacora con 3 tipos de ejecución: 01=inicio de proceso, 02=estado intermedio, 03=fin; obtiene timestamp UTC de sysmaster:sysshmvals", "conf"),
 "registra":("ACCION","Acción: da de alta y persiste un dato, evento o documento en el sistema","conf"),"genera": ("ACCION", "genera artefacto de salida; sp_generararchivo_rst (bdicnweb, fi=345) descarga tablas a .txt en /RESPALDOSNEW/archivosRST/ vía SYSTEM+dbaccess (patrón RST de unload); sp_generafolionomina (bdicheq, fi=253) emite folios secuenciales de nómina", "conf"),
 "gen":("ACCION","genera / general","conf"),"confirma":("ACCION","Acción: valida y da por firme una operación, pago o ejecutivo previamente capturado","conf"),
 "elimina":("ACCION","Acción: borra o depura registros de tablas operativas o temporales","conf"),"modifica":("ACCION","Acción: actualiza datos, parámetros o catálogos ya existentes","conf"),
 "modificacion":("ACCION","modificación","conf"),"actualiza": ("ACCION", "actualiza campo de estado en registro existente; sp_dicta_actualizastatusalerta (bdinteg, fi=270) escribe veredicto del analista de fraudes (status_alerta + analista_fraudes) en si_bitacora_comparaciones; verifica sqlerrd2≠0 para detectar fila no afectada", "conf"),
 "act":("ACCION","actualiza","conf"),"asigna":("ACCION","Acción: vincula una solicitud, usuario o recurso a un analista o responsable","conf"),
 "bloqueo":("ACCION","bloquea cuenta","conf"),"bloquea":("ACCION","bloquea cuenta","conf"),
 "desbloqueo":("ACCION","desbloquea cuenta","conf"),"desb":("ACCION","desbloqueo","conf"),
 "desbloquea":("ACCION","desbloquea cuenta","conf"),"cancelacion":("ACCION","cancela","conf"),
 "cancela":("ACCION","Acción: anula una cuenta, crédito, tarjeta, token o servicio","conf"),"devolucion":("ACCION","devuelve","conf"),
 "dev":("ACCION","devolución","conf"),"reversion":("ACCION","reversa / rollback","conf"),
 "forma":("ACCION","construye / arma","inf"),"cierre":("ACCION","Acción: proceso batch que consolida saldos y devenga intereses de un periodo (diario o masivo)","conf"),
 "califica":("ACCION","califica / evalúa (scoring)","conf"),"reestructura":("ACCION","reestructura crédito","conf"),
 "suscriptores":("ACCION","gestiona suscriptores","conf"),"fusion":("ACCION","fusiona cuentas","conf"),
 "fusionados":("ACCION","Modificador: clientes o documentos consolidados tras unificar expedientes duplicados","conf"),"fus":("ACCION","fusión de cuentas","conf"),
 "traspaso":("ACCION","traspaso entre cuentas","conf"),"traspas":("ACCION","traspaso","conf"),
 "digitalizar":("ACCION","digitaliza documento","conf"),"digi":("ACCION","digitalización","conf"),
 # ── ENTIDADES (objetos de negocio) ──
 "ordenpago":("ENTIDAD","orden de pago","conf"),"orden":("ENTIDAD","Instrucción de pago o transferencia entre cuentas (SPEI, CoDi, host-to-host)","conf"),"pago":("ENTIDAD","Abono que liquida total o parcialmente una obligación de crédito o servicio","conf"),
 "saldo":("ENTIDAD","Importe disponible o adeudado en una cuenta a una fecha dada","conf"),"saldos":("ENTIDAD","Importes disponibles o adeudados por cuenta; base del devengo de intereses y del corte","conf"),"sdo":("ENTIDAD","saldo","conf"),
 "sdodisp":("ENTIDAD","saldo disponible","conf"),"movimiento":("ENTIDAD","Transacción individual (cargo o abono) registrada en una cuenta","conf"),
 "movto":("ENTIDAD","movimiento","conf"),"cuenta":("ENTIDAD","Contrato bancario del cliente (cheques, ahorro, crédito) identificado por número o CLABE","conf"),"cta":("ENTIDAD","cuenta","conf"),
 "ctas":("ENTIDAD","cuentas","conf"),"ctaclabe":("ENTIDAD","cuenta CLABE","conf"),"clabe":("ENTIDAD","CLABE interbancaria","conf"),
 "cliente":("ENTIDAD","Persona física o moral titular de productos bancarios BanCoppel","conf"),"cte":("ENTIDAD","cliente","conf"),"ctes":("ENTIDAD","clientes","conf"),
 "beneficiarios":("ENTIDAD","Personas designadas para recibir los recursos de una cuenta o inversión por fallecimiento","conf"),"bts":("ENTIDAD","Bancomer Transfer Services — canal de transferencias BBVA; base de datos propia bdibts; confirmado por SME (2026-08-02)","conf"),
 "documentos":("ENTIDAD","Comprobantes que integran el expediente del cliente o de una solicitud","conf"),"documento":("ENTIDAD","Comprobante individual del expediente del cliente o anexado a una aclaración/bitácora","conf"),
 "doctos":("ENTIDAD","documentos","conf"),"docto":("ENTIDAD","documento","conf"),
 "pagares":("ENTIDAD","pagarés","conf"),"pagare":("ENTIDAD","pagaré","conf"),
 "producto":("ENTIDAD","Instrumento bancario ofertado (crédito, cuenta, seguro) definido en catálogo","conf"),"productos":("ENTIDAD","Catálogo de instrumentos bancarios (crédito, cuenta, seguro) con sus comisiones y versiones","conf"),
 "prod":("ENTIDAD","producto","conf"),"subproducto":("ENTIDAD","sub-producto","conf"),
 "catalogo":("ENTIDAD","catálogo","conf"),"cat":("ENTIDAD","catálogo","conf"),
 "divisas":("ENTIDAD","Monedas extranjeras y su cotización para operaciones cambiarias (Billetes y Monedas)","conf"),"firmas":("ENTIDAD","firmas mancomunadas","conf"),
 "cheques":("ENTIDAD","Títulos de pago librados contra una cuenta; se compensan y devuelven vía CCE","conf"),"cheq":("ENTIDAD","cheque","conf"),"folio":("ENTIDAD","Identificador consecutivo único de una operación, solicitud o aclaración para su rastreo","conf"),
 "nomina":("ENTIDAD","nómina","conf"),"nom":("ENTIDAD","nómina","conf"),"evento":("ENTIDAD","evento/notificación","conf"),
 "bitacora":("ENTIDAD","bitácora","conf"),"afore":("ENTIDAD","AFORE (Afore Coppel — 2ª mayor de México, ~14.5M cuentas)","conf"),
 "perfil":("ENTIDAD","perfil de usuario","conf"),"usuario":("ENTIDAD","Empleado u operador con perfil y permisos para operar el sistema","conf"),"usuarios":("ENTIDAD","Empleados u operadores con perfil y permisos; sujetos de bitácora y control de acceso","conf"),
 "ejecutivo":("ENTIDAD","Empleado de sucursal o promotoría que atiende clientes y solicitudes (validado en CNSIF)","conf"),"marcas":("ENTIDAD","marcas de cuenta","conf"),"marca":("ENTIDAD","Bandera aplicada a una cuenta o cliente por situación especial (IPAB, PLD, precalificación)","conf"),
 "alertas":("ENTIDAD","Notificaciones de eventos que requieren atención (SPEI, CoDi, dictamen, PLD)","conf"),"alerta":("ENTIDAD","Notificación de un evento que requiere atención o seguimiento (PLD, fraude, dictamen)","conf"),"situaciones":("ENTIDAD","situaciones de cuenta","conf"),
 "ciudades":("ENTIDAD","ciudades (catálogo)","conf"),"colonias":("ENTIDAD","colonias (catálogo domicilio)","conf"),
 "cp":("ENTIDAD","código postal","conf"),"dictamen":("ENTIDAD","Resolución u opinión formal sobre crédito, fraude (HAWK) o situación del cliente","conf"),
 "piezas":("ENTIDAD","piezas de efectivo (billetes y monedas)","conf"),"pieza":("ENTIDAD","pieza de efectivo (billete/moneda)","conf"),
 "denominacion":("ENTIDAD","denominación (valor facial del billete/moneda)","conf"),"denominaciones":("ENTIDAD","Valores nominales de billetes y monedas para el conteo de efectivo en caja","conf"),
 "catdenominacion":("ENTIDAD","catálogo de denominaciones","conf"),"efectivo":("ENTIDAD","Dinero en billetes y monedas manejado en caja, cajero o traslado de valores","conf"),"boveda":("ENTIDAD","bóveda","conf"),
 "estatussolic":("ENTIDAD","estatus de solicitud","conf"),
 "estatus": ("ENTIDAD", "estado de un objeto de negocio; en bdicred: estatus_cred (activo/bloqueado/vencido), en bdinteg: status_alerta (veredicto antifraude en si_bitacora_comparaciones), en bdicnweb: estatus de solicitud y proceso; valor siempre CHAR(1-2) codificado", "conf"),"solicitud":("ENTIDAD","Petición del cliente de un producto o servicio que sigue flujo de originación y autorización","conf"),
 "solic":("ENTIDAD","solicitud","conf"),"sol":("ENTIDAD","solicitud","conf"),"solin":("ENTIDAD","solicitud de crédito","conf"),
 "lincred":("ENTIDAD","línea de crédito","conf"),"credito":("ENTIDAD","crédito","conf"),"cred": ("ENTIDAD", "crédito — productos financieros de préstamo en bdicred; familia dominante: consulta al Buró de Crédito para solicitudes de línea (sp_mon_buro_conssolcredlincred2, fi=325) con paginación, segmento/etiqueta y asignación a analista via SQL dinámico (5000 chars)", "conf"),"cre":("ENTIDAD","crédito","conf"),
 "scoring":("ENTIDAD","scoring crediticio","conf"),"motor":("ENTIDAD","motor de decisión","conf"),
 "buro":("ENTIDAD","Buró de Crédito","conf"),"etiqueta":("ENTIDAD","Nodo o campo (tag) de un mensaje XML que se arma o del que se extrae valor","conf"),"xml":("ENTIDAD","Formato de intercambio de mensajes estructurados entre sistemas","conf"),
 "fecha":("ENTIDAD","Dato de calendario que acota o sella una operación o proceso","conf"),"fechas":("ENTIDAD","Rango o conjunto de datos de calendario que acota consultas, cortes y quincenas","conf"),"datos":("ENTIDAD","Conjunto de campos o atributos que describen una entidad de negocio","conf"),
 "abono":("ENTIDAD","abono / crédito","conf"),"cargo":("ENTIDAD","cargo / débito","conf"),
 "transaccion":("ENTIDAD","transacción","conf"),"cedula":("ENTIDAD","cédula de identificación","conf"),
 "cedulas":("ENTIDAD","cédulas","conf"),"empresas":("ENTIDAD","empresas (nómina empresarial)","conf"),
 "rpt":("ENTIDAD","reporte","conf"),"reporte":("ENTIDAD","Salida estructurada de datos para consumo regulatorio, operativo o de negocio (ej. sp_reporte_usuarios_amov)","conf"),"reportes":("ENTIDAD","Salidas estructuradas de datos para consumo regulatorio, operativo o de negocio","conf"),
 "tpcalculo":("ENTIDAD","tipo de cálculo","conf"),"calculo":("ENTIDAD","cálculo","conf"),
 "imagenes":("ENTIDAD","imágenes / documentos digitales","conf"),"imagen":("ENTIDAD","imagen digital","conf"),
 "poliza":("ENTIDAD","póliza","inf"),"politica":("ENTIDAD","política de crédito","conf"),
 "huellas":("ENTIDAD","huellas biométricas","conf"),"huella":("ENTIDAD","huella biométrica","conf"),
 "medioacceso":("ENTIDAD","medio de acceso","conf"),"acceso":("ENTIDAD","Medio y permisos con que un usuario o cliente ingresa a un canal, cuenta o módulo","conf"),
 "frecpago":("ENTIDAD","frecuencia de pago","conf"),"telefonos":("ENTIDAD","teléfonos","conf"),
 "telefono":("ENTIDAD","teléfono","conf"),"nombre":("ENTIDAD","Denominación textual de una persona, archivo o entidad","conf"),
 # ── MODIFICADORES ──
 "diarios":("MODIF","Modificador: proceso o dato con periodicidad de un día (cierre, saldos, movimientos)","conf"),"diario":("MODIF","Modificador: proceso o reporte que corre una vez al día","conf"),"masivo":("MODIF","Modificador: procesamiento por lote de múltiples registros en una sola corrida","conf"),
 "preventivo":("MODIF","Modificador: acción anticipada para evitar un riesgo (ej. cierre preventivo de cuenta)","conf"),"inmediato":("MODIF","Modificador: aplicación en tiempo real, sin diferimiento (ej. abono inmediato)","conf"),"general":("MODIF","Modificador: alcance amplio o consolidado, sin filtros específicos","conf"),
 "manual":("MODIF","Modificador: operación capturada o ejecutada por un operador, no automatizada","conf"),"extemporanea":("MODIF","extemporánea","conf"),"faltantes":("MODIF","Modificador: elementos ausentes (documentos del expediente, efectivo de caja o cajero)","conf"),
 "baja":("MODIF","de baja","conf"),"max":("MODIF","máximo","conf"),"visual":("MODIF","Modificador: revisión por inspección directa (ej. cotejo visual de firmas en cheques)","conf"),
 "por":("MODIF","por (criterio)","conf"),"x":("MODIF","por (criterio)","conf"),"forzada":("MODIF","Modificador: transacción aplicada sin autorización en línea, forzando su procesamiento","conf"),
 "esp":("MODIF","especial","conf"),"comp":("MODIF","complemento","conf"),
 "tp":("MODIF","tipo","conf"),"dia":("MODIF","del día","conf"),"deb":("MODIF","débito","conf"),
 "web":("MODIF","canal web","conf"),"sub":("MODIF","sub-","inf"),
 "inactivas":("MODIF","inactivas (art.61)","conf"),"inactiv":("MODIF","inactiva","conf"),
 "activos":("MODIF","Modificador: registros vigentes o habilitados (convenios, mensajes, productos)","conf"),"totales":("MODIF","Modificador: variante de un SP que devuelve el conteo agregado para paginación","conf"),"ultimas":("MODIF","últimas","inf"),
 "fallecimiento":("MODIF","por fallecimiento","conf"),"temp":("MODIF","temporal","conf"),
 # ── REGULATORIO ──
 "codi":("REG","CoDi — Cobro Digital (Banxico)","conf"),
 "art61":("REG","Art. 61 LIC (cuentas inactivas cuyos saldos, tras años sin movimiento, prescriben a favor de la beneficencia pública)","conf"),
 "ivasart61":("REG","IVA sobre operaciones del Art. 61 LIC (alcance fiscal por confirmar con el SME)","gap"),
 # ── AMBIGUO (requieren SME/DBA) ──
 "b3":("MODIF","sufijo de versión de SP (Bloque/Build 3) — patrón Informix: no existe ALTER PROCEDURE, se crea nueva versión con sufijo _b3/_b4/_b5","conf"),
 "bym":("ENTIDAD","Billetes y Monedas (efectivo en sucursal — evidencia: 'piezas' + 'denominación')","conf"),
 "bym2":("ENTIDAD","Billetes y Monedas (v2)","conf"),"bym3":("ENTIDAD","Billetes y Monedas (v3)","conf"),
 "sac":("ENTIDAD","Servicios de Atención al Cliente — subsistema de atención en sucursal (ventanilla, domiciliación, abonos ATM, remesas WU); base de datos propia bdisac: con tabla sac_movimientoshistorial; confirmado por SME (2026-08-02)","conf"),"ref":("AMBIGUO","referencia","conf"),
 "tco":("ENTIDAD","TCO — Tarjetas Coppel / TCoppel (producto de crédito Grupo Coppel); confirmado por SME (Jorge Isaac Díaz, 2026-07-09)","conf"),"pba":("MODIF","PBA — sufijo de SPs para Pruebas; confirmado por SME (Guerra, Alejandro, 2026-07-09)","conf"),
 "bpi":("MODIF","Banca Por Internet (canal web BPI)","conf"),"soc":("ENTIDAD","Sistema Operativo Central (SOC) — confirmado SME","conf"),
 # [auditoría 2026-07-06] removidos "re" y "mc": ruido de segmentación (matchean dentro de empresa/registros/recuperacion/numcte)
 "ccl":("ENTIDAD","módulo de Cédulas de Captación e inversión — pagaré, ISR, saldos diarios, inversión auto-creciente (bdicnweb:sp_ccl_*)","conf"),"fus2":("AMBIGUO","fusión v2","inf"),
 # ── COMPUESTOS FRECUENTES (atajo de segmentación) ──
 "recordenpago":("ACCION","recibe orden de pago","conf"),"reccancelacion":("ACCION","recibe cancelación","conf"),
 "recdevolucion":("ACCION","recibe devolución","conf"),"recextemporanea":("ACCION","recibe orden extemporánea","conf"),
 "aplicaordenpago":("ACCION","aplica orden de pago","conf"),"cargamovimiento":("ACCION","carga movimiento","conf"),
 "cargamanual":("ACCION","carga manual","conf"),"conssaldosdiarios":("ACCION","consulta saldos diarios","conf"),
 "cilocconsulta":("ACCION","consulta local (cobranza)","conf"),"productotransaccion":("ENTIDAD","producto-transacción","conf"),
 "generafolionomina":("ACCION","genera folio de nómina","conf"),"confirmasms":("ACCION","confirma vía SMS (2FA)","conf"),
 "abonoinmediato":("ENTIDAD","abono inmediato","conf"),"datosdia":("ENTIDAD","datos del día","conf"),
 "devforzada":("ACCION","devolución forzada","conf"),"folionomina":("ENTIDAD","folio de nómina","conf"),
 "consutacat":("ACCION","consulta catálogo [typo]","conf"),
 "generafechpagoreestructura":("ACCION","genera fecha de pago de reestructura","conf"),
 "consprodcte":("ACCION","consulta producto de cliente","conf"),"ctasinactivas":("ENTIDAD","cuentas inactivas","conf"),
 "conscedulas":("ACCION","consulta cédulas","conf"),"cedulacontable":("ENTIDAD","cédula contable","conf"),
 # ── TÉRMINOS DE PARÁMETROS (minados del código fuente — mine-source.py) ──
 "empresa":("ENTIDAD","empresa (entidad bancaria)","conf"),"sucursal":("ENTIDAD","Oficina física de atención al cliente; unidad operativa que opera caja","conf"),
 "numcte":("ENTIDAD","número de cliente","conf"),"numsol":("ENTIDAD","número de solicitud","conf"),"idfuncion":("ENTIDAD","id de funcionalidad","conf"),
 "referencia":("ENTIDAD","Dato que identifica un pago frecuente, beneficiario o tasa de referencia","conf"),"ingreso":("ENTIDAD","ingreso (del solicitante)","conf"),
 "conyuge":("ENTIDAD","cónyuge (solicitud crédito)","conf"),"parentesco":("ENTIDAD","parentesco (referencia)","conf"),
 "nombreref":("ENTIDAD","nombre de referencia","conf"),"telefono":("ENTIDAD","teléfono","conf"),
 "importe":("ENTIDAD","Cantidad monetaria de una operación","conf"),"claverastreo":("ENTIDAD","clave de rastreo SPEI (hasta 30 posiciones alfanuméricas, Banxico)","conf"),
 "rastreo":("ENTIDAD","rastreo (SPEI)","conf"),"transacc":("ENTIDAD","código de transacción","conf"),
 "divisa":("ENTIDAD","Moneda extranjera y su cotización para operaciones cambiarias","conf"),"monto":("ENTIDAD","Valor monetario de una operación, límite o convenio","conf"),"cheque":("ENTIDAD","Título de pago librado contra una cuenta; se compensa vía CCE","conf"),
 "tarjeta":("ENTIDAD","Plástico de débito o crédito asociado a una cuenta del cliente","conf"),"docto":("ENTIDAD","documento","conf"),"concepto":("ENTIDAD","concepto de pago","conf"),
 "concentradora":("ENTIDAD","cuenta concentradora","conf"),"hipotecario":("ENTIDAD","crédito hipotecario","conf"),
 "sbc":("ENTIDAD","saldo básico de cuenta (SBC)","conf"),"folsuc":("ENTIDAD","folio de sucursal","conf"),
 "region":("ENTIDAD","región","conf"),"aval":("ENTIDAD","aval / garante","conf"),"garantia":("ENTIDAD","garantía","conf"),
 "periodicidad":("MODIF","Modificador: frecuencia con que se repite un cargo o proceso","conf"),"remanente":("MODIF","Modificador: saldo o importe residual pendiente tras un pago o proceso","conf"),"autoriza":("ACCION","Acción: aprueba una operación o eleva su nivel de permiso","conf"),
 "recuperacion":("ACCION","recuperación (cobranza)","conf"),
 # ── ÁTOMOS Y COMPUESTOS MINADOS A ESCALA (3,761 SPs · nombres + params) ──
 # átomos productivos (resuelven muchos compuestos num+X, id+X, tipo+X)
 "num":("ENTIDAD","número (de)","conf"),"id":("ENTIDAD","identificador (de)","conf"),
 "tipo":("MODIF","tipo de","conf"),"idfuncionc":("ENTIDAD","id de funcionalidad","conf"),
 "numcredito":("ENTIDAD","número de crédito","conf"),
 "numcuenta":("ENTIDAD","número de cuenta","conf"),"numtarjeta":("ENTIDAD","número de tarjeta","conf"),
 "numsolicitud":("ENTIDAD","número de solicitud","conf"),"numempleado":("ENTIDAD","número de empleado","conf"),
 "numproducto":("ENTIDAD","número de producto","conf"),"numsucursal":("ENTIDAD","número de sucursal","conf"),
 "numcred":("ENTIDAD","número de crédito","conf"),
 # acciones
 "operacion":("ACCION","operación","conf"),"ope":("ACCION","operación","conf"),
 "verifica":("ACCION","Acción: comprueba estatus, validez o consistencia de un dato o proceso","conf"),"guarda":("ACCION","guarda / almacena","conf"),
 "graba":("ACCION","graba / almacena","conf"),"alta":("ACCION","da de alta / registra","conf"),
 "notifica":("ACCION","Acción: comunica al cliente o usuario un evento por SMS, correo u otro canal","conf"),"notifi":("ACCION","notifica","conf"),
 "envio":("ACCION","envía","conf"),"envia":("ACCION","envía","conf"),"upgrade":("ACCION","actualiza producto (upgrade)","conf"),
 "conciliacion":("ACCION","conciliación","conf"),"concentracion":("ACCION","concentración de fondos","conf"),
 # entidades / objetos de negocio
 "detalle":("ENTIDAD","Desglose renglón por renglón de una operación o consulta","conf"),
 "oficio":("ENTIDAD","oficio (requerimiento judicial/autoridad)","conf"),"ofi":("ENTIDAD","oficio","conf"),
 "tef":("ENTIDAD","TEF — transferencia electrónica de fondos","conf"),
 "tdc":("ENTIDAD","tarjeta de crédito (TDC)","conf"),"info":("ENTIDAD","información","conf"),
 "archivo":("ENTIDAD","Fichero de intercambio por lote (nómina, TEF, domiciliación, Buró de Crédito)","conf"),"arch":("ENTIDAD","archivo","conf"),
 "atms":("ENTIDAD","cajeros automáticos (ATM)","conf"),"caja":("ENTIDAD","caja / ventanilla","conf"),
 "mail":("ENTIDAD","correo electrónico","conf"),"correo":("ENTIDAD","correo electrónico","conf"),
 "sms":("ENTIDAD","Mensaje de texto al celular del cliente para avisos y confirmaciones","conf"),"msi":("ENTIDAD","meses sin intereses (MSI)","conf"),
 "cartera":("ENTIDAD","cartera de crédito","conf"),"biometrico":("ENTIDAD","biométrico","conf"),
 "domiciliacion":("ENTIDAD","domiciliación","conf"),"domi":("ENTIDAD","domiciliación","conf"),
 "pos":("ENTIDAD","punto de venta (POS)","conf"),"auditoria":("ENTIDAD","auditoría","conf"),"aud":("ENTIDAD","auditoría","conf"),
 "convenio":("ENTIDAD","convenio (nómina/empresarial)","conf"),"venio":("ENTIDAD","convenio","conf"),
 "parametros":("ENTIDAD","parámetros","conf"),"param":("ENTIDAD","parámetro","conf"),"parametro":("ENTIDAD","parámetro","conf"),
 "estado":("ENTIDAD","estado (entidad federativa / estatus)","inf"),"edo":("ENTIDAD","estado","conf"),
 "registros":("ENTIDAD","Renglones de datos de una tabla; unidades de resultado en consultas paginadas","conf"),"lote":("ENTIDAD","lote (proceso batch)","conf"),
 "secuencia":("ENTIDAD","Contador consecutivo que genera folios o identificadores únicos","conf"),"origen":("ENTIDAD","Canal o fuente de donde proviene una operación, solicitud o archivo","conf"),"codigo":("ENTIDAD","código","conf"),
 "codigos":("ENTIDAD","códigos","conf"),"codificacion":("ENTIDAD","codificación","conf"),
 "decodifica":("ACCION","Acción: interpreta y separa los campos de una línea de captura o cadena codificada","conf"),"opcion":("ENTIDAD","opción","conf"),"canal":("ENTIDAD","canal","conf"),"descripcion":("ENTIDAD","descripción","conf"),
 "rfc":("ENTIDAD","RFC (registro fiscal)","conf"),"causa":("ENTIDAD","causa / motivo","conf"),
 "periodo":("ENTIDAD","Rango de fechas que acota facturación, corte o consulta","conf"),"clave":("ENTIDAD","Código identificador (CLABE, clave de retiro, homoclave) o credencial de acceso","conf"),"sistema":("ENTIDAD","Módulo o subsistema aplicativo del core, o el reloj/fecha del entorno; ámbito de una operación (ej. sp_bitacorasistema)","conf"),
 "plantilla":("ENTIDAD","Formato precargado reutilizable, típicamente de nómina y empleados, para agilizar altas y dispersiones en BPI","conf"),"ruta":("ENTIDAD","ruta (de archivo)","conf"),"descarga":("ENTIDAD","Extracción de archivos, imágenes o información desde el core para consumo externo (estados de cuenta, conciliación)","conf"),
 "titulo":("ENTIDAD","título","conf"),"empleado":("ENTIDAD","Persona trabajadora de una empresa empleadora, sujeta a nómina y descuentos; también operador interno del banco","conf"),"mac":("ENTIDAD","dirección MAC","conf"),
 "empresarial":("ENTIDAD","empresarial (nómina)","conf"),"respuesta":("ENTIDAD","Registro del resultado devuelto por un servicio o contraparte (Buró, Western Union, validaciones PAYI/REVI)","conf"),
 "fechafin":("ENTIDAD","fecha fin","conf"),"fechainicio":("ENTIDAD","fecha inicio","conf"),
 "fechainicial":("ENTIDAD","fecha inicial","conf"),"fechafinal":("ENTIDAD","fecha final","conf"),
 "fechaconsulta":("ENTIDAD","fecha de consulta","conf"),"inicio":("MODIF","Modificador: marca de comienzo de un periodo o proceso (inicio de mes, inicio de sesión)","conf"),"final":("MODIF","Modificador: marca de cierre o última fase de un proceso ya ejecutado (pase contable final, finalización de cédula)","conf"),
 # modificadores
 "total":("MODIF","Modificador: cifra agregada o conteo global de una consulta o cálculo, no el detalle línea a línea","conf"),"totales":("MODIF","Modificador: variante de un SP que devuelve el conteo agregado para paginación","conf"),"moral":("MODIF","persona moral","conf"),
 "fisica":("MODIF","persona física","conf"),"fisicas":("MODIF","personas físicas","conf"),
 "app":("MODIF","canal app","conf"),"ivr":("MODIF","canal IVR (telefónico)","conf"),
 "movil":("MODIF","canal móvil","conf"),"suc":("MODIF","sucursal","conf"),"aumento":("MODIF","Modificador: incremento de un valor, típicamente de la línea de crédito autorizada al cliente","conf"),# ambiguos — requieren SME/DBA
 "cap":("ENTIDAD","Captación — cuentas de ahorro/depósito; evidencia: sp_cap_genrepcancelacioncuentascaptacion, nCtaCap, recalculagat1200 (GAT = Ganancia Anual Total regulado por Banxico)","conf"),
 "soe":("ENTIDAD","SOE — Soporte Operativo EmpresaNet; confirmado por SME (Jorge Isaac Díaz, 2026-07-09)","conf"),
 "seg":("ENTIDAD","[polisemia] Seguridad (bdicnweb: usuarios, perfiles, app móvil) | Seguro (bdisac: pólizas — sac_abono_seg, sac_cons_seg; poliza + cantidadseguros + claveseguro)","conf"),"ris":("ENTIDAD","Riesgo — módulo de gestión de riesgo crediticio (bdicnweb:sp_ris_*); confirmado en código: nivel_riesgo, grado_riesgo, califica_riesgo","conf"),
 "cnt":("ENTIDAD","CNT — módulo de convenios y control de descuentos de nómina de empleados (sp_cnt_catconvenio, detallefaltdescemp, genreportesolcred — bdicnweb)","conf"),"adn":("ACCION","Adelanto de Nómina — producto de crédito al consumo liquidable vía descuento automático de nómina (cierre diario + cobro automático sobre bdicred)","conf"),
 "cjunk":("AMBIGUO","variable temporal (ruido de código, se ignora)","conf"),
 "mesas":("ENTIDAD","Mesas de Control — equipo de revisión y autorización de solicitudes de crédito (plural de Mesa de Control)","conf"),
 # [auditoría] removido "pro": ruido (matchea dentro de producto/procede/proceso, ya completos)
 "dic":("AMBIGUO","¿diciembre / dictamen? — por confirmar con el SME","gap"),
 # ── segunda pasada de candidatos (reduce ruido de fragmentación) ──
 "cantidad":("ENTIDAD","Número de elementos o unidades contadas (registros, adicionales del crédito, campos)","conf"),"cant":("ENTIDAD","cantidad","conf"),
 "busqueda":("ACCION","búsqueda","conf"),"ejecucion":("ENTIDAD","ejecución (de proceso)","conf"),
 "proceso":("ENTIDAD","Corrida batch o flujo operativo con estatus rastreable vía monitor (conciliación, cierre, generación de archivos)","conf"),"proc":("ENTIDAD","proceso","conf"),
 "registro":("ENTIDAD","Renglón o asiento individual almacenado en tabla; unidad mínima de dato persistido y rastreable","conf"),"monitor":("ENTIDAD","Tablero de seguimiento en tiempo real del estatus de procesos, operaciones y efectivo en caja","conf"),
 "beneficiario":("ENTIDAD","beneficiario","conf"),"benef":("ENTIDAD","beneficiario","conf"),
 "cve":("ENTIDAD","clave (cve)","conf"),"cod":("ENTIDAD","código","conf"),
 "bandera":("MODIF","bandera / flag (técnico)","conf"),
 "reinicia":("ACCION","reinicia / resetea","conf"),"reinicio":("ACCION","Acción: reiniciar un contador, secuencia o proceso a su estado inicial para una nueva corrida","conf"),
 "inicia":("ACCION","Acción: arrancar un proceso, sesión o secuencia; también reiniciar secuencias y folios","conf"),"inicializa":("ACCION","Acción: poner en estado base tablas, saldos o acumuladores al comienzo de un periodo o corrida","conf"),
 "inicial":("MODIF","Modificador: correspondiente al arranque de un proceso o periodo (carga inicial, saldo inicial)","conf"),
 "pase":("ACCION","pase contable (registra/traslada a póliza o mayor)","conf"),
 "pasecont":("ACCION","realiza el pase contable (registro a póliza/mayor)","conf"),
 "pasecheq":("ACCION","pase de cheque (a compensación/conciliación)","conf"),
 "poliza":("ENTIDAD","póliza contable","conf"),"mayor":("ENTIDAD","mayor contable","conf"),
 "asiento":("ENTIDAD","asiento contable","conf"),
 "propuesta":("ENTIDAD","Oferta u ofrecimiento generado al cliente, típicamente de crédito o producto, sujeto a aceptación","conf"),"trans":("ENTIDAD","[polisemia] Transferencia (bditransfer, bditrans: transferencias y remesas con campos pbco_dest/ppais_dest) | Transacción (sufijo genérico en SPs de reversión y procesamiento)","conf"),
 "desc":("ENTIDAD","[polisemia] Descripción (sp_desc_ret: devuelve descripción del código de retorno) | Descarga (sp_desc_archivos_cfdi/conc: descarga archivos CFDI y conciliación)","conf"),
 "empresas":("ENTIDAD","empresas (nómina empresarial)","conf"),
 # ── tercera pasada de candidatos (3,761 SPs) ──
 "banco":("ENTIDAD","Institución bancaria contraparte en transferencias interbancarias (TEF, SPEI); catálogo de bancos participantes","conf"),"coppel":("ENTIDAD","Coppel (grupo)","conf"),
 "hoy":("MODIF","de hoy / fecha actual","conf"),"anio":("ENTIDAD","año","conf"),"mes":("ENTIDAD","Periodo mensual base del cálculo de saldos promedio, devengos e indicadores; unidad de cierre contable","conf"),
 "hora":("ENTIDAD","Momento u horario límite que condiciona la ejecución de operaciones (TEF, remesas, cortes)","conf"),"mensual":("MODIF","Modificador: periodicidad de mes para reportes, cargas y cierres de saldo promedio","conf"),
 "ord":("ENTIDAD","ordenante / orden (SPEI)","conf"),"mov":("ENTIDAD","movimiento","conf"),
 "motivo":("ENTIDAD","motivo / causa","conf"),"apellido":("ENTIDAD","Componente del nombre del cliente, validado contra RFC y usado en búsquedas e identificación","conf"),"error":("ENTIDAD","Condición de fallo registrada en bitácora con código y descripción para diagnóstico y reenvío","conf"),"ciudad":("ENTIDAD","Nivel geográfico del domicilio, catalogado y conciliado contra SEPOMEX para validar direcciones","conf"),"atm":("ENTIDAD","cajero automático (ATM)","conf"),
 "token":("ENTIDAD","token (autenticación)","conf"),"zona":("ENTIDAD","Segmento territorial (zona, colonia, calle) usado para catalogar y validar el domicilio del cliente","conf"),"calle":("ENTIDAD","calle (domicilio)","conf"),
 "domicilio":("ENTIDAD","Dirección registrada del cliente, validada contra INE/SAT/SEPOMEX y usada en KYC y notificaciones","conf"),"expediente":("ENTIDAD","Conjunto de documentos digitalizados del cliente por producto, base del dictamen crediticio","conf"),
 "identificacion":("ENTIDAD","identificación","conf"),"categoria":("ENTIDAD","categoría","conf"),
 "vencimiento":("ENTIDAD","Fecha límite de una obligación o instrucción (pagaré, inversión); condiciona reinversión o exigibilidad","conf"),"venc":("ENTIDAD","vencimiento","conf"),
 "analista":("ENTIDAD","Operador de Mesa de Control que revisa, dictamina y autoriza solicitudes de crédito y aumentos de línea","conf"),"pais":("ENTIDAD","país","conf"),"tel":("ENTIDAD","teléfono","conf"),
 "cel":("ENTIDAD","celular","conf"),"emisor":("ENTIDAD","Institución emisora de la tarjeta identificada por su BIN; contraparte en operaciones de tarjeta","conf"),"grupo":("ENTIDAD","Segmento de clasificación del cliente por comportamiento o demografía, usado en scoring y reportes","conf"),
 "plaza":("ENTIDAD","plaza (regional)","conf"),"puntos":("ENTIDAD","puntos (recompensas)","conf"),
 "valor":("ENTIDAD","Dato o importe puntual leído de parámetros, tramas XML o servicios; magnitud a aplicar en un cálculo","conf"),"destino":("ENTIDAD","Cuenta, banco o plaza receptora de una operación, contraparte del origen en una transferencia","conf"),"servicio":("ENTIDAD","Producto o funcionalidad contratable activable por canal (EmpresaNet, BEI); alta/baja/consulta","conf"),
 "titular":("ENTIDAD","titular de cuenta","conf"),"mensaje":("ENTIDAD","Texto o notificación enviada al cliente o al operador (SMS, avisos, mensajes de estado de cuenta)","conf"),"local":("MODIF","Modificador: ámbito acotado o localización geográfica; contrasta con procesamiento central","conf"),
 "bloq":("ACCION","bloqueo","conf"),"rol":("ENTIDAD","rol / perfil","conf"),"gral":("MODIF","general","conf"),
 "comision":("REG","comisión (CONDUSEF — debe estar en RECO)","conf"),
 "iva":("REG","IVA (impuesto — SAT)","conf"),"impuesto":("REG","impuesto (SAT)","conf"),
 "admin":("ENTIDAD","Administrador — rol de usuario con privilegios administrativos (pIdAdmin INTEGER en bdibei/bdibpi); también administración de tasas y procesos","conf"),
 "imp":("ENTIDAD","Impago — pago vencido o fallido; confirmado: n_impagos_consec (impagos consecutivos), n_imp_hist_6m (historial 6 meses) en motor de scoring crediticio (bdicred)","conf"),
 "emp":("ENTIDAD","Empresa — empleadora del cliente; vinculada a crédito de nómina (ADN); SPs: sp_consulta_datos_emp_bei (phone+address), sp_genera_emp_gc (Grupo Coppel), inserta_rel_cte_emp","conf"),"mesa":("ENTIDAD","Mesa de Control — equipo de revisión y autorización de solicitudes de crédito; status codes MC/CM; valida comprobantes de ingreso; comentario explícito en código","conf"),
 "oro":("ENTIDAD","Tier medio de la Tarjeta de Crédito BanCoppel — jerarquía Clásica < Oro < Platino; path de upgrade desde crédito Grupo Coppel","conf"),
 # ── PRODUCTOS Y NEGOCIO BANCOPPEL (investigado en la web · 2026-07-03) ──
 "prestamo":("ENTIDAD","préstamo (Personal / Nómina / Digital BanCoppel)","conf"),
 "prestamos":("ENTIDAD","préstamos","conf"),"remesa":("ENTIDAD","remesa (Western Union / MoneyGram)","conf"),
 "remesas":("ENTIDAD","remesas internacionales","conf"),"hipoteca":("ENTIDAD","crédito hipotecario (digital, desde 2025)","conf"),
 "inversion":("ENTIDAD","inversión (pagaré / plazo)","conf"),"quincena":("ENTIDAD","quincena (periodo de pago nómina/crédito Coppel)","conf"),
 "clic":("ENTIDAD","BanCoppel Clic (tarjeta digital instantánea)","conf"),
 "cep":("ENTIDAD","Comprobante Electrónico de Pago (SPEI · Banxico)","conf"),
 "efectiva":("ENTIDAD","Cuenta Efectiva Digital (débito BanCoppel)","conf"),
 "pin":("ENTIDAD","PIN dinámico (tarjeta digital)","conf"),"recompensa":("ENTIDAD","recompensa / cashback (Coppel Max)","inf"),
 "oxxo":("ENTIDAD","OXXO (red de depósito/retiro)","conf"),"comercio":("ENTIDAD","comercio afiliado","conf"),
 # precisiones de negocio (SPEI/Banxico — glosario oficial)
 "beneficiario":("ENTIDAD","beneficiario (receptor del pago SPEI)","conf"),
 "ordenante":("ENTIDAD","ordenante (pagador que emite la orden SPEI)","conf"),
 # ── palabras completas que eliminan ruido de segmentación (2026-07-03) ──
 "plazo":("ENTIDAD","plazo (depósito / crédito a plazo)","conf"),
 "combo":("ENTIDAD","combo / lista desplegable (control de UI en app)","conf"),
 "isr":("REG","ISR — Impuesto Sobre la Renta (retención · SAT)","conf"),
 "interes":("ENTIDAD","interés","conf"),"intereses":("ENTIDAD","Rédito devengado o provisionado sobre saldos y créditos según tasa y días transcurridos","conf"),
 "int":("ENTIDAD","interés","conf"),
 "digitalizacion":("ENTIDAD","digitalización de documentos","conf"),
 "supervision":("ENTIDAD","supervisión","conf"),"division":("ENTIDAD","división","conf"),
 "revision":("ENTIDAD","revisión","conf"),"presentado":("MODIF","presentado (a cobro)","conf"),
 "presenta":("ACCION","Acción: enviar documentos a compensación o cobro ante la cámara (cheques, domiciliaciones a CCE)","conf"),"presentacion":("ENTIDAD","presentación","conf"),
 "transportadora":("ENTIDAD","transportadora de valores (traslado de efectivo)","conf"),
 "remesadora":("ENTIDAD","remesadora (envío de remesas)","conf"),
 "receptor":("ENTIDAD","Contraparte que recibe una transferencia electrónica de fondos (rol receptor en TEF)","conf"),
 "tasa":("ENTIDAD","tasa (de interés)","conf"),"inf":("ENTIDAD","información","conf"),
 # ── palabras completas (auditoría exhaustiva 2026-07-06 — el longest-match las prefiere y elimina falsos de tokens cortos) ──
 "retiro":("ENTIDAD","Disposición de efectivo de una cuenta (cajero, sucursal, corresponsal); afecta saldo disponible","conf"),"retiros":("ENTIDAD","Conjunto de disposiciones de efectivo consultadas o parametrizadas por cuenta, canal o límite","conf"),"resultado":("ENTIDAD","Desenlace de una gestión o proceso registrado y catalogado (cobranza, fin de ejercicio, validación SAT)","conf"),
 "captura":("ACCION","Acción: ingreso y persistencia de datos al sistema por un operador o carga (FATCA, crédito, parámetros)","conf"),"consecutivo":("ENTIDAD","Número secuencial que identifica y ordena archivos o registros para su control y rastreo","conf"),"liquidacion":("ENTIDAD","liquidación","conf"),
 "nacionalidad":("ENTIDAD","País de origen del cliente, catalogado para requisitos KYC y clasificación FATCA","conf"),"direccion":("ENTIDAD","dirección","conf"),"direcciones":("ENTIDAD","Domicilios y datos de contacto del cliente (postal, SMS, teléfonos) capturados y validados","conf"),
 "historico":("MODIF","histórico","conf"),"dotacion":("ENTIDAD","dotación de efectivo (a cajero/sucursal)","conf"),
 "dotaciones":("ENTIDAD","dotaciones de efectivo","conf"),"fatca":("REG","FATCA (reporte fiscal cuentas EE.UU. — SAT/IRS)","conf"),
 "encabezado":("ENTIDAD","Bloque de cabecera con totales y datos de control de un archivo, lote o estado de cuenta","conf"),"central":("MODIF","Modificador: procesamiento o cuenta centralizada del core, frente a la operación por sucursal o local","conf"),"depura": ("ACCION", "depura / purga registros expirados de tabla operativa; patrón observado en bdicred: FOREACH+DELETE+COMMIT por fila con contador iCuentasaDepurar, UPDATE STATISTICS al cierre; controla ventana horaria via sd_param cod_param=119 y soporta reinicio", "conf"),
 "depuracion":("ACCION","depuración","conf"),"apertura":("ENTIDAD","apertura (de cuenta/crédito)","conf"),"sorteo":("ENTIDAD","Sorteo de efectivo BanCoppel: asignación de folios de premio según saldo, reportable al SAT","conf"),
 "primer":("MODIF","Modificador: primera ocurrencia de un evento del cliente (primer uso, primer consumo, primera compra)","conf"),"cita":("ENTIDAD","Agendamiento de trámite o atención en sucursal, con estatus y horario asignados","conf"),"citas":("ENTIDAD","Conjunto de agendamientos de trámite o atención en sucursal consultados por cliente","conf"),
 "factura":("ENTIDAD","Comprobante de facturación asociado a la originación de solicitudes y al devengo de intereses del crédito","conf"),"facturacion":("ENTIDAD","facturación","conf"),"autenticacion":("ENTIDAD","autenticación","conf"),
 "digito":("ENTIDAD","dígito verificador","conf"),"intercambio":("ENTIDAD","intercambio (interbancario)","conf"),
 "reverso":("ACCION","Acción: reversión de una operación aplicada para dejarla sin efecto (pagos, cargos, transferencias)","conf"),"apoderado":("ENTIDAD","Persona física facultada para operar en representación de una cuenta de persona moral","conf"),"dormidas":("MODIF","cuentas dormidas (inactivas)","conf"),
 "agendadas":("MODIF","Modificador: citas o transacciones programadas con fecha y hora previamente reservadas","conf"),"determina":("ACCION","Acción: calcular y fijar un valor de negocio, típicamente la línea de crédito de tarjeta o el valor UDI","conf"),"telefonico":("MODIF","telefónico","conf"),
 "fusionados":("MODIF","Modificador: clientes o documentos consolidados tras unificar expedientes duplicados","conf"),"movimientos":("ENTIDAD","Cargos y abonos registrados en una cuenta o crédito; base del estado de cuenta y la conciliación","conf"),"ordenes":("ENTIDAD","órdenes","conf"),
 "linea":("ENTIDAD","línea (de crédito)","conf"),"procede":("ACCION","Acción: validar la procedencia o viabilidad de una operación antes de ejecutarla (fusión, aclaración)","conf"),"procesa":("ACCION","Acción: transformar y aplicar el contenido de archivos, tramas o solicitudes al core","conf"),
 "activar":("ACCION","Acción: habilitar un producto, servicio, token o línea de crédito para su uso","conf"),"activa":("ACCION","Acción: habilitar o poner en operación un elemento; también atributo de estatus vigente (cuenta/mensaje activo)","conf"),"masiva":("MODIF","Modificador: procesamiento por lote de múltiples registros en una sola corrida (altas, cargas, cancelaciones)","conf"),
 "salida":("ENTIDAD","Egreso de efectivo o dato producido; par de entrada/salida en caja, o output de un reporte","conf"),"declaracion":("ENTIDAD","declaración","conf"),"corresponsal":("ENTIDAD","Corresponsal bancario: red de puntos de servicio (Coppel) que operan retiros y depósitos con comisión","conf"),
 "producto":("ENTIDAD","Instrumento bancario ofertado (crédito, cuenta, seguro) definido en catálogo","conf"),"promocion":("ENTIDAD","promoción","conf"),"proceso":("ENTIDAD","Corrida batch o flujo operativo con estatus rastreable vía monitor (conciliación, cierre, generación de archivos)","conf"),
 # ── BARRIDO 2026-07-09 — términos investigados en código fuente ──
 "archsdos":("ENTIDAD","Archivos de Saldos — comentario explícito: 'Genera archivos de saldos diarios y mensuales' (bdicheq:gen_archsdos)","conf"),
 "corresp":("ENTIDAD","Corresponsal — corresponsal bancario; red de puntos de servicio no-sucursal regulada por CNBV (bdicheq:sp_corresp_*, sp_generar_acum_corresponsal_mc)","conf"),
 "arr":("ENTIDAD","ARR — producto de ahorro/inversión recurrente (CLABE, interés acumulado, inversión creciente, pago de interés — bdicheq:arr_*)","conf"),
 "dinya":("ENTIDAD","DINYA — sistema/plataforma de remesas domésticas en sucursal; retorna nombre_remitente, sucursal_origen, importe_eviado (bdicnweb:sp_*dinya*)","conf"),
 "sps":("PREFIJO","sps — prefijo alternativo de SP en bdibei (posiblemente 'stored procedure set' o convención local del equipo; vs el 'sp' estándar)","conf"),
 "sif":("ENTIDAD","SIF — canal de estado de cuenta (aclaraciones_edocta_sif, detalle_edocta_sif); procesa aclaraciones de TDC por tarjeta+fecha de emisión","conf"),
 "cnc":("ENTIDAD","CNC — sistema de configuración de planes fijos de Tarjetas Coppel (plazos_fijos, Buen Fin, carga de archivos, stat06 — bditarjeta:sp_cnc_*)","conf"),
 "cpl":("ENTIDAD","CPL — segmento o producto de cliente (sp_dictamina_ctes_cpl, sp_afore_ctes_cpl, sp_situacionespecialcte_cpl — bdinteg)","conf"),
 "mib":("ENTIDAD","MIB — módulo/canal de integración para cheques y tarjeta (cargo_ref_mib, cancelar_activar_cheque_mib — bdicheq + bdibpi)","conf"),
 "cnr":("ENTIDAD","CNR — tipo o formato de consulta al Buró de Crédito para personas físicas (bdiburo:burofisicas_cnr; vcredito_maximo)","conf"),
 "ftc":("ENTIDAD","FTC — módulo de configuración de transferencia de archivos (SFTP/FTP IPs, passwords de proxy, SFTP depósito — bdilide:sp_ftc_*)","conf"),
 # ── BARRIDO 2026-07-09 — términos frecuentes de alta frecuencia ──
 "rep":("ACCION","reporte","conf"),"transfer":("ENTIDAD","transferencia (forma larga de 'trans')","conf"),
 "rem":("ENTIDAD","remesa (forma corta)","conf"),"tarjetas":("ENTIDAD","tarjetas (plural)","conf"),
 "indicadores":("ENTIDAD","Métricas de comportamiento del cliente o producto usadas en cartera, scoring y monitoreo (SPEI)","conf"),"aut":("ACCION","autorización","conf"),
 "buscar":("ACCION","búsqueda/buscar","conf"),"ins":("ACCION","insertar","conf"),
 "ant":("MODIF","anterior","conf"),
 "cuentas":("ENTIDAD","cuentas (plural)","conf"),"hist":("MODIF","histórico/historial","conf"),
 "his":("MODIF","histórico","conf"),"clientes":("ENTIDAD","clientes (plural)","conf"),
 "crd":("ENTIDAD","crédito (abreviación)","conf"),"pagos":("ENTIDAD","pagos (plural)","conf"),
 "concilia":("ACCION","conciliación","conf"),"solicitudes":("ENTIDAD","solicitudes (plural)","conf"),
 "estadisticas":("ENTIDAD","estadísticas","conf"),"creditos":("ENTIDAD","créditos (plural)","conf"),
 "mensajes":("ENTIDAD","Conjunto de avisos o notificaciones al cliente u operador (SMS, estado de cuenta, cartera externa)","conf"),"envios":("ENTIDAD","envíos","conf"),
 "cobranza":("ENTIDAD","Gestión de recuperación de cartera vencida: campañas telefónicas, convenios y marcación","conf"),"operaciones":("ENTIDAD","operaciones (plural)","conf"),
 "batch":("MODIF","proceso batch (por lotes)","conf"),"debito":("ENTIDAD","débito","conf"),
 "canales":("ENTIDAD","canales (de distribución)","conf"),"cobro":("ACCION","Acción: aplicación de un cargo por comisión, interés o servicio, a menudo automático sobre saldo","conf"),
 "correos":("ENTIDAD","correos electrónicos (email)","conf"),"archivos":("ENTIDAD","Ficheros de intercambio cargados o generados para procesos batch (TEF, CCE, AFORE, domiciliación)","conf"),
 "cambio":("ENTIDAD","cambio (de estatus, domicilio, etc.)","conf"),"reproceso":("ACCION","Acción: volver a ejecutar un proceso batch fallido o pendiente (cierre diario, reportes, emergentes)","conf"),
 "portabilidad":("ENTIDAD","portabilidad (de nómina o número)","conf"),"reserva":("ENTIDAD","Reserva preventiva crediticia CNBV: provisión por probabilidad de incumplimiento y severidad de la pérdida","conf"),
 "corte":("ENTIDAD","corte (fecha de corte / período)","conf"),"det":("ENTIDAD","detalle","conf"),
 "dep":("ENTIDAD","depósito","conf"),"movs":("ENTIDAD","movimientos (abreviación)","conf"),
 "sdos":("ENTIDAD","saldos (abreviación)","conf"),"upd":("ACCION","actualiza (update)","conf"),
 "calif":("ENTIDAD","calificación","conf"),"situacion":("ENTIDAD","situación","conf"),
 "retenido":("MODIF","retenido (fondos en retención)","conf"),"tels":("ENTIDAD","teléfonos (plural)","conf"),
 "prospectos":("ENTIDAD","prospectos (nuevos clientes potenciales)","conf"),
 "avatar":("ENTIDAD","avatar (foto de perfil del usuario en app)","conf"),"reg":("ACCION","registro","conf"),
 # ── BARRIDO 2026-07-09 — términos regulatorios / dominio bancario ──
 "sat":("REG","SAT — Servicio de Administración Tributaria (CFDI, ISR, IVA)","conf"),
 "ine":("REG","INE — Instituto Nacional Electoral (validación de identidad del cliente)","conf"),
 "pld":("REG","PLD — Prevención de Lavado de Dinero (AML — obligación CNBV)","conf"),
 "tdd":("ENTIDAD","TDD — Tarjeta de Débito","conf"),
 "cfdi":("REG","CFDI — Comprobante Fiscal Digital por Internet (SAT · factura electrónica)","conf"),
 "factelect":("ENTIDAD","Factura Electrónica / CFDI","conf"),
 "repipab":("ENTIDAD","Reporte IPAB — reporte regulatorio de seguimiento de depósitos (bdibei:sp_repipab_*)","conf"),
 # ── BARRIDO 2026-07-09 — investigación de términos de segundo nivel ──
 "ctamec":("ENTIDAD","Cuenta Mecánica — tipo de cuenta de cheques empresarial para nómina y pagos automáticos (bdicheq:sp_ctamec_*)","conf"),
 "evc":("ENTIDAD","EVC — Evaluación/Cartera a Quebrantar (write-off de cartera vencida; sp_evc_cartera_quebrantar, sp_evc_consexclusionlote — bdicnweb)","conf"),
 "camp":("ENTIDAD","Campaña — campaña de cobranza o crédito (sp_envio_camp_ctes, sp_actvig_camp — bdicobranza + bdicred)","conf"),
 "synmotor":("ENTIDAD","SynMotor — motor de procesamiento de Syndein (empresa externa fintech); gestiona campos, parámetros y WSDL (intercard:sp_synmotor_*)","conf"),
 "credisoluciones":("ENTIDAD","CrediSoluciones — producto/segmento de crédito BanCoppel (sp_carga_ctes_credisoluciones, sp_credisoluciones_crd — bdicred)","conf"),
 "proac":("ENTIDAD","PROAC — producto de cuenta de ahorro con inscripción y ciclo anual (sp_proac_consultarincripcioncuentaproac, sp_proac_calc_proximoanio — bdicheq)","conf"),
 "portanom":("ENTIDAD","Portabilidad de Nómina — portabilidad de domiciliación de nómina entre bancos (CNBV); gestiona solicitudes y archivos (bdicheq:sp_portanom_*)","conf"),
 "ctepr":("ENTIDAD","Cliente Prospecto — cliente potencial aún sin cuenta abierta (sp_catalogoscteprospecto, sp_consdireccionescteprospecto, sp_cancelaperturacteprospecto — bdicnweb)","conf"),
 "ics":("ENTIDAD","ICS — sistema de cuotas/mensualidades de crédito (sp_ics_cuotas, sp_ics_compara_secuencias, sp_ics_genera_control — bdicred)","conf"),
 "bccc":("ENTIDAD","BCCC — formato o protocolo de consulta al Buró de Crédito (bdiburo:sp_reenvio_sols_bccc9; catproducto, catcomentario)","conf"),
 "chq":("ENTIDAD","cheque (abreviación — bdicheq)","conf"),
 "adm":("ACCION","administración/administrar (abreviación de admin)","conf"),
 "canal":("ENTIDAD","canal (de distribución)","conf"),"campana":("ENTIDAD","campaña","conf"),
 "genrep":("ACCION","genera reporte (abreviación genrep)","inf"),
 "conciliachq":("ACCION","conciliación de cheques","inf"),
 "aclaraciones":("ENTIDAD","aclaraciones (proceso de disputas/reclamaciones de cliente)","conf"),
 "pld":("REG","PLD — Prevención de Lavado de Dinero (AML)","conf"),
 # ── BARRIDO 2026-07-09 — NUEVOS TÉRMINOS (barrido de código 2026-07-09) ──
 "dic":("ENTIDAD","[polisemia] Dictamen (bdicnweb:sp_dic_* — decisión crediticia, analista de dictamen, hawk) | Diciembre (columna dic en tablas de series mensuales ene…dic)","conf"),
 "manco":("ENTIDAD","Mancomunidad — cuenta u operación con múltiples titulares autorizados; requiere autorización de todos (bdibei:sp_*_manco_bei; DESCRIPCION: 'Actualiza Status Mancomunidad')","conf"),
 "cce":("ENTIDAD","CCE — Cámara de Compensación Electrónica (CECOBAN/Banxico) — sistema de compensación interbancaria de cheques; SPs: sp_cce_consultar_cheques40/46, chequespresentados (bdicheq)","conf"),
 "ctanvl2":("ENTIDAD","Cuenta Nivel 2 (CNBV Circular Única de Bancos) — categoría regulatoria de cuenta bancaria con KYC; valida documentos digitales y huellas (sp_ctanvl2_*, DoctosCtaNvl2/)","conf"),
 "concreing":("ENTIDAD","Conciliación de Reingresos — proceso de conciliación de tarjetas reingresadas (bditarjeta:sp_concreing_*; gestiona archivos ATM, usuarios, horarios, parámetros)","conf"),
 "bex":("ENTIDAD","BEX — canal o plataforma de Banca Por Internet (bdibpi); gestiona sesiones, preguntas de seguridad, cuentas cap/cred (sp_*_bex, sp_ini_session_bex)","conf"),
 "rcda":("ENTIDAD","RCDA — producto de captación/ahorro (apertura, incremento de saldo, acumulación mensual); gestionado en bdmis (sp_rcda_apert, sp_rcda_acumsdo_mes)","conf"),
 "iccat":("ENTIDAD","ICCAT — canal de atención al cliente en BPI; gestiona solicitudes de entrega y reposición de token, desbloqueo de acceso (bdibpi:sp_iccat_*, sp_*_iccat)","conf"),
 "edocta":("ENTIDAD","Estado de Cuenta — documento periódico de movimientos y saldos; generado como PDF (sp_ctanvl2_generapdf_pba) y enviado por email automático (bdinteg)","conf"),
 "aumlincred":("ACCION","Aumento de Línea de Crédito — proceso de incremento del límite crediticio; 26+ SPs en bdicred (sp_*_aumlincred)","conf"),
 "bei":("ENTIDAD","BEI — Banca En Internet; canal digital principal de BanCoppel; base de datos bdibei con 279+ SPs de operaciones, autenticación, transferencias y mancomunidad","conf"),
 "ipab":("REG","IPAB — Instituto para la Protección al Ahorro Bancario (seguro de depósitos hasta 400,000 UDIs por depositante; Banxico/CNBV)","conf"),
 "club":("ENTIDAD","Club de Protección — producto de seguro grupal BanCoppel; movimientos históricos en bdisac:sac_movimientoshistorial; ventas en sp_rep_vtas_club_proteccion","conf"),
 # ── BARRIDO 2026-07-09 — investigación de tercer nivel (freq ≥ 10 no cubiertos) ──
 "cal":("ENTIDAD","[polisemia] Cálculo (cal_fecha, cal_riesgo_cliente, cal_tradicion — operaciones matemáticas financieras) | Calendario (cal_habil_ant — días hábiles bancarios; bdicheq)","conf"),
 "exp":("MODIF","sufijo Exportar — SP genera/exporta archivo de salida (sp_*_exp: generaarchivocuentasnomina_exp, perfisica_listanegra_exp, reversion_exp)","conf"),
 "com":("ENTIDAD","Comisión bancaria — cobro de comisión sobre cuenta (bdicheq:sp_cobra_com, sp_com_manejo_cta_cobro_*; también en OXXO)","conf"),
 "chi":("ENTIDAD","CHI — formato/protocolo de consulta al Buró de Crédito (bdiburo/bdicred:sp_chi_cre_consulta_sic, sp_chi_cre_layout_sics, sp_chi_cre_result_consulta_sic; SICS = Sociedad de Información Crediticia)","conf"),
 "tar":("ENTIDAD","Tarjeta (abreviación — bdicheq/bdicred: cons_cta_o_tar, mover_his_tar, obtener_cta_con_num_tar)","conf"),
 "compac":("ENTIDAD","Compromisos de Pago en Cobranza — acuerdos/convenios de pago activos o cumplidos el mismo día; historial en cb_compac_his (bdicobranza:sp_archivo_compac, sp_compac_consultacompromisosvigente)","conf"),
 "movhis":("ENTIDAD","Movimientos Históricos — tabla/proceso de historial de movimientos (bdicheq:arrmovhis, borra_movhis; bdicred:carga_movhis_edoctacrd)","conf"),
 "stat06":("ENTIDAD","Stat06 — tipo/código de archivo de carga en procesamiento de tarjetas Coppel (bditarjeta:sp_cnc_cga_stat06; parámetros: ruta, nombre archivo, sistema, layout)","conf"),
 "admtoken":("ENTIDAD","AdmToken — módulo de administración de tokens de autenticación para personas morales (empresas) en BEI; gestiona solicitudes, estados, devoluciones y comentarios (bdibei:sp_*_admtoken_bei)","conf"),
 "generaredoctaeje":("ACCION","Genera Estado de Cuenta Ejecutivo — proceso de generación de EdoCta para cheques/captación; incluye variante con CFDI (bdicheq:sp_generaredoctaeje, sp_generaredoctaeje_factelect)","conf"),
 "edoctacrd":("ENTIDAD","Estado de Cuenta Crédito — documento de movimientos y saldos de crédito; carga de movhis y gestión de aclaraciones (bdicred:carga_movhis_edoctacrd, aclaraciones_edoctacrd_sif)","conf"),
 "monitorsol":("ENTIDAD","Monitor de Solicitudes — sistema de monitoreo de solicitudes de crédito por sucursal/empresa; parámetros: empresa, sucursal, status_solicitud, num_producto (bdicred+bdisolic:envia_monitorsol)","conf"),
 "reversa":("ACCION","Reversión — anula/revierte una operación (bdibei:sp_reversa_solicitudes_bei, sp_reversa_tokenasociados_bei)","conf"),
 "rev":("ACCION","reversión (abreviación de reversa/reverso)","conf"),
 "clon":("ENTIDAD","[polisemia] Clon de SP (réplica funcional para variante de entorno o canal — similar a _pba; bdiburo:burofisicas_clon, bdibpi:sp_consultarctepmempresanet_clon) | Clonación fraudulenta (bdiauditor:sp_pld_chq_addfolio_clon — fraude de clonación de cheques/documentos en PLD)","conf"),
 "regordenctecte":("ACCION","Regresa Orden Cuenta a Cuenta — operación de transferencia/orden entre cuentas propias del cliente (bdicheq:sp_regordenctecte, sp_regordenctecte_bex, sp_regordenctecte_web, sp_regordenctecte_pp)","inf"),
 "ctefisico":("ENTIDAD","Cliente Físico — persona física (tp_persona CHAR(2)); distingue de persona moral; maneja datos de identidad y afiliación (bdibpi+bdinteg:ctefisico, ctefisico_mib*)","conf"),
 "burofisicas":("ENTIDAD","Buró Personas Físicas — consulta al Buró de Crédito para personas físicas (bdiburo:burofisicas_cnr, burofisicas_clon, burofisicas_concilia_clon)","conf"),
 "corrige":("ACCION","corrige — acción de corrección de datos (bdicred:sp_corrige_*)","conf"),
 "auto":("MODIF","automático (proceso automático / batch — sp_*_auto)","conf"),
 "principal":("ENTIDAD","principal — capital principal de deuda / titular principal de cuenta","conf"),
 }

# tokens compuestos que NO deben listarse en el glosario (son atajos de segmentación)
COMPOUND = {
 "recordenpago","reccancelacion","recdevolucion","recextemporanea","aplicaordenpago",
 "cargamovimiento","cargamanual","conssaldosdiarios","cilocconsulta","productotransaccion",
 "generafolionomina","confirmasms","abonoinmediato","datosdia","devforzada","folionomina",
 "consutacat","generafechpagoreestructura","consprodcte","ctasinactivas","conscedulas","cedulacontable",
}

KEYS = sorted(CAT.keys(), key=len, reverse=True)  # longest-match

def segment(tok):
    """Segmenta un token pegado en subtérminos conocidos (greedy longest-match)."""
    out, i, t = [], 0, tok.lower()
    while i < len(t):
        m = next((k for k in KEYS if t.startswith(k, i)), None)
        if m:
            out.append(m); i += len(m)
        else:
            j = i + 1
            while j < len(t) and not any(t.startswith(k, j) for k in KEYS):
                j += 1
            out.append("?" + t[i:j]); i = j
    return out

def tokenize(name):
    r = []
    for p in name.split("_"):
        if p:
            r += segment(p)
    return r

def compose(name):
    """Compone el objetivo de negocio. Devuelve (frase, flag, estado).
    estado: 'conf' | 'partial' (algún inf/desconocido) | 'gap' (ambiguo SME)."""
    toks = tokenize(name)
    acc, ent, mod, reg, amb, unk = [], [], [], [], [], []
    has_inf = False
    for t in toks:
        if t.startswith("?"):
            frag = t[1:]
            if len(frag) > 2:            # ignora fragmentos de 1-2 letras (ruido)
                unk.append(frag)
            continue
        c = CAT.get(t)
        if not c:
            continue
        cat, mean, st = c
        if st == "inf":
            has_inf = True
        if cat == "PREFIJO":
            continue
        elif cat == "ACCION":
            acc.append(mean)
        elif cat == "ENTIDAD":
            ent.append(mean)
        elif cat == "MODIF":
            mod.append(mean)
        elif cat == "REG":
            reg.append(mean)
        elif cat == "AMBIGUO":
            amb.append(mean);
            if st == "gap":
                has_inf = True
    # de-dup preservando orden
    def dedup(xs):
        seen, o = set(), []
        for x in xs:
            if x not in seen:
                seen.add(x); o.append(x)
        return o
    acc, ent, mod, reg = dedup(acc), dedup(ent), dedup(mod), dedup(reg)
    # lenguaje natural: 1er sinónimo, sin paréntesis internos; unir con comas + "y"
    import re as _re
    def _clean(x):
        x = x.split(" / ")[0]
        if "(" in x:
            x = x.split("(")[0]
        # Eliminar prefijo "abbr — " (abreviatura corta de 1-8 chars)
        # Ej: "mc — Mesa de Control" → "Mesa de Control"
        x = _re.sub(r'^\s*\S{1,8}\s*—\s*', '', x)
        # Eliminar descripción tras em-dash para nombres multi-palabra
        # Ej: "Bancomer Transfer Services — canal BBVA..." → "Bancomer Transfer Services"
        if ' — ' in x:
            x = x.split(' — ')[0]
        return x.strip()
    def _nat(items):
        items = [i for i in items if i]
        if len(items) <= 1:
            return "".join(items)
        return ", ".join(items[:-1]) + " y " + items[-1]
    ent_c = dedup([_clean(e) for e in ent])
    mod_c = dedup([_clean(mm) for mm in mod if _clean(mm) and _clean(mm) != "por"])
    frase = _clean(acc[0]) if acc else ""
    if ent_c:
        frase = (frase + " " if frase else "") + _nat(ent_c)
    if mod_c:
        frase += " (" + ", ".join(mod_c) + ")"
    if reg:
        frase += " · " + " · ".join(_clean(r) for r in reg)
    phrase = frase.strip()
    flag = ""
    if unk: flag += f" [¿{','.join(unk)}?]"
    sme = any("CONSULTAR" in a or "Art.61" in a for a in (amb + reg))
    if sme: flag += " [SME]"
    estado = "gap" if sme else ("partial" if (unk or has_inf) else "conf")
    return (phrase or name), flag, estado
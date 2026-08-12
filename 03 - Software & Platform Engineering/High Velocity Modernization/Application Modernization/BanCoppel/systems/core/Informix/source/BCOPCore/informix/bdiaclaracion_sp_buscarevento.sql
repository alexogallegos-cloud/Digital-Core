CREATE PROCEDURE "informix".sp_buscarevento(
                        pTipoProducto INTEGER,
                        pOrigenEvento INTEGER,
						pEstatusTarjeta CHAR(3))

	RETURNING
		CHAR(3) 			as cCodRet,
		INTEGER 			as pky_tipo_evento,
		SMALLINT			as capturamanual,
		CHAR(50)			as descripcion,
		SMALLINT			as diferenciaimportes,
		CHAR(4)				as grupo_doc,
		CHAR(50)			as nombre,
		INTEGER				as fky_tipo_transaccion,
		MONEY				as costo,
		SMALLINT			as acepta_cargos_recurrentes,
		CHAR(2)				as motivobloqueodebito,
		INTEGER				as tipobloqueocredito,
		CHAR(2)				as motivobloqueocredito,
		INTEGER				as tipobloqueodebito,
		CHAR(3)				as statusTarjeta,
		CHAR(1)				as validacion_cancelacion_automatica,
		CHAR(1)				as es_compra_a_meses;

	--Variables--
		DEFINE sql_err 						INTEGER;
		DEFINE v_cod_ret 					CHAR(3);
		DEFINE v_pky_tipo_evento  			INTEGER;
		DEFINE v_capturamanual	 			SMALLINT;
		DEFINE v_descripcion  				VARCHAR(50);
		DEFINE v_diferenciaimportes  		SMALLINT;
		DEFINE v_grupo_doc  				VARCHAR(4);
		DEFINE v_nombre  					VARCHAR(50);
		DEFINE v_fky_tipo_transaccion  		INTEGER;
		DEFINE v_costo 						MONEY;
		DEFINE v_acepta_cargos_recurrentes	SMALLINT;
		DEFINE v_motivobloqueodebito  		CHAR(2);
		DEFINE v_tipobloqueocredito 		INTEGER;
		DEFINE v_motivobloqueocredito 		CHAR(2);
		DEFINE v_tipobloqueodebito 			INTEGER;
		DEFINE v_statustarjeta		 		CHAR(3);
		DEFINE v_indroboextravio 			SMALLINT;
		DEFINE v_contador_eventos 			INTEGER;
		DEFINE v_validacion_cancelacion_automatica CHAR(1);
		DEFINE v_es_compra_a_meses 			CHAR(1);

		LET v_cod_ret 					= "000";
		LET v_pky_tipo_evento 			= "";
		LET v_capturamanual	 			= "";
		LET v_descripcion 				= "";
		LET v_diferenciaimportes		= "";
		LET v_grupo_doc					= "";
		LET v_nombre					= "";
		LET v_fky_tipo_transaccion		= "";
		LET v_costo						= "";
		LET v_acepta_cargos_recurrentes	= "";
		LET v_motivobloqueodebito		= "";
		LET v_tipobloqueocredito		= "";
		LET v_motivobloqueocredito		= "";
		LET v_tipobloqueodebito 		= "";
		LET v_statustarjeta				= "";
		LET v_indroboextravio			= 0;
		LET v_contador_eventos 			= 0;
		LET v_validacion_cancelacion_automatica = "";
		LET v_es_compra_a_meses			= "";


		BEGIN
		  ON EXCEPTION SET sql_err
		     IF sql_err <> 0 THEN
		   	     LET v_cod_ret = sql_err;
			     RETURN v_cod_ret,v_pky_tipo_evento,v_capturamanual,v_descripcion,v_diferenciaimportes,v_grupo_doc,v_nombre,v_fky_tipo_transaccion,
			     		v_costo,v_acepta_cargos_recurrentes,v_motivobloqueodebito,v_tipobloqueocredito,v_motivobloqueocredito,v_tipobloqueodebito,
						v_statustarjeta, v_validacion_cancelacion_automatica, v_es_compra_a_meses;
		     END IF;
		   END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_buscarevento.out';
		--TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT indicador_robo_extravio
		INTO v_indroboextravio
		FROM acl_origen_evento
		WHERE pky_origen_evento = pOrigenEvento;
		
		IF v_indroboextravio = 1 THEN
			SELECT COUNT(*) 
			INTO v_contador_eventos
			FROM acl_tipo_evento tipoeve
			INNER JOIN acl_tipo_prod_tipo_evento tipoproduceve on tipoeve.pky_tipo_evento=tipoproduceve.fky_tipo_evento
			INNER JOIN acl_tipo_producto tipoproduc on tipoproduceve.fky_tipo_producto=tipoproduc.pky_tipo_producto
			WHERE tipoeve.fky_origen_evento = pOrigenEvento
			AND tipoproduc.pky_tipo_producto=pTipoProducto
				AND tipoeve.status_tarjeta = pEstatusTarjeta;
				
		
			IF  v_contador_eventos > 0 THEN
				
				SET ISOLATION TO DIRTY READ;
				
				FOREACH
					select tipoeve.pky_tipo_evento, tipoeve.capturamanual, tipoeve.descripcion, tipoeve.diferenciaimportes, tipoeve.grupo_doc, tipoeve.nombre,
						tipoeve.fky_tipo_transaccion, tipoeve.costo, tipoeve.acepta_cargos_recurrentes, tipoeve.motivobloqueodebito, tipoeve.tipobloqueocredito,
						tipoeve.motivobloqueocredito, tipoeve.tipobloqueodebito, tipoeve.status_tarjeta, tipoeve.validacion_can_msi, tipoeve.compra_meses
						INTO v_pky_tipo_evento,v_capturamanual,v_descripcion,v_diferenciaimportes,v_grupo_doc,v_nombre,v_fky_tipo_transaccion,
							v_costo,v_acepta_cargos_recurrentes,v_motivobloqueodebito,v_tipobloqueocredito,v_motivobloqueocredito,v_tipobloqueodebito,v_statustarjeta, v_validacion_cancelacion_automatica, v_es_compra_a_meses
						from acl_tipo_evento tipoeve
						inner join acl_origen_evento origeneve on tipoeve.fky_origen_evento=origeneve.pky_origen_evento
						inner join acl_tipo_prod_tipo_evento tipoproduceve on tipoeve.pky_tipo_evento=tipoproduceve.fky_tipo_evento
						inner join acl_tipo_producto tipoproduc on tipoproduceve.fky_tipo_producto=tipoproduc.pky_tipo_producto
						where tipoeve.activo=1 and
						origeneve.pky_origen_evento=pOrigenEvento and
						tipoproduc.pky_tipo_producto=pTipoProducto and
						tipoeve.status_tarjeta=pEstatusTarjeta
						order by tipoeve.descripcion asc

					RETURN
						v_cod_ret,
						v_pky_tipo_evento,
						v_capturamanual,
						v_descripcion,
						v_diferenciaimportes,
						v_grupo_doc,
						v_nombre,
						v_fky_tipo_transaccion,
						v_costo,
						v_acepta_cargos_recurrentes,
						v_motivobloqueodebito,
						v_tipobloqueocredito,
						v_motivobloqueocredito,
						v_tipobloqueodebito,
						v_statustarjeta,
						v_validacion_cancelacion_automatica,
						v_es_compra_a_meses
					WITH RESUME;
				END FOREACH;
				
			ELSE
				
				SET ISOLATION TO DIRTY READ;
			
				FOREACH
					select tipoeve.pky_tipo_evento, tipoeve.capturamanual, tipoeve.descripcion, tipoeve.diferenciaimportes, tipoeve.grupo_doc, tipoeve.nombre,
						tipoeve.fky_tipo_transaccion, tipoeve.costo, tipoeve.acepta_cargos_recurrentes, tipoeve.motivobloqueodebito, tipoeve.tipobloqueocredito,
						tipoeve.motivobloqueocredito, tipoeve.tipobloqueodebito, tipoeve.status_tarjeta, tipoeve.validacion_can_msi, tipoeve.compra_meses
						INTO v_pky_tipo_evento,v_capturamanual,v_descripcion,v_diferenciaimportes,v_grupo_doc,v_nombre,v_fky_tipo_transaccion,
							v_costo,v_acepta_cargos_recurrentes,v_motivobloqueodebito,v_tipobloqueocredito,v_motivobloqueocredito,v_tipobloqueodebito,v_statustarjeta, v_validacion_cancelacion_automatica, v_es_compra_a_meses
						from acl_tipo_evento tipoeve
						inner join acl_origen_evento origeneve on tipoeve.fky_origen_evento=origeneve.pky_origen_evento
						inner join acl_tipo_prod_tipo_evento tipoproduceve on tipoeve.pky_tipo_evento=tipoproduceve.fky_tipo_evento
						inner join acl_tipo_producto tipoproduc on tipoproduceve.fky_tipo_producto=tipoproduc.pky_tipo_producto
						where tipoeve.activo=1 and
						origeneve.pky_origen_evento=pOrigenEvento and
						tipoproduc.pky_tipo_producto=pTipoProducto
						order by tipoeve.descripcion asc
			
					RETURN
						v_cod_ret,
						v_pky_tipo_evento,
						v_capturamanual,
						v_descripcion,
						v_diferenciaimportes,
						v_grupo_doc,
						v_nombre,
						v_fky_tipo_transaccion,
						v_costo,
						v_acepta_cargos_recurrentes,
						v_motivobloqueodebito,
						v_tipobloqueocredito,
						v_motivobloqueocredito,
						v_tipobloqueodebito,
						v_statustarjeta,
						v_validacion_cancelacion_automatica,
						v_es_compra_a_meses
					WITH RESUME;
				END FOREACH;
			
			END IF;
			
		ELSE
			
			SET ISOLATION TO DIRTY READ;
			
			FOREACH
					select tipoeve.pky_tipo_evento, tipoeve.capturamanual, tipoeve.descripcion, tipoeve.diferenciaimportes, tipoeve.grupo_doc, tipoeve.nombre,
						tipoeve.fky_tipo_transaccion, tipoeve.costo, tipoeve.acepta_cargos_recurrentes, tipoeve.motivobloqueodebito, tipoeve.tipobloqueocredito,
						tipoeve.motivobloqueocredito, tipoeve.tipobloqueodebito, tipoeve.status_tarjeta, tipoeve.validacion_can_msi, tipoeve.compra_meses
						INTO v_pky_tipo_evento,v_capturamanual,v_descripcion,v_diferenciaimportes,v_grupo_doc,v_nombre,v_fky_tipo_transaccion,
							v_costo,v_acepta_cargos_recurrentes,v_motivobloqueodebito,v_tipobloqueocredito,v_motivobloqueocredito,v_tipobloqueodebito,v_statustarjeta, v_validacion_cancelacion_automatica, v_es_compra_a_meses
						from acl_tipo_evento tipoeve
						inner join acl_origen_evento origeneve on tipoeve.fky_origen_evento=origeneve.pky_origen_evento
						inner join acl_tipo_prod_tipo_evento tipoproduceve on tipoeve.pky_tipo_evento=tipoproduceve.fky_tipo_evento
						inner join acl_tipo_producto tipoproduc on tipoproduceve.fky_tipo_producto=tipoproduc.pky_tipo_producto
						where tipoeve.activo=1 and
						origeneve.pky_origen_evento=pOrigenEvento and
						tipoproduc.pky_tipo_producto=pTipoProducto
						order by tipoeve.descripcion asc
			
					RETURN
						v_cod_ret,
						v_pky_tipo_evento,
						v_capturamanual,
						v_descripcion,
						v_diferenciaimportes,
						v_grupo_doc,
						v_nombre,
						v_fky_tipo_transaccion,
						v_costo,
						v_acepta_cargos_recurrentes,
						v_motivobloqueodebito,
						v_tipobloqueocredito,
						v_motivobloqueocredito,
						v_tipobloqueodebito,
						v_statustarjeta,
						v_validacion_cancelacion_automatica,
						v_es_compra_a_meses
					WITH RESUME;
				END FOREACH;
		
		END IF;

		END;
END PROCEDURE
DOCUMENT
'Sp sp_buscarevento',
'Sistema: Aclaraciones',
'AUTOR : Root',
'Coordinador:Norberto Corona Berruecos',
'FECHA : 05/Junio/2018',
'VERSION: 1.0.0',
'AUTOR: Rodolfo Conde Flores',
'FECHA: 16/10/2019',
'DESCRIPCION: Se modifica procedimiento para retornar nuevo campo estatus de tarjeta.',
'BD    :  bdiaclaracion',
'AUTOR: Juan RomÃ?Â¡n Toledo',
'FECHA: 09/12/2019',
'DESCRIPCION: Se modifica procedimiento para retornar tipos evento por estatus tarjeta existente.',
'BD    :  bdiaclaracion';

CREATE PROCEDURE "informix".sp_busca_cte_domiciliacion(
	bandera CHAR(5),
	eNumeroCliente CHAR(20),
	eNumeroTarjeta CHAR(20),
	eNumeroCuenta CHAR(20),
	eEmpresa CHAR(3),
	eTelefonoTransfer CHAR(20),
	ePrimerNombre CHAR(30),
	eSegundoNombre CHAR(30),
	ePrimerApellido CHAR(30),
	eSegundoApellido CHAR(30),
	eTelefonoCorreo CHAR(5),
	eConsultaDatosActual INTEGER,
	eNumEmpleado CHAR(12),
	eClienteTelefonoCelular CHAR(20),
	eClienteCorreoElectronico CHAR(100),
	eFechaInicial DATE,
	eFechaFinal DATE,
	eMonto money(16,2),
	eNumeroTransacciones lvarchar,
	--eNumeroTransacciones LIST(CHAR(4) NOT NULL);
	eFolioSuc CHAR(20),
	eOrigenEvento INTEGER,
	eArchivoInternacional CHAR(30),
	eArchivoNacional CHAR(30),
	eSkip INTEGER,
	opc1 CHAR(30),
	opc2 CHAR(30),
	opc3 CHAR(30),
	opc4 CHAR(30),
	opc5 CHAR(30))

RETURNING 

	CHAR(5)   AS sCodigoRetorno, 
	CHAR(100) AS sCodigoDescripcion,
	CHAR(10)  AS sNumeroRegistros,
	CHAR(20)  AS sNumeroCliente,
	CHAR(30)  AS sPrimerNombre,
	CHAR(30)  AS sSegundoNombre,
	CHAR(30)  AS sPrimerApellido,
	CHAR(30)  AS sSegundoApellido,
	CHAR(6)   AS sNumeroProducto,
	CHAR(60)  AS sDescripcionProducto,
	CHAR(20)  AS sNumeroCuenta,
	CHAR(20)  AS sNumeroTarjeta,
	CHAR(3)   AS sStatusTarjeta,
	CHAR(20)  AS sTelefonoTransfer,
	CHAR(30)  AS sNumeroCuentaInversion,
	CHAR(30)  AS sNumeroCuentaTransfer,
	CHAR(30)  AS sNumeroClienteTransfer,
	CHAR(20)  AS sTelefonoCasa,
	CHAR(20)  AS sTelefonoCelular,
	CHAR(30)  AS sCompaniaCelular,
	INTEGER   AS sIdCompaniaCelular,
	CHAR(100) AS sCorreoElectronico,
	DATE      AS sFechaMovimiento,
	DATETIME HOUR to FRACTION(3) AS sHoraMovimiento,
	MONEY(16,2) AS sMonto,
	CHAR(20)  AS sFolioSuc,
	CHAR(40)  AS sReferencia,
	CHAR(30)  AS sNombreSucursal,
	CHAR(5)   AS sNumeroSucursal,
	CHAR(5)   AS sTransaccion,
	CHAR(50)  AS sTranDescripcion,
	CHAR(10)  AS sActivo,
	CHAR(10)  AS sTipoMovimiento,
	CHAR(10)  AS sMovimientoDuplicado,
	CHAR(23)  AS sReferencia23,
	BOOLEAN   AS sReversado,
	CHAR(40)  AS sReferenciaComercio,
	DATE      AS sFechaConsumo,
	DATETIME HOUR to FRACTION(3) AS sHoraConsumo,
	CHAR(5)   AS sModoEntrada,
	CHAR(5)   AS sSecuenciaFolio,
	CHAR(30)  AS ret1,
	CHAR(30)  AS ret2,
	CHAR(30)  AS ret3,
	CHAR(30)  AS ret4,
	CHAR(30)  AS ret5;

--****************************************************************************************************
-- DESCRIPCION:  SP PRINCIPAL DE BUSQUEDA DE CLIENTES Y MOVIMIENTOS PARA CANCELACION Y OBJECION DE DOMICILIACIONES POR EL BUS.
-- FECHA : 22/07/2022
-- BD: Bdiaclaracion
-- SISTEMA : Aclaraciones
--****************************************************************************************************

/*  DEFINICION DE VARIABLES */

	-- DATOS SALIDA
	DEFINE sCodigoRetorno CHAR(5);
	DEFINE sCodigoDescripcion CHAR(100);
	DEFINE sNumeroRegistros CHAR(10);
	DEFINE sNumeroCliente CHAR(20);
	DEFINE sPrimerNombre CHAR(30);
	DEFINE sSegundoNombre CHAR(30);
	DEFINE sPrimerApellido CHAR(30);
	DEFINE sSegundoApellido CHAR(30);
	DEFINE sNumeroProducto CHAR(6);
	DEFINE sDescripcionProducto CHAR(60);
	DEFINE sNumeroCuenta CHAR(20);
	DEFINE sNumeroTarjeta CHAR(20);
	DEFINE sStatusTarjeta CHAR(3);
	DEFINE sTelefonoTransfer CHAR(20);
	DEFINE sNumeroCuentaInversion CHAR(30);
	DEFINE sNumeroCuentaTransfer CHAR(30);
	DEFINE sNumeroClienteTransfer CHAR(30);
	DEFINE sTelefonoCasa CHAR(20);
	DEFINE sTelefonoCelular CHAR(20);
	DEFINE sCompaniaCelular CHAR(30);
	DEFINE sIdCompaniaCelular INTEGER;
	DEFINE sCorreoElectronico CHAR(100);
	DEFINE sFechaMovimiento DATE;
	DEFINE sHoraMovimiento DATETIME HOUR to FRACTION(3);
	DEFINE sMonto MONEY(16,2);
	DEFINE sFolioSuc CHAR(20);
	DEFINE sReferencia CHAR(40);
	DEFINE sNombreSucursal CHAR(30);
	DEFINE sNumeroSucursal CHAR(5);
	DEFINE sTransaccion CHAR(5);
	DEFINE sTranDescripcion CHAR(50);
	DEFINE sActivo CHAR(10);
	DEFINE sTipoMovimiento CHAR(10);
	DEFINE sMovimientoDuplicado CHAR(10);
	DEFINE sReferencia23 CHAR(23);
	DEFINE sReversado BOOLEAN;
	DEFINE sReferenciaComercio CHAR(40);
	DEFINE sFechaConsumo DATE;
	DEFINE sHoraConsumo DATETIME HOUR to FRACTION(3);
	DEFINE sModoEntrada CHAR(5);
	DEFINE sSecuenciaFolio CHAR(5);
	DEFINE ret1 CHAR(30);
	DEFINE ret2 CHAR(30);
	DEFINE ret3 CHAR(30);
	DEFINE ret4 CHAR(30);
	DEFINE ret5 CHAR(30);
	DEFINE iSqlErr INTEGER ;
	DEFINE reversado CHAR(30);
	
	
	

	/* INICIALIZACION DE VARIABLES */
	
	LET sCodigoRetorno = '00000';
	LET sCodigoDescripcion = 'Proceso Exitoso.';
	LET sNumeroRegistros = '';
	LET sNumeroCliente = '';
	LET sPrimerNombre = '';
	LET sSegundoNombre = '';
	LET sPrimerApellido = '';
	LET sSegundoApellido = '';
	LET sNumeroProducto = '';
	LET sDescripcionProducto = '';
	LET sNumeroCuenta = '';
	LET sNumeroTarjeta = '';
	LET sStatusTarjeta = '';
	LET sTelefonoTransfer = '';
	LET sNumeroCuentaInversion = '';
	LET sNumeroCuentaTransfer = '';
	LET sNumeroClienteTransfer = '';
	LET sTelefonoCasa = '';
	LET sTelefonoCelular = '';
	LET sCompaniaCelular = '';
	LET sIdCompaniaCelular = '';
	LET sCorreoElectronico = '';
	LET sFechaMovimiento = '';
	LET sHoraMovimiento = ''; 
	LET sMonto = '';
	LET sFolioSuc = '';
	LET sReferencia = '';
	LET sNombreSucursal = '';
	LET sNumeroSucursal = '';
	LET sTransaccion = '';
	LET sTranDescripcion = '';
	LET sActivo = '';
	LET sTipoMovimiento = '';
	LET sMovimientoDuplicado = '';
	LET sReferencia23 = '';
	LET sReversado = 'f';
	LET sReferenciaComercio = '';
	LET sFechaConsumo  = '';
	LET sHoraConsumo = '';
	LET sModoEntrada = '';
	LET sSecuenciaFolio = '';
	LET ret1 = '';
	LET ret2 = '';
	LET ret3 = '';
	LET ret4 = '';
	LET ret5 = '';
	LET iSqlErr = 0;
	LET reversado = '';
	
	
BEGIN

	--Manejo de excepciones (errores)
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET sCodigoRetorno = iSqlErr;
			LET sCodigoDescripcion = 'ERROR NO CONTROLADO(' || iSqlErr || ')';
			
			INSERT INTO bdidomi:"informix".dom_errores(fecha_error, hora_error, cod_error, nombre_arch, sp_llamado, mensaje_error, user_insert, fecha_insert)
            VALUES(EXTEND(CURRENT::DATE, YEAR to SECOND), EXTEND(CURRENT::DATE, YEAR to SECOND)+10 UNITS HOUR+42 UNITS MINUTE+29 UNITS SECOND,sCodigoRetorno,'', 'bdiaclaracion:sp_busca_cte_domiciliacion', 'OBTENER MENSAJES CODIGO DE ERROR DESCONOCIDO', 'sysdomi ', EXTEND(CURRENT::DATE, YEAR to SECOND));

			
			RETURN sCodigoRetorno, sCodigoDescripcion, sNumeroRegistros, sNumeroCliente, sPrimerNombre, sSegundoNombre, sPrimerApellido, sSegundoApellido, sNumeroProducto, sDescripcionProducto, sNumeroCuenta,           
		    sNumeroTarjeta, sStatusTarjeta, sTelefonoTransfer, sNumeroCuentaInversion, sNumeroCuentaTransfer, sNumeroClienteTransfer, sTelefonoCasa, sTelefonoCelular, sCompaniaCelular, sIdCompaniaCelular,      
		    sCorreoElectronico, sFechaMovimiento, sHoraMovimiento, sMonto, sFolioSuc, sReferencia, sNombreSucursal, sNumeroSucursal, sTransaccion, sTranDescripcion, sActivo, sTipoMovimiento, sMovimientoDuplicado,    
		    sReferencia23, sReversado, sReferenciaComercio, sFechaConsumo, sHoraConsumo, sModoEntrada, sSecuenciaFolio, ret1, ret2, ret3, ret4, ret5;
		END IF;
	END EXCEPTION; 
			
	--SET DEBUG FILE TO '/RESPALDOSNEW/enrique/sp_busca_cte_domiciliacion.out';
	--TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	
	IF bandera =  "1" THEN
	
		EXECUTE PROCEDURE bdinteg:sp_buscarclientespornumero(eNumeroCliente) INTO sNumeroCliente, sPrimerNombre,sSegundoNombre, sPrimerApellido, sSegundoApellido;
		
		RETURN sCodigoRetorno, sCodigoDescripcion, sNumeroRegistros, sNumeroCliente, sPrimerNombre, sSegundoNombre, sPrimerApellido, sSegundoApellido, sNumeroProducto, sDescripcionProducto, sNumeroCuenta,           
		   sNumeroTarjeta, sStatusTarjeta, sTelefonoTransfer, sNumeroCuentaInversion, sNumeroCuentaTransfer, sNumeroClienteTransfer, sTelefonoCasa, sTelefonoCelular, sCompaniaCelular, sIdCompaniaCelular,      
		   sCorreoElectronico, sFechaMovimiento, sHoraMovimiento, sMonto, sFolioSuc, sReferencia, sNombreSucursal, sNumeroSucursal, sTransaccion, sTranDescripcion, sActivo, sTipoMovimiento, sMovimientoDuplicado,    
		   sReferencia23, sReversado, sReferenciaComercio, sFechaConsumo, sHoraConsumo, sModoEntrada, sSecuenciaFolio, ret1, ret2, ret3, ret4, ret5;
		   
	ELIF (bandera = "2") THEN
	
		EXECUTE PROCEDURE bdinteg:sp_buscarclientesportarjeta(eNumeroTarjeta) INTO sNumeroCliente, sPrimerNombre, sSegundoNombre, sPrimerApellido, sSegundoApellido;
		
		RETURN sCodigoRetorno, sCodigoDescripcion, sNumeroRegistros, sNumeroCliente, sPrimerNombre, sSegundoNombre, sPrimerApellido, sSegundoApellido, sNumeroProducto, sDescripcionProducto, sNumeroCuenta,           
		   sNumeroTarjeta, sStatusTarjeta, sTelefonoTransfer, sNumeroCuentaInversion, sNumeroCuentaTransfer, sNumeroClienteTransfer, sTelefonoCasa, sTelefonoCelular, sCompaniaCelular, sIdCompaniaCelular,      
		   sCorreoElectronico, sFechaMovimiento, sHoraMovimiento, sMonto, sFolioSuc, sReferencia, sNombreSucursal, sNumeroSucursal, sTransaccion, sTranDescripcion, sActivo, sTipoMovimiento, sMovimientoDuplicado,    
		   sReferencia23, sReversado, sReferenciaComercio, sFechaConsumo, sHoraConsumo, sModoEntrada, sSecuenciaFolio, ret1, ret2, ret3, ret4, ret5;
		   
	ELIF (bandera = "3") THEN
	
		EXECUTE PROCEDURE bdinteg:sp_buscarclientesporcuenta(eNumeroCuenta, eEmpresa) INTO sNumeroCliente, sPrimerNombre, sSegundoNombre, sPrimerApellido, sSegundoApellido;
		
		RETURN sCodigoRetorno, sCodigoDescripcion, sNumeroRegistros, sNumeroCliente, sPrimerNombre, sSegundoNombre, sPrimerApellido, sSegundoApellido, sNumeroProducto, sDescripcionProducto, sNumeroCuenta,           
		   sNumeroTarjeta, sStatusTarjeta, sTelefonoTransfer, sNumeroCuentaInversion, sNumeroCuentaTransfer, sNumeroClienteTransfer, sTelefonoCasa, sTelefonoCelular, sCompaniaCelular, sIdCompaniaCelular,      
		   sCorreoElectronico, sFechaMovimiento, sHoraMovimiento, sMonto, sFolioSuc, sReferencia, sNombreSucursal, sNumeroSucursal, sTransaccion, sTranDescripcion, sActivo, sTipoMovimiento, sMovimientoDuplicado,    
		   sReferencia23, sReversado, sReferenciaComercio, sFechaConsumo, sHoraConsumo, sModoEntrada, sSecuenciaFolio, ret1, ret2, ret3, ret4, ret5;
		   
	ELIF (bandera = "4") THEN  --Validar si no es necesario todos los parametros
		
		FOREACH
			
			EXECUTE PROCEDURE bdinteg:sp_buscarclientespornombre(eEmpresa,ePrimerNombre,eSegundoNombre,ePrimerApellido,eSegundoApellido,'', '','',eSkip) INTO sNumeroCliente, sPrimerNombre, sSegundoNombre, sPrimerApellido, sSegundoApellido
		
			RETURN sCodigoRetorno, sCodigoDescripcion, sNumeroRegistros, sNumeroCliente, sPrimerNombre, sSegundoNombre, sPrimerApellido, sSegundoApellido, sNumeroProducto, sDescripcionProducto, sNumeroCuenta,           
				   sNumeroTarjeta, sStatusTarjeta, sTelefonoTransfer, sNumeroCuentaInversion, sNumeroCuentaTransfer, sNumeroClienteTransfer, sTelefonoCasa, sTelefonoCelular, sCompaniaCelular, sIdCompaniaCelular,      
				   sCorreoElectronico, sFechaMovimiento, sHoraMovimiento, sMonto, sFolioSuc, sReferencia, sNombreSucursal, sNumeroSucursal, sTransaccion, sTranDescripcion, sActivo, sTipoMovimiento, sMovimientoDuplicado,    
				   sReferencia23, sReversado, sReferenciaComercio, sFechaConsumo, sHoraConsumo, sModoEntrada, sSecuenciaFolio, ret1, ret2, ret3, ret4, ret5 WITH RESUME;
			
		END FOREACH;
	
	ELIF (bandera = "5") THEN --Para este caso el numero de cuenta es el numero de credito de la tabla sd_maecred	
		
		FOREACH
			
			EXECUTE PROCEDURE bdinteg:sp_busca_producto_cred_cuenta(eNumeroCuenta,eSkip,eEmpresa) INTO sNumeroProducto, sDescripcionProducto, sNumeroCuenta, sNumeroTarjeta, sStatusTarjeta
			
			RETURN sCodigoRetorno, sCodigoDescripcion, sNumeroRegistros, sNumeroCliente, sPrimerNombre, sSegundoNombre, sPrimerApellido, sSegundoApellido, sNumeroProducto, sDescripcionProducto, sNumeroCuenta,           
				   sNumeroTarjeta, sStatusTarjeta, sTelefonoTransfer, sNumeroCuentaInversion, sNumeroCuentaTransfer, sNumeroClienteTransfer, sTelefonoCasa, sTelefonoCelular, sCompaniaCelular, sIdCompaniaCelular,      
				   sCorreoElectronico, sFechaMovimiento, sHoraMovimiento, sMonto, sFolioSuc, sReferencia, sNombreSucursal, sNumeroSucursal, sTransaccion, sTranDescripcion, sActivo, sTipoMovimiento, sMovimientoDuplicado,    
				   sReferencia23, sReversado, sReferenciaComercio, sFechaConsumo, sHoraConsumo, sModoEntrada, sSecuenciaFolio, ret1, ret2, ret3, ret4, ret5 WITH RESUME;
		
		END FOREACH;
	
	ELIF (bandera = "6") THEN
		
		EXECUTE PROCEDURE bdinteg:sp_busca_producto_cred_tarjeta(eNumeroTarjeta,eEmpresa) INTO sNumeroProducto, sDescripcionProducto, sNumeroCuenta, sNumeroTarjeta, sStatusTarjeta;
	
		RETURN sCodigoRetorno, sCodigoDescripcion, sNumeroRegistros, sNumeroCliente, sPrimerNombre, sSegundoNombre, sPrimerApellido, sSegundoApellido, sNumeroProducto, sDescripcionProducto, sNumeroCuenta,           
		   sNumeroTarjeta, sStatusTarjeta, sTelefonoTransfer, sNumeroCuentaInversion, sNumeroCuentaTransfer, sNumeroClienteTransfer, sTelefonoCasa, sTelefonoCelular, sCompaniaCelular, sIdCompaniaCelular,      
		   sCorreoElectronico, sFechaMovimiento, sHoraMovimiento, sMonto, sFolioSuc, sReferencia, sNombreSucursal, sNumeroSucursal, sTransaccion, sTranDescripcion, sActivo, sTipoMovimiento, sMovimientoDuplicado,    
		   sReferencia23, sReversado, sReferenciaComercio, sFechaConsumo, sHoraConsumo, sModoEntrada, sSecuenciaFolio, ret1, ret2, ret3, ret4, ret5;
		   
	ELIF (bandera = "7") THEN
		
		FOREACH
			
			EXECUTE PROCEDURE bdinteg:sp_busca_producto_transfer_telefono(eTelefonoTransfer,eSkip) INTO sNumeroProducto, sDescripcionProducto, sNumeroCuenta, sNumeroTarjeta, sTelefonoTransfer, sNumeroClienteTransfer, sStatusTarjeta
			
			RETURN sCodigoRetorno, sCodigoDescripcion, sNumeroRegistros, sNumeroCliente, sPrimerNombre, sSegundoNombre, sPrimerApellido, sSegundoApellido, sNumeroProducto, sDescripcionProducto, sNumeroCuenta,           
				   sNumeroTarjeta, sStatusTarjeta, sTelefonoTransfer, sNumeroCuentaInversion, sNumeroCuentaTransfer, sNumeroClienteTransfer, sTelefonoCasa, sTelefonoCelular, sCompaniaCelular, sIdCompaniaCelular,      
				   sCorreoElectronico, sFechaMovimiento, sHoraMovimiento, sMonto, sFolioSuc, sReferencia, sNombreSucursal, sNumeroSucursal, sTransaccion, sTranDescripcion, sActivo, sTipoMovimiento, sMovimientoDuplicado,    
				   sReferencia23, sReversado, sReferenciaComercio, sFechaConsumo, sHoraConsumo, sModoEntrada, sSecuenciaFolio, ret1, ret2, ret3, ret4, ret5 WITH RESUME;
		
		END FOREACH;
	
	ELIF (bandera = "8") THEN
		
		FOREACH
			
			EXECUTE PROCEDURE bdinteg:sp_busca_producto_deb_cheq_cliente(eNumeroCliente,eSkip) INTO sNumeroProducto, sDescripcionProducto, sNumeroCuenta, sNumeroTarjeta, sStatusTarjeta
			
			RETURN sCodigoRetorno, sCodigoDescripcion, sNumeroRegistros, sNumeroCliente, sPrimerNombre, sSegundoNombre, sPrimerApellido, sSegundoApellido, sNumeroProducto, sDescripcionProducto, sNumeroCuenta,           
				   sNumeroTarjeta, sStatusTarjeta, sTelefonoTransfer, sNumeroCuentaInversion, sNumeroCuentaTransfer, sNumeroClienteTransfer, sTelefonoCasa, sTelefonoCelular, sCompaniaCelular, sIdCompaniaCelular,      
				   sCorreoElectronico, sFechaMovimiento, sHoraMovimiento, sMonto, sFolioSuc, sReferencia, sNombreSucursal, sNumeroSucursal, sTransaccion, sTranDescripcion, sActivo, sTipoMovimiento, sMovimientoDuplicado,    
				   sReferencia23, sReversado, sReferenciaComercio, sFechaConsumo, sHoraConsumo, sModoEntrada, sSecuenciaFolio, ret1, ret2, ret3, ret4, ret5 WITH RESUME;
		
		END FOREACH;
	
	ELIF (bandera = "9") THEN
		
		FOREACH
			
			EXECUTE PROCEDURE bdinteg:sp_busca_producto_cred_cliente(eNumeroCliente, eSkip) INTO sNumeroProducto, sDescripcionProducto, sNumeroCuenta, sNumeroTarjeta, sStatusTarjeta
		
			RETURN sCodigoRetorno, sCodigoDescripcion, sNumeroRegistros, sNumeroCliente, sPrimerNombre, sSegundoNombre, sPrimerApellido, sSegundoApellido, sNumeroProducto, sDescripcionProducto, sNumeroCuenta,           
				   sNumeroTarjeta, sStatusTarjeta, sTelefonoTransfer, sNumeroCuentaInversion, sNumeroCuentaTransfer, sNumeroClienteTransfer, sTelefonoCasa, sTelefonoCelular, sCompaniaCelular, sIdCompaniaCelular,      
				   sCorreoElectronico, sFechaMovimiento, sHoraMovimiento, sMonto, sFolioSuc, sReferencia, sNombreSucursal, sNumeroSucursal, sTransaccion, sTranDescripcion, sActivo, sTipoMovimiento, sMovimientoDuplicado,    
				   sReferencia23, sReversado, sReferenciaComercio, sFechaConsumo, sHoraConsumo, sModoEntrada, sSecuenciaFolio, ret1, ret2, ret3, ret4, ret5 WITH RESUME;
		
		END FOREACH;
	
	ELIF (bandera = "10") THEN
		
		FOREACH
			
			EXECUTE PROCEDURE bdinteg:sp_busca_producto_cred_cliente_crd(eNumeroCliente, eSkip) INTO sNumeroProducto, sDescripcionProducto, sNumeroCuenta, sNumeroTarjeta, sStatusTarjeta
	
			RETURN sCodigoRetorno, sCodigoDescripcion, sNumeroRegistros, sNumeroCliente, sPrimerNombre, sSegundoNombre, sPrimerApellido, sSegundoApellido, sNumeroProducto, sDescripcionProducto, sNumeroCuenta,           
				   sNumeroTarjeta, sStatusTarjeta, sTelefonoTransfer, sNumeroCuentaInversion, sNumeroCuentaTransfer, sNumeroClienteTransfer, sTelefonoCasa, sTelefonoCelular, sCompaniaCelular, sIdCompaniaCelular,      
				   sCorreoElectronico, sFechaMovimiento, sHoraMovimiento, sMonto, sFolioSuc, sReferencia, sNombreSucursal, sNumeroSucursal, sTransaccion, sTranDescripcion, sActivo, sTipoMovimiento, sMovimientoDuplicado,    
				   sReferencia23, sReversado, sReferenciaComercio, sFechaConsumo, sHoraConsumo, sModoEntrada, sSecuenciaFolio, ret1, ret2, ret3, ret4, ret5 WITH RESUME;
		
		END FOREACH;
	
	ELIF (bandera = "11") THEN
	
		FOREACH
		
			EXECUTE PROCEDURE bdinteg:sp_busca_producto_deb_inver_cliente(eNumeroCliente, eSkip) INTO sNumeroProducto, sDescripcionProducto, sNumeroCuenta, sNumeroTarjeta, sNumeroCuentaInversion 
			
			RETURN sCodigoRetorno, sCodigoDescripcion, sNumeroRegistros, sNumeroCliente, sPrimerNombre, sSegundoNombre, sPrimerApellido, sSegundoApellido, sNumeroProducto, sDescripcionProducto, sNumeroCuenta,           
				   sNumeroTarjeta, sStatusTarjeta, sTelefonoTransfer, sNumeroCuentaInversion, sNumeroCuentaTransfer, sNumeroClienteTransfer, sTelefonoCasa, sTelefonoCelular, sCompaniaCelular, sIdCompaniaCelular,      
				   sCorreoElectronico, sFechaMovimiento, sHoraMovimiento, sMonto, sFolioSuc, sReferencia, sNombreSucursal, sNumeroSucursal, sTransaccion, sTranDescripcion, sActivo, sTipoMovimiento, sMovimientoDuplicado,    
				   sReferencia23, sReversado, sReferenciaComercio, sFechaConsumo, sHoraConsumo, sModoEntrada, sSecuenciaFolio, ret1, ret2, ret3, ret4, ret5 WITH RESUME;
		
		END FOREACH;
	
	ELIF (bandera = "12") THEN
	
		FOREACH
           
		   EXECUTE PROCEDURE bdinteg:sp_busca_producto_transfer_cliente(eNumeroCliente, eSkip) INTO sNumeroProducto, sDescripcionProducto, sNumeroCuenta, sNumeroTarjeta, sTelefonoTransfer, sNumeroClienteTransfer, sStatusTarjeta
		
			RETURN sCodigoRetorno, sCodigoDescripcion, sNumeroRegistros, sNumeroCliente, sPrimerNombre, sSegundoNombre, sPrimerApellido, sSegundoApellido, sNumeroProducto, sDescripcionProducto, sNumeroCuenta,           
				   sNumeroTarjeta, sStatusTarjeta, sTelefonoTransfer, sNumeroCuentaInversion, sNumeroCuentaTransfer, sNumeroClienteTransfer, sTelefonoCasa, sTelefonoCelular, sCompaniaCelular, sIdCompaniaCelular,      
				   sCorreoElectronico, sFechaMovimiento, sHoraMovimiento, sMonto, sFolioSuc, sReferencia, sNombreSucursal, sNumeroSucursal, sTransaccion, sTranDescripcion, sActivo, sTipoMovimiento, sMovimientoDuplicado,    
				   sReferencia23, sReversado, sReferenciaComercio, sFechaConsumo, sHoraConsumo, sModoEntrada, sSecuenciaFolio, ret1, ret2, ret3, ret4, ret5 WITH RESUME;
		
		END FOREACH;
	
	ELIF (bandera = "13") THEN
		
		FOREACH
			
			EXECUTE PROCEDURE bdinteg:sp_consulta_telefonos(eEmpresa, eNumeroCliente, eConsultaDatosActual, eTelefonoCorreo) INTO sCodigoRetorno,sTelefonoCelular, sCorreoElectronico,sSecuenciaFolio, sActivo, ret1, sIdCompaniaCelular, sCompaniaCelular, ret2     
			
			RETURN sCodigoRetorno, sCodigoDescripcion, sNumeroRegistros, sNumeroCliente, sPrimerNombre, sSegundoNombre, sPrimerApellido, sSegundoApellido, sNumeroProducto, sDescripcionProducto, sNumeroCuenta,           
					   sNumeroTarjeta, sStatusTarjeta, sTelefonoTransfer, sNumeroCuentaInversion, sNumeroCuentaTransfer, sNumeroClienteTransfer, sTelefonoCasa, sTelefonoCelular, sCompaniaCelular, sIdCompaniaCelular,      
					   sCorreoElectronico, sFechaMovimiento, sHoraMovimiento, sMonto, sFolioSuc, sReferencia, sNombreSucursal, sNumeroSucursal, sTransaccion, sTranDescripcion, sActivo, sTipoMovimiento, sMovimientoDuplicado,    
					   sReferencia23, sReversado, sReferenciaComercio, sFechaConsumo, sHoraConsumo, sModoEntrada, sSecuenciaFolio, ret1, ret2, ret3, ret4, ret5 WITH RESUME;
		
		END FOREACH;
	ELIF (bandera = "14") THEN 
		
		FOREACH
			
			EXECUTE PROCEDURE bdinteg:sp_buscar_movimientos_cheques_dia3(eNumeroCuenta,eFechaInicial,eFechaFinal,eMonto,eSkip,eNumeroTarjeta,eNumeroTransacciones,eEmpresa) 
			INTO sFechaMovimiento, sHoraMovimiento,sMonto,sFolioSuc,sNumeroSucursal,sNombreSucursal,sTransaccion,sTranDescripcion,reversado,sReferenciaComercio,sFechaConsumo,sHoraConsumo 
			IF reversado = '' THEN LET sReversado = 'f'; ELSE LET sReversado = 't'; END IF; --Validacion de variable que si viene en blanco manda un bolean	
			RETURN sCodigoRetorno, sCodigoDescripcion, sNumeroRegistros, sNumeroCliente, sPrimerNombre, sSegundoNombre, sPrimerApellido, sSegundoApellido, sNumeroProducto, sDescripcionProducto, sNumeroCuenta,           
					   sNumeroTarjeta, sStatusTarjeta, sTelefonoTransfer, sNumeroCuentaInversion, sNumeroCuentaTransfer, sNumeroClienteTransfer, sTelefonoCasa, sTelefonoCelular, sCompaniaCelular, sIdCompaniaCelular,      
					   sCorreoElectronico, sFechaMovimiento, sHoraMovimiento, sMonto, sFolioSuc, sReferencia, sNombreSucursal, sNumeroSucursal, sTransaccion, sTranDescripcion, sActivo, sTipoMovimiento, sMovimientoDuplicado,    
					   sReferencia23, sReversado, sReferenciaComercio, sFechaConsumo, sHoraConsumo, sModoEntrada, sSecuenciaFolio, ret1, ret2, ret3, ret4, ret5 WITH RESUME;
		
		END FOREACH;
	
	ELIF (bandera = "15") THEN
		
		FOREACH
			
			EXECUTE PROCEDURE bdinteg:sp_buscar_movimientos_inversion_dia2(eNumeroCuenta,eFechaInicial,eFechaFinal,eMonto,eSkip,eNumeroTransacciones,eEmpresa)
			INTO sFechaMovimiento, sHoraMovimiento,sMonto,sFolioSuc,sNumeroSucursal,sNombreSucursal,sTransaccion,sTranDescripcion,reversado	
			IF reversado = '' THEN LET sReversado = 'f'; ELSE LET sReversado = 't'; END IF; --Validacion de variable que si viene en blanco manda un bolean
			RETURN sCodigoRetorno, sCodigoDescripcion, sNumeroRegistros, sNumeroCliente, sPrimerNombre, sSegundoNombre, sPrimerApellido, sSegundoApellido, sNumeroProducto, sDescripcionProducto, sNumeroCuenta,           
					   sNumeroTarjeta, sStatusTarjeta, sTelefonoTransfer, sNumeroCuentaInversion, sNumeroCuentaTransfer, sNumeroClienteTransfer, sTelefonoCasa, sTelefonoCelular, sCompaniaCelular, sIdCompaniaCelular,      
					   sCorreoElectronico, sFechaMovimiento, sHoraMovimiento, sMonto, sFolioSuc, sReferencia, sNombreSucursal, sNumeroSucursal, sTransaccion, sTranDescripcion, sActivo, sTipoMovimiento, sMovimientoDuplicado,    
					   sReferencia23, sReversado, sReferenciaComercio, sFechaConsumo, sHoraConsumo, sModoEntrada, sSecuenciaFolio, ret1, ret2, ret3, ret4, ret5 WITH RESUME;
		
		END FOREACH;
	
	ELIF (bandera = "16") THEN
		
		EXECUTE PROCEDURE bdinteg:sp_buscar_movimientos_inversion_his2(eNumeroCuenta,eFechaInicial,eFechaFinal,eMonto,eSkip,eNumeroTransacciones,eEmpresa) INTO sFechaMovimiento;
	
		RETURN sCodigoRetorno, sCodigoDescripcion, sNumeroRegistros, sNumeroCliente, sPrimerNombre, sSegundoNombre, sPrimerApellido, sSegundoApellido, sNumeroProducto, sDescripcionProducto, sNumeroCuenta,           
		   sNumeroTarjeta, sStatusTarjeta, sTelefonoTransfer, sNumeroCuentaInversion, sNumeroCuentaTransfer, sNumeroClienteTransfer, sTelefonoCasa, sTelefonoCelular, sCompaniaCelular, sIdCompaniaCelular,      
		   sCorreoElectronico, sFechaMovimiento, sHoraMovimiento, sMonto, sFolioSuc, sReferencia, sNombreSucursal, sNumeroSucursal, sTransaccion, sTranDescripcion, sActivo, sTipoMovimiento, sMovimientoDuplicado,    
		   sReferencia23, sReversado, sReferenciaComercio, sFechaConsumo, sHoraConsumo, sModoEntrada, sSecuenciaFolio, ret1, ret2, ret3, ret4, ret5;
		   
	ELIF (bandera = "17") THEN
	
		EXECUTE PROCEDURE bdinteg:sp_buscar_movimientos_transfer(eNumeroCuenta,eTelefonoTransfer,eFechaInicial,eFechaFinal,eMonto,eSkip,eNumeroTarjeta,eNumeroTransacciones,eEmpresa)
		INTO sFechaMovimiento, sHoraMovimiento, sMonto, sTransaccion, sTranDescripcion,sFolioSuc,sNumeroSucursal;
		
		RETURN sCodigoRetorno, sCodigoDescripcion, sNumeroRegistros, sNumeroCliente, sPrimerNombre, sSegundoNombre, sPrimerApellido, sSegundoApellido, sNumeroProducto, sDescripcionProducto, sNumeroCuenta,           
		   sNumeroTarjeta, sStatusTarjeta, sTelefonoTransfer, sNumeroCuentaInversion, sNumeroCuentaTransfer, sNumeroClienteTransfer, sTelefonoCasa, sTelefonoCelular, sCompaniaCelular, sIdCompaniaCelular,      
		   sCorreoElectronico, sFechaMovimiento, sHoraMovimiento, sMonto, sFolioSuc, sReferencia, sNombreSucursal, sNumeroSucursal, sTransaccion, sTranDescripcion, sActivo, sTipoMovimiento, sMovimientoDuplicado,    
		   sReferencia23, sReversado, sReferenciaComercio, sFechaConsumo, sHoraConsumo, sModoEntrada, sSecuenciaFolio, ret1, ret2, ret3, ret4, ret5;
		   
	ELIF (bandera = "18") THEN
		
		FOREACH
			
			EXECUTE PROCEDURE bdinteg:sp_buscar_movimientos_credito_dia3(eNumeroCuenta,eFechaInicial,eFechaFinal,eMonto,eSkip,eNumeroTarjeta,eNumeroTransacciones,eEmpresa)
			INTO sFechaMovimiento, sHoraMovimiento, sMonto,sFolioSuc, sNumeroSucursal,sNombreSucursal,sTransaccion,sTranDescripcion,sReferencia23,reversado,sReferenciaComercio,sFechaConsumo,sHoraConsumo
			IF reversado = '' THEN LET sReversado = 'f'; ELSE LET sReversado = 't'; END IF; --Validacion de variable que si viene en blanco manda un bolean
			RETURN sCodigoRetorno, sCodigoDescripcion, sNumeroRegistros, sNumeroCliente, sPrimerNombre, sSegundoNombre, sPrimerApellido, sSegundoApellido, sNumeroProducto, sDescripcionProducto, sNumeroCuenta,           
					   sNumeroTarjeta, sStatusTarjeta, sTelefonoTransfer, sNumeroCuentaInversion, sNumeroCuentaTransfer, sNumeroClienteTransfer, sTelefonoCasa, sTelefonoCelular, sCompaniaCelular, sIdCompaniaCelular,      
					   sCorreoElectronico, sFechaMovimiento, sHoraMovimiento, sMonto, sFolioSuc, sReferencia, sNombreSucursal, sNumeroSucursal, sTransaccion, sTranDescripcion, sActivo, sTipoMovimiento, sMovimientoDuplicado,    
					   sReferencia23, sReversado, sReferenciaComercio, sFechaConsumo, sHoraConsumo, sModoEntrada, sSecuenciaFolio, ret1, ret2, ret3, ret4, ret5 WITH RESUME;
		
		END FOREACH;
	
	ELIF (bandera = "19") THEN
		
		FOREACH
			
			EXECUTE PROCEDURE bdinteg:sp_buscar_movimientos_credito_his3(eNumeroCuenta,eFechaInicial,eFechaFinal,eMonto,eSkip,eNumeroTarjeta,eNumeroTransacciones,eEmpresa)
			INTO sFechaMovimiento, sHoraMovimiento, sMonto,sFolioSuc, sNumeroSucursal,sNombreSucursal,sTransaccion,sTranDescripcion,sReferencia23,reversado,sReferenciaComercio,sFechaConsumo,sHoraConsumo
			IF reversado = '' THEN LET sReversado = 'f'; ELSE LET sReversado = 't'; END IF; --Validacion de variable que si viene en blanco manda un bolean
			RETURN sCodigoRetorno, sCodigoDescripcion, sNumeroRegistros, sNumeroCliente, sPrimerNombre, sSegundoNombre, sPrimerApellido, sSegundoApellido, sNumeroProducto, sDescripcionProducto, sNumeroCuenta,           
					   sNumeroTarjeta, sStatusTarjeta, sTelefonoTransfer, sNumeroCuentaInversion, sNumeroCuentaTransfer, sNumeroClienteTransfer, sTelefonoCasa, sTelefonoCelular, sCompaniaCelular, sIdCompaniaCelular,      
					   sCorreoElectronico, sFechaMovimiento, sHoraMovimiento, sMonto, sFolioSuc, sReferencia, sNombreSucursal, sNumeroSucursal, sTransaccion, sTranDescripcion, sActivo, sTipoMovimiento, sMovimientoDuplicado,    
					   sReferencia23, sReversado, sReferenciaComercio, sFechaConsumo, sHoraConsumo, sModoEntrada, sSecuenciaFolio, ret1, ret2, ret3, ret4, ret5 WITH RESUME;
		
		END FOREACH;
	
	ELIF (bandera = "20") THEN
		
		FOREACH
			
			EXECUTE PROCEDURE bdinteg:sp_buscar_movimientos_creditocrd_his(eNumeroCuenta,eFechaInicial,eFechaFinal,eMonto,eSkip,eNumeroTarjeta,eNumeroTransacciones,eEmpresa)
			INTO sFechaMovimiento, sHoraMovimiento, sMonto,sFolioSuc, sNumeroSucursal,sNombreSucursal,sTransaccion,sTranDescripcion,sReferencia23,reversado,sReferenciaComercio,sFechaConsumo,sHoraConsumo
			IF reversado = '' THEN LET sReversado = 'f'; ELSE LET sReversado = 't'; END IF; --Validacion de variable que si viene en blanco manda un bolean
			RETURN sCodigoRetorno, sCodigoDescripcion, sNumeroRegistros, sNumeroCliente, sPrimerNombre, sSegundoNombre, sPrimerApellido, sSegundoApellido, sNumeroProducto, sDescripcionProducto, sNumeroCuenta,           
					   sNumeroTarjeta, sStatusTarjeta, sTelefonoTransfer, sNumeroCuentaInversion, sNumeroCuentaTransfer, sNumeroClienteTransfer, sTelefonoCasa, sTelefonoCelular, sCompaniaCelular, sIdCompaniaCelular,      
					   sCorreoElectronico, sFechaMovimiento, sHoraMovimiento, sMonto, sFolioSuc, sReferencia, sNombreSucursal, sNumeroSucursal, sTransaccion, sTranDescripcion, sActivo, sTipoMovimiento, sMovimientoDuplicado,    
					   sReferencia23, sReversado, sReferenciaComercio, sFechaConsumo, sHoraConsumo, sModoEntrada, sSecuenciaFolio, ret1, ret2, ret3, ret4, ret5 WITH RESUME;
		
		END FOREACH;
	
	ELIF (bandera = "21") THEN	
		
		EXECUTE PROCEDURE bdiaclaracion:sp_consulta_tipo_movimiento(eFolioSuc,eNumeroTarjeta,eOrigenEvento) INTO sTipoMovimiento, sModoEntrada;
		
		RETURN sCodigoRetorno, sCodigoDescripcion, sNumeroRegistros, sNumeroCliente, sPrimerNombre, sSegundoNombre, sPrimerApellido, sSegundoApellido, sNumeroProducto, sDescripcionProducto, sNumeroCuenta,           
		   sNumeroTarjeta, sStatusTarjeta, sTelefonoTransfer, sNumeroCuentaInversion, sNumeroCuentaTransfer, sNumeroClienteTransfer, sTelefonoCasa, sTelefonoCelular, sCompaniaCelular, sIdCompaniaCelular,      
		   sCorreoElectronico, sFechaMovimiento, sHoraMovimiento, sMonto, sFolioSuc, sReferencia, sNombreSucursal, sNumeroSucursal, sTransaccion, sTranDescripcion, sActivo, sTipoMovimiento, sMovimientoDuplicado,    
		   sReferencia23, sReversado, sReferenciaComercio, sFechaConsumo, sHoraConsumo, sModoEntrada, sSecuenciaFolio, ret1, ret2, ret3, ret4, ret5;
		   
	ELIF (bandera = "22") THEN
		
		EXECUTE PROCEDURE bdiaclaracion:sp_obten_secuencia_folio() INTO sSecuenciaFolio;
		
		RETURN sCodigoRetorno, sCodigoDescripcion, sNumeroRegistros, sNumeroCliente, sPrimerNombre, sSegundoNombre, sPrimerApellido, sSegundoApellido, sNumeroProducto, sDescripcionProducto, sNumeroCuenta,           
		   sNumeroTarjeta, sStatusTarjeta, sTelefonoTransfer, sNumeroCuentaInversion, sNumeroCuentaTransfer, sNumeroClienteTransfer, sTelefonoCasa, sTelefonoCelular, sCompaniaCelular, sIdCompaniaCelular,      
		   sCorreoElectronico, sFechaMovimiento, sHoraMovimiento, sMonto, sFolioSuc, sReferencia, sNombreSucursal, sNumeroSucursal, sTransaccion, sTranDescripcion, sActivo, sTipoMovimiento, sMovimientoDuplicado,    
		   sReferencia23, sReversado, sReferenciaComercio, sFechaConsumo, sHoraConsumo, sModoEntrada, sSecuenciaFolio, ret1, ret2, ret3, ret4, ret5;
		   
	ELIF (bandera = "23") THEN
		
		EXECUTE PROCEDURE bdinteg:sp_obten_referencia23_cheques(eFolioSuc,eArchivoInternacional,eArchivoNacional,eEmpresa) INTO sReferencia23;
		
		RETURN sCodigoRetorno, sCodigoDescripcion, sNumeroRegistros, sNumeroCliente, sPrimerNombre, sSegundoNombre, sPrimerApellido, sSegundoApellido, sNumeroProducto, sDescripcionProducto, sNumeroCuenta,           
		   sNumeroTarjeta, sStatusTarjeta, sTelefonoTransfer, sNumeroCuentaInversion, sNumeroCuentaTransfer, sNumeroClienteTransfer, sTelefonoCasa, sTelefonoCelular, sCompaniaCelular, sIdCompaniaCelular,      
		   sCorreoElectronico, sFechaMovimiento, sHoraMovimiento, sMonto, sFolioSuc, sReferencia, sNombreSucursal, sNumeroSucursal, sTransaccion, sTranDescripcion, sActivo, sTipoMovimiento, sMovimientoDuplicado,    
		   sReferencia23, sReversado, sReferenciaComercio, sFechaConsumo, sHoraConsumo, sModoEntrada, sSecuenciaFolio, ret1, ret2, ret3, ret4, ret5;
	ELIF (bandera = "24") THEN
		
		FOREACH
		
			EXECUTE PROCEDURE bdidomi:sp_consultaparamdomi("12") 
			INTO sCodigoRetorno, sCodigoDescripcion, sTranDescripcion
			RETURN sCodigoRetorno, sCodigoDescripcion, sNumeroRegistros, sNumeroCliente, sPrimerNombre, sSegundoNombre, sPrimerApellido, sSegundoApellido, sNumeroProducto, sDescripcionProducto, sNumeroCuenta,           
			   sNumeroTarjeta, sStatusTarjeta, sTelefonoTransfer, sNumeroCuentaInversion, sNumeroCuentaTransfer, sNumeroClienteTransfer, sTelefonoCasa, sTelefonoCelular, sCompaniaCelular, sIdCompaniaCelular,      
			   sCorreoElectronico, sFechaMovimiento, sHoraMovimiento, sMonto, sFolioSuc, sReferencia, sNombreSucursal, sNumeroSucursal, sTransaccion, sTranDescripcion, sActivo, sTipoMovimiento, sMovimientoDuplicado,    
			   sReferencia23, sReversado, sReferenciaComercio, sFechaConsumo, sHoraConsumo, sModoEntrada, sSecuenciaFolio, ret1, ret2, ret3, ret4, ret5 WITH RESUME;	
		
		END FOREACH;
	ELIF (bandera = "25") THEN
	
		FOREACH
		
			EXECUTE PROCEDURE bdidomi:sp_consultactasdomi(eNumeroCliente,0) 
			INTO sCodigoRetorno, sNumeroCuenta, sNumeroProducto,ret1,sNumeroTarjeta 
			RETURN sCodigoRetorno, sCodigoDescripcion, sNumeroRegistros, sNumeroCliente, sPrimerNombre, sSegundoNombre, sPrimerApellido, sSegundoApellido, sNumeroProducto, sDescripcionProducto, sNumeroCuenta,           
			   sNumeroTarjeta, sStatusTarjeta, sTelefonoTransfer, sNumeroCuentaInversion, sNumeroCuentaTransfer, sNumeroClienteTransfer, sTelefonoCasa, sTelefonoCelular, sCompaniaCelular, sIdCompaniaCelular,      
			   sCorreoElectronico, sFechaMovimiento, sHoraMovimiento, sMonto, sFolioSuc, sReferencia, sNombreSucursal, sNumeroSucursal, sTransaccion, sTranDescripcion, sActivo, sTipoMovimiento, sMovimientoDuplicado,    
			   sReferencia23, sReversado, sReferenciaComercio, sFechaConsumo, sHoraConsumo, sModoEntrada, sSecuenciaFolio, ret1, ret2, ret3, ret4, ret5 WITH RESUME;
		END FOREACH;		
	ELSE
		
		LET sCodigoRetorno = '00004';
		LET sCodigoDescripcion = 'BÃºsqueda No Encontrada.';
	
		RETURN sCodigoRetorno, sCodigoDescripcion, sNumeroRegistros, sNumeroCliente, sPrimerNombre, sSegundoNombre, sPrimerApellido, sSegundoApellido, sNumeroProducto, sDescripcionProducto, sNumeroCuenta,           
		   sNumeroTarjeta, sStatusTarjeta, sTelefonoTransfer, sNumeroCuentaInversion, sNumeroCuentaTransfer, sNumeroClienteTransfer, sTelefonoCasa, sTelefonoCelular, sCompaniaCelular, sIdCompaniaCelular,      
		   sCorreoElectronico, sFechaMovimiento, sHoraMovimiento, sMonto, sFolioSuc, sReferencia, sNombreSucursal, sNumeroSucursal, sTransaccion, sTranDescripcion, sActivo, sTipoMovimiento, sMovimientoDuplicado,    
		   sReferencia23, sReversado, sReferenciaComercio, sFechaConsumo, sHoraConsumo, sModoEntrada, sSecuenciaFolio, ret1, ret2, ret3, ret4, ret5;
	END IF;		
END
END PROCEDURE;
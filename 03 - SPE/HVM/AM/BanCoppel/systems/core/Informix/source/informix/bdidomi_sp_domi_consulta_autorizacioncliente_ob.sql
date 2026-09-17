CREATE PROCEDURE "informix".sp_domi_consulta_autorizacioncliente_ob(pNumcte CHAR(20), p_sFolioActivacion CHAR(20), p_sUserStatus CHAR(8), p_sGenerico1 NVARCHAR(254), p_sGenerico2 NVARCHAR(254), p_sGenerico3 NVARCHAR(254), p_sGenerico4 NVARCHAR(254), p_sGenerico5 NVARCHAR(254))
	RETURNING CHAR(5) 		AS codRet,
			  CHAR(30) 		AS primerNombreClienteCargo,
			  CHAR(30) 		AS segundoNombreClienteCargo,
			  CHAR(30) 		AS primerApellidoClienteCargo,
			  CHAR(30) 		AS segundoApellidoClienteCargo,
			  CHAR(100) 	AS correo, 
			  CHAR(10) 		AS telefono, 
			  CHAR(13)  	AS RFC, -- RFC del cliente
			  CHAR(4) 		AS numProductoCargo, --Numero de producto quitar
			  CHAR(40) 		AS nomProductoCargo, --Nombre de producto Cargo quitar
			  CHAR(20) 		AS cuentaCargo, -- Cuenta cargo(DebitDeviceAccess) quitar
			  CHAR(20) 		AS clabeInterbancaria, --Clabe interbancaria quitar		  
			  CHAR(20) 		AS folioActivacion,--folio activacion
			  CHAR(20)		AS numeroTarjetaAbono, --Numero de Tarjeta abono 
			  CHAR(40)		AS nombreProductoAbono, --Nombre del producto abono
			  CHAR(30)  	AS nomCortoProductoAbono, --Nombre Corto de Producto Abono 
			  CHAR(40) 		AS descripcionBancoAbono, --Descripcion de banco abono
			  CHAR(10)		AS fechaPago,--fecha pago
			  CHAR(10)		AS fechaProximo,--fecha proximo pago
			  MONEY(16,2)	AS montoProximoPago, --monto proximo pago
			  MONEY(16,2)	AS montoMaximoDomiciliar, -- monto maximo a domiciliar
			  CHAR(2) 		AS periodicidad,--periodicidad
			  CHAR(2) 		AS tipoDomiciliacion, --tipoDomiciliacion
			  CHAR(3)		AS claveBancoCargo,
			  CHAR(2)		AS tipoCuentaCargo, 
			  CHAR(2)		AS tipoCuentaAbono,
			  CHAR(20)		AS cuentaAbono,
			  CHAR(20)		AS tarjetaCargo,
			  CHAR(100)		AS aliasDomiciliacion,
			  CHAR(2)		AS tipoPago,
			  MONEY(16,2) 	AS importePago,
			  CHAR(20)		AS rfcServicio,
			  CHAR(20)		AS userStatus,
			  CHAR(20)		AS userInsert,
			  CHAR(2)		AS claveCanal,
			  CHAR(100)		AS vGenerico1,
              CHAR(100)		AS vGenerico2,
              CHAR(100)		AS vGenerico3,
              CHAR(100)		AS vGenerico4,
			  CHAR(254)		AS vGenerico5,
			  CHAR(254)		AS vGenerico6,
			  CHAR(254)		AS vGenerico7,
			  CHAR(254)		AS vGenerico8,
			  CHAR(254)		AS vGenerico9;
			  			  
	--Declaracion de  Variables
	DEFINE sql_err 						INTEGER;
	DEFINE v_iContador 					INTEGER;	
	DEFINE v_cDataAux	                CHAR(100);	
			  
	DEFINE v_sCodRet					CHAR(5);
		
	DEFINE v_cPrimerNombreClienteCargo		CHAR(30);
	DEFINE v_cSegundoNombreClienteCargo		CHAR(30);
	DEFINE v_cPrimerApellidoClienteCargo	CHAR(30);
	DEFINE v_cSegundoApellidoClienteCargo	CHAR(30);
	DEFINE v_cCorreoElect				CHAR(100);
	DEFINE v_cNumTelefono				CHAR(10); 

   	DEFINE v_sNumProductoCargo			CHAR(4);	
   	DEFINE v_sNombreProductoCargo		CHAR(40);	
	DEFINE v_sCuentaCargo				CHAR(20);
	
	DEFINE v_sFolioActivacion			CHAR(20);
	DEFINE v_sNumeroTarjetaAbono		CHAR(20);
	DEFINE v_sNombreProductoAbono		CHAR(40);
	DEFINE v_sNombreCortoProductoAbono	CHAR(30);
	DEFINE v_sFechaPago					CHAR(10);
	DEFINE v_sFechaProximo				CHAR(10);
	DEFINE v_cRfc						CHAR(13);
	
	DEFINE v_mMontoMaximoDomiciliar		MONEY(16,2);

	DEFINE v_mMontoProximoPago			MONEY(16,2);
	--data return sp sp_domi_valida_cuentatarjeta
	DEFINE cClaveBancoAbono				CHAR(3);
	DEFINE v_sDescripcionBancoAbono		CHAR(40);

	DEFINE v_sNombreBancoAbono			CHAR(20);
	DEFINE v_sCuentaAbono				CHAR(20);
	DEFINE v_sClabeInterbancaria_ab 	CHAR(20);
	DEFINE v_sClabeInterbancaria_ca		CHAR(20);
	DEFINE v_sPeriodicidad				CHAR(2);
	DEFINE v_sTipoDomiciliacion			CHAR(2);
	DEFINE v_sClaveBancoCargo			CHAR(3);
	DEFINE ctipoCuentaCargo				CHAR(2);
	DEFINE ctipoCuentaAbono	            CHAR(2);
	DEFINE v_sCodRet2					CHAR(5);
	DEFINE cMensajeRespuesta 		    CHAR(110);
	DEFINE v_sTipoPago					CHAR(1);
	DEFINE v_sTarjetaCargo             	CHAR(20);
    DEFINE v_sAliasDomi                 CHAR(100);
	DEFINE v_mImportePago				MONEY(16,2);

	DEFINE v_sRfcServicio				CHAR(20);
	DEFINE v_sUserStatus				CHAR(20);
	DEFINE v_sUserInsert				CHAR(20);
	DEFINE v_sClaveCanal				CHAR(2);
	DEFINE v_sEstatusCtaCargoCecoban	CHAR(2);

	
    DEFINE v_Generico1                  CHAR(100);
    DEFINE v_Generico2                  CHAR(100);
    DEFINE v_Generico3                  CHAR(100);
    DEFINE v_Generico4                  CHAR(100);
	DEFINE v_Generico5                  CHAR(254);
	DEFINE v_Generico6                  CHAR(254);
	DEFINE v_Generico7                  CHAR(254);
	DEFINE v_Generico8                  CHAR(254);
	DEFINE v_Generico9                  CHAR(254);
	
	 			
	-- Inicializacion de variables			
	
	LET sql_err 					= 0;
	LET v_sCodRet 					= '00000';
	LET v_iContador					= 0;
	
	LET v_cPrimerNombreClienteCargo 		= '';
	LET v_cSegundoNombreClienteCargo 		= '';
	LET v_cPrimerApellidoClienteCargo 		= '';
	LET v_cSegundoApellidoClienteCargo 		= '';
	LET v_cCorreoElect				= '';
	LET v_cNumTelefono				= '';
	LET v_sNumProductoCargo 		= '';
	LET v_sNombreProductoCargo		= '';

	LET v_sCuentaCargo 				= '';
	LET v_sFolioActivacion			= '';	
	LET v_sNumeroTarjetaAbono		= '';
	LET v_sNombreProductoAbono 		= '';
	LET v_sNombreCortoProductoAbono	= '';
	LET v_sFechaPago				= '';
	LET v_sFechaProximo  			= '';
	LET v_cRfc  					= '';
	LET v_mMontoMaximoDomiciliar  	= 0.00;
	LET v_mMontoProximoPago 		= 0.00;
	--data return sp sp_domi_valida_cuentatarjeta
	LET cClaveBancoAbono			= '';
	LET v_sDescripcionBancoAbono	= '';	
	LET v_sNombreBancoAbono			= '';
	LET v_sCuentaAbono				= '';	
	LET v_sClabeInterbancaria_ab	= '';
	LET v_sClabeInterbancaria_ca 	= '';
	LET v_sPeriodicidad				= '';
	LET v_cDataAux 					= '';
	LET v_sTipoDomiciliacion		= '';
	LET v_sClaveBancoCargo			= '';
	LET ctipoCuentaCargo			= '';
	LET ctipoCuentaAbono			= '';
	LET v_sCodRet2					= '';
	LET cMensajeRespuesta			= '';
	LET v_sTipoPago					= '';
	LET v_sTarjetaCargo            	= '';
    LET v_sAliasDomi                = '';
	LET v_mImportePago				= '';
	LET v_sRfcServicio				= '';
	LET v_sUserStatus				= '';
	LET v_sUserInsert				= '';
	LET v_sClaveCanal				= '';
	LET v_sEstatusCtaCargoCecoban	= '';
	
    LET v_Generico1                 = '';
    LET v_Generico2                 = '';
    LET v_Generico3                 = '';
    LET v_Generico4                 = '';
	LET v_Generico5                 = '';
	LET v_Generico6                 = '';
	LET v_Generico7                 = '';
	LET v_Generico8                 = '';
	LET v_Generico9                 = '';
	
    --***************************************************************************************
    --SET DEBUG FILE TO "/home/e99806695/sp_domi_consulta_autorizacioncliente_ob.out";
	--TRACE ON;
	--***************************************************************************************
	
	BEGIN
		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				LET v_sCodRet = sql_err;
				
				INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error, Hora_Error, Cod_Error, Nombre_Arch, Sp_Llamado, Mensaje_Error, User_Insert, Fecha_Insert)
				VALUES (CURRENT, CURRENT HOUR TO FRACTION, v_sCodRet, '', 'sp_domi_consulta_autorizacioncliente', trim(p_sFolioActivacion), p_sUserStatus, CURRENT);
				
            	RETURN NVL(v_sCodRet,''),NVL(v_cPrimerNombreClienteCargo,''),NVL(v_cSegundoNombreClienteCargo,''),NVL(v_cPrimerApellidoClienteCargo,''),NVL(v_cSegundoApellidoClienteCargo,''), NVL(v_cCorreoElect,''),NVL(v_cNumTelefono,''),NVL(v_cRfc,''),NVL(v_sNumProductoCargo,''),NVL(v_sNombreProductoCargo,''),NVL(v_sCuentaCargo,''),NVL(v_sClabeInterbancaria_ca,''), NVL(v_sFolioActivacion,''),NVL(v_sNumeroTarjetaAbono,''),NVL(v_sNombreProductoAbono,''),NVL(v_sNombreCortoProductoAbono,''),NVL(v_sDescripcionBancoAbono,''), NVL(v_sFechaPago,''),NVL(v_sFechaProximo,''),NVL(v_mMontoProximoPago,''),NVL(v_mMontoMaximoDomiciliar,''), NVL(v_sPeriodicidad,''),NVL(v_sTipoDomiciliacion,''),NVL(v_sClaveBancoCargo,''), NVL(ctipoCuentaCargo,''),NVL(ctipoCuentaAbono,''),NVL(v_sCuentaAbono,''), NVL(v_sTarjetaCargo,''), NVL(v_sAliasDomi,''), NVL(v_sTipoPago,''), NVL(v_mImportePago,'0.00'), NVL(v_sRfcServicio,''), NVL(v_sUserStatus,''), NVL(v_sUserInsert,''), NVL(v_sClaveCanal,''), NVL(v_Generico1,''),NVL(v_Generico2,''),NVL(v_Generico3,''),NVL(v_Generico4,''), NVL(v_Generico5,''), NVL(v_Generico6,''), NVL(v_Generico7,''), NVL(v_Generico8,''), NVL(v_Generico9,'');
			END IF;
		END EXCEPTION;
			
		IF NVL(pNumcte, '') = '' OR NVL(p_sFolioActivacion, '') = '' OR NVL(p_sUserStatus, '') = '' THEN
			LET v_sCodRet = '88827'; --ALGUN PARAMETRO DE ENTRADA REQUERIDO ESTE EN BLANCO.
			
			EXECUTE PROCEDURE bdidomi:"informix".sp_obtenermensajeerror(v_sCodRet) INTO v_sCodRet2, cMensajeRespuesta;
	
			INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
			VALUES (CURRENT, CURRENT HOUR TO FRACTION, v_sCodRet2, '', 'sp_domi_consulta_autorizacioncliente', trim(p_sFolioActivacion) || ' - ' || trim(cMensajeRespuesta), p_sUserStatus, CURRENT);
			
            RETURN NVL(v_sCodRet,''),NVL(v_cPrimerNombreClienteCargo,''),NVL(v_cSegundoNombreClienteCargo,''),NVL(v_cPrimerApellidoClienteCargo,''),NVL(v_cSegundoApellidoClienteCargo,''), NVL(v_cCorreoElect,''),NVL(v_cNumTelefono,''),NVL(v_cRfc,''),NVL(v_sNumProductoCargo,''),NVL(v_sNombreProductoCargo,''),NVL(v_sCuentaCargo,''),NVL(v_sClabeInterbancaria_ca,''), NVL(v_sFolioActivacion,''),NVL(v_sNumeroTarjetaAbono,''),NVL(v_sNombreProductoAbono,''),NVL(v_sNombreCortoProductoAbono,''),NVL(v_sDescripcionBancoAbono,''), NVL(v_sFechaPago,''),NVL(v_sFechaProximo,''),NVL(v_mMontoProximoPago,''),NVL(v_mMontoMaximoDomiciliar,''), NVL(v_sPeriodicidad,''),NVL(v_sTipoDomiciliacion,''),NVL(v_sClaveBancoCargo,''), NVL(ctipoCuentaCargo,''),NVL(ctipoCuentaAbono,''),NVL(v_sCuentaAbono,''), NVL(v_sTarjetaCargo,''), NVL(v_sAliasDomi,''), NVL(v_sTipoPago,''), NVL(v_mImportePago,'0.00'), NVL(v_sRfcServicio,''), NVL(v_sUserStatus,''), NVL(v_sUserInsert,''), NVL(v_sClaveCanal,''), NVL(v_Generico1,''),NVL(v_Generico2,''),NVL(v_Generico3,''),NVL(v_Generico4,''), NVL(v_Generico5,''), NVL(v_Generico6,''), NVL(v_Generico7,''), NVL(v_Generico8,''), NVL(v_Generico9,'');
		END IF;	
		
        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;
        
	--CONSULTAR LOS DATOS DEL CLIENTE
		SELECT TRIM(nombre1), TRIM(nombre2 ), TRIM(apell_paterno), TRIM(apell_materno), rfc
		INTO v_cPrimerNombreClienteCargo,v_cSegundoNombreClienteCargo,v_cPrimerApellidoClienteCargo,v_cSegundoApellidoClienteCargo,v_cRfc
		FROM bdinteg:"informix".si_cliente
		WHERE numcte = pNumcte AND empresa = '001';
			
		SELECT telefono
		INTO v_cNumTelefono
		FROM bdinteg:"informix".si_telefonos_actual
		WHERE numcte = pNumcte
		AND status_tel = 'A'
		AND secuencia = (SELECT MAX(secuencia) FROM bdinteg:"informix".si_telefonos_actual WHERE numcte = pNumcte AND tipo_tel = 2)
		AND tipo_tel = 2
		AND empresa = '001';
		
		SELECT correo_elec
		INTO v_cCorreoElect
		FROM bdinteg:"informix".si_correos
		WHERE numcte = pNumcte 
		AND tipo_correo = 1
		AND secuencia = (SELECT MAX(secuencia) FROM bdinteg:"informix".si_correos WHERE numcte = pNumcte AND tipo_correo = 1)
		AND status_correo = 'A'
		AND empresa = '001';
		
		IF 
			NVL((v_cPrimerNombreClienteCargo || v_cSegundoNombreClienteCargo || v_cPrimerApellidoClienteCargo || v_cSegundoApellidoClienteCargo),'') = '' 
			OR NVL(v_cNumTelefono,'') = '' 
			OR NVL(v_cCorreoElect,'') = ''  
			OR NVL(v_cRfc,'') = '' 
		THEN
			LET v_sCodRet = '88829'; -- No se encontro informacion del cliente.		
			EXECUTE PROCEDURE bdidomi:"informix".sp_obtenermensajeerror(v_sCodRet) INTO v_sCodRet2, cMensajeRespuesta;
	
			INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
			VALUES (CURRENT, CURRENT HOUR TO FRACTION, v_sCodRet2, '', 'sp_domi_consulta_autorizacioncliente', trim(p_sFolioActivacion) || ' - ' || trim(cMensajeRespuesta), p_sUserStatus, CURRENT);
						
            RETURN NVL(v_sCodRet,''),NVL(v_cPrimerNombreClienteCargo,''),NVL(v_cSegundoNombreClienteCargo,''),NVL(v_cPrimerApellidoClienteCargo,''),NVL(v_cSegundoApellidoClienteCargo,''), NVL(v_cCorreoElect,''),NVL(v_cNumTelefono,''),NVL(v_cRfc,''),NVL(v_sNumProductoCargo,''),NVL(v_sNombreProductoCargo,''),NVL(v_sCuentaCargo,''),NVL(v_sClabeInterbancaria_ca,''), NVL(v_sFolioActivacion,''),NVL(v_sNumeroTarjetaAbono,''),NVL(v_sNombreProductoAbono,''),NVL(v_sNombreCortoProductoAbono,''),NVL(v_sDescripcionBancoAbono,''), NVL(v_sFechaPago,''),NVL(v_sFechaProximo,''),NVL(v_mMontoProximoPago,''),NVL(v_mMontoMaximoDomiciliar,''), NVL(v_sPeriodicidad,''),NVL(v_sTipoDomiciliacion,''),NVL(v_sClaveBancoCargo,''), NVL(ctipoCuentaCargo,''),NVL(ctipoCuentaAbono,''),NVL(v_sCuentaAbono,''), NVL(v_sTarjetaCargo,''), NVL(v_sAliasDomi,''), NVL(v_sTipoPago,''), NVL(v_mImportePago,'0.00'), NVL(v_sRfcServicio,''), NVL(v_sUserStatus,''), NVL(v_sUserInsert,''), NVL(v_sClaveCanal,''), NVL(v_Generico1,''),NVL(v_Generico2,''),NVL(v_Generico3,''),NVL(v_Generico4,''), NVL(v_Generico5,''), NVL(v_Generico6,''), NVL(v_Generico7,''), NVL(v_Generico8,''), NVL(v_Generico9,'');
		END IF;
		
		IF NOT EXISTS (SELECT 1 FROM bdidomi:"informix".dom_autorizaciones d_aut 
						WHERE d_aut.num_cte = pNumcte AND d_aut.folio_activacion = p_sFolioActivacion AND d_aut.cve_estatus = '01' )
		THEN	
			LET v_sCodRet = '88828'; --EL CLIENTE NO CUENTA CON LA DOMICILIACION ACTIVA.
			
			EXECUTE PROCEDURE bdidomi:"informix".sp_obtenermensajeerror(v_sCodRet) INTO v_sCodRet2, cMensajeRespuesta;
	
			INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
			VALUES (CURRENT, CURRENT HOUR TO FRACTION, v_sCodRet2, '', 'sp_domi_consulta_autorizacioncliente', trim(p_sFolioActivacion) || ' - ' || trim(cMensajeRespuesta), p_sUserStatus, CURRENT);
			
            RETURN NVL(v_sCodRet,''),NVL(v_cPrimerNombreClienteCargo,''),NVL(v_cSegundoNombreClienteCargo,''),NVL(v_cPrimerApellidoClienteCargo,''),NVL(v_cSegundoApellidoClienteCargo,''), NVL(v_cCorreoElect,''),NVL(v_cNumTelefono,''),NVL(v_cRfc,''),NVL(v_sNumProductoCargo,''),NVL(v_sNombreProductoCargo,''),NVL(v_sCuentaCargo,''),NVL(v_sClabeInterbancaria_ca,''), NVL(v_sFolioActivacion,''),NVL(v_sNumeroTarjetaAbono,''),NVL(v_sNombreProductoAbono,''),NVL(v_sNombreCortoProductoAbono,''),NVL(v_sDescripcionBancoAbono,''), NVL(v_sFechaPago,''),NVL(v_sFechaProximo,''),NVL(v_mMontoProximoPago,''),NVL(v_mMontoMaximoDomiciliar,''), NVL(v_sPeriodicidad,''),NVL(v_sTipoDomiciliacion,''),NVL(v_sClaveBancoCargo,''), NVL(ctipoCuentaCargo,''),NVL(ctipoCuentaAbono,''),NVL(v_sCuentaAbono,''), NVL(v_sTarjetaCargo,''), NVL(v_sAliasDomi,''), NVL(v_sTipoPago,''), NVL(v_mImportePago,'0.00'), NVL(v_sRfcServicio,''), NVL(v_sUserStatus,''), NVL(v_sUserInsert,''), NVL(v_sClaveCanal,''), NVL(v_Generico1,''),NVL(v_Generico2,''),NVL(v_Generico3,''),NVL(v_Generico4,''), NVL(v_Generico5,''), NVL(v_Generico6,''), NVL(v_Generico7,''), NVL(v_Generico8,''), NVL(v_Generico9,'');
		END IF;
	
		-- Datos domi.
		SELECT 
		  d_aut.cuenta, -- Cuenta abono.
		  d_aut.cuenta_cargo, --Cuenta cargo.
		  d_aut.folio_activacion --Folio activacion
		, TO_CHAR(f_pago.fecha_pago, '%Y-%m-%d') fecha_pago
		, TO_CHAR(f_pago.fecha_prox_pago, '%Y-%m-%d') fecha_prox_pago --Fecha proximo pago
		, d_aut.imp_maximo	--Importe maximo
		, f_pago.periodo
		, d_archivom.tipo_domi
		, d_aut.cve_domiciliar_tc
		, d_aut.alias_domi
		, d_aut.imp_fijo_tc  
		, d_aut.rfc
		, d_aut.user_estatus
		, d_aut.user_insert
		, d_aut.cve_canal
		, d_act_ob.estatus
		INTO 
		 v_sCuentaAbono,
		 v_sCuentaCargo,
		 v_sFolioActivacion,
		 v_sFechaPago,
		 v_sFechaProximo,
		 v_mMontoMaximoDomiciliar,
		 v_sPeriodicidad,
		 v_sTipoDomiciliacion,
		 v_sTipoPago,
		 v_sAliasDomi,
		 v_mImportePago,
		 v_sRfcServicio,
		 v_sUserStatus,
		 v_sUserInsert,
		 v_sClaveCanal,
		 v_sEstatusCtaCargoCecoban -- Estatus de verificacion de CECOBAN.
		FROM bdidomi:"informix".dom_autorizaciones d_aut
		INNER JOIN bdidomi:"informix".dom_cuentas_ob ctas_ob ON d_aut.cuenta_cargo = ctas_ob.num_tarjeta
		INNER JOIN bdidomi:"informix".dom_activacion_domiciliacion_ob d_act_ob ON d_act_ob.folio_activacion = d_aut.folio_activacion
		INNER JOIN bdidomi:"informix".dom_archivomanual d_archivom ON d_aut.folio_activacion = d_archivom.folio_activacion
		INNER JOIN bdidomi:"informix".dom_fecha_pago f_pago ON d_aut.folio_activacion = f_pago.folio_activacion
		INNER JOIN bdidomi:"informix".dom_pago d_pagos ON d_aut.folio_activacion = d_pagos.folio_activacion
		WHERE d_aut.num_cte = pNumcte AND d_aut.folio_activacion = p_sFolioActivacion
		AND d_aut.cve_estatus = '01' 
		GROUP BY d_aut.cuenta, d_aut.cuenta_cargo, d_aut.folio_activacion, f_pago.fecha_pago, f_pago.fecha_prox_pago, d_aut.imp_maximo
		, f_pago.periodo, d_archivom.tipo_domi, d_aut.cve_domiciliar_tc, d_aut.alias_domi, d_aut.imp_fijo_tc, d_aut.rfc, d_aut.user_estatus
		, d_aut.user_insert, d_aut.cve_canal, d_act_ob.estatus;
			
		-- Cuentas de credito.
		SELECT 
		  sd_def.nombre_prod --Nombre del producto abono
		, prod_tc.nombre_corto --Nombre corto del producto abono
		INTO 
		 v_sNombreProductoAbono,
		 v_sNombreCortoProductoAbono
		FROM bdicred:"informix".sd_maecred sd_mac 
		INNER JOIN bdicred:"informix".sd_definicion sd_def ON sd_def.num_producto = sd_mac.num_producto
		INNER JOIN bdidomi:"informix".dom_prod_permitidos_tc prod_tc on sd_def.num_producto = prod_tc.cve_producto
		WHERE sd_mac.numcte = pNumcte 
		AND sd_mac.num_credito = v_sCuentaAbono
		GROUP BY sd_def.nombre_prod, prod_tc.nombre_corto;
	
		--Obtener nombre y clave del banco, tipo de cuenta, cuuenta, tarjeta y ClabeInterbancaria de cargo
		EXECUTE PROCEDURE "informix".sp_domi_valida_cuentatarjeta_ob(v_sCuentaCargo, p_sUserStatus)
		INTO v_sCodRet, ctipoCuentaCargo, v_sClaveBancoCargo, v_cDataAux, v_cDataAux, v_sCuentaCargo, v_sTarjetaCargo, v_sClabeInterbancaria_ca;
			
		IF v_sCodRet = '00000' THEN
			--Obtener nombre y clave del banco, tipo de cuenta, cuuenta, tarjeta y ClabeInterbancaria de abono
			EXECUTE PROCEDURE "informix".sp_domi_valida_cuentatarjeta(v_sCuentaAbono, p_sUserStatus)
			INTO v_sCodRet, ctipoCuentaAbono, cClaveBancoAbono, v_sDescripcionBancoAbono, v_sNombreBancoAbono, v_sCuentaAbono, v_sNumeroTarjetaAbono, v_sClabeInterbancaria_ab;
			
			IF v_sCodRet = '00000' THEN
				EXECUTE PROCEDURE bdidomi:"informix".sp_domi_proximo_pago(v_sTipoPago, '001',v_sCuentaAbono,p_sUserStatus,p_sFolioActivacion, v_sTipoDomiciliacion)
				INTO v_sCodRet, v_mMontoProximoPago;
			END IF;
		END IF;
		
		IF v_sCodRet <> '00000' THEN
			EXECUTE PROCEDURE bdidomi:"informix".sp_obtenermensajeerror(v_sCodRet) INTO v_sCodRet2, cMensajeRespuesta;
	
			INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
			VALUES (CURRENT, CURRENT HOUR TO FRACTION, v_sCodRet2, '', 'sp_domi_consulta_autorizacioncliente', trim(p_sFolioActivacion) || ' - ' || trim(cMensajeRespuesta), p_sUserStatus, CURRENT);
			
		END IF;
		
		RETURN NVL(v_sCodRet,''),NVL(v_cPrimerNombreClienteCargo,''),NVL(v_cSegundoNombreClienteCargo,''),NVL(v_cPrimerApellidoClienteCargo,''),NVL(v_cSegundoApellidoClienteCargo,''), NVL(v_cCorreoElect,''),NVL(v_cNumTelefono,''),NVL(v_cRfc,''),NVL(v_sNumProductoCargo,''),NVL(v_sNombreProductoCargo,''),NVL(v_sCuentaCargo,''),NVL(v_sClabeInterbancaria_ca,''), NVL(v_sFolioActivacion,''),NVL(v_sNumeroTarjetaAbono,''),NVL(v_sNombreProductoAbono,''),NVL(v_sNombreCortoProductoAbono,''),NVL(v_sDescripcionBancoAbono,''), NVL(v_sFechaPago,''),NVL(v_sFechaProximo,''),NVL(v_mMontoProximoPago,''),NVL(v_mMontoMaximoDomiciliar,''), NVL(v_sPeriodicidad,''),NVL(v_sTipoDomiciliacion,''),NVL(v_sClaveBancoCargo,''), NVL(ctipoCuentaCargo,''),NVL(ctipoCuentaAbono,''),NVL(v_sCuentaAbono,''), NVL(v_sTarjetaCargo,''), NVL(v_sAliasDomi,''), NVL(v_sTipoPago,''), NVL(v_mImportePago,''), NVL(v_sRfcServicio,''), NVL(v_sUserStatus,''), NVL(v_sUserInsert,''), NVL(v_sClaveCanal,''), NVL(v_sTarjetaCargo,''), NVL(v_sAliasDomi,''), NVL(v_sTipoPago,''), NVL(v_mImportePago, '0.00'), NVL(v_sRfcServicio,''), NVL(v_sUserStatus,''), NVL(v_sUserInsert,''), NVL(v_sClaveCanal,''), NVL(v_sEstatusCtaCargoCecoban,'');
	END; 
END PROCEDURE;
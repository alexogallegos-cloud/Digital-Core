CREATE PROCEDURE "informix".sp_domi_reversa_archivomanual(p_sFolioActivacion CHAR(20), p_sUserStatus CHAR(8), p_sAccion CHAR(1), p_sGenerico1 CHAR(100), p_sGenerico2 CHAR(100), p_sGenerico3 CHAR(100), p_sGenerico4 CHAR(100))
	RETURNING CHAR(5) 	AS codRet, --Codigo de Retorno
			  CHAR(100)	AS v_generico1,
			  CHAR(100)	AS v_generico2,
			  CHAR(100)	AS v_generico3,
			  CHAR(100)	AS v_generico4;
	
--Declaracion de  Variables
	DEFINE sql_err 				INTEGER;
	DEFINE sCodret 				CHAR(5);


	DEFINE cCodret2				CHAR(5);
	DEFINE cMensajeRespuesta 	CHAR (110);
	DEFINE v_generico1			CHAR (110);
	DEFINE v_generico2			CHAR (110);
	DEFINE v_generico3			CHAR (110);
	DEFINE v_generico4			CHAR (110);	
	
	
	--Inicializo Variables
	LET sql_err = 0;
	LET sCodret 			= "00000";	
	LET cCodret2			= '';
	LET cMensajeRespuesta	= '';
	LET v_generico1			= '';
	LET v_generico2			= '';
	LET v_generico3			= '';
	LET v_generico4			= '';
	
	--*********************************************************************************************************************************
	--SET DEBUG FILE TO "/tmp/sp_domi_reversa_archivomanual.out";
	--TRACE ON;
	--*********************************************************************************************************************************
	
	BEGIN
		--Manejo de excepciones (errores)
		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				LET sCodret = sql_err;
				
				--Insertamos a la tabla bdidomi:dom_errores los datos del error ocurrido.
				INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
				VALUES (CURRENT, CURRENT HOUR TO FRACTION, sCodret, '', 'sp_domi_reversa_archivomanual', TRIM(p_sFolioActivacion), p_sUserStatus, CURRENT);
			
				RETURN sCodret, v_generico1, v_generico2, v_generico3, v_generico4;
			END IF;
		END EXCEPTION;
		
		--Valida parametros de entrada
		IF NVL(p_sfolioActivacion,'') = '' OR NVL(p_sUserStatus,'') = '' OR NVL(p_sAccion,'') = ''THEN
			LET sCodret = '99941'; --Problema con los parametros
			
			--Obtenemos los datos del error ocurrido.
			EXECUTE PROCEDURE bdidomi:"informix".sp_obtenermensajeerror(sCodret) INTO cCodret2, cMensajeRespuesta;
	

			
			--Insertamos a la tabla bdidomi:dom_errores los datos del error ocurrido.
			INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
			VALUES (CURRENT, CURRENT HOUR TO FRACTION, sCodret, '', 'sp_dom_reversa_archivomanual', TRIM(p_sfolioActivacion) || '-' || TRIM(cMensajeRespuesta), p_sUserStatus, CURRENT);
			
			RETURN sCodret, v_generico1, v_generico2, v_generico3, v_generico4;
		END IF;
		
		--Valida si existe la domiciliacion.
		IF EXISTS (SELECT 1 FROM bdidomi:"informix".dom_archivomanual WHERE folio_activacion = p_sfolioActivacion AND estatus = 'EP') THEN			
			
			IF (p_sAccion = 'B') THEN
				IF EXISTS (select 1 from bdidomi:"informix".dom_archivomanual a
					inner join  bdidomi:"informix".dom_archivomanual b on a.folio_activacion = b.folio_activacion and a.accion = 'A' and b.accion = 'B'
					WHERE a.folio_activacion = p_sfolioActivacion AND a.estatus = 'EP')THEN

					--Elimina registros de las tablas referentes al archivo manual
					DELETE FROM bdidomi:"informix".dom_archivomanual 
					WHERE folio_activacion = p_sfolioActivacion AND accion = 'A';

				END IF;			

				UPDATE bdidomi:"informix".dom_archivomanual SET accion = 'A'	
				WHERE folio_activacion = p_sfolioActivacion AND accion = p_sAccion;
				
			END IF;
			
			IF (p_sAccion = 'A') THEN
				--Elimina registros de las tablas referentes al archivo manual
				DELETE FROM bdidomi:"informix".dom_archivomanual 
				WHERE folio_activacion = p_sfolioActivacion AND accion = p_sAccion;
				
				DELETE FROM bdidomi:"informix".dom_fecha_pago
				WHERE folio_activacion = p_sfolioActivacion;
				
				DELETE FROM bdidomi:"informix".dom_pago
				WHERE folio_activacion = p_sfolioActivacion;
				
			--Se aplica reversa a la domiciliacion
				EXECUTE PROCEDURE bdidomi:"informix".sp_dom_reversa_estatus(p_sFolioActivacion, p_sUserStatus, '02', null, null, null, null, null, null,null)
				INTO sCodret, v_generico1, v_generico2, v_generico3, v_generico4;
				
				IF sCodret != '00000' THEN
					--Obtenemos los datos del error ocurrido.
					EXECUTE PROCEDURE bdidomi:"informix".sp_obtenermensajeerror(sCodret) INTO cCodret2, cMensajeRespuesta;
						
					--Insertamos a la tabla bdidomi:dom_errores los datos del error ocurrido.
					INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
					VALUES (CURRENT, CURRENT HOUR TO FRACTION, sCodret, '', 'sp_dom_reversa_archivomanual', TRIM(p_sfolioActivacion) || '-' || TRIM(cMensajeRespuesta), p_sUserStatus, CURRENT);
				END IF;
				
			END IF;
			
		END IF;
 			
		RETURN sCodret, v_generico1, v_generico2, v_generico3, v_generico4;
	END;

END PROCEDURE
DOCUMENT
'AUTOR      : Edith Mendoza Barraza',
'DESCRIPCION: Se encarga de reversar el guardado del archivo manual.',
'FECHA      : 12/04/2022',
'BD         : BDIDOMI';

CREATE PROCEDURE "informix".sp_activaserviciosdomi_lmpba (
	p_sFolioActivacion 	CHAR(20), 
	p_sAlias 			CHAR(50), 
	p_sCuenta 			CHAR(20),
	p_sRfcServicio 		CHAR(13), 
	p_sNumCte 			CHAR(20), 
	p_sCveCanal 		CHAR(2), 
	p_fImpMax 			MONEY(16,2), 
	p_sCveSucursal 		CHAR(4), 
	p_sCveStatus 		CHAR(2), 
	p_sUserStatus 		CHAR(8), 
	p_sCveCausa 		CHAR(2), 
	p_sUserInsert 		CHAR(8), 
	p_sTipoPago 		CHAR(1), 
	p_mImpPago 			MONEY(16,2), 
	p_sTipoCuentaCargo  CHAR(2), 
	p_sCuentaCargo 		CHAR(20),
	p_sCveBancoCargo 	CHAR(3)
)
	RETURNING CHAR(5)   AS codRet,
			  CHAR(100) AS vGenerico1,
              CHAR(100)	AS vGenerico2,
              CHAR(100)	AS vGenerico3,
              CHAR(100)	AS vGenerico4;
	
--Declaracion de  Variables
	DEFINE sql_err 				INTEGER;
	DEFINE sCodret 				CHAR(5);
	DEFINE dFechaHoy 			DATE;
	DEFINE dFechaInsert			DATE;
	DEFINE iNumRechazos			INTEGER;
	DEFINE v_sCveSucursal		CHAR(4);
	DEFINE cCodret2				CHAR(5);
	DEFINE cMensajeRespuesta 	CHAR (110);
	
	DEFINE v_Generico1          CHAR(100);
    DEFINE v_Generico2          CHAR(100);
    DEFINE v_Generico3          CHAR(100);
    DEFINE v_Generico4          CHAR(100);
	
	--Inicializo Variables
	LET sql_err 			= 0;
	LET sCodret 			= "00000";	
	LET dFechaInsert  		= CURRENT::DATE;
	LET iNumRechazos		= 0;
	LET cCodret2			= '';
	LET cMensajeRespuesta	= '';
	
	LET v_Generico1                 = '';
    LET v_Generico2                 = '';
    LET v_Generico3                 = '';
    LET v_Generico4                 = '';
	
	--*******************************************************************
	--SET DEBUG FILE TO "/tmp/sp_ActivaDomiciliacion.out";
	--TRACE ON;
	--*******************************************************************
	
	BEGIN
		--Manejo de excepciones (errores)
		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				LET sCodret = sql_err;
					
				--Insertamos a la tabla bdidomi:dom_errores los datos del error ocurrido.
				INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
				VALUES (CURRENT, CURRENT HOUR TO FRACTION, sCodret, '', 'sp_activaserviciosdomi', TRIM(p_sFolioActivacion), p_sUserInsert, CURRENT);
			
				RETURN sCodret,
				v_Generico1,v_Generico2,v_Generico3,v_Generico4;
			END IF;
		END EXCEPTION;
		
		--Valida parametros de entrada
		 IF 
		 	NVL(p_sfolioActivacion,'') = '' OR NVL(p_sCuenta,'') = '' OR NVL(p_sRfcServicio,'') = '' OR NVL(p_sNumCte,'') = '' OR NVL(p_sCveCanal,'') = '' 
		 	OR NVL(p_fImpMax,'') = '' OR NVL(p_sCveSucursal,'')  = '' OR NVL(p_sCveStatus,'') = '' OR NVL(p_sUserStatus,'') = '' 
		 	OR NVL(p_sCveCausa,'') = '' OR NVL(p_sUserInsert,'') = '' OR NVL(p_sTipoPago,'') = '' OR NVL(p_sTipoCuentaCargo,'') = ''  OR NVL(p_sCuentaCargo,'') = '' OR NVL(p_sCveBancoCargo,'') = '' 
			OR NVL(p_mImpPago,'') = ''
		 THEN
			LET sCodret='99926'; --PARAMETROS DE ENTRADA ESTAN EN BLANCO.
			
			--Obtenemos los datos del error ocurrido.
			EXECUTE PROCEDURE bdidomi:"informix".sp_obtenermensajeerror(sCodret) INTO cCodret2, cMensajeRespuesta;
				
			--Insertamos a la tabla bdidomi:dom_errores los datos del error ocurrido.
			INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
			VALUES (CURRENT, CURRENT HOUR TO FRACTION, sCodret, '', 'sp_activaserviciosdomi', TRIM(p_sfolioActivacion) || '-' || TRIM(cMensajeRespuesta), p_sUserInsert, CURRENT);
			
			RETURN sCodret,
				v_Generico1,v_Generico2,v_Generico3,v_Generico4;
		END IF;
		
		--Valida si el paymentType(cve_domiciliar_tc) existe en la tabla dom_cat_imptc.
		IF NOT EXISTS (SELECT 1 FROM bdidomi:"informix".dom_cat_imptc WHERE cve_domiciliar_tc = p_sTipoPago ) THEN
		   LET sCodret='99918'; --El tipo de pago no existe.
		   
		   --Obtenemos los datos del error ocurrido.
			EXECUTE PROCEDURE bdidomi:"informix".sp_obtenermensajeerror(sCodret) INTO cCodret2, cMensajeRespuesta;
				
			--Insertamos a la tabla bdidomi:dom_errores los datos del error ocurrido.
			INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
			VALUES (CURRENT, CURRENT HOUR TO FRACTION, sCodret, '', 'sp_activaserviciosdomi', TRIM(p_sfolioActivacion) || '-' || TRIM(cMensajeRespuesta), p_sUserInsert, CURRENT);
		   
		   RETURN sCodret,
				v_Generico1,v_Generico2,v_Generico3,v_Generico4;
		END IF;
		
		--Valida si el cliente  tiene dado de alta el servicio, que se envia en los parametros para darse de alta.
		IF EXISTS (SELECT 1 FROM bdidomi:"informix".dom_autorizaciones WHERE cuenta = p_sCuenta AND rfc = p_sRfcServicio AND num_cte = p_sNumCte AND cve_estatus = '01') then
		   LET sCodret='99917'; --El cliente ya esta dado de alta en el servicio de domiciliacion.
		   
		   --Obtenemos los datos del error ocurrido.
			EXECUTE PROCEDURE bdidomi:"informix".sp_obtenermensajeerror(sCodret) INTO cCodret2, cMensajeRespuesta;
				
			--Insertamos a la tabla bdidomi:dom_errores los datos del error ocurrido.
			INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
			VALUES (CURRENT, CURRENT HOUR TO FRACTION, sCodret, '', 'sp_activaserviciosdomi', TRIM(p_sfolioActivacion) || '-' || TRIM(cMensajeRespuesta), p_sUserInsert, CURRENT);
		   
		   RETURN sCodret,
				v_Generico1,v_Generico2,v_Generico3,v_Generico4;
		END IF;
		
		SELECT fecha_hoy INTO dFechaHoy FROM bdinteg:"informix".si_fechas WHERE empresa = '001';
	
		--Consultar clave de la sucursal.
		SELECT valor INTO v_sCveSucursal FROM bdidomi:"informix".dom_parametros WHERE cod_param = p_sCveSucursal;
		
		IF EXISTS (SELECT 1 FROM bdidomi:"informix".dom_autorizaciones WHERE SUBSTR(cuenta, 2, 16) = p_sCuenta AND rfc = p_sRfcServicio AND num_cte = p_sNumCte AND cve_estatus = '02') THEN
		--Insertar registro actual de dom_autorizaciones en historico 
			INSERT INTO bdidomi:"informix".dom_autorizaciones_hist(
				alias_domi, folio_activacion, cuenta, rfc, num_cte, cve_canal, imp_maximo, num_rechazos, 
				cve_sucursal, cve_estatus, fecha_estatus, user_estatus, cve_causa, user_insert, fecha_insert, 
				cve_domiciliar_tc, imp_fijo_tc, tipo_cuenta_cargo, cuenta_cargo, cve_banco_cargo
			) 
			SELECT {+INDEX(bdidomi:dom_autorizaciones idx_cuenta)} alias_domi, folio_activacion, cuenta, rfc, num_cte, cve_canal, imp_maximo, num_rechazos, 
				cve_sucursal, cve_estatus, fecha_estatus, user_estatus, cve_causa, user_insert, fecha_insert, 
				cve_domiciliar_tc, imp_fijo_tc, tipo_cuenta_cargo, cuenta_cargo, cve_banco_cargo
			FROM bdidomi:"informix".dom_autorizaciones
			WHERE SUBSTR(cuenta, 2, 16) = p_sCuenta 
			AND rfc = p_sRfcServicio 
			AND num_cte = p_sNumCte;
			
		 --Actualizar registro de dom_autorizaciones
			UPDATE {+INDEX(bdidomi:dom_autorizaciones idx_cuenta)} bdidomi:"informix".dom_autorizaciones 
			SET cuenta = p_sCuenta, cve_canal = p_sCveCanal, imp_maximo = p_fImpMax, num_rechazos = iNumRechazos, cve_sucursal = v_sCveSucursal, 
			cve_estatus = p_sCveStatus, fecha_estatus = dFechaHoy, user_estatus = p_sUserStatus, cve_causa = p_sCveCausa, user_insert = p_sUserInsert,
			fecha_insert = dFechaInsert, cve_domiciliar_tc = p_sTipoPago, imp_fijo_tc = CASE WHEN p_sTipoPago = 'F' THEN p_mImpPago ELSE NULL END, 
			tipo_cuenta_cargo = p_sTipoCuentaCargo, cuenta_cargo = p_sCuentaCargo, cve_banco_cargo = p_sCveBancoCargo, folio_activacion = p_sFolioActivacion, alias_domi = p_sAlias
			WHERE SUBSTR(cuenta, 2, 16) = p_sCuenta 
			AND rfc = p_sRfcServicio 
			AND num_cte = p_sNumCte;
			
			
		   RETURN sCodret, v_Generico1,v_Generico2,v_Generico3,v_Generico4;
		END IF;
		
		--Almacena el sevicio a domiciliar al cliente.
		INSERT INTO bdidomi:"informix".dom_autorizaciones (
			cuenta, rfc, num_cte, cve_canal, imp_maximo, num_rechazos, cve_sucursal, 
			cve_estatus, fecha_estatus, user_estatus, cve_causa, user_insert, 
			fecha_insert, cve_domiciliar_tc, imp_fijo_tc, tipo_cuenta_cargo, cuenta_cargo, cve_banco_cargo, folio_activacion, alias_domi
		)
		VALUES (
			p_sCuenta,p_sRfcServicio, p_sNumCte, p_sCveCanal, p_fImpMax, iNumRechazos, v_sCveSucursal, 
			p_sCveStatus, dFechaHoy, p_sUserStatus, p_sCveCausa, p_sUserInsert,
			dFechaInsert, p_sTipoPago, CASE WHEN p_sTipoPago = 'F' THEN p_mImpPago ELSE NULL END, p_sTipoCuentaCargo, p_sCuentaCargo, p_sCveBancoCargo, p_sFolioActivacion, p_sAlias
		);
			
		RETURN sCodret,
				v_Generico1,v_Generico2,v_Generico3,v_Generico4;
	END;
END PROCEDURE
DOCUMENT
'AUTOR      	: Edith Mendoza Barraza',
'DESCRIPCION	: Se encarga de dar de alta al cliente en el servicio de Domiciliacion',
'FECHA      	: 27/12/2021',
'BD         	: BDIDOMI';

CREATE PROCEDURE "informix".sp_domi_consulta_autorizacioncliente(pNumcte CHAR(20), p_sFolioActivacion CHAR(20), p_sUserStatus CHAR(8))
	RETURNING CHAR(5) 		AS codRet,
			  CHAR(30) 		AS primerNombreClienteCargo,
			  CHAR(30) 		AS segundoNombreClienteCargo,
			  CHAR(30) 		AS primerApellidoClienteCargo,
			  CHAR(30) 		AS segundoApellidoClienteCargo,
			  CHAR(100) 	AS correo, 
			  CHAR(10) 		AS telefono, 
			  CHAR(13)  	AS RFC, -- RFC del cliente
			  CHAR(4) 		AS numProductoCargo, --Numero de producto
			  CHAR(40) 		AS nomProductoCargo, --Nombre de producto Cargo
			  CHAR(20) 		AS cuentaCargo, -- Cuenta cargo(DebitDeviceAccess)
			  CHAR(20) 		AS clabeInterbancaria, --Clabe interbancaria		  
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
              CHAR(100)		AS vGenerico4;
			  			  
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

	
    DEFINE v_Generico1                  CHAR(100);
    DEFINE v_Generico2                  CHAR(100);
    DEFINE v_Generico3                  CHAR(100);
    DEFINE v_Generico4                  CHAR(100);
	
	 			
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
	
    LET v_Generico1                 = '';
    LET v_Generico2                 = '';
    LET v_Generico3                 = '';
    LET v_Generico4                 = '';
	
    --***************************************************************************************
    --SET DEBUG FILE TO "/tmp/sp_domi_consulta_autorizacioncliente.out";
	--TRACE ON;
	--***************************************************************************************
	
	BEGIN
		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				LET v_sCodRet = sql_err;
				
				INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error, Hora_Error, Cod_Error, Nombre_Arch, Sp_Llamado, Mensaje_Error, User_Insert, Fecha_Insert)
				VALUES (CURRENT, CURRENT HOUR TO FRACTION, v_sCodRet, '', 'sp_domi_consulta_autorizacioncliente', trim(p_sFolioActivacion), p_sUserStatus, CURRENT);
				
				RETURN v_sCodRet,v_cPrimerNombreClienteCargo,v_cSegundoNombreClienteCargo,v_cPrimerApellidoClienteCargo,v_cSegundoApellidoClienteCargo, v_cCorreoElect,v_cNumTelefono,v_cRfc,v_sNumProductoCargo,v_sNombreProductoCargo,v_sCuentaCargo,v_sClabeInterbancaria_ca, v_sFolioActivacion,v_sNumeroTarjetaAbono,v_sNombreProductoAbono,v_sNombreCortoProductoAbono,v_sDescripcionBancoAbono, v_sFechaPago,v_sFechaProximo,v_mMontoProximoPago,v_mMontoMaximoDomiciliar, v_sPeriodicidad,v_sTipoDomiciliacion,v_sClaveBancoCargo, ctipoCuentaCargo,ctipoCuentaAbono,v_sCuentaAbono, v_sTarjetaCargo, v_sAliasDomi, v_sTipoPago, v_mImportePago, v_sRfcServicio, v_sUserStatus, v_sUserInsert, v_sClaveCanal, v_Generico1,v_Generico2,v_Generico3,v_Generico4;
			END IF;
		END EXCEPTION;
			
		IF NVL(pNumcte, '') = '' OR NVL(p_sFolioActivacion, '') = '' OR NVL(p_sUserStatus, '') = ''THEN
			LET v_sCodRet = '99945'; --ALGUN PARAMETRO DE ENTRADA REQUERIDO ESTE EN BLANCO.
			
			EXECUTE PROCEDURE bdidomi:"informix".sp_obtenermensajeerror(v_sCodRet) INTO v_sCodRet2, cMensajeRespuesta;
	
			INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
			VALUES (CURRENT, CURRENT HOUR TO FRACTION, v_sCodRet2, '', 'sp_domi_consulta_autorizacioncliente', trim(p_sFolioActivacion) || ' - ' || trim(cMensajeRespuesta), p_sUserStatus, CURRENT);
			
		RETURN v_sCodRet,v_cPrimerNombreClienteCargo,v_cSegundoNombreClienteCargo,v_cPrimerApellidoClienteCargo,v_cSegundoApellidoClienteCargo, v_cCorreoElect,v_cNumTelefono,v_cRfc,v_sNumProductoCargo,v_sNombreProductoCargo,v_sCuentaCargo,v_sClabeInterbancaria_ca, v_sFolioActivacion,v_sNumeroTarjetaAbono,v_sNombreProductoAbono,v_sNombreCortoProductoAbono,v_sDescripcionBancoAbono, v_sFechaPago,v_sFechaProximo,v_mMontoProximoPago,v_mMontoMaximoDomiciliar, v_sPeriodicidad,v_sTipoDomiciliacion,v_sClaveBancoCargo, ctipoCuentaCargo,ctipoCuentaAbono,v_sCuentaAbono, v_sTarjetaCargo, v_sAliasDomi, v_sTipoPago, v_mImportePago, v_sRfcServicio, v_sUserStatus, v_sUserInsert, v_sClaveCanal, v_Generico1,v_Generico2,v_Generico3,v_Generico4;
		END IF;	
		
	--CONSULTAR LOS DATOS DEL CLIENTE
		SELECT TRIM(nombre1), TRIM(nombre2 ), TRIM(apell_paterno), TRIM(apell_materno), rfc
		INTO v_cPrimerNombreClienteCargo,v_cSegundoNombreClienteCargo,v_cPrimerApellidoClienteCargo,v_cSegundoApellidoClienteCargo,v_cRfc
		FROM bdinteg:"informix".si_cliente
		WHERE numcte = pNumcte AND empresa = '001';
			
		SELECT FIRST 1 telefono
		INTO v_cNumTelefono
		FROM bdinteg:"informix".si_telefonos_actual
		WHERE numcte= pNumcte
		AND status_tel = 'A'
		AND tipo_tel = 2
		AND secuencia = (SELECT MAX(secuencia) FROM bdinteg:"informix".si_telefonos_actual WHERE numcte = pNumcte AND status_tel = 'A')
		AND empresa = '001';
				

		SELECT FIRST 1 correo_elec
		INTO v_cCorreoElect
		FROM bdinteg:"informix".si_correos
		WHERE numcte= pNumcte 
		AND tipo_correo = 1
		AND status_correo = 'A'
		AND secuencia = (SELECT MAX(secuencia) FROM bdinteg:"informix".si_correos WHERE numcte = pNumcte AND status_correo = 'A')
		AND empresa = '001';
		
		IF (v_cPrimerNombreClienteCargo || v_cSegundoNombreClienteCargo || v_cPrimerApellidoClienteCargo || v_cSegundoApellidoClienteCargo) = '' OR v_cNumTelefono IS NULL OR v_cNumTelefono = '' OR v_cCorreoElect IS NULL OR v_cCorreoElect = '' 
		OR v_cRfc IS NULL OR v_cRfc = '' THEN
			LET v_sCodRet = '99947';			
			EXECUTE PROCEDURE bdidomi:"informix".sp_obtenermensajeerror(v_sCodRet) INTO v_sCodRet2, cMensajeRespuesta;
	
			INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
			VALUES (CURRENT, CURRENT HOUR TO FRACTION, v_sCodRet2, '', 'sp_domi_consulta_autorizacioncliente', trim(p_sFolioActivacion) || ' - ' || trim(cMensajeRespuesta), p_sUserStatus, CURRENT);
						
			RETURN v_sCodRet,v_cPrimerNombreClienteCargo,v_cSegundoNombreClienteCargo,v_cPrimerApellidoClienteCargo,v_cSegundoApellidoClienteCargo, v_cCorreoElect,v_cNumTelefono,v_cRfc,v_sNumProductoCargo,v_sNombreProductoCargo,v_sCuentaCargo,v_sClabeInterbancaria_ca, v_sFolioActivacion,v_sNumeroTarjetaAbono,v_sNombreProductoAbono,v_sNombreCortoProductoAbono,v_sDescripcionBancoAbono, v_sFechaPago,v_sFechaProximo,v_mMontoProximoPago,v_mMontoMaximoDomiciliar, v_sPeriodicidad,v_sTipoDomiciliacion,v_sClaveBancoCargo, ctipoCuentaCargo,ctipoCuentaAbono,v_sCuentaAbono, v_sTarjetaCargo, v_sAliasDomi, v_sTipoPago, v_mImportePago, v_sRfcServicio, v_sUserStatus, v_sUserInsert, v_sClaveCanal, v_Generico1,v_Generico2,v_Generico3,v_Generico4;
		END IF;
		
		IF NOT EXISTS (SELECT 1 FROM bdidomi:"informix".dom_autorizaciones d_aut 
						WHERE d_aut.num_cte = pNumcte AND d_aut.folio_activacion = p_sFolioActivacion AND d_aut.cve_estatus = '01' )
		THEN	
			LET v_sCodRet = '99946'; --EL CLIENTE NO CUENTA CON LA DOMICILIACION ACTIVA.
			
			EXECUTE PROCEDURE bdidomi:"informix".sp_obtenermensajeerror(v_sCodRet) INTO v_sCodRet2, cMensajeRespuesta;
	
			INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
			VALUES (CURRENT, CURRENT HOUR TO FRACTION, v_sCodRet2, '', 'sp_domi_consulta_autorizacioncliente', trim(p_sFolioActivacion) || ' - ' || trim(cMensajeRespuesta), p_sUserStatus, CURRENT);
			
			RETURN v_sCodRet,v_cPrimerNombreClienteCargo,v_cSegundoNombreClienteCargo,v_cPrimerApellidoClienteCargo,v_cSegundoApellidoClienteCargo, v_cCorreoElect,v_cNumTelefono,v_cRfc,v_sNumProductoCargo,v_sNombreProductoCargo,v_sCuentaCargo,v_sClabeInterbancaria_ca, v_sFolioActivacion,v_sNumeroTarjetaAbono,v_sNombreProductoAbono,v_sNombreCortoProductoAbono,v_sDescripcionBancoAbono, v_sFechaPago,v_sFechaProximo,v_mMontoProximoPago,v_mMontoMaximoDomiciliar, v_sPeriodicidad,v_sTipoDomiciliacion,v_sClaveBancoCargo, ctipoCuentaCargo,ctipoCuentaAbono,v_sCuentaAbono, v_sTarjetaCargo, v_sAliasDomi, v_sTipoPago, v_mImportePago, v_sRfcServicio, v_sUserStatus, v_sUserInsert, v_sClaveCanal, v_Generico1,v_Generico2,v_Generico3,v_Generico4;
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
		 v_sClaveCanal
		FROM bdidomi:"informix".dom_autorizaciones d_aut
		INNER JOIN bdidomi:"informix".dom_archivomanual d_archivom ON d_aut.folio_activacion = d_archivom.folio_activacion
		INNER JOIN bdidomi:"informix".dom_fecha_pago f_pago ON d_aut.folio_activacion = f_pago.folio_activacion
		INNER JOIN bdidomi:"informix".dom_pago d_pagos ON d_aut.folio_activacion = d_pagos.folio_activacion
		WHERE d_aut.num_cte = pNumcte AND d_aut.folio_activacion = p_sFolioActivacion
		AND d_aut.cve_estatus = '01' 
		GROUP BY d_aut.cuenta, d_aut.cuenta_cargo, d_aut.folio_activacion, f_pago.fecha_pago, f_pago.fecha_prox_pago, d_aut.imp_maximo
		, f_pago.periodo, d_archivom.tipo_domi, d_aut.cve_domiciliar_tc, d_aut.alias_domi, d_aut.imp_fijo_tc, d_aut.rfc, d_aut.user_estatus, d_aut.user_insert, d_aut.cve_canal;
			
		-- Cuentas de credito.
		SELECT 
		{+INDEX(dom_prod_permitidos_tc idxdom_prodperm_1)} 
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
	
		-- Cuentas de debito.
		SELECT 
		  sc_prod.nombre --Nombre del producto cargo
		, sc_prod.producto --numero producto cargo
		INTO 
		 v_sNombreProductoCargo,
		 v_sNumProductoCargo
		FROM bdicheq:"informix".sc_maechq sc_ma	
		INNER JOIN bdicheq:"informix".sc_producto sc_prod ON sc_ma.producto = sc_prod.producto
		WHERE sc_ma.num_cte = pNumcte
		AND sc_ma.cuenta = v_sCuentaCargo
		GROUP BY sc_prod.nombre, sc_prod.producto;
		
		--Obtener nombre y clave del banco, tipo de cuenta, cuuenta, tarjeta y ClabeInterbancaria de cargo
		EXECUTE PROCEDURE "informix".sp_domi_valida_cuentatarjeta(v_sCuentaCargo, p_sUserStatus)
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
		
		RETURN v_sCodRet,v_cPrimerNombreClienteCargo,v_cSegundoNombreClienteCargo,v_cPrimerApellidoClienteCargo,v_cSegundoApellidoClienteCargo, v_cCorreoElect,v_cNumTelefono,v_cRfc,v_sNumProductoCargo,v_sNombreProductoCargo,v_sCuentaCargo,v_sClabeInterbancaria_ca, v_sFolioActivacion,v_sNumeroTarjetaAbono,v_sNombreProductoAbono,v_sNombreCortoProductoAbono,v_sDescripcionBancoAbono, v_sFechaPago,v_sFechaProximo,v_mMontoProximoPago,v_mMontoMaximoDomiciliar, v_sPeriodicidad,v_sTipoDomiciliacion,v_sClaveBancoCargo, ctipoCuentaCargo,ctipoCuentaAbono,v_sCuentaAbono, v_sTarjetaCargo, v_sAliasDomi, v_sTipoPago, v_mImportePago, v_sRfcServicio, v_sUserStatus, v_sUserInsert, v_sClaveCanal, v_Generico1,v_Generico2,v_Generico3,v_Generico4;
		
	END; 
END PROCEDURE
DOCUMENT
'AUTOR: Aldo Alejandro Sanchez Felix',
'DESCRIPCION: Se encarga de consultar las domiciliaciones que estan activas.',
'FECHA: 25/04/2022',
'BD: BDIDOMI';

CREATE PROCEDURE "informix".sp_domi_valida_alta(pNumcte CHAR(20), pNumCuentaTarjetaCargo CHAR(20), pNumCuentaTarjetaAbono CHAR(20), pRazonSocial CHAR(60), pCanal CHAR(30), pTipo_domi CHAR(2), p_sUserStatus CHAR(8), p_sPeriodo CHAR(2))
	RETURNING	CHAR(5) 	AS codRet, 
				CHAR(20) 	AS NumCliente,
				CHAR(16) 	AS NumTarjetaAbono,
				CHAR(20) 	AS CuentaAbono, 
				CHAR(80)  	AS NomProductoAbono, --Nombre de Producto Abono
				CHAR(30)  	AS NomCortoProductoAbono, --Nombre Corto de Producto Abono 
				CHAR(30) 	AS NombreTitular, --Nombre del Titular de la Tarjeta Abono
				CHAR(26) 	AS Nombre1, -- Nombre1 del cliente
				CHAR(26) 	AS Nombre2, -- Nombre2 del cliente
				CHAR(26) 	AS Apellido1, -- Apellido1 del cliente
				CHAR(26) 	AS Apellido2, -- Apellido2 del cliente
				CHAR(13)  	AS RFC, -- RFC del cliente
				CHAR(13)  	AS NumCelular, -- NÃÂºmero de telefono celular
				CHAR(100) 	AS Correo, -- Correo electronico
				CHAR(20) 	AS CuentaCargo,
				CHAR(4)		AS CodigoProductoCargo,
				CHAR(80) 	AS NomProductoCargo, --Nombre de producto Cargo
				CHAR(20) 	AS CuentaClabe,
				CHAR(16)	AS NumeroTarjetaCargo, 
				CHAR(40)	AS BancoCargo, --Nombre del banco Cargo
				CHAR(40)	AS BancoCargoCorto, --Nombre corto del banco Cargo
		        CHAR(40)	AS BancoAbono, --Nombre del banco Abono
				CHAR(40)	AS BancoAbonoCorto, --Nombre corto del banco Abono
				CHAR(2)     AS ClaveCanal, -- Clave del canal de domiciliaciÃÂ³n
				CHAR(13)  	AS RFCServicio, 
				CHAR(2)		AS TipoCuentaCargo, 
		        CHAR(2)		AS TipoCuentaAbono, 
				CHAR(3)		AS ClaveBancoCargo,
				CHAR(20)	AS Periodicidad,
			    CHAR(100)   AS vGenerico1,
                CHAR(100)	AS vGenerico2,
                CHAR(100)	AS vGenerico3,
                CHAR(100)	AS vGenerico4;
               
--DECLARACION DE VARIABLES	
	DEFINE sql_err        				INTEGER;
	DEFINE cCodret        				CHAR(5);
	DEFINE cCanal         				CHAR(2);
	
	DEFINE cCuentaAbono					CHAR(20);
	DEFINE cNumTarjetaCargo				CHAR(16);
	DEFINE cCuentaCargo					CHAR(20);
	DEFINE cNumTarjetaAbono   			CHAR(16);
	DEFINE cNombreTitular				CHAR(30);
	DEFINE cNumProducto					CHAR(4);
	DEFINE iContador					SMALLINT;
	
	DEFINE cNumcte						CHAR(20);
	DEFINE iExiste						INTEGER;
	DEFINE cNombre1Cte     		        CHAR(200);
	DEFINE cNombre2Cte     				CHAR(200);
	DEFINE cApellido1Cte   				CHAR(200);
	DEFINE cApellido2Cte   				CHAR(200);
	DEFINE cRfc							CHAR(13);
	DEFINE cNumTelefono					CHAR(13); 
	DEFINE cCorreoElect					CHAR(100);

	DEFINE cRfcServicio					CHAR(13);

	DEFINE v_iPosicion					INTEGER;
	DEFINE iPosicionCadena				INTEGER;
	DEFINE v_sProducto    				CHAR(5);
	DEFINE v_sProductos    				CHAR(80);
	DEFINE v_sNombreProductoCargo		CHAR(80);
	DEFINE v_sNombreProductoAbono		CHAR(80);
	DEFINE v_sNombreCortoProductoAbono	CHAR(80);
	DEFINE v_sFechaNac   				CHAR(10);
	DEFINE v_sClabe						CHAR(20);
	DEFINE v_sValor 					CHAR(100);
	DEFINE v_sCodParam					CHAR(2);

	DEFINE cBancoCargo					CHAR(40);
	DEFINE cBancoAbono					CHAR(40);
	DEFINE cBancoCargoCorto				CHAR(20);
	DEFINE cBancoAbonoCorto				CHAR(20);
	DEFINE cClaveBancoCargo				CHAR(3);
	DEFINE cClaveBancoAbono				CHAR(3);
	DEFINE ctipoCuentaCargo				CHAR(2);
	DEFINE ctipoCuentaAbono				CHAR(2);
	DEFINE cCodret2						CHAR(5);
	DEFINE cMensajeRespuesta 			CHAR (110);
	DEFINE cPeriodicidad	 			CHAR (20);
	DEFINE cFolioAnterior               CHAR(20);
	
    DEFINE v_Generico2                  CHAR(100);
    DEFINE v_Generico3                  CHAR(100);

    DEFINE v_Generico4                  CHAR(100);
	
--Inicializar Variables	
	LET sql_err            			= 0;
	LET cCodret           			= '00000';
	LET cCanal              		= '';
	
	LET cCuentaAbono				= '';
	LET cNumTarjetaCargo			= '';
	LET cCuentaCargo				= '';
	LET cNumTarjetaAbono      		= '';
	LET cNombreTitular				= '';
	LET cNumProducto				= '';
	LET iContador					= 0;
 
	LET cNumcte						= '';
	LET iExiste						= 0;
	LET cNombre1Cte 				= '';
	LET cNombre2Cte 				= '';
	LET cApellido1Cte				= '';
	LET cApellido2Cte				= '';
	LET cRfc						= '';
	LET cNumTelefono				= '';
	LET cCorreoElect				= '';
	LET cRfcServicio        		= '';

	LET v_sClabe					= '';
	LET v_sProducto 				= '';
	LET v_sProductos				= '';
	LET v_sNombreProductoCargo		= '';
	LET v_sNombreProductoAbono		= '';
	LET v_sNombreCortoProductoAbono	= '';
	LET v_sFechaNac					= '';
	LET v_iPosicion					= 1;
	LET v_sCodParam					= '53';

	LET cBancoCargo					= '';
	LET cBancoAbono					= '';
	LET cBancoCargoCorto			= '';

	LET cBancoAbonoCorto			= '';
	LET cClaveBancoCargo			= '';
	LET cClaveBancoAbono			= '';
	LET ctipoCuentaCargo			= '';
	LET ctipoCuentaAbono			= '';
	LET iPosicionCadena				= 4;
	LET cCodret2					= '';
	LET cMensajeRespuesta			= '';
	LET cPeriodicidad				= '';
	LET cFolioAnterior              = '';
	
    LET v_Generico2                 = '';
    LET v_Generico3                 = '';
    LET v_Generico4                 = '';
	
	--*****************************************************************************************************
	--SET DEBUG FILE TO "/tmp/sp_domi_valida_alta.out";
	--TRACE ON;
	--*****************************************************************************************************

	
	BEGIN
		
		--Manejo de excepciones (errores)
		ON EXCEPTION SET sql_err 
			IF sql_err <> 0 THEN
				LET cCodret = sql_err;
				
				INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error, Hora_Error, Cod_Error, Nombre_Arch, Sp_Llamado, Mensaje_Error, User_Insert, Fecha_Insert)
				VALUES (CURRENT, CURRENT HOUR TO FRACTION, cCodret, '', 'sp_domi_valida_alta', trim(pNumCuentaTarjetaCargo), p_sUserStatus, CURRENT);
				
				RETURN cCodret, cNumcte, cNumTarjetaAbono, cCuentaAbono, v_sNombreProductoAbono, v_sNombreCortoProductoAbono, cNombreTitular, cNombre1Cte, cNombre2Cte, cApellido1Cte, cApellido2Cte, cRfc, cNumTelefono, cCorreoElect, cCuentaCargo, v_sProducto, v_sNombreProductoCargo, v_sClabe, cNumTarjetaCargo, cBancoCargo, cBancoCargoCorto, cBancoAbono, cBancoAbonoCorto, cCanal, cRfcServicio, ctipoCuentaCargo, ctipoCuentaAbono, cClaveBancoCargo, cPeriodicidad,
				cFolioAnterior,v_Generico2,v_Generico3,v_Generico4;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;

	-- Se validan los parametros de entrada
		IF NVL(pNumcte, '') = '' OR NVL(pCanal, '') = '' OR  NVL(pTipo_domi, '') = '' OR NVL(pNumCuentaTarjetaCargo, '') = '' OR NVL(pNumCuentaTarjetaAbono, '') = '' OR NVL(p_sUserStatus, '') = '' THEN
			LET cCodret = '99921'; --Parametros de entrada estan en blanco.
			
			EXECUTE PROCEDURE bdidomi:"informix".sp_obtenermensajeerror(cCodret) INTO cCodret2, cMensajeRespuesta;
	
			INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
			VALUES (CURRENT, CURRENT HOUR TO FRACTION, cCodret, '', 'sp_domi_valida_alta', trim(pNumCuentaTarjetaCargo) || ' - ' || trim(cMensajeRespuesta), p_sUserStatus, CURRENT);
			
			RETURN cCodret, cNumcte, cNumTarjetaAbono, cCuentaAbono, v_sNombreProductoAbono, v_sNombreCortoProductoAbono, cNombreTitular, cNombre1Cte, cNombre2Cte, cApellido1Cte, cApellido2Cte, cRfc, cNumTelefono, cCorreoElect, cCuentaCargo, v_sProducto, v_sNombreProductoCargo, v_sClabe, cNumTarjetaCargo, cBancoCargo, cBancoCargoCorto, cBancoAbono, cBancoAbonoCorto, cCanal, cRfcServicio, ctipoCuentaCargo, ctipoCuentaAbono, cClaveBancoCargo, cPeriodicidad,cFolioAnterior,v_Generico2,v_Generico3,v_Generico4;
		END IF;
	
	-- Se valida que exista el canal de procedencia
		IF EXISTS (SELECT {+INDEX(dom_canal idx_canal_descripcion)} * FROM bdidomi:"informix".dom_canal where UPPER(descripcion) = UPPER(pCanal)) THEN 
			SELECT {+INDEX(dom_canal idx_canal_descripcion)} cve_canal 

			INTO cCanal
	
		FROM bdidomi:"informix".dom_canal 
			WHERE UPPER(descripcion) = UPPER(pCanal);
		ELSE
			LET cCodret = '99920'; --El canal no existe en domiciliaciones
			
			EXECUTE PROCEDURE bdidomi:"informix".sp_obtenermensajeerror(cCodret) INTO cCodret2, cMensajeRespuesta;
	
			INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
			VALUES (CURRENT, CURRENT HOUR TO FRACTION, cCodret, '', 'sp_domi_valida_alta', trim(pNumCuentaTarjetaCargo) || ' - ' || trim(cMensajeRespuesta), p_sUserStatus, CURRENT);
			
			RETURN cCodret, cNumcte, cNumTarjetaAbono, cCuentaAbono, v_sNombreProductoAbono, v_sNombreCortoProductoAbono, cNombreTitular, cNombre1Cte, cNombre2Cte, cApellido1Cte, cApellido2Cte, cRfc, cNumTelefono, cCorreoElect, cCuentaCargo, v_sProducto, v_sNombreProductoCargo, v_sClabe, cNumTarjetaCargo, cBancoCargo, cBancoCargoCorto, cBancoAbono, cBancoAbonoCorto, cCanal, cRfcServicio, ctipoCuentaCargo, ctipoCuentaAbono, cClaveBancoCargo, cPeriodicidad,
				cFolioAnterior,v_Generico2,v_Generico3,v_Generico4;
		END IF;
	
	-- Se valida que exista el tipo de domiciliaciÃÂ³n
		IF NOT EXISTS (select * from bdidomi:"informix".dom_cat_tipo where cve_tipo = pTipo_domi) THEN
			LET cCodret = '99924'; --El tipo de domiciliaciÃÂ³n no existe
			
			EXECUTE PROCEDURE bdidomi:"informix".sp_obtenermensajeerror(cCodret) INTO cCodret2, cMensajeRespuesta;
	
			INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
			VALUES (CURRENT, CURRENT HOUR TO FRACTION, cCodret, '', 'sp_domi_valida_alta', trim(pNumCuentaTarjetaCargo) || ' - ' || trim(cMensajeRespuesta), p_sUserStatus, CURRENT);
			

			RETURN cCodret, cNumcte, cNumTarjetaAbono, cCuentaAbono, v_sNombreProductoAbono, v_sNombreCortoProductoAbono, cNombreTitular, cNombre1Cte, cNombre2Cte, cApellido1Cte, cApellido2Cte, cRfc, cNumTelefono, cCorreoElect, cCuentaCargo, v_sProducto, v_sNombreProductoCargo, v_sClabe, cNumTarjetaCargo, cBancoCargo, cBancoCargoCorto, cBancoAbono, cBancoAbonoCorto, cCanal, cRfcServicio, ctipoCuentaCargo, ctipoCuentaAbono, cClaveBancoCargo, cPeriodicidad,
				cFolioAnterior,v_Generico2,v_Generico3,v_Generico4;
		END IF;
	   
	--Verifica si el numero de cliente existe.
		SELECT numcte
		INTO cNumCte
		FROM bdinteg:"informix".si_cliente
		WHERE numcte = pNumcte
		AND empresa = '001';
	
		IF cNumCte IS NULL OR cNumCte = '' THEN
			-- NUMERO DE CLIENTE NO EXISTE
			LET cCodret = '99914';
			
			EXECUTE PROCEDURE bdidomi:"informix".sp_obtenermensajeerror(cCodret) INTO cCodret2, cMensajeRespuesta;
	
			INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
			VALUES (CURRENT, CURRENT HOUR TO FRACTION, cCodret, '', 'sp_domi_valida_alta', trim(pNumCuentaTarjetaCargo) || ' - ' || trim(cMensajeRespuesta), p_sUserStatus, CURRENT);
			
			
			RETURN cCodret, cNumcte, cNumTarjetaAbono, cCuentaAbono, v_sNombreProductoAbono, v_sNombreCortoProductoAbono, cNombreTitular, cNombre1Cte, cNombre2Cte, cApellido1Cte, cApellido2Cte, cRfc, cNumTelefono, cCorreoElect, cCuentaCargo, v_sProducto, v_sNombreProductoCargo, v_sClabe, cNumTarjetaCargo, cBancoCargo, cBancoCargoCorto, cBancoAbono, cBancoAbonoCorto, cCanal, cRfcServicio, ctipoCuentaCargo, ctipoCuentaAbono, cClaveBancoCargo, cPeriodicidad, cFolioAnterior,v_Generico2,v_Generico3,v_Generico4;
		END IF;
		
		--Obtener nombre y clave del banco, tipo de cuenta, cuuenta, tarjeta y clabe de abono
		EXECUTE PROCEDURE "informix".sp_domi_valida_cuentatarjeta(pNumCuentaTarjetaAbono, p_sUserStatus)
		INTO cCodret, ctipoCuentaAbono, cClaveBancoAbono, cBancoAbono, cBancoAbonoCorto, cCuentaAbono, cNumTarjetaAbono,v_sClabe;
	
		IF cCodret = '00000' THEN
			--Obtener nombre y clave del banco, tipo de cuenta, cuuenta, tarjeta de cargo
			EXECUTE PROCEDURE "informix".sp_domi_valida_cuentatarjeta(pNumCuentaTarjetaCargo, p_sUserStatus)
			INTO cCodret, ctipoCuentaCargo, cClaveBancoCargo, cBancoCargo, cBancoCargoCorto, cCuentaCargo, cNumTarjetaCargo, v_sClabe;
		END IF;

		IF cCodret != '00000' THEN
		
			EXECUTE PROCEDURE bdidomi:"informix".sp_obtenermensajeerror(cCodret) INTO cCodret2, cMensajeRespuesta;
	
	
		INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
			VALUES (CURRENT, CURRENT HOUR TO FRACTION, cCodret, '', 'sp_domi_valida_alta', trim(pNumCuentaTarjetaCargo) || ' - ' || trim(cMensajeRespuesta), p_sUserStatus, CURRENT);
			
			RETURN cCodret, cNumcte, cNumTarjetaAbono, cCuentaAbono, v_sNombreProductoAbono, v_sNombreCortoProductoAbono, cNombreTitular, cNombre1Cte, cNombre2Cte, cApellido1Cte, cApellido2Cte, cRfc,cNumTelefono, cCorreoElect, cCuentaCargo, v_sProducto, v_sNombreProductoCargo, v_sClabe, cNumTarjetaCargo, cBancoCargo, cBancoCargoCorto, cBancoAbono, cBancoAbonoCorto, cCanal, cRfcServicio, ctipoCuentaCargo, ctipoCuentaAbono, cClaveBancoCargo, cPeriodicidad,
				cFolioAnterior,v_Generico2,v_Generico3,v_Generico4;
		END IF;
			
	-- VALIDAR QUE EL PRODUCTO CARGO NO SEA 1500, 1600 o 2500 SI EL CANAL ES BEX	
		IF UPPER(pCanal) = 'BEX' THEN
		
			SELECT  a.producto
			INTO v_sProducto	

			FROM bdicheq:"informix".sc_maechq a
			WHERE a.cuenta = cCuentaCargo;  
			
			IF v_sProducto IN ('1500','1600','2500') THEN
			--CUENTA DE DEBITO NO PERMITIDA PARA DOMICILIACION.
				LET cCodret = '99915';
				
				EXECUTE PROCEDURE bdidomi:"informix".sp_obtenermensajeerror(cCodret) INTO cCodret2, cMensajeRespuesta;
	
				INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
				VALUES (CURRENT, CURRENT HOUR TO FRACTION, cCodret, '', 'sp_domi_valida_alta', trim(pNumCuentaTarjetaCargo) || ' - ' || trim(cMensajeRespuesta), p_sUserStatus, CURRENT);
			
			
				RETURN cCodret, cNumcte, cNumTarjetaAbono, cCuentaAbono, v_sNombreProductoAbono, v_sNombreCortoProductoAbono, cNombreTitular, cNombre1Cte, cNombre2Cte, cApellido1Cte, cApellido2Cte, cRfc, cNumTelefono, cCorreoElect, cCuentaCargo, v_sProducto, v_sNombreProductoCargo, v_sClabe, cNumTarjetaCargo, cBancoCargo, cBancoCargoCorto, cBancoAbono, cBancoAbonoCorto, cCanal, cRfcServicio, ctipoCuentaCargo, ctipoCuentaAbono, cClaveBancoCargo, cPeriodicidad,cFolioAnterior,v_Generico2,v_Generico3,v_Generico4;
			END IF;

		END IF;
		
	--OBTENER CUENTAS DE DEBITO DEL CLIENTE QUE SON APTAS PARA EL SERVICIO DE DOMICILIACION
		SELECT valor into v_sValor FROM bdidomi:"informix".dom_parametros WHERE cod_param = v_sCodParam;
	
		WHILE (v_iPosicion < LENGTH(TRIM(v_sValor)) AND NVL(v_sNombreProductoCargo,'') = '')
	
			LET v_sProductos = SUBSTR(v_sValor, v_iPosicion, iPosicionCadena); --Extrae de la cadena de los productos vÃÂ¡lidos producto por producto

			--Obtiene las cuentas  que tiene el cliente.	 
			SELECT  a.producto, b.nombre
			INTO v_sProducto, v_sNombreProductoCargo 
			FROM bdicheq:"informix".sc_maechq a
			INNER JOIN bdicheq:"informix".sc_producto b
			ON a.producto = b.producto	
			WHERE a.cuenta = cCuentaCargo  
			AND a.empresa = '001'
			AND a.num_cte = pNumcte  			   
			AND a.producto = v_sProductos
			AND a.status_cta in (1,4,5);
		
			LET v_iPosicion = v_iPosicion + 5; --Se incrementa la posicion

		END WHILE;
	
		IF v_sProducto = '' OR v_sProducto IS NULL THEN 
			--CUENTA DE DEBITO NO PERMITIDA PARA DOMICILIACION.
			LET cCodret = '99915';
			
			EXECUTE PROCEDURE bdidomi:"informix".sp_obtenermensajeerror(cCodret) INTO cCodret2, cMensajeRespuesta;
	
			INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
			VALUES (CURRENT, CURRENT HOUR TO FRACTION, cCodret, '', 'sp_domi_valida_alta', trim(pNumCuentaTarjetaCargo) || ' - ' || trim(cMensajeRespuesta), p_sUserStatus, CURRENT);
			
			
			RETURN cCodret, cNumcte, cNumTarjetaAbono, cCuentaAbono, v_sNombreProductoAbono, v_sNombreCortoProductoAbono, cNombreTitular, cNombre1Cte, cNombre2Cte, cApellido1Cte, cApellido2Cte, cRfc, cNumTelefono, cCorreoElect, cCuentaCargo, v_sProducto, v_sNombreProductoCargo, v_sClabe, cNumTarjetaCargo, cBancoCargo, cBancoCargoCorto, cBancoAbono, cBancoAbonoCorto, cCanal, cRfcServicio, ctipoCuentaCargo, ctipoCuentaAbono, cClaveBancoCargo, cPeriodicidad,
				cFolioAnterior,v_Generico2,v_Generico3,v_Generico4;
		END IF;
	
	-- Valida el tipo de domiciliaciÃÂ³n de TDD - TDC propias ambas de BanCoppel
		IF pTipo_domi= '01' THEN 

		
--OBTENER TARJETAS DE CREDITO DEL CLIENTE
			SELECT  a.nombre, b.descripcion, c.num_producto
			INTO cNombreTitular, v_sNombreProductoAbono, cNumProducto
			FROM bdicred:"informix".sd_tarjeta a
			INNER JOIN bdicred:"informix".sd_maecred c
			ON a.num_credito = c.num_credito
			INNER JOIN bdicred:"informix".sd_productos_sdoret b
			ON b.num_producto = c.num_producto
			WHERE a.numcte = pNumcte
			AND a.num_credito = cCuentaAbono
			AND a.status_tar <> 'C'
			AND c.empresa = '001'

			AND c.status_cred in ('E1', 'E2', 'E3');
						
			IF EXISTS (SELECT cve_producto FROM bdidomi:"informix".dom_prod_permitidos_tc WHERE cve_producto = cNumProducto) THEN
				SELECT nombre_corto INTO v_sNombreCortoProductoAbono FROM bdidomi:"informix".dom_prod_permitidos_tc WHERE cve_producto = cNumProducto;
				LET iContador = iContador + 1;
			ELSE
				IF cNumProducto = '' OR cNumProducto IS NULL THEN
					LET cCodret = '99919'; --CUENTA DE CREDITO NO ESTA ACTIVA.
					
					EXECUTE PROCEDURE bdidomi:"informix".sp_obtenermensajeerror(cCodret) INTO cCodret2, cMensajeRespuesta;
	
					INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
					VALUES (CURRENT, CURRENT HOUR TO FRACTION, cCodret, '', 'sp_domi_valida_alta', trim(pNumCuentaTarjetaCargo) || ' - ' || trim(cMensajeRespuesta), p_sUserStatus, CURRENT);
			
					RETURN cCodret, cNumcte, cNumTarjetaAbono, cCuentaAbono, v_sNombreProductoAbono, v_sNombreCortoProductoAbono, cNombreTitular, cNombre1Cte, cNombre2Cte, cApellido1Cte, cApellido2Cte, cRfc, cNumTelefono, cCorreoElect, cCuentaCargo, v_sProducto, v_sNombreProductoCargo, v_sClabe, cNumTarjetaCargo, cBancoCargo, cBancoCargoCorto, cBancoAbono, cBancoAbonoCorto, cCanal,cRfcServicio, ctipoCuentaCargo, ctipoCuentaAbono, cClaveBancoCargo, cPeriodicidad,cFolioAnterior,v_Generico2,v_Generico3,v_Generico4;
				END IF
			END IF;
	
			IF iContador = 0 THEN
				LET cCodret = '99915'; --CUENTA DE CREDITO NO PERMITIDA PARA DOMICILIACION.
				
				EXECUTE PROCEDURE bdidomi:"informix".sp_obtenermensajeerror(cCodret) INTO cCodret2, cMensajeRespuesta;
	
				INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
				VALUES (CURRENT, CURRENT HOUR TO FRACTION, cCodret, '', 'sp_domi_valida_alta', trim(pNumCuentaTarjetaCargo) || ' - ' || trim(cMensajeRespuesta), p_sUserStatus, CURRENT);
			
				RETURN cCodret, cNumcte, cNumTarjetaAbono, cCuentaAbono, v_sNombreProductoAbono, v_sNombreCortoProductoAbono, cNombreTitular, cNombre1Cte, cNombre2Cte, cApellido1Cte, cApellido2Cte, cRfc, cNumTelefono, cCorreoElect, cCuentaCargo, v_sProducto, v_sNombreProductoCargo, v_sClabe, cNumTarjetaCargo, cBancoCargo, cBancoCargoCorto, cBancoAbono, cBancoAbonoCorto, cCanal, cRfcServicio, ctipoCuentaCargo, ctipoCuentaAbono, cClaveBancoCargo, cPeriodicidad,
				cFolioAnterior,v_Generico2,v_Generico3,v_Generico4;
			END IF;
		
		END IF;
		
	--OBTENER RFC DEL SERVICIO
		EXECUTE PROCEDURE bdidomi:"informix".sp_domi_obtienerfc(pRazonSocial, p_sUserStatus, pNumCuentaTarjetaCargo) INTO cCodret, cRfcServicio;
		
		IF cCodret != '00000' THEN
		
			EXECUTE PROCEDURE bdidomi:"informix".sp_obtenermensajeerror(cCodret) INTO cCodret2, cMensajeRespuesta;
	
			INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
			VALUES (CURRENT, CURRENT HOUR TO FRACTION, cCodret, '', 'sp_domi_valida_alta', trim(pNumCuentaTarjetaCargo) || ' - ' || trim(cMensajeRespuesta), p_sUserStatus, CURRENT);
			
			RETURN cCodret, cNumcte, cNumTarjetaAbono, cCuentaAbono, v_sNombreProductoAbono, v_sNombreCortoProductoAbono, cNombreTitular, cNombre1Cte, cNombre2Cte, cApellido1Cte, cApellido2Cte, cRfc, cNumTelefono, cCorreoElect, cCuentaCargo, v_sProducto, v_sNombreProductoCargo, v_sClabe, cNumTarjetaCargo, cBancoCargo, cBancoCargoCorto, cBancoAbono, cBancoAbonoCorto, cCanal, cRfcServicio, ctipoCuentaCargo, ctipoCuentaAbono, cClaveBancoCargo, cPeriodicidad, cFolioAnterior,v_Generico2,v_Generico3,v_Generico4;
		END IF;
		
		
	--CONSULTAR LOS DATOS DEL CLIENTE
		SELECT numcte, TRIM(nombre1), TRIM(nombre2 ), TRIM(apell_paterno), TRIM(apell_materno), rfc
		INTO cNumCte, cNombre1Cte, cNombre2Cte, cApellido1Cte, cApellido2Cte, cRfc
		FROM bdinteg:"informix".si_cliente
		WHERE numcte = pNumcte
		AND empresa = '001';
			
		SELECT FIRST 1 telefono
		INTO cNumTelefono
		FROM bdinteg:"informix".si_telefonos_actual
		WHERE numcte= pNumcte
		AND status_tel = 'A'
		AND tipo_tel = 2
		AND secuencia = (SELECT MAX(secuencia) FROM bdinteg:"informix".si_telefonos_actual WHERE numcte = pNumcte AND status_tel = 'A')
		AND empresa = '001';
				
		SELECT FIRST 1 correo_elec
		INTO cCorreoElect
		FROM bdinteg:"informix".si_correos
		WHERE numcte= pNumcte 
		AND tipo_correo = 1
		AND status_correo = 'A'
		AND secuencia = (SELECT MAX(secuencia) FROM bdinteg:"informix".si_correos WHERE numcte = pNumcte AND status_correo = 'A')
		AND empresa = '001';
		
		IF NVL(cCorreoElect, '') = '' THEN
			-- El cliente no cuenta con correo electronico registrado
			LET cCodret = '99922';
			
			EXECUTE PROCEDURE bdidomi:"informix".sp_obtenermensajeerror(cCodret) INTO cCodret2, cMensajeRespuesta;
	
			INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
			VALUES (CURRENT, CURRENT HOUR TO FRACTION, cCodret, '', 'sp_domi_valida_alta', trim(pNumCuentaTarjetaCargo) || ' - ' || trim(cMensajeRespuesta), p_sUserStatus, CURRENT);
			
			RETURN cCodret, cNumcte, cNumTarjetaAbono, cCuentaAbono, v_sNombreProductoAbono, v_sNombreCortoProductoAbono, cNombreTitular, cNombre1Cte, cNombre2Cte, cApellido1Cte, cApellido2Cte, cRfc, cNumTelefono, cCorreoElect, cCuentaCargo, v_sProducto, v_sNombreProductoCargo, v_sClabe, cNumTarjetaCargo, cBancoCargo, cBancoCargoCorto, cBancoAbono, cBancoAbonoCorto, cCanal, cRfcServicio, ctipoCuentaCargo, ctipoCuentaAbono, cClaveBancoCargo, cPeriodicidad,
				cFolioAnterior,v_Generico2,v_Generico3,v_Generico4;
		END IF;
		
		IF NVL(cNumTelefono, '') = '' THEN
			-- El cliente no cuenta con numero de telefono registrado
			LET cCodret = '99936';
			
			EXECUTE PROCEDURE bdidomi:"informix".sp_obtenermensajeerror(cCodret) INTO cCodret2, cMensajeRespuesta;
	
			INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
			VALUES (CURRENT, CURRENT HOUR TO FRACTION, cCodret, '', 'sp_domi_valida_alta', trim(pNumCuentaTarjetaCargo) || ' - ' || trim(cMensajeRespuesta), p_sUserStatus, CURRENT);
			
			RETURN cCodret, cNumcte, cNumTarjetaAbono, cCuentaAbono, v_sNombreProductoAbono, v_sNombreCortoProductoAbono, cNombreTitular, cNombre1Cte, cNombre2Cte, cApellido1Cte, cApellido2Cte, cRfc, cNumTelefono, cCorreoElect, cCuentaCargo, v_sProducto, v_sNombreProductoCargo, v_sClabe, cNumTarjetaCargo, cBancoCargo, cBancoCargoCorto, cBancoAbono, cBancoAbonoCorto, cCanal, cRfcServicio, ctipoCuentaCargo, ctipoCuentaAbono, cClaveBancoCargo, cPeriodicidad,cFolioAnterior,v_Generico2,v_Generico3,v_Generico4;
		END IF;
		
		IF NVL(p_sPeriodo, '') != '' THEN
			SELECT descripcion
			INTO cPeriodicidad
			FROM bdidomi:"informix".dom_cat_periodo
			WHERE cve_periodo = p_sPeriodo;
			
			IF NVL(cPeriodicidad, '') = '' THEN
				--La periodicidad no existe
				LET cCodret = '99938';
				
				EXECUTE PROCEDURE bdidomi:"informix".sp_obtenermensajeerror(cCodret) INTO cCodret2, cMensajeRespuesta;
	
				INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
				VALUES (CURRENT, CURRENT HOUR TO FRACTION, cCodret, '', 'sp_domi_valida_alta', trim(pNumCuentaTarjetaCargo) || ' - ' || trim(cMensajeRespuesta), p_sUserStatus, CURRENT);
				
				RETURN cCodret, cNumcte, cNumTarjetaAbono, cCuentaAbono, v_sNombreProductoAbono, v_sNombreCortoProductoAbono, cNombreTitular, cNombre1Cte, cNombre2Cte, cApellido1Cte, cApellido2Cte, cRfc, cNumTelefono, cCorreoElect, cCuentaCargo, v_sProducto, v_sNombreProductoCargo, v_sClabe, cNumTarjetaCargo, cBancoCargo, cBancoCargoCorto, cBancoAbono, cBancoAbonoCorto, cCanal, cRfcServicio, ctipoCuentaCargo, ctipoCuentaAbono, cClaveBancoCargo, cPeriodicidad,cFolioAnterior,v_Generico2,v_Generico3,v_Generico4;
				
			END IF;
		END IF;
		
		SELECT folio_activacion
		INTO cFolioAnterior
		FROM bdidomi:"informix".dom_autorizaciones
		WHERE cuenta = 'C'||cCuentaAbono AND cuenta_cargo = cCuentaCargo AND cve_estatus = '02';
		
		RETURN cCodret, cNumcte, cNumTarjetaAbono, cCuentaAbono, v_sNombreProductoAbono, v_sNombreCortoProductoAbono, cNombreTitular, cNombre1Cte, cNombre2Cte, cApellido1Cte, cApellido2Cte, cRfc, cNumTelefono, cCorreoElect, cCuentaCargo, v_sProducto, v_sNombreProductoCargo, v_sClabe, cNumTarjetaCargo, cBancoCargo, cBancoCargoCorto, cBancoAbono, cBancoAbonoCorto, cCanal, cRfcServicio, ctipoCuentaCargo, ctipoCuentaAbono, cClaveBancoCargo, cPeriodicidad,				cFolioAnterior,v_Generico2,v_Generico3,v_Generico4;

	END;
END PROCEDURE 
DOCUMENT
'AUTOR      : Derian Alejandro Sainz Zazueta',
'DESCRIPCION: Se encarga de validar al usuario y verficar si puede dar de alta el servicio de domiciliacion',
'FECHA      : 01/02/2022',
'BD         : BDIDOMI' ;

CREATE PROCEDURE "informix".sp_domi_presentador ( psNomArchivo CHAR(20), psNumEmpleado CHAR (8))
RETURNING CHAR (20) AS Nom_Archivo, CHAR (5) AS Codigo_Respuesta, CHAR (100) AS Mensaje_Respuesta;

--****************************************************************************************************
-- DESCRIPCION:  SP PRINCIPAL DE DOMICILIACION -- PRESENTADOR
-- AUTOR : Casanova Edeza Hector Juan 
-- FECHA : 20/07/2009
-- BD: BdiDomi
-- SISTEMA : Domiciliacion
--***************************************************************************************************

/*  DEFINICION DE VARIABLES */
DEFINE sPROCESANDO CHAR(1);
DEFINE sERROR CHAR(1);
DEFINE sFINALIZADO CHAR(1);
DEFINE vsDescripcionProceso CHAR (60);
DEFINE vsFlagTipoProceso CHAR (1);
DEFINE viTipoArchivo SMALLINT ;
DEFINE vsFlagUnico CHAR (1);
DEFINE vsBloque CHAR (2);
DEFINE vsFecha_Presentacion CHAR (8);
DEFINE vSFecha_aplica CHAR(8);
DEFINE vdFecha_aplicaDe DATE;
DEFINE vsMensaje CHAR (80) ;
DEFINE vsRuta CHAR (100);

DEFINE vsCodRetorno CHAR (5);
DEFINE vsCodRetorno2 CHAR (5);
DEFINE vsMensaje_Respuesta CHAR (100);
DEFINE vsValorParam CHAR (100);
DEFINE vsNomArchivo CHAR (20);
DEFINE vsNomArchivo11 CHAR (20);
DEFINE vsNomArchivo31 CHAR (20);
DEFINE vsNomArchivo32 CHAR (20);
DEFINE viContador INTEGER;
DEFINE vdtFecha DATE;
DEFINE visqlerr INTEGER ;

DEFINE vsNomProceso CHAR (20);
DEFINE vsEstatusTemp CHAR(1);
DEFINE cCuentaAbono_Prov	CHAR(20);
DEFINE cNumCteCoppel		CHAR(20);
DEFINE cNom_Arch_Salida		CHAR(20);
DEFINE cCodret				CHAR(5);

/* INICIALIZACION DE VARIABLES */
--VARIABLES DE MONITOR
LET sPROCESANDO = '0';
LET sFINALIZADO = '1';
LET sERROR = '3';
LET vsDescripcionProceso = '';
LET vsFlagTipoProceso = '';
LET viTipoArchivo = 0;
LET vsFlagUnico = 'F';
LET vsBloque = '00';
LET vsFecha_Presentacion = '';
LET vSFecha_aplica = '';
LET vsMensaje = '';
LET vsRuta = '';

LET vsCodRetorno = '00000';
LET vsCodRetorno2 = '';
LET vsMensaje_Respuesta = '';
LET vsValorParam = '';
LET vsNomArchivo = '';
LET vsNomArchivo11 = '';
LET vsNomArchivo31 = '';
LET vsNomArchivo32 = '';
LET viContador = 0;
LET vdtFecha = CURRENT::DATE;
LET vdFecha_aplicaDe = CURRENT::DATE;

LET vsNomProceso = '';
LET vsEstatusTemp = '';
LET cCuentaAbono_Prov = '';
LET cNumCteCoppel = '';
LET cNom_Arch_Salida = '';
LET cCodret = '';

LET visqlerr = 0;


BEGIN

	ON EXCEPTION SET visqlerr   --CONTROL DE ERRORES
	 
		EXECUTE PROCEDURE BdiDomi:Sp_Domi_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomArchivo), vsDescripcionProceso, 
		sERROR, visqlerr, psNumEmpleado, 'ERROR NO CONTROLADO', TRIM(vsNomArchivo), vsFecha_Presentacion, '11'/*NO GUARDAR CCE_ARCHIVO*/ ) INTO vsCodRetorno2;
		
		LET vsMensaje_Respuesta = 'ERROR NO CONTROLADO(' || visqlerr || ') ARCHIVO: ' || TRIM(vsNomArchivo) || 'PROCESO: ' || TRIM(vsDescripcionProceso) ;
		
		RETURN vsNomArchivo, visqlerr, vsMensaje_Respuesta ;
		
	END EXCEPTION;

	--SET DEBUG FILE TO "/home/sysdomi/sp_domi_presentador.out";
	--TRACE ON;
	
--F ( psNumEmpleado = '99999999' ) THEN
		--SET DEBUG FILE TO '/home/sysdomi/TraceDomi_Presentador.out';
		--TRACE ON ;
	--D IF ;
	
	LET vsDescripcionProceso = 'Validacion de numero de empleado.';
	EXECUTE PROCEDURE BdiDomi:Sp_Valida_Cadena(TRIM(psNumEmpleado),'T') INTO vsCodRetorno;
	
	LET vsDescripcionProceso = 'Validacion de parametros.';
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	IF NOT EXISTS (SELECT Valor FROM BdiDomi:Dom_Parametros WHERE Cod_Param = '01') THEN -- Valida que exista el parametro RUTA ARCHIVO PROCESAR
		LET vsCodRetorno = '01401';
	ELIF NOT EXISTS (SELECT Valor FROM BdiDomi:Dom_Parametros WHERE Cod_Param = '02') THEN -- Valida que exista el parametro RUTA ARCHIVO RESPUESTA
		LET vsCodRetorno = '01402';
	ELIF NOT EXISTS (SELECT Valor FROM BdiDomi:Dom_Parametros WHERE Cod_Param = '03') THEN -- Valida que exista el parametro RUTA ARCHIVOS PROCESADOS
		LET vsCodRetorno = '01403';
	ELIF NOT EXISTS (SELECT Valor FROM BdiDomi:Dom_Parametros WHERE Cod_Param = '04') THEN -- Valida que exista el parametro RUTA ARCHIVOS ERRONEOS
		LET vsCodRetorno = '01404';
	ELIF NOT EXISTS (SELECT Valor FROM BdiDomi:Dom_Parametros WHERE Cod_Param = '05') THEN -- Valida que exista el parametro CLAVE BANCARIA BANCOPPEL
		LET vsCodRetorno = '01405';
	ELIF NOT EXISTS (SELECT Valor FROM BdiDomi:Dom_Parametros WHERE Cod_Param = '06') THEN -- Valida que exista el parametro BIN CORRESPONDIENTE TARJETA DEBITO
		LET vsCodRetorno = '10106';
	ELIF NOT EXISTS (SELECT Valor FROM BdiDomi:Dom_Parametros WHERE Cod_Param = '43') THEN -- Valida que exista el NUEVO parametro BIN CORRESPONDIENTE TARJETA DEBITO
		LET vsCodRetorno = '10106';
	ELIF NOT EXISTS (SELECT Valor FROM BdiDomi:Dom_Parametros WHERE Cod_Param = '07') THEN -- Valida que exista el parametro SUCURSAL CONTABLE DOMI
		LET vsCodRetorno = '01407';
	ELIF NOT EXISTS (SELECT Valor FROM BdiDomi:Dom_Parametros WHERE Cod_Param = '08') THEN -- Valida que exista el parametro TRANSACCION DE CARGO POR DOMI
		LET vsCodRetorno = '01408';
	ELIF NOT EXISTS (SELECT Valor FROM BdiDomi:Dom_Parametros WHERE Cod_Param = '09') THEN -- Valida que exista el parametro TRANSACCION DE ABONO
		LET vsCodRetorno = '01409';
	ELIF NOT EXISTS (SELECT Valor FROM BdiDomi:Dom_Parametros WHERE Cod_Param = '10') THEN -- Valida que exista el parametro IMPORTE MAXIMO CECOBAN
		LET vsCodRetorno = '01410';
	ELIF NOT EXISTS (SELECT Valor FROM BdiDomi:Dom_Parametros WHERE Cod_Param = '11') THEN -- Valida que exista el parametro MAXIMO DE RECHAZOS PERMITIDOS
		LET vsCodRetorno = '01411';
	ELIF NOT EXISTS (SELECT Valor FROM BdiDomi:Dom_Parametros WHERE Cod_Param = '12') THEN -- Valida que exista el parametro PRODUCTOS PERMITIDOS PARA DOMI
		LET vsCodRetorno = '01412';
--	ELIF NOT EXISTS (SELECT Valor FROM BdiDomi:Dom_Parametros WHERE Cod_Param = '13') THEN -- Valida que exista el parametro PRODUCTOS PERMITIDOS PARA DOMI
--		LET vsCodRetorno = '01413';
	ELIF NOT EXISTS (SELECT Fecha_Hoy FROM BdiCheq:Sc_Fechas) THEN -- Valida que exista el parametro de la fecha actual.
		LET vsCodRetorno = '01414';
	ELIF (TRIM(psNumEmpleado) = '') THEN --NUMERO DE EMPRLEADO VACIO
		LET vsCodRetorno = '01415';
	ELIF (LENGTH(TRIM(psNumEmpleado)) NOT IN(7,8)) THEN --NUMERO DE EMPLEADO NO CONTIENE LOS 8 DIGITOS REQUERIDOS
		LET vsCodRetorno = '01416';
	ELIF (vsCodRetorno <> '00000') THEN --ERROR EL NUMERO DE EMPLEADO CONTIENE  CARACTERES INVALIDOS
		LET vsCodRetorno = '01417';
	ELIF NOT EXISTS (SELECT Ejecutivo FROM BdInteg:Si_Ejecut WHERE Ejecutivo = TRIM(psNumEmpleado)) THEN -- Valida que exista el empleado en al si_ejecut
		LET vsCodRetorno = '00132';
	ELSE --TODO LOS PARAMETROS EXISTEN
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		SELECT LIMIT 1 Fecha_Hoy INTO vdtFecha FROM BdiCheq:Sc_Fechas; 
		
		SELECT LIMIT 1 TRIM(valor)
		INTO vsValorParam
		FROM bdidomi: dom_parametros
		WHERE cod_param = "05";
		
		EXECUTE PROCEDURE BdiDomi:Sp_Valida_Fecha(LPAD (YEAR(vdtFecha), 4, '0') || LPAD (MONTH(vdtFecha), 2, '0') || LPAD (DAY(vdtFecha), 2, '0')) INTO vsCodRetorno;
		
		LET vsFecha_Presentacion = LPAD (YEAR(vdtFecha), 4, '0') || LPAD (MONTH(vdtFecha), 2, '0') || LPAD (DAY(vdtFecha), 2, '0');
		
		IF (vsCodRetorno <> '00000') THEN --DIA NO LABORAL
			LET vsCodRetorno = '01413';
		ELSE --DIA LABORAL
			LET vsCodRetorno = '00000';
		END IF;
		
	END IF;
	
	IF (vsCodRetorno = '00000') THEN --TODO LOS PARAMETROS EXISTEN

		LET viContador = 0;
		LET vsFlagTipoProceso = 'A';
		
		WHILE ((viContador < 5) AND (vsFlagTipoProceso = 'A'))  --VERIFICA LA EXISTENCIA DE LOS 2 TIPOS DE ARCHIVO A PROCESAR
			
			LET vsDescripcionProceso = 'Obtencion de nombre de Archivo';
			
			LET vsNomProceso = '';
			
			LET viContador = viContador + 1;
			
			IF (TRIM(psNomArchivo) = '') THEN --Valida si es una corrida Automatica. --SIN NOMBRE DE ARCHIVO
				--OBTIENE EL NOPMBRE DEL ARCHIVO ESPERADO
				
				LET vsFlagTipoProceso = 'A'; --AUTOMATICO
				
				IF (viContador = 1) THEN --ARCHIVO 11
					LET viTipoArchivo = 11;
				ELIF (viContador = 2) THEN -- ARCHIVO 31
					LET viTipoArchivo = 31;
				ELIF (viContador = 3) THEN -- ARCHIVO 32
					LET viTipoArchivo = 32;
				ELIF (viContador = 4) THEN -- ARCHIVO 34
					LET viTipoArchivo = 34;
				ELIF (viContador = 5) THEN -- ARCHIVO 36
					LET viTipoArchivo = 36;
				ELSE --NINGUN TIPO DEFINIDO
					LET viTipoArchivo = 0;
				END IF;
					
					
				LET vsNomArchivo = 'S' --CONSTANTE
								|| '01'--CONSTANTE
								|| TRIM(vsValorParam) --ID BANCARIA BANCOPPEL 137
								|| 'A' --CONSTANTE 
								|| '2' --DOMICILIACION EN MONEDA NAC. 
								|| '.' --CONSTANTE
								|| 'A' --ARCHIVO DE DATOS
								|| viTipoArchivo::CHAR(2)
								|| LPAD(DAY(vdtFecha), 2, '0') --FECHA DEL ARCHIVO DIA DEL MES --DD--
								|| '98'; --SECUENCIA DEL ARCHIVO 98 PARA AUTOMATICO
						
			ELSE -- Corrida Manual.  -- INDICA EL NOMBRE DEL ARCHIVO.
				
				LET vsFlagTipoProceso = 'M'; --MANUAL
				
				IF ( SUBSTRING (TRIM(psNomArchivo) FROM 11 FOR 2) = '11' ) THEN --ARCHIVO 11
					LET viTipoArchivo = 11;
				ELIF ( SUBSTRING (TRIM(psNomArchivo) FROM 11 FOR 2) = '31' ) THEN --ARCHIVO 31
					LET viTipoArchivo = 31;
				ELIF ( SUBSTRING (TRIM(psNomArchivo) FROM 11 FOR 2) = '32' ) THEN --ARCHIVO 32
					LET viTipoArchivo = 32;
				ELIF ( SUBSTRING (TRIM(psNomArchivo) FROM 11 FOR 2) = '34' ) THEN --ARCHIVO 34
					LET viTipoArchivo = 34;
				ELIF ( SUBSTRING (TRIM(psNomArchivo) FROM 11 FOR 2) = '36' ) THEN --ARCHIVO 36
					LET viTipoArchivo = 36;
				ELSE --ARCHIVO NO VALIDO
					LET viTipoArchivo = 0;
				END IF;
					
				LET vsNomArchivo = TRIM(psNomArchivo);
				
			END IF;
			
			IF (LENGTH (TRIM(psNomArchivo)) >= 16) THEN --VALIDA EL EL NOMBRE DEL ARCHIVO POSEA LA EXTENCION ADECUADA
				LET vsNomProceso = 'RECARCH_' || LPAD (viTipoArchivo, 2, '0') || '.' || SUBSTRING (TRIM(psNomArchivo) FROM 15 FOR 2);
			ELSE -- ERROR DE LONGITUD DE NOMBRE DE ARCHIVO, ARCHIVO NO RECONOCIDO
				LET vsNomProceso = 'RECARCH_' || LPAD (viTipoArchivo, 2, '0') || '.' || '98';
			END IF ;
			
			LET vsDescripcionProceso = 'Validacion de nombre de archivo';
			--VALIDA LA INTEGRIDAD DEL NOMBRE DEL ARCHIVO
			EXECUTE PROCEDURE BdiDomi:Sp_Domi_ValidarNombreArchivos( viTipoArchivo, 'S', vsNomArchivo) INTO vsCodRetorno;
			
			IF (vsCodRetorno = '00000') THEN --NOMBRE DE ARCHIVO OK
			
				LET vsDescripcionProceso = 'Validacion de procesamientos previos.';
				SET LOCK MODE TO WAIT 3;
				SET ISOLATION TO DIRTY READ;
				IF EXISTS(SELECT Cve_Proceso FROM BdiDomi:Dom_Procesos WHERE Fecha_Proceso = vdtFecha AND TRIM(Cve_Proceso) = TRIM(vsNomProceso) ) THEN  --VALIDA SI EXISTE EL REGISTRO DE LA OPERACION
					
					SELECT LIMIT 1 Estatus INTO vsEstatusTemp FROM BdiDomi:Dom_Procesos WHERE Fecha_Proceso = vdtFecha AND TRIM(Cve_Proceso) = TRIM(vsNomProceso);
					
					IF (vsEstatusTemp = sFINALIZADO) THEN --EL ARCHIVO FUE PROCESADO PREVIAMENTE
						LET vsCodRetorno = '01419';
						EXECUTE PROCEDURE BdiDomi:sp_ObtenerMensajeError(vsCodRetorno) INTO vsCodRetorno2, vsMensaje_Respuesta;
					
						INSERT INTO BdiDomi:Dom_Errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
						VALUES (CURRENT, CURRENT HOUR TO FRACTION, vsCodRetorno, vsNomArchivo, 'sp_Domi_Presentador', vsMensaje_Respuesta, psNumEmpleado, CURRENT);
						
					ELIF (vsEstatusTemp = sPROCESANDO) THEN --EL ARCHIVO SE ENCUENTRA PROCESANDO
						LET vsCodRetorno = '01420';
						
						EXECUTE PROCEDURE BdiDomi:sp_ObtenerMensajeError(vsCodRetorno) INTO vsCodRetorno2, vsMensaje_Respuesta;
					
						INSERT INTO BdiDomi:Dom_Errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
						VALUES (CURRENT, CURRENT HOUR TO FRACTION, vsCodRetorno, vsNomArchivo, 'sp_Domi_Presentador', vsMensaje_Respuesta, psNumEmpleado, CURRENT);
						
					ELIF (vsEstatusTemp = sERROR) THEN --EL ARCHIVOFUE PROCESADO CON ERROR 
						--CREA REGISTRO DEL PROCESO DEL ARCHIVO
						LET vsDescripcionProceso = 'Registro de Reproceso del Archivo.';
						
						EXECUTE PROCEDURE BdiDomi:Sp_Domi_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso, 
						sPROCESANDO, vsCodRetorno, psNumEmpleado, 'sp_Domi_Receptor', TRIM(vsNomArchivo), vsFecha_Presentacion, '01'/*NO GUARDAR CCE_ARCHIVO*/ ) INTO vsCodRetorno2;
					END IF;
				
				ELSE --EL REGISTRO NO EXISTE
					--CREA REGISTRO DEL PROCESO DEL ARCHIVO
					LET vsDescripcionProceso = 'Registro de Procesamiento del Archivo.';
					
					EXECUTE PROCEDURE BdiDomi:Sp_Domi_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso, 
					sPROCESANDO, vsCodRetorno, psNumEmpleado, 'sp_Domi_Receptor', TRIM(vsNomArchivo), vsFecha_Presentacion, '01'/*NO GUARDAR CCE_ARCHIVO*/) INTO vsCodRetorno2;
					
				END IF;
				
				IF (vsCodRetorno = '00000') THEN -- VALIDA SI EL ARCHIVO ES APTO ÃÂÃÂÃÂÃÂ´PARA SER PROCESADO
				
					LET vsDescripcionProceso = 'Borrado de tablas de paso';
					--LIMPIA LAS TABLAS DE PARA PROCESAR EL NUEVOA ARCHIVO
					EXECUTE PROCEDURE BdiDomi:sp_Domi_MoverRegistrosHist (TRIM (vsNomArchivo), '', 'B') INTO vsCodRetorno;
					
					IF (vsCodRetorno = '00000') THEN -- VALIDA KE LAS TABLAS SE LIMPIARON CORRECTAMENTE 
					
						SET LOCK MODE TO WAIT 3;
						SET ISOLATION TO DIRTY READ;
						SELECT LIMIT 1 Valor INTO vsRuta FROM BdiDomi:Dom_Parametros WHERE Cod_Param = '01'; -- RUTA ARCHIVO PROCESAR
						
						--VALIDA QUE EL ARCHIVO EXISTA EN EL REPOSITORIO DE PROCESO
						EXECUTE PROCEDURE BdiDomi:Sp_Domi_BuscarArchivo( TRIM(vsRuta), TRIM(vsNomArchivo)) INTO vsCodRetorno, vsFlagUnico;
						
						IF ((vsCodRetorno = '00000') AND (vsFlagUnico = 'V')) THEN --VALIDA QUE EXISTA EL ARCHIVO EN EL REPOSITORIO
						
							LET vsDescripcionProceso = 'Carga del archivo a las tablas de paso';
							--CARGA EL ARCHIVO A LAS TABLAS
							EXECUTE PROCEDURE BdiDomi:sp_Domi_SubirArchivos(vsFlagTipoProceso, '01'/*RUTA ARCHIVO PROCESAR*/, TRIM(vsNomArchivo), psNumEmpleado) INTO vsCodRetorno, vsMensaje;
													
							IF (vsCodRetorno = '00000') THEN -- VALIDA KE EL ARCHIVO SE CARGO CORRECTAMENTE A LAS TABLAS
								
								SET LOCK MODE TO WAIT 3;
								SET ISOLATION TO DIRTY READ;
								SELECT LIMIT 1 Fecha_Presentacion INTO vsFecha_Presentacion FROM BdiDomi:Dom_cce_Encabezado_Paso WHERE Nombre_Arch = TRIM(vsNomArchivo) ;
								
								UPDATE bdidomi: dom_cce_archivos SET fecha_presentacion = vsFecha_Presentacion where Nombre_Arch = TRIM(vsNomArchivo) AND fecha_presentacion = "";
								LET vsDescripcionProceso = 'Validacion de Integridad del Archivo.';
								--INTEGRIDAD DEL ARCHIVO
								EXECUTE PROCEDURE BdiDomi:Sp_Domi_Valida_Datos( TRIM(vsNomArchivo), vsFecha_Presentacion, 'S' /*SALIDA CECOBAN*/, viTipoArchivo, 'R' /*RECEPTOR*/, TRIM(vsNomProceso) ) INTO vsCodRetorno, vsBloque;
								
								IF (vsCodRetorno = '00000') THEN --VALIDA LA INTEGRIDAD DEL ARCHIVO
								
									IF (viTipoArchivo = 34) THEN --ARCHIVO 34
									
										SELECT MAX(fecha_aplica) INTO vSFecha_aplica 
										FROM bdidomi:dom_cce_detalle_paso WHERE Nombre_Arch = TRIM(vsNomArchivo)  AND fecha_presentacion = vsFecha_Presentacion;
									
									ELSE
									
										SELECT unique(fecha_aplica) INTO vSFecha_aplica 
										FROM bdidomi:dom_cce_detalle_paso WHERE Nombre_Arch = TRIM(vsNomArchivo)  AND fecha_presentacion = vsFecha_Presentacion;
									
									END IF;
										
									LET vdFecha_aplicaDe = Substr(vSFecha_aplica,5,2) || "/" || Substr(vSFecha_aplica,7,2) || "/" || Substr(vSFecha_aplica,1,4);
									
									UPDATE bdidomi: dom_cce_archivos SET fecha_aplicacion = vdFecha_aplicaDe 
									WHERE Nombre_Arch = TRIM(vsNomArchivo)  AND fecha_presentacion = vsFecha_Presentacion;
										
									LET vsDescripcionProceso = 'Procesamiento del Archivo Original.';
									IF (viTipoArchivo = 11) THEN --ARCHIVO 11
										--EXECUTE PROCEDURE BdiDomi:Sp_Domi_ProcesarArchivo11 (TRIM(vsNomArchivo)) INTO vsCodRetorno;
										EXECUTE PROCEDURE "informix".Sp_Domi_ProcesarArchivo11 ('02', TRIM(vsNomArchivo), psNumEmpleado) INTO vsCodRetorno, vsMensaje;
										UPDATE BdiDomi:Dom_CCE_Detalle_Paso SET cve_Estatus = '01' WHERE Nombre_Arch = TRIM(vsNomArchivo) AND motivo_dev = '99' ;
										UPDATE BdiDomi:Dom_CCE_Detalle_Paso SET cve_Estatus = '02' WHERE Nombre_Arch = TRIM(vsNomArchivo) AND motivo_dev <> '99';
									ELIF (viTipoArchivo = 31) THEN --ARCHIVO 31 
										--EXECUTE PROCEDURE BdiDomi:Sp_Domi_ProcesarArchivo31 (TRIM(vsNomArchivo)) INTO vsCodRetorno;
										EXECUTE PROCEDURE Sp_Domi_ProcesarArchivo31(TRIM(vsNomArchivo), vsFecha_Presentacion, psNumEmpleado) INTO vsCodRetorno;
										UPDATE BdiDomi:Dom_CCE_Detalle_Paso SET cve_Estatus = '02' WHERE Nombre_Arch = TRIM(vsNomArchivo) ;
									ELIF (viTipoArchivo = 32) THEN --ARCHIVO 32
										--EXECUTE PROCEDURE BdiDomi:Sp_Domi_ProcesarArchivo32 (TRIM(vsNomArchivo)) INTO vsCodRetorno;
										EXECUTE PROCEDURE BdiDomi:Sp_Domi_ProcesarArchivo32 (TRIM(vsNomArchivo), psNumEmpleado) INTO vsCodRetorno;
										UPDATE BdiDomi:Dom_CCE_Detalle_Paso SET cve_Estatus = '01' WHERE Nombre_Arch = TRIM(vsNomArchivo) ;
									ELIF (viTipoArchivo = 34) THEN --ARCHIVO 34
										--EXECUTE PROCEDURE BdiDomi:Sp_Domi_ProcesarArchivo34 (TRIM(vsNomArchivo)) INTO vsCodRetorno;
										EXECUTE PROCEDURE sp_domi_ProcesarArchivo34 (TRIM(vsNomArchivo), psNumEmpleado) INTO vsCodRetorno, vsMensaje;
										IF (vsCodRetorno = '00000') THEN
											UPDATE BdiDomi:Dom_CCE_Detalle_Paso SET cve_Estatus = '01' WHERE Nombre_Arch = TRIM(vsNomArchivo) ;
										END IF ;
									ELIF (viTipoArchivo = 36) THEN --ARCHIVO 36
										EXECUTE PROCEDURE BdiDomi:Sp_Domi_ProcesarArchivo36 (TRIM(vsNomArchivo), psNumEmpleado) INTO vsCodRetorno;
										UPDATE BdiDomi:Dom_CCE_Detalle_Paso SET cve_Estatus = '01' WHERE Nombre_Arch = TRIM(vsNomArchivo) ;
									END IF;
									
									IF (vsCodRetorno = '00000') THEN --VALIDA KE EL ARCHIVO SE PROCESO CORRECTAMENTE
										
										LET vsDescripcionProceso = 'Mover Registros Procesados a la Tabla de Historico.';
										--ARCHIVO ORIGINAL
										--EXECUTE PROCEDURE BdiDomi:sp_Domi_MoverRegistrosHist (TRIM (vsNomArchivo), vdtFecha, 'T') INTO vsCodRetorno;
										EXECUTE PROCEDURE BdiDomi:sp_Domi_MoverRegistrosHist (TRIM (vsNomArchivo), vsFecha_Presentacion, 'T') INTO vsCodRetorno;
										
										IF (vsCodRetorno = '00000') THEN -- VALIDA QUE LOS DATOS DEL ARCHIVO SE TRANSFIRIERON CORRECTAMENTE A LOS HISTORICOS
											
											LET vsDescripcionProceso = 'Mover Archivo Procesado al Repositorio Historico.';
											EXECUTE PROCEDURE BdiDomi:Sp_Domi_MoverArchivos (TRIM (vsNomArchivo), '01' /*RUTA  ARCHIVO PROCESAR*/, '03' /*RUTA ARCVHIVOS PROCESADOS*/ ) INTO vsCodRetorno;
											
											IF (vsCodRetorno = '00000') THEN -- VALIDA KE EL ARCHIVO ORIGINAL SE PASO CORRECTAMENTE AL REPOSITORIO HISTORICO
												--GUARDA BITACORA EXITO
												LET vsDescripcionProceso = 'Domiciliacion Finalizada Exitosamente.';
												LET vsCodRetorno = '00000';
												EXECUTE PROCEDURE BdiDomi:Sp_Domi_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso, 
												sFINALIZADO, vsCodRetorno, psNumEmpleado, 'sp_Domi_Receptor', TRIM(vsNomArchivo), vsFecha_Presentacion, '02'/*EXITO*/ ) INTO vsCodRetorno2;
												
												EXECUTE PROCEDURE Sp_Domi_GuardarCCEArchivos (psNumEmpleado, TRIM (vsNomArchivo), vsFecha_Presentacion, '02') INTO vsCodRetorno2;
												
											ELSE --ERROR DE PASO DE ARCHIVO ORIGINAL AL REPOSITORIO DE HISTORICO
												--GUARDAR BITACORA
												EXECUTE PROCEDURE BdiDomi:Sp_Domi_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso, 
												sERROR, vsCodRetorno, psNumEmpleado, 'Sp_Domi_MoverArchivos', TRIM(vsNomArchivo), vsFecha_Presentacion, '01'/* GUARDAR CCE_ARCHIVO*/) INTO vsCodRetorno2;
												LET vsCodRetorno = '01430';
											END IF;
											
										ELSE --ERROR AL MOVER LOS REGISTROS DEL ARCHIVO ORIGINAL AL HITORICO
											--GUARDAR BITACORA
											EXECUTE PROCEDURE BdiDomi:Sp_Domi_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso, 
											sERROR, vsCodRetorno, psNumEmpleado, 'sp_Domi_MoverRegistrosHist', TRIM(vsNomArchivo), vsFecha_Presentacion, '01'/* GUARDAR CCE_ARCHIVO*/ ) INTO vsCodRetorno2;
											LET vsCodRetorno = '01424';
										END IF;
										
									ELSE --ERROR AL PROCESAR EL ARCHIVO
										
										--GUARDAR BITACORA
										EXECUTE PROCEDURE BdiDomi:Sp_Domi_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso, 
											sERROR, vsCodRetorno, psNumEmpleado, 'Sp_Domi_ProcesarArchivo' || viTipoArchivo::CHAR(2), TRIM(vsNomArchivo), vsFecha_Presentacion, '03'/* RECHAZADO*/ ) INTO vsCodRetorno2;
										
										LET vsCodRetorno = '01423';
									END IF;
									
								ELSE --ERROR DE INTEGRIDAD EN EL ARCHIVO
									--GUARDAR BITACORA
									EXECUTE PROCEDURE BdiDomi:Sp_Domi_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso, 
									sERROR, vsCodRetorno, psNumEmpleado, 'Sp_Domi_Valida_Datos', TRIM(vsNomArchivo), vsFecha_Presentacion, '03'/* RECHAZADO*/) INTO vsCodRetorno2;
									
									EXECUTE PROCEDURE BdiDomi:Sp_Domi_MoverArchivos (TRIM (vsNomArchivo), '01' /*RUTA  ARCHIVO PROCESAR*/, '04' /*RUTA ARCVHIVOS ERRONEOS*/ ) INTO vsCodRetorno;
									
									IF (vsCodRetorno <> '00000') THEN --ERROR DE TRANSFERENCIA DE ARCHIVO
										EXECUTE PROCEDURE BdiDomi:Sp_Domi_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso, 
										sERROR, vsCodRetorno, psNumEmpleado, 'Sp_Domi_ValidarNombreArchivos', TRIM(vsNomArchivo), vsFecha_Presentacion, '03'/*RECHAZADO*/ ) INTO vsCodRetorno2;
									END IF; 
									
									LET vsCodRetorno = '01422';
								END IF;
								
							ELSE -- ERROR AL CARGAR EL ARCHIVO A LAS TABLAS DE PASO
								IF (vsCodRetorno = '00411') THEN
									--GUARDAR BITACORA
									EXECUTE PROCEDURE BdiDomi:Sp_Domi_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso, 
									sERROR, vsCodRetorno, psNumEmpleado, 'sp_Domi_SubirArchivos', TRIM(vsNomArchivo), vsFecha_Presentacion, '01'/*GUARDAR CCE_ARCHIVO*/ ) INTO vsCodRetorno2;
									LET vsCodRetorno = '01426';								
								ELSE										
									--GUARDAR BITACORA
									EXECUTE PROCEDURE BdiDomi:Sp_Domi_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso, 
									sERROR, vsCodRetorno, psNumEmpleado, 'sp_Domi_SubirArchivos', TRIM(vsNomArchivo), vsFecha_Presentacion, '01'/*GUARDAR CCE_ARCHIVO*/ ) INTO vsCodRetorno2;
									LET vsCodRetorno = '01421';										
								END IF;									
							END IF;						
														
						ELSE --NO EXISTE EL ARCHIVO
							EXECUTE PROCEDURE BdiDomi:Sp_Domi_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso, 
							sERROR, vsCodRetorno, psNumEmpleado, 'Sp_Domi_BuscarArchivo', TRIM(vsNomArchivo) , vsFecha_Presentacion, '11'/*NO GUARDAR CCE_ARCHIVO*/ ) INTO vsCodRetorno2;
							LET vsCodRetorno = '01426';
						END IF;
					ELSE -- ERROR AL LIMPIAR LAS TABLAS
						--GUARDAR BITACORA
						EXECUTE PROCEDURE BdiDomi:Sp_Domi_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso, 
						sERROR, vsCodRetorno, psNumEmpleado, 'sp_Domi_SubirArchivos', TRIM(vsNomArchivo), vsFecha_Presentacion, '01'/*GUARDAR CCE_ARCHIVO*/ ) INTO vsCodRetorno2;
						LET vsCodRetorno = '01425';
					END IF; 
				ELSE --EL ARCHIVO NO ES APTO PARA SER PROCESADO
				
				END IF;
			ELSE -- NOMBRE DE ARCHIVO ERRONEO
				--GRABAR EN LA BITACORA  vsCodRetorno
				EXECUTE PROCEDURE BdiDomi:Sp_Domi_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso, 
				sERROR, vsCodRetorno, psNumEmpleado, 'Sp_Domi_ValidarNombreArchivos', TRIM(vsNomArchivo), vsFecha_Presentacion, '01'/*GUARDAR CCE_ARCHIVO*/ ) INTO vsCodRetorno2;
				
				SET LOCK MODE TO WAIT 3;
				SET ISOLATION TO DIRTY READ;
				SELECT LIMIT 1 Valor INTO vsRuta FROM BdiDomi:Dom_Parametros WHERE Cod_Param = '01'; -- RUTA ARCHIVO PROCESAR
				
				--VALIDA QUE EL ARCHIVO EXISTA EN EL REPOSITORIO DE PROCESO
				EXECUTE PROCEDURE BdiDomi:Sp_Domi_BuscarArchivo( TRIM(vsRuta), TRIM(vsNomArchivo)) INTO vsCodRetorno, vsFlagUnico;
				
				IF ((vsCodRetorno = '00000') AND (vsFlagUnico = 'V')) THEN --VALIDA QUE EXISTA EL ARCHIVO EN EL REPOSITORIO
					
					EXECUTE PROCEDURE BdiDomi:Sp_Domi_MoverArchivos (TRIM (vsNomArchivo), '01' /*RUTA  ARCHIVO PROCESAR*/, '04' /*RUTA ARCVHIVOS ERRONEOS*/ ) INTO vsCodRetorno;
					
					IF (vsCodRetorno <> '00000') THEN --ERROR DE TRANSFERENCIA DE ARCHIVO
						EXECUTE PROCEDURE BdiDomi:Sp_Domi_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso, 
						sERROR, vsCodRetorno, psNumEmpleado, 'Sp_Domi_ValidarNombreArchivos', TRIM(vsNomArchivo), vsFecha_Presentacion, '03'/*RECHAZADO*/ ) INTO vsCodRetorno2;
					END IF; 
				END IF;
				
				LET vsCodRetorno = '01418';
			END IF;
		
			EXECUTE PROCEDURE BdiDomi:sp_ObtenerMensajeError(vsCodRetorno) INTO vsCodRetorno2, vsMensaje_Respuesta;
			RETURN vsNomArchivo, vsCodRetorno, vsMensaje_Respuesta WITH RESUME; 
			
			IF EXISTS(SELECT descripcion FROM BdiDomi:Dom_Procesos WHERE Fecha_Proceso = vdtFecha AND TRIM(Cve_Proceso) = TRIM(vsNomProceso) AND Estatus = sPROCESANDO ) THEN  --EL ARCHIVO SE ENCUENTRA PROCESANDO
				IF (vsCodRetorno <> '01420') THEN --VALIDA SI EL ERROR ES DISTINTO DE 'PROCESANDO'
					UPDATE BdiDomi:Dom_Procesos SET Estatus = sERROR WHERE Fecha_Proceso = vdtFecha AND TRIM(Cve_Proceso) = TRIM(vsNomProceso) AND Estatus = sPROCESANDO ;
				END IF;
			END IF;
			
		END WHILE;
		
		--SE OBTIENE NUMERO DE CLIENTE COPPEL
		SELECT TRIM(valor) 
		INTO cNumCteCoppel FROM dom_parametros
		WHERE cod_param = '45';
		
		--SE OBTIENE NUMERO DE CUENTA COPPEL
		SELECT TRIM(valor) 
		INTO cCuentaAbono_Prov FROM dom_parametros
		WHERE cod_param = '46';
				
		LET cNom_Arch_Salida = 	'S'||
								TRIM(cNumCteCoppel)||
								'D'||
								LPAD(DAY(vdtFecha),2,'0') || 	LPAD(MONTH(vdtFecha),2,'0') || SUBSTR(YEAR(vdtFecha)::CHAR(4),3,2)||
								'.'||
								'01';
								
		IF EXISTS(SELECT 1 FROM dom_cte_detalle_paso WHERE nombre_arch = cNom_Arch_Salida) THEN
			
			IF EXISTS (SELECT 1 FROM dom_cte_archivos WHERE nombre_arch = cNom_Arch_Salida) THEN
				DELETE FROM  dom_cte_sumario WHERE nombre_arch = cNom_Arch_Salida;
				DELETE FROM  dom_cte_encabezado WHERE nombre_arch = cNom_Arch_Salida;
				DELETE FROM  dom_cte_archivos WHERE nombre_arch = cNom_Arch_Salida;
			END IF;
			
			--INSERTA EN ARCHIVOS
			INSERT INTO dom_cte_archivos(nombre_arch, fecha_envio, num_cte, fecha_carga, cve_status, user_insert, fecha_insert)
			VALUES (cNom_Arch_Salida, vdtFecha, cNumCteCoppel, vdtFecha, '01', psNumEmpleado, CURRENT::DATE);
			
			LET cNumCteCoppel = LPAD(TRIM(cNumCteCoppel), 20,'0');
			
			--INSERTA EN ENCABEZADO
			INSERT INTO dom_cte_encabezado(nombre_arch, fecha_envio, tipo_registro, num_cte, cuenta_abono, 
						num_operaciones, 
						fecha_inicial, fecha_final, user_insert, fecha_insert)
			SELECT LIMIT 1 nombre_arch, vdtFecha, 'E', cNumCteCoppel, LPAD(TRIM(cCuentaAbono_Prov),20,'0'), 
				   LPAD((SELECT COUNT(*)	FROM dom_cte_detalle_paso WHERE nombre_arch = cNom_Arch_Salida),8,'0'),
				   (SELECT MIN(fecha_cargo) FROM dom_cte_detalle_paso WHERE nombre_arch = cNom_Arch_Salida),
				   (SELECT MAX(fecha_cargo) FROM dom_cte_detalle_paso WHERE nombre_arch = cNom_Arch_Salida),
				   psNumEmpleado, CURRENT::DATE
			FROM dom_cte_detalle_paso 
			WHERE nombre_arch = cNom_Arch_Salida;
			
			---INSERTA DE LA TABLA DETALLE_PASO A LA DE DETALLE MAESTRA
			INSERT INTO dom_cte_detalle (nombre_arch,fecha_envio,tipo_registro,consecutivo,fecha_cargo, fecha_abono, tipo_cta_cargo, cve_banco_cargo,
			cuenta_cargo, rfc_cargo, nombre_cargo, cuenta_abono, imp_operacion, imp_iva, ref_numerica, ref_leyenda, ref_servicio,
			ref_titular_serv, accion, reintentar_cuenta, estatus,
			causa_rechazo, nombre_arch_cce, fecha_presentacion_cce, tipo_registro_cce, numero_secuencia_cce, comision_cobrada, iva_cobrado, user_insert,
			fecha_insert, tipo_cta_abono)
			SELECT nombre_arch,fecha_envio,tipo_registro,consecutivo,fecha_cargo, fecha_abono, tipo_cta_cargo, cve_banco_cargo,
			cuenta_cargo, rfc_cargo, nombre_cargo, cuenta_abono, imp_operacion, imp_iva, ref_numerica, ref_leyenda, ref_servicio,
			ref_titular_serv, accion, reintentar_cuenta, estatus,
			causa_rechazo, nombre_arch_cce, fecha_presentacion_cce, tipo_registro_cce, numero_secuencia_cce, comision_cobrada, iva_cobrado, user_insert,
			fecha_insert, tipo_cta_abono
			FROM dom_cte_detalle_paso
			WHERE nombre_arch = cNom_Arch_Salida;
			
			--INSERTA EN SUMARIO
			INSERT INTO dom_cte_sumario(nombre_arch, fecha_envio, tipo_registro, num_operaciones, imp_operaciones, num_oper_pend, imp_oper_pend, num_oper_apli, 
						imp_oper_apli, num_oper_rech, imp_oper_rech, user_insert, fecha_insert)
			SELECT LIMIT 1 nombre_arch, vdtFecha, 'S', LPAD((SELECT COUNT(*)	FROM dom_cte_detalle_paso WHERE nombre_arch = cNom_Arch_Salida),8,'0'),
			(SELECT LPAD( NVL(SUM(imp_operacion::INTEGER),0),18,'0') FROM dom_cte_detalle_paso WHERE nombre_arch = cNom_Arch_Salida),
			LPAD ((SELECT COUNT (*) FROM dom_cte_detalle_paso WHERE nombre_arch = cNom_Arch_Salida AND estatus = '02' AND causa_rechazo = 'PR'),8, '0'), 
			(SELECT LPAD( NVL(SUM(imp_operacion::INTEGER),0),18,'0') FROM dom_cte_detalle_paso WHERE nombre_arch = cNom_Arch_Salida AND estatus = '02' AND causa_rechazo = 'PR'),
			LPAD ((SELECT COUNT (*) FROM dom_cte_detalle_paso WHERE nombre_arch = cNom_Arch_Salida AND estatus = '01'),8, '0'), 
			(SELECT LPAD( NVL(SUM(imp_operacion::INTEGER),0),18,'0') FROM dom_cte_detalle_paso WHERE nombre_arch = cNom_Arch_Salida AND estatus = '01'),
			LPAD ((SELECT COUNT (*) FROM dom_cte_detalle_paso WHERE nombre_arch = cNom_Arch_Salida AND estatus = '02' AND causa_rechazo <> 'PR'),8, '0'),
			(SELECT LPAD( NVL(SUM(imp_operacion::INTEGER),0),18,'0') FROM dom_cte_detalle_paso WHERE nombre_arch = cNom_Arch_Salida AND estatus = '02' AND causa_rechazo <> 'PR'),
			psNumEmpleado, CURRENT::DATE
			FROM dom_cte_detalle_paso 
			WHERE nombre_arch = cNom_Arch_Salida;	

			TRUNCATE TABLE dom_cte_detalle_paso;
		
			EXECUTE PROCEDURE "informix".sp_domi_cop_generaarchivo(cNom_Arch_Salida, '02') INTO cCodret;	
			
		END IF;
	ELSE -- PARAMETRO NO ENCONTRADO
		EXECUTE PROCEDURE BdiDomi:sp_ObtenerMensajeError(vsCodRetorno) INTO vsCodRetorno2, vsMensaje_Respuesta;
		RETURN 'GENERAL', vsCodRetorno, vsMensaje_Respuesta;
		--LET vsCodRetorno = '01431'
	END IF;
	
END

END PROCEDURE;
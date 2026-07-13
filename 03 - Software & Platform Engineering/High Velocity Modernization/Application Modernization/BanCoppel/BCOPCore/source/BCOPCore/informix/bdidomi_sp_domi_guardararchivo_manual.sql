CREATE PROCEDURE "informix".sp_domi_guardararchivo_manual(
	p_sNombreCargo	 			CHAR(40), 
	p_sCuentaAbono  			CHAR(20), 
	p_sTipoCtaAbono 			CHAR(2),
	p_sImpOperacion 			CHAR(15), 
	p_sCuentaCargo 			 	CHAR(20),
	p_sTipoCtaCargo 			CHAR(2),
	p_sCveBancoCargo 			CHAR(3),
	p_sUserInsert 				CHAR(8),
	p_sTipoDomiciliacion 		CHAR(2),
	p_sFechaPago 				CHAR(8),
	p_sFechaInicio				CHAR(8),
	p_sFechaFin					CHAR(8),
	p_sRfcCargo				 	CHAR(13),
	p_sFolioActivacion 			CHAR(20),
	p_sReferenciaNumerica 	 	CHAR(7),
	p_sAccion 					CHAR(1),
	p_sPeriodo					CHAR(2),
	p_sEstatus					CHAR(2),
	p_sNumCliente				CHAR(9)
)
	RETURNING 	CHAR(5) AS CodigoRetorno,
				CHAR(100)	AS v_generico1,
				CHAR(100)	AS v_generico2,
				CHAR(100)	AS v_generico3,
				CHAR(100)	AS v_generico4;
	
	--Declaracion de  Variables
	DEFINE sql_err 				INTEGER;
	DEFINE cInTransaction	 	CHAR(1);  

	DEFINE sCodret 				CHAR(5);
	DEFINE sNombreArchivo		CHAR(20);

	DEFINE dFechaInsert 		DATE;
	DEFINE dFechaPago 			DATE;
	DEFINE dFechaInicio 		DATE;
	DEFINE dFechaFin 			DATE;
	DEFINE dFechaNotificacion	DATE;
	DEFINE dFechaProximoPago	DATE;
	DEFINE dFechaHoy			DATE;

	DEFINE sFormarYear			CHAR(10);
	DEFINE sFormarMes			CHAR(10);
	DEFINE sFormarFecha			CHAR(10);
	DEFINE sFormarDia			CHAR(10);
	DEFINE sUnirMesDia 			CHAR(10);
	DEFINE sTipoRegistro 		CHAR(1);
	DEFINE sReintentarCuenta  	CHAR(1);
	DEFINE sReferenciaLeyenda  	CHAR(50);
	DEFINE sReferenciaServicio  CHAR(50);
	DEFINE sTipo 				CHAR(1);
	DEFINE sIva					CHAR(15);
	DEFINE sConsecutivoArchivo	CHAR(3);
	DEFINE cNumCte_proveedor	CHAR(9);
	DEFINE diasPrevios			CHAR(2);
	DEFINE sImpOperacion		CHAR(15);
	DEFINE cCodret2				CHAR(5);
	DEFINE cMensajeRespuesta 	CHAR (110);
	DEFINE iNumIntentos			INTEGER;
	DEFINE iRegistros			INTEGER;
	DEFINE v_generico1			CHAR (110);
	DEFINE v_generico2			CHAR (110);
	DEFINE v_generico3			CHAR (110);
	DEFINE v_generico4			CHAR (110);
	DEFINE sFechaCargoAbono		CHAR(10);

	--Inicializar Variables
	LET sql_err 			= 0;
	LET sCodret 			= '00000';	
	LET cInTransaction      = 'N';
	LET sNombreArchivo 		= '';
	LET sTipoRegistro 	 	= 'B';
	LET sReintentarCuenta 	= 'S';
	LET	dFechaInsert 		= current::DATE;
	LET sIva				= '000000000000000';
	LET sTipo				= '';
	LET sConsecutivoArchivo = '01';
	LET cNumCte_proveedor	= '';
	LET cCodret2			= '';
	LET cMensajeRespuesta	= '';
	LET diasPrevios			= '';
	LET v_generico1			= '';
	LET v_generico2			= '';
	LET v_generico3			= '';
	LET v_generico4			= '';
	LET iNumIntentos		= 0;
	LET iRegistros			= 0;
	LET sFechaCargoAbono	= '';

	LET sFormarYear 	= CONCAT(SUBSTR(TRIM(p_sFechaPago), 1,4),'-');
	LET sFormarMes 		= CONCAT(SUBSTR(TRIM(p_sFechaPago), 5,2),'-');
	LET sFormarDia		= SUBSTR(TRIM(p_sFechaPago), 7,2);
	LET sUnirMesDia		= CONCAT(TRIM(sFormarMes), TRIM(sFormarDia));
	LET sFormarFecha 	= CONCAT( TRIM(sFormarYear),  TRIM(sUnirMesDia));

	LET	dFechaPago 		=  to_date( TRIM(sFormarFecha), "%Y-%m-%d"); 
	LET sFechaCargoAbono	= TO_CHAR(dFechaPago, '%Y%m%d');

	--Convertimos la p_sFechaInicio de string a date.
	LET sFormarYear 	= CONCAT(SUBSTR(TRIM(p_sFechaInicio), 1,4),'-');
	LET sFormarMes 		= CONCAT(SUBSTR(TRIM(p_sFechaInicio), 5,2),'-');	
	LET sFormarDia		= SUBSTR(TRIM(p_sFechaInicio), 7,2);
	LET sUnirMesDia		= CONCAT(TRIM(sFormarMes), TRIM(sFormarDia));
	LET sFormarFecha 	= CONCAT( TRIM(sFormarYear),  TRIM(sUnirMesDia));

	LET	dFechaInicio 	= to_date( TRIM(sFormarFecha), "%Y-%m-%d");
	
	--Convertimos la p_sFechaFin de string a date.
	LET sFormarYear 	= CONCAT(SUBSTR(TRIM(p_sFechaFin), 1,4),'-');
	LET sFormarMes 		= CONCAT(SUBSTR(TRIM(p_sFechaFin), 5,2),'-');	
	LET sFormarDia		= SUBSTR(TRIM(p_sFechaFin), 7,2);
	LET sUnirMesDia		= CONCAT(TRIM(sFormarMes), TRIM(sFormarDia));
	LET sFormarFecha 	= CONCAT( TRIM(sFormarYear),  TRIM(sUnirMesDia));

	LET	dFechaFin 	= to_date( TRIM(sFormarFecha), "%Y-%m-%d"); 
	
	--***************************************************************************************
	--SET DEBUG FILE TO "/tmp/sp_dom_guardararchivo_manual.out";
	--TRACE ON;
	--***************************************************************************************
	
	BEGIN
		
		--Manejo de excepciones (errores)
		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
			
				IF cInTransaction = 'S' THEN 
					ROLLBACK WORK;
				END IF;
					
				LET sCodret = sql_err;
					
				--Insertamos a la tabla bdidomi:dom_errores los datos del error ocurrido.
				INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
				VALUES (CURRENT, CURRENT HOUR TO FRACTION, sCodret, '', 'sp_dom_guardararchivo_manual', TRIM(p_sFolioActivacion), p_sUserInsert, CURRENT);
			
				RETURN sCodret, v_generico1, v_generico2, v_generico3, v_generico4;
			END IF;
		END EXCEPTION;
		
		ON EXCEPTION IN (-535)
			--ROLLBACK WORK;
			COMMIT WORK;
			BEGIN WORK;
		END EXCEPTION WITH RESUME;
		
		--Valida parametros de entrada
	 	IF 
	 		NVL(p_sNombreCargo,'') = ''	 			 
			OR NVL(p_sCuentaAbono,'') = ''  			  
			OR NVL(p_sTipoCtaAbono,'') = ''				  
			OR NVL(p_sCuentaCargo,'') = '' 
			OR NVL(p_sTipoCtaCargo,'') = ''			
			OR NVL(p_sCveBancoCargo,'') = '' 			 
			OR NVL(p_sUserInsert,'') = '' 				 
			OR NVL(p_sTipoDomiciliacion,'') = '' 		 
			OR NVL(p_sFechaPago,'') = '' 				 
			OR NVL(p_sFechaInicio,'') = '' 			 
			OR NVL(p_sFechaFin,'') = ''				 
			OR NVL(p_sRfcCargo,'') = ''			 
			OR NVL(p_sFolioActivacion,'') = ''			 
		  	OR NVL(p_sReferenciaNumerica,'') = ''
		  	OR NVL(p_sAccion,'') = ''
			OR NVL(p_sPeriodo,'') = ''
			OR NVL(p_sImpOperacion, '') = ''
			OR NVL(p_sNumCliente, '') = ''
								 
	 	THEN
		 	
			LET sCodret='99929'; --PARAMETROS DE ENTRADA ESTAN EN BLANCO.
			
			--Obtenemos los datos del error ocurrido.
			EXECUTE PROCEDURE bdidomi:"informix".sp_obtenermensajeerror(sCodret) INTO cCodret2, cMensajeRespuesta;
				
			--Insertamos a la tabla bdidomi:dom_errores los datos del error ocurrido.
			INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
			VALUES (CURRENT, CURRENT HOUR TO FRACTION, sCodret, '', 'sp_dom_guardararchivo_manual', TRIM(p_sfolioActivacion) || '-' || TRIM(cMensajeRespuesta), p_sUserInsert, CURRENT);
			
			RETURN sCodret, v_generico1, v_generico2, v_generico3, v_generico4;
		
		END IF;
		
		--Validar si existe el tipo de domiciliacion en la tabla dom_cat_tipo.
	 	IF NOT EXISTS(SELECT 1 FROM bdidomi:"informix".dom_cat_tipo WHERE cve_tipo = p_sTipoDomiciliacion) THEN
			LET sCodret='99930'; --EL TIPO DE DOMICILIACION NO EXISTE.
			
			--Obtenemos los datos del error ocurrido.
			EXECUTE PROCEDURE bdidomi:"informix".sp_obtenermensajeerror(sCodret) INTO cCodret2, cMensajeRespuesta;
				
			--Insertamos a la tabla bdidomi:dom_errores los datos del error ocurrido.
			INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
			VALUES (CURRENT, CURRENT HOUR TO FRACTION, sCodret, '', 'sp_dom_guardararchivo_manual', TRIM(p_sfolioActivacion) || '-' || TRIM(cMensajeRespuesta), p_sUserInsert, CURRENT);
			
			RETURN sCodret, v_generico1, v_generico2, v_generico3, v_generico4;
		END IF;
		
		--Verificar si el registro ya existe.
		IF EXISTS(SELECT 1 FROM bdidomi:"informix".dom_archivomanual WHERE folio_activacion = p_sFolioActivacion AND accion = p_sAccion AND estatus = 'EP') THEN
			LET sCodret='99931'; --EL REGISTRO CON EL FOLIO INGRESADO YA EXISTE.
			
			--Obtenemos los datos del error ocurrido.
			EXECUTE PROCEDURE bdidomi:"informix".sp_obtenermensajeerror(sCodret) INTO cCodret2, cMensajeRespuesta;
				
			--Insertamos a la tabla bdidomi:dom_errores los datos del error ocurrido.
			INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
			VALUES (CURRENT, CURRENT HOUR TO FRACTION, sCodret, '', 'sp_dom_guardararchivo_manual', TRIM(p_sfolioActivacion) || '-' || TRIM(cMensajeRespuesta), p_sUserInsert, CURRENT);
			
			RETURN sCodret, v_generico1, v_generico2, v_generico3, v_generico4;
		END IF;
	
		--Generar nombre de archivo.
		IF (p_sTipoDomiciliacion = '01') THEN 
			LET sTipo = 'B'; 
			
			SELECT TRIM(valor) 
			INTO cNumCte_proveedor
			FROM  bdidomi:"informix".dom_parametros
			WHERE cod_param = '36';
			
			SELECT TRIM(valor) 
			INTO sReferenciaLeyenda
			FROM  bdidomi:"informix".dom_parametros
			WHERE cod_param = '58';
			
			SELECT TRIM(valor) 
			INTO sReferenciaServicio
			FROM  bdidomi:"informix".dom_parametros
			WHERE cod_param = '59';
			
		END IF;
		
		LET cNumCte_proveedor = TO_CHAR(TRIM(cNumCte_proveedor), "&&&&&&&&&");	
		
		SELECT fecha_hoy INTO dFechaHoy FROM bdinteg:"informix".si_fechas WHERE empresa = '001';
	
		
		--se genera nombre de archivo 
		LET sNombreArchivo = 'BX'||
								TRIM(cNumCte_proveedor)||
								'B'||
								LPAD(DAY(dFechaPago),2,'0') || LPAD(MONTH(dFechaPago),2,'0') || SUBSTR(YEAR(dFechaPago)::CHAR(4),3,2)||
								'01';
	
		--Formatear campos que llevan leading zeros
		LET p_sCuentaCargo = TO_CHAR(p_sCuentaCargo, "&&&&&&&&&&&&&&&&&&&&");
		LET p_sCuentaAbono = TO_CHAR(p_sCuentaAbono, "&&&&&&&&&&&&&&&&&&&&");
		LET sImpOperacion = REPLACE(p_sImpOperacion,".", "");
		LET sImpOperacion = TO_CHAR(sImpOperacion,"&&&&&&&&&&&&&&&");
		LET p_sReferenciaNumerica = TO_CHAR(p_sReferenciaNumerica,"&&&&&&&");
		
		SELECT COUNT(*) INTO iRegistros FROM bdidomi:"informix".dom_archivomanual WHERE folio_activacion = p_sFolioActivacion;

		IF (iRegistros > 0) THEN
			FOREACH
				SELECT FIRST 1 num_intento 
				INTO iNumIntentos
				FROM bdidomi:"informix".dom_archivomanual
				WHERE folio_activacion = p_sFolioActivacion
				ORDER BY fecha_insert DESC
			END FOREACH;
		END IF;
		
		
		BEGIN WORK;
			LET cInTransaction = 'S';
			
			LET dFechaProximoPago = dFechaPago;
			IF (p_sAccion = 'A') THEN 
				
				SELECT TRIM(valor) 
				INTO diasPrevios 
				FROM  bdidomi:"informix".dom_parametros
				WHERE cod_param = '52';
				
				--Si es tipo domi 01 y la fecha de pago cae en dia festivo (25 dic y 1 ene) se agrega un dÃ­a 
				IF (p_sTipoDomiciliacion = '01' AND 
					(MONTH(dFechaPago) = 12 AND DAY(dFechaPago) = 25 ) OR
					(MONTH(dFechaPago) = 1 AND DAY(dFechaPago) = 1)) THEN
					LET dFechaProximoPago = dFechaPago + 1;
				END IF;
				
				LET sFechaCargoAbono = TO_CHAR(dFechaProximoPago, '%Y%m%d');
			END IF;
			
			--Inserta en la tabla dom_archivomanual.
			INSERT INTO bdidomi:"informix".dom_archivomanual(
				folio_activacion, tipo_domi, nombre_arch, fecha_envio, tipo_registro, consecutivo, 
				fecha_cargo, fecha_abono, tipo_cta_cargo, cve_banco_cargo, cuenta_cargo, rfc_cargo, nombre_cargo, cuenta_abono, imp_operacion, imp_iva, ref_numerica, ref_leyenda, ref_servicio, ref_titular_serv, 
				accion, reintentar_cuenta, estatus, user_insert, fecha_insert, tipo_cta_abono,
				num_periodo, num_intento
			) 
			VALUES(
				p_sFolioActivacion, p_sTipoDomiciliacion, sNombreArchivo, dFechaProximoPago, sTipoRegistro, '000001', 
				sFechaCargoAbono, sFechaCargoAbono, p_sTipoCtaCargo, p_sCveBancoCargo, p_sCuentaCargo, p_sRfcCargo, p_sNombreCargo, p_sCuentaAbono, sImpOperacion, sIva, p_sReferenciaNumerica, sReferenciaLeyenda, sReferenciaServicio, p_sNombreCargo, p_sAccion, sReintentarCuenta, p_sEstatus, p_sUserInsert, dFechaInsert, p_sTipoCtaAbono,
				p_sPeriodo, iNumIntentos
			);
		
			
			
			IF (p_sAccion = 'A') THEN 
			
				--calcular fecha notificacion = fecha_pago - dÃ­as previos 
				LET dFechaNotificacion = dFechaPago - TO_NUMBER(diasPrevios);
				
				--si es tipo domi 01 y la fecha notificacion cae en dia festivo (25 dic y 1 ene) se resta un dÃ­a adicional 
				IF (p_sTipoDomiciliacion = '01' AND 
					(MONTH(dFechaNotificacion) = 12 AND DAY(dFechaNotificacion) = 25 ) OR
					(MONTH(dFechaNotificacion) = 1 AND DAY(dFechaNotificacion) = 1)) THEN
					LET dFechaNotificacion = dFechaNotificacion - 1;
				END IF;
				
					--Si el folio ya existe entonces hacer update fecha_prox_pago y fecha_notificacion
				IF EXISTS(SELECT 1 FROM bdidomi:"informix".dom_fecha_pago WHERE folio_activacion = p_sFolioActivacion) THEN
					UPDATE bdidomi:"informix".dom_fecha_pago 
					SET fecha_prox_pago = dFechaProximoPago, fecha_notificacion = dFechaNotificacion, fecha_inicio = dFechaProximoPago, fecha_fin = dFechaProximoPago
					WHERE folio_activacion = p_sFolioActivacion;
				ELSE 
					--Inserta en la tabla dom_fecha_pago 
					INSERT INTO bdidomi:"informix".dom_fecha_pago(folio_activacion, periodo, fecha_pago, fecha_prox_pago, fecha_inicio, fecha_fin, fecha_insert, user_insert, fecha_notificacion)
					VALUES(p_sFolioActivacion, p_sPeriodo, dFechaPago, dFechaProximoPago, dFechaInicio, dFechaFin, dFechaInsert, p_sUserInsert, dFechaNotificacion);
				END IF;
				
				--Si el folio ya existe entonces se omite insert
				IF NOT EXISTS(SELECT 1 FROM bdidomi:"informix".dom_pago WHERE folio_activacion = p_sFolioActivacion) THEN
					--Inserta en dom_pago 
				
					INSERT INTO "informix".dom_pago (folio_activacion,num_cliente,monto_proximo_pago,tipo_domi,fecha_insert,user_insert) 
					VALUES(p_sFolioActivacion, p_sNumCliente, p_sImpOperacion, p_sTipoDomiciliacion, dFechaInsert, p_sUserInsert);
				END IF;
		
			END IF;
			
		COMMIT WORK;
		LET cInTransaction = 'N';
		
		RETURN sCodret, v_generico1, v_generico2, v_generico3, v_generico4;
	END;
END PROCEDURE
DOCUMENT
'AUTOR      	: Derian Alejandro Sainz Zazueta',
'DESCRIPCION	: Se encarga de guardar el archivo de forma manual',
'FECHA      	: 08/02/2022',
'BD         	: BDIDOMI';

CREATE PROCEDURE "informix".sp_domi_valida_cuentatarjeta(pNumCuentaTarjeta CHAR(18), p_sUserStatus CHAR(8))
	RETURNING	CHAR (5) 	AS CodRet, --Codigo de Retorno
				CHAR (2) 	AS TipoCuenta, --Tipo de cuenta
				CHAR (3) 	AS ClaveBanco, --Clave del banco
				CHAR (40) 	AS NombreBanco, --Descripcion del banco
				CHAR (40) 	AS NombreCortoBanco, -- Nombre de Banco
				CHAR (12)	AS CuentaCredito, -- Numero de cuenta o credito
				CHAR (16)	AS NumTarjeta, --Numero de tarjeta
				CHAR (18)	AS Clabe; -- CLABE Interbancaria de la cuenta
					
	--DECLARACION DE VARIABLES	
	DEFINE sql_err					INTEGER;
	DEFINE cCodret					CHAR(5);
	DEFINE cNumTarjeta				CHAR(16);
	DEFINE bCuenta					BOOLEAN;
	DEFINE cBIN						CHAR(6);
	DEFINE cTipoCuenta				CHAR(2);
	DEFINE cClaveBanco				CHAR(3);
	DEFINE cNombreBanco				CHAR(40);
	DEFINE cNombreCortoBanco		CHAR(40);
	DEFINE cIdTipoCuenta			CHAR(1);
	DEFINE cCuentaCredito			CHAR(12);
	DEFINE cClabe					CHAR(18);
	DEFINE cCodret2					CHAR(5);
	DEFINE cMensajeRespuesta 		CHAR (110);
	DEFINE cProducto 				CHAR (4);
	DEFINE cNumCte 					CHAR (9);

	
	--Inicializar Variables
	LET sql_err					= 0;
	LET cCodret					= '00000';
	LET cNumTarjeta				= '';
	LET bCuenta					= 'f';
	LET cBIN					= '';
	LET cTipoCuenta				= '';
	LET cClaveBanco				= '';
	LET cNombreBanco			= '';
	LET cNombreCortoBanco		= '';
	LET cIdTipoCuenta			= '';
	LET cCuentaCredito			= '';
	LET cClabe 					='';
	LET cCodret2				= '';
	LET cMensajeRespuesta		= '';
	LET cProducto				= '';
	LET cNumCte					= '';

	
	--SET DEBUG FILE TO "/tmp/sp_domi_valida_cuentatarjeta.out"
	--TRACE ON;
	
	BEGIN
			
		--Manejo de excepciones (errores)
		ON EXCEPTION SET sql_err 
			IF sql_err <> 0 THEN
				LET cCodret = sql_err;
				
				INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error, Hora_Error, Cod_Error, Nombre_Arch, Sp_Llamado, Mensaje_Error, User_Insert, Fecha_Insert)
				VALUES (CURRENT, CURRENT HOUR TO FRACTION, cCodret, '', 'sp_domi_valida_cuentatarjeta', trim(pNumCuentaTarjeta), p_sUserStatus, CURRENT);
				
				--Regresa Resultados
				RETURN cCodret, cTipoCuenta, cClaveBanco, cNombreBanco, cNombreCortoBanco, cCuentaCredito, cNumTarjeta, cClabe;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		
		-- Se valida el parametro de entrada
		IF NVL(pNumCuentaTarjeta, '') = '' OR NVL(p_sUserStatus, '') = '' THEN
			LET cCodret = '99939'; --Parametros de entrada estan en blanco.
			
			EXECUTE PROCEDURE bdidomi:"informix".sp_obtenermensajeerror(cCodret) INTO cCodret2, cMensajeRespuesta;
	
			INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
			VALUES (CURRENT, CURRENT HOUR TO FRACTION, cCodret, '', 'sp_domi_valida_cuentatarjeta', trim(pNumCuentaTarjeta) || ' - ' || trim(cMensajeRespuesta), p_sUserStatus, CURRENT);
			
			 --Regresa Resultados
			RETURN cCodret, cTipoCuenta, cClaveBanco, cNombreBanco, cNombreCortoBanco, cCuentaCredito, cNumTarjeta, cClabe;
		END IF;
		

		IF LENGTH(pNumCuentaTarjeta) = 11 THEN
		-- Cuenta de debito
			LET bCuenta = 't'; -- El parametro de entrada pertenece a una cuenta
			
			SELECT producto INTO cProducto FROM bdicheq:"informix".sc_maechq WHERE cuenta = pNumCuentaTarjeta;
			
			IF NVL(cProducto, '') <> '1800' THEN
				IF EXISTS(
					SELECT DISTINCT 1 FROM bdicheq:"informix".sc_tarjeta
					WHERE cuenta = pNumCuentaTarjeta AND empresa = '001' AND tipo_tarjeta = 'T' 
					AND num_tarjeta <> '' 
				)
				THEN
					SELECT num_tarjeta 
					INTO cNumTarjeta
					FROM bdicheq:"informix".sc_tarjeta 
					WHERE cuenta = pNumCuentaTarjeta AND empresa = '001' AND tipo_tarjeta = 'T' AND num_tarjeta <> ''
					AND secuencia = (SELECT MAX(secuencia) FROM bdicheq:"informix".sc_tarjeta 
									 WHERE cuenta = pNumCuentaTarjeta AND tipo_tarjeta = 'T');
				END IF;
			END IF;
		
			SELECT cuenta, cuenta_clabe
			INTO cCuentaCredito, cClabe
			FROM bdicheq:"informix".sc_maechq 
			WHERE cuenta = pNumCuentaTarjeta 
			AND status_cta IN ('1','4','5')
			AND empresa = '001';
					
			--Se le asigna el numero de tarjeta al parametro de entrada para obtener el resto de informacion de retorno
			IF NVL(cNumTarjeta, '') != '' AND NVL(cClabe, '') != '' THEN
				LET pNumCuentaTarjeta = cClabe;
			ELIF NVL(cNumTarjeta, '') = '' AND NVL(cClabe, '') != '' AND NVL(cProducto, '') = '1800' THEN
				LET pNumCuentaTarjeta = cClabe;
			ELSE 
				LET cCodret = '99940'; --El numero de cuenta, tarjeta o clabe es incorrecto.
				LET cTipoCuenta = '';
				LET cClaveBanco = '';
				LET cNombreCortoBanco = '';
				
				EXECUTE PROCEDURE bdidomi:"informix".sp_obtenermensajeerror(cCodret) INTO cCodret2, cMensajeRespuesta;
	
				INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
				VALUES (CURRENT, CURRENT HOUR TO FRACTION, cCodret, '', 'sp_domi_valida_cuentatarjeta', trim(pNumCuentaTarjeta) || ' - ' || trim(cMensajeRespuesta), p_sUserStatus, CURRENT);
				
				RETURN cCodret, cTipoCuenta, cClaveBanco, cNombreBanco, cNombreCortoBanco, cCuentaCredito, cNumTarjeta, cClabe;

			END IF;
		END IF;
		
		IF LENGTH(pNumCuentaTarjeta) = 18 THEN
		-- Clabe Interbancaria		
			LET cClaveBanco = SUBSTR(pNumCuentaTarjeta,1,3);
			LET cTipoCuenta = '40';
			
			SELECT cuenta, cuenta_clabe
			INTO cCuentaCredito, cClabe
			FROM bdicheq:"informix".sc_maechq 
			WHERE cuenta_clabe = pNumCuentaTarjeta 
			AND status_cta IN ('1','4','5')
			AND empresa = '001';
			
			SELECT descripcion, vchrnombrecorto
			INTO cNombreBanco, cNombreCortoBanco
			FROM bdinteg:"informix".si_bancos 
			WHERE banco = cClaveBanco  and 
			flg_domi_r='1';
			
			--Si el parametro de entrada era una cuenta se define como 01
			IF (bCuenta = 't') THEN
				LET cTipoCuenta = '01';
			END IF;
			
			IF NVL(cTipoCuenta, '') = '' OR NVL(cClaveBanco, '') = '' OR NVL(cNombreBanco, '') = '' OR NVL(cNombreCortoBanco, '') = '' OR NVL(cCuentaCredito, '') = '' THEN
				LET cCodret = '99940'; --El numero de cuenta, tarjeta o clabe es incorrecto.
				LET cTipoCuenta = '';
				LET cClaveBanco = '';
				LET cNombreCortoBanco = '';
				
				EXECUTE PROCEDURE bdidomi:"informix".sp_obtenermensajeerror(cCodret) INTO cCodret2, cMensajeRespuesta;
	
				INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
				VALUES (CURRENT, CURRENT HOUR TO FRACTION, cCodret, '', 'sp_domi_valida_cuentatarjeta', trim(pNumCuentaTarjeta) || ' - ' || trim(cMensajeRespuesta), p_sUserStatus, CURRENT);
				
			END IF;
			
			RETURN cCodret, cTipoCuenta, cClaveBanco, cNombreBanco, cNombreCortoBanco, cCuentaCredito, cNumTarjeta, cClabe;
		END IF;

		IF LENGTH(pNumCuentaTarjeta) = 12 THEN
		--Numero de credito
			LET bCuenta = 't'; -- El parametro de entrada pertenece a una cuenta
			
			SELECT a.num_credito, a.cuenta_clabe, b.num_tarjeta
			INTO cCuentaCredito, cClabe, cNumTarjeta
			FROM bdicred:"informix".sd_maecred a
			INNER JOIN bdicred:"informix".sd_tarjeta b
			ON a.num_credito = b.num_credito
			WHERE a.status_cred IN('E1','E2','E3')
			AND a.num_credito = pNumCuentaTarjeta
			AND b.status_tar <> 'C'
			AND b.num_tarjeta <> ''
			AND b.tipo_tarjeta = 'T'
			AND b.secuencia = (SELECT MAX(secuencia) FROM bdicred:"informix".sd_tarjeta 
							   WHERE num_credito = pNumCuentaTarjeta AND tipo_tarjeta = 'T' AND status_tar <> 'C');
			
			--Se le asigna el numero de tarjeta al parametro de entrada para obtener el resto de informacion de retorno
			IF NVL(cNumTarjeta, '') != '' THEN
				LET pNumCuentaTarjeta = cNumTarjeta;
			ELSE 
				LET cCodret = '99940'; --El numero de cuenta, tarjeta o clabe es incorrecto.
				LET cTipoCuenta = '';
				LET cClaveBanco = '';
				LET cNombreCortoBanco = '';
				
				EXECUTE PROCEDURE bdidomi:"informix".sp_obtenermensajeerror(cCodret) INTO cCodret2, cMensajeRespuesta;
	
				INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
				VALUES (CURRENT, CURRENT HOUR TO FRACTION, cCodret, '', 'sp_domi_valida_cuentatarjeta', trim(pNumCuentaTarjeta) || ' - ' || trim(cMensajeRespuesta), p_sUserStatus, CURRENT);
				
				RETURN cCodret, cTipoCuenta, cClaveBanco, cNombreBanco, cNombreCortoBanco, cCuentaCredito, cNumTarjeta, cClabe;

			END IF;
		END IF;
			
		IF LENGTH(pNumCuentaTarjeta) = 16 THEN
		--Tarjeta
			LET cBIN = SUBSTR(pNumCuentaTarjeta,1,6);
				
			SELECT banco.banco, upper(bin.creditodebito), banco.descripcion, banco.vchrnombrecorto
			INTO cClaveBanco, cIdTipoCuenta, cNombreBanco, cNombreCortoBanco
			FROM bdicheq:"informix".sc_bines bin
			INNER JOIN bdinteg:"informix".si_bancos banco
			  ON bin.cve_banco = banco.banco
			WHERE bin.bin = cBIN
			AND banco.flg_domi_r = '1'; 

			 IF cIdTipoCuenta = 'D' THEN 
				LET cTipoCuenta='03';

				SELECT a.cuenta, b.num_tarjeta, a.cuenta_clabe
				INTO cCuentaCredito, cNumTarjeta, cClabe 
				FROM bdicheq:"informix".sc_maechq a
				INNER JOIN bdicheq:"informix".sc_tarjeta b
				ON a.cuenta = b.cuenta
				INNER JOIN intercard:"informix".tarjeta c 
				ON c.numtarjeta = b.num_tarjeta
				WHERE b.num_tarjeta= pNumCuentaTarjeta  
				AND c.codstatusasignada = 'SIA'
				AND a.status_cta IN ('1','4','5')
				AND b.status_tar = 'A'
				AND a.empresa = '001'
				AND codstatustarjeta in ('ACT', 'BLT', 'BLO')
				AND c.titular = 'T';
				
			  ELIF cIdTipoCuenta = 'C' THEN 
				LET cTipoCuenta = '05';
				
				SELECT a.num_credito, b.num_tarjeta 
				INTO cCuentaCredito, cNumTarjeta
				FROM bdicred:"informix".sd_maecred a
				INNER JOIN bdicred:"informix".sd_tarjeta b
				ON a.num_credito=b.num_credito
				INNER JOIN intercard:"informix".tarjeta c 
				ON c.numtarjeta = b.num_tarjeta
				WHERE a.status_cred IN('E1','E2','E3')
				AND b.num_tarjeta = pNumCuentaTarjeta
				AND c.codstatusasignada = 'SIA'
				AND b.status_tar <> 'C'
				AND codstatustarjeta in ('ACT', 'BLT', 'BLO')
				AND c.titular = 'T';

			END IF;
			
			--Si el parametro de entrada era una cuenta se define como 01
			IF (bCuenta = 't') THEN
				LET cTipoCuenta = '01';
			END IF;
			
			IF NVL(cTipoCuenta, '') = '' OR NVL(cClaveBanco, '') = '' OR NVL(cNombreBanco, '') = '' OR NVL(cNombreCortoBanco, '') = '' OR NVL(cCuentaCredito, '') = '' OR NVL(cNumTarjeta, '') = '' THEN
				LET cCodret = '99940'; --El numero de cuenta, tarjeta o clabe es incorrecto.
				LET cTipoCuenta = '';
				LET cClaveBanco = '';
				LET cNombreCortoBanco = '';
				
				EXECUTE PROCEDURE bdidomi:"informix".sp_obtenermensajeerror(cCodret) INTO cCodret2, cMensajeRespuesta;
	
				INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
				VALUES (CURRENT, CURRENT HOUR TO FRACTION, cCodret, '', 'sp_domi_valida_cuentatarjeta', trim(pNumCuentaTarjeta) || ' - ' || trim(cMensajeRespuesta), p_sUserStatus, CURRENT);
				
			END IF;
			
			RETURN cCodret, cTipoCuenta, cClaveBanco, cNombreBanco, cNombreCortoBanco, cCuentaCredito, cNumTarjeta, cClabe;
		ELSE
			LET cCodret = '99940'; --El numero de cuenta, tarjeta o clabe es incorrecto.
			
			EXECUTE PROCEDURE bdidomi:"informix".sp_obtenermensajeerror(cCodret) INTO cCodret2, cMensajeRespuesta;
	
			INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
			VALUES (CURRENT, CURRENT HOUR TO FRACTION, cCodret, '', 'sp_domi_valida_cuentatarjeta', trim(pNumCuentaTarjeta) || ' - ' || trim(cMensajeRespuesta), p_sUserStatus, CURRENT);
			
			RETURN cCodret, cTipoCuenta, cClaveBanco, cNombreBanco, cNombreCortoBanco, cCuentaCredito, cNumTarjeta, cClabe;

		END IF;
	END;
END PROCEDURE 
DOCUMENT
'AUTOR      : Edith Mendoza Barraza',
'DESCRIPCION: Se encarga de definir si se recibe cuenta, tarjeta o clabe asi como retornar la informacion del banco',
'FECHA      : 08/03/2022',
'BD         : BDIDOMI';

CREATE PROCEDURE "informix".sp_domi_generaarchivo(psNombreArchivo CHAR(20),psFechaPres CHAR(8),psId CHAR(2))
RETURNING CHAR(5) AS codret;

--****************************************************************************************************
-- DESCRIPCION: Guarda la estadística del consumo de la sucursal de manera mensual.
-- AUTOR : Rochin Rocha Edgar Ivan
-- FECHA : 16/07/2009
-- BD: bdidomi
-- SISTEMA : Domiciliacion
-- MODIFICADO : 05/08/2009 parametro recibido fecha insert reemplazado por fecha presentacion.
--****************************************************************************************************

DEFINE viSqlErr INTEGER;
DEFINE vsRepositorio CHAR(100);
DEFINE vsCodRet CHAR(5);
DEFINE vsSQL CHAR(2204);
--DEFINE vsSQL1 VARCHAR(100);
DEFINE vsSQL1 VARCHAR(255);
DEFINE vsSQL2 CHAR(2004);
DEFINE vsSQL3 CHAR(100);
DEFINE vsArchTemp CHAR(23);
DEFINE vsArchTemp1 CHAR(23);
DEFINE vsUsoFutBanc CHAR(12);
DEFINE cHora				CHAR(8);
DEFINE cFechaArchivoOUT		CHAR(15);
DEFINE iPaso				SMALLINT;

LET viSqlErr = 0;
LET vsRepositorio = '';
LET vsCodRet = '';
LET vsSQL = '';
LET vsSQL1 = '';
LET vsSQL2 = '';
LET vsSQL3 = '';
LET vsArchTemp = '';
LET vsArchTemp1 = '';
LET vsUsoFutBanc = '';

LET cHora	= TO_CHAR(EXTEND(CURRENT, HOUR TO SECOND),'%H:%M:%S');
LET cFechaArchivoOUT	= YEAR(CURRENT::DATE)||LPAD(MONTH(CURRENT::DATE),2,'0')||LPAD(DAY(CURRENT::DATE),2,'0')||SUBSTR(cHora,1,2)||SUBSTR(cHora,4,2)||SUBSTR(cHora,7,2)||'_';
LET iPaso	= 0;

BEGIN

ON EXCEPTION SET viSqlErr   --Cacha el error en caso de que exista y regresa un valor predeterminado.
        IF viSqlErr <> 0 THEN
        RETURN viSqlErr;
        END IF;
END EXCEPTION;
ON EXCEPTION IN(-668) SET viSqlErr	
	IF iPaso NOT IN(5,8,9,10,11,12) THEN 
		LET vsCodRet = viSqlErr;
		RETURN vsCodRet;
	END IF;
END EXCEPTION WITH RESUME;

SET ISOLATION DIRTY READ;
SET LOCK MODE TO wait 3;

--Se le quitan espacion en blanco a nombre de archivo
LET psNombreArchivo = TRIM(psNombreArchivo);

IF EXISTS(SELECT nombre_arch FROM bdidomi:dom_cce_encabezado_paso WHERE nombre_arch = psNombreArchivo)THEN
        IF EXISTS(SELECT cod_param FROM bdidomi:dom_parametros WHERE cod_param = psId)THEN
			--Selecciona el repositorio del archivo a generar.
			SELECT valor INTO vsRepositorio FROM bdidomi:dom_parametros WHERE cod_param = psId;
            --Genera archivo.
            LET vsArchTemp = cFechaArchivoOUT||'tmp1.txt';
            LET vsArchTemp1 = cFechaArchivoOUT||'tmp2.txt';
			
			LET iPaso = 1;
            LET vsSQL1 = 'echo "UNLOAD TO ' || TRIM(vsRepositorio) || TRIM (vsArchTemp) || ' DELIMITER ' || '''£''' || ' " > '|| TRIM(vsRepositorio) || cFechaArchivoOUT||'.sql';
			LET vsSQL1 = TRIM(vsSQL1);
			SYSTEM vsSQL1;
                
				
				
				LET vsSQL2 = 'echo "SELECT tpo_registro || num_secuencia || cod_operacion || cve_banco || sentido || servicio || num_bloque || fecha_presentacion ||'
                || " cod_divisa || cve_rechazo_bl || modalidad || '                                                                                                                                                                                                                                                                                                                                                                                                  Ø' FROM bdidomi:dom_cce_encabezado_paso WHERE nombre_arch = '"||psNombreArchivo||"' AND fecha_presentacion = '"||psFechaPres||"'"
                || " UNION"
                || " SELECT tipo_registro || num_secuencia || cod_operacion || cod_divisa || fecha_trans || banco_presentador || banco_receptor || importe ||"
                || " uso_futuro_ccen || tipo_operacion || fecha_aplica || tipo_cta_ord || num_cta_ord || nombre_ord || rfc_ord || tipo_cta_rec || num_cta_rec ||"
                || " nombre_rec || rfc_rec || ref_servicio || nombre_titular_serv || importe_iva || ref_numerica || ref_leyenda || clave_rastreo || motivo_dev || fecha_pres_ini ||"
                || " '            Ø' FROM bdidomi:dom_cce_detalle_paso WHERE nombre_arch = '"||psNombreArchivo||"' AND fecha_presentacion = '"||psFechaPres||"'"
                || " UNION"
                || " SELECT tipo_registro || num_secuencia || cod_operacion || num_bloque || num_operaciones ||"
                || " imp_operaciones || '                                                                                                                                                                                                                                                                                                                                                                                           Ø' FROM bdidomi:dom_cce_sumario_paso WHERE nombre_arch = '"||psNombreArchivo||"' AND fecha_presentacion = '"||psFechaPres||"'";

                LET vsSQL3 = ' " >> '|| TRIM(vsRepositorio) || cFechaArchivoOUT||'.sql';
                LET vsSQL3 = TRIM(vsSQL3);
                LET vsSQL = vsSQL2 || vsSQL3;
                --Verifica que no este vacia la consulta.
                IF ( vsSQL <> '' ) THEN
					SYSTEM vsSQL;
					--Permiso para la creacion de archivo.
					LET iPaso = 2;
					--Produccion
					LET vsSQL = '/ifxsif01/bin/dbaccess bdidomi ' || TRIM(vsRepositorio) || cFechaArchivoOUT||'.sql>> '||TRIM(vsRepositorio)||TRIM(cFechaArchivoOUT)||'.out 2>&1';
					
					
					
					--Desarrollo
					--LET vsSQL = '/informix/bin/dbaccess bdidomi ' || TRIM(vsRepositorio) || cFechaArchivoOUT||'.sql > '||TRIM(vsRepositorio)||TRIM(cFechaArchivoOUT)||'.out 2>&1';
					SYSTEM vsSQL ;
											
					--Elimina el caracter delimitador '?'.
					LET iPaso = 3;
					LET vsSQL =  "sed 's/£$//g' " || TRIM(vsRepositorio) || TRIM (vsArchTemp) || " > " || TRIM(vsRepositorio) || TRIM (vsArchTemp1);
					SYSTEM vsSQL;
					--Elimina el caracter delimitador 'x'.
					LET iPaso = 4;
					LET vsSQL =  "sed 's/Ø$//g' " || TRIM(vsRepositorio) || TRIM (vsArchTemp1) || " > " || TRIM(vsRepositorio) || TRIM (psNombreArchivo);
					SYSTEM vsSQL;

					--Operacion exitosa "Archivo Generado".
					--se dan permiso a todos para el archivo 
					LET iPaso = 5;
					--LET vsSQL = 'chmod 666 ' || TRIM(vsRepositorio) || TRIM (psNombreArchivo);
					LET vsSQL = 'chmod 777 ' || TRIM(vsRepositorio) || TRIM (psNombreArchivo);
					SYSTEM vsSQL ;
										
					LET iPaso = 6;
					LET vsSQL = 'cp ' || TRIM(vsRepositorio) || TRIM (psNombreArchivo)  ||' '|| TRIM(vsRepositorio)|| TRIM (psNombreArchivo)  ||'.resp';
					SYSTEM vsSQL;	
					
					--Borrar diagonales del archivo.
					LET iPaso = 7;
					LET vsSQL = 'grep -lr -e "1" ' || TRIM(vsRepositorio) || TRIM (psNombreArchivo)  ||'.resp | xargs sed ''s/\\\\/\\/g'' > '|| TRIM(vsRepositorio) || 
					TRIM (psNombreArchivo);
					SYSTEM vsSQL;
					
					LET iPaso = 8;
					LET vsSQL = 'rm '|| TRIM(vsRepositorio) || TRIM (psNombreArchivo)  ||'.resp';
					SYSTEM vsSQL;
					
					--Borra el archivo temporal.
					LET iPaso = 9;
					LET vsSQL = 'rm ' || TRIM(vsRepositorio) || TRIM(vsArchTemp);
					SYSTEM vsSQL;
					
					--Borra el archivo temporal1.
					LET iPaso = 10;
					LET vsSQL = 'rm ' || TRIM(vsRepositorio) || TRIM(vsArchTemp1);
					SYSTEM vsSQL;

					--Borra el archivo de control.
					LET iPaso = 11;
					LET vsSQL = 'rm ' || TRIM(vsRepositorio) || cFechaArchivoOUT||'.sql';
					SYSTEM vsSQL;
					
					LET iPaso = 12;
					LET vsSQL = 'rm ' || TRIM(vsRepositorio) || cFechaArchivoOUT||'.out';
					SYSTEM vsSQL;
					LET vsCodRet = '00000';
                ELSE
                        --No fue posible generar el archivo.
                    LET vsCodRet = '01002';
                END IF ;
        ELSE
        --El Id proporcionado no fue localizado.
        LET vsCodRet = '01001';
        END IF;
ELSE
        --El nombre del archivo proporcionado no fue localizado.
        LET vsCodRet = '01000';
END IF;

RETURN vsCodRet;

END;
END PROCEDURE;
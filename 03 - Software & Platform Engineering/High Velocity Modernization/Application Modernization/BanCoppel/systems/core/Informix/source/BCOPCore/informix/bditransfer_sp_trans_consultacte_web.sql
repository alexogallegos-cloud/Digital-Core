CREATE PROCEDURE "informix".sp_trans_consultacte_web(	pTpoTrans	CHAR(1), -- 1 = Deposito, ? 2 = Retiro.
														pTarjeta	CHAR(20),
														pCuenta		CHAR(20),
														pTelefono	CHAR(20))
	  RETURNING CHAR(5)   AS cCodinfx,
				CHAR(5)   AS cCodRet,
				CHAR(20)  AS cCuenta_tf, 
				CHAR(18)  AS cCta_clabe,
				CHAR(13)  AS cTelCelular,
				CHAR(1)   AS cStatus_cta,
				CHAR(20)  AS cNum_cte_ret,
				CHAR(20)  AS cNumcte_tf,
				CHAR(4)   AS cProducto,
				CHAR(100) AS cNombre,
				CHAR(10)  AS cFecha_nac,
				CHAR(13)  AS cRfc,
				CHAR(100) AS cCorreo,
				CHAR(18)  AS cCurp,
				CHAR(15)  AS cMet_notificacion,
				CHAR(8)   AS cEjecutivo,
				CHAR(10)  AS cFec_alta,
				CHAR(10)  AS cFec_cancelac,
				CHAR(10)  AS cFec_modific,
				CHAR(2)   AS cCod_ent_nac;
		
	--DEFINICION DE VARIABLES
	DEFINE iSqlErr 				INTEGER;
	DEFINE cCodinfx 			CHAR(5);
	DEFINE cCodRet 				CHAR(5);

	DEFINE cCuenta 		   		CHAR(20);
	DEFINE cApellpaterno   		CHAR(26); 
	DEFINE cApellmaterno   		CHAR(26);
	DEFINE cNombre1		   		CHAR(26);
	DEFINE cNombre2		   		CHAR(26);
	DEFINE cTelCelular	   		CHAR(13);
	DEFINE cNum_cte		   		CHAR(20);
	DEFINE cNum_cte_1	   		CHAR(20);
	DEFINE iNum_cte_fon	   		INTEGER;
	DEFINE iNumParams	   		INTEGER;

	DEFINE cCuenta_tf 			CHAR(20);
	DEFINE cCta_clabe			CHAR(18);
	DEFINE cStatus_cta			CHAR(1);
	DEFINE cNumcte_tf			CHAR(20);
	DEFINE cProducto			CHAR(4);
	DEFINE cFecha_nac			CHAR(10);
	DEFINE cRfc					CHAR(13);
	DEFINE cCorreo				CHAR(100);
	DEFINE cCurp				CHAR(18);
	DEFINE cMet_notificacion	CHAR(15);
	DEFINE cEjecutivo			CHAR(8);
	DEFINE cFec_alta			CHAR(10);
	DEFINE cFec_cancelac		CHAR(10);
	DEFINE cFec_modific			CHAR(10);
	DEFINE cCod_ent_nac			CHAR(2);
	DEFINE cNum_cte_ret 		CHAR(20);
	DEFINE cNombre		 		CHAR(100);

	--INICIALIZACION DE VARIABLES
	LET iSqlErr 			= 0;
	LET cCodinfx 			= '00000';
	LET cCodRet 			= '00000';

	LET cCuenta  			= '';
	LET cApellpaterno   	= ''; 
	LET cApellmaterno   	= '';
	LET cNombre1			= '';
	LET cNombre2			= '';
	LET cTelCelular	    	= '';
	LET cNum_cte			= '';
	--LET cNum_cte_tar		= '';
	LET iNum_cte_fon		= 0;

	LET cCuenta_tf  		= '';
	LET cCta_clabe			= '';
	LET cStatus_cta			= '';
	LET cNumcte_tf			= '';
	LET cProducto			= '';
	LET cFecha_nac			= '';
	LET cRfc				= '';
	LET cCorreo				= '';
	LET cCurp				= '';
	LET cMet_notificacion	= '';
	LET cEjecutivo			= '';
	LET cFec_alta			= '';
	LET cFec_cancelac		= '';
	LET cFec_modific		= '';
	LET cCod_ent_nac		= '';
	LET cNum_cte_ret		= '';
	LET cNombre				= '';
	LET iNumParams			= 0;

	-- SET DEBUG FILE TO '/home/sysifx/vlv/sp_trans_consultacte_web.out';
	-- TRACE ON;

	BEGIN
		ON EXCEPTION -- CONTROL DE ERROR DE INFORMIX
			SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodinfx = iSqlErr;
				RETURN cCodinfx,cCodRet,cCuenta_tf,cCta_clabe,cTelCelular,cStatus_cta,cNum_cte_ret,cNumcte_tf,cProducto,cNombre,
				cFecha_nac,cRfc,cCorreo,cCurp,cMet_notificacion,cEjecutivo,cFec_alta,cFec_cancelac,cFec_modific,cCod_ent_nac;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		-- SE VALIDA EL VALOR DE LA TRANSACCION
		IF NVL(pTpoTrans,'') = '' THEN
			LET cCodRet = '00832';
			RETURN cCodinfx,cCodRet,cCuenta_tf,cCta_clabe,cTelCelular,cStatus_cta,cNum_cte_ret,cNumcte_tf,cProducto,cNombre,cFecha_nac,cRfc,cCorreo,cCurp,cMet_notificacion,cEjecutivo,cFec_alta,cFec_cancelac,cFec_modific,cCod_ent_nac;
		END IF
		
		-- SE VALIDA QUE EL CLIENTE SOLO ENVIE UN CRITERIO DE CONSULTA
		IF NVL(pTarjeta,'') <> '' THEN
			LET iNumParams = iNumParams +1;
		END IF
		
		IF NVL(pCuenta,'') <> '' THEN
			LET iNumParams = iNumParams +1;
		END IF

		IF NVL(pTelefono,'') <> '' THEN
			LET iNumParams = iNumParams +1;
		END IF
		
		-- SE VALIDA QUE MINIMO 1 PARAMETRO DE LOS RESTANTES TENGA INFORMACIÃN
		IF iNumParams <> 1 THEN
			LET cCodRet = '00832';
		ELSE
			IF NVL(pTpoTrans,'') = 1 THEN			
				-- SI LA CONSULTA ES POR CUENTA O POR CELULAR
				IF (NVL(pCuenta,'') <> '') OR (NVL(pTelefono,'') <> '') THEN
					IF NVL(pCuenta,'') <> '' THEN
						-- LA CUENTA TIENE QUE SER DE 11 POSICIONES.
						IF LENGTH(TRIM(pCuenta)) <> 11 THEN
							LET cCodRet = '00831';
							RETURN cCodinfx,cCodRet,cCuenta_tf,cCta_clabe,cTelCelular,cStatus_cta,cNum_cte_ret,cNumcte_tf,cProducto,cNombre,cFecha_nac,cRfc,cCorreo,cCurp,cMet_notificacion,cEjecutivo,cFec_alta,cFec_cancelac,cFec_modific,cCod_ent_nac;
						ELSE
							LET cCuenta = TRIM(pCuenta);							
						
							SELECT cuenta_tf,cta_clabe,telefono,status_cta,numcte,numcte_tf,producto,nombre1,nombre2,apell_paterno,apell_materno,
							fecha_nac,rfc,correo,curp,met_notificacion,ejecutivo,fec_alta,fec_cancelac,fec_modific,cod_ent_nac
							INTO cCuenta_tf,cCta_clabe,cTelCelular,cStatus_cta,cNum_cte_ret,cNumcte_tf,cProducto,cNombre1,
							cNombre2,cApellpaterno,cApellmaterno,cFecha_nac,cRfc,cCorreo,cCurp,cMet_notificacion,cEjecutivo,
							cFec_alta,cFec_cancelac,cFec_modific,cCod_ent_nac
							FROM "informix".tf_maecte 
							WHERE cuenta_tf = cCuenta
								AND empresa = '001'
								AND status_cta = '1';

							IF NVL(cNumcte_tf,'') <> '' THEN
								LET cNombre = TRIM(cNombre1)||" "||TRIM(cNombre2)||" "||TRIM(cApellpaterno)||" "||TRIM(cApellmaterno);
							ELSE
								--EL CLIENTE TRANSFER NO EXISTE
								LET cCodRet = '00833';
							END IF							
						END IF	
					ELIF NVL(pTelefono,'') <> '' THEN
						-- EL TELEFONO TIENE QUE SER DE 10 POSICIONES.						
						IF LENGTH(TRIM(pTelefono)) <> 10 THEN
							LET cCodRet = '00831';
							RETURN cCodinfx,cCodRet,cCuenta_tf,cCta_clabe,cTelCelular,cStatus_cta,cNum_cte_ret,cNumcte_tf,cProducto,cNombre,cFecha_nac,cRfc,cCorreo,cCurp,cMet_notificacion,cEjecutivo,cFec_alta,cFec_cancelac,cFec_modific,cCod_ent_nac;
						ELSE
							let pTelefono = TRIM(pTelefono);
							
							SELECT {+INDEX( "informix".tf_maecte  "informix".idx_tf_maecte_tel)} 
							cuenta_tf,cta_clabe,telefono,status_cta,numcte,numcte_tf,producto,nombre1,nombre2,apell_paterno,apell_materno,
							fecha_nac,rfc,correo,curp,met_notificacion,ejecutivo,fec_alta,fec_cancelac,fec_modific,cod_ent_nac
							INTO cCuenta_tf,cCta_clabe,cTelCelular,cStatus_cta,cNum_cte_ret,cNumcte_tf,cProducto,cNombre1,
							cNombre2,cApellpaterno,cApellmaterno,cFecha_nac,cRfc,cCorreo,cCurp,cMet_notificacion,cEjecutivo,
							cFec_alta,cFec_cancelac,cFec_modific,cCod_ent_nac
							FROM "informix".tf_maecte 
							WHERE telefono = pTelefono
								AND empresa = '001'
								AND status_cta = '1';

							IF NVL(cNumcte_tf,'') <> '' THEN
								LET cNombre = TRIM(cNombre1)||" "||TRIM(cNombre2)||" "||TRIM(cApellpaterno)||" "||TRIM(cApellmaterno);
							ELSE
								--EL CLIENTE TRANSFER NO EXISTE
								LET cCodRet = '00833';
							END IF							
						END IF
					END IF;					
				-- SI EL PARAMETRO DE LA TARJETA ESTA CONTENIDO
				ELIF (NVL(pTarjeta,'') <> '') THEN
					-- LA TARJETA TIENE QUE SER DE 16 POSICIONES.
					IF LENGTH(TRIM(pTarjeta)) <> 16 THEN
						LET cCodRet = '00831';
						RETURN cCodinfx,cCodRet,cCuenta_tf,cCta_clabe,cTelCelular,cStatus_cta,cNum_cte_ret,cNumcte_tf,cProducto,cNombre,cFecha_nac,cRfc,cCorreo,cCurp,cMet_notificacion,cEjecutivo,cFec_alta,cFec_cancelac,cFec_modific,cCod_ent_nac;
					ELSE
					
						SELECT NVL(cuenta,'') INTO cCuenta FROM bdicheq:"informix".sc_tarjeta WHERE empresa = "001" AND num_tarjeta = pTarjeta;
						
						IF NVL(cCuenta,'') <> '' THEN
						
							SELECT cuenta_tf,cta_clabe,telefono,status_cta,numcte,numcte_tf,producto,nombre1,nombre2,apell_paterno,apell_materno,
							fecha_nac,rfc,correo,curp,met_notificacion,ejecutivo,fec_alta,fec_cancelac,fec_modific,cod_ent_nac
							INTO cCuenta_tf,cCta_clabe,cTelCelular,cStatus_cta,cNum_cte_ret,cNumcte_tf,cProducto,cNombre1,
							cNombre2,cApellpaterno,cApellmaterno,cFecha_nac,cRfc,cCorreo,cCurp,cMet_notificacion,cEjecutivo,
							cFec_alta,cFec_cancelac,cFec_modific,cCod_ent_nac
							FROM "informix".tf_maecte 
							WHERE cuenta_tf = cCuenta
							AND empresa = '001'
							AND status_cta = '1';

							IF NVL(cNumcte_tf,'') <> '' THEN
								LET cNombre = TRIM(cNombre1)||" "||TRIM(cNombre2)||" "||TRIM(cApellpaterno)||" "||TRIM(cApellmaterno);
							ELSE
								--EL CLIENTE TRANSFER NO EXISTE
								LET cCodRet = '00833';
							END IF
						ELSE
							--EL CLIENTE TRANSFER NO EXISTE
							LET cCodRet = '00838';
						END IF
					END IF
				END IF;
			-- PARA LA TRANSACCION POR RETIRO
			ELIF NVL(pTpoTrans,'') = 2 THEN
				--EN CASO QUE CLIENTE HAYA PROPORCIONADO EL DATO DE LA CUENTA O DEL CELULAR
				IF (NVL(pCuenta,'') <> '') OR (NVL(pTelefono,'') <> '') THEN
					IF NVL(pCuenta,'') <> '' THEN					
						-- LA CUENTA TIENE QUE SER DE 11 POSICIONES.
						IF LENGTH(TRIM(pCuenta)) <> 11 THEN
							--LA LONGITUD DE LA CUENTA NO ES DE 11 POSICIONES
							LET cCodRet = '00831';
							RETURN cCodinfx,cCodRet,cCuenta_tf,cCta_clabe,cTelCelular,cStatus_cta,cNum_cte_ret,cNumcte_tf,cProducto,cNombre,cFecha_nac,cRfc,cCorreo,cCurp,cMet_notificacion,cEjecutivo,cFec_alta,cFec_cancelac,cFec_modific,cCod_ent_nac;
						ELSE
							-- OBTENER EL NUMERO DEL CLIENTE
							LET pCuenta = TRIM(pCuenta);
							
							SELECT NVL(numcte,'') INTO cNum_cte	FROM "informix".tf_maecte WHERE cuenta_tf = pCuenta AND status_cta = "1";
						END IF					
					ELIF NVL(pTelefono,'') <> '' THEN						
						-- EL TELEFONO TIENE QUE SER DE 10 POSICIONES.
						IF LENGTH(TRIM(pTelefono)) <> 10 THEN
							LET cCodRet = '00831';
							RETURN cCodinfx,cCodRet,cCuenta_tf,cCta_clabe,cTelCelular,cStatus_cta,cNum_cte_ret,cNumcte_tf,cProducto,cNombre,cFecha_nac,cRfc,cCorreo,cCurp,cMet_notificacion,cEjecutivo,cFec_alta,cFec_cancelac,cFec_modific,cCod_ent_nac;
						ELSE
							LET pTelefono = TRIM(pTelefono);
							-- OBTENER EL NUMERO DEL CLIENTE
							SELECT NVL(numcte,'') INTO cNum_cte	FROM "informix".tf_maecte WHERE telefono = pTelefono AND status_cta = "1";
						END IF
					END IF;
					
					-- VALIDAR EL DATO DEL NUMERO DEL CLIENTE
					IF NVL(cNum_cte,'') = '' THEN
						-- CLIENTE INCORRECTO
						LET cCodRet = '00845';
					ELSE
						LET cNum_cte = TRIM(cNum_cte);
					
						SELECT numcte 
						INTO cNum_cte_1  
						FROM bdinteg:si_cliente 
						WHERE numcte=cNum_cte
						AND  tipo_cliente=1;
												 
							IF NVL(cNum_cte_1,'') = '' THEN
								LET cCodRet = '00838';  --CLIENTE NO SE ENCUENTRA REGISTRADO
							END IF;
									
						IF (NVL(cNum_cte_1,'') <> '') THEN
							-- SI SE TIENE LA CUENTA SE CONSULTARA POR CUENTA
							IF NVL(pCuenta,'') <> '' THEN						
								SELECT cuenta_tf,cta_clabe,telefono,status_cta,numcte,numcte_tf,producto,nombre1,nombre2,apell_paterno,apell_materno,
								fecha_nac,rfc,correo,curp,met_notificacion,ejecutivo,fec_alta,fec_cancelac,fec_modific,cod_ent_nac
								INTO cCuenta_tf,cCta_clabe,cTelCelular,cStatus_cta,cNum_cte_ret,cNumcte_tf,cProducto,cNombre1,
								cNombre2,cApellpaterno,cApellmaterno,cFecha_nac,cRfc,cCorreo,cCurp,cMet_notificacion,cEjecutivo,
								cFec_alta,cFec_cancelac, cFec_modific,cCod_ent_nac
								FROM "informix".tf_maecte
								WHERE cuenta_tf = pCuenta
									AND numcte = cNum_cte
									AND status_cta = "1";
									
							-- SI SE TIENE EL TELEFO CELULAR SE CONSULTARA POR EL TELEFO CELULAR
							ELIF NVL(pTelefono,'') <> '' THEN
								SELECT cuenta_tf,cta_clabe,telefono,status_cta,numcte,numcte_tf,producto,nombre1,nombre2,apell_paterno,apell_materno,
								fecha_nac,rfc,correo,curp,met_notificacion,ejecutivo,fec_alta,fec_cancelac,fec_modific,cod_ent_nac
								INTO cCuenta_tf,cCta_clabe,cTelCelular,cStatus_cta,cNum_cte_ret,cNumcte_tf,cProducto,cNombre1,
								cNombre2,cApellpaterno,cApellmaterno,cFecha_nac,cRfc,cCorreo,cCurp,cMet_notificacion,cEjecutivo,
								cFec_alta,cFec_cancelac, cFec_modific,cCod_ent_nac
								FROM "informix".tf_maecte
								WHERE telefono = pTelefono
									AND numcte = cNum_cte
									AND status_cta = "1";

							END IF;
							-- ARMAR EL NOMBRE COMPLETO DEL CLIENTE
							LET cNombre = TRIM(cNombre1)||" "||TRIM(cNombre2)||" "||TRIM(cApellpaterno)||" "||TRIM(cApellmaterno);							
						END IF;
					END IF;
				END IF;
				-- SI EL PARAMETRO DE LA TARJETA ESTA CONTENIDO
				IF (NVL(pTarjeta,'') <> '') THEN
					
					-- LA TARJETA TIENE QUE SER DE 16 POSICIONES.
					IF LENGTH(TRIM(pTarjeta)) <> 16 THEN
						LET cCodRet = '00831';
						RETURN cCodinfx,cCodRet,cCuenta_tf,cCta_clabe,cTelCelular,cStatus_cta,cNum_cte_ret,cNumcte_tf,cProducto,cNombre,cFecha_nac,cRfc,cCorreo,cCurp,cMet_notificacion,cEjecutivo,cFec_alta,cFec_cancelac,cFec_modific,cCod_ent_nac;
					END IF
					
					SELECT NVL(cuenta,'') INTO cCuenta FROM bdicheq:"informix".sc_tarjeta WHERE empresa = "001" AND num_tarjeta = pTarjeta AND prodtarjeta = "8000";
					-- SI SE TIENE EL DATO DE LA CUENTA
					IF NVL(cCuenta,'') <> '' THEN
						
						LET cCuenta = TRIM(cCuenta);
						SELECT cuenta_tf,cta_clabe,telefono,status_cta,numcte,numcte_tf,producto,nombre1,nombre2,apell_paterno,apell_materno,fecha_nac,rfc,correo,curp,met_notificacion,ejecutivo,fec_alta,fec_cancelac,fec_modific,cod_ent_nac
						INTO cCuenta_tf,cCta_clabe,cTelCelular,cStatus_cta,cNum_cte_ret,cNumcte_tf,cProducto,cNombre1,cNombre2,cApellpaterno,cApellmaterno,cFecha_nac,cRfc,cCorreo,cCurp,cMet_notificacion,cEjecutivo,cFec_alta,cFec_cancelac,cFec_modific,cCod_ent_nac
						FROM "informix".tf_maecte 
						WHERE cuenta_tf = cCuenta
						AND status_cta = '1';
						
						IF NVL(cNumcte_tf,'') = '' THEN
							--EL CLIENTE TRANSFER NO EXISTE
							LET cCodRet = '00835';
						ELSE
							LET cNombre = TRIM(cNombre1)||" "||TRIM(cNombre2)||" "||TRIM(cApellpaterno)||" "||TRIM(cApellmaterno);
						END IF;
					ELSE
						--EL CLIENTE TRANSFER NO EXISTE
						LET cCodRet = '00838';
					END IF;
				END IF;
			ELSE
				-- LA TRANSACCION NO ES DEPOSITO NI ES RETIRO
				LET cCodRet = '00832';
				RETURN cCodinfx,cCodRet,cCuenta_tf,cCta_clabe,cTelCelular,cStatus_cta,cNum_cte_ret,cNumcte_tf,cProducto,cNombre,cFecha_nac,cRfc,cCorreo,cCurp,cMet_notificacion,cEjecutivo,cFec_alta,cFec_cancelac,cFec_modific,cCod_ent_nac;

			END IF;
		END IF;		
		-- SE RETORNA LA INFORMACIÃN OBTENIDA
		RETURN cCodinfx,cCodRet,cCuenta_tf,cCta_clabe,cTelCelular,cStatus_cta,cNum_cte_ret,cNumcte_tf,cProducto,cNombre,
		cFecha_nac,cRfc,cCorreo,cCurp,cMet_notificacion,cEjecutivo,cFec_alta,cFec_cancelac,cFec_modific,cCod_ent_nac;
			
	END;

	END PROCEDURE
	DOCUMENT
	'Folio: 1433',
	'Autor: 93893061 ',
	'Fecha: 08/07/2014',
	'DescripciÃ³n: Consulta el nombre del cliente dependiendo del criterio de consulta que el cliente proporcione ya sea "Tarjeta", "Cuenta" o "Num. TelÃ©fono". ',
	'Sustento: Retiro_efectivo.pdf y Deposito_ Efectivo.pdf',
	'Solicita: Berenice MÃ©ndez Rivera',
	'BD: bditransfer';
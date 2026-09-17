CREATE PROCEDURE "informix".sp_validacion_msj(
	pTexto_msj              	CHAR(160),
	pUsuario               		CHAR(10),
	pPass             		 	CHAR(10),
	pCel              			CHAR(10),  
	pCompania                   CHAR(10))
	
	RETURNING
		CHAR (5) AS cReturnCode,
		CHAR (900) AS cErrorDescription;

	-- DECLARACION DE VARIABLES
	DEFINE iSqlErr  			INTEGER;
	DEFINE cPCodRet,cPCodRet1, cPCodRet2, cPCodRet3, cPCodRet4 CHAR(5);
	DEFINE cPCodRet5 CHAR(6); ------INICIATIVA DE INCREMENTO DE CREDITO PARA PRESTAMO DIGITAL
	DEFINE cReturnCode	 		CHAR (5);
	DEFINE cErrorDescription 	CHAR (256);
	DEFINE vRetornoDescription 	VARCHAR (100);
    DEFINE vcodret        		CHAR(50);
	DEFINE cFechaSolitud  		DATETIME YEAR TO SECOND;
    DEFINE cFecha  				CHAR(10);
    DEFINE cHora  				CHAR(10);
	DEFINE iParam 				INTEGER;
	DEFINE iNParam 				INTEGER;
	DEFINE sMsgError 			VARCHAR(100);
	DEFINE vImporte    			VARCHAR(160);
	DEFINE vImporte2        	CHAR(160);
	DEFINE PARAM1 				VARCHAR(40);
	DEFINE PARAM2 				VARCHAR(40);
	DEFINE PARAM3 				VARCHAR(40);
	DEFINE PARAM4 				VARCHAR(40);
	DEFINE PARAM5 				VARCHAR(40);
	DEFINE PARAM6 				VARCHAR(40);
	DEFINE PARAM7 				VARCHAR(40);
	DEFINE PARAM8 				VARCHAR(40);
	DEFINE PARAM9 				VARCHAR(40);
	DEFINE PARAM10 				VARCHAR(40);
	DEFINE texto_msj_par		VARCHAR(30);
	DEFINE iCont				INTEGER;
	DEFINE vsql					CHAR(900);
	DEFINE vsql2				CHAR(900);
	DEFINE vproceso				CHAR(30);
	DEFINE vpclave		   		CHAR(30);
	DEFINE vpaso				INTEGER;
	DEFINE vsql_aux				CHAR(900);
    DEFINE ejec					CHAR(250);
    DEFINE ejec2				CHAR(250);
	DEFINE claveSinonimo 			CHAR(10);
	DEFINE cNumCte					VARCHAR(20);
	DEFINE cNumCte2					VARCHAR(20);	
	DEFINE cSucursal				VARCHAR(4);
	DEFINE cTarjeta				VARCHAR(20);
	DEFINE cTarjeta4				VARCHAR(4);	
	DEFINE cFolio				VARCHAR(16);
	DEFINE pCanal			CHAR(1); --Actualizacion para sp_validaradn_multicanal
	DEFINE cMnsjRet			CHAR(5); --Actualizacion para sp_validaradn_multicanal
	DEFINE c_term_tarjeta   CHAR(4);
	define c_nombre_prod    char(50);
	
	
	-- INICIALIZACION DE VARIABLES
	LET iSqlErr = 0;
	LET cReturnCode = '00000';
	LET cErrorDescription = 'Consulta exitosa';
	LET vRetornoDescription = '';
	LET cPCodRet = '00000';
	LET cPCodRet1 = '00000';
	LET cPCodRet3 = '00000';
	LET cPCodRet4 = '00000';
	LET cPCodRet2 = '00000';
	LET cPCodRet5 = '000000'; ------INICIATIVA DE INCREMENTO DE CREDITO PARA PRESTAMO DIGITAL
	LET cFechaSolitud = CURRENT::DATE;
	LET iCont = 0;
    LET ejec = '';
    LET ejec2 = '';
    LET cFecha = '';
    LET cHora = '';
    let vsql2 = '';
	LET sMsgError = '';
	LET PARAM1 = '';
	LET PARAM2 = '';
	LET PARAM3 = '';
	LET PARAM4 = '';
	LET PARAM5 = '';
	LET PARAM6 = '';
	LET PARAM7 = '';
	LET PARAM8 = '';
	LET PARAM9 = '';
	LET PARAM10 = '';
	LET iParam = 0;
	LET iNParam = 0;
	LET claveSinonimo = '';
	LET cNumCte = '';
    LET cNumCte2 = '';	
	LET cSucursal = '';
	LET cTarjeta = '';
	LET pCanal = '1'; --Actualizacion para sp_validaradn_multicanal
	LET cMnsjRet = '';
	LET c_term_tarjeta = '';
	LET c_nombre_prod ='';
	
		
	--SET DEBUG FILE TO '/informix/ragomez/ANTICIPO/sp_validacion_msj2.out';
	--TRACE ON;

    BEGIN
	
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN -- MANEJADOR DE ERRORES
				LET cReturnCode = iSqlErr;
				LET cPCodRet = TRIM(iSqlErr);

				LET cErrorDescription='Error en paso' || vpaso ;
				--REGISTRO DE PARAMETROS DE EJECUCION DE SP A GUARDAR EN BITACORA
				LET ejec = TRIM(pTexto_msj)||''','''||TRIM(pUsuario)||''','''||TRIM(pPass)||''','''||TRIM(pCel)||''','''||TRIM(pCompania);
				LET ejec2 = 'Respuesta('''||cPCodRet||''','''||(vpaso)||''')';
	
				INSERT INTO bdimnsj:"informix".mnsjr_bitacora_sms(fechasolicitud,proceso,texto_msj,usuario,pass,cel,compania,respuestasolicitud,numcte,sucursal,param1,param2,param3)
				VALUES(current, 'sp_validaradn', pTexto_msj,pUsuario,pPass,pCel,pCompania,ejec2,cNumCte,cSucursal,PARAM1,PARAM2,PARAM3);

				RETURN cPCodRet, cErrorDescription;
			END IF;
		END EXCEPTION;
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		--REGISTRO DE PARAMETROS DE EJECUCION DE SP A GUARDAR EN BITACORA
		LET ejec = TRIM(pTexto_msj)||''','''||TRIM(pUsuario)||''','''||TRIM(pPass)||''','''||TRIM(pCel)||''','''||TRIM(pCompania);

		FOREACH
			EXECUTE PROCEDURE bdimnsj:"informix".sp_espacios_blancos2(pTexto_msj)
			INTO texto_msj_par
			
			LET iCont = iCont + 1;
			
			IF iCont = 2 AND PARAM1 = 'PAGOSFIJOS' THEN
				LET texto_msj_par = TRIM(texto_msj_par);
			ELSE
				LET texto_msj_par = UPPER(TRIM(texto_msj_par));
			END IF;
			
		
			-- ASIGNACION DE PARAMETROS
			IF iCont = 1 THEN 
				LET PARAM1 = texto_msj_par;
				-- VALIDACION DE SINONIMOS
				SELECT clave INTO claveSinonimo FROM mnsj_cat_sinonimos WHERE palabra = PARAM1;
				IF claveSinonimo <> '' AND claveSinonimo IS NOT NULL THEN
					LET PARAM1 = UPPER(TRIM(claveSinonimo));
				END IF;
			ELIF iCont = 2  THEN 
				LET PARAM2 = texto_msj_par;
				IF PARAM2 = 'PLAN' AND PARAM1 = 'BAJA' THEN
					LET PARAM1 = 'BAJAPLAN';
				ELIF PARAM2 = 'SIMULADOR' AND PARAM1 = 'PRESTAMO' THEN
					LET PARAM1 = 'SIMULADOR';
				ELIF PARAM2 = 'SALDO' AND PARAM1 = 'CANCELAR' THEN
					LET PARAM1 = 'CANSALDO';
				END IF;
			ELIF iCont = 3  THEN LET PARAM3 = texto_msj_par;
			ELIF iCont = 4  THEN LET PARAM4 = texto_msj_par;
			ELIF iCont = 5  THEN LET PARAM5 = texto_msj_par;
			ELIF iCont = 6  THEN LET PARAM6 = texto_msj_par;
			ELIF iCont = 7  THEN LET PARAM7 = texto_msj_par;
			ELIF iCont = 8  THEN LET PARAM8 = texto_msj_par;
			ELIF iCont = 9  THEN LET PARAM9 = texto_msj_par;
			ELIF iCont = 10 THEN LET PARAM10 = texto_msj_par;
			END IF;
		END FOREACH

		--VALIDA PALABRA CLAVE
		SELECT proceso,numeroparametros::int, msjerror
		INTO vproceso,iParam, sMsgError
		FROM bdimnsj:"informix".mnsjr_cat_smsin
		WHERE clave = PARAM1;

		IF (dbinfo('sqlca.sqlerrd2')=0)  THEN
			LET ejec2 = '00003, NO EXISTE PALABRA CLAVE';
			
			INSERT INTO bdimnsj:"informix".mnsjr_bitacora_sms(fechasolicitud,proceso,texto_msj,usuario,pass,cel,compania,respuestasolicitud,numcte,sucursal,param1,param2,param3)
			VALUES(current, vproceso,pTexto_msj,pUsuario,pPass,pCel,pCompania,ejec2,cNumCte,cSucursal,PARAM1,PARAM2,PARAM3);
			
			RETURN '00003', 'NO EXISTE PALABRA CLAVE';
		END IF;
		
		--VALIDA ESTRUCTURA DEL MENSAJE
		IF iCont <> iParam AND PARAM1 <> 'BAJAPLAN' THEN 
			
			LET ejec2 = '00004,'||sMsgError;
			
			INSERT INTO bdimnsj:"informix".mnsjr_bitacora_sms(fechasolicitud,proceso,texto_msj,usuario,pass,cel,compania,respuestasolicitud,numcte,sucursal,param1,param2,param3)
			VALUES(current, vproceso,pTexto_msj,pUsuario,pPass,pCel,pCompania,ejec2,cNumCte,cSucursal,PARAM1,PARAM2,PARAM3);
			
			RETURN '00004', sMsgError;
		END IF;
		
		SELECT FIRST 1 numcte INTO cNumCte 
		FROM TABLE(MULTISET(
							SELECT numcte
							FROM bdinteg:"informix".si_telefonos_actual 
							WHERE telefono = pCel AND tipo_tel = '2' AND status_tel = 'A'
							ORDER BY fecha_hora DESC
		));

		SELECT sucursal INTO cSucursal FROM bdinteg:si_cliente WHERE numcte = cNumCte and empresa='001';
		
		-- INICIA PALABRA CLAVE SALDO
		IF PARAM1 = 'SALDO' THEN
			EXECUTE PROCEDURE bdimnsj:"informix".sp_recupera_saldo(pCel)
			INTO cPCodRet2, vImporte;

			LET cReturnCode = cPCodRet2;
			LET ejec2 = 'Respuesta('''||TRIM(cPCodRet2)||''','''||(vImporte)||''')';
			SELECT DBINFO('utc_to_datetime', sh_curtime) INTO cFechaSolitud FROM sysmaster:"informix".sysshmvals;

			INSERT INTO bdimnsj:"informix".mnsjr_bitacora_sms(fechasolicitud,proceso,texto_msj,usuario,pass,cel,compania,respuestasolicitud,numcte,sucursal,param1,param2,param3)
			VALUES(current, vproceso, pTexto_msj,pUsuario,pPass,pCel,pCompania,ejec2,cNumCte,cSucursal,PARAM1,PARAM2,PARAM3);

			IF cPCodRet2 = '00000' THEN
				LET vImporte2 = vImporte;
				-- SE AGREGA PARAMETRO CON EL SALDO OBTENIDO, ADEMAS DE MODIFICAR LA PLANTILLA CON EL CAMPO OBTENIDO.
				EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','SMS_RECI','RECI_SALD','000000000','','','1','','','','',vImporte,'','','','','','',pCel,1,0,0,0,0,'','') -- PARA CONSULTA DE SALDO
				INTO cPCodRet;
			ELSE
				-- GENERAR PLANTILLA CON MENSAJE DE ERROR. "SU PETICION NO PUDO SER PROCESADA. GRACIAS."
				EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','SMS_RECI','ERR_SALD','000000000','','','1','','','','','','','','','','','',pCel,1,0,0,0,0,'','') -- PARA CONSULTA DE SALDO
				INTO cPCodRet;
			END IF;
		-- INICIA PALABRA CLAVE ANTICIPO
		ELIF PARAM1 = 'ANTICIPO' THEN
			EXECUTE PROCEDURE bdimnsj:"informix".sp_valida_esnumerico(PARAM2) INTO cPCodRet4;
			IF cPCodRet4 = 'V' THEN
				EXECUTE PROCEDURE bdisolic:"informix".sp_validaradn_multicanal(pCel, PARAM2, pcanal)
				INTO cPCodRet2, cMnsjRet;
				LET cReturnCode = cPCodRet2;
				--LET ejec2 = 'Respuesta('''||TRIM(cPCodRet2)||')';
				LET ejec2 = 'Respuesta('||TRIM(cPCodRet2)||','||trim(cMnsjRet)||')';
				
				INSERT INTO bdimnsj:"informix".mnsjr_bitacora_sms(fechasolicitud,proceso,texto_msj,usuario,pass,cel,compania,respuestasolicitud,numcte,sucursal,param1,param2,param3)
				VALUES(current, vproceso, pTexto_msj,pUsuario,pPass,pCel,pCompania,ejec2,cNumCte,cSucursal,PARAM1,PARAM2,PARAM3);

			ELSE
				LET ejec2 = '00005, La cantidad no es un valor numerico';
				
				INSERT INTO bdimnsj:"informix".mnsjr_bitacora_sms(fechasolicitud,proceso,texto_msj,usuario,pass,cel,compania,respuestasolicitud,numcte,sucursal,param1,param2,param3)
				VALUES(current, vproceso, pTexto_msj,pUsuario,pPass,pCel,pCompania,ejec2,cNumCte,cSucursal,PARAM1,PARAM2,PARAM3);
				
				RETURN '00005','La cantidad no es un valor numerico';

			END IF
		-- INICIA PALABRA CLAVE PAGO
		ELIF PARAM1 = 'PAGO' THEN 

			EXECUTE PROCEDURE bdimnsj:"informix".sp_recupera_pago(pCel)
			INTO cPCodRet2, vImporte;
			LET cReturnCode = cPCodRet2;
			LET ejec2 = 'Respuesta('''||TRIM(cPCodRet2)||''','''||(vImporte)||''')';

			INSERT INTO bdimnsj:"informix".mnsjr_bitacora_sms(fechasolicitud,proceso,texto_msj,usuario,pass,cel,compania,respuestasolicitud,numcte,sucursal,param1,param2,param3)
			VALUES(current, vproceso, pTexto_msj,pUsuario,pPass,pCel,pCompania,ejec2,cNumCte,cSucursal,PARAM1,PARAM2,PARAM3);

			IF cPCodRet2 = '00000' THEN
				EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','SMS_RECI','RECI_SALD','000000000','','','1','','','','',vImporte,'','','','','','',pCel,1,0,0,0,0,'','')
				INTO cPCodRet;

			ELSE
				-- GENERAR PLANTILLA CON MENSAJE DE ERROR. "SU PETICION NO PUDO SER PROCESADA. GRACIAS."
				EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','SMS_RECI','ERR_SALD','000000000','','','1','','','','','','','','','','','',pCel,1,0,0,0,0,'','') -- PARA CONSULTA DE PAGO
				INTO cPCodRet;
			END IF;
		-- INICIA CAMBIO INVERSIONES
		ELIF PARAM1 = 'INVERSION' THEN
			EXECUTE PROCEDURE bdimnsj:"informix".sp_recupera_saldo_inv(pCel)
			INTO cPCodRet2, vImporte;
			LET cReturnCode = cPCodRet2;
			LET ejec2 = 'Respuesta('''||TRIM(cPCodRet2)||''','''||(vImporte)||''')';
			
			INSERT INTO bdimnsj:"informix".mnsjr_bitacora_sms(fechasolicitud,proceso,texto_msj,usuario,pass,cel,compania,respuestasolicitud,numcte,sucursal,param1,param2,param3)
			VALUES(current, vproceso, pTexto_msj,pUsuario,pPass,pCel,pCompania,ejec2,cNumCte,cSucursal,PARAM1,PARAM2,PARAM3);

			IF cPCodRet2 = '00000' THEN
				EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','SMS_RECI','RECI_SALD','000000000','','','1','','','','',vImporte,'','','','','','',pCel,1,0,0,0,0,'','')
				INTO cPCodRet;
			ELSE
				-- GENERAR PLANTILLA CON MENSAJE DE ERROR. "SU PETICION NO PUDO SER PROCESADA. GRACIAS."
				EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','SMS_RECI','ERR_SALD','000000000','','','1','','','','','','','','','','','',pCel,1,0,0,0,0,'','') -- PARA CONSULTA DE PAGO
				INTO cPCodRet;
			END IF;
		-- INICIA CAMBIO SOLICITUD
		ELIF PARAM1 = 'SOLICITUD' THEN
			EXECUTE PROCEDURE bdimnsj:"informix".sp_recupera_estatussolic(pCel)
			INTO cPCodRet2, vImporte;
			LET cReturnCode = cPCodRet2;
			LET ejec2 = 'Respuesta('''||TRIM(cPCodRet2)||''','''||(vImporte)||''')';
			
			INSERT INTO bdimnsj:"informix".mnsjr_bitacora_sms(fechasolicitud,proceso,texto_msj,usuario,pass,cel,compania,respuestasolicitud,numcte,sucursal,param1,param2,param3)
			VALUES(current, vproceso, pTexto_msj,pUsuario,pPass,pCel,pCompania,ejec2,cNumCte,cSucursal,PARAM1,PARAM2,PARAM3);
			
			IF cPCodRet2 = '00000' THEN
				EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','SMS_RECI','RECI_SALD','000000000','','','1','','','','',vImporte,'','','','','','',pCel,1,0,0,0,0,'','')
				INTO cPCodRet;

			ELSE
				-- GENERAR PLANTILLA CON MENSAJE DE ERROR. "SU PETICION NO PUDO SER PROCESADA. GRACIAS."
				EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','SMS_RECI','ERR_SALD','000000000','','','1','','','','','','','','','','','',pCel,1,0,0,0,0,'','') -- PARA CONSULTA DE PAGO
				INTO cPCodRet;
			END IF;
		
		ELIF PARAM1 = 'CELULAR' THEN -- INICIA PALABRA CLAVE CELULAR
			EXECUTE PROCEDURE bdimnsj:"informix".sp_recupera_cuentatelefono(pCel)
			INTO cPCodRet2, vImporte;
			LET cReturnCode = cPCodRet2;
			LET ejec2 = 'Respuesta('''||TRIM(cPCodRet2)||''','''||(vImporte)||''')';
			
			INSERT INTO bdimnsj:"informix".mnsjr_bitacora_sms(fechasolicitud,proceso,texto_msj,usuario,pass,cel,compania,respuestasolicitud,numcte,sucursal,param1,param2,param3)
			VALUES(current, vproceso, pTexto_msj,pUsuario,pPass,pCel,pCompania,ejec2,cNumCte,cSucursal,PARAM1,PARAM2,PARAM3);

			IF cPCodRet2 = '00000' THEN
				EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','SMS_RECI','RECI_SALD','000000000','','','1','','','','',vImporte,'','','','','','',pCel,1,0,0,0,0,'','')
				INTO cPCodRet;

			ELSE
				-- GENERAR PLANTILLA CON MENSAJE DE ERROR. "SU PETICION NO PUDO SER PROCESADA. GRACIAS."
				EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','SMS_RECI','ERR_SALD','000000000','','','1','','','','','','','','','','','',pCel,1,0,0,0,0,'','') ----PARA CONSULTA DE pago
				INTO cPCodRet;
			END IF;

		-- INICIA PALABRA CLAVE DIFERIR
		/*ELIF PARAM1 = 'DIFERIR' THEN 
			
			EXECUTE PROCEDURE bdicred:"informix".sp_diferir(cNumCte,pCel,cTarjeta,9)
			INTO cPCodRet2, vImporte;
			LET cReturnCode = cPCodRet2;
			LET ejec2 = 'Respuesta('''||TRIM(cPCodRet2)||''','''||(vImporte)||''')';
				
			INSERT INTO bdimnsj:"informix".mnsjr_bitacora_sms(fechasolicitud,proceso,texto_msj,usuario,pass,cel,compania,respuestasolicitud,numcte,sucursal,param1,param2,param3)
			VALUES(current, vproceso, pTexto_msj,pUsuario,pPass,pCel,pCompania,ejec2,cNumCte,cSucursal,PARAM1,PARAM2,PARAM3);

			IF cPCodRet2 = '00009' THEN
				LET vImporte = 'Lo sentimos, no cumples con los requisitos para participar en el Plan de Apoyo. Consulta terminos y condiciones en www.bancoppel.com';
			END IF;
			
			EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','SMS_RECI','RECI_SALD','000000000','','','1','','','','',vImporte,'','','','','','',pCel,1,0,0,0,0,'','')
				INTO cPCodRet;*/

		-- INICIA PALABRA CLAVE ROBO / EXTRAVIO
		ELIF PARAM1 IN ('ROBO','EXTRAVIO') THEN 

			EXECUTE PROCEDURE bdimnsj:"informix".sp_valida_esnumerico(PARAM2) INTO cPCodRet4;
			IF cPCodRet4 = 'V' THEN		
				LET cHora = replace (substring (current FROM 12  FOR 8 ), ':', '');
				LET cFolio = TRIM(cNumCte)||'9'||cHora ;
				LET cTarjeta4 = TRIM(PARAM2);
				EXECUTE PROCEDURE intercard:"informix".sp_cancelatarjeta_canales(cNumCte,cTarjeta4,'09',cFolio,'0')
					INTO cPCodRet2, vImporte;
			
				LET cReturnCode = cPCodRet2;
				LET ejec2 = 'Respuesta('''|| cPCodRet2 ||''','''|| vImporte ||''')';

				IF cPCodRet2 = '00000' THEN
				   LET vImporte = 'Tu tarjeta con terminacion ' || cTarjeta4 || ' ha sido cancelada. Folio:' || cFolio ;
				ELSE
					LET vImporte = 'Operacion no exitosa. ' || vImporte;
				END IF;
				
				INSERT INTO bdimnsj:"informix".mnsjr_bitacora_sms(fechasolicitud,proceso,texto_msj,usuario,pass,cel,compania,respuestasolicitud,numcte,sucursal,param1,param2,param3)
				VALUES(current, vproceso, pTexto_msj,pUsuario,pPass,pCel,pCompania,ejec2,cNumCte,cSucursal,PARAM1,PARAM2,PARAM3);

				EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','SMS_RECI','RECI_SALD','000000000','','','1','','','','',vImporte,'','','','','','',pCel,1,0,0,0,0,'','')
					INTO cPCodRet;
					
			ELSE
				LET ejec2 = '00005, Los digitos de la tarjeta deben ser numericos.';
				
				INSERT INTO bdimnsj:"informix".mnsjr_bitacora_sms(fechasolicitud,proceso,texto_msj,usuario,pass,cel,compania,respuestasolicitud,numcte,sucursal,param1,param2,param3)
				VALUES(current, vproceso, pTexto_msj,pUsuario,pPass,pCel,pCompania,ejec2,cNumCte,cSucursal,PARAM1,PARAM2,PARAM3);

				EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','SMS_RECI','RECI_SALD','000000000','','','1','','','','',sMsgError,'','','','','','',pCel,1,0,0,0,0,'','')
					INTO cPCodRet;				
				--RETURN '00005','La cantidad no es un valor numerico';

			END IF;
				
		ELIF PARAM1 IN('FLEXIBLE','PRESTAMO') THEN -- INICIA PALABRA CLAVE FLEXIBLE	
			IF PARAM2 = 'DISPONIBLE' THEN
				--EXECUTE PROCEDURE bdisolic:"informix".sp_prestamoflex_sms(1, pCel, 0)
				EXECUTE PROCEDURE bdisolic:"informix".sp_prestamoflex_sms(1, pCel, 0, 9, '', '', '')
				INTO cPCodRet2,vRetornoDescription;
				
				LET cReturnCode = cPCodRet2;
				--LET cErrorDescription = vRetornoDescription;
				LET ejec2 = 'Respuesta('''||TRIM(cPCodRet2)||')';
				
				INSERT INTO bdimnsj:"informix".mnsjr_bitacora_sms(fechasolicitud,proceso,texto_msj,usuario,pass,cel,compania,respuestasolicitud,numcte,sucursal,param1,param2,param3)
				VALUES(current, vproceso, pTexto_msj,pUsuario,pPass,pCel,pCompania,ejec2,cNumCte,cSucursal,PARAM1,PARAM2,PARAM3);
				
			ELIF PARAM2 = 'CONSULTA' THEN
				--EXECUTE PROCEDURE bdisolic:"informix".sp_prestamoflex_sms(3, pCel, 0)
				EXECUTE PROCEDURE bdisolic:"informix".sp_prestamoflex_sms(3, pCel, 0, 9, '', '', '') 
				INTO cPCodRet2,vRetornoDescription;
				
				LET cReturnCode = cPCodRet2;
				--LET cErrorDescription = vRetornoDescription;
				LET ejec2 = 'Respuesta('''||TRIM(cPCodRet2)||')';
				
				INSERT INTO bdimnsj:"informix".mnsjr_bitacora_sms(fechasolicitud,proceso,texto_msj,usuario,pass,cel,compania,respuestasolicitud,numcte,sucursal,param1,param2,param3)
				VALUES(current, vproceso, pTexto_msj,pUsuario,pPass,pCel,pCompania,ejec2,cNumCte,cSucursal,PARAM1,PARAM2,PARAM3);

			ELSE
				EXECUTE PROCEDURE bdimnsj:"informix".sp_valida_esnumerico(PARAM2)
				INTO cPCodRet4;
				IF cPCodRet4 = 'V' THEN
					IF PARAM2 = PARAM2::INT THEN
						--EXECUTE PROCEDURE bdisolic:"informix".sp_prestamoflex_sms(2, pCel, PARAM2)
						EXECUTE PROCEDURE bdisolic:"informix".sp_prestamoflex_sms(2, pCel, PARAM2, 9, '', '', '')
						INTO cPCodRet2,vRetornoDescription;
				
						LET cReturnCode = cPCodRet2;
						--LET cErrorDescription = vRetornoDescription;
						LET ejec2 = 'Respuesta('''||TRIM(cPCodRet2)||')';
						
						INSERT INTO bdimnsj:"informix".mnsjr_bitacora_sms(fechasolicitud,proceso,texto_msj,usuario,pass,cel,compania,respuestasolicitud,numcte,sucursal,param1,param2,param3)
						VALUES(current, vproceso, pTexto_msj,pUsuario,pPass,pCel,pCompania,ejec2,cNumCte,cSucursal,PARAM1,PARAM2,PARAM3);
						
					ELSE
						LET ejec2 = '00006, La cantidad no es un valor entero';
						INSERT INTO bdimnsj:"informix".mnsjr_bitacora_sms(fechasolicitud,proceso,texto_msj,usuario,pass,cel,compania,respuestasolicitud,numcte,sucursal,param1,param2,param3)
						VALUES(current, vproceso,pTexto_msj,pUsuario,pPass,pCel,pCompania,ejec2,cNumCte,cSucursal,PARAM1,PARAM2,PARAM3);
						RETURN '00006','La cantidad no es un valor entero';
					END IF
				ELSE
					LET ejec2 = '00005, La cantidad no  es un valor numerico';
					INSERT INTO bdimnsj:"informix".mnsjr_bitacora_sms(fechasolicitud,proceso,texto_msj,usuario,pass,cel,compania,respuestasolicitud,numcte,sucursal,param1,param2,param3)
					VALUES(current, vproceso,pTexto_msj,pUsuario,pPass,pCel,pCompania,ejec2,cNumCte,cSucursal,PARAM1,PARAM2,PARAM3);
					RETURN '00005','La cantidad no  es un valor numerico';
				END IF
			END IF
		ELIF PARAM1 = 'VALIDA' THEN -- INICIA PALABRA CLAVE VALIDA	
			IF PARAM2 = '1' THEN
				-- AURONIX
				EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','VAL_AURO','VAL_AURO','000000000','','','1','','','','','','','','','','','',pCel,1,0,0,0,0,CURRENT,'')
				INTO cPCodRet;
				LET ejec2 = 'Respuesta('''||TRIM(cPCodRet)||''')';
				
				INSERT INTO bdimnsj:"informix".mnsjr_bitacora_sms(fechasolicitud,proceso,texto_msj,usuario,pass,cel,compania,respuestasolicitud,numcte,sucursal,param1,param2,param3)
				VALUES(current, vproceso, pTexto_msj,pUsuario,pPass,pCel,pCompania,ejec2,cNumCte,cSucursal,PARAM1,PARAM2,PARAM3);
				
			ELIF PARAM2 = '2' THEN
				-- AUTOAGENTE
				EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','VAL_AUTO','VAL_AUTO','000000000','','','1','','','','','','','','','','','',pCel,1,0,0,0,0,CURRENT,'')
				INTO cPCodRet;

				LET ejec2 = 'Respuesta('''||TRIM(cPCodRet)||''')';

				INSERT INTO bdimnsj:"informix".mnsjr_bitacora_sms(fechasolicitud,proceso,texto_msj,usuario,pass,cel,compania,respuestasolicitud,numcte,sucursal,param1,param2,param3)
				VALUES(current, vproceso, pTexto_msj,pUsuario,pPass,pCel,pCompania,ejec2,cNumCte,cSucursal,PARAM1,PARAM2,PARAM3);

			ELIF PARAM2 = '3' THEN
				-- INNOVATIA
				EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','VAL_INNO','VAL_INNO','000000000','','','1','','','','','','','','','','','',pCel,1,0,0,0,0,CURRENT,'')
				INTO cPCodRet;

				LET ejec2 = 'Respuesta('''||TRIM(cPCodRet)||''')';
				
				INSERT INTO bdimnsj:"informix".mnsjr_bitacora_sms(fechasolicitud,proceso,texto_msj,usuario,pass,cel,compania,respuestasolicitud,numcte,sucursal,param1,param2,param3)
				VALUES(current, vproceso, pTexto_msj,pUsuario,pPass,pCel,pCompania,ejec2,cNumCte,cSucursal,PARAM1,PARAM2,PARAM3);
				
			ELIF PARAM2 = '4' THEN
				-- AURONX, AUTOAGENTE E INNOVATIA
				EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','VAL_AURO','VAL_AURO','000000000','','','1','','','','','','','','','','','',pCel,1,0,0,0,0,CURRENT,'')
				INTO cPCodRet;

				LET ejec2 = 'Respuesta('''||TRIM(cPCodRet)||''')';
				
				INSERT INTO bdimnsj:"informix".mnsjr_bitacora_sms(fechasolicitud,proceso,texto_msj,usuario,pass,cel,compania,respuestasolicitud,numcte,sucursal,param1,param2,param3)
				VALUES(current, vproceso, pTexto_msj,pUsuario,pPass,pCel,pCompania,ejec2,cNumCte,cSucursal,PARAM1,PARAM2,PARAM3);
				
				EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','VAL_AUTO','VAL_AUTO','000000000','','','1','','','','','','','','','','','',pCel,1,0,0,0,0,CURRENT,'')
				INTO cPCodRet3;

				LET ejec2 = 'Respuesta('''||TRIM(cPCodRet3)||''')';

				INSERT INTO bdimnsj:"informix".mnsjr_bitacora_sms(fechasolicitud,proceso,texto_msj,usuario,pass,cel,compania,respuestasolicitud,numcte,sucursal,param1,param2,param3)
				VALUES(current, vproceso, pTexto_msj,pUsuario,pPass,pCel,pCompania,ejec2,cNumCte,cSucursal,PARAM1,PARAM2,PARAM3);
				
				EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','VAL_INNO','VAL_INNO','000000000','','','1','','','','','','','','','','','',pCel,1,0,0,0,0,CURRENT,'')
				INTO cPCodRet4;

				LET ejec2 = 'Respuesta('''||TRIM(cPCodRet4)||''')';

				INSERT INTO bdimnsj:"informix".mnsjr_bitacora_sms(fechasolicitud,proceso,texto_msj,usuario,pass,cel,compania,respuestasolicitud,numcte,sucursal,param1,param2,param3)
				VALUES(current, vproceso, pTexto_msj,pUsuario,pPass,pCel,pCompania,ejec2,cNumCte,cSucursal,PARAM1,PARAM2,PARAM3);
			ELIF PARAM2 = '5' THEN
				-- AURONX, AUTOAGENTE E INNOVATIA POR BATCH
				EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','VAL_AURO','VAL_AURO','000000000','','','2','','','','','','','','','','','',pCel,1,0,0,0,0,CURRENT,'')
				INTO cPCodRet;

				LET ejec2 = 'Respuesta('''||TRIM(cPCodRet)||''')';
				
				INSERT INTO bdimnsj:"informix".mnsjr_bitacora_sms(fechasolicitud,proceso,texto_msj,usuario,pass,cel,compania,respuestasolicitud,numcte,sucursal,param1,param2,param3)
				VALUES(current, vproceso, pTexto_msj,pUsuario,pPass,pCel,pCompania,ejec2,cNumCte,cSucursal,PARAM1,PARAM2,PARAM3);
				
				EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','VAL_AUTO','VAL_AUTO','000000000','','','2','','','','','','','','','','','',pCel,1,0,0,0,0,CURRENT,'')
				INTO cPCodRet3;

				LET ejec2 = 'Respuesta('''||TRIM(cPCodRet3)||''')';

				INSERT INTO bdimnsj:"informix".mnsjr_bitacora_sms(fechasolicitud,proceso,texto_msj,usuario,pass,cel,compania,respuestasolicitud,numcte,sucursal,param1,param2,param3)
				VALUES(current, vproceso, pTexto_msj,pUsuario,pPass,pCel,pCompania,ejec2,cNumCte,cSucursal,PARAM1,PARAM2,PARAM3);
				
				EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','VAL_INNO','VAL_INNO','000000000','','','2','','','','','','','','','','','',pCel,1,0,0,0,0,CURRENT,'')
				INTO cPCodRet4;

				LET ejec2 = 'Respuesta('''||TRIM(cPCodRet4)||''')';

				INSERT INTO bdimnsj:"informix".mnsjr_bitacora_sms(fechasolicitud,proceso,texto_msj,usuario,pass,cel,compania,respuestasolicitud,numcte,sucursal,param1,param2,param3)
				VALUES(current, vproceso, pTexto_msj,pUsuario,pPass,pCel,pCompania,ejec2,cNumCte,cSucursal,PARAM1,PARAM2,PARAM3);
			ELIF PARAM2 = 'CORREO' THEN
				-- CORREO
				IF cNumCte <> '' Or cNumCte IS NOT NULL THEN 
					EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','MON_ALERT','MON_ALERT',cNumCte,'','','1','','','','','','','','','','','','',1,0,0,0,0,CURRENT,'')
					INTO cPCodRet;
				END IF;

				LET ejec2 = 'Respuesta('''||TRIM(cPCodRet)||''')';
				
				INSERT INTO bdimnsj:"informix".mnsjr_bitacora_sms(fechasolicitud,proceso,texto_msj,usuario,pass,cel,compania,respuestasolicitud,numcte,sucursal,param1,param2,param3)
				VALUES(current, vproceso, pTexto_msj,pUsuario,pPass,pCel,pCompania,ejec2,cNumCte,cSucursal,PARAM1,PARAM2,PARAM3);

			END IF;
		ELIF PARAM1 = 'PAGOSFIJOS' THEN
				EXECUTE PROCEDURE bdimnsj:"informix".sp_valida_esnumerico(PARAM3)
				INTO cPCodRet4;
				IF cPCodRet4 = 'V' THEN
					IF PARAM3 = PARAM3::INT THEN
						IF UPPER(PARAM2) = 'SALDO' THEN
							LET vproceso='sp_credisol_contrata_x_sms_sdos';
							EXECUTE PROCEDURE bdicred:"informix".sp_credisol_contrata_x_sms_sdos('001', 2, pCel,PARAM3) INTO cPCodRet2;
						ELSE
							LET vproceso='sp_credisol_contrata_x_sms';
							EXECUTE PROCEDURE bdicred:"informix".sp_credisol_contrata_x_sms('001',2,pCel,PARAM2,0,PARAM3) INTO cPCodRet2;
						END IF;
						
						LET cReturnCode = cPCodRet2;
						LET ejec2 = 'Respuesta('''||TRIM(cPCodRet2)||')';
			
					ELSE
						LET ejec2 = 'Respuesta(00006, La cantidad no  es un valor entero)';
						LET cPCodRet1= '00006';
						LET cErrorDescription = ' La cantidad no es un valor entero';
					END IF
				ELSE
					LET ejec2 = 'Respuesta(00005, La cantidad no es un valor numerico)';
					LET cPCodRet1= '00005';
					LET cErrorDescription = ' La cantidad no es un valor entero';

				END IF
	
				INSERT INTO bdimnsj:"informix".mnsjr_bitacora_sms(fechasolicitud,proceso,texto_msj,usuario,pass,cel,compania,respuestasolicitud,numcte,sucursal,param1,param2,param3)
				VALUES(current, vproceso,pTexto_msj,pUsuario,pPass,pCel,pCompania,ejec2,cNumCte,cSucursal,PARAM1,PARAM2,PARAM3);
				
				IF cPCodRet1 <> '00000' THEN 
					RETURN cPCodRet1, cErrorDescription;
				END IF
	
		ELIF PARAM1 = 'INCREMENTO' THEN
				
				EXECUTE PROCEDURE bdisolic:"informix".sp_rep_aumlincred_sms(pCel,PARAM1) INTO cPCodRet2;
					
				LET cReturnCode = cPCodRet2;
				LET ejec2 = 'Respuesta('''||TRIM(cPCodRet2)||')';
					
				INSERT INTO bdimnsj:"informix".mnsjr_bitacora_sms(fechasolicitud,proceso,texto_msj,usuario,pass,cel,compania,respuestasolicitud,numcte,sucursal,param1,param2,param3)
				VALUES(current, vproceso,pTexto_msj,pUsuario,pPass,pCel,pCompania,ejec2,cNumCte,cSucursal,PARAM1,PARAM2,PARAM3);
				
		ELIF PARAM1 = 'ACLARACION' THEN

				EXECUTE PROCEDURE bdiaclaracion:"informix".sp_consulta_aclaracion_sms(PARAM2,pCel,cNumCte) INTO cPCodRet2;

				LET cReturnCode = cPCodRet2;
				LET ejec2 = 'Respuesta('''||TRIM(cPCodRet2)||')';

				INSERT INTO bdimnsj:"informix".mnsjr_bitacora_sms(fechasolicitud,proceso,texto_msj,usuario,pass,cel,compania,respuestasolicitud,numcte,sucursal,param1,param2,param3)
				VALUES(current, vproceso,pTexto_msj,pUsuario,pPass,pCel,pCompania,ejec2,cNumCte,cSucursal,PARAM1,PARAM2,PARAM3);
				
		ELIF PARAM1 = 'CANCELAR' THEN

				EXECUTE PROCEDURE bdicred:"informix".sp_credisol_contrata_x_sms('001',5,pCel,'',0,'0') INTO cPCodRet2;

				LET cReturnCode = cPCodRet2;
				LET ejec2 = 'Respuesta('''||TRIM(cPCodRet2)||')';

				INSERT INTO bdimnsj:"informix".mnsjr_bitacora_sms(fechasolicitud,proceso,texto_msj,usuario,pass,cel,compania,respuestasolicitud,numcte,sucursal,param1,param2,param3)
				VALUES(current, vproceso,pTexto_msj,pUsuario,pPass,pCel,pCompania,ejec2,cNumCte,cSucursal,PARAM1,PARAM2,PARAM3);
        
		ELIF PARAM1 = 'CANSALDO' THEN

				--EXECUTE PROCEDURE bdicred:"informix".sp_credisol_contrata_x_sms('001',5,pCel,'',0,'0') INTO cPCodRet2;
                EXECUTE PROCEDURE bdicred:"informix".sp_credisol_contrata_x_sms_sdos('001',5,pCel,'','') INTO cPCodRet2;
				LET cReturnCode = cPCodRet2;
				LET ejec2 = 'Respuesta('''||TRIM(cPCodRet2)||')';

				INSERT INTO bdimnsj:"informix".mnsjr_bitacora_sms(fechasolicitud,proceso,texto_msj,usuario,pass,cel,compania,respuestasolicitud,numcte,sucursal,param1,param2,param3)
				VALUES(current, vproceso,pTexto_msj,pUsuario,pPass,pCel,pCompania,ejec2,cNumCte,cSucursal,'CANCELAR',PARAM2,PARAM3);
    
		ELIF PARAM1 = 'CONFIRMA' THEN

	             UPDATE bdinteg:si_telefonos SET verificado='V' WHERE telefono = pCel AND tipo_tel=2 AND status_tel='A';
				 
				EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','SMS_RECI','CONFIR_CEL','000000000','','','1','','','','','','','','','','','',pCel,1,0,0,0,0,CURRENT,'')
				INTO cPCodRet;

				LET cReturnCode = '00000';
				LET ejec2 = 'Respuesta('''||TRIM(cPCodRet)||')';

				INSERT INTO bdimnsj:"informix".mnsjr_bitacora_sms(fechasolicitud,proceso,texto_msj,usuario,pass,cel,compania,respuestasolicitud,numcte,sucursal,param1,param2,param3)
				VALUES(current, vproceso,pTexto_msj,pUsuario,pPass,pCel,pCompania,ejec2,cNumCte,cSucursal,PARAM1,PARAM2,PARAM3);
		
		ELIF PARAM1 = 'INE' THEN

	            IF cNumCte <> '' Or cNumCte IS NOT NULL THEN 
				
		            SELECT FIRST 1 numcte INTO cNumCte2 
		               FROM TABLE(MULTISET(
							SELECT numcte
							FROM bdinteg:"informix".si_bitacora_huella_ine 
							WHERE numcte = cNumCte
		            ));
                    IF cNumCte2 <> '' AND cNumCte2 IS NOT NULL THEN
  					    EXECUTE PROCEDURE "informix".sp_registra_evento('2','SMS_RECI','INE_VERI','000000000','','','1','','','','','','','','','','','',pCel,1,0,0,0,0,'','')
						INTO cPCodRet;
					ELSE
                        EXECUTE PROCEDURE "informix".sp_registra_evento('2','SMS_RECI','INE_NO_VERI','000000000','','','1','','','','','','','','','','','',pCel,1,0,0,0,0,'','')
						INTO cPCodRet;
                    END IF;					
				ELSE
                    EXECUTE PROCEDURE "informix".sp_registra_evento('2','SMS_RECI','INE_NO_VERI','000000000','','','1','','','','','','','','','','','',pCel,1,0,0,0,0,'','')
					INTO cPCodRet;				    
				END IF;

				LET cReturnCode = '00000';
				LET ejec2 = 'Respuesta('''||TRIM(cPCodRet)||''')';

				INSERT INTO bdimnsj:"informix".mnsjr_bitacora_sms(fechasolicitud,proceso,texto_msj,usuario,pass,cel,compania,respuestasolicitud,numcte,sucursal,param1,param2,param3)
				VALUES(current, vproceso,pTexto_msj,pUsuario,pPass,pCel,pCompania,ejec2,cNumCte,cSucursal,PARAM1,PARAM2,PARAM3);

		ELIF PARAM1 = 'BAJAPLAN' THEN
		
				EXECUTE PROCEDURE bdicred:sp_diferir_cancela (cNumCte,pCel,'',9)INTO cPCodRet2, vRetornoDescription;
				
				
				EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','SMS_RECI','SMS_BAJAPLAN','000000000','','','1','','','','',TRIM(vRetornoDescription),'','','','','','',pCel,1,0,0,0,0,CURRENT,'')
				INTO cPCodRet;

				LET cReturnCode = '00000';
				LET ejec2 = 'Respuesta('''||TRIM(cPCodRet)||','||TRIM(vRetornoDescription)||')';

				INSERT INTO bdimnsj:"informix".mnsjr_bitacora_sms(fechasolicitud,proceso,texto_msj,usuario,pass,cel,compania,respuestasolicitud,numcte,sucursal,param1,param2,param3)
				VALUES(current, vproceso,pTexto_msj,pUsuario,pPass,pCel,pCompania,ejec2,cNumCte,cSucursal,PARAM1,PARAM2,PARAM3);				
		
		ELIF PARAM1 = 'SIMULADOR' THEN
				
				EXECUTE PROCEDURE bdimnsj:"informix".sp_valida_esnumerico(PARAM3)
				INTO cPCodRet4;
				IF cPCodRet4 = 'V' THEN
					IF PARAM3 = PARAM3::INT THEN
						EXECUTE PROCEDURE bdisolic:"informix".sp_prestamoflex_sms(4, pCel, PARAM3) 
						INTO cPCodRet2;
						
						LET cReturnCode = cPCodRet2;
						LET ejec2 = 'Respuesta('''||TRIM(cPCodRet2)||')'; 
						
						INSERT INTO bdimnsj:"informix".mnsjr_bitacora_sms(fechasolicitud,proceso,texto_msj,usuario,pass,cel,compania,respuestasolicitud,numcte,sucursal,param1,param2,param3)
						VALUES(current, vproceso, pTexto_msj,pUsuario,pPass,pCel,pCompania,ejec2,cNumCte,cSucursal,'PRESTAMO',PARAM1,PARAM3);
						
					ELSE
						LET ejec2 = '00006, La cantidad no es un valor entero';
						INSERT INTO bdimnsj:"informix".mnsjr_bitacora_sms(fechasolicitud,proceso,texto_msj,usuario,pass,cel,compania,respuestasolicitud,numcte,sucursal,param1,param2,param3)
						VALUES(current, vproceso,pTexto_msj,pUsuario,pPass,pCel,pCompania,ejec2,cNumCte,cSucursal,'PRESTAMO',PARAM1,PARAM3);
						RETURN '00006','La cantidad no es un valor entero';
					END IF
				ELSE
					LET ejec2 = '00005, La cantidad no  es un valor numerico';
					INSERT INTO bdimnsj:"informix".mnsjr_bitacora_sms(fechasolicitud,proceso,texto_msj,usuario,pass,cel,compania,respuestasolicitud,numcte,sucursal,param1,param2,param3)
					VALUES(current, vproceso,pTexto_msj,pUsuario,pPass,pCel,pCompania,ejec2,cNumCte,cSucursal,'PRESTAMO',PARAM1,PARAM3);
					RETURN '00005','La cantidad no  es un valor numerico';
				END IF
		
		------INICIATIVA DE INCREMENTO DE CREDITO PARA PRESTAMO DIGITAL
		ELIF PARAM1 = 'S'  OR PARAM1 = 'N' THEN
		
				EXECUTE PROCEDURE bdicred:"informix".sp_actualiza_linea_pdigital ('', PARAM1,'1','',pCel)INTO cPCodRet5;
	
				IF cPCodRet5 = '000000' THEN
					LET vRetornoDescription = 'ACEPTA INCREMENTO';
				ELIF cPCodRet5 = '000001' THEN
					LET vRetornoDescription = 'PARAMETRO VACIO';
				ELIF cPCodRet5 = '000002' THEN
					LET vRetornoDescription = 'NO ACEPTA OFERTA';
				ELIF cPCodRet5 = '000003' THEN
					LET vRetornoDescription = 'OFERTA INACTIVA';
				ELIF cPCodRet5 = '000004' THEN
					LET vRetornoDescription = 'OFERTA NULA';
				END IF;
				
				LET cReturnCode = '00000';
				LET ejec2 = 'Respuesta('''||TRIM(cPCodRet5)||','||TRIM(vRetornoDescription)||')';

				INSERT INTO bdimnsj:"informix".mnsjr_bitacora_sms(fechasolicitud,proceso,texto_msj,usuario,pass,cel,compania,respuestasolicitud,numcte,sucursal,param1,param2,param3)
				VALUES(current, vproceso,pTexto_msj,pUsuario,pPass,pCel,pCompania,ejec2,cNumCte,cSucursal,PARAM1,PARAM2,PARAM3);

		ELIF PARAM1 = 'ACEPTAR' THEN -----Incremento Linea de credito TDC por inflacion


				EXECUTE PROCEDURE bdicred:"informix".sp_obtener_tarjeta_incremento_inflacion('001',cNumCte) INTO cPCodRet1,c_term_tarjeta,c_nombre_prod;


				EXECUTE PROCEDURE "informix".sp_registra_evento('2','SMS_RECI','SMS_INCSAL2',cNumCte,'',c_term_tarjeta,'2','','','','',c_nombre_prod,'','','','','',
				'','',0,0,0,0,0,'','') INTO cPCodRet ;


				EXECUTE PROCEDURE bdicred:"informix".sp_actualizar_linea_credito_tc_inflacion('001','','','9','',pCel,'',cNumCte,'') INTO cPCodRet2;
								
				IF cPCodRet2 = '000000' THEN
					LET vRetornoDescription = 'ACEPTA INCREMENTO';
				ELSE
					LET vRetornoDescription = 'OFERTA NULA';
				END IF;
				
				LET ejec2 = 'Respuesta('''||TRIM(cPCodRet2)||','||TRIM(vRetornoDescription)||')';

				INSERT INTO bdimnsj:"informix".mnsjr_bitacora_sms(fechasolicitud,proceso,texto_msj,usuario,pass,cel,compania,respuestasolicitud,numcte,sucursal,param1,param2,param3)
				VALUES(current, vproceso,pTexto_msj,pUsuario,pPass,pCel,pCompania,ejec2,cNumCte,cSucursal,PARAM1,PARAM2,PARAM3);
		END IF;
		RETURN '00000', cErrorDescription;
	END;
END PROCEDURE;
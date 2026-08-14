CREATE PROCEDURE "informix".sp_reverso_msw(pOrigen CHAR(4),pCategoria CHAR(2),pConvenio CHAR(3),pUsuario CHAR(8),pFolio CHAR(16),pFecha CHAR(8),pHora CHAR(6))
	RETURNING
	CHAR(5)		AS codigo,	
	CHAR(30)	AS mensaje;	
	
	DEFINE iSqlErr       INTEGER;
    DEFINE iIsamErr      INTEGER;
    DEFINE cInfoErr      CHAR(100);
	DEFINE cCodRet       CHAR(5);
	DEFINE cMensaje		 CHAR(30);
	DEFINE cReversable	 CHAR(1);
	DEFINE iExiste		 INTEGER;
	DEFINE cSucursal     CHAR(4);
	DEFINE dFecha_actual DATE;
	DEFINE cFechaFormat	 CHAR(8);
	DEFINE cHora_Reverso 	CHAR(6);
	DEFINE cNumero_Cuenta 	CHAR(12);
	
	LET cCodRet       = "00000";
	LET cMensaje      = "Exitoso";
	LET cReversable   = '';
	LET iExiste		  = 0;
	LET cSucursal	  = '';
	LET dFecha_actual = '';
	LET cFechaFormat  = '';
	LET cHora_Reverso 	= '';
	LET cNumero_Cuenta 	= '';
	
	--SET DEBUG FILE TO  '/home/e10000161/sp_reverso_msw.out'; 
	--TRACE ON;
	
	BEGIN
		ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
            IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;
				LET cMensaje = "Error: sp_reverso_msw";
				UPDATE "informix".bitacora_reverso_msw SET codret = cCodRet, Mensaje = cMensaje 
			     WHERE categoria = pCategoria and convenio = pConvenio and folio = pFolio and
				       fecha = pFecha and hora = pHora;
                EXECUTE PROCEDURE "informix".sp_sac_guardamensajeerror(iSqlErr, iIsamErr, cInfoErr, "sp_reverso_msw_epg");
                RETURN cCodRet, cMensaje;
            END IF;
        END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
	    SET LOCK MODE TO WAIT 3;

	    -- HoraReverso
		IF pCategoria = '03' AND pConvenio = '001' AND SUBSTR(pHora, 1, 1) = 'R' THEN
			LET cHora_Reverso = pHora;
			LET pHora = TO_CHAR(CURRENT HOUR TO SECOND, '%H%M%S');
		END IF;
		
         INSERT INTO "informix".bitacora_reverso_msw 
         VALUES (pOrigen,pCategoria,pConvenio,pUsuario,pFolio,pFecha,pHora,'','',CURRENT);
        
		SELECT fecha_hoy into dFecha_actual FROM "informix".sac_fechas;
		LET cFechaFormat = YEAR(dFecha_actual) || LPAD(MONTH(dFecha_actual),2,0) || LPAD(DAY(dFecha_actual),2,0);	
		
		IF pOrigen = "" OR pCategoria = "" OR pConvenio = "" OR pFolio = "" OR cFechaFormat <> pFecha THEN
			LET cCodRet = '00400';
			LET cMensaje = 'Error:sp_reverso_msw';
			UPDATE "informix".bitacora_reverso_msw SET codret = cCodRet, Mensaje = cMensaje 
			 WHERE categoria = pCategoria and convenio = pConvenio and folio = pFolio and
				   fecha = pFecha and hora = pHora;
            RETURN cCodRet, cMensaje;
		END IF;

		IF pOrigen = "CPL"  THEN
                
			  SELECT reversable 
                INTO cReversable
			    FROM "informix".sac_controlconvenios
			   WHERE estatus = 'A' 
                 AND status_cpl = 'A'
			     AND numcategoria = pCategoria 
                 AND numconvenio = pConvenio;
			
			   SELECT id_sucursal, count(*)
				 INTO cSucursal,iExiste
				 FROM "informix".sac_movimientos
			    WHERE numcategoria = pCategoria 
                  AND numconvenio = pConvenio
				  AND folio_suc = pFolio
				  AND origen = pOrigen group by id_sucursal;
				  
			IF  dbinfo("sqlca.sqlerrd2") = 0 THEN
				LET cCodRet = '00401';
				LET cMensaje = 'Error:No existe Folio';
				UPDATE "informix".bitacora_reverso_msw SET codret = cCodRet, Mensaje = cMensaje 
				 WHERE categoria = pCategoria and convenio = pConvenio and folio = pFolio and
					   fecha = pFecha and hora = pHora;
				RETURN cCodRet, cMensaje;
			END IF;
			
			IF cReversable = 1 AND iExiste = 1 THEN 			
					
				IF pCategoria||pConvenio = '02003' OR pCategoria||pConvenio = '04001' OR pCategoria||pConvenio = '06004' OR pCategoria||pConvenio = '09011' THEN 	
					
					EXECUTE PROCEDURE "informix".sp_reversionsac('001', cSucursal, pUsuario, pFolio) INTO cCodRet;
					IF cCodRet = '001' THEN
						LET cCodRet = '00000';
					  UPDATE "informix".bitacora_reverso_msw SET codret = cCodRet, Mensaje = cMensaje 
					   WHERE categoria = pCategoria and convenio = pConvenio and folio = pFolio and
							 fecha = pFecha and hora = pHora;
					ELSE
						LET cCodRet = '00402';
						LET cMensaje = 'Error: sp_reverso_msw';
						UPDATE "informix".bitacora_reverso_msw SET codret = cCodRet, Mensaje = cMensaje 
						 WHERE categoria = pCategoria and convenio = pConvenio and folio = pFolio and
							   fecha = pFecha and hora = pHora;
					END IF;
				
				ELSE	
				
					EXECUTE PROCEDURE bdicheq:"informix".reversion('001', cSucursal, pUsuario, pFolio, '') INTO cCodRet;
					IF cCodRet = '000' THEN
						LET cCodRet = '00000';
					  UPDATE "informix".bitacora_reverso_msw SET codret = cCodRet, Mensaje = cMensaje 
					   WHERE categoria = pCategoria and convenio = pConvenio and folio = pFolio and
							 fecha = pFecha and hora = pHora;
					ELSE
						LET cCodRet = '00402';
						LET cMensaje = 'Error: sp_reverso_msw';
						UPDATE "informix".bitacora_reverso_msw SET codret = cCodRet, Mensaje = cMensaje 
						 WHERE categoria = pCategoria and convenio = pConvenio and folio = pFolio and
							   fecha = pFecha and hora = pHora;
					END IF;	
				
				END IF;	
				
			ELSE
				LET cCodRet = '00403';
				LET cMensaje = 'Servicio no permite reverso';
				UPDATE "informix".bitacora_reverso_msw SET codret = cCodRet, Mensaje = cMensaje 
				 WHERE categoria = pCategoria and convenio = pConvenio and folio = pFolio and
					   fecha = pFecha and hora = pHora;
			END IF;
						
			RETURN cCodRet, cMensaje;
		ELIF pOrigen = "BEX" OR pOrigen = "bex"  THEN
			SELECT reversable 
                INTO cReversable
			    FROM "informix".sac_controlconvenios
			   WHERE estatus = 'A' 
                 AND status_bex = 'A'
			     AND numcategoria = pCategoria 
                 AND numconvenio = pConvenio;
			
				--HoraReverso			
				IF pCategoria = '03' AND pConvenio = '001' AND SUBSTR(cHora_Reverso, 1, 1) = 'R' THEN
					LET cNumero_Cuenta = SUBSTR(pFolio,1,11);
					--OBTIENE NUMERO DE CLIENTE DE LA CUENTA EJE
			        SELECT TRIM(num_cte)|| SUBSTR(pFolio,12,5) || SUBSTR(cHora_Reverso,5,2)
					INTO pFolio
					FROM bdicheq:"informix".sc_maechq 
					WHERE cuenta = cNumero_Cuenta;
					
					IF dbinfo("sqlca.sqlerrd2") = 0 THEN
						LET cCodRet = "00309";
						LET cMensaje = 'Cuenta eje invalida';
						RETURN cCodRet, cMensaje;
					END IF;
					
					LET cMensaje = pFolio;
				END IF;
			
			   SELECT id_sucursal, count(*)
				 INTO cSucursal,iExiste
				 FROM "informix".sac_movimientos
			    WHERE numcategoria = pCategoria 
                  AND numconvenio = pConvenio
				  AND folio_suc = pFolio
				  AND origen = pOrigen group by id_sucursal;
				  
			IF  dbinfo("sqlca.sqlerrd2") = 0 THEN
				LET cCodRet = '00401';
				LET cMensaje = 'Error:No existe Folio';
				UPDATE "informix".bitacora_reverso_msw SET codret = cCodRet, Mensaje = cMensaje 
				 WHERE categoria = pCategoria and convenio = pConvenio and folio = pFolio and
					   fecha = pFecha and hora = pHora;
				RETURN cCodRet, cMensaje;
			END IF;
			
			IF cReversable = 1 AND iExiste = 1 THEN 		
				EXECUTE PROCEDURE bdicheq:"informix".reversion('001', cSucursal, pUsuario, pFolio, '') INTO cCodRet;
				IF cCodRet = '000' THEN
					LET cCodRet = '00000';
					UPDATE "informix".bitacora_reverso_msw SET codret = cCodRet, Mensaje = cMensaje 
					WHERE 	categoria = pCategoria and convenio = pConvenio and folio = pFolio and
							fecha = pFecha and hora = pHora;
				ELSE
					LET cCodRet = '00402';
					LET cMensaje = 'Error: sp_reverso_msw';
					UPDATE "informix".bitacora_reverso_msw SET codret = cCodRet, Mensaje = cMensaje 
					WHERE categoria = pCategoria and convenio = pConvenio and folio = pFolio and
						fecha = pFecha and hora = pHora;
				END IF;
				--Se reversa  bitacora_aplicapago_hs cConfirma_pago a 0
				UPDATE "informix".bitacora_aplicapago_hs SET confirma_pago = 0
				WHERE categoria = pCategoria and convenio = pConvenio and folio_operacion = pFolio;
			ELSE
				LET cCodRet = '00403';
				LET cMensaje = 'Servicio no permite reverso';
				UPDATE "informix".bitacora_reverso_msw SET codret = cCodRet, Mensaje = cMensaje 
				 WHERE categoria = pCategoria and convenio = pConvenio and folio = pFolio and
					   fecha = pFecha and hora = pHora;
			END IF;
						
			RETURN cCodRet, cMensaje;
		ELSE
		    LET cCodRet = '00404';
			LET cMensaje = 'Origen Desconocido';
			UPDATE "informix".bitacora_reverso_msw SET codret = cCodRet, Mensaje = cMensaje 
			 WHERE categoria = pCategoria and convenio = pConvenio and folio = pFolio and
				   fecha = pFecha and hora = pHora;
            RETURN cCodRet, cMensaje;
		END IF;
		
	END;
END PROCEDURE;
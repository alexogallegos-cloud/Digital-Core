CREATE PROCEDURE "informix".sp_actualizadatos_reevaluacion(pEmpresa CHAR(3), pNumSol CHAR(20),pNumCte CHAR(20),pFlagPagIni CHAR(1),pPorcPagIni CHAR(4), pMontoPagoInicial INTEGER, pFlagPrestamo CHAR(1),pFlagTipoMsgMotos CHAR(1),pMontoDispMotos INTEGER,pPorcPIMotos CHAR(4))

	RETURNING 	CHAR(6) 					AS Cod_Ret;

	DEFINE cCod_Ret						CHAR(6);	
	DEFINE iSqlErr						INTEGER;		
	DEFINE iActualiza					INTEGER;
	
	LET cCod_Ret						= '000000';	
	LET iSqlErr							= 0;
	LET iActualiza						= 0;
	LET pEmpresa 						= TRIM(NVL(pEmpresa,''));
	LET pNumCte 						= TRIM(NVL(pNumCte,''));
	LET pNumSol 						= TRIM(NVL(pNumSol,''));	
	LET pFlagPagIni 					= TRIM(NVL(pFlagPagIni,''));
	LET pPorcPagIni 					= TRIM(NVL(pPorcPagIni,''));
	LET pMontoPagoInicial 				= NVL(pMontoPagoInicial,0);
	LET pFlagPrestamo 					= TRIM(NVL(pFlagPrestamo,''));
	LET pFlagTipoMsgMotos  				= TRIM(NVL(pFlagTipoMsgMotos,'0'));
	LET pMontoDispMotos					= NVL(pMontoDispMotos,0);
	LET pPorcPIMotos					= TRIM(NVL(pPorcPIMotos,''));
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCod_Ret = iSqlErr;
			RETURN cCod_Ret;
		END EXCEPTION;

		--SET DEBUG FILE TO "/tmp/sp_actualizadatos_reevaluacion.out";
		--TRACE ON;
	
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pEmpresa <> '' AND pNumCte <> '' AND pNumSol <> '' THEN
		
			--ACTUALIZA LA INFORMACION CON LA RESPUESTA RECIBIDA
			-- DEL PARAMETRICO COPPEL A LA TDC COPPEL
			UPDATE "informix".ss_nuevo_parametrico 
			SET flag_pagoini = pFlagPagIni,
				porc_pagoini = pPorcPagIni,
				monto_disp_pagoini = pMontoPagoInicial,
				flag_prestamo = pFlagPrestamo,
				flagtipomsgmotos = pFlagTipoMsgMotos,
				montodispmotos = pMontoDispMotos,
				porcpimotos = pPorcPIMotos
			WHERE empresa = pEmpresa
			AND num_solicitud = pNumSol;
	
			LET iActualiza = dbinfo("sqlca.sqlerrd2");
			
			--SI NO SE REALIZA LA ACTUALIZACION
			IF iActualiza = 0 THEN
				LET cCod_Ret = '000002';	
			END IF;
		ELSE
			LET cCod_Ret = '000001';	
		END IF;
		
		RETURN cCod_Ret;
		
	END;				
END PROCEDURE

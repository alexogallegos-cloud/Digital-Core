CREATE PROCEDURE "informix".sp_actualizadatos_reevaluacion_web(pEmpresa CHAR(3), pNumSol CHAR(20),pNumCte CHAR(20),pFlagPagIni CHAR(1),pPorcPagIni CHAR(4), pMontoPagoInicial INTEGER, pFlagPrestamo CHAR(1))

	RETURNING 	CHAR(5) AS Cod_Ret;

	DEFINE cCod_Ret			CHAR(5);	
	DEFINE iSqlErr			INTEGER;		
	DEFINE iActualiza		INTEGER;
	
	LET cCod_Ret			= '00000';	
	LET iSqlErr				= 0;
	LET iActualiza			= 0;
	LET pEmpresa 			= TRIM(NVL(pEmpresa,''));
	LET pNumCte 			= TRIM(NVL(pNumCte,''));
	LET pNumSol 			= TRIM(NVL(pNumSol,''));	
	LET pFlagPagIni 		= TRIM(NVL(pFlagPagIni,''));
	LET pPorcPagIni 		= TRIM(NVL(pPorcPagIni,''));
	LET pMontoPagoInicial 	= NVL(pMontoPagoInicial,0);
	LET pFlagPrestamo 		= TRIM(NVL(pFlagPrestamo,''));
	
	
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
				flag_prestamo = pFlagPrestamo
			WHERE empresa = pEmpresa
			AND num_solicitud = pNumSol;
	
			LET iActualiza = dbinfo("sqlca.sqlerrd2");
			
			--SI NO SE REALIZA LA ACTUALIZACION
			IF iActualiza = 0 THEN
				LET cCod_Ret = '00002';	
			END IF;
		ELSE
			LET cCod_Ret = '00001';	
		END IF;
		
		RETURN cCod_Ret;
		
	END;				
END PROCEDURE

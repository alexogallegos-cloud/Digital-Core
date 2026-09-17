CREATE PROCEDURE "informix".sp_registrarespuestacoppel_pba( pEmpresa			    CHAR(3),
														pNum_Solic		    CHAR(20),
														pCod_ret			CHAR(3),
														pStatus_solic		CHAR (1),
														pSit_Especial	    CHAR(1),
														pCausa_sitesp		INTEGER,
														pPuntos_parcn		SMALLINT,
														pPar_altoriesgo		SMALLINT,
														pPar_celulares		SMALLINT,
														pPar_prestamos		SMALLINT,
														pIngreso_men		INTEGER,
														pCap_siste_abono	INTEGER,
														pTope_abonocoppel 	INTEGER,														
														pCapmaxima_abono	INTEGER,
														pCapreal_abono		INTEGER,
														pLincred_real		INTEGER,
														pLincred_tope		INTEGER,														
														pFechaLincred_real	CHAR (10),														
														pFechaLincred_tope	CHAR (10),
														pCompromisosSic     INTEGER,
														pFlagLinCreditoEsp  SMALLINT,
														pLimiteCredito		INTEGER,
														pLimitecreditopesos INTEGER,
														pCampo_3     		INTEGER,
														pCampo_4             CHAR(1),
														--DSB-14082017 
														pPrepuntajealtoriesgo CHAR(1),  --  parametro ya existia "pcampo_5" se renombro a "pPrepuntajealtoriesgo" 14/08/2017 
														pCampo_6   			CHAR(1)
														)	
RETURNING CHAR(6)  AS COD_RET,
		  CHAR(80) AS MENSAJE_EJEC;

--DECLARACIÃN DE VARIABLES
DEFINE iSqlErr         		INTEGER;
DEFINE iIsamErr        		INTEGER;
DEFINE iCantReg        		INTEGER;
DEFINE cErrorInfo      		CHAR(80);
DEFINE cCodRet         		CHAR(6);
DEFINE cMensajeRet          CHAR(80);
DEFINE dtFechaLincred_real    DATE;
DEFINE dtFechaLincred_tope    DATE;

--INICIALIZACIÃN DE VARIABLES
LET iSqlErr            	= 0;
LET iIsamErr           	= 0;
LET iCantReg           	= 0;
LET cErrorInfo         	= "";
LET cCodRet            	= "000000";
LET cMensajeRet         = "REGISTRO DE INFORMACION REALIZADO EXITOSAMENTE";
LET dtFechaLincred_real =DATE(1);
LET dtFechaLincred_tope = DATE(1);

BEGIN

	ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
	   IF iSqlErr != 0 THEN
		  LET cCodRet = iSqlErr;
		  LET cMensajeRet = cErrorInfo;
		  RETURN TRIM(cCodRet), TRIM(cMensajeRet);
	   END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO "/home/sysifx/jesusm/sp_registrarespuestacoppel";
	 --TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	UPDATE "informix".ss_solicitudes
		SET envio_parametrico = "2"				
	WHERE num_solicitud = pNum_Solic
	AND empresa = pEmpresa;	
    IF pFechaLincred_real <> "" THEN
		LET dtFechaLincred_real = SUBSTR(pFechaLincred_real,6,2)||'/'|| SUBSTR(pFechaLincred_real,9,2) ||'/'|| SUBSTR(pFechaLincred_real,1,4);
	ELSE
		LET dtFechaLincred_real = "";
	END IF;
	IF pFechaLincred_real <> "" THEN
		LET dtFechaLincred_tope = SUBSTR(pFechaLincred_tope,6,2)||'/'|| SUBSTR(pFechaLincred_tope,9,2) ||'/'|| SUBSTR(pFechaLincred_tope,1,4);
	ELSE
		LET dtFechaLincred_tope = "";
	END IF;
	--JMAH
	IF NOT EXISTS (SELECT num_solicitud FROM bdisolic:"informix".ss_nuevo_parametrico WHERE num_solicitud=pNum_Solic) THEN
	
		INSERT INTO bdisolic:"informix".ss_nuevo_parametrico(
				empresa, num_solicitud, status_solicitud, situacion_especial, causa_sitesp, puntos_parcn, par_altoriesgo, par_celulares, par_prestamos,
				ingreso_mensual, cap_sistematica_abono, tope_abonocoppel, capmaxima_abono, capreal_abono, lineacredito_real,lineacreditotope		,
				fechalineacreditoreal,fechalineacreditotope,compromisossic,flaglineacreditoesp,cod_ret,limitecredito,limitecreditopesos,campo_3,campo_4,prepuntajealtoriesgo,campo_6)
		VALUES (pEmpresa, pNum_Solic, pStatus_solic, pSit_Especial, pCausa_sitesp, pPuntos_parcn, pPar_altoriesgo, pPar_celulares, pPar_prestamos,
				pIngreso_men, pCap_siste_abono, pTope_abonocoppel, pCapmaxima_abono, pCapreal_abono, pLincred_real,pLincred_tope,dtFechaLincred_real,dtFechaLincred_tope,
				pCompromisosSic,pFlagLinCreditoEsp,pCod_ret,pLimiteCredito,pLimitecreditopesos ,pCampo_3,pCampo_4,pPrepuntajealtoriesgo ,pCampo_6  );	ELSE 
		LET cCodRet            	= "000001";
		LET cMensajeRet         = "NO SE REGISTRO LA INFORMACIÃN";
	
	END IF;				
		
	RETURN cCodRet, TRIM(cMensajeRet);
END
END PROCEDURE 

CREATE PROCEDURE "informix".sp_genarchivomonitoreosearchpaywu()
RETURNING
CHAR(5) AS codigo_respuesta,
CHAR(80) AS mensaje_respuesta;

--DEFINICION DE VARIABLES
DEFINE cCodret           CHAR(5);
DEFINE cMensaje			 CHAR(80);
DEFINE iSqlErr           INTEGER;
DEFINE iIsamErr          INTEGER;
DEFINE cInfoErr          CHAR(100);
DEFINE dFecha_Hoy		 DATE;
DEFINE cRutaArch		 CHAR(100);
DEFINE cStmt			 CHAR(250);
DEFINE iCuantosSearch	 INTEGER;
DEFINE iCuantosPay		 INTEGER;

--INICIALIZAR VARIABLES
LET cCodret			= '00000';
LET cMensaje		= 'PROCESO EXITOSO';
LET cInfoErr		= '';
LET dFecha_Hoy 	    = DATE(1);
LET cRutaArch		= '';
LET cStmt			= '';
LET iCuantosSearch	= 0;
LET iCuantosPay		= 0;
	
	BEGIN
		ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;				
				LET cMensaje = 'ERROR';
				EXECUTE PROCEDURE "informix".sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_genarchivomonitoreosearchpaywu");				
				RETURN cCodRet, cMensaje;
			END IF;
		END EXCEPTION;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
		SELECT {+INDEX("informix".sac_fechas "informix".idx_sac_fechas)} fecha_hoy
		INTO dFecha_Hoy
		FROM "informix".sac_fechas
		WHERE empresa = "001";
		
		SELECT {+INDEX("informix".sac_param "informix".idxsc_par)} TRIM(valor)
		INTO cRutaArch
		FROM "informix".sac_param
		WHERE cod_param = '87095';
		
		SELECT {+INDEX ("informix".sac_wu_search "informix".idx_wu_search3)} count(*) as cuantos
		INTO iCuantosSearch
		FROM "informix".sac_wu_search
		WHERE retcode = '99998' 
		AND fecha_insert >= current - 5 UNITS MINUTE;
			

		SELECT {+INDEX ("informix".sac_wu_pay "informix".idx_sac_wu_pay1)} count(*) as cuantos
		INTO iCuantosPay
		FROM "informix".sac_wu_pay
		WHERE retcode = '99998' 
		AND conf_pago = 'P'
		AND fecha_insert >= current - 5 UNITS MINUTE;
		
		--IMPRIME RENGLON DE SEARCH
		LET cStmt='echo "' || dFecha_Hoy || "|" || "search" || "|" || REPLACE(NVL(iCuantosSearch,''),'',0) || '" > ' || cRutaArch;
		SYSTEM cStmt;
		--IMPRIME RENGLON DE PAY
		LET cStmt='echo "' || dFecha_Hoy || "|" || "pay" || "|" || REPLACE(NVL(iCuantosPay,''),'',0) || '" >> ' || cRutaArch;
		SYSTEM cStmt;
		
		RETURN cCodret, cMensaje;		
	END;
END PROCEDURE
;
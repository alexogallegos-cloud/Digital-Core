CREATE PROCEDURE "informix".sp_insertaerrorwu (pTipo INTEGER,pProceso CHAR(45),pCodRet CHAR(5),pDescError CHAR(80),pSql_Err CHAR(6),
                                               pIsamErr CHAR(6), pCadena_ent CHAR (100), pUsuario CHAR(8), pFechaproceso DATETIME YEAR TO SECOND )

RETURNING CHAR(5) AS retorno;

DEFINE	iSqlErr	 INTEGER;
DEFINE	cCodRet	 CHAR(5);
DEFINE 	iIsamErr INTEGER;

LET	iSqlErr = 0;
LET	cCodRet = '00000';
LET	iIsamErr = 0;
    
BEGIN
	ON EXCEPTION SET iSqlErr, iIsamErr
				IF iSqlErr <> 0 THEN
					LET cCodRet = '00000';
--El codigo de retorno tiene que ser exitoso debido a que si es diferente detiene la oepracion
					RETURN cCodRet;
				END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO '/respaldosbd/christian/sp_insertaerrorwu.out';
	--TRACE ON;	

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	IF pTipo = 1 THEN
		INSERT INTO bdisac:"informix".sac_wu_errores (proceso, cod_ret, desc_error, sql_err, isam_err, cadena_ent, user_insert, fecha_hora_insert) 
		       						          VALUES (pProceso, pCodRet, pDescError, pSql_Err, pIsamErr, pCadena_ent, pUsuario, CURRENT:: DATETIME YEAR TO SECOND);
		UPDATE bdisac:"informix".sac_wu_procesos {+  INDEX(sac_wu_procesos idx_wu_procesos1 ) }
		SET status = '2'
		WHERE proceso = pProceso
		AND fecha_proceso = pFechaproceso
		AND user_insert = pUsuario
		AND status = '0';
		
	ELIF pTipo = 2 THEN
			INSERT INTO bdisac:"informix".sac_wu_procesos (proceso, fecha_proceso, status, user_insert, fecha_insert ) 
		       						               VALUES (pProceso, pFechaproceso , '0', pUsuario, CURRENT:: DATETIME YEAR TO SECOND); 
	ELIF pTipo = 3 THEN

			UPDATE bdisac:"informix".sac_wu_procesos {+  INDEX(sac_wu_procesos idx_wu_procesos1 ) }
			SET status = '1'
				WHERE proceso = pProceso
				AND fecha_proceso = pFechaproceso
				AND user_insert = pUsuario
				AND status = '0';
	ELSE
        LET cCodRet = '00000';	--Tipo no valido
	END IF;



	RETURN cCodRet;
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se crea SP para guardar los errores en la tabla sac_wu_errores y los procesos en la tabla sac_wu_procesos de todos los sp que interactuan con el. ',  
'AUTOR: Christian Echavarria',			
'FECHA: 10/Jul/2013',
'BD: bdisac';

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
CREATE PROCEDURE "informix".sp_actualiza_respuestacoppel_cteprosp(cNum_solicitud CHAR(20), cEnvio_parametrico CHAR(1))

RETURNING CHAR(5) AS cCodRet;

--DECLARACION DE VARIABLES
DEFINE iSqlErr INTEGER;
DEFINE iIsamErr INTEGER;
DEFINE cErrorInfo CHAR(30);
DEFINE cCodRet CHAR(5);

--INICIALIZACION DE VARIABLES
LET iSqlErr = 0;
LET iIsamErr = 0;
LET cErrorInfo = "80";
LET cCodRet = "00000";

BEGIN

	ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
		IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			RETURN TRIM(cCodRet);
		END IF;
	END EXCEPTION;

	 --SET DEBUG FILE TO "/home/sysifx/Aracely/bdisolic/sp_actualiza_respuestacoppel_cteprosp.out";
	 --TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	IF cNum_solicitud IS NULL THEN
		LET cCodRet = "00001";
		RETURN TRIM(cCodRet);
	END IF;
	
	--validar la longitud del numero de solicitud 
	--si es menor que 12 actualizar pr_cliente
	--si es mayor o igual a 12 actualizar ss_solicitudes
	
	IF cEnvio_parametrico = '5' THEN
		LET cEnvio_parametrico = '2';
	END IF;
	
	LET cNum_solicitud = TRIM(cNum_solicitud);
	
	IF LENGTH(cNum_solicitud) < 12 THEN
		
		UPDATE bdiprospectos:"informix".pr_cliente
		SET envio_parametrico = cEnvio_parametrico
		WHERE numcte_pros = cNum_solicitud;
		
		ELSE		
			UPDATE bdisolic:"informix".ss_solicitudes
			SET envio_parametrico = cEnvio_parametrico
			WHERE num_solicitud = cNum_solicitud;	
	END IF;
	
	
	IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '00002';
		END IF;
	
	RETURN TRIM(cCodRet);

END;
END PROCEDURE

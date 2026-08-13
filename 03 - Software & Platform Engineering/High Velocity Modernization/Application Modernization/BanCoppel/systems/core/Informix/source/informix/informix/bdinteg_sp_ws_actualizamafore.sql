CREATE PROCEDURE "informix".sp_ws_actualizamafore(pcCliente CHAR(20))

RETURNING 	CHAR(5) AS cCodRet;

	/*
		SPS USADO PARA LA ACTUALIZACION DE LA INFORMACION DE LA TABLA si_ws_mensajeafore
		AL MOMENTO DE SUCEDA UN ERROR AL MOMENTO DE CONSUMIR WS AFORE
		REGRESANDO EL CAMPO NOTIFICACION A SU ESTADO NATUTAL '0'.
	*/

--DEFINICION DE VARIABLES
DEFINE iSqlErr 		  	INTEGER;
DEFINE cCodRet 		  	CHAR(5);

--INICIALIZACION DE VARIABLES
LET iSqlErr 		= 0;
LET cCodRet 		= '0000';

BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO '/informix/mijail/sp_actualizastatus.out';
	--TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	UPDATE "informix".si_ws_mensajeafore SET notificado = 0 WHERE numcte = pcCliente and fecha_notifica>TODAY;
		
	RETURN cCodret;

END;
END PROCEDURE;
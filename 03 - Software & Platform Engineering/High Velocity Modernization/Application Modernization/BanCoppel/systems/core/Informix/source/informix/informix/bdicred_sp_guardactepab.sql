CREATE PROCEDURE "informix".sp_guardactepab (pRespuesta CHAR(2), pNumCliente CHAR(13), pCanal CHAR(10))

RETURNING CHAR(5);

--Declaracion de Variables.
DEFINE cCodRet CHAR(5);
DEFINE iSqlErr INTEGER;
DEFINE dFecha1 DATE;
DEFINE dFecha2 DATE;
DEFINE dFecha3 DATE;


--Asignacion de Variables.
LET cCodRet = "";
LET iSqlErr = 0;
LET dFecha1 = "";
LET dFecha2 = "";
LET dFecha3 = "";


--SET DEBUG FILE TO "/tmp/sp_guardactepab.out";	
--TRACE ON;													

BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;								
	SET LOCK MODE TO WAIT 3;
	
	SELECT fecha1, fecha2, ultimafecha
	INTO dFecha1, dFecha2, dFecha3
	FROM bdicred:"informix".sd_clientes_preaprobados
	WHERE numcte = pNumCliente;
	
	IF (dFecha1 = "" or dFecha1 is null) THEN
		UPDATE "informix".sd_clientes_preaprobados
		SET fecha1 = today, respuesta1 = pRespuesta, contador = contador + 1
		WHERE numcte = pNumCliente;
		
		IF pRespuesta = "SI" THEN
			UPDATE "informix".sd_clientes_preaprobados
			SET canalcaptacion = pCanal
			WHERE numcte = pNumCliente;		
		END IF;	
		LET cCodRet = '00000';
		
	ELIF 	(dFecha2 = "" or dFecha2 is null) THEN
		UPDATE "informix".sd_clientes_preaprobados
		SET fecha2 = today, respuesta2 = pRespuesta, contador = contador + 1
		WHERE numcte = pNumCliente;
		
		IF pRespuesta = "SI" THEN
			UPDATE "informix".sd_clientes_preaprobados
			SET canalcaptacion = pCanal
			WHERE numcte = pNumCliente;		
		END IF;	
		LET cCodRet = '00000';
		
	ELIF 	(dFecha3 = "" or dFecha3 is null) or (dFecha3 <> "" or dFecha3 is not null) THEN
		UPDATE "informix".sd_clientes_preaprobados
		SET ultimafecha = today, ultimarespuesta = pRespuesta, contador = contador + 1
		WHERE numcte = pNumCliente;
		
		IF pRespuesta = "SI" THEN
			UPDATE "informix".sd_clientes_preaprobados
			SET canalcaptacion = pCanal
			WHERE numcte = pNumCliente;		
		END IF;	
		
		IF pRespuesta = "NO" THEN
			UPDATE "informix".sd_clientes_preaprobados
			SET canalcaptacion = ""
			WHERE numcte = pNumCliente;
		END IF;
		LET cCodRet = '00000';
		
	END IF;

	
RETURN cCodRet;
END
END PROCEDURE
;
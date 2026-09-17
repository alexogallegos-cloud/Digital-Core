CREATE PROCEDURE "informix".sp_registratickethuelladec (
														pNumCte CHAR(20),
														pSecuencia INTEGER,
														pTicket CHAR(50),
														pCodService CHAR(3)
														)												
--DATOS A REGRESAR---
RETURNING             	
CHAR(5) 	AS CodRet;

/*
SCRIPT DE PROCEDIMIENTO ALMACENADO "sp_registratickethuelladec"
Folio.........: 841 - ComparaciÃÂ³n en linea de 10 huellas_V2.0.
Autor.........: 90127902 - Carlos VÃÂ¡zquez Mitre
Fecha.........: 31/01/2022
Solicita......: Juan Francisco Ponce Damian
BD............: bdinteg
-----
Folio.........: RQI 63 1194
Fecha.........: 25/03/2025
Modificacion..: Se integra codigo para integrar los resultados de la comparacion de 
				10 huellas a las tablas de 2.
Autor.........: Juan Francisco Ponce Damian
-----
*/

-- DEFINICION DE VARIABLES.
DEFINE cCodRet				CHAR(5);
DEFINE iSqlErr				INTEGER;
DEFINE cStatus				CHAR(1);
DEFINE cStatusActual        CHAR(1);
DEFINE iMinutos             INTEGER;
DEFINE dFecha			DATETIME YEAR TO SECOND;
DEFINE dInsertFecha     DATETIME YEAR TO SECOND; 

DEFINE cTicket 				CHAR(20);
DEFINE dHora	 			DATETIME HOUR TO SECOND;

 --SET DEBUG FILE TO '/informix/jfponce/gabriel/err/sp_registratickethuelladec.out';
 --TRACE ON;

-- INICIALIZACION DE VARIABLE.
LET cCodRet				= '00000';
LET iSqlErr				= 0;
LET cStatus 			= '1';
LET cStatusActual       = '0';
LET iMinutos            = 15;

LET cTicket            = '';
LET dHora			   = CURRENT HOUR TO SECOND;


BEGIN
	ON EXCEPTION SET iSqlErr
		IF(iSqlErr != 0) THEN
			LET cCodRet = iSqlErr;
			RETURN cCodret;
		END IF;
	END EXCEPTION;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;

	SELECT status_consulta, fecha_insert INTO cStatusActual,dInsertFecha FROM "informix".si_huella_linea_dec WHERE numcte = TRIM(pNumCte) 
	AND secuencia = pSecuencia;	
	
	-- SELECT cStatus INTO iMinutos FROM bdinteg:"informix".si_huella_linea_dec WHERE numcte = TRIM(pNumCte) 
	-- AND secuencia = pSecuencia;
	
	SELECT TO_NUMBER(valor) INTO iMinutos FROM "informix".si_param WHERE cod_param = '507' AND empresa = '001';
	LET dFecha = (CURRENT - iMinutos UNITS MINUTE);

	IF (NVL(pTicket,'') = '') THEN
		IF(cStatusActual = '0' ) THEN 
			LET cStatus='2';
	    ELSE
			IF(dFecha >= dInsertFecha) THEN
				LET cStatus='4';
			ELSE
				LET cStatus='2';
			END IF;
		END IF;	
	END IF;	
	
	UPDATE "informix".si_huella_linea_dec
	SET ticket = pTicket,
		code_service = pCodService,
		status_consulta = cStatus,
		fecha_resp = CURRENT		
	WHERE numcte = TRIM(pNumCte) 
	AND secuencia = pSecuencia;	
	
	--Se agrega codigo para tablas de 2 huellas
	
	INSERT INTO "informix".si_ticket_rel_dec (ticket_dec,numcte) VALUES (pTicket,pNumCte);
	
	SELECT ticket INTO cTicket FROM si_ticket_rel_dec WHERE ticket_dec=pTicket AND numcte=pNumCte;
	
	UPDATE "informix".si_huella_linea
	SET ticket = cTicket,
		respuesta_msj601 = '1',
		status_consulta = '2'		
	WHERE numcte = pNumCte
	AND fecha_consulta = TODAY;	

	INSERT INTO "informix".si_huella_linea_resultado(
	estado_proceso,	resultado, cliente,	ticket,	fecha, hora, empresa, num_mensaje, secuenciacpl)
	VALUES('1','',0,cTicket,TODAY,dHora,'','601','0');
	--fin
	
	RETURN cCodret;

END;
END PROCEDURE;
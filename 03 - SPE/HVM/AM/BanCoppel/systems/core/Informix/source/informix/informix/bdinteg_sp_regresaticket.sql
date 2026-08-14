CREATE PROCEDURE "informix".sp_regresaticket()

--DATOS A REGRESAR---
RETURNING             	
	CHAR(5) 	AS CodRet,
	CHAR(50)	AS ticket;

/*
SCRIPT DE PROCEDIMIENTO ALMACENADO "sp_regresaticket "
Folio.........: 712.1 - EnvÃ­o de decÃ¡logo de huellas.
Autor.........: 90127902 - Carlos VÃ¡zquez Mitre
Fecha.........: 27/01/2021
Solicita......: Juan Francisco Ponce Damian
BD............: bdinteg
VersiÃ³n.......: 20/08/2021

folio:Cambio
Autor.........: Juan Francisco Ponce Damian
Fecha.........: 26/10/2021
Modificacion..: Se limita a 1000 la cantidad maxima de tickets por ejecuciÃ³n y se ordenan de mas antiguas a mas nuevos.
*/

-- DEFINICION DE VARIABLES.
DEFINE cCodRet			CHAR(5);
DEFINE iSqlErr			INTEGER;
DEFINE iContador		INTEGER;
DEFINE cTicket			CHAR(50);
DEFINE cMinutos			INTEGER;
DEFINE dFecha			DATETIME YEAR TO SECOND;

-- SET DEBUG FILE TO '/home/sysifx/sp_regresaticket.out';
-- TRACE ON;

-- INICIALIZACION DE VARIABLE.
LET cCodRet				= '00001';
LET iSqlErr				= 0;
LET iContador			= 0;
LET cTicket				= '';
LET cMinutos			= 0;

BEGIN
	ON EXCEPTION SET iSqlErr
		IF(iSqlErr != 0) THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cTicket;
		END IF;
	END EXCEPTION;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	SELECT TO_NUMBER(valor) INTO cMinutos FROM "informix".si_param WHERE cod_param = '502' AND empresa = '001';
	LET dFecha = (CURRENT - cMinutos UNITS MINUTE);
	
	FOREACH
	    SELECT limit 1000 ticket INTO cTicket 
		FROM "informix".si_rostro_linea 
		WHERE status_consulta = '2'
		AND ticket != ''
		AND fecha_env <= dFecha ORDER BY fecha_env ASC

		LET cCodRet = '00000';
		
		LET iContador = iContador + 1;
		
		RETURN cCodRet, cTicket WITH RESUME;
		
	END FOREACH;
		
	IF (iContador <= 0) THEN
		RETURN cCodRet, cTicket WITH RESUME;
	END IF;
END;
END PROCEDURE;
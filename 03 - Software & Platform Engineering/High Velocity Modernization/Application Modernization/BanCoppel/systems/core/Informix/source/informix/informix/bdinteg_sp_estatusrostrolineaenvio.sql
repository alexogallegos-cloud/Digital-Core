CREATE PROCEDURE "informix".sp_estatusrostrolineaenvio(
											       pNumCte 			CHAR(20),											   
												   pSecuencia 		SMALLINT,
												   pOrigenTicket 	SMALLINT
												   )
--DATOS A REGRESAR---
RETURNING
	CHAR(5)   	AS CodRet;
	
/*
SCRIPT DE PROCEDIMIENTO ALMACENADO "sp_generarostroslinea"
Folio.........: 712.1 - EnvÃ­o de decÃ¡logo de huellas.
Autor.........: 90127902 - Carlos VÃ¡zquez Mitre
Fecha.........: 05/02/2021
Solicita......: Juan Francisco Ponce Damian
BD............: bdinteg
VersiÃ³n.......: 20/08/2021
*/

--DEFINICION DE VARIABLES--
DEFINE iSql_err	  		INTEGER;
DEFINE cCodRet	  		CHAR(5);

--INICIALIZACION DE VARIABLES--
LET iSql_err 	= 0;
LET cCodRet		= '00000';

-- SET DEBUG FILE TO "/home/sysifx/sp_generarostroslinea.out";
-- TRACE ON;

BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;

	SET ISOLATION TO dirty READ;
	SET LOCK MODE TO WAIT 3;
	
	UPDATE "informix".si_rostro_linea 
	SET
	origen_ticket = pOrigenTicket,
	fecha_env = CURRENT
	WHERE secuencia = pSecuencia AND numcte = pNumCte;
	
	RETURN cCodRet;
END;
END PROCEDURE;
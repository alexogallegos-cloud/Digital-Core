CREATE PROCEDURE "informix".sp_estatusrostroslinea(
											       pNumCte 			CHAR(20),
												   pTicket			CHAR(50),												   
												   pSecuencia 		SMALLINT,
												   pStatusConsulta	CHAR(1),
												   pCodeService 	CHAR(3), 
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
*/

--DEFINICION DE VARIABLES--
DEFINE iSql_err	  		INTEGER;
DEFINE cCodRet	  		CHAR(5);

--INICIALIZACION DE VARIABLES--
LET iSql_err 	= 0;
LET cCodRet		= '00000';

--SET DEBUG FILE TO "/home/sysifx/sp_generarostroslinea.out";
--TRACE ON;

BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;

	SET ISOLATION TO dirty READ;
	SET LOCK MODE TO WAIT 3;
	
	UPDATE si_rostro_linea 
	SET 
	status_consulta = pStatusConsulta,
	ticket = pTicket,
	code_service = pCodeService,
	origen_ticket = pOrigenTicket
	WHERE secuencia = pSecuencia AND numcte = pNumCte;
	
	RETURN cCodRet;
END;
END PROCEDURE;
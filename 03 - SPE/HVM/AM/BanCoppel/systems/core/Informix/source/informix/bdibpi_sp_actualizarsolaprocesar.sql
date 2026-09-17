CREATE PROCEDURE "informix".sp_actualizarsolaprocesar(pSolicitud varchar(10),pNumcte varchar(9),pErrorDesc varchar(200),pToken varchar(10))
RETURNING CHAR(5);
--------------------------------------------------------------------------------------------
-- Realizó: Francisco Rodríguez Ibarra
-- Actividad: Actualizá registro de la solicitud, en caso que existá un error en el token manager
-- Solicitó: Mauricio León
-- Fecha de Solicitud: 14/01/2011
---------------------------------------------------------------------------------------------
-- Realizó: Walber Castro
-- Actividad: Hace rollback a las solicitudes que quedaron atendidas después de que el token manager marcó error.
-- Solicitó: Mauricio León
-- Fecha de Solicitud: 27/09/2011
---------------------------------------------------------------------------------------------	
	
--Definición de variables
DEFINE sql_err      INT;
DEFINE vCodRet      CHAR(5);

SET LOCK MODE TO WAIT 10;
--Inicializar valores a variables declaradas
LET vCodRet = '00000';
BEGIN

	ON EXCEPTION SET sql_err
		IF sql_err <> 0 THEN
	            let vCodRet = sql_err;
	            RETURN vCodRet;                       
		END IF ;
	END EXCEPTION ;

	UPDATE bdibpi:"informix".tkn_solprocesadas SET estatus_sol='1',error_desc=pErrorDesc
	WHERE solicitud=TRIM(pSolicitud)
	AND cliente=TRIM(pNumcte);
	/*
	UPDATE bdibpi:"informix".bpi_tokensolicitud SET id_status='100', f_atencion = DATE('01/01/1900'), usr_atiende = null, ns_token = null
	WHERE solicitud=TRIM(pSolicitud)
	AND numcte=TRIM(pNumcte);
	
	UPDATE bdibpi:"informix".tkn_nseries SET id_status='105' WHERE ns_token = TRIM(pToken);
*/
	RETURN vCodRet; 
END;
END PROCEDURE;
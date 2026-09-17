CREATE PROCEDURE "informix".sp_consulta_carrier_web ()

	RETURNING  CHAR(5) AS codRetorno, CHAR(4) AS idCarrier, CHAR(40) AS nombreCarrier;
 
--definicion de variables--               
DEFINE resultado_idCarrier           CHAR(4);
DEFINE resultado_nombreCarrier       CHAR(40);
DEFINE resultado_codRetorno          CHAR(5);
DEFINE iSqlErr                       INTEGER;

-- Inicializacion de las variables.
LET resultado_idCarrier = '';
LET resultado_nombreCarrier = '';
LET resultado_codRetorno = '00000';

SET ISOLATION DIRTY READ;
SET LOCK MODE TO WAIT 3;

BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET resultado_idCarrier = '';
			LET resultado_nombreCarrier = '';
			LET resultado_codRetorno = '00001';
			RETURN resultado_codRetorno,resultado_idCarrier, resultado_nombreCarrier;
		END IF;
	END EXCEPTION;
	
	FOREACH
		SELECT cve_carrier, nombre_carrier
		INTO resultado_idCarrier, resultado_nombreCarrier
		FROM bdinteg:si_carriers
		ORDER BY cve_carrier, nombre_carrier
		RETURN resultado_codRetorno, resultado_idCarrier, resultado_nombreCarrier WITH resume;
	END FOREACH;
END
END PROCEDURE;
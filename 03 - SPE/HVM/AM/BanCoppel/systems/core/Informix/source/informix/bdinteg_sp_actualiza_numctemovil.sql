CREATE PROCEDURE "informix".sp_actualiza_numctemovil()
				returning CHAR(5) AS Cod_Retorno,INTEGER as Idreg;


DEFINE iexiste 			INT;
DEFINE cCodRet 			CHAR(5);
DEFINE iSql_err 		INT;
DEFINE sRetCod          CHAR(5);
DEFINE IidErr			INTEGER;
DEFINE cRFC     		CHAR(13);
DEFINE cNumcte          CHAR(20);
DEFINE iID				INT8;

LET cRFC        		= '';
LET cNumcte				= '';
LET iexiste				=0;
LET iSql_err				   =0;
LET sRetCod          	="99999";
LET cCodRet 			= "00000";
LET IidErr				=0;
LET iID					=0;

BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN cCodRet,IidErr;
		END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO "/informix/VH/PM/sp_actualiza_numctemovil.out";
	--TRACE ON;
		

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	FOREACH
		SELECT id,ap_rfc INTO iID,cRFC FROM si_solicitud_movil WHERE status_valua IS NOT NULL AND (numcte IS NULL OR numcte='') AND ap_rfc IS NOT NULL AND fecha_insert>='01/01/2016'
		
			SELECT LIMIT 1 numcte INTO cNumcte FROM si_cliente WHERE rfc = TRIM(cRFC);
			UPDATE si_solicitud_movil set numcte = cNumcte wHERE id = iID;

	END FOREACH;

	RETURN cCodRet,IidErr;
END
END PROCEDURE;
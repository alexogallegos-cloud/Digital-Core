CREATE PROCEDURE "informix".sp_actualizapuntajesol()
RETURNING CHAR(6)  AS COD_RET;

--DECLARACIÓN DE VARIABLES
DEFINE iSqlErr         		INTEGER;
DEFINE iIsamErr        		INTEGER;
DEFINE iCantReg        		INTEGER;
DEFINE cErrorInfo      		CHAR(80);
DEFINE cCodRet         		CHAR(6);
DEFINE cMensajeRet          CHAR(80);
DEFINE cCodRet2			CHAR(6);

DEFINE vnumcte, vnumsolcred CHAR(20);
DEFINE vparaltoriesgo SMALLINT;


--INICIALIZACIÓN DE VARIABLES
LET iSqlErr            	= 0;
LET iIsamErr           	= 0;
LET iCantReg           	= 0;
LET cErrorInfo         	= "";
LET cCodRet            	= "000000";
LET cCodRet2		= "000000";
LET cMensajeRet         = "REGISTRO DE INFORMACION REALIZADO EXITOSAMENTE";

BEGIN

	ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
	   IF iSqlErr != 0 THEN
		  LET cCodRet = iSqlErr;
		  LET cMensajeRet = cErrorInfo;
		  RETURN TRIM(cCodRet);
	   END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO "/pisa/pisabanco/actualizapuntajesol.out";
	--TRACE ON;

	SET ISOLATION TO DIRTY READ;

    FOREACH WITH HOLD

        SELECT num_solicitud,par_altoriesgo
        INTO vnumsolcred, vparaltoriesgo
        FROM bdisolic:"informix".ss_puntaje_solicitudes

        IF SUBSTR(vnumsolcred,1,2)= '65' THEN
            IF EXISTS(SELECT num_solicitud from bdisolic:ss_nuevo_parametrico WHERE num_solicitud = vnumsolcred) THEN
                BEGIN;
                    UPDATE bdisolic:ss_nuevo_parametrico 
                    SET par_altoriesgo = vparaltoriesgo
                    WHERE num_solicitud = vnumsolcred;
                COMMIT;
            END IF
        END IF 

    END FOREACH;

	RETURN cCodRet;
END;
END PROCEDURE

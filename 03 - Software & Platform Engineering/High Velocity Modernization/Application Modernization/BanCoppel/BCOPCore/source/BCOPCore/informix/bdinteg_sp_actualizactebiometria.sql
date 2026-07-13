CREATE PROCEDURE "informix".sp_actualizactebiometria(pTipo CHAR(1), pNumCte CHAR(20))
    RETURNING CHAR(5) AS CodRet;

    --Definicion de Variables
    DEFINE iSqlErr INTEGER;
    DEFINE cCodRet CHAR(5);

    --Inicializacion de Variables
    LET iSqlErr = 0;
    LET cCodRet = '000';

    --SET DEBUG FILE TO '/informix/IrisA/sp_actualizactebiometria.out';
    --TRACE ON;

    BEGIN
        ON EXCEPTION SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;
                RETURN cCodRet;
            END IF;
        END EXCEPTION;

        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;

		IF pTipo = '1' THEN
			UPDATE "informix".si_cliente SET tpo_biometria = '2' WHERE numcte = pNumCte;
		ELSE
			LET cCodRet = '001'; -- No Existe el Tipo de Consulta
		END IF;

        RETURN cCodRet;
    END;
END PROCEDURE;
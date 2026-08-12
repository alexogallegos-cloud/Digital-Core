CREATE PROCEDURE "informix".speliminadescquincena()
RETURNING	CHAR(5)     AS CodigoRetorno;

define sCodRet     char(5);
DEFINE iSqlErr							INTEGER;

BEGIN
            ON EXCEPTION
                SET iSqlErr
                IF iSqlErr <> 0 THEN
                    LET sCodRet = iSqlErr;
                    INSERT INTO bdirech:rec_errores(descripcion) VALUES ('sedq'|| iSqlErr);
                    RETURN sCodRet;
                END IF;
            END EXCEPTION;        
          
        IF (select count(*) from bdirech:rec_descquincena)>0 THEN
            DELETE FROM bdirech:rec_descquincena;
        END IF

                let sCodRet='00000';
                RETURN sCodRet;
END
END PROCEDURE;
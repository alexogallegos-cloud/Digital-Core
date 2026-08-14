CREATE PROCEDURE "informix".speliminaerrores()
RETURNING	CHAR(5)     AS CodigoRetorno;

define sCodRet     char(5);
DEFINE iSqlErr							INTEGER;

   SET ISOLATION TO DIRTY READ;
   SET LOCK MODE TO WAIT 3;

BEGIN
            ON EXCEPTION
                SET iSqlErr
                IF iSqlErr <> 0 THEN
                    LET sCodRet = iSqlErr;
                    INSERT INTO bdirech:rec_errores(descripcion) VALUES ('scfvsc'|| iSqlErr);
                    RETURN sCodRet;
                END IF;
            END EXCEPTION;        
            
            DELETE FROM bdirech:rec_errores;

                let sCodRet='00000';
                RETURN sCodRet;
END
END PROCEDURE;
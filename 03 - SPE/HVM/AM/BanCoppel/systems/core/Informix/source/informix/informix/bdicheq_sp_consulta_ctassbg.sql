CREATE PROCEDURE "informix".sp_consulta_ctassbg( pEmpresa CHAR(3) ) 
RETURNING CHAR(5), CHAR(20);
    
    DEFINE cCodRet      CHAR(5);
    DEFINE cIsamErr     CHAR(5);
    DEFINE cDescErr     CHAR(50);
    DEFINE iSqlErr      INTEGER;
    DEFINE iSamErr      INTEGER;
    DEFINE cDesErr      CHAR(50);
    DEFINE iExiste      SMALLINT;
    DEFINE cCredito     CHAR(20);
    
    LET cCodRet     = '000';
    LET cIsamErr    = '';
    LET cDescErr    = '';
    LET iSqlErr	    = 0;
    LET iSamErr     = 0;
    LET cDesErr     = '';
    LET iExiste     = 0;
    LET cCredito    = '';
	
	BEGIN
    
    ON EXCEPTION SET iSqlErr, iSamErr, cDesErr
        SET DEBUG FILE TO "/tmp/sp_consulta_ctassbg.err";
        TRACE ON;
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
            LET cIsamErr = iSamErr;
            LET cDescErr = cDesErr;
            RETURN cCodRet, cCredito;
        END IF;
    END EXCEPTION;  
    
    --- SET DEBUG FILE TO "/tmp/sp_consulta_ctassbg.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF ( pEmpresa is null OR pEmpresa = '' OR pEmpresa <> '001' ) THEN
        LET cCodRet = '110';
        RETURN cCodRet, cCredito;
    END IF;
    
    SELECT COUNT(*)
      INTO iExiste
      FROM sc_limite_sbg;
     
    IF iExiste = 0 THEN
        LET cCodRet = '100';
        RETURN cCodRet, cCredito;
    ELSE
        FOREACH
            SELECT num_credito
              INTO cCredito
              FROM sc_limite_sbg
            
            RETURN cCodRet, cCredito WITH RESUME;
             
            LET cCredito = '';
        END FOREACH;
    END IF;
    
    END;
    
END PROCEDURE;
CREATE PROCEDURE "informix".sp_consulta_ctasconsbg( pEmpresa CHAR(3) ) 
RETURNING CHAR(5), CHAR(20), MONEY(18,2);
    
    DEFINE cCodRet      CHAR(5);
    DEFINE cIsamErr     CHAR(5);
    DEFINE cDescErr     CHAR(50);
    DEFINE iSqlErr      INTEGER;
    DEFINE iSamErr      INTEGER;
    DEFINE cDesErr      CHAR(50);
    DEFINE iExiste      SMALLINT;
    DEFINE cCredito     CHAR(20);
    DEFINE mSdoAcumSbg  MONEY(18,2);
    
    LET cCodRet     = '000';
    LET cIsamErr    = '';
    LET cDescErr    = '';
    LET iSqlErr	    = 0;
    LET iSamErr     = 0;
    LET cDesErr     = '';
    LET iExiste     = 0;
    LET cCredito    = '';
    LET mSdoAcumSbg = 0.00;
	
	BEGIN
    
    ON EXCEPTION SET iSqlErr, iSamErr, cDesErr
        SET DEBUG FILE TO "/tmp/sp_consulta_ctasconsbg.err";
        TRACE ON;
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
            LET cIsamErr = iSamErr;
            LET cDescErr = cDesErr;
            RETURN cCodRet, cCredito, mSdoAcumSbg;
        END IF;
    END EXCEPTION;  
    
    --- SET DEBUG FILE TO "/tmp/sp_consulta_ctasconsbg.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF ( pEmpresa is null OR pEmpresa = '' OR pEmpresa <> '001' ) THEN
        LET cCodRet = '110';
        RETURN cCodRet, cCredito, mSdoAcumSbg;
    END IF;
    
    SELECT COUNT(*)
      INTO iExiste
      FROM sc_limite_sbg
     WHERE imp_acum_sbg > 0.00;
     
    IF iExiste = 0 THEN
        LET cCodRet = '100';
        RETURN cCodRet, cCredito, mSdoAcumSbg;
    ELSE
        FOREACH
            SELECT num_credito, imp_acum_sbg
              INTO cCredito, mSdoAcumSbg
              FROM sc_limite_sbg
             WHERE imp_acum_sbg > 0.00
            
            RETURN cCodRet, cCredito, mSdoAcumSbg WITH RESUME;
             
            LET cCredito = '';
            LET mSdoAcumSbg = 0.00;
        END FOREACH;
    END IF;
    
    END;
    
END PROCEDURE;
CREATE PROCEDURE "informix".sp_valida_limite_sbg( pCuenta CHAR(20), pLimiteSbg MONEY(18,2) ) 
RETURNING CHAR(5), MONEY(18,2);
    
    DEFINE cCodRet  CHAR(5);
    DEFINE cIsamErr CHAR(5);
    DEFINE cDescErr CHAR(50);
    DEFINE iSqlErr  INTEGER;
    DEFINE iSamErr  INTEGER;
    DEFINE cDesErr  CHAR(50);
    DEFINE iExiste  SMALLINT;
    DEFINE mAcumSbg MONEY(18,2);
    DEFINE mLimSbg  MONEY(18,2);
    
    LET cCodRet  = '';
    LET cIsamErr = '';
    LET cDescErr = '';
    LET iSqlErr	 = 0;
    LET iSamErr  = 0;
    LET cDesErr  = '';
    LET iExiste  = 0;
    LET mAcumSbg = 0.00;
    LET mLimSbg  = 0.00;
	
	BEGIN
    
    ON EXCEPTION SET iSqlErr, iSamErr, cDesErr
        SET DEBUG FILE TO "/tmp/sp_valida_limite_sbg.err";
        TRACE ON;
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
            LET cIsamErr = iSamErr;
            LET cDescErr = cDesErr;
            RETURN cCodRet, mLimSbg;
        END IF;
    END EXCEPTION;  
    
    --- SET DEBUG FILE TO "/tmp/sp_valida_limite_sbg.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF ( pCuenta is null OR pCuenta = '' ) OR ( pLimiteSbg is null OR pLimiteSbg <= 0.00 ) THEN
        LET cCodRet = '00110';
        RETURN cCodRet, mLimSbg;
    END IF;
    
    SELECT COUNT(*)
      INTO iExiste
      FROM sc_limite_sbg
     WHERE cuenta = pCuenta;
     
    IF ( iExiste > 0 ) THEN
        SELECT imp_acum_sbg, limite_sbg
          INTO mAcumSbg, mLimSbg
          FROM sc_limite_sbg
         WHERE cuenta = pCuenta;
        
        IF pLimiteSbg >= mAcumSbg THEN
            LET mLimSbg = pLimiteSbg;
            LET cCodRet = '00000';
        ELSE
            LET mLimSbg = mAcumSbg;
            LET cCodRet = '00124';
            RETURN cCodRet, mLimSbg;
        END IF;
    ELSE
        LET mLimSbg = 0.00;
        LET cCodRet = '00100';
        RETURN cCodRet, mLimSbg;
    END IF;
    
    RETURN cCodRet, mLimSbg;
     
    END;
    
END PROCEDURE;
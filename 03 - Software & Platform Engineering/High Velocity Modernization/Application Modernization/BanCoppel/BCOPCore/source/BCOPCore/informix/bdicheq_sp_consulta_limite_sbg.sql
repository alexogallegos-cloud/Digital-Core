CREATE PROCEDURE "informix".sp_consulta_limite_sbg( pCuenta CHAR(20) ) 
RETURNING CHAR(5), CHAR(20), MONEY(18,2), MONEY(18,2), MONEY(18,2);
    
    DEFINE cCodRet      CHAR(5);
    DEFINE cIsamErr     CHAR(5);
    DEFINE cDescErr     CHAR(50);
    DEFINE iSqlErr      INTEGER;
    DEFINE iSamErr      INTEGER;
    DEFINE cDesErr      CHAR(50);
    DEFINE iExiste      SMALLINT;
    DEFINE cCuenta      CHAR(20);
    DEFINE mLimiteSbg   MONEY(18,2);
    DEFINE mSdoAcumSbg  MONEY(18,2);
    DEFINE mSdoDispSbg  MONEY(18,2);
    
    LET cCodRet     = '000';
    LET cIsamErr    = '';
    LET cDescErr    = '';
    LET iSqlErr	    = 0;
    LET iSamErr     = 0;
    LET cDesErr     = '';
    LET iExiste     = 0;
    LET cCuenta     = '';
    LET mLimiteSbg  = 0.00;
    LET mSdoAcumSbg = 0.00;
    LET mSdoDispSbg = 0.00;
	
	BEGIN
    
    ON EXCEPTION SET iSqlErr, iSamErr, cDesErr
        SET DEBUG FILE TO "/tmp/sp_consulta_limite_sbg.err";
        TRACE ON;
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
            LET cIsamErr = iSamErr;
            LET cDescErr = cDesErr;
            RETURN cCodRet, cCuenta, mLimiteSbg, mSdoAcumSbg, mSdoDispSbg;
        END IF;
    END EXCEPTION;  
    
    --- SET DEBUG FILE TO "/tmp/sp_consulta_limite_sbg.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 2;
    
    IF ( pCuenta is null OR pCuenta = '' ) THEN
        LET cCodRet = '110';
        RETURN cCodRet, cCuenta, mLimiteSbg, mSdoAcumSbg, mSdoDispSbg;
    END IF;
    
    SELECT COUNT(*)
      INTO iExiste
      FROM sc_limite_sbg
     WHERE cuenta = pCuenta;
     
    IF ( iExiste = 0 ) THEN
        LET cCodRet = '100';
        RETURN cCodRet, cCuenta, mLimiteSbg, mSdoAcumSbg, mSdoDispSbg;
    END IF;
    
    SELECT cuenta, limite_sbg, imp_acum_sbg
      INTO cCuenta, mLimiteSbg, mSdoAcumSbg
      FROM sc_limite_sbg
     WHERE cuenta = pCuenta;
     
    LET mSdoDispSbg = mLimiteSbg - mSdoAcumSbg;
    
    END;
    
    RETURN cCodRet, cCuenta, mLimiteSbg, mSdoAcumSbg, mSdoDispSbg;
    
END PROCEDURE;
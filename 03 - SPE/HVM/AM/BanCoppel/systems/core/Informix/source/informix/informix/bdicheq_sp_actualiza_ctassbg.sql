CREATE PROCEDURE "informix".sp_actualiza_ctassbg( pNumCredito CHAR(20), pTramaResp CHAR(500) ) 
RETURNING CHAR(5);
    
    DEFINE cCodRet  CHAR(5);
    DEFINE cIsamErr CHAR(5);
    DEFINE cDescErr CHAR(50);
    DEFINE iSqlErr  INTEGER;
    DEFINE iSamErr  INTEGER;
    DEFINE cDesErr  CHAR(50);
    DEFINE iExiste  SMALLINT;
    DEFINE cCodResp CHAR(5);
    DEFINE mSdoDisp DECIMAL(15,2);
    
    LET cCodRet  = '000';
    LET cIsamErr = '';
    LET cDescErr = '';
    LET iSqlErr	 = 0;
    LET iSamErr  = 0;
    LET cDesErr  = '';
    LET iExiste  = 0;
    LET cCodResp = '';
    LET mSdoDisp = 0.00;
	
	BEGIN
    
    ON EXCEPTION SET iSqlErr, iSamErr, cDesErr
        SET DEBUG FILE TO "/tmp/sp_actualiza_ctassbg.err";
        TRACE ON;
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
            LET cIsamErr = iSamErr;
            LET cDescErr = cDesErr;
            RETURN cCodRet;
        END IF;
    END EXCEPTION;  
    
    --- SET DEBUG FILE TO "/tmp/sp_actualiza_ctassbg.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF ( pNumCredito is null OR pNumCredito = '' ) OR
       ( pTramaResp is null OR pTramaResp = '' ) THEN
        LET cCodRet = '110';
        RETURN cCodRet;
    END IF;
    
    SELECT COUNT(*)
      INTO iExiste
      FROM sc_limite_sbg
     WHERE num_credito = pNumCredito;
     
    IF iExiste = 0 THEN
        LET cCodRet = '100';
        RETURN cCodRet;
    ELSE
        LET cCodResp = SUBSTR(pTramaResp, 1, 5);
    
        IF cCodResp = '00000' THEN
            LET mSdoDisp = SUBSTR(pTramaResp, 123, 15);
            
            UPDATE sc_limite_sbg
               SET limite_sbg = mSdoDisp
             WHERE num_credito = pNumCredito;
        END IF;
        
        INSERT INTO sc_limite_sbg_resp
        ( fecha_hora, num_credito, trama_resp )
        VALUES
        ( current, pNumCredito, pTramaResp );
    END IF;
    
    END;
    
    RETURN cCodRet;
    
END PROCEDURE;
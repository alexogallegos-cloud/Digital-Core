CREATE PROCEDURE "informix".sp_transfer_online_actualiza( pSerial       INTEGER, 
                                                          pCuenta       CHAR(20),
                                                          pFolioSuc     CHAR(16), 
                                                          pIdTransacc   CHAR(5), 
                                                          pCodRet       CHAR(20),
                                                          pTramaRes     CHAR(600) )
RETURNING CHAR(5);
          
    DEFINE cCodRet      CHAR(5);
    DEFINE cCodRet2     CHAR(5);
    DEFINE cCodRet3     CHAR(5);
    DEFINE iSqlErr      INTEGER;
    DEFINE iSamErr      INTEGER;
    DEFINE cDesErr      CHAR(50);
    DEFINE cStatus      CHAR(1);
    DEFINE vCodRet      INTEGER;
    
    LET cCodRet  = '';
    LET cCodRet2 = '';
    LET cCodRet3 = '';
    LET iSqlErr  = 0;
    LET iSamErr  = 0;
    LET cDesErr  = 0;
    LET cStatus  = '';
    LET vCodRet  = 0;
    
    BEGIN
    
    ON EXCEPTION SET iSqlErr, iSamErr, cDesErr
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_transfer_online_actualiza.err";
        TRACE ON;
        IF iSqlErr <> 0 THEN
            LET cCodRet  = iSqlErr;
            LET cCodRet2 = iSamErr;
            LET cCodRet3 = cDesErr;
            RETURN cCodRet;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_transfer_online_actualiza.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF ( pSerial is null OR pSerial = 0 ) OR
       ( pCuenta is null OR pCuenta = '' ) OR
       ( pFolioSuc is null OR pFolioSuc = '' ) OR
       ( pIdTransacc is null OR pIdTransacc = '' ) OR
       ( pCodRet is null OR pCodRet = '' ) THEN
        LET cCodRet = '110';
        RETURN cCodRet;
    END IF;
    
    LET vCodRet = pCodRet::INTEGER;
    
    IF vCodRet = 0 THEN
        LET cStatus = 'F';
    ELSE
        LET cStatus = 'X';
    END IF;
    
    UPDATE {+INDEX(sc_transfer_online idx_transferonline_serctafoltra)} 
           sc_transfer_online
       SET cod_ret = vCodRet,
           status = cStatus,
           trama_res = pTramaRes
     WHERE no_serial = pSerial
       AND cuenta = pCuenta
       AND folio_suc = pFolioSuc
       AND id_transacc = pIdTransacc;
    
    IF dbinfo('sqlca.sqlerrd2') > 0  THEN
        LET cCodRet = '000';
    ELSE
        LET cCodRet = '999';
    END IF;
    
    END;
    
    RETURN cCodRet; 
    
END PROCEDURE;
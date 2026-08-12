CREATE PROCEDURE "informix".sp_transfer_online_consulta( )
RETURNING CHAR(5),
          INTEGER,
          CHAR(20),
          CHAR(16),
          CHAR(5),
          CHAR(600);
          
    DEFINE cCodRet      CHAR(5);
    DEFINE cCodRet2     CHAR(5);
    DEFINE cCodRet3     CHAR(5);
    DEFINE iSqlErr      INTEGER;
    DEFINE iSamErr      INTEGER;
    DEFINE cDesErr      CHAR(50);
    
    DEFINE iSerial      INTEGER;
    DEFINE cCuenta      CHAR(20);
    DEFINE cFolioSuc    CHAR(16);
    DEFINE cIdTransacc  CHAR(5);
    DEFINE cTrama       CHAR(600);
    
    LET cCodRet  = '';
    LET cCodRet2 = '';
    LET cCodRet3 = '';
    LET iSqlErr  = 0;
    LET iSamErr  = 0;
    LET cDesErr  = 0;
    
    LET iSerial     = 0;
    LET cCuenta     = '';
    LET cFolioSuc   = '';
    LET cIdTransacc = '';
    LET cTrama      = '';
    
    BEGIN
    
    ON EXCEPTION SET iSqlErr, iSamErr, cDesErr
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_transfer_online_consulta.err";
        TRACE ON;
        IF iSqlErr <> 0 THEN
            LET cCodRet  = iSqlErr;
            LET cCodRet2 = iSamErr;
            LET cCodRet3 = cDesErr;
            RETURN cCodRet, iSerial, cCuenta, cFolioSuc, cIdTransacc, cTrama;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_transfer_online_consulta.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
        
    SELECT {+INDEX(sc_transfer_online idx_transferonline_status)}
           FIRST 1 no_serial, cuenta, folio_suc, id_transacc, trama
      INTO iSerial, cCuenta, cFolioSuc, cIdTransacc, cTrama
      FROM sc_transfer_online
     WHERE status = 'N';
     
    IF ( dbinfo('sqlca.sqlerrd2') > 0 ) THEN
        UPDATE {+INDEX(sc_transfer_online idx_transferonline_serctafoltra)} 
               sc_transfer_online
           SET status = 'E'
         WHERE no_serial = iSerial
           AND cuenta = cCuenta
           AND folio_suc = cFolioSuc
           AND id_transacc = cIdTransacc;
           
        IF ( dbinfo('sqlca.sqlerrd2') > 0 ) THEN
            LET cCodRet     = '000';
            LET iSerial     = iSerial;
            LET cCuenta     = cCuenta;
            LET cFolioSuc   = cFolioSuc;
            LET cIdTransacc = cIdTransacc;
            LET cTrama      = cTrama;
        ELSE
            LET cCodRet     = '999';
            LET iSerial     = 0;
            LET cCuenta     = '';
            LET cFolioSuc   = '';
            LET cIdTransacc = '';
            LET cTrama      = '';
        END IF;
    ELSE
        LET cCodRet     = '568';
        LET iSerial     = 0;
        LET cCuenta     = '';
        LET cFolioSuc   = '';
        LET cIdTransacc = '';
        LET cTrama      = '';
    END IF;
     
    RETURN cCodRet, iSerial, cCuenta, cFolioSuc, cIdTransacc, cTrama; 
     
    END;
    
END PROCEDURE;
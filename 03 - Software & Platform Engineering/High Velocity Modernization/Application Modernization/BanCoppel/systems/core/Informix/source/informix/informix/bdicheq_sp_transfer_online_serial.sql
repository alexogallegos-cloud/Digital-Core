CREATE PROCEDURE "informix".sp_transfer_online_serial( pCuenta     CHAR(20),
                                                       pFolioSuc   CHAR(16),
                                                       pIdTransacc CHAR(5) ) 
RETURNING CHAR(5), INTEGER; 
    
    DEFINE vCodRet1     CHAR(5);
    DEFINE vCodRet2     CHAR(5);
    DEFINE vCodRet3     CHAR(50);
    DEFINE vSqlErr      INTEGER; 
    DEFINE vIsamErr     INTEGER;
    DEFINE vDescErr     CHAR(50);
    DEFINE iSerial      INTEGER;
    
    LET vCodRet1 = '';
    LET vCodRet2 = '';
    LET vCodRet3 = '';
    LET vSqlErr  = 0;
    LET vIsamErr = 0;
    LET vDescErr = '';
    LET iSerial  = 0;
    
    --- SET DEBUG FILE TO "/ids10_2uc5/jivan/spei/sp_transfer_online_serial.out";
    --- TRACE ON;
    
    BEGIN  
    
    ON EXCEPTION SET vSqlErr, vIsamErr, vDescErr
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_transfer_online_serial.err";
        TRACE ON;
        IF vSqlErr != 0 THEN
            LET vCodRet1 = vSqlErr;
            LET vCodRet2 = vIsamErr;
            RETURN vCodRet1, iSerial; 
        END IF;
    END EXCEPTION;   
    
    SET ISOLATION TO DIRTY READ; 
    SET LOCK MODE TO WAIT 3; 
    
    SELECT MAX(no_serial)
      INTO iSerial
      FROM sc_transfer_serial;
      
    IF iSerial is null THEN
        LET iSerial = 0;
    END IF;
    
    LET iSerial = iSerial + 1;
    
    INSERT INTO sc_transfer_serial
    ( no_serial, cuenta, folio_suc, id_transacc )
    VALUES
    ( iSerial, pCuenta, pFolioSuc, pIdTransacc );
    
    IF dbinfo('sqlca.sqlerrd2') > 0  THEN
        LET iSerial  = iSerial;
        LET vCodRet1 = '000';
    ELSE
        LET iSerial  = 0;
        LET vCodRet1 = '999';
    END IF;
    
    END;
    
    RETURN vCodRet1, iSerial;
    
END PROCEDURE;
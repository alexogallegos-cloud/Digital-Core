CREATE PROCEDURE "informix".sp_consdoctatransfersoc( pCuenta CHAR(20) )
RETURNING CHAR(5), CHAR(5), INTEGER, CHAR(16);
    
    DEFINE cCodRet1     CHAR(5);
    DEFINE cCodRet2     CHAR(5);
    DEFINE cCodRet3     CHAR(50);
    DEFINE iSqlErr      INTEGER;
    DEFINE iSamErr      INTEGER;
    DEFINE cDesErr      CHAR(50);
    DEFINE cHora        CHAR(15);
    DEFINE cFolioSuc    CHAR(16);
    DEFINE cTransaccTrf CHAR(5);
    DEFINE cUsuario     CHAR(8);
    DEFINE mMonto       DECIMAL(14,2);
    DEFINE cCodRetTrf   CHAR(5);
    DEFINE iSerial      INTEGER;
    DEFINE iVueltas     SMALLINT;
    DEFINE cStatus      CHAR(1);
    DEFINE cSQL         CHAR(10);
    
    LET cCodRet1     = '000';
    LET cCodRet2     = '';
    LET cCodRet3     = '';
    LET iSqlErr	     = 0;
    LET iSamErr      = 0;
    LET cDesErr      = '';
    LET cHora        = '';
    LET cFolioSuc    = '';
    LET cTransaccTrf = '';
    LET cUsuario     = 'informix';
    LET mMonto       = 0.00;
    LET cCodRetTrf   = '';
    LET iSerial      = 0;
    LET iVueltas     = 0;
    LET cStatus      = '';
    LET cSQL         = '';
	
	BEGIN
    
    ON EXCEPTION SET iSqlErr, iSamErr, cDesErr
        SET DEBUG FILE TO "/tmp/sp_consdoctatransfersoc.err";
        TRACE ON;
        IF iSqlErr <> 0 THEN
            LET cCodRet1 = iSqlErr;
            LET cCodRet2 = iSamErr;
            LET cCodRet3 = cDesErr;
            RETURN cCodRet1, cTransaccTrf, iSerial, cFolioSuc;
        END IF;
    END EXCEPTION;  
    
    --- SET DEBUG FILE TO "/tmp/sp_consdoctatransfersoc.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    LET cHora = CURRENT HOUR TO FRACTION;
    LET cFolioSuc = cUsuario||cHora[1,2]||cHora[4,5]||cHora[7,8]||cHora[10,11];
    
    SELECT valor
      INTO cTransaccTrf
      FROM bdicheq:sc_param
     WHERE empresa = '001'
       AND codparam = 'TranConSdoTransfer';  
       
    CALL bdicheq:sp_transfer_online_consdo( cTransaccTrf, pCuenta, cFolioSuc, cUsuario, mMonto )
    RETURNING cCodRetTrf, iSerial;
    
    LET cStatus = 'N';
    LET iVueltas = 0;
    
    WHILE cStatus IN('N','E') 
        SET ISOLATION TO DIRTY READ;
        
        SELECT status
          INTO cStatus
          FROM bdicheq:sc_transfer_online
         WHERE no_serial = iSerial
           AND cuenta = pCuenta
           AND folio_suc = cFolioSuc
           AND id_transacc = cTransaccTrf;
           
        IF cStatus IN('F','X') THEN
            EXIT WHILE;
        ELSE
            LET cSQL = 'sleep 6'; 
            SYSTEM cSQL; 
            LET iVueltas = iVueltas + 1; 
            IF iVueltas > 5 THEN 
                EXIT WHILE; 
            END IF; 
        END IF;
    END WHILE;
    
    IF ( cStatus is null OR cStatus = '' OR cStatus IN('N','E') ) THEN
        UPDATE bdicheq:sc_transfer_online
           SET status = 'T'
         WHERE no_serial = iSerial
           AND cuenta = pCuenta
           AND folio_suc = cFolioSuc
           AND id_transacc = cTransaccTrf;
    END IF;
    
    RETURN cCodRet1, cTransaccTrf, iSerial, cFolioSuc;
    
    END;
    
END PROCEDURE;
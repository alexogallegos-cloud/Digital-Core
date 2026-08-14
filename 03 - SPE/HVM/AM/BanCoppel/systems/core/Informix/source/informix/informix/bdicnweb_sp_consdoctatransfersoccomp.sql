CREATE PROCEDURE "informix".sp_consdoctatransfersoccomp( pCuenta CHAR(20), pTransaccTrf CHAR(5), pSerial INTEGER, pFolioSuc CHAR(16) )
RETURNING CHAR(5), DECIMAL(14,2);
    
    DEFINE cCodRet1     CHAR(5);
    DEFINE cCodRet2     CHAR(5);
    DEFINE cCodRet3     CHAR(50);
    DEFINE iSqlErr      INTEGER;
    DEFINE iSamErr      INTEGER;
    DEFINE cDesErr      CHAR(50);
    DEFINE mSdoCtaTrf   DECIMAL(14,2);
    DEFINE cStatus      CHAR(1);
    DEFINE cTramaResp   CHAR(500);
    
    LET cCodRet1     = '';
    LET cCodRet2     = '';
    LET cCodRet3     = '';
    LET iSqlErr	     = 0;
    LET iSamErr      = 0;
    LET cDesErr      = '';
    LET mSdoCtaTrf   = 0.00;
    LET cStatus      = '';
    LET cTramaResp   = '';
	
	BEGIN
    
    ON EXCEPTION SET iSqlErr, iSamErr, cDesErr
        SET DEBUG FILE TO "/tmp/sp_consdoctatransfersoccomp.err";
        TRACE ON;
        IF iSqlErr <> 0 THEN
            LET cCodRet1 = iSqlErr;
            LET cCodRet2 = iSamErr;
            LET cCodRet3 = cDesErr;
            RETURN cCodRet1, mSdoCtaTrf;
        END IF;
    END EXCEPTION;  
    
    --- SET DEBUG FILE TO "/tmp/sp_consdoctatransfersoccomp.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 2;
    
    SELECT status, trama_res
      INTO cStatus, cTramaResp
      FROM bdicheq:sc_transfer_online
     WHERE no_serial = pSerial
       AND cuenta = pCuenta
       AND folio_suc = pFolioSuc
       AND id_transacc = pTransaccTrf;
    
    IF ( cStatus is not null AND cStatus = 'F' ) AND ( cTramaResp is not null OR cTramaResp <> '' ) THEN
        LET cCodRet1 = "000"; 
        LET mSdoCtaTrf = SUBSTR(cTramaResp, 49, 17);
    ELSE
        LET cCodRet1 = "999"; 
        LET mSdoCtaTrf = 0.00;
    END IF;
    
    RETURN cCodRet1, mSdoCtaTrf;
    
    END;
    
END PROCEDURE;
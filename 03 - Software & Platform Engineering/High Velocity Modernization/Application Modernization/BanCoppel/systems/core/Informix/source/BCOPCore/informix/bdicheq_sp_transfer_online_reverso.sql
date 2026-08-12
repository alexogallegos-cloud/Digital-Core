CREATE PROCEDURE "informix".sp_transfer_online_reverso( pTranTrfn CHAR(5), 
                                                        pCuenta   CHAR(20), 
                                                        pFolioSuc CHAR(16), 
                                                        pUsuario  CHAR(8) )
RETURNING CHAR(5), INTEGER;
    
    DEFINE cCodRet      CHAR(5);
    DEFINE cCodRet2     CHAR(5);
    DEFINE cCodRet3     CHAR(5);
    DEFINE iSqlErr      INTEGER;
    DEFINE iSamErr      INTEGER;
    DEFINE cDesErr      CHAR(50);
    DEFINE cWebService  CHAR(128);
    DEFINE cPaisTrnf    CHAR(3);
    DEFINE cBancoTrnf   CHAR(3);
    DEFINE cCanalTrnf   CHAR(3);
    DEFINE cMonedaTrnf  CHAR(3);
    DEFINE cCodRetSer   CHAR(5);
    DEFINE iSerial      INTEGER;
    DEFINE cHora        CHAR(23); 
    DEFINE cFechaHora   CHAR(15);
    DEFINE cTrama       CHAR(600);
    DEFINE cCodigoRet   CHAR(5);
    DEFINE cIdUser      CHAR(14);
    DEFINE cNoAudit     CHAR(15);
    DEFINE cTransaccId  CHAR(35);
    DEFINE cUsuario     CHAR(10);
    DEFINE cStatus      CHAR(1);
    
    LET cCodRet     = '';
    LET cCodRet2    = '';
    LET cCodRet3    = '';
    LET iSqlErr     = 0;
    LET iSamErr     = 0;
    LET cDesErr     = 0;
    LET cWebService = '';
    LET cPaisTrnf   = '';
    LET cBancoTrnf  = '';
    LET cCanalTrnf  = '';
    LET cMonedaTrnf = '';
    LET cCodRetSer  = '';
    LET cTrama      = '';
    LET cCodigoRet  = '';
    LET cIdUser     = '';
    LET cNoAudit    = '';
    LET iSerial     = 0;
    LET cStatus     = 'N';
    LET cUsuario    = '';
    --- LET cTransaccId = pFolioSuc||pCuenta;
    LET cTransaccId = RPAD(TRIM(pFolioSuc)||TRIM(pCuenta), 35, '0');
    LET cHora       = CURRENT;
    --- LET cFechaHora  = SUBSTR(cHora,1,4)||SUBSTR(cHora,6,2)||SUBSTR(cHora,9,2)||SUBSTR(cHora,12,2)||SUBSTR(cHora,15,2)||SUBSTR(cHora,18,2);
    LET cFechaHora  = RPAD(SUBSTR(cHora,1,4)||SUBSTR(cHora,6,2)||SUBSTR(cHora,9,2)||SUBSTR(cHora,12,2)||SUBSTR(cHora,15,2)||SUBSTR(cHora,18,2), 15 , '0');
    
    BEGIN
    
    ON EXCEPTION SET iSqlErr, iSamErr, cDesErr
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_transfer_online_reverso.err";
        TRACE ON;
        IF iSqlErr <> 0 THEN
            LET cCodRet  = iSqlErr;
            LET cCodRet2 = iSamErr;
            LET cCodRet3 = cDesErr;
            RETURN cCodRet, iSerial;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_transfer_online_reverso.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    SELECT valor
      INTO cWebService
      FROM sc_param
     WHERE empresa = '001'
       AND codparam = 'WSReverTransfer';
    
    SELECT valor
      INTO cPaisTrnf
      FROM sc_param
     WHERE empresa = '001'
       AND codparam = 'WSCodPaisTransfer';
    
    SELECT valor
      INTO cBancoTrnf
      FROM sc_param
     WHERE empresa = '001'
       AND codparam = 'WSCodBancoTransfer';
    
    SELECT valor
      INTO cCanalTrnf
      FROM sc_param
     WHERE empresa = '001'
       AND codparam = 'WSCodCanalTransfer';
    
    SELECT valor
      INTO cMonedaTrnf
      FROM sc_param
     WHERE empresa = '001'
       AND codparam = 'WSCodMonedaTransfer';
    
    CALL sp_transfer_online_serial( pCuenta, pFolioSuc, pTranTrfn)
    RETURNING cCodRetSer, iSerial;
    
    IF cCodRetSer <> '000' OR iSerial = 0 THEN
        LET cCodRet = '999';
        RETURN cCodRet, iSerial;
    END IF;
    
    LET cTrama = cWebService || 
                 cFechaHora  || 
                 cPaisTrnf   || 
                 cBancoTrnf  || 
                 cTransaccId || 
                 cCanalTrnf  || 
                 cMonedaTrnf || 
                 cUsuario    || 
                 cIdUser     || 
                 cNoAudit    ||
                 '$$'; 
    
    INSERT INTO sc_transfer_online( no_serial, cuenta, folio_suc, id_transacc, trama, cod_ret, status, fecha_hora )
    VALUES( iSerial, pCuenta, pFolioSuc, pTranTrfn, TRIM(cTrama), cCodigoRet, cStatus, current );
    
    IF ( dbinfo('sqlca.sqlerrd2') > 0 ) THEN
        LET cCodRet = '000';
        LET iSerial = iSerial;
    ELSE
        LET cCodRet = '999';
        LET iSerial = 0;
    END IF;
    
    END;
    
    RETURN cCodRet, iSerial;
    
END PROCEDURE;
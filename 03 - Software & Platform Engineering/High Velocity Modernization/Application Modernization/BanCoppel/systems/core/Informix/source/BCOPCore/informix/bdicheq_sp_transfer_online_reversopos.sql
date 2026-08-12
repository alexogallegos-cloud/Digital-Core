CREATE PROCEDURE "informix".sp_transfer_online_reversopos( pTranTrf     CHAR(5), 
                                                           pCuenta      CHAR(20), 
                                                           pFolioSuc    CHAR(16), 
                                                           pUsuario     CHAR(8),
                                                           pMonto       DECIMAL(14,2),
                                                           pFechaHoy    DATE,
                                                           pTranPosAut  CHAR(6),
                                                           pTranPosTrf  CHAR(5),
                                                           pTranPosTime CHAR(6),
                                                           pTranPosDate CHAR(4),
                                                           pTranPosRef  CHAR(12) )
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
    DEFINE cIdUser      CHAR(16);
    DEFINE cNoAudit     CHAR(15);
    DEFINE cTransaccId  CHAR(35);
    DEFINE cUsuario     CHAR(10);
    DEFINE cCuenta      CHAR(16);
    DEFINE cStatus      CHAR(1);
    DEFINE cMonto       CHAR(17);
    DEFINE cIdBanco     CHAR(3);
    DEFINE cRfc         CHAR(13);
    DEFINE cReferComer  CHAR(12);
    DEFINE cLocation    CHAR(40);
    DEFINE cProcesCode  CHAR(6);
    DEFINE cTransTime   CHAR(6);
    DEFINE cTransDate   CHAR(4);
    DEFINE cTrack2Data  CHAR(37);
    DEFINE cReferenNum  CHAR(12);
    DEFINE cAnio1       CHAR(4);
    DEFINE cAnio2       CHAR(2);
    DEFINE cMes         CHAR(2);
    DEFINE cDia         CHAR(2);
    DEFINE cHor         CHAR(2);
    DEFINE cMin         CHAR(2);
    DEFINE cSeg         CHAR(2);
    DEFINE vCodAutor    CHAR(6);
    DEFINE cTpoCuenta   CHAR(3);
    DEFINE cArrBancos   CHAR(3);
    
    LET cCodRet      = '';
    LET cCodRet2     = '';
    LET cCodRet3     = '';
    LET iSqlErr      = 0;
    LET iSamErr      = 0;
    LET cDesErr      = 0;
    LET cWebService  = '';
    LET cPaisTrnf    = '';
    LET cBancoTrnf   = '';
    LET cCanalTrnf   = '';
    LET cMonedaTrnf  = '';
    LET cCodRetSer   = '';
    LET cTrama       = '';
    LET cCodigoRet   = '';
    LET cIdUser      = '';
    LET cNoAudit     = '';
    LET iSerial      = 0;
    LET cStatus      = 'N';
    LET cUsuario     = '';
    LET cCuenta      = '';
    LET cTransaccId  = '';
    LET cHora        = '';
    LET cFechaHora   = '';
    LET cMonto       = '';
    LET cIdBanco     = '';
    LET cRfc         = '';
    LET cReferComer  = '';
    LET cLocation    = '';
    LET cProcesCode  = '';
    LET cHor         = '';
    LET cMin         = '';
    LET cSeg         = '';
    LET cTransTime   = '';
    LET cMes         = '';
    LET cDia         = '';
    LET cTransDate   = '';
    LET cAnio1       = '';
    LET cAnio2       = '';
    LET cTrack2Data  = '';
    LET cReferenNum  = '';
    LET vCodAutor    = '';
    LET cTpoCuenta   = '';
    LET cArrBancos   = '';
    
    BEGIN
    
    ON EXCEPTION SET iSqlErr, iSamErr, cDesErr
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_transfer_online_reversopos.err";
        TRACE ON;
        IF iSqlErr <> 0 THEN
            LET cCodRet  = iSqlErr;
            LET cCodRet2 = iSamErr;
            LET cCodRet3 = cDesErr;
            RETURN cCodRet, iSerial;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_transfer_online_reversopos.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    SELECT valor
      INTO cWebService
      FROM sc_param
     WHERE empresa = '001'
       AND codparam = 'WSReverPosTransfer';
    
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
       AND codparam = 'WSCanalPOSTransfer';
    
    SELECT valor
      INTO cMonedaTrnf
      FROM sc_param
     WHERE empresa = '001'
       AND codparam = 'WSCodMonedaTransfer';
    
    CALL sp_transfer_online_serial( pCuenta, pFolioSuc, pTranTrf)
    RETURNING cCodRetSer, iSerial;
    
    IF cCodRetSer <> '000' OR iSerial = 0 THEN
        LET cCodRet = '999';
        RETURN cCodRet, iSerial;
    END IF;
    
    LET cHora       = CURRENT;
    LET cMonto      = pMonto;
    LET cCuenta     = pCuenta;
    LET cFechaHora  = RPAD(SUBSTR(cHora,1,4)||SUBSTR(cHora,6,2)||SUBSTR(cHora,9,2)||SUBSTR(cHora,12,2)||SUBSTR(cHora,15,2)||SUBSTR(cHora,18,2), 15 , '0');
    LET cTransaccId = RPAD(pFolioSuc||cCuenta, 35, '0');
--- LET cProcesCode = SUBSTR(pFolioSuc, 2, 6);
    LET cProcesCode = LPAD(pTranPosTrf, 6, '0');
    LET cHor        = SUBSTR(cHora,12,2);
    LET cMin        = SUBSTR(cHora,15,2);
    LET cSeg        = SUBSTR(cHora,18,2);
    LET cTransTime  = cHor||cMin||cSeg;
    LET cMes        = LPAD(MONTH(pFechaHoy), 2, '0');
    LET cDia        = LPAD(DAY(pFechaHoy), 2, '0');
    LET cTransDate  = cMes||cDia;
    LET cAnio1      = YEAR(pFechaHoy);
    LET cAnio2      = SUBSTR(cAnio1, 3, 2);
--- LET cTrack2Data = TRIM(cCuenta)||'='||cAnio2||cMes||'0000000000000000';
    LET cTrack2Data = RPAD(TRIM(cCuenta)||'='||cAnio2||cMes, 37, '0'); 
    LET cReferenNum = SUBSTR(pFolioSuc, 2, 12);
    
    IF LENGTH(pCuenta) = 16 THEN
        LET cTpoCuenta = '103';
    ELIF LENGTH(pCuenta) = 12 THEN
        LET cTpoCuenta = '101';
    ELSE
        LET cTpoCuenta = '';
    END IF;
    
    LET cTransTime  = pTranPosTime;
    LET cTransDate  = pTranPosDate;
    LET cReferenNum = pTranPosRef;
    LET vCodAutor   = pTranPosAut;
    
    LET cTrama = cWebService || 
                 cFechaHora  || 
                 cPaisTrnf   || 
                 cTransaccId ||
                 cNoAudit    ||
                 cCanalTrnf  ||
                 cMonedaTrnf ||
                 cMonto      || 
                 cBancoTrnf  || 
                 cCuenta     ||  
                 cTpoCuenta  || 
                 cArrBancos  ||
                 cRfc        || 
                 cReferComer ||
                 cUsuario    || 
                 cIdUser     || 
                 cLocation   ||
                 cProcesCode ||
                 cTransTime  ||
                 cTransDate  ||
                 cTrack2Data ||
                 cReferenNum || 
                 vCodAutor   ||
                 '$$'; 
    
    INSERT INTO sc_transfer_online( no_serial, cuenta, folio_suc, id_transacc, trama, cod_ret, status, fecha_hora )
    VALUES( iSerial, pCuenta, pFolioSuc, pTranTrf, TRIM(cTrama), cCodigoRet, cStatus, current );
    
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
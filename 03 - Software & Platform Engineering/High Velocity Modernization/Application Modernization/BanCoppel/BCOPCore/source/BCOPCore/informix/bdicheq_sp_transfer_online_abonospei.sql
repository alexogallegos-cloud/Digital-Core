CREATE PROCEDURE "informix".sp_transfer_online_abonospei( pTranTrfn CHAR(5),
                                                          pCuenta   CHAR(20), 
                                                          pFolioSuc CHAR(16), 
                                                          pMonto    DECIMAL(14,2), 
                                                          pUsuario  CHAR(8),
                                                          pReferencia CHAR(30) )
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
    DEFINE cCuenta      CHAR(18);
    DEFINE cCodRetSer   CHAR(5);
    DEFINE iSerial      INTEGER;
    DEFINE cHora        CHAR(23); 
    DEFINE cFechaHora   CHAR(15);
    DEFINE cTpoCuenta   CHAR(3);
    DEFINE cTrama       CHAR(600);
    DEFINE cCodigoRet   CHAR(5);
    DEFINE cStatus      CHAR(1);
    DEFINE cIdUser      CHAR(14);
    DEFINE cSourceAcnt  CHAR(18);
    DEFINE cNoAudit     CHAR(15);
    DEFINE cReferencia  CHAR(40);
    DEFINE iReferencia  CHAR(7);
    DEFINE cTransaccId  CHAR(35);
    DEFINE cMonto       CHAR(17);
    DEFINE cUsuario     CHAR(10);
    DEFINE cBancoOrig   CHAR(3);
    DEFINE cCveRastreo  CHAR(30);
    DEFINE cNombreCte   CHAR(100);
    DEFINE cSourceActType CHAR(3);
    DEFINE cCuentaTf    CHAR(20);
    
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
    LET cTpoCuenta  = '';
    LET cTrama      = '';
    LET cCodigoRet  = '';
    LET cIdUser     = '';
    LET cSourceAcnt = pCuenta;
    LET cNoAudit    = '';
    LET cReferencia = '';
    LET iReferencia = '';
    LET iSerial     = 0;
    LET cStatus     = 'N';
    LET cCuenta     = pCuenta;
    LET cMonto      = pMonto;
    LET cUsuario    = '';
    --- LET cTransaccId = pFolioSuc||cCuenta;
    LET cTransaccId = RPAD(TRIM(pFolioSuc)||TRIM(cCuenta), 35, '0');
    LET cHora       = CURRENT;
    --- LET cFechaHora  = SUBSTR(cHora,1,4)||SUBSTR(cHora,6,2)||SUBSTR(cHora,9,2)||SUBSTR(cHora,12,2)||SUBSTR(cHora,15,2)||SUBSTR(cHora,18,2);
    LET cFechaHora  = RPAD(SUBSTR(cHora,1,4)||SUBSTR(cHora,6,2)||SUBSTR(cHora,9,2)||SUBSTR(cHora,12,2)||SUBSTR(cHora,15,2)||SUBSTR(cHora,18,2), 15 , '0');
    LET cBancoOrig  = '';
    LET cCveRastreo = TRIM(pReferencia);
    LET cNombreCte  = '';
    LET cSourceActType = '';
    LET cCuentaTf   = '';
    
    BEGIN
    
    ON EXCEPTION SET iSqlErr, iSamErr, cDesErr
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_transfer_online_abonospei.err";
        TRACE ON;
        IF iSqlErr <> 0 THEN
            LET cCodRet  = iSqlErr;
            LET cCodRet2 = iSamErr;
            LET cCodRet3 = cDesErr;
            RETURN cCodRet, iSerial;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_transfer_online_abonospei.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    SELECT valor
      INTO cWebService
      FROM sc_param
     WHERE empresa = '001'
       AND codparam = 'WSAbonoTransfer';
    
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
       AND codparam = 'WSCanalSPEITransfer';
    
    SELECT valor
      INTO cMonedaTrnf
      FROM sc_param
     WHERE empresa = '001'
       AND codparam = 'WSCodMonedaTransfer';
     
    IF ( cWebService is null  OR  cWebService = '' ) OR 
       ( cPaisTrnf   is null  OR  cPaisTrnf   = '' ) OR 
       ( cBancoTrnf  is null  OR  cBancoTrnf  = '' ) OR 
       ( cCanalTrnf  is null  OR  cCanalTrnf  = '' ) OR
       ( cMonedaTrnf is null  OR  cMonedaTrnf = '' ) THEN
        LET cCodRet = '110';
        RETURN cCodRet, iSerial;
    END IF;
    
    IF LENGTH(TRIM(cCuenta)) = 11 THEN
        LET cTpoCuenta = '104';
        LET cSourceActType = '104';
        
        SELECT TRIM(nombre1)||' '||TRIM(nombre2)||' '||TRIM(apell_paterno)||' '||TRIM(apell_materno)
          INTO cNombreCte
          FROM bditransfer:tf_maecte
         WHERE cuenta_tf = cCuenta
           AND status_cta = '1';
    ELIF LENGTH(TRIM(cCuenta)) = 12 THEN
        LET cTpoCuenta = '101';
        LET cSourceActType = '101';
        
        SELECT TRIM(nombre1)||' '||TRIM(nombre2)||' '||TRIM(apell_paterno)||' '||TRIM(apell_materno)
          INTO cNombreCte
          FROM bditransfer:tf_maecte
         WHERE cuenta_tf = cuenta_tf
           AND telefono = cCuenta
           AND status_cta = '1';
    ELIF LENGTH(TRIM(cCuenta)) = 16 THEN
        LET cTpoCuenta = '103';
        LET cSourceActType = '103';
        
        SELECT cuenta
          INTO cCuentaTf
          FROM sc_tarjeta
         WHERE empresa = '001'
           AND num_tarjeta = cCuenta;
        
        SELECT TRIM(nombre1)||' '||TRIM(nombre2)||' '||TRIM(apell_paterno)||' '||TRIM(apell_materno)
          INTO cNombreCte
          FROM bditransfer:tf_maecte
         WHERE cuenta_tf = cCuentaTf
           AND status_cta = '1';
    ELIF LENGTH(TRIM(cCuenta)) = 18 THEN
        LET cTpoCuenta = '102';
        LET cSourceActType = '102';
        
        SELECT TRIM(nombre1)||' '||TRIM(nombre2)||' '||TRIM(apell_paterno)||' '||TRIM(apell_materno)
          INTO cNombreCte
          FROM bditransfer:tf_maecte
         WHERE cuenta_tf = cuenta_tf
           AND cta_clabe = cCuenta
           AND status_cta = '1';
    ELSE
        LET cTpoCuenta = '111';
        RETURN cCodRet, iSerial;
    END IF;
    
    CALL sp_transfer_online_serial( cCuenta, pFolioSuc, pTranTrfn )
    RETURNING cCodRetSer, iSerial;
    
    IF cCodRetSer <> '000' OR iSerial = 0 THEN
        LET cCodRet = '999';
        RETURN cCodRet, iSerial;
    END IF;
    
    LET cTrama = cWebService    || 
                 cFechaHora     || 
                 cPaisTrnf      || 
                 cBancoTrnf     || 
                 cTransaccId    || 
                 cCanalTrnf     || 
                 cMonedaTrnf    || 
                 cCuenta        || 
                 cTpoCuenta     || 
                 cMonto         || 
                 cUsuario       || 
                 cIdUser        ||
                 cSourceAcnt    ||
                 cNoAudit       ||
                 cReferencia    ||
                 iReferencia    ||
                 --- cBancoOrig ||
                 cCveRastreo    ||
                 cNombreCte     ||
                 cSourceActType ||
                 '$$';
    
    INSERT INTO sc_transfer_online( no_serial, cuenta, folio_suc, id_transacc, trama, cod_ret, status, fecha_hora )
    VALUES( iSerial, cCuenta, pFolioSuc, pTranTrfn, TRIM(cTrama), cCodigoRet, cStatus, current );
    
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
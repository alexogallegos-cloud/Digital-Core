CREATE PROCEDURE "informix".sp_inserta_credspei( pCtaClabe CHAR(18), pMonto DECIMAL(15,2), pCveRastreo CHAR(30) )
RETURNING CHAR(5);
    
    DEFINE cCodRet      CHAR(5);
    DEFINE cCodRet2     CHAR(5);
    DEFINE cCodRet3     CHAR(5);
    DEFINE iSqlErr      INTEGER;
    DEFINE iSamErr      INTEGER;
    DEFINE cDesErr      CHAR(50);
    
    DEFINE cStatus         CHAR(1);
    DEFINE cCtaClabe       CHAR(18);
    DEFINE cMonto          CHAR(17);
    DEFINE iTpoPago        SMALLINT;
    DEFINE cMontoPagoWS    CHAR(18);
    DEFINE cCtaClabeWS     CHAR(18);
    DEFINE cCodRetWS       CHAR(5);
    DEFINE cCveBcoMexWS    CHAR(3);
    DEFINE cCodErrWS       CHAR(5);
    DEFINE cDescErrWS      CHAR(100);
    DEFINE cNoCteCentralWS CHAR(20);
    DEFINE cNoCteOrionWS   CHAR(15);
    DEFINE cRfcCteWS       CHAR(13);
    DEFINE cNombreCteWS    CHAR(40);
    
    LET cCodRet     = '000';
    LET cCodRet2    = '';
    LET cCodRet3    = '';
    LET iSqlErr     = 0;
    LET iSamErr     = 0;
    LET cDesErr     = 0;
    
    LET cStatus         = '';
    LET cCtaClabe       = '';
    LET cMonto          = '';
    LET iTpoPago        = '';
    LET cMontoPagoWS    = '';  
    LET cCtaClabeWS     = '';  
    LET cCodRetWS       = '';  
    LET cCveBcoMexWS    = '';  
    LET cCodErrWS       = '';  
    LET cDescErrWS      = ''; 
    LET cNoCteCentralWS = '';
    LET cNoCteOrionWS   = '';
    LET cRfcCteWS       = '';
    LET cNombreCteWS    = '';
    
    BEGIN
    
    ON EXCEPTION SET iSqlErr, iSamErr, cDesErr
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_inserta_credspei.err";
        TRACE ON;
        IF iSqlErr <> 0 THEN
            LET cCodRet  = iSqlErr;
            LET cCodRet2 = iSamErr;
            LET cCodRet3 = cDesErr;
            RETURN cCodRet;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_inserta_credspei.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF ( pCtaClabe   is null OR  pCtaClabe = '' ) OR 
       ( pMonto      is null OR  pMonto <= 0.00 ) OR 
       ( pCveRastreo is null OR  pCveRastreo = '' ) THEN
        LET cCodRet = '110';
        RETURN cCodRet;
    END IF;
    
    LET cStatus = 'N';
    LET iTpoPago = 0;
    
    INSERT INTO tblpagocred
    ( status, fecha_hora, cve_rastreo, cta_clabe, monto, tpo_pago, 
      monto_pago, ctaclabe_pago, codret_pago, cvebcomex_pago, coderr_pago, descerr_pago,
      no_cte_central, no_cte_orion, rfc_cte, nombre_cliente )
    VALUES
    ( cStatus, CURRENT, pCveRastreo, pCtaClabe, pMonto, iTpoPago, 
      cMontoPagoWS, cCtaClabeWS, cCodRetWS, cCveBcoMexWS, cCodErrWS, cDescErrWS,
      cNoCteCentralWS, cNoCteOrionWS, cRfcCteWS, cNombreCteWS );
    
    IF ( dbinfo('sqlca.sqlerrd2') > 0 ) THEN
        LET cCodRet = '000';
    ELSE
        LET cCodRet = '999';
    END IF;
    
    END;
    
    RETURN cCodRet;
    
END PROCEDURE;
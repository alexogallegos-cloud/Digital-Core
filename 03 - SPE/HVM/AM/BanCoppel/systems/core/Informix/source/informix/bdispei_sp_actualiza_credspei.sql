CREATE PROCEDURE "informix".sp_actualiza_credspei( pCveRastreo CHAR(30), 
                                                   pMontoPago  CHAR(18),
                                                   pCtaClabe   CHAR(18), 
                                                   pCodRet     CHAR(20),
                                                   pClaveBM    CHAR(3),
                                                   pCodError   CHAR(5),
                                                   pDescError  CHAR(100),
                                                   pCteCentral CHAR(20),
                                                   pCteOrion   CHAR(15),
                                                   pRFC        CHAR(13),
                                                   pNombreCte  CHAR(40) )
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
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_actualiza_credspei.err";
        TRACE ON;
        IF iSqlErr <> 0 THEN
            LET cCodRet  = iSqlErr;
            LET cCodRet2 = iSamErr;
            LET cCodRet3 = cDesErr;
            RETURN cCodRet;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_actualiza_credspei.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF ( ( pCveRastreo is null OR pCveRastreo = '' ) OR
         ( pCtaClabe is null OR pCtaClabe = '' ) OR
         ( pCodRet is null OR pCodRet = '' ) OR
         ( pClaveBM is null OR pClaveBM = '' ) OR 
         ( pCodError is null OR pCodError = '' ) ) THEN
        LET cCodRet = '110';
        RETURN cCodRet;
    END IF;
    
    IF pCodRet = '00000' THEN
        LET cStatus = 'F';
    ELSE
        LET cStatus = 'X';
    END IF;
    
    UPDATE tblpagocred
       SET status = cStatus,
           monto_pago = pMontoPago,
           ctaclabe_pago = pCtaClabe,
           codret_pago = pCodRet,
           cvebcomex_pago = pClaveBM,
           coderr_pago = pCodError,
           descerr_pago = pDescError,
           no_cte_central = pCteCentral,
           no_cte_orion = pCteOrion,
           rfc_cte = pRFC,
           nombre_cliente = pNombreCte
     WHERE cve_rastreo = pCveRastreo;
    
    IF dbinfo('sqlca.sqlerrd2') > 0  THEN
        LET cCodRet = '000';
    ELSE
        LET cCodRet = '999';
    END IF;
    
    END;
    
    RETURN cCodRet; 
    
END PROCEDURE;
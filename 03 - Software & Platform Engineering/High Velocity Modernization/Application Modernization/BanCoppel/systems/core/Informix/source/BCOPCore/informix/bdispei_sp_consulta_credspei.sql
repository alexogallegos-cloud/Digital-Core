CREATE PROCEDURE "informix".sp_consulta_credspei( pEmpresa CHAR(3) )
RETURNING CHAR(5), CHAR(30), CHAR(18), DECIMAL(15,2), SMALLINT;
          
    DEFINE cCodRet      CHAR(5);
    DEFINE cCodRet2     CHAR(5);
    DEFINE cCodRet3     CHAR(50);
    DEFINE iSqlErr      INTEGER;
    DEFINE iSamErr      INTEGER;
    DEFINE cDesErr      CHAR(50);
    
    DEFINE cCveRastreo  CHAR(30);
    DEFINE cCuentaClabe CHAR(18);
    DEFINE dMonto       DECIMAL(15,2);
    DEFINE iTpoPago     SMALLINT;
    
    
    LET cCodRet  = '';
    LET cCodRet2 = '';
    LET cCodRet3 = '';
    LET iSqlErr  = 0;
    LET iSamErr  = 0;
    LET cDesErr  = 0;
    
    LET cCveRastreo  = '';
    LET cCuentaClabe = '';
    LET dMonto       = 0.00;
    LET iTpoPago     = 0;
    
    BEGIN
    
    ON EXCEPTION SET iSqlErr, iSamErr, cDesErr
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_consulta_credspei.err";
        TRACE ON;
        IF iSqlErr <> 0 THEN
            LET cCodRet  = iSqlErr;
            LET cCodRet2 = iSamErr;
            LET cCodRet3 = cDesErr;
            RETURN cCodRet, cCveRastreo, cCuentaClabe, dMonto, iTpoPago;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_consulta_credspei.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
        
    SELECT FIRST 1 cve_rastreo, cta_clabe, monto, tpo_pago
      INTO cCveRastreo, cCuentaClabe, dMonto, iTpoPago
      FROM tblpagocred
     WHERE status = 'N';
     
    IF ( dbinfo('sqlca.sqlerrd2') > 0 ) THEN
        UPDATE tblpagocred
           SET status = 'E'
         WHERE cve_rastreo = cCveRastreo;
           
        IF ( dbinfo('sqlca.sqlerrd2') > 0 ) THEN
            LET cCodRet      = '000';
            LET cCveRastreo  = cCveRastreo;
            LET cCuentaClabe = cCuentaClabe;
            LET dMonto       = dMonto;
            LET iTpoPago     = iTpoPago;
        ELSE
            LET cCodRet      = '999';
            LET cCveRastreo  = '';
            LET cCuentaClabe = '';
            LET dMonto       = '';
            LET iTpoPago     = '';
        END IF;
    ELSE
        LET cCodRet      = '568';
        LET cCveRastreo  = '';
        LET cCuentaClabe = '';
        LET dMonto       = '';
        LET iTpoPago     = '';
    END IF;
     
    RETURN cCodRet, cCveRastreo, cCuentaClabe, dMonto, iTpoPago;
     
    END;
    
END PROCEDURE;
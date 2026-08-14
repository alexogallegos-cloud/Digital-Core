CREATE PROCEDURE "informix".spei_recliquidacion(pvchrclaverastreo CHAR(30)) -- clave de rastreo
RETURNING CHAR(5); -- codigo de retorno

    DEFINE vCodRet1     CHAR(5);
    DEFINE vCodRet2     CHAR(5);
    DEFINE vSqlErr      INTEGER; 
    DEFINE vIsamErr     INTEGER;
    
    DEFINE wexiste      CHAR(30);
    
    LET vCodRet1 = "00000";
    LET vCodRet2 = "00000";
    LET vSqlErr  = 0;
    LET vIsamErr = 0;
    
    LET wexiste = '';
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/spei/spei_recliquidacion.out";
    --- TRACE ON;

    BEGIN

    ON EXCEPTION SET vSqlErr, vIsamErr
        SET DEBUG FILE TO "/resplogifx/conciliachq/spei/spei_recliquidacion.err";
        TRACE ON;
        IF vSqlErr != 0 THEN
            LET vCodRet1 = vSqlErr;
            LET vCodRet2 = vIsamErr;
            RETURN vCodRet1; 
        END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    SELECT vchrclaverastreo
      INTO wexiste
      FROM bdispei:"informix".tblpago
     WHERE vchrclaverastreo = pvchrclaverastreo;
     
    IF wexiste is not null OR wexiste <> '' THEN
        UPDATE bdispei:"informix".tblpago
           SET chrestatusenvio = 'L'
         WHERE vchrclaverastreo = pvchrclaverastreo;
    END IF;
    
    END;
    
    RETURN vCodRet1;
    
END PROCEDURE;
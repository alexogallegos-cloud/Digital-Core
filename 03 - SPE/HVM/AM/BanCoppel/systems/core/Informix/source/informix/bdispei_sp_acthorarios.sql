CREATE PROCEDURE "informix".sp_acthorarios(phoraini char(8), phorafin char(8)) 

RETURNING CHAR(5); -- codigo de retorno

    DEFINE vCodRet1     CHAR(5);
    DEFINE vCodRet2     CHAR(5);
    DEFINE vSqlErr      INTEGER; 
    DEFINE vIsamErr     INTEGER;
    
    LET vCodRet1 = "000";
    LET vCodRet2 = "000";
    LET vSqlErr  = 0;
    LET vIsamErr = 0;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_acthorarios.out";
    --- TRACE ON;

    BEGIN

    ON EXCEPTION SET vSqlErr, vIsamErr
        --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_acthorarios.err";
        --- TRACE ON;
        IF vSqlErr != 0 THEN
            LET vCodRet1 = vSqlErr;
            LET vCodRet2 = vIsamErr;
            RETURN vCodRet1; 
        END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 2;
    
    UPDATE bdispei:"informix".tblhorario
       SET tmhorainicio = phoraini,
           tmhoralimite = phorafin
     WHERE intpkhorario = 1;
     
    IF dbinfo('sqlca.sqlerrd2') = 0 THEN
        LET vCodRet1 = '001';
    END IF;
    
    END;
    
    RETURN vCodRet1;
    
END PROCEDURE;
CREATE PROCEDURE "informix".sp_actual_gerente( pPuesto   CHAR(3),
                                               pSucursal CHAR(4), 
                                               pNombre   CHAR(45) ) 
    
    DEFINE cCodRet1 CHAR(5);
    DEFINE cCodRet2 CHAR(5);
    DEFINE cCodRet3 CHAR(50);
    DEFINE iSqlErr  INTEGER;
    DEFINE iIsamErr INTEGER;
    DEFINE cDescErr CHAR(50);
    DEFINE cTpoSuc  CHAR(1);
    
    LET cCodRet1 = '000';
    LET cCodRet2 = '';
    LET cCodRet3 = '';
    LET iSqlErr	 = 0;
    LET iIsamErr = 0;
    LET cDescErr = '';
    LET cTpoSuc  = '';
    
    BEGIN
    
    ON EXCEPTION SET iSqlErr, iIsamErr, cDescErr
        SET DEBUG FILE TO "/tmp/sp_actual_gerente.err";
        TRACE ON;
        IF iSqlErr <> 0 THEN
            LET cCodRet1 = iSqlErr;
            LET cCodRet2 = iIsamErr;
            LET cCodRet3 = cDescErr;
        END IF;
    END EXCEPTION;  
    
    --- SET DEBUG FILE TO "/tmp/sp_actual_gerente.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF pPuesto = '001' THEN
        SELECT tpo_sucursal
          INTO cTpoSuc
          FROM si_sucursales
         WHERE sucursal = pSucursal;
         
        IF cTpoSuc = 'S' THEN
            UPDATE si_sucursales
               SET gerente = pNombre
             WHERE sucursal = pSucursal;
        END IF;
    END IF;
    
    END;
    
END PROCEDURE;
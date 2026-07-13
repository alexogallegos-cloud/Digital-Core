CREATE PROCEDURE "informix".sp_actualiza_acumtrapres( pEmpresa CHAR(3) )
RETURNING CHAR(5), INTEGER, INTEGER;
    
    DEFINE sql_err      INTEGER;
    DEFINE isam_err     INTEGER;
    DEFINE desc_err     CHAR(50);
    DEFINE vcodret1     CHAR(5);
    DEFINE vcodret2     CHAR(5);
    DEFINE vcodret3     CHAR(50);
    DEFINE iContador1   INTEGER;
    DEFINE iContador2   INTEGER;
    DEFINE cCuenta      CHAR(20);
    DEFINE cNumCte      CHAR(20);
    
    LET sql_err  = 0;
    LET isam_err = 0;
    LET desc_err = '';
    LET vcodret1 = '000';
    LET vcodret2 = '';
    LET vcodret3 = '';
    LET iContador1 = 0;
    LET iContador2 = 0;
    LET cCuenta = '';
    LET cNumCte = '';
    
    --- SET DEBUG FILE TO "sp_actualiza_acumtrapres.out";
    --- TRACE ON;
    
    BEGIN
    
    ON EXCEPTION SET sql_err, isam_err
        -- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_actualiza_acumtrapres.err";
        -- TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            RETURN vcodret1, iContador1, iContador2;
        END IF;
    END EXCEPTION;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    FOREACH WITH HOLD
        SELECT UNIQUE cuenta
          INTO cCuenta
          FROM sc_acumtrapres
          
        LET iContador1 = iContador1 + 1;  
        
        BEGIN WORK;
          
        SELECT num_cte
          INTO cNumCte
          FROM sc_maechq
         WHERE empresa = pEmpresa
           AND cuenta = cCuenta;
           
        UPDATE sc_acumtrapres
           SET numcte = cNumCte
         WHERE cuenta = cCuenta;
         
        IF ( dbinfo('sqlca.sqlerrd2') > 0 ) THEN
            LET iContador2 = iContador2 + 1;
            COMMIT WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        
        LET cCuenta = '';
        LET cNumCte = '';
    END FOREACH;

    RETURN vcodret1, iContador1, iContador2;

    END;

END PROCEDURE;
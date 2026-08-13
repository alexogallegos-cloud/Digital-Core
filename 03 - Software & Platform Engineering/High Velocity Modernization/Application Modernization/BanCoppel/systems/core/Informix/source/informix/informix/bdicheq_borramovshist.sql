CREATE PROCEDURE "informix".borramovshist(pempresa CHAR(3), pcuenta CHAR(20), pfecha DATE)

RETURNING CHAR(5), CHAR(5), INTEGER;

    DEFINE vcodret1         CHAR(5);
    DEFINE vcodret2         CHAR(5);
    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE vcontador1       INTEGER;
    DEFINE vnum_serial      INTEGER;
    DEFINE vtransaccion     INTEGER;
    
    LET vcodret1        = '000';
    LET vcodret2        = '000';
    LET sql_err	        = 0;
    LET isam_err        = 0;
    LET vcontador1      = -1;
    LET vnum_serial     = 0;
    LET vtransaccion    = 0;
    
    BEGIN

    ON EXCEPTION SET sql_err, isam_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/borramovshist.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
        END IF;
    END EXCEPTION;
    
    -- SET DEBUG FILE TO "/resplogifx/conciliachq/borramovshist.out";
    -- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    
    FOREACH cursor_borra FOR
        SELECT num_serial
          INTO vnum_serial
          FROM sc_movdia
         WHERE empresa = pempresa
           AND cuenta = pcuenta
           AND fech_alt < pfecha
           
        IF vcontador1 = -1 THEN
            LET vcontador1 = 0;
        END IF;
        
        DELETE FROM sc_movdia 
         WHERE CURRENT OF cursor_borra;
         
        LET vcontador1 = vcontador1 + 1;
    END FOREACH;

    END;

    RETURN vcodret1, vcodret2, vcontador1;

END PROCEDURE;
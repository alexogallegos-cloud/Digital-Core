CREATE PROCEDURE "informix".borramovshistold1(pempresa CHAR(3), pcuenta CHAR(20), pfecha DATE)
RETURNING CHAR(5), CHAR(5), INTEGER;

    DEFINE vcodret1     CHAR(5);
    DEFINE vcodret2     CHAR(5);
    DEFINE vcodret3     CHAR(50);
    DEFINE sql_err      INTEGER;
    DEFINE isam_err     INTEGER;
    DEFINE desc_err     CHAR(50);
    DEFINE vcontador1   INTEGER;
    DEFINE vnum_serial  INTEGER;
    
    LET vcodret1    = '000';
    LET vcodret2    = '000';
    LET vcodret3    = '';
    LET sql_err	    = 0;
    LET isam_err    = 0;
    LET desc_err    = '';
    LET vcontador1  = -1;
    LET vnum_serial = 0;
    
    BEGIN

    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/borramovshistold1.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/borramovshistold1.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 10;
    
    FOREACH cursor_borra FOR
        SELECT {+INDEX(sc_movhis idx_movhisnew1)} num_serial
          INTO vnum_serial
          FROM sc_movhis
         WHERE empresa = pempresa
           AND cuenta = pcuenta
           AND fech_alt = pfecha
           
        IF vcontador1 = -1 THEN
            LET vcontador1 = 0;
        END IF;
        
        DELETE FROM sc_movhis 
         WHERE CURRENT OF cursor_borra;
         
        LET vcontador1 = vcontador1 + 1;
    END FOREACH;

    END;

    RETURN vcodret1, vcodret2, vcontador1;

END PROCEDURE;
CREATE PROCEDURE "informix".borramovs_movefechis(paniomes CHAR(6))
RETURNING CHAR(5), CHAR(5), INTEGER;

    DEFINE vcodret1         CHAR(5);
    DEFINE vcodret2         CHAR(5);
    DEFINE vcodret3         CHAR(50);
    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE desc_err         CHAR(50);
    DEFINE vcontador        INTEGER;
    DEFINE vcontador1       INTEGER;
    DEFINE vnum_serial      INTEGER;
    DEFINE vcomienza        SMALLINT;
    DEFINE vabierto         CHAR(1);
    
    LET vcodret1        = '000';
    LET vcodret2        = '000';
    LET sql_err	        = 0;
    LET isam_err        = 0;
    LET desc_err        = '';
    LET vcontador       = 0;
    LET vcontador1      = 0;
    LET vnum_serial     = 0;
    LET vcomienza       = -1;
    LET vabierto        = '0';
    
    BEGIN

    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/borramovs_movefechis.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            IF vabierto = '1' THEN
                ROLLBACK WORK;
            END IF;
        END IF;
    END EXCEPTION;
    
    -- SET DEBUG FILE TO "/resplogifx/conciliachq/borramovs_movefechis.out";
    -- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    FOREACH cursor_borra WITH HOLD FOR
        SELECT num_serial
          INTO vnum_serial
          FROM sl_movefec_his
         WHERE aniomes = paniomes
           AND num_cte is not null
           AND num_serial > 0
           
        IF vcomienza = -1 THEN
            LET vcomienza = 0;
            LET vabierto = '1';
            BEGIN WORK;
        END IF;
        
        DELETE FROM sl_movefec_his 
         WHERE CURRENT OF cursor_borra;
         
        LET vcontador = vcontador + 1;
        LET vcontador1 = vcontador1 + 1;
        
        IF vcontador1 >= 5000 THEN
            LET vcontador1 = 0;
            COMMIT WORK;
            BEGIN WORK;
        END IF;
    END FOREACH;
    
    IF vabierto = '1' THEN
        LET vabierto = '0';
        COMMIT WORK;
    END IF;

    END;

    RETURN vcodret1, vcodret2, vcontador;
    
END PROCEDURE;
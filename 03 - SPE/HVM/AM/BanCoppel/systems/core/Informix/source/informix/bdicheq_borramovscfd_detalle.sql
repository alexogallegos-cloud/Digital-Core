CREATE PROCEDURE "informix".borramovscfd_detalle( pfecha DATE )
RETURNING CHAR(5), INTEGER;

    DEFINE vcodret1         CHAR(5);
    DEFINE vcodret2         CHAR(5);
    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE vcontador1       INTEGER;
    DEFINE vcontador2       INTEGER;
    DEFINE vcomienza        SMALLINT;
    DEFINE vabierto         SMALLINT;
    DEFINE vidreg           INTEGER;
    DEFINE vfecha_emision   DATE;
    DEFINE vnum_cuenta      CHAR(20);
    
    LET vcodret1        = '000';
    LET vcodret2        = '000';
    LET sql_err	        = 0;
    LET isam_err        = 0;
    LET vcontador1      = 0;
    LET vcontador2      = 0;
    LET vcomienza       = -1;
    LET vabierto        = 0;
    LET vidreg          = 0;
    LET vfecha_emision  = '';
    LET vnum_cuenta     = '';
    
    BEGIN

    ON EXCEPTION SET sql_err, isam_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/borramovscfd_detalle.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            IF vabierto = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcodret1, vcontador1;
        END IF;
    END EXCEPTION;
    
    -- SET DEBUG FILE TO "/resplogifx/conciliachq/borramovscfd_detalle.out";
    -- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    FOREACH cursor_borra WITH HOLD FOR
        SELECT {+INDEX(sc_detalle_edocta_factelect idx_detedocta_fe)} idreg, fecha_emision, num_cuenta
          INTO vidreg, vfecha_emision, vnum_cuenta
          FROM sc_detalle_edocta_factelect
         WHERE fecha_emision <= pFecha
           
        IF vcomienza = -1 THEN
            LET vcomienza = 0;
            BEGIN WORK;
            LET vabierto = 1;
        END IF;
        
        DELETE FROM sc_detalle_edocta_factelect 
         WHERE CURRENT OF cursor_borra;
         
        LET vcontador1 = vcontador1 + 1;
        LET vcontador2 = vcontador2 + 1;
        
        IF vcontador2 >= 1000 THEN
            LET vcontador2 = 0;
            COMMIT WORK;
            BEGIN WORK;
        END IF;
    END FOREACH;
    
    IF vabierto = 1 THEN
        COMMIT WORK;
    END IF;

    END;

    RETURN vcodret1, vcontador1;

END PROCEDURE;
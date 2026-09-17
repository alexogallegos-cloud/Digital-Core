CREATE PROCEDURE "informix".borra_movs_movdia( pfecha DATE )
RETURNING CHAR(5), INTEGER, INTEGER, INTEGER;

    DEFINE vcodret1         CHAR(5);
    DEFINE vcodret2         CHAR(5);
    DEFINE vcodret3         CHAR(50);
    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE desc_err         CHAR(50);
    DEFINE vcomienza        SMALLINT;
    DEFINE vcontador1       INTEGER;
    DEFINE vcontador2       INTEGER;
    DEFINE vcontador3       INTEGER;
    DEFINE vtransaccion     INTEGER;
    DEFINE vregistros       INTEGER;
    DEFINE vnum_serial      INTEGER;
    
    LET vcodret1        = '000';
    LET vcodret2        = '';
    LET vcodret3        = '';
    LET sql_err	        = 0;
    LET isam_err        = 0;
    LET desc_err        = '';
    LET vcomienza       = -1;
    LET vcontador1      = 0;
    LET vcontador2      = 0;
    LET vcontador3      = 0;
    LET vtransaccion    = 0;
    LET vregistros      = 0;
    LET vnum_serial     = 0;
    
    BEGIN

    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/borra_movs_movdia.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            IF vtransaccion = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcodret1, vregistros, vcontador1, vcontador2;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/borra_movs_movdia.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    SELECT COUNT(*)
      INTO vregistros
      FROM sc_movdia
     WHERE fech_alt = pfecha;
    
    FOREACH WITH HOLD
        SELECT num_serial
          INTO vnum_serial
          FROM sc_movdia
         WHERE fech_alt = pfecha
         
        IF vcomienza = -1 THEN
            LET vcomienza = 0;
            BEGIN WORK;
            LET vtransaccion = 1;
        END IF;
           
        LET vcontador1 = vcontador1 + 1;
           
        DELETE FROM sc_movdia
         WHERE fech_alt = pfecha
           AND num_serial = vnum_serial;
           
        IF ( dbinfo('sqlca.sqlerrd2') > 0 ) THEN
            LET vcontador2 = vcontador2 + 1;
        END IF;
        
        LET vcontador3 = vcontador3 + 1;
        
        IF vcontador3 >= 1000 THEN
            LET vcontador3 = 0;
            COMMIT WORK;
            BEGIN WORK;
        END IF;
    END FOREACH;
    
    IF vtransaccion = 1 THEN
        LET vtransaccion = 0;
        COMMIT WORK;
    END IF;

    END;

    RETURN vcodret1, vregistros, vcontador1, vcontador2;

END PROCEDURE;
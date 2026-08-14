CREATE PROCEDURE "informix".sdos_31(pempresa CHAR(3))

RETURNING CHAR(5), CHAR(5), INTEGER;

    DEFINE vcodret1         CHAR(5);
    DEFINE vcodret2         CHAR(5);
    DEFINE vsqlerr          INTEGER;
    DEFINE visamerr         INTEGER;
    DEFINE vcontador        INTEGER;
    DEFINE vcuantos         INTEGER;
    DEFINE vcomienza        INTEGER;
    DEFINE vtransaccion     INTEGER;
    DEFINE vcuenta          CHAR(20);
    DEFINE vcapvig31        MONEY(18,2);
    DEFINE vsdo_actual      MONEY(18,2);
    
    LET vcodret1     = "000";
    LET vcodret2     = "000";
    LET vcontador    = -1;
    LET vcuantos     = 0;
    LET vcomienza    = -1;
    LET vtransaccion = 0;
    
    --- SET DEBUG FILE TO "sdos_31.out";
    --- TRACE ON;
    
    BEGIN
    
    ON EXCEPTION SET vsqlerr, visamerr
        IF vsqlerr <> 0 THEN
            LET vcodret1 = vsqlerr;
            LET vcodret2 = visamerr;
            IF vtransaccion = 1 THEN
                ROLLBACK WORK;
            END IF
            RETURN vcodret1, vcodret2, vcuantos;
        END IF;
    END EXCEPTION;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    FOREACH WITH HOLD
        SELECT {+INDEX(sc_maehiscont idx_maehiscont1), +INDEX(sc_sdodiarioc2009 isdodiario2009)} sdo.cuenta, sdo.capvig31, his.sdo_actual
          INTO vcuenta, vcapvig31, vsdo_actual
          FROM sc_maehiscont his,
               sc_sdodiarioc2009 sdo
         WHERE his.empresa = pempresa
           AND his.cuenta = sdo.cuenta
           AND his.aniomes = '200912'
           AND sdo.cuenta = his.cuenta
           AND sdo.aniomes = his.aniomes
           
        IF vcomienza = -1 THEN
            LET vcomienza = 0;
            LET vcontador = 0;
            LET vtransaccion = 1;
            BEGIN WORK;
        END IF
        
        IF vsdo_actual <> vcapvig31 THEN
            UPDATE sc_sdodiarioc2009
               SET capvig31 = vsdo_actual
             WHERE cuenta = vcuenta
               AND aniomes = '200912';
        END IF;
           
        LET vcontador = vcontador + 1;
        
        IF vcontador >= 75000 THEN
            LET vcuantos = vcuantos + vcontador;
            LET vcontador = 0;
            COMMIT WORK;
            BEGIN WORK;
        END IF
        
    END FOREACH
    
    IF vcontador > 0 THEN
        LET vcuantos = vcuantos + vcontador;
        COMMIT WORK;
    END IF
    
    END;

    RETURN vcodret1, vcodret2, vcuantos;

END PROCEDURE;
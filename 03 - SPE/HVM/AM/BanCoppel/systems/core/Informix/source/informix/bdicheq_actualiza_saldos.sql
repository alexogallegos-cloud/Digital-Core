CREATE PROCEDURE "informix".actualiza_saldos(pempresa CHAR(3))

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
    DEFINE vintprovnp31     MONEY(18,2);
    
    LET vcodret1     = "000";
    LET vcodret2     = "000";
    LET vcontador    = -1;
    LET vcuantos     = 0;
    LET vcomienza    = -1;
    LET vtransaccion = 0;
    
    --- SET DEBUG FILE TO "actualiza_saldos.out"
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
    SET LOCK MODE TO WAIT 2;
    ---set pdqpriority 1;
    
    FOREACH WITH HOLD
        SELECT chq.cuenta, sdo.capvig31, sdo.intprovnp31
          INTO vcuenta, vcapvig31, vintprovnp31
          FROM sc_sdodiarioc2009 sdo,
               sc_maechq chq
         WHERE sdo.cuenta = chq.cuenta
           AND sdo.aniomes = '200912'
           AND chq.status_cta <> '2'
           
        IF vcomienza = -1 THEN
            LET vcomienza = 0;
            LET vcontador = 0;
            LET vtransaccion = 1;
            BEGIN WORK;
        END IF
        
        UPDATE sc_sdodiarioc
           SET capvig1 = vcapvig31,
               intprovnp1 = vintprovnp31,
               capvigacum = vcapvig31,
               diacum = 1
         WHERE cuenta = vcuenta
           AND aniomes = '201001';
           
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
CREATE PROCEDURE "informix".sdos_31_2(pempresa CHAR(3))

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
    DEFINE vsucursal        CHAR(4);
    
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
    
    SELECT cuenta
      FROM sc_maenoc
     WHERE empresa = pempresa
       AND cuenta IN(SELECT cuenta FROM sc_maechq
                      WHERE (status_cta IN('1','3') OR fecha_proceso >= '12132009'))
       AND fecha_alta = '12312009'
      INTO TEMP tmp_ctas31 WITH NO LOG;
    CREATE INDEX idx_ctas31 ON tmp_ctas31(cuenta) USING BTREE FILLFACTOR 99;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_ctas31;
    
    SELECT cuenta
      FROM tmp_ctas31
     WHERE cuenta NOT IN(SELECT cuenta FROM sc_sdodiarioc2009 
                          WHERE cuenta <> '' AND aniomes = '200912')
      INTO TEMP tmp_ctas WITH NO LOG;
    CREATE INDEX idx_ctas ON tmp_ctas(cuenta) USING BTREE FILLFACTOR 99;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_ctas;
    
    FOREACH WITH HOLD
        SELECT a.cuenta, a.sdo_actual, a.sucursal 
          INTO vcuenta, vsdo_actual, vsucursal
          FROM sc_maehiscont a
         WHERE a.empresa = pempresa
           AND a.cuenta IN(SELECT cuenta FROM tmp_ctas)
           AND a.aniomes = '200912'
           
        IF vcomienza = -1 THEN
            LET vcomienza = 0;
            LET vcontador = 0;
            LET vtransaccion = 1;
            BEGIN WORK;
        END IF
        
        INSERT INTO sc_sdodiarioc2009 VALUES(
         vcuenta, '200912', vsucursal,
         0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
         0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
         0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
         0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
         0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
         0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
         vsdo_actual, 0, vsdo_actual, 31);
           
        LET vcontador = vcontador + 1;
        
        IF vcontador >= 5000 THEN
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
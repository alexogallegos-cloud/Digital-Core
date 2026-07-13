CREATE PROCEDURE "informix".bloquea_ctas_inactivas(pempresa CHAR(3))

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
    
    LET vcodret1     = "000";
    LET vcodret2     = "000";
    LET vcontador    = -1;
    LET vcuantos     = 0;
    LET vcomienza    = -1;
    LET vtransaccion = 0;
    
    --- SET DEBUG FILE TO "bloquea_ctas_inactivas.out"
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
    SET LOCK MODE TO WAIT 4;
    
    SELECT cuenta
      FROM sc_ctabloqueo
     WHERE cuenta BETWEEN (SELECT MIN(cuenta) FROM sc_ctabloqueo) AND (SELECT MAX(cuenta) FROM sc_ctabloqueo)
      INTO TEMP tmp_ctasbloq WITH NO LOG;
    CREATE INDEX idx_tmpctasbloq ON tmp_ctasbloq(cuenta) USING BTREE FILLFACTOR 99;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_ctasbloq;
        
    FOREACH WITH HOLD
        SELECT cuenta
          INTO vcuenta
          FROM sc_maechq
         WHERE status_cta = '4'
           AND producto IN('1400','1500','1700','2000')
           AND cuenta IN(SELECT cuenta FROM tmp_ctasbloq)
           
        IF vcomienza = -1 THEN
            LET vcomienza = 0;
            LET vcontador = 0;
            LET vtransaccion = 1;
            BEGIN WORK;
        END IF
        
        UPDATE sc_maechq
           SET status_cta = '3'
         WHERE empresa = pempresa
           AND cuenta = vcuenta;
           
        LET vcontador = vcontador + 1;
        
        COMMIT WORK;
        BEGIN WORK;
        
    END FOREACH;
    
    LET vcuantos = vcuantos + vcontador;
    COMMIT WORK;
    
    END;

    RETURN vcodret1, vcodret2, vcuantos;

END PROCEDURE;
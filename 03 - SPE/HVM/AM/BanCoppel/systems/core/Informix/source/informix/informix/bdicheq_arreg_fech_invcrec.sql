CREATE PROCEDURE "informix".arreg_fech_invcrec(pempresa CHAR(3))

RETURNING CHAR(5), CHAR(5), INTEGER;

    DEFINE vcodret1         CHAR(5);
    DEFINE vcodret2         CHAR(5);
    DEFINE vsqlerr          INTEGER;
    DEFINE visamerr         INTEGER;
    DEFINE vcontador        INTEGER;
    DEFINE vcuantos         INTEGER;
    DEFINE vcomienza        INTEGER;
    DEFINE vtransaccion     SMALLINT;
    DEFINE vcuenta          CHAR(20);
    
    LET vcodret1     = "000";
    LET vcodret2     = "000";
    LET vcontador    = -1;
    LET vcuantos     = 0;
    LET vcomienza    = -1;
    LET vtransaccion = 0;
    LET vcuenta = '';
    
    --- SET DEBUG FILE TO "arreg_fech_invcrec.out"
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
    
    SELECT noc.cuenta, noc.fecha_alta, noc.fecha_mod
      FROM sc_maenoc noc,
           sc_maechq chq
     WHERE noc.empresa = pempresa
       AND noc.cuenta = chq.cuenta
       AND noc.fecha_alta >= '01012010'
       AND day(noc.fecha_alta) <> day(noc.fecha_mod)
       AND chq.empresa = noc.empresa
       AND chq.cuenta = noc.cuenta
       AND chq.producto = '1100'
       AND chq.status_cta in('1','3')
      INTO TEMP tmp_ctasinvcrec WITH NO LOG;
    CREATE INDEX idx_ctasinvcrec ON tmp_ctasinvcrec(cuenta) USING BTREE FILLFACTOR 99;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_ctasinvcrec;
    
    FOREACH WITH HOLD
        SELECT cuenta
          INTO vcuenta
          FROM tmp_ctasinvcrec
               
        IF vcomienza = -1 THEN
            LET vcomienza = 0;
            LET vcontador = 0;
            LET vtransaccion = 1;
            BEGIN WORK;
        END IF
        
        UPDATE sc_maenoc
           SET fecha_mod = fecha_mod + 1 UNITS DAY
         WHERE empresa = pempresa
           AND cuenta = vcuenta;
           
        UPDATE sc_tasa_variable
           SET inicio_periodo = inicio_periodo + 1 UNITS DAY,
               fin_periodo = fin_periodo + 1 UNITS DAY
         WHERE empresa = pempresa
           AND cuenta = vcuenta;
           
        LET vcontador = vcontador + 1;
        
        IF vcontador >= 500 THEN
            LET vcuantos = vcuantos + vcontador;
            LET vcontador = 0;
            COMMIT WORK;
            BEGIN WORK;
        END IF
        
        LET vcuenta = '';
        
    END FOREACH
    
    IF vcontador > 0 THEN
        LET vcuantos = vcuantos + vcontador;
        COMMIT WORK;
    END IF
    
    END;

    RETURN vcodret1, vcodret2, vcuantos;

END PROCEDURE;
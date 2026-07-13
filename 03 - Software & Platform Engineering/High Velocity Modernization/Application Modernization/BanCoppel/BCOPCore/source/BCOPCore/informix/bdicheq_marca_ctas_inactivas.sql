CREATE PROCEDURE "informix".marca_ctas_inactivas(pempresa CHAR(3))

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
    
    --- SET DEBUG FILE TO "marca_ctas_inactivas.out"
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
    
    SELECT {+INDEX(sc_producto idx_producto1), +INDEX(sc_maechq maecheques)} mae.cuenta, mae.num_cte
      FROM sc_maechq mae,
           sc_producto pro
     WHERE pro.empresa = mae.empresa
       AND pro.producto = mae.producto
       AND mae.producto IN('1400','1500','1700','2000')
       AND mae.status_cta = '1'
       AND mae.fec_ult_mov < '09/08/2010'
       AND mae.sdo_actual < pro.mto_pag_int
       AND mae.num_cte NOT IN ( SELECT num_cte
                                  FROM sc_maechq
                                 WHERE producto = '1100'
                                   AND status_cta = '1' )
      INTO TEMP tmp_filtro1 WITH NO LOG;
begin;
    CREATE INDEX idx_filtro1 ON tmp_filtro1(num_cte) ONLINE;
commit;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_filtro1(num_cte) resolution 1.5;
        
    SELECT {+INDEX(tmp_filtro1 idx_filtro1)} cuenta, num_cte
      FROM tmp_filtro1
     WHERE num_cte NOT IN ( SELECT num_cte
                              FROM bdinvers:sv_maeinv
                             WHERE status_cta = '1' )
      INTO TEMP tmp_filtro2 WITH NO LOG;
begin;
    CREATE INDEX idx_filtro2 ON tmp_filtro2(num_cte) ONLINE;
commit;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_filtro2(num_cte) resolution 1.5;
    
    SELECT {+INDEX(tmp_filtro2 idx_filtro2)} cuenta, num_cte
      FROM tmp_filtro2
     WHERE num_cte NOT IN ( SELECT {+INDEX(bdicred:sd_maecred maesta)} numcte
                              FROM bdicred:sd_maecred
                             WHERE empresa = pempresa
                               AND status_cred IN('AA','BA','BT','FC','E1','E2','E3') )
      INTO TEMP tmp_filtro3 WITH NO LOG;
begin;
    CREATE INDEX idx_filtro3 ON tmp_filtro3(num_cte) ONLINE;
commit;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_filtro3(num_cte) resolution 1.5;
    
    FOREACH WITH HOLD
        SELECT {+INDEX(tmp_filtro3 idx_filtro3)} cuenta
          INTO vcuenta
          FROM tmp_filtro3
           
        IF vcomienza = -1 THEN
            LET vcomienza = 0;
            LET vcontador = 0;
            LET vtransaccion = 1;
            BEGIN WORK;
        END IF
        
        UPDATE {+INDEX(sc_maechq idx_maechq1)} sc_maechq
           SET status_cta = '4'
         WHERE empresa = pempresa
           AND cuenta = vcuenta;
           
        LET vcontador = vcontador + 1;
        
        IF vcontador >= 7500 THEN
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
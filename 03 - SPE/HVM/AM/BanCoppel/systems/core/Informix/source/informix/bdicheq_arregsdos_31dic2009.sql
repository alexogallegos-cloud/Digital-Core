CREATE PROCEDURE "informix".arregsdos_31dic2009(pempresa CHAR(3), pcuenta  CHAR(20), pfecha DATE)

RETURNING CHAR(5), INTEGER, INTEGER;

    -- // DECLARACION DE VARIABLES
    DEFINE vcodret          CHAR(5);
    DEFINE sql_err          INTEGER;
    DEFINE vcontador        INTEGER;
    DEFINE vcontador2       INTEGER;
    DEFINE vcuantos         INTEGER;
    DEFINE vcuantos2        INTEGER;
    DEFINE vcuenta          CHAR(20);
    DEFINE vnum_cte         CHAR(20);
    DEFINE vsucursal        CHAR(4);
    DEFINE vejecutivo       CHAR(8);
    DEFINE vcap_anterior    MONEY(18,2);
    DEFINE vcap_calculado   MONEY(18,2);
    DEFINE vcap_actual      MONEY(18,2);
    DEFINE vdif_capital     MONEY(18,2);
    DEFINE vint_anterior    MONEY(18,2);
    DEFINE vint_calculado   MONEY(18,2);
    DEFINE vint_actual      MONEY(18,2);
    DEFINE vdif_interes     MONEY(18,2);
    DEFINE vmontocargocap   MONEY(18,2);
    DEFINE vmontoabonocap   MONEY(18,2);
    DEFINE vmontocargoint   MONEY(18,2);
    DEFINE vmontoabonoint   MONEY(18,2);
    DEFINE vcta_cargo       CHAR(14);
    DEFINE vcta_abono       CHAR(14);
    DEFINE vfecha_hoy       DATE;
    DEFINE vfecha_ant       DATE;
    DEFINE vproducto        CHAR(4);

    -- // INICIALIZACION DE VARIABLES
    LET vcodret	        = '000';
    LET sql_err	        = 0;
    LET vcontador       = -1;
    LET vcontador2      = -1;
    LET vcuantos        = 0;
    LET vcuantos2       = 0;
    LET vcap_anterior   = 0.00;
    LET vmontocargocap  = 0.00;
    LET vmontoabonocap  = 0.00;
    LET vcap_calculado  = 0.00;
    LET vcap_actual     = 0.00;
    LET vdif_capital    = 0.00;
    LET vint_anterior   = 0.00;
    LET vmontocargoint  = 0.00;
    LET vmontoabonoint  = 0.00;
    LET vint_calculado  = 0.00;
    LET vint_actual     = 0.00;
    LET vdif_interes    = 0.00;

    BEGIN

    ON EXCEPTION
	SET sql_err
	IF sql_err <> 0 THEN
	    LET vcodret = sql_err;
        RETURN vcodret, vcuantos, vcuantos2;
	END IF;
    END EXCEPTION;

    -- SET DEBUG FILE TO "arregsdos_31DIC2009.out";
    -- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    LET vfecha_hoy = pfecha;
    LET vfecha_ant = pfecha - 1 UNITS DAY;
        
    -- // TABLA TEMPORAL DE MOVIMIENTOS
    SELECT mov.cuenta, mov.transacc, mov.monto_tot,
           TRIM(prod.c_ccmayor)||TRIM(prod.c_ccsub)||TRIM(prod.c_ccsubsub)||
           TRIM(prod.c_ccsssub)||TRIM(prod.c_ccssssub)  AS cta_cargo,
           TRIM(prod.a_ccmayor)||TRIM(prod.a_ccsub)||TRIM(prod.a_ccsubsub)||
           TRIM(prod.a_ccsssub)||TRIM(prod.a_ccssssub) AS cta_abono
      FROM bdicheq:"informix".sc_movhis mov,
           bdinteg:"informix".si_transacc tran,
           bdinteg:"informix".si_prodtran prod
     WHERE mov.empresa = pempresa
       AND mov.cuenta <> ''
       AND mov.fech_alt = vfecha_hoy
       AND mov.cancelad <> 'S'
       AND tran.sistema = '01'
       AND tran.numero = mov.transacc
       AND tran.empresa = mov.empresa
       AND tran.se_contabiliza = 'S'
       AND prod.transaccion = tran.numero
       AND prod.producto = mov.producto
       AND prod.sistema = tran.sistema
    INTO TEMP tmp_concilia WITH NO LOG;
    CREATE INDEX idx_concilia ON tmp_concilia(cuenta) USING BTREE FILLFACTOR 99;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_concilia;
    
    FOREACH WITH HOLD
        SELECT cuenta
          INTO vcuenta
          FROM sc_sdodiarioc2009
         WHERE cuenta <> ''
           AND aniomes = '200912'

        IF (vcontador = -1)THEN
            BEGIN WORK;
            LET vcontador = 0;
            LET vcontador2 = 0;
        END IF;

        -- // OBTIENE SALDOS ANTERIORES
        EXECUTE PROCEDURE bdicheq:'informix'.sp_capintafecha_2009(vcuenta, vfecha_ant)
        INTO vcodret, vcap_anterior, vint_anterior;
        
        IF vcodret <> '000' THEN
            LET vcap_anterior = 0.00;
            LET vint_anterior = 0.00;
            LET vcodret = '000';
        END IF
        
        LET vcap_calculado = vcap_anterior;
        LET vint_calculado = vint_anterior;
        
        -- // RESTA CAPITAL

        SELECT NVL(SUM(tmp.monto_tot),0.00)
          INTO vmontocargocap
          FROM tmp_concilia tmp
         WHERE tmp.cuenta = vcuenta
           AND tmp.cta_cargo IN(SELECT cta_contable 
                                  FROM bdicheq:"informix".sc_ctascontchq
                                 WHERE tipo = 'CAPITAL');

        LET vcap_calculado = vcap_calculado - vmontocargocap;
        
        -- // SUMA CAPITAL
        SELECT NVL(SUM(tmp.monto_tot),0.00)
          INTO vmontoabonocap
          FROM tmp_concilia tmp
         WHERE tmp.cuenta = vcuenta
           AND tmp.cta_abono IN(SELECT cta_contable 
                                  FROM bdicheq:"informix".sc_ctascontchq
                                 WHERE tipo = 'CAPITAL');

        LET vcap_calculado = vcap_calculado + vmontoabonocap;
        
        -- // RESTA INTERES
        SELECT NVL(SUM(tmp.monto_tot),0.00)
          INTO vmontocargoint
          FROM tmp_concilia tmp
         WHERE tmp.cuenta = vcuenta
           AND tmp.cta_cargo IN(SELECT cta_contable 
                                  FROM bdicheq:"informix".sc_ctascontchq
                                 WHERE tipo = 'INTERES');

        LET vint_calculado = vint_calculado - vmontocargoint;
        
        -- // SUMA INTERES
        SELECT NVL(SUM(tmp.monto_tot),0.00)
          INTO vmontoabonoint
          FROM tmp_concilia tmp
         WHERE tmp.cuenta = vcuenta
           AND tmp.cta_abono IN(SELECT cta_contable 
                                  FROM bdicheq:"informix".sc_ctascontchq
                                 WHERE tipo = 'INTERES');

        LET vint_calculado = vint_calculado + vmontoabonoint;
        
        UPDATE sc_sdodiarioc2009
           SET capvig31 = vcap_calculado,
               intprovnp31 = vint_calculado
         WHERE cuenta = vcuenta
           AND aniomes = '200912';
        
        LET vcontador = vcontador + 1;

        IF (vcontador >= 75000) THEN
            LET vcuantos = vcuantos + vcontador;
            LET vcontador = 0;
            COMMIT WORK;
            BEGIN WORK;
        END IF;
        
        IF (vcontador2 >= 75000) THEN
            LET vcuantos2 = vcuantos2 + vcontador2;
            LET vcontador2 = 0;
        END IF;
        
        LET vcap_anterior   = 0.00;
        LET vmontocargocap  = 0.00;
        LET vmontoabonocap  = 0.00;
        LET vcap_calculado  = 0.00;
        LET vcap_actual     = 0.00;
        LET vdif_capital    = 0.00;
        LET vint_anterior   = 0.00;
        LET vmontocargoint  = 0.00;
        LET vmontoabonoint  = 0.00;
        LET vint_calculado  = 0.00;
        LET vint_actual     = 0.00;
        LET vdif_interes    = 0.00;

    END FOREACH;

    LET vcuantos = vcuantos + vcontador;
    LET vcuantos2 = vcuantos2 + vcontador2;

    IF (vcontador > 0) THEN
        COMMIT WORK;
    END IF;

    END;

    RETURN vcodret, vcuantos, vcuantos2;

END PROCEDURE;
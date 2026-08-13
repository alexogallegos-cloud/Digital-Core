CREATE PROCEDURE "informix".sp_conciliachq_reg(pempresa CHAR(3), pcuenta  CHAR(20), pproducto CHAR(4), pfecha_hoy DATE, pfecha_ant DATE,
                                               pmin_cta CHAR(20), pmax_cta CHAR(20), pmincta CHAR(20), pmaxcta CHAR(20))

RETURNING CHAR(5), CHAR(5), INTEGER, INTEGER;

    DEFINE vcodret1     CHAR(5);
    DEFINE vcodret2     CHAR(5);
    DEFINE sql_err      INTEGER;
    DEFINE isam_err     INTEGER;
    DEFINE vcontador1   INTEGER;
    DEFINE vcontador2   INTEGER;
    DEFINE vcontador3   INTEGER;
    DEFINE vcomienza1   SMALLINT;
    DEFINE vcomienza2   SMALLINT;
    DEFINE ven_transacc SMALLINT;
    
    DEFINE vcuenta      CHAR(20);
    DEFINE vproducto    CHAR(4);
    DEFINE vnum_cte     CHAR(20);
    DEFINE vsucursal    CHAR(4);
    DEFINE vejecutivo   CHAR(8);
    
    DEFINE vcapital_anterior    MONEY(18,2);
    DEFINE vcapital_calculado   MONEY(18,2);
    DEFINE vmovs_cargo_capital  MONEY(18,2);
    DEFINE vmovs_abono_capital  MONEY(18,2);
    DEFINE vcapital_actual      MONEY(18,2);
    DEFINE vdiferencia_capital  MONEY(18,2);

    DEFINE vinteres_anterior    MONEY(18,2);
    DEFINE vinteres_calculado   MONEY(18,2);
    DEFINE vmovs_cargo_interes  MONEY(18,2);
    DEFINE vmovs_abono_interes  MONEY(18,2);
    DEFINE vinteres_actual      MONEY(18,2);
    DEFINE vdiferencia_interes  MONEY(18,2);

    LET vcodret1     = '000';
    LET vcodret2     = '000';
    LET sql_err	     = 0;
    LET isam_err     = 0;
    LET vcontador1   = 0;
    LET vcontador2   = 0;
    LET vcontador3   = 0;
    LET vcomienza1   = -1;
    LET vcomienza2   = -1;
    LET ven_transacc = 0; 
    
    LET vcuenta      = ''; 
    LET vproducto    = '';
    LET vnum_cte     = '';
    LET vsucursal    = '';
    LET vejecutivo   = '';
    
    LET vcapital_anterior   = 0.00;
    LET vcapital_calculado  = 0.00;
    LET vmovs_cargo_capital = 0.00;
    LET vmovs_abono_capital = 0.00;
    LET vcapital_actual     = 0.00;
    LET vdiferencia_capital = 0.00;
    
    LET vinteres_anterior   = 0.00;
    LET vinteres_calculado  = 0.00;
    LET vmovs_cargo_interes = 0.00;
    LET vmovs_abono_interes = 0.00;
    LET vinteres_actual     = 0.00;
    LET vdiferencia_interes = 0.00;
    
    BEGIN

    ON EXCEPTION SET sql_err, isam_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_conciliachq_reg.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            IF ven_transacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcodret1, vcodret2, vcontador1, vcontador2;
        END IF;
    END EXCEPTION;

    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_conciliachq_reg.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // TABLA TEMPORAL DE MOVIMIENTOS
    IF (pcuenta IS NULL OR pcuenta = '') THEN
        SELECT {+INDEX(sc_movhis idx_movhisnew4)} 
               mov.cuenta, mov.transacc, mov.monto_tot,
               TRIM(prod.c_ccmayor)||TRIM(prod.c_ccsub)||TRIM(prod.c_ccsubsub)||TRIM(prod.c_ccsssub)||TRIM(prod.c_ccssssub) AS cta_cargo,
               TRIM(prod.a_ccmayor)||TRIM(prod.a_ccsub)||TRIM(prod.a_ccsubsub)||TRIM(prod.a_ccsssub)||TRIM(prod.a_ccssssub) AS cta_abono
          FROM sc_movhis mov,
               bdinteg:si_transacc tran,
               bdinteg:si_prodtran prod
         WHERE mov.empresa = pempresa
           AND mov.cuenta BETWEEN pmincta AND pmaxcta
           AND mov.fech_alt = pfecha_hoy
           AND mov.cancelad != 'S'
           AND mov.transacc = tran.numero
           AND tran.empresa = mov.empresa
           AND tran.numero = mov.transacc
           AND tran.se_contabiliza = 'S'
           AND tran.sistema = '01'
           AND prod.transaccion = tran.numero
           AND prod.producto = mov.producto
           AND prod.sistema = tran.sistema
          INTO TEMP tmp_concilia WITH NO LOG;
        CREATE INDEX idx_concilia ON tmp_concilia(cuenta) USING BTREE FILLFACTOR 99;
        UPDATE STATISTICS MEDIUM FOR TABLE tmp_concilia;
    ELSE
        SELECT {+INDEX(sc_movhis idx_movhisnew4)} 
               mov.cuenta, mov.transacc, mov.monto_tot,
               TRIM(prod.c_ccmayor)||TRIM(prod.c_ccsub)||TRIM(prod.c_ccsubsub)||TRIM(prod.c_ccsssub)||TRIM(prod.c_ccssssub) AS cta_cargo,
               TRIM(prod.a_ccmayor)||TRIM(prod.a_ccsub)||TRIM(prod.a_ccsubsub)||TRIM(prod.a_ccsssub)||TRIM(prod.a_ccssssub) AS cta_abono
          FROM sc_movhis mov,
               bdinteg:si_transacc tran,
               bdinteg:si_prodtran prod
         WHERE mov.empresa = pempresa
           AND mov.cuenta = pcuenta
           AND mov.fech_alt = pfecha_hoy
           AND mov.cancelad != 'S'
           AND mov.transacc = tran.numero
           AND tran.empresa = mov.empresa
           AND tran.numero = mov.transacc
           AND tran.se_contabiliza = 'S'
           AND tran.sistema = '01'
           AND prod.transaccion = tran.numero
           AND prod.producto = mov.producto
           AND prod.sistema = tran.sistema
          INTO TEMP tmp_concilia WITH NO LOG;
        CREATE INDEX idx_concilia ON tmp_concilia(cuenta) USING BTREE FILLFACTOR 99;
        UPDATE STATISTICS MEDIUM FOR TABLE tmp_concilia;
    END IF;

    IF pproducto <> '1100' THEN
    
        -- // FOREACH CUENTAS SIN INVERSION CRECIENTE
        FOREACH WITH HOLD
            SELECT chq.cuenta, chq.producto, chq.num_cte, chq.sucursal, noc.ejecutivo
              INTO vcuenta, vproducto, vnum_cte, vsucursal, vejecutivo
              FROM sc_maechq chq,
                   sc_maenoc noc
             WHERE chq.empresa = pempresa
               AND chq.cuenta BETWEEN pmin_cta AND pmax_cta
               AND chq.cuenta = CASE WHEN pcuenta = '' THEN noc.cuenta ELSE pcuenta END
               AND (chq.status_cta <> '2' OR chq.fecha_proceso = pfecha_hoy)
               AND chq.producto = pproducto
               AND noc.empresa = chq.empresa
               AND noc.cuenta = chq.cuenta
               AND noc.fecha_alta < today
               
            IF vcomienza1 = -1 THEN
                LET vcomienza1 = 0;
                LET ven_transacc = 1; 
                BEGIN WORK;
            END IF;

            -- // OBTIENE SALDOS ANTERIORES
            EXECUTE PROCEDURE sp_capintafecha(vcuenta, pfecha_ant) 
            INTO vcodret1, vcapital_anterior, vinteres_anterior;
            
            IF vcodret1 = '100' THEN
                LET vcapital_anterior = 0.00;
                LET vinteres_anterior = 0.00;
                LET vcodret1 = '000';
            END IF;
            
            LET vcapital_calculado = vcapital_anterior;
            LET vinteres_calculado = vinteres_anterior;
            
            -- // RESTA CAPITAL 
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmovs_cargo_capital
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.cta_cargo IN (SELECT cta_contable FROM sc_ctascontchq WHERE (tipo = 'CAPITAL' OR tipo = 'SOBREGIRO'));

            LET vcapital_calculado = vcapital_calculado - vmovs_cargo_capital;
            
            -- // SUMA CAPITAL 
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmovs_abono_capital
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.cta_abono IN (SELECT cta_contable FROM sc_ctascontchq WHERE (tipo = 'CAPITAL' OR tipo = 'SOBREGIRO'));

            LET vcapital_calculado = vcapital_calculado + vmovs_abono_capital;
            
            -- // RESTA INTERES
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmovs_cargo_interes
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.cta_cargo IN(SELECT cta_contable FROM sc_ctascontchq WHERE tipo = 'INTERES');

            LET vinteres_calculado = vinteres_calculado - vmovs_cargo_interes;
            
            -- // SUMA INTERES
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmovs_abono_interes
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.cta_abono IN(SELECT cta_contable FROM sc_ctascontchq WHERE tipo = 'INTERES');

            LET vinteres_calculado = vinteres_calculado + vmovs_abono_interes;
            
            -- // OBTIENE SALDOS ACTUALES
            EXECUTE PROCEDURE sp_capintafecha(vcuenta, pfecha_hoy) 
            INTO vcodret1, vcapital_actual, vinteres_actual;
            
            IF vcodret1 = '100' THEN
                LET vcapital_actual = 0.00;
                LET vinteres_actual = 0.00;
                LET vcodret1 = '000';
            END IF;
            
            -- // OBTIENE DIFERENCIAS
            LET vdiferencia_capital = vcapital_actual - vcapital_calculado;
            LET vdiferencia_interes = vinteres_actual - vinteres_calculado;
            
            -- // LLENA TABLA DE TODAS LAS CUENTAS
            INSERT INTO conciliachq VALUES
            (pfecha_hoy, vcuenta, vproducto, vnum_cte, vsucursal, vejecutivo,
             vcapital_anterior, vmovs_cargo_capital, vmovs_abono_capital, vcapital_calculado, vcapital_actual, vdiferencia_capital, 
             vinteres_anterior, vmovs_cargo_interes, vmovs_abono_interes, vinteres_calculado, vinteres_actual, vdiferencia_interes);
            
            -- // LLENA TABLA DE DIFERENCIAS
            IF (vdiferencia_capital != 0.00 OR vdiferencia_interes != 0.00) THEN
                INSERT INTO conciliachq_dif VALUES
                (pfecha_hoy, vcuenta, vproducto, vnum_cte, vsucursal, vejecutivo,
                 vcapital_anterior, vmovs_cargo_capital, vmovs_abono_capital, vcapital_calculado, vcapital_actual, vdiferencia_capital, 
                 vinteres_anterior, vmovs_cargo_interes, vmovs_abono_interes, vinteres_calculado, vinteres_actual, vdiferencia_interes); 
                 
                LET vcontador2 = vcontador2 + 1;
            END IF;
            
            LET vcontador1 = vcontador1 + 1;
            LET vcontador3 = vcontador3 + 1;
            
            IF (vcontador3 >= 50000) THEN
                LET vcontador3 = 0;
                UPDATE STATISTICS MEDIUM FOR TABLE conciliachq;
                UPDATE STATISTICS MEDIUM FOR TABLE conciliachq_dif;
                COMMIT WORK;
                BEGIN WORK;
            END IF;
            
            LET vcuenta      = ''; 
            LET vproducto    = '';
            LET vnum_cte     = '';
            LET vsucursal    = '';
            LET vejecutivo   = '';
            
            LET vcapital_anterior   = 0.00;
            LET vcapital_calculado  = 0.00;
            LET vmovs_cargo_capital = 0.00;
            LET vmovs_abono_capital = 0.00;
            LET vcapital_actual     = 0.00;
            LET vdiferencia_capital = 0.00;
            
            LET vinteres_anterior   = 0.00;
            LET vinteres_calculado  = 0.00;
            LET vmovs_cargo_interes = 0.00;
            LET vmovs_abono_interes = 0.00;
            LET vinteres_actual     = 0.00;
            LET vdiferencia_interes = 0.00;
        END FOREACH;
    
        IF ven_transacc = 1 THEN
            LET ven_transacc = 0;
            COMMIT WORK;
        END IF;
    
    ELSE   

        -- // FOREACH CUENTAS INVERSION CRECIENTE
        FOREACH WITH HOLD
            SELECT chq.cuenta, chq.producto, chq.num_cte, chq.sucursal, noc.ejecutivo
              INTO vcuenta, vproducto, vnum_cte, vsucursal, vejecutivo
              FROM sc_maechq chq,
                   sc_maenoc noc
             WHERE chq.empresa = pempresa
               AND chq.cuenta BETWEEN pmin_cta AND pmax_cta
               AND chq.cuenta = CASE WHEN pcuenta = '' THEN noc.cuenta ELSE pcuenta END
               AND (chq.status_cta <> '2' OR chq.fecha_proceso = pfecha_hoy)
               AND chq.producto = pproducto
               AND chq.sdo_dia_ant <> 0.00
               AND noc.empresa = chq.empresa
               AND noc.cuenta = chq.cuenta
               
            IF vcomienza2 = -1 THEN
                LET vcomienza2 = 0;
                LET ven_transacc = 1; 
                BEGIN WORK;
            END IF;

            -- // OBTIENE SALDOS ANTERIORES
            EXECUTE PROCEDURE sp_capintafecha(vcuenta, pfecha_ant) 
            INTO vcodret1, vcapital_anterior, vinteres_anterior;
            
            LET vcapital_calculado = vcapital_anterior;
            LET vinteres_calculado = vinteres_anterior;
            
            -- // RESTA CAPITAL 
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmovs_cargo_capital
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.cta_cargo IN (SELECT cta_contable FROM sc_ctascontchq WHERE (tipo = 'CAPITAL' OR tipo = 'SOBREGIRO'));

            LET vcapital_calculado = vcapital_calculado - vmovs_cargo_capital;
            
            -- // SUMA CAPITAL 
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmovs_abono_capital
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.cta_abono IN (SELECT cta_contable FROM sc_ctascontchq WHERE (tipo = 'CAPITAL' OR tipo = 'SOBREGIRO'));

            LET vcapital_calculado = vcapital_calculado + vmovs_abono_capital;
            
            -- // RESTA INTERES
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmovs_cargo_interes
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.cta_cargo IN(SELECT cta_contable FROM sc_ctascontchq WHERE tipo = 'INTERES');

            LET vinteres_calculado = vinteres_calculado - vmovs_cargo_interes;
            
            -- // SUMA INTERES
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmovs_abono_interes
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.cta_abono IN(SELECT cta_contable FROM sc_ctascontchq WHERE tipo = 'INTERES');

            LET vinteres_calculado = vinteres_calculado + vmovs_abono_interes;
            
            -- // OBTIENE SALDOS ACTUALES
            EXECUTE PROCEDURE sp_capintafecha(vcuenta, pfecha_hoy) 
            INTO vcodret1, vcapital_actual, vinteres_actual;
            
            -- // OBTIENE DIFERENCIAS
            LET vdiferencia_capital = vcapital_actual - vcapital_calculado;
            LET vdiferencia_interes = vinteres_actual - vinteres_calculado;
            
            -- // LLENA TABLA DE TODAS LAS CUENTAS
            INSERT INTO conciliachq VALUES
            (pfecha_hoy, vcuenta, vproducto, vnum_cte, vsucursal, vejecutivo,
             vcapital_anterior, vmovs_cargo_capital, vmovs_abono_capital, vcapital_calculado, vcapital_actual, vdiferencia_capital, 
             vinteres_anterior, vmovs_cargo_interes, vmovs_abono_interes, vinteres_calculado, vinteres_actual, vdiferencia_interes);
            
            -- // LLENA TABLA DE DIFERENCIAS
            IF (vdiferencia_capital != 0.00 OR vdiferencia_interes != 0.00) THEN
                INSERT INTO conciliachq_dif VALUES
                (pfecha_hoy, vcuenta, vproducto, vnum_cte, vsucursal, vejecutivo,
                 vcapital_anterior, vmovs_cargo_capital, vmovs_abono_capital, vcapital_calculado, vcapital_actual, vdiferencia_capital, 
                 vinteres_anterior, vmovs_cargo_interes, vmovs_abono_interes, vinteres_calculado, vinteres_actual, vdiferencia_interes); 
                 
                LET vcontador2 = vcontador2 + 1;
            END IF;
            
            LET vcontador1 = vcontador1 + 1;
            LET vcontador3 = vcontador3 + 1;
            
            IF (vcontador3 >= 50000) THEN
                LET vcontador3 = 0;
                UPDATE STATISTICS MEDIUM FOR TABLE conciliachq;
                UPDATE STATISTICS MEDIUM FOR TABLE conciliachq_dif;
                COMMIT WORK;
                BEGIN WORK;
            END IF;

            LET vcuenta    = ''; 
            LET vproducto  = '';
            LET vnum_cte   = '';
            LET vsucursal  = '';
            LET vejecutivo = '';
            
            LET vcapital_anterior   = 0.00;
            LET vcapital_calculado  = 0.00;
            LET vmovs_cargo_capital = 0.00;
            LET vmovs_abono_capital = 0.00;
            LET vcapital_actual     = 0.00;
            LET vdiferencia_capital = 0.00;
            
            LET vinteres_anterior   = 0.00;
            LET vinteres_calculado  = 0.00;
            LET vmovs_cargo_interes = 0.00;
            LET vmovs_abono_interes = 0.00;
            LET vinteres_actual     = 0.00;
            LET vdiferencia_interes = 0.00;
        END FOREACH;
        
        IF ven_transacc = 1 THEN
            LET ven_transacc = 0;
            COMMIT WORK;
        END IF;
        
    END IF;
    
    END;

    RETURN vcodret1, vcodret2, vcontador1, vcontador2;

END PROCEDURE;
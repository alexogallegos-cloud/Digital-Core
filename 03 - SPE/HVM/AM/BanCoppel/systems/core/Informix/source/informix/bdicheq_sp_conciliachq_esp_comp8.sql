CREATE PROCEDURE "informix".sp_conciliachq_esp_comp8(pempresa CHAR(3), pfecha DATE)
RETURNING CHAR(5), CHAR(5), INTEGER, INTEGER;
    
    DEFINE vcodret1     CHAR(5);
    DEFINE vcodret2     CHAR(5);
    DEFINE sql_err      INTEGER;
    DEFINE isam_err     INTEGER;
    DEFINE vcontador1   INTEGER;
    DEFINE vcontador2   INTEGER;
    DEFINE vcontador3   INTEGER;
    DEFINE vcomienza1   SMALLINT;
    DEFINE ven_transacc SMALLINT;
    
    DEFINE vfecha_hoy    DATE;
    DEFINE vfecha_ant    DATE;
    DEFINE vfecha_actual DATE;
    DEFINE vpri_hab_mes  DATE;
    
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
    
    DEFINE vcuentaini           CHAR(20);
    DEFINE vcuentafin           CHAR(20);
    
    DEFINE vcuenta_cargo        CHAR(14);  
    DEFINE vcuenta_abono        CHAR(14);  
    DEFINE vmonto_tot           MONEY(14,2);
    DEFINE vgenero              CHAR(1);
    
    DEFINE vestatus_actual      CHAR(1);
    DEFINE vestatus_anterior    CHAR(1);

    LET vcodret1     = '000';
    LET vcodret2     = '000';
    LET sql_err	     = 0;
    LET isam_err     = 0;
    LET vcontador1   = 0;
    LET vcontador2   = 0;
    LET vcontador3   = 0;
    LET vcomienza1   = -1;
    LET ven_transacc = 0; 
    
    LET vfecha_hoy    = ''; 
    LET vfecha_ant    = '';
    LET vfecha_actual = '';
    LET vpri_hab_mes  = '';
    
    LET vcuenta    = ''; 
    LET vproducto  = '';
    LET vnum_cte   = '';
    LET vsucursal  = '';
    LET vejecutivo = '';
    
    LET vcapital_anterior       = 0.00;
    LET vcapital_calculado      = 0.00;
    LET vmovs_cargo_capital     = 0.00;
    LET vmovs_abono_capital     = 0.00;
    LET vcapital_actual         = 0.00;
    LET vdiferencia_capital     = 0.00;
    
    LET vinteres_anterior       = 0.00;
    LET vinteres_calculado      = 0.00;
    LET vmovs_cargo_interes     = 0.00;
    LET vmovs_abono_interes     = 0.00;
    LET vinteres_actual         = 0.00;
    LET vdiferencia_interes     = 0.00;
    
    LET vcuentaini = '';
    LET vcuentafin = '';
    
    LET vcuenta_cargo = '';
    LET vcuenta_abono = '';
    LET vmonto_tot    = 0.00;
    LET vgenero       = '';
    
    LET vestatus_actual = '';
    LET vestatus_anterior = '';

    BEGIN

    ON EXCEPTION SET sql_err, isam_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_conciliachq_esp_comp8.err";
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

    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_conciliachq_esp_comp8.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    SELECT pri_hab_mes
      INTO vpri_hab_mes
      FROM sc_fechas
     WHERE empresa = pempresa;
    
    -- // TABLA PARA TODAS LAS CUENTAS
    CREATE TEMP TABLE tmp_conciliachq
      (
        fecha                   DATE,           
        cuenta                  CHAR(20),
        producto                CHAR(4),        
        num_cte                 CHAR(20),
        genero                  CHAR(1),
        sucursal                CHAR(4),        
        ejecutivo               CHAR(8),
        capital_anterior        MONEY(18,2),    
        movs_cargo              MONEY(18,2),
        movs_abono              MONEY(18,2),    
        capital_calculado       MONEY(18,2),
        capital_actual          MONEY(18,2),
        diferencia_capital      MONEY(18,2),
        interes_anterior        MONEY(18,2),    
        movs_cargo_interes      MONEY(18,2),
        movs_abono_interes      MONEY(18,2),    
        interes_calculado       MONEY(18,2),
        interes_actual          MONEY(18,2),    
        diferencia_interes      MONEY(18,2)
      ) WITH NO LOG LOCK MODE ROW;
    CREATE INDEX idx_tmpconciliachq ON tmp_conciliachq(cuenta) USING BTREE;
    
    -- // TABLA DE DIFERENCIAS
    CREATE TEMP TABLE tmp_conciliachq_dif
      (
        fecha                   DATE,           
        cuenta                  CHAR(20),
        producto                CHAR(4),        
        num_cte                 CHAR(20),
        genero                  CHAR(1),
        sucursal                CHAR(4),        
        ejecutivo               CHAR(8),
        capital_anterior        MONEY(18,2),    
        movs_cargo              MONEY(18,2),
        movs_abono              MONEY(18,2),    
        capital_calculado       MONEY(18,2),
        capital_actual          MONEY(18,2),
        diferencia_capital      MONEY(18,2),
        interes_anterior        MONEY(18,2),    
        movs_cargo_interes      MONEY(18,2),
        movs_abono_interes      MONEY(18,2),    
        interes_calculado       MONEY(18,2),
        interes_actual          MONEY(18,2),    
        diferencia_interes      MONEY(18,2)
      ) WITH NO LOG LOCK MODE ROW;
    CREATE INDEX idx_tmpconciliadifchq ON tmp_conciliachq_dif(cuenta) USING BTREE;
    
    LET vfecha_hoy    = pfecha;
    LET vfecha_ant    = pfecha - 1 UNITS DAY;
    LET vfecha_actual = pfecha + 1 UNITS DAY;
    
    CALL sp_valfechabil(vfecha_hoy, '-') 
    RETURNING vcodret1, vfecha_hoy;    
    
    CALL sp_valfechabil(vfecha_ant, '-') 
    RETURNING vcodret1, vfecha_ant;
    
    -- // OBTIENE EL RANGO DE CUENTAS A PROCESAR
    SELECT valor
      INTO vcuentaini
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = 'CtaIniConcilChqComp8';
       
    /*
    SELECT valor
      INTO vcuentafin
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = 'CtaIniConcilChqComp8';
    */
    
    -- // TABLA TEMPORAL DE MOVIMIENTOS
    SELECT {+INDEX(sc_movhis idx_movhisnew4)} 
           mov.cuenta, mov.transacc, mov.monto_tot,
           TRIM(prod.c_ccmayor)||TRIM(prod.c_ccsub)||TRIM(prod.c_ccsubsub)||TRIM(prod.c_ccsssub)||TRIM(prod.c_ccssssub)||TRIM(prod.c_sector) AS cta_cargo,
           TRIM(prod.a_ccmayor)||TRIM(prod.a_ccsub)||TRIM(prod.a_ccsubsub)||TRIM(prod.a_ccsssub)||TRIM(prod.a_ccssssub)||TRIM(prod.a_sector) AS cta_abono
      FROM sc_movhis mov,
           bdinteg:si_transacc tran,
           bdinteg:si_prodtran prod
     WHERE mov.empresa = pempresa
       AND mov.cuenta >= vcuentaini
       --- AND mov.cuenta < vcuentafin
       AND mov.fech_alt = vfecha_hoy
       AND mov.cancelad != 'S'
       AND mov.transacc = tran.numero
       AND mov.producto = '2000'
       AND tran.empresa = mov.empresa
       AND tran.numero = mov.transacc
       AND tran.se_contabiliza = 'S'
       AND tran.sistema = '01'
       AND prod.transaccion = tran.numero
       AND prod.producto = mov.producto
       AND prod.sistema = tran.sistema
      INTO TEMP tmp_concilia WITH NO LOG;
      
    CREATE INDEX idxtmp_concilia_cta ON tmp_concilia(cuenta) ONLINE;
    CREATE INDEX idxtmp_concilia_ctacgo ON tmp_concilia(cuenta, cta_cargo) ONLINE;
    CREATE INDEX idxtmp_concilia_ctaabo ON tmp_concilia(cuenta, cta_abono) ONLINE;
    
    UPDATE STATISTICS HIGH FOR TABLE tmp_concilia;
    
    IF vfecha_actual = vpri_hab_mes THEN
    
        FOREACH WITH HOLD
            SELECT chq.cuenta, chq.producto, chq.num_cte, chq.sucursal, noc.ejecutivo
              INTO vcuenta, vproducto, vnum_cte, vsucursal, vejecutivo
              FROM sc_maechq chq,
                   sc_maenoc noc
             WHERE chq.cuenta >= vcuentaini
               --- AND chq.cuenta < vcuentafin
               AND chq.producto = '2000'
               AND ( chq.status_cta <> '2' OR chq.fecha_proceso >= vfecha_hoy )
               AND noc.cuenta = chq.cuenta
               AND noc.fecha_alta < vfecha_actual

            IF vcomienza1 = -1 THEN
                LET vcomienza1 = 0;
                LET ven_transacc = 1; 
                BEGIN WORK;
            END IF;
            
            SELECT sexo
              INTO vgenero
              FROM bdinteg:si_ctepf 
             WHERE numcte = vnum_cte;
             
            IF vgenero is null OR vgenero = '' OR vgenero NOT IN('F','M') THEN
                LET vgenero = 'E';
            END IF;

            -- // OBTIENE SALDOS ANTERIORES
            /* ######################################################
            EXECUTE PROCEDURE sp_capintafecha(vcuenta, vfecha_ant) 
            INTO vcodret1, vcapital_anterior, vinteres_anterior;
            ###################################################### */
            
            EXECUTE PROCEDURE sp_capintafecha_status(vcuenta, vfecha_ant) 
            INTO vcodret1, vcapital_anterior, vinteres_anterior, vestatus_anterior;
            
            IF vcodret1 = '100' THEN
                LET vcodret1 = '000';
                LET vcapital_anterior = 0.00;
                LET vinteres_anterior = 0.00;
                LET vestatus_anterior = '0';
            END IF;
            
            LET vcapital_calculado = vcapital_anterior;
            LET vinteres_calculado = vinteres_anterior;
            
            -- // OBTIENE LOS MOVIMIENTOS DE CAPITAL E INTERES
            FOREACH
                SELECT {+INDEX(tmp_concilia idx_concilia)} 
                       cta_cargo, cta_abono, monto_tot
                  INTO vcuenta_cargo, vcuenta_abono, vmonto_tot
                  FROM tmp_concilia
                 WHERE cuenta = vcuenta
                 
                IF vcuenta_cargo IN( SELECT cta_contable FROM sc_ctascontchq WHERE producto = vproducto AND tipo IN('CAPITAL','SOBREGIRO') ) THEN
                    LET vcapital_calculado = vcapital_calculado - vmonto_tot;
                    LET vmovs_cargo_capital = vmovs_cargo_capital + vmonto_tot;
                END IF;
                        
                IF vcuenta_abono IN( SELECT cta_contable FROM sc_ctascontchq WHERE producto = vproducto AND tipo IN('CAPITAL','SOBREGIRO') ) THEN
                    LET vcapital_calculado = vcapital_calculado + vmonto_tot;
                    LET vmovs_abono_capital = vmovs_abono_capital + vmonto_tot;
                END IF;
                                    
                IF vcuenta_cargo IN( SELECT cta_contable FROM sc_ctascontchq WHERE producto = vproducto AND tipo = 'INTERES' ) THEN
                    LET vinteres_calculado = vinteres_calculado - vmonto_tot;
                    LET vmovs_cargo_interes = vmovs_cargo_interes + vmonto_tot;
                END IF;
                    
                IF vcuenta_abono IN( SELECT cta_contable FROM sc_ctascontchq WHERE producto = vproducto AND tipo = 'INTERES' ) THEN
                    LET vinteres_calculado = vinteres_calculado + vmonto_tot;
                    LET vmovs_abono_interes = vmovs_abono_interes + vmonto_tot;
                END IF;
                
                LET vcuenta_cargo = '';
                LET vcuenta_abono = '';
                LET vmonto_tot    = 0.00;
            END FOREACH;
            
            -- // OBTIENE SALDOS ACTUALES
            /* ######################################################
            EXECUTE PROCEDURE sp_capintafecha(vcuenta, vfecha_hoy) 
            INTO vcodret1, vcapital_actual, vinteres_actual;
            ###################################################### */
            
            EXECUTE PROCEDURE sp_capintafecha_status(vcuenta, vfecha_hoy) 
            INTO vcodret1, vcapital_actual, vinteres_actual, vestatus_actual;
            
            IF vcodret1 = '100' THEN
                LET vcodret1 = '000';
                LET vcapital_actual = 0.00;
                LET vinteres_actual = 0.00;
                LET vestatus_actual = '';
            END IF;
            
            IF vestatus_actual = '6' AND vproducto <> '5000' THEN
                LET vproducto = '5000';
            END IF;
            
            -- // OBTIENE DIFERENCIAS
            LET vdiferencia_capital = vcapital_actual - vcapital_calculado;
            LET vdiferencia_interes = vinteres_actual - vinteres_calculado;
            
            -- // LLENA TABLA DE TODAS LAS CUENTAS
            INSERT INTO tmp_conciliachq VALUES
            (vfecha_hoy, vcuenta, vproducto, vnum_cte, vgenero, vsucursal, vejecutivo,
             vcapital_anterior, vmovs_cargo_capital, vmovs_abono_capital, vcapital_calculado, vcapital_actual, vdiferencia_capital, 
             vinteres_anterior, vmovs_cargo_interes, vmovs_abono_interes, vinteres_calculado, vinteres_actual, vdiferencia_interes);
            
            -- // LLENA TABLA DE DIFERENCIAS
            IF (vdiferencia_capital != 0.00 OR vdiferencia_interes != 0.00) THEN
                INSERT INTO tmp_conciliachq_dif VALUES
                (vfecha_hoy, vcuenta, vproducto, vnum_cte, vgenero, vsucursal, vejecutivo,
                 vcapital_anterior, vmovs_cargo_capital, vmovs_abono_capital, vcapital_calculado, vcapital_actual, vdiferencia_capital, 
                 vinteres_anterior, vmovs_cargo_interes, vmovs_abono_interes, vinteres_calculado, vinteres_actual, vdiferencia_interes);
                       
                LET vcontador2 = vcontador2 + 1;
            END IF;
            
            LET vcontador1 = vcontador1 + 1;
            LET vcontador3 = vcontador3 + 1;

            IF (vcontador3 >= 1000) THEN
                LET vcontador3 = 0;
                COMMIT WORK;
                BEGIN WORK;
            END IF;
            
            LET vcuenta    = ''; 
            LET vproducto  = '';
            LET vnum_cte   = '';
            LET vgenero    = '';
            LET vsucursal  = '';
            LET vejecutivo = '';
            
            LET vcapital_anterior       = 0.00;
            LET vcapital_calculado      = 0.00;
            LET vmovs_cargo_capital     = 0.00;
            LET vmovs_abono_capital     = 0.00;
            LET vcapital_actual         = 0.00;
            LET vdiferencia_capital     = 0.00;
            
            LET vinteres_anterior       = 0.00;
            LET vinteres_calculado      = 0.00;
            LET vmovs_cargo_interes     = 0.00;
            LET vmovs_abono_interes     = 0.00;
            LET vinteres_actual         = 0.00;
            LET vdiferencia_interes     = 0.00;
            
            LET vestatus_anterior = '';
            LET vestatus_actual = '';
        END FOREACH;
    
    ELSE
    
        FOREACH WITH HOLD
            SELECT chq.cuenta, chq.producto, chq.num_cte, chq.sucursal, noc.ejecutivo
              INTO vcuenta, vproducto, vnum_cte, vsucursal, vejecutivo
              FROM sc_maechq chq,
                   sc_maenoc noc
             WHERE chq.cuenta >= vcuentaini
               --- AND chq.cuenta < vcuentafin
               AND chq.producto = '2000'
               AND ( chq.status_cta <> '2' OR chq.fecha_proceso >= vfecha_hoy )
               AND noc.cuenta = chq.cuenta
               AND noc.fecha_alta < vfecha_actual

            IF vcomienza1 = -1 THEN
                LET vcomienza1 = 0;
                LET ven_transacc = 1; 
                BEGIN WORK;
            END IF;
            
            -- // OBTIENE SALDOS ANTERIORES
            /* ######################################################
            EXECUTE PROCEDURE sp_capintafecha(vcuenta, vfecha_ant) 
            INTO vcodret1, vcapital_anterior, vinteres_anterior;
            ###################################################### */
            
            EXECUTE PROCEDURE sp_capintafecha_status(vcuenta, vfecha_ant) 
            INTO vcodret1, vcapital_anterior, vinteres_anterior, vestatus_anterior;
            
            IF vcodret1 = '100' THEN
                LET vcodret1 = '000';
                LET vcapital_anterior = 0.00;
                LET vinteres_anterior = 0.00;
                LET vestatus_anterior = '0';
            END IF;
            
            LET vcapital_calculado = vcapital_anterior;
            LET vinteres_calculado = vinteres_anterior;
            
            -- // OBTIENE LOS MOVIMIENTOS DE CAPITAL E INTERES
            FOREACH
                SELECT {+INDEX(tmp_concilia idx_concilia)} 
                       cta_cargo, cta_abono, monto_tot
                  INTO vcuenta_cargo, vcuenta_abono, vmonto_tot
                  FROM tmp_concilia
                 WHERE cuenta = vcuenta
                 
                IF vcuenta_cargo IN( SELECT cta_contable FROM sc_ctascontchq WHERE producto = vproducto AND tipo IN('CAPITAL','SOBREGIRO') ) THEN
                    LET vcapital_calculado = vcapital_calculado - vmonto_tot;
                    LET vmovs_cargo_capital = vmovs_cargo_capital + vmonto_tot;
                END IF;
                        
                IF vcuenta_abono IN( SELECT cta_contable FROM sc_ctascontchq WHERE producto = vproducto AND tipo IN('CAPITAL','SOBREGIRO') ) THEN
                    LET vcapital_calculado = vcapital_calculado + vmonto_tot;
                    LET vmovs_abono_capital = vmovs_abono_capital + vmonto_tot;
                END IF;
                                    
                IF vcuenta_cargo IN( SELECT cta_contable FROM sc_ctascontchq WHERE producto = vproducto AND tipo = 'INTERES' ) THEN
                    LET vinteres_calculado = vinteres_calculado - vmonto_tot;
                    LET vmovs_cargo_interes = vmovs_cargo_interes + vmonto_tot;
                END IF;
                    
                IF vcuenta_abono IN( SELECT cta_contable FROM sc_ctascontchq WHERE producto = vproducto AND tipo = 'INTERES' ) THEN
                    LET vinteres_calculado = vinteres_calculado + vmonto_tot;
                    LET vmovs_abono_interes = vmovs_abono_interes + vmonto_tot;
                END IF;
                
                LET vcuenta_cargo = '';
                LET vcuenta_abono = '';
                LET vmonto_tot    = 0.00;
            END FOREACH;
            
            -- // OBTIENE SALDOS ACTUALES
            /* ######################################################
            EXECUTE PROCEDURE sp_capintafecha(vcuenta, vfecha_hoy) 
            INTO vcodret1, vcapital_actual, vinteres_actual;
            ###################################################### */
            
            EXECUTE PROCEDURE sp_capintafecha_status(vcuenta, vfecha_hoy) 
            INTO vcodret1, vcapital_actual, vinteres_actual, vestatus_actual;
            
            IF vcodret1 = '100' THEN
                LET vcodret1 = '000';
                LET vcapital_actual = 0.00;
                LET vinteres_actual = 0.00;
                LET vestatus_actual = '';
            END IF;
            
            IF vestatus_actual = '6' AND vproducto <> '5000' THEN
                LET vproducto = '5000';
            END IF;
            
            -- // OBTIENE DIFERENCIAS
            LET vdiferencia_capital = vcapital_actual - vcapital_calculado;
            LET vdiferencia_interes = vinteres_actual - vinteres_calculado;
            
            -- // LLENA TABLA DE TODAS LAS CUENTAS
            INSERT INTO tmp_conciliachq VALUES
            (vfecha_hoy, vcuenta, vproducto, vnum_cte, vgenero, vsucursal, vejecutivo,
             vcapital_anterior, vmovs_cargo_capital, vmovs_abono_capital, vcapital_calculado, vcapital_actual, vdiferencia_capital, 
             vinteres_anterior, vmovs_cargo_interes, vmovs_abono_interes, vinteres_calculado, vinteres_actual, vdiferencia_interes);
            
            -- // LLENA TABLA DE DIFERENCIAS
            IF (vdiferencia_capital != 0.00 OR vdiferencia_interes != 0.00) THEN
                INSERT INTO tmp_conciliachq_dif VALUES
                (vfecha_hoy, vcuenta, vproducto, vnum_cte, vgenero, vsucursal, vejecutivo,
                 vcapital_anterior, vmovs_cargo_capital, vmovs_abono_capital, vcapital_calculado, vcapital_actual, vdiferencia_capital, 
                 vinteres_anterior, vmovs_cargo_interes, vmovs_abono_interes, vinteres_calculado, vinteres_actual, vdiferencia_interes);
                       
                LET vcontador2 = vcontador2 + 1;
            END IF;
            
            LET vcontador1 = vcontador1 + 1;
            LET vcontador3 = vcontador3 + 1;

            IF (vcontador3 >= 1000) THEN
                LET vcontador3 = 0;
                COMMIT WORK;
                BEGIN WORK;
            END IF;
            
            LET vcuenta    = ''; 
            LET vproducto  = '';
            LET vnum_cte   = '';
            LET vgenero    = '';
            LET vsucursal  = '';
            LET vejecutivo = '';
            
            LET vcapital_anterior       = 0.00;
            LET vcapital_calculado      = 0.00;
            LET vmovs_cargo_capital     = 0.00;
            LET vmovs_abono_capital     = 0.00;
            LET vcapital_actual         = 0.00;
            LET vdiferencia_capital     = 0.00;
            
            LET vinteres_anterior       = 0.00;
            LET vinteres_calculado      = 0.00;
            LET vmovs_cargo_interes     = 0.00;
            LET vmovs_abono_interes     = 0.00;
            LET vinteres_actual         = 0.00;
            LET vdiferencia_interes     = 0.00;
            
            LET vestatus_anterior = '';
            LET vestatus_actual = '';
        END FOREACH;
    
    END IF;

    IF ven_transacc = 1 THEN
        LET ven_transacc = 0;
        COMMIT WORK;
    END IF;
    
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_conciliachq;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_conciliachq_dif;

    END;

    RETURN vcodret1, vcodret2, vcontador1, vcontador2;

END PROCEDURE;
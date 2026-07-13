CREATE PROCEDURE "informix".sp_conciliachq_pba( pempresa CHAR(3) )
RETURNING CHAR(5), CHAR(5), CHAR(50), INTEGER, INTEGER;
    
    DEFINE vcodret1     CHAR(5);
    DEFINE vcodret2     CHAR(5);
    DEFINE vcodret3     CHAR(50);
    DEFINE sql_err      INTEGER;
    DEFINE isam_err     INTEGER;
    DEFINE desc_err     CHAR(50);
    DEFINE vcontador1   INTEGER;
    DEFINE vcontador2   INTEGER;
    DEFINE vcontador3   INTEGER;
    DEFINE vcomienza1   SMALLINT;
    DEFINE ven_transacc SMALLINT;
    
    DEFINE vsql          CHAR(600);
    DEFINE vstmt         CHAR(250);
    DEFINE vfecha_hoy    DATE;
    DEFINE vfecha_ant    DATE;
    DEFINE vpri_hab_mes  DATE;
    DEFINE vfecha_actual DATE;
    DEFINE vproceso      CHAR(11);
    DEFINE vsistema      CHAR(2);
    DEFINE vexiste       INTEGER;
    DEFINE vexistefin    INTEGER;
    DEFINE vusuario      CHAR(10);
    DEFINE vfechaprocsdo DATE;
    
    DEFINE vcuenta      CHAR(20);
    DEFINE vnum_cte     CHAR(20);
    DEFINE vsucursal    CHAR(4);
    DEFINE vejecutivo   CHAR(8);
    DEFINE vproducto    CHAR(4);
    
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
    
    DEFINE vcuentafin           CHAR(20);    
    DEFINE vcuenta_cargo        CHAR(12);  
    DEFINE vcuenta_abono        CHAR(12);  
    DEFINE vmonto_tot           MONEY(14,2);
    DEFINE vexiste_cta          SMALLINT;
    
    LET vcodret1     = '000';
    LET vcodret2     = '000';
    LET vcodret3     = 'PROCESO CONCLUIDO SATISFACTORIAMENTE';
    LET sql_err	     = 0;
    LET isam_err     = 0;
    LET desc_err     = '';
    LET vcontador1   = 0;
    LET vcontador2   = 0;
    LET vcontador3   = 0;
    LET vcomienza1   = -1;
    LET ven_transacc = 0; 
    
    LET vsql          = '';
    LET vstmt         = '';
    LET vfecha_hoy    = ''; 
    LET vfecha_ant    = '';
    LET vpri_hab_mes  = '';
    LET vfecha_actual = '';
    LET vproceso      = 'conciliachq';
    LET vsistema      = '01';
    LET vexiste       = 0;
    LET vexistefin    = 0;
    LET vusuario      = user;
    LET vfechaprocsdo = '';
    
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
    
    LET vcuentafin = '';
    LET vcuenta_cargo   = '';
    LET vcuenta_abono   = '';
    LET vmonto_tot      = 0.00;
    LET vexiste_cta     = 0;
    
    BEGIN
    
    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_conciliachq.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            IF ven_transacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            LET vsql = 'echo "UPDATE bdinteg:sx_contproc '||
                       'SET ejecutivo = '''||vusuario||''','||
                       'status_proc   = '''||'C'||''','||
                       'codret        = '''||vcodret1||''','||
                       'hora_fin      = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
                       'WHERE empresa = '''||pempresa||''' '||
                       'AND proceso   = '''||vproceso||''' '||
                       'AND fecha     = '''||vfecha_hoy||''' '||
                       'AND sistema   = '''||vsistema||''';" > /tmp/horasconcilchq.sql';
            SYSTEM vsql;
            LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horasconcilchq.sql';
            SYSTEM vstmt;
            RETURN vcodret1, vcodret2, vcodret3, vcontador1, vcontador2;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_conciliachq.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // OBTIENE LAS FECHAS DEL SISTEMA
    SELECT fecha_hoy, fecha_ant, pri_hab_mes, fecha_hoy
      INTO vfecha_hoy, vfecha_ant, vpri_hab_mes, vfecha_actual
      FROM sc_fechas
     WHERE empresa = pempresa;
    
    -- // VALIDA LA FECHA DE AYER
    LET vfecha_hoy = vfecha_hoy - 1 UNITS DAY;
    
    CALL sp_valfechabil(vfecha_hoy, '-') 
    RETURNING vcodret1, vfecha_hoy;
    
    -- // VALIDA LA FECHA DE ANTIER
    LET vfecha_ant = vfecha_ant - 1 UNITS DAY;
    
    CALL sp_valfechabil(vfecha_ant, '-') 
    RETURNING vcodret1, vfecha_ant;
    
    -- // VERIFICA SE HAYA ACTUALIZADO LA TABLA DE SALDOS DIARIOS (SEGUNDA PARTE)
    select fecha 
      into vfechaprocsdo
      from bdinteg:sx_contproc
     where empresa = pempresa 
       and proceso = "sdoschqdes"
       and fecha   = vfecha_actual
       and sistema = vsistema
       and status_proc = 'F';
    
    if vfechaprocsdo is null then
        let vcodret1 = "950";
        let vcodret2 = "950";
        
        SELECT descripcion
          INTO vcodret3
          FROM bdinteg:si_codret
         WHERE sistema = vsistema
           AND codigo_retorno = vcodret1;
        
        return vcodret1, vcodret2, vcodret3, vcontador1, vcontador2;
    end if;
     
    -- // GUARDA REGISTRO DE CONTROL EN TABLA DE INTEGRAL
    select count(*)
      into vexiste
      from bdinteg:sx_contproc
     where empresa = pempresa
       and proceso = vproceso
       and fecha   = vfecha_hoy
       and sistema = vsistema;
    
    if vexiste = 0 then
        LET vsql = 'echo " INSERT INTO bdinteg:sx_contproc VALUES '||
                   '('''||pempresa||''', '''||vproceso||''', '''||vfecha_hoy||''', '''||vsistema||''', '''||'I'||''', '''||vusuario||''','||
                   '(SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas), NULL, NULL);" > /tmp/horasconcilchq.sql';
        SYSTEM vsql;
        
        LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horasconcilchq.sql';
        SYSTEM vstmt;
    else
        SELECT count(*)
          INTO vexistefin
          FROM bdinteg:sx_contproc
         WHERE empresa     = pempresa
           AND proceso     = vproceso
           AND fecha       = vfecha_hoy
           AND sistema     = vsistema
           AND status_proc = "F";
           
        IF vexistefin = 0 THEN
            LET vsql = 'echo "UPDATE bdinteg:sx_contproc '||
                       'SET ejecutivo = '''||vusuario||''','||
                       'status_proc   = '''||'I'||''','||
                       'codret        = '''||' '||''','||
                       'hora_fin      = '''||' '||''','||
                       'hora_ini      = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
                       'WHERE empresa = '''||pempresa||''' '||
                       'AND proceso   = '''||vproceso||''' '||
                       'AND fecha     = '''||vfecha_hoy||''' '||
                       'AND sistema   = '''||vsistema||''';" > /tmp/horasconcilchq.sql';
            SYSTEM vsql;
            
            LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horasconcilchq.sql';
            SYSTEM vstmt;
        ELSE
            LET vcodret1 = "958";
            LET vcodret2 = "958";
            
            SELECT descripcion
              INTO vcodret3
              FROM bdinteg:si_codret
             WHERE sistema = vsistema
               AND codigo_retorno = vcodret1;
            
            RETURN vcodret1, vcodret2, vcodret3, vcontador1, vcontador2;
        END IF;
    end if;
      
    -- // OBTIENE EL RANGO DE CUENTAS A PROCESAR
    SELECT valor
      INTO vcuentafin
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = 'CtaIniActuaSdosComp1';
    
    -- // TABLA TEMPORAL DE MOVIMIENTOS
    SELECT { +INDEX(sc_movdia_concil idx_movdiaconc_1),
             +INDEX(bdinteg:si_transacc idx_si_transacc4),
             +INDEX(bdinteg:si_prodtran idx01_prodtran) } 
           mov.cuenta, mov.transacc, mov.monto_tot,
           TRIM(prod.c_ccmayor)||TRIM(prod.c_ccsub)||TRIM(prod.c_ccsubsub)||TRIM(prod.c_ccsssub)||TRIM(prod.c_ccssssub) AS cta_cargo,
           TRIM(prod.a_ccmayor)||TRIM(prod.a_ccsub)||TRIM(prod.a_ccsubsub)||TRIM(prod.a_ccsssub)||TRIM(prod.a_ccssssub) AS cta_abono
      FROM sc_movdia_concil mov,
           bdinteg:si_transacc tran,
           bdinteg:si_prodtran prod
     WHERE mov.fech_alt = vfecha_hoy
       AND mov.cancelad != 'S'
       AND mov.cuenta < vcuentafin
       AND mov.producto <> '1100'
       AND tran.empresa = mov.empresa
       AND tran.numero = mov.transacc
       AND tran.se_contabiliza = 'S'
       AND tran.sistema = '01'
       AND prod.transaccion = tran.numero
       AND prod.producto = mov.producto
       AND prod.sistema = tran.sistema
      INTO TEMP tmp_concilia WITH NO LOG;
      
    CREATE INDEX idx_concilia ON tmp_concilia(cuenta) ONLINE;
    CREATE INDEX idx_concilia2 ON tmp_concilia(cuenta, cta_cargo) ONLINE;
    CREATE INDEX idx_concilia3 ON tmp_concilia(cuenta, cta_abono) ONLINE;
    
    UPDATE STATISTICS HIGH FOR TABLE tmp_concilia(cuenta, cta_cargo, cta_abono);
    
    -- // FOREACH CUENTAS 
    FOREACH WITH HOLD
        SELECT chq.cuenta, chq.producto, chq.num_cte, chq.sucursal, noc.ejecutivo
          INTO vcuenta, vproducto, vnum_cte, vsucursal, vejecutivo
          FROM sc_maechq chq,
               sc_maenoc noc
         WHERE chq.empresa = pempresa
           AND chq.cuenta < vcuentafin
           AND chq.producto <> '1100'
           AND ( chq.status_cta <> '2' OR chq.fecha_proceso >= vfecha_hoy )
           AND noc.empresa = chq.empresa
           AND noc.cuenta = chq.cuenta
           AND noc.fecha_alta < vfecha_actual
           
        IF vcomienza1 = -1 THEN
            LET vcomienza1 = 0;
            LET ven_transacc = 1; 
            BEGIN WORK;
        END IF;
        
        -- // OBTIENE SALDOS ANTERIORES
        EXECUTE PROCEDURE sp_capintafecha(vcuenta, vfecha_ant) 
        INTO vcodret1, vcapital_anterior, vinteres_anterior;
        
        IF vcodret1 = '100' THEN
            LET vcapital_anterior = 0.00;
            LET vinteres_anterior = 0.00;
            LET vcodret1 = '000';
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
        EXECUTE PROCEDURE sp_capintafecha(vcuenta, vfecha_hoy) 
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
        SELECT COUNT(*)
          INTO vexiste_cta
          FROM conciliachq
         WHERE cuenta = vcuenta;
         
        IF vexiste_cta > 0 THEN
            UPDATE conciliachq
               SET fecha              = vfecha_hoy,
                   capital_anterior   = vcapital_anterior,
                   movs_cargo         = vmovs_cargo_capital,
                   movs_abono         = vmovs_abono_capital,
                   capital_calculado  = vcapital_calculado,
                   capital_actual     = vcapital_actual,
                   diferencia_capital = vdiferencia_capital,
                   interes_anterior   = vinteres_anterior,
                   movs_cargo_interes = vmovs_cargo_interes,
                   movs_abono_interes = vmovs_abono_interes,
                   interes_calculado  = vinteres_calculado,
                   interes_actual     = vinteres_actual,
                   diferencia_interes = vdiferencia_interes
             WHERE cuenta = vcuenta;
        ELSE
            INSERT INTO conciliachq VALUES
            (vfecha_hoy, vcuenta, vproducto, vnum_cte, vsucursal, vejecutivo,
             vcapital_anterior, vmovs_cargo_capital, vmovs_abono_capital, vcapital_calculado, vcapital_actual, vdiferencia_capital, 
             vinteres_anterior, vmovs_cargo_interes, vmovs_abono_interes, vinteres_calculado, vinteres_actual, vdiferencia_interes);
        END IF;
        
        -- // LLENA TABLA DE DIFERENCIAS
        IF (vdiferencia_capital != 0.00 OR vdiferencia_interes != 0.00) THEN
            INSERT INTO conciliachq_dif VALUES
            (vfecha_hoy, vcuenta, vproducto, vnum_cte, vsucursal, vejecutivo,
             vcapital_anterior, vmovs_cargo_capital, vmovs_abono_capital, vcapital_calculado, vcapital_actual, vdiferencia_capital, 
             vinteres_anterior, vmovs_cargo_interes, vmovs_abono_interes, vinteres_calculado, vinteres_actual, vdiferencia_interes); 
             
            LET vcontador2 = vcontador2 + 1;
        END IF;
        
        LET vcontador1 = vcontador1 + 1;
        LET vcontador3 = vcontador3 + 1;
        
        IF vcontador3 >= 1000 THEN
            LET vcontador3 = 0;
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
        
        LET vcuenta_cargo   = '';
        LET vcuenta_abono   = '';
        LET vmonto_tot      = 0.00;
        LET vexiste_cta     = 0;
    END FOREACH;
    
    IF ven_transacc = 1 THEN
        LET ven_transacc = 0;
        COMMIT WORK;
    END IF;
    
	LET vsql = 'echo "UPDATE bdinteg:sx_contproc '||
               'SET ejecutivo = '''||vusuario||''','||
               'status_proc   = '''||'F'||''','||
               'codret        = '''||vcodret1||''','||
               'hora_fin      = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
               'WHERE empresa = '''||pempresa||''' '||
               'AND proceso   = '''||vproceso||''' '||
               'AND fecha     = '''||vfecha_hoy||''' '||
               'AND sistema   = '''||vsistema||''';" > /tmp/horasconcilchq.sql';
    SYSTEM vsql;
    
    LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horasconcilchq.sql';
    SYSTEM vstmt;
           
    END;
    
    RETURN vcodret1, vcodret2, vcodret3, vcontador1, vcontador2;
    
END PROCEDURE;
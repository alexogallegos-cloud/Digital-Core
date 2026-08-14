CREATE PROCEDURE "informix".sp_conciliachqcomp1_pba( pempresa CHAR(3) )
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
    DEFINE vcomienza2   SMALLINT;
    DEFINE ven_transacc SMALLINT;
    
    DEFINE vsql          CHAR(600);
    DEFINE vstmt         CHAR(250);
    DEFINE vfecha        CHAR(8);
    DEFINE vfecha_hoy    DATE;
    DEFINE vfecha_ant    DATE;
    DEFINE vpri_hab_mes  DATE;
    DEFINE vfecha_actual DATE;
    DEFINE vproceso      CHAR(16);
    DEFINE vsistema      CHAR(2);
    DEFINE vexiste       INTEGER;
    DEFINE vexistefin    INTEGER;
    DEFINE vusuario      CHAR(10);
    DEFINE vfechaproc    DATE;
    DEFINE vfechaprocsdo DATE;
    
    DEFINE vminaniomes  CHAR(6);
    DEFINE vmaxaniomes  CHAR(6);
    DEFINE vcuenta      CHAR(20);
    DEFINE vnum_cte     CHAR(20);
    DEFINE vsucursal    CHAR(4);
    DEFINE vejecutivo   CHAR(8);
    DEFINE vproducto    CHAR(4);
    DEFINE wproducto    CHAR(4);
    
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
    LET vcomienza2   = -1;
    LET ven_transacc = 0; 
    
    LET vsql          = '';
    LET vstmt         = '';
    LET vfecha        = '';
    LET vfecha_hoy    = ''; 
    LET vfecha_ant    = '';
    LET vpri_hab_mes  = '';
    LET vfecha_actual = '';
    LET vproceso      = 'conciliachqcomp1';
    LET vsistema      = '01';
    LET vexiste       = 0;
    LET vexistefin    = 0;
    LET vusuario      = user;
    LET vfechaproc    = '';
    LET vfechaprocsdo = '';
    
    LET vminaniomes  = '';
    LET vmaxaniomes  = '';
    LET vcuenta      = ''; 
    LET vproducto    = '';
    LET wproducto    = '';
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
    
    LET vcuentaini = '';
    LET vcuentafin = '';
    
    BEGIN

    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_conciliachqcomp1.err";
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
                       'AND sistema   = '''||vsistema||''';" > /tmp/horasconcilchq1.sql';
            SYSTEM vsql;
            LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horasconcilchq1.sql';
            SYSTEM vstmt;
            RETURN vcodret1, vcodret2, vcodret3, vcontador1, vcontador2;
        END IF;
    END EXCEPTION;
    
    ON EXCEPTION IN (-668)
        LET vcodret1 = '668';
        LET vcodret2 = '668';
        LET vcodret3 = 'PROBLEMAS EN LA DESCARGA DE ARCHIVOS VERIFIQUE';
    END EXCEPTION WITH RESUME;

    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_conciliachqcomp1.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 5;
    
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
    
    -- // VERIFICA SE HAYA EFECTUADO EL PASO DE MOVS A HISTORICO
    select fecha 
      into vfechaproc
      from sc_contproc
     where empresa = pempresa 
       and proceso = "pasomovshist"
       and fecha   = vfecha_hoy;

    if vfechaproc is null then
        let vcodret1 = "953";
        let vcodret2 = "953";
        
        SELECT descripcion
          INTO vcodret3
          FROM bdinteg:si_codret
         WHERE sistema = vsistema
           AND codigo_retorno = vcodret1;
        
        return vcodret1, vcodret2, vcodret3, vcontador1, vcontador2;
    end if;
    
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
    
    -- // Verifica se haya iniciado el proceso principal
    select {+INDEX (bdicheq:sc_contproc idx_contproc2)} fecha 
      into vfechaproc
      from sc_contproc
     where empresa = pempresa 
       and proceso = "inicio_conciliachq";
       
    if vfechaproc <> vfecha_hoy then
        let vcodret1 = "977";        
        return vcodret1, vcodret2, vcodret3, vcontador1, vcontador2;
    end if
     
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
                   '(SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas), NULL, NULL);" > /tmp/horasconcilchq1.sql';
        SYSTEM vsql;
        
        LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horasconcilchq1.sql';
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
                       'AND sistema   = '''||vsistema||''';" > /tmp/horasconcilchq1.sql';
            SYSTEM vsql;
            
            LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horasconcilchq1.sql';
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
      INTO vcuentaini
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = 'CtaIniConcilChqComp1'; 
       
    SELECT valor
      INTO vcuentafin
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = 'CtaIniConcilChqComp2'; 
    
    -- // TABLA TEMPORAL DE MOVIMIENTOS
    ---SELECT {+INDEX(sc_movhis idx_movhisnew6), +INDEX(bdinteg:si_transacc idx_si_transacc4), +INDEX(bdinteg:si_prodtran idx01_prodtran)} 
    SELECT {+INDEX(sc_movhis idx_movhisnew4), +INDEX(bdinteg:si_transacc idx_si_transacc4), +INDEX(bdinteg:si_prodtran idx01_prodtran)} 
           mov.cuenta, mov.transacc, mov.monto_tot,
           TRIM(prod.c_ccmayor)||TRIM(prod.c_ccsub)||TRIM(prod.c_ccsubsub)||TRIM(prod.c_ccsssub)||TRIM(prod.c_ccssssub) AS cta_cargo,
           TRIM(prod.a_ccmayor)||TRIM(prod.a_ccsub)||TRIM(prod.a_ccsubsub)||TRIM(prod.a_ccsssub)||TRIM(prod.a_ccssssub) AS cta_abono
      FROM sc_movhis mov,
           bdinteg:si_transacc tran,
           bdinteg:si_prodtran prod
     ---WHERE mov.fech_alt = vfecha_hoy
     WHERE mov.empresa = '001'
       AND mov.fech_alt = vfecha_hoy
       AND mov.cancelad != 'S'
       AND mov.cuenta BETWEEN vcuentaini and vcuentafin
       ---AND mov.cuenta >= vcuentaini
       ---AND mov.cuenta < vcuentafin
       AND mov.producto <> '1100'
       AND tran.empresa = mov.empresa
       AND tran.numero = mov.transacc
       AND tran.se_contabiliza = 'S'
       AND tran.sistema = '01'
       AND prod.transaccion = tran.numero
       AND prod.producto = mov.producto
       AND prod.sistema = tran.sistema
      INTO TEMP tmp_concilia WITH NO LOG;
      
    ---CREATE INDEX idx_concilia ON tmp_concilia(cuenta) ONLINE;
    CREATE INDEX idx_concilia2 ON tmp_concilia(cuenta, cta_cargo) ONLINE;
    CREATE INDEX idx_concilia3 ON tmp_concilia(cuenta, cta_abono) ONLINE;
    
    ---UPDATE STATISTICS HIGH FOR TABLE tmp_concilia(cuenta, cta_cargo, cta_abono);
    
    -- // FOREACH CUENTAS 
    FOREACH WITH HOLD
        SELECT {+INDEX(sc_maechq idx_sc_maechq), +INDEX(sc_maenoc idx_sc_maenoc2)} chq.cuenta, chq.producto, chq.num_cte, chq.sucursal, noc.ejecutivo
          INTO vcuenta, vproducto, vnum_cte, vsucursal, vejecutivo
          FROM sc_maechq chq,
               sc_maenoc noc
         ---WHERE chq.empresa = pempresa
         WHERE chq.cuenta BETWEEN vcuentaini and vcuentafin
           ---AND chq.cuenta >= vcuentaini
           ---AND chq.cuenta < vcuentafin
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
        
        -- // RESTA CAPITAL 
        SELECT {+INDEX(tmp_concilia idx_concilia2)} 
               NVL(SUM(tmp.monto_tot),0.00)
          INTO vmovs_cargo_capital
          FROM tmp_concilia tmp
         WHERE tmp.cuenta = vcuenta
           AND tmp.cta_cargo IN( SELECT {+INDEX(sc_ctascontchq idx_ctascont)} 
                                        cta_contable 
                                   FROM sc_ctascontchq 
                                  WHERE tipo IN('CAPITAL', 'SOBREGIRO') );

        LET vcapital_calculado = vcapital_calculado - vmovs_cargo_capital;
        
        -- // SUMA CAPITAL 
        SELECT {+INDEX(tmp_concilia idx_concilia3)} 
               NVL(SUM(tmp.monto_tot),0.00)
          INTO vmovs_abono_capital
          FROM tmp_concilia tmp
         WHERE tmp.cuenta = vcuenta
           AND tmp.cta_abono IN( SELECT {+INDEX(sc_ctascontchq idx_ctascont)} 
                                        cta_contable 
                                   FROM sc_ctascontchq 
                                  WHERE tipo IN('CAPITAL', 'SOBREGIRO') );

        LET vcapital_calculado = vcapital_calculado + vmovs_abono_capital;
        
        -- // RESTA INTERES
        SELECT {+INDEX(tmp_concilia idx_concilia2)} 
               NVL(SUM(tmp.monto_tot),0.00)
          INTO vmovs_cargo_interes
          FROM tmp_concilia tmp
         WHERE tmp.cuenta = vcuenta
           AND tmp.cta_cargo IN( SELECT {+INDEX(sc_ctascontchq idx_ctascont)} 
                                        cta_contable 
                                   FROM sc_ctascontchq 
                                  WHERE tipo = 'INTERES' );

        LET vinteres_calculado = vinteres_calculado - vmovs_cargo_interes;
        
        -- // SUMA INTERES
        SELECT {+INDEX(tmp_concilia idx_concilia3)} 
               NVL(SUM(tmp.monto_tot),0.00)
          INTO vmovs_abono_interes
          FROM tmp_concilia tmp
         WHERE tmp.cuenta = vcuenta
           AND tmp.cta_abono IN( SELECT {+INDEX(sc_ctascontchq idx_ctascont)} 
                                        cta_contable 
                                   FROM sc_ctascontchq 
                                  WHERE tipo = 'INTERES' );

        LET vinteres_calculado = vinteres_calculado + vmovs_abono_interes;
        
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
        INSERT INTO conciliachq VALUES
        (vfecha_hoy, vcuenta, vproducto, vnum_cte, vsucursal, vejecutivo,
         vcapital_anterior, vmovs_cargo_capital, vmovs_abono_capital, vcapital_calculado, vcapital_actual, vdiferencia_capital, 
         vinteres_anterior, vmovs_cargo_interes, vmovs_abono_interes, vinteres_calculado, vinteres_actual, vdiferencia_interes);
        
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
        
        IF vcontador3 >= 5000 THEN
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
               'AND sistema   = '''||vsistema||''';" > /tmp/horasconcilchq1.sql';
    SYSTEM vsql;
    
    LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horasconcilchq1.sql';
    SYSTEM vstmt;
           
    END;

    RETURN vcodret1, vcodret2, vcodret3, vcontador1, vcontador2;

END PROCEDURE;
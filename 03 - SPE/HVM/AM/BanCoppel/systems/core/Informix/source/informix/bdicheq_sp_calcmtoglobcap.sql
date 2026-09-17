CREATE PROCEDURE "informix".sp_calcmtoglobcap(pempresa CHAR(3))
RETURNING CHAR(5), CHAR(5), CHAR(50);
    
    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE desc_err         CHAR(50);
    DEFINE vcodret1         CHAR(5);
    DEFINE vcodret2         CHAR(5);
    DEFINE vcodret3         CHAR(50);
    
    DEFINE vfecha_hoy       DATE;
    DEFINE vfecha_ant       DATE;
    DEFINE vpri_dia_mes     DATE;
    DEFINE vfechaproc       DATE;
    DEFINE vfecha_ini       DATE;
    DEFINE vfecha_fin       DATE;
    DEFINE vaniomesant      CHAR(6);
    DEFINE vaniomes         CHAR(6);
    
    DEFINE vexiste          CHAR(6);
    DEFINE vprodcrec        CHAR(4);
    DEFINE vno_transacc     INTEGER;
    DEFINE vtransacc        CHAR(4);
    DEFINE vmonto_transacc  MONEY(18,2);
    DEFINE vmonto_mes       MONEY(18,2);
    DEFINE vperiodo         CHAR(6);
    DEFINE vmonto           MONEY(18,2);
    DEFINE wveces           SMALLINT;
    DEFINE vmonto_glob_cap  MONEY(18,2);
    DEFINE vmesant          CHAR(6);
    DEFINE vfechconmovhis    CHAR(10);
    DEFINE vfechconmovhisold CHAR(10);
    
    LET sql_err	 = 0;
    LET isam_err = 0;
    LET desc_err = '';
    LET vcodret1 = '000';
    LET vcodret2 = '000';
    LET vcodret3 = '';
    
    LET vfecha_hoy   = ''; 
    LET vfecha_ant   = ''; 
    LET vpri_dia_mes = '';
    LET vfechaproc   = '';
    LET vfecha_ini   = '';
    LET vfecha_fin   = '';
    
    LET vexiste         = '';
    LET vprodcrec       = '';
    LET vno_transacc    = 0;
    LET vtransacc       = '';
    LET vmonto_transacc = 0.00;
    LET vmonto_mes      = 0.00;
    LET vperiodo        = '';
    LET vmonto          = 0.00;
    LET wveces          = 0;
    LET vmonto_glob_cap = 0.00;
    LET vmesant         = '';
    LET vfechconmovhis    = '';
    LET vfechconmovhisold = '';
    
    BEGIN

    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_calcmtoglobcap.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            RETURN vcodret1, vcodret2, vcodret3;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_calcmtoglobcap.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // OBTIENE LAS FECHAS DEL SISTEMA
    SELECT fecha_hoy, fecha_ant, pri_dia_mes
      INTO vfecha_hoy, vfecha_ant, vpri_dia_mes
      FROM sc_fechas
     WHERE empresa = pempresa;
     
    -- // Verifica se haya efectuado el paso de movs a historico
    SELECT fecha 
      INTO vfechaproc
      FROM sc_contproc
     WHERE empresa = pempresa 
       AND proceso = "pasomovshist"
       AND fecha = vfecha_ant;
       
    IF vfechaproc is null THEN
        LET vcodret1 = '953';
        LET vcodret2 = '953';
        
        SELECT descripcion
          INTO vcodret3
          FROM bdinteg:si_codret
         WHERE codigo_retorno = '953'
           AND sistema = '01';
           
        RETURN vcodret1, vcodret2, vcodret3;
    END IF;
      
    LET vfecha_ini = vpri_dia_mes - 1 UNITS MONTH;
    LET vfecha_fin = vpri_dia_mes - 1 UNITS DAY;
    
    LET vaniomesant = YEAR(vfecha_ini) || LPAD(MONTH(vfecha_ini), 2, '0');
    LET vaniomes = YEAR(vfecha_hoy) || LPAD(MONTH(vfecha_hoy), 2, '0');
    
    SELECT periodo
      INTO vexiste
      FROM sc_corresp_limite
     WHERE periodo = vaniomes;
    
    IF vexiste = vaniomes THEN
        LET vcodret1 = '958';
        LET vcodret2 = '958';
        
        SELECT descripcion
          INTO vcodret3
          FROM bdinteg:si_codret
         WHERE codigo_retorno = '958'
           AND sistema = '01';
           
        RETURN vcodret1, vcodret2, vcodret3;
    END IF;
    
    SELECT valor
      INTO vprodcrec
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = 'PRODCREC';
    
    SELECT valor 
      INTO vfechconmovhis
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = 'fechcon_movhis';
       
    SELECT valor 
      INTO vfechconmovhisold
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = 'FechIniCon_movhis_ol';
       
    FOREACH         
        SELECT {+INDEX(sc_movhis_old idx_movhisnew6_old)} 
               transacc, COUNT(*), SUM(monto_tot) 
          INTO vtransacc, vno_transacc, vmonto_transacc
          FROM sc_movhis_old
         WHERE fech_alt BETWEEN vfecha_ini AND vfecha_fin
           AND fech_alt >= vfechconmovhisold
           AND fech_alt < vfechconmovhis
           AND cancelad <> 'S'
           AND ( 
                (transacc IN(SELECT transaccion FROM sc_transacc_captglobal WHERE descripcion NOT IN('DEPOSITO A CUENTA','ABONO SPEI'))) OR 
                (transacc IN(SELECT transaccion FROM sc_transacc_captglobal WHERE descripcion = 'ABONO SPEI') AND cuenta NOT IN(SELECT cuenta FROM sc_ctas_sin_corresp WHERE cliente = 'BANCOPPEL')) OR 
                (transacc IN(SELECT transaccion FROM sc_transacc_captglobal WHERE descripcion = 'DEPOSITO A CUENTA') AND producto <> vprodcrec) 
               )
         GROUP BY transacc
     
        INSERT INTO sc_corresp_monto_mes VALUES (vaniomesant, vtransacc, vno_transacc, vmonto_transacc);
        
        LET vtransacc = '';
        LET vno_transacc = 0;
        LET vmonto_transacc = 0.00;
    END FOREACH;
    
    FOREACH         
        SELECT {+INDEX(sc_movhis idx_movhisnew6)} 
               transacc, COUNT(*), SUM(monto_tot) 
          INTO vtransacc, vno_transacc, vmonto_transacc
          FROM sc_movhis
         WHERE fech_alt BETWEEN vfecha_ini AND vfecha_fin
           AND fech_alt >= vfechconmovhis
           AND cancelad <> 'S'
           AND ( 
                (transacc IN(SELECT transaccion FROM sc_transacc_captglobal WHERE descripcion NOT IN('DEPOSITO A CUENTA','ABONO SPEI'))) OR 
                (transacc IN(SELECT transaccion FROM sc_transacc_captglobal WHERE descripcion = 'ABONO SPEI') AND cuenta NOT IN(SELECT cuenta FROM sc_ctas_sin_corresp WHERE cliente = 'BANCOPPEL')) OR 
                (transacc IN(SELECT transaccion FROM sc_transacc_captglobal WHERE descripcion = 'DEPOSITO A CUENTA') AND producto <> vprodcrec) 
               )
         GROUP BY transacc
     
        INSERT INTO sc_corresp_monto_mes VALUES (vaniomesant, vtransacc, vno_transacc, vmonto_transacc);
        
        LET vtransacc = '';
        LET vno_transacc = 0;
        LET vmonto_transacc = 0.00;
    END FOREACH;
    
    SELECT SUM(monto)
      INTO vmonto_mes
      FROM sc_corresp_monto_mes
     WHERE periodo = vaniomesant;
     
    INSERT INTO sc_corresp_monto VALUES (vaniomesant, vmonto_mes);
    
    LET wveces = 1;
    LET vmonto_glob_cap = 0.00;
    
    FOREACH
        SELECT periodo, monto
          INTO vperiodo, vmonto
          FROM sc_corresp_monto
         ORDER BY periodo DESC
        
        IF wveces <= 12 THEN
            LET vmonto_glob_cap = vmonto_glob_cap + vmonto;
        ELSE
            EXIT FOREACH;
        END IF;
        
        LET wveces = wveces + 1;
        LET vperiodo = '';
        LET vmonto = 0.00;
    END FOREACH
    
    LET vmonto_glob_cap = vmonto_glob_cap / 12;
    
    INSERT INTO sc_corresp_limite VALUES (vaniomes, vmonto_glob_cap);
    
    UPDATE sc_param_corresp 
       SET valor = vmonto_glob_cap,
           fecha_insert = vfecha_hoy
     WHERE codparam = '001'
       AND empresa = pempresa;
       
    LET vcodret3 = 'EL PROCESO SE REALIZO SATISFACTORIAMENTE';

    END;

    RETURN vcodret1, vcodret2, vcodret3;

END PROCEDURE;
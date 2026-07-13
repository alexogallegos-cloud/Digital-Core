CREATE PROCEDURE "informix".sp_movs_mayores_diezmil(pempresa CHAR(3))
RETURNING CHAR(5), CHAR(5), INTEGER;

    DEFINE vsql CHAR(300);
    DEFINE vfecha CHAR(8);
    DEFINE vtel1, vtel2, vtel3 CHAR(13);
    DEFINE vtransacc, vsucursal, vsuc_cta CHAR(4);
    DEFINE vcodret1, vcodret2, vext CHAR(5);
    DEFINE vmincta, vmaxcta, vcuenta, vnum_cte, vexiste char(20); 
    DEFINE vmonto DECIMAL(18,2);
    DEFINE ven_transacc SMALLINT;
    DEFINE vfecha_hoy, vfecha_ant, vfech_alt DATE;
    DEFINE sql_err, isam_err, vcontador1, vnum_serial , vregistro INTEGER;
    
    LET vcodret1     = '000';
    LET vcodret2     = '000';
    LET sql_err	     = 0;
    LET isam_err     = 0;
    LET vcontador1   = -1;
    LET ven_transacc = 0; 
    
    LET vexiste    = '';
    LET vfecha_hoy = '';
    LET vfecha_ant = '';
    LET vmincta    = '';
    LET vmaxcta    = '';
    LET vfecha     = '';
    LET vsql       = '';
    
    LET vregistro = 0;
    LET vnum_serial = '';
    LET vcuenta = ''; 
    LET vsuc_cta = '';
    LET vtransacc = ''; 
    LET vmonto = 0.00; 
    LET vsucursal = ''; 
    LET vfech_alt = ''; 
    LET vnum_cte = '';
    LET vtel1 = '';
    LET vtel2 = '';
    LET vtel3 = '';
    LET vext = '';
    
    BEGIN

    ON EXCEPTION SET sql_err, isam_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_movs_mayores_diezmil.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            IF ven_transacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcodret1, vcodret2, vcontador1;
        END IF;
    END EXCEPTION;

    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_movs_mayores_diezmil.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    
    SELECT fecha_hoy, fecha_ant
      INTO vfecha_hoy, vfecha_ant
      FROM sc_fechas
     WHERE empresa = pempresa;
     
    SELECT proceso
      INTO vexiste
      FROM bdinteg:sx_contproc
     WHERE proceso = 'PasaMovsHist'
       AND fecha = vfecha_hoy
       AND sistema = '01'
       AND status_proc = 'F';
       
    IF vexiste is null OR vexiste = '' THEN 
        LET vcodret1 = '953';
        RETURN vcodret1, vcodret2, vcontador1;
    END IF;
     
    IF WEEKDAY(vfecha_ant) = 1 THEN
        TRUNCATE TABLE sc_movs_mayor_diezmil;
    END IF;
    
    SELECT MIN(cuenta), MAX(cuenta)
      INTO vmincta, vmaxcta
      FROM sc_movhis;
      
    SELECT {+INDEX(sc_movhis idx_movhisnew4)}
           num_serial
      FROM sc_movhis
     WHERE empresa = pempresa
       AND cuenta = '16000000012'
       AND fech_alt = vfecha_ant
       AND cancelad <> 'S'
       AND transacc = '0202'
    UNION ALL 
    SELECT {+INDEX(sc_movhis idx_movhisnew4)}
           num_serial
      FROM sc_movhis
     WHERE empresa = pempresa
       AND cuenta = '16000000039'
       AND fech_alt = vfecha_ant
       AND cancelad <> 'S'
       AND transacc = '1133'
      INTO TEMP tmp_movscoppel WITH NO LOG;
    CREATE INDEX idx_tmpmovscoppel ON tmp_movscoppel(num_serial) ONLINE;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_movscoppel;
      
    SELECT {+INDEX(sc_movhis idx_movhisnew4)}
           mov.num_serial, mov.cuenta, mov.transacc, mov.monto_tot, mov.sucursal, mov.fech_alt, tran.descripcion
      FROM sc_movhis mov,
           bdinteg:si_transacc tran
     WHERE mov.empresa = pempresa
       AND mov.cuenta BETWEEN vmincta AND vmaxcta
       AND mov.fech_alt = vfecha_ant
       AND mov.cancelad <> 'S'
       AND mov.transacc = tran.numero
       AND mov.monto_tot > 10000.00
       AND mov.num_serial NOT IN(SELECT num_serial FROM tmp_movscoppel)
       AND tran.empresa = mov.empresa
       AND tran.numero = mov.transacc
       AND tran.naturaleza IN('A', 'C')       
      INTO TEMP tmp_movtos WITH NO LOG;
    CREATE INDEX idx_tmpmovtos ON tmp_movtos(cuenta) ONLINE;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_movtos;
    
    SELECT cuenta, num_cte, sucursal as suc_cta
      FROM sc_maechq
     WHERE empresa = pempresa
       AND cuenta IN(SELECT cuenta FROM tmp_movtos)
      INTO TEMP tmp_clientes WITH NO LOG;
    CREATE INDEX idx_tmpctes ON tmp_clientes(num_cte) ONLINE;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_clientes;  
    
    /* ###########################################################################################
    SELECT numcte, secuencia, telefono1, telefono2, telefono3, extension
      FROM bdinteg:si_direcciones_actual
     WHERE numcte IN(SELECT num_cte FROM tmp_clientes)
      INTO TEMP tmp_si_direcciones_actual WITH NO LOG;
    CREATE INDEX idx_tmpsidirecc ON tmp_si_direcciones_actual(numcte) ONLINE;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_si_direcciones_actual;  
    ########################################################################################### */
    
    UPDATE STATISTICS MEDIUM FOR TABLE sc_movs_mayor_diezmil;
      
    FOREACH WITH HOLD
        SELECT num_serial, cuenta, transacc, monto_tot, sucursal, fech_alt
          INTO vnum_serial, vcuenta, vtransacc, vmonto, vsucursal, vfech_alt
          FROM tmp_movtos 
          
        IF vcontador1 = -1 THEN
            LET vcontador1 = 0;
            LET ven_transacc = 1; 
            BEGIN WORK;
        END IF;
         
        SELECT num_cte, suc_cta 
          INTO vnum_cte, vsuc_cta
          FROM tmp_clientes
         WHERE cuenta = vcuenta;
           
        SELECT LIMIT 1 NVL(tel1.telefono, ' '), NVL(tel2.telefono, ' '), NVL(tel3.telefono, ' '), NVL(tel3.extension, ' ')
          INTO vtel1, vtel2, vtel3, vext
          FROM bdicheq:sc_maechq mae
          INNER JOIN bdinteg:si_cliente sicte ON ( sicte.numcte = mae.num_cte )
          left outer join bdinteg:si_telefonos_actual tel1 on ( tel1.numcte = mae.num_cte and tel1.tipo_tel = 1 )
          left outer join bdinteg:si_telefonos_actual tel2 on ( tel2.numcte = mae.num_cte and tel2.tipo_tel = 2 )
          left outer join bdinteg:si_telefonos_actual tel3 on ( tel3.numcte = mae.num_cte and tel3.tipo_tel = 3 )
         WHERE mae.num_cte = vnum_cte;
           
        SELECT NVL(MAX(registro), 0) + 1
          INTO vregistro
          FROM sc_movs_mayor_diezmil;
    
        INSERT INTO sc_movs_mayor_diezmil VALUES
        (vregistro, vsucursal, vnum_cte, vcuenta, vsuc_cta, vfech_alt, vtransacc, vmonto, vtel1, vtel2, vtel3, vext);
        
        LET vcontador1 = vcontador1 + 1;
        
        COMMIT WORK;
        BEGIN WORK;
        
        LET vregistro = 0;
        LET vnum_serial = '';
        LET vcuenta = ''; 
        LET vtransacc = ''; 
        LET vmonto = 0.00; 
        LET vsucursal = ''; 
        LET vfech_alt = ''; 
        LET vnum_cte = '';
        LET vsuc_cta = '';
        LET vtel1 = '';
        LET vtel2 = '';
        LET vtel3 = '';
        LET vext = '';
    END FOREACH;
    
    IF ven_transacc = 1 THEN
        COMMIT WORK;
        LET ven_transacc = 0;
    END IF;
    
    IF WEEKDAY(vfecha_ant) = 0 THEN
        UPDATE STATISTICS MEDIUM FOR TABLE sc_movs_mayor_diezmil;
        
        LET vfecha = TO_CHAR(vfecha_hoy, '%d%m%Y');
        
        LET vsql = '';
        LET vsql = 'echo "UNLOAD TO /resplogifx/conciliachq/movtos_mayores_diezmil_'||vfecha||'.txt'||
                   ' SELECT sucursal,numcte,cuenta,suc_cta,fecha_transacc,transaccion,monto_transacc,telefono1,telefono2,telefono3,extension'||
                   ' FROM sc_movs_mayor_diezmil ORDER BY sucursal,numcte,cuenta;" > /resplogifx/conciliachq/movs.sql';
        SYSTEM vsql;
        LET vsql = '';
        --- LET vsql = "dbaccess bdicheq /resplogifx/conciliachq/movs.sql"; 
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/movs.sql"; 
        SYSTEM vsql;
        LET vsql = '';
    END IF;
    
    END;

    RETURN vcodret1, vcodret2, vcontador1;

END PROCEDURE;
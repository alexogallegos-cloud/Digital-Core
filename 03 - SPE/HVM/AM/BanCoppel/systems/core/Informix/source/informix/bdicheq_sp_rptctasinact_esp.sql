CREATE PROCEDURE "informix".sp_rptctasinact_esp( pempresa char(3), pfechaini date, pfechafin date )
RETURNING CHAR(5), CHAR(5), CHAR(50);
     
    DEFINE vcodret1             char(5);
    DEFINE vcodret2             char(5);
    DEFINE vcodret3             char(50);
    DEFINE sql_err              integer;
    DEFINE isam_err             integer;
    DEFINE desc_err             char(50);
    DEFINE vcontador1           integer;
    DEFINE vcontador2           integer;
    DEFINE vcontador3           integer;
    DEFINE ven_transacc         smallint;
    DEFINE vcomienza            smallint;
    
    DEFINE vfechconmovhis       char(10);
    DEFINE vfechconmovhisold    char(10);
    
    DEFINE vcuenta              CHAR(20);
    DEFINE vnumcte              CHAR(20);
    DEFINE vproducto            CHAR(4);
    DEFINE vsucursal            CHAR(4);
    DEFINE vsaldo               DECIMAL(18,2);
    DEFINE vnombre              CHAR(104);
    DEFINE vtel_casa            CHAR(13);
    DEFINE vtel_cel             CHAR(13);
    DEFINE vtel_ofi             CHAR(13);
    DEFINE vcorreo              CHAR(60);
    
    LET vcodret1     = "000";               
    LET vcodret2     = '000';
    LET vcodret3     = 'PROCESO CONCLUIDO SATISFACTORIAMENTE';
    LET sql_err      = 0;                   
    LET isam_err     = 0;
    LET desc_err     = '';
    LET vcontador1   = 0;                   
    LET vcontador2   = 0;
    LET vcontador3   = 0;
    LET ven_transacc = 0;                   
    LET vcomienza    = -1;  
       
    LET vfechconmovhis    = '';
    LET vfechconmovhisold = '';
    
    LET vcuenta   = '';
    LET vnumcte   = '';
    LET vproducto = '';
    LET vsucursal = '';
    LET vsaldo    = 0.00;
    LET vnombre   = '';
    LET vtel_casa = '';
    LET vtel_cel  = '';
    LET vtel_ofi  = '';
    LET vcorreo   = '';
    
    BEGIN

    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_rptctasinact_esp.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            IF ven_transacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcodret1, vcodret2, vcodret3;
        END IF;
    END EXCEPTION;

    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_rptctasinact_esp.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    -- // TABLA PARA REPORTE
    CREATE TEMP TABLE sc_rptctasinactivas_tmp
    ( 
      producto   CHAR(4), 
      cliente    CHAR(20),
      cuenta     CHAR(20),
      tel_casa   CHAR(13),
      tel_cel    CHAR(13),
      tel_ofi    CHAR(13),
      email      CHAR(60),
      sucursal   CHAR(4),
      sdo_cuenta DECIMAL(18,2)
    ) WITH NO LOG EXTENT SIZE 32 NEXT SIZE 32 LOCK MODE ROW;
    CREATE INDEX idx_rptctasinact_tmp ON sc_rptctasinactivas_tmp(cuenta);
    UPDATE STATISTICS MEDIUM FOR TABLE sc_rptctasinactivas_tmp;

    -- // PARAMETROS DE CONSULTA PARA MOVIMIENTOS HISTORICOS
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
       
    -- // TABLA TEMPORAL DE MOVIMIENTOS DEL MES
    SELECT mov.cuenta, mov.producto, mae.num_cte, mae.sucursal, mae.sdo_actual
      FROM sc_movhis_old mov,
           sc_maechq mae
     WHERE mov.empresa = pempresa
       AND mov.cuenta = mae.cuenta
       AND mov.fech_alt BETWEEN pfechaini and pfechafin
       AND mov.fech_alt >= vfechconmovhisold
       AND mov.fech_alt < vfechconmovhis
       AND mov.cancelad <> 'S'
       AND mov.transacc = '3232'
       AND mae.empresa = mov.empresa
       AND mae.cuenta = mov.cuenta
       AND mae.status_cta <> '2'
       AND mae.sdo_actual > 1000.00
    UNION ALL
    SELECT mov.cuenta, mov.producto, mae.num_cte, mae.sucursal, mae.sdo_actual
      FROM sc_movhis mov,
           sc_maechq mae
     WHERE mov.empresa = pempresa
       AND mov.cuenta = mae.cuenta
       AND mov.fech_alt BETWEEN pfechaini and pfechafin
       AND mov.fech_alt >= vfechconmovhis
       AND mov.cancelad <> 'S'
       AND mov.transacc = '3232'
       AND mae.empresa = mov.empresa
       AND mae.cuenta = mov.cuenta
       AND mae.status_cta <> '2'
       AND mae.sdo_actual > 1000.00
    INTO TEMP tmp_movscobrocom WITH NO LOG;
    CREATE INDEX idx_movscobrocom ON tmp_movscobrocom(num_cte) USING BTREE FILLFACTOR 99;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_movscobrocom;
    
    SELECT UNIQUE num_cte
      FROM tmp_movscobrocom
      INTO TEMP tmp_ctesinact WITH NO LOG;
    CREATE INDEX idx_ctesinact ON tmp_ctesinact(num_cte) USING BTREE FILLFACTOR 99;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_ctesinact;
       
    FOREACH WITH HOLD
        SELECT num_cte
          INTO vnumcte
          FROM tmp_ctesinact
          
        IF vcomienza = -1 THEN
            LET vcomienza = 0;
            BEGIN WORK;
        END IF;
        
        SELECT TRIM(cte.nombre1)||' '||TRIM(cte.nombre2)||' '||TRIM(cte.apell_paterno)||' '||TRIM(cte.apell_materno),
               dir.telefono1, dir.telefono2, dir.telefono3, pf.email
          INTO vnombre, vtel_casa, vtel_cel, vtel_ofi, vcorreo
          FROM bdinteg:si_cliente cte,
               bdinteg:si_direcciones_actual dir,
               bdinteg:si_ctepf pf
         WHERE cte.numcte = vnumcte
           AND dir.numcte = cte.numcte
           AND dir.tipo_dir = '1'
           AND pf.numcte = dir.numcte;
        
        FOREACH
            SELECT UNIQUE cuenta, producto, sucursal, sdo_actual
              INTO vcuenta, vproducto, vsucursal, vsaldo
              FROM tmp_movscobrocom
             WHERE num_cte = vnumcte
            
            INSERT INTO sc_rptctasinactivas_tmp(producto, cliente, cuenta, tel_casa, tel_cel, tel_ofi, email, sucursal, sdo_cuenta)
            VALUES(vproducto, vnombre, vcuenta, vtel_casa, vtel_cel, vtel_ofi, vcorreo, vsucursal, vsaldo);
            
            LET vcontador1 = vcontador1 + 1;
            LET vcontador2 = vcontador2 + 1;
        END FOREACH
        
        IF vcontador2 >= 1000 THEN
            LET vcontador2 = 0;
            COMMIT WORK;
            BEGIN WORK;
        END IF;
           
        LET vcuenta = '';
        LET vnumcte = '';
        LET vproducto = '';
        LET vnombre = '';
        LET vsucursal = '';
        LET vsaldo = 0.00;
        LET vtel_casa = '';
        LET vtel_cel = '';
        LET vtel_ofi = '';
        LET vcorreo = '';
    END FOREACH;
    
    IF vcontador2 > 0 THEN
        LET vcontador2 = 0;
        COMMIT WORK;
    END IF;
    
    UPDATE STATISTICS MEDIUM FOR TABLE sc_rptctasinactivas_tmp;
    
    END;

    RETURN vcodret1, vcodret2, vcodret3;

END PROCEDURE;
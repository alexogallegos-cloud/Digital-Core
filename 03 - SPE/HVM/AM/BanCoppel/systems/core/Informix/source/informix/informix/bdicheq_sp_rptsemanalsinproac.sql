CREATE PROCEDURE "informix".sp_rptsemanalsinproac( pempresa char(3) )
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
    
    DEFINE vfecha_hoy           date;
    DEFINE vfecha_ant           DATE;
    DEFINE vfecha_ini           DATE;
    DEFINE vfecha_fin           DATE;
    DEFINE vfecha_ejecucion     DATE;
    DEFINE vfechaproc           DATE;
    DEFINE vfechconmovhis       char(10);
    DEFINE vfechconmovhisold    char(10);
    
    DEFINE vsucursal            char(4);
    DEFINE vproducto            char(4);
    DEFINE vno_ctes             integer;
    DEFINE vno_ctas             integer;
    DEFINE vsdo_fin_mes         decimal(18,2);
    DEFINE vno_compras          integer;
    DEFINE vmonto_compras       decimal(18,2);
    
    DEFINE vsql                 CHAR(500);
    DEFINE vfechades            CHAR(8);

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
       
    LET vfecha_hoy        = ''; 
    LET vfecha_ant        = '';
    LET vfecha_ini        = '';
    LET vfecha_fin        = '';
    LET vfecha_ejecucion  = '';
    LET vfechaproc        = '';
    LET vfechconmovhis    = '';
    LET vfechconmovhisold = '';
    
    LET vsucursal      = '';
    LET vproducto      = '';
    LET vno_ctes       = 0;
    LET vno_ctas       = 0;
    LET vsdo_fin_mes   = 0.00;
    LET vno_compras    = 0;
    LET vmonto_compras = 0.00;
    
    LET vsql      = '';
    LET vfechades = '';
    
    BEGIN
    
    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_rptsemanalsinproac.err";
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
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_rptsemanalsinproac.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    SELECT fecha_hoy, fecha_ant
      INTO vfecha_hoy, vfecha_ant
      FROM sc_fechas
     WHERE empresa = pempresa;
     
    LET vfecha_ini = vfecha_hoy - 7 UNITS DAY;
    LET vfecha_fin = vfecha_ant;
    
    -- // VERIFICA DIA DE LA SEMANA
    IF WEEKDAY(vfecha_hoy) <> 1 THEN
        LET vcodret1 = '908';
        LET vcodret2 = '908';
        
        SELECT descripcion
          INTO vcodret3
          FROM bdinteg:si_codret
         WHERE codigo_retorno = vcodret1
           AND sistema = '01';
           
        RETURN vcodret1, vcodret2, vcodret3;
    END IF;
    
    -- // VERIFICA QUE NO SE HAYA EJECUTADO EL PROCESO
    SELECT fecha
      INTO vfecha_ejecucion
      FROM sc_contproc_proac
     WHERE proceso = 'rptsemanalsinproac'
       AND empresa = pempresa;
       
    IF vfecha_ejecucion = vfecha_hoy THEN
        LET vcodret1 = '958';
        LET vcodret2 = '958';
        
        SELECT descripcion
          INTO vcodret3
          FROM bdinteg:si_codret
         WHERE codigo_retorno = vcodret1
           AND sistema = '01';
           
        RETURN vcodret1, vcodret2, vcodret3;
    END IF;
    
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
         WHERE codigo_retorno = vcodret1
           AND sistema = '01';
           
        RETURN vcodret1, vcodret2, vcodret3;
    END IF;
    
    -- // BORRA Y CREA TABLA PARA REPORTE
    IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'sc_rptsemanalsinproac') THEN
        DROP TABLE "informix".sc_rptsemanalsinproac;        
    END IF;
    
    CREATE TABLE "informix".sc_rptsemanalsinproac
      ( 
        sucursal            CHAR(4), 
        producto            CHAR(4), 
        no_clientes         INTEGER,
        no_cuentas          INTEGER,
        sdo_fin_mes         DECIMAL(18,2),
        no_compras_td       INTEGER,
        monto_compras_td    DECIMAL(18,2)
      ) 
    EXTENT SIZE 32 NEXT SIZE 32 LOCK MODE ROW;
    CREATE INDEX "informix".idx_rptsemsinproac ON "informix".sc_rptsemanalsinproac(sucursal);
    UPDATE STATISTICS MEDIUM FOR TABLE "informix".sc_rptsemanalsinproac;

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
    SELECT *
      FROM sc_movhis_old  
     WHERE fech_alt BETWEEN vfecha_ini and vfecha_fin
       AND fech_alt >= vfechconmovhisold
       AND fech_alt < vfechconmovhis
       AND transacc IN('0830','0887')
       AND cancelad <> 'S'
    UNION ALL
    SELECT *
      FROM sc_movhis
     WHERE fech_alt BETWEEN vfecha_ini AND vfecha_fin
       AND fech_alt >= vfechconmovhis
       AND transacc IN('0830','0887')
       AND cancelad <> 'S'
    INTO TEMP tmp_movs WITH NO LOG;
    CREATE INDEX idx_tmpmovs1 ON tmp_movs(suc_cuen, producto);
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_movs;
    
    FOREACH WITH HOLD
        SELECT sucursal
          INTO vsucursal
          FROM sc_sucsrptsproac
          
        IF vcomienza = -1 THEN
            LET vcomienza = 0;
            LET ven_transacc = 1;
            BEGIN WORK;
        END IF;
          
        FOREACH
            SELECT producto
              INTO vproducto
              FROM sc_prodproac
             
            SELECT NVL(COUNT(UNIQUE mae.num_cte),0)
              INTO vno_ctes
              FROM sc_maechq mae
             WHERE mae.sucursal = vsucursal
               AND mae.producto = vproducto
               AND mae.status_cta <> '2'
               AND mae.cuenta NOT IN(SELECT cta_eje
                                       FROM sc_proac
                                      WHERE cta_eje = mae.cuenta
                                        AND status_cta = '1');
               
            SELECT NVL(COUNT(mae.cuenta),0)
              INTO vno_ctas
              FROM sc_maechq mae
             WHERE mae.sucursal = vsucursal
               AND mae.producto = vproducto
               AND mae.status_cta <> '2'
               AND mae.cuenta NOT IN(SELECT cta_eje
                                       FROM sc_proac
                                      WHERE cta_eje = mae.cuenta
                                        AND status_cta = '1');
               
            SELECT NVL(SUM(mae.sdo_dia_ant),0.00)
              INTO vsdo_fin_mes
              FROM sc_maechq mae
             WHERE mae.sucursal = vsucursal
               AND mae.producto = vproducto
               AND mae.status_cta <> '2'
               AND mae.cuenta NOT IN(SELECT cta_eje
                                       FROM sc_proac
                                      WHERE cta_eje = mae.cuenta
                                        AND status_cta = '1');
               
            SELECT NVL(COUNT(mov.num_serial),0)
              INTO vno_compras
              FROM tmp_movs mov
             WHERE mov.suc_cuen = vsucursal
               AND mov.producto = vproducto
               AND mov.cuenta NOT IN(SELECT cta_eje
                                       FROM sc_proac
                                      WHERE cta_eje = mov.cuenta
                                        AND status_cta = '1');
               
            SELECT NVL(SUM(mov.monto_tot),0.00)
              INTO vmonto_compras
              FROM tmp_movs mov
             WHERE mov.suc_cuen = vsucursal
               AND mov.producto = vproducto
               AND mov.cuenta NOT IN(SELECT cta_eje
                                       FROM sc_proac
                                      WHERE cta_eje = mov.cuenta
                                        AND status_cta = '1');
               
            INSERT INTO sc_rptsemanalsinproac(sucursal, producto, no_clientes, no_cuentas, sdo_fin_mes, no_compras_td, monto_compras_td)
            VALUES(vsucursal, vproducto, vno_ctes, vno_ctas, vsdo_fin_mes, vno_compras, vmonto_compras);
            
            LET vproducto      = '';
            LET vno_ctes       = 0;
            LET vno_ctas       = 0;
            LET vsdo_fin_mes   = 0.00;
            LET vno_compras    = 0;
            LET vmonto_compras = 0.00;
        END FOREACH;
        
        COMMIT WORK;
        BEGIN WORK;
        
        LET vsucursal = '';
    END FOREACH;
    
    IF ven_transacc = 1 THEN
        LET ven_transacc = 0;
        COMMIT WORK;
    END IF;
    
    UPDATE STATISTICS MEDIUM FOR TABLE "informix".sc_rptsemanalsinproac;
    
    -- // DESCARGA EL ARCHIVO DE INFORMACIÓN
    LET vfechades = TO_CHAR(vfecha_hoy, '%d%m%Y');
    
    LET vsql = '';
    LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/rptsemanalsinproac_'||vfechades||'.txt '||
               ' SELECT * FROM sc_rptsemanalsinproac ORDER BY sucursal, producto;" > /resplogifx/conciliachq/rptproac4.sql';
    SYSTEM vsql;
    
    LET vsql = '';
    LET vsql = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/rptproac4.sql"; 
    SYSTEM vsql;
    
    UPDATE sc_contproc_proac
       SET fecha = vfecha_hoy
     WHERE proceso = 'rptsemanalsinproac'
       AND empresa = pempresa;
    
    END;

    RETURN vcodret1, vcodret2, vcodret3;

END PROCEDURE;
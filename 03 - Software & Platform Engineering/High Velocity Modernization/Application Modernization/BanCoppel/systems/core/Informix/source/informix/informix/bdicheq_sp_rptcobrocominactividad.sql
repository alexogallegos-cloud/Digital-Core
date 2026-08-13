CREATE PROCEDURE "informix".sp_rptcobrocominactividad( pempresa char(3) )
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
    DEFINE vpri_dia_mes         DATE;
    DEFINE vfecha_ini           DATE;
    DEFINE vfecha_fin           DATE;
    DEFINE vfecha_ejecucion     DATE;
    DEFINE vfechconmovhis       char(10);
    DEFINE vfechconmovhisold    char(10);
    
    DEFINE vproducto            CHAR(4);
    DEFINE vcuantos             INTEGER;
    DEFINE vmonto               DECIMAL(18,2);
    DEFINE vrango1              CHAR(30);
    DEFINE vrango2              CHAR(30);
    DEFINE vrango3              CHAR(30);
    DEFINE vrango4              CHAR(30);
    DEFINE vrango5              CHAR(30);
    DEFINE vrango6              CHAR(30);
    DEFINE vrango7              CHAR(30);
    DEFINE vrango8              CHAR(30);
    DEFINE vrango9              CHAR(30);
    DEFINE vrango10             CHAR(30);
    
    DEFINE vsql                 CHAR(500);
    DEFINE vaniomes             CHAR(6);

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
       
    LET vfecha_hoy              = ''; 
    LET vfecha_ant              = ''; 
    LET vpri_dia_mes            = '';
    LET vfecha_ini              = '';
    LET vfecha_fin              = '';
    LET vfecha_ejecucion        = '';
    LET vfechconmovhis          = '';
    LET vfechconmovhisold       = '';
    
    LET vproducto = '';
    LET vcuantos  = 0;    
    LET vmonto    = 0.00;
    LET vrango1   = '0.01 a 200.00';
    LET vrango2   = '200.01 a 1000.00';
    LET vrango3   = '1000.01 a 5000.00';
    LET vrango4   = '5000.01 a 10000.00';
    LET vrango5   = '10000.01 a 20000.00';
    LET vrango6   = '20000.01 a 50000.00';
    LET vrango7   = '50000.01 a 100000.00';
    LET vrango8   = '100000.01 a 500000.00';
    LET vrango9   = '500000.01 a 1000000.00';
    LET vrango10  = '1000000 en adelante';
    
    LET vsql     = '';
    LET vaniomes = '';

    BEGIN

    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_rptcobrocominactividad.err";
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

    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_rptcobrocominactividad.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    SELECT fecha_hoy, fecha_ant, pri_dia_mes
      INTO vfecha_hoy, vfecha_ant, vpri_dia_mes
      FROM sc_fechas
     WHERE empresa = pempresa;
     
    LET vfecha_ini = vpri_dia_mes - 1 UNITS MONTH;
    LET vfecha_fin = vpri_dia_mes - 1 UNITS DAY;
    
    -- // VERIFICA QUE NO SE HAYA EJECUTADO EL PROCESO PARA ESTE PERIODO
    SELECT fecha
      INTO vfecha_ejecucion
      FROM sc_contproc_cobrocominact
     WHERE proceso = 'rptcobrocominactividad'
       AND empresa = pempresa;
       
    IF vfecha_ejecucion >= vpri_dia_mes THEN
        LET vcodret1 = '958';
        LET vcodret2 = '958';
        
        SELECT descripcion
          INTO vcodret3
          FROM bdinteg:si_codret
         WHERE codigo_retorno = '958'
           AND sistema = '01';
           
        RETURN vcodret1, vcodret2, vcodret3;
    END IF;
    
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
       AND transacc = '3232'
       AND cancelad <> 'S'
    UNION ALL
    SELECT *
      FROM sc_movhis
     WHERE fech_alt BETWEEN vfecha_ini AND vfecha_fin
       AND fech_alt >= vfechconmovhis
       AND transacc = '3232'
       AND cancelad <> 'S'
    INTO TEMP tmp_movs_cobrocom WITH NO LOG;
    CREATE INDEX idx_movscobro ON tmp_movs_cobrocom(sdo_cuenta);
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_movs_cobrocom;
       
    -- // TABLAS PARA REPORTE
    -- // 0.01 A 200.00
    IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'sc_rptcobrocominactividad_1') THEN
        DROP TABLE "informix".sc_rptcobrocominactividad_1;        
    END IF;
    
    CREATE TABLE "informix".sc_rptcobrocominactividad_1( producto CHAR(4), no_cuentas INTEGER, monto_cobrado MONEY(18,2) ) 
    EXTENT SIZE 32 NEXT SIZE 32 LOCK MODE ROW;
    CREATE INDEX "informix".idx_rptcobcominact1 ON "informix".sc_rptcobrocominactividad_1(producto);
    UPDATE STATISTICS MEDIUM FOR TABLE "informix".sc_rptcobrocominactividad_1;
    
    FOREACH
        SELECT producto, COUNT(*), SUM(monto_tot)
          INTO vproducto, vcuantos, vmonto
          FROM tmp_movs_cobrocom  
         WHERE sdo_cuenta BETWEEN 0.01 AND 200.00
         GROUP BY producto
  
        INSERT INTO sc_rptcobrocominactividad_1 VALUES(vproducto, vcuantos, vmonto);
    END FOREACH;
    
    UPDATE STATISTICS MEDIUM FOR TABLE "informix".sc_rptcobrocominactividad_1;
    
    -- // 200.01 A 1000.00
    IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'sc_rptcobrocominactividad_2') THEN
        DROP TABLE "informix".sc_rptcobrocominactividad_2;        
    END IF;
    
    CREATE TABLE "informix".sc_rptcobrocominactividad_2( producto CHAR(4), no_cuentas INTEGER, monto_cobrado MONEY(18,2) ) 
    EXTENT SIZE 32 NEXT SIZE 32 LOCK MODE ROW;
    CREATE INDEX "informix".idx_rptcobcominact2 ON "informix".sc_rptcobrocominactividad_2(producto);
    UPDATE STATISTICS MEDIUM FOR TABLE "informix".sc_rptcobrocominactividad_2;
    
    FOREACH
        SELECT producto, COUNT(*), SUM(monto_tot)
          INTO vproducto, vcuantos, vmonto
          FROM tmp_movs_cobrocom  
         WHERE sdo_cuenta BETWEEN 200.01 AND 1000.00
         GROUP BY producto
      
        INSERT INTO sc_rptcobrocominactividad_2 VALUES(vproducto, vcuantos, vmonto);
    END FOREACH;
    
    UPDATE STATISTICS MEDIUM FOR TABLE "informix".sc_rptcobrocominactividad_2;
    
    -- // 1000.01 A 5000.00
    IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'sc_rptcobrocominactividad_3') THEN
        DROP TABLE "informix".sc_rptcobrocominactividad_3;        
    END IF;
    
    CREATE TABLE "informix".sc_rptcobrocominactividad_3( producto CHAR(4), no_cuentas INTEGER, monto_cobrado MONEY(18,2) ) 
    EXTENT SIZE 32 NEXT SIZE 32 LOCK MODE ROW;
    CREATE INDEX "informix".idx_rptcobcominact3 ON "informix".sc_rptcobrocominactividad_3(producto);
    UPDATE STATISTICS MEDIUM FOR TABLE "informix".sc_rptcobrocominactividad_3;
    
    FOREACH
        SELECT producto, COUNT(*), SUM(monto_tot)
          INTO vproducto, vcuantos, vmonto
          FROM tmp_movs_cobrocom  
         WHERE sdo_cuenta BETWEEN 1000.01 AND 5000.00
         GROUP BY producto
      
        INSERT INTO sc_rptcobrocominactividad_3 VALUES(vproducto, vcuantos, vmonto);
    END FOREACH;
    
    UPDATE STATISTICS MEDIUM FOR TABLE "informix".sc_rptcobrocominactividad_3;
    
    -- // 5000.01 A 10000.00
    IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'sc_rptcobrocominactividad_4') THEN
        DROP TABLE "informix".sc_rptcobrocominactividad_4;        
    END IF;
    
    CREATE TABLE "informix".sc_rptcobrocominactividad_4( producto CHAR(4), no_cuentas INTEGER, monto_cobrado MONEY(18,2) ) 
    EXTENT SIZE 32 NEXT SIZE 32 LOCK MODE ROW;
    CREATE INDEX "informix".idx_rptcobcominact4 ON "informix".sc_rptcobrocominactividad_4(producto);
    UPDATE STATISTICS MEDIUM FOR TABLE "informix".sc_rptcobrocominactividad_4;
    
    FOREACH
        SELECT producto, COUNT(*), SUM(monto_tot)
          INTO vproducto, vcuantos, vmonto
          FROM tmp_movs_cobrocom  
         WHERE sdo_cuenta BETWEEN 5000.01 AND 10000.00
         GROUP BY producto
      
        INSERT INTO sc_rptcobrocominactividad_4 VALUES(vproducto, vcuantos, vmonto);
    END FOREACH;
    
    UPDATE STATISTICS MEDIUM FOR TABLE "informix".sc_rptcobrocominactividad_4;
    
    -- // 10000.01 A 20000.00
    IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'sc_rptcobrocominactividad_5') THEN
        DROP TABLE "informix".sc_rptcobrocominactividad_5;        
    END IF;
    
    CREATE TABLE "informix".sc_rptcobrocominactividad_5( producto CHAR(4), no_cuentas INTEGER, monto_cobrado MONEY(18,2) ) 
    EXTENT SIZE 32 NEXT SIZE 32 LOCK MODE ROW;
    CREATE INDEX "informix".idx_rptcobcominact5 ON "informix".sc_rptcobrocominactividad_5(producto);
    UPDATE STATISTICS MEDIUM FOR TABLE "informix".sc_rptcobrocominactividad_5;
    
    FOREACH
        SELECT producto, COUNT(*), SUM(monto_tot)
          INTO vproducto, vcuantos, vmonto
          FROM tmp_movs_cobrocom  
         WHERE sdo_cuenta BETWEEN 10000.01 AND 20000.00
         GROUP BY producto
      
        INSERT INTO sc_rptcobrocominactividad_5 VALUES(vproducto, vcuantos, vmonto);
    END FOREACH;
    
    UPDATE STATISTICS MEDIUM FOR TABLE "informix".sc_rptcobrocominactividad_5;
    
    -- // 20000.01 A 50000.00
    IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'sc_rptcobrocominactividad_6') THEN
        DROP TABLE "informix".sc_rptcobrocominactividad_6;        
    END IF;
    
    CREATE TABLE "informix".sc_rptcobrocominactividad_6( producto CHAR(4), no_cuentas INTEGER, monto_cobrado MONEY(18,2) ) 
    EXTENT SIZE 32 NEXT SIZE 32 LOCK MODE ROW;
    CREATE INDEX "informix".idx_rptcobcominact6 ON "informix".sc_rptcobrocominactividad_6(producto);
    UPDATE STATISTICS MEDIUM FOR TABLE "informix".sc_rptcobrocominactividad_6;
    
    FOREACH
        SELECT producto, COUNT(*), SUM(monto_tot)
          INTO vproducto, vcuantos, vmonto
          FROM tmp_movs_cobrocom  
         WHERE sdo_cuenta BETWEEN 20000.01 AND 50000.00
         GROUP BY producto
      
        INSERT INTO sc_rptcobrocominactividad_6 VALUES(vproducto, vcuantos, vmonto);
    END FOREACH;
    
    UPDATE STATISTICS MEDIUM FOR TABLE "informix".sc_rptcobrocominactividad_6;
    
    -- // 50000.01 A 100000.00
    IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'sc_rptcobrocominactividad_7') THEN
        DROP TABLE "informix".sc_rptcobrocominactividad_7;        
    END IF;
    
    CREATE TABLE "informix".sc_rptcobrocominactividad_7( producto CHAR(4), no_cuentas INTEGER, monto_cobrado MONEY(18,2) ) 
    EXTENT SIZE 32 NEXT SIZE 32 LOCK MODE ROW;
    CREATE INDEX "informix".idx_rptcobcominact7 ON "informix".sc_rptcobrocominactividad_7(producto);
    UPDATE STATISTICS MEDIUM FOR TABLE "informix".sc_rptcobrocominactividad_7;
    
    FOREACH
        SELECT producto, COUNT(*), SUM(monto_tot)
          INTO vproducto, vcuantos, vmonto
          FROM tmp_movs_cobrocom  
         WHERE sdo_cuenta BETWEEN 50000.01 AND 100000.00
         GROUP BY producto
      
        INSERT INTO sc_rptcobrocominactividad_7 VALUES(vproducto, vcuantos, vmonto);
    END FOREACH;
    
    UPDATE STATISTICS MEDIUM FOR TABLE "informix".sc_rptcobrocominactividad_7;
    
    -- // 100000.01 A 500000.00
    IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'sc_rptcobrocominactividad_8') THEN
        DROP TABLE "informix".sc_rptcobrocominactividad_8;        
    END IF;
    
    CREATE TABLE "informix".sc_rptcobrocominactividad_8( producto CHAR(4), no_cuentas INTEGER, monto_cobrado MONEY(18,2) ) 
    EXTENT SIZE 32 NEXT SIZE 32 LOCK MODE ROW;
    CREATE INDEX "informix".idx_rptcobcominact8 ON "informix".sc_rptcobrocominactividad_8(producto);
    UPDATE STATISTICS MEDIUM FOR TABLE "informix".sc_rptcobrocominactividad_8;
    
    FOREACH
        SELECT producto, COUNT(*), SUM(monto_tot)
          INTO vproducto, vcuantos, vmonto
          FROM tmp_movs_cobrocom  
         WHERE sdo_cuenta BETWEEN 100000.01 AND 500000.00
         GROUP BY producto
      
        INSERT INTO sc_rptcobrocominactividad_8 VALUES(vproducto, vcuantos, vmonto);
    END FOREACH;
    
    UPDATE STATISTICS MEDIUM FOR TABLE "informix".sc_rptcobrocominactividad_8;
    
    -- // 500000.01 A 1000000.00
    IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'sc_rptcobrocominactividad_9') THEN
        DROP TABLE "informix".sc_rptcobrocominactividad_9;        
    END IF;
    
    CREATE TABLE "informix".sc_rptcobrocominactividad_9( producto CHAR(4), no_cuentas INTEGER, monto_cobrado MONEY(18,2) ) 
    EXTENT SIZE 32 NEXT SIZE 32 LOCK MODE ROW;
    CREATE INDEX "informix".idx_rptcobcominact9 ON "informix".sc_rptcobrocominactividad_9(producto);
    UPDATE STATISTICS MEDIUM FOR TABLE "informix".sc_rptcobrocominactividad_9;
    
    FOREACH
        SELECT producto, COUNT(*), SUM(monto_tot)
          INTO vproducto, vcuantos, vmonto
          FROM tmp_movs_cobrocom  
         WHERE sdo_cuenta BETWEEN 500000.01 AND 1000000.00
         GROUP BY producto
      
        INSERT INTO sc_rptcobrocominactividad_9 VALUES(vproducto, vcuantos, vmonto);
    END FOREACH;
    
    UPDATE STATISTICS MEDIUM FOR TABLE "informix".sc_rptcobrocominactividad_9;
    
    -- // 1000000.01 EN ADELANTE
    IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'sc_rptcobrocominactividad_10') THEN
        DROP TABLE "informix".sc_rptcobrocominactividad_10;        
    END IF;
    
    CREATE TABLE "informix".sc_rptcobrocominactividad_10( producto CHAR(4), no_cuentas INTEGER, monto_cobrado MONEY(18,2) ) 
    EXTENT SIZE 32 NEXT SIZE 32 LOCK MODE ROW;
    CREATE INDEX "informix".idx_rptcobcominact10 ON "informix".sc_rptcobrocominactividad_10(producto);
    UPDATE STATISTICS MEDIUM FOR TABLE "informix".sc_rptcobrocominactividad_10;
    
    FOREACH
        SELECT producto, COUNT(*), SUM(monto_tot)
          INTO vproducto, vcuantos, vmonto
          FROM tmp_movs_cobrocom  
         WHERE sdo_cuenta >= 1000000.01
         GROUP BY producto
      
        INSERT INTO sc_rptcobrocominactividad_10 VALUES(vproducto, vcuantos, vmonto);
    END FOREACH;
    
    UPDATE STATISTICS MEDIUM FOR TABLE "informix".sc_rptcobrocominactividad_10;
    
    -- // CREA TABLA DE DESCARGA
    IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'sc_rptcobrocominactividad') THEN
        DROP TABLE "informix".sc_rptcobrocominactividad;        
    END IF;
    
    CREATE TABLE "informix".sc_rptcobrocominactividad( producto CHAR(4), rango CHAR(30), no_cuentas INTEGER, monto_cobrado MONEY(18,2) ) 
    EXTENT SIZE 32 NEXT SIZE 32 LOCK MODE ROW;
    CREATE INDEX "informix".idx_rptcobcominact ON "informix".sc_rptcobrocominactividad(producto);
    UPDATE STATISTICS MEDIUM FOR TABLE "informix".sc_rptcobrocominactividad;
    
    INSERT INTO sc_rptcobrocominactividad
    SELECT producto, vrango1, no_cuentas, monto_cobrado
      FROM sc_rptcobrocominactividad_1;
     
    INSERT INTO sc_rptcobrocominactividad
    SELECT producto, vrango2, no_cuentas, monto_cobrado
      FROM sc_rptcobrocominactividad_2;
     
    INSERT INTO sc_rptcobrocominactividad
    SELECT producto, vrango3, no_cuentas, monto_cobrado
      FROM sc_rptcobrocominactividad_3;
     
    INSERT INTO sc_rptcobrocominactividad
    SELECT producto, vrango4, no_cuentas, monto_cobrado
      FROM sc_rptcobrocominactividad_4;
     
    INSERT INTO sc_rptcobrocominactividad
    SELECT producto, vrango5, no_cuentas, monto_cobrado
      FROM sc_rptcobrocominactividad_5;
     
    INSERT INTO sc_rptcobrocominactividad
    SELECT producto, vrango6, no_cuentas, monto_cobrado
      FROM sc_rptcobrocominactividad_6;
     
    INSERT INTO sc_rptcobrocominactividad
    SELECT producto, vrango7, no_cuentas, monto_cobrado
      FROM sc_rptcobrocominactividad_7;
     
    INSERT INTO sc_rptcobrocominactividad
    SELECT producto, vrango8, no_cuentas, monto_cobrado
      FROM sc_rptcobrocominactividad_8;
     
    INSERT INTO sc_rptcobrocominactividad
    SELECT producto, vrango9, no_cuentas, monto_cobrado
      FROM sc_rptcobrocominactividad_9;
     
    INSERT INTO sc_rptcobrocominactividad
    SELECT producto, vrango10, no_cuentas, monto_cobrado
      FROM sc_rptcobrocominactividad_10;
    
    -- // DESCARGA EL ARCHIVO DE INFORMACIÓN
    LET vaniomes = TO_CHAR(vfecha_fin, '%Y%m');
    
    LET vsql = '';
    LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/rptcobrocominactividad_'||vaniomes||'.csv '||
               ' SELECT * FROM sc_rptcobrocominactividad ORDER BY producto, rango" > /resplogifx/conciliachq/cominact.sql';
    SYSTEM vsql;
    
    LET vsql = '';
    LET vsql = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/cominact.sql"; 
    SYSTEM vsql;
    
    UPDATE sc_contproc_cobrocominact
       SET fecha = vfecha_hoy
     WHERE proceso = 'rptcobrocominactividad'
       AND empresa = pempresa;
    
    END;

    RETURN vcodret1, vcodret2, vcodret3;

END PROCEDURE;
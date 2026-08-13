CREATE PROCEDURE "informix".sp_rptctasinact( pempresa char(3) )
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
       
    LET vfecha_hoy        = ''; 
    LET vfecha_ant        = ''; 
    LET vpri_dia_mes      = '';
    LET vfecha_ini        = '';
    LET vfecha_fin        = '';
    LET vfecha_ejecucion  = '';
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
    
    LET vsql = '';
    LET vaniomes = '';

    BEGIN

    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_rptctasinact.err";
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

    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_rptctasinact.out";
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
     WHERE proceso = 'rptctasinactivas'
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
    
    -- // TABLA PARA REPORTE
    IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'sc_rptctasinactivas') THEN
        DROP TABLE "informix".sc_rptctasinactivas;        
    END IF;
    
    CREATE TABLE "informix".sc_rptctasinactivas
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
    ) 
    EXTENT SIZE 32 NEXT SIZE 32 LOCK MODE ROW;
    CREATE INDEX "informix".idx_rptctasinact ON "informix".sc_rptctasinactivas(producto,cuenta);
    UPDATE STATISTICS MEDIUM FOR TABLE "informix".sc_rptctasinactivas;

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
       AND mov.fech_alt BETWEEN vfecha_ini and vfecha_fin
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
       AND mov.fech_alt BETWEEN vfecha_ini AND vfecha_fin
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
        
        /* ###########################################################################################################################
        SELECT TRIM(cte.nombre1)||' '||TRIM(cte.nombre2)||' '||TRIM(cte.apell_paterno)||' '||TRIM(cte.apell_materno),
               tel1.telefono, tel2.telefono, tel3.telefono, core.correo_elec
          INTO vnombre, vtel_casa, vtel_cel, vtel_ofi, vcorreo
          FROM bdinteg:si_cliente cte
		  left outer join bdinteg:si_telefonos_actual tel1 on (tel1.numcte = cte.numcte and tel1.tipo_tel = 1)
	      left outer join bdinteg:si_telefonos_actual tel2 on (tel2.numcte = cte.numcte and tel2.tipo_tel = 2)
		  left outer join bdinteg:si_telefonos_actual tel3 on (tel3.numcte = cte.numcte and tel3.tipo_tel = 3)
	      left outer join bdinteg:si_correos core on (core.numcte = cte.numcte and core.tipo_correo = 1 and core.status_correo ='A')
         WHERE cte.numcte = vnumcte;
        ########################################################################################################################### */
        
        SELECT TRIM(cte.nombre1)||' '||TRIM(cte.nombre2)||' '||TRIM(cte.apell_paterno)||' '||TRIM(cte.apell_materno),
               tel1.telefono, tel2.telefono, tel3.telefono
          INTO vnombre, vtel_casa, vtel_cel, vtel_ofi
          FROM bdinteg:si_cliente cte
		  LEFT OUTER JOIN bdinteg:si_telefonos_actual tel1 on (tel1.numcte = cte.numcte and tel1.tipo_tel = 1)
	      LEFT OUTER JOIN bdinteg:si_telefonos_actual tel2 on (tel2.numcte = cte.numcte and tel2.tipo_tel = 2)
		  LEFT OUTER JOIN bdinteg:si_telefonos_actual tel3 on (tel3.numcte = cte.numcte and tel3.tipo_tel = 3)
         WHERE cte.numcte = vnumcte;
         
        SELECT correo_elec
          INTO vcorreo
          FROM bdinteg:si_correos
         WHERE numcte = vnumcte
           AND tipo_correo = 1
           AND status_correo = 'A'
           AND secuencia = ( SELECT max(secuencia) FROM bdinteg:si_correos WHERE numcte = vnumcte AND tipo_correo = 1 AND status_correo = 'A' );          
   
        FOREACH
            SELECT UNIQUE cuenta, producto, sucursal, sdo_actual
              INTO vcuenta, vproducto, vsucursal, vsaldo
              FROM tmp_movscobrocom
             WHERE num_cte = vnumcte
            
            INSERT INTO sc_rptctasinactivas(producto, cliente, cuenta, tel_casa, tel_cel, tel_ofi, email, sucursal, sdo_cuenta)
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
    
    UPDATE STATISTICS MEDIUM FOR TABLE sc_rptctasinactivas;
    
    -- // DESCARGA EL ARCHIVO DE INFORMACIÓN
    LET vaniomes = TO_CHAR(vfecha_fin, '%Y%m');
    
    LET vsql = '';
    LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/rptctasinactivas_'||vaniomes||'.csv '||
               ' SELECT * FROM sc_rptctasinactivas ORDER BY producto, cuenta" > /resplogifx/conciliachq/ctasinact.sql';
    SYSTEM vsql;
    
    LET vsql = '';
    LET vsql = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/ctasinact.sql"; 
    SYSTEM vsql;
    
    UPDATE sc_contproc_cobrocominact
       SET fecha = vfecha_hoy
     WHERE proceso = 'rptctasinactivas'
       AND empresa = pempresa;
    
    END;

    RETURN vcodret1, vcodret2, vcodret3;

END PROCEDURE;
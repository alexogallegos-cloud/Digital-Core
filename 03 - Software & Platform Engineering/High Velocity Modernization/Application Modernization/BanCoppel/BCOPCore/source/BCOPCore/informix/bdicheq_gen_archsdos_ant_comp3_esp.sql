CREATE PROCEDURE "informix".gen_archsdos_ant_comp3_esp( pFechaHoy DATE, pFechaAnt DATE )
RETURNING CHAR(5), CHAR(5), CHAR(50), INTEGER;
     
    DEFINE vcodret1         char(5);
    DEFINE vcodret2         char(5);
    DEFINE vcodret3         char(50);
    DEFINE sql_err          integer;
    DEFINE isam_err         integer;
    DEFINE desc_err         char(50);
    DEFINE vcontador1       integer;
    DEFINE vcontador2       integer;
    DEFINE ven_transacc     smallint;
    DEFINE vcomienza        smallint;
    DEFINE vexiste          smallint;
    DEFINE vexistefin       smallint;
    DEFINE vexisteproc      char(12);
    DEFINE vsql             char(600);
    DEFINE vstmt            char(300);
    DEFINE vfecha_hoy       date;
    DEFINE vfecha_ant       date;
    DEFINE vfecha_proceso   date;
    DEFINE vfec_ult_mov     date;
    DEFINE vaniomes         char(6);
    DEFINE vaniomes2        char(6);
    DEFINE vempresa         char(3);
    DEFINE vstatus_cta      char(1);
    DEFINE vproceso         char(15);
    DEFINE vusuario         char(10);
    DEFINE vanio            char(4);
    DEFINE vsucursal        char(4);
    DEFINE vprodcrec        char(4);
    DEFINE vtrancobsbg      char(4);
    DEFINE vproducto        char(4);
    DEFINE vcuenta          char(20);
    DEFINE vmes_actual      char(2);
    DEFINE vmes_siguiente   char(2);
    DEFINE vdia             char(2);
    DEFINE vdia2            char(2);
    DEFINE vmes             char(2);
    DEFINE vsistema         char(2);
    DEFINE vsdo_dia_ant     decimal(18,2);
    DEFINE vimp_chq_sbg     decimal(18,2);
    DEFINE vint_acum        decimal(18,2);
    DEFINE vacum_sdo_int    decimal(18,2);
    DEFINE vsdo_actual      decimal(18,2);
    DEFINE vexistecobsbg    integer;
    DEFINE vmonto_sbg       decimal(18,2);
    DEFINE vnum_cte         char(20);
    DEFINE vejecutivo       char(8);
    DEFINE vgenero          char(1);
    DEFINE vpri_hab_mes     date;
    
    LET vcodret1       = "000";               
    LET vcodret2       = '000';
    LET vcodret3       = 'PROCESO CONCLUIDO SATISFACTORIAMENTE';
    LET sql_err        = 0;                   
    LET isam_err       = 0;
    LET desc_err       = '';
    LET vcontador1     = 0;                   
    LET vcontador2     = 0;
    LET ven_transacc   = 0;                   
    LET vcomienza      = -1;  
    LET vexiste        = 0;                   
    LET vexistefin     = 0;    
    LET vexisteproc    = '';
    LET vsql           = '';                  
    LET vstmt          = '';
    LET vfecha_hoy     = '';                  
    LET vfecha_ant     = '';                    
    LET vmes_actual    = 0;                   
    LET vmes_siguiente = 0;                 
    LET vaniomes       = '';
    LET vaniomes2      = '';     
    LET vdia           = '';   
    LET vdia2          = '';  
    LET vmes           = '';                  
    LET vanio          = '';    
    LET vprodcrec      = '';    
    LET vtrancobsbg    = '';
    LET vproceso       = 'sdoschqantcomp3';        
    LET vsistema       = '01';                
    LET vusuario       = user;                 
    LET vempresa       = '001';             
    LET vcuenta        = '';                  
    LET vsucursal      = '';                
    LET vsdo_dia_ant   = 0.00;                
    LET vimp_chq_sbg   = 0.00;              
    LET vint_acum      = 0.00;                
    LET vacum_sdo_int  = 0.00;              
    LET vproducto      = '';
    LET vstatus_cta    = '';                
    LET vfecha_proceso = '';
    LET vsdo_actual    = 0.00;              
    LET vfec_ult_mov   = '';
    LET vexistecobsbg  = 0;
    LET vmonto_sbg     = 0.00;
    LET vnum_cte       = '';
    LET vejecutivo     = '';
    LET vgenero        = '';
    LET vpri_hab_mes   = '';
    
    BEGIN

    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/gen_archsdos_ant_comp3.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            IF ven_transacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            /* ###############################################################################################
            LET vsql = 'echo "UPDATE bdinteg:sx_contproc '||
                       'SET ejecutivo = '''||vusuario||''','||
                       'status_proc   = '''||'C'||''','||
                       'codret        = '''||vcodret1||''','||
                       'hora_fin      = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
                       'WHERE empresa = '''||vempresa||''' '||
                       'AND proceso   = '''||vproceso||''' '||
                       'AND fecha     = '''||vfecha_hoy||''' '||
                       'AND sistema   = '''||vsistema||''';" > /tmp/horassdosdia3.sql';
            SYSTEM vsql;
            
            LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horassdosdia3.sql';
            SYSTEM vstmt;
            ############################################################################################### */
            RETURN vcodret1, vcodret2, vcodret3, vcontador1;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/gen_archsdos_ant_comp3.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // Obtiene fechas del sistema
    SELECT fecha_hoy, fecha_ant, pri_hab_mes
      INTO vfecha_hoy, vfecha_ant, vpri_hab_mes
      FROM sc_fechas
     WHERE empresa = vempresa;
	 
    LET vfecha_hoy = pFechaHoy;
    LET vfecha_ant = pFechaAnt;
		
    /* ########################################################
    -- // VALIDA HAYA FINALIZADO CIERRE DE CAPTACION
    SELECT proceso
      INTO vexisteproc
      FROM sc_contproc
     WHERE empresa = vempresa
       AND proceso = 'cierre'
       AND fecha = vfecha_ant;
    
    IF vexisteproc is null OR vexisteproc = '' THEN
        LET vcodret1 = "962";        
        LET vcodret2 = "962";        
        
        SELECT descripcion
          INTO vcodret3
          FROM bdinteg:si_codret
         WHERE sistema = vsistema
           AND codigo_retorno = vcodret1;
           
        RETURN vcodret1, vcodret2, vcodret3, vcontador1;
    END IF
    ########################################################*/
     
    /* ############################################################################################################################################
    -- // Guarda proceso en tabla de control de proceso de integral
    SELECT count(*)
      INTO vexiste
      FROM bdinteg:sx_contproc
     WHERE empresa = vempresa
       AND proceso = vproceso
       AND fecha   = vfecha_hoy
       AND sistema = vsistema;

    IF vexiste = 0 THEN
        LET vsql = 'echo "INSERT INTO bdinteg:sx_contproc VALUES '||
                   '('''||vempresa||''', '''||vproceso||''', '''||vfecha_hoy||''', '''||vsistema||''', '''||'I'||''', '''||vusuario||''', '||
                   '(SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas), NULL, NULL);" > /tmp/horassdosdia3.sql';
        SYSTEM vsql;
        
        LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horassdosdia3.sql';
        SYSTEM vstmt;
    ELSE
        SELECT count(*)
          INTO vexistefin
          FROM bdinteg:sx_contproc
         WHERE empresa     = vempresa
           AND proceso     = vproceso
           AND fecha       = vfecha_hoy
           AND sistema     = vsistema
           AND status_proc = "F";

        IF vexistefin = 0 THEN
            LET vsql = 'echo "UPDATE bdinteg:sx_contproc '||
                       'SET ejecutivo = '''||vusuario||''','||
                       'status_proc   = '''||'I'||''','||
                       'codret        = '''||' '||''','||
                       'hora_ini      = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
                       'WHERE empresa = '''||vempresa||''' '||
                       'AND proceso   = '''||vproceso||''' '||
                       'AND fecha     = '''||vfecha_hoy||''' '||
                       'AND sistema   = '''||vsistema||''';" > /tmp/horassdosdia3.sql';
            SYSTEM vsql;
            
            LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horassdosdia3.sql';
            SYSTEM vstmt;
        ELSE
            LET vcodret1 = "958";
            LET vcodret2 = "958";
            
            SELECT descripcion
              INTO vcodret3
              FROM bdinteg:si_codret
             WHERE sistema = vsistema
               AND codigo_retorno = vcodret1;
            
            RETURN vcodret1, vcodret2, vcodret3, vcontador1;
        END IF;
    END IF;
    ############################################################################################################################################ */
    
    LET vmes_actual    = LPAD(MONTH(vfecha_ant), 2, '0');
    LET vmes_siguiente = LPAD(MONTH(vfecha_hoy), 2, '0');
    LET vaniomes       = YEAR(vfecha_ant)||LPAD(MONTH(vfecha_ant), 2, '0');
    LET vdia           = DAY(vfecha_ant);
    LET vmes           = LPAD(MONTH(vfecha_ant), 2, '0');
    LET vanio          = YEAR(vfecha_ant);
    LET vaniomes2      = YEAR(vfecha_ant - 1 UNITS DAY)||LPAD(MONTH(vfecha_ant - 1 UNITS DAY), 2, '0');
    LET vdia2          = DAY(vfecha_ant - 1 UNITS DAY);
    
    SELECT valor
      INTO vprodcrec
      FROM sc_param
     WHERE empresa = vempresa
       AND codparam = 'PRODCREC';
       
    SELECT valor
      INTO vtrancobsbg
      FROM sc_param
     WHERE empresa = vempresa
       AND codparam = 'tranpagosbg';
       
    IF vfecha_hoy = vpri_hab_mes THEN
    
        FOREACH WITH HOLD
            SELECT {+INDEX(sc_maechq_resp)}
                   chq.cuenta, chq.sucursal, chq.sdo_dia_ant, chq.imp_chq_sbg, noc.int_acum, noc.acum_sdo_int,
                   chq.producto, chq.status_cta, chq.fecha_proceso, chq.fec_ult_mov, chq.sdo_actual, chq.num_cte, noc.ejecutivo
              INTO vcuenta, vsucursal, vsdo_dia_ant, vimp_chq_sbg, vint_acum, vacum_sdo_int,
                   vproducto, vstatus_cta, vfecha_proceso, vfec_ult_mov, vsdo_actual, vnum_cte, vejecutivo
              FROM sc_maechq_resp chq, 
                   sc_maenoc_resp noc 
             WHERE ( ( chq.producto = vprodcrec AND chq.status_cta != '2' AND chq.fecultdep < vfecha_hoy ) OR
                     ( chq.producto = vprodcrec AND chq.status_cta  = '2' AND chq.fecha_proceso >= vfecha_ant AND chq.fecultdep < vfecha_hoy ) OR
                     ( chq.producto = vprodcrec AND chq.status_cta  = '2' AND chq.fecha_proceso is null AND chq.fec_ult_mov >= vfecha_ant AND chq.fecultdep < vfecha_hoy ) )
               AND noc.cuenta = chq.cuenta
               
            IF vcomienza = -1 THEN
                LET vcomienza = 0;
                LET ven_transacc = 1; 
                BEGIN WORK;
            END IF;

            SELECT COUNT(*)
              INTO vexistecobsbg
              FROM sc_movhis
             WHERE empresa = vempresa
               AND cuenta = vcuenta
               AND cancelad <> 'S'
               AND transacc = vtrancobsbg
               AND fech_alt = vfecha_hoy;
               
            IF vexistecobsbg > 0 THEN
                SELECT SUM(monto_tot)
                  INTO vmonto_sbg
                  FROM sc_movhis
                 WHERE empresa = vempresa
                   AND cuenta = vcuenta
                   AND cancelad <> 'S'
                   AND transacc = vtrancobsbg
                   AND fech_alt = vfecha_hoy;
                   
                LET vimp_chq_sbg = vimp_chq_sbg + vmonto_sbg;
            END IF;
            
            IF vimp_chq_sbg < 0 THEN
                LET vimp_chq_sbg = vimp_chq_sbg * -1;
            END IF
            
            LET vsdo_dia_ant = vsdo_dia_ant - vimp_chq_sbg;
            
            IF ( vproducto = vprodcrec AND vstatus_cta = '2' AND vfecha_proceso = vfecha_ant ) OR
               ( vproducto = vprodcrec AND vstatus_cta = '2' AND vfecha_proceso is null AND vfec_ult_mov = vfecha_ant ) THEN
                LET vsdo_dia_ant = vsdo_actual;
            END IF;
            
            -- // Actualiza tabla de saldos diarios y provisiones no capitalizadas..        
            CALL sp_actsdodiarioc(vcuenta, vaniomes, vsucursal, vsdo_dia_ant, vint_acum, vdia, vaniomes2, vdia2, vstatus_cta) 
            RETURNING vcodret1;
            
            -- // Actualiza tabla de saldos mensuales y provisiones no capitalizadas..
            IF vmes_actual <> vmes_siguiente THEN
                CALL sp_actsdomensualc(vcuenta, vsucursal, vsdo_dia_ant, vacum_sdo_int, vanio, vmes) 
                RETURNING vcodret1;
                
                CALL sp_actsdotrimestralc(vcuenta, vsucursal, vanio, vmes)
                RETURNING vcodret1;
            END IF;
            
            /* ############################################################################
            SELECT sexo
              INTO vgenero
              FROM bdinteg:si_ctepf 
             WHERE numcte = vnum_cte;
             
            IF vgenero is null OR vgenero = '' OR vgenero NOT IN('F','M') THEN
                LET vgenero = 'E';
            END IF;
            
            -- // INSERTA EN TABLAS DE LA CONCILIAION DE SALDOS E INTERESES
            INSERT INTO conciliachq VALUES
            ( vfecha_hoy, vcuenta, vproducto, vnum_cte, vgenero, vsucursal, vejecutivo, 
              0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00 );
            ############################################################################ */
              
            LET vcontador1 = vcontador1 + 1;
            LET vcontador2 = vcontador2 + 1;

            IF (vcontador2 >= 1000) THEN
                LET vcontador2 = 0;
                COMMIT WORK;
                BEGIN WORK;
            END IF;
            
            LET vcuenta        = '';
            LET vsucursal      = '';
            LET vsdo_dia_ant   = 0.00;
            LET vimp_chq_sbg   = 0.00;
            LET vint_acum      = 0.00;
            LET vacum_sdo_int  = 0.00;
            LET vproducto      = '';
            LET vstatus_cta    = '';                
            LET vfecha_proceso = '';
            LET vsdo_actual    = 0.00;
            LET vfec_ult_mov   = '';
            LET vexistecobsbg  = 0;
            LET vmonto_sbg     = 0.00;
            LET vgenero        = '';
        END FOREACH;
        
    ELSE
    
        FOREACH WITH HOLD
            SELECT {+INDEX(sc_maechq_resp)}
                   chq.cuenta, chq.sucursal, chq.sdo_dia_ant, chq.imp_chq_sbg, noc.int_acum, noc.acum_sdo_int,
                   chq.producto, chq.status_cta, chq.fecha_proceso, chq.fec_ult_mov, chq.sdo_actual, chq.num_cte, noc.ejecutivo
              INTO vcuenta, vsucursal, vsdo_dia_ant, vimp_chq_sbg, vint_acum, vacum_sdo_int,
                   vproducto, vstatus_cta, vfecha_proceso, vfec_ult_mov, vsdo_actual, vnum_cte, vejecutivo
              FROM sc_maechq_resp chq, 
                   sc_maenoc_resp noc
             WHERE ( ( chq.producto = vprodcrec AND chq.status_cta != '2' AND chq.fecultdep < vfecha_hoy ) OR
                     ( chq.producto = vprodcrec AND chq.status_cta  = '2' AND chq.fecha_proceso >= vfecha_ant AND chq.fecultdep < vfecha_hoy ) OR
                     ( chq.producto = vprodcrec AND chq.status_cta  = '2' AND chq.fecha_proceso is null AND chq.fec_ult_mov >= vfecha_ant AND chq.fecultdep < vfecha_hoy ) )
               AND noc.cuenta = chq.cuenta
               
            IF vcomienza = -1 THEN
                LET vcomienza = 0;
                LET ven_transacc = 1; 
                BEGIN WORK;
            END IF;

            SELECT COUNT(*)
              INTO vexistecobsbg
              FROM sc_movhis
             WHERE empresa = vempresa
               AND cuenta = vcuenta
               AND cancelad <> 'S'
               AND transacc = vtrancobsbg
               AND fech_alt = vfecha_hoy;
               
            IF vexistecobsbg > 0 THEN
                SELECT SUM(monto_tot)
                  INTO vmonto_sbg
                  FROM sc_movhis
                 WHERE empresa = vempresa
                   AND cuenta = vcuenta
                   AND cancelad <> 'S'
                   AND transacc = vtrancobsbg
                   AND fech_alt = vfecha_hoy;
                   
                LET vimp_chq_sbg = vimp_chq_sbg + vmonto_sbg;
            END IF;
            
            IF vimp_chq_sbg < 0 THEN
                LET vimp_chq_sbg = vimp_chq_sbg * -1;
            END IF
            
            LET vsdo_dia_ant = vsdo_dia_ant - vimp_chq_sbg;
            
            IF ( vproducto = vprodcrec AND vstatus_cta = '2' AND vfecha_proceso = vfecha_ant ) OR
               ( vproducto = vprodcrec AND vstatus_cta = '2' AND vfecha_proceso is null AND vfec_ult_mov = vfecha_ant ) THEN
                LET vsdo_dia_ant = vsdo_actual;
            END IF;
            
            -- // Actualiza tabla de saldos diarios y provisiones no capitalizadas..        
            CALL sp_actsdodiarioc(vcuenta, vaniomes, vsucursal, vsdo_dia_ant, vint_acum, vdia, vaniomes2, vdia2, vstatus_cta) 
            RETURNING vcodret1;
            
            -- // Actualiza tabla de saldos mensuales y provisiones no capitalizadas..
            IF vmes_actual <> vmes_siguiente THEN
                CALL sp_actsdomensualc(vcuenta, vsucursal, vsdo_dia_ant, vacum_sdo_int, vanio, vmes) 
                RETURNING vcodret1;
                
                CALL sp_actsdotrimestralc(vcuenta, vsucursal, vanio, vmes)
                RETURNING vcodret1;
            END IF;
            
            /* #############################################################################
            -- // INSERTA EN TABLAS DE LA CONCILIAION DE SALDOS E INTERESES
            INSERT INTO conciliachq VALUES
            ( vfecha_hoy, vcuenta, vproducto, vnum_cte, vgenero, vsucursal, vejecutivo, 
              0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00 );
            ############################################################################ */
              
            LET vcontador1 = vcontador1 + 1;
            LET vcontador2 = vcontador2 + 1;

            IF (vcontador2 >= 1000) THEN
                LET vcontador2 = 0;
                COMMIT WORK;
                BEGIN WORK;
            END IF;
            
            LET vcuenta        = '';
            LET vsucursal      = '';
            LET vsdo_dia_ant   = 0.00;
            LET vimp_chq_sbg   = 0.00;
            LET vint_acum      = 0.00;
            LET vacum_sdo_int  = 0.00;
            LET vproducto      = '';
            LET vstatus_cta    = '';                
            LET vfecha_proceso = '';
            LET vsdo_actual    = 0.00;
            LET vfec_ult_mov   = '';
            LET vexistecobsbg  = 0;
            LET vmonto_sbg     = 0.00;
            LET vgenero        = '';
        END FOREACH;
    
    END IF;
    
    IF ven_transacc = 1 THEN
        LET ven_transacc = 0;
        COMMIT WORK;
    END IF;
    
    /* ##################################################################################################
    LET vsql = 'echo "UPDATE bdinteg:sx_contproc '||
               'SET ejecutivo = '''||vusuario||''','||
               'status_proc   = '''||'F'||''','||
               'codret        = '''||vcodret1||''','||
               'hora_fin      = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
               'WHERE empresa = '''||vempresa||''' '||
               'AND proceso   = '''||vproceso||''' '||
               'AND fecha     = '''||vfecha_hoy||''' '||
               'AND sistema   = '''||vsistema||''';" > /tmp/horassdosdia3.sql';
    SYSTEM vsql;
    
    LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horassdosdia3.sql';
    SYSTEM vstmt;
    ################################################################################################## */
    
    END;

    RETURN vcodret1, vcodret2, vcodret3, vcontador1;

END PROCEDURE;
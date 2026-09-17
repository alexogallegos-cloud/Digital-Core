CREATE PROCEDURE "informix".gen_archsdos_ant_comp7()
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
    DEFINE vexisteproc      varchar(12);
    DEFINE vsql             LVARCHAR(600);
    DEFINE vstmt            LVARCHAR(300);
    DEFINE vfecha_hoy       date;
    DEFINE vfecha_ant       date;
    DEFINE vfecha_proceso   date;
    DEFINE vfec_ult_mov     date;
    DEFINE vaniomes         varchar(6);
    DEFINE vaniomes2        varchar(6);
    DEFINE vempresa         char(3);
    DEFINE vstatus_cta      char(1);
    DEFINE vproceso         char(15);
    DEFINE vusuario         varchar(10);
    DEFINE vanio            char(4);
    DEFINE vsucursal        char(4);
    DEFINE vprodcrec        char(4);
    DEFINE vtrancobsbg      char(4);
    DEFINE vproducto        char(4);
    DEFINE vcuenta          varchar(20);
    DEFINE vmin_cta         varchar(20);
    DEFINE vmax_cta         varchar(20);
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
    DEFINE vcuentaini       varchar(20);
    DEFINE vnum_cte         varchar(20);
    DEFINE vejecutivo       varchar(8);
    DEFINE vgenero          char(1);
    DEFINE vpri_hab_mes     date;
	
	DEFINE vcuentafin       varchar(20);
    
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
    LET vproceso       = 'sdoschqantcomp7';        
    LET vsistema       = '01';                
    LET vusuario       = user;
    --LET vusuario       = 'informix'; --Para pruebas de ejecuciÃ³n	
    LET vmin_cta       = '';                  
    LET vmax_cta       = '';  
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
    LET vcuentaini     = '';
    LET vnum_cte       = '';
    LET vejecutivo     = '';
    LET vgenero        = '';
    LET vpri_hab_mes   = '';
	
	LET vcuentafin     = '';
    
    BEGIN

    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/gen_archsdos_ant_comp7.err";
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
                       'WHERE empresa = '''||vempresa||''' '||
                       'AND proceso   = '''||vproceso||''' '||
                       'AND fecha     = '''||vfecha_hoy||''' '||
                       'AND sistema   = '''||vsistema||''';" > /tmp/horassdosdia7.sql';
            SYSTEM vsql;
            
            LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horassdosdia7.sql';
            SYSTEM vstmt;
            RETURN vcodret1, vcodret2, vcodret3, vcontador1;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/gen_archsdos_ant_comp7.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // Obtiene fechas del sistema
    SELECT fecha_hoy, fecha_ant, pri_hab_mes
      INTO vfecha_hoy, vfecha_ant, vpri_hab_mes
      FROM sc_fechas
     WHERE empresa = vempresa;
     
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
     
    -- // Guarda proceso en tabla de control de proceso de integral
    SELECT count(*)
      INTO vexiste
      FROM bdinteg:sx_contproc
     WHERE empresa = vempresa
       AND proceso = vproceso
       AND fecha   = vfecha_hoy
       AND sistema = vsistema;
    
	
	--Comentar este 'IF' para pruebas
    IF vexiste = 0 THEN
        LET vsql = 'echo "INSERT INTO bdinteg:sx_contproc VALUES '||
                   '('''||vempresa||''', '''||vproceso||''', '''||vfecha_hoy||''', '''||vsistema||''', '''||'I'||''', '''||vusuario||''', '||
                   '(SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas), NULL, NULL);" > /tmp/horassdosdia7.sql';
        SYSTEM vsql;
        
        LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horassdosdia7.sql';
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
                       'AND sistema   = '''||vsistema||''';" > /tmp/horassdosdia7.sql';
            SYSTEM vsql;
            
            LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horassdosdia7.sql';
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
     
	SELECT valor
      INTO vcuentaini
      FROM sc_param
     WHERE empresa = vempresa
       AND codparam = 'CtaIniActuaSdosComp6';
    
    SELECT valor
      INTO vcuentafin
      FROM sc_param
     WHERE empresa = vempresa
       AND codparam = 'CtaIniActuaSdosComp7';
    
              
    SELECT cuenta, monto_tot
      FROM sc_movdia
     WHERE empresa = vempresa
       AND cuenta >= vcuentaini
       AND cuenta <  vcuentafin
       AND cancelad <> 'S'
       AND transacc = vtrancobsbg
       AND fech_alt = vfecha_hoy
       AND producto != vprodcrec 
    INTO TEMP tmp_movs_sbg WITH NO LOG;
    CREATE INDEX idxtmp_movs_sbg ON tmp_movs_sbg(cuenta) ONLINE;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_movs_sbg;
    
    
    IF vfecha_hoy = vpri_hab_mes THEN
    
        FOREACH WITH HOLD
            SELECT chq.cuenta, chq.sucursal, chq.sdo_dia_ant, chq.imp_chq_sbg, noc.int_acum, noc.acum_sdo_int,
                   chq.producto, chq.status_cta, chq.fecha_proceso, chq.fec_ult_mov, chq.sdo_actual, chq.num_cte, noc.ejecutivo
              INTO vcuenta, vsucursal, vsdo_dia_ant, vimp_chq_sbg, vint_acum, vacum_sdo_int,
                   vproducto, vstatus_cta, vfecha_proceso, vfec_ult_mov, vsdo_actual, vnum_cte, vejecutivo
              FROM sc_maechq chq, 
                   sc_maenoc noc
             WHERE chq.cuenta >= vcuentaini
               AND chq.cuenta <  vcuentafin
               AND chq.producto != vprodcrec 
			   AND ( chq.status_cta IN('1','3','4','5','6','8') OR ( chq.status_cta = '2' AND chq.fec_cancelac = vfecha_hoy ) )
               AND noc.cuenta = chq.cuenta
               AND noc.fecha_alta < vfecha_hoy
               --AND ( chq.status_cta NOT IN('2','7') OR ( chq.status_cta = '2' AND fec_cancelac = vfecha_hoy ) )
                 
            IF vcomienza = -1 THEN
                LET vcomienza = 0;
                LET ven_transacc = 1; 
                BEGIN WORK;
            END IF;

            SELECT SUM(monto_tot)
              INTO vmonto_sbg
              FROM tmp_movs_sbg
             WHERE cuenta = vcuenta;
             
            IF vmonto_sbg is null THEN
                LET vmonto_sbg = 0.00;
            END IF;
               
            LET vimp_chq_sbg = vimp_chq_sbg + vmonto_sbg;
            
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
            
            /* ##########################################################################################
            -- // Actualiza tabla de saldos mensuales y provisiones no capitalizadas..
            IF vmes_actual <> vmes_siguiente THEN
                CALL sp_actsdomensualc(vcuenta, vsucursal, vsdo_dia_ant, vacum_sdo_int, vanio, vmes) 
                RETURNING vcodret1;
                
                CALL sp_actsdotrimestralc(vcuenta, vsucursal, vanio, vmes)
                RETURNING vcodret1;
            END IF;
            ########################################################################################## */
            
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
            SELECT chq.cuenta, chq.sucursal, chq.sdo_dia_ant, chq.imp_chq_sbg, noc.int_acum, noc.acum_sdo_int,
                   chq.producto, chq.status_cta, chq.fecha_proceso, chq.fec_ult_mov, chq.sdo_actual, chq.num_cte, noc.ejecutivo
              INTO vcuenta, vsucursal, vsdo_dia_ant, vimp_chq_sbg, vint_acum, vacum_sdo_int,
                   vproducto, vstatus_cta, vfecha_proceso, vfec_ult_mov, vsdo_actual, vnum_cte, vejecutivo
              FROM sc_maechq chq, 
                   sc_maenoc noc
             WHERE chq.cuenta >= vcuentaini
               AND chq.cuenta <  vcuentafin
               AND chq.producto != vprodcrec 
			   AND ( chq.status_cta IN('1','3','4','5','6','8') OR ( chq.status_cta = '2' AND chq.fec_cancelac = vfecha_hoy ) )
               AND noc.cuenta = chq.cuenta
               AND noc.fecha_alta < vfecha_hoy
               --AND ( chq.status_cta NOT IN('2','7') OR ( chq.status_cta = '2' AND fec_cancelac = vfecha_hoy ) )
                 
            IF vcomienza = -1 THEN
                LET vcomienza = 0;
                LET ven_transacc = 1; 
                BEGIN WORK;
            END IF;

            SELECT SUM(monto_tot)
              INTO vmonto_sbg
              FROM tmp_movs_sbg
             WHERE cuenta = vcuenta;
             
            IF vmonto_sbg is null THEN
                LET vmonto_sbg = 0.00;
            END IF;
               
            LET vimp_chq_sbg = vimp_chq_sbg + vmonto_sbg;
            
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
            
            /* ##########################################################################################
            -- // Actualiza tabla de saldos mensuales y provisiones no capitalizadas..
            IF vmes_actual <> vmes_siguiente THEN
                CALL sp_actsdomensualc(vcuenta, vsucursal, vsdo_dia_ant, vacum_sdo_int, vanio, vmes) 
                RETURNING vcodret1;
                
                CALL sp_actsdotrimestralc(vcuenta, vsucursal, vanio, vmes)
                RETURNING vcodret1;
            END IF;
            ########################################################################################## */
            
            -- // INSERTA EN TABLAS DE LA CONCILIAION DE SALDOS E INTERESES
            INSERT INTO conciliachq VALUES
            ( vfecha_hoy, vcuenta, vproducto, vnum_cte, vgenero, vsucursal, vejecutivo, 
              0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00 );
              
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
    
    LET vsql = 'echo "UPDATE bdinteg:sx_contproc '||
               'SET ejecutivo = '''||vusuario||''','||
               'status_proc   = '''||'F'||''','||
               'codret        = '''||vcodret1||''','||
               'hora_fin      = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
               'WHERE empresa = '''||vempresa||''' '||
               'AND proceso   = '''||vproceso||''' '||
               'AND fecha     = '''||vfecha_hoy||''' '||
               'AND sistema   = '''||vsistema||''';" > /tmp/horassdosdia7.sql';
    SYSTEM vsql;
    
    LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horassdosdia7.sql';
    SYSTEM vstmt;
    
    END;

    RETURN vcodret1, vcodret2, vcodret3, vcontador1;

END PROCEDURE;
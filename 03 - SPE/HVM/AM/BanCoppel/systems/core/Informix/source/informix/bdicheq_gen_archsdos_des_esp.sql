CREATE PROCEDURE "informix".gen_archsdos_des_esp( pFechaHoy     DATE, 
                                                  pFechaAyer    DATE, 
                                                  pFechaAntier  DATE, 
                                                  pPriHabMes    DATE,
                                                  pUltDiaMesAnt DATE )
RETURNING CHAR(5), CHAR(5), CHAR(50), INTEGER;
    
    DEFINE vsql             char(600);
    DEFINE vstmt            char(300);
    DEFINE vaniomes         char(6);
    DEFINE vempresa         char(3);
    DEFINE vstatus_cta      char(1);
    DEFINE vcodret1         char(5); 
    DEFINE vcodret2         char(5);
    DEFINE desc_err         char(50);
    DEFINE vcodret3         char(50);
    DEFINE vproceso         char(10);
    DEFINE vusuario         char(10);
    DEFINE vcuenta          char(20);
    DEFINE vexiste_cta      char(20);
    DEFINE vexisteproc      char(20);
    DEFINE vexisteproc2     char(20);
    DEFINE vanio            char(4);
    DEFINE vsucursal        char(4);
    DEFINE vprodcrec        char(4);
    DEFINE vproducto        char(4);
    DEFINE vtrancobsbg      char(4);
    DEFINE vtranprovint     char(4);
    DEFINE vtrandesprovint  char(4);
    DEFINE vtranpagoint     char(4);
    DEFINE vmes_actual      char(2);
    DEFINE vmes_siguiente   char(2);
    DEFINE vdia             char(2);
    DEFINE vmes             char(2);
    DEFINE vsistema         char(2);
    DEFINE vcomienza        smallint;
    DEFINE ven_transacc     smallint;
    DEFINE vsqlerr          integer;
    DEFINE isam_err         integer;
    DEFINE vcontador1       integer;
    DEFINE vcontador2       integer;
    DEFINE vexiste          integer;
    DEFINE vexistefin       integer;
    DEFINE vexistecobsbg    integer;
    DEFINE vprovint         decimal(18,2);
    DEFINE vdesprov         decimal(18,2);
    DEFINE vpagoint         decimal(18,2);
    DEFINE vcap_ant         decimal(18,2);
    DEFINE vsdo_dia_ant     decimal(18,2);
    DEFINE vimp_chq_sbg     decimal(18,2);
    DEFINE vint_acum        decimal(18,2);
    DEFINE vacum_sdo_int    decimal(18,2);
    DEFINE vsdo_actual      decimal(18,2);
    DEFINE vmonto_sbg       decimal(18,2);
    DEFINE vfecha_hoy       date;
    DEFINE vfecha_ant       date;
    DEFINE vfecha_con       date;
    DEFINE vpri_hab_mes     date;
    DEFINE vfecha_alta      date;
    DEFINE vfecha_proceso   date;
    DEFINE vfec_ult_mov     date;
    DEFINE vcuentafin       char(20);
    DEFINE vult_hab_mes_ant DATE;
    
    LET vsql           = '';    
    LET vstmt          = '';   
    LET vaniomes       = '';
    LET vempresa       = '001';   
    LET vstatus_cta    = '';   
    LET vcodret1       = "000";               
    LET vcodret2       = '000';
    LET desc_err       = '';  
    LET vcodret3       = 'PROCESO CONCLUIDO SATISFACTORIAMENTE'; 
    LET vproceso       = 'sdoschqdes';   
    LET vusuario       = user;    
    LET vcuenta        = ''; 
    LET vexiste_cta    = ''; 
    LET vexisteproc    = '';
    LET vexisteproc2   = '';    
    LET vanio          = ''; 
    LET vsucursal      = '';
    LET vprodcrec      = '';  
    LET vproducto      = '';  
    LET vmes_actual    = '';                  
    LET vmes_siguiente = '';  
    LET vdia           = ''; 
    LET vmes           = '';    
    LET vsistema       = '01';   
    LET vcomienza      = -1;                  
    LET ven_transacc   = 0; 
    LET vsqlerr        = 0;                   
    LET isam_err       = 0;
    LET vcontador1     = 0;                   
    LET vcontador2     = 0;
    LET vexiste        = 0;                   
    LET vexistefin     = 0;
    LET vprovint       = 0.00;
    LET vdesprov       = 0.00;              
    LET vpagoint       = 0.00;
    LET vcap_ant       = 0.00; 
    LET vsdo_dia_ant   = 0.00;  
    LET vimp_chq_sbg   = 0.00;
    LET vint_acum      = 0.00;   
    LET vacum_sdo_int  = 0.00;
    LET vsdo_actual    = 0.00;
    LET vfecha_hoy     = '';                  
    LET vfecha_ant     = '';                
    LET vfecha_con     = '';                  
    LET vpri_hab_mes   = '';   
    LET vfecha_alta    = '';  
    LET vfecha_proceso = '';           
    LET vfec_ult_mov   = '';   
    LET vexistecobsbg  = 0;
    LET vmonto_sbg     = 0.00;    
    LET vtranprovint   = '';
    LET vtrandesprovint = '';
    LET vtranpagoint   = '';
    LET vcuentafin     = '';
    LET vult_hab_mes_ant = '';
                  
    BEGIN

    ON EXCEPTION SET vsqlerr, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/gen_archsdos_des.err";
        TRACE ON;
        IF vsqlerr <> 0 THEN
            LET vcodret1 = vsqlerr;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            IF ven_transacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            /* #################################################################################################
            LET vsql = 'echo "UPDATE bdinteg:sx_contproc '||
                       'SET ejecutivo = '''||vusuario||''','||
                       'status_proc   = '''||'C'||''','||
                       'codret        = '''||vcodret1||''','||
                       'hora_fin      = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
                       'WHERE empresa = '''||vempresa||''' '||
                       'AND proceso   = '''||vproceso||''' '||
                       'AND fecha     = '''||vfecha_hoy||''' '||
                       'AND sistema   = '''||vsistema||''';" > /tmp/horassdosdia.sql';
            SYSTEM vsql;
            LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horassdosdia.sql';
            SYSTEM vstmt;
            ################################################################################################# */
            RETURN vcodret1, vcodret2, vcodret3, vcontador1;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/gen_archsdos_des.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // OBTIENE FECHAS DEL SISTEMA
    SELECT fecha_hoy, fecha_ant, fecha_ant - 1 UNITS DAY, pri_hab_mes, pri_hab_mes - 1 UNITS DAY
      INTO vfecha_hoy, vfecha_ant, vfecha_con, vpri_hab_mes, vult_hab_mes_ant
      FROM sc_fechas
     WHERE empresa = vempresa;
	 
    LET vfecha_hoy       = pFechaHoy;
    LET vfecha_ant       = pFechaAyer;
    LET vfecha_con       = pFechaAntier;
    LET vpri_hab_mes     = pPriHabMes;
    LET vult_hab_mes_ant = pUltDiaMesAnt;
		
    /* ######################################################
    -- // VERIFICA PASO DE MOVS A HISTORICO DE CHEQUES
    SELECT proceso
      INTO vexisteproc
      FROM sc_contproc
     WHERE empresa = vempresa
       AND proceso = 'movdia_concil'
       AND fecha = vfecha_ant;
       
    IF vexisteproc is null OR vexisteproc = '' THEN 
        LET vcodret1 = '953';
        LET vcodret2 = '953';
        
        SELECT descripcion
          INTO vcodret3
          FROM bdinteg:si_codret
         WHERE sistema = vsistema
           AND codigo_retorno = vcodret1;
        
        RETURN vcodret1, vcodret2, vcodret3, vcontador1;
    END IF;
    ###################################################### */
    
    /* #######################################################################################
    -- // VERIFICA FINALIZACION DE ACTUALIZACION DE LA TABLA DE SALDOS (PRIMERA PARTE)
    SELECT proceso
      INTO vexisteproc2
      FROM bdinteg:sx_contproc
     WHERE sistema = vsistema
       AND proceso = 'sdoschqant'
       AND fecha = vfecha_hoy
       AND status_proc = 'F';
       
    IF vexisteproc2 is null OR vexisteproc2 = '' THEN 
        LET vcodret1 = '952';
        LET vcodret2 = '952';
        
        SELECT descripcion
          INTO vcodret3
          FROM bdinteg:si_codret
         WHERE sistema = vsistema
           AND codigo_retorno = vcodret1;
        
        RETURN vcodret1, vcodret2, vcodret3, vcontador1;
    END IF;
    ####################################################################################### */
    
    CALL sp_valfechabil(vfecha_con, '-')
    RETURNING vcodret1, vfecha_con;
    
    /* ##########################################################################################################################################
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
                   '(SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas), NULL, NULL);" > /tmp/horassdosdia.sql';
        SYSTEM vsql;
        
        LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horassdosdia.sql';
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
                       'hora_fin      = '''||' '||''','||
                       'hora_ini      = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
                       'WHERE empresa = '''||vempresa||''' '||
                       'AND proceso   = '''||vproceso||''' '||
                       'AND fecha     = '''||vfecha_hoy||''' '||
                       'AND sistema   = '''||vsistema||''';" > /tmp/horassdosdia.sql';
            SYSTEM vsql;
            
            LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horassdosdia.sql';
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
    ########################################################################################################################################## */
    
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
      INTO vtranprovint
      FROM sc_param
     WHERE empresa = vempresa
       AND codparam = 'tranprov';
       
    SELECT valor
      INTO vtrandesprovint
      FROM sc_param
     WHERE empresa = vempresa
       AND codparam = 'tranrevprov';
       
    SELECT valor
      INTO vtranpagoint
      FROM sc_param
     WHERE empresa = vempresa
       AND codparam = 'tranpagint';
    
    LET vmes_actual    = LPAD(MONTH(vfecha_ant), 2, '0');
    LET vmes_siguiente = LPAD(MONTH(vfecha_hoy), 2, '0');
    LET vaniomes       = YEAR(vfecha_ant)||LPAD(MONTH(vfecha_ant), 2, '0');
    LET vdia           = DAY(vfecha_ant);
    LET vmes           = LPAD(MONTH(vfecha_ant), 2, '0');
    LET vanio          = YEAR(vfecha_ant);
    
    SELECT valor
      INTO vcuentafin
      FROM sc_param
     WHERE empresa = vempresa
       AND codparam = 'CtaIniActuaSdosComp1';
    
    FOREACH WITH HOLD
        SELECT UNIQUE chq.cuenta, chq.sucursal, chq.sdo_dia_ant, chq.imp_chq_sbg, noc.int_acum, noc.acum_sdo_int, noc.fecha_alta,
               chq.producto, chq.status_cta, chq.fecha_proceso, chq.fec_ult_mov, chq.sdo_actual
          INTO vcuenta, vsucursal, vsdo_dia_ant, vimp_chq_sbg, vint_acum, vacum_sdo_int, vfecha_alta,
               vproducto, vstatus_cta, vfecha_proceso, vfec_ult_mov, vsdo_actual
          FROM sc_maechq_resp chq, 
               sc_maenoc_resp noc,
               sc_movhis mov
         WHERE chq.empresa = vempresa
           AND chq.cuenta < vcuentafin
           AND chq.producto != vprodcrec 
           AND chq.status_cta NOT IN('2','7')  
           AND noc.empresa = chq.empresa
           AND noc.cuenta = chq.cuenta
           AND noc.fecha_alta < vfecha_hoy
           AND mov.empresa = chq.empresa
           AND mov.cuenta = chq.cuenta
           AND mov.fech_alt = vfecha_ant
           AND mov.cancelad <> 'S'
           AND mov.transacc IN(vtranprovint,vtrandesprovint,vtranpagoint) 
           
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
        
        -- // PROVISIONES
        SELECT NVL(SUM(monto_tot), 0.00)
          INTO vprovint 
          FROM sc_movhis
         WHERE empresa = vempresa
           AND cuenta = vcuenta
           AND fech_alt = vfecha_ant
           AND cancelad <> 'S'
           AND transacc = vtranprovint;
         
        -- // DESPROVISIONES
        SELECT NVL(SUM(monto_tot), 0.00)
          INTO vdesprov
          FROM sc_movhis
         WHERE empresa = vempresa
           AND cuenta = vcuenta
           AND fech_alt = vfecha_ant
           AND cancelad <> 'S'
           AND transacc = vtrandesprovint;
         
        -- // PAGO DE INTERESES
        SELECT NVL(SUM(monto_tot), 0.00)
          INTO vpagoint
          FROM sc_movhis
         WHERE empresa = vempresa
           AND cuenta = vcuenta
           AND fech_alt = vfecha_ant
           AND cancelad <> 'S'
           AND transacc = vtranpagoint;
        
        IF DAY(vfecha_alta) = DAY(vfecha_hoy) THEN
            CALL sp_capintafecha(vcuenta, vfecha_con)
            RETURNING vcodret1, vcap_ant, vint_acum;
        END IF;
        
        IF vfecha_hoy = vpri_hab_mes THEN 
            IF DAY(vfecha_alta) <> DAY(vfecha_hoy) THEN 
                LET vint_acum = vprovint;
            END IF;
            
            IF DAY(vfecha_alta) > DAY(vult_hab_mes_ant) THEN
                LET vint_acum = 0.00;
            END IF;
        ELSE 
            LET vprovint = vprovint - vdesprov;
            LET vint_acum = ((vint_acum + vprovint) - vpagoint);
        END IF; 
        
        -- // Actualiza tabla de saldos diarios y provisiones no capitalizadas..        
        SELECT cuenta
          INTO vexiste_cta
          FROM sc_sdodiarioc
         WHERE cuenta = vcuenta
           AND aniomes = vaniomes;
           
        IF vexiste_cta is not null OR vexiste_cta <> '' THEN
            UPDATE sc_sdodiarioc 
               SET intprovnp1  =  DECODE(vdia,1,vint_acum,intprovnp1),
                   intprovnp2  =  DECODE(vdia,2,vint_acum,intprovnp2),
                   intprovnp3  =  DECODE(vdia,3,vint_acum,intprovnp3),
                   intprovnp4  =  DECODE(vdia,4,vint_acum,intprovnp4),
                   intprovnp5  =  DECODE(vdia,5,vint_acum,intprovnp5),
                   intprovnp6  =  DECODE(vdia,6,vint_acum,intprovnp6),
                   intprovnp7  =  DECODE(vdia,7,vint_acum,intprovnp7),
                   intprovnp8  =  DECODE(vdia,8,vint_acum,intprovnp8),
                   intprovnp9  =  DECODE(vdia,9,vint_acum,intprovnp9),
                   intprovnp10 =  DECODE(vdia,10,vint_acum,intprovnp10),
                   intprovnp11 =  DECODE(vdia,11,vint_acum,intprovnp11),
                   intprovnp12 =  DECODE(vdia,12,vint_acum,intprovnp12),
                   intprovnp13 =  DECODE(vdia,13,vint_acum,intprovnp13),
                   intprovnp14 =  DECODE(vdia,14,vint_acum,intprovnp14),
                   intprovnp15 =  DECODE(vdia,15,vint_acum,intprovnp15),
                   intprovnp16 =  DECODE(vdia,16,vint_acum,intprovnp16),
                   intprovnp17 =  DECODE(vdia,17,vint_acum,intprovnp17),
                   intprovnp18 =  DECODE(vdia,18,vint_acum,intprovnp18),
                   intprovnp19 =  DECODE(vdia,19,vint_acum,intprovnp19),
                   intprovnp20 =  DECODE(vdia,20,vint_acum,intprovnp20),
                   intprovnp21 =  DECODE(vdia,21,vint_acum,intprovnp21),
                   intprovnp22 =  DECODE(vdia,22,vint_acum,intprovnp22),
                   intprovnp23 =  DECODE(vdia,23,vint_acum,intprovnp23),
                   intprovnp24 =  DECODE(vdia,24,vint_acum,intprovnp24),
                   intprovnp25 =  DECODE(vdia,25,vint_acum,intprovnp25),
                   intprovnp26 =  DECODE(vdia,26,vint_acum,intprovnp26),
                   intprovnp27 =  DECODE(vdia,27,vint_acum,intprovnp27),
                   intprovnp28 =  DECODE(vdia,28,vint_acum,intprovnp28),
                   intprovnp29 =  DECODE(vdia,29,vint_acum,intprovnp29),
                   intprovnp30 =  DECODE(vdia,30,vint_acum,intprovnp30),
                   intprovnp31 =  DECODE(vdia,31,vint_acum,intprovnp31)
             WHERE cuenta = vcuenta
               AND aniomes = vaniomes;
        ELSE
            INSERT INTO sc_sdodiarioc 
            VALUES (vcuenta, vaniomes, vsucursal,
                    DECODE(vdia,1,vsdo_dia_ant,0),
                    DECODE(vdia,1,vint_acum,0),
                    DECODE(vdia,2,vsdo_dia_ant,0),
                    DECODE(vdia,2,vint_acum,0),
                    DECODE(vdia,3,vsdo_dia_ant,0),
                    DECODE(vdia,3,vint_acum,0),
                    DECODE(vdia,4,vsdo_dia_ant,0),
                    DECODE(vdia,4,vint_acum,0),
                    DECODE(vdia,5,vsdo_dia_ant,0),
                    DECODE(vdia,5,vint_acum,0),
                    DECODE(vdia,6,vsdo_dia_ant,0),
                    DECODE(vdia,6,vint_acum,0),
                    DECODE(vdia,7,vsdo_dia_ant,0),
                    DECODE(vdia,7,vint_acum,0),
                    DECODE(vdia,8,vsdo_dia_ant,0),
                    DECODE(vdia,8,vint_acum,0),
                    DECODE(vdia,9,vsdo_dia_ant,0),
                    DECODE(vdia,9,vint_acum,0),
                    DECODE(vdia,10,vsdo_dia_ant,0),
                    DECODE(vdia,10,vint_acum,0),
                    DECODE(vdia,11,vsdo_dia_ant,0),
                    DECODE(vdia,11,vint_acum,0),
                    DECODE(vdia,12,vsdo_dia_ant,0),
                    DECODE(vdia,12,vint_acum,0),
                    DECODE(vdia,13,vsdo_dia_ant,0),
                    DECODE(vdia,13,vint_acum,0),
                    DECODE(vdia,14,vsdo_dia_ant,0),
                    DECODE(vdia,14,vint_acum,0),
                    DECODE(vdia,15,vsdo_dia_ant,0),
                    DECODE(vdia,15,vint_acum,0),
                    DECODE(vdia,16,vsdo_dia_ant,0),
                    DECODE(vdia,16,vint_acum,0),
                    DECODE(vdia,17,vsdo_dia_ant,0),
                    DECODE(vdia,17,vint_acum,0),
                    DECODE(vdia,18,vsdo_dia_ant,0),
                    DECODE(vdia,18,vint_acum,0),
                    DECODE(vdia,19,vsdo_dia_ant,0),
                    DECODE(vdia,19,vint_acum,0),
                    DECODE(vdia,20,vsdo_dia_ant,0),
                    DECODE(vdia,20,vint_acum,0),
                    DECODE(vdia,21,vsdo_dia_ant,0),
                    DECODE(vdia,21,vint_acum,0),
                    DECODE(vdia,22,vsdo_dia_ant,0),
                    DECODE(vdia,22,vint_acum,0),
                    DECODE(vdia,23,vsdo_dia_ant,0),
                    DECODE(vdia,23,vint_acum,0),
                    DECODE(vdia,24,vsdo_dia_ant,0),
                    DECODE(vdia,24,vint_acum,0),
                    DECODE(vdia,25,vsdo_dia_ant,0),
                    DECODE(vdia,25,vint_acum,0),
                    DECODE(vdia,26,vsdo_dia_ant,0),
                    DECODE(vdia,26,vint_acum,0),
                    DECODE(vdia,27,vsdo_dia_ant,0),
                    DECODE(vdia,27,vint_acum,0),
                    DECODE(vdia,28,vsdo_dia_ant,0),
                    DECODE(vdia,28,vint_acum,0),
                    DECODE(vdia,29,vsdo_dia_ant,0),
                    DECODE(vdia,29,vint_acum,0),
                    DECODE(vdia,30,vsdo_dia_ant,0),
                    DECODE(vdia,30,vint_acum,0),
                    DECODE(vdia,31,vsdo_dia_ant,0),
                    DECODE(vdia,31,vint_acum,0),
                    vsdo_dia_ant, 1, 'F');
        END IF;
        
        -- // Actualiza tabla de saldos mensuales y provisiones no capitalizadas..
        IF vmes_actual <> vmes_siguiente THEN
            CALL sp_actsdomensualc(vcuenta, vsucursal, vsdo_dia_ant, vacum_sdo_int, vanio, vmes) 
            RETURNING vcodret1;
        END IF
        
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
        LET vfecha_alta    = '';
        LET vprovint       = 0.00;
        LET vdesprov       = 0.00;
        LET vpagoint       = 0.00;
        LET vcap_ant       = 0.00;
        LET vproducto      = '';
        LET vstatus_cta    = '';                
        LET vfecha_proceso = '';
        LET vsdo_actual    = 0.00;
        LET vfec_ult_mov   = '';
        LET vexistecobsbg  = 0;
        LET vmonto_sbg     = 0.00;
    END FOREACH;
    
    IF ven_transacc = 1 THEN
        LET ven_transacc = 0;
        COMMIT WORK;
    END IF;
    
    /* ################################################################################################
    LET vsql = 'echo "UPDATE bdinteg:sx_contproc '||
               'SET ejecutivo = '''||vusuario||''','||
               'status_proc   = '''||'F'||''','||
               'codret        = '''||vcodret1||''','||
               'hora_fin      = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
               'WHERE empresa = '''||vempresa||''' '||
               'AND proceso   = '''||vproceso||''' '||
               'AND fecha     = '''||vfecha_hoy||''' '||
               'AND sistema   = '''||vsistema||''';" > /tmp/horassdosdia.sql';
    SYSTEM vsql;
    
    LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horassdosdia.sql';
    SYSTEM vstmt;
    ################################################################################################ */
    
    END;

    RETURN vcodret1, vcodret2, vcodret3, vcontador1;

END PROCEDURE;
CREATE PROCEDURE "informix".gen_archsdos()

RETURNING CHAR(5), CHAR(5), INTEGER;

    -- ***********************************************************************
    -- * cierre_diario                                                       *
    -- * Version              1.0.0                                          *
    -- * Obejtivo:            Genera archivos de saldos diarios y mensuales  *
    -- * Creado por:                                                         *
    -- * ModIFicado por:      Alejandro Rueda Sanchez                        *
    -- * Ultima Modificacion: Septiembre 2009                                *
    -- *                     Creación de SPL                                 *
    -- ***********************************************************************

    DEFINE aniomes char(6);
    DEFINE vcodret1, vcodret2 char(5);
    DEFINE vanio, vsucursal, vprodcrec char(4);
    DEFINE vmes_actual, vmes_siguiente, vdia, vmes char(2);
    DEFINE vcuenta, vmin_cta, vmax_cta, vmincta, vmaxcta, vexiste char(20);
    
    DEFINE ven_transacc smallint;
    DEFINE vsqlerr, isam_err, vcontador1, vcuantos1 integer;

    DEFINE vprovint, vdesprov, vpagoint, vcap_ant decimal(14,2);
    DEFINE vsdo_dia_ant, vimp_chq_sbg, vint_acum, vacum_sdo_int decimal(14,2);
    
    DEFINE vfecha_hoy, vfecha_ant, vfecha_con, vpri_hab_mes, vfecha_alta date;
    
    BEGIN

    ON EXCEPTION SET vsqlerr, isam_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/gen_archsdos.err";
        TRACE ON;
        IF vsqlerr <> 0 THEN
            LET vcodret1 = vsqlerr;
            LET vcodret2 = isam_err;
            IF ven_transacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcodret1, vcodret2, vcuantos1;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/gen_archsdos.out";
    --- TRACE ON;

    LET vcodret1     = "000";
    LET vcodret2     = '000';
    LET vsqlerr      = 0;
    LET isam_err     = 0;
    LET vcontador1   = -1;
    LET vcuantos1    = 0;
    LET ven_transacc = 0; 
    
    LET vfecha_hoy     = '';
    LET vfecha_ant     = '';
    LET vfecha_con     = '';
    LET vpri_hab_mes   = '';
    LET vmes_actual    = 0;
    LET vmes_siguiente = 0;
    LET aniomes        = '';
    LET vdia           = '';
    LET vmes           = '';
    LET vanio          = '';
    LET vmin_cta       = '';
    LET vmax_cta       = '';
    LET vmincta        = '';
    LET vmaxcta        = '';
    LET vprodcrec      = '';
    
    LET vexiste       = '';
    LET vcuenta       = '';
    LET vsucursal     = '';
    LET vsdo_dia_ant  = 0.00;
    LET vimp_chq_sbg  = 0.00;
    LET vint_acum     = 0.00;
    LET vacum_sdo_int = 0.00;
    LET vfecha_alta   = '';
    LET vprovint      = 0.00;
    LET vdesprov      = 0.00;
    LET vpagoint      = 0.00;
    LET vcap_ant      = 0.00;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    SELECT fecha_hoy, fecha_ant, fecha_ant - 1 UNITS DAY, pri_hab_mes
      INTO vfecha_hoy, vfecha_ant, vfecha_con, vpri_hab_mes
      FROM sc_fechas
     WHERE empresa = '001';
     
    CALL sp_valfechabil(vfecha_con, '-')
    RETURNING vcodret1, vfecha_con;
    
    SELECT proceso
      INTO vexiste
      FROM bdinteg:sx_contproc
     WHERE proceso = 'PasaMovsHist'
       AND fecha = vfecha_hoy
       AND sistema = '01'
       AND status_proc = 'F';
       
    IF vexiste is null OR vexiste = '' THEN 
        LET vcodret1 = '953';
        RETURN vcodret1, vcodret2, vcuantos1;
    END IF;
    
    SELECT MIN(cuenta), MAX(cuenta)
      INTO vmincta, vmaxcta
      FROM sc_movhis;
    
    SELECT {+INDEX(sc_movhis idx_movhisnew4)}
           cuenta, monto_tot
      FROM sc_movhis
     WHERE empresa = '001'
       AND cuenta BETWEEN vmincta AND vmaxcta
       AND fech_alt = vfecha_ant
       AND cancelad != 'S'
       AND transacc = '3381'
      INTO TEMP tmp_provint WITH NO LOG;
    CREATE INDEX idx_provint ON tmp_provint(cuenta) USING BTREE FILLFACTOR 99;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_provint;
    
    SELECT {+INDEX(sc_movhis idx_movhisnew4)}
           cuenta, monto_tot
      FROM sc_movhis
     WHERE empresa = '001'
       AND cuenta BETWEEN vmincta AND vmaxcta
       AND fech_alt = vfecha_ant
       AND cancelad != 'S'
       AND transacc = '3382'
      INTO TEMP tmp_desprov WITH NO LOG;
    CREATE INDEX idx_desprov ON tmp_desprov(cuenta) USING BTREE FILLFACTOR 99;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_desprov;
    
    SELECT {+INDEX(sc_movhis idx_movhisnew4)}
           cuenta, monto_tot
      FROM sc_movhis
     WHERE empresa = '001'
       AND cuenta BETWEEN vmincta AND vmaxcta
       AND fech_alt = vfecha_ant
       AND cancelad != 'S'
       AND transacc = '3276'
      INTO TEMP tmp_pagoint WITH NO LOG;
    CREATE INDEX idx_pagoint ON tmp_pagoint(cuenta) USING BTREE FILLFACTOR 99;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_pagoint;
    
    LET vmes_actual = LPAD(MONTH(vfecha_ant), 2, '0');
    LET vmes_siguiente = LPAD(MONTH(vfecha_hoy), 2, '0');
    LET aniomes = YEAR(vfecha_ant)||LPAD(MONTH(vfecha_ant), 2, '0');
    LET vdia = DAY(vfecha_ant);
    LET vmes = LPAD(MONTH(vfecha_ant), 2, '0');
    LET vanio = YEAR(vfecha_ant);
    
    SELECT valor
      INTO vprodcrec
      FROM sc_param
     WHERE empresa = '001'
       AND codparam = 'PRODCREC';
    
    SELECT MIN(cuenta), MAX(cuenta)
      INTO vmin_cta, vmax_cta
      FROM sc_maechq;
    
    FOREACH WITH HOLD
        SELECT chq.cuenta, chq.sucursal, chq.sdo_dia_ant, chq.imp_chq_sbg, noc.int_acum, noc.acum_sdo_int, noc.fecha_alta
          INTO vcuenta, vsucursal, vsdo_dia_ant, vimp_chq_sbg, vint_acum, vacum_sdo_int, vfecha_alta
          FROM sc_maechq chq, 
               sc_maenoc noc
         WHERE chq.empresa = '001'
           AND chq.cuenta BETWEEN vmin_cta AND vmax_cta
           AND ( ( chq.producto != vprodcrec AND chq.status_cta != '2' ) OR
                 ( chq.producto  = vprodcrec AND chq.status_cta != '2' ) OR
                 ( chq.producto  = vprodcrec AND chq.status_cta  = '2' AND chq.fecha_proceso >= vfecha_ant ) OR
                 ( chq.producto  = vprodcrec AND chq.status_cta  = '2' AND chq.fecha_proceso is null AND chq.fec_ult_mov >= vfecha_ant ) )
           AND noc.empresa = chq.empresa
           AND noc.cuenta = chq.cuenta
           
        IF vcontador1 = -1 THEN
            LET vcontador1 = 0;
            LET ven_transacc = 1; 
            BEGIN WORK;
        END IF;

        IF vimp_chq_sbg < 0 THEN
            LET vimp_chq_sbg = vimp_chq_sbg * -1;
        END IF

        LET vsdo_dia_ant = vsdo_dia_ant - vimp_chq_sbg;
        
        -- // PROVISIONES
        SELECT NVL(SUM(monto_tot), 0.00)
          INTO vprovint 
          FROM tmp_provint
         WHERE cuenta = vcuenta;
         
        -- // DESPROVISIONES
        SELECT NVL(SUM(monto_tot), 0.00)
          INTO vdesprov
          FROM tmp_desprov
         WHERE cuenta = vcuenta;
         
        -- // PAGO DE INTERESES
        SELECT NVL(SUM(monto_tot), 0.00)
          INTO vpagoint
          FROM tmp_pagoint
         WHERE cuenta = vcuenta;
        
        IF DAY(vfecha_alta) = DAY(vfecha_hoy) THEN
            CALL sp_capintafecha(vcuenta, vfecha_con)
            RETURNING vcodret1, vcap_ant, vint_acum;
        END IF;
        
        IF vfecha_hoy = vpri_hab_mes THEN 
            IF DAY(vfecha_alta) <> DAY(vfecha_hoy) THEN 
                LET vint_acum = vprovint;
            END IF;
        ELSE 
            LET vprovint = vprovint - vdesprov;
            LET vint_acum = ((vint_acum + vprovint) - vpagoint);
        END IF; 
        
        -- // Actualiza tabla de saldos diarios y provisiones no capitalizadas..        
        CALL sp_actsdodiarioc(vcuenta, aniomes, vsucursal, vsdo_dia_ant, vint_acum, vdia) 
        RETURNING vcodret1;
        
        -- // Actualiza tabla de saldos mensuales y provisiones no capitalizadas..
        IF vmes_actual <> vmes_siguiente THEN
            CALL sp_actsdomensualc(vcuenta, vsucursal, vsdo_dia_ant, vacum_sdo_int, vanio, vmes) 
            RETURNING vcodret1;
        END IF
        
        LET vcontador1 = vcontador1 + 1;

        IF (vcontador1 >= 7500) THEN
            LET vcuantos1 = vcuantos1 + vcontador1;
            LET vcontador1 = 0;
            COMMIT WORK;
            BEGIN WORK;
        END IF;
        
        LET vcuenta       = '';
        LET vsucursal     = '';
        LET vsdo_dia_ant  = 0.00;
        LET vimp_chq_sbg  = 0.00;
        LET vint_acum     = 0.00;
        LET vacum_sdo_int = 0.00;
        LET vfecha_alta   = '';
        LET vprovint      = 0.00;
        LET vdesprov      = 0.00;
        LET vpagoint      = 0.00;
        LET vcap_ant      = 0.00;
    END FOREACH;
    
    IF ven_transacc = 1 THEN
        LET vcuantos1 = vcuantos1 + vcontador1;
        LET ven_transacc = 0;
        COMMIT WORK;
    END IF;
    
    END;

    RETURN vcodret1, vcodret2, vcuantos1;

END PROCEDURE;
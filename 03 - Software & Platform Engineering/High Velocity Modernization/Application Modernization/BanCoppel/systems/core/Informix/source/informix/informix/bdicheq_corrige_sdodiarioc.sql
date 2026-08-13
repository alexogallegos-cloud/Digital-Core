CREATE PROCEDURE "informix".corrige_sdodiarioc(pempresa char(3))
    
RETURNING CHAR(5), CHAR(5), INTEGER;
    
    DEFINE vcodret1         CHAR(5);
    DEFINE vcodret2         CHAR(5);
    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE nComit           SMALLINT;
    DEFINE vcuantos         INTEGER;
    
    DEFINE vfecha_hoy       DATE;
    DEFINE vfecha_ant       DATE;
    DEFINE vfecha_con       DATE;
    DEFINE vpri_hab_mes     DATE;
    DEFINE vdia             CHAR(2);
    DEFINE vaniomes         CHAR(6);
    
    DEFINE vmincta          CHAR(20);
    DEFINE vmaxcta          CHAR(20);
    DEFINE vmin_cta         CHAR(20);
    DEFINE vmax_cta         CHAR(20);
    
    DEFINE vcuenta          CHAR(20);
    DEFINE vsucursal        CHAR(4);
    DEFINE vsdo_dia_ant     MONEY(18,2);
    DEFINE vimp_chq_sbg     MONEY(18,2);
    DEFINE vint_acum        MONEY(18,2);
    DEFINE vfecha_alta      DATE;
    DEFINE vprovint         MONEY(18,2);
    DEFINE vdesprov         MONEY(18,2);
    DEFINE vpagoint         MONEY(18,2);
    DEFINE vcap_ant         MONEY(18,2);
    
    BEGIN

    ON EXCEPTION SET sql_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/corrige_sdodiarioc.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            IF nComit = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcodret1, vcodret2, vcuantos;
        END IF;
    END EXCEPTION;

    --- SET DEBUG FILE TO "/resplogifx/conciliachq/corrige_sdodiarioc.out";
    --- TRACE ON;

    LET vcodret1  = "000";
    LET vcodret2  = "000";
    LET sql_err   = 0;
    LET isam_err  = 0;
    LET nComit    = 0;
    LET vcuantos  = -1;
    
    LET vfecha_hoy   = '07/10/2010';
    LET vfecha_ant   = '07/09/2010';
    LET vfecha_con   = '07/08/2010';
    LET vpri_hab_mes = '07/01/2010';
    LET vdia         = DAY(vfecha_ant);
    LET vaniomes     = YEAR(vfecha_ant)||LPAD(MONTH(vfecha_ant),2,'0');
    
    LET vmincta  = '';
    LET vmaxcta  = '';
    LET vmin_cta = '';
    LET vmax_cta = '';
    
    LET vcuenta      = ''; 
    LET vsucursal    = '';
    LET vsdo_dia_ant = 0.00;
    LET vimp_chq_sbg = 0.00;
    LET vint_acum    = 0.00;
    LET vfecha_alta  = '';
    LET vprovint     = 0.00;
    LET vdesprov     = 0.00;
    LET vpagoint     = 0.00;
    LET vcap_ant     = 0.00;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    SELECT MIN(cuenta), MAX(cuenta)
      INTO vmincta, vmaxcta
      FROM sc_movhis;
    
    SELECT {+INDEX(sc_movhis idx_movhisnew4)}
           cuenta, monto_tot
      FROM sc_movhis
     WHERE empresa = pempresa
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
     WHERE empresa = pempresa
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
     WHERE empresa = pempresa
       AND cuenta BETWEEN vmincta AND vmaxcta
       AND fech_alt = vfecha_ant
       AND cancelad != 'S'
       AND transacc = '3276'
      INTO TEMP tmp_pagoint WITH NO LOG;
    CREATE INDEX idx_pagoint ON tmp_pagoint(cuenta) USING BTREE FILLFACTOR 99;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_pagoint;
    
    SELECT MIN(cuenta), MAX(cuenta)
      INTO vmin_cta, vmax_cta
      FROM maechq_10Jul2010;
    
    FOREACH WITH HOLD
        SELECT chq.cuenta, chq.sucursal, chq.sdo_dia_ant, chq.imp_chq_sbg, noc.int_acum, noc.fecha_alta
          INTO vcuenta, vsucursal, vsdo_dia_ant, vimp_chq_sbg, vint_acum, vfecha_alta
          FROM maechq_10jul2010 chq, 
               maenoc_10jul2010 noc
         WHERE chq.empresa = pempresa
           AND chq.cuenta BETWEEN vmin_cta AND vmax_cta
           AND chq.status_cta != '2'
           AND noc.empresa = chq.empresa
           AND noc.cuenta = chq.cuenta
    
        IF vcuantos = -1 THEN
            LET nComit = 1;
            LET vcuantos = 0;
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
        CALL sp_actsdodiarioc(vcuenta, vaniomes, vsucursal, vsdo_dia_ant, vint_acum, vdia) 
        RETURNING vcodret1;
        
        LET vcuantos = vcuantos + 1;
        
        COMMIT WORK;
        BEGIN WORK;
        
        LET vcuenta      = ''; 
        LET vsucursal    = '';
        LET vsdo_dia_ant = 0.00;
        LET vimp_chq_sbg = 0.00;
        LET vint_acum    = 0.00;
        LET vfecha_alta  = '';
        LET vprovint     = 0.00;
        LET vdesprov     = 0.00;
        LET vpagoint     = 0.00;
        LET vcap_ant     = 0.00;
    END FOREACH;

    IF nComit = 1 THEN
        COMMIT WORK;
        LET nComit = 0;
    END IF;

    END;

    RETURN vcodret1, vcodret2, vcuantos;

END PROCEDURE;
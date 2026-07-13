CREATE PROCEDURE "informix".arr_invcrec_12262009(pempresa char(3))

RETURNING CHAR(5), CHAR(5), INTEGER, INTEGER;

    DEFINE vcodret          CHAR(5);
    DEFINE vcodret1         CHAR(5);
    DEFINE vcodret2         CHAR(5);
    DEFINE vsqlerr          INTEGER;
    DEFINE visamerr         INTEGER;
    DEFINE vfecha_hoy		DATE;
    DEFINE vcuenta          CHAR(20);
    DEFINE vsdo_actual		DECIMAL(14,2);
    DEFINE vsdo_nuevo		DECIMAL(14,2);
    DEFINE vint_acum		DECIMAL(14,2);
    DEFINE visr             DECIMAL(14,2);
    DEFINE vintereses		DECIMAL(14,2);
    DEFINE vmonto_apertura	DECIMAL(14,2);
    DEFINE vhoraw       	CHAR(15);
    DEFINE vhora        	DATETIME HOUR TO FRACTION;
    DEFINE vfolio_suc   	CHAR(16);
    DEFINE vsucursal		CHAR(4);
    DEFINE vproducto		CHAR(4);
    DEFINE vstatus          CHAR(1);
    DEFINE vdiferencia		DECIMAL(14,2);
    DEFINE vexiste1         INTEGER;
    DEFINE vexiste2         INTEGER;
    DEFINE vcontador1       INTEGER;
    DEFINE vcontador2       INTEGER;
    DEFINE vcuantos1        INTEGER;
    DEFINE vcuantos2        INTEGER;
    DEFINE vcomienza        INTEGER;
    DEFINE vtransaccion     INTEGER;
    DEFINE vaniomescre      CHAR(6);
    DEFINE vacum_sdo_pos    DECIMAL(14,2);
    DEFINE vacum_sdo_int    DECIMAL(14,2);

    LET vcodret1     = "000";
    LET vcodret2     = "000";
    LET vhora        = current hour to fraction;
    LET vhoraw       = vhora;
    LET vhoraw       = vhoraw[1,2]||vhoraw[4,5]||vhoraw[7,8]||vhoraw[10,11];
    LET vfolio_suc   = "informix" ||vhoraw[1,8];
    LET vcontador1   = -1;
    LET vcontador2   = -1;
    LET vcuantos1    = 0;
    LET vcuantos2    = 0;
    LET vcomienza    = -1;
    LET vtransaccion = 0;

    --- SET DEBUG FILE TO "rpt_invcrec.out";
    --- TRACE ON;

    BEGIN
    
    ON EXCEPTION SET vsqlerr, visamerr
        IF vsqlerr <> 0 THEN
            LET vcodret1 = vsqlerr;
            LET vcodret2 = visamerr;
            IF vtransaccion = 1 THEN
                ROLLBACK WORK;
            END IF
            RETURN vcodret1, vcodret2, vcuantos1, vcuantos2;
        END IF;
    END EXCEPTION;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 2;
    
    IF EXISTS (SELECT tabname FROM sysmaster:systabnames
                WHERE partnum BETWEEN (SELECT MIN(partnum) FROM sysmaster:systabnames) AND
                                      (SELECT MAX(partnum) FROM sysmaster:systabnames)
                  AND tabname = 'cuentas_crecientes') THEN
        DROP TABLE cuentas_crecientes;
        CREATE RAW TABLE cuentas_crecientes(
            cuenta          CHAR(20),
            sdo_actual      MONEY(18,2),
            sdo_calculado   MONEY(18,2),
            diferencia      MONEY(18,2));
    ELSE
        CREATE RAW TABLE cuentas_crecientes(
            cuenta          CHAR(20),
            sdo_actual      MONEY(18,2),
            sdo_calculado   MONEY(18,2),
            diferencia      MONEY(18,2));
    END IF;
    
    SELECT {+INDEX(sc_fechas idx_fechas1)} fecha_hoy
      INTO vfecha_hoy
      FROM sc_fechas
     WHERE empresa = pempresa;

    FOREACH WITH HOLD
        SELECT {+INDEX(sc_maenoc idx_maenoc1)} mae.cuenta, mae.imp_chq_rem, mae.sdo_actual, mae.sucursal, mae.producto, mae.status_cta
          INTO vcuenta, vmonto_apertura, vsdo_actual, vsucursal, vproducto, vstatus
          FROM sc_maechq mae,
               sc_maenoc noc
         WHERE mae.producto = '1100'
           AND mae.status_cta = '1'
           AND mae.fecha_proceso >= '12242009'
           AND noc.empresa = mae.empresa
           AND noc.cuenta = mae.cuenta
           AND noc.fecha_mod = '12262009'
        
        IF vcomienza = -1 THEN
            LET vcomienza = 0;
            LET vcontador1 = 0;
            LET vcontador2 = 0;
            LET vtransaccion = 1;
            BEGIN WORK;
        END IF

        IF vsdo_actual is null THEN
            LET vsdo_actual = 0.00;
        END IF

        -- // INVERSION PASADA
        LET vintereses = 0.00;
        LET vsdo_nuevo = 0.00;
        LET vint_acum  = 0.00;
        LET visr       = 0.00;
        LET vexiste1   = 0;
        
        SELECT NVL(COUNT(*),0)
          INTO vexiste1
          FROM sc_tasa_var_hist
         WHERE empresa = pempresa
           AND cuenta = vcuenta
           AND inicio_periodo < vfecha_hoy
           AND tipo_tasa in("M","P");
        
        IF vexiste1 > 0 THEN
            SELECT NVL(SUM(int_acum),0)
              INTO vint_acum
              FROM sc_tasa_var_hist
             WHERE empresa = pempresa
               AND cuenta = vcuenta
               AND inicio_periodo < vfecha_hoy
               AND tipo_tasa in("M","P");
               
            SELECT NVL(SUM(isr),0)
              INTO visr
              FROM sc_tasa_var_hist
             WHERE empresa = pempresa
               AND cuenta = vcuenta
               AND inicio_periodo < vfecha_hoy
               AND tipo_tasa in("P");
        END IF

        LET vintereses = (vint_acum - visr);
        
        -- // INVERSION ACTUAL
        LET vint_acum  = 0.00;
        LET visr       = 0.00;
        LET vexiste2   = 0;
        
        SELECT NVL(COUNT(*),0)
          INTO vexiste2
          FROM sc_tasa_variable
         WHERE empresa = pempresa
           AND cuenta = vcuenta
           AND inicio_periodo < vfecha_hoy
           AND tipo_tasa in("M","P")
           AND fin_periodo < vfecha_hoy;
           
        IF vexiste2 > 0 THEN
            SELECT NVL(SUM(int_acum),0)
              INTO vint_acum
              FROM sc_tasa_variable
             WHERE empresa = pempresa
               AND cuenta = vcuenta
               AND inicio_periodo < vfecha_hoy
               AND tipo_tasa in("M","P")
               AND fin_periodo < vfecha_hoy;
               
            SELECT NVL(SUM(isr),0)
              INTO visr
              FROM sc_tasa_variable
             WHERE empresa = pempresa
               AND cuenta = vcuenta
               AND inicio_periodo < vfecha_hoy
               AND tipo_tasa in("P")
               AND fin_periodo < vfecha_hoy;
        END IF

        LET vintereses = (vintereses + (vint_acum - visr));

        LET vsdo_nuevo = vmonto_apertura + vintereses;
        LET vdiferencia = 0.00;
        
        IF vsdo_nuevo <> vsdo_actual THEN
        
            LET vdiferencia = vsdo_nuevo - vsdo_actual;

            IF vdiferencia > 0.00 THEN
            
                INSERT INTO cuentas_crecientes VALUES(vcuenta, vsdo_actual, vsdo_nuevo, vdiferencia);
                
                INSERT INTO sc_movdia 
                VALUES(0, vfolio_suc, vsucursal, "informix", vfecha_hoy, vfecha_hoy, vhora, 
                       "3276", vsucursal, vproducto, pempresa, vcuenta, " ", 0, vdiferencia, 
                       vdiferencia, 0, 0, 0,  " ", vstatus, vsdo_actual, "0000", "", 0, "", "");

                INSERT INTO sc_movdia 
                VALUES(0, vfolio_suc, vsucursal, "informix", vfecha_hoy, vfecha_hoy, vhora,
                       "3381", vsucursal, vproducto, pempresa, vcuenta, " ", 0, vdiferencia,
                       vdiferencia, 0, 0, 0, " ", vstatus, vsdo_actual, "0000", "", 0, "", "");
            END IF
            
            UPDATE sc_maechq
               SET sdo_actual = vsdo_nuevo
             WHERE empresa = pempresa
               AND cuenta = vcuenta;
            
            LET vcontador2 = vcontador2 + 1;
            
        END IF
        
        -- // REALIZA EL MOVIMIENTO DE RENOVACION ES REFERENCIAL
        INSERT INTO sc_movdia 
        VALUES(0, vfolio_suc, vsucursal, "informix", vfecha_hoy, vfecha_hoy, vhora,
               "3383", vsucursal, vproducto, pempresa, vcuenta, " ", 0, vsdo_nuevo,
               vsdo_nuevo, 0, 0, 0, " ", vstatus, vsdo_nuevo, "0000", "RENOVACION", 0, "", "");
        
        -- // Respalda la proyeccion actual en el historico
        LET vaniomescre = YEAR(vfecha_hoy)||LPAD(month(vfecha_hoy),2,0);
        
        INSERT INTO sc_tasa_var_hist
        SELECT vaniomescre, a.*
          FROM sc_tasa_variable a
         WHERE a.empresa = pempresa
           AND a.cuenta = vcuenta;
           
        -- // ELIMINA LA PROYECCION ACTUAL
        DELETE FROM sc_tasa_variable
         WHERE empresa = pempresa
           AND cuenta = vcuenta;
           
        -- // REALIZA LA ACTUALIZACION DEL MAESTRO NOCTURNO PARA GENERAR LA NUEVA PROYECCION
        LET vacum_sdo_pos = vsdo_nuevo * 2;
        LET vacum_sdo_int = (((vsdo_nuevo * 0.025) / 360) * 2);
        
        UPDATE sc_maenoc
           SET fecha_mod = NULL,
               fecha_alta = '12262009',
               dia_sdo_pos = 2,
               acum_sdo_pos = vacum_sdo_pos,
               int_acum = 0.00,
               isr_acum = 0.00,
               dias_acum_int = 2,
               acum_sdo_int = vacum_sdo_int
         WHERE empresa = pempresa
           AND cuenta = vcuenta;
           
        CALL creciente_proy_cierre(pempresa, vcuenta, vproducto, vsdo_nuevo)
        RETURNING vcodret;

        IF vcodret <> "000" THEN
            CONTINUE FOREACH;
        END IF
        
        LET vcontador1 = vcontador1 + 1;
        
        IF vcontador1 >= 75000 THEN
            LET vcuantos1 = vcuantos1 + vcontador1;
            LET vcontador1 = 0;
            UPDATE STATISTICS MEDIUM FOR TABLE cuentas_crecientes;
            COMMIT WORK;
            BEGIN WORK;
        END IF
        
    END FOREACH
    
    LET vcuantos2 = vcuantos2 + vcontador2;

    IF vcontador1 > 0 THEN
        LET vcuantos1 = vcuantos1 + vcontador1;
        UPDATE STATISTICS MEDIUM FOR TABLE cuentas_crecientes;
        COMMIT WORK;
    END IF

    END;

    RETURN vcodret1, vcodret2, vcuantos1, vcuantos2;

END PROCEDURE;
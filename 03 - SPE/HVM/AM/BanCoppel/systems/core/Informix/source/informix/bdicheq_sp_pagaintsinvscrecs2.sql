CREATE PROCEDURE "informix".sp_pagaintsinvscrecs2( pempresa CHAR(3) )
RETURNING CHAR(5), INTEGER, INTEGER;

    DEFINE vcodret1         CHAR(5);
    DEFINE vcodret2         CHAR(5);
    DEFINE vcodret3         CHAR(50);
    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE desc_err         CHAR(50);
    DEFINE vcontador1       INTEGER;
    DEFINE vcontador2       INTEGER;
    DEFINE vcontador3       INTEGER;
    DEFINE ven_transacc     SMALLINT;
    DEFINE vsql             CHAR(500);
    DEFINE vstmt            CHAR(200);
    DEFINE vfecha_hoy       DATE;
    DEFINE vhora            CHAR(15);
    DEFINE vfolio_suc       CHAR(16);
    DEFINE vcuenta          CHAR(20);
    DEFINE vstatus_cta      CHAR(1);
    DEFINE vsucursal        CHAR(4);
    DEFINE vproducto        CHAR(4);
    DEFINE vsdo_actual      DECIMAL(14,2);
    DEFINE vint_acum        DECIMAL(14,2); 
    DEFINE vacum_sdo_pos    DECIMAL(18,2);
    DEFINE vdia_sdo_pos     SMALLINT;
    DEFINE vfecha_alta      DATE;
    DEFINE vcuentadep       CHAR(20);
    DEFINE vtasa_mensual    DECIMAL(9,6);
    DEFINE vmonto_desprov   DECIMAL(14,2);
    DEFINE vtasa_premio     DECIMAL(9,6);
    DEFINE vmonto_meta      DECIMAL(14,2);
    DEFINE vvaltasa         DECIMAL(9,6);
    DEFINE visr_prem        DECIMAL(14,2);
    DEFINE vtotint          DECIMAL(14,2);
    DEFINE visr             DECIMAL(14,2);
    DEFINE vmonto_prov      DECIMAL(14,2);
    DEFINE vcodretcgoisr    CHAR(5);
    DEFINE vsucursaldep     CHAR(4);
    DEFINE vproductodep     CHAR(4);
    DEFINE vstatus_ctadep   CHAR(1);
    DEFINE vsdo_actualdep   DECIMAL(14,2);
    DEFINE vsdo_traspaso    DECIMAL(14,2);
    DEFINE vcodretmaehis    CHAR(5);
    DEFINE vexiste          SMALLINT;
    DEFINE vacepta_abonos   CHAR(1);
    DEFINE vsdo_promedio    DECIMAL(18,2);
    DEFINE vint_dia         DECIMAL(14,2);
    DEFINE vsdo_nuevo       DECIMAL(14,2);
    
    LET vcodret1       = '000';
    LET vcodret2       = '';
    LET vcodret3       = '';
    LET sql_err	       = 0;
    LET isam_err       = 0;
    LET desc_err       = '';
    LET vcontador1     = 0;
    LET vcontador2     = 0;
    LET vcontador3     = 0;
    LET ven_transacc   = 0;
    LET vsql           = '';
    LET vstmt          = '';
    LET vfecha_hoy     = '';
    LET vhora          = '';
    LET vfolio_suc     = '';
    LET vcuenta        = '';
    LET vstatus_cta    = '';
    LET vsucursal      = '';
    LET vproducto      = '';
    LET vsdo_actual    = 0.00;
    LET vint_acum      = 0.00;
    LET vacum_sdo_pos  = 0.00;
    LET vdia_sdo_pos   = 0;
    LET vfecha_alta    = '';
    LET vcuentadep     = '';
    LET vtasa_mensual  = 0.000000;
    LET vmonto_desprov = 0.00;
    LET vtasa_premio   = 0.000000;
    LET vmonto_meta    = 0.00;
    LET vvaltasa       = 0.000000;
    LET visr_prem      = 0.00;
    LET vtotint        = 0.00;
    LET visr           = 0.00;
    LET vmonto_prov    = 0.00;
    LET vcodretcgoisr  = '';
    LET vsucursaldep   = '';
    LET vproductodep   = '';
    LET vstatus_ctadep = '';
    LET vsdo_actualdep = 0.00;
    LET vsdo_traspaso  = 0.00;
    LET vcodretmaehis  = '';
    LET vexiste        = 0;
    LET vacepta_abonos = '';
    LET vsdo_promedio  = 0.00;
    LET vint_dia       = 0.00;
    LET vsdo_nuevo     = 0.00;
    
    BEGIN

    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_pagaintsinvscrecs2.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            IF ven_transacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcodret1, vcontador1, vcontador2;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_pagaintsinvscrecs2.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    SELECT fecha_hoy
      INTO vfecha_hoy
      FROM sc_fechas
     WHERE empresa = pempresa;
    
    SELECT a.cuenta
      FROM sc_tasa_var_hist a,
           sc_maechq b
     WHERE a.cuenta = b.cuenta  
       AND a.empresa = b.empresa
       AND a.inicio_periodo = '02/29/2016'
       AND a.fin_periodo = '02/28/2017'
       AND a.tipo_tasa = 'P' 
       AND b.status_cta = '1'
       AND b.fecha_proceso <> '02/27/2017'
    INTO TEMP tmp_invcrec1 WITH NO LOG;
    CREATE INDEX idxtmp_invcrec1_cta ON tmp_invcrec1(cuenta) USING BTREE FILLFACTOR 99;
    UPDATE STATISTICS HIGH FOR TABLE tmp_invcrec1;
    
    FOREACH WITH HOLD
        SELECT tmp.cuenta, mae.producto, mae.sucursal, mae.sdo_actual, mae.status_cta, 
               noc.fecha_alta, noc.acum_sdo_pos, noc.dia_sdo_pos, ins.cuentadep
          INTO vcuenta, vproducto, vsucursal, vsdo_actual, vstatus_cta, 
               vfecha_alta, vacum_sdo_pos, vdia_sdo_pos, vcuentadep
          FROM tmp_invcrec1 tmp,
               sc_maechq mae,
               sc_maenoc noc,
               sc_maeinstrucc ins
         WHERE tmp.cuenta = mae.cuenta
           AND noc.cuenta = tmp.cuenta
           AND ins.cuenta = tmp.cuenta
           
        BEGIN WORK;
        LET ven_transacc = 1;
        
        IF vstatus_cta <> '1' OR vstatus_cta is null THEN
            ROLLBACK WORK;
            LET ven_transacc = 0;
            CONTINUE FOREACH;
        END IF;
        
        -- // CALCULA, PROVISIONA Y PAGA INTERESES MES 12
        LET vhora = CURRENT HOUR TO FRACTION;
        LET vfolio_suc = 'informix'||vhora[1,2]||vhora[4,5]||vhora[7,8]||vhora[10,11];
        
        -- // ELIMINA EL PLAN ACTUAL
        DELETE FROM sc_tasa_variable
         WHERE empresa = pEmpresa
           AND cuenta = vcuenta;
           
        -- // CANCELA TRANSACCION DE RENOVACION
        UPDATE sc_movhis
           SET cancelad = 'S'
         WHERE empresa = pEmpresa
           AND cuenta = vcuenta
           AND fech_alt = '02/27/2017'
           AND cancelad <> 'S'
           AND transacc = '3383';
        
        -- // OBTIENE PROVISION DEL 31/01/2017
        SELECT monto_tot
          INTO vint_acum
          FROM sc_movhis
         WHERE empresa = pEmpresa
           AND cuenta = vcuenta
           AND fech_alt = '01/31/2017'
           AND cancelad <> 'S'
           AND transacc = '3381';
           
        -- // OBTIENE DATOS DEL MES 12
        SELECT valor_tasa / 100, int_acum, isr
          INTO vtasa_mensual, vtotint, visr
          FROM sc_tasa_var_hist
         WHERE empresa = pEmpresa
           AND cuenta = vcuenta
           AND fin_periodo = '02/28/2017'
           AND tipo_tasa = 'M';
           
        -- // CALCULA LOS INTERESES DE UN DIA
        LET vsdo_promedio = (vacum_sdo_pos / vdia_sdo_pos);
        LET vint_dia = ((vsdo_promedio * vtasa_mensual) / 360);
        
        -- // REGISTRA LA PROVISION DEL MES 12
        LET vtotint = vtotint + vint_dia;
        LET vmonto_prov = vtotint;
           
        IF vmonto_prov >= vint_acum THEN
            LET vmonto_prov = vmonto_prov - vint_acum;
            
            IF vmonto_prov > 0 THEN
                INSERT INTO sc_movdia VALUES 
                ( 0, vfolio_suc, vsucursal, 'informix', vfecha_hoy, vfecha_hoy, vhora, '3381', vsucursal, vproducto, pempresa, vcuenta, 
                  '', 0, vmonto_prov, vmonto_prov, 0, 0, 0, '', vstatus_cta, vsdo_actual, '0000', ' ', vtasa_mensual, '', '' , '', vfecha_hoy );
            END IF
        ELSE
            LET vmonto_desprov = vint_acum - vmonto_prov;
            
            IF vmonto_desprov > 0 THEN
                INSERT INTO sc_movdia VALUES 
                ( 0, vfolio_suc, vsucursal, 'informix', vfecha_hoy, vfecha_hoy, vhora, '3382', vsucursal, vproducto, pempresa, vcuenta, 
                  '', 0, vmonto_desprov, vmonto_desprov, 0, 0, 0, '', vstatus_cta, vsdo_actual, '0000', ' ', vtasa_mensual, '', '' , '', vfecha_hoy );
            END IF
        END IF;
        
        -- // REGISTRA EL PAGO DE INTERESES DEL MESIVERSARIO
        INSERT INTO sc_movdia VALUES 
        ( 0, vfolio_suc, vsucursal, 'informix', vfecha_hoy, vfecha_hoy, vhora, '3276', vsucursal, vproducto, pempresa, vcuenta, 
          '', 0, vtotint, vtotint, 0, 0, 0, '', vstatus_cta, vsdo_actual, '0000', ' ', vtasa_mensual, '', '' , '', vfecha_hoy );
          
        -- // REGISTRA EL COBRO DE ISR
        IF visr > 0 THEN
            INSERT INTO sc_movdia VALUES 
            ( 0, vfolio_suc, vsucursal, 'informix', vfecha_hoy, vfecha_hoy, vhora, '3277', vsucursal, vproducto, pempresa, vcuenta, 
              '', 0, visr, visr, 0, 0, 0, '', vstatus_cta, vsdo_actual, '0000', ' ', vtasa_premio, '', '' , '', vfecha_hoy );
        END IF;
                
        -- // OBTIENE DATOS DEL PLAN PARA EL PREMIO META
        SELECT valor_tasa / 100, int_acum, valor_tasa, isr
          INTO vtasa_premio, vmonto_meta, vvaltasa, visr_prem
          FROM sc_tasa_var_hist
         WHERE empresa = pempresa
           AND cuenta = vcuenta
           AND fin_periodo = '02/28/2017'
           AND tipo_tasa = "P";
           
        LET vmonto_meta = vmonto_meta + vint_dia;
        
        -- // REGISTRA PROVISION DEL MONTO META 
        INSERT INTO sc_movdia VALUES 
        ( 0, vfolio_suc, vsucursal, 'informix', vfecha_hoy, vfecha_hoy, vhora, '3381', vsucursal, vproducto, pempresa, vcuenta, 
          '', 0, vmonto_meta, vmonto_meta, 0, 0, 0, '', vstatus_cta, vsdo_actual, '0000', ' ', vtasa_premio, '', '' , '', vfecha_hoy );
          
        -- // REGISTRA PAGO DE INTERES DEL MONTO META 
        INSERT INTO sc_movdia VALUES 
        ( 0, vfolio_suc, vsucursal, 'informix', vfecha_hoy, vfecha_hoy, vhora, '3276', vsucursal, vproducto, pempresa, vcuenta, 
          '', 0, vmonto_meta, vmonto_meta, 0, 0, 0, '', vstatus_cta, vsdo_actual, '0000', ' ', vtasa_premio, '', '' , '', vfecha_hoy );
          
        -- // REGISTRA EL COBRO DE ISR
        IF visr_prem > 0 THEN
            INSERT INTO sc_movdia VALUES 
            ( 0, vfolio_suc, vsucursal, 'informix', vfecha_hoy, vfecha_hoy, vhora, '3277', vsucursal, vproducto, pempresa, vcuenta, 
              '', 0, visr_prem, visr_prem, 0, 0, 0, '', vstatus_cta, vsdo_actual, '0000', ' ', vtasa_premio, '', '' , '', vfecha_hoy );
        END IF;
        
        -- // CALCULA NUEVO SALDO
        LET vsdo_nuevo = vsdo_actual + ( ( vtotint + vmonto_meta ) - ( visr + visr_prem ) );
        
        -- // ACTUALIZA TABLAS MAESTRAS CON LA INFORMACIÃN DE LOS INTERESES
        UPDATE sc_maechq
           SET num_abonos_mes = num_abonos_mes + 2, 
               imp_abonos_mes = imp_abonos_mes + ( vtotint + vmonto_meta ),
               sdo_actual = sdo_actual + ( ( vtotint + vmonto_meta ) - ( visr + visr_prem ) ),
               ultpagoint = vfecha_hoy,
               fecha_proceso = null,
               fec_ult_mov = vfecha_hoy,
               imp_chq_rem = vsdo_nuevo
         WHERE cuenta = vcuenta;
         
        UPDATE sc_maenoc
           SET dia_sdo_pos = 0,
               acum_sdo_pos = 0.00,
               int_acum = 0.00,
               acum_sdo_int = 0.00,
               dias_acum_int = 0,
               isr_acum = isr_acum + ( visr + visr_prem ),
               fecha_alta = vfecha_hoy,
               fecha_mod = null
         WHERE cuenta = vcuenta;
         
        -- // REGISTRA TRANSACCION DE RENOVACION
        INSERT INTO sc_movdia VALUES 
        ( 0, vfolio_suc, vsucursal, 'informix', vfecha_hoy, vfecha_hoy, vhora, '3383', vsucursal, vproducto, pempresa, vcuenta, '', 0, 
          vsdo_nuevo, vsdo_nuevo, 0, 0, 0, '', vstatus_cta, vsdo_actual, '0000', 'RENOVACION DE INVERSION CRECIENTE', 0, '', '' , '', vfecha_hoy );
         
        LET vcontador1 = vcontador1 + 1;
        
        COMMIT WORK;
        LET ven_transacc = 0;
        
        LET vhora          = '';
        LET vfolio_suc     = '';
        LET vcuenta        = '';
        LET vstatus_cta    = '';
        LET vsucursal      = '';
        LET vproducto      = '';
        LET vsdo_actual    = 0.00;
        LET vint_acum      = 0.00;
        LET vacum_sdo_pos  = 0.00;
        LET vdia_sdo_pos   = 0;
        LET vfecha_alta    = '';
        LET vcuentadep     = '';
        LET vtasa_mensual  = 0.000000;
        LET vmonto_desprov = 0.00;
        LET vtasa_premio   = 0.000000;
        LET vmonto_meta    = 0.00;
        LET vvaltasa       = 0.000000;
        LET visr_prem      = 0.00;
        LET vtotint        = 0.00;
        LET visr           = 0.00;
        LET vsdo_promedio  = 0.00;
        LET vint_dia       = 0.00;
        LET vsdo_nuevo     = 0.00;
    END FOREACH;
    
    
    SELECT a.cuenta
      FROM sc_tasa_var_hist a,
           sc_maechq b
     WHERE a.cuenta = b.cuenta  
       AND a.empresa = b.empresa
       AND a.inicio_periodo = '02/29/2016'
       AND a.fin_periodo = '02/28/2017'
       AND a.tipo_tasa = 'P' 
       AND b.status_cta = '1'
       AND b.fecha_proceso = '02/27/2017'
    INTO TEMP tmp_invcrec2 WITH NO LOG;
    CREATE INDEX idxtmp_invcrec2_cta ON tmp_invcrec2(cuenta) USING BTREE FILLFACTOR 99;
    UPDATE STATISTICS HIGH FOR TABLE tmp_invcrec2;
    
    FOREACH WITH HOLD
        SELECT tmp.cuenta, mae.producto, mae.sucursal, mae.sdo_actual, mae.status_cta, 
               noc.fecha_alta, noc.acum_sdo_pos, noc.dia_sdo_pos, ins.cuentadep
          INTO vcuenta, vproducto, vsucursal, vsdo_actual, vstatus_cta, 
               vfecha_alta, vacum_sdo_pos, vdia_sdo_pos, vcuentadep
          FROM tmp_invcrec2 tmp,
               sc_maechq mae,
               sc_maenoc noc,
               sc_maeinstrucc ins
         WHERE tmp.cuenta = mae.cuenta
           AND noc.cuenta = tmp.cuenta
           AND ins.cuenta = tmp.cuenta
           
        BEGIN WORK;
        LET ven_transacc = 1;
        
        IF vstatus_cta <> '1' OR vstatus_cta is null THEN
            ROLLBACK WORK;
            LET ven_transacc = 0;
            CONTINUE FOREACH;
        END IF;
        
        LET vhora = CURRENT HOUR TO FRACTION;
        LET vfolio_suc = 'informix'||vhora[1,2]||vhora[4,5]||vhora[7,8]||vhora[10,11];
        
        SELECT monto_tot
          INTO vint_acum
          FROM sc_movhis
         WHERE empresa = pEmpresa
           AND cuenta = vcuenta
           AND fech_alt = '01/31/2017'
           AND cancelad <> 'S'
           AND transacc = '3381';
           
        SELECT valor_tasa / 100, int_acum, isr
          INTO vtasa_mensual, vtotint, visr
          FROM sc_tasa_var_hist
         WHERE empresa = pEmpresa
           AND cuenta = vcuenta
           AND fin_periodo = '02/28/2017'
           AND tipo_tasa = 'M';
           
        LET vmonto_prov = vtotint;
           
        IF vmonto_prov >= vint_acum THEN
            LET vmonto_prov = vmonto_prov - vint_acum;
            
            IF vmonto_prov > 0 THEN
                INSERT INTO sc_movdia VALUES 
                ( 0, vfolio_suc, vsucursal, 'informix', vfecha_hoy, vfecha_hoy, vhora, '3381', vsucursal, vproducto, pempresa, vcuenta, 
                  '', 0, vmonto_prov, vmonto_prov, 0, 0, 0, '', vstatus_cta, vsdo_actual, '0000', ' ', vtasa_mensual, '', '' , '', vfecha_hoy );
            END IF
        ELSE
            LET vmonto_desprov = vint_acum - vmonto_prov;
            
            IF vmonto_desprov > 0 THEN
                INSERT INTO sc_movdia VALUES 
                ( 0, vfolio_suc, vsucursal, 'informix', vfecha_hoy, vfecha_hoy, vhora, '3382', vsucursal, vproducto, pempresa, vcuenta, 
                  '', 0, vmonto_desprov, vmonto_desprov, 0, 0, 0, '', vstatus_cta, vsdo_actual, '0000', ' ', vtasa_mensual, '', '' , '', vfecha_hoy );
            END IF
        END IF;
        
        -- // REGISTRA EL PAGO DE INTERESES DEL MESIVERSARIO
        INSERT INTO sc_movdia VALUES 
        ( 0, vfolio_suc, vsucursal, 'informix', vfecha_hoy, vfecha_hoy, vhora, '3276', vsucursal, vproducto, pempresa, vcuenta, 
          '', 0, vtotint, vtotint, 0, 0, 0, '', vstatus_cta, vsdo_actual, '0000', ' ', vtasa_mensual, '', '' , '', vfecha_hoy );
          
        IF visr > 0 THEN
            INSERT INTO sc_movdia VALUES 
            ( 0, vfolio_suc, vsucursal, 'informix', vfecha_hoy, vfecha_hoy, vhora, '3277', vsucursal, vproducto, pempresa, vcuenta, 
              '', 0, visr, visr, 0, 0, 0, '', vstatus_cta, vsdo_actual, '0000', ' ', vtasa_premio, '', '' , '', vfecha_hoy );
        END IF;
                
        -- // OBTIENE DATOS DEL PLAN PARA EL PREMIO META
        SELECT valor_tasa / 100, int_acum, valor_tasa, isr
          INTO vtasa_premio, vmonto_meta, vvaltasa, visr_prem
          FROM sc_tasa_var_hist
         WHERE empresa = pempresa
           AND cuenta = vcuenta
           AND fin_periodo = '02/28/2017'
           AND tipo_tasa = "P";
           
        LET vmonto_meta = vmonto_meta + vint_dia;
        
        -- // REGISTRA PROVISION DEL MONTO META 
        INSERT INTO sc_movdia VALUES 
        ( 0, vfolio_suc, vsucursal, 'informix', vfecha_hoy, vfecha_hoy, vhora, '3381', vsucursal, vproducto, pempresa, vcuenta, 
          '', 0, vmonto_meta, vmonto_meta, 0, 0, 0, '', vstatus_cta, vsdo_actual, '0000', ' ', vtasa_premio, '', '' , '', vfecha_hoy );
          
        -- // REGISTRA PAGO DE INTERES DEL MONTO META 
        INSERT INTO sc_movdia VALUES 
        ( 0, vfolio_suc, vsucursal, 'informix', vfecha_hoy, vfecha_hoy, vhora, '3276', vsucursal, vproducto, pempresa, vcuenta, 
          '', 0, vmonto_meta, vmonto_meta, 0, 0, 0, '', vstatus_cta, vsdo_actual, '0000', ' ', vtasa_premio, '', '' , '', vfecha_hoy );
          
        IF visr_prem > 0 THEN
            INSERT INTO sc_movdia VALUES 
            ( 0, vfolio_suc, vsucursal, 'informix', vfecha_hoy, vfecha_hoy, vhora, '3277', vsucursal, vproducto, pempresa, vcuenta, 
              '', 0, visr_prem, visr_prem, 0, 0, 0, '', vstatus_cta, vsdo_actual, '0000', ' ', vtasa_premio, '', '' , '', vfecha_hoy );
        END IF;
                
        -- // REALIZA EL ABONO A LA CUENTA EJE 
        SELECT sucursal, producto, status_cta, sdo_actual
          INTO vsucursaldep, vproductodep, vstatus_ctadep, vsdo_actualdep
          FROM sc_maechq
         WHERE cuenta = vcuentadep;
         
        IF vstatus_ctadep IN('2','6','7','8') THEN
            UPDATE sc_maechq
               SET sdo_actual = sdo_actual + ( ( vtotint + vmonto_meta ) - ( visr + visr_prem ) )
             WHERE cuenta = vcuenta;
             
            COMMIT WORK;
            LET ven_transacc = 0;
            
            CONTINUE FOREACH;
        ELIF vstatus_ctadep = '3' THEN
            SELECT COUNT(*)
              INTO vexiste
              FROM sc_ctabloqueo 
             WHERE cuenta = vcuentadep;
            
            IF vexiste > 0 THEN 
                SELECT opcion 
                  INTO vacepta_abonos
                  FROM sc_ctabloqueo 
                 WHERE cuenta = vcuentadep;
                
                IF vacepta_abonos IN('2','4') THEN
                    UPDATE sc_maechq
                       SET sdo_actual = sdo_actual + ( ( vtotint + vmonto_meta ) - ( visr + visr_prem ) )
                     WHERE cuenta = vcuenta;
                     
                    COMMIT WORK;
                    LET ven_transacc = 0;
                    
                    CONTINUE FOREACH;
                END IF;
            ELSE
                SELECT abono 
                  INTO vacepta_abonos
                  FROM sc_bloqueo 
                 WHERE codigo = vmotivo;
                
                IF vacepta_abonos = "N" THEN
                    UPDATE sc_maechq
                       SET sdo_actual = sdo_actual + ( ( vtotint + vmonto_meta ) - ( visr + visr_prem ) )
                     WHERE cuenta = vcuenta;
                     
                    COMMIT WORK;
                    LET ven_transacc = 0;
                    
                    CONTINUE FOREACH;
                END IF;
            END IF;
        END IF;
        
        LET vsdo_traspaso = ( vsdo_actual + ( ( vtotint + vmonto_meta ) - ( visr + visr_prem ) ) );
        
        -- // REGISTRA EL CARGO A LA INVERSION CRECIENTE
        INSERT INTO sc_movdia VALUES 
        ( 0, vfolio_suc, vsucursal, 'informix', vfecha_hoy, vfecha_hoy, vhora, '0239', vsucursal, vproducto, pempresa, vcuenta, '', 0, 
          vsdo_traspaso, vsdo_traspaso, 0, 0, 0, '', vstatus_cta, vsdo_actual, '0000', 'CARGO POR TRASPASO', 0.000000, '', '' , '', vfecha_hoy );
        
        -- // REGISTRA EL ABONO EN LA CUENTA EJE
        INSERT INTO sc_movdia VALUES 
        ( 0, vfolio_suc, vsucursaldep, 'informix', vfecha_hoy, vfecha_hoy, vhora, '0205', vsucursaldep, vproductodep, pempresa, vcuentadep, '', 0, 
          vsdo_traspaso, vsdo_traspaso, 0, 0, 0, '', vstatus_ctadep, vsdo_actualdep, '0000', 'TRASPASO CAP E INT INV. CRECIENTE', 0.000000, '', '' , '', vfecha_hoy );
          
        UPDATE sc_maechq
           SET fecultdep = vfecha_hoy,
               fec_ult_mov = vfecha_hoy,
               num_abonos_mes = num_abonos_mes + 1,
               imp_abonos_mes = imp_abonos_mes + vsdo_traspaso, 
               sdo_actual = sdo_actual + vsdo_traspaso
         WHERE cuenta = vcuentadep;
        
        -- // ACTIVA LA CUENTA EJE SI ES QUE TENIA ESTATUS DE INACTIVA
        IF vstatus_ctadep IN('4','5') THEN
            UPDATE sc_maechq
               SET status_cta = '1',
                   fecha_proceso = vfecha_hoy
             WHERE cuenta = vcuentadep;
        END IF; 
        
        UPDATE sc_maechq
           SET status_cta = '2',
               fec_ult_mov = vfecha_hoy,
               fec_cancelac = vfecha_hoy,
               sdo_actual = 0.00,
               fecultret = vfecha_hoy,
               ultpagoint = vfecha_hoy
         WHERE cuenta = vcuenta;
         
        LET vcontador2 = vcontador2 + 1;
        
        COMMIT WORK;
        LET ven_transacc = 0;
        
        LET vhora          = '';
        LET vfolio_suc     = '';
        LET vcuenta        = '';
        LET vstatus_cta    = '';
        LET vsucursal      = '';
        LET vproducto      = '';
        LET vsdo_actual    = 0.00;
        LET vint_acum      = 0.00;
        LET vacum_sdo_pos  = 0.00;
        LET vdia_sdo_pos   = 0;
        LET vfecha_alta    = '';
        LET vcuentadep     = '';
        LET vtasa_mensual  = 0.000000;
        LET vmonto_desprov = 0.00;
        LET vtasa_premio   = 0.000000;
        LET vmonto_meta    = 0.00;
        LET vvaltasa       = 0.000000;
        LET visr_prem      = 0.00;
        LET vtotint        = 0.00;
        LET vsdo_promedio  = 0.00;
        LET vint_dia       = 0.00;
        LET visr           = 0.00;
        LET vcodretcgoisr  = '';
        LET vsucursaldep   = '';
        LET vproductodep   = '';
        LET vstatus_ctadep = '';
        LET vsdo_actualdep = 0.00;
        LET vsdo_traspaso  = 0.00;
        LET vcodretmaehis  = '';
        LET vexiste        = 0;
        LET vacepta_abonos = '';
    END FOREACH;
    
    END;
    
    RETURN vcodret1, vcontador1, vcontador2;
    
END PROCEDURE;
CREATE PROCEDURE "informix".sp_venceinvscrecs( pempresa CHAR(3), pfechafin DATE )
RETURNING CHAR(5), INTEGER;
    
    DEFINE vcodret1         CHAR(5);
    DEFINE vcodret2         CHAR(5);
    DEFINE vcodret3         CHAR(50);
    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE desc_err         CHAR(50);
    DEFINE vcontador1       INTEGER;
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
    DEFINE vsdo_retenido    DECIMAL(14,2);
    DEFINE vsdo_cong        DECIMAL(14,2);
    DEFINE vint_acum        DECIMAL(14,2); 
    DEFINE vacum_sdo_pos    DECIMAL(18,2);
    DEFINE vdia_sdo_pos     SMALLINT;
    DEFINE vfecha_alta      DATE;
    DEFINE vcuentadep       CHAR(20);
    DEFINE vtasa_premio     DECIMAL(9,6);
    DEFINE vmonto_meta      DECIMAL(14,2);
    DEFINE vvaltasa         DECIMAL(9,6);
    DEFINE visr_prem        DECIMAL(14,2);
    DEFINE vnumdias         SMALLINT;
    DEFINE vcodretcgoisr    CHAR(5);
    DEFINE vsucursaldep     CHAR(4);
    DEFINE vproductodep     CHAR(4);
    DEFINE vstatus_ctadep   CHAR(1);
    DEFINE vsdo_actualdep   DECIMAL(14,2);
    DEFINE vsdo_traspaso    DECIMAL(14,2);
    DEFINE vexiste          SMALLINT;
    DEFINE vacepta_abonos   CHAR(1);
    
    LET vcodret1       = '000';
    LET vcodret2       = '';
    LET vcodret3       = '';
    LET sql_err	       = 0;
    LET isam_err       = 0;
    LET desc_err       = '';
    LET vcontador1     = 0;
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
    LET vsdo_retenido  = 0.00;
    LET vsdo_cong      = 0.00;
    LET vint_acum      = 0.00;
    LET vacum_sdo_pos  = 0.00;
    LET vdia_sdo_pos   = 0;
    LET vfecha_alta    = '';
    LET vcuentadep     = '';
    LET vtasa_premio   = 0.000000;
    LET vmonto_meta    = 0.00;
    LET vvaltasa       = 0.000000;
    LET visr_prem      = 0.00;
    LET vnumdias       = 0;
    LET vcodretcgoisr  = '';
    LET vsucursaldep   = '';
    LET vproductodep   = '';
    LET vstatus_ctadep = '';
    LET vsdo_actualdep = 0.00;
    LET vsdo_traspaso  = 0.00;
    LET vexiste        = 0;
    LET vacepta_abonos = '';
    
    BEGIN

    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_venceinvscrecs.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            IF ven_transacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcodret1, vcontador1;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_venceinvscrecs.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    select a.cuenta, a.fecha_proceso, b.fecha_alta, b.fecha_mod, c.instrucc, c.cuentadep, a.imp_chq_rem, a.sdo_actual
      from sc_maechq a,
           sc_maenoc b,
           sc_maeinstrucc c
     where a.producto = '1100'
       and a.status_cta = '1'
       and a.fecha_proceso = '09/17/2020'
       and b.cuenta = a.cuenta
       and c.empresa = b.empresa
       and c.cuenta = a.cuenta
       and c.capint = 'R'
    into temp tmp_invscrec with no log;
    create index idxtmp_invscrecs_cuenta on tmp_invscrec(cuenta) online;
    update statistics medium for table tmp_invscrec;
    
    SELECT fecha_hoy
      INTO vfecha_hoy
      FROM sc_fechas
     WHERE empresa = pempresa;
     
    LET vhora = CURRENT HOUR TO FRACTION;
    LET vfolio_suc = 'informix'||vhora[1,2]||vhora[4,5]||vhora[7,8]||vhora[10,11];
    
    FOREACH WITH HOLD
        SELECT cuenta
          INTO vcuenta
          FROM tmp_invscrec
           
        BEGIN WORK;
        LET ven_transacc = 1;
        
        SELECT mae.status_cta, mae.sucursal, mae.producto, mae.sdo_actual, mae.sdo_retenido, mae.sdo_cong, noc.int_acum, noc.acum_sdo_pos, noc.dia_sdo_pos, noc.fecha_alta, ins.cuentadep
          INTO vstatus_cta, vsucursal, vproducto, vsdo_actual, vsdo_retenido, vsdo_cong, vint_acum, vacum_sdo_pos, vdia_sdo_pos, vfecha_alta, vcuentadep
          FROM sc_maechq mae,
               sc_maenoc noc,
               sc_maeinstrucc ins
         WHERE mae.cuenta = vcuenta
           AND noc.cuenta = mae.cuenta
           AND ins.cuenta = mae.cuenta
           AND ins.capint = 'R';
           
        SELECT valor_tasa / 100, int_acum, valor_tasa, isr, (fin_periodo - inicio_periodo)
          INTO vtasa_premio, vmonto_meta, vvaltasa, visr_prem, vnumdias
          FROM sc_tasa_var_hist
         WHERE empresa = pempresa
           AND cuenta = vcuenta
           AND inicio_periodo >= vfecha_alta
           AND fin_periodo <= pfechafin
           AND tipo_tasa = "P";
        
        -- // REGISTRA PROVISION DEL MONTO META 
        INSERT INTO sc_movdia VALUES 
        ( 0, vfolio_suc, vsucursal, 'informix', vfecha_hoy, vfecha_hoy, vhora, '3381', vsucursal, vproducto, pempresa, vcuenta, 
          '', 0, vmonto_meta, vmonto_meta, 0, 0, 0, '', vstatus_cta, vsdo_actual, '0000', ' ', vtasa_premio, '', '' , '', vfecha_hoy );
          
        -- // REGISTRA PAGO DE INTERES DEL MONTO META 
        INSERT INTO sc_movdia VALUES 
        ( 0, vfolio_suc, vsucursal, 'informix', vfecha_hoy, vfecha_hoy, vhora, '3276', vsucursal, vproducto, pempresa, vcuenta, 
          '', 0, vmonto_meta, vmonto_meta, 0, 0, 0, '', vstatus_cta, vsdo_actual, '0000', ' ', vtasa_premio, '', '' , '', vfecha_hoy );
          
        -- // VERIFICA ISR
        IF visr_prem > 0 THEN
            CALL cargocie(pempresa, vsucursal, 'informix', '3277', '0000', vfolio_suc, vcuenta, 0, visr_prem)
            RETURNING vcodretcgoisr;
        END IF;
        
        -- // ACTUALIZA TABLAS MAESTRAS CON LA INFORMACIÃN DE LOS INTERESES
        UPDATE sc_maechq
           SET num_abonos_mes = num_abonos_mes + 1, 
               imp_abonos_mes = imp_abonos_mes + ( vmonto_meta ),
               sdo_actual = sdo_actual + ( ( vmonto_meta ) - visr_prem),
               ultpagoint = vfecha_hoy
         WHERE cuenta = vcuenta;
         
        UPDATE sc_maenoc
           SET isr_acum = isr_acum + ( visr_prem )
         WHERE cuenta = vcuenta;
        
        -- // REALIZA EL ABONO A LA CUENTA EJE 
        SELECT sucursal, producto, status_cta, sdo_actual
          INTO vsucursaldep, vproductodep, vstatus_ctadep, vsdo_actualdep
          FROM sc_maechq
         WHERE cuenta = vcuentadep;
         
        IF vstatus_ctadep IN('2','6','7','8') THEN
            ROLLBACK WORK;
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
                    ROLLBACK WORK;
                    LET ven_transacc = 0;
                    CONTINUE FOREACH;
                END IF;
            ELSE
                SELECT abono 
                  INTO vacepta_abonos
                  FROM sc_bloqueo 
                 WHERE codigo = vmotivo;
                
                IF vacepta_abonos = "N" THEN
                    ROLLBACK WORK;
                    LET ven_transacc = 0;
                    CONTINUE FOREACH;
                END IF;
            END IF;
        END IF;
        
        LET vsdo_traspaso = ( (vsdo_actual + vmonto_meta) - visr_prem );
        
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
        
        -- // REALIZA EL CARGO A LA INVERSION CRECIENTE
        INSERT INTO sc_movdia VALUES 
        ( 0, vfolio_suc, vsucursal, 'informix', vfecha_hoy, vfecha_hoy, vhora, '0239', vsucursal, vproducto, pempresa, vcuenta, '', 0, 
          vsdo_traspaso, vsdo_traspaso, 0, 0, 0, '', vstatus_cta, vsdo_actual, '0000', 'CARGO POR TRASPASO', 0.000000, '', '' , '', vfecha_hoy );
        
        -- // ACTIVA LA CUENTA EJE SI ES QUE TENIA ESTATUS DE INACTIVA
        IF vstatus_ctadep IN('4','5') THEN
            UPDATE sc_maechq
               SET status_cta = '1',
                   fecha_proceso = vfecha_hoy
             WHERE cuenta = vcuentadep;
        END IF; 
        
        -- // ACTUALIZA TABLAS MAESTRAS CON LA INFORMACIÃN DEL TRASPASO
        UPDATE sc_maechq
           SET status_cta = '2',
               fecultret = vfecha_hoy,
               fec_ult_mov = vfecha_hoy,
               fec_cancelac = vfecha_hoy,
               num_cgos_mes = num_cgos_mes + 1,
               imp_cgos_mes = imp_cgos_mes + vsdo_traspaso,
               sdo_actual = sdo_actual - vsdo_traspaso 
         WHERE cuenta = vcuenta;
         
        UPDATE sc_maenoc
           SET int_acum        = 0,
               dias_acum_int   = 0,
               acum_sdo_int    = 0,
               dia_sdo_pos     = 0,
               acum_sdo_pos    = 0,
               acum_sbc        = 0,
               acum_rem        = 0,
               sdo_mes_ant     = vsdo_actual,
               ret_mes_ant     = vsdo_retenido,
               cong_mes_ant    = vsdo_cong
         WHERE cuenta = vcuenta;
         
        LET vcontador1 = vcontador1 + 1;
        
        COMMIT WORK;
        LET ven_transacc = 0;
        
        LET vcuenta        = '';
        LET vstatus_cta    = '';
        LET vsucursal      = '';
        LET vproducto      = '';
        LET vsdo_actual    = 0.00;
        LET vsdo_retenido  = 0.00;
        LET vsdo_cong      = 0.00;
        LET vint_acum      = 0.00;
        LET vacum_sdo_pos  = 0.00;
        LET vdia_sdo_pos   = 0;
        LET vfecha_alta    = '';
        LET vcuentadep     = '';
        LET vtasa_premio   = 0.000000;
        LET vmonto_meta    = 0.00;
        LET vvaltasa       = 0.000000;
        LET visr_prem      = 0.00;
        LET vnumdias       = 0;
        LET vcodretcgoisr  = '';
        LET vsucursaldep   = '';
        LET vproductodep   = '';
        LET vstatus_ctadep = '';
        LET vsdo_actualdep = 0.00;
        LET vsdo_traspaso  = 0.00;
        LET vexiste        = 0;
        LET vacepta_abonos = '';
    END FOREACH;
    
    END;

    RETURN vcodret1, vcontador1;

END PROCEDURE;
CREATE PROCEDURE "informix".inicio_mes_esp(pempresa char(3))

RETURNING CHAR(5), CHAR(5), INTEGER;

    -- ********************************************************************
    -- SPL                  inicio_mes
    -- Version              1.0.0
    -- Obejtivo:            Proceso mensual para la acumulacion de saldos
    -- Creado por:
    -- ModIFicado por:      Alejandro Rueda Sanchez
    -- Ultima ModIFicacion: Noviembre29 -2008
    --                      Creación de SPL
    -- ********************************************************************

    DEFINE vcodret1, vcodret2               CHAR(5);
    DEFINE vsql_err, visam_err              INTEGER;
    DEFINE vpago_interes                    CHAR(1);
    DEFINE vsdo_mes_ant, vsdo_prom_mesant   MONEY(18,2);
    DEFINE vdias, vdia_sdo_pos              SMALLINT;
    DEFINE vsdo_retenido, vsdo_cong,
           vsdo_actual, vacum_sdo_pos       MONEY(18,2);
    DEFINE vfecha_prox, vfecha_hoy,
           vfechaini, vfechafin, 
           vfecha_valida, vfecha_validada   DATE;
    DEFINE vlimsbgccc, vimpsbgccc, 
           vimpintccc,vimpchqsbg, 
           vimpintsbg,vdiffinmes,vdifmesact MONEY(18,2);
    DEFINE vcuenta                          CHAR(20);
    DEFINE vmonto, vsdodisp, vsdocta        MONEY(18,2);
    DEFINE vtasa_bruta                      DECIMAL(9,6);
    DEFINE vnumreg                          SMALLINT;
    DEFINE vtraninteres                     CHAR(4);
    DEFINE vtranisr                         CHAR(4);
    DEFINE vtiptran                         CHAR(2);
    DEFINE vaniomes                         CHAR(6);
    DEFINE vcuenta_clabe                    CHAR(20);
    DEFINE vsucursal                        CHAR(4);
    DEFINE vproducto                        CHAR(4);
    DEFINE vnum_cte                         CHAR(20);
    DEFINE vstatus_cta                      CHAR(1);
    DEFINE vmotivo                          CHAR(1);
    DEFINE vfec_cancelac                    DATE;
    DEFINE venvio_direcc                    CHAR(1);
    DEFINE vdirecc_envio                    SMALLINT;
    DEFINE vacum_sdo_int                    MONEY(18,2);
    DEFINE vdias_acum_int                   MONEY(18,2);
    DEFINE vret_mes_ant                     MONEY(18,2);
    DEFINE vcong_mes_ant                    MONEY(18,2);
    DEFINE vlim_sbg_ccc                     MONEY(18,2);
    DEFINE vimp_sbg_ccc                     MONEY(18,2);
    DEFINE vimp_chq_sbg                     MONEY(18,2);
    DEFINE vsaldo_sbc                       MONEY(18,2);
    DEFINE vint_acum                        MONEY(18,2);
    DEFINE visr_acum                        MONEY(18,2);
    DEFINE vnum_tarjeta                     CHAR(16);
    DEFINE vmaxsecuencia                    SMALLINT;
    DEFINE vtotretiros, vtotdepositos,
           vtotinrpag, vtotcomcobrada,
           vtotintpag, vtotcombonif,
           vtotivacobrado, vtotivabonif,
           vtotisrcobrado                   MONEY(18,2);
    DEFINE vbandcorte                       CHAR(1);
    DEFINE v_cuantos                        SMALLINT;
    DEFINE vt_monto_tot                     MONEY(18,2);
    DEFINE vt_naturaleza                    CHAR(1);
    DEFINE vt_transacc                      CHAR(4);
    DEFINE vt_tasa_aplicada                 DECIMAL(9,6);
    DEFINE vt_tipo_tran                     CHAR(2);
    DEFINE vdia                             CHAR(2);
    DEFINE vexistecta                       CHAR(20);
    DEFINE vcontador, vcuantos, vcomienza   INTEGER;
    DEFINE vfechainimovhis                  CHAR(10);
    DEFINE vfechainimovhisold               CHAR(10);
    
    DEFINE vtran_efec                       CHAR(4);
    DEFINE vtotretirosefec                  DECIMAL(18,2);
    DEFINE vtototroscargos                  DECIMAL(18,2);
    DEFINE vgat                             DECIMAL(9,6);
    DEFINE vsdo_01                          DECIMAL(18,2);

    BEGIN

    ON EXCEPTION 
        SET vsql_err, visam_err
        IF vsql_err <> 0 THEN
            LET vcodret1 = vsql_err;
            LET vcodret2 = visam_err;
            RETURN vcodret1, vcodret2, vcuantos;
        END IF;
    END EXCEPTION;

    --- SET DEBUG FILE TO "/tmp/inicio_mes_esp.out";
    --- TRACE ON;

    LET vcodret1  = "000";
    LET vcodret2  = "000";
    LET vcontador = 0;
    LET vcuantos  = 0;
    LET vcomienza = -1;
    LET v_cuantos = 0;
    
    LET vtran_efec = '';
    LET vsdo_01 = 0;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    -- // OBTIENE FECHAS DEL SISTEMA
    { ***************************************************************************
    SELECT fecha_hoy, fecha_ant, fecha_hoy - 1 UNITS MONTH, fecha_ant , fecha_hoy
      INTO vfecha_prox, vfecha_hoy, vfechaini, vfechafin, vfecha_valida
      FROM sc_fechas
     WHERE empresa = pempresa;

    LET vdia = SUBSTR(vfecha_valida,4,2);
    LET vdia = vdia;

    IF LPAD(vdia,2,'0') <> "01" THEN
        IF LPAD(vdia,2,'0') = "02" THEN
            LET vfecha_validada = vfecha_valida - 1;
            
            EXECUTE PROCEDURE sp_valfechabil(vfecha_validada,"") 
            INTO vcodret1, vfecha_validada;
            
            IF vfecha_validada <> vfecha_valida THEN
                RETURN vcodret1, vcodret2, vcuantos;
            END IF
            
            LET vfechaini = vfechaini - 1;
        ELSE
            RETURN vcodret1, vcodret2, vcuantos;
        END IF
    END IF

    EXECUTE PROCEDURE sp_valfechabil(vfecha_prox,"") 
    INTO vcodret1, vfecha_prox;

    EXECUTE PROCEDURE sp_valfechabil(vfecha_hoy,"") 
    INTO vcodret1, vfecha_hoy;

    EXECUTE PROCEDURE sp_valfechabil(vfechaini,"") 
    INTO vcodret1, vfechaini;

    EXECUTE PROCEDURE sp_valfechabil(vfechafin,"") 
    INTO vcodret1, vfechafin;
    *************************************************************************** }

    LET vfecha_prox   = "12/01/2010";
    LET vfecha_hoy    = "11/30/2010";
    LET vfechaini     = "11/01/2010";
    LET vfechafin     = "11/30/2010";
    LET vfecha_valida = '12/01/2010';

    LET vdias = day(vfecha_prox) - 1;
    LET vaniomes = year(vfecha_hoy) || lpad(month(vfecha_hoy),2,"0");
    
    { ******************************************************
    -- // VERIFICA QUE NO SE HAYA REALIZADO EL INICIO DE MES
    SELECT COUNT(*)
      INTO v_cuantos
      FROM sc_contproc
     WHERE empresa = pempresa
       AND proceso = "inicio_mes"
       AND fecha = vfecha_valida;

    IF v_cuantos > 0 THEN 
        LET vcodret1 = '958';
        LET vcodret2 = '958';
        RETURN vcodret1, vcodret2, vcuantos;
    END IF;
    ****************************************************** }
    
    -- // OBTIENE PARAMETROS DE TRANSACCIONES Y FECHAS
    SELECT valor
      INTO vtraninteres
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "tranpagint";

    SELECT valor
      INTO vtranisr
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "tranisr";
       
    SELECT valor
      INTO vfechainimovhis
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = 'fechcon_movhis';
       
    SELECT valor
      INTO vfechainimovhisold
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = 'FechIniCon_movhis_ol';
       
    -- // FOREACH PRINCIPAL      
    FOREACH WITH HOLD
        SELECT mc.cuenta,cuenta_clabe,sucursal,mc.producto,mc.num_cte,
               status_cta,motivo,fec_cancelac,sdo_retenido,sdo_cong,
               sdo_dia_ant,envio_direcc,direcc_envio,sdo_mes_ant,
               acum_sdo_pos,dia_sdo_pos,acum_sdo_int,dias_acum_int,
               ret_mes_ant,cong_mes_ant,lim_sbg_ccc,imp_sbg_ccc,
               imp_chq_sbg,saldo_sbc,int_acum,isr_acum,pago_interes, sdo_actual
          INTO vcuenta,vcuenta_clabe,vsucursal,vproducto,vnum_cte,
               vstatus_cta,vmotivo,vfec_cancelac,vsdo_retenido,vsdo_cong,
               vsdo_actual,venvio_direcc,vdirecc_envio,vsdo_mes_ant,
               vacum_sdo_pos,vdia_sdo_pos,vacum_sdo_int,vdias_acum_int,
               vret_mes_ant,vcong_mes_ant,vlim_sbg_ccc,vimp_sbg_ccc,
               vimp_chq_sbg,vsaldo_sbc,vint_acum,visr_acum,vpago_interes, vsdo_01
          FROM sc_producto pr, 
               sc_maechq_01122010 mc, 
               sc_maenoc_01122010 mn 
         WHERE pr.empresa = pempresa
           AND pr.producto = mc.producto
           AND pr.pago_interes = 'M'
           AND mc.empresa = pr.empresa
           AND mc.producto = pr.producto
           AND mc.status_cta != '2'
           AND mn.empresa = mc.empresa
           AND mn.cuenta = mc.cuenta           
           
        IF (vcomienza = -1)THEN
            LET vcomienza = 0;
            BEGIN WORK;
        END IF;
        
        SELECT max(secuencia)
          INTO vmaxsecuencia
          FROM sc_tarjeta
         WHERE empresa = pempresa
           AND cuenta = vcuenta
           AND tipo_tarjeta = "T";

        SELECT num_tarjeta
          INTO vnum_tarjeta
          FROM sc_tarjeta
         WHERE empresa = pempresa
           AND cuenta = vcuenta
           AND secuencia = vmaxsecuencia;

        IF vnum_tarjeta is null THEN
            LET vnum_tarjeta = "";
        END IF

        -- // INICIALIZA VARIABLES DE SALDOS
        LET vtotdepositos   = 0;
        LET vtotretiros     = 0;
        LET vtotintpag      = 0;
        LET vtasa_bruta     = 0;
        LET vtotcomcobrada  = 0;
        LET vtotcombonif    = 0;
        LET vtotivacobrado  = 0;
        LET vtotivabonif    = 0;
        LET vtotisrcobrado  = 0;
        LET vtotretirosefec = 0;
        LET vtototroscargos = 0;
        LET vgat            = 0;
        
        FOREACH
            SELECT mv.monto_tot, mv.transacc, tr.naturaleza, tr.tipo_tran, NVL(efe.transaccion, '0000')
              INTO vt_monto_tot, vt_transacc, vt_naturaleza, vt_tipo_tran, vtran_efec
              FROM sc_movhis mv
             INNER JOIN bdinteg:si_transacc tr ON (tr.empresa = mv.empresa AND tr.numero = mv.transacc AND tr.se_emite_edocta = 'S')
              LEFT OUTER JOIN sc_transacc_efectivo efe ON (efe.transaccion = mv.transacc)
             WHERE mv.empresa = pempresa
               AND mv.cuenta = vcuenta   
               AND mv.fech_alt BETWEEN vfechaini AND vfechafin
               AND mv.fech_alt >= vfechainimovhis
               AND mv.cancelad <> 'S'
               AND mv.transacc > '0000'
            UNION ALL 
            SELECT mv.monto_tot, mv.transacc, tr.naturaleza, tr.tipo_tran, NVL(efe.transaccion, '0000')
              FROM sc_movhis_old mv
             INNER JOIN bdinteg:si_transacc tr ON (tr.empresa = mv.empresa AND tr.numero = mv.transacc AND tr.se_emite_edocta = 'S')
              LEFT OUTER JOIN sc_transacc_efectivo efe ON (efe.transaccion = mv.transacc)
             WHERE mv.empresa = pempresa
               AND mv.cuenta = vcuenta   
               AND mv.fech_alt BETWEEN vfechaini AND vfechafin
               AND mv.fech_alt >= vfechainimovhisold
               AND mv.fech_alt < vfechainimovhis
               AND mv.cancelad <> 'S'
               AND mv.transacc > '0000'

            -- // ABONOS
            IF vt_naturaleza = "A" THEN -- // TOTAL DEPOSITOS
                IF vt_transacc <> vtraninteres THEN
                    LET vtotdepositos = vtotdepositos + vt_monto_tot;
                END IF

                IF vt_tipo_tran in("01","05","09") THEN -- // TOTAL COMISIONES BONIFICADAS
                    LET vtotcombonif = vtotcombonif + vt_monto_tot;
                END IF

                IF vt_tipo_tran in("02","04","06","08","10") THEN -- // TOTAL IVAS BONIFICADOS
                    LET vtotivabonif = vtotivabonif + vt_monto_tot;
                END IF
            -- // CARGOS
            ELIF vt_naturaleza = "C" THEN -- // TOTAL CARGOS
                IF vt_tipo_tran in('00','30') THEN
                    LET vtotretiros = vtotretiros + vt_monto_tot;
                    LET vtototroscargos = vtototroscargos + vt_monto_tot;
                END IF;
                
                IF vtran_efec = vt_transacc THEN
                    LET vtotretirosefec = vtotretirosefec + vt_monto_tot;
                END IF;
                
                IF vt_tipo_tran in("01","05") THEN -- // TOTAL COMISIONES COBRADAS
                    LET vtotcomcobrada = vtotcomcobrada + vt_monto_tot;
                END IF

                IF vt_tipo_tran in("02","04","06","08") THEN -- // TOTAL IVA COBRADO
                    LET vtotivacobrado = vtotivacobrado + vt_monto_tot;
                END IF
            END IF

            IF vt_transacc = vtraninteres THEN -- // TOTAL PAGO DE INTERESES
                LET vtotintpag = vtotintpag + vt_monto_tot;
            END IF

            IF vt_transacc = vtranisr THEN -- // TOTAL ISR COBRADO
                LET vtotisrcobrado = vtotisrcobrado + vt_monto_tot;
            END IF
        END FOREACH

        LET vtototroscargos = vtototroscargos - vtotretirosefec;
    
        IF vtototroscargos is null OR vtototroscargos < 0 THEN
            LET vtototroscargos = 0;
        END IF;
        
        LET vtotcomcobrada = vtotcomcobrada - vtotcombonif;
        LET vtotivacobrado = vtotivacobrado - vtotivabonif;
        LET vtotretiros    = vtotretiros - vtotcomcobrada - vtotivacobrado - vtotisrcobrado;
        
        SELECT FIRST 1 mov.tasa_aplicada
          INTO vtasa_bruta
          FROM sc_movhis mov
         WHERE mov.empresa = pempresa
           AND mov.cuenta = vcuenta
           AND mov.fech_alt = vfechafin
           AND mov.cancelad <> 'S'
           AND mov.transacc = vtraninteres;
           
        IF vtasa_bruta is null OR vtasa_bruta = '' THEN
            LET vtasa_bruta = 0;
        END IF;
        
        IF vpago_interes = "D" OR  -- // DIARIO
           vpago_interes = "M" OR  -- // MENSUAL
          (vpago_interes = "T" AND (month(vfecha_prox) = "4" OR month(vfecha_prox) = "7" OR month(vfecha_prox) = "10" OR month(vfecha_prox) = "1")) OR -- // TRIMESTRAL
          (vpago_interes = "S" AND (month(vfecha_prox) = "7" OR month(vfecha_prox) = "1")) OR -- // SEMESTRAL
          (vpago_interes = "A" AND month(vfecha_prox) = "1") THEN -- // ANUAL
            LET vbandcorte = "S";
        ELSE
            LET vbandcorte = "N";
        END IF
        
        IF vbandcorte = "S" THEN
            LET vaniomes = vaniomes;
            LET vcuenta = vcuenta;

            INSERT INTO sc_maehis VALUES
            (pempresa,vaniomes,vcuenta,vfechaini,vfechafin,vcuenta_clabe,vnum_tarjeta,vsucursal,vproducto,
             vnum_cte,vstatus_cta,vmotivo,vfec_cancelac,vsdo_retenido,vsdo_cong,vsdo_actual,venvio_direcc,
             vdirecc_envio,vsdo_mes_ant,vacum_sdo_pos,vdia_sdo_pos,vacum_sdo_int,vdias_acum_int,vtasa_bruta,
             vret_mes_ant,vcong_mes_ant,vlim_sbg_ccc,vimp_sbg_ccc,vimp_chq_sbg,vsaldo_sbc,vint_acum,visr_acum,
             vtotdepositos,vtotretiros,vtotintpag,vtotcomcobrada,vtotivacobrado,vtotisrcobrado, 
             vtotretirosefec, vtototroscargos, vgat);
        END IF
        
        -- // INICIALIZA MAESTRO DE CHEQUES Y ACUMULADOS
        LET vsdo_mes_ant = vsdo_actual;

        IF vdia_sdo_pos > 0 THEN
            LET vsdo_prom_mesant = vacum_sdo_pos / vdia_sdo_pos;
        ELSE
            LET vsdo_prom_mesant = 0;
        END IF

        IF vdias > 0 THEN
            LET vacum_sdo_pos = vsdo_actual * vdias;
            LET vdia_sdo_pos = vdias;
            LET vacum_sdo_int = ((((vacum_sdo_pos / vdias) * vtasa_bruta) / 360) * vdias);
        ELSE
            LET vacum_sdo_pos = 0;
            LET vdia_sdo_pos = 0;
            LET vacum_sdo_int = 0;
        END IF

        IF vpago_interes IS NULL or vpago_interes = " " THEN
            LET vpago_interes = "M";
        END IF
        
        IF vproducto IN('1200', '9900')THEN
            LET vtasa_bruta = 4.350000;
        END IF;
        
        IF vbandcorte = "S" THEN
            UPDATE sc_maenoc
               SET acum_sbc        = 0,
                   acum_rem        = 0,
                   dia_sdo_pos     = 1,
                   acum_sdo_pos    = vsdo_01,
                   dias_acum_int   = 1,
                   acum_sdo_int    = ((((vsdo_01 / 1) * vtasa_bruta) / 360) * 1),
                   sdo_mes_ant     = vsdo_actual,
                   sdo_prom_mesant = vsdo_prom_mesant,
                   int_acum        = 0,
                   isr_acum        = 0,
                   ret_mes_ant     = vsdo_retenido,
                   cong_mes_ant    = vsdo_cong
             WHERE empresa = pempresa
               AND cuenta = vcuenta;

            UPDATE sc_maechq
               SET chq_exp_mes    = 0,
                   chq_dev        = 0,
                   monto_dev      = 0,
               --- sdo_dia_ant    = vsdo_mes_ant,
                   num_cgos_mes   = 0,
                   imp_cgos_mes   = 0,  
                   num_abonos_mes = 0,
                   imp_abonos_mes = 0
             WHERE empresa = pempresa
               AND cuenta = vcuenta;
        ELSE
            UPDATE sc_maenoc
               SET acum_sbc        = 0,
                   acum_rem        = 0,
                   sdo_mes_ant     = vsdo_mes_ant,
                   sdo_prom_mesant = vsdo_prom_mesant,
                   ret_mes_ant     = vsdo_retenido,
                   cong_mes_ant    = vsdo_cong
             WHERE empresa = pempresa
               AND cuenta = vcuenta;
        END IF
        
        LET vcontador = vcontador + 1;
        COMMIT WORK;
        BEGIN WORK;

    END FOREACH;
    
    IF (vcontador > 0) THEN
        LET vcuantos = vcuantos + vcontador;
        COMMIT WORK;
    END IF;
    
    UPDATE sc_contproc
       SET fecha = vfecha_valida
     WHERE empresa = pempresa
       AND proceso = "inicio_mes";

    RETURN vcodret1, vcodret2, vcuantos;

    END;

END PROCEDURE;
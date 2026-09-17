CREATE PROCEDURE "informix".inicio_mes_pba(pempresa char(3))
   RETURNING CHAR(5);

   -- *************************************************************************
   -- SPL                  inicio_mes
   -- Version              1.0.0
   -- Obejtivo:            Proceso mensual para la acumulacion de saldos
   -- Creado por:
   -- ModIFicado por:      Alejandro Rueda Sanchez
   -- Ultima ModIFicacion: Noviembre29 -2008
   --                      Creación de SPL
   -- *************************************************************************

   -- ******************* Definicion de Variables *****************************

   define vcodret CHAR(5);
   define vpago_interes char(1);
   define vsdo_mes_ant, vsdo_prom_mesant MONEY(14,2);
   define vdias, vdia_sdo_pos SMALLINT;
   define vsqlerr INTEGER;
   define vsdo_retenido, vsdo_cong, vsdo_actual, vacum_sdo_pos MONEY(14,2);
   define vfecha_prox, vfecha_hoy, vfechaini, vfechafin DATE;
   define vlimsbgccc,vimpsbgccc,vimpintccc,vimpchqsbg,vimpintsbg,
          vdiffinmes,vdifmesact money(14,2);
   define vcuenta char(20);
   define vmonto, vsdodisp, vsdocta money(14,2);
   define vtasa_bruta decimal(9,6);
   define vnumreg smallint;
   define vtraninteres char(4);
   define vtranisr char(4);
   define vtiptran char(2);
   define vaniomes char(6);
   define vcuenta_clabe char(20);
   define vsucursal char(4);
   define vproducto char(4);
   define vnum_cte char(20);
   define vstatus_cta char(1);
   define vmotivo char(1);
   define vfec_cancelac date;
   define venvio_direcc char(1);
   define vdirecc_envio smallint;
   define vacum_sdo_int money(14,2);
   define vdias_acum_int money(14,2);
   define vret_mes_ant money(14,2);
   define vcong_mes_ant money(14,2);
   define vlim_sbg_ccc money(14,2);
   define vimp_sbg_ccc money(14,2);
   define vimp_chq_sbg money(14,2);
   define vsaldo_sbc money(14,2);
   define vint_acum money(14,2);
   define visr_acum money(14,2);
   define vnum_tarjeta char(16);
   define vmaxsecuencia smallint;
   define vtotretiros,vtotdepositos,vtotinrpag,vtotcomcobrada,vtotintpag,
          vtotcombonif,vtotivacobrado,vtotivabonif,vtotisrcobrado money(14,2);
   define vbandcorte char(1);
   define v_cuantos smallint;

   -- ******** Nuevas Variables ********

   DEFINE vt_monto_tot  MONEY(14,2);
   DEFINE vt_naturaleza CHAR(1);
   DEFINE vt_transacc   CHAR(4);
   DEFINE vt_tasa_aplicada DECIMAL(9,6);
   DEFINE vt_tipo_tran  CHAR(2);

   BEGIN
      ON EXCEPTION SET vsqlerr
         IF vsqlerr <> 0 THEN
            LET vcodret = vsqlerr;
            RETURN vcodret;
         END IF;
      END EXCEPTION;

      --SET DEBUG FILE TO "/tmp/inicio_mes.out";
      --TRACE ON;

      LET vcodret = "000";
      LET v_cuantos = 0;
      SET LOCK MODE TO WAIT 3;
      SELECT prox_fecha, fecha_hoy, pri_dia_mes, ult_dia_mes
      INTO vfecha_prox, vfecha_hoy, vfechaini, vfechafin
      FROM sc_fechas
      WHERE empresa = pempresa;

      LET vfecha_prox  = "02012009";
      LET vfecha_hoy   = "01312009";
      LET vfechaini = "01012009";
      LET vfechafin = "01312009";

      LET vdias = day(vfecha_prox)-1;

      -- *********** Procesos de Primer Dia Habil ****************

      LET vaniomes = year(vfecha_hoy)||lpad(month(vfecha_hoy),2,"0");

      SELECT valor
      INTO vtraninteres
      FROM sc_param
      WHERE empresa = pempresa AND codparam = "tranpagint";

      SELECT valor
      INTO vtranisr
      FROM sc_param
      WHERE empresa = pempresa AND codparam = "tranisr";

      -- *** Pasa Maestro de Cheques a Maestro historico de saldos (maehis) ***

      SELECT COUNT(*)
      INTO v_cuantos
      FROM sc_contproc
      WHERE empresa = pempresa
      AND proceso = "inicio_mes"
      AND fecha = vfecha_hoy;

      IF v_cuantos IS NULL OR v_cuantos = 0 THEN
         UPDATE sc_contproc
	 SET fecha = vfecha_hoy
         WHERE empresa = pempresa
         AND proceso = "inicio_mes";
      ELSE
         RETURN vcodret;
      END IF

      -- *************** TABLA TEMPORAL ***************

      SELECT *
        FROM sc_movhis
       WHERE empresa = pempresa
         AND fech_alt between vfechaini and vfechafin
         AND cancelad <> "S"
      INTO TEMP temp_movhis WITH NO LOG;
      CREATE INDEX idx_temp_movhis ON temp_movhis(empresa,cuenta, transacc) USING BTREE;
update statistics medium for table temp_movhis;
      -- ******************* FOREACH PRINCIPAL **************************

      FOREACH
         SELECT mc.cuenta,cuenta_clabe,sucursal,mc.producto,mc.num_cte,
                status_cta,motivo,fec_cancelac,sdo_retenido,sdo_cong,
                sdo_actual,envio_direcc,direcc_envio,sdo_mes_ant,
                acum_sdo_pos,dia_sdo_pos,acum_sdo_int,dias_acum_int,
                ret_mes_ant,cong_mes_ant,lim_sbg_ccc,imp_sbg_ccc,
                imp_chq_sbg,saldo_sbc,int_acum,isr_acum,pago_interes
           INTO vcuenta,vcuenta_clabe,vsucursal,vproducto,vnum_cte,
                vstatus_cta,vmotivo,vfec_cancelac,vsdo_retenido,vsdo_cong,
                vsdo_actual,venvio_direcc,vdirecc_envio,vsdo_mes_ant,
                vacum_sdo_pos,vdia_sdo_pos,vacum_sdo_int,vdias_acum_int,
                vret_mes_ant,vcong_mes_ant,vlim_sbg_ccc,vimp_sbg_ccc,
                vimp_chq_sbg,vsaldo_sbc,vint_acum,visr_acum,vpago_interes
           FROM sc_maechq mc, sc_maenoc mn, sc_producto pr
          WHERE mc.empresa = pempresa and mc.empresa = mn.empresa and
                mc.cuenta = mn.cuenta and mc.empresa = pr.empresa and
                mc.producto = pr.producto and
                mc.cuenta > "10000478798"

         SELECT max(secuencia)
         INTO vmaxsecuencia
         FROM sc_tarjeta
         WHERE empresa = pempresa AND cuenta = vcuenta AND tipo_tarjeta = "T";

         SELECT num_tarjeta
         INTO vnum_tarjeta
         FROM sc_tarjeta
         WHERE empresa = pempresa AND cuenta = vcuenta AND secuencia = vmaxsecuencia;

         IF vnum_tarjeta is null THEN
            LET vnum_tarjeta = "";
         END IF

         -- *** Inicializa Variables ***

         LET vtotdepositos = 0;
         LET vtotretiros = 0;
         LET vtotintpag = 0;
         LET vtasa_bruta = 0;
         LET vtotcomcobrada = 0;
         LET vtotcombonif = 0;
         LET vtotivacobrado = 0;
         LET vtotivabonif = 0;
         LET vtotisrcobrado = 0;

         -- **********************************************************
         --        Ciclo para los Acumulados por cuenta
         -- **********************************************************

         FOREACH
            SELECT monto_tot,naturaleza,transacc,nvl(mv.tasa_aplicada,0),tipo_tran
              INTO vt_monto_tot,vt_naturaleza,vt_transacc,vt_tasa_aplicada,vt_tipo_tran
              FROM temp_movhis mv, bdinteg:si_transacc tr
             WHERE mv.empresa = pempresa
               AND cuenta = vcuenta
               AND numero = transacc

            -- ************* Total depositos *******************

            IF vt_naturaleza = "A" THEN
               LET vtotdepositos = vtotdepositos + vt_monto_tot;

               IF vt_tipo_tran in("01","05","09") THEN --// Total comisiones bonificadas
                  LET vtotcombonif = vtotcombonif + vt_monto_tot;
               END IF

               IF vt_tipo_tran in("02","04","06","08","10") THEN --// Total ivas bonificados
                  LET vtotivabonif = vtotivabonif + vt_monto_tot;
               END IF
            ELIF vt_naturaleza = "C" THEN --//Total retiros
               LET vtotretiros = vtotretiros + vt_monto_tot;

               IF vt_tipo_tran in("01","05") THEN --// Total comisiones cobradas
                  LET vtotcomcobrada = vtotcomcobrada + vt_monto_tot;
               END IF

               IF vt_tipo_tran in("02","04","06","08") THEN --// Total iva cobrado
                  LET vtotivacobrado = vtotivacobrado + vt_monto_tot;
               END IF
            END IF

            -- ******** Total pago intereses *************

            IF vt_transacc = vtraninteres THEN
               LET vtotintpag = vtotintpag + vt_monto_tot;
               LET vtasa_bruta = vt_tasa_aplicada;
            END IF

            -- ************* Total isr cobrado ******************

            IF vt_transacc = vtranisr THEN
               LET vtotisrcobrado = vtotisrcobrado + vt_monto_tot;
            END IF

         END FOREACH

         LET vtotcomcobrada = vtotcomcobrada - vtotcombonif;
         LET vtotivacobrado = vtotivacobrado - vtotivabonif;
         LET vtotretiros = vtotretiros - vtotcomcobrada - vtotivacobrado - vtotisrcobrado;

         -- ***************************************************************
         --                           Fin Ciclo...
         -- ***************************************************************

         if vpago_interes = "D" OR vpago_interes = "M" OR
            (vpago_interes = "T" AND (month(vfecha_prox) = "4" OR
            month(vfecha_prox) = "7" OR month(vfecha_prox) = "10" OR
            month(vfecha_prox) = "1")) OR (vpago_interes = "S" AND
            (month(vfecha_prox) = "7" OR month(vfecha_prox) = "1")) OR
            (vpago_interes = "A" AND month(vfecha_prox) = "1") THEN

            LET vbandcorte = "S";
         ELSE
            LET vbandcorte = "N";
         END IF

         IF vbandcorte = "S" THEN
	    LET vaniomes = vaniomes;
	    LET vcuenta = vcuenta;

            INSERT INTO sc_maehis
            VALUES(pempresa,vaniomes,vcuenta,vfechaini,vfechafin,
               vcuenta_clabe,vnum_tarjeta,vsucursal,vproducto,vnum_cte,
               vstatus_cta,vmotivo,vfec_cancelac,vsdo_retenido,
               vsdo_cong,vsdo_actual,venvio_direcc,vdirecc_envio,
               vsdo_mes_ant,vacum_sdo_pos,vdia_sdo_pos,vacum_sdo_int,
               vdias_acum_int,vtasa_bruta,vret_mes_ant,vcong_mes_ant,
               vlim_sbg_ccc,vimp_sbg_ccc,vimp_chq_sbg,vsaldo_sbc,vint_acum,
               visr_acum,vtotdepositos,vtotretiros,vtotintpag,
               vtotcomcobrada,vtotivacobrado,vtotisrcobrado);
         END IF

         INSERT INTO sc_maehiscont
         VALUES(pempresa,vaniomes,vcuenta,vsucursal,vproducto,
                vstatus_cta,vsdo_actual,vacum_sdo_pos,vdia_sdo_pos,
                vtotdepositos,vtotretiros,vtotintpag,
                vtotcomcobrada,vtotivacobrado,vtotisrcobrado, vint_acum);

         -- **************** Inicializa maechq ******************

         LET vsdo_mes_ant = vsdo_actual;

         IF vdia_sdo_pos > 0 THEN
            LET vsdo_prom_mesant = vacum_sdo_pos / vdia_sdo_pos;
         ELSE
            LET vsdo_prom_mesant = 0;
         END IF

         IF vdias > 0 THEN
            LET vacum_sdo_pos = vsdo_actual * vdias;
            LET vdia_sdo_pos = vdias;
         ELSE
            LET vacum_sdo_pos = 0;
            LET vdia_sdo_pos = 0;
         END IF

         IF vpago_interes IS NULL or vpago_interes = " " THEN
            LET vpago_interes = "M";
         END IF

         IF vbandcorte = "S" THEN
            UPDATE sc_maenoc
            SET acum_sbc        = 0,
                acum_rem        = 0,
                dia_sdo_pos     = vdia_sdo_pos,
                acum_sdo_pos    = vacum_sdo_pos,
                dias_acum_int   = vdia_sdo_pos,
                acum_sdo_int    = vacum_sdo_pos,
                sdo_mes_ant     = vsdo_mes_ant,
                sdo_prom_mesant = vsdo_prom_mesant,
                int_acum        = 0,
                isr_acum        = 0,
                ret_mes_ant     = vsdo_retenido,
                cong_mes_ant    = vsdo_cong
            WHERE empresa = pempresa and cuenta = vcuenta;

            UPDATE sc_maechq
            SET chq_exp_mes    = 0,
                chq_dev        = 0,
                monto_dev      = 0,
                sdo_dia_ant    = vsdo_mes_ant,
                num_cgos_mes   = 0,
                imp_cgos_mes   = 0,
                num_abonos_mes = 0,
                imp_abonos_mes = 0
            WHERE empresa = pempresa and cuenta = vcuenta;
         ELSE
            UPDATE sc_maenoc
            SET acum_sbc        = 0,
                acum_rem        = 0,
                sdo_mes_ant     = vsdo_mes_ant,
                sdo_prom_mesant = vsdo_prom_mesant,
                ret_mes_ant     = vsdo_retenido,
                cong_mes_ant    = vsdo_cong
            WHERE empresa = pempresa and cuenta = vcuenta;
         END IF
      END FOREACH;
   RETURN vcodret;
   END;
END PROCEDURE;
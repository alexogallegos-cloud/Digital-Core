CREATE PROCEDURE "informix".tmpinicio_mes(pempresa char(3))
        RETURNING CHAR(5);

-- ********************** Definicion de Variables ****************
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

 
BEGIN
   ON EXCEPTION SET vsqlerr
      if vsqlerr <> 0 then
         let vcodret = vsqlerr;
         RETURN vcodret;
      end if;
   end EXCEPTION;

let vcodret = "000";
let v_cuantos = 0;

select prox_fecha, fecha_hoy, pri_dia_mes, ult_dia_mes
   into vfecha_prox, vfecha_hoy, vfechaini, vfechafin
   from sc_fechaspaso where empresa = pempresa;

let vdias = day(vfecha_prox)-1;

-- Procesos de Primer Dia Habil
--if month(vfecha_prox) != month(vfecha_hoy) then
  let vaniomes = year(vfecha_hoy)||lpad(month(vfecha_hoy),2,"0");
   select valor into vtraninteres
      from sc_param
      where empresa = pempresa and codparam = "tranpagint";
   select valor into vtranisr
      from sc_param
      where empresa = pempresa and codparam = "tranisr";
   --Pasa Maestro de Cheques a Maestro historico de saldos (maehis)

   SELECT COUNT(*) INTO v_cuantos
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
       --  RETURN vcodret;
   END IF

   SET ISOLATION TO DIRTY READ;

   foreach
      select mc.cuenta,cuenta_clabe,sucursal,mc.producto,mc.num_cte,
             status_cta,motivo,fec_cancelac,sdo_retenido,sdo_cong,
             sdo_dia_ant,envio_direcc,direcc_envio,sdo_mes_ant,
             acum_sdo_pos,dia_sdo_pos,acum_sdo_int,dias_acum_int,
             ret_mes_ant,cong_mes_ant,lim_sbg_ccc,imp_sbg_ccc,
             imp_chq_sbg,saldo_sbc,int_acum,isr_acum,pago_interes
         into vcuenta,vcuenta_clabe,vsucursal,vproducto,vnum_cte,
             vstatus_cta,vmotivo,vfec_cancelac,vsdo_retenido,vsdo_cong,
             vsdo_actual,venvio_direcc,vdirecc_envio,vsdo_mes_ant,
             vacum_sdo_pos,vdia_sdo_pos,vacum_sdo_int,vdias_acum_int,
             vret_mes_ant,vcong_mes_ant,vlim_sbg_ccc,vimp_sbg_ccc,
             vimp_chq_sbg,vsaldo_sbc,vint_acum,visr_acum,vpago_interes
         from sc_maechq mc, sc_maenoc mn, sc_producto pr
         where mc.empresa = pempresa and mc.empresa = mn.empresa and
               mc.cuenta = mn.cuenta and mc.empresa = pr.empresa and
               mc.producto = pr.producto
          
      select max(secuencia) into vmaxsecuencia
         from sc_tarjeta
         where empresa = pempresa and cuenta = vcuenta and
               tipo_tarjeta = "T";
      select num_tarjeta into vnum_tarjeta
         from sc_tarjeta
         where empresa = pempresa and cuenta = vcuenta and
               secuencia = vmaxsecuencia;
      if vnum_tarjeta is null then
         let vnum_tarjeta = "";
      end if

      select sum(monto_tot) into vtotdepositos
         from sc_movhis mv, bdinteg:si_transacc tr
         where mv.empresa = pempresa and cuenta = vcuenta and
               fech_alt between vfechaini and vfechafin and
               numero = transacc and cancelad <> "S" and
               naturaleza = "A";
      if vtotdepositos is null then
         let vtotdepositos = 0;
      end if

      select sum(monto_tot) into vtotretiros
         from sc_movhis mv, bdinteg:si_transacc tr
         where mv.empresa = pempresa and cuenta = vcuenta and
               fech_alt between vfechaini and vfechafin and
               numero = transacc and cancelad <> "S" and
               naturaleza = "C";
      if vtotretiros is null then
         let vtotretiros = 0;
      end if

      --select monto_tot,tasa_aplicada into vtotintpag,vtasa_bruta
        select sum(monto_tot) into vtotintpag
         from sc_movhis mv
         where mv.empresa = pempresa and cuenta = vcuenta and
               fech_alt between vfechaini and vfechafin and
               cancelad <> "S" and transacc = vtraninteres;
      if vtotintpag is null then
         let vtotintpag = 0;
      end if

      let vtasa_bruta = 0;

      select sum(monto_tot) into vtotcomcobrada
         from sc_movhis mv, bdinteg:si_transacc tr
         where mv.empresa = pempresa and cuenta = vcuenta and
               fech_alt between vfechaini and vfechafin and
               numero = transacc and cancelad <> "S" and
               naturaleza = "C" and tipo_tran in("01","05");
      if vtotcomcobrada is null then
         let vtotcomcobrada = 0;
      end if

      select sum(monto_tot) into vtotcombonif
         from sc_movhis mv, bdinteg:si_transacc tr
         where mv.empresa = pempresa and cuenta = vcuenta and
               fech_alt between vfechaini and vfechafin and
               numero = transacc and cancelad <> "S" and
               naturaleza = "A" and tipo_tran in("01","05","09");
      if vtotcombonif is null then
         let vtotcombonif = 0;
      end if
      let vtotcomcobrada = vtotcomcobrada - vtotcombonif;

      select sum(monto_tot) into vtotivacobrado
         from sc_movhis mv, bdinteg:si_transacc tr
         where mv.empresa = pempresa and cuenta = vcuenta and
               fech_alt between vfechaini and vfechafin and
               numero = transacc and cancelad <> "S" and
               naturaleza = "C" and tipo_tran in("02","04","06","08");
      if vtotivacobrado is null then
         let vtotivacobrado = 0;
      end if

      select sum(monto_tot) into vtotivabonif
         from sc_movhis mv, bdinteg:si_transacc tr
         where mv.empresa = pempresa and cuenta = vcuenta and
               fech_alt between vfechaini and vfechafin and
               numero = transacc and cancelad <> "S" and
               naturaleza = "A" and tipo_tran in("02","04","06","08","10");
      if vtotivabonif is null then
         let vtotivabonif = 0;
      end if
      let vtotivacobrado = vtotivacobrado - vtotivabonif;

      select sum(monto_tot) into vtotisrcobrado
         from sc_movhis mv
         where mv.empresa = pempresa and cuenta = vcuenta and
               fech_alt between vfechaini and vfechafin and
               cancelad <> "S" and transacc = vtraninteres;
      if vtotisrcobrado is null then
         let vtotisrcobrado = 0;
      end if
      let vtotretiros = vtotretiros - vtotintpag - vtotcomcobrada -
                        vtotivacobrado - vtotisrcobrado;
      if vpago_interes = "D" or vpago_interes = "M" or
         (vpago_interes = "T" and
         (month(vfecha_prox) = "4" or month(vfecha_prox) = "7" or
          month(vfecha_prox) = "10" or month(vfecha_prox) = "1")) or
         (vpago_interes = "S" and
         (month(vfecha_prox) = "7" or month(vfecha_prox) = "1")) or
         (vpago_interes = "A" and month(vfecha_prox) = "1") then
         let vbandcorte = "S";
      else
         let vbandcorte = "N";
      end if
      if vbandcorte = "S" then
	 LET vaniomes = vaniomes;
	 LET vcuenta = vcuenta;
         insert into sc_maehis
            values(pempresa,vaniomes,vcuenta,vfechaini,vfechafin,
               vcuenta_clabe,vnum_tarjeta,vsucursal,vproducto,vnum_cte,
               vstatus_cta,vmotivo,vfec_cancelac,vsdo_retenido,
               vsdo_cong,vsdo_actual,venvio_direcc,vdirecc_envio,
               vsdo_mes_ant,vacum_sdo_pos,vdia_sdo_pos,vacum_sdo_int,
               vdias_acum_int,vtasa_bruta,vret_mes_ant,vcong_mes_ant,
               vlim_sbg_ccc,vimp_sbg_ccc,vimp_chq_sbg,vsaldo_sbc,vint_acum,
               visr_acum,vtotdepositos,vtotretiros,vtotintpag,
               vtotcomcobrada,vtotivacobrado,vtotisrcobrado);
      end if
      IF NOT EXISTS (SELECT vcuenta
                       FROM sc_maehiscont
                      WHERE empresa = pempresa
                        AND cuenta = vcuenta
                        AND aniomes = vaniomes) THEN
         insert into sc_maehiscont
            values(pempresa,vaniomes,vcuenta,vsucursal,vproducto,
                   vstatus_cta,vsdo_actual,vacum_sdo_pos,vdia_sdo_pos,
                   vtotdepositos,vtotretiros,vtotintpag,
                   vtotcomcobrada,vtotivacobrado,vtotisrcobrado, vint_acum);
      END IF
      -- Inicializa maechq
      let vsdo_mes_ant = vsdo_actual;
      if vdia_sdo_pos > 0 then
         let vsdo_prom_mesant = vacum_sdo_pos / vdia_sdo_pos;
      else
         let vsdo_prom_mesant = 0;
      end if
      if vdias > 0 then
         let vacum_sdo_pos = vsdo_actual * vdias;
         let vdia_sdo_pos = vdias;
      else
         let vacum_sdo_pos = 0;
         let vdia_sdo_pos = 0;
      end if
      if vpago_interes IS NULL or vpago_interes = " " then
         let vpago_interes = "M";
      end if
      if vbandcorte = "S" then
         update sc_maenoc
            set acum_sbc        = 0,
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
            where empresa = pempresa and cuenta = vcuenta;
         update sc_maechq
            set chq_exp_mes    = 0,
                chq_dev        = 0,
                monto_dev      = 0,
                sdo_dia_ant    = vsdo_mes_ant,
                num_cgos_mes   = 0,
                imp_cgos_mes   = 0,
                num_abonos_mes = 0,
                imp_abonos_mes = 0
            where empresa = pempresa and cuenta = vcuenta;
      else
         update sc_maenoc
            set acum_sbc        = 0,
                acum_rem        = 0,
                dia_sdo_pos     = vdia_sdo_pos,
                acum_sdo_pos    = vacum_sdo_pos,
                dias_acum_int   = dias_acum_int + vdia_sdo_pos,
                acum_sdo_int    = acum_sdo_int + vacum_sdo_pos,
                sdo_mes_ant     = vsdo_mes_ant,
                sdo_prom_mesant = vsdo_prom_mesant,
                ret_mes_ant     = vsdo_retenido,
                cong_mes_ant    = vsdo_cong
            where empresa = pempresa and cuenta = vcuenta;
      end if
   end foreach
--end if
RETURN vcodret;
end
end PROCEDURE;
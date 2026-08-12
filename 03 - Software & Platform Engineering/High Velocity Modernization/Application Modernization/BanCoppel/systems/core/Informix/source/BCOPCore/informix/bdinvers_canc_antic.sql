create procedure "informix".canc_antic(pempresa char(3),
                           psucursal char(4),
                           pusuario char(8),
                           ptransacc char(4),
                           pcuenta char(20),
			   pfolio_suc char(16),
			   ptransacc_suc char(4),
                           ppagaint char(1))

returning char(5),money(14,2),decimal(9,6),money(14,2),money(14,2),
          money(14,2),money(14,2),char(4);

define vserial,sql_err,isam_err integer;
define vfecultmov,vfechalta, vfech_reinv date;
define vpagintcancta char(1);
define vsecuencia,vdias_prov,vplazo_nvo smallint;
define vstatus_cta,vfisica,vexento_isr,vinserta char(1);
define vproducto char(4);
define vprovision money(14,2);
define vcta_cheques char(20);
define vtip_per,vmoneda char(2);
define vplazo smallint;
define vsdo, vinteres_nvo, visr_nvo money(14,2);
define whora datetime hour to fraction;
define vcodret char(5);
define vsuc_cta,vsucursal char(4);
define vcod,vplaza char(3);
define vtrancanprov,vcod_instrum char(4);
define vtasa, vusuario char(8);
define vbandera char(1);
define vnum_cte char(20);
define vtrans_int,vtrans_ret,vtrans_isr,vtrans_prov,
       vtrans_vtopas2,vtransacc_suc,vtrans_recap,vtrans_reint char(4);
define vvalor_tasa,vval,vsobretasa decimal(9,6);
define vintprov,vsdo_actual,vsdo_retenido,vsdo_cong,vsdo_prom,
       vtot_int,visr,vtot_canc,vcapital,vprovinteres,
       vint_neto  money(14,2);
define vnum_dias_int,vfol_suc smallint;
define vfecha_hoy,vprox,vpri_dia date;
define vfecha_venc date;
define vper_acred_int char(1);
define wfol_suc char(5);
define wfolio char(16);
define vdia1,vdia2,vday,vday2,vfecha1,vfecha2 smallint;
define vlong_param char(2);

-- Inicializa variables
let vsdo_prom 	= 0;
let vvalor_tasa = 0;
let vsdo_actual = 0;
let vtot_int 	= 0;
let visr_nvo    = 0;
let vint_neto	= 0;
let vtot_canc 	= 0;
let vinserta 	= "1";
let vcodret 	= "000";
let vsuc_cta    = "000";
let vtransacc_suc = "0000";



   begin
      on exception set sql_err,isam_err
         if sql_err <> 0 or isam_err <> 0 then
            let vcodret = sql_err;
            return vcodret,vsdo_prom,vvalor_tasa,vsdo_actual,vint_neto,
            	   visr_nvo,vtot_canc,vsuc_cta;
         end if;
      end exception;

   select ejecutivo into vusuario from bdinteg:si_ejecut
      where ejecutivo = pusuario;
  if vusuario <> pusuario or vusuario is null then
      let vcodret = "107";
      return vcodret,vsdo_prom,vvalor_tasa,vsdo_actual,vint_neto,
       	     visr_nvo,vtot_canc,vsuc_cta;
   end if;

-- Extrae datos de la cuenta de Inversion
select secuencia,fecha_venc,fec_reinversion,mv.cod_instrum,sdo_mes_ant,
	mv.fecha_alta,status_cta,sdo_retenido,sdo_cong,capital,
	isr,tasa,sobretasa,mv.plazo,mv.plaza,
        sucursal,mv.per_acred_int,trans_int,trans_vtopas2,
        trans_isr,trans_prov,trans_recap,trans_reint,num_cte,
	num_dias_int,moneda,cta_cheques,fec_ult_mov
   into
        vsecuencia,vfecha_venc,vfech_reinv,vcod_instrum,vintprov,
	vfechalta,vstatus_cta,vsdo_retenido,vsdo_cong,
	vcapital,visr,vtasa,vsobretasa,vplazo,vplaza,vsucursal,
	vper_acred_int,vtrans_int,vtrans_vtopas2,
	vtrans_isr,vtrans_prov,vtrans_recap, vtrans_reint,
        vnum_cte,vnum_dias_int,vmoneda,vcta_cheques,vfecultmov
   from sv_maeinv mv,sv_instrum pr
   where mv.empresa = pempresa and cuenta = pcuenta and status_cta <> "4" and
   	pr.empresa = mv.empresa and mv.cod_instrum = pr.cod_instrum;

let vsuc_cta = vsucursal;
if vsecuencia is null then
	let vcodret = "100";
        return vcodret,vsdo_prom,vvalor_tasa,vsdo_actual,vint_neto,
            	visr_nvo,vtot_canc,vsuc_cta;
end if

if vper_acred_int is null then
      	let vcodret="333";
      	return vcodret,vsdo_prom,vvalor_tasa,vsdo_actual,vint_neto,
        visr_nvo,vtot_canc,vsuc_cta;
end if

--- Verifica que la cuenta no este cancelada
if vstatus_cta = "2" or vstatus_cta="4" then
	let vcodret = "200";
      	return vcodret,vsdo_prom,vvalor_tasa,vsdo_actual,vint_neto,
             visr_nvo,vtot_canc,vsuc_cta;
end if;

--- Verifica que la cuenta no este bloqueada
if vstatus_cta = "3" then
	let vcodret = "303";
      	return vcodret,vsdo_prom,vvalor_tasa,vsdo_actual,vint_neto,
             visr_nvo,vtot_canc,vsuc_cta;
end if;

--- Verifica que la cuenta no tenga saldo congelado o retenido
if vsdo_cong != 0 or vsdo_retenido != 0 then
    	let vcodret = "305";
      	return vcodret,vsdo_prom,vvalor_tasa,vsdo_actual,vint_neto,
             	visr_nvo,vtot_canc,vsuc_cta;
end if;
-- Determina Fecha
   select fecha_hoy,prox_fecha,pri_dia_mes into vfecha_hoy,vprox,vpri_dia
   from sv_fechas
   where empresa = pempresa;

   --- Verifica que la cancelacion sea anticipada
   if vfecha_venc <= vfecha_hoy  or vfechalta >= vfecha_hoy then
      let vcodret = "405";
      return vcodret,vsdo_prom,vvalor_tasa,vsdo_actual,vint_neto,
             visr_nvo,vtot_canc,vsuc_cta;
   end if

   if vfech_reinv < vpri_dia then
      let vdias_prov = vfecha_hoy - vpri_dia;
   else
      let vdias_prov = vfecha_hoy - vfech_reinv;
   end if;
   select importe into vcapital
      from sv_maeinstrucc
      where empresa = pempresa and cuenta = pcuenta and
            cap_int = "C" and aplicado = "N";
   if vcapital is null then
      let vcapital = 0;
   end if;

   --- Verifica si paga interes en cancelacion anticipada
   if ppagaint = "S" then
      let vpagintcancta = "S";
   else
      select valor into vpagintcancta
         from sv_param
         where empresa = pempresa and codparam = "pagintcancta";
      if vpagintcancta is null then
         let vpagintcancta = "N";
      end if
   end if

   --- Verifica el Total de Intereses
   if vpagintcancta = "S" then
      if vfecultmov is null then
         let vfecultmov = vfechalta;
      end if
      let vplazo_nvo = vfecha_hoy - vfecultmov;
      let vinteres_nvo = vcapital * vtasa * vplazo_nvo / vnum_dias_int / 100;
      let vprovinteres = vcapital * vtasa * vdias_prov / vnum_dias_int / 100;
      let visr_nvo = visr / vplazo * vplazo_nvo;
   else
      let vinteres_nvo = 0;
      let vprovinteres = 0;
      let visr_nvo = 0;
   end if
   let vtot_canc   = vcapital + vinteres_nvo - visr_nvo;
   let vsdo_actual = vtot_canc;
   let vint_neto = vinteres_nvo - visr_nvo;
   --- Realiza el movimiento del deposito de los intereses
   if vinteres_nvo > 0 then
      let whora = current hour to fraction;
      insert into sv_movdia
         values(pempresa,0,pfolio_suc,vplaza,psucursal,pusuario,vfecha_hoy,
                whora,vtrans_int,vsucursal,pcuenta,vsecuencia,vcod_instrum,
                0,vinteres_nvo,vinteres_nvo,0,0,"",vcapital,vtransacc_suc);
   end if
   if vprovinteres > 0 then
      let whora = current hour to fraction;
      insert into sv_movdia
         values(pempresa,0,pfolio_suc,vplaza,psucursal,pusuario,vfecha_hoy,
                whora,vtrans_prov,vsucursal,pcuenta,vsecuencia,vcod_instrum,
                0,vprovinteres,vprovinteres,0,0,"", vcapital,vtransacc_suc);
   end if
   insert into sv_auxcont
      values (pempresa,pcuenta,vtasa,vsobretasa);
   --- Realiza el movimiento del cargo de isr
   if visr_nvo > 0 then
      let whora = current hour to fraction;
      insert into sv_movdia
         values(pempresa,0,pfolio_suc,vplaza,psucursal,pusuario,vfecha_hoy,
                whora,vtrans_isr,vsucursal,pcuenta,vsecuencia,vcod_instrum,
                0,visr_nvo,visr_nvo,0,0,"",vcapital,vtransacc_suc);
   end if
   --- Realiza el movimiento del cargo del capital
   if vcapital > 0 then
      let whora = current hour to fraction;
      insert into sv_movdia
         values(pempresa,0,pfolio_suc,vplaza,psucursal,pusuario,vfecha_hoy,
                whora,vtrans_recap,vsucursal,pcuenta,vsecuencia,vcod_instrum,
                0,vcapital,vcapital,0,0,"",vcapital,vtransacc_suc);
   end if
   --- Realiza el movimiento del cargo del interes neto
   if vint_neto > 0 then
      let whora = current hour to fraction;
      insert into sv_movdia
         values(pempresa,0,pfolio_suc,vplaza,psucursal,pusuario,vfecha_hoy,
                whora,vtrans_reint,vsucursal,pcuenta,vsecuencia,vcod_instrum,
                0,vint_neto,vint_neto,0,0,"",vcapital,vtransacc_suc);
   end if
   if vtrans_vtopas2 <> "" and vtrans_vtopas2 is not null then
      let whora = current hour to fraction;
      insert into sv_movdia
         values(pempresa,0,pfolio_suc,vplaza,psucursal,pusuario,vfecha_hoy,
             whora,vtrans_vtopas2,vsucursal,pcuenta,vsecuencia,vcod_instrum,
             0,vcapital,vcapital,0,0,"",vcapital,vtransacc_suc);
   end if

   if vpagintcancta = "N" then
      --- Cancela provision de intereses contabilizada previamente|
      select valor into vtrancanprov
         from sv_param
         where empresa = pempresa and codparam = "trancanprov";
      if vintprov > 0 and vtrancanprov is not null then
         insert into sv_movdia
            values(pempresa,0,pfolio_suc,vplaza,psucursal,pusuario,vfecha_hoy,
                whora,vtrancanprov,vsucursal,pcuenta,vsecuencia,vcod_instrum,
                0,vintprov,vintprov,0,0,"",vcapital,vtransacc_suc);
      end if
   end if

   -- Actualiza el Maestro de Inversiones
   update sv_maeinv
      set status_cta   = "2",
          fec_cancelac = vfecha_hoy,
      	  modificado   = pusuario,
       	  fecha_mod    = vfecha_hoy
      where empresa = pempresa and cuenta = pcuenta and
            secuencia = vsecuencia;
   -- Actualiza el maestro de instrucciones
   update sv_maeinstrucc
      set aplicado = "S"
      where empresa = pempresa and cuenta = pcuenta;

   return vcodret,vsdo_prom,vvalor_tasa,vcapital,vint_neto,
          visr_nvo,vtot_canc,vsuc_cta;
end;   -- fin del on exception
end procedure;
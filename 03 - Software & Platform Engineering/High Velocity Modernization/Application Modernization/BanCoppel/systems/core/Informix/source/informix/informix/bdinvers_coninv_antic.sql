create procedure "informix".coninv_antic(pempresa char(3),
                              pcuenta   char(20),
			      pdivisa   char(3),
                              ppagaint  char(1))
returning char(5),money(14,2),money(14,2),money(14,2),char(20);

-- ***************************************************************************
-- Define variables
-- ***************************************************************************
   define cod_ret char(5);
   define vfecultmov,vfechalta,vfecvenc,vfechoy date;
   define vctaeje char(20);
   define vstatus_cta,vpagintcancta char(1);
   define visr,vintereses,vcapital,vrend_neto money(14,2);
   define visr_nvo, vinteres_nvo money(14,2);
   define vnum_dias_int,vplazo_nvo,vplazo,vsecuencia smallint;
   define vmoneda char(3);
   define vtasa decimal(9,6);
-- ***************************************************************************
-- Asigna variables
-- ***************************************************************************
   let cod_ret        = "000";
   let vcapital      = 0;
   let vrend_neto    = 0;
   let vctaeje = " ";



   select fecha_hoy into vfechoy
      from sv_fechas
      where empresa = pempresa;

-- ***************************************************************************
-- Verifica si existe la inversion y extrae su informacion
-- ***************************************************************************
   select status_cta,moneda,fecha_venc,capital,intereses,isr,cta_cheques,
          mv.fecha_alta, mv.plazo, fec_ult_mov, tasa+sobretasa,secuencia,
          num_dias_int
   into vstatus_cta,vmoneda,vfecvenc,vcapital,vintereses,visr,vctaeje,
        vfechalta,vplazo,vfecultmov,vtasa,vsecuencia,vnum_dias_int
   from sv_maeinv mv,sv_instrum pr
   where mv.empresa = pempresa and cuenta = pcuenta and status_cta <> "4" and
	 pr.empresa = mv.empresa and pr.cod_instrum = mv.cod_instrum;

-- ********************************************************************
-- Validaciones
-- ********************************************************************
   if vfecvenc is null then
      let cod_ret = "100";
      return cod_ret,vcapital,vrend_neto,visr,vctaeje;
   end if

   --- Verifica que la cuenta no este cancelada
   if vstatus_cta = "2" or vstatus_cta="4" then
      let cod_ret = "200";
      return cod_ret,vcapital,vrend_neto,visr,vctaeje;
   end if;

   --- Verifica que la cuenta no este bloqueada
    if vstatus_cta = "3" then
	let cod_ret = "303";
       return cod_ret,vcapital,vrend_neto,visr,vctaeje;
    end if;

   --- Verifica que la cancelacion sea anticipada
   if vfecvenc <= vfechoy  or vfechalta >= vfechoy then
      let cod_ret = "405";
      return cod_ret,vcapital,vrend_neto,visr,vctaeje;
   end if

   --- Verifica la divisa de sucursal vs la divisa de la inversion
   if vmoneda <> pdivisa then
      let cod_ret = "159";
      return cod_ret,vcapital,vrend_neto,visr,vctaeje;
   end if

   --- Verifica el Total de Capital para reinversion
   select importe into vcapital from sv_maeinstrucc
      where empresa = pempresa and cuenta = pcuenta and cap_int = "C"
            and aplicado <> "S";
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
      --- Calcula intereses de acuerdo a nuevo plazo
      if vfecultmov is null then
         let vfecultmov = vfechalta;
      end if
      let vplazo_nvo = vfechoy - vfecultmov;
      let vinteres_nvo = vcapital * vplazo_nvo * vtasa / vnum_dias_int / 100;
      let visr_nvo = visr / vplazo * vplazo_nvo;
      let vrend_neto = vinteres_nvo - visr_nvo;
   else
      let vrend_neto = 0;
      let visr_nvo = 0;
   end if
   if vcapital = 0 and vrend_neto = 0 then
      let cod_ret = "212";
   end if;
   return cod_ret,vcapital,vrend_neto,visr_nvo,vctaeje;
end procedure;
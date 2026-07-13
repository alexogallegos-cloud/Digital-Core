create procedure "informix".cons_inv(pempresa char(3),
                                     pcuenta   char(20),
			             pdivisa   char(3))
returning char(5),money(14,2),money(14,2),money(14,2),char(20);

-- ***************************************************************************
-- Define variables
-- ***************************************************************************
   define cod_ret char(5);
   define v_fecvenc,v_fechoy date;
   define v_ctaeje char(20);
   define vstatus_cta,v_cal_int_inv char(1);
   define v_isr,v_intereses,v_capital,v_rend_neto money(14,2);
   define vsecuencia smallint;
   define v_moneda char(3);
set isolation to dirty read;


-- ***************************************************************************
-- Asigna variables
-- ***************************************************************************
   let cod_ret        = "000";
   let v_capital      = 0;
   let v_rend_neto    = 0;
   let v_ctaeje = " ";

   select fecha_hoy into v_fechoy from sv_fechas where empresa = pempresa;

-- ***************************************************************************
-- Verifica si existe la inversion y extrae su informacion
-- ***************************************************************************
   select status_cta,moneda,fecha_venc,capital,intereses,isr,cta_cheques
	  into vstatus_cta,v_moneda,v_fecvenc,v_capital,v_intereses,
		v_isr,v_ctaeje
   from sv_maeinv mv,sv_instrum pr
   where mv.empresa = pempresa and cuenta = pcuenta and
	 pr.empresa = mv.empresa and pr.cod_instrum = mv.cod_instrum
         and mv.status_cta <> "4";

-- ********************************************************************
-- Validaciones
-- ********************************************************************
   --- Verifica que la cuenta exista
   if v_fecvenc is null then
      let cod_ret = "100";
      return cod_ret,v_capital,v_rend_neto,v_isr,v_ctaeje;
   end if

   --- Verifica que la cuenta no este cancelada
   if vstatus_cta = "2" or vstatus_cta="4" then
      let cod_ret = "200";
      return cod_ret,v_capital,v_rend_neto,v_isr,v_ctaeje;
   end if;

   --- Verifica que la cuenta no este bloqueada
    if vstatus_cta = "3" then
	let cod_ret = "303";
       return cod_ret,v_capital,v_rend_neto,v_isr,v_ctaeje;
    end if;

   --- Verifica que la inversion vence el dia de hoy
   if v_fecvenc <> v_fechoy then
      let cod_ret = "149";
      return cod_ret,v_capital,v_rend_neto,v_isr,v_ctaeje;
   end if

   --- Verifica la divisa de sucursal vs la divisa de la inversion
   if v_moneda <> pdivisa then
      let cod_ret = "159";
      return cod_ret,v_capital,v_rend_neto,v_isr,v_ctaeje;
   end if

   --- Verifica el Total de Capital para reinversion
   select importe into v_capital from sv_maeinstrucc
      where empresa = pempresa and cuenta = pcuenta and cap_int = "C" and
	    (inst_vento = "01" or inst_vento = "04") and aplicado <> "S";
   if v_capital is null then
      let v_capital = 0;
   end if;

   --- Verifica el Total de Intereses para reinversion
   select importe into v_rend_neto from sv_maeinstrucc
      where empresa = pempresa and cuenta = pcuenta and cap_int = "I" and
	    (inst_vento = "01" or inst_vento = "04") and aplicado <> "S";
   if v_rend_neto is null then
      let v_rend_neto = 0;
   else
      let v_rend_neto = v_intereses - v_isr;
   end if;
   if v_capital = 0 and v_rend_neto = 0 then
      let cod_ret = "212";
   end if;
   return cod_ret,v_capital,v_rend_neto,v_isr,v_ctaeje;
end procedure;
create procedure "informix".chq_comi(i_empresa char(3),
                           i_sucursal         char(3),
			   i_moneda           char(2),
			   i_unidades_divisa  money(14,2),
			   i_monto_mn         money(14,2),
                           i_porc_cob_com     decimal(8,5))
    returning char(5),money(14,2),money(14,2),money(14,2);

-- ###########################################################################;
-- DEFINE VARIABLES DE TRABAJO;
-- ###########################################################################;
   define v_existe,v_rowid smallint;
   define v_fecha_hoy date;
   define v_moneda char(1);
   define v_mto_abono_cta    money(14,2);
   define v_num_abono_cta    money(14,2);
   define v_beneficiario     char(40);
   define v_mto_efec_a_div   money(14,2);
   define v_mto_efec_a_val   money(14,2);
   define v_mto_efec_abono   money(14,2);
   define v_monto            money(14,2);
   define v_unid_divisa      money(14,2);
   define v_clave_cajero     char(8);
   define v_status_docto     char(1);
   define v_sucursal         char(3);
   define v_nomeje           char(15);
   define v_appat            char(15);
   define v_apmat            char(15);
   define v_plaza            char(3);
   define v_iva              decimal(5,3);
   define v_clave            char(8);
   define v_calculo_impuesto char(1);
   define v_valida_cve_autor char(1);
   define v_preve            money(12,7);
   define v_preco            money(12,7);
   define v_cve_c_caja       char(2);
   define v_com_c_caja       money(14,2);
   define v_cve_en_transito  char(1);
   define v_cve_liquidado    char(1);
   define v_cve_prevenido    char(1);
   define v_cve_desbloqueo   char(1);
   define v_cve_cancelado    char(1);
   define v_tran_venta       char(4);
   define v_tran_canc        char(4);
   define v_tran_liq         char(4);
   define v_mto_min          money(14,2);
   define v_mto_max          money(14,2);
   define v_factor           decimal(5,3);
   define v_com_fija         money(14,2);
   define v_num_act_suc      integer;
   define v_saldo            money(14,2);
   define v_ccc              money(14,2);
   define v_util_ccc         money(14,2);
   define v_fecha_ccc        date;
   define v_reten            money(14,2);
   define v_cong             money(14,2);
   define v_disp             money(14,2);
   define v_codigo_mn        char(2);

-- Variables de salida
   define o_comision,o_iva,o_total_com money(14,2);
   define o_stts char(28);
   define o_no_cheque char(10);
   define o_fechahorapago datetime year to second;
   define o_codret char(5);

   define codret char(5);
   define tranret char(4);

-- ###########################################################################
-- INICIALIZA VARIABLES
-- ###########################################################################
   let o_codret = "000";
   let o_comision = 0;
   let o_iva = 0;
   let o_total_com = 0;
   let o_stts = " ";
   let o_fechahorapago = " ";
   let o_no_cheque = " ";
-- ###########################################################################
-- RUTINA PRINCIPAL DEL PROGRAMA
-- ###########################################################################
   select valor into v_codigo_mn
      from bdinteg:si_param
      where empresa = i_empresa
      and   cod_param = 15;

   if v_codigo_mn is null then
      let o_codret = "115";
      return o_codret,o_comision,o_iva,o_total_com;
   end if
   select fecha_hoy into v_fecha_hoy
      from bdinteg:si_fechas
      where empresa = i_empresa;
   if v_fecha_hoy is null then
      let o_codret = "001";
      return o_codret,o_comision,o_iva,o_total_com;
   end if
   select plaza,iva into v_plaza,v_iva 
      from bdinteg:si_sucursales
      where empresa = i_empresa and sucursal = i_sucursal;
   if v_plaza is null then
      let o_codret = "003";
      return o_codret,o_comision,o_iva,o_total_com;
   end if
   if v_iva is null then
      let o_codret = "004";
      return o_codret,o_comision,o_iva,o_total_com;
   end if
   -- Extrae parametros de Transferencias
   select cve_chq_caja,com_chq_caja,cve_en_transito,
	  cve_liquidado,cve_prevenido,cve_desbloqueo,cve_cancelado,
	  tran_venta_chq_caj,tran_canc_chq_caj,tran_liq_chq_caj
      into v_cve_c_caja,v_com_c_caja,v_cve_en_transito,
          v_cve_liquidado,v_cve_prevenido,v_cve_desbloqueo,v_cve_cancelado,
	  v_tran_venta,v_tran_canc,v_tran_liq
      from st_param
      where empresa = i_empresa;
   if v_cve_c_caja is null then
      let o_codret = "005";
      return o_codret,o_comision,o_iva,o_total_com;
   end if
   -- Extrae Comisiones generales
   if i_moneda = v_codigo_mn then  
      select comision_fija_mn,monto_minimo_mn,monto_maximo_mn,factor_millar_mn
         into v_com_fija,v_mto_min,v_mto_max,v_factor
         from st_paramplaza
         where empresa    = i_empresa and
               cod_plaza  = v_plaza and
	       tipo_docto = v_cve_c_caja;
      if v_com_fija is null then
         let o_codret = "006";
         return o_codret,o_comision,o_iva,o_total_com;
      end if
      if v_com_fija > 0 then
         let v_com_c_caja = v_com_fija;
      else
         let v_com_c_caja = 0;
      end if
   else
      select comision_fija_od,monto_minimo_od,monto_maximo_od,factor_millar_od
         into v_com_fija,v_mto_min,v_mto_max,v_factor
         from st_paramplaza
         where empresa    = i_empresa and
               cod_plaza  = v_plaza and
	       tipo_docto = v_cve_c_caja;
      if v_com_fija is null then
         let o_codret = "006";
         return o_codret,o_comision,o_iva,o_total_com;
      end if
      if v_com_fija > 0 then
         let v_com_c_caja = v_com_fija;
      else
         let v_com_c_caja = 0;
      end if
   end if
   --  Valida si es Moneda Nacional para inicializar las unidades de divisa
   if i_moneda = v_codigo_mn then  -- NCB 8/Ene/97
      let i_unidades_divisa = "0";
      let v_preve = 1;
   else
      -- Si es moneda extranjera calcula tipo de cambio
      if i_unidades_divisa = 0 or
	 i_unidades_divisa is null or
	 i_unidades_divisa = " " then
	 let o_codret = "034";
	 return o_codret,o_comision,o_iva,o_total_com;
      end if
      select precio_venta into v_preve 
         from bdinteg:si_tpcambio
         where empresa = i_empresa and 
               divisa = i_moneda and clase_tpcambio = "B";
      if v_preve is null then
	 let o_codret = "105";
	 return o_codret,o_comision,o_iva,o_total_com;
      end if
      let v_preve = 1;
      let i_monto_mn = i_unidades_divisa * v_preve;
   end if
   -- Asigna Comision
   if v_com_fija > 0 then
      let o_comision = v_com_fija;
   else 
      let o_comision = (i_monto_mn * v_factor * v_preve) / 1000;
      if o_comision < (v_mto_min * v_preve) then
         let o_comision = v_mto_min * v_preve;
      end if
      if o_comision > (v_mto_max * v_preve) then
         let o_comision = v_mto_max * v_preve;
      end if
   end if
   if i_porc_cob_com is not null then
      let o_comision = o_comision * (i_porc_cob_com / 100);
   end if
   let o_iva = (o_comision) * v_iva;
   let o_total_com = i_monto_mn + o_comision + o_iva;
   return o_codret,o_comision,o_iva,o_total_com;
end procedure;
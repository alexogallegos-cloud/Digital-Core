create procedure "informix".ord_comi(i_empresa    char(3),
                          i_sucursal         char(3),
			  i_moneda           char(2),
			  i_unidades_divisa  money(14,2),
			  i_monto_mn         money(14,2),
			  i_banco_dest       char(4),
			  i_pais_dest        char(3),
			  i_estado_dest      char(2),
			  i_ciudad_dest      char(3))

   returning char(5), char(10), money(14,2), money(14,2), money(14,2),
	     money(14,2),money(14,2);


-- ###########################################################################;
-- DEFINE VARIABLES DE TRABAJO;
-- ###########################################################################;
   define v_existe,v_rowid   smallint;
   define v_fecha_hoy        date;
   define v_moneda           char(1);
   define v_folio_suc        char(16);
   define v_mto_abono_cta    money(14,2);
   define v_num_abono_cta    money(14,2);
   define v_beneficiario     char(40);
   define v_mto_efec_a_div   money(14,2);
   define v_mto_efec_a_val   money(14,2);
   define v_mto_efec_abono   money(14,2);
   define v_monto            money(14,2);
   define v_unid_divisa      money(14,2);
   define v_num_docto        char(10);
   define v_clave_cajero     char(8);
   define v_status_docto     char(1);
   define v_sucursal         char(3);
   define v_pais_o           char(3);
   define v_estado_o         char(3);
   define v_ciudad_o         char(3);
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
   define v_cve_o_pago       char(2);
   define v_com_o_pago       money(14,2);
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
   define v_num_bco          smallint;
   define v_num_bco_local    char(3);
   define v_num_moneda       smallint;
   define v_num_act_suc      integer;
   define v_bco_param        char(3);
   define v_com_o_pago_mn    money(14,2);
   define v_com_por_suc      char(1);
   define i,j                integer;
   define o_iva_total,
          o_com_total money(14,2);
   define v_codigo_mn        char(2);

-- Variables de salida
   define o_comision,o_iva,o_total_com,o_telef_telex,o_telef_telex_div,
          o_iva_gastos money(14,2);
   define o_stts char(28);
   define o_fechahorapago datetime year to second;
   define o_divisa_considera char(2);
   define o_codret char(5);
   define o_no_pago char(10);

-- ###########################################################################
-- INICIALIZA VARIABLES
-- ###########################################################################
   let o_codret        = "000";
   let o_comision      = 0;
   let o_iva           = 0;
   let o_iva_gastos    = 0;
   let o_total_com     = 0;
   let o_telef_telex   = 0;
   let o_stts          = " ";
   let o_no_pago       = " ";
   let o_iva_total = 0;
   let o_com_total = 0;
   let v_com_fija = 0;
-- ###########################################################################
-- RUTINA PRINCIPAL DEL PROGRAMA
-- ###########################################################################
  select valor into v_bco_param
  from   bdinteg:si_param
  where  cod_param = 5
  and    empresa = i_empresa;
  select valor into v_codigo_mn
  from   bdinteg:si_param
  where  cod_param = 15
  and    empresa = i_empresa;

   select pais, estado, ciudad, plaza, iva
   into v_pais_o, v_estado_o, v_ciudad_o, v_plaza, v_iva
   from bdinteg:si_sucursales
   where sucursal = i_sucursal;

   select cve_orden_pago, com_orden_pago, cve_en_transito,
	  cve_liquidado, cve_prevenido, cve_desbloqueo,
	  cve_cancelado,
	  tran_venta_orden_p, tran_canc_orden_p, tran_liq_orden_p,
	  com_por_suc
      into v_cve_o_pago, v_com_o_pago_mn, v_cve_en_transito,
	  v_cve_liquidado, v_cve_prevenido, v_cve_desbloqueo,
	  v_cve_cancelado,
	  v_tran_venta, v_tran_canc, v_tran_liq,
	  v_com_por_suc
      from st_param;

   if v_cve_o_pago is null then
      let o_codret = "005";
      return o_codret,o_no_pago,o_comision,o_iva,
      o_total_com, o_telef_telex, o_iva_gastos;
   end if

if v_com_por_suc = "N" then
      if v_com_o_pago_mn = 0 then
	 select mto_min_orden_pago, mto_max_orden_pago, fac_millar_orden_p
	    into v_mto_min, v_mto_max, v_factor
	    from st_param;
      end if
else
 -- Extrae Comisiones generales
    if i_moneda = v_codigo_mn then
      select comision_fija_mn, monto_minimo_mn, monto_maximo_mn,
	factor_millar_mn
	into v_com_fija, v_mto_min, v_mto_max, v_factor
	from st_paramplaza
	where cod_plaza  = v_plaza and
	    tipo_docto = v_cve_o_pago;
    else
      select comision_fija_od, monto_minimo_od, monto_maximo_od,
	factor_millar_od
	into v_com_fija, v_mto_min, v_mto_max, v_factor
	from st_paramplaza
	where cod_plaza  = v_plaza and
	    tipo_docto = v_cve_o_pago;
     end if
end if

   if v_com_fija is null then
      let o_codret = "006";
      return o_codret,o_no_pago,o_comision,o_iva,
      o_total_com, o_telef_telex, o_iva_gastos;

   end if
   if v_com_fija > 0 then
      let v_com_o_pago_mn = v_com_fija;
   else
      let v_com_o_pago_mn = 0;
   end if

   -- Verifica que el Banco indicado como destino Exista
   select count(*) into v_num_bco from bdinteg:si_bancos
   where banco = i_banco_dest;
   if v_num_bco < 1 then
      let o_codret = "026";
      return o_codret,o_no_pago,o_comision,o_iva,
      o_total_com, o_telef_telex, o_iva_gastos;

   end if

   -- Verifica que la Moneda en que se Vende el Docto. exista
   select count(*) into v_num_moneda from bdinteg:si_divisas
   where divisa = i_moneda;
   if v_num_moneda < 1 then
      let o_codret = "027";
      return o_codret,o_no_pago,o_comision,o_iva,
      o_total_com, o_telef_telex, o_iva_gastos;
   end if

   -- Valida si es Moneda Nacional para inicializar las unidades de divisa
   if i_moneda = v_codigo_mn then
      let i_unidades_divisa = "0";
      let v_moneda = "0";
      let v_preve = 1;
   else
      -- Si es moneda extranjera calcula tipo de cambio
      select precio_venta into v_preve from  bdinteg:si_tpcambio
      where divisa = i_moneda and clase_tpcambio = "B";
      if v_preve is null then
	 let o_codret = "008";
	 return o_codret,o_no_pago,o_comision,o_iva,
	 o_total_com, o_telef_telex, o_iva_gastos;
      end if
      -- La sig. Linea debera eliminarse cuando se decida que Central debe Valorizar
      let v_preve = 1;
      let i_monto_mn = i_unidades_divisa * v_preve;
   end if
   -- Asigna el Importe de la Comision
   if v_com_fija > 0 then
      let o_comision = v_com_fija * v_preve;
   else
      let o_comision = (i_monto_mn * v_factor * v_preve) / 1000;
      if o_comision < (v_mto_min * v_preve) then
	 let o_comision = v_mto_min * v_preve;
      end if
      if o_comision > (v_mto_max * v_preve) then
	 let o_comision = v_mto_max * v_preve;
      end if
   end if
   let o_iva = (o_comision) * v_iva;
   -- Busca los cargos por transmision
   select monto_a_cobrar,divisa_considerada,monto_a_cobrar_div
      into o_telef_telex, o_divisa_considera, o_telef_telex_div
      from st_zonas
      where pais_origen = v_pais_o and
	    estado_origen = v_estado_o and
	    pais_destino = i_pais_dest and
	    estado_destino = i_estado_dest;
      if o_telef_telex is null then
         let o_telef_telex = 0;
         let o_telef_telex_div = 0;
      end if
   if i_moneda != v_codigo_mn then
      let o_telef_telex = v_preve * o_telef_telex_div;
   end if
   let o_iva_gastos = o_telef_telex * v_iva;
   let o_total_com = i_monto_mn + o_comision + o_iva + o_telef_telex + o_iva_gastos;
   let o_iva_total = o_iva + o_iva_gastos;
   let o_com_total = o_comision + o_telef_telex;
   -- Las sig. lineas se integran a peticion del usuario, debido a los problemas presentados
   -- para la definicion de la transaccion en Visual. 2/Jul/96 NCB.
   if i_unidades_divisa != 0 then
      let o_comision    = o_comision / v_preve;
      let o_iva         = o_iva / v_preve;
      let o_total_com   = o_total_com / v_preve;
      let o_telef_telex = o_telef_telex / v_preve;
      let o_iva_gastos  = o_iva_gastos / v_preve;
   end if
   return o_codret,o_no_pago,o_comision,o_iva,
   o_total_com, o_telef_telex, o_iva_gastos;

end procedure;
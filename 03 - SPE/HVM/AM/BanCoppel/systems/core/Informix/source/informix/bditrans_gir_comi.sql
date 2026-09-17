create procedure "informix".gir_comi( i_empresa          char(3),
                           i_sucursal         char(3),
			   i_moneda           char(2),
			   i_unidades_divisa  money(14,2),
			   i_monto_mn         money(14,2))

   returning char(5), money(14,2), money(14,2), money(14,2);
-- ###########################################################################;
-- DEFINE VARIABLES DE TRABAJO;
-- ###########################################################################;
   define v_fecha_hoy        date;
   define v_moneda           char(1);
   define v_unid_divisa      money(14,2);
   define v_num_docto        char(10);
   define v_status_docto     char(1);
   define v_plaza            char(3);
   define v_sucursal         char(3);
   define v_pais_o           char(3);
   define v_estado_o         char(3);
   define v_ciudad_o         char(3);
   define v_iva              decimal(2,2);
   define v_calculo_impuesto char(1);
   define v_valida_cve_autor char(1);
   define v_preve            money(12,7);
   define v_preco            money(12,7);
   define v_cve_giro_banc    char(2);
   define v_com_giro_banc    money(14,2);
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
   define v_codigo_mn        char(2);
-- Variables de salida
   define o_comision,o_iva,o_total_com,o_telef_telex,o_iva_gastos money(14,2);
   define o_stts char(28);
   define o_fechahorapago datetime year to second;
   define o_codret char(5);
   define o_no_giro char(10);


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
   let o_fechahorapago = " ";
   let o_no_giro       = " ";
-- ###########################################################################
-- RUTINA PRINCIPAL DEL PROGRAMA
-- ###########################################################################
   -- Obtiene el Codigo definido para el Banco en Parametros de S.I.
   select codigo_mn, banco into v_codigo_mn, v_num_bco_local
      from bdinteg:si_param
      where empresa = i_empresa;
   if v_codigo_mn is null then
      let o_codret = "115";
      return o_codret,o_comision,o_iva, o_total_com;
   end if
   select fecha_hoy into v_fecha_hoy
      from bdinteg:si_fechas
      where empresa = i_empresa;
   if v_fecha_hoy is null then
      let o_codret = "001";
      return o_codret,o_comision,o_iva, o_total_com;
   end if

   -- Obtiene el lugar en el que se situa la Sucursal Origen
   select plaza, pais, estado, ciudad, iva
      into v_plaza, v_pais_o, v_estado_o, v_ciudad_o, v_iva
      from bdinteg:si_sucursales
      where empresa = i_empresa and sucursal = i_sucursal;
   if v_plaza is null then
      let o_codret = "003";
      return o_codret,o_comision,o_iva, o_total_com;
   end if
   if v_iva is null then
      let o_codret = "004";
      return o_codret,o_comision,o_iva, o_total_com;
   end if
   -- Extrae parametros Generales de Transferencias
   select cve_giro_banc, com_giro_banc, cve_en_transito,
	  cve_liquidado, cve_prevenido, cve_desbloqueo, cve_cancelado,
	  tran_venta_giro_ba, tran_canc_giro_ba, tran_liq_giro_ba
      into v_cve_giro_banc, v_com_giro_banc, v_cve_en_transito,
	   v_cve_liquidado, v_cve_prevenido, v_cve_desbloqueo, v_cve_cancelado,
	   v_tran_venta, v_tran_canc, v_tran_liq
      from st_param
      where empresa = i_empresa;
    if v_cve_giro_banc is null then
       let o_codret = "005";
       return o_codret,o_comision,o_iva, o_total_com;
    end if
    -- Extrae Comisiones generales
    if i_moneda = v_codigo_mn then
       select comision_fija_mn, monto_minimo_mn, monto_maximo_mn, factor_millar_mn
	  into v_com_fija, v_mto_min, v_mto_max, v_factor
	  from st_paramplaza
	  where empresa = i_empresa and cod_plaza = v_plaza and
                tipo_docto = v_cve_giro_banc;
    else
       select comision_fija_od, monto_minimo_od, monto_maximo_od, factor_millar_od
	  into v_com_fija, v_mto_min, v_mto_max, v_factor
	  from st_paramplaza
	  where empresa = i_empresa and cod_plaza  = v_plaza and
  	        tipo_docto = v_cve_giro_banc;
    end if
    if v_com_fija is null then
       let o_codret = "006";
       return o_codret,o_comision,o_iva, o_total_com;
    end if
    if v_com_fija > 0 then
       let v_com_giro_banc = v_com_fija;
    else
       let v_com_giro_banc = 0;
    end if
    select count(*) into v_num_moneda
       from bdinteg:si_divisas
       where divisa = i_moneda;
    if v_num_moneda < 1 then
       let o_codret = "027";
       return o_codret,o_comision,o_iva, o_total_com;
    end if
    -- Valida si es Moneda Nacional para inicializar las unidades de divisa
    if i_moneda = v_codigo_mn then
       let i_unidades_divisa = 0;
       let v_moneda = v_codigo_mn;
       let v_preve = 1;
    else
       -- Si es moneda extranjera calcula tipo de cambio
       select precio_venta into v_preve
          from  bdinteg:si_tpcambio
          where empresa = i_empresa and divisa = i_moneda and
                clase_tpcambio = "B";
       if v_preve is null then
	  let o_codret = "105";
	  return o_codret,o_comision,o_iva, o_total_com;
       end if
       -- La sig. linea debera eliminarse cuando se decida que Central valorize
       let v_moneda = "1";
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
       if o_comision > v_mto_max * v_preve then
	  let o_comision = v_mto_max * v_preve;
       end if
    end if
    let o_iva = (o_comision) * v_iva;
    let o_total_com = i_monto_mn;

    -- Las sig. lineas se integran a peticion del usuario, debido a los problemas presentados
    -- para la definicion de la transaccion en Visual. 2/Jul/96 NCB.
    if i_unidades_divisa != 0 then
       let o_comision    = o_comision / v_preve;
       let o_iva         = o_iva / v_preve;
       let o_total_com   = o_total_com / v_preve;
    end if
    return o_codret,o_comision,o_iva, o_total_com;
end procedure;
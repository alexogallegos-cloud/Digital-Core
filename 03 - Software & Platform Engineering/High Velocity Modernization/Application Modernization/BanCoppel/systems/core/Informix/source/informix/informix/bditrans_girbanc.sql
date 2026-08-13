create procedure "informix".girbanc(i_empresa char(3),
                          i_tipmov           char(4),
                          i_tipo_docto       char(2),
                          i_usuario          char(8),
                          i_fecha_horaexp    datetime year to second,
                          i_folio            char(16),
                          i_sucursal         char(3),
                          i_cve_aut          char(8),
                          i_no_giro          char(10),
                          i_moneda           char(2),
                          i_unidades_divisa  money(14,2),
                          i_monto_mn         money(14,2),
                          i_mto_efec         money(14,2),
                          i_mto_efec_c_div   money(14,2),
                          i_mto_efec_c_val   money(14,2),
                          i_cta_cgo_abono    char(10),
                          i_mto_cgo_abono    money(14,2),
                          i_tipo_comision    char(1),
                          i_importe_comis    money(14,2),
                          i_porc_cob_com     decimal(8,5),
                          i_beneficiario     char(40),
                          i_nombre_comprador char(40),
                          i_telsolic         char(10),
                          i_domsolic         char(70),
                          i_banco_dest       char(3),
                          i_pais_dest        char(3),
                          i_estado_dest      char(2),
                          i_ciudad_dest      char(3))

   returning char(5),char(10),money(14,2),money(14,2),money(14,2),
             char(28),datetime year to second;

-- ###########################################################################;
-- DEFINE VARIABLES DE TRABAJO;
-- ###########################################################################;
   define v_existe,v_rowid   integer;
   define v_fecha_hoy        date;
   define v_moneda           char(2);
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
   define v_usuario          char(8);
   define v_status_docto     char(1);
   define v_sucursal         char(3);
   define v_pais_o           char(3);
   define v_estado_o         char(3);
   define v_ciudad_o         char(3);
   define v_nomeje           char(45);
   define v_plaza            char(3);
   define v_iva              decimal(2,2);
   define v_clave            char(8);
   define v_calculo_impuesto char(1);
   define v_valida_cve_autor char(1);
   define v_preve            money(12,7);
   define v_preco            money(12,7);
   define v_cve_giro_banc    char(2);
   define v_com_giro_banc    money(14,2);
   define v_cve_en_transito  char(1);
   define v_cve_liquidado    char(1);
   define v_cve_liq_cam      char(1);
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
   define v_producto         char(4);
   define v_tipo_moneda      char(2);
   define v_tipo_cambio      money(12,7);
   define v_num_automatico   char(1);
   define v_fecha            datetime year to day;
   define v_fecha_hora       char(19);
   define v_codigo_mn        char(2);
-- Variables de salida
   define o_comision         money(14,2);
   define o_iva              money(14,2);
   define o_total_com        money(14,2);
   define o_total_com1       money(14,2);
   define o_telef_telex      money(14,2);
   define o_iva_gastos       money(14,2);
   define o_stts             char(28);
   define o_fechahorapago    datetime year to second;
   define o_codret           char(5);
   define o_no_giro          char(10);
   define i,j                char(3);
   define sql_err,isam_err   integer;


-- ##########################################################################;
-- INICIALIZA VARIABLES
-- ##########################################################################;
   let v_folio_suc     = "999ORDPAGO100000";
   let o_codret        = "000";
   let o_comision      = 0;
   let o_iva           = 0;
   let o_iva_gastos    = 0;
   let o_total_com     = 0;
   let o_total_com1    = 0;
   let o_telef_telex   = 0;
   let o_stts          = " ";
   let o_fechahorapago = " ";
   let o_no_giro       = " ";

   begin
      on exception set sql_err,isam_err
         if sql_err <> 0 or isam_err <> 0 then
            let o_codret = sql_err;
            return o_codret,o_no_giro,o_comision,o_iva,o_total_com,o_stts,
                   o_fechahorapago;
         end if;
      end exception;

   select ejecutivo,nombre,sucursal
      into v_usuario,v_nomeje,v_sucursal
      from bdinteg:si_ejecut
      where empresa = i_empresa and ejecutivo = i_usuario;
   if v_usuario <> i_usuario or v_usuario is null then
      let o_codret = "002";
      return o_codret,o_no_giro,o_comision,o_iva,o_total_com,
             o_stts,o_fechahorapago;
   end if

   select codigo_mn into v_codigo_mn
      from bdinteg:si_param
      where empresa = i_empresa;
   if v_codigo_mn is null then
      let o_codret = "115";
      return o_codret,o_no_giro,o_comision,o_iva,o_total_com,
             o_stts,o_fechahorapago;
   end if

   select fecha_hoy into v_fecha_hoy
      from bdinteg:si_fechas
      where empresa = i_empresa;
   if v_fecha_hoy is null then
      let o_codret = "001";
      return o_codret,o_no_giro,o_comision,o_iva,o_total_com,
             o_stts,o_fechahorapago;
   end if

   if i_fecha_horaexp is null or i_fecha_horaexp = " " then
      let v_fecha         = v_fecha_hoy;
      let v_fecha_hora    = v_fecha || " " || current hour to second;
      let i_fecha_horaexp = v_fecha_hora;
   end if

   -- Obtiene el Codigo definido para el Banco en Parametros de S.I.
   select banco into v_num_bco_local
      from bdinteg:si_param
      where empresa = i_empresa;

   -- Obtiene el lugar en el que se situa la Sucursal Origen
   select plaza,pais,estado,ciudad,iva
      into v_plaza,v_pais_o,v_estado_o,v_ciudad_o,v_iva
      from bdinteg:si_sucursales
      where empresa = i_empresa and sucursal = i_sucursal;
   if v_plaza is null then
      let o_codret = "003";
      return o_codret,o_no_giro,o_comision,o_iva,o_total_com,
             o_stts,o_fechahorapago;
   end if
   if v_iva is null then
      let o_codret = "004";
      return o_codret,o_no_giro,o_comision,o_iva,o_total_com,
             o_stts,o_fechahorapago;
   end if
   -- Extrae parametros Generales de Transferencias
   select cve_giro_banc,com_giro_banc,cve_en_transito,
          cve_liquidado,cve_prevenido,cve_desbloqueo,cve_cancelado,
          tran_venta_giro_ba,tran_canc_giro_ba,tran_liq_giro_ba,
          num_autom_gir_ban,cve_liq_cam
     into v_cve_giro_banc,v_com_giro_banc,v_cve_en_transito,
          v_cve_liquidado,v_cve_prevenido,v_cve_desbloqueo,v_cve_cancelado,
          v_tran_venta,v_tran_canc,v_tran_liq,v_num_automatico,
          v_cve_liq_cam
    from st_param
    where empresa = i_empresa;
   if v_cve_giro_banc is null then
      let o_codret = "005";
      return o_codret,o_no_giro,o_comision,o_iva,o_total_com,
             o_stts,o_fechahorapago;
   end if
   -- Extrae Comisiones generales
   if i_moneda = v_codigo_mn then
      select comision_fija_mn,monto_minimo_mn,monto_maximo_mn,
             factor_millar_mn
         into v_com_fija,v_mto_min,v_mto_max,v_factor
         from st_paramplaza
         where empresa = i_empresa and cod_plaza  = v_plaza and
               tipo_docto = v_cve_giro_banc;
   else
      select comision_fija_od,monto_minimo_od,monto_maximo_od,
             factor_millar_od
         into v_com_fija,v_mto_min,v_mto_max,v_factor
         from st_paramplaza
         where empresa = i_empresa and cod_plaza  = v_plaza and
               tipo_docto = v_cve_giro_banc;
   end if
   if v_com_fija is null then
      let o_codret = "006";
      return o_codret,o_no_giro,o_comision,o_iva,o_total_com,
             o_stts,o_fechahorapago;
   end if
   if v_com_fija > 0 then
      let v_com_giro_banc = v_com_fija;
   else
      let v_com_giro_banc = 0;
   end if

-- *************************************************************************
if i_tipmov = "ALTA" then
   -- Valida si el numero de cheque debera ser asignado Automaticamente
   if v_num_automatico = "N" then
      if i_no_giro is null or i_no_giro = " " then
         let o_codret = "112";  -- Debe Recibirse el No. de Giro
         return o_codret,o_no_giro,o_comision,o_iva,o_total_com,
                o_stts,o_fechahorapago;
      else
         -- Verifica que NO exista aun
         select count(*) into v_existe
            from st_maetrans
            where empresa = i_empresa and
                  num_docto  = i_no_giro and tipo_docto = v_cve_giro_banc;
         if v_existe > 0  then
            let o_codret = "007";
            return o_codret,o_no_giro,o_comision,o_iva,o_total_com,
                   o_stts,o_fechahorapago;
         end if
      end if
   else
      let i_no_giro = " "; -- Blanqueo para Asignacion Automatica de Numero
   end if
   -- Verifica el Codigo del Banco Destino del Documento
   if i_banco_dest = "000" or i_banco_dest = " " or i_banco_dest is null then
      let i_banco_dest = v_num_bco_local;
   end if
   -- Verifica que el Banco indicado como destino Exista
   select count(*) into v_num_bco
      from bdinteg:si_bancos
      where banco = i_banco_dest;
   if v_num_bco < 1 then
      let o_codret = "026";
      return o_codret,o_no_giro,o_comision,o_iva,o_total_com,
             o_stts,o_fechahorapago;
   end if
   -- Verifica que la Moneda en que se Vende el Docto. exista
   select count(*) into v_num_moneda from bdinteg:si_divisas
      where divisa = i_moneda;
   if v_num_moneda < 1 then
      let o_codret = "027";
      return o_codret,o_no_giro,o_comision,o_iva,o_total_com,
             o_stts,o_fechahorapago;
   end if
   -- Valida si es Moneda Nacional para inicializar las unidades de divisa
   if i_moneda = v_codigo_mn then
      let i_unidades_divisa = 0;
      let v_preve = 1;
   else
      -- Si es moneda extranjera calcula tipo de cambio
      select precio_venta into v_preve
         from  bdinteg:si_tpcambio
         where empresa = i_empresa and divisa = i_moneda and
               clase_tpcambio = "B";
      -- La sig. linea debe eliminarse cuando el Central debe Valorizar
      let v_preve = 1;
      if v_preve is null then
         let o_codret = "105";
         return o_codret,o_no_giro,o_comision,o_iva,o_total_com,
                o_stts,o_fechahorapago;
      end if
      -- La 13 sigs lineas son TEMPORALES para considerar montos sin Valorizar
      -- excepto el monto a cargar a la Cuenta. 2/Jul/96 NCB
      let v_tipo_cambio = v_preve;
      let v_preve       = 1;
      if i_mto_cgo_abono != 0 then
         select producto,plaza into v_producto,v_plaza
            from bdicheq:sc_maechq
            where empresa = i_empresa and cuenta = i_cta_cgo_abono;
         select tp_moneda into v_tipo_moneda
            from bdicheq:sc_producto
            where empresa = i_empresa and codigo = v_producto
                  and plaza  = v_plaza;
         if v_tipo_moneda = v_codigo_mn then
            let i_mto_cgo_abono = i_mto_cgo_abono * v_tipo_cambio;
         end if
      end if
      let i_monto_mn = i_unidades_divisa * v_preve;
   end if
   -- Asigna el Importe de la Comision
   if v_com_fija > 0 then
      let o_comision = v_com_fija * v_preve;
   else
      let o_comision = (i_monto_mn * v_factor * v_preve) / 100;
      if o_comision < (v_mto_min * v_preve) then
         let o_comision = v_mto_min * v_preve;
      end if
      if o_comision > (v_mto_max * v_preve) then
         let o_comision = v_mto_max * v_preve;
      end if
   end if
   let o_iva = (o_comision) * v_iva;
   let o_total_com = i_monto_mn;
   let o_total_com1 = i_monto_mn + o_comision + o_iva;
   let o_iva_gastos = (o_telef_telex) * v_iva;
   -- Obtiene el Numero del Documento que se esta vendiendo
   -- De Acuerdo a Validacion Previa. NCB 19/Dic/96
   if i_no_giro is null or i_no_giro = " " then
      call stnumdocto (i_empresa,i_sucursal,v_cve_giro_banc)
           returning o_codret,v_num_act_suc,o_no_giro;
      if o_codret != "000" then
         return o_codret,o_no_giro,o_comision,o_iva,o_total_com,
                o_stts,o_fechahorapago;
      end if
      let i_no_giro = o_no_giro;
   end if
   -- Crea Movimiento Diario
   call stmovdia(i_empresa,v_plaza,i_sucursal,i_usuario,
                 i_fecha_horaexp,v_cve_en_transito,i_moneda,
                 v_cve_giro_banc,i_no_giro,i_folio,"")
        returning o_codret;
   if o_codret != "000" then
      return o_codret,o_no_giro,o_comision,o_iva,o_total_com,
             o_stts,o_fechahorapago;
   end if
   -- Crea el Documento en el Maestro
   insert into st_maetrans
      values (i_empresa,v_cve_giro_banc,i_no_giro,i_sucursal,i_moneda,
              i_unidades_divisa,i_usuario,
              i_fecha_horaexp,i_banco_dest,i_pais_dest,i_estado_dest,
              i_ciudad_dest," ",
              " ",0,0,0,0," ",0,i_monto_mn,i_beneficiario," "," "," "," ",
              i_nombre_comprador,i_telsolic,i_domsolic,i_mto_efec,
              i_mto_efec_c_div,
              i_mto_efec_c_val,i_cta_cgo_abono,i_mto_cgo_abono,
              i_tipo_comision,o_comision,
              i_porc_cob_com,0,o_total_com1,v_cve_en_transito,"");
   -- Indica Status y Valores de Retorno
   let o_stts = "GIRO VIGENTE";
   let o_fechahorapago = i_fecha_horaexp;
   return o_codret,o_no_giro,o_comision,o_iva,
          o_total_com,o_stts,o_fechahorapago;
end if

-- ***************************************************************************
if i_tipmov = "PAGO" then
   -- Valida que Exista el Documento
   select rowid,moneda,unidades_divisa,monto,beneficiario,
          status_docto,mto_efec_abono,mto_efec_a_div,
          mto_efec_a_val,num_abono_cta,mto_abono_cta
      into v_rowid,v_moneda,v_unid_divisa,v_monto,v_beneficiario,
           v_status_docto,v_mto_efec_abono,v_mto_efec_a_div,
           v_mto_efec_a_val,v_num_abono_cta,v_mto_abono_cta
      from st_maetrans
      where empresa = i_empresa and tipo_docto = i_tipo_docto and
            num_docto = i_no_giro;
   if v_rowid is null then
      let o_codret = "019";
      return o_codret,o_no_giro,o_comision,o_iva,o_total_com,
             o_stts,o_fechahorapago;
   end if
   -- Valida el Status del Documento
   if v_status_docto = v_cve_liquidado then
      let o_stts = "GIRO LIQUIDADO";
      let o_codret = "021";
      return o_codret,o_no_giro,o_comision,o_iva,o_total_com,
             o_stts,o_fechahorapago;
   elif v_status_docto = v_cve_prevenido then
      let o_stts = "GIRO PREVENIDO";
      let o_codret = "022";
      return o_codret,o_no_giro,o_comision,o_iva,o_total_com,
             o_stts,o_fechahorapago;
   elif  v_status_docto = v_cve_cancelado then
      let o_stts = "GIRO CANCELADO";
      let o_codret = "023";
      return o_codret,o_no_giro,o_comision,o_iva,o_total_com,
             o_stts,o_fechahorapago;
   elif  v_status_docto = v_cve_liq_cam then
      let o_stts = "GIRO LIQ POR CAMARA";
      let o_codret = "024";
      return o_codret,o_no_giro,o_comision,o_iva,o_total_com,
             o_stts,o_fechahorapago;
   end if
   -- Verifica si la moneda corresponde
   if i_moneda != v_moneda then
      let o_codret = "045";
      return o_codret,o_no_giro,o_comision,o_iva,o_total_com,
             o_stts,o_fechahorapago;
   end if
   -- Si es moneda extranjera calcula  Valor en M.N.
   if v_moneda != v_codigo_mn then
      if i_unidades_divisa = 0 or
         i_unidades_divisa is null or
         i_unidades_divisa = " " then
         let o_codret = "034";
         return o_codret,o_no_giro,o_comision,o_iva,o_total_com,
                o_stts,o_fechahorapago;
      end if
      if i_unidades_divisa != v_unid_divisa then
         let o_codret = "057";
         return o_codret,o_no_giro,o_comision,o_iva,o_total_com,
                o_stts,o_fechahorapago;
      end if
      -- Obtiene Precio de compra para llevar a cabo la Valorizacion
      select precio_compra into v_preco
         from bdinteg:si_tpcambio
         where empresa = i_empresa and divisa = i_moneda and
               clase_tpcambio = "B";
      if v_preco is null then
         let v_preco = 1;
      end if
      let i_monto_mn = i_unidades_divisa * v_preco;
   else
      if i_monto_mn != v_monto then
         let o_codret = "057";
         return o_codret,o_no_giro,o_comision,o_iva,o_total_com,
                o_stts,o_fechahorapago;
      end if
   end if
   -- Crea Movimiento Diario
   call stmovdia(i_empresa,v_plaza,i_sucursal,i_usuario,
                 i_fecha_horaexp,v_cve_liquidado,i_moneda,
                 v_cve_giro_banc,i_no_giro,i_folio,"")
        returning o_codret;
   if o_codret != "000" then
      return o_codret,o_no_giro,o_comision,o_iva,o_total_com,
             o_stts,o_fechahorapago;
   end if
   -- Actualiza el Documento en el Maestro como Liquidado
   update st_maetrans
      set (sucursal_pagadora,cajero_paga,mto_pagado_mn,mto_efec_abono,
           mto_efec_a_div,mto_efec_a_val,num_abono_cta,mto_abono_cta,
           status_docto,fecha_hora_pago)
        = (i_sucursal,i_usuario,i_monto_mn,i_mto_efec,i_mto_efec_c_div,
           i_mto_efec_c_val,i_cta_cgo_abono,i_mto_cgo_abono,v_cve_liquidado,
           i_fecha_horaexp)
      where rowid = v_rowid;
   -- Indica Status y Valores de Retorno
   let o_stts          = "GIRO LIQUIDADO";
   let o_no_giro       = i_no_giro;
   let o_fechahorapago = i_fecha_horaexp;
   return o_codret,o_no_giro,o_comision,o_iva,o_total_com,
          o_stts,o_fechahorapago;
end if

-- ***************************************************************************
if i_tipmov = "CANC" then
   -- Valida que Exista el Documento
   select rowid,moneda,unidades_divisa,monto,beneficiario,
          status_docto,mto_efec_abono,mto_efec_a_div,
          mto_efec_a_val,num_abono_cta,mto_abono_cta
      into v_rowid,v_moneda,v_unid_divisa,v_monto,v_beneficiario,
           v_status_docto,v_mto_efec_abono,v_mto_efec_a_div,
           v_mto_efec_a_val,v_num_abono_cta,v_mto_abono_cta
      from st_maetrans
      where empresa = i_empresa and tipo_docto = i_tipo_docto and
            num_docto = i_no_giro;
   if v_rowid is null then
      let o_codret = "019";
      return o_codret,o_no_giro,o_comision,o_iva,o_total_com,
             o_stts,o_fechahorapago;
   end if
   -- Valida el Status del Documento
   if v_status_docto = v_cve_liquidado then
      let o_stts = "GIRO LIQUIDADO";
      let o_codret = "021";
      return o_codret,o_no_giro,o_comision,o_iva,o_total_com,
             o_stts,o_fechahorapago;
   elif v_status_docto = v_cve_prevenido then
      let o_stts = "GIRO PREVENIDO";
      let o_codret = "022";
      return o_codret,o_no_giro,o_comision,o_iva,o_total_com,
             o_stts,o_fechahorapago;
   elif  v_status_docto = v_cve_cancelado then
      let o_stts = "GIRO CANCELADO";
      let o_codret = "023";
      return o_codret,o_no_giro,o_comision,o_iva,o_total_com,
             o_stts,o_fechahorapago;
   elif  v_status_docto = v_cve_liq_cam then
      let o_stts = "GIRO LIQ POR CAMARA";
      let o_codret = "024";
      return o_codret,o_no_giro,o_comision,o_iva,o_total_com,
             o_stts,o_fechahorapago;
   end if
   -- Verifica si la moneda corresponde
   if i_moneda != v_moneda then
      let o_codret = "045";
      return o_codret,o_no_giro,o_comision,o_iva,o_total_com,
             o_stts,o_fechahorapago;
   end if
   -- Verifica si corresponde el Monto
   if v_moneda != v_codigo_mn then
      -- Obtiene Precio de compra para llevar a cabo la Valorizacion
      select precio_compra into v_preco
         from bdinteg:si_tpcambio
         where empresa = i_ewmpresa and divisa = i_moneda and
               clase_tpcambio = "B";
      if v_preco is null then
         let o_codret = "105";
         return o_codret,o_no_giro,o_comision,o_iva,o_total_com,
                o_stts,o_fechahorapago;
      end if
      let i_monto_mn = i_unidades_divisa * v_preco;
   end if
   -- Crea Movimiento Diario
   call stmovdia(i_empresa,v_plaza,i_sucursal,i_usuario,
                 i_fecha_horaexp,v_cve_cancelado,i_moneda,
                 v_cve_giro_banc,i_no_giro,i_folio,"")
        returning o_codret;
   if o_codret != "000" then
      return o_codret,o_no_giro,o_comision,o_iva,o_total_com,
             o_stts,o_fechahorapago;
   end if
   -- Actualiza el Documento en el Maestro como Cancelado
   update st_maetrans
      set (sucursal_pagadora,cajero_paga,mto_pagado_mn,mto_efec_abono,
           mto_efec_a_div,mto_efec_a_val,num_abono_cta,mto_abono_cta,
           status_docto,fecha_hora_pago)
        = (i_sucursal,i_usuario,i_monto_mn,i_mto_efec,i_mto_efec_c_div,
           i_mto_efec_c_val,i_cta_cgo_abono,i_mto_cgo_abono,v_cve_cancelado,
           i_fecha_horaexp)
      where rowid = v_rowid;
   -- Indica Status y Valores de Retorno
   let o_stts          = "GIRO CANCELADO";
   let o_no_giro       = i_no_giro;
   let o_fechahorapago = i_fecha_horaexp;
   return o_codret,o_no_giro,o_comision,o_iva,o_total_com,
          o_stts,o_fechahorapago;
end if

-- ************************************************************************
-- Pago de Giros por Camara
if i_tipmov = "CMRA" then
   -- Valida que Exista el Documento
   select rowid,moneda,unidades_divisa,monto,beneficiario,
          status_docto,mto_efec_abono,mto_efec_a_div,
          mto_efec_a_val,num_abono_cta,mto_abono_cta
   into   v_rowid,v_moneda,v_unid_divisa,v_monto,v_beneficiario,
          v_status_docto,v_mto_efec_abono,v_mto_efec_a_div,
          v_mto_efec_a_val,v_num_abono_cta,v_mto_abono_cta
   from  st_maetrans
   where empresa = i_empresa and tipo_docto = i_tipo_docto and
         num_docto = i_no_giro;
   if v_rowid is null then
      let o_codret = "019";
      return o_codret,o_no_giro,o_comision,o_iva,o_total_com,o_stts,
             o_fechahorapago;
   end if
   -- Valida el Status del Documento
   if v_status_docto = v_cve_liquidado then
      let o_stts = "GIRO LIQUIDADO";
      let o_codret = "021";
      return o_codret,o_no_giro,o_comision,o_iva,o_total_com,o_stts,
             o_fechahorapago;
   elif v_status_docto = v_cve_prevenido then
      let o_stts = "GIRO PREVENIDO";
      let o_codret = "022";
      return o_codret,o_no_giro,o_comision,o_iva,o_total_com,o_stts,
             o_fechahorapago;
   elif  v_status_docto = v_cve_cancelado then
      let o_stts = "GIRO CANCELADO";
      let o_codret = "023";
      return o_codret,o_no_giro,o_comision,o_iva,o_total_com,o_stts,
             o_fechahorapago;
   elif  v_status_docto = v_cve_liq_cam then
      let o_stts = "GIRO LIQ POR CAMARA";
      let o_codret = "024";
      return o_codret,o_no_giro,o_comision,o_iva,o_total_com,o_stts,
             o_fechahorapago;
   end if
   if i_unidades_divisa != v_unid_divisa or
      i_monto_mn != v_monto then
      let o_stts = "GIRO VIGENTE";
      let o_codret = "020";
      return o_codret,o_no_giro,o_comision,o_iva,o_total_com,o_stts,
             o_fechahorapago;
   end if
   -- Verifica si la moneda corresponde
   if i_moneda != v_moneda then
      let o_codret = "045";
      return o_codret,o_no_giro,o_comision,o_iva,o_total_com,
             o_stts,o_fechahorapago;
   end if
   -- Si es moneda extranjera calcula  Valor en M.N.
   if v_moneda != v_codigo_mn then
      if i_unidades_divisa = 0 or
         i_unidades_divisa is null or
         i_unidades_divisa = " " then
         let o_codret = "034";
         return o_codret,o_no_giro,o_comision,o_iva,o_total_com,o_stts,
                o_fechahorapago;
      end if
      -- Obtiene Precio de compra para llevar a cabo la Valorizacion
      select precio_compra into v_preco
         from bdinteg:si_tpcambio
         where empresa = i_empresa and divisa = i_moneda and
               clase_tpcambio = "B";
      if v_preco is null then
         let o_codret = "105";
         return o_codret,o_no_giro,o_comision,o_iva,o_total_com,o_stts,
                o_fechahorapago;
      end if
      let i_monto_mn = i_unidades_divisa * v_preco;
   end if
   -- Crea Movimiento Diario
   call stmovdia(i_empresa,v_plaza,i_sucursal,i_usuario,
                 i_fecha_horaexp,v_cve_liq_cam,i_moneda,
                 v_cve_giro_banc,i_no_giro,i_folio,"")
        returning o_codret;
   if o_codret != "000" then
      return o_codret,o_no_giro,o_comision,o_iva,o_total_com,
             o_stts,o_fechahorapago;
   end if
   -- Actualiza el Documento en el Maestro como Liquidado por Camara
   update st_maetrans
      set (sucursal_pagadora,cajero_paga,mto_pagado_mn,mto_efec_abono,
           mto_efec_a_div,mto_efec_a_val,num_abono_cta,mto_abono_cta,
           status_docto,fecha_hora_pago)
        = (i_sucursal,i_usuario,i_monto_mn,i_mto_efec,i_mto_efec_c_div,
           i_mto_efec_c_val,i_cta_cgo_abono,i_mto_cgo_abono,v_cve_liq_cam,
           i_fecha_horaexp)
      where rowid = v_rowid;
   -- Indica Status y Valores de Retorno
   let o_stts          = "GIRO LIQ POR CAMARA";
   let o_no_giro       = i_no_giro;
   let o_fechahorapago = i_fecha_horaexp;
   return o_codret,o_no_giro,o_comision,o_iva,o_total_com,o_stts,
          o_fechahorapago;
end if
end;       --fin del on exception
end procedure;
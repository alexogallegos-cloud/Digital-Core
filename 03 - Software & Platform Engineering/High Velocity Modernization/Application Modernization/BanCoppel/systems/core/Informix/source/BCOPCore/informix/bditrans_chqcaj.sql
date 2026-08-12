create procedure "informix".chqcaj(i_empresa     char(3),
                              i_tipmov           char(4),
			      i_tipo_docto       char(2),
			      i_usuario          char(8),
			      i_fecha_horaexp    datetime year to second,
			      i_folio            char(16),
			      i_plaza            char(3),
			      i_sucursal         char(3),
			      i_cve_aut          char(8),
			      i_no_cheque        char(10),
			      i_moneda           char(2),
			      i_unidades_divisa  money(14,2),
			      i_monto_mn         money(14,2),
			      i_mto_efec         money(14,2),
			      i_mto_efec_c_div   money(14,2),
			      i_mto_efec_c_val   money(14,2),
			      i_cta_cgo_abono    char(20),
			      i_mto_cgo_abono    money(14,2),
			      i_tipo_comision    char(1),
			      i_importe_comis    money(14,2),
			      i_porc_cob_com     decimal(8,5),
			      i_beneficiario     char(40),
			      i_nombre_comprador char(40),
			      i_telsolic         char(10),
			      i_domsolic         char(70))

   returning money(14,2),money(14,2),money(14,2),char(28),
	     datetime year to second,char(5),char(10);
-- ##########################################################################
-- DEFINE VARIABLES DE TRABAJO;
-- ##########################################################################
   define v_existe           smallint;
   define v_rowid            integer;
   define v_fecha_hoy        date;
   define v_moneda           char(2);
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
   define v_nomeje           char(45);
   define v_plaza            char(3);
   define v_iva              decimal(5,2);
   define v_clave            char(8);
   define v_calculo_impuesto char(1);
   define v_valida_cve_autor char(1);
   define v_preve            money(12,7);
   define v_preco            money(12,7);
   define v_cve_c_caja       char(2);
   define v_com_c_caja       money(14,2);
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
   define v_num_automatico   char(1);
   define v_fecha            datetime year to day;
   define v_fecha_hora       char(19);
   define v_num_act_suc      integer;
   define i                  smallint;
   define v_codigo_mn        char(2);
   define v_usuario          char(8);
-- Variables de salida
   define o_comision         money(14,2);
   define o_iva              money(14,2);
   define o_total_com        money(14,2);
   define o_stts             char(28);
   define o_no_cheque        char(10);
   define o_fecha    	     datetime year to second;
   define o_codret           char(5);
   define codret             char(5);
   define tranret            char(4);
   define sql_err,isam_err  integer;


-- ###########################################################################
-- INICIALIZA VARIABLES
-- ###########################################################################
   let o_codret        = "000";
   let o_comision      = 0;
   let o_iva           = 0;
   let o_total_com     = 0;
   let o_stts          = " ";
   let o_no_cheque     = " ";
   let o_fecha = i_fecha_horaexp;
   begin
      on exception set sql_err,isam_err
         if sql_err <> 0 or isam_err <> 0 then
            let o_codret = sql_err;
            return o_comision,o_iva,o_total_com,o_stts,o_fecha,
	           o_codret,o_no_cheque;
         end if;
      end exception;

   select ejecutivo into v_usuario
      from bdinteg:si_ejecut
      where empresa = i_empresa and ejecutivo = i_usuario;
   if v_usuario <> i_usuario or v_usuario is null then
      let o_codret = "002";
      return o_comision,o_iva,o_total_com,o_stts,o_fecha,o_codret,o_no_cheque;
   end if

-- ############################################################################
-- RUTINA PRINCIPAL DEL PROGRAMA
-- ############################################################################
   select valor into v_codigo_mn
      from bdinteg:si_param
      where empresa = i_empresa
      and   cod_param = 15;
   if v_codigo_mn is null then
      let o_codret = "115";
      return o_comision,o_iva,o_total_com,o_stts,o_fecha,o_codret,o_no_cheque;
   end if
   select fecha_hoy into v_fecha_hoy
      from bdinteg:si_fechas
      where empresa = i_empresa;
   if v_fecha_hoy is null then
      let o_codret = "001";
      return o_comision,o_iva,o_total_com,o_stts,o_fecha,o_codret,o_no_cheque;
   end if
   if i_fecha_horaexp is null or i_fecha_horaexp = " " then
      let v_fecha         = v_fecha_hoy;
      let v_fecha_hora    = v_fecha || " " || current hour to second;
      let i_fecha_horaexp = v_fecha_hora;
      let o_fecha = i_fecha_horaexp;
   end if
   select ejecutivo,nombre,sucursal
      into v_clave_cajero,v_nomeje,v_sucursal
      from bdinteg:si_ejecut
      where empresa = i_empresa and ejecutivo = i_usuario;
   if v_clave_cajero is null then
      let o_codret = "002";
      return o_comision,o_iva,o_total_com,o_stts,o_fecha,o_codret,o_no_cheque;
   end if
   select plaza,iva into v_plaza,v_iva
      from bdinteg:si_sucursales
      where empresa = i_empresa and sucursal = i_sucursal;
   if v_plaza is null then
      let o_codret = "003";
      return o_comision,o_iva,o_total_com,o_stts,o_fecha,o_codret,o_no_cheque;
   end if
   if v_iva is null then
      let o_codret = "004";
      return o_comision,o_iva,o_total_com,o_stts,o_fecha,o_codret,o_no_cheque;
   end if
   -- Extrae parametros de Transferencias
   select cve_chq_caja,com_chq_caja,cve_en_transito,cve_liquidado,
          cve_prevenido,cve_desbloqueo,cve_cancelado,tran_venta_chq_caj,
          tran_canc_chq_caj,tran_liq_chq_caj,num_autom_chq_caj,
	  cve_liq_cam
      into v_cve_c_caja,v_com_c_caja,v_cve_en_transito,v_cve_liquidado,
           v_cve_prevenido,v_cve_desbloqueo,v_cve_cancelado,v_tran_venta,
           v_tran_canc,v_tran_liq,v_num_automatico,v_cve_liq_cam
      from bditrans:st_param
      where empresa = i_empresa;
   if v_cve_c_caja is null then
      let o_codret = "005";
      return o_comision,o_iva,o_total_com,o_stts,o_fecha,o_codret,o_no_cheque;
   end if
   -- Extrae Comisiones generales
   if i_moneda = v_codigo_mn then
      select comision_fija_mn,monto_minimo_mn,monto_maximo_mn,factor_millar_mn
         into v_com_fija,v_mto_min,v_mto_max,v_factor
         from bditrans:st_paramplaza
         where empresa = i_empresa and cod_plaza  = v_plaza and
               tipo_docto = v_cve_c_caja;
      if v_com_fija is null then
         let o_codret = "006";
         return o_comision,o_iva,o_total_com,o_stts,o_fecha,
                o_codret,o_no_cheque;
      end if
      if v_com_fija > 0 then
         let v_com_c_caja = v_com_fija;
      else
         let v_com_c_caja = 0;
      end if
   else
      select comision_fija_od,monto_minimo_od,monto_maximo_od,factor_millar_od
         into v_com_fija,v_mto_min,v_mto_max,v_factor
         from bditrans:st_paramplaza
         where empresa = i_empresa and cod_plaza  = v_plaza and
               tipo_docto = v_cve_c_caja;
      if v_com_fija is null then
         let o_codret = "006";
         return o_comision,o_iva,o_total_com,o_stts,o_fecha,
                o_codret,o_no_cheque;
      end if
      if v_com_fija > 0 then
         let v_com_c_caja = v_com_fija;
      else
         let v_com_c_caja = 0;
      end if
   end if

-- **************************************************************************
if i_tipmov = "ALTA" then
   -- Valida si el numero de cheque debera ser asignado Automaticamente
   if v_num_automatico = "N" then
      if i_no_cheque is null or i_no_cheque = " " then
         let o_codret = "112";  -- Debe Recibirse el No. de Cheque
         return o_comision,o_iva,o_total_com,o_stts,o_fecha,o_codret,
                o_no_cheque;
      else
	 -- Verifica que NO exista aun.
         select count(*) into v_existe
            from bditrans:st_maetrans
            where empresa = i_empresa and num_docto = i_no_cheque and
                  tipo_docto = v_cve_c_caja;
         if v_existe > 0  then
            let o_codret = "007";
            return o_comision,o_iva,o_total_com,o_stts,o_fecha,
                   o_codret,o_no_cheque;
         end if
      end if
   else
      let i_no_cheque = " "; -- Blanqueo para Asignacion Automatica de Numero
   end if
   -- Valida si es Moneda Nacional para inicializar las unidades de divisa
   if i_moneda = v_codigo_mn then
      let i_unidades_divisa = 0;
      let v_preve           = 1;
   else
      -- Si es moneda extranjera calcula tipo de cambio
      if i_unidades_divisa = 0 or i_unidades_divisa is null or
	 i_unidades_divisa = " " then
	 let o_codret = "034";
	 return o_comision,o_iva,o_total_com,o_stts,o_fecha,
                o_codret,o_no_cheque;
      end if
      select precio_venta into v_preve
         from bdinteg:si_tpcambio
         where empresa = i_empresa and divisa = i_moneda and
               clase_tpcambio = "B";
         if v_preve is null then
	    let o_codret = "115";
	    return o_comision,o_iva,o_total_com,o_stts,o_fecha,
                   o_codret,o_no_cheque;
         end if
      -- eliminar la sig linea  cuando se decida que Central debe Valorizar
      let v_preve = 1;
      let i_monto_mn = i_unidades_divisa * v_preve;
   end if
   -- Asigna Comision e IVA
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
   -- Recalcula el Monto de la Comision,si esta es ESPECIAL
   if i_porc_cob_com is not null then
      let i_tipo_comision = "2";
      let o_comision = o_comision * (i_porc_cob_com / 100);
   end if
   let o_iva = (o_comision) * v_iva;
   -- Obtiene el Numero del Documento que se esta vendiendo
   if i_no_cheque is null or i_no_cheque = " " then
      call stnumdocto(i_empresa,i_sucursal,i_tipo_docto)
  	   returning o_codret,v_num_act_suc,o_no_cheque;
      if o_codret != "000" then
         return o_comision,o_iva,o_total_com,o_stts,o_fecha,
                o_codret,o_no_cheque;
      end if
      let i_no_cheque = o_no_cheque;
   end if
   -- Determina el total de la Operacion
   let o_total_com = i_monto_mn;
   -- Crea Movimiento Diario
   call stmovdia(i_empresa,v_plaza,i_sucursal,i_usuario,
		 i_fecha_horaexp,v_cve_en_transito,i_moneda,
		 v_cve_c_caja,i_no_cheque,i_folio,"",i_monto_mn)
  	returning o_codret;
   if o_codret != "000" then
      return o_comision,o_iva,o_total_com,o_stts,o_fecha,o_codret,o_no_cheque;
   end if
   -- Da de Alta el Cheque de Caja
   if i_cta_cgo_abono is null then
      let i_cta_cgo_abono = " ";
   end if
   insert into bditrans:st_maetrans
      values (i_empresa,v_cve_c_caja,i_no_cheque,i_sucursal,
              i_moneda,i_unidades_divisa,i_usuario,
	      i_fecha_horaexp," "," "," "," "," "," ",
              0,0,0,0," ",0,i_monto_mn,i_beneficiario," "," ",
              " "," ",i_nombre_comprador,i_telsolic,i_domsolic,
	      i_mto_efec,i_mto_efec_c_div,i_mto_efec_c_val,i_cta_cgo_abono,
	      i_mto_cgo_abono,i_tipo_comision,o_comision,i_porc_cob_com,
              0,o_total_com, v_cve_en_transito," "," "," ");
   -- Indica Status y Valores de Retorno
   let o_stts = "CHEQUE VIGENTE";
   return o_comision,o_iva,o_total_com,o_stts,o_fecha,o_codret,o_no_cheque;
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
      from bditrans:st_maetrans
      where empresa = i_empresa and tipo_docto = i_tipo_docto and
	    num_docto  = i_no_cheque;
   if v_rowid is null then
      let o_codret = "019";
      return o_comision,o_iva,o_total_com,o_stts,o_fecha,
             o_codret,o_no_cheque;
   end if
   if i_moneda != v_moneda then
      let o_codret = "045";
      return o_comision,o_iva,o_total_com,o_stts,o_fecha,
             o_codret,o_no_cheque;
   end if;

   -- Valida Status del Documento
   if  v_status_docto = v_cve_liquidado then
      let o_stts = "CHEQUE LIQUIDADO";
      let o_codret = "021";
      return o_comision,o_iva,o_total_com,o_stts,o_fecha,o_codret,o_no_cheque;
   elif  v_status_docto = v_cve_prevenido then
      let o_stts = "CHEQUE PREVENIDO";
      let o_codret = "022";
      return o_comision,o_iva,o_total_com,o_stts,o_fecha,o_codret,o_no_cheque;
   elif  v_status_docto = v_cve_cancelado then
      let o_stts = "CHEQUE CANCELADO";
      let o_codret = "023";
      return o_comision,o_iva,o_total_com,o_stts,o_fecha,o_codret,o_no_cheque;
   elif  v_status_docto = v_cve_liq_cam then
      let o_stts = "CHQ LIQ POR CAMARA";
      let o_codret = "024";
      return o_comision,o_iva,o_total_com,o_stts,o_fecha,o_codret,o_no_cheque;
   end if
   --  Valida si es Moneda Nacional para inicializar las unidades de divisa
   if i_moneda != v_codigo_mn then
      -- Si es moneda extranjera calcula Monto en M.N.
      if i_unidades_divisa = 0 or i_unidades_divisa is null or
         i_unidades_divisa = " " then
	 let o_codret = "034";
	 return o_comision,o_iva,o_total_com,o_stts,o_fecha,
                o_codret,o_no_cheque;
      end if
      if i_unidades_divisa != v_unid_divisa then
         let o_codret = "057";
         return o_comision,o_iva,o_total_com,o_stts,o_fecha,
                o_codret,o_no_cheque;
      end if
      -- Obtiene Precio de compra para llevar a cabo la Valorizacion
      select precio_compra into v_preco
         from bdinteg:si_tpcambio
         where empresa = i_empresa and divisa = i_moneda and
               clase_tpcambio = "B";
      if v_preco is null then
	 let o_codret = "105";
	 return o_comision,o_iva,o_total_com,o_stts,o_fecha,
                o_codret,o_no_cheque;
      end if
   -- let i_monto_mn = i_unidades_divisa * v_preve;
      let i_monto_mn = i_unidades_divisa;  -- 14/Dic/95
   else
      if i_monto_mn != v_monto then
         let o_codret = "057";
         return o_comision,o_iva,o_total_com,o_stts,o_fecha,
                o_codret,o_no_cheque;
      end if
   end if
   -- Inserta en Movimiento Diario
   call stmovdia(i_empresa,v_plaza,i_sucursal,i_usuario,
	 	 i_fecha_horaexp,v_cve_liquidado,i_moneda,
	  	 v_cve_c_caja,i_no_cheque,i_folio,"",i_monto_mn)
  	returning o_codret;
   if o_codret != "000" then
      return o_comision,o_iva,o_total_com,o_stts,o_fecha,o_codret,o_no_cheque;
   end if
   -- Actualiza el Documento en el Maestro como Liquidado
   update bditrans:st_maetrans
      set (sucursal_pagadora,cajero_paga,mto_pagado_mn,
           status_docto,fecha_hora_pago)
	= (i_sucursal,i_usuario,i_monto_mn,v_cve_liquidado,i_fecha_horaexp)
      where rowid = v_rowid;
   -- Indica Status y Valores de Retorno
   let o_no_cheque     = i_no_cheque;
   let o_stts          = "CHEQUE LIQUIDADO";
   return o_comision,o_iva,o_total_com,o_stts,o_fecha,o_codret,o_no_cheque;
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
      from bditrans:st_maetrans
      where empresa = i_empresa and tipo_docto = i_tipo_docto and
	    num_docto  = i_no_cheque;
   if v_rowid is null then
      let o_codret = "019";
      return o_comision,o_iva,o_total_com,o_stts,o_fecha,o_codret,o_no_cheque;
   end if
   if i_moneda != v_moneda then
      let o_codret = "045";
      return o_comision,o_iva,o_total_com,o_stts,o_fecha,o_codret,o_no_cheque;
   end if;
   -- Valida Status del Documento
   if  v_status_docto = v_cve_liquidado then
      let o_stts = "CHEQUE LIQUIDADO";
      let o_codret = "021";
      return o_comision,o_iva,o_total_com,o_stts,o_fecha,o_codret,o_no_cheque;
   elif  v_status_docto = v_cve_prevenido then
      let o_stts = "CHEQUE PREVENIDO";
      let o_codret = "022";
      return o_comision,o_iva,o_total_com,o_stts,o_fecha,o_codret,o_no_cheque;
   elif  v_status_docto = v_cve_cancelado then
      let o_stts = "CHEQUE CANCELADO";
      let o_codret = "023";
      return o_comision,o_iva,o_total_com,o_stts,o_fecha,o_codret,o_no_cheque;
   elif  v_status_docto = v_cve_liq_cam then
      let o_stts = "CHQ LIQ POR CAMARA";
      let o_codret = "024";
      return o_comision,o_iva,o_total_com,o_stts,o_fecha,o_codret,o_no_cheque;
   end if
   --  Valida si es Moneda Nacional para inicializar las unidades de divisa
   if i_moneda != v_codigo_mn then
      -- Obtiene Precio de compra para llevar a cabo la Valorizacion
      select precio_compra into v_preco
         from bdinteg:si_tpcambio
         where empresa = i_empresa and divisa = i_moneda and
               clase_tpcambio = "B";
      if v_preco is null then
	 let o_codret = "105";
	 return o_comision,o_iva,o_total_com,o_stts,o_fecha,
                o_codret,o_no_cheque;
      end if
   -- let i_monto_mn = i_unidades_divisa * v_preve;
      let i_monto_mn = i_unidades_divisa;  -- 14/Dic/95
   end if
   -- Inserta en Movimiento Diario
   call stmovdia(i_empresa,v_plaza,i_sucursal,i_usuario,
		 i_fecha_horaexp,v_cve_cancelado,i_moneda,
		 v_cve_c_caja,i_no_cheque,i_folio,"",i_monto_mn)
  	returning o_codret;
   if o_codret != "000" then
      return o_comision,o_iva,o_total_com,o_stts,o_fecha,o_codret,o_no_cheque;
   end if
   -- Actualiza el Documento en el Maestro como Cancelado
   update bditrans:st_maetrans
      set (sucursal_pagadora,cajero_paga,mto_pagado_mn,
           status_docto,fecha_hora_pago)
	= (i_sucursal,i_usuario,i_monto_mn,v_cve_cancelado,i_fecha_horaexp)
      where rowid = v_rowid;
   -- Indica Status y Valores de Retorno
   let o_no_cheque     = i_no_cheque;
   let o_stts          = "CHEQUE CANCELADO";
   return o_comision,o_iva,o_total_com,o_stts,o_fecha,o_codret,o_no_cheque;
end if
-- ********************************************************************
-- Pago por Camara
-- ********************************************************************
if i_tipmov = "CMRA" then
   -- Valida que Exista el Documento
   select rowid,moneda,unidades_divisa,monto,beneficiario,
	  status_docto,mto_efec_abono,mto_efec_a_div,
	  mto_efec_a_val,num_abono_cta,mto_abono_cta
   into   v_rowid,v_moneda,v_unid_divisa,v_monto,v_beneficiario,
	  v_status_docto,v_mto_efec_abono,v_mto_efec_a_div,
	  v_mto_efec_a_val,v_num_abono_cta,v_mto_abono_cta
   from   bditrans:st_maetrans
   where empresa = i_empresa and tipo_docto = i_tipo_docto and
	  num_docto  = i_no_cheque;
   if v_rowid is null then
      let o_codret = "019";
      return o_comision,o_iva,o_total_com,o_stts,o_fecha,
	     o_codret,o_no_cheque;
   end if
   if i_moneda != v_moneda then
      let o_codret = "045";
      return o_comision,o_iva,o_total_com,o_stts,o_fecha,o_codret,o_no_cheque;
   end if;
   if i_unidades_divisa != v_unid_divisa or i_monto_mn != v_monto then
      let o_codret = "020";
      return o_comision,o_iva,o_total_com,o_stts,o_fecha,
	     o_codret,o_no_cheque;
   end if;

   -- Valida Status del Documento
   if  v_status_docto = v_cve_liquidado then
      let o_stts = "CHEQUE LIQUIDADO";
      let o_codret = "021";
      return o_comision,o_iva,o_total_com,o_stts,o_fecha,
	     o_codret,o_no_cheque;
   elif v_status_docto = v_cve_prevenido then
      let o_stts = "CHEQUE PREVENIDO";
      let o_codret = "022";
      return o_comision,o_iva,o_total_com,o_stts,o_fecha,
	     o_codret,o_no_cheque;
   elif v_status_docto = v_cve_cancelado then
      let o_stts = "CHEQUE CANCELADO";
      let o_codret = "023";
      return o_comision,o_iva,o_total_com,o_stts,o_fecha,
	     o_codret,o_no_cheque;
   elif v_status_docto = v_cve_liq_cam then
      let o_stts = "CHQ LIQ POR CAMARA";
      let o_codret = "024";
      return o_comision,o_iva,o_total_com,o_stts,o_fecha,
	     o_codret,o_no_cheque;
   end if

   --  Valida si es Moneda Nacional para inicializar las unidades de divisa
   if i_moneda != v_codigo_mn then
      -- Si es moneda extranjera calcula Monto en M.N.
      if i_unidades_divisa = 0 or i_unidades_divisa is null or
	 i_unidades_divisa = " " then
	 let o_codret = "034";
	 return o_comision,o_iva,o_total_com,o_stts,o_fecha,
		o_codret,o_no_cheque;
      end if
      -- Obtiene Precio de compra para llevar a cabo la Valorizacion
      select precio_compra into v_preco
         from bdinteg:si_tpcambio
         where empresa = i_empresa and divisa = i_moneda and
               clase_tpcambio = "B";
      if v_preco is null then
         let v_preco = 1;
      end if
   -- let i_monto_mn = i_unidades_divisa * v_preve;
      let i_monto_mn = i_unidades_divisa;  -- 14/Dic/95
   end if
   -- Inserta en Movimiento Diario
   call stmovdia(i_empresa,v_plaza,i_sucursal,i_usuario,
	  	 i_fecha_horaexp,v_cve_liq_cam,i_moneda,
		 v_cve_c_caja,i_no_cheque,i_folio,"",i_monto_mn)
  	 returning o_codret;
   if o_codret != "000" then
      return o_comision,o_iva,o_total_com,o_stts,o_fecha,o_codret,o_no_cheque;
   end if
   -- Actualiza el Documento en el Maestro como Liquidado por Camara
   update bditrans:st_maetrans
      set (sucursal_pagadora,cajero_paga,mto_pagado_mn,
           status_docto,fecha_hora_pago)
	= (i_sucursal,i_usuario,i_monto_mn,v_cve_liq_cam,i_fecha_horaexp)
      where rowid = v_rowid;
   -- Indica Status y Valores de Retorno
   let o_no_cheque     = i_no_cheque;
   let o_stts          = "CHQ LIQ POR CAMARA";
   return o_comision,o_iva,o_total_com,o_stts,o_fecha,
	  o_codret,o_no_cheque;
end if
end;     --fin del on exception
end procedure;
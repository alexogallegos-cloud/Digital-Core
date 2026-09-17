create procedure "informix".stmovdia(p_empresa   char(3),
                          p_plaza           char(3),
			  p_sucursal        char(3),
			  p_usuario         char(8),
			  p_fecha_horaexp   datetime year to second,
		          p_tipo_operacion  char,
			  p_moneda          char(2),
			  p_tipo_docto      char(2),
			  p_no_cheque       char(10),
			  p_folio	    char(16),
			  p_ctacheq         char(20),
                          p_monto           money(14,2))
   returning char(5);

   define v_cod_ret          char(5);
   define v_existe_prod      int;
   define v_num_transacc     char(4);
   define v_cve_en_transito  char;
   define v_cve_liquidado    char;
   define v_cve_prevenido    char;
   define v_cve_desbloqueo   char;
   define v_cve_cancelado    char;
   define v_cve_liq_cam      char;
   define v_producto           char(4);
   define v_plaza            char(3);
   define v_moneda           char(2);
   define v_tipo_docto       char(2);
   define v_tran_venta       char(4);
   define v_tran_com_vta     char(4);
   define v_tran_iva_com     char(4);
   define v_tran_otras_com   char(4);
   define v_tran_iva_otr_com char(4);
   define v_tran_pago        char(4);
   define v_tran_prev        char(4);
   define v_tran_prev_anul   char(4);
   define v_tran_cancel      char(4);
   define v_tran_pago_cam    char(4);
   define v_tran_abono_dev   char(4);
   define v_tran_cargo_dev   char(4);
   define v_producto_mn        char(2);
   define sql_err,isam_err  integer;
-- ****************************************************************************
-- Inicializa variables
-- ****************************************************************************

   let v_cod_ret   = "000";

   begin
      on exception set sql_err,isam_err
         if sql_err <> 0 or isam_err <> 0 then
            let v_cod_ret = sql_err;
            return v_cod_ret;
         end if;
      end exception;

-- ****************************************************************************
-- Obtiene y valida los Codigos Correspondientes
-- ****************************************************************************
   select valor into v_producto_mn
      from bdinteg:si_param
      where empresa = p_empresa and cod_param = 15;
   if p_moneda is null then
      let p_moneda = v_producto_mn;
   end if
   -- Extrae parametros de Transferencias
   select cve_en_transito,cve_liquidado,cve_prevenido,
	  cve_desbloqueo,cve_cancelado,cve_liq_cam
       into v_cve_en_transito,v_cve_liquidado,v_cve_prevenido,
	    v_cve_desbloqueo,v_cve_cancelado,v_cve_liq_cam
      from bditrans:st_param
      where empresa = p_empresa;

      select producto,moneda,tipo_docto,
             tran_venta,tran_com_vta,tran_iva_com,tran_otras_com,
             tran_iva_otr_com,tran_pago,tran_prev,tran_prev_anul,
	     tran_cancel,tran_pago_cam,tran_abono_dev,tran_cargo_dev
         into v_producto,v_moneda,v_tipo_docto,
              v_tran_venta,v_tran_com_vta,v_tran_iva_com,v_tran_otras_com,
              v_tran_iva_otr_com,v_tran_pago,v_tran_prev,v_tran_prev_anul,
	      v_tran_cancel,v_tran_pago_cam,v_tran_abono_dev,v_tran_cargo_dev
         from bditrans:st_producto
         where empresa        = p_empresa and
               moneda         = p_moneda and
               tipo_docto     = p_tipo_docto;
         if v_producto is null or v_producto = " " then
	    let v_cod_ret = "030";      -- No existe Producto
            return v_cod_ret;
         end if

   if p_tipo_operacion = v_cve_en_transito then
      let v_num_transacc = v_tran_venta;
   elif p_tipo_operacion = v_cve_liquidado then
      let v_num_transacc = v_tran_pago;
   elif p_tipo_operacion = v_cve_prevenido then
      let v_num_transacc = v_tran_prev;
   elif p_tipo_operacion = v_cve_desbloqueo then
      let v_num_transacc = v_tran_prev_anul;
   elif p_tipo_operacion = v_cve_cancelado then
      let v_num_transacc = v_tran_cancel;
   elif p_tipo_operacion = v_cve_liq_cam then
      let v_num_transacc = v_tran_pago_cam;
   elif p_tipo_operacion = "7" then
      let v_num_transacc = v_tran_cargo_dev;
   elif p_tipo_operacion = "8" then
      let v_num_transacc = v_tran_abono_dev;
   end if;

   if p_ctacheq = " " or p_ctacheq is null then
      select num_cargo_cta into p_ctacheq from st_maetrans
         where empresa = p_empresa and tipo_docto = p_tipo_docto
           and num_docto  = p_no_cheque;
   end if;

-- ****************************************************************************
-- Realiza la insercion a la tabla de Movimientos
-- ****************************************************************************

   insert into bditrans:st_movdia
      values (p_empresa,
              p_plaza,
	      p_sucursal,
	      p_usuario,
	      p_fecha_horaexp,
              v_num_transacc,
	      p_tipo_operacion,
	      p_moneda,
	      p_tipo_docto,
              p_no_cheque,
	      v_producto,
	      p_folio,
	      p_ctacheq,
              p_monto,
              "N");
end;     --fin del on exception
return v_cod_ret;
end procedure;
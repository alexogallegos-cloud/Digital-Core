create procedure "informix".cons_ordpag(i_empresa char(3),
                             i_no_pago char(10))
   returning char(5),char(40),char(20),char(20),money(14,2),
             date,date,char(40);

-- ###################################################################
-- DEFINE VARIABLES DE TRABAJO;
-- ###################################################################
   define o_moneda           char(20);
   define o_beneficiario     char(40);
   define o_monto            money(14,2);
   define v_unid_divisa      money(14,2);
   define v_num_docto        char(10);
   define v_status_docto     char(1);
   define o_sucursal         char(40);
   define o_cve_o_pago       char(2);
   define v_moneda           char(2);
   define o_fechalta         date;
   define o_fechcanc         date;
   define o_codret           char(5);
   define sql_err,isam_err  integer;
   define o_stts            char(20);
   define v_cve_o_pago,v_cve_en_transito,v_cve_liquidado,v_codigo_mn,
          v_cve_prevenido,v_cve_desbloqueo,v_cve_cancelado,
          v_cve_liq_cam char(2);


-- ###################################################################
-- INICIALIZA VARIABLES
-- ###################################################################
   let o_codret        = "000";
   let o_beneficiario  = " ";
   let o_moneda        = " ";
   let o_beneficiario  = " ";
   let o_monto         = 0;
   let v_moneda        = " ";
   let o_moneda        = " ";
   let v_status_docto  = " ";
   let o_sucursal      = " ";
   let o_fechalta      = " ";
   let o_fechcanc      = " ";
   let o_sucursal      = " ";
   Let o_stts          = " ";
   begin
      on exception set sql_err,isam_err
         if sql_err <> 0 or isam_err <> 0 then
            let o_codret = sql_err;
            return o_codret,o_beneficiario,o_stts,o_moneda,
               o_monto,o_fechalta,o_fechcanc,o_sucursal;
         end if;
      end exception;

   select valor into v_codigo_mn
      from bdinteg:si_param
      where empresa = i_empresa
      and   cod_param = 15;

   select cve_orden_pago,cve_en_transito,cve_liquidado,
	  cve_prevenido,cve_desbloqueo,cve_cancelado,cve_liq_cam
      into v_cve_o_pago,v_cve_en_transito,v_cve_liquidado,
	   v_cve_prevenido,v_cve_desbloqueo,v_cve_cancelado,v_cve_liq_cam
      from st_param
      where empresa = i_empresa;

   select moneda||" "||descripcion,unidades_divisa,monto,beneficiario,
          mt.sucursal||" "||nombre,moneda,
	  status_docto,date(fecha_hora_exp),date(fecha_hora_pago)
      into o_moneda,v_unid_divisa,o_monto,o_beneficiario,o_sucursal,
	   v_moneda,v_status_docto,o_fechalta,o_fechcanc
      from st_maetrans mt, bdinteg:si_sucursales su, bdinteg:si_divisas di
      where mt.empresa = i_empresa and tipo_docto = v_cve_o_pago and
	    num_docto  = i_no_pago and status_docto <> "S" and
            su.empresa = mt.empresa and su.sucursal = mt.sucursal and
            di.empresa = mt.empresa and di.divisa = mt.moneda;
   if o_moneda is null then
      let o_codret = "019";
      return o_codret,o_beneficiario,o_stts,o_moneda,
             o_monto,o_fechalta,o_fechcanc,o_sucursal;
   end if
   -- Valida el Status del Documento
   if v_status_docto = v_cve_liquidado then
      let o_stts = v_status_docto||" LIQUIDADA";
      elif v_status_docto = v_cve_prevenido then
           let o_stts = v_status_docto||" PREVENIDA";
           let o_codret = "022";
        elif v_status_docto = v_cve_cancelado then
             let o_stts = v_status_docto||" CANCELADA";
          elif v_status_docto = v_cve_en_transito then
               let o_stts = v_status_docto||" VIGENTE";
               let o_fechcanc = " ";
            elif v_status_docto = v_cve_liq_cam  then
                 let o_stts = v_status_docto||" LIQUIDADO POR CAMARA";
   end if
   -- Si es moneda extranjera calcula el Valor en M.N.
   if v_moneda != v_codigo_mn then
      let o_monto = v_unid_divisa;
   end if
   return o_codret,o_beneficiario,o_stts,o_moneda,
          o_monto,o_fechalta,o_fechcanc,o_sucursal;
end
End procedure;
create procedure "informix".cert_pag(i_empresa char(3),
                           i_sucursal     char(3),
			   i_usuario      char(8),
			   i_folio        char(16),
			   i_cuenta       char(20),
			   i_nodocto      int,
			   i_monto        money (14,2),
			   i_unidades_div money(14,2),
			   i_divisa       char(2),
			   i_ctaabono     char(10),
			   i_montoabono   money(14,2),
			   i_efect        money(14,2))
   returning char(5);

   define v_fecha_hoy       date;
   define v_iva             decimal(8,4);
   define v_fecha_hora_exp  datetime year to second;
   define v_t_cam           decimal(12,6);
   define v_cve_c_cert      char(2);
   define v_com_c_cert_mn   money (14,2);
   define v_com_c_cert_od   money(14,2);
   define v_cve_en_transito char(1);
   define v_cve_liquidado   char(1);
   define v_cve_prevenido   char(1);
   define v_cve_desbloqueo  char(1);
   define v_cve_cancelado   char(1);
   define v_tran_venta      char(4);
   define v_tran_canc       char(4);
   define v_tran_liq        char(4);
   define v_com_por_suc     char(1);
   define v_unidades_divisa money(14,2);

   define inoreg           smallint;
   define longitud         smallint;
   define v_plaza          char(3);

   define v_com_fija_mn,v_mto_min_mn,v_mto_max_mn money(14,2);
   define v_factor_mn      decimal(8,4);
   define v_com_fija_od,v_mto_min_od,v_mto_max_od money(14,2);
   define v_factor_od      decimal(8,4);

   define codret           char(5);
   define o_comision       money(14,2);
   define o_iva            money(14,2);
   define v_total          money(14,2);
   define v_monto_chq      money(14,2);

   define cta              char(20);
   define estatus          char(1);
   define mot              char(1);
   define pro              char(4);
   define sucur            char(3);
   define lin_cre,sad_ret,sad_con,sad_actual money(14,2);
   define v_colateral      char(1);
   define sdo_dis,v_sdo_fin money(14,2);
   define v_sdo_col,v_totcol money(14,2);
   define v_moneda         char(2);
   define acep_car         char(1);
   define v_row            int;
   define cuen             char(20);
   define num              int;
   define util             char(1);
   define i,j              int;
   define v_status         char(1);
   define v_fecha          datetime year to day;
   define v_fecha_hora     char(19);
   define v_codigo_mn      char(2);
   define sql_err,isam_err integer;
   define v_usuario        char(8);
   define v_tipodocto      CHAR(1);

   let codret = "000";
   let o_comision = 0;
   let o_iva = 0;

   begin
      on exception set sql_err,isam_err
         if sql_err <> 0 or isam_err <> 0 then
            let codret = sql_err;
            return codret;
         end if;
      end exception;

   select ejecutivo into v_usuario from bdinteg:si_ejecut
      where empresa = i_empresa and ejecutivo = i_usuario;
   if v_usuario <> i_usuario or v_usuario is null then
      let codret = "002";
      return codret;
   end if;

   select codigo_mn into v_codigo_mn
      from bdinteg:si_param
      where empresa = i_empresa;

   select cve_chq_cert,cve_en_transito,cve_liquidado,cve_prevenido,
          cve_desbloqueo,cve_cancelado,tran_venta_chq_cer,tran_canc_chq_cer,
          tran_liq_chq_cer,com_por_suc
      into v_cve_c_cert, v_cve_en_transito,v_cve_liquidado,v_cve_prevenido,
           v_cve_desbloqueo,v_cve_cancelado,v_tran_venta,v_tran_canc,
           v_tran_liq,v_com_por_suc
      from st_param
      where empresa = i_empresa;

   -- Valida el monto a pagar del cheque certificado
   select monto,unidades_divisa,moneda
      into v_monto_chq,v_unidades_divisa,v_moneda
      from st_maetrans
      where empresa       = i_empresa
            and tipo_docto    = v_cve_c_cert
            and num_docto     = i_nodocto
            and num_cargo_cta = i_cuenta
            AND status_docto    <> "2"; -- diferente de Liquidado

   if (i_divisa =  v_codigo_mn and v_monto_chq != i_monto) or
      (i_divisa != v_codigo_mn and v_unidades_divisa != i_unidades_div) then
      let codret = "700";
      return codret;
   end if

   if i_divisa <> v_moneda then
      let codret = "045";
      return codret;
   end if

   select fecha_hoy into v_fecha_hoy
      from bdinteg:si_fechas
      where empresa = i_empresa;

   let v_fecha          = v_fecha_hoy;
   let v_fecha_hora     = v_fecha || " " || current hour to second;
   let v_fecha_hora_exp = v_fecha_hora;

   select count(*) into inoreg
      from bdinteg:si_ejecut
      where empresa = i_empresa and ejecutivo = i_usuario
      and   sucursal  = i_sucursal;

   select plaza,iva into v_plaza,v_iva
      from bdinteg:si_sucursales
      where empresa = i_empresa and sucursal = i_sucursal;

if i_montoabono > 0 then
   select cuenta,status_cta,motivo,producto,sucursal,plaza,
          lim_sbg_ccc-imp_sbg_ccc,sdo_retenido,sdo_cong,sdo_actual,colateral
      into cta,estatus,mot,pro,sucur,v_plaza,lin_cre,sad_ret,sad_con,
           sad_actual,v_colateral
      from bdicheq:sc_maechq chq
      where empresa = i_empresa and chq.cuenta = i_cuenta;
   if cta is null then
      let cta = "0";
   end if;

   if i_cuenta != cta then
      let codret = "100";
      return codret;
   end if;

   select divisa into v_moneda from bdicheq:sc_producto
      where empresa = i_empresa and  producto = pro;

   if v_moneda != i_divisa then
	let codret="905";
	return codret;
   end if;

   if estatus = "2" then
      let codret = "200";
      return codret;
   elif estatus = "3" then
      select cargo into acep_car from bdicheq:sc_bloqueo
         where codigo = mot;
      if acep_car = "N" then
         let codret = "300";
         return codret;
      end if;
   end if;
end if

--Validar que el documento no haya sido pagado,ni suspendido
select rowid,cuenta,numero,estado
   into v_row,cuen,num,util
   from bdicheq:sc_contch
   where empresa = i_empresa and cuenta = i_cuenta and
         numero = i_nodocto;
if cuen is null and num is null then
   let cuen = "0";
   let num = "0";
end if;

if cuen = i_cuenta and num = i_nodocto then
   if util = "P" then
      let codret = "600";
      return codret;
   elif util = "S" then
      let codret = "700";
      return codret;
   end if;
   update bdicheq:sc_contch set (estado) = ("P")
      where rowid=v_row;
   let i = "000";
   if i_montoabono > 0 then
      call bdicheq:abono_ref(i_empresa,i_sucursal,i_usuario,
	   v_tran_liq,"0000",i_folio,i_ctaabono,i_nodocto,
	   i_montoabono,i_montoabono,0,0,0,i_divisa,"")
           returning i;
      if i <> "000" then
  	 let codret = i;
 	 return codret;
      else
 	 let codret = "000";
      end if
   end if
else
   select rowid,cuenta,numero,estado
      into v_row,cuen,num,util
      from bdicheq:sc_histch sc_hist
      where empresa = i_empresa and cuenta = i_cuenta and
	    numero = i_nodocto;

   if cuen is null and num is null then
      let cuen = "0";
      let num = "0";
   end if;

   if cuen = i_cuenta and num = i_nodocto then
      if util = "P" then
	 let codret = "600";
	 return codret;
      elif util = "S" then
  	   let codret = "700";
	   return codret;
      end if;
   else
      let i = "000";
      if i_montoabono > 0 then
         insert into bdicheq:sc_histch
            values(i_empresa,i_cuenta,i_nodocto,"P",v_fecha_hoy,i_montoabono);
	 call bdicheq:abono_ref(i_empresa,i_sucursal,i_usuario,
	      v_tran_liq,"0000",i_folio,i_ctaabono,i_nodocto,
  	      i_montoabono,i_montoabono,0,0,0,i_divisa,"")
              returning i;
	 if i <> "000" then
	    let codret = i;
   	    return codret;
         end if
      end if
   end if
end if

-- Actualiza los datos en la base de datos de TRANSFERENCIAS
let v_cve_c_cert = v_cve_c_cert;
let i_nodocto = i_nodocto;

select status_docto into v_status
   from st_maetrans
   where empresa       = i_empresa and
         tipo_docto    = v_cve_c_cert and
         num_docto     = i_nodocto and
         num_cargo_cta = i_cuenta;

if v_status =  v_cve_c_cert or v_status = v_cve_en_transito or
   v_status = v_cve_desbloqueo then
   -- Crea Movimiento Diario
      call stmovdia(i_empresa,v_plaza,i_sucursal,i_usuario,
            	    v_fecha_hora_exp,v_cve_liquidado,i_divisa,
		    v_cve_c_cert,i_nodocto,i_folio,i_cuenta,
                    i_montoabono)
  	   returning codret;
      if codret != "000" then
         return codret;
      end if
      update st_maetrans
         set (sucursal_pagadora,cajero_paga,mto_efec_abono,
	      mto_efec_a_div,mto_efec_a_val,num_abono_cta,
	      mto_abono_cta,status_docto,fecha_hora_pago)
	   = (i_sucursal,i_usuario,i_efect,
	      0,0,i_ctaabono,
	      i_montoabono,v_cve_liquidado,v_fecha_hora_exp)
         where empresa       = i_empresa and
               tipo_docto    = v_cve_c_cert and
               num_docto     = i_nodocto and
               num_cargo_cta = i_cuenta;
   else
      let codret = "900";
   end if
   return codret;
   end;     --fin del on exception
end procedure;
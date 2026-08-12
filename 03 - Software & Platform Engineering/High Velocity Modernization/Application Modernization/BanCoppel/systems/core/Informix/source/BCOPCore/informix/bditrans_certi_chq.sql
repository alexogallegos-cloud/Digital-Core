create procedure "informix".certi_chq(i_empresa char(3),
                           i_sucursal   char(3),
			   i_usuario    char(8),
			   i_folio      char(16),
			   i_cuenta     char(20),
			   i_nodocto    int,
			   i_monto      money (14,2),
			   i_unidades_div money(14,2),
			   i_divisa     char(2),
			   i_benefic    char(35))
       returning char(5),money(14,2),money(14,2);

-- Definicion de Variables
   define v_status_cta char(1);
   define v_fecha_hoy date;
   define v_iva decimal(8,4);
   define v_fecha_hora_exp datetime year to second;
   define v_t_cam decimal(12,6);
   define v_cve_c_cert char(2);
   define v_com_c_cert_mn money (14,2);
   define v_com_c_cert_od money(14,2);
   define v_cve_en_transito char(1);
   define v_cve_liquidado char(1);
   define v_cve_prevenido char(1);
   define v_cve_desbloqueo char(1);
   define v_cve_cancelado char(1);
   define v_tran_venta char(4);
   define v_tran_canc char(4);
   define v_tran_liq char(4);
   define v_com_por_suc char(1);
   define v_trancar char(4);
   define inoreg smallint;
   define v_plaza char(3);
   define v_com_fija_mn,v_mto_min_mn,v_mto_max_mn money(14,2);
   define v_factor_mn decimal(8,4);
   define v_com_fija_od,v_mto_min_od,v_mto_max_od money(14,2);
   define v_factor_od decimal(8,4);
   define codret char(5);
   define o_comision money(14,2);
   define o_iva money(14,2);
   define v_total money(14,2);
   define cta char(10);
   define estatus char(1);
   define mot char(1);
   define pro char(4);
   define sucur char(3);
   define lin_cre,sad_ret,sad_con,sad_actual money(14,2);
   define v_colateral char(1);
   define sdo_dis,v_sdo_fin money(14,2);
   define v_sdo_col,v_totcol money(14,2);
   define v_moneda char(2);
   define acep_car char(1);
   define v_row int;
   define cuen char(10);
   define num int;
   define util char(1);
   define i,j int;
   define v_fecha      datetime year to day;
   define v_fecha_hora char(19);
   define v_cuenta  char(10);
   define v_num_cte char(9);
   define v_ape_pa  char(12);
   define v_ape_ma  char(12);
   define v_nom1    char(12);
   define v_per     char(2);
   define v_rasoc   char(36);
   define v_domnum  char(35);
   define v_domcolo char (35);
   define v_telefono char(12);
   define v_nom_cliente char(35);
   define v_es_fisica char;
   define v_codigo_mn char(2);
   define v_mto_cargo money(14,2);
   define sql_err,isam_err integer;
   define v_usuario char(8);
   define vcodret char(5);
   define vtranret char(4);
   define vfecapli date;
   define vsdodisp money(14,2);
   define vmontoret money(14,2);


let codret = "000";
let o_comision = 0;
let o_iva = 0;

   begin
      on exception set sql_err,isam_err
         if sql_err <> 0 or isam_err <> 0 then
            let codret = sql_err;
            return codret,o_comision,o_iva;
         end if;
      end exception;

   select ejecutivo into v_usuario
      from bdinteg:si_ejecut
      where empresa = i_empresa and ejecutivo = i_usuario;
   if v_usuario <> i_usuario or v_usuario is null then
      let codret = "002";
      return codret,o_comision,o_iva;
   end if;

-- Validaciones y Calculos
   select codigo_mn into v_codigo_mn
      from bdinteg:si_param
      where empresa = i_empresa;

   select fecha_hoy into v_fecha_hoy
      from bdinteg:si_fechas
      where empresa = i_empresa;

   let v_fecha          = v_fecha_hoy;
   let v_fecha_hora     = v_fecha || " " || current hour to second;
   let v_fecha_hora_exp = v_fecha_hora;

   select count(*) into inoreg
      from bdinteg:si_ejecut
      where empresa = i_empresa and ejecutivo = i_usuario
            and sucursal  = i_sucursal;

   select plaza,iva into v_plaza,v_iva
      from bdinteg:si_sucursales
      where empresa = i_empresa and sucursal = i_sucursal;

   select cve_chq_cert,com_chq_cert,cve_en_transito,
	  cve_liquidado,cve_prevenido,cve_desbloqueo,
	  cve_cancelado,
	  tran_venta_chq_cer,tran_canc_chq_cer,tran_liq_chq_cer,
	  com_por_suc
      into v_cve_c_cert,v_com_c_cert_mn,v_cve_en_transito,
	  v_cve_liquidado,v_cve_prevenido,v_cve_desbloqueo,
	  v_cve_cancelado,
	  v_tran_venta,v_tran_canc,v_tran_liq,
	  v_com_por_suc
      from st_param
      where empresa = i_empresa;

      select comision_fija_mn,monto_minimo_mn,monto_maximo_mn,
	     factor_millar_mn,
	     comision_fija_od,monto_minimo_od,monto_maximo_od,
	     factor_millar_od
	 into v_com_fija_mn,v_mto_min_mn,v_mto_max_mn,v_factor_mn,
	      v_com_fija_od,v_mto_min_od,v_mto_max_od,v_factor_od
	 from st_paramplaza
	 where empresa    = i_empresa and
               cod_plaza  = v_plaza and
	       tipo_docto = v_cve_c_cert;

       if v_com_fija_mn is NULL then
	  let codret = "102";
	  return codret,o_comision,o_iva;
       end if

	 if v_com_fija_mn > 0 then
	    let v_com_c_cert_mn = v_com_fija_mn;
	 else
	    let v_com_c_cert_mn = 0;
	 end if
	 if v_com_fija_od > 0 then
	    let v_com_c_cert_od = v_com_fija_od;
	 else
	    let v_com_c_cert_od = 0;
	 end if

-- Revisa el estado del cheque
   select count(*) into inoreg from st_maetrans
      where empresa       = i_empresa and
            num_docto     = i_nodocto    and
	    tipo_docto    = v_cve_c_cert and
  	    num_cargo_cta = i_cuenta;

   if inoreg > 0  then
      let codret = "007";
      return codret,o_comision,o_iva;
   end if

   select status_cta into v_status_cta
     from bdicheq:sc_maechq
      where empresa = i_empresa and cuenta = i_cuenta;

   if v_status_cta is null then
     let codret = "100";
     return codret,o_comision,o_iva;
   end if

   if i_divisa = v_codigo_mn then
	 if v_com_c_cert_mn > 0 then
	      let o_comision =  v_com_c_cert_mn;
	 else
	      let o_comision = (i_monto * v_factor_mn) / 1000;
	      if o_comision < v_mto_min_mn then
		 let o_comision = v_mto_min_mn;
	      end if
	      if o_comision > v_mto_max_mn then
		 let o_comision = v_mto_max_mn;
	      end if

	 end if
	 let o_iva = o_comision * v_iva;
    else
	 select precio_venta into v_t_cam
            from bdinteg:si_tpcambio
	    where empresa = i_empresa and divisa = i_divisa and
                  clase_tpcambio = "B";
         -- eliminar linea cuando se decida que Central Valoriza
         let v_t_cam = 1;
	 if v_t_cam is NULL then
	       let codret = "105";
	       return codret,o_comision,o_iva;
	 end if
	 if v_com_c_cert_od > 0 then
	      let o_comision =  v_com_c_cert_od * v_t_cam;
	 else
	      let o_comision = (i_monto * v_factor_od) / 1000;
	      if o_comision < (v_mto_min_od * v_t_cam) then
		 let o_comision = (v_mto_min_od * v_t_cam);
	      end if
	      if o_comision > (v_mto_max_od * v_t_cam) then
		 let o_comision = (v_mto_max_od * v_t_cam);
	      end if
	 end if
	 let o_iva = o_comision * v_iva;
         let i_monto = (i_unidades_div * v_t_cam);
    end if

   let v_total = i_monto + o_comision + o_iva;

   select cuenta,status_cta,motivo,producto,sucursal,plaza,
          lim_sbg_ccc-imp_sbg_ccc,sdo_retenido,sdo_cong,sdo_actual,colateral
      into cta,estatus,mot,pro,sucur,v_plaza,lin_cre,sad_ret,sad_con,
           sad_actual,v_colateral
      from bdicheq:sc_maechq
      where empresa = i_empresa and cuenta = i_cuenta;
   if cta is null then
      let codret = "100";
      return codret,o_comision,o_iva;
   end if;

   select divisa into v_moneda
      from bdicheq:sc_producto
      where empresa = i_empresa and producto=pro;

   if v_moneda != i_divisa then
      let codret="905";
      return codret,o_comision,o_iva;
   end if;

   if estatus = "2" then
      let codret = "200";
      return codret,o_comision,o_iva;
   elif estatus = "3" then
      select cargo into acep_car
         from bdicheq:sc_bloqueo
         where codigo = mot;
      if acep_car = "N" then
         let codret = "300";
         return codret,o_comision,o_iva;
      end if;
   end if;

-------------------------------------------------------------------------
--Valida que el saldo disponible sea mayor al monto
-------------------------------------------------------------------------
   let sdo_dis = sad_actual - sad_con - sad_ret + lin_cre;
   if sdo_dis < v_total then
      if v_colateral="S" then
	 call bdicheq:total_colateral(i_empresa,i_cuenta)
	      returning v_sdo_col,v_totcol;
 	 let v_sdo_fin= v_sdo_col+sdo_dis;
	 if v_sdo_fin < v_total then
	    let codret = "400";
	    return codret,o_comision,o_iva;
	 end if;
      else
	 let codret = "400";
	 return codret,o_comision,o_iva;
      end if;
   end if;

--------------------------------------------------------------------------
-- Valida que el documento no haya sido pagado,certificado,ni suspendido
--------------------------------------------------------------------------
   if i_divisa != v_codigo_mn then
      let v_mto_cargo = i_unidades_div;
      let v_trancar = "0320";
   else
      let v_mto_cargo = i_monto;
      let v_trancar = "0220";
   end if
   select rowid,cuenta,numero,estado
      into v_row,cuen,num,util
      from bdicheq:sc_contch
      where empresa = i_empresa and
            cuenta = i_cuenta and
            numero = i_nodocto;

   if cuen is null and num is null then
      let cuen = "0";
      let num = "0";
   end if;

   if cuen = i_cuenta and num = i_nodocto then
      if util = "P" then
	 let codret = "600";
	 return codret,o_comision,o_iva;
      elif util = "S" then
	 let codret = "700";
	 return codret,o_comision,o_iva;
      elif util = "C" then
	 let codret = "800";
	 return codret,o_comision,o_iva;
      end if;
      let vcodret = "000";
      call bdicheq:cargo_ref(i_empresa,i_sucursal,i_usuario,v_trancar,
           "0000",i_folio,i_cuenta,i_nodocto,v_mto_cargo,i_divisa,"")
           returning vcodret,vtranret,vfecapli,vsdodisp,vmontoret;
      if vcodret <> "000" then
         let codret = vcodret;
         return codret,o_comision,o_iva;
      else
         let codret = "000";
         update bdicheq:sc_contch
            set (estado,fecha_alta) = ("C",v_fecha_hoy)
            where rowid=v_row;
      end if;
      let vcodret = "000";
      if o_comision > 0 then
	 call bdicheq:cargo_ref(i_empresa,i_sucursal,i_usuario,"3088",
              "0000",i_folio,i_cuenta,i_nodocto,o_comision,i_divisa,"")
              returning vcodret,vtranret,vfecapli,vsdodisp,vmontoret;
      end if
      if vcodret <> "000" then
 	 let codret = i;
	 return codret,o_comision,o_iva;
      else
         let codret = "000";
      end if;

      let vcodret = "000";
      if o_iva > 0 then
	 call bdicheq:cargo_ref(i_empresa,i_sucursal,i_usuario,"3089",
                   "0000",i_folio,i_cuenta,i_nodocto,o_iva,i_divisa,"")
              returning vcodret,vtranret,vfecapli,vsdodisp,vmontoret;
      end if

      if vcodret <> "000" then
            let codret = i;
	    return codret,o_comision,o_iva;
      else
	    let codret = "000";
      end if
   else
      select cuenta,numero,estado into cuen,num,util
         from bdicheq:sc_histch
         where cuenta = i_cuenta and numero = i_nodocto;
      if cuen is null and num is null then
         let cuen = "0";
         let num = "0";
      end if;

      if cuen = i_cuenta and num = i_nodocto then
         if util = "P" then
	    let codret = "600";
	    return codret,o_comision,o_iva;
	 elif util = "S" then
	    let codret = "700";
	    return codret,o_comision,o_iva;
	 elif util = "C" then
	    let codret = "800";
	    return codret,o_comision,o_iva;
	 end if;
      else
	let vcodret = "000";
	call bdicheq:cargo_ref(i_empresa,i_sucursal,i_usuario,v_trancar,
             "0000",i_folio,i_cuenta,i_nodocto,v_mto_cargo,i_divisa,"")
             returning vcodret,vtranret,vfecapli,vsdodisp,vmontoret;
	if vcodret <> "000" then
	   let codret = i;
	   return codret,o_comision,o_iva;
	else
	   update bdicheq:sc_contch
	      set estado = "C"
	      where empresa = i_empresa and cuenta = i_cuenta and
                    numero = i_nodocto;
	end if

	let vcodret = "000";
	if o_comision > 0 then
	   call bdicheq:cargo_ref(i_empresa,i_sucursal,i_usuario,"3088",
               "0000",i_folio,i_cuenta,i_nodocto ,o_comision,i_divisa,"")
           returning vcodret,vtranret,vfecapli,vsdodisp,vmontoret;
	end if
	if vcodret <> "000" then
	   let codret = i;
	   return codret,o_comision,o_iva;
	else
	   let codret = "000";
	end if;

	let vcodret = "000";
	if o_iva > 0 then
	   call bdicheq:cargo_ref(i_sucursal,i_usuario,"3089",
                "0000",i_folio,i_cuenta,i_nodocto,o_iva,i_divisa,"")
           returning vcodret,vtranret,vfecapli,vsdodisp,vmontoret;
	end if
	if vcodret <> "000" then
	   let codret = i;
	   return codret,o_comision,o_iva;
	else
	   let codret = "000";
	end if
      end if
   end if

--------------------------------------------------------------------
-- Inserta los datos en la base de datos de TRANSFERENCIAS
--------------------------------------------------------------------
   let v_nom_cliente = " ";
   -- Obtiene el Nombre del Cliente
   select cuenta,cl.numcte,tpo_persona,apell_paterno,apell_materno,
	  nombre1,razon_social
      into v_cuenta,v_num_cte,v_per,v_ape_pa,v_ape_ma,v_nom1,v_rasoc
      from bdicheq:sc_maechq mc, bdinteg:si_cliente cl
      where mc.empresa = i_empresa and cuenta  = i_cuenta and
            mc.empresa = cl.empresa and numcte = num_cte;
   select es_fisica into v_es_fisica from bdinteg:si_tipper
      where tpo_persona = v_per;

   if v_es_fisica = "S" then
      let v_nom_cliente = v_ape_pa || " " || v_ape_ma || " " || v_nom1;
   else
      let v_nom_cliente = v_rasoc;
   end if

   -- Crea Movimiento Diario
   call stmovdia(i_empresa,v_plaza,i_sucursal,i_usuario,
		 v_fecha_hora_exp,v_cve_en_transito,i_divisa,
	  	 v_cve_c_cert,i_nodocto,i_folio,i_cuenta,v_total)
  	returning codret;
   if codret != "000" then
      return codret,o_comision,o_iva;
   end if
   insert into st_maetrans
      values (i_empresa,v_cve_c_cert,i_nodocto,i_sucursal,
              i_divisa,i_unidades_div,
    	      i_usuario,v_fecha_hora_exp," "," "," "," "," "," ",0,
	      0,0,0," ",0,i_monto,i_benefic," "," "," "," ",
	      v_nom_cliente," "," ",0,0,0,i_cuenta,v_total,"1",
  	      o_comision,100,0,v_total,v_cve_en_transito," ");
end;    --fin del on exception
return codret,o_comision,o_iva;
end procedure;
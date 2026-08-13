create procedure "informix".stpase(usuario char(8))
-- ****************************** Definicion de Variables *********************
   define v_tipo_docto char(2);
   define v_num_docto char(10);
   define v_sucursal char(3);
   define v_moneda char(2);
   define v_unidades_divisa money(14,2);
   define v_clave_cajero char(8);
   define v_fecha_hora_exp datetime year to second;
   define v_banco_dest char(3);
   define v_pais_dest char(3);
   define v_plaza_dest char(2);
   define v_ciudad_dest char(3);
   define v_sucursal_pagador char(3);
   define v_cajero_paga char(8);
   define v_mto_pagado_mn money(14,2);
   define v_mto_efec_abono money(14,2);
   define v_mto_efec_a_div money(14,2);
   define v_mto_efec_a_val money(14,2);
   define v_num_abono_cta char(10);
   define v_mto_abono_cta money(14,2);
   define v_sistema_abono char(2);
   define v_monto money(14,2);
   define v_beneficiario char(40);
   define v_banco_emisor char(25);
   define v_lugar_emision char(25);
   define v_contrasena char(10);
   define v_instrucciones char(30);
   define v_nombre_comprador char(40);
   define v_telefono_solic char(10);
   define v_domicilio_solic char(40);
   define v_mto_efec_cargo money(14,2);
   define v_mto_efec_c_div money(14,2);
   define v_mto_efec_c_val money(14,2);
   define v_num_cargo_cta char(10);
   define v_mto_cargo_cta money(14,2);
   define v_sistema_cargo char(2);
   define v_tipo_comision char(1);
   define v_comision money(14,2);
   define v_impuesto money(14,2);
   define v_porc_cob_com decimal(8,5);
   define v_telef_telex money(14,2);
   define v_impuesto_gastos money(14,2);
   define v_total_com money(14,2);
   define v_status_docto char(1);
   define v_fecha_hora_pago datetime year to second;
   define v_fecha_hora_hecho datetime year to second;

   define v_cve_en_transito char(1);
   define v_cve_prevenido char(1);
   define v_cve_desbloqueo char(1);
   define v_ExisteHist     smallint;

-- *************************** Inicializacion de Variables *********************

select fecha_hoy into v_fecha_hora_hecho
   from bdicent:si_fechas;

let v_fecha_hora_hecho = current hour to second;

select cve_en_transito, cve_prevenido, cve_desbloqueo
   into v_cve_en_transito, v_cve_prevenido, v_cve_desbloqueo
   from st_param;

-- *************************** Lectura de Doctos. en Mtro. *********************
-- *************************** (No vigentes) para su alta  *********************
-- *************************** en reg. historico de Transf.*********************
begin work;
foreach pase_hist_cur for
   select *
      into v_tipo_docto, v_num_docto, v_sucursal,
	   v_moneda, v_unidades_divisa, v_clave_cajero,
	   v_fecha_hora_exp, v_banco_dest, v_pais_dest,
	   v_plaza_dest, v_ciudad_dest, v_sucursal_pagador,
	   v_cajero_paga, v_mto_pagado_mn, v_mto_efec_abono,
	   v_mto_efec_a_div, v_mto_efec_a_val, v_num_abono_cta,
	   v_mto_abono_cta, v_monto, v_beneficiario,
	   v_banco_emisor, v_lugar_emision, v_contrasena,
	   v_instrucciones, v_nombre_comprador, v_telefono_solic,
	   v_domicilio_solic, v_mto_efec_cargo, v_mto_efec_c_div,
	   v_mto_efec_c_val, v_num_cargo_cta, v_mto_cargo_cta,
	   v_tipo_comision, v_comision, v_porc_cob_com,
	   v_telef_telex, v_total_com, v_status_docto,
	   v_fecha_hora_pago
      from st_maetrans
      where status_docto != v_cve_en_transito and
            status_docto != v_cve_prevenido and
            status_docto != v_cve_desbloqueo
      order by tipo_docto, num_docto desc

      select count(*) into v_ExisteHist
	 from st_histrans
	 where tipo_docto = v_tipo_docto and num_docto = v_num_docto;
	 if v_ExisteHist = 0 then
	    -- Si solo existe en el Maestro y No es un Docto. Vigente
	    -- Se Traspasa al Historico.
            insert into st_histrans
            values (v_tipo_docto, v_num_docto, v_sucursal,
	            v_moneda, v_unidades_divisa, v_clave_cajero,
	            v_fecha_hora_exp, v_banco_dest, v_pais_dest,
	            v_plaza_dest, v_ciudad_dest, v_sucursal_pagador,
	            v_cajero_paga, v_mto_pagado_mn, v_mto_efec_abono,
		    v_mto_efec_a_div, v_mto_efec_a_val, v_num_abono_cta,
		    v_mto_abono_cta, v_monto, v_beneficiario,
		    v_banco_emisor, v_lugar_emision, v_contrasena,
		    v_instrucciones, v_nombre_comprador, v_telefono_solic,
		    v_domicilio_solic, v_mto_efec_cargo, v_mto_efec_c_div,
		    v_mto_efec_c_val, v_num_cargo_cta, v_mto_cargo_cta,
		    v_tipo_comision, v_comision, v_porc_cob_com,
		    v_telef_telex, v_total_com, v_status_docto,
		    v_fecha_hora_pago, v_fecha_hora_hecho, usuario);
            -- Elimina el Renglon que fue traspasado a Historico.
            delete from st_maetrans
	       where tipo_docto = v_tipo_docto and
		     num_docto  = v_num_docto;
         else
	    continue foreach;
         end if

end foreach;
commit work;

end procedure;
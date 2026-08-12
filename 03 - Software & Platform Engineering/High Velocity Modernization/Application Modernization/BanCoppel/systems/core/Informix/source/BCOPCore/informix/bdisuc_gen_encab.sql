create procedure "informix".gen_encab(psucursal       char(8),
			   pfecha_hoy      date,
                           pcontrol_poliza smallint)
returning char(3);

   define cod_ret char(3);
   define v_moneda char(2);
   define v_descripcion char(40);
   define v_monto money(14,2);

 set debug file to "gen_encab.suc";
 trace on;

-- ***************************************************************************
-- Inicializa variables
-- ***************************************************************************
   let cod_ret         = "000";
   let v_descripcion  = "MOVIMIENTO DE SUCURSAL";

-- ***************************************************************************
-- Valida los parametros de entrada
-- ***************************************************************************
   if psucursal    is null  or
      pfecha_hoy   is null then
      let cod_ret = "110";
      return cod_ret;
   end if

   Foreach
      -- Extrae los montos capturados en la poliza
     select moneda, sum(monto)/2 into v_moneda, v_monto
     from bdicont:co_detpol
     where usuario = psucursal and fecha_captura=pfecha_hoy and
           control_poliza = pcontrol_poliza 
     group by moneda

     if v_monto is null then
        let v_monto = 0;
     end if
     insert into bdicont:co_poliza
     values(psucursal, pcontrol_poliza, pfecha_hoy, v_monto,
	    v_monto, v_monto, v_moneda, v_descripcion);

     -- Actualiza el control de polizas en Sistema Integral 28/ABR/97 AMF
     execute procedure bdicent:contpolizas(psucursal, pcontrol_poliza,
                                           pfecha_hoy, v_moneda, "SS");


   end foreach
return cod_ret;
end procedure;
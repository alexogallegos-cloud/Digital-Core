create procedure "informix".gen_encab(pempresa char(3),pusuario char(8),
			   pfecha_hoy      date,
                           pcontrol_poliza integer)
returning char(3);

   define cod_ret char(3);
   define v_moneda char(2);
   define v_descripcion char(40);
   define v_monto money(14,2);


-- ***************************************************************************
-- Inicializa variables
-- ***************************************************************************
   let cod_ret         = "000";
   let v_descripcion  = "ENCABEZADO GENERADO POR SISTEMA";

-- ***************************************************************************
-- Valida los parametros de entrada
-- ***************************************************************************
   if pusuario    is null  or
      pfecha_hoy   is null then
      let cod_ret = "110";
      return cod_ret;
   end if

   Foreach
      -- Extrae los montos capturados en la poliza
     select moneda, sum(monto)/2 into v_moneda, v_monto
     from co_detpol
     where usuario = pusuario and fecha_captura=pfecha_hoy and
           control_poliza = pcontrol_poliza and
           empresa = pempresa
     group by moneda

     if v_monto is null then
        let v_monto = 0;
     end if
     if v_moneda is null then
        let v_moneda = "00";
     end if
     insert into co_poliza
     values(pempresa, pusuario, pcontrol_poliza, pfecha_hoy, v_monto,
	    v_monto, v_monto, v_moneda, v_descripcion);
   end foreach
return cod_ret;
end procedure;
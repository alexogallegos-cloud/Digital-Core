create procedure "informix".sp_act_encab(pempresa char(3),pusuario char(8),
			   pfecha_hoy      date,
                           pcontrol_poliza smallint)
returning char(3);

   define cod_ret char(3);
   define v_moneda char(2);
   define v_descripcion char(40);
   define v_monto money(14,2);
   define v_naturaleza char(1);



-- ***************************************************************************
-- Inicializa variables
-- ****************************

   let cod_ret         = "00000";
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
      -- Extrae los montos capturados en la poliza 26/08/2002
     select moneda, naturaleza, sum(monto) into v_moneda, v_naturaleza, v_monto
     from co_detpol
     where usuario = pusuario and fecha_captura=pfecha_hoy and
           control_poliza = pcontrol_poliza and
           empresa = pempresa
     group by moneda,naturaleza

     if v_monto is null then
        let v_monto = 0;
     end if
     if v_moneda is null then
        let v_moneda = "00";
     end if

     if v_naturaleza = "D" then
        update co_poliza
            set cifra_control = v_monto,
                capturado_cargo = v_monto,
                descripcion = v_descripcion
        where  empresa = pempresa
        and    usuario = pusuario
        and    control_poliza = pcontrol_poliza
        and    fecha_captura = pfecha_hoy
        and    moneda = v_moneda;
     end if

     if v_naturaleza = "C" then
        update co_poliza
            set cifra_control = v_monto,
                capturado_abono = v_monto,
                descripcion = v_descripcion
        where  empresa = pempresa
        and    usuario = pusuario
        and    control_poliza = pcontrol_poliza
        and    fecha_captura = pfecha_hoy
        and    moneda = v_moneda;
     end if
   end foreach;
return cod_ret;
end procedure;
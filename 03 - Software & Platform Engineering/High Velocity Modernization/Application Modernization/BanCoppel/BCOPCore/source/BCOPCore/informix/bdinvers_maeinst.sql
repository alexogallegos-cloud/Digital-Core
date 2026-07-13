create procedure "informix".maeinst(pempresa char(3),
                                    pcuenta  char(20))
returning char(5), char(1), smallint, char(2), money(14,2), char(20); 

-- ***************************************************************************
-- Define variables 
-- ***************************************************************************
   define cod_ret char(5);
   define v_cap_int char(1); 
   define v_inst_vento char(2); 
   define v_nro_cuenta, v_cuenta char(20); 
   define v_importe money(14,2);
   define v_secuencia, longitud smallint; 

-- ***************************************************************************
-- Asigna variables 
-- ***************************************************************************
   let cod_ret       = "000";
   let v_cap_int     = " ";
   let v_inst_vento  = "00";
   let v_nro_cuenta  = "0";
   let v_importe     = 0;
   let v_secuencia   = 0;



-- Verifica existan instrucciones al vencimiento de la inversion a consultar
   FOREACH
   select cuenta, cap_int, secuencia, inst_vento, importe, nro_cuenta
	  into v_cuenta, v_cap_int, v_secuencia, v_inst_vento, v_importe,
	  v_nro_cuenta
   from sv_maeinstrucc
   where empresa = pempresa and cuenta = pcuenta
   return cod_ret, v_cap_int, v_secuencia, v_inst_vento, v_importe,
	  v_nro_cuenta WITH RESUME;
   END FOREACH

end procedure;
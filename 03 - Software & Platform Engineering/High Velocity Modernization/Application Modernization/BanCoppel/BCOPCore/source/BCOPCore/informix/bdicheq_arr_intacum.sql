create procedure "informix".arr_intacum()

define vcuenta char(20);
define vsaldo  decimal(14,2);
define int_acum decimal(14,2);


	foreach select a.cuenta, sdo_actual
		  into vcuenta, vsaldo
		  from sc_maenoc a, sc_maechq b
		 where a.empresa = "001"
		   and a.empresa = b.empresa
		   and a.cuenta = b.cuenta
		   and day(fecha_alta) > "02"
		   and fecha_alta <> "01/03/2008"
		   and status_cta ="1"
		   and producto in ("2000","1400")

		if vsaldo > 0 then
		   let int_acum = ((vsaldo * .04) / 360) * 2;
		else
		   let int_acum = 0;
		end if
		update sc_maenoc
		   set acum_sdo_int = int_acum
		 where empresa = "001"
		   and cuenta = vcuenta;

	end foreach


end procedure
;
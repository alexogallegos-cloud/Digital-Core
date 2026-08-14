create procedure "informix".sp_factura( p_empresa char(3), p_num_credito char(20), p_fecha date )
returning 	char(20) ,
		char(20) ,
		char(4) ,
		decimal(18,2) ,
		date ,
		date ,
		date ,
		date ,
		integer ,
		decimal(9,6) ,
		decimal(18,2) ;

define r_num_cte char(20);
define r_num_credito char(20);
define r_num_producto char(4);
define r_monto_desembolso decimal(18,2);
define r_fecha_desembolso date;
define r_fecha_apertura date;
define r_fecha_inicial date;
define r_fecha_factura date;
define r_dias integer;
define r_tasa_interes decimal(9,6);
define r_monto_interes decimal(18,2);
define ax_programada DATE;

define v_min_fecha_nopagada date;
define v_max_fecha_pagada date;
define v_fecha_dias date;



let r_fecha_factura = p_fecha;

select num_credito, fecha_apertura, tasa_interes, numcte, num_producto
into r_num_credito, r_fecha_apertura, r_tasa_interes, r_num_cte, r_num_producto
from sd_maecred
where empresa = p_empresa
and num_credito = p_num_credito;

foreach
	select monto_otorgado, fecha_otorga, fecha_programada
	into r_monto_desembolso, r_fecha_desembolso, ax_programada
	from sd_detminis
	where empresa = p_empresa
	and num_credito = r_num_credito
	and status_ministra = 'M'
	and monto_otorgado > 0.0
	order by fecha_programada

		select min(fecha_cuota)
		into v_min_fecha_nopagada
		from sd_paginter
		where  empresa = p_empresa
		and num_credito = p_num_credito
		and status_cuota in ('1','2','7')
		and fecha_cuota > r_fecha_desembolso;

		select max(fecha_cuota)
		into v_max_fecha_pagada
		from sd_paginter
		where empresa = p_empresa
		and num_credito = p_num_credito
		and status_cuota in ('5')
		and fecha_cuota < v_min_fecha_nopagada;

		if r_fecha_desembolso < v_min_fecha_nopagada and r_fecha_desembolso < v_max_fecha_pagada then
			let r_fecha_inicial = v_max_fecha_pagada;
		else
			let r_fecha_inicial = r_fecha_desembolso;
		end if;

		let v_fecha_dias = r_fecha_factura - r_fecha_inicial;
		let r_dias = day(v_fecha_dias) + 30 * (month(v_fecha_dias)-1) + 365 * (year(v_fecha_dias)-1900) + 1;


		let r_monto_interes = (r_monto_desembolso) * (( r_tasa_interes / 100 ) / ( 365 )) * r_dias;

		return r_num_cte, r_num_credito, r_num_producto, r_monto_desembolso, r_fecha_desembolso, r_fecha_apertura, r_fecha_inicial, r_fecha_factura,
		       r_dias,	r_tasa_interes, r_monto_interes with resume;


end foreach;


end procedure;
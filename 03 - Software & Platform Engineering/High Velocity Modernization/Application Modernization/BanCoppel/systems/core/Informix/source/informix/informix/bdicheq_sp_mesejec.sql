create procedure "informix".sp_mesejec( pempresa char(3) )
returning char(20) ,
	  integer ,
	  char(60) ,
	  char(160) ,
	  char(2) ,
	  char(4) ,
	  char(20) ,
	  char(2) ,
	  decimal(14,2) ,
	  decimal(14,2) ,
	  decimal(14,2) ,
	  decimal(14,2) ,
	  date ,
	  date ,
	  date ,
	  integer ,
	  integer ,
	  char(40) ;

define r_numcte char(20);
define r_tpo integer;
define r_nombre char(60);
define r_titulo char(160);
define r_siglas char(2);
define r_producto char(4);
define r_cuenta char(20);
define r_status char(2);
define r_saldo decimal(14,2);
define r_interes decimal(14,2);
define r_pago decimal(14,2);
define r_saldo_original decimal(14,2);
define r_fecha_apertura date;
define r_fecha_pago date;
define r_fecha_vencimiento date;
define r_plazos_total integer;
define r_plazos_pagados integer;
define r_producto_nombre char(40);

define v_nombre1 char(15);
define v_nombre2 char(15);
define v_apell_paterno char(15);
define v_apell_materno char(15);
define v_tasa char(8);
define v_secuencia integer;


SET ISOLATION TO DIRTY READ;

foreach
    select a.numcte, a.tpo, a.titulo,
	   b.nombre1, b.nombre2, b.apell_paterno, b.apell_materno
    into r_numcte, r_tpo, r_titulo,
	 v_nombre1, v_nombre2, v_apell_paterno, v_apell_materno
    from si_repmesejec a
    inner join si_cliente b
    on a.empresa = b.empresa
    and a.numcte = b.numcte
    order by a.numcte
    let r_nombre = TRIM(v_nombre1)||' '||TRIM(V_apell_paterno)||' '||TRIM(v_apell_materno);
    foreach
	select "SD", a.num_credito, a.num_producto, a.status_cred,
	sdo_cap_insoluto + sdo_exig_int + sdo_moratorio
	into r_siglas, r_cuenta, r_producto, r_status, r_saldo
	from sd_maecred a
	inner join sd_maesdos b
	on a.empresa = b.empresa
	and a.num_credito = b.num_credito
	where  a.empresa = pempresa
	and a.numcte = r_numcte
--	union all
--	select "SC", cuenta, producto, status_cta, sdo_actual
--	from bdicheq:sc_maechq
--	where empresa = pempresa and num_cte = r_numcte
--	union all
--	select "SV", cuenta, cod_instrum, status_cta, capital
--	from bdinvers:sv_maeinv
--	where empresa = pempresa and num_cte = r_numcte and status_cta <> "4"
	order by 2
	if r_status = "2" then
	    let r_saldo = 0;
	end if;

	let r_interes = 0.0;
	let r_pago = 0.0;
	let r_saldo_original = 0.0;
	let r_fecha_apertura = null;
	let r_fecha_pago = null;
	let r_fecha_vencimiento = null;
	let r_plazos_total = 0;
	let r_plazos_pagados = 0;
	let r_producto_nombre = ' ';

	if r_siglas = "SC" then
		select a.tasa
		into v_tasa
		from bdicheq:sc_producto a
		where a.empresa = pempresa
		and a.producto = r_producto;
		select a.valor
		into r_interes
		from bdinteg:si_fechavalor a
		where a.empresa = pempresa
		and a.tasa = v_tasa;
		if r_interes is null then
			let r_interes = 0.0;
		end if;
	elif r_siglas = "SV" then
		select max(a.secuencia)
		into v_secuencia
		from bdinvers:sv_maeinv a
		where a.empresa = pempresa
		and a.cuenta = r_cuenta;
		select a.tasa + a.sobretasa, a.capital
		into r_interes, r_saldo_original
		from bdinvers:sv_maeinv a
		where a.empresa = pempresa
		and a.secuencia = v_secuencia
		and a.cuenta = r_cuenta;
		if r_interes is null then
			let r_interes = 0.0;
		end if;
		if r_saldo_original is null then
			let r_saldo_original = 0.0;
		end if;
	elif r_siglas = "SD" then
		select round(a.tasa_interes,2)
		into r_interes
		from bdicred:sd_maecred a
		where a.empresa = pempresa
		and num_credito = r_cuenta;
		if r_interes is null then
			let r_interes = 0.0;
		end if;
		select min(a.monto_cuota + b.monto_cuota)
		into r_pago
		from bdicred:sd_pagocapit a, bdicred:sd_paginter b
		where a.empresa = pempresa
		and a.empresa = b.empresa
		and a.num_credito = r_cuenta
		and a.num_credito = b.num_credito
		and a.fecha_cuota = b.fecha_cuota;
		if r_pago is null then
			let r_pago = 0.0;
		end if;
		select a.monto_otorgado
		into r_saldo_original
		from bdicred:sd_maesdos a
		where a.empresa = pempresa
		and a.num_credito = r_cuenta;
		if r_saldo_original is null then
			let r_saldo_original = 0.0;
		end if;
		select a.fecha_apertura, a.fecha_vencim, a.plazo
		into r_fecha_apertura, r_fecha_vencimiento, r_plazos_total
		from bdicred:sd_maecred a
		where a.empresa = pempresa
		and a.num_credito = r_cuenta;
		select min(fecha_cuota)
		into r_fecha_pago
		from bdicred:sd_pagocapit a
		where a.empresa = pempresa
		and a.num_credito = r_cuenta
		and a.status_cuota in ('1','2','7');
		select count(*)
		into r_plazos_pagados
		from bdicred:sd_pagocapit a
		where a.empresa = pempresa
		and a.num_credito = r_cuenta
		and a.fecha_cuota < r_fecha_pago;

		select a.nombre_prod
		into r_producto_nombre
		from bdicred:sd_definicion a
		where a.empresa = pempresa
		and a.num_producto = r_producto;
	end if;
	return r_numcte, r_tpo, r_nombre, r_titulo, r_siglas, r_producto, r_cuenta, r_status, r_saldo,
	       r_interes, r_pago, r_saldo_original,
	       r_fecha_apertura, r_fecha_pago, r_fecha_vencimiento, r_plazos_total, r_plazos_pagados, r_producto_nombre  with resume;
    end foreach;
end foreach;
end procedure;
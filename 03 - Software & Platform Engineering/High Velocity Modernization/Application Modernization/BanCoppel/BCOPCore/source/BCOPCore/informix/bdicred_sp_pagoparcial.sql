create procedure "informix".sp_pagoparcial( pempresa char(3),
				 ptipo char(1) )
returning	integer ,
		char(20) ,
		date ,
		decimal(14,2) ,
		decimal(14,2) ,
		decimal(14,2) ;

define r_count integer;
define r_num_credito char(20);
define r_fecha_pago date;
define r_principal decimal(14,2);
define r_interes decimal(14,2);
define r_seguros decimal(14,2);

define v_fecha_ult date;

let r_count = 0;

foreach
	select a.num_credito
	into r_num_credito
	from sd_maecred a
	where a.empresa = pempresa
	and a.status_cred <> 'CC'


        select max(a.fecha_cuota)
        into v_fecha_ult
        from sd_pagocapit a
        where a.empresa = pempresa
        and a.num_credito = r_num_credito
        and a.status_cuota in ('1','2','7');


	foreach 
		select a.fecha_cuota 
		into r_fecha_pago
		from sd_pagocapit a
		where a.empresa = pempresa
		and a.num_credito = r_num_credito
		and a.status_cuota in ('1','2','7')
		order by a.fecha_cuota

		if r_fecha_pago = v_fecha_ult then
			exit foreach;
		end if;

		-- Presenta Principal por Cuota segun el detalle de Credito
                select sum(a.monto_real_pag)
                into r_principal
                from bdicred:sd_pagocapit a
                where a.empresa = pempresa
                and a.num_credito = r_num_credito
                and a.fecha_cuota = r_fecha_pago;
                if r_principal is null then
                	let r_principal = 0;
                end if;

                -- Presenta Interes por Cuota segun el detalle de Credito
                select sum(a.monto_real_pag)
                into r_interes
                from bdicred:sd_paginter a
                where a.empresa = pempresa
                and a.num_credito = r_num_credito
                and a.fecha_cuota = r_fecha_pago;
                if r_interes is null then
                	let r_interes = 0;
                end if;


                -- Presenta Seguros por Cuota segun el detalle de Credito
                select sum(a.monto_pag)
                into r_seguros
                from bdicred:sd_detcomi a
                where a.empresa = pempresa
                and a.num_credito = r_num_credito
                and a.fecha_alta = r_fecha_pago
                and a.cod_comis in ('0101','0102','0103','0104','0105','0106');
                if r_seguros is null then
                	let r_seguros = 0;
                end if;
		
		if r_principal + r_interes + r_seguros <> 0 then
			let r_count = r_count + 1;
			return r_count, r_num_credito, r_fecha_pago, r_principal, r_interes, r_seguros with resume;	
		end if;
		
		if ptipo = '1' then
			exit foreach;
		end if;
	end foreach;
end foreach;

end procedure;
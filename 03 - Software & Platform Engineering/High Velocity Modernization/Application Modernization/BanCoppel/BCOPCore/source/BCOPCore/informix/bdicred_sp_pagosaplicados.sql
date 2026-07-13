create procedure "informix".sp_pagosaplicados( pempresa char(3), pdia_inicial date, pdia_final date )
returning char(3)  ,
	  char(20) ,
	  char(8)  ,
	  char(16) ,
	  decimal(18,2) ,
	  decimal(18,2) ,
	  decimal(18,2) ,
	  decimal(18,2) ,
	  decimal(18,2) ,
	  date ,
	  date ,
	  decimal(18,2) ,
	  decimal(18,2) ,
	  decimal(18,2) ,
	  decimal(18,2) ;

	define r_num_producto char(3);
	define r_num_credito char(20);
	define r_usuario char(8);
	define r_folio char(16);
	define r_monto_total_pago decimal(18,2);
	define r_monto_total_principal decimal(18,2);
	define r_monto_total_interes decimal(18,2);
	define r_monto_total_recargos decimal(18,2);
	define r_monto_total_seguros decimal(18,2);
	define r_fecha_pago date;
	define r_fecha_vencimiento date;
	define r_monto_cuota_principal decimal(18,2);
	define r_monto_cuota_interes decimal(18,2);
	define r_monto_cuota_recargos decimal(18,2);
	define r_monto_cuota_seguros decimal(18,2);

	define v_monto_temp decimal(18,2);

	define v_folio_prox char(16);
	define v_mov_serial int;
--	define v_fecha_pago date;

	set isolation dirty read;
 

	foreach 
		-- Para Cada Pago En Movdia por El rango de fechas
		select a.num_producto, a.num_credito, a.usuario, a.folio_suc, a.monto, a.fecha_mov
		into r_num_producto, r_num_credito, r_usuario, r_folio, r_monto_total_pago, r_fecha_pago
		from bdicred:sd_movdia a
		where a.empresa = pempresa
		and a.codigo_ref = '1'
		and a.codigo_fun = '033'
		and a.reversado <> 'S'
		and a.fecha_mov >= pdia_inicial and a.fecha_mov <= pdia_final
		order by a.fecha_mov, a.num_producto, a.usuario, a.num_credito, a.folio_suc

		-- Presenta Proximo Folio por si no es el ultimo
		-- Es necesario por la estructura de los respaldos de las tablas
		select min(a.secuencia)
		into v_mov_serial
		from bdicred:sd_movdia a
		where a.empresa = pempresa
		and a.num_credito = r_num_credito
		and a.codigo_ref = '1'
		and a.codigo_fun = '033'
		and a.reversado <> 'S'
		and a.fecha_mov > r_fecha_pago;

		select a.folio_suc
		into v_folio_prox
		from bdicred:sd_movdia a
		where a.empresa = pempresa
		and a.num_credito = r_num_credito
		and a.secuencia = v_mov_serial
		and a.codigo_ref = '1'
		and a.codigo_fun = '033'
		and a.reversado <> 'S';

		-- Presenta Total Principal de Pago segun Movdia
		select sum(a.monto)
		into r_monto_total_principal
		from bdicred:sd_movdia a
		where a.empresa = pempresa
		and a.num_credito = r_num_credito
		and a.folio_suc = r_folio
		and a.codigo_ref in (7,8,10,909,908,907);
		if r_monto_total_principal is null then
			let r_monto_total_principal = 0;
		end if;

		-- Presenta Total Intereses de Pago segun Movdia
		select sum(a.monto)
		into r_monto_total_interes
		from bdicred:sd_movdia a
		where a.empresa = pempresa
		and a.num_credito = r_num_credito
		and a.folio_suc = r_folio
		and a.codigo_ref in (3,5,9,923,925,926);
		if r_monto_total_interes is null then
			let r_monto_total_interes = 0;
		end if;

		-- Presenta Total Seguros de Pago segun Movdia
		select sum(a.monto)
		into r_monto_total_seguros
		from bdicred:sd_movdia a
		where a.empresa = pempresa
		and a.num_credito = r_num_credito
		and a.folio_suc = r_folio
		and a.codigo_ref in ('1101','1102','1103','1104','1105','1106');
		if r_monto_total_seguros is null then
			let r_monto_total_seguros = 0;
		end if;

		-- Presenta Total Recargos de Pago segun Movdia
		select sum(a.monto)
		into r_monto_total_recargos
		from bdicred:sd_movdia a
		where a.empresa = pempresa
		and a.num_credito = r_num_credito
		and a.folio_suc = r_folio
		and a.codigo_ref = '2';
		if r_monto_total_recargos is null then
			let r_monto_total_recargos = 0;
		end if;

		-- Si es ultimo folio del credito necesita tratamiento diferente...
		if v_folio_prox is null then
				foreach 
					-- Presenta las fecha de los vencimientos de la cuotas afectadas por el ultimo folio
					select a.fecha_cuota
					into r_fecha_vencimiento
					from bdicred:sd_pagocapit a
					where a.empresa = pempresa
					and a.num_credito = r_num_credito
					and a.fecha_pago = r_fecha_pago
--	                       		and a.monto_real_pag > 0
					and a.monto_real_pag <> (
						select b.monto_real_pag
						from bdicred:sd_pagocapitrev b
						where b.empresa = a.empresa
						and b.num_credito = a.num_credito
						and b.fecha_cuota = a.fecha_cuota
--						and b.monto_real_pag > 0
						and b.folio = r_folio
					)
					union
					select a.fecha_cuota
					from bdicred:sd_paginter a
					where a.empresa = pempresa
					and a.num_credito = r_num_credito
					and a.fecha_pag = r_fecha_pago
--			            	and a.monto_real_pag > 0
					and a.monto_real_pag <> (
						select b.monto_real_pag
						from bdicred:sd_paginterrev b
						where b.empresa = a.empresa
						and b.num_credito = a.num_credito
						and b.fecha_cuota = a.fecha_cuota
--						and b.monto_real_pag > 0
						and b.folio = r_folio
					)
					union
					select a.fecha_alta
					from bdicred:sd_detcomi a
					where a.empresa = pempresa
					and a.num_credito = r_num_credito
					and a.fecha_pago = r_fecha_pago
--					and a.monto_pag > 0
					and a.monto_pag <> (
						select b.monto_pag
						from bdicred:sd_detcomirev b
						where b.empresa = a.empresa
						and b.num_credito = a.num_credito
						and b.fecha_alta = a.fecha_alta
--						and b.monto_pag > 0
						and b.folio = r_folio
						and b.cod_comis = a.cod_comis
					)
					
					-- Presenta Principal por Cuota segun el detalle de Credito
					select sum(a.monto_real_pag)
					into r_monto_cuota_principal
					from bdicred:sd_pagocapit a
					where a.empresa = pempresa
					and a.num_credito = r_num_credito
					and a.fecha_cuota = r_fecha_vencimiento
                              		and a.monto_real_pag > 0;
					if r_monto_cuota_principal is null then
						let r_monto_cuota_principal = 0;
					end if;

					select r_monto_cuota_principal - sum(a.monto_real_pag)
					into v_monto_temp
					from bdicred:sd_pagocapitrev a
					where a.empresa = pempresa
					and a.num_credito = r_num_credito
					and a.fecha_cuota = r_fecha_vencimiento
					and a.monto_real_pag > 0
					and a.folio = r_folio;
					if v_monto_temp is not null then
						let r_monto_cuota_principal = v_monto_temp;
					end if;

					-- Presenta Interes por Cuota segun el detalle de Credito
					select sum(a.monto_real_pag)
					into r_monto_cuota_interes
					from bdicred:sd_paginter a
					where a.empresa = pempresa
					and a.num_credito = r_num_credito
					and a.fecha_cuota = r_fecha_vencimiento
                              		and a.monto_real_pag > 0;
					if r_monto_cuota_interes is null then
						let r_monto_cuota_interes = 0;
					end if;
	
					select r_monto_cuota_interes - sum(a.monto_real_pag)
					into v_monto_temp
					from bdicred:sd_paginterrev a
					where a.empresa = pempresa
					and a.num_credito = r_num_credito
					and a.fecha_cuota = r_fecha_vencimiento
					and a.monto_real_pag > 0
					and a.folio = r_folio;
					if v_monto_temp is not null then
						let r_monto_cuota_interes = v_monto_temp;
					end if;

					-- Presenta Seguros por Cuota segun el detalle de Credito
					select sum(a.monto_pag)
					into r_monto_cuota_seguros
					from bdicred:sd_detcomi a
					where a.empresa = pempresa
					and a.num_credito = r_num_credito
					and a.fecha_alta = r_fecha_vencimiento
					and a.cod_comis in ('0101','0102','0103','0104','0105','0106')
					and a.monto_pag > 0;
					if r_monto_cuota_seguros is null then
						let r_monto_cuota_seguros = 0;
					end if;

					select r_monto_cuota_seguros - sum(a.monto_pag)
					into v_monto_temp
					from bdicred:sd_detcomirev a
					where a.empresa = pempresa
					and a.num_credito = r_num_credito
					and a.fecha_alta = r_fecha_vencimiento
					and a.cod_comis in ('0101','0102','0103','0104','0105','0106')
					and a.monto_pag > 0
					and a.folio = r_folio;
					if v_monto_temp is not null then
						let r_monto_cuota_seguros = v_monto_temp;
					end if;
					
					-- Presenta Moratorios por Couta segun el detalle de Credito
					select sum(a.sdo_mora_ordi)
					into r_monto_cuota_recargos
					from bdicred:sd_detmorarev a
					where a.empresa = pempresa
					and a.num_credito = r_num_credito
					and a.fecha_cuota = r_fecha_vencimiento
					and a.folio = r_folio; 
					if r_monto_cuota_recargos is null then
						let r_monto_cuota_recargos = 0;	
					end if;

					select r_monto_cuota_recargos - sum(a.sdo_mora_ordi)
					into v_monto_temp
					from bdicred:sd_detmora a
					where a.empresa = pempresa
					and a.num_credito = r_num_credito
					and a.fecha_cuota = r_fecha_vencimiento;
					if v_monto_temp is not null then
						let r_monto_cuota_recargos = v_monto_temp;
					end if;
					
					if r_monto_cuota_principal + r_monto_cuota_interes + r_monto_cuota_recargos + r_monto_cuota_seguros = 0 then
						continue foreach;
					end if;

					-- Presenta Informacion por Cuota
					return 	r_num_producto, r_num_credito, r_usuario, r_folio,
			       			r_monto_total_pago, r_monto_total_principal, r_monto_total_interes, r_monto_total_recargos, r_monto_total_seguros,
			       			r_fecha_pago, r_fecha_vencimiento,
			       			r_monto_cuota_principal, r_monto_cuota_interes, r_monto_cuota_recargos, r_monto_cuota_seguros with resume;
				end foreach;
		else	--Para Folios que no son el ultimo
				foreach 
					-- Presenta las fecha de los vencimientos de la cuotas afectadas por el ultimo folio
					select a.fecha_cuota
					into r_fecha_vencimiento
					from bdicred:sd_pagocapitrev a
					where a.empresa = pempresa
					and a.num_credito = r_num_credito
					and a.fecha_pago = r_fecha_pago
--                              		and a.monto_real_pag > 0
					and a.folio = v_folio_prox
					and a.monto_real_pag <> (
						select b.monto_real_pag
						from bdicred:sd_pagocapitrev b
						where b.empresa = a.empresa
						and b.num_credito = a.num_credito
						and b.fecha_cuota = a.fecha_cuota
--						and b.monto_real_pag > 0
						and b.folio = r_folio
					)
					union
					select a.fecha_cuota
					from bdicred:sd_paginterrev a
					where a.empresa = pempresa
					and a.num_credito = r_num_credito
					and a.fecha_pag = r_fecha_pago
--                              		and a.monto_real_pag > 0
					and a.folio = v_folio_prox
					and a.monto_real_pag <> (
						select b.monto_real_pag
						from bdicred:sd_paginterrev b
						where b.empresa = a.empresa
						and b.num_credito = a.num_credito
						and b.fecha_cuota = a.fecha_cuota
--						and b.monto_real_pag > 0
						and b.folio = r_folio
					)
					union
					select a.fecha_alta
					from bdicred:sd_detcomirev a
					where a.empresa = pempresa
					and a.num_credito = r_num_credito
					and a.fecha_pago = r_fecha_pago
--					and a.monto_pag > 0
					and a.folio = v_folio_prox
					and a.monto_pag <> (
						select b.monto_pag
						from bdicred:sd_detcomirev b
						where b.empresa = a.empresa
						and b.num_credito = a.num_credito
						and b.fecha_alta = a.fecha_alta
--						and b.monto_pag > 0
						and b.folio = r_folio
						and b.cod_comis = a.cod_comis
					)
					
					-- Presenta Principal por Cuota segun el detalle de Credito
					select sum(a.monto_real_pag)
					into r_monto_cuota_principal
					from bdicred:sd_pagocapitrev a
					where a.empresa = pempresa
					and a.num_credito = r_num_credito
					and a.fecha_cuota = r_fecha_vencimiento
                            		and a.monto_real_pag > 0
					and a.folio = v_folio_prox;
					if r_monto_cuota_principal is null then
						let r_monto_cuota_principal = 0;
					end if;

					select r_monto_cuota_principal - sum(a.monto_real_pag)
					into v_monto_temp
					from bdicred:sd_pagocapitrev a
					where a.empresa = pempresa
					and a.num_credito = r_num_credito
					and a.fecha_cuota = r_fecha_vencimiento
                            		and a.monto_real_pag > 0
					and a.folio = r_folio;
					if v_monto_temp is not null then
						let r_monto_cuota_principal = v_monto_temp;
					end if;

					-- Presenta Interes por Cuota segun el detalle de Credito
					select sum(a.monto_real_pag)
					into r_monto_cuota_interes
					from bdicred:sd_paginterrev a
					where a.empresa = pempresa
					and a.num_credito = r_num_credito
					and a.fecha_cuota = r_fecha_vencimiento
                            		and a.monto_real_pag > 0
					and a.folio = v_folio_prox;
					if r_monto_cuota_interes is null then
						let r_monto_cuota_interes = 0;
					end if;
	
					select r_monto_cuota_interes - sum(a.monto_real_pag)
					into v_monto_temp
					from bdicred:sd_paginterrev a
					where a.empresa = pempresa
					and a.num_credito = r_num_credito
					and a.fecha_cuota = r_fecha_vencimiento
                            		and a.monto_real_pag > 0
					and a.folio = r_folio;
					if v_monto_temp is not null then
						let r_monto_cuota_interes = v_monto_temp;
					end if;

					-- Presenta Seguros por Cuota segun el detalle de Credito
					select sum(a.monto_pag)
					into r_monto_cuota_seguros
					from bdicred:sd_detcomirev a
					where a.empresa = pempresa
					and a.num_credito = r_num_credito
					and a.fecha_alta = r_fecha_vencimiento
					and a.cod_comis in ('0101','0102','0103','0104','0105','0106')
					and a.monto_pag > 0
					and a.folio = v_folio_prox;
					if r_monto_cuota_seguros is null then
						let r_monto_cuota_seguros = 0;
					end if;

					select r_monto_cuota_seguros - sum(a.monto_pag)
					into v_monto_temp
					from bdicred:sd_detcomirev a
					where a.empresa = pempresa
					and a.num_credito = r_num_credito
					and a.fecha_alta = r_fecha_vencimiento
					and a.cod_comis in ('0101','0102','0103','0104','0105','0106')
					and a.monto_pag > 0 
					and a.folio = r_folio;
					if v_monto_temp is not null then
						let r_monto_cuota_seguros = v_monto_temp;
					end if;
					
					-- Presenta Moratorios por Couta segun el detalle de Credito
					select sum(a.sdo_mora_ordi)
					into r_monto_cuota_recargos
					from bdicred:sd_detmorarev a
					where a.empresa = pempresa
					and a.num_credito = r_num_credito
					and a.fecha_cuota = r_fecha_vencimiento
					and a.folio = r_folio; 
					if r_monto_cuota_recargos is null then
						let r_monto_cuota_recargos = 0;	
					end if;

					select r_monto_cuota_recargos - sum(a.sdo_mora_ordi)
					into v_monto_temp
					from bdicred:sd_detmorarev a
					where a.empresa = pempresa
					and a.num_credito = r_num_credito
					and a.fecha_cuota = r_fecha_vencimiento
					and a.folio = v_folio_prox;
					if v_monto_temp is not null then
						let r_monto_cuota_recargos = v_monto_temp;
					end if;

					if r_monto_cuota_principal + r_monto_cuota_interes + r_monto_cuota_recargos + r_monto_cuota_seguros = 0 then
						continue foreach;
					end if;

					-- Presenta Informacion por Cuota
					return 	r_num_producto, r_num_credito, r_usuario, r_folio,
			       			r_monto_total_pago, r_monto_total_principal, r_monto_total_interes, r_monto_total_recargos, r_monto_total_seguros,
			       			r_fecha_pago, r_fecha_vencimiento,
			       			r_monto_cuota_principal, r_monto_cuota_interes, r_monto_cuota_recargos, r_monto_cuota_seguros with resume;
				end foreach;
		end if;
	end foreach;
end procedure;
create procedure "informix".sp_rcda_aperturas()
RETURNING CHAR(005) as cod_ret,
		  char(180) as mensaje;
		  
--declaracion de variables
/***********************************/
	DEFINE 	vusuario            	CHAR(8);
    DEFINE 	vtipo_reg           	INTEGER;
    DEFINE 	vempresa            	CHAR(3);
    DEFINE 	vsucursal           	CHAR(4);
    DEFINE 	vejecutivo          	CHAR(8);
    DEFINE 	vnombre             	CHAR(45);
    DEFINE 	vproducto           	CHAR(4);
    DEFINE 	vfechacierre        	CHAR(10);
    DEFINE 	vnumtdc             	INTEGER;
    DEFINE 	vmetanumtdc         	INTEGER;
    DEFINE 	vcumpmetatdc        	MONEY;	
	DEFINE  vmeta 					INTEGER;
	


	/**********************************/
	DEFINE  SQL_ERR          INTEGER;
	DEFINE  ISAM_ERR         INTEGER;
	DEFINE  ERROR_INFO       VARCHAR(80);
	DEFINE  P_COD_RET        VARCHAR(6);
	DEFINE  P_MENSAJE        VARCHAR(80);
	DEFINE  dFecha           Date;
	DEFINE  dFechafto        char(10);
	DEFINE  dFechaCorte      Date;
	DEFINE  dFechaAnt        Date;
	DEFINE  dFechaAnioAnt    Date;
	DEFINE  cFechaAnioAnt    char(06);
	DEFINE  dFechahoy        Date;
	DEFINE  dult_dia_mes     Date;
	DEFINE  dfechaantier     Date;
	DEFINE  iDiasMes         INTEGER;
	DEFINE  vpaso			 integer;	
	DEFINE  Val2			 integer;
		--variables 
	DEFINE cod_ret			char(04);
	DEFINE vmensaje			char(80);	


--control de errores 	
BEGIN
   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
      LET P_COD_RET    = SQL_ERR;
      LET P_MENSAJE  = ERROR_INFO || ' sp_rcda_proceso en paso ' || vpaso;
	  insert into mi_rptcierresucerror (fecha_cierre,estatus_ejec,codigo_error,desc_error )
	  select fecha_ant,'F',P_COD_RET, P_MENSAJE  from bdmis:mi_fechas;
      RETURN P_COD_RET, P_MENSAJE;
   END EXCEPTION;
   
  
   
--inicializacion
	let P_COD_RET = '000';
	let P_MENSAJE ='PROCESO EXITOSO';
	LET Val2 = 0;
   
--se obtienen las fechas de proceso   
   let vpaso = 0;  
  set isolation to dirty read;
   select fecha_ant,day(ult_dia_mes)::int, (fecha_ant-1), fecha_hoy, ult_dia_mes 
   into dFecha,iDiasMes, dfechaantier, dFechahoy, dult_dia_mes 
   from bdmis:mi_fechas;
   
	if (SELECT count(codigo_error) FROM mi_rptcierresucerror where fecha_cierre = dfecha and codigo_error = 001) > 0 then
	   return '001','fecha ya procesada';
	end if;
	
   Select  count(*) into Val2 from bdmis:mi_comportamiento where fecha = dFecha;
 
 let vpaso = 1;
 -- limpia la tabla mi_rptsolic al inicio del mes 
        if ( day(dFechahoy)::int) = 2 or ( day(dFechahoy)::int) = 02  then
			   --Se posiciona el truncate a la tabla del acumulado de solicitudes mensual al inicio del mes. 01/04/2012
				truncate table mi_rptsolic; 
		end if;
   
 let vpaso = 2;  
--se limpia la tabla temporal de paso   
   TRUNCATE table mi_tmpcierresuc;
   
	--aperturas de cuentas de captacion 
		execute procedure "informix".sp_bitacora_rcda('rcda_apertura_capt', 1)
		into cod_ret, vmensaje;
		if trim(cod_ret) <> '000' then
			return cod_ret ,vmensaje;
		end if;
	
 		insert into mi_tmpcierresuc(tipo,empresa,sucursal,ejecutivo,producto,num_ctasdia,monto_ctasdia)
		select 'APERD',chq.empresa,chq.sucursal,mae.ejecutivo,chq.producto,count(*),sum(chq.sdo_dia_ant) as monto
		from bdicheq:sc_maenoc mae,bdicheq:sc_maechq chq, bdicheq:sc_producto prod
		where mae.empresa = '001' and prod.empresa = chq.empresa and chq.cuenta = mae.cuenta and chq.producto not in ('1300','1800') 
		and prod.producto = chq.producto and mae.fecha_alta = dFecha and chq.status_cta <> "2"
		group by chq.empresa,chq.sucursal,mae.ejecutivo,chq.producto;  
		
		if Val2 = 0 then
		
		truncate table mi_tmpcomportamiento;
		
	        insert into bdmis:mi_tmpcomportamiento(num_sucursal,producto,apertura_cap,saldo_cap,fecha)
			select chq.sucursal, chq.producto,count(*),sum(chq.sdo_dia_ant) as monto,dFecha 
			from bdicheq:sc_maenoc mae,bdicheq:sc_maechq chq, bdicheq:sc_producto prod
			where mae.empresa = '001' and prod.empresa = chq.empresa and chq.cuenta = mae.cuenta and chq.producto not in ('1300','1800') 
			and prod.producto = chq.producto and mae.fecha_alta = dFecha and chq.status_cta <> "2"
			group by chq.sucursal, chq.producto;
			
			insert into bdmis:mi_tmpcomportamiento(num_sucursal,producto,apertura_cap,saldo_cap,fecha)
			select sucursal, cod_instrum,count(*)as conteo,sum(capital)as capital,dFecha from bdinvers:sv_maeinv
			where fecha_alta = dFecha  
			and empresa = '001'
			group by sucursal, cod_instrum;
		end if;
		
		
		execute procedure "informix".sp_bitacora_rcda('rcda_apertura_capt', 2)
		into cod_ret, vmensaje;
		if trim(cod_ret) <> '000' then
			return cod_ret ,vmensaje;
		end if;
		
		let vpaso = 3;
        -- CUENTAS PROAC o ahorre su cambio
		
		execute procedure "informix".sp_bitacora_rcda('rcda_apert_proac', 1)
		into cod_ret, vmensaje;
		if trim(cod_ret) <> '000' then
			return cod_ret ,vmensaje;
		end if;
		
        insert into mi_tmpcierresuc(tipo,empresa,sucursal,ejecutivo,producto,num_ctasdia,monto_ctasdia)
        select 'APERD', mae.empresa, proac.sucursal, mae.ejecutivo, '2300' as producto, count(*) , 0
        from bdicheq:sc_proac proac, bdicheq:sc_maenoc mae
        where mae.fecha_alta = dFecha and mae.empresa = '001' and cta_eje = mae.cuenta and  status_cta = 1 and        
        not exists(select * from mi_tmpcierresuc mi where mi.empresa = mae.empresa and mi.sucursal = proac.sucursal and 
        mi.ejecutivo = mae.ejecutivo and mi.producto = '2300')
        group by 1, mae.empresa, proac.sucursal, mae.ejecutivo, 5;	

		execute procedure "informix".sp_bitacora_rcda('rcda_apert_proac', 2)
		into cod_ret, vmensaje;
		if trim(cod_ret) <> '000' then
			return cod_ret ,vmensaje;
		end if;
		
		let vpaso = 4;
		--Aperturas de Cuentas de Pagares

		execute procedure "informix".sp_bitacora_rcda('rcda_apert_pagares', 1)
		into cod_ret, vmensaje;
		if trim(cod_ret) <> '000' then
			return cod_ret ,vmensaje;
		end if;		
		
		insert into mi_tmpcierresuc(tipo,empresa,sucursal,ejecutivo,producto,num_ctasdia,monto_ctasdia)
		select 'APERP',empresa,sucursal,promotor,cod_instrum,count(*),sum(capital)
	    from bdinvers:sv_maeinv
	    where fecha_alta = dFecha --and status_cta = '1' // se elimina condición para generar correctamente la información
	    and empresa = '001' group by 1,2,3,4,5;		
 
 		execute procedure "informix".sp_bitacora_rcda('rcda_apert_pagares', 2)
		into cod_ret, vmensaje;
		if trim(cod_ret) <> '000' then
			return cod_ret ,vmensaje;
		end if;
 
		let vpaso = 5;
		--****************Solicitudes de credito *****************
		-- INSERTA AL RCD LAS SOLICITUDES Y PRECALIFICACIONES REALIZADAS EN EL DÍA
		-- Y QUE NO HAN SIDO CONSIDERADAS EN EL MES
		
		execute procedure "informix".sp_bitacora_rcda('rcda_solicitudes', 1)
		into cod_ret, vmensaje;
		if trim(cod_ret) <> '000' then
			return cod_ret ,vmensaje;
		end if;
		
        BEGIN WORK;           
			 select empresa, sucursal, user_insert, num_solicitud, '6001' as num_producto, numcte, '' as num_referencia,fecha_insert
                from bdisolic:ss_solicitudes sol
                where fecha_insert = dFecha AND (num_producto not in ('6500') or user_insert = 'interact') AND  --today /*dFecha o dFechafto */
                     numcte not in (SELECT rpt.numcte FROM mi_rptsolic rpt
                                     WHERE rpt.numcte = sol.numcte and rpt.sucursal = sol.sucursal)
                                 and num_solicitud = ( Select min(num_solicitud) from bdisolic:ss_solicitudes soli2  
                                 where fecha_insert = dFecha and soli2.numcte = sol.numcte 
                                 and soli2.num_producto = sol.num_producto and soli2.status_solicitud = sol.status_solicitud and soli2.sucursal = sol.sucursal )
			
			union all
            select empresa, sucursal, ejecutivo as user_insert, '' as num_solicitud, '6001' as num_producto,'' as numcte, num_referencia, fecha
                from bdisolic:ss_bitacora_precal precal
                where fecha  = dFecha AND (producto not in ('6500') or ejecutivo = 'interact' )  AND --today /*dFecha o dFechafto */
                      num_referencia not in (SELECT rpt.num_referencia FROM mi_rptsolic rpt
                                             WHERE rpt.num_referencia = precal.num_referencia and rpt.sucursal = precal.sucursal)
                and consecutivo = (SELECT min(consecutivo) FROM bdisolic:ss_bitacora_precal precali2 WHERE fecha  = dFecha AND precali2.num_referencia = precal.num_referencia
				and precali2.sucursal = precal.sucursal)
            into temp solicis with no log;
        COMMIT WORK;    
		
        let vpaso = 6;
		BEGIN WORK;
			select 'APERC' as tipo,empresa,sucursal,user_insert,num_producto, count(numcte) as num_ctasdia
				from bdmis:solicis
				where fecha_insert = dFecha and (numcte is not null or numcte <> '') and numcte > "000000000"
				group by 1,2,3,4,5
			union all
			select 'APERC' as tipo,empresa,sucursal,user_insert,num_producto,count(num_referencia) as num_ctasdia
				from bdmis:solicis
				where fecha_insert = dFecha and (num_referencia is not null or num_referencia <> '') and num_referencia > "0"
				group by 1,2,3,4,5
			into temp mi_rptsolic2 with no log;
		COMMIT WORK;

		let vpaso = 7;
        BEGIN WORK;
            insert into mi_tmpcierresuc(tipo,empresa,sucursal,ejecutivo,producto,num_ctasdia)
            select tipo,empresa,sucursal,user_insert,num_producto, sum(num_ctasdia) as num_ctasdia
            from mi_rptsolic2 group by tipo,empresa,sucursal,user_insert,num_producto;
        COMMIT WORK;

		   
		 let vpaso = 8;  
   		 insert into mi_rptsolic(empresa, sucursal, ejecutivo, num_producto, numcte, num_referencia, fecha_insert )
		 select empresa, sucursal, user_insert, num_producto, numcte, 		 
		  case when num_solicitud = '' then num_referencia  
			   when num_referencia = '' then num_solicitud
			   else '' end	as  num_referencia,		   
		 fecha_insert FROM bdmis:solicis
		 WHERE fecha_insert = dfecha;

		execute procedure "informix".sp_bitacora_rcda('rcda_solicitudes', 2)
		into cod_ret, vmensaje;
		if trim(cod_ret) <> '000' then
			return cod_ret ,vmensaje;
		end if;
		 
		 
		 let vpaso = 9;
		--tarjetas de credito entregadas 	

		execute procedure "informix".sp_bitacora_rcda('rcda_tdc_entregadas', 1)
		into cod_ret, vmensaje;
		if trim(cod_ret) <> '000' then
			return cod_ret ,vmensaje;
		end if;

		insert into mi_tmpcierresuc(tipo,empresa,sucursal,ejecutivo,producto,num_ctasdia)
		SELECT 'APERC' as tipo, empresa, sucursal, ejecutivo, '6666' as producto, sum (cantidad)  
		FROM table (multiset(
		select empresa,sucursal,ejecutivo ,count(*) as cantidad
		from bdicred:sd_maecred where fecha_apertura = dFecha and empresa = '001'
		group by 1,2,3
        union all
		select empresa,sucursal,ejecutivo,count(*) as cantidad
		from bdicred:sd_maecredcrd where fecha_apertura = dFecha and empresa = '001' and num_producto= '6300'
		group by 1,2,3/*
		union all
		select empresa,sucursal,user_insert as ejecutivo,count(*) as cantidad
		from bdinteg:si_adiccoppel where fechamov = dFecha and empresa = '001' 
		group by 1,2,3*/)) group by empresa, sucursal, ejecutivo;
		
		execute procedure "informix".sp_bitacora_rcda('rcda_tdc_entregadas', 2)
		into cod_ret, vmensaje;
		if trim(cod_ret) <> '000' then
			return cod_ret ,vmensaje;
		end if;		
		
		let vpaso = 10;
		--Abonos y retiros de  Captación
		
		execute procedure "informix".sp_bitacora_rcda('rcda_movs_capt', 1)
		into cod_ret, vmensaje;
		if trim(cod_ret) <> '000' then
			return cod_ret ,vmensaje;
		end if;		
		
		insert into mi_tmpcierresuc(tipo,producto,empresa,sucursal,ejecutivo,num_abonosctascap,monto_abonosctascap,num_retirocapta,monto_retirocapta)
	    select 'VENCA','9999',empresa,sucursal,usuario,sum(num_abonos),sum(sdo_abonos),sum(num_retiros),sum(sdo_retiros)
	    from table ( multiset(
					    select empresa,sucursal,usuario,
						nvl(case when tipo = 'ABONO' then num end,0) as num_abonos,
							nvl(case when tipo = 'ABONO' then saldo end,0) as sdo_abonos,
						nvl(case when tipo = 'DISPO' then num end,0) as num_retiros,
							nvl(case when tipo = 'DISPO' then saldo end,0) as sdo_retiros
						from table ( multiset (
									 select mov.empresa,mov.sucursal,mov.usuario,count(*) as num,sum(mov.monto_tot) as saldo,
											case when mov.transacc = '0223' then 'DISPO'
												when mov.transacc = '0202' then 'ABONO'
											end as tipo
									 from /*bdicheq:sc_movdia_apert*/ mi_rcda_movdeb mov,bdicheq:sc_maechq mae
									 where mov.empresa = '001' and mov.cuenta = mae.cuenta and mov.fech_alt = dFecha and mov.producto = mov.producto and mov.empresa = mae.empresa
									 and mov.transacc in ( '0223','0202') --and mov.cancelad <> 'S' -- ya lo filtra en sc_movdia_apert
									 group by 1,2,3,6))
					))
		group by 1,2,3,4,5;

		execute procedure "informix".sp_bitacora_rcda('rcda_movs_capt', 2)
		into cod_ret, vmensaje;
		if trim(cod_ret) <> '000' then
			return cod_ret ,vmensaje;
		end if;
		
		let vpaso = 11;
		--Calcular fecha del ultimo corte
		select max(fecha_emision) into dFechaCorte  from bdicred@pld_tcp:sd_encabezado2_edocta;

		let vpaso = 12;
		--Abonos y depositos de Credito
		
		execute procedure "informix".sp_bitacora_rcda('rcda_movs_cred', 1)
		into cod_ret, vmensaje;
		if trim(cod_ret) <> '000' then
			return cod_ret ,vmensaje;
		end if;			
		
/*		insert into mi_tmpcierresuc(tipo,producto,empresa,sucursal,ejecutivo,num_abonosctascred,monto_abonosctascred,num_retirocoloca,monto_retirocoloca, p_rec_vs_pagomin,p_rec_vs_vencido)
		select  'VENCO','9999',empresa,sucursal,usuario,num_abonos,sdo_abonos,num_retiros,sdo_retiros,
		  nvl(case when pagmin > 0 then ((pagvs / pagmin) * 100)::money end,0) as porce_pagmin,
		  nvl(case when pagven > 0 then  ((pagvs / pagven) * 100)::money end,0) as porce_pagven
		from table (multiset(
				 select empresa,sucursal,usuario,
					nvl(sum(case when tipo = 'ABONO' then num end),0) as num_abonos,
					nvl(sum(case when tipo = 'ABONO' then saldo end),0) as sdo_abonos,
					nvl(sum(case when tipo = 'DISPO' then num end),0) as num_retiros,
					nvl(sum(case when tipo = 'DISPO' then saldo end),0) as sdo_retiros,
					sum(case when tipo = 'ABONO' and (edo.sdo_pagar > 0 or (capital_ven_tc + interes_ven_tc + iva_interes_ven_tc + moratorios_tc + iva_moratorios_tc) > 0 )
					then saldo else 0  end) as pagvs,
					sum(case when tipo = 'ABONO'  then edo.sdo_pagar else 0  end) as pagmin,
					sum(case when tipo = 'ABONO'  then (capital_ven_tc + interes_ven_tc + iva_interes_ven_tc + moratorios_tc + iva_moratorios_tc)
					else 0 end) as pagven
				  from table( multiset(
								select  mov.empresa,mov.sucursal,mov.usuario,count(*) as num,num_credito,
								case when mov.codigo_fun = '033' and mov.codigo_ref = '1' then 'ABONO'
								     when mov.transacc_suc = '6900' then 'DISPO'
									  end as tipo,sum(mov.monto) as saldo
								from /*bdicred:sd_movhis*//* mi_rcda_movcred mov
								where mov.fecha_mov = dfecha and mov.empresa = '001' --and mov.reversado <> 'S' and mov.usuario <> 'interact'
								and ((mov.codigo_fun = '033' and mov.codigo_ref = '1') or  (mov.transacc_suc = '6900'))
								group by 1,2,3,5,6
								order by 1,2,3
							)) as mov,outer bdicred:sd_encabezado2_edocta edo
									   where  edo.num_credito = mov.num_credito and fecha_emision = dFechaCorte
										group by 1,2,3));*/
										
--nuevo calculo de porcentaje de recuperacion contra pago vencido y pago minimo de operaciones en caja para colocación

			    select  mov.empresa,mov.sucursal,mov.usuario,num_credito,
				case when mov.codigo_fun = '033' and mov.codigo_ref = '1' then 'ABONO'
					 when mov.transacc_suc = '6900' then 'DISPO'
					  end as tipo,mov.monto as saldo
				from bdmis:mi_rcda_movcred mov
				where mov.empresa = '001' and ((mov.codigo_fun = '033' and mov.codigo_ref = '1') or  (mov.transacc_suc = '6900'))				
				order by 1,2,3
				into temp tmp_rcda_mov_cred with no log;
		
		
					--tabla temporal para extraccion de estados de cuenta
				select edo.num_credito, edo.sdo_pagar, edo.capital_ven_tc, edo.interes_ven_tc, edo.iva_interes_ven_tc,
				edo.moratorios_tc, edo.iva_moratorios_tc, mov.saldo							   
				from bdicred@pld_tcp:sd_encabezado2_edocta edo, tmp_rcda_mov_cred mov
				where  edo.num_credito = mov.num_credito and fecha_emision = dFechaCorte
				into temp tmp_rcda_edocta with no log;
				
                select mov.empresa,mov.sucursal,mov.usuario, mov.tipo, mov.num_credito,
                nvl((mov.saldo),0) as sdo_abono,
                nvl((edo.sdo_pagar),0) as pagmin,		
                nvl(((edo.capital_ven_tc + edo.interes_ven_tc + edo.iva_interes_ven_tc + edo.moratorios_tc + edo.iva_moratorios_tc)), 0) as pagven				
                from tmp_rcda_mov_cred mov , tmp_rcda_edocta edo
                where edo.num_credito = mov.num_credito and edo.saldo = mov.saldo and 
                edo.sdo_pagar > 0  and mov.tipo = 'ABONO'              
                into temp tmp_rcda_pagmin with no log;		
		
				--Abonos de  capital vencido
				select mov.empresa,mov.sucursal,mov.usuario, mov.tipo, mov.num_credito,
				nvl((case when mov.tipo = 'ABONO' then mov.saldo end),0) as sdo_abono,						   
				nvl((case when mov.tipo = 'ABONO'  then 
				(edo.capital_ven_tc + edo.interes_ven_tc + edo.iva_interes_ven_tc + edo.moratorios_tc + edo.iva_moratorios_tc) end), 0) as pagven               
				from tmp_rcda_mov_cred mov , tmp_rcda_edocta edo				   
				where edo.num_credito = mov.num_credito and edo.saldo = mov.saldo and
				(edo.capital_ven_tc + edo.interes_ven_tc + edo.iva_interes_ven_tc + edo.moratorios_tc + edo.iva_moratorios_tc) > 0 and
				mov.tipo = 'ABONO'
				--group by 1,2,3,4,5
				into temp tmp_rcda_pagven with no log;
				
				--disposiciones
				select mov.empresa,mov.sucursal,mov.usuario, mov.tipo,
				nvl(count(num_credito),0) as num,
				nvl(sum(saldo),0) as sdo
				from tmp_rcda_mov_cred mov 				
				group by 1,2,3,4
				into temp tmp_rcda_numsdo with no log;
				
				--porcentaje de pago minimo
			    select empresa, sucursal, usuario, tipo,
				(sum (				
				case when nvl( (((sdo_abono - pagven) / pagmin ) * 100)::money ,0) > 100 then 100::money 
				     when nvl( (((sdo_abono - pagven) / pagmin ) * 100)::money ,0) < 0   then 0  ::money 
				else nvl((((sdo_abono - pagven) / pagmin ) * 100)::money,0) end				
				) / count (num_credito)) ::money  as porce_pagmin 				
				from tmp_rcda_pagmin 
                group by 1,2,3,4
				into temp tmp_rcda_porcen_pagmin;				

				-- porcentaje de pago vencido
				select empresa, sucursal, usuario, tipo,
				(sum (
				case when  nvl(((sdo_abono / pagven) * 100)::money ,0) > 100 then 100::money 
				     when  nvl(((sdo_abono / pagven) * 100)::money ,0) < 0   then 0  ::money 
				else nvl(((sdo_abono / pagven) * 100)::money ,0) end				
				)/ count (num_credito)) ::money as porce_pagven	
				from  tmp_rcda_pagven
				group by 1,2,3,4
				into temp tmp_rcda_porcen_pagven;
				
				insert into mi_tmpcierresuc(tipo,producto,empresa,sucursal,ejecutivo,num_abonosctascred,monto_abonosctascred,num_retirocoloca,monto_retirocoloca, p_rec_vs_pagomin,p_rec_vs_vencido)
				select 'VENCO' as tipo, '9999' as producto, empresa, sucursal,usuario,
				nvl(sum (case when tipo =  'ABONO' then num end), 0) as num_abonosctascred,  
				nvl(sum (case when tipo =  'ABONO' then sdo end), 0) as monto_abonosctascred,
				nvl(sum (case when tipo =  'DISPO' then num end), 0) as num_retirocoloca,
				nvl(sum (case when tipo =  'DISPO' then sdo end), 0) as monto_retirocoloca,
				0.00 ::money as p_rec_vs_pagomin, 0.00 ::money as p_rec_vs_vencido
				from tmp_rcda_numsdo 
				group by 1,2,3,4,5;
				
				
				UPDATE mi_tmpcierresuc SET p_rec_vs_pagomin = (nvl((SELECT porce_pagmin FROM tmp_rcda_porcen_pagmin pm 
				WHERE pm.sucursal = mi_tmpcierresuc.sucursal and pm.usuario = mi_tmpcierresuc.ejecutivo),0)) ::money,
				p_rec_vs_vencido = (nvl((select porce_pagven from tmp_rcda_porcen_pagven pv where pv.sucursal = mi_tmpcierresuc.sucursal and pv.usuario = mi_tmpcierresuc.ejecutivo ),0)) ::money
				WHERE tipo = 'VENCO' AND producto ='9999' ;				
				
----------------------------------------------------------------------------------------------------------------------		

										
										
		execute procedure "informix".sp_bitacora_rcda('rcda_movs_cred', 2)
		into cod_ret, vmensaje;
		if trim(cod_ret) <> '000' then
			return cod_ret ,vmensaje;
		end if;		
		
		let vpaso = 13;
        -- Traspaso de informacion historica
		
		execute procedure "informix".sp_bitacora_rcda('rcda_tx_hist', 1)
		into cod_ret, vmensaje;
		if trim(cod_ret) <> '000' then
			return cod_ret ,vmensaje;
		end if;		
		
        insert into mi_rptcierresuchis(empresa,sucursal,ejecutivo,nombre,producto,fecha_cierre, num_ctasdia,meta_ctasdia,p_cumpmetactas,monto_ctasdia,monto_incrementodia,meta_incremento,
		p_cumpsaldo,num_abonosctascap,monto_abonosctascap,num_abonosctascred,monto_abonosctascred, p_rec_vs_pagomin,p_rec_vs_vencido,num_clientel_act,num_compago,num_acuerdopago,num_cons_edocta,
		num_retirocapta,monto_retirocapta,num_retirocoloca,monto_retirocoloca)
		select empresa,sucursal,ejecutivo,nombre,producto,fecha_cierre, num_ctasdia,meta_ctasdia,p_cumpmetactas,monto_ctasdia,monto_incrementodia,meta_incremento,
		p_cumpsaldo,num_abonosctascap,monto_abonosctascap,num_abonosctascred,monto_abonosctascred, p_rec_vs_pagomin,p_rec_vs_vencido,num_clientel_act,num_compago,num_acuerdopago,num_cons_edocta,
		num_retirocapta,monto_retirocapta,num_retirocoloca,monto_retirocoloca from mi_rptcierresuc;

		execute procedure "informix".sp_bitacora_rcda('rcda_tx_hist', 2)
		into cod_ret, vmensaje;
		if trim(cod_ret) <> '000' then
			return cod_ret ,vmensaje;
		end if;				
		
		
		
	
	RETURN P_COD_RET, P_MENSAJE;	
END
end procedure;
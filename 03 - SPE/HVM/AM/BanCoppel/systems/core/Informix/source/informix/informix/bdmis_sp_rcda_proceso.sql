create procedure "informix".sp_rcda_proceso()
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
   
--se obtienen las fechas de proceso   
   let vpaso = 0;  
  set isolation to dirty read;
   select fecha_ant,day(ult_dia_mes)::int, (fecha_ant-1), fecha_hoy, ult_dia_mes 
   into dFecha,iDiasMes, dfechaantier, dFechahoy, dult_dia_mes 
   from bdmis:mi_fechas;
   
   			if (SELECT count(codigo_error) FROM mi_rptcierresucerror where fecha_cierre = dfecha and codigo_error = 001) > 0 then
			   return '001','fecha ya procesada';
			end if	
 
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
 		insert into mi_tmpcierresuc(tipo,empresa,sucursal,ejecutivo,producto,num_ctasdia,monto_ctasdia)
		select 'APERD',chq.empresa,chq.sucursal,mae.ejecutivo,chq.producto,count(*),sum(chq.sdo_dia_ant) as monto
		from bdicheq:sc_maenoc mae,bdicheq:sc_maechq chq, bdicheq:sc_producto prod
		where mae.empresa = '001' and prod.empresa = chq.empresa and chq.cuenta = mae.cuenta and chq.producto not in ('1300','1800') 
		and prod.producto = chq.producto and mae.fecha_alta = dFecha and chq.status_cta <> "2"
		group by chq.empresa,chq.sucursal,mae.ejecutivo,chq.producto;  
		
		let vpaso = 3;
        -- CUENTAS PROAC o ahorre su cambio
        insert into mi_tmpcierresuc(tipo,empresa,sucursal,ejecutivo,producto,num_ctasdia,monto_ctasdia)
        select 'APERD', mae.empresa, proac.sucursal, mae.ejecutivo, '2300' as producto, count(*) , 0
        from bdicheq:sc_proac proac, bdicheq:sc_maenoc mae
        where mae.fecha_alta = dFecha and mae.empresa = '001' and cta_eje = mae.cuenta and  status_cta = 1 and        
        not exists(select * from mi_tmpcierresuc mi where mi.empresa = mae.empresa and mi.sucursal = proac.sucursal and 
        mi.ejecutivo = mae.ejecutivo and mi.producto = '2300')
        group by 1, mae.empresa, proac.sucursal, mae.ejecutivo, 5;	
		
		let vpaso = 4;
		--Aperturas de Cuentas de Pagares
		insert into mi_tmpcierresuc(tipo,empresa,sucursal,ejecutivo,producto,num_ctasdia,monto_ctasdia)
		select 'APERP',empresa,sucursal,promotor,cod_instrum,count(*),sum(capital)
	    from bdinvers:sv_maeinv
	    where fecha_alta = dFecha --and status_cta = '1' // se elimina condición para generar correctamente la información
	    and empresa = '001' group by 1,2,3,4,5;		
 
		let vpaso = 5;
		--****************Solicitudes de credito *****************
		-- INSERTA AL RCD LAS SOLICITUDES Y PRECALIFICACIONES REALIZADAS EN EL DÍA
		-- Y QUE NO HAN SIDO CONSIDERADAS EN EL MES
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
		 
		 let vpaso = 9;
		--tarjetas de credito entregadas 		
		insert into mi_tmpcierresuc(tipo,empresa,sucursal,ejecutivo,producto,num_ctasdia)
		select 'APERC',empresa,sucursal,ejecutivo,'6666',count(*)
		from bdicred:sd_maecred where fecha_apertura = dFecha and empresa = '001'
		group by 1,2,3,4; 
		
		let vpaso = 10;
		--Abonos y retiros de  Captación
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
									 from bdicheq:sc_movdia_apert mov,bdicheq:sc_maechq mae
									 where mov.empresa = '001' and mov.cuenta = mae.cuenta and mov.fech_alt = dFecha and mov.producto = mov.producto and mov.empresa = mae.empresa
									 and mov.transacc in ( '0223','0202') --and mov.cancelad <> 'S' -- ya lo filtra en sc_movdia_apert
									 group by 1,2,3,6))
					))
		group by 1,2,3,4,5;
		
		let vpaso = 11;
		--Calcular fecha del ultimo corte
		select max(fecha_emision) into dFechaCorte  from bdicred:sd_encabezado2_edocta;

		let vpaso = 12;
		--Abonos y depositos de Credito
		insert into mi_tmpcierresuc(tipo,producto,empresa,sucursal,ejecutivo,num_abonosctascred,monto_abonosctascred,num_retirocoloca,monto_retirocoloca, p_rec_vs_pagomin,p_rec_vs_vencido)
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
								from bdicred:sd_movhis mov
								where mov.fecha_mov = dFecha and mov.empresa = '001' and mov.reversado <> 'S' and mov.usuario <> 'interact'
								and ((mov.codigo_fun = '033' and mov.codigo_ref = '1') or  (mov.transacc_suc = '6900'))
								group by 1,2,3,5,6
								order by 1,2,3
							)) as mov,outer bdicred:sd_encabezado2_edocta edo
									   where  edo.num_credito = mov.num_credito and fecha_emision = dFechaCorte
										group by 1,2,3));
		
		let vpaso = 13;
        -- Traspaso de informacion historica
        insert into mi_rptcierresuchis(empresa,sucursal,ejecutivo,nombre,producto,fecha_cierre, num_ctasdia,meta_ctasdia,p_cumpmetactas,monto_ctasdia,monto_incrementodia,meta_incremento,
		p_cumpsaldo,num_abonosctascap,monto_abonosctascap,num_abonosctascred,monto_abonosctascred, p_rec_vs_pagomin,p_rec_vs_vencido,num_clientel_act,num_compago,num_acuerdopago,num_cons_edocta,
		num_retirocapta,monto_retirocapta,num_retirocoloca,monto_retirocoloca)
		select empresa,sucursal,ejecutivo,nombre,producto,fecha_cierre, num_ctasdia,meta_ctasdia,p_cumpmetactas,monto_ctasdia,monto_incrementodia,meta_incremento,
		p_cumpsaldo,num_abonosctascap,monto_abonosctascap,num_abonosctascred,monto_abonosctascred, p_rec_vs_pagomin,p_rec_vs_vencido,num_clientel_act,num_compago,num_acuerdopago,num_cons_edocta,
		num_retirocapta,monto_retirocapta,num_retirocoloca,monto_retirocoloca from mi_rptcierresuc;

	
	RETURN P_COD_RET, P_MENSAJE;	
END
end procedure;
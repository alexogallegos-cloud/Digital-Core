create procedure "informix".sp_reproceso_22102012()
returning char (05) as cod_ret,
	   char (80) as mensaje;
	   
	--variables de retorno
	DEFINE cod_ret 		char (05);
	DEFINE VMENSAJE		CHAR (80);
	
	
	-- variables de proceso
	DEFINE  dFechaCorte      Date;
	
	--variables de control de errores
	DEFINE  SQL_ERR          INTEGER;
	DEFINE  ISAM_ERR         INTEGER;
	DEFINE  ERROR_INFO       VARCHAR(80);

	
begin	

   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
    if SQL_ERR <> 0 then
      LET cod_ret    = SQL_ERR;
      LET VMENSAJE  = ERROR_INFO ;
	  RETURN cod_ret, VMENSAJE;
	end if	   
   END EXCEPTION;
   
      
   let cod_ret = '000';
   let vmensaje = 'OK';
   
   set isolation to dirty read;
	-- CEPILLADO DE TABLA mi_tmpcierresuc

	    TRUNCATE TABLE mi_tmpcierresuc;		
	
	--	EXTRACION DE MOVIMIENTOS DIARIOS DEL DIA
	
	    --APERTURAS DE CUENTAS DE CAPTACIÓN
	
	 	insert into mi_tmpcierresuc(tipo,empresa,sucursal,ejecutivo,producto,num_ctasdia,monto_ctasdia)
		select 'APERD',chq.empresa,chq.sucursal,mae.ejecutivo,chq.producto,count(*),sum(chq.sdo_dia_ant) as monto
		from bdicheq:sc_maenoc mae,bdicheq:sc_maechq chq, bdicheq:sc_producto prod
		where mae.empresa = '001' and prod.empresa = chq.empresa and chq.cuenta = mae.cuenta and chq.producto not in ('1300','1800') 
		and prod.producto = chq.producto and mae.fecha_alta = '10/20/2012' and chq.status_cta <> "2"
		group by chq.empresa,chq.sucursal,mae.ejecutivo,chq.producto; 
	
	-- INSERCION DE CUENTAS PROACTIVAS 
	
	    insert into mi_tmpcierresuc(tipo,empresa,sucursal,ejecutivo,producto,num_ctasdia,monto_ctasdia)
        select 'APERD', mae.empresa, proac.sucursal, mae.ejecutivo, '2300' as producto, count(*) , 0
        from bdicheq:sc_proac proac, bdicheq:sc_maenoc mae
        where mae.fecha_alta = '10/20/2012' and mae.empresa = '001' and cta_eje = mae.cuenta and  status_cta = 1 and        
        not exists(select * from mi_tmpcierresuc mi where mi.empresa = mae.empresa and mi.sucursal = proac.sucursal and 
        mi.ejecutivo = mae.ejecutivo and mi.producto = '2300')
        group by 1, mae.empresa, proac.sucursal, mae.ejecutivo, 5;
		
	-- INSERCION DE CUENTAS DE PAGARES.

		insert into mi_tmpcierresuc(tipo,empresa,sucursal,ejecutivo,producto,num_ctasdia,monto_ctasdia)
		select 'APERP',empresa,sucursal,promotor,cod_instrum,count(*),sum(capital)
	    from bdinvers:sv_maeinv
	    where fecha_alta = '10/20/2012' --and status_cta = '1' // se elimina condición para generar correctamente la información
	    and empresa = '001' group by 1,2,3,4,5;			
	
	-- SOLICITUDES
	
	        BEGIN WORK;           
			 select empresa, sucursal, user_insert, num_solicitud, '6001' as num_producto, numcte, '' as num_referencia,fecha_insert
                from bdisolic:ss_solicitudes sol
                where fecha_insert = '10/20/2012' AND (num_producto not in ('6500') or user_insert = 'interact') AND  --today /*'10/20/2012' o '10/20/2012'fto */
                     numcte not in (SELECT rpt.numcte FROM mi_rptsolic rpt
                                     WHERE rpt.numcte = sol.numcte and rpt.sucursal = sol.sucursal and rpt.fecha_insert < '10/20/2012' )
                                 and num_solicitud = ( Select min(num_solicitud) from bdisolic:ss_solicitudes soli2  
                                 where fecha_insert = '10/20/2012' and soli2.numcte = sol.numcte 
                                 and soli2.num_producto = sol.num_producto and soli2.status_solicitud = sol.status_solicitud and soli2.sucursal = sol.sucursal )
			
			union all
            select empresa, sucursal, ejecutivo as user_insert, '' as num_solicitud, '6001' as num_producto,'' as numcte, num_referencia, fecha
                from bdisolic:ss_bitacora_precal precal
                where fecha  = '10/20/2012' AND (producto not in ('6500') or ejecutivo = 'interact' )  AND --today /*'10/20/2012' o '10/20/2012'fto */
                      num_referencia not in (SELECT rpt.num_referencia FROM mi_rptsolic rpt
                                             WHERE rpt.num_referencia = precal.num_referencia and rpt.sucursal = precal.sucursal and rpt.fecha_insert < '10/20/2012' )
                and consecutivo = (SELECT min(consecutivo) FROM bdisolic:ss_bitacora_precal precali2 WHERE fecha  = '10/20/2012' AND precali2.num_referencia = precal.num_referencia
				and precali2.sucursal = precal.sucursal)
            into temp solicis with no log;
			COMMIT WORK;   
		
	--
	
		BEGIN WORK;
			select 'APERC' as tipo,empresa,sucursal,user_insert,num_producto, count(numcte) as num_ctasdia
				from bdmis:solicis
				where fecha_insert = '10/20/2012' and (numcte is not null or numcte <> '') and numcte > "000000000"
				group by 1,2,3,4,5
			union all
			select 'APERC' as tipo,empresa,sucursal,user_insert,num_producto,count(num_referencia) as num_ctasdia
				from bdmis:solicis
				where fecha_insert = '10/20/2012' and (num_referencia is not null or num_referencia <> '') and num_referencia > "0"
				group by 1,2,3,4,5
			into temp mi_rptsolic2 with no log;
		COMMIT WORK;
		
		
		BEGIN WORK;
            insert into mi_tmpcierresuc(tipo,empresa,sucursal,ejecutivo,producto,num_ctasdia)
            select tipo,empresa,sucursal,user_insert,num_producto, sum(num_ctasdia) as num_ctasdia
            from mi_rptsolic2 group by tipo,empresa,sucursal,user_insert,num_producto;
        COMMIT WORK;
		
		insert into mi_rptsolic(empresa, sucursal, ejecutivo, num_producto, numcte, num_referencia, fecha_insert )
		 select empresa, sucursal, user_insert, num_producto, numcte, 		 
		  case when num_solicitud = '' then num_referencia  
			   when num_referencia = '' then num_solicitud
			   else '' end	as  num_referencia,		   
		 fecha_insert FROM bdmis:solicis
		 WHERE fecha_insert = '10/20/2012';
		 
	--tarjetas de credito entregadas 	

		insert into mi_tmpcierresuc(tipo,empresa,sucursal,ejecutivo,producto,num_ctasdia)
		select 'APERC',empresa,sucursal,ejecutivo,'6666',count(*)
		from bdicred:sd_maecred where fecha_apertura = '10/20/2012' and empresa = '001'
		group by 1,2,3,4; 
		
    --abonos y retiros de 		

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
									 from bdicheq:sc_movhis mov,bdicheq:sc_maechq mae
									 where mov.empresa = '001' and mov.cuenta = mae.cuenta and mov.fech_alt = '10/20/2012' and mov.producto = mov.producto and mov.empresa = mae.empresa
									 and mov.transacc in ( '0223','0202') and mov.cancelad <> 'S' and mov.usuario <> 'interact'
									 group by 1,2,3,6))
					))
		group by 1,2,3,4,5;
		
		
		select max(fecha_emision) into dFechaCorte  from bdicred:sd_encabezado2_edocta;
		
		
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
								where mov.fecha_mov = '10/20/2012' and mov.empresa = '001' and mov.reversado <> 'S' and mov.usuario <> 'interact'
								and ((mov.codigo_fun = '033' and mov.codigo_ref = '1') or  (mov.transacc_suc = '6900'))
								group by 1,2,3,5,6
								order by 1,2,3
							)) as mov,outer bdicred:sd_encabezado2_edocta edo
									   where  edo.num_credito = mov.num_credito and fecha_emision = dFechaCorte
										group by 1,2,3));			
				
												
		--Nuevo calculo de porcentaje obteniendo las metas divididas entre numero de promotores por sucursal LAGS - 17/01/2012
		set isolation to dirty read;
		select num_sucursal,
		(meta_acu_cap +  ((metasuc.meta_men_cap / 30.5) * day('10/20/2012')))::money / nvl (num,1) as metacapdia,     
		(meta_acu_col +  ((meta_men_col / 30.5) * day('10/20/2012')))::money   as metacoldia
			   from table ( multiset (
									select metasuc1.num_sucursal , metasuc1.id_tiposuc, ejec.num, meta_acu_cap, meta_acu_col, meta_men_cap, meta_men_col                    
								   from table ( multiset (
									select li.num_sucursal,tpo.id_tiposuc,
									sum(case when tpo.aniomes[5,6] < MONTH('10/20/2012') then meta_monto_cap else 0 end) as meta_acu_cap,
									sum(case when tpo.aniomes[5,6] < MONTH('10/20/2012') then meta_monto_col else 0 end) as meta_acu_col,
									sum(case when tpo.aniomes[5,6] = MONTH('10/20/2012') then meta_monto_cap else 0 end) as meta_men_cap,
									sum(case when tpo.aniomes[5,6] = MONTH('10/20/2012') then meta_monto_col else 0 end) as meta_men_col
									from mi_sucursalesinfo li,mi_tiposuc tpo
									where tpo.id_tiposuc = tipo_suc and tpo.aniomes[1,4] = YEAR('10/20/2012')  and  tpo.aniomes[5,6] <= MONTH('10/20/2012')                            
									 group by 1,2
									)) as metasuc1, table ( multiset ( 
									select sucursal , count(ejecutivo) as num from bdinteg:si_ejecut where password <> 'BAJA' and puesto = '003' GROUP BY sucursal)) 							
									as ejec where metasuc1.num_sucursal = ejec.sucursal))as metasuc
									into temp metaprod WITH NO LOG;  	

		
		insert into mi_rptcierresuchis(empresa,sucursal,ejecutivo,nombre,producto,fecha_cierre,num_ctasdia,
		monto_ctasdia,p_cumpmetactas,meta_ctasdia,
		monto_incrementodia,meta_incremento,p_cumpsaldo,num_abonosctascap,monto_abonosctascap,num_abonosctascred,
		monto_abonosctascred,p_rec_vs_pagomin,p_rec_vs_vencido,num_clientel_act,num_compago,num_acuerdopago,num_cons_edocta,
	    num_retirocapta,monto_retirocapta,num_retirocoloca,monto_retirocoloca)
            select  tmp.empresa,tmp.sucursal,tmp.ejecutivo,si.nombre,tmp.producto,'10/20/2012',num_ctasdia,monto_ctasdia,
            nvl((case when num_ctasdia > 0 and mp.metanum > 0 then ((num_ctasdia / mp.metanum) * 100) else 0 end)::money,0) as p_cumpmetactas,
            nvl(MP.METANUM,0) as meta_numero,nvl((monto_incrementodia )::money,0) as  monto_incrementodia,
            nvl(CASE WHEN tmp.producto IN (select num_producto from bdmis:mi_producto where num_sistema = 1) THEN metacapdia
                     WHEN tmp.producto IN (select num_producto from bdmis:mi_producto where num_sistema = 3) THEN metacapdia
                     WHEN tmp.producto IN (select num_producto from bdmis:mi_producto where num_sistema = 6) THEN metacoldia END,0) AS meta_monto,
            nvl((case when monto_incrementodia > 0  and (CASE WHEN tmp.producto IN (select producto  from bdicheq: sc_producto) THEN meta_monto_cap
                                             WHEN tmp.producto IN (select num_producto from bdmis:mi_producto where num_sistema = 3) THEN metacapdia
                                             WHEN tmp.producto IN (select num_producto from bdmis:mi_producto where num_sistema = 6) THEN metacoldia END) > 0 then (((monto_incrementodia ) / (CASE WHEN tmp.producto IN (select num_producto from bdmis:mi_producto where num_sistema = 1) THEN meta_monto_cap
                                             WHEN tmp.producto IN (select num_producto from bdmis:mi_producto where num_sistema = 3) THEN metacapdia
                                             WHEN tmp.producto IN (select num_producto from bdmis:mi_producto where num_sistema = 6) THEN metacoldia END)) * 100) else 0 end)::money,0)  as    p_cumpsaldo,
            num_abonosctascap, monto_abonosctascap,num_abonosctascred,monto_abonosctascred, p_rec_vs_pagomin,p_rec_vs_vencido,num_clientel_act,num_compago,
            num_acuerdopago,num_cons_edocta,num_retirocapta,monto_retirocapta, num_retirocoloca,monto_retirocoloca
                        from table (multiset(
									select tmp.empresa, tmp.sucursal,tmp.ejecutivo,tmp.producto,
											sum(tmp.num_ctasdia) as num_ctasdia ,sum(tmp.meta_ctasdia) as meta_ctasdia ,sum(tmp.monto_ctasdia) as monto_ctasdia,
											sum(tmp.monto_incrementodia) as monto_incrementodia ,sum(tmp.p_cumpsaldo) as p_cumpsaldo,sum(tmp.num_abonosctascap) as num_abonosctascap,
											sum(tmp.monto_abonosctascap) as monto_abonosctascap,sum(tmp.num_abonosctascred) as num_abonosctascred,sum(tmp.monto_abonosctascred) as monto_abonosctascred,
											sum(tmp.p_rec_vs_pagomin) as p_rec_vs_pagomin,sum(tmp.p_rec_vs_vencido) as p_rec_vs_vencido,sum(tmp.num_clientel_act) as num_clientel_act,sum(tmp.num_compago) as num_compago,
											sum(tmp.num_acuerdopago) as num_acuerdopago,sum(tmp.num_cons_edocta) as num_cons_edocta ,
											sum(tmp.num_retirocapta) as num_retirocapta,sum(tmp.monto_retirocapta) as monto_retirocapta,sum(tmp.num_retirocoloca) as num_retirocoloca,sum(tmp.monto_retirocoloca) as monto_retirocoloca
											from mi_tmpcierresuc tmp
											group by  1,2,3,4
                                                            )) tmp,---*** MI_SUCURSALESINFO (TIENE EL TIPO DE SUCURSAL EL CUAL SIRVE PARA BUSCAR EL NUMERO Y EL MONTO DE LAS METAS)
        bdinteg:si_ejecut si, bdmis:mi_sucursalesinfo suc,  outer bdmis:mi_metasprod mp, outer bdmis:mi_tiposuc ts, metaprod        ----****  MI_METASPROD  (SIRVE PARAOBTENER EL NUMERO DE META POR MEDIO DE TIPO DE SUCURSAL Y PRODUCTO)        
		where si.ejecutivo = tmp.ejecutivo --and si.sucursal = tmp.sucursal 
		and si.empresa ='001'  ----****  MI_TIPOSUC  (SIRVE PARAOBTENER EL MONTO DE LA META DE CAPTACION O DE COLOCACION POR MEDIO DE TIPO DE SUCURSAL)
		AND TMP.SUCURSAL = SUC.NUM_SUCURSAL AND SUC.TIPO_SUC = MP.ID_TIPOSUC AND TMP.PRODUCTO = MP.PRODUCTO AND TS.ID_TIPOSUC = SUC.TIPO_SUC AND
		MP.ANIOMES = YEAR('10/20/2012') ||  LPAD( MONTH('10/20/2012'),2,'00') AND TS.ANIOMES = YEAR('10/20/2012') ||  LPAD(MONTH('10/20/2012'),2,'00') and  metaprod.num_sucursal = tmp.sucursal;
			
	return cod_ret, vmensaje;		
end		
end procedure

;
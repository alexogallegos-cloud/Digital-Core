create procedure "informix".sp_reproceso_tdce ()
returning char (05) as cod_ret,
		  char (80) as mensaje;
		  
	--variables de retorno	  
	Define cod_ret 	 char (05);
	Define vmensaje  char (80);
	
	--VARIABLES DE PROCESO
	
	  Define  vempresa             	CHAR(03) ;
      Define  vsucursal            	CHAR(04) ;
      Define  vejecutivo           	CHAR(08) ;    
      Define  vproducto            	CHAR(04) ;
      Define  vfecha_cierre        	DATE ;
	  Define  vnum_ctasdia			integer;
	-- variables de control de errores 
	  DEFINE  SQL_ERR          INTEGER;
	  DEFINE  ISAM_ERR         INTEGER;
	  DEFINE  ERROR_INFO       VARCHAR(80);

	  
--control de errores 

BEGIN
   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
     if SQL_ERR <> 0 then
		  LET cod_ret    = SQL_ERR;
		  LET vmensaje  = ERROR_INFO ;
		  RETURN cod_ret, vmensaje;
	 end if 
   END EXCEPTION;
	  
	
	let cod_ret  = '000' ;
	let vmensaje = 'OK';
	
	
	
--proceso del dia primero

		truncate table "informix".mi_tmpcierresuc;

		
		insert into mi_tmpcierresuc(tipo,empresa,sucursal,ejecutivo,producto,num_ctasdia)
		SELECT 'APERC' as tipo, empresa, sucursal, ejecutivo, '6666' as producto, sum (cantidad)  
		FROM table (multiset(
		select empresa,sucursal,user_insert as ejecutivo,count(*) as cantidad
		from bdinteg:si_adiccoppel where fechamov = '10/01/2012' and empresa = '001' 
		group by 1,2,3)) group by empresa, sucursal, ejecutivo;
		
		set isolation to dirty read;
		select num_sucursal,
		(meta_acu_cap +  ((metasuc.meta_men_cap / 30.5) * day('10/01/2012')))::money / nvl (num,1) as metacapdia,     
		(meta_acu_col +  ((meta_men_col / 30.5) * day('10/01/2012')))::money   as metacoldia
			   from table ( multiset (
									select metasuc1.num_sucursal , metasuc1.id_tiposuc, ejec.num, meta_acu_cap, meta_acu_col, meta_men_cap, meta_men_col                    
								   from table ( multiset (
									select li.num_sucursal,tpo.id_tiposuc,
									sum(case when tpo.aniomes[5,6] < MONTH('10/01/2012') then meta_monto_cap else 0 end) as meta_acu_cap,
									sum(case when tpo.aniomes[5,6] < MONTH('10/01/2012') then meta_monto_col else 0 end) as meta_acu_col,
									sum(case when tpo.aniomes[5,6] = MONTH('10/01/2012') then meta_monto_cap else 0 end) as meta_men_cap,
									sum(case when tpo.aniomes[5,6] = MONTH('10/01/2012') then meta_monto_col else 0 end) as meta_men_col
									from "informix".mi_sucursalesinfo li, "informix".mi_tiposuc tpo
									where tpo.id_tiposuc = tipo_suc and tpo.aniomes[1,4] = YEAR('10/01/2012')  and  tpo.aniomes[5,6] <= MONTH('10/01/2012')                            
									 group by 1,2
									)) as metasuc1, table ( multiset ( 
									select sucursal , count(ejecutivo) as num from bdinteg:si_ejecut where password <> 'BAJA' and puesto = '003' GROUP BY sucursal)) 							
									as ejec where metasuc1.num_sucursal = ejec.sucursal))as metasuc
									into temp metaprod WITH NO LOG; 	
									
									
		/*insert into "informix".mi_rptcierresuchis(empresa,sucursal,ejecutivo,nombre,producto,fecha_cierre,num_ctasdia,
		monto_ctasdia,p_cumpmetactas,meta_ctasdia,
		monto_incrementodia,meta_incremento,p_cumpsaldo,num_abonosctascap,monto_abonosctascap,num_abonosctascred,
		monto_abonosctascred,p_rec_vs_pagomin,p_rec_vs_vencido,num_clientel_act,num_compago,num_acuerdopago,num_cons_edocta,
	    num_retirocapta,monto_retirocapta,num_retirocoloca,monto_retirocoloca)*/
            select  tmp.empresa,tmp.sucursal,tmp.ejecutivo,si.nombre,tmp.producto,'10/01/2012' as fecha_cierre ,num_ctasdia,monto_ctasdia,
            nvl((case when num_ctasdia > 0 and mp.metanum > 0 then ((num_ctasdia / mp.metanum) * 100) else 0 end)::money,0) as p_cumpmetactas,
            nvl(MP.METANUM,0) as meta_ctasdia,nvl((monto_incrementodia )::money,0) as  monto_incrementodia,
            nvl(CASE WHEN tmp.producto IN (select num_producto from bdmis:"informix".mi_producto where num_sistema = 1) THEN metacapdia
                     WHEN tmp.producto IN (select num_producto from bdmis:"informix".mi_producto where num_sistema = 3) THEN metacapdia
                     WHEN tmp.producto IN (select num_producto from bdmis:"informix".mi_producto where num_sistema = 6) THEN metacoldia END,0) AS meta_incremento,
            nvl((case when monto_incrementodia > 0  and (CASE WHEN tmp.producto IN (select producto  from bdicheq:"informix".sc_producto) THEN meta_monto_cap
                                             WHEN tmp.producto IN (select num_producto from bdmis:"informix".mi_producto where num_sistema = 3) THEN metacapdia
                                             WHEN tmp.producto IN (select num_producto from bdmis:"informix".mi_producto where num_sistema = 6) THEN metacoldia END) > 0 then (((monto_incrementodia ) / (CASE WHEN tmp.producto IN (select num_producto from bdmis:mi_producto where num_sistema = 1) THEN meta_monto_cap
                                             WHEN tmp.producto IN (select num_producto from bdmis:"informix".mi_producto where num_sistema = 3) THEN metacapdia
                                             WHEN tmp.producto IN (select num_producto from bdmis:"informix".mi_producto where num_sistema = 6) THEN metacoldia END)) * 100) else 0 end)::money,0)  as    p_cumpsaldo,
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
        bdinteg:"informix".si_ejecut si, bdmis:"informix".mi_sucursalesinfo suc,  outer bdmis:"informix".mi_metasprod mp, outer bdmis:"informix".mi_tiposuc ts, metaprod        ----****  MI_METASPROD  (SIRVE PARAOBTENER EL NUMERO DE META POR MEDIO DE TIPO DE SUCURSAL Y PRODUCTO)        
		where si.ejecutivo = tmp.ejecutivo --and si.sucursal = tmp.sucursal 
		and si.empresa ='001'  ----****  MI_TIPOSUC  (SIRVE PARAOBTENER EL MONTO DE LA META DE CAPTACION O DE COLOCACION POR MEDIO DE TIPO DE SUCURSAL)
		AND TMP.SUCURSAL = SUC.NUM_SUCURSAL AND SUC.TIPO_SUC = MP.ID_TIPOSUC AND TMP.PRODUCTO = MP.PRODUCTO AND TS.ID_TIPOSUC = SUC.TIPO_SUC AND
		MP.ANIOMES = YEAR('10/01/2012') ||  LPAD( MONTH('10/01/2012'),2,'00') AND TS.ANIOMES = YEAR('10/01/2012') ||  LPAD(MONTH('10/01/2012'),2,'00') and  metaprod.num_sucursal = tmp.sucursal
		into temp tmp_mi_rptcierresuchis WITH NO LOG;
		
		
			FOREACH  cursor1 
			WITH HOLD for
				SELECT  ejecutivo,empresa,fecha_cierre,producto,sucursal,num_ctasdia
				INTO 	vejecutivo,vempresa,vfecha_cierre,vproducto,vsucursal, vnum_ctasdia
				FROM tmp_mi_rptcierresuchis 
				
				
				if (select count (*) from mi_rptcierresuchis where ejecutivo = vejecutivo  and empresa = vempresa  and fecha_cierre = vfecha_cierre
					and producto = vproducto and sucursal = vsucursal ) > 0  then
				
						UPDATE mi_rptcierresuchis SET num_ctasdia = (num_ctasdia + vnum_ctasdia)  WHERE ejecutivo = vejecutivo  and empresa = vempresa  and fecha_cierre = vfecha_cierre
							and producto = vproducto and sucursal = vsucursal;
				
				else
				
						insert into "informix".mi_rptcierresuchis(empresa,sucursal,ejecutivo,nombre,producto,fecha_cierre,num_ctasdia,
						monto_ctasdia,p_cumpmetactas,meta_ctasdia,
						monto_incrementodia,meta_incremento,p_cumpsaldo,num_abonosctascap,monto_abonosctascap,num_abonosctascred,
						monto_abonosctascred,p_rec_vs_pagomin,p_rec_vs_vencido,num_clientel_act,num_compago,num_acuerdopago,num_cons_edocta,
						num_retirocapta,monto_retirocapta,num_retirocoloca,monto_retirocoloca)
						SELECT empresa,sucursal,ejecutivo,nombre,producto,fecha_cierre,num_ctasdia,
						monto_ctasdia,p_cumpmetactas,meta_ctasdia,
						monto_incrementodia,meta_incremento,p_cumpsaldo,num_abonosctascap,monto_abonosctascap,num_abonosctascred,
						monto_abonosctascred,p_rec_vs_pagomin,p_rec_vs_vencido,num_clientel_act,num_compago,num_acuerdopago,num_cons_edocta,
						num_retirocapta,monto_retirocapta,num_retirocoloca,monto_retirocoloca
						FROM tmp_mi_rptcierresuchis 
						where ejecutivo = vejecutivo  and empresa = vempresa  and fecha_cierre = vfecha_cierre
							  and producto = vproducto and sucursal = vsucursal; 
						
				
				end if
				
			END FOREACH				
			
			
--reproceso de tarjetas de credito entregadas 02

		truncate table "informix".mi_tmpcierresuc;
		drop table tmp_mi_rptcierresuchis;
		drop table metaprod;

		
		insert into mi_tmpcierresuc(tipo,empresa,sucursal,ejecutivo,producto,num_ctasdia)
		SELECT 'APERC' as tipo, empresa, sucursal, ejecutivo, '6666' as producto, sum (cantidad)  
		FROM table (multiset(
		select empresa,sucursal,user_insert as ejecutivo,count(*) as cantidad
		from bdinteg:si_adiccoppel where fechamov = '10/02/2012' and empresa = '001' 
		group by 1,2,3)) group by empresa, sucursal, ejecutivo;
		
		set isolation to dirty read;
		select num_sucursal,
		(meta_acu_cap +  ((metasuc.meta_men_cap / 30.5) * day('10/02/2012')))::money / nvl (num,1) as metacapdia,     
		(meta_acu_col +  ((meta_men_col / 30.5) * day('10/02/2012')))::money   as metacoldia
			   from table ( multiset (
									select metasuc1.num_sucursal , metasuc1.id_tiposuc, ejec.num, meta_acu_cap, meta_acu_col, meta_men_cap, meta_men_col                    
								   from table ( multiset (
									select li.num_sucursal,tpo.id_tiposuc,
									sum(case when tpo.aniomes[5,6] < MONTH('10/02/2012') then meta_monto_cap else 0 end) as meta_acu_cap,
									sum(case when tpo.aniomes[5,6] < MONTH('10/02/2012') then meta_monto_col else 0 end) as meta_acu_col,
									sum(case when tpo.aniomes[5,6] = MONTH('10/02/2012') then meta_monto_cap else 0 end) as meta_men_cap,
									sum(case when tpo.aniomes[5,6] = MONTH('10/02/2012') then meta_monto_col else 0 end) as meta_men_col
									from "informix".mi_sucursalesinfo li, "informix".mi_tiposuc tpo
									where tpo.id_tiposuc = tipo_suc and tpo.aniomes[1,4] = YEAR('10/02/2012')  and  tpo.aniomes[5,6] <= MONTH('10/02/2012')                            
									 group by 1,2
									)) as metasuc1, table ( multiset ( 
									select sucursal , count(ejecutivo) as num from bdinteg:si_ejecut where password <> 'BAJA' and puesto = '003' GROUP BY sucursal)) 							
									as ejec where metasuc1.num_sucursal = ejec.sucursal))as metasuc
									into temp metaprod WITH NO LOG; 	
									
									
		/*insert into "informix".mi_rptcierresuchis(empresa,sucursal,ejecutivo,nombre,producto,fecha_cierre,num_ctasdia,
		monto_ctasdia,p_cumpmetactas,meta_ctasdia,
		monto_incrementodia,meta_incremento,p_cumpsaldo,num_abonosctascap,monto_abonosctascap,num_abonosctascred,
		monto_abonosctascred,p_rec_vs_pagomin,p_rec_vs_vencido,num_clientel_act,num_compago,num_acuerdopago,num_cons_edocta,
	    num_retirocapta,monto_retirocapta,num_retirocoloca,monto_retirocoloca)*/
            select  tmp.empresa,tmp.sucursal,tmp.ejecutivo,si.nombre,tmp.producto,'10/02/2012' as fecha_cierre ,num_ctasdia,monto_ctasdia,
            nvl((case when num_ctasdia > 0 and mp.metanum > 0 then ((num_ctasdia / mp.metanum) * 100) else 0 end)::money,0) as p_cumpmetactas,
            nvl(MP.METANUM,0) as meta_ctasdia,nvl((monto_incrementodia )::money,0) as  monto_incrementodia,
            nvl(CASE WHEN tmp.producto IN (select num_producto from bdmis:"informix".mi_producto where num_sistema = 1) THEN metacapdia
                     WHEN tmp.producto IN (select num_producto from bdmis:"informix".mi_producto where num_sistema = 3) THEN metacapdia
                     WHEN tmp.producto IN (select num_producto from bdmis:"informix".mi_producto where num_sistema = 6) THEN metacoldia END,0) AS meta_incremento,
            nvl((case when monto_incrementodia > 0  and (CASE WHEN tmp.producto IN (select producto  from bdicheq:"informix".sc_producto) THEN meta_monto_cap
                                             WHEN tmp.producto IN (select num_producto from bdmis:"informix".mi_producto where num_sistema = 3) THEN metacapdia
                                             WHEN tmp.producto IN (select num_producto from bdmis:"informix".mi_producto where num_sistema = 6) THEN metacoldia END) > 0 then (((monto_incrementodia ) / (CASE WHEN tmp.producto IN (select num_producto from bdmis:mi_producto where num_sistema = 1) THEN meta_monto_cap
                                             WHEN tmp.producto IN (select num_producto from bdmis:"informix".mi_producto where num_sistema = 3) THEN metacapdia
                                             WHEN tmp.producto IN (select num_producto from bdmis:"informix".mi_producto where num_sistema = 6) THEN metacoldia END)) * 100) else 0 end)::money,0)  as    p_cumpsaldo,
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
        bdinteg:"informix".si_ejecut si, bdmis:"informix".mi_sucursalesinfo suc,  outer bdmis:"informix".mi_metasprod mp, outer bdmis:"informix".mi_tiposuc ts, metaprod        ----****  MI_METASPROD  (SIRVE PARAOBTENER EL NUMERO DE META POR MEDIO DE TIPO DE SUCURSAL Y PRODUCTO)        
		where si.ejecutivo = tmp.ejecutivo --and si.sucursal = tmp.sucursal 
		and si.empresa ='001'  ----****  MI_TIPOSUC  (SIRVE PARAOBTENER EL MONTO DE LA META DE CAPTACION O DE COLOCACION POR MEDIO DE TIPO DE SUCURSAL)
		AND TMP.SUCURSAL = SUC.NUM_SUCURSAL AND SUC.TIPO_SUC = MP.ID_TIPOSUC AND TMP.PRODUCTO = MP.PRODUCTO AND TS.ID_TIPOSUC = SUC.TIPO_SUC AND
		MP.ANIOMES = YEAR('10/02/2012') ||  LPAD( MONTH('10/02/2012'),2,'00') AND TS.ANIOMES = YEAR('10/02/2012') ||  LPAD(MONTH('10/02/2012'),2,'00') and  metaprod.num_sucursal = tmp.sucursal
		into temp tmp_mi_rptcierresuchis WITH NO LOG;
		
		
			FOREACH  cursor1 
			WITH HOLD for
				SELECT  ejecutivo,empresa,fecha_cierre,producto,sucursal,num_ctasdia
				INTO 	vejecutivo,vempresa,vfecha_cierre,vproducto,vsucursal, vnum_ctasdia
				FROM tmp_mi_rptcierresuchis 
				
				
				if (select count (*) from mi_rptcierresuchis where ejecutivo = vejecutivo  and empresa = vempresa  and fecha_cierre = vfecha_cierre
					and producto = vproducto and sucursal = vsucursal ) > 0  then
				
						UPDATE mi_rptcierresuchis SET num_ctasdia = (num_ctasdia + vnum_ctasdia)  WHERE ejecutivo = vejecutivo  and empresa = vempresa  and fecha_cierre = vfecha_cierre
							and producto = vproducto and sucursal = vsucursal;
				
				else
				
						insert into "informix".mi_rptcierresuchis(empresa,sucursal,ejecutivo,nombre,producto,fecha_cierre,num_ctasdia,
						monto_ctasdia,p_cumpmetactas,meta_ctasdia,
						monto_incrementodia,meta_incremento,p_cumpsaldo,num_abonosctascap,monto_abonosctascap,num_abonosctascred,
						monto_abonosctascred,p_rec_vs_pagomin,p_rec_vs_vencido,num_clientel_act,num_compago,num_acuerdopago,num_cons_edocta,
						num_retirocapta,monto_retirocapta,num_retirocoloca,monto_retirocoloca)
						SELECT empresa,sucursal,ejecutivo,nombre,producto,fecha_cierre,num_ctasdia,
						monto_ctasdia,p_cumpmetactas,meta_ctasdia,
						monto_incrementodia,meta_incremento,p_cumpsaldo,num_abonosctascap,monto_abonosctascap,num_abonosctascred,
						monto_abonosctascred,p_rec_vs_pagomin,p_rec_vs_vencido,num_clientel_act,num_compago,num_acuerdopago,num_cons_edocta,
						num_retirocapta,monto_retirocapta,num_retirocoloca,monto_retirocoloca
						FROM tmp_mi_rptcierresuchis 
						where ejecutivo = vejecutivo  and empresa = vempresa  and fecha_cierre = vfecha_cierre
							  and producto = vproducto and sucursal = vsucursal; 
						
				
				end if
				
			END FOREACH		

--reproceso de tarjetas de credito entregadas 03

		truncate table "informix".mi_tmpcierresuc;
		drop table tmp_mi_rptcierresuchis;
		drop table metaprod;

		
		insert into mi_tmpcierresuc(tipo,empresa,sucursal,ejecutivo,producto,num_ctasdia)
		SELECT 'APERC' as tipo, empresa, sucursal, ejecutivo, '6666' as producto, sum (cantidad)  
		FROM table (multiset(
		select empresa,sucursal,user_insert as ejecutivo,count(*) as cantidad
		from bdinteg:si_adiccoppel where fechamov = '10/03/2012' and empresa = '001' 
		group by 1,2,3)) group by empresa, sucursal, ejecutivo;
		
		set isolation to dirty read;
		select num_sucursal,
		(meta_acu_cap +  ((metasuc.meta_men_cap / 30.5) * day('10/03/2012')))::money / nvl (num,1) as metacapdia,     
		(meta_acu_col +  ((meta_men_col / 30.5) * day('10/03/2012')))::money   as metacoldia
			   from table ( multiset (
									select metasuc1.num_sucursal , metasuc1.id_tiposuc, ejec.num, meta_acu_cap, meta_acu_col, meta_men_cap, meta_men_col                    
								   from table ( multiset (
									select li.num_sucursal,tpo.id_tiposuc,
									sum(case when tpo.aniomes[5,6] < MONTH('10/03/2012') then meta_monto_cap else 0 end) as meta_acu_cap,
									sum(case when tpo.aniomes[5,6] < MONTH('10/03/2012') then meta_monto_col else 0 end) as meta_acu_col,
									sum(case when tpo.aniomes[5,6] = MONTH('10/03/2012') then meta_monto_cap else 0 end) as meta_men_cap,
									sum(case when tpo.aniomes[5,6] = MONTH('10/03/2012') then meta_monto_col else 0 end) as meta_men_col
									from "informix".mi_sucursalesinfo li, "informix".mi_tiposuc tpo
									where tpo.id_tiposuc = tipo_suc and tpo.aniomes[1,4] = YEAR('10/03/2012')  and  tpo.aniomes[5,6] <= MONTH('10/03/2012')                            
									 group by 1,2
									)) as metasuc1, table ( multiset ( 
									select sucursal , count(ejecutivo) as num from bdinteg:si_ejecut where password <> 'BAJA' and puesto = '003' GROUP BY sucursal)) 							
									as ejec where metasuc1.num_sucursal = ejec.sucursal))as metasuc
									into temp metaprod WITH NO LOG; 	
									
									
		/*insert into "informix".mi_rptcierresuchis(empresa,sucursal,ejecutivo,nombre,producto,fecha_cierre,num_ctasdia,
		monto_ctasdia,p_cumpmetactas,meta_ctasdia,
		monto_incrementodia,meta_incremento,p_cumpsaldo,num_abonosctascap,monto_abonosctascap,num_abonosctascred,
		monto_abonosctascred,p_rec_vs_pagomin,p_rec_vs_vencido,num_clientel_act,num_compago,num_acuerdopago,num_cons_edocta,
	    num_retirocapta,monto_retirocapta,num_retirocoloca,monto_retirocoloca)*/
            select  tmp.empresa,tmp.sucursal,tmp.ejecutivo,si.nombre,tmp.producto,'10/03/2012' as fecha_cierre ,num_ctasdia,monto_ctasdia,
            nvl((case when num_ctasdia > 0 and mp.metanum > 0 then ((num_ctasdia / mp.metanum) * 100) else 0 end)::money,0) as p_cumpmetactas,
            nvl(MP.METANUM,0) as meta_ctasdia,nvl((monto_incrementodia )::money,0) as  monto_incrementodia,
            nvl(CASE WHEN tmp.producto IN (select num_producto from bdmis:"informix".mi_producto where num_sistema = 1) THEN metacapdia
                     WHEN tmp.producto IN (select num_producto from bdmis:"informix".mi_producto where num_sistema = 3) THEN metacapdia
                     WHEN tmp.producto IN (select num_producto from bdmis:"informix".mi_producto where num_sistema = 6) THEN metacoldia END,0) AS meta_incremento,
            nvl((case when monto_incrementodia > 0  and (CASE WHEN tmp.producto IN (select producto  from bdicheq:"informix".sc_producto) THEN meta_monto_cap
                                             WHEN tmp.producto IN (select num_producto from bdmis:"informix".mi_producto where num_sistema = 3) THEN metacapdia
                                             WHEN tmp.producto IN (select num_producto from bdmis:"informix".mi_producto where num_sistema = 6) THEN metacoldia END) > 0 then (((monto_incrementodia ) / (CASE WHEN tmp.producto IN (select num_producto from bdmis:mi_producto where num_sistema = 1) THEN meta_monto_cap
                                             WHEN tmp.producto IN (select num_producto from bdmis:"informix".mi_producto where num_sistema = 3) THEN metacapdia
                                             WHEN tmp.producto IN (select num_producto from bdmis:"informix".mi_producto where num_sistema = 6) THEN metacoldia END)) * 100) else 0 end)::money,0)  as    p_cumpsaldo,
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
        bdinteg:"informix".si_ejecut si, bdmis:"informix".mi_sucursalesinfo suc,  outer bdmis:"informix".mi_metasprod mp, outer bdmis:"informix".mi_tiposuc ts, metaprod        ----****  MI_METASPROD  (SIRVE PARAOBTENER EL NUMERO DE META POR MEDIO DE TIPO DE SUCURSAL Y PRODUCTO)        
		where si.ejecutivo = tmp.ejecutivo --and si.sucursal = tmp.sucursal 
		and si.empresa ='001'  ----****  MI_TIPOSUC  (SIRVE PARAOBTENER EL MONTO DE LA META DE CAPTACION O DE COLOCACION POR MEDIO DE TIPO DE SUCURSAL)
		AND TMP.SUCURSAL = SUC.NUM_SUCURSAL AND SUC.TIPO_SUC = MP.ID_TIPOSUC AND TMP.PRODUCTO = MP.PRODUCTO AND TS.ID_TIPOSUC = SUC.TIPO_SUC AND
		MP.ANIOMES = YEAR('10/03/2012') ||  LPAD( MONTH('10/03/2012'),2,'00') AND TS.ANIOMES = YEAR('10/03/2012') ||  LPAD(MONTH('10/03/2012'),2,'00') and  metaprod.num_sucursal = tmp.sucursal
		into temp tmp_mi_rptcierresuchis WITH NO LOG;
		
		
			FOREACH  cursor1 
			WITH HOLD for
				SELECT  ejecutivo,empresa,fecha_cierre,producto,sucursal,num_ctasdia
				INTO 	vejecutivo,vempresa,vfecha_cierre,vproducto,vsucursal, vnum_ctasdia
				FROM tmp_mi_rptcierresuchis 
				
				
				if (select count (*) from mi_rptcierresuchis where ejecutivo = vejecutivo  and empresa = vempresa  and fecha_cierre = vfecha_cierre
					and producto = vproducto and sucursal = vsucursal ) > 0  then
				
						UPDATE mi_rptcierresuchis SET num_ctasdia = (num_ctasdia + vnum_ctasdia)  WHERE ejecutivo = vejecutivo  and empresa = vempresa  and fecha_cierre = vfecha_cierre
							and producto = vproducto and sucursal = vsucursal;
				
				else
				
						insert into "informix".mi_rptcierresuchis(empresa,sucursal,ejecutivo,nombre,producto,fecha_cierre,num_ctasdia,
						monto_ctasdia,p_cumpmetactas,meta_ctasdia,
						monto_incrementodia,meta_incremento,p_cumpsaldo,num_abonosctascap,monto_abonosctascap,num_abonosctascred,
						monto_abonosctascred,p_rec_vs_pagomin,p_rec_vs_vencido,num_clientel_act,num_compago,num_acuerdopago,num_cons_edocta,
						num_retirocapta,monto_retirocapta,num_retirocoloca,monto_retirocoloca)
						SELECT empresa,sucursal,ejecutivo,nombre,producto,fecha_cierre,num_ctasdia,
						monto_ctasdia,p_cumpmetactas,meta_ctasdia,
						monto_incrementodia,meta_incremento,p_cumpsaldo,num_abonosctascap,monto_abonosctascap,num_abonosctascred,
						monto_abonosctascred,p_rec_vs_pagomin,p_rec_vs_vencido,num_clientel_act,num_compago,num_acuerdopago,num_cons_edocta,
						num_retirocapta,monto_retirocapta,num_retirocoloca,monto_retirocoloca
						FROM tmp_mi_rptcierresuchis 
						where ejecutivo = vejecutivo  and empresa = vempresa  and fecha_cierre = vfecha_cierre
							  and producto = vproducto and sucursal = vsucursal; 
						
				
				end if
				
			END FOREACH					
			

		RETURN cod_ret, vmensaje;		
	END
end procedure;
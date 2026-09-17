create procedure "informix".sp_rcda_integracion()
	RETURNING CHAR (005) as cod_ret,
			  char (180) as mensaje;

	--Declaracion de variables
				  
	--variables de control de errores			  
	DEFINE  SQL_ERR          INTEGER;
	DEFINE  ISAM_ERR         INTEGER;
	DEFINE  ERROR_INFO       VARCHAR(80);
	DEFINE  P_COD_RET        VARCHAR(6);
	DEFINE  P_MENSAJE        VARCHAR(80);
	DEFINE  dFecha           Date;
	DEFINE  dFechafto        char(10);
	DEFINE  dFechaCorte      Date;
	DEFINE  dFechaAnt        Date;
	DEFINE  dFechahoy        Date;
	DEFINE  dult_dia_mes     Date;
	DEFINE  dfechaantier     Date;
	DEFINE  iDiasMes         INTEGER;
	DEFINE  vpaso			 integer;
	DEFINE  vaniomes		 char(06);
	DEFINE  iVal             INTEGER;
	DEFINE  iVal2            INTEGER;
	DEFINE  iPorCap          decimal;
	DEFINE  iPorSdo          decimal;
	DEFINE  iPorCol          decimal;
	DEFINE  iPorTdc          decimal;
	
BEGIN
   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
      LET P_COD_RET    = SQL_ERR;
      LET P_MENSAJE  = ERROR_INFO || ' sp_rcda_integracion en paso ' || vpaso;
	  insert into mi_rptcierresucerror (fecha_cierre,estatus_ejec,codigo_error,desc_error )
	  select fecha_ant,'F',P_COD_RET, P_MENSAJE  from bdmis:mi_fechas;
      RETURN P_COD_RET, P_MENSAJE;
   END EXCEPTION;
   
   set isolation to dirty read;
   
   --inicializacion
	let P_COD_RET = '00000';
	let P_MENSAJE ='PROCESO EXITOSO';
   
     let vpaso = 0;
   --se obtienen las fechas de proceso   
	   set isolation to dirty read;
	   select fecha_ant,day(ult_dia_mes)::int, (fecha_ant-1), fecha_hoy, ult_dia_mes 
	   into dFecha,iDiasMes, dfechaantier, dFechahoy, dult_dia_mes 
	   from bdmis:mi_fechas;
	   
			if (SELECT count(codigo_error) FROM mi_rptcierresucerror where fecha_cierre = dfecha and codigo_error = 001) > 0 then
			   return '001','fecha ya procesada';
			end if	   
	   
	   let vaniomes = year(dFecha)|| lpad(month(dFecha),2,'0');
   
		--insercion de incrementos de saldo
		
		 let vpaso = 1;
		 insert into mi_tmpcierresuc(tipo,empresa,sucursal,ejecutivo,producto,monto_incrementodia)
		 select tipo,empresa,sucursal,ejecutivo,producto,monto_incrementodia from mi_incremento_saldo;
		
		let vpaso = 2;
		--Nuevo calculo de porcentaje obteniendo las metas divididas entre numero de promotores por sucursal LAGS - 17/01/2012
		set isolation to dirty read;
		select num_sucursal,
		(meta_acu_cap +  ((metasuc.meta_men_cap / 30.5) * day(dfecha)))::money / nvl (num,1) as metacapdia,     
		(meta_acu_col +  ((meta_men_col / 30.5) * day(dfecha)))::money   as metacoldia
			   from table ( multiset (
									select metasuc1.num_sucursal , metasuc1.id_tiposuc, ejec.num, meta_acu_cap, meta_acu_col, meta_men_cap, meta_men_col                    
								   from table ( multiset (
									select li.num_sucursal,tpo.id_tiposuc,
									sum(case when tpo.aniomes[5,6] < MONTH(dfecha) then meta_monto_cap else 0 end) as meta_acu_cap,
									sum(case when tpo.aniomes[5,6] < MONTH(dfecha) then meta_monto_col else 0 end) as meta_acu_col,
									sum(case when tpo.aniomes[5,6] = MONTH(dfecha) then meta_monto_cap else 0 end) as meta_men_cap,
									sum(case when tpo.aniomes[5,6] = MONTH(dfecha) then meta_monto_col else 0 end) as meta_men_col
									from mi_sucursalesinfo li,mi_tiposuc tpo
									where tpo.id_tiposuc = tipo_suc and tpo.aniomes[1,4] = YEAR(dfecha)  and  tpo.aniomes[5,6] <= MONTH(dfecha)                            
									 group by 1,2
									)) as metasuc1, table ( multiset ( 
									select sucursal , count(ejecutivo) as num from bdinteg:si_ejecut where password <> 'BAJA' and puesto = '003' GROUP BY sucursal)) 							
									as ejec where metasuc1.num_sucursal = ejec.sucursal))as metasuc
									into temp metaprod WITH NO LOG;   
		   
		let vpaso = 3;	
		--Se agrega	nueva tabla temporal para guardar datos de la meta de incremento en cálculo de ponderaciones - HLA - 01/03/2012						
		select num_sucursal, metacapdia from metaprod
		into temp metaprod_backup;
		
		let vpaso = 4;
		truncate table mi_rptcierresuc;
		
		insert into mi_rptcierresuc(empresa,sucursal,ejecutivo,nombre,producto,fecha_cierre,num_ctasdia,
		monto_ctasdia,p_cumpmetactas,meta_ctasdia,
		monto_incrementodia,meta_incremento,p_cumpsaldo,num_abonosctascap,monto_abonosctascap,num_abonosctascred,
		monto_abonosctascred,p_rec_vs_pagomin,p_rec_vs_vencido,num_clientel_act,num_compago,num_acuerdopago,num_cons_edocta,
	    num_retirocapta,monto_retirocapta,num_retirocoloca,monto_retirocoloca)
            select  tmp.empresa,tmp.sucursal,tmp.ejecutivo,si.nombre,tmp.producto,dfecha,num_ctasdia,monto_ctasdia,
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
		MP.ANIOMES = YEAR(dfecha) ||  LPAD( MONTH(dfecha),2,'00') AND TS.ANIOMES = YEAR(dfecha) ||  LPAD(MONTH(dfecha),2,'00') and  metaprod.num_sucursal = tmp.sucursal;
		
		let vpaso = 5;
		-- borrar interact de mi_rptcierresuc		
		delete from mi_rptcierresuc where ejecutivo ='interact';
		
		--incluir  solicitudes de usuario interact  en tabla mi_rptcierresuc
		
				--incluir  solicitudes de usuario interact  en tabla mi_rptcierresuc
		insert into mi_rptcierresuc(empresa,sucursal,ejecutivo,nombre,producto,fecha_cierre,num_ctasdia)
					select empresa, sucursal, ejecutivo, nombre, producto,dfecha , num_ctasdia 
					from mi_tmpcierresuc where ejecutivo = 'interact';	
					
		
		let vpaso = 6;		
       --Calcular la tabla de acumulado mensual --Modifico MANUEL OSUNA 05/05/2011
        truncate table mi_rptcierresucacumulejecut;

		insert into mi_rptcierresucacumulejecut(empresa,sucursal,ejecutivo,nombre,producto,aniomes,num_ctasmes,monto_ctasmes,p_cumpmetactasmes,
		meta_ctasmes,monto_incrementomes,meta_incrementomes,p_cumpsaldomes,num_abonosctascapmes,monto_abonosctascapmes,num_abonosctascredmes,
		monto_abonosctascredmes,num_retirocaptames,monto_retirocaptames,num_retirocolocames,monto_retirocolocames)
		select tmp.empresa,tmp.sucursal,tmp.ejecutivo,si.nombre,tmp.producto,
		trim( year (dFecha) || lpad(month(dFecha),2,'0'))::integer   as fecha_cierre, num_ctasdia,monto_ctasdia,
		case when num_ctasdia > 0  and producto <> '9999'  and meta_numero > 0
                    then ((num_ctasdia / meta_numero) * 100)::money
			 else 0
		end as p_cumpmetactasmes, meta_numero,monto_incrementomes,meta_monto,
		case when monto_incrementomes >  0  and producto <> '9999'  and meta_monto > 0
                    then ((monto_incrementomes /  meta_monto) * 100)::money
             else 0
		end as p_cumpsaldomes, num_abonosctascap,monto_abonosctascap,num_abonosctascred,monto_abonosctascred,num_retirocapta,monto_retirocapta, num_retirocoloca,monto_retirocoloca
		from table(multiset(
						select  metahis.empresa, metahis.sucursal, metahis.ejecutivo, metahis.producto, metahis.num_ctasdia,
					metahis.monto_ctasdia,/*round*/(nvl((((mp.metanum * 24) / 30 ) * day(dFecha)),0)) as meta_numero,
					nvl((CASE WHEN METAHIS.producto IN (select num_producto from bdmis:mi_producto where num_sistema = 1) THEN metacapmes
												 WHEN METAHIS.producto IN (select num_producto from bdmis:mi_producto where num_sistema = 3) THEN metacapmes
												 WHEN METAHIS.producto IN (select num_producto from bdmis:mi_producto where num_sistema = 6) THEN metacolmes END),0) as meta_monto
					,metahis.num_abonosctascap, metahis.monto_abonosctascap, metahis.num_abonosctascred, metahis.monto_abonosctascred,metahis.num_retirocapta,metahis.monto_retirocapta,
					metahis.num_retirocoloca, metahis.monto_retirocoloca, metahis.monto_incrementomes
					FROM TABLE (MULTISET(                select empresa, sucursal, ejecutivo, producto,
					                sum(num_ctasdia) as num_ctasdia,sum(monto_ctasdia) as monto_ctasdia,
					                sum(num_abonosctascap) as num_abonosctascap,sum(monto_abonosctascap) as monto_abonosctascap,
					                sum(num_abonosctascred) as num_abonosctascred,sum(monto_abonosctascred) as monto_abonosctascred,
					                sum(num_retirocapta) as num_retirocapta,sum(monto_retirocapta) as monto_retirocapta,
					                sum(num_retirocoloca) as num_retirocoloca,sum(monto_retirocoloca) as monto_retirocoloca,
					               sum(monto_incrementomes)  as monto_incrementomes 								   
								   from table (multiset(		
					select    his.empresa,his.sucursal,his.ejecutivo,his.producto,
					                sum(his.num_ctasdia) as num_ctasdia,sum(his.monto_ctasdia) as monto_ctasdia,
					                sum(num_abonosctascap) as num_abonosctascap,sum(monto_abonosctascap) as monto_abonosctascap,
					                sum(num_abonosctascred) as num_abonosctascred,sum(monto_abonosctascred) as monto_abonosctascred,
					                sum(num_retirocapta) as num_retirocapta,sum(monto_retirocapta) as monto_retirocapta,
					                sum(num_retirocoloca) as num_retirocoloca,sum(monto_retirocoloca) as monto_retirocoloca,
					               sum(monto_incrementodia)  as monto_incrementomes		---*** MI_SUCURSALESINFO (TIENE EL TIPO DE SUCURSAL EL CUAL SIRVE PARA BUSCAR EL NUMERO Y EL MONTO DE LAS METAS)
					from mi_rptcierresuchis his ----****  MI_METASPROD  (SIRVE PARAOBTENER EL NUMERO DE META POR MEDIO DE TIPO DE SUCURSAL Y PRODUCTO)
					where month(his.fecha_cierre) = month (dFecha) and year(his.fecha_cierre) = year(dFecha)	----****  MI_TIPOSUC  (SIRVE PARAOBTENER EL MONTO DE LA META DE CAPTACION O DE COLOCACION POR MEDIO DE TIPO DE SUCURSAL)
					group by his.empresa,his.sucursal,his.ejecutivo,his.producto    
                    union all 
					select    his.empresa,his.sucursal,his.ejecutivo,his.producto,
					                sum(his.num_ctasdia) as num_ctasdia,sum(his.monto_ctasdia) as monto_ctasdia,
					                sum(num_abonosctascap) as num_abonosctascap,sum(monto_abonosctascap) as monto_abonosctascap,
					                sum(num_abonosctascred) as num_abonosctascred,sum(monto_abonosctascred) as monto_abonosctascred,
					                sum(num_retirocapta) as num_retirocapta,sum(monto_retirocapta) as monto_retirocapta,
					                sum(num_retirocoloca) as num_retirocoloca,sum(monto_retirocoloca) as monto_retirocoloca,
					               sum(monto_incrementodia)  as monto_incrementomes		---*** MI_SUCURSALESINFO (TIENE EL TIPO DE SUCURSAL EL CUAL SIRVE PARA BUSCAR EL NUMERO Y EL MONTO DE LAS METAS)
					from mi_rptcierresuc his ----****  MI_METASPROD  (SIRVE PARAOBTENER EL NUMERO DE META POR MEDIO DE TIPO DE SUCURSAL Y PRODUCTO)
					where month(his.fecha_cierre) = month (dFecha) and year(his.fecha_cierre) = year(dFecha)	----****  MI_TIPOSUC  (SIRVE PARAOBTENER EL MONTO DE LA META DE CAPTACION O DE COLOCACION POR MEDIO DE TIPO DE SUCURSAL)
					group by his.empresa,his.sucursal,his.ejecutivo,his.producto ))
					group by empresa, sucursal, ejecutivo, producto)) AS METAHIS,
					outer table ( multiset (
					select num_sucursal as sucursal, metacapdia as metacapmes ,metacoldia as metacolmes from metaprod)) as metaprod ,
							outer BDMIS: MI_METASPROD MP,BDMIS: MI_SUCURSALESINFO SUC, BDMIS: MI_TIPOSUC TS
					WHERE metahis.sucursal = suc.num_sucursal and suc.tipo_suc = mp.id_tiposuc and metahis.producto = mp.producto and ts.id_tiposuc = suc.tipo_suc
					AND MP.ANIOMES = YEAR(dFecha) ||  LPAD( MONTH(dFecha),2,'00') AND TS.ANIOMES = YEAR(dFecha) ||  LPAD(MONTH(dFecha),2,'00') and  metaprod.sucursal = metahis.sucursal
					)) tmp,
		outer bdinteg:si_ejecut si where tmp.ejecutivo = si.ejecutivo /*and tmp.sucursal = si.sucursal*/;
		
		let vpaso = 7;
		-- borrar interact de mi_rptcierresucacumulejecut		
		delete from mi_rptcierresucacumulejecut where ejecutivo ='interact';
		
		--incluir  solicitudes de usuario interact  en tabla mi_rptcierresucacumulejecut
		insert into mi_rptcierresucacumulejecut(empresa,sucursal,ejecutivo,nombre,producto,aniomes,num_ctasmes)
					select empresa, sucursal, ejecutivo, nombre, producto,year(dfecha)||lpad(month(dfecha),2,'0') , num_ctasdia 
					from mi_tmpcierresuc where ejecutivo = 'interact';
					
		let vpaso = 8;			
		--Se agrega	nueva tabla temporal para guardar datos de la meta de incremento mensual en cálculo de ponderaciones - HLA - 01/03/2012		
		select num_sucursal,
		( meta_acu_cap +  ((meta_men_cap / 30.5) * day(dFecha)))::money as metacapmes
		from table ( multiset (
		select li.num_sucursal,tpo.id_tiposuc,
		sum(case when tpo.aniomes[5,6] < MONTH(dFecha) then meta_monto_cap else 0 end) as meta_acu_cap ,
		sum(case when tpo.aniomes[5,6] = MONTH(dFecha) then meta_monto_cap else 0 end) as meta_men_cap
		from mi_sucursalesinfo li,mi_tiposuc tpo
		where tpo.id_tiposuc = tipo_suc and tpo.aniomes[1,4] = YEAR(dFecha)  and  tpo.aniomes[5,6] <= MONTH(dFecha)
		group by 1,2))
		into temp metaprod_backup2;
		--Se agrega	nueva tabla temporal para guardar datos de la meta de incremento mensual en cálculo de ponderaciones - HLA - 01/03/2012						

		let vpaso = 9;
		 -- CALCULO DE PONDERACIONES(PARAMETROS)
		select sum(case when parametro = 1 then valor end) as capt,
		sum(case when parametro = 2 then valor end) as saldo,
		sum(case when parametro = 3 then valor end) as col,
		sum(case when parametro = 4 then valor end) as tdc
		into iPorCap,iPorSdo,iPorCol, iPorTdc from mi_paramcump;
		
		let vpaso = 10;
		TRUNCATE table mi_rptcierresucpgeneral;

		insert into mi_rptcierresucpgeneral(empresa,sucursal,ejecutivo,nombre,fecha_cierre,p_cumdia_capta,
		p_cumdia_saldo,p_cumdia_coloca,p_cumdia_tdc,p_cumdia_general,p_cummes_capta,p_cummes_saldo,p_cummes_coloca,p_cummes_tdc, p_cummes_general)
		select empresa,sucursal,ejecutivo,nombre,dFecha,cump_cap_dia,cump_sdo_dia,cump_col_dia,cump_tdc_dia,
		(cump_cap_dia + cump_sdo_dia + cump_col_dia + cump_tdc_dia) as cump_gral_dia, cump_cap_mes,cump_sdo_mes,cump_col_mes,cump_tdc_mes,
		(cump_cap_mes +cump_sdo_mes + cump_col_mes + cump_tdc_mes ) as cum_gral_mes
		from table (multiset(
						select empresa,sucursal,ejecutivo,nombre,
						nvl(sum(
						        case when meta_ctasdia_cap > 0 and tipo = '1'  and  (((num_ctasdia_cap / meta_ctasdia_cap ) * 100)::money  > 120 )  then  ((120 * iPorCap)::money)
						             when meta_ctasdia_cap > 0 and tipo = '1'  and  (((num_ctasdia_cap / meta_ctasdia_cap ) * 100)::money  < 120 )  then (((num_ctasdia_cap / meta_ctasdia_cap ) * 100) * iPorCap)::money end),0) as cump_cap_dia,
						nvl(sum(case when meta_incremento_sdo > 0 and tipo = '1'  and  (((monto_incrementodia_sdo / meta_incremento_sdo ) * 100)::money  > 120 )  then  ((120 * iPorSdo)::money)
						             when meta_incremento_sdo > 0 and tipo = '1'  and  (((monto_incrementodia_sdo / meta_incremento_sdo ) * 100)::money  < 120 )  then (((monto_incrementodia_sdo / meta_incremento_sdo ) * 100) * iPorSdo)::money  end),0) as cump_sdo_dia,
						nvl(sum(case when meta_ctasdia_col > 0 and tipo = '1'  and  (((num_ctasdia_col / meta_ctasdia_col ) * 100)::money  > 120 )  then  ((120 * iPorCol)::money)
						             when meta_ctasdia_col > 0 and tipo = '1'  and  (((num_ctasdia_col / meta_ctasdia_col ) * 100)::money  < 120 )  then (((num_ctasdia_col / meta_ctasdia_col ) * 100) * iPorCol)::money end),0) as cump_col_dia,
						nvl(sum(case when meta_ctasdia_TDC > 0 and tipo = '1'  and  (((num_ctasdia_TDC / meta_ctasdia_TDC ) * 100)::money  > 120 )  then  ((120 * iPorTdc)::money)
						             when meta_ctasdia_TDC > 0 and tipo = '1'  and  (((num_ctasdia_TDC / meta_ctasdia_TDC ) * 100)::money  < 120 )  then (((num_ctasdia_TDC / meta_ctasdia_TDC ) * 100) * iPorTdc)::money end),0) as cump_tdc_dia,

						nvl(sum(case when meta_ctasdia_cap > 0 and tipo = '2'  and  (((num_ctasdia_cap / meta_ctasdia_cap ) * 100)::money  > 120 )  then  ((120 * iPorCap)::money)
						             when meta_ctasdia_cap > 0 and tipo = '2'  and  (((num_ctasdia_cap / meta_ctasdia_cap ) * 100)::money  < 120 )  then (((num_ctasdia_cap / meta_ctasdia_cap ) * 100) * iPorCap)::money end),0) as cump_cap_mes,
						nvl(sum(case when meta_incremento_sdo > 0 and tipo = '2'  and  (((monto_incrementodia_sdo / meta_incremento_sdo ) * 100)::money  > 120 )  then  ((120 * iPorSdo)::money)
						             when meta_incremento_sdo > 0 and tipo = '2'  and  (((monto_incrementodia_sdo / meta_incremento_sdo ) * 100)::money  < 120 )  then (((monto_incrementodia_sdo / meta_incremento_sdo ) * 100) * iPorSdo)::money end),0) as cump_sdo_mes,
						nvl(sum(case when meta_ctasdia_col > 0 and tipo = '2'  and  (((num_ctasdia_col / meta_ctasdia_col ) * 100)::money  > 120 )  then  ((120 * iPorCol)::money)
						             when meta_ctasdia_col > 0 and tipo = '2'  and  (((num_ctasdia_col / meta_ctasdia_col ) * 100)::money  < 120 )  then (((num_ctasdia_col / meta_ctasdia_col ) * 100) * iPorCol)::money end),0) as cump_col_mes,
						nvl(sum(case when meta_ctasdia_TDC > 0 and tipo = '2'  and  (((num_ctasdia_TDC / meta_ctasdia_TDC ) * 100)::money  > 120 )  then  ((120 * iPorTdc)::money)
						             when meta_ctasdia_TDC > 0 and tipo = '2'  and  (((num_ctasdia_TDC / meta_ctasdia_TDC ) * 100)::money  < 120 )  then (((num_ctasdia_TDC / meta_ctasdia_TDC ) * 100) * iPorTdc)::money end),0) as cump_tdc_mes

						from table(multiset (
									select  '1' as tipo,suc.empresa,suc.sucursal,suc.ejecutivo,suc.nombre,
									nvl(sum(case when pro.num_sistema in ('1','3')  then num_ctasdia end),0) as num_ctasdia_cap,
									nvl(sum(case when pro.num_sistema in ('1','3') then meta_ctasdia end),0) as meta_ctasdia_cap,
									nvl(sum(case when pro.num_sistema in ('1','3') then monto_incrementodia end),0) as monto_incrementodia_sdo,
									--nvl(sum(case when pro.num_sistema in ('1','3') then meta_incremento end),0) as meta_incremento_sdo,
									--Cambia cálculo de meta incremento en ponderaciones - HLA - 01/03/2012
                                    (select metacapdia from metaprod_backup where num_sucursal = suc.sucursal) as meta_incremento_sdo,
									nvl(sum(case when pro.num_sistema = '6' and suc.producto <> '6666' then num_ctasdia end),0) as num_ctasdia_col,
									nvl(sum(case when pro.num_sistema = '6' and suc.producto <> '6666' then meta_ctasdia end),0) as meta_ctasdia_col,
									nvl(sum(case when pro.num_sistema = '6' and suc.producto = '6666' then num_ctasdia end),0) as num_ctasdia_TDC,
									nvl(sum(case when pro.num_sistema = '6' and suc.producto = '6666' then meta_ctasdia end),0) as meta_ctasdia_TDC
									from bdmis:mi_rptcierresuc suc,bdmis:mi_producto pro
									where pro.num_producto = suc.producto and suc.producto <> '9999'
									group by suc.empresa,suc.sucursal,suc.ejecutivo,suc.nombre
									union
									select  '2' as tipo,eje.empresa,eje.sucursal,eje.ejecutivo,eje.nombre,
									nvl(sum(case when pro.num_sistema in ('1','3') then eje.num_ctasmes end),0) as num_ctasmes_cap,
									nvl(sum(case when pro.num_sistema in ('1','3') then eje.meta_ctasmes end),0) as meta_ctasmes_cap,
									nvl(sum(case when pro.num_sistema in ('1','3') then eje.monto_incrementomes end),0) as monto_incrementomes_sdo,
									--nvl(sum(case when pro.num_sistema in ('1','3') then meta_incrementomes end),0) as meta_incrementomes_sdo,
									--Cambia cálculo de meta incremento en ponderaciones - HLA - 01/03/2012
									(select metacapmes from metaprod_backup2 where num_sucursal = eje.sucursal) as meta_incrementomes_sdo,
									--Se modifica validación de eje.producto en las siguientes 2 líneas ya que estaba como "=" - HLA - 01/03/2012
									nvl(sum(case when pro.num_sistema = '6' and eje.producto <> '6666' then eje.num_ctasmes end),0) as num_ctasmes_col,
									nvl(sum(case when pro.num_sistema = '6' and eje.producto <> '6666' then eje.meta_ctasmes end),0) as meta_ctasmes_col,
									nvl(sum(case when pro.num_sistema = '6' and eje.producto = '6666' then num_ctasmes end),0) as num_ctasmes_TDC,
									nvl(sum(case when pro.num_sistema = '6' and eje.producto = '6666' then meta_ctasmes end),0) as meta_ctasmes_TDC
									from bdmis:mi_rptcierresucacumulejecut  eje,bdmis:mi_producto pro
									where pro.num_producto = eje.producto and eje.producto <> '9999' and ejecutivo <> 'interact'
									group by eje.empresa,eje.sucursal,eje.ejecutivo,eje.nombre))
                   group by empresa,sucursal,ejecutivo,nombre));		
		
		TRUNCATE table bdmis:mi_rptcierresucestatus;

		let vpaso = 11;
		insert into mi_rptcierresucestatus(sucursal,fecha_rptcierre)
		select sucinf.num_sucursal,dFecha 
			from "informix".mi_sucursalesinfo sucinf, bdinteg:si_sucursales suc
			where sucinf.num_sucursal = suc.sucursal and sucinf.num_sucursal < 8000 and suc.tpo_sucursal = 'S'; -- Carlos F. Flores Verdugo 23/10/2017 Se cambia num. de sucursal hasta 8000 y se agrega tipo sucursal igual a S

		let vpaso = 12;
		--Calcular el Acumulado mensual
	    insert into mi_rptcierresucerror values (dFecha,'V',P_COD_RET,P_MENSAJE );

		let vpaso = 13;
        execute PROCEDURE sp_integrapromotorvirtualdia()
            INTO P_COD_RET, P_MENSAJE;
        IF P_COD_RET <> '000' THEN
            RETURN P_COD_RET, P_MENSAJE;
        END IF;
		
		let vpaso = 14;
        execute PROCEDURE sp_obtieneinfocierrediariosucDia(dFecha)
            INTO P_COD_RET, P_MENSAJE;
        IF P_COD_RET <> '00000' THEN
            RETURN P_COD_RET, P_MENSAJE;
        END IF;
		
		let vpaso = 15;
			--Actualización de tmp_cifrascierresuc para presentación de Metas LAGS.
        --1)Inserción de Solicitudes de TDC para ejecutivos que solo tienen TDC entregadas
		insert into tmp_cifrascierresuc(usuario,tipo_reg,empresa,sucursal,ejecutivo,nombre,producto,fechacierre,numtdc,metanumtdc,cumpmetatdc, metactasdia)
		 select cf.usuario,'2',cf.empresa,cf.sucursal,cf.ejecutivo,cf.nombre,'6001',cf.fechacierre,cf.numtdc,cf.metanumtdc,cf.cumpmetatdc,
		(SELECT mt.metanum FROM mi_metasprod mt, mi_sucursalesinfo si
						where  mt.aniomes = vaniomes and mt.id_tiposuc = si.tipo_suc and mt.producto  = '6001' 
                        and si.num_sucursal = cf.sucursal  )
        from tmp_cifrascierresuc cf
		where producto = '6666'
		and not cf.ejecutivo in (select ejecutivo from tmp_cifrascierresuc where producto = '6001' and tipo_reg = '2' ) and length(cf.fechacierre) = 10;
		
		let vpaso = 16;
		insert into tmp_cifrascierresuc(usuario,tipo_reg,empresa,sucursal,ejecutivo,nombre,producto,fechacierre,numtdc,metanumtdc,cumpmetatdc,metactasdia)
		select cf.usuario,'6',cf.empresa,cf.sucursal,cf.ejecutivo,cf.nombre,'6001',cf.fechacierre,cf.numtdc,cf.metanumtdc,cf.cumpmetatdc, 
		(SELECT nvl(round(((mt.metanum * 24) / 30) * day(dFecha)),0)
						FROM mi_metasprod mt, mi_sucursalesinfo si
						where  mt.aniomes = vaniomes and mt.id_tiposuc = si.tipo_suc and mt.producto  = '6001' 
                        and si.num_sucursal = cf.sucursal  )
		from tmp_cifrascierresuc cf
		where producto = '6666'
		and not cf.ejecutivo in (select ejecutivo from tmp_cifrascierresuc where producto = '6001' and tipo_reg = '6' ) and length(cf.fechacierre) = 6;


		let vpaso = 17;
	--2)Actualización de metas de solicitudes de TDC
	
		begin work;
		update bdmis:tmp_cifrascierresuc set numtdc = 0, cumpmetatdc = 0, metanumtdc = 0 where tipo_reg in ('2','6') and producto = '6001';
        commit work;

		let vpaso = 18;
	--3)Actualización de TDC entregadas que trae el producto 6666 sobre los registros del producto 6001
		select sucursal,ejecutivo,numtdc,metanumtdc,cumpmetatdc from tmp_cifrascierresuc where producto = '6666' AND length(fechacierre) = 10  INTO TEMP tmpmi_cierresuctdc;

		begin work;
		update tmp_cifrascierresuc set (numtdc,metanumtdc,cumpmetatdc) =
		((select numtdc,metanumtdc,cumpmetatdc from tmpmi_cierresuctdc
		where ejecutivo = tmp_cifrascierresuc.ejecutivo AND sucursal = tmp_cifrascierresuc.sucursal
		))where producto  = '6001' and tipo_reg = '2';
        commit work;

		let vpaso = 19;
		select sucursal,ejecutivo,numtdc,metanumtdc,cumpmetatdc from tmp_cifrascierresuc where producto = '6666' AND length(fechacierre) = 6   INTO TEMP tmpmi_cierresucacumtdc;

		begin work;
		update tmp_cifrascierresuc set (numtdc,metanumtdc,cumpmetatdc) =
		((select numtdc,metanumtdc,cumpmetatdc from tmpmi_cierresucacumtdc
		where ejecutivo = tmp_cifrascierresuc.ejecutivo AND sucursal = tmp_cifrascierresuc.sucursal
		))where producto  = '6001' and tipo_reg = '6';
        commit work;

		let vpaso = 20;
	--4)Borrado de registros del producto 6666 para evitar presentación en el reporte
		delete from bdmis:tmp_cifrascierresuc where tipo_reg in ('2','6') and producto = '6666';

		let vpaso = 21;
	--5)Actualización de metas de ejecutivos que están en nulo o ceros
		begin work;
		update tmp_cifrascierresuc  set tmp_cifrascierresuc.metactasdia = (select nvl(round(((metanum * 24) / 30) * day(dFecha)),0) from mi_metasprod where producto = '6001' and id_tiposuc = (select tipo_suc from mi_sucursalesinfo 
		where num_sucursal = tmp_cifrascierresuc.sucursal) and aniomes = tmp_cifrascierresuc.fechacierre)
		where tmp_cifrascierresuc.producto = '6001' and tmp_cifrascierresuc.tipo_reg = '6' and length(tmp_cifrascierresuc.fechacierre) = 6 and
	        (tmp_cifrascierresuc.metactasdia = 0 or tmp_cifrascierresuc.metactasdia is null);
        	commit work;
		
		let vpaso = 22;
		begin work;
		update tmp_cifrascierresuc set tmp_cifrascierresuc.metactasdia = (select metanum from mi_metasprod where producto = '6666' and id_tiposuc = (select tipo_suc from mi_sucursalesinfo 
        where num_sucursal = tmp_cifrascierresuc.sucursal) and aniomes = (substring(tmp_cifrascierresuc.fechacierre FROM 7 FOR 10) || substring(tmp_cifrascierresuc.fechacierre FROM 1 FOR 2)))
		where tmp_cifrascierresuc.producto = '6001' and tmp_cifrascierresuc.tipo_reg = '2' and length(tmp_cifrascierresuc.fechacierre) = 10 and
		(tmp_cifrascierresuc.metactasdia = 0 or tmp_cifrascierresuc.metactasdia is null);
        	commit work;

		let vpaso = 22;	
		begin work;
		update tmp_cifrascierresuc set tmp_cifrascierresuc.metanumtdc  = (select nvl(round(((metanum * 24) / 30) * day(dFecha)),0) from mi_metasprod where producto = '6666' and id_tiposuc = (select tipo_suc from mi_sucursalesinfo 
        where num_sucursal = tmp_cifrascierresuc.sucursal) and aniomes = tmp_cifrascierresuc.fechacierre)
		where tmp_cifrascierresuc.producto = '6001' and tmp_cifrascierresuc.tipo_reg = '6' and length(tmp_cifrascierresuc.fechacierre) = 6 and
	        (tmp_cifrascierresuc.metanumtdc  = 0 or tmp_cifrascierresuc.metanumtdc  is null);
        	commit work;

		let vpaso = 23;
		begin work;
		update tmp_cifrascierresuc set tmp_cifrascierresuc.metanumtdc  = (select metanum from mi_metasprod where producto = '6666' and id_tiposuc = (select tipo_suc from mi_sucursalesinfo 
        where num_sucursal = tmp_cifrascierresuc.sucursal) and aniomes = (substring(tmp_cifrascierresuc.fechacierre FROM 7 FOR 10) || substring(tmp_cifrascierresuc.fechacierre FROM 1 FOR 2)))
		where tmp_cifrascierresuc.producto = '6001' and tmp_cifrascierresuc.tipo_reg = '2' and length(tmp_cifrascierresuc.fechacierre) = 10 and
	        (tmp_cifrascierresuc.metanumtdc = 0 or tmp_cifrascierresuc.metanumtdc is null);
        	commit work;

		let vpaso = 24;
        --6)Actualiza metas para los gerentes en 0
	        begin work;
			update tmp_cifrascierresuc set metactasdia = 0, metanumtdc = 0, metaincremento = 0, cumpmetactas = 0, cumpmetatdc = 0
			where ejecutivo in (select ejecutivo from bdinteg:si_ejecut where puesto = '001');
        	commit work;
			let vpaso = 25;
		-- 7) actualiza las metas para los promores virtuales GLI - 24/02/2012
			 begin work; 
				update tmp_cifrascierresuc set metactasdia = 0, metanumtdc = 0, metaincremento = 0, cumpmetactas = 0 where nombre = 'PROMOTOR VIRTUAL';
        	commit work;	
			
			begin work;
				UPDATE bdmis:mi_param SET estatus = 'V' WHERE descripcion = 'FLAG RPT CIERRE';	
			commit work;
			
	RETURN P_COD_RET, P_MENSAJE;
END;
end procedure;
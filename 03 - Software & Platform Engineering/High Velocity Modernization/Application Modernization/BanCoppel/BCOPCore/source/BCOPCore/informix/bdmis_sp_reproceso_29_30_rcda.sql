CREATE PROCEDURE "informix".sp_reproceso_29_30_rcda()		
 RETURNING	CHAR(06) as cod_ret,
			CHAR(80) as mensaje;
			
			
	--variables de control de errores			  
	DEFINE  SQL_ERR          INTEGER;
	DEFINE  ISAM_ERR         INTEGER;
	DEFINE  ERROR_INFO       VARCHAR(80);			
	DEFINE  P_COD_RET        VARCHAR(6);
	DEFINE  P_MENSAJE        VARCHAR(80);
	DEFINE  vpaso			 integer;
	
BEGIN
   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
      LET P_COD_RET    = SQL_ERR;
      LET P_MENSAJE  = ERROR_INFO || ' sp_rcda_integra en paso ' || vpaso;
	  
      RETURN P_COD_RET, P_MENSAJE;
   END EXCEPTION;
   
   
   LET P_COD_RET ='000000';
   LET P_MENSAJE ='PROCESO EXITOSO';
   
   set isolation to dirty read;		 
	
	let vpaso = 0;
	insert into mi_his_productividad (fecha,sucursal, tpo_reg ,ejecutivo,nombre,producto,capcuentas,capmeta,colsolcred,colsolmeta,colentrcred,colentrmeta,copsoltdc,copsolmeta,
				copentrtdc,copentrmeta,num_comp_mismomes,meta_comp_mismomes,clubncandidatos,clubncompraron,clubncompraronmeta,be_totcontr,be_meta  )
	SELECT  fecha,sucursal,1 as tpo_reg ,ejecutivo,nombre,producto,capcuentas,capmeta,colsolcred,colsolmeta,colentrcred,colentrmeta,copsoltdc,copsolmeta,
			copentrtdc,copentrmeta,num_comp_mismomes,meta_comp_mismomes,clubncandidatos,clubncompraron,clubncompraronmeta,be_totcontr,be_meta  
	 FROM mi_acumps_mes WHERE fecha in ('11/29/2014','11/30/2014');	
		
	let vpaso = 1;	
	SELECT suc.num_sucursal, meta.producto, meta.metanum 
	FROM mi_metasprod meta ,mi_sucursalesinfo suc 
	WHERE meta.aniomes = year(date('11/29/2014')) || lpad (month(date('11/29/2014')),2,'0') and  meta.id_tiposuc = suc.tipo_suc 
	into temp tmp_metas_prod WITH NO LOG;
	
	let vpaso = 2;
	BEGIN WORK ;
	insert into mi_his_productividad 	(fecha,sucursal, tpo_reg,ejecutivo, nombre, producto, capcuentas, capmeta)
	select date('11/29/2014'),sucursal,2,ejecutivo,(select nombre from bdinteg:si_ejecut eje where eje.ejecutivo = mes.ejecutivo ) ,
	producto,sum(nvl(capcuentas,0)),nvl((((nvl((select metanum from tmp_metas_prod pd where 
										pd.num_sucursal = mes.sucursal and pd.producto = mes.producto ),0) * 24) / 30) * (select case
										when fecha_insert < mdy(1,1,year(date('11/29/2014')))+1 
										then date('11/29/2014')-mdy(1,1,year(date('11/29/2014')))+1
										else date('11/29/2014')-fecha_insert end
										from bdinteg:si_ejecut eej where eej.ejecutivo =mes.ejecutivo  )) ,0)as meta--sum(nvl(capmeta,0))
	from  mi_acumps_mes mes
	where producto in ('2000','1100','2200','2300','1400','1500','1700','3000','2500','1900')
			and (year(fecha) = year (date('11/29/2014')) ) and fecha < date('11/29/2014')
	group by 1,2,3,4,5,6;
	COMMIT WORK ;
	
	
	let vpaso = 3;
	 BEGIN WORK ;
			insert into mi_his_productividad (fecha,sucursal, tpo_reg,ejecutivo, nombre, producto, colsolcred, colsolmeta)
			select date('11/29/2014'),sucursal,2,ejecutivo,(select nombre from bdinteg:si_ejecut eje where eje.ejecutivo = mes.ejecutivo ),producto, sum(nvl(colsolcred,0)),  
			nvl((((nvl((select metanum from tmp_metas_prod pd where 
												pd.num_sucursal = mes.sucursal and pd.producto = mes.producto ),0) * 24) / 30) * (select case
												when fecha_insert < mdy(month(date('11/29/2014')),1,year(date('11/29/2014')))+1 
												then date('11/29/2014')-mdy(month(date('11/29/2014')),1,year(date('11/29/2014')))+1
												else date('11/29/2014')-fecha_insert end
												from bdinteg:si_ejecut eej where eej.ejecutivo =mes.ejecutivo)) ,0)as meta
			
			--((nvl((select metanum from tmp_metas_prod pd where pd.num_sucursal = mes.sucursal and pd.producto = mes.producto ),0) * 24) / 30) * day (date('11/29/2014')) 
			from  mi_acumps_mes mes where producto = '6001' and (year(fecha) = year (date('11/29/2014')) ) and  (month(fecha) = month (date('11/29/2014')) )
				  and fecha < date('11/29/2014')			
			group by 1,2,3,4,5,6;
		
		 COMMIT WORK ;
		
		 --acumulado de tarjetas de credito entregdas 
	let vpaso = 4;	 
		 BEGIN WORK ;
			insert into mi_his_productividad 	(fecha,sucursal, tpo_reg,ejecutivo, nombre, producto, colentrcred, colentrmeta)
			select date('11/29/2014'),sucursal,2,ejecutivo,(select nombre from bdinteg:si_ejecut eje where eje.ejecutivo = mes.ejecutivo ),producto, sum(nvl(colentrcred,0)),  
			nvl((((nvl((select metanum from tmp_metas_prod pd where 
												pd.num_sucursal = mes.sucursal and pd.producto = mes.producto ),0) * 24) / 30) * (select case
												when fecha_insert < mdy(1,1,year(date('11/29/2014')))+1 
												then date('11/29/2014')-mdy(1,1,year(date('11/29/2014')))+1
												else date('11/29/2014')-fecha_insert end
												from bdinteg:si_ejecut eej where eej.ejecutivo =mes.ejecutivo)) ,0)as meta
			--((nvl((select metanum from tmp_metas_prod pd where pd.num_sucursal = mes.sucursal and pd.producto = mes.producto ),0) * 24) / 30) * day (date('11/29/2014')) 
			from  mi_acumps_mes mes where producto = '6666' and (year(fecha) = year (date('11/29/2014')) )  and fecha < date('11/29/2014')
			group by 1,2,3,4,5,6;
		  COMMIT WORK ;
		  
		 
		 -- acumulado solicitud de tarjeta de credito coppel  
		 let vpaso = 5;
		 BEGIN WORK ;
			insert into mi_his_productividad 	(fecha,sucursal, tpo_reg,ejecutivo, nombre, producto, copsoltdc, copsolmeta)
			select date('11/29/2014'),sucursal,2,ejecutivo,(select nombre from bdinteg:si_ejecut eje where eje.ejecutivo = mes.ejecutivo ),producto, sum(nvl(copsoltdc,0)),  
			nvl((((nvl((select metanum from tmp_metas_prod pd where 
												pd.num_sucursal = mes.sucursal and pd.producto = mes.producto ),0) * 24) / 30) * (select case
												when fecha_insert < mdy(month(date('11/29/2014')),1,year(date('11/29/2014')))+1 
												then date('11/29/2014')-mdy(month(date('11/29/2014')),1,year(date('11/29/2014')))+1
												else date('11/29/2014')-fecha_insert end
												from bdinteg:si_ejecut eej where eej.ejecutivo =mes.ejecutivo)) ,0)as meta
			--((nvl((select metanum from tmp_metas_prod pd where pd.num_sucursal = mes.sucursal and pd.producto = mes.producto ),0) * 24) / 30) * day (date('11/29/2014')) 
			from  mi_acumps_mes mes where producto = '6500' and (year(fecha) = year (date('11/29/2014')) ) and  (month(fecha) = month (date('11/29/2014')) )  and fecha < date('11/29/2014')
			group by 1,2,3,4,5,6;
		 COMMIT WORK ;
	
		 -- acumulado tarjetas coppel entregadas
		 let vpaso = 6;
		 BEGIN WORK ;
			insert into mi_his_productividad 	(fecha,sucursal, tpo_reg,ejecutivo, nombre, producto, copentrtdc, copentrmeta)
			select date('11/29/2014'),sucursal,2,ejecutivo,(select nombre from bdinteg:si_ejecut eje where eje.ejecutivo = mes.ejecutivo ),producto, sum(nvl(copentrtdc,0)),  
			nvl((((nvl((select metanum from tmp_metas_prod pd where 
												pd.num_sucursal = mes.sucursal and pd.producto = mes.producto ),0) * 24) / 30) * (select case
												when fecha_insert < mdy(1,1,year(date('11/29/2014')))+1 
												then date('11/29/2014')-mdy(1,1,year(date('11/29/2014')))+1
												else date('11/29/2014')-fecha_insert end
												from bdinteg:si_ejecut eej where eej.ejecutivo =mes.ejecutivo)) ,0)as meta
			--((nvl((select metanum from tmp_metas_prod pd where pd.num_sucursal = mes.sucursal and pd.producto = mes.producto ),0) * 24) / 30) * day (date('11/29/2014')) 
			from  mi_acumps_mes mes where producto = '6566' and (year(fecha) = year (date('11/29/2014')) )  and fecha < date('11/29/2014')
			group by 1,2,3,4,5,6;
		 COMMIT WORK ;
	
		 let vpaso = 7;
		 -- acumulado  club de proteccion 
		 BEGIN WORK ;
			insert into mi_his_productividad 	(fecha,sucursal, tpo_reg,ejecutivo, nombre, producto,clubncandidatos, clubncompraron,clubncompraronmeta )
			select date('11/29/2014'),sucursal,2,ejecutivo,(select nombre from bdinteg:si_ejecut eje where eje.ejecutivo = mes.ejecutivo ),
			producto, sum(nvl(clubncandidatos,0)), sum(nvl(clubncompraron,0)), 
			nvl((((nvl((select metanum from tmp_metas_prod pd where 
												pd.num_sucursal = mes.sucursal and pd.producto = mes.producto ),0) * 24) / 30) * (select case
												when fecha_insert < mdy(month(date('11/29/2014')),1,year(date('11/29/2014')))+1 
												then date('11/29/2014')-mdy(month(date('11/29/2014')),1,year(date('11/29/2014')))+1
												else date('11/29/2014')-fecha_insert end
												from bdinteg:si_ejecut eej where eej.ejecutivo =mes.ejecutivo)) ,0)as meta
			--((nvl(mes.clubncompraronmeta,0) * 24) / 30) * day (date('11/29/2014')) 
			from  mi_acumps_mes mes where producto = '7777' and (year(fecha) = year (date('11/29/2014')) ) and  (month(fecha) = month (date('11/29/2014')) )  and fecha < date('11/29/2014')
			group by 1,2,3,4,5,6,9;
		 COMMIT WORK ;	
		 
		let vpaso = 8;
		 --  acumulado banca electrónica 
		 BEGIN WORK ;
			insert into mi_his_productividad 	(fecha,sucursal, tpo_reg,ejecutivo, nombre, producto, be_totcontr, be_meta)
			select date('11/29/2014'),sucursal,2,ejecutivo,(select nombre from bdinteg:si_ejecut eje where eje.ejecutivo = mes.ejecutivo ),producto, sum(nvl(be_totcontr,0)),  
			nvl((((nvl((select metanum from tmp_metas_prod pd where 
												pd.num_sucursal = mes.sucursal and pd.producto = mes.producto ),0) * 24) / 30) * (select case
												when fecha_insert < mdy(month(date('11/29/2014')),1,year(date('11/29/2014')))+1 
												then date('11/29/2014')-mdy(month(date('11/29/2014')),1,year(date('11/29/2014')))+1
												else date('11/29/2014')-fecha_insert end
												from bdinteg:si_ejecut eej where eej.ejecutivo =mes.ejecutivo)) ,0)as meta
			--((nvl(be_meta,0) * 24) / 30) * day (date('11/29/2014')) 
			from  mi_acumps_mes mes where producto = '5003' and (year(fecha) = year (date('11/29/2014')) ) and  (month(fecha) = month (date('11/29/2014')) )  and fecha < date('11/29/2014')
			group by 1,2,3,4,5,6,8;
		 COMMIT WORK ;
		 

		 -- acumulado clientes que compraron el mismo mes 
		 let vpaso = 9;
		 BEGIN WORK ;
			insert into mi_his_productividad 	(fecha,sucursal, tpo_reg,ejecutivo, nombre, producto, num_comp_mismomes, meta_comp_mismomes)
			select date('11/29/2014'),sucursal,2,ejecutivo,(select nombre from bdinteg:si_ejecut eje where eje.ejecutivo = mes.ejecutivo ),producto, sum(nvl(num_comp_mismomes,0)),  
			nvl((((nvl((select metanum from tmp_metas_prod pd where 
												pd.num_sucursal = mes.sucursal and pd.producto = mes.producto ),0) * 24) / 30) * (select case
												when fecha_insert < mdy(month(date('11/29/2014')),1,year(date('11/29/2014')))+1 
												then date('11/29/2014')-mdy(month(date('11/29/2014')),1,year(date('11/29/2014')))+1
												else date('11/29/2014')-fecha_insert end
												from bdinteg:si_ejecut eej where eej.ejecutivo =mes.ejecutivo)) ,0)as meta
			--((nvl((select metanum from tmp_metas_prod pd where pd.num_sucursal = mes.sucursal and pd.producto = mes.producto ),0) * 24) / 30) * day (date('11/29/2014')) 
			from  mi_acumps_mes mes  where producto = '6111' and (year(fecha) = year (date('11/29/2014')) ) and  (month(fecha) = month (date('11/29/2014')) )  and fecha < date('11/29/2014')
			group by 1,2,3,4,5,6;
		 COMMIT WORK ;	
		  
	--dia 30 
	let vpaso = 10;
	BEGIN WORK ;
	insert into mi_his_productividad 	(fecha,sucursal, tpo_reg,ejecutivo, nombre, producto, capcuentas, capmeta)
	select date('11/30/2014'),sucursal,2,ejecutivo,(select nombre from bdinteg:si_ejecut eje where eje.ejecutivo = mes.ejecutivo ) ,
	producto,sum(nvl(capcuentas,0)),nvl((((nvl((select metanum from tmp_metas_prod pd where 
										pd.num_sucursal = mes.sucursal and pd.producto = mes.producto ),0) * 24) / 30) * (select case
										when fecha_insert < mdy(1,1,year(date('11/30/2014')))+1 
										then date('11/30/2014')-mdy(1,1,year(date('11/30/2014')))+1
										else date('11/30/2014')-fecha_insert end
										from bdinteg:si_ejecut eej where eej.ejecutivo =mes.ejecutivo  )) ,0)as meta--sum(nvl(capmeta,0))
	from  mi_acumps_mes mes
	where producto in ('2000','1100','2200','2300','1400','1500','1700','3000','2500','1900')
			and (year(fecha) = year (date('11/30/2014')) ) and fecha < date('11/30/2014')
	group by 1,2,3,4,5,6;
	COMMIT WORK ;
	
	let vpaso = 11;
	 BEGIN WORK ;
			insert into mi_his_productividad (fecha,sucursal, tpo_reg,ejecutivo, nombre, producto, colsolcred, colsolmeta)
			select date('11/30/2014'),sucursal,2,ejecutivo,(select nombre from bdinteg:si_ejecut eje where eje.ejecutivo = mes.ejecutivo ),producto, sum(nvl(colsolcred,0)),  
			nvl((((nvl((select metanum from tmp_metas_prod pd where 
												pd.num_sucursal = mes.sucursal and pd.producto = mes.producto ),0) * 24) / 30) * (select case
												when fecha_insert < mdy(month(date('11/30/2014')),1,year(date('11/30/2014')))+1 
												then date('11/30/2014')-mdy(month(date('11/30/2014')),1,year(date('11/30/2014')))+1
												else date('11/30/2014')-fecha_insert end
												from bdinteg:si_ejecut eej where eej.ejecutivo =mes.ejecutivo)) ,0)as meta
			
			--((nvl((select metanum from tmp_metas_prod pd where pd.num_sucursal = mes.sucursal and pd.producto = mes.producto ),0) * 24) / 30) * day (date('11/30/2014')) 
			from  mi_acumps_mes mes where producto = '6001' and (year(fecha) = year (date('11/30/2014')) ) and  (month(fecha) = month (date('11/30/2014')) )
				  and fecha < date('11/30/2014')			
			group by 1,2,3,4,5,6;
		
		 COMMIT WORK ;
		
		 --acumulado de tarjetas de credito entregdas 
		 let vpaso = 12;
		 BEGIN WORK ;
			insert into mi_his_productividad 	(fecha,sucursal, tpo_reg,ejecutivo, nombre, producto, colentrcred, colentrmeta)
			select date('11/30/2014'),sucursal,2,ejecutivo,(select nombre from bdinteg:si_ejecut eje where eje.ejecutivo = mes.ejecutivo ),producto, sum(nvl(colentrcred,0)),  
			nvl((((nvl((select metanum from tmp_metas_prod pd where 
												pd.num_sucursal = mes.sucursal and pd.producto = mes.producto ),0) * 24) / 30) * (select case
												when fecha_insert < mdy(1,1,year(date('11/30/2014')))+1 
												then date('11/30/2014')-mdy(1,1,year(date('11/30/2014')))+1
												else date('11/30/2014')-fecha_insert end
												from bdinteg:si_ejecut eej where eej.ejecutivo =mes.ejecutivo)) ,0)as meta
			--((nvl((select metanum from tmp_metas_prod pd where pd.num_sucursal = mes.sucursal and pd.producto = mes.producto ),0) * 24) / 30) * day (date('11/30/2014')) 
			from  mi_acumps_mes mes where producto = '6666' and (year(fecha) = year (date('11/30/2014')) )  and fecha < date('11/30/2014')
			group by 1,2,3,4,5,6;
		  COMMIT WORK ;
		  
		 
		 -- acumulado solicitud de tarjeta de credito coppel  
		 let vpaso = 13;
		 BEGIN WORK ;
			insert into mi_his_productividad 	(fecha,sucursal, tpo_reg,ejecutivo, nombre, producto, copsoltdc, copsolmeta)
			select date('11/30/2014'),sucursal,2,ejecutivo,(select nombre from bdinteg:si_ejecut eje where eje.ejecutivo = mes.ejecutivo ),producto, sum(nvl(copsoltdc,0)),  
			nvl((((nvl((select metanum from tmp_metas_prod pd where 
												pd.num_sucursal = mes.sucursal and pd.producto = mes.producto ),0) * 24) / 30) * (select case
												when fecha_insert < mdy(month(date('11/30/2014')),1,year(date('11/30/2014')))+1 
												then date('11/30/2014')-mdy(month(date('11/30/2014')),1,year(date('11/30/2014')))+1
												else date('11/30/2014')-fecha_insert end
												from bdinteg:si_ejecut eej where eej.ejecutivo =mes.ejecutivo)) ,0)as meta
			--((nvl((select metanum from tmp_metas_prod pd where pd.num_sucursal = mes.sucursal and pd.producto = mes.producto ),0) * 24) / 30) * day (date('11/30/2014')) 
			from  mi_acumps_mes mes where producto = '6500' and (year(fecha) = year (date('11/30/2014')) ) and  (month(fecha) = month (date('11/30/2014')) )  and fecha < date('11/30/2014')
			group by 1,2,3,4,5,6;
		 COMMIT WORK ;
	
		 -- acumulado tarjetas coppel entregadas
		 let vpaso = 14;
		 BEGIN WORK ;
			insert into mi_his_productividad 	(fecha,sucursal, tpo_reg,ejecutivo, nombre, producto, copentrtdc, copentrmeta)
			select date('11/30/2014'),sucursal,2,ejecutivo,(select nombre from bdinteg:si_ejecut eje where eje.ejecutivo = mes.ejecutivo ),producto, sum(nvl(copentrtdc,0)),  
			nvl((((nvl((select metanum from tmp_metas_prod pd where 
												pd.num_sucursal = mes.sucursal and pd.producto = mes.producto ),0) * 24) / 30) * (select case
												when fecha_insert < mdy(1,1,year(date('11/30/2014')))+1 
												then date('11/30/2014')-mdy(1,1,year(date('11/30/2014')))+1
												else date('11/30/2014')-fecha_insert end
												from bdinteg:si_ejecut eej where eej.ejecutivo =mes.ejecutivo)) ,0)as meta
			--((nvl((select metanum from tmp_metas_prod pd where pd.num_sucursal = mes.sucursal and pd.producto = mes.producto ),0) * 24) / 30) * day (date('11/30/2014')) 
			from  mi_acumps_mes mes where producto = '6566' and (year(fecha) = year (date('11/30/2014')) )  and fecha < date('11/30/2014')
			group by 1,2,3,4,5,6;
		 COMMIT WORK ;
	
		 let vpaso = 15;
		 -- acumulado  club de proteccion 
		 BEGIN WORK ;
			insert into mi_his_productividad 	(fecha,sucursal, tpo_reg,ejecutivo, nombre, producto,clubncandidatos, clubncompraron,clubncompraronmeta )
			select date('11/30/2014'),sucursal,2,ejecutivo,(select nombre from bdinteg:si_ejecut eje where eje.ejecutivo = mes.ejecutivo ),
			producto, sum(nvl(clubncandidatos,0)), sum(nvl(clubncompraron,0)), 
			nvl((((nvl((select metanum from tmp_metas_prod pd where 
												pd.num_sucursal = mes.sucursal and pd.producto = mes.producto ),0) * 24) / 30) * (select case
												when fecha_insert < mdy(month(date('11/30/2014')),1,year(date('11/30/2014')))+1 
												then date('11/30/2014')-mdy(month(date('11/30/2014')),1,year(date('11/30/2014')))+1
												else date('11/30/2014')-fecha_insert end
												from bdinteg:si_ejecut eej where eej.ejecutivo =mes.ejecutivo)) ,0)as meta
			--((nvl(mes.clubncompraronmeta,0) * 24) / 30) * day (date('11/30/2014')) 
			from  mi_acumps_mes mes where producto = '7777' and (year(fecha) = year (date('11/30/2014')) ) and  (month(fecha) = month (date('11/30/2014')) )  and fecha < date('11/30/2014')
			group by 1,2,3,4,5,6,9;
		 COMMIT WORK ;	
		 
	let vpaso = 16;
		 --  acumulado banca electrónica 
		 BEGIN WORK ;
			insert into mi_his_productividad 	(fecha,sucursal, tpo_reg,ejecutivo, nombre, producto, be_totcontr, be_meta)
			select date('11/30/2014'),sucursal,2,ejecutivo,(select nombre from bdinteg:si_ejecut eje where eje.ejecutivo = mes.ejecutivo ),producto, sum(nvl(be_totcontr,0)),  
			nvl((((nvl((select metanum from tmp_metas_prod pd where 
												pd.num_sucursal = mes.sucursal and pd.producto = mes.producto ),0) * 24) / 30) * (select case
												when fecha_insert < mdy(month(date('11/30/2014')),1,year(date('11/30/2014')))+1 
												then date('11/30/2014')-mdy(month(date('11/30/2014')),1,year(date('11/30/2014')))+1
												else date('11/30/2014')-fecha_insert end
												from bdinteg:si_ejecut eej where eej.ejecutivo =mes.ejecutivo)) ,0)as meta
			--((nvl(be_meta,0) * 24) / 30) * day (date('11/30/2014')) 
			from  mi_acumps_mes mes where producto = '5003' and (year(fecha) = year (date('11/30/2014')) ) and  (month(fecha) = month (date('11/30/2014')) )  and fecha < date('11/30/2014')
			group by 1,2,3,4,5,6,8;
		 COMMIT WORK ;
		 

		 -- acumulado clientes que compraron el mismo mes 
		 let vpaso = 17;
		 BEGIN WORK ;
			insert into mi_his_productividad 	(fecha,sucursal, tpo_reg,ejecutivo, nombre, producto, num_comp_mismomes, meta_comp_mismomes)
			select date('11/30/2014'),sucursal,2,ejecutivo,(select nombre from bdinteg:si_ejecut eje where eje.ejecutivo = mes.ejecutivo ),producto, sum(nvl(num_comp_mismomes,0)),  
			nvl((((nvl((select metanum from tmp_metas_prod pd where 
												pd.num_sucursal = mes.sucursal and pd.producto = mes.producto ),0) * 24) / 30) * (select case
												when fecha_insert < mdy(month(date('11/30/2014')),1,year(date('11/30/2014')))+1 
												then date('11/30/2014')-mdy(month(date('11/30/2014')),1,year(date('11/30/2014')))+1
												else date('11/30/2014')-fecha_insert end
												from bdinteg:si_ejecut eej where eej.ejecutivo =mes.ejecutivo)) ,0)as meta
			--((nvl((select metanum from tmp_metas_prod pd where pd.num_sucursal = mes.sucursal and pd.producto = mes.producto ),0) * 24) / 30) * day (date('11/30/2014')) 
			from  mi_acumps_mes mes  where producto = '6111' and (year(fecha) = year (date('11/30/2014')) ) and  (month(fecha) = month (date('11/30/2014')) )  and fecha < date('11/30/2014')
			group by 1,2,3,4,5,6;
		 COMMIT WORK ;	
		 
		 RETURN P_COD_RET, P_MENSAJE;
		 
END
END PROCEDURE;
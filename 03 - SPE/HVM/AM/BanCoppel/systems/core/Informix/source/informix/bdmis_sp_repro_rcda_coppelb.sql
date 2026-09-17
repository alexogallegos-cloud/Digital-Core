CREATE PROCEDURE  "informix".sp_repro_rcda_coppelb(pfecha1 DATE, pfecha2 DATE)
RETURNING 	CHAR(08) AS cod_ret,
			CHAR(80) AS mensaje;
			
--variables de retorno
DEFINE  cod_ret	CHAR(08);
DEFINE	mensaje	CHAR(80);

--variables de control de errores 
	DEFINE  SQL_ERR				INTEGER;
	DEFINE  ISAM_ERR			INTEGER;
	DEFINE  ERROR_INFO			VARCHAR(80);
	DEFINE	vpaso				INTEGER;
	DEFINE	vpaso2				INTEGER;
	
--variables de trabajo 
	DEFINE	dfecha				DATE;

BEGIN
   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
      LET cod_ret    = SQL_ERR;
      LET mensaje  = ERROR_INFO || ' sp_repro_rcda_coppelb en paso ' || vpaso;
	  
      RETURN cod_ret, mensaje;
   END EXCEPTION;

   
	set ISOLATION to dirty read;
	
	let vpaso =0;
	
	IF (select * from systabnames where dbsname = 'bdmis' and tabname = 'mi_bcpl_enproceso') = 0 THEN
	
		CREATE TABLE "informix".mi_bcpl_enproceso ( 
		sp  	char(80),
		paso	int 
		);

	END IF;
	
	IF (SELECT count(*) FROM mi_bcpl_enproceso) = 0 THEN
		
		insert into mi_bcpl_enproceso(sp,paso) VALUES('sp_repro_rcda_coppelb',vpaso);
	
		
	END IF
	
	select paso INTO vpaso2 from mi_bcpl_enproceso;
	
	let vpaso =1;
   --limpieza de tabla para el inicio del reproceso
	UPDATE mi_bcpl_enproceso SET paso = vpaso where sp = 'sp_repro_rcda_coppelb';
   IF vpaso >= vpaso2 then
	   BEGIN WORK;
			DELETE FROM mi_his_productividad WHERE (fecha BETWEEN pfecha1 AND pfecha2) AND tpo_reg = 2 AND producto IN('6500','7777','6566','6111') ;
	   COMMIT WORK;
	   
   END IF
	--insercion de registros del dia   
   let vpaso =2;
   UPDATE mi_bcpl_enproceso SET paso = vpaso where sp = 'sp_repro_rcda_coppelb';
   IF vpaso >= vpaso2 then
		BEGIN WORK;
		INSERT INTO mi_his_productividad(fecha,sucursal,tpo_reg,ejecutivo,nombre,producto,capcuentas,capmeta,colsolcred,colsolmeta,colentrcred,
						colentrmeta,copsoltdc,copsolmeta,copentrtdc,copentrmeta,num_comp_mismomes,meta_comp_mismomes,
						clubncandidatos,clubncompraron,clubncompraronmeta,be_totcontr,be_meta)
		SELECT fecha,sucursal,'1',ejecutivo,nombre,producto,capcuentas,capmeta,colsolcred,colsolmeta,colentrcred,
						colentrmeta,copsoltdc,copsolmeta,copentrtdc,copentrmeta,num_comp_mismomes,meta_comp_mismomes,
						clubncandidatos,clubncompraron,clubncompraronmeta,be_totcontr,be_meta
		FROM mi_acumps_mes WHERE (fecha BETWEEN pfecha1 AND pfecha2) AND producto IN('6500','7777','6566','6111');
		
		COMMIT WORK;
	
	END IF
   -- insercion de registros acumulados
   
   
   let vpaso =3;
   UPDATE mi_bcpl_enproceso SET paso = vpaso where sp = 'sp_repro_rcda_coppelb';
   
   
   IF vpaso >= vpaso2 then     
    BEGIN WORK;
	  foreach cursor1 WITH HOLD for
		SELECT distinct(fecha) into dfecha FROM mi_acumps_mes
		WHERE (fecha between pfecha1 and pfecha2) 
			
			
			SELECT suc.num_sucursal, meta.producto, meta.metanum 
			FROM mi_metasprod meta ,mi_sucursalesinfo suc 
			WHERE meta.aniomes = year(dfecha) || lpad (month(dfecha),2,'0') and  meta.id_tiposuc = suc.tipo_suc 
			into temp tmp_metas_prod WITH NO LOG;
	   
				insert into mi_his_productividad 	(fecha,sucursal, tpo_reg,ejecutivo, nombre, producto, copsoltdc, copsolmeta)
				select dfecha,sucursal,2,ejecutivo,(select nombre from bdinteg:si_ejecut eje where eje.ejecutivo = mes.ejecutivo ),producto, sum(nvl(copsoltdc,0)),  
				nvl((((nvl((select metanum from tmp_metas_prod pd where 
													pd.num_sucursal = mes.sucursal and pd.producto = mes.producto ),0) * 24) / 30) * (select case
													when fecha_insert < mdy(month(dfecha),1,year(dfecha))+1 
													then dfecha-mdy(month(dfecha),1,year(dfecha))+1
													else dfecha-fecha_insert end
													from bdinteg:si_ejecut eej where eej.ejecutivo =mes.ejecutivo)) ,0)as meta
				--((nvl((select metanum from tmp_metas_prod pd where pd.num_sucursal = mes.sucursal and pd.producto = mes.producto ),0) * 24) / 30) * day (dfecha) 
				from  mi_acumps_mes mes where producto = '6500' and (year(fecha) = year (dfecha) ) and  (month(fecha) = month (dfecha) )
				and fecha <= dfecha
				group by 1,2,3,4,5,6;
			
			
				insert into mi_his_productividad 	(fecha,sucursal, tpo_reg,ejecutivo, nombre, producto,clubncandidatos, clubncompraron,clubncompraronmeta )
				select dfecha,sucursal,2,ejecutivo,(select nombre from bdinteg:si_ejecut eje where eje.ejecutivo = mes.ejecutivo ),
				producto, sum(nvl(clubncandidatos,0)), sum(nvl(clubncompraron,0)), 
				nvl((((nvl((select metanum from tmp_metas_prod pd where 
													pd.num_sucursal = mes.sucursal and pd.producto = mes.producto ),0) * 24) / 30) * (select case
													when fecha_insert < mdy(month(dfecha),1,year(dfecha))+1 
													then dfecha-mdy(month(dfecha),1,year(dfecha))+1
													else dfecha-fecha_insert end
													from bdinteg:si_ejecut eej where eej.ejecutivo =mes.ejecutivo)) ,0)as meta
				--((nvl(mes.clubncompraronmeta,0) * 24) / 30) * day (dfecha) 
				from  mi_acumps_mes mes where producto = '7777' and (year(fecha) = year (dfecha) ) and  (month(fecha) = month (dfecha) )
				and fecha <= dfecha
				group by 1,2,3,4,5,6,9;
			
				
				insert into mi_his_productividad 	(fecha,sucursal, tpo_reg,ejecutivo, nombre, producto, copentrtdc, copentrmeta)
				select dfecha,sucursal,2,ejecutivo,(select nombre from bdinteg:si_ejecut eje where eje.ejecutivo = mes.ejecutivo ),producto, sum(nvl(copentrtdc,0)),  
				nvl((((nvl((select metanum from tmp_metas_prod pd where 
													pd.num_sucursal = mes.sucursal and pd.producto = mes.producto ),0) * 24) / 30) * (select case
													when fecha_insert < mdy(1,1,year(dfecha))+1 
													then dfecha-mdy(1,1,year(dfecha))+1
													else dfecha-fecha_insert end
													from bdinteg:si_ejecut eej where eej.ejecutivo =mes.ejecutivo)) ,0)as meta
				--((nvl((select metanum from tmp_metas_prod pd where pd.num_sucursal = mes.sucursal and pd.producto = mes.producto ),0) * 24) / 30) * day (dfecha) 
				from  mi_acumps_mes mes where producto = '6566' and (year(fecha) = year (dfecha) ) 
				and fecha <= dfecha
				group by 1,2,3,4,5,6;
			
	   
				insert into mi_his_productividad 	(fecha,sucursal, tpo_reg,ejecutivo, nombre, producto, num_comp_mismomes, meta_comp_mismomes)
				select dfecha,sucursal,2,ejecutivo,(select nombre from bdinteg:si_ejecut eje where eje.ejecutivo = mes.ejecutivo ),producto, sum(nvl(num_comp_mismomes,0)),  
				nvl((((nvl((select metanum from tmp_metas_prod pd where 
													pd.num_sucursal = mes.sucursal and pd.producto = mes.producto ),0) * 24) / 30) * (select case
													when fecha_insert < mdy(month(dfecha),1,year(dfecha))+1 
													then dfecha-mdy(month(dfecha),1,year(dfecha))+1
													else dfecha-fecha_insert end
													from bdinteg:si_ejecut eej where eej.ejecutivo =mes.ejecutivo)) ,0)as meta
				--((nvl((select metanum from tmp_metas_prod pd where pd.num_sucursal = mes.sucursal and pd.producto = mes.producto ),0) * 24) / 30) * day (dfecha) 
				from  mi_acumps_mes mes  where producto = '6111' and (year(fecha) = year (dfecha) ) and  (month(fecha) = month (dfecha) )
				group by 1,2,3,4,5,6;
			
			
			
			DROP TABLE tmp_metas_prod;
			
	   END foreach;
	   COMMIT WORK;
	END IF			
	DELETE FROM mi_bcpl_enproceso;
	
	RETURN '00000000','PROCESO EXITOSO'	;

END
END PROCEDURE;
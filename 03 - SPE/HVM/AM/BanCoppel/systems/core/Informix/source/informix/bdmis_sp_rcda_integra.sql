create procedure "informix".sp_rcda_integra()
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
	
	DEFINE	cm_fecha		DATE;
	DEFINE	cm_ejecutivo	CHAR(8);
	DEFINE	cm_tpo_reg 		INTEGER;
	DEFINE	cm_producto		CHAR(04);
	
	DEFINE	cm_commit		integer;
	
	-- Nuevas Variables
	DEFINE	v_sucursal		CHAR(4);
	DEFINE	v_copsolmeta	DECIMAL;
	
BEGIN
   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
      LET P_COD_RET    = SQL_ERR;
      LET P_MENSAJE  = ERROR_INFO || ' sp_rcda_integra en paso ' || vpaso;
	  insert into mi_rcda_cierresucerror (fecha_cierre,estatus_ejec,codigo_error,desc_error )
	  select fecha_ant,'F',P_COD_RET, P_MENSAJE  from "informix".mi_fechas;
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
	   from "informix".mi_fechas;
	   
			if (SELECT count(codigo_error) FROM "informix".mi_rcda_cierresucerror where fecha_cierre = dfecha and codigo_error = 001) > 0 then
			   return '001','fecha ya procesada';
			end if	   
	   
	   let vaniomes = year(dFecha)|| lpad(month(dFecha),2,'0');
   
   	
		 let vpaso = 1;
		 set isolation to dirty read;
		 truncate TABLE "informix".mi_aperturas;
		 		
			--EXTRACCION DE METAS DE PRODUCTOS
			set isolation to dirty read;
			select mp.aniomes,suc.num_sucursal as sucursal,suc.tipo_suc, mp.producto ,mp.metanum 
			from "informix".mi_metasprod mp, "informix".mi_sucursalesinfo suc where mp.aniomes = vaniomes and mp.id_tiposuc = suc.tipo_suc
			and mp.producto in ('6566')
			into temp tmp_mp with no log;   ---sacar de aqui el producto 6500 
			
			--Extraer metas del producto 6500
			set isolation to dirty read;   
			select mp.sucursal,suc.tipo_suc, mp.producto,mp.meta_diaria
			from "informix".mi_metascoppel mp, --Nueva tabla con las metas de solicitudes coppel
			"informix".mi_sucursalesinfo suc where mp.fecha = (select max(cpl.fecha) from bdmis:mi_metascoppel cpl) --Se busca la maxima fecha ingresada para tomar la información de la ultima semana cargada
			and mp.sucursal = suc.num_sucursal
			into temp tmp_mp2 with no log;    ---se modifica la tabla temporal 
				
		 let vpaso = 4;
		--llenado de tabla de aperturas, SOLICITUDES DE TARJETA DE CREDITO COPPEL 
		BEGIN WORK ;
		 insert into "informix".mi_aperturas  (fecha,sucursal, tpo_reg,ejecutivo,nombre ,producto,copsoltdc,copsolmeta)
			SELECT  dfecha,tmp.sucursal, 1,tmp.ejecutivo, eje.nombre, tmp.producto, tmp.num_ctasdia ,mp.meta_diaria
			FROM    "informix".mi_rcda_suc tmp, tmp_mp2 mp, bdinteg:si_ejecut eje  --modificar la tabla temporal tmp_mp2
			where   tmp.producto in ('6500')  and
					tmp.sucursal = mp.sucursal and tmp.producto = mp.producto and tmp.ejecutivo = eje.ejecutivo ;
		 COMMIT WORK ;			
		 
		let vpaso = 5;			
		--llenado de tabla de aperturas, TARJETA DEPARTAMENTAL COPPEL ENTREGADAS 
		BEGIN WORK ;
			insert into "informix".mi_aperturas (fecha,sucursal, tpo_reg,ejecutivo,nombre ,producto,copentrtdc, copentrmeta)
			SELECT  dfecha,tmp.sucursal, 1,tmp.ejecutivo, eje.nombre, tmp.producto, tmp.num_ctasdia ,mp.metanum
			FROM    "informix".mi_rcda_suc tmp, tmp_mp mp, bdinteg:si_ejecut eje
			where   tmp.producto in ('6566')  and
					tmp.sucursal = mp.sucursal and tmp.producto = mp.producto and aniomes = vaniomes and 
					tmp.ejecutivo = eje.ejecutivo ;
		COMMIT WORK ;

		drop table tmp_mp;		--Rocio
		--drop table tmp_mp2;
		
		--paso a tablas de acumulado mensual
		set isolation to dirty read;		
		let vpaso = 7;
		-- paso de productividad de sucursales a acumulado mensual
		--validacion para acumulados del mes 
		IF (SELECT COUNT (*) FROM "informix".mi_acumps_mes WHERE fecha = dFecha ) > 0 THEN
		
			DELETE FROM "informix".mi_acumps_mes WHERE fecha = dFecha;
		
		END IF
		BEGIN WORK ;	
			insert into "informix".mi_acumps_mes ( fecha, sucursal, ejecutivo, nombre,producto,capcuentas,capmeta,colsolcred,colsolmeta,colentrcred,
							colentrmeta,copsoltdc,copsolmeta,copentrtdc,copentrmeta,num_comp_mismomes,meta_comp_mismomes,clubncandidatos,
							clubncompraron,clubncompraronmeta,be_totcontr,be_meta)
			select fecha, sucursal, ejecutivo, nombre,producto,nvl(sum(capcuentas),0) as capcuentas,
			nvl(sum(capmeta),0) as capmeta,nvl(sum(colsolcred),0) as colsolcred ,nvl(sum(colsolmeta),0) as colsolmeta,
			nvl(sum(colentrcred),0) as colentrcred,nvl(sum(colentrmeta),0) as colentrmeta,
			nvl(sum(copsoltdc),0) as copsoltdc,nvl(sum(copsolmeta),0) as copsolmeta,nvl(sum(copentrtdc),0) as copentrtdc,
			nvl(sum(copentrmeta),0) as copentrmeta,nvl(sum(num_comp_mismomes),0) as num_comp_mismomes,
			nvl(sum(meta_comp_mismomes),0) as meta_comp_mismomes,nvl(sum(clubncandidatos),0) as clubncandidatos,
			nvl(sum(clubncompraron),0) as clubncompraron,nvl(sum(clubncompraronmeta),0) as clubncompraronmeta,
			nvl(sum(be_totcontr),0) as be_totcontr,nvl(sum(be_meta),0) as be_meta 
			from table(multiset(
				SELECT fecha, sucursal, ejecutivo, case when (nombre is null and ejecutivo < '90000000') 
				then 'PROMOTOR VIRTUAL' ELSE nombre end as nombre,producto,nvl(sum(capcuentas),0) as capcuentas,
				nvl(sum(capmeta),0) as capmeta,nvl(sum(colsolcred),0) as colsolcred ,nvl(sum(colsolmeta),0) as colsolmeta,
				nvl(sum(colentrcred),0) as colentrcred,nvl(sum(colentrmeta),0) as colentrmeta,
				nvl(sum(copsoltdc),0) as copsoltdc,nvl(sum(copsolmeta),0) as copsolmeta,nvl(sum(copentrtdc),0) as copentrtdc,
				nvl(sum(copentrmeta),0) as copentrmeta,nvl(sum(num_comp_mismomes),0) as num_comp_mismomes,
				nvl(sum(meta_comp_mismomes),0) as meta_comp_mismomes,nvl(sum(clubncandidatos),0) as clubncandidatos,
				nvl(sum(clubncompraron),0) as clubncompraron,nvl(sum(clubncompraronmeta),0) as clubncompraronmeta,
				nvl(sum(be_totcontr),0) as be_totcontr,nvl(sum(be_meta),0) as be_meta FROM "informix".mi_aperturas
				group by fecha, sucursal, ejecutivo, nombre, producto ))
			group by fecha, sucursal, ejecutivo, nombre, producto;				
			/*SELECT fecha, sucursal, ejecutivo, nombre,producto,capcuentas,capmeta,colsolcred,colsolmeta,colentrcred,
							colentrmeta,copsoltdc,copsolmeta,copentrtdc,copentrmeta,num_comp_mismomes,meta_comp_mismomes,clubncandidatos,
							clubncompraron,clubncompraronmeta,be_totcontr,be_meta FROM mi_aperturas;*/
		COMMIT WORK ;


		--integracion de de valores acumulados del mes
		let vpaso = 10;
		 --acumulado de Productividad en Sucursales

        --ACUMULADO PARA PRODUCTOS DE CAPTACION 
		--Extracción de metas 
		SELECT suc.num_sucursal, meta.producto, meta.metanum 
		FROM "informix".mi_metasprod meta , "informix".mi_sucursalesinfo suc 
		WHERE meta.aniomes = year(dfecha) || lpad (month(dfecha),2,'0') and  meta.id_tiposuc = suc.tipo_suc
		and meta.producto in ('6566') --sacar producto 6500
		into temp tmp_metas_prod WITH NO LOG;  
		
		--Extraer metas del producto 6500
		SELECT meta.sucursal, meta.producto, meta.meta_diaria
		FROM "informix".mi_metascoppel meta 
		WHERE meta.fecha = (select max(meta2.fecha) from mi_metascoppel meta2 )
		into temp tmp_metas_prod2 WITH NO LOG; 
		
			
		let vpaso = 11;
		 --ACUMULADO SOLICITUDES DE TDC BANCOPPEL 
		 
		let vpaso = 13;  
		 -- ACUMULADO SOLICITUD DE TARJETA DE CREDITO COPPEL 
		 
		 BEGIN WORK ;
			insert into "informix".mi_aperturas (fecha,sucursal, tpo_reg,ejecutivo, nombre, producto, copsoltdc, copsolmeta)
			select dfecha,sucursal,2,ejecutivo,(select nombre from bdinteg:si_ejecut eje where eje.ejecutivo = mes.ejecutivo ),producto, sum(nvl(copsoltdc,0)),  
			nvl((((nvl((select meta_diaria from tmp_metas_prod2 pd where 
												pd.sucursal = mes.sucursal and pd.producto = mes.producto ),0) * 24) / 30) * (select case
												when fecha_insert < mdy(month(dfecha),1,year(dfecha))+1 
												then dfecha-mdy(month(dfecha),1,year(dfecha))+1
												else dfecha-fecha_insert end
												from bdinteg:si_ejecut eej where eej.ejecutivo =mes.ejecutivo)) ,0)as meta
			--((nvl((select metanum from tmp_metas_prod pd where pd.num_sucursal = mes.sucursal and pd.producto = mes.producto ),0) * 24) / 30) * day (dfecha) 
			from  "informix".mi_acumps_mes mes where producto = '6500' and (year(fecha) = year (dfecha) ) and  (month(fecha) = month (dfecha) )
			group by 1,2,3,4,5,6;
		 COMMIT WORK ;
		let vpaso = 14;	
		 -- ACUMULADO DE TARJETA DEPARTAMENTAL COPPEL ENTREGADAS
		 
		 BEGIN WORK ;
			insert into "informix".mi_aperturas (fecha,sucursal, tpo_reg,ejecutivo, nombre, producto, copentrtdc, copentrmeta)
			select dfecha,sucursal,2,ejecutivo,(select nombre from bdinteg:si_ejecut eje where eje.ejecutivo = mes.ejecutivo ),producto, sum(nvl(copentrtdc,0)),  
			nvl((((nvl((select metanum from tmp_metas_prod pd where 
												pd.num_sucursal = mes.sucursal and pd.producto = mes.producto ),0) * 24) / 30) * (select case
												when fecha_insert < mdy(1,1,year(dfecha))+1 
												then dfecha-mdy(1,1,year(dfecha))+1
												else dfecha-fecha_insert end
												from bdinteg:si_ejecut eej where eej.ejecutivo =mes.ejecutivo)) ,0)as meta
			--((nvl((select metanum from tmp_metas_prod pd where pd.num_sucursal = mes.sucursal and pd.producto = mes.producto ),0) * 24) / 30) * day (dfecha) 
			from  "informix".mi_acumps_mes mes where producto = '6566' and (year(fecha) = year (dfecha) ) 
			group by 1,2,3,4,5,6;
		 COMMIT WORK ;
		 let vpaso = 15;

		let vpaso = 16;	
		 --  ACUMULADO BANCA ELECTRONICA

		let vpaso = 17;
		 -- ACUMULADO CLIENTES QUE COMPRARON EL MISMO MES  
		 
		
		drop table tmp_metas_prod;
		drop table tmp_metas_prod2;
		let vpaso = 18;

		IF (SELECT COUNT(*) FROM "informix".mi_rptcierresucestatus WHERE fecha_rptcierre = dFecha ) = 0 THEN
		
			set isolation to dirty read;
			TRUNCATE table "informix".mi_rptcierresucestatus;
			insert into "informix".mi_rptcierresucestatus(sucursal,fecha_rptcierre)
			select sucinf.num_sucursal,dFecha 
			from "informix".mi_sucursalesinfo sucinf, bdinteg:si_sucursales suc
			where sucinf.num_sucursal = suc.sucursal and sucinf.num_sucursal < 8000 and suc.tpo_sucursal = 'S'; -- Carlos F. Flores Verdugo 23/10/2017 Se cambia num. de sucursal hasta 8000 y se agrega tipo sucursal igual a S
		
		END IF	
		
		let vpaso = 21;
		
	    insert into "informix".mi_rcda_cierresucerror values (dFecha,'V',P_COD_RET,P_MENSAJE );

			
		let vpaso = 22;
		
		
        EXECUTE PROCEDURE "informix".sp_rcda_promotorvirtual()
            INTO P_COD_RET, P_MENSAJE;
        IF P_COD_RET <> '000' THEN
            RETURN P_COD_RET, P_MENSAJE;
        END IF;
		
		let vpaso = 23;
		EXECUTE PROCEDURE "informix".sp_rcda_rellenaprod()
            INTO P_COD_RET, P_MENSAJE;
        IF P_COD_RET <> '000000' THEN
            RETURN P_COD_RET, P_MENSAJE;
        END IF;
		
		
		let vpaso = 24;
		BEGIN WORK;
			UPDATE "informix".mi_aperturas SET capmeta = 0, colsolmeta = 0,colentrmeta = 0, copsolmeta = 0,copentrmeta = 0,
			be_meta = 0, meta_comp_mismomes = 0 , clubncompraronmeta = 0
			WHERE nombre = 'PROMOTOR VIRTUAL';
		COMMIT WORK;
		
		let vpaso = 25;
		BEGIN WORK;
			UPDATE "informix".mi_aperturas set capmeta = 0, colsolmeta = 0,colentrmeta = 0, copsolmeta = 0,copentrmeta = 0,
			be_meta = 0, meta_comp_mismomes = 0, clubncompraronmeta = 0
			WHERE ejecutivo IN (SELECT ejecutivo FROM bdinteg:si_ejecut WHERE puesto = '001');
		COMMIT WORK;
		
		let vpaso = 26;
		BEGIN WORK;
			UPDATE "informix".mi_aperturas set capmeta = 0, colsolmeta = 0,colentrmeta = 0, copsolmeta = 0,copentrmeta = 0,
			be_meta = 0, meta_comp_mismomes = 0, clubncompraronmeta = 0
			WHERE ejecutivo NOT IN (SELECT ejecutivo FROM bdinteg:si_ejecut);
		COMMIT WORK;	
		
		let cm_commit = 0;
		let vpaso = 27;
		FOREACH	
		select	fecha ,ejecutivo, tpo_reg,producto
		into	cm_fecha,cm_ejecutivo,cm_tpo_reg, cm_producto
		from "informix".mi_his_productividad 
		WHERE 	((nombre = 'PROMOTOR VIRTUAL') or 
				(ejecutivo IN (SELECT ejecutivo FROM bdinteg:si_ejecut WHERE puesto = '001')) or 
				(ejecutivo NOT IN (SELECT ejecutivo FROM bdinteg:si_ejecut))) and NOT
				(capmeta = 0 and colsolmeta = 0 and colentrmeta = 0 and copsolmeta = 0 AND copentrmeta = 0 AND
					be_meta = 0 AND meta_comp_mismomes = 0 AND clubncompraronmeta = 0)
			let vpaso = 28;		
				IF 	cm_commit = 0 THEN
					
					BEGIN WORK;
					
				END IF	
			let vpaso = 29;	
				UPDATE "informix".mi_his_productividad set capmeta = 0, colsolmeta = 0,colentrmeta = 0, copsolmeta = 0,copentrmeta = 0,
					be_meta = 0, meta_comp_mismomes = 0, clubncompraronmeta = 0
				WHERE 	fecha = cm_fecha AND ejecutivo = cm_ejecutivo AND tpo_reg = cm_tpo_reg  AND producto = cm_producto;
				
				let cm_commit = cm_commit + 1;
				IF 	cm_commit = 1000 THEN
					
					COMMIT WORK;
					let cm_commit = 0;
					
				END IF	
				
				
				
		END FOREACH	
			
		
		IF 	cm_commit <> 0 THEN
				
			COMMIT WORK;
				
		END IF	
		
		
		let vpaso = 30;
		EXECUTE PROCEDURE "informix".sp_paso_his()
		            INTO P_COD_RET, P_MENSAJE;
        IF P_COD_RET <> '000' THEN
            RETURN P_COD_RET, P_MENSAJE;
        END IF;		

	--set debug file to "/informix/1170/cfflores/sp_rcda_integra.out";
    --trace on;
	
		-- Actualización de metas para registros con campo copsoltdc = 0
		LET v_copsolmeta = 0;

		set isolation to dirty read;
		FOREACH

		SELECT sucursal
		INTO v_sucursal
		FROM "informix".mi_aperturas
		WHERE producto = '6500' and tpo_reg = 1 AND copsoltdc = 0
		ORDER BY sucursal

			SELECT meta_diaria
			INTO v_copsolmeta
			FROM tmp_mp2
			WHERE producto = '6500' AND sucursal = v_sucursal;

			UPDATE "informix".mi_aperturas set copsolmeta = v_copsolmeta
			WHERE producto = '6500' AND tpo_reg = 1 AND sucursal = v_sucursal;


		END FOREACH;

		DROP TABLE tmp_mp2;
		----

		BEGIN WORK;
			UPDATE STATISTICS MEDIUM FOR TABLE "informix".mi_his_productividad; 	
		COMMIT WORK;
				
				
		let vpaso = 31;			
			begin work;
				UPDATE "informix".mi_param SET estatus = 'V' WHERE descripcion = 'FLAG RPT CIERRE';	
			commit work;
			
	RETURN P_COD_RET, P_MENSAJE;
END;
end procedure;
CREATE PROCEDURE "informix".sp_rcda_obtaperturas()
RETURNING	CHAR (06) AS cod_ret,
			CHAR (80) AS mensaje;
--variables de retorno 
	DEFINE	cod_ret			CHAR (06);
	DEFINE	mensaje			CHAR (80);
	
--variables de control de errores
	DEFINE  SQL_ERR			INTEGER;
	DEFINE  ISAM_ERR		INTEGER;
	DEFINE  ERROR_INFO		VARCHAR(80);			
	DEFINE	vpaso			INTEGER;	

--variables de proceso
	DEFINE	dfecha			DATE;
	DEFINE	vfecha			CHAR(08);		
	DEFINE	vsuc_tienda		CHAR(04);
	DEFINE	vpromotor		CHAR(08);
	DEFINE	vnumero			INTEGER;
	DEFINE	vmeta			money(18,4);
	DEFINE	vproducto		CHAR(04);
	DEFINE	vnombrearchivo	CHAR(35);
	DEFINE	vfecha_apertura	DATE;
	DEFINE	vnumcte			CHAR(20);
	DEFINE  vaniomes		CHAR(06);
	DEFINE	vsucursal		CHAR(04);
	DEFINE	vtpo_reg		INTEGER;
	
	

BEGIN
   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
      LET cod_ret    = SQL_ERR;
      LET mensaje  = ERROR_INFO || ' sp_rcda_obtaperturas en paso ' || vpaso;
	  insert into mi_rcda_cierresucerror (fecha_cierre,estatus_ejec,codigo_error,desc_error )
	  select fecha_ant,'F',cod_ret, mensaje  from bdmis:mi_fechas;
      RETURN cod_ret, mensaje;
   END EXCEPTION;
   
	let cod_ret = '00000';
    let mensaje = 'PROCESO EXITOSO';
   --DDMMAAAA
   set isolation to dirty read;
   
   let vpaso = 1;
   select fecha_ant into dfecha from mi_fechas;
   
   let vpaso = 2;
   let vfecha = LPAD(DAY(dfecha),2,'0') || LPAD( MONTH(dfecha),2,'0') || YEAR(dfecha); 
   let vfecha = vfecha;   
   
   let vnombrearchivo = 'BCPLRCD_' ||vfecha  ;   
   
   let vaniomes = year(dFecha)|| lpad(month(dFecha),2,'0');
   
     let vpaso = 3; 
	 TRUNCATE TABLE	mi_rcda_apert_paso;
	 
	 UPDATE STATISTICS HIGH FOR TABLE "informix".mi_rcda_infocoppel; 
	 UPDATE STATISTICS HIGH FOR TABLE "informix".mi_acumps_mes; 
	   
   let vpaso = 4;     
   foreach cursor1 WITH HOLD for
		select 	{+INDEX(mi_rcda_infocoppel idx_infocoppel_clave)}
				suc_tienda, promotor, fecha_apertura, '6566' as producto, count(*) as numero
		into	vsuc_tienda,vpromotor, vfecha_apertura,vproducto,vnumero
		from mi_rcda_infocoppel 
		where clave = 'A' --and nombrearchivo = vnombrearchivo and fechageneracion = dfecha 
		group by 1,2,3
		
			SELECT	{+INDEX(mi_sucursalesinfo idx_mi_sucursalesinfo)}
					mp.metanum 
			INTO	vmeta
			FROM 	mi_metasprod mp, mi_sucursalesinfo suc 
			WHERE	mp.aniomes = ( year(vfecha_apertura)|| lpad(month(vfecha_apertura),2,'0'))
					AND suc.num_sucursal = vsuc_tienda
					AND mp.id_tiposuc = suc.tipo_suc AND mp.producto = '6566';
					
  		   
			INSERT INTO mi_rcda_apert_paso (fecha,sucursal,tpo_reg,ejecutivo,nombre,producto,numero,meta) 
				VALUES (vfecha_apertura,vsuc_tienda,1,vpromotor,' ',vproducto, vnumero,vmeta);		
		  
	end foreach;
   
   
   let vpaso = 5;
   IF  (SELECT count(*) FROM mi_rcda_altas_bcplrcd WHERE nombrearchivo = vnombrearchivo ) = 0 THEN
   
		   foreach cursor1 WITH HOLD for
				select	{+INDEX(mi_rcda_infocoppel idx_infocoppel_clave)}
						fecha_apertura,promotor,numcte ,suc_tienda
				into	vfecha_apertura, vpromotor, vnumcte,vsuc_tienda
				from 	mi_rcda_infocoppel 
				where clave = 'A' --and nombrearchivo = vnombrearchivo and fechageneracion = dfecha 
				 
				
					INSERT INTO mi_rcda_altas_bcplrcd(nombrearchivo, fecha, promotor, numcte,sucursal) 
						VALUES (vnombrearchivo, vfecha_apertura, vpromotor, vnumcte,vsuc_tienda);
		   
		   end foreach;
		   
		  insert into mi_rcda_altas_bcplrcd (nombrearchivo, fecha, promotor, numcte,sucursal) 
		   SELECT '',fechamov,user_insert,numctecoppel,sucursal FROM bdinteg:si_adiccoppel where fechamov = dfecha;  
		   
		ELSE
		
			DELETE FROM mi_rcda_altas_bcplrcd WHERE nombrearchivo = vnombrearchivo;
			foreach cursor1 WITH HOLD for
				select	{+INDEX(mi_rcda_infocoppel idx_infocoppel_clave)}
						fecha_apertura,promotor,numcte,suc_tienda
				into	vfecha_apertura, vpromotor, vnumcte,vsuc_tienda
				from 	mi_rcda_infocoppel 
				where 	clave = 'A' --and nombrearchivo = vnombrearchivo and fechageneracion = dfecha 
				 
				
					INSERT INTO mi_rcda_altas_bcplrcd(nombrearchivo, fecha, promotor, numcte,sucursal) 
						VALUES (vnombrearchivo, vfecha_apertura, vpromotor, vnumcte,vsuc_tienda);
		   
		   end foreach;	
		   
		    insert into mi_rcda_altas_bcplrcd (nombrearchivo, fecha, promotor, numcte,sucursal) 
		   SELECT '',fechamov,user_insert,numctecoppel,sucursal FROM bdinteg:si_adiccoppel where fechamov = dfecha;
   
   END IF
   
   let vpaso = 6;
 -- paso de productividad de sucursales a acumulado mensual
	
		
	INSERT INTO bdmis:mi_acumps_mes(fecha,sucursal,ejecutivo,nombre,producto,copentrtdc, copentrmeta)
	select fecha,sucursal,ejecutivo,nombre,producto,numero,meta from mi_rcda_apert_paso
	WHERE  producto = '6566';
			

	
	--calculo de acumulado
	let vpaso = 7;
	/*INSERT INTO mi_rcda_apert_paso (fecha,sucursal,tpo_reg,ejecutivo,nombre,producto,numero,meta)
	select apert.fecha ,mes.sucursal,2,mes.ejecutivo,mes.nombre,mes.producto, SUM(NVL(mes.copentrtdc,0)),((nvl(mes.copentrmeta,0) * 24) / 30) * day (apert.fecha) 
	from mi_acumps_mes mes, mi_rcda_apert_paso apert
	WHERE (mes.fecha BETWEEN  (MONTH(apert.fecha)|| '/01/' || YEAR(apert.fecha)) AND apert.fecha) and mes.sucursal = apert.sucursal and mes.producto = apert.producto AND mes.ejecutivo = apert.ejecutivo
	GROUP BY 1,2,3,4,5,6,8;
	*/
	
	
	FOREACH	
	SELECT	distinct(fecha) 
	INTO 	dfecha
	FROM mi_rcda_apert_paso
	
			SELECT suc.num_sucursal, meta.producto, meta.metanum 
			FROM mi_metasprod meta ,mi_sucursalesinfo suc 
			WHERE meta.aniomes = year(dfecha) || lpad (month(dfecha),2,'0') and  meta.id_tiposuc = suc.tipo_suc 
			into temp tmp_metas_prod WITH NO LOG;	 
				 
			let vpaso = 8;	 
			
		BEGIN WORK ;
			INSERT INTO mi_rcda_apert_paso (fecha,sucursal,tpo_reg,ejecutivo,nombre,producto,numero,meta)
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
		COMMIT WORK ;
			
			DROP TABLE tmp_metas_prod;
	
	END FOREACH;
	
	
	let vpaso = 9;
	UPDATE "informix".mi_rcda_apert_paso SET meta = 0
	WHERE producto = '6566' and  ejecutivo not in (select ejecutivo from bdinteg:si_ejecut );
	
     
	let vpaso = 10;
	
	foreach cursor1 WITH HOLD for
		SELECT	fecha,sucursal,tpo_reg,ejecutivo,producto,numero,meta 
		INTO	dfecha,vsucursal,vtpo_reg,vpromotor, vproducto, vnumero, vmeta
		FROM mi_rcda_apert_paso
		WHERE  producto = '6566'
		
			IF vtpo_reg = 1 THEN 
			
					IF (SELECT COUNT(*) FROM mi_his_productividad WHERE fecha = dfecha AND sucursal = vsucursal AND tpo_reg = vtpo_reg AND ejecutivo = vpromotor AND producto = vproducto) = 0 THEN
				
							INSERT INTO mi_his_productividad (fecha,sucursal,tpo_reg,ejecutivo,nombre,producto,copentrtdc, copentrmeta) 
								VALUES (dfecha,vsucursal,vtpo_reg,vpromotor, (select nombre from bdinteg:si_ejecut eje where eje.ejecutivo = vpromotor ), vproducto, vnumero, vmeta);
						ELSE	
							
							UPDATE mi_his_productividad SET copentrtdc = copentrtdc + vnumero
							WHERE fecha = dfecha AND sucursal = vsucursal AND tpo_reg = vtpo_reg AND ejecutivo = vpromotor AND producto = vproducto;
						
					END IF
				
				ELSE
					
					IF (SELECT COUNT(*) FROM mi_his_productividad WHERE fecha = dfecha AND sucursal = vsucursal AND tpo_reg = vtpo_reg AND ejecutivo = vpromotor AND producto = vproducto) = 0 THEN
				
							INSERT INTO mi_his_productividad (fecha,sucursal,tpo_reg,ejecutivo,nombre,producto,copentrtdc, copentrmeta) 
								VALUES (dfecha,vsucursal,vtpo_reg,vpromotor,(select nombre from bdinteg:si_ejecut eje where eje.ejecutivo = vpromotor ) ,vproducto, vnumero, vmeta);
						
						ELSE
						
							DELETE FROM mi_his_productividad WHERE fecha = dfecha AND sucursal = vsucursal AND tpo_reg = vtpo_reg AND ejecutivo = vpromotor AND producto = vproducto ;
							INSERT INTO mi_his_productividad (fecha,sucursal,tpo_reg,ejecutivo,nombre,producto,copentrtdc, copentrmeta) 
								VALUES (dfecha,vsucursal,vtpo_reg,vpromotor,(select nombre from bdinteg:si_ejecut eje where eje.ejecutivo = vpromotor ) ,vproducto, vnumero, vmeta);
						
					END IF	
					
			END IF	
		
		END foreach;
	
	
	

    
   RETURN cod_ret, mensaje;

   
END
END PROCEDURE;
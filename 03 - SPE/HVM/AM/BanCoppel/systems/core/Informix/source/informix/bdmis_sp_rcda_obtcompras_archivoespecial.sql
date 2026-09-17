CREATE PROCEDURE "informix".sp_rcda_obtcompras_archivoespecial(pfecha DATE)
RETURNING	CHAR (06) AS cod_ret,
			CHAR (80) AS mensaje;
--variables de retorno 
	DEFINE	cod_ret					CHAR (06);
	DEFINE	mensaje					CHAR (80);
	
--variables de control de errores
	DEFINE  SQL_ERR					INTEGER;
	DEFINE  ISAM_ERR				INTEGER;
	DEFINE  ERROR_INFO				VARCHAR(80);			
	DEFINE	vpaso					INTEGER;	

--variables de proceso
	DEFINE	vfecha					CHAR(10);	
	DEFINE	dfecha					DATE;
	DEFINE	vsuc_tienda				CHAR(04);
	DEFINE	vpromotor				CHAR(08);
	DEFINE	vnumero					INTEGER;
	DEFINE	vproducto				CHAR(04);
	DEFINE	vnombrearchivo			CHAR(35);
	DEFINE	vfecha_apertura			DATE;
	DEFINE	vfecha_primeracompra	DATE;
	DEFINE	vnumcte					CHAR(20);
	DEFINE  vaniomes				CHAR(06);	
	DEFINE	vmeta					money(18,4);
	DEFINE	vsucursal				CHAR(04);
	DEFINE	vtpo_reg				INTEGER;
	DEFINE	vnombre					CHAR (104);
	

BEGIN
   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
      LET cod_ret    = SQL_ERR;
      LET mensaje  = ERROR_INFO || ' sp_rcda_obtcompras_archivoespecial en paso ' || vpaso;
	  insert into mi_rcda_cierresucerror (fecha_cierre,estatus_ejec,codigo_error,desc_error )
	  select fecha_ant,'F',cod_ret, mensaje  from bdmis:mi_fechas;
      RETURN cod_ret, mensaje;
   END EXCEPTION;
   
	let cod_ret = '00000';
    let mensaje = 'PROCESO EXITOSO';
   --DDMMAAAA
   set isolation to dirty read;
   
   let vpaso = 1;
  -- select fecha_ant into pfecha from mi_fechas;
   
   let vpaso = 2;
   let vfecha = LPAD(DAY(pfecha),2,'0') || LPAD( MONTH(pfecha),2,'0') || YEAR(pfecha); 
   let vfecha = vfecha;   
   
   let vnombrearchivo = 'BCPLRCD_' ||vfecha  ;   
   
   let vaniomes = year(pfecha)|| lpad(month(pfecha),2,'0');
   
   let vpaso = 3; 
	delete from mi_rcda_apert_paso;
	
	UPDATE STATISTICS HIGH FOR TABLE "informix".mi_acumps_mes; 
   
      let vpaso = 4;     
	  
		   merge into mi_rcda_apert_paso a
			USING ( select case when alt.sucursal is null then A.suc_tienda else alt.sucursal end as suc_tienda 
                    , case when alt.promotor is not null then alt.promotor
				   else LPAD(trim(A.suc_tienda),8,'0') end as promotor
					,case when alt.promotor is not null then  NVL(( select nombre from bdinteg:si_ejecut eject where eject.ejecutivo = alt.promotor),'')
					else 'PROMOTOR VIRTUAL' END AS nombre ,
					 A.producto,count(A.numcte) as num,A.fecha_primercompra,A.metanum from table(multiset(
					select  suc_tienda, producto,numcte,fecha_primercompra,num_sucursal,metanum from table (multiset( --tabla de numero de compras y meta
					 select	suc_tienda,'6111' as producto, numcte, fecha_primercompra
				--	into	vsuc_tienda,vproducto,vnumcte,vfecha_primeracompra
					from mi_rcda_infocoppel 
					where clave = 'V' 
					)) A, table (multiset(--tabla de metas
						SELECT suc.num_sucursal,mp.metanum ,mp.aniomes
						--INTO	vmeta
						FROM 	mi_metasprod mp, mi_sucursalesinfo suc 
						WHERE	 mp.id_tiposuc = suc.tipo_suc AND mp.producto = '6111'  )) B
					  where A.suc_tienda = B.num_sucursal and B.aniomes = ( year(A.fecha_primercompra)|| lpad(month(A.fecha_primercompra),2,'0'))
				))	A
				left join mi_rcda_altas_bcplrcd alt on A.numcte = alt.numcte group by 1,2,3,4,6,7) b
			on a.fecha = b.fecha_primercompra and a.ejecutivo = b.promotor and a.producto = b.producto
			WHEN NOT MATCHED THEN
			insert (a.fecha,a.sucursal,a.tpo_reg,a.ejecutivo,a.nombre,a.producto,a.numero,a.meta) 
			values  (b.fecha_primercompra,b.suc_tienda,1,b.promotor,b.nombre,b.producto,b.num ,b.metanum );
	
	  let vpaso = 6;
 -- paso de productividad de sucursales a acumulado mensual
 
 		merge into mi_rcda_apert_paso a
		using (SELECT a.fecha,a.sucursal,a.tpo_reg, a.ejecutivo, a.nombre,a.producto, sum(a.numero) as numero,sum(meta) as meta 
		FROM mi_rcda_apert_paso a
			left join bdinteg:si_ejecut b on a.ejecutivo = b.ejecutivo
		where b.ejecutivo is null  group by 1,2,3,4,5,6) b
		on a.ejecutivo =b.ejecutivo and a.sucursal = b.sucursal and a.fecha =b.fecha and a.tpo_reg = b.tpo_reg and a.producto = b.producto and a.numero=b.numero
		WHEN MATCHED THEN update 
			set a.meta = 0;
		
			INSERT INTO bdmis:mi_acumps_mes(fecha,sucursal,ejecutivo,nombre,producto,num_comp_mismomes,meta_comp_mismomes)
			select {+INDEX(mi_rcda_apert_paso idx_aprtpaso_cp)} fecha,sucursal,ejecutivo,nombre,producto,numero,meta from mi_rcda_apert_paso
			WHERE producto = '6111';
			

	
	--calculo de acumulado
	let vpaso = 7;
	/*
	INSERT INTO mi_rcda_apert_paso (fecha,sucursal,tpo_reg,ejecutivo,nombre,producto,numero,meta)
	 select apert.fecha,mes.sucursal,2,mes.ejecutivo,mes.nombre,mes.producto, SUM(NVL(mes.num_comp_mismomes,0)), SUM(NVL(mes.meta_comp_mismomes,0)) 
    from mi_acumps_mes mes , mi_rcda_apert_paso apert
    WHERE (mes.fecha BETWEEN  (MONTH(apert.fecha)|| '/01/' || YEAR(apert.fecha)) AND apert.fecha) 
       and mes.sucursal = apert.sucursal and mes.producto = apert.producto AND mes.ejecutivo = apert.ejecutivo
	GROUP BY 1,2,3,4,5,6;*/
	
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
			COMMIT WORK ;
				
			DROP TABLE tmp_metas_prod;
			
	END FOREACH;
	
	   
	let vpaso = 8;
merge into mi_his_productividad a
	USING ( SELECT	fecha,sucursal,tpo_reg,ejecutivo,nombre,producto,numero,meta 
		--INTO	dfecha,vsucursal,vtpo_reg,vpromotor,vnombre, vproducto, vnumero, vmeta
		FROM mi_rcda_apert_paso
		WHERE  producto = '6111' and tpo_reg = 1) b
		on a.fecha = b.fecha AND a.sucursal = b.sucursal AND a.tpo_reg = b.tpo_reg AND a.ejecutivo = b.ejecutivo AND a.producto = b.producto
		WHEN NOT MATCHED THEN
		insert (a.fecha,a.sucursal,a.tpo_reg,a.ejecutivo,a.nombre,a.producto,a.num_comp_mismomes,a.meta_comp_mismomes) 
		values (b.fecha,b.sucursal,b.tpo_reg,b.ejecutivo,b.nombre,b.producto,b.numero,b.meta)
		WHEN  MATCHED THEN update
		set a.num_comp_mismomes = a.num_comp_mismomes + b.numero ;
	
	let vpaso = 9;	
	
		foreach cursor1 WITH HOLD for
			SELECT	fecha,sucursal,tpo_reg,ejecutivo,nombre,producto,numero,meta 
			INTO	vfecha,vsucursal,vtpo_reg,vpromotor,vnombre, vproducto, vnumero, vmeta
			FROM mi_rcda_apert_paso
			WHERE  producto = '6111' and tpo_reg = 2
			
			delete FROM mi_his_productividad 
			WHERE fecha = vfecha AND sucursal = vsucursal AND tpo_reg = vtpo_reg AND ejecutivo = vpromotor AND producto = vproducto;
			
			
		end foreach
	
	
	/*merge into mi_his_productividad a
	USING ( SELECT	fecha,sucursal,tpo_reg,ejecutivo,nombre,producto,numero,meta 
			--INTO	dfecha,vsucursal,vtpo_reg,vpromotor,vnombre, vproducto, vnumero, vmeta
			FROM mi_rcda_apert_paso
			WHERE  producto = '6111' and tpo_reg = 2) b
	on a.fecha = b.fecha AND a.sucursal = b.sucursal AND a.tpo_reg = b.tpo_reg AND a.ejecutivo = b.ejecutivo AND a.producto = b.producto
	WHEN  MATCHED THEN
	DELETE;		*/

	let vpaso = 10;
	merge into mi_his_productividad a
	USING ( SELECT	fecha,sucursal,tpo_reg,ejecutivo,nombre,producto,numero,meta 
		--INTO	dfecha,vsucursal,vtpo_reg,vpromotor,vnombre, vproducto, vnumero, vmeta
			FROM mi_rcda_apert_paso
			WHERE  producto = '6111' and tpo_reg = 2) b
	on a.fecha = b.fecha AND a.sucursal = b.sucursal AND a.tpo_reg = b.tpo_reg AND a.ejecutivo = b.ejecutivo AND a.producto = b.producto
	WHEN NOT MATCHED THEN
	insert (a.fecha,a.sucursal,a.tpo_reg,a.ejecutivo,a.nombre,a.producto,a.num_comp_mismomes,a.meta_comp_mismomes) 
	values (b.fecha,b.sucursal,b.tpo_reg,b.ejecutivo,b.nombre,b.producto,b.numero,b.meta);
    
   RETURN cod_ret, mensaje;

	
END
END PROCEDURE;
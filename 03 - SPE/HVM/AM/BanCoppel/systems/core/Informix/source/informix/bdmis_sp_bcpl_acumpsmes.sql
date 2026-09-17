CREATE PROCEDURE "informix".sp_bcpl_acumpsmes()
 RETURNING	CHAR (06) as cod_ret,
			CHAR (80) as mensaje;
			
			
--definicion de variables de retorno			
 	DEFINE	cod_ret	CHAR(08)	;
	DEFINE	mensaje	CHAR(80)	;

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
	DEFINE	vfecha_inser 	DATE;
	DEFINE	vnumcte			CHAR(20);
	DEFINE  vaniomes		CHAR(06);
	DEFINE	vsucursal		CHAR(04);
	DEFINE	vtpo_reg		INTEGER;
		

BEGIN
   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
      LET cod_ret    = SQL_ERR;
      LET mensaje  = ERROR_INFO || ' sp_bcpl_acumpsmes en paso ' || vpaso;
	  insert into mi_rcda_cierresucerror (fecha_cierre,estatus_ejec,codigo_error,desc_error )
	  select fecha_ant,'F',cod_ret, mensaje  from bdmis:mi_fechas;
      RETURN cod_ret, mensaje;
   END EXCEPTION;		
 
	SET ISOLATION to dirty read;
	let cod_ret = '000000';
	let mensaje	= 'PROCESO EXITOSO';
 
 let vpaso = 0;
 UPDATE STATISTICS HIGH FOR TABLE "informix".mi_acumps_mes; 
 
 let vpaso = 1;
 --insertar aperturas
 foreach cursor1 WITH HOLD for
		select 	{+INDEX(mi_rcda_infocoppel idx_infocoppel_clave)}
				suc_tienda, promotor, fecha_apertura, '6566' as producto, count(*) as numero
		into	vsuc_tienda,vpromotor, vfecha_apertura,vproducto,vnumero
		from mi_rcda_infocoppel 
		where clave = 'A' --and nombrearchivo = vnombrearchivo and fechageneracion = dfecha 
		group by 1,2,3
		
		let vpaso = 2;
			SELECT	{+INDEX(mi_sucursalesinfo idx_mi_sucursalesinfo)}
					mp.metanum 
			INTO	vmeta
			FROM 	mi_metasprod mp, mi_sucursalesinfo suc 
			WHERE	mp.aniomes = ( year(vfecha_apertura)|| lpad(month(vfecha_apertura),2,'0'))
					AND suc.num_sucursal = vsuc_tienda
					AND mp.id_tiposuc = suc.tipo_suc AND mp.producto = '6566';
				
			let vpaso = 3;		
  		   INSERT INTO bdmis:mi_acumps_mes(fecha,sucursal,ejecutivo,nombre,producto,copentrtdc, copentrmeta) 
		   VALUES (vfecha_apertura,vsuc_tienda,vpromotor,' ',vproducto, vnumero,vmeta);		
		  
	end foreach;
	let vpaso = 4;
	UPDATE STATISTICS HIGH FOR TABLE "informix".mi_acumps_mes; 
	let vpaso = 5;
--insertar solcitudes	
   foreach cursor1 WITH HOLD for
		select	suc_tienda, promotor, fecha_inser,'6500' as producto, count(*) as numero
		into	vsuc_tienda,vpromotor, vfecha_inser ,vproducto,vnumero
		from mi_rcda_infocoppel 
		where clave = ' ' --and nombrearchivo = vnombrearchivo and fechageneracion = dfecha 
		group by 1,2,3
  		   
		   let vpaso = 6;
			SELECT	{+INDEX(mi_sucursalesinfo idx_mi_sucursalesinfo)}
					mp.metanum 
			INTO	vmeta
			FROM 	mi_metasprod mp, mi_sucursalesinfo suc 
			WHERE	mp.aniomes = ( year(vfecha_inser)|| lpad(month(vfecha_inser),2,'0'))
					AND suc.num_sucursal = vsuc_tienda
					AND mp.id_tiposuc = suc.tipo_suc AND mp.producto = '6500';		   
		   
		    let vpaso = 7;
			INSERT INTO bdmis:mi_acumps_mes(fecha,sucursal,ejecutivo,nombre,producto,copsoltdc,copsolmeta)
				VALUES (vfecha_inser,vsuc_tienda,vpromotor,' ',vproducto, vnumero,vmeta);
		
		   
	end foreach;	

--	Insercion de compras del mismo mes
    let vpaso = 8;
	TRUNCATE TABLE mi_rcda_apert_paso;
   
	let vpaso = 9;
	UPDATE STATISTICS HIGH FOR TABLE "informix".mi_acumps_mes; 
   
      let vpaso = 10;     
	  
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
						SELECT  suc.num_sucursal,mp.metanum ,mp.aniomes
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
	
	  let vpaso = 11;
 -- paso de productividad de sucursales a acumulado mensual 
 
 		merge into mi_rcda_apert_paso a
		using (SELECT a.fecha,a.sucursal,a.tpo_reg, a.ejecutivo, a.nombre,a.producto, sum(a.numero) as numero,sum(meta) as meta 
		FROM mi_rcda_apert_paso a
			left join bdinteg:si_ejecut b on a.ejecutivo = b.ejecutivo
		where b.ejecutivo is null  group by 1,2,3,4,5,6) b
		on a.ejecutivo =b.ejecutivo and a.sucursal = b.sucursal and a.fecha =b.fecha and a.tpo_reg = b.tpo_reg and a.producto = b.producto and a.numero=b.numero
		WHEN MATCHED THEN update 
			set a.meta = 0;
			
			let vpaso = 12;
			INSERT INTO bdmis:mi_acumps_mes(fecha,sucursal,ejecutivo,nombre,producto,num_comp_mismomes,meta_comp_mismomes)
			select {+INDEX(mi_rcda_apert_paso idx_aprtpaso_cp)} fecha,sucursal,ejecutivo,nombre,producto,numero,meta from mi_rcda_apert_paso
			WHERE producto = '6111';
			
    --insercion del club de protecciÃ³n 			
	let vpaso = 13;
	TRUNCATE TABLE mi_rcda_apert_paso;
   
    let vpaso = 14;
	UPDATE STATISTICS HIGH FOR TABLE "informix".mi_acumps_mes; 

   --llenado de clientes clientes candidatos
   let vpaso = 15;
		merge into mi_rcda_apert_paso a
			USING ( SELECT LPAD(trim(cb.suc_tienda),4,'0') as sucursal, cb.promotor,
							fecha_primercompra  as fecha_candidato , COUNT(numcte) as num           
					FROM mi_rcda_infocoppel cb 
					where  cb.clave = 'G' AND  cb.cliente_cand_club = 'S' group by 1,2,3) b
		 on a.sucursal =b.sucursal and a.ejecutivo = b.promotor AND a.fecha = b.fecha_candidato
		WHEN NOT MATCHED THEN 
			INSERT (a.fecha,a.sucursal,a.tpo_reg,a.ejecutivo,a.producto,a.ctescand)
			VALUES  (b.fecha_candidato,b.sucursal,1, b.promotor,'7777',b.num);		
			
		
		   --llenado de clientes que compraron el club
		 let vpaso = 16;  
		merge into mi_rcda_apert_paso a
			USING (SELECT	 case when alt.sucursal is null then LPAD(trim(info.suc_tienda),4,'0') else alt.sucursal end as sucursal, 
			   case when alt.promotor is not null then alt.promotor
			   else  LPAD(trim(info.suc_tienda),8,'0') end as promotor, 
			   CASE  when alt.promotor is null then 'PROMOTOR VIRTUAL' END AS nombre,	   
			 info.fecha_primercompra as fecha_candidato  ,COUNT(info.numcte) as num	
			FROM mi_rcda_infocoppel info 
			left join  mi_rcda_altas_bcplrcd alt on info.numcte = alt.numcte 
			where info.clave ='G' AND info.compraclub = 'S' 
			group by 1,2,3,4  ) b 
				on a.sucursal = b.sucursal AND a.ejecutivo = b.promotor AND a.fecha = b.fecha_candidato
		WHEN NOT MATCHED THEN
					INSERT   (a.fecha,a.sucursal,a.tpo_reg,a.ejecutivo,a.nombre,a.producto,a.numero) 
						VALUES (b.fecha_candidato,b.sucursal,1,b.promotor,b.nombre,'7777', b.num)
		WHEN MATCHED THEN UPDATE
				set a.numero = b.num;
				
				
		--se obtiene la meta
	let vpaso = 17;	
	 merge into mi_rcda_apert_paso a
		USING ( SELECT paso.fecha,paso.sucursal,paso.tpo_reg,paso.ejecutivo,  mp.metanum
		FROM mi_rcda_apert_paso paso, mi_metasprod mp, mi_sucursalesinfo suc
		WHERE   mp.aniomes = ( year(paso.fecha)|| lpad(month(paso.fecha),2,'0'))
			   and paso.sucursal = suc.num_sucursal and mp.id_tiposuc = suc.tipo_suc AND mp.producto = '7777' )	b
		on 	   a.fecha = b.fecha and a.sucursal = b.sucursal and a.tpo_reg = b.tpo_reg and a.ejecutivo = b.ejecutivo
		WHEN MATCHED THEN UPDATE
		set a.meta = b.metanum;		
		
	RETURN cod_ret, mensaje;
		
	
END
END PROCEDURE;
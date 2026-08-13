CREATE PROCEDURE "informix".sp_rcda_club_proteccion()
RETURNING	CHAR (06) AS cod_ret,
			CHAR (80) AS mensaje;

--variables de retorno 
	DEFINE	cod_ret				CHAR (06);
	DEFINE	mensaje				CHAR (80);

--variables de control de errores
	DEFINE  SQL_ERR				INTEGER;
	DEFINE  ISAM_ERR			INTEGER;
	DEFINE  ERROR_INFO			VARCHAR(80);
	DEFINE	vpaso				INTEGER;
	
--variables del proceso
	DEFINE	dfecha				DATE;
	DEFINE	vfecha				CHAR(08);		
	DEFINE	ffecha				DATE;
	DEFINE	vsucursal			CHAR(04);
	DEFINE	vpromotor			CHAR(08);
	DEFINE	vnumero_cand		INTEGER;
	DEFINE	vnumero_comp		INTEGER;
	DEFINE	vnombre				CHAR(104);
	DEFINE	vnombrearchivo		CHAR(35);
	DEFINE	vfecha_primercompra DATE;
	DEFINE	vtpo_reg			INTEGER;
	DEFINE	vproducto			CHAR(04);
	DEFINE	vnumero				INTEGER;
	DEFINE	vmeta				money (18,4);
	DEFINE	vnumcte				CHAR(04);

BEGIN	
   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
      LET cod_ret    = SQL_ERR;
      LET mensaje  = ERROR_INFO || ' sp_rcda_club_proteccion en paso ' || vpaso;
	  insert into mi_rcda_cierresucerror (fecha_cierre,estatus_ejec,codigo_error,desc_error )
	  select fecha_ant,'F',cod_ret, mensaje  from bdmis:mi_fechas;
      RETURN cod_ret, mensaje;
   END EXCEPTION;
   
   let cod_ret = '00000';
   let mensaje = 'PROCESO EXITOSO';
   
   set isolation to dirty read;
   
   let vpaso = 1;
   select fecha_ant into dfecha from mi_fechas;
   
   let vpaso = 2;
   let vfecha = LPAD(DAY(dfecha),2,'0') || LPAD( MONTH(dfecha),2,'0') || YEAR(dfecha); 
   let vfecha = vfecha;
   
   
   let vnombrearchivo = 'BCPLRCD_' ||vfecha  ;
   
   let vnombrearchivo = vnombrearchivo;
    
	--DELETE FROM mi_aperturas WHERE fecha = dfecha and producto = '7777';
	
   	let vpaso = 3;
	TRUNCATE TABLE	mi_rcda_apert_paso;
	
	UPDATE STATISTICS HIGH FOR TABLE "informix".mi_acumps_mes; 
	
	
	/*	
	SELECT LPAD(trim(info.suc_tienda),4,'0') as sucursal, info.promotor,info.fecha_primercompra, COUNT(info.numcte) as num
	FROM mi_rcda_infocoppel info , mi_rcda_altas_bcplrcd alt 
	where info.cliente_cand_club = 'S' AND info.integridad = 'V' AND info.compraclub = 'S'
    AND info.numcte = alt.numcte AND ( alt.fecha   between date(info.fecha_primercompra)-30 AND info.fecha_primercompra)
	group by 1,2,3
	into temp tmp_compraclub WITH NO LOG;*/
	
   
   let vpaso = 4 ;
   
   --llenado de clientes clientes candidatos
   
  		merge into mi_rcda_apert_paso a
			USING ( SELECT LPAD(trim(cb.suc_tienda),4,'0') as sucursal, cb.promotor,
                            fecha_primercompra  as fecha_candidato , COUNT(numcte) as num           
                    FROM mi_rcda_infocoppel cb 
                    where  cb.clave = 'G' AND  cb.cliente_cand_club = 'S' group by 1,2,3) b
		 on a.sucursal =b.sucursal and a.ejecutivo = b.promotor AND a.fecha = b.fecha_candidato
		WHEN NOT MATCHED THEN 
			INSERT (a.fecha,a.sucursal,a.tpo_reg,a.ejecutivo,a.producto,a.ctescand)
			VALUES  (b.fecha_candidato,b.sucursal,1, b.promotor,'7777',b.num);		
			
   		
		
   
   let vpaso = 6;
   --llenado de clientes que compraron el club
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
	 merge into mi_rcda_apert_paso a
		USING ( SELECT paso.fecha,paso.sucursal,paso.tpo_reg,paso.ejecutivo,  mp.metanum
		FROM mi_rcda_apert_paso paso, mi_metasprod mp, mi_sucursalesinfo suc
		WHERE   mp.aniomes = ( year(paso.fecha)|| lpad(month(paso.fecha),2,'0'))
			   and paso.sucursal = suc.num_sucursal and mp.id_tiposuc = suc.tipo_suc AND mp.producto = '7777' )	b
		on 	   a.fecha = b.fecha and a.sucursal = b.sucursal and a.tpo_reg = b.tpo_reg and a.ejecutivo = b.ejecutivo
		WHEN MATCHED THEN UPDATE
		set a.meta = b.metanum;			
		
		
   
   let vpaso = 8;
 -- paso de productividad de sucursales a acumulado mensual
	UPDATE STATISTICS HIGH FOR TABLE "informix".mi_acumps_mes; 
	INSERT INTO bdmis:mi_acumps_mes(fecha,sucursal,ejecutivo,nombre,producto,clubncandidatos, clubncompraron,clubncompraronmeta)
	select fecha,sucursal,ejecutivo,nombre,producto,ctescand,numero,meta from mi_rcda_apert_paso
	WHERE  producto = '7777';		
		
	
--calculo de acumulado
	let vpaso = 9;
	/*INSERT INTO mi_rcda_apert_paso (fecha,sucursal,tpo_reg,ejecutivo,nombre,producto,ctescand,numero,meta)
	 select apert.fecha,mes.sucursal,2,mes.ejecutivo,mes.nombre,mes.producto, 
	 SUM(NVL(mes.clubncandidatos,0)), SUM(NVL(mes.clubncompraron,0)) , ((nvl(mes.clubncompraronmeta,0) * 24) / 30) * day (apert.fecha) 
    from mi_acumps_mes mes , mi_rcda_apert_paso apert
    WHERE (mes.fecha BETWEEN  (MONTH(apert.fecha)|| '/01/' || YEAR(apert.fecha)) AND apert.fecha) 
       and mes.sucursal = apert.sucursal and mes.producto = apert.producto AND mes.ejecutivo = apert.ejecutivo
	GROUP BY 1,2,3,4,5,6,9;*/
	
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
			INSERT INTO mi_rcda_apert_paso (fecha,sucursal,tpo_reg,ejecutivo,nombre,producto,ctescand,numero,meta)	 
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
		COMMIT WORK ;
			
			DROP TABLE tmp_metas_prod;
	
	END FOREACH;
	
	let vpaso = 11;
	UPDATE mi_rcda_apert_paso SET  meta = 0
	WHERE nombre = 'PROMOTOR VIRTUAL';
	
	
	let vpaso = 12;
	UPDATE mi_rcda_apert_paso set meta = 0
	WHERE ejecutivo IN (SELECT ejecutivo FROM bdinteg:si_ejecut WHERE puesto = '001');
	
	
	let vpaso = 13;
	UPDATE mi_rcda_apert_paso set meta = 0
	WHERE ejecutivo NOT IN (SELECT ejecutivo FROM bdinteg:si_ejecut );		
	
	

--paso historico
	let vpaso = 14;
	--diario
		   		merge into mi_his_productividad a
			USING ( SELECT	apert.fecha,apert.sucursal,apert.tpo_reg,apert.ejecutivo,
                    CASE WHEN apert.nombre is not null THEN apert.nombre
					ELSE (select nombre from bdinteg:si_ejecut eje where eje.ejecutivo = apert.ejecutivo ) end					
					as nombre 
                    ,apert.producto,apert.ctescand,sum(apert.numero) as numero,sum(apert.meta) as meta
                    FROM mi_rcda_apert_paso apert
                    WHERE  producto = '7777' and tpo_reg = 1 group by 1,2,3,4,5,6,7) b
		 on a.fecha = b.fecha AND a.sucursal = b.sucursal AND a.tpo_reg = b.tpo_reg AND a.ejecutivo = b.ejecutivo AND a.producto = b.producto
		WHEN NOT MATCHED THEN 
			INSERT  (a.fecha, a.sucursal, a.tpo_reg, a.ejecutivo ,a.nombre, a.producto, a.clubncandidatos, a.clubncompraron,a.clubncompraronmeta) 
			VALUES (b.fecha, b.sucursal, b.tpo_reg, b.ejecutivo, b.nombre, b.producto, b.ctescand,b.numero, b.meta)
        WHEN MATCHED THEN UPDATE     
                 SET a.clubncandidatos = a.clubncandidatos + b.ctescand , a.clubncompraron = a.clubncompraron + b.numero;		
		
		
		let vpaso = 15;
		
		
		-- acumulado
		
		foreach cursor1 WITH HOLD for
			SELECT	 apert.fecha,apert.sucursal,apert.tpo_reg,apert.ejecutivo,
			CASE WHEN apert.nombre is not null THEN apert.nombre
			ELSE (select nombre from bdinteg:si_ejecut eje where eje.ejecutivo = apert.ejecutivo ) end					
			as nombre 
			,apert.producto,apert.numero,meta   
			INTO 	ffecha,vsucursal,vtpo_reg,vpromotor,vnombre, vproducto, vnumero, vmeta
			FROM mi_rcda_apert_paso apert
			WHERE  producto = '7777' and tpo_reg = 2
			 
			
			delete FROM mi_his_productividad 
			where fecha = ffecha AND sucursal = vsucursal AND tpo_reg = vtpo_reg AND ejecutivo = vpromotor AND producto = vproducto;
		 
			
		END foreach;
		

   		/*merge into mi_his_productividad a
			USING ( SELECT	apert.fecha,apert.sucursal,apert.tpo_reg,apert.ejecutivo,
                    CASE WHEN apert.nombre is not null THEN apert.nombre
					ELSE (select nombre from bdinteg:si_ejecut eje where eje.ejecutivo = apert.ejecutivo ) end					
					as nombre 
                    ,apert.producto,apert.numero,meta                     
                    FROM mi_rcda_apert_paso apert
                    WHERE  producto = '7777' and tpo_reg = 2) b
		 on a.fecha = b.fecha AND a.sucursal = b.sucursal AND a.tpo_reg = b.tpo_reg AND a.ejecutivo = b.ejecutivo AND a.producto = b.producto
         WHEN MATCHED THEN 
         DELETE;*/
		 
		 

		 let vpaso = 16;

   		merge into mi_his_productividad a
			USING ( SELECT	apert.fecha,apert.sucursal,apert.tpo_reg,apert.ejecutivo,
                    CASE WHEN apert.nombre is not null THEN apert.nombre
					ELSE (select nombre from bdinteg:si_ejecut eje where eje.ejecutivo = apert.ejecutivo ) end					
					as nombre 
                    ,apert.producto,apert.ctescand,sum(apert.numero) as numero,sum(apert.meta) as meta
                    FROM mi_rcda_apert_paso apert
                    WHERE  producto = '7777' and tpo_reg = 2  group by 1,2,3,4,5,6,7) b
		 on a.fecha = b.fecha AND a.sucursal = b.sucursal AND a.tpo_reg = b.tpo_reg AND a.ejecutivo = b.ejecutivo AND a.producto = b.producto
         WHEN NOT MATCHED THEN 
                 INSERT (a.fecha,a.sucursal,a.tpo_reg,a.ejecutivo,a.nombre,a.producto,a.clubncandidatos, a.clubncompraron,a.clubncompraronmeta) 
                 VALUES (b.fecha,b.sucursal,b.tpo_reg,b.ejecutivo,b.nombre, b.producto,b.ctescand ,b.numero, b.meta);		
	
		
		
		let vpaso = 17;
		UPDATE mi_rcda_bitacoraarchivo SET fecha_hora_carga_tabla =  (SELECT DBINFO('utc_to_datetime', sh_curtime) FROM sysmaster:"informix".sysshmvals), fecha_hora_fin_proceso = (SELECT DBINFO('utc_to_datetime', sh_curtime) FROM sysmaster:"informix".sysshmvals), proceso = 'C' WHERE nombrearchivo = 'BCPLRCD_'|| vfecha  AND fecha_archivo =  dfecha ;	
	
    
   RETURN cod_ret, mensaje;
	
END
END PROCEDURE;
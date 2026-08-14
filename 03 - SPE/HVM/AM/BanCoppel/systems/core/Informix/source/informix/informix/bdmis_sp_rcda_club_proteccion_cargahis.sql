CREATE PROCEDURE "informix".sp_rcda_club_proteccion_cargahis()
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
	
	DEFINE 	ffecha 				date;
	DEFINE 	fsucursal 			CHAR(04); 
	DEFINE	ftpo_reg			INTEGER;
	DEFINE	fejecutivo			CHAR(08);
	DEFINE  fmeta				money (18,4);

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
   --select fecha_ant into dfecha from mi_fechas;
   
  -- let vpaso = 2;
   --let vfecha = LPAD(DAY(dfecha),2,'0') || LPAD( MONTH(dfecha),2,'0') || YEAR(dfecha); 
   --let vfecha = vfecha;
   
   
  -- let vnombrearchivo = 'BCPLRCD_' ||vfecha  ;
   
  -- let vnombrearchivo = vnombrearchivo;
    
	--DELETE FROM mi_aperturas WHERE fecha = dfecha and producto = '7777';
	
   	let vpaso = 3;
	TRUNCATE TABLE	mi_rcda_apert_paso;
	
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
                           case WHEN fecha_primercompra <> '01/01/1900' THEN fecha_primercompra
						   else   cb.fecha_apertura END  as fecha_candidato , COUNT(numcte) as num           
                    FROM mi_rcda_infocoppel_his cb 
                    where   cb.cliente_cand_club = 'S'  group by 1,2,3) b
		 on a.sucursal =b.sucursal and a.ejecutivo = b.promotor AND a.fecha = b.fecha_candidato
		WHEN NOT MATCHED THEN 
			INSERT (a.fecha,a.sucursal,a.tpo_reg,a.ejecutivo,a.producto,a.numero)
			VALUES  (b.fecha_candidato,b.sucursal,1, b.promotor,'7777',b.num);
			
   		
		
   
   let vpaso = 6;
   --llenado de clientes que compraron el club
		merge into mi_rcda_apert_paso a
			USING (SELECT	LPAD(trim(info.suc_tienda),4,'0') as sucursal, 
			   case when alt.promotor is not null then alt.promotor
			   else  LPAD(trim(info.suc_tienda),8,'0') end as promotor, 
			   CASE  when alt.promotor is null then 'PROMOTOR VIRTUAL' END AS nombre,	   
			 case when info.fecha_primercompra <> '01/01/1900' then info.fecha_primercompra
							else info.fecha_apertura end as fecha_candidato  ,COUNT(info.numcte) as num	
			FROM mi_rcda_infocoppel_his info 
			left join  mi_rcda_altas_bcplrcd alt  on info.numcte = alt.numcte 
			where  info.compraclub = 'S' 
			group by 1,2,3,4  ) b 
				on a.sucursal = b.sucursal AND a.ejecutivo = b.promotor AND a.fecha = b.fecha_candidato
		WHEN NOT MATCHED THEN
					INSERT   (a.fecha,a.sucursal,a.tpo_reg,a.ejecutivo,a.nombre,a.producto,a.meta) 
						VALUES (b.fecha_candidato,b.sucursal,1,b.promotor,b.nombre,'7777', b.num)
		WHEN MATCHED THEN UPDATE
				set a.meta = b.num;
				 
		
	 FOREACH cursor1 WITH HOLD for
		SELECT unique paso.fecha,paso.sucursal,paso.tpo_reg,paso.ejecutivo,  mp.metanum
		into  ffecha, fsucursal, ftpo_reg, fejecutivo,fmeta
		FROM mi_rcda_apert_paso paso, mi_metasprod mp, mi_sucursalesinfo suc
		WHERE   mp.aniomes = ( year(paso.fecha)|| lpad(month(paso.fecha),2,'0'))
			   and paso.sucursal = suc.num_sucursal and mp.id_tiposuc = suc.tipo_suc AND mp.producto = '7777'
		
		update mi_rcda_apert_paso set meta =fmeta where fecha=ffecha and sucursal=fsucursal and  tpo_reg=ftpo_reg;
		
	end foreach;
		 
		
		/*
	 merge into mi_rcda_apert_paso a
		USING ( SELECT paso.fecha,paso.sucursal,paso.tpo_reg,paso.ejecutivo,paso.nombre,  mp.metanum
		FROM mi_rcda_apert_paso paso, mi_metasprod mp, mi_sucursalesinfo suc
		WHERE   mp.aniomes = ( year(paso.fecha)|| lpad(month(paso.fecha),2,'0'))
			   and paso.sucursal = suc.num_sucursal and mp.id_tiposuc = suc.tipo_suc AND mp.producto = '7777')	b
		on 	   a.fecha = b.fecha and a.sucursal = b.sucursal and a.tpo_reg = b.tpo_reg and a.ejecutivo = b.ejecutivo
		WHEN MATCHED THEN UPDATE
		set a.meta = b.metanum;		*/
			
		
		
   
   let vpaso = 8;
 -- paso de productividad de sucursales a acumulado mensual
	UPDATE STATISTICS HIGH FOR TABLE "informix".mi_acumps_mes; 
	INSERT INTO bdmis:mi_acumps_mes(fecha,sucursal,ejecutivo,nombre,producto,clubncandidatos, clubncompraron)
	select fecha,sucursal,ejecutivo,nombre,producto,numero,meta from mi_rcda_apert_paso
	WHERE  producto = '7777';			
		
	
--calculo de acumulado
	let vpaso = 9;
	FOREACH cursor1 WITH HOLD for	
	SELECT distinct(fecha)
    INTO	dfecha
	FROM mi_rcda_apert_paso	
	
		INSERT INTO mi_rcda_apert_paso (fecha,sucursal,tpo_reg,ejecutivo,nombre,producto,numero,meta)
		 select --{+INDEX(mi_acumps_mes idx_acms_cp)} {+INDEX(mi_rcda_apert_paso idx_aprtpaso_cp)} 
		 apert.fecha,mes.sucursal,2 as tpo_reg,mes.ejecutivo,mes.nombre,mes.producto, 
		 SUM(NVL(mes.clubncandidatos,0)) as candidatos, SUM(NVL(mes.clubncompraron,0))as  compraron
		from mi_rcda_apert_paso apert
		   inner join mi_acumps_mes mes  on  
			mes.sucursal = apert.sucursal and  mes.ejecutivo = apert.ejecutivo and apert.fecha= dfecha
		where  mes.producto = apert.producto and
			  (mes.fecha BETWEEN  DATE( MONTH(apert.fecha)|| '/01/'  || YEAR(apert.fecha))  AND apert.fecha) 
		GROUP BY 1,2,3,4,5,6;
	
	
	
	/*INSERT INTO mi_rcda_apert_paso (fecha,sucursal,tpo_reg,ejecutivo,nombre,producto,numero,meta)
	 select {+INDEX(mi_acumps_mes idx_acms_cp)} {+INDEX(mi_rcda_apert_paso idx_aprtpaso_cp)} 
	 apert.fecha,mes.sucursal,2,mes.ejecutivo,mes.nombre,mes.producto, 
	 SUM(NVL(mes.clubncandidatos,0)), SUM(NVL(mes.clubncompraron,0)) 
    from mi_acumps_mes mes , mi_rcda_apert_paso apert
    WHERE (mes.fecha BETWEEN  DATE(MONTH(apert.fecha)|| '/01/' || YEAR(apert.fecha)) AND apert.fecha) 
       and mes.sucursal = apert.sucursal and  mes.ejecutivo = apert.ejecutivo AND mes.producto = apert.producto 
	GROUP BY 1,2,3,4,5,6;*/
	
	
	END FOREACH 

--paso historico
	let vpaso = 10;
	--diario
		   		merge into mi_his_productividad a
			USING ( SELECT	apert.fecha,apert.sucursal,apert.tpo_reg,apert.ejecutivo,
                    CASE WHEN apert.nombre is not null THEN apert.nombre
					ELSE (select nombre from bdinteg:si_ejecut eje where eje.ejecutivo = apert.ejecutivo ) end					
					as nombre 
                    ,apert.producto,apert.numero,meta                     
                    FROM mi_rcda_apert_paso apert
                    WHERE  producto = '7777' and tpo_reg = 1) b
		 on a.fecha = b.fecha AND a.sucursal = b.sucursal AND a.tpo_reg = b.tpo_reg AND a.ejecutivo = b.ejecutivo AND a.producto = b.producto
		WHEN NOT MATCHED THEN 
			INSERT  (a.fecha, a.sucursal, a.tpo_reg, a.ejecutivo ,a.nombre, a.producto, a.clubncandidatos, a.clubncompraron) 
			VALUES (b.fecha, b.sucursal, b.tpo_reg, b.ejecutivo, b.nombre, b.producto, b.numero, b.meta)
        WHEN MATCHED THEN UPDATE     
                 SET a.clubncandidatos = a.clubncandidatos + b.numero , a.clubncompraron = a.clubncompraron + b.meta;		
		
		
		let vpaso = 11;
		
		
		-- acumulado

   		merge into mi_his_productividad a
			USING ( SELECT	apert.fecha,apert.sucursal,apert.tpo_reg,apert.ejecutivo,
                    CASE WHEN apert.nombre is not null THEN apert.nombre
					ELSE (select nombre from bdinteg:si_ejecut eje where eje.ejecutivo = apert.ejecutivo ) end					
					as nombre 
                    ,apert.producto,apert.numero,meta                     
                    FROM mi_rcda_apert_paso apert
                    WHERE  producto = '7777' and tpo_reg = 2) b
		 on a.fecha = b.fecha AND a.sucursal = b.sucursal AND a.tpo_reg = b.tpo_reg AND a.ejecutivo = b.ejecutivo AND a.producto = b.producto
         WHEN MATCHED THEN 
         DELETE;
		 
		 

		 let vpaso = 12;

   		merge into mi_his_productividad a
			USING ( SELECT	apert.fecha,apert.sucursal,apert.tpo_reg,apert.ejecutivo,
                    CASE WHEN apert.nombre is not null THEN apert.nombre
					ELSE (select nombre from bdinteg:si_ejecut eje where eje.ejecutivo = apert.ejecutivo ) end					
					as nombre 
                    ,apert.producto,apert.numero,meta                     
                    FROM mi_rcda_apert_paso apert
                    WHERE  producto = '7777' and tpo_reg = 2) b
		 on a.fecha = b.fecha AND a.sucursal = b.sucursal AND a.tpo_reg = b.tpo_reg AND a.ejecutivo = b.ejecutivo AND a.producto = b.producto
         WHEN NOT MATCHED THEN 
                 INSERT (a.fecha,a.sucursal,a.tpo_reg,a.ejecutivo,a.nombre,a.producto,a.clubncandidatos, a.clubncompraron) 
                 VALUES (b.fecha,b.sucursal,b.tpo_reg,b.ejecutivo,b.nombre, b.producto, b.numero, b.meta);

		
		
		
		
		let vpaso = 13;
		--UPDATE mi_rcda_bitacoraarchivo SET fecha_hora_carga_tabla =  (SELECT DBINFO('utc_to_datetime', sh_curtime) FROM sysmaster:"informix".sysshmvals), fecha_hora_fin_proceso = (SELECT DBINFO('utc_to_datetime', sh_curtime) FROM sysmaster:"informix".sysshmvals), proceso = 'C' WHERE nombrearchivo = 'BCPLRCD_'|| vfecha  AND fecha_archivo =  dfecha ;	
	
    
   RETURN cod_ret, mensaje;
	
END
END PROCEDURE;
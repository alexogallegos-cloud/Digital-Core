CREATE PROCEDURE "informix".sp_bcplr_repro()
RETURNING 	CHAR	(08)	AS	cod_ret,
			CHAR	(80)	AS	mensaje;
			
--variables de retorno
	DEFINE	cod_ret	CHAR(08)	;
	DEFINE	mensaje	CHAR(80)	;
	
--variables de control de errores
	DEFINE  SQL_ERR		INTEGER;
	DEFINE  ISAM_ERR	INTEGER;
	DEFINE  ERROR_INFO	VARCHAR(80);
	DEFINE	vpaso		INTEGER;

--variables del proceso
	DEFINE	vruta		CHAR(0120);
	DEFINE	vsql		CHAR(1120);
	DEFINE	dfecha		DATE;
	DEFINE	vfecha		CHAR(08);	
	DEFINE	vtipo		INTEGER;
	DEFINE	vtotal		INTEGER;
	DEFINE	vdetalle	CHAR(35);
	DEFINE	vresumen	CHAR(35);
	
	DEFINE	vfecha_min	DATE;
	DEFINE	vfecha_max	DATE;

BEGIN
   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
      LET cod_ret    = SQL_ERR;
      LET mensaje  = ERROR_INFO || ' sp_bcplr_repro en paso ' || vpaso;
	  insert into mi_rcda_cierresucerror (fecha_cierre,estatus_ejec,codigo_error,desc_error )
	  select fecha_ant,'F',cod_ret, mensaje  from bdmis:mi_fechas;
      RETURN cod_ret, mensaje;
   END EXCEPTION;
   
   let cod_ret = '000000';
   let mensaje = 'PROCESO EXITOSO';
   
   set isolation to dirty read;	
	
	
   --ruta de archivos 
	let vpaso = 1;
	SELECT trim(descripcion) into vruta FROM mi_param WHERE parametro = 6111;
	
	let vpaso = 2;
   --obtener nombres de archivos 
    FOREACH cursor1 WITH HOLD FOR 
		SELECT TRIM(detalle), TRIM(resumen) INTO vdetalle, vresumen FROM mi_bcplr_especiales
		let vpaso = 3;
		
		TRUNCATE TABLE "informix".mi_rcda_infocoppel_paso;
		
		let vpaso = 4;
		DELETE FROM "informix".mi_rcda_archivo_cifcontrol;
	
	   --detalle del archivo  
	   let vpaso = 5;
	   let vsql = " echo 'load from " ||trim(vruta)|| TRIM(vdetalle) || " INSERT INTO mi_rcda_infocoppel_paso ;'>"||trim(vruta)|| "carga_infocoppel_rep.sql";
	   let vpaso = 6;
	   SYSTEM vsql;  
	   
	   let vpaso = 7;
	   LET vsql = 'dbaccess bdmis ' || trim(vruta) || 'carga_infocoppel_rep.sql';
	   let vpaso = 8;
	   SYSTEM vsql;
	   
	   --resumen del archivo
	   
	   let vpaso = 9;
	   let vsql = " echo 'load from " ||trim(vruta)|| TRIM(vresumen) || " INSERT INTO mi_rcda_archivo_cifcontrol;'>"||trim(vruta)|| "carga_infocoppel_rep.sql";
	   let vpaso = 10;
	   SYSTEM vsql;  
	   
	   let vpaso = 11;
	   LET vsql = 'dbaccess bdmis ' || trim(vruta) || 'carga_infocoppel_rep.sql';
	   let vpaso = 12;
	   SYSTEM vsql; 
		
		let vpaso = 13;
		foreach 
			SELECT CASE WHEN clave = ''  THEN 1
						WHEN clave = 'A' THEN 2
						WHEN clave = 'V' THEN 3
						WHEN clave = 'G' THEN 4
						WHEN clave = 'M' THEN 5
				end AS TIPO,
			   count(*) as total
			INTO vtipo, vtotal
			FROM mi_rcda_infocoppel_paso group by 1
				
				let vpaso = 14;
				IF (SELECT totalregistros  FROM mi_rcda_archivo_cifcontrol WHERE tipo = vtipo ) <> vtotal THEN
					
					let cod_ret = '000003';
					let mensaje = 'DETALLE ' || TRIM(vdetalle) || ' NO CORRESPONDE CON CIFRAS CONTROL';	
					RETURN cod_ret, mensaje;
				
				END IF
			
		END foreach
		--validacion del archivo
		let vpaso = 15;
		EXECUTE PROCEDURE "informix".sp_bcplr_validaarchivo(vdetalle)
		INTO cod_ret, mensaje;
		IF cod_ret <> '00000' THEN
			RETURN cod_ret, mensaje;
		END IF		
		
		--integracion de la informacion a la tabla 
		let vpaso = 16;
		EXECUTE PROCEDURE "informix".sp_bcplr_integracion (vdetalle)
		INTO cod_ret, mensaje;
		IF cod_ret <> '00000' THEN
			RETURN cod_ret, mensaje;
		END IF
	
	
		
	END FOREACH
	
	--elimina registros incorrectos de aperturas
	
	DELETE FROM mi_rcda_altas_bcplrcd 
	WHERE numcte in ('0','1','2','3','4','5','6','7','8','9');
	
	--se eliminan los registros de compras con errores
	delete FROM mi_acumps_mes  WHERE fecha >= '08/02/2015' and producto = '6111';
	
	-- carga las aperturas
	
	INSERT INTO mi_rcda_altas_bcplrcd(nombrearchivo, fecha, promotor, numcte,sucursal) 
	select	{+INDEX(mi_rcda_infocoppel idx_infocoppel_clave)}
	nombrearchivo,fecha_apertura,promotor,numcte ,suc_tienda
	from 	mi_rcda_infocoppel 
	where clave = 'A' ;
	
	merge into mi_acumps_mes  a
	using (
			SELECT promotor, suc_tienda,
			case    when clave = 'A' then  fecha_apertura
					when clave = ' ' then  fecha_inser       
					when clave = 'G' then  fecha_primercompra
					end as fecha,
			case    when clave = 'A' then  '6566'
					when clave = ' ' then  '6500'
					when clave = 'G' then  '7777'  
					end as producto,
			count(*) as num
			FROM mi_rcda_infocoppel where clave in ('A',' ','G')
			group by 1,2,3,4)   b
	on a.ejecutivo = b.promotor and  a.sucursal = b.suc_tienda and  
	a.fecha = b.fecha and a.producto = b.producto 
	WHEN MATCHED THEN  DELETE;
	
	
	EXECUTE PROCEDURE "informix".sp_bcpl_acumpsmes()
	INTO cod_ret, mensaje;
	IF cod_ret <> '000000' THEN
		RETURN cod_ret, mensaje;
	END IF
	
	SELECT	min(fechageneracion) , max(fechageneracion)
	INTO	vfecha_min, vfecha_max
	FROM mi_rcda_infocoppel;  
	
	EXECUTE PROCEDURE "informix".sp_repro_rcda_coppelb( vfecha_min,vfecha_max )
	INTO cod_ret, mensaje;
	IF cod_ret <> '00000000' THEN
		RETURN cod_ret, mensaje;
	END IF
	
	
	
	RETURN cod_ret, mensaje;
END
END PROCEDURE;
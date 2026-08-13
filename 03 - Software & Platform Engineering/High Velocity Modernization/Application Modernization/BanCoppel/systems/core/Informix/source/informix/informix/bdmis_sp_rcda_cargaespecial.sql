CREATE	PROCEDURE "informix".sp_rcda_cargaespecial (pfecha DATE)
RETURNING	CHAR (06) AS cod_ret,
			CHAR (80) AS mensaje;
	
--variables de retorno
	DEFINE	cod_ret			CHAR(06);
	DEFINE	mensaje			CHAR(80);

--variables de control de errores
	DEFINE  SQL_ERR			INTEGER;
	DEFINE  ISAM_ERR		INTEGER;
	DEFINE  ERROR_INFO		VARCHAR(80);
	DEFINE	vpaso			INTEGER;

--variables de proceso
	DEFINE	vnombre			CHAR(35);
	DEFINE	vruta			CHAR(0120);
	DEFINE	vsql			CHAR(1120);
	DEFINE	vfecha			CHAR(08);	
	DEFINE	vtipo			INTEGER;
	DEFINE	vtotal			INTEGER;
	

BEGIN
	ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
      LET cod_ret    = SQL_ERR;
      LET mensaje  = ERROR_INFO || ' sp_rcda_cargaespecial en paso ' || vpaso;
	  insert into mi_rcda_cierresucerror (fecha_cierre,estatus_ejec,codigo_error,desc_error )
	  select fecha_ant,'F',cod_ret, mensaje  from bdmis:mi_fechas;
      RETURN cod_ret, mensaje;
	END EXCEPTION;
		
	
	--set debug file TO "sp_rcda_cargaespecial.out";
	--trace on;
		
	let cod_ret = '00000';
	let mensaje = 'PROCESO EXITOSO';
	
	SET ISOLATION TO dirty READ;
	
	let vpaso = 1;
	let vfecha = LPAD(DAY(pfecha),2,'0') || LPAD( MONTH(pfecha),2,'0') || YEAR(pfecha);

	let	vpaso = 2;
	let vnombre = 'BCPLRCD_' || vfecha;
	
	let	vpaso = 3;
	SELECT trim(descripcion) into vruta FROM mi_param WHERE parametro = 6111;
	
	let vpaso = 4;
	if (SELECT COUNT(*) FROM mi_rcda_bitacoraarchivo WHERE nombrearchivo = vnombre and fecha_archivo = pfecha and proceso = 'C' ) > 0 THEN
	
			let cod_ret = '000002';
			let mensaje = 'PROCESO CONCLUIDO ANTERIORMENTE';	
			RETURN cod_ret, mensaje;				
			
	END IF
	
	let	vpaso = 5;
	TRUNCATE TABLE mi_rcda_infocoppel_cargaespecial ;
	DELETE FROM mi_rcda_archivo_cifcontrol; 
	
	IF (SELECT COUNT(*) FROM mi_rcda_bitacoraarchivo WHERE nombrearchivo = "BCPLRCD_" || vfecha and fecha_archivo = pfecha  ) = 0 THEN
   
		insert into  mi_rcda_bitacoraarchivo (nombrearchivo, fecha_archivo, fecha_proceso,  fecha_hora_ini_proceso) 
		values ('BCPLRCD_'|| vfecha , pfecha ,pfecha, (SELECT DBINFO('utc_to_datetime', sh_curtime) FROM sysmaster:"informix".sysshmvals) );		
		
	END IF
	
	let vpaso = 6;
	let vsql = " echo 'load from " ||trim(vruta)||  TRIM(vnombre) || ".txt INSERT INTO mi_rcda_infocoppel_cargaespecial ;'>"||trim(vruta)|| "carga_infocoppel.sql";
	let vpaso = 7;
	SYSTEM vsql;  
   
	let vpaso = 8;
	LET vsql = 'dbaccess bdmis ' || trim(vruta) || 'carga_infocoppel.sql';
	let vpaso = 9;
	SYSTEM vsql;
	
	let	vpaso = 10;
	UPDATE mi_rcda_bitacoraarchivo 
	SET fecha_hora_carga_archivo =  (SELECT DBINFO('utc_to_datetime', sh_curtime) FROM sysmaster:"informix".sysshmvals) 
	WHERE nombrearchivo = 'BCPLRCD_'|| vfecha  AND fecha_archivo =  pfecha ;
	
	let vpaso = 11;
	let vsql = " echo 'load from " ||trim(vruta)|| "BCPLRCC_" || TRIM(vfecha) || ".txt INSERT INTO mi_rcda_archivo_cifcontrol;'>"||trim(vruta)|| "carga_infocoppel.sql";
	let vpaso = 12;
	SYSTEM vsql;  
   
	let vpaso = 13;
	LET vsql = 'dbaccess bdmis ' || trim(vruta) || 'carga_infocoppel.sql';
	let vpaso = 14;
	SYSTEM vsql;  
	
	foreach 
		SELECT CASE WHEN clave = ''  THEN 1
					WHEN clave = 'A' THEN 2
                    WHEN clave = 'V' THEN 3
                    WHEN clave = 'G' THEN 4
                    WHEN clave = 'M' THEN 5
			end AS TIPO,
           count(*) as total
		INTO vtipo, vtotal
		FROM mi_rcda_infocoppel_cargaespecial group by 1
   
		IF (SELECT totalregistros  FROM mi_rcda_archivo_cifcontrol WHERE tipo = vtipo ) <> vtotal THEN
			
			let cod_ret = '000003';
			let mensaje = 'DETALLE DE ARCHIVO NO CORRESPONDE CON CIFRAS CONTROL';	
			RETURN cod_ret, mensaje;
		
		END IF
			
	end foreach
			
	
	let vpaso = 15;
   UPDATE mi_rcda_bitacoraarchivo set num_registros = (select COUNT(*) FROM mi_rcda_infocoppel_paso) 
   WHERE nombrearchivo = "BCPLRCD_" || vfecha and fecha_archivo = pfecha ;

   
   ---- proceso de validacion de integridad de archivo
   EXECUTE PROCEDURE "informix".sp_rcda_validaarchivo_especial (pfecha)
   INTO cod_ret, mensaje;
	IF cod_ret <> '00000' THEN		
		RETURN cod_ret, mensaje;   
	END IF
	
	-- proceso de integracion de datos a tabla de proceso
	EXECUTE PROCEDURE "informix".sp_rcda_infocoppel_integracion_especial (pfecha)
	INTO cod_ret, mensaje;
	IF cod_ret <> '00000' THEN		
		RETURN cod_ret, mensaje;   
	END IF
	
	EXECUTE PROCEDURE "informix".sp_rcda_obtaperturas_archivoespecial(pfecha)
	INTO cod_ret, mensaje;
	IF cod_ret <> '00000' THEN		
		RETURN cod_ret, mensaje;   
	END IF
	
	EXECUTE PROCEDURE "informix".sp_rcda_obtsolcoppel_archivoespecial(pfecha)
	INTO cod_ret, mensaje;
	IF cod_ret <> '00000' THEN		
		RETURN cod_ret, mensaje;   
	END IF
	
	EXECUTE PROCEDURE "informix".sp_rcda_obtcompras_archivoespecial(pfecha)
	INTO cod_ret, mensaje;
	IF cod_ret <> '00000' THEN		
		RETURN cod_ret, mensaje;   
	END IF
	
	EXECUTE PROCEDURE "informix".sp_rcda_club_proteccion_archivoespecial(pfecha)
	INTO cod_ret, mensaje;
	IF cod_ret <> '00000' THEN		
		RETURN cod_ret, mensaje;   
	END IF
	
	let vpaso = 15;
	UPDATE mi_rcda_bitacoraarchivo SET fecha_hora_carga_tabla =  (SELECT DBINFO('utc_to_datetime', sh_curtime) FROM sysmaster:"informix".sysshmvals), fecha_hora_fin_proceso = (SELECT DBINFO('utc_to_datetime', sh_curtime) FROM sysmaster:"informix".sysshmvals), proceso = 'C' WHERE nombrearchivo = 'BCPLRCD_'|| vfecha  AND fecha_archivo =  pfecha ;	
	
	RETURN cod_ret, mensaje; 
END
END	PROCEDURE;
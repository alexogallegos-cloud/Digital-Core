CREATE PROCEDURE "informix".sp_rcda_infocoppel()
RETURNING CHAR (06) as cod_ret,
		  CHAR (80) as mensaje;

--variables de retorno 
	DEFINE	cod_ret		CHAR (06);
	DEFINE	mensaje		CHAR (80);

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

BEGIN
   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
      LET cod_ret    = SQL_ERR;
      LET mensaje  = ERROR_INFO || ' sp_rcda_infocoppel en paso ' || vpaso;
	  insert into mi_rcda_cierresucerror (fecha_cierre,estatus_ejec,codigo_error,desc_error )
	  select fecha_ant,'F',cod_ret, mensaje  from bdmis:mi_fechas;
      RETURN cod_ret, mensaje;
   END EXCEPTION;
   
   let cod_ret = '000000';
   let mensaje = 'PROCESO EXITOSO';
   --DDMMAAAA
   set isolation to dirty read;
   
   let vpaso = 1;
   select fecha_ant into dfecha from mi_fechas;
   
   let vpaso = 2;
   let vfecha = LPAD(DAY(dfecha),2,'0') || LPAD( MONTH(dfecha),2,'0') || YEAR(dfecha);
   
     let vpaso = 5;
   SELECT trim(descripcion) into vruta FROM mi_param WHERE parametro = 6111;
   
   let vpaso = 3;
    if (SELECT COUNT(*) FROM mi_rcda_bitacoraarchivo WHERE nombrearchivo = "BCPLRCD_" || vfecha and fecha_archivo = dfecha and proceso = 'C' ) > 0 THEN
	
			let cod_ret = '000002';
			let mensaje = 'PROCESO CONCLUIDO ANTERIORMENTE';	
			RETURN cod_ret, mensaje;
				
			
	END IF
	
	
	TRUNCATE TABLE "informix".mi_rcda_infocoppel_paso;
				
	DELETE FROM "informix".mi_rcda_archivo_cifcontrol;
	
	/* ######### descarga archivo de detalle ######### */
	let vpaso = 4;
	IF (SELECT COUNT(*) FROM mi_rcda_bitacoraarchivo WHERE nombrearchivo = "BCPLRCD_" || vfecha and fecha_archivo = dfecha  ) = 0 THEN
   
		insert into  mi_rcda_bitacoraarchivo (nombrearchivo, fecha_archivo, fecha_proceso,  fecha_hora_ini_proceso) values ('BCPLRCD_'|| vfecha  , dfecha ,dfecha, (SELECT DBINFO('utc_to_datetime', sh_curtime) FROM sysmaster:"informix".sysshmvals) );
		
		/*let vsql =	'echo "insert into  mi_rcda_bitacoraarchivo (nombrearchivo, fecha_archivo, fecha_proceso,  fecha_hora_ini_proceso) values (''' || "BCPLRCD_" || vfecha || ".txt','"|| dfecha || "','"||dfecha || ''',CURRENT );"> '||trim(vruta)|| "query_bitacora.sql";
		SYSTEM vsql; 
		
		LET vsql = 'dbaccess bdmis ' || trim(vruta) || 'query_bitacora.sql';
		SYSTEM vsql;*/
		
	END IF
	

   let vpaso = 6;
   let vsql = " echo 'load from " ||trim(vruta)|| "BCPLRCD_" || trim(vfecha) || ".txt INSERT INTO mi_rcda_infocoppel_paso ;'>"||trim(vruta)|| "carga_infocoppel.sql";
   let vpaso = 7;
   SYSTEM vsql;  
   
   let vpaso = 8;
   LET vsql = 'dbaccess bdmis ' || trim(vruta) || 'carga_infocoppel.sql';
   let vpaso = 9;
   SYSTEM vsql;
   
   let vpaso = 10;
   
   UPDATE mi_rcda_bitacoraarchivo SET fecha_hora_carga_archivo =  (SELECT DBINFO('utc_to_datetime', sh_curtime) FROM sysmaster:"informix".sysshmvals) WHERE nombrearchivo = 'BCPLRCD_'|| vfecha  AND fecha_archivo =  dfecha ;
   
   /*
   let vsql = 'echo " UPDATE mi_rcda_bitacoraarchivo SET fecha_hora_carga_archivo = CURRENT WHERE nombrearchivo = '''||"BCPLRCD_" || vfecha || "' AND fecha_archivo = '" || dfecha || ''';">'||trim(vruta)|| "query_bitacora.sql";
   let vpaso = 11;
   SYSTEM vsql; 
		
   let vpaso = 12;	
   LET vsql = 'dbaccess bdmis ' || trim(vruta) || 'query_bitacora.sql';
   let vpaso = 13;
   SYSTEM vsql;*/
   
   /* ######### descarga archivo de cifras control ######### */
   
   let vpaso = 11;
   let vsql = " echo 'load from " ||trim(vruta)|| "BCPLRCC_" || trim(vfecha) || ".txt INSERT INTO mi_rcda_archivo_cifcontrol;'>"||trim(vruta)|| "carga_infocoppel.sql";
   let vpaso = 12;
   SYSTEM vsql;  
   
   let vpaso = 13;
   LET vsql = 'dbaccess bdmis ' || trim(vruta) || 'carga_infocoppel.sql';
   let vpaso = 14;
   SYSTEM vsql;   
   
   /* ######### valida el contenido del archivo de detalle con el de cifras control ######### */
   
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
   
		IF (SELECT totalregistros  FROM mi_rcda_archivo_cifcontrol WHERE tipo = vtipo ) <> vtotal THEN
			
			let cod_ret = '000003';
			let mensaje = 'DETALLE DE ARCHIVO NO CORRESPONDE CON CIFRAS CONTROL';	
			RETURN cod_ret, mensaje;
		
		END IF
			
	end foreach
   
   let vpaso = 15;
   UPDATE mi_rcda_bitacoraarchivo set num_registros = (select COUNT(*) FROM mi_rcda_infocoppel_paso) WHERE nombrearchivo = "BCPLRCD_" || vfecha and fecha_archivo = dfecha ;
   
   
   EXECUTE PROCEDURE "informix".sp_rcda_validaarchivo()
   INTO cod_ret, mensaje;
   IF cod_ret <> '00000' THEN
		RETURN cod_ret, mensaje;
   END IF
   
   EXECUTE PROCEDURE "informix".sp_rcda_infocoppel_integracion ()
   INTO cod_ret, mensaje;
   IF cod_ret <> '00000' THEN
		RETURN cod_ret, mensaje;
   END IF
   
   EXECUTE PROCEDURE "informix".sp_rcda_obtaperturas()
   INTO cod_ret, mensaje;
   IF cod_ret <> '00000' THEN
		RETURN cod_ret, mensaje;
   END IF
   
   EXECUTE PROCEDURE "informix".sp_rcda_obtsolcoppel()
   INTO cod_ret, mensaje;
   IF cod_ret <> '00000' THEN
		RETURN cod_ret, mensaje;
   END IF
   
   EXECUTE PROCEDURE "informix".sp_rcda_obtcompras()
   INTO cod_ret, mensaje;
   IF cod_ret <> '00000' THEN
		RETURN cod_ret, mensaje;
   END IF
   
   execute PROCEDURE "informix".sp_rcda_club_proteccion()
   INTO cod_ret, mensaje;
   IF cod_ret <> '00000' THEN
		RETURN cod_ret, mensaje;
   END IF
   
   
   RETURN cod_ret, mensaje;
   
   
	
END
end PROCEDURE;
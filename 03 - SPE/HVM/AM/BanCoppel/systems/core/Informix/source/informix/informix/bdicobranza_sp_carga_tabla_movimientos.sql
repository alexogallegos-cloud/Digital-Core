CREATE PROCEDURE "informix".sp_carga_tabla_movimientos()

RETURNING CHAR(6), CHAR(80);
/*
___________________________________________________________________________________________________________________________________________________________________________
	MODIFICADO POR: Abrham Lopez Lopez.
	FECHA: 24-01-2012.
	DESCRIPCION: Se modifica para que se quede registro de la ejecucion de SP en bitacora.
	BASE DE DATOS: bdicobranza.
Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯
 Modificacion: Marco A. Campos
 Descripcion: Eliminar llamado a sp_carga_sms_latinia porque ahora se carga la informacion por proceso batch. 2013-12-18.
*/
--DECLARACION DE VARIABLES
	DEFINE sql_err		INTEGER;
	DEFINE isam_err		INTEGER;
	DEFINE error_info	CHAR(80);
	DEFINE cCod_ret		CHAR(6);
	DEFINE vempresa     CHAR(3);
	DEFINE cproceso     CHAR(4);
	DEFINE vvcCod_ret   CHAR(6);
	DEFINE cMensaje		CHAR(80);
	DEFINE cCadena		CHAR(500);
	DEFINE vRuta		CHAR(100);
	DEFINE cSql         CHAR(2204);	
	DEFINE vNomArch     CHAR(2204);	
	DEFINE X 			CHAR(100);
	DEFINE pNomArch 	CHAR(100);
	DEFINE vfecha 		DATE;
	DEFINE vRutasql		CHAR(50);
	DEFINE v_clienteact	CHAR(9);
	DEFINE v_cliente 	CHAR(9);
	
--	 SET DEBUG FILE TO "sp_carga_tabla_movimientos.out ";
--	 TRACE ON;

--DEFINICION DE VARIABLES
	LET cCod_ret  	= "000000";
	LET sql_err   	= 0;
	LET cMensaje  	= "PROCESO EXITOSO";
	LET cCadena   	= "";
	LET vRuta     	= "";
	LET cSql      	= "";
	LET vempresa    = '001';
	LET cproceso    = '2000';
	LET vNomArch    = "";
	LET X 			= '';
	LET pNomArch 	= '';
	let vfecha 		= DATE(1);
	LET vRutasql 	= "/ifxsif01/Control-M/";
	LET v_clienteact = "";
	LET v_cliente 	= "";

      BEGIN
  
        ON EXCEPTION SET sql_err, isam_err, error_info
	        LET cCod_ret = sql_err;
			LET cMensaje = error_info;
		  CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso, cCod_ret, cMensaje, '02')
            RETURNING vvcCod_ret;
			    RETURN cCod_ret, cMensaje;	    
	    END EXCEPTION;
		
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
		
	--SE MANDA LLAMAR SP PARA INSERTAR EN BITACORA EL INICIO DE LA EJECUCION DE SP
		 CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso, cCod_ret, cMensaje, '01')
            RETURNING vvcCod_ret;
 
 --SELECCIONAMOS LA FECHA DEL DIA
	select fecha_hoy 
		into vfecha 
		from bdicred:sd_fechas 
		where empresa = '001';

--temporal solo para pruebas
--let vfecha = mdy('09','12','2018');
--temporal solo para pruebas
			
		--SELECCIONAMOS LA RUTA 
            select valor_alfabetico 
			into vRuta 
            from bdicobranza:cb_param_campania
            where empresa = '001'
				and tipo_campania = 1
				and grupo_parametro = 'ARCHIVOS'
				and num_parametro = 9;	--9 RUTA EN PRODUCCION			
		
		--ASIGNAMOS NOMBRE AL ARCHIVO
		LET pNomArch = 'movimientosctbcpl_'|| to_char(vfecha,'%d%m%Y')||'.txt.gz';

		--DESCOMPRIMIMOS EL ARCHIVO
		  LET cSql = "gunzip "  || trim(vRuta) || trim(pNomArch); 
          system cSql;
		  
		--TOMAMOS EL NOMBRE DE ARCHIVO YA DESCOMPRIMIDO SIN LOS 3 ULTIMOS CARACTERES 
		 LET X = length(pNomArch);
		 LET vNomArch = substr(pNomArch,0,X-3);
		
/*       LET cCadena = 'echo " load from ' || SUBSTR(vRuta,1,LENGTH(vRuta)) || SUBSTR(VNomArch,1,
		  LENGTH(VNomArch))  || ' insert into bdicobranza:cb_cat_movimientos " >' || SUBSTR(vRuta,1,LENGTH(vRuta)) || 'catmovimientosctbcpl.sql';
          System SUBSTR(cCadena,1,LENGTH(cCadena));
          let cCadena = 'dbaccess bdicobranza ' || SUBSTR(vRuta,1,LENGTH(vRuta)) || 'catmovimientosctbcpl.sql';
          System SUBSTR(cCadena,1,LENGTH(cCadena));*/

		--SE ENVIAR EL NOMBRE DEL ARCHIVO A CARGAR AL SCRIPT
		LET cCadena = 'cat ' || TRIM(vRutasql) || '206_3_40_carga_movimientos_cat_archivo.sql | sed "s/vnom_archivo/' || TRIM(VNomArch) || '/g" > ' || TRIM(vRuta) || 'catmovimientosctbcpl.sql';
		SYSTEM SUBSTR(cCadena,1,LENGTH(cCadena));

		--CREAMOS EL ARCHIVO CON LA CADENA A EJECUTAR
		LET cCadena = "";
		LET cCadena = 'dbload -d bdicobranza -c ' || TRIM(vRuta) || 'catmovimientosctbcpl.sql -l ' || TRIM(vRuta) || 'catmovimientosctbcpl.log -n 1000 -k';
		SYSTEM SUBSTR(cCadena,1,LENGTH(cCadena));

		--BORRA EL ARCHIVO 
          let cCadena = 'rm ' || SUBSTR(vRuta,1,LENGTH(vRuta)) || 'catmovimientosctbcpl.sql';
          System SUBSTR(cCadena,1,LENGTH(cCadena));
		  
	--SE COMPRIME DE NUEVO EL ARCHIVO	
		LET cSql = "gzip " || trim(vRuta) || trim(vNomArch); 
		system cSql;
	--SE ACTUALIZA CAMPO CON LPAD A CAMPO CLIENTE
	FOREACH WITH HOLD
		SELECT cliente
		INTO v_cliente
		FROM "informix".cb_cat_movimientos
		WHERE date(horainicio) = vfecha
		
		IF LENGTH(TRIM(v_cliente)) < 9 THEN
			LET v_clienteact = lpad (trim(v_cliente),9,'0');
		ELSE
			CONTINUE FOREACH;
		END IF;

		BEGIN WORK;
			UPDATE "informix".cb_cat_movimientos
			SET cliente = v_clienteact
			WHERE date(horainicio) = vfecha
			AND cliente = v_cliente;
		COMMIT WORK;
	END FOREACH
	--SE MANDA LLAMAR SP PARA INSERTAR EN BITACORA EL FINAL DE LA EJECUCION DE SP
		 CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso, cCod_ret, cMensaje, '03')
			RETURNING vvcCod_ret;
	--SE MANDA LLAMAR SP CIERRE LLAMADAS PARA REALIZAR EL CONTEO DE LLAMADAS POR CLIENTE
--		 CALL bdicobranza:"informix".sp_cat_cierrellamadas()
--			RETURNING cCod_ret, cMensaje;
	--SE MANDA LLAMAR SP PARA ACTUALIZAR EN LA TABLA SI_TELEFONOS_ACTUAL EL CAMPO "CONTACTO"
--		 CALL bdicobranza:"informix".sp_actualiza_contacto_exitoso()
--			RETURNING cCod_ret, cMensaje;
	--SE MANDA LLAMAR AL SP QUE CARGA REGISTROS DE ATENTO
		--CALL bdicobranza:"informix".sp_carga_info_atento() RETURNING cCod_ret, cMensaje;
	--SE MANDA LLAMAR AL SP QUE CARGA REGISTROS DE LATINIA
		--CALL bdicobranza:"informix".sp_carga_sms_latinia() RETURNING cCod_ret, cMensaje;
		
RETURN cCod_ret, cMensaje;

END;
END PROCEDURE;
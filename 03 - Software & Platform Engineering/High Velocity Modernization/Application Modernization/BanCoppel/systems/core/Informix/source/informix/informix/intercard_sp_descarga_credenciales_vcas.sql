CREATE PROCEDURE "informix".sp_descarga_credenciales_vcas(pNombreArchivo CHAR(28))
RETURNING CHAR(5) as codret, CHAR(20) as estatus;

	DEFINE codret 			CHAR(5);
	DEFINE estatus			CHAR(20);

	DEFINE v_sql     		CHAR(250);
	DEFINE cEncabezado  	CHAR(250);
	DEFINE vreg_ins			INTEGER;
	
	DEFINE cRuta 			CHAR(250);
	DEFINE cRuta2 			CHAR(250);
	DEFINE cNombreArchivo 	CHAR(250);
	DEFINE cNombreArchivo1 	CHAR(250);
	DEFINE cNombreArchivo2 	CHAR(250);
	
    DEFINE vcod_ret         VARCHAR(10);
    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE error_info       CHAR(40);
	
	LET codret 			= "000";
	LET estatus			= "DESCARGA EXITOSA";
	
	LET vreg_ins		= 0;
	
	LET cRuta 			= "/RESPALDOSNEW/";
	LET cRuta2 			= "/RESPALDOSNEW/VCAS_resultados/";
	
BEGIN
	
	-- MANEJO DEL ERROR.
	ON EXCEPTION SET sql_err, isam_err, error_info
				
		-- SET DEBUG FILE TO "/RESPALDOSNEW/exc_sp_tarj_det_vcas.err.out" WITH APPEND;
		-- TRACE ON;
		
		IF sql_err <> 0 THEN
			LET vcod_ret = sql_err;
			
			RETURN vcod_ret, isam_err||' ' ||error_info;
		END IF;
		
	END EXCEPTION;
	
	-- DESCARGAR ARCHIVO.
				
	--SET DEBUG FILE TO "/RESPALDOSNEW/VCAS_reporte/204.out";
	--TRACE ON;

	-- Definicion de variables de paso para generacion de archivo VCAS con informacion
	LET cNombreArchivo = TRIM(cRuta2) || pNombreArchivo;
	LET cNombreArchivo1 = TRIM(cRuta) || LEFT(TRIM(pNombreArchivo),24)||'_aux.csv';
	LET cNombreArchivo2 = TRIM(cRuta) || LEFT(TRIM(pNombreArchivo),24)||'_aux2.csv';
		
	-- DESCARGA DEL ARCHIVO .CSV.
	LET cEncabezado = 'echo "action,pan,mobilenumber,email,segmentationindicator," > /RESPALDOSNEW/queryenc.sql';
	System cEncabezado;
	
	LET v_sql = 'chmod 777 /RESPALDOSNEW/queryenc.sql';
	System v_sql;

	LET v_sql = 'echo "UNLOAD TO ' || TRIM (cNombreArchivo1) || ' DELIMITER '',''" > /RESPALDOSNEW/queryhist.sql ';
	System v_sql;
	
	LET v_sql = 'chmod 777 /RESPALDOSNEW/queryhist.sql';
	System v_sql;

	LET v_sql = 'echo "SELECT action,numtarjeta AS pan, ''+52''||RIGHT(LTRIM(RTRIM(telefono)),10) AS mobilenumber," >> /RESPALDOSNEW/queryhist.sql ';
	System v_sql;

	LET v_sql = 'echo "LTRIM(RTRIM(correo_elec)) AS email, ''01'' AS segmentationindicator" >> /RESPALDOSNEW/queryhist.sql ';
	System v_sql;

	LET v_sql = 'echo " from intercard:ctas_vcas where numtarjeta <> ''''" >> /RESPALDOSNEW/queryhist.sql';
	System v_sql;

	LET v_sql = 'echo " order by linea asc" >> /RESPALDOSNEW/queryhist.sql';
	System v_sql;

	LET v_sql = "dbaccess intercard /RESPALDOSNEW/queryhist.sql";
	System v_sql;

	LET v_sql="";

	-- SE ANADEN LOS ENCABEZADOS Y LOS RESULTADOS EXTRAIDOS AL ARCHIVO AUXILIAR.
	LET v_sql = "sed 's/$//g' "|| TRIM(cRuta) || "queryenc.sql >> " || TRIM (cNombreArchivo2);
	SYSTEM TRIM(v_sql);

	LET v_sql="";	
	LET v_sql = "sed 's/$//g' "|| TRIM (cNombreArchivo1) || " >> " || TRIM (cNombreArchivo2);
	SYSTEM TRIM(v_sql);

	-- SE PASA LA INFORMACION DESCARGADA AL ARCHIVO FINAL.
	LET v_sql = "";
	LET v_sql = "sed -e 's/.$//' "|| TRIM(cNombreArchivo2) || " >> " || TRIM (cNombreArchivo);
	SYSTEM v_sql;

	LET v_sql = "";
	LET v_sql = 'chmod 777 '||TRIM(cNombreArchivo);
	SYSTEM v_sql;
	
	-- BORRADO DE SCRIPTS GENERADOS EN EL PROCESO.
	LET v_sql = "";
	LET v_sql = "rm " || TRIM(cRuta) || "queryhist.sql";
	SYSTEM TRIM(v_sql);

	LET v_sql = "";
	LET v_sql = "rm " || TRIM(cRuta) || "queryenc.sql";
	SYSTEM TRIM(v_sql);

	LET v_sql = "";
	LET v_sql = "rm " || TRIM(cNombreArchivo1);
	SYSTEM TRIM(v_sql);

	LET v_sql = "";
	LET v_sql = "rm " || TRIM(cNombreArchivo2);
	SYSTEM TRIM(v_sql);
	
	-- Insertar en la variable el conteo de registros del archivo procesado
	SELECT COUNT(*)
	INTO vreg_ins
	FROM intercard:ctas_vcas;
	
	--Se inserta en la tabla archivos control el nombre del archivo que se creo
	INSERT INTO intercard:archivos_control_vcas( nombre_archivo, fecha_generacion, tipo_archivo, total_registros, estatus ) 
	VALUES (pNombreArchivo, CURRENT, 'Enviado', vreg_ins, 'Pendiente');
	
	TRUNCATE TABLE intercard:ctas_vcas;
	
	RETURN codret, estatus;
		
END;
		
END PROCEDURE;
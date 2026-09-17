CREATE PROCEDURE "informix".sp_nombre_archivo_dep_atm ()

RETURNING VARCHAR (5)   AS CODIGO, VARCHAR (150) AS MENSAJE_RPTA;
		
	/*  DEFINICION DE VARIABLES */

	-- CONTROL DE ERRORES
	
	DEFINE  SQL_ERR          INTEGER;
	DEFINE  ISAM_ERR         INTEGER;
	DEFINE  ERROR_INFO       VARCHAR(80);
	
	--CONTROL GENERAL
	
	DEFINE CODIGO				CHAR (6);
	DEFINE MENSAJE_RPTA			CHAR (80);
	DEFINE vRUTA_DEP_ATM		CHAR (33);
	DEFINE vListArchivo			CHAR (20);
	DEFINE vArchiBat			CHAR (20);
	DEFINE vExecuteSQL 			CHAR (300);
	DEFINE vsNombreArchivo 		CHAR (30);
	DEFINE dsFechaArchivo 		CHAR (10);

BEGIN	
			
	ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
	
		LET CODIGO    = SQL_ERR;
		LET MENSAJE_RPTA  = ERROR_INFO;
	  
		DELETE FROM BdiTarjeta:"informix".td_cga_nombre_archivo_dep_atm;
		RETURN CODIGO, MENSAJE_RPTA;
	  
	END EXCEPTION;
			
	--SET DEBUG FILE TO "/informix/LVRQ/dep_atm/debug/nombre_archivo_dep_atm.out";
	--TRACE ON;
	
	/* INICIALIZACION DE VARIABLES */ --CONTROL GENERAL
	
	LET CODIGO					= '00000';
	LET MENSAJE_RPTA			= 'PROCESO EXITOSO';
	LET vRUTA_DEP_ATM				= '';
	LET vListArchivo			= 'listado_archivos.txt';
	LET vArchiBat				= 'ls_bat.bat';
	LET vExecuteSQL				= '';
	LET vsNombreArchivo			= '';
	LET dsFechaArchivo			= '';
							
	SET ISOLATION TO dirty READ;
	SET LOCK MODE TO WAIT 3;
			
	-- ELIMINA LOS RESGISTROS DE LA TABLA CARGADOS ANTERIORMENTE
	DELETE FROM BdiTarjeta:"informix".td_cga_nombre_archivo_dep_atm;
	
	SELECT rep_aix
	INTO vRUTA_DEP_ATM
	FROM BdiTarjeta:td_archivo_origen_atm_stat06
	WHERE archivo_origen='DEP';
	
	--LET vRUTA_DEP_ATM = TRIM(vRUTA_DEP_ATM);
	--TRACE 'losguitud de ruta'||vRUTA_DEP_ATM;
	--TRACE 'losguitud de ruta2'||TRIM(vRUTA_DEP_ATM);
	LET vExecuteSQL = '';
	LET vExecuteSQL = 'echo "ls '|| TRIM(vRUTA_DEP_ATM) || '| grep BCPL_STAT06_DEP " > ' || TRIM(vRUTA_DEP_ATM) || '/' || vArchiBat;
	SYSTEM vExecuteSQL;
	
	LET vExecuteSQL ='';
	LET vExecuteSQL= 'chmod 777 ' || TRIM(vRUTA_DEP_ATM) || '/' || vArchiBat;
	system vExecuteSQL;
	
	
	LET vExecuteSQL = ''; 
	LET vExecuteSQL =  TRIM(vRUTA_DEP_ATM) || '/' || vArchiBat || '>' || TRIM(vRUTA_DEP_ATM) || '/' || vListArchivo; 
	SYSTEM vExecuteSQL; 
	 
	LET vExecuteSQL = '';
	LET vExecuteSQL = 'rm ' || TRIM(vRUTA_DEP_ATM) || '/' || vArchiBat;
	system vExecuteSQL;
	
	LET vExecuteSQL = '';
	LET vExecuteSQL = 'echo "LOAD FROM '|| TRIM(vRUTA_DEP_ATM) || '/' || TRIM(vListArchivo) ||
					 ' INSERT INTO BdiTarjeta:td_cga_nombre_archivo_dep_atm;" > ' || TRIM(vRUTA_DEP_ATM) ||  '/load_nombre_archivo.sql';
	SYSTEM vExecuteSQL;
	
	LET vExecuteSQL = '';
	LET vExecuteSQL = 'dbaccess bditarjeta ' || TRIM(vRUTA_DEP_ATM) ||  '/load_nombre_archivo.sql';
	SYSTEM vExecuteSQL;

	LET vExecuteSQL = '';
	LET vExecuteSQL = 'rm ' || TRIM(vRUTA_DEP_ATM) || '/' || vListArchivo;
	system vExecuteSQL;
			
	FOREACH cursor_archivo FOR	
		
		SELECT nom_archivo_dep
			INTO vsNombreArchivo
		FROM BdiTarjeta:"informix".td_cga_nombre_archivo_dep_atm
			
				
		IF length(vsNombreArchivo) = 26 THEN
		
			IF SUBSTR(vsNombreArchivo,23,4) = '.txt' THEN
			
				EXECUTE PROCEDURE bditarjeta:sp_guardabitacora_dep_atm( 0 , 'Registrando archivo ' || vsNombreArchivo || 'para procesar.' , 'sysconau')
				INTO CODIGO;
				
				
				LET dsFechaArchivo = TRIM(SUBSTR (vsNombreArchivo,17,6));
				LET dsFechaArchivo = SUBSTR(dsFechaArchivo,3,2)||'/'||SUBSTR(dsFechaArchivo,1,2)||'/'||SUBSTR(dsFechaArchivo,5,2);
				LET dsFechaArchivo = dsFechaArchivo::DATE;
				
				--TRACE 'SOY FECHA ARCHIVO '||dsFechaArchivo;
				
				INSERT INTO bditarjeta:"informix".td_archivos_conciliacion_dep_atm(nombrearchivo, archivo_origen, fecha_archivo, num_registros325, monto325,
							fecha_proceso, fecha_hora_transferencia, fecha_hora_ini_proceso, fecha_hora_carga_archivo, fecha_hora_carga_tabla,
							fecha_hora_ini_concilia_reg, fecha_hora_fin_concilia_reg, fecha_hora_fin_proceso, fecha_hora_gen_conadmin, transferencia,
							carga, conadmin, traspaso_historico, num_cargo, monto_cargo, num_abono, monto_abono, proceso) 
				VALUES( vsNombreArchivo, 'DEP', dsFechaArchivo, 0, 0, CURRENT, '1900-01-01 00:00:00.0', '1900-01-01 00:00:00.0', '1900-01-01 00:00:00.0', '1900-01-01 00:00:00.0',
				'1900-01-01 00:00:00.0','1900-01-01 00:00:00.0', '1900-01-01 00:00:00.0', '1900-01-01 00:00:00.0', 'V', 'F', '', 'F', 0, 0, 0, 0, 'P');
			
			ELSE
				EXECUTE PROCEDURE bditarjeta:sp_guardabitacora_dep_atm( 0 , 'El archivo de conciliacion depositadores < ' || vsNombreArchivo || ' > no se puede procesar por el formato.', 'sysconau')
				INTO CODIGO;
				
				LET CODIGO = '00001';
			
			END IF
		END IF	
	END FOREACH; -- CICLO DE OBTENCION DE REGISTROS DEL NOMBRE DEL ARCHIVO DEPOSITADORES ATM			
		
	IF CODIGO = '00001' THEN
	
		LET MENSAJE_RPTA = ' Se intento procesar un archivo con formato diferente. Numero de archivos procesados: ' || ( SELECT COUNT(*) FROM bditarjeta:td_cga_nombre_archivo_dep_atm );
		
		EXECUTE PROCEDURE bditarjeta:sp_guardabitacora_dep_atm( 0 , MENSAJE_RPTA, 'sysconau')
		INTO CODIGO;
			
	ELSE
	
		LET MENSAJE_RPTA = ' Numero de archivos procesados: ' || ( SELECT COUNT(*) FROM bditarjeta:td_cga_nombre_archivo_dep_atm );
		
		EXECUTE PROCEDURE bditarjeta:sp_guardabitacora_dep_atm( 0 , MENSAJE_RPTA, 'sysconau')
		INTO CODIGO;
		
	END IF
		
	LET CODIGO = '00000';
	RETURN CODIGO, MENSAJE_RPTA;
END
END PROCEDURE;
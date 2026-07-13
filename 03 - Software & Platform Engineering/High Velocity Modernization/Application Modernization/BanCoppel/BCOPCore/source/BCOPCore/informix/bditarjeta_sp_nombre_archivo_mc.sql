CREATE PROCEDURE "informix".sp_nombre_archivo_mc ()

		RETURNING VARCHAR (5)   AS CODIGO, VARCHAR (150) AS MENSAJE_RPTA;
		
		 /*  DEFINICION DE VARIABLES */

			-- CONTROL DE ERRORES
			
		    DEFINE  SQL_ERR          INTEGER;
			DEFINE  ISAM_ERR         INTEGER;
			DEFINE  ERROR_INFO       VARCHAR(80);
			
			--CONTROL GENERAL
			
			DEFINE CODIGO				CHAR (6);
			DEFINE MENSAJE_RPTA			CHAR (80);
			DEFINE vRUTA_OXXO			CHAR (35);
			DEFINE vListArchivo			CHAR (20);
			DEFINE vArchiBat			CHAR (20);
			DEFINE vExecuteSQL 			CHAR (300);
			DEFINE vsNombreArchivo 		CHAR (30);
			DEFINE dsFechaArchivo 		CHAR (10);
			
			

			
			
		BEGIN	
			
			ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
			
			  LET CODIGO    = SQL_ERR;
			  LET MENSAJE_RPTA  = ERROR_INFO;

			  
				DELETE FROM BdiTarjeta:"informix".td_cga_nombre_archivo_mc;

			  
			  RETURN CODIGO, MENSAJE_RPTA;
			  
			END EXCEPTION;
			
			--SET DEBUG FILE TO "/ifxsif01/LVRQ/debug/nombre_archivo_mc.out";
			--TRACE ON;
			
				/* INICIALIZACION DE VARIABLES */ --CONTROL GENERAL
				
				LET CODIGO					= '00000';
				LET MENSAJE_RPTA			= 'PROCESO EXITOSO';
				LET vRUTA_OXXO				= '';
				LET vListArchivo			= 'listado_archivos.txt';
				LET vArchiBat				= 'ls_bat.bat';
				LET vExecuteSQL				= '';
				LET vsNombreArchivo			= '';
				LET dsFechaArchivo			= '';
				
				
			SET ISOLATION TO dirty READ;
			SET LOCK MODE TO WAIT 3;
			
			-- ELIMINA LOS RESGISTROS DE LA TABLA CARGADOS ANTERIORMENTE
				DELETE FROM BdiTarjeta:"informix".td_cga_nombre_archivo_mc;
				
				SELECT rep_aix
				INTO vRUTA_OXXO
				FROM BdiTarjeta:"informix".td_archivo_origentmp_mc
				WHERE archivo_origen='MCO';
				 
				
				LET vExecuteSQL = '';
				LET vExecuteSQL = 'echo "ls '|| vRUTA_OXXO || '| grep BCPL.T464.D " > ' || vRUTA_OXXO||'/'||vArchiBat;
				SYSTEM vExecuteSQL;
				
				LET vExecuteSQL ='';
				LET vExecuteSQL= 'chmod 777 ' || vRUTA_OXXO||'/'||vArchiBat;
				system vExecuteSQL;
				
				
				LET vExecuteSQL = ''; 
                LET vExecuteSQL =  vRUTA_OXXO||'/'||vArchiBat ||'>'|| vRUTA_OXXO||'/'||vListArchivo; 
				SYSTEM vExecuteSQL; 
				 
				LET vExecuteSQL = '';
				LET vExecuteSQL = 'rm '||vRUTA_OXXO||'/'||vArchiBat;
				system vExecuteSQL;
				
				LET vExecuteSQL = '';
				LET vExecuteSQL = 'echo "LOAD FROM '|| TRIM(vRUTA_OXXO) || '/' || TRIM(vListArchivo) ||
								 ' INSERT INTO BdiTarjeta:td_cga_nombre_archivo_mc;" > ' || TRIM(vRUTA_OXXO) ||  '/load_nombre_archivo.sql';
				SYSTEM vExecuteSQL;
				
				LET vExecuteSQL = '';
				LET vExecuteSQL = 'dbaccess bditarjeta ' || TRIM(vRUTA_OXXO) ||  '/load_nombre_archivo.sql';
				SYSTEM vExecuteSQL;
			
				LET vExecuteSQL = '';
				LET vExecuteSQL = 'rm '||vRUTA_OXXO||'/'||vListArchivo;
				system vExecuteSQL;
			
				 
				 
			FOREACH cursor_archivo FOR	
			
				SELECT nom_archivo_mc
					INTO vsNombreArchivo
				FROM BdiTarjeta:"informix".td_cga_nombre_archivo_mc
				
				LET dsFechaArchivo = TRIM(SUBSTR (vsNombreArchivo,12,6));
				LET dsFechaArchivo = SUBSTR(dsFechaArchivo,3,2)||'/'||SUBSTR(dsFechaArchivo,5,2)||'/'||SUBSTR(dsFechaArchivo,1,2);
				LET dsFechaArchivo = dsFechaArchivo::DATE;
				
				--TRACE 'SOY FECHA ARCHIVO '||dsFechaArchivo;
				
				INSERT INTO bditarjeta:"informix".td_archivos_conciliacion_mc(nombrearchivo, archivo_origen, fecha_archivo, num_registros325, monto325,
							fecha_proceso, fecha_hora_transferencia, fecha_hora_ini_proceso, fecha_hora_carga_archivo, fecha_hora_carga_tabla,
							fecha_hora_ini_concilia_reg, fecha_hora_fin_concilia_reg, fecha_hora_fin_proceso, fecha_hora_gen_conadmin, transferencia,
							carga, conadmin, traspaso_historico, num_cargo, monto_cargo, num_abono, monto_abono, proceso) 
				VALUES( vsNombreArchivo, 'MCO', dsFechaArchivo, 0, 0, CURRENT, '1900-01-01 00:00:00.0', '1900-01-01 00:00:00.0', '1900-01-01 00:00:00.0', '1900-01-01 00:00:00.0',
						'1900-01-01 00:00:00.0','1900-01-01 00:00:00.0', '1900-01-01 00:00:00.0', '1900-01-01 00:00:00.0', 'V', 'F', '', 'F', 0, 0, 0, 0, 'P');
				

			END FOREACH; -- CICLO DE OBTENCION DE REGISTROS DEL NOMBRE DEL ARCHIVO DE MASTER CARD
			
		
			RETURN CODIGO, MENSAJE_RPTA;
		END
	END PROCEDURE;
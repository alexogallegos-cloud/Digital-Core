CREATE PROCEDURE "informix".sp_mueve_archivo_atm_stat06_resp ()

		RETURNING VARCHAR (5)   AS CODIGO, VARCHAR (150) AS MENSAJE_RPTA;
		
		 /*  DEFINICION DE VARIABLES */

			-- CONTROL DE ERRORES
			
		    DEFINE  SQL_ERR          INTEGER;
			DEFINE  ISAM_ERR         INTEGER;
			DEFINE  ERROR_INFO       VARCHAR(80);
			
			--CONTROL GENERAL
			
			DEFINE CODIGO				CHAR (6);
			DEFINE MENSAJE_RPTA			CHAR (80);
			DEFINE vRUTA_STAT06			CHAR (34);
			DEFINE vRuta_Resp			CHAR (44);
			DEFINE vListArchivo			CHAR (20);
			DEFINE vArchiBat			CHAR (20);
			DEFINE vExecuteSQL 			CHAR (300);
			DEFINE vsNombreArchivo 		CHAR (30);
			DEFINE dsFechaArchivo 		CHAR (10);
			
		BEGIN	
			
			ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
			
			  LET CODIGO    = SQL_ERR;
			  LET MENSAJE_RPTA  = ERROR_INFO;
			  
			  RETURN CODIGO, MENSAJE_RPTA;
			  
			END EXCEPTION;
			
			--SET DEBUG FILE TO "/home/c98188925/debug/mov_archivo_dep_atm.out";
			--TRACE ON;
			
				/* INICIALIZACION DE VARIABLES */ --CONTROL GENERAL
				
				LET CODIGO					= '00000';
				LET MENSAJE_RPTA			= 'PROCESO EXITOSO';
				LET vRUTA_STAT06				= '';
				LET vRuta_Resp				= '/home/sysconau/conciliacion/istsw/Respaldo';
				LET vListArchivo			= 'hay_archivos.txt';
				LET vArchiBat				= 'archivos_atm_stat06.bat';
				LET vExecuteSQL				= '';
				LET vsNombreArchivo			= '';
				LET dsFechaArchivo			= '';
				
				
			SET ISOLATION TO dirty READ;
			SET LOCK MODE TO WAIT 3;
			
				SELECT rep_aix
				INTO vRUTA_STAT06
				FROM BdiTarjeta:"informix".td_archivo_origen_atm_stat06
				WHERE archivo_origen='IST';
				

			FOREACH cursor_move FOR	
			
				SELECT nombrearchivo
					INTO vsNombreArchivo
				FROM BdiTarjeta:"informix".td_archivos_conciliacion_atm_stat06
				WHERE fecha_proceso = today 
				AND proceso='T'
				
				LET vExecuteSQL  = '';
				LET vExecuteSQL  = ' if  [ -f '||TRIM(vRUTA_STAT06)||'/'||TRIM(vsNombreArchivo)||' ]; ' ||     
				  ' then ' ||     
					' mv '||TRIM(vRUTA_STAT06)||'/'||TRIM(vsNombreArchivo)|| ' ' ||vRuta_Resp||';'||  
				 ' fi  >' ||TRIM(vRUTA_STAT06)||'/'||vArchiBat;
				 SYSTEM vExecuteSQL;
				
				LET vExecuteSQL  = '';
				LET vExecuteSQL  = ' chmod 777 '||TRIM(vRUTA_STAT06)||'/'||vArchiBat;
				SYSTEM vExecuteSQL;
				
				LET vExecuteSQL  = '';
				LET vExecuteSQL  = TRIM(vRUTA_STAT06)||'/'||vArchiBat;
				SYSTEM vExecuteSQL;
				
				LET vExecuteSQL  = '';
				LET vExecuteSQL  = 'rm -f '||TRIM(vRUTA_STAT06)||'/'||vArchiBat;
				SYSTEM vExecuteSQL;
	

			END FOREACH; -- CICLO DE OBTENCION DE REGISTROS DEL NOMBRE DEL ARCHIVO DE MASTER CARD
			
			RETURN CODIGO, MENSAJE_RPTA;
		END
	END PROCEDURE
	DOCUMENT
'Autor: Maria Fernanda Ortiz Figueroa',
'Proyecto: Optimizacion Conciliacion Automatica - Separacion STAT06',
'Solicito: Gerencia de Produccion y Base de Datos Centrales',
'Descripcion: Proceso que se encarga de realizar el respaldo del archivo de la conciliacion de ATM STAT06',
'Fecha: 2023/12/13',
'Version: 1.0',
'BD: BdiTarjeta';

CREATE PROCEDURE "informix".sp_carga_buen_fin_cnc(vArchivoDBLOAD CHAR(100), RUTA CHAR(100))

	RETURNING CHAR(5) AS CodigoRetorno, CHAR(160) AS mensaje;
	
	-- Define Var Init Var Control 
	DEFINE vIntervaloCommit		INTEGER;
	DEFINE vExecuteSQL		    LVARCHAR(1000);
	DEFINE vNombreCompTXT		VARCHAR(100);
	DEFINE vNombreCompLog		VARCHAR(100);
	DEFINE vNombreEjecucionLog  VARCHAR(100);
	DEFINE nomArch              VARCHAR(100);
	DEFINE nomRut		    	VARCHAR(100);
	
	-- Define Var EXCEPTION
	DEFINE vCodigoRetorno		CHAR(5);
	DEFINE vMensaje 			CHAR(160);
	DEFINE SQLERR 				INTEGER;
    DEFINE ISAM_ERR 			INTEGER;
   	DEFINE ERROR_INFO 			VARCHAR(80);
	
	-- Init Var Control
	LET nomRut = TRIM(RUTA);
	LET nomArch = vArchivoDBLOAD;
	LET vIntervaloCommit = 1000;
	LET vExecuteSQL	='';
	LET vNombreCompTXT = TRIM(nomRut) || "/extraccion_tbl_bf_movs_cnc_sorteo_2023.txt";
	LET vNombreCompLog = TRIM(nomRut) || "/extraccion_tbl_bf_movs_cnc_sorteo_2023_log.log";
	LET vNombreEjecucionLog = TRIM(nomRut) || "/extraccion_tbl_bf_movs_cnc_sorteo_2023.log";
	
	-- Init Var Exception
	LET vCodigoRetorno = '00000';
	LET vMensaje = '';
	LET SQLERR	 = 0;
    LET ISAM_ERR = 0;
    LET ERROR_INFO = '';
	
	
	BEGIN 
		-- Flujo de Excepciones
		ON EXCEPTION SET SQLERR, ISAM_ERR, ERROR_INFO
					
			SET DEBUG FILE TO RUTA || "carga_.err.out";
			TRACE ON;
			
			IF ( SQLERR <> 0 ) THEN
				LET vCodigoRetorno = SQLERR;
				LET vMensaje = ERROR_INFO;                
				RETURN vCodigoRetorno, vMensaje;
			END IF;
					
		END EXCEPTION;
	
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		--Termina Flujo de Exepciones 			
		
		-- Comienza Load de archivo 
		LET vCodigoRetorno = '00001';        
		LET vMensaje = 'GENERAR COMANDO DE CARGA.';
		
		LET vExecuteSQL = '';
		LET vExecuteSQL = "echo "||'"'|| "FILE '"|| TRIM(nomRut) || '/' || TRIM(nomArch)|| "' delimiter '"|| '|' ||"' "|| '17'||
					"; INSERT INTO "|| 'tbl_bf_movs_cnc_sorteo' || ";"||'"'||' > '|| vNombreCompTXT;
		SYSTEM vExecuteSQL;
		
		LET vCodigoRetorno = '00002';        
		LET vMensaje = 'EJECUTAR CARGA DE ARCHIVO.';
		
		LET vExecuteSQL = '';
		LET vExecuteSQL = "dbload -d bditarjeta -c " || vNombreCompTXT || " -l " || vNombreCompLog || " -n " || vIntervaloCommit ||" -r > "||vNombreEjecucionLog;
		SYSTEM vExecuteSQL; 
		
		LET vCodigoRetorno = '00000';        
		LET vMensaje = 'ARCHIVO CARGADO';

		RETURN vCodigoRetorno, vMensaje;
	END;
END PROCEDURE;
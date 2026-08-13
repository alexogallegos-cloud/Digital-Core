CREATE PROCEDURE "informix".sp_mueve_archivo_atm_stat06_pagos ()

		RETURNING VARCHAR (5)   AS CODIGO, VARCHAR (150) AS MENSAJE_RPTA;
		
		 /*  DEFINICION DE VARIABLES */

			-- CONTROL DE ERRORES
			
		DEFINE  SQL_ERR          INTEGER;
		DEFINE  ISAM_ERR         INTEGER;
		DEFINE  ERROR_INFO       VARCHAR(80);
		
		--CONTROL GENERAL
		
		DEFINE CODIGO				CHAR (6);
		DEFINE MENSAJE_RPTA			CHAR (80);
		DEFINE vRUTA_PAG			CHAR (34);
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
		
		--SET DEBUG FILE TO "/RESPALDOSNEW/e10000656/mov_archivo_dep_atm.out";
		--TRACE ON;
		
		/* INICIALIZACION DE VARIABLES */ --CONTROL GENERAL
		
		LET CODIGO					= '00000';
		LET MENSAJE_RPTA			= 'PROCESO EXITOSO';
		LET vRUTA_PAG				= '';
		LET vRuta_Resp				= '/home/sysconau/conciliacion/istsw/Respaldo';
		--LET vRuta_Resp				= '/RESPALDOSNEW/e10000656/sysconau/Respaldo';
		LET vListArchivo			= 'hay_archivos.txt';
		LET vArchiBat				= 'archivos_dep_atm.bat';
		LET vExecuteSQL				= '';
		LET vsNombreArchivo			= '';
		LET dsFechaArchivo			= '';
			
		SET ISOLATION TO dirty READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT rep_aix
		INTO vRUTA_PAG
		FROM BdiTarjeta:td_archivo_origen_atm_stat06
		WHERE archivo_origen = 'COB';

		FOREACH WITH HOLD
		
			SELECT nombrearchivo
			INTO vsNombreArchivo
			FROM BdiTarjeta:td_archivos_conciliacion_atm_stat06_pagos
			WHERE fecha_proceso = today 
			AND proceso='T'
			
			LET vExecuteSQL  = '';
			LET vExecuteSQL  = ' if  [ -f '||TRIM(vRUTA_PAG)||'/'||TRIM(vsNombreArchivo)||' ]; ' ||     
			  ' then ' ||     
				' mv '||TRIM(vRUTA_PAG)||'/'||TRIM(vsNombreArchivo)|| ' ' ||vRuta_Resp||';'||  
			 ' fi  >' ||TRIM(vRUTA_PAG)||'/'||vArchiBat;
			 SYSTEM vExecuteSQL;
			
			LET vExecuteSQL  = '';
			LET vExecuteSQL  = ' chmod 777 '||TRIM(vRUTA_PAG)||'/'||vArchiBat;
			SYSTEM vExecuteSQL;
			
			LET vExecuteSQL  = '';
			LET vExecuteSQL  = TRIM(vRUTA_PAG)||'/'||vArchiBat;
			SYSTEM vExecuteSQL;
			
			LET vExecuteSQL  = '';
			LET vExecuteSQL  = 'rm -f '||TRIM(vRUTA_PAG)||'/'||vArchiBat;
			SYSTEM vExecuteSQL;

		END FOREACH; -- CICLO DE OBTENCION DE REGISTROS DEL NOMBRE DEL ARCHIVO DE MASTER CARD
		
		RETURN CODIGO, MENSAJE_RPTA;
	END
END PROCEDURE;
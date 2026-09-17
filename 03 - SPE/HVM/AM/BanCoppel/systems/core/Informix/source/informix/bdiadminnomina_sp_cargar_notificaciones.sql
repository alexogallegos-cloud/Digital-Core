CREATE PROCEDURE "informix".sp_cargar_notificaciones()
	RETURNING CHAR(5) AS codret;

	DEFINE cCodRet				 CHAR(5);
	DEFINE sqlErr				 INTEGER;
	DEFINE cRuta 				 CHAR(255);
	DEFINE cNombreArch 			 CHAR(255);
	DEFINE cFechaHoy 			 CHAR(8);
	DEFINE vFechaAct			 DATE;	
	DEFINE cSql					 VARCHAR(200);
	
	LET cCodRet 		    	= '00001';
	LET sqlErr 			    	= 0; 
	LET cRuta					= '';
	LET cNombreArch  			= '';
	LET cFechaHoy				= '';
	LET vFechaAct				= today-2;	
	LET cSql					= '';	
	
	BEGIN

		ON EXCEPTION SET sqlErr
			IF sqlErr <> 0 THEN
				LET cCodRet = sqlErr;
				ROLLBACK WORK;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO "/home/sysifx/AleBarranco/sp_cargar_notificaciones.out";
		--TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;	
		
		--Ruta del archivo a cargar
		SELECT valor
		INTO cRuta
		FROM "informix".sn_parametros
		WHERE id = 'RUTA_ARCHIVO';
		
		--Nombre del archivo a cargar
		SELECT TRIM(valor) 
		INTO cNombreArch
		FROM "informix".sn_parametros
		WHERE id = 'NOMBRE_ARC_NOTIF_SEC';
		
		IF TRIM(NVL(cRuta,'')) <> '' AND TRIM(NVL(cNombreArch,'')) <> '' THEN
			
			BEGIN WORK;
				TRUNCATE TABLE "informix".mnsjr_trx_online;
				--TRUNCATE TABLE "informix".sec_mnsjr_trx_online;
			COMMIT WORK;
			
			LET cFechaHoy = YEAR(vFechaAct)||""||LPAD(MONTH(vFechaAct),2,0)||""||LPAD(DAY(vFechaAct),2,0);
			
			LET cNombreArch = REPLACE(TRIM(cNombreArch), 'YYYYMMDD', TRIM(cFechaHoy));
			
			LET cSql = 'echo "LOAD FROM '|| TRIM(cRuta) || TRIM(cNombreArch)
						|| ' INSERT INTO "informix".mnsjr_trx_online;" > ' || TRIM(cRuta) || 'instruccion.sql';
						--|| ' INSERT INTO "informix".sec_mnsjr_trx_online;" > ' || TRIM(cRuta) || 'instruccion.sql';
			SYSTEM cSql;
			
			LET cSql = '';
			LET cSql = 'dbaccess bdiadminnomina '|| TRIM(cRuta) || 'instruccion.sql';
			SYSTEM cSql;
			
			LET cSql = '';
			LET cSql =  "rm " || TRIM(cRuta)|| "instruccion.sql";										
			SYSTEM cSql;
		
			LET cCodRet = '00000';
			
		END IF;				
									
		RETURN cCodRet;

END;	
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se crea procedimiento para cargar los datos del archivo de texto plano a la tabla de notificaciones',
'AUTOR: Alejandra Barranco',
'FECHA DE CREACION: 05 de Octubre de 2022',
'VERSION: 1.0',
'BD: bdiadminnomina',
'SOLICITO: Fabio Torres Esquer';
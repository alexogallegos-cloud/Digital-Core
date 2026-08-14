CREATE PROCEDURE "informix".sp_homologacion_tarjeta_general
(
	inNumeroCaso		INTEGER,
	-- 1: CASO 1	ACT/BLO/BLT			NOA/NOE		SIN informacion en intercard:tarjetacuenta y CON informacion en bdicred:sd_tarjeta/sd_maecred
	-- 2: CASO 2	ACT/BLO/BLT			NOA/NOE 	SIN informacion en intercard:tarjetacuenta y SIN informacion en bdicred:sd_tarjeta/sd_maecred
	-- 3: CASO 3	ACT/BLO/BLT			NOA/NOE 	CON informacion en intercard:tarjetacuenta y CON informacion en bdicred:sd_tarjeta/sd_maecred
	-- 6: CASO 6	ACT/BLO/BLT			SIA    		CON informacion en intercard:tarjetacuenta y CON informacion en bdicred:sd_tarjeta/sd_maecred
	-- 9: CASO 9	DAN					NOA/NOE		SIN informacion en intercard:tarjetacuenta y CON informacion en bdicred:sd_tarjeta/sd_maecred
	--10: CASO 10	DAN					NOA/NOE		SIN informacion en intercard:tarjetacuenta y SIN informacion en bdicred:sd_tarjeta/sd_maecred con registro de numero de cliente en intercard:tarjeta
	--13: CASO 13	CAN/ROB/EXT/FAL		NOA/NOE		SIN informacion en intercard:tarjetacuenta y CON informacion en bdicred:sd_tarjeta/sd_maecred
	--16: CASO 16	CAN/ROB/EXT/FAL		NOA/NOE		CON informacion en intercard:tarjetacuenta y SIN informacion en bdicred:sd_tarjeta/sd_maecred
	--17: CASO 17	CAN/ROB/EXT/FAL		SIA			SIN informacion en intercard:tarjetacuenta y CON informacion en bdicred:sd_tarjeta/sd_maecred
	--20: CASO 20	CAN/ROB/EXT/FAL		SIA			CON informacion en intercard:tarjetacuenta y CON informacion en bdicred:sd_tarjeta/sd_maecred
	inNombreArchivo		VARCHAR(250),
	inTipoEjecucion		CHAR(1)
	-- N: normal 
	-- R: reverso
)
RETURNING CHAR(5) AS outCodigo, VARCHAR(250) AS outMensaje;
	
	-- Variables para manejar error
	DEFINE err_sql				INTEGER;
	DEFINE err_isam				INTEGER;
	DEFINE err_info				CHAR(40);
	
	-- Variable de retorno
	DEFINE vCodigoRetorno		CHAR(5);
	DEFINE vMensaje				VARCHAR(250);

	-- Variable para lectura de archivos
	DEFINE vDia         				CHAR(2);
    DEFINE vMes         				CHAR(2);
    DEFINE vAnio         				CHAR(4);
    DEFINE vHoraAux						DATETIME HOUR TO SECOND;
    DEFINE vHora						CHAR(8);
	DEFINE vRutaArchivo            		CHAR(250);
	DEFINE vRutaArchivoProcesado        CHAR(250);
	DEFINE vRutaArchivoResultado        CHAR(250);
	DEFINE vNombreArchivo   			CHAR(250);
	DEFINE vExecuteSQL      			CHAR(250);
	DEFINE vNombreTXT   				CHAR(250);
	DEFINE vNombreLog   				CHAR(250);
	DEFINE vNombreEjecucionLog  		CHAR(250);
	DEFINE vNombreArchivoResultado		CHAR(250);
	
	-- Inicializacion de variable
	LET err_sql		= 0;
	LET err_isam	= 0;
	LET err_info	= '';

	LET vCodigoRetorno	= '00000';
	LET vMensaje 		= 'PROCESO EXITOSO';
	
	LET vDia						= LPAD(DAY(CURRENT),2,'0');  
	LET vMes						= LPAD(MONTH(CURRENT),2,'0');
	LET vAnio						= YEAR(CURRENT);
	LET vHoraAux					= CURRENT;
	LET vHora						= vHoraAux::CHAR(8);
	LET vRutaArchivo				= '/RESPALDOSNEW/MaquilaPersonalizada/';
	LET vRutaArchivoProcesado		= '/RESPALDOSNEW/MaquilaPersonalizada/Procesado/';
	LET vRutaArchivoResultado		= '/RESPALDOSNEW/MaquilaPersonalizada/Procesado/';
	LET vNombreArchivo				= TRIM(inNombreArchivo);
	LET vExecuteSQL					= '';
	LET vNombreTXT					= 'PasoHomologacion.txt';
	LET vNombreLog					= 'PasoHomologacion.log';
	LET vNombreEjecucionLog			= 'PasoHomologacionRep.log';
	LET vNombreArchivoResultado		= '/RESULTADO_CASO_' || inNumeroCaso || '_' || vAnio || vMes || vDia || SUBSTR(vHora,1,2) || SUBSTR(vHora,4,2) || SUBSTR(vHora,7,2) || '.unl';
	
BEGIN
    -- Manejo de errores
    ON EXCEPTION SET err_sql, err_isam, err_info

		IF ( err_sql <> 0 ) THEN
		
			LET vCodigoRetorno	= err_sql;
			LET vMensaje		= 'Error: ' || err_isam || err_info;
		
			RETURN vCodigoRetorno, vMensaje;
			
		END IF;

    END EXCEPTION;

	--SET DEBUG FILE TO "/home/c90311247/homologacion_sp/cc_32_511_cancelacion/pruebas/sp_homologacion_tarjeta_general.out";
	--TRACE ON;
	
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	-- Tabla de paso para descargar estatus anterior de tarjeta y confirmacion de tarjetas a las que se les aplico cambio
    CREATE TABLE IF NOT EXISTS intercard:tmp_modificacion_homologacion
	(
		numtarjeta			CHAR(16),
		codstatustarjeta	VARCHAR(3),
		codstatusasignada	VARCHAR(3),
		status_tar			CHAR(1)	
    );
	
	CREATE INDEX IF NOT EXISTS tmp_mod_homo_idx1 ON tmp_modificacion_homologacion(numtarjeta) ONLINE;
	
	-- Tabla de paso para leer todas las tarjeta de cada caso  
    CREATE TABLE IF NOT EXISTS intercard:tmp_numtarjeta_homologacion
	(
        numtarjeta            CHAR(16)
    );
	
	CREATE INDEX IF NOT EXISTS tmp_num_homo_idx1 ON tmp_numtarjeta_homologacion(numtarjeta) ONLINE;
	
	TRUNCATE TABLE intercard:tmp_modificacion_homologacion;
	TRUNCATE TABLE intercard:tmp_numtarjeta_homologacion; 
	
	IF inTipoEjecucion = 'N' THEN
	
		-- Se lee el archivo que contiene la lista de tarjetas a trabajar
		LET vExecuteSQL = "echo "||'"'|| "FILE '" || TRIM(vRutaArchivo) || TRIM(vNombreArchivo) || "' delimiter '" || '|' || "' " || '1' || "; INSERT INTO "|| 'tmp_numtarjeta_homologacion' || ";" || '"' || ' > '|| TRIM(vRutaArchivo) || TRIM(vNombreTXT);
		SYSTEM vExecuteSQL;
		
	ELSE 
	
		-- Se lee el archivo que contiene la lista de tarjetas a trabajar
		LET vExecuteSQL = "echo "||'"'|| "FILE '" || TRIM(vRutaArchivo) || TRIM(vNombreArchivo) || "' delimiter '" || '|' || "' " || '4' || "; INSERT INTO "|| 'tmp_modificacion_homologacion' || ";" || '"' || ' > '|| TRIM(vRutaArchivo) || TRIM(vNombreTXT);
		SYSTEM vExecuteSQL;
		
	END IF;

	LET vExecuteSQL = "chmod 777 " || TRIM(vRutaArchivo) || TRIM(vNombreTXT);
	SYSTEM vExecuteSQL;

	LET vExecuteSQL = "dbload -d intercard -c " || TRIM(vRutaArchivo) || TRIM(vNombreTXT) || " -l " || TRIM(vRutaArchivo) || TRIM(vNombreLog) || " -n " || 1000 || " -r > " || TRIM(vRutaArchivo) || TRIM(vNombreEjecucionLog);
	SYSTEM vExecuteSQL;

	LET vExecuteSQL = "chmod 777 " || TRIM(vRutaArchivo) || TRIM(vNombreLog);
	SYSTEM vExecuteSQL;

	LET vExecuteSQL = "chmod 777 " || TRIM(vRutaArchivo) || TRIM(vNombreEjecucionLog);
	SYSTEM vExecuteSQL;

	LET vExecuteSQL = "rm -r " || TRIM(vRutaArchivo) || TRIM(vNombreLog);
	SYSTEM vExecuteSQL;

	LET vExecuteSQL = "rm -r " || TRIM(vRutaArchivo) || TRIM(vNombreEjecucionLog);
	SYSTEM vExecuteSQL;

	LET vExecuteSQL = "rm -r " || TRIM(vRutaArchivo) || TRIM(vNombreTXT);
	SYSTEM vExecuteSQL;
	
	LET vExecuteSQL = "mv " || TRIM(vRutaArchivo) || TRIM(vNombreArchivo) || " " || TRIM(vRutaArchivoResultado);
	SYSTEM vExecuteSQL;

	LET vExecuteSQL = '';

	IF inTipoEjecucion = 'N' THEN
	
		IF ((SELECT COUNT(*) FROM intercard:tmp_numtarjeta_homologacion) > 0 ) THEN

			EXECUTE PROCEDURE intercard:sp_homologacion_tarjeta_normal( inNumeroCaso ) INTO vCodigoRetorno, vMensaje;
			
		ELSE 
		
			LET vCodigoRetorno	= '00001';
			LET vMensaje		= 'PROCESO EXITOSO - Archivo vacio, no se proceso ninguna tarjeta';
		
			RETURN vCodigoRetorno, vMensaje;
		
		END IF;
	
		-- Descarga de las tarjetas procesadas, mismo que sirve como un archivo de reverso en caso de aplicar
		IF ((SELECT COUNT(*) FROM intercard:tmp_modificacion_homologacion) > 0 ) THEN
				
			LET vExecuteSQL = 'echo "UNLOAD TO ' || TRIM(vRutaArchivoResultado) || TRIM (vNombreArchivoResultado) || ' DELIMITER '',''" > ' || TRIM(vRutaArchivoResultado) || '/querydescarga.sql';
			SYSTEM vExecuteSQL;
			
			LET vExecuteSQL = 'chmod 777 ' || TRIM(vRutaArchivoResultado) || '/querydescarga.sql';
			SYSTEM vExecuteSQL;
		
			LET vExecuteSQL = 'echo "SELECT * FROM intercard:tmp_modificacion_homologacion;" >> ' || TRIM(vRutaArchivoResultado) || '/querydescarga.sql';
			SYSTEM vExecuteSQL;
		
			LET vExecuteSQL = "dbaccess intercard " || TRIM(vRutaArchivoResultado) || '/querydescarga.sql';
			SYSTEM vExecuteSQL;
			
			LET vExecuteSQL = "rm -r " || TRIM(vRutaArchivoResultado) || '/querydescarga.sql';
			SYSTEM vExecuteSQL;	
		
			LET vExecuteSQL="";
			
		ELSE 
		
			LET vCodigoRetorno	= '00002';
			LET vMensaje		= 'PROCESO EXITOSO - No se proceso ninguna tarjeta';
			
		END IF;
		
	ELSE 
	
		IF ((SELECT COUNT(*) FROM intercard:tmp_modificacion_homologacion) > 0 ) THEN

			EXECUTE PROCEDURE intercard:sp_homologacion_tarjeta_reverso( inNumeroCaso ) INTO vCodigoRetorno, vMensaje;
			
		ELSE 
		
			LET vCodigoRetorno	= '00001';
			LET vMensaje		= 'PROCESO EXITOSO - Archivo vacio, no se proceso ninguna tarjeta para reversar';
		
			RETURN vCodigoRetorno, vMensaje;
		
		END IF;
	
	END IF;
	
    DROP TABLE IF EXISTS intercard:tmp_modificacion_homologacion;
	DROP TABLE IF EXISTS intercard:tmp_numtarjeta_homologacion; 

	RETURN vCodigoRetorno, vMensaje;

END;
END PROCEDURE;
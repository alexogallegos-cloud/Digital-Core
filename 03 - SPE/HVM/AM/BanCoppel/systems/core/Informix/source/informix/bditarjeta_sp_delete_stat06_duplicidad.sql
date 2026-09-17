CREATE PROCEDURE "informix".sp_delete_stat06_duplicidad(
	fecha_carga   DATETIME YEAR to FRACTION(3),
	nombre_carga  CHAR(23),
	accion        CHAR(1),
	ruta          CHAR(200)
)
RETURNING 
	CHAR(5) 	AS codigo, 
	CHAR(100) 	AS descripcion;
	
	-- Variables para el control de errores, codigos y mensajes
	DEFINE vCodigoRetorno		CHAR(5);
	DEFINE vMensaje 			CHAR(160);
	DEFINE SQLERR 				INTEGER;
    DEFINE ISAM_ERR 			INTEGER;
   	DEFINE ERROR_INFO 			VARCHAR(80);
	
	-- Variables ELIMINACION
	DEFINE vFecha_Carga             DATETIME YEAR to FRACTION(3);
	DEFINE vNumeroTarjeta 			CHAR(16);
	DEFINE vSecuenciaExtendida      VARCHAR(50);
	DEFINE vNombre_archivo          CHAR(23);
	DEFINE vContador                INTEGER;
	DEFINE vConsecutivo             INTEGER;
	DEFINE vAccion                  CHAR(1);
	DEFINE vRuta				    CHAR(100);
	DEFINE vExecuteSQL		        CHAR(300);
	DEFINE vNombreCompTXT		    CHAR(250);
	DEFINE vNombreCompLog		    CHAR(250);
	DEFINE vNombreEjecucionLog      CHAR(150);

	-- Inicializacion de variables
	LET vCodigoRetorno		= '00000';
	LET vMensaje 			= 'PROCESO EXITO';
	LET SQLERR 				= 0;
    LET ISAM_ERR 			= 0;
   	LET ERROR_INFO 			= '';
	
	LET vFecha_Carga             	= fecha_carga;
	LET vNumeroTarjeta 			 	= '';
	LET vSecuenciaExtendida      	= '';
    LET vNombre_archivo          	= nombre_carga;
	LET vContador                	= 0;
	LET vConsecutivo             	= 0;
	LET vAccion                  	= accion;
	LET vRuta                    	= TRIM(ruta);
	LET vExecuteSQL					= '';
	LET vNombreCompTXT 				= TRIM(vRuta) || "/dbload_archivo_conciliacion_stat06.txt";
	LET vNombreCompLog 				= TRIM(vRuta) || "/dbload_archivo_conciliacion_stat06.log";
	LET vNombreEjecucionLog 		= TRIM(vRuta) || "/dbload_archivo_conciliacion_stat06_rep.log";

BEGIN
	ON EXCEPTION SET SQLERR, ISAM_ERR, ERROR_INFO
        IF SQLERR <> 0 THEN
			LET vCodigoRetorno 	= SQLERR;
			LET vMensaje  		= ERROR_INFO;
			
			-- Se valida si es necesario terminar el ultimo bloque de ejecucion
			IF (vContador > 0) THEN 
				LET vCodigoRetorno 	= SQLERR;
				LET vMensaje 		= ERROR_INFO;
				COMMIT;
			END IF;
				
			RETURN vCodigoRetorno, vMensaje;
        END IF;
    END EXCEPTION;
	
	SET ISOLATION TO DIRTY READ; 
    SET LOCK MODE TO WAIT 3;
		
	--Borrar Datos
	IF vAccion = 1 THEN 
	
		BEGIN WORK;		
			FOREACH WITH HOLD
				SELECT  numtarjeta, secuencia_extendida, consecutivo
				INTO vNumeroTarjeta, vSecuenciaExtendida, vConsecutivo 
				FROM bditarjeta:td_movimientos_conciliacion
				WHERE nombrearchivo = vNombre_archivo
				AND fechacarga = vFecha_Carga
			
				DELETE bditarjeta:td_movimientos_conciliacion
				WHERE nombrearchivo = vNombre_archivo
				AND fechacarga = vFecha_Carga
				AND archivo_origen = 'IST'
				AND numtarjeta = vNumeroTarjeta
				AND secuencia_extendida = vSecuenciaExtendida
				AND consecutivo = vConsecutivo;
				
				LET vContador = vContador + 1;
				
				IF (vContador = 1000) THEN 
					COMMIT;
					LET vContador = 0;
					BEGIN WORK;
				END IF;
			END FOREACH;
		COMMIT ;
		
		LET vContador = 0; 
		
		BEGIN WORK;
			FOREACH WITH HOLD
				SELECT  numtarjeta, secuenciaextendida, keyx
				INTO vNumeroTarjeta, vSecuenciaExtendida, vConsecutivo 
				FROM intercard:conciliacion_atm_stat06
				WHERE nombrearchivo = vNombre_archivo
				AND fechaconciliacion = vFecha_Carga
			
				DELETE intercard:conciliacion_atm_stat06
				WHERE nombrearchivo = vNombre_archivo
				AND fechaconciliacion = vFecha_Carga
				AND archivoorigen = 'IST'
				AND numtarjeta = vNumeroTarjeta
				AND secuenciaextendida = vSecuenciaExtendida
				AND keyx = vConsecutivo;
				
				LET vContador = vContador + 1;
				
				IF (vContador = 1000) THEN 
					COMMIT;
					LET vContador = 0;
					BEGIN WORK;
				END IF;	
			END FOREACH;
		COMMIT;
	
    ELIF accion = 2 THEN
	
		LET vContador = 1000;

		--Comienza Load de archivo 
		LET vCodigoRetorno = '00001';        
		LET vMensaje = 'GENERAR COMANDO DE CARGA.';
				
		LET vExecuteSQL = '';
		LET vExecuteSQL = "echo "||'"'|| "FILE '"|| TRIM(vRuta) || "' delimiter '"|| '|' ||"' "|| '55'||
					"; INSERT INTO "|| 'td_movimientos_conciliacion' || ";"||'"'||' > '|| vNombreCompTXT;
		SYSTEM vExecuteSQL;
		
        LET vCodigoRetorno = '00002';        
		LET vMensaje = 'EJECUTAR CARGA DE ARCHIVO.';
		
        LET vExecuteSQL = '';
		LET vExecuteSQL = "dbload -d bditarjeta -c " || vNombreCompTXT || " -l " || vNombreCompLog || " -n " || vContador ||" -r > "||vNombreEjecucionLog;
		SYSTEM vExecuteSQL;
		
        LET vCodigoRetorno = '00000';        
		LET vMensaje = 'ARCHIVO CARGADO';
			
	ELIF accion = 3 THEN 
	
		LET vContador = 1000;	
	
		LET vCodigoRetorno = '00001';        
		LET vMensaje = 'GENERAR COMANDO DE CARGA.';
				
		LET vExecuteSQL = '';
		LET vExecuteSQL = "echo "||'"'|| "FILE '"|| TRIM(vRuta) || "' delimiter '"|| '|' ||"' "|| '34'||
					"; INSERT INTO "|| 'conciliacion_atm_stat06' || ";"||'"'||' > '|| vNombreCompTXT;
		SYSTEM vExecuteSQL;
		
        LET vCodigoRetorno = '00002';        
		LET vMensaje = 'EJECUTAR CARGA DE ARCHIVO.';
		
        LET vExecuteSQL = '';
		LET vExecuteSQL = "dbload -d intercard -c " || vNombreCompTXT || " -l " || vNombreCompLog || " -n " || vContador ||" -r > "||vNombreEjecucionLog;
		SYSTEM vExecuteSQL;
		
        LET vCodigoRetorno = '00000';        
		LET vMensaje = 'ARCHIVO CARGADO';
		
	END IF;

	RETURN vCodigoRetorno, vMensaje;

END

END PROCEDURE;
CREATE PROCEDURE "informix".sp_guardaraplicacion(piCveAplicacion INT, pcNombreAplicacion CHAR(30), pcPeriodicidad CHAR(1), piTiempoEnLinea INT, piDiaRespaldo SMALLINT, 
pcActivar CHAR(1), piCveDependencia INT, piTiempoMaxSol INT, pcUser CHAR(10))
	RETURNING CHAR(5) AS Retorno, CHAR(100) as DescError;
		
	/*
	*****************************************************************************************************
	-- DESCRIPCION:  Guarda las aplicaciones dadas de alta ----------------------------------------------
	-- AUTOR : Walber Castro ----------------------------------------------------------------------------
	-- FECHA : 04/10/2012  ------------------------------------------------------------------------------
	-- BD: bdiresp  -------------------------------------------------------------------------------------	
	-----------------------------------------------------------------------------------------------------
	*****************************************************************************************************
	-- MODIFICACIÓN: Se eliminaron las referencias a la BD bdiresp de los sp's propios de esta.
	-- AUTOR: Moisés Soriano
	-- FECHA : 26/02/2013
	-- BD: bdiresp
	*/
	
	DEFINE viCodigo		INT;
	DEFINE viCodigo2	INT;
	DEFINE vcCodRet		CHAR(5);
	DEFINE vcCodRet2	CHAR(5);
	DEFINE vcDescRet	CHAR(100);
	DEFINE vcDescRet2	CHAR(100);
		
	LET viCodigo	= 	0;
	LET viCodigo2	= 	0;
	LET vcCodRet	= 	'00000';
	LET vcCodRet2	= 	'00000';
	LET vcDescRet	= 	'';
	LET vcDescRet2	= 	'';

--SET DEBUG FILE TO "/tmp/moises/prueba/sp_guardaraplicacion.out";
--TRACE ON;

	
	BEGIN

	ON EXCEPTION SET viCodigo
		IF viCodigo <> 0 THEN
			LET vcCodRet = viCodigo;
		END IF;
		IF ( NVL(piCveAplicacion,0) = 0 ) THEN
			--LOG DE ERRORES
			EXECUTE PROCEDURE sp_insertaLog(1000, 'REGISTRO DE APLICACIÓN', '', "Informix", 3, 'ERROR ' || viCodigo || ' AL EJECUTAR EL SP sp_guardarAplicacion(' || NVL(piCveAplicacion,'NULL') || ',' || TRIM(NVL(pcNombreAplicacion,'NULL')) || ',' || TRIM(NVL(pcPeriodicidad,'NULL')) || ',' || NVL(piTiempoEnLinea,'NULL') || ',' || NVL(piDiaRespaldo,'NULL') || ',' || TRIM(NVL(pcActivar,'NULL')) || ',' || NVL(piCveDependencia,'NULL') || ',' || NVL(piTiempoMaxSol,'NULL') || ',' || TRIM(NVL(pcUser,'NULL')) ) INTO viCodigo2, vcDescRet2;
		ELSE
			--LOG DE ERRORES
			EXECUTE PROCEDURE sp_insertaLog(1001, 'EDICIÓN DE APLICACIÓN', '', "Informix", 3, 'ERROR ' || viCodigo || ' AL EJECUTAR EL SP sp_guardarAplicacion(' || NVL(piCveAplicacion,'NULL') || ',' || TRIM(NVL(pcNombreAplicacion,'NULL')) || ',' || TRIM(NVL(pcPeriodicidad,'NULL')) || ',' || NVL(piTiempoEnLinea,'NULL') || ',' || NVL(piDiaRespaldo,'NULL') || ',' || TRIM(NVL(pcActivar,'NULL')) || ',' || NVL(piCveDependencia,'NULL') || ',' || NVL(piTiempoMaxSol,'NULL') || ',' || TRIM(NVL(pcUser,'NULL')) ) INTO viCodigo2, vcDescRet2;
		END IF;
		RETURN NVL(vcCodRet,''),NVL(vcDescRet,'');
	END EXCEPTION;	
		
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
		
	EXECUTE PROCEDURE sp_validaCadena(pcNombreAplicacion,'1','1',NULL) INTO vcCodRet2;
	
	IF ( TRIM(NVL(vcCodRet2,'')) != '00000' ) THEN
		LET vcCodRet = '00001';
		LET vcDescRet = 'ERROR, NOMBRE APLICACIÓN INVÁLIDO (PARÁMETRO 2)';
		RETURN vcCodRet, vcDescRet;
	END IF;
	
	 IF ( NVL(piCveAplicacion,0) = 0 ) THEN
		IF(EXISTS(SELECT * FROM "informix".rp_aplicaciones WHERE nombre_aplicacion=pcNombreAplicacion)) THEN
			LET vcCodRet = '00001';
			LET vcDescRet = 'ERROR, YA EXISTE APLICACIÓN CON ESE NOMBRE (PARÁMETRO 2)';
			RETURN vcCodRet, vcDescRet;
		END IF;
	END IF;
	
	IF ( UPPER(TRIM(NVL(pcPeriodicidad,''))) != 'D' AND UPPER(TRIM(NVL(pcPeriodicidad,''))) != 'M' ) THEN
		LET vcCodRet = '00001';
		LET vcDescRet = 'ERROR, PERIODICIDAD INVÁLIDA (PARÁMETRO 3)';
		RETURN vcCodRet, vcDescRet;
	END IF;
	
	IF ( NVL(piTiempoEnLinea,0) <= 0 ) THEN
		LET vcCodRet = '00001';
		LET vcDescRet = 'ERROR, TIEMPO EN LÍNEA INVÁLIDO (PARÁMETRO 4)';
		RETURN vcCodRet, vcDescRet;
	END IF;
	
	IF ( NVL(piDiaRespaldo,0) <= 0 OR NVL(piDiaRespaldo,0) > 28 ) THEN
		LET vcCodRet = '00001';
		LET vcDescRet = 'ERROR, DÍA DE RESPALDO INVÁLIDO (PARÁMETRO 5)';
		RETURN vcCodRet, vcDescRet;
	END IF;
	
	IF ( TRIM(NVL(pcActivar,'')) != '0' AND TRIM(NVL(pcActivar,'')) != '1' ) THEN
		LET vcCodRet = '00001';
		LET vcDescRet = 'ERROR, BANDERA ACTIVA INVÁLIDA (PARÁMETRO 6)';
		RETURN vcCodRet, vcDescRet;
	END IF;
	
	IF ( NVL(piCveDependencia,-1) = -1 ) THEN
		LET vcCodRet = '00001';
		LET vcDescRet = 'ERROR, DEPENDENCIA INVÁLIDA (PARÁMETRO 7)';
		RETURN vcCodRet, vcDescRet;
	END IF;
	
	IF ( piCveDependencia <> 0 AND NOT EXISTS(SELECT cve_aplicacion FROM "informix".rp_aplicaciones WHERE cve_aplicacion = piCveDependencia)) THEN
		LET vcCodRet = '00001';
		LET vcDescRet = 'ERROR, LA DEPENDENCIA NO EXISTE (PARÁMETRO 7)';
		RETURN vcCodRet, vcDescRet;
	END IF;
	
	IF ( NVL(piTiempoMaxSol,0) <= 0 ) THEN
		LET vcCodRet = '00001';
		LET vcDescRet = 'ERROR, TIEMPO MÁXIMO DE SOLICITUD INVÁLIDO (PARÁMETRO 8)';
		RETURN vcCodRet, vcDescRet;
	END IF;
	
	IF ( TRIM(NVL(pcUser,'')) = '' ) THEN
		LET pcUser = 'Informix';
	END IF;
	
		
	
	IF ( NVL(piCveAplicacion,0) = 0 ) THEN	
		INSERT INTO "informix".rp_aplicaciones (nombre_aplicacion, periodicidad, tiempo_en_linea, dia_respaldo, activa, cve_dependencia, tiempo_max_sol, user_insert, fecha_insert)
		VALUES(TRIM(NVL(pcNombreAplicacion,'')), UPPER(TRIM(NVL(pcPeriodicidad,''))), piTiempoEnLinea, piDiaRespaldo, TRIM(NVL(pcActivar,'')), piCveDependencia, piTiempoMaxSol, TRIM(NVL(pcUser,'')), CURRENT YEAR TO SECOND);
	ELSE
		IF ( piCveDependencia = piCveAplicacion ) THEN
			LET vcCodRet = '00002';
			LET vcDescRet = 'ERROR, LA APLICACIÓN NO PUEDE SER DEPENDIENTE DE SÍ MISMA';
			RETURN vcCodRet, vcDescRet;
		ELSE
			IF (EXISTS(SELECT nombre_aplicacion FROM "informix".rp_aplicaciones WHERE cve_aplicacion = piCveAplicacion)) THEN
				UPDATE {+INDEX(bdiresp:rp_aplicaciones 100_1)} "informix".rp_aplicaciones
				SET nombre_aplicacion = TRIM(NVL(pcNombreAplicacion,'')), periodicidad = UPPER(TRIM(NVL(pcPeriodicidad,''))),	
				tiempo_en_linea = piTiempoEnLinea, dia_respaldo = piDiaRespaldo, 
				activa = TRIM(NVL(pcActivar,'')), cve_dependencia = piCveDependencia, 
				tiempo_max_sol = piTiempoMaxSol, user_insert = TRIM(NVL(pcUser,'')), fecha_insert = CURRENT YEAR TO SECOND 
				WHERE cve_aplicacion = piCveAplicacion;
			ELSE
				LET vcCodRet = '00002';
				LET vcDescRet = 'ERROR, LA CVE APLICACIÓN NO EXISTE';
			END IF;
		END IF;
	END IF;
	
	RETURN vcCodRet, vcDescRet;
	END;
END PROCEDURE;
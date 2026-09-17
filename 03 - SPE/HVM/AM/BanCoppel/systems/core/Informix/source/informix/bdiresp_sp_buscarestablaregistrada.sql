CREATE PROCEDURE "informix".sp_buscarestablaregistrada(piIdSolicitud INT, piCveAplicacion INT, pdFechaInicio DATE, pdFechaFin DATE)
	RETURNING CHAR(5) AS Retorno, CHAR(100) AS DescError, CHAR(1) AS Resultado;
		
	/*
	*****************************************************************************************************
	-- DESCRIPCION:  Busca si hay tablas registradas para restauracion ----------------------------------
	-- AUTOR : Walber Castro ----------------------------------------------------------------------------
	-- FECHA : 04/10/2012  ------------------------------------------------------------------------------
	-- BD: bdiresp  -------------------------------------------------------------------------------------	
	-----------------------------------------------------------------------------------------------------
	*****************************************************************************************************
	-- MODIFICACIÓN: Se modificó el formato de fechas del nombre del archivo en base a su periodicidad,
	-- Se eliminaron las referencias a la BD bdiresp de los sp's propios de esta.
	-- AUTOR: Moisés Soriano
	-- FECHA : 26/02/2013
	-- BD: bdiresp
	*/
	
	DEFINE viCodigo				INT;
	DEFINE viCodigo2			INT;
	DEFINE vcCodRet				CHAR(5);
	DEFINE vcCodRet2			CHAR(5);	
	DEFINE vcDescRet			CHAR(100);
	DEFINE vcDescRet2			CHAR(100);	
	DEFINE vdFechaInicio_Actual DATE;
	DEFINE vdFechaFin_Actual 	DATE;
	DEFINE vcRes 				CHAR(1);
	DEFINE viCveAplicacion 		INT;
	DEFINE vcTabla				CHAR(30);
	DEFINE vcNomArchivo 		CHAR(50);
	DEFINE vcPeriodicidad 		CHAR(1);
	DEFINE vcNomArchivoTMP 		CHAR(50);
	DEFINE viCveAplicacionTmp 	INT;
	
	LET vcDescRet2 			= 	'';
	LET vcTabla 			= 	'';
	LET vcNomArchivo 		= 	'';
	LET vcPeriodicidad 		= 	'';
	LET vcNomArchivoTMP 	= 	'';
	LET viCodigo			= 	0;
	LET viCodigo2			= 	0;
	LET vcCodRet			= 	'00000';
	LET vcCodRet2			= 	'00000';
	LET vcDescRet			= 	'';
	LET vcRes 				= 	'';
	LET vdFechaInicio_Actual= 	'01-01-1900';
	LET vdFechaFin_Actual 	= 	'01-01-1900';
	LET viCveAplicacion 	= 	piCveAplicacion;
	LET viCveAplicacionTmp 	= 	0;
	
	BEGIN

	ON EXCEPTION SET viCodigo
		IF viCodigo <> 0 THEN
			LET vcCodRet = viCodigo;
		END IF;
		--LOG DE ERRORES
		EXECUTE PROCEDURE sp_insertaLog(4000, 'REGISTRO DE RESTAURACIÓN', '', "Informix", 3, 'ERROR ' || viCodigo || ' AL EJECUTAR EL SP sp_buscaResTablaRegistrada(' || NVL(piIdSolicitud,'NULL') || ',' || NVL(piCveAplicacion,'NULL') || ',' || NVL(pdFechaInicio,'NULL') || ',' || NVL(pdFechaFin,'NULL') || ')' ) INTO viCodigo2, vcDescRet2;
		RETURN NVL(vcCodRet,''),NVL(vcDescRet,''),'';
	END EXCEPTION;	

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;	
	
	IF ( NVL(piCveAplicacion,0) <= 0 ) THEN
		LET vcCodRet = '00001';
		LET vcDescRet = 'ERROR, CVE APLICACIÓN INVÁLIDA (PARÁMETRO 2)';
		RETURN vcCodRet, vcDescRet, vcRes;
	END IF;	
	
	IF ( NOT EXISTS(SELECT cve_aplicacion FROM "informix".rp_aplicaciones WHERE cve_aplicacion = piCveAplicacion)) THEN
		LET vcCodRet = '00001';
		LET vcDescRet = 'ERROR, LA CVE APLICACIÓN NO EXISTE';
		RETURN vcCodRet, vcDescRet, vcRes;
	END IF;
	
	IF ( NVL(pdFechaInicio,'01-01-1900') = '01-01-1900' ) THEN
		LET vcCodRet = '00001';
		LET vcDescRet = 'ERROR, FECHA INICIO INVÁLIDA (PARÁMETRO 3)';
		RETURN vcCodRet, vcDescRet, vcRes;
	END IF;
	
	IF ( NVL(pdFechaFin,'01-01-1900') = '01-01-1900' ) THEN
		LET vcCodRet = '00001';
		LET vcDescRet = 'ERROR, FECHA FIN INVÁLIDA (PARÁMETRO 4)';
		RETURN vcCodRet, vcDescRet, vcRes;
	END IF;	
	
	IF ( piIdSolicitud IS NULL ) THEN
		LET piIdSolicitud = 0;
	END IF;
		
	WHILE viCveAplicacion <> 0 --CICLO PARA CONSULTAR LAS TABLAS DE LA APLICACIÓN SOLICITADA, ASÍ COMO LAS DEPENDIENTES
		EXECUTE PROCEDURE sp_consultaPeriodicidad(viCveAplicacion) INTO vcCodRet2, vcDescRet2, vcPeriodicidad;
		
		FOREACH		
			SELECT tabla, estructura_nom_archivo
			INTO vcTabla, vcNomArchivo
			FROM "informix".rp_tabla_aplicacion
			WHERE cve_aplicacion = viCveAplicacion AND ind_restauracion = '1'
			
			LET vdFechaInicio_Actual = pdFechaInicio;
			IF ( NVL(vcPeriodicidad,'') = 'M') THEN
				LET vdFechaFin_Actual = vdFechaInicio_Actual + 1 UNITS MONTH - 1 UNITS DAY;
			ELIF ( NVL(vcPeriodicidad,'') = 'D') THEN					
				LET vdFechaFin_Actual = vdFechaInicio_Actual;
			END IF;
			LET vcNomArchivoTMP = TRIM(vcNomArchivo);					
					
			WHILE vdFechaInicio_Actual < pdFechaFin	--CICLO PARA INSERTAR LAS TABLAS MES POR MES O DÍA POR DÍA
				
				-- Asigna formato de fecha al nombre del archivo
				IF (NVL(vcPeriodicidad,'')='M') THEN
					LET vcNomArchivo = TRIM(vcNomArchivoTMP) || '_' || YEAR(vdFechaFin_Actual) || LPAD(MONTH(vdFechaFin_Actual),2,'0');
				ELIF (NVL(vcPeriodicidad,'')='D') THEN
					LET vcNomArchivo = TRIM(vcNomArchivoTMP) || '_' || YEAR(vdFechaFin_Actual) || LPAD(MONTH(vdFechaFin_Actual),2,'0') || LPAD(DAY(vdFechaFin_Actual),2,'0');
				END IF;
				
				--SE CONSULTA SI HAY TABLAS DE ALGUNA OTRA RESTAURACION QUE YA CONSIDEREN EL PERÍODO SOLICITADO
				IF (EXISTS(SELECT t2.id_solicitud
					FROM "informix".rp_tablas_restauradas t1 		
					INNER JOIN "informix".rp_restauraciones t2 ON (t1.id_solicitud = t2.id_solicitud)
					INNER JOIN "informix".rp_tabla_aplicacion t3 ON (t1.tabla = t3.tabla)
					WHERE t3.cve_aplicacion = viCveAplicacion AND t2.id_solicitud <> piIdSolicitud AND t1.tabla = TRIM(vcTabla) AND t1.nombre_archivo = TRIM(vcNomArchivo)
					AND t1.fecha_inicio = vdFechaInicio_Actual AND t1.fecha_fin = vdFechaFin_Actual AND t1.fecha_caducidad > TODAY AND t1.estatus IN ('0','1'))) THEN
					LET vcRes = '1';
					EXIT WHILE;
				END IF;
				
				IF ( NVL(vcPeriodicidad,'') = 'M') THEN
					LET vdFechaInicio_Actual = vdFechaInicio_Actual + 1 UNITS MONTH;
					LET vdFechaFin_Actual = vdFechaInicio_Actual + 1 UNITS MONTH - 1 UNITS DAY;
				ELIF ( NVL(vcPeriodicidad,'') = 'D') THEN
					LET vdFechaInicio_Actual = vdFechaInicio_Actual + 1 UNITS DAY;
					LET vdFechaFin_Actual = vdFechaInicio_Actual;
				END IF;
			END WHILE;
			IF ( vcRes = '1' ) THEN
				EXIT FOREACH;
			END IF;
		END FOREACH;
		
		IF ( vcRes = '1' ) THEN
			EXIT WHILE;
		END IF;
				
		SELECT NVL(cve_dependencia,0) INTO viCveAplicacionTMP FROM "informix".rp_aplicaciones WHERE cve_aplicacion = viCveAplicacion;
		LET viCveAplicacion = NVL(viCveAplicacionTMP,0);
	END WHILE;
	RETURN vcCodRet, vcDescRet, vcRes;
	END;
END PROCEDURE;
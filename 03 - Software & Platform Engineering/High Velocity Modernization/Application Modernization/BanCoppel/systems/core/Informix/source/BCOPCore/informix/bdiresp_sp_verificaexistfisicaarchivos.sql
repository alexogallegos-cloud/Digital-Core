CREATE PROCEDURE "informix".sp_verificaexistfisicaarchivos(piCveAplicacion INT, pdFechaInicio DATE, pdFechaFin DATE)
	RETURNING CHAR(5) AS Retorno, CHAR(100) AS DescError, CHAR(50) AS archivo, CHAR(1) AS existe;
		
	/*
	*****************************************************************************************************
	-- DESCRIPCION:  Verifica que los archivos de respaldo existan en el servidor -----------------------
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
	DEFINE vcNomArchivo 		CHAR(50);
	DEFINE vcPeriodicidad 		CHAR(1);
	DEFINE vcNomArchivoTMP 		CHAR(50);
	DEFINE viCveAplicacionTmp 	INT;
	DEFINE vcRuta 				CHAR(100);
	DEFINE viCont				INT;
	DEFINE vcSql				CHAR(500);
	DEFINE vcRutaBase			CHAR(50);
	
	LET vcDescRet2 				= 	'';	
	LET vcNomArchivo 			= 	'';
	LET vcPeriodicidad 			= 	'';
	LET vcNomArchivoTMP 		= 	'';
	LET viCodigo				= 	0;
	LET viCodigo2				=	0;
	LET vcCodRet				= 	'00000';
	LET vcCodRet2				= 	'00000';
	LET vcDescRet				= 	'';
	LET vcRes 					= 	'';
	LET vdFechaInicio_Actual 	= 	'01-01-1900';
	LET vdFechaFin_Actual 		= 	'01-01-1900';
	LET viCveAplicacion 		= 	piCveAplicacion;
	LET viCveAplicacionTmp 		= 	0;
	LET vcRuta 					= 	'';
	LET viCont 					= 	0;
	LET vcSql 					= 	'';
	LET vcRutaBase				=	'';
	
--SET DEBUG FILE TO "/tmp/moises/outs/sp_verificaexistfisicaarchivos.out";
--TRACE ON;
	
	BEGIN

	ON EXCEPTION SET viCodigo
		IF viCodigo <> 0 THEN
			LET vcCodRet = viCodigo;
		END IF;
		DELETE {+INDEX(bdiresp:rp_existenarchivos idx_rpexistearchivo)} FROM "informix".rp_existenarchivos;
		--LOG DE ERRORES
		EXECUTE PROCEDURE sp_insertaLog(4000, 'REGISTRO DE RESTAURACIÓN', '', "Informix", 3, 'ERROR ' || viCodigo || ' AL EJECUTAR EL SP sp_verificaExistFisicaArchivos(' || NVL(piCveAplicacion,'NULL') || ',' || NVL(pdFechaInicio,'NULL') || ',' || NVL(pdFechaFin,'NULL') || ')') INTO viCodigo2, vcDescRet2;
		RETURN NVL(vcCodRet,''),NVL(vcDescRet,''),'','';
	END EXCEPTION;	

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;	
	
	IF ( NVL(piCveAplicacion,0) <= 0 ) THEN
		LET vcCodRet = '00001';
		LET vcDescRet = 'ERROR, CVE APLICACIÓN INVÁLIDA (PARÁMETRO 1)';
		RETURN vcCodRet, vcDescRet, '', '';
	END IF;	
	
	IF ( NOT EXISTS(SELECT cve_aplicacion FROM "informix".rp_aplicaciones WHERE cve_aplicacion = piCveAplicacion)) THEN
		LET vcCodRet = '00001';
		LET vcDescRet = 'ERROR, LA CVE APLICACIÓN NO EXISTE (PARÁMETRO 1)';
		RETURN vcCodRet, vcDescRet, '', '';
	END IF;
	
	IF ( pdFechaInicio IS NULL ) THEN
		LET vcCodRet = '00001';
		LET vcDescRet = 'ERROR, FECHA INICIO INVÁLIDA (PARÁMETRO 2)';
		RETURN vcCodRet, vcDescRet, '', '';
	END IF;
	
	IF ( pdFechaFin IS NULL ) THEN
		LET vcCodRet = '00001';
		LET vcDescRet = 'ERROR, FECHA FIN INVÁLIDA (PARÁMETRO 3)';
		RETURN vcCodRet, vcDescRet, '', '';
	END IF;	
	
	EXECUTE PROCEDURE sp_consultaParametro('01') INTO vcCodRet2, vcRutaBase;
	
	IF ( TRIM(NVL(vcCodRet2,'')) <> '00000' OR TRIM(NVL(vcRutaBase,'')) = '' ) THEN
		LET vcCodRet = '00001';
		LET vcDescRet = 'NO SE ENCONTRÓ LA RUTA BASE EN LA TABLA DE PARÁMETROS';
		--LOG DE ERRORES
		EXECUTE PROCEDURE sp_insertaLog(4000, 'REGISTRO DE SOLICITUD DE RESTAURACIÓN', '', "Informix", 3, vcDescRet) INTO viCodigo2, vcDescRet2;
		RETURN vcCodRet, vcDescRet, '', '';
	END IF;
	
	IF ( SUBSTR(TRIM(NVL(vcRutaBase,'')),LENGTH(TRIM(NVL(vcRutaBase,''))),1) <> '/' ) THEN
		LET vcRutaBase = TRIM(NVL(vcRutaBase,'')) || '/';
	END IF;
	
	EXECUTE PROCEDURE sp_validaCadena(vcRutaBase,"1","1","/") INTO vcCodRet2;
	IF ( TRIM(NVL(vcCodRet2,'')) != '00000' ) THEN
		LET vcCodRet = '00001';
		LET vcDescRet = 'RUTA BASE INVÁLIDA';
		--LOG DE ERRORES
		EXECUTE PROCEDURE sp_insertaLog(4000, 'REGISTRO DE SOLICITUD DE RESTAURACIÓN', '', "Informix", 3, vcDescRet) INTO viCodigo2, vcDescRet2;
		RETURN vcCodRet, vcDescRet, '', '';
	END IF;
	
	EXECUTE PROCEDURE sp_validaRuta(vcRutaBase) INTO viCont;
	IF ( viCont <> 0 ) THEN
		LET vcCodRet = '00001';
		LET vcDescRet = 'RUTA BASE INVÁLIDA';
		--LOG DE ERRORES
		EXECUTE PROCEDURE sp_insertaLog(4000, 'REGISTRO DE SOLICITUD DE RESTAURACIÓN', '', "Informix", 3, vcDescRet) INTO viCodigo2, vcDescRet2;
		RETURN vcCodRet, vcDescRet, '', '';
	END IF;
	
	LET viCont = 0;
	
	DELETE {+INDEX(bdiresp:rp_existenarchivos idx_rpexistearchivo)} FROM "informix".rp_existenarchivos;
	WHILE viCveAplicacion <> 0 --CICLO PARA CONSULTAR LAS TABLAS DE LA APLICACIÓN SOLICITADA, ASÍ COMO LAS DEPENDIENTES
		EXECUTE PROCEDURE sp_consultaPeriodicidad(viCveAplicacion) INTO vcCodRet2, vcDescRet2, vcPeriodicidad;
		IF ( TRIM(NVL(vcCodRet2,'')) = '00000' AND ( TRIM(NVL(vcPeriodicidad,'')) = 'D' OR TRIM(NVL(vcPeriodicidad,'')) = 'M' ) ) THEN		
			FOREACH		
				SELECT estructura_nom_archivo, ruta
				INTO vcNomArchivo, vcRuta
				FROM "informix".rp_tabla_aplicacion
				WHERE cve_aplicacion = viCveAplicacion AND ind_restauracion = '1' ORDER BY estructura_nom_archivo		
				
				LET vdFechaInicio_Actual = pdFechaInicio;
				IF ( NVL(vcPeriodicidad,'') = 'M') THEN
					LET vdFechaFin_Actual = vdFechaInicio_Actual + 1 UNITS MONTH - 1 UNITS DAY;
				ELIF ( NVL(vcPeriodicidad,'') = 'D') THEN
					LET vdFechaFin_Actual = vdFechaInicio_Actual;
				END IF;
				LET vcNomArchivoTMP = TRIM(NVL(vcNomArchivo,''));					
						
				WHILE vdFechaInicio_Actual <= pdFechaFin	--CICLO PARA INSERTAR LAS TABLAS MES POR MES O DÍA POR DÍA
									
					-- Se verifica la periodicidad y de acuerdo a ella se le asigna el formato.
					IF ( NVL(vcPeriodicidad,'') = 'M') THEN
						LET vcNomArchivo = TRIM(NVL(vcNomArchivoTMP,'')) || '_' || YEAR(vdFechaFin_Actual) || LPAD(MONTH(vdFechaFin_Actual),2,'0') ;
					ELIF ( NVL(vcPeriodicidad,'') = 'D') THEN
						LET vcNomArchivo = TRIM(NVL(vcNomArchivoTMP,'')) || '_' || YEAR(vdFechaFin_Actual) || LPAD(MONTH(vdFechaFin_Actual),2,'0') || LPAD(DAY(vdFechaFin_Actual),2,'0');
					END IF;
					
					--SE CONSULTA SI HAY TABLAS DE ALGUNA OTRA RESTAURACION QUE YA CONSIDEREN EL PERÍODO SOLICITADO
					INSERT INTO "informix".rp_existenarchivos (archivo) VALUES(TRIM(NVL(vcNomArchivo,'')));
					LET vcSql = TRIM(NVL(vcRutaBase,'')) || "verificaArchivo.sh " || TRIM(NVL(vcRuta,'')) || TRIM(NVL(vcNomArchivo,'')) || ' ' || TRIM(NVL(vcNomArchivo,''));
					SYSTEM vcSql;
					SELECT {+INDEX(bdiresp:rp_existenarchivos idx_rpexistearchivo)} existe INTO vcRes FROM "informix".rp_existenarchivos WHERE archivo = TRIM(NVL(vcNomArchivo,''));
					
					LET viCont = viCont +1;
					
					IF ( NVL(vcPeriodicidad,'') = 'M') THEN
						LET vdFechaInicio_Actual = vdFechaInicio_Actual + 1 UNITS MONTH;
						LET vdFechaFin_Actual = vdFechaInicio_Actual + 1 UNITS MONTH - 1 UNITS DAY;
					ELIF ( NVL(vcPeriodicidad,'') = 'D') THEN
						LET vdFechaInicio_Actual = vdFechaInicio_Actual + 1 UNITS DAY;
						LET vdFechaFin_Actual = vdFechaInicio_Actual;
					END IF;
					RETURN vcCodRet, vcDescRet, TRIM(NVL(vcNomArchivo,'')), vcRes WITH RESUME;
				END WHILE;			
			END FOREACH;
		END IF;
				
		SELECT NVL(cve_dependencia,0) INTO viCveAplicacionTMP FROM "informix".rp_aplicaciones WHERE cve_aplicacion = viCveAplicacion;
		LET viCveAplicacion = NVL(viCveAplicacionTMP,0);
	END WHILE;
	DELETE {+INDEX(bdiresp:rp_existenarchivos idx_rpexistearchivo)} FROM "informix".rp_existenarchivos;
	IF (viCont = '0') THEN
		LET vcCodRet = '00002';
		LET vcDescRet = 'ERROR, NO SE ENCONTRÓ INFORMACIÓN';
		RETURN vcCodRet, vcDescRet, '', '';
	END IF;
	END;
END PROCEDURE;
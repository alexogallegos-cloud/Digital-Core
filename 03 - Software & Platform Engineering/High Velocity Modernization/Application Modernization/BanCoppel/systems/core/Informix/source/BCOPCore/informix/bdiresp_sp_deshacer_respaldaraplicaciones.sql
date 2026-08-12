CREATE PROCEDURE "informix".sp_deshacer_respaldaraplicaciones(pdFechaCaracter CHAR(10))
	RETURNING CHAR(5) AS Retorno, CHAR(100) as DescError;
		
	/*
	*****************************************************************************************************
	-- DESCRIPCION:  hace rollback al proceso de respaldo de aplicaciones -------------------------------
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
	*****************************************************************************************************
	-- MODIFICACION:  Se modificó la fecha diaria para que respete los meses en linea asignados  --------
	-- AUTOR : Roberto Castro ---------------------------------------------------------------------------
	-- FECHA : 07/15/2013  ------------------------------------------------------------------------------
	-- BD: bdiresp  -------------------------------------------------------------------------------------	
	-----------------------------------------------------------------------------------------------------
	*****************************************************************************************************
	*/
	
	DEFINE viCodigo			INT;
	DEFINE vcCodRet			CHAR(5);
	DEFINE vcCodRet2		CHAR(5);	
	DEFINE vcDescRet		CHAR(100);	
	DEFINE vcSql 			LVARCHAR(500);
	DEFINE vcRuta 			CHAR(100);
	DEFINE vcNombreArchivo	CHAR(50);
	DEFINE vcPeriodicidad	CHAR(1);	
	DEFINE vdFecha1			DATE;
	DEFINE vdFecha2			DATE;
	DEFINE viTiempoEnLinea	INT;	
	DEFINE pdFechaResp		DATE;
	DEFINE vcRutaBase		CHAR(50);
	DEFINE viCodigo2		INT;
	DEFINE vcDescRet2		CHAR(100);
	DEFINE viCont			INT;
		
	LET pdFechaResp			= TODAY;
	LET viCodigo			= 0;
	LET vcCodRet			= '00000';
	LET vcCodRet2			= '00000';
	LET vcDescRet			= '';	
	LET vcSql				= '';	
	LET vcRuta 				= '';
	LET vcNombreArchivo 	= '';	
	LET vcPeriodicidad		= '';	
	LET vdFecha1			= pdFechaResp;
	LET vdFecha2			= pdFechaResp;
	LET viTiempoEnLinea		= 0;
	LET vcRutaBase			=	'';
	LET viCodigo2			= 0;
	LET vcDescRet2			=	'';
	LET viCont				= 0;
	
	BEGIN

	ON EXCEPTION SET viCodigo
		IF viCodigo <> 0 THEN
			LET vcCodRet = viCodigo;
		END IF;	
		RETURN NVL(vcCodRet,''),NVL(vcDescRet,'');
	END EXCEPTION;
	
	IF ( pdFechaResp IS NULL ) THEN
		LET vcCodRet = '00001';
		LET vcDescRet = 'ERROR, FECHA INVÁLIDA (PARÁMETRO 1)';
		RETURN vcCodRet, vcDescRet;
	END IF;
	
	EXECUTE PROCEDURE sp_validaFecha(pdFechaCaracter) INTO vcCodRet2;
	IF ( TRIM(NVL(vcCodRet2,'')) <> '00000' ) THEN
		LET vcCodRet = '00001';
		LET vcDescRet = 'ERROR, FECHA INVÁLIDA (PARÁMETRO 1)';
		RETURN vcCodRet, vcDescRet;
	END IF;
	
	LET pdFechaResp = pdFechaCaracter::DATE;
	LET vdFecha1 = pdFechaResp;
	LET vdFecha2 = pdFechaResp;
	
	EXECUTE PROCEDURE sp_consultaParametro('01') INTO vcCodRet2, vcRutaBase;
	
	IF ( TRIM(NVL(vcCodRet2,'')) <> '00000' OR TRIM(NVL(vcRutaBase,'')) = '' ) THEN
		LET vcCodRet = '00001';
		LET vcDescRet = 'NO SE ENCONTRÓ LA RUTA BASE EN LA TABLA DE PARÁMETROS';
		--LOG DE ERRORES
		EXECUTE PROCEDURE sp_insertaLog(3001, 'PROCESO DE RESPALDO', '', "Informix", 3, vcDescRet) INTO viCodigo2, vcDescRet2;
		RETURN vcCodRet, vcDescRet;
	END IF;
	
	IF ( SUBSTR(TRIM(vcRutaBase),LENGTH(TRIM(vcRutaBase)),1) <> '/' ) THEN
		LET vcRutaBase = TRIM(vcRutaBase) || '/';
	END IF;
	
	EXECUTE PROCEDURE sp_validaCadena(vcRutaBase,"1","1","/") INTO vcCodRet2;
	IF ( TRIM(NVL(vcCodRet2,'')) != '00000' ) THEN
		LET vcCodRet = '00001';
		LET vcDescRet = 'RUTA BASE INVÁLIDA';
		--LOG DE ERRORES
		EXECUTE PROCEDURE sp_insertaLog(3001, 'PROCESO DE RESPALDO', '', "Informix", 3, vcDescRet) INTO viCodigo2, vcDescRet2;
		RETURN vcCodRet, vcDescRet;
	END IF;
	
	EXECUTE PROCEDURE sp_validaRuta(vcRutaBase) INTO viCont;
	IF ( viCont <> 0 ) THEN
		LET vcCodRet = '00001';
		LET vcDescRet = 'RUTA BASE INVÁLIDA';
		--LOG DE ERRORES
		EXECUTE PROCEDURE sp_insertaLog(3001, 'PROCESO DE RESPALDO', '', "Informix", 3, vcDescRet) INTO viCodigo2, vcDescRet2;
		RETURN vcCodRet, vcDescRet;
	END IF;	
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;	
	
	FOREACH		
		SELECT {+INDEX(bdiresp:rp_aplicaciones idx_rpappperiodicidad)} t2.ruta, t2.estructura_nom_archivo, t1.periodicidad, t1.tiempo_en_linea
		INTO vcRuta, vcNombreArchivo, vcPeriodicidad, viTiempoEnLinea
		FROM "informix".rp_aplicaciones t1 
		INNER JOIN "informix".rp_tabla_aplicacion t2 ON (t1.cve_aplicacion = t2.cve_aplicacion)
		WHERE t1.activa = '1' AND (( t1.periodicidad = 'M' AND t1.dia_respaldo = DAY(pdFechaResp) ) OR ( t1.periodicidad = 'D' ))
		AND t2.activa = '1' AND t2.ind_respaldo = '1' ORDER BY t2.cve_aplicacion, t2.sec_borrado
		
		LET viTiempoEnLinea = NVL(viTiempoEnLinea,0);
			
		IF ( TRIM(NVL(vcPeriodicidad,'')) <> '' ) THEN
			IF ( TRIM(vcPeriodicidad) = 'M' ) THEN
				LET vdFecha1 = DATE(MONTH(pdFechaResp) || '/01/' || YEAR(pdFechaResp));
				LET vdFecha1 = DATE(vdFecha1 -(viTiempoEnLinea+1) UNITS MONTH);
				LET vdFecha2 = DATE(vdFecha1 + 1 UNITS MONTH - 1 UNITS DAY);
			ELIF ( TRIM(vcPeriodicidad) = 'D' ) THEN
				LET vdFecha2 = DATE(vdFecha2 - (viTiempoEnLinea+1) UNITS MONTH);
				LET vdFecha1 = vdFecha2;
			END IF;
		END IF;
		
		--Asigna formato de fechas al nombre del archivo
		IF ( NVL(vcPeriodicidad,'') = 'M') THEN
			LET vcNombreArchivo = TRIM(vcNombreArchivo) || '_' || YEAR(vdFecha2) || LPAD(MONTH(vdFecha2),2,'0');
		ELIF ( NVL(vcPeriodicidad,'') = 'D') THEN
			LET vcNombreArchivo = TRIM(vcNombreArchivo) || '_' || YEAR(vdFecha2) || LPAD(MONTH(vdFecha2),2,'0') || LPAD(DAY(vdFecha2),2,'0');
		END IF;
		
		
		--SE ELIMINAN LOS ARCHIVOS DE RESPALDOS DEL SERVER
		LET vcSql = TRIM(vcRutaBase) || "borraArchivo.sh " || TRIM(vcRuta) || TRIM(vcNombreArchivo);
		SYSTEM vcSql;		
		
	END FOREACH;	
	RETURN vcCodRet, vcDescRet;
	END;
END PROCEDURE;
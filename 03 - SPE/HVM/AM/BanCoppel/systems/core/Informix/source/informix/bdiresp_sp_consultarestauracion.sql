CREATE PROCEDURE "informix".sp_consultarestauracion(piIdSolicitud INT)
	RETURNING CHAR(5) AS Retorno, CHAR(100) AS DescError, 
	CHAR(80) AS usuario_solicitud, INT AS cve_aplicacion, INT AS tiempo_solicitado, DATE AS fecha_inicio, DATE AS fecha_fin, CHAR(1) AS status, CHAR(1) AS on_line;
		
	/*
	*****************************************************************************************************
	-- DESCRIPCION:  Consulta una restauración en particular --------------------------------------------
	-- AUTOR : Walber Castro ----------------------------------------------------------------------------
	-- FECHA : 04/10/2012  ------------------------------------------------------------------------------
	-- BD: bdiresp  -------------------------------------------------------------------------------------	
	-----------------------------------------------------------------------------------------------------
	*****************************************************************************************************
	*/
	
	DEFINE viCodigo			INT;
	DEFINE vcCodRet			CHAR(5);	
	DEFINE vcDescRet		CHAR(100);	
	DEFINE vcUsuario		CHAR(80);
	DEFINE viCveAplicacion	INT;
	DEFINE viTiempo			INT;
	DEFINE vdFechaInicio	DATE;
	DEFINE vdFechaFin		DATE;
	DEFINE vcStatus			CHAR(1);
	DEFINE vcOnline			CHAR(1);
		
	LET viCodigo		= 	0;
	LET vcCodRet		= 	'00000';
	LET vcDescRet		= 	'';	
	LET vcUsuario		= 	'';
	LET viCveAplicacion	= 	0;
	LET viTiempo		= 	0;
	LET vdFechaInicio	= 	'01-01-1900';
	LET vdFechaFin		= 	'01-01-1900';
	LET vcStatus		= 	'';
	LET vcOnline		= 	'';
	
	BEGIN

	ON EXCEPTION SET viCodigo
		IF viCodigo <> 0 THEN
			LET vcCodRet = viCodigo;
		END IF;		
		RETURN NVL(vcCodRet,''), vcDescRet, '', 0, 0, '01-01-1900', '01-01-1900', '', '';
	END EXCEPTION;	

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	IF ( NVL(piIdSolicitud,0) <= 0 ) THEN
		LET vcCodRet = '00001';
		LET vcDescRet = 'ERROR, ID SOLICITUD INVÁLIDO (PARÁMETRO 1)';
		RETURN vcCodRet, vcDescRet, '', 0, 0, '01-01-1900', '01-01-1900', '', '';
	END IF;
	
	SELECT usuario_solicitud, cve_aplicacion, tiempo_solicitado, fecha_inicio::DATE, fecha_fin::DATE, status, on_line
	INTO vcUsuario, viCveAplicacion, viTiempo, vdFechaInicio, vdFechaFin, vcStatus, vcOnline
	FROM "informix".rp_restauraciones
	WHERE id_solicitud = piIdSolicitud;
	
	IF ( DBINFO('sqlca.sqlerrd2') <= 0 ) THEN
		LET vcCodRet = '00002';
		LET vcDescRet = 'ERROR, NO SE ENCONTRÓ INFORMACIÓN';
	END IF;
	
	RETURN vcCodRet, vcDescRet, vcUsuario, viCveAplicacion, viTiempo, vdFechaInicio, vdFechaFin, vcStatus, vcOnline;
	END;
END PROCEDURE;
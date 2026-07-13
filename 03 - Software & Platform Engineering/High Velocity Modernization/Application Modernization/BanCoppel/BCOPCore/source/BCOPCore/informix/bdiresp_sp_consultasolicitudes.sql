CREATE PROCEDURE "informix".sp_consultasolicitudes(piDesde INT, piCuantos INT)
	RETURNING CHAR(5) AS Retorno, CHAR(100) AS DescError, INT AS Solicitud, CHAR(80) AS Usuario, CHAR(30) AS Aplicacion;
		
	/*
	*****************************************************************************************************
	-- DESCRIPCION:  Consulta las solicitudes de restauración -------------------------------------------
	-- AUTOR : Walber Castro ----------------------------------------------------------------------------
	-- FECHA : 04/10/2012  ------------------------------------------------------------------------------
	-- BD: bdiresp  -------------------------------------------------------------------------------------	
	-----------------------------------------------------------------------------------------------------
	*****************************************************************************************************
	*/
	
	DEFINE viCodigo			INT;
	DEFINE vcCodRet			CHAR(5);
	DEFINE vcDescRet		CHAR(100);
	DEFINE viIdSolicitud	INT;
	DEFINE vcUsuario		CHAR(80);
	DEFINE vcAplicacion		CHAR(30);
		
	LET viCodigo		=	0;
	LET vcCodRet		=	'00000';
	LET vcDescRet		=	'';
	LET viIdSolicitud 	=	0;
	LET vcUsuario		=	'';
	LET vcAplicacion	=	'';
	
	BEGIN

	ON EXCEPTION SET viCodigo
		IF viCodigo <> 0 THEN
			LET vcCodRet = viCodigo;
		END IF;		
		RETURN NVL(vcCodRet,''), vcDescRet, 0, '', '';
	END EXCEPTION;	

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	FOREACH
		SELECT {+INDEX(bdiresp:rp_restauraciones 110_79)} SKIP piDesde LIMIT piCuantos t1.id_solicitud, t1.usuario_solicitud, t2.nombre_aplicacion
		INTO viIdSolicitud, vcUsuario, vcAplicacion
		FROM "informix".rp_restauraciones t1
		INNER JOIN "informix".rp_aplicaciones t2 ON (t1.cve_aplicacion = t2.cve_aplicacion)
		
		RETURN NVL(vcCodRet,''), '', viIdSolicitud, vcUsuario, vcAplicacion WITH RESUME;	
	END FOREACH
	
	IF dbinfo("sqlca.sqlerrd2") = 0 THEN
		LET vcCodRet= "00002";
		LET vcDescRet = "ERROR, NO SE ENCONTRÓ INFORMACIÓN";
		RETURN vcCodRet, vcDescRet, 0, '', '';
	END IF;
	END;
END PROCEDURE;
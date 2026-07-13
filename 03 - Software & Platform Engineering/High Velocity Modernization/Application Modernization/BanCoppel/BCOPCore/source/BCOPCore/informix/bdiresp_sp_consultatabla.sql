CREATE PROCEDURE "informix".sp_consultatabla(piCveAplicacion INT, pcBD VARCHAR(250), pcTabla VARCHAR(250))
	RETURNING CHAR(5) AS Retorno, CHAR(100) AS ruta, CHAR(50) AS nomArchivo, CHAR(1) AS indResp, CHAR(1) AS indRest, INT AS secRest, INT AS secBorr, CHAR(1) AS activa,
	CHAR(100) AS condicion;
		
	/*
	*****************************************************************************************************
	-- DESCRIPCION:  Consulta las aplicaciones ----------------------------------------------------------
	-- AUTOR : Walber Castro ----------------------------------------------------------------------------
	-- FECHA : 23/10/2012  ------------------------------------------------------------------------------
	-- BD: bdiresp  -------------------------------------------------------------------------------------	
	-----------------------------------------------------------------------------------------------------
	*****************************************************************************************************
	*/
	
	DEFINE viCodigo			INT;
	DEFINE vcCodRet			CHAR(5);	
	DEFINE vcRuta			CHAR(100);
	DEFINE vcDescRet		CHAR(100);
	DEFINE vcNomArchivo		CHAR(50);
	DEFINE vcIndResp		CHAR(1);
	DEFINE vcIndRest		CHAR(1);
	DEFINE viSecRest		INT;
	DEFINE viSecBorr		INT;
	DEFINE vcActiva			CHAR(1);
	DEFINE vcCondicion		CHAR(100);
		
	LET viCodigo		= 	0;
	LET vcCodRet		= 	'00000';
	LET vcRuta			= 	'';
	LET vcNomArchivo	= 	'';
	LET vcDescRet		= 	'';
	LET vcIndResp 		= 	'';
	LET vcIndRest 		= 	'';
	LET viSecRest 		= 	0;
	LET viSecBorr 		= 	0;
	LET vcActiva 		= 	'';
	LET vcCondicion 	= 	'';
	
	BEGIN

	ON EXCEPTION SET viCodigo
		IF viCodigo <> 0 THEN
			LET vcCodRet = viCodigo;
		END IF;		
		RETURN NVL(vcCodRet,''), vcDescRet, '', '', '', 0, 0, '', '';
	END EXCEPTION;	

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	IF ( NVL(piCveAplicacion,0) = 0) THEN
		LET vcCodRet = '00001';
		LET vcDescRet = 'ERROR, CVE APLICACIÓN INVÁLIDA (PARÁMETRO 1)';
		RETURN vcCodRet, vcDescRet, '', '', '', 0, 0, '', '';
	END IF;
	
	IF ( NVL(pcBD,'') = '') THEN
		LET vcCodRet = '00001';
		LET vcDescRet = 'ERROR, BD INVÁLIDA (PARÁMETRO 2)';
		RETURN vcCodRet, vcDescRet, '', '', '', 0, 0, '', '';
	END IF;
	
	IF ( NVL(pcTabla,'') = '') THEN
		LET vcCodRet = '00001';
		LET vcDescRet = 'ERROR, TABLA INVÁLIDA (PARÁMETRO 3)';
		RETURN vcCodRet, vcDescRet, '', '', '', 0, 0, '', '';
	END IF;
	
	SELECT ruta, estructura_nom_archivo, ind_respaldo, ind_restauracion, sec_restauracion, sec_borrado, activa, condicion
	INTO vcRuta, vcNomArchivo , vcIndResp, vcIndRest, viSecRest, viSecBorr, vcActiva, vcCondicion
	FROM "informix".rp_tabla_aplicacion
	WHERE cve_aplicacion = piCveAplicacion AND base_de_datos = pcBD AND tabla = pcTabla;	
		
	IF dbinfo("sqlca.sqlerrd2") = 0 THEN
		LET vcCodRet= "00002";
		LET vcDescRet = "ERROR, NO SE ENCONTRÓ INFORMACIÓN";
		RETURN vcCodRet, vcDescRet, '', '', '', 0, 0, '', '';
	END IF;
	
	RETURN NVL(vcCodRet,''), vcRuta, vcNomArchivo, vcIndResp, vcIndRest, viSecRest, viSecBorr, vcActiva, vcCondicion;
	
	END;
END PROCEDURE;
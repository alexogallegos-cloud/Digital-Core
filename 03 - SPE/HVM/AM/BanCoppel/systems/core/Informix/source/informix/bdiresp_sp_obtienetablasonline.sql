CREATE PROCEDURE "informix".sp_obtienetablasonline(piIdSolicitud INT)
	RETURNING CHAR(5) AS Retorno, CHAR(100) AS DescError, CHAR(30) AS tabla;
		
	/*
	*****************************************************************************************************
	-- DESCRIPCION:  Realiza la restauración de una tabla en especifico on-line -------------------------
	-- AUTOR : Walber Castro ----------------------------------------------------------------------------
	-- FECHA : 05/11/2012  ------------------------------------------------------------------------------
	-- BD: bdiresp  -------------------------------------------------------------------------------------	
	-----------------------------------------------------------------------------------------------------
	*****************************************************************************************************
	*/
	
	DEFINE viCodigo		INT;
	DEFINE viCodigo2	INT;
	DEFINE vcCodRet		CHAR(5);	
	DEFINE vcDescRet	CHAR(100);
	DEFINE vcDescRet2	CHAR(100);
	DEFINE vcTabla		CHAR(30);
	DEFINE viCveApli	INT;
	DEFINE viSecRest	INT;	
	
	LET viCodigo 	=	0;
	LET viCodigo2	=	0;
	LET vcCodRet	=	'00000';	
	LET vcDescRet	=	'';
	LET vcDescRet2	=	'';
	LET vcTabla		=	'';
	LET viCveApli	=	0;
	LET viSecRest	=	0;	
	
--SET DEBUG FILE TO "/tmp/moises/sp_obtienetablasonline.out";
--TRACE ON;

	BEGIN

	ON EXCEPTION SET viCodigo
		IF viCodigo <> 0 THEN
			LET vcCodRet = viCodigo;
		END IF;		
		RETURN NVL(vcCodRet,''),NVL(vcDescRet,''), vcTabla;
	END EXCEPTION;
	
	IF ( NVL(piIdSolicitud,0) = 0 ) THEN
		LET vcCodRet = '00001';
		LET vcDescRet = 'ERROR, ID SOLICITUD INVÁLIDA (PARÁMETRO 1)';
		RETURN vcCodRet, vcDescRet, '';
	END IF;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	FOREACH
		SELECT DISTINCT t1.tabla, t2.cve_aplicacion, t1.sec_restauracion
		INTO vcTabla, viCveApli, viSecRest
		FROM "informix".rp_tablas_restauradas t1
		INNER JOIN "informix".rp_tabla_aplicacion t2 ON (t1.tabla=t2.tabla)
		WHERE t1.estatus = '0' AND t1.id_solicitud = piIdSolicitud AND t1.fecha_restauracion = '1900-01-01 00:00:00'	
		ORDER BY t2.cve_aplicacion, t1.sec_restauracion
		
		RETURN vcCodRet, vcDescRet, vcTabla WITH RESUME;		
	END FOREACH;
	
	IF dbinfo("sqlca.sqlerrd2") = 0 THEN
		LET vcCodRet= "00002";
		LET vcDescRet = "ERROR, NO SE ENCONTRÓ INFORMACIÓN";
		RETURN vcCodRet, vcDescRet, '';
	END IF;
	END;
END PROCEDURE;
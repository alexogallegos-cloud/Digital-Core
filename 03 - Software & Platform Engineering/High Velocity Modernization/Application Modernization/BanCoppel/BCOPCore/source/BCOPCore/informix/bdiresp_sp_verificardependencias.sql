CREATE PROCEDURE "informix".sp_verificardependencias(piCveAplicacion INT)
	RETURNING CHAR(5) AS Retorno, CHAR(100) AS DescError, CHAR(30) AS tabla;
		
	/*
	*****************************************************************************************************
	-- DESCRIPCION:  Verifica si las aplicaciones con dependencia tienen el mismo tiempo en linea -------
	-- Si no es asi verifica que los padres tengan estatus 1 (restaurados) ------------------------------
	-- AUTOR : Roberto Castro ---------------------------------------------------------------------------
	-- FECHA : 19/07/2013  ------------------------------------------------------------------------------
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
	DEFINE viOnLine		INT;	
	DEFINE viOnLineTmp	INT;
	DEFINE viCount		INT;
	DEFINE viDependencia	INT;
	DEFINE viDependenciaTmp	INT;
	DEFINE viEstatus	INT;
	DEFINE viCveAplicacion2 INT;
	
	LET viCodigo 	=	0;
	LET viCodigo2	=	0;
	LET vcCodRet	=	'00000';	
	LET vcDescRet	=	'';
	LET vcDescRet2	=	'';
	LET vcTabla		=	'';
	LET viCveApli	=	0;
	LET viSecRest	=	0;
	LET viOnLine	= 	0;
	LET viOnLineTmp	= 	0;
	LET viCount		= 	0;
	LET viDependencia	=	0;
	LET viDependenciaTmp	=	0;
	LET viEstatus	=	0;
	LET viCveAplicacion2	=	0;

	--SET DEBUG FILE TO "/home/sysifx/roberto/sp_verificardependencias.out";
	--TRACE ON;

	BEGIN

	ON EXCEPTION SET viCodigo
		IF viCodigo <> 0 THEN
			LET vcCodRet = viCodigo;
		END IF;		
		RETURN NVL(vcCodRet,''),NVL(vcDescRet,''), vcTabla;
	END EXCEPTION;
	
	IF ( NVL(piCveAplicacion ,0) = 0 ) THEN
		LET vcCodRet = '00001';
		LET vcDescRet = 'ERROR, CLAVE DE APLICACIÓN INVÁLIDA (PARÁMETRO 1)';
		RETURN vcCodRet, vcDescRet, '';
	END IF;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	LET viCveAplicacion2=piCveAplicacion;
	
	SELECT cve_dependencia, tiempo_en_linea INTO viDependencia, viOnLine FROM "informix".rp_aplicaciones WHERE cve_aplicacion=viCveAplicacion2;
	
	WHILE (viDependencia <> 0)
	
		SELECT cve_dependencia, tiempo_en_linea
		INTO viDependencia, viOnLineTmp
		FROM "informix".rp_aplicaciones
		WHERE cve_aplicacion=viDependencia;
		
		IF (viOnLineTmp <> viOnLine) THEN
			SELECT t1.estatus 
			INTO viEstatus 
			FROM "informix".rp_tablas_restauradas t1
			INNER JOIN "informix".rp_tabla_aplicacion t2 ON (t1.tabla=t2.tabla)
			INNER JOIN "informix".rp_aplicaciones t3 ON (t2.cve_aplicacion=t3.cve_aplicacion)
			WHERE t2.cve_aplicacion=viDependencia AND t1.estatus='1';
			
			IF (NVL (viEstatus,1)=1) THEN
				SELECT cve_dependencia INTO viDependenciaTmp FROM rp_aplicaciones WHERE cve_aplicacion=viCveAplicacion2;
				
				IF(viDependenciaTmp=0) THEN
					SELECT t1.estatus 
					INTO viEstatus 
					FROM "informix".rp_tablas_restauradas t1
					INNER JOIN "informix".rp_tabla_aplicacion t2 ON (t1.tabla=t2.tabla)
					INNER JOIN "informix".rp_aplicaciones t3 ON (t2.cve_aplicacion=t3.cve_aplicacion)
					WHERE t2.cve_aplicacion=viDependenciaTmp;
					IF ( NVL (viEstatus,0)<>1) THEN
						LET vcCodRet= "00003";
						LET vcDescRet = "ERROR, LOS TIEMPOS EN LINEA SON DIFERENTES";
						RETURN vcCodRet, vcDescRet, '';
					END IF;
					EXIT WHILE;
				END IF;
				
				LET viCveAplicacion2=viDependenciaTmp;
				
				SELECT t1.estatus 
				INTO viEstatus 
				FROM "informix".rp_tablas_restauradas t1
				INNER JOIN "informix".rp_tabla_aplicacion t2 ON (t1.tabla=t2.tabla)
				INNER JOIN "informix".rp_aplicaciones t3 ON (t2.cve_aplicacion=t3.cve_aplicacion)
				WHERE t2.cve_aplicacion=viDependenciaTmp AND t1.estatus='1';
				IF ( NVL (viEstatus,0)<>1) THEN
					LET vcCodRet= "00003";
					LET vcDescRet = "ERROR, LOS TIEMPOS EN LINEA SON DIFERENTES";
					RETURN vcCodRet, vcDescRet, '';
				END IF;
			END IF;
		END IF;
	
	END WHILE;
		
	/*IF dbinfo("sqlca.sqlerrd2") = 0 THEN
		LET vcCodRet= "00002";
		LET vcDescRet = "ERROR, NO SE ENCONTRÓ INFORMACIÓN";
		RETURN vcCodRet, vcDescRet, '';
	END IF;*/
	
	RETURN vcCodRet, vcDescRet, vcTabla WITH RESUME;	
	END;
END PROCEDURE;
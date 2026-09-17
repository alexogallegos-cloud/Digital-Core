CREATE PROCEDURE "informix".sp_guardartabla(piCveAplicacion INT, pcBD CHAR(50), pcTabla CHAR(50), pcRuta CHAR(100), pcNomArchivo CHAR(100), pcRespalda CHAR(1), 
pcRestaura CHAR(1), piSecRestauracion INT, piSecBorrado INT, pcActivar CHAR(1), pcCondicion CHAR(100), pcUser CHAR(10))
	RETURNING CHAR(5) AS Retorno, CHAR(100) as DescError;
		
	/*
	*****************************************************************************************************
	-- DESCRIPCION:  Guarda las tablas dadas de alta ----------------------------------------------------
	-- AUTOR : Walber Castro ----------------------------------------------------------------------------
	-- FECHA : 04/10/2012  ------------------------------------------------------------------------------
	-- BD: bdiresp  -------------------------------------------------------------------------------------	
	-----------------------------------------------------------------------------------------------------
	*****************************************************************************************************
	-- MODIFICACIÓN: Validación sobre existencia de tabla para otra aplicación.
	-- Se eliminaron las referencias a la BD bdiresp de los sp's propios de esta.
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
	DEFINE vcSecuencia	CHAR(1);
	DEFINE viRetRuta 	INT;
	DEFINE vcNuevo		CHAR(1);
	DEFINE vcSql		CHAR(250);
	DEFINE viTotRegCons	INT;
	DEFINE vcCondicion	CHAR(100);
		
	LET viCodigo	= 	0;
	LET viCodigo2	=	0;
	LET vcCodRet	= 	'00000';
	LET vcCodRet2	= 	'00000';
	LET vcDescRet	= 	'';
	LET vcSecuencia = 	'';
	LET viRetRuta 	= 	0;
	LET vcNuevo		=	'';
	LET vcDescRet2	=	'';
	LET vcSql		=	'';
	LET viTotRegCons=	0;
	LET vcCondicion	=	'';
	
	BEGIN

	ON EXCEPTION SET viCodigo
		IF viCodigo <> 0 THEN
			LET vcCodRet = viCodigo;
		END IF;
		IF ( TRIM(NVL(vcNuevo,'')) = '1' ) THEN
			--LOG DE ERRORES
			EXECUTE PROCEDURE sp_insertaLog(2000, 'REGISTRO DE TABLA', '', "Informix", 3, 'ERROR ' || viCodigo || ' AL EJECUTAR EL SP sp_guardarTabla(' || NVL(piCveAplicacion,'NULL') || ',' || NVL(pcBD,'NULL') || ',' || NVL(pcTabla,'NULL') || ',' || NVL(pcRuta,'NULL') || ',' || NVL(pcNomArchivo,'NULL') || ',' || NVL(pcRespalda,'NULL') || ',' || NVL(pcRestaura,'NULL') || ',' || NVL(piSecRestauracion,'NULL') || ',' || NVL(piSecBorrado,'NULL') || ',' || NVL(pcActivar,'NULL') || ',' || NVL(pcCondicion,'NULL') || ',' || NVL(pcUser,'NULL') ) INTO viCodigo2, vcDescRet2;
		ELIF ( TRIM(NVL(vcNuevo,'')) = '0' ) THEN
			--LOG DE ERRORES
			EXECUTE PROCEDURE sp_insertaLog(2001, 'EDICIÓN DE TABLA', '', "Informix", 3, 'ERROR ' || viCodigo || ' AL EJECUTAR EL SP sp_guardarTabla(' || NVL(piCveAplicacion,'NULL') || ',' || NVL(pcBD,'NULL') || ',' || NVL(pcTabla,'NULL') || ',' || NVL(pcRuta,'NULL') || ',' || NVL(pcNomArchivo,'NULL') || ',' || NVL(pcRespalda,'NULL') || ',' || NVL(pcRestaura,'NULL') || ',' || NVL(piSecRestauracion,'NULL') || ',' || NVL(piSecBorrado,'NULL') || ',' || NVL(pcActivar,'NULL') || ',' || NVL(pcCondicion,'NULL') || ',' || NVL(pcUser,'NULL') ) INTO viCodigo2, vcDescRet2;
		END IF;
		RETURN NVL(vcCodRet,''),NVL(vcDescRet,'');
	END EXCEPTION;	

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	IF ( NVL(piCveAplicacion,0) <= 0 ) THEN
		LET vcCodRet = '00001';
		LET vcDescRet = 'ERROR, CVE APLICACIÓN INVÁLIDA (PARÁMETRO 1)';
		RETURN vcCodRet, vcDescRet;
	END IF;
	
	IF ( NOT EXISTS(SELECT cve_aplicacion FROM "informix".rp_aplicaciones WHERE cve_aplicacion = piCveAplicacion)) THEN
		LET vcCodRet = '00001';
		LET vcDescRet = 'ERROR, LA CVE APLICACIÓN NO EXISTE (PARÁMETRO 1)';
		RETURN vcCodRet, vcDescRet;
	END IF;
	
	IF ( TRIM(NVL(pcBD,'')) = '') THEN
		LET vcCodRet = '00001';
		LET vcDescRet = 'ERROR, BD INVÁLIDA (PARÁMETRO 2)';
		RETURN vcCodRet, vcDescRet;
	END IF;
	
	IF ( NOT EXISTS( SELECT name FROM sysmaster:sysdatabases WHERE name = TRIM(NVL(pcBD,'')) ) ) THEN
		LET vcCodRet = '00001';
		LET vcDescRet = 'ERROR, LA BD NO EXISTE (PARÁMETRO 2)';
		RETURN vcCodRet, vcDescRet;
	END IF;
	
	IF ( TRIM(NVL(pcTabla,'')) = '') THEN
		LET vcCodRet = '00001';
		LET vcDescRet = 'ERROR, TABLA INVÁLIDA (PARÁMETRO 3)';
		RETURN vcCodRet, vcDescRet;
	END IF;
	
	LET vcSql = "SELECT COUNT(tabname) FROM " || TRIM(NVL(pcBD,'')) || ":systables WHERE tabname='" || TRIM(NVL(pcTabla,'')) || "'";
	PREPARE xsql FROM vcSql;
	DECLARE xcur CURSOR FOR xsql;
	OPEN xcur;		
	WHILE 1 = 1
		FETCH xcur INTO viTotRegCons;
		IF (SQLCODE = 100) THEN
			EXIT WHILE;
		END IF;
	END WHILE;
	CLOSE xcur;
	FREE xcur;
	FREE xsql;
	IF ( NVL(viTotRegCons,0) <= 0 ) THEN
		LET vcCodRet = '00001';
		LET vcDescRet = 'ERROR, LA TABLA NO EXISTE (PARÁMETRO 3)';
		RETURN vcCodRet, vcDescRet;
	END IF;
	
	IF ( TRIM(NVL(pcRuta,'')) = '' ) THEN
		LET vcCodRet = '00001';
		LET vcDescRet = 'ERROR, RUTA INVÁLIDA (PARÁMETRO 4)';
		RETURN vcCodRet, vcDescRet;
	END IF;
	
	IF ( SUBSTR(TRIM(NVL(pcRuta,'')),LENGTH(TRIM(NVL(pcRuta,''))),1) <> '/' ) THEN
		LET pcRuta = TRIM(NVL(pcRuta,'')) || '/';
	END IF;
	
	EXECUTE PROCEDURE sp_validaCadena(pcRuta,"1","1","/") INTO vcCodRet2;
	IF ( TRIM(NVL(vcCodRet2,'')) != '00000' ) THEN
		LET vcCodRet = '00001';
		LET vcDescRet = 'ERROR, RUTA INVÁLIDA (PARÁMETRO 4)';
		RETURN vcCodRet, vcDescRet;
	END IF;
	
	EXECUTE PROCEDURE sp_validaRuta(pcRuta) INTO viRetRuta;
	IF ( viRetRuta <> 0 ) THEN
		LET vcCodRet = '00001';
		LET vcDescRet = 'ERROR, RUTA INVÁLIDA (PARÁMETRO 4)';
		RETURN vcCodRet, vcDescRet;
	END IF;
	
	IF ( TRIM(NVL(pcNomArchivo,'')) = '' ) THEN
		LET vcCodRet = '00001';
		LET vcDescRet = 'ERROR, NOMBRE ARCHIVO INVÁLIDO (PARÁMETRO 5)';
		RETURN vcCodRet, vcDescRet;
	END IF;
	
	IF ( TRIM(NVL(pcRespalda,'')) != '0' AND TRIM(NVL(pcRespalda,'')) != '1' ) THEN
		LET vcCodRet = '00001';
		LET vcDescRet = 'ERROR, BANDERA SE RESPALDA INVÁLIDA (PARÁMETRO 6)';
		RETURN vcCodRet, vcDescRet;
	END IF;
	
	IF ( TRIM(NVL(pcRestaura,'')) != '0' AND TRIM(NVL(pcRestaura,'')) != '1' ) THEN
		LET vcCodRet = '00001';
		LET vcDescRet = 'ERROR, BANDERA SE RESTAURA INVÁLIDA (PARÁMETRO 7)';
		RETURN vcCodRet, vcDescRet;
	END IF;
	
	IF ( NVL(piSecRestauracion,0) <= 0) THEN
		LET vcCodRet = '00001';
		LET vcDescRet = 'ERROR, SECUENCIA DE RESTAURACIÓN INVÁLIDA (PARÁMETRO 8)';
		RETURN vcCodRet, vcDescRet;
	END IF;
	
	IF ( NVL(piSecBorrado,0) <= 0) THEN
		LET vcCodRet = '00001';
		LET vcDescRet = 'ERROR, SECUENCIA DE BORRADO INVÁLIDA (PARÁMETRO 9)';
		RETURN vcCodRet, vcDescRet;
	END IF;
	
	EXECUTE PROCEDURE sp_verificaSecuenciaRestBorrado(piCveAplicacion, pcTabla, piSecRestauracion, piSecBorrado)
	INTO vcCodRet2, vcDescRet, vcSecuencia;
	
	IF ( TRIM(NVL(vcCodRet2,'')) != '00000' ) THEN
		LET vcCodRet = vcCodRet2;
		RETURN vcCodRet, vcDescRet;
	ELSE
		IF (TRIM(NVL(vcSecuencia,'0')) = '1' ) THEN
			LET vcCodRet = '00002';
			LET vcDescRet = 'ERROR, LAS SECUENCIAS DE RESTAURACIÓN Y BORRADO YA EXISTEN EN LA APLICACIÓN';
			RETURN vcCodRet, vcDescRet;
		END IF;
	END IF;
	
	IF ( TRIM(NVL(pcActivar,'')) != '0' AND TRIM(NVL(pcActivar,'')) != '1' ) THEN
		LET vcCodRet = '00001';
		LET vcDescRet = 'ERROR, BANDERA DE ACTIVA INVÁLIDA (PARÁMETRO 10)';
		RETURN vcCodRet, vcDescRet;
	END IF;	
	
	EXECUTE PROCEDURE sp_validaCadena(pcCondicion,"1","1","< >:='/¿?_") INTO vcCodRet2;
	IF ( TRIM(NVL(vcCodRet2,'')) != '00000' ) THEN
		LET vcCodRet = '00001';
		LET vcDescRet = 'ERROR, CONDICIÓN INVÁLIDA (PARÁMETRO 11)';
		RETURN vcCodRet, vcDescRet;
	END IF;
	
	LET vcCondicion = REPLACE(pcCondicion, '¿', "'" || TODAY || "'::DATE");
	LET vcCondicion = REPLACE(vcCondicion, '?', "'" || TODAY || "'::DATE");	
	EXECUTE PROCEDURE sp_validaQuery(pcBD, pcTabla, vcCondicion) INTO vcCodRet2, vcDescRet2;
	IF ( TRIM(NVL(vcCodRet2,'')) != '00000' ) THEN
		LET vcCodRet = '00001';
		LET vcDescRet = 'ERROR, CONDICIÓN INVÁLIDA (PARÁMETRO 11)';
		RETURN vcCodRet, vcDescRet;
	END IF;
	
	IF ( TRIM(NVL(pcUser,'')) = '' ) THEN
		LET pcUser = 'Informix';
	END IF;
		-- SI EXISTE LA TABLA PARA LA APLICACION RECIBIDA REALIZA UN UPDATE
		IF (EXISTS(SELECT {+INDEX(bdiresp:rp_tabla_aplicacion 108_45)} tabla FROM "informix".rp_tabla_aplicacion WHERE TRIM(tabla) = TRIM(NVL(pcTabla,'')) and cve_aplicacion = piCveAplicacion))
		THEN
		LET vcNuevo = '0';
		UPDATE {+INDEX(bdiresp:rp_tabla_aplicacion 108_45)} "informix".rp_tabla_aplicacion SET cve_aplicacion = piCveAplicacion, base_de_datos = TRIM(NVL(pcBD,'')), ruta = TRIM(NVL(pcRuta,'')), estructura_nom_archivo = TRIM(NVL(pcNomArchivo,'')), ind_respaldo = TRIM(NVL(pcRespalda,'')),
		ind_restauracion = TRIM(NVL(pcRestaura,'')), sec_restauracion = piSecRestauracion, sec_borrado = piSecBorrado, activa = TRIM(NVL(pcActivar,'')), condicion = TRIM(NVL(pcCondicion,'')), user_insert = TRIM(NVL(pcUser,'')), fecha_insert = CURRENT YEAR TO SECOND
		WHERE TRIM(tabla) = TRIM(NVL(pcTabla,''));
		-- SI EXISTE LA TABLA PARA CUALQUIER OTRA APLICACIÓN REGRESA ERROR DE QUE YA EXISTE DICHA TABLA
	ELIF (EXISTS(SELECT {+INDEX(bdiresp:rp_tabla_aplicacion 108_45)} tabla FROM "informix".rp_tabla_aplicacion WHERE TRIM(tabla) = TRIM(NVL(pcTabla,'')))) THEN
		LET vcCodRet = '00002';
		LET vcDescRet = 'ERROR, LA TABLA YA EXISTE PARA OTRA APLICACIÓN.';
		RETURN vcCodRet, vcDescRet;
		ELSE
		-- SI NO EXISTE TABLA PARA ESA APLICACION REALIZA UN INSERT
		LET vcNuevo = '1';
		INSERT INTO "informix".rp_tabla_aplicacion(cve_aplicacion, base_de_datos, tabla, ruta, estructura_nom_archivo, ind_respaldo,
		ind_restauracion, sec_restauracion, sec_borrado, activa, condicion, user_insert, fecha_insert, realizo_respaldo)
		VALUES (piCveAplicacion, TRIM(NVL(pcBD,'')), TRIM(NVL(pcTabla,'')), TRIM(NVL(pcRuta,'')), TRIM(NVL(pcNomArchivo,'')), TRIM(NVL(pcRespalda,'')), TRIM(NVL(pcRestaura,'')), piSecRestauracion, piSecBorrado, TRIM(NVL(pcActivar,'')), TRIM(NVL(pcCondicion,'')), TRIM(NVL(pcUser,'')), CURRENT YEAR TO SECOND, NULL);
	END IF;
	
	RETURN vcCodRet, vcDescRet;
	END;
END PROCEDURE;
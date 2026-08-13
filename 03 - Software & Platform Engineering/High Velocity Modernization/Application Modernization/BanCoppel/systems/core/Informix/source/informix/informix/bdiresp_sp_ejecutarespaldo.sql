CREATE PROCEDURE "informix".sp_ejecutarespaldo(pcFechaCaracter CHAR(10))
	RETURNING CHAR(5) AS Retorno, CHAR(100) as DescError;

	/*
	*****************************************************************************************************
	-- DESCRIPCION:  corre proceso de respaldo de aplicaciones ------------------------------------------
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
	-- MODIFICACIÓN: Se cambió la ejecución de la depuración, ahora se hace a través del sp_borraregistros
	-- AUTOR: Moisés Soriano
	-- FECHA : 17/04/2013
	-- BD: bdiresp
	*****************************************************************************************************
	-- MODIFICACION: Se cambio el order by de la consulta para el proceso de borrado, -------------------
	-- Se Cambio el nombre del Archivo que se crea en el servidor cuando la periodicidad es Diaria.------
	-- Se Agrego Validacion para que, en caso de ocurrir un error en el sp_borraregistros lo inserte en -
	-- la tabla rp_errores y nos informe que el respaldo fue exitoso pero ocurrio error en el borrado. --
	-- AUTOR : Roberto Castro ---------------------------------------------------------------------------
	-- FECHA : 17/07/2013  ------------------------------------------------------------------------------
	-- BD: bdiresp  -------------------------------------------------------------------------------------
	-----------------------------------------------------------------------------------------------------
	*****************************************************************************************************
	*/

	DEFINE viCodigo			INT;
	DEFINE vcCodRet			CHAR(5);
	DEFINE vcCodRet2		CHAR(5);
	DEFINE vcDescRet		CHAR(100);
	DEFINE viCveAplicacion 	INT;
	DEFINE vcSql 			LVARCHAR(500);
	DEFINE vcBaseDatos 		CHAR(20);
	DEFINE vcTabla 			CHAR(30);
	DEFINE vcRuta 			CHAR(100);
	DEFINE vcNombreArchivo	CHAR(50);
	DEFINE vcCondicion		CHAR(100);
	DEFINE vcPeriodicidad	CHAR(1);
	DEFINE vdFecha1			DATE;
	DEFINE vdFecha2			DATE;
	DEFINE viTiempoEnLinea	INT;
	DEFINE viDifRegistros	INT;
	DEFINE viCodigo2		INT;
	DEFINE vcDescRet2		CHAR(100);
	DEFINE viTotRegResp		INT;
	DEFINE viTotRegCons		INT;
	DEFINE viTotRegBorr		INT;
	DEFINE vcEnTrans 		CHAR(1);
	DEFINE vcRutaBase		CHAR(50);
	DEFINE viCont			INT;
	DEFINE vcError			CHAR(1);
	DEFINE vcEncontro		CHAR(1);
	DEFINE vcCodRet3		CHAR(5);
	DEFINE cIndResp			CHAR(1);
	DEFINE cIndRest			CHAR(1);
	DEFINE cSecRest			INTEGER;
	DEFINE cSecBorrado		INTEGER;
	DEFINE cActiva			CHAR(1);
	

	DEFINE pdFechaResp		DATE;
	LET pdFechaResp			=TODAY;

	LET viCodigo		= 	0;
	LET vcCodRet		= 	'00000';
	LET vcDescRet		= 	'';
	LET viCveAplicacion = 	0;
	LET vcSql			= 	'';
	LET vcBaseDatos 	= 	'';
	LET vcTabla 		= 	'';
	LET vcRuta 			= 	'';
	LET vcNombreArchivo = 	'';
	LET vcCondicion 	= 	'';
	LET vcPeriodicidad	= 	'';
	LET vdFecha1		= 	'01-01-1900';
	LET vdFecha2		= 	'01-01-1900';
	LET viTiempoEnLinea	= 	0;
	LET viDifRegistros	= 	0;
	LET viCodigo2		= 	0;
	LET vcDescRet2		= 	'';
	LET viTotRegResp	= 	0;
	LET viTotRegCons	= 	0;
	LET viTotRegBorr	= 	0;
	LET vcEnTrans		= 	'0';
	LET vcRutaBase		=	'';
	LET vcCodRet2		=	'00000';
	LET viCont			=	0;
	LET vcError			=	'';
	LET vcEncontro		=	'';
	LET vcCodRet3		=	'';

--SET DEBUG FILE TO "/informix/ArmandoM/sp_ejecutarespaldo.out";
--TRACE ON;

	BEGIN

	ON EXCEPTION SET viCodigo
		IF viCodigo <> 0 THEN
			LET vcCodRet = viCodigo;
		END IF;
		IF( vcEnTrans = '1' OR viCodigo=-535) THEN
			ROLLBACK WORK;
		END IF;
		--SE HACE ROLLBACK MANUAL DEL BORRADO DE ARCHIVOS DEL SERVER
		EXECUTE PROCEDURE sp_deshacer_respaldarAplicaciones(pdFechaResp) INTO viCodigo2, vcDescRet2;

		--LOG DE EVENTOS
		UPDATE "informix".rp_tabla_aplicacion SET realizo_respaldo = '0' WHERE cve_aplicacion = viCveAplicacion;
		EXECUTE PROCEDURE sp_insertaLog(3001, 'FALLÓ PROCESO DE RESPALDO ' || NVL(vcNombreArchivo,''), '' , "Informix", 1, '') INTO viCodigo2, vcDescRet2;
		--LOG DE ERRORES
		EXECUTE PROCEDURE sp_insertaLog(3001, 'PROCESO DE RESPALDO', '', "Informix", 3, ('ERROR ' || viCodigo || ' AL EJECUTAR EL SP sp_ejecutaRespaldo(' || NVL(pdFechaResp,'NULL') || ')')) INTO viCodigo2, vcDescRet2;
		--BITÁCORA DE PROCESOS
		EXECUTE PROCEDURE sp_insertaLog(3001, 'ERROR, SE DETECTÓ UN PROBLEMA EN PROCESO DE RESPALDO', TRIM(vcNombreArchivo), "Informix", 2, '') INTO viCodigo2, vcDescRet2;
		EXECUTE PROCEDURE sp_insertaLog(3002, 'FINALIZA PROCESO DE RESPALDO', '' , "Informix", 2, '') INTO viCodigo2, vcDescRet2;

		RETURN NVL(vcCodRet,''),NVL(vcDescRet,'');
	END EXCEPTION;

	IF ( pcFechaCaracter IS NULL ) THEN
		LET vcCodRet = '00001';
		LET vcDescRet = 'ERROR, FECHA INVÁLIDA (PARÁMETRO 1)';
		RETURN vcCodRet, vcDescRet;
	END IF;

	EXECUTE PROCEDURE sp_validaFecha(pcFechaCaracter) INTO vcCodRet2;
	IF ( TRIM(NVL(vcCodRet2,'')) <> '00000' ) THEN
		LET vcCodRet = '00001';
		LET vcDescRet = 'ERROR, FECHA INVÁLIDA (PARÁMETRO 1)';
		RETURN vcCodRet, vcDescRet;
	END IF;

	LET pdFechaResp = pcFechaCaracter::DATE;
	LET vdFecha1 = pdFechaResp;
	LET vdFecha2 = pdFechaResp;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;

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

	--SE REGISTRA EN EL LOG DE PROCESOS EL INICIO DEL PROCESO
	EXECUTE PROCEDURE sp_insertaLog(3000, 'INICIA PROCESO DE RESPALDO', TRIM(vcNombreArchivo) , "Informix", 2, '') INTO viCodigo2, vcDescRet2;
	BEGIN WORK;
	LET vcEnTrans = '1';

	FOREACH WITH HOLD
		SELECT {+INDEX(bdiresp:rp_aplicaciones idx_rpappperiodicidad)} {+AVOID_FULL(bdiresp:rp_tabla_aplicacion)} t2.cve_aplicacion, t2.base_de_datos, t2.tabla, t2.ruta, t2.estructura_nom_archivo, t2.condicion, t1.periodicidad, t1.tiempo_en_linea
		INTO viCveAplicacion, vcBaseDatos, vcTabla, vcRuta, vcNombreArchivo, vcCondicion, vcPeriodicidad, viTiempoEnLinea
		FROM "informix".rp_aplicaciones t1
		INNER JOIN "informix".rp_tabla_aplicacion t2 ON (t1.cve_aplicacion = t2.cve_aplicacion)
		WHERE t1.activa = '1' AND (( t1.periodicidad = 'M' AND t1.dia_respaldo = DAY(pdFechaResp) ) OR ( t1.periodicidad = 'D' ))
		AND t2.activa = '1' AND t2.ind_respaldo = '1' AND t2.realizo_respaldo IS NULL OR t2.realizo_respaldo = '1'
		ORDER BY t2.sec_borrado, t2.cve_aplicacion
		LET vcEncontro = '1';
		LET viTiempoEnLinea = NVL(viTiempoEnLinea,0);

		IF ( TRIM(NVL(vcPeriodicidad,'')) <> '' ) THEN
			IF ( TRIM(vcPeriodicidad) = 'M' ) THEN
			-- Se le asigna a vdFecha1 el primer dia de la fecha de respaldo
				LET vdFecha1 = DATE(MONTH(pdFechaResp) || '/01/' || YEAR(pdFechaResp));
			-- Se le resta a vdFecha1 en meses el tiempo en linea + 1 mes
				LET vdFecha1 = DATE(vdFecha1 -(viTiempoEnLinea+1) UNITS MONTH);
			-- A la vdFecha1 se le suma un mes y le resta un dia en fecha
				LET vdFecha2 = DATE(vdFecha1 + 1 UNITS MONTH - 1 UNITS DAY);
			-- Asigna nombre de archivo c/ formato mensual
				LET vcNombreArchivo = TRIM(vcNombreArchivo) || '_' || YEAR(vdFecha2) || LPAD(MONTH(vdFecha2),2,'0');
			ELIF ( TRIM(vcPeriodicidad) = 'D' ) THEN
			-- Se le resta a vdFecha2 en meses el tiempo en linea
				LET vdFecha2 = DATE(pdFechaResp - (viTiempoEnLinea+1) UNITS MONTH);
				LET vdFecha1 = vdFecha2;
			-- Asigna nombre de archivo c/formato diario
				LET vcNombreArchivo = TRIM(vcNombreArchivo) || '_' || YEAR(vdFecha2) || LPAD(MONTH(vdFecha2),2,'0') || LPAD(DAY(vdFecha2),2,'0');
			END IF;
		END IF;

		--Aqui es donde se le asigna el nombre con la fecha al archivo
		--LET vcNombreArchivo = TRIM(vcNombreArchivo) || '_' || YEAR(vdFecha2) || LPAD(MONTH(vdFecha2),2,'0') || LPAD(DAY(vdFecha2),2,'0');

		IF (EXISTS(SELECT {+AVOID_FULL(bdiresp:rp_respaldos)} nombre_archivo FROM "informix".rp_respaldos WHERE TRIM(nombre_archivo) = TRIM(vcNombreArchivo))) THEN
			--LET vcError = '1';
			--LOG DE ERRORES
			EXECUTE PROCEDURE sp_insertaLog(3001, 'PROCESO DE RESPALDO','' , "Informix", 3, 'YA EXISTE RESPALDO DEL ARCHIVO ' || TRIM(NVL(vcNombreArchivo,''))) INTO viCodigo2, vcDescRet2;
			--BITÁCORA DE PROCESOS
			EXECUTE PROCEDURE sp_insertaLog(3001, 'ERROR, SE DETECTÓ UN PROBLEMA EN PROCESO DE RESPALDO', TRIM(vcNombreArchivo) , "Informix", 2, '') INTO viCodigo2, vcDescRet2;
			CONTINUE FOREACH;
		END IF;

		IF ( TRIM(NVL(vcCondicion,'')) <> '' ) THEN
			LET vcCondicion = REPLACE(vcCondicion, '¿', "'" || vdFecha1 || "'::DATE");
			LET vcCondicion = REPLACE(vcCondicion, '?', "'" || vdFecha2 || "'::DATE");
		ELSE
			LET vcError = '1';
			--LOG DE ERRORES
			EXECUTE PROCEDURE sp_insertaLog(3001, 'PROCESO DE RESPALDO','' , "Informix", 3, 'CONDICIÓN NO VÁLIDA PARA EL ARCHIVO ' || TRIM(NVL(vcNombreArchivo,''))) INTO viCodigo2, vcDescRet2;
			--BITÁCORA DE PROCESOS
			EXECUTE PROCEDURE sp_insertaLog(3001, 'ERROR, SE DETECTÓ UN PROBLEMA EN PROCESO DE RESPALDO', TRIM(vcNombreArchivo) , "Informix", 2, '') INTO viCodigo2, vcDescRet2;
			--CONTINUE FOREACH;
			EXECUTE PROCEDURE sp_deshacer_respaldarAplicaciones(pdFechaResp) INTO viCodigo2, vcDescRet2;
			EXIT FOREACH;
		END IF;
		--VERIFICA SI LA RUTA DE RESPALDOS EXISTE EN EL SERVER, SINO LA CREA
		LET vcSql = TRIM(vcRutaBase) || "verificaRuta.sh " || TRIM(vcRuta);
		SYSTEM vcSql;
		--SE INSERTA REGISTRO DE RESPALDO EN LA TABLA
		INSERT INTO "informix".rp_respaldos(cve_aplicacion, base_de_datos, tabla, ruta, nombre_archivo , fecha_inicio, fecha_final,
		fecha_respaldo, registros_respaldados, registros_query, registros_borrados, condicion, user_insert, fecha_insert)
		VALUES(NVL(viCveAplicacion,0), TRIM(NVL(vcBaseDatos,'')), TRIM(NVL(vcTabla,'')), TRIM(NVL(vcRuta,'')), TRIM(NVL(vcNombreArchivo,'')), vdFecha1, vdFecha2, pdFechaResp, -1, -1, -1, TRIM(NVL(vcCondicion,'')), "Informix", CURRENT YEAR TO SECOND);

		--AQUI VA EL CODIGO PARA GENERAR RESPALDO
		LET vcSql = 'echo "UNLOAD TO ' || TRIM(vcRuta) || TRIM(vcNombreArchivo) ||
                  ' SELECT * FROM ' || TRIM(vcBaseDatos) || ':' || TRIM(vcTabla) ||
                  ' WHERE ' || TRIM(vcCondicion) || '" > ' || TRIM(vcRuta) || 'query.sql';
		SYSTEM vcSql;

		--SE GENERA EL RESPALDO EN EL SERVER
		LET vcSql = "/ifxsif01/bin/dbaccess " || TRIM(vcBaseDatos) || " " || TRIM(vcRuta) || "query.sql ";
		SYSTEM vcSql;

		--SE EJECUTA QUERY CON EL COUNT DE REGISTROS CON LA MISMA CONDICIÓN CON LA QUE SE REALIZÓ EL RESPALDO
		LET vcSql = " SELECT COUNT(*) FROM " || TRIM(vcBaseDatos) || ":" || TRIM(vcTabla) || " WHERE " || TRIM(vcCondicion);

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
		UPDATE {+AVOID_FULL(bdiresp:rp_respaldos)} "informix".rp_respaldos SET registros_query = NVL(viTotRegCons,0) WHERE TRIM(nombre_archivo) = TRIM(vcNombreArchivo);

		--SE CUENTAN LOS REGISTROS DEL RESPALDO, ASÍ COMO LOS DE LA CONSULTA CON LA CONDICIÓN DINÁMICA Y SE ACTUALIZAN ESTOS DATOS EN LA TABLA
		LET vcSql = TRIM(vcRutaBase) || "actRegResp.sh " || TRIM(vcRuta) || TRIM(vcNombreArchivo) || ' ' || TRIM(vcNombreArchivo);
		SYSTEM vcSql;
		--SE OBTIENEN EL NUM TOTAL DE REGISTROS RESPALDADOS Y DEL QUERY DINÁMICO
		SELECT {+AVOID_FULL(bdiresp:rp_regrespaldados)} NVL(tot_reg_resp,0) INTO viTotRegResp FROM "informix".rp_regrespaldados WHERE TRIM(nombre_respaldo) = TRIM(vcNombreArchivo);
		--SE REALIZA UN RESTA DE AMBOS TOTALES PARA VER SI HUBO DIFERENCIAS ENTRE RESPALDO Y CONSULTA DINÁMICA
		LET viDifRegistros = NVL(viTotRegResp,0) - NVL(viTotRegCons,0);
		--ESTA CONDICIÓN INDICA QUE NO SE PUDO REALIZAR EL RESPALDO O NO PUDIERON ACTUALIZARSE LOS CAMPOS REGISTROS_RESPALDOS Y REGISTROS_QUERY
		If ( NVL(viTotRegResp,0) = -1 OR NVL(viDifRegistros,0) <> 0 ) THEN
			LET vcError = '1';
			EXECUTE PROCEDURE sp_deshacer_respaldarAplicaciones(pdFechaResp) INTO viCodigo2, vcDescRet2;
			EXIT FOREACH;
		ELSE--SI NO HUBO DIFERENCIAS DE REGISTROS RESPALDADOS SE ACTUALIZA EL FLAG DE CONFIRMACIÓN DE RESPALDO
			UPDATE {+AVOID_FULL(bdiresp:rp_respaldos)} "informix".rp_respaldos SET flag_confirmacion = '1' WHERE TRIM(nombre_archivo) = TRIM(vcNombreArchivo);
			--SE REGISTRA EN EL LOG DE PROCESOS EL TOTAL DE REGISTROS RESPALDADOS POR TABLA
			IF ( NVL(viTotRegResp,0) = 0 ) THEN
				EXECUTE PROCEDURE sp_insertaLog(3001, 'SE GENERÓ RESPALDO CON CERO REGISTROS', TRIM(vcNombreArchivo), "Informix", 2, '') INTO viCodigo2, vcDescRet2;
			ELSE
				EXECUTE PROCEDURE sp_insertaLog(3001, 'TOTAL REGISTROS RESPALDADOS: '  || viTotRegResp, TRIM(vcNombreArchivo), "Informix", 2, '') INTO viCodigo2, vcDescRet2;
			END IF;
		END IF;
		UPDATE {+AVOID_FULL(bdiresp:rp_respaldos)} "informix".rp_respaldos SET registros_respaldados = NVL(viTotRegResp,0) WHERE TRIM(nombre_archivo) = TRIM(vcNombreArchivo);

		--DEPURACIÓN DE INFORMACIÓN

		EXECUTE PROCEDURE sp_borraregistros(vcBaseDatos,vcTabla,vcCondicion,vcNombreArchivo) INTO vcCodRet3;


		IF(vcCodRet3 != '00000')THEN
			--LOG DE ERRORES
			EXECUTE PROCEDURE sp_insertaLog(3001, 'ERROR, SE DETECTÓ UN PROBLEMA EN SP_BORRAREGISTROS', '', "Informix", 3, ('ERROR ' || viCodigo || ' AL EJECUTAR EL SP sp_borraregistros(' || NVL(pdFechaResp,'NULL') || ')')) INTO viCodigo2, vcDescRet2;
			LET vcDescRet = 'RESPALDO EXITOSO, OCURRIO UN ERROR EN EL SP_BORRAREGISTROS';
		END IF;

		SELECT {+AVOID_FULL(bdiresp:rp_respaldos)} NVL(registros_respaldados,0), NVL(registros_borrados,0) INTO viTotRegResp, viTotRegBorr FROM "informix".rp_respaldos WHERE TRIM(nombre_archivo) = TRIM(vcNombreArchivo);
		--SI EL NÚMERO DE REGISTROS RESPALDADOS DIFIERE DEL DE BORRADOS, SE REALIZA ROLLBACK MANUAL
		IF ( NVL(viTotRegResp,0) <> NVL(viTotRegBorr, 0) ) THEN
			LET vcError = '1';
			--EXECUTE PROCEDURE sp_deshacer_respaldarAplicaciones(pdFechaResp) INTO viCodigo2, vcDescRet2;
			EXIT FOREACH;
		ELSE --EN CASO DE QUE NO HAYA DIFERENCIAS ENTRE LOS REGISTROS RESPALDADOS Y BORRADOS, SE ACTUALIZA EL FLAG DE CONFIRMACIÓN DE BORRADO
			UPDATE {+AVOID_FULL(bdiresp:rp_respaldos)} "informix".rp_respaldos SET flag_borrados = '1' WHERE TRIM(nombre_archivo) = TRIM(vcNombreArchivo);
		END IF;
		
		IF ( vcError = '1' ) THEN
			--LOG DE EVENTOS
			UPDATE "informix".rp_tabla_aplicacion SET realizo_respaldo = '0' WHERE cve_aplicacion = viCveAplicacion;
			EXECUTE PROCEDURE sp_insertaLog(3001, 'FALLÓ PROCESO DE RESPALDO ' || NVL(vcNombreArchivo,''), '' , "Informix", 1, '') INTO viCodigo2, vcDescRet2;
		ELSE
			IF ( vcEncontro = '1' ) THEN
				--LOG DE EVENTOS
				UPDATE "informix".rp_tabla_aplicacion SET realizo_respaldo = '1' WHERE cve_aplicacion = viCveAplicacion;
				EXECUTE PROCEDURE sp_insertaLog(3001, 'CONCLUYÓ EXITOSAMENTE PROCESO DE RESPALDO', '' , "Informix", 1, '') INTO viCodigo2, vcDescRet2;
			ELSE
				--LOG DE EVENTOS
				EXECUTE PROCEDURE sp_insertaLog(3001, 'CONCLUYÓ PROCESO DE RESPALDO SIN INFORMACIÓN POR RESPALDAR', '' , "Informix", 1, '') INTO viCodigo2, vcDescRet2;
				--BITÁCORA DE PROCESOS
				EXECUTE PROCEDURE sp_insertaLog(3001, 'NO SE ENCONTRARON RESPALDOS PENDIENTES POR REALIZAR', '', "Informix", 2, '') INTO viCodigo2, vcDescRet2;
			END IF;
		END IF;

	END FOREACH;


	DELETE {+AVOID_FULL(bdiresp:rp_regrespaldados)} FROM "informix".rp_regrespaldados;
	IF ( vcEnTrans = '1' ) THEN
		COMMIT WORK;
		LET vcEnTrans = '0';
	END IF;
	
	--BITÁCORA DE PROCESOS
	EXECUTE PROCEDURE sp_insertaLog(3002, 'FINALIZA PROCESO DE RESPALDO', '', "Informix", 2, '') INTO viCodigo2, vcDescRet2;
	RETURN vcCodRet, vcDescRet;
	END;
END PROCEDURE;
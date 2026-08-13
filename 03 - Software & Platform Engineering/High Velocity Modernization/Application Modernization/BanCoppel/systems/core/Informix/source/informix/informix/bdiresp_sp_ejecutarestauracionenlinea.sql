CREATE PROCEDURE "informix".sp_ejecutarestauracionenlinea(piIdSolicitud INT, pcTabla CHAR(30))
	RETURNING CHAR(5) AS Retorno, CHAR(100) AS DescError;
	
	/*
	*****************************************************************************************************
	-- DESCRIPCION:  Realiza la restauración de una tabla en linea --------------------------------------
	-- AUTOR : Walber Castro ----------------------------------------------------------------------------
	-- FECHA : 05/11/2012  ------------------------------------------------------------------------------
	-- BD: bdiresp  -------------------------------------------------------------------------------------	
	-----------------------------------------------------------------------------------------------------
	*****************************************************************************************************
	-- MODIFICACIÓN: Se eliminaron las referencias a la BD bdiresp de los sp's propios de esta.
	-- AUTOR: Moisés Soriano
	-- FECHA : 26/02/2013
	-- BD: bdiresp
	
	-- Descripción: Se actualizó el cargado de información de load a dbload.
	-- Modificó: Moisés Soriano.
	-- Fecha: 17/02/2013.
	-- BD: bdiresp.
	*****************************************************************************************************
	-- MODIFICACION:  Se agrego ROLLBACK en caso de que falle el proceso de restauracion. ---------------
	-- Se cambio la posicion del COMMIT WORK. -----------------------------------------------------------
	-- AUTOR : Roberto Castro ---------------------------------------------------------------------------
	-- FECHA : 07/22/2013  ------------------------------------------------------------------------------
	-- BD: bdiresp  -------------------------------------------------------------------------------------	
	-----------------------------------------------------------------------------------------------------
	*****************************************************************************************************
	*/
	
	DEFINE viCodigo				INT;
	DEFINE vcCodRet				CHAR(5);	
	DEFINE vcDescRet			CHAR(100);
	DEFINE vcCodRet2			CHAR(5);
	
	DEFINE vcBaseDeDatos		CHAR(20);	
	DEFINE vcCondicion			CHAR(100);
	DEFINE vcNomArchivo			CHAR(50);	
	DEFINE vcSql				CHAR(1000);
	DEFINE viCodigo2			INT;
	DEFINE vcDescRet2			CHAR(100);
	DEFINE vcRuta 				CHAR(100);
	DEFINE viTotRegCons			INT;
	DEFINE viTotRegResp			INT;	
	DEFINE vdFechaInicio		DATE;
	DEFINE vdFechaFinal			DATE;
	DEFINE vcRutaBase			CHAR(50);
	DEFINE viCont				INT;
	DEFINE vcEnTrans			CHAR(1);
	DEFINE vcSeRestauro			CHAR(1);	
	DEFINE viCont2				INT;
	DEFINE viNumCols			INT;
	DEFINE viNumColSql			CHAR(1000);
	
	
	LET viCodigo 			=	0;
	LET vcCodRet			=	'00000';
	LET vcDescRet			=	'';	
	LET vcBaseDeDatos		=	'';	
	LET vcCondicion			=	'';
	LET vcNomArchivo		=	'';	
	LET vcSql				=	'';
	LET viCodigo2			=	0;
	LET vcDescRet2			=	'';
	LET vcRuta				=	'';
	LET viTotRegCons		=	0;
	LET viTotRegResp		=	0;	
	LET vdFechaInicio		=	'01-01-1900';
	LET vdFechaFinal		=	'01-01-1900';
	LET vcRutaBase			=	'';
	LET vcCodRet2			=	'00000';
	LET viCont				=	0;
	LET vcEnTrans			=	'0';
	LET vcSeRestauro		=	'0';	
	LET viCont2				=	0;
	LET viNumCols			=	0;
	LET viNumColSql			=	'';
	
--SET DEBUG FILE TO "/home/sysifx/roberto/sp_ejecutarestauracionenlinea.out";
--TRACE ON;
	
	BEGIN

	ON EXCEPTION SET viCodigo
		IF ( viCodigo <> 0 ) THEN
			LET vcCodRet = viCodigo;
		END IF;
		IF( vcEnTrans = '1' ) THEN
			ROLLBACK WORK;
			LET vcEnTrans = '0';
		END IF;		
		IF ( TRIM(NVL(vcSeRestauro,'')) = '1' ) THEN
			LET vcSql = "DELETE FROM " || TRIM(vcBaseDeDatos) || ":" || TRIM(pcTabla) || " WHERE " || TRIM(vcCondicion);
			EXECUTE IMMEDIATE vcSql;
		END IF;	
		--LOG DE EVENTOS
		EXECUTE PROCEDURE sp_insertaLog(4004, 'FALLÓ PROCESO DE RESTAURACIÓN EN LÍNEA, SOLICITUD: ' || piIdSolicitud || ', TABLA: ' || TRIM(NVL(pcTabla,'')), '' , "Informix", 1, '') INTO viCodigo2, vcDescRet2;
		--LOG DE ERRORES
		EXECUTE PROCEDURE sp_insertaLog(4004, 'PROCESO DE RESTAURACIÓN EN LÍNEA', '', "Informix", 3, 'ERROR ' || viCodigo || ' AL EJECUTAR EL SP sp_ejecutaRestauracionEnLinea(' || NVL(piIdSolicitud,'NULL') || ',' || TRIM(NVL(pcTabla,'NULL')) || ')') INTO viCodigo2, vcDescRet2;		
		--BITÁCORA DE PROCESOS
		EXECUTE PROCEDURE sp_insertaLog(4004, 'ERROR, SE DETECTÓ UN PROBLEMA EN PROCESO DE RESTAURACIÓN EN LÍNEA', TRIM(vcNomArchivo), "Informix", 2, '') INTO viCodigo2, vcDescRet2;
		EXECUTE PROCEDURE sp_insertaLog(4005, 'FINALIZA PROCESO DE RESTAURACIÓN EN LÍNEA', '' , "Informix", 2, '') INTO viCodigo2, vcDescRet2;		
		
		RETURN NVL(vcCodRet,''),NVL(vcDescRet,'');
	END EXCEPTION;	

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	IF ( NVL(piIdSolicitud, 0) = 0 ) THEN
		LET vcCodRet = '00001';
		LET vcDescRet= 'ERROR, ID SOLICITUD INVÁLIDO (PARÁMETRO 1)';
		RETURN vcCodRet, vcDescRet;
	END IF;
	
	IF ( NVL(pcTabla,'') = '' ) THEN
		LET vcCodRet = '00001';
		LET vcDescRet= 'ERROR, TABLA INVÁLIDA (PARÁMETRO 2)';
		RETURN vcCodRet, vcDescRet;
	END IF;
	
	EXECUTE PROCEDURE sp_consultaParametro('01') INTO vcCodRet2, vcRutaBase;
	
	IF ( TRIM(NVL(vcCodRet2,'')) <> '00000' OR TRIM(NVL(vcRutaBase,'')) = '' ) THEN
		LET vcCodRet = '00001';
		LET vcDescRet = 'NO SE ENCONTRÓ LA RUTA BASE EN LA TABLA DE PARÁMETROS';
		--LOG DE ERRORES
		EXECUTE PROCEDURE sp_insertaLog(4004, 'PROCESO DE RESTAURACIÓN EN LÍNEA', '', "Informix", 3, vcDescRet) INTO viCodigo2, vcDescRet2;
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
		EXECUTE PROCEDURE sp_insertaLog(4004, 'PROCESO DE RESTAURACIÓN EN LÍNEA', '', "Informix", 3, vcDescRet) INTO viCodigo2, vcDescRet2;
		RETURN vcCodRet, vcDescRet;
	END IF;
	
	EXECUTE PROCEDURE sp_validaRuta(vcRutaBase) INTO viCont;
	IF ( viCont <> 0 ) THEN
		LET vcCodRet = '00001';
		LET vcDescRet = 'RUTA BASE INVÁLIDA';
		--LOG DE ERRORES
		EXECUTE PROCEDURE sp_insertaLog(4004, 'PROCESO DE RESTAURACIÓN EN LÍNEA', '', "Informix", 3, vcDescRet) INTO viCodigo2, vcDescRet2;
		RETURN vcCodRet, vcDescRet;
	END IF;
	
	EXECUTE PROCEDURE sp_insertaLog(4003, 'INICIA PROCESO DE RESTAURACIÓN EN LÍNEA', '' , "Informix", 2, '') INTO viCodigo2, vcDescRet2;
	BEGIN WORK;
	LET vcEnTrans = '1';
	LET viCont = 0;
	FOREACH
		SELECT {+INDEX(bdiresp:rp_respaldos 109_60)} t1.base_de_datos, t1.ruta, t1.nombre_archivo, t3.condicion, t4.fecha_inicio, t4.fecha_final
		INTO vcBaseDeDatos, vcRuta, vcNomArchivo, vcCondicion, vdFechaInicio, vdFechaFinal
		FROM "informix".rp_tablas_restauradas t1
		INNER JOIN "informix".rp_restauraciones t2 ON (t1.id_solicitud=t2.id_solicitud)
		INNER JOIN "informix".rp_tabla_aplicacion t3 ON (t1.tabla=t3.tabla)
		INNER JOIN "informix".rp_respaldos t4 ON (t1.nombre_archivo=t4.nombre_archivo)
		WHERE t1.id_solicitud = piIdSolicitud AND t1.estatus IN ('0') AND TRIM(t1.tabla) = TRIM(pcTabla)
		ORDER BY t3.cve_aplicacion,t1.sec_restauracion
		LET vcSeRestauro = '0'; --BANDERA INICIO DE PROCESO
		LET viCont = viCont + 1;
		IF ( TRIM(NVL(vcCondicion,'')) <> '' ) THEN
			LET vcCondicion = REPLACE(vcCondicion, '¿', "'" || vdFechaInicio || "'::DATE");
			LET vcCondicion = REPLACE(vcCondicion, '?', "'" || vdFechaFinal || "'::DATE");
		ELSE			
			--LOG DE ERRORES
			EXECUTE PROCEDURE sp_insertaLog(4004, 'PROCESO DE RESTAURACIÓN EN LÍNEA','' , "Informix", 3, 'CONDICIÓN NO VÁLIDA PARA EL ARCHIVO ' || TRIM(NVL(vcNomArchivo,''))) INTO viCodigo2, vcDescRet2;
			--BITÁCORA DE PROCESOS
			EXECUTE PROCEDURE sp_insertaLog(4004, 'ERROR, SE DETECTÓ UN PROBLEMA EN PROCESO DE RESTAURACIÓN EN LÍNEA', TRIM(vcNomArchivo) , "Informix", 2, '') INTO viCodigo2, vcDescRet2;			
			CONTINUE FOREACH;
		END IF;

		
		/* LET vcSql = '"LOAD FROM ' || TRIM(vcRuta) || TRIM(vcNomArchivo) ||
                  ' INSERT INTO ' || TRIM(vcBaseDeDatos) || ':' || TRIM(pcTabla) || '"';
				  
		SYSTEM TRIM(vcRutaBase) || "restauraArchivo.sh " || TRIM(vcRuta) || TRIM(vcNomArchivo) || " " || TRIM(vcSql) || " " || TRIM(vcBaseDeDatos) || " " || TRIM(vcNomArchivo) || " " || "4004";
		*/	
				
		--Obtiene el numero de columnas de la tabla dinámica
				
		LET viNumColSql = "SELECT ncols FROM " ||TRIM(vcBaseDeDatos)||":"|| "systables WHERE tabname = " ||"'"||TRIM(pcTabla)||"'";
		
		PREPARE xsql FROM viNumColSql;
			DECLARE xcur CURSOR FOR xsql;
			OPEN xcur;		
			WHILE 1 = 1
				FETCH xcur INTO viNumCols;
				IF (SQLCODE = 100) THEN
					EXIT WHILE;
				END IF;
			END WHILE;
			CLOSE xcur;
			FREE xcur;
			FREE xsql;
		
		--Carga de información		
		
		LET vcSql = "echo "||'"'|| "file '"|| TRIM(vcRuta) || TRIM(vcNomArchivo)||
					  "' delimiter '|' "|| viNumCols||
					  "; insert into "||TRIM(pcTabla)||";"||'"'|| ">" ||TRIM(vcRuta)|| "carga";
		SYSTEM vcSql;

		/* LET vcSql = "dbload -d "|| TRIM(vcBaseDeDatos)|| " -c carga -l er -n 100";
		  SYSTEM vcSql;
		   */
		
		LET vcSql ="cd "||TRIM(vcRuta)||" && "||"dbload -d "|| TRIM(vcBaseDeDatos)|| " -c carga -l er -n 100";		
		SYSTEM vcSql;
				
		LET vcSeRestauro = '1'; --BANDERA SE EJECUTÓ LA RESTAURACION
		LET vcSql = " SELECT COUNT(*) FROM " || TRIM(vcBaseDeDatos) || ":" || TRIM(pcTabla) || " WHERE " || TRIM(vcCondicion);
		
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

		
		
		--SE VALIDA QUE LOS REGISTROS RESTAURADOS COINCIDAN CON LOS DEL RESPALDO REGISTRADOS EN LA TABLA RP_RESPALDO
		SELECT {+INDEX(bdiresp:rp_respaldos 109_60)} NVL(registros_respaldados,0) INTO viTotRegResp FROM "informix".rp_respaldos WHERE TRIM(nombre_archivo) = TRIM(vcNomArchivo);
		IF ( NVL(viTotRegResp,0) <> NVL(viTotRegCons,0) ) THEN
			LET viCont2 = viCont2 + 1;
			
			LET vcSql = "DELETE FROM " || TRIM(vcBaseDeDatos) || ":" || TRIM(pcTabla) || " WHERE " || TRIM(vcCondicion);
			EXECUTE IMMEDIATE vcSql;			
			--LOG DE ERRORES
			EXECUTE PROCEDURE sp_insertaLog(4004, 'PROCESO DE RESTAURACIÓN EN LÍNEA','' , "Informix", 3, 'LOS REGISTROS RESTAURADOS DIFIEREN DEL RESPALDO ' || TRIM(NVL(vcNomArchivo,''))) INTO viCodigo2, vcDescRet2;
			--BITÁCORA DE PROCESOS
			EXECUTE PROCEDURE sp_insertaLog(4004, 'ERROR, SE DETECTÓ UN PROBLEMA EN PROCESO DE RESTAURACIÓN EN LÍNEA', TRIM(vcNomArchivo) , "Informix", 2, '') INTO viCodigo2, vcDescRet2;			
		ELSE
			EXECUTE PROCEDURE sp_insertaLog(4004, 'TOTAL REGISTROS RESTAURADOS EN LÍNEA: '  || viTotRegCons, TRIM(vcNomArchivo), "Informix", 2, '') INTO viCodigo2, vcDescRet2;
			
			UPDATE "informix".rp_tablas_restauradas 
			SET estatus = '1', fecha_restauracion = CURRENT YEAR TO SECOND, user_insert = 'Informix', fecha_insert = CURRENT YEAR TO SECOND
			WHERE id_solicitud = piIdSolicitud AND tabla = TRIM(pcTabla) AND nombre_archivo = TRIM(vcNomArchivo);
		
			UPDATE "informix".rp_restauraciones SET status = '1', user_insert = 'Informix', fecha_insert = CURRENT YEAR TO SECOND WHERE id_solicitud = piIdSolicitud AND status = '0';			
		END IF;		
	END FOREACH;
	
	/*IF ( vcEnTrans = '1' ) THEN
		COMMIT WORK;
		LET vcEnTrans = '0';
	END IF;*/
	
	IF ( viCont > 0 ) THEN
		IF ( viCont2 > 0 ) THEN
			IF ( viCont2 = viCont ) THEN
				LET vcCodRet = '00020';
				LET vcDescRet = 'ERROR, NO PUDIERON SER RESTAURADOS LOS ARCHIVOS RELACIONADOS A LA TABLA';
				--LOG DE EVENTOS
				EXECUTE PROCEDURE sp_insertaLog(4004, 'FALLÓ PROCESO DE RESTAURACIÓN EN LÍNEA DE LA SOLICITUD ' || NVL(piIdSolicitud,'') || ', TABLA ' || TRIM(NVL(pcTabla,'')), '' , "Informix", 1, '') INTO viCodigo2, vcDescRet2;

				ROLLBACK WORK;
				RETURN vcCodRet, vcDescRet;
			ELSE
				LET vcCodRet = '00030';
				LET vcDescRet = 'ERROR, NO PUDIERON SER RESTAURADOS UNO O MÁS DE LOS ARCHIVOS RELACIONADOS A LA TABLA';
				--LOG DE EVENTOS
				EXECUTE PROCEDURE sp_insertaLog(4004, 'FINALIZÓ INCOMPLETO PROCESO DE RESTAURACIÓN EN LÍNEA DE LA SOLICITUD ' || NVL(piIdSolicitud,'') || ', TABLA ' || TRIM(NVL(pcTabla,'')), '' , "Informix", 1, '') INTO viCodigo2, vcDescRet2;

				ROLLBACK WORK;
				RETURN vcCodRet, vcDescRet;
			END IF;		
		ELSE
			--LOG DE EVENTOS
			EXECUTE PROCEDURE sp_insertaLog(4004, 'CONCLUYÓ EXITOSAMENTE PROCESO DE RESTAURACIÓN EN LÍNEA, SOLICITUD: ' || NVL(piIdSolicitud,'') || ', TABLA: ' || TRIM(NVL(pcTabla,'')), '' , "Informix", 1, '') INTO viCodigo2, vcDescRet2;		
		END IF;
	ELSE
		--LOG DE EVENTOS
		EXECUTE PROCEDURE sp_insertaLog(4004, 'CONCLUYÓ PROCESO DE RESTAURACIÓN EN LÍNEA SIN INFORMACIÓN POR RESTAURAR', '' , "Informix", 1, '') INTO viCodigo2, vcDescRet2;
		--BITÁCORA DE PROCESOS
		EXECUTE PROCEDURE sp_insertaLog(4004, 'NO SE ENCONTRARON RESTAURACIONES EN LÍNEA PENDIENTES POR REALIZAR','', "Informix", 2, '') INTO viCodigo2, vcDescRet2;
	END IF;
	
	IF ( vcEnTrans = '1' ) THEN
		COMMIT WORK;
		LET vcEnTrans = '0';
	END IF;

	--Actualizar índices
	EXECUTE IMMEDIATE 
	"update statistics medium for table " ||TRIM(vcBaseDeDatos)||":"|| TRIM(pcTabla);
	
	--BITÁCORA DE PROCESOS
	EXECUTE PROCEDURE sp_insertaLog(4005, 'FINALIZA PROCESO DE RESTAURACIÓN EN LÍNEA', '' , "Informix", 2, '') INTO viCodigo2, vcDescRet2;
	RETURN vcCodRet, vcDescRet;
	END;
END PROCEDURE;
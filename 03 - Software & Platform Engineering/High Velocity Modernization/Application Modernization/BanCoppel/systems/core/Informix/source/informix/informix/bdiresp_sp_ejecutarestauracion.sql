CREATE PROCEDURE "informix".sp_ejecutarestauracion(pcFechaCaracter CHAR(10))
	RETURNING CHAR(5) AS Retorno, CHAR(100) AS DescError;
		
	/*
	*****************************************************************************************************
	-- DESCRIPCION:  Realiza la restauración de las tablas cuya fecha solicitud es hoy ------------------
	-- AUTOR : Walber Castro ----------------------------------------------------------------------------
	-- FECHA : 05/11/2012  ------------------------------------------------------------------------------
	-- BD: bdiresp  -------------------------------------------------------------------------------------	
	-----------------------------------------------------------------------------------------------------
	*****************************************************************************************************	
	-- Descripción: Se actualizó el cargado de información de load a dbload.
	-- Modificó: Moisés Soriano.
	-- Fecha: 17/02/2013.
	-- BD: bdiresp.
	*****************************************************************************************************
	-- DESCRIPCION:  Se cambio la ubicacion de la actualizacion de los indices.  ------------------------
	-- AUTOR : Roberto Castro ---------------------------------------------------------------------------
	-- FECHA : 17/07/2013  ------------------------------------------------------------------------------
	-- BD: bdiresp  -------------------------------------------------------------------------------------	
	-----------------------------------------------------------------------------------------------------
	*****************************************************************************************************
	*/
	
	DEFINE viCodigo				INT;
	DEFINE vcCodRet				CHAR(5);	
	DEFINE vcDescRet			CHAR(100);
	DEFINE vcCodRet2			CHAR(5);
	
	DEFINE viIdSolicitud		INT;
	DEFINE vcBaseDeDatos		CHAR(20);
	DEFINE vcTabla				CHAR(30);
	DEFINE vcCondicion			CHAR(100);
	DEFINE vcNomArchivo			CHAR(50);
	DEFINE vcEnTrans			CHAR(1);
	DEFINE vdFechaRestauracion	DATETIME YEAR TO SECOND;
	DEFINE vcSql				CHAR(1000);
	DEFINE viCodigo2			INT;
	DEFINE vcDescRet2			CHAR(100);
	DEFINE vcRuta				CHAR(100);
	DEFINE viTotRegCons			INT;
	DEFINE viTotRegResp			INT;	
	DEFINE vdFechaInicio		DATE;
	DEFINE vdFechaFinal			DATE;
	DEFINE vcRutaBase			CHAR(50);
	DEFINE viCont				INT;
	DEFINE pdFechaRest			DATE;
	DEFINE vcEncontro			CHAR(1);
	DEFINE viNumCols			INT;
	DEFINE viNumColSql			CHAR(1000);
	
	LET viCodigo 			=	0;
	LET vcCodRet 			= 	'00000';
	LET vcDescRet 			= 	'';
	LET viIdSolicitud 		= 	0;
	LET vcBaseDeDatos 		= 	'';
	LET vcTabla 			= 	'';
	LET vcCondicion 		= 	'';
	LET vcNomArchivo 		= 	'';
	LET vcEnTrans 			= 	'0';
	LET vdFechaRestauracion = 	CURRENT YEAR TO SECOND;
	LET vcSql 				= 	'';
	LET viCodigo2 			= 	0;
	LET vcDescRet2 			= 	'';
	LET vcRuta 				= 	'';
	LET viTotRegCons 		= 	0;
	LET viTotRegResp 		= 	0;	
	LET vdFechaInicio		=	'01-01-1900';
	LET vdFechaFinal		=	'01-01-1900';
	LET vcRutaBase			=	'';
	LET vcCodRet2			=	'00000';
	LET viCont				=	0;
	LET pdFechaRest			=	'01-01-1900';
	LET vcEncontro			=	'';
	LET viNumCols			=	'';
	LET viNumColSql			=	'';

  --SET DEBUG FILE TO "/home/sysifx/roberto/sp_ejecutarestauracion1.out";
  --TRACE ON;
	
	BEGIN

	ON EXCEPTION SET viCodigo
		IF viCodigo <> 0 THEN
			LET vcCodRet = viCodigo;
		END IF;
				
		LET vcSql = "DELETE FROM " || TRIM(vcBaseDeDatos) || ":" || TRIM(vcTabla) || " WHERE " || TRIM(vcCondicion);
		EXECUTE IMMEDIATE vcSql;
		
		--LOG DE EVENTOS
		EXECUTE PROCEDURE sp_insertaLog(4007, 'FALLÓ PROCESO DE RESTAURACIÓN ' || NVL(vcNomArchivo,''), '' , "Informix", 1, '') INTO viCodigo2, vcDescRet2;
		--LOG DE ERRORES
		EXECUTE PROCEDURE sp_insertaLog(4007, 'PROCESO DE RESTAURACIÓN', '', "Informix", 3, 'ERROR ' || viCodigo || ' AL EJECUTAR EL SP sp_ejecutaRestauracion()') INTO viCodigo2, vcDescRet2;
		--BITÁCORA DE PROCESOS
		EXECUTE PROCEDURE sp_insertaLog(4007, 'ERROR, SE DETECTÓ UN PROBLEMA EN PROCESO DE RESTAURACIÓN', TRIM(vcNomArchivo), "Informix", 2, '') INTO viCodigo2, vcDescRet2;
		EXECUTE PROCEDURE sp_insertaLog(4008, 'FINALIZA PROCESO DE RESTAURACIÓN', '' , "Informix", 2, '') INTO viCodigo2, vcDescRet2;		
		
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
	
	SELECT FIRST 1 today INTO pcFechaCaracter FROM rp_parametros;
	LET pdFechaRest = pcFechaCaracter::DATE;	

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;

	EXECUTE PROCEDURE sp_consultaParametro('01') INTO vcCodRet2, vcRutaBase;
	
	IF ( TRIM(NVL(vcCodRet2,'')) <> '00000' OR TRIM(NVL(vcRutaBase,'')) = '' ) THEN
		LET vcCodRet = '00001';
		LET vcDescRet = 'NO SE ENCONTRÓ LA RUTA BASE EN LA TABLA DE PARÁMETROS';
		--LOG DE ERRORES
		EXECUTE PROCEDURE sp_insertaLog(4007, 'PROCESO DE RESTAURACIÓN', '', "Informix", 3, vcDescRet) INTO viCodigo2, vcDescRet2;
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
		EXECUTE PROCEDURE sp_insertaLog(4007, 'PROCESO DE RESTAURACIÓN', '', "Informix", 3, vcDescRet) INTO viCodigo2, vcDescRet2;
		RETURN vcCodRet, vcDescRet;
	END IF;
	
	EXECUTE PROCEDURE sp_validaRuta(vcRutaBase) INTO viCont;
	IF ( viCont <> 0 ) THEN
		LET vcCodRet = '00001';
		LET vcDescRet = 'RUTA BASE INVÁLIDA';
		--LOG DE ERRORES
		EXECUTE PROCEDURE sp_insertaLog(4007, 'PROCESO DE RESTAURACIÓN', '', "Informix", 3, vcDescRet) INTO viCodigo2, vcDescRet2;
		RETURN vcCodRet, vcDescRet;
	END IF;	
	
	--BITÁCORA DE PROCESOS
	EXECUTE PROCEDURE sp_insertaLog(4006, 'INICIA PROCESO DE RESTAURACIÓN', '' , "Informix", 2, '') INTO viCodigo2, vcDescRet2;
	
	FOREACH
		SELECT {+INDEX(bdiresp:rp_respaldos 109_60)} t1.id_solicitud, t1.base_de_datos, t1.ruta, t1.tabla, t1.nombre_archivo, t1.fecha_restauracion, t4.condicion, t4.fecha_inicio, t4.fecha_final
		INTO viIdSolicitud, vcBaseDeDatos, vcRuta, vcTabla, vcNomArchivo, vdFechaRestauracion, vcCondicion, vdFechaInicio, vdFechaFinal
		FROM "informix".rp_tablas_restauradas t1
		INNER JOIN "informix".rp_restauraciones t2 ON (t1.id_solicitud=t2.id_solicitud)
		INNER JOIN "informix".rp_tabla_aplicacion t3 ON (t1.tabla=t3.tabla)
		INNER JOIN "informix".rp_respaldos t4 ON (t1.nombre_archivo=t4.nombre_archivo)
		WHERE t2.fecha_solicitud::DATE = pdFechaRest AND t1.estatus IN ('0')
		ORDER BY t3.cve_aplicacion,t1.sec_restauracion
		LET vcEncontro = '1';
		IF ( TRIM(NVL(vcCondicion,'')) = '' ) THEN
			--LOG DE EVENTOS
			EXECUTE PROCEDURE sp_insertaLog(4007, 'FALLÓ PROCESO DE RESTAURACIÓN ' || TRIM(vcNomArchivo), '' , "Informix", 1, '') INTO viCodigo2, vcDescRet2;
			--LOG DE ERRORES
			EXECUTE PROCEDURE sp_insertaLog(4007, 'PROCESO DE RESTAURACIÓN','' , "Informix", 3, 'CONDICIÓN NO VÁLIDA PARA EL ARCHIVO ' || TRIM(NVL(vcNomArchivo,''))) INTO viCodigo2, vcDescRet2;
			--BITÁCORA DE PROCESOS
			EXECUTE PROCEDURE sp_insertaLog(4007, 'ERROR, SE DETECTÓ UN PROBLEMA EN PROCESO DE RESTAURACIÓN', TRIM(vcNomArchivo) , "Informix", 2, '') INTO viCodigo2, vcDescRet2;			
			EXECUTE PROCEDURE sp_insertaLog(4008, 'FINALIZA PROCESO DE RESTAURACIÓN', TRIM(vcNomArchivo) , "Informix", 2, '') INTO viCodigo2, vcDescRet2;
			CONTINUE FOREACH;
		END IF;		
		
		/* LET vcSql = '"LOAD FROM ' || TRIM(vcRuta) || TRIM(vcNomArchivo) ||
                  ' INSERT INTO ' || TRIM(vcBaseDeDatos) || ':' || TRIM(vcTabla) || '"';
				  		
		SYSTEM TRIM(vcRutaBase) || "restauraArchivo.sh " || TRIM(vcRuta) || TRIM(vcNomArchivo) || " " || TRIM(vcSql) || " " || TRIM(vcBaseDeDatos);
		 */
		
		--Obtiene el numero de columnas de la tabla dinámica
		 
		LET viNumColSql = "SELECT ncols FROM " ||TRIM(vcBaseDeDatos)||":"|| "systables WHERE tabname = " ||"'"||TRIM(vcTabla)||"'";
		
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
		
		/* LET vcSql = "echo "||'"'|| "file '"|| TRIM(vcRuta) || TRIM(vcNomArchivo)||
					  "' delimiter '|' "|| viNumCols||
					  "; insert into "||TRIM(vcTabla)||";"||'"'||' > carga';
		SYSTEM vcSql; */
		
		LET vcSql = "echo "||'"'|| "file '"|| TRIM(vcRuta) || TRIM(vcNomArchivo)||
					  "' delimiter '|' "|| viNumCols||
					  "; insert into "||TRIM(vcTabla)||";"||'"'|| ">" ||TRIM(vcRuta)|| "carga";
		SYSTEM vcSql;
	
		LET vcSql ="cd "||TRIM(vcRuta)||" && "||"dbload -d "|| TRIM(vcBaseDeDatos)|| " -c carga -l er -n 100";		
		SYSTEM vcSql;
		
		
		LET vcSql = " SELECT COUNT(*) FROM " || TRIM(vcBaseDeDatos) || ":" || TRIM(vcTabla) || " WHERE " || TRIM(vcCondicion);
		
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
			EXECUTE PROCEDURE sp_insertaLog(4007, 'ERROR, LOS REGISTROS RESTAURADOS DIFIEREN DEL RESPALDO, ROLLBACK A RESTAURACIÓN', TRIM(vcNomArchivo) , "Informix", 2, '') INTO viCodigo2, vcDescRet2;
			LET vcSql = "DELETE FROM " || TRIM(vcBaseDeDatos) || ":" || TRIM(vcTabla) || " WHERE " || TRIM(vcCondicion);
			EXECUTE IMMEDIATE vcSql;
			--LOG DE EVENTOS
			EXECUTE PROCEDURE sp_insertaLog(4007, 'FALLÓ PROCESO DE RESTAURACIÓN ' || TRIM(vcNomArchivo), '' , "Informix", 1, '') INTO viCodigo2, vcDescRet2;
			--LOG DE ERRORES
			EXECUTE PROCEDURE sp_insertaLog(4007, 'PROCESO DE RESTAURACIÓN','' , "Informix", 3, 'LOS REGISTROS RESTAURADOS DIFIEREN DEL RESPALDO ' || TRIM(NVL(vcNomArchivo,''))) INTO viCodigo2, vcDescRet2;
			--BITÁCORA DE PROCESOS
			EXECUTE PROCEDURE sp_insertaLog(4007, 'ERROR, SE DETECTÓ UN PROBLEMA EN PROCESO DE RESTAURACIÓN', TRIM(vcNomArchivo) , "Informix", 2, '') INTO viCodigo2, vcDescRet2;			
		ELSE			
			
			EXECUTE PROCEDURE sp_insertaLog(4007, 'TOTAL REGISTROS RESTAURADOS: '  || viTotRegCons, TRIM(vcNomArchivo), "Informix", 2, '') INTO viCodigo2, vcDescRet2;
			
			UPDATE "informix".rp_tablas_restauradas 
			SET estatus = '1', fecha_restauracion = CURRENT YEAR TO SECOND, user_insert = 'Informix', fecha_insert = CURRENT YEAR TO SECOND
			WHERE id_solicitud = viIdSolicitud AND tabla = TRIM(vcTabla) AND nombre_archivo = TRIM(vcNomArchivo) AND fecha_restauracion::DATE = vdFechaRestauracion::DATE;
		
			UPDATE "informix".rp_restauraciones SET status = '1', user_insert = 'Informix', fecha_insert = CURRENT YEAR TO SECOND WHERE id_solicitud = viIdSolicitud AND status = '0';
			
		END IF;
		

		--Actualizar índices
		EXECUTE IMMEDIATE 
		"update statistics medium for table "||TRIM(vcBaseDeDatos)||":"|| TRIM(vcTabla);

	END FOREACH;	
	
	IF ( vcEncontro = '1' ) THEN
		--LOG DE EVENTOS
		EXECUTE PROCEDURE sp_insertaLog(4007, 'CONCLUYÓ EXITOSAMENTE PROCESO DE RESTAURACIÓN', '' , "Informix", 1, '') INTO viCodigo2, vcDescRet2;
	ELSE
		--LOG DE EVENTOS
		EXECUTE PROCEDURE sp_insertaLog(4007, 'CONCLUYÓ PROCESO DE RESTAURACIÓN SIN INFORMACIÓN POR RESTAURAR', '' , "Informix", 1, '') INTO viCodigo2, vcDescRet2;
		--BITÁCORA DE PROCESOS
		EXECUTE PROCEDURE sp_insertaLog(4007, 'NO SE ENCONTRARON RESTAURACIONES PENDIENTES POR REALIZAR','', "Informix", 2, '') INTO viCodigo2, vcDescRet2;
	END IF;
	
	--Actualizar índices
	/*EXECUTE IMMEDIATE 
	"update statistics medium for table "||TRIM(vcBaseDeDatos)||":"|| TRIM(vcTabla);*/
	
	--BITÁCORA DE PROCESOS
	EXECUTE PROCEDURE sp_insertaLog(4008, 'FINALIZA PROCESO DE RESTAURACIÓN', '' , "Informix", 2, '') INTO viCodigo2, vcDescRet2;
	
	RETURN vcCodRet, vcDescRet;
	END;
END PROCEDURE;
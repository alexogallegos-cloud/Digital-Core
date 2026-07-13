CREATE PROCEDURE "informix".sp_cargar_info_procesada_cta_nom()
	RETURNING CHAR(5) AS codret;
	
	DEFINE cCodRet				 	CHAR(5);
	DEFINE sqlErr				 	INTEGER;
	DEFINE cRuta 				 	CHAR(255);
	DEFINE cNombreArch 			 	CHAR(255);
	DEFINE cFechaHoy 			 	CHAR(8);
	DEFINE sNombreArchivoFinal   	VARCHAR(100);
	DEFINE sPreNomArchivoFinal 	 	VARCHAR(100);
	DEFINE sAntNomArchivoFinal 	 	VARCHAR(100);
	DEFINE sAnterNomArchivoFinal 	VARCHAR(100);
	DEFINE vFechaAct			 	DATE;
	DEFINE cSql					 	VARCHAR(200);
	DEFINE v_id					 	INTEGER;
	DEFINE v_numcte				 	VARCHAR(20);
	DEFINE v_numcta				 	VARCHAR(20);
	DEFINE v_estatus			 	SMALLINT;
	DEFINE v_cuentaNomina		 	SMALLINT;
	DEFINE v_estatusCuentaNomina 	SMALLINT;
	DEFINE v_fechaAltaDeNomina	 	DATE;
	DEFINE v_fechaBajaDeNomina	 	DATE;
	DEFINE v_empresagc			 	SMALLINT;
	DEFINE v_grupoBeneficios	 	SMALLINT;
	DEFINE v_periodicidad		 	SMALLINT;
	DEFINE v_tipoCliente		 	SMALLINT;
	DEFINE v_estatusPeticionCliente SMALLINT;
	DEFINE v_proceso			 	VARCHAR(6);
	DEFINE v_fechaUltimaModificacion DATE;
	DEFINE v_fechaCreacion		 	DATE;
	DEFINE v_borracuenta			SMALLINT;
	
	LET cCodRet 		    		= '00001';
	LET sqlErr 			    		= 0; 
	LET cRuta						= '';
	LET cNombreArch  				= '';
	LET sNombreArchivoFinal 		= '';
	LET cFechaHoy					= '';
	LET sPreNomArchivoFinal 		= '';
	LET sAntNomArchivoFinal 		= '';
	LET sAnterNomArchivoFinal		= '';
	LET vFechaAct					= today-2;
	LET cSql						= '';
	LET v_id						= 0;
	LET v_numcte					= '';
	LET v_numcta					= '';
	LET v_estatus			 		= 0;
	LET v_cuentaNomina		 		= 0;
	LET v_estatusCuentaNomina 		= 0;
	LET v_fechaAltaDeNomina	 		= DATE(1);
	LET v_fechaBajaDeNomina	 		= DATE(1);
	LET v_empresagc			 		= 0;
	LET v_grupoBeneficios	 		= 0;
	LET v_periodicidad		  		= 0;
	LET v_tipoCliente		 		= 0;
	LET v_estatusPeticionCliente 	= 0;
	LET v_proceso			 		= '';
	LET v_fechaUltimaModificacion 	= DATE(1);
	LET v_fechaCreacion		 		= DATE(1);
	LET v_borracuenta				= 0;

	
BEGIN

		ON EXCEPTION SET sqlErr
			IF sqlErr <> 0 THEN
				LET cCodRet = sqlErr;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;
	
		--SET DEBUG FILE TO "/home/sysifx/AleBarranco/sp_cargar_info_procesada_cta_nom.out";
		--TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;	
		
		--Ruta del archivo a cargar
		SELECT TRIM(valor)
		INTO cRuta
		FROM "informix".sn_parametros
		WHERE id = 'RUTA_ARCHIVO';

		--Nombre del archivo a cargar
		SELECT TRIM(valor) 
		INTO cNombreArch
		FROM "informix".sn_parametros
		WHERE id = 'NOMBRE_ARCHIVO_SEC';

		BEGIN WORK;
			TRUNCATE TABLE "informix".tbl_sn_cte_cta_nomina;
		COMMIT WORK;
	
		--Cargar informacion a la tabla temporal
		IF TRIM(NVL(cRuta,'')) <> '' AND TRIM(NVL(cNombreArch,'')) <> '' THEN
		
			LET cFechaHoy = YEAR(vFechaAct)||""||LPAD(MONTH(vFechaAct),2,0)||""||LPAD(DAY(vFechaAct),2,0);
			
			LET cNombreArch = REPLACE(TRIM(cNombreArch), 'YYYYMMDD', TRIM(cFechaHoy));
			
			LET cSql = 'echo "LOAD FROM '|| TRIM(cRuta) || TRIM(cNombreArch)
						|| ' INSERT INTO "informix".tbl_sn_cte_cta_nomina;" > ' || TRIM(cRuta) || 'instruccion.sql';
			SYSTEM cSql;
			
			LET cSql = '';
			LET cSql = 'dbaccess bdiadminnomina '|| TRIM(cRuta) || 'instruccion.sql';
			SYSTEM cSql;
			
			LET cSql = '';
			LET cSql =  "rm " || TRIM(cRuta)|| "instruccion.sql";										
			SYSTEM cSql;

		END IF;		

		--Recorrer los datos para insertar, actualizar o eliminar los registros en central
		FOREACH	
			SELECT id, numcte, numcta, estatus, cuentaNomina, estatusCuentaNomina, fechaAltaDeNomina, fechaBajaDeNomina, empresagc, grupoBeneficios, periodicidad, tipoCliente, estatusPeticionCliente, proceso, fechaUltimaModificacion, fechaCreacion, borracuenta
			INTO v_id, v_numcte, v_numcta, v_estatus, v_cuentaNomina, v_estatusCuentaNomina, v_fechaAltaDeNomina, v_fechaBajaDeNomina, v_empresagc, v_grupoBeneficios, v_periodicidad, v_tipoCliente, v_estatusPeticionCliente, v_proceso, v_fechaUltimaModificacion, v_fechaCreacion, v_borracuenta
			FROM tbl_sn_cte_cta_nomina
			
			IF  NVL(v_borracuenta,0) = 0 THEN
				--- Si el registro existe, se actualiza
					UPDATE "informix".sn_cte_cta_nomina
					--UPDATE "informix".tmp_sn_cte_cta_nomina
					SET estatus = v_estatus, cuentaNomina = v_cuentaNomina, estatusCuentaNomina = v_estatusCuentaNomina, fechaAltaDeNomina = v_fechaAltaDeNomina, fechaBajaDeNomina = v_fechaBajaDeNomina, 
						empresagc = v_empresagc, grupoBeneficios = v_grupoBeneficios, periodicidad = v_periodicidad, tipoCliente = v_tipoCliente, estatusPeticionCliente = v_estatusPeticionCliente, 
						proceso = v_proceso, fechaUltimaModificacion = v_fechaUltimaModificacion, fechaCreacion = v_fechaCreacion 
					WHERE numcte = v_numcte and numcta = v_numcta;
						
					--Si no se actualizo, se insertan los datos
					IF DBINFO('sqlca.sqlerrd2') = 0 THEN
						--Si no existe el registro en central, se inserta
						INSERT INTO "informix".sn_cte_cta_nomina( numcte, numcta, estatus, cuentaNomina, estatusCuentaNomina, fechaAltaDeNomina, fechaBajaDeNomina, empresagc, grupoBeneficios, periodicidad, tipoCliente, estatusPeticionCliente, proceso, fechaUltimaModificacion, fechaCreacion)
						--INSERT INTO "informix".tmp_sn_cte_cta_nomina( numcte, numcta, estatus, cuentaNomina, estatusCuentaNomina, fechaAltaDeNomina, fechaBajaDeNomina, empresagc, grupoBeneficios, periodicidad, tipoCliente, estatusPeticionCliente, proceso, fechaUltimaModificacion, fechaCreacion)
						VALUES ( v_numcte, v_numcta, v_estatus, v_cuentaNomina, v_estatusCuentaNomina, v_fechaAltaDeNomina, v_fechaBajaDeNomina, v_empresagc, v_grupoBeneficios, v_periodicidad, v_tipoCliente, v_estatusPeticionCliente, v_proceso, v_fechaUltimaModificacion, v_fechaCreacion);
					END IF;
					
					LET cCodRet = '00000';
	
			--Validar bandera de baja	
			ELSE 
				DELETE FROM "informix".sn_cte_cta_nomina WHERE numcte = v_numcte and numcta = v_numcta;
				--DELETE FROM "informix".tmp_sn_cte_cta_nomina WHERE numcte = v_numcte and numcta = v_numcta;
				LET cCodRet = '00000';
	
			END IF;	
		END FOREACH;
		
		--No hay registros en la tabla 
		IF DBINFO('sqlca.sqlerrd2') = 0 AND cCodRet = '00001' THEN
			LET cCodRet = '00002';
		END IF;
		
		RETURN cCodRet;

	END;	
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se crea procedimiento para actualizar/insertar/eliminar los registros de la tabla sn_cte_cta_nomina del servidor central',
'AUTOR: Alejandra Barranco',
'FECHA DE CREACION: 30 de Septiembre de 2022',
'VERSION: 1.0',
'BD: bdiadminnomina',
'SOLICITO: Fabio Torres Esquer';
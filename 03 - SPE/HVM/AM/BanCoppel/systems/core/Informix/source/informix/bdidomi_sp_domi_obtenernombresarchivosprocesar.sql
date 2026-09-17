CREATE PROCEDURE "informix".sp_domi_obtenernombresarchivosprocesar()
RETURNING
	CHAR(5), ---cod_ret
	VARCHAR(50); ---Nombre de archivos

	---DECLARACIONES
    DEFINE v_cod_ret            CHAR(5);
    DEFINE iSqlErr              INTEGER;
    DEFINE iSamErr              INTEGER;

	DEFINE bBandera				CHAR(1);
	DEFINE sCadSql				LVARCHAR(500);
	DEFINE sLinea				VARCHAR(50);
	DEFINE sRuta				VARCHAR(100);
	DEFINE sNombreArchivo		VARCHAR(50);
	DEFINE iDiaSistema			SMALLINT;
	
	DEFINE cHora				CHAR(8);
	DEFINE cFechaArchivoOUT		CHAR(15);
	DEFINE iTemporales			SMALLINT;
	DEFINE iPaso				SMALLINT;
	
	---INICIALIZACIONES
	LET sCadSql				= "";
	LET bBandera			= "F";
	LET sLinea				= "";
	LET sRuta				= "";
	LET sNombreArchivo		= "";
	LET iDiaSistema			= 0;
	LET cHora				= TO_CHAR(EXTEND(CURRENT, HOUR TO SECOND),'%H:%M:%S');
	LET cFechaArchivoOUT	= YEAR(CURRENT::DATE)||LPAD(MONTH(CURRENT::DATE),2,'0')||LPAD(DAY(CURRENT::DATE),2,'0')||SUBSTR(cHora,1,2)||SUBSTR(cHora,4,2)||SUBSTR(cHora,7,2)||'_';
	LET iTemporales			= 0;
	LET iPaso				= 0;

BEGIN

	ON EXCEPTION
        SET iSqlErr, iSamErr
        IF iSqlErr <> 0 THEN
            LET v_cod_ret = iSqlErr;
        END IF;

        RETURN v_cod_ret,NULL;
    END EXCEPTION;
	
	ON EXCEPTION IN(-668) SET iSqlErr
		IF iPaso NOT IN (4,5,6) THEN 
			LET v_cod_ret = iSqlErr;
			RETURN v_cod_ret,NULL;
		END IF;
	END EXCEPTION WITH RESUME;

	--SET DEBUG FILE TO "/home/sysdomi/sp_Domi_ObtenerNombresArchivosProcesar.out";
	--TRACE ON;

	LET v_cod_ret = '00000';


	--- BORRAR  LA TABLA DE TEMPORAL DE TRABAJO EN CASO DE QUE EXISTA
	IF EXISTS (SELECT tabname FROM systables WHERE tabname = 'dom_tmp_nombres_archivos') THEN
		DROP TABLE dom_tmp_nombres_archivos;
	END IF

	--- CREAR LA TABLA DE TRABAJO
	CREATE TABLE dom_tmp_nombres_archivos
	(linea LVARCHAR(50));

	--- OBETENER LA RUTA DE LOS ARCHIVOS A PROCESAR
	SELECT TRIM(valor)
	INTO sRuta
	FROM bdidomi: dom_parametros WHERE cod_param = "01";

	--- CORRER EL COMANDO LS PARA OBTENER LOS NOMBRES QUE EXISTEN EN LAS CARPETAS Y METERLOS EN EL ARCHIVO buscarnombres.bus
	LET iPaso = 1;
	LET sCadSql = 'ls ' || TRIM(sRuta) || ' > ' || TRIM(sRuta)||cFechaArchivoOUT||'.bus';
	SYSTEM sCadSql;	

	--- GUARDA EL QUERY DEL LOAD EN EL ARCHIVO   *.SQL
	LET iPaso = 2;
	LET sCadSql = 'echo "LOAD FROM ' || TRIM(sRuta) || cFechaArchivoOUT||'.bus' || ' INSERT INTO dom_tmp_nombres_archivos" > '|| TRIM(sRuta) ||cFechaArchivoOUT||'.sql';
	SYSTEM sCadSql;
	
	LET iPaso = 3;
	--- EJECUTA LAS INSTRUCCIONES QUE ESTAN DENTRO DEL ARCHIVO  *.SQL
	--PRODUCCION
	LET sCadSql = '/ifxsif01/bin/dbaccess bdidomi ' || TRIM(sRuta) || cFechaArchivoOUT||'.sql > '||TRIM(sRuta)||TRIM(cFechaArchivoOUT)||'.out 2>&1';
	
	--DESARROLLO
	--LET sCadSql = '/informix/bin/dbaccess bdidomi ' || TRIM(sRuta) || cFechaArchivoOUT||'.sql > '||TRIM(sRuta)||TRIM(cFechaArchivoOUT)||'.out 2>&1';
	SYSTEM sCadSql;

	SELECT DAY(fecha_hoy)
	INTO iDiaSistema
	FROM bdicheq: sc_fechas;
		
	IF NOT EXISTS(SELECT linea FROM dom_tmp_nombres_archivos WHERE LENGTH (linea) = 16 AND UPPER(SUBSTR(linea,1,1)) = "S"
					AND SUBSTR(linea,9,1) = "." AND SUBSTR(linea,13,2)::SMALLINT = iDiaSistema) THEN

		LET iPaso = 4;
		LET sCadSql = 'rm ' || TRIM(sRuta) ||cFechaArchivoOUT||'.bus';
		SYSTEM sCadSql;

		LET iPaso = 5;
		LET sCadSql = 'rm ' || TRIM(sRuta) ||cFechaArchivoOUT||'.sql';
		SYSTEM sCadSql;
		
		LET iPaso = 6;
		LET sCadSql = 'rm ' || TRIM(sRuta) ||cFechaArchivoOUT||'.out';
		SYSTEM sCadSql;		
					
		RETURN "90001", NULL;
	END IF

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	--- CICLO PARA BARRER  LA TABLA DE TRABAJO Y BUSCAR EL NOMBRE DEL ARCHIVO
	FOREACH
		SELECT linea
		INTO sNombreArchivo
		FROM dom_tmp_nombres_archivos
		WHERE LENGTH (linea) = 16 AND UPPER(SUBSTR(linea,1,1)) = "S"  AND SUBSTR(linea,9,1) = "." AND SUBSTR(linea,13,2)::SMALLINT = iDiaSistema
		
		RETURN v_cod_ret, sNombreArchivo WITH RESUME;
	END FOREACH

	--- BORRA LA TABLA DE PASO
	DROP TABLE dom_tmp_nombres_archivos;

	-- BORRA LOS ARCHIVOS DE PASO
	LET iPaso = 4;
	LET sCadSql = 'rm ' || TRIM(sRuta) ||cFechaArchivoOUT||'.bus';
	SYSTEM sCadSql;

	LET iPaso = 5;
	LET sCadSql = 'rm ' || TRIM(sRuta) ||cFechaArchivoOUT||'.sql';
	SYSTEM sCadSql;
	
	LET iPaso = 6;
	LET sCadSql = 'rm ' || TRIM(sRuta) ||cFechaArchivoOUT||'.out';
	SYSTEM sCadSql;
	

END;
--##############################################################################
--## Procedimiento   : sp_Domi_ObtenerNombresArchivosProcesar
--## Version         : 1.0
--## Creado por      : Mohamed CarreÃ³n
--## Fecha creacion  : Julio de 2009
--##Descripcion :
--##############################################################################
END PROCEDURE;
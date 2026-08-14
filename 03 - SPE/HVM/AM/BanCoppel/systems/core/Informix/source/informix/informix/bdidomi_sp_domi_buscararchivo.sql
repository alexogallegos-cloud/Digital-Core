CREATE PROCEDURE "informix".sp_domi_buscararchivo(p_Ruta VARCHAR(100), p_NombreArchivo VARCHAR(50))
RETURNING
	CHAR(5), ---cod_ret
	CHAR(1); ---Bandera   *** V > Existe el Archivo en la Ruta, *** F > No existe el Archivo

	---DECLARACIONES
    DEFINE v_cod_ret            CHAR(5);
    DEFINE iSqlErr              INTEGER;
    DEFINE iSamErr              INTEGER;

	DEFINE bBandera				CHAR(1);
	DEFINE sCadSql				LVARCHAR(500);
	DEFINE sLinea				VARCHAR(50);
	
	DEFINE cHora				CHAR(8);
	DEFINE cFechaArchivoOUT		CHAR(15);
	DEFINE iPaso				SMALLINT;

	---INICIALIZACIONES
	LET sCadSql				= "";
	LET bBandera			= "F";
	LET sLinea				= "";

	LET cHora				= TO_CHAR(EXTEND(CURRENT, HOUR TO SECOND),'%H:%M:%S');
	LET cFechaArchivoOUT	= YEAR(CURRENT::DATE)||LPAD(MONTH(CURRENT::DATE),2,'0')||LPAD(DAY(CURRENT::DATE),2,'0')||SUBSTR(cHora,1,2)||SUBSTR(cHora,4,2)||SUBSTR(cHora,7,2)||'_';
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


	--SET DEBUG FILE TO "/home/sysdomi/sp_Domi_BuscarArchivo.out";
	--TRACE ON;

	LET v_cod_ret = '00000';

	IF (p_Ruta = "") OR (p_Ruta  IS NULL) THEN
		RETURN "00450", NULL;
	END IF

	IF (p_NombreArchivo = "") OR (p_NombreArchivo  IS NULL) THEN
		RETURN "00451", NULL;
	END IF

	--- BORRAR  LA TABLA DE TEMPORAL DE TRABAJO EN CASO DE QUE EXISTA
	IF EXISTS (SELECT tabname FROM systables WHERE tabname = 'dom_tmp_busca_archivo') THEN
		DROP TABLE dom_tmp_busca_archivo;
	END IF

	--- CREAR LA TABLA DE TRABAJO
	CREATE TABLE dom_tmp_busca_archivo
	(linea LVARCHAR(50));

	--- CORRER EL COMANDO LS PARA OBTENER LOS NOMBRES QUE EXISTEN EN LAS CARPETAS Y METERLOS EN EL ARCHIVO buscar.bus
	LET iPaso = 1;
	LET sCadSql = 'ls ' || TRIM(p_Ruta) || ' > ' || TRIM(p_Ruta) || cFechaArchivoOUT|| '.bus';
	SYSTEM sCadSql;

	--- GUARDA EL QUERY DEL LOAD EN EL ARCHIVO   *.SQL
	LET iPaso = 2;
	LET sCadSql = 'echo "LOAD FROM ' || TRIM(p_Ruta) || cFechaArchivoOUT|| '.bus' || ' INSERT INTO dom_tmp_busca_archivo" > '|| TRIM(p_Ruta) || cFechaArchivoOUT|| '.sql';
	SYSTEM sCadSql;

	--- EJECUTA LAS INSTRUCCIONES QUE ESTAN DENTRO DEL ARCHIVO  *.SQL
	LET iPaso = 3;
	--Produccion
	LET sCadSql = '/ifxsif01/bin/dbaccess  bdidomi ' || TRIM(p_Ruta) || cFechaArchivoOUT||'.sql > '||TRIM(p_Ruta)||TRIM(cFechaArchivoOUT)||'.out 2>&1';
	
	--Desarrollo
	--LET sCadSql = '/informix/bin/dbaccess  bdidomi ' || TRIM(p_Ruta) || cFechaArchivoOUT||'.sql > '||TRIM(p_Ruta)||TRIM(cFechaArchivoOUT)||'.out 2>&1';
	
	SYSTEM sCadSql;
	

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	--- CICLO PARA BARRER  LA TABLA DE TRABAJO Y BUSCAR EL NOMBRE DEL ARCHIVO
	FOREACH
		SELECT linea
		INTO sLinea
		FROM dom_tmp_busca_archivo

		IF sLinea = p_NombreArchivo THEN
			LET bBandera = "V";
			EXIT FOREACH;
		END IF;
	END FOREACH;
	
	LET iPaso = 4;	
	LET sCadSql = 'rm ' || TRIM(p_Ruta) ||cFechaArchivoOUT||'.bus';
	SYSTEM sCadSql;

	LET iPaso = 5;
	LET sCadSql = 'rm ' || TRIM(p_Ruta) ||cFechaArchivoOUT||'.sql';
	SYSTEM sCadSql;	

	LET iPaso = 6;
	LET sCadSql = 'rm ' || TRIM(p_Ruta) ||cFechaArchivoOUT||'.out';
	SYSTEM sCadSql;	
	
	DROP TABLE dom_tmp_busca_archivo;

	RETURN v_cod_ret, bBandera;
END;
--##############################################################################
--## Procedimiento   : sp_Domi_BuscarArchivo
--## Version         : 1.0
--## Creado por      : Mohamed CarreÃ³n
--## Fecha creacion  : Julio de 2009
--##Descripcion :  Procedimiento para buscar un archivo en una ruta proporcionada
--##############################################################################
END PROCEDURE;
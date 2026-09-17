CREATE PROCEDURE "informix".sp_con_buscararchivo(p_Ruta VARCHAR(100), p_NombreArchivo VARCHAR(100))
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

	---INICIALIZACIONES
	LET sCadSql				= "";
	LET bBandera			= "F";
	LET sLinea				= "";

BEGIN

	ON EXCEPTION
        SET iSqlErr, iSamErr
        IF iSqlErr <> 0 THEN
            LET v_cod_ret = iSqlErr;
        END IF;
		
        RETURN v_cod_ret,NULL;
    END EXCEPTION;

	
	--SET DEBUG FILE TO "/tmp/sp_BuscarArchivo.out";
	--TRACE ON;

	LET v_cod_ret = '00000';
	
	IF (p_Ruta = "") OR (p_Ruta  IS NULL) THEN
		RETURN "00450", NULL;	
	END IF
	
	IF (p_NombreArchivo = "") OR (p_NombreArchivo  IS NULL) THEN
		RETURN "00451", NULL;	
	END IF
	
	--- BORRAR  LA TABLA DE TEMPORAL DE TRABAJO EN CASO DE QUE EXISTA
	IF EXISTS (SELECT tabname FROM systables WHERE tabname = 'con_tmp_busca_archivo') THEN	
		DROP TABLE con_tmp_busca_archivo;
	END IF
	
	--- CREAR LA TABLA DE TRABAJO
	CREATE TABLE con_tmp_busca_archivo
	(linea LVARCHAR(50));	

	--- CORRER EL COMANDO LS PARA OBTENER LOS NOMBRES QUE EXISTEN EN LAS CARPETAS Y METERLOS EN EL ARCHIVO buscar.bus
	LET sCadSql = 'ls ' || TRIM(p_Ruta) || ' > ' || TRIM(p_Ruta) || 'buscar.bus';
	SYSTEM sCadSql;

	--- GUARDA EL QUERY DEL LOAD EN EL ARCHIVO   *.SQL
	LET sCadSql = 'echo "LOAD FROM ' || TRIM(p_Ruta) || 'buscar.bus' || ' INSERT INTO con_tmp_busca_archivo" > '|| TRIM(p_Ruta) || 'EjecutaScripts_sp_con_BuscarArchivo.sql';
	SYSTEM sCadSql;	

	--- EJECUTA LAS INSTRUCCIONES QUE ESTAN DENTRO DEL ARCHIVO  *.SQL
	LET sCadSql = 'dbaccess intercard ' || TRIM(p_Ruta) || 'EjecutaScripts_sp_con_BuscarArchivo.sql';
	SYSTEM sCadSql;	

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;	
	--- CICLO PARA BARRER  LA TABLA DE TRABAJO Y BUSCAR EL NOMBRE DEL ARCHIVO
	FOREACH
		SELECT linea
		INTO sLinea
		FROM con_tmp_busca_archivo
		
		IF sLinea = p_NombreArchivo THEN
			LET bBandera = "V";
			EXIT FOREACH;
		END IF
	
	END FOREACH
	
	DROP TABLE con_tmp_busca_archivo;
	
	RETURN v_cod_ret, bBandera;

END;
--##############################################################################
--## Procedimiento   : sp_con_BuscarArchivo
--## Version         : 1.0
--## Creado por      : Mohamed Carreón 
--## Fecha creacion  : 4 Diciembre de 2009
--##Descripcion :  Procedimiento para buscar un archivo en una ruta proporcionada
--##############################################################################
END PROCEDURE;
CREATE PROCEDURE "informix".sp_conciladm_paserarchivo(p_Ruta VARCHAR(100), p_NombreArchivo VARCHAR(50))
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
	DEFINE vLinea				VARCHAR(50);	

	---INICIALIZACIONES
	LET sCadSql				= "";
	LET bBandera			= "F";
	LET sLinea				= "";
	LET vLinea 				= "";

BEGIN

	ON EXCEPTION
        SET iSqlErr, iSamErr
        IF iSqlErr <> 0 THEN
            LET v_cod_ret = iSqlErr;
        END IF;
		
        RETURN v_cod_ret,NULL;
    END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	--SET DEBUG FILE TO "/tmp/sp_conciladm_paserarchivo.out";
	--TRACE ON;

	LET v_cod_ret = '00000';
	
	IF (p_Ruta = "") OR (p_Ruta  IS NULL) THEN
		RETURN "00450", NULL;	
	END IF
	
	IF (p_NombreArchivo = "") OR (p_NombreArchivo  IS NULL) THEN
		RETURN "00451", NULL;	
	END IF
	
	IF EXISTS (SELECT tabname FROM systables WHERE tabname = 'con_tmp_find_file') THEN	
		DROP TABLE con_tmp_find_file;
	END IF
	
	--- CREAR LA TABLA DE TRABAJO
	CREATE TABLE con_tmp_find_file
	(linea LVARCHAR(50));	

    IF 	SUBSTR(p_NombreArchivo,0,8) = 'BCPLVND_' OR SUBSTR(p_NombreArchivo,0,8) = 'BCPLVNC_' OR SUBSTR(p_NombreArchivo,0,8) = 'BCPLVID_' OR SUBSTR(p_NombreArchivo,0,8) = 'BCPLVIC_' THEN 
	
		LET sCadSql = '[ -e ' || TRIM(p_Ruta) || '/' || TRIM(p_NombreArchivo) || ' ] && echo 1' ||  ' > '  || TRIM(p_Ruta) || '/' || 'parser.unl';
		SYSTEM sCadSql;	
		
		--- GUARDA EL QUERY DEL LOAD EN EL ARCHIVO   *.SQL
		LET sCadSql = 'echo "LOAD FROM ' || TRIM(p_Ruta) || '/' || 'parser.unl' || ' INSERT INTO con_tmp_find_file" > ' || TRIM(p_Ruta) || '/' || 'Exec_sp_conciladm_paserarchivo.sql';
		SYSTEM sCadSql;	
		
		--- EJECUTA LAS INSTRUCCIONES QUE ESTAN DENTRO DEL ARCHIVO  *.SQL
		LET sCadSql = 'dbaccess intercard ' || TRIM(p_Ruta) || '/' || 'Exec_sp_conciladm_paserarchivo.sql';
		SYSTEM sCadSql;	
	
		SELECT vlinea INTO vLinea FROM con_tmp_find_file;
		
		IF vLinea=0 OR vLinea IS NULL THEN
			RETURN '00451', NULL;
		END IF
		
		--- CORRER EL COMANDO LS PARA OBTENER LOS NOMBRES QUE EXISTEN EN LAS CARPETAS Y METERLOS EN EL ARCHIVO buscar.bus
		
		LET sCadSql = 'sed ' || '''s/|/I/g'' ' || TRIM(p_Ruta) || '/' || TRIM (p_NombreArchivo) || ' > ' || TRIM(p_Ruta) || '/' || TRIM (p_NombreArchivo) || '.prs';
		SYSTEM sCadSql;		
	
	    LET bBandera = 'V';	
	
	ELIF SUBSTR(p_NombreArchivo,0,10) = 'BCPL_ATMC_' OR SUBSTR(p_NombreArchivo,0,10) = 'BCPL_ATMD_'  THEN 
	
		LET sCadSql = '[ -e ' || TRIM(p_Ruta) || '/' || TRIM(p_NombreArchivo) || ' ] && echo 1' ||  ' > '  || TRIM(p_Ruta) || '/' || 'parserATM.unl';
		SYSTEM sCadSql;	
		
		--- GUARDA EL QUERY DEL LOAD EN EL ARCHIVO   *.SQL
		LET sCadSql = 'echo "LOAD FROM ' || TRIM(p_Ruta) || '/' || 'parserATM.unl' || ' INSERT INTO con_tmp_find_file" > ' || TRIM(p_Ruta) || '/' || 'Exec_sp_conciladm_paserarchivo1.sql';
		SYSTEM sCadSql;	
		
		--- EJECUTA LAS INSTRUCCIONES QUE ESTAN DENTRO DEL ARCHIVO  *.SQL
		LET sCadSql = 'dbaccess intercard ' || TRIM(p_Ruta) || '/' || 'Exec_sp_conciladm_paserarchivo1.sql';
		SYSTEM sCadSql;	
	
		SELECT vlinea INTO vLinea FROM con_tmp_find_file;
		
		IF vLinea=0 OR vLinea IS NULL THEN
			RETURN '00451', NULL;
		END IF
		
		--- CORRER EL COMANDO LS PARA OBTENER LOS NOMBRES QUE EXISTEN EN LAS CARPETAS Y METERLOS EN EL ARCHIVO buscar.bus
		
		LET sCadSql = 'sed ' || '''s/|/I/g'' ' || TRIM(p_Ruta) || '/' || TRIM (p_NombreArchivo) || ' > ' || TRIM(p_Ruta) || '/' || TRIM (p_NombreArchivo) || '.prst';
		SYSTEM sCadSql;		
	
	    LET bBandera = 'V';		
	
	END IF 
	
	RETURN v_cod_ret, bBandera;

END;
END PROCEDURE;
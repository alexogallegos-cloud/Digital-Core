CREATE PROCEDURE "informix".sp_subirarchivos(p_CodRuta CHAR(2), p_NombreArchivo VARCHAR(20))
RETURNING
	CHAR(5), ---cod_ret
	CHAR(50); ---descripcion

	---DECLARACIONES
    DEFINE v_cod_ret        CHAR(5);
    DEFINE iSqlErr          INTEGER;
    DEFINE iSamErr          INTEGER;
	DEFINE sRuta			CHAR(100);
	DEFINE sCadSql			CHAR(1000);
	DEFINE iPaso			SMALLINT;
	DEFINE cHora                      CHAR(8);
	DEFINE cFechaArchivoOUT			  CHAR(15);

	---INICIALIZACIONES
	LET v_cod_ret 			= '00000';	
	LET sRuta				= "";
	LET iPaso = 0;
	LET cHora               = TO_CHAR(EXTEND(CURRENT, HOUR TO SECOND),'%H:%M:%S');
	LET cFechaArchivoOUT    = YEAR(CURRENT::DATE)||LPAD(MONTH(CURRENT::DATE),2,'0')||LPAD(DAY(CURRENT::DATE),2,'0')||SUBSTR(cHora,1,2)||SUBSTR(cHora,4,2)||SUBSTR(cHora,7,2)||'_';


BEGIN

	ON EXCEPTION
        SET iSqlErr, iSamErr
        IF iSqlErr <> 0 THEN
            LET v_cod_ret = iSqlErr;
        END IF;
		
        RETURN v_cod_ret, NULL;
    END EXCEPTION;
	
	ON EXCEPTION IN(-668) SET iSqlErr
		IF iPaso NOT IN(3,4) THEN 
			LET v_cod_ret = iSqlErr;
			RETURN v_cod_ret, NULL;
		END IF;
	END EXCEPTION WITH RESUME;
			
	--SET DEBUG FILE TO "/tmp/has/sp_SubirArchivos.out";
	--TRACE ON;
		
	--- BORRAR  LA TABLA DE TEMPORAL DE TRABAJO EN CASO DE QUE EXISTA
	IF EXISTS (SELECT tabname FROM systables WHERE tabname MATCHES 'dom_tmp_trabajo') THEN
		DROP TABLE dom_tmp_trabajo;
	END IF
	
	--- CREAR LA TABLA DE TRABAJO
	CREATE TABLE dom_tmp_trabajo
	(linea LVARCHAR(1000));

	--- OBTIENE LA RUTA DONDE SE ENCUENTRA EL ARCHIVO 
	SELECT TRIM(valor)
	INTO sRuta
	FROM bdidomi: dom_parametros
	WHERE cod_param = p_CodRuta;
	
	LET iPaso = 1;
	LET sCadSql = 'echo "LOAD FROM ' || TRIM(sRuta) || p_NombreArchivo || ' INSERT INTO dom_tmp_trabajo" > '|| TRIM(sRuta)||TRIM(cFechaArchivoOUT)||'.sql';
	SYSTEM sCadSql;
	
	LET iPaso = 2;
	--Produccion
    LET sCadSql = '/ifxsif01/bin/dbaccess bdidomi ' || TRIM(sRuta)||TRIM(cFechaArchivoOUT)||'.sql > '||TRIM(sRuta)||TRIM(cFechaArchivoOUT)||'.out 2>&1';	
	
	--Desarrollo
	--LET sCadSql = '/informix/bin/dbaccess bdidomi ' || TRIM(sRuta)||TRIM(cFechaArchivoOUT)||'.sql > '||TRIM(sRuta)||TRIM(cFechaArchivoOUT)||'.out 2>&1';	
    SYSTEM sCadSql;
	
	LET iPaso = 3;
	LET sCadSql = 'rm ' || TRIM(sRuta) ||TRIM(cFechaArchivoOUT)||'.out';
	SYSTEM sCadSql;
	
	LET iPaso = 4;
	LET sCadSql = 'rm ' || TRIM(sRuta) ||TRIM(cFechaArchivoOUT)||'.sql';
	SYSTEM sCadSql;
	
END;
--##############################################################################
--## Procedimiento   : sp_SubirArchivos
--## Version         : 1.0
--## Creado por      : Mohamed CarreÃ³n 
--## Fecha creacion  : Julio de 2009
--##Descripcion :  Procedimiento para realizar la carga de los archivos que se reciben a las tablas de informix
--##############################################################################
END PROCEDURE;
CREATE PROCEDURE "informix".sp_carga_lista_archivos(p_Ruta VARCHAR(150))
RETURNING 	CHAR (06) as cod_ret,
		CHAR (80) as mensaje;
		
--	variables de retorno 
	DEFINE	cod_ret			CHAR (06);
	DEFINE	mensaje			CHAR (80);
	
--DEFINICION DE VARIABLES DE CONTROL DE ERRORES 
	DEFINE  SQL_ERR          INTEGER;   
	DEFINE  ERROR_INFO       VARCHAR(180);	
	DEFINE  ISAM_ERR         INTEGER;	
	
--VARIABLES DE PROCESO
	DEFINE	vsql			CHAR(500);
	DEFINE 	vpaso			INTEGER;
		

BEGIN
   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
      LET cod_ret    = SQL_ERR;
      LET mensaje  = ERROR_INFO || ' sp_infocoppel_recargarhis en paso ' || vpaso;	  
      RETURN cod_ret, mensaje;
   END EXCEPTION;		
	
	
	let cod_ret = '000000';
	let mensaje	= 'PROCESO EXITOSO';
	
	let vpaso = 1;
	IF (p_Ruta = "") OR (p_Ruta  IS NULL) THEN
		RETURN "000001", 'RUTA VACIA O NULA';
	END IF		
	
	let vpaso = 2;
	--- BORRAR  LA TABLA DE TEMPORAL DE TRABAJO EN CASO DE QUE EXISTA
	IF  (SELECT COUNT(tabname) FROM systables WHERE tabname = 'cop_tmp_busca_archivo') >  0 THEN
		DROP TABLE cop_tmp_busca_archivo;
	END IF

	let vpaso = 3;
	--- CREAR LA TABLA DE TRABAJO
	CREATE TABLE cop_tmp_busca_archivo
	(linea LVARCHAR(50));
	

	truncate table mi_rcda_infocoppel_recargarhis;
	
	let vpaso = 4;
	LET vsql = 'ls ' || TRIM(p_Ruta) || ' > ' || TRIM(p_Ruta) || 'lista_archivos.bus';
	SYSTEM vsql;
	
	let vpaso = 5;
	-- GUARDA EL QUERY DEL LOAD EN EL ARCHIVO   *.SQL
	LET vsql = 'echo "LOAD FROM ' || TRIM(p_Ruta) || 'lista_archivos.bus' || ' INSERT INTO cop_tmp_busca_archivo" > '|| TRIM(p_Ruta) || 'EjecutaScripts_sp_Domi_BuscarArchivo.sql';
	SYSTEM vsql;

	
	let vpaso = 6;
	--- EJECUTA LAS INSTRUCCIONES QUE ESTAN DENTRO DEL ARCHIVO  *.SQL
	LET vsql = 'dbaccess bdmis ' || TRIM(p_Ruta) || 'EjecutaScripts_sp_Domi_BuscarArchivo.sql';
	SYSTEM vsql;
	
	RETURN cod_ret , mensaje;
	
	
END
END PROCEDURE;
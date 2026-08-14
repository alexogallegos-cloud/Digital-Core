CREATE PROCEDURE "informix".sp_load_archivo_migracion(pRuta varchar(50),pArchivo varchar(50),pTabla varchar(50))
	RETURNING CHAR(5);
	
	--Variable pRuta: esta variable lleva la ruta donde se encuentra el archivo, ejemp:/tmp/,
	--Variable pArchivo: es el nombre del archivo a cargar.
	--Variable pTabla: Nombre de la tabla a cargar.
	--Ejemplo de la ejecucion del sp : execute procedure sp_load_archivo_migracion('/tmp/','registrosTablaUsuario.txt','bpi_usuario');
	
	--Declaración de variables
	DEFINE vsCodRet 	CHAR(5);
	DEFINE vSqlErr		INTEGER;
	DEFINE sCadSql		LVARCHAR(500);
	
	
	
	--Asignación de valores a variables
	LET vsCodRet = '00000';
	LET vSqlErr = 0;
	LET sCadSql="";
	
	--SET DEBUG FILE TO "/home/informix/sp_load_archivo_migracion.out";
	--TRACE ON;
	
	BEGIN
	
		ON EXCEPTION SET vSqlErr
	      IF vSqlErr <> 0 THEN
	            let vsCodRet = vSqlErr;
				RETURN vsCodRet;
	      END IF;
		
		
		END EXCEPTION;
		 	
		LET sCadSql ='echo "LOAD FROM '''|| TRIM(pRuta)||TRIM(pArchivo) || "'" ||' DELIMITER ''|'' INSERT INTO bdibpi:'|| TRIM(pTabla)||'" >'|| TRIM(pRuta) ||  'load_archivo.sql';
		SYSTEM sCadSql;
		
		LET sCadSql='';
		LET sCadSql='chmod 777 ' || TRIM(pRuta) || 'load_archivo.sql';
		SYSTEM sCadSql;
		
		LET sCadSql='';
		LET sCadSql='dbaccess bdibpi ' || TRIM(pRuta) || 'load_archivo.sql';
		SYSTEM sCadSql;
		
		LET sCadSql = 'rm ' || TRIM(pRuta) || 'load_archivo.sql';
		SYSTEM sCadSql;
		
		RETURN vsCodRet;
	END;
	
END PROCEDURE;
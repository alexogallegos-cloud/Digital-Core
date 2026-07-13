CREATE PROCEDURE "informix".sp_genarchivo_ctetsinhuella()
RETURNING VARCHAR(5) AS CodRetorno, 
		  VARCHAR(200) AS Mensaje;
		  
/*DEFINICION DE VARIABLES */		  
DEFINE viSqlError 		  INTEGER;
DEFINE vsCodRetorno       VARCHAR (5);
DEFINE vsMensaje          VARCHAR (200);

DEFINE cNumctecred		  CHAR (20);
DEFINE cNombreprodcred	  CHAR (40);

DEFINE cNumcteinv		  CHAR (20);
DEFINE cNombreprodinv	  CHAR (40);

DEFINE cFecha			  CHAR (20);
DEFINE cNumcte			  CHAR (20);
DEFINE cNombre			  CHAR (100);
DEFINE cNombreprod		  CHAR (40);

DEFINE cNombreArchivo 	  CHAR(100);
DEFINE cRutaArchivo 	  CHAR(100);

DEFINE cSQL1			  CHAR(500);
DEFINE cSQL				  CHAR(500);

DEFINE cStmt1			  CHAR(200);
DEFINE cStmt2			  CHAR(200);



LET viSqlError = 0;
LET vsCodRetorno = '00000';
LET vsMensaje = 'EL PROCESO SE EJECUTO CORRECTAMENTE';

LET cNumctecred = '';
LET cNombreprodcred	= '';

LET cNumcteinv = '';
LET cNombreprodinv	= '';

LET cSQL1 = '';
LET cSQL = '';


--SET DEBUG FILE TO "/tmp/ALAN/sp_genarchivo_ctetsinhuella.out";
--RACE ON;

BEGIN


	ON EXCEPTION SET viSqlError
		IF (viSqlError != 0) THEN
			LET vsCodRetorno = viSqlError;
			LET vsMensaje = 'ERROR DE EJECUCION';
			RETURN vsCodRetorno, vsMensaje;
		END IF;
	END EXCEPTION;
	
	TRUNCATE TABLE bdinteg:"informix".si_paso_archivocte;
	UPDATE statistics medium FOR TABLE bdinteg:"informix".si_paso_archivocte;
	
	IF EXISTS (SELECT dbsname,tabname FROM sysmaster:"informix".systabnames WHERE tabname = 'tmp_ctet_sinhue') THEN
	DROP TABLE tmp_ctet_sinhue;
	END IF;
	
	IF EXISTS (SELECT dbsname,tabname FROM sysmaster:"informix".systabnames WHERE tabname = 'tmp_genera_nombre') THEN
	DROP TABLE tmp_genera_nombre;
	END IF;
	
	SET ISOLATION TO DIRTY READ;
	/*CLIENTES TITULARES SIN HUELLA*/
	SELECT {+INDEX( bdinteg:"informix".si_cliente ix_client_3 )} CAST(fecha_alta AS CHAR(20)) fecha_alta,numcte,TRIM(nombre1)||' '||TRIM(nombre2)||' '||TRIM(apell_paterno)||' '||TRIM(apell_materno) AS nombre_cliente 
	FROM si_cliente 
	WHERE tipo_cliente = 1 AND numcte NOT IN(SELECT numcte FROM si_cte_huella)
	INTO TEMP tmp_ctet_sinhue WITH NO LOG;
	
	IF DBINFO('sqlca.sqlerrd2') = 0 THEN	
		LET vsCodRetorno = '00000';
		LET vsMensaje = 'NO EXISTEN CLIENTES TITULARES SIN HUELLA';
		RETURN vsCodRetorno, vsMensaje;
	END IF;
	
	
	/*CUENTA CAPTACION*/
		SELECT a.numcte,c.nombre FROM tmp_ctet_sinhue a INNER JOIN bdicheq: sc_maechq b ON a.numcte = b.num_cte INNER JOIN bdicheq:sc_producto c ON b.producto = c.producto
		WHERE b.status_cta = 1
		INTO TEMP tmp_genera_nombre WITH NO LOG;
	
	/*CREDITO REV*/
	--IFRS Se contempla el nuevo estatus E1 con Act 0 equivalente al estatus AA
	FOREACH
		SELECT a.numcte,c.nombre_prod 
		INTO cNumctecred,cNombreprodcred
		FROM tmp_ctet_sinhue a INNER JOIN bdicred: sd_maecred b ON a.numcte = b.numcte INNER JOIN bdicred:sd_definicion c ON b.num_producto = c.num_producto

		WHERE b.status_cred IN ('AA','E1')
		
		INSERT INTO tmp_genera_nombre VALUES (cNumctecred,cNombreprodcred);
	END FOREACH;
	
	/*CREDITO CRD*/
	--IFRS Se contempla el nuevo estatus E1 con Act 0 equivalente al estatus AA
	FOREACH
		SELECT a.numcte,c.nombre_prod 
		INTO cNumctecred,cNombreprodcred
		FROM tmp_ctet_sinhue a INNER JOIN bdicred: sd_maecredcrd b ON a.numcte = b.numcte INNER JOIN bdicred:sd_definicion c ON b.num_producto = c.num_producto

		WHERE b.status_cred IN ('AA','E1')
		
		INSERT INTO tmp_genera_nombre VALUES (cNumctecred,cNombreprodcred);
	END FOREACH;	
	
	/*INVERSIONES*/
	FOREACH
		SELECT a.numcte,c.nombre 
		INTO cNumcteinv, cNombreprodinv
		FROM tmp_ctet_sinhue a INNER JOIN bdinvers: sv_maeinv b ON a.numcte = b.num_cte INNER JOIN bdinvers: sv_instrum c ON b.cod_instrum = c.cod_instrum
		WHERE b.status_cta = 1
		
		INSERT INTO tmp_genera_nombre VALUES (cNumcteinv, cNombreprodinv);
		
	END FOREACH;

	/*GENERA ARCHIVO*/
	
	LET cStmt1 =  'Fecha_de_alta'||'|'||'N°_Cte'||'|'||'Nombre_Cte'||'|'||'Productos';
	INSERT INTO si_paso_archivocte (linea)
	VALUES(cStmt1); 
	
	FOREACH
		SELECT a.fecha_alta,a.numcte,a.nombre_cliente,NVL(b.nombre,'') AS producto 
		INTO cFecha,cNumcte,cNombre,cNombreprod
		FROM tmp_ctet_sinhue a INNER JOIN tmp_genera_nombre b ON a.numcte = b.numcte
		
		
		LET cStmt2 =  trim(cFecha)||'|'||trim(cNumcte)||'|'||trim(cNombre)||'|'||trim(NVL(cNombreprod,''));
		INSERT INTO si_paso_archivocte (linea)
		VALUES(cStmt2);
	END FOREACH;

		--Nombre del archivo
	LET cRutaArchivo = '/RESPALDOS/';
	LET cNombreArchivo = 'Reporte_de_clientes'||'.csv';
	
	LET cSQL1 = 'echo "UNLOAD TO '||TRIM(cRutaArchivo)||TRIM(cNombreArchivo)||' delimiter '||' SELECT linea FROM bdinteg:"informix".si_paso_archivocte ORDER BY secuencial" >'||TRIM(cRutaArchivo)||'Ejecuta_archivo_reporte.sql';
	SYSTEM cSQL1;

	LET cSQL='dbaccess bdinteg '||TRIM(cRutaArchivo)||'Ejecuta_archivo_reporte.sql';
	SYSTEM cSQL;
	
	DROP TABLE tmp_ctet_sinhue;
	DROP TABLE tmp_genera_nombre; 
	
	RETURN vsCodRetorno, vsMensaje;
END;
END PROCEDURE;
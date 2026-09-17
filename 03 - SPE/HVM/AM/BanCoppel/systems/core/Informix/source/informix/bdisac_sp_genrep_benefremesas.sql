CREATE PROCEDURE "informix".sp_genrep_benefremesas(pFechaIni DATE,pFechaFin DATE)
RETURNING
CHAR(5)		AS codigo_respuesta,
CHAR(80)	AS mensaje_respuesta;

	DEFINE iSqlErr              	INTEGER;
	DEFINE iIsamErr             	INTEGER;
	DEFINE cInfoErr             	CHAR(100);
	DEFINE cCodRet              	CHAR(5);
	DEFINE cMensaje					CHAR(80);		
	DEFINE cDescripcionGEN			CHAR(100);	
	DEFINE cMes						CHAR(2);
	DEFINE cAnio 					CHAR(4);
	DEFINE cRutaArch 				CHAR(100);
	DEFINE cStmt					LVARCHAR(1500);
	DEFINE cStatus					CHAR(1);
	
	DEFINE cRutaArchivo 			CHAR(100);
	DEFINE cNombreArchivo 			CHAR(100);
	DEFINE cSQL1			  		CHAR(500);
	DEFINE cSQL				  	 	CHAR(500);
	
	DEFINE dFechaIni 				DATE;
	DEFINE dFechaFin				DATE;
	
	LET cCodRet  					= "00000";
	LET cMensaje 					= 'PROCESO EXITOSO';		
	LET cDescripcionGEN		 		= 'Genera reporte anual de beneficiarios con mas de 3 remesas pagadas en 2 perdiodos de 6 meses';
	LET cAnio 					    = '';	
	LET cStatus						= '0';	
	
	LET cRutaArchivo 				= '';
	LET cNombreArchivo 				= '';
	LET cSQL1			  			= '';
	LET cSQL				  	 	= '';
	
	LET dFechaIni 					= '';
	LET dFechaFin					= '';
	
	--SET DEBUG FILE TO "/tmp/adrian/informix/sp_genrep_benefremesas.out";
	--TRACE ON;
	
	BEGIN
		ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				LET cMensaje = "ERROR";
				EXECUTE PROCEDURE bdisac:"informix".sp_sac_guardamensajeerror(iSqlErr, iIsamErr, cInfoErr, "sp_genrep_benefremesas");
                RETURN cCodRet, cMensaje;
			END IF;
		END EXCEPTION;		

		--OBTENER FECHAS DE LOS PERIODOS QUE SE VAN GENERAR
		LET dFechaIni = pFechaIni - 1 UNITS YEAR;
		LET dFechaIni = MDY(07,01,YEAR(dFechaIni));				
		LET dFechaFin = MDY(01,01,YEAR(pFechaFin));		
		
		IF NOT EXISTS (SELECT * FROM bdisac:"informix".sac_procesos_jobs where proceso='INS_GEN_BENREM' and fecha_proceso = pFechaFin) THEN								
			--INSERTA EN BITACORA
			EXECUTE PROCEDURE bdisac:"informix".sp_bitacoraspj (0, 'INS_GEN_BENREM', pFechaFin, '0', 'informix', 'sp_genrep_benefremesas', cDescripcionGEN);	
		ELSE
			SELECT status 
			INTO cStatus
			FROM bdisac:"informix".sac_procesos_jobs 
			WHERE proceso='INS_GEN_BENREM' and fecha_proceso = pFechaFin;
			IF cStatus = '0' THEN
				DELETE FROM bdisac:"informix".sac_benefremesas WHERE marca = 'AAA' AND fecha = dFechaIni;
			END IF;
		END IF;
		
		--SE EJECUTA SOLO SI NO HAY REGISTRO EXITOSO
		IF cStatus = '0' THEN		
				--Nombre del archivo
--				LET cRutaArchivo = '/RESPALDOS/';
				LET cRutaArchivo = '/RESPALDOSNEW/';
				LET cNombreArchivo = 'BENEFREMESASaaaa.cvs';
				
				LET cAnio = LPAD(YEAR(pFechaFin - 1 UNITS YEAR),4,'0');
				
				LET cNombreArchivo = REPLACE(cNombreArchivo,'aaaa',cAnio);

				INSERT INTO bdisac:"informix".sac_benefremesas (fecha,marca,linea,fecha_insert)
				VALUES(dFechaIni,'AAA','MARCA|NOMBRE DEL BENEFICIARIO|CIUDAD|ESTADO|CELULAR 1|CELULAR 2|CELULAR 3|NUMERO TOTAL DE REMESAS|MONTO TOTAL DE REMESAS',current);
				
				TRUNCATE TABLE bdisac:"informix".sac_benefrem_tmp;
				insert into bdisac:"informix".sac_benefrem_tmp
				SELECT marca,linea 
				FROM bdisac:"informix".sac_benefremesas 
				WHERE fecha = dFechaIni
				OR fecha = dFechaFin;
				
				LET cSQL1 = 'echo "UNLOAD TO '||TRIM(cRutaArchivo)||TRIM(cNombreArchivo)||' DELIMITER '|| "'|'" ||' SELECT linea FROM bdisac:"informix".sac_benefrem_tmp ORDER BY marca;" >'||TRIM(cRutaArchivo)||'Ejecuta_repbenefrem.sql';
				SYSTEM cSQL1;

				LET cSQL='dbaccess bdisac '||TRIM(cRutaArchivo)||'Ejecuta_repbenefrem.sql';
				SYSTEM cSQL;
				
				--CREAR ARCHIVO TEMPORAL
				LET cSQL = '';
				LET cSQL = 'cp ' || TRIM(cRutaArchivo) || TRIM(cNombreArchivo)  ||' '|| TRIM(cRutaArchivo)|| TRIM(cNombreArchivo) || '.temp';
				SYSTEM cSQL;	

				--BORRAR ARCHIVO
				LET cSQL = '' ;
				LET cSQL = 'rm ' || TRIM(cRutaArchivo) || TRIM(cNombreArchivo);
				SYSTEM cSQL;						
				
				--CREAR ARCHIVO SUBSTITUYENDO \
				LET cSQL = '';
				LET cSQL = "sed 's/\\//g' " || TRIM(cRutaArchivo) || TRIM(cNombreArchivo) || '.temp' || " > " || TRIM(cRutaArchivo) || TRIM(cNombreArchivo);
				SYSTEM cSQL;
				
				--BORRAR ARCHIVO TEMPORAL
				LET cSQL = '' ;
				LET cSQL = 'rm ' || TRIM(cRutaArchivo) || TRIM(cNombreArchivo) || '.temp';
				SYSTEM cSQL;
				
				LET cSQL = '' ;
				LET cSQL = 'rm ' ||TRIM(cRutaArchivo)||'Ejecuta_repbenefrem.sql';
				SYSTEM cSQL;

				set pdqpriority 0;
				UPDATE STATISTICS MEDIUM FOR TABLE bdisac:"informix".sac_benefremesas;		
						
				--ACTUALIZA STATUS DE INSERTA INFO
				EXECUTE PROCEDURE bdisac:"informix".sp_bitacoraspj (1, 'INS_GEN_BENREM', pFechaFin, '1', 'informix', 'sp_genrep_benefremesas', cDescripcionGEN);
		END IF;
		
		RETURN cCodRet, cMensaje;

	END;
END PROCEDURE;
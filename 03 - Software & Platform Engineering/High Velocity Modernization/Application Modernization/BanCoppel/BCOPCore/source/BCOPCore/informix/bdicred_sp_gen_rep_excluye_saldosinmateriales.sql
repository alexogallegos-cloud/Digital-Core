CREATE PROCEDURE "informix".sp_gen_rep_excluye_saldosinmateriales()
RETURNING CHAR(5) AS cod_ret,
	      CHAR(15) AS reg_procesados,
		  CHAR(15) AS reg_excluidos,
		  CHAR(17) AS reg_no_excluidos,
		  CHAR(100) AS mensaje 
--DECLARACIÃN Y DEFINICIÃN DE VARIABLES
	DEFINE pNombreArchivoLeer	CHAR(100);
	DEFINE vRutaArchivo 		CHAR(100);
	DEFINE vNombreArchivo 		CHAR(18);
	DEFINE vNombreArchivo2 		CHAR(22);
	DEFINE vCommand				CHAR(2000);
	DEFINE vNumCredito			CHAR(20);
	DEFINE vEmpresa 			CHAR(3);
	DEFINE vCodRet		    	CHAR(5);
	DEFINE vCodRet2				CHAR(5);
	DEFINE vMensaje		    	CHAR(80);
	DEFINE vRegProcesados   	CHAR(15);
	DEFINE vRegExcluidos		CHAR(15);
	DEFINE vRegNoExcluidos  	CHAR(17);
	DEFINE vContadorExcluidos 	INTEGER;
	DEFINE vContadorProcesados 	INTEGER;
	DEFINE vContador2			INTEGER;
	DEFINE vSQLcommand			CHAR(100);
	DEFINE vMensaje2			CHAR(50);
	DEFINE iSqlErr 				INTEGER;
	DEFINE iIsamErr				INTEGER;
	DEFINE cErrorInfo       	CHAR(80);
	
	LET pNombreArchivoLeer	= 'archivo_cuentas_leer.unl';
	LET vNombreArchivo		= 'exclusion_sdosinma';
	LET vNombreArchivo2		= 'exclusion_no_sdosinma';
	LET vRutaArchivo		= ''; --/informix/roman/archivoscartera/
	LET vCommand			= '';
	LET vNumCredito			= '';
	LET vEmpresa			= '001';
	LET vContadorExcluidos	= 0;
	LET vContadorProcesados = 0;
	LET vContador2 			= 0;
	LET vCodRet2 			= '00000';
	LET vSQLcommand 		= '';
	LET vMensaje2 			= 'PROCESO EXITOSO';
	LET iSqlErr 			= 0;
	LET iIsamErr			= 0;
	LET cErrorInfo			= '';
	LET vRegProcesados 		= 'PROCESADOS ';
	LET vRegExcluidos 		= 'EXCLUIDOS ';
	LET vRegNoExcluidos 	= 'NO EXCLUIDOS ';
	
	BEGIN
		ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
			IF iSqlErr != 0 THEN
				LET vCodRet2 = iSqlErr;
				LET vRegExcluidos =  TRIM(vRegExcluidos) || ' ' || vContadorExcluidos;
				LET vRegNoExcluidos = TRIM(vRegNoExcluidos) || ' ' || vContador2;
				LET vRegProcesados = TRIM(vRegProcesados) || ' ' || vContadorProcesados;
				LET vMensaje2 = 'OcurriÃ³ un error en el sp';
				RETURN vCodRet2, vRegProcesados, vRegExcluidos, vRegNoExcluidos, vMensaje2;
			END IF;
		END EXCEPTION;
	
		SET ISOLATION TO dirty READ;
		SET LOCK MODE TO WAIT 3;
		
		--SET DEBUG FILE TO "/informix/roman/archivoscartera/sp_gen_rep_excluye_saldosinmateriales.out";
		--TRACE ON;
		
		-- Ruta donde se encuentran los archivos.
		SELECT trim(valor) into vRutaArchivo FROM sd_param WHERE cod_param = '49';
		
		--Se crea una tabla fÃ­sica donde se guardarÃ¡n las cuentas leÃ­das desde el arch ivo
		LET vSQLcommand = 'CREATE TABLE bdicred:cuentas_excluye (num_credito CHAR(20)) EXTENT SIZE 500';
		EXECUTE IMMEDIATE TRIM(vSQLcommand);
		
		--Se crea una segunda tabla para insertar las cuentas que no hayan sido excluidas
		LET vSQLcommand = 'CREATE TABLE bdicred:cuentas_no_excluye (num_credito CHAR(20), cod_err CHAR(5)) EXTENT SIZE 500';
		EXECUTE IMMEDIATE TRIM(vSQLcommand); 
		
		--Leemos el archivo e insertamos las cuentas en la tabla anterior.
		LET vCommand = ' echo "FILE '||TRIM(vRutaArchivo) || TRIM(pNombreArchivoLeer) || ' DELIMITER '' '' 1; INSERT INTO cuentas_excluye; " > '|| TRIM(vRutaArchivo) ||'queryCargaExc.sql';
        system vCommand;
		
		LET vCommand = '';
		LET vCommand = 'dbload -d bdicred -c '||TRIM(vRutaArchivo)||'queryCargaExc.sql -l '||TRIM(vRutaArchivo)||'cuentas_excluye.log -n 1000 -k';
        system vCommand;
		
		--Consultamos la tabla para recorrer las cuentas leidas
		FOREACH
			SELECT num_credito INTO vNumCredito FROM bdicred:cuentas_excluye
			
			EXECUTE PROCEDURE bdicred:"informix".sp_excluye_saldosinmateriales(vEmpresa, vNumCredito) 
			INTO vCodRet, vMensaje;
			
			IF vCodRet = '00000' THEN
				LET vContadorExcluidos = vContadorExcluidos + 1;
			ELSE
				INSERT INTO bdicred:cuentas_no_excluye VALUES (vNumCredito, vCodRet);
			END IF;
			
			LET vContadorProcesados = vContadorProcesados + 1;
		END FOREACH;
		
		IF vContadorProcesados = 0 THEN
			LET vMensaje2 = 'El archivo se encuentra vacio';
			LET vCodRet2 = '00002';
			
			LET vSQLcommand = '';
			LET vSQLcommand = 'DROP TABLE bdicred:cuentas_excluye';
			EXECUTE IMMEDIATE TRIM(vSQLcommand);
			
			LET vSQLcommand = '';
			LET vSQLcommand = 'DROP TABLE bdicred:cuentas_no_excluye';
			EXECUTE IMMEDIATE TRIM(vSQLcommand);
			
			LET vRegExcluidos = TRIM(vRegExcluidos) || ' 0';
			LET vRegNoExcluidos = TRIM(vRegNoExcluidos) || ' 0';
			LET vRegProcesados = TRIM(vRegProcesados) || ' ' || vContadorProcesados;
			
			RETURN vCodRet2, vRegProcesados, vRegExcluidos, vRegNoExcluidos, vMensaje2;
		END IF;
		
		--Verificamos que la segunda tabla tenga cuentas no excluidas
		SELECT COUNT(num_credito) INTO vContador2 FROM bdicred:cuentas_no_excluye;
		
		IF vContador2 > 0 THEN
			LET vCommand  = 'echo "UNLOAD TO ' || TRIM(vRutaArchivo) || TRIM(vNombreArchivo2) || "_1.txt DELIMITER " ||  "'" || '|' || "'" || '" > ' || TRIM(vRutaArchivo) || TRIM(vNombreArchivo2) || '.sql;';
			system TRIM(vCommand);
		
			LET vCommand = 'echo "select * from bdicred:cuentas_no_excluye; " >> ' || TRIM(vRutaArchivo) ||  TRIM(vNombreArchivo2) || '.sql';
			SYSTEM TRIM(vCommand);
			
			/*LET vCommand = 'chmod 777 ' || TRIM(vRutaArchivo) || TRIM(vNombreArchivo2) || '.sql';
			SYSTEM TRIM(vCommand);*/
								
			LET vCommand = 'dbaccess bdicred ' || TRIM(vRutaArchivo) ||  TRIM(vNombreArchivo2) || '.sql';
			SYSTEM TRIM(vCommand);
			
			SYSTEM "sed 's/|$//g' " || TRIM(vRutaArchivo) || TRIM(vNombreArchivo2) || "_1.txt > " || TRIM(vRutaArchivo) || TRIM(vNombreArchivo2) || ".txt";
			SYSTEM 'rm ' || TRIM(vRutaArchivo) || TRIM(vNombreArchivo2) || "_1.txt";
		END IF;
		
	    LET vSQLcommand = 'DROP TABLE bdicred:cuentas_excluye';
		EXECUTE IMMEDIATE TRIM(vSQLcommand);
		
		LET vSQLcommand = 'DROP TABLE bdicred:cuentas_no_excluye';
		EXECUTE IMMEDIATE TRIM(vSQLcommand);
		
		-- Eliminacion de archivos.
		LET vCommand = '';
        LET vCommand = "rm "||TRIM(vRutaArchivo)||'queryCargaExc.sql';
        SYSTEM vCommand;
		
		LET vCommand = '';
        LET vCommand = "rm "||TRIM(vRutaArchivo)||'cuentas_excluye.log';
        SYSTEM vCommand;
		
		-- Contador
		LET vRegExcluidos =  TRIM(vRegExcluidos) || ' ' || vContadorExcluidos;
		LET vRegNoExcluidos = TRIM(vRegNoExcluidos) || ' ' || vContador2;
		LET vRegProcesados = TRIM(vRegProcesados) || ' ' || vContadorProcesados;
		
		RETURN vCodRet2, vRegProcesados, vRegExcluidos, vRegNoExcluidos, vMensaje2;
	END
END PROCEDURE
	
;
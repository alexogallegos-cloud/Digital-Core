CREATE PROCEDURE "informix".sp_generar_arch_cta_nom()
	RETURNING CHAR(5) AS codret;
	
	DEFINE cCodRet				 CHAR(5);
	DEFINE sqlErr				 INTEGER;
	DEFINE cRuta 				 CHAR(255);
	DEFINE cNombreArch 			 CHAR(255);
	DEFINE cFecha 				 CHAR(8);
	DEFINE vsSQL 				 LVARCHAR (32739);
	DEFINE sNombreArchivoFinal   VARCHAR(100);
	DEFINE sPreNomArchivoFinal 	 VARCHAR(100);
	DEFINE sAntNomArchivoFinal 	 VARCHAR(100);
	DEFINE sAnterNomArchivoFinal VARCHAR(100);
	DEFINE vFechaAct			 DATE;

	LET cCodRet 		    	= '00001';
	LET sqlErr 			    	= 0; 
	LET cRuta					= '';
	LET cNombreArch  			= '';
	LET sNombreArchivoFinal 	= '';
	LET cFecha					= '';
	LET vsSQL 					= '';
	LET sPreNomArchivoFinal 	= '';
	LET sAntNomArchivoFinal 	= '';
	LET sAnterNomArchivoFinal	= '';
	LET vFechaAct				= today -2;
	
	BEGIN

		ON EXCEPTION SET sqlErr
			IF sqlErr <> 0 THEN
				LET cCodRet = sqlErr;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO "/home/sysifx/AleBarranco/sp_generar_arch_cta_nom.out";
		--TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;	
		
		--Ruta del archivo
		SELECT TRIM(valor)
		INTO cRuta
		FROM "informix".sn_parametros
		WHERE id = 'RUTA_ARCHIVO';

		--Nombre del archivo
		SELECT TRIM(valor) 
		INTO cNombreArch
		FROM "informix".sn_parametros
		WHERE id = 'NOMBRE_ARCHIVO';
		
		LET cFecha = YEAR(vFechaAct)||""||LPAD(MONTH(vFechaAct),2,0)||""||LPAD(DAY(vFechaAct),2,0);
		
		LET cNombreArch = REPLACE(cNombreArch,'YYYYMMDD',cFecha);
		
		LET sNombreArchivoFinal = TRIM(cRuta)|| TRIM(cNombreArch);
		
		LET sPreNomArchivoFinal = TRIM(cRuta)||'ctanombatch.unl';
		LET sAntNomArchivoFinal = TRIM(cRuta)||'ctanombatch2_batch.unl';
		LET sAnterNomArchivoFinal = TRIM(cRuta)||'ctanombatch3_batch.unl';
		
		LET vsSQL = ' echo "UNLOAD TO ' ||  TRIM(cRuta)|| 'movimientos_cta_nom.unl' || ' DELIMITER ' || '''|''' || 
						' SELECT id, TRIM(numcte), TRIM(numcta), estatus, cuentanomina, estatuscuentanomina, fechaaltadenomina, fechabajadenomina, empresagc, grupobeneficios, periodicidad, tipocliente, estatuspeticioncliente, proceso,fechaultimamodificacion,fechacreacion,0'||
						' FROM bdiadminnomina:"informix".sn_cte_cta_nomina '||
						' " > ' || TRIM(cRuta)|| 'movimientos_cta_nom.sql';
		SYSTEM vsSQL;
		LET vsSQL =  "chmod 777 "||sNombreArchivoFinal||" > "|| TRIM(cRuta)|| "movimientos_cta_nom.sql";
		LET vsSQL = '';
		LET vsSQL = 'dbaccess bdiadminnomina ' || TRIM(cRuta)|| 'movimientos_cta_nom.sql';
		SYSTEM vsSQL;
		
		LET vsSQL = '';
		LET vsSQL =  "sed 's/\\//g' " || TRIM(cRuta)|| "movimientos_cta_nom.unl > " || sPreNomArchivoFinal;
		SYSTEM vsSQL;					
		LET vsSQL = '';					
		LET vsSQL = '';
		LET vsSQL =  "sed 's/|$//g' " || TRIM(cRuta)|| "ctanombatch.unl > " || sAntNomArchivoFinal;
		SYSTEM vsSQL;
		-- SE AGREGA ARCHIVO DE PASO PARA AGREGAR ESPACIOS EN BLANCO A LOS CAMPOS VACIOS
		LET vsSQL = '';
		LET vsSQL =  "sed 's/||/| |/g' " || TRIM(cRuta)|| "ctanombatch2_batch.unl > " || sAnterNomArchivoFinal;
		SYSTEM vsSQL;				
		LET vsSQL = '';
		LET vsSQL =  "sed 's/||/| |/g' " || TRIM(cRuta)|| "ctanombatch3_batch.unl > " || sNombreArchivoFinal;
		SYSTEM vsSQL;	
		--
		LET vsSQL = '';
		LET vsSQL =  "chmod 777 "||sNombreArchivoFinal||" > "|| TRIM(cRuta)|| "cuentanomina_batch.txt";
		SYSTEM vsSQL;
		LET vsSQL = '';
		LET vsSQL =  "rm " || TRIM(cRuta)|| "cuentanomina_batch.txt";
		SYSTEM vsSQL;
		LET vsSQL = '';
		LET vsSQL =  "rm " || TRIM(cRuta)|| "ctanombatch2_batch.unl";
		SYSTEM vsSQL;
		LET vsSQL = '';					
		LET vsSQL =  "rm " || TRIM(cRuta)|| "ctanombatch3_batch.unl";
		SYSTEM vsSQL;
		LET vsSQL = '';
		LET vsSQL =  "rm " || TRIM(cRuta)|| "ctanombatch.unl";
		SYSTEM vsSQL;
		LET vsSQL = '';
		LET vsSQL =  "rm " || TRIM(cRuta)|| "movimientos_cta_nom.unl";										
		SYSTEM vsSQL;
		LET vsSQL = '';
		LET vsSQL =  "rm " || TRIM(cRuta)|| "movimientos_cta_nom.sql";										
		SYSTEM vsSQL;
		
		LET cCodRet = '00000';
		RETURN cCodRet;

	END;	
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se crea procedimiento para extraer informacion de la tabla sn_cte_cta_nomina y guardarla en un archivo de texto plano',
'AUTOR: Alejandra Barranco',
'FECHA DE CREACION: 27 de Septiembre 2022',
'VERSION: 1.0.0',
'BD: bdiadminnomina',
'SOLICITO: Fabio Torres Esquer' ;
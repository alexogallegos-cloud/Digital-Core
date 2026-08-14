CREATE PROCEDURE "informix".sp_generar_arch_mov_spei()
	RETURNING CHAR(5) AS codret;

	DEFINE cCodRet				 CHAR(5);
	DEFINE sqlErr				 INTEGER;
	DEFINE cRutaArc 			 CHAR(255);
	DEFINE cRuta 			 CHAR(255);
	DEFINE cFecha 				 CHAR(8);
	DEFINE vsSQL 				 LVARCHAR (32739);
	DEFINE sNombreArchivoFinal   VARCHAR(100);
	DEFINE sPreNomArchivoFinal 	 VARCHAR(100);
	DEFINE sAntNomArchivoFinal 	 VARCHAR(100);
	DEFINE sAnterNomArchivoFinal VARCHAR(100);
	DEFINE vFechaAct			 DATE;
	
	LET cCodRet 		    	= '00001';
	LET sqlErr 			    	= 0; 
	LET cRutaArc				= '';
	LET cRuta  			= '';
	LET cFecha					= '';
	LET vsSQL 					= '';
	LET sNombreArchivoFinal 	= '';
	LET sPreNomArchivoFinal 	= '';
	LET sAntNomArchivoFinal 	= '';
	LET sAnterNomArchivoFinal	= '';
	LET vFechaAct				= today-2;
	
	
BEGIN

		ON EXCEPTION SET sqlErr
			IF sqlErr <> 0 THEN
				LET cCodRet = sqlErr;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;
	
		--SET DEBUG FILE TO "/home/sysifx/AleBarranco/sp_generar_arch_mov_spei.out";
		--TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;	
		
		--Ruta del archivo
		SELECT TRIM(valor)
		INTO cRutaArc
		FROM "informix".sn_parametros
		WHERE id = 'RUTA_ARCHIVO';

		--Nombre del archivo
		SELECT TRIM(valor) 
		INTO cRuta
		FROM "informix".sn_parametros
		WHERE id = 'NOMBRE_ARCHIVO_MOV';
		
		LET cFecha = YEAR(vFechaAct)||""||LPAD(MONTH(vFechaAct),2,0)||""||LPAD(DAY(vFechaAct),2,0);
		
		LET cRuta = REPLACE(cRuta,'YYYYMMDD',cFecha);
		
		LET sNombreArchivoFinal = TRIM(cRuta)|| TRIM(cRuta);
		
		LET sNombreArchivoFinal = TRIM(cRutaArc)|| TRIM(cRuta);
		LET sPreNomArchivoFinal = TRIM(cRutaArc)||'speibatch.unl';
		LET sAntNomArchivoFinal = TRIM(cRutaArc)||'speibatch2_batch.unl';
		LET sAnterNomArchivoFinal = TRIM(cRutaArc)||'speibatch3_batch.unl';	
		
		LET vsSQL = ' echo "UNLOAD TO ' ||  TRIM(cRutaArc)|| 'movimientos_spei.unl' || ' DELIMITER ' || '''|''' || 
						' SELECT mnyimporte,cvecesifbcoord, TRIM(vchrconceptopago2), dtfechavalor, dtfechacaptura, TRIM(vchrclaverastreo),TRIM(vchrcuentachq), TRIM(vchrnumctechq), TRIM(vchrtransacc) '||
						' FROM bdispei:"informix".tblhistabono ;'|| -- 'where dtfechacaptura = ' || vFechaAct ||
						' " > ' || TRIM(cRutaArc)|| 'movimientos_spei.sql';
		SYSTEM vsSQL;
		LET vsSQL =  "chmod 777 "||sNombreArchivoFinal||" > "|| TRIM(cRutaArc)|| "movimientos_spei.sql";
		LET vsSQL = '';
		LET vsSQL = 'dbaccess bdispei ' || TRIM(cRutaArc)|| 'movimientos_spei.sql';
		SYSTEM vsSQL;
		
		LET vsSQL = '';
		LET vsSQL =  "sed 's/\\//g' " || TRIM(cRutaArc)|| "movimientos_spei.unl > " || sPreNomArchivoFinal;
		SYSTEM vsSQL;					
		LET vsSQL = '';					
		LET vsSQL = '';
		LET vsSQL =  "sed 's/|$//g' " || TRIM(cRutaArc)|| "speibatch.unl > " || sAntNomArchivoFinal;
		SYSTEM vsSQL;
		-- SE AGREGA ARCHIVO DE PASO PARA AGREGAR ESPACIOS EN BLANCO A LOS CAMPOS VACIOS
		LET vsSQL = '';
		LET vsSQL =  "sed 's/||/| |/g' " || TRIM(cRutaArc)|| "speibatch2_batch.unl > " || sAnterNomArchivoFinal;
		SYSTEM vsSQL;				
		LET vsSQL = '';
		LET vsSQL =  "sed 's/||/| |/g' " || TRIM(cRutaArc)|| "speibatch3_batch.unl > " || sNombreArchivoFinal;
		SYSTEM vsSQL;	
		--
		LET vsSQL = '';
		LET vsSQL =  "chmod 777 "||sNombreArchivoFinal||" > "|| TRIM(cRutaArc)|| "movimientos_spei_batch.txt";
		SYSTEM vsSQL;
		LET vsSQL = '';
		LET vsSQL =  "rm " || TRIM(cRutaArc)|| "movimientos_spei_batch.txt";
		SYSTEM vsSQL;
		LET vsSQL = '';
		LET vsSQL =  "rm " || TRIM(cRutaArc)|| "speibatch2_batch.unl";
		SYSTEM vsSQL;
		LET vsSQL = '';					
		LET vsSQL =  "rm " || TRIM(cRutaArc)|| "speibatch3_batch.unl";
		SYSTEM vsSQL;
		LET vsSQL = '';
		LET vsSQL =  "rm " || TRIM(cRutaArc)|| "speibatch.unl";
		SYSTEM vsSQL;
		LET vsSQL = '';
		LET vsSQL =  "rm " || TRIM(cRutaArc)|| "movimientos_spei.unl";										
		SYSTEM vsSQL;
		LET vsSQL = '';
		LET vsSQL =  "rm " || TRIM(cRutaArc)|| "movimientos_spei.sql";										
		SYSTEM vsSQL;
		
		LET cCodRet = '00000';
		RETURN cCodRet;

	END;	
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se crea procedimiento para extraer informacion de la tabla tblhistabono y guardarla en un archivo de texto plano',
'AUTOR: Alejandra Barranco',
'FECHA DE CREACION: 27 de Septiembre de 2022',
'VERSION: 1.0.0',
'BD: bdiadminnomina',
'SOLICITO: Fabio Torres Esquer';
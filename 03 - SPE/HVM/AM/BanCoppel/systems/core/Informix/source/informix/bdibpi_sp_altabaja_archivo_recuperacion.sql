CREATE PROCEDURE "informix".sp_altabaja_archivo_recuperacion(pNombreArchivo CHAR(40),
																	pNumSolicitud CHAR(10),
																	pNumCte CHAR(9),
																	pNumSerial CHAR(9),
																	pOpcion CHAR(1))
RETURNING CHAR(5),CHAR(20);

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Creador: Manuel Ramos Figueroa
-- Objetivo: Registra y elimina el nombre de archivo de recuperacion del proceso de asignacion masiva de tokens,
--			para procesarlos antes de realizar de nuevo el proceso en caso de haber ocurrido un problema.
-- Solicitó: Walber Castro
-- Fecha: 05/02/2013
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	--DECLARACION DE VARIABLES
	DEFINE cCod_Ret			CHAR(5);
	DEFINE sql_err 			INTEGER;
	DEFINE cMensaje			CHAR(20);
	DEFINE cNombreArchivo	CHAR(40);
		
	--INICIALIZAR VALORES A VARIABLES;
	LET cCod_Ret='00000';
	LET cMensaje='PROCESO EXITOSO';
	LET cNombreArchivo = 0;
	
	--SET DEBUG FILE TO "/informix/sp_altabaja_archivo_recuperacion.out";
	--TRACE ON;

	BEGIN
		ON EXCEPTION SET sql_err
		  IF sql_err <> 0 THEN
				let cCod_Ret = sql_err;
				RETURN cCod_Ret, 'PROCESO FALLIDO';
		  END IF ;
		END EXCEPTION ;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF (pOpcion = '1') THEN
			INSERT INTO bdibpi:"informix".tkn_archivosadmtoken (nombre, intentos) VALUES (pNombreArchivo, '0'); 
		ELIF (pOpcion = '2') THEN
			IF EXISTS (SELECT nombre FROM bdibpi:"informix".tkn_archivosadmtoken WHERE nombre = pNombreArchivo) THEN
				DELETE FROM bdibpi:"informix".tkn_archivosadmtoken WHERE nombre = pNombreArchivo; 
				DELETE FROM bdibpi:"informix".tkn_archivosadmtoken_detalle WHERE nombre = pNombreArchivo; 
			ELSE
				LET cCod_Ret='00002';
				LET cMensaje='NOMBRE INVALIDO';
			END IF;
		ELIF (pOpcion = '3') THEN
			SELECT nombre
			INTO cNombreArchivo
			FROM bdibpi:"informix".tkn_archivosadmtoken WHERE nombre = pNombreArchivo;
			
			IF TRIM(cNombreArchivo) <> '' THEN
				INSERT INTO bdibpi:"informix".tkn_archivosadmtoken_detalle (nombre, numsolicitud, numcte, numserial) VALUES (cNombreArchivo, pNumSolicitud, pNumCte, pNumSerial);
			ELSE
				LET cCod_Ret='00003';
				LET cMensaje='NOMBRE INVALIDO';
			END IF;
		ELSE
			LET cCod_Ret='00001';
			LET cMensaje='OPCION INVALIDA';
		END IF;	
		
		RETURN cCod_Ret,cMensaje;
	END;
END PROCEDURE;
CREATE PROCEDURE "informix".sp_obtenerarchivo_recuperacion(pNombreArchivo CHAR(40) ,pOpcion CHAR(1))
RETURNING CHAR(5),CHAR(40),CHAR(10),CHAR(9),CHAR(9);

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Creador: Manuel Ramos Figueroa
-- Objetivo: Obtiene los nombres de archivos de recuperacion del proceso de asignacion masiva de tokens.
-- Solicitó: Walber Castro
-- Fecha: 05/02/2013
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	--DECLARACION DE VARIABLES
	DEFINE cCod_Ret 		CHAR(5);
	DEFINE sql_err 			INTEGER;
	DEFINE cNombreArchivo	CHAR(40);
	DEFINE cNumSolicitud	CHAR(10);
	DEFINE cNumCte			CHAR(9);
	DEFINE cNumSerial		CHAR(9);
	DEFINE cIntentos		INTEGER;
	DEFINE cMensaje			CHAR(20);
		
	--INICIALIZAR VALORES A VARIABLES
	LET cCod_Ret='00000';
	LET cNombreArchivo='';
	LET cNumSolicitud='';
	LET cNumCte='';
	LET cNumSerial='';
	LET cIntentos=0;
	LET cMensaje='';
	
	--SET DEBUG FILE TO "/informix/sp_obtenerarchivo_recuperacion.out";
	--TRACE ON;

	BEGIN
		ON EXCEPTION SET sql_err
		  IF sql_err <> 0 THEN
				let cCod_Ret = sql_err;
				RETURN cCod_Ret,'','','','';
		  END IF ;
		END EXCEPTION ;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF (pOpcion = '1') THEN
			IF EXISTS (SELECT nombre FROM bdibpi:"informix".tkn_archivosadmtoken) THEN
				FOREACH
					SELECT nombre, intentos
					INTO cNombreArchivo, cIntentos
					FROM bdibpi:"informix".tkn_archivosadmtoken 
					
					IF (cIntentos < 3) THEN
						LET cIntentos = cIntentos + 1;
						UPDATE bdibpi:"informix".tkn_archivosadmtoken SET intentos = cIntentos WHERE nombre = cNombreArchivo;
						LET cCod_Ret='00000';
					ELSE
						LET cCod_Ret='00003';
					END IF;
					
					RETURN cCod_Ret,cNombreArchivo,'','','' WITH RESUME;
				END FOREACH;
			ELSE
				LET cCod_Ret='00001';
				LET cNombreArchivo='';

				RETURN cCod_Ret,cNombreArchivo,'','','' WITH RESUME;
			END IF;
		ELIF (pOpcion = '2') THEN
			IF EXISTS (SELECT nombre FROM bdibpi:"informix".tkn_archivosadmtoken_detalle WHERE nombre = pNombreArchivo) THEN
				FOREACH
					SELECT numsolicitud, numcte, numserial
					INTO cNumSolicitud, cNumCte, cNumSerial
					FROM bdibpi:"informix".tkn_archivosadmtoken_detalle 
					WHERE nombre = pNombreArchivo
					
					RETURN cCod_Ret,'',cNumSolicitud,cNumCte,cNumSerial WITH RESUME;
				END FOREACH;
			ELSE
				LET cCod_Ret='00002';
				LET cNumSolicitud='';
				LET cNumCte='';
				LET cNumSerial='';

				RETURN cCod_Ret,'',cNumSolicitud,cNumCte,cNumSerial WITH RESUME;
			END IF;
		END IF;
	END;
END PROCEDURE;
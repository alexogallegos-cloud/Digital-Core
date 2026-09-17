CREATE PROCEDURE "informix".sp_actstatus_mnsj (psecuencial INTEGER, 
											   pid_mensaje CHAR(10),
											   ptransactionid CHAR(24),
											   pestatus INTEGER,
											   pfecha_recup DATE)



--Definición de variables
DEFINE viSqlError         INTEGER;
DEFINE isam_error      	  INTEGER;
DEFINE vsMensaje          CHAR(200);
DEFINE vsCodRetorno       CHAR (5);
DEFINE visam_error		  INTEGER;
DEFINE vdFechaHoy         DATETIME YEAR TO FRACTION(5);
DEFINE vscompara		  CHAR(3);
DEFINE vexiste			  INTEGER;


--Fin de definición


--Se inicilializan variables
LET viSqlError = 0;
LET isam_error = 0;
LET vsMensaje = '';
LET vscompara = '';
LET vsCodRetorno = '00000';
LET visam_error = 0;
LET vdFechaHoy = CAST('1900-01-01 12:00:00' AS DATETIME YEAR TO FRACTION(5));
LET vexiste = 0;


--Se termina inicialización

BEGIN

	ON EXCEPTION SET viSqlError,isam_error,vsMensaje
		IF (viSqlError != 0) THEN
			LET vsCodRetorno = viSqlError;
			LET visam_error = isam_error;
				INSERT INTO bdimnsj:"informix".mnsj_errores (sql_error,isam_error, descripcion, origen_error, fecha, fecha_insert)
				VALUES (vsCodRetorno,visam_error, vsMensaje, 'sp_actstatus_mnsj', vdFechaHoy,CURRENT);
		END IF;
	END EXCEPTION;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	LET vscompara = substr(pid_mensaje,1,3);
	
	IF vscompara in ('PPG','DOM') THEN
	
		select count(id_mensaje) INTO vexiste FROM bdimnsj:"informix".mnsj_transacc_status where 
		secuencial = psecuencial and id_mensaje = pid_mensaje;
		
			IF vexiste = '1' AND pestatus IS NOT NULL THEN
				
				UPDATE bdimnsj:"informix".mnsj_transacc_status SET estatus = pestatus,id_mensaje = pid_mensaje,
				transaction_id = ptransactionid,fecha_hora_recuperado = pfecha_recup
				WHERE secuencial = psecuencial and id_mensaje = pid_mensaje;
				
			ELSE
				
				INSERT INTO bdimnsj:"informix".mnsj_transacc_status (secuencial,id_mensaje,transaction_id,estatus,fecha_hora_recuperado)
				VALUES (psecuencial,pid_mensaje,ptransactionid,pestatus,pfecha_recup);
				
			END IF;
			
	
	END IF;
	
END;
END PROCEDURE;
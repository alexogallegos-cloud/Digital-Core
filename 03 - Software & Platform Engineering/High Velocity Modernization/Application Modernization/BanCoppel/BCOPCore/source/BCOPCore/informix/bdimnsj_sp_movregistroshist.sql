CREATE PROCEDURE "informix".sp_movregistroshist()

	RETURNING CHAR(5) as Codigoretorno,
			  CHAR(100) as Mensaje;
	
	
--Definicion de variables
DEFINE viSqlError         INTEGER;
DEFINE vsCodRetorno       CHAR(5);
DEFINE vsCodRetOnline     CHAR(5);
DEFINE vsCodRetBatch      CHAR(5);
DEFINE vsCodRetNotif      CHAR(5);
DEFINE vsMensajeOnline    CHAR(50);
DEFINE vsMensajeBatch     CHAR(50);
DEFINE vsMensajeNotif     CHAR(50);
DEFINE vsMensaje          CHAR(200);
DEFINE isam_error      	  INTEGER;
DEFINE vsCont			  INTEGER;
DEFINE vsCont2			  INTEGER;
DEFINE vscountonline	  INTEGER;
DEFINE vscountbatch		  INTEGER;
DEFINE visam_error	 	  INTEGER;
DEFINE vistatus			  INTEGER;
DEFINE vistatusO		  INTEGER;
DEFINE vistatusB		  INTEGER;
DEFINE iContBorra		  INTEGER;
DEFINE vdFecha			  DATE;


--Termina definiciÃÂÃÂ³n de variables	
LET viSqlError = 0;
LET vsCodRetorno = '00000';
LET vsCodRetOnline = '';
LET vsCodRetBatch = '';
LET vsCodRetNotif = '';
LET vsMensajeOnline = '';
LET vsMensajeBatch = ''; 
LET vsMensajeNotif = '';
LET visam_error = 0;
LET vsMensaje = '';

LET vsCont = 0;
LET vsCont2 = 0;
LET vscountonline = 0;
LET vscountbatch = 0;
LET vistatus = 0;
LET vistatusO = 0;
LET vistatusB = 0;
LET iContBorra = 0;

--SET DEBUG FILE TO "/tmp/cristo/sp_movregistroshist.out";
--TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

BEGIN

	ON EXCEPTION SET viSqlError,isam_error,vsMensaje
		IF (viSqlError != 0) THEN
			LET vsCodRetorno = viSqlError;
			LET visam_error = isam_error;
				INSERT INTO bdimnsj:"informix".mnsj_errores (sql_error,isam_error, descripcion, origen_error, fecha, fecha_insert)
				VALUES (vsCodRetorno,visam_error, vsMensaje, 'sp_movregistroshist', CURRENT,CURRENT);
				
			RETURN vsCodRetorno, vsMensaje;
		END IF;
	END EXCEPTION;
	
	SELECT fecha_hoy INTO vdFecha from 
	bdinteg:"informix".si_fechas where empresa = '001';

	INSERT INTO bdimnsj:"informix".mnsj_procesos(proceso,fecha_proceso,status,user_insert,fecha_insert)
	VALUES('MOV_REGHIS',vdFecha,vistatus,'informix',CURRENT);
				
	-- Ejecuta proceso MOV_ONLINE
	EXECUTE PROCEDURE "informix".sp_mover_mensajes('MOV_ONLINE',vdFecha) INTO vsCodRetOnline, vsMensajeOnline;
	-- Ejecuta proceso MOV_BATCH
	EXECUTE PROCEDURE "informix".sp_mover_mensajes('MOV_BATCH',vdFecha) INTO vsCodRetBatch, vsMensajeBatch;
	-- Ejecuta proceso de depuraciÃ³n de Tablas del proceso binario synMsgsProc de Latinia
	EXECUTE PROCEDURE "informix".sp_depura_mensajes(vdFecha) INTO vsCodRetNotif, vsMensajeNotif;
	
	IF vsCodRetOnline = '00000'  AND vsCodRetBatch = '00000' AND vsCodRetNotif = '00000' THEN
		UPDATE bdimnsj:"informix".mnsj_procesos set status = '1' WHERE fecha_proceso = vdFecha and fecha_insert=current and proceso='MOV_REGHIS';
		LET vsCodRetorno = vsCodRetOnline; 
		LET vsMensaje = vsMensajeOnline;
	ELIF vsCodRetOnline <> '00000' THEN
		LET vsCodRetorno = vsCodRetOnline; 
		LET vsMensaje = vsMensajeOnline;
	ELIF vsCodRetBatch <> '00000' THEN 
		LET vsCodRetorno = vsCodRetBatch; 
		LET vsMensaje = vsMensajeBatch;
	ELIF vsCodRetNotif <> '00000' THEN 
		LET vsCodRetorno = vsCodRetNotif; 
		LET vsMensaje = vsMensajeNotif;
	END IF;
		
	RETURN vsCodRetorno, vsMensaje;	

END;
END PROCEDURE

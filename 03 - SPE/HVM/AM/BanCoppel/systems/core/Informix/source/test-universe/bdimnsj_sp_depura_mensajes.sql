CREATE PROCEDURE "informix".sp_depura_mensajes(pdFecha DATE)

	RETURNING CHAR(5) as Codigoretorno,
			  VARCHAR(50) as Mensaje;
	
	
--Definicion de variables
DEFINE viSqlError         INTEGER;
DEFINE vsCodRetorno       CHAR (5);
DEFINE vsMensaje          CHAR(200);
DEFINE isam_error      	  INTEGER;
DEFINE vsecuencial		  INTEGER;

--DEFINE vdFechatope     	  DATETIME YEAR TO SECOND;
DEFINE vsCont			  INTEGER;
DEFINE vscount			  INTEGER;
DEFINE visam_error	 	  INTEGER;
DEFINE vistatus			  INTEGER;
DEFINE iContBorra		  INTEGER;
DEFINE pProceso			  VARCHAR(10);

--Termina definicion de variables	
LET viSqlError = 0;
LET vsCodRetorno = '00000';
LET visam_error = 0;
LET vsMensaje = '';
LET vsecuencial = 0;

--LET vdFechatope = '1900-01-01 0:00:00';
LET vsCont = 0;
LET vscount = 0;
LET vistatus = 0;
LET iContBorra = 0;
LET pProceso = '';

--SET DEBUG FILE TO "/tmp/ragomez/sp_depura_mensajes.out";
--TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

BEGIN
	

	ON EXCEPTION SET viSqlError,isam_error,vsMensaje
		IF (viSqlError != 0) THEN
			LET vsCodRetorno = viSqlError;
			LET visam_error = isam_error;
				INSERT INTO bdimnsj:"informix".mnsj_errores (sql_error,isam_error, descripcion, origen_error, fecha, fecha_insert)
				VALUES (vsCodRetorno,visam_error, vsMensaje,pProceso, CURRENT,CURRENT);
				
			RETURN vsCodRetorno, vsMensaje;
		END IF;
	END EXCEPTION;

	
----DEPURACION DE TABLA NOTIF_ONLINE_DEFAULT
	
	LET pProceso = 'ONL_DEF';
	
	INSERT INTO bdimnsj:"informix".mnsj_procesos(proceso,fecha_proceso,status,user_insert,fecha_insert)
	VALUES(pProceso,pdFecha,vistatus,'informix',CURRENT);
					
	SELECT {+ INDEX ("informix".notif_online_default idx_online_default_secuencial_tranid) }  count(*) into vscount FROM
	bdimnsj:"informix".notif_online_default
	WHERE transaction_id IS NOT NULL;
		
	IF vscount > 0 THEN
		BEGIN WORK;
    END IF
   
	FOREACH cursor_borra WITH HOLD FOR
		
		SELECT  {+ INDEX ("informix".notif_online_default idx_online_default_secuencial_tranid) } secuencial
		INTO vsecuencial
		FROM bdimnsj:"informix".notif_online_default
		WHERE transaction_id IS NOT NULL
					
		
		LET vsCont = vsCont + 1;
		
		DELETE FROM "informix".notif_online_default WHERE CURRENT OF cursor_borra;
		LET iContBorra = iContBorra + 1;
	
		IF iContBorra = 1000 THEN
			COMMIT WORK;
			LET iContBorra = 0;
			BEGIN WORK;
		END IF;

	END FOREACH;
	
	IF iContBorra < 1000 and vscount>0 THEN
		COMMIT WORK;
	END IF;
	
	IF vsCont = vscount OR vscount < vsCont THEN
		LET vistatus = 1;
		UPDATE bdimnsj:"informix".mnsj_procesos set status = '1' WHERE fecha_proceso = pdFecha and fecha_insert=current and proceso=pProceso;
	ELSE
		LET vsCodRetorno = 9999;
		LET isam_error = 9999;
		LET vsMensaje = 'No se depurÃ³ la tbl notif_online_default t/los regs: '+vsCont;
		INSERT INTO bdimnsj:"informix".mnsj_errores (sql_error,isam_error, descripcion, origen_error, fecha, fecha_insert)
		VALUES (vsCodRetorno,visam_error, vsMensaje, pProceso, CURRENT,CURRENT);
	END IF;
	
		
----DEPURACION DE TABLA NOTIF_BATCH_DEFAULT		
	
	LET pProceso = 'BAT_DEF';
	
	INSERT INTO bdimnsj:"informix".mnsj_procesos(proceso,fecha_proceso,status,user_insert,fecha_insert)
	VALUES(pProceso,pdFecha,vistatus,'informix',CURRENT);
	
	LET vscount = 0;
	LET vsCont = 0;
		
	SELECT {+ INDEX ("informix".notif_batch_default idx_batch_default_secuencial_tranid) }  count(*) into vscount FROM
	bdimnsj:"informix".notif_batch_default
	WHERE transaction_id IS NOT NULL;
		
   IF vscount > 0 THEN
		BEGIN WORK;
    END IF
   
   
	FOREACH cursor_borra WITH HOLD FOR
	
		SELECT  {+ INDEX ("informix".notif_batch_default idx_batch_default_secuencial_tranid) } secuencial
		INTO vsecuencial
		FROM bdimnsj:"informix".notif_batch_default
		WHERE transaction_id IS NOT NULL
	
	
		LET vsCont = vsCont + 1;
		
		DELETE FROM bdimnsj:"informix".notif_batch_default WHERE CURRENT OF cursor_borra;
		LET iContBorra = iContBorra + 1;
	
		IF iContBorra = 1000 THEN
			COMMIT WORK;
			LET iContBorra = 0;
			BEGIN WORK;
		END IF;
	
	END FOREACH;
	
	IF iContBorra < 1000 and vscount>0 THEN
		COMMIT WORK;
	END IF;
	
	IF vsCont = vscount OR vscount < vsCont THEN
		LET vistatus = 1;
		UPDATE bdimnsj:"informix".mnsj_procesos set status = '1' WHERE fecha_proceso = pdFecha and fecha_insert=current and proceso=pProceso;
	ELSE
		LET vsCodRetorno = 9999;
		LET isam_error = 9999;
		LET vsMensaje = 'No se depurÃ³ la tbl notif_batch_default t/los regs';
		INSERT INTO bdimnsj:"informix".mnsj_errores (sql_error,isam_error, descripcion, origen_error, fecha, fecha_insert)
		VALUES (vsCodRetorno,visam_error, vsMensaje, pProceso, CURRENT,CURRENT);
	END IF;
		
		
----DEPURACION DE TABLA NOTIF_ONLINE_ICARD

	LET pProceso = 'ON_ICARD';
	
	INSERT INTO bdimnsj:"informix".mnsj_procesos(proceso,fecha_proceso,status,user_insert,fecha_insert)
	VALUES(pProceso,pdFecha,vistatus,'informix',CURRENT);
	
	LET vscount = 0;
	LET vsCont = 0;
	
	
	SELECT {+ INDEX ("informix".notif_online_icard idx_icard_secuencial_tranid) }  count(*) into vscount FROM
	bdimnsj:"informix".notif_online_icard
	WHERE transaction_id IS NOT NULL;
		
   IF vscount > 0 THEN
		BEGIN WORK;
   END IF
   
   
	FOREACH cursor_borra WITH HOLD FOR
	
		SELECT  {+ INDEX ("informix".notif_online_icard idx_icard_secuencial_tranid) } secuencial
		INTO vsecuencial
		FROM bdimnsj:"informix".notif_online_icard
		WHERE transaction_id IS NOT NULL
	
	
		LET vsCont = vsCont + 1;
		
		DELETE FROM bdimnsj:"informix".notif_online_icard WHERE CURRENT OF cursor_borra;
		LET iContBorra = iContBorra + 1;
	
		IF iContBorra = 1000 THEN
			COMMIT WORK;
			LET iContBorra = 0;
			BEGIN WORK;
		END IF;
	
	END FOREACH;
		
	IF iContBorra < 1000 and vscount>0 THEN
		COMMIT WORK;
	END IF;
	
	IF vsCont = vscount OR vscount < vsCont THEN
		LET vistatus = 1;
		UPDATE bdimnsj:"informix".mnsj_procesos set status = '1' WHERE fecha_proceso = pdFecha and fecha_insert=current and proceso=pProceso;
		
	ELSE
		LET vsCodRetorno = 9999;
		LET isam_error = 9999;
		LET vsMensaje = 'No se depurÃ³ la tbl notif_online_icard t/los regs';
		INSERT INTO bdimnsj:"informix".mnsj_errores (sql_error,isam_error, descripcion, origen_error, fecha, fecha_insert)
		VALUES (vsCodRetorno,visam_error, vsMensaje, pProceso, CURRENT,CURRENT);
	END IF;
		
		
----DEPURACION DE TABLA NOTIF_ONLINE_OPER_BANCARIAS

	LET pProceso = 'ON_OPER';
		
		INSERT INTO bdimnsj:"informix".mnsj_procesos(proceso,fecha_proceso,status,user_insert,fecha_insert)
		VALUES(pProceso,pdFecha,vistatus,'informix',CURRENT);
		
		LET vscount = 0;
		LET vsCont = 0;
		
		SELECT {+ INDEX ("informix".notif_online_oper_bancarias idx_online_oper_bancarias_tranid) }  count(*) into vscount FROM
		bdimnsj:"informix".notif_online_oper_bancarias
		WHERE transaction_id IS NOT NULL;
		
   IF vscount > 0 THEN
       BEGIN WORK;   
   END IF
   
   
	FOREACH cursor_borra WITH HOLD FOR
	
		SELECT  {+ INDEX ("informix".notif_online_oper_bancarias idx_online_oper_bancarias_tranid) } secuencial
		INTO vsecuencial
		FROM bdimnsj:"informix".notif_online_oper_bancarias
		WHERE transaction_id IS NOT NULL
	
	
		LET vsCont = vsCont + 1;
		
		DELETE FROM bdimnsj:"informix".notif_online_oper_bancarias WHERE CURRENT OF cursor_borra;
		LET iContBorra = iContBorra + 1;
	
		IF iContBorra = 1000 THEN
			COMMIT WORK;
			LET iContBorra = 0;
			BEGIN WORK;
		END IF;
	
	END FOREACH;
		
	IF iContBorra < 1000 and vscount>0 THEN
		COMMIT WORK;
	END IF;
	
	IF vsCont = vscount OR vscount < vsCont THEN
		LET vistatus = 1;
		UPDATE bdimnsj:"informix".mnsj_procesos set status = '1' WHERE fecha_proceso = pdFecha and fecha_insert=current and proceso=pProceso;
	
	ELSE
		LET vsCodRetorno = 9999;
		LET isam_error = 9999;
		LET vsMensaje = 'No se depurÃ³ la tbl notif_online_oper_bancarias t/los regs';
		INSERT INTO bdimnsj:"informix".mnsj_errores (sql_error,isam_error, descripcion, origen_error, fecha, fecha_insert)
		VALUES (vsCodRetorno,visam_error, vsMensaje, pProceso, CURRENT,CURRENT);
	END IF;
		

----DEPURACION DE TABLA NOTIF_ONLINE_REMESAS
		
	LET pProceso = 'ON_REMESAS';
	
	INSERT INTO bdimnsj:"informix".mnsj_procesos(proceso,fecha_proceso,status,user_insert,fecha_insert)
	VALUES(pProceso,pdFecha,vistatus,'informix',CURRENT);
	
	LET vscount = 0;
	LET vsCont = 0;
		
	SELECT {+ INDEX ("informix".notif_online_remesas idx_online_remesas_tranid) }  count(*) into vscount FROM
	bdimnsj:"informix".notif_online_remesas
	WHERE transaction_id IS NOT NULL;
		
   IF vscount > 0 THEN
       BEGIN WORK;    
   END IF
   
	FOREACH cursor_borra WITH HOLD FOR
	
		SELECT  {+ INDEX ("informix".notif_online_remesas idx_online_remesas_tranid) } secuencial
		INTO vsecuencial
		FROM bdimnsj:"informix".notif_online_remesas
		WHERE transaction_id IS NOT NULL
	
	
		LET vsCont = vsCont + 1;
		
		DELETE FROM bdimnsj:"informix".notif_online_remesas WHERE CURRENT OF cursor_borra;
		LET iContBorra = iContBorra + 1;
	
		IF iContBorra = 1000 THEN
			COMMIT WORK;
			LET iContBorra = 0;
			BEGIN WORK;
		END IF;
	
	END FOREACH;
		
	IF iContBorra < 1000 and vscount>0 THEN
		COMMIT WORK;
	END IF;
	
	IF vsCont = vscount OR vscount < vsCont THEN
		LET vistatus = 1;
		UPDATE bdimnsj:"informix".mnsj_procesos set status = '1' WHERE fecha_proceso = pdFecha and fecha_insert=current and proceso=pProceso;
		
	ELSE
		LET vsCodRetorno = 9999;
		LET isam_error = 9999;
		LET vsMensaje = 'No se depurÃ³ la tbl notif_online_remesas t/los regs';
		INSERT INTO bdimnsj:"informix".mnsj_errores (sql_error,isam_error, descripcion, origen_error, fecha, fecha_insert)
		VALUES (vsCodRetorno,visam_error, vsMensaje, pProceso, CURRENT,CURRENT);
	END IF;
		
		
		
----DEPURACION DE TABLA NOTIF_ONLINE_SPEI

	LET pProceso = 'ON_SPEI';
		
		INSERT INTO bdimnsj:"informix".mnsj_procesos(proceso,fecha_proceso,status,user_insert,fecha_insert)
		VALUES(pProceso,pdFecha,vistatus,'informix',CURRENT);
		
		LET vscount = 0;
		LET vsCont = 0;
		
		SELECT {+ INDEX ("informix".notif_online_spei idx_spei_tranid) }  count(*) into vscount FROM
		bdimnsj:"informix".notif_online_spei
		WHERE transaction_id IS NOT NULL;
		
   IF vscount > 0 THEN
       BEGIN WORK;    
   END IF
   
   
	FOREACH cursor_borra WITH HOLD FOR
	
		SELECT  {+ INDEX ("informix".notif_online_spei idx_spei_tranid) } secuencial
		INTO vsecuencial
		FROM bdimnsj:"informix".notif_online_spei
		WHERE transaction_id IS NOT NULL
	
	
		LET vsCont = vsCont + 1;
		
		DELETE FROM bdimnsj:"informix".notif_online_spei WHERE CURRENT OF cursor_borra;
		LET iContBorra = iContBorra + 1;
	
		IF iContBorra = 1000 THEN
			COMMIT WORK;
			LET iContBorra = 0;
			BEGIN WORK;
		END IF;
	
	END FOREACH;
		
	IF iContBorra < 1000 and vscount>0 THEN
		COMMIT WORK;
	END IF;
	
	IF vsCont = vscount OR vscount < vsCont THEN
		LET vistatus = 1;
		UPDATE bdimnsj:"informix".mnsj_procesos set status = '1' WHERE fecha_proceso = pdFecha and fecha_insert=current and proceso=pProceso;
		
	ELSE
		LET vsCodRetorno = 9999;
		LET isam_error = 9999;
		LET vsMensaje = 'No se depurÃ³ la tbl notif_online_spei t/los regs';
		INSERT INTO bdimnsj:"informix".mnsj_errores (sql_error,isam_error, descripcion, origen_error, fecha, fecha_insert)
		VALUES (vsCodRetorno,visam_error, vsMensaje, pProceso, CURRENT,CURRENT);
	END IF;
		
		
----DEPURACION DE TABLA NOTIF_ONLINE_TOKENS

	LET pProceso = 'ON_TOKENS';
		
		INSERT INTO bdimnsj:"informix".mnsj_procesos(proceso,fecha_proceso,status,user_insert,fecha_insert)
		VALUES(pProceso,pdFecha,vistatus,'informix',CURRENT);
		
		LET vscount = 0;
		LET vsCont = 0;
		
		SELECT {+ INDEX ("informix".notif_online_tokens indx_notif_online_tokens) }  count(*) into vscount FROM
		bdimnsj:"informix".notif_online_tokens
		WHERE transaction_id IS NOT NULL;
		
   IF vscount > 0 THEN
       BEGIN WORK;    
   END IF
   
   
	FOREACH cursor_borra WITH HOLD FOR
	
		SELECT  {+ INDEX ("informix".notif_online_tokens indx_notif_online_tokens) } secuencial
		INTO vsecuencial
		FROM bdimnsj:"informix".notif_online_tokens
		WHERE transaction_id IS NOT NULL
	
	
		LET vsCont = vsCont + 1;
		
		DELETE FROM bdimnsj:"informix".notif_online_tokens WHERE CURRENT OF cursor_borra;
		LET iContBorra = iContBorra + 1;
	
		IF iContBorra = 1000 THEN
			COMMIT WORK;
			LET iContBorra = 0;
			BEGIN WORK;
		END IF;
	
	END FOREACH;
		
	IF iContBorra < 1000 and vscount>0 THEN
		COMMIT WORK;
	END IF;
	
	IF vsCont = vscount OR vscount < vsCont THEN
		LET vistatus = 1;
		UPDATE bdimnsj:"informix".mnsj_procesos set status = '1' WHERE fecha_proceso = pdFecha and fecha_insert=current and proceso=pProceso;
	
	ELSE
		LET vsCodRetorno = 9999;
		LET isam_error = 9999;
		LET vsMensaje = 'No se depurÃ³ la tbl notif_online_tokens t/los regs';
		INSERT INTO bdimnsj:"informix".mnsj_errores (sql_error,isam_error, descripcion, origen_error, fecha, fecha_insert)
		VALUES (vsCodRetorno,visam_error, vsMensaje, pProceso, CURRENT,CURRENT);
	END IF;

		
----DEPURACION DE TABLA NOTIF_ONLINE_FON_INSUF

	LET pProceso = 'ON_F_INSUF';
		
		INSERT INTO bdimnsj:"informix".mnsj_procesos(proceso,fecha_proceso,status,user_insert,fecha_insert)
		VALUES(pProceso,pdFecha,vistatus,'informix',CURRENT);
		
		LET vscount = 0;
		LET vsCont = 0;
			
		SELECT {+ INDEX ("informix".notif_online_fon_insuf idx_online_fon_insuf_tranid) }  count(*) into vscount FROM
		bdimnsj:"informix".notif_online_fon_insuf
		WHERE transaction_id IS NOT NULL;
		
   IF vscount > 0 THEN
      BEGIN WORK;  
   END IF
   
   
	FOREACH cursor_borra WITH HOLD FOR
	
		SELECT  {+ INDEX ("informix".notif_online_fon_insuf idx_online_fon_insuf_tranid) } secuencial
		INTO vsecuencial
		FROM bdimnsj:"informix".notif_online_fon_insuf
		WHERE transaction_id IS NOT NULL
	
	
		LET vsCont = vsCont + 1;
		
		DELETE FROM bdimnsj:"informix".notif_online_fon_insuf WHERE CURRENT OF cursor_borra;
		LET iContBorra = iContBorra + 1;
	
		IF iContBorra = 1000 THEN
			COMMIT WORK;
			LET iContBorra = 0;
			BEGIN WORK;
		END IF;
	
	END FOREACH;
	
	IF iContBorra < 1000 and vscount>0 THEN
		COMMIT WORK;
	END IF;
	
	IF vsCont = vscount OR vscount < vsCont THEN
		LET vistatus = 1;
		UPDATE bdimnsj:"informix".mnsj_procesos set status = '1' WHERE fecha_proceso = pdFecha and fecha_insert=current and proceso=pProceso;
		
	ELSE
		LET vsCodRetorno = 9999;
		LET isam_error = 9999;
		LET vsMensaje = 'No se depurÃ³ la tbl notif_online_fon_insuf t/los regs';
		INSERT INTO bdimnsj:"informix".mnsj_errores (sql_error,isam_error, descripcion, origen_error, fecha, fecha_insert)
		VALUES (vsCodRetorno,visam_error, vsMensaje, pProceso, CURRENT,CURRENT);
	END IF;
		
		
----DEPURACION DE TABLA NOTIF_BATCH_MASIVOS

	LET pProceso = 'BAT_MASIVO';
		
		INSERT INTO bdimnsj:"informix".mnsj_procesos(proceso,fecha_proceso,status,user_insert,fecha_insert)
		VALUES(pProceso,pdFecha,vistatus,'informix',CURRENT);
		
		LET vscount = 0;
		LET vsCont = 0;
		
		SELECT {+ INDEX ("informix".notif_batch_masivos idx_masivos_secuencial_tranid) }  count(*) into vscount FROM
		bdimnsj:"informix".notif_batch_masivos
		WHERE transaction_id IS NOT NULL;
		
   IF vscount > 0 THEN
   
    BEGIN WORK;
    
   END IF
       
	FOREACH cursor_borra WITH HOLD FOR
	
		SELECT  {+ INDEX ("informix".notif_batch_masivos idx_masivos_secuencial_tranid) } secuencial
		INTO vsecuencial
		FROM bdimnsj:"informix".notif_batch_masivos
		WHERE transaction_id IS NOT NULL
	
	
		LET vsCont = vsCont + 1;
		
		DELETE FROM bdimnsj:"informix".notif_batch_masivos WHERE CURRENT OF cursor_borra;
		LET iContBorra = iContBorra + 1;
	
		IF iContBorra = 1000 THEN
			COMMIT WORK;
			LET iContBorra = 0;
			BEGIN WORK;
		END IF;
	
	END FOREACH;
		
	IF iContBorra < 1000 and vscount>0 THEN
		COMMIT WORK;
	END IF;
	
	IF vsCont = vscount OR vscount < vsCont THEN
		LET vistatus = 1;
		UPDATE bdimnsj:"informix".mnsj_procesos set status = '1' WHERE fecha_proceso = pdFecha and fecha_insert=current and proceso=pProceso;
	
	ELSE
		LET vsCodRetorno = 9999;
		LET isam_error = 9999;
		LET vsMensaje = 'No se depurÃ³ la tbl notif_batch_masivos t/los regs';
		INSERT INTO bdimnsj:"informix".mnsj_errores (sql_error,isam_error, descripcion, origen_error, fecha, fecha_insert)
		VALUES (vsCodRetorno,visam_error, vsMensaje, pProceso, CURRENT,CURRENT);
	END IF;
		
		
		
----DEPURACION DE TABLA NOTIF_ONLINE_97000_98000

	LET pProceso = 'ON_98000';
		
		INSERT INTO bdimnsj:"informix".mnsj_procesos(proceso,fecha_proceso,status,user_insert,fecha_insert)
		VALUES(pProceso,pdFecha,vistatus,'informix',CURRENT);
		
		LET vscount = 0;
		LET vsCont = 0;
			
		SELECT {+ INDEX ("informix".notif_online_97000_98000 idx_98000_tranid) }  count(*) into vscount FROM
		bdimnsj:"informix".notif_online_97000_98000
		WHERE transaction_id IS NOT NULL;
		
   IF vscount > 0 THEN
      BEGIN WORK;  
   END IF
   
   
	FOREACH cursor_borra WITH HOLD FOR
	
		SELECT  {+ INDEX ("informix".notif_online_97000_98000 idx_98000_tranid) } secuencial
		INTO vsecuencial
		FROM bdimnsj:"informix".notif_online_97000_98000
		WHERE transaction_id IS NOT NULL
	
	
		LET vsCont = vsCont + 1;
		
		DELETE FROM bdimnsj:"informix".notif_online_97000_98000 WHERE CURRENT OF cursor_borra;
		LET iContBorra = iContBorra + 1;
	
		IF iContBorra = 1000 THEN
			COMMIT WORK;
			LET iContBorra = 0;
			BEGIN WORK;
		END IF;
	
	END FOREACH;
	
	IF iContBorra < 1000 and vscount>0 THEN
		COMMIT WORK;
	END IF;
	
	IF vsCont = vscount OR vscount < vsCont THEN
		LET vistatus = 1;
		UPDATE bdimnsj:"informix".mnsj_procesos set status = '1' WHERE fecha_proceso = pdFecha and fecha_insert=current and proceso=pProceso;
		
	ELSE
		LET vsCodRetorno = 9999;
		LET isam_error = 9999;
		LET vsMensaje = 'No se depurÃ³ la tbl notif_online_97000_98000 t/los regs';
		INSERT INTO bdimnsj:"informix".mnsj_errores (sql_error,isam_error, descripcion, origen_error, fecha, fecha_insert)
		VALUES (vsCodRetorno,visam_error, vsMensaje, pProceso, CURRENT,CURRENT);
	END IF;

	

----DEPURACION DE TABLA NOTIF_ONLINE_MONITOREO

	LET pProceso = 'ON_MONIT';
		
		INSERT INTO bdimnsj:"informix".mnsj_procesos(proceso,fecha_proceso,status,user_insert,fecha_insert)
		VALUES(pProceso,pdFecha,vistatus,'informix',CURRENT);
		
		LET vscount = 0;
		LET vsCont = 0;
			
		SELECT {+ INDEX ("informix".notif_online_monitoreo idx_monitoreo_tranid) }  count(*) into vscount FROM
		bdimnsj:"informix".notif_online_monitoreo
		WHERE transaction_id IS NOT NULL;
		
   IF vscount > 0 THEN
      BEGIN WORK;  
   END IF
   
   
	FOREACH cursor_borra WITH HOLD FOR
	
		SELECT  {+ INDEX ("informix".notif_online_monitoreo idx_monitoreo_tranid) } secuencial
		INTO vsecuencial
		FROM bdimnsj:"informix".notif_online_monitoreo
		WHERE transaction_id IS NOT NULL
	
	
		LET vsCont = vsCont + 1;
		
		DELETE FROM bdimnsj:"informix".notif_online_monitoreo WHERE CURRENT OF cursor_borra;
		LET iContBorra = iContBorra + 1;
	
		IF iContBorra = 1000 THEN
			COMMIT WORK;
			LET iContBorra = 0;
			BEGIN WORK;
		END IF;
	
	END FOREACH;
	
	IF iContBorra < 1000 and vscount>0 THEN
		COMMIT WORK;
	END IF;
	
	IF vsCont = vscount OR vscount < vsCont THEN
		LET vistatus = 1;
		UPDATE bdimnsj:"informix".mnsj_procesos set status = '1' WHERE fecha_proceso = pdFecha and fecha_insert=current and proceso=pProceso;
		
	ELSE
		LET vsCodRetorno = 9999;
		LET isam_error = 9999;
		LET vsMensaje = 'No se depurÃ³ la tbl notif_online_monitoreo t/los regs';
		INSERT INTO bdimnsj:"informix".mnsj_errores (sql_error,isam_error, descripcion, origen_error, fecha, fecha_insert)
		VALUES (vsCodRetorno,visam_error, vsMensaje, pProceso, CURRENT,CURRENT);
	END IF;

	
	LET vsMensaje = 'Proceso Exitoso';
	RETURN vsCodRetorno, vsMensaje;	
END;
END PROCEDURE

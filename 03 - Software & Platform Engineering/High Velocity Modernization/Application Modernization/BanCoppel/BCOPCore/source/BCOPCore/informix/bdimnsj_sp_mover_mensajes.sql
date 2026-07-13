CREATE PROCEDURE "informix".sp_mover_mensajes(pProceso VARCHAR(10), pdFecha DATE)

	RETURNING CHAR(5) as Codigoretorno,
			  VARCHAR(50) as Mensaje;
	
	
--Definicion de variables
DEFINE viSqlError         INTEGER;
DEFINE vsCodRetorno       CHAR (5);
DEFINE vsMensaje          CHAR(200);
DEFINE isam_error      	  INTEGER;
DEFINE vsecuencial		  INTEGER;
DEFINE vstipomensaje	  CHAR(1);
DEFINE vsidmensaje		  CHAR(10);
DEFINE vidplantilla 	  VARCHAR(12);
DEFINE vtransactionid 	  CHAR(24);
DEFINE vscliente		  CHAR(20);
DEFINE vscuenta		 	  CHAR(20);
DEFINE vstarjeta		  CHAR(16);
DEFINE vsestatus		  INTEGER;
DEFINE vdfechahora		  DATETIME YEAR TO SECOND;
DEFINE vdfechahorarecu    DATETIME YEAR TO SECOND;
DEFINE vsString1		  CHAR(30);
DEFINE vsString2		  CHAR(30);
DEFINE vsString3		  CHAR(30);
DEFINE vsString4		  CHAR(30);
DEFINE vsString5		  CHAR(150);
DEFINE vsString6		  CHAR(100);
DEFINE vsString7		  CHAR(60);
DEFINE vsString8		  CHAR(60);
DEFINE vsString9		  CHAR(15);
DEFINE vsString10		  CHAR(100);
DEFINE vscorreo_alterno	  CHAR(100);
DEFINE vscelular_alterno  CHAR(10);
DEFINE vsimporte1		  MONEY (14,2);
DEFINE vsimporte2		  MONEY (14,2);
DEFINE vsimporte3		  MONEY (14,2);
DEFINE vsimporte4		  MONEY (14,2);
DEFINE vsimporte5		  MONEY (14,2);
DEFINE vdfecha1		  	  DATETIME YEAR TO SECOND;
DEFINE vdfecha2 		  DATETIME YEAR TO SECOND;
--DEFINE vdFechatope     	  DATETIME YEAR TO SECOND;
DEFINE vsCont			  INTEGER;
DEFINE vsCont2			  INTEGER;
DEFINE vscountonline	  INTEGER;
DEFINE vscountbatch		  INTEGER;
DEFINE visam_error	 	  INTEGER;
DEFINE vistatus			  INTEGER;
DEFINE iContBorra		  INTEGER;
DEFINE iprioridad		INTEGER;


--Termina definicion de variables	
LET viSqlError = 0;
LET vsCodRetorno = '00000';
LET visam_error = 0;
LET vsMensaje = '';
LET vsecuencial = 0;
LET vstipomensaje = '';
LET vsidmensaje ='';
LET vidplantilla='';
LET vtransactionid = '';
LET vscliente = '';
LET vscuenta = '';
LET vstarjeta = '';
LET vsestatus = '';
LET vdfechahora = '1900-01-01 0:00:00';
LET vdfechahorarecu = '1900-01-01 0:00:00';
LET vsString1 = '';
LET vsString2 = '';
LET vsString3 = '';
LET vsString4 = '';
LET vsString5 = '';
LET vsString6 = '';
LET vsString7 = '';
LET vsString8 = '';
LET vsString9 = '';
LET vsString10 = '';
LET vscorreo_alterno = '';
LET vscelular_alterno = '';
LET vsimporte1 = 0;
LET vsimporte2 = 0;
LET vsimporte3 = 0;
LET vsimporte4 = 0;
LET vsimporte5 = 0;
LET vdfecha1 =  '1900-01-01 0:00:00';
LET vdfecha2 = '1900-01-01 0:00:00';
--LET vdFechatope = '1900-01-01 0:00:00';
LET vsCont = 0;
LET vsCont2 = 0;
LET vscountonline = 0;
LET vscountbatch = 0;
LET vistatus = 0;
LET iContBorra = 0;
LET iprioridad = 0;

--SET DEBUG FILE TO "/tmp/cristo/sp_mover_mensajes.out";
--TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 5;

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

	
	
	INSERT INTO bdimnsj:"informix".mnsj_procesos(proceso,fecha_proceso,status,user_insert,fecha_insert)
	VALUES(pProceso,pdFecha,vistatus,'informix',CURRENT);
	
	
				
	IF pProceso = 'MOV_ONLINE' THEN
		SELECT  count(*) into vscountonline FROM
		bdimnsj:"informix".mnsjr_trx_online
		WHERE fecha_hora_registro < TODAY AND transaction_id IS NOT NULL;
		
   IF vscountonline > 0 THEN
   
    BEGIN WORK;
    
   END IF
   
		FOREACH cursor_borra WITH HOLD FOR
			
			SELECT  {+AVOID_FULL("informix".mnsjr_trx_online)} secuencial, tipo_mensaje, id_mensaje,
			id_plantilla,transaction_id, cliente, cuenta, tarjeta, estatus, fecha_hora_registro, 
			fecha_hora_recuperado, string1, string2, string3, string4, string5, string6, string7, string8, string9, string10, 
			correo_alterno, celular_alterno, importe1, importe2, importe3, importe4, importe5, fecha1, fecha2, prioridad
			INTO vsecuencial,vstipomensaje, vsidmensaje,vidplantilla,vtransactionid,vscliente,vscuenta,vstarjeta,vsestatus,vdfechahora,
			vdfechahorarecu,vsString1,vsString2,vsString3,vsString4,vsString5,vsString6,vsString7,vsString8,vsString9,vsString10,
			vscorreo_alterno, vscelular_alterno, vsimporte1,vsimporte2,vsimporte3,vsimporte4,vsimporte5, vdfecha1,vdfecha2, iprioridad
			FROM bdimnsj:"informix".mnsjr_trx_online
			WHERE fecha_hora_registro < TODAY AND transaction_id IS NOT NULL
			
			INSERT INTO bdimnsj:"informix".mnsjr_trx_online_his (
			secuencial, tipo_mensaje, id_mensaje, id_plantilla,transaction_id, cliente, cuenta, tarjeta, estatus, fecha_hora_registro, 
			fecha_hora_recuperado, string1, string2, string3, string4, string5, string6, string7, string8, string9, string10,
			correo_alterno, celular_alterno, importe1, importe2, importe3, importe4, importe5, fecha1, fecha2, prioridad)
			VALUES (vsecuencial,vstipomensaje, vsidmensaje,vidplantilla,vtransactionid,vscliente,vscuenta,vstarjeta,vsestatus,vdfechahora,
			vdfechahorarecu,vsString1,vsString2,vsString3,vsString4,vsString5,vsString6,vsString7,vsString8,vsString9,vsString10,
			vscorreo_alterno, vscelular_alterno,vsimporte1,vsimporte2,vsimporte3,vsimporte4,vsimporte5, vdfecha1,vdfecha2, iprioridad);
			
			LET vsCont = vsCont + 1;
			
			DELETE FROM "informix".mnsjr_trx_online WHERE CURRENT OF cursor_borra;
			LET iContBorra = iContBorra + 1;
		
			IF iContBorra = 1000 THEN
				COMMIT WORK;
				LET iContBorra = 0;
				BEGIN WORK;
			END IF;

		END FOREACH;
		
		IF iContBorra < 1000 and vscountonline>0 THEN
			COMMIT WORK;
		END IF;
		
		IF vsCont = vscountonline THEN
			LET vistatus = 1;
		ELSE
			LET vsCodRetorno = 9999;
			LET isam_error = 9999;
			LET vsMensaje = 'No se instr la tbl mnsjr_trx_online_his t/los regs: '+vsCont;
			INSERT INTO bdimnsj:"informix".mnsj_errores (sql_error,isam_error, descripcion, origen_error, fecha, fecha_insert)
			VALUES (vsCodRetorno,visam_error, vsMensaje, pProceso, CURRENT,CURRENT);
		END IF;
		
	ELIF pProceso = 'MOV_BATCH' THEN	
		SELECT count(*) into vscountbatch FROM
		bdimnsj:"informix".mnsjr_trx_batch
		WHERE fecha_hora_registro < TODAY AND transaction_id IS NOT NULL;
		
   IF vscountbatch > 0 THEN
   
    BEGIN WORK;
    
   END IF
   
   
		FOREACH  cursor_borra WITH HOLD FOR
		
			SELECT secuencial, tipo_mensaje, id_mensaje, 
			id_plantilla,transaction_id, cliente, cuenta, tarjeta, estatus, fecha_hora_registro, 
			fecha_hora_recuperado, string1, string2, string3, string4, string5, string6, string7, string8, string9, string10, 
			correo_alterno, celular_alterno, importe1, importe2, importe3, importe4, importe5, fecha1, fecha2, prioridad 
			INTO vsecuencial,vstipomensaje, vsidmensaje,vidplantilla,vtransactionid,vscliente,vscuenta,vstarjeta,vsestatus,vdfechahora,
			vdfechahorarecu,vsString1,vsString2,vsString3,vsString4,vsString5,vsString6,vsString7,vsString8,vsString9,vsString10,
			vscorreo_alterno, vscelular_alterno, vsimporte1,vsimporte2,vsimporte3,vsimporte4,vsimporte5, vdfecha1,vdfecha2, iprioridad
			FROM bdimnsj:"informix".mnsjr_trx_batch
			WHERE fecha_hora_registro < TODAY AND transaction_id IS NOT NULL
		
			INSERT INTO bdimnsj:"informix".mnsjr_trx_batch_his (
			secuencial, tipo_mensaje, id_mensaje, id_plantilla,transaction_id, cliente, cuenta, tarjeta, estatus, fecha_hora_registro, 
			fecha_hora_recuperado, string1, string2, string3, string4, string5, string6, string7, string8, string9, string10,
			correo_alterno, celular_alterno, importe1, importe2, importe3, importe4, importe5, fecha1, fecha2, prioridad)
			VALUES (vsecuencial,vstipomensaje, vsidmensaje,vidplantilla,vtransactionid,vscliente,vscuenta,vstarjeta,vsestatus,vdfechahora,
			vdfechahorarecu,vsString1,vsString2,vsString3,vsString4,vsString5,vsString6,vsString7,vsString8,vsString9,vsString10,
			vscorreo_alterno, vscelular_alterno,vsimporte1,vsimporte2,vsimporte3,vsimporte4,vsimporte5, vdfecha1,vdfecha2, iprioridad);
			
			LET vsCont2 = vsCont2 + 1;
			
			DELETE FROM bdimnsj:"informix".mnsjr_trx_batch WHERE CURRENT OF cursor_borra;
			LET iContBorra = iContBorra + 1;
		
			IF iContBorra = 1000 THEN
				COMMIT WORK;
				LET iContBorra = 0;
				BEGIN WORK;
			END IF;
		
		END FOREACH;
		
		IF iContBorra < 1000 and vscountbatch>0 THEN
			COMMIT WORK;
		END IF;
		
		IF vsCont2 = vscountbatch THEN
			LET vistatus = 1;
		ELSE
			LET vsCodRetorno = 9999;
			LET isam_error = 9999;
			LET vsMensaje = 'No se insrt la tbl mnsjr_trx_batch_his t/los regs';
			INSERT INTO bdimnsj:"informix".mnsj_errores (sql_error,isam_error, descripcion, origen_error, fecha, fecha_insert)
			VALUES (vsCodRetorno,visam_error, vsMensaje, pProceso, CURRENT,CURRENT);
			

		END IF;
	END IF;
	
	IF vistatus = '1'THEN
		UPDATE bdimnsj:"informix".mnsj_procesos set status = '1' WHERE fecha_proceso = pdFecha and fecha_insert=current and proceso=pProceso;
	END IF;
	
	
	
	RETURN vsCodRetorno, vsMensaje;	
END;
END PROCEDURE

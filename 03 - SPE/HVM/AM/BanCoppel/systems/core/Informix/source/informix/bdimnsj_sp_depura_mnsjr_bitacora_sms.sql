CREATE PROCEDURE "informix".sp_depura_mnsjr_bitacora_sms()

	RETURNING CHAR(5) as Codigoretorno,
			  VARCHAR(50) as Mensaje;
	
	
--Definicion de variables
DEFINE viSqlError         INTEGER;
DEFINE vsCodRetorno       CHAR (5);
DEFINE vsMensaje          CHAR(200);
DEFINE isam_error      	  INTEGER;

---Definicion de variablas de la tabla
DEFINE vdfechasolicitud	  DATETIME YEAR TO SECOND;
DEFINE vsproceso  		  VARCHAR(30);
DEFINE vstexto_msj  	  VARCHAR(30);
DEFINE vsusuario	  	  VARCHAR(10);
DEFINE vspass		  	  VARCHAR(10);
DEFINE vscel		  	  VARCHAR(10);
DEFINE vscompania	  	  VARCHAR(10);
DEFINE vsresp_solic	  	  VARCHAR(250);
DEFINE vsnumcte		  	  VARCHAR(20);
DEFINE vssucursal	  	  VARCHAR(10);
DEFINE vsparam1		  	  VARCHAR(20);
DEFINE vsparam2		  	  VARCHAR(20);
DEFINE vsparam3		  	  VARCHAR(20);


DEFINE vsCont			  INTEGER;
DEFINE vscount			  INTEGER;
DEFINE visam_error	 	  INTEGER;
DEFINE vistatus			  INTEGER;
DEFINE iContBorra		  INTEGER;


--Termina definicion de variables	
LET viSqlError = 0;
LET vsCodRetorno = '00000';
LET visam_error = 0;
LET vsMensaje = 'PROCESO EXITOSO';

---Variables de la tabla
LET vdfechasolicitud = '1900-01-01 0:00:00';
LET vsproceso = '';
LET vstexto_msj = '';
LET vsusuario = '';
LET vspass = '';
LET vscel = '';
LET vscompania = '';
LET vsresp_solic = '';
LET vsnumcte = '';
LET vssucursal = '';
LET vsparam1 = '';
LET vsparam2 = '';
LET vsparam3 = '';

LET vsCont = 0;
LET vscount = 0;
LET vistatus = 0;
LET iContBorra = 0;

--SET DEBUG FILE TO "/informix/ragomez/depuracion_mnsjr_bitacora_sms/sp_depura_mnsjr_bitacora_sms.out";
--TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 5;

BEGIN
	

	ON EXCEPTION SET viSqlError,isam_error,vsMensaje
		IF (viSqlError != 0) THEN
			LET vsCodRetorno = viSqlError;
			LET visam_error = isam_error;
				INSERT INTO bdimnsj:"informix".mnsj_errores (sql_error,isam_error, descripcion, origen_error, fecha, fecha_insert)
				VALUES (vsCodRetorno,visam_error, vsMensaje,'MOV_BIT_SMS', CURRENT,CURRENT);
				
			RETURN vsCodRetorno, vsMensaje;
		END IF;
	END EXCEPTION;

					
		SELECT  COUNT(*) INTO vscount FROM
		bdimnsj:"informix".mnsjr_bitacora_sms
		WHERE fechasolicitud < TODAY - 1;
		
   IF vscount > 0 THEN
   
    BEGIN WORK;
    
   END IF
   
		FOREACH cursor_borra WITH HOLD FOR
			
			SELECT {+AVOID_FULL("informix".mnsjr_bitacora_sms)} fechasolicitud, proceso, texto_msj, usuario, pass, cel, 
					compania, respuestasolicitud, numcte, sucursal, param1, param2, param3
			INTO vdfechasolicitud, vsproceso, vstexto_msj, vsusuario, vspass, vscel, vscompania,	vsresp_solic, vsnumcte, vssucursal,
				 vsparam1, vsparam2, vsparam3
			FROM bdimnsj:"informix".mnsjr_bitacora_sms
			WHERE fechasolicitud < TODAY - 1
			
			INSERT INTO bdimnsj:"informix".mnsjr_bitacora_sms_hist (
						fechasolicitud, proceso, texto_msj, usuario, pass, cel, 
						compania, respuestasolicitud, numcte, sucursal, param1, param2, param3)
			VALUES (vdfechasolicitud, vsproceso, vstexto_msj, vsusuario, vspass, vscel, vscompania,	vsresp_solic, vsnumcte, vssucursal,
					vsparam1, vsparam2, vsparam3);
			
			LET vsCont = vsCont + 1;
			
			DELETE FROM "informix".mnsjr_bitacora_sms WHERE CURRENT OF cursor_borra;
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
		
		IF vsCont = vscount THEN
			LET vistatus = 1;
		ELSE
			LET vsCodRetorno = 9999;
			LET isam_error = 9999;
			LET vsMensaje = 'No se instr la tbl mnsjr_bitacora_sms_hist t/los regs: '+vsCont;
			INSERT INTO bdimnsj:"informix".mnsj_errores (sql_error,isam_error, descripcion, origen_error, fecha, fecha_insert)
			VALUES (vsCodRetorno,visam_error, vsMensaje, 'MOV_BIT_SMS', CURRENT,CURRENT);
		END IF;
		
	
	RETURN vsCodRetorno, vsMensaje;	
END;
END PROCEDURE

CREATE PROCEDURE "informix".sp_carga_telefonos_duplicados()
RETURNING CHAR(6), CHAR(100);

	DEFINE iSqlError 		  INTEGER;
	DEFINE cCodRetorno        CHAR (8);
	DEFINE cMensaje           CHAR(200);
	DEFINE iExiste			  INTEGER;
	DEFINE iExisteDos		  INTEGER;
	DEFINE iExistetmp		  INTEGER;		
	DEFINE cTelefonoDuplicado CHAR (13);	
	
	LET cCodRetorno 			= '000000';
	LET cMensaje 				= 'EL PROCESO DE CARGA DE TELEFONOS DUPLICADOS SE A GENERADO CORRECTAMENTE';
	LET iExiste					= 0;
	LET iExisteDos				= 0;
	LET iExistetmp				= 0;
	LET cTelefonoDuplicado		= '';
	
	--SET DEBUG FILE TO "/tmp/ALAN/depuracionTelefonos/sp_carga_telefonos_duplicados.out";
	--TRACE ON;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	

BEGIN
		ON EXCEPTION SET iSqlError
			IF iSqlError <> 0 THEN
				LET cCodRetorno = iSqlError;				
				LET cMensaje = 'EL PROCESO DE CARGA DE TELEFONOS DUPLICADOS SE A GENERADO CON ERRORES';			
				RETURN cCodRetorno, cMensaje;
			END IF;			
		END EXCEPTION;
		
		IF iExiste = 1 THEN
			DROP TABLE tmptelefonosduplicados;
			LET iExiste = 0;
		END IF;
		
		IF iExistetmp = 1 THEN
			DROP TABLE tmptelefonosduplicados2;
			LET iExiste = 0;
		END IF;
		
		IF iExisteDos = 1 THEN
			DROP TABLE tmptelefonossindepurar;
			LET iExiste = 0;
		END IF;
		
		
		SELECT {+MULTI_INDEX(si_telefonos_actual)} telefono
		FROM si_telefonos_actual
		WHERE tipo_tel = 2 AND status_tel = 'A'
		INTO TEMP tmptelefonosduplicados WITH NO LOG;
		
		LET iExiste = 1;
		
		SELECT telefono
		FROM tmptelefonosduplicados
		GROUP BY telefono
		HAVING COUNT(telefono) >= 2
		INTO TEMP tmptelefonosduplicados2 WITH NO LOG;

		LET iExistetmp = 1;
		
		SELECT telefono 
		FROM si_telefonos_duplicados
		WHERE estatus = 2 AND tipo_tel = 2
		INTO TEMP tmptelefonossindepurar WITH NO LOG;
		
		LET iExisteDos = 1;
		
		
		INSERT INTO si_telefonos_duplicados(telefono,tipo_tel,estatus,proceso,cod_retorno,tipo_depuracion,fecha_proceso,fecha_depuracion,user_insert,fecha_insert)
		SELECT telefono, 2,0,'','','','','','informix',TODAY
		FROM tmptelefonosduplicados2
		WHERE  telefono NOT IN( SELECT telefono FROM tmptelefonossindepurar);
							
		DROP TABLE tmptelefonosduplicados;					
		LET iExiste = 0;
		
		DROP TABLE tmptelefonosduplicados2;
		LET iExistetmp = 0;

		DROP TABLE tmptelefonossindepurar;					
		LET iExisteDos = 0;		
							
		RETURN cCodRetorno, cMensaje;
END
END PROCEDURE					
;
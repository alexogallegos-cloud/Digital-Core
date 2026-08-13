CREATE PROCEDURE "informix".sp_cargar_informacion_procesada_central()
	RETURNING CHAR(5) AS codret;

	DEFINE cCodRet				CHAR(5);
	DEFINE sqlErr				INTEGER;
	
	LET cCodRet 		    	= '00001';
	LET sqlErr 			    	= 0; 
	
	BEGIN

		ON EXCEPTION SET sqlErr
			IF sqlErr <> 0 THEN
				LET cCodRet = sqlErr;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO "/INFORMIXDUMP/sp_cargar_informacion_procesada_central.trc";
		--TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--Se ejecuta el 1er procedimiento
		EXECUTE PROCEDURE "informix".sp_cargar_info_procesada_cta_nom() 
		INTO cCodRet;
		
		--Si es exitoso se ejecuta el 2do procedimiento
		IF TRIM(NVL(cCodRet,'')) = '00000' THEN
			
			EXECUTE PROCEDURE "informix".sp_cargar_notificaciones()
			INTO cCodRet;
			
		END IF;
		
		RETURN cCodRet;

	END;	
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se crea procedimiento para ejecutar los procedimientos que cargan la informacion de los archivos planos a la base de datos central.',
'AUTOR: Alejandra Barranco',
'FECHA DE CREACION: 04 DE OCTUBRE DE 2022',
'VERSION: 1.0.0',
'BD: bdiadminnomina',
'SOLICITO: Fabio Torres Esquer' ;
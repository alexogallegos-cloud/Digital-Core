CREATE PROCEDURE "informix".sp_generar_archivos_nom_spei()
	RETURNING CHAR(5) AS codret;

	DEFINE sqlErr			INTEGER;
	DEFINE cCodRet			CHAR(5);
	
	LET sqlErr 			    = 0; 
	LET cCodRet				= '00001';
	
	BEGIN

		ON EXCEPTION SET sqlErr
			IF sqlErr <> 0 THEN
				LET cCodRet = sqlErr;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO "/INFORMIXDUMP/sp_generar_archivos_nom_spei.trc";
		--TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		-- se ejecuta el 1er procedimiento
		EXECUTE PROCEDURE "informix".sp_generar_arch_cta_nom()
		INTO cCodRet;
		
		--Si es exitoso se ejecuta el 2do procedimiento
		IF TRIM(NVL(cCodRet,'')) = '00000' THEN
		
			EXECUTE PROCEDURE "informix".sp_generar_arch_mov_spei()
			INTO cCodRet;
			
		END IF;
		
		RETURN cCodRet;

	END;	
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se crea procedimiento para ejecutar los procedimientos que generan los archivos planos ',
'AUTOR: Alejandra Barranco',
'FECHA DE CREACION: 29 de SEPTIEMBRE DE 2022',
'VERSION: 1.0.0',
'BD: bdiadminnomina',
'SOLICITO: Fabio Torres Esquer';
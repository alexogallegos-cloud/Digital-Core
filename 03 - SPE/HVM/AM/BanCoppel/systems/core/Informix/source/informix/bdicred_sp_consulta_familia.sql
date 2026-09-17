CREATE PROCEDURE "informix".sp_consulta_familia(pOpcion CHAR(3))

RETURNING CHAR(5) AS cCodRet,
          CHAR(3) AS cId,
		  CHAR(40) AS cFamilia;
    
DEFINE cCodRet CHAR(5);
DEFINE cId CHAR(3);
DEFINE cFamilia CHAR(40);
DEFINE iSqlErr  INTEGER;

LET cCodRet = '00000';
LET cId = '';
LET cFamilia = '';
LET iSqlErr = 0;
    
	BEGIN
		-- // MANEJO DE EXCEPCIONES   
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet,cId,cFamilia;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO "/ifxsif01/home/e_efierro/sp_consulta_familia.out";
		--TRACE ON;
	
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
	
		-- // VALIDA PARAMETROS DE ENTRADA
		IF (pOpcion IS NULL OR pOpcion = '') THEN
			LET cCodRet = '00001';
		ELSE
				-- // OBTIENE INFORMACION
				SELECT id_familia,familia
				INTO cId,cFamilia
				FROM "informix".sd_familia_productos 
				WHERE id_familia = pOpcion;
			
				-- // VERIFICA SI EXISTE EL NUMERO DE ID
				IF (cId IS NULL OR cId = '') THEN
					LET cCodRet = '00002'; 
				END IF;
		END IF;
		RETURN cCodRet, cId,cFamilia;
	END
END PROCEDURE;
CREATE PROCEDURE "informix".sp_guarda_telefonos_web(pEmpresa CHAR(3), 
													    pNumcte CHAR (20), 
													    pTelcasa CHAR (10), 
													    pTelcelular CHAR (10), 
													    pTeloficina CHAR (10),
													    pTelotro CHAR (10),
													    pCarrier SMALLINT,
													    pExtension CHAR(5),
													    pUserInsert  CHAR(8))
	RETURNING CHAR(5) AS CodRetorno;

--Definicion de Variables
DEFINE iSqlErr 		   INTEGER;
DEFINE cCodRet 		   CHAR(5);

--Inicializacion de Variables
LET iSqlErr 		= 0;
LET cCodRet 		= '00000';

	--SET DEBUG FILE TO "/informix/tmp/sp_guarda_telefonos.out";
	--TRACE ON;

BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
		
	IF NVL(pEmpresa,'') <> '' AND NVL(pNumcte,'') <> '' AND (NVL(pTelcasa, '') <> '' OR NVL(pTelcelular, '') <> '' OR NVL(pTeloficina, '') <> '' OR NVL(pTelotro, '') <> '') THEN
		
		IF pTelcasa <> '' THEN
			
			EXECUTE PROCEDURE "informix".sp_registra_telefonos_web (pEmpresa, pNumcte, pTelcasa, 1, '', 0, 1, pUserInsert) INTO cCodRet;
		
		END IF;
		IF cCodRet::INT = 0 OR cCodRet= '00999' THEN
		
			IF pTelcelular <> '' THEN 
				
				EXECUTE PROCEDURE "informix".sp_registra_telefonos_web (pEmpresa, pNumcte, pTelcelular, 2, '', pCarrier, 1, pUserInsert) INTO cCodRet;
			
			END IF;
			IF cCodRet::INT = 0 OR cCodRet= '00999' THEN
			 
				IF pTeloficina <> '' THEN
			
					EXECUTE PROCEDURE "informix".sp_registra_telefonos_web (pEmpresa, pNumcte, pTeloficina, 3, pExtension, 0, 1, pUserInsert) INTO cCodRet;
			
				END IF;
				
				IF cCodRet::INT = 0 OR cCodRet= '00999' THEN
					IF pTelotro <> '' THEN 
						EXECUTE PROCEDURE "informix".sp_registra_telefonos_web (pEmpresa, pNumcte, pTelotro, 4, '', 0, 1, pUserInsert) INTO cCodRet;
			
					END IF;	
				END IF;
				 
			END IF;
		END IF;
	ELSE 
		LET cCodRet = '00001';	
	END IF;
	
RETURN cCodRet;

END;
END PROCEDURE
;
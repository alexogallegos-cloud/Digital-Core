CREATE PROCEDURE "informix".sp_obtienenumeroconsultaws(pParam CHAR(4), pEmpresa CHAR(3))
RETURNING CHAR(6) AS rCodRet, 
		  INTEGER AS rNum_Consecutivo;
			
--Declaracion de variables-------- 
DEFINE cCodRet 				   CHAR(6);
DEFINE iNum_Consecutivo        INTEGER;
DEFINE iSqlErr				   INTEGER;

--Inicializacion de Variables----------------------------------------------------- 
LET iSqlErr				=		0;
LET cCodRet 			= 		'000001';
LET iNum_Consecutivo 	= 		0;


--SET DEBUG FILE TO '/respaldosbd/Carolina/sp_guardasituacionespecialcte.out';
	--TRACE ON;

	BEGIN 

	ON EXCEPTION SET iSqlerr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet,'';
		END IF;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

		IF NVL(pParam,'') <> ''  AND NVL(pEmpresa,'') <> '' THEN 
		
			SELECT ((valor:: INTEGER)+1)
			INTO iNum_Consecutivo
			FROM bdinteg:"informix".si_param WHERE cod_param = pParam AND  empresa = pEmpresa;
			
						
			UPDATE bdinteg:"informix".si_param SET valor = iNum_Consecutivo WHERE cod_param = pParam AND empresa = pEmpresa;			
			LET cCodRet = '000000';
			
		END IF ;
		
			RETURN cCodRet, iNum_Consecutivo;
	END
END PROCEDURE

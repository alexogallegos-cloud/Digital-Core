CREATE PROCEDURE "informix".sp_mttositespalterna_web(pEmpresa CHAR(3),pNumcte CHAR(20),pSucursal CHAR(4),pOperador CHAR(8))
RETURNING 	CHAR(5) AS cCodRet

--DECLARACIONES DE VARIABLES Y SU TIPO DE DATO
DEFINE cCodRet  CHAR(5);
DEFINE iSqlErr  INTEGER;

--INICIALIZACIONES DEVALORES DEFAULT DE VARIABLES
LET cCodRet		= '000000';
LET iSqlErr		= 0;		
			
	--SET DEBUG FILE TO '/respaldosbd/josue/sp_mttositespalterna.out';
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

		IF  NVL(pEmpresa,'') = '' OR NVL(pNumcte,'') = '' OR NVL(pSucursal,'') = '' OR NVL(pOperador,'') = '' THEN
			LET cCodRet = '00001'; -- 'PARAMETROS INCOMPLETOS'
		ELSE
		
			INSERT INTO "informix".se_sitespctetmp(empresa,numcte,situacion,causa,sucursal,proceso_origen,operador,fecha,fechamovto)
			VALUES(pEmpresa,pNumcte,'U','61',pSucursal,'3',pOperador,CURRENT,CURRENT);
			
			IF DBINFO("sqlca.sqlerrd2") = 0 THEN
				LET cCodRet = '00002'; -- NO SE PUDO REALIZAR EL INSERT.
			END IF	
		END IF;
	RETURN cCodRet;
	END; 
END PROCEDURE

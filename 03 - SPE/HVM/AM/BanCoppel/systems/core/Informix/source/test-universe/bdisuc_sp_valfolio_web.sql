CREATE PROCEDURE "informix".sp_valfolio_web(
	pEmpresa  CHAR(3),
	pSucursal CHAR(4),
	pcajeroprincipal  CHAR(8),   --- se respeta el nombre de la varible porque se revisa el servicio y tiene el mismo nombre
								 --- el nombre que tiene el SP original es "pEmpleado"
	pFolioOpe CHAR(8),
	pDivisa   CHAR(2),
	pMonto    MONEY(14,2))
	
RETURNING CHAR(5);

DEFINE iSqlErr   INTEGER;
DEFINE iIsamErr  INTEGER;
DEFINE cCodRet   CHAR(5);
DEFINE cSucursal CHAR(4);
DEFINE cStatus   CHAR(2);
DEFINE mMonto    MONEY(14,2);

LET cCodRet   = '00000';
LET cSucursal = '';
LET cStatus   = '';
LET mMonto    = 0;

BEGIN
	ON EXCEPTION SET iSqlErr, iIsamErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO '/informix/JEPI/sp_valfolio.out';
	--TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	IF 	pEmpresa  = '0' OR pEmpresa  = '' OR 
		pSucursal = '0' OR pSucursal = '' OR
		pDivisa   = '0' OR pDivisa   = '' OR 
		pcajeroprincipal = '0' OR pcajeroprincipal = '' OR 
		pMonto    = 0 OR pFolioOpe   = '' THEN
			LET cCodRet = '00110';
	ELSE
		SELECT sucursal, status, monto INTO cSucursal, cStatus, mMonto FROM bdisuc:"informix".ss_mae_entradasalida WHERE folio_oper = pFolioOpe;
		
		IF cSucursal IS NULL THEN
			LET cCodRet = '00100';
			RETURN cCodRet;
		ELSE		
			IF cSucursal <> pSucursal THEN
				LET cCodRet = '00560';
				RETURN cCodRet;
			END IF;
			
			IF mMonto <> pMonto THEN
				LET cCodRet = '00102';
				RETURN cCodRet;
			END IF;

			IF cStatus <> '11' THEN
				IF cStatus = '08' THEN
					LET cCodRet = '00103';
					RETURN cCodRet;
				ELSE
					LET cCodRet = '00104';
					RETURN cCodRet;
				END IF;
			END IF;
		END IF;
	END IF;
	
	RETURN cCodRet;
END;
END PROCEDURE;
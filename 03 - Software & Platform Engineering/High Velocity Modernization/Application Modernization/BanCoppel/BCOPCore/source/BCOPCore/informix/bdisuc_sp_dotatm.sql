CREATE PROCEDURE "informix".sp_dotatm(
	pEmpresa  CHAR(3),
	pFolioOpe CHAR(8)) 
RETURNING CHAR(5), CHAR(4), MONEY(14,2);

DEFINE cCodRet    CHAR(5);
DEFINE iSqlErr    INTEGER;
DEFINE iIsamErr   INTEGER;
DEFINE iCont      INTEGER;
DEFINE cStatus    CHAR(2);
DEFINE cPlaza     CHAR(3);
DEFINE cAtm       CHAR(4);
DEFINE cNombre    CHAR(40);    
DEFINE cSucursal  CHAR(4);
DEFINE mMonto	  MONEY(14,2);
DEFINE cReversado CHAR(1);
DEFINE cTipoSuc   CHAR(2);

LET cCodRet    = '000';
LET iCont      = 0;
LET mMonto	   = 0;
LET cPlaza     = '';
LET cAtm       = '';
LET cNombre    = '';
LET cSucursal  = '';
LET cReversado = '';
LET cStatus    = '';
LET cTipoSuc   = '';

BEGIN
	ON EXCEPTION SET iSqlErr, iIsamErr
	   IF iSqlErr <> 0 THEN
		  LET cCodRet = iSqlErr;
		  RETURN cCodRet, cSucursal, mMonto;
	   END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO '/informix/jepolanco/sp_dotatm.out';
	--TRACE ON;

	IF 	pEmpresa  = '0' OR pEmpresa  = '' OR 
		pFolioOpe = '0' OR pFolioOpe = '' THEN 
			LET cCodRet = '110';
	ELSE
		SELECT COUNT(*) INTO iCont FROM bdisuc:"informix".ss_operaciones WHERE folio_oper = pFolioOpe;
		
		IF iCont > 0 THEN
			LET iCont = 0;
			SELECT COUNT(*) INTO iCont FROM bdisuc:"informix".ss_mae_entradasalida  WHERE folio_oper = pFolioOpe;
			
			IF iCont > 0 THEN	
				SELECT ope.sucursal, ope.reversado, ope.monto, mae.status INTO cSucursal, cReversado, mMonto, cStatus
				FROM bdisuc:"informix".ss_operaciones ope INNER JOIN bdisuc:"informix".ss_mae_entradasalida mae 
				ON ope.folio_oper = mae.folio_oper WHERE ope.folio_oper = pFolioOpe AND ope.reversado = '0';
				
				SELECT tpo_sucursal INTO cTipoSuc FROM bdinteg:"informix".si_sucursales WHERE sucursal = cSucursal;
				
				LET cTipoSuc = TRIM(cTipoSuc);
				
				IF cTipoSuc <> 'C' THEN
					LET cCodRet = '560';
				END IF;
			
				IF cStatus <> '11' THEN
					IF cStatus = '05' THEN
						LET cCodRet = '107';
					ELSE
						LET cCodRet = '104';
					END IF;	
				END IF;
			ELSE
				LET cCodRet = '100';
			END IF;  					
		ELSE
			LET cCodRet = '100';
		END IF;
	END IF;
	RETURN cCodRet, cSucursal, mMonto;
END;
END PROCEDURE;
CREATE PROCEDURE "informix".sp_verifica_exp(pEmpresa CHAR(3), pNumCte CHAR(9))
RETURNING CHAR(5), CHAR(1),  CHAR(1);
	--DEFINICION DE VARIABLES
DEFINE iSqlErr          INTEGER;
DEFINE cCodRet          CHAR(5);
DEFINE vdoccuantos      INTEGER;
DEFINE iIdentificacion  INTEGER;
DEFINE cIFE             CHAR(1);
DEFINE cCompDom         CHAR(1);

	--INICIALIZACION DE VARIABLES
LET iSqlErr         = 0;
LET cCodRet         = '00000';
LET vdoccuantos     = 0;
LET iIdentificacion = 0;
LET cIFE            = '1';
LET cCompDom        = '1'; 

	--SET DEBUG FILE TO 'sp_verifica_exp.out';
    --TRACE ON;

BEGIN
ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, cIFE, cCompDom;
			END IF;
		END EXCEPTION;

		SET ISOLATION DIRTY READ;
		SET LOCK MODE TO WAIT 3;

			SELECT FIRST 1 NVL(1,0)
			INTO vdoccuantos
			FROM "informix".dg_expediente
			WHERE empresa = pEmpresa
			AND cliente = pNumCte
			AND cod_docto IN ('0012','0015','0016','0017','0018','0031','0032','0033');

			IF (NVL(vdoccuantos,0) <=0) THEN
				LET cCompDom = '0';
			END IF;
		
		
			SELECT FIRST 1 NVL(1,0)
			INTO iIdentificacion
			FROM "informix".dg_expediente
			WHERE empresa = pEmpresa
			AND cliente = pNumCte
			AND cod_docto IN ('0001','0003','0013','0014','0022','0027','0028','0029','0030','0047','0061','0050','0092','0049','0048','0090','0938','0084');
			
			IF (NVL(iIdentificacion,0) <= '0') THEN
				LET cIFE = '0';
			END IF;

RETURN cCodRet, cIFE, cCompDom;

END
END PROCEDURE;
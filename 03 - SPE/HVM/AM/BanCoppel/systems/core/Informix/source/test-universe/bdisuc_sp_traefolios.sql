CREATE PROCEDURE "informix".sp_traefolios(pEmpresa CHAR(3),psuc CHAR(5))
RETURNING CHAR(5), CHAR(20);

DEFINE cCodRet 	  CHAR(5);
--DEFINE cFolio	  CHAR(8);
DEFINE iSqlErr 	  INTEGER; 
DEFINE iIsamErr   INTEGER;   
DEFINE cFolio char(20);

LET cFolio = '';
LET cCodRet = '00000';
LET iSqlErr = 0;
LET iIsamErr = 0;

BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr
			IF iSqlErr <> 0 THEN 
				LET cCodRet = iSqlErr;
				--ROLLBACK;
				RETURN cCodRet,cFolio;
			END IF;
		END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

    IF pEmpresa IS NULL OR pEmpresa='' OR psuc='' OR psuc IS NULL THEN
        let cCodRet='00001';
        RETURN cCodRet,cFolio;
    END IF;

    SELECT MIN(a.folio_oper) 
    INTO cFolio
    FROM ss_operaciones a,ss_mae_entradasalida b 
    WHERE a.sucursal=psuc 
    AND a.folio_oper=b.folio_oper 
    AND b.status = '11';

    IF cFolio IS NULL OR cFolio = '' THEN
        LET cCodRet='00001';
        LET cFolio= '';
        RETURN cCodRet,cFolio;
    END IF;

    RETURN cCodRet,cFolio;

END
END PROCEDURE;
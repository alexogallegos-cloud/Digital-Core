CREATE PROCEDURE "informix".sp_logapertura_prom(pId_promocion INT,
									 pCuenta CHAR(20))
RETURNING CHAR(3) AS codRet

DEFINE SQL_ERR          		INTEGER;
DEFINE vCodRet          		CHAR(3);
DEFINE vNumCte          		CHAR(20);

LET vCodRet = '000';

BEGIN

	ON EXCEPTION SET SQL_ERR
        LET vCodRet = SQL_ERR;
        RETURN vCodRet;
	END EXCEPTION;
	
	--SET DEBUG FILE TO '/home/informix/cliente_nuevo/sp_logapertura_prom.out';
    --TRACE ON;

	SET ISOLATION TO dirty READ;
    SET LOCK MODE TO wait 3;

	SELECT first 1 num_cte
	INTO vNumCte
	from sv_maeinv where cuenta = pCuenta;

	DELETE FROM sv_admintasas_instruccion_vencimiento WHERE num_cte = vNumCte;
	
	IF (pCuenta IS NULL OR LEN(pCuenta) = 0) OR (pId_promocion IS NULL) THEN
		LET vCodRet = '001';
		RETURN vCodRet;
	END IF;

	IF EXISTS  (select id_promocion from sv_logapertura_admintasas where id_promocion = pId_promocion AND cuenta = pCuenta) THEN
		LET vCodRet = '002';
		RETURN vCodRet;
	END IF;
	
	INSERT INTO sv_logapertura_admintasas(id_promocion, cuenta) VALUES (pId_promocion, pCuenta);

	RETURN vCodRet;

END

END PROCEDURE;
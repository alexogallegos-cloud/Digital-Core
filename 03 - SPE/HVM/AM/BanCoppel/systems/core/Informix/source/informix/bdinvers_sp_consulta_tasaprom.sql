CREATE PROCEDURE "informix".sp_consulta_tasaprom(pCuenta CHAR(20))

RETURNING CHAR(5)	AS codRet,
		  CHAR(1)   AS esTasaPromocional,
		  INT		AS idPromocion;

DEFINE SQL_ERR          		INTEGER;
DEFINE ERROR_INFO       		CHAR(80);
DEFINE ISAM_ERR         		INTEGER;
DEFINE vCodRet          		CHAR(5);
DEFINE vCount					SMALLINT;
DEFINE vIdPromocion 			INTEGER;
DEFINE vEsTasaPromocional 		CHAR(1);

LET vCodRet = '000';
LET vEsTasaPromocional = 'N';
LET vIdPromocion = -1;

BEGIN

	ON EXCEPTION SET SQL_ERR,ISAM_ERR,ERROR_INFO
        LET vCodRet = SQL_ERR;
        RETURN vCodRet, vEsTasaPromocional , vIdPromocion;
	END EXCEPTION;
	
	--SET DEBUG FILE TO '/home/sysifx/Miguel/Captacion/pruebas_admin_tasas/sp_consulta_tasaprom.out';
    --TRACE ON;
	
	IF pCuenta IS NULL OR LEN(pCuenta) = 0 THEN
		LET vCodRet = '001';
		RETURN vCodRet, vEsTasaPromocional ,vIdPromocion;
	END IF;
	
	SELECT id_promocion
	INTO vIdPromocion
	FROM sv_logapertura_admintasas
	WHERE cuenta = pCuenta;
	
	
	IF vIdPromocion IS NOT NULL THEN
		LET vEsTasaPromocional = 'S';
	END IF
	

	RETURN vCodRet, vEsTasaPromocional ,vIdPromocion;


END 

END PROCEDURE;
CREATE PROCEDURE "informix".sp_sn_insert_log_playroll_account(pSucursal CHAR(4), pNumCta CHAR(20), pTarjeta CHAR(20), pEjecutivo CHAR(20))
	RETURNING CHAR(5)

    DEFINE vCodRet	CHAR(5);
    DEFINE sqlErr	INTEGER;
    
    LET vCodRet    = "00001";
    LET sqlErr     = 0;    
BEGIN
	
	ON EXCEPTION SET sqlErr
		IF sqlErr <> 0 THEN
			LET vCodRet = sqlErr;
			RETURN vCodRet;
		END IF;
	END EXCEPTION;

    -- SET DEBUG FILE TO "/INFORMIXDUMP/sp_sn_insert_log_playroll_account.trc";
    -- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	IF NOT (TRIM(NVL(pSucursal,'')) = '' 
		OR TRIM(NVL(pNumCta,'')) = '' 
		OR TRIM(NVL(pEjecutivo,'')) = '') THEN    
       	    INSERT INTO "informix".sn_log_playroll_account(empresa, sucursal, cuenta, tarjeta, ejecutivo) 
			VALUES ("001", pSucursal, pNumCta, pTarjeta, pEjecutivo);
			LET vCodRet = "00000";
    END IF;

	RETURN vCodRet;
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Este procedimiento almacenado registra los movimientos hacia la cuenta de nomina',
'PETICION: Iniciativa cuenta Nomina',
'AUTOR: Jorge Arturo Astorga',
'FECHA DE CREACION: 2022/08/19',
'BD: bdiadminnomina';
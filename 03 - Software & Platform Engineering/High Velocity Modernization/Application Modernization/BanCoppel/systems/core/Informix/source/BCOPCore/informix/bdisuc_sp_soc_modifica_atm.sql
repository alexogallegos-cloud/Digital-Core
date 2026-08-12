CREATE PROCEDURE "informix".sp_soc_modifica_atm(pCentroCostos CHAR(4), pIdAtm CHAR(8), pCodPlazaAtm CHAR(3), pNumeroEmpleado CHAR(8))
RETURNING CHAR(6) AS codret, CHAR(4) AS sucursal,CHAR(50) AS cMsjRet, CHAR(6) AS cod_bitacora, CHAR(50) AS mensaje_bitacora;

DEFINE SQL_ERR INTEGER;
DEFINE ISAM_ERR INTEGER;
DEFINE ERROR_INFO VARCHAR(80);
DEFINE cCodRet CHAR(6);
DEFINE cMsjRet CHAR(50);
DEFINE cMsjRetSp CHAR(50);
DEFINE cCodRetSp CHAR(6);
DEFINE iSaldoTotalAtm INTEGER;

LET cCodRet = '';
LET cMsjRet = 'El ATM ha sido modificado correctamente';
LET cMsjRetSp = '';
LET cCodRetSp = '';

--SET DEBUG FILE TO "/ifxsif01/jepolanco/sp_soc_modifica_atm.out";
--TRACE ON;

	BEGIN
		ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
			LET cCodRet = SQL_ERR;
			LET cMsjRet = ERROR_INFO;
			RETURN TRIM(cCodRet), pCentroCostos, TRIM(cMsjRet), TRIM(cCodRetSp), TRIM(cMsjRetSp);
		END EXCEPTION;
	
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
	
		SELECT saldo_total INTO iSaldoTotalAtm FROM bdisuc:"informix".ss_atm WHERE cod_atm = pCentroCostos;
		
		IF iSaldoTotalAtm IS NULL OR iSaldoTotalAtm = 0 THEN
		
			UPDATE bdinteg:"informix".si_sucursales SET plaza_cajagen = pCodPlazaAtm WHERE sucursal = pCentroCostos;

			UPDATE bdisuc:"informix".ss_relacionccid SET id = pIdAtm WHERE cc = pCentroCostos;
		
			EXECUTE PROCEDURE bdisuc:"informix".sp_bitacora_atm('MODIFICACION', pCentroCostos, pIdAtm, pCodPlazaAtm, pNumeroEmpleado) INTO cCodRetSp, cMsjRetSp;
			
			RETURN TRIM(cCodRet), pCentroCostos, TRIM(cMsjRet), TRIM(cCodRetSp), TRIM(cMsjRetSp) WITH RESUME;
		ELSE
			LET cCodRet = '100';
			LET cMsjRet = 'El ATM cuenta con efectivo, favor de validar';
			RETURN TRIM(cCodRet), pCentroCostos, TRIM(cMsjRet), TRIM(cCodRetSp), TRIM(cMsjRetSp) WITH RESUME;
		END IF;
	END;						
END PROCEDURE;
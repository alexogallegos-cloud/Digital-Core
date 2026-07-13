CREATE PROCEDURE "informix".sp_soc_alta_atm(pCentroCostos CHAR(4), pIdAtm CHAR(8), pCodPlazaAtm CHAR(3), pNombreAtm CHAR(40), pNumeroEmpleado CHAR(8))
RETURNING CHAR(6) AS codret, CHAR(4) AS sucursal, CHAR(50) AS mensaje, CHAR(6) AS cob_bitacora, CHAR(50) AS mensaje_bitacora;

DEFINE SQL_ERR INTEGER;
DEFINE ISAM_ERR INTEGER;
DEFINE ERROR_INFO VARCHAR(80);
DEFINE cCodRet CHAR(6);
DEFINE cMsjRet CHAR(50);
DEFINE cMsjRetSp CHAR(50);
DEFINE cCodRetSp CHAR(6);
DEFINE cCodPlazaAtm CHAR(3);

LET cCodRet = '';
LET cMsjRet = 'El ATM ha sido agregado correctamente';
LET cMsjRetSp = '';
LET cCodRetSp = '';

--SET DEBUG FILE TO "/ifxsif01/jepolanco/sp_soc_alta_atm.out";
--TRACE ON;

	BEGIN
		ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
			LET cCodRet = SQL_ERR;
			LET cMsjRet = ERROR_INFO;
			UPDATE bdinteg:"informix".si_sucursales SET plaza_cajagen = cCodPlazaAtm WHERE sucursal = pCentroCostos;
			DELETE FROM bdisuc:"informix".ss_atms_sucursal WHERE cod_atm = pCentroCostos;
			DELETE FROM bdisuc:"informix".ss_relacionccid WHERE cc = pCentroCostos;			
			--ROLLBACK WORK;
			RETURN TRIM(cCodRet), pCentroCostos, TRIM(cMsjRet), TRIM(cCodRetSp), TRIM(cMsjRetSp);
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT plaza_cajagen INTO cCodPlazaAtm FROM bdinteg:"informix".si_sucursales WHERE sucursal = pCentroCostos;

		UPDATE bdinteg:"informix".si_sucursales SET plaza_cajagen = pCodPlazaAtm WHERE sucursal = pCentroCostos;

		INSERT INTO bdisuc:"informix".ss_atms_sucursal (empresa, sucursal, cod_atm, saldo_ant, realizo_pase_con) VALUES ('001', '9250', pCentroCostos, 0, 0);

		INSERT INTO bdisuc:"informix".ss_relacionccid (id, cc, descripcion) VALUES (pIdAtm, pCentroCostos, pNombreAtm);		
		
		EXECUTE PROCEDURE bdisuc:"informix".sp_bitacora_atm('ALTA', pCentroCostos, pIdAtm, pCodPlazaAtm, pNumeroEmpleado) INTO cCodRetSp, cMsjRetSp;

		RETURN TRIM(cCodRet), pCentroCostos, TRIM(cMsjRet), TRIM(cCodRetSp), TRIM(cMsjRetSp) WITH RESUME;	
	END;	
END PROCEDURE;
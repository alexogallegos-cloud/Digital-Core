CREATE PROCEDURE "informix".sp_inserta_numcaja_web(pEmpresa CHAR(3),pSucursal CHAR(4),pNumeroCaja CHAR(10),pUsuario CHAR(8),pSucursalCaja CHAR(4))
--DATOS A REGRESAR---
RETURNING	CHAR(5) AS cCodRet;

--DEFINICION DE VARIABLES--
DEFINE  cCodRet			CHAR(5);
DEFINE  cSuc			CHAR(4);
DEFINE  cCajaAnt		CHAR(10);
DEFINE  iSqlErr			INTEGER;

--INICIALIZACION DE VARIABLES--
LET cCodRet			= '00000';
LET cSuc			= '';
LET cCajaAnt		= '';
LET iSqlErr			= 0;

BEGIN
	ON EXCEPTION SET iSqlErr
	   IF (iSqlErr != 0) THEN
		  LET cCodRet = iSqlErr;
		  RETURN cCodRet;
	   END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO '/respaldosbd/claudio/sp_inserta_numcaja.out';
	--TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	IF NVL(pEmpresa,'') <> '' AND NVL(pSucursal,'') <> '' AND NVL(pNumeroCaja,'') <> '' AND NVL(pUsuario,'') <> '' AND NVL(pSucursalCaja,'') <> '' THEN

		SELECT sucursal INTO cSuc
		FROM bdinteg:"informix".si_sucursales
		WHERE empresa = pEmpresa AND sucursal = pSucursal;

		IF NVL(cSuc,'') = '' THEN
			LET cCodret = '01309';
		ELSE
			SELECT sucursal INTO cSuc
			FROM bdinteg:"informix".si_sucursales
			WHERE empresa = pEmpresa AND sucursal = pSucursalCaja;

			IF NVL(cSuc,'') = '' THEN
				LET cCodret = '01309';
			ELSE
				SELECT numerocaja INTO cCajaAnt
				FROM bdisuc:"informix".ss_numcajas WHERE empresa = pEmpresa
				AND numsucursal = pSucursalCaja AND numerocaja = pNumeroCaja;

				IF NVL(cCajaAnt,'') <> '' THEN
					LET cCodret = '01312';
				ELSE
					INSERT INTO bdisuc:"informix".ss_numcajas (empresa,numerocaja,numsucursal,numsuc_crea,tipopaquete,fecha_insert,estatus,usuarioalta,fechaalta,numempleado_cajaocupada,fecha_cajaocupada)
					VALUES (pEmpresa,pNumeroCaja,pSucursalCaja,pSucursal,3,CURRENT,'Activa',pUsuario,CURRENT,pUsuario,CURRENT);
				END IF;
			END IF;
		END IF;
	ELSE
		LET cCodRet ='01308';
	END IF
	RETURN cCodRet;
END;
END PROCEDURE
;
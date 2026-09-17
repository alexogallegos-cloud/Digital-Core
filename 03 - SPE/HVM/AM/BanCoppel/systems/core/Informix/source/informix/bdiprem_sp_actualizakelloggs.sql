CREATE PROCEDURE "informix".sp_actualizakelloggs(pEmpresa CHAR(3), pNumFolio CHAR(7), pEntregado CHAR(1), pNumCuenta CHAR(11),
												pSucursal CHAR(4), pUsuario CHAR(8), pMontoPremio DECIMAL(16,8))

RETURNING CHAR(5) AS CodRet,CHAR(5) As CodRet2;

--Definicion de Variables
DEFINE cEntregado	CHAR(1);
DEFINE cCodRet		CHAR(5);
DEFINE cCodRet2		CHAR(5);
DEFINE iSqlErr 		INTEGER;

--Inicializacion de Variables
LET cCodRet    = '00000';
LET cCodRet2   = '00000';
LET cEntregado = '';

--SET DEBUG FILE TO '/tmp/sp_actualizakelloggs.out';
--TRACE ON;

BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
		RETURN cCodRet, cCodRet2;
		END IF;
	END EXCEPTION;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO dirty READ;

	IF (pEmpresa IS NULL OR pEmpresa = '') OR (pNumFolio IS NULL OR pNumFolio = '')
		OR (pSucursal IS NULL OR pSucursal = '') OR (pUsuario IS NULL OR pUsuario = '') OR
		(pEntregado IS NULL OR pEntregado = '')  OR (pMontoPremio IS NULL OR pMontoPremio = '') THEN
		LET cCodRet2 = '00001';
	ELSE
		SELECT entregado INTO cEntregado
		FROM sc_promocion_kelloggs 
		WHERE folio = pNumFolio AND empresa = pEmpresa;

		IF dbinfo("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet2 = '00002';
		ELSE
			IF cEntregado = '1' THEN
				LET cCodRet2 = '00003';
			ELSE
				UPDATE sc_promocion_kelloggs
				SET entregado = pEntregado, cuenta_abono = pNumCuenta, folio = pNumFolio,
				sucursal = pSucursal, usuario_entrega = pUsuario, monto_premio = pMontoPremio, fecha_entrega = CURRENT	
				WHERE folio = pNumFolio AND empresa = pEmpresa;
			END IF;
		END IF;
	END IF;

	RETURN cCodRet, cCodRet2;
END;
END PROCEDURE

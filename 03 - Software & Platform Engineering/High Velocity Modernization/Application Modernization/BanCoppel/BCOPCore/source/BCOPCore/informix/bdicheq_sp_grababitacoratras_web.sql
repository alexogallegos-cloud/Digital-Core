CREATE PROCEDURE "informix".sp_grababitacoratras_web(pEmpresa CHAR(3),
                                   pCtaOrig     CHAR(20),
								   pCtaDest     CHAR(20),
								   pSucursal    CHAR(5),
								   pMonto       MONEY,
								   pEjecutivo   CHAR(20))

	RETURNING CHAR(5);

	DEFINE vCodRet CHAR(5);
	DEFINE vSqlErr, vIsamErr INTEGER;

	LET vCodRet = "00000";

	BEGIN
		ON EXCEPTION SET vSqlErr, vIsamErr
			IF vSqlErr != 0 THEN
				LET vCodRet = vSqlErr;
				RETURN vCodRet;
			END IF;
		END EXCEPTION;

	    SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;
	
		INSERT INTO sc_bitacoratraspaso
			(empresa, cta_origen, cta_destino, sucursal, monto, ejecutivo, fecha)
		VALUES
			(pEmpresa, pCtaOrig, pCtaDest, pSucursal, pMonto, pEjecutivo, Current);
		RETURN vCodRet;
	END;
END PROCEDURE;
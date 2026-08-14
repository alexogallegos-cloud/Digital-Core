CREATE PROCEDURE "informix".intercard_cancelatarjeta_debito_central(pEmpresa CHAR(3),
                  pCuenta CHAR(20), pNumTarjeta CHAR(20),
                  pNumCte CHAR(20))

	RETURNING
	CHAR(5); -- Codigo de retorno

	DEFINE vCodRet	  CHAR(5);
	DEFINE vActualizo INTEGER;
	DEFINE vSqlErr	  INTEGER;

	LET vcodret    = "000";
	LET vActualizo = 0;
	LET vSqlErr    = 0;

	BEGIN
		ON EXCEPTION SET vSqlErr
			IF vSqlErr <> 0 THEN
				LET vCodRet = vSqlErr;
				RETURN vCodRet;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
	
		-- ACTUALIZAR EL ESTADO DE LA TARJETA
		UPDATE
			bdicheq:sc_tarjeta
		SET
			status_tar = 'C'
		WHERE
			empresa = pEmpresa AND
			cuenta = pCuenta AND
			numcte = pNumCte AND
			num_tarjeta = pNumTarjeta;

        -- VERIFICAR SI SE CAMBIO EL ESTADO DE LA TARJETA
		SELECT
			1
		INTO
			vActualizo
		FROM
			bdicheq:sc_tarjeta
		WHERE
			empresa = pEmpresa AND
			cuenta = pCuenta AND
			numcte = pNumCte AND
			num_tarjeta = pNumTarjeta AND
			status_tar = 'C';

		IF vActualizo <> 1 THEN
			LET vCodRet = "254";
		END IF

		RETURN vCodRet;
	END
END PROCEDURE;
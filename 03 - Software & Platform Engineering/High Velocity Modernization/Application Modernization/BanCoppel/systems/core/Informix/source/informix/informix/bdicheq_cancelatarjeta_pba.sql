CREATE PROCEDURE "informix".cancelatarjeta_pba(pEmpresa CHAR(3),
                  pCuenta CHAR(20), pNumTarjeta CHAR(20),
                  pNumCte CHAR(20))

	RETURNING
	CHAR(5),MONEY(14,2); -- Codigo de retorno

	DEFINE vCodRet	  CHAR(5);
	DEFINE vActualizo INTEGER;
	DEFINE vSqlErr	  INTEGER;
        DEFINE vmonto_aut MONEY(14,2);

	LET vcodret    = "000";
	LET vActualizo = 0;
	LET vSqlErr    = 0;
        LET vmonto_aut = 0;

	BEGIN
		ON EXCEPTION SET vSqlErr
			IF vSqlErr <> 0 THEN
				LET vCodRet = vSqlErr;
				RETURN vCodRet,vmonto_aut;
			END IF;
		END EXCEPTION;


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

		-- Regresa el Monto Autorizado de la Tarjeta
                SELECT limite_aut INTO vmonto_aut
                FROM   sc_tarjeta
		WHERE  empresa = pEmpresa AND
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

		RETURN vCodRet,vmonto_aut;
	END
END PROCEDURE;
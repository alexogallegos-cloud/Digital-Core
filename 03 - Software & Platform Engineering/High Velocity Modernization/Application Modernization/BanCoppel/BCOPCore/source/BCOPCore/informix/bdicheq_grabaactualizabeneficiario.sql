CREATE PROCEDURE "informix".grabaactualizabeneficiario(pEmpresa CHAR(3), pNumeroCuenta CHAR(20), pNombre CHAR(40), pParentesco CHAR(20),  pPorcentaje SMALLINT, pNumeroCliente CHAR(20))

	--DATOS A REGRESAR---
	RETURNING
	CHAR(5);  -- Codigo de Retorno

	--DEFINICION DE VARIABLES--
	DEFINE vCantReg		SMALLINT;
	DEFINE vSiguiente	SMALLINT;
	DEFINE vCodRet		CHAR(5);

	--INICIALIZACION DE VARIABLES--
	LET vCodRet    = "000";
	LET vCantReg   = 0;
	LET vSiguiente = 0;

	IF EXISTS(SELECT 1 FROM bdicheq:sc_beneficiario WHERE empresa = pEmpresa AND cuenta = pNumeroCuenta AND numcte = pNumeroCliente) THEN

		UPDATE
			bdicheq:sc_beneficiario
		SET
			porcentaje = pPorcentaje, parentesco = pParentesco
		WHERE
			empresa = pEmpresa AND cuenta = pNumeroCuenta AND numcte = pNumeroCliente;
	ELSE
		SELECT NVL(MAX(secuencia), 0)+1 INTO vSiguiente FROM bdicheq:sc_beneficiario WHERE empresa = pEmpresa AND cuenta = pNumeroCuenta;

		INSERT INTO bdicheq:sc_beneficiario
			(empresa, cuenta, secuencia, nombre, parentesco, porcentaje, numcte)
		VALUES
			(pEmpresa, pNumeroCuenta, vSiguiente, pNombre, pParentesco, pPorcentaje, pNumeroCliente);
	END IF

	LET vCantReg = DBINFO("sqlca.sqlerrd2");

	IF vCantReg = 0 THEN
		LET vCodRet = "127";
	END IF

	RETURN vCodRet;
END PROCEDURE
;
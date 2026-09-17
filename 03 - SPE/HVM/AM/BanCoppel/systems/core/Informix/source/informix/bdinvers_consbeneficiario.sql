CREATE PROCEDURE "informix".consbeneficiario(pEmpresa CHAR(3),
                                             pNumeroCuenta CHAR(20))

	--DATOS A REGRESAR---
	RETURNING
	CHAR(5),  -- Codigo de Retorno
	CHAR(20), -- Numero de Cuenta
	CHAR(20), -- Numero de Cliente
	CHAR(9),  -- Porcentaje
	CHAR(2); -- Parentesco


	--DEFINICION DE VARIABLES--
	DEFINE vCantReg		SMALLINT;
	DEFINE vCodRet		CHAR(5);
	DEFINE vNumCuenta	CHAR(20);
	DEFINE vNumCliente	CHAR(20);
	DEFINE vPorcentaje  CHAR(9);
	DEFINE vParentesco	CHAR(2);

	--INICIALIZACION DE VARIABLES--
	LET vCodRet = "000";
	LET vCantReg = 0;

	FOREACH
		SELECT
			bdi_svbene.cuenta, bdi_svbene.numcte,
                        bdi_svbene.porcentaje, bdi_svbene.parentesco
		INTO
			vNumCuenta, vNumCliente, vPorcentaje,
                        vParentesco
		FROM
			bdinvers:sv_benefic bdi_svbene
		WHERE
			bdi_svbene.empresa = pEmpresa AND
			bdi_svbene.cuenta = pNumeroCuenta
			LET vCantReg = vCantReg + 1;
			RETURN vCodRet, vNumCuenta, vNumCliente,
                               vPorcentaje, vParentesco
                               WITH RESUME;
	END FOREACH;

	IF vCantReg = 0 THEN
	   LET vCodRet		= "128";
	   LET vNumCuenta  = "";
	   LET vNumCliente = "";
	   LET vPorcentaje = "";
	   LET vParentesco = "";

	   RETURN vCodRet, vNumCuenta, vNumCliente, vPorcentaje,
                  vParentesco;
	END IF
END PROCEDURE;
CREATE PROCEDURE "informix".bajabeneficiarios(pEmpresa CHAR(3), pNumeroCuenta CHAR(20), pNumeroCliente CHAR(20))

	--DATOS A REGRESAR---
	RETURNING
	CHAR(5);

	--DEFINICION DE VARIABLES--
	DEFINE vCodRet	CHAR(5);
	DEFINE vElimino	INTEGER;

	--INICIALIZACION DE VARIABLES--
	LET vCodRet  = "000";
	LET vElimino = 0;

-- set debug file to '/tmp/bajabeneficiarios.out';
 --trace on;

begin
	DELETE
        FROM
                bdicheq:sc_beneficiario
	WHERE
		empresa = pEmpresa AND cuenta = pNumeroCuenta AND numcte = pNumeroCliente;

	LET vElimino = DBINFO("sqlca.sqlerrd2");

	IF vElimino = 0 THEN
		LET vCodRet = "127";
	END IF

	RETURN vCodRet;
end;
END PROCEDURE;
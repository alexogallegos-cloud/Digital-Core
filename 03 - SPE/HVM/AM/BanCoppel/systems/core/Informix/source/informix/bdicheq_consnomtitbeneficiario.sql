CREATE PROCEDURE "informix".consnomtitbeneficiario(pEmpresa CHAR(3), pNumeroCuenta CHAR(20))

	--DATOS A REGRESAR---
	RETURNING
	CHAR(5),  -- Codigo de Retorno
	CHAR(20), -- Numero de Cuenta
	CHAR(20), -- Numero de Cliente
	CHAR(26), -- Apellido Paterno
	CHAR(26), -- Apellido Materno
	CHAR(26), -- Nombre1
	CHAR(26), -- Nombre2
	CHAR(13); -- RFC


	--DEFINICION DE VARIABLES--
	DEFINE vCodRet		CHAR(5);
	DEFINE vNumCuenta	CHAR(20);
	DEFINE vNumCliente	CHAR(20);
	DEFINE vApePat		CHAR(26);
	DEFINE vApeMat		CHAR(26);
	DEFINE vNombre1		CHAR(26);
	DEFINE vNombre2		CHAR(26);
	DEFINE vRFC			CHAR(13);
	DEFINE vtpopersona  CHAR(2);
    DEFINE vrazonsocial CHAR(26);
    DEFINE vesfisica    CHAR(1);
	DEFINE vRFC_alterno	CHAR(13);


	--INICIALIZACION DE VARIABLES--
	LET vCodRet = "000";
	LET vNumCuenta = pNumeroCuenta;
	LET vtpopersona   = "";
	LET vrazonsocial  = "";
	LET vesfisica     = "";
	LET vRFC_alterno  = "";

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;
    

	SELECT
		bdi_sicte.numcte, bdi_sicte.apell_paterno, bdi_sicte.apell_materno, bdi_sicte.nombre1, bdi_sicte.nombre2, bdi_sicte.rfc, bdi_sicte.rfc_alterno, bdi_sicte.razon_social, bdi_sicte.tpo_persona
	INTO
		vNumCliente, vApePat, vApeMat, vNombre1, vNombre2, vRFC, vRFC_alterno, vrazonsocial, vtpopersona
	FROM
		bdinteg:si_cliente bdi_sicte,
		bdicheq:sc_maechq dbc_sdmachq
	WHERE
		dbc_sdmachq.cuenta = pNumeroCuenta AND
		dbc_sdmachq.num_cte = bdi_sicte.numcte;
        -- AND	bdi_sicte.empresa = pEmpresa;
		--AND	bdi_sicte.tpo_persona = "01";

	IF vApePat IS NULL AND vNombre1 IS NULL AND vrazonsocial IS NULL THEN
		LET vCodRet		= "131";
		LET vNumCliente = "";
		LET vApePat		= "";
		LET vApeMat		= "";
		LET vNombre1	= "";
		LET vNombre2	= "";
		LET vRFC		= "";
	END IF

    SELECT es_fisica 
      INTO vesfisica
      FROM bdinteg:si_tipper
     WHERE tpo_persona = vtpopersona;

    IF vesfisica = "N" THEN
       LET vApePat = TRIM(vrazonsocial);
    END IF	   

	RETURN vCodRet, vNumCuenta, vNumCliente, vApePat, vApeMat, vNombre1, vNombre2, vRFC;

END PROCEDURE;
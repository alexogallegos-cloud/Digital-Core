CREATE PROCEDURE "informix".consctactebeneficiario_web(pEmpresa CHAR(3), pNumeroTarjeta CHAR(20))
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
	DEFINE iSqlErr INTEGER;
	DEFINE vCodRet CHAR(5);
	DEFINE vNumCuenta CHAR(20);
	DEFINE vNumCliente CHAR(20);
	DEFINE vApePat CHAR(26);
	DEFINE vApeMat CHAR(26);
	DEFINE vNombre1 CHAR(26);
	DEFINE vNombre2 CHAR(26);
	DEFINE vRFC CHAR(13);
	DEFINE cProdTransfer CHAR(4);
	DEFINE cProdTarjeta CHAR(4);
	

	--INICIALIZACION DE VARIABLES--
	LET iSqlErr = 0;
	LET vCodRet = "00000";
	LET cProdTransfer = "";
	LET cProdTarjeta = "";
	LET vNumCuenta  = "";
	LET vNumCliente = "";
	LET vApePat = "";
	LET vApeMat = "";
	LET vNombre1 = "";
	LET vNombre2 = "";
	LET vRFC = "";
	
	 BEGIN
        ON EXCEPTION SET iSqlErr
            LET vCodRet = iSqlErr;
            RETURN vCodRet, vNumCuenta, vNumCliente, vApePat, vApeMat, vNombre1, vNombre2, vRFC;
        END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;	
	
    -- SET DEBUG FILE TO "/tmp/consctactebeneficiario.out";
	-- TRACE ON;
	  
	-- CONSULTA --
	SELECT
		bdc_sctar.cuenta, bdi_sicte.numcte, bdi_sicte.apell_paterno, bdi_sicte.apell_materno, bdi_sicte.nombre1, bdi_sicte.nombre2, bdi_sicte.rfc
	INTO
		vNumCuenta, vNumCliente, vApePat, vApeMat, vNombre1, vNombre2, vRFC
	FROM
		bdicheq:"informix".sc_tarjeta bdc_sctar,
		bdicheq:"informix".sc_maechq dbc_sdmachq,
		bdinteg:"informix".si_cliente bdi_sicte
	WHERE
		bdc_sctar.empresa = pEmpresa AND
		bdc_sctar.tipo_tarjeta = "T" AND
		bdc_sctar.num_tarjeta = pNumeroTarjeta AND
		bdc_sctar.cuenta = dbc_sdmachq.cuenta AND
		dbc_sdmachq.num_cte = bdi_sicte.numcte AND
		bdi_sicte.tpo_persona = "01";


	SELECT valor
	INTO cProdTransfer
	FROM bditransfer:"informix".tf_param 
	WHERE cod_param = 4;

	SELECT prodtarjeta 
	INTO cProdTarjeta
	FROM bdicheq:"informix".sc_tarjeta 
	WHERE num_tarjeta = pNumeroTarjeta;
	
	IF TRIM(cProdTransfer) = TRIM(cProdTarjeta) THEN
			LET vCodRet = "00858";
	ELSE
		IF vApePat IS NULL AND vNombre1 IS NULL THEN
			LET vCodRet = "00255";
			LET vNumCuenta  = "";
			LET vNumCliente = "";
			LET vApePat		= "";
			LET vApeMat		= "";
			LET vNombre1	= "";
			LET vNombre2	= "";
			LET vRFC		= "";
		END IF
	
	END IF

	RETURN vCodRet, vNumCuenta, vNumCliente, vApePat, vApeMat, vNombre1, vNombre2, vRFC;
	
END;
END PROCEDURE
DOCUMENT
"Folio:1636",
"Autor:951421354 Mario Gallardo",
"Fecha:29/08/2014",
"ModificaciÃ³n: Se modifica SP para retornar error 858 en caso de que el producto de la tarjeta sea 8000.",
"Sustento: Cambios_Plataforma_Observaciones.doc",
"Solicita:Berenice Mendez Riveraz ",
"BD: bdicheq";

CREATE PROCEDURE "informix".consnomtitbeneficiario_web(pEmpresa CHAR(3), pNumeroCuenta CHAR(20))

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

	LET vCodRet = "00000";
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
		LET vCodRet		= "00131";
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
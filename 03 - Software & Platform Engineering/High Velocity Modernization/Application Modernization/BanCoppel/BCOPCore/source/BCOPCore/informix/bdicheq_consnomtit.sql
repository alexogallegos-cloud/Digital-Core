CREATE PROCEDURE "informix".consnomtit(pEmpresa CHAR(3), pNumeroCuenta CHAR(20))

	--DATOS A REGRESAR---
	RETURNING
	CHAR(5),  -- Codigo de Retorno
	CHAR(20), -- Numero de cliente
	CHAR(26), -- Apellido Paterno
	CHAR(26), -- Apellido Materno
	CHAR(26), -- Nombre1
	CHAR(26), -- Nombre2
	CHAR(13), -- RFC
    CHAR(4);  -- Numero de Producto	

	--DEFINICION DE VARIABLES--
	DEFINE vCodRet		CHAR(5);
	DEFINE vNumCliente	CHAR(20);
	DEFINE vApePat		CHAR(26);
	DEFINE vApeMat		CHAR(26);
	DEFINE vNombre1		CHAR(26);
	DEFINE vNombre2		CHAR(26);
	DEFINE vRFC      	CHAR(13);
    DEFINE vValProd     CHAR(4);
    DEFINE vNumProd     CHAR(4);
	DEFINE vtpopersona  CHAR(2);
    DEFINE vrazonsocial CHAR(26);
    DEFINE vesfisica    CHAR(1);
	DEFINE vRFC_alterno	CHAR(13);
	DEFINE vStatusCta   CHAR(1);
	
	--INICIALIZACION DE VARIABLES--
	LET vCodRet   	  = "000";
	LET vNumCliente   = "";
	LET vApePat	  	  = "";
	LET vApeMat	      = "";
	LET vNombre1	  = "";
	LET vNombre2	  = "";
	LET vRFC   	      = "";
    LET vValProd      = "";
    LET vNumProd      = "";
	LET vtpopersona   = "";
	LET vrazonsocial  = "";
	LET vesfisica     = "";
	LET vRFC_alterno  = "";
    LET vStatusCta    = "";
    set isolation to dirty read;
    set lock mode to wait 3;
     

	SELECT
		bdi_sicte.numcte, bdi_sicte.apell_paterno, bdi_sicte.apell_materno, 
                bdi_sicte.nombre1, bdi_sicte.nombre2, bdi_sicte.rfc, bdi_sicte.rfc_alterno, bdi_sicte.razon_social, bdi_sicte.tpo_persona,
	        dbc_sdmachq.producto, dbc_sdmachq.status_cta	
	INTO
		vNumCliente, vApePat, vApeMat, vNombre1, vNombre2, vRFC, vRFC_alterno, vrazonsocial, vtpopersona, vNumProd, vStatusCta

	FROM
		bdinteg:si_cliente bdi_sicte,
		bdicheq:sc_maechq dbc_sdmachq

	WHERE
		dbc_sdmachq.cuenta = pNumeroCuenta AND
		dbc_sdmachq.num_cte = bdi_sicte.numcte;
		--AND bdi_sicte.empresa = pEmpresa; AND bdi_sicte.tpo_persona = "01";

		IF vStatusCta = '2' THEN
		LET vCodRet = "200";
		RETURN vCodRet, "","","","","","","";
		END IF
		
    IF vApePat IS NULL AND vNombre1 IS NULL AND vrazonsocial IS NULL THEN
	   LET vCodRet = "100";
	END IF

    SELECT es_fisica 
      INTO vesfisica
      FROM bdinteg:si_tipper
     WHERE tpo_persona = vtpopersona;

    IF vesfisica = "N" THEN
       LET vApePat = TRIM(vrazonsocial);
    END IF	   

    SELECT valor
      INTO vValProd
      FROM bditarjeta:td_producto_emp
     WHERE codigo = vNumProd;

    IF vValProd IS NULL OR Trim(vValProd) = "" THEN
       LET vValProd = "501";
    END IF

	IF vRFC_alterno is not null and vRFC_alterno <> "" THEN
       LET vRFC = vRFC_alterno;
    END IF;	

    RETURN vCodRet, vNumCliente, vApePat, vApeMat, vNombre1, vNombre2, vRFC, vValProd;

END PROCEDURE;
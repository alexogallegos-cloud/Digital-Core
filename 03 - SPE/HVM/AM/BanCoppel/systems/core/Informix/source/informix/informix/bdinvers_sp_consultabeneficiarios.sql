CREATE PROCEDURE "informix".sp_consultabeneficiarios(pEmpresa CHAR(3),pNumeroCuenta CHAR(20))

	--DATOS A REGRESAR---
	RETURNING
	CHAR(5),  	-- Codigo de Retorno
	CHAR(20), 	-- Numero de Cuenta
	CHAR(20), 	-- Numero de Cliente
	CHAR(9),  	-- Porcentaje
	CHAR(26),	-- Apellido Paterno
	CHAR(26),	-- Apellido Materno
	CHAR(26),	-- Nombre1
	CHAR(26),	-- Nombre2
	CHAR(13),	-- RFC
	CHAR(10),	-- Fecha de Nacimiento
	CHAR(20); 	-- Parentesco


	--DEFINICION DE VARIABLES--
	DEFINE iSqlErr      INTEGER;
	DEFINE cCodRet		CHAR(5);
	DEFINE vNumCuenta	CHAR(20);
	DEFINE vNumCliente	CHAR(20);
	DEFINE vApellidoP	CHAR(26);
	DEFINE vApellidoM   CHAR(26);
	DEFINE vNombre1		CHAR(26);
	DEFINE vNombre2		CHAR(26);
	DEFINE vRFC			CHAR(13); 
	DEFINE vFechaNac	CHAR(10);
	DEFINE vPorcentaje  CHAR(9);
	DEFINE vParentesco	CHAR(20);
	DEFINE vRFC_alterno	CHAR(13);

	--INICIALIZACION DE VARIABLES--
	LET iSqlErr			= 0;
	LET cCodRet 		= "000";
	LET vNumCuenta  	= "";
	LET vNombre1		= "";
	LET vNombre2		= "";
	LET vApellidoP		= "";
	LET vApellidoM		= "";
	LET vRFC			= "";
	LET vFechaNac   	= "";
	LET vNumCliente 	= "";
	LET vPorcentaje 	= "";
	LET vParentesco 	= "";
	LET vRFC_alterno    = "";

   --SET DEBUG FILE TO "/respaldosbd/felipe/sp_consultabeneficiarios.out";
   --TRACE ON;

 BEGIN
    ON EXCEPTION SET iSqlErr
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
			RETURN cCodRet, vNumCuenta, vNumCliente, vPorcentaje, vApellidoP, vApellidoM, vNombre1, vNombre2, vRFC, vFechaNac, vParentesco;
        END IF;
    END EXCEPTION;
	
	SET LOCK MODE TO WAIT 3;
	
	IF pEmpresa IS NULL OR TRIM(pEmpresa) = "" OR pNumeroCuenta IS NULL OR TRIM(pNumeroCuenta) = "" THEN
		LET cCodRet = "086";
		RETURN cCodRet, vNumCuenta, vNumCliente, vPorcentaje, vApellidoP, vApellidoM, vNombre1, vNombre2, vRFC, vFechaNac, vParentesco;
	END IF;	
	
	IF EXISTS(SELECT 1 FROM bdinvers:"informix".sv_benefic WHERE empresa = pEmpresa AND cuenta = pNumeroCuenta) THEN
		FOREACH
		
			SELECT 
				bdi_svbene.cuenta, bdi_svbene.numcte,
				bdi_sicte.apell_paterno,bdi_sicte.apell_materno,
				bdi_sicte.nombre1,bdi_sicte.nombre2,bdi_sicte.rfc, bdi_sicte.rfc_alterno, 
				bdi_sicpf.fecha_nac, bdi_svbene.porcentaje,
				bdi_svbene.parentesco
			INTO
				vNumCuenta, vNumCliente, vApellidoP, vApellidoM,
				vNombre1, vNombre2, vRFC, vRFC_alterno, vFechaNac, vPorcentaje,
				vParentesco
			FROM
				bdinvers:"informix".sv_benefic AS bdi_svbene,
				bdinteg:"informix".si_cliente AS bdi_sicte,
				bdinteg:"informix".si_ctepf as bdi_sicpf
			WHERE
				bdi_svbene.empresa =  bdi_sicte.empresa AND
				bdi_sicte.empresa  = bdi_sicpf.empresa  AND
				bdi_svbene.empresa = pEmpresa AND
				bdi_sicte.numcte = bdi_svbene.numcte AND
				bdi_sicpf.numcte = bdi_sicte.numcte AND
				bdi_svbene.cuenta = pNumeroCuenta
				
			IF vRFC_alterno is not null and vRFC_alterno <> "" THEN
               LET vRFC = vRFC_alterno;
            END IF;	
					
			RETURN cCodRet, vNumCuenta, vNumCliente, vPorcentaje, vApellidoP, vApellidoM, vNombre1, vNombre2, vRFC, vFechaNac, vParentesco WITH RESUME;
				
		END FOREACH;
	ELSE
		LET cCodRet	= "128";
		RETURN cCodRet, vNumCuenta, vNumCliente, vPorcentaje, vApellidoP, vApellidoM, vNombre1, vNombre2, vRFC, vFechaNac, vParentesco;
	END IF;
 END;	
END PROCEDURE


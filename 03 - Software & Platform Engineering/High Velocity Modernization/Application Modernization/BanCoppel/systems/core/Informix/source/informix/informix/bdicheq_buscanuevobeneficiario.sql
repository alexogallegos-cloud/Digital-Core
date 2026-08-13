CREATE PROCEDURE "informix".buscanuevobeneficiario(pEmpresa CHAR(3), pRFC CHAR(20))

	--DATOS A REGRESAR---
	RETURNING
	CHAR(5),  -- Codigo de Retorno
	CHAR(20), -- Numero de cliente
	CHAR(26), -- Apellido Paterno
	CHAR(26), -- Apellido Materno
	CHAR(26), -- Nombre1
	CHAR(26), -- Nombre2
	CHAR(13), -- RFC
	CHAR(10); -- Fecha Nacimiento


	--DEFINICION DE VARIABLES--
	DEFINE vCantReg		SMALLINT;
	DEFINE vCodRet		CHAR(5);
	DEFINE vNumCte		CHAR(20);
	DEFINE vApePat		CHAR(26);
	DEFINE vApeMat		CHAR(26);
	DEFINE vNombre1		CHAR(26);
	DEFINE vNombre2		CHAR(26);
	DEFINE vRFC			CHAR(13);
	DEFINE vFechaNac	CHAR(10);


	--INICIALIZACION DE VARIABLES--
	LET vCodRet  = "000";
	LET vCantReg = 0;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3 ;


	SELECT
		bdi_sicte.numcte, bdi_sicte.apell_paterno, bdi_sicte.apell_materno, bdi_sicte.nombre1, bdi_sicte.nombre2, bdi_sicte.rfc,
		bdi_sictepf.fecha_nac
	INTO
		vNumCte, vApePat, vApeMat, vNombre1, vNombre2, vRFC, vFechaNac
	FROM
		bdinteg:si_cliente bdi_sicte,
		bdinteg:si_ctepf bdi_sictepf
	WHERE
		bdi_sicte.empresa = pEmpresa AND
		bdi_sicte.tpo_persona = "01" AND
		bdi_sicte.rfc = pRFC AND
		bdi_sicte.numcte = bdi_sictepf.numcte;

	LET vCantReg = DBINFO("sqlca.sqlerrd2");

	IF vCantReg = 0 THEN
		LET vCodRet		= "132";
		LET vNumCte		= "";
		LET vApePat		= "";
		LET vApeMat		= "";
		LET vNombre1	= "";
		LET vNombre2	= "";
		LET vRFC		= "";
		LET vFechaNac	= "";
	END IF

	RETURN vCodRet, vNumCte, vApePat, vApeMat, vNombre1, vNombre2, vRFC, vFechaNac;
END PROCEDURE
;
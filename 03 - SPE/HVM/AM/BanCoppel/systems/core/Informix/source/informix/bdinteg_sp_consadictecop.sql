CREATE PROCEDURE "informix".sp_consadictecop(pEmpresa CHAR(3), pNumCteCop CHAR(20), pTipo CHAR(1))

	--DATOS A REGRESAR---
	RETURNING
	CHAR(5),  -- Codigo de Retorno
	CHAR(20), -- Numero de cliente
	CHAR(26), -- Apellido Paterno
	CHAR(26), -- Apellido Materno
	CHAR(26), -- Nombre1
	CHAR(26), -- Nombre2
	CHAR(13); -- RFC

	--Rodolfo Tortolero Varela
	--19/12/2008
	--Consulta la tabla si_cliente para consultar los datos por número de cliente coppel

	--DEFINICION DE VARIABLES--
	DEFINE vCodRet		CHAR(5);
	DEFINE vNumCliente	CHAR(20);
	DEFINE vApePat		CHAR(26);
	DEFINE vApeMat		CHAR(26);
	DEFINE vNombre1		CHAR(26);
	DEFINE vNombre2		CHAR(26);
	DEFINE vRFC			CHAR(13);
	DEFINE vRFC_alterno CHAR(13);

	--INICIALIZACION DE VARIABLES--
	LET vCodRet		= "000";
	LET vNumCliente = "";
	LET vApePat		= "";
	LET vApeMat		= "";
	LET vNombre1	= "";
	LET vNombre2	= "";
	LET vRFC		= "";
	LET vRFC_alterno = "";

	SELECT
		numcte
	INTO
		vNumCliente
	FROM
		bdinteg:si_adiccoppel
	WHERE
		numctecoppel = pNumCteCop
	AND
		secuencia = 1;

    IF vNumCliente IS NOT NULL THEN
		IF pTipo = '1' THEN
			SELECT
				numcte, apell_paterno, apell_materno, nombre1, nombre2, rfc, rfc_alterno
			INTO
				vNumCliente, vApePat, vApeMat, vNombre1, vNombre2, vRFC, vRFC_alterno
			FROM
				bdinteg:si_cliente
			WHERE
				numcte = vNumCliente AND
				empresa = pEmpresa AND
				tpo_persona = "01";
			
			IF vRFC_alterno is not null and vRFC_alterno <> "" THEN
               LET vRFC = vRFC_alterno;
            END IF;	

			RETURN vCodRet, vNumCliente, vApePat, vApeMat, vNombre1, vNombre2, vRFC;
		END IF;

		IF pTipo = '2' THEN
			FOREACH
				SELECT
					numcte
				INTO
					vNumCliente
				FROM
					bdinteg:si_adiccoppel
				WHERE
					numctecoppel = pNumCteCop
				AND
					secuencia > 1

				SELECT
					a.numcte, a.apell_paterno, a.apell_materno, a.nombre1, a.nombre2, a.rfc, a.rfc_alterno
				INTO
					vNumCliente, vApePat, vApeMat, vNombre1, vNombre2, vRFC, vRFC_alterno
				FROM
					bdinteg:si_cliente a, bdinteg:si_adiccoppel b
				WHERE
					a.numcte = vNumCliente AND
					a.empresa = pEmpresa AND
					a.numcte = b.numcte AND
					a.tpo_persona = "01";

				IF vRFC_alterno is not null and vRFC_alterno <> "" THEN
                   LET vRFC = vRFC_alterno;
                END IF;		
					
					RETURN vCodRet, vNumCliente, vApePat, vApeMat, vNombre1, vNombre2, vRFC WITH RESUME;

			END FOREACH;
		END IF;
	ELSE
		LET vCodRet = '001';
	END IF;

	IF vCodRet <> '000' THEN
		RETURN vCodRet, vNumCliente, vApePat, vApeMat, vNombre1, vNombre2, vRFC;
	END IF;
--##############################################################################
--## Procedimiento   : sp_ConsAdiCteCop
--## Base de Datos   : bdinteg
--## Version         : 1.0
--## Creado por      : Rodolfo Tortolero
--## Fecha creacion  : Febrero de 2009
--##Descripcion :  Consulta el Titular y los Adicionales de Clientes Coppel
--##############################################################################
END PROCEDURE;
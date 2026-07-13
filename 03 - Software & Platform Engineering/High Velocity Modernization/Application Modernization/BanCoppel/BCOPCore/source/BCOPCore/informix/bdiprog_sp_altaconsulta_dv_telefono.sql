CREATE PROCEDURE "informix".sp_altaconsulta_dv_telefono(pNumCliente CHAR(9), 
											 pNumTelefono CHAR (10), 
											 pDV CHAR(2),
											 pTipoOperacion INTEGER)
RETURNING CHAR (5), CHAR(2);

	-- Realizó: Javier Calderón
	-- Funcionalidad: agregar o consultar el dígito verificador de un teléfono frecuente
	-- Fecha: 24/09/2010
	-- Solicitó: Diana Castellanos
	
	DEFINE sql_err INTEGER;
	DEFINE vCodRet CHAR(5);
	DEFINE vDV CHAR(2);
	BEGIN
		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				LET vCodRet = sql_err;
				RETURN vCodRet, vDV;
			END IF;
		END EXCEPTION;
		
		LET vCodRet = '00000';
		LET vDV = '';
		
		IF pTipoOperacion = 1 THEN
			IF EXISTS(SELECT num_cte FROM pp_ctasterceros WHERE num_cte = pNumCliente AND cuenta = pNumTelefono AND cve_estado = '01') THEN
				UPDATE pp_ctasterceros SET digito_ver = pDV WHERE num_cte = pNumCliente AND cuenta = pNumTelefono AND cve_estado = '01';
			ELSE
				LET vCodRet = '00011'; -- Registro no encontrado con las condiciones especificadas al agregar el dígito verificador
			END IF;
		ELIF pTipoOperacion = 2 THEN
			IF EXISTS(SELECT num_cte FROM pp_ctasterceros WHERE num_cte = pNumCliente AND cuenta = pNumTelefono AND cve_estado = '01') THEN
				SELECT digito_ver INTO vDV FROM pp_ctasterceros WHERE num_cte = pNumCliente AND cuenta = pNumTelefono AND cve_estado = '01';
			ELSE
				LET vCodRet = '00012'; -- Registro no encontrado con las condiciones especificadas al consultar el dígito verificador
			END IF;
		ELSE
			LET vCodRet = '00010'; -- Tipo de operación incorrecto
		END IF;
		RETURN vCodRet, vDV;
	END;
END PROCEDURE;
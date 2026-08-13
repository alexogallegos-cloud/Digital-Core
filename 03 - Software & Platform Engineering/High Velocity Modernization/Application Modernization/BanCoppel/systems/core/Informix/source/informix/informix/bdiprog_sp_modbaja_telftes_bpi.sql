CREATE PROCEDURE "informix".sp_modbaja_telftes_bpi(pNumCliente  CHAR(10),
										pNumTelefono VARCHAR(15),
										pAlias VARCHAR(30),
										pDigito CHAR(1),
										pModo CHAR(1), 
										p_sCanal_Baja CHAR(2), 
										p_sUser_Insert CHAR(8),
										pCveCaducidad CHAR(1))
RETURNING
    CHAR(5),
	CHAR(60);

-- SP clonado para la edición/eliminación de teléfono frecuentes, a éste se agrega parametro para calcular la caducidad
-- Bibiana Gaxiola Verdugo
-- Marzo 2013

DEFINE vCodRet          CHAR(5);
DEFINE vMensaje         CHAR(60);
DEFINE iSqlErr			INTEGER;
DEFINE vDigito			CHAR(1);
DEFINE vDigitoGenerado  CHAR(1);
DEFINE vFechaCaducidad 	DATE;
DEFINE VExisteUser		CHAR(8);

LET vCodRet = '000';
LET vMensaje = '';
LET vDigito = '';
LET vDigitoGenerado = '';
LET vFechaCaducidad = '';
LET VExisteUser = NULL;

SET LOCK MODE TO WAIT 3;
SET ISOLATION TO DIRTY READ;

BEGIN
    ON EXCEPTION
        SET iSqlErr
        IF iSqlErr <> 0 THEN
            LET vCodRet = iSqlErr;
            RETURN vCodRet, vMensaje;
        END IF;
    END EXCEPTION;
	
	IF NVL(pNumCliente,'') = '' THEN
		LET vCodRet = '001';
		LET vMensaje = 'Parámetro cliente incorrecto';
		RETURN vCodRet, vMensaje;
	END IF;
	IF NVL(pNumTelefono,'') = '' THEN
		LET vCodRet = '002';
		LET vMensaje = 'Parámetro teléfono incorrecto';
		RETURN vCodRet, vMensaje;
	END IF;
	IF NVL(pAlias,'') = '' AND pModo = '1' THEN
		LET vCodRet = '003';
		LET vMensaje = 'Parámetro alias incorrecto';
		RETURN vCodRet, vMensaje;
	END IF;
	IF NVL(pDigito,'') = '' AND pModo = '1' THEN
		LET vCodRet = '004';
		LET vMensaje = 'Parámetro dígito incorrecto';
		RETURN vCodRet, vMensaje;
	END IF;
	IF NVL(pModo,'') = '' OR ( pModo <> '1' AND pModo <> '2' AND pModo <> '3') THEN
		LET vCodRet = '005';
		LET vMensaje = 'Parámetro modo incorrecto';
		RETURN vCodRet, vMensaje;
	END IF;
	IF NVL(p_sCanal_Baja,'') = '' AND pModo = '2' THEN
		LET vCodRet = '006';
		LET vMensaje = 'Parámetro canal baja incorrecto';
		RETURN vCodRet, vMensaje;
	END IF;
	IF NVL(p_sUser_Insert,'') = '' THEN
		LET vCodRet = '007';
		LET vMensaje = 'Parámetro usuario incorrecto';
		RETURN vCodRet, vMensaje;
	END IF;

	--SELECT LIMIT 1 user_insert INTO VExisteUser FROM bdiprog:pp_ctasterceros WHERE num_cte = pNumCliente AND cuenta = pNumTelefono AND cve_estado = '01';
		SELECT  LIMIT 1 user_insert INTO VExisteUser FROM
		(SELECT ct.user_insert
		FROM bdiprog: pp_ctasterceros ct
		WHERE ct.num_cte = pNumCliente
		AND ct.cuenta = pNumTelefono AND ct.cve_estado = '01'
		UNION 
		SELECT bex.user_insert 
		FROM bdiprog: pp_ctasterceros_bex bex
		WHERE bex.num_cte = pNumCliente
		AND bex.cuenta = pNumTelefono AND bex.cve_estado = '01') t;
	
	IF (VExisteUser IS NOT NULL) THEN 
	 IF pModo = 1 THEN --modificacion
		
			EXECUTE PROCEDURE bdisac:sp_calculadv(pNumTelefono) INTO vCodRet,vDigitoGenerado;
			IF vCodRet <> 0 THEN
				--LET vCodRet = '001';
				LET vMensaje = 'Error en el cálculo del dígito verificador';
				RETURN vCodRet, vMensaje;
			ELSE
				IF NVL(vDigitoGenerado,'') = '' THEN
					LET vCodRet = '001';
					LET vMensaje = 'Error en el número de dígitos del teléfono';
					RETURN vCodRet, vMensaje;
				ELIF vDigitoGenerado <> pDigito THEN
						LET vCodRet = '001';
						LET vMensaje = 'Error en el dígito verificador';
						RETURN vCodRet, vMensaje;					
				END IF;
			END IF;
			
			IF pCveCaducidad IS NOT NULL THEN 
						
				IF (pCveCaducidad = '1') THEN -- Caducidad 48 horas (2 días)
					LET vFechaCaducidad = TODAY + 2 UNITS DAY;

					UPDATE bdiprog:pp_ctasterceros SET descrip_cta = pAlias, digito_ver = pDigito, fecha_estado = current, 
						user_insert = p_sUser_Insert, cve_caducidad = pCveCaducidad, fecha_caducidad = vFechaCaducidad, fecha_movtos = today
						WHERE num_cte = pNumCliente AND cuenta = pNumTelefono;
				
				ELIF (pCveCaducidad = '2') THEN -- Caducidad 6 meses
					LET vFechaCaducidad = TODAY + 6 UNITS MONTH;
	
					UPDATE bdiprog:pp_ctasterceros SET descrip_cta = pAlias, digito_ver = pDigito, fecha_estado = current, 
						user_insert = p_sUser_Insert, cve_caducidad = pCveCaducidad, fecha_caducidad = vFechaCaducidad, fecha_movtos = today
						WHERE num_cte = pNumCliente AND cuenta = pNumTelefono;
							
				ELIF (pCveCaducidad = '3') THEN -- Caducidad indefinida - 1 año
					LET vFechaCaducidad = TODAY + 1 UNITS YEAR;
					
					UPDATE bdiprog:pp_ctasterceros SET descrip_cta = pAlias, digito_ver = pDigito, fecha_estado = current, 
						user_insert = p_sUser_Insert, cve_caducidad = pCveCaducidad, fecha_caducidad = vFechaCaducidad, fecha_movtos = today
						WHERE num_cte = pNumCliente AND cuenta = pNumTelefono;
				END IF;
				
			ELSE
				LET vCodRet = '003';
				LET vMensaje = 'Caducidad inválida';
				RETURN vCodRet, vMensaje;
			END IF;
					
		ELSE
			IF pModo = 2 THEN --baja
		
				UPDATE bdiprog:pp_ctasterceros SET cve_estado = '02',canal_baja = p_sCanal_Baja,fecha_estado = current,
				user_insert = p_sUser_Insert WHERE num_cte = pNumCliente AND cuenta = pNumTelefono;
			
			ELSE
				
				DELETE FROM bdiprog:pp_ctasterceros_bex WHERE num_cte = pNumCliente AND cuenta = pNumTelefono;
				
			END IF 
				
		END IF;
	ELSE
		LET vCodRet = '002';
		LET vMensaje = 'Número de teléfono frecuente no existe o esta dado de baja';
		RETURN vCodRet, vMensaje;
	END IF;

	RETURN vCodRet, vMensaje;
END;
END PROCEDURE;
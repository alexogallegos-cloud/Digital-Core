CREATE PROCEDURE "informix".sp_modbaja_telftes_bex(pNumCliente  CHAR(10),
										pNumTelefono VARCHAR(15),
										pAlias VARCHAR(30),
										pDigito CHAR(1),
										pModo CHAR(1),
										p_sCanal_Baja CHAR(2),
										p_sUser_Insert CHAR(8))
RETURNING
    CHAR(5),
	CHAR(60);


DEFINE vCodRet          CHAR(5);
DEFINE vMensaje         CHAR(60);
DEFINE iSqlErr			INTEGER;
DEFINE vDigito			CHAR(1);
DEFINE vDigitoGenerado  CHAR(1);
DEFINE vFechaCaducidad DATE;

LET vCodRet = '00000';
LET vMensaje = '';
LET vDigito = '';
LET vDigitoGenerado = '';
LET vFechaCaducidad = '';


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
		LET vMensaje = 'ParÃ¡metro cliente incorrecto';
		RETURN vCodRet, vMensaje;
	END IF;
	IF NVL(pNumTelefono,'') = '' THEN
		LET vCodRet = '002';
		LET vMensaje = 'ParÃ¡metro telÃ©fono incorrecto';
		RETURN vCodRet, vMensaje;
	END IF;
	IF NVL(pAlias,'') = '' AND pModo = '1' THEN
		LET vCodRet = '003';
		LET vMensaje = 'ParÃ¡metro alias incorrecto';
		RETURN vCodRet, vMensaje;
	END IF;
	IF NVL(pDigito,'') = '' AND pModo = '1' THEN
		LET vCodRet = '004';
		LET vMensaje = 'ParÃ¡metro dÃ­gito incorrecto';
		RETURN vCodRet, vMensaje;
	END IF;
	IF NVL(pModo,'') = '' OR ( pModo <> '1' AND pModo <> '2' ) THEN
		LET vCodRet = '005';
		LET vMensaje = 'ParÃ¡metro modo incorrecto';
		RETURN vCodRet, vMensaje;
	END IF;
	IF NVL(p_sCanal_Baja,'') = '' AND pModo = '2' THEN
		LET vCodRet = '006';
		LET vMensaje = 'ParÃ¡metro canal baja incorrecto';
		RETURN vCodRet, vMensaje;
	END IF;
	IF NVL(p_sUser_Insert,'') = '' THEN
		LET vCodRet = '007';
		LET vMensaje = 'ParÃ¡metro usuario incorrecto';
		RETURN vCodRet, vMensaje;
	END IF;

	IF EXISTS (SELECT user_insert FROM bdiprog:pp_ctasterceros_bex WHERE num_cte = pNumCliente AND cuenta = pNumTelefono AND cve_estado = '01') THEN
		IF pModo = 1 THEN --modificacion

			EXECUTE PROCEDURE bdisac:sp_calculadv(pNumTelefono) INTO vCodRet,vDigitoGenerado;
			IF vCodRet <> 0 THEN
				--LET vCodRet = '001';
				LET vMensaje = 'Error en el cÃ¡lculo del dÃ­gito verificador';
				RETURN vCodRet, vMensaje;
			ELSE
				IF NVL(vDigitoGenerado,'') = '' THEN
					LET vCodRet = '001';
					LET vMensaje = 'Error en el nÃºmero de dÃ­gitos del telÃ©fono';
					RETURN vCodRet, vMensaje;
				ELIF vDigitoGenerado <> pDigito THEN
						LET vCodRet = '001';
						LET vMensaje = 'Error en el dÃ­gito verificador';
						RETURN vCodRet, vMensaje;
				END IF;
				LET vCodRet = '00000';
			END IF;

			UPDATE bdiprog:pp_ctasterceros_bex SET descrip_cta = pAlias, digito_ver = pDigito, fecha_estado = current,
					user_insert = p_sUser_Insert, fecha_movtos = today
					WHERE num_cte = pNumCliente AND cuenta = pNumTelefono;
						
		ELIF pModo = 2 THEN --baja

			UPDATE bdiprog:pp_ctasterceros_bex SET cve_estado = '02',canal_baja = p_sCanal_Baja,fecha_estado = current,
				user_insert = p_sUser_Insert WHERE num_cte = pNumCliente AND cuenta = pNumTelefono;

		END IF;
	ELSE
		LET vCodRet = '002';
		LET vMensaje = 'NÃºmero de telÃ©fono frecuente no existe o esta dado de baja';
		RETURN vCodRet, vMensaje;
	END IF;

	RETURN vCodRet, vMensaje;
END;
END PROCEDURE;
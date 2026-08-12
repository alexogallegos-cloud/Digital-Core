CREATE PROCEDURE "informix".sp_altatelefonoctasftes_migracion(pNumCliente  CHAR(9),
													pNumTelefono VARCHAR(10),
													pAlias VARCHAR(30),
													pDV CHAR(2))
RETURNING
    CHAR(5),
    CHAR(60);

--Creado por: Javier Calderon
--Actividad:  Si no existe el telefono se registra en la tabla pp_ctasterceros o se le agrega el DV
--Solicito:   Diana Castellanos
--Fecha:      24/09/2010

DEFINE vCodRet          CHAR(5);
DEFINE vMensaje         CHAR(60);
DEFINE iSqlErr			INTEGER;
LET vCodRet = '00000';
LET vMensaje = '';

BEGIN
    ON EXCEPTION
        SET iSqlErr
        IF iSqlErr <> 0 THEN
            LET vCodRet = iSqlErr;
            RETURN vCodRet, vMensaje;
        END IF;
    END EXCEPTION;

	IF NOT EXISTS (SELECT user_insert FROM bdiprog:pp_ctasterceros WHERE num_cte = pNumCliente AND cuenta = pNumTelefono AND cve_estado = '01') THEN

		EXECUTE PROCEDURE sp_altabajaterceros('01',
											  '05',
											  pNumCliente,
											  pNumTelefono,
											  '000',
											  pAlias,
											  'Telmex',
											  ' TME840315KT6',
											  '',
											  '00',
											  '',
											  '03',
											  '00',
											  'transBPI') INTO vCodRet, vMensaje;
		IF vCodRet <> '00000' THEN
			RETURN vCodRet, vMensaje;
		END IF;
		EXECUTE PROCEDURE sp_altaconsulta_dv_telefono(pNumCliente, pNumTelefono, pDV, 1) INTO vCodRet, vMensaje;
	ELIF EXISTS (SELECT user_insert FROM bdiprog:pp_ctasterceros WHERE num_cte = pNumCliente AND cuenta = pNumTelefono AND cve_estado = '01' AND digito_ver = '') THEN
		EXECUTE PROCEDURE sp_altaconsulta_dv_telefono(pNumCliente, pNumTelefono, pDV, 1) INTO vCodRet, vMensaje;
	ELSE
		RETURN '00001', 'EL REGISTRO YA EXISTE CON LOS DATOS CORRECTOS';
	END IF;

	RETURN vCodRet, vMensaje;
END;
END PROCEDURE;
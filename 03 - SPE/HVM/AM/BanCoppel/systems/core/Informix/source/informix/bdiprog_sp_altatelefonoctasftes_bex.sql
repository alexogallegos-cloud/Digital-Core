CREATE PROCEDURE "informix".sp_altatelefonoctasftes_bex(pNumCliente  CHAR(10),
										pNumTelefono VARCHAR(15),
										pAlias VARCHAR(30),
										pDigito CHAR(1),
										p_sUser CHAR(8))
RETURNING
    CHAR(5),
	CHAR(60);

DEFINE vCodRet          CHAR(5);
DEFINE vMensaje         CHAR(60);
DEFINE iSqlErr			INTEGER;
DEFINE vDigito			CHAR(1);
DEFINE vFechaCaducidad DATE; --
LET vCodRet = '00000';
LET vMensaje = '';
LET vDigito = '';
LET vFechaCaducidad = ''; --

SET LOCK MODE TO WAIT 10;
--SET DEBUG FILE TO "/informix/ireb/bdiprog/bex/sp_altatelefonoctasftes_bex.out";
--TRACE ON;

BEGIN
    ON EXCEPTION
        SET iSqlErr
        IF iSqlErr <> 0 THEN
            LET vCodRet = iSqlErr;
            RETURN vCodRet, vMensaje;
        END IF;
    END EXCEPTION;

	--- Validar que el tÃ?ÃÂ©lefono frecuente no exista en la tabla pp_ctasterceros_bex
	IF (SELECT count(user_insert) FROM bdiprog:"informix".pp_ctasterceros_bex WHERE num_cte = pNumCliente AND cuenta = pNumTelefono AND cve_estado = '01') = 0 THEN
		EXECUTE PROCEDURE bdiprog:"informix".sp_altabajaterceros_bex('01',
											  '05',
											  pNumCliente,
											  pNumTelefono,
											  '201',
											  pAlias,
											  'Telmex',
											  ' TME840315KT6',
											  '',
											  '00',
											  '',
											  '03',
											  '00',
											  p_sUser) INTO vCodRet, vMensaje;

		IF vCodRet = '00000' THEN
			EXECUTE PROCEDURE bdiprog:"informix".sp_altaconsultadigito_bex(pNumCliente,pNumTelefono,'201',pDigito,'1') INTO vCodRet, vMensaje, vDigito;
		END IF;
	/*ELIF   ---- Valida que el TelÃ?ÃÂ©fono frecuente que fue dado de alta en sucursal y no tienen digito verificador para permitir su registro
		(SELECT count(user_insert) FROM bdiprog:"informix".pp_ctasterceros_bex WHERE num_cte = pNumCliente AND cuenta = pNumTelefono AND cve_estado = '01' AND digito_ver = '') = 1 THEN
			EXECUTE PROCEDURE bdiprog:"informix".sp_altabajaterceros_bex('01',
											  '05',
											  pNumCliente,
											  pNumTelefono,
											  '201',
											  pAlias,
											  'Telmex',
											  ' TME840315KT6',
											  '',
											  '00',
											  '',
											  '03',
											  '00',
											  p_sUser) INTO vCodRet, vMensaje;

		IF vCodRet = '00000' THEN
			EXECUTE PROCEDURE bdiprog:"informix".sp_altaconsultadigito_bex(pNumCliente,pNumTelefono,'201',pDigito,'1') INTO vCodRet, vMensaje, vDigito;
		END IF;*/

	ELSE
		LET vCodRet = '90000';
		LET vMensaje = 'La cuenta ya existe';
	END IF;

	RETURN vCodRet, vMensaje;
END;
END PROCEDURE;
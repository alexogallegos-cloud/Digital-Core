CREATE PROCEDURE "informix".sp_altatelefonoctasftes_bpi(pNumCliente  CHAR(10),
										pNumTelefono VARCHAR(15),
										pAlias VARCHAR(30),
										pDigito CHAR(1),
										p_sUser CHAR(8), p_CveCaducidad CHAR(1))
RETURNING
    CHAR(5),
	CHAR(60);

--Se clona el sp sp_altatelefonoctasftes para incluir el manejo de caducidad de las cuentas frecuentes
--Modifico: Berenice Noriega
--Fecha:    2013-01-17
------------------------------------------------------------------------------------------------------------------------------
-- Se agrega la condiciÃ?Â³n para que tambiÃ?Â©n se ejecute el SP sp_altabajaterceros_bpi cuando el telÃ?Â©fono frecuente se encuentra
-- todavÃ?Â­a activo pero no tiene dÃ?Â­gito verificador
-- Bibiana Gaxiola Verdugo.
-- 06/03/2014

-------------------------------------------------------------------------------------------------------------------------------
-- Se modifica el cÃ³digo de retorno a '90000', 'la cuenta ya existe'.
-- Modifico: Jorge Bibriesca
-- Fecha: 03/08/2017

-------------------------------------------------------------------------------------------------------------------------------

DEFINE vCodRet          CHAR(5);
DEFINE vMensaje         CHAR(60);
DEFINE iSqlErr			INTEGER;
DEFINE vDigito			CHAR(1);
DEFINE vFechaCaducidad DATE; --
LET vCodRet = '000';
LET vMensaje = '';
LET vDigito = '';
LET vFechaCaducidad = ''; --

SET LOCK MODE TO WAIT 10;
--SET DEBUG FILE TO "/home/informix/bibiana/sp_altatelefonoctasftes_bpi.out";
--TRACE ON;

BEGIN
    ON EXCEPTION
        SET iSqlErr
        IF iSqlErr <> 0 THEN
            LET vCodRet = iSqlErr;
            RETURN vCodRet, vMensaje;
        END IF;
    END EXCEPTION;

	--- Validar que el tÃ?Â©lefono frecuente no exista en la tabla pp_ctasterceros
	IF (SELECT count(user_insert) FROM bdiprog:"informix".pp_ctasterceros WHERE num_cte = pNumCliente AND cuenta = pNumTelefono AND cve_estado = '01') = 0 THEN
		EXECUTE PROCEDURE bdiprog:"informix".sp_altabajaterceros_bpi('01',
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
											  p_sUser,p_CveCaducidad) INTO vCodRet, vMensaje;

		IF vCodRet = '00000' THEN
			EXECUTE PROCEDURE bdiprog:"informix".sp_altaconsultadigito(pNumCliente,pNumTelefono,'201',pDigito,'1') INTO vCodRet, vMensaje, vDigito;
		END IF;
	ELIF   ---- Valida que el TelÃ?Â©fono frecuente que fue dado de alta en sucursal y no tienen digito verificador para permitir su registro
		(SELECT count(user_insert) FROM bdiprog:"informix".pp_ctasterceros WHERE num_cte = pNumCliente AND cuenta = pNumTelefono AND cve_estado = '01' AND digito_ver = '') = 1 THEN
			EXECUTE PROCEDURE bdiprog:"informix".sp_altabajaterceros_bpi('01',
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
											  p_sUser,p_CveCaducidad) INTO vCodRet, vMensaje;

		IF vCodRet = '00000' THEN
			EXECUTE PROCEDURE bdiprog:"informix".sp_altaconsultadigito(pNumCliente,pNumTelefono,'201',pDigito,'1') INTO vCodRet, vMensaje, vDigito;
		END IF;

	ELSE
		LET vCodRet = '90000';
		LET vMensaje = 'La cuenta ya existe';
	END IF;

	RETURN vCodRet, vMensaje;
END;
END PROCEDURE;
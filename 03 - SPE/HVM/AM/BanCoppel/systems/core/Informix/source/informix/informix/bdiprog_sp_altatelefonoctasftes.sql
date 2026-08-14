CREATE PROCEDURE "informix".sp_altatelefonoctasftes(pNumCliente  CHAR(10),
										pNumTelefono VARCHAR(15),
										pAlias VARCHAR(30),
										pDigito CHAR(1),
										p_sUser CHAR(8))
RETURNING
    CHAR(5),
	CHAR(60);

--Creado por: Javier Calderon
--Actividad:  Si no existe el telefono se registra en la tabla pp_ctasterceros
--Solicito:   Mauricio Leon
--Fecha:      25/02/2010
--Modifico:   Walber Castro
--Razon:      Se agrego actualizacion del digito verificador y codigo de retorno para cuando el telefono ya exista.
--Fecha:      06/10/2010
--Modifico:   Walber Castro
--Razon:      Se agrega validación del status en el query del NOT EXISTS.
--Fecha:      25/10/2010
--Modifico:	Walber Castro
--Razon:    Se modifica la empresa de 000 a 201.
--Fecha:    2011-07-13
--Modifico: Walber Castro
--Razón:    Se agrega nuevo parámetro del usuario.
--Fecha:    2011-09-23

DEFINE vCodRet          CHAR(5);
DEFINE vMensaje         CHAR(60);
DEFINE iSqlErr			INTEGER;
DEFINE vDigito			CHAR(1);
LET vCodRet = '000';
LET vMensaje = '';
LET vDigito = '';

SET LOCK MODE TO WAIT 10;
--SET DEBUG FILE TO "/tmp/sp_altatelefonoctasftes.out";
--TRACE ON;

BEGIN
    ON EXCEPTION
        SET iSqlErr
        IF iSqlErr <> 0 THEN
            LET vCodRet = iSqlErr;
            RETURN vCodRet, vMensaje;
        END IF;
    END EXCEPTION;

	IF NOT EXISTS (SELECT user_insert FROM bdiprog:"informix".pp_ctasterceros WHERE num_cte = pNumCliente AND cuenta = pNumTelefono AND cve_estado = '01') THEN	
		EXECUTE PROCEDURE bdiprog:"informix".sp_altabajaterceros('01',
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
			EXECUTE PROCEDURE bdiprog:"informix".sp_altaconsultadigito(pNumCliente,pNumTelefono,'201',pDigito,'1') INTO vCodRet, vMensaje, vDigito;		END IF;
	ELSE
		LET vCodRet = '001';
	END IF;

	RETURN vCodRet, vMensaje;
END;
END PROCEDURE;
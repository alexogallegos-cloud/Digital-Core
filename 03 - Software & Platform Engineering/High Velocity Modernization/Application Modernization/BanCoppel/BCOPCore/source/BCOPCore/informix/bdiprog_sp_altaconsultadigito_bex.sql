CREATE PROCEDURE "informix".sp_altaconsultadigito_bex(pNumCliente  CHAR(10),
										pNumTelefono VARCHAR(15),
										pCveBanco VARCHAR(30),
										pDigito CHAR(1),
										pModo CHAR(1))--1.- Alta, 2.-Consulta
    RETURNING CHAR(5), CHAR(60), CHAR(1);

DEFINE vCodRet          CHAR(5);
DEFINE vMensaje         CHAR(60);
DEFINE iSqlErr			INTEGER;
DEFINE vDigito CHAR(1);
LET vCodRet = '00000';
LET vMensaje = '';
LET vDigito = '';

BEGIN
    ON EXCEPTION
        SET iSqlErr
        IF iSqlErr <> 0 THEN
            LET vCodRet = iSqlErr;
            RETURN vCodRet, vMensaje, vDigito;
        END IF;
    END EXCEPTION;
	
	IF  NVL(pNumCliente,'') = '' THEN
		LET vCodRet = '001';
		LET vMensaje = 'Hace falta parÃ¡metro NÃºmero Cliente';
		RETURN vCodRet, vMensaje, vDigito;
	END IF;
	
	IF  NVL(pNumTelefono,'') = '' THEN
		LET vCodRet = '001';
		LET vMensaje = 'Hace falta parÃ¡metro NÃºmero TelÃ©fono';
		RETURN vCodRet, vMensaje, vDigito;
	END IF;
	
	IF  NVL(pCveBanco,'') = '' THEN
		LET vCodRet = '001';
		LET vMensaje = 'Hace falta parÃ¡metro Banco';
		RETURN vCodRet, vMensaje, vDigito;
	END IF;
	
	IF  NVL(pModo,'') = '' THEN
		LET vCodRet = '001';
		LET vMensaje = 'Hace falta parÃ¡metro Modo (1.-Alta o 2.-Consulta)';
		RETURN vCodRet, vMensaje, vDigito;
	END IF;
	
	IF ( pModo = '1' ) AND NVL(pDigito,'') = '' THEN
		LET vCodRet = '001';
		LET vMensaje = 'Hace falta parÃ¡metro DÃ­gito Verificador';
		RETURN vCodRet, vMensaje, vDigito;
	END IF;	
	
	IF ( pModo != '1' AND pModo != '2' ) THEN
		LET vCodRet = '001';
		LET vMensaje = 'ParÃ¡metro Modo InvÃ¡lido (1.-Alta o 2.-Consulta)';
		RETURN vCodRet, vMensaje, vDigito;
	END IF;

	--Se valida que exista la cuenta para poder actualizar el DV o bien consultarlo ya sea el caso.
	IF EXISTS(SELECT num_cte FROM bdiprog:pp_ctasterceros_bex WHERE num_cte = pNumCliente AND cuenta = pNumTelefono AND cve_banco = pCveBanco) THEN			
		IF (pModo = '1') THEN
			UPDATE bdiprog:pp_ctasterceros_bex SET digito_ver = pDigito WHERE num_cte = pNumCliente AND cuenta = pNumTelefono AND cve_banco = pCveBanco;
			LET vMensaje = 'OPERACION REALIZADA SATISFACTORIAMENTE';
		ELSE
			SELECT NVL(digito_ver,'') INTO vDigito FROM bdiprog:pp_ctasterceros_bex WHERE num_cte = pNumCliente AND cuenta = pNumTelefono AND cve_banco = pCveBanco;
		END IF;		
	ELSE
		LET vCodRet = '001';
		LET vMensaje = 'No existe el telÃ©fono frecuente';
	END IF;	
	
    RETURN vCodRet, vMensaje, vDigito;
END
END PROCEDURE;
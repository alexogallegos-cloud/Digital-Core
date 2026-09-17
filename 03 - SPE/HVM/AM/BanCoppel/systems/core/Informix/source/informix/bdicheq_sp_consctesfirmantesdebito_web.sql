CREATE PROCEDURE "informix".sp_consctesfirmantesdebito_web(pEmpresa CHAR(3), pNumeroCuenta CHAR(20), pNumeroClienteFirmante CHAR(20))
    RETURNING CHAR(5);

    -- DECLARACION DE VARIABLES --
    DEFINE vCodRet        CHAR(5);
    DEFINE vCantReg       SMALLINT;
    DEFINE iSqlErr        INTEGER;
	DEFINE pNumeroCuenta2 CHAR(20);

    -- INICIALIZACION DE VARIABLES --
    LET vCodRet = "00000";
    LET vCantReg = 0;
    LET iSqlErr = 0;
	LET pNumeroCuenta2 = '';

BEGIN

	      ON EXCEPTION
			SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET vCodRet = iSqlErr;
				RETURN vCodRet;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO dirty READ;
		SET LOCK MODE TO wait 3;

    -- Consulta si el firmante de debito ya esta asignado a la cuenta
    -- Autor: Rodolfo Tortolero
    -- Fecha: 24 Dic 2008
    -- BD: bdinteg

    --set debug file to '/tmp/consctesfirmantesdebito.out';
    --trace on;

    -- BUSCA SI EL FIRMANTE YA ESTA ASOCIADO A LA CUENTA--
		IF LENGTH(pNumeroCuenta) > 11 THEN
			LET pNumeroCuenta2 = pNumeroCuenta;
			LET pNumeroCuenta = '';
			SELECT b.cuenta INTO pNumeroCuenta FROM bdicheq:sc_tarjeta a, bdicheq:sc_maechq b
			WHERE a.num_tarjeta = pNumeroCuenta2 AND a.cuenta = b.cuenta;
		END IF;

		IF(SELECT count(numcte) FROM sc_firmantes WHERE numcte = pNumeroClienteFirmante AND cuenta = pNumeroCuenta) > 0 THEN
			LET vCodRet = '00001';
		END IF;

		RETURN vCodRet;

END;
END PROCEDURE;
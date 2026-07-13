CREATE PROCEDURE "informix".registrarportabilidad(cEmpresa CHAR(3),
												 cNumcte CHAR (20),
												 cNumcta CHAR(20),
												 cBanco CHAR(60),
												 cNumCtaRef CHAR(20),
												 cFechaDep CHAR(60))
												 RETURNING CHAR(5);

-- DEFINICION DE VARIABLES
DEFINE vCodRet CHAR(5);
LET vCodRet = '00000';

--Set debug file to '/tmp/RegistrarPortabilidad.out';
--trace on;

	BEGIN
		IF (cEmpresa <> '' AND cNumcte <> '' AND cNumcta <> '' AND cBanco <> '' AND	cNumCtaRef <> '' AND cFechaDep <> '') THEN
			IF NOT EXISTS (SELECT cuenta FROM bdicheq:sc_portabilidad WHERE cuenta = cNumcta) THEN
				INSERT INTO bdicheq:sc_portabilidad
					(empresa, numcte, cuenta, bancoreferencia, cuentareferencia, fecha_deposita_nomina)
				VALUES (cEmpresa,cNumcte,cNumcta,cBanco,cNumCtaRef,cFechaDep);
			ELSE
				LET vCodRet = '0002'; --El Número de cuenta ya existe
			END IF;
		ELSE
			LET vCodRet = '0001'; --Se reciben datos vacíos
		END IF;
		RETURN vCodRet;
	END;
--*************************************************************************
--| Procedimiento   : RegistrarPortabilidad
--| Versión         : 1.0
--| Creado por      : Martha Aguirre
--| Fecha creacion  : Agosto de 2009
--| Descripción     : Obtención de los datos de la cuenta del cliente.
--*************************************************************************
END PROCEDURE;
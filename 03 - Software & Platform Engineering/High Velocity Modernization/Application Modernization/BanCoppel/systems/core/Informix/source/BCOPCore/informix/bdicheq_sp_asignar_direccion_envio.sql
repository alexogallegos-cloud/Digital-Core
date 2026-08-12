CREATE PROCEDURE "informix".sp_asignar_direccion_envio(pEmpresa char(3), pCuenta char(20), pDirEnvio smallint)
        RETURNING char(5);

    -- Realizo   : Javier Humberto Calderon Zazueta
    -- Actividad : Asignar la direccion de envio
    -- Solicitó  : Mauricio Leon Ibarra
    -- Fecha     : 22/03/2010

   DEFINE vCodret   char(5);
   DEFINE sql_err integer;

	ON EXCEPTION SET sql_err
	   IF sql_err <> 0 THEN
		LET vCodret = sql_err;
		RETURN vCodret;
	   END IF;
	END EXCEPTION;

	LET vCodret = '000';
	
	BEGIN
		UPDATE sc_maechq SET direcc_envio = pDirEnvio WHERE empresa = pEmpresa AND cuenta = pCuenta;
		RETURN vCodret;
	END;

END PROCEDURE;
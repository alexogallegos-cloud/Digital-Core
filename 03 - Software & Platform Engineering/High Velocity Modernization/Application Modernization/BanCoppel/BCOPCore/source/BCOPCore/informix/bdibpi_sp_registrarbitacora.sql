CREATE PROCEDURE "informix".sp_registrarbitacora(pUsuario char(9), pDescripcion char(50), pIp char(15))
        RETURNING char(5);

    -- Realizo   : Javier Humberto Calderon Zazueta
    -- Actividad : Agregar en bitacora cuando un usuario entra con una misma sesion desde otro lugar
    -- Solicitó  : Mauricio Leon Ibarra
    -- Fecha     : 07/05/2010

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
		INSERT INTO tkn_bitacoracceso (descripcion, ip, usuario) VAlUES (pDescripcion, pIp, pUsuario);
		RETURN vCodret;
	END;

END PROCEDURE;
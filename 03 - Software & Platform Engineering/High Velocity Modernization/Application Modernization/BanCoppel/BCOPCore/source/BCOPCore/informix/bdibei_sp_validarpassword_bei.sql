CREATE PROCEDURE "informix".sp_validarpassword_bei(pEmpresa char(3), pUsuario char(50), pPass char(50))
   returning char(5);

--Creador:
--Fecha:
--Actividad: Permite validar si la contraseÃ±a del usuario es correcta

    DEFINE cCod_ret char(5);
	DEFINE sql_err integer ;

	LET cCod_ret  = "000";

	Set isolation to dirty read;



	BEGIN
		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				LET cCod_ret = sql_err;
				RETURN cCod_ret;
			END IF ;
		END EXCEPTION ;

		SET LOCK MODE TO WAIT ;
		SET ISOLATION DIRTY READ ;

		IF EXISTS (SELECT num_cliente FROM "informix".bei_usuario  WHERE usuario_bei = pUsuario AND pass = pPass ) THEN
			LET cCod_ret = '000';  -- Sesion iniciada
		ELSE
			LET cCod_ret = '001';  -- Usuario y/o ContraseÃ±a incorrecta
		END IF ;
		RETURN cCod_ret;
	END
END PROCEDURE ;
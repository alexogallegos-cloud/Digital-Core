CREATE PROCEDURE "informix".sp_validarpassword_bei(pEmpresa char(3), pUsuario char(50), pPass char(50))
   returning char(5);

--Creador: Manuel Ramos Figueroa
--Fecha: 15/08/2011
--Actividad: Permite validar si la contraseña del usuario es correcta

    DEFINE cCod_ret char(5);
	DEFINE sql_err integer ;

	LET cCod_ret  = "000";
	
	Set isolation to dirty read;

 --SET DEBUG FILE TO '/tmp/sp_loginusuario_bpi.out';
 --TRACE ON;

	BEGIN
		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				LET cCod_ret = sql_err;
				RETURN cCod_ret;
			END IF ;
		END EXCEPTION ;

		SET LOCK MODE TO WAIT ;
		SET ISOLATION DIRTY READ ;
		
		IF EXISTS (SELECT num_cliente FROM bdinteg:"informix".si_bpiusuariospm  WHERE empresa = pEmpresa AND usuario = pUsuario AND pass = pPass ) THEN
			LET cCod_ret = '000';  -- Sesion iniciada
		ELSE
			LET cCod_ret = '001';  -- Usuario y/o Contraseña incorrecta
		END IF ;
		RETURN cCod_ret;
	END
END PROCEDURE ;
CREATE PROCEDURE "informix".sp_cambiarpass_bei(pEmpresa char(3), pNumCte char(20),pIdUsuario 	INTEGER, pPass char(50))
   returning char(5);

   --Creador:
   --Actividad: Actualiza el password del usuario de BPI
   --Fecha 15-08-2011

   --****************************************************************************************************
	-- DESCRIPCION: Cambio de pass de los usuarios
	-- AUTOR : SOLSER
	-- FECHA : 
	-- BD: bdibei
	-- SOLICITO : BanCoppel
	-- Liberado a Producción: Mayo 2014
	--***************************************************************************************************

   
	DEFINE cCod_ret char(5);
    DEFINE sql_err integer ;

	LET cCod_ret  = 000;

	BEGIN
		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				LET cCod_ret = sql_err;
				RETURN cCod_ret;
			END IF ;
		END EXCEPTION ;

		SET LOCK MODE TO WAIT ;
		SET ISOLATION DIRTY READ ;

		IF EXISTS ( SELECT num_cliente FROM bdibei:"informix".bei_usuario WHERE id_usuario = pIdUsuario AND num_cliente = pNumCte ) THEN
			IF EXISTS ( SELECT num_cliente FROM bdibei:"informix".bei_usuario WHERE id_usuario = pIdUsuario AND num_cliente = pNumCte AND pass = pPass) THEN
				LET cCod_ret = '001';  -- Ya existe el pass
			ELSE
				IF EXISTS ( SELECT num_cliente FROM bdibei:"informix".bei_usuario WHERE id_usuario = pIdUsuario AND num_cliente = pNumCte AND pass1 = pPass) THEN
					LET cCod_ret = '001';  -- Ya existe el pass
				ELSE
					IF EXISTS ( SELECT num_cliente FROM bdibei:"informix".bei_usuario WHERE id_usuario = pIdUsuario AND num_cliente = pNumCte AND pass2 = pPass) THEN
						LET cCod_ret = '001';  -- Ya existe el pass
					ELSE
						IF EXISTS ( SELECT num_cliente FROM bdibei:"informix".bei_usuario WHERE id_usuario = pIdUsuario AND num_cliente = pNumCte AND pass3 = pPass) THEN
							LET cCod_ret = '001';  -- Ya existe el pass
						ELSE
							UPDATE bdibei:"informix".bei_usuario SET pass3 = TRIM(pass2), f_pass3 = current WHERE id_usuario = pIdUsuario AND num_cliente = pNumCte;
							UPDATE bdibei:"informix".bei_usuario SET pass2 = TRIM(pass1), f_pass2 = current WHERE id_usuario = pIdUsuario AND num_cliente = pNumCte;
							UPDATE bdibei:"informix".bei_usuario SET pass1 = TRIM(pass), f_pass1 = current WHERE id_usuario = pIdUsuario AND num_cliente = pNumCte;
							UPDATE bdibei:"informix".bei_usuario SET pass = TRIM(pPass), f_pass = current WHERE id_usuario = pIdUsuario AND num_cliente = pNumCte;

							LET cCod_ret = '000';  -- Pass modificado
						END IF;
					END IF;
				END IF;
			END IF;
		ELSE
			LET cCod_ret = '002';  -- No existe el Cliente
		END IF ;

		RETURN cCod_ret;
	END
END PROCEDURE;
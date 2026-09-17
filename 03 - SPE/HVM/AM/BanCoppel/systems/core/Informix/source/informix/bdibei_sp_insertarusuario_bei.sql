CREATE PROCEDURE "informix".sp_insertarusuario_bei(pNumCliente VARCHAR(9), pUsuario VARCHAR(50),pIdentAdmin	CHAR(30),pIdUsuario INTEGER)
RETURNING CHAR (5),INTEGER;

--****************************************************************************************************
-- DESCRIPCION:  Registra numero de cliente y el usuario
-- AUTOR : Irving Guzman Salas
-- FECHA : 24/05/2013
-- BD: bdibei
-- SOLICITO :
--***************************************************************************************************


	DEFINE sql_err int;
	DEFINE cCod_ret CHAR (5);
	DEFINE vNumCliente VARCHAR(9);
	DEFINE vUsuario VARCHAR(50);
	DEFINE iUsuario VARCHAR(50);
	DEFINE sIdUsuario INTEGER;
	DEFINE sIdStatus SMALLINT;
	DEFINE sNombre CHAR(250);
	LET cCod_ret = '00000';
	LET sNombre = '';
	LET sIdUsuario =0;
	LET sIdStatus =20;
	LET iUsuario='RESETUSUARIO';
	BEGIN
--****************************************************************************************************
-- Excepciones:
--***************************************************************************************************
		ON EXCEPTION SET sql_err
		  IF sql_err <> 0 THEN
				LET cCod_ret = sql_err;
				RETURN cCod_ret,NVL(sIdUsuario,0);
		  END IF ;
		END EXCEPTION ;
--****************************************************************************************************
-- Valida Si Nombre de Usuario ya esta Registrado:
--***************************************************************************************************

		SET LOCK MODE TO WAIT ;
		SET ISOLATION DIRTY READ ;


		SELECT num_cliente INTO vNumCliente FROM "informix".bei_usuario WHERE usuario_bei = pUsuario;

		IF NVL(vNumCliente, '') <> '' THEN
			LET cCod_ret = '00001'; -- Nombre de Usuario ya registrado
				RETURN cCod_ret,NVL(sIdUsuario,0);
		END IF;

--****************************************************************************************************
-- Proceso de Actualizacion o Insert:
--***************************************************************************************************

    IF NVL(pIdentAdmin,'') == '' THEN

		SELECT id_usuario,id_status,(nombre1||' '||nombre2||' '||apell_paterno||' '||apell_materno )
		INTO sIdUsuario,sIdStatus , sNombre
		FROM "informix".bei_servicio
		WHERE num_cliente = pNumCliente
		AND id_usuario = pIdUsuario;
    ELSE
		SELECT id_usuario,id_status,(nombre1||' '||nombre2||' '||apell_paterno||' '||apell_materno )
		INTO sIdUsuario,sIdStatus , sNombre
		FROM "informix".bei_servicio
		WHERE num_cliente = pNumCliente
		AND identificacion_admin = pIdentAdmin;
    END IF;

		IF NVL(sIdUsuario, -1) == -1 THEN

			INSERT INTO "informix".bei_usuario(id_usuario,usuario_bei, num_cliente, id_status,id_tipo_usuario,f_registro)
			VALUES (0,pUsuario, pNumCliente, sIdStatus,1,CURRENT);

			LET sIdUsuario = DBINFO('sqlca.sqlerrd1');

			UPDATE "informix".bei_servicio
			SET id_usuario=sIdUsuario ,id_status =sIdStatus
			WHERE identificacion_admin = pIdentAdmin
			AND num_cliente = pNumCliente;

			INSERT INTO "informix".bei_datos_usuario(id_usuario,nombre,activo)
			VALUES (sIdUsuario,sNombre,'t');

		ELSE
			LET iUsuario=iUsuario||sIdUsuario;
			SELECT usuario_bei
			INTO vUsuario
			FROM "informix".bei_usuario
			WHERE id_usuario = sIdUsuario
			AND num_cliente = pNumCliente;

			IF NVL(vUsuario, iUsuario) <> iUsuario THEN
				LET cCod_ret = '00002'; -- Usuario ya registrado
				RETURN cCod_ret,sIdUsuario;
			END IF;

			UPDATE "informix".bei_usuario
			SET usuario_bei=pUsuario ,id_status =sIdStatus
			WHERE id_usuario = sIdUsuario
			AND num_cliente = pNumCliente;

			INSERT INTO "informix".bei_datos_usuario(id_usuario,nombre,activo)
			VALUES (sIdUsuario,sNombre,'t');

		END IF;

		RETURN cCod_ret,NVL(sIdUsuario,0);

	END;

END PROCEDURE;
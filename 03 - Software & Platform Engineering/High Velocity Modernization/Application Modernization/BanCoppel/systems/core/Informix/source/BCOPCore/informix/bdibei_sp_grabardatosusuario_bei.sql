CREATE PROCEDURE "informix".sp_grabardatosusuario_bei(
									   pNumCliente VARCHAR(9),
									   pIdUsuario INTEGER,
									   pNumTel VARCHAR(15),
									   pCiaCel INT,
									   pEmail VARCHAR(80))
RETURNING CHAR (5);

--****************************************************************************************************
-- DESCRIPCION:  Registra Datos de Usuario
-- AUTOR : Irving Guzman Salas
-- FECHA : 24/05/2013
-- BD: bdibei
-- SOLICITO :
--***************************************************************************************************


	DEFINE sql_err int;
	DEFINE cCod_ret CHAR (5);
	DEFINE vNumCliente VARCHAR(9);

    DEFINE v_Empresa     CHAR(3);
    DEFINE v_TipoTel     SMALLINT;
    DEFINE v_Extension   CHAR(5);
    DEFINE v_Canal       SMALLINT;
    DEFINE v_UserInsert  CHAR(8);
    DEFINE v_codret1      CHAR(5);
    DEFINE v_codret2      CHAR(5);
    DEFINE v_TipoCorreo  SMALLINT;

	DEFINE sIdusuario				INTEGER;

    DEFINE sNombre				CHAR(250);


	LET sNombre = '';

	LET sIdusuario = -1;


	LET cCod_ret = '00000';
	LET vNumCliente = '';

	LET v_Empresa    = '001';
    LET v_TipoTel    = 2;
    LET v_Extension  = '';
    LET v_Canal      = 3;
    LET v_UserInsert = 'transBPI';
    LET v_codret1 = '00000';
    LET v_codret2 = '00000';
    LET v_TipoCorreo    = 1;

	BEGIN
		ON EXCEPTION SET sql_err
		  IF sql_err <> 0 THEN
				LET cCod_ret = sql_err;
				RETURN cCod_ret;
		  END IF ;
		END EXCEPTION ;

		SET LOCK MODE TO WAIT ;
		SET ISOLATION DIRTY READ ;

		IF NVL(pNumCliente,'') =='' THEN
	 	  	LET cCod_ret = '00002'; -- No contiene Dato de Numero de Cliente
       		RETURN cCod_ret;
		END IF;

		IF NVL(pIdUsuario,-1) ==-1 THEN
	 	  	LET cCod_ret = '00003'; -- No contiene Dato de Id Usuario
       		RETURN cCod_ret;
		END IF;

		SELECT id_usuario,nombre1||' '||nombre2||' '||apell_paterno||' '||apell_materno
		INTO sIdusuario, sNombre
		FROM "informix".bei_servicio WHERE num_cliente = pNumCliente AND id_usuario = pIdUsuario;

		IF NVL(sIdusuario, -1) == -1 THEN
			LET cCod_ret = '00004'; -- El Usuario no existe
       		RETURN cCod_ret;
		END IF;


		IF EXISTS (  SELECT id_usuario
   					FROM "informix".bei_servicio
   					WHERE num_cliente = pNumCliente
   					AND id_usuario = pIdUsuario) THEN


			UPDATE "informix".bei_datos_usuario  SET tel_celular=pNumTel ,cia_cel=pCiaCel,e_mail=pEmail WHERE id_usuario = pIdUsuario;

			IF (pNumTel <> '') THEN
				IF ((SELECT COUNT (telefono) FROM bdinteg:"informix".si_telefonos_actual WHERE numcte = pNumCliente AND telefono = pNumTel
						AND tipo_tel = v_TipoTel AND carrier = pCiaCel) = 0) THEN

                EXECUTE PROCEDURE bdinteg:"informix".sp_registra_telefonos(v_Empresa, pNumCliente, pNumTel, v_TipoTel,
                                                     v_Extension, pCiaCel, v_Canal,v_UserInsert)
                             INTO v_codret1;
				END IF;
            END IF;

            IF (pEmail <> '') THEN
				IF ((SELECT COUNT (correo_elec) FROM bdinteg:"informix".si_correos WHERE numcte = pNumCliente AND correo_elec = pEmail
						AND status_correo = 'A') =0) THEN
                EXECUTE PROCEDURE bdinteg:"informix".sp_registra_correos(v_Empresa,pNumCliente,pEmail,v_TipoCorreo,v_Canal,v_UserInsert)
                            INTO v_codret2;
				END IF;
            END IF;

		ELSE
			LET cCod_ret = '00001'; -- El usuario no es Administrador
		END IF;

		RETURN cCod_ret;

	END;

END PROCEDURE;
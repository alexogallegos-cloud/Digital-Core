CREATE PROCEDURE "informix".sp_actualizadatoscontacto_bei(pIdUsuario VARCHAR(9),
										   pCel VARCHAR(15),
										   pCiaCel INT,
										   pEmail VARCHAR(80))
RETURNING CHAR (5);

	DEFINE sql_err int;
	DEFINE cCod_ret CHAR (5);
	--variables para registro en nuevas tablas
    DEFINE v_Empresa     CHAR(3);
    DEFINE v_TipoTel     SMALLINT;
    DEFINE v_Extension   CHAR(5);
    DEFINE v_Canal       SMALLINT;
    DEFINE v_UserInsert  CHAR(8);
    DEFINE v_codret1      CHAR(5);
    DEFINE v_codret2      CHAR(5);
    DEFINE v_TipoCorreo  SMALLINT;

	LET cCod_ret = '00000';

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

		SET LOCK MODE TO WAIT 3;

		IF NVL(pcel,'')<>'' THEN
			UPDATE bdibei:"informix".bei_datos_usuario SET tel_celular = pCel WHERE id_usuario = pIdUsuario ;
		END IF;

		IF NVL(pCiaCel,-1)<>-1 THEN
			UPDATE bdibei:"informix".bei_datos_usuario SET cia_cel = pCiaCel, e_mail = pEmail WHERE id_usuario = pIdUsuario ;
		END IF;

		IF NVL(pEmail,'')<>'' THEN
			UPDATE bdibei:"informix".bei_datos_usuario SET e_mail = pEmail WHERE id_usuario = pIdUsuario ;
		END IF;



		RETURN cCod_ret;
	END;
END PROCEDURE;
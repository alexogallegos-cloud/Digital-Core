CREATE PROCEDURE "informix".sp_obtenerdatoscontacto_bei(pIdUser Integer)
RETURNING CHAR (5), CHAR(80), CHAR(15), INT;


	DEFINE sql_err int;
	DEFINE cCod_ret CHAR (5);
	DEFINE cEmail CHAR(80);
	DEFINE cCel CHAR(15);
	DEFINE iCiaCel INT;

	LET cCod_ret = '00000';
	LET cEmail = '';
	LET cCel = '';
	LET iCiaCel = 0;

	BEGIN
		ON EXCEPTION SET sql_err
		  IF sql_err <> 0 THEN
				LET cCod_ret = sql_err;
				RETURN cCod_ret, cEmail, cCel, iCiaCel;
		  END IF ;
		END EXCEPTION ;

		SET LOCK MODE TO WAIT ;
		SET ISOLATION DIRTY READ ;


		SELECT e_mail,tel_celular,cia_cel INTO cEmail, cCel, iCiaCel FROM "informix".bei_datos_usuario WHERE
		id_usuario = pIdUser;

		RETURN cCod_ret, NVL(cEmail, ''), NVL(cCel, ''), NVL(iCiaCel, 0);
	END;
END PROCEDURE;
CREATE PROCEDURE "informix".sp_buscar_token(pTokenIni char (9), pTokenFin char (9),pRegistros smallint,pUsuarioBusca char(9))
returning char(5) as cod_ret, char(9) as token,char(10) as fechaReg,char(9) as usuarioReg ,char(10) as fechaDisp ,char(9) as usuarioDisp ,char(10) as fechaAsig ,char(9) as usuarioAsig ,char(10) as fechaEntrega ,char(9) as usuarioEntrega ,char(10) as fechaGarantia ,char(9) as usuarioGarantia


--Elaboró: Javier A. Chávez Trujillo.
--Fecha: 07/12/09
--Solicitó: Mauricio León.
--Actividad: Busca Los token

--Define Variables
DEFINE sql_err integer;
DEFINE cod_ret char(5);
DEFINE vFecha_registro char(10);
DEFINE vUsuario_registro char(9);
DEFINE vFcha_disp char(10);
DEFINE vUsuario_disp char(9);
DEFINE vFecha_asig char(10);
DEFINE vUsuario_asigna char(9);
DEFINE vFcha_entreg char(10);
DEFINE vUsuario_entreg char(9);
DEFINE vFecha_garantia char(10);
DEFINE vUsuario_garantia char(9);
DEFINE vToken char(9);
--Inicializa variables
LET  cod_ret = '00000';
LET vToken = '';
LET vFecha_registro = '';
LET vUsuario_registro = '';
LET vFcha_disp = '';
LET vUsuario_disp = '';
LET vFecha_asig = '';
LET vUsuario_asigna = '';
LET vFcha_entreg = '';
LET vUsuario_entreg = '';
LET vFecha_garantia = '';
LET vUsuario_garantia = '';


BEGIN
	ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
            RETURN cod_ret,vToken,vFecha_registro, vUsuario_registro, vFcha_disp, vUsuario_disp ,vFecha_asig, vUsuario_asigna, vFcha_entreg, vUsuario_entreg,vFecha_garantia, vUsuario_garantia;
      END IF ;
   END EXCEPTION ;


  IF(pTokenFin IS NULL OR pTokenFin = '') THEN

		SELECT ns_token, fecha_registro, usuario_registro, fecha_disp, usuario_disp, fecha_asig, usuario_asig, fecha_entreg, usuario_entreg, fecha_garantia, usuario_garantia
		INTO vToken,vFecha_registro, vUsuario_registro, vFcha_disp, vUsuario_disp,vFecha_asig, vUsuario_asigna, vFcha_entreg, vUsuario_entreg,vFecha_garantia, vUsuario_garantia
		FROM tkn_busqueda
		WHERE ns_token = pTokenIni AND usuario_busca = pUsuarioBusca;

		IF(vUsuario_registro = '' OR vUsuario_registro IS NULL)THEN

			LET cod_ret = '00001';
		ELSE
			DELETE FROM tkn_busqueda WHERE usuario_busca = pUsuarioBusca;
		END IF;

		RETURN cod_ret,vToken,vFecha_registro, vUsuario_registro, vFcha_disp, vUsuario_disp,vFecha_asig, vUsuario_asigna, vFcha_entreg, vUsuario_entreg,vFecha_garantia, vUsuario_garantia;

	ELSE

		FOREACH

			SELECT SKIP pRegistros FIRST 10 ns_token, fecha_registro, usuario_registro, fecha_disp, usuario_disp, fecha_asig, usuario_asig, fecha_entreg, usuario_entreg, fecha_garantia, usuario_garantia
			INTO vToken,vFecha_registro, vUsuario_registro, vFcha_disp, vUsuario_disp,vFecha_asig, vUsuario_asigna, vFcha_entreg, vUsuario_entreg,vFecha_garantia, vUsuario_garantia
			FROM tkn_busqueda
			WHERE usuario_busca = pUsuarioBusca

			RETURN cod_ret,vToken,vFecha_registro, vUsuario_registro, vFcha_disp, vUsuario_disp,vFecha_asig, vUsuario_asigna, vFcha_entreg, vUsuario_entreg,vFecha_garantia, vUsuario_garantia WITH RESUME;

		END FOREACH;

	   IF(vUsuario_registro = '' OR vUsuario_registro IS NULL)THEN

			LET cod_ret = '00002';
				RETURN cod_ret,vToken,vFecha_registro, vUsuario_registro, vFcha_disp, vUsuario_disp,vFecha_asig, vUsuario_asigna, vFcha_entreg, vUsuario_entreg,vFecha_garantia, vUsuario_garantia;

	   END IF;

   END IF;

 END;
END PROCEDURE;
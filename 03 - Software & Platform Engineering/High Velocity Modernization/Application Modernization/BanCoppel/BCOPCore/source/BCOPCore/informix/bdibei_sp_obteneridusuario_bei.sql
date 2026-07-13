CREATE PROCEDURE "informix".sp_obteneridusuario_bei(pUsuario CHAR(50))
RETURNING CHAR (5) as vCod_ret, CHAR(11) as vIdUsuario;

--****************************************************************************************************
	-- DESCRIPCION:  CONSULTA EL ID_USUARIO APARTIR DEL USUARIO
	-- AUTOR : SOLSER
	-- FECHA : 05/06/2013
	-- BD: BDIBEI
	--***************************************************************************************************

        DEFINE sql_err int;
        DEFINE vCod_ret CHAR (5);
        DEFINE vIdUsuario VARCHAR(11);

        BEGIN
                ON EXCEPTION SET sql_err
                  IF sql_err <> 0 THEN
                                let vCod_ret = sql_err;
                                RETURN vCod_ret, vIdUsuario;
                  END IF ;
                END EXCEPTION ;

                LET vCod_ret = '00000';
                LET vIdUsuario = '';

				SET LOCK MODE TO WAIT ;
				SET ISOLATION DIRTY READ ;

                SELECT id_usuario INTO vIdUsuario FROM "informix".bei_usuario WHERE usuario_bei = pUsuario AND id_status = '30';
                RETURN vCod_ret, vIdUsuario;
        END;
END PROCEDURE;
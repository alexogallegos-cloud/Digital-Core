CREATE PROCEDURE "informix".sp_obteneridusuario_bei(pNumCliente VARCHAR(9))
RETURNING CHAR (5), CHAR(11);

--****************************************************************************************************
-- DESCRIPCION:  OBTIENE EL ID DEL USUARIO
-- AUTOR : Francisco Rodríguez Ibarra
-- FECHA : 26/08/2011
-- BD: bibpi
-- SOLICITO :Mauricio León
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
				
                SELECT id_usuario INTO vIdUsuario FROM bdibpi:"informix".bpi_usuariopm WHERE numcliente = pNumCliente AND st_portal = 'activo';
                RETURN vCod_ret, vIdUsuario;
        END;
END PROCEDURE;
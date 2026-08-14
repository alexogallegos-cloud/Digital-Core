CREATE PROCEDURE "informix".sp_asigna_token_bei(pNumCliente CHAR(9),pIdUsuario INTEGER,pNsToken VARCHAR(10))
 returning char(5) ;

    DEFINE cod_ret char(5);
    DEFINE sql_err INTEGER ;
    DEFINE vNsToken VARCHAR(10);
    DEFINE vfolio CHAR(12);
    LET cod_ret  = "00000";
    LET vfolio='';

--****************************************************************************************************
-- DESCRIPCION:  Asocia y Desasocia los Tokens de los Usuarios
-- AUTOR : Irving Guzman Salas
-- FECHA : 24/05/2013
-- BD: bdibei
-- SOLICITO :

-- MODIFICACION: se modifica para que al elegir un token (activacion o asignacion de token) se realice un
-- insert en la tabla bei_token
-- AUTOR : Berenice Noriega
-- FECHA : 04 de Septiembre 2013
-- BD: bdibei
-- SOLICITO : Ismael Hernandez

-- MODIFICACION: CorrecciÃ?Â³n de Flujo, se agrego validacion ya que tabla bei_token no permite valores nulos
--
-- AUTOR : IRVING GUZMAN SALAS
-- FECHA : 11 de Septiembre 2013
-- BD: bdibei
-- SOLICITO : RUBEN MOTA

-- MODIFICACION: Corregio  Flujo,ya que no se puede borrar bei_token con un id de usuario nulo
--Se borra por numero de cliente y ns de token , se actualiza bei_usuario de igual manera
-- AUTOR : IRVING GUZMAN SALAS
-- FECHA : 12 de Septiembre 2013
-- BD: bdibei
-- SOLICITO : RUBEN MOTA

--***************************************************************************************************

  BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
          RETURN cod_ret;
      END IF ;
   END EXCEPTION ;

     SET LOCK MODE TO WAIT 4;

	IF NVL(pNumCliente,0) == 0 THEN
	 	  LET cod_ret = '00001'; -- Codigo de Cliente Vacio
          RETURN cod_ret;
	END IF;
        --valida que exista el token en la tkn_nseries
		IF NOT EXISTS ( SELECT ns_token FROM bdibpi:"informix".tkn_nseries WHERE ns_token = pNsToken) THEN
			LET cod_ret = '00003'; -- No existe el Token
          	RETURN cod_ret;
		END IF;
        IF NVL(pIdUsuario,0) == 0 THEN --Desasocia el token

            /*UPDATE bdibei:"informix".bei_token SET id_usuario=null
			WHERE ns_token=pNsToken
            AND num_cliente=pNumCliente;*/
/*
            DELETE bdibei:"informix".bei_token WHERE ns_token=pNsToken
            AND num_cliente=pNumCliente AND id_usuario=pIdUsuario;

            UPDATE bdibei:"informix".bei_servicio SET ns_token=null
            WHERE id_usuario=pIdUsuario
            AND num_cliente=pNumCliente;

*/
            DELETE "informix".bei_token WHERE ns_token=pNsToken
            AND num_cliente=pNumCliente AND ns_token = pNsToken;

            UPDATE "informix".bei_servicio SET ns_token=null
            WHERE ns_token = pNsToken
            AND num_cliente=pNumCliente;


        ELSE
            --Si si trae usuario se procede a registrar el token seleccionado en la bei_token para el usuario.
              IF EXISTS ( SELECT num_cliente, * FROM "informix".bei_token WHERE id_usuario = pIdUsuario AND num_cliente=pNumCliente) THEN
                    LET cod_ret = '00002'; -- ya esta registrado en la bei_token
                    RETURN cod_ret;
              END IF;

            --Se saca el folio del token que tiene el usuario encaso de ser administrador
                select folio_activa
                into vfolio
                from "informix".bei_servicio
                where num_cliente=pNumCliente and id_usuario=pIdUsuario;

                IF NVL(vfolio,'')=='' THEN
                 	LET vfolio='';
                END IF;

            --Se consulta el estatus del token en la tkn_nseries.
                select id_status
                into vNsToken
                from bdibpi:"informix".tkn_nseries
                where ns_token=pNsToken;

             --Se inserta la relacion de usuario-token-cliente
                INSERT INTO "informix".bei_token(id_usuario, num_cliente, ns_token, suc_registro, folio_token, id_status_token, f_status, f_registro)
                VALUES(pIdUsuario, pNumCliente, pNsToken, '5008', vfolio, vNsToken, CURRENT, CURRENT);

             --Si es administrador se le pone el token que eligio en la tabla de servicio.
                UPDATE "informix".bei_servicio SET ns_token=pNsToken
                WHERE id_usuario=pIdUsuario
                AND num_cliente=pNumCliente;


                /*	IF NOT EXISTS ( SELECT num_cliente FROM bdibei:"informix".bei_usuario WHERE id_usuario = pIdUsuario AND num_cliente=pNumCliente) THEN
                        LET cod_ret = '00002'; -- No existe el Usuario
                        RETURN cod_ret;
                    END IF;*/

                /*UPDATE bdibei:"informix".bei_token SET id_usuario=pIdUsuario
                WHERE ns_token=pNsToken
                AND num_cliente=pNumCliente;

                UPDATE bdibei:"informix".bei_servicio SET ns_token=pNsToken
                WHERE id_usuario=pIdUsuario
                AND num_cliente=pNumCliente;*/

        END IF;
             RETURN cod_ret;
END
END PROCEDURE;
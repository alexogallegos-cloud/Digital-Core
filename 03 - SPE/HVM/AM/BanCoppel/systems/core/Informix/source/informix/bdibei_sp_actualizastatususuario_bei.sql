CREATE PROCEDURE "informix".sp_actualizastatususuario_bei(
				pEmpresa char(3),
				pNumCliente char(20),
				pIdUsuario INTEGER,
				pStatus integer,
				pIp char (15),
				pSuc char (4),
				pUsuCambio char (8),
				pIdentAdmin CHAR(30))
   returning char(5);


--****************************************************************************************************
-- DESCRIPCION:  Actualiza Status de usuario Admin y Operador
-- AUTOR : Irving Guzman Salas
-- FECHA : 24/05/2013
-- BD: bdibei
-- SOLICITO :
-- MODIFICACION: Para en caso de ser administrador y no tener id de usuario, ya no sea necesario 
--				 actualizar la tabla de usuarios.
-- MOD. POR: Berenice Noriega - BanCoppel.
-- FECHA MOD: 21 Agosto 2014
-- Liberado a produccion: 23 Octubre 2014
--***************************************************************************************************

    DEFINE cCod_ret char(5);
    DEFINE sql_err integer;
    DEFINE iStatus integer;

   LET cCod_ret       = "00000";
   LET iStatus = "0";


BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            LET cCod_ret = sql_err;
            RETURN cCod_ret;
      END IF ;
   END EXCEPTION ;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

		IF NVL(pNumCliente, '') == '' THEN
			LET cCod_ret = '00001'; -- No Envio Numero de Cliente
			RETURN cCod_ret;
		END IF;




	IF NVL(pIdUsuario, -1) == -1 THEN --no se recibe el id de usuario

		IF NVL(pIdentAdmin, '') == '' THEN --Se revisa que recibe la identificación para admistradores nuevos
			LET cCod_ret = '00003'; -- No Envio la Identificacion Admin
			RETURN cCod_ret;
		END IF;


	   IF EXISTS ( 	SELECT num_cliente
	   				FROM bdibei:"informix".bei_servicio
	   				WHERE num_cliente = pNumCliente
	   				AND identificacion_admin=pIdentAdmin) THEN

					SELECT id_status,id_usuario
					INTO iStatus,pIdUsuario
					FROM bdibei:"informix".bei_servicio
					WHERE num_cliente = pNumCliente
					AND identificacion_admin=pIdentAdmin;

					IF ((NVL(pIdUsuario,'')='') OR pIdUsuario is null) THEN --si esta vacio o es null
			 
						INSERT INTO bdibei:"informix".bei_cambiostusuario
						(numcliente, id_statusanterior, id_statusactual, ipusuario, fecha_cambio, suc_cambio, usuario_cambio,pIdentAdmin)
						VALUES (pNumCliente, iStatus, pStatus, pIp, current, pSuc, pUsuCambio,pIdentAdmin);
						
					ELSE --si pIdUsuario NO es vacio o null
						INSERT INTO bdibei:"informix".bei_cambiostusuario
						(numcliente, id_statusanterior, id_statusactual, ipusuario, fecha_cambio, suc_cambio, usuario_cambio,pIdentAdmin,id_usuario)
						VALUES (pNumCliente, iStatus, pStatus, pIp, current, pSuc, pUsuCambio,pIdentAdmin,pIdUsuario);

						--Se cambia esta parte de codigo aqui, para que lo haga si tiene idusuario. (estaba un poco mas abajo fuera del if.
						IF EXISTS (SELECT num_cliente
								FROM bdibei:"informix".bei_usuario
								WHERE id_usuario=pIdUsuario) THEN
								UPDATE bdibei:"informix".bei_usuario
								SET id_status = pStatus, f_status = current
								WHERE id_usuario=pIdUsuario;
						ELSE
								LET cCod_ret = '00004';  -- No existe el Usuario del administrador
						END IF ;

					END IF;

					--si tiene o no usuario de todos modos cambia el estatus en bei_servicio
					UPDATE bdibei:"informix".bei_servicio
					SET id_status = pStatus, f_status = current
					WHERE num_cliente = pNumCliente
					AND identificacion_admin=pIdentAdmin;
					
					--Aqui estaba el codigo que se paso arriba. y se elimina un select que estaba de mas.

	   	ELSE
            LET cCod_ret = '00002';  -- No existe el Usuario Administrador
        END IF ;


	ELSE --El id de usuario no esta vacio
	
	   	IF EXISTS ( SELECT num_cliente
	   				FROM bdibei:"informix".bei_servicio
	   				WHERE num_cliente = pNumCliente
	   				AND id_usuario=pIdUsuario) THEN --si es administrador


	   			   	SELECT id_status
	   				INTO iStatus
	   				FROM bdibei:"informix".bei_servicio
	   				WHERE num_cliente = pNumCliente
	   				AND id_usuario=pIdUsuario;


					UPDATE bdibei:"informix".bei_servicio
					SET id_status = pStatus, f_status = current
					WHERE num_cliente = pNumCliente
					AND id_usuario=pIdUsuario;

				   IF EXISTS ( 	SELECT num_cliente
						FROM bdibei:"informix".bei_usuario
						WHERE id_usuario=pIdUsuario) THEN

						IF iStatus <> pStatus THEN
						INSERT INTO bdibei:"informix".bei_cambiostusuario
						(id_usuario,numcliente, id_statusanterior, id_statusactual, ipusuario, fecha_cambio, suc_cambio, usuario_cambio)
						VALUES (pIdUsuario,pNumCliente, iStatus, pStatus, pIp, current, pSuc, pUsuCambio);
						END IF;

						UPDATE bdibei:"informix".bei_usuario
						SET id_status = pStatus, f_status = current
						WHERE id_usuario=pIdUsuario;
					ELSE
						LET cCod_ret = '00004';  -- No existe el Usuario en bei_usuario
					END IF ;

		ELSE --no existe el usuario en la bei_servicio por pIdUsuario, es operador y no administrador
		
			   IF EXISTS ( 	SELECT num_cliente
	   				FROM bdibei:"informix".bei_usuario
	   				WHERE id_usuario=pIdUsuario) THEN

 					SELECT id_status
	   				INTO iStatus
	   				FROM bdibei:"informix".bei_usuario
	   				WHERE num_cliente = pNumCliente
	   				AND id_usuario=pIdUsuario;
					IF iStatus <> pStatus THEN
	   				INSERT INTO bdibei:"informix".bei_cambiostusuario
	   				(id_usuario,numcliente, id_statusanterior, id_statusactual, ipusuario, fecha_cambio, suc_cambio, usuario_cambio)
					VALUES (pIdUsuario,pNumCliente, iStatus, pStatus, pIp, current, pSuc, pUsuCambio);
					END IF;
	   				UPDATE bdibei:"informix".bei_usuario
					SET id_status = pStatus, f_status = current
					WHERE id_usuario=pIdUsuario;
	   			ELSE
            		LET cCod_ret = '00004';  -- No existe el Usuario operador
       			END IF ;

        END IF ;

	END IF ;


    RETURN cCod_ret;

END

END PROCEDURE ;
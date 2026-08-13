CREATE PROCEDURE "informix".sp_act_statususuario_bei(
				pUsuario char(50),
				pStatus integer,
				pIp char (15),
				pSuc char (4),
				pUsuCambio char (8)
			)
   returning char(5);

--****************************************************************************************************
-- DESCRIPCION:  Actualiza Status de usuario por Nombre de Usuario
-- AUTOR : Irving Guzman Salas
-- FECHA : 24/05/2013
-- BD: bdibei
-- SOLICITO :
--***************************************************************************************************

    DEFINE cCod_ret char(5);
    DEFINE sql_err integer;
    DEFINE iIdUsuario integer;
    DEFINE iStatus integer;
	DEFINE iEmpresa char(3);
	DEFINE iNumCliente char(20);
	DEFINE iIdentAdmin char(30);

   LET cCod_ret       = "00000";
   LET iIdUsuario = 0;
   LET iStatus = 0;
   LET iEmpresa = "000";
   LET iNumCliente = "";
   LET iIdentAdmin = "";




BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            LET cCod_ret = sql_err;
            RETURN cCod_ret;
      END IF ;
   END EXCEPTION ;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

		IF NVL(pUsuario, '') == '' THEN
			LET cCod_ret = '00001'; -- No Envio Nombre de Usuario
			RETURN cCod_ret;
		END IF;

	SELECT id_usuario ,num_cliente,id_status
	INTO iIdUsuario,iNumCliente,iStatus
	FROM bdibei:"informix".bei_usuario
	WHERE usuario_bei=pUsuario;

	IF EXISTS ( 	SELECT id_usuario
	   				FROM bdibei:"informix".bei_usuario
					WHERE usuario_bei=pUsuario) THEN

	   	 			INSERT INTO bdibei:"informix".bei_cambiostusuario
	   				(id_usuario,numcliente, id_statusanterior, id_statusactual, ipusuario, fecha_cambio, suc_cambio, usuario_cambio)
					VALUES (iIdUsuario,iNumCliente, iStatus, pStatus, pIp, current, pSuc, pUsuCambio);

	   				UPDATE bdibei:"informix".bei_usuario
					SET id_status = pStatus, f_status = current
					WHERE id_usuario=iIdUsuario;

			IF EXISTS ( 	SELECT num_cliente
	   						FROM bdibei:"informix".bei_servicio
	   						WHERE num_cliente = iNumCliente
	   						AND id_usuario=iIdUsuario) THEN

	   					SELECT num_cliente
	   					INTO iIdentAdmin
	   						FROM bdibei:"informix".bei_servicio
	   						WHERE num_cliente = iNumCliente
	   						AND id_usuario=iIdUsuario	;

	   				   	INSERT INTO bdibei:"informix".bei_cambiostusuario
	   					(numcliente, id_statusanterior, id_statusactual, ipusuario, fecha_cambio, suc_cambio, usuario_cambio,pIdentAdmin)
						VALUES (iNumCliente, iStatus, pStatus, pIp, current, pSuc, pUsuCambio,iIdentAdmin);

						UPDATE bdibei:"informix".bei_servicio
						SET id_status = pStatus, f_status = current
						WHERE num_cliente = iNumCliente
						AND id_usuario=iIdUsuario;

	   		END IF;

	ELSE
	   		  LET cCod_ret = '00002';  -- No existe el Usuario
	END IF;


    RETURN cCod_ret;

END

END PROCEDURE ;
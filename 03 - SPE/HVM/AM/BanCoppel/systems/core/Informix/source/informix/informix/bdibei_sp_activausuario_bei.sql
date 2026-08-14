CREATE PROCEDURE "informix".sp_activausuario_bei(
												pNumCte char(20),
												pPass char(50),
												pStatus integer,
												pIp char (15),
												pSuc char (4),
												pUsuCambio char (8),
												pIdentAdmin char(30),
												pIdUsuario INTEGER)
   returning char(5);

--****************************************************************************************************
-- DESCRIPCION:  Activa y Registra el usuario y registra el cambio de status
-- AUTOR : Irving Guzman Salas
-- FECHA : 24/05/2013
-- BD: bdibei
-- SOLICITO :
--***************************************************************************************************

	DEFINE sql_err integer ;
	DEFINE cCod_ret char(5);
	DEFINE iCont smallint ;
	DEFINE iStatus INTEGER;
	DEFINE sIdUsuario INTEGER;
	DEFINE sIdentAdmin char(30);

	LET cCod_ret  = '00000';
	LET iCont = 0;
	LET iStatus = 0;
	LET sIdentAdmin='';

BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            LET cCod_ret = sql_err;
            RETURN cCod_ret;
      END IF ;
   END EXCEPTION ;

    SET LOCK MODE TO WAIT ;
	SET ISOLATION DIRTY READ ;



	IF NVL(pIdentAdmin,'') == '' THEN

		SELECT id_status,id_usuario ,identificacion_admin
		INTO iStatus,sIdUsuario ,sIdentAdmin
		FROM bdibei:"informix".bei_servicio
		WHERE num_cliente = pNumCte
		AND id_usuario = pIdUsuario;
    ELSE
		SELECT id_status,id_usuario ,identificacion_admin
		INTO iStatus,sIdUsuario ,sIdentAdmin
		FROM bdibei:"informix".bei_servicio
		WHERE num_cliente = pNumCte
		AND identificacion_admin = pIdentAdmin;

    END IF;



	IF NVL(sIdUsuario,-1) == -1 THEN
		LET cCod_Ret = '001';   ---Usuario no esta registrado en el servicio
	    RETURN cCod_ret;
	END IF;

	IF NVL(iStatus,-1) == -1 THEN
		LET cCod_Ret = '002';   ---No contiene un Status Valido
	    RETURN cCod_ret;
	 END IF;

   IF EXISTS (  SELECT id_usuario
   					FROM bdibei:"informix".bei_usuario
   					WHERE num_cliente = pNumCte
   					AND id_usuario = sIdUsuario) THEN

		 		INSERT INTO bdibei:"informix".bei_cambiostusuario
	   			(id_usuario,numcliente, id_statusanterior, id_statusactual, ipusuario, fecha_cambio, suc_cambio, usuario_cambio)
				VALUES (sIdUsuario,pNumCte, iStatus, pStatus, pIp, current, pSuc, pUsuCambio);


      	UPDATE bdibei:"informix".bei_usuario
        SET  pass = TRIM(pPass), f_pass = CURRENT, id_status = pStatus
        WHERE num_cliente = pNumCte
        AND id_usuario = sIdUsuario;

        UPDATE bdibei:"informix".bei_servicio
        SET  id_status = pStatus
        WHERE num_cliente = pNumCte
        AND identificacion_admin = sIdentAdmin;

        LET cCod_ret = '000';  -- Usuario activado
   ELSE
        LET cCod_ret = '003';  -- No existe el usuario
   END IF ;


   RETURN cCod_ret;
END
END PROCEDURE;
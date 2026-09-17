CREATE PROCEDURE "informix".sp_actualiza_status_token_bpi(pEmpresa char (3), pNumCte char(9), pStatus integer, pNSToken char(10))
	RETURNING char (5), integer;

--Realizó: Javier Calderon
--Fecha: 02/01/09
--Solicitó: Mauricio León
--Actividad: Actualiza el status y fecha de status del token asignado al cliente

--Define variables
define sql_err integer;
define cod_ret char (5);


--Inicializa variables
LET sql_err = '';
LET cod_ret = '000';


BEGIN

 ON EXCEPTION SET sql_err
          LET cod_ret = sql_err;
      RETURN  cod_ret, 0;
   END EXCEPTION;

   IF EXISTS(SELECT numcte FROM bdinteg:si_bpiusuarios WHERE numcte = pNumcte AND empresa = pEmpresa) THEN
	IF pStatus = '160' THEN --Valida si el estatus es de Desbloqueo, lo cambia a activo 140 para poder ingresar al portal
            UPDATE bdinteg:si_bpitoken set id_status_token = '140', f_status = CURRENT
			WHERE empresa = pEmpresa AND num_cliente = pNumCte AND ns_token = pNSToken;

        ELSE
            UPDATE bdinteg:si_bpitoken SET id_status_token = pStatus, f_status = CURRENT
			WHERE empresa = pEmpresa AND num_cliente = pNumCte AND ns_token = pNSToken;
	END IF
	ELSE
		LET cod_ret = '001'; -- El cliente No existe
	END IF;

	RETURN cod_ret, pStatus;

END;
END PROCEDURE;
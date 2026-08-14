CREATE PROCEDURE "informix".sp_actualiza_aut_manc_bei(pIdUser INTEGER,pNumCte CHAR(9),pNumCta CHAR(16),pAutoriza CHAR(1))
   returning char(5);


    DEFINE cCod_ret char(5);
    DEFINE sql_err integer ;

    LET cCod_ret  = "00000";


--****************************************************************************************************
-- DESCRIPCION:  Actualiza Autorizacion de Mancomunidad por Cuenta
-- AUTOR : Irving Guzman Salas
-- FECHA : 24/05/2013
-- BD: bdibei
-- SOLICITO :
--***************************************************************************************************

  BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cCod_ret = sql_err;
            RETURN cCod_ret;
      END IF ;
   END EXCEPTION ;


SET LOCK MODE TO WAIT 4;

	 IF NVL(pIdUser,-1) == -1 THEN
		LET cCod_Ret = '00002';   ---No se Recibio ID de Usuario
	    RETURN cCod_ret;
	 END IF;

	 IF NVL(pNumCte,'') == '' THEN
		LET cCod_Ret = '00003';   ---No se Recibio Numero de Cliente
	    RETURN cCod_ret;
	 END IF;

	 IF NVL(pNumCta,'') == '' THEN
		LET cCod_Ret = '00004';   ---No se Recibio Numero de Cuenta
	    RETURN cCod_ret;
	 END IF;

	 IF NVL(pAutoriza,'') == '' THEN
		LET cCod_Ret = '00005';   ---No se Recibio valor de Autorizacion
	    RETURN cCod_ret;
	 END IF;


 	IF EXISTS ( 	SELECT id_usuario
	   				FROM bdibei:"informix".bei_mancomunidad
	   				WHERE id_usuario =pIdUser
					AND num_cte = pNumCte
					AND num_cta = pNumCta) THEN


		UPDATE  bdibei:"informix".bei_mancomunidad
		SET autoriza = pAutoriza
		WHERE id_usuario = pIdUser
		AND num_cte =pNumCte
		AND num_cta =pNumCta;

	ELSE
	    INSERT INTO bdibei:"informix".bei_mancomunidad
		(id_usuario,num_cte,num_cta,autoriza) VALUES
		(pIdUser, pNumCte,pNumCta, pAutoriza );
	END IF;


  RETURN cCod_ret;


END
END PROCEDURE;
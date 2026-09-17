CREATE PROCEDURE "informix".sp_inserta_aut_manco_temp_bei(pIdUser INTEGER,
pNumCte CHAR(9),pNumCta CHAR(20),pAutoriza CHAR(1), id_admin_manco INTEGER)
   returning char(5);

    DEFINE cCod_Ret char(5);
    DEFINE sql_err integer ;

    LET cCod_Ret  = "00000";
--****************************************************************************************************
-- DESCRIPCION:  Guarda Autorizacion de Mancomunidad por Cuenta
-- AUTOR : Irving Guzman Salas
-- FECHA : 24/05/2013
-- BD: bdibei
-- SOLICITO :
--***************************************************************************************************
  BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cCod_Ret = sql_err;
            RETURN cCod_Ret;
      END IF ;
   END EXCEPTION ;




	 IF LENGTH(TRIM(NVL(pNumCte,''))) = 0 THEN
		LET cCod_Ret = '00003';   ---No se Recibio Numero de Cliente
	    RETURN cCod_ret;
	 END IF;

	 IF LENGTH(TRIM(NVL(pNumCta,''))) = 0 THEN
		LET cCod_Ret = '00004';   ---No se Recibio Numero de Cuenta
	    RETURN cCod_ret;
	 END IF;

	 IF LENGTH(TRIM(NVL(pAutoriza,''))) = 0 THEN
		LET cCod_Ret = '00005';   ---No se Recibio valor de Autorizacion
	    RETURN cCod_ret;
	 END IF;

     IF NVL(id_admin_manco,-1) = -1 THEN
		LET cCod_Ret = '00006';   ---No se Recibio FOREIGN KEY DE LA TABLA bei_admin_manco_temp
	    RETURN cCod_ret;
	 END IF;

    SET LOCK MODE TO WAIT 4;

	INSERT INTO "informix".bei_admin_manco_det_temp(
        id_admin_manco, tipo_oper,
        id_usuario, num_cte,
        autoriza, id_oper,
        id_menu_oper, id_perfil,
        num_cta, monto_min,
        monto_max, mancomunado)
	VALUES(
        id_admin_manco, 1,
        pIdUser, pNumCte,
        pAutoriza,NULL,
        NULL, NULL,
        pNumCta, NULL,
        NULL,NULL);

  RETURN cCod_Ret;


END
END PROCEDURE;
CREATE PROCEDURE "informix".sp_adm_perfil_borra(eId INTEGER)  
returning CHAR(5);

    DEFINE cod_ret char(5);
    DEFINE sql_err integer ;

    LET cod_ret  = "00000";

BEGIN
ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
           RETURN  cod_ret;
      END IF ;
   END EXCEPTION ;

SET LOCK MODE TO WAIT 4;

	IF  NVL(eId,0) == 0  THEN 
	 	  LET cod_ret = '00001'; -- No contiene Dato 
           RETURN  cod_ret;
	END IF;

	-- Borra Datos de Perfil de ADM_MENU_PERFIL
	DELETE FROM bdinteg:"informix".adm_menu_perfil 
	WHERE id_perfil = eId;
	
	-- Borra Perfil de ADM_PERFIL
	DELETE FROM  bdinteg:"informix".adm_perfil
	WHERE id = eId;

      RETURN  cod_ret;
END
END PROCEDURE;
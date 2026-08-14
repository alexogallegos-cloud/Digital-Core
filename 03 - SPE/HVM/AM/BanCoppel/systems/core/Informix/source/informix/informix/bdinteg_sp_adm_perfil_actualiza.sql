CREATE PROCEDURE "informix".sp_adm_perfil_actualiza(eid INTEGER, enombre CHAR(200), esitio CHAR(200))  
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
	
	IF  NVL(eid,0) == 0  THEN 
	 	  LET cod_ret = '00001'; -- No contiene Dato 
           RETURN  cod_ret;
	END IF;

	IF  NVL(enombre,'') == ''  THEN 
	 	  LET cod_ret = '00002'; -- No contiene Dato 
           RETURN  cod_ret;
	END IF;

	IF  NVL(esitio,'') == ''  THEN 
	 	  LET cod_ret = '00003'; -- No contiene Dato 
           RETURN  cod_ret;
	END IF;

		UPDATE bdinteg:"informix".adm_perfil 
		SET nombre = enombre , sitio = esitio 
		WHERE id = eid;
		
		-- Borra Datos de Perfil de ADM_MENU_PERFIL
	DELETE FROM bdinteg:"informix".adm_menu_perfil 
	WHERE id_perfil = eId;

      RETURN  cod_ret;
END
END PROCEDURE;
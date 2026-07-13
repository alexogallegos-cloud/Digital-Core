CREATE PROCEDURE "informix".sp_adm_menu_perfil_guarda(eIdPerfil INTEGER,eIdMenu INTEGER)  
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

	IF  NVL(eIdPerfil,-1) == -1  THEN 
	 	  LET cod_ret = '00001'; -- No contiene Dato 
           RETURN  cod_ret;
	END IF;

	IF  NVL(eIdMenu,-1) == -1  THEN 
	 	  LET cod_ret = '00002'; -- No contiene Dato 
           RETURN  cod_ret;
	END IF;

		INSERT INTO bdinteg:"informix".adm_menu_perfil
		(id_perfil, id_menu) 	
		VALUES(eIdPerfil, eIdMenu);
 
      RETURN  cod_ret;
END
END PROCEDURE;
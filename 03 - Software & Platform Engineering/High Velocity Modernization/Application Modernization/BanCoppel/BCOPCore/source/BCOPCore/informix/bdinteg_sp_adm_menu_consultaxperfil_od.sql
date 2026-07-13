CREATE PROCEDURE "informix".sp_adm_menu_consultaxperfil_od(e_idperfil INTEGER, pRegInicial INTEGER)  
returning CHAR(5),INTEGER, CHAR(200),INTEGER, CHAR(200), CHAR(200), INTEGER;

    DEFINE cod_ret char(5);
    DEFINE sql_err integer ;

 
    DEFINE sid INTEGER ; 
    DEFINE snombre CHAR(200); 
    DEFINE sidpadre INTEGER;
    DEFINE sfactory CHAR(200); 
    DEFINE siconpath CHAR(200);
    DEFINE stipo INTEGER;

    
    LET cod_ret  = "00000";
    LET sid   = 0;
    LET snombre  = "";
    LET sidpadre  = 0;
    LET sfactory  = "";
    LET siconpath  = "";
    LET stipo = 0;
BEGIN
ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
           RETURN  cod_ret,sid,snombre,sidpadre,sfactory,siconpath, stipo;
      END IF ;
   END EXCEPTION ;

SET LOCK MODE TO WAIT 4;
	

	IF  NVL(e_idperfil,0) == 0  THEN 
	 	  LET cod_ret = '00001'; -- No contiene Dato de MAC
           RETURN  cod_ret,sid,snombre,sidpadre,sfactory,siconpath, stipo;
	END IF;
	
   FOREACH
 	  	SELECT SKIP pRegInicial FIRST 10 menu.id,menu.NOMBRE,menu.idpadre,menu.factory,menu.iconpath, menu.tipo
  	 	INTO 	sid, snombre, sidpadre, sfactory, siconpath, stipo
		FROM  bdinteg:"informix".adm_menu menu
		JOIN  bdinteg:"informix".adm_menu_perfil mp ON mp.id_menu=menu.ID 
		WHERE mp.id_perfil = e_idperfil  
            
               RETURN  cod_ret,sid,snombre,NVL(sidpadre,-1),NVL(sfactory,""),NVL(siconpath,""), stipo WITH RESUME;
    END FOREACH;
   
END
END PROCEDURE;
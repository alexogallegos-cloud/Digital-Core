CREATE PROCEDURE "informix".sp_adm_menu_consultaxsitio(esitio CHAR(200), pRegInicial INTEGER)  
returning CHAR(5),INTEGER, CHAR(200),INTEGER, CHAR(200);

    DEFINE cod_ret char(5);
    DEFINE sql_err integer ;

 
    DEFINE sid INTEGER ; 
    DEFINE snombre CHAR(200); 
    DEFINE sidpadre INTEGER;
    DEFINE sfactory CHAR(200); 

    LET cod_ret  = "00000";
    LET sid   = 0;
    LET snombre  = "";
    LET sidpadre  = 0;
    LET sfactory  = "";
 
    
BEGIN
ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
           RETURN  cod_ret,sid,snombre,sidpadre,sfactory;
      END IF ;
   END EXCEPTION ;

SET LOCK MODE TO WAIT 4;
	

	IF  NVL(esitio,'') == ''  THEN 
	 	  LET cod_ret = '00001'; -- No contiene Dato de MAC
           RETURN  cod_ret,sid,snombre,sidpadre,sfactory;
	END IF;
	
   FOREACH
 	  	SELECT SKIP pRegInicial FIRST 10 menu.id,menu.NOMBRE,menu.idpadre,menu.factory
  	 	INTO 	sid, snombre, sidpadre, sfactory
		FROM  bdinteg:"informix".adm_menu menu
		WHERE menu.sitio = esitio  
            
               RETURN  cod_ret,sid,snombre,NVL(sidpadre,-1),NVL(sfactory,"") WITH RESUME;
    END FOREACH;
   
END
END PROCEDURE;
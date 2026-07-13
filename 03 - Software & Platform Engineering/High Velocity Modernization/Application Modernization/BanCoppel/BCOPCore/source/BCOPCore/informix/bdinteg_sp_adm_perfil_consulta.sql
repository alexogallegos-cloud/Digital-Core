CREATE PROCEDURE "informix".sp_adm_perfil_consulta(ePerfil CHAR(200),eSitio CHAR(200), eRegInicial INTEGER)  
returning char(5), INTEGER,  CHAR(200);

    DEFINE cod_ret char(5);
    DEFINE sql_err integer ;

    DEFINE sid INTEGER;
    DEFINE snombre  CHAR(200);

    
    LET cod_ret  = "00000";
    LET sid   = 0;
    LET snombre  = "";

BEGIN
ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
           RETURN  cod_ret,sid,snombre;
      END IF ;
   END EXCEPTION ;

SET LOCK MODE TO WAIT 4;
	


  FOREACH
 	  	SELECT SKIP eRegInicial FIRST 10 perfil.id, perfil.nombre
  	 	INTO sid, snombre
		FROM  bdinteg:"informix".adm_perfil perfil
		WHERE perfil.nombre LIKE NVL(ePerfil,'%%')
		AND   perfil.sitio = eSitio
  
    	RETURN  cod_ret,sid,snombre WITH RESUME;
  END FOREACH;
 

END
END PROCEDURE;
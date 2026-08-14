CREATE PROCEDURE "informix".sp_adm_encript_consulta(e_mac CHAR(20))  
returning char(5), CHAR(1500),  CHAR(1500);

    DEFINE cod_ret char(5);
    DEFINE sql_err integer ;

    DEFINE scert CHAR(1500);
    DEFINE skey  CHAR(1500);
    
    LET cod_ret  = "00000";
    LET skey   = "";
    LET scert  = "";
BEGIN
ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
           RETURN  cod_ret,scert,skey;
      END IF ;
   END EXCEPTION ;

SET LOCK MODE TO WAIT 4;
	

	IF NVL(e_mac,'') =='' THEN 
	 	  LET cod_ret = '00001'; -- No contiene Dato de MAC
          RETURN  cod_ret,scert,skey;
	END IF;
	
	SELECT cert_file,key_file INTO scert,skey
	FROM 	bdinteg:"informix".adm_encryption
	WHERE mac_address = e_mac;


	RETURN cod_ret,scert,skey;
END
END PROCEDURE;
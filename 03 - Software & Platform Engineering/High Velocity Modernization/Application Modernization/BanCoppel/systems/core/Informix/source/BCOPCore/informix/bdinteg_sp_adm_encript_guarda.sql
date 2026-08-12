CREATE PROCEDURE "informix".sp_adm_encript_guarda(e_ip CHAR(200),e_mac CHAR(20),e_so CHAR(100),e_cert CHAR(1500), e_key CHAR(1500))  
returning char(5);

    DEFINE cod_ret char(5);
    DEFINE sql_err integer ;

    LET cod_ret  = "00000";
BEGIN
ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
           RETURN cod_ret ;
      END IF ;
   END EXCEPTION ;

SET LOCK MODE TO WAIT 4;
	
	IF NVL(e_ip,'') =='' THEN 
	 	  LET cod_ret = '00001'; -- No contiene Dato de Ip
          RETURN cod_ret;
	END IF;
	IF NVL(e_mac,'') =='' THEN 
	 	  LET cod_ret = '00002'; -- No contiene Dato de MAC
          RETURN cod_ret;
	END IF;
	IF NVL(e_so,'') =='' THEN 
	 	  LET cod_ret = '00003'; -- No contiene Dato de Sistema Operativo
          RETURN cod_ret;
	END IF;
	IF NVL(e_cert,'') =='' THEN 
	 	  LET cod_ret = '00004'; -- No contiene Dato de Certificado
          RETURN cod_ret;
	END IF;
	IF NVL(e_key,'') =='' THEN 
	 	  LET cod_ret = '00005'; -- No contiene Dato de Llave
          RETURN cod_ret;
	END IF;
	INSERT INTO bdinteg:"informix".adm_encryption
				(id,ip_address,mac_address,SO,cert_file,key_file,fec_creacion) VALUES
				(0, e_ip,e_mac,e_so,e_cert,e_key,CURRENT);

	RETURN cod_ret;
END
END PROCEDURE;
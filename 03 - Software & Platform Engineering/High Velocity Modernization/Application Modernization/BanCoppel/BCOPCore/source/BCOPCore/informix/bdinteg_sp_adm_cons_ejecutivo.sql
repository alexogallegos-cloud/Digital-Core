CREATE PROCEDURE "informix".sp_adm_cons_ejecutivo(e_ejecut CHAR(8),e_mac CHAR(12),e_suc CHAR(4))  
returning char(5);

    DEFINE cod_ret char(5);
    DEFINE sql_err integer ;

    DEFINE s_status 		CHAR(1);

	DEFINE s_ejecutivo 		CHAR(8);
	
	DEFINE s_esZona 		INTEGER;
	

    LET cod_ret  = "00000";

    LET s_ejecutivo= "";
	
	LET s_esZona = 0;
  

BEGIN
ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;

         	RETURN  cod_ret;
      END IF ;
   END EXCEPTION ;

SET LOCK MODE TO WAIT 4;
	

	IF NVL(e_mac,'') =='' THEN 
	 	  LET cod_ret = '02000'; -- No contiene Dato de MAC
     	RETURN  cod_ret;
    END IF;

	IF NVL(e_ejecut,'') =='' THEN 
	 	  LET cod_ret = '02002'; -- No contiene Dato de Ejecutivo
    	RETURN  cod_ret;
    END IF;

	IF NVL(e_suc,'') =='' THEN 
	 	  LET cod_ret = '02003'; -- No contiene Dato de Sucursal
     	RETURN  cod_ret;
    END IF;
	
	
	SELECT COUNT(ejecutivo)
		    INTO  s_esZona
    FROM si_ejecut   
	WHERE ejecutivo = e_ejecut
	AND puesto = '005' 
	AND password <> 'BAJA';

	IF s_esZona = 1 THEN
       LET s_status = 'A';
	ELSE
		SELECT status INTO s_status
        FROM si_macejecutivo        
        WHERE ejecutivo = e_ejecut AND MAC = e_suc;
	END IF;
	
	IF NVL(s_status,'') =='' THEN 
	 	  LET cod_ret = '02004'; -- Usuario no Autorizado en esta Sucursal
       	RETURN  cod_ret;
    END IF;
    
    IF NVL(s_status,'') <>'A' THEN 
	 	  LET cod_ret = '02005'; -- Usuario no Activo
     	RETURN  cod_ret;
    END IF;

	IF s_esZona = 1 THEN
      SELECT ejecutivo   
			INTO  s_ejecutivo
		FROM si_ejecut   
		WHERE ejecutivo = e_ejecut;
	ELSE
		SELECT ejecutivo   
		INTO  s_ejecutivo
		FROM si_ejecut   
		WHERE ejecutivo = e_ejecut AND sucursal = e_suc;
	END IF;
    

    IF NVL(s_ejecutivo,'') =='' THEN 
	 	  LET cod_ret = '02006'; -- No se encontro registro de el Ejecutivo
       	RETURN  cod_ret;
    ELSE

    END IF;

     	RETURN  cod_ret;
END
END PROCEDURE

;
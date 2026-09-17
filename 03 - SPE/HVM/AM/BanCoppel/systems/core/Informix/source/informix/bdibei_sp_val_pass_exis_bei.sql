CREATE PROCEDURE "informix".sp_val_pass_exis_bei(pIdUsuario INTEGER,
pPass CHAR(50))
 returning char(5);

    DEFINE cod_ret char(5);
    DEFINE sql_err INTEGER ;

	DEFINE sPass                   	CHAR(50);
   	DEFINE sFpass                   	DATE;
   	DEFINE sPass1                    CHAR(50);
   	DEFINE sFpass1                  	DATE;
   	DEFINE sPass2                    CHAR(50);
   	DEFINE sFpass2                  	DATE;
   	DEFINE sPass3                    CHAR(50);
   	DEFINE sFpass3                  	DATE;

    LET cod_ret  = "00000";

--****************************************************************************************************
-- DESCRIPCION:  Actualiza usuario Bei
-- AUTOR : Irving Guzman Salas /SOLSER
-- FECHA : 24/05/2013
-- BD: bdibei
-- SOLICITO :BanCoppel
-- Liberado a produccion: Mayo 2014
--***************************************************************************************************

  BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
           -- ROLLBACK WORk;
          RETURN cod_ret;
      END IF ;
   END EXCEPTION ;

     SET LOCK MODE TO WAIT 4;

     IF NVL(pIdUsuario,'') =='' THEN
	 	  LET cod_ret = '00001'; -- No contiene Dato de Id Usuario
       RETURN cod_ret;
	END IF;

	IF NVL(pPass,'') == '' THEN
	 	  LET cod_ret = '00000'; -- No contiene Password
    ELSE

    	SELECT pass,f_pass,pass1,f_pass1,pass2,f_pass2,pass3,f_pass3
    	INTO sPass,sFpass,sPass1,sFpass1,sPass2,sFpass2,sPass3,sFpass3
    	FROM bdibei:"informix".bei_usuario
    	WHERE id_usuario=pIdUsuario;

    	IF(sPass==pPass)THEN
    	  	LET cod_ret = '00041'; -- PASSWORD Repetido
    	ELIF(sPass1==pPass)THEN
    	  	LET cod_ret = '00041'; -- PASSWORD Repetido
    	ELIF(sPass2==pPass)THEN
    	  	LET cod_ret = '00041'; -- PASSWORD Repetido
    	ELIF(sPass3==pPass)THEN
    	  	LET cod_ret = '00041'; -- PASSWORD Repetido
    	END IF;

		IF(cod_ret<>'00041')THEN

    		LET sPass3=sPass2;
    		LET sFpass3=sFpass2;

    		LET sPass2=sPass1;
    		LET sFpass2=sFpass1;

    		LET sPass1=sPass;
    		LET sFpass1=sFpass;

    		LET sPass=pPass;    	  
		ELSE
			--	ROLLBACK WORk;
		 RETURN cod_ret;
		END IF;

	END IF;

  RETURN cod_ret;
END;
END PROCEDURE;
CREATE PROCEDURE "informix".sp_session_temp2(pIp VARCHAR(20),pNavegador VARCHAR(200), pNumIntentosMax SMALLINT,pMinBloq INTEGER ,pExitoso SMALLINT)
   returning char(5) ;

    DEFINE cod_ret char(5);
    DEFINE sql_err integer ;
    
    
    DEFINE sIp VARCHAR(20);
    DEFINE sNumIntento SMALLINT;
    DEFINE sFBloqueoTemp DATETIME YEAR to SECOND;


    LET cod_ret  = "00000";
    LET sIp  = "";
  	LET sNumIntento = 0;
    LET sFBloqueoTemp = "";

    
	--****************************************************************************************************
	-- DESCRIPCION:  GUARDA INFO DE SESSION TEMPORAL
	-- AUTOR : Irving Guzman Salas - SOLSER
	-- FECHA : 28/08/2014
	-- BD: bdibei
	-- SOLICITO : BanCoppel
	-- FECHA LIBERACION A PRODUCCION: 22-ENERO-2015
	--***************************************************************************************************

  BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
        

      END IF ;
   END EXCEPTION ;

		SET LOCK MODE TO WAIT 3;
		
           LET cod_ret = '00000'; 
	   --RETURN cod_ret;

		IF LENGTH(TRIM(NVL(pIp,''))) == 0 THEN
			LET cod_ret = '00006'; 
			RETURN cod_ret;
		END IF;
				
		IF LENGTH(TRIM(NVL(pNavegador,'')))== 0  THEN
			LET cod_ret = '00007'; 
			RETURN cod_ret;
		END IF;
		
		SELECT ip,numIntento,f_bloqueo_temp 
		INTO sIp,sNumIntento ,sFBloqueoTemp
    	FROM bdibei:"informix".bei_session_temp 
   		WHERE ip =pIp 
   		AND navegador=pNavegador;
   	
   		IF LENGTH(TRIM(NVL(sIp,''))) ==0 THEN   -- Inicia Contador de Intentos
	
			INSERT INTO "informix".bei_session_temp(
            ip,
            navegador,
            f_registro,
            f_modifica,
            numIntento,
            f_bloqueo_temp,
            cont_intentos,
            cont_bloqueos
        	 )
        	VALUES(
            	pIp,
            	pNavegador,
            	CURRENT,
            	CURRENT,
            	1,
            	null,
                1,
                0
        	);
        	
        		LET cod_ret = '00000'; 
        	
        ELIF (NVL(pExitoso,0)>0) AND (sFBloqueoTemp IS NULL)  THEN -- Resetea Contador Intentos al Login Correcto si no esta Bloqueado
               
            UPDATE bdibei:"informix".bei_session_temp SET numIntento = 0, f_modifica = CURRENT 
			WHERE ip =pIp AND navegador=pNavegador;
            LET cod_ret = '00001'; 

        ELIF ((NVL(sNumIntento,0)>0)  AND (sNumIntento < (pNumIntentosMax-1) ))  THEN -- Aumenta Contador de Intentos
        
        	UPDATE bdibei:"informix".bei_session_temp SET numIntento = (numIntento+1), f_modifica = CURRENT ,cont_intentos=cont_intentos+1
			WHERE ip =pIp AND navegador=pNavegador;
			
        	LET cod_ret = '00002'; 
            LET sFBloqueoTemp = "";
        
        ELIF (sNumIntento >= (pNumIntentosMax-1) AND sNumIntento < pNumIntentosMax )  THEN -- Bloquea Peticiones
        
            LET sFBloqueoTemp =CURRENT+ pMinBloq units minute;

            UPDATE bdibei:"informix".bei_session_temp SET numIntento = (numIntento+1), f_modifica = CURRENT ,f_bloqueo_temp=sFBloqueoTemp,cont_bloqueos=cont_bloqueos+1,cont_intentos=cont_intentos+1
			WHERE ip =pIp AND navegador=pNavegador;
			
       	 	LET cod_ret = '00003'; 

        ELIF (sFBloqueoTemp is NULL) THEN
                UPDATE bdibei:"informix".bei_session_temp SET numIntento = (numIntento+1), f_modifica = CURRENT ,cont_intentos=cont_intentos+1
                WHERE ip =pIp AND navegador=pNavegador;
			
                LET cod_ret = '00002'; 

		ELIF (sFBloqueoTemp < CURRENT)  THEN 
				
          UPDATE bdibei:"informix".bei_session_temp SET numIntento = 1, f_modifica = CURRENT ,f_bloqueo_temp=NULL
          WHERE ip =pIp AND navegador=pNavegador;

          LET cod_ret = '00004'; -- Ya no esta Bloquedo

		ELIF (sFBloqueoTemp >= CURRENT) THEN

           	UPDATE bdibei:"informix".bei_session_temp SET f_modifica = CURRENT ,cont_intentos=cont_intentos+1
			WHERE ip =pIp AND navegador=pNavegador;
           
             LET cod_ret = '00005';  -- Continua  Bloquedo
        ELSE
            UPDATE bdibei:"informix".bei_session_temp SET numIntento = (numIntento+1), f_modifica = CURRENT ,cont_intentos=cont_intentos+1
			WHERE ip =pIp AND navegador=pNavegador;
			
        	LET cod_ret = '00002'; 
            LET sFBloqueoTemp = "";
		END IF;

  RETURN cod_ret;

END
END PROCEDURE;
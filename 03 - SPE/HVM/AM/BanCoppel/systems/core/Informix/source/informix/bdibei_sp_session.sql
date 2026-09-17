CREATE PROCEDURE "informix".sp_session(pIdUsuario INTEGER,
									 pNumCliente CHAR(9),
									 pIp VARCHAR(20),
									 pNavegador VARCHAR(200), 
									 pTipoSession SMALLINT,
									 
									 pCode VARCHAR(200) ,
									 
									 pCodeNew VARCHAR(200) ,
									 pTokenVirtualNew VARCHAR(20),
									 pMin INTEGER,
                                     pDel INTEGER)
   returning char(5) ;


    DEFINE cod_ret char(5);
    DEFINE sql_err integer ;
    
    DEFINE sIdUsuario INTEGER;
    DEFINE sNumCliente CHAR(9);
    DEFINE sIp VARCHAR(20);
    DEFINE sNavegador VARCHAR(200); 
    DEFINE sTipoSession SMALLINT;
    DEFINE sCode1 VARCHAR(200) ;
    DEFINE sTokenVirtual1 VARCHAR(20);
    DEFINE sCode2 VARCHAR(200) ;
    DEFINE sTokenVirtual2 VARCHAR(20);
    DEFINE sFecha DATETIME YEAR to SECOND; 

    DEFINE sFechaReset DATETIME YEAR to SECOND; 
    DEFINE sFecha_Mod DATETIME YEAR to SECOND; 
    
    LET cod_ret  = "00000";
    LET sIdUsuario =0;
    LET sNumCliente = "";
    LET sIp = "";
    LET sNavegador = ""; 
    LET sTipoSession =0;
    LET sCode1 = "" ;
    LET sTokenVirtual1 = "";
    LET sCode2 = "" ;
    LET sTokenVirtual2 = "";
    LET sFecha_Mod="";
    LET sFechaReset="";
    
	--****************************************************************************************************
	-- DESCRIPCION:  GUARDA INFO DE SESSION y VALIDA
	-- AUTOR : Irving Guzman Salas - SOLSER
	-- FECHA : 24/09/2014
	-- BD: bdibei
	-- SOLICITO : BanCoppel
	-- FECHA LIBERACION A PRODUCCION: 22-ENERO-2015
	--***************************************************************************************************

  BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
            RETURN cod_ret;

      END IF ;
   END EXCEPTION ;

		SET LOCK MODE TO WAIT 3;
		
        IF NVL(pDel,2)== 2   THEN
            IF NVL(pIdUsuario,0) == 0 THEN
				LET cod_ret = '00009'; 
				RETURN cod_ret;
			END IF;

			DELETE  FROM bdibei:"informix".bei_session  
			WHERE  id_usuario=pIdUsuario
			OR (code1 = pCode  OR code2 = pCode);
			LET cod_ret = '00008'; 
            RETURN cod_ret;
        END IF;


		IF LENGTH(TRIM(NVL(pCode,'')))== 0  THEN
			
			IF LENGTH(TRIM(NVL(pCodeNew,'')))== 0  THEN
				LET cod_ret = '00004'; 
				RETURN cod_ret;
			END IF;
			
			IF LENGTH(TRIM(NVL(pTokenVirtualNew,'')))== 0  THEN
				LET cod_ret = '00004'; 
				RETURN cod_ret;
			END IF;
			
			IF NVL(pIdUsuario,0) == 0 THEN
				LET cod_ret = '00004'; 
				RETURN cod_ret;
			END IF;
				
			IF LENGTH(TRIM(NVL(pNumCliente,'')))== 0  THEN
				LET cod_ret = '00004'; 
				RETURN cod_ret;
			END IF;
		
			IF LENGTH(TRIM(NVL(pIp,'')))== 0  THEN
				LET cod_ret = '00004'; 
				RETURN cod_ret;
			END IF;
		
			IF LENGTH(TRIM(NVL(pNavegador,'')))== 0  THEN
				LET cod_ret = '00004'; 
				RETURN cod_ret;
			END IF;

			
				SELECT id_usuario
				INTO sIdUsuario
   				FROM bdibei:"informix".bei_session 
   				WHERE id_usuario=pIdUsuario;


			IF sIdUsuario IS NOT NULL THEN
				DELETE  FROM bdibei:"informix".bei_session  
				WHERE  id_usuario=sIdUsuario;
				LET cod_ret = '00006'; 
				-- Se Borrra Session, ya Es doble Login
				RETURN cod_ret;
			END IF;
			
		
			INSERT INTO "informix".bei_session(
            id_usuario,
            num_cliente,
            code1,
            tokenvirtual1,
            ip,
            navegador,
            tipo_session,
            f_registro,
            f_modifica
        	 )
        	VALUES(
            	pIdUsuario,
            	pNumCliente,
            	pCodeNew,
            	pTokenVirtualNew,
            	pIp,
            	pNavegador,
            	pTipoSession,
                CURRENT,
                CURRENT
        	);
			
			
			LET cod_ret = '00005'; 
			RETURN cod_ret;
		END IF;
		
		

		IF NVL(pMin,0) == 0 THEN
			LET cod_ret = '00001'; 
			RETURN cod_ret;
		END IF;
		
	
		

		
	LET sFecha =CURRENT - pMin units minute;	
					
			
	SELECT id_usuario
	INTO sIdUsuario
    FROM bdibei:"informix".bei_session 
   	WHERE (code1 = pCode  OR code2 = pCode)
   	AND f_modifica < sFecha ;


		IF NVL(sIdUsuario,0) <> 0 THEN
		
				DELETE  FROM bdibei:"informix".bei_session  
				WHERE  id_usuario=sIdUsuario;

				LET cod_ret = '00002'; 
				
				-- Se Borrra Session, ya que es invalida
			RETURN cod_ret;
		END IF;
		
	LET sIdUsuario = 0; 
	
	SELECT id_usuario
	INTO sIdUsuario
    FROM bdibei:"informix".bei_session 
   	WHERE (code1 = pCode  OR code2 = pCode)
   	AND f_modifica > sFecha ;	
	
	
		IF NVL(sIdUsuario,0) == 0 THEN
				LET cod_ret = '00003'; 
					-- No Existe Session
			RETURN cod_ret;
		END IF;
	
		
		IF NVL(pIdUsuario,0) == 0 THEN
			LET cod_ret = '00001'; 
			RETURN cod_ret;
		END IF;
				
		IF LENGTH(TRIM(NVL(pNumCliente,'')))== 0  THEN
			LET cod_ret = '00001'; 
			RETURN cod_ret;
		END IF;
		
		IF LENGTH(TRIM(NVL(pIp,'')))== 0  THEN
			LET cod_ret = '00001'; 
			RETURN cod_ret;
		END IF;
		
		IF LENGTH(TRIM(NVL(pNavegador,'')))== 0  THEN
			LET cod_ret = '00001'; 
			RETURN cod_ret;
		END IF;
		
		IF LENGTH(TRIM(NVL(pCodeNew,'')))== 0  THEN
			LET cod_ret = '00001'; 
			RETURN cod_ret;
		END IF;
		
		IF LENGTH(TRIM(NVL(pTokenVirtualNew,'')))== 0  THEN
			LET cod_ret = '00001'; 
			RETURN cod_ret;
		END IF;
					

	SELECT  code1,tokenvirtual1 , code2,tokenvirtual2,f_modifica
	INTO sCode1,sTokenVirtual1,sCode2,sTokenVirtual2,sFecha_Mod
    FROM bdibei:"informix".bei_session 
   	WHERE (code1 = pCode  OR code2 = pCode)
   --AND ip =pIp 
   	AND navegador=pNavegador
   	AND id_usuario=pIdUsuario
   	AND num_cliente=pNumCliente
   	AND tipo_session=pTipoSession;
   	
	
   	IF LENGTH(TRIM(NVL(sCode1,'')))== 0 THEN
		LET cod_ret = '00004'; 
		-- Session no Coincide con datos Enviados Se procede a Borrar, Posible robo de session

		DELETE  FROM bdibei:"informix".bei_session  
		WHERE  id_usuario=pIdUsuario;	
					
		RETURN cod_ret;
	END IF;
	
    LET sFechaReset =CURRENT - 30 units SECOND;	

    IF(sFecha_Mod<sFechaReset) THEN
    	--Actualiza Session con nuevos Valores
        UPDATE bdibei:"informix".bei_session SET code2 =sCode1,	tokenvirtual2=sTokenVirtual1,	code1 =pCodeNew,	tokenvirtual1=pTokenVirtualNew,	 f_modifica = CURRENT 
        WHERE (code1 = pCode  OR code2 = pCode);
    
  
        LET cod_ret = '00000'; 
    ELSE

         LET cod_ret = '00007'; 
    END IF;




  RETURN cod_ret;

END
END PROCEDURE;
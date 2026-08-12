CREATE PROCEDURE "informix".sp_ins_user_pass_web(pempresa char(3),pnumcte char(20), pass_first_part char (4), puser_modif varchar(20)) 
    RETURNING CHAR(5) AS CodigoRetorno

    DEFINE iSqlErr              INTEGER;
    DEFINE v_sCodRet            CHAR(5);
	DEFINE v_pass_second_part   CHAR(4);
	DEFINE encry_pass           VARCHAR(20);
	
	DEFINE vnumcte1         VARCHAR(20);
	DEFINE vnumcte2         VARCHAR(20);
	DEFINE vcodret1 		CHAR(5);
	
	LET vnumcte1 = '';
	LET vnumcte2 = '';
	LET vcodret1 = '';

   -- SET DEBUG FILE TO  "sp_ins_usr_pass.out"; 
    --TRACE ON;
	
	LET v_sCodRet = '00000';
	LET encry_pass = "";

    BEGIN
        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET v_sCodRet = iSqlErr;
                RETURN v_sCodRet;
            END IF;
        END EXCEPTION;
		
		SET ISOLATION DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT FIRST 1 numcte  
		  INTO vnumcte1
		FROM bdiedoelec:edelec_alta_serv 
		WHERE numcte = pnumcte;
		  
		SELECT FIRST 1 numcte  
		  INTO vnumcte2
		FROM bdiedoelec:edelec_constancia 
		WHERE numcte = pnumcte;
		
		IF ((vnumcte1 IS NULL OR vnumcte1 = '') AND (vnumcte2 IS NULL OR vnumcte2 = '')) THEN
		
			LET v_sCodRet = '00001'; --Cliente No se encuentra en el Alta del Servicio
			RETURN v_sCodRet;
					
		END IF 
		
		SELECT password  
		  INTO encry_pass
		FROM bdinteg:si_ejecut 
		WHERE ejecutivo = 'informix';

		SET encryption password encry_pass;
	
		SELECT SUBSTR(sp_random(),1,4) 
		  INTO v_pass_second_part
		FROM bdiedoelec:systables where tabname = "systables";

		/*
		EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','idplant',pnumcte,null,null,'1',v_pass_second_part,null,null,null,null,null,null,null,null,null,null,null)			
		INTO vcodret1;	
		
		IF vcodret1 <> '00000' THEN
		
			LET v_sCodRet=vcodret1;
			RETURN v_sCodRet; 
		
		END IF
		*/
		
		IF(SELECT count(numcte) FROM bdiedoelec:edelec_usr_pass WHERE numcte = pnumcte) > 0 THEN
		
			UPDATE bdiedoelec:edelec_usr_pass 
			   SET pass_first_part = encrypt_aes(pass_first_part), 
			       pass_sec_part = encrypt_aes(v_pass_second_part), 
				   fecha_ultima_mod = TODAY, 
				   user_modif = puser_modif
			WHERE numcte = pnumcte;			 
		ELSE
		
			INSERT INTO bdiedoelec:edelec_usr_pass (empresa,numcte,pass_first_part,pass_sec_part,fecha_alta,fecha_ultima_mod,user_modif)
				VALUES (pempresa,pnumcte,encrypt_aes(pass_first_part),encrypt_aes(v_pass_second_part),TODAY,TODAY,puser_modif);				 
		END IF
			
		RETURN v_sCodRet;    

    END
END PROCEDURE;
CREATE PROCEDURE "informix".sp_ver_user_pass (pempresa char(3),pnumcte char(20)) 
    RETURNING CHAR(6) AS CodigoRetorno

    DEFINE iSqlErr              INTEGER;
    DEFINE v_sCodRet            CHAR(6);
	DEFINE v_numcte				CHAR(20);
	

    --SET DEBUG FILE TO  "sp_ver_user_pass"; 
    --TRACE ON;
	
	LET v_sCodRet = '000';
	LET v_numcte = '000000000';
	
    BEGIN
        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET v_sCodRet = iSqlErr;
                RETURN v_sCodRet;
            END IF;
        END EXCEPTION;
		

		SELECT numcte
          INTO v_numcte	
		  FROM bdiedoelec:edelec_usr_pass WHERE numcte = pnumcte; 
		  
		 IF (v_numcte IS NULL OR v_numcte = '' ) THEN
		 
			LET v_sCodRet = '001'; --Cliente No Existe
			RETURN v_sCodRet;
		
		ELSE
		
			RETURN v_sCodRet;    
		
		END IF

    END
END PROCEDURE;
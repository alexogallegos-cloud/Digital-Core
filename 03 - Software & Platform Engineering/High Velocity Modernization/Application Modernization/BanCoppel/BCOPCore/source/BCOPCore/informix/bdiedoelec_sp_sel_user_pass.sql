CREATE PROCEDURE "informix".sp_sel_user_pass (pempresa char(3),pnumcte char(20), pseed lvarchar(43)) 
    RETURNING CHAR(6) AS CodigoRetorno, CHAR(20) AS numcte, CHAR(4) AS pass_first_part, CHAR(4) AS pass_sec_part

    DEFINE iSqlErr              INTEGER;
    DEFINE v_sCodRet            CHAR(6);
	DEFINE v_pass_second_part   CHAR (4);
	DEFINE v_numcte             CHAR(20);
	DEFINE v_pass_first_part    CHAR(4); 
	DEFINE v_pass_sec_part      CHAR(4); 
	DEFINE v_seed               VARCHAR(20);
	DEFINE encry_pass           VARCHAR(20);

    --SET DEBUG FILE TO  "sp_sel_user_pass"; 
    --TRACE ON;
	
	LET v_sCodRet = '000';
	LET v_numcte = '000000000';
	LET v_pass_first_part = '0000';
	LET v_pass_sec_part = '0000';
    LET encry_pass = "";
	
    BEGIN
        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET v_sCodRet = iSqlErr;
                RETURN v_sCodRet,v_numcte, v_pass_first_part, v_pass_sec_part;
            END IF;
        END EXCEPTION;
		
		SELECT password  
		  INTO encry_pass
		  FROM bdinteg:si_ejecut 
		  WHERE ejecutivo = 'informix';

        SET encryption password encry_pass;
		
		SELECT decrypt_binary(pseed) 
		  INTO v_seed
		  FROM "informix".systables WHERE tabid = 1;		
		 
		IF v_seed <> encry_pass THEN
			RAISE EXCEPTION -26008;
		END IF 

		SELECT numcte, decrypt_binary(pass_first_part), decrypt_binary(pass_sec_part)
          INTO v_numcte, v_pass_first_part, v_pass_sec_part		
		  FROM bdiedoelec:edelec_usr_pass WHERE numcte = pnumcte; 
		
		RETURN v_sCodRet,v_numcte, v_pass_first_part, v_pass_sec_part;    

    END
END PROCEDURE;
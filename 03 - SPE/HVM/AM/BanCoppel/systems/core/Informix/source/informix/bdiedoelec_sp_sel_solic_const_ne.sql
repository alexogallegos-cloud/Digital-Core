CREATE PROCEDURE "informix".sp_sel_solic_const_ne (pempresa char(3)) 
    RETURNING CHAR(5) AS v_sCodRet, CHAR(20) AS v_numcte, CHAR(20) AS v_cuenta, CHAR(4) AS v_ejercicio, DATE AS v_fecha_recepcion 
	
    DEFINE iSqlErr              INTEGER;
    DEFINE v_sCodRet            CHAR(5);
	
	DEFINE v_numcte 			CHAR(20);
	DEFINE v_cuenta 			CHAR(20);
	DEFINE v_ejercicio		    CHAR(4);
	DEFINE v_fecha_recepcion    DATE;
	
    --SET DEBUG FILE TO  "sp_sel_solic_const_ne.out"; 
    --TRACE ON;
	
	LET v_sCodRet = '000';
	LET v_numcte = ''; 			
	LET v_cuenta = '';
	LET v_ejercicio = '';		
	LET v_fecha_recepcion = TODAY;
		
    BEGIN
        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET v_sCodRet = iSqlErr;
                RETURN v_sCodRet,'','','','';
            END IF;
        END EXCEPTION;
		
		FOREACH WITH HOLD 
			SELECT numcte,cuenta,ejercicio,fecha_recepcion
			  INTO v_numcte,v_cuenta,v_ejercicio,v_fecha_recepcion
			  FROM bdiedoelec:edelec_solic_const_ne 
			 WHERE 1 = 1
				  
				 RETURN v_sCodRet,v_numcte,v_cuenta,v_ejercicio,v_fecha_recepcion  WITH resume;
				 
			CONTINUE FOREACH;
		END FOREACH;
		
    END
END PROCEDURE;
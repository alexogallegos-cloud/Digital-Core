CREATE PROCEDURE "informix".sp_del_serv_solic_ne (pempresa char(3)) 
    RETURNING CHAR(5) AS v_sCodRet
	
    DEFINE iSqlErr              INTEGER;
    DEFINE v_sCodRet            CHAR(5);
	
	DEFINE v_numcte 			CHAR(20);
	DEFINE v_cuenta 			CHAR(20);
	DEFINE v_producto 			CHAR(4);
	DEFINE v_fecha_corte	    DATE;
	DEFINE v_fecha_recepcion    DATE;
	DEFINE v_valor              SMALLINT;
	
    --SET DEBUG FILE TO  "sp_del_serv_solic_ne.out"; 
    --TRACE ON;
	
	LET v_sCodRet = '000';
	LET v_numcte = ''; 			
	LET v_cuenta = '';
	LET v_producto = '';	
	LET v_fecha_corte = TODAY;
	LET v_fecha_recepcion = TODAY;
	LET v_valor = 0;
		
    BEGIN
        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET v_sCodRet = iSqlErr;
                RETURN v_sCodRet;
            END IF;
        END EXCEPTION;
		
			SELECT (valor)::SMALLINT
			  INTO v_valor 
			  FROM bdiedoelec:edelec_param 
		     WHERE cod_param = 6;
			
			DELETE FROM bdiedoelec:edelec_serv_solic_ne 
			      WHERE fecha_modificacion + v_valor < TODAY;
			
		RETURN v_sCodRet;    
    END
END PROCEDURE;
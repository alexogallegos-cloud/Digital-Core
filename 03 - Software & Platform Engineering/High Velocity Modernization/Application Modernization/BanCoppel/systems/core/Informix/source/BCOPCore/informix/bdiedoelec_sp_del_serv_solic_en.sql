CREATE PROCEDURE "informix".sp_del_serv_solic_en (pempresa char(3)) 
    RETURNING CHAR(5) AS v_sCodRet
	
    DEFINE iSqlErr             	 	INTEGER;
    DEFINE v_sCodRet            	CHAR(5);
	DEFINE v_numcte 				CHAR(20);
	DEFINE v_cuenta 				CHAR(20);
	DEFINE v_producto 				CHAR(4);
	DEFINE v_status_envio_edocta	CHAR(2);
	DEFINE v_fecha_corte	    	DATE;
	DEFINE v_fecha_recepcion    	DATE;
	DEFINE v_fecha_modificacion    	DATE;
	DEFINE v_valor 					CHAR(3);
	DEFINE pFechaSol 				DATE;
	
    --SET DEBUG FILE TO  "sp_del_serv_solic_en.out"; 
    --TRACE ON;
	
	LET v_sCodRet = '000';
	LET v_numcte = ''; 			
	LET v_cuenta = '';
	LET v_producto = '';	
	LET v_status_envio_edocta = '';	
	LET v_fecha_corte = TODAY;
	LET v_fecha_recepcion = TODAY;
	LET v_fecha_modificacion = TODAY;
	LET v_valor ='';
	LET pFechaSol ='';
		
    BEGIN
        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET v_sCodRet = iSqlErr;
                RETURN v_sCodRet;
            END IF;
        END EXCEPTION;
		
		SELECT TRIM(valor)
		INTO v_valor
		FROM bdiedoelec:edelec_param
		WHERE cod_param=7;
		
		LET pFechaSol = TODAY - cast(v_valor as integer);	
				
		FOREACH WITH HOLD 
			SELECT cuenta,fecha_corte 
			  INTO v_cuenta,v_fecha_corte
			  FROM bdiedoelec:edelec_log_serv_solic 
			 WHERE status_envio_edocta = 'AE'
				AND fecha_modificacion < pFechaSol
			ORDER BY fecha_corte
			
			SELECT fecha_recepcion 
			  INTO v_fecha_recepcion
			  FROM bdiedoelec:edelec_serv_solic
			 WHERE empresa = pempresa
				AND cuenta = v_cuenta
				AND fecha_corte = v_fecha_corte;
			
			FOREACH WITH HOLD 
				SELECT numcte,producto,status_envio_edocta,fecha_modificacion 
				  INTO v_numcte,v_producto,v_status_envio_edocta,v_fecha_modificacion
				  FROM bdiedoelec:edelec_log_serv_solic 
				 WHERE cuenta = v_cuenta
					AND fecha_corte = v_fecha_corte
				ORDER BY fecha_modificacion
		
				INSERT INTO bdiedoelec:edelec_serv_solic_en (empresa,numcte,cuenta,producto,status_envio_edocta,fecha_corte,fecha_recepcion,fecha_modificacion)
					VALUES (pempresa,v_numcte,v_cuenta,v_producto,v_status_envio_edocta,v_fecha_corte,v_fecha_recepcion,v_fecha_modificacion);
				
				CONTINUE FOREACH;
				END FOREACH;
				DELETE FROM bdiedoelec:edelec_serv_solic 
					  WHERE numcte = v_numcte
						AND cuenta = v_cuenta
						AND producto = v_producto 
						AND fecha_corte = v_fecha_corte;
				
				DELETE FROM bdiedoelec:edelec_log_serv_solic
					  WHERE numcte = v_numcte
						AND cuenta = v_cuenta
						AND producto = v_producto 
						AND fecha_corte = v_fecha_corte;
						
		CONTINUE FOREACH;
		END FOREACH;
		
		RETURN v_sCodRet;    
    END
END PROCEDURE;
CREATE PROCEDURE "informix".sp_del_serv_solic (pempresa char(3)) 
    RETURNING CHAR(5) AS v_sCodRet
	
    DEFINE iSqlErr              INTEGER;
    DEFINE v_sCodRet            CHAR(5);
	DEFINE v_pass_second_part   CHAR (4);
	DEFINE encry_pass           VARCHAR(20);
	
	DEFINE v_numcte 			CHAR(20);
	DEFINE v_cuenta 			CHAR(20);
	DEFINE v_producto 			CHAR(4);
	DEFINE v_fecha_corte	    DATE;
	DEFINE v_fecha_recepcion    DATE;
	
SET DEBUG FILE TO  "/home/sysdba/salida_trace/sp_del_serv_solic.out"; 
TRACE ON;
	
	LET v_sCodRet = '000';
	LET v_numcte = ''; 			
	LET v_cuenta = '';
	LET v_producto = '';	
	LET v_fecha_corte = TODAY;
	LET v_fecha_recepcion = TODAY;
		
    BEGIN
        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET v_sCodRet = iSqlErr;
                RETURN v_sCodRet;
            END IF;
        END EXCEPTION;
		
		FOREACH WITH HOLD 
			SELECT b.numcte,b.cuenta,b.producto,b.fecha_corte 
		      INTO v_numcte,v_cuenta,v_producto,v_fecha_corte
			  FROM bdiedoelec:edelec_serv_solic a, bdiedoelec:edelec_log_serv_solic b 
			 WHERE a. numcte = b. numcte
			   AND a.cuenta = b.cuenta
			   AND a.producto = b.producto
			   AND a. fecha_vigencia < (select fecha_hoy from bdinteg:si_fechas)
               AND NOT EXISTS ( SELECT 1 FROM bdiedoelec:edelec_log_serv_solic c 
			                            WHERE c.empresa = pempresa
										  AND c.numcte = a. numcte 
										  AND c.producto = a.producto
                                          AND c.fecha_corte = a.fecha_corte 
										  AND c.status_envio_edocta = 'AE')
		  GROUP BY b.numcte,b.cuenta,b.producto,b.fecha_corte 
		  ORDER BY fecha_corte ASC
			
			INSERT INTO bdiedoelec:edelec_serv_solic_ne (empresa,numcte,cuenta,producto,fecha_corte,fecha_recepcion,fecha_modificacion)
				  VALUES (pempresa,v_numcte,v_cuenta,v_producto,v_fecha_corte,v_fecha_recepcion,TODAY);
			
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
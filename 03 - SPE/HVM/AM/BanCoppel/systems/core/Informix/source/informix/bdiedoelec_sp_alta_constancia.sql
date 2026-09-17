CREATE PROCEDURE "informix".sp_alta_constancia (pempresa char(3),pnumcte char(20), pcuenta char(20), pstatus_serv_elec char(1), puser_modif char(20)) 
    RETURNING CHAR(5) AS CodigoRetorno

    DEFINE iSqlErr        	INTEGER;
    DEFINE v_sCodRet   	   	CHAR(5);
	DEFINE v_numcte     	CHAR(20);
	DEFINE v_cuenta     	CHAR(20);
	
    --SET DEBUG FILE TO  "sp_alta_constancia.out"; 
    --TRACE ON;
	
	LET v_sCodRet = '000';
	LET v_numcte = "";
	LET v_cuenta = "";
		
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
			FROM bdinteg:si_cliente
			WHERE numcte = pnumcte;
			   
						  
		IF (v_numcte IS NULL OR v_numcte = '' ) THEN
		
			LET v_sCodRet = '001'; --Cliente No Existe
			RETURN v_sCodRet;	
			
		END IF	
		
		SELECT cuenta
			INTO v_cuenta
			FROM bdicheq:sc_maechq
			WHERE cuenta = pcuenta
				AND num_cte = pnumcte;
		
		IF (v_cuenta IS NULL OR v_cuenta = '' ) THEN
		
			LET v_sCodRet = '002'; --Cuenta No VÃ¡lida
			RETURN v_sCodRet;
		
		END IF	
				
		IF pstatus_serv_elec NOT IN ('A','I') THEN
		
			LET v_sCodRet = '003'; --Estatus de Servicio InvÃ¡lido
			RETURN v_sCodRet;
					
		END IF	
		
		IF pempresa <> '001' THEN
		
			LET v_sCodRet = '004'; --Empresa InvÃ¡lida
			RETURN v_sCodRet;
					
		END IF	
		
			
		IF NOT EXISTS (SELECT cuenta FROM bdiedoelec:edelec_constancia WHERE numcte = pnumcte AND cuenta = pcuenta) THEN
						
					INSERT INTO edelec_constancia (empresa,numcte,cuenta,status_serv_elec,fecha_alta_servicio,fecha_ultima_mod,
										fecha_cancel_servicio,user_modif)
					VALUES (pempresa,pnumcte,pcuenta,'A',TODAY,TODAY,null,puser_modif);

		ELIF EXISTS (SELECT cuenta FROM bdiedoelec:edelec_constancia WHERE numcte = pnumcte AND cuenta = pcuenta) THEN
							
					IF pstatus_serv_elec = 'I' THEN -- Cancelar Servicio
					
						UPDATE edelec_constancia SET status_serv_elec = pstatus_serv_elec, fecha_ultima_mod = TODAY, 
													fecha_cancel_servicio = TODAY,	user_modif = puser_modif
						 WHERE numcte = pnumcte AND cuenta = pcuenta;
						 
					ELIF pstatus_serv_elec = 'A' THEN  -- Reactivar Servicio
					
						UPDATE edelec_constancia SET status_serv_elec = pstatus_serv_elec,fecha_ultima_mod = TODAY, 
													fecha_cancel_servicio = null,	user_modif = puser_modif				
						 WHERE numcte = pnumcte AND cuenta = pcuenta;
					
					END IF
		END IF
    END
	
	RETURN v_sCodRet;    
	
END PROCEDURE;
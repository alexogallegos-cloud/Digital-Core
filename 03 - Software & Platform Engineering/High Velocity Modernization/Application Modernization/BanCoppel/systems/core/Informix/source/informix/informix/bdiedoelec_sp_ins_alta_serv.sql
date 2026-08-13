CREATE PROCEDURE "informix".sp_ins_alta_serv (pempresa char(3),pnumcte char(20), pcuenta char(20), pproducto char(4), pstatus_serv_elec char(1), pstatus_serv_imp char(1), puser_modif char(20)) 
    RETURNING CHAR(5) AS CodigoRetorno

    DEFINE iSqlErr              INTEGER;
    DEFINE v_sCodRet            CHAR(5);
	DEFINE v_pass_second_part   CHAR (4);
	DEFINE encry_pass           VARCHAR(20);
	DEFINE v_numcte_cap         CHAR(20);
	DEFINE v_numcte_cred        CHAR(20);
	DEFINE v_numcte_pres_res    CHAR(20);
	DEFINE v_status_cta         CHAR(1);
	DEFINE v_status_cred        CHAR(2);
	DEFINE v_dia_corte       	SMALLINT ;

    --SET DEBUG FILE TO  "sp_ins_alta_serv.out"; 
    --TRACE ON;
	
	LET v_sCodRet = '000';
	LET encry_pass = "";
	LET v_numcte_cap = "";
	LET v_numcte_cred = "";
	LET v_numcte_pres_res = "";
	LET v_status_cta = "";
	LET v_status_cred = "";
	LET v_dia_corte = 0;

	
    BEGIN
        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET v_sCodRet = iSqlErr;
                RETURN v_sCodRet;
            END IF;
        END EXCEPTION;
		
		IF SUBSTR(pcuenta,1,1) = '1' OR SUBSTR(pcuenta,1,1) = '2' THEN
		
			SELECT a.numcte, b.status_cta
			  INTO v_numcte_cap,v_status_cta
			  FROM bdinteg:si_cliente a, bdicheq:sc_maechq b 
			 WHERE a.numcte = b.num_cte
			   AND a.numcte = pnumcte
			   AND b.cuenta = pcuenta
			   AND b.producto = pproducto;
			   
		ELIF SUBSTR(pcuenta,1,2) = '60' OR SUBSTR(pcuenta,1,2) = '66' OR SUBSTR(pcuenta,1,2) = '70'  OR SUBSTR(pcuenta,1,2) = '78'  OR SUBSTR(pcuenta,1,2) = '81' THEN	   
		
			SELECT a.numcte, b.status_cred 
			  INTO v_numcte_cred, v_status_cred
			  FROM bdinteg:si_cliente a, bdicred:sd_maecred b
			  WHERE a.numcte = b.numcte
				AND a.numcte = pnumcte
				AND b.num_credito = pcuenta
				AND b.num_producto = pproducto;
				
		ELIF SUBSTR(pcuenta,1,2) IN ('61','63','76','77') THEN	 
		
			SELECT a.numcte, b.status_cred 
			  INTO v_numcte_pres_res, v_status_cred
			  FROM bdinteg:si_cliente a, bdicred:sd_maecredcrd b
			  WHERE a.numcte = b.numcte
				AND a.numcte = pnumcte
				AND b.num_credito = pcuenta
				AND b.num_producto = pproducto;
				
		END IF
								  
		IF (v_numcte_cap IS NULL OR v_numcte_cap = '' ) AND (v_numcte_cred IS NULL OR v_numcte_cred = '' ) AND  (v_numcte_pres_res IS NULL OR v_numcte_pres_res = '') THEN
		
			LET v_sCodRet = '001'; --Cliente No Existe
			RETURN v_sCodRet;
					
		END IF	
		
		IF pstatus_serv_elec NOT IN ('A','I') OR pstatus_serv_imp NOT IN ('A','I') THEN
		
			LET v_sCodRet = '002'; --Servicios No Validos 
			RETURN v_sCodRet;
					
		END IF	
		
		IF (SUBSTR(pcuenta,1,1) = '1' OR SUBSTR(pcuenta,1,1) = '2') AND v_status_cta IN (2,6,7,8) THEN

			LET v_sCodRet = '003'; -- Estatus de la Cuenta No Valido
			RETURN v_sCodRet;
		
		END IF
		
		IF (SUBSTR(pcuenta,1,1) = '6' OR SUBSTR(pcuenta,1,1) = '7') AND v_status_cred NOT IN ('AA','BA','BT','VP','E1','E2','E3') THEN	--IFRS 

			LET v_sCodRet = '004'; -- Estatus del CrÃ©dito No Valido
			RETURN v_sCodRet;
		
		END IF
		
		IF (v_numcte_cap IS NOT NULL AND v_numcte_cap <> '' ) AND v_status_cta IN (1,3,4,5) THEN
		
			LET v_status_cred = null;
			LET pstatus_serv_imp = 'I'; -- No se Imprimen
			
			SELECT DAY(fecha_alta)
			     INTO v_dia_corte
			     FROM bdicheq:sc_maenoc 
				WHERE cuenta = pcuenta;
				
		ELIF (v_numcte_cred IS NOT NULL AND v_numcte_cred <> '') AND v_status_cred IN ('AA','BA','BT','E1','E2','E3') THEN	--IFRS 
		
			LET v_status_cta = null;	
			SELECT dia_corte 
				  INTO v_dia_corte
				  FROM bdicred:sd_maecredanexo
				 WHERE num_credito = pcuenta
				   AND empresa = pempresa;
			
		ELIF (v_numcte_pres_res IS NOT NULL AND v_numcte_pres_res <> '') AND v_status_cred IN ('AA','BA','BT','VP','E1','E2','E3') THEN	--IFRS 
		
			LET v_status_cta = null;
			
			SELECT dia_corte 
				  INTO v_dia_corte
				  FROM bdicred:sd_maecredanexocrd 
				 WHERE num_credito = pcuenta
				   AND empresa = pempresa;
		END IF
		
		
		IF (v_dia_corte = 0) OR (v_dia_corte = '') OR (v_dia_corte IS NULL) THEN
		
			LET v_sCodRet = '005'; --Cuenta no existe en sc_maenoc o sd_maecredanexocrd, segÃºn se trate
			RETURN v_sCodRet;
					
		END IF	
		
				
		IF NOT EXISTS (SELECT numcte FROM bdiedoelec:edelec_alta_serv WHERE numcte = pnumcte AND cuenta = pcuenta AND producto = pproducto ) AND 
		                v_dia_corte > 0 THEN
						
					INSERT INTO edelec_alta_serv (empresa,numcte,cuenta,producto,status_serv_elec,status_serv_imp,status_cta,status_cred,fecha_alta_servicio,	 
										fecha_ultima_mod,fecha_cancel_servicio,tipo_modificacion,dia_corte,user_modif)
					VALUES (pempresa,pnumcte,pcuenta,pproducto,'A',pstatus_serv_imp,v_status_cta,v_status_cred,TODAY,TODAY,null,'U',v_dia_corte,puser_modif);

		ELIF EXISTS (SELECT numcte FROM bdiedoelec:edelec_alta_serv WHERE numcte = pnumcte AND cuenta = pcuenta AND producto = pproducto ) THEN
				
					IF ( pstatus_serv_elec = 'I' AND pstatus_serv_imp = 'I') AND (SUBSTR(pcuenta,1,1) = '6' OR SUBSTR(pcuenta,1,1) = '7') OR SUBSTR(pcuenta,1,2) = '81'THEN
						LET pstatus_serv_imp = 'A';
					END IF
					
					IF pstatus_serv_elec = 'I' THEN -- Cancelar Servicio
						UPDATE edelec_alta_serv SET status_serv_elec = pstatus_serv_elec, status_serv_imp = pstatus_serv_imp, fecha_ultima_mod = TODAY, 
													fecha_cancel_servicio = TODAY,	tipo_modificacion = 'U', user_modif = puser_modif
						 WHERE numcte = pnumcte AND cuenta = pcuenta AND producto = pproducto;
					ELIF pstatus_serv_elec = 'A' THEN  -- Reactivas Servicio
					
						UPDATE edelec_alta_serv SET status_serv_elec = pstatus_serv_elec, status_serv_imp = pstatus_serv_imp, fecha_ultima_mod = TODAY, 
													fecha_cancel_servicio = null,	tipo_modificacion = 'U', user_modif = puser_modif				
						 WHERE numcte = pnumcte AND cuenta = pcuenta AND producto = pproducto;
					
					ELSE 
						
						UPDATE edelec_alta_serv SET status_serv_elec = pstatus_serv_elec, status_serv_imp = pstatus_serv_imp, fecha_ultima_mod = TODAY, 
													tipo_modificacion = 'U', user_modif = puser_modif				
						 WHERE numcte = pnumcte AND cuenta = pcuenta AND producto = pproducto;
					END IF
		END IF
    END
	
	RETURN v_sCodRet;    
	
END PROCEDURE;
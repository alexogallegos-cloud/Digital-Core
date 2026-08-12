CREATE PROCEDURE "informix".sp_upd_status_pres(pempresa char(3)) 
RETURNING CHAR(5) AS CodigoRetorno

    DEFINE iSqlErr              INTEGER;
    DEFINE v_sCodRet            CHAR(5);
	DEFINE v_valor 				SMALLINT;
	DEFINE v_fecha_hoy 			DATE;
	DEFINE v_numcte 			CHAR(20);
	DEFINE v_cuenta 			CHAR(20);
	DEFINE v_status_cred_serv   CHAR(2);
	DEFINE v_status_cred_cred   CHAR(2);
	DEFINE v_status_serv_elec   CHAR(1);
	DEFINE v_status_serv_imp    CHAR(1);
	DEFINE v_fecha_cancel_servicio DATE;
	DEFINE cMtoVen				DECIMAL(14,2);
	
	--SET DEBUG FILE TO  "sp_upd_status_pres.out"; 
    --TRACE ON;

	LET v_sCodRet = '000';
	LET v_valor = 0;
	LET v_fecha_hoy = TODAY;
	LET v_numcte = ''; 			
	LET v_cuenta = '';			
	LET v_status_cred_serv = '';  
	LET v_status_cred_cred = '';  
	LET v_status_serv_elec = '';  
	LET v_status_serv_imp = '';   
	LET v_fecha_cancel_servicio = TODAY;
	LET cMtoVen = 0;	
	BEGIN
		ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET v_sCodRet = iSqlErr;
                RETURN v_sCodRet;
            END IF;
        END EXCEPTION;

		SELECT fecha_hoy
		  INTO v_fecha_hoy 
		  FROM bdinteg:si_fechas 
		 WHERE 1=1;
		
		FOREACH WITH HOLD
			SELECT a.numcte,a.cuenta,a.status_serv_elec,a.status_cred,b.status_cred, NVL(maes.monto_vencido + maes.mto_venc_trasp,0) 
			  INTO v_numcte, v_cuenta, v_status_serv_elec, v_status_cred_serv , v_status_cred_cred, cMtoVen
			  FROM bdiedoelec:edelec_alta_serv a, bdicred:sd_maecredcrd b, bdicred:sd_maecredanexocrd c, bdicred:"informix".sd_maesdoscrd maes
			 WHERE a.cuenta = b.num_credito
			   AND b.num_credito = maes.num_credito
			   AND a.producto = '6300'
			   AND c.num_credito = b.num_credito
			   AND c.empresa = pempresa
			   AND c.fecha_proceso = v_fecha_hoy


		IF v_status_cred_serv <> v_status_cred_cred AND v_status_serv_elec = 'A' THEN
		
			IF (v_status_cred_cred IN ('BA','BT','E1','E2','E3') AND cMtoVen > 0) THEN		--IF v_status_cred_cred IN ('BA','BT') THEN	--IFRS 
			
				LET v_status_serv_imp = 'A';
				LET v_fecha_cancel_servicio = NULL;
			
			END IF

			IF (v_status_cred_cred IN ('AA','E1') AND cMtoVen = 0 ) THEN	--IFRS 
		
				LET v_status_serv_elec = 'A';
				LET v_status_serv_imp = 'I';
				LET v_fecha_cancel_servicio = NULL;
				
			END IF			
			
			IF v_status_cred_cred NOT IN ('VP','AA','BA','BT','E1','E2','E3') THEN	--IFRS 
			
				LET v_status_serv_elec = 'I';
				LET v_status_serv_imp = 'I';
				LET v_fecha_cancel_servicio = TODAY;
			
			END IF
			
			UPDATE bdiedoelec:edelec_alta_serv 
			   SET status_serv_elec = v_status_serv_elec,
				   status_serv_imp = v_status_serv_imp,
				   status_cred = v_status_cred_cred,
				   fecha_ultima_mod = TODAY,
				   fecha_cancel_servicio = v_fecha_cancel_servicio,
				   tipo_modificacion = 'S',
				   user_modif = 'informix'
			 WHERE empresa = pempresa 
			   AND numcte = v_numcte 
			   AND cuenta = v_cuenta 
			   AND producto = '6300';
			 
		END IF
				
			CONTINUE FOREACH;
		END FOREACH;

		RETURN v_sCodRet;    

    END
END PROCEDURE;
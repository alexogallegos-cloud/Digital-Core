CREATE PROCEDURE "informix".sp_upd_status_cap(pempresa char(3) ) 
RETURNING CHAR(5) AS CodigoRetorno

    DEFINE iSqlErr              INTEGER;
    DEFINE v_sCodRet            CHAR(5);
	DEFINE v_valor 				SMALLINT;
	DEFINE v_fecha_hoy 			DATE;
	DEFINE v_numcte 			CHAR(20);
	DEFINE v_cuenta 			CHAR(20);
	DEFINE v_producto 			CHAR(4);
	DEFINE v_status_cta_serv   CHAR(1);
	DEFINE v_status_cta_cap   CHAR(1);
	DEFINE v_status_serv_elec   CHAR(1);
	DEFINE v_status_serv_imp    CHAR(1);
	DEFINE v_tipo_modificacion    CHAR(1);
	DEFINE v_fecha_cancel_servicio DATE;

	
	--SET DEBUG FILE TO  "sp_upd_status_cap.out"; 
    --TRACE ON;

	LET v_sCodRet = '000';
	LET v_valor = 0;
	LET v_fecha_hoy = TODAY;
	LET v_numcte = ''; 			
	LET v_cuenta = '';
	LET v_producto = '';	
	LET v_status_cta_serv = '';  
	LET v_status_cta_cap = '';  
	LET v_status_serv_elec = '';  
	LET v_status_serv_imp = '';   
	LET v_tipo_modificacion = ''; 
	LET v_fecha_cancel_servicio = TODAY;
	
	BEGIN
		ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET v_sCodRet = iSqlErr;
                RETURN v_sCodRet;
            END IF;
        END EXCEPTION;

		SELECT fecha_hoy - 1 UNITS DAY
		  INTO v_fecha_hoy 
		  FROM bdinteg:si_fechas 
		 WHERE 1=1;
		
		FOREACH WITH HOLD
			SELECT a.numcte,a.cuenta,a.producto,a.status_serv_elec,a.tipo_modificacion,a.status_cta,b.status_cta
			  INTO v_numcte, v_cuenta, v_producto ,v_status_serv_elec,v_tipo_modificacion, v_status_cta_serv , v_status_cta_cap
			  FROM bdiedoelec:edelec_alta_serv a, bdicheq:sc_maechq b, bdicheq:sc_maehis c
			 WHERE a.numcte = b.num_cte
			   AND a.numcte = b.num_cte
			   AND b.cuenta = a.cuenta
			   AND b.producto = a.producto
               AND c.empresa = pempresa
               AND c.cuenta = b.cuenta
               AND c.fechafin = v_fecha_hoy 
	
		IF v_status_cta_serv <> v_status_cta_cap AND (v_status_serv_elec = 'A' OR v_tipo_modificacion = 'S') THEN
		
			IF v_status_cta_cap IN ('1','3','4','5') THEN
				
				LET v_status_serv_elec = 'A';
				LET v_status_serv_imp = 'I';
				LET v_fecha_cancel_servicio = NULL;
				
			END IF
			
			
			IF v_status_cta_cap NOT IN ('1','3','4','5') THEN
			
				LET v_status_serv_elec = 'I';
				LET v_status_serv_imp = 'I';
				LET v_fecha_cancel_servicio = TODAY;
			
			END IF
			
			UPDATE bdiedoelec:edelec_alta_serv 
			   SET status_serv_elec = v_status_serv_elec,
				   status_serv_imp = v_status_serv_imp,
				   status_cta = v_status_cta_cap,
				   fecha_ultima_mod = TODAY,
				   fecha_cancel_servicio = v_fecha_cancel_servicio,
				   tipo_modificacion = 'S',
				   user_modif = 'informix'
			 WHERE empresa = pempresa 
			   AND numcte = v_numcte 
			   AND cuenta = v_cuenta 
			   AND producto = v_producto;
			 
		END IF
				
			CONTINUE FOREACH;
		END FOREACH;

		RETURN v_sCodRet;    

    END
END PROCEDURE;
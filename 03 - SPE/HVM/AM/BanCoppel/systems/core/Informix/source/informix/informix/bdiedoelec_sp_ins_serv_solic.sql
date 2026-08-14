CREATE PROCEDURE "informix".sp_ins_serv_solic (pempresa char(3) ) 
    RETURNING CHAR(5) AS CodigoRetorno

    DEFINE iSqlErr              INTEGER;
    DEFINE v_sCodRet            CHAR(5);
	DEFINE v_pass_second_part   CHAR (4);
	DEFINE encry_pass           VARCHAR(20);
	
	DEFINE v_fecha_hoy 			DATE;
	DEFINE v_fecha_cto 			DATE;
	DEFINE v_numcte 			CHAR(20);
	DEFINE v_cuenta 			CHAR(20);
	DEFINE v_producto 			CHAR(4);
	DEFINE v_fechafin           DATE;


--SET DEBUG FILE TO  "/DBA/JULIO/sp_ins_serv_solic.out"; 
--TRACE ON;
	
	LET v_sCodRet = '000';
	LET v_fecha_hoy = TODAY;
	LET v_fecha_cto = TODAY;
	LET v_numcte = ''; 			
	LET v_cuenta = '';
	LET v_producto = '';	
	LET v_fechafin = TODAY;

	
    BEGIN
        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET v_sCodRet = iSqlErr;
                RETURN v_sCodRet;
            END IF;
        END EXCEPTION;
		
		
		SELECT fecha_hoy - 2 UNITS DAY, fecha_hoy - 9 UNITS DAY
		  INTO v_fecha_hoy, v_fecha_cto
		  FROM bdinteg:si_fechas 
		 WHERE 1=1;
		 		
		FOREACH WITH HOLD -- Captación
			SELECT a.numcte,a.cuenta,a.producto, c.fechafin
			  INTO v_numcte, v_cuenta, v_producto,v_fechafin
			  FROM bdiedoelec:edelec_alta_serv a, bdicheq:sc_maechq b, bdicheq:sc_maehis_factelect c
			 WHERE a.numcte = b.num_cte
			   AND a.status_serv_elec = 'A'
			   AND b.cuenta = a.cuenta
			   --AND b.producto = a.producto
               AND c.empresa = pempresa
               AND c.cuenta = b.cuenta
               AND c.fechafin = v_fecha_hoy 
			   
			IF NOT EXISTS (SELECT cuenta FROM bdiedoelec:edelec_serv_solic 
							WHERE cuenta =  v_cuenta
							  AND fecha_corte = v_fechafin
							  AND producto = v_producto) THEN
			
				INSERT INTO "informix".edelec_serv_solic (empresa,numcte,cuenta,producto,fecha_corte,fecha_recepcion,fecha_vigencia)
											  VALUES (pempresa,v_numcte,v_cuenta,v_producto, v_fechafin, TODAY, TODAY + 20);
				
				INSERT INTO "informix".edelec_log_serv_solic (empresa,numcte,cuenta,producto,fecha_corte,status_envio_edocta,fecha_modificacion)
												  VALUES (pempresa, v_numcte, v_cuenta, v_producto, v_fechafin, 'SE', TODAY);
			END IF;
		CONTINUE FOREACH;
		END FOREACH;
		
		FOREACH WITH HOLD -- Crédito
			SELECT a.numcte,a.cuenta,a.producto, b.fecha_corte
				  INTO v_numcte, v_cuenta, v_producto,v_fechafin
				  --FROM bdiedoelec:edelec_alta_serv a, bdicred:sd_encabezado2_edocta b --Desarrollo
				  FROM bdiedoelec:edelec_alta_serv a, bdicred@pld_tcp:sd_encabezado2_edocta b  --Produccion
				 WHERE a.cuenta = b.num_credito
				   AND a.status_serv_elec = 'A'
				   AND b.fecha_emision = v_fecha_cto
				   AND b.num_credito = a.cuenta
			
			IF NOT EXISTS (SELECT cuenta FROM bdiedoelec:edelec_serv_solic 
							WHERE cuenta =  v_cuenta
							  AND fecha_corte = v_fechafin
							  AND producto = v_producto) THEN
			
				INSERT INTO "informix".edelec_serv_solic (empresa,numcte,cuenta,producto,fecha_corte,fecha_recepcion,fecha_vigencia)
												  VALUES (pempresa,v_numcte,v_cuenta,v_producto, v_fechafin, TODAY, TODAY + 20);
				
				INSERT INTO "informix".edelec_log_serv_solic (empresa,numcte,cuenta,producto,fecha_corte,status_envio_edocta,fecha_modificacion)
													  VALUES (pempresa, v_numcte, v_cuenta, v_producto, v_fechafin, 'SE', TODAY);
			END IF;
			
			CONTINUE FOREACH;
		END FOREACH;
		
		FOREACH WITH HOLD -- Préstamo Personal Y Reestructuras
			SELECT a.numcte,a.cuenta,a.producto, b.fecha_emision
				  INTO v_numcte, v_cuenta, v_producto,v_fechafin
				  FROM bdiedoelec:edelec_alta_serv a, bdicred:sd_encabezado2_edoctacrd b 
				 WHERE a.cuenta = b.num_credito
				   AND a.status_serv_elec = 'A'
				   AND b.fecha_emision = v_fecha_hoy
				   AND b.num_credito = a.cuenta
				   
				   
			IF NOT EXISTS (SELECT cuenta FROM bdiedoelec:edelec_serv_solic 
					WHERE cuenta =  v_cuenta
						AND fecha_corte = v_fechafin
						AND producto = v_producto) THEN
			
				INSERT INTO "informix".edelec_serv_solic (empresa,numcte,cuenta,producto,fecha_corte,fecha_recepcion,fecha_vigencia)
											  VALUES (pempresa,v_numcte,v_cuenta,v_producto, v_fechafin, TODAY, TODAY + 31);
			
				INSERT INTO "informix".edelec_log_serv_solic (empresa,numcte,cuenta,producto,fecha_corte,status_envio_edocta,fecha_modificacion)
												  VALUES (pempresa, v_numcte, v_cuenta, v_producto, v_fechafin, 'SE', TODAY);
			END IF;
			CONTINUE FOREACH;
		END FOREACH;

		RETURN v_sCodRet;    

    END
END PROCEDURE;
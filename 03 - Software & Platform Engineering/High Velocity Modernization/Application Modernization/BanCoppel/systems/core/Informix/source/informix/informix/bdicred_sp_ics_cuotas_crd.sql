CREATE PROCEDURE "informix".sp_ics_cuotas_crd(p_num_ejecucion INTEGER)

	RETURNING
		CHAR(5)							AS cod_ret;


	--Variables de Control y Retorno de errores--
		DEFINE sql_err 						INTEGER;
		DEFINE v_cod_ret 					CHAR(5);
	
	--Variables interfaz
	
		DEFINE v_customer_id								VARCHAR(10);
		DEFINE v_identity_code                            	VARCHAR(13);
		DEFINE v_acc_customer_id                          	VARCHAR(20);
		DEFINE v_product_id                               	VARCHAR(20);			
		DEFINE v_account_number         	            	VARCHAR(20);
		DEFINE v_age                                    	INTEGER;
		DEFINE v_delinquency                            	DECIMAL(15,2);
		DEFINE v_paid_delinquency                       	DECIMAL(15,2);
		DEFINE v_principal_delinquency                  	DECIMAL(15,2);
		DEFINE v_paid_principal_delinquency                 DECIMAL(15,2);
		DEFINE v_interest_delinquent                    	DECIMAL(15,2);
		DEFINE v_paid_interest_delinquent               	DECIMAL(15,2);
		DEFINE v_comission                             		DECIMAL(15,2);
		DEFINE v_paid_comission                        		DECIMAL(15,2);
		DEFINE v_insurance_desg                         	DECIMAL(15,2);
		DEFINE v_paid_insurance_desg                    	DECIMAL(15,2);
		DEFINE v_insurance_fire                         	DECIMAL(15,2);
		DEFINE v_paid_insurance_fire                    	DECIMAL(15,2);
		DEFINE v_other_reasons                         		DECIMAL(15,2);
		DEFINE v_paid_other_reasons                    		DECIMAL(15,2);
		DEFINE v_update_date                            	DATE;
		DEFINE v_due_date                               	DATE;
		DEFINE v_last_entrance_date                     	DATE;
		DEFINE v_state_cause_id                         	VARCHAR(20);
		DEFINE v_quote_status                           	VARCHAR(20);
		DEFINE v_last_payment_date                      	DATE;
		DEFINE v_reviewed                               	CHAR(1);
		DEFINE v_return_id                              	VARCHAR(80);
		DEFINE v_entrance_date                          	DATE;
		DEFINE v_entrance_date_char							CHAR(10);
		DEFINE v_wite_off_date                          	VARCHAR(10);
		DEFINE c_fecha_ejecucion							DATE;
		DEFINE v_activo					                  	DECIMAL(15,2);
		DEFINE v_fecha1										DATE;
		DEFINE v_fecha2										DATE;
		DEFINE v_num_cliente								VARCHAR(20);
		DEFINE v_capital_pagado								DECIMAL(15,2);
		DEFINE v_capital_debe								DECIMAL(15,2);
		DEFINE v_interes_debe								DECIMAL(15,2);
		DEFINE v_condicion_adeudo							DECIMAL(15,2);
		DEFINE fecha_inicio									DATE;
		DEFINE v_update_date_char 							CHAR(10);	
		DEFINE v_due_date_char 								CHAR(10);
		DEFINE v_last_entrance_date_char					CHAR(10);	
		DEFINE v_last_payment_date_char 					CHAR(10);	
		DEFINE v_valor_inicial 								INT8;
		DEFINE v_valor_final                                INT8;
		DEFINE v_contados_cuotas							INTEGER;

		--Controles
		DEFINE horaActual									DATETIME YEAR TO FRACTION(5);
		DEFINE iContador1 									INTEGER;
		DEFINE iContador									INTEGER;
		DEFINE v_capital_status								CHAR(2);
  
		DEFINE v_capital_debe_2             DECIMAL(18,2);
		DEFINE v_interes_debe_2               DECIMAL(18,2);
		DEFINE v_iva_debe                   DECIMAL(18,2);
		DEFINE v_interes_mora               DECIMAL(18,2);
		DEFINE v_iva_interes_mora           DECIMAL(18,2);
		DEFINE  v_num_pago					INTEGER;
		DEFINE cSucursal 					CHAR(4);
		DEFINE dIvaSuc 						DECIMAL(5,3); 
		DEFINE v_transaccion				INTEGER;
		DEFINE v_proceso 					VARCHAR(50);
		
  --------Iniciar las nuevas variables
		LET v_capital_debe_2     = 0.0;
		LET v_interes_debe_2       = 0.0;
		LET v_iva_debe           = 0.0;
		LET v_interes_mora       = 0.0;
		LET v_iva_interes_mora   = 0.0;
		LET v_num_pago			 = NULL;
		LET cSucursal			 = NULL;
		LET dIvaSuc				 = 0.16;
  
  
		--Inicializamos las variables
		LET v_customer_id									='BANCOPPEL';
		LET v_identity_code                			   		= NULL;
		LET v_acc_customer_id              			   		= NULL;
		LET v_product_id                   			   		= NULL;		
		LET v_account_number         				   		= NULL;
		LET v_age                        			   		= 0;
		LET v_delinquency                			   		= 0.0;
		LET v_paid_delinquency           			   		= 0.0;
		LET v_principal_delinquency      			   		= 0.0;
		LET v_paid_principal_delinquency 			   		= 0.0;
		LET v_interest_delinquent        			   		= 0.0;
		LET v_paid_interest_delinquent   			   		= 0.0;
		LET v_comission                 			   		= 0.0;
		LET v_paid_comission            			   		= 0.0;
		LET v_insurance_desg             			   		= 0.0;
		LET v_paid_insurance_desg        			   		= 0.0;
		LET v_insurance_fire             			   		= 0.0;
		LET v_paid_insurance_fire        			   		= 0.0;
		LET v_other_reasons             			   		= 0.0;
		LET v_paid_other_reasons       			   			= 0.0;
		LET v_update_date                			   		= NULL;
		LET v_due_date                   			   		= NULL;
		LET v_last_entrance_date         			   		= NULL;
		LET v_state_cause_id             			   		= 'UPDATE';
		LET v_quote_status               			   		= NULL;
		LET v_last_payment_date          			   		= NULL;
		LET v_reviewed                   			   		= 'N';
		LET v_return_id                  			   		= NULL;
		LET v_entrance_date              			   		= NULL;
		LET v_wite_off_date              			   		= '1900/01/01';
		LET c_fecha_ejecucion								= NULL;
		LET v_activo										= 0.0;
		LET v_fecha1										= NULL;
		LET v_fecha2										= NULL;
		LET v_capital_pagado	                            = 0.0;
		LET v_capital_debe	                                = 0.0;
		LET v_interes_debe	                                = 0.0;
													      
		LET horaActual										= NULL;
		LET iContador1 										= 0;
		LET iContador										= 0;
		
		LET v_cod_ret										= '00000';
		
		LET v_num_cliente									= NULL;
		
		LET v_condicion_adeudo								= 0.0;
		
		LET fecha_inicio									= NULL;
		LET v_update_date_char 								= NULL;
		LET v_due_date_char 								= NULL;
		LET v_last_entrance_date_char 						= NULL;
		LET v_last_payment_date_char 						= NULL;
		LET v_valor_inicial									= 0;
        LET v_valor_final                                   = 0;
		LET v_entrance_date_char							= NULL;
		LET v_capital_status								= NULL;
		LET v_contados_cuotas 								= NULL;
		LET v_transaccion									= 0;
		LET v_proceso 										='';
	--SET DEBUG FILE TO "/resplogifx/info_ics/pbas_iniciales/cuotas_V1";
    --TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	BEGIN
	
		ON EXCEPTION SET sql_err
		
				INSERT INTO "informix".ics_control_errores(num_credito, numcte, num_producto, descripcion_error, proceso, fecha_insert)
				VALUES(v_account_number, v_num_cliente, v_acc_customer_id, sql_err, v_proceso, CURRENT);
			
			IF v_transaccion = 1 Then
				COMMIT WORK;
			End IF
			
			IF sql_err <> 0 THEN
				LET v_cod_ret = sql_err;
				RETURN v_cod_ret;
		    END IF;
		END EXCEPTION;
		ON EXCEPTION IN (-535)
			  --ROLLBACK WORK;
			  --COMMIT WORK;

			  --BEGIN WORK;
			  LET v_transaccion = 1;
			  INSERT INTO "informix".ics_control_errores(num_credito, numcte, num_producto,descripcion_error, proceso, fecha_insert)
			  VALUES( v_account_number, v_num_cliente, v_acc_customer_id, 'ERROR -535 Coutas CRD',v_proceso, CURRENT);
			    COMMIT WORK;
				BEGIN WORK;

		 END EXCEPTION WITH RESUME;
		
		--SELECT fecha_hoy 
		--	INTO c_fecha_ejecucion
		--FROM bdinteg:si_fechas;
		

		SELECT DBINFO("utc_to_datetime", sh_curtime) 
			INTO horaActual 
		FROM sysmaster:sysshmvals;
		INSERT INTO ics_tiempos (num_registro, hora, proceso) VALUES (iContador1, horaActual, 'IN_CICLO_CUOTAS_CRD');

---------------------------
		BEGIN WORK;
		
			LET v_transaccion = 1;
			LET v_proceso = 'Creditos No Revolventes Cuotas';
		
			SELECT valor_inicial, valor_final, fecha_ejecucion
					INTO v_valor_inicial, v_valor_final, c_fecha_ejecucion
			FROM ics_numero_proceso 
			WHERE numero_hilo = p_num_ejecucion and tipo_cred = '2';
			
			FOREACH WITH HOLD
			SELECT 
				mc.numcte, mc.num_producto, mc.num_credito, mc.rfc, mc.sucursal
			INTO
				v_num_cliente, v_acc_customer_id, v_account_number, v_identity_code, cSucursal
			FROM ics_clientes mc 
			WHERE mc.tipo_cred = '2' AND num_credito BETWEEN v_valor_inicial AND v_valor_final

			/*SELECT rfc
				INTO v_identity_code
			FROM bdinteg:si_cliente 
				WHERE numcte = v_num_cliente;
				
			SELECT num_producto
				INTO v_product_id
			FROM sd_definicion
			WHERE num_producto = v_acc_customer_id;*/
			LET v_product_id = v_acc_customer_id;
			
			IF v_acc_customer_id IN ('6001','6011','6500','6600','6900','7000','7200','7500','8100','8500') THEN
				LET v_acc_customer_id = 'TARJETA DE CREDITO';
			END IF;
			
			IF v_acc_customer_id IN ('6300','6800','7300','7600','7700','8600','9100','9300') THEN
				LET v_acc_customer_id = 'PRESTAMO PERSONAL';
			END IF;
			
			IF v_acc_customer_id IN ('6400','7400','7800') THEN
				LET v_acc_customer_id = 'NOMINA';
			END IF;

			/*SELECT delinquency
				INTO v_delinquency
			FROM bdicred:ics_obligacion
				WHERE account_number = v_account_number; */ -- SE obtiene el delinquenci directamente por couta
			
			SELECT dias_acum_mora 
				INTO v_age
			FROM sd_maesdoscrd 
			WHERE num_credito= v_account_number;
			
						SELECT fecha_ultimo_pago 
							INTO v_last_payment_date
						FROM sd_indicador_cred
							WHERE num_credito = v_account_number;
				
			SELECT MIN(fecha_cuota)
				INTO fecha_inicio
			FROM sd_amortiza_creditocrd 
			WHERE num_credito = v_account_number	AND capital_status in (2,6,7) ;
			
				IF	fecha_inicio IS NOT NULL THEN
	
					FOREACH WITH HOLD
					
					--Paid delinquency
					
						SELECT capital_pagado, interes_pagado, capital_debe, interes_debe, fecha_cuota, capital_status, num_pago
							INTO v_capital_pagado, v_paid_principal_delinquency, v_capital_debe, v_interes_debe, v_due_date, v_capital_status, v_num_pago
						FROM sd_amortiza_creditocrd 
						WHERE num_credito = v_account_number 
							AND capital_status in (2,6,7)  AND fecha_cuota between fecha_inicio and add_months(c_fecha_ejecucion, 1)
							
						LET v_paid_interest_delinquent = v_paid_principal_delinquency;
						LET v_principal_delinquency = v_capital_debe - v_capital_pagado ; --ajustado
						LET v_paid_delinquency = v_capital_pagado + v_paid_principal_delinquency;
						LET v_interest_delinquent = v_interes_debe - v_paid_principal_delinquency; --ajustado
						LET v_update_date = c_fecha_ejecucion;
						LET v_last_entrance_date = c_fecha_ejecucion;
						LET v_state_cause_id = 'UPDATE';
						LET v_condicion_adeudo = v_capital_debe - v_capital_pagado;
						
					
						SELECT MAX(capital_fecha_pago), MAX(interes_fecha_pago)
							INTO v_fecha1, v_fecha2
						FROM sd_amortiza_creditocrd
						WHERE num_credito = v_account_number 
							AND capital_status in (2,6,7);
		
					
							IF v_fecha1 IS NOT NULL AND v_fecha2 IS NOT NULL THEN
								
								IF  v_fecha1 > v_fecha2	THEN
									LET v_entrance_date = v_fecha1;
								ELSE
									LET v_entrance_date = v_fecha2;
								END IF;
							
							ELSE
								LET v_entrance_date = c_fecha_ejecucion;
							END IF;
				--	
						--Last_payment_date
						/*SELECT fecha_ultimo_pago 
							INTO v_last_payment_date
						FROM sd_indicador_cred
							WHERE num_credito = v_account_number;*/
					
						LET v_quote_status = 'ACTIVE';
						LET v_update_date_char = TO_CHAR(v_update_date,'%d/%m/%Y');
						LET v_due_date_char = TO_CHAR(v_due_date,'%d/%m/%Y');
						LET v_last_entrance_date_char = TO_CHAR(v_last_entrance_date,'%d/%m/%Y');
						LET v_last_payment_date_char = TO_CHAR(v_last_payment_date,'%d/%m/%Y');
						LET v_entrance_date_char = TO_CHAR(v_entrance_date,'%d/%m/%Y');
						
						
						--Se obtiene la sucursal
						/*SELECT sucursal 
							INTO cSucursal
						FROM sd_maecredcrd 
						WHERE num_credito = v_account_number;
						
						SELECT iva
							INTO dIvaSuc
						FROM bdinteg:"informix".si_sucursales
						WHERE sucursal = cSucursal AND empresa  = '001';*/
						
							----SE modifica para obtener la sumatoria de la variable delinquency
						SELECT --a.num_credito,
						sum(capital_debe - capital_pagado) capital_debe,
						sum(interes_debe - interes_pagado) interes_debe, 
						sum(iva_debe - iva_pagado) iva_debe,
						sum((NVL(mora_provi_ordi,0) + NVL(mora_provi_cope,0) + NVL(mora_sdo_ordi,0) - NVL(mora_sdo_ordi_pag,0) + NVL(mora_sdo_cope,0) - NVL(mora_sdo_cope_pag,0))) interes_mora
						--sum(((NVL(mora_provi_ordi,0) + NVL(mora_provi_cope,0) + NVL(mora_sdo_ordi,0) - NVL(mora_sdo_ordi_pag,0) + NVL(mora_sdo_cope,0) - NVL(mora_sdo_cope_pag,0)) * 0.16 )) v_iva_interes_mora
							INTO v_capital_debe_2, v_interes_debe_2, v_iva_debe, v_interes_mora--, v_v_iva_interes_mora
						FROM sd_amortiza_creditocrd a
						WHERE a.empresa   = '001'
							AND a.num_credito = v_account_number
						AND capital_status= v_capital_status AND fecha_cuota = v_due_date and num_pago = v_num_pago;
					    --
						LET v_iva_interes_mora = (v_interes_mora * dIvaSuc);
					
					--Delinquency
						LET v_delinquency = v_capital_debe_2 + v_interes_debe_2 + v_iva_debe + v_interes_mora + v_iva_interes_mora;					
				
							IF v_condicion_adeudo > 0 THEN 
							
								INSERT INTO ics_cuotas
									(customer_id, identity_code, acc_customer_id, product_id, account_number, age, delinquency, paid_delinquency, principal_delinquency,			
									paid_principal_delinquency, interest_delinquent, paid_interest_delinquent, comission, paid_comission, insurance_deg, paid_insurance_deg,				
									insurance_fire, paid_insurance_fire, other_reasons, paid_other_reasons, update_date, due_date, last_entrance_date, state_cause_id, quote_status,					
									last_payment_date, reviewed, return_id, entrance_date, wite_off_date, fecha_ejecucion, capital_status)
								VALUES
									(v_customer_id, v_identity_code, v_acc_customer_id, v_product_id, v_account_number, v_age, v_delinquency, v_paid_delinquency, v_principal_delinquency,			
									v_paid_principal_delinquency, v_interest_delinquent, v_paid_interest_delinquent, v_comission, v_paid_comission, v_insurance_desg, v_paid_insurance_desg,				
									v_insurance_fire, v_paid_insurance_fire, v_other_reasons, v_paid_other_reasons, v_update_date_char, v_due_date_char, v_last_entrance_date_char, v_state_cause_id, v_quote_status,					
									v_last_payment_date_char, v_reviewed, v_return_id, v_entrance_date_char, v_wite_off_date, c_fecha_ejecucion, v_capital_status);
							END IF;
					END FOREACH;	
				END IF;
			
			--Se aÃ±ade para los estatus 1
			
			--Se aÃ±ade condicion para que tome solo las cuotas con capital estatus 1 y se tenga una cuota minima registrada por cada obligacion
			SELECT distinct(fecha_cuota)
				INTO fecha_inicio
			FROM sd_amortiza_creditocrd 
			WHERE num_credito = v_account_number
			AND capital_status = 1
			AND fecha_cuota between c_fecha_ejecucion and add_months(c_fecha_ejecucion, 1);
					
				IF fecha_inicio IS NOT NULL THEN
					
					FOREACH WITH HOLD
					
						SELECT capital_pagado, interes_pagado, capital_debe, interes_debe, fecha_cuota, capital_status, num_pago
							INTO v_capital_pagado, v_paid_principal_delinquency, v_capital_debe, v_interes_debe, v_due_date, v_capital_status, v_num_pago
						FROM sd_amortiza_creditocrd 
						WHERE num_credito = v_account_number 
						AND capital_status = 1  AND fecha_cuota between fecha_inicio and add_months(c_fecha_ejecucion, 1)
							
						LET v_paid_interest_delinquent = v_paid_principal_delinquency;
						LET v_principal_delinquency = v_capital_debe - v_capital_pagado ; --ajustado
						LET v_paid_delinquency = v_capital_pagado + v_paid_principal_delinquency;
						LET v_interest_delinquent = v_interes_debe - v_paid_principal_delinquency; --ajustado
						LET v_update_date = c_fecha_ejecucion;
						LET v_last_entrance_date = c_fecha_ejecucion;
						LET v_state_cause_id = 'UPDATE';
						LET v_condicion_adeudo = v_capital_debe - v_capital_pagado;
						
						SELECT MAX(capital_fecha_pago), MAX(interes_fecha_pago)
							INTO v_fecha1, v_fecha2
						FROM sd_amortiza_creditocrd
						WHERE num_credito = v_account_number 
							AND capital_status = 1;
								
							
						IF v_fecha1 IS NOT NULL AND v_fecha2 IS NOT NULL THEN
							
							IF  v_fecha1 > v_fecha2	THEN
								LET v_entrance_date = v_fecha1;
							ELSE
								LET v_entrance_date = v_fecha2;
							END IF;
						
						ELSE
							LET v_entrance_date = c_fecha_ejecucion;
						END IF;
							
						--Last_payment_date
					/*	SELECT fecha_ultimo_pago 
							INTO v_last_payment_date
						FROM sd_indicador_cred
							WHERE num_credito = v_account_number;*/
						
						LET v_quote_status = 'ACTIVE';
						LET v_update_date_char = TO_CHAR(v_update_date,'%d/%m/%Y');
						LET v_due_date_char = TO_CHAR(v_due_date,'%d/%m/%Y');
						LET v_last_entrance_date_char = TO_CHAR(v_last_entrance_date,'%d/%m/%Y');
						LET v_last_payment_date_char = TO_CHAR(v_last_payment_date,'%d/%m/%Y');
						LET v_entrance_date_char = TO_CHAR(v_entrance_date,'%d/%m/%Y');
						
						--Se obtiene la sucursal
						/*SELECT sucursal 
							INTO cSucursal
						FROM sd_maecredcrd 
						WHERE num_credito = v_account_number;
						
						SELECT iva
							INTO dIvaSuc
						FROM bdinteg:"informix".si_sucursales
						WHERE sucursal = cSucursal AND empresa  = '001';*/
						
							----SE modifica para obtener la sumatoria de la variable delinquency
						SELECT --a.num_credito,
						sum(capital_debe - capital_pagado) capital_debe,
						sum(interes_debe - interes_pagado) interes_debe, 
						sum(iva_debe - iva_pagado) iva_debe,
						sum((NVL(mora_provi_ordi,0) + NVL(mora_provi_cope,0) + NVL(mora_sdo_ordi,0) - NVL(mora_sdo_ordi_pag,0) + NVL(mora_sdo_cope,0) - NVL(mora_sdo_cope_pag,0))) interes_mora
						--sum(((NVL(mora_provi_ordi,0) + NVL(mora_provi_cope,0) + NVL(mora_sdo_ordi,0) - NVL(mora_sdo_ordi_pag,0) + NVL(mora_sdo_cope,0) - NVL(mora_sdo_cope_pag,0)) * 0.16 )) v_iva_interes_mora
							INTO v_capital_debe_2, v_interes_debe_2, v_iva_debe, v_interes_mora--, v_v_iva_interes_mora
						FROM sd_amortiza_creditocrd a
						WHERE a.empresa   = '001'
							AND a.num_credito = v_account_number
						AND capital_status= v_capital_status AND fecha_cuota = v_due_date and num_pago = v_num_pago;
					    --
						LET v_iva_interes_mora = (v_interes_mora * dIvaSuc);
					
					--Delinquency
						LET v_delinquency = v_capital_debe_2 + v_interes_debe_2 + v_iva_debe + v_interes_mora + v_iva_interes_mora;
						
						INSERT INTO ics_cuotas
							(customer_id, identity_code, acc_customer_id, product_id, account_number, age, delinquency, paid_delinquency, principal_delinquency,			
							paid_principal_delinquency, interest_delinquent, paid_interest_delinquent, comission, paid_comission, insurance_deg, paid_insurance_deg,				
							insurance_fire, paid_insurance_fire, other_reasons, paid_other_reasons, update_date, due_date, last_entrance_date, state_cause_id, quote_status,					
							last_payment_date, reviewed, return_id, entrance_date, wite_off_date, fecha_ejecucion, capital_status)
						VALUES
							(v_customer_id, v_identity_code, v_acc_customer_id, v_product_id, v_account_number, v_age, v_delinquency, v_paid_delinquency, v_principal_delinquency,			
							v_paid_principal_delinquency, v_interest_delinquent, v_paid_interest_delinquent, v_comission, v_paid_comission, v_insurance_desg, v_paid_insurance_desg,				
							v_insurance_fire, v_paid_insurance_fire, v_other_reasons, v_paid_other_reasons, v_update_date_char, v_due_date_char, v_last_entrance_date_char, v_state_cause_id, v_quote_status,					
							v_last_payment_date_char, v_reviewed, v_return_id, v_entrance_date_char, v_wite_off_date, c_fecha_ejecucion, v_capital_status);
					
					END FOREACH;
					
				END IF;
			
			--Se aÃ±ade contador
			SELECT COUNT(*) INTO v_contados_cuotas FROM ics_cuotas WHERE account_number = v_account_number;
			
			--Se aÃ±ade condicion para que tome solo las cuotas con capital estatus 5 y se tenga una cuota minima registrada por cada obligacion
			IF v_contados_cuotas = 0 OR v_contados_cuotas IS NULL OR v_contados_cuotas = '' THEN
				
				SELECT MAX(fecha_cuota)
					INTO fecha_inicio
				FROM sd_amortiza_creditocrd 
				WHERE num_credito = v_account_number
				AND capital_status in (5) AND fecha_cuota <= add_months(c_fecha_ejecucion, 1);
				
					IF fecha_inicio IS NOT NULL THEN 
						
						FOREACH WITH HOLD
							SELECT capital_pagado, interes_pagado, capital_debe, interes_debe, fecha_cuota, capital_status
								INTO v_capital_pagado, v_paid_principal_delinquency, v_capital_debe, v_interes_debe, v_due_date, v_capital_status
							FROM sd_amortiza_creditocrd 
							WHERE num_credito = v_account_number 
							AND capital_status in (5)  AND fecha_cuota between fecha_inicio and add_months(c_fecha_ejecucion, 1)
									
							LET v_paid_interest_delinquent = v_paid_principal_delinquency;
							LET v_principal_delinquency = v_capital_debe - v_capital_pagado ; --ajustado
							LET v_paid_delinquency = v_capital_pagado + v_paid_principal_delinquency;
							LET v_interest_delinquent = v_interes_debe - v_paid_principal_delinquency; --ajustado
							LET v_update_date = c_fecha_ejecucion;
							LET v_last_entrance_date = c_fecha_ejecucion;
							LET v_state_cause_id = 'UPDATE';
							LET v_condicion_adeudo = v_capital_debe - v_capital_pagado;
							
							SELECT MAX(capital_fecha_pago), MAX(interes_fecha_pago)
								INTO v_fecha1, v_fecha2
							FROM sd_amortiza_creditocrd
							WHERE num_credito = v_account_number 
								AND capital_status in (5);
									
								
								IF v_fecha1 IS NOT NULL AND v_fecha2 IS NOT NULL THEN
									
									IF  v_fecha1 > v_fecha2	THEN
										LET v_entrance_date = v_fecha1;
									ELSE
										LET v_entrance_date = v_fecha2;
									END IF;
								
								ELSE
									LET v_entrance_date = c_fecha_ejecucion;
								END IF;
								
--							Last_payment_date
							/*SELECT fecha_ultimo_pago 
								INTO v_last_payment_date
							FROM sd_indicador_cred
								WHERE num_credito = v_account_number;*/
							
							LET v_quote_status = 'ACTIVE';
							LET v_update_date_char = TO_CHAR(v_update_date,'%d/%m/%Y');
							LET v_due_date_char = TO_CHAR(v_due_date,'%d/%m/%Y');
							LET v_last_entrance_date_char = TO_CHAR(v_last_entrance_date,'%d/%m/%Y');
							LET v_last_payment_date_char = TO_CHAR(v_last_payment_date,'%d/%m/%Y');
							LET v_entrance_date_char = TO_CHAR(v_entrance_date,'%d/%m/%Y');
								
								LET v_delinquency = '0';
								
							INSERT INTO ics_cuotas
								(customer_id, identity_code, acc_customer_id, product_id, account_number, age, delinquency, paid_delinquency, principal_delinquency,			
								paid_principal_delinquency, interest_delinquent, paid_interest_delinquent, comission, paid_comission, insurance_deg, paid_insurance_deg,				
								insurance_fire, paid_insurance_fire, other_reasons, paid_other_reasons, update_date, due_date, last_entrance_date, state_cause_id, quote_status,					
								last_payment_date, reviewed, return_id, entrance_date, wite_off_date, fecha_ejecucion, capital_status)
							VALUES
								(v_customer_id, v_identity_code, v_acc_customer_id, v_product_id, v_account_number, v_age, v_delinquency, v_paid_delinquency, v_principal_delinquency,			
								v_paid_principal_delinquency, v_interest_delinquent, v_paid_interest_delinquent, v_comission, v_paid_comission, v_insurance_desg, v_paid_insurance_desg,				
								v_insurance_fire, v_paid_insurance_fire, v_other_reasons, v_paid_other_reasons, v_update_date_char, v_due_date_char, v_last_entrance_date_char, v_state_cause_id, v_quote_status,					
								v_last_payment_date_char, v_reviewed, v_return_id, v_entrance_date_char, v_wite_off_date, c_fecha_ejecucion, v_capital_status);
						END FOREACH;
					END IF;
			END IF;

			
			
			--Se aÃ±ade contador
			SELECT COUNT(*) INTO v_contados_cuotas FROM ics_cuotas WHERE account_number = v_account_number;
			
			--Se aÃ±ade condicion para que tome solo las cuotas con capital estatus 3 y se tenga una cuota minima registrada por cada obligacion
			IF v_contados_cuotas = 0 OR v_contados_cuotas IS NULL OR v_contados_cuotas = '' THEN
				
				SELECT MAX(fecha_cuota)
					INTO fecha_inicio
				FROM sd_amortiza_creditocrd 
				WHERE num_credito = v_account_number
				AND capital_status in (3) AND fecha_cuota <= add_months(c_fecha_ejecucion, 1);
				
					IF fecha_inicio IS NOT NULL THEN 
						
						FOREACH WITH HOLD
							SELECT capital_pagado, interes_pagado, capital_debe, interes_debe, fecha_cuota, capital_status
								INTO v_capital_pagado, v_paid_principal_delinquency, v_capital_debe, v_interes_debe, v_due_date, v_capital_status
							FROM sd_amortiza_creditocrd 
							WHERE num_credito = v_account_number 
							AND capital_status in (3)  AND fecha_cuota between fecha_inicio and add_months(c_fecha_ejecucion, 1)
									
							LET v_paid_interest_delinquent = v_paid_principal_delinquency;
							LET v_principal_delinquency = v_capital_debe - v_capital_pagado ; --ajustado
							LET v_paid_delinquency = v_capital_pagado + v_paid_principal_delinquency;
							LET v_interest_delinquent = v_interes_debe - v_paid_principal_delinquency; --ajustado
							LET v_update_date = c_fecha_ejecucion;
							LET v_last_entrance_date = c_fecha_ejecucion;
							LET v_state_cause_id = 'UPDATE';
							LET v_condicion_adeudo = v_capital_debe - v_capital_pagado;
							
							SELECT MAX(capital_fecha_pago), MAX(interes_fecha_pago)
								INTO v_fecha1, v_fecha2
							FROM sd_amortiza_creditocrd
							WHERE num_credito = v_account_number 
								AND capital_status in (3);
									
								
								IF v_fecha1 IS NOT NULL AND v_fecha2 IS NOT NULL THEN
									
									IF  v_fecha1 > v_fecha2	THEN
										LET v_entrance_date = v_fecha1;
									ELSE
										LET v_entrance_date = v_fecha2;
									END IF;
								
								ELSE
									LET v_entrance_date = c_fecha_ejecucion;
								END IF;
								
--							Last_payment_date
							/*SELECT fecha_ultimo_pago 
								INTO v_last_payment_date
							FROM sd_indicador_cred
								WHERE num_credito = v_account_number;*/
							
							LET v_quote_status = 'ACTIVE';
							LET v_update_date_char = TO_CHAR(v_update_date,'%d/%m/%Y');
							LET v_due_date_char = TO_CHAR(v_due_date,'%d/%m/%Y');
							LET v_last_entrance_date_char = TO_CHAR(v_last_entrance_date,'%d/%m/%Y');
							LET v_last_payment_date_char = TO_CHAR(v_last_payment_date,'%d/%m/%Y');
							LET v_entrance_date_char = TO_CHAR(v_entrance_date,'%d/%m/%Y');
								LET v_delinquency = '0';
							INSERT INTO ics_cuotas
								(customer_id, identity_code, acc_customer_id, product_id, account_number, age, delinquency, paid_delinquency, principal_delinquency,			
								paid_principal_delinquency, interest_delinquent, paid_interest_delinquent, comission, paid_comission, insurance_deg, paid_insurance_deg,				
								insurance_fire, paid_insurance_fire, other_reasons, paid_other_reasons, update_date, due_date, last_entrance_date, state_cause_id, quote_status,					
								last_payment_date, reviewed, return_id, entrance_date, wite_off_date, fecha_ejecucion, capital_status)
							VALUES
								(v_customer_id, v_identity_code, v_acc_customer_id, v_product_id, v_account_number, v_age, v_delinquency, v_paid_delinquency, v_principal_delinquency,			
								v_paid_principal_delinquency, v_interest_delinquent, v_paid_interest_delinquent, v_comission, v_paid_comission, v_insurance_desg, v_paid_insurance_desg,				
								v_insurance_fire, v_paid_insurance_fire, v_other_reasons, v_paid_other_reasons, v_update_date_char, v_due_date_char, v_last_entrance_date_char, v_state_cause_id, v_quote_status,					
								v_last_payment_date_char, v_reviewed, v_return_id, v_entrance_date_char, v_wite_off_date, c_fecha_ejecucion, v_capital_status);
						END FOREACH;
					END IF;
			END IF;
			
			
						
				--Se aÃ±ade contador
			SELECT COUNT(*) INTO v_contados_cuotas FROM ics_cuotas WHERE account_number = v_account_number;
			
			--Se aÃ±ade condicion para que tome solo las cuotas con capital estatus 3 y se tenga una cuota minima registrada por cada obligacion
			IF v_contados_cuotas = 0 OR v_contados_cuotas IS NULL OR v_contados_cuotas = '' THEN
			---=============*********** Se agrega en las validaciones la tablas sd_amortiza_creditocrd_apoyo2021 
				SELECT MIN(fecha_cuota)
					INTO fecha_inicio
				FROM sd_amortiza_creditocrd_apoyo2021 
				WHERE num_credito = v_account_number	AND capital_status in (2,6,7) ;
				
					IF	fecha_inicio IS NOT NULL THEN
		
						FOREACH WITH HOLD
						
						--Paid delinquency
						
							SELECT capital_pagado, interes_pagado, capital_debe, interes_debe, fecha_cuota, capital_status, num_pago
								INTO v_capital_pagado, v_paid_principal_delinquency, v_capital_debe, v_interes_debe, v_due_date, v_capital_status, v_num_pago
							FROM sd_amortiza_creditocrd_apoyo2021 
							WHERE num_credito = v_account_number 
								AND capital_status in (2,6,7)  AND fecha_cuota between fecha_inicio and add_months(c_fecha_ejecucion, 1)
								
							LET v_paid_interest_delinquent = v_paid_principal_delinquency;
							LET v_principal_delinquency = v_capital_debe - v_capital_pagado ; --ajustado
							LET v_paid_delinquency = v_capital_pagado + v_paid_principal_delinquency;
							LET v_interest_delinquent = v_interes_debe - v_paid_principal_delinquency; --ajustado
							LET v_update_date = c_fecha_ejecucion;
							LET v_last_entrance_date = c_fecha_ejecucion;
							LET v_state_cause_id = 'UPDATE';
							LET v_condicion_adeudo = v_capital_debe - v_capital_pagado;
							
						
							SELECT MAX(capital_fecha_pago), MAX(interes_fecha_pago)
								INTO v_fecha1, v_fecha2
							FROM sd_amortiza_creditocrd_apoyo2021
							WHERE num_credito = v_account_number 
								AND capital_status in (2,6,7);
			
						
								IF v_fecha1 IS NOT NULL AND v_fecha2 IS NOT NULL THEN
									
									IF  v_fecha1 > v_fecha2	THEN
										LET v_entrance_date = v_fecha1;
									ELSE
										LET v_entrance_date = v_fecha2;
									END IF;
								
								ELSE
									LET v_entrance_date = c_fecha_ejecucion;
								END IF;
					--	
							--Last_payment_date
							/*SELECT fecha_ultimo_pago 
								INTO v_last_payment_date
							FROM sd_indicador_cred
								WHERE num_credito = v_account_number;*/
						
							LET v_quote_status = 'ACTIVE';
							LET v_update_date_char = TO_CHAR(v_update_date,'%d/%m/%Y');
							LET v_due_date_char = TO_CHAR(v_due_date,'%d/%m/%Y');
							LET v_last_entrance_date_char = TO_CHAR(v_last_entrance_date,'%d/%m/%Y');
							LET v_last_payment_date_char = TO_CHAR(v_last_payment_date,'%d/%m/%Y');
							LET v_entrance_date_char = TO_CHAR(v_entrance_date,'%d/%m/%Y');
							
							--Se obtiene la sucursal
						SELECT sucursal 
							INTO cSucursal
						FROM sd_maecredcrd 
						WHERE num_credito = v_account_number;
						
						SELECT iva
							INTO dIvaSuc
						FROM bdinteg:"informix".si_sucursales
						WHERE sucursal = cSucursal AND empresa  = '001';
							----SE modifica para obtener la sumatoria de la variable delinquency
						SELECT --a.num_credito,
						sum(capital_debe - capital_pagado) capital_debe,
						sum(interes_debe - interes_pagado) interes_debe, 
						sum(iva_debe - iva_pagado) iva_debe,
						sum((NVL(mora_provi_ordi,0) + NVL(mora_provi_cope,0) + NVL(mora_sdo_ordi,0) - NVL(mora_sdo_ordi_pag,0) + NVL(mora_sdo_cope,0) - NVL(mora_sdo_cope_pag,0))) interes_mora
						--sum(((NVL(mora_provi_ordi,0) + NVL(mora_provi_cope,0) + NVL(mora_sdo_ordi,0) - NVL(mora_sdo_ordi_pag,0) + NVL(mora_sdo_cope,0) - NVL(mora_sdo_cope_pag,0)) * 0.16 )) v_iva_interes_mora
							INTO v_capital_debe_2, v_interes_debe_2, v_iva_debe, v_interes_mora--, v_v_iva_interes_mora
						FROM sd_amortiza_creditocrd_apoyo2021 a
						WHERE a.empresa   = '001'
							AND a.num_credito = v_account_number
						AND capital_status= v_capital_status AND fecha_cuota = v_due_date and num_pago = v_num_pago;
					    --
						LET v_iva_interes_mora = (v_interes_mora * dIvaSuc);
					
					--Delinquency
						LET v_delinquency = v_capital_debe_2 + v_interes_debe_2 + v_iva_debe + v_interes_mora + v_iva_interes_mora;
					
								IF v_condicion_adeudo > 0 THEN 
								
									INSERT INTO ics_cuotas
										(customer_id, identity_code, acc_customer_id, product_id, account_number, age, delinquency, paid_delinquency, principal_delinquency,			
										paid_principal_delinquency, interest_delinquent, paid_interest_delinquent, comission, paid_comission, insurance_deg, paid_insurance_deg,				
										insurance_fire, paid_insurance_fire, other_reasons, paid_other_reasons, update_date, due_date, last_entrance_date, state_cause_id, quote_status,					
										last_payment_date, reviewed, return_id, entrance_date, wite_off_date, fecha_ejecucion, capital_status)
									VALUES
										(v_customer_id, v_identity_code, v_acc_customer_id, v_product_id, v_account_number, v_age, v_delinquency, v_paid_delinquency, v_principal_delinquency,			
										v_paid_principal_delinquency, v_interest_delinquent, v_paid_interest_delinquent, v_comission, v_paid_comission, v_insurance_desg, v_paid_insurance_desg,				
										v_insurance_fire, v_paid_insurance_fire, v_other_reasons, v_paid_other_reasons, v_update_date_char, v_due_date_char, v_last_entrance_date_char, v_state_cause_id, v_quote_status,					
										v_last_payment_date_char, v_reviewed, v_return_id, v_entrance_date_char, v_wite_off_date, c_fecha_ejecucion, v_capital_status);
								END IF;
						END FOREACH;	
					END IF;
			
			--Se aÃ±ade para los estatus 1
			
			--Se aÃ±ade condicion para que tome solo las cuotas con capital estatus 1 y se tenga una cuota minima registrada por cada obligacion
				SELECT distinct(fecha_cuota)
					INTO fecha_inicio
				FROM sd_amortiza_creditocrd_apoyo2021 
				WHERE num_credito = v_account_number
				AND capital_status = 1
				AND fecha_cuota between c_fecha_ejecucion and add_months(c_fecha_ejecucion, 1);
						
					IF fecha_inicio IS NOT NULL THEN
						
						FOREACH WITH HOLD
						
							SELECT capital_pagado, interes_pagado, capital_debe, interes_debe, fecha_cuota, capital_status, num_pago
								INTO v_capital_pagado, v_paid_principal_delinquency, v_capital_debe, v_interes_debe, v_due_date, v_capital_status, v_num_pago
							FROM sd_amortiza_creditocrd_apoyo2021 
							WHERE num_credito = v_account_number 
							AND capital_status = 1  AND fecha_cuota between fecha_inicio and add_months(c_fecha_ejecucion, 1)
								
							LET v_paid_interest_delinquent = v_paid_principal_delinquency;
							LET v_principal_delinquency = v_capital_debe - v_capital_pagado ; --ajustado
							LET v_paid_delinquency = v_capital_pagado + v_paid_principal_delinquency;
							LET v_interest_delinquent = v_interes_debe - v_paid_principal_delinquency; --ajustado
							LET v_update_date = c_fecha_ejecucion;
							LET v_last_entrance_date = c_fecha_ejecucion;
							LET v_state_cause_id = 'UPDATE';
							LET v_condicion_adeudo = v_capital_debe - v_capital_pagado;
							
							SELECT MAX(capital_fecha_pago), MAX(interes_fecha_pago)
								INTO v_fecha1, v_fecha2
							FROM sd_amortiza_creditocrd_apoyo2021
							WHERE num_credito = v_account_number 
								AND capital_status = 1;
									
								
							IF v_fecha1 IS NOT NULL AND v_fecha2 IS NOT NULL THEN
								
								IF  v_fecha1 > v_fecha2	THEN
									LET v_entrance_date = v_fecha1;
								ELSE
									LET v_entrance_date = v_fecha2;
								END IF;
							
							ELSE
								LET v_entrance_date = c_fecha_ejecucion;
							END IF;
								
							--Last_payment_date
							/*SELECT fecha_ultimo_pago 
								INTO v_last_payment_date
							FROM sd_indicador_cred
								WHERE num_credito = v_account_number;*/
							
							LET v_quote_status = 'ACTIVE';
							LET v_update_date_char = TO_CHAR(v_update_date,'%d/%m/%Y');
							LET v_due_date_char = TO_CHAR(v_due_date,'%d/%m/%Y');
							LET v_last_entrance_date_char = TO_CHAR(v_last_entrance_date,'%d/%m/%Y');
							LET v_last_payment_date_char = TO_CHAR(v_last_payment_date,'%d/%m/%Y');
							LET v_entrance_date_char = TO_CHAR(v_entrance_date,'%d/%m/%Y');
					
							
							--Se obtiene la sucursal
							/*	SELECT sucursal 
									INTO cSucursal
								FROM sd_maecredcrd 
								WHERE num_credito = v_account_number;
								
								SELECT iva
									INTO dIvaSuc
								FROM bdinteg:"informix".si_sucursales
								WHERE sucursal = cSucursal AND empresa  = '001';*/
								
									----SE modifica para obtener la sumatoria de la variable delinquency
								SELECT --a.num_credito,
								sum(capital_debe - capital_pagado) capital_debe,
								sum(interes_debe - interes_pagado) interes_debe, 
								sum(iva_debe - iva_pagado) iva_debe,
								sum((NVL(mora_provi_ordi,0) + NVL(mora_provi_cope,0) + NVL(mora_sdo_ordi,0) - NVL(mora_sdo_ordi_pag,0) + NVL(mora_sdo_cope,0) - NVL(mora_sdo_cope_pag,0))) interes_mora
								--sum(((NVL(mora_provi_ordi,0) + NVL(mora_provi_cope,0) + NVL(mora_sdo_ordi,0) - NVL(mora_sdo_ordi_pag,0) + NVL(mora_sdo_cope,0) - NVL(mora_sdo_cope_pag,0)) * 0.16 )) v_iva_interes_mora
									INTO v_capital_debe_2, v_interes_debe_2, v_iva_debe, v_interes_mora--, v_v_iva_interes_mora
								FROM sd_amortiza_creditocrd_apoyo2021 a
								WHERE a.empresa   = '001'
									AND a.num_credito = v_account_number
								AND capital_status= v_capital_status AND fecha_cuota = v_due_date and num_pago = v_num_pago;
								--
								LET v_iva_interes_mora = (v_interes_mora * dIvaSuc);
							
								--Delinquency
								LET v_delinquency = v_capital_debe_2 + v_interes_debe_2 + v_iva_debe + v_interes_mora + v_iva_interes_mora;
					
					
					
							INSERT INTO ics_cuotas
								(customer_id, identity_code, acc_customer_id, product_id, account_number, age, delinquency, paid_delinquency, principal_delinquency,			
								paid_principal_delinquency, interest_delinquent, paid_interest_delinquent, comission, paid_comission, insurance_deg, paid_insurance_deg,				
								insurance_fire, paid_insurance_fire, other_reasons, paid_other_reasons, update_date, due_date, last_entrance_date, state_cause_id, quote_status,					
								last_payment_date, reviewed, return_id, entrance_date, wite_off_date, fecha_ejecucion, capital_status)
							VALUES
								(v_customer_id, v_identity_code, v_acc_customer_id, v_product_id, v_account_number, v_age, v_delinquency, v_paid_delinquency, v_principal_delinquency,			
								v_paid_principal_delinquency, v_interest_delinquent, v_paid_interest_delinquent, v_comission, v_paid_comission, v_insurance_desg, v_paid_insurance_desg,				
								v_insurance_fire, v_paid_insurance_fire, v_other_reasons, v_paid_other_reasons, v_update_date_char, v_due_date_char, v_last_entrance_date_char, v_state_cause_id, v_quote_status,					
								v_last_payment_date_char, v_reviewed, v_return_id, v_entrance_date_char, v_wite_off_date, c_fecha_ejecucion, v_capital_status);
						
						END FOREACH;
						
					END IF;
			END IF;
			--Se aÃ±ade condicion para que tome solo las cuotas con capital estatus 5 y se tenga una cuota minima registrada por cada obligacion
			
				--Se aÃ±ade contador
			SELECT COUNT(*) INTO v_contados_cuotas FROM ics_cuotas WHERE account_number = v_account_number;
			
			--Se aÃ±ade condicion para que tome solo las cuotas con capital estatus 3 y se tenga una cuota minima registrada por cada obligacion
			IF v_contados_cuotas = 0 OR v_contados_cuotas IS NULL OR v_contados_cuotas = '' THEN
						
				SELECT MAX(fecha_cuota)
					INTO fecha_inicio
				FROM sd_amortiza_creditocrd_apoyo2021 
				WHERE num_credito = v_account_number
				AND capital_status in (5) AND fecha_cuota <= add_months(c_fecha_ejecucion, 1);
				
					IF fecha_inicio IS NOT NULL THEN 
						
						FOREACH WITH HOLD
							SELECT capital_pagado, interes_pagado, capital_debe, interes_debe, fecha_cuota, capital_status
								INTO v_capital_pagado, v_paid_principal_delinquency, v_capital_debe, v_interes_debe, v_due_date, v_capital_status
							FROM sd_amortiza_creditocrd_apoyo2021 
							WHERE num_credito = v_account_number 
							AND capital_status in (5)  AND fecha_cuota between fecha_inicio and add_months(c_fecha_ejecucion, 1)
									
							LET v_paid_interest_delinquent = v_paid_principal_delinquency;
							LET v_principal_delinquency = v_capital_debe - v_capital_pagado ; --ajustado
							LET v_paid_delinquency = v_capital_pagado + v_paid_principal_delinquency;
							LET v_interest_delinquent = v_interes_debe - v_paid_principal_delinquency; --ajustado
							LET v_update_date = c_fecha_ejecucion;
							LET v_last_entrance_date = c_fecha_ejecucion;
							LET v_state_cause_id = 'UPDATE';
							LET v_condicion_adeudo = v_capital_debe - v_capital_pagado;
							
							SELECT MAX(capital_fecha_pago), MAX(interes_fecha_pago)
								INTO v_fecha1, v_fecha2
							FROM sd_amortiza_creditocrd_apoyo2021
							WHERE num_credito = v_account_number 
								AND capital_status in (5);
									
								
								IF v_fecha1 IS NOT NULL AND v_fecha2 IS NOT NULL THEN
									
									IF  v_fecha1 > v_fecha2	THEN
										LET v_entrance_date = v_fecha1;
									ELSE
										LET v_entrance_date = v_fecha2;
									END IF;
								
								ELSE
									LET v_entrance_date = c_fecha_ejecucion;
								END IF;
								
--							Last_payment_date
							/*SELECT fecha_ultimo_pago 
								INTO v_last_payment_date
							FROM sd_indicador_cred
								WHERE num_credito = v_account_number;*/
							
							LET v_quote_status = 'ACTIVE';
							LET v_update_date_char = TO_CHAR(v_update_date,'%d/%m/%Y');
							LET v_due_date_char = TO_CHAR(v_due_date,'%d/%m/%Y');
							LET v_last_entrance_date_char = TO_CHAR(v_last_entrance_date,'%d/%m/%Y');
							LET v_last_payment_date_char = TO_CHAR(v_last_payment_date,'%d/%m/%Y');
							LET v_entrance_date_char = TO_CHAR(v_entrance_date,'%d/%m/%Y');
								LET v_delinquency = '0';
							INSERT INTO ics_cuotas
								(customer_id, identity_code, acc_customer_id, product_id, account_number, age, delinquency, paid_delinquency, principal_delinquency,			
								paid_principal_delinquency, interest_delinquent, paid_interest_delinquent, comission, paid_comission, insurance_deg, paid_insurance_deg,				
								insurance_fire, paid_insurance_fire, other_reasons, paid_other_reasons, update_date, due_date, last_entrance_date, state_cause_id, quote_status,					
								last_payment_date, reviewed, return_id, entrance_date, wite_off_date, fecha_ejecucion, capital_status)
							VALUES
								(v_customer_id, v_identity_code, v_acc_customer_id, v_product_id, v_account_number, v_age, v_delinquency, v_paid_delinquency, v_principal_delinquency,			
								v_paid_principal_delinquency, v_interest_delinquent, v_paid_interest_delinquent, v_comission, v_paid_comission, v_insurance_desg, v_paid_insurance_desg,				
								v_insurance_fire, v_paid_insurance_fire, v_other_reasons, v_paid_other_reasons, v_update_date_char, v_due_date_char, v_last_entrance_date_char, v_state_cause_id, v_quote_status,					
								v_last_payment_date_char, v_reviewed, v_return_id, v_entrance_date_char, v_wite_off_date, c_fecha_ejecucion, v_capital_status);
						END FOREACH;
					END IF;
			END IF;
			
			SELECT COUNT(*) INTO v_contados_cuotas FROM ics_cuotas WHERE account_number = v_account_number;
			
			--Se aÃ±ade condicion para que tome solo las cuotas con capital estatus 3 y se tenga una cuota minima registrada por cada obligacion
			IF v_contados_cuotas = 0 OR v_contados_cuotas IS NULL OR v_contados_cuotas = '' THEN
						
				SELECT MAX(fecha_cuota)
					INTO fecha_inicio
				FROM sd_amortiza_creditocrd_apoyo2021 
				WHERE num_credito = v_account_number
				AND capital_status in (3) AND fecha_cuota <= add_months(c_fecha_ejecucion, 1);
				
					IF fecha_inicio IS NOT NULL THEN 
						
						FOREACH WITH HOLD
							SELECT capital_pagado, interes_pagado, capital_debe, interes_debe, fecha_cuota, capital_status
								INTO v_capital_pagado, v_paid_principal_delinquency, v_capital_debe, v_interes_debe, v_due_date, v_capital_status
							FROM sd_amortiza_creditocrd_apoyo2021 
							WHERE num_credito = v_account_number 
							AND capital_status in (3)  AND fecha_cuota between fecha_inicio and add_months(c_fecha_ejecucion, 1)
									
							LET v_paid_interest_delinquent = v_paid_principal_delinquency;
							LET v_principal_delinquency = v_capital_debe - v_capital_pagado ; --ajustado
							LET v_paid_delinquency = v_capital_pagado + v_paid_principal_delinquency;
							LET v_interest_delinquent = v_interes_debe - v_paid_principal_delinquency; --ajustado
							LET v_update_date = c_fecha_ejecucion;
							LET v_last_entrance_date = c_fecha_ejecucion;
							LET v_state_cause_id = 'UPDATE';
							LET v_condicion_adeudo = v_capital_debe - v_capital_pagado;
							
							SELECT MAX(capital_fecha_pago), MAX(interes_fecha_pago)
								INTO v_fecha1, v_fecha2
							FROM sd_amortiza_creditocrd_apoyo2021
							WHERE num_credito = v_account_number 
								AND capital_status in (3);
									
								
								IF v_fecha1 IS NOT NULL AND v_fecha2 IS NOT NULL THEN
									
									IF  v_fecha1 > v_fecha2	THEN
										LET v_entrance_date = v_fecha1;
									ELSE
										LET v_entrance_date = v_fecha2;
									END IF;
								
								ELSE
									LET v_entrance_date = c_fecha_ejecucion;
								END IF;
								
--							Last_payment_date
							/*SELECT fecha_ultimo_pago 
								INTO v_last_payment_date
							FROM sd_indicador_cred
								WHERE num_credito = v_account_number;*/
							
							LET v_quote_status = 'ACTIVE';
							LET v_update_date_char = TO_CHAR(v_update_date,'%d/%m/%Y');
							LET v_due_date_char = TO_CHAR(v_due_date,'%d/%m/%Y');
							LET v_last_entrance_date_char = TO_CHAR(v_last_entrance_date,'%d/%m/%Y');
							LET v_last_payment_date_char = TO_CHAR(v_last_payment_date,'%d/%m/%Y');
							LET v_entrance_date_char = TO_CHAR(v_entrance_date,'%d/%m/%Y');
								LET v_delinquency = '0';
							INSERT INTO ics_cuotas
								(customer_id, identity_code, acc_customer_id, product_id, account_number, age, delinquency, paid_delinquency, principal_delinquency,			
								paid_principal_delinquency, interest_delinquent, paid_interest_delinquent, comission, paid_comission, insurance_deg, paid_insurance_deg,				
								insurance_fire, paid_insurance_fire, other_reasons, paid_other_reasons, update_date, due_date, last_entrance_date, state_cause_id, quote_status,					
								last_payment_date, reviewed, return_id, entrance_date, wite_off_date, fecha_ejecucion, capital_status)
							VALUES
								(v_customer_id, v_identity_code, v_acc_customer_id, v_product_id, v_account_number, v_age, v_delinquency, v_paid_delinquency, v_principal_delinquency,			
								v_paid_principal_delinquency, v_interest_delinquent, v_paid_interest_delinquent, v_comission, v_paid_comission, v_insurance_desg, v_paid_insurance_desg,				
								v_insurance_fire, v_paid_insurance_fire, v_other_reasons, v_paid_other_reasons, v_update_date_char, v_due_date_char, v_last_entrance_date_char, v_state_cause_id, v_quote_status,					
								v_last_payment_date_char, v_reviewed, v_return_id, v_entrance_date_char, v_wite_off_date, c_fecha_ejecucion, v_capital_status);
						END FOREACH;
					END IF;
			END IF;
			
			
			---=============*********** Se concluyen las las validaciones a la tablas sd_amortiza_creditocrd_apoyo2021 
				
			LET iContador1 = iContador1 + 1;
					
			IF iContador1 >= 100000 THEN
				SELECT DBINFO("utc_to_datetime", sh_curtime) 
					INTO horaActual 
				FROM sysmaster:sysshmvals;
				INSERT INTO ics_tiempos (num_registro, hora, proceso) VALUES (iContador1, horaActual, 'IN_CICLO_CUOTAS_CRD');
				LET iContador1 = 0;
			END IF; 
			
			LET iContador = iContador + 1;
					
			IF iContador >= 1000 THEN
				COMMIT WORK;
				LET iContador = 0;
				BEGIN WORK;
			END IF; 
				
		END FOREACH;
			
		SELECT DBINFO("utc_to_datetime", sh_curtime) 
			INTO horaActual 
		FROM sysmaster:sysshmvals;
		INSERT INTO ics_tiempos (num_registro, hora, proceso) VALUES (iContador1, horaActual, 'FIN_CICLO_CUOTA_CRD');
			
			
		COMMIT WORK;
		
		LET v_transaccion = 0;
		
		RETURN v_cod_ret;		
			
	END;
END PROCEDURE
DOCUMENT
'Sistema		:	iCS',
'Creacion		:	BanCoppel',
'Area			:	Sistemas Administrativos y Perifericos',
					'Gerencia de Mtto y Soporte IV',
'Coordinador	:	Norberto Corona Berruecos',
'FECHA			: 	Oct 2021',
'Requerimiento	:	RQM 09 596',
'VERSION		: 	1.0.0';

CREATE PROCEDURE "informix".sp_numero_hilos_ics( pfecha date) 
							RETURNING char(7);


DEFINE  vsqlerr 						INTEGER;
DEFINE 	vcodret 						CHAR(7);
DEFINE  v_cantidad_universo				INT8  ;
DEFINE  cantidad_registros				INT8  ;
DEFINE  v_valor_inicial					INT8  ;
DEFINE  v_valor_final                   INT8  ;
DEFINE  i              					INTEGER;
DEFINE v_cantidad_minima_cdr			INT8  ;
DEFINE v_cantidad_maxima_cdr			INT8  ;
DEFINE v_cantidad_universo_crd			INT8  ;
DEFINE v_fecha_ejecucion					DATE;
DEFINE  v_cantidad_universo_min				INT8  ;
DEFINE v_cantidad						INT8  ;
DEFINE cred_fin							CHAR(20);
   DEFINE pprocesos     SMALLINT;
   DEFINE pcontador     SMALLINT;

LET vsqlerr								= 0;
LET vcodret								= '00000';
LET v_cantidad_universo					= 0;
LET v_cantidad_universo_min					= 0;
LET i                  					= 1;
LET v_fecha_ejecucion					= NULL;
LET cred_fin							= NULL;
LET pprocesos 							= 10;
LET pcontador							= 0;

	BEGIN
	  ON EXCEPTION SET vsqlerr
		COMMIT WORK;
	  IF vsqlerr <>0 THEN
		LET vcodret = vsqlerr;
		RETURN vcodret;
	  END IF;
	END EXCEPTION;

	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	TRUNCATE TABLE ics_numero_proceso;
	---ALTER TABLE ics_clientes_cred_crd MODIFY (ics_consecutivo serial (1));

	--BEGIN WORK;
	
		--SELECT fecha_hoy 
		--	INTO v_fecha_ejecucion
		--FROM bdinteg:si_fechas;
		LET v_fecha_ejecucion = pfecha;
		
		SELECT min(num_credito)
			INTO v_cantidad_universo_min
		FROM ics_clientes WHERE tipo_cred='1';
		
		SELECT MAX(num_credito)
			INTO v_cantidad_universo 
		FROM ics_clientes WHERE tipo_cred='1';
		
		SELECT count(*)
			INTO v_cantidad 
		FROM ics_clientes WHERE tipo_cred='1';
		LET v_valor_inicial = 0;
		
		--LET v_cantidad = v_cantidad_universo - v_cantidad_universo_min;
		
		--CREAR VARIABLE
		LET cantidad_registros = ROUND(v_cantidad / pprocesos);
		LET v_valor_final = '000000000000';
		LET v_valor_inicial = v_cantidad_universo_min ;
		--Declarar i
		--WHILE i <= 10 
			
			FOR pcontador = 1 TO  pprocesos
				
				FOREACH
					SELECT SKIP cantidad_registros FIRST 1 nvl(num_credito,'')
								INTO cred_fin
					FROM bdicred:ics_clientes
					WHERE tipo_cred = '1' and num_credito >= v_valor_inicial
					ORDER BY num_credito
				end FOREACH;
				
				
				IF pcontador = 1 THEN
						LET v_valor_inicial = v_cantidad_universo_min;
					 --  LET prango = '000000000000'||'-'|| trim(nvl(cred_fin,''));
                        LET v_valor_final = cred_fin ;
                       -- LET pparametro = '951';
						--LET pparametro2 = '981';
                 ELSE
                        IF pcontador = pprocesos THEN
                            LET v_valor_inicial = v_valor_final + 1;
							LET v_valor_final = v_cantidad_universo;
							--LET prango = trim(nvl(cred_ini,''))||'-'|| '999999999999';
                        ELSE    
						
								LET v_valor_inicial = v_valor_final + 1;
								
					 --  LET prango = '000000000000'||'-'|| trim(nvl(cred_fin,''));
								LET v_valor_final = cred_fin ;
						
                            --LET prango = trim(nvl(cred_ini,''))||'-'|| trim(nvl(cred_fin,''));
                            --LET cred_ini = cred_fin;
                        END IF;

                     --   LET pparametro = (pparametro::integer + 1)::varchar(3); 
						--LET pparametro2 = (pparametro2::integer + 1)::varchar(3);  
                 END IF;
				
				
				
				/*IF i = 10 THEN
					LET v_valor_final = cred_fin;
				ELSE
					LET v_valor_final = cred_fin;
				END IF;*/
				
				/*IF v_valor_inicial = 0 THEN
					LET v_valor_inicial = v_cantidad_universo_min;
				ELSE
					LET v_valor_inicial = v_valor_final + 1;
				END IF;
					
				IF i = 10 THEN
					LET v_valor_final = v_cantidad_maxima_cdr;
				ELSE
					LET v_valor_final = cred_fin;
				END IF;*/
				
			--CREAR TABLA
				INSERT INTO "informix".ics_numero_proceso(numero_hilo, valor_inicial, valor_final, tipo_cred, fecha_ejecucion)	
				VALUES (i, v_valor_inicial, v_valor_final,'1', v_fecha_ejecucion);
				
				--UPDATE ics_clientes_2 SET proceso = i where ics_consecutivo between v_valor_inicial and v_valor_final and tipo_cred='1';
				LET v_valor_inicial = v_valor_final + 1;
				
				LET i = i + 1;
			--END WHILE;
		 END FOR;
		
		--Totalk de registros para crd
		SELECT MIN(num_credito)
			INTO v_cantidad_minima_cdr 
		FROM ics_clientes WHERE tipo_cred='2';
		--CREAR VARIABLE
		--LET cantidad_registros = ROUND(v_cantidad_universo / 10);
		
		SELECT MAX(num_credito)
			INTO v_cantidad_maxima_cdr 
		FROM ics_clientes WHERE tipo_cred='2';
		--CREAR VARIABLE
		
		
		
		--LET cantidad_registros = 
		
		SELECT count(*)
			INTO v_cantidad 
		FROM ics_clientes WHERE tipo_cred='2';
		
		LET v_cantidad_universo_crd = ROUND(v_cantidad / 10); --(v_cantidad_maxima_cdr - v_cantidad_minima_cdr);
		--LET cantidad_registros = ROUND(v_cantidad_universo_crd / 10);
		LET i = 1;
		LET v_valor_final = 0;
		LET v_valor_inicial = v_cantidad_minima_cdr;
		--Declarar i
		
		FOR pcontador = 1 TO  pprocesos
		--WHILE i <= 10 
			
			
			FOREACH
				SELECT SKIP v_cantidad_universo_crd FIRST 1 nvl(num_credito,'')
							INTO cred_fin
				FROM bdicred:ics_clientes
				WHERE tipo_cred = '2'
				AND num_credito >= v_valor_inicial
				ORDER BY num_credito
			end FOREACH;
			
			IF i = 1 THEN
				LET v_valor_inicial = v_cantidad_minima_cdr;
			ELSE
				LET v_valor_inicial = v_valor_final + 1;
			END IF;
				
			IF i = 10 THEN
				LET v_valor_final = v_cantidad_maxima_cdr;
			ELSE
				LET v_valor_final = cred_fin;
			END IF;
			
			
			
		--CREAR TABLA
			INSERT INTO "informix".ics_numero_proceso(numero_hilo, valor_inicial, valor_final, tipo_cred, fecha_ejecucion)	
			VALUES (i, v_valor_inicial, v_valor_final,'2', v_fecha_ejecucion);
			
			--UPDATE ics_clientes_2 SET proceso = i where ics_consecutivo between v_valor_inicial and v_valor_final and tipo_cred='2';
			
			LET v_valor_inicial = v_valor_final + 1;
			
			LET i = i + 1;
		--END WHILE;
		END FOR;
		
		
		
	--COMMIT WORK;
	
RETURN vcodret;
END;
END PROCEDURE;
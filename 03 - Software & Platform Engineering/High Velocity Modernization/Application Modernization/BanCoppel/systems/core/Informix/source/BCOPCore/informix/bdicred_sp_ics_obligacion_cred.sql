CREATE PROCEDURE "informix".sp_ics_obligacion_cred(p_num_ejecucion INTEGER)

	RETURNING
		CHAR(5)							AS cod_ret;


	--Variables--
	DEFINE sql_err 						INTEGER;
	DEFINE v_cod_ret 					CHAR(5);
	--Variables generales--
	DEFINE v_num_cliente				VARCHAR(20);
	DEFINE v_saldo_retenido				DECIMAL;
	DEFINE v_dias_gracia_mora			SMALLINT;
	DEFINE v_fecha_clean_behavior 		DATE;
	DEFINE v_fecha_dirty_behavior 		DATE;
	DEFINE v_behaviour_score_obtenida 	SMALLINT;
	DEFINE v_num_tarjeta 				VARCHAR(20);
	DEFINE v_longitud_tarjeta 			SMALLINT;
	DEFINE v_max_secuencia_tarjeta		INTEGER;
	DEFINE v_fecha_validacion			DATE;
	--Variables para Insertar--
	DEFINE v_identity_code				VARCHAR(13);
	DEFINE v_acc_customer_id			VARCHAR(20);
	DEFINE v_product_id					VARCHAR(20);
	DEFINE v_account_number				VARCHAR(20);
	DEFINE v_cust_branch_id				VARCHAR(15);
	DEFINE c_account_status				VARCHAR(10);
	DEFINE v_work_type					VARCHAR(15);
	DEFINE v_last_entrance_date			DATE;
	DEFINE v_last_entrance_date_char	CHAR(10);
	DEFINE v_days_delinquent			SMALLINT;
	DEFINE v_balance					DECIMAL(15,2);
	DEFINE v_delinquency				DECIMAL(15,2);
	DEFINE v_original_balance			DECIMAL(15,2);
	DEFINE v_principal_balance			DECIMAL(15,2);
	DEFINE v_interest_balance			DECIMAL(15,2);
	DEFINE v_principal_delinquent		DECIMAL(15,2);
	DEFINE v_interest_delinquent		DECIMAL(15,2);
	DEFINE v_overlimit					DECIMAL(15,2);
	DEFINE v_credit_limit				DECIMAL(15,2);
	DEFINE v_insurance_amount			DECIMAL(15,2);
	DEFINE v_collection_chargue			DECIMAL(15,2);
	DEFINE v_disputed_amount			DECIMAL(15,2);
	DEFINE v_provisioned_amount			VARCHAR(10);
	DEFINE v_interest_rate				DECIMAL(8,5);
	DEFINE v_cycle_day					SMALLINT;
	DEFINE v_billing_day				SMALLINT;
	DEFINE v_payment_frequency          SMALLINT;
	DEFINE v_payment_frequency_char		CHAR(1);
	DEFINE v_credit_score				SMALLINT;
	DEFINE v_behaviour_score			SMALLINT;
	DEFINE v_principal_delinquency_0	DECIMAL(15,2);
	DEFINE v_principal_delinquency_1	DECIMAL(15,2);
	DEFINE v_principal_delinquency_2	DECIMAL(15,2);
	DEFINE v_principal_delinquency_3	DECIMAL(15,2);
	DEFINE v_principal_delinquency_4	DECIMAL(15,2);
	DEFINE v_principal_delinquency_5	DECIMAL(15,2);
	DEFINE v_principal_delinquency_6	DECIMAL(15,2);
	DEFINE v_delinquency_0				DECIMAL(15,2);
	DEFINE v_delinquency_1				DECIMAL(15,2);
	DEFINE v_delinquency_2				DECIMAL(15,2);
	DEFINE v_delinquency_3				DECIMAL(15,2);
	DEFINE v_delinquency_4				DECIMAL(15,2);
	DEFINE v_delinquency_5				DECIMAL(15,2);
	DEFINE v_delinquency_6				DECIMAL(15,2);
	DEFINE v_due_date_0					DATE;
	DEFINE v_due_date_0_char			CHAR(10);
	DEFINE v_due_date_1					DATE;
	DEFINE v_due_date_1_char			CHAR(10);
	DEFINE v_due_date_2					DATE;
	DEFINE v_due_date_2_char			CHAR(10);
	DEFINE v_due_date_3					DATE;
	DEFINE v_due_date_3_char			CHAR(10);
	DEFINE v_due_date_4					DATE;
	DEFINE v_due_date_4_char			CHAR(10);
	DEFINE v_due_date_5					DATE;
	DEFINE v_due_date_5_char			CHAR(10);
	DEFINE v_due_date_6					DATE;
	DEFINE v_due_date_6_char			CHAR(10);
	DEFINE v_opening_date				DATE;
	DEFINE v_opening_date_char			CHAR(10);
	DEFINE v_wite_off_date 				DATE;
	DEFINE char_v_wite_off_date 		CHAR(10);
	DEFINE v_payment_date				DATE;
	DEFINE v_payment_date_char			CHAR(10);
	DEFINE v_prescription_date			DATE;
	DEFINE v_prescription_date_char		CHAR(10);
	DEFINE v_last_rest_date				DATE;
	DEFINE v_last_rest_date_char		CHAR(10);
	DEFINE v_return_id 					VARCHAR(80);
	DEFINE v_user_defined1				VARCHAR(16);
	DEFINE v_qualification				VARCHAR(10);
	DEFINE v_session_id					VARCHAR(200);
	DEFINE v_update_online				DATE;
	DEFINE c_fecha_ejecucion			DATE;
	DEFINE v_fecha_inicial				DATE;
	DEFINE v_fecha_final				DATE;
	DEFINE v_valor_inicial 				INT8;
	DEFINE v_valor_final				INT8;
	
	--Valores por Default--
	DEFINE c_reviewed					CHAR(1);
	DEFINE c_expiration_date			DATE;
	DEFINE char_expiration_date			CHAR(10);
	
	--Variables de definiciÃ?ÃÂ³n SP
	DEFINE codRet_sp_sdos				CHAR(6);
	DEFINE v_cap_trans 					DECIMAL(18,2);
	DEFINE v_cap_vdo_exig 				DECIMAL(18,2);
	DEFINE v_int_vdo 					DECIMAL(18,2);
	DEFINE v_int_moratorios 			DECIMAL(18,2);
	DEFINE v_iva_int_vdo 				DECIMAL(18,2);
	DEFINE v_iva_int_moratorios 		DECIMAL(18,2);
	DEFINE v_com_pend 					DECIMAL(18,2);
	DEFINE v_iva_com 					DECIMAL(18,2);
	DEFINE v_total_liquidacion 			DECIMAL(18,2);
	DEFINE v_tiempo_obligaciones		VARCHAR(20);
	
	DEFINE v_comodin_char_sp 			CHAR(80);
	DEFINE v_comodin_date_sp 			DATE;
	DEFINE v_comodin_decimal_sp 		DECIMAL(18,2);
	DEFINE v_comodin_int_sp 			INTEGER;
	DEFINE v_capital_debe				DECIMAL(18,2);
	DEFINE v_capital_pagado				DECIMAL(18,2);
	DEFINE v_proceso 					VARCHAR(50);				
	DEFINE iContador 					INTEGER;
	
	DEFINE horaActual					DATETIME YEAR TO FRACTION(5);
	DEFINE iContador1 					INTEGER;
	DEFINE v_transaccion				INTEGER;
	DEFINE v_activo_ics					BOOLEAN;
	DEFINE v_overdue_payments			INTEGER;
	DEFINE v_fecha_desactivado_ics		DATE;
	
	LET v_cod_ret 						= '00000';
	LET sql_err 						= NULL;
	
	--Variables generales--
	LET v_capital_debe					= 0.0;
	LET v_capital_pagado				= 0.0;
	LET v_num_cliente					= NULL;
	LET v_saldo_retenido				= 0.0;
	LET v_dias_gracia_mora				= 0;
	LET v_fecha_clean_behavior 			= NULL;
	LET v_fecha_dirty_behavior 			= NULL;
	LET v_behaviour_score_obtenida 		= 0;
	LET v_num_tarjeta 					= NULL;
	LET v_longitud_tarjeta 				= 0;
	LET v_max_secuencia_tarjeta			= NULL;
	LET v_payment_frequency_char  		= NULL;
	LET v_fecha_validacion				= NULL;
	--Variables para Insertar--
	LET v_identity_code					= NULL;
	LET v_acc_customer_id				= NULL;
	LET v_product_id					= NULL;
	LET v_account_number				= NULL;
	LET v_cust_branch_id				= NULL;
	LET v_work_type						= NULL;
	LET v_last_entrance_date			= NULL;
	LET v_last_entrance_date_char		= NULL;
	LET v_days_delinquent				= NULL;
	LET v_balance						= 0.0;
	LET v_delinquency					= 0.0;
	LET v_original_balance				= 0.0;
	LET v_principal_balance				= 0.0;
	LET v_interest_balance				= 0.0;
	LET v_principal_delinquent			= 0.0;
	LET v_interest_delinquent			= 0.0;
	LET v_overlimit						= 0.0;
	LET v_credit_limit					= 0.0;
	LET v_insurance_amount				= 0.0;
	LET v_disputed_amount				= 0.0;
	LET v_provisioned_amount			= NULL;
	LET v_interest_rate					= 0.0;
	LET v_collection_chargue			= 0.0; 
	LET v_cycle_day						= 0;
	LET v_billing_day					= 0;
	LET v_payment_frequency				= 0;
	LET v_credit_score					= 0;
	LET v_behaviour_score				= 0;
	LET v_principal_delinquency_0		= 0.0;
	LET v_principal_delinquency_1		= 0.0;
	LET v_principal_delinquency_2		= 0.0;
	LET v_principal_delinquency_3		= 0.0;
	LET v_principal_delinquency_4		= 0.0;
	LET v_principal_delinquency_5		= 0.0;
	LET v_principal_delinquency_6		= 0.0;
	LET v_delinquency_0					= 0.0;
	LET v_delinquency_1					= 0.0;
	LET v_delinquency_2					= 0.0;
	LET v_delinquency_3					= 0.0;
	LET v_delinquency_4					= 0.0;
	LET v_delinquency_5					= 0.0;
	LET v_delinquency_6					= 0.0;
	LET v_due_date_0					= NULL;
	LET v_due_date_0_char				= NULL;
	LET v_due_date_1					= NULL;
	LET v_due_date_1_char				= NULL;
	LET v_due_date_2					= NULL;
	LET v_due_date_2_char				= NULL;
	LET v_due_date_3					= NULL;
	LET v_due_date_3_char				= NULL;
	LET v_due_date_4					= NULL;
	LET v_due_date_4_char				= NULL;
	LET v_due_date_5					= NULL;
	LET v_due_date_5_char				= NULL;
	LET v_due_date_6					= NULL;
	LET v_due_date_6_char				= NULL;
	LET v_wite_off_date					= mdy(01,01,1900);
	LET char_v_wite_off_date			= NULL;
	LET v_payment_date					= NULL;
	LET v_opening_date_char				= NULL;
	LET v_prescription_date				= NULL;
	LET v_prescription_date_char		= NULL;
	LET v_last_rest_date				= NULL;
	LET v_last_rest_date_char			= NULL;
	LET v_return_id 					= NULL;
	LET v_user_defined1					= NULL;
	LET v_qualification					= NULL;
	LET v_session_id 					= 'PENDING';
	LET v_update_online					= NULL;
	LET c_fecha_ejecucion				= NULL;
	
	LET c_reviewed						= 'N';
	LET c_expiration_date				= mdy(01,01,1900);
	LET c_account_status 				= 'ACTIVE';
	LET char_expiration_date			= NULL;
	
	LET iContador 						= 0;
	
	LET horaActual						= NULL;
	LET iContador1 						= 0;
	LET v_valor_inicial 				= 0;
	LET v_valor_final				    = 0;
	LET v_fecha_inicial					= NULL;
	LET v_fecha_final					= NULL;
	LET v_transaccion					= 0;
	LET v_activo_ics					= NULL;
	LET v_proceso ='';
	LET v_overdue_payments				= 0;
	LET v_fecha_desactivado_ics			= NULL;
        
        --SET DEBUG FILE TO "//resplogifx/cobranza/obligacion_pruebas.out"; --Este es el SP actual y funcional
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
			  VALUES( v_account_number, v_num_cliente, v_acc_customer_id, 'ERROR -535 obligaciones',v_proceso, CURRENT);
			    COMMIT WORK;
				BEGIN WORK;

		 END EXCEPTION WITH RESUME;
		--SELECT fecha_hoy 
		--	INTO c_fecha_ejecucion
		--FROM bdinteg:si_fechas;
		
		--TRUNCATE TABLE ics_obligacion_2;
		
		
		/*DROP INDEX IF EXISTS informix.ics_obligacion_idx_fec_eje_2 ONLINE;
		DROP INDEX IF EXISTS informix.index_primerio ONLINE;
		DROP INDEX IF EXISTS informix.ics_obligacion_idx_acc_2 ONLINE;
		DROP INDEX IF EXISTS informix.ics_obligacion_idx_user_defined_2 ONLINE;*/
		LET v_tiempo_obligaciones = 'IN_OBLIGACION'||'_'||p_num_ejecucion;
		
		SELECT DBINFO("utc_to_datetime", sh_curtime) 
			INTO horaActual 
		FROM sysmaster:sysshmvals;
		INSERT INTO ics_tiempos (num_registro, hora, proceso) VALUES (iContador1, horaActual, v_tiempo_obligaciones);
		
		BEGIN WORK;
			 LET v_transaccion = 1;
			 LET v_proceso = 'Creditos Revolventes ObligaciÃÂ³n';
			SELECT valor_inicial, valor_final, fecha_ejecucion
				INTO v_valor_inicial, v_valor_final, c_fecha_ejecucion
			FROM ics_numero_proceso 
			WHERE numero_hilo = p_num_ejecucion and tipo_cred='1';
			
				/*SELECT 
					mc.numcte, mc.num_producto, mc.num_credito, mc.sucursal, mc.status_cred, 
					mc.tasa_interes, mc.bandera_ministra, mc.fecha_apertura, mc.balance, mc.delinquency, mc.principal_delinquent, 
					mc.interest_delinquent, mc.collection_chargue, mc.rfc
				INTO
					v_num_cliente, v_acc_customer_id, v_account_number, v_cust_branch_id, v_work_type, 
					v_interest_rate, v_payment_frequency_char, v_opening_date, v_balance, v_delinquency, v_principal_delinquent, v_interest_delinquent, v_collection_chargue
				FROM ics_clientes_2 mc WHERE mc.tipo_cred = '1' AND ics_consecutivo BETWEEN v_valor_inicial AND v_valor_final
				INTO TEMP temp_obligaciones_cred WITH NO LOG;*/
			
			
			
			FOREACH WITH HOLD
			
			
				--Select num_credito  INTO v_account_number FROM ics_creditos_obligaciones
			
				SELECT 
					mc.numcte, mc.num_producto, mc.num_credito, mc.sucursal, mc.status_cred, 
					mc.tasa_interes, mc.bandera_ministra, mc.fecha_apertura, mc.balance, mc.delinquency, mc.principal_delinquent, mc.interest_delinquent, 
					mc.collection_chargue, mc.rfc, mc.pagos_vencidos
				INTO
					v_num_cliente, v_acc_customer_id, v_account_number, v_cust_branch_id, v_work_type, 
					v_interest_rate, v_payment_frequency_char, v_opening_date, v_balance, v_delinquency, v_principal_delinquent, v_interest_delinquent, 
					v_collection_chargue, v_identity_code, v_overdue_payments
				FROM ics_clientes mc WHERE mc.tipo_cred = '1' AND /*proceso = p_num_ejecucion--*/ num_credito BETWEEN v_valor_inicial AND v_valor_final
				
				/*SELECT df.num_producto
					INTO v_product_id
				FROM sd_definicion df 
				WHERE num_producto= v_acc_customer_id;*/
				
				 
				
				SELECT limit 1 activo_ics, fecha_desactivado_ics into v_activo_ics, v_fecha_desactivado_ics FROM ics_maectrl where num_credito = v_account_number;
				
				IF v_activo_ics = 'f' AND v_fecha_desactivado_ics = (c_fecha_ejecucion + 1) THEN
					LET c_account_status 				= 'INACTIVE';
				ELSE
					LET c_account_status 				= 'ACTIVE';
				END IF;
				
				
				LET v_product_id = v_acc_customer_id;
				
				IF v_acc_customer_id IN ('6001','6011','6500','6600','6900','7000','7200','7500','8100','8500', '5400') THEN
					LET v_acc_customer_id = 'TARJETA DE CREDITO';
				END IF;
				
				IF v_acc_customer_id IN ('6300','6800','7300','7600','7700','8600','9100','9300') THEN
					LET v_acc_customer_id = 'PRESTAMO PERSONAL';
				END IF;
				
				IF v_acc_customer_id IN ('6400','7400','7800') THEN
					LET v_acc_customer_id = 'NOMINA';
				END IF;
				
				/*SELECT rfc
					INTO v_identity_code
				FROM bdinteg:si_cliente 
				WHERE numcte = v_num_cliente;*/
				
				SELECT limit 1 dias_atraso, intereses_periodo_ch
					INTO v_days_delinquent, v_interest_balance
				FROM sd_indicador_cred
				WHERE num_credito = v_account_number;
				
				SELECT limit 1 monto_otorgado, sdo_cap_insoluto, sdo_retenido
					INTO v_original_balance, v_principal_balance, v_saldo_retenido
				FROM sd_maesdos
				WHERE num_credito = v_account_number;
				
				SELECT limit 1 dia_corte, dias_gracia_mora, prox_fecha_pago
					INTO v_cycle_day, v_dias_gracia_mora, v_payment_date
				FROM sd_maecredanexo
				WHERE num_credito = v_account_number;
				
				Select limit 1 bs_score 
					INTO v_credit_score
				FROM  bdisolic:ss_revision_determinacion	
					WHERE num_solicitud = v_account_number;
					
				IF v_principal_balance < 0 THEN --Si el Capital Insoluto es Negativo, solo se resta el Saldo Retenido
					LET v_credit_limit = v_original_balance - v_saldo_retenido;
				ELSE
					LET v_credit_limit = v_original_balance - v_principal_balance - v_saldo_retenido;
				END IF
				
				IF v_payment_frequency_char = 'M' THEN --Revisar que valores se deben insertar para los periodos
					LET v_payment_frequency = 30;
				ELSE
					LET v_payment_frequency = 15;
				END IF
				
				LET v_billing_day = v_cycle_day - v_dias_gracia_mora;
				
				/*SELECT balance, delinquency, principal_delinquent, interest_delinquent, collection_chargue
					INTO v_balance, v_delinquency, v_principal_delinquent, v_interest_delinquent, v_collection_chargue
				FROM ics_clientes_2
				WHERE num_credito = v_account_number;*/
				--
				
				--ObtenciÃÂ³n del Behavor_score
				SELECT MAX(fecha_reporte) 
					INTO v_fecha_clean_behavior
				FROM sd_clientes_clean_behavior 
					WHERE num_credito = v_account_number AND status_bit IS NULL;

				SELECT MAX(fecha_reporte) 
					INTO v_fecha_dirty_behavior
				FROM sd_clientes_dirty_behavior 
					WHERE num_credito = v_account_number AND status_bit IS NULL;
				
				IF v_fecha_dirty_behavior IS NULL THEN
					SELECT limit 1 REPLACE(score,CHR (13))::SMALLINT as score -- JVG G4
						INTO v_behaviour_score
					FROM sd_clientes_clean_behavior
					WHERE num_credito = v_account_number 
						AND fecha_reporte = v_fecha_clean_behavior;
					
					LET v_behaviour_score_obtenida = 1;
				END IF
				
				IF v_fecha_clean_behavior IS NULL THEN
					SELECT limit 1 REPLACE(score,CHR (13))::SMALLINT as score
						INTO v_behaviour_score
					FROM sd_clientes_dirty_behavior
					WHERE num_credito = v_account_number 
						AND fecha_reporte = v_fecha_dirty_behavior;
					
					LET v_behaviour_score_obtenida = 1;
				END IF
				
				IF v_behaviour_score_obtenida = 0 THEN
					IF v_fecha_dirty_behavior > v_fecha_dirty_behavior THEN
						SELECT limit 1 REPLACE(score,CHR (13))::SMALLINT as score
							INTO v_behaviour_score
						FROM sd_clientes_dirty_behavior
						WHERE num_credito = v_account_number 
							AND fecha_reporte = v_fecha_dirty_behavior;
					ELSE
						SELECT limit 1 REPLACE(score,CHR (13))::SMALLINT as score
							INTO v_behaviour_score
						FROM sd_clientes_clean_behavior
						WHERE num_credito = v_account_number 
							AND fecha_reporte = v_fecha_clean_behavior;
					END IF
				END IF
				--Fin ObtenciÃÂ³n del Behavor_score
				
				--ObtenciÃÂ³n monto en disputa (aclaraciones)
				-- SELECT SUM(importereclamado) 
					-- INTO v_disputed_amount
				-- FROM bdiaclaracion:acl_aclaracion 
					-- WHERE fky_estatus_aclaracion = 2 and num_cliente = v_num_cliente;
					
				---==== Se obtienen todos los registros de la amortiza por numero de credito
				/*Select * FROM sd_amortiza_credito 
					WHERE num_credito = v_account_number INTO TEMP ics_amortiza_credito WITH NO LOG;*/
					
				LET v_fecha_inicial =c_fecha_ejecucion;
				LET v_fecha_final = add_months(c_fecha_ejecucion, 1);
				
				--Principal_delinquency_0 
				SELECT limit 1 fecha_cuota, capital_debe, capital_pagado
					INTO  v_due_date_0, v_capital_debe, v_capital_pagado
				FROM sd_amortiza_credito 
					WHERE num_credito = v_account_number AND capital_status in (1,2,6,7)
					and fecha_cuota between v_fecha_inicial and v_fecha_final;
				
				LET v_principal_delinquency_0 = v_capital_debe - v_capital_pagado;
				LET v_delinquency_0 = v_principal_delinquency_0;
				--Final Principal_delinquency_0
				
				
				LET v_fecha_inicial = add_months(c_fecha_ejecucion, -1);
				LET v_fecha_final = c_fecha_ejecucion;
				
				--Principal_delinquency_1 
				SELECT limit 1 fecha_cuota, capital_debe, capital_pagado
					INTO  v_due_date_1, v_capital_debe, v_capital_pagado
				FROM sd_amortiza_credito 
					WHERE num_credito = v_account_number AND capital_status in (1,2,6,7)
					and fecha_cuota between v_fecha_inicial and v_fecha_final;
				
				LET v_principal_delinquency_1 = v_capital_debe - v_capital_pagado;
				LET v_delinquency_1 = v_principal_delinquency_0 + v_principal_delinquency_1;
				--Final Principal_delinquency_1
				
				SELECT MIN(fecha_cuota) 
					INTO v_due_date_6
				FROM sd_amortiza_credito 
					WHERE num_credito = v_account_number AND capital_status in (1,2,6,7);
				
				LET v_fecha_validacion = add_months(v_due_date_0,-2);
				
				--Principal_delinquency_2 
				IF v_fecha_validacion >= v_due_date_6 THEN 
					LET v_fecha_inicial = add_months(c_fecha_ejecucion, -2);
					LET v_fecha_final = add_months(c_fecha_ejecucion, -1);
				
				
					SELECT limit 1 fecha_cuota, capital_debe, capital_pagado
						INTO  v_due_date_2, v_capital_debe, v_capital_pagado
					FROM sd_amortiza_credito 
						WHERE num_credito = v_account_number AND capital_status in (2,6,7)
						and fecha_cuota between v_fecha_inicial and v_fecha_final;
				
					LET v_principal_delinquency_2 = v_capital_debe - v_capital_pagado;
					LET v_delinquency_2 = v_principal_delinquency_0 + v_principal_delinquency_1 + v_principal_delinquency_2;
				ELSE
					LET v_due_date_2 = NULL;
					LET v_principal_delinquency_2= NULL;
					LET v_delinquency_2 = NULL;
				END IF;
				--Final Principal_delinquency_2
				
				LET v_fecha_validacion = add_months(v_due_date_0,-3);
				
				--Principal_delinquency_3 
				IF v_fecha_validacion >= v_due_date_6 THEN
					
					LET v_fecha_inicial = add_months(c_fecha_ejecucion, -3);
					LET v_fecha_final = add_months(c_fecha_ejecucion, -2);
					
					
					SELECT limit 1 fecha_cuota, capital_debe, capital_pagado
						INTO  v_due_date_3, v_capital_debe, v_capital_pagado
					FROM sd_amortiza_credito 
						WHERE num_credito = v_account_number AND capital_status in (2,6,7)
						and fecha_cuota between v_fecha_inicial and v_fecha_final;
				
					LET v_principal_delinquency_3 = v_capital_debe - v_capital_pagado;
					LET v_delinquency_3 = v_principal_delinquency_0 + v_principal_delinquency_1 + v_principal_delinquency_2 + v_principal_delinquency_3;
				ELSE
					LET v_due_date_3 = NULL;
					LET v_principal_delinquency_3= NULL;
					LET v_delinquency_3 = NULL;
				END IF;
				--Final Principal_delinquency_3
				
				LET v_fecha_validacion = add_months(v_due_date_0,-4);
				
				--Principal_delinquency_4
				IF v_fecha_validacion >= v_due_date_6 THEN
					
					LET v_fecha_inicial = add_months(c_fecha_ejecucion, -4);
					LET v_fecha_final = add_months(c_fecha_ejecucion, -3);
					
					SELECT limit 1 fecha_cuota, capital_debe, capital_pagado
						INTO  v_due_date_4, v_capital_debe, v_capital_pagado
					FROM sd_amortiza_credito 
						WHERE num_credito = v_account_number AND capital_status in (2,6,7)
						and fecha_cuota between v_fecha_inicial and v_fecha_final;
					
					LET v_principal_delinquency_4 = v_capital_debe - v_capital_pagado;
					LET v_delinquency_4 = v_principal_delinquency_0 + v_principal_delinquency_1 + v_principal_delinquency_2 + v_principal_delinquency_3 + v_principal_delinquency_4;
				ELSE
					LET v_due_date_4 = NULL;
					LET v_principal_delinquency_4= NULL;
					LET v_delinquency_4 = NULL;
				END IF;
				--Final Principal_delinquency_4
				
				LET v_fecha_validacion = add_months(v_due_date_0,-5);
				
				--Principal_delinquency_5
				IF v_fecha_validacion >= v_due_date_6 THEN
					
					LET v_fecha_inicial = add_months(c_fecha_ejecucion, -5);
					LET v_fecha_final = add_months(c_fecha_ejecucion, -4);
					
					SELECT limit 1 fecha_cuota, capital_debe, capital_pagado
						INTO  v_due_date_5, v_capital_debe, v_capital_pagado
					FROM sd_amortiza_credito 
						WHERE num_credito = v_account_number AND capital_status in (2,6,7)
						and fecha_cuota between v_fecha_inicial and v_fecha_final;
				
					LET v_principal_delinquency_5 = v_capital_debe - v_capital_pagado;
					LET v_delinquency_5 = v_principal_delinquency_0 + v_principal_delinquency_1 + v_principal_delinquency_2 + v_principal_delinquency_3 + v_principal_delinquency_4 +
									  v_principal_delinquency_5;
				ELSE
					LET v_due_date_5 = NULL;
					LET v_principal_delinquency_5= NULL;
					LET v_delinquency_5 = NULL;
				END IF;
				--Final Principal_delinquency_5
				
			
				--Principal_delinquency_6
				IF v_principal_delinquency_5 IS NOT NULL THEN
					--LET v_fecha_inicial = add_months(c_fecha_ejecucion, -5);
					LET v_fecha_final = add_months(c_fecha_ejecucion, -5);
					
					SELECT SUM(capital_debe), SUM(capital_pagado)
						INTO  v_capital_debe, v_capital_pagado
					FROM sd_amortiza_credito 
						WHERE num_credito = v_account_number AND capital_status in (2,6,7)
						and fecha_cuota between v_due_date_6 and v_fecha_final;
					
					LET v_principal_delinquency_6 = v_capital_debe - v_capital_pagado;
					LET v_delinquency_6 = v_principal_delinquency_0 + v_principal_delinquency_1 + v_principal_delinquency_2 + v_principal_delinquency_3 + v_principal_delinquency_4 +
										  v_principal_delinquency_5 + v_principal_delinquency_6;
				ELSE
					LET v_due_date_6 = NULL;
					LET v_principal_delinquency_6= NULL;
					LET v_delinquency_6 = NULL;
				END IF;
				--Final Principal_delinquency_6
				
				IF v_work_type = 'CV' OR v_work_type = 'FC' THEN
					SELECT limit 1 fecha 
						INTO v_prescription_date
					FROM sd_maecred_vendida 
						WHERE num_credito = v_account_number;
				END IF
				
				IF v_work_type = 'FC' THEN
					
					LET v_last_rest_date = v_prescription_date;
					/*SELECT fecha 
						INTO v_last_rest_date
					FROM sd_maecred_vendida 
						WHERE num_credito = v_account_number;*/
				END IF
				
				--OJO: Los tamaÃ?ÃÂ±os de las variables no son las mismas; sin embargo, el tamaÃ?ÃÂ±o real de la variable es de 9:
				LET v_user_defined1 = TRIM(v_num_cliente);

				
				--Ultimo 4 digistos de la tarjeta
				SELECT MAX(secuencia)
					INTO v_max_secuencia_tarjeta
				FROM sd_tarjeta 
					WHERE num_credito = v_account_number AND tipo_tarjeta = 'T';
				
				SELECT limit 1 num_tarjeta
					INTO v_num_tarjeta
				FROM sd_tarjeta 
					WHERE num_credito = v_account_number AND tipo_tarjeta = 'T' 
						AND secuencia = v_max_secuencia_tarjeta;
				
				
				LET v_longitud_tarjeta = length(trim(v_num_tarjeta)); 
				LET v_qualification = SUBSTR(v_num_tarjeta,(v_longitud_tarjeta-3),v_longitud_tarjeta);
				
				SELECT FIRST 1 reserva	
					INTO v_provisioned_amount
				FROM ics_reserva_credito
					WHERE num_credito = v_account_number;
					
				LET v_provisioned_amount = replace(replace(v_provisioned_amount,chr(13),''),chr(10),'');
				LET v_last_entrance_date = c_fecha_ejecucion;
				LET v_last_entrance_date_char = TO_CHAR(v_last_entrance_date,'%d/%m/%Y');
				LET v_due_date_0_char = TO_CHAR(v_due_date_0,'%d/%m/%Y');
				LET v_due_date_1_char = TO_CHAR(v_due_date_1,'%d/%m/%Y');
				LET v_due_date_2_char = TO_CHAR(v_due_date_2,'%d/%m/%Y');
				LET v_due_date_3_char = TO_CHAR(v_due_date_3,'%d/%m/%Y');
				LET v_due_date_4_char = TO_CHAR(v_due_date_4,'%d/%m/%Y');
				LET v_due_date_5_char = TO_CHAR(v_due_date_5,'%d/%m/%Y');
				LET v_due_date_6_char = TO_CHAR(v_due_date_6,'%d/%m/%Y');
				LET v_opening_date_char = TO_CHAR(v_opening_date,'%d/%m/%Y');
				LET v_payment_date_char = TO_CHAR(v_payment_date,'%d/%m/%Y');
				LET v_prescription_date_char = TO_CHAR(v_prescription_date,'%d/%m/%Y');
				LET v_last_rest_date_char = TO_CHAR(v_last_rest_date,'%d/%m/%Y');
				LET char_expiration_date = TO_CHAR(c_expiration_date,'%d/%m/%Y');
				LET char_v_wite_off_date = TO_CHAR(v_wite_off_date,'%d/%m/%Y');
				
				
				
				IF v_credit_limit < 0 THEN
					LET v_credit_limit = 0;
				END IF;
				
				INSERT INTO ics_obligacion
					(identity_code, acc_customer_id, product_id, account_number, cust_branch_id, account_status, work_type, 
					reviewed, last_entrance_date, days_delinquent, balance, delinquency, original_balance, principal_balance, interest_balance, 
					principal_delinquent, interest_delinquent, over_limit, credit_limit, insurance_amount, collection_chargue, disputed_amount, provisioned_amount, interest_rate, 
					cycle_day, billing_day, payment_frequency, credit_score, behaviour_score, principal_delinquency_0, 
					principal_delinquency_1, principal_delinquency_2, principal_delinquency_3, principal_delinquency_4, 
					principal_delinquency_5, principal_delinquency_6, delinquency_0, delinquency_1, delinquency_2, 
					delinquency_3, delinquency_4, delinquency_5, delinquency_6, due_date_0, due_date_1, due_date_2, 
					due_date_3, due_date_4, due_date_5, due_date_6, opening_date, wite_off_date, payment_date, prescription_date, 
					expiration_date, last_rest_date, return_id, user_defined1, qualification, session_id, update_online, fecha_ejecucion, overdue_payments)
				VALUES
					(v_identity_code,v_acc_customer_id, v_product_id, v_account_number, v_cust_branch_id, c_account_status, v_work_type, 
					c_reviewed, v_last_entrance_date_char, v_days_delinquent, v_balance, v_delinquency, v_original_balance, v_principal_balance, v_interest_balance, 
					v_principal_delinquent, v_interest_delinquent, v_overlimit, v_credit_limit, v_insurance_amount, v_collection_chargue, v_disputed_amount, v_provisioned_amount, v_interest_rate, 
					v_cycle_day, v_billing_day, v_payment_frequency, v_credit_score, v_behaviour_score, v_principal_delinquency_0, 
					v_principal_delinquency_1, v_principal_delinquency_2, v_principal_delinquency_3, v_principal_delinquency_4, 
					v_principal_delinquency_5, v_principal_delinquency_6, v_delinquency_0, v_delinquency_1, v_delinquency_2, 
					v_delinquency_3, v_delinquency_4, v_delinquency_5, v_delinquency_6, v_due_date_0_char, v_due_date_1_char, v_due_date_2_char, 
					v_due_date_3_char, v_due_date_4_char, v_due_date_5_char, v_due_date_6_char, v_opening_date_char, char_v_wite_off_date, v_payment_date_char, v_prescription_date_char, 
					char_expiration_date, v_last_rest_date_char, v_return_id, v_user_defined1, v_qualification, v_session_id, v_update_online, c_fecha_ejecucion, v_overdue_payments);
				
				
				
				--IF v_valor_inicial = v_valor_final THEN
				--	EXIT FOREACH;
				--END IF;
				
				--LET v_valor_inicial = v_valor_inicial + 1;
				
				--LET v_valor_inicial = 
				
				LET iContador1 = iContador1 + 1;
				--DROP  TABLE ics_amortiza_credito;
				/*IF iContador1 >= 100000 THEN
					SELECT DBINFO("utc_to_datetime", sh_curtime) 
						INTO horaActual 
					FROM sysmaster:sysshmvals;
					INSERT INTO ics_tiempos (num_registro, hora, proceso) VALUES (iContador1, horaActual, 'CICLO_OBLIGACION');
					LET iContador1 = 0;
				END IF; */
				
				LET iContador = iContador + 1;
				
				IF iContador >= 5000 THEN
					COMMIT WORK;
					LET iContador = 0;
					BEGIN WORK;
				END IF; 
				
			END FOREACH;
			
			LET v_tiempo_obligaciones = 'FIN__OBLIGACION'||'_'||p_num_ejecucion;
			
			SELECT DBINFO("utc_to_datetime", sh_curtime) 
				INTO horaActual 
			FROM sysmaster:sysshmvals;
			INSERT INTO ics_tiempos (num_registro, hora, proceso) VALUES (iContador1, horaActual, v_tiempo_obligaciones);
			
			
		COMMIT WORK;
		
		LET v_transaccion = 0;
		
	/*CREATE INDEX informix.ics_obligacion_idx_fec_eje_2  ON "informix".ics_obligacion_2(fecha_ejecucion);
	
	CREATE INDEX informix.index_primerio ON "informix".ics_obligacion_2(identity_code, account_number, fecha_ejecucion);
	
	CREATE INDEX informix.ics_obligacion_idx_acc_2   ON "informix".ics_obligacion_2(account_number);
	
	CREATE INDEX informix.ics_obligacion_idx_user_defined_2  ON "informix".ics_obligacion_2(user_defined1);*/
		
		
		
		
	
		RETURN v_cod_ret;
			
	END;
END PROCEDURE
DOCUMENT
'Sistema		:	iCS',
'CreaciÃÂ³n		:	BanCoppel',
'Area			:	Sistemas Administrativos y Perifericos',
					'Gerencia de Mtto y Soporte IV',
'Coordinador	:	Norberto Corona Berruecos',
'FECHA			: 	Oct 2021',
'Requerimiento	:	RQM 09 596',
'VERSION		: 	1.0.0';

CREATE PROCEDURE "informix".sp_obtiene_info_rep_edc_tdc(v_num_credito CHAR(20), v_numcte CHAR(20), v_fecha_consul DATE, v_fecha_corte_edc DATE, v_sin_servicio CHAR(1),
														v_view_down	CHAR(1), v_no_view_down CHAR(1), v_si_serv_sin_view CHAR(1),v_canal CHAR(4)
														)

RETURNING 	--CHAR(255) AS Mensaje_Salida, 
			CHAR(5) AS Codigo_Retorno;
-- CANAL MAIL: 5000
-- CANAL APP : 5011
-- CANAL BPI : 5003

-- ************************************************************
-- *** DECLARACION DE VARIABLES INTERNAS DEL STORED PROCEDURE ***
-- ************************************************************
DEFINE iSqlErr                  INTEGER;     
DEFINE iIsamErr                 INTEGER; 
DEFINE cCodRet                  CHAR(5);
DEFINE cErrorInfo               VARCHAR(255); 
DEFINE cMensajeSalida			CHAR(150);
DEFINE v_x_mail                 CHAR(2);
DEFINE v_x_app_movil            CHAR(2);
DEFINE v_x_suc_web              CHAR(2);
DEFINE v_mto_comi               DECIMAL(18,2);
DEFINE v_mto_mora               DECIMAL(18,2);	
DEFINE v_fecha_hoy              DATE;
DEFINE v_ult_dia_mes            DATE;
DEFINE vCanal_aprob				CHAR(4);
DEFINE v_num_proceso			CHAR(4);

-- ************************************************************
-- *** INICIALIZACION DE VARIABLES ***
-- ************************************************************

LET iSqlErr                     = 0;
LET iIsamErr                    = 0;
LET cCodRet                     = '00000';
LET cErrorInfo                  = '';
LET cMensajeSalida              = 'PROCESO EXITOSO';
LET v_x_mail                    = '';
LET v_x_app_movil               = '';
LET v_x_suc_web                 = '';
LET v_mto_comi                  = 0;
LET v_mto_mora                  = 0;
LET v_fecha_hoy                 = DATE(1);
LET vCanal_aprob				= '';
LET v_num_proceso				= '0017';

-- ************************************************************
-- *** BLOQUE PRINCIPAL DEL STORED PROCEDURE ***
-- ************************************************************
BEGIN -- Inicio del bloque principal del SP

    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			DROP TABLE IF EXISTS tmp_canales;
			--LET cMensajeSalida = cErrorInfo;
			RETURN TRIM('00000');
			
       END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;  
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------	
--SET DEBUG FILE TO "/informix/David/RQM_10_1790/sp_obtiene_info_rep_edc_tdc.out";
--TRACE ON;

	SELECT CURRENT::DATE 
		INTO v_fecha_hoy 
	FROM systables WHERE tabid = 1;
	
	SELECT id_canal, cc_canal
	FROM bdinteg:"informix".si_canales WHERE id_canal IN('03','17')
	INTO TEMP tmp_canales WITH NO LOG;
	
	SELECT cc_canal INTO vCanal_aprob 
	FROM tmp_canales WHERE cc_canal = v_canal;

	--WHILE 1 = 1
	
	IF vCanal_aprob = v_canal THEN 
		IF v_fecha_hoy = v_fecha_consul THEN 
			IF NOT EXISTS (
				SELECT num_credito FROM "informix".sd_info_rep_edc 
				WHERE num_credito = v_num_credito AND fecha_consul = v_fecha_consul AND fecha_corte_edc = v_fecha_corte_edc AND canal = v_canal 
			  ) THEN
						 INSERT INTO "informix".sd_info_rep_edc
									(
									num_credito,					numcte,						fecha_consul,					fecha_corte_edc,				sin_servicio,
									view_down,						no_view_down,               si_serv_sin_view,				canal	    				
									)
							 VALUES(
									NVL(v_num_credito,''),			NVL(v_numcte,''),			NVL(v_fecha_consul,DATE(1)),	NVL(v_fecha_corte_edc,DATE(1)),	NVL(v_sin_servicio,''),			
									NVL(v_view_down,''),			NVL(v_no_view_down,''),     NVL(v_si_serv_sin_view,''),		NVL(v_canal,'')
									);
				--EXIT WHILE;
			ELSE 
				LET cMensajeSalida = 'Ya existe un registro durante el dia.';
				--EXIT WHILE;
			END IF;
		ELSE 
			LET cMensajeSalida = 'La fecha de consulta no es igual al dia de hoy.';
			LET cCodRet = '00001';
			--EXIT WHILE;
		END IF;
	ELSE 
		LET cMensajeSalida = 'El canal no es valido.';
		LET cCodRet = '00002';
		--EXIT WHILE;
	END IF;
	
	IF cCodRet != '00000' THEN
	
		INSERT INTO bdicred:sd_bitacora_mec (
					empresa, 		num_proceso, 	fecha_ejecucion, 	cod_ret, 	mensaje,
					user_insert, 	fecha_insert, 	hora_insert
					) 
			VALUES (
					'001',			v_num_proceso,	TODAY, 				cCodRet,	TRIM(cMensajeSalida) || ' Para el credito: ' || TRIM(v_num_credito) || ' con canal: ' || v_canal,
					user, 			TODAY,			CURRENT
					);
	END IF;
	DROP TABLE IF EXISTS tmp_canales;
			
	RETURN '00000';

END; 

END PROCEDURE;
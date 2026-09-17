CREATE PROCEDURE "informix".sp_nom_gen_mov_mes(i_fecha_generar DATE)
RETURNING CHAR(6);
-- DeclaraciÃÂ³n de las variables

    DEFINE cCodRet CHAR(6);
    DEFINE cInfoErr CHAR(100);

	DEFINE v_monto, v_Cur_Monto MONEY;
	
	DEFINE iSqlErr, iIsamErr, dia_festivo, existeDispCte, v_deposito1_7, v_deposito8_14, 
		v_deposito15_21, v_deposito22_31, v_deposito1_13, v_deposito14_27, v_deposito28_31,
		v_tot_movs_movhis, v_Num_Regs, v_Regs_X_Commit, v_mes_cerrado, v_existeMesAnt, v_Num_Serial INT;
	
	DEFINE v_fecha_primer_dia_mes, v_fecha_primer_dia_mes_ant, v_fecha_captura_pri_dia_mes, 
		v_fecha_ultimo_dia_mes, v_Cur_Fecha, v_fecha_folio_suc, v_fecha_captura DATE;
	
	Define v_Cur_Concepto VARCHAR(210);
	DEFINE v_desc_producto CHAR(40);
	DEFINE v_Cur_Clave_Rastreo, v_Cur_Folio_Suc VARCHAR(30);
	DEFINE v_cuenta, v_id_cuenta_empresa, v_bancoreferencia, v_Cur_Num_Cte, v_Cur_Id_Empresa_Nom CHAR(20);
	DEFINE v_num_tarjeta, v_Cur_Num_Tarjeta, V_Folio_Suc CHAR(16);
	DEFINE v_Clave_Rastreo_Pensionado CHAR(12);
	DEFINE v_numcte, v_id_empresa_nom, v_Cur_Cuenta, v_Cur_Id_Cuenta_Empresa CHAR(11);
	DEFINE v_Folio_Suc_Pensionado CHAR(10);
	DEFINE v_producto, V_Transacc, v_Cur_Transacc CHAR(4);
	DEFINE v_Empresa, v_Cur_Empresa, v_Like_Cadena CHAR(3);
	DEFINE v_dia_pago CHAR(2);
	DEFINE esInhabil, wBegin CHAR(1); --v_dig_verif_pen --INC 27 364
	
    --SET DEBUG FILE TO "/home/e90227195/TRACE/log_sp_nom_gen_mov_mes.sql";
	--TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
    
    BEGIN
    
        ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
            IF iSqlErr <> 0 THEN
				
				IF wBegin = 'S' THEN
				
					ROLLBACK WORK;
					
				END IF;
			
				TRUNCATE TABLE bdicheq:"informix".sc_temp_movs_nom;
			
                LET cCodRet = iSqlErr;
                RETURN cCodRet;
				
            END IF;
        END EXCEPTION;
		
		ON EXCEPTION IN (-255)
			LET wBegin = 'N';
		END EXCEPTION WITH RESUME;

		ON EXCEPTION IN (-535)
			LET wBegin = 'S';
			COMMIT WORK;
			BEGIN WORK;
		END EXCEPTION WITH RESUME;

		LET wBegin = 'N';
		LET esInhabil = '0';
		LET dia_festivo = 0;
		LET v_fecha_primer_dia_mes = MDY(MONTH(i_fecha_generar), 1, YEAR(i_fecha_generar));
		LET existeDispCte = 0;
		LET v_Num_Regs = 0;
		LET v_Regs_X_Commit = 1000;
		LET v_fecha_folio_suc = NULL;
			
		TRUNCATE TABLE bdicheq:"informix".sc_temp_movs_nom;
		
		/*
		INC 27 364 -- Se elimina el digito verifidor de pensionados de la cadena

	    SELECT TRIM(valor) INTO v_dig_verif_pen 
		FROM bdicheq:"informix".sc_param
		WHERE empresa = '001' 
			AND codparam = 'idpensionado';

		*/
		
		--Extraccion de dispersiones empleados grupo coppel
		
		FOREACH cur_movhis WITH HOLD FOR
			SELECT M.empresa, M.folio_suc, M.cuenta, M.monto_tot, M.transacc, M.num_tarjeta, M.fech_alt, M.referencia, M.num_serial
			INTO v_Cur_Empresa, v_Cur_Folio_Suc, v_Cur_Cuenta, v_Cur_Monto, v_Cur_Transacc, v_Cur_Num_Tarjeta, v_Cur_Fecha, v_Cur_Clave_Rastreo, v_Num_Serial
			FROM bdicheq:"informix".sc_movhis M
			LEFT JOIN bdicheq:"informix".sc_nom_mov_mes NM ON M.fech_alt = NM.fecha_oper 
																AND M.folio_suc = NM.folio_suc 
																AND M.referencia = NM.referencia
																AND M.num_serial = NM.num_serial
																AND M.transacc = NM.transacc
			WHERE M.fech_alt = i_fecha_generar
				AND M.cancelad = ''
				AND M.transacc IN ('0287', '0293')
				AND NM.folio_suc IS NULL
				
			IF v_Num_Regs = 0 THEN
			
				BEGIN WORK;
				LET wBegin = 'S';
			
			END IF;
			
			INSERT INTO bdicheq:"informix".sc_temp_movs_nom (empresa, folio_suc, cuenta, monto, transacc, num_tarjeta, fecha, clave_rastreo, num_serial)
			VALUES(v_Cur_Empresa, v_Cur_Folio_Suc, v_Cur_Cuenta, v_Cur_Monto, v_Cur_Transacc, v_Cur_Num_Tarjeta, v_Cur_Fecha, v_Cur_Clave_Rastreo, v_Num_Serial);
			
			LET v_Num_Regs = v_Num_Regs + 1;
			
			IF v_Num_Regs = v_Regs_X_Commit THEN
			
				COMMIT WORK;
				LET wBegin = 'N';
				
				LET v_Num_Regs = 0;
				
			END IF;
			
		END FOREACH
		
		IF wBegin = 'S' THEN
		
			COMMIT WORK;
			LET wBegin = 'N';
			LET v_Num_Regs = 0;
		
		END IF;
		
		SELECT COUNT(*) INTO v_tot_movs_movhis FROM bdicheq:"informix".sc_temp_movs_nom;
		
		--Si no encontramos movimientos en la movhis, buscamos en la movhis_old
		IF v_tot_movs_movhis = 0 THEN

			FOREACH cur_movhis WITH HOLD FOR
				SELECT M.empresa, M.folio_suc, M.cuenta, M.monto_tot, M.transacc, M.num_tarjeta, M.fech_alt, M.referencia, M.num_serial
				INTO v_Cur_Empresa, v_Cur_Folio_Suc, v_Cur_Cuenta, v_Cur_Monto, v_Cur_Transacc, v_Cur_Num_Tarjeta, v_Cur_Fecha, v_Cur_Clave_Rastreo, v_Num_Serial
				FROM bdicheq:"informix".sc_movhis_old M
				LEFT JOIN bdicheq:"informix".sc_nom_mov_mes NM ON M.fech_alt = NM.fecha_oper 
																AND M.folio_suc = NM.folio_suc 
																AND M.referencia = NM.referencia
																AND M.num_serial = NM.num_serial
																AND M.transacc = NM.transacc
				WHERE M.fech_alt = i_fecha_generar
					AND M.cancelad = ''
					AND M.transacc IN ('0287', '0293')
					AND NM.folio_suc IS NULL
					
				IF v_Num_Regs = 0 THEN
				
					BEGIN WORK;
					LET wBegin = 'S';
				
				END IF;
				
				INSERT INTO bdicheq:"informix".sc_temp_movs_nom (empresa, folio_suc, cuenta, monto, transacc, num_tarjeta, fecha, clave_rastreo, num_serial)
				VALUES(v_Cur_Empresa, v_Cur_Folio_Suc, v_Cur_Cuenta, v_Cur_Monto, v_Cur_Transacc, v_Cur_Num_Tarjeta, v_Cur_Fecha, v_Cur_Clave_Rastreo, v_Num_Serial);
				
				LET v_Num_Regs = v_Num_Regs + 1;
				
				IF v_Num_Regs = v_Regs_X_Commit THEN
				
					COMMIT WORK;
					LET wBegin = 'N';
					LET v_Num_Regs = 0;
					
				END IF;
				
			END FOREACH

			IF wBegin = 'S' THEN
			
				COMMIT WORK;
				LET wBegin = 'N';
				LET v_Num_Regs = 0;
			
			END IF;
		
		END IF;
		
		LET v_tot_movs_movhis = 0;
		SELECT COUNT(*) INTO v_tot_movs_movhis FROM bdicheq:"informix".sc_temp_movs_nom;
		
		--Si no encontramos movimientos en la movhis, buscamos en la movhis_old2
		IF v_tot_movs_movhis = 0 THEN
		
			FOREACH cur_movhis WITH HOLD FOR
				SELECT M.empresa, M.folio_suc, M.cuenta, M.monto_tot, M.transacc, M.num_tarjeta, M.fech_alt, M.referencia, M.num_serial
				INTO v_Cur_Empresa, v_Cur_Folio_Suc, v_Cur_Cuenta, v_Cur_Monto, v_Cur_Transacc, v_Cur_Num_Tarjeta, v_Cur_Fecha, v_Cur_Clave_Rastreo, v_Num_Serial
				FROM bdicheq:"informix".sc_movhis_old2 M
				LEFT JOIN bdicheq:"informix".sc_nom_mov_mes NM ON M.fech_alt = NM.fecha_oper 
																AND M.folio_suc = NM.folio_suc 
																AND M.referencia = NM.referencia
																AND M.num_serial = NM.num_serial
																AND M.transacc = NM.transacc
				WHERE M.fech_alt = i_fecha_generar
					AND M.cancelad = ''
					AND M.transacc IN ('0287', '0293')
					AND NM.folio_suc IS NULL
					
				IF v_Num_Regs = 0 THEN
				
					BEGIN WORK;
					LET wBegin = 'S';
				
				END IF;
				
				INSERT INTO bdicheq:"informix".sc_temp_movs_nom (empresa, folio_suc, cuenta, monto, transacc, num_tarjeta, fecha, clave_rastreo, num_serial)
				VALUES(v_Cur_Empresa, v_Cur_Folio_Suc, v_Cur_Cuenta, v_Cur_Monto, v_Cur_Transacc, v_Cur_Num_Tarjeta, v_Cur_Fecha, v_Cur_Clave_Rastreo, v_Num_Serial);
				
				LET v_Num_Regs = v_Num_Regs + 1;
				
				IF v_Num_Regs = v_Regs_X_Commit THEN
				
					COMMIT WORK;
					LET wBegin = 'N';
					LET v_Num_Regs = 0;
					
				END IF;
				
			END FOREACH
			
			IF wBegin = 'S' THEN
			
				COMMIT WORK;
				LET wBegin = 'N';
				LET v_Num_Regs = 0;
			
			END IF;
		
		END IF;
		
		FOREACH cur_histabono WITH HOLD FOR
			SELECT S.vchrclaverastreo, S.vchrfoliosuc, S.vchrconceptopago2, S.vchrnumctechq, S.vchrcuentachq,
				S.cvecesifbcoord, S.vchrcuentaord, S.mnyimporte, S.vchrtransacc, S.vchrctabenefemail, S.dtfechacaptura, S.intnumserial
			INTO v_Cur_Clave_Rastreo, v_Cur_Folio_Suc, v_Cur_Concepto, v_Cur_Num_Cte, v_Cur_Cuenta,
				v_Cur_Id_Empresa_Nom, v_Cur_Id_Cuenta_Empresa, v_Cur_Monto, v_Cur_Transacc, v_Cur_Num_Tarjeta, v_Cur_Fecha, v_Num_Serial
			FROM bdispei:"informix".tblhistabono S
			LEFT JOIN bdicheq:"informix".sc_nom_mov_mes NM ON S.dtfechacaptura = NM.fecha_oper 
																AND S.vchrfoliosuc = NM.folio_suc 
																AND S.vchrclaverastreo = NM.referencia 
																AND S.intnumserial = NM.num_serial
																AND S.vchrtransacc = NM.transacc
			WHERE S.dtfechavalor = i_fecha_generar
				AND S.vchrtransacc = '0273'
				AND NM.folio_suc IS NULL
				AND S.chrestatusenvio = 'L'
				AND S.mnyimporte > 0
				
			IF v_Num_Regs = 0 THEN
			
				BEGIN WORK;
				LET wBegin = 'S';
			
			END IF;
			
			INSERT INTO bdicheq:"informix".sc_temp_movs_nom (clave_rastreo, folio_suc, concepto, num_cte, 
				cuenta, id_empresa_nom, id_cuenta_empresa, monto, transacc, num_tarjeta, fecha, num_serial)
			VALUES(v_Cur_Clave_Rastreo, v_Cur_Folio_Suc, UPPER(v_Cur_Concepto), v_Cur_Num_Cte, v_Cur_Cuenta, v_Cur_Id_Empresa_Nom, 
				v_Cur_Id_Cuenta_Empresa, v_Cur_Monto, v_Cur_Transacc, v_Cur_Num_Tarjeta, v_Cur_Fecha, v_Num_Serial);
			
			LET v_Num_Regs = v_Num_Regs + 1;
			
			IF v_Num_Regs = v_Regs_X_Commit THEN
			
				COMMIT WORK;
				LET wBegin = 'N';
				LET v_Num_Regs = 0;
				
			END IF;
			
		END FOREACH
		
		IF wBegin = 'S' THEN
		
			COMMIT WORK;
			LET wBegin = 'N';
			LET v_Num_Regs = 0;
		
		END IF;
		
		FOREACH cur_empleados WITH HOLD FOR SELECT 
			M.folio_suc, C.num_cte, M.cuenta, '', '', '', C.producto, P.nombre, 
			M.monto, M.transacc, M.num_tarjeta, clave_rastreo, M.num_serial
		INTO
			V_Folio_Suc, v_numcte, v_cuenta, v_id_empresa_nom, v_id_cuenta_empresa, v_bancoreferencia, 
			v_producto, v_desc_producto, v_monto, v_transacc, v_num_tarjeta, v_Cur_Clave_Rastreo, v_Num_Serial
		FROM bdicheq:"informix".sc_temp_movs_nom AS M
		INNER JOIN bdicheq:"informix".sc_maechq C ON M.cuenta = C.cuenta AND M.empresa = C.empresa
		INNER JOIN bdicheq:"informix".sc_producto P ON C.producto = P.producto AND C.empresa = P.empresa
		INNER JOIN bdicheq:"informix".sc_nomina_prod_cte P_TP_CTE ON P.producto = P_TP_CTE.producto
		WHERE transacc IN ('0287', '0293')
			AND P_TP_CTE.clave_tipo = 'EGP' --Clave para empleados grupo coppel
			AND P_TP_CTE.estatus = '1'
			AND M.monto >= 0
		
			BEGIN WORK;
			LET wBegin = 'S';
			
			SELECT COUNT(*) INTO existeDispCte FROM bdicheq:"informix".sc_nom_disp_cte WHERE fecha_pago = v_fecha_primer_dia_mes AND cuenta = v_cuenta;

			IF existeDispCte = 0 THEN
			
				INSERT INTO bdicheq:"informix".sc_nom_disp_cte (numcte, cuenta, producto, desc_producto, fecha_pago, ingresos_emp, ingresos_porta, 
				ingresos_pen, ingresos_sdw, ingresos_netos, cadena_dia_dispersion, conteo_dias_pago, conteo_depositos)
				VALUES(v_numcte, v_cuenta, v_producto, v_desc_producto, v_fecha_primer_dia_mes, v_monto, 0, 0, 0, v_monto, '', 0, 1);
				
			ELSE
			
				UPDATE bdicheq:"informix".sc_nom_disp_cte
				SET	ingresos_netos = ingresos_netos + v_monto,
					ingresos_emp = ingresos_emp + v_monto,
					conteo_depositos = conteo_depositos + 1
				WHERE fecha_pago = v_fecha_primer_dia_mes AND cuenta = v_cuenta;
				
			END IF;
		
			INSERT INTO bdicheq:"informix".sc_nom_mov_mes (
				folio_suc, numcte, cuenta, id_empresa_nom, id_cuenta_empresa, bancoreferencia, 
				tipo_transaccion, producto, desc_producto, monto_tot, transacc, num_tarjeta, fecha_oper, referencia, fecha_origen, num_serial
			)VALUES(
				V_Folio_Suc,v_numcte, v_cuenta, v_id_empresa_nom, v_id_cuenta_empresa, v_bancoreferencia, 
				'EGP',	v_producto, v_desc_producto, v_monto, v_transacc, v_num_tarjeta, i_fecha_generar, v_Cur_Clave_Rastreo, i_fecha_generar, v_Num_Serial
			);
			
			COMMIT WORK;
			LET wBegin = 'N';
			
			
		END FOREACH
		
		LET v_fecha_primer_dia_mes_ant = v_fecha_primer_dia_mes - 1 UNITS MONTH;

		SELECT COUNT(*) INTO v_existeMesAnt
		FROM bdicheq:"informix".sc_bitacora_movnom 
		WHERE id_proceso = 'movimientos_mes' AND periodo >= v_fecha_primer_dia_mes_ant AND periodo < v_fecha_primer_dia_mes;

		SELECT COUNT(*) INTO v_mes_cerrado 
		FROM bdicheq:"informix".sc_bitacora_movnom 
		WHERE id_proceso = 'ingnetos' AND periodo = v_fecha_primer_dia_mes_ant AND fechahora_fin IS NOT NULL;
		
		FOREACH cur_portabilidad WITH HOLD FOR SELECT 
			S.folio_suc, S.num_cte, S.cuenta, S.id_empresa_nom, S.id_cuenta_empresa, B.vchrnombrecorto,	C.producto, P.nombre, 
			S.monto, S.transacc, S.num_tarjeta, S.fecha, MDY(MONTH(S.fecha), 1, YEAR(S.fecha)), S.clave_rastreo, S.num_serial
		INTO
			V_Folio_Suc, v_numcte, v_cuenta, v_id_empresa_nom, v_id_cuenta_empresa, v_bancoreferencia, v_producto, v_desc_producto, 
			v_monto, v_transacc, v_num_tarjeta, v_fecha_captura, v_fecha_captura_pri_dia_mes, v_Cur_Clave_Rastreo, v_Num_Serial
		FROM bdicheq:"informix".sc_temp_movs_nom S
		LEFT JOIN  bdispei:"informix".tblbanco B ON S.id_empresa_nom = B.cvecesif
		INNER JOIN bdicheq:"informix".sc_maechq C ON S.cuenta = C.cuenta
		INNER JOIN bdicheq:"informix".sc_producto P ON C.producto = P.producto AND C.empresa = P.empresa
		INNER JOIN bdicheq:"informix".sc_nomina_prod_cte P_TP_CTE ON P.producto = P_TP_CTE.producto
		WHERE S.transacc = '0273'
			AND P_TP_CTE.clave_tipo = 'EPB' --Clave para empleados portabilidad
			AND P_TP_CTE.estatus = '1'
			AND S.clave_rastreo LIKE '%NNNN%'
			AND S.monto > 0
			
			BEGIN WORK;
			LET wBegin = 'S';

			--Cuando fecha_captura es del mes anterior, se debe validar que el mes no este cerrado antes de actualizar la sc_nom_disp_cte
			IF v_fecha_primer_dia_mes_ant = v_fecha_captura_pri_dia_mes AND( v_mes_cerrado >= 1 OR v_existeMesAnt = 0 ) THEN

				COMMIT WORK;
				LET wBegin = 'N';
				CONTINUE FOREACH;

			END IF;
			
			SELECT COUNT(*) INTO existeDispCte FROM bdicheq:"informix".sc_nom_disp_cte WHERE fecha_pago = v_fecha_captura_pri_dia_mes AND cuenta = v_cuenta;
			
			IF existeDispCte = 0 THEN
			
				INSERT INTO bdicheq:"informix".sc_nom_disp_cte (numcte, cuenta, producto, desc_producto, fecha_pago, ingresos_emp, ingresos_porta, 
				ingresos_pen, ingresos_sdw, ingresos_netos, cadena_dia_dispersion, conteo_dias_pago, conteo_depositos)
				VALUES(v_numcte, v_cuenta, v_producto, v_desc_producto, v_fecha_captura_pri_dia_mes, 0, v_monto, 0, 0, v_monto, '', 0, 1);
				
			ELSE
			
				UPDATE bdicheq:"informix".sc_nom_disp_cte
				SET	ingresos_netos = ingresos_netos + v_monto,
					ingresos_porta = ingresos_porta + v_monto,
					conteo_depositos = conteo_depositos + 1
				WHERE fecha_pago = v_fecha_captura_pri_dia_mes AND cuenta = v_cuenta;
				
			END IF;
			
			INSERT INTO bdicheq:"informix".sc_nom_mov_mes (
				folio_suc, numcte, cuenta, id_empresa_nom, id_cuenta_empresa, bancoreferencia, tipo_transaccion, producto, 
				desc_producto, monto_tot, transacc, num_tarjeta, fecha_oper, referencia, fecha_origen, num_serial
			)VALUES(
				V_Folio_Suc, v_numcte, v_cuenta, v_id_empresa_nom, v_id_cuenta_empresa, v_bancoreferencia, 'EPB', v_producto, 
				v_desc_producto, v_monto, v_transacc, v_num_tarjeta, v_fecha_captura, v_Cur_Clave_Rastreo, i_fecha_generar, v_Num_Serial
			);
			
			COMMIT WORK;
			LET wBegin = 'N';
			
		END FOREACH;
		
		FOREACH cur_pensionados WITH HOLD FOR SELECT 
			S.folio_suc, S.num_cte, S.cuenta, S.id_empresa_nom, S.id_cuenta_empresa, B.vchrnombrecorto, C.producto, P.nombre, 
			S.monto, S.transacc, S.num_tarjeta, S.fecha, S.clave_rastreo, MDY(MONTH(S.fecha), 1, YEAR(S.fecha)), S.num_serial
		INTO
			V_Folio_Suc, v_numcte, v_cuenta, v_id_empresa_nom, v_id_cuenta_empresa, v_bancoreferencia, v_producto, v_desc_producto, 
			v_monto, v_transacc, v_num_tarjeta, v_fecha_captura, v_Cur_Clave_Rastreo, v_fecha_captura_pri_dia_mes, v_Num_Serial
		FROM bdicheq:"informix".sc_temp_movs_nom S
		LEFT JOIN  bdispei:"informix".tblbanco B ON S.id_empresa_nom = B.cvecesif
		INNER JOIN bdicheq:"informix".sc_maechq C ON S.cuenta = C.cuenta
		INNER JOIN bdicheq:"informix".sc_producto P ON C.producto = P.producto AND C.empresa = P.empresa
		INNER JOIN bdicheq:"informix".sc_nomina_prod_cte P_TP_CTE ON P.producto = P_TP_CTE.producto
		WHERE S.transacc = '0273'
			AND P_TP_CTE.clave_tipo = 'PEN' --Clave para empleados pensionados
			AND P_TP_CTE.estatus = '1'
			AND (concepto = 'IMSS PAGO DE NOMINA ORDINARIA' OR concepto LIKE '%ISSSTE%')
			AND S.monto > 0
		ORDER BY S.fecha
			
			BEGIN WORK;
			LET wBegin = 'S';

			--Cuando fecha_captura es del mes anterior, se debe validar que el mes no este cerrado antes de actualizar la sc_nom_disp_cte
			IF v_fecha_primer_dia_mes_ant = v_fecha_captura_pri_dia_mes AND( v_mes_cerrado >= 1 OR v_existeMesAnt = 0 ) THEN

				COMMIT WORK;
				LET wBegin = 'N';
				CONTINUE FOREACH;

			END IF;

			IF v_fecha_folio_suc IS NULL OR v_fecha_folio_suc <> v_fecha_captura THEN
				
				LET esInhabil = '0';
				LET v_fecha_folio_suc = v_fecha_captura;
				LET v_Clave_Rastreo_Pensionado = '60' || CASE WHEN MONTH(v_fecha_captura) = 12 THEN YEAR(v_fecha_captura) + 1 ELSE YEAR(v_fecha_captura) END  || '19098%';
				LET v_fecha_ultimo_dia_mes = v_fecha_captura_pri_dia_mes + 1 UNITS MONTH - 1 UNITS DAY;
				
				WHILE esInhabil <> '1'
				
					SELECT COUNT(*) INTO dia_festivo FROM bdinteg:"informix".si_feriado WHERE fecha = v_fecha_ultimo_dia_mes AND laborable = 'N';
					
					IF dia_festivo >= 1 OR TO_CHAR(v_fecha_ultimo_dia_mes, "%A") IN ('Saturday', 'Sunday') THEN
					
						LET v_fecha_ultimo_dia_mes = v_fecha_ultimo_dia_mes - 1 UNITS DAY;
						
					ELSE
					
						LET esInhabil = '1';
					
					END IF;
				
				END WHILE;

				--INC 27 364 Se elimina el digito verifidor de pensionados de la cadena  SPEI0227
				--LET v_Folio_Suc_Pensionado = 'SPEI' || TO_CHAR(v_fecha_ultimo_dia_mes, '%m%d') || v_dig_verif_pen || '%';
				LET v_Folio_Suc_Pensionado = 'SPEI' || TO_CHAR(v_fecha_ultimo_dia_mes, '%m%d') || '%';

			END IF;
			
			IF V_Folio_Suc NOT LIKE v_Folio_Suc_Pensionado OR v_Cur_Clave_Rastreo NOT LIKE v_Clave_Rastreo_Pensionado THEN
				
				COMMIT WORK;
				LET wBegin = 'N';
				CONTINUE FOREACH;

			END IF;
			
			SELECT COUNT(*) INTO existeDispCte FROM bdicheq:"informix".sc_nom_disp_cte WHERE fecha_pago = v_fecha_captura_pri_dia_mes AND cuenta = v_cuenta;
			
			IF existeDispCte = 0 THEN
			
				INSERT INTO bdicheq:"informix".sc_nom_disp_cte (numcte, cuenta, producto, desc_producto, fecha_pago, ingresos_emp, ingresos_porta, 
				ingresos_pen, ingresos_sdw, ingresos_netos, cadena_dia_dispersion, conteo_dias_pago, conteo_depositos)
				VALUES(v_numcte, v_cuenta, v_producto, v_desc_producto, v_fecha_captura_pri_dia_mes, 0, 0, v_monto, 0, v_monto, '', 0, 1);
				
			ELSE
			
				UPDATE bdicheq:"informix".sc_nom_disp_cte
				SET	ingresos_netos = ingresos_netos + v_monto,
					ingresos_pen = ingresos_pen + v_monto,
					conteo_depositos = conteo_depositos + 1
				WHERE fecha_pago = v_fecha_captura_pri_dia_mes AND cuenta = v_cuenta;
				
			END IF;
			
			INSERT INTO bdicheq:"informix".sc_nom_mov_mes (
				folio_suc,	numcte, cuenta, id_empresa_nom, id_cuenta_empresa, bancoreferencia, tipo_transaccion, producto, 
				desc_producto, monto_tot, transacc, num_tarjeta, fecha_oper, referencia, fecha_origen, num_serial
			)VALUES(
				V_Folio_Suc, v_numcte, v_cuenta, v_id_empresa_nom, v_id_cuenta_empresa, v_bancoreferencia, 'PEN', v_producto, 
				v_desc_producto, v_monto, v_transacc, v_num_tarjeta, v_fecha_captura, v_Cur_Clave_Rastreo, i_fecha_generar, v_Num_Serial
			);
			
			COMMIT WORK;
			LET wBegin = 'N';
			
		END FOREACH;
		
		LET v_fecha_folio_suc = NULL;
		
		FOREACH cur_shadow WITH HOLD FOR SELECT 
			S.folio_suc, S.num_cte, S.cuenta, S.id_empresa_nom, S.id_cuenta_empresa, B.vchrnombrecorto, C.producto, P.nombre, 
			S.monto, S.transacc, S.num_tarjeta, S.fecha, S.clave_rastreo, MDY(MONTH(S.fecha), 1, YEAR(S.fecha)), S.num_serial
		INTO
			V_Folio_Suc, v_numcte, v_cuenta, v_id_empresa_nom, v_id_cuenta_empresa, v_bancoreferencia, v_producto, v_desc_producto, 
			v_monto, v_transacc, v_num_tarjeta, v_fecha_captura, v_Cur_Clave_Rastreo, v_fecha_captura_pri_dia_mes, v_Num_Serial
		FROM bdicheq:"informix".sc_temp_movs_nom S
		LEFT JOIN  bdispei:"informix".tblbanco B ON S.id_empresa_nom = B.cvecesif
		INNER JOIN bdicheq:"informix".sc_maechq C ON S.cuenta = C.cuenta
		INNER JOIN bdicheq:"informix".sc_producto P ON C.producto = P.producto AND C.empresa = P.empresa
		INNER JOIN bdicheq:"informix".sc_nomina_prod_cte P_TP_CTE ON P.producto = P_TP_CTE.producto
		WHERE S.transacc = '0273'
			AND P_TP_CTE.clave_tipo = 'SDW' --Clave para empleados nomina shadow
			AND P_TP_CTE.estatus = '1'
			AND ( concepto LIKE '%NOMINA%' OR concepto LIKE '%SUELDO%')
			AND clave_rastreo NOT LIKE '%NNNN%'
			AND (concepto <> 'IMSS PAGO DE NOMINA ORDINARIA' AND concepto NOT LIKE '%ISSSTE%')
			AND S.monto > 0
		ORDER BY S.fecha
			
			BEGIN WORK;
			LET wBegin = 'S';

			--Cuando fecha_captura es del mes anterior, se debe validar que el mes no este cerrado antes de actualizar la sc_nom_disp_cte
			IF v_fecha_primer_dia_mes_ant = v_fecha_captura_pri_dia_mes AND( v_mes_cerrado >= 1 OR v_existeMesAnt = 0 ) THEN

				COMMIT WORK;
				LET wBegin = 'N';
				CONTINUE FOREACH;

			END IF;
			
			IF v_fecha_folio_suc IS NULL OR v_fecha_folio_suc <> v_fecha_captura THEN

				LET esInhabil = '0';
				LET v_fecha_folio_suc = v_fecha_captura;
				LET v_Clave_Rastreo_Pensionado = '60' || CASE WHEN MONTH(v_fecha_captura) = 12 THEN YEAR(v_fecha_captura) + 1 ELSE YEAR(v_fecha_captura) END  || '19098%';
				LET v_fecha_ultimo_dia_mes = v_fecha_captura_pri_dia_mes + 1 UNITS MONTH - 1 UNITS DAY;
				
				WHILE esInhabil <> '1'
				
					SELECT COUNT(*) INTO dia_festivo FROM bdinteg:"informix".si_feriado WHERE fecha = v_fecha_ultimo_dia_mes AND laborable = 'N';
					
					IF dia_festivo >= 1 OR TO_CHAR(v_fecha_ultimo_dia_mes, "%A") IN ('Saturday', 'Sunday') THEN
					
						LET v_fecha_ultimo_dia_mes = v_fecha_ultimo_dia_mes - 1 UNITS DAY;
						
					ELSE
					
						LET esInhabil = '1';
					
					END IF;
				
				END WHILE;
				
				--INC 27 364 Se elimina el digito verifidor de pensionados de la cadena
				--LET v_Folio_Suc_Pensionado = 'SPEI' || TO_CHAR(v_fecha_ultimo_dia_mes, '%m%d') || v_dig_verif_pen || '%'; 
				LET v_Folio_Suc_Pensionado = 'SPEI' || TO_CHAR(v_fecha_ultimo_dia_mes, '%m%d') || '%';

			END IF;

			IF V_Folio_Suc LIKE v_Folio_Suc_Pensionado AND v_Cur_Clave_Rastreo LIKE v_Clave_Rastreo_Pensionado THEN

				COMMIT WORK;
				LET wBegin = 'N';
				CONTINUE FOREACH;

			END IF;
			
			SELECT COUNT(*) INTO existeDispCte FROM bdicheq:"informix".sc_nom_disp_cte WHERE fecha_pago = v_fecha_captura_pri_dia_mes AND cuenta = v_cuenta;
			
			IF existeDispCte = 0 THEN
			
				INSERT INTO bdicheq:"informix".sc_nom_disp_cte (numcte, cuenta, producto, desc_producto, fecha_pago, ingresos_emp, ingresos_porta,
				ingresos_pen, ingresos_sdw, ingresos_netos, cadena_dia_dispersion, conteo_dias_pago, conteo_depositos)
				VALUES(v_numcte, v_cuenta, v_producto, v_desc_producto, v_fecha_captura_pri_dia_mes, 0, 0, 0, v_monto, v_monto, '', 0, 1);
				
			ELSE
			
				UPDATE bdicheq:"informix".sc_nom_disp_cte
				SET	ingresos_netos = ingresos_netos + v_monto,
					ingresos_sdw = ingresos_sdw + v_monto,
					conteo_depositos = conteo_depositos + 1
				WHERE fecha_pago = v_fecha_captura_pri_dia_mes AND cuenta = v_cuenta;
				
			END IF;
			
			INSERT INTO bdicheq:"informix".sc_nom_mov_mes (
				folio_suc,	numcte, cuenta, id_empresa_nom, id_cuenta_empresa, bancoreferencia, tipo_transaccion, producto, 
				desc_producto, monto_tot, transacc, num_tarjeta, fecha_oper, referencia, fecha_origen, num_serial
			)VALUES(
				V_Folio_Suc, v_numcte, v_cuenta, v_id_empresa_nom, v_id_cuenta_empresa, v_bancoreferencia, 'SDW', v_producto, 
				v_desc_producto, v_monto, v_transacc, v_num_tarjeta, v_fecha_captura, v_Cur_Clave_Rastreo, i_fecha_generar, v_Num_Serial
			);
			
			COMMIT WORK;
			LET wBegin = 'N';
			
		END FOREACH;

		BEGIN WORK;

		FOREACH cur_movimientos WITH HOLD FOR 
		SELECT DISTINCT 
			fecha_oper, MDY(MONTH(fecha_oper), 1, YEAR(fecha_oper)) 
		INTO 
			v_Cur_Fecha, v_fecha_captura_pri_dia_mes 
		FROM 
			bdicheq:"informix".sc_nom_mov_mes 
		WHERE 
			fecha_origen = i_fecha_generar 
		ORDER BY 
			fecha_oper

			LET v_dia_pago = DAY(v_Cur_Fecha);
			LET v_Like_Cadena = '%' || v_dia_pago;
			
			LET v_deposito1_7 = CASE WHEN v_dia_pago BETWEEN 1  AND 7 THEN 1 ELSE 0 END;
			LET v_deposito8_14 = CASE WHEN v_dia_pago BETWEEN 8  AND 14 THEN 1 ELSE 0 END;
			LET v_deposito15_21 = CASE WHEN v_dia_pago BETWEEN 15 AND 21 THEN 1 ELSE 0 END;
			LET v_deposito22_31 = CASE WHEN v_dia_pago BETWEEN 22 AND 31 THEN 1 ELSE 0 END;
			LET v_deposito1_13 = CASE WHEN v_dia_pago BETWEEN 1  AND 13 THEN 1 ELSE 0 END;
			LET v_deposito14_27 = CASE WHEN v_dia_pago BETWEEN 14 AND 27 THEN 1 ELSE 0 END;
			LET v_deposito28_31 = CASE WHEN v_dia_pago BETWEEN 28 AND 31 THEN 1 ELSE 0 END;

			UPDATE bdicheq:"informix".sc_nom_disp_cte
			SET cadena_dia_dispersion = CASE WHEN cadena_dia_dispersion = '' THEN v_dia_pago ELSE TRIM(cadena_dia_dispersion) || '-' || v_dia_pago END,
				deposito1_7 	= CASE WHEN deposito1_7 IS NULL OR (deposito1_7 	= 0 AND v_deposito1_7 	= 1) THEN v_deposito1_7 	ELSE deposito1_7 	END,
				deposito8_14 	= CASE WHEN deposito1_7 IS NULL OR (deposito8_14 	= 0 AND v_deposito8_14 	= 1) THEN v_deposito8_14 	ELSE deposito8_14 	END,
				deposito15_21 	= CASE WHEN deposito1_7 IS NULL OR (deposito15_21 	= 0 AND v_deposito15_21 = 1) THEN v_deposito15_21 	ELSE deposito15_21 	END,
				deposito22_31 	= CASE WHEN deposito1_7 IS NULL OR (deposito22_31 	= 0 AND v_deposito22_31 = 1) THEN v_deposito22_31 	ELSE deposito22_31 	END,
				deposito1_13 	= CASE WHEN deposito1_7 IS NULL OR (deposito1_13 	= 0 AND v_deposito1_13 	= 1) THEN v_deposito1_13 	ELSE deposito1_13 	END,
				deposito14_27 	= CASE WHEN deposito1_7 IS NULL OR (deposito14_27 	= 0 AND v_deposito14_27 = 1) THEN v_deposito14_27 	ELSE deposito14_27 	END,
				deposito28_31 	= CASE WHEN deposito1_7 IS NULL OR (deposito28_31 	= 0 AND v_deposito28_31 = 1) THEN v_deposito28_31 	ELSE deposito28_31 	END,
				conteo_dias_pago = conteo_dias_pago	+ 1
			WHERE fecha_pago = v_fecha_captura_pri_dia_mes AND cuenta IN ( 
				SELECT DISTINCT cuenta FROM bdicheq:"informix".sc_nom_mov_mes 
				WHERE fecha_origen = i_fecha_generar AND fecha_oper = v_Cur_Fecha
			) AND cadena_dia_dispersion NOT LIKE v_Like_Cadena;

		END FOREACH

		COMMIT WORK;
		
		--UPDATE STATISTICS HIGH FOR TABLE bdicheq:"informix".sc_nom_mov_mes;
		--UPDATE STATISTICS HIGH FOR TABLE bdicheq:"informix".sc_nom_disp_cte;
		TRUNCATE TABLE bdicheq:"informix".sc_temp_movs_nom;
		
		LET cCodRet = '000000';
		LET cInfoErr = '';
        
    END;
    
    RETURN cCodRet;
    
END PROCEDURE
DOCUMENT
'_____________________________________________________________________________________________________________________________________',
'CREADO:      	Jesus Adrian Diaz Orozco',
'FECHA:       	23 de diciembre de 2024',
'DESCRIPCION: 	Generar el concentrado de todos las dispersiones de los distintos tipos de clientes nomina (Empleado de GC, ',
'				Portabilidad, Pensionado y Shadow) de bancoppel en una unica tabla de movimientos de nomina					',
'Retorno: 		000000  Proceso Exitoso',
'_____________________________________________________________________________________________________________________________________',
'MODIFICADO: 	Jesus Adrian Diaz Orozco',
'FECHA: 		04 de Junio de 2025',
'DESCRIPCION: 	Se atienden las observaciones del equipo de captacion previo a la liberaciÃ³n, se agrega tabla fisica para 	',
'				almacenamiento de movimientos, TRUNCATE y se agrega manejo de transacciones al insertar en la tabla tmp		',
'_____________________________________________________________________________________________________________________________________',
'MODIFICADO: 	Jesus Adrian Diaz Orozco',
'FECHA: 		15 de Octubre de 2025',
'DESCRIPCION: 	Se atiende incidencia Asimetrias, Se modifica la fecha que se guarda de la tblhistabono al momento de obtener los 	',
'				movimientos, guardando la fechacaptura para utilizarla como fecha del movimiento y para hacer los calculos en		',
'				el foliosuc y clave rastreo para los pensionados, ademas se agrega la consulta a la sc_movhis_old2 para obtener los	',
'				registros mas antiguos																								',
'_____________________________________________________________________________________________________________________________________',
'MODIFICADO: 	Jesus Adrian Diaz Orozco',
'FECHA: 		20 de Noviembre de 2025',
'DESCRIPCION: 	Se modifica numero de registros por commit a 1000',
'_____________________________________________________________________________________________________________________________________',
'MODIFICADO: 	Jesus Adrian Diaz Orozco',
'FECHA: 		29 de Febrero de 2026',
'DESCRIPCION: 	INC 27 364 - Se agrega num_serial y transacc como columnas identificadoras de movimientos, con el objetivo de evitar',
'							la incorrecta omision de movimientos ya procesados, ademas se elimina el digito verificador de pensionados';

CREATE PROCEDURE "informix".sp_nom_gendata_disp(p_periodo CHAR(6))
RETURNING CHAR(6)
	
	DEFINE	c_producto, c_transacc CHAR(4);
	DEFINE	cCodRet CHAR(6);
	DEFINE	c_tipo_transaccion CHAR(3);
	DEFINE 	c_folio_suc, c_num_tarjeta CHAR(16);
	DEFINE	c_numcte, c_bancoreferencia, c_periodicidad, c_cuenta, c_id_empresa_nom, c_id_cuenta_empresa CHAR(20);
	DEFINE  vc_referencia VARCHAR(30);
	DEFINE	c_desc_producto CHAR(40);
	DEFINE	c_cadena_dia_dispersion VARCHAR(85);
	DEFINE	vInfoErr VARCHAR(100);
	DEFINE	m_ingresos_emp,	m_ingresos_porta, m_ingresos_pen, m_ingresos_sdw, m_ingresos_netos, c_ingreso_ajustado, m_monto_tot MONEY;
	DEFINE	iIsamErr, iSqlErr, i_dia_proceso_mensual, i_conteo_dias_pago, i_conteo_depositos, 
			i_deposito1_7, i_deposito8_14, i_deposito15_21, i_deposito22_31, i_deposito1_13, i_deposito14_27, i_deposito28_31,
			i_dias_tope_movs_nom, v_Regs_X_Commit, v_Num_Regs, i_num_serial, i_meses_respaldar_movsnom INT;
	DEFINE	c_fecha_pago, dt_fecha_ant, dt_fecha_aux, dt_ult_per_proc, dt_fecha_generar, 
			dt_fec_tope_movs, dt_fecha_oper, dt_fecha_origen, dt_fec_max_movsnom_old, dt_fec_pri_dia_mes DATE;
	DEFINE	b_enTransaccion BOOLEAN;
	DEFINE dt_fecha_bitacora_ini, dt_fecha_bitacora_fin DATETIME YEAR TO SECOND;

	
	 --SET DEBUG FILE TO "/home/e10001202/jquintana/sp_nom_gendata_disp.log";
	 --TRACE ON;
	
	--_______________________________________________________________________________________________________________________________________
	-- Se ejecuta desde el shell de Control-M [pro_206_37_124_nom_gendata_disp.sh]
	-- Se ejecuta desde el shell de Opcion de menu [1219]-[pro_1219_nom_gendata_disp.sh]
	--_______________________________________________________________________________________________________________________________________
	-- Desde Control-M se detona con parametro vacio "".
	--		Ej. [EXECUTE PROCEDURE 'informix'.sp_nom_gendata_disp("");]
	--_______________________________________________________________________________________________________________________________________
	-- Desde opcion de menu se debe colocar el archivo TXT pro_1219_nom_gendata_disp_periodos.txt en la ruta /ifxsif01/scripts 
	-- con un periodo en formato "YYYYMM" a ejecutar por cada linea
	-- 		Ej. fichero pro_1219_nom_gendata_disp_periodos.txt
	--			202410
	--			202411
	--			202412
	--			202501
	--_______________________________________________________________________________________________________________________________________
	-- Para una ejecucion especifica de un periodo, el parametro p_periodo debe llevar el formato "YYYYMM"
	-- 		Ej. [EXECUTE PROCEDURE 'informix'.sp_nom_gendata_disp("202501");] para el periodo de enero 2025
	--_______________________________________________________________________________________________________________________________________
	
	BEGIN
		
		ON EXCEPTION SET iSqlErr, iIsamErr, vInfoErr
			IF iSqlErr <> 0 THEN
				
				IF b_enTransaccion = 't' THEN
					ROLLBACK WORK;
				END IF;
				
				LET cCodRet = iSqlErr;
				
				RETURN cCodRet;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		LET cCodRet = '000000';
		LET b_enTransaccion = 'f';
		LET v_Regs_X_Commit = 1000;
		LET v_Num_Regs = 0;
		
		-- Se toma el dia en que se realiza la ejecucion mensual
		-- Si el valor del parametro esta vacio, se toma el 6 por default
		SELECT NVL(valor::INT, 6)
		INTO i_dia_proceso_mensual
		FROM "informix".sc_param
		WHERE codparam = 'DiaProcesoMensualNom';

		-- Se toma el numero de dias de desfase para generar los movimientos
		-- Si el valor del parametro esta vacio, se toma el 5 por default
		SELECT NVL(valor::INT, 5)
		INTO i_dias_tope_movs_nom
		FROM "informix".sc_param
		WHERE codparam = 'DiasTopeMovsNom';

		SELECT NVL(valor::INT, 1)	
		INTO i_meses_respaldar_movsnom
		FROM "informix".sc_param
		WHERE codparam = 'MesesMovsNomOld';

		-- Se toma la fecha del dia que se cerro, asi como el mes inmediato anterior de la misma
		SELECT fecha_ant, pri_dia_mes
		INTO dt_fecha_ant, dt_fec_pri_dia_mes
		FROM "informix".sc_fechas
		WHERE empresa = '001';

		LET dt_fec_tope_movs = dt_fecha_ant - i_dias_tope_movs_nom UNITS DAY;
		
		-- Se toma la fecha de la ultima ejecucion exitosa del subproceso [movimientos_mes]
		-- Si no existe ninguna ejecucion exitosa para el subproceso [movimientos_mes], se ejecutara por primera vez el con fecha del dia anterior
		SELECT NVL(MAX(periodo + 1 UNITS DAY), dt_fec_tope_movs)
		INTO dt_ult_per_proc
		FROM "informix".sc_bitacora_movnom
		WHERE id_proceso = 'movimientos_mes' AND fechahora_fin IS NOT NULL;
		
		-- Se recorre desde la ultima ejecucion exitosa del subproceso [movimientos_mes] hasta la fecha del dia que cerro
		WHILE dt_ult_per_proc <= dt_fec_tope_movs
			
			SELECT DBINFO('utc_to_datetime', sh_curtime) 
			INTO dt_fecha_bitacora_ini 
			FROM sysmaster:sysshmvals;
			
			-- Ejecucion de subproceso [movimientos_mes] {
			INSERT INTO "informix".sc_bitacora_movnom (id_proceso, periodo, fechahora_inicio, fechahora_fin)
				VALUES ('movimientos_mes', dt_ult_per_proc, dt_fecha_bitacora_ini, NULL);
			
			EXECUTE PROCEDURE "informix".sp_nom_gen_mov_mes(dt_ult_per_proc) INTO cCodRet;
			
			IF cCodRet <> '000000' THEN
				RETURN cCodRet;
				
			END IF;
			
			SELECT DBINFO('utc_to_datetime', sh_curtime) 
			INTO dt_fecha_bitacora_fin 
			FROM sysmaster:sysshmvals;
			
			UPDATE "informix".sc_bitacora_movnom SET
				fechahora_fin = dt_fecha_bitacora_fin
			WHERE id_proceso = 'movimientos_mes' AND periodo = dt_ult_per_proc;
			-- } fin de ejecucion de subproceso [movimientos_mes]
			
			LET dt_ult_per_proc = dt_ult_per_proc + 1 UNITS DAY;
			
		END WHILE;
		
		IF DAY(dt_fecha_ant) = i_dia_proceso_mensual OR p_periodo <> "" THEN

			LET dt_fecha_generar = dt_fec_pri_dia_mes - 1 UNITS MONTH;
		
			IF p_periodo <> "" THEN
				LET dt_fecha_generar = MDY(SUBSTR(p_periodo, 5, 2), 1, SUBSTR(p_periodo, 1, 4));
			END IF;
			
			SELECT DBINFO('utc_to_datetime', sh_curtime) 
			INTO dt_fecha_bitacora_ini 
			FROM sysmaster:sysshmvals;
			
			-- Ejecucion de subproceso [ingnetos] {
			INSERT INTO "informix".sc_bitacora_movnom (id_proceso, periodo, fechahora_inicio, fechahora_fin)
				VALUES ('ingnetos', dt_fecha_generar, dt_fecha_bitacora_ini, NULL);
			
			EXECUTE PROCEDURE "informix".sp_nom_gen_ingnetos(dt_fecha_generar) INTO cCodRet;
			
			IF cCodRet <> '000000' THEN
				RETURN cCodRet;
			END IF;
			
			SELECT DBINFO('utc_to_datetime', sh_curtime) 
			INTO dt_fecha_bitacora_fin 
			FROM sysmaster:sysshmvals;
			
			UPDATE "informix".sc_bitacora_movnom SET 
				fechahora_fin = dt_fecha_bitacora_fin
			WHERE id_proceso = 'ingnetos' AND periodo = dt_fecha_generar;
			-- } fin de ejecucion de subproceso [ingnetos]
			
			SELECT DBINFO('utc_to_datetime', sh_curtime) 
			INTO dt_fecha_bitacora_ini 
			FROM sysmaster:sysshmvals;
			
			-- Ejecucion de subproceso [ingajustado] {
			INSERT INTO "informix".sc_bitacora_movnom (id_proceso, periodo, fechahora_inicio, fechahora_fin)
				VALUES ('ingajustado', dt_fecha_generar, dt_fecha_bitacora_ini, NULL);
			
			EXECUTE PROCEDURE "informix".sp_nom_gen_ing_ajustado(dt_fecha_generar) INTO cCodRet;
			
			IF cCodRet <> '000000' THEN
				RETURN cCodRet;
			END IF;
			
			SELECT DBINFO('utc_to_datetime', sh_curtime) 
			INTO dt_fecha_bitacora_fin 
			FROM sysmaster:sysshmvals;
			
			UPDATE "informix".sc_bitacora_movnom SET
				fechahora_fin = dt_fecha_bitacora_fin
			WHERE id_proceso = 'ingajustado' AND periodo = dt_fecha_generar;
			-- } fin de ejecucion de subproceso [ingajustado]
			
			-- Depuracion de tabla de movimientos para el periodo que se ejecuta			
			FOREACH cursor_mov_mes WITH HOLD FOR
			SELECT 
				folio_suc, 			numcte, 			cuenta, 		id_empresa_nom, 	id_cuenta_empresa, 
				bancoreferencia, 	tipo_transaccion, 	producto, 		desc_producto, 		monto_tot, 
				transacc, 			num_tarjeta, 		fecha_oper, 	referencia, 		fecha_origen,		num_serial
			INTO
				c_folio_suc, 		c_numcte, 			c_cuenta, 		c_id_empresa_nom, 	c_id_cuenta_empresa, 
				c_bancoreferencia, c_tipo_transaccion,	c_producto, 	c_desc_producto, 	m_monto_tot, 
				c_transacc, 		c_num_tarjeta, 		dt_fecha_oper, 	vc_referencia, 		dt_fecha_origen,	i_num_serial
			FROM informix.sc_nom_mov_mes
			WHERE fecha_oper >= dt_fecha_generar AND fecha_oper < dt_fecha_generar + 1 UNITS MONTH
					
					IF v_Num_Regs = 0 THEN
					
						BEGIN WORK;
						LET b_enTransaccion = 't';
					
					END IF;

					INSERT INTO "informix".sc_nom_mov_mes_old(
						folio_suc, 			numcte, 			cuenta, 		id_empresa_nom, 	id_cuenta_empresa, 
						bancoreferencia, 	tipo_transaccion, 	producto, 		desc_producto, 		monto_tot, 
						transacc, 			num_tarjeta, 		fecha_oper, 	referencia, 		fecha_origen,		num_serial
					)VALUES(
						c_folio_suc, 		c_numcte, 			c_cuenta, 		c_id_empresa_nom, 	c_id_cuenta_empresa, 
						c_bancoreferencia, 	c_tipo_transaccion,	c_producto, 	c_desc_producto, 	m_monto_tot, 
						c_transacc, 		c_num_tarjeta, 		dt_fecha_oper, 	vc_referencia, 		dt_fecha_origen,	i_num_serial
					);

					DELETE FROM "informix".sc_nom_mov_mes 
					WHERE fecha_oper 		= dt_fecha_oper 
							AND folio_suc 	= c_folio_suc
							AND transacc 	= c_transacc
							AND num_serial 	= i_num_serial
							AND referencia	= vc_referencia;
					
					LET v_Num_Regs = v_Num_Regs + 1;

					IF v_Num_Regs = v_Regs_X_Commit THEN
					
						COMMIT WORK;
						LET b_enTransaccion = 'f';
						LET v_Num_Regs = 0;
						
					END IF;

			END FOREACH
			
			IF b_enTransaccion = 't' THEN
			
				COMMIT WORK;
				LET b_enTransaccion = 'f';
				LET v_Num_Regs = 0;
			
			END IF;

			LET dt_fec_max_movsnom_old = dt_fec_pri_dia_mes - i_meses_respaldar_movsnom UNITS MONTH;

			--Depuracion de sc_nom_mov_mes_old
			DELETE FROM informix.sc_nom_mov_mes_old WHERE fecha_oper < dt_fec_max_movsnom_old;
			
			LET dt_fecha_aux = MDY(MONTH(dt_fecha_generar - 1 UNITS YEAR), 1, YEAR(dt_fecha_generar - 1 UNITS YEAR));
			
			-- Respalda al historico la informacion con 13 meses o mas de antiguedad
			FOREACH cursor_disp_cte WITH HOLD FOR
			SELECT
				numcte, cuenta, producto, desc_producto,
				id_empresa_nom, id_cuenta_empresa, bancoreferencia, fecha_pago,
				ingresos_emp, ingresos_porta, ingresos_pen, ingresos_sdw, ingresos_netos,
				tipo_transaccion, periodicidad, ingreso_ajustado, cadena_dia_dispersion,
				conteo_dias_pago, conteo_depositos, deposito1_7, deposito8_14,
				deposito15_21, deposito22_31, deposito1_13, deposito14_27, deposito28_31				
			INTO
				c_numcte, c_cuenta, c_producto, c_desc_producto,
				c_id_empresa_nom, c_id_cuenta_empresa, c_bancoreferencia, c_fecha_pago,
				m_ingresos_emp, m_ingresos_porta, m_ingresos_pen, m_ingresos_sdw, m_ingresos_netos,
				c_tipo_transaccion, c_periodicidad, c_ingreso_ajustado, c_cadena_dia_dispersion,
				i_conteo_dias_pago, i_conteo_depositos, i_deposito1_7, i_deposito8_14,
				i_deposito15_21, i_deposito22_31, i_deposito1_13, i_deposito14_27, i_deposito28_31
			FROM
				"informix".sc_nom_disp_cte
			WHERE
				fecha_pago <= dt_fecha_aux
					
					IF v_Num_Regs = 0 THEN
					
						BEGIN WORK;
						LET b_enTransaccion = 't';
					
					END IF;
					
					INSERT INTO "informix".sc_nom_disp_cte_his (
						numcte, cuenta, producto, desc_producto,
						id_empresa_nom, id_cuenta_empresa, bancoreferencia, fecha_pago,
						ingresos_emp, ingresos_porta, ingresos_pen, ingresos_sdw, ingresos_netos,
						tipo_transaccion, periodicidad, ingreso_ajustado, cadena_dia_dispersion,
						conteo_dias_pago, conteo_depositos, deposito1_7, deposito8_14,
						deposito15_21, deposito22_31, deposito1_13, deposito14_27, deposito28_31,
						fecha_insert)
					VALUES(
						c_numcte, c_cuenta, c_producto, c_desc_producto,
						c_id_empresa_nom, c_id_cuenta_empresa, c_bancoreferencia, c_fecha_pago,
						m_ingresos_emp, m_ingresos_porta, m_ingresos_pen, m_ingresos_sdw, m_ingresos_netos,
						c_tipo_transaccion, c_periodicidad, c_ingreso_ajustado, c_cadena_dia_dispersion,
						i_conteo_dias_pago, i_conteo_depositos, i_deposito1_7, i_deposito8_14,
						i_deposito15_21, i_deposito22_31, i_deposito1_13, i_deposito14_27, i_deposito28_31,
						TODAY);
					
					DELETE FROM "informix".sc_nom_disp_cte
					WHERE fecha_pago = c_fecha_pago AND cuenta = c_cuenta;
					
					LET v_Num_Regs = v_Num_Regs + 1;
					
					IF v_Num_Regs = v_Regs_X_Commit THEN
					
						COMMIT WORK;
						LET b_enTransaccion = 'f';
						LET v_Num_Regs = 0;
						
					END IF;
					
			END FOREACH
			
			IF b_enTransaccion = 't' THEN
			
				COMMIT WORK;
				LET b_enTransaccion = 'f';
				LET v_Num_Regs = 0;
			
			END IF;
			
		END IF;
	END;

	RETURN cCodRet;

END PROCEDURE
DOCUMENT
'_______________________________________________________________________________________________________________________________',
'CREADO:		Jorge Humberto Quintana Santiesteban',
'FECHA:			28 de enero de 2025',
'BD:			bdicheq',
'DESCRIPCION:	Proceso orquestador de subprocesos diario y mensuales para la generacion de la data de dispersion',
'RETORNO:		000000 Proceso Exitoso',
'_______________________________________________________________________________________________________________________________',
'CREADO:		Jesus Adrian Diaz Orozco',
'FECHA:			20 de noviembre de 2025',
'DESCRIPCION:	Se agrega commit cada 1000 registros',
'_______________________________________________________________________________________________________________________________',
'CREADO:		Jesus Adrian Diaz Orozco',
'FECHA:			29 de Febrero de 2026',
'DESCRIPCION:	INC 27 364 - Se agrega llenado de sc_nom_mov_mes con los movimietos de meses previos, la cantidad de meses queda',
'							 parametrizado a traves de la sc_param',
'_______________________________________________________________________________________________________________________________';

CREATE PROCEDURE "informix".pasecheqhis(pempresa char(3), pfechahoy date)
RETURNING CHAR(5);
    
    DEFINE GLOBAL vgcodigo_mn           CHAR(2)     DEFAULT ' ';
    DEFINE GLOBAL vg_sistema            CHAR(2)     DEFAULT ' ';
    DEFINE GLOBAL vgtransacc_t1         CHAR(4)     DEFAULT ' ';
    DEFINE GLOBAL vgtransacc_t2         CHAR(4)     DEFAULT ' ';
    DEFINE GLOBAL vgcta_iva             CHAR(20)    DEFAULT ' ';
    DEFINE GLOBAL vgcta_itr             CHAR(20)    DEFAULT ' ';
    DEFINE GLOBAL vgtransacc_corresp    CHAR(4)     DEFAULT ' ';
	DEFINE GLOBAL vfecha_hoy            DATE        DEFAULT TODAY;
    
    define vcodret          char(5);
    define vcodret2         char(5);
    define vcodret3         char(50);
    define vsqlerr          integer;
    define visamerr         integer;
    define vdescerr         char(50);
    define vsucopero        char(4);
    define vproducto        char(4);
    define vmoneda          char(2);
    define vtransacc        char(4);
    define vmonto_tot       money(14,2);
    define vexento_isr      char(1);
    define vsector          char(2);
    define vvaloriza        char(1);
    define vcancelad        char(1);
    define vsuccta          char(4);
    define wabreviatura     char(20);
    define wdescripcion     char(30);
    define vfechaproc       date;
    define vporcentaje      decimal(9,6);
    define vtasa_bruta      decimal(9,6);
    define vsobretasa       decimal(9,6);
    define vtpcambval       decimal(14,6);
    define vmonto1          money(14,2);
    define vmonto2          money(14,2);
    define vdivisa_cambio   char(2);
    define vtranprovint     char(4);
    define vcobraisr        char(1);
    define vproceso         char(20);
    define vsistema         char(2);
    define vestatusproc     char(1);
    define vsql             char(600);
    define vstmt            char(250);
    define vusuario         char(10);
    define vhora_tc         datetime hour to minute;
    define vbintarjeta      char(6);   -- PITDC
    define vsecuencia       integer;   -- PITDC
    define vreferencia      char (19); -- PITDC
    define vcuenta          char(20);
    define vsecserv         smallint;
    define vserial_final    integer;
    define vexiste          integer;
    define vcodretparam     char(5);

    let vcodret  = "000";
    let vcodret2 = "";
    let vcodret3 = "";
    let vsqlerr  = 0;
    let visamerr = 0;
    let vdescerr = "";
    let vproceso = "pasechqhis";
    let vsistema = "01";
    let vestatusproc = "I";
    let vsql     = '';
    let vstmt    = '';
    let vusuario = user;
    let vserial_final = 0;
    let vexiste = 0;
    let vcodretparam = '';

    -- set debug file to "/RESPALDOS/pasecheqhis.out";
    -- trace on;

    begin
    
    on exception set vsqlerr, visamerr, vdescerr
        set debug file to "/tmp/pasecheqhis.err";
        trace on;
        if vsqlerr <> 0 then
            let vcodret = vsqlerr;
            let vcodret2 = visamerr;
            let vcodret3 = vdescerr;
            UPDATE bdinteg:sx_contproc
            SET ejecutivo = vusuario,
            status_proc = 'C',
            codret = vcodret,
            hora_fin = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas)
            WHERE empresa = pempresa
            AND proceso = vproceso
            AND fecha = vfecha_hoy
            AND sistema = vsistema;
            return vcodret;
        end if;
    end exception;
    
    set isolation to dirty read;
    set optimization high;

    -- // Asigna la fecha de hoy
    let vfecha_hoy = pfechahoy;
    
    -- // GUARDA REGISTRO DE EJECUCIï¿½N
    select count(*)
      into vexiste
      from bdinteg:sx_contproc
     where empresa = pempresa
       and proceso = vproceso
       and fecha   = vfecha_hoy
       and sistema = vsistema;

    if vexiste = 0 then
        INSERT INTO bdinteg:sx_contproc
            VALUES(pempresa, vproceso, vfecha_hoy, vsistema, 'I', vusuario, (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas), NULL, NULL);
    else
        UPDATE bdinteg:sx_contproc
        SET ejecutivo = vusuario,
        status_proc = 'I',
        codret = ' ',
        hora_fin = ' ',
        hora_ini = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas)
        WHERE empresa = pempresa
        AND proceso = vproceso
        AND fecha = vfecha_hoy
        AND sistema = vsistema;    
    end if; 
    
    execute procedure "informix".sp_actparampasecheqhis(pempresa, vfecha_hoy)
    into vcodretparam;
    
    if vcodretparam <> '000' then
        let vcodret = '975';
        UPDATE bdinteg:sx_contproc 
        SET ejecutivo = vusuario,
        status_proc = 'C',
        codret = vcodret,
        hora_fin = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) 
        WHERE empresa = pempresa 
        AND proceso = vproceso 
        AND fecha = vfecha_hoy 
        AND sistema = vsistema;
        return vcodret;
    end if;

    -- // LIMPIA TABLAS DE TRABAJO
    truncate sc_contab;
    truncate aux_auditerr;
    --- truncate aux_contab;
    
	delete bdicheq:sc_suspenso 
     where fecha_valida = vfecha_hoy;
	
	-- // Extrae parametros globales	
	CALL pasechq_globalvar (pempresa) 
    RETURNING vcodret; 
       
    select valor 
      into vtranprovint
      from sc_param
     where empresa = pempresa 
       and codparam = "tranprov";
       
    -- // Extrae tasa base para el calculo de tasa exenta y param de T+1
    select {+INDEX (bdinteg:si_param ix_si_param)} valor 
      into vdivisa_cambio
      from bdinteg:si_param
     where cod_param > 0
       and empresa = pempresa 
       and descripcion = "divisa cambio";
    
    -- // Extrae tipo de cambio valorizado
    select precio_venta 
      into vtpcambval
      from bdinteg:si_tpcambio
     where empresa = pempresa 
       and divisa = vdivisa_cambio 
       and fecha_tpcambio = vfecha_hoy 
       and clase_tpcambio = "O";
       
    if vtpcambval is null then
        select max(hora_tc) 
          into vhora_tc
          from bdinteg:si_histdiv
         where empresa = pempresa 
           and divisa = vdivisa_cambio 
           and fecha_tc = vfecha_hoy
           and clase_tpcambio = "O";
           
        select precio_venta 
          into vtpcambval
          from bdinteg:si_histdiv
         where empresa = pempresa 
           and divisa = vdivisa_cambio 
           and fecha_tc = vfecha_hoy
           and clase_tpcambio = "O"
           and hora_tc = vhora_tc;
           
        if vtpcambval is null then
            let vtpcambval = 1;
        end if
    end if
    
    -- // ACTUALIZA BANDERA DE PROCESAMIENTO DIARIO PARA LOS COMPLEMENTOS
    update sc_contproc
       set fecha = vfecha_hoy
     where empresa = pempresa 
       and proceso = "inicio_pasehis";
      
    -- // OBTIENE VALORES PARA RANGO DE SERIALES A PROCESAR
    select valor::integer
      into vserial_final
      from sc_param
     where empresa = pempresa
       and codparam = 'SerialIniPaseChqCom1';
    
    -- // CREA TABLA TEMPORAL DEL RANGO DE SERIALES INDICADOS
    select cuenta, sucursal, producto, transacc, monto_tot, cancelad, referencia /* PITDC Se agrega el campo "referencia" para que traiga el numero de tarjeta */
      from sc_movhis
     where fech_alt = vfecha_hoy 
       and num_serial < vserial_final
      into temp his1 with no log;
    create index inx_temp on his1(cuenta, producto, transacc) using btree fillfactor 99;
    update statistics high for table his1;
	
		-- // CREA TABLA TEMPORAL DEL CUENTAS X PROCESO CUENTAS SUSPENSO
	select empresa,ccmayor,ccsub,ccsubsub,ccssubsub,ccsssubsub,sector 
      from bdinteg:si_catalog  
      into temp tmp_si_catalog with no log;
	
    create index id1_tmp_si_catalog on tmp_si_catalog (empresa,ccmayor,ccsub,ccsubsub,ccssubsub,ccsssubsub,sector ) using btree fillfactor 99;
    update statistics medium for table tmp_si_catalog;

    -- // FOREACH PRINCIPAL
    foreach
        select md.sucursal, md.producto, pr.divisa, md.transacc, md.referencia, 
               md.monto_tot, tp.exento_isr, cl.sector, tr.valoriza, md.cancelad, 
               ac.tasa_bruta, ac.sobretasa, mc.sucursal, tr.descripcion as abreviatura, mc.cobraisr,md.cuenta
          into vsucopero, vproducto, vmoneda, vtransacc,vreferencia, 
               vmonto_tot, vexento_isr, vsector, vvaloriza, vcancelad, 
               vtasa_bruta, vsobretasa, vsuccta, wabreviatura, vcobraisr,vcuenta
          from his1 md,
               sc_maechq mc,
         outer sc_auxcont ac,
               sc_producto pr,
               bdinteg:si_transacc tr, 
               bdinteg:si_cliente cl,
               bdinteg:si_tipper tp
         where md.cuenta = mc.cuenta
           and md.producto = mc.producto
           and md.transacc not in(vgtransacc_t1, vgtransacc_t2, "0231", "0232", "3313", "3314", "0269","1113","1144")
           and md.cancelad <> "S"
           and mc.empresa = pempresa
           and mc.cuenta = md.cuenta
           and ac.empresa = pempresa
           and ac.cuenta = md.cuenta
           and pr.empresa = pempresa
           and pr.producto = md.producto
           and tr.empresa = pempresa
           and tr.numero = md.transacc
           and tr.se_contabiliza = "S"
           and tr.sistema = vg_sistema
           and cl.numcte = mc.num_cte
           and tp.tpo_persona = cl.tpo_persona
        union all
        select md.sucursal, ma.producto, pr.divisa, md.transacc, md.referencia, 
               md.monto_tot, "N", cl.sector, tr.valoriza, md.cancelad, 
               0, 0, ma.sucursal, tr.descripcion as abreviatura, ma.cobraisr,md.cuenta
          from his1 md,
               sc_maechq ma,
               sc_producto pr,
               bdinteg:si_cliente cl,
               bdinteg:si_transacc tr
         where md.cuenta = ma.cuenta
           and md.producto = ma.producto
           and md.transacc in (vgtransacc_t1,vgtransacc_t2,"0231","0232","3313","3314","0269","1113","1144")
           and ma.empresa = pempresa
           and ma.cuenta = md.cuenta
           and pr.empresa = pempresa
           and pr.producto = md.producto
           and cl.numcte = ma.num_cte
           and tr.empresa = pempresa
           and tr.numero = md.transacc
           and tr.se_contabiliza = "S"
           and tr.sistema = vg_sistema
        union all
        select md.sucursal, md.producto, pr.divisa, md.transacc, md.referencia, 
               md.monto_tot, "N", "00", tr.valoriza, md.cancelad, 
               ac.tasa_bruta, ac.sobretasa, md.sucursal, tr.descripcion as abreviatura, 'S', md.cuenta
          from his1 md,
               bditransfer:tf_maecte mc,
         outer sc_auxcont ac,
               sc_producto pr,
               bdinteg:si_transacc tr
         where md.cuenta = mc.cuenta_tf
           and md.transacc not in(vgtransacc_t1, vgtransacc_t2, "0231", "0232", "3313", "3314", "0269","1113","1144")
           and md.cancelad <> "S"
           and mc.cuenta_tf = md.cuenta
           and ac.empresa = pempresa
           and ac.cuenta = md.cuenta
           and pr.empresa = pempresa
           and pr.producto = md.producto
           and tr.empresa = pempresa
           and tr.numero = md.transacc
           and tr.se_contabiliza = "S"
           and tr.sistema = vg_sistema

        let wdescripcion = wabreviatura;
        
        if vcobraisr <> "" then
            if vcobraisr = "S" then
                let vexento_isr = "N";
            else
                let vexento_isr = "S";
            end if
        end if

        -- // Verifica si es Transaccion de provision de Interes
        if vtransacc = vtranprovint then
            if vmoneda = vgcodigo_mn then
                call extrae_cont(pempresa,1,vmonto_tot,vsucopero,vproducto,vmoneda,vtransacc,vsector,vcancelad,vsuccta,wdescripcion) 
                returning vcodret;
                
                continue foreach;
            end if
            
            if vmoneda != vgcodigo_mn and vvaloriza = "S" then
                call extrae_cont(pempresa,1,vmonto_tot,vsucopero,vproducto,vmoneda,vtransacc,vsector,vcancelad,vsuccta,wdescripcion) 
                returning vcodret;
                
                let vmonto2 = vmonto_tot * vtpcambval;
                
                call extrae_cont(pempresa,3,vmonto2,vsucopero,vproducto,vgcodigo_mn,vtransacc,vsector,vcancelad,vsuccta,wdescripcion) 
                returning vcodret;
                
                continue foreach;
            end if
        end if

        -- // Verifica si es movimiento valorizado
        if vmoneda <> vgcodigo_mn and vvaloriza = "S"  then
            let vmonto2 = vmonto_tot * vtpcambval;
            
            call extrae_cont(pempresa,3,vmonto2,vsucopero,vproducto,vgcodigo_mn,vtransacc,vsector,vcancelad,vsuccta,wdescripcion) 
            returning vcodret;
        end if

        if vtransacc <> "0231" and 
           vtransacc <> "0232" and 
           vtransacc <> "3313" and 
           vtransacc <> "3314" and
           vtransacc <> "1193" and 
           vtransacc <> "1195" and
           vtransacc <> vgtransacc_t1 and 
           vtransacc <> "0269" and 
           vtransacc <> "1113" and
           vtransacc <> "1144" and		   
           vtransacc <> vgtransacc_t2 and not  
          (vtransacc="0274" and vproducto="9901") AND NOT 
          (vtransacc="0273" and vproducto="9901") AND NOT 
          (vtransacc="0273" and vproducto = "1600" and vcuenta in ('16000000080')) AND NOT
		  (vtransacc="0273" and vproducto = "1600" and vcuenta in ('16000000322')) AND NOT
          (vtransacc="0273" and vproducto = "2200" and vcuenta in ('22000001574'))   then
            call extrae_cont(pempresa,1,vmonto_tot,vsucopero,vproducto,vmoneda,vtransacc,vsector,vcancelad,vsuccta,wdescripcion)  
            returning vcodret;
        end if
        
        --	// Proceso para PITDC:
        if vtransacc = "1193" or vtransacc = "1195" then
            let vbintarjeta = substr(vreferencia, 1, 6);
            
            -- // Obtener que secuencia debe ser tomada en cuenta:
            SELECT Cod_Reg 
            into vsecuencia 
            FROM BdiSac:Sac_EGlobal_Banco 
            WHERE IdBanco = (SELECT NVL(Id_Bco, 0) 
                            FROM BdiCheq:Sc_Bines 
                            WHERE Bin = vbintarjeta);
             
            if vsecuencia is null then
                let vsecuencia = "3";
            end if;	
            
            call extrae_cont(pempresa,vsecuencia,vmonto_tot,vsucopero,vproducto,vmoneda,vtransacc,vsector,vcancelad,vsuccta,wdescripcion)
            returning vcodret;
     	end if;			

        -- // Contabiliza Camara,231,232,3246,269,1113
        if vtransacc = "0231" or 
            vtransacc = "0232" or
            vtransacc = "3313" or 
            vtransacc = "3314" or
            vtransacc = vgtransacc_t1 or 
            vtransacc = "0269" or 
            vtransacc = "1113" or 		   
            vtransacc = "1144" or
		    vtransacc = vgtransacc_t2 then
            call extrae_cont(pempresa,1,vmonto_tot,vsucopero,vproducto,vmoneda,vtransacc,vsector,vcancelad,vsuccta,wdescripcion)  
            returning vcodret;
            
            if vtransacc = vgtransacc_t1 or vtransacc = "0269" or vtransacc = "1113" or vtransacc = "1144" then
                call extrae_cont(pempresa,2,vmonto_tot,vsucopero,vproducto,vmoneda,vtransacc,vsector,vcancelad,vsuccta,wdescripcion) 
                returning vcodret;
            end if
        end if
        
        /* SERVICIOS */
		if (vtransacc = "0274" and vproducto="9901") OR 
           (vtransacc = "0273" and vproducto="9901") OR 
           (vtransacc = "0273" and vproducto="1600" and vcuenta in ('16000000080')) OR 
		   (vtransacc = "0273" and vproducto="1600" and vcuenta in ('16000000322')) OR 
           (vtransacc = "0273" and vproducto="2200" and vcuenta in ('22000001574')) then

            select {+INDEX (bdisac:sac_catalogo_pt idx_ptcta)} nvl(MAX(secuencia),0) INTO vsecserv from bdisac:sac_catalogo_pt where cuenta=trim(vcuenta); 
            if vsecserv<>0 then
                call extrae_cont(pempresa,vsecserv,vmonto_tot,vsucopero,vproducto,vmoneda,vtransacc,vsector,vcancelad,vsuccta,
                case when vcuenta = '22000001574' then 'ABSPEIWU' 
                    when vcuenta = '16000000080' then 'ABSPEIBTS'
                    when vcuenta = '16000000322' then 'ABSPEIAPP' 									  
                else wdescripcion end)  

                returning vcodret;
            end if;
        end if;
    end foreach
    
    let vestatusproc = "F";
    
    UPDATE bdinteg:sx_contproc
    SET status_proc = vestatusproc,
    codret = vcodret,
    hora_fin = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) 
    WHERE empresa = pempresa
    AND proceso = vproceso
    AND fecha = vfecha_hoy 
    AND sistema = vsistema;
    return vcodret;

    end;

end procedure

DOCUMENT
"FUNCIONAMIENTO:SP padre de pase de cheques historicos",
"AJUSTE: Se quitan system",
"FECHA : 24/03/2026",
"DB: bdicheq";

CREATE PROCEDURE "informix".pasecheqhiscomp1(pempresa char(3), pfechahoy date)
RETURNING CHAR(5);
      
    DEFINE GLOBAL vgcodigo_mn           CHAR(2)     DEFAULT ' ';
    DEFINE GLOBAL vg_sistema            CHAR(2)     DEFAULT ' ';
    DEFINE GLOBAL vgtransacc_t1         CHAR(4)     DEFAULT ' ';
    DEFINE GLOBAL vgtransacc_t2         CHAR(4)     DEFAULT ' ';
    DEFINE GLOBAL vgcta_iva             CHAR(20)    DEFAULT ' ';
    DEFINE GLOBAL vgcta_itr             CHAR(20)    DEFAULT ' ';
    DEFINE GLOBAL vgtransacc_corresp    CHAR(4)     DEFAULT ' ';
	DEFINE GLOBAL vfecha_hoy            DATE        DEFAULT TODAY;
    
    define vcodret          char(5);
    define vcodret2         char(5);
    define vcodret3         char(50);
    define vsqlerr          integer;
    define visamerr         integer;
    define vdescerr         char(50);
    define vsucopero        char(4);
    define vproducto        char(4);
    define vmoneda          char(2);
    define vtransacc        char(4);
    define vmonto_tot       money(14,2);
    define vexento_isr      char(1);
    define vsector          char(2);
    define vvaloriza        char(1);
    define vcancelad        char(1);
    define vsuccta          char(4);
    define wabreviatura     char(20);
    define wdescripcion     char(30);
    define vfechaproc       date;
    define vporcentaje      decimal(9,6);
    define vtasa_bruta      decimal(9,6);
    define vsobretasa       decimal(9,6);
    define vtpcambval       decimal(14,6);
    define vmonto1          money(14,2);
    define vmonto2          money(14,2);
    define vdivisa_cambio   char(2);
    define vtranprovint     char(4);
    define vcobraisr        char(1);
    define vproceso         char(20);
    define vsistema         char(2);
    define vestatusproc     char(1);
    define vsql             char(600);
    define vstmt            char(250);
    define vusuario         char(10);
    define vhora_tc         datetime hour to minute;
    define vbintarjeta      char(6);   -- PITDC
    define vsecuencia       integer;   -- PITDC
    define vreferencia      char (19); -- PITDC
    define vcuenta          char(20);
    define vsecserv         smallint;
    define vserial_inicial  integer;
    define vserial_final    integer;
    define vexiste          integer;
    
    let vcodret  = "000";
    let vcodret2 = "";
    let vcodret3 = "";
    let vsqlerr  = 0;
    let visamerr = 0;
    let vdescerr = "";
    let vproceso = "pasechqhiscomp1";
    let vsistema = "01";
    let vestatusproc = "I";
    let vsql     = '';
    let vstmt    = '';
    let vusuario = user;
    let vserial_inicial = 0;
    let vserial_final = 0;
    let vexiste = 0;
    
    -- set debug file to "/tmp/pasecheqhiscomp1_09052018.out";
    -- trace on;
    
    begin
    
    on exception set vsqlerr, visamerr, vdescerr
        set debug file to "/tmp/pasecheqhiscomp1.err";
        trace on;
        if vsqlerr <> 0 then
            let vcodret = vsqlerr;
            let vcodret2 = visamerr;
            let vcodret3 = vdescerr;
            UPDATE bdinteg:sx_contproc
            SET ejecutivo = vusuario,
            status_proc = 'C',
            codret = vcodret,
            hora_fin = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas)
            WHERE empresa = pempresa
            AND proceso   = vproceso
            AND fecha     = vfecha_hoy
            AND sistema   = vsistema;
            return vcodret;
        end if;
    end exception;
    
    set isolation to dirty read;
    set optimization high;

    -- // Asigna la fecha de hoy
    let vfecha_hoy = pfechahoy;
    
    -- // GUARDA REGISTRO DE EJECUCIï¿½N
    select count(*)
      into vexiste
      from bdinteg:sx_contproc
     where empresa = pempresa
       and proceso = vproceso
       and fecha   = vfecha_hoy
       and sistema = vsistema;

    if vexiste = 0 then
        INSERT INTO bdinteg:sx_contproc 
            VALUES (pempresa, vproceso, vfecha_hoy, vsistema, 'I', vusuario, (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas), NULL, NULL);
    else
        UPDATE bdinteg:sx_contproc
        SET ejecutivo = vusuario,
        status_proc = 'I',
        codret = ' ',
        hora_fin = ' ',
        hora_ini = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas)
        WHERE empresa = pempresa
        AND proceso = vproceso
        AND fecha = vfecha_hoy
        AND sistema = vsistema;
    end if;

    -- // Verifica se haya iniciado el pase contable principal
    select {+INDEX (bdicheq:sc_contproc idx_contproc2)} fecha 
      into vfechaproc
      from sc_contproc
     where empresa = pempresa 
       and proceso = "inicio_pasehis";
       
    if vfechaproc <> vfecha_hoy then
        let vcodret = "973";        
        return vcodret;
    end if
    
    -- // Extrae parametros globales	
	CALL pasechq_globalvar (pempresa) 
    RETURNING vcodret; 
       
    select valor 
      into vtranprovint
      from sc_param
     where empresa = pempresa 
       and codparam = "tranprov";
       
    -- // Extrae tasa base para el calculo de tasa exenta y param de T+1
    select {+INDEX (bdinteg:si_param ix_si_param)} valor 
      into vdivisa_cambio
      from bdinteg:si_param
     where cod_param > 0
       and empresa = pempresa 
       and descripcion = "divisa cambio";
    
    -- // Extrae tipo de cambio valorizado
    select precio_venta 
      into vtpcambval
      from bdinteg:si_tpcambio
     where empresa = pempresa 
       and divisa = vdivisa_cambio 
       and fecha_tpcambio = vfecha_hoy 
       and clase_tpcambio = "O";
       
    if vtpcambval is null then
        select max(hora_tc) 
          into vhora_tc
          from bdinteg:si_histdiv
         where empresa = pempresa 
           and divisa = vdivisa_cambio 
           and fecha_tc = vfecha_hoy
           and clase_tpcambio = "O";
           
        select precio_venta 
          into vtpcambval
          from bdinteg:si_histdiv
         where empresa = pempresa 
           and divisa = vdivisa_cambio 
           and fecha_tc = vfecha_hoy
           and clase_tpcambio = "O"
           and hora_tc = vhora_tc;
           
        if vtpcambval is null then
            let vtpcambval = 1;
        end if
    end if
      
    -- // OBTINE VALORES PARA RANGO DE SERIALES A PROCESAR
    select valor::integer
      into vserial_inicial
      from sc_param
     where empresa = pempresa
       and codparam = 'SerialIniPaseChqCom1';
       
    select valor::integer
      into vserial_final
      from sc_param
     where empresa = pempresa
       and codparam = 'SerialIniPaseChqCom2';
    
    -- // CREA TABLA TEMPORAL DEL RANGO DE SERIALES INDICADOS
    select cuenta, sucursal, producto, transacc, monto_tot, cancelad, referencia /* PITDC Se agrega el campo "referencia" para que traiga el numero de tarjeta */
      from sc_movhis
     where fech_alt = vfecha_hoy 
       and num_serial >= vserial_inicial
       and num_serial < vserial_final
      into temp his1 with no log;
    create index inx_temp on his1(cuenta, producto, transacc) using btree fillfactor 99;
    update statistics high for table his1;
		-- // CREA TABLA TEMPORAL DEL CUENTAS X PROCESO CUENTAS SUSPENSO
	select empresa,ccmayor,ccsub,ccsubsub,ccssubsub,ccsssubsub,sector 
      from bdinteg:si_catalog  
      into temp tmp_si_catalog with no log;
	
    create index id1_tmp_si_catalog on tmp_si_catalog (empresa,ccmayor,ccsub,ccsubsub,ccssubsub,ccsssubsub,sector ) using btree fillfactor 99;
    update statistics medium for table tmp_si_catalog;
    
    -- // FOREACH PRINCIPAL
    foreach
        select md.sucursal, md.producto, pr.divisa, md.transacc, md.referencia, 
               md.monto_tot, tp.exento_isr, cl.sector, tr.valoriza, md.cancelad, 
               ac.tasa_bruta, ac.sobretasa, mc.sucursal, tr.descripcion as abreviatura, mc.cobraisr,md.cuenta
          into vsucopero, vproducto, vmoneda, vtransacc,vreferencia, 
               vmonto_tot, vexento_isr, vsector, vvaloriza, vcancelad, 
               vtasa_bruta, vsobretasa, vsuccta, wabreviatura, vcobraisr,vcuenta
          from his1 md,
               sc_maechq mc,
         outer sc_auxcont ac,
               sc_producto pr,
               bdinteg:si_transacc tr, 
               bdinteg:si_cliente cl,
               bdinteg:si_tipper tp
         where md.cuenta = mc.cuenta
           and md.producto = mc.producto
           and md.transacc not in(vgtransacc_t1, vgtransacc_t2, "0231", "0232", "3313", "3314", "0269","1113","1144")
           and md.cancelad <> "S"
           and mc.empresa = pempresa
           and mc.cuenta = md.cuenta
           and ac.empresa = pempresa
           and ac.cuenta = md.cuenta
           and pr.empresa = pempresa
           and pr.producto = md.producto
           and tr.empresa = pempresa
           and tr.numero = md.transacc
           and tr.se_contabiliza = "S"
           and tr.sistema = vg_sistema
           and cl.numcte = mc.num_cte
           and tp.tpo_persona = cl.tpo_persona
        union all
        select md.sucursal, ma.producto, pr.divisa, md.transacc, md.referencia, 
               md.monto_tot, "N", cl.sector, tr.valoriza, md.cancelad, 
               0, 0, ma.sucursal, tr.descripcion as abreviatura, ma.cobraisr,md.cuenta
          from his1 md,
               sc_maechq ma,
               sc_producto pr,
               bdinteg:si_cliente cl,
               bdinteg:si_transacc tr
         where md.cuenta = ma.cuenta
           and md.producto = ma.producto
           and md.transacc in (vgtransacc_t1,vgtransacc_t2,"0231","0232","3313","3314","0269","1113","1144")
           and ma.empresa = pempresa
           and ma.cuenta = md.cuenta
           and pr.empresa = pempresa
           and pr.producto = md.producto
           and cl.numcte = ma.num_cte
           and tr.empresa = pempresa
           and tr.numero = md.transacc
           and tr.se_contabiliza = "S"
           and tr.sistema = vg_sistema
        union all
        select md.sucursal, md.producto, pr.divisa, md.transacc, md.referencia, 
               md.monto_tot, "N", "00", tr.valoriza, md.cancelad, 
               ac.tasa_bruta, ac.sobretasa, md.sucursal, tr.descripcion as abreviatura, 'S', md.cuenta
          from his1 md,
               bditransfer:tf_maecte mc,
         outer sc_auxcont ac,
               sc_producto pr,
               bdinteg:si_transacc tr
         where md.cuenta = mc.cuenta_tf
           and md.transacc not in(vgtransacc_t1, vgtransacc_t2, "0231", "0232", "3313", "3314", "0269","1113","1144")
           and md.cancelad <> "S"
           and mc.cuenta_tf = md.cuenta
           and ac.empresa = pempresa
           and ac.cuenta = md.cuenta
           and pr.empresa = pempresa
           and pr.producto = md.producto
           and tr.empresa = pempresa
           and tr.numero = md.transacc
           and tr.se_contabiliza = "S"
           and tr.sistema = vg_sistema

        let wdescripcion = wabreviatura;
        
        if vcobraisr <> "" then
            if vcobraisr = "S" then
                let vexento_isr = "N";
            else
                let vexento_isr = "S";
            end if
        end if

        -- // Verifica si es Transaccion de provision de Interes
        if vtransacc = vtranprovint then
            if vmoneda = vgcodigo_mn then
                call extrae_cont(pempresa,1,vmonto_tot,vsucopero,vproducto,vmoneda,vtransacc,vsector,vcancelad,vsuccta,wdescripcion) 
                returning vcodret;
                
                continue foreach;
            end if
            
            if vmoneda != vgcodigo_mn and vvaloriza = "S" then
                call extrae_cont(pempresa,1,vmonto_tot,vsucopero,vproducto,vmoneda,vtransacc,vsector,vcancelad,vsuccta,wdescripcion) 
                returning vcodret;
                
                let vmonto2 = vmonto_tot * vtpcambval;
                
                call extrae_cont(pempresa,3,vmonto2,vsucopero,vproducto,vgcodigo_mn,vtransacc,vsector,vcancelad,vsuccta,wdescripcion) 
                returning vcodret;
                
                continue foreach;
            end if
        end if

        -- // Verifica si es movimiento valorizado
        if vmoneda <> vgcodigo_mn and vvaloriza = "S"  then
            let vmonto2 = vmonto_tot * vtpcambval;
            
            call extrae_cont(pempresa,3,vmonto2,vsucopero,vproducto,vgcodigo_mn,vtransacc,vsector,vcancelad,vsuccta,wdescripcion) 
            returning vcodret;
        end if

        if vtransacc <> "0231" and 
           vtransacc <> "0232" and 
           vtransacc <> "3313" and 
           vtransacc <> "3314" and
           vtransacc <> "1193" and 
           vtransacc <> "1195" and
           vtransacc <> vgtransacc_t1 and 
           vtransacc <> "0269" and 
           vtransacc <> "1113" and
           vtransacc <> "1144" and		   
           vtransacc <> vgtransacc_t2 and not  
          (vtransacc="0274" and vproducto="9901") AND NOT 
          (vtransacc="0273" and vproducto="9901") AND NOT 
          (vtransacc="0273" and vproducto = "1600" and vcuenta in ('16000000080')) AND NOT
		  (vtransacc="0273" and vproducto = "1600" and vcuenta in ('16000000322')) AND NOT
          (vtransacc="0273" and vproducto = "2200" and vcuenta in ('22000001574'))   then
            call extrae_cont(pempresa,1,vmonto_tot,vsucopero,vproducto,vmoneda,vtransacc,vsector,vcancelad,vsuccta,wdescripcion)  
            returning vcodret;
        end if
        
        --	// Proceso para PITDC:
        if vtransacc = "1193" or vtransacc = "1195" then
            let vbintarjeta = substr(vreferencia, 1, 6);
            
            -- // Obtener que secuencia debe ser tomada en cuenta:
            SELECT Cod_Reg 
              into vsecuencia 
              FROM BdiSac:Sac_EGlobal_Banco 
             WHERE IdBanco = (SELECT NVL(Id_Bco, 0) 
                                FROM BdiCheq:Sc_Bines 
                               WHERE Bin = vbintarjeta);
             
            if vsecuencia is null then
                let vsecuencia = "3";
            end if;	
            
            call extrae_cont(pempresa,vsecuencia,vmonto_tot,vsucopero,vproducto,vmoneda,vtransacc,vsector,vcancelad,vsuccta,wdescripcion)
            returning vcodret;
     	end if;			

        -- // Contabiliza Camara,231,232,3246,269,1113
        if vtransacc = "0231" or 
           vtransacc = "0232" or
           vtransacc = "3313" or 
           vtransacc = "3314" or
           vtransacc = vgtransacc_t1 or 
           vtransacc = "0269" or 
           vtransacc = "1113" or 		   
           vtransacc = "1144" or
		   vtransacc = vgtransacc_t2 then
            call extrae_cont(pempresa,1,vmonto_tot,vsucopero,vproducto,vmoneda,vtransacc,vsector,vcancelad,vsuccta,wdescripcion)  
            returning vcodret;
            
            if vtransacc = vgtransacc_t1 or vtransacc = "0269" or vtransacc = "1113" or vtransacc = "1144" then
                call extrae_cont(pempresa,2,vmonto_tot,vsucopero,vproducto,vmoneda,vtransacc,vsector,vcancelad,vsuccta,wdescripcion) 
                returning vcodret;
            end if
        end if
        
        /* SERVICIOS */
		if (vtransacc = "0274" and vproducto="9901") OR 
           (vtransacc = "0273" and vproducto="9901") OR 
           (vtransacc = "0273" and vproducto="1600" and vcuenta in ('16000000080')) OR 
		   (vtransacc = "0273" and vproducto="1600" and vcuenta in ('16000000322')) OR 
           (vtransacc = "0273" and vproducto="2200" and vcuenta in ('22000001574')) then

            select {+INDEX (bdisac:sac_catalogo_pt idx_ptcta)} nvl(MAX(secuencia),0) INTO vsecserv from bdisac:sac_catalogo_pt where cuenta=trim(vcuenta); 
            if vsecserv<>0 then
                call extrae_cont(pempresa,vsecserv,vmonto_tot,vsucopero,vproducto,vmoneda,vtransacc,vsector,vcancelad,vsuccta,
				                 case when vcuenta = '22000001574' then 'ABSPEIWU' 
								      WHEN vcuenta = '16000000080' then 'ABSPEIBTS'
									  when vcuenta = '16000000322' then 'ABSPEIAPP' 									  
									  else wdescripcion end)  


                returning vcodret;
            end if;
        end if;
    end foreach
    
    let vestatusproc = "F";
    
    UPDATE bdinteg:sx_contproc
    SET status_proc = vestatusproc,
    codret = vcodret,
    hora_fin = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) 
    WHERE empresa = pempresa
    AND proceso = vproceso 
    AND fecha = vfecha_hoy 
    AND sistema = vsistema;
    return vcodret;

    end;

end procedure

DOCUMENT
"FUNCIONAMIENTO:SP padre de pase de cheques historicos",
"AJUSTE: Se quitan system",
"FECHA : 24/03/2026",
"DB: bdicheq";

CREATE PROCEDURE "informix".pasecheqhiscomp2(pempresa char(3), pfechahoy date)
RETURNING CHAR(5);
     
    DEFINE GLOBAL vgcodigo_mn           CHAR(2)     DEFAULT ' ';
    DEFINE GLOBAL vg_sistema            CHAR(2)     DEFAULT ' ';
    DEFINE GLOBAL vgtransacc_t1         CHAR(4)     DEFAULT ' ';
    DEFINE GLOBAL vgtransacc_t2         CHAR(4)     DEFAULT ' ';
    DEFINE GLOBAL vgcta_iva             CHAR(20)    DEFAULT ' ';
    DEFINE GLOBAL vgcta_itr             CHAR(20)    DEFAULT ' ';
    DEFINE GLOBAL vgtransacc_corresp    CHAR(4)     DEFAULT ' ';
	DEFINE GLOBAL vfecha_hoy            DATE        DEFAULT TODAY;
    
    define vcodret          char(5);
    define vcodret2         char(5);
    define vcodret3         char(50);
    define vsqlerr          integer;
    define visamerr         integer;
    define vdescerr         char(50);
    define vsucopero        char(4);
    define vproducto        char(4);
    define vmoneda          char(2);
    define vtransacc        char(4);
    define vmonto_tot       money(14,2);
    define vexento_isr      char(1);
    define vsector          char(2);
    define vvaloriza        char(1);
    define vcancelad        char(1);
    define vsuccta          char(4);
    define wabreviatura     char(20);
    define wdescripcion     char(30);
    define vfechaproc       date;
    define vporcentaje      decimal(9,6);
    define vtasa_bruta      decimal(9,6);
    define vsobretasa       decimal(9,6);
    define vtpcambval       decimal(14,6);
    define vmonto1          money(14,2);
    define vmonto2          money(14,2);
    define vdivisa_cambio   char(2);
    define vtranprovint     char(4);
    define vcobraisr        char(1);
    define vproceso         char(20);
    define vsistema         char(2);
    define vestatusproc     char(1);
    define vsql             char(600);
    define vstmt            char(250);
    define vusuario         char(10);
    define vhora_tc         datetime hour to minute;
    define vbintarjeta      char(6);   -- PITDC
    define vsecuencia       integer;   -- PITDC
    define vreferencia      char (19); -- PITDC
    define vcuenta          char(20);
    define vsecserv         smallint;
    define vserial_inicial  integer;
    define vserial_final    integer;
    define vexiste          integer;

    let vcodret  = "000";
    let vcodret2 = "";
    let vcodret3 = "";
    let vsqlerr  = 0;
    let visamerr = 0;
    let vdescerr = "";
    let vproceso = "pasechqhiscomp2";
    let vsistema = "01";
    let vestatusproc = "I";
    let vsql     = '';
    let vstmt    = '';
    let vusuario = user;
    let vserial_inicial = 0;
    let vserial_final = 0;
    let vexiste = 0;

    --- set debug file to "/tmp/pasecheqhiscomp2.out";
    --- trace on;

    begin
    
    on exception set vsqlerr, visamerr, vdescerr
        set debug file to "/tmp/pasecheqhiscomp2.out";
        trace on;
        if vsqlerr <> 0 then
            let vcodret = vsqlerr;
            let vcodret2 = visamerr;
            let vcodret3 = vdescerr;
            UPDATE bdinteg:sx_contproc
            SET ejecutivo = vusuario,
            status_proc = 'C',
            codret = vcodret,
            hora_fin = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas)
            WHERE empresa = pempresa
            AND proceso = vproceso
            AND fecha = vfecha_hoy
            AND sistema = vsistema;
            return vcodret;
        end if;
    end exception;
    
    set isolation to dirty read;
    SET OPTIMIZATION HIGH;

    -- // Asigna la fecha de hoy
    let vfecha_hoy = pfechahoy;
    
    -- // GUARDA REGISTRO DE EJECUCIï¿½N
    select count(*)
      into vexiste
      from bdinteg:sx_contproc
     where empresa = pempresa
       and proceso = vproceso
       and fecha   = vfecha_hoy
       and sistema = vsistema;

    if vexiste = 0 then
        INSERT INTO bdinteg:sx_contproc 
            VALUES (pempresa, vproceso, vfecha_hoy, vsistema, 'I', vusuario, (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas), NULL, NULL);
        SYSTEM vsql;
    else
        UPDATE bdinteg:sx_contproc
        SET ejecutivo = vusuario,
        status_proc = 'I',
        codret = ' ',
        hora_fin = ' ',
        hora_ini = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas)
        WHERE empresa = pempresa
        AND proceso = vproceso
        AND fecha = vfecha_hoy
        AND sistema = vsistema;
    end if;

    -- // Verifica se haya iniciado el pase contable principal
    select {+INDEX (bdicheq:sc_contproc idx_contproc2)} fecha 
      into vfechaproc
      from sc_contproc
     where empresa = pempresa 
       and proceso = "inicio_pasehis";
       
    if vfechaproc <> vfecha_hoy then
        let vcodret = "973";        
        return vcodret;
    end if
    
    -- // Extrae parametros globales	
	CALL pasechq_globalvar (pempresa) 
    RETURNING vcodret; 
       
    select valor 
      into vtranprovint
      from sc_param
     where empresa = pempresa 
       and codparam = "tranprov";
       
    -- // Extrae tasa base para el calculo de tasa exenta y param de T+1
    select {+INDEX (bdinteg:si_param ix_si_param)} valor 
      into vdivisa_cambio
      from bdinteg:si_param
     where cod_param > 0
       and empresa = pempresa 
       and descripcion = "divisa cambio";
    
    -- // Extrae tipo de cambio valorizado
    select precio_venta 
      into vtpcambval
      from bdinteg:si_tpcambio
     where empresa = pempresa 
       and divisa = vdivisa_cambio 
       and fecha_tpcambio = vfecha_hoy 
       and clase_tpcambio = "O";
       
    if vtpcambval is null then
        select max(hora_tc) 
          into vhora_tc
          from bdinteg:si_histdiv
         where empresa = pempresa 
           and divisa = vdivisa_cambio 
           and fecha_tc = vfecha_hoy
           and clase_tpcambio = "O";
           
        select precio_venta 
          into vtpcambval
          from bdinteg:si_histdiv
         where empresa = pempresa 
           and divisa = vdivisa_cambio 
           and fecha_tc = vfecha_hoy
           and clase_tpcambio = "O"
           and hora_tc = vhora_tc;
           
        if vtpcambval is null then
            let vtpcambval = 1;
        end if
    end if
    
    -- // OBTINE VALORES PARA RANGO DE SERIALES A PROCESAR
    select valor::integer
      into vserial_inicial
      from sc_param
     where empresa = pempresa
       and codparam = 'SerialIniPaseChqCom2';
       
    select valor::integer
      into vserial_final
      from sc_param
     where empresa = pempresa
       and codparam = 'SerialIniPaseChqCom3';

    -- // CREA TABLA TEMPORAL DEL RANGO DE SERIALES INDICADOS
    select cuenta, sucursal, producto, transacc, monto_tot, cancelad, referencia /* PITDC Se agrega el campo "referencia" para que traiga el numero de tarjeta */
      from sc_movhis
     where fech_alt = vfecha_hoy 
       and num_serial >= vserial_inicial
       and num_serial < vserial_final
      into temp his1 with no log;
    create index inx_temp on his1(cuenta, producto, transacc) using btree fillfactor 99;
    update statistics high for table his1;
		-- // CREA TABLA TEMPORAL DEL CUENTAS X PROCESO CUENTAS SUSPENSO
	select empresa,ccmayor,ccsub,ccsubsub,ccssubsub,ccsssubsub,sector 
      from bdinteg:si_catalog  
      into temp tmp_si_catalog with no log;
	
    create index id1_tmp_si_catalog on tmp_si_catalog (empresa,ccmayor,ccsub,ccsubsub,ccssubsub,ccsssubsub,sector ) using btree fillfactor 99;
    update statistics medium for table tmp_si_catalog;
    
    -- // FOREACH PRINCIPAL
    foreach
        select md.sucursal, md.producto, pr.divisa, md.transacc, md.referencia, 
               md.monto_tot, tp.exento_isr, cl.sector, tr.valoriza, md.cancelad, 
               ac.tasa_bruta, ac.sobretasa, mc.sucursal, tr.descripcion as abreviatura, mc.cobraisr,md.cuenta
          into vsucopero, vproducto, vmoneda, vtransacc,vreferencia, 
               vmonto_tot, vexento_isr, vsector, vvaloriza, vcancelad, 
               vtasa_bruta, vsobretasa, vsuccta, wabreviatura, vcobraisr,vcuenta
          from his1 md,
               sc_maechq mc,
         outer sc_auxcont ac,
               sc_producto pr,
               bdinteg:si_transacc tr, 
               bdinteg:si_cliente cl,
               bdinteg:si_tipper tp
         where md.cuenta = mc.cuenta
           and md.producto = mc.producto
           and md.transacc not in(vgtransacc_t1, vgtransacc_t2, "0231", "0232", "3313", "3314", "0269","1113","1144")
           and md.cancelad <> "S"
           and mc.empresa = pempresa
           and mc.cuenta = md.cuenta
           and ac.empresa = pempresa
           and ac.cuenta = md.cuenta
           and pr.empresa = pempresa
           and pr.producto = md.producto
           and tr.empresa = pempresa
           and tr.numero = md.transacc
           and tr.se_contabiliza = "S"
           and tr.sistema = vg_sistema
           and cl.numcte = mc.num_cte
           and tp.tpo_persona = cl.tpo_persona
        union all
        select md.sucursal, ma.producto, pr.divisa, md.transacc, md.referencia, 
               md.monto_tot, "N", cl.sector, tr.valoriza, md.cancelad, 
               0, 0, ma.sucursal, tr.descripcion as abreviatura, ma.cobraisr,md.cuenta
          from his1 md,
               sc_maechq ma,
               sc_producto pr,
               bdinteg:si_cliente cl,
               bdinteg:si_transacc tr
         where md.cuenta = ma.cuenta
           and md.producto = ma.producto
           and md.transacc in (vgtransacc_t1,vgtransacc_t2,"0231","0232","3313","3314","0269","1113","1144")
           and ma.empresa = pempresa
           and ma.cuenta = md.cuenta
           and pr.empresa = pempresa
           and pr.producto = md.producto
           and cl.numcte = ma.num_cte
           and tr.empresa = pempresa
           and tr.numero = md.transacc
           and tr.se_contabiliza = "S"
           and tr.sistema = vg_sistema
        union all
        select md.sucursal, md.producto, pr.divisa, md.transacc, md.referencia, 
               md.monto_tot, "N", "00", tr.valoriza, md.cancelad, 
               ac.tasa_bruta, ac.sobretasa, md.sucursal, tr.descripcion as abreviatura, 'S', md.cuenta
          from his1 md,
               bditransfer:tf_maecte mc,
         outer sc_auxcont ac,
               sc_producto pr,
               bdinteg:si_transacc tr
         where md.cuenta = mc.cuenta_tf
           and md.transacc not in(vgtransacc_t1, vgtransacc_t2, "0231", "0232", "3313", "3314", "0269","1113","1144")
           and md.cancelad <> "S"
           and mc.cuenta_tf = md.cuenta
           and ac.empresa = pempresa
           and ac.cuenta = md.cuenta
           and pr.empresa = pempresa
           and pr.producto = md.producto
           and tr.empresa = pempresa
           and tr.numero = md.transacc
           and tr.se_contabiliza = "S"
           and tr.sistema = vg_sistema

        let wdescripcion = wabreviatura;
        
        if vcobraisr <> "" then
            if vcobraisr = "S" then
                let vexento_isr = "N";
            else
                let vexento_isr = "S";
            end if
        end if

        -- // Verifica si es Transaccion de provision de Interes
        if vtransacc = vtranprovint then
            if vmoneda = vgcodigo_mn then
                call extrae_cont(pempresa,1,vmonto_tot,vsucopero,vproducto,vmoneda,vtransacc,vsector,vcancelad,vsuccta,wdescripcion) 
                returning vcodret;
                
                continue foreach;
            end if
            
            if vmoneda != vgcodigo_mn and vvaloriza = "S" then
                call extrae_cont(pempresa,1,vmonto_tot,vsucopero,vproducto,vmoneda,vtransacc,vsector,vcancelad,vsuccta,wdescripcion) 
                returning vcodret;
                
                let vmonto2 = vmonto_tot * vtpcambval;
                
                call extrae_cont(pempresa,3,vmonto2,vsucopero,vproducto,vgcodigo_mn,vtransacc,vsector,vcancelad,vsuccta,wdescripcion) 
                returning vcodret;
                
                continue foreach;
            end if
        end if

        -- // Verifica si es movimiento valorizado
        if vmoneda <> vgcodigo_mn and vvaloriza = "S"  then
            let vmonto2 = vmonto_tot * vtpcambval;
            
            call extrae_cont(pempresa,3,vmonto2,vsucopero,vproducto,vgcodigo_mn,vtransacc,vsector,vcancelad,vsuccta,wdescripcion) 
            returning vcodret;
        end if

        if vtransacc <> "0231" and 
           vtransacc <> "0232" and 
           vtransacc <> "3313" and 
           vtransacc <> "3314" and
           vtransacc <> "1193" and 
           vtransacc <> "1195" and
           vtransacc <> vgtransacc_t1 and 
           vtransacc <> "0269" and 
           vtransacc <> "1113" and
           vtransacc <> "1144" and		   
           vtransacc <> vgtransacc_t2 and not  
          (vtransacc="0274" and vproducto="9901") AND NOT 
          (vtransacc="0273" and vproducto="9901") AND NOT 
          (vtransacc="0273" and vproducto = "1600" and vcuenta in ('16000000080')) AND NOT
		  (vtransacc="0273" and vproducto = "1600" and vcuenta in ('16000000322')) AND NOT
          (vtransacc="0273" and vproducto = "2200" and vcuenta in ('22000001574'))   then
            call extrae_cont(pempresa,1,vmonto_tot,vsucopero,vproducto,vmoneda,vtransacc,vsector,vcancelad,vsuccta,wdescripcion)  
            returning vcodret;
        end if
        
        --	// Proceso para PITDC:
        if vtransacc = "1193" or vtransacc = "1195" then
            let vbintarjeta = substr(vreferencia, 1, 6);
            
            -- // Obtener que secuencia debe ser tomada en cuenta:
            SELECT Cod_Reg 
              into vsecuencia 
              FROM BdiSac:Sac_EGlobal_Banco 
             WHERE IdBanco = (SELECT NVL(Id_Bco, 0) 
                                FROM BdiCheq:Sc_Bines 
                               WHERE Bin = vbintarjeta);
             
            if vsecuencia is null then
                let vsecuencia = "3";
            end if;	
            
            call extrae_cont(pempresa,vsecuencia,vmonto_tot,vsucopero,vproducto,vmoneda,vtransacc,vsector,vcancelad,vsuccta,wdescripcion)
            returning vcodret;
     	end if;			

        -- // Contabiliza Camara,231,232,3246,269,1113
        if vtransacc = "0231" or 
           vtransacc = "0232" or
           vtransacc = "3313" or 
           vtransacc = "3314" or
           vtransacc = vgtransacc_t1 or 
           vtransacc = "0269" or 
           vtransacc = "1113" or 		   
           vtransacc = "1144" or
		   vtransacc = vgtransacc_t2 then
            call extrae_cont(pempresa,1,vmonto_tot,vsucopero,vproducto,vmoneda,vtransacc,vsector,vcancelad,vsuccta,wdescripcion)  
            returning vcodret;
            
            if vtransacc = vgtransacc_t1 or vtransacc = "0269" or vtransacc = "1113" or vtransacc = "1144" then
                call extrae_cont(pempresa,2,vmonto_tot,vsucopero,vproducto,vmoneda,vtransacc,vsector,vcancelad,vsuccta,wdescripcion) 
                returning vcodret;
            end if
        end if
        ----SERVICIOS
		if (vtransacc = "0274" and vproducto="9901") OR 
           (vtransacc = "0273" and vproducto="9901") OR 
           (vtransacc = "0273" and vproducto="1600" and vcuenta in ('16000000080')) OR 
		   (vtransacc = "0273" and vproducto="1600" and vcuenta in ('16000000322')) OR 
           (vtransacc = "0273" and vproducto="2200" and vcuenta in ('22000001574')) then

            select {+INDEX (bdisac:sac_catalogo_pt idx_ptcta)} nvl(MAX(secuencia),0) INTO vsecserv from bdisac:sac_catalogo_pt where cuenta=trim(vcuenta); 
            if vsecserv<>0 then
                call extrae_cont(pempresa,vsecserv,vmonto_tot,vsucopero,vproducto,vmoneda,vtransacc,vsector,vcancelad,vsuccta,
				                 case when vcuenta = '22000001574' then 'ABSPEIWU' 
								      WHEN vcuenta = '16000000080' then 'ABSPEIBTS'
									  when vcuenta = '16000000322' then 'ABSPEIAPP' 									  
									  else wdescripcion end)  



                returning vcodret;
            end if;
        end if;
        -----
    end foreach
    
    let vestatusproc = "F";
    
    UPDATE bdinteg:sx_contproc
    SET status_proc = vestatusproc,
    codret = vcodret,
    hora_fin = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas)
    WHERE empresa = pempresa
    AND proceso = vproceso
    AND fecha = vfecha_hoy
    AND sistema = vsistema;
    
    return vcodret;

    end;

end procedure

DOCUMENT
"FUNCIONAMIENTO:SP padre de pase de cheques historicos",
"AJUSTE: Se quitan system",
"FECHA : 24/03/2026",
"DB: bdicheq";

CREATE PROCEDURE "informix".pasecheqhiscomp3(pempresa char(3), pfechahoy date)
RETURNING CHAR(5);
     
    DEFINE GLOBAL vgcodigo_mn           CHAR(2)     DEFAULT ' ';
    DEFINE GLOBAL vg_sistema            CHAR(2)     DEFAULT ' ';
    DEFINE GLOBAL vgtransacc_t1         CHAR(4)     DEFAULT ' ';
    DEFINE GLOBAL vgtransacc_t2         CHAR(4)     DEFAULT ' ';
    DEFINE GLOBAL vgcta_iva             CHAR(20)    DEFAULT ' ';
    DEFINE GLOBAL vgcta_itr             CHAR(20)    DEFAULT ' ';
    DEFINE GLOBAL vgtransacc_corresp    CHAR(4)     DEFAULT ' ';
	DEFINE GLOBAL vfecha_hoy            DATE        DEFAULT TODAY;
    
    define vcodret          char(5);
    define vcodret2         char(5);
    define vcodret3         char(50);
    define vsqlerr          integer;
    define visamerr         integer;
    define vdescerr         char(50);
    define vsucopero        char(4);
    define vproducto        char(4);
    define vmoneda          char(2);
    define vtransacc        char(4);
    define vmonto_tot       money(14,2);
    define vexento_isr      char(1);
    define vsector          char(2);
    define vvaloriza        char(1);
    define vcancelad        char(1);
    define vsuccta          char(4);
    define wabreviatura     char(20);
    define wdescripcion     char(30);
    define vfechaproc       date;
    define vporcentaje      decimal(9,6);
    define vtasa_bruta      decimal(9,6);
    define vsobretasa       decimal(9,6);
    define vtpcambval       decimal(14,6);
    define vmonto1          money(14,2);
    define vmonto2          money(14,2);
    define vdivisa_cambio   char(2);
    define vtranprovint     char(4);
    define vcobraisr        char(1);
    define vproceso         char(20);
    define vsistema         char(2);
    define vestatusproc     char(1);
    define vsql             char(600);
    define vstmt            char(250);
    define vusuario         char(10);
    define vhora_tc         datetime hour to minute;
    define vbintarjeta      char(6);   -- PITDC
    define vsecuencia       integer;   -- PITDC
    define vreferencia      char (19); -- PITDC
    define vcuenta          char(20);
    define vsecserv         smallint;
    define vserial_inicial  integer;
    define vserial_final    integer;
    define vexiste          integer;

    let vcodret  = "000";
    let vcodret2 = "";
    let vcodret3 = "";
    let vsqlerr  = 0;
    let visamerr = 0;
    let vdescerr = "";
    let vproceso = "pasechqhiscomp3";
    let vsistema = "01";
    let vestatusproc = "I";
    let vsql     = '';
    let vstmt    = '';
    let vusuario = user;
    let vserial_inicial = 0;
    let vserial_final = 0;
    let vexiste = 0;

    --- set debug file to "/tmp/pasecheqhiscomp3.out";
    --- trace on;

    begin
    
    on exception set vsqlerr, visamerr, vdescerr
        set debug file to "/tmp/pasecheqhiscomp3.out";
        trace on;
        if vsqlerr <> 0 then
            let vcodret = vsqlerr;
            let vcodret2 = visamerr;
            let vcodret3 = vdescerr;
            UPDATE bdinteg:sx_contproc
            SET ejecutivo = vusuario,
            status_proc = 'C',
            codret = vcodret,
            hora_fin = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas)
            WHERE empresa = pempresa
            AND proceso = vproceso
            AND fecha = vfecha_hoy
            AND sistema = vsistema;
            return vcodret;
        end if;
    end exception;
    
    set isolation to dirty read;
    SET OPTIMIZATION HIGH;

    -- // Asigna la fecha de hoy
    let vfecha_hoy = pfechahoy;
    
    -- // GUARDA REGISTRO DE EJECUCIï¿½N
    select count(*)
      into vexiste
      from bdinteg:sx_contproc
     where empresa = pempresa
       and proceso = vproceso
       and fecha   = vfecha_hoy
       and sistema = vsistema;

    if vexiste = 0 then
        INSERT INTO bdinteg:sx_contproc 
            VALUES (pempresa, vproceso, vfecha_hoy, vsistema, 'I', vusuario, (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas), NULL, NULL);
    else
        UPDATE bdinteg:sx_contproc
        SET ejecutivo = vusuario,
        status_proc = 'I',
        codret = ' ',
        hora_fin = ' ',
        hora_ini = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas)
        WHERE empresa = pempresa
        AND proceso = vproceso
        AND fecha = vfecha_hoy
        AND sistema = vsistema;
    end if;

    -- // Verifica se haya iniciado el pase contable principal
    select {+INDEX (bdicheq:sc_contproc idx_contproc2)} fecha 
      into vfechaproc
      from sc_contproc
     where empresa = pempresa 
       and proceso = "inicio_pasehis";
       
    if vfechaproc <> vfecha_hoy then
        let vcodret = "973";        
        return vcodret;
    end if
    
    -- // Extrae parametros globales	
	CALL pasechq_globalvar (pempresa) 
    RETURNING vcodret; 
       
    select valor 
      into vtranprovint
      from sc_param
     where empresa = pempresa 
       and codparam = "tranprov";
       
    -- // Extrae tasa base para el calculo de tasa exenta y param de T+1
    select {+INDEX (bdinteg:si_param ix_si_param)} valor 
      into vdivisa_cambio
      from bdinteg:si_param
     where cod_param > 0
       and empresa = pempresa 
       and descripcion = "divisa cambio";
    
    -- // Extrae tipo de cambio valorizado
    select precio_venta 
      into vtpcambval
      from bdinteg:si_tpcambio
     where empresa = pempresa 
       and divisa = vdivisa_cambio 
       and fecha_tpcambio = vfecha_hoy 
       and clase_tpcambio = "O";
       
    if vtpcambval is null then
        select max(hora_tc) 
          into vhora_tc
          from bdinteg:si_histdiv
         where empresa = pempresa 
           and divisa = vdivisa_cambio 
           and fecha_tc = vfecha_hoy
           and clase_tpcambio = "O";
           
        select precio_venta 
          into vtpcambval
          from bdinteg:si_histdiv
         where empresa = pempresa 
           and divisa = vdivisa_cambio 
           and fecha_tc = vfecha_hoy
           and clase_tpcambio = "O"
           and hora_tc = vhora_tc;
           
        if vtpcambval is null then
            let vtpcambval = 1;
        end if
    end if
      
    -- // OBTINE VALORES PARA RANGO DE SERIALES A PROCESAR
    select valor::integer
      into vserial_inicial
      from sc_param
     where empresa = pempresa
       and codparam = 'SerialIniPaseChqCom3';
       
    select valor::integer
      into vserial_final
      from sc_param
     where empresa = pempresa
       and codparam = 'SerialIniPaseChqCom4';
       
    -- // CREA TABLA TEMPORAL DEL RANGO DE SERIALES INDICADOS
    select cuenta, sucursal, producto, transacc, monto_tot, cancelad, referencia /* PITDC Se agrega el campo "referencia" para que traiga el numero de tarjeta */
      from sc_movhis
     where fech_alt = vfecha_hoy 
       and num_serial >= vserial_inicial
       and num_serial < vserial_final
      into temp his1 with no log;
    create index inx_temp on his1(cuenta, producto, transacc) using btree fillfactor 99;
    update statistics high for table his1;
		-- // CREA TABLA TEMPORAL DEL CUENTAS X PROCESO CUENTAS SUSPENSO
	select empresa,ccmayor,ccsub,ccsubsub,ccssubsub,ccsssubsub,sector 
      from bdinteg:si_catalog  
      into temp tmp_si_catalog with no log;
	
    create index id1_tmp_si_catalog on tmp_si_catalog (empresa,ccmayor,ccsub,ccsubsub,ccssubsub,ccsssubsub,sector ) using btree fillfactor 99;
    update statistics medium for table tmp_si_catalog;
    
    -- // FOREACH PRINCIPAL
    foreach
        select md.sucursal, md.producto, pr.divisa, md.transacc, md.referencia, 
               md.monto_tot, tp.exento_isr, cl.sector, tr.valoriza, md.cancelad, 
               ac.tasa_bruta, ac.sobretasa, mc.sucursal, tr.descripcion as abreviatura, mc.cobraisr,md.cuenta
          into vsucopero, vproducto, vmoneda, vtransacc,vreferencia, 
               vmonto_tot, vexento_isr, vsector, vvaloriza, vcancelad, 
               vtasa_bruta, vsobretasa, vsuccta, wabreviatura, vcobraisr,vcuenta
          from his1 md,
               sc_maechq mc,
         outer sc_auxcont ac,
               sc_producto pr,
               bdinteg:si_transacc tr, 
               bdinteg:si_cliente cl,
               bdinteg:si_tipper tp
         where md.cuenta = mc.cuenta
           and md.producto = mc.producto
           and md.transacc not in(vgtransacc_t1, vgtransacc_t2, "0231", "0232", "3313", "3314", "0269","1113","1144")
           and md.cancelad <> "S"
           and mc.empresa = pempresa
           and mc.cuenta = md.cuenta
           and ac.empresa = pempresa
           and ac.cuenta = md.cuenta
           and pr.empresa = pempresa
           and pr.producto = md.producto
           and tr.empresa = pempresa
           and tr.numero = md.transacc
           and tr.se_contabiliza = "S"
           and tr.sistema = vg_sistema
           and cl.numcte = mc.num_cte
           and tp.tpo_persona = cl.tpo_persona
        union all
        select md.sucursal, ma.producto, pr.divisa, md.transacc, md.referencia, 
               md.monto_tot, "N", cl.sector, tr.valoriza, md.cancelad, 
               0, 0, ma.sucursal, tr.descripcion as abreviatura, ma.cobraisr,md.cuenta
          from his1 md,
               sc_maechq ma,
               sc_producto pr,
               bdinteg:si_cliente cl,
               bdinteg:si_transacc tr
         where md.cuenta = ma.cuenta
           and md.producto = ma.producto
           and md.transacc in (vgtransacc_t1,vgtransacc_t2,"0231","0232","3313","3314","0269","1113","1144")
           and ma.empresa = pempresa
           and ma.cuenta = md.cuenta
           and pr.empresa = pempresa
           and pr.producto = md.producto
           and cl.numcte = ma.num_cte
           and tr.empresa = pempresa
           and tr.numero = md.transacc
           and tr.se_contabiliza = "S"
           and tr.sistema = vg_sistema
        union all
        select md.sucursal, md.producto, pr.divisa, md.transacc, md.referencia, 
               md.monto_tot, "N", "00", tr.valoriza, md.cancelad, 
               ac.tasa_bruta, ac.sobretasa, md.sucursal, tr.descripcion as abreviatura, 'S', md.cuenta
          from his1 md,
               bditransfer:tf_maecte mc,
         outer sc_auxcont ac,
               sc_producto pr,
               bdinteg:si_transacc tr
         where md.cuenta = mc.cuenta_tf
           and md.transacc not in(vgtransacc_t1, vgtransacc_t2, "0231", "0232", "3313", "3314", "0269","1113","1144")
           and md.cancelad <> "S"
           and mc.cuenta_tf = md.cuenta
           and ac.empresa = pempresa
           and ac.cuenta = md.cuenta
           and pr.empresa = pempresa
           and pr.producto = md.producto
           and tr.empresa = pempresa
           and tr.numero = md.transacc
           and tr.se_contabiliza = "S"
           and tr.sistema = vg_sistema

        let wdescripcion = wabreviatura;
        
        if vcobraisr <> "" then
            if vcobraisr = "S" then
                let vexento_isr = "N";
            else
                let vexento_isr = "S";
            end if
        end if

        -- // Verifica si es Transaccion de provision de Interes
        if vtransacc = vtranprovint then
            if vmoneda = vgcodigo_mn then
                call extrae_cont(pempresa,1,vmonto_tot,vsucopero,vproducto,vmoneda,vtransacc,vsector,vcancelad,vsuccta,wdescripcion) 
                returning vcodret;
                
                continue foreach;
            end if
            
            if vmoneda != vgcodigo_mn and vvaloriza = "S" then
                call extrae_cont(pempresa,1,vmonto_tot,vsucopero,vproducto,vmoneda,vtransacc,vsector,vcancelad,vsuccta,wdescripcion) 
                returning vcodret;
                
                let vmonto2 = vmonto_tot * vtpcambval;
                
                call extrae_cont(pempresa,3,vmonto2,vsucopero,vproducto,vgcodigo_mn,vtransacc,vsector,vcancelad,vsuccta,wdescripcion) 
                returning vcodret;
                
                continue foreach;
            end if
        end if

        -- // Verifica si es movimiento valorizado
        if vmoneda <> vgcodigo_mn and vvaloriza = "S"  then
            let vmonto2 = vmonto_tot * vtpcambval;
            
            call extrae_cont(pempresa,3,vmonto2,vsucopero,vproducto,vgcodigo_mn,vtransacc,vsector,vcancelad,vsuccta,wdescripcion) 
            returning vcodret;
        end if

        if vtransacc <> "0231" and 
           vtransacc <> "0232" and 
           vtransacc <> "3313" and 
           vtransacc <> "3314" and
           vtransacc <> "1193" and 
           vtransacc <> "1195" and
           vtransacc <> vgtransacc_t1 and 
           vtransacc <> "0269" and 
           vtransacc <> "1113" and
           vtransacc <> "1144" and		   
           vtransacc <> vgtransacc_t2 and not  
          (vtransacc="0274" and vproducto="9901") AND NOT 
          (vtransacc="0273" and vproducto="9901") AND NOT 
          (vtransacc="0273" and vproducto = "1600" and vcuenta in ('16000000080')) AND NOT
		  (vtransacc="0273" and vproducto = "1600" and vcuenta in ('16000000322')) AND NOT
          (vtransacc="0273" and vproducto = "2200" and vcuenta in ('22000001574'))   then
            call extrae_cont(pempresa,1,vmonto_tot,vsucopero,vproducto,vmoneda,vtransacc,vsector,vcancelad,vsuccta,wdescripcion)  
            returning vcodret;
        end if
        
        --	// Proceso para PITDC:
        if vtransacc = "1193" or vtransacc = "1195" then
            let vbintarjeta = substr(vreferencia, 1, 6);
            
            -- // Obtener que secuencia debe ser tomada en cuenta:
            SELECT Cod_Reg 
              into vsecuencia 
              FROM BdiSac:Sac_EGlobal_Banco 
             WHERE IdBanco = (SELECT NVL(Id_Bco, 0) 
                                FROM BdiCheq:Sc_Bines 
                               WHERE Bin = vbintarjeta);
             
            if vsecuencia is null then
                let vsecuencia = "3";
            end if;	
            
            call extrae_cont(pempresa,vsecuencia,vmonto_tot,vsucopero,vproducto,vmoneda,vtransacc,vsector,vcancelad,vsuccta,wdescripcion)
            returning vcodret;
     	end if;			

        -- // Contabiliza Camara,231,232,3246,269,1113
        if vtransacc = "0231" or 
           vtransacc = "0232" or
           vtransacc = "3313" or 
           vtransacc = "3314" or
           vtransacc = vgtransacc_t1 or 
           vtransacc = "0269" or 
           vtransacc = "1113" or 		   
           vtransacc = "1144" or
		   vtransacc = vgtransacc_t2 then
            call extrae_cont(pempresa,1,vmonto_tot,vsucopero,vproducto,vmoneda,vtransacc,vsector,vcancelad,vsuccta,wdescripcion)  
            returning vcodret;
            
            if vtransacc = vgtransacc_t1 or vtransacc = "0269" or vtransacc = "1113" or vtransacc = "1144" then
                call extrae_cont(pempresa,2,vmonto_tot,vsucopero,vproducto,vmoneda,vtransacc,vsector,vcancelad,vsuccta,wdescripcion) 
                returning vcodret;
            end if
        end if
        ----SERVICIOS
		if (vtransacc = "0274" and vproducto="9901") OR 
           (vtransacc = "0273" and vproducto="9901") OR 
           (vtransacc = "0273" and vproducto="1600" and vcuenta in ('16000000080')) OR 
		   (vtransacc = "0273" and vproducto="1600" and vcuenta in ('16000000322')) OR 
           (vtransacc = "0273" and vproducto="2200" and vcuenta in ('22000001574')) then

            select {+INDEX (bdisac:sac_catalogo_pt idx_ptcta)} nvl(MAX(secuencia),0) INTO vsecserv from bdisac:sac_catalogo_pt where cuenta=trim(vcuenta); 
            if vsecserv<>0 then

                call extrae_cont(pempresa,vsecserv,vmonto_tot,vsucopero,vproducto,vmoneda,vtransacc,vsector,vcancelad,vsuccta,
				                 case when vcuenta = '22000001574' then 'ABSPEIWU' 
								      WHEN vcuenta = '16000000080' then 'ABSPEIBTS'
									  when vcuenta = '16000000322' then 'ABSPEIAPP' 									  
									  else wdescripcion end)  


                returning vcodret;
            end if;
        end if;
        -----
    end foreach
    
    let vestatusproc = "F";
    
    UPDATE bdinteg:sx_contproc
    SET status_proc = vestatusproc,
    codret = vcodret,
    hora_fin = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas)
    WHERE empresa = pempresa
    AND proceso = vproceso
    AND fecha = vfecha_hoy
    AND sistema = vsistema;

    return vcodret;

    end;

end procedure

DOCUMENT
"FUNCIONAMIENTO:SP padre de pase de cheques historicos",
"AJUSTE: Se quitan system",
"FECHA : 24/03/2026",
"DB: bdicheq";

CREATE PROCEDURE "informix".pasecheqhiscomp4(pempresa char(3), pfechahoy date)
RETURNING CHAR(5);
     
    DEFINE GLOBAL vgcodigo_mn           CHAR(2)     DEFAULT ' ';
    DEFINE GLOBAL vg_sistema            CHAR(2)     DEFAULT ' ';
    DEFINE GLOBAL vgtransacc_t1         CHAR(4)     DEFAULT ' ';
    DEFINE GLOBAL vgtransacc_t2         CHAR(4)     DEFAULT ' ';
    DEFINE GLOBAL vgcta_iva             CHAR(20)    DEFAULT ' ';
    DEFINE GLOBAL vgcta_itr             CHAR(20)    DEFAULT ' ';
    DEFINE GLOBAL vgtransacc_corresp    CHAR(4)     DEFAULT ' ';
	DEFINE GLOBAL vfecha_hoy            DATE        DEFAULT TODAY;
    
    define vcodret          char(5);
    define vcodret2         char(5);
    define vcodret3         char(50);
    define vsqlerr          integer;
    define visamerr         integer;
    define vdescerr         char(50);
    define vsucopero        char(4);
    define vproducto        char(4);
    define vmoneda          char(2);
    define vtransacc        char(4);
    define vmonto_tot       money(14,2);
    define vexento_isr      char(1);
    define vsector          char(2);
    define vvaloriza        char(1);
    define vcancelad        char(1);
    define vsuccta          char(4);
    define wabreviatura     char(20);
    define wdescripcion     char(30);
    define vfechaproc       date;
    define vporcentaje      decimal(9,6);
    define vtasa_bruta      decimal(9,6);
    define vsobretasa       decimal(9,6);
    define vtpcambval       decimal(14,6);
    define vmonto1          money(14,2);
    define vmonto2          money(14,2);
    define vdivisa_cambio   char(2);
    define vtranprovint     char(4);
    define vcobraisr        char(1);
    define vproceso         char(20);
    define vsistema         char(2);
    define vestatusproc     char(1);
    define vsql             char(600);
    define vstmt            char(250);
    define vusuario         char(10);
    define vhora_tc         datetime hour to minute;
    define vbintarjeta      char(6);   -- PITDC
    define vsecuencia       integer;   -- PITDC
    define vreferencia      char (19); -- PITDC
    define vcuenta          char(20);
    define vsecserv         smallint;
    define vserial_inicial  integer;
    define vserial_final    integer;
    define vexiste          integer;

    let vcodret  = "000";
    let vcodret2 = "";
    let vcodret3 = "";
    let vsqlerr  = 0;
    let visamerr = 0;
    let vdescerr = "";
    let vproceso = "pasechqhiscomp4";
    let vsistema = "01";
    let vestatusproc = "I";
    let vsql     = '';
    let vstmt    = '';
    let vusuario = user;
    let vserial_inicial = 0;
    let vserial_final = 0;
    let vexiste = 0;

    --- set debug file to "/tmp/pasecheqhiscomp4.out";
    --- trace on;

    begin
    
    on exception set vsqlerr, visamerr, vdescerr
        set debug file to "/tmp/pasecheqhiscomp4.out";
        trace on;
        if vsqlerr <> 0 then
            let vcodret = vsqlerr;
            let vcodret2 = visamerr;
            let vcodret3 = vdescerr;
            UPDATE bdinteg:sx_contproc
            SET ejecutivo = vusuario,
            status_proc = 'C',
            codret = vcodret,
            hora_fin = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas)
            WHERE empresa = pempresa
            AND proceso = vproceso
            AND fecha = vfecha_hoy
            AND sistema = vsistema;
            return vcodret;
        end if;
    end exception;
    
    set isolation to dirty read;
    SET OPTIMIZATION HIGH;

    -- // Asigna la fecha de hoy
    let vfecha_hoy = pfechahoy;
    
    -- // GUARDA REGISTRO DE EJECUCIï¿½N
    select count(*)
      into vexiste
      from bdinteg:sx_contproc
     where empresa = pempresa
       and proceso = vproceso
       and fecha   = vfecha_hoy
       and sistema = vsistema;

    if vexiste = 0 then
        INSERT INTO bdinteg:sx_contproc
            VALUES (pempresa, vproceso, vfecha_hoy, vsistema, 'I', vusuario, (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas), NULL, NULL);          
    else
        UPDATE bdinteg:sx_contproc
        SET ejecutivo = vusuario,
        status_proc   = 'I',
        codret = ' ',
        hora_fin = ' ',
        hora_ini = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas)
        WHERE empresa = pempresa
        AND proceso = vproceso
        AND fecha = vfecha_hoy
        AND sistema = vsistema;
    end if;

    -- // Verifica se haya iniciado el pase contable principal
    select {+INDEX (bdicheq:sc_contproc idx_contproc2)} fecha 
      into vfechaproc
      from sc_contproc
     where empresa = pempresa 
       and proceso = "inicio_pasehis";
       
    if vfechaproc <> vfecha_hoy then
        let vcodret = "973";        
        return vcodret;
    end if
    
    -- // Extrae parametros globales	
	CALL pasechq_globalvar (pempresa) 
    RETURNING vcodret; 
       
    select valor 
      into vtranprovint
      from sc_param
     where empresa = pempresa 
       and codparam = "tranprov";
       
    -- // Extrae tasa base para el calculo de tasa exenta y param de T+1
    select {+INDEX (bdinteg:si_param ix_si_param)} valor 
      into vdivisa_cambio
      from bdinteg:si_param
     where cod_param > 0
       and empresa = pempresa 
       and descripcion = "divisa cambio";
    
    -- // Extrae tipo de cambio valorizado
    select precio_venta 
      into vtpcambval
      from bdinteg:si_tpcambio
     where empresa = pempresa 
       and divisa = vdivisa_cambio 
       and fecha_tpcambio = vfecha_hoy 
       and clase_tpcambio = "O";
       
    if vtpcambval is null then
        select max(hora_tc) 
          into vhora_tc
          from bdinteg:si_histdiv
         where empresa = pempresa 
           and divisa = vdivisa_cambio 
           and fecha_tc = vfecha_hoy
           and clase_tpcambio = "O";
           
        select precio_venta 
          into vtpcambval
          from bdinteg:si_histdiv
         where empresa = pempresa 
           and divisa = vdivisa_cambio 
           and fecha_tc = vfecha_hoy
           and clase_tpcambio = "O"
           and hora_tc = vhora_tc;
           
        if vtpcambval is null then
            let vtpcambval = 1;
        end if
    end if
    
    -- // OBTINE VALORES PARA RANGO DE SERIALES A PROCESAR
    select valor::integer
      into vserial_inicial
      from sc_param
     where empresa = pempresa
       and codparam = 'SerialIniPaseChqCom4';
       
    select valor::integer
      into vserial_final
      from sc_param
     where empresa = pempresa
       and codparam = 'SerialIniPaseChqCom5';

    -- // CREA TABLA TEMPORAL DEL RANGO DE SERIALES INDICADOS
    select cuenta, sucursal, producto, transacc, monto_tot, cancelad, referencia /* PITDC. Se agrega el campo "referencia" para que traiga el numero de tarjeta */
      from sc_movhis
     where fech_alt = vfecha_hoy 
       and num_serial >= vserial_inicial
       and num_serial < vserial_final
      into temp his1 with no log;
    create index inx_temp on his1(cuenta, producto, transacc) using btree fillfactor 99;
    update statistics high for table his1;
	
		-- // CREA TABLA TEMPORAL DEL CUENTAS X PROCESO CUENTAS SUSPENSO
	select empresa,ccmayor,ccsub,ccsubsub,ccssubsub,ccsssubsub,sector 
      from bdinteg:si_catalog  
      into temp tmp_si_catalog with no log;
	
    create index id1_tmp_si_catalog on tmp_si_catalog (empresa,ccmayor,ccsub,ccsubsub,ccssubsub,ccsssubsub,sector ) using btree fillfactor 99;
    update statistics medium for table tmp_si_catalog;	
    
    -- // FOREACH PRINCIPAL
    foreach
        select md.sucursal, md.producto, pr.divisa, md.transacc, md.referencia, 
               md.monto_tot, tp.exento_isr, cl.sector, tr.valoriza, md.cancelad, 
               ac.tasa_bruta, ac.sobretasa, mc.sucursal, tr.descripcion as abreviatura, mc.cobraisr,md.cuenta
          into vsucopero, vproducto, vmoneda, vtransacc,vreferencia, 
               vmonto_tot, vexento_isr, vsector, vvaloriza, vcancelad, 
               vtasa_bruta, vsobretasa, vsuccta, wabreviatura, vcobraisr,vcuenta
          from his1 md,
               sc_maechq mc,
         outer sc_auxcont ac,
               sc_producto pr,
               bdinteg:si_transacc tr, 
               bdinteg:si_cliente cl,
               bdinteg:si_tipper tp
         where md.cuenta = mc.cuenta
           and md.producto = mc.producto
           and md.transacc not in(vgtransacc_t1, vgtransacc_t2, "0231", "0232", "3313", "3314", "0269","1113","1144")
           and md.cancelad <> "S"
           and mc.empresa = pempresa
           and mc.cuenta = md.cuenta
           and ac.empresa = pempresa
           and ac.cuenta = md.cuenta
           and pr.empresa = pempresa
           and pr.producto = md.producto
           and tr.empresa = pempresa
           and tr.numero = md.transacc
           and tr.se_contabiliza = "S"
           and tr.sistema = vg_sistema
           and cl.numcte = mc.num_cte
           and tp.tpo_persona = cl.tpo_persona
        union all
        select md.sucursal, ma.producto, pr.divisa, md.transacc, md.referencia, 
               md.monto_tot, "N", cl.sector, tr.valoriza, md.cancelad, 
               0, 0, ma.sucursal, tr.descripcion as abreviatura, ma.cobraisr,md.cuenta
          from his1 md,
               sc_maechq ma,
               sc_producto pr,
               bdinteg:si_cliente cl,
               bdinteg:si_transacc tr
         where md.cuenta = ma.cuenta
           and md.producto = ma.producto
           and md.transacc in (vgtransacc_t1,vgtransacc_t2,"0231","0232","3313","3314","0269","1113","1144")
           and ma.empresa = pempresa
           and ma.cuenta = md.cuenta
           and pr.empresa = pempresa
           and pr.producto = md.producto
           and cl.numcte = ma.num_cte
           and tr.empresa = pempresa
           and tr.numero = md.transacc
           and tr.se_contabiliza = "S"
           and tr.sistema = vg_sistema
        union all
        select md.sucursal, md.producto, pr.divisa, md.transacc, md.referencia, 
               md.monto_tot, "N", "00", tr.valoriza, md.cancelad, 
               ac.tasa_bruta, ac.sobretasa, md.sucursal, tr.descripcion as abreviatura, 'S', md.cuenta
          from his1 md,
               bditransfer:tf_maecte mc,
         outer sc_auxcont ac,
               sc_producto pr,
               bdinteg:si_transacc tr
         where md.cuenta = mc.cuenta_tf
           and md.transacc not in(vgtransacc_t1, vgtransacc_t2, "0231", "0232", "3313", "3314", "0269","1113","1144")
           and md.cancelad <> "S"
           and mc.cuenta_tf = md.cuenta
           and ac.empresa = pempresa
           and ac.cuenta = md.cuenta
           and pr.empresa = pempresa
           and pr.producto = md.producto
           and tr.empresa = pempresa
           and tr.numero = md.transacc
           and tr.se_contabiliza = "S"
           and tr.sistema = vg_sistema
        
        let wdescripcion = wabreviatura;
        
        if vcobraisr <> "" then
            if vcobraisr = "S" then
                let vexento_isr = "N";
            else
                let vexento_isr = "S";
            end if
        end if

        -- // Verifica si es Transaccion de provision de Interes
        if vtransacc = vtranprovint then
            if vmoneda = vgcodigo_mn then
                call extrae_cont(pempresa,1,vmonto_tot,vsucopero,vproducto,vmoneda,vtransacc,vsector,vcancelad,vsuccta,wdescripcion) 
                returning vcodret;
                
                continue foreach;
            end if
            
            if vmoneda != vgcodigo_mn and vvaloriza = "S" then
                call extrae_cont(pempresa,1,vmonto_tot,vsucopero,vproducto,vmoneda,vtransacc,vsector,vcancelad,vsuccta,wdescripcion) 
                returning vcodret;
                
                let vmonto2 = vmonto_tot * vtpcambval;
                
                call extrae_cont(pempresa,3,vmonto2,vsucopero,vproducto,vgcodigo_mn,vtransacc,vsector,vcancelad,vsuccta,wdescripcion) 
                returning vcodret;
                
                continue foreach;
            end if
        end if

        -- // Verifica si es movimiento valorizado
        if vmoneda <> vgcodigo_mn and vvaloriza = "S"  then
            let vmonto2 = vmonto_tot * vtpcambval;
            
            call extrae_cont(pempresa,3,vmonto2,vsucopero,vproducto,vgcodigo_mn,vtransacc,vsector,vcancelad,vsuccta,wdescripcion) 
            returning vcodret;
        end if
        if vtransacc <> "0231" and 
           vtransacc <> "0232" and 
           vtransacc <> "3313" and 
           vtransacc <> "3314" and
           vtransacc <> "1193" and 
           vtransacc <> "1195" and
           vtransacc <> vgtransacc_t1 and 
           vtransacc <> "0269" and 
           vtransacc <> "1113" and
           vtransacc <> "1144" and		   
           vtransacc <> vgtransacc_t2 and not  
          (vtransacc="0274" and vproducto="9901") AND NOT 
          (vtransacc="0273" and vproducto="9901") AND NOT 
          (vtransacc="0273" and vproducto = "1600" and vcuenta in ('16000000080')) AND NOT
		  (vtransacc="0273" and vproducto = "1600" and vcuenta in ('16000000322')) AND NOT
          (vtransacc="0273" and vproducto = "2200" and vcuenta in ('22000001574'))   then
            call extrae_cont(pempresa,1,vmonto_tot,vsucopero,vproducto,vmoneda,vtransacc,vsector,vcancelad,vsuccta,wdescripcion)  
            returning vcodret;
        end if
        
        --	// Proceso para PITDC:
        if vtransacc = "1193" or vtransacc = "1195" then
            let vbintarjeta = substr(vreferencia, 1, 6);
            
            -- // Obtener que secuencia debe ser tomada en cuenta:
            SELECT Cod_Reg 
              into vsecuencia 
              FROM BdiSac:Sac_EGlobal_Banco 
             WHERE IdBanco = (SELECT NVL(Id_Bco, 0) 
                                FROM BdiCheq:Sc_Bines 
                               WHERE Bin = vbintarjeta);
             
            if vsecuencia is null then
                let vsecuencia = "3";
            end if;	
            
            call extrae_cont(pempresa,vsecuencia,vmonto_tot,vsucopero,vproducto,vmoneda,vtransacc,vsector,vcancelad,vsuccta,wdescripcion)
            returning vcodret;
     	end if;			

        -- // Contabiliza Camara,231,232,3246,269,1113
        if vtransacc = "0231" or 
           vtransacc = "0232" or
           vtransacc = "3313" or 
           vtransacc = "3314" or
           vtransacc = vgtransacc_t1 or 
           vtransacc = "0269" or 
           vtransacc = "1113" or 		   
           vtransacc = "1144" or
		   vtransacc = vgtransacc_t2 then
            call extrae_cont(pempresa,1,vmonto_tot,vsucopero,vproducto,vmoneda,vtransacc,vsector,vcancelad,vsuccta,wdescripcion)  
            returning vcodret;
            
            if vtransacc = vgtransacc_t1 or vtransacc = "0269" or vtransacc = "1113" or vtransacc = "1144" then
                call extrae_cont(pempresa,2,vmonto_tot,vsucopero,vproducto,vmoneda,vtransacc,vsector,vcancelad,vsuccta,wdescripcion) 
                returning vcodret;
            end if
        end if
        ----SERVICIOS
		if (vtransacc = "0274" and vproducto="9901") OR 
           (vtransacc = "0273" and vproducto="9901") OR 
           (vtransacc = "0273" and vproducto="1600" and vcuenta in ('16000000080')) OR 
		   (vtransacc = "0273" and vproducto="1600" and vcuenta in ('16000000322')) OR 
           (vtransacc = "0273" and vproducto="2200" and vcuenta in ('22000001574')) then

            select {+INDEX (bdisac:sac_catalogo_pt idx_ptcta)} nvl(MAX(secuencia),0) INTO vsecserv from bdisac:sac_catalogo_pt where cuenta=trim(vcuenta); 
            if vsecserv<>0 then

                call extrae_cont(pempresa,vsecserv,vmonto_tot,vsucopero,vproducto,vmoneda,vtransacc,vsector,vcancelad,vsuccta,
				                 case when vcuenta = '22000001574' then 'ABSPEIWU' 
								      WHEN vcuenta = '16000000080' then 'ABSPEIBTS'
									  when vcuenta = '16000000322' then 'ABSPEIAPP' 									  
									  else wdescripcion end)  


                returning vcodret;
            end if;
        end if;
        -----
    end foreach
    
    let vestatusproc = "F";
    
    UPDATE bdinteg:sx_contproc
    SET status_proc = vestatusproc,
    codret = vcodret,
    hora_fin = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas)
    WHERE empresa = pempresa
    AND proceso = vproceso
    AND fecha = vfecha_hoy
    AND sistema = vsistema;
    
    return vcodret;

    end;

end procedure

DOCUMENT
"FUNCIONAMIENTO:SP padre de pase de cheques historicos",
"AJUSTE: Se quitan system",
"FECHA : 24/03/2026",
"DB: bdicheq";

CREATE PROCEDURE "informix".pasecheqhiscomp5(pempresa char(3), pfechahoy date)
RETURNING CHAR(5);
     
    DEFINE GLOBAL vgcodigo_mn           CHAR(2)     DEFAULT ' ';
    DEFINE GLOBAL vg_sistema            CHAR(2)     DEFAULT ' ';
    DEFINE GLOBAL vgtransacc_t1         CHAR(4)     DEFAULT ' ';
    DEFINE GLOBAL vgtransacc_t2         CHAR(4)     DEFAULT ' ';
    DEFINE GLOBAL vgcta_iva             CHAR(20)    DEFAULT ' ';
    DEFINE GLOBAL vgcta_itr             CHAR(20)    DEFAULT ' ';
    DEFINE GLOBAL vgtransacc_corresp    CHAR(4)     DEFAULT ' ';
	DEFINE GLOBAL vfecha_hoy            DATE        DEFAULT TODAY;
    
    define vcodret          char(5);
    define vcodret2         char(5);
    define vcodret3         char(50);
    define vsqlerr          integer;
    define visamerr         integer;
    define vdescerr         char(50);
    define vsucopero        char(4);
    define vproducto        char(4);
    define vmoneda          char(2);
    define vtransacc        char(4);
    define vmonto_tot       money(14,2);
    define vexento_isr      char(1);
    define vsector          char(2);
    define vvaloriza        char(1);
    define vcancelad        char(1);
    define vsuccta          char(4);
    define wabreviatura     char(20);
    define wdescripcion     char(30);
    define vfechaproc       date;
    define vporcentaje      decimal(9,6);
    define vtasa_bruta      decimal(9,6);
    define vsobretasa       decimal(9,6);
    define vtpcambval       decimal(14,6);
    define vmonto1          money(14,2);
    define vmonto2          money(14,2);
    define vdivisa_cambio   char(2);
    define vtranprovint     char(4);
    define vcobraisr        char(1);
    define vproceso         char(20);
    define vsistema         char(2);
    define vestatusproc     char(1);
    define vsql             char(600);
    define vstmt            char(250);
    define vusuario         char(10);
    define vhora_tc         datetime hour to minute;
    define vbintarjeta      char(6);   -- PITDC
    define vsecuencia       integer;   -- PITDC
    define vreferencia      char (19); -- PITDC
    define vcuenta          char(20);
    define vsecserv         smallint;
    define vserial_inicial  integer;
    define vserial_final    integer;
    define vexiste          integer;

    let vcodret  = "000";
    let vcodret2 = "";
    let vcodret3 = "";
    let vsqlerr  = 0;
    let visamerr = 0;
    let vdescerr = "";
    let vproceso = "pasechqhiscomp5";
    let vsistema = "01";
    let vestatusproc = "I";
    let vsql     = '';
    let vstmt    = '';
    let vusuario = user;
    let vserial_inicial = 0;
    let vserial_final = 0;
    let vexiste = 0;

    --- set debug file to "/tmp/pasecheqhiscomp5.out";
    --- trace on;

    begin
    
    on exception set vsqlerr, visamerr, vdescerr
        set debug file to "/tmp/pasecheqhiscomp5.out";
        trace on;
        if vsqlerr <> 0 then
            let vcodret = vsqlerr;
            let vcodret2 = visamerr;
            let vcodret3 = vdescerr;
            UPDATE bdinteg:sx_contproc
            SET ejecutivo = vusuario,
            status_proc = 'C',
            codret = vcodret,
            hora_fin = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas)
            WHERE empresa = pempresa
            AND proceso = vproceso
            AND fecha = vfecha_hoy
            AND sistema = vsistema;
            
            return vcodret;
        end if;
    end exception;
    
    set isolation to dirty read;
    SET OPTIMIZATION HIGH;

    -- // Asigna la fecha de hoy
    let vfecha_hoy = pfechahoy;
    
    -- // GUARDA REGISTRO DE EJECUCIï¿½N
    select count(*)
      into vexiste
      from bdinteg:sx_contproc
     where empresa = pempresa
       and proceso = vproceso
       and fecha   = vfecha_hoy
       and sistema = vsistema;

    if vexiste = 0 then
        INSERT INTO bdinteg:sx_contproc
            VALUES (pempresa, vproceso, vfecha_hoy, vsistema, 'I', vusuario, (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas), NULL, NULL);
    else
        UPDATE bdinteg:sx_contproc
        SET ejecutivo = vusuario,
        status_proc = 'I',
        codret = ' ',
        hora_fin = ' ',
        hora_ini = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas)
        WHERE empresa = pempresa
        AND proceso = vproceso
        AND fecha = vfecha_hoy
        AND sistema = vsistema;
    end if;

    -- // Verifica se haya iniciado el pase contable principal
    select {+INDEX (bdicheq:sc_contproc idx_contproc2)} fecha 
      into vfechaproc
      from sc_contproc
     where empresa = pempresa 
       and proceso = "inicio_pasehis";
       
    if vfechaproc <> vfecha_hoy then
        let vcodret = "973";        
        return vcodret;
    end if

    -- // Extrae parametros globales	
	CALL pasechq_globalvar (pempresa) 
    RETURNING vcodret; 
       
    select valor 
      into vtranprovint
      from sc_param
     where empresa = pempresa 
       and codparam = "tranprov";
       
    -- // Extrae tasa base para el calculo de tasa exenta y param de T+1
    select {+INDEX (bdinteg:si_param ix_si_param)} valor 
      into vdivisa_cambio
      from bdinteg:si_param
     where cod_param > 0
       and empresa = pempresa 
       and descripcion = "divisa cambio";
    
    -- // Extrae tipo de cambio valorizado
    select precio_venta 
      into vtpcambval
      from bdinteg:si_tpcambio
     where empresa = pempresa 
       and divisa = vdivisa_cambio 
       and fecha_tpcambio = vfecha_hoy 
       and clase_tpcambio = "O";
       
    if vtpcambval is null then
        select max(hora_tc) 
          into vhora_tc
          from bdinteg:si_histdiv
         where empresa = pempresa 
           and divisa = vdivisa_cambio 
           and fecha_tc = vfecha_hoy
           and clase_tpcambio = "O";
           
        select precio_venta 
          into vtpcambval
          from bdinteg:si_histdiv
         where empresa = pempresa 
           and divisa = vdivisa_cambio 
           and fecha_tc = vfecha_hoy
           and clase_tpcambio = "O"
           and hora_tc = vhora_tc;
           
        if vtpcambval is null then
            let vtpcambval = 1;
        end if
    end if
    
    -- // OBTINE VALORES PARA RANGO DE SERIALES A PROCESAR
    select valor::integer
      into vserial_inicial
      from sc_param
     where empresa = pempresa
       and codparam = 'SerialIniPaseChqCom5';
    
    -- // CREA TABLA TEMPORAL DEL RANGO DE SERIALES INDICADOS
    select cuenta, sucursal, producto, transacc, monto_tot, cancelad, referencia /* PITDC Se agrega el campo "referencia" para que traiga el numero de tarjeta */
      from sc_movhis
     where fech_alt = vfecha_hoy 
       and num_serial >= vserial_inicial
      into temp his1 with no log;
    create index inx_temp on his1(cuenta, producto, transacc) using btree fillfactor 99;
    update statistics high for table his1;
		-- // CREA TABLA TEMPORAL DEL CUENTAS X PROCESO CUENTAS SUSPENSO
	select empresa,ccmayor,ccsub,ccsubsub,ccssubsub,ccsssubsub,sector 
      from bdinteg:si_catalog  
      into temp tmp_si_catalog with no log;
	
    create index id1_tmp_si_catalog on tmp_si_catalog (empresa,ccmayor,ccsub,ccsubsub,ccssubsub,ccsssubsub,sector ) using btree fillfactor 99;
    update statistics medium for table tmp_si_catalog;
    
    -- // FOREACH PRINCIPAL
    foreach
        select md.sucursal, md.producto, pr.divisa, md.transacc, md.referencia, 
               md.monto_tot, tp.exento_isr, cl.sector, tr.valoriza, md.cancelad, 
               ac.tasa_bruta, ac.sobretasa, mc.sucursal, tr.descripcion as abreviatura, mc.cobraisr,md.cuenta
          into vsucopero, vproducto, vmoneda, vtransacc,vreferencia, 
               vmonto_tot, vexento_isr, vsector, vvaloriza, vcancelad, 
               vtasa_bruta, vsobretasa, vsuccta, wabreviatura, vcobraisr,vcuenta
          from his1 md,
               sc_maechq mc,
         outer sc_auxcont ac,
               sc_producto pr,
               bdinteg:si_transacc tr, 
               bdinteg:si_cliente cl,
               bdinteg:si_tipper tp
         where md.cuenta = mc.cuenta
           and md.producto = mc.producto
           and md.transacc not in(vgtransacc_t1, vgtransacc_t2, "0231", "0232", "3313", "3314", "0269","1113","1144")
           and md.cancelad <> "S"
           and mc.empresa = pempresa
           and mc.cuenta = md.cuenta
           and ac.empresa = pempresa
           and ac.cuenta = md.cuenta
           and pr.empresa = pempresa
           and pr.producto = md.producto
           and tr.empresa = pempresa
           and tr.numero = md.transacc
           and tr.se_contabiliza = "S"
           and tr.sistema = vg_sistema
           and cl.numcte = mc.num_cte
           and tp.tpo_persona = cl.tpo_persona
        union all
        select md.sucursal, ma.producto, pr.divisa, md.transacc, md.referencia, 
               md.monto_tot, "N", cl.sector, tr.valoriza, md.cancelad, 
               0, 0, ma.sucursal, tr.descripcion as abreviatura, ma.cobraisr,md.cuenta
          from his1 md,
               sc_maechq ma,
               sc_producto pr,
               bdinteg:si_cliente cl,
               bdinteg:si_transacc tr
         where md.cuenta = ma.cuenta
           and md.producto = ma.producto
           and md.transacc in (vgtransacc_t1,vgtransacc_t2,"0231","0232","3313","3314","0269","1113","1144")
           and ma.empresa = pempresa
           and ma.cuenta = md.cuenta
           and pr.empresa = pempresa
           and pr.producto = md.producto
           and cl.numcte = ma.num_cte
           and tr.empresa = pempresa
           and tr.numero = md.transacc
           and tr.se_contabiliza = "S"
           and tr.sistema = vg_sistema
        union all
        select md.sucursal, md.producto, pr.divisa, md.transacc, md.referencia, 
               md.monto_tot, "N", "00", tr.valoriza, md.cancelad, 
               ac.tasa_bruta, ac.sobretasa, md.sucursal, tr.descripcion as abreviatura, 'S', md.cuenta
          from his1 md,
               bditransfer:tf_maecte mc,
         outer sc_auxcont ac,
               sc_producto pr,
               bdinteg:si_transacc tr
         where md.cuenta = mc.cuenta_tf
           and md.transacc not in(vgtransacc_t1, vgtransacc_t2, "0231", "0232", "3313", "3314", "0269","1113","1144")
           and md.cancelad <> "S"
           and mc.cuenta_tf = md.cuenta
           and ac.empresa = pempresa
           and ac.cuenta = md.cuenta
           and pr.empresa = pempresa
           and pr.producto = md.producto
           and tr.empresa = pempresa
           and tr.numero = md.transacc
           and tr.se_contabiliza = "S"
           and tr.sistema = vg_sistema

        let wdescripcion = wabreviatura;
        
        if vcobraisr <> "" then
            if vcobraisr = "S" then
                let vexento_isr = "N";
            else
                let vexento_isr = "S";
            end if
        end if

        -- // Verifica si es Transaccion de provision de Interes
        if vtransacc = vtranprovint then
            if vmoneda = vgcodigo_mn then
                call extrae_cont(pempresa,1,vmonto_tot,vsucopero,vproducto,vmoneda,vtransacc,vsector,vcancelad,vsuccta,wdescripcion) 
                returning vcodret;
                
                continue foreach;
            end if
            
            if vmoneda != vgcodigo_mn and vvaloriza = "S" then
                call extrae_cont(pempresa,1,vmonto_tot,vsucopero,vproducto,vmoneda,vtransacc,vsector,vcancelad,vsuccta,wdescripcion) 
                returning vcodret;
                
                let vmonto2 = vmonto_tot * vtpcambval;
                
                call extrae_cont(pempresa,3,vmonto2,vsucopero,vproducto,vgcodigo_mn,vtransacc,vsector,vcancelad,vsuccta,wdescripcion) 
                returning vcodret;
                
                continue foreach;
            end if
        end if

        -- // Verifica si es movimiento valorizado
        if vmoneda <> vgcodigo_mn and vvaloriza = "S"  then
            let vmonto2 = vmonto_tot * vtpcambval;
            
            call extrae_cont(pempresa,3,vmonto2,vsucopero,vproducto,vgcodigo_mn,vtransacc,vsector,vcancelad,vsuccta,wdescripcion) 
            returning vcodret;
        end if

        if vtransacc <> "0231" and 
           vtransacc <> "0232" and 
           vtransacc <> "3313" and 
           vtransacc <> "3314" and
           vtransacc <> "1193" and 
           vtransacc <> "1195" and
           vtransacc <> vgtransacc_t1 and 
           vtransacc <> "0269" and 
           vtransacc <> "1113" and
           vtransacc <> "1144" and		   
           vtransacc <> vgtransacc_t2 and not  
          (vtransacc="0274" and vproducto="9901") AND NOT 
          (vtransacc="0273" and vproducto="9901") AND NOT 
          (vtransacc="0273" and vproducto = "1600" and vcuenta in ('16000000080')) AND NOT
		  (vtransacc="0273" and vproducto = "1600" and vcuenta in ('16000000322')) AND NOT
          (vtransacc="0273" and vproducto = "2200" and vcuenta in ('22000001574'))   then
            call extrae_cont(pempresa,1,vmonto_tot,vsucopero,vproducto,vmoneda,vtransacc,vsector,vcancelad,vsuccta,wdescripcion)  
            returning vcodret;
        end if
        
        --	// Proceso para PITDC:
        if vtransacc = "1193" or vtransacc = "1195" then
            let vbintarjeta = substr(vreferencia, 1, 6);
            
            -- // Obtener que secuencia debe ser tomada en cuenta:
            SELECT Cod_Reg 
              into vsecuencia 
              FROM BdiSac:Sac_EGlobal_Banco 
             WHERE IdBanco = (SELECT NVL(Id_Bco, 0) 
                                FROM BdiCheq:Sc_Bines 
                               WHERE Bin = vbintarjeta);
             
            if vsecuencia is null then
                let vsecuencia = "3";
            end if;	
            
            call extrae_cont(pempresa,vsecuencia,vmonto_tot,vsucopero,vproducto,vmoneda,vtransacc,vsector,vcancelad,vsuccta,wdescripcion)
            returning vcodret;
     	end if;			

        -- // Contabiliza Camara,231,232,3246,269,1113
        if vtransacc = "0231" or 
           vtransacc = "0232" or
           vtransacc = "3313" or 
           vtransacc = "3314" or
           vtransacc = vgtransacc_t1 or 
           vtransacc = "0269" or 
           vtransacc = "1113" or 		   
           vtransacc = "1144" or
		   vtransacc = vgtransacc_t2 then
            call extrae_cont(pempresa,1,vmonto_tot,vsucopero,vproducto,vmoneda,vtransacc,vsector,vcancelad,vsuccta,wdescripcion)  
            returning vcodret;
            
            if vtransacc = vgtransacc_t1 or vtransacc = "0269" or vtransacc = "1113" or vtransacc = "1144" then
                call extrae_cont(pempresa,2,vmonto_tot,vsucopero,vproducto,vmoneda,vtransacc,vsector,vcancelad,vsuccta,wdescripcion) 
                returning vcodret;
            end if
        end if
        ----SERVICIOS
		if (vtransacc = "0274" and vproducto="9901") OR 
           (vtransacc = "0273" and vproducto="9901") OR 
           (vtransacc = "0273" and vproducto="1600" and vcuenta in ('16000000080')) OR 
		   (vtransacc = "0273" and vproducto="1600" and vcuenta in ('16000000322')) OR 
           (vtransacc = "0273" and vproducto="2200" and vcuenta in ('22000001574')) then

            select {+INDEX (bdisac:sac_catalogo_pt idx_ptcta)} nvl(MAX(secuencia),0) INTO vsecserv from bdisac:sac_catalogo_pt where cuenta=trim(vcuenta); 
            if vsecserv<>0 then

                call extrae_cont(pempresa,vsecserv,vmonto_tot,vsucopero,vproducto,vmoneda,vtransacc,vsector,vcancelad,vsuccta,
				                 case when vcuenta = '22000001574' then 'ABSPEIWU' 
								      WHEN vcuenta = '16000000080' then 'ABSPEIBTS'
									  when vcuenta = '16000000322' then 'ABSPEIAPP' 									  
									  else wdescripcion end)  


                returning vcodret;
            end if;
        end if;
        -----
    end foreach
    
    let vestatusproc = "F";
    
    UPDATE bdinteg:sx_contproc
    SET status_proc = vestatusproc,
    codret = vcodret,
    hora_fin = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas)
    WHERE empresa = pempresa
    AND proceso = vproceso
    AND fecha = vfecha_hoy
    AND sistema = vsistema;

    return vcodret;

    end;

end procedure

DOCUMENT
"FUNCIONAMIENTO:SP padre de pase de cheques historicos",
"AJUSTE: Se quitan system",
"FECHA : 24/03/2026",
"DB: bdicheq";

CREATE PROCEDURE "informix".pasecheqhisfinal(pempresa char(3), pfechahoy date)
RETURNING CHAR(5);
    
    DEFINE GLOBAL vgcodigo_mn           CHAR(2)     DEFAULT ' ';
    DEFINE GLOBAL vg_sistema            CHAR(2)     DEFAULT ' ';
    DEFINE GLOBAL vgtransacc_t1         CHAR(4)     DEFAULT ' ';
    DEFINE GLOBAL vgtransacc_t2         CHAR(4)     DEFAULT ' ';
    DEFINE GLOBAL vgcta_iva             CHAR(20)    DEFAULT ' ';
    DEFINE GLOBAL vgcta_itr             CHAR(20)    DEFAULT ' ';
    DEFINE GLOBAL vgtransacc_corresp    CHAR(4)     DEFAULT ' ';
	  DEFINE GLOBAL vfecha_hoy            DATE        DEFAULT TODAY;
    
    define vcodret          char(5);
    define vcodret2         char(5);
    define vcodret3         char(50);
    define vsqlerr          integer;
    define visamerr         integer;
    define vdescerr         char(50);
    define vsucopero        char(4);
    define vproducto        char(4);
    define vmoneda          char(2);
    define vtransacc        char(4);
    define vmonto_tot       money(14,2);
    define vexento_isr      char(1);
    define vsector          char(2);
    define vvaloriza        char(1);
    define vcancelad        char(1);
    define vsuccta          char(4);
    define wabreviatura     char(20);
    define wdescripcion     char(30);
    define vfechaproc       date;
    define vporcentaje      decimal(9,6);
    define vtasa_bruta      decimal(9,6);
    define vsobretasa       decimal(9,6);
    define vtpcambval       decimal(14,6);
    define vmonto1          money(14,2);
    define vmonto2          money(14,2);
    define vdivisa_cambio   char(2);
    define vtranprovint     char(4);
    define vcobraisr        char(1);
    define vproceso         char(20);
    define vsistema         char(2);
    define vestatusproc     char(1);
    define vsql             char(600);
    define vstmt            char(250);
    define vusuario         char(10);
    define vhora_tc         datetime hour to minute;
    define vmincta          char(20);
    define vmaxcta          char(20);
    define vbintarjeta      char(6);   -- PITDC
    define vsecuencia       integer;   -- PITDC
    define vreferencia      char (19); -- PITDC
    define vcuenta          char(20);
    define vsecserv         smallint;
    define vexistepase      smallint;
    define vexistepase1     smallint;
    define vexistepase2     smallint;
    define vexistepase3     smallint;
    define vexistepase4     smallint;
    define vexistepase5     smallint;
    define vexiste          integer;

    let vcodret  = "000";
    let vcodret2 = "";
    let vcodret3 = "";
    let vsqlerr  = 0;
    let visamerr = 0;
    let vdescerr = "";
    let vproceso = "pasechqhisfin";
    let vsistema = "01";
    let vestatusproc = "I";
    let vsql     = '';
    let vstmt    = '';
    let vusuario = user;
    let vexiste  = 0;

    --set debug file to "/tmp/pasecheqhisfinal.out";
    --trace on;

    begin
    
    on exception set vsqlerr, visamerr, vdescerr
        set debug file to "/tmp/pasecheqhisfinal.err";
        trace on;
        if vsqlerr <> 0 then
            let vcodret = vsqlerr;
            let vcodret2 = visamerr;
            let vcodret3 = vdescerr;
            UPDATE bdinteg:sx_contproc
            SET ejecutivo = vusuario,
            status_proc = 'C',
            codret = vcodret,
            hora_fin = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas)
            WHERE empresa = pempresa
            AND proceso = vproceso
            AND fecha = vfecha_hoy
            AND sistema = vsistema;
            
            return vcodret;
        end if;
    end exception;
    
    set isolation to dirty read;
    SET OPTIMIZATION HIGH;

    -- // Asigna la fecha de hoy
    let vfecha_hoy = pfechahoy;
    
    -- // GUARDA REGISTRO DE EJECUCIï¿½N
    select count(*)
      into vexiste
      from bdinteg:sx_contproc
     where empresa = pempresa
       and proceso = vproceso
       and fecha   = vfecha_hoy
       and sistema = vsistema;

    if vexiste = 0 then
        INSERT INTO bdinteg:sx_contproc 
          VALUES (pempresa, vproceso, vfecha_hoy, vsistema, 'I', vusuario, (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas), NULL, NULL);  
      else
        UPDATE bdinteg:sx_contproc
        SET ejecutivo = vusuario,
        status_proc = 'I',
        codret = ' ',
        hora_fin = ' ',
        hora_ini = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas)
        WHERE empresa = pempresa
        AND proceso = vproceso
        AND fecha = vfecha_hoy
        AND sistema = vsistema;
    end if;
     
    -- // Verifica se hayan efectuado todos los complementos del pase contable
    select count(*)
      into vexistepase
      from bdinteg:sx_contproc
     where empresa = pempresa
       and proceso = "pasechqhis"
       and fecha   = vfecha_hoy
       and sistema = vsistema
       and status_proc = 'F';
       
    select count(*)
      into vexistepase1
      from bdinteg:sx_contproc
     where empresa = pempresa
       and proceso = "pasechqhiscomp1"
       and fecha   = vfecha_hoy
       and sistema = vsistema
       and status_proc = 'F';
       
    select count(*)
      into vexistepase2
      from bdinteg:sx_contproc
     where empresa = pempresa
       and proceso = "pasechqhiscomp2"
       and fecha   = vfecha_hoy
       and sistema = vsistema
       and status_proc = 'F';
       
    select count(*)
      into vexistepase3
      from bdinteg:sx_contproc
     where empresa = pempresa
       and proceso = "pasechqhiscomp3"
       and fecha   = vfecha_hoy
       and sistema = vsistema
       and status_proc = 'F';
       
    select count(*)
      into vexistepase4
      from bdinteg:sx_contproc
     where empresa = pempresa
       and proceso = "pasechqhiscomp4"
       and fecha   = vfecha_hoy
       and sistema = vsistema
       and status_proc = 'F';
       
    select count(*)
      into vexistepase5
      from bdinteg:sx_contproc
     where empresa = pempresa
       and proceso = "pasechqhiscomp5"
       and fecha   = vfecha_hoy
       and sistema = vsistema
       and status_proc = 'F';
    
    -- // EJECUTA LOS PROCESOS FALTANTES PARA GENERAR LA POLIZA DE CHEQUES
    if vexistepase <= 0 or vexistepase1 <= 0 or vexistepase2 <= 0 or vexistepase3 <= 0 or vexistepase4 <= 0 or vexistepase5 <= 0 then
       let vcodret = "974";
        
        UPDATE bdinteg:sx_contproc
        SET ejecutivo = vusuario,
        status_proc = 'C',
        codret = vcodret,
        hora_fin = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas)
        WHERE empresa = pempresa
        AND proceso = vproceso
        AND fecha = vfecha_hoy
        AND sistema = vsistema;
                   
        return vcodret;
    end if;
       
    -- // EJECUTA LOS PROCESOS FALTANTES PARA GENERAR LA CONTABILIDAD DEL SISTEMA DE CHEQUES
    call auditor(pempresa) 
    returning vcodret;

    if vcodret = "000" then
        call pasecont(pempresa,vfecha_hoy,vfecha_hoy,'') 
        returning vcodret;
    end if;

    if vcodret <> "000" then
        let vestatusproc = "C";
    else
        let vestatusproc = "F";
    end if;
    
    UPDATE bdinteg:sx_contproc
    SET status_proc = vestatusproc,
    codret = vcodret,
    hora_fin = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas)
    WHERE empresa = pempresa
    AND proceso = vproceso
    AND fecha = vfecha_hoy
    AND sistema = vsistema;
    
    IF vcodret = "000" THEN
        CALL "informix".sp_integra_suspenso ('001','01',vfecha_hoy) 
        RETURNING vcodret;
    END IF

    return vcodret;

    end;

end procedure

DOCUMENT
"FUNCIONAMIENTO:SP padre de pase de cheques historicos",
"AJUSTE: Se quitan system",
"FECHA : 24/03/2026",
"DB: bdicheq";

CREATE OR REPLACE PROCEDURE "informix".sp_cons_sdodisp_x_tpcalculo_costo(
cCuenta         CHAR(20),
mSdoActual      MONEY(14,2),
mSdoRetenido    MONEY(14,2),
mSdoCong        MONEY(14,2),
mSaldoSbc       MONEY(14,2),
mImpChqSbg      MONEY(14,2),
mLimSbgCcc      MONEY(14,2),
mImpSbgCcc      MONEY(14,2),
bConsultaSaldo  BOOLEAN,
iOpcion         INTEGER)

RETURNING  
CHAR(5)       AS cCodRet,
CHAR(50)      AS cMensajeRet,
MONEY(14,2)   AS mSaldoDisponible;

DEFINE iSqlErr           INTEGER;
DEFINE iIsamErr          INTEGER;
DEFINE cErrorInfo        CHAR(50);

DEFINE cCodRet           CHAR(5);
DEFINE cMensajeRet       CHAR(50);
DEFINE mSaldoDisponible  MONEY(14,2);
DEFINE iContadorAuxiliar INTEGER;

LET iSqlErr              = 0;
LET iIsamErr             = 0;
LET cErrorInfo           = '';
LET cCodRet              = '00000';
LET cMensajeRet			 = 'Proceso de consulta de saldo exitoso';
LET iContadorAuxiliar    = 0;
LET mSaldoDisponible     = 0;

BEGIN

	ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
	IF iSqlErr != 0 THEN
		LET cCodRet     = iSqlErr;
		LET cMensajeRet = cErrorInfo;
		RETURN cCodRet,cMensajeRet,mSaldoDisponible;
	END IF;
	END EXCEPTION;
   
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	-- SET DEBUG FILE TO "/home/c90316821/sp_cons_sdodisp.out";
	-- TRACE ON;

	IF ( bConsultaSaldo IS NULL )THEN
			LET cCodRet = '00004';
			LET cMensajeRet = 'El valor del campo bConsultaSaldo es nulo';
			RETURN cCodRet,cMensajeRet,mSaldoDisponible;
	END IF;

	IF (bConsultaSaldo) THEN

		-- Se valida si la cuenta se ingresaron correctamente 
		IF (cCuenta = '' OR cCuenta IS NULL)THEN
				LET cCodRet = '00001';
				LET cMensajeRet = 'El valor del numero de cuenta es nulo o vacio';
				RETURN cCodRet,cMensajeRet,mSaldoDisponible;
		END IF;

		SELECT COUNT(1),sdo_actual,sdo_retenido,sdo_cong,saldo_sbc,imp_chq_sbg,imp_sbg_ccc, lim_sbg_ccc
	    INTO iContadorAuxiliar,mSdoActual,mSdoRetenido,mSdoCong,mSaldoSbc,mImpChqSbg,mImpSbgCcc,mLimSbgCcc
	    FROM BDICHEQ:"informix".SC_MAECHQ
	    WHERE CUENTA = cCuenta GROUP BY sdo_actual,sdo_retenido,sdo_cong, saldo_sbc,imp_chq_sbg,imp_sbg_ccc, lim_sbg_ccc;

		IF iContadorAuxiliar = 0 OR iContadorAuxiliar IS NULL THEN
			LET cCodRet = '00002';
			LET cMensajeRet = 'La cuenta ingresada no existe en la base de datos.';
			RETURN cCodRet,cMensajeRet,mSaldoDisponible;
		END IF;
	END IF;

	-- Se ingresa a la opcion de la formula deseada

	IF iOpcion = 1 THEN
		LET mSaldoDisponible = mSdoActual  - (mSdoRetenido + mSdoCong + mImpChqSbg + mSaldoSbc);
	ELIF iOpcion = 2 THEN
		LET mSaldoDisponible = mSdoActual  - (mSdoRetenido + mSdoCong + mSaldoSbc);
	ELIF iOpcion = 3 THEN
		LET mSaldoDisponible = mSdoActual  - mSdoRetenido - mSaldoSbc;
	ELIF iOpcion = 4 THEN
		LET mSaldoDisponible = mSdoActual  - (mSdoRetenido + mSdoCong + mSaldoSbc) + (mLimSbgCcc - mImpSbgCcc);
	ELIF iOpcion = 5 THEN
		LET mSaldoDisponible = mSdoActual  - (mSdoRetenido + mSdoCong + mSaldoSbc + mImpSbgCcc);
	ELIF iOpcion = 6 THEN
		LET mSaldoDisponible = mSdoActual + (mLimSbgCcc - mImpSbgCcc) - (mSdoRetenido + mSdoCong + mSaldoSbc + mImpChqSbg);	
	ELSE
		LET cCodRet = '00003';
		LET cMensajeRet = 'Opcion de calculo invalida';
	END IF;


  RETURN cCodRet,cMensajeRet,mSaldoDisponible;
END
END PROCEDURE 
DOCUMENT 'AUTOR: Osiel Alfredo Camacho Mendoza / Eric E. Armenta Perez / Luis E. Orozco Cosme',
'FECHA 05/06/2025',
'MODULO: RQM 09 704 ',
'FUNCIONALIDAD: Consulta Saldo Disponible',
'DESCRIPCION: SPL encargado de devolver la consulta del saldo disponible dependiendo de la opcion deseada',
'VER: 1.0.0',
'MODIFICADO:            Donovan F. Torres Landeros',
'ULTIMA MODIFICACION:   2025/07/07',
'RAZON:                 Se agrega el RETURN  en el bloque de EXCEPTION faltante.',
'PROYECTO:              RQM 09 704   Cobranza Automatica en cuentas de captacion',
'BD:                    bdicheq',
'VER:                   1.0.2',
'MODIFICADO:            Donovan F. Torres Landeros',
'ULTIMA MODIFICACION:   2025/07/07',
'RAZON:                 Se quitan validaciones que ya no son necesarias',
'PROYECTO:              RQM 09 704   Cobranza Automatica en cuentas de captacion',
'BD:                    bdicheq',
'VER:                   1.0.3';

CREATE PROCEDURE "informix".sp_cap_buscaejec(pUsuario CHAR(8), pIdFuncion CHAR(10), pUsuarioSesion CHAR(8))
		RETURNING CHAR(5) AS codret,
				  CHAR(50) AS nombre; 

    
	--DEFINICIÃN DE VARIABLES
	DEFINE cCodRet 		     CHAR(5);
	DEFINE iSqlErr 		     INTEGER;
	DEFINE cNombreEjecutivo  CHAR(50);

	LET cCodRet 		= '00000';
	LET iSqlErr 		= 0;
	LET cNombreEjecutivo = '';

	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNombreEjecutivo;
		END EXCEPTION;

		-- SET DEBUG FILE TO '/tmp/mfinis/sp_cap_buscaejec.out';
		-- TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' OR pUsuarioSesion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNombreEjecutivo;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNombreEjecutivo;
		END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		SELECT TRIM(nombre) 
		INTO cNombreEjecutivo 
		FROM bdinteg:si_ejecut 
		WHERE ejecutivo = pUsuarioSesion;

		IF NVL(cNombreEjecutivo,'') = '' THEN
			LET cCodRet = '01280';
			RETURN cCodRet, cNombreEjecutivo;
		END IF;
		
		RETURN cCodRet, cNombreEjecutivo;
	END
END PROCEDURE
DOCUMENT 'AUTOR: Veronica Sanchez Tlacomulco',
'FECHA: 12/01/2026',
'MODULO: DEBITO',
'FUNCIONALIDAD: HISTORICO ACTUALIZACIONES CARATULA PRODUCTO 1200',
'DESCRIPCION: SPS encargado de consultar el usuario en si_ejecut',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cap_coninsertmedinfla(pUsuario CHAR(8), pIdFuncion CHAR(10), pBandera CHAR(1), pMedianaInf DECIMAL(9,6), pUsuarioMod CHAR(8), pTasa DECIMAL(9,6))
		RETURNING CHAR(5) AS codret,
				  DECIMAL(9,6) AS mediana_inflacion,
				  DATETIME YEAR TO SECOND AS fecha_actualizacion; 

    
	--DEFINICIÃN DE VARIABLES
	DEFINE cCodRet 		     CHAR(5);
	DEFINE iSqlErr 		     INTEGER;
	DEFINE dMedianaInfl		 DECIMAL(9,6);
	DEFINE cFechaAct		 DATETIME YEAR TO SECOND;
	DEFINE cFechaAct2		 DATETIME YEAR TO SECOND;

	LET cCodRet 		= '00000';
	LET iSqlErr 		= 0;
	LET dMedianaInfl    = 0;
	LET cFechaAct		= '';
	LET cFechaAct2		= '';

	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, dMedianaInfl, cFechaAct2;
		END EXCEPTION;

		 --SET DEBUG FILE TO '/tmp/mfinis/sp_cap_coninsertmedinfla.out';
		 --TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' OR pBandera = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, dMedianaInfl, cFechaAct2;
		END IF;
		
		IF pBandera = '2' THEN 
			IF pMedianaInf IS NULL AND pUsuarioMod = '' THEN 
				LET cCodRet = '00003';
				RETURN cCodRet, dMedianaInfl, cFechaAct2;
			END IF;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, dMedianaInfl, cFechaAct2;
		END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		IF pBandera = '1' THEN 
			SELECT MAX(fecha_insert) 
			INTO cFechaAct
			FROM bdinteg:si_medProd1200
			WHERE producto = '1200' AND tasa = 'EJEMP';
			
			IF NVL(cFechaAct,'') = '' THEN 
				LET cCodRet = '00017';
				RETURN cCodRet, dMedianaInfl, cFechaAct2;
			END IF;
			
			SELECT mediana_inflacion, fecha_insert 
			INTO dMedianaInfl, cFechaAct2
			FROM bdinteg:si_medProd1200
			WHERE producto = '1200' AND tasa = 'EJEMP' AND fecha_insert = cFechaAct;
			
			IF NVL(dMedianaInfl,'') = '' AND NVL(cFechaAct2,'') = '' THEN 
				LET cCodRet = '00017';
				RETURN cCodRet, dMedianaInfl, cFechaAct2;
			END IF;
			
			RETURN cCodRet, dMedianaInfl, cFechaAct2;
			
		ELIF pBandera = '2' THEN 
			
			INSERT INTO bdinteg:"informix".si_medProd1200 (tasa, producto, mediana_inflacion, user_insert, fecha_insert) 
			VALUES ('EJEMP', '1200', pMedianaInf, pUsuarioMod, CURRENT);
			
			IF DBINFO("sqlca.sqlerrd2") = 0 THEN
				LET cCodRet = '00283';
				RETURN cCodRet, dMedianaInfl, cFechaAct2;
			END IF;
			
			-- RECALCULO GAT - MASIVO
			EXECUTE PROCEDURE bdicheq:"informix".sp_cap_recalculagat1200(pUsuario, pIdFuncion, pUsuarioMod, '1', 0, pTasa) 
			INTO cCodRet;
			IF cCodRet <> '00000' THEN
				RETURN cCodRet, dMedianaInfl, cFechaAct2;
			END IF;
			
			RETURN cCodRet, dMedianaInfl, cFechaAct2;
		END IF;
	END
END PROCEDURE
DOCUMENT 'AUTOR: Veronica Sanchez Tlacomulco',
'FECHA: 12/01/2026',
'MODULO: DEBITO',
'FUNCIONALIDAD: MANTENIMIENTO CARATULA PRODUCTO 1200',
'DESCRIPCION: Procedimiento almacenado encargado de recuperar e insert nueva informacion sobre la mediana de inflacion',
'BD: bdicheq';

CREATE PROCEDURE "informix".sp_cap_conrespaldohistorico(pUsuario CHAR(8), pIdFuncion CHAR(10), pBandera CHAR(1), pUsuarioCon CHAR(8), pPeriodoDel DATE, pPeriodoAl DATE, pRegistro INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
		          INTEGER AS total_registros,
				  DATE AS dFechaModifica,
				  DECIMAL(14,2) AS saldo_desde, 
				  DECIMAL(14,2) AS saldo_hasta,
				  DECIMAL(9,6) AS tasarendcetes,
				  INTEGER AS tasarendxcetes,
				  INTEGER AS periodo,
				  DECIMAL(9,6) AS gatnominal,
				  DECIMAL(9,6) AS gatreal,
				  CHAR(2) AS esvisible,
				  CHAR(8) AS user_modifica,
				  CHAR(50) AS nombre_user_modifica;
    
	--DEFINICIÃN DE VARIABLES
	DEFINE cCodRet 		    CHAR(5);
	DEFINE iSqlErr 		    INTEGER;
	DEFINE iTotalRegistro   INTEGER;
	DEFINE dSdoDesde		DECIMAL(14,2);
	DEFINE dSdoHasta		DECIMAL(14,2);
	DEFINE dTasaCetes		DECIMAL(9,6);
	DEFINE iTasaxCetes		INTEGER;
	DEFINE iPeriodo			INTEGER;
	DEFINE dGatNominal		DECIMAL(9,6);
	DEFINE dGatReal			DECIMAL(9,6);
	DEFINE cEsVisIble		CHAR(2);
	DEFINE cUserModifica	CHAR(8);
	DEFINE cNombreUserMod	CHAR(50);
	DEFINE dFechaModifica	DATE;
	
	LET cCodRet 		= '00000';
	LET iSqlErr 		= 0;
	LET iTotalRegistro	= 0;
	LET dSdoDesde		= 0;
	LET dSdoHasta		= 0;
	LET dTasaCetes		= 0;
	LET iTasaxCetes     = 0;
	LET iPeriodo		= 0;
	LET dGatNominal		= 0;
	LET dGatReal		= 0;
	LET cEsVisIble		= '';
	LET cUserModifica	= '';
	LET cNombreUserMod	= '';
	LET dFechaModifica	= '';

	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iTotalRegistro, dFechaModifica, dSdoDesde, dSdoHasta, dTasaCetes, iTasaxCetes, iPeriodo, dGatNominal, dGatReal, cEsVisIble, cUserModifica, cNombreUserMod;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_cap_conrespaldohistorico.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pBandera = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iTotalRegistro, dFechaModifica, dSdoDesde, dSdoHasta, dTasaCetes, iTasaxCetes, iPeriodo, dGatNominal, dGatReal, cEsVisIble, cUserModifica, cNombreUserMod;
		END IF;
			
		IF pBandera = '2' THEN 
			IF pRegistro IS NULL OR pRecuperacion IS NULL THEN
				LET cCodRet = '00003';
				RETURN cCodRet, iTotalRegistro, dFechaModifica, dSdoDesde, dSdoHasta, dTasaCetes, iTasaxCetes, iPeriodo, dGatNominal, dGatReal, cEsVisIble, cUserModifica, cNombreUserMod;
			END IF;
			
			IF pRegistro < 0 THEN
				LET cCodRet = '00098';
				RETURN cCodRet, iTotalRegistro, dFechaModifica, dSdoDesde, dSdoHasta, dTasaCetes, iTasaxCetes, iPeriodo, dGatNominal, dGatReal, cEsVisIble, cUserModifica, cNombreUserMod;
			END IF;
		END IF;
		
		IF NVL(pUsuarioCon,'') <> '' AND NVL(pPeriodoDel,'') <> '' OR NVL(pPeriodoAl,'') <> '' THEN 
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iTotalRegistro, dFechaModifica, dSdoDesde, dSdoHasta, dTasaCetes, iTasaxCetes, iPeriodo, dGatNominal, dGatReal, cEsVisIble, cUserModifica, cNombreUserMod;
		END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pBandera = '1' THEN 
			IF NVL(pUsuarioCon,'') = '' AND NVL(pPeriodoDel,'') <> '' AND NVL(pPeriodoAl,'') <> '' THEN 
				SELECT COUNT(*) 
				INTO iTotalRegistro
				FROM bdinteg:si_paramProd1200_hist
				WHERE fecha_modifica >= pPeriodoDel AND fecha_modifica <= pPeriodoAl;
			ELIF NVL(pUsuarioCon,'') <> '' AND NVL(pPeriodoDel,'') = '' AND NVL(pPeriodoAl,'') = '' THEN
				SELECT COUNT(*) 
				INTO iTotalRegistro
				FROM bdinteg:si_paramProd1200_hist
				WHERE user_modifica = pUsuarioCon;
			ELSE 
				SELECT COUNT(*) 
				INTO iTotalRegistro
				FROM bdinteg:si_paramProd1200_hist
				WHERE user_modifica = pUsuarioCon AND (fecha_modifica >= pPeriodoDel AND fecha_modifica <= pPeriodoAl);
			END IF;
			
			IF NVL(iTotalRegistro,0) = 0 THEN 
				LET cCodRet = '00017';
				RETURN cCodRet, iTotalRegistro, dFechaModifica, dSdoDesde, dSdoHasta, dTasaCetes, iTasaxCetes, iPeriodo, dGatNominal, dGatReal, cEsVisIble, cUserModifica, cNombreUserMod;
			END IF;
			
			RETURN cCodRet, iTotalRegistro, dFechaModifica, dSdoDesde, dSdoHasta, dTasaCetes, iTasaxCetes, iPeriodo, dGatNominal, dGatReal, cEsVisIble, cUserModifica, cNombreUserMod;
			
		ELIF pBandera = '2' THEN 
			IF NVL(pUsuarioCon,'') = '' AND NVL(pPeriodoDel,'') <> '' AND NVL(pPeriodoAl,'') <> '' THEN 
				FOREACH
					SELECT SKIP pRegistro FIRST pRecuperacion T1.saldo_desde, T1.saldo_hasta, T1.tasarendcetes, T1.tasarendxcetes, T1.periodo, T1.gatnominal, T1.gatreal, T1.esvisible, T1.user_modifica, TRIM(T2.nombre), T1.fecha_modifica
					INTO dSdoDesde, dSdoHasta, dTasaCetes, iTasaxCetes, iPeriodo, dGatNominal, dGatReal, cEsVisIble, cUserModifica, cNombreUserMod, dFechaModifica
					FROM bdinteg:si_paramProd1200_hist AS T1,
					bdinteg:si_ejecut AS T2
					WHERE T1.user_modifica = T2.ejecutivo AND (T1.fecha_modifica >= pPeriodoDel AND T1.fecha_modifica <= pPeriodoAl)
				
					LET iTotalRegistro =  iTotalRegistro + 1;
					RETURN cCodRet, 0, dFechaModifica, dSdoDesde, dSdoHasta, dTasaCetes, iTasaxCetes, iPeriodo, dGatNominal, dGatReal, cEsVisIble, cUserModifica, cNombreUserMod WITH RESUME;
				
				END FOREACH;
			ELIF NVL(pUsuarioCon,'') <> '' AND NVL(pPeriodoDel,'') = '' AND NVL(pPeriodoAl,'') = '' THEN
				FOREACH
					SELECT SKIP pRegistro FIRST pRecuperacion T1.saldo_desde, T1.saldo_hasta, T1.tasarendcetes, T1.tasarendxcetes, T1.periodo, T1.gatnominal, T1.gatreal, T1.esvisible, T1.user_modifica, TRIM(T2.nombre), T1.fecha_modifica
					INTO dSdoDesde, dSdoHasta, dTasaCetes, iTasaxCetes, iPeriodo, dGatNominal, dGatReal, cEsVisIble, cUserModifica, cNombreUserMod, dFechaModifica
					FROM bdinteg:si_paramProd1200_hist AS T1,
					bdinteg:si_ejecut AS T2
					WHERE T1.user_modifica = T2.ejecutivo AND T1.user_modifica = pUsuarioCon
				
					LET iTotalRegistro =  iTotalRegistro + 1;
					RETURN cCodRet, 0, dFechaModifica, dSdoDesde, dSdoHasta, dTasaCetes, iTasaxCetes, iPeriodo, dGatNominal, dGatReal, cEsVisIble, cUserModifica, cNombreUserMod WITH RESUME;
				
				END FOREACH;
			ELSE
				FOREACH
					SELECT SKIP pRegistro FIRST pRecuperacion T1.saldo_desde, T1.saldo_hasta, T1.tasarendcetes, T1.tasarendxcetes, T1.periodo, T1.gatnominal, T1.gatreal, T1.esvisible, T1.user_modifica, TRIM(T2.nombre), T1.fecha_modifica
					INTO dSdoDesde, dSdoHasta, dTasaCetes, iTasaxCetes, iPeriodo, dGatNominal, dGatReal, cEsVisIble, cUserModifica, cNombreUserMod, dFechaModifica
					FROM bdinteg:si_paramProd1200_hist AS T1,
					bdinteg:si_ejecut AS T2
					WHERE T1.user_modifica = T2.ejecutivo AND T1.user_modifica = pUsuarioCon AND (T1.fecha_modifica >= pPeriodoDel AND T1.fecha_modifica <= pPeriodoAl)
				
					LET iTotalRegistro =  iTotalRegistro + 1;
					RETURN cCodRet, 0, dFechaModifica, dSdoDesde, dSdoHasta, dTasaCetes, iTasaxCetes, iPeriodo, dGatNominal, dGatReal, cEsVisIble, cUserModifica, cNombreUserMod WITH RESUME;
				
				END FOREACH;
			END IF;
			IF iTotalRegistro = 0 AND pRegistro = 0 THEN
				LET cCodRet = '00017'; --
				RETURN cCodRet, iTotalRegistro, dFechaModifica, dSdoDesde, dSdoHasta, dTasaCetes, iTasaxCetes, iPeriodo, dGatNominal, dGatReal, cEsVisIble, cUserModifica, cNombreUserMod;
			ELIF iTotalRegistro = 0 AND pRegistro > 0 THEN
				LET cCodRet = '1001';
				RETURN cCodRet, iTotalRegistro, dFechaModifica, dSdoDesde, dSdoHasta, dTasaCetes, iTasaxCetes, iPeriodo, dGatNominal, dGatReal, cEsVisIble, cUserModifica, cNombreUserMod;
			END IF;
		END IF;		
	END
END PROCEDURE
DOCUMENT 'AUTOR: VERONICA SANCHEZ TLACOMULCO',
'FECHA: 19/12/2025',
'MODULO: DEBITO',
'FUNCIONALIDAD: MANTENIMIENTO CARATULA PRODUCTO 1200',
'DESCRIPCION: SPL encargado de realiza el respaldo historico de la actualizacion de las tasas',
'BD: bdicheq';

CREATE PROCEDURE "informix".sp_cap_infocarat1200(pUsuario CHAR(8), pIdFuncion CHAR(10), pUsuarioMod CHAR(8), pBandera CHAR(1), pTrama CHAR(250), pPeriodo CHAR(2),  pTasa DECIMAL(9,6))
		RETURNING CHAR(5) AS codret,
		          INTEGER AS idRegistro,
				  DECIMAL(14,2) AS dSdoDesde, 
				  DECIMAL(14,2) AS dSdoHasta, 
				  DECIMAL(9,6) AS dTasaRendCetes, 
				  INTEGER AS iTasaRendxCetes, 
				  INTEGER AS iPeriodo, 
				  DECIMAL(9,6) AS dGatNominal, 
				  DECIMAL(9,6) AS dGatReal, 
				  CHAR(2) AS cVisible, 
				  DATE AS dFechaModifica; 

    
	--DEFINICIÃN DE VARIABLES
	DEFINE cCodRet 		    CHAR(5);
	DEFINE iSqlErr 		    INTEGER;
	DEFINE cTasa			CHAR(8);
	DEFINE cProducto		CHAR(4);
	DEFINE dSdoDesde		DECIMAL(14,2);
	DEFINE dSdoDesdeAnt		DECIMAL(14,2);
	DEFINE dSdoHasta		DECIMAL(14,2);
	DEFINE dSdoHastaAnt		DECIMAL(14,2);
	DEFINE dTasaRendCetes	DECIMAL(9,6);
	DEFINE dTasaRendCetesAnt	DECIMAL(9,6);
	DEFINE iTasaRendxCetes	INTEGER;
	DEFINE iTasaRendxCetesAnt	INTEGER;
	DEFINE iPeriodo			INTEGER;
	DEFINE iPeriodoAnt			INTEGER;
	DEFINE dGatNominal		DECIMAL(9,6);
	DEFINE dGatReal			DECIMAL(9,6);
	DEFINE cVisible			CHAR(2);
	DEFINE cVisibleAnt			CHAR(2);
	DEFINE dFechaModifica	DATE;
	DEFINE iTotalRegistro	INTEGER;
	DEFINE iIdRegistro		INTEGER;
	DEFINE cRecuperaTrama1	CHAR(50);
	DEFINE cRecuperaTrama2	CHAR(12);
	DEFINE idRegistro		INTEGER;

	LET cCodRet 		= '00000';
	LET iSqlErr 		= 0;
	LET cTasa			= '';
	LET cProducto		= '';
	LET dSdoDesde		= 0;
	LET dSdoDesdeAnt	= 0;
	LET dSdoHasta		= 0;
	LET dSdoHastaAnt	= 0;
	LET dTasaRendCetes	= 0;
	LET dTasaRendCetesAnt	= 0;
	LET iTasaRendxCetes	= 0;
	LET iTasaRendxCetesAnt	= 0;
	LET iPeriodo		= 0;
	LET iPeriodoAnt		= 0;
	LET dGatNominal		= 0;
	LET dGatReal		= 0;
	LET cVisible		= '';
	LET cVisibleAnt		= '';
	LET dFechaModifica 	= '';
	LET iTotalRegistro	= 0;
	LET iIdRegistro 	= 0;
	LET cRecuperaTrama1	= '';
	LET cRecuperaTrama2 = '';
	LET idRegistro		= 0;

	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iIdRegistro, dSdoDesde, dSdoHasta, dTasaRendCetes, iTasaRendxCetes, iPeriodo, dGatNominal, dGatReal, cVisible, dFechaModifica;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_cap_infocarat1200.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' OR pBandera = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iIdRegistro, dSdoDesde, dSdoHasta, dTasaRendCetes, iTasaRendxCetes, iPeriodo, dGatNominal, dGatReal, cVisible, dFechaModifica;
		END IF;

		IF pBandera = '2' THEN 
			IF pUsuarioMod = '' OR pTrama = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, iIdRegistro, dSdoDesde, dSdoHasta, dTasaRendCetes, iTasaRendxCetes, iPeriodo, dGatNominal, dGatReal, cVisible, dFechaModifica;
			END IF;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iIdRegistro, dSdoDesde, dSdoHasta, dTasaRendCetes, iTasaRendxCetes, iPeriodo, dGatNominal, dGatReal, cVisible, dFechaModifica;
		END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pBandera = '1' THEN 
			FOREACH
				SELECT rowid, saldo_desde, saldo_hasta, tasarendcetes, tasarendxcetes, periodo, gatnominal, gatreal, esvisible, fecha_modifica 
				INTO iIdRegistro, dSdoDesde, dSdoHasta, dTasaRendCetes, iTasaRendxCetes, iPeriodo, dGatNominal, dGatReal, cVisible, dFechaModifica
				FROM bdinteg:si_paramProd1200
				WHERE tasa = 'EJEMP' AND producto = 1200
				
				LET iTotalRegistro = iTotalRegistro + 1;
				
				RETURN cCodRet, iIdRegistro, dSdoDesde, dSdoHasta, dTasaRendCetes, iTasaRendxCetes, iPeriodo, dGatNominal, dGatReal, cVisible, dFechaModifica WITH RESUME;
			END FOREACH;
		ELIF pBandera = '2' THEN 
			FOREACH
				EXECUTE PROCEDURE bdicnweb:"informix".sp_split_cadena (pTrama, '|')
				INTO cRecuperaTrama1
				FOREACH
					EXECUTE PROCEDURE bdicnweb:"informix".sp_split_cadena (cRecuperaTrama1, ',')
					INTO cRecuperaTrama2
					IF iTotalRegistro = 0 THEN 
						LET idRegistro = cRecuperaTrama2::INTEGER;
					ELIF iTotalRegistro = 1 THEN 
						LET dSdoDesdeAnt = cRecuperaTrama2::DECIMAL(14,2);
					ELIF iTotalRegistro = 2 THEN 
						LET dSdoHastaAnt = cRecuperaTrama2::DECIMAL(14,2);
					ELIF iTotalRegistro = 3 THEN 
						LET dTasaRendCetesAnt = cRecuperaTrama2::DECIMAL(9,6);
					ELIF iTotalRegistro = 4 THEN 
						LET iTasaRendxCetesAnt = cRecuperaTrama2::INTEGER;
					ELIF iTotalRegistro = 5 THEN 
						LET iPeriodoAnt = cRecuperaTrama2::INTEGER;
					ELSE
						LET cVisibleAnt = cRecuperaTrama2::CHAR(2);
					END IF;
					
					LET iTotalRegistro = iTotalRegistro + 1;
				END FOREACH;
				LET iTotalRegistro = 0;
				
				SELECT saldo_desde, saldo_hasta, tasarendcetes, tasarendxcetes, periodo, esvisible
				INTO dSdoDesde, dSdoHasta, dTasaRendCetes, iTasaRendxCetes, iPeriodo, cVisible
				FROM bdinteg:si_paramProd1200
				WHERE rowid = idRegistro;
				
				IF dSdoDesde <> dSdoDesdeAnt THEN 
					UPDATE bdinteg:si_paramProd1200
					SET saldo_desde = dSdoDesdeAnt, user_modifica = pUsuarioMod, fecha_modifica = CURRENT
					WHERE tasa = 'EJEMP' AND producto = 1200 AND rowid = idRegistro;
					
					INSERT INTO bdinteg:"informix".si_bitacoraprod1200 (campo, valor_ant, valor_nuevo, usuario_insert, fecha_modifica)
					VALUES ('Saldo Desde', dSdoDesde, dSdoDesdeAnt, pUsuarioMod, CURRENT);
					
					IF DBINFO("sqlca.sqlerrd2") = 0 THEN
						LET cCodRet = '00283';
						RETURN cCodRet, iIdRegistro, dSdoDesde, dSdoHasta, dTasaRendCetes, iTasaRendxCetes, iPeriodo, dGatNominal, dGatReal, cVisible, dFechaModifica WITH RESUME;
					END IF;
				END IF;
				
				IF dSdoHasta <> dSdoHastaAnt THEN 
					UPDATE bdinteg:si_paramProd1200
					SET saldo_hasta = dSdoHastaAnt, user_modifica = pUsuarioMod, fecha_modifica = CURRENT
					WHERE tasa = 'EJEMP' AND producto = 1200 AND rowid = idRegistro;
					
					INSERT INTO bdinteg:"informix".si_bitacoraprod1200 (campo, valor_ant, valor_nuevo, usuario_insert, fecha_modifica)
					VALUES ('Saldo Hasta', dSdoHasta, dSdoHastaAnt, pUsuarioMod, CURRENT);
					
					IF DBINFO("sqlca.sqlerrd2") = 0 THEN
						LET cCodRet = '00283';
						RETURN cCodRet, iIdRegistro, dSdoDesde, dSdoHasta, dTasaRendCetes, iTasaRendxCetes, iPeriodo, dGatNominal, dGatReal, cVisible, dFechaModifica WITH RESUME;
					END IF;
				END IF;
				
				IF dTasaRendCetes <> dTasaRendCetesAnt THEN 
					UPDATE bdinteg:si_paramProd1200
					SET tasarendcetes = dTasaRendCetesAnt, user_modifica = pUsuarioMod, fecha_modifica = CURRENT
					WHERE tasa = 'EJEMP' AND producto = 1200 AND rowid = idRegistro;
					
					INSERT INTO bdinteg:"informix".si_bitacoraprod1200 (campo, valor_ant, valor_nuevo, usuario_insert, fecha_modifica)
					VALUES ('Tasa Rendimiento CETES', dTasaRendCetes, dTasaRendCetesAnt, pUsuarioMod, CURRENT);
					
					IF DBINFO("sqlca.sqlerrd2") = 0 THEN
						LET cCodRet = '00283';
						RETURN cCodRet, iIdRegistro, dSdoDesde, dSdoHasta, dTasaRendCetes, iTasaRendxCetes, iPeriodo, dGatNominal, dGatReal, cVisible, dFechaModifica WITH RESUME;
					END IF;
				END IF;
				
				IF iTasaRendxCetes <> iTasaRendxCetesAnt THEN 
					UPDATE bdinteg:si_paramProd1200
					SET tasarendxcetes = iTasaRendxCetesAnt, user_modifica = pUsuarioMod, fecha_modifica = CURRENT
					WHERE tasa = 'EJEMP' AND producto = 1200 AND rowid = idRegistro;
					
					INSERT INTO bdinteg:"informix".si_bitacoraprod1200 (campo, valor_ant, valor_nuevo, usuario_insert, fecha_modifica)
					VALUES ('Tasa Rendimiento % CETES', iTasaRendxCetes, iTasaRendxCetesAnt, pUsuarioMod, CURRENT);
					
					IF DBINFO("sqlca.sqlerrd2") = 0 THEN
						LET cCodRet = '00283';
						RETURN cCodRet, iIdRegistro, dSdoDesde, dSdoHasta, dTasaRendCetes, iTasaRendxCetes, iPeriodo, dGatNominal, dGatReal, cVisible, dFechaModifica WITH RESUME;
					END IF;
				END IF;
				
				IF iPeriodo <> iPeriodoAnt THEN 
					UPDATE bdinteg:si_paramProd1200
					SET periodo = iPeriodoAnt, user_modifica = pUsuarioMod, fecha_modifica = CURRENT
					WHERE tasa = 'EJEMP' AND producto = 1200 AND rowid = idRegistro;
					
					INSERT INTO bdinteg:"informix".si_bitacoraprod1200 (campo, valor_ant, valor_nuevo, usuario_insert, fecha_modifica)
					VALUES ('AÃ±os', iPeriodo, iPeriodoAnt, pUsuarioMod, CURRENT);
					
					IF DBINFO("sqlca.sqlerrd2") = 0 THEN
						LET cCodRet = '00283';
						RETURN cCodRet, iIdRegistro, dSdoDesde, dSdoHasta, dTasaRendCetes, iTasaRendxCetes, iPeriodo, dGatNominal, dGatReal, cVisible, dFechaModifica WITH RESUME;
					END IF;
				END IF;
				
				IF cVisible <> cVisibleAnt THEN 
					UPDATE bdinteg:si_paramProd1200
					SET esvisible = cVisibleAnt, user_modifica = pUsuarioMod, fecha_modifica = CURRENT
					WHERE tasa = 'EJEMP' AND producto = 1200 AND rowid = idRegistro;
					
					INSERT INTO bdinteg:"informix".si_bitacoraprod1200 (campo, valor_ant, valor_nuevo, usuario_insert, fecha_modifica)
					VALUES ('esvisible', cVisible, cVisibleAnt, pUsuarioMod, CURRENT);
					
					IF DBINFO("sqlca.sqlerrd2") = 0 THEN
						LET cCodRet = '00283';
						RETURN cCodRet, iIdRegistro, dSdoDesde, dSdoHasta, dTasaRendCetes, iTasaRendxCetes, iPeriodo, dGatNominal, dGatReal, cVisible, dFechaModifica WITH RESUME;
					END IF;
				END IF;
				
				IF NVL(pPeriodo,'') <> '' OR NVL(pTasa,0) <> 0 THEN 
					EXECUTE PROCEDURE bdicheq:"informix".sp_cap_recalculagat1200(pUsuario, pIdFuncion, pUsuarioMod, '2', idRegistro, pTasa) 
					INTO cCodRet;
					IF cCodRet <> '00000' THEN
						RETURN cCodRet, iIdRegistro, dSdoDesde, dSdoHasta, dTasaRendCetes, iTasaRendxCetes, iPeriodo, dGatNominal, dGatReal, cVisible, dFechaModifica;
					END IF;
				END IF;
				
			END FOREACH;
		END IF;
		
		IF pBandera = '1' THEN 
			IF iTotalRegistro = 0 THEN 
				LET cCodRet = '00017';
				RETURN cCodRet, iIdRegistro, dSdoDesde, dSdoHasta, dTasaRendCetes, iTasaRendxCetes, iPeriodo, dGatNominal, dGatReal, cVisible, dFechaModifica;
			END IF;
		ELIF pBandera = '2' THEN 
			RETURN cCodRet, iIdRegistro, dSdoDesde, dSdoHasta, dTasaRendCetes, iTasaRendxCetes, iPeriodo, dGatNominal, dGatReal, cVisible, dFechaModifica WITH RESUME;
		END IF;

	END
END PROCEDURE
DOCUMENT 'AUTOR: VERONICA SANCHEZ TLACOMULCO',
'FECHA: 19/12/2025',
'MODULO: debito',
'FUNCIONALIDAD: MANTENIMIENTO CARATULA PRODUCTO 1200',
'DESCRIPCION: SPL encargado de realizr la consulta para obtener los datos a mostrar en pantalla y actualizar la informacion',
'BD: bdicheq';

CREATE PROCEDURE "informix".sp_cap_recalculagat1200(pUsuario CHAR(8), pIdFuncion CHAR(10), pUsuarioMod CHAR(8), pBandera CHAR(1), pRowid INTEGER, pTasa DECIMAL(9,6))
		RETURNING CHAR(5) AS codret; 
    
	--DEFINICIÃN DE VARIABLES
	DEFINE cCodRet 		    CHAR(5);
	DEFINE iSqlErr 		    INTEGER;
	DEFINE cFechaAct		 DATETIME YEAR TO SECOND;
	DEFINE dMedianaInfl		 DECIMAL(9,6);
	DEFINE iPeriodo			INTEGER;
	DEFINE dGatNominal		DECIMAL(9,6);
	DEFINE dGatReal			DECIMAL(9,6);
	DEFINE vgat_nominal		DECIMAL(9,6);
	DEFINE vgat_real		DECIMAL(9,6);
	DEFINE valor			DECIMAL(9,6);
	DEFINE iIdRegistro		INTEGER;
	DEFINE iTotalRegistro	INTEGER;
	DEFINE dTasa			DECIMAL(9,6);

	LET cCodRet 		= '00000';
	LET iSqlErr 		= 0;
	LET cFechaAct		= '';
	LET dMedianaInfl	= 0;
	LET iPeriodo		= 0;
	LET dGatNominal		= 0;
	LET dGatReal		= 0;
	LET vgat_nominal 	= 0;
	LET vgat_real	 	= 0;
	LET valor			= 0;
	LET iIdRegistro		= 0;
	LET iTotalRegistro	= 0;
	LET dTasa			= 0;

	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_cap_recalculagat1200.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' OR pBandera = '' AND pUsuarioMod = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pRowid = 0 THEN
			FOREACH
				SELECT rowid
				INTO iIdRegistro
				FROM bdinteg:si_paramProd1200
				WHERE tasa = 'EJEMP' AND producto = 1200
				EXECUTE FUNCTION bdicheq:sp_cap_respaldohistorico (pUsuario,pIdFuncion,iIdRegistro) INTO cCodRet;
				IF cCodRet <> '00000' THEN
					RETURN cCodRet;
				END IF;
			END FOREACH;
		END IF;
		
		SELECT MAX(fecha_insert) 
		INTO cFechaAct
		FROM bdinteg:si_medProd1200
		WHERE producto = '1200' AND tasa = 'EJEMP';
		
		IF NVL(cFechaAct,'') = '' THEN 
			LET cCodRet = '00017';
			RETURN cCodRet;
		END IF;
		
		SELECT mediana_inflacion 
		INTO dMedianaInfl
		FROM bdinteg:si_medProd1200
		WHERE producto = '1200' AND tasa = 'EJEMP' AND fecha_insert = cFechaAct;
		
		/*IF NVL(dMedianaInfl,0) = 0 THEN 
			LET cCodRet = '00017';
			RETURN cCodRet;
		END IF;*/
			
		IF pBandera = '1' THEN 
			FOREACH
				SELECT rowid,  tasarendcetes, periodo, gatnominal, gatreal
				INTO iIdRegistro, dTasa, iPeriodo, dGatNominal, dGatReal
				FROM bdinteg:si_paramProd1200
				WHERE tasa = 'EJEMP' AND producto = 1200
				
				LET iTotalRegistro = iTotalRegistro + 1;
				
				LET vgat_nominal = ROUND((POW((1 + dTasa/iPeriodo),iPeriodo) - 1), 2);
				LET vgat_real = ROUND(((((1 + (vgat_nominal/100)) / (1 + (dMedianaInfl/100)))-1)*100),2);
				
				UPDATE bdinteg:si_paramProd1200
				SET gatnominal = vgat_nominal, gatreal = vgat_real, user_modifica = pUsuarioMod, fecha_modifica = CURRENT
				WHERE tasa = 'EJEMP' AND producto = 1200 AND rowid = iIdRegistro;
				
				INSERT INTO bdinteg:"informix".si_bitacoraprod1200 (campo, valor_ant, valor_nuevo, usuario_insert, fecha_modifica) 
				VALUES ('gatnominal', dGatNominal, vgat_nominal, pUsuarioMod, CURRENT);
				
				IF DBINFO("sqlca.sqlerrd2") = 0 THEN
					LET cCodRet = '00283';
					RETURN cCodRet;
				END IF;
				
				INSERT INTO bdinteg:"informix".si_bitacoraprod1200 (campo, valor_ant, valor_nuevo, usuario_insert, fecha_modifica)
				VALUES ('gatreal', dGatReal, vgat_real, pUsuarioMod, CURRENT);
				
				IF DBINFO("sqlca.sqlerrd2") = 0 THEN
					LET cCodRet = '00283';
					RETURN cCodRet;
				END IF;
			END FOREACH;
		ELIF pBandera = '2' THEN 
			SELECT periodo, tasarendcetes, gatnominal, gatreal
			INTO iPeriodo, dTasa, dGatNominal, dGatReal
			FROM bdinteg:si_paramProd1200
			WHERE tasa = 'EJEMP' AND producto = 1200 AND rowid = pRowid;
			
			LET vgat_nominal = ROUND((POW((1 + dTasa/iPeriodo),iPeriodo) - 1), 2);
			LET vgat_real = ROUND(((((1 + (vgat_nominal/100)) / (1 + (dMedianaInfl/100)))-1)*100),2);
			
			UPDATE bdinteg:si_paramProd1200
			SET gatnominal = vgat_nominal, gatreal = vgat_real, user_modifica = pUsuarioMod, fecha_modifica = CURRENT
			WHERE tasa = 'EJEMP' AND producto = 1200 AND rowid = pRowid;
			
			INSERT INTO bdinteg:"informix".si_bitacoraprod1200 (campo, valor_ant, valor_nuevo, usuario_insert, fecha_modifica)
			VALUES ('gatnominal', dGatNominal, vgat_nominal, pUsuarioMod, CURRENT);
			
			IF DBINFO("sqlca.sqlerrd2") = 0 THEN
				LET cCodRet = '00283';
				RETURN cCodRet;
			END IF;
			
			INSERT INTO bdinteg:"informix".si_bitacoraprod1200 (campo, valor_ant, valor_nuevo, usuario_insert, fecha_modifica)
			VALUES ('gatreal', dGatReal, vgat_real, pUsuarioMod, CURRENT);
			
			IF DBINFO("sqlca.sqlerrd2") = 0 THEN
				LET cCodRet = '00283';
				RETURN cCodRet;
			END IF;
		END IF;
		
		IF pBandera = '1' THEN 
			IF iTotalRegistro = 0 THEN 
				LET cCodRet = '00017';
				RETURN cCodRet;
			END IF;
		ELIF pBandera = '2' THEN 
			IF NVL(iPeriodo, 0) = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet;
			END IF;
		END IF;
		
		RETURN cCodRet;
	END
END PROCEDURE
DOCUMENT 'AUTOR: VERONICA SANCHEZ TLACOMULCO',
'FECHA: 19/12/2025',
'MODULO: DEBITO',
'FUNCIONALIDAD: MANTENIMIENTO CARATULA PRODUCTO 1200',
'DESCRIPCION: SPL encargado de recalcular la gat nominal y real',
'BD: bdicheq';

CREATE PROCEDURE "informix".sp_cap_respaldohistorico(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdRow INTEGER)
		RETURNING CHAR(5) AS codret; 

    
	--DEFINICIÃN DE VARIABLES
	DEFINE cCodRet 		    CHAR(5);
	DEFINE iSqlErr 		    INTEGER;
	DEFINE cTasa			CHAR(8);
	DEFINE cProducto		CHAR(4);
	DEFINE dSdoDesde		DECIMAL(14,2);
	DEFINE dSdoHasta		DECIMAL(14,2);
	DEFINE dTasaRendCetes	DECIMAL(9,6);
	DEFINE iTasaRendxCetes	INTEGER;
	DEFINE iPeriodo			INTEGER;
	DEFINE dGatNominal		DECIMAL(9,6);
	DEFINE dGatReal			DECIMAL(9,6);
	DEFINE cVisible			CHAR(2);
	DEFINE iTotalReg		INTEGER;
	DEFINE cUserModifica	CHAR(8);
	DEFINE dFechaModifica	DATE;

	LET cCodRet 		= '00000';
	LET iSqlErr 		= 0;
	LET cTasa			= '';
	LET cProducto		= '';
	LET dSdoDesde		= 0;
	LET dSdoHasta		= 0;
	LET dTasaRendCetes	= 0;
	LET iTasaRendxCetes	= 0;
	LET iPeriodo		= 0;
	LET dGatNominal		= 0;
	LET dGatReal		= 0;
	LET cVisible		= '';
	LET iTotalReg		= 0;
	LET cUserModifica   = '';
	LET dFechaModifica  = '';


	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_cap_respaldohistorico.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' OR pIdRow IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT COUNT(*) 
		INTO iTotalReg 
		FROM bdinteg:si_paramProd1200
		WHERE rowid = pIdRow;
		
		IF NVL(iTotalReg,0) = 0 THEN 
			LET cCodRet = '00017';
			RETURN cCodRet;
		END IF;
		
		SELECT tasa, producto, saldo_desde, saldo_hasta, tasarendcetes, tasarendxcetes, periodo, gatnominal, gatreal, esvisible, user_modifica, fecha_modifica
		INTO cTasa, cProducto, dSdoDesde, dSdoHasta, dTasaRendCetes, iTasaRendxCetes, iPeriodo, dGatNominal, dGatReal, cVisible, cUserModifica, dFechaModifica
		FROM bdinteg:si_paramProd1200
		WHERE rowid = pIdRow;
		
		INSERT INTO bdinteg:si_paramProd1200_hist (tasa, producto, saldo_desde, saldo_hasta, tasarendcetes, tasarendxcetes, periodo, gatnominal, gatreal, esvisible, user_modifica, fecha_modifica) 
		VALUES (cTasa, cProducto, dSdoDesde, dSdoHasta, dTasaRendCetes, iTasaRendxCetes, iPeriodo, dGatNominal, dGatReal, cVisible, cUserModifica, dFechaModifica);
		
		IF DBINFO('sqlca.sqlerrd1') = 0 THEN 
			LET cCodRet = '00282';
			RETURN cCodRet;
		END IF;
		
		RETURN cCodRet;
		
	END
END PROCEDURE
DOCUMENT 'AUTOR: VERONICA SANCHEZ TLACOMULCO',
'FECHA: 19/12/2025',
'MODULO: DEBITO',
'FUNCIONALIDAD: HISTORICO ACTUALIZACIONES CARATULA PRODUCTO 1200',
'DESCRIPCION: SPL encargado de realiza el respaldo historico de la actualizacion de las tasas',
'BD: bdicheq';

CREATE PROCEDURE "informix".sp_retencion_anticipada(p_empresa  CHAR(3))
RETURNING CHAR(5), CHAR(80);

-- EXCEPCIONES SQL
DEFINE i_sql_err        INTEGER;		-- CODIGO DE ERROR SQL
DEFINE i_isam_err       INTEGER;		-- CODIGO DE ERROR SQL
DEFINE c_error_info     CHAR(80);		-- MENSAJE DE ERROR SQL

DEFINE c_cod_ret		CHAR(5);   		-- CODIGO DE RETORNO
DEFINE c_mensaje		CHAR(80);		-- MENSAJE DE RETORNO
DEFINE dt_fecha_hoy     DATE;      		-- FECHA DE HOY
DEFINE dt_fecha_prox    DATE;      		-- FECHA POSTERIOR A 2 DIAS
DEFINE c_act_retenido   CHAR(1);		-- BANDERA PARA IDENTIFICAR SI EL PRODUCTO CUENTA CON RETENCION ACTIVA
DEFINE s_existe_cntrl	SMALLINT;		-- CONTADOR DE REGISTROS EN LA TABLA SC_CONTROL_COBRANZA_AUTOMATICA POR CUENTA	
DEFINE c_num_producto	CHAR(20);		-- NUMERO DE PRODUCTO DE CREDITO

DEFINE c_codret_sp		CHAR(5);		-- CODIGO DE RETORNO DE SP_RETENCION_COBRANZA_AUTOMATICA
DEFINE c_msjret_sp		CHAR(150);    	-- MENSAJE DE RETORNO DE SP_RETENCION_COBRANZA_AUTOMATICA

DEFINE cCuentaCaptacion	CHAR(20);		-- CUENTA ASOCIADA AL CREDITO
DEFINE cNumeroCliente	CHAR(20);		-- NUMERO DE CLIENTE 
DEFINE dMontoXPagar		DECIMAL(18,2);  -- MONTO CUOTA A PAGAR
DEFINE mMontoRetenido	MONEY(14,2);    -- MONTO RETENIDO
DEFINE iStatus			INTEGER;	    -- VARIABLE PARA INDICAR EL ESTATUS DE LA RETENCION  
DEFINE cCodRetCtrl                   CHAR(5);
DEFINE cMensajeRet                   CHAR(125);



-- EXCEPCIONES SQL
LET i_sql_err         	= 0;
LET i_isam_err        	= 0;
LET c_error_info      	= '';

LET c_cod_ret 			= "00000";
LET c_mensaje			= "Se realizo el Proceso correctamente";
LET dt_fecha_hoy  	    = DATE(1);
LET dt_fecha_prox  	    = DATE(1);
LET c_act_retenido 		= '0';
LET s_existe_cntrl      = 0;
LET c_num_producto		= '';	

LET c_codret_sp		  	= '';
LET c_msjret_sp			= '';	

LET cCuentaCaptacion 	= '';
LET cNumeroCliente		= '';
LET dMontoXPagar	 	= 0;
LET mMontoRetenido      = 0.00;
LET iStatus				= 0;
LET cCodRetCtrl           = "00000";
LET cMensajeRet           = "Se realizo el pago correctamente";

--SET DEBUG FILE TO "/resplogifx/archivoscredito/sp_retencion_anticipada.out";
--TRACE ON;

BEGIN
	
	ON EXCEPTION SET i_sql_err, i_isam_err, c_error_info
		IF i_sql_err != 0 THEN
			LET c_cod_ret = i_sql_err;
			LET c_mensaje = c_error_info;
		END IF;
				
	DROP TABLE IF EXISTS tmp_retenciones_cobauto;
	DROP TABLE IF EXISTS tmp_ret_depurada;

		RETURN c_cod_ret, c_mensaje;
	END EXCEPTION;
	
	
	IF p_empresa = "" THEN
		LET c_cod_ret = '11111';
		LET c_mensaje = "";
		RETURN c_cod_ret, c_mensaje;
	END IF;

	SELECT 	fecha_hoy 
	INTO 	dt_fecha_hoy
	FROM 	bdicred:"informix".sd_fechas
	WHERE 	empresa = p_empresa;

	
	DROP TABLE IF EXISTS tmp_retenciones_cobauto;
	DROP TABLE IF EXISTS tmp_ret_depurada;
	
	-- SE AGREGAN 2 DIAS (48 HRS) A LA VARIABLE DE DT_FECHA_HOY
	LET dt_fecha_prox = DATE(dt_fecha_hoy)  + 3 UNITS DAY ;
	
	SELECT 	cta.num_cta AS cuenta_captacion,amor.capital_mto_cuota AS monto_exigible,cred.numcte,cred.num_producto,  amor.fecha_cuota , mae.prox_fecha_pago, mdoscrd.monto_vencido, mdoscrd.monto_reservado, mdoscrd.monto_financiado
	FROM 		bdicred:"informix".sd_maecredcrd cred
	INNER JOIN	bdicred:"informix".sd_amortiza_creditocrd amor 	ON cred.empresa = amor.empresa 	AND cred.num_credito = amor.num_credito
	INNER JOIN	bdicred:"informix".sd_ctascarg cta 				ON cred.empresa = cta.empresa 	AND cred.num_credito = cta.num_credito
	INNER JOIN	bdicred:"informix".sd_maecredanexocrd mae 		ON cred.empresa = mae.empresa 	AND cred.num_credito = mae.num_credito
	INNER JOIN	"informix".sc_maechq cheq 						ON cta.empresa = cheq.empresa 	AND cta.num_cta	= cheq.cuenta
	INNER JOIN  bdicred:"informix".sd_maesdoscrd mdoscrd        ON cred.empresa = mdoscrd.empresa 	AND cred.num_credito = mdoscrd.num_credito
	WHERE 	cred.num_producto = '6400'
	AND 	NVL(amor.campo_trabajo4,'') = ''
	AND     cred.status_cred IN ("E1","E2","E3")
	AND   	amor.capital_status NOT IN ("5")
	AND 	mae.fecha_proceso >= dt_fecha_hoy INTO TEMP tmp_retenciones_cobauto WITH NO LOG;
	
	INSERT INTO tmp_retenciones_cobauto (cuenta_captacion,monto_exigible,numcte,num_producto,fecha_cuota,prox_fecha_pago,monto_vencido,monto_reservado,monto_financiado)
		SELECT 	adn.cuenta_nomina, 	sdos.sdo_cap_insoluto AS monto_exigible, 	cred.numcte, 	cred.num_producto, '' AS fecha_cuota , maec.prox_fecha_pago,mdos.monto_vencido, mdos.monto_reservado, mdos.monto_financiado
		FROM 		bdicred:"informix".sd_maecred cred
		INNER JOIN	bdicred:"informix".sd_maesdos sdos  	        ON cred.empresa = sdos.empresa 	AND cred.num_credito = sdos.num_credito
		INNER JOIN	bdicred:"informix".sd_maecredanexo maec 		ON cred.empresa = maec.empresa 	AND cred.num_credito = maec.num_credito
		INNER JOIN	bdisolic:"informix".ss_adn_solicitudcuenta adn 	ON cred.empresa = adn.empresa 	AND cred.num_credito = adn.num_solicitud
		INNER JOIN	"informix".sc_maechq cheq 						ON adn.empresa = cheq.empresa 	AND adn.cuenta_nomina = cheq.cuenta
		INNER JOIN  bdicred:"informix".sd_maesdos mdos              ON cred.empresa = mdos.empresa 	AND cred.num_credito = mdos.num_credito
		WHERE 	cred.num_producto = '7800'
		AND 	cred.status_cred IN ("E1","E3")
		AND		sdos.sdo_cap_insoluto > 0;
	
	
	CREATE TEMP TABLE tmp_ret_depurada 
	(
		cuenta_captacion		CHAR(20),
		numero_cliente			CHAR(20),
		monto_x_pagar 			DECIMAL(18,2),
		num_producto			CHAR(4),
		bandera_caso			CHAR(15)
	)WITH NO LOG;
	
	-- SE CONSULTA SI EL PRODUCTO 6400 TIENE ACTIVA LA BANDERA DE ACTIVO_RETENIDO
	SELECT 	activo_retenido 
	INTO 	c_act_retenido
	FROM 	bdicred:"informix".sd_definicion
	WHERE 	num_producto = '6400';
	
	IF c_act_retenido = 1 THEN
	--PDN vigentes 
	INSERT INTO tmp_ret_depurada (cuenta_captacion,numero_cliente,monto_x_pagar,num_producto,bandera_caso)
	SELECT cuenta_captacion,numcte AS numero_cliente,monto_exigible AS monto_x_pagar,num_producto,'PDN_vigente' AS bandera_caso
	FROM tmp_retenciones_cobauto 
		WHERE num_producto = '6400'
		AND monto_vencido = 0 
		AND fecha_cuota = prox_fecha_pago 
		AND fecha_cuota BETWEEN dt_fecha_hoy AND dt_fecha_prox;
		
	--PDN con atraso	
	INSERT INTO tmp_ret_depurada (cuenta_captacion,numero_cliente,monto_x_pagar,num_producto,bandera_caso)
	SELECT cuenta_captacion,numcte AS numero_cliente,monto_reservado AS monto_x_pagar,num_producto,'PDN_atraso' AS bandera_caso
	FROM tmp_retenciones_cobauto 
		WHERE num_producto = '6400' 
		AND monto_vencido > 0
		GROUP BY 1,2,3,4,5;

	END IF;

	SELECT 	activo_retenido 
	INTO 	c_act_retenido
	FROM 	bdicred:"informix".sd_definicion
	WHERE 	num_producto = '7800';

	
	IF c_act_retenido = 1 THEN
	--ADN vigentes	
	INSERT INTO tmp_ret_depurada (cuenta_captacion,numero_cliente,monto_x_pagar,num_producto,bandera_caso)
	SELECT cuenta_captacion,numcte AS numero_cliente,monto_exigible AS monto_x_pagar,num_producto,'ADN_vigente' AS bandera_caso
	FROM tmp_retenciones_cobauto 
		WHERE num_producto = '7800' 
		AND monto_vencido = 0
		AND prox_fecha_pago BETWEEN dt_fecha_hoy AND dt_fecha_prox;
		
	--ADN con atraso	
	INSERT INTO tmp_ret_depurada (cuenta_captacion,numero_cliente,monto_x_pagar,num_producto,bandera_caso)
	SELECT cuenta_captacion,numcte AS numero_cliente,monto_reservado AS monto_x_pagar,num_producto,'ADN_atraso' AS bandera_caso
	FROM tmp_retenciones_cobauto 
		WHERE num_producto = '7800' 
		AND monto_vencido > 0;

	END IF;

	FOREACH WITH HOLD
	SELECT cuenta_captacion,numero_cliente,SUM(monto_x_pagar)
	INTO cCuentaCaptacion,cNumeroCliente,dMontoXPagar
	FROM tmp_ret_depurada GROUP BY 1,2
	
		SELECT 	COUNT(*) 
			INTO 	s_existe_cntrl
			FROM 	"informix".sc_control_cobranza_automatica  
			WHERE 	numero_cliente	 = cNumeroCliente 
			AND 	cuenta_captacion = cCuentaCaptacion;
		
		IF s_existe_cntrl >= 1 THEN
		
			UPDATE "informix".sc_control_cobranza_automatica
				SET monto_pendiente_por_pagar 	= dMontoXPagar,
					pendiente_a_retener 		= dMontoXPagar - monto_retenido,
					estatus 					= CASE WHEN monto_retenido > 0 THEN 2 ELSE 1 END,
					fecha_modificacion			= CURRENT
				WHERE 	numero_cliente	 = cNumeroCliente 
				AND 	cuenta_captacion = cCuentaCaptacion;
			
		ELSE
		
			INSERT INTO "informix".sc_control_cobranza_automatica(numero_cliente, cuenta_captacion, estatus, monto_pendiente_por_pagar, monto_retenido, pendiente_a_retener, fecha_modificacion, user_insert, fecha_insert)
				VALUES (cNumeroCliente, cCuentaCaptacion, 1, dMontoXPagar, 0, dMontoXPagar, CURRENT, USER, dt_fecha_hoy);
		
		END IF;
		
		EXECUTE PROCEDURE "informix".sp_retencion_cobranza_automatica(cNumeroCliente,cCuentaCaptacion,'') INTO c_codret_sp, c_msjret_sp;
	
	END FOREACH;
	
	FOREACH WITH HOLD
	    -- SE REALIZA UNA DISTINCION DE CUENTAS A LAS QUE YA SE PAGARON PERO TIENE UN RETENIDO
		SELECT ctrl.cuenta_captacion, ctrl.numero_cliente, ctrl.monto_retenido, ctrl.estatus
		INTO  cCuentaCaptacion, cNumeroCliente, mMontoRetenido, iStatus
		FROM "informix".sc_control_cobranza_automatica AS ctrl 
		LEFT JOIN tmp_ret_depurada AS tmp ON tmp.cuenta_captacion = ctrl.cuenta_captacion
		WHERE tmp.cuenta_captacion IS NULL
		AND ctrl.monto_retenido <> 0 

		-- SE VALIDA QUE SI EL ESTATUS ES 3 LO CAMBIAMOS A 2 PARA PODER DESRETENER
		IF iStatus = 3 THEN
			UPDATE "informix".sc_control_cobranza_automatica
			SET estatus = 2
			WHERE 	numero_cliente	 = cNumeroCliente 
			AND 	cuenta_captacion = cCuentaCaptacion;

	    END IF;

		-- SE EJECURTA LA DESRETENCION PARA LOS CASOS YA PAGADOS
		EXECUTE PROCEDURE bdicheq:"informix".sp_desretencion_cobranza_automatica(
					cNumeroCliente, -- Numero de cliente
					cCuentaCaptacion, -- Numero de cuenta de captacion.
					mMontoRetenido -- Monto a des retener. 
		) INTO cCodRetCtrl,cMensajeRet;	

		-- SE VALIDA SI SE REALIZO LA DESRETENCION PARA ACTUALIZAR LA TABLA DE CONTROL
		IF cCodRetCtrl = '00000' THEN			
			UPDATE "informix".sc_control_cobranza_automatica
			SET monto_pendiente_por_pagar 	= 0,
				pendiente_a_retener 		= 0,
				monto_retenido				= 0,
				estatus 					= 3,
				fecha_modificacion			= CURRENT
			WHERE 	numero_cliente	 = cNumeroCliente 
			AND 	cuenta_captacion = cCuentaCaptacion;
		END IF;

	END FOREACH;

	DROP TABLE IF EXISTS tmp_retenciones_cobauto;
	DROP TABLE IF EXISTS tmp_ret_depurada;

	RETURN c_cod_ret, c_mensaje;

END
END PROCEDURE
DOCUMENT
'=======================================================',
'Proyecto	: RQM 09 704',
'Descripcion: Retencion anticipada de saldo de captacion para cuentas que presentan credinomina y su proxima fecha de pago cae en dia inhabil',
'Desarrollo	: Juan Olivares Martinez/Maria Elena Angulo',
'Fecha		: 31/Marzo/2025',
'=======================================================',
'Proyecto	: RQM 09 704',
'Descripcion: Se elimino validacion de dia inhabil y se consultan los pagos de las proximas 48 horas',
'			  Se agrego foreach para producto 7800',
'			  Se agrego ejecucion de sp_retencion_cobranza_automatica',
'Desarrollo	: Jose Gil Hernandez',
'Fecha		: 10/Nov/2025',
'=======================================================',
'Proyecto	: RQM 09 704',
'Descripcion: Se refactoriza el procedimiento para centralizar el proceso de marcaje para retencion',
'Desarrollo	: Luis Enrique Orozco Cosme',
'Fecha		: 23/Mar/2026',
'=======================================================';

CREATE PROCEDURE "informix".sp_retencion_cobranza_automatica(
							pNumeroCliente 		CHAR(20),			--Numero de cliente con un saldo por retener
							pCuentaCaptacion 	CHAR(20), 			--Numero de cuenta de captacion a validar 
							pFolioSucAbono		CHAR(16))			--Numero de folio_suc del abono al que esta ligada la inmovilizacion
RETURNING 	CHAR(5), 
			CHAR(150);
			
	--Declaracion de variables
	--Variables para retorno del SP
	DEFINE cCodRet				CHAR(5);						--Codigo de retorno del SP
	DEFINE cMensajeRet          CHAR(150);                      --Mensaje de retorno del SP
	--Variables para retorno del SP de actualizacion de la tabla de control
	DEFINE cCodRetSPActualiza		CHAR(5);					--Codigo de retorno del SP de actualizacion
	DEFINE cMensajeRetSPActualiza   CHAR(150);                  --Mensaje de retorno del SP de actualizacion
	--Variable de manejo de excepciones
	DEFINE iSQLError            INTEGER;                        --Variable de codigo SQL 
	DEFINE iISAMError           INTEGER;                        --Variable de codigo ISAM 
	--Variables para la obtencion de datos de la cuenta
	DEFINE mSdoActual           MONEY(14,2);                    --Variable del saldo actual de la cuenta
	DEFINE mSdoRetenido         MONEY(14,2);                    --Variable del saldo retenido 
	DEFINE mImpChqSbg			MONEY(14,2);					--Variable del importe de cheques sbg
	DEFINE mSdoCong				MONEY(14,2);					--Variable del saldo congelado
	DEFINE mSaldoSBC				MONEY(14,2);				--Variable del saldo salvo buen cobro (saldo inmovilizado)
	DEFINE dFechaProceso        DATE;                           --Variable de la fecha de proceso de la cuenta de cheques
	DEFINE cStatusCta			CHAR(1);						--Estatus de la cuenta
	--Variable para la obtencion de fecha del sistema
	DEFINE dFechaHoy            DATE;                           --Variable para la fecha del sistema de cheques
	--Variables para la obtencion de datos de los saldos por pagar ligados a la cuenta
	DEFINE mMontoPendientexPagar MONEY(14,2);              		--Monto a retener por concepto de pago
	DEFINE mMontoRetenido		MONEY(14,2);					--Monto que se ha retenido a la cuenta
	DEFINE mPendienteARetener	MONEY(14,2);					--Monto pendiente por retener
	DEFINE mMontoRetenOperActual MONEY(14,2);					--Monto retenido en esta operacion
	--Variables para el registro en la tabla de movimientos del dia del sistema de cheques 
	DEFINE cEmpresa				CHAR(3);						--Variable para numero de identificacion de la empresa
	DEFINE cSucursal			CHAR(4);						--Variable para el numero de sucursal del movimiento
	DEFINE cFolioSuc            CHAR(16);                       --Folio suc del movimiento para insercion en movdia
	DEFINE dFechHor             DATETIME HOUR TO FRACTION(3);   --Valor de la Hora en la que se realiza la operacion
	DEFINE cTransacc            CHAR(4);                        --Numero de la transaccion del movimiento de inmovilizacion
	DEFINE cSucCuen             CHAR(4);                        --Sucursal de la cuenta 
	DEFINE cProducto            CHAR(4);                        --Numero de producto de la cuenta involucrada
	DEFINE mSdoDisponible       MONEY(14,2);                    --Saldo de la cuenta para la insercion en movimientos del dia
	DEFINE cTransaccSuc         CHAR(4);                        --Transaccion de la Sucursal
	DEFINE cReferencia          CHAR(40);                       --Referencia del movimiento 
	DEFINE cUsuAutoriza			CHAR(8);						--Usuario de sistema que autoriza la operacion 
	--Variables de utileria
	DEFINE cCodParamTransacc	CHAR(14);						--Variable para el almacenamiento del codigo de parametro de la transaccion de inmovilizacion
	DEFINE iEstatusRetenido		INTEGER;						--Variable para indicar el estatus de saldo retenido.
	DEFINE cPrefijoFolioSuc		CHAR(6);                        --Variable para almacenar el prefijo a usar en el folio_suc
	DEFINE cCodRetConsSdo		CHAR(5); 						--Codigo de retorno de SP de consulta de saldo.
	DEFINE cMensajeRetConsSdo 	CHAR(50); 						--Mensaje de retorno de SP de consulta de saldo.
	DEFINE iStatus				INTEGER;						--Variable para indicar el status de la retencion (por retener, retenido, cobrado)
	DEFINE vtransaccion         INTEGER;
    
	
	--Declaracion de archivo de debuggeo
	--SET DEBUG FILE TO "/home/c90314833/sp_inmovilizacion_cobranza_automatica.out";
    --TRACE ON;
	
	--Inicializacion de variables
	LET cCodRet					='00000';
	LET cMensajeRet         	='Proceso de inmovilizacion finalizado exitosamente';
	
	LET iSQLError           	=0;
	LET iISAMError          	=0;
	
	LET mSdoActual          	=0.00;
	LET mSdoRetenido        	=0.00;
	LET mImpChqSbg				=0.00;
	LET mSdoCong				=0.00;
	LET mSaldoSBC				=0.00;
	LET dFechaProceso       	=TODAY;
	LET cStatusCta				='1';
	
	LET dFechaHoy           	=TODAY;
	
	LET mMontoPendientexPagar   =0.00;
	LET mMontoRetenido			=0.00;
	LET mPendienteARetener		=0.00;
	LET mMontoRetenOperActual	=0.00;
	
	LET cEmpresa				='001';
	LET cSucursal				='9290';
	LET cFolioSuc           	='';
	LET dFechHor            	=CURRENT HOUR TO FRACTION;
	LET cTransacc           	='';
	LET cSucCuen            	='';
	LET cProducto           	='';
	LET mSdoDisponible          	=0.00;
	LET cTransaccSuc        	='0000';
	LET cReferencia         	='INMOVILIZA COBRO AUTO';
	LET cUsuAutoriza			='informix';
	
	LET cCodParamTransacc		='TRANRETCOBAUTO';
	LET iEstatusRetenido 		=2;
	LET cPrefijoFolioSuc		='retsal';
	LET cCodRetConsSdo			= '00000';
	LET cMensajeRetConsSdo		= '';
	LET iStatus					= 3;
    LET vtransaccion            = 0;
	
	BEGIN
	
		--Manejo de excepciones
		ON EXCEPTION SET iSQLError, iISAMError, cMensajeRet
			IF iSQLError <> 0 THEN
				LET cCodRet = iSQLError;
					ROLLBACK TO SAVEPOINT sp_ret_cob_aut_savepoint;
					IF vtransaccion = 0 THEN
			        	COMMIT WORK;       
					END IF;
			END IF;
			RETURN cCodRet,cMensajeRet;
		END EXCEPTION;
		
		-- Se agrega la exepcion de la transaccion
		ON EXCEPTION IN (-535)
        	LET vtransaccion = 1;
    	END EXCEPTION WITH RESUME;

		--Directivas para nivel de lectura y tiempo de bloqueo
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		-- Se agrega el begin para iniciar una transaccion y en caso que no estÃÂ© modifique la variable de transaccion
        BEGIN WORK;

		--Punto de guardado de una transaccion en curso para realizar rollback solo desde este punto
		SAVEPOINT sp_ret_cob_aut_savepoint;
			
		--Validacion de valores nulos o vacios
		IF (pNumeroCliente = '' OR pNumeroCliente IS NULL) OR
		(pCuentaCaptacion = '' OR pCuentaCaptacion IS NULL) THEN
		
			LET cCodRet = '00001';
			LET cMensajeRet = 'El valor de algun parametro de entrada es nulo o se encuentra vacio';
			IF vtransaccion = 0 THEN
	        	COMMIT WORK;       
			END IF;
			RETURN cCodRet, cMensajeRet;
		
		END IF;
		
		--Consulta de validacion de montos a retener sobre la cuenta y conteo para validacion de existencia de inmovilizaciones pendientes
		SELECT monto_pendiente_por_pagar,pendiente_a_retener,monto_retenido, estatus
		INTO mMontoPendientexPagar,mPendienteARetener,mMontoRetenido, iStatus
		FROM sc_control_cobranza_automatica 
		WHERE numero_cliente = pNumeroCliente
		AND cuenta_captacion = pCuentaCaptacion;
		
		--Validacion de existencia de inmovilizaciones pendientes
		IF (mMontoPendientexPagar IS NULL) OR (mPendienteARetener IS NULL) OR (mPendienteARetener <= 0) OR (iStatus = 3) THEN
			LET cCodRet = '00002';
			LET cMensajeRet = 'No existen inmovilizaciones pendientes para la cuenta proporcionada';
			IF vtransaccion = 0 THEN
	        	COMMIT WORK;       
			END IF;
			RETURN cCodRet,cMensajeRet;
		END IF;
		
		--Obtencion de datos y saldos de la cuenta
		SELECT sucursal,producto,status_cta,imp_chq_sbg,sdo_cong, sdo_actual,sdo_retenido,saldo_sbc, fecha_proceso
		INTO cSucCuen,cProducto,cStatusCta,mImpChqSbg,mSdoCong,mSdoActual,mSdoRetenido,mSaldoSBC,dFechaProceso
		FROM sc_maechq
		WHERE cuenta = pCuentaCaptacion;
		
		--Obtencion de la transaccion para la inmovilizacion
		SELECT valor INTO cTransacc FROM sc_param WHERE codparam = cCodParamTransacc;
			
		--Calculo de saldo disponible de la cuenta
		EXECUTE PROCEDURE bdicheq:sp_cons_sdodisp_x_tpcalculo('',mSdoActual,mSdoRetenido,mSdoCong,mSaldoSBC,mImpChqSbg,0.00,0.00,'F',1) INTO cCodRetConsSdo,cMensajeRetConsSdo,mSdoDisponible;        
		
		--Validacion de saldo disponible menor o igual a 0
		IF mSdoDisponible <= 0 OR mSdoActual <= 0 THEN
			LET cCodRet = '00003';
			LET cMensajeRet = 'No hay saldo disponible en la cuenta, para realizar la inmovilizacion ';
			IF vtransaccion = 0 THEN
	        	COMMIT WORK;       
			END IF;
			RETURN cCodRet,cMensajeRet;
		END IF;
		
		--Validacion de saldo suficiente sobre la cuenta para la inmovilizacion 
		IF mSdoDisponible < mPendienteARetener THEN 
			LET mMontoRetenido = mMontoRetenido + mSdoDisponible;
			LET mMontoRetenOperActual = mSdoDisponible;
		ELSE
			LET mMontoRetenido = mMontoRetenido + mPendienteARetener;
			LET mMontoRetenOperActual = mPendienteARetener;
		END IF;
			
		--Movimientos de saldo para modificacion en maechq, insercion en movdia y actualizacion de tabla de control
		LET mSaldoSBC = mSaldoSBC + mMontoRetenOperActual;				
		LET mPendienteARetener = mPendienteARetener - mMontoRetenOperActual;
		
		--Obtencion de fechas de sistema
		SELECT fecha_hoy INTO dFechaHoy 
		FROM bdicheq:sc_fechas 
		WHERE empresa = cEmpresa;

		--Actualizacion de los saldos para la cuenta de cheques a la que se realizo la inmovilizacion
		UPDATE sc_maechq SET 
			saldo_sbc = mSaldoSBC,
			fec_ult_mov = dFechaHoy
		WHERE cuenta = pCuentaCaptacion; 
		
		--Armado del Folio_suc
		LET cFolioSuc = cPrefijoFolioSuc||LPAD(MONTH(CURRENT::DATE),2,0)||LPAD(DAY(CURRENT::DATE),2,0)||SUBSTR(TRIM(REPLACE(CURRENT::DATETIME HOUR TO FRACTION, ':', '')),1,6);
		
		--Insercion del movimiento de dia con la transaccion de inmovilizacion
		INSERT INTO sc_movdia VALUES
		(0, cFolioSuc, cSucursal, cUsuAutoriza, dFechaHoy, dFechaHoy, dFechHor, cTransacc, cSucCuen, cProducto, cEmpresa, pCuentaCaptacion, "", 0, mMontoRetenOperActual, mMontoRetenOperActual,0.00, 
		0.00, 0, "", cStatusCta, mSdoActual, cTransaccSuc, pFolioSucAbono||' '||cReferencia, 0, "", cUsuAutoriza, "", dFechaProceso);							
		
		--Actualizacion del registro de la tabla de control para actualizacion de montos y estatus
		EXECUTE PROCEDURE sp_actualiza_control_cobranza_automatica(pNumeroCliente,pCuentaCaptacion,iEstatusRetenido,mMontoPendientexPagar,mMontoRetenido,mPendienteARetener)
		INTO cCodRetSPActualiza,cMensajeRetSPActualiza;				
		
		IF cCodRetSPActualiza <> '00000' THEN
			LET cCodRet = '00004';
			LET cMensajeRet = 'Error al actualizar el registro en la tabla de control: (Codigo: '||cCodRetSPActualiza||')';
			ROLLBACK TO SAVEPOINT sp_ret_cob_aut_savepoint;
			IF vtransaccion = 0 THEN
	        	COMMIT WORK;       
			END IF;
			RETURN cCodRet,cMensajeRet;	
		END IF;
		
		-- verifica si la transaccion la inicio el spl o ya la traia
		IF vtransaccion = 0 THEN
        	COMMIT WORK;       
        END IF;

		--Finalizacion del proceso
		RETURN cCodRet,cMensajeRet;
	END
END PROCEDURE
DOCUMENT
'AUTOR :        Luis Enrique Orozco Cosme',
'FECHA :        01-10-2025',
'DESCRIPCION :  Este SPL tiene la finalidad de retener el saldo a las cuentas que tienen una exigibilidad de pago (se encuentren en la tabla sc_control_cobranza_automatica)',
'               ya sea de PDN(Prestamo Directo de Nomina) o de ADN (Anticipo de Nomina)',
'PROYECTO :     RQM 09 704 Cobranza Automatica en Cuentas de Captacion',
'BD :           bdicheq',
'VERSION :      1.0.0';

CREATE PROCEDURE "informix".sp_procesa_ctas_com_prod2100(pEmpresa char(3))
RETURNING   CHAR(5);
	
	DEFINE vCodRet CHAR(5);
	DEFINE vCodRet2 Char(5);
    DEFINE vCodRet3 Char(50);
	DEFINE cSQL_ERR     Integer;
    DEFINE cISAM_ERR    Integer;
    DEFINE cDESC_ERR    Char(50);
	DEFINE vCliente char(20);
	DEFINE vCuenta char(20);
	DEFINE dFechaInicio date;
	DEFINE diaMesiversario char(6);
	DEFINE iCuentaInactiva int;
	DEFINE iMovimientos int;
	DEFINE mSaldoPromMes1 money(16,2);
	DEFINE mSaldoPromMes2 money(16,2);
	DEFINE mSaldoPromMes3 money(16,2);
	DEFINE mSaldoAcomulado1 money(16,2);
	DEFINE mSaldoAcomDisp money(16,2);
	DEFINE mSaldoAcomDispOld money(16,2);
	DEFINE mSaldoAcomuladoOld money(16,2);
	DEFINE mSaldoAcomulado2 money(16,2);
	DEFINE mSaldoAcomulado3 money(16,2);
	DEFINE mSaldoAcomuladoPorta money(16,2);
	DEFINE mSaldoAcomuladoEmp money(16,2);
	DEFINE dFechaFinalMes1 date;
	DEFINE dFechaFinalMes2 date;
	DEFINE dFechaFinalMes3 date;
	DEFINE dFechaInicialMes1 date;
	DEFINE dFechaInicialMes2 date;
	DEFINE dFechaInicialMes3 date;
	DEFINE vCobraComision char(2);
	DEFINE dFechaHoy date;
	--DEFINE iProductosInversion int;
	--DEFINE iProductosPagare int;
	DEFINE mSaldoProm money(16,2);
	DEFINE mMontoAcum money(16,2);
	DEFINE vSucursal CHAR(4);
	DEFINE iDiasIntegracion int;
	DEFINE iCommit INTEGER;
	DEFINE vContador1 INTEGER;
    DEFINE vContador2 INTEGER;
	DEFINE vComienza SMALLINT;
	DEFINE vAbierto CHAR(1);
	DEFINE mSaldoAcumulado MONEY(16,2);
	DEFINE iDiasConMov INTEGER;
	DEFINE cAnioMes1 char(6);
	DEFINE cAnioMes2 char(6);
	DEFINE cAnioMes3 char(6);
	DEFINE v_fecha_movhis DATE;
	--DEFINE mSaldoInvPagare MONEY(16,2);
	DEFINE vDias VARCHAR(30);
	DEFINE dPrimerDiaMes DATE;
	DEFINE mMontoIVA MONEY(16,2);
	DEFINE mMontoCom MONEY(16,2);
	DEFINE mComisionTotal MONEY(16,2);
	DEFINE vValorIva DECIMAL(16,2);
	DEFINE dFechaAyer DATE; 
	DEFINE mSaldoAcomDisp0273 money(16,2);
	DEFINE mSaldoAcomPen0273 money(16,2);
	--Fechas donde consultara las quincenas
	DEFINE dFechaIniM1Quin date;
	DEFINE dFechaIniM1Quin2 date;
	DEFINE dFechaFinM1Quin date;
	DEFINE dFechaFinM1Quin2 date;
	
	DEFINE dFechaIniM2Quin date;
	DEFINE dFechaIniM2Quin2 date;
	DEFINE dFechaFinM2Quin date;
	DEFINE dFechaFinM2Quin2 date;
	
	DEFINE dFechaIniM3Quin date;
	DEFINE dFechaIniM3Quin2 date;
	DEFINE dFechaFinM3Quin date;
	DEFINE dFechaFinM3Quin2 date;
	
	DEFINE v_ret1        CHAR(5);
    DEFINE v_ret2        CHAR(20);
    DEFINE v_ret3        CHAR(20);
    DEFINE v_ret4        CHAR(26);
    DEFINE v_ret5        CHAR(26);
    DEFINE v_ret6        CHAR(26);
    DEFINE v_ret7        CHAR(26);
    DEFINE v_ret8        CHAR(60);
    DEFINE v_ret9        CHAR(1);
    DEFINE v_ret10       MONEY(14,2);
    DEFINE v_ret11       MONEY(14,2);
    DEFINE v_ret12       MONEY(14,2);
    DEFINE v_ret13       MONEY(14,2);
    DEFINE v_ret14       MONEY(14,2);
    DEFINE v_ret15       CHAR(1);
    DEFINE v_ret16       CHAR(40);
    DEFINE v_ret17       CHAR(40); 
    DEFINE v_ret18       MONEY(14,2);
	DEFINE v_ret19       MONEY(14,2);
	DEFINE v_ret20       MONEY(14,2);
	DEFINE v_ret21       CHAR(8);
	DEFINE v_ret22       DATE;
	DEFINE v_ret23       CHAR(16);
	DEFINE v_ret24       CHAR(18);
	DEFINE iMovQuinMovhis  MONEY(14,2);
	DEFINE iMovQuinMovhis2 MONEY(14,2);
	DEFINE mSaldoAcum273Sdw money(16,2);
	
	

	LET vCodRet = '00000';
	LET vCliente = '';
	LET vCuenta = '';
	LET vSucursal = '';
	LET iCuentaInactiva = 0;
	LET iMovimientos = 0;
	LET mSaldoPromMes1 = 0;
	LET mSaldoPromMes2 = 0;
	LET mSaldoPromMes3 = 0;
	--LET iProductosInversion = 0;
	Let mSaldoAcomDisp = 0;
	Let mSaldoAcomDispOld =0;
	--LET iProductosPagare = 0;
	
	LET iCommit = 1000;
	LET vContador1 = 0;
    LET vContador2 = 0;
    LET vComienza = -1;
    LET vAbierto = '0';
	LET mSaldoAcumulado = 0;
	LET iDiasConMov = 0;
	
	LET v_ret1         = "";
	LET v_ret2         = '';
	LET v_ret3         = '';
	LET v_ret4         ='';
	LET v_ret5         = '';
	LET v_ret6         = '';
	LET v_ret7         = '';
	LET v_ret8         = '';
	LET v_ret9         = '';
	LET v_ret10        = 0 ;
	LET v_ret11        = 0 ;
	LET v_ret12        = 0 ;
	LET v_ret13        = 0 ;
	LET v_ret14        = 0 ;
	LET v_ret15        = " ";
	LET v_ret16        = '';
	LET v_ret17        = "";
	LET v_ret18        = 0 ;
	LET v_ret19        = 0 ;
	LET v_ret20        = 0;
	LET v_ret21        = " ";
	LET v_ret22        = "";
	LET v_ret23        = '';
	LET v_ret24        = "";
	LET mSaldoAcomDisp0273 = 0;
	LET mSaldoAcomPen0273  = 0;
	LET mSaldoAcomuladoPorta = 0;
	LET mSaldoAcomuladoEmp = 0;
	LET iMovQuinMovhis = 0;
	LET iMovQuinMovhis2 = 0;
	LET mSaldoAcum273Sdw = 0;
	BEGIN
		ON EXCEPTION SET cSQL_ERR, cISAM_ERR, cDESC_ERR
			LET vCodret  = cSQL_ERR;
			LET vCodRet2 = cISAM_ERR;
			LET vCodRet3 = cDESC_ERR;
			--SET DEBUG FILE TO '/sql-scripts/sp_procesa_ctas_com_prod2100.err';
		    --TRACE ON;
			IF vAbierto = '1' THEN
				ROLLBACK WORK;
			END IF;
			RETURN vCodRet;
		END EXCEPTION;
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		--SET DEBUG FILE TO '/sql-scripts/sp_procesa_ctas_com_prod2100.out';
		--TRACE ON;
		
		--Consulta los dias que debe tener de integracion o de alta la cuenta para poder ser tomada en cuenta en el proceso
		SELECT valor 
		into iDiasIntegracion 
		FROM bdicheq:sc_param 
		WHERE codparam = 'INTEGRACION_PROCESO' and empresa = pEmpresa;
		
		--Consulta la fecha actual
		SELECT fecha_hoy 
		INTO dFechaHoy 
		FROM bdicheq:sc_fechas 
		where empresa = pEmpresa;
		
		--Consulta el primer dÃ­a del mes
		SELECT pri_dia_mes 
		INTO dPrimerDiaMes 
		FROM bdicheq:sc_fechas 
		where empresa = pEmpresa;
		
		--Consulta la fecha de ayer
		SELECT fecha_ant 
		INTO dFechaAyer 
		FROM bdicheq:sc_fechas 
		where empresa = pEmpresa;
				
		--Saldo promedio mensual
		SELECT valor  
		INTO   mSaldoProm
		FROM   bdicheq:sc_param 
		WHERE  codparam = 'sdoprom_2100' and empresa = pEmpresa;
		
		--Saldo minimo en pagare e inversion
		--SELECT valor  
		--INTO   mSaldoInvPagare
		--FROM   bdicheq:sc_param 
		--WHERE  codparam = 'montoinvpag_2100' and empresa = pEmpresa;
		
		--Monto acumulado mensual
		SELECT valor  
		into mMontoAcum
		FROM   bdicheq:sc_param 
		WHERE  codparam = 'montoacum_2100' and empresa = pEmpresa;
		
		
		SELECT valor
		INTO   v_fecha_movhis
		FROM   bdicheq:sc_param 
		WHERE  codparam = 'fechcon_movhis';
		
		--Monto de la comision para cuenta del producto 2100
		SELECT valor  
		INTO   mMontoCom
		FROM   bdicheq:sc_param 
		WHERE  codparam = 'montocom2100' and empresa = pEmpresa;
		
		--Valor del iva
		SELECT valor 
		INTO   vValorIva 
		FROM   bdinteg:si_param
		WHERE  empresa = pEmpresa
		AND    cod_param = 47;
		--Monto acumulado para suma de acumulado mensual sin filtrar por conceptos los dias de quincena 13 al 15 y ultimos 4 dias del mes
		SELECT 	NVL(valor,3000)
		INTO mSaldoAcum273Sdw
		FROM   bdicheq:sc_param 
		WHERE  codparam = 'montoAcum2100sdw' and empresa = pEmpresa;
		
		
		--Fechas iniciales y finales para validar sumatoria de movimientos y portabilidad
		LET dFechaInicialMes1 = DATE(dPrimerDiaMes - 1 UNITS MONTH);
		LET dFechaInicialMes2 = DATE(dPrimerDiaMes - 2 UNITS MONTH);
		LET dFechaInicialMes3 = DATE(dPrimerDiaMes - 3 UNITS MONTH);
		LET dFechaFinalMes1 = LAST_DAY(dFechaHoy -1 UNITS MONTH);
		LET dFechaFinalMes2 = LAST_DAY(dFechaHoy -2 UNITS MONTH);
		LET dFechaFinalMes3 = LAST_DAY(dFechaHoy -3 UNITS MONTH);
		--Fechas de rangos donde se consultara las quincenas los dias 13-16,28-31 del mes 1
		LET dFechaIniM1Quin = MDY(MONTH(dPrimerDiaMes - 1 UNITS MONTH),13,YEAR(dPrimerDiaMes - 1 UNITS MONTH));
		LET dFechaIniM1Quin2 =LAST_DAY(dFechaHoy -1 UNITS MONTH) - 3 units day;
	    LET dFechaFinM1Quin = MDY(MONTH(dPrimerDiaMes - 1 UNITS MONTH),15,YEAR(dPrimerDiaMes - 1 UNITS MONTH));
	    LET dFechaFinM1Quin2 =LAST_DAY(dFechaHoy -1 UNITS MONTH);
		--Fechas de rangos donde se consultara las quincenas los dias 13-16,28-31 del mes 2
		LET dFechaIniM2Quin = MDY(MONTH(dPrimerDiaMes - 2 UNITS MONTH),13,YEAR(dPrimerDiaMes - 2 UNITS MONTH));
		LET dFechaIniM2Quin2 =LAST_DAY(dFechaHoy -2 UNITS MONTH) - 3 units day;
	    LET dFechaFinM2Quin = MDY(MONTH(dPrimerDiaMes - 2 UNITS MONTH),15,YEAR(dPrimerDiaMes - 2 UNITS MONTH));
	    LET dFechaFinM2Quin2 =LAST_DAY(dFechaHoy -2 UNITS MONTH);
		--Fechas de rangos donde se consultara las quincenas los dias 13-16,28-31 del mes 3
		LET dFechaIniM3Quin = MDY(MONTH(dPrimerDiaMes - 3 UNITS MONTH),13,YEAR(dPrimerDiaMes - 3 UNITS MONTH));
		LET dFechaIniM3Quin2 =LAST_DAY(dFechaHoy -3 UNITS MONTH) - 3 units day;
	    LET dFechaFinM3Quin = MDY(MONTH(dPrimerDiaMes - 3 UNITS MONTH),15,YEAR(dPrimerDiaMes - 3 UNITS MONTH));
	    LET dFechaFinM3Quin2 =LAST_DAY(dFechaHoy -3 UNITS MONTH);
		
		
		--Fecha para tomar en cuenta las cuentas, la alta o creacion de la cuenta debe ser menor a hoy menos los dias de integracion(90)
		LET dFechaInicio = DATE(dFechaHoy - iDiasIntegracion UNITS DAY);
		
		--Fechas para saldo promedio en sc_maehis
		LET cAnioMes1 = YEAR(dFechaFinalMes1)||lpad(month(dFechaFinalMes1),2,"0");
		LET cAnioMes2 = YEAR(dFechaFinalMes2)||lpad(month(dFechaFinalMes2),2,"0");
		LET cAnioMes3 = YEAR(dFechaFinalMes3)||lpad(month(dFechaFinalMes3),2,"0");
		
		--Se calcula IVA y monto total de comision
		LET mMontoIVA = (mMontoCom * vValorIva);
		LET mComisionTotal = mMontoCom + mMontoIVA;
		
		FOREACH WITH HOLD
			SELECT a.num_cte, a.cuenta, a.sucursal 
			INTO   vCliente, vCuenta,  vSucursal
			FROM   bdicheq:sc_maechq AS a,
				   bdicheq:sc_maenoc AS b, 
				   bdicheq:sc_maehis AS c
			WHERE  a.cuenta     = b.cuenta 
			AND    a.cuenta     = c.cuenta
			AND    a.status_cta = "1"
			AND    a.producto   = "2100"
			AND    b.fecha_alta < dFechaInicio
			AND    c.fechafin = dFechaAyer
			AND a.cuenta NOT IN(select cuenta FROM bdicheq:sc_cuentas_procesar2100 where cuenta = a.cuenta)
			
			IF vComienza = -1 THEN
				LET vComienza = 0;
				BEGIN WORK;
				LET vAbierto = '1';
			END IF;
			--Limpiamos las variables despues de cada iteracion
			LET mSaldoAcomDispOld = 0;
			LET mSaldoAcomDisp = 0;
			LET mSaldoAcomulado1 = 0;
			LET mSaldoAcomuladoOld = 0;
			LET mSaldoAcomulado2 = 0;
			LET mSaldoAcomulado3 = 0;
			lET mSaldoAcumulado = 0;
			LET iDiasConMov = 0;
			LET mSaldoPromMes1 = 0;
			LET mSaldoPromMes2 = 0;
	        LET mSaldoPromMes3 = 0;
			LET mSaldoAcomDisp0273 = 0;
	        LET mSaldoAcomPen0273  = 0;
			LET mSaldoAcomuladoPorta = 0;
			LET mSaldoAcomuladoEmp = 0;
			LET iMovQuinMovhis = 0;
	        LET iMovQuinMovhis2 = 0;
			
			--Si la cuenta no cuenta con saldo suficiente para el cobro se descarta
			EXECUTE PROCEDURE cons_sdos1(pEmpresa,vCuenta,'')
			INTO v_ret1,v_ret2,v_ret3,v_ret4,v_ret5,v_ret6,v_ret7,v_ret8,v_ret9,v_ret10,v_ret11,v_ret12,v_ret13,v_ret14,v_ret15,v_ret16,v_ret17,v_ret18,v_ret19,v_ret20,v_ret21,v_ret22,v_ret23,v_ret24; 
			IF v_ret10 < mComisionTotal THEN
				CONTINUE FOREACH;
			END IF;
			
			--Si la cuenta esta considerada en el cobro comision por inectividad se descarta.
			SELECT count(cuenta) INTO iCuentaInactiva FROM bdicheq:sc_ctasinact_cobro_comision WHERE cuenta = vCuenta;
			IF iCuentaInactiva > 0 THEN
				CONTINUE FOREACH;
			END IF;
			
			--CONSULTA MOVIMIENTOS DE LA TRANSACCION 0273 PARA:
			--Pensionados
			--Ingresos con concepto de nomina que incluye los conceptos de NOMINA o SUELDO
			--portabilidad
			--Empleados nomina coppel y bancoppel(0293,0287)
			SELECT nvl(sum(ingresos_pen),0),nvl(sum(ingresos_sdw),0),nvl(sum(ingresos_porta),0),nvl(sum(ingresos_emp),0) 
			INTO mSaldoAcomPen0273,mSaldoAcomDisp0273,mSaldoAcomuladoPorta,mSaldoAcomuladoEmp FROM bdicheq:sc_nom_disp_cte 
			where cuenta = vCuenta and fecha_pago BETWEEN dFechaInicialMes3 and dFechaFinalMes1;
			--En caso de tener saldo > 0 se descarta para cobro de comision
			IF mSaldoAcomPen0273 > 0 OR mSaldoAcomDisp0273 > 0 or mSaldoAcomuladoPorta > 0 or mSaldoAcomuladoEmp >0 then
			    CONTINUE FOREACH;
			END IF;
			
			--Consulta si tiene dispersion de nomina en alguno de los 3 meses anteriores
			IF dFechaInicialMes3 >= v_fecha_movhis THEN
			    SELECT nvl(sum(monto_tot),0) into mSaldoAcomDisp FROM bdicheq:sc_movhis 
				WHERE transacc in (select numero FROM bdicheq:sc_productos_notificacion where empresa="001" and numero is not null 
				and tipo_trans = 2)
				and cuenta = vCuenta and fech_alt between dFechaInicialMes3 and dFechaFinalMes1;
			ELSE
			    SELECT nvl(sum(monto_tot),0) into mSaldoAcomDisp FROM bdicheq:sc_movhis 
				WHERE transacc in (select numero FROM bdicheq:sc_productos_notificacion where empresa="001" and numero is not null 
				and tipo_trans = 2)
				and cuenta = vCuenta and fech_alt between dFechaInicialMes3 and dFechaFinalMes1;
				
				SELECT nvl(sum(monto_tot),0) into mSaldoAcomDispOld FROM bdicheq:sc_movhis_old 
				WHERE transacc in (select numero FROM bdicheq:sc_productos_notificacion where empresa="001" and numero is not null 
				and tipo_trans = 2)
				and cuenta = vCuenta and fech_alt between dFechaInicialMes3 and dFechaFinalMes1;
			END IF;
			
			IF (mSaldoAcomDisp + mSaldoAcomDispOld) > 0 then
			    CONTINUE FOREACH;
			END IF;
			
			--FILTRO 2 NOMINA 0273 - CONSULTA POR TRANSACCION 0273 LOS DIAS DE QUINCENA 13-16,ultimos 4 dias del mes, MES 1
			--EN CASO DE TENER UN ACUMULADO >=3000 SE DESCARTA PARA COBRO DE COMISON
			IF dFechaIniM1Quin >= v_fecha_movhis THEN
			    SELECT nvl(sum(monto_tot),0) into iMovQuinMovhis FROM bdicheq:sc_movhis WHERE transacc = '0273'
				and cuenta = vCuenta and (fech_alt between dFechaIniM1Quin and dFechaFinM1Quin or fech_alt between dFechaIniM1Quin2 and dFechaFinM1Quin2);
			ELSE
			    SELECT nvl(sum(monto_tot),0) into iMovQuinMovhis2 FROM bdicheq:sc_movhis WHERE transacc = '0273'
				and cuenta = vCuenta and (fech_alt between dFechaIniM1Quin and dFechaFinM1Quin or fech_alt between dFechaIniM1Quin2 and dFechaFinM1Quin2);
				
				SELECT nvl(sum(monto_tot),0) into iMovQuinMovhis FROM bdicheq:sc_movhis_old WHERE transacc = '0273'
				and cuenta = vCuenta and(fech_alt between dFechaIniM1Quin and dFechaFinM1Quin or fech_alt between dFechaIniM1Quin2 and dFechaFinM1Quin2);
			END IF;
			   
			   IF (iMovQuinMovhis + iMovQuinMovhis2) >= mSaldoAcum273Sdw then
			        CONTINUE FOREACH;
			    END IF;
			    LET iMovQuinMovhis = 0;
			    LET iMovQuinMovhis2 = 0;
				
		--MES 2 FILTRO 2
			IF dFechaIniM2Quin >= v_fecha_movhis THEN
			    SELECT nvl(sum(monto_tot),0) into iMovQuinMovhis FROM bdicheq:sc_movhis WHERE transacc = '0273'
				and cuenta = vCuenta and (fech_alt between dFechaIniM2Quin and dFechaFinM2Quin or fech_alt between dFechaIniM2Quin2 and dFechaFinM2Quin2);
			ELSE
			    SELECT nvl(sum(monto_tot),0) into iMovQuinMovhis2 FROM bdicheq:sc_movhis WHERE transacc = '0273'
				and cuenta = vCuenta and (fech_alt between dFechaIniM2Quin and dFechaFinM2Quin or fech_alt between dFechaIniM2Quin2 and dFechaFinM2Quin2);
				
				SELECT nvl(sum(monto_tot),0) into iMovQuinMovhis FROM bdicheq:sc_movhis_old WHERE transacc = '0273'
				and cuenta = vCuenta and (fech_alt between dFechaIniM2Quin and dFechaFinM2Quin or fech_alt between dFechaIniM2Quin2 and dFechaFinM2Quin2);
			END IF;
			    IF (iMovQuinMovhis + iMovQuinMovhis2) >= mSaldoAcum273Sdw then
			        CONTINUE FOREACH;
			    END IF;
			    LET iMovQuinMovhis = 0;
			    LET iMovQuinMovhis2 = 0;
				
		--MES 3 FILTRO 2
			IF dFechaIniM3Quin >= v_fecha_movhis THEN
			    SELECT nvl(sum(monto_tot),0) into iMovQuinMovhis FROM bdicheq:sc_movhis WHERE transacc = '0273'
				and cuenta = vCuenta and (fech_alt between dFechaIniM3Quin and dFechaFinM3Quin or fech_alt between dFechaIniM3Quin2 and dFechaFinM3Quin2);
			ELSE
			    SELECT nvl(sum(monto_tot),0) into iMovQuinMovhis2 FROM bdicheq:sc_movhis WHERE transacc = '0273'
				and cuenta = vCuenta and (fech_alt between dFechaIniM3Quin and dFechaFinM3Quin or fech_alt between dFechaIniM3Quin2 and dFechaFinM3Quin2);
				
				SELECT nvl(sum(monto_tot),0) into iMovQuinMovhis FROM bdicheq:sc_movhis_old WHERE transacc = '0273'
				and cuenta = vCuenta and(fech_alt between dFechaIniM3Quin and dFechaFinM3Quin or fech_alt between dFechaIniM3Quin2 and dFechaFinM3Quin2);
			END IF;
			
			    IF (iMovQuinMovhis + iMovQuinMovhis2) >= mSaldoAcum273Sdw then
			        CONTINUE FOREACH;
			    END IF;
			    LET iMovQuinMovhis = 0;
			    LET iMovQuinMovhis2 = 0;
			
			--Consulta la sumatoria de los movimientos validos de los 3 meses anteriores para remesas
			IF dFechaInicialMes1 >= v_fecha_movhis THEN
				SELECT nvl(sum(monto_tot),0) into mSaldoAcomulado1 FROM bdicheq:sc_movhis 
				WHERE transacc in (select numero FROM bdicheq:sc_productos_notificacion where empresa="001" and numero is not null and tipo_trans <> 2) 
				and cuenta = vCuenta and fech_alt between dFechaInicialMes1 and dFechaFinalMes1;
			ELSE
				SELECT nvl(sum(monto_tot),0) into mSaldoAcomulado1 FROM bdicheq:sc_movhis 
				WHERE transacc in (select numero FROM bdicheq:sc_productos_notificacion where empresa="001" and numero is not null and tipo_trans <> 2) 
				and cuenta = vCuenta and fech_alt between dFechaInicialMes1 and dFechaFinalMes1;
				
				SELECT nvl(sum(monto_tot),0) into mSaldoAcomuladoOld FROM bdicheq:sc_movhis_old 
				WHERE transacc in (select numero FROM bdicheq:sc_productos_notificacion where empresa="001" and numero is not null and tipo_trans <> 2) 
				and cuenta = vCuenta and fech_alt between dFechaInicialMes1 and dFechaFinalMes1;
				LET mSaldoAcomulado1 = mSaldoAcomulado1 + mSaldoAcomuladoOld;
				LET mSaldoAcomuladoOld = 0;
			END IF
			--si el monto acumulado es igual o mayor al establecido continua con el siguiente registro
			IF mSaldoAcomulado1 >= mMontoAcum THEN
				CONTINUE FOREACH;
			END IF;
			
			IF dFechaInicialMes2 >= v_fecha_movhis THEN
				SELECT nvl(sum(monto_tot),0) into mSaldoAcomulado2 FROM bdicheq:sc_movhis 
				WHERE transacc in (SELECT numero FROM bdicheq:sc_productos_notificacion where empresa="001" and numero is not null and tipo_trans <> 2)
				and cuenta = vCuenta and fech_alt between dFechaInicialMes2 and dFechaFinalMes2;
			ELSE
				SELECT nvl(sum(monto_tot),0) into mSaldoAcomulado2 FROM bdicheq:sc_movhis 
				WHERE transacc in (SELECT numero FROM bdicheq:sc_productos_notificacion where empresa="001" and numero is not null and tipo_trans <> 2)
				and cuenta = vCuenta and fech_alt between dFechaInicialMes2 and dFechaFinalMes2;
				
				SELECT nvl(sum(monto_tot),0) into mSaldoAcomuladoOld FROM bdicheq:sc_movhis_old 
				WHERE transacc in (SELECT numero FROM bdicheq:sc_productos_notificacion where empresa="001" and numero is not null and tipo_trans <> 2)
				and cuenta = vCuenta and fech_alt between dFechaInicialMes2 and dFechaFinalMes2;
				LET mSaldoAcomulado2 = mSaldoAcomulado2 + mSaldoAcomuladoOld;
				LET mSaldoAcomuladoOld = 0;
			END IF;
			--si el monto acumulado es igual o mayor al establecido continua con el siguiente registro
			IF mSaldoAcomulado2 >= mMontoAcum THEN
				CONTINUE FOREACH;
			END IF;
			IF dFechaInicialMes3 >= v_fecha_movhis THEN
				SELECT nvl(sum(monto_tot),0) into mSaldoAcomulado3 FROM bdicheq:sc_movhis 
				WHERE transacc in (select numero FROM bdicheq:sc_productos_notificacion where empresa="001" and numero is not null and tipo_trans <> 2)
				and cuenta = vCuenta and fech_alt between dFechaInicialMes3 and dFechaFinalMes3;
			ELSE
				SELECT nvl(sum(monto_tot),0) into mSaldoAcomulado3 FROM bdicheq:sc_movhis 
				WHERE transacc in (select numero FROM bdicheq:sc_productos_notificacion where empresa="001" and numero is not null and tipo_trans <> 2)
				and cuenta = vCuenta and fech_alt between dFechaInicialMes3 and dFechaFinalMes3;
				
				SELECT nvl(sum(monto_tot),0) into mSaldoAcomuladoOld FROM bdicheq:sc_movhis_old 
				WHERE transacc in (select numero FROM bdicheq:sc_productos_notificacion where empresa="001" and numero is not null and tipo_trans <> 2)
				and cuenta = vCuenta and fech_alt between dFechaInicialMes3 and dFechaFinalMes3;
				LET mSaldoAcomulado3 = mSaldoAcomulado3 + mSaldoAcomuladoOld;
				LET mSaldoAcomuladoOld = 0;
			END IF;
			--si el monto acumulado es igual o mayor al establecido continua con el siguiente registro
			IF mSaldoAcomulado3 >= mMontoAcum THEN
				CONTINUE FOREACH;
			END IF;
			
			--Consulta el saldo promedio mensual de los ulimos 3 meses
			SELECT NVL(acum_sdo_pos,0),NVL(dia_sdo_pos,0) into mSaldoAcumulado, iDiasConMov  from bdicheq:sc_maehis
			WHERE aniomes = cAnioMes1 and cuenta = vCuenta;
			IF iDiasConMov <> 0 THEN
				LET mSaldoPromMes1 = mSaldoAcumulado / iDiasConMov;
			ELSE
				LET mSaldoPromMes1 = 0;
			END IF;
			
			SELECT NVL(acum_sdo_pos,0),NVL(dia_sdo_pos,0) into mSaldoAcumulado, iDiasConMov  from bdicheq:sc_maehis
			WHERE aniomes = cAnioMes2 and cuenta = vCuenta;
			IF iDiasConMov <> 0 THEN
				LET mSaldoPromMes2 = mSaldoAcumulado / iDiasConMov;
			ELSE
				LET mSaldoPromMes2 = 0;
			END IF;  
			
			SELECT NVL(acum_sdo_pos,0),NVL(dia_sdo_pos,0) into mSaldoAcumulado, iDiasConMov  from bdicheq:sc_maehis
			WHERE aniomes = cAnioMes3 and cuenta = vCuenta;
			IF iDiasConMov <> 0 THEN
				LET mSaldoPromMes3 = mSaldoAcumulado / iDiasConMov;
			ELSE
				LET mSaldoPromMes3 = 0;
			END IF;
			
			IF mSaldoPromMes1 >= mSaldoProm or mSaldoPromMes2 >= mSaldoProm or mSaldoPromMes3 >= mSaldoProm THEN
				CONTINUE FOREACH;
			END IF;
			
			--Consulta si el cliente tiene por lo menos un producto de inversion activo con saldo minimo de 1500
			--SELECT count(*) INTO iProductosInversion 
			--FROM bdicheq:sc_maechq 
			--WHERE producto = '1100' AND num_cte  = vCliente AND status_cta = '1' and sdo_actual >= mSaldoInvPagare;
			--IF iProductosInversion > 0 THEN
				--CONTINUE FOREACH;
			--END IF;
			
			--Consulta si el cliente tiene por lo menos un producto de pagare activo con saldo minimo de 1500
			--SELECT count(*) INTO iProductosPagare 
			--FROM bdinvers:sv_maeinv 
			--WHERE cod_instrum = '3000' AND num_cte = vCliente AND    status_cta  = '1' and capital >= mSaldoInvPagare; 
			--IF iProductosPagare > 0 THEN
			--	CONTINUE FOREACH;
			--END IF;
			INSERT INTO sc_cuentas_procesar2100 VALUES(vCuenta,vSucursal,dFechaHoy);
			LET vcontador1 = vcontador1 + 1;
			LET vcontador2 = vcontador2 + 1;
			
			IF vcontador2 >= iCommit THEN
				LET vcontador2 = 0;
				COMMIT WORK;
				BEGIN WORK;
			END IF;
		END FOREACH;
		
		IF vAbierto = '1' THEN
			COMMIT WORK;
			LET vAbierto = '0';
		END IF;
		RETURN  vCodRet;
	END; 
END PROCEDURE
DOCUMENT
'DESCRIPCION: Filtra las cuentas del producto 2100 para poder realizar el cobro de comisiÃ³n por manejo de cuenta,',
'descartando las que no cuenten con portabilidad de nÃ³mina, la sumatoria de movimientos validos, saldo promedio mensual',
'en los ultimos 3 meses, que se encuentre en las cuentas consideradas en el cobro por inactividad y que no cuenten con  ',
'saldo suficiente para el cobro de la comisiÃ³n, las cuentas que no cumplan con alguno de estos requicitos serÃ¡n guardadas',
'en la tabla sc_cuentas_procesar2100',
'PETICION: Iniciativa Cuenta Nomina',
'AUTOR: 99805418 - Jose Zetina',
'FECHA DE CREACION: 17/09/2024',
'FECHA MODIFICACION: 14/02/2025',
'BD: bdicheq',
'_____________________________________________________________________________________________________________________________________',
'MODIFICADO: 	Jose Mauricio Ramirez Zamudio',
'FECHA: 		11 de Febrero de 2026',
'Peticion: Mariana Reyes, Bruno Bernabe',
'DESCRIPCION: - Se modifica consulta a la tabla sc_productos_notificacion para filtrar tipo_trans donde 1 es para remesas y 2 para transaccion de nomina',
    ',se consultan  movimientos de pensionados,portabilidad, nomina empleados coppel y bancopel de la tabla sc_nom_disp_cte',
	'se quita la consulta de portabilidad a la tabla sc_movhis y se hace ahora a la tabla sc_nom_disp_cte directamente,se agregan cambios',
    ' para consultar los dias de quincena por transaccion 0273 en la tabla sc_movhis para tratar de abarcar movimientos de nomina',
    'los dias 13-18 del mes y 28-31 del mes como segunda opcion en caso de no ser viable consultar el campo ingresos_sdw de la tabla sc_nom_disp_cte',
    ', se quita validacion para en caso de tener alguna cuenta de inversion o pagare pueda ser descartado de cobro de comision';

CREATE PROCEDURE "informix".sp_cap_cancelacta_masiva(pUsuario CHAR(8), pIdFuncion CHAR(10), pTrama LVARCHAR)
	RETURNING CHAR(5) AS codret, INTEGER AS total_canceladas, INTEGER AS total_no_canceladas;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	
	DEFINE v_PosPipe INT;
	DEFINE v_FechaHoy DATE;
	DEFINE v_Sucursal CHAR(4);
	DEFINE v_TipoSucursal CHAR(1);
	DEFINE v_ClavePagoProgramado CHAR(20);
	DEFINE v_Contador INTEGER;
	DEFINE v_Dec CHAR(5);
	DEFINE v_FolioCancelacion  VARCHAR(40);
	DEFINE v_Year              CHAR(4);
	DEFINE v_Month             CHAR(2);
	DEFINE v_Day               CHAR(2);
	DEFINE v_Hour              CHAR(2);
	DEFINE v_Minute            CHAR(2);
	DEFINE v_Second            CHAR(2);
	DEFINE v_PromotorPadded    CHAR(8); 
	DEFINE v_RespuestaProcesoCanc BOOLEAN;
	DEFINE v_CodRetProceso 		CHAR(5);
	
	DEFINE v_TramaRestante VARCHAR(100); 
	DEFINE v_ParCompleto   VARCHAR(40);
	DEFINE i INTEGER;
	DEFINE v_Char CHAR(1);
	DEFINE v_PosSeparador INTEGER; 
	DEFINE v_ContadorCuentasCanc INTEGER;
	DEFINE v_ContadorCuentasNoCanc INTEGER;
	DEFINE v_FechaActual DATETIME YEAR TO SECOND;
	DEFINE v_FechaNueva DATETIME YEAR TO SECOND;
	DEFINE v_Intervalo INTERVAL SECOND TO SECOND;	
	DEFINE v_PosPipe1 INTEGER;
	DEFINE v_PosPipe2 INTEGER;
	DEFINE v_Cliente CHAR(20);
	DEFINE v_Cuenta CHAR(20);
	
	LET cCodRet = '00000';
	LET v_RespuestaProcesoCanc = 'f';
	LET iSqlErr = 0;
	LET v_Cuenta = '';
	LET v_Cliente = '';
	LET v_PosPipe = 0;
	LET v_FechaHoy = TODAY;
	LET v_Sucursal = '';
	LET v_TipoSucursal = '';
	LET v_ClavePagoProgramado = '';
	LET v_Contador = 0;
	LET v_Dec = '';
	LET v_Year = YEAR(TODAY);    
	LET v_ContadorCuentasCanc = 0;
	LET v_ContadorCuentasNoCanc = 0;
	LET v_CodRetProceso = '00000';
	LET v_FechaActual = CURRENT;
	LET v_FechaNueva = CURRENT;
	LET v_Second = '';
	-- InicializaciÃ³n y limpieza
	LET v_TramaRestante = TRIM(pTrama); 
	LET i = 1;

	BEGIN
		
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
		RETURN cCodRet, v_ContadorCuentasCanc, v_ContadorCuentasNoCanc;

		END EXCEPTION;
		DROP TABLE IF EXISTS temp_cuentas;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/vero/cancelacion/sp_cap_cancelacta_masiva.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pTrama = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, v_ContadorCuentasCanc, v_ContadorCuentasNoCanc;
		END IF;		
		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, v_ContadorCuentasCanc, v_ContadorCuentasNoCanc;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		CREATE TEMP TABLE temp_cuentas (
			cuenta    CHAR(20),
			cliente   CHAR(20)
		) WITH NO LOG;
	
		LET v_TramaRestante = TRIM(pTrama); 
		LET i = 1;

		WHILE LENGTH(v_TramaRestante) > 0

			SELECT INSTR(v_TramaRestante, '|') INTO v_PosPipe1 FROM systables WHERE tabid = 1;

			IF v_PosPipe1 = 0 THEN
				LET v_TramaRestante = '';
				EXIT WHILE;
			END IF;

			LET v_Cliente = SUBSTR(v_TramaRestante, 1, v_PosPipe1 - 1);

			SELECT 
				INSTR(SUBSTR(v_TramaRestante, v_PosPipe1 + 1), '|') 
			INTO 
				v_PosPipe2 
			FROM systables 
			WHERE tabid = 1;

			IF v_PosPipe2 = 0 THEN
				LET v_Cuenta = SUBSTR(v_TramaRestante, v_PosPipe1 + 1); 
				
				INSERT INTO temp_cuentas (cliente, cuenta) VALUES (TRIM(v_Cliente), TRIM(v_Cuenta));
				
				LET v_TramaRestante = '';
			ELSE
				LET v_Cuenta = SUBSTR(v_TramaRestante, v_PosPipe1 + 1, v_PosPipe2 - 1);
				INSERT INTO temp_cuentas (cliente, cuenta) VALUES (TRIM(v_Cliente), TRIM(v_Cuenta));
				LET v_TramaRestante = SUBSTR(v_TramaRestante, v_PosPipe1 + v_PosPipe2 + 1);
			END IF;
		END WHILE
		
		
		FOREACH
			SELECT * INTO v_Cuenta, v_Cliente 
			FROM temp_cuentas
			EXECUTE PROCEDURE bdicnweb:sp_valida_cuentacan(pUsuario, pIdFuncion, v_Cuenta) 
			INTO v_CodRetProceso, v_RespuestaProcesoCanc;
			
			IF v_RespuestaProcesoCanc = 't' THEN
				UPDATE bdicheq:sc_maechq 
				SET status_cta = '2', motivo = '15', fec_cancelac = v_FechaHoy 
				WHERE cuenta = v_Cuenta;
				
				UPDATE bdicheq:sc_contch 
				SET estado = 'C' 
				WHERE cuenta = v_Cuenta AND estado = 'A';
				
				SELECT sucursal 
				INTO v_Sucursal 
				FROM bdinteg:si_cliente 
				WHERE numcte = v_Cliente;
				
				SELECT tpo_sucursal 
				INTO v_TipoSucursal
				FROM bdinteg:si_sucursales 
				WHERE sucursal = v_Sucursal;
				
				FOREACH
					SELECT cve_pagoprog 
					INTO v_ClavePagoProgramado 
					FROM bdiprog:pp_pagoprog 
					WHERE num_cte=v_Cliente AND cuenta_origen = v_Cuenta AND cve_estado = '01'
					
					LET v_Contador = v_Contador + 1;
				END FOREACH;
				
				IF v_Contador>0 THEN
					LET v_Contador = 0;
					FOREACH
						SELECT DECODE(v_TipoSucursal, 'S', '01', 'N', '02', '')
						INTO v_Dec
						FROM bdinteg:si_sucursales
						WHERE sucursal = v_Sucursal
						LET v_Contador = v_Contador + 1;
					END FOREACH;
					IF v_Contador>0 THEN
						EXECUTE PROCEDURE bdiprog:sp_cancelaprogramacion ('02', v_Cliente, v_Dec, v_ClavePagoProgramado, 0, pUsuario);
						LET v_PromotorPadded = LPAD(pUsuario, 8, '0');
						LET v_FolioCancelacion = v_PromotorPadded || v_Year || v_Month || v_Day || v_Hour || v_Minute || v_Second;
					END IF;					
				END IF;
				
				LET v_FechaNueva = v_FechaActual + INTERVAL (1) SECOND TO SECOND;
				LET v_FechaActual = v_FechaNueva;
				LET v_Year = TO_CHAR(v_FechaNueva, '%Y');
				LET v_Month = TO_CHAR(v_FechaNueva, '%m');
				LET v_Day =	TO_CHAR(v_FechaNueva, '%d');
				LET v_Hour = TO_CHAR(v_FechaNueva, '%H');
				LET v_Minute = TO_CHAR(v_FechaNueva, '%M');
				LET v_Second = TO_CHAR(v_FechaNueva, '%S');
				LET v_PromotorPadded = LPAD(pUsuario, 8, '0');
				LET v_FolioCancelacion = v_PromotorPadded || v_Year || v_Month || v_Day || v_Hour || v_Minute || v_Second;
				UPDATE bdicheq:si_cliente_cancela_notifica 
				SET folio_cancelacion = v_FolioCancelacion, status = '2', fecha_cancelacion = v_FechaNueva, usuario_cancela = pUsuario 
				WHERE no_cuenta = v_Cuenta;
				
				LET v_ContadorCuentasCanc = v_ContadorCuentasCanc + 1;
			ELSE
				--ELIMINA LA REFERENCIA DE LA TABLA DE TRABAJO
				DELETE FROM bdicheq:si_cliente_cancela_notifica
				WHERE status = '' AND no_cliente = v_Cliente  AND no_cuenta = v_Cuenta;
				
				LET v_ContadorCuentasNoCanc = v_ContadorCuentasNoCanc + 1;
			END IF;
			
		END FOREACH;
		RETURN cCodRet, v_ContadorCuentasCanc, v_ContadorCuentasNoCanc;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Eduardo Ãvila PÃ©rez Tagle',
'FECHA: 24/09/2025',
'Requerimiento: RQM 20 129 DEF AutomatizaciÃ³n de cancelaciÃ³n de cuentas inactivas',
'DESCRIPCION: Procedimiento almacenado encargado de realiza la cancelacion de las cuentas de forma masiva',
'BD: bdicheq';

CREATE PROCEDURE "informix".sp_cap_conemppru(id_usuarioc CHAR(8), id_funcionc CHAR(10), p_Bandera CHAR(2), pNumCliente CHAR(20), pEsEmpresaPrueba CHAR(1), pNoCuenta CHAR(11))
	RETURNING CHAR(5) AS codret, CHAR(20) AS no_cliente, CHAR(1) AS es_empresa_prueba;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	

	DEFINE v_fecha_hora_alta DATETIME YEAR TO SECOND;
	DEFINE v_fecha_hora_modifica DATETIME YEAR TO SECOND;
	
	DEFINE vConteo INTEGER;
	DEFINE vNoCliente CHAR(20);
	DEFINE vEsEmpresaPrueba CHAR(1);LET v_fecha_hora_alta = CURRENT;
	LET v_fecha_hora_modifica = CURRENT;

	LET cCodRet = '00000';
	LET iSqlErr = 0;		
	LET vConteo = 0;
	LET vNoCliente = '';
	LET vEsEmpresaPrueba = 'f';
	
	BEGIN
		
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, vNoCliente, vEsEmpresaPrueba;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/home/mfinis/EAPT/sp_cap_conemppru.out';
		-- TRACE ON;
		
		IF p_Bandera='' OR id_usuarioc = '' OR id_funcionc = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, vNoCliente, vEsEmpresaPrueba;
		END IF;		
		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(id_usuarioc, id_funcionc) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, vNoCliente, vEsEmpresaPrueba;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF p_Bandera = '1' THEN
			IF pNumCliente = '' OR pNumCliente IS NULL  THEN
				LET cCodRet = '00003';
				RETURN cCodRet, vNoCliente, vEsEmpresaPrueba;
			END IF;
			INSERT INTO bdicheq:si_cliente_emp_pru (no_cliente, es_empresa_prueba, usuario_alta, fecha_hora_alta) 
			VALUES (pNumCliente, pEsEmpresaPrueba, id_usuarioc, v_fecha_hora_alta);
			RETURN cCodRet, pNumCliente, pEsEmpresaPrueba;
		ELIF p_Bandera = '2' THEN
			IF pNumCliente = '' OR pEsEmpresaPrueba = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, vNoCliente, vEsEmpresaPrueba;
			END IF;
			
			SELECT COUNT(*) 
			INTO vConteo 
			FROM bdicheq:si_cliente_emp_pru 
			WHERE no_cliente = pNumCliente;
			
			IF NVL(vConteo,0) = 0 THEN
				INSERT INTO bdicheq:si_cliente_emp_pru (no_cliente, no_cuenta, es_empresa_prueba, usuario_alta, fecha_hora_alta) 
				VALUES (pNumCliente, pNoCuenta, pEsEmpresaPrueba, id_usuarioc, v_fecha_hora_alta);
			ELSE
				UPDATE bdicheq:si_cliente_emp_pru 
				SET es_empresa_prueba = pEsEmpresaPrueba, usuario_modifica = id_usuarioc, fecha_hora_modifica = v_fecha_hora_modifica
				WHERE no_cliente = pNumCliente;
			END IF;
			RETURN cCodRet, vNoCliente, vEsEmpresaPrueba;
		ELIF p_Bandera = '3' THEN
			IF pNumCliente = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, vNoCliente, vEsEmpresaPrueba;
			END IF;
			SELECT COUNT(*) INTO vConteo FROM bdicheq:si_cliente_emp_pru WHERE no_cliente = pNumCliente;
			IF vConteo<=0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, vNoCliente, vEsEmpresaPrueba;
			ELSE
				SELECT no_cliente, es_empresa_prueba
				INTO vNoCliente, vEsEmpresaPrueba
				FROM bdicheq:si_cliente_emp_pru
				WHERE no_cliente = pNumCliente;
				RETURN cCodRet, vNoCliente, vEsEmpresaPrueba;
			
			END IF;
		ELIF p_Bandera = '4' THEN
			IF pNumCliente = '' OR pNoCuenta='' OR pEsEmpresaPrueba='' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, vNoCliente, vEsEmpresaPrueba;
			END IF;
			IF pEsEmpresaPrueba = 't' THEN
				INSERT INTO bdicheq:si_cliente_emp_pru (no_cliente, no_cuenta, es_empresa_prueba, usuario_alta, fecha_hora_alta) 
				VALUES (pNumCliente, pNoCuenta, pEsEmpresaPrueba, id_usuarioc, v_fecha_hora_alta);
				RETURN cCodRet, vNoCliente, vEsEmpresaPrueba;
			END IF;
	
		END IF;
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Eduardo Ãvila PÃ©rez Tagle',
'FECHA: 24/09/2025',
'Requerimiento: RQM 20 129 DEF AutomatizaciÃ³n de cancelaciÃ³n de cuentas inactivas',
'DESCRIPCION: Procedimiento encargado de realizar la consulta, insercion y actualizacion de clientes de tipo prueba.',
'BD: bdicheq';

CREATE PROCEDURE "informix".sp_cap_notifica_ctecta_can(pNumCte CHAR(20), pNumCta CHAR(20), pFechaUltMov DATE, pSaldo MONEY)
	RETURNING CHAR(5) AS codret;
	
	DEFINE iSqlErr INTEGER;
	DEFINE v_Ejecutivo CHAR(8);
	DEFINE v_Funcion CHAR(8);
	DEFINE cCodRet CHAR(5);
	DEFINE v_CodRet CHAR(5);
	DEFINE v_Cuenta CHAR(20);
	DEFINE v_NumCte CHAR(20);
	DEFINE v_Saldo MONEY;
	DEFINE v_FechaUltimoMov DATE;
	DEFINE v_IdPlantilla CHAR(12);
	DEFINE v_CodRetRegistraEvento CHAR(5);

	LET iSqlErr = 0;
	LET v_Ejecutivo = 'informix';
	LET v_Funcion = 'CCN001';
	LET cCodRet = '00017';
	LET v_CodRet = '00000';
	LET v_Cuenta = '';
	LET v_NumCte = '';
	LET v_Saldo = 0;
	LET v_FechaUltimoMov = CURRENT;
	LET v_IdPlantilla = '121212';
	LET v_CodRetRegistraEvento = '00000';
	
	BEGIN
		
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;

		END EXCEPTION;
		
		 --SET DEBUG FILE TO '/tmp/mfinis/sp_extrae_cuentascan.out';
		 --TRACE ON;
		
		IF pNumCte = '' OR pNumCta = '' OR pFechaUltMov IS NULL OR pSaldo = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;		
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
			EXECUTE PROCEDURE bdicheq:"informix".sp_extrae_cuentascan(v_Ejecutivo, v_Funcion) 
			INTO v_CodRet, v_Cuenta, v_NumCte, v_Saldo, v_FechaUltimoMov
			IF v_CodRet = '00000' THEN
				EXECUTE PROCEDURE bdinteg:sp_registra_evento ('1', '', v_IdPlantilla, v_NumCte, v_Cuenta, '', '', '', '', '', '', '', '', '', '', '', '', '', '', v_Saldo, 0,
				0, 0, 0, '', '') 
				INTO v_CodRetRegistraEvento;
				
				IF v_CodRetRegistraEvento = '00000' THEN
					INSERT INTO bdicheq:"informix".si_cliente_cancela_notifica(no_cliente, no_cuenta, fec_ultimo_mov, saldo, cliente_notificado, fecha_notificacion, folio_cancelacion, status, 
								fecha_cancelacion, usuario_cancela )
					VALUES(v_NumCte, v_Cuenta, v_FechaUltimoMov, v_Saldo, 't', CURRENT, '', '0', '', '');
				ELSE
					INSERT INTO bdicheq:"informix".si_cancela_notifica_bitacora (cod_ret, fecha_error) 
					VALUES(v_CodRetRegistraEvento, CURRENT);
				END IF;
			ELSE 
				INSERT INTO bdicheq:"informix".si_cancela_notifica_bitacora (cod_ret, fecha_error) 
				VALUES(v_CodRet, CURRENT);
			END IF;
		END FOREACH;
		RETURN cCodRet;
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Eduardo Ãvila PÃ©rez Tagle',
'FECHA: 24/09/2025',
'Requerimiento: RQM 20 129 DEF AutomatizaciÃ³n de cancelaciÃ³n de cuentas inactivas',
'FUNCIONALIDAD: Componente NotificaciÃ³n de Correo ElectrÃ³nico ',
'DESCRIPCION: Procedimiento almacenado encargado de recuperar las cuentas que se deben de notificar para el proceso de cancelacion',
'BD: bdicheq';

CREATE PROCEDURE "informix".sp_extrae_cuentascan(pUsuario CHAR(8), pIdFuncion CHAR(10))
	RETURNING CHAR(5) AS codret, CHAR(20) AS Cuenta, CHAR(20) AS num_cte, MONEY AS saldo, DATE AS fecha_ultimo_movimiento;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	
	DEFINE v_Cuenta CHAR(20);
	DEFINE v_Cliente CHAR(20);
	DEFINE v_RazonSocial CHAR(120);
	DEFINE v_SdoActual MONEY;
	DEFINE v_SdoCongelado MONEY;
	DEFINE v_LimSbgCCC MONEY;
	DEFINE v_ImpChqSbg MONEY;
	DEFINE v_ComPendiente MONEY;
	DEFINE v_FecUltMov DATE;
	DEFINE v_Producto CHAR(4);
	DEFINE v_ProdNoCancelacion INTEGER;
	DEFINE anio_actual INTEGER;
    DEFINE anio_pasado INTEGER;
    DEFINE mes_actual INTEGER;
	DEFINE v_Anio SMALLINT;
	
	DEFINE v_capvigprom1 MONEY; 
	DEFINE v_capvigprom2 MONEY;
	DEFINE v_capvigprom3 MONEY;
	DEFINE v_capvigprom4 MONEY; 
	DEFINE v_capvigprom5 MONEY;
	DEFINE v_capvigprom6 MONEY;
	DEFINE v_capvigprom7 MONEY;
	DEFINE v_capvigprom8 MONEY;
	DEFINE v_capvigprom9 MONEY;
	DEFINE v_capvigprom10 MONEY;
	DEFINE v_capvigprom11 MONEY;
	DEFINE v_capvigprom12 MONEY;
	
	DEFINE v_SaldoProm1 MONEY; 
	DEFINE v_SaldoProm2 MONEY;
	DEFINE v_SaldoProm3 MONEY;
	DEFINE v_SaldoProm4 MONEY; 
	DEFINE v_SaldoProm5 MONEY;
	DEFINE v_SaldoProm6 MONEY;
	DEFINE v_SaldoProm7 MONEY;
	DEFINE v_SaldoProm8 MONEY;
	DEFINE v_SaldoProm9 MONEY;
	DEFINE v_SaldoProm10 MONEY;
	DEFINE v_SaldoProm11 MONEY;
	DEFINE v_SaldoProm12 MONEY;
	
	DEFINE v_CreditosVigentes INTEGER;
	DEFINE v_CreditosVigentes1 INTEGER;
	DEFINE v_CreditosVigentes2 INTEGER;
	
	DEFINE v_AclaracionPendiente INTEGER;
	
	DEFINE v_Spei INTEGER;
	
	define v_EmpresaPrueba INTEGER;
	DEFINE v_CuentaFideicomiso INTEGER;
	DEFINE v_FechaActual DATE;
	
	DEFINE v_mes_actual INTEGER;
	
	DEFINE v_mes_anio_actual INTEGER;
	DEFINE v_mes_anio_anterior INTEGER;
	
	DEFINE v_SaldoPromedioTotal MONEY;
	
	DEFINE v_SaldoSobregirado MONEY;
	DEFINE v_SaldoActual MONEY;
	
	DEFINE v_SaldoActualSegVal MONEY;
	DEFINE v_SaldoCuenta MONEY;
	DEFINE v_CodRetRegistraEvento CHAR(5);
	DEFINE v_TotalRegCan	INTEGER;
	DEFINE cStatus_Cta	CHAR(1);

    LET v_FechaActual = TODAY;    
    LET mes_actual = MONTH(v_FechaActual);	
	LET v_capvigprom1 = 0; 
	LET v_capvigprom2 = 0;
	LET v_capvigprom3 = 0;
	LET v_capvigprom4 = 0; 
	LET v_capvigprom5 = 0;
	LET v_capvigprom6 = 0;
	LET v_capvigprom7 = 0;
	LET v_capvigprom8 = 0;
	LET v_capvigprom9 = 0;
	LET v_capvigprom10 = 0;
	LET v_capvigprom11 = 0;
	LET v_capvigprom12 = 0;
	
	LET v_SaldoProm1 = 0; 
	LET v_SaldoProm2 = 0;
	LET v_SaldoProm3 = 0;
	LET v_SaldoProm4 = 0; 
	LET v_SaldoProm5 = 0;
	LET v_SaldoProm6 = 0;
	LET v_SaldoProm7 = 0;
	LET v_SaldoProm8 = 0;
	LET v_SaldoProm9 = 0;
	LET v_SaldoProm10 = 0;
	LET v_SaldoProm11 = 0;
	LET v_SaldoProm12 = 0;
	
	LET v_SaldoPromedioTotal = 0;
	
	LET v_Anio = 0;
	
	LET v_mes_anio_actual = 0;
	LET v_mes_anio_anterior = 0;

	LET v_Cuenta = '';
	LET v_Cliente  = '';
	LET v_RazonSocial = '';
	LET v_SdoActual = 0;
	LET v_SdoCongelado = 0;
	LET v_LimSbgCCC = 0;
	LET v_ImpChqSbg = 0;
	LET v_ComPendiente = 0;
	LET v_FecUltMov = CURRENT;
	LET v_Producto = '0000';
	LET v_ProdNoCancelacion = 0;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;		
	
	LET v_SaldoSobregirado = 0;
	LET v_SaldoActual = 0;
	
	LET v_CreditosVigentes = 0;
	LET v_CreditosVigentes1 = 0;
	LET v_CreditosVigentes2 = 0;
	
	LET v_SaldoActualSegVal = 0;
	LET v_SaldoCuenta = 0;
	
	LET v_AclaracionPendiente = 0;
	LET v_EmpresaPrueba = 0;
	LET v_CuentaFideicomiso = 0;
	
	LET v_Spei = 0;
	LET v_CodRetRegistraEvento = '00000';
	LET v_TotalRegCan = 0;
	LET cStatus_Cta = '';
	
	BEGIN
		
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, v_Cuenta, v_Cliente, v_SdoActual, v_FecUltMov;
		END EXCEPTION;
		
		SET DEBUG FILE TO '/tmp/mfinis/vero/cancelacion/sp_extrae_cuentascan.out';
		TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, v_Cuenta, v_Cliente, v_SdoActual, v_FecUltMov;
		END IF;		
		
		/*EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
			IF cCodRet <> '00000' THEN
			RETURN cCodRet, v_Cuenta, v_Cliente, v_SdoActual, v_FecUltMov;
		END IF;*/
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		FOREACH
			SELECT chq.cuenta, cli.numcte, cli.razon_social, chq.sdo_actual, chq.sdo_cong, chq.lim_sbg_ccc, chq.imp_chq_sbg, chq.com_pendiente, chq.fec_ult_mov, chq.producto, chq.status_cta
			INTO v_Cuenta, v_Cliente, v_RazonSocial, v_SdoActual, v_SdoCongelado, v_LimSbgCCC, v_ImpChqSbg, v_ComPendiente, v_FecUltMov, v_Producto, cStatus_Cta
			FROM bdinteg:si_cliente cli
			INNER JOIN bdicheq:sc_maechq chq ON cli.numcte = chq.num_cte
			WHERE chq.producto IN ('1200','1600','2200','2600') AND cli.tpo_persona='02' AND chq.status_cta NOT IN('3','2','5') 
			AND chq.fec_ult_mov <= (TODAY - DAY(TODAY) UNITS DAY) - 12 UNITS MONTH
			
			SELECT COUNT(*) 
			INTO v_ProdNoCancelacion 
			FROM bdicheq:sc_productonocancelacion 
			WHERE producto = v_Producto;
			
			IF NVL(v_ProdNoCancelacion,0) = 0 THEN
				LET v_mes_anio_actual = mes_actual - 1;
				LET v_mes_anio_anterior = 12 - v_mes_anio_actual;
				FOREACH
					SELECT
						capvigprom1, capvigprom2, capvigprom3, capvigprom4, capvigprom5, 
						capvigprom6, capvigprom7, capvigprom8, capvigprom9, capvigprom10, 
						capvigprom11, capvigprom12, anio
					INTO 
						v_capvigprom1, v_capvigprom2, v_capvigprom3, v_capvigprom4, v_capvigprom5,
						v_capvigprom6, v_capvigprom7, v_capvigprom8, v_capvigprom9, v_capvigprom10,
						v_capvigprom11, v_capvigprom12, v_Anio
					FROM 
						bdicheq:sc_sdomensualc
					WHERE
						cuenta = v_Cuenta
					AND				
						(anio = YEAR(v_FechaActual - 12 UNITS MONTH)
					OR
						anio = YEAR(v_FechaActual - 1 UNITS MONTH))
						
					IF v_Anio = YEAR(v_FechaActual - 1) THEN
						IF v_mes_anio_anterior = 1 THEN
							LET v_SaldoProm1 = v_capvigprom12;
						ELIF v_mes_anio_anterior = 2 THEN
							LET v_SaldoProm1 = v_capvigprom11;
							LET v_SaldoProm2 = v_capvigprom12;
						ELIF v_mes_anio_anterior = 3 THEN
							LET v_SaldoProm1 = v_capvigprom10;
							LET v_SaldoProm2 = v_capvigprom11;
							LET v_SaldoProm3 = v_capvigprom12;
						ELIF v_mes_anio_anterior = 4 THEN
							LET v_SaldoProm1 = v_capvigprom9;
							LET v_SaldoProm2 = v_capvigprom10;
							LET v_SaldoProm3 = v_capvigprom11;
							LET v_SaldoProm4 = v_capvigprom12;
						ELIF v_mes_anio_anterior = 5 THEN
							LET v_SaldoProm1 = v_capvigprom8;
							LET v_SaldoProm2 = v_capvigprom9;
							LET v_SaldoProm3 = v_capvigprom10;
							LET v_SaldoProm4 = v_capvigprom11;
							LET v_SaldoProm5 = v_capvigprom12;
						ELIF v_mes_anio_anterior = 6 THEN
							LET v_SaldoProm1 = v_capvigprom7;
							LET v_SaldoProm2 = v_capvigprom8;
							LET v_SaldoProm3 = v_capvigprom9;
							LET v_SaldoProm4 = v_capvigprom10;
							LET v_SaldoProm5 = v_capvigprom11;
							LET v_SaldoProm6 = v_capvigprom12;
						ELIF v_mes_anio_anterior = 7 THEN
							LET v_SaldoProm1 = v_capvigprom6;
							LET v_SaldoProm2 = v_capvigprom7;
							LET v_SaldoProm3 = v_capvigprom8;
							LET v_SaldoProm4 = v_capvigprom9;
							LET v_SaldoProm5 = v_capvigprom10;
							LET v_SaldoProm6 = v_capvigprom11;
							LET v_SaldoProm7 = v_capvigprom12;
						ELIF v_mes_anio_anterior = 8 THEN
							LET v_SaldoProm1 = v_capvigprom5;
							LET v_SaldoProm2 = v_capvigprom6;
							LET v_SaldoProm3 = v_capvigprom7;
							LET v_SaldoProm4 = v_capvigprom8;
							LET v_SaldoProm5 = v_capvigprom9;
							LET v_SaldoProm6 = v_capvigprom10;
							LET v_SaldoProm7 = v_capvigprom11;
							LET v_SaldoProm8 = v_capvigprom12;
						ELIF v_mes_anio_anterior = 9 THEN
							LET v_SaldoProm1 = v_capvigprom4;
							LET v_SaldoProm2 = v_capvigprom5;
							LET v_SaldoProm3 = v_capvigprom6;
							LET v_SaldoProm4 = v_capvigprom7;
							LET v_SaldoProm5 = v_capvigprom8;
							LET v_SaldoProm6 = v_capvigprom9;
							LET v_SaldoProm7 = v_capvigprom10;
							LET v_SaldoProm8 = v_capvigprom11;
							LET v_SaldoProm9 = v_capvigprom12;
						ELIF v_mes_anio_anterior = 10 THEN
							LET v_SaldoProm1 = v_capvigprom3;
							LET v_SaldoProm2 = v_capvigprom4;
							LET v_SaldoProm3 = v_capvigprom5;
							LET v_SaldoProm4 = v_capvigprom6;
							LET v_SaldoProm5 = v_capvigprom7;
							LET v_SaldoProm6 = v_capvigprom8;
							LET v_SaldoProm7 = v_capvigprom9;
							LET v_SaldoProm8 = v_capvigprom10;
							LET v_SaldoProm9 = v_capvigprom11;
							LET v_SaldoProm10 = v_capvigprom12;
						ELIF v_mes_anio_anterior = 11 THEN
							LET v_SaldoProm1 = v_capvigprom2;
							LET v_SaldoProm2 = v_capvigprom3;
							LET v_SaldoProm3 = v_capvigprom4;
							LET v_SaldoProm4 = v_capvigprom5;
							LET v_SaldoProm5 = v_capvigprom6;
							LET v_SaldoProm6 = v_capvigprom7;
							LET v_SaldoProm7 = v_capvigprom8;
							LET v_SaldoProm8 = v_capvigprom9;
							LET v_SaldoProm9 = v_capvigprom10;
							LET v_SaldoProm10 = v_capvigprom11;
							LET v_SaldoProm11 = v_capvigprom12;
						ELIF v_mes_anio_anterior = 12 THEN
							LET v_SaldoProm1 = v_capvigprom1;
							LET v_SaldoProm2 = v_capvigprom2;
							LET v_SaldoProm3 = v_capvigprom3;
							LET v_SaldoProm4 = v_capvigprom4;
							LET v_SaldoProm5 = v_capvigprom5;
							LET v_SaldoProm6 = v_capvigprom6;
							LET v_SaldoProm7 = v_capvigprom7;
							LET v_SaldoProm8 = v_capvigprom8;
							LET v_SaldoProm9 = v_capvigprom9;
							LET v_SaldoProm10 = v_capvigprom10;
							LET v_SaldoProm11 = v_capvigprom11;
							LET v_SaldoProm12 = v_capvigprom12;
						END IF;
					ELIF v_Anio = YEAR(v_FechaActual) THEN
						IF v_mes_anio_actual = 1 THEN
							LET v_SaldoProm12 = v_capvigprom1;
						ELIF v_mes_anio_actual = 2 THEN
							LET v_SaldoProm11 = v_capvigprom1;
							LET v_SaldoProm12 = v_capvigprom2;
						ELIF v_mes_anio_actual = 3 THEN
							LET v_SaldoProm10 = v_capvigprom1;
							LET v_SaldoProm11 = v_capvigprom2;
							LET v_SaldoProm12 = v_capvigprom3;
						ELIF v_mes_anio_actual = 4 THEN
							LET v_SaldoProm9 = v_capvigprom1;
							LET v_SaldoProm10 = v_capvigprom2;
							LET v_SaldoProm11 = v_capvigprom3;
							LET v_SaldoProm12 = v_capvigprom4;
						ELIF v_mes_anio_actual = 5 THEN
							LET v_SaldoProm8 = v_capvigprom1;
							LET v_SaldoProm9 = v_capvigprom2;
							LET v_SaldoProm10 = v_capvigprom3;
							LET v_SaldoProm11 = v_capvigprom4;
							LET v_SaldoProm12 = v_capvigprom5;
						ELIF v_mes_anio_actual = 6 THEN
							LET v_SaldoProm7 = v_capvigprom1;
							LET v_SaldoProm8 = v_capvigprom2;
							LET v_SaldoProm9 = v_capvigprom3;
							LET v_SaldoProm10 = v_capvigprom4;
							LET v_SaldoProm11 = v_capvigprom5;
							LET v_SaldoProm12 = v_capvigprom6;
						ELIF v_mes_anio_actual = 7 THEN
							LET v_SaldoProm6 = v_capvigprom1;
							LET v_SaldoProm7 = v_capvigprom2;
							LET v_SaldoProm8 = v_capvigprom3;
							LET v_SaldoProm9 = v_capvigprom4;
							LET v_SaldoProm10 = v_capvigprom5;
							LET v_SaldoProm11 = v_capvigprom6;
							LET v_SaldoProm12 = v_capvigprom7;
						ELIF v_mes_anio_actual = 8 THEN
							LET v_SaldoProm5 = v_capvigprom1;
							LET v_SaldoProm6 = v_capvigprom2;
							LET v_SaldoProm7 = v_capvigprom3;
							LET v_SaldoProm8 = v_capvigprom4;
							LET v_SaldoProm9 = v_capvigprom5;
							LET v_SaldoProm10 = v_capvigprom6;
							LET v_SaldoProm11 = v_capvigprom7;
							LET v_SaldoProm12 = v_capvigprom8;
						ELIF v_mes_anio_actual = 9 THEN
							LET v_SaldoProm4 = v_capvigprom1;
							LET v_SaldoProm5 = v_capvigprom2;
							LET v_SaldoProm6 = v_capvigprom3;
							LET v_SaldoProm7 = v_capvigprom4;
							LET v_SaldoProm8 = v_capvigprom5;
							LET v_SaldoProm9 = v_capvigprom6;
							LET v_SaldoProm10 = v_capvigprom7;
							LET v_SaldoProm11 = v_capvigprom8;
							LET v_SaldoProm12 = v_capvigprom9;
						ELIF v_mes_anio_actual = 10 THEN
							LET v_SaldoProm3 = v_capvigprom1;
							LET v_SaldoProm4 = v_capvigprom2;
							LET v_SaldoProm5 = v_capvigprom3;
							LET v_SaldoProm6 = v_capvigprom4;
							LET v_SaldoProm7 = v_capvigprom5;
							LET v_SaldoProm8 = v_capvigprom6;
							LET v_SaldoProm9 = v_capvigprom7;
							LET v_SaldoProm10 = v_capvigprom8;
							LET v_SaldoProm11 = v_capvigprom9;
							LET v_SaldoProm12 = v_capvigprom10;
						ELIF v_mes_anio_actual = 11 THEN
							LET v_SaldoProm2 = v_capvigprom1;
							LET v_SaldoProm3 = v_capvigprom2;
							LET v_SaldoProm4 = v_capvigprom3;
							LET v_SaldoProm5 = v_capvigprom4;
							LET v_SaldoProm6 = v_capvigprom5;
							LET v_SaldoProm7 = v_capvigprom6;
							LET v_SaldoProm8 = v_capvigprom7;
							LET v_SaldoProm9 = v_capvigprom8;
							LET v_SaldoProm10 = v_capvigprom9;
							LET v_SaldoProm11 = v_capvigprom10;
							LET v_SaldoProm12 = v_capvigprom11;
						ELIF v_mes_anio_actual = 12 THEN
							LET v_SaldoProm1 = v_capvigprom1;
							LET v_SaldoProm2 = v_capvigprom2;
							LET v_SaldoProm3 = v_capvigprom3;
							LET v_SaldoProm4 = v_capvigprom4;
							LET v_SaldoProm5 = v_capvigprom5;
							LET v_SaldoProm6 = v_capvigprom6;
							LET v_SaldoProm7 = v_capvigprom7;
							LET v_SaldoProm8 = v_capvigprom8;
							LET v_SaldoProm9 = v_capvigprom9;
							LET v_SaldoProm10 = v_capvigprom10;
							LET v_SaldoProm11 = v_capvigprom11;
							LET v_SaldoProm12 = v_capvigprom12;
						END IF;
					END IF;
					
				END FOREACH
				LET v_SaldoPromedioTotal = v_capvigprom1 + v_capvigprom2 + v_capvigprom3 + v_capvigprom4 + v_capvigprom5 + v_capvigprom6 + v_capvigprom7 + v_capvigprom8 + v_capvigprom9 + v_capvigprom10 + v_capvigprom11 + v_capvigprom2;
				IF NVL(v_SaldoPromedioTotal,0) = 0 THEN
					FOREACH
						SELECT imp_chq_sbg, sdo_actual INTO v_SaldoSobregirado, v_SaldoActual 
						FROM bdicheq:sc_maechq WHERE cuenta = v_Cuenta AND num_cte = v_Cliente --Aqui se agrego el filtro num_cte porque devolvÃ­a mas de un registro
					END FOREACH
					IF NVL(v_SaldoSobregirado,0) = 0 THEN
						IF NVL(v_SaldoActual,0) = 0 THEN
							--Aqui va el otro calculo del saldo actual
							SELECT (cheq.sdo_actual - (cheq.sdo_retenido + cheq.sdo_cong + cheq.imp_sbg_ccc)) AS saldo_actual, bal.sdo_cta
							INTO v_SaldoActualSegVal, v_SaldoCuenta
							FROM bdicheq:sc_maechq cheq
							INNER JOIN bditransfer:tf_maecte mae ON mae.numcte_tf = cheq.num_cte
							INNER JOIN bditransfer:tf_account_balance_customer bal ON bal.cuenta = mae.cuenta_tf
							WHERE cheq.num_cte = v_Cliente  AND (mae.numcte = v_Cliente OR mae.numcte_tf = v_Cliente) AND mae.status_cta != '2' AND bal.fecha_proceso = (SELECT MAX(bal2.fecha_proceso)
						    FROM bditransfer:tf_account_balance_customer bal2
							WHERE bal2.cuenta = bal.cuenta);
							
							IF NVL(v_SaldoActualSegVal,0) = 0 AND NVL(v_SaldoCuenta,0) = 0 THEN
								SELECT COUNT(*) INTO v_CreditosVigentes FROM bdicred:sd_ctascarg WHERE num_cta = v_Cuenta AND naturaleza = naturaleza;
								IF NVL(v_CreditosVigentes,0) > 0 THEN
									SELECT count(ctascar.num_cta)
									INTO v_CreditosVigentes1
									FROM bdicred:sd_ctascarg ctascar
									INNER JOIN bdicred:sd_maecred cred ON ctascar.empresa = cred.empresa AND ctascar.num_credito = cred.num_credito
									WHERE cred.numcte = v_Cliente AND ctascar.num_cta = v_Cuenta AND cred.status_cred != 'FF';
									
									SELECT count(ctascar.num_cta)
									INTO v_CreditosVigentes2
									FROM bdicred:sd_ctascarg ctascar
									INNER JOIN bdicred:sd_maecredcrd cred ON ctascar.empresa = cred.empresa AND ctascar.num_credito = cred.num_credito
									WHERE cred.numcte = v_Cliente AND ctascar.num_cta = v_Cuenta AND cred.status_cred != 'FF';
								END IF;
								-- verificar regla d ecredito vig.
								IF NVL(v_CreditosVigentes,0) = 0 and (NVL(v_CreditosVigentes1,0) = 0 and NVL(v_CreditosVigentes2,0) = 0) THEN
										SELECT count(producto.numero_cuenta)
										INTO v_AclaracionPendiente
										FROM bdiaclaracion:acl_producto producto
										INNER JOIN bdiaclaracion:acl_aclaracion aclaracion ON producto.pky_producto = aclaracion.fky_producto
										WHERE producto.numero_cuenta = v_Cuenta AND aclaracion.fky_estatus_aclaracion = '2';
										IF NVL(v_AclaracionPendiente,0) = 0 THEN -- ajuste
											SELECT COUNT(*) 
											INTO v_EmpresaPrueba
											FROM bdicnweb:si_cliente_emp_pru
											WHERE no_cliente = v_Cliente;
											
											IF NVL(v_EmpresaPrueba,0) = 0 THEN
												SELECT COUNT(*) 
												INTO v_CuentaFideicomiso
												FROM bdinteg:si_ctepm 
												WHERE numcte = v_Cliente AND 
												(giro IS NULL OR giro = '' OR actividadsocial IS NULL OR actividadsocial = '' OR sufijo IS NULL OR sufijo = '' OR telefono_contacto IS NULL OR telefono_contacto = '' 
														OR tipo_poder IS NULL OR tipo_poder = '' OR tipo_admon IS NULL OR tipo_admon = '' OR tipo_org IS NULL OR tipo_org = '');
												IF NVL(v_CuentaFideicomiso,0) = 0 THEN -- ajuste
													SELECT COUNT(*) 
													INTO v_Spei
													FROM bdicheq:sc_movdia 
													WHERE cuenta = v_Cuenta AND transacc = '0274';
													IF v_Spei = 0 THEN
														SELECT COUNT(*)
														INTO v_TotalRegCan
														FROM bdicheq:"informix".si_cliente_cancela_notifica
														WHERE no_cliente = v_Cliente AND no_cuenta = v_Cuenta;
														IF NVL(v_TotalRegCan,0) = 0 THEN 
															--Aqui se ejecuta el SPL para envio de notifiaciÃ³n
															EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','CTAS_INAC','COR_CAN_CTAI',v_Cliente,v_Cuenta,'','2','5426','','','','','','','','','','','',0,0,0,0,0,CURRENT,'')
															INTO v_CodRetRegistraEvento;
															IF v_CodRetRegistraEvento = '00000' THEN
																INSERT INTO bdicheq:"informix".si_cliente_cancela_notifica(no_cliente, no_cuenta, fec_ultimo_mov, saldo, cliente_notificado, fecha_notificacion, folio_cancelacion, status, fecha_cancelacion, usuario_cancela, status_ant)
																VALUES(v_Cliente, v_Cuenta, v_FecUltMov, v_SdoActual, 't', CURRENT, '', '', '', '', cStatus_Cta);
															ELSE
																INSERT INTO bdicheq:"informix".si_cancela_notifica_bitacora (cod_ret, fecha_error) 
																VALUES(v_CodRetRegistraEvento, CURRENT);
															END IF;
														END IF;
													END IF;
												END IF;
											END IF;
										END IF;
									--END IF;
								END IF;
							END IF;							
							--Aqui termina el calculo del saldo actual
						END IF;
					END IF;
				END IF;
			END IF;
		END FOREACH
		RETURN cCodRet, v_Cuenta, v_Cliente, v_SdoActual, v_FecUltMov;
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Eduardo Ãvila PÃ©rez Tagle',
'FECHA: 24/09/2025',
'Requerimiento: RQM 20 129 DEF AutomatizaciÃ³n de cancelaciÃ³n de cuentas inactivas',
'FUNCIONALIDAD:',
'DESCRIPCION: ',
'BD: bdicheq';

CREATE PROCEDURE "informix".sp_com_manejo_cta_ident_1()
    RETURNING CHAR(5), VARCHAR(80);
-- *****************************************************************************
-- Version          1.0.0
-- Objetivo:        Toma un cliente y analiza sus cuentas para
--                   decidir si se le cobrara la "Comision por Manejo de
--                   Cuenta", las cuentas que deben pagar son guardadas en la
--                   tabla sc_com_manejo_ctas_a_cobrar.
-- Creado por:      Joel Martinez
-- Fecha:           Septiembre - 2024
-- *****************************************************************************
    
    DEFINE vNumHilo                 SMALLINT;
    DEFINE vCodRet                  CHAR(5);
    DEFINE vErrorInfo               VARCHAR(80);
    DEFINE vIsamErr                 SMALLINT;
    DEFINE vSQLErr                  INTEGER;
    DEFINE vEmpresa                 CHAR(3);
    DEFINE vFechaInicial            DATE;
    DEFINE vFechaFinal              DATE;
    DEFINE vAnioMes                 CHAR(6);
    DEFINE vSdoPromMinGral          INTEGER;
    DEFINE vSdoPromMin2500          INTEGER;
    DEFINE vUltimoCteHiloAnterior   CHAR(20);
    DEFINE vUltimoCteHiloActual     CHAR(20);
    DEFINE vFechConMovHis           DATE;
    DEFINE vUltimoCteProcesado      CHAR(20);
    DEFINE vFechaHoraFinIniciador   DATETIME YEAR TO FRACTION(3);
    DEFINE vFechaHoraIni            DATETIME YEAR TO FRACTION(3);
    DEFINE vStatusPrevio            VARCHAR(10);
    DEFINE vStatusIniciador         VARCHAR(10);
    DEFINE vIndice                  SMALLINT;
    DEFINE vConfStatus              VARCHAR(60);
    DEFINE vConfProductos           VARCHAR(60);
    DEFINE vCharAux                 CHAR(1);
    DEFINE vStringAux               VARCHAR(4);
    DEFINE vExisteTMP               SMALLINT;
    DEFINE vExisteTMP2              SMALLINT;
    DEFINE vExisteTMP3              SMALLINT;
    DEFINE vExisteTMP4              SMALLINT;
    DEFINE vExisteTMP5              SMALLINT;
    DEFINE vContCtasInsertadas      INTEGER;
    DEFINE vNumCte                  CHAR(20);
    DEFINE vCuenta                  CHAR(20);
    DEFINE vSucursal                CHAR(4);
    DEFINE vCantCtasProcesadas      INTEGER;
    DEFINE vCantCtasIdentificadas   INTEGER;
    DEFINE vCantCtasInversion       SMALLINT;
    DEFINE vCantCtasPagare          SMALLINT;
    DEFINE vCantMovHis              SMALLINT;
    DEFINE vCantMovHisOld           SMALLINT;
    DEFINE cCantMovCred             SMALLINT;
    DEFINE vParamMontCargo          MONEY(14,2);
    DEFINE vArchivoSQL              CHAR(50);
    DEFINE vSQL                     CHAR(350);
   
    LET vNumHilo                = 1;
    LET vCodRet                 = "00000";
    LET vEmpresa                = "001";
    LET vErrorInfo              = '';
    LET vIsamErr                = 0;
    LET vSQLErr                 = 0; 
    LET vFechaInicial           = '';
    LET vFechaFinal             = '';
    LET vAnioMes                = '';
    LET vSdoPromMinGral         = 0;
    LET vSdoPromMin2500         = 0;
    LET vUltimoCteHiloAnterior  = '';
    LET vUltimoCteHiloActual    = ''; 
    LET vFechConMovHis          = '';
    LET vUltimoCteProcesado     = '';
    LET vFechaHoraFinIniciador  = '';
    LET vFechaHoraIni           = '';
    LET vStatusPrevio           = '';
    LET vStatusIniciador        = '';
    LET vIndice                 = 0;
    LET vConfStatus             = '';
    LET vConfProductos          = '';
    LET vCharAux                = '';
    LET vStringAux              = '';
    LET vExisteTMP              = 0;
    LET vExisteTMP2             = 0;
    LET vExisteTMP3             = 0;
    LET vExisteTMP4             = 0;
    LET vExisteTMP5             = 0;
    LET vContCtasInsertadas     = 0;
    LET vNumCte                 = '';
    LET vCuenta                 = '';
    LET vSucursal               = '';
    LET vCantCtasProcesadas     = 0;
    LET vCantCtasIdentificadas  = 0; 
    LET vCantCtasInversion      = 0;
    LET vCantCtasPagare         = 0;
    LET vCantMovHis             = 0;
    LET vCantMovHisOld          = 0;
    LET cCantMovCred            = 0;
    LET vParamMontCargo         = 150.00;
    LET vArchivoSQL             = "/resplogifx/conciliachq/updatebitacora" || vNumHilo ||".sql";
    LET vSQL                    = '';

    BEGIN
    ON EXCEPTION SET vSQLErr, vIsamErr, vErrorInfo
        IF  vSQLErr != 0 THEN
            SET DEBUG FILE TO '/resplogifx/conciliachq/sp_com_manejo_cta_ident_1.err';
            TRACE ON;
            LET vCodRet     = vSQLErr;
            LET vIsamErr    = vIsamErr;
            LET vErrorInfo   = vErrorInfo;
            LET vNumCte     = vNumCte;
            LET vCuenta     = vCuenta;
        
            IF vExisteTMP = 1 THEN
                DROP TABLE tmp_conf_status;
                DROP TABLE tmp_conf_productos; 
            END IF;
        
            IF vExisteTMP2 = 1 THEN
                DROP TABLE tmp_ctas_total;
                DROP TABLE tmp_ctas_cte;
            END IF;
        
            IF vExisteTMP3 = 1 THEN
                DROP TABLE tmp_ctes_exentos;
            END IF;

            IF vExisteTMP4 = 1 THEN
                DROP TABLE tmp_ctes_sin_sdo_prom;
            END IF;

            IF vExisteTMP5 = 1 THEN
                DROP TABLE tmp_ctes_sin_presperban;
            END IF;
        
            IF vContCtasInsertadas > 0 THEN
                ROLLBACK;
            END IF;
        
            RETURN vCodRet, vErrorInfo;
        END IF;
    END EXCEPTION;
    
    --SET DEBUG FILE TO '/resplogifx/conciliachq/sp_com_manejo_cta_ident_1.out';
    --TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;  
    
    /**************************************************************************/
    /*                         CONSULTA DE PARAMETROS                         */
    /**************************************************************************/
    -- El periodo a procesar, sera del primero al ultimo dia del mes anterior
    SELECT DATE( pri_dia_mes - 1 UNITS MONTH ),
    DATE( pri_dia_mes - 1 UNITS DAY )
    INTO vFechaInicial, vFechaFinal
    FROM sc_fechas
    WHERE empresa = vEmpresa;
    
    -- Extrae aÃ±o y mes que se procesara
    LET vAnioMes = TO_CHAR(vFechaInicial,"%Y%m");

    -- Saldo promedio minimo general
    SELECT valor 
    INTO vSdoPromMinGral
    FROM sc_param
    WHERE codparam = "sdoprom";

    -- Saldo promedio minimo para producto 2500
    SELECT valor 
    INTO vSdoPromMin2500
    FROM sc_param
    WHERE codparam = "sdoprom_2500";
    
    -- Obtiene el ultimo cte que atendera este hilo
    SELECT valor 
    INTO vUltimoCteHiloActual
    FROM sc_param 
    WHERE codparam = "UltCteIdentComMC" || vNumHilo;

    -- Fecha de concentrado de la tabla sc_movhis_old
    SELECT TO_DATE(valor, '%m/%d/%Y')
    INTO vFechConMovHis
    FROM sc_param 
    WHERE codparam = "fechcon_movhis";
    
    -- Se obtienen los status de las cuentas a considerar
    SELECT valor
    INTO vConfStatus
    FROM sc_param
    WHERE codparam = "IdenComMCStatus";
    
    -- Se obtienen los productos de las cuentas a considerar
    SELECT valor
    INTO vConfProductos
    FROM sc_param
    WHERE codparam = "IdenComMCProductos";
    /**************************************************************************/
    /*                      [FIN] CONSULTA DE PARAMETROS                      */
    /**************************************************************************/

    /**************************************************************************/
    /*     GUARDA STATUS Y PRODUCTOS CONFIGURADOS EN TABLAS TEMPORALES        */
    /**************************************************************************/
    CREATE TEMP TABLE tmp_conf_status (
        status CHAR(1)) WITH NO LOG;

    CREATE TEMP TABLE tmp_conf_productos (
        producto CHAR(4)) WITH NO LOG;
    
    LET vExisteTMP = 1;

    -- Ciclo que extrae los status y los inserta en la tabla temporal
    FOR vIndice = 1 TO LENGTH( vConfStatus )
        LET vCharAux = SUBSTR( vConfStatus, vIndice, 1 );
        IF vCharAux IN ( '1', '2', '3', '5', '6', '7', '8', '9' ) THEN
            INSERT INTO tmp_conf_status ( status ) 
                VALUES ( vCharAux );
        END IF;
    END FOR;
    
    -- Ciclo que extrae los productos y los inserta en la tabla temporal
    FOR vIndice = 1 TO LENGTH( vConfProductos )
        LET vCharAux = SUBSTR( vConfProductos, vIndice, 1 );
        IF vCharAux IN ( '1', '2', '3', '4', '5', '6', '7', '8', '9', '0') THEN
            LET vStringAux = vStringAux || vCharAux;
            IF LENGTH( vStringAux ) > 3 THEN
                INSERT INTO tmp_conf_productos ( producto ) 
                    VALUES ( vStringAux );    
                LET vStringAux = '';
            END IF;
        ELSE
            LET vStringAux = '';
        END IF;
    END FOR;

    /**************************************************************************/
    /*    [FIN] GUARDA STATUS Y PRODUCTOS CONFIGURADOS EN TABLAS TEMPORALES   */
    /**************************************************************************/

    /**************************************************************************/
    /*                         REGISTRO EN BITACORA                           */
    /**************************************************************************/
    -- Revisa que la ultima ejecucion del proceso iniciador haya concluido
    FOREACH 
        SELECT FIRST 1 status, fecha_hora_fin
        INTO vStatusIniciador, vFechaHoraFinIniciador
        FROM sc_bitacora_com_manejo_cta 
        WHERE aniomes = vAnioMes
        AND etapa = 'INICIA IDENTIFICACION'
        ORDER BY fecha_hora_fin DESC
    END FOREACH;

    IF  vStatusIniciador <> 'FINALIZADO' THEN
        -- Error, el proceso iniciador no ha finalizado
        DROP TABLE tmp_conf_status;
        DROP TABLE tmp_conf_productos;
        LET vCodRet = "00002";
        LET vErrorInfo = "Error: El proceso iniciador no ha finalizado";
        RETURN vCodRet, vErrorInfo;
    END IF;

    -- Revisa si hay una ejecucion previa de este hilo
    FOREACH
        SELECT FIRST 1 status, fecha_hora_ini 
        INTO vStatusPrevio, vFechaHoraIni
        FROM sc_bitacora_com_manejo_cta 
        WHERE aniomes = vAnioMes
        AND etapa = 'IDENTIFICACION'
        AND hilo = vNumHilo
        AND fecha_hora_ini > vFechaHoraFinIniciador
        ORDER BY fecha_hora_ini DESC
    END FOREACH;

    IF vStatusPrevio = 'FINALIZADO' THEN 
        -- Se cancela todo, el proceso ya se ha finalizado previamente
        DROP TABLE tmp_conf_status;
        DROP TABLE tmp_conf_productos;
        LET vCodRet = "00003";
        LET vErrorInfo = "Este hilo ya ha finalizado en una ejecucion previa";
        RETURN vCodRet, vErrorInfo;
    END IF;

    IF vStatusPrevio = 'EN PROCESO' THEN 
        -- Retoma donde se quedo la ejecucion previa inconclusa
        SELECT MAX( cliente )
        INTO vUltimoCteProcesado
        FROM sc_com_manejo_ctas_a_cobrar
        WHERE cliente <= vUltimoCteHiloActual;

    ELSE
        -- Registra el inicio de la nueva ejecucion
        LET vFechaHoraIni = CURRENT;

        INSERT INTO sc_bitacora_com_manejo_cta (aniomes, etapa, hilo, status, fecha_hora_ini)
            VALUES (vAnioMes, 'IDENTIFICACION', vNumHilo, 'EN PROCESO', vFechaHoraIni);
    END IF;
    /**************************************************************************/
    /*                       [FIN] REGISTRO EN BITACORA                       */
    /**************************************************************************/

    /**************************************************************************/
    /*                           PROCESO PRINCIPAL                            */
    /**************************************************************************/
    -- Se valida si ya hay clientes procesados
    IF vUltimoCteProcesado IS NULL OR vUltimoCteProcesado == '' THEN
        -- No se ha procesado ni un cliente, se inicia despues del hilo anterior
        LET vUltimoCteProcesado = vUltimoCteHiloAnterior;
    END IF;

    -- Obtiene las cuentas que procesara este hilo
    --Insert Into tmp_ctas_total_cte
    SELECT chq.num_cte, chq.cuenta, chq.producto, chq.sucursal, 
    (sdo.capvigacum / sdo.diacum) AS sdo_prom
    FROM sc_maechq AS chq
    INNER JOIN tmp_conf_status AS c_stat ON chq.status_cta = c_stat.status
    INNER JOIN tmp_conf_productos AS c_prod ON chq.producto = c_prod.producto
    INNER JOIN sc_maenoc AS noc ON chq.num_cte > vUltimoCteProcesado
    AND chq.num_cte <= vUltimoCteHiloActual AND noc.fecha_alta < vFechaInicial
    AND chq.cuenta = noc.cuenta
    LEFT JOIN sc_sdodiarioc AS sdo ON sdo.aniomes = vAnioMes AND chq.cuenta = sdo.cuenta
    WHERE chq.empresa = vEmpresa
    INTO TEMP tmp_ctas_total WITH NO LOG;

    -- Tabla temporal para guardar las cuentas de un cliente siendo evaluado
    CREATE TEMP TABLE tmp_ctas_cte (
        cuenta CHAR(20),
        sucursal CHAR(4)) WITH NO LOG;
    LET vExisteTMP2 = 1;

    CREATE INDEX idx_tmp_ctas_total ON tmp_ctas_total(num_cte) 
        USING BTREE;
    CREATE INDEX idx_tmp_ctas_total2 ON tmp_ctas_total( producto, sdo_prom ) 
        USING BTREE;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_ctas_total;

    DROP TABLE tmp_conf_status;
    DROP TABLE tmp_conf_productos;
    LET vExisteTMP = 0;

    -- Si es la primer ejecucion, se guarda cuantas cuentas procesa este hilo
    IF vStatusPrevio = '' THEN
        SELECT COUNT(*)
        INTO vCantCtasProcesadas
        FROM tmp_ctas_total;

        UPDATE sc_bitacora_com_manejo_cta 
        SET cuentas_procesadas = vCantCtasProcesadas
        WHERE aniomes = vAnioMes
        AND etapa = 'IDENTIFICACION'
        AND hilo = vNumHilo
        AND status = 'EN PROCESO'
        AND fecha_hora_ini = vFechaHoraIni;
    END IF;

    -- Tabla temporal que guarda los clientes que exentan por saldo promedio y prestamo personal BanCoppel
    CREATE TEMP TABLE tmp_ctes_exentos (
        num_cte CHAR(20)) WITH NO LOG;
    CREATE INDEX idx_tmp_ctes_exentos ON tmp_ctes_exentos(num_cte);
    LET vExisteTMP3 = 1;

    /* EXENCION POR CUMPLIR CON SALDO PROMEDIO MINIMO */
    INSERT INTO tmp_ctes_exentos (num_cte)
    SELECT num_cte
    FROM tmp_ctas_total 
    WHERE producto <> "2500" 
    AND sdo_prom >= vSdoPromMinGral;

    INSERT INTO tmp_ctes_exentos (num_cte)
    SELECT num_cte
    FROM tmp_ctas_total 
    WHERE producto = "2500" 
    AND sdo_prom >= vSdoPromMin2500;
            
    SELECT DISTINCT( num_cte )
    FROM tmp_ctas_total AS ctas
    WHERE NOT EXISTS(SELECT 1 
                    FROM tmp_ctes_exentos AS exentos 
                    WHERE ctas.num_cte = exentos.num_cte)
    INTO TEMP tmp_ctes_sin_sdo_prom WITH NO LOG;
    LET vExisteTMP4 = 1;
    CREATE INDEX idx_tmp_ctes_sin_sdo_prom ON tmp_ctes_sin_sdo_prom( num_cte );
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_ctes_sin_sdo_prom;
    /* [FIN] EXENCION POR CUMPLIR CON SALDO PROMEDIO MINIMO */

    DROP TABLE tmp_ctes_exentos;
    LET vExisteTMP3 = 0;

    -- Ciclo principal que procesa las cuentas
    FOREACH WITH HOLD
        SELECT num_cte
        INTO vNumCte
        FROM tmp_ctes_sin_sdo_prom
        ORDER BY num_cte ASC
        
        DELETE FROM tmp_ctas_cte;

        /*   EXENCION POR CUENTA INVERSION CRECIENTE   */
        SELECT COUNT(*)
        INTO vCantCtasInversion
        FROM sc_maechq AS chq 
        WHERE chq.num_cte = vNumCte
        AND chq.producto = "1100"
        AND chq.status_cta = '1';
                
        IF vCantCtasInversion > 0 THEN 
            -- si entra aqui, es porque este cte exento, se salta al siguiente
            CONTINUE FOREACH;
        END IF;

        /*         EXENCION POR CUENTA PAGARE          */
        SELECT COUNT(*)
        INTO vCantCtasPagare
        FROM bdinvers:sv_maeinv AS inv 
        WHERE inv.num_cte = vNumCte
        AND inv.cod_instrum = "3000"
        AND inv.status_cta = '1';

        IF vCantCtasPagare > 0 THEN
            -- si entra aqui, es porque este cte exento, se salta al siguiente
            CONTINUE FOREACH;
        END IF; 
    
        /*     EXENCION POR MOVIMIENTO DE PORTABILIDAD DE NOMINA     */
        FOREACH WITH HOLD
            SELECT cuenta, sucursal
            INTO vCuenta, vSucursal
            FROM tmp_ctas_total
            WHERE num_cte = vNumCte

            SELECT COUNT(*) 
            INTO vCantMovHis
            FROM sc_movhis AS mov
            WHERE mov.empresa  = vEmpresa
            AND mov.cuenta = vCuenta
            AND mov.fech_alt BETWEEN vFechaInicial AND vFechaFinal
            AND mov.cancelad <> 'S'
            AND mov.transacc = "0273"
            AND mov.referencia LIKE "%NNNN%";
            
           IF vCantMovHis > 0 THEN
                -- si entra aqui es porque la cuenta exento
                -- se exentan todas las ctas del cte
                DELETE FROM tmp_ctas_cte;
                EXIT FOREACH;

           END IF;

            -- Se revisa tambien la tabla sc_movhis_old cuando el rango de
            -- fechas analizado no se encuentra por completo en la sc_movhis
            IF vFechaInicial < vFechConMovHis THEN
                SELECT COUNT(*)
                INTO vCantMovHisOld
                FROM sc_movhis_old AS mov 
                WHERE mov.empresa  = vEmpresa
                AND mov.cuenta = vCuenta
                AND mov.fech_alt BETWEEN vFechaInicial AND vFechaFinal
                AND mov.cancelad <> 'S'
                AND mov.transacc = "0273"
                AND mov.referencia LIKE "%NNNN%";
                        
                IF vCantMovHisOld > 0 THEN
                    -- si entra aqui es porque la cuenta exento
                    -- se exentan todas las ctas del cte
                    DELETE FROM tmp_ctas_cte;
                    EXIT FOREACH;
                END IF;
            END IF;
            /*  [FIN] EXENCION POR MOVIMIENTO DE PORTABILIDAD DE NOMINA   */

            -- Si llega a este punto, es porque la cta no exento la comision, se
            -- guarda en una tmp a esperar evaluar las demas cuentas del cte
            INSERT INTO tmp_ctas_cte (cuenta, sucursal )
                VALUES ( vCuenta, vSucursal );
        END FOREACH;

        /*     EXENCION POR CARGO RECURRENTE     */
        FOREACH WITH HOLD
            Select cuenta, sucursal
            Into vCuenta, vSucursal
            From tmp_ctas_total
            Where num_cte = vNumCte and producto <> '2500'

            Select count(*)
            Into vCantMovHis
            From bdicheq:sc_movhis
            Where empresa = vEmpresa and cuenta = vCuenta
            and fech_alt Between vFechaInicial and vFechaFinal and cancelad <> 'S'
            and transacc = '1141' and monto_tot >= vParamMontCargo
            Having count(*) > 1;
            
            If vCantMovHis >= 2 Then
                -- Si entra aqui es porque la cuenta exento
                -- Se exentan todas las ctas del cte
                Delete From tmp_ctas_cte;
                Exit Foreach;
            End If;

            -- Se revisa tambien la tabla sc_movhis_old cuando el rango de
            -- fechas analizado no se encuentra por completo en la sc_movhis
            If vFechaInicial < vFechConMovHis Then
                Select count(*)
                Into vCantMovHisOld
                From sc_movhis_old
                Where empresa = vEmpresa and cuenta = vCuenta
                and fech_alt Between vFechaInicial and vFechaFinal and cancelad <> 'S'
                and transacc = '1141' and monto_tot >= vParamMontCargo
                Having count(*) > 1;
                        
                If vCantMovHisOld >= 2 Then
                    -- si entra aqui es porque la cuenta exento
                    -- se exentan todas las ctas del cte
                    Delete From tmp_ctas_cte;
                    Exit Foreach;
                End If;
            End If;

            /*  [FIN] EXENCION POR CARGO RECURRENTE   */

            -- Si llega a este punto, es porque la cta no exento la comision, se
            -- guarda en una tmp a esperar evaluar las demas cuentas del cte
            Insert Into tmp_ctas_cte (cuenta, sucursal )
                Values (vCuenta, vSucursal);
        END FOREACH;

        /*     EXENCION POR PRESTAMO PERSONAL BANCOPPEL     */
        FOREACH WITH HOLD
            Select cuenta, sucursal
            Into vCuenta, vSucursal
            From tmp_ctas_total
            Where num_cte = vNumCte and producto <> '2500'

            Select count(*)
            Into vCantMovHis
            From bdicheq:sc_movhis
            Where empresa = vEmpresa and cuenta = vCuenta
            and fech_alt Between vFechaInicial and vFechaFinal and cancelad <> 'S'
            and transacc = '0548';
            
            If vCantMovHis > 0 Then
                -- Si entra aqui es porque la cuenta exento
                -- Se exentan todas las ctas del cte
                Delete From tmp_ctas_cte;
                Exit Foreach;
            End If;

            -- Se revisa tambien la tabla sc_movhis_old cuando el rango de
            -- fechas analizado no se encuentra por completo en la sc_movhis
            If vFechaInicial < vFechConMovHis Then
                Select count(*)
                Into vCantMovHisOld
                From sc_movhis_old
                Where empresa = vEmpresa and cuenta = vCuenta
                and fech_alt Between vFechaInicial and vFechaFinal and cancelad <> 'S'
                and transacc = '0548';
                        
                If vCantMovHisOld > 0 Then
                    -- si entra aqui es porque la cuenta exento
                    -- se exentan todas las ctas del cte
                    Delete From tmp_ctas_cte;
                    Exit Foreach;
                End If;
            End If;

            /*  [FIN] EXENCION POR PRESTAMO PERSONAL BANCOPPEL   */

            -- Si llega a este punto, es porque la cta no exento la comision, se
            -- guarda en una tmp a esperar evaluar las demas cuentas del cte
            Insert Into tmp_ctas_cte (cuenta, sucursal )
                Values (vCuenta, vSucursal);
        END FOREACH;

        /*     EXENCION POR PRESTAMO PERSONAL COPPEL     */
        FOREACH WITH HOLD
            Select cuenta, sucursal
            Into vCuenta, vSucursal
            From tmp_ctas_total
            Where num_cte = vNumCte and producto <> '2500'

            Select count(*)
            Into vCantMovHis
            From bdicheq:sc_movhis
            Where empresa = vEmpresa and cuenta = vCuenta
            and fech_alt Between vFechaInicial and vFechaFinal and cancelad <> 'S'
            and transacc in('0253', '1667');
            
            If vCantMovHis > 0 Then
                -- Si entra aqui es porque la cuenta exento
                -- Se exentan todas las ctas del cte
                Delete From tmp_ctas_cte;
                Exit Foreach;
            End If;

            -- Se revisa tambien la tabla sc_movhis_old cuando el rango de
            -- fechas analizado no se encuentra por completo en la sc_movhis
            If vFechaInicial < vFechConMovHis Then
                Select count(*)
                Into vCantMovHisOld
                From sc_movhis_old
                Where empresa = vEmpresa and cuenta = vCuenta
                and fech_alt Between vFechaInicial and vFechaFinal and cancelad <> 'S'
                and transacc in('0253', '1667');
                        
                If vCantMovHisOld > 0 Then
                    -- si entra aqui es porque la cuenta exento
                    -- se exentan todas las ctas del cte
                    Delete From tmp_ctas_cte;
                    Exit Foreach;
                End If;
            End If;

            /*  [FIN] EXENCION POR PRESTAMO PERSONAL COPPEL   */

            -- Si llega a este punto, es porque la cta no exento la comision, se
            -- guarda en una tmp a esperar evaluar las demas cuentas del cte
            Insert Into tmp_ctas_cte (cuenta, sucursal )
                Values (vCuenta, vSucursal);
        END FOREACH;

        -- Si llega a este punto, significa que ninguna cta del cte ha exentado
        -- por lo que se guardan en la tabla sc_com_manejo_ctas_a_cobrar
        FOREACH WITH HOLD
            SELECT cuenta, sucursal
            INTO vCuenta, vSucursal
            FROM tmp_ctas_cte
            Group By cuenta, sucursal

            IF vContCtasInsertadas = 0 THEN
                BEGIN WORK;
            END IF;

            LET vContCtasInsertadas = vContCtasInsertadas + 1;

            INSERT INTO sc_com_manejo_ctas_a_cobrar ( cliente, cuenta, sucursal )
                VALUES ( vNumCte, vCuenta, vSucursal );
                    
        END FOREACH;        

        IF vContCtasInsertadas >= 5000 THEN
            LET vContCtasInsertadas = 0;
            COMMIT WORK;
        END IF; 
        
    END FOREACH;

    -- Se valida si hay inserts pendientes de commits
    IF vContCtasInsertadas > 0 THEN
        LET vContCtasInsertadas = 0;
        COMMIT WORK;
    END IF;

    /**************************************************************************/
    /*                       [FIN] PROCESO PRINCIPAL                          */
    /**************************************************************************/
    
    /**************************************************************************/
    /*                         REGISTRO EN BITACORA                           */
    /**************************************************************************/
    -- Obtiene la cantidad de cuentas identificadas
    SELECT COUNT(*)
    INTO vCantCtasIdentificadas
    FROM sc_com_manejo_ctas_a_cobrar
    WHERE cliente <= vUltimoCteHiloActual;
     
    LET vSQL = 'echo "UPDATE sc_bitacora_com_manejo_cta' ||
                ' SET fecha_hora_fin = CURRENT,' ||
                ' status = ''FINALIZADO'',' ||
                ' cuentas_identificadas = ' || vCantCtasIdentificadas ||
                ' WHERE aniomes = ''' || vAnioMes || '''' ||
                ' AND etapa = ''IDENTIFICACION''' ||
                ' AND hilo = ' || vNumHilo ||
                ' AND status = ''EN PROCESO''' ||
                ' AND fecha_hora_ini = ''' || vFechaHoraIni || '''' ||
                ';" > '|| vArchivoSQL;
    SYSTEM vSQL;
    LET vSQL = "chmod 777 " || vArchivoSQL;
    SYSTEM vSQL;
    LET vSQL = "dbaccess bdicheq " || vArchivoSQL;
    SYSTEM vSQL;

    -- Actualiza el registro de totales
    UPDATE sc_bitacora_com_manejo_cta
    SET cuentas_identificadas = 
    ( cuentas_identificadas + vCantCtasIdentificadas )::INTEGER
    WHERE aniomes = vAnioMes
    AND etapa = 'TOTALES';
    /**************************************************************************/
    /*                       [FIN] REGISTRO EN BITACORA                       */
    /**************************************************************************/
    --DROP TABLE tmp_ctas_total;
    DROP TABLE tmp_ctas_cte;
    DROP TABLE tmp_ctes_sin_sdo_prom;
        
    RETURN vCodRet, vErrorInfo;
    END
END PROCEDURE;
CREATE PROCEDURE "informix".sp_nom_gen_ing_ajustado(dt_fecha_generar_mes1 DATE)
RETURNING CHAR(6)
	
	DEFINE	cCodRet CHAR(6);
	DEFINE	v_cuenta VARCHAR(11);
	DEFINE	vInfoErr VARCHAR(100);
	DEFINE	iSqlErr, iIsamErr, i_meses_con_dispersion, i_meses_con_nomina INT;
	DEFINE	m_ingreso_mes1, m_ingreso_mes2, m_ingreso_mes3, m_ingreso_mes4, m_E, m_ingreso_ajustado, m_TotalIngresos, 
		m_IngresoMaximo, m_IngresoMinimo, m_variacion_mes1, m_variacion_mes2, m_variacion_mes3, m_variacion_mes4 MONEY;
	DEFINE 	dt_fecha_generar_mes2, dt_fecha_generar_mes3, dt_fecha_generar_mes4 DATE;
	DEFINE i_porcentaje_ingreso DECIMAL(14,2);
	DEFINE wBegin CHAR(1);
		
	LET cCodRet = '000000';
	LET vInfoErr = '';
	LET i_porcentaje_ingreso = 0.0;
	
	--SET DEBUG FILE TO "/home/e10001525/Incidencia/log_sp_nom_gen_ing_ajustado.sql";
	--TRACE ON;
	
	--_______________________________________________________________________________________________________________________________________
	-- Se ejecuta desde el SP orquestador [bdicheq:sp_nom_gendata_disp(VARCHAR)]
	--_______________________________________________________________________________________________________________________________________
	
	BEGIN
		
		ON EXCEPTION SET iSqlErr, iIsamErr, vInfoErr
			IF iSqlErr <> 0 THEN
			
				IF wBegin = 'S' THEN
				
					ROLLBACK WORK;
					
				END IF;
				
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
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		LET wBegin = 'N';
		LET dt_fecha_generar_mes2 = dt_fecha_generar_mes1 - 1 UNITS MONTH;
		LET dt_fecha_generar_mes3 = dt_fecha_generar_mes1 - 2 UNITS MONTH;
		LET dt_fecha_generar_mes4 = dt_fecha_generar_mes1 - 3 UNITS MONTH;
		
		FOREACH cursor_disp_cte WITH HOLD FOR
			SELECT cuenta, ingresos_netos
			INTO v_cuenta, m_ingreso_mes1
			FROM bdicheq:"informix".sc_nom_disp_cte
			WHERE fecha_pago = dt_fecha_generar_mes1 AND ingresos_netos > 0 AND ingreso_ajustado IS NULL
			
				BEGIN WORK;
				
				LET wBegin = 'S';
			
				LET m_ingreso_ajustado = 0;
				LET i_meses_con_dispersion = 0;
				LET i_meses_con_nomina = 0;
				
				SELECT NVL(ingresos_netos, 0)
				INTO m_ingreso_mes2
				FROM "informix".sc_nom_disp_cte
				WHERE fecha_pago = dt_fecha_generar_mes2 AND cuenta = v_cuenta;
				
				SELECT NVL(ingresos_netos, 0)
				INTO m_ingreso_mes3
				FROM "informix".sc_nom_disp_cte
				WHERE fecha_pago = dt_fecha_generar_mes3 AND cuenta = v_cuenta;
				
				SELECT NVL(ingresos_netos, 0)
				INTO m_ingreso_mes4
				FROM "informix".sc_nom_disp_cte
				WHERE fecha_pago = dt_fecha_generar_mes4 AND cuenta = v_cuenta;
				
				LET i_meses_con_dispersion = 1 + -- En el primer mes siempre hay ingresos ya que es parte de la condicion del cursor
												CASE WHEN m_ingreso_mes2 > 0	THEN 1 ELSE 0 END +
												CASE WHEN m_ingreso_mes3 > 0	THEN 1 ELSE 0 END +
												CASE WHEN m_ingreso_mes4 > 0	THEN 1 ELSE 0 END;
				
				IF i_meses_con_dispersion = 4 THEN
					
					LET m_TotalIngresos = 0;
					LET m_IngresoMaximo = 0;
					LET m_IngresoMinimo = 0;
					
					--Extraer las operaciones para realizarlas afuera del ciclo
					SELECT SUM(ingresos_netos), MAX(ingresos_netos), MIN(ingresos_netos)
					INTO m_TotalIngresos, m_IngresoMaximo, m_IngresoMinimo 
					FROM "informix".sc_nom_disp_cte
					WHERE fecha_pago >= dt_fecha_generar_mes4 AND fecha_pago <= dt_fecha_generar_mes1 AND cuenta = v_cuenta;
					
					LET m_E = (m_TotalIngresos - m_IngresoMaximo - m_IngresoMinimo) / 2;
					
					SELECT valor::DECIMAL(14,2)
					INTO i_porcentaje_ingreso
					FROM "informix".sc_param
					WHERE codparam = 'PorcentIngAjustado';
					
					LET i_porcentaje_ingreso = i_porcentaje_ingreso / 100;

					LET m_variacion_mes1 = ((m_ingreso_mes1 - m_E) / m_ingreso_mes1);
					LET m_variacion_mes2 = ((m_ingreso_mes2 - m_E) / m_ingreso_mes2);
					LET m_variacion_mes3 = ((m_ingreso_mes3 - m_E) / m_ingreso_mes3);
					LET m_variacion_mes4 = ((m_ingreso_mes4 - m_E) / m_ingreso_mes4);
					
					-- Si la variacion es mayor al porcentaje configurado (10% para cuando se lanza este sp) se modifica el ingreso
					IF m_variacion_mes1 > i_porcentaje_ingreso	THEN
						LET m_ingreso_mes1  = m_E * (1 - m_variacion_mes1)::DECIMAL(14,2);
					END IF;
					
					IF m_variacion_mes2 > i_porcentaje_ingreso	THEN
						LET m_ingreso_mes2  = m_E * (1 - m_variacion_mes2)::DECIMAL(14,2);
					END IF;
					
					IF m_variacion_mes3 > i_porcentaje_ingreso	THEN
						LET m_ingreso_mes3  = m_E * (1 - m_variacion_mes3)::DECIMAL(14,2);
					END IF;
					
					IF m_variacion_mes4 > i_porcentaje_ingreso	THEN
						LET m_ingreso_mes4  = m_E * (1 - m_variacion_mes4)::DECIMAL(14,2);
					END IF;
					
					LET m_ingreso_ajustado = m_ingreso_mes1 + m_ingreso_mes2 + m_ingreso_mes3 + m_ingreso_mes4;
					
					-- Restar el ingreso menor y dividir entre tres
					LET m_ingreso_ajustado = (m_ingreso_ajustado - LEAST(m_ingreso_mes1, m_ingreso_mes2, m_ingreso_mes3, m_ingreso_mes4)) / 3;
					
					UPDATE "informix".sc_nom_disp_cte SET
						ingreso_ajustado = m_ingreso_ajustado
					WHERE fecha_pago = dt_fecha_generar_mes1 AND cuenta = v_cuenta;
					
									
					COMMIT WORK;
					
					LET wBegin = 'N';
					
					CONTINUE FOREACH;
					
				END IF;
				
				-- Aplicacion de reglas de temporalidad para meses con dispersion < 4
				LET m_ingreso_mes1 =	CASE
											WHEN MONTH(dt_fecha_generar_mes1) = 5			THEN m_ingreso_mes1 * 0.34
											WHEN MONTH(dt_fecha_generar_mes1) IN (11,12)	THEN m_ingreso_mes1 * 0.61
											ELSE m_ingreso_mes1
										END;
				
				LET m_ingreso_mes2 =	CASE
											WHEN MONTH(dt_fecha_generar_mes2) = 5			THEN NVL(m_ingreso_mes2, 0) * 0.34
											WHEN MONTH(dt_fecha_generar_mes2) IN (11,12)	THEN NVL(m_ingreso_mes2, 0) * 0.61
											ELSE NVL(m_ingreso_mes2, 0)
										END;
				
				LET m_ingreso_mes3 =	CASE
											WHEN MONTH(dt_fecha_generar_mes3) = 5			THEN NVL(m_ingreso_mes3, 0) * 0.34
											WHEN MONTH(dt_fecha_generar_mes3) IN (11,12)	THEN NVL(m_ingreso_mes3, 0) * 0.61
											ELSE NVL(m_ingreso_mes3, 0)
										END;
				
				LET m_ingreso_mes4 =	CASE
											WHEN MONTH(dt_fecha_generar_mes4) = 5			THEN NVL(m_ingreso_mes4, 0) * 0.34
											WHEN MONTH(dt_fecha_generar_mes4) IN (11,12)	THEN NVL(m_ingreso_mes4, 0) * 0.61
											ELSE NVL(m_ingreso_mes4, 0)
										END;
				
				LET i_meses_con_nomina =	CASE
												WHEN NVL(m_ingreso_mes4, 0) > 0																	THEN 4
												WHEN NVL(m_ingreso_mes4, 0) = 0 AND NVL(m_ingreso_mes3, 0) > 0									THEN 3
												WHEN NVL(m_ingreso_mes4, 0) = 0 AND NVL(m_ingreso_mes3, 0) = 0 AND NVL(m_ingreso_mes2, 0) > 0	THEN 2
												WHEN NVL(m_ingreso_mes4, 0) = 0 AND NVL(m_ingreso_mes3, 0) = 0 AND NVL(m_ingreso_mes2, 0) = 0	THEN 1
											END;
				
				LET m_ingreso_ajustado = m_ingreso_mes1 + NVL(m_ingreso_mes2, 0) + NVL(m_ingreso_mes3, 0) + NVL(m_ingreso_mes4, 0);
				
				IF i_meses_con_dispersion = 3 THEN
					
					IF i_meses_con_nomina = 3 THEN
						
						-- Restar el ingreso mayor
						LET m_ingreso_ajustado = m_ingreso_ajustado - GREATEST(m_ingreso_mes1, m_ingreso_mes2, m_ingreso_mes3);
										
						-- Restar el ingreso menor
						LET m_ingreso_ajustado = m_ingreso_ajustado - LEAST(m_ingreso_mes1, m_ingreso_mes2, m_ingreso_mes3);
						
					ELSE
						
						-- Restar el ingreso mayor
						LET m_ingreso_ajustado = m_ingreso_ajustado - GREATEST(m_ingreso_mes1, m_ingreso_mes2, m_ingreso_mes3, m_ingreso_mes4);
						
						LET m_ingreso_ajustado = m_ingreso_ajustado / 2;
						
					END IF;
					
				END IF;
				
				IF i_meses_con_dispersion = 2 THEN
					LET m_ingreso_ajustado = m_ingreso_ajustado / i_meses_con_nomina;
				END IF;
				
				UPDATE "informix".sc_nom_disp_cte SET
					ingreso_ajustado = m_ingreso_ajustado
				WHERE fecha_pago = dt_fecha_generar_mes1 AND cuenta = v_cuenta;
			
				COMMIT WORK;
				
				LET wBegin = 'N';
			
		END FOREACH;
		
	END
	
	RETURN cCodRet;
	
END PROCEDURE
DOCUMENT
'_______________________________________________________________________________________________________________________________',
'CREADO:			Jorge Humberto Quintana Santiesteban',
'FECHA:				28 de enero de 2025',
'BASE DE DATOS:		bdicheq',
'DESCRIPCION:		Proceso para calculo de ingreso ajustado sobre registros de ingresos netos',
'RETORNO:			000000 Proceso Exitoso',
'_______________________________________________________________________________________________________________________________',
'MODIFICADO:		Jesus Adrian Diaz Oorozco',
'FECHA:				15 de octubre de 2025',
'BASE DE DATOS:		bdicheq',
'DESCRIPCION:		Se agrega en codigo la utilizacion de formula para obtener la variacion en los ingresos para la ventana 4 ',
'					meses con 4 dispersion y 4 meses con nomina, ademas se soluciona incidencia en la ventana 3 meses con ',
'					dispesion y 3 meses con nomina, en el cual al existir uno de los 4 meses en cero, al hacer la resta del ',
'					ingreso menor restaba el que estaba en cero ',
'_______________________________________________________________________________________________________________________________',
'MODIFICADO:		Jesus Adrian Diaz Oorozco',
'FECHA:				20 de noviembre de 2025',
'DESCRIPCION:		Se elimina UPDATE STATISTICS',
'_______________________________________________________________________________________________________________________________';

CREATE PROCEDURE "informix".sp_nom_gen_ingnetos(dt_fecha_generar DATE)
RETURNING CHAR(6);
-- DeclaraciÃ³n de las variables

    DEFINE cCodRet CHAR(6);
    DEFINE cInfoErr CHAR(100);

	DEFINE v_numcte, v_id_empresa_nom CHAR(9);
	DEFINE v_cuenta, v_id_cuenta_empresa CHAR(11);

	DEFINE v_deposito1_7, v_deposito8_14, v_deposito15_21, v_deposito22_31, v_deposito1_13, 
		v_deposito14_27, v_deposito28_31, v_conteo_dias_pago, iSqlErr, iIsamErr INT;

    DEFINE v_tipo_transaccion CHAR(15);
	DEFINE v_periodicidad, v_bancoreferencia CHAR(20);
	DEFINE v_fecha_final DATE;
	DEFINE wBegin CHAR(1);
	
    --SET DEBUG FILE TO "/home/e10001202/adriandiaz/prototipo/LOGS/sp_nom_gen_ingnetos.sql";
	--TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
    
    BEGIN
    
        ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
			
			IF wBegin = 'S' THEN
			
				ROLLBACK WORK;
				
			END IF;
		
			DROP TABLE IF EXISTS temp_movs_aux;
			DROP TABLE IF EXISTS temp_movs_max;
			DROP TABLE IF EXISTS temp_movs_final;
				
            IF iSqlErr <> 0 THEN
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
		
		
		LET cCodRet = '000000';
		LET cInfoErr = '';
        
        LET v_fecha_final = dt_fecha_generar + 1 UNITS MONTH;
    
        LET v_conteo_dias_pago = 0;
        LET v_periodicidad = '';
		LET wBegin = 'N';
		
		UPDATE bdicheq:"informix".sc_nom_disp_cte
		SET tipo_transaccion = 	CASE GREATEST(ingresos_emp, ingresos_porta, ingresos_pen, ingresos_sdw)
									WHEN ingresos_pen 	THEN 'PEN'
									WHEN ingresos_emp 	THEN 'EGP'
									WHEN ingresos_porta THEN 'EPB'
									WHEN ingresos_sdw 	THEN 'SDW'
								END,
			periodicidad = 
			CASE
				WHEN conteo_dias_pago >= 20 
					THEN 'D'
				WHEN conteo_dias_pago BETWEEN 4 AND 6 AND deposito1_7 = 1 AND deposito8_14 = 1 AND deposito15_21 = 1 AND deposito22_31 = 1
					THEN 'S'
				WHEN conteo_dias_pago = 3 AND deposito1_13 = 1 AND deposito14_27 = 1 AND deposito28_31 = 1
					THEN 'C'
				WHEN conteo_dias_pago = 2 AND
						SUBSTR(cadena_dia_dispersion, charindex('-', cadena_dia_dispersion) + 1)::INT - 
						SUBSTR(cadena_dia_dispersion, 1, charindex('-', cadena_dia_dispersion) - 1)::INT >= 25 
					THEN 'M'
				WHEN conteo_dias_pago = 2 AND
						SUBSTR(cadena_dia_dispersion, charindex('-', cadena_dia_dispersion) + 1)::INT - 
						SUBSTR(cadena_dia_dispersion, 1, charindex('-', cadena_dia_dispersion) - 1)::INT >= 13 
					THEN 'Q'
				WHEN conteo_dias_pago = 3
						AND SUBSTR(cadena_dia_dispersion, INSTR(cadena_dia_dispersion, '-') + 1, INSTR(cadena_dia_dispersion, '-', INSTR(cadena_dia_dispersion, '-') + 1) - INSTR(cadena_dia_dispersion, '-') - 1)::INT - 
							SUBSTR(cadena_dia_dispersion, 1, charindex('-', cadena_dia_dispersion) - 1)::INT >= 13
						AND SUBSTR(cadena_dia_dispersion, INSTR(cadena_dia_dispersion, '-', INSTR(cadena_dia_dispersion, '-', 1) + 1) + 1) -
							SUBSTR(cadena_dia_dispersion, INSTR(cadena_dia_dispersion, '-') + 1, INSTR(cadena_dia_dispersion, '-', INSTR(cadena_dia_dispersion, '-') + 1) - INSTR(cadena_dia_dispersion, '-') - 1)::INT >= 13
					THEN 'Q'
				WHEN conteo_dias_pago = 1 THEN 'M'
					ELSE 'I'
			END
		WHERE fecha_pago = dt_fecha_generar AND tipo_transaccion IS NULL;
		
		DROP TABLE IF EXISTS temp_movs_aux;
		
		SELECT cuenta, id_empresa_nom , id_cuenta_empresa , bancoreferencia, SUM(monto_tot) AS total_empresa
		FROM bdicheq:"informix".sc_nom_mov_mes M 
		WHERE M.fecha_oper >= dt_fecha_generar AND M.fecha_oper < v_fecha_final AND transacc = '0273'
		GROUP BY cuenta, id_empresa_nom , id_cuenta_empresa , bancoreferencia
		INTO TEMP temp_movs_aux WITH NO LOG;
		
		CREATE INDEX "informix".idx_temp_movs_aux1 ON temp_movs_aux(cuenta, total_empresa)  USING btree;
		
		DROP TABLE IF EXISTS temp_movs_max;
		
		SELECT cuenta, MAX(total_empresa) AS max_total_empresa
		FROM temp_movs_aux
		GROUP BY cuenta
		INTO TEMP temp_movs_max WITH NO LOG;
		
		CREATE INDEX "informix".idx_temp_movs_max1 ON temp_movs_max(cuenta, max_total_empresa)  USING btree;
		
		DROP TABLE IF EXISTS temp_movs_final;
		
		SELECT MA.cuenta, NVL(MA.id_empresa_nom, '') AS id_empresa_nom, NVL(MA.id_cuenta_empresa, '') AS id_cuenta_empresa, NVL(MA.bancoreferencia, '') AS bancoreferencia
		FROM temp_movs_aux MA
		INNER JOIN temp_movs_max MM ON MA.cuenta = MM.cuenta AND MA.total_empresa = MM.max_total_empresa
		INTO TEMP temp_movs_final WITH NO LOG;
		
		DROP TABLE temp_movs_aux;
		DROP TABLE temp_movs_max;
		
		CREATE INDEX "informix".idx_temp_movs_final1 ON temp_movs_final(cuenta)  USING btree;
		
		FOREACH cur_data_dispersion WITH HOLD FOR
			SELECT numcte, cuenta, conteo_dias_pago, tipo_transaccion, deposito1_7, deposito8_14, 
				deposito15_21, deposito22_31, deposito1_13, deposito14_27, deposito28_31
			INTO v_numcte, v_cuenta, v_conteo_dias_pago, v_tipo_transaccion, v_deposito1_7, v_deposito8_14, 
				v_deposito15_21, v_deposito22_31, v_deposito1_13, v_deposito14_27, v_deposito28_31
			FROM bdicheq:"informix".sc_nom_disp_cte 
			WHERE fecha_pago = dt_fecha_generar
			
			BEGIN WORK;
			
			LET wBegin = 'S';
			
			SELECT FIRST 1 id_empresa_nom, id_cuenta_empresa, bancoreferencia INTO v_id_empresa_nom, v_id_cuenta_empresa, v_bancoreferencia FROM temp_movs_final WHERE cuenta = v_cuenta;
			
			UPDATE bdicheq:"informix".sc_nom_disp_cte 
			SET 
				id_empresa_nom = v_id_empresa_nom, 
				id_cuenta_empresa = v_id_cuenta_empresa, 
				bancoreferencia = v_bancoreferencia
			WHERE fecha_pago = dt_fecha_generar AND cuenta = v_cuenta;
			
			COMMIT WORK;
			
			LET wBegin = 'N';
			
		END FOREACH
		
		DROP TABLE temp_movs_final;
		
    END;
    
    RETURN cCodRet;
    
END PROCEDURE
DOCUMENT
'_____________________________________________________________________________________________________________________________________',
'CREADO:      	Jesus Adrian Diaz Orozco',
'FECHA:       	23 de diciembre de 2024',
'DESCRIPCION: 	Generar los ingresos netos de todos los tipos de clientes de nomina en bancoppel (Empleado de GC, Portabilidad, ',
'				Pensionado y Shadow), determinar su segmento y periodicidad',
'Retorno: 000000  Proceso Exitoso',
'_____________________________________________________________________________________________________________________________________',
'MODIFICADO:	Jesus Adrian Diaz Orozco',
'FECHA:       	15 de octubre de 2025',
'DESCRIPCION: 	Se soluciona incidencia al momento de determinar periodicidad Quincenal y Mensual, se hacia de forma incorrecta la',
'				obtencion de diferencia de dias entre cada deposito, lo que provocaba numeros negativos y periodicidades incorrectas',
'______________________________________________________________________________________________________________________________________';

CREATE PROCEDURE "informix".sp_nom_gen_carga_inicial(i_fecha_generar DATE)
RETURNING CHAR(6);
-- DeclaraciÃÂÃÂ³n de las variables

    DEFINE cCodRet CHAR(6);
    DEFINE cInfoErr CHAR(100);

	DEFINE iSqlErr, iIsamErr INT;
	DEFINE esInhabil CHAR(1);
    DEFINE v_dFecha_Final, v_dFecha_Inicial DATE;
	DEFINE v_dt_fecha_bitacora_ini, v_dt_fecha_bitacora_fin DATETIME YEAR TO SECOND;
	
    --SET DEBUG FILE TO "/home/e10001202/adriandiaz/prototipo/LOGS/sp_nom_gen_carga_inicial.out";
	--TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
    
    BEGIN
    
        ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
            IF iSqlErr <> 0 THEN
			
                LET cCodRet = iSqlErr;
                RETURN cCodRet;
				
            END IF;
        END EXCEPTION;
		
		LET esInhabil = '0';
		
		SELECT NVL(MAX(periodo + 1 UNITS DAY), i_fecha_generar)
		INTO v_dFecha_Inicial
		FROM "informix".sc_bitacora_movnom
		WHERE id_proceso = 'movimientos_mes' AND fechahora_fin IS NOT NULL;

		LET v_dFecha_Final = MDY(MONTH(i_fecha_generar), 1, YEAR(i_fecha_generar)) + 1 UNITS MONTH;
		LET v_dFecha_Final = v_dFecha_Final + 6 UNITS DAY;

		WHILE v_dFecha_Inicial < v_dFecha_Final
			
			SELECT DBINFO('utc_to_datetime', sh_curtime) 
			INTO v_dt_fecha_bitacora_ini 
			FROM sysmaster:sysshmvals;
		
			INSERT INTO "informix".sc_bitacora_movnom (id_proceso, periodo, fechahora_inicio, fechahora_fin)
				VALUES ('movimientos_mes', v_dFecha_Inicial, v_dt_fecha_bitacora_ini, NULL);
			
			EXECUTE PROCEDURE bdicheq:"informix".sp_nom_gen_mov_mes(v_dFecha_Inicial) INTO cCodRet;

			IF cCodRet <> '000000' THEN
				RETURN cCodRet;
			END IF;
			
			SELECT DBINFO('utc_to_datetime', sh_curtime) 
			INTO v_dt_fecha_bitacora_fin 
			FROM sysmaster:sysshmvals;
			
			UPDATE "informix".sc_bitacora_movnom SET
				fechahora_fin = v_dt_fecha_bitacora_fin
			WHERE id_proceso = 'movimientos_mes' AND periodo = v_dFecha_Inicial;
			
			LET v_dFecha_Inicial = v_dFecha_Inicial + 1 UNITS DAY;

		END WHILE;

		SELECT DBINFO('utc_to_datetime', sh_curtime) 
		INTO v_dt_fecha_bitacora_ini 
		FROM sysmaster:sysshmvals;
		
		-- Ejecucion de subproceso [ingnetos] {
		INSERT INTO "informix".sc_bitacora_movnom (id_proceso, periodo, fechahora_inicio, fechahora_fin)
			VALUES ('ingnetos', i_fecha_generar, v_dt_fecha_bitacora_ini, NULL);
			
			--TRACE OFF;
		EXECUTE PROCEDURE bdicheq:"informix".sp_nom_gen_ingnetos(i_fecha_generar) INTO cCodRet;
		--TRACE ON;

		IF cCodRet <> '000000' THEN
			RETURN cCodRet;
		END IF;
		
		SELECT DBINFO('utc_to_datetime', sh_curtime) 
		INTO v_dt_fecha_bitacora_fin 
		FROM sysmaster:sysshmvals;
		
		UPDATE "informix".sc_bitacora_movnom SET 
			fechahora_fin = v_dt_fecha_bitacora_fin
		WHERE id_proceso = 'ingnetos' AND periodo = i_fecha_generar;
		-- } fin de ejecucion de subproceso [ingnetos]
		
		SELECT DBINFO('utc_to_datetime', sh_curtime) 
		INTO v_dt_fecha_bitacora_ini 
		FROM sysmaster:sysshmvals;
		
		-- Ejecucion de subproceso [ingajustado] {
		INSERT INTO "informix".sc_bitacora_movnom (id_proceso, periodo, fechahora_inicio, fechahora_fin)
			VALUES ('ingajustado', i_fecha_generar, v_dt_fecha_bitacora_ini, NULL);
		
		--TRACE OFF;
		EXECUTE PROCEDURE "informix".sp_nom_gen_ing_ajustado(i_fecha_generar) INTO cCodRet;
		--TRACE ON;
		
		LET cCodRet = '000000';
		
		IF cCodRet <> '000000' THEN
			RETURN cCodRet;
		END IF;
		
		SELECT DBINFO('utc_to_datetime', sh_curtime) 
		INTO v_dt_fecha_bitacora_fin 
		FROM sysmaster:sysshmvals;
		
		UPDATE "informix".sc_bitacora_movnom SET
			fechahora_fin = v_dt_fecha_bitacora_fin
		WHERE id_proceso = 'ingajustado' AND periodo = i_fecha_generar;
		-- } fin de ejecucion de subproceso [ingajustado]
		
		-- Depuracion de tabla de movimientos para el periodo que se ejecuta			
		DELETE FROM "informix".sc_nom_mov_mes WHERE fecha_oper >= i_fecha_generar AND fecha_oper < i_fecha_generar + 1 UNITS MONTH;
		
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
'Retorno: 000000  Proceso Exitoso',
'_____________________________________________________________________________________________________________________________________',
'MODIFICADO:	Jesus Adrian Diaz Orozco',
'FECHA:       	15 de octubre de 2025',
'DESCRIPCION: 	Se modifica el periodo de movimientos que es procesado durante la carga de un mes, se agrega el procesamiento de los',
'				6 dias del siguiente mes, para abarcar aquellos movimientos que se realizan a finales de mes pero su dtfechavalor es',
'				del mes que se esta procesando																						',
'_____________________________________________________________________________________________________________________________________';

CREATE PROCEDURE "informix".sp_rptctasempresariales(pEmpresa VARCHAR(3))
RETURNING VARCHAR(5);


DEFINE vsql            LVARCHAR(800);
DEFINE vstmt           LVARCHAR(300);
DEFINE desc_err        VARCHAR(80);
DEFINE vcodret3        VARCHAR(80);
DEFINE cRazonSocial    VARCHAR(60);
DEFINE Prazon_social   VARCHAR(60);
DEFINE cCuenta         VARCHAR(20);
DEFINE pCuenta         VARCHAR(20);
DEFINE cNumCte         VARCHAR(20);
DEFINE pNumCte         VARCHAR(20);
DEFINE si_numcte       VARCHAR(20);
DEFINE cFechaDes       VARCHAR(8);
DEFINE cEjecutivo      VARCHAR(8);
DEFINE cAnioMes        VARCHAR(6);
DEFINE vcodret1        VARCHAR(5);
DEFINE vcodret2        VARCHAR(5);
DEFINE vcodret4        VARCHAR(5);
DEFINE cProducto       VARCHAR(4);
DEFINE pProducto       VARCHAR(4);
DEFINE dSdoProm        DECIMAL(16,2);
DEFINE dMtoAbonos      DECIMAL(16,2);
DEFINE dMtoAbonosOld   DECIMAL(16,2);
DEFINE dMtoAbonosHis   DECIMAL(16,2);
DEFINE dMtoCargos      DECIMAL(16,2);
DEFINE dMtoCargosOld   DECIMAL(16,2);
DEFINE dMtoCargosHis   DECIMAL(16,2);
DEFINE dComisiones     DECIMAL(16,2);
DEFINE dSdoDiaAnt      DECIMAL(14,2);
DEFINE pSdoDiaAnt      DECIMAL(14,2);
DEFINE dSdoDiaAntier   DECIMAL(14,2);
DEFINE dIntDiaAntier   DECIMAL(14,2);
DEFINE dcapVigAcum     DECIMAL(14,2);
DEFINE mAcumSdoPos     MONEY(14,2);
DEFINE vexiste         SMALLINT;
DEFINE iDiaSdoPos      SMALLINT;
DEFINE dSdoDiaCum      SMALLINT;
DEFINE vcomienza       SMALLINT;
DEFINE vcomienza1      SMALLINT;
DEFINE vcomienza2      SMALLINT;
DEFINE vcomienza3      SMALLINT;
DEFINE ven_transacc    SMALLINT;
DEFINE ven_transacc1   SMALLINT;
DEFINE ven_transacc2   SMALLINT;
DEFINE ven_transacc3   SMALLINT;
DEFINE num_mes_hoy     SMALLINT;
DEFINE num_mes_busca   SMALLINT;
DEFINE num_mes_sol     SMALLINT;
DEFINE vBuscaTablas    SMALLINT;
DEFINE vcontador       INTEGER;
DEFINE vcontador1      INTEGER;
DEFINE vcontador2      INTEGER;
DEFINE vcontador3      INTEGER;
DEFINE sql_err         INTEGER;
DEFINE isam_err        INTEGER;
DEFINE iNoAbonos       INTEGER;
DEFINE iNoAbonosOld    INTEGER;
DEFINE iNoAbonosHis    INTEGER;
DEFINE iNoCargos       INTEGER;
DEFINE iNoCargosOld    INTEGER;
DEFINE iNoCargosHis    INTEGER;
DEFINE dFechaHoy       DATE;
DEFINE dFechaAnt       DATE;
DEFINE vult_mes_ant    DATE;
DEFINE vpri_mes_ant    DATE;
DEFINE dPriDiaMes      DATE;
DEFINE dFechaAct       DATE;
DEFINE dPriDiaMesAnt   DATE;
DEFINE dUltDiaMesAnt   DATE;
DEFINE dIniMovOld      DATE;
DEFINE dIniMovHis      DATE;


LET dcapVigAcum     = 0;
LET dSdoDiaCum      = 0;
LET vcodret1        = '000';
LET vcodret2        = '';
LET vcodret3        = '';
LET vcodret4        = '';
LET desc_err        = '';
LET vsql            = '';
LET vstmt           = '';
LET dFechaHoy       = '';
LET dFechaAnt       = '';
LET dPriDiaMes      = '';
LET dFechaAct       = '';
LET dPriDiaMesAnt   = '';
LET dUltDiaMesAnt   = '';
LET cAnioMes        = '';
LET cFechaDes       = '';
LET cProducto       = '';
LET pProducto       = '';
LET cCuenta         = '';
LET pCuenta         = '';
LET cEjecutivo      = '';
LET cNumCte         = '';
LET pNumCte         = '';
LET si_numcte       = '';
LET cRazonSocial    = '';
LET Prazon_social   = '';
LET dIniMovOld      = '';
LET dIniMovHis      = '';
LET mAcumSdoPos     = 0.00;
LET dSdoDiaAnt      = 0.00;
LET pSdoDiaAnt      = 0.00;
LET dSdoDiaAntier   = 0.00;
LET dIntDiaAntier   = 0.00;
LET dSdoProm        = 0.00;
LET dMtoAbonos      = 0.00;
LET dMtoAbonosOld   = 0.00;
LET dMtoAbonosHis   = 0.00;
LET dMtoCargos      = 0.00;
LET dMtoCargosOld   = 0.00;
LET dMtoCargosHis   = 0.00;
LET dComisiones     = 0.00;
LET vBuscaTablas    = 0;
LET num_mes_hoy     = 0;
LET num_mes_sol     = 0;
LET num_mes_busca   = 0;
LET sql_err         = 0;
LET isam_err        = 0;
LET vcontador       = 0;
LET vcontador1      = 0;
LET vcontador2      = 0;
LET vcontador3      = 0;
LET vexiste         = 0;
LET iDiaSdoPos      = 0;
LET iNoAbonos       = 0;
LET iNoAbonosOld    = 0;
LET iNoAbonosHis    = 0;
LET iNoCargos       = 0;
LET iNoCargosOld    = 0;
LET iNoCargosHis    = 0;
LET vcomienza       = -1;
LET vcomienza1      = -1;
LET vcomienza2      = -1;
LET vcomienza3      = -1;
LET ven_transacc    = 0;
LET ven_transacc1   = 0;
LET ven_transacc2   = 0;
LET ven_transacc3   = 0;


BEGIN

   ON EXCEPTION SET sql_err, isam_err, desc_err
      SET DEBUG FILE TO "/resplogifx/conciliachq/sp_rptctasempresariales.err";
      TRACE ON;

      IF (sql_err <> 0) THEN
         LET vcodret1 = sql_err;
         LET vcodret2 = isam_err;
         LET vcodret3 = desc_err;

         RETURN vcodret1;

      END IF;
   END EXCEPTION;

   SET ISOLATION TO DIRTY READ;
   SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO "/resplogifx/conciliachq/sp_rptctasempresariales.out";
   --TRACE ON;


   IF pEmpresa IS NULL OR LENGTH(TRIM(pEmpresa)) = 0 THEN
      RETURN '00001';
   END IF;

   SELECT fecha_hoy, fecha_ant, pri_hab_mes, pri_dia_mes - 1 UNITS DAY, pri_dia_mes - 1 UNITS MONTH
     INTO dFechaHoy, dFechaAnt, dPriDiaMes, vult_mes_ant, vpri_mes_ant
     FROM bdicheq:sc_fechas
    WHERE empresa = pEmpresa;

   LET dFechaAct = dFechaHoy;

   -- // VALIDA LA FECHA DE AYER
   LET dFechaHoy = dFechaHoy - 1 UNITS DAY;


   --LET dFechaHoy ='10/04/2025';
   


   CALL sp_valfechabil(dFechaHoy, '-')
   RETURNING vcodret4, dFechaHoy;

   -- // VALIDA LA FECHA DE ANTIER
   LET dFechaAnt = dFechaAnt - 1 UNITS DAY;

   CALL sp_valfechabil(dFechaAnt, '-')
   RETURNING vcodret4, dFechaAnt;


	   -- // CREA TABLA PARA REPORTE DIARIO
	   IF EXISTS (SELECT dbsname, tabname
					FROM sysmaster:systabnames
				   WHERE partnum > 0
					 AND tabname = 'sc_rptctasempresariales') THEN

		  TRUNCATE TABLE bdicheq:sc_rptctasempresariales;
	   ELSE
		  CREATE TABLE bdicheq:sc_rptctasempresariales
			 (
			  fecha           VARCHAR(10),
			  producto        VARCHAR(4),
			  cuenta          VARCHAR(20),
			  ejecutivo       VARCHAR(8),
			  numcte          VARCHAR(20),
			  razon_social    VARCHAR(60),
			  no_abonos       INTEGER,
			  monto_abonos    DECIMAL(16,2),
			  no_cargos       INTEGER,
			  monto_cargos    DECIMAL(16,2),
			  sdo_dia_ant     DECIMAL(14,2),
			  sdo_dia_hoy     DECIMAL(14,2),
			  sdo_promedio    DECIMAL(14,2),
			  comisiones      DECIMAL(14,2)
			 ) IN dbs_datos05 EXTENT SIZE 32 NEXT SIZE 32 LOCK MODE ROW;
		  CREATE INDEX idx_rptctasempresariales_cta ON bdicheq:sc_rptctasempresariales(cuenta) IN dbs_idxinteg ONLINE;
	   END IF;


		  -- // CREA TABLA TEMPORAL PARA OPTIMIZAR CONSULTA 1
	   IF EXISTS (SELECT dbsname, tabname
					FROM sysmaster:systabnames
				   WHERE partnum > 0
					 AND tabname = 'paso_sc_maechq') THEN

		  TRUNCATE TABLE bdicheq:paso_sc_maechq;
	   ELSE
		  CREATE TABLE bdicheq:paso_sc_maechq
			 (
			  producto        VARCHAR(4),
			  cuenta          VARCHAR(20),
			  numcte          VARCHAR(20),
			  razon_social    VARCHAR(60),
			  sdo_dia_ant     DECIMAL(14,2)
			 ) IN dbs_datos05 EXTENT SIZE 32 NEXT SIZE 32 LOCK MODE ROW;
		  CREATE INDEX idx_paso_sc_maechq ON bdicheq:paso_sc_maechq(cuenta) IN dbs_idxinteg ONLINE;
		  
	   END IF;


    FOREACH Cur_Inicial WITH HOLD FOR
      SELECT mae.producto, mae.cuenta, mae.num_cte, cte.razon_social, mae.sdo_dia_ant
        INTO pProducto, pCuenta, pNumCte, Prazon_social, pSdoDiaAnt
        FROM bdicheq:sc_maechq mae, bdinteg:si_cliente cte
       WHERE mae.producto IN ('1200', '1600', '2200', '2600', '2700', '2800', '9901')
         AND mae.status_cta <> '2'
         AND mae.num_cte = cte.numcte

      -- Abre la transaccion
      IF (vcomienza = -1) THEN
         LET vcomienza = 0;
         LET ven_transacc = 1;
         BEGIN WORK;
      END IF;

      INSERT INTO bdicheq:paso_sc_maechq (producto, cuenta, numcte, razon_social, sdo_dia_ant)
           VALUES (pProducto, pCuenta, pNumCte, Prazon_social, pSdoDiaAnt);

      LET vcontador = vcontador + 1;
      --Realiza commit cada 1000 registros

      IF (vcontador >= 1000) THEN
         LET vcontador = 0;
         COMMIT WORK;
         BEGIN WORK;
      END IF;

    END FOREACH;

    UPDATE STATISTICS MEDIUM FOR TABLE bdicheq:paso_sc_maechq;


   --Si la transaccion esta abierta realiza el commit
   IF (ven_transacc = 1) THEN
      LET ven_transacc = 0;
      COMMIT WORK;
   END IF;


   -- // PROCESA REGISTROS DE CUENTAS EMPRESARIALES
    FOREACH Cur_Prin_A WITH HOLD FOR
      SELECT {+INDEX(paso_sc_maechq idx_paso_sc_maechq)}
             mae.producto, mae.cuenta, noc.ejecutivo, mae.numcte, mae.razon_social, noc.acum_sdo_pos,
             noc.dia_sdo_pos, mae.sdo_dia_ant
        INTO cProducto, cCuenta, cEjecutivo, cNumCte, cRazonSocial, mAcumSdoPos, iDiaSdoPos, dSdoDiaAnt
        FROM bdicheq:paso_sc_maechq mae, bdicheq:sc_maenoc noc
       WHERE mae.cuenta = noc.cuenta
         AND noc.fecha_alta <= dFechaHoy


      -- // OBTIENE SALDOS DE ANTIER
      EXECUTE PROCEDURE sp_capintafecha(cCuenta, dFechaAnt)
         INTO vcodret4, dSdoDiaAntier, dIntDiaAntier;

      IF (vcodret4 = '100') THEN
         LET dSdoDiaAntier = 0.00;
         LET dIntDiaAntier = 0.00;
      END IF;

      -- // ABONOS
      SELECT COUNT(*), SUM(mov.monto_tot) INTO iNoAbonos, dMtoAbonos
        FROM bdicheq:sc_movdia_concil mov, bdinteg:si_transacc trx
       WHERE mov.empresa = pEmpresa
         AND mov.cuenta = cCuenta
         AND mov.fech_alt = dFechaHoy
         AND mov.cancelad <> 'S'
         AND mov.transacc = trx.numero
         AND trx.sistema = '01'
         AND trx.se_emite_edocta = 'S'
         AND trx.se_contabiliza = 'S'
         AND trx.naturaleza = 'A';

      IF (iNoAbonos IS NULL) THEN
         LET iNoAbonos = 0;
      END IF;

      IF (dMtoAbonos IS NULL) THEN
         LET dMtoAbonos = 0.00;
      END IF;

      -- // CARGOS
      SELECT COUNT(*), SUM(mov.monto_tot) INTO iNoCargos, dMtoCargos
        FROM bdicheq:sc_movdia_concil mov, bdinteg:si_transacc trx
       WHERE mov.empresa = pEmpresa
         AND mov.cuenta = cCuenta
         AND mov.fech_alt >= dFechaHoy
         AND mov.cancelad <> 'S'
         AND mov.transacc = trx.numero
         AND trx.sistema = '01'
         AND trx.se_emite_edocta = 'S'
         AND trx.se_contabiliza = 'S'
         AND trx.naturaleza = 'C';

      IF (iNoCargos IS NULL) THEN
         LET iNoCargos = 0;
      END IF;

      IF (dMtoCargos IS NULL) THEN
         LET dMtoCargos = 0.00;
      END IF;

      -- // COMISIONES
      SELECT SUM(mov.monto_tot) INTO dComisiones
        FROM bdicheq:sc_movdia_concil mov, bdinteg:si_transacc trx
       WHERE mov.empresa = pEmpresa
         AND mov.cuenta = cCuenta
         AND mov.fech_alt >= dFechaHoy
         AND mov.cancelad <> 'S'
         AND mov.transacc = trx.numero
         AND mov.referencia LIKE 'COM%'
         AND trx.sistema = '01'
         AND trx.se_emite_edocta = 'S'
         AND trx.se_contabiliza = 'S'
         AND trx.naturaleza = 'C';

      IF (dComisiones IS NULL) THEN
         LET dComisiones = 0;
      END IF;

      -- // SALDO PROMEDIO
      IF (iDiaSdoPos > 0) THEN
         LET dSdoProm = mAcumSdoPos / iDiaSdoPos;
      ELSE
         LET dSdoProm = 0.00;
      END IF;

      -- Abre la transaccion
      IF (vcomienza2 = -1) THEN
         LET vcomienza2 = 0;
         LET ven_transacc2 = 1;
         BEGIN WORK;
      END IF;

      -- // GUARDA REGISTRO
      INSERT INTO bdicheq:sc_rptctasempresariales(fecha, producto, cuenta, ejecutivo, numcte, razon_social,
                                                  no_abonos, monto_abonos, no_cargos, monto_cargos, sdo_dia_ant,
                                                  sdo_dia_hoy, sdo_promedio, comisiones)
           VALUES (dFechaHoy, cProducto, cCuenta, cEjecutivo, cNumCte, cRazonSocial, iNoAbonos, dMtoAbonos,
                   iNoCargos, dMtoCargos, dSdoDiaAntier, dSdoDiaAnt, dSdoProm, dComisiones);

      LET vcontador2 = vcontador2 + 1;

      --Realiza commit cada 1000 registros
      IF (vcontador2 >= 1000) THEN
         LET vcontador2 = 0;
         COMMIT WORK;
         BEGIN WORK;
      END IF;

    END FOREACH;

   UPDATE STATISTICS MEDIUM FOR TABLE bdicheq:sc_rptctasempresariales;


   --Si la transaccion esta abierta realiza el commit
   IF (ven_transacc2 = 1) THEN
      LET ven_transacc2 = 0;
      COMMIT WORK;
   END IF;

   -- // DESCARGA ARCHIVO DIARIO
   LET cFechaDes = TO_CHAR(dFechaAct, '%Y%m%d');

   LET vsql = 'echo "UNLOAD TO /resplogifx/conciliachq/rep_cap_emp_diario_'||cFechaDes||'.unl SELECT fecha, producto,Trim(cuenta),'|| 'ejecutivo,Trim(numcte), Trim(razon_social),no_abonos, monto_abonos, no_cargos, monto_cargos, sdo_dia_ant,'||
                'sdo_dia_hoy, sdo_promedio, comisiones FROM sc_rptctasempresariales;" > /resplogifx/conciliachq/rptdiactasemp.sql';

   SYSTEM vsql;

   LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/rptdiactasemp.sql';
   SYSTEM vstmt;

   LET vstmt = 'rm /resplogifx/conciliachq/rptdiactasemp.sql';
   SYSTEM vstmt;
   LET vstmt = '';

	--LET dFechaAct = '10/02/2025';

   -- // REPORTE MENSUAL ( CADA DIA 2 )
   IF LPAD(DAY(dFechaAct),2,'0') = '02' THEN
      -- // CREA TABLA PARA REPORTE MENSUAL

      IF EXISTS (SELECT dbsname, tabname
                   FROM sysmaster:systabnames
                  WHERE partnum > 0
                    AND tabname = 'sc_rptmesctasempresariales') THEN

         TRUNCATE TABLE bdicheq:sc_rptmesctasempresariales;
      ELSE
         CREATE TABLE bdicheq:sc_rptmesctasempresariales
            (
             aniomes         VARCHAR(6),
             producto        VARCHAR(4),
             cuenta          VARCHAR(20),
             ejecutivo       VARCHAR(8),
             numcte          VARCHAR(20),
             razon_social    VARCHAR(60),
             no_abonos       INTEGER,
             monto_abonos    DECIMAL(16,2),
             no_cargos       INTEGER,
             monto_cargos    DECIMAL(16,2),
             sdo_promedio    DECIMAL(16,2)
            ) IN dbs_datos05 EXTENT SIZE 32 NEXT SIZE 32 LOCK MODE ROW;
         CREATE INDEX idx_rptmesctasempresariales_cta ON bdicheq:sc_rptmesctasempresariales(cuenta) IN dbs_idxinteg ONLINE; 
      END IF;

	  -- // OBTIENE FECHAS
      LET dPriDiaMesAnt = dPriDiaMes - 1 UNITS MONTH;
      LET dUltDiaMesAnt = dPriDiaMes - 1 UNITS DAY;
      LET cAnioMes = TO_CHAR(dUltDiaMesAnt, '%Y%m');

      -- // OBTIENE PARAMETROS PARA MOVS HISTORICOS
      SELECT valor INTO dIniMovOld
        FROM bdicheq:sc_param
       WHERE empresa = pempresa
         AND codparam = 'FechIniCon_movhis_ol';

      SELECT valor INTO dIniMovHis
        FROM bdicheq:sc_param
       WHERE empresa = pempresa
         AND codparam = 'fechcon_movhis';


      IF vpri_mes_ant >= dIniMovOld AND vult_mes_ant <= (dIniMovHis -1) THEN
         LET vBuscaTablas = 1;      ---   MovHisOld
      ELSE
         IF vpri_mes_ant >= dIniMovHis AND vult_mes_ant >= (dIniMovHis -1) THEN
            LET vBuscaTablas = 2;   --- MovHis
         ELSE
            LET vBuscaTablas = 3;   --- MovHis & MovHisOld
         END IF;
      END IF;


	   -- // CREA TABLA TEMPORAL paso_sc_maechq2
	   IF EXISTS (SELECT dbsname, tabname
					FROM sysmaster:systabnames
				   WHERE partnum > 0
					 AND tabname = 'paso_sc_maechq2') THEN

		  TRUNCATE TABLE bdicheq:paso_sc_maechq2;
	   ELSE
		CREATE TABLE bdicheq:paso_sc_maechq2
			 (
			  producto        VARCHAR(4),
			  cuenta          VARCHAR(20),
			  ejecutivo       VARCHAR (8),
			  numcte          VARCHAR(20),
			  razon_social    VARCHAR(60)
			 ) IN dbs_datos05 EXTENT SIZE 32 NEXT SIZE 32 LOCK MODE ROW;
		 CREATE INDEX idx_paso_sc_maechq_2 ON bdicheq:paso_sc_maechq2(cuenta) IN dbs_idxinteg ONLINE;
		  --CREATE INDEX idx_paso_sc_maechq1 ON bdicheq:paso_sc_maechq(numcte) ONLINE;
		END IF;


    LET vcomienza       = -1;
    LET ven_transacc    = 0;
	LET vcontador       = 0;

	--CREAMOS UN UNIVERSO CON paso_sc_maechq,sc_maenoc,si_cliente
	FOREACH Cur_B WITH HOLD FOR
      SELECT {+INDEX(paso_sc_maechq idx_paso_sc_maechq)}
                mae.producto, mae.cuenta, noc.ejecutivo, mae.numcte, cte.razon_social
           INTO cProducto, cCuenta, cEjecutivo, cNumCte, cRazonSocial
           FROM bdicheq:paso_sc_maechq mae, bdicheq:sc_maenoc noc, bdinteg:si_cliente cte
          WHERE mae.cuenta = noc.cuenta
            AND mae.numcte = cte.numcte
            

      -- Abre la transaccion
      IF (vcomienza = -1) THEN
         LET vcomienza = 0;
         LET ven_transacc = 1;
         BEGIN WORK;
      END IF;

      INSERT INTO bdicheq:paso_sc_maechq2 (producto, cuenta, ejecutivo,numcte,razon_social)
           VALUES (cProducto, cCuenta, cEjecutivo, cNumCte, cRazonSocial);

      LET vcontador = vcontador + 1;
      --Realiza commit cada 1000 registros

      IF (vcontador >= 1000) THEN
         LET vcontador = 0;
         COMMIT WORK;
         BEGIN WORK;
      END IF;

    END FOREACH;

	 --Si la transaccion esta abierta realiza el commit
	   IF (ven_transacc = 1) THEN
		  LET ven_transacc = 0;
		  COMMIT WORK;
	   END IF;


	UPDATE STATISTICS MEDIUM FOR TABLE bdicheq:paso_sc_maechq2;


      -- // PROCESA REGISTROS DE CUENTAS EMPRESARIALES CON LA SALDO DIARIO
    FOREACH Cur_Prin_C WITH HOLD FOR
        
		SELECT {+INDEX(idx_paso_sc_maechq_2 paso_sc_maechq2)} 
		       scmae2.producto, scmae2.cuenta, scmae2.ejecutivo, scmae2.numcte, scmae2.razon_social, sdo.capvigacum, sdo.diacum
			   INTO cProducto,cCuenta,cEjecutivo,cNumCte,cRazonSocial,dcapVigAcum,dSdoDiaCum
			   FROM paso_sc_maechq2 scmae2, OUTER bdicheq:sc_sdodiarioc sdo
			   WHERE sdo.cuenta = scmae2.cuenta 
               AND sdo.aniomes = cAnioMes
		

         LET dSdoProm = dSdoDiaCum;
         IF dSdoProm > 0 THEN LET dSdoProm = dcapVigAcum / dSdoDiaCum; ELSE LET dSdoProm = 0; END IF;
	

         IF (vBuscaTablas = 1) THEN      --- BÃºsca en MovHisOld
            -- // ABONOS HISTORICO VIEJOS
            SELECT COUNT(*), SUM(mov.monto_tot) INTO iNoAbonosOld, dMtoAbonosOld
              FROM bdicheq:sc_movhis_old mov, bdinteg:si_transacc trx
             WHERE mov.empresa = pEmpresa
               AND mov.cuenta = cCuenta
               AND mov.fech_alt BETWEEN vpri_mes_ant AND vult_mes_ant
               AND mov.cancelad <> 'S'
               AND mov.transacc = trx.numero
               AND trx.sistema = '01'
               AND trx.se_emite_edocta = 'S'
               AND trx.se_contabiliza = 'S'
               AND trx.naturaleza = 'A';

            IF (iNoAbonosOld IS NULL) THEN LET iNoAbonosOld = 0; END IF;
            IF (dMtoAbonosOld IS NULL) THEN LET dMtoAbonosOld = 0.00; END IF;

            -- // CARGOS HISTRICOS VIEJOS
            SELECT COUNT(*), SUM(mov.monto_tot) INTO iNoCargosOld, dMtoCargosOld
              FROM bdicheq:sc_movhis_old mov, bdinteg:si_transacc trx
             WHERE mov.empresa = pEmpresa
               AND mov.cuenta = cCuenta
               AND mov.fech_alt BETWEEN vpri_mes_ant AND vult_mes_ant
               AND mov.cancelad <> 'S'
               AND mov.transacc = trx.numero
               AND trx.sistema = '01'
               AND trx.se_emite_edocta = 'S'
               AND trx.se_contabiliza = 'S'
               AND trx.naturaleza = 'C';

            IF (iNoCargosOld IS NULL) THEN LET iNoCargosOld = 0; END IF;
            IF (dMtoCargosOld IS NULL) THEN LET dMtoCargosOld = 0.00; END IF;
         END IF;

         IF (vBuscaTablas = 2) THEN      --- Busca en MovHis
            -- // ABONOS HISTORICOS
            SELECT COUNT(*), SUM(mov.monto_tot) INTO iNoAbonosHis, dMtoAbonosHis
              FROM bdicheq:sc_movhis mov, bdinteg:si_transacc trx
             WHERE mov.empresa = pEmpresa
               AND mov.cuenta = cCuenta
               AND mov.fech_alt BETWEEN vpri_mes_ant AND vult_mes_ant
               AND mov.cancelad <> 'S'
               AND mov.transacc = trx.numero
               AND trx.sistema = '01'
               AND trx.se_emite_edocta = 'S'
               AND trx.se_contabiliza = 'S'
               AND trx.naturaleza = 'A';

            IF (iNoAbonosHis IS NULL) THEN LET iNoAbonosHis = 0; END IF;
            IF (dMtoAbonosHis IS NULL) THEN LET dMtoAbonosHis = 0.00; END IF;

            LET iNoAbonos = iNoAbonosOld + iNoAbonosHis;
            LET dMtoAbonos = dMtoAbonosOld + dMtoAbonosHis;

            --// CARGOS HISTORICOS
            SELECT COUNT(*), SUM(mov.monto_tot) INTO iNoCargosHis, dMtoCargosHis
              FROM bdicheq:sc_movhis mov, bdinteg:si_transacc trx
             WHERE mov.empresa = pEmpresa
               AND mov.cuenta = cCuenta
               AND mov.fech_alt BETWEEN vpri_mes_ant AND vult_mes_ant
               AND mov.fech_alt >= dIniMovHis
               AND mov.cancelad <> 'S'
               AND mov.transacc = trx.numero
               AND trx.sistema = '01'
               AND trx.se_emite_edocta = 'S'
               AND trx.se_contabiliza = 'S'
               AND trx.naturaleza = 'C';

            IF (iNoCargosHis IS NULL) THEN LET iNoCargosHis = 0; END IF;
            IF (dMtoCargosHis IS NULL) THEN LET dMtoCargosHis = 0.00; END IF;

            LET iNoCargos = iNoCargosOld + iNoCargosHis;
            LET dMtoCargos = dMtoCargosOld + dMtoCargosHis;
         END IF;

         IF (vBuscaTablas = 3) THEN
            FOREACH Cur_MovHisAll WITH HOLD FOR
               -- // ABONOS HISTORICOS
               SELECT COUNT(*), SUM(mov.monto_tot) INTO iNoAbonosOld, dMtoAbonosOld
                 FROM bdicheq:sc_movhis_old mov, bdinteg:si_transacc trx
                WHERE mov.empresa = pEmpresa
                  AND mov.cuenta = cCuenta
                  AND mov.fech_alt BETWEEN vpri_mes_ant AND vult_mes_ant
                  AND mov.cancelad <> 'S'
                  AND mov.transacc = trx.numero
                  AND trx.sistema = '01'
                  AND trx.se_emite_edocta = 'S'
                  AND trx.se_contabiliza = 'S'
                  AND trx.naturaleza = 'A'
               UNION
               SELECT COUNT(*), SUM(mov.monto_tot)
                 FROM bdicheq:sc_movhis mov, bdinteg:si_transacc trx
                WHERE mov.empresa = pEmpresa
                  AND mov.cuenta = cCuenta
                  AND mov.fech_alt BETWEEN vpri_mes_ant AND vult_mes_ant
                  AND mov.cancelad <> 'S'
                  AND mov.transacc = trx.numero
                  AND trx.sistema = '01'
                  AND trx.se_emite_edocta = 'S'
                  AND trx.se_contabiliza = 'S'
                  AND trx.naturaleza = 'A'

               IF (iNoAbonosHis IS NULL) THEN LET iNoAbonosHis = 0; END IF;
               IF (dMtoAbonosHis IS NULL) THEN LET dMtoAbonosHis = 0.00; END IF;

               LET iNoAbonos = iNoAbonosOld + iNoAbonosHis;
               LET dMtoAbonos = dMtoAbonosOld + dMtoAbonosHis;
            END FOREACH;

            --// CARGOS HISTORICOS
            FOREACH Cur_MovHisAll2 WITH HOLD FOR
               SELECT COUNT(*), SUM(mov.monto_tot) INTO iNoCargosHis, dMtoCargosHis
                 FROM bdicheq:sc_movhis mov, bdinteg:si_transacc trx
                WHERE mov.empresa = pEmpresa
                  AND mov.cuenta = cCuenta
                  AND mov.fech_alt BETWEEN vpri_mes_ant AND vult_mes_ant
                  AND mov.cancelad <> 'S'
                  AND mov.transacc = trx.numero
                  AND trx.sistema = '01'
                  AND trx.se_emite_edocta = 'S'
                  AND trx.se_contabiliza = 'S'
                  AND trx.naturaleza = 'C'
                UNION
               SELECT COUNT(*), SUM(mov.monto_tot)
                 FROM bdicheq:sc_movhis_old mov, bdinteg:si_transacc trx
                WHERE mov.empresa = pEmpresa
                  AND mov.cuenta = cCuenta
                  AND mov.fech_alt BETWEEN vpri_mes_ant AND vult_mes_ant
                  AND mov.cancelad <> 'S'
                  AND mov.transacc = trx.numero
                  AND trx.sistema = '01'
                  AND trx.se_emite_edocta = 'S'
                  AND trx.se_contabiliza = 'S'
                  AND trx.naturaleza = 'C'

               IF (iNoCargosHis IS NULL) THEN LET iNoCargosHis = 0; END IF;
               IF (dMtoCargosHis IS NULL) THEN LET dMtoCargosHis = 0.00; END IF;

               LET iNoCargos = iNoCargosOld + iNoCargosHis;
               LET dMtoCargos = dMtoCargosOld + dMtoCargosHis;
            END FOREACH;
         END IF;

         -- // VALIDA SALDO PROMEDIO
         IF (dSdoProm IS NULL) THEN
            LET dSdoProm = 0.00;
         END IF;

         -- Abre la transaccion
         IF (vcomienza3 = -1) THEN
            LET vcomienza3 = 0;
            LET ven_transacc3 = 1;
            BEGIN WORK;
         END IF;

         -- // GUARDA REGISTRO
         INSERT INTO bdicheq:sc_rptmesctasempresariales(aniomes, producto, cuenta, ejecutivo, numcte, razon_social,
                                                        no_abonos, monto_abonos, no_cargos, monto_cargos, sdo_promedio)
              VALUES (cAnioMes, cProducto, cCuenta, cEjecutivo, cNumCte, cRazonSocial, iNoAbonos,
                      dMtoAbonos, iNoCargos, dMtoCargos, dSdoProm);

         LET vcontador3 = vcontador3 + 1;

         --Realiza commit cada 1000 registros
         --IF (vcontador3 >= 1000) THEN
		 IF (vcontador3 >= 1) THEN
            LET vcontador3 = 0;
            COMMIT WORK;
            BEGIN WORK;
         END IF;

    END FOREACH;
	  
	   --Si la transaccion esta abierta realiza el commit
      IF (ven_transacc3 = 1) THEN
         LET ven_transacc3 = 0;
         COMMIT WORK;
      END IF;


      UPDATE STATISTICS MEDIUM FOR TABLE bdicheq:sc_rptmesctasempresariales;

      -- // DESCARGA ARCHIVO MENSUAL
      LET vsql = 'echo "UNLOAD TO /resplogifx/conciliachq/rep_cap_emp_mensual_'||cAnioMes||'.unl SELECT aniomes, producto,'||
	  'Trim(cuenta), ejecutivo, Trim(numcte), Trim(razon_social),no_abonos, monto_abonos,'||
	  'no_cargos, monto_cargos, sdo_promedio FROM sc_rptmesctasempresariales;" > /resplogifx/conciliachq/rptmenctasemp.sql';

      SYSTEM vsql;

      LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/rptmenctasemp.sql';
      SYSTEM vstmt;

      LET vstmt = 'rm /resplogifx/conciliachq/rptmenctasemp.sql';
      SYSTEM vstmt;

   END IF;

END;

RETURN vcodret1;

END PROCEDURE;
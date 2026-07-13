CREATE PROCEDURE "informix".spconciliarfaltantevscontabilidad ( p_iConsulta INTEGER, p_dFechaInicial DATE, p_dFechaFinal DATE) 
	RETURNING	CHAR(5)     AS CodigoRetorno, 
				CHAR(16)    AS estatus,
				DATE        AS fechafaltante,
				CHAR(12)    AS auxiliar,
				MONEY(10,0) AS saldoinicial_faltante,
				MONEY(10,0) AS cargosdia_faltante,
				MONEY(10,0) AS abonosdia_faltante,
				MONEY(10,0) AS saldofinal_faltante,
				DATE        AS fechacontable,
				MONEY(10,0) AS saldoinicial_contable,
				MONEY(10,0) AS cargosdia_contable,
				MONEY(10,0) AS abonosdia_contable,
				MONEY(10,0) AS saldofinal_contable,
				MONEY(10,0) AS variacion;

	DEFINE iSqlErr							INTEGER;
	--VARIABLES DE RETORNO
	DEFINE sCodRet							CHAR(5);
	DEFINE sEstatus							CHAR(16);
	DEFINE dFechaFaltante					DATE;
	DEFINE sAuxiliar						CHAR(12);
	DEFINE mSaldoInicialFaltante			MONEY(10,0);
	DEFINE mCargosDiaFaltante				MONEY(10,0);
	DEFINE mAbonosDiaFaltante				MONEY(10,0);
	DEFINE mSaldoFinalFaltante				MONEY(10,0);
	DEFINE dFechaContable					DATE;
	DEFINE mSaldoInicialContable			MONEY(10,0);
	DEFINE mCargosDiaContable				MONEY(10,0);
	DEFINE mAbonosDiaContable				MONEY(10,0);
	DEFINE mSaldoFinalContable				MONEY(10,0);
	DEFINE mVariacion						MONEY(10,0);

	--VARIABLES PARA MANEJO DE LAS TRANSACCIONES
	DEFINE sEmpresa							CHAR(3);
	DEFINE sTransaccionReasignacionFaltante	CHAR(4);
	DEFINE sTransaccionQuebrantoFaltante	CHAR(4);
	DEFINE sTransaccionReversoAsigFaltante	CHAR(4);
	DEFINE sTransaccionRegistroFaltante		CHAR(4);
	DEFINE sTransaccionEliminacionFaltante	CHAR(4);
	DEFINE sTransaccionRecuperacionFaltante	CHAR(4);
	DEFINE sTransaccionLiquidacionFaltante	CHAR(4);

	--SET DEBUG FILE TO  "spconciliarfaltantevscontabilidad.out"; 
	--TRACE ON;

	BEGIN
		ON EXCEPTION
			SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET sCodRet = iSqlErr;
				INSERT INTO bdirech:rec_errores(descripcion) VALUES ('scfvsc'|| iSqlErr);
				RETURN sCodRet, '', '', '', '', '', '', '', '', '', '', '', '', '';
			END IF;
		END EXCEPTION;

		--// VALIDA PARÁMETROS DE ENTRADA
		IF p_iConsulta NOT IN(0, 1, 2) OR  NVL(p_dFechaInicial, '') = '' OR  NVL(p_dFechaFinal, '') = '' THEN
			LET sCodRet = '00001';
			RETURN sCodRet, '', '', '', '', '', '', '', '', '', '', '', '', '';
		END IF;

		LET sEmpresa = '001';
		LET sCodRet  = '00002';
		LET sTransaccionReasignacionFaltante	= '0050';
		LET sTransaccionRecuperacionFaltante	= '0051';
		LET sTransaccionLiquidacionFaltante 	= '0052';
		LET sTransaccionQuebrantoFaltante		= '0053';
		LET sTransaccionReversoAsigFaltante		= '0058';
		LET sTransaccionRegistroFaltante		= '0017';
		LET sTransaccionEliminacionFaltante		= '0018';

		--TODAS
		IF p_iConsulta = 0 THEN

		--SUCURSAL
		LET sEstatus = 'SUCURSAL';
			
			SELECT  auxiliar,  fecharegistro
			  FROM bdirech:'informix'.rec_movfaltante
			 WHERE transaccion IN (sTransaccionReasignacionFaltante,--'0050'
					sTransaccionQuebrantoFaltante,--'0053'
					sTransaccionReversoAsigFaltante,--'0058'
					sTransaccionRegistroFaltante,--'0017'
					sTransaccionEliminacionFaltante)--'0018'
				AND tipomovimiento IN('C', 'A', 'R','D')
				AND fecharegistro BETWEEN p_dFechaInicial AND p_dFechaFinal
				AND auxiliar   = auxiliar
				AND idrecupera = idrecupera
			 GROUP BY 1, 2
			  INTO TEMP temp_suc WITH NO LOG;
			
			INSERT INTO temp_suc
			SELECT b.auxiliar, b.mes_dia
              FROM bdicont:'informix'.co_histdiasaux b , temp_suc a 
             WHERE empresa = '001'
			   AND mes_dia   between p_dFechaInicial AND p_dFechaFinal
			   AND ccmayor   = '1402' AND ccsub = '05' AND ccsubsub = '03' 
			   AND ccssubsub = '04' AND ccsssubsub = '01' AND sector = '00'
			   AND ciudad   <> '900'
			   AND sucursal IS  NOT NULL
               AND b.auxiliar = a.auxiliar
			   AND moneda    = '01'
               AND (cargos_dia > 0 OR abonos_dia > 0)
			 GROUP BY b.auxiliar, b.mes_dia;
			 
			 SELECT mes_dia, auxiliar,
							 NVL(saldo_inicio_dia, 0) AS saldo_inicio_dia , 
							 NVL(cargos_dia, 0) AS cargos_dia, 
							 NVL(abonos_dia, 0) AS abonos_dia, 
							 NVL(saldo_fin_de_dia, 0) AS saldo_fin_de_dia
				FROM bdicont:'informix'.co_histdiasaux
				WHERE empresa = sEmpresa
				AND mes_dia   between p_dFechaInicial AND p_dFechaFinal
				AND ccmayor   = '1402' AND ccsub = '05' AND ccsubsub = '03' AND ccssubsub = '04' AND ccsssubsub = '01' AND sector = '00'
				AND ciudad   <> '900'
				AND sucursal IS  NOT NULL
				AND auxiliar IN (SELECT auxiliar  FROM temp_suc GROUP BY 1)
				AND moneda    = '01'
				INTO TEMP co_histdiasaux_suc WITH NO LOG;

			CREATE INDEX informix.idx01co_histdiasaux_suc ON informix.co_histdiasaux_suc(mes_dia,auxiliar);
			UPDATE STATISTICS MEDIUM FOR TABLE co_histdiasaux_suc;	

			--PARA CADA AUXILIAR DE LAS TRANSACCIONES PARA LA CONCILIACIÓN DE SUCURSAL
			FOREACH
				SELECT auxiliar,  fecharegistro
				  INTO sAuxiliar, dFechaFaltante
				  FROM temp_suc
				 GROUP BY 1, 2
				 ORDER BY 1, 2
			
				LET sCodRet = '00000';

				----Cargos para calcular el saldo inicial del faltante
				SELECT NVL( SUM(montomovimiento), 0)
				INTO mCargosDiaFaltante
				FROM 'informix'.rec_movfaltante
				WHERE transaccion IN(sTransaccionRegistroFaltante)--'0017'
				AND tipomovimiento IN('C','D','F')
				AND fecharegistro < dFechaFaltante
				AND auxiliar   = sAuxiliar
				AND idrecupera = idrecupera;

				--Abonos para calcular el saldo inicial del faltante
				SELECT NVL( SUM(montomovimiento), 0)
				INTO mAbonosDiaFaltante
				FROM 'informix'.rec_movfaltante
				WHERE transaccion IN(	sTransaccionReasignacionFaltante,--'0050'
										sTransaccionEliminacionFaltante)--'0018'
				AND tipomovimiento IN('A', 'R')
				AND fecharegistro < dFechaFaltante
				AND auxiliar   = sAuxiliar;

				LET mSaldoInicialFaltante = mCargosDiaFaltante - mAbonosDiaFaltante;

				--Cargos de la fecha del movimiento del faltante
				SELECT NVL( SUM(montomovimiento), 0)
				INTO mCargosDiaFaltante
				FROM 'informix'.rec_movfaltante
				WHERE transaccion IN(sTransaccionRegistroFaltante) --'0017'
				AND tipomovimiento IN('C', 'D','F')
				AND fecharegistro = dFechaFaltante
				AND auxiliar   = sAuxiliar
				AND idrecupera = idrecupera;				
				

				--Abonos de la fecha del movimiento del faltante
				SELECT NVL( SUM(montomovimiento), 0)
				INTO mAbonosDiaFaltante
				FROM 'informix'.rec_movfaltante
				WHERE transaccion IN(	sTransaccionReasignacionFaltante,--'0050'
										sTransaccionEliminacionFaltante)--'0018'
				AND tipomovimiento IN('A', 'R')
				AND fecharegistro  = dFechaFaltante
				AND auxiliar    = sAuxiliar;

				LET mSaldoFinalFaltante = (mSaldoInicialFaltante + mCargosDiaFaltante) - mAbonosDiaFaltante;

				--Se obtienen los datos de la contabilidad para la conciliación
				SELECT LIMIT 1 mes_dia, NVL(saldo_inicio_dia, 0), NVL(cargos_dia, 0), NVL(abonos_dia, 0), NVL(saldo_fin_de_dia, 0)
				INTO dFechaContable, mSaldoInicialContable, mCargosDiaContable, mAbonosDiaContable, mSaldoFinalContable
				FROM bdicont:'informix'.co_histdiasaux_suc
				WHERE mes_dia   = dFechaFaltante
				AND auxiliar  = sAuxiliar;

				IF dFechaContable IS NULL THEN
					LET dFechaContable = MDY(1, 1, 1900);
				END IF;

				LET mVariacion = mSaldoFinalContable - mSaldoFinalFaltante;

				IF NOT(mSaldoInicialFaltante = 0 AND mCargosDiaFaltante = 0 AND mAbonosDiaFaltante = 0) THEN
					RETURN sCodRet, sEstatus, dFechaFaltante, sAuxiliar, mSaldoInicialFaltante,
						mCargosDiaFaltante, mAbonosDiaFaltante, mSaldoFinalFaltante, dFechaContable,
						mSaldoInicialContable, mCargosDiaContable, mAbonosDiaContable, mSaldoFinalContable, mVariacion WITH RESUME;
				END IF;
			END FOREACH;
			
			DROP TABLE temp_suc;
			DROP TABLE co_histdiasaux_suc;
			
		--RRHH
		LET sEstatus = 'RRHH';
			
			SELECT  auxiliar,  fecharegistro
			  FROM bdirech:'informix'.rec_movfaltante
			 WHERE transaccion IN (sTransaccionReasignacionFaltante,--'0050'
								   sTransaccionRecuperacionFaltante,--'0051'
								   sTransaccionLiquidacionFaltante,--'0052'
								   sTransaccionQuebrantoFaltante,--'0053'
								   sTransaccionReversoAsigFaltante)
			   AND tipomovimiento IN('A', 'R')
			   AND fecharegistro BETWEEN p_dFechaInicial AND p_dFechaFinal
			   AND auxiliar   = auxiliar
			   AND idrecupera = idrecupera
			 GROUP BY 1, 2
			  INTO TEMP temp_rrhh WITH NO LOG;

			INSERT INTO temp_rrhh
			SELECT b.auxiliar, b.mes_dia
              FROM bdicont:'informix'.co_histdiasaux b , temp_rrhh a 
             WHERE empresa = '001'
			   AND mes_dia   between p_dFechaInicial AND p_dFechaFinal
			   AND ccmayor   = '1402' AND ccsub = '05' AND ccsubsub = '03' 
			   AND ccssubsub = '11' AND ccsssubsub = '01' AND sector = '00'
			   AND ciudad   IS NOT NULL
			   AND sucursal = '9103'
               AND b.auxiliar = a.auxiliar
			   AND moneda    = '01'
               AND (cargos_dia > 0 OR abonos_dia > 0)
			 GROUP BY b.auxiliar, b.mes_dia;
			 
			 SELECT mes_dia, auxiliar,
							 NVL(saldo_inicio_dia, 0) AS saldo_inicio_dia , 
							 NVL(cargos_dia, 0) AS cargos_dia, 
							 NVL(abonos_dia, 0) AS abonos_dia, 
							 NVL(saldo_fin_de_dia, 0) AS saldo_fin_de_dia
				FROM bdicont:'informix'.co_histdiasaux
				WHERE empresa = sEmpresa
				AND mes_dia   between p_dFechaInicial AND p_dFechaFinal
				AND ccmayor   = '1402' AND ccsub = '05' AND ccsubsub = '03' AND ccssubsub = '11' AND ccsssubsub = '01' AND sector = '00'
				AND ciudad   IS NOT NULL
				AND sucursal = '9103' --CC RRHH
				AND auxiliar IN (SELECT auxiliar  FROM temp_rrhh GROUP BY 1)
				AND moneda    = '01'
				INTO TEMP co_histdiasaux_rrhh WITH NO LOG;
				
			CREATE INDEX informix.idx01co_histdiasaux_rrhh ON informix.co_histdiasaux_rrhh(mes_dia,auxiliar);
			UPDATE STATISTICS MEDIUM FOR TABLE co_histdiasaux_rrhh;	

			--PARA CADA AUXILIAR DE LAS TRANSACCIONES PARA LA CONCILIACIÓN DE RECURSOS HUMANOS
			FOREACH
				SELECT auxiliar,  fecharegistro
				  INTO sAuxiliar, dFechaFaltante
				  FROM temp_rrhh
				 GROUP BY 1, 2
				 ORDER BY 1, 2
				
				LET sCodRet = '00000';

				----Cargos para calcular el saldo inicial del faltante
				SELECT NVL( SUM(montomovimiento), 0)
				INTO mCargosDiaFaltante
				FROM 'informix'.rec_movfaltante
				WHERE transaccion  = sTransaccionReasignacionFaltante--'0050'
				AND tipomovimiento = 'R'
				AND fecharegistro  < dFechaFaltante
				AND auxiliar    = sAuxiliar
				AND idrecupera IN (2,6)
				AND contable    = '1';

				--Abonos para calcular el saldo inicial del faltante
				SELECT NVL( SUM(montomovimiento), 0)
				INTO mAbonosDiaFaltante
				FROM 'informix'.rec_movfaltante
				WHERE transaccion IN(	sTransaccionRecuperacionFaltante,--'0051'
										sTransaccionLiquidacionFaltante)--'0052'
				AND tipomovimiento = 'A'
				AND fecharegistro  < dFechaFaltante
				AND auxiliar   = sAuxiliar
				AND idrecupera IN (2,6) 
				AND contable   = '1';

				LET mSaldoInicialFaltante = mCargosDiaFaltante - mAbonosDiaFaltante;

					--Cargos de la fecha del movimiento del faltante
					SELECT NVL( SUM(montomovimiento), 0)
					INTO mCargosDiaFaltante
					FROM 'informix'.rec_movfaltante
					WHERE transaccion  = sTransaccionReasignacionFaltante--'0050'
					AND tipomovimiento = 'R'
					AND fecharegistro  = dFechaFaltante
					AND auxiliar    = sAuxiliar
					AND idrecupera IN(2,6)
					AND contable    = '1';

					--Abonos de la fecha del movimiento del faltante
					SELECT NVL( SUM(montomovimiento), 0)
					INTO mAbonosDiaFaltante
					FROM 'informix'.rec_movfaltante
					WHERE transaccion IN(	sTransaccionRecuperacionFaltante,--'0051'
											sTransaccionLiquidacionFaltante)--'0052'
					AND tipomovimiento = 'A'
					AND fecharegistro  = dFechaFaltante
					AND auxiliar   = sAuxiliar
					AND idrecupera IN (2,6) 
					AND contable   = '1';

				LET mSaldoFinalFaltante = (mSaldoInicialFaltante + mCargosDiaFaltante) - mAbonosDiaFaltante;

				--Se obtienen los datos de la contabilidad para la conciliación
				SELECT LIMIT 1 mes_dia, NVL(saldo_inicio_dia, 0), NVL(cargos_dia, 0), NVL(abonos_dia, 0), NVL(saldo_fin_de_dia, 0)
				INTO dFechaContable, mSaldoInicialContable, mCargosDiaContable, mAbonosDiaContable, mSaldoFinalContable
				FROM bdicont:'informix'.co_histdiasaux_rrhh
				WHERE mes_dia   = dFechaFaltante
				AND auxiliar  = sAuxiliar;
				
				IF dFechaContable IS NULL THEN
					LET dFechaContable = MDY(1, 1, 1900);
				END IF;
				
				--Se obtiene la variacion de los saldos para el movimiento
				LET mVariacion = mSaldoFinalContable - mSaldoFinalFaltante;

				IF NOT(mSaldoInicialFaltante = 0 AND mCargosDiaFaltante = 0 AND mAbonosDiaFaltante = 0) THEN
					RETURN sCodRet, sEstatus, dFechaFaltante, sAuxiliar, mSaldoInicialFaltante,
							mCargosDiaFaltante, mAbonosDiaFaltante, mSaldoFinalFaltante, dFechaContable,
							mSaldoInicialContable, mCargosDiaContable, mAbonosDiaContable, mSaldoFinalContable, mVariacion WITH RESUME;
				END IF;
			END FOREACH;
			
			DROP TABLE temp_rrhh;
			DROP TABLE co_histdiasaux_rrhh;
			
		
		--SOLO SUCURSAL
		ELIF p_iConsulta = 1 THEN
			LET sEstatus = 'SUCURSAL';
			
			SELECT  auxiliar,  fecharegistro
			  FROM bdirech:'informix'.rec_movfaltante
			 WHERE transaccion IN (sTransaccionReasignacionFaltante,--'0050'
					sTransaccionQuebrantoFaltante,--'0053'
					sTransaccionReversoAsigFaltante,--'0058'
					sTransaccionRegistroFaltante,--'0017'
					sTransaccionEliminacionFaltante)--'0018'
				AND tipomovimiento IN('C', 'A', 'R','D')
				AND fecharegistro BETWEEN p_dFechaInicial AND p_dFechaFinal
				AND auxiliar   = auxiliar
				AND idrecupera = idrecupera
			 GROUP BY 1, 2
			  INTO TEMP temp_suc WITH NO LOG;
			
			INSERT INTO temp_suc
			SELECT b.auxiliar, b.mes_dia
              FROM bdicont:'informix'.co_histdiasaux b , temp_suc a 
             WHERE empresa = '001'
			   AND mes_dia   between p_dFechaInicial AND p_dFechaFinal
			   AND ccmayor   = '1402' AND ccsub = '05' AND ccsubsub = '03' 
			   AND ccssubsub = '04' AND ccsssubsub = '01' AND sector = '00'
			   AND ciudad   <> '900'
			   AND sucursal IS  NOT NULL
               AND b.auxiliar = a.auxiliar
			   AND moneda    = '01'
               AND (cargos_dia > 0 OR abonos_dia > 0)
			 GROUP BY b.auxiliar, b.mes_dia;
			 
			 SELECT mes_dia, auxiliar,
							 NVL(saldo_inicio_dia, 0) AS saldo_inicio_dia , 
							 NVL(cargos_dia, 0) AS cargos_dia, 
							 NVL(abonos_dia, 0) AS abonos_dia, 
							 NVL(saldo_fin_de_dia, 0) AS saldo_fin_de_dia
				FROM bdicont:'informix'.co_histdiasaux
				WHERE empresa = sEmpresa
				AND mes_dia   between p_dFechaInicial AND p_dFechaFinal
				AND ccmayor   = '1402' AND ccsub = '05' AND ccsubsub = '03' AND ccssubsub = '04' AND ccsssubsub = '01' AND sector = '00'
				AND ciudad   <> '900'
				AND sucursal IS  NOT NULL
				AND auxiliar IN (SELECT auxiliar  FROM temp_suc GROUP BY 1)
				AND moneda    = '01'
				INTO TEMP co_histdiasaux_suc WITH NO LOG;

			CREATE INDEX informix.idx01co_histdiasaux_suc ON informix.co_histdiasaux_suc(mes_dia,auxiliar);
			UPDATE STATISTICS MEDIUM FOR TABLE co_histdiasaux_suc;	

			--PARA CADA AUXILIAR DE LAS TRANSACCIONES PARA LA CONCILIACIÓN DE SUCURSAL
			FOREACH
				SELECT auxiliar,  fecharegistro
				  INTO sAuxiliar, dFechaFaltante
				  FROM temp_suc
				 GROUP BY 1, 2
				 ORDER BY 1, 2
			
				LET sCodRet = '00000';

				----Cargos para calcular el saldo inicial del faltante
				SELECT NVL( SUM(montomovimiento), 0)
				INTO mCargosDiaFaltante
				FROM 'informix'.rec_movfaltante
				WHERE transaccion IN(sTransaccionRegistroFaltante)--'0017'
				AND tipomovimiento IN('C','D','F')
				AND fecharegistro < dFechaFaltante
				AND auxiliar   = sAuxiliar
				AND idrecupera = idrecupera;

				--Abonos para calcular el saldo inicial del faltante
				SELECT NVL( SUM(montomovimiento), 0)
				INTO mAbonosDiaFaltante
				FROM 'informix'.rec_movfaltante
				WHERE transaccion IN(	sTransaccionReasignacionFaltante,--'0050'
										sTransaccionEliminacionFaltante)--'0018'
				AND tipomovimiento IN('A', 'R')
				AND fecharegistro < dFechaFaltante
				AND auxiliar   = sAuxiliar;

				LET mSaldoInicialFaltante = mCargosDiaFaltante - mAbonosDiaFaltante;

				--Cargos de la fecha del movimiento del faltante
				SELECT NVL( SUM(montomovimiento), 0)
				INTO mCargosDiaFaltante
				FROM 'informix'.rec_movfaltante
				WHERE transaccion IN(sTransaccionRegistroFaltante) --'0017'
				AND tipomovimiento IN('C', 'D','F')
				AND fecharegistro = dFechaFaltante
				AND auxiliar   = sAuxiliar
				AND idrecupera = idrecupera;				
				

				--Abonos de la fecha del movimiento del faltante
				SELECT NVL( SUM(montomovimiento), 0)
				INTO mAbonosDiaFaltante
				FROM 'informix'.rec_movfaltante
				WHERE transaccion IN(	sTransaccionReasignacionFaltante,--'0050'
										sTransaccionEliminacionFaltante)--'0018'
				AND tipomovimiento IN('A', 'R')
				AND fecharegistro  = dFechaFaltante
				AND auxiliar    = sAuxiliar;

				LET mSaldoFinalFaltante = (mSaldoInicialFaltante + mCargosDiaFaltante) - mAbonosDiaFaltante;

				--Se obtienen los datos de la contabilidad para la conciliación
				SELECT LIMIT 1 mes_dia, NVL(saldo_inicio_dia, 0), NVL(cargos_dia, 0), NVL(abonos_dia, 0), NVL(saldo_fin_de_dia, 0)
				INTO dFechaContable, mSaldoInicialContable, mCargosDiaContable, mAbonosDiaContable, mSaldoFinalContable
				FROM bdicont:'informix'.co_histdiasaux_suc
				WHERE mes_dia   = dFechaFaltante
				AND auxiliar  = sAuxiliar;

				IF dFechaContable IS NULL THEN
					LET dFechaContable = MDY(1, 1, 1900);
				END IF;

				LET mVariacion = mSaldoFinalContable - mSaldoFinalFaltante;

				IF NOT(mSaldoInicialFaltante = 0 AND mCargosDiaFaltante = 0 AND mAbonosDiaFaltante = 0) THEN
					RETURN sCodRet, sEstatus, dFechaFaltante, sAuxiliar, mSaldoInicialFaltante,
						mCargosDiaFaltante, mAbonosDiaFaltante, mSaldoFinalFaltante, dFechaContable,
						mSaldoInicialContable, mCargosDiaContable, mAbonosDiaContable, mSaldoFinalContable, mVariacion WITH RESUME;
				END IF;
			END FOREACH;
			
			DROP TABLE temp_suc;
			DROP TABLE co_histdiasaux_suc;

		--SOLO RECURSOS HUMANOS
		ELIF p_iConsulta = 2 THEN
		
			LET sEstatus = 'RRHH';
			
			SELECT  auxiliar,  fecharegistro
			  FROM bdirech:'informix'.rec_movfaltante
			 WHERE transaccion IN (sTransaccionReasignacionFaltante,--'0050'
								   sTransaccionRecuperacionFaltante,--'0051'
								   sTransaccionLiquidacionFaltante,--'0052'
								   sTransaccionQuebrantoFaltante,--'0053'
								   sTransaccionReversoAsigFaltante)
			   AND tipomovimiento IN('A', 'R')
			   AND fecharegistro BETWEEN p_dFechaInicial AND p_dFechaFinal
			   AND auxiliar   = auxiliar
			   AND idrecupera = idrecupera
			 GROUP BY 1, 2
			  INTO TEMP temp_rrhh WITH NO LOG;

			INSERT INTO temp_rrhh
			SELECT b.auxiliar, b.mes_dia
              FROM bdicont:'informix'.co_histdiasaux b , temp_rrhh a 
             WHERE empresa = '001'
			   AND mes_dia   between p_dFechaInicial AND p_dFechaFinal
			   AND ccmayor   = '1402' AND ccsub = '05' AND ccsubsub = '03' 
			   AND ccssubsub = '11' AND ccsssubsub = '01' AND sector = '00'
			   AND ciudad   IS NOT NULL
			   AND sucursal = '9103'
               AND b.auxiliar = a.auxiliar
			   AND moneda    = '01'
               AND (cargos_dia > 0 OR abonos_dia > 0)
			 GROUP BY b.auxiliar, b.mes_dia;
			 
			 SELECT mes_dia, auxiliar,
							 NVL(saldo_inicio_dia, 0) AS saldo_inicio_dia , 
							 NVL(cargos_dia, 0) AS cargos_dia, 
							 NVL(abonos_dia, 0) AS abonos_dia, 
							 NVL(saldo_fin_de_dia, 0) AS saldo_fin_de_dia
				FROM bdicont:'informix'.co_histdiasaux
				WHERE empresa = sEmpresa
				AND mes_dia   between p_dFechaInicial AND p_dFechaFinal
				AND ccmayor   = '1402' AND ccsub = '05' AND ccsubsub = '03' AND ccssubsub = '11' AND ccsssubsub = '01' AND sector = '00'
				AND ciudad   IS NOT NULL
				AND sucursal = '9103' --CC RRHH
				AND auxiliar IN (SELECT auxiliar  FROM temp_rrhh GROUP BY 1)
				AND moneda    = '01'
				INTO TEMP co_histdiasaux_rrhh WITH NO LOG;
				
			CREATE INDEX informix.idx01co_histdiasaux_rrhh ON informix.co_histdiasaux_rrhh(mes_dia,auxiliar);
			UPDATE STATISTICS MEDIUM FOR TABLE co_histdiasaux_rrhh;	

			--PARA CADA AUXILIAR DE LAS TRANSACCIONES PARA LA CONCILIACIÓN DE RECURSOS HUMANOS
			FOREACH
				SELECT auxiliar,  fecharegistro
				  INTO sAuxiliar, dFechaFaltante
				  FROM temp_rrhh
				 GROUP BY 1, 2
				 ORDER BY 1, 2
				
				LET sCodRet = '00000';

				----Cargos para calcular el saldo inicial del faltante
				SELECT NVL( SUM(montomovimiento), 0)
				INTO mCargosDiaFaltante
				FROM 'informix'.rec_movfaltante
				WHERE transaccion  = sTransaccionReasignacionFaltante--'0050'
				AND tipomovimiento = 'R'
				AND fecharegistro  < dFechaFaltante
				AND auxiliar    = sAuxiliar
				AND idrecupera IN (2,6)
				AND contable    = '1';

				--Abonos para calcular el saldo inicial del faltante
				SELECT NVL( SUM(montomovimiento), 0)
				INTO mAbonosDiaFaltante
				FROM 'informix'.rec_movfaltante
				WHERE transaccion IN(	sTransaccionRecuperacionFaltante,--'0051'
										sTransaccionLiquidacionFaltante)--'0052'
				AND tipomovimiento = 'A'
				AND fecharegistro  < dFechaFaltante
				AND auxiliar   = sAuxiliar
				AND idrecupera IN (2,6) 
				AND contable   = '1';

				LET mSaldoInicialFaltante = mCargosDiaFaltante - mAbonosDiaFaltante;

					--Cargos de la fecha del movimiento del faltante
					SELECT NVL( SUM(montomovimiento), 0)
					INTO mCargosDiaFaltante
					FROM 'informix'.rec_movfaltante
					WHERE transaccion  = sTransaccionReasignacionFaltante--'0050'
					AND tipomovimiento = 'R'
					AND fecharegistro  = dFechaFaltante
					AND auxiliar    = sAuxiliar
					AND idrecupera IN(2,6)
					AND contable    = '1';

					--Abonos de la fecha del movimiento del faltante
					SELECT NVL( SUM(montomovimiento), 0)
					INTO mAbonosDiaFaltante
					FROM 'informix'.rec_movfaltante
					WHERE transaccion IN(	sTransaccionRecuperacionFaltante,--'0051'
											sTransaccionLiquidacionFaltante)--'0052'
					AND tipomovimiento = 'A'
					AND fecharegistro  = dFechaFaltante
					AND auxiliar   = sAuxiliar
					AND idrecupera IN (2,6) 
					AND contable   = '1';

				LET mSaldoFinalFaltante = (mSaldoInicialFaltante + mCargosDiaFaltante) - mAbonosDiaFaltante;

				--Se obtienen los datos de la contabilidad para la conciliación
				SELECT LIMIT 1 mes_dia, NVL(saldo_inicio_dia, 0), NVL(cargos_dia, 0), NVL(abonos_dia, 0), NVL(saldo_fin_de_dia, 0)
				INTO dFechaContable, mSaldoInicialContable, mCargosDiaContable, mAbonosDiaContable, mSaldoFinalContable
				FROM bdicont:'informix'.co_histdiasaux_rrhh
				WHERE mes_dia   = dFechaFaltante
				AND auxiliar  = sAuxiliar;
				
				IF dFechaContable IS NULL THEN
					LET dFechaContable = MDY(1, 1, 1900);
				END IF;
				
				--Se obtiene la variacion de los saldos para el movimiento
				LET mVariacion = mSaldoFinalContable - mSaldoFinalFaltante;

				IF NOT(mSaldoInicialFaltante = 0 AND mCargosDiaFaltante = 0 AND mAbonosDiaFaltante = 0) THEN
					RETURN sCodRet, sEstatus, dFechaFaltante, sAuxiliar, mSaldoInicialFaltante,
							mCargosDiaFaltante, mAbonosDiaFaltante, mSaldoFinalFaltante, dFechaContable,
							mSaldoInicialContable, mCargosDiaContable, mAbonosDiaContable, mSaldoFinalContable, mVariacion WITH RESUME;
				END IF;
			END FOREACH;
			
			DROP TABLE temp_rrhh;
			DROP TABLE co_histdiasaux_rrhh;
			
		END IF;

		IF sCodRet = '00002' THEN
			RETURN sCodRet, '', '', '', '', '', '', '', '', '', '', '', '', '';
		END IF;
		
	END
END PROCEDURE;
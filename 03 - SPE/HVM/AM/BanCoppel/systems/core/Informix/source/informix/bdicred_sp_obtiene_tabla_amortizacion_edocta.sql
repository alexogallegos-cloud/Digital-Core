CREATE PROCEDURE "informix".sp_obtiene_tabla_amortizacion_edocta( pEmpresa CHAR(3))
	RETURNING   CHAR(6)         AS Codigo; 		  	-- CODIGO DE RETORNO


	-- VARIABLES PARA RETORNO DE DATOS --
	DEFINE cCodRet     			CHAR(6); 			-- CODIGO DE RETORNO DE ERROR
	DEFINE iPeriodo				INTEGER;			-- PERIODO ACTUAL PARA PP
	DEFINE iCicloRtc 			INTEGER;   			-- PERIODO ACTUAL PARA RTC
	DEFINE dtFechaCouta			DATE;				-- FECHA DEL PAGO PARA PP
	DEFINE dtFecha_Alta       	DATE;				-- FECHA DEL PAGO PARA RTC
	DEFINE dSdoInicial			MONEY(14,2);		-- SALDO INICIAL
	DEFINE dMensualidad			DECIMAL(18,6);		-- MENSUALIDAD
	DEFINE dIntereses			MONEY(14,2);		-- INTERESES
	DEFINE dIvaInt				DECIMAL(14,2);		-- IVA DE INTERESES
	DEFINE dCapital				MONEY(14,2);		-- CAPITAL
	DEFINE dSdoFinal			DECIMAL(18,6);		-- SALDO FINAL
	DEFINE iDiasPeriodo			INTEGER;			-- DIAS DEL PERIODO
	DEFINE dtFechaAper			DATE;				-- FECHA DE APERTURA
	DEFINE dPlazoAux      		DECIMAL(18,6);		-- NUMERO DE MESES PAGO
	DEFINE dMtoContrato      	DECIMAL(18,2);		-- MONTO CONTRATADO PARA PP
	DEFINE dEnganchePag      	DECIMAL(18,2);		-- ENGANCHE PAGADO DE LA RTC
	DEFINE dMtoTotalaPagar      DECIMAL(18,2);		-- MONTO TOTAL A PAGAR PARA PP Y RTC
	DEFINE cTasaFija      		CHAR(6);			-- TASA DE INTERES FIJA ANUAL PARA PP Y RTC
	DEFINE dTasaFija      		DECIMAL(18,2);		-- TASA DE INTERES FIJA ANUAL PARA PP Y RTC
	DEFINE dTotLiqpp 			DECIMAL(18,2);   	-- TOTAL LIQUIDACION PARA PRESTAMO
	DEFINE dTotLiqRtc 			DECIMAL(18,2);   	-- TOTAL LIQUIDACION PARA REESCTRUCTURA
	DEFINE dTotAhorro  			DECIMAL(18,2);		-- MONTO DE TE AHORRARIAS
	DEFINE cCadena1      		CHAR(3);
	DEFINE cCadena2      		CHAR(6);
	DEFINE cCadena3      		CHAR(6);
	-- VARIABLES AUXILIARES PARA PRESTAMO/REESTRUCTURA/CREDINOMINA
	DEFINE iSqlErr      		INTEGER;			-- CODIGO DE ERROR
	DEFINE dTasa				DECIMAL(18,6);		-- TASA ANUAL
	DEFINE dTasa_Mora			DECIMAL(18,6);		-- TASA ANUAL MORATORIA	
	DEFINE iContador 			INTEGER; 			-- PARA CONTROLAR LAS INTERACIONES DEL CICLO
	DEFINE cProducto     		CHAR(4);			-- NUMERO DEL PRODUCTO
	DEFINE dCapacidadPres		DECIMAL(18,6); 		-- CAPACIDAD DE PAGO DEL CLIENTE
	DEFINE iDiaPago      		INTEGER;			-- DIA DE PAGO
	DEFINE iPagosRealizados 	INTEGER;			-- NUMERO DE PAGOS REALIZADO
	DEFINE dIva              	MONEY(14,2);		-- IVA DE SUCURSAL
	-- VARIABLES AUXILIARES PARA PRESTAMO
	DEFINE dtFechaInicial		DATE;				-- FECHA QUE SE TOMA COMO INICIO PARA CALCULAR LAS DEMAS FECHAS
	DEFINE dtFechaAnt			DATE;				-- FECHA ANTERIOR DE COUTA
	DEFINE dTasaInt 			DECIMAL(18,6);		-- TASA DE INTERES
	DEFINE dtFechaCoutaAux		DATE;				-- FECHA DEL PAGO AUXILIAR
	DEFINE cFrecuencia     		CHAR(1);			-- FECUENCIA DEL PAGO
	DEFINE dMontoAut 			DECIMAL(18,6); 		-- MONTO DEL CREDITO
	DEFINE dPlazo  	 			DECIMAL(18,6);		-- PLAZO EN MESES PARA PAGAR
	-- VARIABLES AUXILIARES PARA REESTRUCTURA
	DEFINE dtFechaIniRtc		DATE;				-- FECHA CUOTA DE LA PRIMERA MENSUALIDAD
	DEFINE dtFechaActual		DATE;				-- FECHA DEL CAMPO  fecha_hoy DE LA TABLA sd_fechas
	DEFINE dSobreTasa			DECIMAL(18,2);		-- TASA ANUAL
	DEFINE cDias_Cal_Int    	CHAR(10);			-- DIAS PARA EL CALCULO DE INTERESES
	DEFINE cFactor_SobreTasa 	CHAR(1);			-- FACTOR SOBRE TASA
	DEFINE dTasa_IntDiario      DECIMAL(10,6);		-- TASA DE INTERES DIARIO
	DEFINE dTasa_Interes    	DECIMAL(9,6);		-- TASA DE INTERES
	DEFINE sPlazoMax			SMALLINT;			-- PLAZO MAXIMO
	-- VARIABLES PARA EL PROCEDIMIENTO sp_ofi_consultasdos
	DEFINE cCod_Ret2 			CHAR(6);			-- CODIGO DE RETORNO
	DEFINE cMensaje 			CHAR(80);  	  		-- MENSAJE DE RETORNO
	DEFINE cNumCred				CHAR(20); 	  		-- NUMERO DE CREDITO
	DEFINE cNumProd				CHAR(4); 	  		-- NUMERO DEL PRODUCTO
	DEFINE cDescProd			CHAR(40);      		-- DESCRIPCION DEL PRODUCTO
	DEFINE cNumCte				CHAR(20);      		-- NUMERO DE CLIENTE
	DEFINE cNomCte				CHAR(150);			-- NOMBRE DEL CLIENTE
	DEFINE dMtoLinea			DECIMAL(18,2);		-- MONTO DE LINEA OTORGADA
	DEFINE cStatus 				CHAR (60); 			-- ESATUS DEL CREDITO
	DEFINE dtProximo 			DATE;				-- FECHA DEL PROXIMO PAGO
	DEFINE dtFecha 				DATE; 				-- FECHA DEL PAGO
	DEFINE dSaldo				DECIMAL(18,2); 		-- SALDO DEL CREDITO
	DEFINE mInteres 			DECIMAL(18,2);   	-- INTERESES DEL CREDITO
	DEFINE dIvaInt2				DECIMAL(18,2);   	-- IVA DE INTERESES DEL CREDITO
	DEFINE mTotal 				DECIMAL(18,2);  	-- MONTO TOTAL DEL CREDITO
	DEFINE mPagos 				DECIMAL(18,2);      -- MONTO DE PAGO DEL CREDITO
	DEFINE mMinimo 				DECIMAL(18,2);   	-- MONTO DE PAGO MINIMO DEL CREDITO
	DEFINE mSaldar 				DECIMAL(18,2); 		-- MONTO DE TOTAL DE LIQUIDACION
	DEFINE dAhorro  			DECIMAL(18,2);		-- MONTO DE AHORRO DEL CREDITO
	DEFINE mDeuda 				DECIMAL(18,2);   	-- MONTO DE DEUDA DEL CREDITO
	DEFINE mPagReal				DECIMAL(18,2);   	-- MONTO DE PAGO REAL DEL CREDITO
	DEFINE mIntDeven			DECIMAL(18,2);   	-- INTERESES DEVENGADOS DEL CREDITO
	DEFINE dIvaIntDeven			DECIMAL(18,2);  	-- IVA DE INTERES DEVENGADOS DEL CREDITO
	DEFINE mComision 			DECIMAL(18,2);   	-- MONTO DE COMISION DEL CREDITO
	DEFINE mIvaCom 				DECIMAL(18,2);   	-- IVA DE COMISION DEL CREDITO
	DEFINE mMonto 				DECIMAL(18,2);   	-- MONTO DEL CREDITO
	DEFINE iPagos 				INTEGER;       		-- NUMERO DE PAGOS DEL CREDITO
	DEFINE iPlazo 				INTEGER;   			-- NUMERO DE PLAZOS DEL CREDITO
	DEFINE cCodRetTDif			CHAR(6);			-- COD RETORNO TASAS DIFERENCIADAS
	DEFINE dfechahoy 			DATE;
	DEFINE vfechahoy 			DATE;
	DEFINE vMesAnt				DATE;
	DEFINE vAnioAnt				DATE;
	DEFINE dSum_capital DECIMAL(18,2); 
	DEFINE	dSum_intereses DECIMAL(18,2); 
	DEFINE	dSum_iva_intereses DECIMAL(18,2); 
	DEFINE	dSum_pagomin DECIMAL(18,2); 
	DEFINE  pNumCred CHAR(12);
	DEFINE cAmortiza INTEGER;
	DEFINE cBandera INTEGER;
	DEFINE pSucursal CHAR(4);
	DEFINE dMesesadicionales  INTEGER;
	DEFINE dFecha_vencim DATE;
	DEFINE dInteresesAcum MONEY(14,2);
	DEFINE sSdo_debe MONEY(14,2);
	DEFINE sSdo_pagado MONEY(14,2);
	DEFINE psaldoInteresApoyo DECIMAL(18,2);
	DEFINE psaldoIvaApoyo DECIMAL(18,2);
	DEFINE dSdoAdeudTotal  DECIMAL(18,2);
	DEFINE pProporcion  DECIMAL(18,2);
	DEFINE dUltimopago  DECIMAL(18,2);
	DEFINE dUlt_interes  DECIMAL(18,2);
	DEFINE dUltiva  DECIMAL(18,2);
	DEFINE dInt_restante  DECIMAL(18,2);
	DEFINE dInteres_sumar  DECIMAL(18,2);
	DEFINE dIva_sumar  DECIMAL(18,2);
	DEFINE pFinal_intreses  DECIMAL(18,2);
	DEFINE pFinal_iva	  DECIMAL(18,2);
	DEFINE DFinal_montopago  DECIMAL(18,2);
	DEFINE dUltpago_capital  DECIMAL(18,2);
	DEFINE dInteresesN DECIMAL(18,2);
	DEFINE dIvaIntN DECIMAL(18,2);
	DEFINE dMensualidadN DECIMAL(18,2);
	DEFINE dSdoAdeudTotal_liquidar DECIMAL(18,2);

	
	-- VARIABLES PARA RETORNO DE DATOS
	LET cCodRet     			= '000000';
	LET iPeriodo				= 0;
	LET iCicloRtc				= 0;
	LET dtFechaCouta			= DATE(1);
	LET dtFecha_Alta			= DATE(1);
	LET dSdoInicial				= 0;
	LET dMensualidad			= 0;
	LET dIntereses				= 0;
	LET dIvaInt					= 0;
	LET dCapital				= 0;
	LET dSdoFinal				= 0;
	LET iDiasPeriodo			= 0;
	LET dtFechaAper				= DATE(1);
	LET dPlazoAux      			= 0;
	LET dMtoContrato      		= 0;
	LET dEnganchePag			= 0;
	LET dMtoTotalaPagar      	= 0;
	LET dTasaFija				= 0;
	LET dTotLiqpp 				= 0;
	LET dTotLiqRtc 				= 0;
	LET dTotAhorro  			= 0;
	-- VARIABLES AUXILIARES PARA PRESTAMO/REESTRUCTURA/CREDINOMINA
	LET iSqlErr      			= 0;
	LET dTasa					= 0;
	LET dTasa_Mora				= 0;
	LET iContador 				= 0;
	LET cProducto     			= '';
	LET dCapacidadPres			= 0;
	LET iDiaPago      			= 0;
	LET iPagosRealizados 		= 0;
	LET dIva              		= 0;
	-- VARIABLES AUXILIARES PARA PRESTAMO
	LET dtFechaInicial			= DATE(1);
	LET dtFechaAnt				= DATE(1);
	LET dTasaInt 				= DATE(1);
	LET dtFechaCoutaAux			= DATE(1);
	LET cFrecuencia     		= '';
	LET dMontoAut 				= 0;
	LET dPlazo  	 			= 0;
	-- VARIABLES AUXILIARES PARA REESTRUCTURA
	LET dtFechaActual			= DATE(1);
	LET dtFechaIniRtc			= DATE(1);
	LET dSobreTasa				= 0;
	LET cDias_Cal_Int    		= '';
	LET cFactor_SobreTasa 		= '';
	LET dTasa_IntDiario     	= 0;
	LET dTasa_Interes    		= 0;
	LET sPlazoMax				= 0;
	-- VARIABLES PARA EL PROCEDIMIENTO sp_ofi_consultasdos
	LET cCod_Ret2 				= '000000';
	LET cMensaje 				= '';
	LET cNumCred				= '';
	LET cNumProd				= '';
	LET cDescProd				= '';
	LET cNumCte					= '';
	LET cNomCte					= '';
	LET dMtoLinea				= 0;
	LET cStatus 				= '';
	LET dtProximo 				= DATE(1);
	LET dtFecha 				= DATE(1);
	LET dSaldo					= 0;
	LET mInteres 				= 0;
	LET dIvaInt2				= 0;
	LET mTotal 					= 0;
	LET mPagos 					= 0;
	LET mMinimo 				= 0;
	LET mSaldar 				= 0;
	LET dAhorro  				= 0;
	LET mDeuda 					= 0;
	LET mPagReal				= 0;
	LET mIntDeven				= 0;
	LET dIvaIntDeven			= 0;
	LET mComision 				= 0;
	LET mIvaCom 				= 0;
	LET mMonto 					= 0;
	LET iPagos 					= 0;
	LET iPlazo 					= 0;
	LET cCodRetTDif				= '';
	LET dfechahoy				= DATE(1);
	LET vfechahoy				= DATE(1);
	LET vMesAnt					= DATE(1);
	LET vAnioAnt				= DATE(1);
	LET dSum_capital 			= 0;
	LET	dSum_intereses 			= 0;
	LET	dSum_iva_intereses 		= 0;
	LET	dSum_pagomin 			= 0;
	LET pNumCred				= '';
	LET cAmortiza = 0;
	LET cBandera = 0;
	LET pSucursal = '';
	LET dMesesadicionales = 0;
	LET dFecha_vencim = DATE(1);
	LET dInteresesAcum =  0;
	LET sSdo_debe = 0;
	LET sSdo_pagado =  0;
	LET psaldoInteresApoyo = 0;
	LET psaldoIvaApoyo = 0;
	LET dSdoAdeudTotal   = 0;
	LET pProporcion   = 0;
	LET dUltimopago  = 0;
	LET dUlt_interes   = 0;
	LET dUltiva   = 0;
	LET dInt_restante  = 0;
	LET dInteres_sumar  = 0;
	LET dIva_sumar   = 0;
	LET pFinal_intreses   = 0;
	LET pFinal_iva	   = 0;
	LET DFinal_montopago   = 0;
	LET dUltpago_capital  = 0;
	LET dInteresesN  = 0;
	LET dIvaIntN  = 0;
	LET dMensualidadN  = 0;
	LET dSdoAdeudTotal_liquidar  = 0;

	BEGIN

		ON EXCEPTION  SET iSqlErr
			IF iSqlErr <> 0  THEN
				LET  cCodRet  = iSqlErr;
				RETURN NVL(cCodRet,'');
			END IF;
		END  EXCEPTION

--		SET DEBUG FILE TO '/home/sysaccapp4/cobranza/rqi21402/home/sysaccapp4/cobranza/rqi21402/sp_obtiene_tabla_amortizacion.out';
--		TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT fecha_hoy - 1 units day, fecha_hoy - 1 UNITS MONTH, fecha_hoy - 1 UNITS YEAR ---SE COMENTA PARA PRUEBAS
			INTO vfechahoy, vMesAnt, vAnioAnt
		FROM bdicred:"informix".sd_fechas;
		
		-- Si los dÃ­as son FESTIVOS 25 de Dic y 1 de Ene
		IF (MONTH(vfechahoy) = 12 AND DAY(vfechahoy) = 25) THEN 
			LET dfechahoy = MDY(MONTH(vfechahoy),24,YEAR(vfechahoy));
		ELIF (LPAD(MONTH(vfechahoy),2,0) = 1 AND LPAD(DAY(vfechahoy),2,0) = 1) THEN 
			LET dfechahoy = MDY(MONTH(vMesAnt),31,YEAR(vAnioAnt));
		ELSE
			LET dfechahoy = vfechahoy;
		END IF;
		
		--LET dfechahoy = MDY(10,29,2020);
		--RQI 27 231 Se contemplan productos 9100 y 9300 para impresion de tabla de amortiza en Edo Cta
			FOREACH
					 SELECT  a.num_credito
							  INTO pNumCred
							  FROM "informix".sd_encabezado_edoctacrd a
							 WHERE  a.fecha_emision = dfechahoy
							   --AND a.empresa = pempresa
								AND a.num_producto IN ('6300','7600','7700','6800','9100','9300')
								AND a.ind_tabla_amortizacion = 1

								
					-- SE OBTIENEN LOS PARAMETROS PARA VALIDAR EL MONTO Y EL PLAZO DEL CREDITO,
					--INCLUYE EL ENGANCHE PAGADO DE LA REESTRUCTURA
					SELECT plazo, periodo_plazo,fecha_apertura,
						num_producto,valor_preferencial,tasa_interes::CHAR(6),sucursal,fecha_vencim
					INTO dPlazo,cFrecuencia,dtFechaCouta,
						cProducto,dEnganchePag,cTasaFija, pSucursal,dFecha_vencim
					FROM "informix".sd_maecredcrd
					WHERE empresa = pEmpresa AND num_credito = pNumCred
					AND status_cred IN ('AA','E1');
					
					IF NVL(cProducto,'') = '' THEN
						--LET cCodRet = '001042';
						CONTINUE FOREACH;
					END IF;
					
					INSERT INTO "informix".sd_amortizacion_creditoedoctacrd (
							fecha_emision ,num_credito ,monto_ahorro ,num_periodo ,fecha_pago ,pago_capital, intereses  ,iva_intereses ,monto_pago  ,
							saldo_insoluto ,sum_capital ,sum_intereses ,sum_iva_intereses  ,sum_pagomin  )
					VALUES(dfechahoy,pNumCred, 0.00,0,dtFechaCouta ,0.00,0.00,0.00,
							0.00,0.00,0.00,0.00,0.00,0.00);
					LET dTotAhorro = 0.00;
					--SE TOMA COMO REFERENCIA LA FECHA DE APERTURA PARA PP
					LET dtFechaCoutaAux = dtFechaCouta;

					--SI ES CREDINOMINA RESPETA RESPETA LA FECHA ACTUAL
					SELECT fecha_hoy
					INTO dtFechaActual
					FROM "informix".sd_fechas
					WHERE empresa = pEmpresa ;

					-- CONSULTA SALDO INICIAL PARA PP Y RTC, MONTO DE TOTAL A PAGAR PARA PRESTAMO PERSONAL
					SELECT  sdo_cap_insoluto,mto_capitalizado
					INTO  dSdoInicial,dMtoTotalaPagar
					FROM "informix".sd_maesdoscrd
					WHERE num_credito = pNumCred
					AND empresa = pEmpresa;

					
	   
					--NUMERO DE PAGOS REALIZADOS
					SELECT COUNT(num_credito)
					INTO iPagosRealizados
					FROM "informix".sd_amortiza_creditocrd
					WHERE empresa = pEmpresa
					AND num_credito = pNumCred
					AND capital_status = '5';

					-- SE OBTIENE EL I.V.A
					SELECT valor
					INTO dIva
					FROM "informix".sd_param
					WHERE empresa = '001'
					AND cod_param = '12';

					-- SE OBTIENE LA TASA ANUAL
					
					SELECT a.factor_sobretasa, a.sobretasa, plazo_max_cred
					  INTO cFactor_SobreTasa,  dSobreTasa, sPlazoMax
					  FROM "informix".sd_definicion a
					 WHERE a.num_producto = cProducto;
					
					LET dTasa = cTasaFija; -- Calculo de intereses diarios se hace en base a la tasa del credito ya que varia por credito.
					
					
					--MONTO DE LA MENSUALIDAD
					--OBTIENE LA FECHA CUOTA PARA LA PRIMERA MENSUALIDAD
					SELECT capital_mto_cuota,fecha_cuota
					INTO dCapacidadPres,dtFechaIniRtc
					FROM "informix".sd_amortiza_creditocrd
					WHERE num_credito = pNumCred
					AND  num_pago = 1;
					
					
						--TASA DE INTERES FIJA ANUAL
						IF NVL(cTasaFija,'') <> '' THEN
							LET cCadena1 = SUBSTR(cTasaFija, 0, INSTR(cTasaFija, '.')-1);
							LET cCadena2 = (cTasaFija - cCadena1); 
							LET cCadena2 = SUBSTR(cCadena2, 3, INSTR(cCadena2, '.')-1);
							LET cTasaFija = TRIM(cCadena1)  || '.' || TRIM(cCadena2);
							LET dTasaFija = NVL(TRIM(cTasaFija)::DECIMAL(18,2),0);
						END IF;
						
						--plazo origen del prÃÂ©stamo
						LET iPlazo = dPlazo;
						
					---se revisa si es programa de apoyo.	
						SELECT COUNT(*) 
						INTO cBandera
						FROM bdicred:sd_programa_apoyo2020crd 
						WHERE  num_credito = pNumCred;

					IF cBandera > 0 THEN
					
						SELECT count(fecha_cuota) 
						 INTO cAmortiza
							FROM "informix".sd_amortiza_creditocrd
							WHERE empresa = pEmpresa
							AND num_credito = pNumCred;
							
							IF cAmortiza > dPlazo THEN
							 LET dPlazo = cAmortiza;
							END IF;
						--- se obtienen los  montos de INT e IVA de la maeretenido del prorama de apoyo
						SELECT monto
							INTO psaldoInteresApoyo
						FROM bdicred:sd_maeretenido 
						WHERE num_credito = pNumCred
							AND transacc = '8374'
							AND estatus = 'R';

							IF psaldoInteresApoyo IS NULL THEN
								LET psaldoInteresApoyo = 0;
							END IF;

						SELECT monto
							INTO psaldoIvaApoyo
						FROM bdicred:sd_maeretenido 
						WHERE num_credito = pNumCred
							AND transacc ='8375'
							AND estatus = 'R';

							IF psaldoIvaApoyo IS NULL THEN
								LET psaldoIvaApoyo = 0;
							END IF;
						
					END IF;
					
						LET dMontoAut = NVL(dSdoInicial,0);
						LET dPlazo = NVL(dPlazo,0) - NVL(iPagosRealizados,0);
						-- SE OBTIENE LA TASA ANUAL CON IVA
						LET dTasaInt = NVL(dTasa,0) / 100;
						LET dPlazoAux = NVL(dPlazo,0);

						IF cFrecuencia = 'M'  THEN --FRECUENCIA MENSUAL
							LET dPlazo = dPlazo * 1;
							LET iDiasPeriodo = 30;
						ELIF cFrecuencia = 'Q'  THEN --FRECUENCIA QUINCENAL
							LET dPlazo = dPlazo * 2;
							LET iDiasPeriodo = 15;
						END IF;

						LET dMensualidad = ROUND(dCapacidadPres,0);

						CALL "informix".monthadd(dtFechaCouta,iPagosRealizados) RETURNING dtFechaCouta;

						-- EL CICLO TENDRA EL NUMERO DE ITERACIONES IGUAL AL PLAZO DE PAGOS
						LET dtFechaInicial = dtFechaCouta;
						LET dtFechaAnt = dtFechaCouta;

						SELECT b.sdo_cap_insoluto
							  -- NVL(SUM(sdo_cap_insoluto + sdo_no_exig + int_tra_no_exig + mto_finan_vdo + mto_venc_int),0) --v_usted_debe_tc
						  INTO dSdoFinal
						  FROM sd_maecredcrd a, sd_maesdoshistcrd b
						 WHERE b.fecha = dfechahoy
						   AND a.empresa       = b.empresa
						   AND a.empresa       = pEmpresa
						   AND a.num_credito   = pNumCred
						   AND a.num_credito   = b.num_credito;
						
						---	Se suman los montos de interes e IVA del programa de apoyo a la deuda total

							IF psaldoInteresApoyo > 0 THEN
								LET dSdoAdeudTotal = 0;
								LET dSdoAdeudTotal = dSdoAdeudTotal + psaldoInteresApoyo + psaldoIvaApoyo;
								LET dSdoAdeudTotal_liquidar = psaldoInteresApoyo + psaldoIvaApoyo;
							END IF;
					
					IF dSdoFinal > 0 THEN 
								-- 26/11/2026 jahj rqi 21 402	
							LET dMesesadicionales = case when dMensualidad <> 0 then round(dSdoFinal / dMensualidad) + 1  else 0 end;
							
							LET dPlazo =  dPlazo + dMesesadicionales;
							
							
							
							--es porque ya excedio elpretamo
							IF dSdoAdeudTotal > 0 THEN 
								-- 26/11/2026 jahj rqi 21 402	
								LET dMesesadicionales = case when dMensualidad <> 0 then  round(dSdoAdeudTotal / dMensualidad) + 1 else 0 end;
								LET dPlazo =  dPlazo + dMesesadicionales;

							END IF;

					END IF;

				IF dPlazo > 0 THEN
					
						
						FOR iContador = 1 TO dPlazo  STEP 1

							-- SE OBTIENE EL SALDO INICIAL DEL PERIODO, SI EL SALDO FINAL ES CERO 
							--QUIERE DECIR QUE ES EL PRIMER PERIODO Y EL SALDO INICIAL ES IGUAL AL MONTO APROBADO
							IF dSdoFinal > 0 THEN
								LET dSdoInicial = NVL(dSdoFinal,0);
							END IF;

							IF dSdoFinal <= 0 AND iContador > 1 THEN
								IF dSdoAdeudTotal <= 0 THEN
								EXIT FOR;
								ELSE 
								LET dSdoInicial = 0;
								END IF;
								
							END IF;

							--SE OBTIENEN LOS MESES DEL PERIODO
							LET iPeriodo = NVL(iContador,0) + NVL(iPagosRealizados,0);

							-- ********************************************************************************************************************
							-- ************************** SE OBTIENE LA SIGUIENTE FECHA DE CUOTA Y LOS DIAS DEL PERIODO **********************
							--*********************************************************************************************************************
							
								--OBTIENE LA FECHA DE LA SIGUIENTE FECHA DE PAGO
								CALL "informix".monthadd(dtFechaInicial,iContador) RETURNING dtFechaCouta;
								--OBTIENE LA FECHA DE LA FECHA DE PAGO ANTERIOR
								CALL "informix".monthadd(dtFechaInicial,iContador-1) RETURNING dtFechaAnt;

								--SI LA FECHA CUOTA O FECHA ANTERIOS ESTAN ENTRE LOS DIAS FESTIVOS 1 DE ENERO Y 25 DE DICIEMBRE
								--SE PASAN AL DIA SIGUIENTE
								IF (MONTH(dtFechaCouta) = 1 AND DAY(dtFechaCouta) = 1) OR (MONTH(dtFechaCouta) = 12 AND DAY(dtFechaCouta) = 25) THEN
									LET dtFechaCouta = dtFechaCouta + 1;
								END IF;

								IF (MONTH(dtFechaAnt) = 1 AND DAY(dtFechaAnt) = 1) OR (MONTH(dtFechaAnt) = 12 AND DAY(dtFechaAnt) = 25) THEN
									LET dtFechaAnt = dtFechaAnt + 1;
								END IF;

								IF iContador = 1 THEN
									IF NVL(iPagosRealizados,0 ) =0 THEN
										LET iDiasPeriodo = dtFechaCouta - dtFechaCoutaAux;
									ELSE
										LET iDiasPeriodo = dtFechaCouta - dtFechaAnt;
									END IF
								ELSE
									LET iDiasPeriodo = dtFechaCouta - dtFechaAnt;
								END IF;
							

							--SE CALCULAN LOS INTERESES
							LET dIntereses = NVL(dSdoInicial,0) * (NVL(dTasaInt,0) / 360) * NVL(iDiasPeriodo,0);
							-- SE CALCULA EL IVA DE LOS INTERESES
							LET dIvaInt = ROUND(NVL(dIntereses,0) * NVL(dIva,0),2);

							IF dMontoAut < dMensualidad and dSdoFinal > 0  THEN
							
								/*IF iPeriodo > iPlazo THEN
								--IF iPeriodo = '13' THEN--
								--LET dSdoInicial = '700';--
								--END IF;--
								LET dCapital = dSdoInicial ;
								LET dMensualidad = dSdoInicial ;
								ELSE*/
								LET dMensualidad = NVL(dMontoAut,0) + NVL(dIntereses,0) + NVL(dIvaInt,0);
								LET dCapital = NVL(dMontoAut,0);
								--END IF;
							ELSE
								/*IF iPeriodo > iPlazo THEN
								--IF iPeriodo = '13' THEN--
								--LET dSdoInicial = '700';--
								--END IF;--
								LET dCapital = NVL(dMensualidad,0);
								ELSE*/
								IF dSdoFinal > 0 THEN
								LET dCapital = NVL(dMensualidad,0) - (NVL(dIntereses,0) + NVL(dIvaInt,0));
								ELSE
								LET dCapital = 0;
								END IF;
								--END IF;
								LET dIntereses = NVL(dIntereses,0) ;
								LET dIvaInt  = NVL(dIvaInt,0) ;
								LET iDiasPeriodo= NVL(iDiasPeriodo,0);
							END IF;

							-- SE CALCULA EL SALDO FINAL
							LET dSdoFinal = NVL(dSdoInicial,0) - NVL(dCapital,0);
							
						   
							LET dMontoAut = NVL(dSdoInicial,0) - NVL(dCapital,0);
							
							
						IF 	dSdoFinal = 0 and dSdoAdeudTotal > 0 THEN
						
						
								
							--proporcional a intereses
							-- 26/11/2025 JAHJ RQI 21 402
							LET pProporcion = case when dSdoAdeudTotal <> 0 then  round(psaldoInteresApoyo / dSdoAdeudTotal,10) else 0 end;
							
							/*SELECT pago_capital, monto_pago,intereses  ,iva_intereses 
							INTO dUltpago_capital, dUltimopago, dUlt_interes, dUltiva
							FROM sd_amortizacion_creditoedoctacrd
							WHERE num_credito = pNumCred
							AND num_periodo <> 0
							AND saldo_insoluto = 0;*/
							
							LET dUltpago_capital  = dCapital;
							LET dUltimopago = dMensualidad;
							LET dUlt_interes = dIntereses;
							LET dUltiva = dIvaInt;
							
							IF dCapital > 0 THEN
							
								IF dMensualidad < dCapacidadPres AND (dSdoAdeudTotal - dMensualidad) = 0 THEN
									LET dInt_restante = dMensualidad;								ELSE
									--IF dMensualidad < dCapacidadPres AND dSdoAdeudTotal <= dMensualidad THEN
									--	LET dInt_restante = dSdoAdeudTotal;
									--ELSE
										IF dSdoAdeudTotal > dMensualidad AND dSdoAdeudTotal <= dCapacidadPres  THEN
											LET dInt_restante = dSdoAdeudTotal;
										ELSE
											LET dInt_restante = dCapacidadPres - dUltimopago ;
										END IF;
									--END IF;
								END IF;
							ELSE
								IF dSdoAdeudTotal < dMensualidad THEN
								LET dMensualidad = dSdoAdeudTotal;								--LET  dIntereses = psaldoInteresApoyo;
								--LET dIvaInt = 0;
								/*ELSE
								--LET dMensualidad = dMensualidad;
								LET dIntereses = dMensualidad - psaldoIvaApoyo;
								LET dIvaInt = psaldoIvaApoyo;*/
								END IF;
							LET dInt_restante = dMensualidad;
							END IF;
							LET dInteres_sumar =  dInt_restante * pProporcion;
							LET dIva_sumar = dInt_restante - dInteres_sumar;
							
							
							LET pFinal_intreses = dUlt_interes + dInteres_sumar;
							LET pFinal_iva =  dUltiva + dIva_sumar;
							LET DFinal_montopago = dUltpago_capital + pFinal_intreses + pFinal_iva;
							
							
							--IF dCapital > 0 THEN
								LET dIntereses = pFinal_intreses;
								LET dIvaInt = pFinal_iva;
								LET dMensualidad = DFinal_montopago;
							--ELSE 
								
							IF dCapital = 0 THEN	
								IF dSdoAdeudTotal > 0 THEN
								let psaldoInteresApoyo = psaldoInteresApoyo - dIntereses;
								let dSdoAdeudTotal = dSdoAdeudTotal - dMensualidad;								LET psaldoIvaApoyo = psaldoIvaApoyo - dIvaInt;
								END IF;
							 ELSE
								IF dSdoAdeudTotal > 0 THEN
								let psaldoInteresApoyo = psaldoInteresApoyo - dInteres_sumar;
								let dSdoAdeudTotal = dSdoAdeudTotal - (dInteres_sumar + dIva_sumar );								LET psaldoIvaApoyo = psaldoIvaApoyo - dIva_sumar;
								END IF;
							END IF;
							--END IF;
							
						END IF;
							
							INSERT INTO "informix".sd_amortizacion_creditoedoctacrd (
							fecha_emision ,num_credito ,monto_ahorro ,num_periodo ,fecha_pago ,pago_capital, intereses  ,iva_intereses ,
							monto_pago  ,
							saldo_insoluto ,sum_capital ,sum_intereses ,sum_iva_intereses  ,sum_pagomin  )
							VALUES(dfechahoy,pNumCred, 0.00,iPeriodo,dtFechaCouta ,dCapital,dIntereses,dIvaInt,
							dMensualidad,dSdoFinal,0.00,0.00,0.00,0.00);
							
						
						/*	UPDATE "informix".sd_amortizacion_creditoedoctacrd 
							set intereses = pFinal_intreses  ,iva_intereses = pFinal_iva , monto_pago = DFinal_montopago
							WHERE fecha_emision = dfechahoy
								AND num_credito = pNumCred
								AND num_periodo <> 0
								AND pago_capital > 0
							AND saldo_insoluto = 0;*/
							
							/*INSERT INTO "informix".sd_amortizacion_creditoedoctacrd (
							fecha_emision ,num_credito ,monto_ahorro ,num_periodo ,fecha_pago ,pago_capital, intereses  ,iva_intereses ,monto_pago  ,
							saldo_insoluto ,sum_capital ,sum_intereses ,sum_iva_intereses  ,sum_pagomin  )
							VALUES(dfechahoy,pNumCred, 0.00,iPeriodo,dtFechaCouta ,0.00,dInteresesN,dIvaIntN,
							dMensualidadN,0.00,0.00,0.00,0.00,0.00);*/
				
							
						END FOR;
			
				END IF;
					
							SELECT sum(pago_capital), sum(intereses), sum(iva_intereses), sum(monto_pago)
								INTO dSum_capital, dSum_intereses, dSum_iva_intereses, dSum_pagomin
							FROM  "informix".sd_amortizacion_creditoedoctacrd
								WHERE fecha_emision = dfechahoy
								AND num_credito = pNumCred;
								
							IF cBandera > 0 THEN
							LET dSum_capital = dSum_capital + dSdoAdeudTotal_liquidar;
							END IF;
							
							LET dTotAhorro = NVL(dTotAhorro,0) + NVL(dSum_intereses,0) + NVL(dSum_iva_intereses,0);
							
							UPDATE "informix".sd_amortizacion_creditoedoctacrd 
							set sum_capital = dSum_capital, sum_intereses = dSum_intereses, sum_iva_intereses = dSum_iva_intereses,  
							sum_pagomin = dSum_pagomin,
							monto_ahorro = dTotAhorro
							WHERE fecha_emision = dfechahoy
								AND num_credito = pNumCred
								AND num_periodo = '0';
								
							
			END FOREACH;
						
								
								
			RETURN NVL(cCodRet,'');
		
	END;
END PROCEDURE
DOCUMENT
'CREACION: GUADALUPE DE JESUS ESPINOZA VALENZUELA',
'FECHA: 29/08/2020 ',
'BD:BDICRED';

CREATE PROCEDURE "informix".sp_valida_spei_cred(pvchrclaverastreo CHAR(30),p_cta_clabe CHAR(18),pmonto MONEY(14,2))
RETURNING CHAR(6)       	AS retorno,
		CHAR(100)     		AS mensaje,
		CHAR (20)			AS numcte,
		CHAR (100)			AS nombre,
		CHAR (13)			AS rfc;	
		  

-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************

DEFINE cCodRet      		CHAR(6); 
DEFINE vMensaje             CHAR(300);
DEFINE iSqlErr      		INTEGER;
DEFINE iIsamErr     		INTEGER;

DEFINE vbanco				CHAR (3);
DEFINE p_cod_banco			CHAR (3);
DEFINE p_cod_financiero		CHAR (3);
DEFINE p_cod_producto		CHAR (4);
DEFINE tipo_producto		INTEGER;
DEFINE v_status_cred		CHAR(2);
DEFINE v_num_credito		CHAR(20);
DEFINE v_numcte				CHAR(20);
DEFINE v_producto			CHAR (4);
DEFINE v_sucursal			CHAR (4);
DEFINE v_divisa				CHAR (2);
DEFINE v_divisa_cred		CHAR (2);
DEFINE v_transaccion		CHAR(4);
DEFINE v_Folio				CHAR(16);
DEFINE v_tipo_bloqueo		INTEGER;
DEFINE v_causa_bloqueo		CHAR (3);
DEFINE valida_total_posisiones INTEGER;
DEFINE v_validanumerico		CHAR(1);

DEFINE cCodRetGF			CHAR (3);
DEFINE cFolioSucGF			CHAR (16);

DEFINE CodRet				CHAR(5);     -- Codigo de Retorno
DEFINE g_Remanente			MONEY(14,2); -- Remanente
DEFINE g_IntMoraCob			MONEY(14,2); -- Interes Moratorio Cobrado
DEFINE g_IntVencCob			MONEY(14,2); -- Interes Vencido Cobrado
DEFINE g_CapVencCob			MONEY(14,2); -- Capital Vencido Cobrado
DEFINE g_IntVigCob			MONEY(14,2); -- Interes Vigente Cobrado
DEFINE g_CapVigCob			MONEY(14,2); -- Capital Vigente Cobrado
DEFINE g_Impuesto			MONEY(14,2); -- Impuesto Cobrado
DEFINE g_Comision			MONEY(14,2); -- Comisiones Cobradas
DEFINE g_Seguro				MONEY(14,2); -- Seguro Cobrado

DEFINE cCodRet2				CHAR(5);
DEFINE cMensaje				CHAR(80);
DEFINE cNumCreditocrd		CHAR(20);
DEFINE Cuenta_eje			CHAR(20);
DEFINE Producto				CHAR(40);
DEFINE Num_Cliente			CHAR(20);
DEFINE Nom_Cliente			CHAR(80);
DEFINE Pago_Efectivo		DECIMAL(18,2);
DEFINE Pago_Cuenta			DECIMAL(18,2);
DEFINE Monto_Operacion		DECIMAL(18,2);
DEFINE Saldo_Actual			DECIMAL(18,2);
DEFINE Status_Actual		CHAR(60);

DEFINE v_apell_paterno		CHAR (25);
DEFINE v_apell_materno		CHAR (25);
DEFINE v_nombrecte			CHAR (100);
DEFINE v_nombre1			CHAR (25);
DEFINE v_nombre2			CHAR (25);
DEFINE v_rfc				CHAR (13);
DEFINE pempresa				CHAR (3);
DEFINE cReferencia			CHAR (40);

-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************

LET cCodRet      			= '000000';
LET vMensaje				= 'Proceso Exitoso';
LET iSqlErr      			= 0;
LET iIsamErr     			= 0;

LET vbanco					= '';
LET p_cod_banco				= '';
LET p_cod_financiero		= '';
LET p_cod_producto			= '';
LET tipo_producto			= 0;
LET v_status_cred			= '';
LET v_num_credito			= '';
LET v_numcte				= '';
LET v_producto				= '';
LET v_sucursal				= '';
LET v_divisa				= '';
LET v_divisa_cred			= '';
LET v_transaccion			= '';
LET v_Folio					= '';
LET v_tipo_bloqueo			= 0;
LET v_causa_bloqueo			= '';
LET valida_total_posisiones = 0;
LET v_validanumerico		= '';

LET cCodRetGF				= '';
LET cFolioSucGF				= '';

LET CodRet		         	= '';
LET g_Remanente	         	= 0;
LET g_IntMoraCob	     	= 0;
LET g_IntVencCob	     	= 0;
LET g_CapVencCob	     	= 0;
LET g_IntVigCob	         	= 0;
LET g_CapVigCob	         	= 0;
LET g_Impuesto	         	= 0;
LET g_Comision	         	= 0;
LET g_Seguro		     	= 0;

LET cCodRet2			= "00000";
LET cMensaje			= "Se realizÃ³ el proceso exitosamente";
LET cNumCreditocrd		= '';
LET Cuenta_eje			= "";
LET Producto			= "";
LET Num_Cliente			= "";
LET Nom_Cliente			= "";
LET Pago_Efectivo		= 0;
LET Pago_Cuenta			= 0;
LET Monto_Operacion		= 0;
LET Saldo_Actual		= 0;
LET Status_Actual		= "";

LET v_apell_paterno			= '';
LET v_apell_materno			= '';
LET v_nombre1				= '';
LET v_nombre2				= '';
LET v_nombrecte				= '';
LET v_rfc					= '';
LET pempresa				= '001';
LET cReferencia				= '';


-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	BEGIN

		ON EXCEPTION SET iSqlErr, iIsamErr
			IF iSqlErr != 0 THEN
				LET cCodRet = iSqlErr;		
				RETURN cCodRet,vMensaje,v_numcte,v_nombrecte,v_rfc;
			END IF;
		END EXCEPTION;
		
---	  SET DEBUG FILE TO '/informix/Israel/sp_valida_spei_cred.out';
--	  SET DEBUG FILE TO '/RESPALDOSNEW/Israel/sp_valida_spei_cred.out';
--	  TRACE ON;

-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************	


		IF p_cta_clabe = '' OR p_cta_clabe IS NULL OR pmonto IS NULL OR  NVL (pmonto,'') = '' THEN
			LET cCodRet = '14';
			LET vMensaje = 'Falta informaciÃ³n mandatoria para completar el pago';
			RETURN cCodRet,vMensaje,v_numcte,v_nombrecte,v_rfc;
		END IF;
		
		--- Obtiene el numero de posiciones
		LET valida_total_posisiones = LENGTH(p_cta_clabe);
		
		--- Valida que la cadena sea solo numerica
		EXECUTE PROCEDURE bdinteg:sp_esnumerico (p_cta_clabe)
			INTO v_validanumerico;
		
		---- Consulta numero banco (clabe receptor de SPEI)
		select{+ INDEX(bdinteg:si_param ix_si_param)} valor INTO vbanco
		  FROM bdinteg:si_param
		  WHERE empresa = pempresa and cod_param = 5;

		--- Obtiene codigo Bancario
		LET p_cod_banco = SUBSTR(p_cta_clabe,1,3);
		--- Obtiene codigo financiero
		LET p_cod_financiero = SUBSTR(p_cta_clabe,4,3);
		--- Obtiene numero de producto
		LET p_cod_producto = SUBSTR(p_cta_clabe,7,2)||'00';
			
		IF NVL (p_cod_banco,'') <> vbanco THEN
			LET cCodRet = '6';
			LET vMensaje = 'Cuenta no pertenece al Banco Receptor';
			RETURN cCodRet,vMensaje,v_numcte,v_nombrecte,v_rfc;
		ELIF pmonto <= 0 THEN
			LET cCodRet = '15';
			LET vMensaje = 'Tipo de pago erroneo';	
			RETURN cCodRet,vMensaje,v_numcte,v_nombrecte,v_rfc;
		ELIF p_cod_producto = '6500' OR valida_total_posisiones <> 18 THEN
			LET cCodRet = '17';
			LET vMensaje = 'Tipo de cuenta no corresponde';		
			RETURN cCodRet,vMensaje,v_numcte,v_nombrecte,v_rfc;
		ELIF v_validanumerico = 'F' THEN
			LET cCodRet = '19';
			LET vMensaje = 'Caracter invalido';		
			RETURN cCodRet,vMensaje,v_numcte,v_nombrecte,v_rfc;
		END IF;	
		
		--AGO - ValidaciÃ³n de producto 7800 PARA NO PERMITIR PAGO DE ADN
		IF NVL(TRIM(p_cod_producto),'') != '' AND NVL(TRIM(p_cod_producto),'') = '7800' THEN
				LET cCodRet     = '15';	-- 'NO SE ACEPTA PRODUCTO 7800'
				RETURN cCodRet,'NO SE ACEPTA PAGO PRODUCTO 7800',v_numcte,v_nombrecte,v_rfc;
		END IF;
				
		IF p_cod_financiero in ('975') OR p_cod_producto = '7800' THEN
		
			SELECT a.num_credito,a.numcte,a.num_producto,a.status_cred,a.sucursal,a.divisa,a.id_unidad_prod,a.Cod_caract_2,b.divisa,b.transacc_spei
				INTO v_num_credito,v_numcte,v_producto,v_status_cred,v_sucursal,v_divisa_cred,v_tipo_bloqueo,v_causa_bloqueo,v_divisa,v_transaccion
			FROM  bdicred:"informix".sd_maecred a
				JOIN bdicred:sd_definicion b on (a.num_producto = b.num_producto)
				WHERE cuenta_clabe = p_cta_clabe;
				
				IF (v_num_credito IS NULL OR NVL (v_num_credito,'') = '') OR (v_numcte IS NULL OR NVL (v_numcte,'') = '') 
					OR (v_producto IS NULL OR NVL (v_producto,'') = '') THEN
						LET cCodRet = '1';
						LET vMensaje = 'Cuenta Inexistente';
						RETURN cCodRet,vMensaje,v_numcte,v_nombrecte,v_rfc;

--				ELIF (v_tipo_bloqueo <> '' OR v_tipo_bloqueo IS NOT NULL) 
--					AND (v_causa_bloqueo <> '' OR v_causa_bloqueo IS NOT NULL) THEN --- VALIDAR ESTATUS BLOQUEADO
--						LET cCodRet = '2';
--						LET vMensaje = 'Cuenta Bloqueada';
--						RETURN cCodRet,vMensaje,v_numcte,v_nombrecte,v_rfc;
--
--				ELIF v_status_cred IN ('FI','FF') THEN --- Validar tipos de canceladas FI cancelada por saldos inmateriales
--					LET cCodRet = '3';
--					LET vMensaje = 'Cuenta Cancelada';
--					RETURN cCodRet,vMensaje,v_numcte,v_nombrecte,v_rfc;
					
--				ELIF (NVL (v_divisa_cred,'') = '' OR v_divisa_cred IS NULL) OR  v_divisa <> v_divisa_cred THEN 
--					LET cCodRet = '5';
--					LET vMensaje = 'Cuenta en otra divisa';
--					RETURN cCodRet,vMensaje,v_numcte,v_nombrecte,v_rfc;
				END IF;
			--- Genera folio para el movimiento
			EXECUTE PROCEDURE bdicred:sp_generafoliocredi(user ,1)
			INTO cCodRetGF,cFolioSucGF;
			
				IF cCodRetGF::INTEGER <> 0 THEN
					LET cCodRet = '000447';
					LET vMensaje = 'OCURRIO UN ERROR EN EL PROCESO QUE GENERA EL FOLIO';
					RETURN cCodRet,vMensaje,v_numcte,v_nombrecte,v_rfc;
				ELSE
					IF pvchrclaverastreo IS NOT NULL AND pvchrclaverastreo != '' THEN LET cReferencia = pvchrclaverastreo; END IF;
					
					EXECUTE PROCEDURE bdicred:"informix".principalrefer (pempresa,v_num_credito,1,'',user,v_sucursal,cFolioSucGF,v_transaccion,0,pmonto,cReferencia)
						INTO CodRet, g_Remanente, g_IntMoraCob, g_IntVencCob,
							g_CapVencCob, g_IntVigCob, g_CapVigCob, g_Impuesto,
							g_Comision, g_Seguro;
							
						IF (CodRet::INTEGER <> 0) THEN
							LET cCodRet = '000448';
							LET vMensaje = 'Error al ejecutar el pago';
							RETURN cCodRet,vMensaje,v_numcte,v_nombrecte,v_rfc;
						ELSE
							SELECT apell_paterno,apell_materno,nombre1,nombre2,rfc
								INTO v_apell_paterno,v_apell_materno,v_nombre1,v_nombre2,v_rfc
							FROM bdinteg:si_cliente 
							WHERE numcte = v_numcte;
							
							IF v_nombre2 IS NULL OR NVL (v_nombre2,'') = '' THEN
								LET v_nombrecte = TRIM (v_nombre1)||' '||TRIM (v_apell_paterno)||' '||TRIM (v_apell_materno);
							ELSE
								LET v_nombrecte = TRIM (v_nombre1)||' '||TRIM (v_nombre2)||' '||TRIM (v_apell_paterno)||' '||TRIM (v_apell_materno);
							END IF;
								
						END IF;
				END IF;

		ELIF p_cod_financiero in ('970','971','972') THEN
		
			SELECT a.num_credito,a.numcte,a.num_producto,a.status_cred,a.sucursal,a.divisa,b.divisa,b.transacc_spei
				INTO v_num_credito,v_numcte,v_producto,v_status_cred,v_sucursal,v_divisa_cred,v_divisa,v_transaccion
			FROM  bdicred:"informix".sd_maecredcrd a
				JOIN bdicred:sd_definicion b on (a.num_producto = b.num_producto)
				WHERE cuenta_clabe = p_cta_clabe;
				
				IF (v_num_credito IS NULL OR NVL (v_num_credito,'') = '') OR (v_numcte IS NULL OR NVL (v_numcte,'') = '') 
					OR (v_producto IS NULL OR NVL (v_producto,'') = '') THEN
						LET cCodRet = '1';
						LET vMensaje = 'Cuenta Inexistente';
						RETURN cCodRet,vMensaje,v_numcte,v_nombrecte,v_rfc;

--				ELIF v_status_cred = '' THEN --- VALIDAR ESTATUS BLOQUEADO
--					LET cCodRet = '2';
--					LET vMensaje = 'Cuenta Bloqueada';
--					RETURN cCodRet,vMensaje,v_numcte,v_nombrecte,v_rfc;
--
--				ELIF v_status_cred IN ('CN','FF') THEN --- 
--					LET cCodRet = '3';
--					LET vMensaje = 'Cuenta Cancelada';
--					RETURN cCodRet,vMensaje,v_numcte,v_nombrecte,v_rfc;
--					
--				ELIF (NVL (v_divisa_cred,'') = '' OR v_divisa_cred IS NULL) OR  v_divisa <> v_divisa_cred THEN 
--					LET cCodRet = '5';
--					LET vMensaje = 'Cuenta en otra divisa';
--					RETURN cCodRet,vMensaje,v_numcte,v_nombrecte,v_rfc;
				END IF;
			--- Genera folio para el movimiento
			EXECUTE PROCEDURE bdicred:sp_generafoliocredi(user ,1)
			INTO cCodRetGF,cFolioSucGF;
			
				IF cCodRetGF::INTEGER <> 0 THEN
					LET cCodRet = '000447';
					LET vMensaje = 'OCURRIO UN ERROR EN EL PROCESO QUE GENERA EL FOLIO';
					RETURN cCodRet,vMensaje,v_numcte,v_nombrecte,v_rfc;
				ELSE

					EXECUTE PROCEDURE bdicred:sp_principal_suc_rr (pempresa,v_num_credito,v_producto,pmonto,0,user,v_sucursal,cFolioSucGF,v_transaccion)
						INTO cCodRet2,cMensaje,cNumCreditocrd,Cuenta_eje,Producto,Num_Cliente,Nom_Cliente,
							Pago_Efectivo,Pago_Cuenta,Monto_Operacion,Saldo_Actual,Status_Actual;
							
						IF (cCodRet2::INTEGER <> 0) THEN
							LET cCodRet = '000449';
							LET vMensaje = cMensaje;
							RETURN cCodRet,vMensaje,v_numcte,v_nombrecte,v_rfc;
						ELSE
							SELECT apell_paterno,apell_materno,nombre1,nombre2,rfc
								INTO v_apell_paterno,v_apell_materno,v_nombre1,v_nombre2,v_rfc
							FROM bdinteg:si_cliente 
							WHERE numcte = v_numcte;
							
							IF v_nombre2 IS NULL OR NVL (v_nombre2,'') = '' THEN
								LET v_nombrecte = TRIM (v_nombre1)||' '||TRIM (v_apell_paterno)||' '||TRIM (v_apell_materno);
							ELSE
								LET v_nombrecte = TRIM (v_nombre1)||' '||TRIM (v_nombre2)||' '||TRIM (v_apell_paterno)||' '||TRIM (v_apell_materno);
							END IF;
							
						END IF;
				END IF;
		ELSE
			LET cCodRet = '6';
			LET vMensaje = 'Cuenta no pertenece al Banco Receptor';
			RETURN cCodRet,vMensaje,v_numcte,v_nombrecte,v_rfc;		
		END IF;
		
	END		
	
RETURN cCodRet,vMensaje,v_numcte,v_nombrecte,v_rfc;

END PROCEDURE
DOCUMENT
'Proceso que realiza la validacion para aplicar un SPEI de credito',
'AUTOR : Israel Travieso',
'FECHA : SEP/2019',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_genarch_info_ctasrtpp()
--EXECUTE PROCEDURE sp_genarch_info_ctasrtpp();

	RETURNING CHAR(5), CHAR(50)    ;  --CodRet
	
	--*****************************************************
	--DECLARACION DE VARIABLES
	--*****************************************************
	DEFINE vCodRet      VARCHAR(05);
	DEFINE cMensaje     CHAR(150); 
	DEFINE iSqlErr      INTEGER;
	DEFINE iIsamErr     INTEGER;
	DEFINE Error_Info   VARCHAR(80);
	DEFINE vFechaHoy	DATE;
	DEFINE vDiaHoy		CHAR(02);
	DEFINE vMesHoy		CHAR(02);
	DEFINE vMesAnt		CHAR(02);
	DEFINE vAnioHoy		CHAR(04);
	DEFINE vFechaRep1	DATE;
	DEFINE vFechaRep2	DATE;
	DEFINE vFechaP1		DATE;
	
	DEFINE vRuta        VARCHAR(255);
	DEFINE v_sql        CHAR(3000);
	DEFINE v_sql1       CHAR(200);
	DEFINE v_sql2       CHAR(666);
	DEFINE v_sql3		CHAR(666);
	
	LET vCodRet     = '00000';
	LET cMensaje    = 'Ejecucion Exitosa';
	LET iSqlErr     = 0;
	LET iIsamErr    = 0;
	LET Error_Info  = '';
	LET vFechaHoy	= date(1);
	LET vDiaHoy		= '20';
	LET vMesHoy		= '';
	LET vMesAnt		= '';
	LET vAnioHoy	= '';
	LET vFechaRep1	= date(1);
	LET vFechaRep2	= date(1);
	LET vFechaP1	= DATE(1);
	
	LET vRuta   = ''; -- '/resplogifx/archivoscartera/';
	LET v_sql   = '';
	LET v_sql1  = '';
	LET v_sql2	= '';
	LET v_sql3	= '';
	
	BEGIN

	ON EXCEPTION SET iSqlErr, iIsamErr
        IF iSqlErr != 0 THEN
			LET vCodRet = iSqlErr;		
            LET cMensaje = 'Error en la ejecucion';
            RETURN vCodRet,cMensaje;
		END IF;
    END EXCEPTION;
	
	--SET DEBUG FILE TO '/informix/Ulises/RQM_repCarteras/sp_genarch_info_ctasrtpp.out';
	--TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	-- Obtiene el Mes y Anio para colocar en el archivo
	SELECT LPAD(MONTH(fecha_hoy),2,0),YEAR(fecha_hoy),LPAD(MONTH(fecha_hoy - 1 units month),2,0)
	INTO vMesHoy,vAnioHoy,vMesAnt
	FROM "informix".sd_fechas where empresa = '001';
	
	--LET vMesHoy = '07'; --para pruebas
	--LET vAnioHoy = '2021'; --para pruebas
	--LET vMesAnt	= '06'; --para pruebas
	
	-- se obtiene la fecha para filtar por mes la obtenciÃ³n de la informaciÃ³n
	LET vFechaRep1 = MDY(vMesAnt,17,vAnioHoy);
	LET vFechaRep2 = MDY(vMesHoy,17,vAnioHoy);
	
	-- Obtiene la ruta donde se realiza la descarga del archivo.
	SELECT TRIM(valor) INTO vRuta FROM sd_param WHERE empresa = '001' AND cod_param = '033';
	
	--LET vRuta = '/informix/ulises/RQI/25_183/OLTP/'; -- PARA PRUEBAS
	
	-- Descarga reporte de Pestamo Personal
/*	LET v_sql1 = ' echo "UNLOAD TO '||trim(vRuta)||'descargaRepPP.unl';
	LET v_sql2 = ' SELECT a.num_credito,a.numcte,a.nombre_cte,a.direccion_cn,a.direccion_col,a.direccion_del, '||
				' a.edo_cd,a.cl_cobra,a.cp,a.ruta,a.entre_calles,a.observaciones,b.capital_ven_tc,b.interes_ven_tc ' ||
				' FROM "informix".sd_encabezado_edoctacrd a '||
				' INNER JOIN "informix".sd_encabezado2_edoctacrd b on b.num_credito = a.num_credito and b.fecha_emision > '''||vFechaRep1|| ''' and b.fecha_emision <= '''||vFechaRep2|| ''' '||
				' WHERE a.fecha_emision > '''||vFechaRep1|| ''' and a.fecha_emision <= '''||vFechaRep2|| ''' and a.num_producto IN(''6300'',''7600'',''7700'',''6800'') ;"  > queryRepPP.sql';
*/
	LET v_sql1 = ' echo "UNLOAD TO '||trim(vRuta)||'descargaRepPP.unl';
	LET v_sql2 = ' SELECT nvl ( replace ( replace( a.num_credito, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
				 ' nvl ( replace ( replace( numcte, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
				 ' nvl ( replace ( replace( nombre_cte, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
				 ' nvl ( replace ( replace( direccion_cn, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
                 ' replace ( replace ( replace( direccion_col, ''|'' , '' '' ), ''\'' , '' '' ), '''','' '' ),'||
				 ' replace ( replace ( replace( direccion_del, ''|'' , '' '' ), ''\'' , '' '' ), '''','' '' ),'||
				 ' replace ( replace ( replace( edo_cd, ''|'' , '' '' ), ''\'' , '' '' ), '''','' '' ),'||
				 ' nvl ( replace ( replace( cl_cobra, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
				 ' nvl ( replace ( replace( cp, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),';
	LET v_sql3 = ' replace ( replace ( replace( ruta, ''|'' , '' '' ), ''\'' , '' '' ), '' '','' '' ),'||
				 ' nvl ( replace ( replace( entre_calles, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
                 ' nvl ( replace ( replace( observaciones, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
				 ' nvl ( capital_ven_tc,0),'||
				 ' nvl ( interes_ven_tc,0)'||
				 ' FROM "informix".sd_encabezado_edoctacrd a '||
				 ' INNER JOIN "informix".sd_encabezado2_edoctacrd b on b.num_credito = a.num_credito and b.fecha_emision > '''||vFechaRep1|| ''' and b.fecha_emision <= '''||vFechaRep2|| ''' '||
				 ' WHERE a.fecha_emision > '''||vFechaRep1|| ''' and a.fecha_emision <= '''||vFechaRep2|| ''' and a.num_producto IN(''6300'',''7600'',''7700'',''6800'') ;"  > queryRepPP.sql';
	LET v_sql = v_sql1||v_sql2||v_sql3;
	SYSTEM v_sql;
	
	LET v_sql = "dbaccess bdicred queryRepPP.sql";
	SYSTEM v_sql;
	
	LET v_sql = '';
    LET v_sql = "sed 's/|$//g' "||trim(vRuta)||'descargaRepPP.unl'||" >"||trim(vRuta)||'descargaRepPP1.txt';
    SYSTEM v_sql;
	
		-- Elimina los caracteres especiales que se tienen dentro de las columnas.
		  LET v_sql = '';
		  LET v_sql = 'echo " cd '|| '\"'||vRuta||'\"'||'" > eliminaespeciales.sh ' ;
		  SYSTEM v_sql;
		  
		  LET v_sql = '';
		  LET v_sql = "chmod 777 "||'eliminaespeciales.sh ';
		  SYSTEM v_sql;

		  LET v_sql = '';
		  LET v_sql = ' echo '||'"'||' sed  -e ''s/''\$(echo ['||'\"'||'\\\001\\\002\\\003\\\004\\\005\\\006\\\007\\\010\\\016\\\017\\\020\\\021'||		                     
		                         '\\\022\\\023\\\024\\\025\\\026\\\027\\\030\\\031\\\032\\\033\\\034\\\035\\\036\\\037'||
                              '\"'||'])''//g'' '||vRuta||'descargaRepPP1.txt'||" > "||vRuta||'descargaRepPP2.txt'||
                              '" >>'||'eliminaespeciales.sh ';
		  SYSTEM v_sql;
		  
		  LET v_sql = '';
		  LET v_sql = "./"||'eliminaespeciales.sh ';
		  SYSTEM v_sql;
	
	LET v_sql = '';
    LET v_sql = "sed 's/" || '"' ||  "//g' "||trim(vRuta)||'descargaRepPP2.txt'||" > " || trim(vRuta||'descargaRepPP1.txt');
    SYSTEM v_sql;
	
	--Elimina diagonal invertida
	LET v_sql = '';
    LET v_sql = "sed 's/[\]//g' "||trim(vRuta)||'descargaRepPP1.txt'||" >"||trim(vRuta)||'descargaRepPP2.txt';
    SYSTEM v_sql;
	
	--Convierte de formato Linux a Windows
	LET v_sql = '';
    LET v_sql = "awk 'sub(""$"", ""\r"")' "||trim(vRuta)||'descargaRepPP2.txt'||" > " || trim(vRuta||'clientesbancoppelppbase64_'||vMesHoy||SUBSTR(vAnioHoy, 3, 4)||'.txt');
    SYSTEM v_sql;
	
	LET v_sql = '';
	LET v_sql = " gzip " ||trim(vRuta)||'clientesbancoppelppbase64_'||vMesHoy||SUBSTR(vAnioHoy, 3, 4)||'.txt ';
    SYSTEM v_sql;
	
	LET v_sql = '';
    LET v_sql = "rm "||trim(vRuta)||'descargaRepPP.unl';
    SYSTEM v_sql;
	
	LET v_sql = '';
    LET v_sql = "rm "||trim(vRuta)||'descargaRepPP1.txt';
    SYSTEM v_sql;
	
	LET v_sql = '';
    LET v_sql = "rm "||trim(vRuta)||'descargaRepPP2.txt';
    SYSTEM v_sql;
	
	LET v_sql = '';
    LET v_sql = "rm "||'queryRepPP.sql';
    SYSTEM v_sql;
	
	LET v_sql = '';
    LET v_sql = "rm "||'eliminaespeciales.sh ';
    SYSTEM v_sql;
	
	LET v_sql1 = '';
	LET v_sql2 = '';
	
	-- Descarga reporte de Reestructura
/*	LET v_sql1 = ' echo "UNLOAD TO '||trim(vRuta)||'descargaRepRT.unl';
	LET v_sql2 = ' SELECT a.num_credito,a.numcte,a.nombre_cte,a.direccion_cn,a.direccion_col,a.direccion_del, '||
				' a.edo_cd,a.cl_cobra,a.cp,a.ruta,a.entre_calles,a.observaciones,b.capital_ven_tc,b.interes_ven_tc ' ||
				' FROM "informix".sd_encabezado_edoctacrd a '||
				' INNER JOIN "informix".sd_encabezado2_edoctacrd b on b.num_credito = a.num_credito and b.fecha_emision > '''||vFechaRep1|| ''' and b.fecha_emision <= '''||vFechaRep2|| ''' '||
				' WHERE a.fecha_emision > '''||vFechaRep1|| ''' and a.fecha_emision <= '''||vFechaRep2|| ''' and a.num_producto IN(''6011'') ;"  > queryRepRT.sql';
*/
	LET v_sql1 = ' echo "UNLOAD TO '||trim(vRuta)||'descargaRepRT.unl';
	LET v_sql2 = ' SELECT nvl ( replace ( replace( a.num_credito, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
				 ' nvl ( replace ( replace( numcte, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
				 ' nvl ( replace ( replace( nombre_cte, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
				 ' nvl ( replace ( replace( direccion_cn, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
                 ' replace ( replace ( replace( direccion_col, ''|'' , '' '' ), ''\'' , '' '' ), '''','' '' ),'||
				 ' replace ( replace ( replace( direccion_del, ''|'' , '' '' ), ''\'' , '' '' ), '''','' '' ),'||
				 ' replace ( replace ( replace( edo_cd, ''|'' , '' '' ), ''\'' , '' '' ), '''','' '' ),'||
				 ' nvl ( replace ( replace( cl_cobra, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
				 ' nvl ( replace ( replace( cp, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),';
	LET v_sql3 = ' replace ( replace ( replace( ruta, ''|'' , '' '' ), ''\'' , '' '' ), '' '','' '' ),'||
				 ' nvl ( replace ( replace( entre_calles, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
                 ' nvl ( replace ( replace( observaciones, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
				 ' nvl ( capital_ven_tc,0),'||
				 ' nvl ( interes_ven_tc,0)'||
				 ' FROM "informix".sd_encabezado_edoctacrd a '||
				 ' INNER JOIN "informix".sd_encabezado2_edoctacrd b on b.num_credito = a.num_credito and b.fecha_emision > '''||vFechaRep1|| ''' and b.fecha_emision <= '''||vFechaRep2|| ''' '||
				 ' WHERE a.fecha_emision > '''||vFechaRep1|| ''' and a.fecha_emision <= '''||vFechaRep2|| ''' and a.num_producto IN(''6011'') ;"  > queryRepRT.sql';
	LET v_sql = v_sql1||v_sql2||v_sql3;
	SYSTEM v_sql;
	
	LET v_sql = "dbaccess bdicred queryRepRT.sql";
	SYSTEM v_sql;
	
	LET v_sql = '';
    LET v_sql = "sed 's/|$//g' "||trim(vRuta)||'descargaRepRT.unl'||" >"||trim(vRuta)||'descargaRepRT1.txt';
    SYSTEM v_sql;
	
		-- Elimina los caracteres especiales que se tienen dentro de las columnas.
		  LET v_sql = '';
		  LET v_sql = 'echo " cd '|| '\"'||vRuta||'\"'||'" > eliminaespeciales.sh ' ;
		  SYSTEM v_sql;
		  
		  LET v_sql = '';
		  LET v_sql = "chmod 777 "||'eliminaespeciales.sh ';
		  SYSTEM v_sql;

		  LET v_sql = '';
		  LET v_sql = ' echo '||'"'||' sed  -e ''s/''\$(echo ['||'\"'||'\\\001\\\002\\\003\\\004\\\005\\\006\\\007\\\010\\\016\\\017\\\020\\\021'||		                     
		                         '\\\022\\\023\\\024\\\025\\\026\\\027\\\030\\\031\\\032\\\033\\\034\\\035\\\036\\\037'||
                              '\"'||'])''//g'' '||vRuta||'descargaRepRT1.txt'||" > "||vRuta||'descargaRepRT2.txt'||
                              '" >>'||'eliminaespeciales.sh ';
		  SYSTEM v_sql;
		  
		  LET v_sql = '';
		  LET v_sql = "./"||'eliminaespeciales.sh ';
		  SYSTEM v_sql;
	
	LET v_sql = '';
    LET v_sql = "sed 's/" || '"' ||  "//g' "||trim(vRuta)||'descargaRepRT2.txt'||" > " || trim(vRuta||'descargaRepRT1.txt');
    SYSTEM v_sql;
	
	--Elimina diagonal invertida
	LET v_sql = '';
    LET v_sql = "sed 's/[\]//g' "||trim(vRuta)||'descargaRepRT1.txt'||" >"||trim(vRuta)||'descargaRepRT2.txt';
    SYSTEM v_sql;
	
	--Convierte de formato Linux a Windows
	LET v_sql = '';
    LET v_sql = "awk 'sub(""$"", ""\r"")' "||trim(vRuta)||'descargaRepRT2.txt'||" > " || trim(vRuta||'clientesbancoppelrtbase64_'||vMesHoy||SUBSTR(vAnioHoy, 3, 4)||'.txt');
    SYSTEM v_sql;
	
	LET v_sql = '';
	LET v_sql = " gzip " ||trim(vRuta)||'clientesbancoppelrtbase64_'||vMesHoy||SUBSTR(vAnioHoy, 3, 4)||'.txt ';
    SYSTEM v_sql;
	
	LET v_sql = '';
    LET v_sql = "rm "||trim(vRuta)||'descargaRepRT.unl';
    SYSTEM v_sql;
	
	LET v_sql = '';
    LET v_sql = "rm "||trim(vRuta)||'descargaRepRT1.txt';
    SYSTEM v_sql;
	
	LET v_sql = '';
    LET v_sql = "rm "||trim(vRuta)||'descargaRepRT2.txt';
    SYSTEM v_sql;
	
	LET v_sql = '';
    LET v_sql = "rm "||'queryRepRT.sql';
    SYSTEM v_sql;
	
	LET v_sql = '';
    LET v_sql = "rm "||'eliminaespeciales.sh ';
    SYSTEM v_sql;
	
	END;
	RETURN vCodRet,cMensaje;
END PROCEDURE
DOCUMENT
'Reportes para Carteras Coppel de PP y RT',
'Autor: David Cuenca',
'BD: bdicred',
'Fecha: 2021';

CREATE PROCEDURE "informix".ugenera_layoutedocuenta_muestras(pempresa CHAR(3),pperiodo DATE) 
--EXECUTE PROCEDURE ugenera_layoutedocuenta_muestras('001',MDY('02','20','2022'));
RETURNING CHAR(5);

DEFINE v_ruta		VARCHAR(255);
DEFINE v_ruta_cfd	VARCHAR(255);
DEFINE cod_ret 		CHAR(5);
DEFINE sql_err 		INTEGER;
DEFINE v_sql        CHAR(8000);
DEFINE v_sql1       CHAR(1600);
DEFINE v_sql2       CHAR(1600);
DEFINE v_sql3       CHAR(1600);
DEFINE v_sql4       CHAR(1600);
DEFINE v_sql5       CHAR(1600);
DEFINE cNumCred     CHAR(20);
DEFINE cNumCredAux  CHAR(20);
DEFINE cNumCte      CHAR(20);
DEFINE cNumCteAux   CHAR(20);
DEFINE iMovMax      INTEGER;
DEFINE sPaso        SMALLINT;
DEFINE v_sql0       CHAR(50);

LET v_ruta      = "";
LET v_sql       = "";
LET v_sql1      = "";
LET v_sql2      = "";
LET v_sql3      = "";
LET v_sql4      = "";
LET v_sql5      = "";
LET sPaso       = 0; 
LET cNumCred    = "";
LET cNumCredAux = "";
LET cNumCte     = "";
LET cNumCteAux  = "";
LET iMovMax     = 0;
LET v_sql0 = ' echo "SET ISOLATION TO DIRTY READ; ';


set isolation to dirty read;
set lock mode to wait 3;
--set pdqpriority 20;

-- Fecha: 03/04/2013
-- Autor: Faviola M. Juarez
-- Nodificacion: Se modifico la tabla temporal  sd_paso_cred por sd_cred_muestra
-- Separando los querys.
 
BEGIN

	ON EXCEPTION SET sql_err
		IF sql_err <> 0 THEN
			LET cod_ret = sql_err;
			SELECT COUNT(tabid)
			  INTO sPaso
			  FROM systables 
			 WHERE tabname= 'sd_cred_muestra';

			IF NVL(sPaso,0) > 0 THEN
				DROP TABLE sd_cred_muestra;
			END IF;
			
			RETURN cod_ret;
		END IF
	END EXCEPTION;

	LET cod_ret = "000";
   
	--SET DEBUG FILE TO "/informix/David/RQM_10_1674/Muestras/sps/ugenera_layoutedocuenta_muestras.out";
	--TRACE ON;

-----------------OBTENGO LA FECHA DE PROCESO---------------------------------------------------

	SELECT TRIM(valor) INTO v_ruta FROM sd_param WHERE empresa = pempresa AND cod_param = '033';
	SELECT TRIM(valor) INTO v_ruta_cfd FROM sd_param WHERE empresa = pempresa AND cod_param = '037';


	SELECT COUNT(tabid)
		INTO sPaso
	FROM systables 
	WHERE tabname= 'sd_cred_muestra';

	IF NVL(sPaso,0) > 0 THEN
		DROP TABLE "informix".sd_cred_muestra;
	END IF;

    CREATE TABLE "informix".sd_cred_muestra 
    (
		num_credito CHAR(20)
    ) in dbs_cfd_03 EXTENT SIZE 1024 NEXT SIZE 4096 LOCK MODE ROW;
	 
	insert into "informix".sd_cred_muestra  values ('000'); -- Encabezado_edocta  General
    insert into "informix".sd_cred_muestra  values ('100'); -- Encabezado_edocta  General
    insert into "informix".sd_cred_muestra  values ('200'); -- Encabezado edocta Saldos
	insert into "informix".sd_cred_muestra  values ('201'); -- Encabezado Sdos sobre Interes Periodo
    insert into "informix".sd_cred_muestra  values ('300'); -- Detalle
	insert into "informix".sd_cred_muestra  values ('301'); -- Detalle MSI
	insert into "informix".sd_cred_muestra  values ('302'); -- CoppelMax
	insert into "informix".sd_cred_muestra  values ('303'); -- Movimiento de Lineas Adi
	insert into "informix".sd_cred_muestra  values ('304'); -- Lienas adicionales
    insert into "informix".sd_cred_muestra  values ('400'); -- Aclaraciones
    insert into "informix".sd_cred_muestra  values ('500'); -- Mensajes
    insert into "informix".sd_cred_muestra  values ('600'); -- Pie
    insert into "informix".sd_cred_muestra  values ('900'); -- Credisoluciones
		
	insert into "informix".sd_cred_muestra
	select num_credito from sd_muestra_edocta
	where empresa ='001'
	and fecha_corte = pperiodo;
    
                  
	------------------------------------------------------------------------------------------------------------------------
	-- RQI 12 297 Actualizacion de archivos de credito para implementar CFDI 3.3.--
	-- ADLM: Se agregan los campos base_iva, descuento, subtotal y total.
	-----------------ENCABEZADO DOS---------------------------------------------------ARCHIVO 200B
	LET v_sql1 = ' UNLOAD TO '||v_ruta||'descargaB.unl';
	LET v_sql2 = ' SELECT nvl ( fecha_emision,date(1)), '||
			  ' trim( replace ( replace( a.num_credito, ''|'' , '' '' ), ''\'' , '' '' )), '||
			  ' nvl ( capital_tc,0), '||
			  ' nvl ( interes_tc,0), '||
			  ' nvl ( iva_interes_tc,0), '||
			  ' nvl ( capital_ven_tc,0), '||
			  ' nvl ( interes_ven_tc,0), '||
			  ' nvl ( iva_interes_ven_tc,0), '||
			  ' nvl ( moratorios_tc,0), '||
			  ' nvl ( iva_moratorios_tc,0), '||
			  ' nvl ( sdo_pagar,0), '||
			  ' nvl ( interes_pago_total_tc,0), '||
			  ' nvl ( limite_tc,0), '||
			  ' nvl ( sdo_disponible,0), '||
			  ' nvl ( periodo_tc_ini,0), '||
			  ' nvl ( periodo_tc_fin,date(1)), '||
			  ' nvl ( pago_antes_de,date(1)), '||
			  ' nvl ( fecha_corte,date(1)), '||
			  ' nvl ( replace ( replace( dias_periodo_tc, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ), '||
			  ' nvl ( usted_debia,0), '||
			  ' nvl ( menos_abonos,0), '||
			  ' nvl ( mas_compras,0), '||
			  ' nvl ( sus_comisiones,0), '||
			  ' nvl ( mas_disp_efectivo,0), '||
			  ' nvl ( mas_intereses,0), '||
			  ' nvl ( mas_iva,0), '||
			  ' nvl ( mas_rendimientos,0), '||
			  ' nvl ( comisiones_iva,0), '||
			  ' nvl ( intereses_iva,0), '||
			  ' nvl ( intereses_pag,0), '||
			  ' nvl ( saldo_menos_pag,0), '||
			  ' nvl ( compras_disp,0), '||
			  ' nvl ( saldo_diferido,0), '||
			  ' nvl ( saldo_total,0), '||
			  ' nvl ( saldo_corte,0), '||
			  ' nvl ( comisionxcobrar,0.00),' ;
	LET v_sql3=  ' nvl ( base_iva,0.00), '||
			  ' nvl ( descuento,0.00), '|| 
			  ' CAST(nvl ( subtotal,0.0) AS CHAR(18)), '|| 
			  ' CAST(nvl ( total,0.0) AS CHAR(18)), '|| 
			  ' nvl ( pagomin_msi,0.00), '||
			  ' CAST(nvl ( val_base_cfdi,0.0) AS CHAR(18)), '||
			  ' CAST(nvl ( iva_intereses_reales_cfdi,0.0) AS CHAR(18)), '||
			  ' CAST(nvl ( intereses_reales_cfdi,0.0) AS CHAR(18)), '||
			  ' nvl ( mtomensgral_pagosfijos,0.0), '||
			  ' CAST(nvl ( iva_cfdi,0.0) AS CHAR(18)), '||
			  ' nvl( trim(term_pagomin_uno),'''' ), '||
			  ' nvl( trim(pago_int_uno),'''' ), '||
			  ' nvl( trim(pagomin_dos_plazos),'''' ), '||
			  ' nvl( trim(term_pagomin_dos),'''' ), '||
			  ' nvl( trim(pago_int_dos),'''' ), '||
			  ' nvl( trim(pagomin_cinco_plazos),'''' ), '||
			  ' nvl( trim(term_pagomin_cinco),'''' ), '||
			  ' nvl( trim(pago_int_cinco),'''' ), '||
			  ' nvl( iva_inter_comi,0 ), '||
			  ' nvl( sdo_deudor_total,0 ), '||
			  ' nvl( lim_disp_efectivo,0 ), '||
			  ' nvl( lim_disp_transferencia,0 ), '||
			  ' nvl( sdo_cargo_regular,0 ), '||
			  ' nvl( sdo_cargo_meses,0 ), '||
			  ' nvl( inter_comi,0 ), '||
			  ' nvl( intereses_pag_12m,0 ), '||
			  ' nvl( comisiones_pag_12m,0 ), '||
			  ' nvl( anualidad_pag_12m,0 ), '||
			  ' nvl( dist_carg_dif_msi,0 ), '||
			  ' nvl( dist_carg_dif_con_int,0 ) '||
			  ' FROM sd_encabezado2_edocta a '||
			  ' WHERE a.fecha_emision = '''||pperiodo||'''  AND a.num_credito in (select num_credito from "informix".sd_cred_muestra)  " > query200B.sql';

	LET v_sql = v_sql0||v_sql1||v_sql2||v_sql3;

	system v_sql;
	LET v_sql = "dbaccess bdicred query200B.sql";
	system v_sql;

	LET v_sql = '';
	LET v_sql = "sed 's/|$//g' "||v_ruta||'descargaB.unl'||" >"||v_ruta||'descarga1.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "rm "||v_ruta||'descargaB.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "sed 's/\\//g' "||v_ruta||'descarga1.unl'||" > " ||v_ruta||'descarga2.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "rm "||v_ruta||'descarga1.unl';
	SYSTEM v_sql;
	
	LET v_sql = '';
	LET v_sql = "sed 's/" || '"' ||  "//g' "||v_ruta||'descarga2.unl'||" > " ||v_ruta||'Archivo200'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban';
	SYSTEM v_sql;
	
	LET v_sql = '';
	LET v_sql = "rm "||v_ruta||'descarga2.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = " gzip " || v_ruta||'Archivo200'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban ';
	SYSTEM v_sql;
	  	  
	--FIN DE COMPRIMIR Y COPIAR A LA RUTA DE CFD , EN ESTA SECCION VA PARA CADAD UNO DE LOS MENSAJES


	-----------------DETALLE---------------------------------------------------ARCHIVO 300
	LET v_sql1 = ' UNLOAD TO '||v_ruta||'descarga.unl';
	LET v_sql2 = ' SELECT nvl ( fecha_emision,date(1)), '||
			  ' trim(nvl ( replace ( replace( a.num_credito, ''|'' , '' '' ), ''\'' , '' '' ), '' '' )), '||
			  ' nvl ( secuencia,0), '||
			  ' nvl ( nlinea,0), '||
			  ' nvl ( replace ( replace( fecha_mov, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ), '||
			  ' nvl ( replace ( replace( concepto, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ), '||
			  ' replace ( replace ( replace( '' '', ''|'' , '' '' ), ''\'' , '' '' ), '''','' '' ), '||
			  ' replace ( replace ( replace( '' '', ''|'' , '' '' ), ''\'' , '' '' ), '''','' '' ), '||
			  ' nvl ( replace ( replace( monto, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ), '||
			  ' nvl ( replace ( replace( fecha_operacion, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ), '||
			  ' nvl ( replace ( replace( num_tarjeta, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ) '||
			  ' FROM sd_detalle_edocta a '||
			  ' WHERE a.fecha_emision ='''||pperiodo||''' AND a.num_credito in (select num_credito from "informix".sd_cred_muestra) '||
			  ' AND a.tipo_tarjeta = ''T'' ORDER BY a.num_credito,secuencia,nlinea " '||
			  ' > query300.sql';

	LET v_sql = v_sql0 || v_sql1||v_sql2;

	system v_sql;
	LET v_sql = "dbaccess bdicred query300.sql";
	system v_sql;

	LET v_sql = '';
	LET v_sql = "sed 's/|$//g' "||v_ruta||'descarga.unl'||" >"||v_ruta||'descarga1.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "rm "||v_ruta||'descarga.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "sed 's/" || '"' ||  "//g' "||v_ruta||'descarga1.unl'||" > " ||v_ruta||'Archivo300'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "rm "||v_ruta||'descarga1.unl';
	SYSTEM v_sql;

	--COMPRIMIR Y COPIAR A LA RUTA DE CFD 
	LET v_sql = '';
	LET v_sql = " gzip " || v_ruta||'Archivo300'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban ';
	SYSTEM v_sql;

	--FIN DE COMPRIMIR Y COPIAR A LA RUTA DE CFD , EN ESTA SECCION VA PARA CADAD UNO DE LOS MENSAJES


	-----------------ACLARACIONES---------------------------------------------------ARCHIVO 400
	LET v_sql1 = ' UNLOAD TO '||v_ruta||'descarga.unl';
	LET v_sql2 = ' SELECT a.fecha_emision, trim(a.num_credito) num_credito, nvl ( secuencia,0) secuencia, nvl ( nlinea,0) nlinea, '||
				' nvl ( replace ( replace( fecha_aclara, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ), ' ||
				' '' '', '' '','' '', 0.0, '' ''  FROM bdicred:sd_aclaraciones_edocta a '||
				' WHERE a.fecha_emision = '''||pperiodo||''' AND num_credito = ''400'' UNION ALL  '||
				' SELECT nvl ( fecha_emision,date(1)),'||
				' trim(nvl ( replace ( replace( a.num_credito, ''|'' , '' '' ), ''\'' , '' '' ), '' '' )),'||
				' nvl ( secuencia,0),'||
				' nvl ( nlinea,0),'||
				' nvl ( replace ( replace( fecha_aclara, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
				' nvl ( replace ( replace( folio, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
				' nvl ( replace ( replace( fecha_movimiento, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
				' nvl ( replace ( replace( descripcion, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
				' nvl ( importe,0), '||
				' nvl ( replace ( replace ( estatus_aclara, ''|'' , '''' ), ''\'' , '''' ), '' '' ) '||
				' FROM sd_aclaraciones_edocta a '||
			' WHERE a.fecha_emision ='''||pperiodo||''' AND a.num_credito in (select num_credito from "informix".sd_cred_muestra)  ORDER BY num_credito,secuencia,nlinea"'||
			' > query400.sql';

	LET v_sql = v_sql0 || v_sql1||v_sql2;

	system v_sql;
	LET v_sql = "dbaccess bdicred query400.sql";
	system v_sql;

	LET v_sql = '';
	LET v_sql = "sed 's/|$//g' "||v_ruta||'descarga.unl'||" >"||v_ruta||'descarga1.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "rm "||v_ruta||'descarga.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "sed 's/" || '"' ||  "//g' "||v_ruta||'descarga1.unl'||" > "||v_ruta||'descarga2.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "rm "||v_ruta||'descarga1.unl';
	SYSTEM v_sql;
	
	LET v_sql = '';
	LET v_sql = "sed 's/\\//g' "||v_ruta||'descarga2.unl'||" > " ||v_ruta||'Archivo400'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban';
	SYSTEM v_sql;
	
	LET v_sql = '';
	LET v_sql = "rm "||v_ruta||'descarga2.unl';
	SYSTEM v_sql;

	--COMPRIMIR Y COPIAR A LA RUTA DE CFD 
	LET v_sql = '';
	LET v_sql = " gzip " || v_ruta||'Archivo400'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban ';
	SYSTEM v_sql;

	--FIN DE COMPRIMIR Y COPIAR A LA RUTA DE CFD , EN ESTA SECCION VA PARA CADAD UNO DE LOS MENSAJES


	-----------------MENSAJES ARCHIVO 500 BIS -----------ARCHIVO DE MENSAJES ANTERIOR----------------------------------  
	-----------------MENSAJES---------------------------------------------------
    LET v_sql1 = ' UNLOAD TO '||v_ruta||'descarga500B.unl';
    LET v_sql2 = ' SELECT nvl (fecha_emision,date(1)),'||
                 ' trim(nvl ( replace ( replace( num_credito, ''|'' , '' '' ), ''\'' , '' '' ), '' '' )),'||
                 ' nvl ( secuencia,0),'||
                 ' nvl ( nlinea,0),'||
				 ' replace ( replace ( replace( '' '', ''|'' , '' '' ), ''\'' , '' '' ), '''','' '' ), '||
                 ' nvl ( replace ( replace ( trim(mensajes), ''|'' , '''' ), ''\'' , '''' ), '' '' ) '||
                 ' FROM sd_mensajes_edocta WHERE fecha_emision = '''||pperiodo||''' AND num_credito in (select num_credito from "informix".sd_cred_muestra)  ORDER BY 2,3,4"'||
                 ' > query500B.sql';

	LET v_sql = v_sql0||v_sql1||v_sql2;

	system v_sql;
	LET v_sql = "dbaccess bdicred query500B.sql";
	system v_sql;

	LET v_sql = '';
	LET v_sql = "sed 's/|$//g' "||v_ruta||'descarga500B.unl'||" >"||v_ruta||'descarga1.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "rm "||v_ruta||'descarga500B.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "sed 's/" || '"' ||  "//g' "||v_ruta||'descarga1.unl'||" > "||v_ruta||'descarga2.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "rm "||v_ruta||'descarga1.unl';
	SYSTEM v_sql;
	
	LET v_sql = '';
	LET v_sql = "sed 's/\\//g' "||v_ruta||'descarga2.unl'||" > " ||v_ruta||'Archivo500'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban';
	SYSTEM v_sql;
	
	LET v_sql = '';
	LET v_sql = "rm "||v_ruta||'descarga2.unl';
	SYSTEM v_sql;

	--COMPRIMIR Y COPIAR A LA RUTA DE CFD 
	LET v_sql = '';
	LET v_sql = " gzip " || v_ruta||'Archivo500'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban ';
	SYSTEM v_sql;

	--FIN DE COMPRIMIR Y MOVER  A LA RUTA DE CFD , EN ESTA SECCION VA PARA CADAD UNO DE LOS MENSAJES

	  
    -----------------MENSAJES ARCHIVO 800 ---------------------------------------------
	LET v_sql1 = ' UNLOAD TO '||v_ruta||'descarga800.unl';
	LET v_sql2 = ' SELECT '''||pperiodo||''', clave, secuencia, TRIM(inciso) || '') '' || clave || ''. '' || mensaje FROM bdicred:sd_notas_aclara_edc order by clave,secuencia"'||
			  ' > query800.sql';
			  
	LET v_sql = v_sql0||v_sql1||v_sql2;

	system v_sql;
	LET v_sql = "dbaccess bdicred query800.sql";
	system v_sql;

	LET v_sql = '';
	LET v_sql = "sed 's/|$//g' "||v_ruta||'descarga800.unl'||" >"||v_ruta||'descarga1800.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "rm "||v_ruta||'descarga800.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "sed 's/\\//g' "||v_ruta||'descarga1800.unl'||" > "||v_ruta||'Archivo800'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "rm "||v_ruta||'descarga1800.unl';
	SYSTEM v_sql;


	--COMPRIMIR Y COPIAR A LA RUTA DE CFD 
	LET v_sql = '';
	LET v_sql = " gzip " || v_ruta||'Archivo800'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban ';
	SYSTEM v_sql;

	--FIN DE COMPRIMIR Y COPIAR A LA RUTA DE CFD , EN ESTA SECCION VA PARA CADAD UNO DE LOS MENSAJES
	
	
	-----------------MENSAJES DE GLOSARIO ARCHIVO 801 ---------------------------------------------		
	LET v_sql1 = ' echo "SET ISOLATION TO DIRTY READ; ';
	LET v_sql2 = ' UNLOAD TO '||v_ruta||'descarga801B.unl '||
				' SELECT '''||pperiodo||''', '||
				' nvl ( clave,0),'||
				' nvl ( secuencia,0), '||
				' nvl ( replace ( replace ( termino, ''|'' , '''' ), ''\'' , '''' ), '' '' ), '||
				' nvl ( replace ( replace ( significado, ''|'' , '''' ), ''\'' , '''' ), '' '' ) '||
				' FROM sd_glosario_edc ORDER BY clave,secuencia; " > query801.sql';
			
	LET v_sql = v_sql1||v_sql2;
			
	system v_sql;
	LET v_sql = "dbaccess bdicred query801.sql";
	system v_sql;
																																  
	LET v_sql = '';
	LET v_sql = "sed 's/|$//g' "||v_ruta||'descarga801B.unl'||" >"||v_ruta||'descarga801.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "rm "||v_ruta||'descarga801B.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "sed 's/" || '"' ||  "//g' "||v_ruta||'descarga801.unl'||" > "||v_ruta||'Archivo801'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "rm "||v_ruta||'descarga801.unl';
	SYSTEM v_sql;
			
	LET v_sql = '';
	LET v_sql = " gzip " || v_ruta||'Archivo801'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban ';
	SYSTEM v_sql;
	  
	  
	-----------------PIE DE PAGINA---------------------------------------------------ARCHIVO 600
	LET v_sql1 = ' UNLOAD TO '||v_ruta||'descarga.unl';
	LET v_sql2 = ' SELECT nvl (fecha_emision,date(1)),'||
				' trim(nvl ( replace ( replace( a.num_credito, ''|'' , '' '' ), ''\'' , '' '' ), '' '' )),'||
				' nvl ( replace ( replace( tasa_mensual, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
				' nvl ( replace ( replace( round(tasa_anual,1), ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
				' nvl ( replace ( replace( round(cat,1), ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
				' nvl ( replace ( replace( saldo_promedio, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
				' nvl ( tasa_mora,0),'||
				' case when nvl (tasa_mensual_mora,0) - (trim( nvl (tasa_mensual_mora,0)::CHAR(2))::int ) = 0 THEN '||
				' (trim(nvl (tasa_mensual_mora,0)::CHAR(2)))||''.00'' '||
				' else '||
				' (trim(nvl (tasa_mensual_mora,0)::CHAR(2)))||substr(rpad(nvl (tasa_mensual_mora,0) - (trim(nvl (tasa_mensual_mora,0)::CHAR(2))::int ),4,0),2,3) '||
				' end '||
				' FROM sd_pie_edocta a '||
				' WHERE fecha_emision ='''||pperiodo||''' AND a.num_credito in (select num_credito from "informix".sd_cred_muestra)  "' ||
				' > query600.sql';

	LET v_sql = v_sql0||v_sql1||v_sql2;

	system v_sql;
	LET v_sql = "dbaccess bdicred query600.sql";
	system v_sql;

	LET v_sql = '';
	LET v_sql = "sed 's/|$//g' "||v_ruta||'descarga.unl'||" >"||v_ruta||'descarga1.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "rm "||v_ruta||'descarga.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "sed 's/" || '"' ||  "//g' "||v_ruta||'descarga1.unl'||" > " ||v_ruta||'Archivo600'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "rm "||v_ruta||'descarga1.unl';
	SYSTEM v_sql;

	--COMPRIMIR ARCHIVO GENERADO
	LET v_sql = '';
	LET v_sql = " gzip " || v_ruta||'Archivo600'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban ';
	SYSTEM v_sql;

	--- ARCHIVO 100 DE CFDI con la atencion del RQI 12 379 Inclusion de Correo Electronico en Archivos de TDC PIQV

	  
	--------------ENCABEZADO UNO---------------------------------------------------ARCHIVO 100
	LET v_sql1 = ' UNLOAD TO '||trim(v_ruta)||'descargaB.unl';
	LET v_sql2 = ' SELECT a.fecha_emision, a.num_credito, '' '', ''0'',''0'',''0'',''0'',''0'',''0'',''0'',''0'',''0'',''0'',''0'',''0'',''0'',ruta,'' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '' '||
				' FROM bdicred:sd_encabezado_edocta a '||
				' WHERE a.fecha_emision = '''||pperiodo||''' AND a.num_credito IN (''100'', ''000'') UNION ALL  '||
				' SELECT nvl ( fecha_emision,DATE(1)),'||
				' nvl ( replace ( replace( a.num_credito, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
				' nvl ( replace ( replace( num_producto, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
				' nvl ( replace ( replace( numcte, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
				' replace ( replace ( replace( num_tarjeta, ''|'' , '' '' ), ''\'' , '' '' ), '''','' '' ),'||
				' nvl ( replace ( replace( replace( nombre_cte, ''|'' , '' '' ), ''\'' , '' '' ), ''  '' , '' '' ), '' '' ),'||
				' nvl ( replace ( replace( replace ( direccion_cn, ''|'' , '' '' ), ''\'' , '' '' ), ''Â´'', '' ''), '' '' ),'||
				' replace ( replace ( replace( direccion_col, ''|'' , '' '' ), ''\'' , '' '' ), '''','' '' ),'||
				' replace ( replace ( replace( direccion_del, ''|'' , '' '' ), ''\'' , '' '' ), '''','' '' ) || '' '' || '||
				' replace ( replace ( replace( cp, ''|'' , '' '' ), ''\'' , '' '' ), '''','' '' ) || '' '' || '||
				' replace ( replace ( replace( edo_cd, ''|'' , '' '' ), ''\'' , '' '' ), '''','' '' ), ';
	LET v_sql3 =  ' replace ( replace ( replace( '' '', ''|'' , '' '' ), ''\'' , '' '' ), '''','' '' ),'||
				' nvl ( replace ( replace( replace ( cl_cobra, ''|'' , '' '' ), ''\'' , '' '' ) , ''Â´'', '' ''), '' '' ),'||
				' nvl ( replace ( replace( sucursal_nombre, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
				' replace ( replace ( replace( '' '', ''|'' , '' '' ), ''\'' , '' '' ), '''','' '' ),'||
				' nvl ( replace ( replace( rfc, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
				' replace ( replace ( replace( '' '', ''|'' , '' '' ), ''\'' , '' '' ), '''','' '' ),'||
				' nvl ( replace ( replace( cp, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
				' replace ( replace ( replace ( replace( ruta, ''|'' , '' '' ), ''\'' , '' '' ), '''','' '' ), ''Â´'', '' ''),'||
				' replace ( replace ( replace( '' '', ''|'' , '' '' ), ''\'' , '' '' ), '''','' '' ),'||
				' replace ( replace ( replace( trim( observaciones), ''|'' , '' '' ), ''\'' , '' '' ), '''','' '' ),'||
				' nvl ( replace ( replace( insertos, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),';
	LET v_sql4 =  ' nvl ( replace ( replace( sucursal, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
				' nvl ((SELECT TRIM(NVL(b.correo_elec,'' '')) FROM bdinteg:si_correos b WHERE b.numcte = a.numcte '||
				' AND b.secuencia IN (select max(d.secuencia) FROM bdinteg:si_correos d  WHERE d.numcte = a.numcte AND d.tipo_correo = b.tipo_correo '||
				' AND d.status_correo = b.status_correo AND d.valido = b.valido) AND b.tipo_correo = 1 AND b.status_correo = ''A'' AND b.valido = ''1'' '||
				' and b.numcte not in (select c.numcte from bdinteg:"informix".si_altaserv_edoctamov c where c.empresa = ''001'' and c.numcte = b.numcte)),'' ''),'||
				' nvl ( replace ( replace( confirmacion, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
				' nvl((SELECT TRIM(NVL(b.cuenta_clabe,'' '')) FROM bdicred:sd_maecred b where b.num_credito = a.num_credito), '' ''),'||
				' nvl ( replace ( replace( num_ciudad_coppel, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
				' nvl ( replace ( replace( num_region, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
				' nvl ( replace ( replace( ec_edocta, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
				' nvl ((SELECT TRIM(valor) FROM sd_param WHERE empresa = ''' || pempresa || ''' AND cod_param = ''135''), '' ''),'||
				' nvl ((SELECT TRIM(valor) FROM sd_param WHERE empresa = ''' || pempresa || ''' AND cod_param = ''136''), '' ''),'||
				' nvl ( replace ( replace( obj_imp, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
				' nvl ( replace ( replace( base_cfdi, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ) ';
	LET v_sql5=  ' FROM sd_encabezado_edocta a '||
				' WHERE a.fecha_emision = '''||TO_CHAR(pperiodo,'%m/%d/%Y')||''' AND a.num_credito  in (select num_credito from "informix".sd_cred_muestra) order by ruta " > query100B.sql';

	LET v_sql = v_sql0||v_sql1||v_sql2||v_sql3||v_sql4||v_sql5;
	system v_sql;

	LET v_sql = "dbaccess bdicred query100B.sql";
	system v_sql;

	LET v_sql = '';
	LET v_sql = "sed 's/|$//g' "||v_ruta||'descargaB.unl'||" >"||v_ruta||'descarga1B.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "sed 's/Â´/ /g' "||v_ruta||'descarga1B.unl'||" >"||v_ruta||'descarga2B.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = 'sed "s/''/ /g" '||v_ruta||'descarga2B.unl'||" >"||v_ruta||'descarga1B.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "sed 's/&/ /g' "||v_ruta||'descarga1B.unl'||" >"||v_ruta||'descarga2B.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "sed 's/Â¨/ /g' "||v_ruta||'descarga2B.unl'||" >"||v_ruta||'descarga1B.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "sed 's/>/ /g' "||v_ruta||'descarga1B.unl'||" >"||v_ruta||'descarga2B.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "sed 's/</ /g' "||v_ruta||'descarga2B.unl'||" >"||v_ruta||'descarga1B.unl';
	SYSTEM v_sql;
	  
	LET v_sql = '';
	LET v_sql = 'echo " cd '|| '\"'||v_ruta||'\"'||'" > eliminaespeciales.sh ' ;
	SYSTEM v_sql;
	  
	LET v_sql = '';
	LET v_sql = "chmod 777 "||'eliminaespeciales.sh ';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = ' echo '||'"'||' sed  -e ''s/''\$(echo ['||'\"'||'\\\001\\\002\\\003\\\004\\\005\\\006\\\007\\\010\\\016\\\017\\\020\\\021'||		                     
							 '\\\022\\\023\\\024\\\025\\\026\\\027\\\030\\\031\\\032\\\033\\\034\\\035\\\036\\\037'||
						  '\"'||'])''//g'' '||v_ruta||'descarga1B.unl'||" > "||v_ruta||'descarga2B.unl'||
						  '" >>'||'eliminaespeciales.sh ';
	SYSTEM v_sql;
	  
	  
	LET v_sql = '';
	LET v_sql = "./"||'eliminaespeciales.sh ';
	SYSTEM v_sql;
	  
	let v_sql = '';
	LET v_sql = "rm "||v_ruta||'descargaB.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "sed 's/" || '"' ||  "//g' "||v_ruta||'descarga2B.unl'||" > " || trim(v_ruta||'Archivo100'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban');
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "rm "||v_ruta||'descarga1B.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "rm "||v_ruta||'descarga2B.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = " gzip " || v_ruta||'Archivo100'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban ';
	SYSTEM v_sql;
	
	LET v_sql = '';
	LET v_sql = "rm "||'eliminaespeciales.sh ';
	SYSTEM v_sql;
	  
	--- ARCHIVO 100 DE CFDI con la atencion del RQI 12 379 Inclusion de Correo Electronico en Archivos de TDC PIQV

	--FIN DE COMPRIMIR Y COPIAR A LA RUTA DE CFD , EN ESTA SECCION VA PARA CADAD UNO DE LOS MENSAJES

    LET v_sql3= "";
    
    
	--------------------- ARCHIVO 900 CREDISOLUCIONES --------------------
	LET v_sql1 = ' UNLOAD TO '||v_ruta||'descarga.unl';				
	LET v_sql4 = ' SELECT nvl ( fecha_emision,date(1)),'||
				 ' trim(a.num_credito) num_credito,'||
				 ' nvl (secuencia,0),'||
				 ' nvl (nlinea,0),'||
				 ' nvl (prox_fecha_pago,date(1)),'||
				 ' concepto,'||
				 ' nvl (tasa,0),'||
				 ' nvl (saldo_pendiente,0),'||
				 ' replace (replace(numero_cuotas,''.0'',''''),''/'','''')::integer ' ||'||''/''||'||'"plazo",'||
				 ' nvl (monto_prox_pago,0),'||
				 ' nvl (fecha_oper,date(1)),'||
				 ' nvl (monto_ori,0),'||
				 ' nvl (int_periodo,0),'||
				 ' nvl (iva_int_periodo,0),'||
				 ' '' '','||
				 ' tipo_tarjeta '||
				 ' FROM sd_detalle_dif_edocta a'||
				 ' WHERE a.fecha_emision = '''||pperiodo||''' AND a.num_credito = ''900'' '||
				 'UNION ALL';
	LET v_sql2 = ' SELECT nvl ( fecha_emision,date(1)),'||
				 ' trim(nvl ( replace ( replace( a.num_credito, ''|'' , '' '' ), ''\'' , '' '' ), '' '' )),'||
				 ' nvl (secuencia,0),'||
				 ' nvl (nlinea,0),'||
				 ' nvl (prox_fecha_pago,date(1)),'||
				 ' concepto,'||
				 ' nvl (tasa,0),'||
				 ' nvl (saldo_pendiente,0),'||
				 --' replace (replace(numero_cuotas,''.0'',''''),''/'','''')::integer + 1  ' ||'||''/''||'||'"plazo",'||
				 ' replace (replace(numero_cuotas,''.0'',''''),''/'','''')::integer  ' ||'||''/''||'||'"plazo",'||
				 ' nvl (monto_prox_pago,0),'||
				 ' nvl (fecha_oper,date(1)),'||
				 ' nvl (monto_ori,0),'||
				 ' nvl (int_periodo,0),'||
				 ' nvl (iva_int_periodo,0),'||
				 ' replace ( replace ( replace( trim(a.num_tar_ori), ''|'' , '' '' ), ''\'' , '' '' ), '''','' '' ), '||
				 ' replace ( replace ( replace( a.tipo_tarjeta, ''|'' , '' '' ), ''\'' , '' '' ), '''','' '' )'||
				 ' FROM sd_detalle_dif_edocta a';
	LET v_sql3 = ' WHERE a.fecha_emision = '''||pperiodo||''' AND a.num_credito in (select num_credito from "informix".sd_cred_muestra) " > query900.sql';
		                                                                                   
	LET v_sql = v_sql0||v_sql1||v_sql2||v_sql3;

	system v_sql;
	LET v_sql = "dbaccess bdicred query900.sql";
	system v_sql;
		 
	LET v_sql = '';
	LET v_sql = "sed 's/|$//g' "||v_ruta||'descarga.unl'||" >"||v_ruta||'descarga1.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "rm "||v_ruta||'descarga.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "sed 's/" || '"' ||  "//g' "||v_ruta||'descarga1.unl'||" > " ||v_ruta||'Archivo900'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = " gzip " || v_ruta||'Archivo900'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban ';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "rm "||v_ruta||'descarga1.unl'; 
	SYSTEM v_sql;
	
	
	--------------------------------ARCHIVO 201 Sdos sobre Interes Periodo------------------------------   
	LET v_sql1 = ' UNLOAD TO '|| v_ruta ||'descargSdosInterPer.unl' ;
	LET v_sql2 = ' SELECT fecha_emision, trim(num_credito) num_credito, 0 secuencia, '' '', '' '', '' '', '' '', '' '', '' '' '||  
				 ' FROM bdicred:sd_sdo_int_periodo_edc'||
				 ' WHERE fecha_emision = '''||pperiodo||''' AND num_credito = ''201'' UNION ALL  '||    
				 ' SELECT nvl (fecha_emision,date(1)), ' ||
				 ' trim(nvl ( replace ( replace( num_credito, ''|'' , '' '' ), ''\'' , '' '' ), '' '' )), '||
				 ' nvl ( secuencia,0),'||
				 ' trim(nvl ( replace ( replace( descripcion, ''|'' , '' '' ), ''\'' , '' '' ), '' '' )), '||
				 ' nvl ( replace ( replace( sdo_base, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ), '||
				 ' nvl ( replace ( replace( dias_periodo, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ), '||
				 ' nvl ( replace ( replace( tasa_inter_aplicable, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ), '||
				 ' nvl ( replace ( replace( monto_interes, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ), '||
				 ' nvl ( replace ( replace( tipo_proceso, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ) '||
				 ' FROM bdicred:sd_sdo_int_periodo_edc '||
				 ' WHERE fecha_emision = '''||pperiodo||''' AND num_credito in (select num_credito from "informix".sd_cred_muestra) ORDER BY num_credito,secuencia " > query201.sql' ;

	LET v_sql = v_sql0||v_sql1||v_sql2 ;

	system v_sql;
	LET v_sql = "dbaccess bdicred query201.sql";
	system v_sql;

	LET v_sql = '';
	LET v_sql = "sed 's/|$//g' "||v_ruta||'descargSdosInterPer.unl'||" >"||v_ruta||'descarga1.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "rm "||v_ruta||'descargSdosInterPer.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "sed 's/" || '"' ||  "//g' "||v_ruta||'descarga1.unl'||" > " ||v_ruta||'Archivo201'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "rm "||v_ruta||'descarga1.unl';
	SYSTEM v_sql;

	  --COMPRIMIR ARCHIVO GENERADO
	LET v_sql = '';
	LET v_sql = " gzip " || v_ruta||'Archivo201'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban ';
	SYSTEM v_sql;
	
	
	--------------------- ARCHIVO 301 MESES SIN INTERESES --------------------
	LET v_sql1 = ' UNLOAD TO '||v_ruta||'descargaMSI.unl';
	LET v_sql4 = ' SELECT nvl ( a.fecha_emision,date(1)), '||
				 ' trim(a.num_credito) num_credito, '||
				 --' LPAD(DAY(fecha_compra),2,''0'') || ''/'' || LPAD(MONTH(fecha_compra),2,''0'') || ''/'' || YEAR(fecha_compra), '||
				 ' nvl (fecha_compra,date(1)),'||
				 ' nvl ( replace ( replace ( a.comercio, ''|'' , '''' ), ''\'' , '''' ), '' '' ), '||
				 ' replace (replace(a.plazo,''.0'',''''),''/'','''')::integer ' ||'||''/''||'||'"numero_cuotas",'||
				 ' nvl (a.saldo_total_compra,0.0), '||
				 ' nvl (a.msipagomin,0.0), '||
				 ' nvl (a.saldo_total_deudor,0.0), '||
				 ' trim(a.tasa_int_aplicable), '||
				 ' nvl ( replace ( replace ( a.num_tarjeta, ''|'' , '''' ), ''\'' , '''' ), '''' ), '||
				 ' a.tipo_tarjeta '||
				 ' FROM sd_detalle_msi_edocta a '||
				 ' WHERE a.fecha_emision = '''||pperiodo||''' AND a.num_credito = ''301'' '||
				 'UNION ALL';
	LET v_sql2 = ' SELECT nvl ( a.fecha_emision,date(1)), '||
				 ' trim(nvl ( replace ( replace( a.num_credito, ''|'' , '' '' ), ''\'' , '' '' ), '' '' )), '||
				 --' LPAD(DAY(fecha_compra),2,''0'') || ''/'' || LPAD(MONTH(fecha_compra),2,''0'') || ''/'' || YEAR(fecha_compra), '||
				 ' nvl (fecha_compra,date(1)),'||
				 ' replace ( replace ( replace( trim(a.num_sol_prestamo), ''|'' , '' '' ), ''\'' , '' '' ), '''','' '' ) || '' '' || '||
				 ' replace ( replace ( replace( trim(a.comercio), ''|'' , '' '' ), ''\'' , '' '' ), '''','' '' ) || '' '' || '||
				 ' replace ( replace ( replace( trim(a.descripcion), ''|'' , '' '' ), ''\'' , '' '' ), '''','' '' ), '||
				 --' replace (replace(a.plazo,''.0'',''''),''/'','''')::integer  ' ||'||''/''||'||' replace (replace(numero_cuotas,''.00'',''''),''/'','''')::integer,'||
				 ' replace (replace(numero_cuotas,''.00'',''''),''/'','''')::integer  ' ||'||''/''||'||' replace (replace(a.plazo,''.0'',''''),''/'','''')::integer,'||
				 ' nvl (a.saldo_total_compra,0.0), '||
				 ' nvl (a.msipagomin,0.0), '||
				 ' nvl (a.saldo_total_deudor,0.0), '||
				 ' trim(a.tasa_int_aplicable), '||
				 ' replace ( replace ( replace( trim(a.num_tarjeta), ''|'' , '' '' ), ''\'' , '' '' ), '''','' '' ), '||
				 ' nvl ( replace ( replace( trim(a.tipo_tarjeta), ''|'' , '' '' ), ''\'' , '' '' ), '' '' )'||
				 ' FROM sd_detalle_msi_edocta a';
	LET v_sql3 = ' WHERE a.fecha_emision = '''||pperiodo||''' AND status in(''2'',''6'') AND a.num_credito in (select num_credito from "informix".sd_cred_muestra) " > query301.sql';

	LET v_sql = TRIM(v_sql0)||" "||TRIM(v_sql1)||" "||TRIM(v_sql4)||" "||TRIM(v_sql2)||" "||TRIM(v_sql3);

	system v_sql;
	LET v_sql = "dbaccess bdicred query301.sql";
	system v_sql;
			 
	LET v_sql = '';
	LET v_sql = "sed 's/|$//g' "||v_ruta||'descargaMSI.unl'||" >"||v_ruta||'descargaMSI1.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "rm "||v_ruta||'descargaMSI.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "sed 's/" || '"' ||  "//g' "||v_ruta||'descargaMSI1.unl'||" > " ||v_ruta||'descargaMSI2.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "rm "||v_ruta||'descargaMSI1.unl';
	SYSTEM v_sql;
	
	LET v_sql = '';
	LET v_sql = "sed 's/\\//g' "||v_ruta||'descargaMSI2.unl'||" > " ||v_ruta||'Archivo301'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban';
	SYSTEM v_sql;
	
	LET v_sql = '';
	LET v_sql = "rm "||v_ruta||'descargaMSI2.unl';
	SYSTEM v_sql;

	--COMPRIMIR Y COPIAR A LA RUTA DE CFD 
	LET v_sql = '';
	LET v_sql = " gzip " || v_ruta||'Archivo301'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban ';
	SYSTEM v_sql;
	
	
	------------- ARCHIVO 302 coppel max --------------------            
	LET v_sql1 = ' UNLOAD TO '|| v_ruta ||'descargaCmax.unl' ;
	LET v_sql2 = ' SELECT fecha_emision, trim(num_credito), nvl (sdo_inicio_elect,0),nvl (dro_elect_utilizado,0),nvl (dro_elect_vencido,0),nvl (dro_elect_obt,0), '||
				 ' nvl(dro_elect_x_venc,0),nvl(sdo_fin_dro_elect,0),nvl(equivale_pesos,0) '|| 
				 ' FROM bdicred:sd_coppelmax_edc '||
				 ' WHERE fecha_emision = '''||pperiodo||''' AND num_credito = ''302'' UNION ALL  '||    
				 ' SELECT nvl (fecha_emision,date(1)),  ' ||
				 ' trim(nvl ( replace ( replace( num_credito, ''|'' , '' '' ), ''\'' , '' '' ), '' '' )),'||
				 ' nvl ( sdo_inicio_elect,0), ' || 
				 ' nvl ( dro_elect_utilizado,0), ' ||  
				 ' nvl ( dro_elect_vencido,0), ' || 
				 ' nvl ( dro_elect_obt,0), ' || 
				 ' nvl ( dro_elect_x_venc,0), ' || 
				 ' nvl ( sdo_fin_dro_elect,0), ' ||
				 ' nvl ( equivale_pesos,0) ' || 
				 ' FROM bdicred:sd_coppelmax_edc '||
				 --' WHERE fecha_emision = '''||pperiodo||''' AND num_credito in (select num_credito from "informix".sd_cred_muestra) " > query302.sql' ;
				 ' WHERE fecha_emision = '''||pperiodo||''' AND num_credito = ''302'' " > query302.sql' ;
											   
	LET v_sql = v_sql0||v_sql1||v_sql2 ;

	system v_sql;
	LET v_sql = "dbaccess bdicred query302.sql";
	system v_sql;

	LET v_sql = '';
	LET v_sql = "sed 's/|$//g' "||v_ruta||'descargaCmax.unl'||" >"||v_ruta||'descarga1.unl';																															  
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "rm "||v_ruta||'descargaCmax.unl';																															 																															   																															 
	SYSTEM v_sql;

	LET v_sql = '';																																	 
	LET v_sql = "sed 's/" || '"' ||  "//g' "||v_ruta||'descarga1.unl'||" > " ||v_ruta||'Archivo302'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "rm "||v_ruta||'descarga1.unl';
																																
	SYSTEM v_sql;

	  --COMPRIMIR ARCHIVO GENERADO
	LET v_sql = '';
	LET v_sql = " gzip " || v_ruta||'Archivo302'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban ';
	SYSTEM v_sql;
		
	---------------- 303 DETALLE DE MOVIMIENTO DE LAS TARJETAS ADICIONALES------------------------------------------------------------------- 
	LET v_sql1 = ' UNLOAD TO '||v_ruta||'descargaDetMovAdi.unl';
	LET v_sql2 = ' SELECT a.fecha_emision, trim(num_credito) num_credito, nvl ( secuencia,0)secuencia ,nvl ( nlinea,0) nlinea, ''0'', ''0'', ''0'', ''0'', ''0'' FROM bdicred:sd_detalle_edocta a '||
			  ' WHERE a.fecha_emision = '''||pperiodo||''' AND num_credito = ''303'' UNION ALL  '||                        
			  ' SELECT nvl ( fecha_emision,DATE(1)),'||
			  ' trim(nvl ( replace ( replace( a.num_credito, ''|'' , '' '' ), ''\'' , '' '' ), '' '' )),'||
			  ' nvl ( secuencia,0),'||
			  ' nvl ( nlinea,0),'||
			  ' nvl ( replace ( replace( fecha_mov, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ), '||
			  ' nvl ( replace ( replace( concepto, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ), '||
			  ' nvl ( replace ( replace( monto, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
			  ' nvl ( replace ( replace( fecha_operacion, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ), '||
			  ' nvl ( replace ( replace( num_tarjeta, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ) '||
			  ' FROM sd_detalle_edocta a '||
			  ' WHERE a.fecha_emision ='''||pperiodo||''' AND a.num_credito in (select num_credito from "informix".sd_cred_muestra) '||  
			  ' AND a.tipo_tarjeta = ''A'' ORDER BY num_credito,secuencia,nlinea" '||
			  ' > query303.sql';
						
	LET v_sql = v_sql0||v_sql1||v_sql2;

	system v_sql;
	LET v_sql = "dbaccess bdicred query303.sql";
	system v_sql;

	LET v_sql = '';
	LET v_sql = "sed 's/|$//g' "||v_ruta||'descargaDetMovAdi.unl'||" >"||v_ruta||'descarga1.unl';
						  
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "rm "||v_ruta||'descargaDetMovAdi.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "sed 's/" || '"' ||  "//g' "||v_ruta||'descarga1.unl'||" > " ||v_ruta||'Archivo303'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "rm "||v_ruta||'descarga1.unl';
	SYSTEM v_sql;

	--COMPRIMIR Y COPIAR A LA RUTA DE CFD
	LET v_sql = '';
	LET v_sql = " gzip " || v_ruta ||'Archivo303'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban ';
	SYSTEM v_sql;
		
	------------- ARCHIVO 304 lineas adicionales -------------------- 
	LET v_sql1 = ' UNLOAD TO '|| v_ruta ||'descargLineasAdic.unl' ;
	LET v_sql2 = ' SELECT fecha_emision, trim(num_credito), nvl (fecha_oper_adi,DATE(1)),'' '',nvl (monto_orig_adi,0),nvl (saldo_pend_adi,0), '||
				 ' nvl (intereses_peri_adi,0),nvl (iva_peri_adi,0), nvl (pago_requ_adi,0), nvl (numero_pago_adi,0), nvl (tasa_apli_adi,0), nvl (credito_adic_adi,0), nvl (fecha_adic_adi,DATE(1)) '|| 
				 ' FROM bdicred:sd_lineas_adicionales_edc '||
				 ' WHERE fecha_emision = '''||pperiodo||''' AND num_credito = ''304'' UNION ALL '||    
				 ' SELECT nvl (fecha_emision,date(1)),  '||
				 ' trim(nvl ( replace ( replace( num_credito, ''|'' , '' '' ), ''\'' , '' '' ), '' '' )), '||
				 ' nvl ( fecha_oper_adi,DATE(1)), '|| 
				 ' trim(nvl ( replace ( replace( descripcion_Desc_adi, ''|'' , '' '' ), ''\'' , '' '' ), '' '' )), '||
				 ' nvl ( monto_orig_adi,0), '||  
				 ' nvl ( saldo_pend_adi,0), '|| 
				 ' nvl ( intereses_peri_adi,0), '||
				 ' nvl ( iva_peri_adi,0), '|| 
				 ' nvl ( pago_requ_adi,0), '||  
				 ' nvl ( numero_pago_adi,0), '||
				 ' nvl ( tasa_apli_adi,0), '||
				 ' nvl (credito_adic_adi,0), '||
				 ' nvl (fecha_adic_adi,DATE(1)) '||
				 ' FROM bdicred:sd_lineas_adicionales_edc '||
				 ' WHERE fecha_emision = '''||pperiodo||''' AND num_credito in (select num_credito from "informix".sd_cred_muestra) " > query304.sql' ;

	LET v_sql = v_sql0||v_sql1||v_sql2 ;								 

	system v_sql;
	LET v_sql = "dbaccess bdicred query304.sql";
	system v_sql;

	LET v_sql = '';
	LET v_sql = "sed 's/|$//g' "||v_ruta||'descargLineasAdic.unl'||" >"||v_ruta||'descarga1.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "rm "||v_ruta||'descargLineasAdic.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "sed 's/" || '"' ||  "//g' "||v_ruta||'descarga1.unl'||" > " ||v_ruta||'descarga2.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "rm "||v_ruta||'descarga1.unl';
	SYSTEM v_sql;
	
	LET v_sql = '';
	LET v_sql = "sed 's/\\//g' "||v_ruta||'descarga2.unl'||" > " ||v_ruta||'Archivo304'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban';
	SYSTEM v_sql;
	
	LET v_sql = '';
	LET v_sql = "rm "||v_ruta||'descarga2.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = " gzip " || v_ruta ||'Archivo304'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban ';
	SYSTEM v_sql;
	
	
	----- ARCHIVO 802 Mensajes Gnerales_MA_AQ --------------------
	LET v_sql1 = ' UNLOAD TO '|| v_ruta ||'descargaGneralMA_QA.unl ';
	LET v_sql2 = ' SELECT nvl (fecha_emision,date(1)), ' ||
				 ' nvl ( secuencia,0), ' || 
				 ' nvl ( nlinea,0), ' || 
				 ' nvl ( mensaje,'' ''), ' || 
				 ' trim(nvl ( replace ( replace( tipo_mens, ''|'' , '' '' ), ''\'' , '' '' ), '' '' )) '||
				 ' FROM bdicred:sd_mensajes_mensual_edocta '||
				 ' WHERE fecha_emision = '''||pperiodo||''' " > query802.sql' ;

	LET v_sql = v_sql0||v_sql1||v_sql2 ;

	system v_sql;
	LET v_sql = "dbaccess bdicred query802.sql";
	system v_sql;

	LET v_sql = '';
	LET v_sql = "sed 's/|$//g' "||v_ruta||'descargaGneralMA_QA.unl'||" >"||v_ruta||'descarga1.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "rm "||v_ruta||'descargaGneralMA_QA.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "sed 's/" || '"' ||  "//g' "||v_ruta||'descarga1.unl'||" > " ||v_ruta||'Archivo802'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "rm "||v_ruta||'descarga1.unl';
	SYSTEM v_sql;

	--COMPRIMIR ARCHIVO GENERADO
	LET v_sql = '';
	LET v_sql = " gzip " || v_ruta||'Archivo802'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban ';
	SYSTEM v_sql;

    
	---------  MOVER ARCHIVOS CREADOS A LA DE CFD ------------------- SOLO VAMOS UTULIZAR EN LA RUTA 
	LET v_sql = '';
	LET v_sql = "mv " || v_ruta|| 'Archivo100'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.gz '||
					   trim(v_ruta_cfd) ||'Archivo100'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.gz ';
	SYSTEM v_sql;

	LET v_sql = ''; 
	LET v_sql = "mv " || v_ruta|| 'Archivo200'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.gz '||
					   trim(v_ruta_cfd) ||'Archivo200'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.gz ';
	SYSTEM v_sql; 

	LET v_sql = '';
	LET v_sql = "mv " || v_ruta|| 'Archivo201'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.gz '||
					   trim(v_ruta_cfd) ||'Archivo201'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.gz ';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "mv " || v_ruta|| 'Archivo300'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.gz '||
					   trim(v_ruta_cfd) ||'Archivo300'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.gz ';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = " mv " || v_ruta|| 'Archivo301'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.gz '||
					   trim(v_ruta_cfd) ||'Archivo301'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.gz ';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "mv " || v_ruta|| 'Archivo302'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.gz '||
					   trim(v_ruta_cfd) ||'Archivo302'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.gz ';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "mv " || v_ruta|| 'Archivo303'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.gz '||
					   trim(v_ruta_cfd) ||'Archivo303'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.gz ';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "mv " || v_ruta|| 'Archivo304'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.gz '||
					   trim(v_ruta_cfd) ||'Archivo304'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.gz ';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "mv " || v_ruta|| 'Archivo400'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.gz '||
					   trim(v_ruta_cfd) ||'Archivo400'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.gz ';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "mv " || v_ruta|| 'Archivo500'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.gz '||
					   trim(v_ruta_cfd) ||'Archivo500'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.gz ';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "mv " || v_ruta|| 'Archivo600'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.gz '||
					   trim(v_ruta_cfd) ||'Archivo600'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.gz ';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "mv " || v_ruta|| 'Archivo800'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.gz '||
					   trim(v_ruta_cfd) ||'Archivo800'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.gz ';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "mv " || v_ruta|| 'Archivo801'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.gz '||
					   trim(v_ruta_cfd) ||'Archivo801'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.gz ';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "mv " || v_ruta|| 'Archivo802'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.gz '||
					   trim(v_ruta_cfd) ||'Archivo802'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.gz ';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "mv " || v_ruta|| 'Archivo900'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.gz '||
					   trim(v_ruta_cfd) ||'Archivo900'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.gz ';
	SYSTEM v_sql;
		

	  
	-----FIN DE COPIAR A LA RUTA DE CFD.
	LET v_sql = '';
	LET v_sql = 'rm query100B.sql ';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = 'rm query201.sql ';
	SYSTEM v_sql;

	LET v_sql = ''; 
	LET v_sql = 'rm query200B.sql '; 
	SYSTEM v_sql; 

	LET v_sql = '';
	LET v_sql = 'rm query300.sql ';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = 'rm query301.sql ';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = 'rm query302.sql ';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = 'rm query303.sql ';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = 'rm query304.sql ';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = 'rm query400.sql ';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = 'rm query500B.sql ';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = 'rm query600.sql ';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = 'rm query800.sql ';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = 'rm query801.sql ';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = 'rm query802.sql ';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = 'rm query900.sql ';
	SYSTEM v_sql;

  END;
  RETURN cod_ret;

END PROCEDURE;
CREATE PROCEDURE "informix".sp_valida_gastos_bonificacion(pEmpresa CHAR(3), pCredito CHAR(20), pMontoImporteAnual DECIMAL(9,2), pMontoImporteMensual DECIMAL(9,2),
					pFechaAnualidad DATE, pBanderaBonificacion CHAR(1), pFecha1erAnual DATE, pMontoImportePrimerMes DECIMAL(9,2), pNumProducto CHAR(4))
   RETURNING CHAR(5);
   
   -- **************************************************************************
   -- *                      DEFINICION DE VARIABLES                           *
   -- **************************************************************************
   /*
   pEmpresa					Parametro estandar en los spl, ocupado en indices de busquedas.
   pCredito					Parametro que contiene el numero de credito a consultar/validar.
   pMontoImporteAnual		Parametro que equivale al monto que debe cubrir el credito en un anio.
   pMontoImporteMensual 	Parametro que equivale al monto que debe cubrir el credito mensualmente.
   pFechaAnualidad				Parametro que contiene la fecha inicio de busqueda de movimientos.
   pBanderaBonificacion 	Parametro que verificara 1 = bonificacion anual, 2 = bonificacion mensual, 3 = Ambas ( si no cumple la mensual, validara anual).
   pFecha1erAnual			Parametro que contendrÃ¡ la primera fecha en la que se llevo a cabo la bonificacion, si es null o igual a DATE(1) quiere decir que no ha pasado por el proceso y deberÃ¡ tomar en cuenta el primer mes de importe
   pMontoImportePrimerMes	Parametro que equivale al monto que debe cubrir el credito el primer mes de la evaluacion.
   */
   --EXECUTE PROCEDURE sp_valida_gastos_bonificacion('001','540000000336',720000,40000,mdy(1,5,2025),'3',mdy(1,5,2025),40000,'5400');
   --EXECUTE PROCEDURE sp_valida_gastos_bonificacion('001','540000000005',720000,40000,mdy(10,12,2024),'3',mdy(10,12,2024),40000,'5400');
   DEFINE cod_ret             		  CHAR(5);
   DEFINE cod_ret2             		  CHAR(5);
   DEFINE cCod_ret_anual       		  CHAR(5);
   DEFINE cCod_ret_mes         		  CHAR(5);
   DEFINE cCod_ret_mesAux     		  CHAR(5);
   DEFINE sql_err             		  SMALLINT;
   DEFINE isam_err            		  SMALLINT;
   DEFINE error_info          		  CHAR(40);
   DEFINE dFechaHoy			  		  DATE;
   DEFINE dFechaAnualidad	  		  DATE;
   DEFINE dFechaInicio		  		  DATE;
   DEFINE sDiaCorte					  SMALLINT;
   DEFINE sAnioRegistro				  SMALLINT;
   DEFINE sContador					  SMALLINT;
   DEFINE dFechaPrimerCorte			  DATE;
   DEFINE cMesCorrespondiente		  CHAR(2);
   DEFINE cRetBonificacionAnual		  CHAR(5);
   DEFINE dGastoEnero				  DECIMAL(14,2);
   DEFINE dGastoFebrero               DECIMAL(14,2);
   DEFINE dGastoMarzo                 DECIMAL(14,2);
   DEFINE dGastoAbril                 DECIMAL(14,2);
   DEFINE dGastoMayo                  DECIMAL(14,2);
   DEFINE dGastoJunio                 DECIMAL(14,2);
   DEFINE dGastoJulio                 DECIMAL(14,2);
   DEFINE dGastoAgosto                DECIMAL(14,2);
   DEFINE dGastoSeptiembre            DECIMAL(14,2);
   DEFINE dGastoOctubre               DECIMAL(14,2);
   DEFINE dGastoNoviembre             DECIMAL(14,2);
   DEFINE dGastoDiciembre             DECIMAL(14,2);
   DEFINE dGastoTotalAnual			  DECIMAL(14,2);
   
  -- **************************************************************************
  -- *                      ASIGNACION DE VARIABLES                           *
  -- **************************************************************************
  
   LET cod_ret             		   = '00000';
   LET cod_ret2            		   = '00000';
   LET cCod_ret_anual       	   = '00000';
   LET cCod_ret_mes         	   = '00000';
   LET cCod_ret_mesAux         	   = '00000';
   LET sql_err             		   = 0;
   LET isam_err            		   = 0;
   LET error_info          		   = '';
   LET dFechaHoy		   		   = DATE(1);
   LET sDiaCorte				   = 0;
   LET sAnioRegistro			   = 0;
   LET dFechaPrimerCorte	       = DATE(1);
   LET cMesCorrespondiente				   = '0';
   LET dFechaAnualidad			   = DATE(1);
   LET dFechaInicio				   = DATE(1);
   LET cRetBonificacionAnual	   = '00001';
   LET dGastoEnero				   = 0;	
   LET dGastoFebrero               = 0;
   LET dGastoMarzo                 = 0;
   LET dGastoAbril                 = 0;
   LET dGastoMayo                  = 0;
   LET dGastoJunio                 = 0;
   LET dGastoJulio                 = 0;
   LET dGastoAgosto                = 0;
   LET dGastoSeptiembre            = 0;
   LET dGastoOctubre               = 0;
   LET dGastoNoviembre             = 0;
   LET dGastoDiciembre             = 0;
   LET dGastoTotalAnual			   = 0;
   LET sContador				   = 0;												
   
   
   BEGIN
		
		ON EXCEPTION SET sql_err, isam_err, error_info
			IF sql_err != 0 THEN
				LET cod_ret = sql_err;
				
				RETURN cod_ret;
			END IF;
		END EXCEPTION;
		
		--SET ISOLATION TO DIRTY READ;
		--SET LOCK MODE TO WAIT 3;
		
	--SET DEBUG FILE TO "/home/e90402183/BONIFICACION_TDC/spl/sp_valida_gastos_bonificacion.out";
    --TRACE ON;
	
	SELECT dia_cuota INTO sDiaCorte FROM sd_definicion WHERE empresa = pEmpresa AND num_producto = pNumProducto;
	LET dFechaInicio = monthadd(pFechaAnualidad, -12);
													
	LET dFechaPrimerCorte = MDY(MONTH(dFechaInicio), sDiaCorte, YEAR(dFechaInicio));
		
	IF MONTH(dFechaPrimerCorte) = 1 THEN
		IF dFechaInicio < dFechaPrimerCorte THEN
			LET sAnioRegistro = YEAR(monthadd(dFechaInicio, - 12));
		ELSE
			LET sAnioRegistro = YEAR(dFechaInicio);
		END IF;
	ELSE 
		LET sAnioRegistro = YEAR(dFechaInicio);
	END IF;
	
	IF pBanderaBonificacion = '1' OR pBanderaBonificacion = '3' THEN
	
		SELECT gasto_total_anual INTO dGastoTotalAnual FROM sd_gastos_bonificacion 
			WHERE empresa = pEmpresa AND num_credito = pCredito AND fecha_registro = pFechaAnualidad
				AND anio_registro = sAnioRegistro AND gasto_total_anual IS NOT NULL;
			
		IF dGastoTotalAnual >= pMontoImporteAnual THEN
			LET cCod_ret_anual = '00000';
		ELSE 
			LET cCod_ret_anual = '00001';
		END IF;
		
		UPDATE sd_gastos_bonificacion SET cod_ret_anual = cCod_ret_anual
			WHERE empresa = pEmpresa AND num_credito = pCredito AND fecha_registro = pFechaAnualidad
				AND anio_registro = sAnioRegistro AND gasto_total_anual IS NOT NULL;
	END IF;
	
	IF pBanderaBonificacion = '2' OR pBanderaBonificacion = '3' THEN--EMPIEZA LoGICA PARA BONIFICICACIoN MENSUAL
		
		LET cMesCorrespondiente = '';
		IF dFechaInicio <= dFechaPrimerCorte THEN
			IF MONTH(dFechaPrimerCorte) = 1 THEN
				LET cMesCorrespondiente = '12';
			ELIF MONTH(dFechaPrimerCorte) = 2 THEN
				LET cMesCorrespondiente = '1';
			ELIF MONTH(dFechaPrimerCorte) = 3 THEN
				LET cMesCorrespondiente = '2';
			ELIF MONTH(dFechaPrimerCorte) = 4 THEN
				LET cMesCorrespondiente = '3';
			ELIF MONTH(dFechaPrimerCorte) = 5 THEN
				LET cMesCorrespondiente = '4';
			ELIF MONTH(dFechaPrimerCorte) = 6 THEN
				LET cMesCorrespondiente = '5';
			ELIF MONTH(dFechaPrimerCorte) = 7 THEN
				LET cMesCorrespondiente = '6';
			ELIF MONTH(dFechaPrimerCorte) = 8 THEN
				LET cMesCorrespondiente = '7';
			ELIF MONTH(dFechaPrimerCorte) = 9 THEN
				LET cMesCorrespondiente = '8';
			ELIF MONTH(dFechaPrimerCorte) = 10 THEN
				LET cMesCorrespondiente = '9';
			ELIF MONTH(dFechaPrimerCorte) = 11 THEN
				LET cMesCorrespondiente = '10';
			ELIF MONTH(dFechaPrimerCorte) = 12 THEN
				LET cMesCorrespondiente = '11';
			END IF;
		ELSE 
			IF MONTH(dFechaPrimerCorte) = 1 THEN
				LET cMesCorrespondiente = '1';
			ELIF MONTH(dFechaPrimerCorte) = 2 THEN
				LET cMesCorrespondiente = '2';
			ELIF MONTH(dFechaPrimerCorte) = 3 THEN
				LET cMesCorrespondiente = '3';
			ELIF MONTH(dFechaPrimerCorte) = 4 THEN
				LET cMesCorrespondiente = '4';
			ELIF MONTH(dFechaPrimerCorte) = 5 THEN
				LET cMesCorrespondiente = '5';
			ELIF MONTH(dFechaPrimerCorte) = 6 THEN
				LET cMesCorrespondiente = '6';
			ELIF MONTH(dFechaPrimerCorte) = 7 THEN
				LET cMesCorrespondiente = '7';
			ELIF MONTH(dFechaPrimerCorte) = 8 THEN
				LET cMesCorrespondiente = '8';
			ELIF MONTH(dFechaPrimerCorte) = 9 THEN
				LET cMesCorrespondiente = '9';
			ELIF MONTH(dFechaPrimerCorte) = 10 THEN
				LET cMesCorrespondiente = '10';
			ELIF MONTH(dFechaPrimerCorte) = 11 THEN
				LET cMesCorrespondiente = '11';
			ELIF MONTH(dFechaPrimerCorte) = 12 THEN
				LET cMesCorrespondiente = '12';
			END IF;
		END IF;
		
		IF pFecha1erAnual <> pFechaAnualidad THEN --ya paso por su primer proceso de bonificacion
			LET pMontoImportePrimerMes = pMontoImporteMensual;
		END IF;
		
		FOREACH WITH HOLD  
			SELECT anio_registro,gasto_enero,gasto_febrero,gasto_marzo,gasto_abril,gasto_mayo,gasto_junio,
				   gasto_julio,gasto_agosto,gasto_septiembre,gasto_octubre,gasto_noviembre,gasto_diciembre 
			INTO sAnioRegistro,dGastoEnero,dGastoFebrero,dGastoMarzo,dGastoAbril,dGastoMayo,dGastoJunio,
				 dGastoJulio,dGastoAgosto,dGastoSeptiembre,dGastoOctubre,dGastoNoviembre,dGastoDiciembre
			FROM sd_gastos_bonificacion 
			WHERE empresa = pEmpresa AND num_credito = pCredito AND fecha_registro = pFechaAnualidad ORDER BY anio_registro ASC
			
			IF sContador = 0 THEN
				IF cMesCorrespondiente = '1' THEN
					IF dGastoEnero < pMontoImportePrimerMes THEN 
						LET cCod_ret_mes = '00001';
							
						UPDATE bdicred:sd_gastos_bonificacion SET cod_ret_mensual = cCod_ret_mes WHERE empresa = pEmpresa AND num_credito = pCredito 
							AND fecha_registro = pFechaAnualidad AND anio_registro = sAnioRegistro;
							
						LET sContador = sContador + 1;
						CONTINUE FOREACH;
					ELSE
						IF dGastoFebrero < pMontoImporteMensual OR dGastoMarzo < pMontoImporteMensual OR dGastoAbril < pMontoImporteMensual OR dGastoMayo < pMontoImporteMensual OR 
						   dGastoJunio < pMontoImporteMensual OR dGastoJulio < pMontoImporteMensual OR dGastoAgosto < pMontoImporteMensual OR dGastoSeptiembre < pMontoImporteMensual OR
						   dGastoOctubre < pMontoImporteMensual OR dGastoNoviembre < pMontoImporteMensual OR dGastoDiciembre < pMontoImporteMensual THEN
							LET cCod_ret_mes = '00001';
							
							UPDATE bdicred:sd_gastos_bonificacion SET cod_ret_mensual = cCod_ret_mes WHERE empresa = pEmpresa AND num_credito = pCredito 
								AND fecha_registro = pFechaAnualidad AND anio_registro = sAnioRegistro;
								
							LET sContador = sContador + 1;
							CONTINUE FOREACH;
						END IF;
					END IF;
				ELIF cMesCorrespondiente = '2' THEN
					IF dGastoFebrero < pMontoImportePrimerMes THEN 
						LET cCod_ret_mes = '00001';
							
						UPDATE bdicred:sd_gastos_bonificacion SET cod_ret_mensual = cCod_ret_mes WHERE empresa = pEmpresa AND num_credito = pCredito 
							AND fecha_registro = pFechaAnualidad AND anio_registro = sAnioRegistro;
						
						LET sContador = sContador + 1;
						CONTINUE FOREACH;
					ELSE
						IF dGastoMarzo < pMontoImporteMensual OR dGastoAbril < pMontoImporteMensual OR dGastoMayo < pMontoImporteMensual OR dGastoJunio < pMontoImporteMensual OR
						   dGastoJulio < pMontoImporteMensual OR dGastoAgosto < pMontoImporteMensual OR dGastoSeptiembre < pMontoImporteMensual OR
						   dGastoOctubre < pMontoImporteMensual OR dGastoNoviembre < pMontoImporteMensual OR dGastoDiciembre < pMontoImporteMensual THEN
							LET cCod_ret_mes = '00001';
							
							UPDATE bdicred:sd_gastos_bonificacion SET cod_ret_mensual = cCod_ret_mes WHERE empresa = pEmpresa AND num_credito = pCredito 
								AND fecha_registro = pFechaAnualidad AND anio_registro = sAnioRegistro;
							
							LET sContador = sContador + 1;
							CONTINUE FOREACH;
						END IF;
					END IF;
				ELIF cMesCorrespondiente = '3' THEN
					IF dGastoMarzo < pMontoImportePrimerMes THEN 
						LET cCod_ret_mes = '00001';
							
						UPDATE bdicred:sd_gastos_bonificacion SET cod_ret_mensual = cCod_ret_mes WHERE empresa = pEmpresa AND num_credito = pCredito 
							AND fecha_registro = pFechaAnualidad AND anio_registro = sAnioRegistro;
							
						LET sContador = sContador + 1;
						CONTINUE FOREACH;
					ELSE
						IF dGastoAbril < pMontoImporteMensual OR dGastoMayo < pMontoImporteMensual OR dGastoJunio < pMontoImporteMensual OR
						dGastoJulio < pMontoImporteMensual OR dGastoAgosto < pMontoImporteMensual OR dGastoSeptiembre < pMontoImporteMensual OR
						dGastoOctubre < pMontoImporteMensual OR dGastoNoviembre < pMontoImporteMensual OR dGastoDiciembre < pMontoImporteMensual THEN
							LET cCod_ret_mes = '00001';
							
							UPDATE bdicred:sd_gastos_bonificacion SET cod_ret_mensual = cCod_ret_mes WHERE empresa = pEmpresa AND num_credito = pCredito 
								AND fecha_registro = pFechaAnualidad AND anio_registro = sAnioRegistro;
								
							LET sContador = sContador + 1;
							CONTINUE FOREACH;
						END IF;
					END IF;
				ELIF cMesCorrespondiente = '4' THEN
					IF dGastoAbril < pMontoImportePrimerMes THEN 
						LET cCod_ret_mes = '00001';
							
						UPDATE bdicred:sd_gastos_bonificacion SET cod_ret_mensual = cCod_ret_mes WHERE empresa = pEmpresa AND num_credito = pCredito 
							AND fecha_registro = pFechaAnualidad AND anio_registro = sAnioRegistro;
							
						LET sContador = sContador + 1;
						CONTINUE FOREACH;
					ELSE
						IF dGastoMayo < pMontoImporteMensual OR dGastoJunio < pMontoImporteMensual OR dGastoJulio < pMontoImporteMensual OR
						   dGastoAgosto < pMontoImporteMensual OR dGastoSeptiembre < pMontoImporteMensual OR
						   dGastoOctubre < pMontoImporteMensual OR dGastoNoviembre < pMontoImporteMensual OR dGastoDiciembre < pMontoImporteMensual THEN
							LET cCod_ret_mes = '00001';
							
							UPDATE bdicred:sd_gastos_bonificacion SET cod_ret_mensual = cCod_ret_mes WHERE empresa = pEmpresa AND num_credito = pCredito 
								AND fecha_registro = pFechaAnualidad AND anio_registro = sAnioRegistro;
								
							LET sContador = sContador + 1;
							CONTINUE FOREACH;
						END IF;
					END IF;
				ELIF cMesCorrespondiente = '5' THEN
					IF dGastoMayo < pMontoImportePrimerMes THEN 
						LET cCod_ret_mes = '00001';
							
						UPDATE bdicred:sd_gastos_bonificacion SET cod_ret_mensual = cCod_ret_mes WHERE empresa = pEmpresa AND num_credito = pCredito 
							AND fecha_registro = pFechaAnualidad AND anio_registro = sAnioRegistro;
							
						LET sContador = sContador + 1;
						CONTINUE FOREACH;
					ELSE
						IF dGastoJunio < pMontoImporteMensual OR dGastoJulio < pMontoImporteMensual OR dGastoAgosto < pMontoImporteMensual OR
						   dGastoSeptiembre < pMontoImporteMensual OR dGastoOctubre < pMontoImporteMensual OR
						   dGastoNoviembre < pMontoImporteMensual OR dGastoDiciembre < pMontoImporteMensual THEN
							LET cCod_ret_mes = '00001';
							
							UPDATE bdicred:sd_gastos_bonificacion SET cod_ret_mensual = cCod_ret_mes WHERE empresa = pEmpresa AND num_credito = pCredito 
								AND fecha_registro = pFechaAnualidad AND anio_registro = sAnioRegistro;
							
							LET sContador = sContador + 1;
							CONTINUE FOREACH;
						END IF;
					END IF;
				ELIF cMesCorrespondiente = '6' THEN
					IF dGastoJunio < pMontoImportePrimerMes THEN 
						LET cCod_ret_mes = '00001';
							
						UPDATE bdicred:sd_gastos_bonificacion SET cod_ret_mensual = cCod_ret_mes WHERE empresa = pEmpresa AND num_credito = pCredito 
							AND fecha_registro = pFechaAnualidad AND anio_registro = sAnioRegistro;
						
						LET sContador = sContador + 1;
						CONTINUE FOREACH;
					ELSE
						IF dGastoJulio < pMontoImporteMensual OR dGastoAgosto < pMontoImporteMensual OR
						   dGastoSeptiembre < pMontoImporteMensual OR dGastoOctubre < pMontoImporteMensual OR
						   dGastoNoviembre < pMontoImporteMensual OR dGastoDiciembre < pMontoImporteMensual THEN
							LET cCod_ret_mes = '00001';
							
							UPDATE bdicred:sd_gastos_bonificacion SET cod_ret_mensual = cCod_ret_mes WHERE empresa = pEmpresa AND num_credito = pCredito 
								AND fecha_registro = pFechaAnualidad AND anio_registro = sAnioRegistro;
							
							LET sContador = sContador + 1;
							CONTINUE FOREACH;
						END IF;
					END IF;
				ELIF cMesCorrespondiente = '7' THEN
					IF dGastoJulio < pMontoImportePrimerMes THEN 
						LET cCod_ret_mes = '00001';
							
						UPDATE bdicred:sd_gastos_bonificacion SET cod_ret_mensual = cCod_ret_mes WHERE empresa = pEmpresa AND num_credito = pCredito 
							AND fecha_registro = pFechaAnualidad AND anio_registro = sAnioRegistro;
						
						LET sContador = sContador + 1;
						CONTINUE FOREACH;
					ELSE
						IF dGastoAgosto < pMontoImporteMensual OR dGastoSeptiembre < pMontoImporteMensual OR
						   dGastoOctubre < pMontoImporteMensual OR dGastoNoviembre < pMontoImporteMensual OR dGastoDiciembre < pMontoImporteMensual THEN
							LET cCod_ret_mes = '00001';
							
							UPDATE bdicred:sd_gastos_bonificacion SET cod_ret_mensual = cCod_ret_mes WHERE empresa = pEmpresa AND num_credito = pCredito 
								AND fecha_registro = pFechaAnualidad AND anio_registro = sAnioRegistro;
							
							LET sContador = sContador + 1;
							CONTINUE FOREACH;
						END IF;
					END IF;
				ELIF cMesCorrespondiente = '8' THEN
					IF dGastoAgosto < pMontoImportePrimerMes THEN 
						LET cCod_ret_mes = '00001';
							
						UPDATE bdicred:sd_gastos_bonificacion SET cod_ret_mensual = cCod_ret_mes WHERE empresa = pEmpresa AND num_credito = pCredito 
							AND fecha_registro = pFechaAnualidad AND anio_registro = sAnioRegistro;
						
						LET sContador = sContador + 1;
						CONTINUE FOREACH;
					ELSE
						IF dGastoSeptiembre < pMontoImporteMensual OR dGastoOctubre < pMontoImporteMensual OR
						   dGastoNoviembre < pMontoImporteMensual OR dGastoDiciembre < pMontoImporteMensual THEN
							LET cCod_ret_mes = '00001';
							
							UPDATE bdicred:sd_gastos_bonificacion SET cod_ret_mensual = cCod_ret_mes WHERE empresa = pEmpresa AND num_credito = pCredito 
								AND fecha_registro = pFechaAnualidad AND anio_registro = sAnioRegistro;
							
							LET sContador = sContador + 1;
							CONTINUE FOREACH;
						END IF;
					END IF;
				ELIF cMesCorrespondiente = '9' THEN
					IF dGastoSeptiembre < pMontoImportePrimerMes THEN 
						LET cCod_ret_mes = '00001';
							
						UPDATE bdicred:sd_gastos_bonificacion SET cod_ret_mensual = cCod_ret_mes WHERE empresa = pEmpresa AND num_credito = pCredito 
							AND fecha_registro = pFechaAnualidad AND anio_registro = sAnioRegistro;
						
						LET sContador = sContador + 1;
						CONTINUE FOREACH;
					ELSE
						IF dGastoOctubre < pMontoImporteMensual OR dGastoNoviembre < pMontoImporteMensual OR dGastoDiciembre < pMontoImporteMensual THEN	
							LET cCod_ret_mes = '00001';
							
							UPDATE bdicred:sd_gastos_bonificacion SET cod_ret_mensual = cCod_ret_mes WHERE empresa = pEmpresa AND num_credito = pCredito 
								AND fecha_registro = pFechaAnualidad AND anio_registro = sAnioRegistro;
							
							LET sContador = sContador + 1;
							CONTINUE FOREACH;
						END IF;
					END IF;
				ELIF cMesCorrespondiente = '10' THEN
					IF dGastoOctubre < pMontoImportePrimerMes THEN 
						LET cCod_ret_mes = '00001';
							
						UPDATE bdicred:sd_gastos_bonificacion SET cod_ret_mensual = cCod_ret_mes WHERE empresa = pEmpresa AND num_credito = pCredito 
							AND fecha_registro = pFechaAnualidad AND anio_registro = sAnioRegistro;
						
						LET sContador = sContador + 1;
						CONTINUE FOREACH;
					ELSE
						IF dGastoNoviembre < pMontoImporteMensual OR dGastoDiciembre < pMontoImporteMensual THEN						
							LET cCod_ret_mes = '00001';
							
							UPDATE bdicred:sd_gastos_bonificacion SET cod_ret_mensual = cCod_ret_mes WHERE empresa = pEmpresa AND num_credito = pCredito 
								AND fecha_registro = pFechaAnualidad AND anio_registro = sAnioRegistro;
							
							LET sContador = sContador + 1;
							CONTINUE FOREACH;
						END IF;
					END IF;
				ELIF cMesCorrespondiente = '11' THEN
					IF dGastoNoviembre < pMontoImportePrimerMes THEN 
						LET cCod_ret_mes = '00001';
							
						UPDATE bdicred:sd_gastos_bonificacion SET cod_ret_mensual = cCod_ret_mes WHERE empresa = pEmpresa AND num_credito = pCredito 
							AND fecha_registro = pFechaAnualidad AND anio_registro = sAnioRegistro;
						
						LET sContador = sContador + 1;
						CONTINUE FOREACH;
					ELSE
						IF dGastoDiciembre < pMontoImporteMensual THEN	
							LET cCod_ret_mes = '00001';
							
							UPDATE bdicred:sd_gastos_bonificacion SET cod_ret_mensual = cCod_ret_mes WHERE empresa = pEmpresa AND num_credito = pCredito 
								AND fecha_registro = pFechaAnualidad AND anio_registro = sAnioRegistro;
							
							LET sContador = sContador + 1;
							CONTINUE FOREACH;
						END IF;
					END IF;
				ELIF cMesCorrespondiente = '12' THEN
					IF dGastoDiciembre < pMontoImportePrimerMes THEN 
						LET cCod_ret_mes = '00001';
							
						UPDATE bdicred:sd_gastos_bonificacion SET cod_ret_mensual = cCod_ret_mes WHERE empresa = pEmpresa AND num_credito = pCredito 
							AND fecha_registro = pFechaAnualidad AND anio_registro = sAnioRegistro;
						
						LET sContador = sContador + 1;
						CONTINUE FOREACH;
					END IF;
				END IF;
			
				IF cCod_ret_mes <> '00001' THEN
					UPDATE bdicred:sd_gastos_bonificacion SET cod_ret_mensual = cCod_ret_mes WHERE empresa = pEmpresa AND num_credito = pCredito 
						AND fecha_registro = pFechaAnualidad AND anio_registro = sAnioRegistro;
				END IF;
			ELSE --segunga vuelta 
				IF cMesCorrespondiente = '1' THEN
					IF dGastoEnero < pMontoImporteMensual THEN 
						LET cCod_ret_mesAux = '00001';
						
						UPDATE bdicred:sd_gastos_bonificacion SET cod_ret_mensual = cCod_ret_mesAux WHERE empresa = pEmpresa AND num_credito = pCredito 
								AND fecha_registro = pFechaAnualidad AND anio_registro = sAnioRegistro;
						CONTINUE FOREACH;
					END IF;
				END IF;
				
				IF cMesCorrespondiente = '2' THEN
					IF dGastoEnero < pMontoImporteMensual OR dGastoFebrero < pMontoImporteMensual THEN 
						LET cCod_ret_mesAux = '00001';
						
						UPDATE bdicred:sd_gastos_bonificacion SET cod_ret_mensual = cCod_ret_mesAux WHERE empresa = pEmpresa AND num_credito = pCredito 
								AND fecha_registro = pFechaAnualidad AND anio_registro = sAnioRegistro;
						CONTINUE FOREACH;
					END IF;
				END IF;
				
				IF cMesCorrespondiente = '3' THEN
					IF dGastoEnero < pMontoImporteMensual OR dGastoFebrero < pMontoImporteMensual OR dGastoMarzo < pMontoImporteMensual THEN 
						LET cCod_ret_mesAux = '00001';
					
						UPDATE bdicred:sd_gastos_bonificacion SET cod_ret_mensual = cCod_ret_mesAux WHERE empresa = pEmpresa AND num_credito = pCredito 
								AND fecha_registro = pFechaAnualidad AND anio_registro = sAnioRegistro;
						CONTINUE FOREACH;
					END IF;
				END IF;
				
				IF cMesCorrespondiente = '4' THEN
					IF dGastoEnero < pMontoImporteMensual OR dGastoFebrero < pMontoImporteMensual OR dGastoMarzo < pMontoImporteMensual OR dGastoAbril < pMontoImporteMensual THEN 
						LET cCod_ret_mesAux = '00001';
						
						UPDATE bdicred:sd_gastos_bonificacion SET cod_ret_mensual = cCod_ret_mesAux WHERE empresa = pEmpresa AND num_credito = pCredito 
								AND fecha_registro = pFechaAnualidad AND anio_registro = sAnioRegistro;
						CONTINUE FOREACH;
					END IF;
				END IF;
				
				IF cMesCorrespondiente = '5' THEN
					IF dGastoEnero < pMontoImporteMensual OR dGastoFebrero < pMontoImporteMensual OR dGastoMarzo < pMontoImporteMensual OR dGastoAbril < pMontoImporteMensual OR
					   dGastoMayo < pMontoImporteMensual THEN 
						LET cCod_ret_mesAux = '00001';
						
						UPDATE bdicred:sd_gastos_bonificacion SET cod_ret_mensual = cCod_ret_mesAux WHERE empresa = pEmpresa AND num_credito = pCredito 
								AND fecha_registro = pFechaAnualidad AND anio_registro = sAnioRegistro;
						CONTINUE FOREACH;
					END IF;
				END IF;
				
				IF cMesCorrespondiente = '6' THEN
					IF dGastoEnero < pMontoImporteMensual OR dGastoFebrero < pMontoImporteMensual OR dGastoMarzo < pMontoImporteMensual OR dGastoAbril < pMontoImporteMensual OR
					   dGastoMayo < pMontoImporteMensual OR dGastoJunio < pMontoImporteMensual THEN 
						LET cCod_ret_mesAux = '00001';
						
						UPDATE bdicred:sd_gastos_bonificacion SET cod_ret_mensual = cCod_ret_mesAux WHERE empresa = pEmpresa AND num_credito = pCredito 
								AND fecha_registro = pFechaAnualidad AND anio_registro = sAnioRegistro;
						CONTINUE FOREACH;
					END IF;
				END IF;
				
				IF cMesCorrespondiente = '7' THEN
					IF dGastoEnero < pMontoImporteMensual OR dGastoFebrero < pMontoImporteMensual OR dGastoMarzo < pMontoImporteMensual OR dGastoAbril < pMontoImporteMensual OR
					   dGastoMayo < pMontoImporteMensual OR dGastoJunio < pMontoImporteMensual OR dGastoJulio < pMontoImporteMensual THEN 
						LET cCod_ret_mesAux = '00001';
						
						UPDATE bdicred:sd_gastos_bonificacion SET cod_ret_mensual = cCod_ret_mesAux WHERE empresa = pEmpresa AND num_credito = pCredito 
								AND fecha_registro = pFechaAnualidad AND anio_registro = sAnioRegistro;
						CONTINUE FOREACH;
					END IF;
				END IF;
				
				IF cMesCorrespondiente = '8' THEN
					IF dGastoEnero < pMontoImporteMensual OR dGastoFebrero < pMontoImporteMensual OR dGastoMarzo < pMontoImporteMensual OR dGastoAbril < pMontoImporteMensual OR
					   dGastoMayo < pMontoImporteMensual OR dGastoJunio < pMontoImporteMensual OR dGastoJulio < pMontoImporteMensual OR dGastoAgosto < pMontoImporteMensual THEN 
						LET cCod_ret_mesAux = '00001';
						
						UPDATE bdicred:sd_gastos_bonificacion SET cod_ret_mensual = cCod_ret_mesAux WHERE empresa = pEmpresa AND num_credito = pCredito 
								AND fecha_registro = pFechaAnualidad AND anio_registro = sAnioRegistro;
						CONTINUE FOREACH;
					END IF;
				END IF;
				
				IF cMesCorrespondiente = '9' THEN
					IF dGastoEnero < pMontoImporteMensual OR dGastoFebrero < pMontoImporteMensual OR dGastoMarzo < pMontoImporteMensual OR dGastoAbril < pMontoImporteMensual OR
					   dGastoMayo < pMontoImporteMensual OR dGastoJunio < pMontoImporteMensual OR dGastoJulio < pMontoImporteMensual OR dGastoAgosto < pMontoImporteMensual OR 
					   dGastoSeptiembre < pMontoImporteMensual THEN
						LET cCod_ret_mesAux = '00001';
						
						UPDATE bdicred:sd_gastos_bonificacion SET cod_ret_mensual = cCod_ret_mesAux WHERE empresa = pEmpresa AND num_credito = pCredito 
								AND fecha_registro = pFechaAnualidad AND anio_registro = sAnioRegistro;
						CONTINUE FOREACH;
					END IF;
				END IF;
				
				IF cMesCorrespondiente = '10' THEN
					IF dGastoEnero < pMontoImporteMensual OR dGastoFebrero < pMontoImporteMensual OR dGastoMarzo < pMontoImporteMensual OR dGastoAbril < pMontoImporteMensual OR
					   dGastoMayo < pMontoImporteMensual OR dGastoJunio < pMontoImporteMensual OR dGastoJulio < pMontoImporteMensual OR dGastoAgosto < pMontoImporteMensual OR 
					   dGastoSeptiembre < pMontoImporteMensual OR dGastoOctubre < pMontoImporteMensual THEN
						LET cCod_ret_mesAux = '00001';
						
						UPDATE bdicred:sd_gastos_bonificacion SET cod_ret_mensual = cCod_ret_mesAux WHERE empresa = pEmpresa AND num_credito = pCredito 
								AND fecha_registro = pFechaAnualidad AND anio_registro = sAnioRegistro;
						CONTINUE FOREACH;
					END IF;
				END IF;
				
				IF cMesCorrespondiente = '11' THEN
					IF dGastoEnero < pMontoImporteMensual OR dGastoFebrero < pMontoImporteMensual OR dGastoMarzo < pMontoImporteMensual OR dGastoAbril < pMontoImporteMensual OR
					   dGastoMayo < pMontoImporteMensual OR dGastoJunio < pMontoImporteMensual OR dGastoJulio < pMontoImporteMensual OR dGastoAgosto < pMontoImporteMensual OR 
					   dGastoSeptiembre < pMontoImporteMensual OR dGastoOctubre < pMontoImporteMensual OR dGastoNoviembre < pMontoImporteMensual THEN
						LET cCod_ret_mesAux = '00001';
						
						UPDATE bdicred:sd_gastos_bonificacion SET cod_ret_mensual = cCod_ret_mesAux WHERE empresa = pEmpresa AND num_credito = pCredito 
								AND fecha_registro = pFechaAnualidad AND anio_registro = sAnioRegistro;
						CONTINUE FOREACH;
					END IF;
				END IF;
				
				IF cMesCorrespondiente = '12' THEN
					IF dGastoEnero < pMontoImporteMensual OR dGastoFebrero < pMontoImporteMensual OR dGastoMarzo < pMontoImporteMensual OR dGastoAbril < pMontoImporteMensual OR
					   dGastoMayo < pMontoImporteMensual OR dGastoJunio < pMontoImporteMensual OR dGastoJulio < pMontoImporteMensual OR dGastoAgosto < pMontoImporteMensual OR 
					   dGastoSeptiembre < pMontoImporteMensual OR dGastoOctubre < pMontoImporteMensual OR dGastoNoviembre < pMontoImporteMensual OR dGastoDiciembre < pMontoImporteMensual THEN
						LET cCod_ret_mesAux = '00001';
						
						UPDATE bdicred:sd_gastos_bonificacion SET cod_ret_mensual = cCod_ret_mesAux WHERE empresa = pEmpresa AND num_credito = pCredito 
								AND fecha_registro = pFechaAnualidad AND anio_registro = sAnioRegistro;
						CONTINUE FOREACH;
					END IF;
				END IF;
				
				IF cCod_ret_mesAux <> '00001' THEN
					UPDATE bdicred:sd_gastos_bonificacion SET cod_ret_mensual = cCod_ret_mesAux WHERE empresa = pEmpresa AND num_credito = pCredito 
						AND fecha_registro = pFechaAnualidad AND anio_registro = sAnioRegistro;
				END IF;		
			END IF;
			
			LET sContador = sContador + 1;
		END FOREACH;
	END IF; --pBanderaBonificacion
	
	--LoGICA PARA RESULTADO FINAL DEPENDIENDO LAS BANDERAS DE BONIFICACIoN
	IF pBanderaBonificacion = '1' THEN--si la bonificacion es anual tomara el valor de su propia bandera.
		LET cod_ret = cCod_ret_anual;
	ELIF pBanderaBonificacion = '2' THEN -- si la bonificacion es mensual tomara el valor de su propia bandera.
		IF cCod_ret_mes = cCod_ret_mesAux THEN
			LET cod_ret = cCod_ret_mes;
		ELSE
			LET cod_ret = '00001';
		END IF;
	ELSE --3 si la bonificacion es anual o mensual, es decir, si no se cumple la anual podria cumplir la mensual
		IF cCod_ret_mes = cCod_ret_anual AND cCod_ret_mesAux = cCod_ret_anual THEN--si los resultados son los mismos
			LET cod_ret = cCod_ret_anual; 
		ELSE--EN ALGUNO SI SE CUMPLIo
			IF cCod_ret_anual = '00000' THEN
				LET cod_ret = cCod_ret_anual;
				RETURN cod_ret;
			END IF;
			
			IF cCod_ret_mes = '00000' AND cCod_ret_mesAux = '00000' THEN
				LET cod_ret = cCod_ret_mes;
			ELSE 
				LET cod_ret = '00001';
			END IF;
		END IF;
	END IF;
	
	RETURN cod_ret;
   END;
END PROCEDURE
;
CREATE PROCEDURE "informix".sp_inserta_carga_inicial(pEmpresa CHAR(3), pCredito CHAR(20), pFechaProxAnualidad DATE, pBanderaTipoBonificacion CHAR(1), 
										      pFecha1erAnual DATE, pBanderaPromociones CHAR(1), pTransaccEspecial SMALLINT, pDiaCorte SMALLINT)
   RETURNING CHAR(5);
   
   -- **************************************************************************
   -- *                      DEFINICION DE VARIABLES                           *
   -- **************************************************************************
   /*
   pEmpresa					Parametro estandar en los spl, ocupado en indices de busquedas.
   pCredito					Parametro que contiene el numero de credito a consultar/validar.
   pFechaProxAnualidad		Parametro que contiene la fecha de limite de busqueda de movimientos.
   pBanderaTipoBonificacion Parametro que verificara 1 = bonificacion anual, 2 = bonificacion mensual, 3 = Ambas ( si no cumple la mensual, validara anual).
   pFecha1erAnual			Parametro que contendrÃ¡ la primera fecha en la que se llevo a cabo la bonificacion, si pFechaProxAnualidad es igual pFecha1erAnual quiere decir que no ha pasado por el proceso y deberÃ¡ tomar en cuenta el primer mes de importe
   pBanderaPromociones		Parametro que dependiendo su valor 0 = no tomara en cuenta MSI, 1 = tomara en cuenta movimientos de MSI TOTALES, 2 = tomarÃ¡ en cuenta movimientos de MSI por mes
   */
   --EXECUTE PROCEDURE sp_inserta_carga_inicial('001', '540000000005', mdy(10,12,2024),'3',mdy(10,12,2024),'0',1,19);
   --EXECUTE PROCEDURE sp_inserta_carga_inicial('001', '540000000005', mdy(10,12,2025),'3', NULL,'0',1,19);
   --EXECUTE PROCEDURE sp_inserta_carga_inicial('001', '540000000336', mdy(1,5,2025),'3', mdy(1,5,2025),'0', 0,19);
   --EXECUTE PROCEDURE sp_inserta_carga_inicial('001', '540000000336', mdy(1,5,2026),'3', NULL,'0', 0,19);

   DEFINE cod_ret             		  CHAR(5);
   DEFINE cod_ret2             		  CHAR(5);
   DEFINE cod_ret_anual        		  CHAR(5);
   DEFINE cod_ret_mes          		  CHAR(5);
   DEFINE sql_err             		  SMALLINT;
   DEFINE isam_err            		  SMALLINT;
   DEFINE sContador					  SMALLINT;
   DEFINE error_info          		  CHAR(40);
   DEFINE dSumaTotalCargoNormal	 	  DECIMAL(14,2);
   DEFINE dSumaTotalCargoEspecial	  DECIMAL(14,2);
   DEFINE dSumaTotalMSI				  DECIMAL(16,2);
   DEFINE dSumaTotalPago	  		  DECIMAL(14,2);
   DEFINE dSumaTotalHisCargoNormal    DECIMAL(14,2);
   DEFINE dSumaTotalHisCargoEspecial  DECIMAL(14,2);
   DEFINE dSumaTotalHisMSI			  DECIMAL(16,2);
   DEFINE dSumaTotalHisPago   		  DECIMAL(14,2);
   DEFINE dSumaAcumulada	   		  DECIMAL(14,2);
   DEFINE dFechaHoy			  		  DATE;
   DEFINE dFechaAnualidad	  		  DATE;
   DEFINE dFechaCorte			  	  DATE;
   DEFINE dFechaInicioOriginal	  	  DATE;
   DEFINE dFechaInicioBusqueda	  	  DATE;
   DEFINE cMesAnterior				  CHAR(1);
   DEFINE iAnioRegistro				  INTEGER;
   
  -- **************************************************************************
  -- *                      ASIGNACION DE VARIABLES                           *
  -- **************************************************************************
  
   LET cod_ret             		   = '00000';
   LET cod_ret2            		   = '00000';
   LET cod_ret_anual       		   = '00000';
   LET cod_ret_mes         		   = '00000';
   LET cMesAnterior				   = '0';
   LET error_info          		   = '';
   LET sql_err             		   = 0;
   LET isam_err            		   = 0;
   LET dSumaTotalCargoNormal 	   = 0;
   LET dSumaTotalCargoEspecial 	   = 0;
   LET dSumaTotalHisCargoNormal    = 0;
   LET dSumaTotalHisCargoEspecial  = 0;
   LET dSumaTotalPago	   		   = 0;
   LET dSumaTotalHisPago   		   = 0;
   LET sContador				   = 0;
   LET dSumaAcumulada 			   = 0;
   LET dSumaTotalHisMSI			   = 0;
   LET dSumaTotalMSI			   = 0;
   LET iAnioRegistro			   = 0;
   LET dFechaHoy		   		   = DATE(1);
   LET dFechaCorte	       		   = DATE(1);
   LET dFechaInicioOriginal	       = DATE(1);
   LET dFechaAnualidad			   = DATE(1);
   LET dFechaInicioBusqueda		   = DATE(1);
   
   BEGIN
		
		ON EXCEPTION SET sql_err, isam_err, error_info
			IF sql_err != 0 THEN
				LET cod_ret = sql_err;
				
				RETURN cod_ret;
			END IF;
		END EXCEPTION;
		
		--SET ISOLATION TO DIRTY READ;
		--SET LOCK MODE TO WAIT 3;
		
	--SET DEBUG FILE TO "/home/e90402183/BONIFICACION_TDC/spl/sp_inserta_carga_inicial.out"; 
    --TRACE ON;
	 
	LET dFechaInicioBusqueda =  monthadd(pFechaProxAnualidad, - 12);
	
	--Si se recibe un valor en la variable pFechaProxAnualidad se realizarÃ¡ la bÃºsqueda 
	--de la primera vez, es decir, pFechaProxAnualidad = 20/12/2024, lo que la siguiente lÃ³gica harÃ¡ serÃ¡
	--iniciar la bÃºsqueda con los rangos dFechaInicioBusqueda y pFechaProxAnualidad - 1 dÃ­a, es decir, 20/12/2023 al 19/12/2024
	IF NVL(pFecha1erAnual, DATE(1)) <> DATE(1) THEN
		LET dFechaAnualidad = pFechaProxAnualidad - 1 UNITS DAY;
	ELSE 
		--Si la variable pFechaProxAnualidad es nula, quiere decir que es la segunda llamada del spl, por lo que la bÃºsqueda
		--serÃ¡ de la nueva dFechaInicioBusqueda a la fecha hoy del sistema.
		SELECT fecha_hoy INTO dFechaAnualidad FROM bdicred:sd_fechas WHERE empresa = pEmpresa;
		
		--Si la fecha de hoy es mayor a su prÃ³xima anualidad, es decir...
		--pFechaProxAnualidad = 20/12/2025 y la dFechaAnualidad = 21/12/2025, la lÃ³gica del proceso tomarÃ¡ pFechaProxAnualidad - 1 day
		--para asÃ­ realizar la bÃºsqueda en los rangos dFechaInicioBusqueda y pFechaProxAnualidad, es decir, 20/12/2024 al 19/12/2025
		IF dFechaAnualidad > pFechaProxAnualidad THEN
			LET dFechaAnualidad = pFechaProxAnualidad - 1 UNITS DAY;
		END IF;
		--de lo contrario, si la dFechaAnualidad es menor a la pFechaProxAnualidad, el rango de bÃºsqueda por ejemplo serÃ­a:
		--*dFechaInicioBusqueda->20/12/2024 y pFechaProxAnualidad->01/01/2025
		--*dFechaInicioBusqueda->20/12/2024 y pFechaProxAnualidad->21/02/2025
		--*dFechaInicioBusqueda->20/12/2024 y pFechaProxAnualidad->16/03/2025
	END IF;
	
	LET dFechaInicioOriginal = pFechaProxAnualidad;
	LET dFechaCorte = MDY(MONTH(dFechaInicioBusqueda), pDiaCorte, YEAR(dFechaInicioBusqueda));
	
	IF MONTH(dFechaCorte) = 1 THEN
		IF dFechaInicioBusqueda < dFechaCorte THEN
			LET iAnioRegistro = YEAR(monthadd(dFechaInicioBusqueda, - 12));
		ELSE
			LET iAnioRegistro = YEAR(dFechaInicioBusqueda);
		END IF;
	ELSE 
		LET iAnioRegistro = YEAR(dFechaInicioBusqueda);
	END IF;
		
	IF pBanderaTipoBonificacion = '1' OR pBanderaTipoBonificacion = '3' THEN
	
		SELECT SUM(monto) monto INTO dSumaTotalCargoNormal FROM sd_movhis 
			WHERE empresa = pEmpresa AND num_credito = pCredito 
			AND fecha_mov >= dFechaInicioBusqueda AND fecha_mov <= dFechaAnualidad
			AND reversado = 'N'
			AND transacc_suc IN (SELECT transacc FROM sd_transacc_bonificacion where empresa = pEmpresa and normal = '1');
			
		IF pTransaccEspecial = 1 THEN 
			SELECT SUM(monto) monto INTO dSumaTotalCargoEspecial FROM sd_movhis 
				WHERE empresa = pEmpresa AND num_credito = pCredito 
				AND fecha_mov >= dFechaInicioBusqueda AND fecha_mov <= dFechaAnualidad
				AND reversado = 'N'
				AND transacc_suc IN (SELECT transacc FROM sd_transacc_bonificacion where empresa = pEmpresa and especial = '1');
		END IF;
		
		SELECT SUM(monto) monto INTO dSumaTotalPago FROM bdicred:sd_movhis
			WHERE empresa = pempresa AND num_credito = pCredito 
			AND fecha_mov >= dFechaInicioBusqueda AND fecha_mov <= dFechaAnualidad
			AND codigo_fun IN ('057','904','905') AND codigo_ref = '1'
			AND reversado = 'N';
		
		IF pBanderaPromociones <> '0' THEN
			EXECUTE PROCEDURE sp_monto_promociones_bonificacion(pEmpresa, pCredito, dFechaInicioBusqueda, dFechaAnualidad, pBanderaPromociones) INTO cod_ret2, dSumaTotalMSI;
			
			IF cod_ret2 = '00000' THEN
				LET dSumaTotalCargoNormal = dSumaTotalCargoNormal + dSumaTotalMSI;
			END IF;
		END IF;
			
		--monto total historico menos devoluciones realizadas.		
		LET dSumaTotalCargoNormal = (NVL(dSumaTotalCargoNormal,0) + NVL(dSumaTotalCargoEspecial,0))  - NVL(dSumaTotalPago,0);	
		
		INSERT INTO sd_gastos_bonificacion (empresa,fecha_registro,anio_registro,num_credito,gasto_enero,gasto_febrero,gasto_marzo,
												   gasto_abril,gasto_mayo,gasto_junio,gasto_julio,gasto_agosto,gasto_septiembre,gasto_octubre,gasto_noviembre,
												   gasto_diciembre,gasto_total_anual,cod_ret_anual,cod_ret_mensual)
			VALUES(pEmpresa,dFechaInicioOriginal,iAnioRegistro, pCredito, NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL, 
				    NVL(dSumaTotalCargoNormal,0),NULL, NULL);	
	END IF;
	
	IF pBanderaTipoBonificacion = '2' OR pBanderaTipoBonificacion = '3' THEN--EMPIEZA LoGICA PARA BONIFICICACIoN MENSUAL
		
		IF dFechaInicioBusqueda > dFechaCorte THEN
			LET dFechaCorte = dFechaCorte + 1 UNITS MONTH;
		ELIF dFechaInicioBusqueda <= dFechaCorte THEN
			LET cMesAnterior = '1';
		END IF;
		
		WHILE dFechaInicioBusqueda <= dFechaAnualidad
		
			SELECT SUM(monto) INTO dSumaTotalHisCargoNormal FROM sd_movhis 
			WHERE empresa = pEmpresa AND num_credito = pCredito 
				AND fecha_mov >= dFechaInicioBusqueda AND fecha_mov <= dFechaCorte
				AND reversado = 'N'
				AND transacc_suc IN (SELECT transacc FROM sd_transacc_bonificacion where empresa = pEmpresa and normal = '1'); 
			
			IF pTransaccEspecial = 1 THEN 
				SELECT SUM(monto) INTO dSumaTotalHisCargoEspecial FROM sd_movhis 
					WHERE empresa = pEmpresa AND num_credito = pCredito 
					AND fecha_mov >= dFechaInicioBusqueda AND fecha_mov <= dFechaCorte
					AND reversado = 'N'
					AND transacc_suc IN (SELECT transacc FROM sd_transacc_bonificacion where empresa = pEmpresa and especia = '1');
			END IF;
			
			SELECT SUM(monto) INTO dSumaTotalHisPago FROM bdicred:sd_movhis
				WHERE empresa = pempresa AND num_credito = pCredito 
				AND fecha_mov >= dFechaInicioBusqueda AND fecha_mov <= dFechaCorte
				AND codigo_fun IN ('057','904','905') AND codigo_ref = '1'
				AND reversado = 'N';
				
			IF pBanderaPromociones <> '0' THEN
				EXECUTE PROCEDURE sp_monto_promociones_bonificacion(pEmpresa, pCredito, dFechaInicioBusqueda, dFechaCorte, pBanderaPromociones) INTO cod_ret2, dSumaTotalHisMSI;
			
				IF cod_ret2 = '00000' THEN
					LET dSumaTotalHisCargoNormal = NVL(dSumaTotalHisCargoNormal,0) + dSumaTotalHisMSI;
				END IF;
			END IF;	
			
			--SUMA DE CARGOS NORMALES Y ESPECIALES HISToRICOS
			LET dSumaTotalHisCargoNormal = (NVL(dSumaTotalHisCargoNormal,0) + NVL(dSumaTotalHisCargoEspecial,0)) - NVL(dSumaTotalHisPago,0);
			
			IF sContador = 0 THEN --NO SE TOMAra EN CUENTA LA CUOTA ESPECIAL POR PRIMER MES
				--ENERO				
				IF MONTH(dFechaInicioBusqueda) = 1 AND cMesAnterior = '0' THEN
					IF pBanderaTipoBonificacion = 3 THEN 
						UPDATE sd_gastos_bonificacion SET gasto_enero = dSumaTotalHisCargoNormal
							WHERE fecha_registro = dFechaInicioOriginal AND num_credito = pCredito AND anio_registro = iAnioRegistro;
					ELSE
						INSERT INTO sd_gastos_bonificacion (empresa,fecha_registro,anio_registro,num_credito,gasto_enero,gasto_febrero,gasto_marzo,
																   gasto_abril,gasto_mayo,gasto_junio,gasto_julio,gasto_agosto,gasto_septiembre,gasto_octubre,
																   gasto_noviembre,gasto_diciembre,gasto_total_anual,cod_ret_anual,cod_ret_mensual)
							VALUES(pEmpresa,dFechaInicioOriginal,iAnioRegistro,pCredito,dSumaTotalHisCargoNormal,NULL,NULL,NULL,NULL,NULL,NULL,
								   NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
					END IF;
				ELIF MONTH(dFechaInicioBusqueda) = 1 AND cMesAnterior = '1' THEN
					IF pBanderaTipoBonificacion = 3 THEN 
						UPDATE sd_gastos_bonificacion SET gasto_diciembre = dSumaTotalHisCargoNormal
							WHERE fecha_registro = dFechaInicioOriginal AND num_credito = pCredito AND anio_registro = iAnioRegistro;
					ELSE
						INSERT INTO sd_gastos_bonificacion (empresa,fecha_registro,anio_registro,num_credito,gasto_enero,gasto_febrero,gasto_marzo,
																   gasto_abril,gasto_mayo,gasto_junio,gasto_julio,gasto_agosto,gasto_septiembre,gasto_octubre,
																   gasto_noviembre,gasto_diciembre,gasto_total_anual,cod_ret_anual,cod_ret_mensual)
							VALUES(pEmpresa,dFechaInicioOriginal,iAnioRegistro,pCredito,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
								   NULL,NULL,NULL,NULL,dSumaTotalHisCargoNormal,NULL,NULL,NULL);
					END IF;
				END IF;
				
				--FEBRERO
				IF MONTH(dFechaInicioBusqueda) = 2  AND cMesAnterior = '0' THEN
					IF pBanderaTipoBonificacion = 3 THEN 
						UPDATE sd_gastos_bonificacion SET gasto_febrero = dSumaTotalHisCargoNormal
							WHERE fecha_registro = dFechaInicioOriginal AND num_credito = pCredito AND anio_registro = iAnioRegistro;
					ELSE
						INSERT INTO sd_gastos_bonificacion (empresa,fecha_registro,anio_registro,num_credito,gasto_enero,gasto_febrero,gasto_marzo,
																   gasto_abril,gasto_mayo,gasto_junio,gasto_julio,gasto_agosto,gasto_septiembre,gasto_octubre,
																   gasto_noviembre,gasto_diciembre,gasto_total_anual,cod_ret_anual,cod_ret_mensual)
							VALUES(pEmpresa,dFechaInicioOriginal,iAnioRegistro,pCredito, NULL,dSumaTotalHisCargoNormal,NULL,NULL,NULL,NULL,NULL,NULL,
								   NULL,NULL,NULL,NULL,NULL,NULL,NULL);
					END IF;
				ELIF MONTH(dFechaInicioBusqueda) = 2  AND cMesAnterior = '1' THEN 
					IF pBanderaTipoBonificacion = 3 THEN 
						UPDATE sd_gastos_bonificacion SET gasto_enero = dSumaTotalHisCargoNormal
							WHERE fecha_registro = dFechaInicioOriginal AND num_credito = pCredito AND anio_registro = iAnioRegistro;
					ELSE
						INSERT INTO sd_gastos_bonificacion (empresa,fecha_registro,anio_registro,num_credito,gasto_enero,gasto_febrero,gasto_marzo,
																   gasto_abril,gasto_mayo,gasto_junio,gasto_julio,gasto_agosto,gasto_septiembre,gasto_octubre,
																   gasto_noviembre,gasto_diciembre,gasto_total_anual,cod_ret_anual,cod_ret_mensual)
							VALUES(pEmpresa,dFechaInicioOriginal,iAnioRegistro,pCredito,dSumaTotalHisCargoNormal,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
								   NULL,NULL,NULL,NULL,NULL,NULL,NULL);
					END IF;
				END IF;
				
				--MARZO
				IF MONTH(dFechaInicioBusqueda) = 3 AND cMesAnterior = '0' THEN
					IF pBanderaTipoBonificacion = 3 THEN 
						UPDATE sd_gastos_bonificacion SET gasto_marzo = dSumaTotalHisCargoNormal
							WHERE fecha_registro = dFechaInicioOriginal AND num_credito = pCredito AND anio_registro = iAnioRegistro;
					ELSE
						INSERT INTO sd_gastos_bonificacion (empresa,fecha_registro,anio_registro,num_credito,gasto_enero,gasto_febrero,gasto_marzo,
																   gasto_abril,gasto_mayo,gasto_junio,gasto_julio,gasto_agosto,gasto_septiembre,gasto_octubre,
																   gasto_noviembre,gasto_diciembre,gasto_total_anual,cod_ret_anual,cod_ret_mensual)
							VALUES(pEmpresa,dFechaInicioOriginal,iAnioRegistro,pCredito, NULL,NULL,dSumaTotalHisCargoNormal,NULL,NULL,NULL,NULL,NULL,
								   NULL,NULL,NULL,NULL,NULL,NULL,NULL);
					END IF;
				ELIF MONTH(dFechaInicioBusqueda) = 3 AND cMesAnterior = '1' THEN
					IF pBanderaTipoBonificacion = 3 THEN 
						UPDATE sd_gastos_bonificacion SET gasto_febrero = dSumaTotalHisCargoNormal
							WHERE fecha_registro = dFechaInicioOriginal AND num_credito = pCredito AND anio_registro = iAnioRegistro;
					ELSE
						INSERT INTO sd_gastos_bonificacion (empresa,fecha_registro,anio_registro,num_credito,gasto_enero,gasto_febrero,gasto_marzo,
																   gasto_abril,gasto_mayo,gasto_junio,gasto_julio,gasto_agosto,gasto_septiembre,gasto_octubre,
																   gasto_noviembre,gasto_diciembre,gasto_total_anual,cod_ret_anual,cod_ret_mensual)
							VALUES(pEmpresa,dFechaInicioOriginal,iAnioRegistro,pCredito, NULL,dSumaTotalHisCargoNormal,NULL,NULL,NULL,NULL,NULL,NULL,
								   NULL,NULL,NULL,NULL,NULL,NULL,NULL);
					END IF;
				END IF;
				
				--ABRIL
				IF MONTH(dFechaInicioBusqueda) = 4 AND cMesAnterior = '0' THEN
					IF pBanderaTipoBonificacion = 3 THEN 
						UPDATE sd_gastos_bonificacion SET gasto_abril = dSumaTotalHisCargoNormal
							WHERE fecha_registro = dFechaInicioOriginal AND num_credito = pCredito AND anio_registro = iAnioRegistro;
					ELSE
						INSERT INTO sd_gastos_bonificacion (empresa,fecha_registro,anio_registro,num_credito,gasto_enero,gasto_febrero,gasto_marzo,
																   gasto_abril,gasto_mayo,gasto_junio,gasto_julio,gasto_agosto,gasto_septiembre,gasto_octubre,
																   gasto_noviembre,gasto_diciembre,gasto_total_anual,cod_ret_anual,cod_ret_mensual)
							VALUES(pEmpresa,dFechaInicioOriginal,iAnioRegistro,pCredito, NULL,NULL,NULL,dSumaTotalHisCargoNormal,NULL,NULL,NULL,NULL,
								   NULL,NULL,NULL,NULL,NULL,NULL,NULL);
					END IF;
				ELIF MONTH(dFechaInicioBusqueda) = 4 AND cMesAnterior = '1' THEN
					IF pBanderaTipoBonificacion = 3 THEN 
						UPDATE sd_gastos_bonificacion SET gasto_marzo = dSumaTotalHisCargoNormal
							WHERE fecha_registro = dFechaInicioOriginal AND num_credito = pCredito AND anio_registro = iAnioRegistro;
					ELSE
						INSERT INTO sd_gastos_bonificacion (empresa,fecha_registro,anio_registro,num_credito,gasto_enero,gasto_febrero,gasto_marzo,
																   gasto_abril,gasto_mayo,gasto_junio,gasto_julio,gasto_agosto,gasto_septiembre,gasto_octubre,
																   gasto_noviembre,gasto_diciembre,gasto_total_anual,cod_ret_anual,cod_ret_mensual)
							VALUES(pEmpresa,dFechaInicioOriginal,iAnioRegistro,pCredito, NULL,NULL,dSumaTotalHisCargoNormal,NULL,NULL,NULL,NULL,NULL,
								   NULL,NULL,NULL,NULL,NULL,NULL,NULL);
					END IF;
				END IF;
				
				--MAYO
				IF MONTH(dFechaInicioBusqueda) = 5 AND cMesAnterior = '0' THEN
					IF pBanderaTipoBonificacion = 3 THEN 
						UPDATE sd_gastos_bonificacion SET gasto_mayo = dSumaTotalHisCargoNormal
							WHERE fecha_registro = dFechaInicioOriginal AND num_credito = pCredito AND anio_registro = iAnioRegistro; 
					ELSE
						INSERT INTO sd_gastos_bonificacion (empresa,fecha_registro,anio_registro,num_credito,gasto_enero,gasto_febrero,gasto_marzo,
																   gasto_abril,gasto_mayo,gasto_junio,gasto_julio,gasto_agosto,gasto_septiembre,gasto_octubre,
																   gasto_noviembre,gasto_diciembre,gasto_total_anual,cod_ret_anual,cod_ret_mensual)
							VALUES(pEmpresa,dFechaInicioOriginal,iAnioRegistro,pCredito, NULL,NULL,NULL,NULL,dSumaTotalHisCargoNormal,NULL,NULL,NULL,
								   NULL,NULL,NULL,NULL,NULL,NULL,NULL);
					END IF;
				ELIF MONTH(dFechaInicioBusqueda) = 5 AND cMesAnterior = '1' THEN
					IF pBanderaTipoBonificacion = 3 THEN 
						UPDATE sd_gastos_bonificacion SET gasto_abril = dSumaTotalHisCargoNormal
							WHERE fecha_registro = dFechaInicioOriginal AND num_credito = pCredito AND anio_registro = iAnioRegistro;
					ELSE
						INSERT INTO sd_gastos_bonificacion (empresa,fecha_registro,anio_registro,num_credito,gasto_enero,gasto_febrero,gasto_marzo,
																   gasto_abril,gasto_mayo,gasto_junio,gasto_julio,gasto_agosto,gasto_septiembre,gasto_octubre,
																   gasto_noviembre,gasto_diciembre,gasto_total_anual,cod_ret_anual,cod_ret_mensual)
							VALUES(pEmpresa,dFechaInicioOriginal,iAnioRegistro,pCredito, NULL,NULL,NULL,dSumaTotalHisCargoNormal,NULL,NULL,NULL,NULL,
								   NULL,NULL,NULL,NULL,NULL,NULL,NULL);
					END IF;
				END IF;
				
				--JUNIO
				IF MONTH(dFechaInicioBusqueda) = 6 AND cMesAnterior = '0' THEN
					IF pBanderaTipoBonificacion = 3 THEN 
						UPDATE sd_gastos_bonificacion SET gasto_junio = dSumaTotalHisCargoNormal
							WHERE fecha_registro = dFechaInicioOriginal AND num_credito = pCredito AND anio_registro = iAnioRegistro;
					ELSE
						INSERT INTO sd_gastos_bonificacion (empresa,fecha_registro,anio_registro,num_credito,gasto_enero,gasto_febrero,gasto_marzo,
																   gasto_abril,gasto_mayo,gasto_junio,gasto_julio,gasto_agosto,gasto_septiembre,gasto_octubre,
																   gasto_noviembre,gasto_diciembre,gasto_total_anual,cod_ret_anual,cod_ret_mensual)
							VALUES(pEmpresa,dFechaInicioOriginal,iAnioRegistro,pCredito, NULL,NULL,NULL,NULL,NULL,dSumaTotalHisCargoNormal,NULL,NULL,
								   NULL,NULL,NULL,NULL,NULL,NULL,NULL);
					END IF;
				ELIF MONTH(dFechaInicioBusqueda) = 6 AND cMesAnterior = '1' THEN
					IF pBanderaTipoBonificacion = 3 THEN 
						UPDATE sd_gastos_bonificacion SET gasto_mayo = dSumaTotalHisCargoNormal
							WHERE fecha_registro = dFechaInicioOriginal AND num_credito = pCredito AND anio_registro = iAnioRegistro;
					ELSE
						INSERT INTO sd_gastos_bonificacion (empresa,fecha_registro,anio_registro,num_credito,gasto_enero,gasto_febrero,gasto_marzo,
																   gasto_abril,gasto_mayo,gasto_junio,gasto_julio,gasto_agosto,gasto_septiembre,gasto_octubre,
																   gasto_noviembre,gasto_diciembre,gasto_total_anual,cod_ret_anual,cod_ret_mensual)
							VALUES(pEmpresa,dFechaInicioOriginal,iAnioRegistro,pCredito, NULL,NULL,NULL,NULL,dSumaTotalHisCargoNormal,NULL,NULL,NULL,
								   NULL,NULL,NULL,NULL,NULL,NULL,NULL);
					END IF;
				END IF;
				
				--JULIO
				IF MONTH(dFechaInicioBusqueda) = 7 AND cMesAnterior = '0' THEN
					IF pBanderaTipoBonificacion = 3 THEN 
						UPDATE sd_gastos_bonificacion SET gasto_julio = dSumaTotalHisCargoNormal
							WHERE fecha_registro = dFechaInicioOriginal AND num_credito = pCredito AND anio_registro = iAnioRegistro;
					ELSE
						INSERT INTO sd_gastos_bonificacion (empresa,fecha_registro,anio_registro,num_credito,gasto_enero,gasto_febrero,gasto_marzo,
																   gasto_abril,gasto_mayo,gasto_junio,gasto_julio,gasto_agosto,gasto_septiembre,gasto_octubre,
																   gasto_noviembre,gasto_diciembre,gasto_total_anual,cod_ret_anual,cod_ret_mensual)
							VALUES(pEmpresa,dFechaInicioOriginal,iAnioRegistro,pCredito, NULL,NULL,NULL,NULL,NULL,NULL,dSumaTotalHisCargoNormal,NULL,
								   NULL,NULL,NULL,NULL,NULL,NULL,NULL);
					END IF;
				ELIF MONTH(dFechaInicioBusqueda) = 7 AND cMesAnterior = '1' THEN
					IF pBanderaTipoBonificacion = 3 THEN 
						UPDATE sd_gastos_bonificacion SET gasto_junio = dSumaTotalHisCargoNormal
							WHERE fecha_registro = dFechaInicioOriginal AND num_credito = pCredito AND anio_registro = iAnioRegistro;
					ELSE
						INSERT INTO sd_gastos_bonificacion (empresa,fecha_registro,anio_registro,num_credito,gasto_enero,gasto_febrero,gasto_marzo,
																   gasto_abril,gasto_mayo,gasto_junio,gasto_julio,gasto_agosto,gasto_septiembre,gasto_octubre,
																   gasto_noviembre,gasto_diciembre,gasto_total_anual,cod_ret_anual,cod_ret_mensual)
							VALUES(pEmpresa,dFechaInicioOriginal,iAnioRegistro,pCredito, NULL,NULL,NULL,NULL,NULL,dSumaTotalHisCargoNormal,NULL,NULL,
								   NULL,NULL,NULL,NULL,NULL,NULL,NULL);
					END IF;
				END IF;
				
				--AGOSTO
				IF MONTH(dFechaInicioBusqueda) = 8 AND cMesAnterior = '0' THEN
					IF pBanderaTipoBonificacion = 3 THEN 
						UPDATE sd_gastos_bonificacion SET gasto_agosto = dSumaTotalHisCargoNormal
							WHERE fecha_registro = dFechaInicioOriginal AND num_credito = pCredito AND anio_registro = iAnioRegistro;
					ELSE
						INSERT INTO sd_gastos_bonificacion (empresa,fecha_registro,anio_registro,num_credito,gasto_enero,gasto_febrero,gasto_marzo,
																   gasto_abril,gasto_mayo,gasto_junio,gasto_julio,gasto_agosto,gasto_septiembre,gasto_octubre,
																   gasto_noviembre,gasto_diciembre,gasto_total_anual,cod_ret_anual,cod_ret_mensual)
							VALUES(pEmpresa,dFechaInicioOriginal,iAnioRegistro,pCredito, NULL,NULL,NULL,NULL,NULL,NULL,NULL,dSumaTotalHisCargoNormal,
								   NULL,NULL,NULL,NULL,NULL,NULL,NULL);
					END IF;
				ELIF  MONTH(dFechaInicioBusqueda) = 8 AND cMesAnterior = '1' THEN
					IF pBanderaTipoBonificacion = 3 THEN 
						UPDATE sd_gastos_bonificacion SET gasto_julio = dSumaTotalHisCargoNormal
							WHERE fecha_registro = dFechaInicioOriginal AND num_credito = pCredito AND anio_registro = iAnioRegistro;
					ELSE
						INSERT INTO sd_gastos_bonificacion (empresa,fecha_registro,anio_registro,num_credito,gasto_enero,gasto_febrero,gasto_marzo,
																   gasto_abril,gasto_mayo,gasto_junio,gasto_julio,gasto_agosto,gasto_septiembre,gasto_octubre,
																   gasto_noviembre,gasto_diciembre,gasto_total_anual,cod_ret_anual,cod_ret_mensual)
							VALUES(pEmpresa,dFechaInicioOriginal,iAnioRegistro,pCredito, NULL,NULL,NULL,NULL,NULL,NULL,dSumaTotalHisCargoNormal,NULL,
								   NULL,NULL,NULL,NULL,NULL,NULL,NULL);
					END IF;
				END IF;
				
				--SEPTIEMBRE
				IF MONTH(dFechaInicioBusqueda) = 9 AND cMesAnterior = '0' THEN
					IF pBanderaTipoBonificacion = 3 THEN 
						UPDATE sd_gastos_bonificacion SET gasto_septiembre = dSumaTotalHisCargoNormal
							WHERE fecha_registro = dFechaInicioOriginal AND num_credito = pCredito AND anio_registro = iAnioRegistro;
					ELSE
						INSERT INTO sd_gastos_bonificacion (empresa,fecha_registro,anio_registro,num_credito,gasto_enero,gasto_febrero,gasto_marzo,
																   gasto_abril,gasto_mayo,gasto_junio,gasto_julio,gasto_agosto,gasto_septiembre,gasto_octubre,
																   gasto_noviembre,gasto_diciembre,gasto_total_anual,cod_ret_anual,cod_ret_mensual)
							VALUES(pEmpresa,dFechaInicioOriginal,iAnioRegistro,pCredito, NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,dSumaTotalHisCargoNormal,
								   NULL,NULL,NULL,NULL,NULL,NULL);
					END IF;
				ELIF MONTH(dFechaInicioBusqueda) = 9 AND cMesAnterior = '1' THEN
					IF pBanderaTipoBonificacion = 3 THEN 
						UPDATE sd_gastos_bonificacion SET gasto_agosto = dSumaTotalHisCargoNormal
							WHERE fecha_registro = dFechaInicioOriginal AND num_credito = pCredito AND anio_registro = iAnioRegistro;
					ELSE
						INSERT INTO sd_gastos_bonificacion (empresa,fecha_registro,anio_registro,num_credito,gasto_enero,gasto_febrero,gasto_marzo,
																   gasto_abril,gasto_mayo,gasto_junio,gasto_julio,gasto_agosto,gasto_septiembre,gasto_octubre,
																   gasto_noviembre,gasto_diciembre,gasto_total_anual,cod_ret_anual,cod_ret_mensual)
							VALUES(pEmpresa,dFechaInicioOriginal,iAnioRegistro,pCredito, NULL,NULL,NULL,NULL,NULL,NULL,NULL,dSumaTotalHisCargoNormal,NULL,
								   NULL,NULL,NULL,NULL,NULL,NULL);
					END IF;
				END IF;
				
				--OCTUBRE
				IF MONTH(dFechaInicioBusqueda) = 10 AND cMesAnterior = '0' THEN
					IF pBanderaTipoBonificacion = 3 THEN 
						UPDATE sd_gastos_bonificacion SET gasto_octubre = dSumaTotalHisCargoNormal, cod_ret_mensual = NULL
							WHERE fecha_registro = dFechaInicioOriginal AND num_credito = pCredito AND anio_registro = iAnioRegistro;
					ELSE
						INSERT INTO sd_gastos_bonificacion (empresa,fecha_registro,anio_registro,num_credito,gasto_enero,gasto_febrero,gasto_marzo,
																   gasto_abril,gasto_mayo,gasto_junio,gasto_julio,gasto_agosto,gasto_septiembre,gasto_octubre,
																   gasto_noviembre,gasto_diciembre,gasto_total_anual,cod_ret_anual,cod_ret_mensual)
							VALUES(pEmpresa,dFechaInicioOriginal,iAnioRegistro,pCredito, NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,dSumaTotalHisCargoNormal,
							       NULL,NULL,NULL,NULL,NULL);
					END IF;
				ELIF MONTH(dFechaInicioBusqueda) = 10 AND cMesAnterior = '1' THEN
					IF pBanderaTipoBonificacion = 3 THEN 
						UPDATE sd_gastos_bonificacion SET gasto_septiembre = dSumaTotalHisCargoNormal, cod_ret_mensual = NULL
							WHERE fecha_registro = dFechaInicioOriginal AND num_credito = pCredito AND anio_registro = iAnioRegistro;
					ELSE
						INSERT INTO sd_gastos_bonificacion (empresa,fecha_registro,anio_registro,num_credito,gasto_enero,gasto_febrero,gasto_marzo,
																   gasto_abril,gasto_mayo,gasto_junio,gasto_julio,gasto_agosto,gasto_septiembre,gasto_octubre,
																   gasto_noviembre,gasto_diciembre,gasto_total_anual,cod_ret_anual,cod_ret_mensual)
							VALUES(pEmpresa,dFechaInicioOriginal,iAnioRegistro,pCredito, NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,dSumaTotalHisCargoNormal,NULL,
							       NULL,NULL,NULL,NULL,NULL);
					END IF;
				END IF;
				
				--NOVIEMBRE
				IF MONTH(dFechaInicioBusqueda) = 11 AND cMesAnterior = '0' THEN
					IF pBanderaTipoBonificacion = 3 THEN 
						UPDATE sd_gastos_bonificacion SET gasto_noviembre = dSumaTotalHisCargoNormal
							WHERE fecha_registro = dFechaInicioOriginal AND num_credito = pCredito AND anio_registro = iAnioRegistro;
					ELSE
						INSERT INTO sd_gastos_bonificacion (empresa,fecha_registro,anio_registro,num_credito,gasto_enero,gasto_febrero,gasto_marzo,
																   gasto_abril,gasto_mayo,gasto_junio,gasto_julio,gasto_agosto,gasto_septiembre,gasto_octubre,
																   gasto_noviembre,gasto_diciembre,gasto_total_anual,cod_ret_anual,cod_ret_mensual)
							VALUES(pEmpresa,dFechaInicioOriginal,iAnioRegistro,pCredito, NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
								   dSumaTotalHisCargoNormal,NULL,NULL,NULL,NULL);
					END IF;
				ELIF MONTH(dFechaInicioBusqueda) = 11 AND cMesAnterior = '1' THEN
					IF pBanderaTipoBonificacion = 3 THEN 
						UPDATE sd_gastos_bonificacion SET gasto_octubre = dSumaTotalHisCargoNormal
							WHERE fecha_registro = dFechaInicioOriginal AND num_credito = pCredito AND anio_registro = iAnioRegistro;
					ELSE
						INSERT INTO sd_gastos_bonificacion (empresa,fecha_registro,anio_registro,num_credito,gasto_enero,gasto_febrero,gasto_marzo,
																   gasto_abril,gasto_mayo,gasto_junio,gasto_julio,gasto_agosto,gasto_septiembre,gasto_octubre,
																   gasto_noviembre,gasto_diciembre,gasto_total_anual,cod_ret_anual,cod_ret_mensual)
							VALUES(pEmpresa,dFechaInicioOriginal,iAnioRegistro,pCredito, NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,dSumaTotalHisCargoNormal,
								   NULL,NULL,NULL,NULL,NULL);
					END IF;
				END IF;
				
				--DIEMBRE
				IF MONTH(dFechaInicioBusqueda) = 12 AND cMesAnterior = '0' THEN
					IF pBanderaTipoBonificacion = 3 THEN 
						UPDATE sd_gastos_bonificacion SET gasto_diciembre = dSumaTotalHisCargoNormal
							WHERE fecha_registro = dFechaInicioOriginal AND num_credito = pCredito AND anio_registro = iAnioRegistro;
					ELSE
						INSERT INTO sd_gastos_bonificacion (empresa,fecha_registro,anio_registro,num_credito,gasto_enero,gasto_febrero,gasto_marzo,
																   gasto_abril,gasto_mayo,gasto_junio,gasto_julio,gasto_agosto,gasto_septiembre,gasto_octubre,
																   gasto_noviembre,gasto_diciembre,gasto_total_anual,cod_ret_anual,cod_ret_mensual)
							VALUES(pEmpresa,dFechaInicioOriginal,iAnioRegistro,pCredito,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
								   dSumaTotalHisCargoNormal,NULL,NULL,NULL);
					END IF;
				ELIF MONTH(dFechaInicioBusqueda) = 12 AND cMesAnterior = '1' THEN
					IF pBanderaTipoBonificacion = 3 THEN 
						UPDATE sd_gastos_bonificacion SET gasto_noviembre = dSumaTotalHisCargoNormal
							WHERE fecha_registro = dFechaInicioOriginal AND num_credito = pCredito AND anio_registro = iAnioRegistro;
					ELSE
						INSERT INTO sd_gastos_bonificacion (empresa,fecha_registro,anio_registro,num_credito,gasto_enero,gasto_febrero,gasto_marzo,
																   gasto_abril,gasto_mayo,gasto_junio,gasto_julio,gasto_agosto,gasto_septiembre,gasto_octubre,
																   gasto_noviembre,gasto_diciembre,gasto_total_anual,cod_ret_anual,cod_ret_mensual)
							VALUES(pEmpresa,dFechaInicioOriginal,iAnioRegistro,pCredito,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,dSumaTotalHisCargoNormal,
								   NULL,NULL,NULL,NULL);
					END IF;
				END IF;
			ELSE --MESES DESPUeS
				
				IF MONTH(dFechaInicioBusqueda) = 1 THEN
					IF YEAR(dFechaInicioBusqueda) = iAnioRegistro THEN
						UPDATE sd_gastos_bonificacion SET gasto_enero = dSumaTotalHisCargoNormal
							WHERE fecha_registro = dFechaInicioOriginal AND anio_registro = YEAR(dFechaInicioBusqueda) AND num_credito = pCredito;
					ELSE
						LET iAnioRegistro = YEAR(dFechaInicioBusqueda);
						INSERT INTO sd_gastos_bonificacion (empresa,fecha_registro,anio_registro,num_credito,gasto_enero,gasto_febrero,gasto_marzo,
																   gasto_abril,gasto_mayo,gasto_junio,gasto_julio,gasto_agosto,gasto_septiembre,gasto_octubre,
																   gasto_noviembre,gasto_diciembre,gasto_total_anual,cod_ret_anual,cod_ret_mensual)
							VALUES(pEmpresa,dFechaInicioOriginal,YEAR(dFechaInicioBusqueda),pCredito,dSumaTotalHisCargoNormal,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
							       NULL,NULL,NULL,NULL,NULL,NULL);
					END IF;
				ELIF MONTH(dFechaInicioBusqueda) = 2 THEN
					IF YEAR(dFechaInicioBusqueda) = iAnioRegistro THEN
						UPDATE sd_gastos_bonificacion SET gasto_febrero = dSumaTotalHisCargoNormal
							WHERE fecha_registro = dFechaInicioOriginal AND anio_registro = YEAR(dFechaInicioBusqueda) AND num_credito = pCredito;
					ELSE
						LET iAnioRegistro = YEAR(dFechaInicioBusqueda);
						INSERT INTO sd_gastos_bonificacion (empresa,fecha_registro,anio_registro,num_credito,gasto_enero,gasto_febrero,gasto_marzo,
																   gasto_abril,gasto_mayo,gasto_junio,gasto_julio,gasto_agosto,gasto_septiembre,gasto_octubre,
																   gasto_noviembre,gasto_diciembre,gasto_total_anual,cod_ret_anual,cod_ret_mensual)
							VALUES(pEmpresa,dFechaInicioOriginal,YEAR(dFechaInicioBusqueda),pCredito,NULL,dSumaTotalHisCargoNormal,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
								   NULL,NULL,NULL,NULL,NULL,NULL);
					END IF;
				ELIF MONTH(dFechaInicioBusqueda) = 3 THEN
					IF YEAR(dFechaInicioBusqueda) = iAnioRegistro THEN
						UPDATE sd_gastos_bonificacion SET gasto_marzo = dSumaTotalHisCargoNormal
							WHERE fecha_registro = dFechaInicioOriginal AND anio_registro = YEAR(dFechaInicioBusqueda) AND num_credito = pCredito;
					ELSE
						LET iAnioRegistro = YEAR(dFechaInicioBusqueda);
						INSERT INTO sd_gastos_bonificacion (empresa,fecha_registro,anio_registro,num_credito,gasto_enero,gasto_febrero,gasto_marzo,
																   gasto_abril,gasto_mayo,gasto_junio,gasto_julio,gasto_agosto,gasto_septiembre,gasto_octubre,
																   gasto_noviembre,gasto_diciembre,gasto_total_anual,cod_ret_anual,cod_ret_mensual)
							VALUES(pEmpresa,dFechaInicioOriginal,YEAR(dFechaInicioBusqueda),pCredito,NULL,NULL,dSumaTotalHisCargoNormal,NULL,NULL,NULL,NULL,NULL,NULL,
								   NULL,NULL,NULL,NULL,NULL,NULL);
					END IF;
				ELIF MONTH(dFechaInicioBusqueda) = 4 THEN
					IF YEAR(dFechaInicioBusqueda) = iAnioRegistro THEN
						UPDATE sd_gastos_bonificacion SET gasto_abril = dSumaTotalHisCargoNormal
							WHERE fecha_registro = dFechaInicioOriginal AND anio_registro = YEAR(dFechaInicioBusqueda) AND num_credito = pCredito;
					ELSE
						LET iAnioRegistro = YEAR(dFechaInicioBusqueda);
						INSERT INTO sd_gastos_bonificacion (empresa,fecha_registro,anio_registro,num_credito,gasto_enero,gasto_febrero,gasto_marzo,
																   gasto_abril,gasto_mayo,gasto_junio,gasto_julio,gasto_agosto,gasto_septiembre,gasto_octubre,
																   gasto_noviembre,gasto_diciembre,gasto_total_anual,cod_ret_anual,cod_ret_mensual)
							VALUES(pEmpresa,dFechaInicioOriginal,YEAR(dFechaInicioBusqueda),pCredito,NULL,NULL,NULL,dSumaTotalHisCargoNormal,NULL,NULL,NULL,NULL,NULL,
							       NULL,NULL,NULL,NULL,NULL,NULL);
					END IF;
				ELIF MONTH(dFechaInicioBusqueda) = 5 THEN
					IF YEAR(dFechaInicioBusqueda) = iAnioRegistro THEN
						UPDATE sd_gastos_bonificacion SET gasto_mayo = dSumaTotalHisCargoNormal
							WHERE fecha_registro = dFechaInicioOriginal AND anio_registro = YEAR(dFechaInicioBusqueda) AND num_credito = pCredito;
					ELSE
						LET iAnioRegistro = YEAR(dFechaInicioBusqueda);
						INSERT INTO sd_gastos_bonificacion (empresa,fecha_registro,anio_registro,num_credito,gasto_enero,gasto_febrero,gasto_marzo,
																   gasto_abril,gasto_mayo,gasto_junio,gasto_julio,gasto_agosto,gasto_septiembre,gasto_octubre,
																   gasto_noviembre,gasto_diciembre,gasto_total_anual,cod_ret_anual,cod_ret_mensual)
							VALUES(pEmpresa,dFechaInicioOriginal,YEAR(dFechaInicioBusqueda),pCredito,NULL,NULL,NULL,NULL,dSumaTotalHisCargoNormal,NULL,NULL,NULL,NULL,
							       NULL,NULL,NULL,NULL,NULL,NULL);
					END IF;
				ELIF MONTH(dFechaInicioBusqueda) = 6 THEN
					IF YEAR(dFechaInicioBusqueda) = iAnioRegistro THEN
						UPDATE sd_gastos_bonificacion SET gasto_junio = dSumaTotalHisCargoNormal
							WHERE fecha_registro = dFechaInicioOriginal AND anio_registro = YEAR(dFechaInicioBusqueda) AND num_credito = pCredito;
					ELSE
						LET iAnioRegistro = YEAR(dFechaInicioBusqueda);
						INSERT INTO sd_gastos_bonificacion (empresa,fecha_registro,anio_registro,num_credito,gasto_enero,gasto_febrero,gasto_marzo,
																   gasto_abril,gasto_mayo,gasto_junio,gasto_julio,gasto_agosto,gasto_septiembre,gasto_octubre,
																   gasto_noviembre,gasto_diciembre,gasto_total_anual,cod_ret_anual,cod_ret_mensual)
							VALUES(pEmpresa,dFechaInicioOriginal,YEAR(dFechaInicioBusqueda),pCredito,NULL,NULL,NULL,NULL,NULL,dSumaTotalHisCargoNormal,NULL,NULL,NULL,
								   NULL,NULL,NULL,NULL,NULL,NULL);
					END IF;
				ELIF MONTH(dFechaInicioBusqueda) = 7 THEN
					IF YEAR(dFechaInicioBusqueda) = iAnioRegistro THEN
						UPDATE sd_gastos_bonificacion SET gasto_julio = dSumaTotalHisCargoNormal
							WHERE fecha_registro = dFechaInicioOriginal AND anio_registro = YEAR(dFechaInicioBusqueda) AND num_credito = pCredito;
					ELSE
						LET iAnioRegistro = YEAR(dFechaInicioBusqueda);
						INSERT INTO sd_gastos_bonificacion (empresa,fecha_registro,anio_registro,num_credito,gasto_enero,gasto_febrero,gasto_marzo,
																   gasto_abril,gasto_mayo,gasto_junio,gasto_julio,gasto_agosto,gasto_septiembre,gasto_octubre,
																   gasto_noviembre,gasto_diciembre,gasto_total_anual,cod_ret_anual,cod_ret_mensual)
							VALUES(pEmpresa,dFechaInicioOriginal,YEAR(dFechaInicioBusqueda),pCredito,NULL,NULL,NULL,NULL,NULL,NULL,dSumaTotalHisCargoNormal,NULL,NULL,
								   NULL,NULL,NULL,NULL,NULL,NULL);
					END IF;
				ELIF MONTH(dFechaInicioBusqueda) = 8 THEN
					IF YEAR(dFechaInicioBusqueda) = iAnioRegistro THEN
						UPDATE sd_gastos_bonificacion SET gasto_agosto = dSumaTotalHisCargoNormal
							WHERE fecha_registro = dFechaInicioOriginal AND anio_registro = YEAR(dFechaInicioBusqueda) AND num_credito = pCredito;
					ELSE
						LET iAnioRegistro = YEAR(dFechaInicioBusqueda);
						INSERT INTO sd_gastos_bonificacion (empresa,fecha_registro,anio_registro,num_credito,gasto_enero,gasto_febrero,gasto_marzo,
																   gasto_abril,gasto_mayo,gasto_junio,gasto_julio,gasto_agosto,gasto_septiembre,gasto_octubre,
																   gasto_noviembre,gasto_diciembre,gasto_total_anual,cod_ret_anual,cod_ret_mensual)
							VALUES(pEmpresa,dFechaInicioOriginal,YEAR(dFechaInicioBusqueda),pCredito,NULL,NULL,NULL,NULL,NULL,NULL,NULL,dSumaTotalHisCargoNormal,NULL,
								   NULL,NULL,NULL,NULL,NULL,NULL);
					END IF;
				ELIF MONTH(dFechaInicioBusqueda) = 9 THEN
					IF YEAR(dFechaInicioBusqueda) = iAnioRegistro THEN
						UPDATE sd_gastos_bonificacion SET gasto_septiembre = dSumaTotalHisCargoNormal
							WHERE fecha_registro = dFechaInicioOriginal AND anio_registro = YEAR(dFechaInicioBusqueda) AND num_credito = pCredito;
					ELSE
						LET iAnioRegistro = YEAR(dFechaInicioBusqueda);
						INSERT INTO sd_gastos_bonificacion (empresa,fecha_registro,anio_registro,num_credito,gasto_enero,gasto_febrero,gasto_marzo,
																   gasto_abril,gasto_mayo,gasto_junio,gasto_julio,gasto_agosto,gasto_septiembre,gasto_octubre,
																   gasto_noviembre,gasto_diciembre,gasto_total_anual,cod_ret_anual,cod_ret_mensual)
							VALUES(pEmpresa,dFechaInicioOriginal,YEAR(dFechaInicioBusqueda),pCredito,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,dSumaTotalHisCargoNormal,NULL,
								   NULL,NULL,NULL,NULL,NULL);
					END IF;
				ELIF MONTH(dFechaInicioBusqueda) = 10 THEN
					IF YEAR(dFechaInicioBusqueda) = iAnioRegistro THEN
						UPDATE sd_gastos_bonificacion SET gasto_octubre = dSumaTotalHisCargoNormal
							WHERE fecha_registro = dFechaInicioOriginal AND anio_registro = YEAR(dFechaInicioBusqueda) AND num_credito = pCredito;
					ELSE
						LET iAnioRegistro = YEAR(dFechaInicioBusqueda);
						INSERT INTO sd_gastos_bonificacion (empresa,fecha_registro,anio_registro,num_credito,gasto_enero,gasto_febrero,gasto_marzo,
																   gasto_abril,gasto_mayo,gasto_junio,gasto_julio,gasto_agosto,gasto_septiembre,gasto_octubre,
																   gasto_noviembre,gasto_diciembre,gasto_total_anual,cod_ret_anual,cod_ret_mensual)
							VALUES(pEmpresa,dFechaInicioOriginal,YEAR(dFechaInicioBusqueda),pCredito,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,dSumaTotalHisCargoNormal,
								   NULL,NULL,NULL,NULL,NULL);
					END IF;
				ELIF MONTH(dFechaInicioBusqueda) = 11 THEN
					IF YEAR(dFechaInicioBusqueda) = iAnioRegistro THEN
						UPDATE sd_gastos_bonificacion SET gasto_noviembre = dSumaTotalHisCargoNormal
							WHERE fecha_registro = dFechaInicioOriginal AND anio_registro = YEAR(dFechaInicioBusqueda) AND num_credito = pCredito;
					ELSE
						LET iAnioRegistro = YEAR(dFechaInicioBusqueda);
						INSERT INTO sd_gastos_bonificacion (empresa,fecha_registro,anio_registro,num_credito,gasto_enero,gasto_febrero,gasto_marzo,
																   gasto_abril,gasto_mayo,gasto_junio,gasto_julio,gasto_agosto,gasto_septiembre,gasto_octubre,
																   gasto_noviembre,gasto_diciembre,gasto_total_anual,cod_ret_anual,cod_ret_mensual)
							VALUES(pEmpresa,dFechaInicioOriginal,YEAR(dFechaInicioBusqueda),pCredito,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
								   dSumaTotalHisCargoNormal,NULL,NULL,NULL,NULL);
					END IF;
				ELSE--12
					IF YEAR(dFechaInicioBusqueda) = iAnioRegistro THEN
						UPDATE sd_gastos_bonificacion SET gasto_diciembre = dSumaTotalHisCargoNormal
							WHERE fecha_registro = dFechaInicioOriginal AND anio_registro = YEAR(dFechaInicioBusqueda) AND num_credito = pCredito;
					ELSE
						LET iAnioRegistro = YEAR(dFechaInicioBusqueda);
						INSERT INTO sd_gastos_bonificacion (empresa,fecha_registro,anio_registro,num_credito,gasto_enero,gasto_febrero,gasto_marzo,
																   gasto_abril,gasto_mayo,gasto_junio,gasto_julio,gasto_agosto,gasto_septiembre,gasto_octubre,
																   gasto_noviembre,gasto_diciembre,gasto_total_anual,cod_ret_anual,cod_ret_mensual)
							VALUES(pEmpresa,dFechaInicioOriginal,YEAR(dFechaInicioBusqueda),pCredito,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
								   dSumaTotalHisCargoNormal,NULL,NULL,NULL);
					END IF;
				END IF;
			END IF;
						
			LET dFechaInicioBusqueda = dFechaCorte + 1 UNITS DAY;
			LET dFechaCorte = dFechaCorte + 1 UNITS MONTH;
			
			IF dFechaCorte > dFechaAnualidad THEN
				LET dFechaCorte = dFechaAnualidad;
			END IF;
			
			LET sContador = sContador + 1;
		END WHILE;
	END IF; --pBanderaTipoBonificacion
	
	RETURN cod_ret;
   END;
END PROCEDURE
;
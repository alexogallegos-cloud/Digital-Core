CREATE PROCEDURE "informix".sp_prevalida_cancelacion_credito (pEmpresa CHAR(3), pNumCredito CHAR(20))
RETURNING
	CHAR(5) AS CodRet
	
	-- DECLARACIONES
    DEFINE cCodRet		   		    CHAR(5);
	DEFINE iSqlErr					INTEGER;
	DEFINE cBandTrans				CHAR(1);
	DEFINE cProducto				CHAR(4);
	DEFINE cStaCredito				CHAR(2);
	DEFINE cNumCte					CHAR(20);
	DEFINE iUnidadProd				INTEGER;
	DEFINE cCodCaracter				CHAR(3);
	DEFINE cCodCaracter2			CHAR(3);
	DEFINE cCliente                 CHAR(20);
	DEFINE dSdoRetenido				DECIMAL(18,2);
	DEFINE dCapVig					DECIMAL(18,2);
	DEFINE dMontoSBC				DECIMAL(18,2);
	DEFINE dSdoActTotalCap			DECIMAL(18,2);
	DEFINE dSdoActTotalInt			DECIMAL(18,2);
	DEFINE dSdoActTotalIva			DECIMAL(18,2);
	DEFINE dIva						DECIMAL(5,3);
	DEFINE dfh_pre_devol_an         DATE;
    DEFINE dfh_devol_an             DATE;

	DEFINE dFech_1er_an     		DATE;
	DEFINE dFech_prox_an    		DATE;
	DEFINE dFech_prev_an    		DATE;
	DEFINE dFechaHoy        		DATE;
	DEFINE dFechaPreDevol   		DATE;
	DEFINE dFechaDevol      		DATE;
	DEFINE dFechaTrspDevol			DATE;
	DEFINE cNumCred         		CHAR(20);
	DEFINE dSdo_Capital     		DECIMAL(18,2);
	DEFINE mMntoTotCobT     		DECIMAL(18,2); --MONEY;
	DEFINE cSucursal        		CHAR(4);
	DEFINE iBloqueo         		INTEGER;
	DEFINE sDiasTotAnio     		SMALLINT;
	DEFINE sDiasTransCob       		INTEGER;
	DEFINE sDiasNoCobParam  		INTEGER;
	DEFINE dFechaCobPrevT   		DATE;
	DEFINE mMntoAplCobT     		DECIMAL(18,2); --MONEY;
	DEFINE mMntoTotCobA     		DECIMAL(18,2); --MONEY;
	DEFINE mMntoAplCobA     		DECIMAL(18,2); --MONEY;
	DEFINE sPorcentNoCob    		DECIMAL(18,2);
	DEFINE dMntoDevolTit    		DECIMAL(16,2);
	DEFINE dMntoDevolAdi    		DECIMAL(16,2);
	DEFINE mMntoAnUsadAux   		MONEY;
	DEFINE dMntoIvaCobr     		DECIMAL(16,2);
	DEFINE dMntoIvaDevol    		DECIMAL(16,2);
	DEFINE dMntoDevol       		DECIMAL(16,2);
	DEFINE cAplicaBoniAnual 		CHAR(1);
	

	
	-- INICIALIZACIONES
	LET cCodRet 				= "00000";
	LET iSqlErr 				= 0;
	LET cBandTrans				= "0";
	LET cProducto				= "";
	LET cStaCredito				= "";
	LET cNumCte					= "";
	LET iUnidadProd				= 0;
	LET cCodCaracter    		= "";
	LET cCodCaracter2   		= "";
	LET dSdoRetenido			= 0.0;
	LET dCapVig					= 0.0;
	LET dMontoSBC				= 0.0;
	LET dSdoActTotalCap			= 0.0;
	LET dSdoActTotalInt			= 0.0;
	LET dSdoActTotalIva			= 0.0;
	LET dIva					= 0.0;
	LET dfh_pre_devol_an        = DATE(1);
    LET dfh_devol_an            = DATE(1);

	LET dFech_1er_an    		= DATE(1);
	LET dFech_prox_an   		= DATE(1);
	LET dFech_prev_an   		= DATE(1);
	LET dFechaHoy       		= DATE(1);
	LET dFechaPreDevol  		= DATE(1);
	LET dFechaDevol     		= DATE(1);
	LET dFechaTrspDevol 		= DATE(1);
	LET cNumCred        		= '';
	LET dSdo_Capital    		= 0;
	LET mMntoTotCobT    		= 0;
	LET cSucursal       		= '';
	LET iBloqueo        		= 0;
	LET sDiasTotAnio    		= 0;
	LET sDiasTransCob      		= 0;
	LET sDiasNoCobParam 		= 0;
	LET dFechaCobPrevT  		= DATE(1);
	LET mMntoAplCobT    		= 0;
	LET mMntoTotCobA    		= 0;
	LET mMntoAplCobA    		= 0;
	LET sPorcentNoCob   		= 0;
	LET dMntoDevolTit   		= 0;
	LET dMntoDevolAdi   		= 0;
	LET mMntoAnUsadAux  		= 0;
	LET dMntoIvaCobr    		= 0;
	LET dMntoIvaDevol  			= 0;
	LET dMntoDevol      		= 0;
	LET cAplicaBoniAnual		='0';
	

	  --SET DEBUG FILE TO "/informix/resplogifx/archivoscredito/sp_prevalida_cancelacion_credito.out";
	  --TRACE ON;
BEGIN

	ON EXCEPTION
        SET iSqlErr
        IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
        END IF;
		IF cBandTrans = '1' THEN
			-- EN CASO DE ERROR DE INFORMIX ABORTA LA TRANSACCION
			ROLLBACK WORK;
		END IF
        RETURN TRIM(cCodRet);
    END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	-- VALIDA QUE NO ESTEN VACIOS LOS PARAMETROS
    IF TRIM(NVL(pEmpresa, '')) = '' OR TRIM(NVL(pNumCredito, '')) = '' THEN 
		LET cCodRet = '00001';
		RETURN TRIM(cCodRet);
	END IF
	
	-- OBTIENE EL PRODUCTO ,  LA SUCURSAL DEL CREDITO Y EL ESTATUS DEL CREDITO
	SELECT mae.num_producto, mae.sucursal, mae.status_cred, mae.numcte, mae.id_unidad_prod, mae.cod_caract, mae.cod_caract_2,def.aplica_boni_anual
	INTO cProducto, cSucursal, cStaCredito, cNumCte, iUnidadProd, cCodCaracter, cCodCaracter2,cAplicaBoniAnual
	FROM "informix".sd_maecred mae
	INNER JOIN bdicred:"informix".sd_definicion def
	ON def.num_producto = mae.num_producto
		AND mae.empresa = def.empresa
	WHERE num_credito = pNumCredito;
	
    -- Obtiene marcas de creditos pre-cancelados por devolucion de anualidad
    SELECT nvl(date(fecha_pre_devol_anual),date(1)), nvl(date(fecha_devol_anual),date(1))
	  INTO dfh_pre_devol_an, dfh_devol_an
      FROM bdicred:sd_indicador_cred WHERE empresa = pEmpresa AND num_credito = pNumCredito;

	-- VALIDA QUE EL CREDITO EXISTA
	IF TRIM(NVL(cNumCte,'')) = '' THEN
		LET cCodRet = '00003'; -- CREDITO NO EXISTE
		RETURN cCodRet;
	END IF
	-- AAME 31012017 Se agregan los productos de crÃ©dito platino y oro para que se contemplen en la cancelaciÃ³n de crÃ©ditos
	-- VALIDA QUE SEA UN PRODUCTO DE TARJETA DE CREDITO
	--BONIFICACION SE AGG. 5400
	IF TRIM(cProducto) NOT IN( '7000','8100','6001','7800','8500','5400') THEN--validar si mejor se consulta la tabla donde se encuentran todos los creditos revolventes
		LET cCodRet = '00004';
		RETURN TRIM(cCodRet);
	END IF
	
-- OBTIENE LA FECHA DEL DIA
	SELECT FECHA_HOY
	INTO dFechaHoy
	FROM "informix".sd_fechas
	WHERE empresa = '001';
	
	IF cStaCredito = 'FF' THEN 
		SELECT DISTINCT(num_cte) --SE CONSULTA A VER SI EL CRÃDITO ESTA CANCELADO
		INTO cCliente
		FROM "informix".sd_cred_can
		WHERE num_credito = pNumCredito
		AND folio_cancelacion <> "" ;
		
		IF NVL(cCliente, "") = "" THEN --SI NO HAY REGISTROS DE QUE ESTE CANCELADO ENTRA AQUI
			LET cCodRet = '00017'; -- CREDITO SALDADO NORMAL (NO CANCELADO)
		ELSE --SI HAY REGISTROS QUIERE DECIR QUE ESTA CANCELADO
			LET cCodRet = '00011'; -- CREDITO CANCELADO
        END IF		
	ELIF cStaCredito = 'CV' THEN
		LET cCodRet = '00012'; -- CREDITO VENCIDO	
	ELIF cStaCredito = 'BA' THEN
		LET cCodRet = '00013'; -- CREDITO VENCIDO NORMAL
	ELIF cStaCredito = 'BT' THEN
		LET cCodRet = '00014'; -- CREDITO VENCIDO TRASPASADO
	ELIF cStaCredito = 'FC' THEN
		LET cCodRet = '00015'; -- CREDITO SALDADO RESTRUCTURADO CONSOLIDADO
	ELIF iUnidadProd IS NOT NULL OR cCodCaracter <> '' OR cCodCaracter2 <> '' THEN
		LET cCodRet = '00010'; -- CREDITO BLOQUEADO
        -- Elimina marca para creditos bloqueados por devolucion de anualidad, para que puedan cancelarse esos creditos.
        IF iUnidadProd = 4 AND nvl(dfh_pre_devol_an,date(1)) > date(1) THEN -- AND nvl(dfh_devol_an,date(1)) = date(1) THEN 
            LET cCodRet = '00000';
        END IF;
	END IF
    
	IF cCodRet='00000' THEN 
			-- OBTIENE EL SALDO RETENIDO, EL CAPITAL VIGENTE Y EL CAPITAL INSOLUTO
			SELECT NVL(sdo_retenido,0), NVL(sdo_capital,0), NVL(sdo_cap_insoluto,0)
			INTO dSdoRetenido, dCapVig, dSdoActTotalCap
			FROM "informix".sd_maesdos
			WHERE num_credito = pNumCredito;

			IF dSdoRetenido > 0 THEN
				LET cCodRet = '00016'; -- CREDITO SALDO RETENIDO
			END IF
			
			IF cCodRet = '00000' THEN
				-- VALIDA QUE LOS SALDOS NO ESTEN EN CEROS Y QUE TENGA ESTATUS VIGENTE
				IF dCapVig <> 0 OR dSdoActTotalCap <> 0 THEN
					LET cCodRet = '00005'; -- CREDITO CON SALDO	
				ELSE		
					-- OBTIENE EL MONTO DE SALVO BUEN COBRO
					SELECT NVL(SUM(monto),0)
					INTO dMontoSBC
					FROM bdicheq:"informix".sc_docret 
					WHERE empresa = pEmpresa
					AND cuenta = pNumCredito
					AND siglas  = 'SD'
					AND cancelado = 'T';

				IF dMontoSBC = 0 THEN
					-- OBTIENE EL SALDO ACTUAL TOTAL INTERES
					SELECT NVL(SUM(NVL(interes_debe,0) - NVL(interes_pagado,0)) + 
					SUM(NVL(mora_provi_ordi,0) + NVL(mora_provi_cope,0) + NVL(mora_sdo_ordi,0) - NVL(mora_sdo_ordi_pag,0) 
					+ NVL(mora_sdo_cope,0) - NVL(mora_sdo_cope_pag,0)),0)
					INTO dSdoActTotalInt
					FROM "informix".sd_amortiza_credito 
					WHERE empresa = pEmpresa
					AND num_credito = pNumCredito
					AND capital_status IN ('2','7');

					IF dSdoActTotalInt = 0 THEN
						-- OBTIENE EL IVA DE LA SUCURSAL
						SELECT iva
						INTO dIva
						FROM bdinteg:"informix".si_sucursales
						WHERE sucursal = cSucursal;

						-- OBTIENE EL SALDO ACTUAL TOTAL IVA
						SELECT NVL(SUM(NVL(mora_provi_ordi,0) + NVL(mora_provi_cope,0) + NVL(mora_sdo_ordi,0) - NVL(mora_sdo_ordi_pag,0) 
						+ NVL(mora_sdo_cope,0) - NVL(mora_sdo_cope_pag,0)) * dIva,0)
						INTO dSdoActTotalIva
						FROM "informix".sd_amortiza_credito 
						WHERE empresa = pEmpresa
						AND num_credito = pNumCredito
						AND capital_status IN ('2','7');

						IF dSdoActTotalIva <> 0 THEN
							LET cCodRet = '00005'; -- CREDITO CON SALDO
						END IF;					
					ELSE
						LET cCodRet = '00005'; -- CREDITO CON SALDO
					END IF				
				ELSE
					LET cCodRet = '00005'; -- CREDITO CON SALDO
				END IF			
			END IF		
	      END IF

			

			IF cCodRet = '00000' THEN
			
				SELECT fecha_hoy INTO dFechaHoy FROM bdicred:"informix".sd_fechas WHERE empresa = pEmpresa;
				-- Se identifica si el credito tiene anualidad pendiente de cobrar.
				SELECT ind.num_credito, nvl(ind.fecha_1er_anualidad, date(1)), nvl(ind.fecha_prox_anualidad, date(1)), 
					dos.sdo_capital, nvl(date(fecha_pre_devol_anual), date(1)), nvl(date(fecha_devol_anual), date(1)), 
					nvl(date(fecha_trasp_devol_anual),date(1)), crd.id_unidad_prod
				INTO cNumCred, dFech_1er_an, dFech_prox_an, dSdo_Capital, dFechaPreDevol, dFechaDevol, dFechaTrspDevol, iBloqueo
				FROM bdicred:sd_indicador_cred ind JOIN bdicred:sd_maecred crd ON (ind.empresa = crd.empresa AND ind.num_credito = crd.num_credito)
				JOIN bdicred:sd_maesdos dos ON (ind.empresa = dos.empresa AND ind.num_credito = dos.num_credito)
				WHERE ind.empresa = pEmpresa AND ind.num_credito = pNumCredito;

				
				IF NVL(cNumCred, '') != '' OR dFech_1er_an != date(1) OR dFech_prox_an >= dFechaHoy OR dFech_1er_an != dFech_prox_an OR
					((nvl(dFech_1er_an, date(1)) != date(1)) and (nvl(dFech_prox_an, date(1)) != date(1)) ) THEN

						
					-- Verifica que el cliente realizo retiro en ventanilla y procede a cancelar el credito
					IF (nvl(dFechaPreDevol, date(1)) > date(1) AND nvl(dFechaDevol, date(1)) > date(1) AND nvl(dFechaTrspDevol,date(1)) = date(1)
						AND dSdo_Capital = 0 ) THEN 
							-- Si se ejecuta desde OFI no deje pasar la cancelacion, por que ya se hizo el retiro. Se cancela con job
							LET cCodRet = '01208';
							RETURN cCodRet;
					END IF;	
					-- Verifica traspaso por no retiro de devolucion. Se realizo traspaso, se cancelara cta
					IF (nvl(dFechaPreDevol, date(1)) > date(1) AND nvl(dFechaDevol, date(1)) = date(1) AND nvl(dFechaTrspDevol,date(1)) > date(1)
						AND dSdo_Capital = 0 ) THEN 
						LET cCodRet = '00000';
						RETURN cCodRet;
					END IF;	
					
					
					LET dFech_prev_an = monthadd(dFech_prox_an, -12);
					-- Obtiene el numero de dia de diferencia entre los dos aÃ±os
					LET sDiasTotAnio = mdy('01','01',year(dFech_prox_an)) - mdy('01','01',year(dFech_prev_an));
					
					-- Obtiene los dias no devengados. Dias que no se cubrieron para cumplir el aÃ±o. sDiasTransCob = Contiene  los dias transcurridos
					LET sDiasTransCob = date((dFechaHoy + 1 units day)) - date((dFech_prev_an - 1 units day));
					
					-- Obtiene el numero de dias parametro no devengados
					SELECT valor_numerico INTO sDiasNoCobParam FROM bdicred:sd_param_campania 
					 WHERE empresa = pEmpresa AND tipo_campania = 70 AND grupo_parametro = 'COMI_ANUAL' AND num_parametro = 1;
					--	Dias total del aÃ±o - Dias transcurridos = dias no devengados.	Dias no devengados sean menor a 30, no aplica devolucion.
					IF (sDiasTotAnio - sDiasTransCob) <= sDiasNoCobParam THEN -- Inicialmente sDiasNoCobParam = 30
						LET cCodRet = '00000';
						RETURN cCodRet;
					END IF;
					-- Verifica estatus de precancelacion y ya realizÃ³ el retiro de la devolucion. Para concluir proceso de devolucion de anualidad.
					IF (nvl(dFechaPreDevol, date(1)) > date(1) AND nvl(dFechaDevol, date(1)) = date(1) AND nvl(dFechaTrspDevol,date(1)) = date(1)
						AND iBloqueo = 4 AND dSdo_Capital = 0 ) THEN 
						LET cCodRet = '00000';
						RETURN cCodRet;
					END IF;
					  -- Verifica si es candidato a devolucion de comision por anualidad, a fin de iniciar proceso de pre-devolucion.
					SELECT MAX(fecha_insert) INTO dFechaCobPrevT FROM bdicred:sd_comision_x_apertura_contable
					WHERE empresa = pEmpresa AND num_credito = pNumCredito AND diferim_parcial = 'PT' AND proceso_comision = 'ANUALIDAD';
					
					-- RQM 10 1669 INCREMENTALES TDC: SE AGREGA LA CONDICION DEL NUMERO DE MESES PARA EVITAR 
					-- QUE PROYECTE SOBRE ANUAIDADES BONIFICADAS
					IF dFechaCobPrevT != dFech_prev_an AND MONTHS_BETWEEN(dFech_prev_an,dFechaCobPrevT)<12 THEN -- Obtiene la fecha del ultimo cobro de comision por anualidad
						LET dFech_prev_an = dFechaCobPrevT;
					END IF;
					
					--RQM 10 1669 INCREMENTALES TDC: INICIAN CAMBIOS PROYECTO BONIFICACION ANUAL TDC 
					--Si la bonificacion esta encendida al cancelar el credito, no hay un reembolso de la misma
					IF cAplicaBoniAnual = '0' THEN 
						-- mMntoTotCob = Monto total de la comision / mMntoAplCob = Monto cobrado comision
						SELECT NVL(monto_afectacion,0), NVL(monto_aplicado,0) INTO mMntoTotCobT, mMntoAplCobT FROM bdicred:sd_comision_x_apertura_contable
						 WHERE empresa = pEmpresa AND num_credito = pNumCredito AND diferim_parcial = 'PT' AND proceso_comision = 'ANUALIDAD' AND fecha_insert = dFech_prev_an;

						-- mMntoTotCobA = Monto total de la comision / mMntoAplCobA = Monto cobrado comision     
						SELECT NVL(monto_afectacion,0), NVL(monto_aplicado,0) INTO mMntoTotCobA, mMntoAplCobA FROM bdicred:sd_comision_x_apertura_contable
						 WHERE empresa = pEmpresa AND num_credito = pNumCredito AND diferim_parcial = 'PA' AND proceso_comision = 'ANUALIDAD' AND fecha_insert = dFech_prev_an;

						-- Obtiene el porcentaje de anualidad no utilizado.
						LET sPorcentNoCob = (sDiasTotAnio - sDiasTransCob) / sDiasTotAnio;
						
						-- Obtiene el monto a abonar por TDC Titular y TDC Adicional. De los dias NO devengados (no usados)
						LET dMntoDevolTit = nvl((mMntoTotCobT * sPorcentNoCob),0);
						LET dMntoDevolAdi = nvl((mMntoTotCobA * sPorcentNoCob),0);
						
						IF mMntoTotCobT > mMntoAplCobT THEN -- Si la anualidad fue parcializada, y no ha sido pagada por completo = El total es mayor al pagado.

							LET mMntoAnUsadAux = mMntoTotCobT - dMntoDevolTit; -- Monto de anualidad usada. Correspondiente a los dias SI devengados.
							LET dMntoDevolTit = mMntoAplCobT - mMntoAnUsadAux; -- Monto de devolucion correspondiente al monto pagado de la anualidad. 

							IF mMntoTotCobA > mMntoAplCobA THEN -- Calcula el monto devolucion correspondiente al monto pagado en parcialidades.

								LET mMntoAnUsadAux = 0;
								LET mMntoAnUsadAux = mMntoTotCobA - dMntoDevolAdi; -- Monto de anualidad usada. Correspondiente a los dias SI devengados.
								LET dMntoDevolAdi = mMntoAplCobA - mMntoAnUsadAux; -- Monto de devolucion correspondiente al monto pagado de la anualidad. 
								IF dMntoDevolAdi < 0 THEN LET dMntoDevolAdi = 0; END IF;

							END IF;
						END IF;
					END IF;					-- Realiza el abono del monto de la devolucion de la comision por anualidad
					IF dMntoDevolTit > 0 THEN-- en caso de que sea  mayor, se calcula el iva en caso de que no termina el flujo

						-- Obtiene el monto cargado con respecto a la comision anualidad para adicionales.
						SELECT nvl(SUM(monto),0) INTO dMntoIvaCobr
						  FROM bdicred:sd_movhis WHERE empresa = pEmpresa AND fecha_mov >= dFech_prev_an AND fecha_mov < dFech_prox_an AND num_credito = pNumCredito
						   AND codigo_fun = '340' AND codigo_ref IN (30,31) AND reversado = 'N';
						IF dMntoIvaCobr > 0 THEN

							-- Realiza el calculo para el iva.
							LET dMntoIvaDevol = dMntoIvaCobr * sPorcentNoCob;
							
						END IF;
					ELSE
					    --BONIFICACION: SE AGREGA VALDIACION PARA QUE AL PRODUCTO INFINTIE NO SE MUESTRE EL MENSAJE DE RETENCION
						IF TRIM(cProducto) = '5400' THEN
						--RQM 10 1669 INCREMENTALES TDC: SE UTILIZA ESTE CODIGO DE ERROR PARA CONTROLAR QUE ALOS CLIENTES/USUARIOS   
						--INFINITE NO SE LES MUESTRE EL MENSAJE DE RETENCION
							LET cCodRet = '01212';
						ELSE
							LET cCodRet = '00000';
						END IF;
						RETURN cCodRet;
					END IF;
					
					LET dMntoDevol = round((dMntoDevolTit + dMntoDevolAdi),0) + round(dMntoIvaDevol,0); -- si esto es mayorr a 0 retorna 1211
					IF dMntoDevolTit > 0 THEN
					    LET cCodRet = '01211';
						RETURN cCodRet;
                    END IF;
				END IF;
            END IF;

	END IF;
	RETURN TRIM(cCodRet);
END  
END PROCEDURE
DOCUMENT
'MODIFICO: Andrea Cubas',
'DESCRIPCION: Se crea el sp incluyendo las validaciones necesarias para saber  si el crÃ©dito ingresado es vÃ¡lido para cancelar sin realizar el proceso de cancelaciÃ³n', 
'FECHA DE MODIFICACIÃN: 08 de Febrero de 2022',
'BD: BDICRED',
'FOLIO: 833.1 - Adendum RQM 10 1405 CÃ©lula de RetenciÃ³n TDC	',
'MODIFICO: Arturo Astorga',
'DESCRIPCION: Se agrega el producto 5400, se agrega la validacion del numero de meses al recuperar el monto de anualidad cobrado y se controla codigo de error para ',
'             no mostrar msj retencion', 
'FECHA DE MODIFICACIÃN: 06 de Noviembre de 2024',
'BD: BDICRED',
'FOLIO: RQM 10 1669 INCREMENTALES TDC',
'MODIFICO: Arturo Astorga',
'DESCRIPCION: Se agrega validacion de la bandera de bonificacion del producto para evitar proyectar el reembolso de la anualidad cobrada ',
'FECHA DE MODIFICACIÃN: 08 de Noviembre de 2024',
'BD: BDICRED',
'FOLIO: RQM 10 1669 INCREMENTALES TDC'
;

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
CREATE PROCEDURE "informix".sp_msi_proyecta_msi
(
	pTipo 			SMALLINT, 		-- 1- consulta proyeccion, 2-regresa el desglose, 3-guarda proyeccion
	pSucursal 		CHAR(4),
	pEjecutivo		CHAR(8),
	pNumPromocion 	SMALLINT, 		-- 10 Meses sin intereses
	pNumCredito 	CHAR(20),
	pNumTarjeta		CHAR(20),
	pMonto 			DECIMAL(18,2),
	pPlazo 			SMALLINT,
	pTasa			SMALLINT,
	pFolioMovto		CHAR(16)
)

RETURNING
	CHAR(6) 		AS cod_ret,
	CHAR(80)		AS descripcion,
	DECIMAL(18,2)	AS total_pagar,
	SMALLINT		AS num_plazo,
	DECIMAL(18,2)	AS pago_mensual,
	DECIMAL(18,2)	AS interes_iva,
	DECIMAL(18,2)	AS saldo_tdc,
	CHAR(16)		AS folio_promo,
	SMALLINT		AS Num_promocion;
	
	---DECLARACIONES
    DEFINE iSqlErr				INTEGER;
    DEFINE iIsamErr				INTEGER;
    DEFINE cErrorInfo			CHAR(80);
    DEFINE cCodRet				CHAR(5);
    DEFINE cMensajeRet			CHAR(80);
	DEFINE sNumPagos			SMALLINT;
	DEFINE dTasaAnual			DECIMAL(18,6);
	DEFINE dTasaAnualIva		DECIMAL(18,6);
	DEFINE dFactorIvaSucursal	DECIMAL(5,3);
	DEFINE dPagoMensual			DECIMAL(18,6);
	DEFINE dPagoPorPlazo		DECIMAL(18,6);
	DEFINE dInterIvaPlazoMax	DECIMAL(18,6);
	DEFINE dValorMinDiferir		DECIMAL(18,6);
	DEFINE dMontoDiferir		DECIMAL(18,6);
	DEFINE dTotalPagar			DECIMAL(18,6);
	DEFINE vcNumCte				VARCHAR(20);
	DEFINE cCodRetGF			CHAR(6);
	DEFINE cFolioSucGF			CHAR(16);
	DEFINE vcNomEjecutivo		VARCHAR(45);
	DEFINE vcNomPromocion		VARCHAR(50);
	DEFINE dSaldoTDC			DECIMAL(18,2);
	DEFINE cFolioPromo			CHAR(16);
	DEFINE dtFechaHoy			DATE;
	DEFINE dtFechaCorte			DATE;
	DEFINE dMontoPromo			DECIMAL(18,2);
	DEFINE cCodRetGenMov	  CHAR(10);
	DEFINE cMsjeGenMov		  CHAR(80);
    DEFINE vsucorig           CHAR(4);
	---VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE sp_consulta_saldos_general
	DEFINE cCsg_codigo_ret			CHAR(6);
	DEFINE dCsg_cap_vig				DECIMAL(18,2);	
	DEFINE dCsg_tot_liquidacion		DECIMAL(18,2);	
	DEFINE dCsg_linea_disp			DECIMAL(18,2);
    DEFINE vcompras                 SMALLINT;
	DEFINE dMontoDiferir_aux	    DECIMAL(18,6);
    DEFINE vdivisa                  CHAR(2);
    DEFINE v_dv                     CHAR(2);
    DEFINE v_tipocambio             DECIMAL(14,6);
    -- VARIABLES PARA OBTENER RESPUESTA DEL SP: sp_proyecta_prest_credisol
    DEFINE c_CodigoRet_pp           CHAR(6);
    DEFINE i_Periodo_pp             INTEGER;
    DEFINE d_FechaCouta_pp          DATE;
    DEFINE dd_SaldoInicial_pp       DECIMAL(18,2);
    DEFINE dd_Mensualidad_pp        DECIMAL(18,2);
    DEFINE dd_Mensualidad_aux_pp    DECIMAL(18,2);
    DEFINE dd_Intereses_pp          DECIMAL(18,2);
    DEFINE dd_IvaInteres_pp         DECIMAL(18,2);
    DEFINE dd_Capital_pp            DECIMAL(18,2);
    DEFINE dd_SaldoFinal_pp         DECIMAL(18,2);
    DEFINE dd_SaldoFinal_aux_pp     DECIMAL(18,2);
    DEFINE s_DiasPeriodo_pp         SMALLINT;
    DEFINE d_FechaAper_pp           DATE;
    DEFINE c_NumMesesPago_pp        CHAR(3);
    DEFINE i_Cont                   SMALLINT;
    DEFINE v_NumCredito             CHAR(20);
	DEFINE sCountExists				INTEGER;
	DEFINE sYield					INTEGER;	
	DEFINE cBandera268				CHAR(1);
	

	---INICIALIZACIONES
	LET iSqlErr				= 0;
	LET iIsamErr			= 0;
	LET cErrorInfo			= '';
	LET cCodRet				= '00000';
	LET cMensajeRet			= 'PROCESO EXITOSO';
	LET sNumPagos			= 0;
	LET dTasaAnual			= 0.0;
	LET dTasaAnualIva		= 0.0;
	LET dFactorIvaSucursal	= 0.0;
	LET dPagoMensual		= 0.0;
	LET dPagoPorPlazo		= 0.0;
	LET dInterIvaPlazoMax	= 0.0;
	LET dValorMinDiferir	= 0.0;
	LET dMontoDiferir		= 0.0;
	LET dTotalPagar			= 0.0;
	LET vcNumCte			= '';
	LET cCodRetGF			= '000000';
	LET cFolioSucGF			= '';
	LET vcNomEjecutivo		= '';
	LET vcNomPromocion		= '';
	LET dSaldoTDC			= 0.0;
	LET cFolioPromo			= '';
	LET dtFechaHoy			= DATE(1);
	LET dtFechaCorte		= DATE(1);
	LET dMontoPromo			= 0.0;
	LET cCodRetGenMov		= "";
	LET cMsjeGenMov		    = "";
	---VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE sp_consulta_saldos_general
	LET cCsg_codigo_ret				= "000000";
	LET dCsg_cap_vig				= 0.0;		
	LET dCsg_tot_liquidacion		= 0.0;
	LET dCsg_linea_disp				= 0.0;
    LET vcompras                    = 0;
	LET dMontoDiferir_aux	        = 0;
    LET vdivisa                     = '00';
    LET v_dv                        = "00";
    LET v_tipocambio                = 0;
    LET vsucorig                    = "";
    -- VARIABLES PARA OBTENER RESPUESTA DEL SP: sp_proyecta_prest_credisol
    LET c_CodigoRet_pp              = '';
    LET i_Periodo_pp                = 0;
    LET d_FechaCouta_pp             = MDY(1,1,1900);
    LET dd_SaldoInicial_pp          = 0.0;
    LET dd_Mensualidad_pp           = 0.0;
    LET dd_Mensualidad_aux_pp       = 0.0;
    LET dd_Intereses_pp             = 0.0;
    LET dd_IvaInteres_pp            = 0.0;
    LET dd_Capital_pp               = 0.0;
    LET dd_SaldoFinal_pp            = 0.0;
    LET dd_SaldoFinal_aux_pp        = 0.0;
    LET s_DiasPeriodo_pp            = 0;
    LET d_FechaAper_pp              = MDY(1,1,1900);
    LET c_NumMesesPago_pp           = '';
    LET i_Cont                      = 0;
    LET v_NumCredito                ='';
	LET sCountExists				= 0;
	LET sYield						= 0;
	LET cBandera268					= '0';


BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			LET cMensajeRet = cErrorInfo;
			RETURN cCodRet, cMensajeRet, NVL(dTotalPagar,0), NVL(pPlazo,0), NVL(dPagoMensual,0), NVL(dInterIvaPlazoMax,0), NVL(dSaldoTDC,0), NVL(cFolioPromo,''), NVL(pNumPromocion,0);
       END IF;
    END EXCEPTION;
	
	ON EXCEPTION IN (-268) SET iSqlErr, iIsamErr, cErrorInfo
		IF cBandera268 = '1' THEN  -- El error es por insertar en la tabla sd_promocion_credito
			SELECT
				year(current) || lpad(month(current),2,0) || lpad(day(current),2,0)
				|| substr(DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND,1,2)
				||substr(DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND,4,2)
				||substr(DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND,7,2)
				||lpad(bdicheq:sp_random(),2,'0'), sysmaster:yieldn( 1 )
			  INTO cFolioSucGF, sYield FROM sysmaster:sysshmvals;

			--SET DEBUG FILE TO '/informix/mahr/sp_proy_pfsms.out';
			--TRACE ON;
			LET cFolioPromo = cFolioSucGF;
			LET cCodRet = '00000';
			LET cMensajeRet = '';
		
			INSERT INTO "informix".sd_promocion_credito
				(empresa,sistema,num_promo,fecha,ejecutivo,num_cte,num_credito,num_tarjeta,plazo,folio_suc,monto_actual,monto_int_iva,mensualidad,status,nombre_promo,sucursal,num_sol_prestamo,num_pro_prestamo,folio_movto)
			VALUES ('001','06',pNumPromocion,dtFechaHoy,pEjecutivo,vcNumCte, pNumCredito,pNumTarjeta,pPlazo,cFolioSucGF,pMonto,dInterIvaPlazoMax,dPagoMensual,0,vcNomPromocion,pSucursal,'','6900',pFolioMovto);
	  
	  ELSE
			RETURN cCodRet, cMensajeRet, NVL(dTotalPagar,0), NVL(pPlazo,0), NVL(dPagoMensual,0), NVL(dInterIvaPlazoMax,0), NVL(dSaldoTDC,0), NVL(cFolioPromo,''), NVL(pNumPromocion,0);	  
	  END IF;
	END EXCEPTION WITH RESUME;
   

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    --SET DEBUG FILE TO '/tmp/sp_msi_proyecta_msi.out';
	--TRACE ON;
	  
	-- Obtiene la fecha del dia de hoy.
	SELECT fecha_hoy INTO dtFechaHoy FROM "informix".sd_fechas WHERE empresa = '001';	  

	-- Obtiene valores de tipos de cambio
	SELECT valor INTO v_dv FROM bdinteg:si_param WHERE cod_param = 17;
    SELECT precio_venta INTO v_tipocambio FROM bdinteg:"informix".si_tpcambio
	 WHERE empresa = "001" AND divisa = v_dv AND clase_tpcambio = "O" AND fecha_tpcambio = (SELECT MAX(fecha_tpcambio) FROM bdinteg:"informix".si_tpcambio
																						     WHERE empresa = "001" AND divisa = v_dv);

	-- Valida que los parametros no vengan vacios
    IF pTipo IS NULL OR NVL(pSucursal,'') = '' OR NVL(pEjecutivo,'') = '' OR pNumPromocion IS NULL
			OR (NVL(pNumCredito,'') = '' AND NVL(pNumTarjeta,'') = '') OR (pTipo = 1 AND pMonto IS NULL)
			OR (pTipo = 2 AND pMonto IS NULL) OR (pTipo = 3 AND NVL(pMonto,0) = 0)
			OR (pTipo = 1 AND pPlazo IS NULL) OR (pTipo = 2 AND pPlazo IS NULL )
			OR (pTipo = 3 AND NVL(pPlazo,0) = 0) THEN
		LET cCodRet = '00432';
		LET cMensajeRet = 'FALTA UNO O MAS PARAMETROS';
    END IF;
	
	-- Valida tipo de ejecucion
	IF cCodRet = '00000' AND pTipo NOT IN (1,2,3) THEN
		LET cCodRet = '00434';
		LET cMensajeRet = 'EL PARAMETRO TIPO NO ES VALIDO';
	END IF;
	
	-- Valida el ejecutivo y obtiene su nombre.
	/*IF cCodRet = '00000' THEN
		SELECT nombre INTO vcNomEjecutivo 
		  FROM bdinteg:"informix".si_ejecut WHERE ejecutivo = pEjecutivo;
		IF NVL(vcNomEjecutivo,'') = '' THEN
			LET cCodRet = '00435';
			LET cMensajeRet = 'CODIGO DE EJECUTIVO NO ES VALIDO';
		END IF;
	END IF;*/

	/*
	-- Obtiene Valor de monto minimo a diferrir 
	IF cCodRet = '00000' THEN	
		SELECT TRIM(valor)::DECIMAL(18,2) INTO dValorMinDiferir				-- ???? PENDIENTE
		  FROM "informix".sd_param WHERE cod_param  = '029';
		IF dValorMinDiferir IS NULL THEN
			LET cCodRet = '00437';
			LET cMensajeRet = 'ERROR AL OBTENER EL PARAMETRO DEL VALOR MINIMO A DIFERIR';
		END IF;
	END IF;
	*/

	-- Proyeccion Especial (X tasa, X plazo)
	LET sCountExists = 0;
	
	-- Valida que al menos reciba el numero de credito o la tarjeta validos
    IF cCodRet = '00000' AND (NVL(pNumCredito,'') = '' OR NVL(pNumTarjeta,'') = '' ) THEN
		IF NVL(pNumCredito,'') <> '' THEN
            SELECT num_credito, numcte  , divisa , sucursal
			  INTO pNumCredito, vcNumCte, vdivisa, vsucorig
			  FROM bdicred:"informix".sd_maecred 
		     WHERE empresa = '001' AND num_credito = pNumCredito;
             --AND status_cred = 'AA';

            IF NVL(pNumCredito,'') = '' THEN
                LET cCodRet = '00439';
				LET cMensajeRet = 'NUMERO DE CREDITO NO ES VALIDO';
			END IF
        ELIF NVL(pNumTarjeta,'') <> '' THEN

            SELECT a.num_tarjeta, b.num_credito, a.numcte, b.divisa,sucursal
		  	  INTO pNumTarjeta, pNumCredito, vcNumCte,vdivisa,vsucorig
			  FROM "informix".sd_tarjeta a, "informix".sd_maecred b
			 WHERE a.empresa = b.empresa
               AND a.num_credito = b.num_credito
               AND a.num_tarjeta = pNumTarjeta
               AND a.tipo_tarjeta = 'T'
               AND a.status_tar IN ('A', 'I');
               --AND b.status_cred = 'AA';

            IF NVL(pNumTarjeta,'') = '' THEN
                LET cCodRet = '00440';
				LET cMensajeRet = 'NUMERO DE TARJETA NO ES VALIDO O SU CREDITO NO ES VALIDO';
			END IF;
		END IF;
	END IF;

    -- Valida el numero de promocion
    IF cCodRet = '00000' THEN
        SELECT nombre_promo INTO vcNomPromocion FROM "informix".sd_promocion WHERE num_promo = pNumPromocion;
        IF NVL(vcNomPromocion,'') = '' THEN
            LET cCodRet = '00436';
            LET cMensajeRet = 'EL PARAMETRO NUMERO DE PROMOCION NO ES VALIDO';
        END IF;
    END IF;

	--	Obtiene saldos del credito
    IF cCodRet = '00000' THEN
			
		SELECT sdo_capital,  (monto_otorgado - (sdo_cap_insoluto + sdo_retenido)), (sdo_cap_insoluto + sdo_retenido) 
		  INTO dCsg_cap_vig, dCsg_linea_disp,									   dCsg_tot_liquidacion
		  FROM bdicred:sd_maesdos WHERE num_credito = pNumCredito;			
		LET cCsg_codigo_ret = '000000';

		IF cCsg_codigo_ret::INTEGER <> 0 THEN
            LET cCodRet = '00441';
			LET cMensajeRet = 'OCURRIO UN ERROR LA CONSULTA DE SALDOS';
		ELSE
			IF pTipo = 1 THEN
				IF pPlazo = 0 THEN LET sNumPagos = 0; ELSE LET sNumPagos = pPlazo; END IF;
				LET sNumPagos = pPlazo;
                IF NVL(sNumPagos,0) = 0 THEN
					LET cCodRet = '00443';
					LET cMensajeRet = 'EL PLAZO NO ES VALIDO PARA LA PROMOCION';
				END IF;
			END IF;

				
            IF cCodRet = '00000' THEN
				LET dTasaAnual = pTasa;
					
				-- Valida que la sucursal exista y ademas obtiene el iva
				SELECT iva INTO dFactorIvaSucursal FROM bdinteg:"informix".si_sucursales WHERE sucursal = pSucursal;
				IF cCodRet = '00000' AND NVL(dFactorIvaSucursal,0.0) = 0.0 THEN
					LET cCodRet = '00444';
					LET cMensajeRet = 'SUCURSAL NO EXISTE O FALTA FACTOR DE IVA DE SUCURSAL';
				END IF;

				-- Calcula la tasa con iva
				LET dTasaAnualIva = (dTasaAnual/100) * (1 + dFactorIvaSucursal);
				IF cCodRet = '00000' THEN

					--ELIF pNumPromocion in (2, 5, 8 )THEN
                    IF pTipo = 1 THEN
						IF DAY(dtFechaHoy) > 20 THEN
							LET dtFechaCorte = MDY(MONTH(dtFechaHoy),20,YEAR(dtFechaHoy));
						ELSE
							EXECUTE PROCEDURE bdicred:"informix".monthadd(dtFechaHoy, -1) INTO dtFechaCorte;
							LET dtFechaCorte = MDY(MONTH(dtFechaCorte),20,YEAR(dtFechaCorte));
						END IF;
                        LET dtFechaCorte = dtFechaCorte + 1;

						IF NVL(dMontoDiferir,0) = 0 THEN
							-- Obtiene el monto maximo de las compras de creditos en los movimientos historicos
							LET sCountExists = 0;  -- Valida si busca en movdia o en movhis. sCountExists = 1 ==> Existe en movdia 
							FOREACH
								SELECT {AVOID_FULL("informix".sd_movdia)} nvl(monto,0) INTO dMontoDiferir_aux
								  FROM "informix".sd_movdia a 
								  JOIN bdinteg:"informix".si_transacc b ON (a.empresa = b.empresa and a.num_credito = pNumCredito and a.empresa = '001') 
								 WHERE a.num_credito = pNumCredito
								   AND a.fecha_mov = dtFechaHoy
								   AND a.codigo_ref IN (37,57)
								   AND a.folio_suc = pFolioMovto
								   AND a.reversado = 'N'
								   AND a.transacc_suc = b.numero
								   AND b.naturaleza = 'C'
								   AND b.sistema = '06'
							   
								IF dMontoDiferir_aux = 0 THEN
									LET dPagoMensual = 0;			LET dPagoPorPlazo = 0;			LET dInterIvaPlazoMax = 0;
                                    LET dTotalPagar = 0;			LET dMontoDiferir_aux = 0;
                                    CONTINUE FOREACH;
									
								--ELIF dMontoDiferir_aux <> 0 AND dCsg_tot_liquidacion >= dMontoDiferir_aux THEN
								ELIF dMontoDiferir_aux <> 0 THEN
								
									LET i_Cont = 0;						LET dd_SaldoFinal_pp = 0;		LET pPlazo = pPlazo;
									LET v_NumCredito = pNumCredito;		LET sCountExists = 1;
											
									FOREACH
										EXECUTE PROCEDURE bdicred:"informix".sp_proyecta_prest_credisol(pMonto,pPlazo::INTEGER,0,'6900',pSucursal,1,0,v_NumCredito,null,1,pNumPromocion::INTEGER, '1', pTasa) 
										   INTO c_CodigoRet_pp, i_Periodo_pp, d_FechaCouta_pp, dd_SaldoInicial_pp, dd_Mensualidad_aux_pp, dd_Intereses_pp, dd_IvaInteres_pp, 
                                                dd_Capital_pp, dd_SaldoFinal_aux_pp, s_DiasPeriodo_pp, d_FechaAper_pp, c_NumMesesPago_pp

										IF c_CodigoRet_pp != '000000' THEN
											LET cMensajeRet = 'ERROR AL EJECUTAR sp_proyecta_prest_credisol';
											RETURN c_CodigoRet_pp, TRIM(cMensajeRet), NVL(dTotalPagar,0), NVL(pPlazo,0), NVL(dPagoMensual,0), NVL(dInterIvaPlazoMax,0), NVL(dSaldoTDC,0), TRIM(cFolioPromo), NVL(pNumPromocion,0);
										END IF;

                                        LET i_Cont = i_Cont + 1;
                                        IF i_Cont = 1 THEN
											LET dd_Mensualidad_pp = dd_Mensualidad_aux_pp;
                                        END IF;
										LET dd_SaldoFinal_pp = dd_SaldoFinal_pp + dd_Mensualidad_aux_pp;
									END FOREACH;

									LET dPagoMensual = dd_Mensualidad_pp;
									LET dPagoPorPlazo = dd_SaldoFinal_pp;
									LET dInterIvaPlazoMax = dPagoPorPlazo - dMontoDiferir_aux;
									LET dTotalPagar = dd_SaldoFinal_pp;

									IF dCsg_linea_disp > (dInterIvaPlazoMax) THEN
										LET dPagoMensual = 0;		LET dPagoPorPlazo = 0;		LET dInterIvaPlazoMax = 0;		LET dTotalPagar = 0;		LET vcompras = 1;
										LET dMontoDiferir = dMontoDiferir_aux;
									ELSE
										CONTINUE FOREACH;
									END IF;
								END IF;
							END FOREACH;
							IF sCountExists = 0 THEN -- Busca en movhis
								FOREACH
									SELECT nvl(monto,0) INTO dMontoDiferir_aux
									  FROM "informix".sd_movhis a, bdinteg:"informix".si_transacc b
									 WHERE a.empresa = b.empresa
									   --AND a.fecha_mov >= dtFechaCorte
									   --AND a.fecha_mov <= dtFechaHoy
									   AND a.transacc_suc = b.numero
									   AND a.num_credito = pNumCredito
									   AND folio_suc = pFolioMovto
									   AND b.naturaleza = 'C'
									   AND b.sistema = '06'
									   AND a.reversado = 'N'
									   --AND a.codigo_ref IN (31,51)
									   AND a.codigo_ref IN (37,57)
									   --AND a.monto >= dValorMinDiferir
											   
									IF dMontoDiferir_aux = 0 THEN
										LET dPagoMensual = 0;		LET dPagoPorPlazo = 0;		LET dInterIvaPlazoMax = 0;		LET dTotalPagar = 0;		LET dMontoDiferir_aux = 0;
										CONTINUE FOREACH;
									--ELIF dMontoDiferir_aux <> 0 AND dCsg_tot_liquidacion >= dMontoDiferir_aux THEN
									ELIF dMontoDiferir_aux <> 0 THEN
										LET i_Cont = 0;					LET dd_SaldoFinal_pp = 0;	LET pPlazo = pPlazo;
										LET v_NumCredito=pNumCredito;

										FOREACH
											EXECUTE PROCEDURE bdicred:"informix".sp_proyecta_prest_credisol(pMonto,pPlazo::INTEGER,0,'6900',pSucursal,1,0,v_NumCredito,null,1,pNumPromocion::INTEGER, '1', pTasa) INTO
												c_CodigoRet_pp, i_Periodo_pp, d_FechaCouta_pp, dd_SaldoInicial_pp, dd_Mensualidad_aux_pp, dd_Intereses_pp, dd_IvaInteres_pp, 
												dd_Capital_pp, dd_SaldoFinal_aux_pp, s_DiasPeriodo_pp, d_FechaAper_pp, c_NumMesesPago_pp

											IF c_CodigoRet_pp != '000000' THEN
												LET cMensajeRet = 'ERROR AL EJECUTAR sp_proyecta_prest_credisol';
												RETURN c_CodigoRet_pp, TRIM(cMensajeRet), NVL(dTotalPagar,0), NVL(pPlazo,0), NVL(dPagoMensual,0), NVL(dInterIvaPlazoMax,0), NVL(dSaldoTDC,0), TRIM(cFolioPromo), NVL(pNumPromocion,0);
											END IF;

											LET i_Cont = i_Cont + 1;
											IF i_Cont = 1 THEN
												LET dd_Mensualidad_pp = dd_Mensualidad_aux_pp;
											END IF;
											LET dd_SaldoFinal_pp = dd_SaldoFinal_pp + dd_Mensualidad_aux_pp;
										END FOREACH;

										LET dPagoMensual = dd_Mensualidad_pp;
										LET dPagoPorPlazo = dd_SaldoFinal_pp;
										LET dInterIvaPlazoMax = dPagoPorPlazo - dMontoDiferir_aux;
										LET dTotalPagar = dd_SaldoFinal_pp;

										IF dCsg_linea_disp > (dInterIvaPlazoMax) THEN
											LET dPagoMensual = 0;		LET dPagoPorPlazo = 0;		LET dInterIvaPlazoMax = 0;		LET dTotalPagar = 0;		LET vcompras = 1;
											LET dMontoDiferir = dMontoDiferir_aux;
										ELSE
											CONTINUE FOREACH;
										END IF;
									END IF;
								END FOREACH;
							END IF;
						END IF;

                    ELIF pTipo IN (2,3) THEN
						LET dMontoDiferir = pMonto;
					END IF;

					IF (vcompras = 0 AND NVL(dMontoDiferir,0) = 0) THEN
						LET cCodRet = '05433';
						LET cMensajeRet = 'EL CLIENTE NO ES VIABLE PARA DIFERIR ';
					ELSE
						-- Calcula el pago mensual
						LET i_Cont = 0;			LET dd_SaldoFinal_pp = 0;		LET pPlazo = pPlazo;		LET v_NumCredito=pNumCredito;
						FOREACH
							EXECUTE PROCEDURE bdicred:"informix".sp_proyecta_prest_credisol(pMonto,pPlazo::INTEGER,0,'6900',pSucursal,1,0,v_NumCredito,null,1,pNumPromocion::INTEGER, '1', pTasa) INTO
								c_CodigoRet_pp, i_Periodo_pp, d_FechaCouta_pp, dd_SaldoInicial_pp, dd_Mensualidad_aux_pp, dd_Intereses_pp, dd_IvaInteres_pp, 
								dd_Capital_pp, dd_SaldoFinal_aux_pp, s_DiasPeriodo_pp, d_FechaAper_pp, c_NumMesesPago_pp

							IF c_CodigoRet_pp != '000000' THEN
								LET cMensajeRet = 'ERROR AL EJECUTAR sp_proyecta_prest_credisol';
								RETURN c_CodigoRet_pp, TRIM(cMensajeRet), NVL(dTotalPagar,0), NVL(pPlazo,0), NVL(dPagoMensual,0), NVL(dInterIvaPlazoMax,0), NVL(dSaldoTDC,0), TRIM(cFolioPromo), NVL(pNumPromocion,0);
							END IF;

							LET i_Cont = i_Cont + 1;
							IF i_Cont = 1 THEN
								LET dd_Mensualidad_pp = dd_Mensualidad_aux_pp;
							END IF;
							LET dd_SaldoFinal_pp = dd_SaldoFinal_pp + dd_Mensualidad_aux_pp;
						END FOREACH;
						LET dPagoMensual = dd_Mensualidad_pp;
						-- Calcula el pago por plazo
						LET dPagoPorPlazo = dd_SaldoFinal_pp;
						-- Calcula el interes e iva a plazo maximo
						LET dInterIvaPlazoMax = dPagoPorPlazo - dMontoDiferir;
						LET dTotalPagar = dd_SaldoFinal_pp;
						-- Valida si la proyeccion es de tipo consulta

						IF cCodRet = '00000' AND pTipo = 1 THEN
							IF dCsg_linea_disp < (dInterIvaPlazoMax) THEN
								LET cCodRet = '06433';
								LET cMensajeRet = 'EL CLIENTE NO ES VIABLE PARA DIFERIR ';
							END IF
							LET dTotalPagar = dTotalPagar;
							LET sNumPagos = sNumPagos;
							LET dPagoMensual = dPagoMensual;
							LET dInterIvaPlazoMax = dInterIvaPlazoMax;
						-- Valida si la proyeccion es para retornar el desglose
						ELIF cCodRet = '00000' AND pTipo = 2 THEN
							-- Valida que si trae el folio del movimiento que se recibe cuando se manda a llamar el proceso desde el proceso nocturno
							IF NVL(pFolioMovto,"") <> "" THEN
								-- Obtiene el monto de los intereses retenidos de la promocion por medio del folio del movto
								SELECT SUM(monto_actual + monto_int_iva) INTO dMontoPromo
								  FROM  "informix".sd_promocion_credito  
								 WHERE status = 0 AND fecha = dtFechaHoy AND num_credito = pNumCredito AND num_promo = pNumPromocion AND folio_movto = pFolioMovto;
								LET dMontoPromo = NVL(dMontoPromo,0.0);
							END IF;
							--IF dCsg_linea_disp < 0 THEN
							IF dCsg_linea_disp < dInterIvaPlazoMax THEN
								LET cCodRet = '07433';
								LET cMensajeRet = 'EL CLIENTE NO ES VIABLE PARA DIFERIR ';
							END IF;
                            -- Valida si la proyeccion es para guardar el desglose en tabla
						ELIF cCodRet = '00000' AND pTipo = 3 THEN
							IF dCsg_linea_disp < dInterIvaPlazoMax THEN
								LET cCodRet = '08433';
								LET cMensajeRet = 'EL CLIENTE NO ES VIABLE PARA DIFERIR ';
							ELSE
								-- Proceso generico para generar un folio
								LET cCodRetGF = '000000';
								SELECT --pEjecutivo 
									year(current) || lpad(month(current),2,0) || lpad(day(current),2,0)
									|| substr(DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND,1,2)
									||substr(DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND,4,2)
									||substr(DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND,7,2)
									||lpad(bdicheq:sp_random(),2,'0')
								INTO cFolioSucGF 
								FROM sysmaster:sysshmvals;
								-------
								-- Valida folio no exista y lo recalcula si existe
								LET sCountExists = 0;  
								SELECT COUNT(folio_suc) INTO sCountExists FROM bdicred:"informix".sd_promocion_credito 
								 WHERE empresa = '001' AND folio_suc = cFolioSucGF;
								IF sCountExists > 0 THEN
									SELECT --pEjecutivo 
										year(current) || lpad(month(current),2,0) || lpad(day(current),2,0)
										|| substr(DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND,1,2)
										||substr(DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND,4,2)
										||substr(DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND,7,2)
										||lpad(bdicheq:sp_random(),2,'0'), sysmaster:yieldn( 1 )
									  INTO cFolioSucGF, sYield FROM sysmaster:sysshmvals;
								END IF;
								-------											
									
								IF cCodRetGF::INTEGER <> 0 THEN
									LET cCodRet = '00447';
									LET cMensajeRet = 'OCURRIO UN ERROR EN EL PROCESO QUE GENERA EL FOLIO';
									LET dTotalPagar = 0;		LET sNumPagos = 0;		LET dPagoMensual = 0;		LET dInterIvaPlazoMax = 0;
								ELSE
									LET cFolioPromo = cFolioSucGF;
									-- Guarda los datos de la promocion
									LET cBandera268 = '1';
									INSERT INTO "informix".sd_promocion_credito
									   (empresa,sistema,num_promo,fecha,ejecutivo,num_cte,num_credito,num_tarjeta,plazo,folio_suc,monto_actual,monto_int_iva,mensualidad,status,nombre_promo,sucursal,num_sol_prestamo,num_pro_prestamo,folio_movto)
										VALUES ('001','06',pNumPromocion,dtFechaHoy,pEjecutivo,vcNumCte, pNumCredito,pNumTarjeta,pPlazo,cFolioSucGF,pMonto,dInterIvaPlazoMax,dPagoMensual,0,vcNomPromocion,pSucursal,'','8900',pFolioMovto);
									LET cBandera268 = '0';
									-- Realiza el retenido por el monto de los intereses e iva para evitar sobregiro 
									INSERT INTO "informix".sd_maeretenido
									   (empresa,num_credito,folio_suc,fecha,hora,transacc,dias_ret,monto,usuario,estatus,referencia,sucursal,dias_ori)
									   VALUES('001',pNumCredito,cFolioSucGF,dtFechaHoy,CURRENT HOUR TO FRACTION(3),'6837',0,dInterIvaPlazoMax,pEjecutivo,'R',cFolioSucGF||' RET. MESES SIN INTERESES',pSucursal,0);
									-- Actualiza el saldo retenido en el maestro de saldos
									UPDATE "informix".sd_maesdos SET sdo_retenido = sdo_retenido + dInterIvaPlazoMax
									 WHERE num_credito = pNumCredito AND empresa = '001';
									-- Genera el movimiento del retenido de los intereses
									EXECUTE PROCEDURE "informix".genmov_tc('001',pNumCredito,'6001',dtFechaHoy,dInterIvaPlazoMax,cFolioSucGF,pSucursal,vdivisa,'6837','','RET. de INT. e Iva MSI',v_tipocambio,0,pEjecutivo,vsucorig,'','')
									INTO cCodRetGenMov, cMsjeGenMov;
								END IF;
							END IF;
						END IF;
					END IF;
				END IF;
			END IF;
		END IF;
	END IF;

    IF cCodRet <> '00000' THEN
        INSERT INTO "informix".sd_bitacora_promocion VALUES('001', pNumCredito, 'sp_msi_proyecta_msi', dtFechaHoy, CURRENT, pTipo, pNumPromocion, cCodRet);
    END IF;

	RETURN cCodRet, TRIM(cMensajeRet), NVL(dTotalPagar,0), NVL(pPlazo,0), NVL(dPagoMensual,0), NVL(dInterIvaPlazoMax,0), NVL(dSaldoTDC,0), TRIM(cFolioPromo), NVL(pNumPromocion,0);

END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Proceso para obtener el desglose de informacion de saldos del credito y validar si es viable el cliente para Meses sin intereses',
'MODIFICO: Martha A Hernandez Rodiguez',
'BD: bdicred';

CREATE PROCEDURE "informix".calcula_meses_fin(o_empresa CHAR(3),
											  o_producto CHAR(4),
											  o_saldo_no_exigible DECIMAL (18,2),
                                              o_monto_otorgado DECIMAL (18,2),
                                              o_tasa DECIMAL (9,4),
                                              o_iva DECIMAL(9,4),
                                              o_fecha_calculo date)

	RETURNING CHAR(5) AS retorno_error,
              INTEGER AS meses_fin;

	-- *********************************************************************
	-- *                        DEFINICION DE VARIABLES                    *
	-- *********************************************************************
	DEFINE scod_ret                	CHAR(5);
	DEFINE p_cod_ret               	CHAR(6);
	DEFINE vsqlerr                 	INTEGER;
	DEFINE wfecha_hoy              	DATE;
    DEFINE vFactorPagoMin           SMALLINT;
    DEFINE TopeMinimo               DECIMAL(14,2);
    DEFINE vFactorPagoMinLinC       DECIMAL (4,4);
    DEFINE wmeses_fin               INTEGER;
    DEFINE wbandera                 SMALLINT;
    DEFINE MontoFinanciado          DECIMAL(14,2);
    DEFINE wfinincimainto           DECIMAL(14,2);
    DEFINE wdias                    SMALLINT;
    DEFINE vFactorPorcentual        DECIMAL(18,2);

	-- ****************************************************************************
	-- *                        ASIGNACION DE VARIABLES                           *
	-- ****************************************************************************

--    SET DEBUG FILE TO "calcula_meses_fin.out"; 
--    TRACE ON;

	LET scod_ret                = "00000";
	LET p_cod_ret               = "000000";
	LET vsqlerr                 = 0;
	LET wfecha_hoy             = DATE(1);
    LET vFactorPagoMin           = 0;
    LET TopeMinimo               = 0;
    LET vFactorPagoMinLinC       = 0;
    LET wmeses_fin               = 0;
    LET wbandera                 = 0;
    LET MontoFinanciado          = 0;
    LET wfinincimainto           = 0;
    LET wdias                    = 0;
    LET vFactorPorcentual        = 0;

	-- ****************************************************************************
	-- *                        CONTROL DE ERRORES                                *
	-- ****************************************************************************

	BEGIN
		ON EXCEPTION SET vsqlerr
		   IF vsqlerr != 0 THEN
			  LET scod_ret=vsqlerr;
			  RETURN scod_ret, 0;
		   END IF;
		END EXCEPTION;

	-- ****************************************************************************
	-- *                        PROGRAMA PRINCIPAL                                *
	-- ****************************************************************************

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

        IF (o_saldo_no_exigible <= 0) THEN
            RETURN scod_ret, 0;
        END IF;

        SELECT factor_pago_min::SMALLINT, mto_pago_min::DECIMAL, fact_pag_min_lc 
          INTO vFactorPagoMin, TopeMinimo, vFactorPagoMinLinC 
          FROM bdicred:sd_definicion 
         WHERE empresa = o_empresa 
           and num_producto = o_producto;

        IF ( o_saldo_no_exigible <= TopeMinimo ) THEN
            RETURN scod_ret, 1; 
        END IF;

        WHILE wbandera = 0
            LET wmeses_fin = wmeses_fin + 1;
            LET vFactorPorcentual = vFactorPagoMin/100;
			
            LET MontoFinanciado = ROUND((o_saldo_no_exigible * vFactorPorcentual), -0);

            IF MontoFinanciado < ROUND((o_monto_otorgado * vFactorPagoMinLinC),-0) THEN 
                LET MontoFinanciado = ROUND((o_monto_otorgado * vFactorPagoMinLinC),-0); 
            END IF;

            IF ( MontoFinanciado < 0 ) THEN
                LET MontoFinanciado = 0;
            ELIF ( o_saldo_no_exigible < TopeMinimo ) THEN     
                IF ( o_saldo_no_exigible ) <= 0 THEN    
                    LET MontoFinanciado = 0;
                ELSE
                    LET MontoFinanciado = o_saldo_no_exigible;     
                END IF;
            ELIF ( MontoFinanciado < TopeMinimo ) THEN  
                LET MontoFinanciado = TopeMinimo;
            END IF

            IF ( o_saldo_no_exigible <= MontoFinanciado ) THEN   
                LET MontoFinanciado = o_saldo_no_exigible;   
                IF MontoFinanciado < 0 THEN
                    LET MontoFinanciado = 0;
                END IF;
            END IF;

            IF ( Round(MontoFinanciado,-1) - MontoFinanciado < 0 ) THEN
                LET MontoFinanciado = Round(MontoFinanciado,-1) + 10;
            ELSE
                LET MontoFinanciado = Round(MontoFinanciado,-1);
            END IF;


            IF ( MontoFinanciado > o_saldo_no_exigible ) THEN
                LET MontoFinanciado = o_saldo_no_exigible;
            END IF;

            LET wdias = monthadd(o_fecha_calculo,wmeses_fin) - monthadd(o_fecha_calculo,wmeses_fin - 1);

            -- Calcula financiamiento
            LET wfinincimainto = ((o_saldo_no_exigible * o_tasa / 360 * wdias) * (1 + o_iva));

            LET o_saldo_no_exigible = o_saldo_no_exigible - MontoFinanciado + wfinincimainto;
            
            IF ( o_saldo_no_exigible <= TopeMinimo ) THEN
                LET wmeses_fin = wmeses_fin + 1;
                LET wbandera = 1;
            END IF;
        END WHILE;
        

        RETURN scod_ret, wmeses_fin;
    END;
END PROCEDURE;
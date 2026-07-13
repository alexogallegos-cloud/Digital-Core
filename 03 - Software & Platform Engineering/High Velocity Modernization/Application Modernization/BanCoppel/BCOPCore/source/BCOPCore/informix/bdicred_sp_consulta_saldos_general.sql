CREATE PROCEDURE "informix".sp_consulta_saldos_general(pEmpresa CHAR(3), pNumCredito CHAR(20))
RETURNING  
    CHAR(6) AS codigo_retorno,
    CHAR(80) AS mensaje_retorno,
    CHAR(20) AS numero_credito,
    CHAR(2) AS codigo_tipcred,
    DATE AS fecha_origen,
    DATE AS fecha_prox_pago,
    DECIMAL(18,2) AS pago_minimo,
    DATE AS fecha_ult_pago,
    INTEGER AS plazo,
    INTEGER AS pagos_realizados,
    DECIMAL(18,2) AS linea_otorgada,
    DECIMAL(9,6) AS tasa_interes,
    DECIMAL(9,6) AS tasa_moratorios,
    DECIMAL(14,2) AS monto_sbc,
    DECIMAL(18,2) AS cap_vig,
    DECIMAL(18,2) AS cap_trans,
    DECIMAL(18,2) AS cap_vdo_exig,
    DECIMAL(18,2) AS cap_vdo_no_exig,
    DECIMAL(18,2) AS sdo_act_total_cap,
    DECIMAL(18,2) AS int_vig,
    DECIMAL(18,2) AS int_vdo,
    DECIMAL(18,2) AS int_moratorios,
    DECIMAL(18,2) AS int_mes,
    DECIMAL(18,2) AS sdo_act_total_int,
    DECIMAL(18,2) AS iva_int_vig,
    DECIMAL(18,2) AS iva_int_vdo,
    DECIMAL(18,2) AS iva_int_moratorios,
    DECIMAL(18,2) AS iva_int_mes,
    DECIMAL(18,2) AS sdo_act_total_iva,
    DECIMAL(18,2) AS com_pend,
    DECIMAL(18,2) AS iva_com,
    DECIMAL(18,2) AS sdo_retenido,
    DECIMAL(18,2) AS total_liquidacion,
    DECIMAL(18,2) AS int_devengado,
    DECIMAL(18,2) AS iva_int_devengado,
    DECIMAL(18,2) AS linea_disponible,
    DECIMAL(18,2) AS pagos_vdos,
    CHAR(60) AS desc_status_cred,
    INTEGER AS id_bloqueo_cred,
    CHAR(60) AS bloqueo_cta,
    CHAR(3) AS id_causa_bloqueo_cred,
    CHAR(50) AS causa_bloqueo_cta,
    CHAR(1) AS id_sit_esp_cte,
    INTEGER AS id_causa_esp_cte,
    CHAR(75) AS sit_esp_cte,
    CHAR(1) AS id_sit_esp_cred,
    INTEGER AS id_causa_esp_cred,
    CHAR(75) AS sit_esp_cred;
    -----------------------------------------------------------------------------------------------------------
    -- Fecha: 12/10/2009                                                                                     --
    -- Autor: Roque Enrique Solis CampaÃÂÃÂÃÂÃÂ±a                                                                    --
    --Modificacion: Se agregaron las consultas para saldos de prestamos personales                           --
    -----------------------------------------------------------------------------------------------------------
    -- Fecha: 20/10/2009                                                                                     --
    -- Autor: Roque Enrique Solis CampaÃÂÃÂÃÂÃÂ±a                                                                    --
    --Modificacion: Se agrego el calculo de la comision para prestamo personal                               --
    --            se sumo al monto total de liquidacion la comision y el iva de comision                     --
    -----------------------------------------------------------------------------------------------------------
    -----------------------------------------------------------------------------------------------------------
    -- Fecha: 22/12/2009                                                                                     --
    -- Autor: Paul ivan quintero varela                                                                      --
    -- Modificacion: Se modifica para contemplar el calculo del iva de interes real                          --
    --               o iva de interes devengado                                                              --
    -----------------------------------------------------------------------------------------------------------
    -----------------------------------------------------------------------------------------------------------
    -- Fecha: 30/11/2011                                                                                     --
    -- Autor: Diego Guera Atienzo                                                                            --
    -- Modificacion: Se modifica mÃÂÃÂÃÂÃÂ©todo para calcular el IVA moratorio en prÃÂÃÂÃÂÃÂ©stamos personales y             --
    --				 reestructuras                                                                           --
    -----------------------------------------------------------------------------------------------------------

    DEFINE nrows INTEGER;
    DEFINE iSqlErr INTEGER;
    DEFINE iIsamErr INTEGER;
    DEFINE cErrorInfo CHAR(80);
    DEFINE cCodRet CHAR(6);
    DEFINE cMensajeRet CHAR(80);    
    DEFINE cEmpresa CHAR(3);
    DEFINE cNumCte CHAR(20);
    DEFINE cNumCredito CHAR(20);
	DEFINE cNumCreditoAux CHAR(20);
    DEFINE cCodTipCred CHAR(2);
    DEFINE cNumTarjeta CHAR(20);
    DEFINE cDescStatusCred CHAR(60);    
    DEFINE cSucursal CHAR(4);
    DEFINE iIdUnidadProd INTEGER;
    DEFINE cCodCaract2 CHAR(3);
    DEFINE dMontoFinanciado DECIMAL(18,2);
    DEFINE dIvaSuc DECIMAL(5,3);    
    DEFINE dtFechaOrigen DATE;
    DEFINE dtFechaProxPago DATE;
    DEFINE dPagoMinimo DECIMAL(18,2);
    DEFINE dtFechaUltPago DATE;
    DEFINE iPlazo INTEGER;
    DEFINE iPagosRealizados INTEGER;
    DEFINE dLineaOtorgada DECIMAL(18,2);    
    DEFINE dTasaInteres DECIMAL(9,6);
    DEFINE dTasaMoratorios DECIMAL(9,6);
    DEFINE dMontoSBC DECIMAL(14,2);    
    DEFINE dCapVig DECIMAL(18,2);
    DEFINE dCapTrans DECIMAL(18,2);
    DEFINE dCapVdoExig DECIMAL(18,2);
    DEFINE dCapVdoNoExig DECIMAL(18,2);
    DEFINE dSdoActCap DECIMAL(18,2);    
    DEFINE dIntVig DECIMAL(18,2);
    DEFINE dIntVdo DECIMAL(18,2);
    DEFINE dIntMoratorio DECIMAL(18,2);
    DEFINE dIntMoratorio_d DECIMAL(18,2);
    DEFINE dIntMes DECIMAL(18,2);
    DEFINE dSdoActInt DECIMAL(18,2);    
    DEFINE dIvaIntVig DECIMAL(18,2);
    DEFINE dIvaIntVdo DECIMAL(18,2);
    DEFINE dIvaIntMoratorio DECIMAL(18,2);
    DEFINE dIvaIntMes DECIMAL(18,2);
    DEFINE dSdoActIvaInt DECIMAL(18,2);    
    DEFINE dComPend DECIMAL(18,2);
    DEFINE dIvaCom DECIMAL(18,2);
    DEFINE dSdoRetenido DECIMAL(18,2);
    DEFINE dSdoTotalLiq DECIMAL(18,2);    
    DEFINE dtIvaFechaPag DATE;
    DEFINE dtFechaCuota DATE;
    DEFINE dIntDevengado DECIMAL(18,2);
    DEFINE dIvaIntDevengado DECIMAL(18,2);
    DEFINE dLineaDisponible DECIMAL(18,2);
    DEFINE dPagosVdos DECIMAL(18,2);
    DEFINE cDescBloqueoCta CHAR(60);
    DEFINE cDescCausaBloqueoCta CHAR(50);
    DEFINE cSitCte CHAR(1);
    DEFINE cCausaCte INTEGER;
    DEFINE cDescSitEspCte CHAR(75);
    DEFINE cSitCred CHAR(1);
    DEFINE cCausaCred INTEGER;
    DEFINE cDescSitEspCred CHAR(75);
    DEFINE dFactorComision DECIMAL(18,2);
    DEFINE dtMesiversario DATE;
    DEFINE dtFechaHoy DATE;
    DEFINE cTipCred CHAR(2);
    DEFINE cind_comision CHAR(1);
    DEFINE ctran_comision CHAR(4);
    DEFINE vRetCs_acum DECIMAL(18,2);    
    DEFINE vvcodigo_retorno CHAR(6);
    DEFINE vvmensaje_retorno CHAR(80);
    DEFINE vRespaldo smallint;

    LET iSqlErr = 0;
    LET iIsamErr = 0;
    LET cErrorInfo = '';
    LET cCodRet = '';
    LET cMensajeRet = '';    
    LET cEmpresa = '';
    LET cNumCte = '';
    LET cNumCredito = '';
	LET cNumCreditoAux = '';
    LET cCodTipCred = '';
    LET cNumTarjeta = '';
    LET cDescStatusCred = '';    
    LET cSucursal = '';
    LET iIdUnidadProd = 0;
    LET cCodCaract2 = '';
    LET dMontoFinanciado = 0;
    LET dIvaSuc = 0;    
    LET dtFechaOrigen = DATE(1);
    LET dtFechaProxPago = DATE(1);
    LET dPagoMinimo = 0;
    LET dtFechaUltPago = DATE(1);
    LET iPlazo = 0;
    LET iPagosRealizados = 0;
    LET dLineaOtorgada = 0;    
    LET dTasaInteres = 0;
    LET dTasaMoratorios = 0;
    LET dMontoSBC = 0;    
    LET dCapVig = 0;
    LET dCapTrans = 0;
    LET dCapVdoExig = 0;
    LET dCapVdoNoExig = 0;
    LET dSdoActCap = 0;    
    LET dIntVig = 0;
    LET dIntVdo = 0;
    LET dIntMoratorio = 0;
    LET dIntMoratorio_d = 0;
    LET dIntMes = 0;
    LET dSdoActInt = 0;    
    LET dIvaIntVig = 0;
    LET dIvaIntVdo = 0;
    LET dIvaIntMoratorio = 0;
    LET dIvaIntMes = 0;
    LET dSdoActIvaInt = 0;    
    LET dComPend = 0;
    LET dIvaCom = 0;
    LET dSdoRetenido = 0;
    LET dSdoTotalLiq = 0;    
    LET dtIvaFechaPag = DATE(1);
    LET dtFechaCuota = DATE(1);
    LET dIntDevengado = 0;
    LET dIvaIntDevengado = 0;
    LET dLineaDisponible = 0;
    LET dPagosVdos = 0;    
    LET cDescBloqueoCta = '';
    LET cDescCausaBloqueoCta = '';
    LET cSitCte = '';
    LET cCausaCte = 0;
    LET cDescSitEspCte = '';
    LET cSitCred = '';
    LET cCausaCred = 0;
    LET cDescSitEspCred = '';
    LET dFactorComision = 0;
    LET dtMesiversario = DATE(1);
    LET dtFechaHoy = DATE(1);
    LET cTipCred = '';
    LET cind_comision = '';
    LET ctran_comision = '';
    LET vRetCs_acum = 0;
    LET vvcodigo_retorno  = '';
    LET vvmensaje_retorno = '';
    LET vRespaldo = 0;

    BEGIN
    
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
        IF iSqlErr != 0 THEN
            LET cCodRet = iSqlErr;
            LET cMensajeRet = 'Ocurrio error al consultar los saldos'||' - '||cErrorInfo;
            RETURN cCodRet, cMensajeRet, cNumCredito, NVL(cCodTipCred,''),NVL(dtFechaOrigen,DATE(1)), NVL(dtFechaProxPago,DATE(1)), NVL(dPagoMinimo,0), NVL(dtFechaUltPago,DATE(1)), NVL(iPlazo,0), NVL(iPagosRealizados,0), NVL(dLineaOtorgada,0), NVL(dTasaInteres,0), NVL(dTasaMoratorios,0), NVL(dMontoSBC,0), NVL(dCapVig,0), NVL(dCapTrans,0), NVL(dCapVdoExig,0), NVL(dCapVdoNoExig,0), NVL(dSdoActCap,0), NVL(dIntVig,0), NVL(dIntVdo,0), NVL(dIntMoratorio,0), NVL(dIntMes,0), NVL(dSdoActInt,0), NVL(dIvaIntVig,0), NVL(dIvaIntVdo,0), NVL(dIvaIntMoratorio,0), NVL(dIvaIntMes,0), NVL(dSdoActIvaInt,0), NVL(dComPend,0), NVL(dIvaCom,0), NVL(dSdoRetenido,0), NVL(dSdoTotalLiq,0), NVL(dIntDevengado,0),NVL(dIvaIntDevengado,0), NVL(dLineaDisponible,0), NVL(dPagosVdos,0), NVL(cDescStatusCred,''), NVL(iIdUnidadProd,0), NVL(TRIM(cDescBloqueoCta),''), NVL(cCodCaract2,''), NVL(TRIM(cDescCausaBloqueoCta),''), NVL(cSitCte,''), NVL(cCausaCte,0), NVL(TRIM(cDescSitEspCte),''), NVL(cSitCred,''), NVL(cCausaCred,0), NVL(TRIM(cDescSitEspCred),'');
        END IF;
    END EXCEPTION;

	SET LOCK MODE TO WAIT 3;
    SET ISOLATION TO dirty READ;
	
    --SET DEBUG FILE TO '/resplogifx/archivoscartera/sp_consulta_saldos_general.out';
    --TRACE ON;
	
    LET cCodRet = '000000';
    LET cMensajeRet  = 'Se realizo la consulta correctamente.';
	
	LET pEmpresa = NVL(TRIM(pEmpresa),'');	
	LET pNumCredito = NVL(TRIM(pNumCredito),'');
	
    IF pEmpresa = '' THEN
        LET pEmpresa = NULL;
        LET cEmpresa= '';
	ELSE
		LET cEmpresa= TRIM(pEmpresa);	
    END IF;
    
    IF pNumCredito = '' THEN
        LET pNumCredito = NULL;
        LET cNumCredito= '';
	ELSE
		LET cNumCredito = TRIM(pNumCredito);
    END IF;

    IF pEmpresa IS NULL AND pNumCredito IS NULL THEN
        LET cCodRet = '000001';
        LET cMensajeRet = 'No hay informacion para realizar la consulta';
	ELSE
        SELECT fecha_hoy 
		INTO dtFechaHoy 
		FROM bdicred:"informix".sd_fechas 
		WHERE empresa = pEmpresa;  
		
		IF  pNumCredito matches '68*' then --RQM 10 1155
			Select fecha_proceso  INTO dtFechaHoy --Fecha proceso credito
			FROM bdicred:"informix".sd_maecredanexocrd 
			WHERE empresa = pEmpresa
			AND num_credito = pNumCredito;
		END IF;
		
        SELECT b.cod_prod 
		INTO cTipCred 
		FROM bdicred:"informix".sd_maecred a, bdicred:"informix".sd_tipprod b 
		WHERE a.num_credito = cNumCredito AND a.empresa = pEmpresa AND a.empresa = b.empresa AND a.num_producto=b.abrevia_prod;

        IF cTipCred IS NULL THEN
            SELECT b.cod_prod 
            INTO cTipCred 
            FROM bdicred:"informix".sd_maecred_old a, bdicred:"informix".sd_tipprod b 
            WHERE a.num_credito = cNumCredito AND a.empresa = pEmpresa AND a.empresa = b.empresa AND a.num_producto=b.abrevia_prod;
            IF cTipCred IS NOT NULL THEN
                LET vRespaldo = 1;
            END IF;
        END IF;

        IF cTipCred IS NULL THEN
            SELECT b.cod_prod 
			INTO cTipCred 
			FROM bdicred:"informix".sd_maecredcrd a, bdicred:"informix".sd_tipprod b 
			WHERE a.num_credito = cNumCredito AND a.empresa=pEmpresa AND a.empresa=b.empresa AND a.num_producto=b.abrevia_prod; 
            IF cTipCred IS NULL THEN
                LET cCodRet = '000002';
                LET cMensajeRet= 'No hay informacion para realizar la consulta';
            END IF;		
        END IF;
		
		IF cCodRet = '000000' THEN
            IF cTipCred = 'T' THEN
                IF SUBSTR(cNumCredito,1,2) = "78" THEN		
                    IF vRespaldo = 0 THEN
                        SELECT a.numcte, a.sucursal, a.plazo, a.fecha_apertura, NVL(a.tasa_interes,0), (NVL(a.tasa_moratorios,0) - NVL(a.tasa_interes,0)), a.id_unidad_prod, a.cod_caract_2, c.cod_tipcred,'', e.descripcion 
                        INTO cNumCte, cSucursal, iPlazo, dtFechaOrigen, dTasaInteres, dTasaMoratorios, iIdUnidadProd, cCodCaract2, cCodTipCred, cNumTarjeta, cDescStatusCred 
                        FROM bdicred:"informix".sd_maecred a, bdicred:"informix".sd_definicion c, bdicred:"informix".sd_tipocartera e 
                        WHERE c.num_producto = a.num_producto AND c.empresa = a.empresa AND e.status_cred = a.status_cred AND a.num_credito  = cNumCredito AND a.empresa = cEmpresa;
                     ELSE
                        SELECT a.numcte, a.sucursal, a.plazo, a.fecha_apertura, NVL(a.tasa_interes,0), (NVL(a.tasa_moratorios,0) - NVL(a.tasa_interes,0)), a.id_unidad_prod, a.cod_caract_2, c.cod_tipcred,'', e.descripcion 
                        INTO cNumCte, cSucursal, iPlazo, dtFechaOrigen, dTasaInteres, dTasaMoratorios, iIdUnidadProd, cCodCaract2, cCodTipCred, cNumTarjeta, cDescStatusCred 
                        FROM bdicred:"informix".sd_maecred_old a, bdicred:"informix".sd_definicion c, bdicred:"informix".sd_tipocartera e 
                        WHERE c.num_producto = a.num_producto AND c.empresa = a.empresa AND e.status_cred = a.status_cred AND a.num_credito  = cNumCredito AND a.empresa = cEmpresa;
                     END IF;
                ELSE
                    IF vRespaldo = 0 THEN
                        SELECT a.numcte, a.sucursal, a.plazo, a.fecha_apertura, NVL(a.tasa_interes,0), (NVL(a.tasa_moratorios,0) - NVL(a.tasa_interes,0)), a.id_unidad_prod, a.cod_caract_2, c.cod_tipcred, d.num_tarjeta, e.descripcion 
                        INTO cNumCte, cSucursal, iPlazo, dtFechaOrigen, dTasaInteres, dTasaMoratorios, iIdUnidadProd, cCodCaract2, cCodTipCred, cNumTarjeta, cDescStatusCred 
                        FROM bdicred:"informix".sd_maecred a, bdicred:"informix".sd_definicion c, bdicred:"informix".sd_tarjeta d, bdicred:"informix".sd_tipocartera e 
                        WHERE c.num_producto = a.num_producto AND c.empresa = a.empresa AND d.num_credito = a.num_credito AND d.status_tar = d.status_tar AND d.tipo_tarjeta = 'T' and d.secuencia = (SELECT MAX(secuencia) FROM bdicred:"informix".sd_tarjeta WHERE a.empresa = empresa AND a.num_credito = num_credito AND tipo_tarjeta = 'T') AND d.empresa = a.empresa AND e.status_cred = a.status_cred AND a.num_credito = cNumCredito AND a.empresa = cEmpresa;
                    ELSE
                        SELECT a.numcte, a.sucursal, a.plazo, a.fecha_apertura, NVL(a.tasa_interes,0), (NVL(a.tasa_moratorios,0) - NVL(a.tasa_interes,0)), a.id_unidad_prod, a.cod_caract_2, c.cod_tipcred, d.num_tarjeta, e.descripcion 
                        INTO cNumCte, cSucursal, iPlazo, dtFechaOrigen, dTasaInteres, dTasaMoratorios, iIdUnidadProd, cCodCaract2, cCodTipCred, cNumTarjeta, cDescStatusCred 
                        FROM bdicred:"informix".sd_maecred_old a, bdicred:"informix".sd_definicion c, bdicred:"informix".sd_tarjeta d, bdicred:"informix".sd_tipocartera e 
                        WHERE c.num_producto = a.num_producto AND c.empresa = a.empresa AND d.num_credito = a.num_credito AND d.status_tar = d.status_tar AND d.tipo_tarjeta = 'T' and d.secuencia = (SELECT MAX(secuencia) FROM bdicred:"informix".sd_tarjeta WHERE a.empresa = empresa AND a.num_credito = num_credito AND tipo_tarjeta = 'T') AND d.empresa = a.empresa AND e.status_cred = a.status_cred AND a.num_credito = cNumCredito AND a.empresa = cEmpresa;
                    END IF;
                END IF
                
                IF DBINFO("sqlca.sqlerrd2")  = 0 THEN
                    LET cCodRet = '000003';
                    LET cMensajeRet = 'El numero de credito no existe';
				ELSE
                    IF vRespaldo = 0 THEN                    
                        SELECT prox_fecha_pago, fecha_ult_pago 
                        INTO dtFechaProxPago, dtFechaUltPago 
                        FROM bdicred:"informix".sd_maecredanexo 
                        WHERE num_credito = cNumCredito AND empresa = cEmpresa;

                        SELECT NVL(sdo_intereses,0), NVL(sdo_retenido,0), 0, NVL(sdo_capital,0), NVL(sdo_cap_insoluto,0), NVL(monto_vencido,0), NVL(mto_venc_trasp,0), NVL(monto_financiado,0), NVL(monto_otorgado,0), NVL(cap_tras_no_venci,0), (NVL(monto_otorgado,0) - NVL(sdo_cap_insoluto,0) - NVL(sdo_retenido,0)), 0 
                        INTO dIntDevengado, dSdoRetenido, dIntVig, dCapVig, dSdoActCap, dCapTrans, dCapVdoExig, dMontoFinanciado, dLineaOtorgada, dCapVdoNoExig, dLineaDisponible, iPagosRealizados
                        FROM bdicred:"informix".sd_maesdos
                        WHERE num_credito = cNumCredito AND empresa = cEmpresa;
                    ELSE
                        SELECT prox_fecha_pago, fecha_ult_pago 
                        INTO dtFechaProxPago, dtFechaUltPago 
                        FROM bdicred:"informix".sd_maecredanexo_old 
                        WHERE num_credito = cNumCredito AND empresa = cEmpresa;

                        SELECT NVL(sdo_intereses,0), NVL(sdo_retenido,0), 0, NVL(sdo_capital,0), NVL(sdo_cap_insoluto,0), NVL(monto_vencido,0), NVL(mto_venc_trasp,0), NVL(monto_financiado,0), NVL(monto_otorgado,0), NVL(cap_tras_no_venci,0), (NVL(monto_otorgado,0) - NVL(sdo_cap_insoluto,0) - NVL(sdo_retenido,0)), 0 
                        INTO dIntDevengado, dSdoRetenido, dIntVig, dCapVig, dSdoActCap, dCapTrans, dCapVdoExig, dMontoFinanciado, dLineaOtorgada, dCapVdoNoExig, dLineaDisponible, iPagosRealizados
                        FROM bdicred:"informix".sd_maesdos_old
                        WHERE num_credito = cNumCredito AND empresa = cEmpresa;
                    END IF;
					
					
                    SELECT SUM(NVL(monto,0))
					INTO dMontoSBC
					FROM bdicheq:"informix".sc_docret
					WHERE empresa= cEmpresa AND cuenta = cNumTarjeta AND siglas = 'SD' AND cancelado = 'T';
					
                    SELECT iva
					INTO dIvaSuc
					FROM bdinteg:"informix".si_sucursales
					WHERE sucursal = cSucursal AND empresa  = cEmpresa;
                    
                    EXECUTE PROCEDURE bdicred:"informix".sp_obtener_pagomin(cEmpresa,cNumCredito)
					INTO vvcodigo_retorno, vvmensaje_retorno, dPagoMinimo, dIntVdo, dIntMoratorio,dIvaIntVdo, dPagosVdos, dIvaIntMoratorio, dIntMes, dIvaIntMes, dIntVig, dIvaIntVig;
                    
                    IF vvcodigo_retorno <> '000000' THEN
                        LET cCodRet = '000007';
                        LET cMensajeRet= 'Error en calculo de pago minimo.';
					ELSE
                        SELECT NVL(SUM(NVL(interes_debe,0)),0),NVL(SUM(NVL(iva_debe,0)),0),0
						INTO dIntMes,dIvaIntMes,dIvaIntVig
						FROM bdicred:"informix".sd_amortiza_credito
						WHERE empresa = cEmpresa AND num_credito = cNumCredito AND capital_status = 1; 
                        
                        LET dSdoActInt = NVL(dIntVig,0) + NVL(dIntVdo,0) + NVL(dIntMoratorio,0);
                        LET dSdoActIvaInt = NVL(dIvaIntVig,0) + NVL(dIvaIntVdo,0) + NVL(dIvaIntMoratorio,0);
                        
                        {
                            SELECT NVL(SUM(decode(tc.comi_o_seg, '1', NVL(dc.monto_com,0) - NVL(dc.monto_pag,0), 0)),0), NVL(SUM(decode(tc.comi_o_seg, '4', NVL(dc.monto_com,0) - NVL(dcmonto_pag,0), 0)),0)
							INTO dComPend, dIvaCom
							FROM bdicred:"informix".sd_detcomi dc, bdicred:"informix".sd_tpcomis tc
							WHERE dc.empresa = cEmpresa AND dc.num_credito = cNumCredito AND dc.estado_com  = 'A' AND dc.empresa = tc.empresa AND dc.cod_comis = tc.cod_comis AND tc.comi_o_seg IN ('1','4');
                        }
                        
                        LET dComPend = 0;
                        LET dIvaCom  = 0;
                        
                        SELECT num_credito
						INTO cNumCreditoAux
						FROM bdicred:"informix".sd_promocion_credito
						WHERE empresa = cEmpresa and num_credito = cNumCredito AND status = 0 GROUP BY num_credito;
						
                        IF DBINFO("sqlca.sqlerrd2") = 1 THEN
                            SELECT sum(NVL(monto_int_iva,0))
							INTO vRetCs_acum
							FROM bdicred:"informix".sd_promocion_credito
							WHERE empresa = cEmpresa AND num_credito = cNumCredito  AND status = 0;
                        END IF;
                        
                        LET dSdoTotalLiq = NVL(dSdoActCap,0) + NVL(dIntVdo,0) + NVL(dIvaIntVdo,0) + NVL(dIntMoratorio,0) + NVL(dIvaIntMoratorio,0) + NVL(dSdoRetenido,0) - NVL(vRetCs_acum,0);
                        
                        IF ( dSdoTotalLiq < 0 ) THEN
                            LET dSdoTotalLiq = 0;
                        END IF;
                        
                        SELECT descripcion
						INTO cDescBloqueoCta
						FROM bdicred:"informix".sd_bloqueoscuenta
						WHERE clave = iIdUnidadProd;        
						
                        SELECT causa_bloq
						INTO cDescCausaBloqueoCta
						FROM bdicred:"informix".sd_causa_bloqueo
						WHERE empresa = pEmpresa AND cod_causa = cCodCaract2;
                        
                        LET cSitCte = '';
                        LET cCausaCte = '';
                        LET cDescSitEspCte = '';        
                        LET cSitCred ='';
                        LET cCausaCred ='';
                        LET cDescSitEspCred = '';
                    END IF;
                END IF;
				
            ELIF cTipCred  in ('P','R') THEN
        	
                SELECT a.numcte, a.sucursal,a.plazo,a.fecha_apertura,NVL(a.tasa_interes,0),(NVL(a.tasa_moratorios,0) - NVL(a.tasa_interes,0)),c.cod_tipcred,e.descripcion,c.ind_comision,c.tran_comision INTO cNumCte,cSucursal,iPlazo,dtFechaOrigen,dTasaInteres,dTasaMoratorios,cCodTipCred,cDescStatusCred,cind_comision,ctran_comision FROM bdicred:"informix".sd_maecredcrd a, bdicred:"informix".sd_definicion c, bdicred:"informix".sd_tipocartera e  WHERE c.num_producto = a.num_producto  AND c.empresa      = a.empresa  AND e.status_cred = a.status_cred AND a.num_credito = cNumCredito AND a.empresa = cEmpresa;
        		
                IF DBINFO("sqlca.sqlerrd2")  = 0 THEN
                    LET cCodRet = '000004';
                    LET cMensajeRet = 'El numero de credito no existe';
				ELSE
                    IF cTipCred='R' THEN
                        LET dTasaMoratorios=0;
                    END IF;
                    
                    SELECT prox_fecha_pago, fecha_ult_pago
					INTO dtFechaProxPago, dtFechaUltPago
					FROM bdicred:"informix".sd_maecredanexocrd
					WHERE num_credito = cNumCredito AND empresa = cEmpresa;
					
                    SELECT NVL(sdo_intereses,0), NVL(sdo_retenido,0), 0, NVL(sdo_capital,0), NVL(sdo_cap_insoluto,0), NVL(monto_vencido,0), NVL(mto_venc_trasp,0), NVL(monto_financiado,0),NVL(monto_otorgado,0), NVL(cap_tras_no_venci,0), 0
					INTO dIntDevengado, dSdoRetenido, dIntVig, dCapVig, dSdoActCap, dCapTrans, dCapVdoExig, dMontoFinanciado, dLineaOtorgada, dCapVdoNoExig, dLineaDisponible
					FROM bdicred:"informix".sd_maesdoscrd
					WHERE num_credito = cNumCredito AND empresa = cEmpresa;
                            
                    IF dIntDevengado IS NULL THEN
                        LET dIntDevengado = 0;
                    END IF;
                    
                    SELECT a.iva_fecha_pago, a.fecha_cuota
					INTO dtIvaFechaPag,dtFechaCuota
					FROM bdicred:"informix".sd_amortiza_creditocrd a
					WHERE a.empresa = cEmpresa AND a.num_credito = cNumCredito AND a.capital_status = "3";
                    
                    SELECT iva
					INTO dIvaSuc
					FROM bdinteg:"informix".si_sucursales
					WHERE sucursal = cSucursal AND empresa  = cEmpresa;
			
                    EXECUTE PROCEDURE bdicred:"informix".calc_iva_grav_pp(cEmpresa,cNumCredito,dTasaInteres,dIvaSuc,dtFechaHoy, dtIvaFechaPag,dtFechaOrigen,dtFechaCuota,dIntDevengado)
					INTO cCodRet,dIvaIntDevengado,cMensajeRet;
                    
                    IF cCodRet <> "000000" THEN
                        LET cCodRet = '000005';
                        LET cMensajeRet = 'Ocurrio un error al realizar calculo';
					ELSE
                        SELECT COUNT(num_credito)
						INTO iPagosRealizados
						FROM bdicred:"informix".sd_amortiza_creditocrd
						WHERE empresa = pEmpresa AND num_credito = cNumCredito AND capital_status = '5';        
                    
                        EXECUTE PROCEDURE bdicred:"informix".sp_obtener_pagomin(cEmpresa,cNumCredito)
						INTO vvcodigo_retorno, vvmensaje_retorno, dPagoMinimo, dIntVdo, dIntMoratorio, dIvaIntVdo, dPagosVdos, dIvaIntMoratorio, dIntMes, dIvaIntMes, dIntVig, dIvaIntVig;
                        
                        LET dSdoActInt = NVL(dIntVig,0) + NVL(dIntVdo,0) + NVL(dIntMoratorio,0);
                        LET dSdoActIvaInt = NVL(dIvaIntVig,0) + NVL(dIvaIntVdo,0) + NVL(dIvaIntMoratorio,0);        
                        
                        IF vvcodigo_retorno <> '000000' THEN
                            LET cCodRet= '000008';
                            LET cMensajeRet= 'Error en calculo de pago minimo.';
						ELSE
                            {
                                SELECT NVL(SUM(DECODE(tc.comi_o_seg, '1', NVL(dc.monto_com,0) - NVL(dc.monto_pag,0), 0)),0), NVL(SUM(DECODE(tc.comi_o_seg, '4', NVL(dc.monto_com,0) - NVL(dc.monto_pag,0), 0)),0)
								INTO dComPend, dIvaCom
								FROM bdicred:"informix".sd_detcomi dc, bdicred:"informix".sd_tpcomis tc
								WHERE dc.empresa = cEmpresa AND dc.num_credito = cNumCredito AND dc.estado_com  = 'A' AND dc.empresa = tc.empresa AND dc.cod_comis = tc.cod_comis AND tc.comi_o_seg IN ('1','4'); 
                            }
                            
                            LET dComPend = 0;
                            LET dIvaCom  = 0;
                            
                            EXECUTE PROCEDURE bdicred:"informix".monthadd(dtFechaOrigen, 1)
							INTO dtMesiversario;
                            
                            IF dtFechaHoy < dtMesiversario and cTipCred = 'P' and cind_comision = '1' THEN
                            
                                SELECT apli_factor/100
								INTO dFactorComision
								FROM bdicred:"informix".sd_tpcomis
								WHERE cod_comis=ctran_comision;
								
                                IF dFactorComision IS NULL THEN
                                    LET cCodRet = '000006';
                                    LET cMensajeRet = 'No se encontro el factor de la comision';
								ELSE
                                    IF dSdoActCap<=0 THEN
                                        LET dComPend = dSdoActCap * dFactorComision;
                                    ELSE
                                        LET dComPend = dLineaOtorgada * dFactorComision;
                                    END IF;        
                                    LET dIvaCom = dComPend * dIvaSuc;
                                END IF;                      
                            END IF;
                            IF cCodRet = '000000' THEN
                                LET dSdoTotalLiq = NVL(dSdoActCap,0) + NVL(dIntVdo,0) + NVL(dIvaIntVdo,0) + NVL(dIntMoratorio,0) + NVL(dIvaIntMoratorio,0) + NVL(dSdoRetenido,0) + NVL(dComPend,0) + NVL(dIvaCom,0) + NVL(dIntDevengado,0) + NVL(dIvaIntDevengado,0) + NVL(dIntVig,0) + NVL(dIvaIntVig,0);
                                
                                IF ( dSdoTotalLiq < 0 ) THEN
                                    LET dSdoTotalLiq = 0;
                                END IF;
                                
                                LET cSitCte = '';
                                LET cCausaCte = '';
                                LET cDescSitEspCte = '';        
                                LET cSitCred ='';
                                LET cCausaCred ='';
                                LET cDescSitEspCred = '';
							END IF;
                        END IF;        
                    END IF;
                END IF;        
            END IF;
		END IF;
    END IF;    

   RETURN cCodRet, cMensajeRet, cNumCredito, NVL(cCodTipCred,''),NVL(dtFechaOrigen,DATE(1)), NVL(dtFechaProxPago,DATE(1)), NVL(dPagoMinimo,0), NVL(dtFechaUltPago,DATE(1)), NVL(iPlazo,0), NVL(iPagosRealizados,0), NVL(dLineaOtorgada,0), NVL(dTasaInteres,0), NVL(dTasaMoratorios,0), NVL(dMontoSBC,0), NVL(dCapVig,0), NVL(dCapTrans,0), NVL(dCapVdoExig,0), NVL(dCapVdoNoExig,0), NVL(dSdoActCap,0), NVL(dIntVig,0), NVL(dIntVdo,0), NVL(dIntMoratorio,0), NVL(dIntMes,0), NVL(dSdoActInt,0), NVL(dIvaIntVig,0), NVL(dIvaIntVdo,0), NVL(dIvaIntMoratorio,0), NVL(dIvaIntMes,0), NVL(dSdoActIvaInt,0), NVL(dComPend,0), NVL(dIvaCom,0), NVL(dSdoRetenido,0), NVL(dSdoTotalLiq,0), NVL(dIntDevengado,0),NVL(dIvaIntDevengado,0), NVL(dLineaDisponible,0), NVL(dPagosVdos,0), NVL(cDescStatusCred,''), NVL(iIdUnidadProd,0), NVL(TRIM(cDescBloqueoCta),''), NVL(cCodCaract2,''), NVL(TRIM(cDescCausaBloqueoCta),''), NVL(cSitCte,''), NVL(cCausaCte,0), NVL(TRIM(cDescSitEspCte),''), NVL(cSitCred,''), NVL(cCausaCred,0), NVL(TRIM(cDescSitEspCred),''); 

END
END PROCEDURE

DOCUMENT
'Se realiza procedimiento para obtener los saldos ',
'generales del credito',
'AUTOR : Paul Ivan Quintero Varela',
'FECHA : 22/06/2009',
'FECHA MODIFICACION: 26/12/2018',
'Modificacion : Coppel',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_depura_sd_indicador_cred_hist(pFecha DATE)
--execute procedure sp_depura_sd_indicador_cred_hist(mdy('04','25','2013'));
RETURNING 
CHAR(6),     -- codigo de retorno
CHAR(150);    -- mensaje

DEFINE cCodRet      	CHAR(6); 
DEFINE cMensaje     	CHAR(150); 
DEFINE vNumCred     	VARCHAR(20,1);
DEFINE vNumCredAux  	VARCHAR(20,1);
DEFINE iSqlErr      	INTEGER;
DEFINE iIsamErr     	INTEGER;
DEFINE Error_Info   	VARCHAR(80);
--DEFINE pFecha 	DATE;
DEFINE vFecha 			DATE;
DEFINE dFechaAProcesar 	DATE;
DEFINE vnum_credito 	CHAR(20);
DEFINE vfecha_corte 	DATE;
DEFINE cFechaDepura 	CHAR(10);
DEFINE iDepura			INTEGER;
DEFINE cHoraInicial		CHAR(8);
DEFINE cHoraFinal		CHAR(8);
DEFINE sHoraInicial		SMALLINT;
DEFINE sHoraFinal		SMALLINT;
DEFINE sMinutoInicial	SMALLINT;
DEFINE sMinutoFinal		SMALLINT;
DEFINE sHorasProceso	SMALLINT;
DEFINE cTerminaProceso					CHAR(1);
DEFINE iCuentasaDepurar					INTEGER;
DEFINE iCount_restantes					INTEGER;
DEFINE iCount_sd_indicador_cred_hist	INTEGER;

DEFINE cProceso			CHAR(04);
DEFINE P_COD_RET    	VARCHAR(6);
DEFINE P_MENSAJE    	VARCHAR(150);
DEFINE v_sql        CHAR(1200);
DEFINE v_sql1       CHAR(500);
DEFINE v_sql2       CHAR(500);
DEFINE vRuta		CHAR(50);
DEFINE dFechaIni	DATE;
DEFINE dFechaFin	DATE;
DEFINE dFechaEmision DATE;
DEFINE cReinicio	CHAR(02);
DEFINE vNumCredito	CHAR(20);
DEFINE vFechaDelete	DATE;

LET vFechaDelete	= '';
LET vNumCredito		= '';
LET v_sql       	= "";
LET v_sql1      	= "";
LET v_sql2      	= "";
LET cCodRet      = '000000';
LET cMensaje     = '';
LET iSqlErr      = 0;
LET iIsamErr     = 0;
LET Error_Info   = '';
LET vNumCred     = '';
LET vNumCredAux  = '';
--LET pFecha 	= DATE(1);
LET vFecha 			= DATE(1);
LET dFechaAProcesar = DATE(1);
LET vnum_credito	= '';
LET vfecha_corte	= DATE(1);
LET cFechaDepura	= '';
LET iDepura			= 0;
LET cHoraInicial	= '';
LET cHoraFinal		= '';
LET sHoraInicial	= 0;
LET sHoraFinal		= 0;
LET sMinutoInicial	= 0;
LET sMinutoFinal	= 0;
LET sHorasProceso	= 0;
LET cTerminaProceso = '0';
LET iCuentasaDepurar				= 0;
LET iCount_restantes				= 0;
LET iCount_sd_indicador_cred_hist	= 0;
LET cProceso		= '0004';
LET P_COD_RET   	= '000000';
LET P_MENSAJE		= '';
LET vRuta      		= '/RESPALDOSNEW/'; --"/resplogifx/archivoscartera/";
LET dFechaIni	= DATE(1);
LET dFechaFin	= DATE(1);
LET dFechaEmision = DATE(1);
LET cReinicio 		= '';

BEGIN

    ON EXCEPTION SET iSqlErr, iIsamErr, Error_Info
        IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;		
            LET cMensaje = 'Error --> '||Error_Info||'	';		
			CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, cMensaje, '02') RETURNING P_COD_RET;
            RETURN cCodRet,cMensaje;
		END IF;
    END EXCEPTION;

    CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, cMensaje, '01') RETURNING P_COD_RET;
	
	IF P_COD_RET != '000000' THEN
       LET P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
       RETURN P_COD_RET,P_MENSAJE;
    END IF;
	
	--SET DEBUG FILE TO '/RESPALDOSNEW/Ulises/depura/sp_depura_tablas.out';
	--TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND INTO cHoraInicial from sysmaster:sysshmvals;

	LET sHoraInicial = SUBSTR(cHoraInicial,1,2);
	LET sMinutoInicial = SUBSTR(cHoraInicial,4,2);
	
	-- ULTIMA FECHA DEPURACION CUENTAS CANCELADAS  FORMATO --> 12/31/2018
    SELECT valor
	INTO vFecha
	FROM bdicred:sd_param
	WHERE cod_param = '117';

    IF vFecha = '' OR vFecha IS NULL THEN
		INSERT INTO "informix".sd_param(empresa, cod_param, descripcion, valor, user_insert, fecha_insert) 
			VALUES('001', '117', 'ULTIMA FECHA DEPURACION DE TABLAS', '12/31/2018', user, TODAY);
			
		LET vFecha = mdy('12','31','2018');
	END IF;	
	
	IF pFecha = date(1) THEN
		LET pFecha = MDY(MONTH(today),20,YEAR(today));
	ELSE
		LET pFecha = MDY(MONTH(pFecha),20,YEAR(pFecha));
		IF  pFecha > MDY(MONTH(vFecha),20,YEAR(vFecha)) THEN
		   LET P_MENSAJE  = 'Excediste fecha a depurar';
		   LET P_COD_RET = '000001';
		   CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, P_COD_RET, P_MENSAJE, '02') RETURNING P_COD_RET;
		   RETURN P_COD_RET,P_MENSAJE;
		END IF;
	END IF;
	
	-- PARAMETRO DE HORAS A PROCESAR CUENTAS CANCELADAS      VALOR --> 5	
	SELECT valor::SMALLINT
      INTO sHorasProceso
      FROM bdicred:sd_param
     WHERE cod_param = '118';

	 IF sHorasProceso IS NULL THEN 
		INSERT INTO "informix".sd_param(empresa, cod_param, descripcion, valor, user_insert, fecha_insert) 
			VALUES('001', '118', 'PARAMETRO DE HORAS A PROCESAR DEPURACION SD_INDICADOR_CRED_HIST', '5', user, TODAY);
		
		LET sHorasProceso = '5';
	END IF;
	
	--Se obtiene la ruta para descargar archivos.
/*	SELECT valor::CHAR INTO vRuta
	FROM bdicred:sd_param 
	where cod_param = '033';
*/		
	SELECT valor
      INTO cReinicio
      FROM bdicred:"informix".sd_param
     WHERE empresa = '001' AND cod_param = '119';
	 
	 -- Si no existe el parametro 063 insertar informacion.
 
	 IF cReinicio IS NULL THEN
		LET cReinicio = '0';
		BEGIN WORK;
		INSERT INTO bdicred:"informix".sd_param(empresa,cod_param,descripcion,valor,user_insert,fecha_insert)
		VALUES ('001','119','Control reinicio descarga de tablas',cReinicio,USER,today);
		COMMIT WORK;
	
	ELIF cReinicio = '' THEN
		LET cReinicio = '0';
		BEGIN WORK;
		UPDATE bdicred:"informix".sd_param SET valor = cReinicio
		WHERE cod_param = '119';
		COMMIT WORK;
	END IF;
	
	-- Se Obtiene rango de fecha por mes
	LET dFechaIni = MDY(MONTH(pFecha),1,YEAR(pFecha));
	LET dFechaFin = (dFechaIni + 1 UNITS MONTH) - 1 UNITS DAY;

	If cReinicio = '0' then
		CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, 'Inicio de descargas de tablas operativas', '02') RETURNING P_COD_RET;
		-- Descargar de informaciÃ³n sd_indicador_cred_hist
		LET v_sql1 = '';
        LET v_sql2 = '';
		LET v_sql = '';

        LET v_sql1 = ' echo "UNLOAD TO '|| trim(vRuta) ||'sd_indicador_cred_hist_'||to_char(dFechaFin, '%d%m%Y')||'.unl';
        LET v_sql2 = ' select * from sd_indicador_cred_hist where empresa = "001" AND fecha >= '''||dFechaIni||''' and fecha <= '''||dFechaFin||'''; " > '|| trim(vRuta) ||'queryIndicadorCred.sql';

        LET v_sql = trim(v_sql1) || v_sql2;
        system v_sql;
		
        LET v_sql = "dbaccess bdicred "|| trim(vRuta) ||"queryIndicadorCred.sql";
        system v_sql;
		
		LET cReinicio = '1';
		BEGIN WORK;
		update bdicred:"informix".sd_param
		set valor = cReinicio
		where empresa = '001' AND cod_param='119';
		COMMIT WORK;
		
		LET v_sql = '';
		LET v_sql = "gzip " || trim(vRuta) ||'sd_indicador_cred_hist_'||to_char(dFechaFin, '%d%m%Y')||'.unl';
		SYSTEM v_sql;
		
		CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, 'Termina descarga de tabla sd_indicador_cred_hist', '02') RETURNING P_COD_RET;
	end if;

--RETURN cCodRet,P_MENSAJE;	
		
	-- INICIA LA DEPURACION DE TABLAS OPERATIVAS
	CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, 'Inicia depuracion de tablas operativas', '02') RETURNING P_COD_RET;
	
	FOREACH WITH HOLD
		select num_credito, fecha INTO vNumCredito, vFechaDelete from bdicred:sd_indicador_cred_hist where empresa = '001' and fecha >= dFechaIni and fecha <= dFechaFin
		
		LET iCuentasaDepurar = iCuentasaDepurar + 1;
		
		BEGIN WORK;
			delete from bdicred:sd_indicador_cred_hist where empresa = '001' and fecha = vFechaDelete and num_credito = vNumCredito;
			--delete from bdicred:sd_encabezado_edoctacrd where fecha_emision = dFechaEmision and num_credito = cNumCredito;
        COMMIT WORK;
	END FOREACH;
		
		 SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND INTO cHoraFinal from sysmaster:sysshmvals;

		LET	sHoraFinal = SUBSTR(cHoraFinal,1,2);
		LET	sMinutoFinal = SUBSTR(cHoraFinal,4,2);
		LET	sHoraFinal = sHoraFinal - sHoraInicial;

		IF sHoraFinal >= sHorasProceso AND sMinutoFinal > sMinutoInicial THEN
			LET cTerminaProceso = '1';
			--EXIT FOREACH;
		END IF;
	
	CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, 'Termina depuracion de tablas operativas', '02') RETURNING P_COD_RET;
	
	LET cReinicio = '0';
		
	update bdicred:"informix".sd_param
	set valor = cReinicio
	where empresa = '001' AND cod_param='119';
	
	UPDATE STATISTICS MEDIUM FOR TABLE bdicred:sd_indicador_cred_hist;
	
	--CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, cMensaje, '03') RETURNING P_COD_RET;
	LET cMensaje = 'TOTAL Cuentas depuradas : ' ||iCuentasaDepurar;
	CALL "informix".sp_inserta_bitacora('001', cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
	
	IF P_COD_RET != '000000' THEN
       LET P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
       RETURN P_COD_RET,P_MENSAJE;
    END IF;
	
	CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, cMensaje, '03') RETURNING P_COD_RET;

	LET P_MENSAJE = 'El proceso DEPURA TABLA sd_indicador_cred_hist termino exitosamente. Cuentas procesadas ' || iCuentasaDepurar;
	
    RETURN cCodRet,P_MENSAJE;

    END
END PROCEDURE;
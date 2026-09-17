CREATE PROCEDURE "informix".sp_consulta_saldos_general_pba(pEmpresa CHAR(3), pNumCredito CHAR(20))
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
    -- Autor: Roque Enrique Solis CampaÃ±a                                                                    --
    --Modificacion: Se agregaron las consultas para saldos de prestamos personales                           --
    -----------------------------------------------------------------------------------------------------------
    -- Fecha: 20/10/2009                                                                                     --
    -- Autor: Roque Enrique Solis CampaÃ±a                                                                    --
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
    -- Modificacion: Se modifica mÃ©todo para calcular el IVA moratorio en prÃ©stamos personales y             --
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

    BEGIN
    
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
        IF iSqlErr != 0 THEN
            LET cCodRet = iSqlErr;
            LET cMensajeRet = 'OcurriÃ³ error al consultar los saldos'||' - '||cErrorInfo;
            RETURN cCodRet, cMensajeRet, cNumCredito, NVL(cCodTipCred,''),NVL(dtFechaOrigen,DATE(1)), NVL(dtFechaProxPago,DATE(1)), NVL(dPagoMinimo,0), NVL(dtFechaUltPago,DATE(1)), NVL(iPlazo,0), NVL(iPagosRealizados,0), NVL(dLineaOtorgada,0), NVL(dTasaInteres,0), NVL(dTasaMoratorios,0), NVL(dMontoSBC,0), NVL(dCapVig,0), NVL(dCapTrans,0), NVL(dCapVdoExig,0), NVL(dCapVdoNoExig,0), NVL(dSdoActCap,0), NVL(dIntVig,0), NVL(dIntVdo,0), NVL(dIntMoratorio,0), NVL(dIntMes,0), NVL(dSdoActInt,0), NVL(dIvaIntVig,0), NVL(dIvaIntVdo,0), NVL(dIvaIntMoratorio,0), NVL(dIvaIntMes,0), NVL(dSdoActIvaInt,0), NVL(dComPend,0), NVL(dIvaCom,0), NVL(dSdoRetenido,0), NVL(dSdoTotalLiq,0), NVL(dIntDevengado,0),NVL(dIvaIntDevengado,0), NVL(dLineaDisponible,0), NVL(dPagosVdos,0), NVL(cDescStatusCred,''), NVL(iIdUnidadProd,0), NVL(TRIM(cDescBloqueoCta),''), NVL(cCodCaract2,''), NVL(TRIM(cDescCausaBloqueoCta),''), NVL(cSitCte,''), NVL(cCausaCte,0), NVL(TRIM(cDescSitEspCte),''), NVL(cSitCred,''), NVL(cCausaCred,0), NVL(TRIM(cDescSitEspCred),'');
        END IF;
    END EXCEPTION;

	SET LOCK MODE TO WAIT 3;
    SET ISOLATION TO dirty READ;
	
   -- SET DEBUG FILE TO '/tmp/sp_consulta_saldos_general.out';
   -- TRACE ON;
	
    LET cCodRet = '000000';
    LET cMensajeRet  = 'Se realizÃ³ la consulta correctamente.';
	
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
        LET cMensajeRet = 'No hay informaciÃ³n para realizar la consulta';
	ELSE
        SELECT fecha_hoy 
		INTO dtFechaHoy 
		FROM bdicred:"informix".sd_fechas 
		WHERE empresa = pEmpresa;  
		
        SELECT b.cod_prod 
		INTO cTipCred 
		FROM bdicred:"informix".sd_maecred a, bdicred:"informix".sd_tipprod b 
		WHERE a.num_credito = cNumCredito AND a.empresa = pEmpresa AND a.empresa = b.empresa AND a.num_producto=b.abrevia_prod;

        IF cTipCred IS NULL THEN
            SELECT b.cod_prod 
			INTO cTipCred 
			FROM bdicred:"informix".sd_maecredcrd a, bdicred:"informix".sd_tipprod b 
			WHERE a.num_credito = cNumCredito AND a.empresa=pEmpresa AND a.empresa=b.empresa AND a.num_producto=b.abrevia_prod; 
            IF cTipCred IS NULL THEN
                LET cCodRet = '000002';
                LET cMensajeRet= 'No hay informaciÃ³n para realizar la consulta';
            END IF;		
        END IF;
		
		IF cCodRet = '000000' THEN
            IF cTipCred = 'T' THEN
                IF SUBSTR(cNumCredito,1,2) = "78" THEN		
                    SELECT a.numcte, a.sucursal, a.plazo, a.fecha_apertura, NVL(a.tasa_interes,0), (NVL(a.tasa_moratorios,0) - NVL(a.tasa_interes,0)), a.id_unidad_prod, a.cod_caract_2, c.cod_tipcred,'', e.descripcion 
					INTO cNumCte, cSucursal, iPlazo, dtFechaOrigen, dTasaInteres, dTasaMoratorios, iIdUnidadProd, cCodCaract2, cCodTipCred, cNumTarjeta, cDescStatusCred 
					FROM bdicred:"informix".sd_maecred a, bdicred:"informix".sd_definicion c, bdicred:"informix".sd_tipocartera e 
					WHERE c.num_producto = a.num_producto AND c.empresa = a.empresa AND e.status_cred = a.status_cred AND a.num_credito  = cNumCredito AND a.empresa = cEmpresa;
                ELSE
                    SELECT a.numcte, a.sucursal, a.plazo, a.fecha_apertura, NVL(a.tasa_interes,0), (NVL(a.tasa_moratorios,0) - NVL(a.tasa_interes,0)), a.id_unidad_prod, a.cod_caract_2, c.cod_tipcred, d.num_tarjeta, e.descripcion 
					INTO cNumCte, cSucursal, iPlazo, dtFechaOrigen, dTasaInteres, dTasaMoratorios, iIdUnidadProd, cCodCaract2, cCodTipCred, cNumTarjeta, cDescStatusCred 
					FROM bdicred:"informix".sd_maecred a, bdicred:"informix".sd_definicion c, bdicred:"informix".sd_tarjeta d, bdicred:"informix".sd_tipocartera e 
					WHERE c.num_producto = a.num_producto AND c.empresa = a.empresa AND d.num_credito = a.num_credito AND d.status_tar = d.status_tar AND d.tipo_tarjeta = 'T' and d.secuencia = (SELECT MAX(secuencia) FROM bdicred:"informix".sd_tarjeta WHERE a.empresa = empresa AND a.num_credito = num_credito AND tipo_tarjeta = 'T') AND d.empresa = a.empresa AND e.status_cred = a.status_cred AND a.num_credito = cNumCredito AND a.empresa = cEmpresa;
                END IF
                
                IF DBINFO("sqlca.sqlerrd2")  = 0 THEN
                    LET cCodRet = '000003';
                    LET cMensajeRet = 'El nÃºmero de crÃ©dito no existe';
				ELSE
                    SELECT prox_fecha_pago, fecha_ult_pago 
					INTO dtFechaProxPago, dtFechaUltPago 
					FROM bdicred:"informix".sd_maecredanexo 
					WHERE num_credito = cNumCredito AND empresa = cEmpresa;
					
                    SELECT NVL(sdo_intereses,0), NVL(sdo_retenido,0), 0, NVL(sdo_capital,0), NVL(sdo_cap_insoluto,0), NVL(monto_vencido,0), NVL(mto_venc_trasp,0), NVL(monto_financiado,0), NVL(monto_otorgado,0), NVL(cap_tras_no_venci,0), (NVL(monto_otorgado,0) - NVL(sdo_cap_insoluto,0) - NVL(sdo_retenido,0)), 0 
					INTO dIntDevengado, dSdoRetenido, dIntVig, dCapVig, dSdoActCap, dCapTrans, dCapVdoExig, dMontoFinanciado, dLineaOtorgada, dCapVdoNoExig, dLineaDisponible, iPagosRealizados
					FROM bdicred:"informix".sd_maesdos
					WHERE num_credito = cNumCredito AND empresa = cEmpresa;
					
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
                        LET cMensajeRet= 'Error en cÃ¡lculo de pago mÃ­nimo.';
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
                    LET cMensajeRet = 'El nÃºmero de crÃ©dito no existe';
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
                        LET cMensajeRet = 'OcurriÃ³ un error al realizar calculo';
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
                            LET cMensajeRet= 'Error en cÃ¡lculo de pago mÃ­nimo.';
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
                                    LET cMensajeRet = 'No se encontrÃ³ el factor de la comisiÃ³n';
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
'generales del crÃ©dito',
'AUTOR : Paul Ivan Quintero Varela',
'FECHA : 22/06/2009',
'FECHA MODIFICACION: 26/12/2018',
'Modificacion : Coppel',
'ValidaciÃ³n : Marcela PÃ©rez-GM3',
'ValidaciÃ³n : Alejandro SÃ¡nchez-GM1',
'VoBo : Alejandro SÃ¡nchez-GM1',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_actualiza_sesion_bex_pba(pc_numero_cliente varchar(20), pc_canal varchar(20), pc_id_sesion char(500), key_old varchar(100), key_new varchar(100))
    RETURNING CHAR(5),CHAR(5);
	
	DEFINE resultado CHAR(5);
    DEFINE vcodret   CHAR(5);
    DEFINE sql_err   INTEGER;
	DEFINE exist     INTEGER;
    DEFINE vCountinactivas INTEGER;
	DEFINE dFecha	DATETIME YEAR TO SECOND;
	
	--SET DEBUG FILE TO "/informix/ireb/bdibpi/bex/sp_actualiza_sesion_bex.out";
    --TRACE ON; 
	LET vcodret   = '00000';
	LET resultado = '00000';
    LET exist = 0;
    LET vCountinactivas = 0;
	LET dFecha = CURRENT;
	
	BEGIN	

	ON EXCEPTION SET sql_err
       IF sql_err <> 0 THEN
			LET vcodret = sql_err;
        RETURN vcodret, resultado;
       END IF;
	END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
		
		--SELECT count(numcliente) 
		SELECT LIMIT 1 1, fecha
		INTO exist, dFecha
		FROM "informix".bpi_doblesesion 
		WHERE numcliente = pc_numero_cliente 
		AND canal = pc_canal 
		AND id_sesion = pc_id_sesion 
		AND llave = key_old;
			 
		IF exist > 0 THEN
--GM2 Juan Olivares: 25/10/2018 INI: ModificaciÃÂ³n Validacion Doble SesiÃÂ³n para evitar error -284
			/*SELECT SUM(CASE WHEN (CURRENT - fecha) < '0 00:08:00.000' THEN 1 ELSE 0 END)
            INTO vCountinactivas
            FROM "informix".bpi_doblesesion 
            WHERE numcliente = pc_numero_cliente
            AND canal = pc_canal;
*/
           -- LET vCountinactivas = NVL(vCountinactivas,0);
		   IF ((CURRENT - dFecha) < '0 00:08:00.000') THEN
				LET vCountinactivas = 1;
		   ELSE
				LET vCountinactivas = 0;				
		   END IF;

			--IF ((SELECT (CURRENT - fecha) FROM "informix".bpi_doblesesion WHERE numcliente = pc_numero_cliente AND canal = pc_canal AND id_sesion = pc_id_sesion AND llave = key_old) <  '0 00:08:00.000')
                IF  (vCountinactivas = 1) THEN
					UPDATE "informix".bpi_doblesesion 
					SET fecha = CURRENT,
					    llave = key_new
					WHERE numcliente = pc_numero_cliente
					AND canal = pc_canal
					AND id_sesion = pc_id_sesion 
					AND llave = key_old;
							
					LET resultado = '00000';
				ELSE
					DELETE FROM "informix".bpi_doblesesion 
					WHERE numcliente = pc_numero_cliente 
					AND canal = pc_canal
					AND id_sesion = pc_id_sesion 
					AND llave = key_old;
--GM2 Juan Olivares: 25/10/2018 FIN: ModificaciÃÂ³n Validacion Doble SesiÃÂ³n para evitar error -284							
					LET resultado = '00001';
				END IF;
		ELSE			
			LET resultado = '00002';
		END IF;
END;		
	RETURN	vcodret, resultado;	
END PROCEDURE

DOCUMENT
'MODIFICADO POR: JUAN OLIVARES-GM2',
'VALIDACION FUNCIONALIDAD POR: PATRICIA DEL RAZO-GM3',
'FECHA DE MODIFICACION: 25 DE OCTUBRE DE 2018',
'OBJETIVO: CAMBIO: ELIMINAR ERROR -284, DOBLE SESION',
'FECHA DE ULTIMA MODIFICACION: 26 DE DICIEMBRE DE 2018',
'MODIFICADO POR: COPPEL',
'VALIDACION FUNCIONALIDAD POR:MARCELA PEREZ GM3',
'VoBo POR: ALEJANDRO SANCHEZ-GM1',
'BD: BDIBPI';

CREATE PROCEDURE "informix".sp_consultasaldocorte_pba(pEmpresa  CHAR (3),pNumCredito CHAR (20), pTipoConsulta SMALLINT)
  RETURNING CHAR (5) AS CodRet, DECIMAL (14,2) AS saldototal;

--pTipoConsulta = 1  Cierre, 0 Para No generar Intereses  
--FMJ Febrero 2012
  
 -- DEFINICION DE VARIABLES --
DEFINE sSqlErr SMALLINT;
DEFINE cCodRet CHAR(5);
DEFINE vSaldoTotal DECIMAL (14,2);

DEFINE iDia_corte 	 INTEGER;
DEFINE vRevolvente	 SMALLINT;
DEFINE dFechaCorte	 DATE;
DEFINE dFechaMesiver DATE;
DEFINE dFechaCentral DATE;

LET sSqlErr = 0;
LET cCodRet = '00000';

LEt iDia_corte = 0;
LET vRevolvente =0;
LET vSaldoTotal = 0;
LET dFechaCentral =date(1); 
LET dFechaMesiver =date(1); 
LET dFechaCorte = date(1); 

BEGIN
        ON EXCEPTION SET sSqlErr
            LET cCodRet = sSqlErr;
            RETURN cCodRet, vSaldoTotal;
        END EXCEPTION;

	set lock mode to wait 3;
	set isolation to dirty read;

	SELECT {+INDEX(bdicred:"informix".sd_fechas idx_sdfechas)} fecha_hoy
  	  INTO dFechaCentral
      FROM bdicred:"informix".sd_fechas
     WHERE empresa = pEmpresa;

	SELECT dia_corte  INTO iDia_corte  
	  FROM bdicred:"informix".sd_maecredanexo     
	 WHERE empresa = pEmpresa  AND num_credito = pNumCredito;		

	LET iDia_corte = nvl(iDia_corte,0);
	 
	if iDia_corte <> 0 then   	
	  Let vRevolvente = 1;	
	  if day(dFechaCentral) <= iDia_corte then
			let dFechaCorte = mdy(month(dFechaCentral),iDia_corte,year(dFechaCentral)) - 1 units month;
		else
			let dFechaCorte = mdy(month(dFechaCentral),iDia_corte,year(dFechaCentral));
		end if;	  
    else     
		Let vRevolvente = 0;

        SELECT nvl(dia_corte,0)  INTO iDia_corte  
          FROM bdicred:"informix".sd_maecredanexocrd     
         WHERE empresa = pEmpresa  
           AND num_credito = pNumCredito;	
	LET iDia_corte = nvl(iDia_corte,0);

        EXECUTE PROCEDURE bdicred:"informix".sp_fecha_plazo(pEmpresa,iDia_corte)
        into cCodRet, dFechaMesiver, dFechaCorte;

        if (cCodRet <> '00000') then
          let cCodRet = '00002';  -- ERROR EN RUTINA DE CALCULO DE MESIVERSARIO
          let vSaldoTotal = 0; 
		  let vRevolvente = 2; 
       end if;

	end if;	
		
	--If  ( iDia_corte =0) and (nvl(dFechaCorte,date(1)) =date(1)) then 
	LET dFechaCorte = NVL(dFechaCorte, date(1));	
	If  ( iDia_corte =0) and (dFechaCorte = date(1)) then 	
          let cCodRet = '00001';  -- CREDITO NO EXISTE
          let vSaldoTotal = 0; 
		  let vRevolvente = 2; 	
    end if;
	
	If (vRevolvente = 1) Then
	
		select nvl(( case when (nvl(sdo_cap_insoluto,0) < 0) then decode( pTipoConsulta,1, nvl(sdo_cap_insoluto,0),0)  
		             else  Nvl(sdo_cap_insoluto,0) +  Nvl(round((sdo_moratorio + sdo_contab_mora) * (1+ s.iva),2),0)  +			
					 
							case when (NVL(int_tra_no_exig,0) -NVL(sdo_acum_mes_int,0) >=0) then  ---
									  (NVL(int_tra_no_exig,0) -NVL(sdo_acum_mes_int,0)) else NVL(int_tra_no_exig,0) end + 
									  
						   (select nvl(campo_trabajo1 ,0)
							from bdicred:"informix".sd_amortiza_credito 
							where a.empresa = empresa 
							  and a.num_credito = num_credito 
							  and b.fecha = fecha_cuota 
							)end),0)   														
							into vSaldoTotal				 
		from bdicred:"informix".sd_maecred a 				
		join bdicred:"informix".sd_maesdoshist b on (a.empresa = b.empresa and b.fecha =dFechaCorte  and a.num_credito = b.num_credito) 				 
		join bdinteg:"informix".si_sucursales s on ( s.empresa = a.empresa and s.sucursal = a.sucursal ) 
        where a.empresa = pEmpresa
          and a.num_credito =pNumCredito;	  
		
	Elif (vRevolvente = 0) then
	
		select (sdo_cap_insoluto     +  
				round(NVL(sdo_intereses,0) * (1+ s.iva),2) + 
				int_tra_no_exig + mto_venc_int + sdo_no_exig + mto_finan_vdo +  
				round((sdo_moratorio + sdo_contab_mora) * (1+ s.iva),2)) into vSaldoTotal
		from bdicred:"informix".sd_maecredcrd a 				
		join bdicred:"informix".sd_maesdoshistcrd b on (a.empresa = b.empresa and b.fecha =dFechaCorte and a.num_credito = b.num_credito)                  
		join bdinteg:"informix".si_sucursales s on ( s.empresa = a.empresa and s.sucursal = a.sucursal ) 
		where a.empresa = pEmpresa
          and a.num_credito =pNumCredito;
	End If;
	Let vSaldoTotal =nvl(vSaldoTotal,0);


RETURN cCodRet, vSaldoTotal;

END;


---Saldo para no generar intereses , o saldo al cierre

END PROCEDURE

DOCUMENT
'FECHA MODIFICACION: 26/12/2018',
'Modificacion : Coppel',
'ValidaciÃ³n : Marcela PÃ©rez-GM3',
'ValidaciÃ³n : Alejandro SÃ¡nchez-GM1',
'ValidaciÃ³n : Juan Olivarez-GM2',
'VoBo : Alejandro SÃ¡nchez-GM1',
'VoBo : Juan Olivarez-GM2',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_consultasaldocorte_pba1(pEmpresa  CHAR (3),pNumCredito CHAR (20), pTipoConsulta SMALLINT)
  RETURNING CHAR (5) AS CodRet, DECIMAL (14,2) AS saldototal;

--pTipoConsulta = 1  Cierre, 0 Para No generar Intereses  
--FMJ Febrero 2012
  
 -- DEFINICION DE VARIABLES --
DEFINE sSqlErr SMALLINT;
DEFINE cCodRet CHAR(5);
DEFINE vSaldoTotal DECIMAL (14,2);

DEFINE iDia_corte 	 INTEGER;
DEFINE vRevolvente	 SMALLINT;
DEFINE dFechaCorte	 DATE;
DEFINE dFechaMesiver DATE;
DEFINE dFechaCentral DATE;

LET sSqlErr = 0;
LET cCodRet = '00000';

LEt iDia_corte = 0;
LET vRevolvente =0;
LET vSaldoTotal = 0;
LET dFechaCentral =date(1); 
LET dFechaMesiver =date(1); 
LET dFechaCorte = date(1); 

BEGIN
        ON EXCEPTION SET sSqlErr
            LET cCodRet = sSqlErr;
            RETURN cCodRet, vSaldoTotal;
        END EXCEPTION;

	set lock mode to wait 3;
	set isolation to dirty read;

	SELECT {+INDEX(sd_fechas idx_sdfechas)} fecha_hoy
  	  INTO dFechaCentral
      FROM bdicred:sd_fechas
     WHERE empresa = pEmpresa;

	SELECT dia_corte  INTO iDia_corte  
	  FROM bdicred:sd_maecredanexo     
	 WHERE empresa = pEmpresa  AND num_credito = pNumCredito;		

	LET iDia_corte = nvl(iDia_corte,0);
	 
	if iDia_corte <> 0 then   	
	  Let vRevolvente = 1;	
	  if day(dFechaCentral) <= iDia_corte then
			let dFechaCorte = mdy(month(dFechaCentral),iDia_corte,year(dFechaCentral)) - 1 units month;
		else
			let dFechaCorte = mdy(month(dFechaCentral),iDia_corte,year(dFechaCentral));
		end if;	  
    else     
		Let vRevolvente = 0;

        SELECT nvl(dia_corte,0)  INTO iDia_corte  
          FROM bdicred:sd_maecredanexocrd     
         WHERE empresa = pEmpresa  
           AND num_credito = pNumCredito;	
	LET iDia_corte = nvl(iDia_corte,0);

        EXECUTE PROCEDURE "informix".sp_fecha_plazo(pEmpresa,iDia_corte)
        into cCodRet, dFechaMesiver, dFechaCorte;

        if (cCodRet <> '00000') then
          let cCodRet = '00002';  -- ERROR EN RUTINA DE CALCULO DE MESIVERSARIO
          let vSaldoTotal = 0; 
		  let vRevolvente = 2; 
       end if;

	end if;	
		
	If  ( iDia_corte =0) and (nvl(dFechaCorte,date(1)) =date(1)) then   
          let cCodRet = '00001';  -- CREDITO NO EXISTE
          let vSaldoTotal = 0; 
		  let vRevolvente = 2; 	
    end if;
	
	If (vRevolvente = 1) Then
	
		select nvl(( case when (nvl(sdo_cap_insoluto,0) < 0) then decode( pTipoConsulta,1, nvl(sdo_cap_insoluto,0),0)  
		             else  Nvl(sdo_cap_insoluto,0) +  Nvl(round((sdo_moratorio + sdo_contab_mora) * (1+ s.iva),2),0)  +			
					 
							case when (NVL(int_tra_no_exig,0) -NVL(sdo_acum_mes_int,0) >=0) then  ---
									  (NVL(int_tra_no_exig,0) -NVL(sdo_acum_mes_int,0)) else NVL(int_tra_no_exig,0) end + 
									  
						   (select nvl(campo_trabajo1 ,0)
							from bdicred:sd_amortiza_credito 
							where a.empresa = empresa 
							  and a.num_credito = num_credito 
							  and b.fecha = fecha_cuota 
							)end),0)   														
							into vSaldoTotal				 
		from bdicred:sd_maecred a 				
		join bdicred:sd_maesdoshist b on (a.empresa = b.empresa and b.fecha =dFechaCorte  and a.num_credito = b.num_credito) 				 
		join bdinteg:si_sucursales s on ( s.empresa = a.empresa and s.sucursal = a.sucursal ) 
        where a.empresa = pEmpresa
          and a.num_credito =pNumCredito;	  
		
	Elif (vRevolvente = 0) then
	
		select (sdo_cap_insoluto     +  
				round(NVL(sdo_intereses,0) * (1+ s.iva),2) + 
				int_tra_no_exig + mto_venc_int + sdo_no_exig + mto_finan_vdo +  
				round((sdo_moratorio + sdo_contab_mora) * (1+ s.iva),2)) into vSaldoTotal
		from bdicred:sd_maecredcrd a 				
		join bdicred:sd_maesdoshistcrd b on (a.empresa = b.empresa and b.fecha =dFechaCorte and a.num_credito = b.num_credito)                  
		join bdinteg:si_sucursales s on ( s.empresa = a.empresa and s.sucursal = a.sucursal ) 
		where a.empresa = pEmpresa
          and a.num_credito =pNumCredito;
	End If;
	Let vSaldoTotal =nvl(vSaldoTotal,0);


RETURN cCodRet, vSaldoTotal;

END;


---Saldo para no generar intereses , o saldo al cierre

END PROCEDURE;
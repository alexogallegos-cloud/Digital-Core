CREATE PROCEDURE "informix".sp_val_datos_promo (pSucursal CHAR(4), pEjecutivo CHAR(8), pOrigenPromo	SMALLINT, pNumCredito CHAR(20), pNumTarjeta CHAR(20), pMonto DECIMAL(18,2))
-- pOrigenPromo =  1 ventanilla, 2 promotoria
-- pOrigenPromo =  1 ventanilla, 2 COMPRAS , 3 SALDOS  <- FMV 4sep14, El visual de promotoria toma 2 y 3 con esos valores.

RETURNING
	CHAR(5) 	AS cod_ret_suc,
	CHAR(5) 	AS cod_ret,
	CHAR(80) 	AS desc_ret,
	SMALLINT	AS tipo_promocion,  -- 1-Efectivo, 2-Compras  y 3-Saldo,
	CHAR(50)	AS nombre_promo,
	SMALLINT	AS valido,  -- valido---> 0 No valido,  1 Valido
    DECIMAL(18,2)    AS dPlazoSeis, --DSB20140619
	DECIMAL(18,2)    AS dPlazoDoce, --DSB20140619
	DECIMAL(18,2)    AS dPlazoDiezocho, --DSB20140619
	SMALLINT	AS numero_promocion; --DSB20140818
	---DECLARACIONES
    DEFINE iSqlErr				INTEGER;
    DEFINE iIsamErr				INTEGER;
    DEFINE cErrorInfo			CHAR(80);
	DEFINE cCodRetSuc			CHAR(5);
    DEFINE cCodRet				CHAR(5);
    DEFINE cMensajeRet			CHAR(80);
	DEFINE dtFechaHoy			DATE;
	DEFINE sValido				SMALLINT;
	DEFINE dValorMinDiferir		DECIMAL(18,2);
	DEFINE sNumPromocion		SMALLINT;
    DEFINE pi_NumPromocion      SMALLINT;
	DEFINE sTipoPromocion		SMALLINT;
	DEFINE cDescPromocion		CHAR(50);
	DEFINE sPromComprasVigente	SMALLINT;
	DEFINE sPromSaldoVigente	SMALLINT;
	DEFINE sCteProspectoCompras	SMALLINT;
    DEFINE sPromEfectivoVigente SMALLINT;
	DEFINE iPlazo               INTEGER;  --DSB20140619
	DEFINE dPlazoSeis           DECIMAL(18,2); --DSB20140619
	DEFINE dPlazoDoce           DECIMAL(18,2); --DSB20140619
	DEFINE dPlazoDiezocho       DECIMAL(18,2); --DSB20140619
	DEFINE dValidaMonto         DECIMAL(18,2); --DSB20140818
	DEFINE iNumeroPromocion     SMALLINT; --DSB20140818

	DEFINE sCteProspectoSaldo	SMALLINT;
	DEFINE sCteProspectoEfec	SMALLINT;
	DEFINE sBandReturn			SMALLINT;
	DEFINE sContadorExists		SMALLINT;
	---VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE LA PROYECCION
	DEFINE cCodRetPP			CHAR(5);
    DEFINE cMensajeRetPP		CHAR(80);
	DEFINE dTotalPagarPP		DECIMAL(18,2);
	DEFINE sNumPlazoPP			SMALLINT;
	DEFINE dPagoMensualPP		DECIMAL(18,2);
	DEFINE dInteresIvaPP		DECIMAL(18,2);
	DEFINE dSaldoTdcPP			DECIMAL(18,2);
	DEFINE cFolioPromoPP		CHAR(16);
	DEFINE cFolioPromo			CHAR(16);	
	DEFINE sPromoSucCaja        SMALLINT; --FMV 12nov13
	
	--VARIABLES DEFINIDAS DEL FOLIO 1461--
	-----------CENTRO: 230202----------01/10/2014
	DEFINE sNumPromoAct  SMALLINT;
	DEFINE sBandCredsAct SMALLINT;
	DEFINE iBanCompras   INTEGER;
	DEFINE iBanSaldos    INTEGER;
	
	
	----- DECLARACION DE VARIABLES sp_consulta_saldos_general.sql-----
	DEFINE cCsg_codigo_ret CHAR(6);
	DEFINE cCsg_mensaje_ret CHAR(80);
	DEFINE cCsg_num_credito CHAR(20);
	DEFINE cCsg_cod_tipcred CHAR(2);
	DEFINE dtCsg_fec_origen DATE;
	DEFINE dtCsg_fec_prox_pago DATE;
	DEFINE dcmCsg_pago_min DECIMAL(18,2);
	DEFINE dtCsg_fec_ult_pago DATE;
	DEFINE iCsg_plazo INTEGER;
	DEFINE iCsg_pagos_realizados INTEGER;
	DEFINE dcmCsg_linea_otorgada DECIMAL(18,2);
	DEFINE dcmCsg_tasa_interes DECIMAL(9,6);
	DEFINE dCsg_tasa_moratorios DECIMAL(9,6);
	DEFINE dCsg_monto_sbc DECIMAL(14,2);
	DEFINE dcmCsg_cap_vig DECIMAL(18,2);
	DEFINE dcmCsg_cap_trans DECIMAL(18,2);
	DEFINE dcmCsg_cap_vdo_exig DECIMAL(18,2);
	DEFINE dcmCsg_cap_vdo_no_exig DECIMAL(18,2);
	DEFINE dcmCsg_sdo_act_total_cap DECIMAL(18,2);
	DEFINE dcmCsg_int_vig DECIMAL(18,2);
	DEFINE dcmCsg_int_vdo DECIMAL(18,2);
	DEFINE dcmCsg_int_moratorios DECIMAL(18,2);
	DEFINE dcmCsg_int_mes DECIMAL(18,2);
	DEFINE dcmCsg_sdo_act_total_int DECIMAL(18,2);
	DEFINE dcmCsg_iva_int_vig DECIMAL(18,2);
	DEFINE dcmCsg_iva_int_vdo DECIMAL(18,2);
	DEFINE dcmCsg_iva_int_moratorios DECIMAL(18,2);
	DEFINE dcmCsg_iva_int_mes DECIMAL(18,2);
	DEFINE dcmCsg_sdo_act_total_iva DECIMAL(18,2);
	DEFINE dcmCsg_com_pend DECIMAL(18,2);
	DEFINE dcmCsg_iva_com DECIMAL(18,2);
	DEFINE dcmCsg_sdo_retenido DECIMAL(18,2);
	DEFINE dcmCsg_tot_liquidacion DECIMAL(18,2);
	DEFINE dcmCsg_int_devengado DECIMAL(18,2);
	DEFINE dcmCsg_iva_int_devengado DECIMAL(18,2);
	DEFINE dcmCsg_linea_disp DECIMAL(18,2);
	DEFINE dcmCsg_pagos_vdos DECIMAL(18,2);
	DEFINE cCsg_desc_status_cred CHAR(60);
	DEFINE iCsg_id_bloqueo_cred INTEGER;
	DEFINE cCsg_bloqueo_cta CHAR(60);
	DEFINE cCsg_id_causa_bloq_cred CHAR(3);
	DEFINE cCsg_causa_bloqueo_cta CHAR(50);
	DEFINE cCsg_id_sit_esp_cte CHAR(75);
	DEFINE iCsg_id_causa_esp_cte INTEGER;
	DEFINE cCsg_sit_esp_cte CHAR(75);
	DEFINE cCsg_id_sit_esp_cred CHAR(1);
	DEFINE iCsg_id_causa_esp_cred INTEGER;
	DEFINE cCsg_sit_esp_cred CHAR(75);
	----------------------------------------------------------------------

	---INICIALIZACIONES
	LET iSqlErr				= 0;
	LET iIsamErr			= 0;
	LET cErrorInfo			= '';
	LET cCodRetSuc			= '00000';
	LET cCodRet				= '00000';
	LET cMensajeRet			= 'PROCESO EXITOSO';
	LET dtFechaHoy			= DATE(1);
	LET sValido				= 0;
	LET dValorMinDiferir	= 0.0;
	LET sTipoPromocion		= 0;
	LET cDescPromocion		= '';
	LET sPromComprasVigente	= 0;
	LET sPromSaldoVigente	= 0;
	LET sCteProspectoCompras = 0;
    LET sPromEfectivoVigente = 0; --FMV 12nov13
	LET sCteProspectoSaldo   = 0;
    LET sCteProspectoEfec    = 0; -->FMV 29Ago14
	LET sNumPromocion		= 0;
    LET pi_NumPromocion     = 0;
	LET sBandReturn			= 0;
	LET iPlazo              = 0; --DSB20140619
	LET dPlazoSeis          = 0.00; --DSB20140619
	LET dPlazoDoce          = 0.00; --DSB20140619
	LET dPlazoDiezocho      = 0.00; --DSB20140619
	LET dValidaMonto        = pMonto; --DSB20140818
	LET iNumeroPromocion    = 0; --DSB20140818
	LET sContadorExists  	= 0;
	---VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE LA PROYECCION
	LET cCodRetPP			= '';
    LET cMensajeRetPP		= '';
	LET dTotalPagarPP		= 0.0;
	LET sNumPlazoPP			= 0;
	LET dPagoMensualPP		= 0.0;
	LET dInteresIvaPP		= 0.0;
	LET dSaldoTdcPP			= 0.0;
	LET cFolioPromoPP		= '';
	LET cFolioPromo			= '';	
	LET sPromoSucCaja       = 0;
    ------ INICIALIZACION DE VARIABLES sp_consulta_saldos_general.sql-------
	LET cCsg_codigo_ret = '000001';
	LET cCsg_mensaje_ret = '';
	LET cCsg_num_credito = '';
	LET cCsg_cod_tipcred = '';
	LET dtCsg_fec_origen = '';
	LET dtCsg_fec_prox_pago = '';
	LET dcmCsg_pago_min = 0.00;
	LET dtCsg_fec_ult_pago = '';
	LET iCsg_plazo = 0;
	LET iCsg_pagos_realizados = 0;
	LET dcmCsg_linea_otorgada = 0.00;
	LET dcmCsg_tasa_interes = 0.00;
	LET dCsg_tasa_moratorios = 0.00;
	LET dCsg_monto_sbc = 0.00;
	LET dcmCsg_cap_vig = 0.00;
	LET dcmCsg_cap_trans = 0.00;
	LET dcmCsg_cap_vdo_exig = 0.00;
	LET dcmCsg_cap_vdo_no_exig = 0.00;
	LET dcmCsg_sdo_act_total_cap = 0.00;
	LET dcmCsg_int_vig = 0.00;
	LET dcmCsg_int_vdo = 0.00;
	LET dcmCsg_int_moratorios = 0.00;
	LET dcmCsg_int_mes = 0.00;
	LET dcmCsg_sdo_act_total_int = 0.00;
	LET dcmCsg_iva_int_vig = 0.00;
	LET dcmCsg_iva_int_vdo = 0.00;
	LET dcmCsg_iva_int_moratorios = 0.00;
	LET dcmCsg_iva_int_mes = 0.00;
	LET dcmCsg_sdo_act_total_iva = 0.00;
	LET dcmCsg_com_pend = 0.00;
	LET dcmCsg_iva_com = 0.00;
	LET dcmCsg_sdo_retenido = 0.00;
	LET dcmCsg_tot_liquidacion = 0.00;
	LET dcmCsg_int_devengado = 0.00;
	LET dcmCsg_iva_int_devengado = 0.00;
	LET dcmCsg_linea_disp = 0.00;
	LET dcmCsg_pagos_vdos = 0.00;
	LET cCsg_desc_status_cred = '';
	LET iCsg_id_bloqueo_cred = 0;
	LET cCsg_bloqueo_cta = '';
	LET cCsg_id_causa_bloq_cred = '';
	LET cCsg_causa_bloqueo_cta = '';
	LET cCsg_id_sit_esp_cte = '';
	LET iCsg_id_causa_esp_cte = 0;
	LET cCsg_sit_esp_cte = '';
	LET cCsg_id_sit_esp_cred = '';
	LET iCsg_id_causa_esp_cred = 0;
	LET cCsg_sit_esp_cred = '';
	
	--INICIALIZACIONES DE VARIABLES DEL FOLIO 1461---
	---CENTRO:230202---01/10/2014----
	LET sNumPromoAct = 0;
	LET sBandCredsAct = 0;
	LET iBanCompras = 0;
	LET iBanSaldos  = 0;
	
	------------------------------------------------------------------------
BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			LET cMensajeRet = cErrorInfo;
			RETURN cCodRetSuc, cCodRet, NVL(cMensajeRet,''), NVL(sTipoPromocion,0), NVL(cDescPromocion,''), NVL(sValido,0), NVL(dPlazoSeis,0.00), NVL(dPlazoDoce,0.00), NVL(dPlazoDiezocho,0.00), NVL(iNumeroPromocion,0); --DSB20140818
		END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	--LAS SIG. 2 LINEAS COMENTADAS EN FOLIO 1461; CENTRO:230202--
	 --SET DEBUG FILE TO '/tmp/sp_val_datos_promo_mod5.out';
	 --TRACE ON;
	 
	-- VALIDA QUE LOS PARAMETROS NO VENGAN VACIOS
    IF NVL(pEjecutivo,'') = '' OR NVL(pSucursal,'') = '' OR pOrigenPromo IS NULL
        OR (NVL(pNumCredito,'') = '' AND NVL(pNumTarjeta,'') = '') OR pMonto IS NULL THEN
		LET cCodRet = '00002';
		LET cMensajeRet = 'FALTA UNO O MAS PARAMETROS';
		RETURN cCodRetSuc, cCodRet, NVL(cMensajeRet,''), NVL(sTipoPromocion,0), NVL(cDescPromocion,''), NVL(sValido,0), NVL(dPlazoSeis,0.00), NVL(dPlazoDoce,0.00), NVL(dPlazoDiezocho,0.00), NVL(iNumeroPromocion,0); --DSB20140818
    END IF;
	-- OBTIENE LA FECHA DE HOY DEL SISTEMA DE CREDITO
	SELECT fecha_hoy
	INTO dtFechaHoy
	FROM 'informix'.sd_fechas
    WHERE empresa = '001';

	-- VALIDA EL TIPO DE PROMOCION
	IF cCodRet = '00000' AND pOrigenPromo NOT IN (1,2) THEN
		LET cCodRet = '00004';
		LET cMensajeRet = 'FALTA UNO O MAS PARAMETROS';
		RETURN cCodRetSuc, cCodRet, NVL(cMensajeRet,''), NVL(sTipoPromocion,0), NVL(cDescPromocion,''), NVL(sValido,0), NVL(dPlazoSeis,0.00), NVL(dPlazoDoce,0.00), NVL(dPlazoDiezocho,0.00), NVL(iNumeroPromocion,0); --DSB20140818
	END IF;

	LET sContadorExists = 0;
	SELECT COUNT(*) INTO sContadorExists 
	  FROM "informix".sd_promocion WHERE activo = 1 AND dtFechaHoy BETWEEN fechaini_promo AND fechafin_promo; 
		
    --IF () = 0 THEN
	IF sContadorExists = 0 THEN
		LET cCodRet = '00001';
		LET cMensajeRet = 'NO EXISTEN PROMOCIONES VIGENTES';
		RETURN cCodRetSuc, cCodRet, NVL(cMensajeRet,''), NVL(sTipoPromocion,0), NVL(cDescPromocion,''), NVL(sValido,0), NVL(dPlazoSeis,0.00), NVL(dPlazoDoce,0.00), NVL(dPlazoDiezocho,0.00), NVL(iNumeroPromocion,0); --DSB20140818
    END IF;

 	-- VALIDA QUE AL MENOS RECIBA EL NUMERO DE CREDITO O LA TARJETA
	IF cCodRet = '00000' /*AND (NVL(pNumCredito,'') = '' OR NVL(pNumTarjeta,'') = '' )*/ THEN
		IF NVL(pNumCredito,'') <> '' THEN
			SELECT a.num_tarjeta
			INTO pNumTarjeta
			FROM 'informix'.sd_tarjeta a
			INNER JOIN bdicred:sd_maecred b on (a.empresa = b.empresa and a.num_credito = b.num_credito)
			INNER JOIN bdicred:sd_maesdos mae on (a.num_credito = mae.num_credito)
			WHERE a.empresa = '001'
              AND a.num_credito = pNumCredito
			  AND a.num_tarjeta = pNumTarjeta --INC 25011 PAGOS FIJOS
              AND a.tipo_tarjeta = 'T'
              AND a.status_tar = 'A'
              AND b.status_cred IN ('AA','E1')
			  AND (mae.monto_vencido + mae.mto_venc_trasp) = 0;

			IF NVL(pNumTarjeta,'') = '' THEN
				LET cCodRet = '00001';
				LET cMensajeRet = 'NUMERO DE CREDITO NO ESTA VIGENTE O NO ES VALIDO';
				RETURN cCodRetSuc, cCodRet, NVL(cMensajeRet,''), NVL(sTipoPromocion,0), NVL(cDescPromocion,''), NVL(sValido,0), NVL(dPlazoSeis,0.00), NVL(dPlazoDoce,0.00), NVL(dPlazoDiezocho,0.00), NVL(iNumeroPromocion,0); --DSB20140818
			END IF;

		ELIF NVL(pNumTarjeta,'') <> '' THEN

           SELECT a.num_credito
		  	 INTO pNumCredito
			 FROM "informix".sd_tarjeta a 
			INNER JOIN bdicred:sd_maecred b on (a.empresa = b.empresa and a.num_credito = b.num_credito)
			INNER JOIN bdicred:sd_maesdos mae on (a.num_credito = mae.num_credito)
			WHERE a.empresa = '001'
              AND a.num_tarjeta = pNumTarjeta
              AND a.tipo_tarjeta = 'T'
              AND a.status_tar = 'A'
              AND b.status_cred IN ('AA','E1')
			  AND (mae.monto_vencido + mae.mto_venc_trasp) = 0;
			  

			IF NVL(pNumCredito,'') = '' THEN
				LET cCodRet = '00001';
				LET cMensajeRet = 'NUMERO DE TARJETA NO ES VALIDO O SU CREDITO NO ESTA VIGENTE';
				RETURN cCodRetSuc, cCodRet, NVL(cMensajeRet,''), NVL(sTipoPromocion,0), NVL(cDescPromocion,''), NVL(sValido,0), NVL(dPlazoSeis,0.00), NVL(dPlazoDoce,0.00), NVL(dPlazoDiezocho,0.00), NVL(iNumeroPromocion,0); --DSB20140818
			END IF;
		END IF;
	END IF;


	--*** VALOR DE PARAMETRO 901 ESTA POR MIENTRAS
	-- OBTIENE EL VALOR MINIMO CONTEMPLADO PARA EL MONTO A DIFERIR EN LAS PROMOCIONES DE CREDISOLUCION
	SELECT TRIM(valor)::DECIMAL(18,2)
	  INTO dValorMinDiferir
      FROM 'informix'.sd_param
	 WHERE cod_param  = '029';
        IF dValorMinDiferir IS NULL THEN
            LET cCodRet = '00005';
            LET cMensajeRet = 'ERROR AL OBTENER EL PARAMETRO DEL VALOR MINIMO A DIFERIR';
        END IF;
	-- VALIDA SI EL ORIGEN DE LA PROMOCION ES EN VENTANILLA
	IF cCodRet = '00000' AND pOrigenPromo = 1 THEN

        --FMV 7nov13: Validar que la CampaÃ±a especial, sea la 1a. en el filtro de credisoluciones
		-- VALIDA SI LA PROMOCION DE CREDISOLUCION CAMPAÃA ESPECIAL, ESQUEMA EFECTIVO ESTA VIGENTE
		LET sContadorExists = 0;
		SELECT count(num_promo) INTO sContadorExists FROM "informix".sd_promocion  
		 WHERE num_promo = 7 AND activo = 1 AND dtFechaHoy >= fechaini_promo AND dtFechaHoy <= fechafin_promo;
						  
		--IF sPromoSucCaja = 0 AND cCodRet = '00000' AND NOT EXISTS     () THEN                          
		IF sPromoSucCaja = 0 AND cCodRet = '00000' AND sContadorExists = 0 THEN
			LET cCodRet = '00001';
			LET cMensajeRet = 'LA PROMOCION 7 NO SE ENCUENTRA VIGENTE';
        ELSE
            IF sPromoSucCaja = 0 THEN
               LET sPromoSucCaja = 7;
               LET cCodRet = '00000';
               LET cMensajeRet = 'PROCESO EXITOSO';
               LET sCteProspectoEfec = 7;
               LET sNumPromocion = sCteProspectoEfec;
            END IF;
            -- VALIDA QUE SEA UN CLIENTE PROSPECTO PARA LA PROMOCION DE CREDISOLUCION EFECTIVO
			LET sContadorExists = 0;
			SELECT count(num_credito) INTO sContadorExists FROM 'informix'.sd_prospectos
			 WHERE num_promo = 7 AND num_credito = pNumCredito AND dtFechaHoy >= fecha_ini AND dtFechaHoy <= fecha_fin;
						
            --IF sPromoSucCaja = 7 AND NOT EXISTS () THEN
			IF sPromoSucCaja = 7 AND sContadorExists = 0 THEN
                LET cCodRet = '00001';
                LET cMensajeRet = 'EL CLIENTE NO ES PROSPECTO PARA LA PROMOCION 7';
                LET sPromoSucCaja = 0;
                LET sCteProspectoEfec = 0;    
                LET sNumPromocion = sCteProspectoEfec;        
            END IF;
		END IF;

 		-- VALIDA SI LA PROMOCION DE CREDISOLUCION CAMPAÃA TEMPORAL, ESQUEMA EFECTIVO ESTA VIGENTE
         IF sPromoSucCaja = 0 AND cCodRet = '00001' THEN
		 
				LET sContadorExists = 0;
				SELECT count(b.num_promo) INTO sContadorExists FROM bdinteg:"informix".si_sucursal_promocion a, "informix".sd_promocion b
				 WHERE a.empresa = b.empresa AND a.promocion = b.num_promo AND b.num_promo = 4
				   AND b.activo = 1 AND dtFechaHoy >= b.fechaini_promo AND dtFechaHoy <= b.fechafin_promo AND a.sucursal = pSucursal;
						  
                --IF NOT EXISTS () THEN
				IF sContadorExists = 0 THEN
                    LET cCodRet = '00001';
                    LET cMensajeRet = 'LA PROMOCION 4 NO SE ENCUENTRA VIGENTE';
                ELSE
                    IF sPromoSucCaja = 0 THEN
                       LET sPromoSucCaja = 4;
                       LET cCodRet = '00000';
                       LET cMensajeRet = 'PROCESO EXITOSO';
                       LET sCteProspectoEfec = 4;
                       LET sNumPromocion = sCteProspectoEfec;
                    END IF;
                END IF;
         END IF;

		-- VALIDA SI LA PROMOCION DE CREDISOLUCION CAMPAÃA PERMANENTE, ESQUEMA EFECTIVO ESTA VIGENTE
         IF sPromoSucCaja = 0 AND cCodRet = '00001' THEN
				LET sContadorExists = 0;
				SELECT count(b.num_promo) INTO sContadorExists FROM bdinteg:"informix".si_sucursal_promocion a, "informix".sd_promocion b
				 WHERE a.empresa = b.empresa AND a.promocion = b.num_promo	AND b.num_promo = 1 AND b.activo = 1
				   AND dtFechaHoy >= b.fechaini_promo AND dtFechaHoy <= b.fechafin_promo AND a.sucursal = pSucursal;

                --IF NOT EXISTS () THEN
				IF sContadorExists = 0 THEN
                    LET cCodRet = '00001';
                    LET cMensajeRet = 'LA PROMOCION 1 NO SE ENCUENTRA VIGENTE';
                ELSE
                    IF sPromoSucCaja = 0 THEN
                        LET sPromoSucCaja = 1;
                        LET cCodRet = '00000';
                        LET cMensajeRet = 'PROCESO EXITOSO';
                        LET sCteProspectoEfec = 1;
                        LET sNumPromocion = sCteProspectoEfec;
                    END IF;
                END IF;
         END IF;

	   IF cCodRet = '00000' THEN			--INICIA DSB20140619,--DSB20140818	 
		 
			EXECUTE PROCEDURE "informix".sp_consulta_saldos_general('001',pNumCredito) --INICIA --DSB20140818
			INTO  cCsg_codigo_ret,cCsg_mensaje_ret,cCsg_num_credito,cCsg_cod_tipcred,dtCsg_fec_origen,dtCsg_fec_prox_pago,dcmCsg_pago_min,
				dtCsg_fec_ult_pago,iCsg_plazo,iCsg_pagos_realizados,dcmCsg_linea_otorgada,dcmCsg_tasa_interes,dCsg_tasa_moratorios,
				dCsg_monto_sbc,dcmCsg_cap_vig,dcmCsg_cap_trans,dcmCsg_cap_vdo_exig,dcmCsg_cap_vdo_no_exig,dcmCsg_sdo_act_total_cap,dcmCsg_int_vig,
				dcmCsg_int_vdo,dcmCsg_int_moratorios,dcmCsg_int_mes,dcmCsg_sdo_act_total_int,dcmCsg_iva_int_vig,dcmCsg_iva_int_vdo,dcmCsg_iva_int_moratorios,
				dcmCsg_iva_int_mes,dcmCsg_sdo_act_total_iva,dcmCsg_com_pend,dcmCsg_iva_com,dcmCsg_sdo_retenido,dcmCsg_tot_liquidacion,dcmCsg_int_devengado,
				dcmCsg_iva_int_devengado,dcmCsg_linea_disp,dcmCsg_pagos_vdos,cCsg_desc_status_cred,iCsg_id_bloqueo_cred,cCsg_bloqueo_cta,
				cCsg_id_causa_bloq_cred,cCsg_causa_bloqueo_cta,cCsg_id_sit_esp_cte,iCsg_id_causa_esp_cte,cCsg_sit_esp_cte,cCsg_id_sit_esp_cred,
				iCsg_id_causa_esp_cred,cCsg_sit_esp_cred;
		    
			IF   cCsg_codigo_ret <> '000000' THEN
				LET cCodRet = '00008';
				LET cMensajeRet = 'ERROR EN EL SP CONSULTA SALDOS GENERAL';	  
			ELSE 
				IF 	dcmCsg_cap_vig < 0 THEN
					 LET dValidaMonto = pMonto + dcmCsg_cap_vig;
				END IF;	
				
				-- VALIDA QUE EL MONTO A DIFERIR SEA MAYOR AL VALOR MINIMO DE LA PROMOCION
				--IF cCodRet = '00000' AND pMonto < dValorMinDiferir THEN
				IF dValidaMonto < dValorMinDiferir THEN	
					LET cCodRet = '00001';
					LET cMensajeRet = 'EL MONTO A DIFERIR ES MENOR AL VALOR MINIMO DE LA PROMOCION';
				END IF;
            END IF;
		END IF; --TERMINA --DSB20140818	

	-- VALIDA SI EL ORIGEN DE LA PROMOCION ES EN PROMOTORIA
	ELIF cCodRet = '00000' AND pOrigenPromo = 2 THEN
		-- VALIDA SI LA PROMOCION DE CREDISOLUCION COMPRAS, ESQUEMA ESPECIAL ESTA VIGENTE
		LET sContadorExists = 0;
		SELECT count(num_promo) INTO sContadorExists FROM "informix".sd_promocion
		 WHERE num_promo = 8 AND activo = 1 AND dtFechaHoy >= fechaini_promo AND dtFechaHoy <= fechafin_promo;
						  
		--IF NOT EXISTS () THEN     
		IF sContadorExists = 0 THEN     
			LET cCodRet = '00001';
			LET cMensajeRet = 'LA PROMOCION 8 NO SE ENCUENTRA VIGENTE';
            LET sPromComprasVigente = 0;
            LET sNumPromocion = sPromComprasVigente;
		ELSE
			LET sPromComprasVigente = 8; --FMV 12nov13 toma valor del numero de promocion
			LET sContadorExists = 0;
			SELECT count(num_credito) INTO sContadorExists FROM 'informix'.sd_prospectos 
             WHERE num_promo = 8 AND num_credito = pNumCredito AND dtFechaHoy >= fecha_ini AND dtFechaHoy <= fecha_fin;
						  
			--IF cCodRet = '00000' AND sPromComprasVigente = 8 AND NOT EXISTS( ) THEN
			IF cCodRet = '00000' AND sPromComprasVigente = 8 AND sContadorExists = 0 THEN
				LET cCodRet = '00001';
				LET cMensajeRet = 'EL CLIENTE NO ES PROSPECTO PARA LA PROMOCION 8';
				LET sPromComprasVigente = 0;
                LET sNumPromocion = sPromComprasVigente;
			ELSE
				LET cCodRet = '00000';
				LET cMensajeRet = 'PROCESO EXITOSO';
                LET sPromComprasVigente = 8; --FMV 2sep14 Asigna valor final del numero de promocion
                LET sNumPromocion = sPromComprasVigente;
			END IF;
		END IF;
		-- VALIDA SI LA PROMOCION DE CREDISOLUCION COMPRAS, ESQUEMA TEMPORAL ESTA VIGENTE
		IF sPromComprasVigente = 0 AND cCodRet = '00001' AND pOrigenPromo = 2 THEN 
			LET sContadorExists = 0;
			SELECT count(b.num_promo) INTO sContadorExists FROM bdinteg:"informix".si_sucursal_promocion a, "informix".sd_promocion b
			 WHERE a.empresa = b.empresa AND a.promocion = b.num_promo AND b.num_promo = 5 AND b.activo = 1 AND dtFechaHoy >= b.fechaini_promo
			   AND dtFechaHoy <= b.fechafin_promo AND a.sucursal = pSucursal;
			
			--IF NOT EXISTS() THEN
			IF sContadorExists = 0 THEN
				LET cCodRet = '00001';
				LET cMensajeRet = 'LA PROMOCION 5 NO SE ENCUENTRA VIGENTE';
				LET sPromComprasVigente = 0;
                LET sNumPromocion = sPromComprasVigente;
			ELSE
				IF sPromComprasVigente = 0 AND cCodRet = '00001' THEN
					LET sPromComprasVigente = 5; --FMV 12nov13 toma valor del numero de promocion
					LET cCodRet = '00000';
					LET cMensajeRet = 'PROCESO EXITOSO'; 
                    LET sNumPromocion = sPromComprasVigente;
				END IF;
			END IF;
		END IF;
		-- VALIDA SI LA PROMOCION DE CREDISOLUCION COMPRAS, ESQUEMA PERMANENTE ESTA VIGENTE
		IF sPromComprasVigente = 0 AND cCodRet = '00001' AND pOrigenPromo = 2 THEN 
			LET sContadorExists = 0;
			SELECT count(b.num_promo) INTO sContadorExists FROM bdinteg:"informix".si_sucursal_promocion a, "informix".sd_promocion b
			 WHERE a.empresa = b.empresa AND a.promocion = b.num_promo AND b.num_promo = 2 AND b.activo = 1 AND dtFechaHoy >= b.fechaini_promo 
			   AND dtFechaHoy <= b.fechafin_promo AND a.sucursal = pSucursal;
			
			--IF NOT EXISTS () THEN
			IF sContadorExists = 0 THEN
				LET cCodRet = '00001'; --DSB20140818				  
				LET cMensajeRet = 'LA PROMOCION 2 NO SE ENCUENTRA VIGENTE';
				LET sPromComprasVigente = 0;
                LET sNumPromocion = sPromComprasVigente;
			ELSE
				IF sPromComprasVigente = 0 AND cCodRet = '00001' THEN
					LET sPromComprasVigente = 2;
					LET cCodRet = '00000';
					LET cMensajeRet = 'PROCESO EXITOSO'; --DSB20140818
                    LET sNumPromocion = sPromComprasVigente;
				END IF;
			END IF;
		END IF;
			LET sCteProspectoCompras = sPromComprasVigente;



--------------------------------------------------------------------------------------------------------------
		-- VALIDA SI LA PROMOCION DE CREDISOLUCION SALDO, ESQUEMA ESPECIAL TDC ESTA VIGENTE
        -- SIEMPRE Y CUANDO EL CLIENTE NO FUE CANDIDADO A COMPRAS Y NO FUE CANDIDATO A EFECTIVO
		LET sContadorExists = 0;
		SELECT count(num_promo) INTO sContadorExists FROM "informix".sd_promocion 
	     WHERE num_promo = 9 AND activo = 1 AND dtFechaHoy >= fechaini_promo AND dtFechaHoy <= fechafin_promo;
						  
		IF pOrigenPromo = 2 AND sPromSaldoVigente = 0 AND sPromComprasVigente = 0 AND  sPromoSucCaja = 0 --AND dcmCsg_tot_liquidacion >= 1000
		AND sContadorExists = 0 THEN
		--AND NOT EXISTS() THEN                          
			LET sPromSaldoVigente = 0;
			LET cCodRet = '00001';
			LET cMensajeRet = 'LA PROMOCION 9 NO SE ENCUENTRA VIGENTE';
            LET sNumPromocion = sPromSaldoVigente;
		ELSE
			IF sPromSaldoVigente =  0 AND cCodRet = '00001' THEN --DSB20140818
				LET sPromSaldoVigente = 9; --DSB20140818
				LET cCodRet = '00000';
				LET cMensajeRet = 'PROCESO EXITOSO';
                LET sNumPromocion = sPromSaldoVigente;
			END IF;
			-- VALIDA QUE SEA UN CLIENTE PROSPECTO PARA LA PROMOCION DE CREDISOLUCION EFECTIVO
			LET sContadorExists = 0;
			SELECT count(num_credito) INTO sContadorExists FROM 'informix'.sd_prospectos 
			 WHERE num_promo = 9 AND num_credito = pNumCredito AND dtFechaHoy >= fecha_ini AND dtFechaHoy <= fecha_fin;
			
			--IF sPromSaldoVigente = 9 AND NOT EXISTS() THEN
			IF sPromSaldoVigente = 9 AND sContadorExists = 0 THEN
				LET cCodRet = '00001';
				LET cMensajeRet = 'EL CLIENTE NO ES PROSPECTO PARA LA PROMOCION 9';
				LET sPromSaldoVigente = 0; 
                LET sNumPromocion = sPromSaldoVigente;
			END IF;
		END IF;
		-- VALIDA SI LA PROMOCION DE CREDISOLUCION SALDO, ESQUEMA TEMPORAL  TDC ESTA VIGENTE
		IF sPromSaldoVigente = 0 AND cCodRet = '00001' AND scteprospectocompras = 0 THEN --DSB20140818
			LET sContadorExists = 0;
			SELECT count(b.num_promo) INTO sContadorExists FROM bdinteg:"informix".si_sucursal_promocion a, "informix".sd_promocion b
			 WHERE a.empresa = b.empresa AND a.promocion = b.num_promo AND b.num_promo = 6 AND b.activo = 1 
			   AND dtFechaHoy >= b.fechaini_promo AND dtFechaHoy <= b.fechafin_promo AND a.sucursal = pSucursal;
						  
			--IF NOT EXISTS() THEN
			IF sContadorExists = 0 THEN
				LET sPromSaldoVigente = 0;
				LET cCodRet = '00001';
				LET cMensajeRet = 'LA PROMOCION 6 NO SE ENCUENTRA VIGENTE'; --DSB20140818
                LET sNumPromocion = sPromSaldoVigente;
			ELSE
				IF sPromSaldoVigente = 0 THEN --DSB20140818
					LET sPromSaldoVigente = 6;
					LET cCodRet = '00000'; 
					LET cMensajeRet = 'PROCESO EXITOSO';
                    LET sNumPromocion = sPromSaldoVigente;
				END IF;
			END IF;
		END IF;
		-- VALIDA SI LA PROMOCION DE CREDISOLUCION SALDO, ESQUEMA PERMANENTE  TDC ESTA VIGENTE
		IF sPromSaldoVigente = 0 AND cCodRet = '00001' AND scteprospectocompras = 0 THEN --DSB20140818
			LET sContadorExists = 0;
			SELECT count(b.num_promo) INTO sContadorExists FROM bdinteg:"informix".si_sucursal_promocion a, "informix".sd_promocion b
			 WHERE a.empresa = b.empresa AND a.promocion = b.num_promo AND b.num_promo = 3 AND b.activo = 1
			   AND dtFechaHoy >= b.fechaini_promo AND dtFechaHoy <= b.fechafin_promo AND a.sucursal = pSucursal;
						  
			--IF NOT EXISTS() THEN
			IF sContadorExists = 0 THEN
				LET sPromSaldoVigente = 0;
				LET cCodRet = '00001';
				LET cMensajeRet = 'LA PROMOCION 3 NO SE ENCUENTRA VIGENTE'; --DSB20140818
                LET sNumPromocion = sPromSaldoVigente;
			ELSE
				IF  sPromSaldoVigente = 0 THEN
					LET sPromSaldoVigente = 3;
					LET cCodRet = '00000';
					LET cMensajeRet = 'PROCESO EXITOSO';
                    LET sNumPromocion = sPromSaldoVigente;
				END IF;
			END IF;
		END IF;
		-- VALIDA QUE SI LAS DOS PROMOCIONES NO ESTAN VIGENTES
		IF sPromComprasVigente = 0 AND sPromSaldoVigente = 0 AND pOrigenPromo = 2 THEN
			LET cCodRet = '00001';
			LET cMensajeRet = 'LAS PROMOCIONES DE PROMOTORIA NO SE ENCUENTRAS VIGENTES';
		ELSE
			LET cCodRet = '00000';
			LET cMensajeRet = 'PROCESO EXITOSO';
		END IF;
		-- VALIDA QUE EL PRESTAMO CANDIDATO PARA LA PROMOCION DE CREDISOLUCION SALDO TDC
		-- El prestamo no debe tener ninguna de las campaÃ±as efectivo y compras para contratar saldo y viceverza
		-- -- (Cualquier campaÃ±a de efectivo y compras)( 0.- Pendiente,  2 .-Aperturado)
		LET sContadorExists = 0;
		SELECT count(num_credito) INTO sContadorExists FROM 'informix'.sd_promocion_credito   
		 WHERE empresa = '001' AND num_credito = pNumCredito AND num_promo IN (1,4,7,2,5,8) AND status IN (0,2);	-- (Cualquier campaÃ±a de efectivo y compras) 
				   
		--IF cCodRet = '00000' AND sPromSaldoVigente IN (3,6,9) AND --EXISTS () THEN
		IF cCodRet = '00000' AND sPromSaldoVigente IN (3,6,9) AND sContadorExists > 0 THEN
			LET sPromComprasVigente = 0; --DSB20140818
			LET sCteProspectoCompras = 0; --DSB20140818
			LET cCodRet = '00001'; --DSB20140818
			LET cMensajeRet = 'YA TIENE PROMOCIONES CONTRATADAS'; --DSB20140818
		END IF;
	END IF;

	
	--folio 1461 
	FOREACH
		SELECT num_promo 
		INTO  sNumPromoAct
		FROM 'informix'.sd_promocion_credito 
		WHERE empresa = '001' 
		AND num_credito = pNumCredito
		AND status IN (0,2)
   
		--TIENE CREDISOLUCIONES SALDO
		IF NVL(sNumPromoAct,0) in (3,6,9) THEN

			LET sCteProspectoSaldo = 0;
			LET sPromSaldoVigente = 0;		
			LET sCteProspectoCompras = 0;
			LET sCteProspectoSaldo = 0;
			LET sPromSaldoVigente = 0;
			LET cCodRet = '00003';
			LET cMensajeRet = 'EL CLIENTE YA CUENTA CON UNA CREDISOLUCION DE SALDO';

			--TIENE CREDISOLUCIONES COMPRAS
		ELIF NVL(sNumPromoAct,0) in (2,5,8)THEN
			LET sBandCredsAct =1;
			LET sCteProspectoCompras = 1;
			LET sCteProspectoSaldo = 0;
			LET cCodRet = '00001';
			LET cMensajeRet = 'EL CLIENTE YA CUENTA CON UNA CREDISOLUCION DE COMPRA';
			
			--TIENE CREDISOLUCIONES EFECTIVO
		ELIF NVL(sNumPromoAct,0) in (1,4,7)THEN
			LET sBandCredsAct =1;
			LET sCteProspectoCompras = 1;
			LET sCteProspectoSaldo = 0;
			LET cCodRet = '00001';
			LET cMensajeRet = 'EL CLIENTE YA CUENTA CON UNA CREDISOLUCION DE EFECTIVO';
		END IF
		
	END FOREACH
	
	
	-- NO TIENE CREDISOLUCIONES ACTIVAS Y VALIDA SI EXISTEN LAS PROMOcIONES ACTIVAS EN LA SUCURSAL.
	IF DBINFO("sqlca.sqlerrd2") = 0 THEN
	
		LET sCteProspectoCompras = 1;
		LET sCteProspectoSaldo = 1;	
		
		IF sPromSaldoVigente = 0 THEN
			SELECT LIMIT 1 a.promocion 
			INTO sPromSaldoVigente
			FROM bdinteg:"informix".si_sucursal_promocion a,
					"informix".sd_promocion b 
			WHERE a.empresa = b.empresa 
			AND a.sucursal = pSucursal
			AND a.promocion= b.num_promo
			AND dtFechaHoy >= b.fechaini_promo
            AND dtFechaHoy <= b.fechafin_promo
			AND b.num_promo in (3,6,9)
			AND b.activo= 1;		
            
			IF sPromSaldoVigente IS NULL THEN 
			    LET sPromSaldoVigente = 0;
				LET sCteProspectoSaldo = 0;
            END IF;
			
		END IF
		IF sPromComprasVigente = 0 THEN
			SELECT LIMIT 1 a.promocion 
			INTO sPromComprasVigente
			FROM bdinteg:"informix".si_sucursal_promocion a,
					"informix".sd_promocion b 
			WHERE a.empresa = b.empresa 
			AND a.sucursal = pSucursal
			AND a.promocion= b.num_promo
			AND dtFechaHoy >= b.fechaini_promo
            AND dtFechaHoy <= b.fechafin_promo
			AND b.num_promo in (2,5,8)
			AND b.activo= 1;

            IF sPromComprasVigente IS NULL THEN 
			    LET sPromComprasVigente = 0;
				LET sCteProspectoCompras = 0;
            END IF;
		END IF

		IF sPromSaldoVigente = 9 THEN
			LET sContadorExists = 0;
			SELECT count(num_credito) INTO sContadorExists FROM 'informix'.sd_prospectos
			 WHERE num_promo = 9 AND num_credito = pNumCredito AND dtFechaHoy >= fecha_ini AND dtFechaHoy <= fecha_fin;
			
			--IF NOT EXISTS() THEN
			IF sContadorExists = 0 THEN
				LET sCteProspectoSaldo = 0;	
		    END IF;
        END IF;
		
		IF sPromComprasVigente = 8 THEN
			LET sContadorExists = 0;
			SELECT count(num_credito) INTO sContadorExists FROM 'informix'.sd_prospectos
			 WHERE num_promo = 8 AND num_credito = pNumCredito AND dtFechaHoy >= fecha_ini AND dtFechaHoy <= fecha_fin;
			 
			--IF NOT EXISTS() THEN
			IF sContadorExists = 0 THEN
				LET sCteProspectoCompras = 0;	
		    END IF;
        END IF;
		
		LET sBandCredsAct = 0;
--		LET cCodRet = '00000';
	
	END IF


	-- VALIDA QUE NO TENGA INVITACION VIGENTE PARA CONTRATAR VIA SMS
	IF ( sCteProspectoSaldo = 1 OR sCteProspectoCompras = 1 ) AND cCodRet = '00000' THEN		-- Candidato a saldos. Valida invitacion de cualquier campaÃ±a, ya que saldos no convive con otras campaÃ±as
	
		LET sContadorExists = 0;
		SELECT count(num_credito) INTO sContadorExists 
		  FROM bdicred:sd_promocion_credito_sms WHERE num_credito = pNumCredito AND tipo_sms in ('0','1','2','3');
		IF sContadorExists > 0 THEN
			LET cCodRet = '00001';
			LET cMensajeRet = 'EL CLIENTE CUENTA CON INVITACION SMS ACTIVA';		
		END IF;
	END IF;


    -- Se comenta por que ya no es necesario con las validaciones anteriores.   
	--	IF  cCodRet = '00000' AND sPromSaldoVigente NOT IN (3,6,9) THEN  --INICIA DSB20140818
	--	    IF (sPromoSucCaja IN (1,4,7) OR sPromComprasVigente IN (2,5,8)) AND EXISTS --NOT EXISTS
	--		       (SELECT num_credito 
	--                  FROM 'informix'.sd_promocion_credito 
	--                 WHERE empresa = '001' 
	--				   AND num_credito = pNumCredito
	--				   AND num_promo IN (3,6,9)  -- (Cualquier campaÃ±a de saldos)
	--				   AND status IN (0,2)) THEN
	--                        LET sCteProspectoSaldo = 0;
	--                        LET sPromSaldoVigente = 0;		
	--                        LET sCteProspectoCompras = 0;
	--                        LET sCteProspectoSaldo = 0;
	--                        LET sPromSaldoVigente = 0;
	--                        LET cCodRet = '00001';
	--                        LET cMensajeRet = 'EL CLIENTE YA CUENTA CON UNA CREDISOLUCION DE SALDO';
	--		END IF;		
	--	END IF; --TERMINA DSB20140818
		
	IF cCodRet = '00000' THEN    --> FMV 21-AGO-14 No presenta error para contratacion
		
		-- SI EL CLIENTE TIENE ACTIVO UN TIPO DE CREDISOLUCION SALDOS, VALIDA QUE NO PUEDA CONTRATAR MAS CREDISOLUCIONES.
      --FMV 14-OCT-14: ESTA VALIDACION NO ES CORRECTA, UN CLIENTE PURDE SER CANDIDATO A SALDOS Y COMPRAS Y NO POR ESA CONDICION
                      -- NO CONTRATA EN LA VENTANILLA, SE OMITE VALIDACION
 --		IF sCteProspectoSaldo <> 0 OR sCteProspectoCompras <> 0 AND pOrigenPromo = 1 THEN
 --			LET cCodRet = '00001';
 --			LET cMensajeRet = 'EL CLIENTE NO ES CANDIDATO PARA OFRECER CREDISOLUCIONES EN VENTANILLA';
 --           LET sCteProspectoSaldo = 0;
 --           LET sCteProspectoCompras = 0;
 --		END IF;

   		-- SI EL CLIENTE TIENE CONTRATADO CAMPAÃAS DE CREDISOLUCIONES EFECTIVO Y COMPRAS, NO PODRA TENER EL CREDISOLUCION SALDOS
		IF sPromComprasVigente = 1 AND sCteProspectoSaldo <> 0 THEN
			LET cCodRet = '00001';
			LET cMensajeRet = 'EL CLIENTE NO ES CANDIDATO PARA LA PROMOCION DE SALDO TDC';
            LET sCteProspectoSaldo = 0;
		END IF;

		-- VALIDA QUE SI EL CLIENTE NO ES PROSPECTO PARA LAS DOS PROMOCIONES
		IF sCteProspectoCompras = 0 AND sCteProspectoSaldo = 0 AND sCteProspectoEfec = 0 THEN
			LET cCodRet = '00001';
			LET cMensajeRet = 'EL CLIENTE NO ES PROSPECTO PARA LAS PROMOCIONES';
		END IF;

		--*****************************************************************************************************************--             
			   
		-- VALIDA SI EL TIPO DE LA PROMOCION ES DE VENTANILLA
			IF pOrigenPromo = 1 AND sPromoSucCaja <> 0 AND cCodRet = '00000'  THEN
		--  IF cCodRet = '00000' and nvl(iNumPromoCred,0)  THEN
				LET sBandReturn = 1;
                LET sTipoPromocion = pOrigenPromo;    --FMV 3sep14 Asigna promocion
	            INSERT INTO "informix".sd_precal_credsol
	                        (empresa,num_credito,num_tarjeta,num_promo,sucursal,origen_promo,monto,secuencia,fecha_insert,user_insert)
	            VALUES ('001', pNumCredito,pNumTarjeta,sPromoSucCaja, pSucursal,pOrigenPromo, pMonto,0,dtFechaHoy,pEjecutivo);

				-- EJECUTA  LA PROYECCION  DE LA PROMOCION PARA SABER SI ES CANDIDATO O NO DE CREDISOLUCION EFECTIVO
					SELECT nombre_promo --DSB20140619
					  INTO cDescPromocion --DSB20140619
					  FROM 'informix'.sd_promocion  --DSB20140619
					 WHERE num_promo = sPromoSucCaja;	--DSB20140619
					   LET iNumeroPromocion = sPromoSucCaja; --DSB20140818
					
				FOREACH --DSB20140619
					SELECT plazo 
                      INTO iPlazo --DSB20140619
				      FROM "informix".sd_tasa_plazo --DSB20140619
					 WHERE num_promo = sPromoSucCaja 
                       AND plazo_activo = '1' --DSB20140619
					
					EXECUTE PROCEDURE 'informix'.sp_proyecta_promo
					(2,pSucursal,pEjecutivo,sPromoSucCaja,pNumCredito,pNumTarjeta,pMonto,iPlazo,'')
					INTO cCodRetPP, cMensajeRetPP, dTotalPagarPP, sNumPlazoPP, dPagoMensualPP, dInteresIvaPP, dSaldoTdcPP, cFolioPromoPP;
					IF cCodRetPP::INTEGER IN (433,1433,2433,3433,4433,5433,6433,7433,8433,9433,10433,11433,12433) THEN
						LET cCodRet = '00001';
						LET cMensajeRet = 'EL CLIENTE NO ES CANDIDATO A PARA LA PROMOCION DE EFECTIVO';
					ELIF cCodRetPP::INTEGER = 0 THEN
						IF dTotalPagarPP <= dcmCsg_linea_disp THEN --DSB20140619
						    IF dPlazoSeis = 0.00  THEN --DSB20140619
								LET dPlazoSeis = dPagoMensualPP; --DSB20140619
							ELIF dPlazoDoce = 0.00  THEN --DSB20140619
								LET dPlazoDoce = dPagoMensualPP; --DSB20140619
							ELSE --DSB20140619
								LET dPlazoDiezocho = dPagoMensualPP; --DSB20140619
							END IF; --DSB20140619
							LET cCodRet = '00000';
							LET cMensajeRet = 'CLIENTE ES CANDIDATO A PARA LA PROMOCION DE EFECTIVO';
							LET sValido = 1;
							CONTINUE FOREACH; --DSB20140619
						--END IF; --DSB20140619
						ELSE --DSB20140619
							IF dPlazoSeis = 0.00  THEN --DSB20140619
								LET dPlazoSeis = dPagoMensualPP; --DSB20140619
								LET sValido = 0; --DSB20140619
								LET cCodRet = '00001'; --DSB20140619
								LET cMensajeRet = 'EL CLIENTE NO ES CANDIDATO A PARA LA PROMOCION DE EFECTIVO'; --DSB20140619
							END IF; --DSB20140619
						END IF; --DSB20140619
					ELSE
						LET cCodRet = '00008';
						LET cMensajeRet = 'ERROR EN EL SP QUE DE PROYECTA PROMOCION';
					END IF;
				END FOREACH;	--DSB20140619
				RETURN cCodRetSuc,TRIM(cCodRet),TRIM(cMensajeRet),NVL(sTipoPromocion,0),TRIM(cDescPromocion),NVL(sValido,0),NVL(dPlazoSeis,0.00),NVL(dPlazoDoce,0.00),NVL(dPlazoDiezocho,0.00),NVL(iNumeroPromocion,0); --DSB20140818





			-- VALIDA SI EL TIPO DE LA PROMOCION ES DE PROMOTORIA
			ELIF pOrigenPromo = 2 THEN
				
                LET sTipoPromocion = pOrigenPromo;   --FMV 2sep14: Se adiciona el numero de promocion al parametro de salida final

				FOREACH
					SELECT b.nombre_promo,b.num_promo
					  INTO cDescPromocion,sNumPromocion
					  FROM 'informix'.sd_promocion b, bdinteg:"informix".si_sucursal_promocion a
					 WHERE a.empresa = b.empresa
                       AND a.promocion = b.num_promo
					   AND b.num_promo <> 0
					   AND b.tipo_promo = pOrigenPromo --DSB20140619
					   AND dtFechaHoy >= b.fechaini_promo
                       AND dtFechaHoy <= b.fechafin_promo
                       AND b.activo = 1     --> FMV 3sep14 Se identifica tipo y numero de promocion
					   AND a.sucursal = pSucursal
					   
					   IF sNumPromocion IN (8,9) THEN
						  LET sContadorExists = 0;
						  SELECT count(num_credito) INTO sContadorExists FROM 'informix'.sd_prospectos 
						   WHERE num_promo = sNumPromocion AND num_credito = pNumCredito AND dtFechaHoy >= fecha_ini AND dtFechaHoy <= fecha_fin;
										
					      --IF NOT EXISTS() THEN
						  IF sContadorExists = 0 THEN
							CONTINUE FOREACH;
						  END IF;
					   END IF;
		                   
					IF sNumPromocion in (2,5,8) AND sPromComprasVigente <> 0 AND iBanCompras = 0 THEN
						LET iBanCompras = 1;
						LET sTipoPromocion = 2; 
						LET sBandReturn = 1;
						LET pi_NumPromocion =  sPromComprasVigente;  --FMV 11nov13
						LET iNumeroPromocion = pi_NumPromocion; --DSB20140818
					-- EJECUTA  LA PROYECCION  DE LA PROMOCION PARA SABER SI ES CANDIDATO O NO DE CREDISOLUCION COMPRAS
						EXECUTE PROCEDURE 'informix'.sp_proyecta_promo
						(1,pSucursal,pEjecutivo,pi_NumPromocion,pNumCredito,pNumTarjeta,0,0,'')
						INTO cCodRetPP, cMensajeRetPP, dTotalPagarPP, sNumPlazoPP, dPagoMensualPP, dInteresIvaPP, dSaldoTdcPP, cFolioPromoPP;
						IF cCodRetPP::INTEGER IN (433,1433,2433,3433,4433,5433,6433,7433,8433,9433,10433,11433,12433) THEN
							LET cCodRet = '00001';
							LET cMensajeRet = 'EL CLIENTE NO ES CANDIDATO A PARA LA PROMOCION DE COMPRAS';
						ELIF cCodRetPP::INTEGER = 0 THEN
							LET cCodRet = '00000';
							LET cMensajeRet = 'CLIENTE ES CANDIDATO A PARA LA PROMOCION DE COMPRAS';
							LET sValido = 1;							
						ELSE
							LET cCodRet = '00008';
							LET cMensajeRet = 'ERROR EN EL SP QUE DE PROYECTA PROMOCION';
						END IF;
						--LET sTipoPromocion = 2;  FMV 2sep14

					ELIF sNumPromocion IN (3,6,9) AND sPromSaldoVigente <> 0 AND sBandCredsAct = 0 and iBanSaldos = 0 THEN
                               LET sTipoPromocion = 3; --FMV 4sep14, Temporalmente registra 3
							   LET sBandReturn = 1;
							   LET iBanSaldos = 1;
							   LET pi_NumPromocion =  sPromSaldoVigente;
							   LET iNumeroPromocion = pi_NumPromocion; --DSB20140818
						-- EJECUTA  LA PROYECCION  DE LA PROMOCION DE CREDISOLUCION SALDOS
						EXECUTE PROCEDURE 'informix'.sp_proyecta_promo
						(1,pSucursal,pEjecutivo,pi_NumPromocion,pNumCredito,pNumTarjeta,0,0,'') --DSB20140818
						INTO cCodRetPP, cMensajeRetPP, dTotalPagarPP, sNumPlazoPP, dPagoMensualPP, dInteresIvaPP, dSaldoTdcPP, cFolioPromoPP;
						IF cCodRetPP::INTEGER IN (433,1433,2433,3433,4433,5433,6433,7433,8433,9433,10433,11433,12433) THEN
							LET cCodRet = '00001';
							LET cMensajeRet = 'EL CLIENTE NO ES CANDIDATO A PARA LA PROMOCION DE SALDO TDC';
						ELIF cCodRetPP::INTEGER = 0 THEN
							LET cCodRet = '00000';
							LET cMensajeRet = 'CLIENTE ES CANDIDATO A PARA LA PROMOCION DE SALDO TDC';
							LET sValido = 1;
						ELSE
							LET cCodRet = '00008';
							LET cMensajeRet = 'ERROR EN EL SP QUE DE PROYECTA PROMOCION';
						END IF;
					ELSE
						CONTINUE FOREACH;
						--LET sTipoPromocion = 3;  FMV 2sep14
					END IF;
					 INSERT INTO 'informix'.sd_precal_credsol
		                              (empresa,num_credito,num_tarjeta,num_promo,sucursal,origen_promo,monto,secuencia,fecha_insert,user_insert)
		             VALUES ('001', pNumCredito,pNumTarjeta,sNumPromocion, pSucursal,pOrigenPromo, pMonto,0,dtFechaHoy,pEjecutivo);

					RETURN cCodRetSuc, cCodRet, TRIM(cMensajeRet), NVL(sTipoPromocion,0), TRIM(cDescPromocion), NVL(sValido,0), NVL(dPlazoSeis,0.00), NVL(dPlazoDoce,0.00), NVL(dPlazoDiezocho,0.00),NVL(iNumeroPromocion,0)WITH RESUME; --DSB20140619,--DSB20140818
				END FOREACH;
				 --FMV 12mar14: Return fuera del foreach
				 IF iBanCompras = 0 AND iBanSaldos = 0 then
					LET cCodRet = '00001';
					LET cMensajeRet = 'LA SUCURSAL NO TIENE PROMOCIONES VIGENTES.';
				 END IF
				
			END IF; --IF pOrigenPromo = 1 AND sPromoSucCaja <> 0 THEN
		-- END FOREACH;  --> FMV 12mar14
		--END IF; --	IF cCodRet = '00000' THEN
    END IF;	
	IF sBandReturn	= 0 THEN
		RETURN cCodRetSuc, cCodRet, TRIM(cMensajeRet), NVL(sTipoPromocion,0), TRIM(cDescPromocion), NVL(sValido,0), NVL(dPlazoSeis,0.00), NVL(dPlazoDoce,0.00), NVL(dPlazoDiezocho,0.00),NVL(iNumeroPromocion,0); --DSB20140619,--DSB20140818
	END IF;

    IF cCodRet <> '00000' THEN
        INSERT INTO bdicred:sd_bitacora_promocion VALUES('001',pNumCredito,'sp_val_datos_promo',dtFechaHoy,CURRENT,'',pOrigenPromo,cCodRet);
    END IF;


END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Proceso que realiza la validaciÃ³n de las promociones de credisoluciÃ³n para las que es vÃ¡lido un cliente',
'AUTOR: Mohamed CarreÃ³n ',
'FECHA DE CREACION: 27 de Enero del 2012',
'VERSION: 20120127.0942',
'BD: bdicred',
'ModificÃ³: Carlos Aguirre Vega',
'Fecha de modificaciÃ³n: 17-06-2013',
'DescripciÃ³n: Se validan los campos fecha_ini y fecha_hoy de la sd_prospectos, y se valida num_promo para que cumpla las reglas de negocio',
'Peticion: MttoCredisoluciones RQM 10 214-2',
'-------------------------------------------------------------------------------------------------------------------------------------------',
'-- Folio.........: 1452 - CrediSoluciones',
'-- Autor.........: 95519203 - Ivan Garcia',
'-- Fecha.........: 19/06/2014 - DSB20140619',
'-- ModificaciÃ³n..: Se modifica para identificar los plazos, primero se deberÃ¡ filtrar el menor de los plazos (6 meses) de acuerdo a la disponibilidad y vigencia de la campaÃ±a que este activa',
'-- Sustento......: Analisis incidencias credisoluciones.doc',
'-- Solicita......: Faviola Martinez',
'-- BD............: Bdicred',
'----------------------------------------------------------------------------------------------------------------',
'-- Folio.........: 1475 - CrediSoluciones',
'-- Autor.........: 95519203 - Ivan Garcia',
'-- Fecha.........: 18/08/2014 - DSB20140818',
'-- ModificaciÃ³n..: Se modifica para que comtemple el saldo a favor del cliente al contratar una credisoluciÃ³n, asi como tambien se modifica para que actualize las tasas de los plazos correspondientes al numero de promocion y campaÃ±a para compras y saldos',
'-- Sustento......: Analisis incidencias credisoluciones.doc',
'-- Solicita......: Faviola Martinez',
'-- BD............: Bdicred',
'----------------------------------------------------------------------------------------------------------------',
'-- Folio.........: 1461 - MTTOCONTRATACIONCREDISOL',
'-- Autor.........: 96273763 - Antonio Cebreros',
'-- Fecha.........: 02/10/2014 - DSB20141002',
'-- ModificaciÃ³n..: Se modifica para validar si el cliente tiene un tipo de credisoluciÃ³n o no. En caso de tener un tipo de credisoluciÃ³n no debe permitir contrataciones de otro tipo a menos que sean credisoluciones compras donde puede pedir mas credisoluciones del mismo tipo. Las credisoluciones en efectivo se tomarÃ¡n como compras. En caso de que el cliente no tenga ningun tipo de credisoluciÃ³n mostrarlo como candidato para cualquier tipo de credisolucion segun la vigencia de la promocion, se aplican reglas de programacion',
'-- Sustento......: Ajustes Promotoria CrediSoluciones.doc',
'-- Solicita......: Faviola Martinez',
'-- BD............: Bdicred';

CREATE PROCEDURE "informix".sp_validavtacredito(pEmpresa CHAR(3), pNumCred CHAR(20))
RETURNING CHAR (6)    AS CodRet,
		  CHAR (1)    AS Status;
		  
	DEFINE iSqlErr       	INTEGER;
	DEFINE cCodRet       	CHAR(6);
	DEFINE cStatus_Cred		CHAR(2);
	DEFINE cFechaHoy		CHAR(6);
	DEFINE cNumProd			CHAR(6);
	DEFINE dtFechaHoy		DATE;
	DEFINE dtFechaRpt		DATE;
	DEFINE iId_Origen		INTEGER;
	DEFINE iRows			INTEGER;
	DEFINE cBand			CHAR(1);
	DEFINE cFechaRpt		CHAR(6);
	DEFINE bConsulta		BOOLEAN;
							  
	
							 
	LET iSqlErr       		= 0;
	LET cCodRet       		= '000000';
	LET cStatus_Cred    	= '';
	LET dtFechaHoy 			= '';	
	LET cFechaHoy 			= '';
	LET cNumProd 			= '';
	LET iId_Origen       	= 0;
	LET iRows       		= 0;
	LET cBand 				= '';
	LET dtFechaRpt 			= '';
	LET cFechaRpt 			= '';
	LET bConsulta 			= 'f';
	
	--SET DEBUG FILE TO '/tmp/sp_validavtacredito.out';
	--TRACE ON;
	
BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			RETURN TRIM(NVL(cCodRet,'')),TRIM(NVL(cBand,''));
		END IF;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	IF TRIM(NVL(pEmpresa,'')) = '' OR TRIM(NVL(pNumCred,'')) = '' THEN
		LET cCodRet = '000001';
		RETURN TRIM(NVL(cCodRet,'')),TRIM(NVL(cBand,''));
	ELSE
	
		SELECT fecha_hoy INTO dtFechaHoy FROM "informix".sd_fechas;
		
		LET iRows = dbinfo("sqlca.sqlerrd2");
		
		IF NVL(iRows,0) <> 0 THEN
			LET cFechaHoy = LPAD(YEAR(dtFechaHoy),4,"0") || LPAD(MONTH(dtFechaHoy),2,"0");
		ELSE
			LET cCodRet = '000004';
			RETURN TRIM(NVL(cCodRet,'')),TRIM(NVL(cBand,''));
		END IF;
		
		LET iRows = 0;
		
		SELECT DISTINCT num_producto,status_cred,id_unidad_prod
		INTO cNumProd,cStatus_Cred,iId_Origen
		FROM "informix".sd_maecred 
																									   
		WHERE num_credito = TRIM(NVL(pNumCred,'')) AND empresa = TRIM(NVL(pEmpresa,''));
		
		LET iRows = dbinfo("sqlca.sqlerrd2");
		
		IF NVL(iRows,0) = 0 THEN
		
			LET iRows = 0;
			
			SELECT DISTINCT num_producto,status_cred,id_origen
			INTO cNumProd,cStatus_Cred,iId_Origen
			FROM "informix".sd_maecredcrd 
																										   
			WHERE num_credito = TRIM(NVL(pNumCred,'')) AND empresa = TRIM(NVL(pEmpresa,''));
			
			LET iRows = dbinfo("sqlca.sqlerrd2");
			
			IF NVL(iRows,0) = 0 THEN
				LET cCodRet = '000002';
				LET cBand 	= '';
				RETURN TRIM(NVL(cCodRet,'')),TRIM(NVL(cBand,''));
			END IF;
			
		END IF;	
		
		LET iRows = 0;

		IF TRIM(NVL(cNumProd,'')) <> '6500' THEN
		
			IF TRIM(NVL(cNumProd,'')) = '6011'THEN
				IF cStatus_Cred IN ('BT','VP','E2','E3') AND NVL(iId_Origen,0) = 1 THEN
					LET bConsulta = 't';
				END IF;
			ELSE
				IF cStatus_Cred IN ('BT','E2','E3') AND NVL(iId_Origen,0) = 1 THEN
					LET bConsulta = 't';
				END IF;			
			END IF;
			
			IF bConsulta = 't' THEN
				IF EXISTS(SELECT MAX(fechareporte) FROM bdicobranza: "informix".cb_rep_cart_quebrantar
				WHERE num_credito = TRIM(NVL(pNumCred,''))) THEN
					LET cBand = '2';	
				ELSE
					LET cBand = '3';		
				END IF;
			ELIF TRIM(NVL(cStatus_Cred,'')) = 'CV' THEN	
				LET cBand = '1';
			ELSE
				LET cBand = '3';
			END IF;
		ELSE
			LET cBand = '4';	
		END IF;
		
		RETURN TRIM(NVL(cCodRet,'')),TRIM(NVL(cBand,''));
		
	END IF;
			  
END	
END PROCEDURE
DOCUMENT
'AUTOR: ISARAI BOJORQUEZ',
'FECHA: 06/06/2016',
'MODIFICACION: ESTE PROCEDIMIENTO INDICA SI EL CRÉDITO QUE SE CONSULTA EN LA CAJA ESTA EN PROCESO DE VENTA O VENDIDO',
'BD: BDICRED';

CREATE PROCEDURE "informix".sp_validavtacredito_web(pEmpresa CHAR(3), pNumCred CHAR(20))
RETURNING CHAR (5)    AS CodRet,
		  CHAR (1)    AS Status;
		  
	DEFINE iSqlErr       	INTEGER;
	DEFINE cCodRet       	CHAR(5);
	DEFINE cStatus_Cred		CHAR(2);
	DEFINE cFechaHoy		CHAR(6);
	DEFINE cNumProd			CHAR(6);
	DEFINE dtFechaHoy		DATE;
	DEFINE dtFechaRpt		DATE;
	DEFINE iId_Origen		INTEGER;
	DEFINE iRows			INTEGER;
	DEFINE cBand			CHAR(1);
	DEFINE cFechaRpt		CHAR(6);
	DEFINE bConsulta		BOOLEAN;
							  
	
							 
	LET iSqlErr       		= 0;
	LET cCodRet       		= '00000';
	LET cStatus_Cred    	= '';
	LET dtFechaHoy 			= '';	
	LET cFechaHoy 			= '';
	LET cNumProd 			= '';
	LET iId_Origen       	= 0;
	LET iRows       		= 0;
	LET cBand 				= '';
	LET dtFechaRpt 			= '';
	LET cFechaRpt 			= '';
	LET bConsulta 			= 'f';
	
	--SET DEBUG FILE TO '/tmp/sp_validavtacredito_web.out';
	--TRACE ON;
	
BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			RETURN TRIM(NVL(cCodRet,'')),TRIM(NVL(cBand,''));
		END IF;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	IF TRIM(NVL(pEmpresa,'')) = '' OR TRIM(NVL(pNumCred,'')) = '' THEN
		LET cCodRet = '00001';
		RETURN TRIM(NVL(cCodRet,'')),TRIM(NVL(cBand,''));
	ELSE
	
		SELECT fecha_hoy INTO dtFechaHoy FROM "informix".sd_fechas;
		
		LET iRows = dbinfo("sqlca.sqlerrd2");
		
		IF NVL(iRows,0) <> 0 THEN
			LET cFechaHoy = LPAD(YEAR(dtFechaHoy),4,"0") || LPAD(MONTH(dtFechaHoy),2,"0");
		ELSE
			LET cCodRet = '00004';
			RETURN TRIM(NVL(cCodRet,'')),TRIM(NVL(cBand,''));
		END IF;
		
		LET iRows = 0;
		
		SELECT DISTINCT num_producto,status_cred,id_unidad_prod
		INTO cNumProd,cStatus_Cred,iId_Origen
		FROM "informix".sd_maecred 
																									   
		WHERE num_credito = TRIM(NVL(pNumCred,'')) AND empresa = TRIM(NVL(pEmpresa,''));
		
		LET iRows = dbinfo("sqlca.sqlerrd2");
		
		IF NVL(iRows,0) = 0 THEN
		
			LET iRows = 0;
			
			SELECT DISTINCT num_producto,status_cred,id_origen
			INTO cNumProd,cStatus_Cred,iId_Origen
			FROM "informix".sd_maecredcrd 
																										   
			WHERE num_credito = TRIM(NVL(pNumCred,'')) AND empresa = TRIM(NVL(pEmpresa,''));
			
			LET iRows = dbinfo("sqlca.sqlerrd2");
			
			IF NVL(iRows,0) = 0 THEN
				LET cCodRet = '00002';
				LET cBand 	= '';
				RETURN TRIM(NVL(cCodRet,'')),TRIM(NVL(cBand,''));
			END IF;
			
		END IF;	
		
		LET iRows = 0;

		IF TRIM(NVL(cNumProd,'')) <> '6500' THEN
		
			IF TRIM(NVL(cNumProd,'')) = '6011'THEN
				IF cStatus_Cred IN ('BT','VP','E2','E3') AND NVL(iId_Origen,0) = 1 THEN
					LET bConsulta = 't';
				END IF;
			ELSE
				IF cStatus_Cred IN ('BT','E2','E3') AND NVL(iId_Origen,0) = 1 THEN
					LET bConsulta = 't';
				END IF;			
			END IF;
			
			IF bConsulta = 't' THEN
				IF EXISTS(SELECT MAX(fechareporte) FROM bdicobranza: "informix".cb_rep_cart_quebrantar
				WHERE num_credito = TRIM(NVL(pNumCred,''))) THEN
					LET cBand = '2';	
				ELSE
					LET cBand = '3';		
				END IF;
			ELIF TRIM(NVL(cStatus_Cred,'')) = 'CV' THEN	
				LET cBand = '1';
			ELSE
				LET cBand = '3';
			END IF;
		ELSE
			LET cBand = '4';	
		END IF;
		
		RETURN TRIM(NVL(cCodRet,'')),TRIM(NVL(cBand,''));
		
	END IF;
			  
END	
END PROCEDURE
DOCUMENT
'AUTOR: ISARAI BOJORQUEZ',
'FECHA: 06/06/2016',
'MODIFICACION: ESTE PROCEDIMIENTO INDICA SI EL CRÃDITO QUE SE CONSULTA EN LA CAJA ESTA EN PROCESO DE VENTA O VENDIDO',
'BD: BDICRED';

CREATE PROCEDURE "informix".sp_cons_cre_cfdi_bpi(pempresa CHAR(3), pnum_cte CHAR(20))
	returning CHAR(5),CHAR(20),CHAR(20), CHAR(2),CHAR(20),CHAR(1),CHAR(55), CHAR(1);

-- ***************************************************************************
-- Define variables
-- ***************************************************************************
	DEFINE cod_ret			CHAR(5);
	DEFINE sql_err			INTEGER;
	DEFINE v_cuenta			CHAR(20);
	DEFINE v_numtarjeta		CHAR(20);
	DEFINE v_status_tar		CHAR(1);
	DEFINE v_status_cred	CHAR(2);
	DEFINE v_nombre_prod	CHAR(55);
	DEFINE v_secuencia		INTEGER;
	DEFINE vstatus_serv		CHAR(1);
	DEFINE v_numcte			CHAR(20);

-- ***************************************************************************
-- Inicializa variables
-- ***************************************************************************
	LET cod_ret			= '00000';
	LET v_cuenta		= NULL;
	LET v_numtarjeta	= '';
	LET v_status_tar	= '';
	LET v_status_cred	= '';
	LET v_nombre_prod	= '';
	LET vstatus_serv	= '';
	LET v_numcte		= pnum_cte;
	
	--set debug file to "/home/informix/bibiana/cons_cre_bpi.out";
	--trace on;

	-- ******************************************************************************************************************************************************
    -- Creado por:			L.I. Manuel Ramos Figueroa
    -- Fecha: 2014/03/05
    -- Objetivo:			Consulta la cuentas de crÃ©dito del cliente y obtiene el status del servicio de estado de cuenta fiscal de cada cuenta
    -- ******************************************************************************************************************************************************

	BEGIN
		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				LET cod_ret = sql_err;
				RETURN cod_ret, v_numcte, v_cuenta, v_status_cred, v_numtarjeta, v_status_tar,v_nombre_prod,vstatus_serv;
			END IF;
		END EXCEPTION;

		SET ISOLATION DIRTY READ ;
		SET LOCK MODE TO WAIT 3;

		FOREACH
			SELECT mc.num_credito,  mc.status_cred,  tr.num_tarjeta, tr.status_tar,  TRIM(df.num_producto) || ' ' || TRIM(df.nombre_prod)
			INTO v_cuenta, v_status_cred, v_numtarjeta, v_status_tar, v_nombre_prod
			FROM bdicred:"informix".sd_maecred mc
			JOIN bdicred:"informix".sd_tarjeta tr 
				ON (tr.empresa = pempresa AND mc.num_credito = tr.num_credito AND tr.tipo_tarjeta = 'T' AND mc.status_cred in ('AA','BA','BT','E1','E2','E3') 
				AND secuencia = (select max(secuencia) from bdicred:"informix".sd_tarjeta where empresa = pempresa AND mc.num_credito = num_credito AND tipo_tarjeta = 'T'))
			JOIN bdicred:"informix".sd_definicion df 
				ON (df.num_producto = mc.num_producto)
			WHERE mc.numcte = pnum_cte
			UNION
			SELECT mcr.num_credito,  mcr.status_cred,  '', '',  TRIM(df.num_producto) || ' ' || TRIM(df.nombre_prod)
			FROM bdicred:"informix".sd_maecredcrd mcr
			JOIN bdicred:"informix".sd_definicion df 
				ON (df.num_producto = mcr.num_producto)
			WHERE mcr.numcte = pnum_cte
			AND mcr.status_cred IN('AA','BA','BT','VP','E1','E2','E3')

			IF NVL(v_numtarjeta, "") = "" THEN
				LET v_numtarjeta = "No Aplica";
			END IF;

			SELECT status_serv_elec
			INTO vstatus_serv
			FROM bdiedoelec:"informix".edelec_alta_serv
			WHERE cuenta = v_cuenta;

			RETURN cod_ret, v_numcte, v_cuenta, v_status_cred, v_numtarjeta, v_status_tar,v_nombre_prod,NVL(vstatus_serv, "") WITH RESUME;
		END FOREACH;

		IF v_cuenta IS NULL THEN
			LET cod_ret = 100;
			RETURN cod_ret, v_numcte, v_cuenta, v_status_cred, v_numtarjeta, v_status_tar,v_nombre_prod,NVL(vstatus_serv, "");
		END IF;
	END
END PROCEDURE;
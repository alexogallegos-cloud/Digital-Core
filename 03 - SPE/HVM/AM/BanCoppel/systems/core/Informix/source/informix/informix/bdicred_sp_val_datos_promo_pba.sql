CREATE PROCEDURE "informix".sp_val_datos_promo_pba
(
pSucursal		CHAR(4),
pEjecutivo		CHAR(8),
pOrigenPromo	SMALLINT,
pNumCredito 	CHAR(20),
pNumTarjeta		CHAR(20),
pMonto 			DECIMAL(18,2)
)
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

    IF (SELECT COUNT(*) FROM bdinteg:"informix".si_sucursal_promocion a, "informix".sd_promocion b
                       WHERE a.empresa = b.empresa
                         AND a.promocion = b.num_promo
                         AND b.activo = 1
                         AND dtFechaHoy BETWEEN b.fechaini_promo
                         AND b.fechafin_promo
                         AND a.sucursal = pSucursal) = 0 THEN
				LET cCodRet = '00001';
				LET cMensajeRet = 'LA SUCURSAL NO TIENE PROMOCIONES VIGENTES';
				RETURN cCodRetSuc, cCodRet, NVL(cMensajeRet,''), NVL(sTipoPromocion,0), NVL(cDescPromocion,''), NVL(sValido,0), NVL(dPlazoSeis,0.00), NVL(dPlazoDoce,0.00), NVL(dPlazoDiezocho,0.00), NVL(iNumeroPromocion,0); --DSB20140818
    END IF;

 	-- VALIDA QUE AL MENOS RECIBA EL NUMERO DE CREDITO O LA TARJETA
	IF cCodRet = '00000' /*AND (NVL(pNumCredito,'') = '' OR NVL(pNumTarjeta,'') = '' )*/ THEN
		IF NVL(pNumCredito,'') <> '' THEN
			SELECT num_tarjeta
			INTO pNumTarjeta
			FROM 'informix'.sd_tarjeta a, "informix".sd_maecred b
			WHERE a.empresa = '001'
              AND a.empresa = b.empresa
              AND a.num_credito = pNumCredito
              AND a.num_credito = b.num_credito
              AND a.tipo_tarjeta = 'T'
              AND a.status_tar = 'A'
              AND b.status_cred = 'AA';

			IF NVL(pNumTarjeta,'') = '' THEN
				LET cCodRet = '00001';
				LET cMensajeRet = 'NUMERO DE CREDITO NO ESTA VIGENTE O NO ES VALIDO';
				RETURN cCodRetSuc, cCodRet, NVL(cMensajeRet,''), NVL(sTipoPromocion,0), NVL(cDescPromocion,''), NVL(sValido,0), NVL(dPlazoSeis,0.00), NVL(dPlazoDoce,0.00), NVL(dPlazoDiezocho,0.00), NVL(iNumeroPromocion,0); --DSB20140818
			END IF;

		ELIF NVL(pNumTarjeta,'') <> '' THEN

           SELECT a.num_credito
		  	 INTO pNumCredito
			 FROM "informix".sd_tarjeta a, 
                  "informix".sd_maecred b
			WHERE a.empresa = '001'
              AND a.empresa = b.empresa
              AND a.num_credito = b.num_credito
              AND num_tarjeta = pNumTarjeta
              AND tipo_tarjeta = 'T'
              AND status_tar = 'A'
              AND b.status_cred = 'AA';

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

        --FMV 7nov13: Validar que la Campaña especial, sea la 1a. en el filtro de credisoluciones
		-- VALIDA SI LA PROMOCION DE CREDISOLUCION CAMPAÑA ESPECIAL, ESQUEMA EFECTIVO ESTA VIGENTE
		IF sPromoSucCaja = 0 AND cCodRet = '00000' AND NOT EXISTS
		              (SELECT b.num_promo
                         FROM bdinteg:"informix".si_sucursal_promocion a, "informix".sd_promocion b
						WHERE a.empresa = b.empresa
						  AND a.promocion = b.num_promo
						  AND b.num_promo = 7
                          AND b.activo = 1
                          AND dtFechaHoy >= b.fechaini_promo
                          AND dtFechaHoy <= b.fechafin_promo
						  AND a.sucursal = pSucursal) THEN
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
            IF sPromoSucCaja = 7 AND NOT EXISTS
                    (SELECT num_credito
                       FROM 'informix'.sd_prospectos
                      WHERE num_promo = 7
                        AND num_credito = pNumCredito
                        AND dtFechaHoy >= fecha_ini
                        AND dtFechaHoy <= fecha_fin) THEN
                LET cCodRet = '00001';
                LET cMensajeRet = 'EL CLIENTE NO ES PROSPECTO PARA LA PROMOCION 7';
                LET sPromoSucCaja = 0;
                LET sCteProspectoEfec = 0;    
                LET sNumPromocion = sCteProspectoEfec;        
            END IF;
		END IF;

 		-- VALIDA SI LA PROMOCION DE CREDISOLUCION CAMPAÑA TEMPORAL, ESQUEMA EFECTIVO ESTA VIGENTE
         IF sPromoSucCaja = 0 AND cCodRet = '00001' THEN
                IF NOT EXISTS (SELECT b.num_promo
                         FROM bdinteg:"informix".si_sucursal_promocion a, "informix".sd_promocion b
						WHERE a.empresa = b.empresa
						  AND a.promocion = b.num_promo
						  AND b.num_promo = 4
                          AND b.activo = 1
                          AND dtFechaHoy >= b.fechaini_promo
                          AND dtFechaHoy <= b.fechafin_promo
						  AND a.sucursal = pSucursal) THEN
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

		-- VALIDA SI LA PROMOCION DE CREDISOLUCION CAMPAÑA PERMANENTE, ESQUEMA EFECTIVO ESTA VIGENTE
         IF sPromoSucCaja = 0 AND cCodRet = '00001' THEN
                IF NOT EXISTS (SELECT b.num_promo
                         FROM bdinteg:"informix".si_sucursal_promocion a, "informix".sd_promocion b
						WHERE a.empresa = b.empresa
						  AND a.promocion = b.num_promo
						  AND b.num_promo = 1
                          AND b.activo = 1
                          AND dtFechaHoy >= b.fechaini_promo
                          AND dtFechaHoy <= b.fechafin_promo
						  AND a.sucursal = pSucursal) THEN
								  
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
		IF NOT EXISTS(SELECT b.num_promo
                         FROM bdinteg:"informix".si_sucursal_promocion a, "informix".sd_promocion b
						WHERE a.empresa = b.empresa
						  AND a.promocion = b.num_promo
						  AND b.num_promo = 8
                          AND b.activo = 1
                          AND dtFechaHoy >= b.fechaini_promo
                          AND dtFechaHoy <= b.fechafin_promo
						  AND a.sucursal = pSucursal) THEN
			LET cCodRet = '00001';
			LET cMensajeRet = 'EL CLIENTE NO ES PROSPECTO PARA LA PROMOCION 8';
            LET sPromComprasVigente = 0;
            LET sNumPromocion = sPromComprasVigente;
		ELSE
			LET sPromComprasVigente = 8; --FMV 12nov13 toma valor del numero de promocion
			IF cCodRet = '00000' AND sPromComprasVigente = 8 AND 
			NOT EXISTS(SELECT num_credito 
                         FROM 'informix'.sd_prospectos 
                        WHERE num_promo = 8
					  	  AND num_credito = pNumCredito
						  AND dtFechaHoy >= fecha_ini
                          AND dtFechaHoy <= fecha_fin
						) THEN
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
			IF NOT EXISTS(SELECT b.num_promo
                         FROM bdinteg:"informix".si_sucursal_promocion a, "informix".sd_promocion b
						WHERE a.empresa = b.empresa
						  AND a.promocion = b.num_promo
						  AND b.num_promo = 5
                          AND b.activo = 1
                          AND dtFechaHoy >= b.fechaini_promo
                          AND dtFechaHoy <= b.fechafin_promo
						  AND a.sucursal = pSucursal) THEN
				LET cCodRet = '00001';
				LET cMensajeRet = 'EL CLIENTE NO ES PROSPECTO PARA LA PROMOCION 5';
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
			IF NOT EXISTS (SELECT b.num_promo
                         FROM bdinteg:"informix".si_sucursal_promocion a, "informix".sd_promocion b


						WHERE a.empresa = b.empresa
						  AND a.promocion = b.num_promo
						  AND b.num_promo = 2
                          AND b.activo = 1
                          AND dtFechaHoy >= b.fechaini_promo
                          AND dtFechaHoy <= b.fechafin_promo
						  AND a.sucursal = pSucursal) THEN
				LET cCodRet = '00001'; --DSB20140818				  
				LET cMensajeRet = 'EL CLIENTE NO ES PROSPECTO PARA LA PROMOCION 2';
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
		IF pOrigenPromo = 2 AND sPromSaldoVigente = 0 AND sPromComprasVigente = 0 AND  sPromoSucCaja = 0 --AND dcmCsg_tot_liquidacion >= 1000
		AND NOT EXISTS(SELECT b.num_promo
                         FROM bdinteg:"informix".si_sucursal_promocion a, "informix".sd_promocion b
						WHERE a.empresa = b.empresa
						  AND a.promocion = b.num_promo
						  AND b.num_promo = 9
                          AND b.activo = 1
                          AND dtFechaHoy >= b.fechaini_promo
                          AND dtFechaHoy <= b.fechafin_promo
						  AND a.sucursal = pSucursal) THEN
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
			IF sPromSaldoVigente = 9 AND 
			NOT EXISTS(SELECT num_credito 
                         FROM 'informix'.sd_prospectos 
                        WHERE num_promo = 9
						  AND num_credito = pNumCredito
                          AND dtFechaHoy >= fecha_ini
                          AND dtFechaHoy <= fecha_fin) THEN
				LET cCodRet = '00001';
				LET cMensajeRet = 'EL CLIENTE NO ES PROSPECTO PARA LA PROMOCION 9';
				LET sPromSaldoVigente = 0; 
                LET sNumPromocion = sPromSaldoVigente;
			END IF;
		END IF;
		-- VALIDA SI LA PROMOCION DE CREDISOLUCION SALDO, ESQUEMA TEMPORAL  TDC ESTA VIGENTE
		IF sPromSaldoVigente = 0 AND cCodRet = '00001' AND scteprospectocompras = 0 THEN --DSB20140818
			IF NOT EXISTS(SELECT b.num_promo
                         FROM bdinteg:"informix".si_sucursal_promocion a, "informix".sd_promocion b
						WHERE a.empresa = b.empresa
						  AND a.promocion = b.num_promo
						  AND b.num_promo = 6
                          AND b.activo = 1
                          AND dtFechaHoy >= b.fechaini_promo
                          AND dtFechaHoy <= b.fechafin_promo
						  AND a.sucursal = pSucursal) THEN
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
			IF NOT EXISTS(SELECT b.num_promo
                         FROM bdinteg:"informix".si_sucursal_promocion a, "informix".sd_promocion b
						WHERE a.empresa = b.empresa
						  AND a.promocion = b.num_promo
						  AND b.num_promo = 3
                          AND b.activo = 1
                          AND dtFechaHoy >= b.fechaini_promo
                          AND dtFechaHoy <= b.fechafin_promo
						  AND a.sucursal = pSucursal) THEN
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
		-- El prestamo no debe tener ninguna de las campañas efectivo y compras para contratar saldo y viceverza
		-- -- (Cualquier campaña de efectivo y compras)( 0.- Pendiente,  2 .-Aperturado)
		IF cCodRet = '00000' AND sPromSaldoVigente IN (3,6,9) AND EXISTS--NOT EXISTS
		       (SELECT num_credito 
                  FROM 'informix'.sd_promocion_credito 
                 WHERE empresa = '001' 
				   AND num_credito = pNumCredito	
				   AND num_promo IN (1,4,7,2,5,8)  -- (Cualquier campaña de efectivo y compras)
				   AND status IN (0,2)) THEN
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
			LET cCodRet = '00000';
			LET cMensajeRet = 'EL CLIENTE YA CUENTA CON UNA CREDISOLUCION DE COMPRA';
			
			--TIENE CREDISOLUCIONES EFECTIVO
		ELIF NVL(sNumPromoAct,0) in (1,4,7)THEN
			LET sBandCredsAct =1;
			LET sCteProspectoCompras = 1;
			LET sCteProspectoSaldo = 0;
			LET cCodRet = '00000';
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
		
			IF NOT EXISTS(SELECT num_credito
                       FROM 'informix'.sd_prospectos
                      WHERE num_promo = 9
                        AND num_credito = pNumCredito
                        AND dtFechaHoy >= fecha_ini
                        AND dtFechaHoy <= fecha_fin) THEN
						
			LET sCteProspectoSaldo = 0;	
						
		    END IF;
        END IF;
		
		IF sPromComprasVigente = 8 THEN
		
			IF NOT EXISTS(SELECT num_credito
                       FROM 'informix'.sd_prospectos
                      WHERE num_promo = 8
                        AND num_credito = pNumCredito
                        AND dtFechaHoy >= fecha_ini
                        AND dtFechaHoy <= fecha_fin) THEN
						
			LET sCteProspectoCompras = 0;	
						
		    END IF;
        END IF;
		
		LET sBandCredsAct = 0;
		LET cCodRet = '00000';
	
	END IF
	
	      -- Se comenta por que ya no es necesario con las validaciones anteriores.   
	--	IF  cCodRet = '00000' AND sPromSaldoVigente NOT IN (3,6,9) THEN  --INICIA DSB20140818
	--	    IF (sPromoSucCaja IN (1,4,7) OR sPromComprasVigente IN (2,5,8)) AND EXISTS --NOT EXISTS
	--		       (SELECT num_credito 
	--                  FROM 'informix'.sd_promocion_credito 
	--                 WHERE empresa = '001' 
	--				   AND num_credito = pNumCredito
	--				   AND num_promo IN (3,6,9)  -- (Cualquier campaña de saldos)
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

   		-- SI EL CLIENTE TIENE CONTRATADO CAMPAÑAS DE CREDISOLUCIONES EFECTIVO Y COMPRAS, NO PODRA TENER EL CREDISOLUCION SALDOS
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
'DESCRIPCION: Proceso que realiza la validación de las promociones de credisolución para las que es válido un cliente',
'AUTOR: Mohamed Carreón ',
'FECHA DE CREACION: 27 de Enero del 2012',
'VERSION: 20120127.0942',
'BD: bdicred',
'Modificó: Carlos Aguirre Vega',
'Fecha de modificación: 17-06-2013',
'Descripción: Se validan los campos fecha_ini y fecha_hoy de la sd_prospectos, y se valida num_promo para que cumpla las reglas de negocio',
'Peticion: MttoCredisoluciones RQM 10 214-2',
'-------------------------------------------------------------------------------------------------------------------------------------------',
'-- Folio.........: 1452 - CrediSoluciones',
'-- Autor.........: 95519203 - Ivan Garcia',
'-- Fecha.........: 19/06/2014 - DSB20140619',
'-- Modificación..: Se modifica para identificar los plazos, primero se deberá filtrar el menor de los plazos (6 meses) de acuerdo a la disponibilidad y vigencia de la campaña que este activa',
'-- Sustento......: Analisis incidencias credisoluciones.doc',
'-- Solicita......: Faviola Martinez',
'-- BD............: Bdicred',
'----------------------------------------------------------------------------------------------------------------',
'-- Folio.........: 1475 - CrediSoluciones',
'-- Autor.........: 95519203 - Ivan Garcia',
'-- Fecha.........: 18/08/2014 - DSB20140818',
'-- Modificación..: Se modifica para que comtemple el saldo a favor del cliente al contratar una credisolución, asi como tambien se modifica para que actualize las tasas de los plazos correspondientes al numero de promocion y campaña para compras y saldos',
'-- Sustento......: Analisis incidencias credisoluciones.doc',
'-- Solicita......: Faviola Martinez',
'-- BD............: Bdicred',
'----------------------------------------------------------------------------------------------------------------',
'-- Folio.........: 1461 - MTTOCONTRATACIONCREDISOL',
'-- Autor.........: 96273763 - Antonio Cebreros',
'-- Fecha.........: 02/10/2014 - DSB20141002',
'-- Modificación..: Se modifica para validar si el cliente tiene un tipo de credisolución o no. En caso de tener un tipo de credisolución no debe permitir contrataciones de otro tipo a menos que sean credisoluciones compras donde puede pedir mas credisoluciones del mismo tipo. Las credisoluciones en efectivo se tomarán como compras. En caso de que el cliente no tenga ningun tipo de credisolución mostrarlo como candidato para cualquier tipo de credisolucion segun la vigencia de la promocion, se aplican reglas de programacion',
'-- Sustento......: Ajustes Promotoria CrediSoluciones.doc',
'-- Solicita......: Faviola Martinez',
'-- BD............: Bdicred';

CREATE PROCEDURE "informix".sp_obtiene_tipoaltaprospecto(pEmpresa CHAR(3),pTpConsulta CHAR(2),pFiltro VARCHAR(4),pProducto CHAR(4),pFechaIni DATE,pFechaFin DATE,pEstatus CHAR(2),pretedocd CHAR(2))
RETURNING
	CHAR(6) AS cod_ret, VARCHAR(80,1) AS mensaje_ret, VARCHAR(200,1) AS descripcion_status, VARCHAR(3,1) AS status_sol, DECIMAL(18,2) AS grupo1_hit,
	DECIMAL(18,2) AS grupo1_no_hit, DECIMAL(18,2) AS grupo2_hit, DECIMAL(18,2) AS grupo2_no_hit, DECIMAL(18,2) AS grupo3_hit, DECIMAL(18,2) AS grupo3_no_hit,
	DECIMAL(18,2) AS grupo5_hit, DECIMAL(18,2) AS grupo5_no_hit, DECIMAL(18,2) AS grupo6_hit, DECIMAL(18,2) AS grupo6_no_hit, 
	DECIMAL(18,2) AS grupoA_hit, DECIMAL(18,2) AS grupoA_no_hit, DECIMAL(18,2) AS grupo7_hit, DECIMAL(18,2) AS grupo7_no_hit, 
    DECIMAL(18,2) AS grupo8_hit, DECIMAL(18,2) AS grupo8_no_hit,DECIMAL(18,2) AS grupo9_hit, DECIMAL(18,2) AS grupo9_no_hit, DECIMAL(18,2) AS total_x_estatus_hit,
	DECIMAL(18,2) AS total_x_estatus_no_hit, DECIMAL(18,2) AS porc_status_hit, DECIMAL(18,2) AS porc_status_no_hit, DECIMAL(18,2) AS total_x_estatus,
	DECIMAL(18,2) AS porc_status;

DEFINE iSqlErr, iIsamErr,total_sol_rep,total_sol_rep_hit,total_sol_rep_no_hit INTEGER;
DEFINE cErrorInfo CHAR(80); DEFINE cCodRet CHAR(6); DEFINE cMensajeRet VARCHAR(80,1); DEFINE cEmpresa CHAR(3);
DEFINE cStatusSol VARCHAR(3,1); DEFINE cDescripcion VARCHAR(200,1); DEFINE dSituacionPago DECIMAL(5,2);
DEFINE dgrupo1_hit, dgrupo1_no_hit, dgrupo2_hit, dgrupo2_no_hit ,dgrupo3_hit, dgrupo3_no_hit, dGrupo5_hit, dGrupo5_no_hit, dTotalStatus, dTotalGenStatus DECIMAL(18,2);
DEFINE dGrupo6_hit, dGrupo6_no_hit, dGrupoA_hit, dGrupoA_no_hit,dgrupo7_hit, dgrupo7_no_hit, dgrupo8_hit, dgrupo8_no_hit,dgrupo9_hit,dgrupo9_no_hit, dtotal_status_hit,dtotal_status_no_hit,dporc_status_hit,dporc_status_no_hit,ptotal_x_status,ptotal_x_status_hit,ptotal_x_status_no_hit DECIMAL(18,2);
DEFINE cBanCausa,cBanTmp CHAR(1); DEFINE cCausaSol VARCHAR(3,1); DEFINE num_registros SMALLINT;

LET iSqlErr = 0; LET iIsamErr = 0; LET cErrorInfo = ''; LET cCodRet = '000000'; LET cMensajeRet = 'Se ejecutó la consulta correctamente';
LET cEmpresa = ''; LET cStatusSol = ''; LET cDescripcion = ''; LET dSituacionPago = 0; LET dgrupo1_hit = 0; LET dgrupo1_no_hit = 0; LET dgrupo2_hit = 0;
LET dgrupo2_no_hit = 0; LET dgrupo3_hit = 0; LET dgrupo3_no_hit = 0; LET dGrupo5_hit = 0; LET dGrupo5_no_hit = 0; LET dgrupo8_hit = 0; LET dgrupo8_no_hit = 0;LET dgrupo9_hit=0;LEt dgrupo9_no_hit=0;
LET dgrupo6_no_hit = 0; LET dgrupo6_hit = 0; LET dgrupoA_no_hit = 0; LET dgrupoA_hit = 0; LET dgrupo7_hit = 0; LET dgrupo7_no_hit = 0; 
LET dTotalStatus = 0; LET dTotalGenStatus = 0; LET cBanCausa = "";
LET cBanTmp = "N"; LET cCausaSol = ""; LET total_sol_rep = 0; LET total_sol_rep_hit = 0; LET total_sol_rep_no_hit = 0; LET dporc_status_hit = 0; LET dporc_status_no_hit = 0;
LET num_registros = 0; LET dtotal_status_hit = 0; LET dtotal_status_no_hit = 0; LET ptotal_x_status = 0; LET ptotal_x_status_hit = 0; LET ptotal_x_status_no_hit = 0;

BEGIN
ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo

	IF iSqlErr != 0 THEN
		IF cBanTmp = "S" THEN DROP TABLE total; DROP TABLE total_sol_group;

			IF pTpConsulta = '04' THEN DROP TABLE total_sucursal; DROP TABLE resultado_sucursal;
				ELIF pTpConsulta = '01' THEN DROP TABLE total_estado; DROP TABLE resultado_estado;
				ELIF pTpConsulta = '02' THEN DROP TABLE total_ciudad; DROP TABLE resultado_ciudad;
				ELIF pTpConsulta = '03' THEN DROP TABLE total_region; DROP TABLE resultado_region;
			END IF
		END IF;
		LET cCodRet= iSqlErr; LET cMensajeRet= cErrorInfo;
		RETURN cCodRet,cMensajeRet,cDescripcion, cStatusSol,dgrupo1_hit,dgrupo1_no_hit,dgrupo2_hit,dgrupo2_no_hit,dgrupo3_hit,dgrupo3_no_hit,dGrupo5_hit,dGrupo5_no_hit,dgrupo6_hit,dgrupo6_no_hit,dGrupoA_hit,dGrupoA_no_hit,dgrupo7_hit,dgrupo7_no_hit,dgrupo8_hit,dgrupo8_no_hit,dgrupo9_hit,dgrupo9_no_hit,dtotal_status_hit,dtotal_status_no_hit,dporc_status_hit,dporc_status_no_hit,dTotalStatus,dTotalGenStatus;
	END IF;
END EXCEPTION;



--SET DEBUG FILE TO "/informix/jesus/inccat/sp_obtiene_tipoaltaprospecto.out";
--TRACE ON;

IF NVL(pEmpresa,'') = '' THEN
	LET cCodRet = '000001'; LET cMensajeRet = 'Es necesario indicar la empresa para ejecutar el proceso';
	RETURN cCodRet,cMensajeRet,cDescripcion, cStatusSol,dgrupo1_hit,dgrupo1_no_hit,dgrupo2_hit,dgrupo2_no_hit,dgrupo3_hit,dgrupo3_no_hit,dGrupo5_hit,dGrupo5_no_hit,dgrupo6_hit,dgrupo6_no_hit,dGrupoA_hit,dGrupoA_no_hit,dgrupo7_hit,dgrupo7_no_hit,dgrupo8_hit,dgrupo8_no_hit,dgrupo9_hit,dgrupo9_no_hit,dtotal_status_hit,dtotal_status_no_hit,dporc_status_hit,dporc_status_no_hit,dTotalStatus,dTotalGenStatus;
END IF;

SELECT empresa INTO cEmpresa FROM bdinteg:si_empresas WHERE empresa = pEmpresa;

IF NVL(cEmpresa,'') = '' THEN
	LET cCodRet = '000002'; LET cMensajeRet = 'La empresa indicada no es valida';
	RETURN cCodRet,cMensajeRet,cDescripcion, cStatusSol,dgrupo1_hit,dgrupo1_no_hit,dgrupo2_hit,dgrupo2_no_hit,dgrupo3_hit,dgrupo3_no_hit,dGrupo5_hit,dGrupo5_no_hit,dgrupo6_hit,dgrupo6_no_hit,dGrupoA_hit,dGrupoA_no_hit,dgrupo7_hit,dgrupo7_no_hit,dgrupo8_hit,dgrupo8_no_hit,dgrupo9_hit,dgrupo9_no_hit,dtotal_status_hit,dtotal_status_no_hit,dporc_status_hit,dporc_status_no_hit,dTotalStatus,dTotalGenStatus;
END IF;

IF NVL(pTpConsulta,"") = "" THEN
	LET cCodRet = "000003"; LET cMensajeRet = "Es necesario indicar el tipo de consulta a realizar";
	RETURN cCodRet,cMensajeRet,cDescripcion, cStatusSol,dgrupo1_hit,dgrupo1_no_hit,dgrupo2_hit,dgrupo2_no_hit,dgrupo3_hit,dgrupo3_no_hit,dGrupo5_hit,dGrupo5_no_hit,dgrupo6_hit,dgrupo6_no_hit,dGrupoA_hit,dGrupoA_no_hit,dgrupo7_hit,dgrupo7_no_hit,dgrupo8_hit,dgrupo8_no_hit,dgrupo9_hit,dgrupo9_no_hit,dtotal_status_hit,dtotal_status_no_hit,dporc_status_hit,dporc_status_no_hit,dTotalStatus,dTotalGenStatus;
END IF;

IF NVL(pFechaIni,"") = "" AND NVL(pFechaFin, "") = "" THEN
	LET cCodRet = "000004"; LET cMensajeRet = "Es necesario indicar al menos una fecha";
	RETURN cCodRet,cMensajeRet,cDescripcion, cStatusSol,dgrupo1_hit,dgrupo1_no_hit,dgrupo2_hit,dgrupo2_no_hit,dgrupo3_hit,dgrupo3_no_hit,dGrupo5_hit,dGrupo5_no_hit,dgrupo6_hit,dgrupo6_no_hit,dGrupoA_hit,dGrupoA_no_hit,dgrupo7_hit,dgrupo7_no_hit,dgrupo8_hit,dgrupo8_no_hit,dgrupo9_hit,dgrupo9_no_hit,dtotal_status_hit,dtotal_status_no_hit,dporc_status_hit,dporc_status_no_hit,dTotalStatus,dTotalGenStatus;
END IF;

IF (NVL(pFechaIni,"") <> "" AND NVL(pFechaFin, "") <> "") AND (pFechaIni > pFechaFin) THEN
	LET cCodRet = "000005"; LET cMensajeRet = "La fecha inicial no debe ser mayor a la fecha final";
	RETURN cCodRet,cMensajeRet,cDescripcion, cStatusSol,dgrupo1_hit,dgrupo1_no_hit,dgrupo2_hit,dgrupo2_no_hit,dgrupo3_hit,dgrupo3_no_hit,dGrupo5_hit,dGrupo5_no_hit,dgrupo6_hit,dgrupo6_no_hit,dGrupoA_hit,dGrupoA_no_hit,dgrupo7_hit,dgrupo7_no_hit,dgrupo8_hit,dgrupo8_no_hit,dgrupo9_hit,dgrupo9_no_hit,dtotal_status_hit,dtotal_status_no_hit,dporc_status_hit,dporc_status_no_hit,dTotalStatus,dTotalGenStatus;
END IF;

LET cBanTmp = "S";

IF pFechaIni IS NULL THEN LET pFechaIni = DATE(1); END IF; 
IF pFechaFin IS NULL THEN LET pFechaFin = pFechaIni; END IF;
	IF pEstatus IN ('AT','AP') THEN
	create temp table sol5
(numcte char(20),
status_solicitud char(2), 
sucursal char(4),
abonomensualropa money , 
abonomensualmuebles money, 
abonomensualprestamos money, 
compromisos_bco decimal (14,2),
fecha_insert date ,
autoriza_gte integer,
confirmado  CHAR(1),--JMAH RQM 09 420
grupo1_hit integer,
grupo1_no_hit integer,
grupo2_hit integer,
grupo2_no_hit integer,
grupo3_hit integer,
grupo3_no_hit integer,
grupo5_hit integer,
grupo5_no_hit integer,
grupo6_hit integer,
grupo6_no_hit integer,
grupoA_hit integer,
grupoA_no_hit integer,
grupo7_hit integer, 
grupo7_no_hit integer,
grupo8_hit integer,
grupo8_no_hit integer,
grupo9_hit integer,
grupo9_no_hit integer,
cantidad integer,
cantidad_hit integer,
cantidad_no_hit integer) with no log;

create temp table sol4
( numcte char(20),
  tipo_alta char(3)
) with no log;

create temp table sol3
(numcte char(20),
status_solicitud char(2), 
sucursal char(4),
abonomensualropa money , 
abonomensualmuebles money, 
abonomensualprestamos money, 
compromisos_bco decimal (14,2),
fecha_insert date ,
autoriza_gte integer,
confirmado  CHAR(1),--JMAH RQM 09 420
grupo1_hit integer,
grupo1_no_hit integer,
grupo2_hit integer,
grupo2_no_hit integer,
grupo3_hit integer,
grupo3_no_hit integer,
grupo5_hit integer,
grupo5_no_hit integer,
grupo6_hit integer,
grupo6_no_hit integer,
grupoA_hit integer,
grupoA_no_hit integer,
grupo7_hit integer, 
grupo7_no_hit integer,
grupo8_hit integer,
grupo8_no_hit integer,
grupo9_hit integer,
grupo9_no_hit integer,
cantidad integer,
cantidad_hit integer,
cantidad_no_hit integer,
tipo_alta char(3),
tipo_alta_causa char(3)--JMAH RQM 09 420
) with no log;

create temp table total
(numcte char(20),
status_solicitud char(2), 
sucursal char(4),
abonomensualropa money , 
abonomensualmuebles money, 
abonomensualprestamos money, 
compromisos_bco decimal (14,2),
fecha_insert date ,
autoriza_gte integer,
confirmado  CHAR(1),--JMAH RQM 09 420
grupo1_hit integer,
grupo1_no_hit integer,
grupo2_hit integer,
grupo2_no_hit integer,
grupo3_hit integer,
grupo3_no_hit integer,
grupo5_hit integer,
grupo5_no_hit integer,
grupo6_hit integer,
grupo6_no_hit integer,
grupoA_hit integer,
grupoA_no_hit integer,
grupo7_hit integer, 
grupo7_no_hit integer,
grupo8_hit integer,
grupo8_no_hit integer,
grupo9_hit integer,
grupo9_no_hit integer,
cantidad integer,
cantidad_hit integer,
cantidad_no_hit integer,
tipo_alta char(3),
tipo_alta_causa char(3), --JMAH RQM 09 420
descripcion char(40),
orden_reporte smallint,
ciudad char(3),
estado char(2),
numero_region smallint
) with no log;

		insert into sol5
		SELECT a.numcte,a.status_solicitud, a.sucursal,b.abonomensualropa, b.abonomensualmuebles, b.abonomensualprestamos, b.compromisos_bco,a.fecha_insert,
		(CASE WHEN (nvl(c.causa_solicitud,'') <> '') AND cau.tipo_auto <> 3 THEN 1 
			ELSE  CASE WHEN (nvl(c.causa_solicitud,'') <> '') AND cau.tipo_auto = 3 THEN 2
			ELSE CASE WHEN (nvl(c.causa_solicitud,'') = '') AND a.num_solicitud in (select num_solicitud from bdisolic:ss_solicitud_os) THEN 3
			ELSE CASE WHEN (nvl(c.causa_solicitud,'') = '')  THEN 5
			ELSE 4 END END END END ) autoriza_gte,
			CASE WHEN (	SELECT COUNT(*)
				FROM bdinteg:"informix".si_telefonos
				WHERE numcte = a.numcte
				AND tipo_tel in (1,2) 
				AND status_tel = 'A' 
				AND NVL(verificado,'F') = 'V') >= 1 THEN 'V' ELSE 'F'END ,   
		sum(CASE WHEN (nvl(b.grupo,'') in ('1','4')) AND b.evalua_cc IN ('0','1','2','3','4') and rev.excluye_validacion = 0 THEN 1 ELSE 0 END ) grupo1_hit,
		sum(CASE WHEN (nvl(b.grupo,'') in ('1','4')) AND NVL(b.evalua_cc,'') IN ('X','') and rev.excluye_validacion = 0 THEN 1 ELSE 0 END) grupo1_no_hit,
		sum(CASE WHEN (nvl(b.grupo,'') = '2') AND b.evalua_cc IN ('0','1','2','3','4') and rev.excluye_validacion = 0 THEN 1 ELSE 0 END) grupo2_hit,
		sum(CASE WHEN (nvl(b.grupo,'') = '2') AND NVL(b.evalua_cc,'') IN ('X','') and rev.excluye_validacion = 0 THEN 1 ELSE 0 END) grupo2_no_hit,
		sum(CASE WHEN (nvl(b.grupo,'') = '3') AND b.evalua_cc IN ('0','1','2','3','4') and rev.excluye_validacion = 0 THEN 1 ELSE 0 END) grupo3_hit,
		sum(CASE WHEN (nvl(b.grupo,'') = '3') AND NVL(b.evalua_cc,'') IN ('X','') and rev.excluye_validacion = 0 THEN 1 ELSE 0 END) grupo3_no_hit,
		sum(CASE WHEN (nvl(b.grupo,'') = '5') AND b.evalua_cc in ('0','1','2','3','4')and rev.excluye_validacion = 0  THEN 1 ELSE 0 END) grupo5_hit,
		sum(CASE WHEN (nvl(b.grupo,'') = '5') AND NVL(b.evalua_cc,'') IN ('X','') and rev.excluye_validacion = 0 THEN 1 ELSE 0 END) grupo5_no_hit,
		sum(CASE WHEN (nvl(b.Grupo,'') = '6') AND b.evalua_cc IN ('0','1','2','3','4') and rev.excluye_validacion = 0 THEN 1 ELSE 0 END) grupo6_hit,
		sum(CASE WHEN (nvl(b.Grupo,'') = '6') AND NVL(b.evalua_cc,'') IN ('X','') and rev.excluye_validacion = 0THEN 1 ELSE 0 END) grupo6_no_hit,
		sum(CASE WHEN (nvl(b.Grupo,'') = 'A') AND b.evalua_cc IN ('0','1','2','3','4') and rev.excluye_validacion = 0 THEN 1 ELSE 0 END) grupoA_hit,
		sum(CASE WHEN (nvl(b.Grupo,'') = 'A') AND NVL(b.evalua_cc,'') IN ('X','') and rev.excluye_validacion = 0 THEN 1 ELSE 0 END) grupoA_no_hit,
		0 grupo7_hit, SUM(CASE WHEN (nvl(b.Grupo,'') = '7') OR (NVL(pr.tipo_alta,'') = '2' and nvl(a.num_producto,'') = '6500')and rev.excluye_validacion = 0 THEN 1 ELSE 0 END ) grupo7_no_hit,
        SUM(CASE WHEN (nvl(b.Grupo,'') = '8') AND b.evalua_cc IN ('0','1','2','3','4') and rev.excluye_validacion = 0THEN 1 ELSE 0 END ) grupo8_hit,
		SUM(CASE WHEN (nvl(b.Grupo,'') = '8') AND NVL(b.evalua_cc,'') IN ('X','')and rev.excluye_validacion = 0 THEN 1 ELSE 0 END ) grupo8_no_hit,SUM(CASE WHEN rev.excluye_validacion = 1 AND b.evalua_cc IN ('0','1','2','3','4') THEN 1 ELSE 0 END ) grupo9_hit,
			SUM(CASE WHEN rev.excluye_validacion = 1 AND b.evalua_cc IN ('X','') THEN 1 ELSE 0 END ) grupo9_no_hit,
		sum(CASE WHEN (nvl(b.grupo,'') in ('1','4')) and rev.excluye_validacion = 0 THEN 1 ELSE 0 END +
			CASE WHEN (nvl(b.grupo,'') = '2') and rev.excluye_validacion = 0 THEN 1 ELSE 0 END +
			CASE WHEN (nvl(b.grupo,'') = '3') and rev.excluye_validacion = 0 THEN 1 ELSE 0 END +
			CASE WHEN (nvl(b.grupo,'') = '5') and rev.excluye_validacion = 0 THEN 1 ELSE 0 END +
			CASE WHEN (nvl(b.Grupo,'') = '6')and rev.excluye_validacion = 0 THEN 1 ELSE 0 END +
			CASE WHEN (nvl(b.Grupo,'') = 'A')and rev.excluye_validacion = 0 THEN 1 ELSE 0 END +
			CASE WHEN (nvl(b.Grupo,'') = '7') OR (NVL(pr.tipo_alta,'') = '2' and nvl(a.num_producto,'') = '6500')and rev.excluye_validacion = 0 THEN 1 ELSE 0 END +
            CASE WHEN (nvl(b.Grupo,'') = '8') and rev.excluye_validacion = 0 THEN 1 ELSE 0 END+(CASE WHEN rev.excluye_validacion = 1  THEN 1 ELSE 0 END )) cantidad,
		sum(CASE WHEN (nvl(b.grupo,'') in ('1','4')) AND b.evalua_cc IN ('0','1','2','3','4') and rev.excluye_validacion = 0 THEN 1 ELSE 0 END +
			CASE WHEN (nvl(b.grupo,'') = '2') AND b.evalua_cc IN ('0','1','2','3','4') and rev.excluye_validacion = 0 THEN 1 ELSE 0 END +
			CASE WHEN (nvl(b.grupo,'') = '3') AND b.evalua_cc IN ('0','1','2','3','4') and rev.excluye_validacion = 0 THEN 1 ELSE 0 END +
			CASE WHEN (nvl(b.grupo,'') = '5') AND b.evalua_cc in ('0','1','2','3','4') and rev.excluye_validacion = 0 THEN 1 ELSE 0 END +
			CASE WHEN (nvl(b.Grupo,'') = '6') AND b.evalua_cc IN ('0','1','2','3','4') and rev.excluye_validacion = 0 THEN 1 ELSE 0 END + CASE WHEN (nvl(b.Grupo,'') = 'A') AND b.evalua_cc IN ('0','1','2','3','4')  THEN 1 ELSE 0 END +
            CASE WHEN (nvl(b.Grupo,'') = '8') AND b.evalua_cc IN ('0','1','2','3','4') and rev.excluye_validacion = 0 THEN 1 ELSE 0 END  +(CASE WHEN rev.excluye_validacion = 1 AND b.evalua_cc IN ('0','1','2','3','4') THEN 1 ELSE 0 END )) cantidad_hit,
		sum(CASE WHEN (nvl(b.grupo,'') in ('1','4')) AND NVL(b.evalua_cc,'') IN ('X','') and rev.excluye_validacion = 0 THEN 1 ELSE 0 END +
			CASE WHEN (nvl(b.grupo,'') = '2') AND NVL(b.evalua_cc,'') IN ('X','') and rev.excluye_validacion = 0 THEN 1 ELSE 0 END +
			CASE WHEN (nvl(b.grupo,'') = '3') AND NVL(b.evalua_cc,'') IN ('X','') and rev.excluye_validacion = 0 THEN 1 ELSE 0 END +
			CASE WHEN (nvl(b.grupo,'') = '5') AND NVL(b.evalua_cc,'') IN ('X','')and rev.excluye_validacion = 0 THEN 1 ELSE 0 END+
			CASE WHEN (nvl(b.Grupo,'') = '6') AND NVL(b.evalua_cc,'') IN ('X','') and rev.excluye_validacion = 0 THEN 1 ELSE 0 END + CASE WHEN (nvl(b.Grupo,'') = 'A') AND NVL(b.evalua_cc,'') IN ('X','')  and rev.excluye_validacion = 0 THEN 1 ELSE 0 END +
			CASE WHEN (nvl(b.Grupo,'') = '7') OR (NVL(pr.tipo_alta,'') = '2' and nvl(a.num_producto,'') = '6500') and rev.excluye_validacion = 0 THEN 1 ELSE 0 END +
            CASE WHEN (nvl(b.Grupo,'') = '8') AND NVL(b.evalua_cc,'') IN ('X','') and rev.excluye_validacion = 0 THEN 1 ELSE 0 END +(CASE WHEN rev.excluye_validacion = 1 AND b.evalua_cc IN ('X','') THEN 1 ELSE 0 END ) ) cantidad_no_hit
		from bdisolic:ss_solicitudes a,bdisolic:ss_resum_scor_fin b, bdisolic:ss_autorizacion c ,
		Outer bdisolic:ss_causas_sol cau ,
			outer bdiprospectos:pr_cliente pr	, outer  "informix".ss_revision_determinacion rev	
		WHERE a.empresa = b.empresa AND a.num_solicitud = b.num_solicitud AND a.empresa = c.empresa AND a.num_solicitud = c.num_solicitud AND a.status_solicitud = c.status_solicitud and a.numcte = pr.numcte
		AND  cau.status_solicitud = a.status_solicitud 
		And rev.empresa= a.empresa and rev.num_solicitud= a.num_solicitud
		and cau.causa_solicitud = c.causa_solicitud
		AND c.fecha_entrada = (select max(fecha_entrada) from bdisolic:ss_autorizacion where a.empresa = empresa and a.num_solicitud = num_solicitud and a.status_solicitud = status_solicitud)
		AND a.num_producto = 	pProducto AND a.fecha_insert >= pFechaIni AND a.fecha_insert <= pFechaFin AND a.status_solicitud = pEstatus and pr.tipo_alta = '2'
		GROUP BY 1,2,3,4,5,6,7,8,9; -- INTO temp sol5 WITH NO LOG;
		
		insert into sol4
		SELECT a.numcte,(CASE WHEN a.tipo_alta = 1 AND b.autoriza_gte = 0 THEN 'ASP' WHEN a.tipo_alta = 1 AND b.autoriza_gte = 1 THEN 'ASG'
			WHEN a.tipo_alta = 2 AND b.autoriza_gte = 0 THEN 'ACP' WHEN a.tipo_alta = 2 AND b.autoriza_gte = 1 THEN 'ACG' WHEN b.autoriza_gte = 5 THEN 'APN'  ELSE a.tipo_alta END) as tipo_alta
			FROM bdiprospectos:pr_cliente a, sol5 b WHERE a.numcte = b.numcte;
			
		insert into  sol3	
		SELECT a.*, (CASE WHEN nvl(b.tipo_alta, '') <> '' THEN b.tipo_alta 
						WHEN nvl(b.tipo_alta, '') = '' AND a.autoriza_gte = 1 THEN 'ASG'
						WHEN nvl(b.tipo_alta, '') = '' AND a.autoriza_gte = 2 THEN 'ACG'
						WHEN nvl(b.tipo_alta, '') = '' AND a.autoriza_gte = 3 THEN 'ACP' 
						WHEN nvl(b.tipo_alta, '') = '' AND a.autoriza_gte = 4 THEN 'ASP' 
						WHEN nvl(b.tipo_alta, '') = '' AND a.autoriza_gte = 5 THEN 'APN' ELSE '' END) as tipo_alta ,
						CASE WHEN NVL(a.confirmado,'') =  'V'  THEN 'CTC' ELSE 'STC' END
			FROM sol5 a LEFT OUTER JOIN sol4 b ON a.numcte = b.numcte;
	END IF;
    insert into total
	SELECT a.*,b.descripcion, b.orden_reporte, c.ciudad, c.estado, r.numero_region
		FROM sol3 a,bdisolic:ss_status_sol b,bdinteg:si_sucursales s,bdinteg:si_ciudades c ,bdinteg:si_catciudades t
		left outer join bdinteg:si_regiones r on ( t.numero_region = r.numero_region)
	WHERE b.empresa = pEmpresa AND a.status_solicitud = b.status_solicitud AND activa_reporte = "1" AND a.sucursal = s.sucursal 
	AND s.ciudad = c.ciudad AND s.pais = c.pais AND s.estado = c.estado AND c.ciudad_coppel = t.numerociudad; 
	--INTO temp total with no log;
	
	create temp table total_sol_group
( descripcion char(100),
  tipo_alta  char(3), 
  tipo_alta_causa  char(3), 
grupo1_hit integer,
grupo1_no_hit integer, 
grupo2_hit integer,
grupo2_no_hit integer,
grupo3_hit integer,
grupo3_no_hit integer, 
grupo5_hit integer,
grupo5_no_hit integer,
grupo6_hit integer,
grupo6_no_hit integer,  
grupoA_hit integer,
grupoA_no_hit integer,
grupo7_hit integer,
grupo7_no_hit integer,
grupo8_hit integer,
grupo8_no_hit integer,
grupo9_hit integer,
grupo9_no_hit integer,
total_x_status_hit integer,
total_x_status_no_hit integer,
porc_status_hit decimal (14,2),
porc_status_no_hit decimal (14,2),
total_x_status	integer,
porc_status decimal (14,2),
orden_reporte smallint
) with no log;

create temp table total_sol_group2
( descripcion char(100),
  tipo_alta  char(3), 
  tipo_alta_causa  char(3), 
grupo1_hit integer,
grupo1_no_hit integer, 
grupo2_hit integer,
grupo2_no_hit integer,
grupo3_hit integer,
grupo3_no_hit integer, 
grupo5_hit integer,
grupo5_no_hit integer,
grupo6_hit integer,
grupo6_no_hit integer,  
grupoA_hit integer,
grupoA_no_hit integer,
grupo7_hit integer,
grupo7_no_hit integer,
grupo8_hit integer,
grupo8_no_hit integer,
grupo9_hit integer,
grupo9_no_hit integer,
total_x_status_hit integer,
total_x_status_no_hit integer,
porc_status_hit decimal (14,2),
porc_status_no_hit decimal (14,2),
total_x_status	integer,
porc_status decimal (14,2),
orden_reporte smallint
) with no log;

	IF pTpConsulta = '04' THEN ---SUCURSAL
		create temp table total_sucursal
	    (  sucursal char(4),
		   total integer,
		   total_hit integer,
		   total_no_hit integer
	     ) with no log;
		 
		 create temp table resultado_sucursal
(numcte char(20),
status_solicitud char(2), 
sucursal char(4),
abonomensualropa money , 
abonomensualmuebles money, 
abonomensualprestamos money, 
compromisos_bco decimal (14,2),
fecha_insert date ,
autoriza_gte integer,
confirmado  CHAR(1),--JMAH RQM 09 420
grupo1_hit integer,
grupo1_no_hit integer,
grupo2_hit integer,
grupo2_no_hit integer,
grupo3_hit integer,
grupo3_no_hit integer,
grupo5_hit integer,
grupo5_no_hit integer,
grupo6_hit integer,
grupo6_no_hit integer,
grupoA_hit integer,
grupoA_no_hit integer,
grupo7_hit integer, 
grupo7_no_hit integer,
grupo8_hit integer,
grupo8_no_hit integer,
grupo9_hit integer,
grupo9_no_hit integer,
cantidad integer,
cantidad_hit integer,
cantidad_no_hit integer,
tipo_alta char(3),
tipo_alta_causa char(3), --JMAH RQM 09 420
descripcion char(40),
orden_reporte smallint,
ciudad char(3),
estado char(2),
numero_region smallint,
total_porcentaje decimal(5,2) , 
total_porc_hit decimal(5,2),
total_porc_no_hit decimal(5,2)
) with no log;

		 insert INTO  total_sucursal
		SELECT sucursal, sum(cantidad) total,sum(cantidad_hit) total_hit,sum(cantidad_no_hit) total_no_hit FROM total group by 1; --INTO temp total_sucursal with no log;
		IF pFiltro <> '' AND pEstatus <> '' THEN
			SELECT sum(cantidad),sum(cantidad_hit),sum(cantidad_no_hit) INTO total_sol_rep,total_sol_rep_hit,total_sol_rep_no_hit FROM total WHERE sucursal = pFiltro AND status_solicitud = pEstatus;
		ELSE
			SELECT sum(total),sum(total_hit),sum(total_no_hit) INTO total_sol_rep,total_sol_rep_hit,total_sol_rep_no_hit FROM total_sucursal;
		END IF;
		insert into resultado_sucursal
		SELECT a.*, round(cantidad / total * 100,2) total_porcentaje, CASE WHEN total_hit > 0 THEN round(cantidad_hit / total_hit * 100,2) ELSE 0 END total_porc_hit,CASE WHEN total_no_hit > 0 THEN round(cantidad_no_hit / total_no_hit * 100,2) ELSE 0 END total_porc_no_hit
		FROM total a, bdisolic:ss_status_sol b, total_sucursal c
		WHERE b.empresa = pEmpresa AND a.status_solicitud = b.status_solicitud AND a.sucursal = c.sucursal AND activa_reporte = "1";
		--INTO temp resultado_sucursal WITH NO LOG;

		IF (pFiltro = '' AND pEstatus <> '') or (pFiltro <> '' AND pEstatus <> '') THEN	--DETALLE
			
			insert into total_sol_group
			SELECT c.descripcion,a.tipo_alta,'', sum(a.grupo1_hit) as grupo1_hit,sum(a.grupo1_no_hit) as grupo1_no_hit, sum(a.grupo2_hit) as grupo2_hit,sum(a.grupo2_no_hit) as grupo2_no_hit,
			sum(a.grupo3_hit) as grupo3_hit,sum(a.grupo3_no_hit) as grupo3_no_hit, sum(grupo5_hit) as grupo5_hit,sum(grupo5_no_hit) as grupo5_no_hit,
			sum(a.grupo6_hit) as grupo6_hit,sum(a.grupo6_no_hit) as grupo6_no_hit, sum(a.grupoA_hit) as grupoA_hit,sum(a.grupoA_no_hit) as grupoA_no_hit,sum(grupo7_hit) as grupo7_hit,sum(grupo7_no_hit) as grupo7_no_hit,
            sum(a.grupo8_hit) as grupo8_hit,sum(a.grupo8_no_hit) as grupo8_no_hit,
			 sum(a.grupo9_hit) as grupo9_hit,sum(a.grupo9_no_hit) as grupo9_no_hit,
			sum(a.cantidad_hit) as total_x_status_hit,sum(a.cantidad_no_hit) as total_x_status_no_hit,
			ROUND((sum(a.cantidad_hit) / case when total_sol_rep_hit = 0 then 1 else total_sol_rep_hit end) * 100,2) as porc_status_hit,
			ROUND((sum(a.cantidad_no_hit) / case when total_sol_rep_no_hit = 0 then 1 else total_sol_rep_no_hit end) * 100,2) as porc_status_no_hit,
			sum(a.cantidad) as total_x_status,ROUND((sum(a.cantidad) / case when total_sol_rep = 0 then 1 else total_sol_rep end) * 100,2) as porc_status,
			c.orden_reporte --MOD
			FROM total a, bdisolic:ss_status_sol b,bdisolic:ss_causas_sol c
			WHERE a.status_solicitud = b.status_solicitud AND a.status_solicitud = c.status_solicitud
			AND a.tipo_alta = c.causa_solicitud AND ( a.sucursal = pFiltro or pFiltro='')
			AND (a.status_solicitud = pEstatus or pEstatus='') AND b.activa_reporte = c.activa_reporte
			AND b.activa_reporte = "1"
		GROUP BY c.descripcion,a.tipo_alta,c.orden_reporte;
		
			
			insert into total_sol_group2
			SELECT c.descripcion,a.tipo_alta,a.tipo_alta_causa, sum(a.grupo1_hit) as grupo1_hit,sum(a.grupo1_no_hit) as grupo1_no_hit, sum(a.grupo2_hit) as grupo2_hit,sum(a.grupo2_no_hit) as grupo2_no_hit,
			sum(a.grupo3_hit) as grupo3_hit,sum(a.grupo3_no_hit) as grupo3_no_hit, sum(grupo5_hit) as grupo5_hit,sum(grupo5_no_hit) as grupo5_no_hit,
			sum(a.grupo6_hit) as grupo6_hit,sum(a.grupo6_no_hit) as grupo6_no_hit, sum(a.grupoA_hit) as grupoA_hit,sum(a.grupoA_no_hit) as grupoA_no_hit,sum(grupo7_hit) as grupo7_hit,sum(grupo7_no_hit) as grupo7_no_hit,
            sum(a.grupo8_hit) as grupo8_hit,sum(a.grupo8_no_hit) as grupo8_no_hit,
			 sum(a.grupo9_hit) as grupo9_hit,sum(a.grupo9_no_hit) as grupo9_no_hit,
			sum(a.cantidad_hit) as total_x_status_hit,sum(a.cantidad_no_hit) as total_x_status_no_hit,
			ROUND((sum(a.cantidad_hit) / case when total_sol_rep_hit = 0 then 1 else total_sol_rep_hit end) * 100,2) as porc_status_hit,
			ROUND((sum(a.cantidad_no_hit) / case when total_sol_rep_no_hit = 0 then 1 else total_sol_rep_no_hit end) * 100,2) as porc_status_no_hit,
			sum(a.cantidad) as total_x_status,ROUND((sum(a.cantidad) / case when total_sol_rep = 0 then 1 else total_sol_rep end) * 100,2) as porc_status,
			c.orden_reporte --MOD
			FROM total a, bdisolic:ss_status_sol b,bdisolic:ss_causas_sol c
			WHERE a.status_solicitud = b.status_solicitud AND a.status_solicitud = c.status_solicitud
			AND a.tipo_alta = c.causa_solicitud AND ( a.sucursal = pFiltro or pFiltro='')
			AND (a.status_solicitud = pEstatus or pEstatus='') AND b.activa_reporte = c.activa_reporte
			AND b.activa_reporte = "1"
		GROUP BY c.descripcion,a.tipo_alta,a.tipo_alta_causa,c.orden_reporte; --ORDER BY c.orden_reporte  --INTO temp total_sol_group WITH NO LOG;
		END IF;
	END IF;

	IF pTpConsulta	 = '01' THEN ---ESTADO
	create temp table total_estado
	    (  estado char(2),
		   total integer,
		   total_hit integer,
		   total_no_hit integer
	     ) with no log;
		 
create temp table resultado_estado
(numcte char(20),
status_solicitud char(2), 
sucursal char(4),
abonomensualropa money , 
abonomensualmuebles money, 
abonomensualprestamos money, 
compromisos_bco decimal (14,2),
fecha_insert date ,
autoriza_gte integer,
confirmado  CHAR(1),--JMAH RQM 09 420
grupo1_hit integer,
grupo1_no_hit integer,
grupo2_hit integer,
grupo2_no_hit integer,
grupo3_hit integer,
grupo3_no_hit integer,
grupo5_hit integer,
grupo5_no_hit integer,
grupo6_hit integer,
grupo6_no_hit integer,
grupoA_hit integer,
grupoA_no_hit integer,
grupo7_hit integer, 
grupo7_no_hit integer,
grupo8_hit integer,
grupo8_no_hit integer,
grupo9_hit integer,
grupo9_no_hit integer,
cantidad integer,
cantidad_hit integer,
cantidad_no_hit integer,
tipo_alta char(3),
tipo_alta_causa char(3), --JMAH RQM 09 420
descripcion char(40),
orden_reporte smallint,
ciudad char(3),
estado char(2),
numero_region smallint,
total_porcentaje decimal(5,2) , 
total_porc_hit decimal(5,2),
total_porc_no_hit decimal(5,2)
) with no log;
		 
			insert into total_estado
			SELECT estado, sum(cantidad) total,sum(cantidad_hit) total_hit,sum(cantidad_no_hit) total_no_hit FROM total GROUP BY 1; -- INTO temp total_estado with no log;
			insert into resultado_estado
			SELECT a.*, round(cantidad / total * 100,2) total_porcentaje, CASE WHEN total_hit > 0 THEN round(cantidad_hit / total_hit * 100,2) ELSE 0 END total_porc_hit, CASE WHEN total_no_hit > 0 THEN round(cantidad_no_hit / total_no_hit * 100,2) ELSE 0 END total_porc_no_hit
			FROM total a, bdisolic:ss_status_sol b, total_estado c
			WHERE b.empresa = pEmpresa AND a.status_solicitud = b.status_solicitud AND a.estado = c.estado AND activa_reporte = "1"; -- INTO temp resultado_estado WITH NO LOG;

		IF pFiltro <> '' AND pEstatus <> '' THEN
			SELECT sum(cantidad),sum(cantidad_hit),sum(cantidad_no_hit) INTO total_sol_rep,total_sol_rep_hit,total_sol_rep_no_hit FROM total WHERE estado = pFiltro AND status_solicitud = pEstatus;
		ELSE 
			SELECT sum(total),sum(total_hit),sum(total_no_hit) INTO total_sol_rep,total_sol_rep_hit,total_sol_rep_no_hit FROM total_estado;
		END IF;

		IF (pFiltro = '' AND pEstatus <> '') or (pFiltro <> '' AND pEstatus <> '') THEN
			insert into total_sol_group
			SELECT c.descripcion,a.tipo_alta,'',sum(a.grupo1_hit) as grupo1_hit,sum(a.grupo1_no_hit) as grupo1_no_hit,sum(a.grupo2_hit) as grupo2_hit,sum(a.grupo2_no_hit) as grupo2_no_hit,
			sum(a.grupo3_hit) as grupo3_hit,sum(a.grupo3_no_hit) as grupo3_no_hit,sum(grupo5_hit) as grupo5_hit,sum(grupo5_no_hit) as grupo5_no_hit,
			sum(a.grupo6_hit) as grupo6_hit,sum(a.grupo6_no_hit) as grupo6_no_hit, sum(a.grupoA_hit) as grupoA_hit,sum(a.grupoA_no_hit) as grupoA_no_hit,sum(grupo7_hit) as grupo7_hit,sum(grupo7_no_hit) as grupo7_no_hit,
            sum(a.grupo8_hit) as grupo8_hit,sum(a.grupo8_no_hit) as grupo8_no_hit,
			 sum(a.grupo9_hit) as grupo9_hit,sum(a.grupo9_no_hit) as grupo9_no_hit,
			sum(a.cantidad_hit) as total_x_status_hit,sum(a.cantidad_no_hit) as total_x_status_no_hit,
			ROUND((sum(a.cantidad_hit) / case when total_sol_rep_hit = 0 then 1 else total_sol_rep_hit end) * 100,2) as porc_status_hit,
			ROUND((sum(a.cantidad_no_hit) / case when total_sol_rep_no_hit = 0 then 1 else total_sol_rep_no_hit end) * 100,2) as porc_status_no_hit,
			sum(a.cantidad) as total_x_status,ROUND((sum(a.cantidad) / case when total_sol_rep = 0 then 1 else total_sol_rep end) * 100,2) as porc_status,
			c.orden_reporte
			FROM total a, bdisolic:ss_status_sol b,bdisolic:ss_causas_sol c
			WHERE a.status_solicitud = b.status_solicitud AND a.status_solicitud = c.status_solicitud AND a.tipo_alta = c.causa_solicitud
			AND (a.estado = pFiltro or pFiltro='') AND (a.status_solicitud = pEstatus or pEstatus='') AND b.activa_reporte = c.activa_reporte AND b.activa_reporte = "1"
			GROUP BY c.descripcion,a.tipo_alta,c.orden_reporte; --ORDER BY c.orden_reporte;  --INTO temp total_sol_group WITH NO LOG;
			
			insert into total_sol_group2
			SELECT c.descripcion,a.tipo_alta,a.tipo_alta_causa,sum(a.grupo1_hit) as grupo1_hit,sum(a.grupo1_no_hit) as grupo1_no_hit,sum(a.grupo2_hit) as grupo2_hit,sum(a.grupo2_no_hit) as grupo2_no_hit,
			sum(a.grupo3_hit) as grupo3_hit,sum(a.grupo3_no_hit) as grupo3_no_hit,sum(grupo5_hit) as grupo5_hit,sum(grupo5_no_hit) as grupo5_no_hit,
			sum(a.grupo6_hit) as grupo6_hit,sum(a.grupo6_no_hit) as grupo6_no_hit, sum(a.grupoA_hit) as grupoA_hit,sum(a.grupoA_no_hit) as grupoA_no_hit,sum(grupo7_hit) as grupo7_hit,sum(grupo7_no_hit) as grupo7_no_hit,
            sum(a.grupo8_hit) as grupo8_hit,sum(a.grupo8_no_hit) as grupo8_no_hit,
			sum(a.grupo9_hit) as grupo9_hit,sum(a.grupo9_no_hit) as grupo9_no_hit,
			sum(a.cantidad_hit) as total_x_status_hit,sum(a.cantidad_no_hit) as total_x_status_no_hit,
			ROUND((sum(a.cantidad_hit) / case when total_sol_rep_hit = 0 then 1 else total_sol_rep_hit end) * 100,2) as porc_status_hit,
			ROUND((sum(a.cantidad_no_hit) / case when total_sol_rep_no_hit = 0 then 1 else total_sol_rep_no_hit end) * 100,2) as porc_status_no_hit,
			sum(a.cantidad) as total_x_status,ROUND((sum(a.cantidad) / case when total_sol_rep = 0 then 1 else total_sol_rep end) * 100,2) as porc_status,
			c.orden_reporte
			FROM total a, bdisolic:ss_status_sol b,bdisolic:ss_causas_sol c
			WHERE a.status_solicitud = b.status_solicitud AND a.status_solicitud = c.status_solicitud AND a.tipo_alta = c.causa_solicitud
			AND (a.estado = pFiltro or pFiltro='') AND (a.status_solicitud = pEstatus or pEstatus='') AND b.activa_reporte = c.activa_reporte AND b.activa_reporte = "1"
			GROUP BY c.descripcion,a.tipo_alta,a.tipo_alta_causa,c.orden_reporte; --ORDER BY c.orden_reporte;  --INTO temp total_sol_group WITH NO LOG;
			
			
		END IF;
	END IF;

	IF pTpConsulta	 = '02' THEN ---CIUDAD
	create temp table total_ciudad
	    (  ciudad char(3),
		   estado char(2),
		   total integer,
		   total_hit integer,
		   total_no_hit integer
	     ) with no log;		 
create temp table resultado_ciudad
(numcte char(20),
status_solicitud char(2), 
sucursal char(4),
abonomensualropa money , 
abonomensualmuebles money, 
abonomensualprestamos money, 
compromisos_bco decimal (14,2),
fecha_insert date ,
autoriza_gte integer,
confirmado  CHAR(1),--JMAH RQM 09 420
grupo1_hit integer,
grupo1_no_hit integer,
grupo2_hit integer,
grupo2_no_hit integer,
grupo3_hit integer,
grupo3_no_hit integer,
grupo5_hit integer,
grupo5_no_hit integer,
grupo6_hit integer,
grupo6_no_hit integer,
grupoA_hit integer,
grupoA_no_hit integer,
grupo7_hit integer, 
grupo7_no_hit integer,
grupo8_hit integer,
grupo8_no_hit integer,
grupo9_hit integer,
grupo9_no_hit integer,
cantidad integer,
cantidad_hit integer,
cantidad_no_hit integer,
tipo_alta char(3),
tipo_alta_causa char(3), --JMAH RQM 09 420
descripcion char(40),
orden_reporte smallint,
ciudad char(3),
estado char(2),
numero_region smallint,
total_porcentaje decimal(5,2) , 
total_porc_hit decimal(5,2),
total_porc_no_hit decimal(5,2)
) with no log;
		insert into total_ciudad
		SELECT ciudad,estado, sum(cantidad) total, sum(cantidad_hit) total_hit, sum(cantidad_no_hit) total_no_hit FROM total group by 1,2; -- into temp total_ciudad with no log;
		
		insert into resultado_ciudad
		SELECT a.*, round(cantidad / total * 100,2) total_porcentaje, CASE WHEN total_hit > 0 THEN round(cantidad_hit / total_hit * 100,2) ELSE 0 END total_porc_hit, CASE WHEN total_no_hit > 0 THEN round(cantidad_no_hit / total_no_hit * 100,2) ELSE 0 END total_porc_no_hit
		FROM total a, bdisolic:ss_status_sol b, total_ciudad c
		WHERE b.empresa = pEmpresa AND a.status_solicitud = b.status_solicitud AND a.ciudad = c.ciudad AND a.estado = c.estado AND activa_reporte = "1" ;
		--INTO temp resultado_ciudad with no log;

		IF pFiltro <> '' AND pEstatus <> '' THEN
			SELECT sum(cantidad),sum(cantidad_hit),sum(cantidad_no_hit) INTO total_sol_rep,total_sol_rep_hit,total_sol_rep_no_hit FROM total WHERE estado = pretedocd and ciudad = pFiltro AND status_solicitud = pEstatus;
		ELSE
			SELECT sum(total),sum(total_hit),sum(total_no_hit) INTO total_sol_rep,total_sol_rep_hit,total_sol_rep_no_hit FROM total_ciudad;
		END IF;

		IF (pFiltro = '' AND pEstatus <> '') or (pFiltro <> '' AND pEstatus <> '') THEN ----DETALLE
		   
		   insert into total_sol_group
			SELECT c.descripcion,a.tipo_alta,'', sum(a.grupo1_hit) as grupo1_hit, sum(a.grupo1_no_hit) as grupo1_no_hit, sum(a.grupo2_hit) as grupo2_hit,sum(a.grupo2_no_hit) as grupo2_no_hit,
			sum(a.grupo3_hit) as grupo3_hit,sum(a.grupo3_no_hit) as grupo3_no_hit,sum(a.grupo5_hit) as grupo5_hit,sum(a.grupo5_no_hit) as grupo5_no_hit,
			sum(a.grupo6_hit) as grupo6_hit,sum(a.grupo6_no_hit) as grupo6_no_hit, sum(a.grupoA_hit) as grupoA_hit,sum(a.grupoA_no_hit) as grupoA_no_hit,sum(a.grupo7_hit) as grupo7_hit,sum(a.grupo7_no_hit) as grupo7_no_hit,
            sum(a.grupo8_hit) as grupo8_hit,sum(a.grupo8_no_hit) as grupo8_no_hit,
			sum(a.grupo9_hit) as grupo9_hit,sum(a.grupo9_no_hit) as grupo9_no_hit,
			sum(a.cantidad_hit) as total_x_status_hit,sum(a.cantidad_no_hit) as total_x_status_no_hit,
			ROUND((sum(a.cantidad_hit) / case when total_sol_rep_hit = 0 then 1 else total_sol_rep_hit end) * 100,2) as porc_status_hit,
			ROUND((sum(a.cantidad_no_hit) / case when total_sol_rep_no_hit = 0 then 1 else total_sol_rep_no_hit end) * 100,2) as porc_status_no_hit,
			sum(a.cantidad) as total_x_status,ROUND((sum(a.cantidad) / case when total_sol_rep = 0 then 1 else total_sol_rep end) * 100,2) as porc_status,
			c.orden_reporte --MOD
			FROM total a, bdisolic:ss_status_sol b,bdisolic:ss_causas_sol c
			WHERE a.status_solicitud = b.status_solicitud AND a.status_solicitud = c.status_solicitud AND a.tipo_alta = c.causa_solicitud
			AND (a.estado = pretedocd or pretedocd='') AND (a.ciudad = pFiltro or pFiltro='') AND (a.status_solicitud = pEstatus or pEstatus='')
			AND b.activa_reporte = c.activa_reporte AND b.activa_reporte = "1"
			GROUP BY c.descripcion,a.tipo_alta,c.orden_reporte; -- ORDER BY c.orden_reporte
			--into temp total_sol_group with no log;
			
			
		   
		   insert into total_sol_group2
			SELECT c.descripcion,a.tipo_alta,a.tipo_alta_causa, sum(a.grupo1_hit) as grupo1_hit, sum(a.grupo1_no_hit) as grupo1_no_hit, sum(a.grupo2_hit) as grupo2_hit,sum(a.grupo2_no_hit) as grupo2_no_hit,
			sum(a.grupo3_hit) as grupo3_hit,sum(a.grupo3_no_hit) as grupo3_no_hit,sum(a.grupo5_hit) as grupo5_hit,sum(a.grupo5_no_hit) as grupo5_no_hit,
			sum(a.grupo6_hit) as grupo6_hit,sum(a.grupo6_no_hit) as grupo6_no_hit, sum(a.grupoA_hit) as grupoA_hit,sum(a.grupoA_no_hit) as grupoA_no_hit,sum(a.grupo7_hit) as grupo7_hit,sum(a.grupo7_no_hit) as grupo7_no_hit,
            sum(a.grupo8_hit) as grupo8_hit,sum(a.grupo8_no_hit) as grupo8_no_hit,
			sum(a.grupo9_hit) as grupo9_hit,sum(a.grupo9_no_hit) as grupo9_no_hit,
			sum(a.cantidad_hit) as total_x_status_hit,sum(a.cantidad_no_hit) as total_x_status_no_hit,
			ROUND((sum(a.cantidad_hit) / case when total_sol_rep_hit = 0 then 1 else total_sol_rep_hit end) * 100,2) as porc_status_hit,
			ROUND((sum(a.cantidad_no_hit) / case when total_sol_rep_no_hit = 0 then 1 else total_sol_rep_no_hit end) * 100,2) as porc_status_no_hit,
			sum(a.cantidad) as total_x_status,ROUND((sum(a.cantidad) / case when total_sol_rep = 0 then 1 else total_sol_rep end) * 100,2) as porc_status,
			c.orden_reporte --MOD
			FROM total a, bdisolic:ss_status_sol b,bdisolic:ss_causas_sol c
			WHERE a.status_solicitud = b.status_solicitud AND a.status_solicitud = c.status_solicitud AND a.tipo_alta = c.causa_solicitud
			AND (a.estado = pretedocd or pretedocd='') AND (a.ciudad = pFiltro or pFiltro='') AND (a.status_solicitud = pEstatus or pEstatus='')
			AND b.activa_reporte = c.activa_reporte AND b.activa_reporte = "1"
			GROUP BY c.descripcion,a.tipo_alta,tipo_alta_causa,c.orden_reporte; -- ORDER BY c.orden_reporte
			--into temp total_sol_group with no log;
		END IF;
	END IF;
	IF pTpConsulta	 = '03' THEN ---REGION
	create temp table total_region
	    (  numero_region smallint,
		   total integer,
		   total_hit integer,
		   total_no_hit integer
	     ) with no log;
		 
create temp table resultado_region
(numcte char(20),
status_solicitud char(2), 
sucursal char(4),
abonomensualropa money , 
abonomensualmuebles money, 
abonomensualprestamos money, 
compromisos_bco decimal (14,2),
fecha_insert date ,
autoriza_gte integer,
confirmado  CHAR(1),--JMAH RQM 09 420
grupo1_hit integer,
grupo1_no_hit integer,
grupo2_hit integer,
grupo2_no_hit integer,
grupo3_hit integer,
grupo3_no_hit integer,
grupo5_hit integer,
grupo5_no_hit integer,
grupo6_hit integer,
grupo6_no_hit integer,
grupoA_hit integer,
grupoA_no_hit integer,
grupo7_hit integer, 
grupo7_no_hit integer,
grupo8_hit integer,
grupo8_no_hit integer,
grupo9_hit integer,
grupo9_no_hit integer,
cantidad integer,
cantidad_hit integer,
cantidad_no_hit integer,
tipo_alta char(3),
tipo_alta_causa char(3), --JMAH RQM 09 420
descripcion char(40),
orden_reporte smallint,
ciudad char(3),
estado char(2),
numero_region smallint,
total_porcentaje decimal(5,2) , 
total_porc_hit decimal(5,2),
total_porc_no_hit decimal(5,2)
) with no log;		 
		 
		insert into total_region
		SELECT numero_region, sum(cantidad) total, sum(cantidad_hit) total_hit, sum(cantidad_no_hit) total_no_hit FROM total group by 1;
		 --INTO temp total_region with no log;
		insert into resultado_region
		SELECT a.*, round(cantidad / total * 100,2) total_porcentaje, CASE WHEN total_hit > 0 THEN round(cantidad_hit / total_hit * 100,2) ELSE 0 END total_porc_hit, CASE WHEN total_no_hit > 0 THEN round(cantidad_no_hit / total_no_hit * 100,2) ELSE 0 END total_porc_no_hit
		FROM total a, bdisolic:ss_status_sol b, total_region c
		WHERE b.empresa = pEmpresa AND a.status_solicitud = b.status_solicitud AND a.numero_region = c.numero_region AND activa_reporte = "1";
		--INTO temp resultado_region WITH NO LOG;

		IF pFiltro <> '' AND pEstatus <> '' THEN
			SELECT sum(cantidad),sum(cantidad_hit),sum(cantidad_no_hit) INTO total_sol_rep,total_sol_rep_hit,total_sol_rep_no_hit FROM total WHERE numero_region = pFiltro AND status_solicitud = pEstatus;
		ELSE
			SELECT sum(total),sum(total_hit),sum(total_no_hit) INTO total_sol_rep,total_sol_rep_hit,total_sol_rep_no_hit FROM total_region;
		END IF;

		IF (pFiltro = '' AND pEstatus <> '') or (pFiltro <> '' AND pEstatus <> '') THEN --DETALLE
			insert into total_sol_group
			SELECT c.descripcion,a.tipo_alta,'', sum(a.grupo1_hit) as grupo1_hit,sum(a.grupo1_no_hit) as grupo1_no_hit, sum(a.grupo2_hit) as grupo2_hit, sum(a.grupo2_no_hit) as grupo2_no_hit,
			sum(a.grupo3_hit) as grupo3_hit, sum(a.grupo3_no_hit) as grupo3_no_hit, sum(a.grupo5_hit) as grupo5_hit, sum(a.grupo5_no_hit) as grupo5_no_hit,
			sum(a.grupo6_hit) as grupo6_hit,sum(a.grupo6_no_hit) as grupo6_no_hit, sum(a.grupoA_hit) as grupoA_hit,sum(a.grupoA_no_hit) as grupoA_no_hit,sum(a.grupo7_hit) as grupo7_hit, sum(a.grupo7_no_hit) as grupo7_no_hit,
            sum(a.grupo8_hit) as grupo8_hit,sum(a.grupo8_no_hit) as grupo8_no_hit,
			sum(a.grupo9_hit) as grupo9_hit,sum(a.grupo9_no_hit) as grupo9_no_hit,
			sum(a.cantidad_hit) as total_x_status_hit,sum(a.cantidad_no_hit) as total_x_status_no_hit,
			ROUND((sum(a.cantidad_hit) / case when total_sol_rep_hit = 0 then 1 else total_sol_rep_hit end) * 100,2) as porc_status_hit,
			ROUND((sum(a.cantidad_no_hit) / case when total_sol_rep_no_hit = 0 then 1 else total_sol_rep_no_hit end) * 100,2) as porc_status_no_hit,
			sum(a.cantidad) as total_x_status,ROUND((sum(a.cantidad) / case when total_sol_rep = 0 then 1 else total_sol_rep end) * 100,2) as porc_status, 
			c.orden_reporte --MOD
			FROM total a, bdisolic:ss_status_sol b,bdisolic:ss_causas_sol c
			WHERE a.status_solicitud = b.status_solicitud AND a.status_solicitud = c.status_solicitud AND a.tipo_alta = c.causa_solicitud
			AND (a.numero_region = pFiltro or pFiltro ='') AND (a.status_solicitud = pEstatus OR pEstatus='') AND b.activa_reporte = c.activa_reporte AND b.activa_reporte = "1"
			GROUP BY c.descripcion,a.tipo_alta,c.orden_reporte; --ORDER BY c.orden_reporte; -- INTO temp total_sol_group WITH NO LOG;
		
		
			insert into total_sol_group2
			SELECT c.descripcion,a.tipo_alta,a.tipo_alta_causa, sum(a.grupo1_hit) as grupo1_hit,sum(a.grupo1_no_hit) as grupo1_no_hit, sum(a.grupo2_hit) as grupo2_hit, sum(a.grupo2_no_hit) as grupo2_no_hit,
			sum(a.grupo3_hit) as grupo3_hit, sum(a.grupo3_no_hit) as grupo3_no_hit, sum(a.grupo5_hit) as grupo5_hit, sum(a.grupo5_no_hit) as grupo5_no_hit,
			sum(a.grupo6_hit) as grupo6_hit,sum(a.grupo6_no_hit) as grupo6_no_hit, sum(a.grupoA_hit) as grupoA_hit,sum(a.grupoA_no_hit) as grupoA_no_hit,sum(a.grupo7_hit) as grupo7_hit, sum(a.grupo7_no_hit) as grupo7_no_hit,
            sum(a.grupo8_hit) as grupo8_hit,sum(a.grupo8_no_hit) as grupo8_no_hit,
			sum(a.grupo9_hit) as grupo9_hit,sum(a.grupo9_no_hit) as grupo9_no_hit,
			sum(a.cantidad_hit) as total_x_status_hit,sum(a.cantidad_no_hit) as total_x_status_no_hit,
			ROUND((sum(a.cantidad_hit) / case when total_sol_rep_hit = 0 then 1 else total_sol_rep_hit end) * 100,2) as porc_status_hit,
			ROUND((sum(a.cantidad_no_hit) / case when total_sol_rep_no_hit = 0 then 1 else total_sol_rep_no_hit end) * 100,2) as porc_status_no_hit,
			sum(a.cantidad) as total_x_status,ROUND((sum(a.cantidad) / case when total_sol_rep = 0 then 1 else total_sol_rep end) * 100,2) as porc_status, 
			c.orden_reporte --MOD
			FROM total a, bdisolic:ss_status_sol b,bdisolic:ss_causas_sol c
			WHERE a.status_solicitud = b.status_solicitud AND a.status_solicitud = c.status_solicitud AND a.tipo_alta = c.causa_solicitud
			AND (a.numero_region = pFiltro or pFiltro ='') AND (a.status_solicitud = pEstatus OR pEstatus='') AND b.activa_reporte = c.activa_reporte AND b.activa_reporte = "1"
			GROUP BY c.descripcion,a.tipo_alta,a.tipo_alta_causa,c.orden_reporte; --ORDER BY c.orden_reporte; -- INTO temp total_sol_group WITH NO LOG;
		
		
		END IF;
	END IF;
	
	
create temp table total_sol_group_aux(
descripcion char(30),
tipo_alta char(3),
tipo_alta_causa char(3),
grupo1_hit integer, 
grupo1_no_hit integer,
grupo2_hit integer, 
grupo2_no_hit integer,
grupo3_hit integer,
grupo3_no_hit integer,  
grupo5_hit integer, 
grupo5_no_hit integer,
grupo6_hit integer, 
grupo6_no_hit integer, 
grupoA_hit integer,
grupoA_no_hit integer,
grupo7_hit integer,
grupo7_no_hit integer,
grupo8_hit integer, 
grupo8_no_hit integer,
grupo9_hit integer,
grupo9_no_hit integer,
total_x_status_hit integer,
total_x_status_no_hit integer, 
porc_status_hit DECIMAL(18,2),
porc_status_no_hit DECIMAL(18,2),
total_x_status integer, 
porc_status DECIMAL(18,2), 
orden_rerpote smallint
) with no log;

---------FIN EVALUACIONES DE LA CLASIFICACION DE LA CAUSA CPS
		insert into total_sol_group_aux
		SELECT 'Total Solicitudes' descripcion,'' tipo_alta, '',sum(grupo1_hit) grupo1_hit, sum(grupo1_no_hit ) grupo1_no_hit, sum(grupo2_hit) grupo2_hit, sum(grupo2_no_hit) grupo2_no_hit, sum(grupo3_hit) grupo3_hit, sum(grupo3_no_hit) grupo3_no_hit, sum(grupo5_hit) grupo5_hit, sum(grupo5_no_hit) grupo5_no_hit,
			sum(grupo6_hit) as grupo6_hit, sum(grupo6_no_hit) as grupo6_no_hit, sum(grupoA_hit) as grupoA_hit,sum(grupoA_no_hit) as grupoA_no_hit,sum(grupo7_hit) grupo7_hit, sum(grupo7_no_hit) grupo7_no_hit,sum(grupo8_hit) grupo8_hit, sum(grupo8_no_hit) grupo8_no_hit,
			sum(grupo9_hit) as grupo9_hit,sum(grupo9_no_hit) as grupo9_no_hit,
			sum(grupo1_hit+grupo2_hit+grupo3_hit+grupo5_hit+grupo6_hit+grupoa_hit+grupo7_hit+grupo8_hit+grupo9_hit) total_x_status_hit,
			sum(grupo1_no_hit+grupo2_no_hit+grupo3_no_hit+grupo5_no_hit+grupo6_no_hit+grupoA_no_hit+grupo7_no_hit+grupo8_no_hit+grupo9_no_hit) total_x_status_no_hit, sum(porc_status_hit) porc_status_hit,sum(porc_status_no_hit) porc_status_no_hit,
			sum(grupo1_hit+grupo1_no_hit+grupo2_hit+grupo2_no_hit+grupo3_hit+grupo3_no_hit+grupo5_hit+grupo5_no_hit+grupo6_hit+grupo6_no_hit+grupoA_hit+grupoA_no_hit+grupo7_hit+grupo7_no_hit+grupo8_hit+grupo8_no_hit+grupo9_hit+grupo9_no_hit) total_x_status, sum(porc_status) porc_status, 997 orden_rerpote
		FROM total_sol_group; -- INTO temp total_sol_group_aux;

		select sum(total_x_status) INTO ptotal_x_status from total_sol_group_aux;
		select sum(total_x_status_hit) INTO ptotal_x_status_hit from total_sol_group_aux;
		select sum(total_x_status_no_hit) INTO ptotal_x_status_no_hit from total_sol_group_aux;

		IF ptotal_x_status = 0 THEN LET ptotal_x_status = 1;
		ELIF ptotal_x_status_hit = 0 THEN LET ptotal_x_status_hit = 1;
		ELIF ptotal_x_status_no_hit = 0 THEN LET ptotal_x_status_no_hit = 1;
		END IF;

		INSERT INTO total_sol_group_aux
		SELECT '% de Solicitudes' descripcion,'' tipo_alta, '',
		round(sum(grupo1_hit)/(ptotal_x_status),2) * 100,round(sum(grupo1_no_hit)/(ptotal_x_status),2) * 100,round(sum(grupo2_hit)/(ptotal_x_status),2) * 100,round(sum(grupo2_no_hit)/(ptotal_x_status),2) * 100,
		round(sum(grupo3_hit)/(ptotal_x_status),2) * 100,round(sum(grupo3_no_hit)/(ptotal_x_status),2) * 100,
		round(sum(grupo5_hit)/(ptotal_x_status),2) * 100,round(sum(grupo5_no_hit)/(ptotal_x_status),2) * 100,round(sum(grupo6_hit)/(ptotal_x_status),2) * 100,round(sum(grupo6_no_hit)/(ptotal_x_status),2) * 100,
		round(sum(grupoA_hit)/(ptotal_x_status),2) * 100,round(sum(grupoA_no_hit)/(ptotal_x_status),2) * 100,round(sum(grupo7_hit)/(ptotal_x_status),2) * 100,round(sum(grupo7_no_hit)/(ptotal_x_status),2) * 100,
		round(sum(grupo8_hit)/(ptotal_x_status),2) * 100,round(sum(grupo8_no_hit)/(ptotal_x_status),2) * 100,
		round(sum(grupo9_hit)/(ptotal_x_status),2) * 100,round(sum(grupo9_no_hit)/(ptotal_x_status),2) * 100, --cada uno de los status		
		round(sum(grupo1_hit)/(ptotal_x_status_hit),2) * 100+round(sum(grupo2_hit)/(ptotal_x_status_hit),2) * 100+
		round(sum(grupo3_hit)/(ptotal_x_status_hit),2) * 100+round(sum(grupo5_hit)/(ptotal_x_status_hit),2) * 100+
		round(sum(grupo6_hit)/(ptotal_x_status_hit),2) * 100+round(sum(grupoA_hit)/(ptotal_x_status_hit),2) * 100+round(sum(grupo7_hit)/(ptotal_x_status_hit),2) * 100+round(sum(grupo8_hit)/(ptotal_x_status_hit),2) * 100+round(sum(grupo9_hit)/(ptotal_x_status_hit),2) * 100, --total x status_hit
		round(sum(grupo1_no_hit)/(ptotal_x_status_no_hit),2) * 100+round(sum(grupo2_no_hit)/(ptotal_x_status_no_hit),2) * 100+
		round(sum(grupo3_no_hit)/(ptotal_x_status_no_hit),2) * 100+round(sum(grupo5_no_hit)/(ptotal_x_status_no_hit),2) * 100+
		round(sum(grupo6_no_hit)/(ptotal_x_status_no_hit),2) * 100+round(sum(grupoA_no_hit)/(ptotal_x_status_no_hit),2) * 100+round(sum(grupo7_no_hit)/(ptotal_x_status_no_hit),2) * 100+round(sum(grupo8_no_hit)/(ptotal_x_status_no_hit),2) * 100+round(sum(grupo9_no_hit)/(ptotal_x_status_no_hit),2) * 100, --total x status_no_hit
		round(sum(grupo1_hit)/(ptotal_x_status_hit),2) * 100+round(sum(grupo2_hit)/(ptotal_x_status_hit),2) * 100+
		round(sum(grupo3_hit)/(ptotal_x_status_hit),2) * 100+round(sum(grupo5_hit)/(ptotal_x_status_hit),2) * 100+
		round(sum(grupo6_hit)/(ptotal_x_status_hit),2) * 100+round(sum(grupoA_hit)/(ptotal_x_status_hit),2) * 100+round(sum(grupo7_hit)/(ptotal_x_status_hit),2) * 100+round(sum(grupo8_hit)/(ptotal_x_status_hit),2) * 100+round(sum(grupo9_hit)/(ptotal_x_status_hit),2) * 100, --porc de total x status_hit
		round(sum(grupo1_no_hit)/(ptotal_x_status_no_hit),2) * 100+round(sum(grupo2_no_hit)/(ptotal_x_status_no_hit),2) * 100+
		round(sum(grupo3_no_hit)/(ptotal_x_status_no_hit),2) * 100+round(sum(grupo5_no_hit)/(ptotal_x_status_no_hit),2) * 100+
		round(sum(grupo6_no_hit)/(ptotal_x_status_no_hit),2) * 100+round(sum(grupoA_no_hit)/(ptotal_x_status_no_hit),2) * 100+round(sum(grupo7_no_hit)/(ptotal_x_status_no_hit),2) * 100+round(sum(grupo8_no_hit)/(ptotal_x_status_no_hit),2) * 100+round(sum(grupo9_no_hit)/(ptotal_x_status_no_hit),2) * 100, --porc de total x status_hit
		round(sum(grupo1_hit)/(ptotal_x_status),2) * 100+round(sum(grupo1_no_hit)/(ptotal_x_status),2) * 100+round(sum(grupo2_hit)/(ptotal_x_status),2) * 100+round(sum(grupo2_no_hit)/(ptotal_x_status),2) * 100+
		round(sum(grupo3_hit)/(ptotal_x_status),2) * 100+round(sum(grupo3_no_hit)/(ptotal_x_status),2) * 100+round(sum(grupo5_hit)/(ptotal_x_status),2) * 100+round(sum(grupo5_no_hit)/(ptotal_x_status),2) * 100+
		round(sum(grupo6_hit)/(ptotal_x_status),2) * 100+round(sum(grupo6_no_hit)/(ptotal_x_status),2) * 100+round(sum(grupoA_hit)/(ptotal_x_status),2) * 100+round(sum(grupoA_no_hit)/(ptotal_x_status),2) * 100+round(sum(grupo7_hit)/(ptotal_x_status),2) * 100+round(sum(grupo7_no_hit)/(ptotal_x_status),2) * 100+round(sum(grupo8_hit)/(ptotal_x_status),2) * 100+round(sum(grupo8_no_hit)/(ptotal_x_status),2) * 100+round(sum(grupo9_no_hit)/(ptotal_x_status),2) * 100, ---total x status
		round(sum(grupo1_hit)/(ptotal_x_status),2) * 100+round(sum(grupo1_no_hit)/(ptotal_x_status),2) * 100+round(sum(grupo2_hit)/(ptotal_x_status),2) * 100+round(sum(grupo2_no_hit)/(ptotal_x_status),2) * 100+
		round(sum(grupo3_hit)/(ptotal_x_status),2) * 100+round(sum(grupo3_no_hit)/(ptotal_x_status),2) * 100+round(sum(grupo5_hit)/(ptotal_x_status),2) * 100+round(sum(grupo5_no_hit)/(ptotal_x_status),2) * 100+
		round(sum(grupo6_hit)/(ptotal_x_status),2) * 100+round(sum(grupo6_no_hit)/(ptotal_x_status),2) * 100+round(sum(grupoA_hit)/(ptotal_x_status),2) * 100+round(sum(grupoA_no_hit)/(ptotal_x_status),2) * 100+round(sum(grupo7_hit)/(ptotal_x_status),2) * 100+round(sum(grupo7_no_hit)/(ptotal_x_status),2) * 100+round(sum(grupo8_hit)/(ptotal_x_status),2) * 100+round(sum(grupo8_no_hit)/(ptotal_x_status),2) * 100+round(sum(grupo9_hit)/(ptotal_x_status),2) * 100+round(sum(grupo9_no_hit)/(ptotal_x_status),2) * 100, 998 ----porc de total x status
		FROM total_sol_group_aux; 

		INSERT INTO total_sol_group 
		SELECT * FROM total_sol_group_aux;
--/*
		SELECT COUNT(*) INTO num_registros FROM total_sol_group;
		IF num_registros > 2 THEN
			IF pEstatus <> '' THEN
			FOREACH WITH HOLD
				SELECT descripcion,tipo_alta,grupo1_hit,grupo1_no_hit,grupo2_hit,grupo2_no_hit,grupo3_hit,grupo3_no_hit,grupo5_hit,grupo5_no_hit,grupo6_hit,grupo6_no_hit,grupoA_hit,grupoA_no_hit,grupo7_hit,grupo7_no_hit,grupo8_hit,grupo8_no_hit,grupo9_hit,grupo9_no_hit,total_x_status_hit,total_x_status_no_hit,porc_status_hit,porc_status_no_hit,total_x_status,porc_status
				INTO cDescripcion,cStatusSol, dgrupo1_hit, dgrupo1_no_hit, dgrupo2_hit, dgrupo2_no_hit, dgrupo3_hit, dgrupo3_no_hit,dgrupo5_hit,dgrupo5_no_hit,dgrupo6_hit,dgrupo6_no_hit,dgrupoA_hit,dgrupoA_no_hit,dgrupo7_hit,dgrupo7_no_hit,dgrupo8_hit,dgrupo8_no_hit,dgrupo9_hit,dgrupo9_no_hit,dtotal_status_hit,dtotal_status_no_hit,dporc_status_hit,dporc_status_no_hit,dTotalStatus,dTotalGenStatus
				FROM total_sol_group ORDER BY orden_reporte
				
				RETURN cCodRet, cMensajeRet, cDescripcion, cStatusSol,dgrupo1_hit,dgrupo1_no_hit, dgrupo2_hit,dgrupo2_no_hit, dgrupo3_hit,dgrupo3_no_hit, dgrupo5_hit, dgrupo5_no_hit,dgrupo6_hit,dgrupo6_no_hit,dgrupoA_hit,dgrupoA_no_hit,dgrupo7_hit, dgrupo7_no_hit,dgrupo8_hit, dgrupo8_no_hit,dgrupo9_hit,dgrupo9_no_hit,dtotal_status_hit,dtotal_status_no_hit, dporc_status_hit,dporc_status_no_hit,dTotalStatus, dTotalGenStatus WITH RESUME;
				FOREACH WITH HOLD
					SELECT descripcion,tipo_alta_causa,grupo1_hit,grupo1_no_hit,grupo2_hit,grupo2_no_hit,grupo3_hit,grupo3_no_hit,grupo5_hit,grupo5_no_hit,grupo6_hit,grupo6_no_hit,grupoA_hit,grupoA_no_hit,grupo7_hit,grupo7_no_hit,grupo8_hit,grupo8_no_hit,grupo9_hit,grupo9_no_hit,total_x_status_hit,total_x_status_no_hit,porc_status_hit,porc_status_no_hit,total_x_status,porc_status
					INTO cDescripcion,cStatusSol, dgrupo1_hit, dgrupo1_no_hit, dgrupo2_hit, dgrupo2_no_hit, dgrupo3_hit, dgrupo3_no_hit,dgrupo5_hit,dgrupo5_no_hit,dgrupo6_hit,dgrupo6_no_hit,dgrupoA_hit,dgrupoA_no_hit,dgrupo7_hit,dgrupo7_no_hit,dgrupo8_hit,dgrupo8_no_hit,dgrupo9_hit,dgrupo9_no_hit,dtotal_status_hit,dtotal_status_no_hit,dporc_status_hit,dporc_status_no_hit,dTotalStatus,dTotalGenStatus
					FROM total_sol_group2
					WHERE tipo_alta = cStatusSol
					ORDER BY orden_reporte
					
					IF cStatusSol = "CTC" THEN
						LET cDescripcion = ".     Con Teléfono Confirmado";
					ELSE
						LET cDescripcion = ".     Sin Teléfono Confirmado";
					END IF;
					
				RETURN cCodRet, cMensajeRet, cDescripcion, cStatusSol,dgrupo1_hit,dgrupo1_no_hit, dgrupo2_hit,dgrupo2_no_hit, dgrupo3_hit,dgrupo3_no_hit, dgrupo5_hit, dgrupo5_no_hit,dgrupo6_hit,dgrupo6_no_hit,dgrupoA_hit,dgrupoA_no_hit,dgrupo7_hit, dgrupo7_no_hit,dgrupo8_hit, dgrupo8_no_hit,dgrupo9_hit,dgrupo9_no_hit,dtotal_status_hit,dtotal_status_no_hit, dporc_status_hit,dporc_status_no_hit,dTotalStatus, dTotalGenStatus WITH RESUME;
				END FOREACH;				
				
		
			END FOREACH;
			ELSE
			FOREACH WITH HOLD
				SELECT descripcion,status_solicitud,grupo1_hit,grupo1_no_hit,grupo2_hit,grupo2_no_hit,grupo3_hit,grupo3_no_hit,grupo5_hit,grupo5_no_hit,grupo6_hit,grupo6_no_hit,grupoA_hit,grupoA_no_hit,grupo7_hit,grupo7_no_hit,grupo8_hit,grupo8_no_hit,grupo9_hit,grupo9_no_hit,total_x_status_hit,total_x_status_no_hit,porc_status_hit,porc_status_no_hit,total_x_status,porc_status
				INTO cDescripcion, cStatusSol, dgrupo1_hit, dgrupo1_no_hit, dgrupo2_hit, dgrupo2_no_hit, dgrupo3_hit, dgrupo3_no_hit, dGrupo5_hit, dGrupo5_no_hit,dgrupo6_hit,dgrupo6_no_hit,dgrupoA_hit,dgrupoA_no_hit,dgrupo7_hit, dgrupo7_no_hit,dgrupo8_hit, dgrupo8_no_hit,dgrupo9_hit,dgrupo9_no_hit, dtotal_status_hit,dtotal_status_no_hit,dporc_status_hit,dporc_status_no_hit,dTotalStatus, dTotalGenStatus
				FROM total_sol_group ORDER BY orden_reporte
				RETURN cCodRet, cMensajeRet, cDescripcion, cStatusSol, dgrupo1_hit, dgrupo1_no_hit, dgrupo2_hit, dgrupo2_no_hit, dgrupo3_hit, dgrupo3_no_hit, dGrupo5_hit, dGrupo5_no_hit,dgrupo6_hit,dgrupo6_no_hit,dgrupoA_hit,dgrupoA_no_hit, dgrupo7_hit, dgrupo7_no_hit,dgrupo8_hit, dgrupo8_no_hit,dgrupo9_hit,dgrupo9_no_hit, dtotal_status_hit,dtotal_status_no_hit,dporc_status_hit,dporc_status_no_hit,dTotalStatus, dTotalGenStatus WITH RESUME;
			END FOREACH;
			END IF;
		ELSE
			LET cCodRet = '000006'; LET cMensajeRet = 'No hay informacion para este producto en este periodo';
			RETURN cCodRet, cMensajeRet, cDescripcion, cStatusSol, dgrupo1_hit, dgrupo1_no_hit, dgrupo2_hit, dgrupo2_no_hit,dgrupo3_hit, dgrupo3_no_hit, dGrupo5_hit, dGrupo5_no_hit,dgrupo6_hit,dgrupo6_no_hit,dgrupoA_hit,dgrupoA_no_hit,dgrupo7_hit, dgrupo7_no_hit,dgrupo8_hit, dgrupo8_no_hit,dgrupo9_hit,dgrupo9_no_hit, dtotal_status_hit,dtotal_status_no_hit,dporc_status_hit,dporc_status_no_hit,dTotalStatus, dTotalGenStatus WITH RESUME;
		END IF
--*/
		DROP TABLE total; DROP TABLE total_sol_group;  DROP TABLE total_sol_group2; DROP TABLE total_sol_group_aux;

		DROP TABLE sol3; DROP TABLE sol4; DROP TABLE sol5;

		IF pTpConsulta = '04' THEN DROP TABLE total_sucursal; DROP TABLE resultado_sucursal;
		ELIF pTpConsulta = '01' THEN DROP TABLE total_estado; DROP TABLE resultado_estado;
		ELIF pTpConsulta = '02' THEN DROP TABLE total_ciudad; DROP TABLE resultado_ciudad;
		ELIF pTpConsulta = '03' THEN DROP TABLE total_region; DROP TABLE resultado_region;
		END IF;

END
END PROCEDURE
DOCUMENT
'Autor: Marco Valenzuela',
'Fecha: 03-Abr-2014',
'Descripción: Obtiene los tipos de Alta de los Clientes-Prospectos para los Estatus AT y AP del Reporte Arbol de Solicitudes';

CREATE PROCEDURE "informix".sp_consultasolcred_x_status(pEmpresa CHAR(3),pTpConsulta CHAR(2),pFiltro VARCHAR(4),pProducto CHAR(4),pFechaIni DATE,pFechaFin DATE,pEstatus CHAR(2),pretedocd CHAR(2),psubcausa CHAR(3))
RETURNING
	CHAR(6) AS cod_ret, VARCHAR(80,1) AS mensaje_ret, VARCHAR(200,1) AS descripcion_status, VARCHAR(3,1) AS status_sol, 
	DECIMAL(18,2) AS grupo1_hit, DECIMAL(18,2) AS grupo1_no_hit, DECIMAL(18,2) AS grupo2_hit, DECIMAL(18,2) AS grupo2_no_hit, DECIMAL(18,2) AS grupo3_hit, DECIMAL(18,2) AS grupo3_no_hit,
	DECIMAL(18,2) AS grupo5_hit, DECIMAL(18,2) AS grupo5_no_hit, DECIMAL(18,2) AS grupo6_hit,DECIMAL(18,2) AS grupo6_no_hit,  DECIMAL(18,2) AS grupoA_hit, DECIMAL(18,2) AS grupoA_no_hit, 
    DECIMAL(18,2) AS grupo7_hit, DECIMAL(18,2) AS grupo7_no_hit, DECIMAL(18,2) AS grupo8_hit, DECIMAL(18,2) AS grupo8_no_hit, DECIMAL(18,2) AS grupo9_hit, DECIMAL(18,2) AS grupo9_no_hit ,DECIMAL(18,2) AS total_x_estatus_hit,
	DECIMAL(18,2) AS total_x_estatus_no_hit, DECIMAL(18,2) AS porc_status_hit, DECIMAL(18,2) AS porc_status_no_hit, DECIMAL(18,2) AS total_x_estatus,
	DECIMAL(18,2) AS porc_status, CHAR(1) AS tiene_causas;

DEFINE iSqlErr, iIsamErr,total_sol_rep,total_sol_rep_hit,total_sol_rep_no_hit INTEGER;
DEFINE cErrorInfo CHAR(80); DEFINE cCodRet CHAR(6); DEFINE cMensajeRet VARCHAR(80,1); DEFINE cEmpresa CHAR(3);
DEFINE cStatusSol VARCHAR(3,1); DEFINE cDescripcion VARCHAR(200,1); DEFINE dSituacionPago DECIMAL(5,2);
DEFINE dgrupo1_hit, dgrupo1_no_hit, dgrupo2_hit, dgrupo2_no_hit ,dgrupo3_hit, dgrupo3_no_hit, dGrupo5_hit, dGrupo5_no_hit, dTotalStatus, dTotalGenStatus DECIMAL(18,2);
DEFINE dGrupo6_hit, dGrupo6_no_hit, dGrupoA_hit, dGrupoA_no_hit, dgrupo7_hit, dgrupo7_no_hit, dgrupo8_hit, dgrupo8_no_hit,dgrupo9_hit,dgrupo9_no_hit,dtotal_status_hit,dtotal_status_no_hit,dporc_status_hit,dporc_status_no_hit,ptotal_x_status,ptotal_x_status_hit,ptotal_x_status_no_hit DECIMAL(18,2);
DEFINE cBanCausa,cBanTmp CHAR(1); DEFINE cCausaSol VARCHAR(3,1); DEFINE num_registros SMALLINT;

LET iSqlErr = 0; LET iIsamErr = 0; LET cErrorInfo = ''; LET cCodRet = '000000'; LET cMensajeRet = 'Se ejecutó la consulta correctamente';
LET cEmpresa = ''; LET cStatusSol = ''; LET cDescripcion = ''; LET dSituacionPago = 0; LET dgrupo1_hit = 0; LET dgrupo1_no_hit = 0; LET dgrupo2_hit = 0;
LET dgrupo2_no_hit = 0; LET dgrupo3_hit = 0; LET dgrupo3_no_hit = 0; LET dGrupo5_hit = 0; LET dGrupo5_no_hit = 0; LET dgrupo8_hit = 0; LET dgrupo8_no_hit = 0; LET dgrupo9_hit=0;LEt dgrupo9_no_hit=0; 
LET dgrupo6_no_hit = 0; LET dgrupo6_hit = 0; LET dgrupoA_no_hit = 0; LET dgrupoA_hit = 0; LET dgrupo7_hit = 0; LET dgrupo7_no_hit = 0; LET dTotalStatus = 0; LET dTotalGenStatus = 0; LET cBanCausa = "";
LET cBanTmp = "N"; LET cCausaSol = ""; LET total_sol_rep = 0; LET total_sol_rep_hit = 0; LET total_sol_rep_no_hit = 0; LET dporc_status_hit = 0; LET dporc_status_no_hit = 0;
LET num_registros = 0; LET dtotal_status_hit = 0; LET dtotal_status_no_hit = 0; LET ptotal_x_status = 0; LET ptotal_x_status_hit = 0; LET ptotal_x_status_no_hit = 0;

BEGIN
ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo

	IF iSqlErr != 0 THEN
		IF cBanTmp = "S" THEN DROP TABLE Tsolicitud; DROP TABLE sol2; DROP TABLE total; DROP TABLE total_sol_group;
			IF psubcausa <> '' THEN DROP TABLE sol3; DROP TABLE sol4; END IF;
			IF pTpConsulta = '04' THEN DROP TABLE total_sucursal;
				ELIF pTpConsulta = '01' THEN DROP TABLE total_estado; 
				ELIF pTpConsulta = '02' THEN DROP TABLE total_ciudad; 
				ELIF pTpConsulta = '03' THEN DROP TABLE total_region; 
			END IF
		END IF;
		LET cCodRet= iSqlErr; LET cMensajeRet= cErrorInfo;
		RETURN cCodRet,cMensajeRet,cDescripcion, cStatusSol,dgrupo1_hit,dgrupo1_no_hit,dgrupo2_hit,dgrupo2_no_hit,dgrupo3_hit,dgrupo3_no_hit,dGrupo5_hit,dGrupo5_no_hit,dgrupo6_hit,dgrupo6_no_hit,dGrupoA_hit,dGrupoA_no_hit,
               dgrupo7_hit,dgrupo7_no_hit,dgrupo8_hit,dgrupo8_no_hit,dgrupo9_hit,dgrupo9_no_hit,dtotal_status_hit,dtotal_status_no_hit,dporc_status_hit,dporc_status_no_hit,dTotalStatus,dTotalGenStatus,cBanCausa;
	END IF;
END EXCEPTION;

--SET DEBUG FILE TO "/informix/marcov/sp_consultasolcred_x_status.out";
--TRACE ON;

IF NVL(pEmpresa,'') = '' THEN
	LET cCodRet = '000001'; LET cMensajeRet = 'Es necesario indicar la empresa para ejecutar el proceso';
	RETURN cCodRet,cMensajeRet,cDescripcion, cStatusSol,dgrupo1_hit,dgrupo1_no_hit,dgrupo2_hit,dgrupo2_no_hit,dgrupo3_hit,dgrupo3_no_hit,dGrupo5_hit,dGrupo5_no_hit,dgrupo6_hit,dgrupo6_no_hit,dGrupoA_hit,dGrupoA_no_hit,dgrupo7_hit,dgrupo7_no_hit,dgrupo8_hit,dgrupo8_no_hit,dgrupo9_hit,dgrupo9_no_hit,dtotal_status_hit,dtotal_status_no_hit,dporc_status_hit,dporc_status_no_hit,dTotalStatus,dTotalGenStatus,cBanCausa;
END IF;

SELECT empresa INTO cEmpresa FROM bdinteg:si_empresas WHERE empresa = pEmpresa;

IF NVL(cEmpresa,'') = '' THEN
	LET cCodRet = '000002'; LET cMensajeRet = 'La empresa indicada no es valida';
	RETURN cCodRet,cMensajeRet,cDescripcion, cStatusSol,dgrupo1_hit,dgrupo1_no_hit,dgrupo2_hit,dgrupo2_no_hit,dgrupo3_hit,dgrupo3_no_hit,dGrupo5_hit,dGrupo5_no_hit,dgrupo6_hit,dgrupo6_no_hit,dGrupoA_hit,dGrupoA_no_hit,dgrupo7_hit,dgrupo7_no_hit,dgrupo8_hit,dgrupo8_no_hit,dgrupo9_hit,dgrupo9_no_hit,dtotal_status_hit,dtotal_status_no_hit,dporc_status_hit,dporc_status_no_hit,dTotalStatus,dTotalGenStatus,cBanCausa;
END IF;

IF NVL(pTpConsulta,"") = "" THEN
	LET cCodRet = "000003"; LET cMensajeRet = "Es necesario indicar el tipo de consulta a realizar";
	RETURN cCodRet,cMensajeRet,cDescripcion, cStatusSol,dgrupo1_hit,dgrupo1_no_hit,dgrupo2_hit,dgrupo2_no_hit,dgrupo3_hit,dgrupo3_no_hit,dGrupo5_hit,dGrupo5_no_hit,dgrupo6_hit,dgrupo6_no_hit,dGrupoA_hit,dGrupoA_no_hit,dgrupo7_hit,dgrupo7_no_hit,dgrupo8_hit,dgrupo8_no_hit,dgrupo9_hit,dgrupo9_no_hit,dtotal_status_hit,dtotal_status_no_hit,dporc_status_hit,dporc_status_no_hit,dTotalStatus,dTotalGenStatus,cBanCausa;
END IF;

IF NVL(pFechaIni,"") = "" AND NVL(pFechaFin, "") = "" THEN
	LET cCodRet = "000004"; LET cMensajeRet = "Es necesario indicar al menos una fecha";
	RETURN cCodRet,cMensajeRet,cDescripcion, cStatusSol,dgrupo1_hit,dgrupo1_no_hit,dgrupo2_hit,dgrupo2_no_hit,dgrupo3_hit,dgrupo3_no_hit,dGrupo5_hit,dGrupo5_no_hit,dgrupo6_hit,dgrupo6_no_hit,dGrupoA_hit,dGrupoA_no_hit,dgrupo7_hit,dgrupo7_no_hit,dgrupo8_hit,dgrupo8_no_hit,dgrupo9_hit,dgrupo9_no_hit,dtotal_status_hit,dtotal_status_no_hit,dporc_status_hit,dporc_status_no_hit,dTotalStatus,dTotalGenStatus,cBanCausa;
END IF;

IF (NVL(pFechaIni,"") <> "" AND NVL(pFechaFin, "") <> "") AND (pFechaIni > pFechaFin) THEN
	LET cCodRet = "000005"; LET cMensajeRet = "La fecha inicial no debe ser mayor a la fecha final";
	RETURN cCodRet,cMensajeRet,cDescripcion, cStatusSol,dgrupo1_hit,dgrupo1_no_hit,dgrupo2_hit,dgrupo2_no_hit,dgrupo3_hit,dgrupo3_no_hit,dGrupo5_hit,dGrupo5_no_hit,dgrupo6_hit,dgrupo6_no_hit,dGrupoA_hit,dGrupoA_no_hit,dgrupo7_hit,dgrupo7_no_hit,dgrupo8_hit,dgrupo8_no_hit,dgrupo9_hit,dgrupo9_no_hit,dtotal_status_hit,dtotal_status_no_hit,dporc_status_hit,dporc_status_no_hit,dTotalStatus,dTotalGenStatus,cBanCausa;
END IF;

LET cBanTmp = "S";

IF pFechaIni IS NULL THEN LET pFechaIni = DATE(1); END IF; 
IF pFechaFin IS NULL THEN LET pFechaFin = pFechaIni; END IF;

create temp table Tsolicitud (numcte char(20),status_solicitud char(2),causa_solicitud char(3), sucursal char(4),
	abonomensualropa money,abonomensualmuebles money,abonomensualprestamos money,
	compromisos_bco decimal (14,2),fecha_insert date,
	grupo1_hit integer,grupo1_no_hit integer, grupo2_hit integer,grupo2_no_hit integer,grupo3_hit integer,grupo3_no_hit integer,grupo5_hit integer,
    grupo5_no_hit integer,grupo6_hit integer,grupo6_no_hit integer,grupoA_hit integer,grupoA_no_hit integer, grupo7_hit integer, grupo7_no_hit integer,
	grupo8_hit integer,grupo8_no_hit integer, grupo9_hit integer,grupo9_no_hit integer,cantidad integer,cantidad_hit integer,cantidad_no_hit integer,sub_causa_solicitud char(3)) with no log;

create temp table sol2 (numcte char(20),status_solicitud char(2),causa_solicitud char(3), sucursal char(4),
	abonomensualropa money,abonomensualmuebles money,abonomensualprestamos money,
	compromisos_bco decimal (14,2),fecha_insert date,
	grupo1_hit integer,grupo1_no_hit integer, grupo2_hit integer,grupo2_no_hit integer,grupo3_hit integer,grupo3_no_hit integer,grupo5_hit integer,
    grupo5_no_hit integer,grupo6_hit integer,grupo6_no_hit integer,grupoA_hit integer,grupoA_no_hit integer, grupo7_hit integer, grupo7_no_hit integer,
	grupo8_hit integer,grupo8_no_hit integer,grupo9_hit integer,grupo9_no_hit integer,cantidad integer,cantidad_hit integer,cantidad_no_hit integer,sub_causa_solicitud char(3)) with no log;	
	
	
		insert into Tsolicitud 
			SELECT a.numcte,a.status_solicitud, c.causa_solicitud, a.sucursal,b.abonomensualropa, b.abonomensualmuebles, b.abonomensualprestamos, b.compromisos_bco,a.fecha_insert,
			sum(CASE WHEN (nvl(b.grupo,'') in ('1','4')) AND b.evalua_cc IN ('0','1','2','3','4') and rev.excluye_validacion = 0 THEN 1 ELSE 0 END ) grupo1_hit,
			sum(CASE WHEN (nvl(b.grupo,'') in ('1','4')) AND NVL(b.evalua_cc,'') IN ('X','')  and rev.excluye_validacion = 0 THEN 1 ELSE 0 END) grupo1_no_hit,
			sum(CASE WHEN (nvl(b.grupo,'') = '2') AND b.evalua_cc IN ('0','1','2','3','4') and rev.excluye_validacion = 0 THEN 1 ELSE 0 END) grupo2_hit,
			sum(CASE WHEN (nvl(b.grupo,'') = '2') AND NVL(b.evalua_cc,'') IN ('X','') and rev.excluye_validacion = 0 THEN 1 ELSE 0 END) grupo2_no_hit,
			sum(CASE WHEN (nvl(b.grupo,'') = '3') AND b.evalua_cc IN ('0','1','2','3','4') and rev.excluye_validacion = 0 THEN 1 ELSE 0 END) grupo3_hit,
			sum(CASE WHEN (nvl(b.grupo,'') = '3') AND NVL(b.evalua_cc,'') IN ('X','') and rev.excluye_validacion = 0 THEN 1 ELSE 0 END) grupo3_no_hit,
			sum(CASE WHEN (nvl(b.grupo,'') = '5') AND b.evalua_cc in ('0','1','2','3','4') and rev.excluye_validacion = 0 THEN 1 ELSE 0 END) grupo5_hit,
			sum(CASE WHEN (nvl(b.grupo,'') = '5') AND NVL(b.evalua_cc,'') IN ('X','') and rev.excluye_validacion = 0 THEN 1 ELSE 0 END) grupo5_no_hit,
			sum(CASE WHEN (nvl(b.Grupo,'') = '6') AND b.evalua_cc IN ('0','1','2','3','4') and rev.excluye_validacion = 0 THEN 1 ELSE 0 END) grupo6_hit,
			sum(CASE WHEN (nvl(b.Grupo,'') = '6') AND NVL(b.evalua_cc,'') IN ('X','') and rev.excluye_validacion = 0 THEN 1 ELSE 0 END) grupo6_no_hit,
			sum(CASE WHEN (nvl(b.Grupo,'') = 'A') AND b.evalua_cc IN ('0','1','2','3','4') and rev.excluye_validacion = 0 THEN 1 ELSE 0 END) grupoA_hit,
			sum(CASE WHEN (nvl(b.Grupo,'') = 'A') AND NVL(b.evalua_cc,'') IN ('X','') and rev.excluye_validacion = 0  THEN 1 ELSE 0 END) grupoA_no_hit,
			0 grupo7_hit, SUM(CASE WHEN (nvl(b.Grupo,'') = '7') OR (NVL(pr.tipo_alta,'') = '2' and nvl(a.num_producto,'') = '6500') and rev.excluye_validacion = 0 THEN 1 ELSE 0 END ) grupo7_no_hit,
			SUM(CASE WHEN (nvl(b.Grupo,'') = '8') AND b.evalua_cc IN ('0','1','2','3','4') and rev.excluye_validacion = 0 THEN 1 ELSE 0 END ) grupo8_hit,
			SUM(CASE WHEN (nvl(b.Grupo,'') = '8') AND NVL(b.evalua_cc,'') IN ('X','')and rev.excluye_validacion = 0 THEN 1 ELSE 0 END ) grupo8_no_hit,
			SUM(CASE WHEN rev.excluye_validacion = 1 AND b.evalua_cc IN ('0','1','2','3','4') THEN 1 ELSE 0 END ) grupo9_hit,
			SUM(CASE WHEN rev.excluye_validacion = 1 AND b.evalua_cc IN ('X','') THEN 1 ELSE 0 END ) grupo9_no_hit,
			sum(CASE WHEN (nvl(b.grupo,'') in ('1','4'))and rev.excluye_validacion = 0 THEN 1 ELSE 0 END +
				CASE WHEN (nvl(b.grupo,'') = '2')and rev.excluye_validacion = 0 THEN 1 ELSE 0 END +
				CASE WHEN (nvl(b.grupo,'') = '3')and rev.excluye_validacion = 0 THEN 1 ELSE 0 END +
				CASE WHEN (nvl(b.grupo,'') = '5') and rev.excluye_validacion = 0 THEN 1 ELSE 0 END +
				CASE WHEN (nvl(b.Grupo,'') = '6') and rev.excluye_validacion = 0 THEN 1 ELSE 0 END + 
				CASE WHEN (nvl(b.Grupo,'') = 'A')and rev.excluye_validacion = 0 THEN 1 ELSE 0 END +
				CASE WHEN (nvl(b.Grupo,'') = '7') OR (NVL(pr.tipo_alta,'') = '2' and nvl(a.num_producto,'') = '6500') and rev.excluye_validacion = 0 THEN 1 ELSE 0 END +
				CASE WHEN (nvl(b.Grupo,'') = '8')  and rev.excluye_validacion = 0 THEN 1 ELSE 0 END +(CASE WHEN rev.excluye_validacion = 1 THEN 1 ELSE 0 END ) )  cantidad,
			sum(CASE WHEN (nvl(b.grupo,'') in ('1','4')) AND b.evalua_cc IN ('0','1','2','3','4') and rev.excluye_validacion = 0 THEN 1 ELSE 0 END +
				CASE WHEN (nvl(b.grupo,'') = '2') AND b.evalua_cc IN ('0','1','2','3','4')and rev.excluye_validacion = 0 THEN 1 ELSE 0 END +
				CASE WHEN (nvl(b.grupo,'') = '3') AND b.evalua_cc IN ('0','1','2','3','4')and rev.excluye_validacion = 0 THEN 1 ELSE 0 END +
				CASE WHEN (nvl(b.grupo,'') = '5') AND b.evalua_cc in ('0','1','2','3','4')and rev.excluye_validacion = 0 THEN 1 ELSE 0 END +
				CASE WHEN (nvl(b.Grupo,'') = '6') AND b.evalua_cc IN ('0','1','2','3','4') and rev.excluye_validacion = 0 THEN 1 ELSE 0 END + CASE WHEN (nvl(b.Grupo,'') = 'A') AND b.evalua_cc IN ('0','1','2','3','4') and rev.excluye_validacion = 0 THEN 1 ELSE 0 END +
				CASE WHEN (nvl(b.Grupo,'') = '8') AND b.evalua_cc IN ('0','1','2','3','4') and rev.excluye_validacion = 0 THEN 1 ELSE 0 END  + (CASE WHEN rev.excluye_validacion = 1 AND b.evalua_cc IN ('0','1','2','3','4') THEN 1 ELSE 0 END ) ) 
				 cantidad_hit,
			sum(CASE WHEN (nvl(b.grupo,'') in ('1','4')) AND NVL(b.evalua_cc,'') IN ('X','') and rev.excluye_validacion = 0 THEN 1 ELSE 0 END +
				CASE WHEN (nvl(b.grupo,'') = '2') AND NVL(b.evalua_cc,'') IN ('X','')and rev.excluye_validacion = 0 THEN 1 ELSE 0 END +
				CASE WHEN (nvl(b.grupo,'') = '3') AND NVL(b.evalua_cc,'') IN ('X','')and rev.excluye_validacion = 0 THEN 1 ELSE 0 END +
				CASE WHEN (nvl(b.grupo,'') = '5') AND NVL(b.evalua_cc,'') IN ('X','') and rev.excluye_validacion = 0 THEN 1 ELSE 0 END +
				CASE WHEN (nvl(b.Grupo,'') = '6') AND NVL(b.evalua_cc,'') IN ('X','') and rev.excluye_validacion = 0 THEN 1 ELSE 0 END + CASE WHEN (nvl(b.Grupo,'') = 'A') AND NVL(b.evalua_cc,'') IN ('X','')  and rev.excluye_validacion = 0 THEN 1 ELSE 0 END +
				CASE WHEN (nvl(b.Grupo,'') = '7') OR (NVL(pr.tipo_alta,'') = '2' and nvl(a.num_producto,'') = '6500') and rev.excluye_validacion = 0 THEN 1 ELSE 0 END +
				CASE WHEN (nvl(b.Grupo,'') = '8') AND NVL(b.evalua_cc,'') IN ('X','')and rev.excluye_validacion = 0 THEN 1 ELSE 0 END  +  (CASE WHEN rev.excluye_validacion = 1 AND b.evalua_cc IN  ('X','') THEN 1 ELSE 0 END ))  cantidad_no_hit, '' sub_causa_solicitud
			from bdisolic:ss_solicitudes a,bdisolic:ss_resum_scor_fin b, bdisolic:ss_autorizacion c, outer bdiprospectos:pr_cliente pr, outer  "informix".ss_revision_determinacion rev
			WHERE a.empresa = b.empresa AND a.num_solicitud = b.num_solicitud 
			And rev.empresa= a.empresa and rev.num_solicitud= a.num_solicitud
			AND a.empresa = c.empresa AND a.num_solicitud = c.num_solicitud AND a.status_solicitud = c.status_solicitud and a.numcte = pr.numcte
			AND c.fecha_entrada = (select max(fecha_entrada) from bdisolic:ss_autorizacion where a.empresa = empresa and a.num_solicitud = num_solicitud and a.status_solicitud = status_solicitud)
			AND a.num_producto = pProducto AND a.fecha_insert >= pFechaIni AND a.fecha_insert <= pFechaFin 
			AND ((a.status_solicitud = pEstatus or pEstatus = '') AND (causa_solicitud = psubcausa or psubcausa ='')) and pr.tipo_alta = '2'
			GROUP BY 1,2,3,4,5,6,7,8,9;  
			

	
	
	
	
	IF pEstatus <> '' and psubcausa = '' THEN     	
	insert into sol2
		SELECT '', status_solicitud, causa_solicitud, sucursal,0,0,0,0,date(1),
		sum(grupo1_hit),sum(grupo1_no_hit),	sum(grupo2_hit), sum(grupo2_no_hit),sum(grupo3_hit),sum(grupo3_no_hit),
		sum(grupo5_hit),sum(grupo5_no_hit),sum(grupo6_hit),sum(grupo6_no_hit),sum(grupoA_hit),sum(grupoA_no_hit),
		0 grupo7_hit, sum(grupo7_no_hit),sum(grupo8_hit),sum(grupo8_no_hit),sum(grupo9_hit),sum(grupo9_no_hit),sum(cantidad),sum(cantidad_hit),sum(cantidad_no_hit),'' sub_causa_solicitud
		from Tsolicitud 
		WHERE status_solicitud = pEstatus 
		GROUP BY 2,3,4; 
	ELIF pEstatus = '' AND psubcausa = '' THEN	
		insert into sol2
		SELECT '',status_solicitud, '', sucursal,0,0,0,0,date(1),		
		sum(grupo1_hit),sum(grupo1_no_hit),	sum(grupo2_hit), sum(grupo2_no_hit),sum(grupo3_hit),sum(grupo3_no_hit),
		sum(grupo5_hit),sum(grupo5_no_hit),sum(grupo6_hit),sum(grupo6_no_hit),sum(grupoA_hit),sum(grupoA_no_hit),
		0 grupo7_hit, sum(grupo7_no_hit),sum(grupo8_hit),sum(grupo8_no_hit),sum(grupo9_hit),sum(grupo9_no_hit),sum(cantidad),sum(cantidad_hit),sum(cantidad_no_hit),'' sub_causa_solicitud
		from Tsolicitud 		
		GROUP BY 2,4;
	ELIF pEstatus <> '' AND psubcausa <> '' THEN
		---sol2
		insert into sol2
		SELECT 
		numcte,status_solicitud, causa_solicitud, sucursal,abonomensualropa, abonomensualmuebles, abonomensualprestamos, compromisos_bco,fecha_insert,
		sum(grupo1_hit),sum(grupo1_no_hit),	sum(grupo2_hit), sum(grupo2_no_hit),sum(grupo3_hit),sum(grupo3_no_hit),
		sum(grupo5_hit),sum(grupo5_no_hit),sum(grupo6_hit),sum(grupo6_no_hit),sum(grupoA_hit),sum(grupoA_no_hit),
		0 grupo7_hit, sum(grupo7_no_hit),sum(grupo8_hit),sum(grupo8_no_hit),sum(grupo9_hit),sum(grupo9_no_hit),sum(cantidad),sum(cantidad_hit),sum(cantidad_no_hit),'' sub_causa_solicitud
		from Tsolicitud
        where status_solicitud = pEstatus AND causa_solicitud = psubcausa 		
		GROUP BY 1,2,3,4,5,6,7,8,9;
		create temp table sol4( numcte char(20),institucion char(2) ) with no log;
		
		create temp table sol3
		( numcte char(20), status_solicitud char(2), causa_solicitud char(3),sucursal char(4),
		  abonomensualropa money, abonomensualmuebles money,abonomensualprestamos money,compromisos_bco decimal (14,2),fecha_insert date,
		  grupo1_hit integer,grupo1_no_hit integer,grupo2_hit integer,grupo2_no_hit integer,grupo3_hit integer,  grupo3_no_hit integer,
		  grupo5_hit integer,grupo5_no_hit integer,grupo6_hit integer,grupo6_no_hit integer,grupoA_hit integer,grupoA_no_hit integer,
		  grupo7_hit integer,  grupo7_no_hit integer,grupo8_hit integer,grupo8_no_hit integer,grupo9_hit integer,grupo9_no_hit integer,cantidad integer,cantidad_hit integer,
		  cantidad_no_hit integer, sub_causa_solicitud char(3), institucion char(2) ) with no log;
		  
		insert into sol4			
		SELECT numcte,max(a.institucion) as institucion FROM bdiburo:br_tl a,sol2 WHERE num_cliente = numcte GROUP BY numcte ;
		insert into sol3
		SELECT a.*, b.institucion FROM sol2 a LEFT OUTER JOIN sol4 b ON a.numcte = b.numcte;
		delete from sol2;	
		insert into sol2
		SELECT a.numcte,a.status_solicitud,a.causa_solicitud,a.sucursal,0,0,0,0,date(1),
		       a.grupo1_hit,a.grupo1_no_hit,a.grupo2_hit,a.grupo2_no_hit,a.grupo3_hit,a.grupo3_no_hit,a.grupo5_hit,a.grupo5_no_hit,a.grupo6_hit,a.grupo6_no_hit,a.grupoA_hit,a.grupoA_no_hit,
               a.grupo7_hit,a.grupo7_no_hit,a.grupo8_hit,a.grupo8_no_hit,a.grupo9_hit,grupo9_no_hit,a.cantidad,a.cantidad_hit,a.cantidad_no_hit,
			(CASE WHEN a.institucion in ('BC','CC') AND a.abonomensualropa = 0 AND a.abonomensualmuebles = 0 AND a.abonomensualprestamos = 0 AND a.compromisos_bco = 0 THEN 'RC1'
				WHEN (a.institucion = '' OR a.institucion IS NULL) AND (a.abonomensualropa <> 0 OR a.abonomensualmuebles <> 0 OR a.abonomensualprestamos <> 0) AND a.compromisos_bco = 0 THEN 'RC2'
				WHEN (a.institucion = '' OR a.institucion IS NULL) AND (a.abonomensualropa = 0 OR a.abonomensualmuebles = 0 OR a.abonomensualprestamos = 0) AND a.compromisos_bco <> 0 THEN 'RC3'
				WHEN a.institucion in ('BC','CC') AND (a.abonomensualropa <> 0 OR a.abonomensualmuebles <> 0 OR a.abonomensualprestamos <> 0) AND a.compromisos_bco = 0 THEN 'RC4'
				WHEN a.institucion in ('BC','CC') AND (a.abonomensualropa <> 0 OR a.abonomensualmuebles <> 0 OR a.abonomensualprestamos <> 0) AND a.compromisos_bco <> 0 THEN 'RC5'
				WHEN (a.institucion = '' OR a.institucion IS NULL) AND (a.abonomensualropa <> 0 OR a.abonomensualmuebles <> 0 OR a.abonomensualprestamos <> 0) AND a.compromisos_bco <> 0 THEN 'RC6'
				WHEN a.institucion in ('BC','CC') AND (a.abonomensualropa = 0 OR a.abonomensualmuebles = 0 OR a.abonomensualprestamos = 0) AND a.compromisos_bco <> 0 THEN 'RC7'
			ELSE 'RC8' END) sub_causa_solicitud FROM sol3 a;
	END IF;
	
	create temp table total(numcte char(20),status_solicitud char(2), causa_solicitud char(3) , sucursal char(4),
	abonomensualropa money,abonomensualmuebles money,abonomensualprestamos money,compromisos_bco decimal (14,2),fecha_insert date,
    grupo1_hit integer,grupo1_no_hit integer,grupo2_hit integer,grupo2_no_hit integer,grupo3_hit integer,grupo3_no_hit integer,
    grupo5_hit integer,grupo5_no_hit integer,grupo6_hit integer,grupo6_no_hit integer,grupoA_hit integer,grupoA_no_hit integer,
    grupo7_hit integer,  grupo7_no_hit integer,grupo8_hit integer,grupo8_no_hit integer,grupo9_hit integer,grupo9_no_hit integer,cantidad integer,cantidad_hit integer,
    cantidad_no_hit integer,sub_causa_solicitud char(3),descripcion char (50),orden_reporte smallint, ciudad char(3),
    estado char(2),numero_region smallint) with no log;
	
create temp table total_sol_group
( descripcion char(100),  status_solicitud  char(3), grupo1_hit integer,grupo1_no_hit integer, 
grupo2_hit integer,grupo2_no_hit integer,grupo3_hit integer,grupo3_no_hit integer, grupo5_hit integer,
grupo5_no_hit integer,grupo6_hit integer,grupo6_no_hit integer,  grupoA_hit integer,grupoA_no_hit integer,
grupo7_hit integer,grupo7_no_hit integer,grupo8_hit integer,grupo8_no_hit integer,grupo9_hit integer,grupo9_no_hit integer,total_x_status_hit integer,
total_x_status_no_hit integer,porc_status_hit decimal (14,2),porc_status_no_hit decimal (14,2),
total_x_status	integer,porc_status decimal (14,2),tiene_causas integer,orden_reporte	smallint) with no log;
	insert into total
	SELECT a.*,/*'',*/b.descripcion, b.orden_reporte, c.ciudad, c.estado, r.numero_region
		FROM sol2 a,bdisolic:ss_status_sol b,bdinteg:si_sucursales s,bdinteg:si_ciudades c ,bdinteg:si_catciudades t
		left outer join bdinteg:si_regiones r on ( t.numero_region = r.numero_region)
	WHERE b.empresa = pEmpresa AND a.status_solicitud = b.status_solicitud AND activa_reporte = "1" AND a.sucursal = s.sucursal
	AND s.ciudad = c.ciudad AND s.pais = c.pais AND s.estado = c.estado AND c.ciudad_coppel = t.numerociudad ;

	IF pTpConsulta = '04' THEN ---SUCURSAL
	create temp table total_sucursal( sucursal char(4),total integer,total_hit integer,total_no_hit integer) with no log;
	    insert into total_sucursal 
		SELECT sucursal, sum(cantidad) total,sum(cantidad_hit) total_hit,sum(cantidad_no_hit) total_no_hit FROM total group by 1; 		
		IF pFiltro <> '' AND pEstatus = '' AND psubcausa = '' THEN
			SELECT sum(total),sum(total_hit),sum(total_no_hit) INTO total_sol_rep,total_sol_rep_hit,total_sol_rep_no_hit FROM total_sucursal WHERE sucursal = pFiltro;
		ELIF pFiltro <> '' AND pEstatus <> '' AND (psubcausa = '' OR psubcausa <> '') THEN
			SELECT sum(cantidad),sum(cantidad_hit),sum(cantidad_no_hit) INTO total_sol_rep,total_sol_rep_hit,total_sol_rep_no_hit FROM total WHERE sucursal = pFiltro AND status_solicitud = pEstatus;
		ELSE
			SELECT sum(total),sum(total_hit),sum(total_no_hit) INTO total_sol_rep,total_sol_rep_hit,total_sol_rep_no_hit FROM total_sucursal;
		END IF;
		IF ( pFiltro <> '' AND pEstatus = '' AND psubcausa = '') or (pFiltro = '' AND pEstatus = '' AND psubcausa = '') THEN
			insert into total_sol_group
			SELECT a.descripcion,a.status_solicitud, sum(a.grupo1_hit) as grupo1_hit, sum(a.grupo1_no_hit) as grupo1_no_hit, sum(a.grupo2_hit) as grupo2_hit,sum(a.grupo2_no_hit) as grupo2_no_hit,
			sum(a.grupo3_hit) as grupo3_hit, sum(a.grupo3_no_hit) as grupo3_no_hit,sum(grupo5_hit) as grupo5_hit,sum(grupo5_no_hit) as grupo5_no_hit,
			sum(a.grupo6_hit) as grupo6_hit,sum(a.grupo6_no_hit) as grupo6_no_hit, sum(a.grupoA_hit) as grupoA_hit,sum(a.grupoA_no_hit) as grupoA_no_hit, 
            sum(grupo7_hit) as grupo7_hit,sum(grupo7_no_hit) as grupo7_no_hit, sum(grupo8_hit) as grupo8_hit,sum(grupo8_no_hit) as grupo8_no_hit, sum(grupo9_hit) as grupo9_hit,  sum(grupo9_no_hit) as grupo9_no_hit,
			sum(a.cantidad_hit) as total_x_status_hit, sum(a.cantidad_no_hit) as total_x_status_no_hit,
			ROUND((sum(a.cantidad_hit) / case when total_sol_rep_hit = 0 then 1 else total_sol_rep_hit end) * 100,2) as porc_status_hit,
			ROUND((sum(a.cantidad_no_hit) / case when total_sol_rep_no_hit = 0 then 1 else total_sol_rep_no_hit end) * 100,2) as porc_status_no_hit,
			sum(a.cantidad) as total_x_status, ROUND((sum(a.cantidad) / case when total_sol_rep = 0 then 1 else total_sol_rep end) * 100,2) as porc_status,
			(CASE WHEN a.status_solicitud IN ('RT','CM','CN','AT','AP') THEN 1 ELSE 0 END) as tiene_causas,b.orden_reporte
			FROM total a, bdisolic:ss_status_sol b
			WHERE a.status_solicitud = b.status_solicitud and b.activa_reporte = "1" and ( a.sucursal = pFiltro or pFiltro ='' )
			GROUP BY a.descripcion,a.status_solicitud,b.orden_reporte; 
		ELIF (pFiltro = '' AND pEstatus <> '' AND psubcausa = '') or (pFiltro <> '' AND pEstatus <> '' AND psubcausa = '' ) THEN	--DETALLE
			insert into total_sol_group
			SELECT c.descripcion,a.causa_solicitud, sum(a.grupo1_hit) as grupo1_hit,sum(a.grupo1_no_hit) as grupo1_no_hit, sum(a.grupo2_hit) as grupo2_hit,sum(a.grupo2_no_hit) as grupo2_no_hit,
			sum(a.grupo3_hit) as grupo3_hit,sum(a.grupo3_no_hit) as grupo3_no_hit,sum(grupo5_hit) as grupo5_hit,sum(grupo5_no_hit) as grupo5_no_hit,
			sum(a.grupo6_hit) as grupo6_hit,sum(a.grupo6_no_hit) as grupo6_no_hit, sum(a.grupoA_hit) as grupoA_hit,sum(a.grupoA_no_hit) as grupoA_no_hit,
            sum(grupo7_hit) as grupo7_hit,sum(grupo7_no_hit) as grupo7_no_hit,sum(grupo8_hit) as grupo8_hit,sum(grupo8_no_hit) as grupo8_no_hit, sum(grupo9_hit) as grupo9_hit, sum(grupo9_no_hit) as grupo9_no_hit,
			sum(a.cantidad_hit) as total_x_status_hit,sum(a.cantidad_no_hit) as total_x_status_no_hit,
			ROUND((sum(a.cantidad_hit) / case when total_sol_rep_hit = 0 then 1 else total_sol_rep_hit end) * 100,2) as porc_status_hit,
			ROUND((sum(a.cantidad_no_hit) / case when total_sol_rep_no_hit = 0 then 1 else total_sol_rep_no_hit end) * 100,2) as porc_status_no_hit,
			sum(a.cantidad) as total_x_status,ROUND((sum(a.cantidad) / case when total_sol_rep = 0 then 1 else total_sol_rep end) * 100,2) as porc_status,
			sum(CASE WHEN c.status_solicitud = 'RT' AND c.causa_solicitud = 'CPS' THEN 1 ELSE 0 END) as tiene_causas,c.orden_reporte --MOD
			FROM total a, bdisolic:ss_status_sol b,bdisolic:ss_causas_sol c
			WHERE a.status_solicitud = b.status_solicitud AND a.status_solicitud = c.status_solicitud
			AND a.causa_solicitud = c.causa_solicitud AND ( a.sucursal = pFiltro or pFiltro='')
			AND (a.status_solicitud = pEstatus or pEstatus='') AND b.activa_reporte = c.activa_reporte
			AND b.activa_reporte = "1"
		GROUP BY c.descripcion,a.causa_solicitud,c.orden_reporte;
		END IF;
	END IF;
	IF pTpConsulta	 = '01' THEN ---ESTADO
	create temp table total_estado	    (  estado char(2),total integer,total_hit integer,total_no_hit integer) with no log;
			insert into total_estado
			SELECT estado, sum(cantidad) total,sum(cantidad_hit) total_hit,sum(cantidad_no_hit) total_no_hit FROM total GROUP BY 1; 
		IF pFiltro <> '' AND pEstatus = '' AND psubcausa = '' THEN
			LET total_sol_rep = 0;
			SELECT sum(total),sum(total_hit),sum(total_no_hit) INTO total_sol_rep,total_sol_rep_hit,total_sol_rep_no_hit FROM total_estado WHERE estado = pFiltro;
		ELIF pFiltro <> '' AND pEstatus <> '' AND (psubcausa = '' OR psubcausa <> '') THEN
			SELECT sum(cantidad),sum(cantidad_hit),sum(cantidad_no_hit) INTO total_sol_rep,total_sol_rep_hit,total_sol_rep_no_hit FROM total WHERE estado = pFiltro AND status_solicitud = pEstatus;
		ELSE 
			SELECT sum(total),sum(total_hit),sum(total_no_hit) INTO total_sol_rep,total_sol_rep_hit,total_sol_rep_no_hit FROM total_estado;
		END IF;
		IF pFiltro <> '' AND pEstatus = '' AND psubcausa = '' THEN
			insert into total_sol_group
			SELECT a.descripcion,a.status_solicitud, sum(a.grupo1_hit) as grupo1_hit, sum(a.grupo1_no_hit) as grupo1_no_hit, sum(a.grupo2_hit) as grupo2_hit, sum(a.grupo2_no_hit) as grupo2_no_hit,
			sum(a.grupo3_hit) as grupo3_hit, sum(a.grupo3_no_hit) as grupo3_no_hit, sum(grupo5_hit) as grupo5_hit, sum(grupo5_no_hit) as grupo5_no_hit,
			sum(a.grupo6_hit) as grupo6_hit,sum(a.grupo6_no_hit) as grupo6_no_hit, sum(a.grupoA_hit) as grupoA_hit,sum(a.grupoA_no_hit) as grupoA_no_hit,
            sum(grupo7_hit) as grupo7_hit, sum(grupo7_no_hit) as grupo7_no_hit,sum(grupo8_hit) as grupo8_hit, sum(grupo8_no_hit) as grupo8_no_hit, sum(grupo9_hit) as grupo9_hit, sum(grupo9_no_hit) as grupo9_no_hit,
			sum(a.cantidad_hit) as total_x_status_hit,sum(a.cantidad_no_hit) as total_x_status_no_hit,
			ROUND((sum(a.cantidad_hit) / case when total_sol_rep_hit = 0 then 1 else total_sol_rep_hit end) * 100,2) as porc_status_hit,
			ROUND((sum(a.cantidad_no_hit) / case when total_sol_rep_no_hit = 0 then 1 else total_sol_rep_no_hit end) * 100,2) as porc_status_no_hit,
			sum(a.cantidad) as total_x_status, ROUND((sum(a.cantidad) / case when total_sol_rep = 0 then 1 else total_sol_rep end) * 100,2) as porc_status,
			(CASE WHEN a.status_solicitud IN ('RT','CM','CN','AT','AP') THEN 1 ELSE 0 END) as tiene_causas,b.orden_reporte
			FROM total a, bdisolic:ss_status_sol b
			WHERE a.status_solicitud = b.status_solicitud AND b.activa_reporte = "1" AND a.estado = pFiltro
			GROUP BY a.descripcion,a.status_solicitud,b.orden_reporte;
		ELIF pFiltro = '' AND pEstatus = '' AND psubcausa = '' THEN
			insert into total_sol_group
			SELECT a.descripcion,a.status_solicitud,sum(a.grupo1_hit) as grupo1_hit,sum(a.grupo1_no_hit) as grupo1_no_hit,sum(a.grupo2_hit) as grupo2_hit,sum(a.grupo2_no_hit) as grupo2_no_hit,
			sum(a.grupo3_hit) as grupo3_hit,sum(a.grupo3_no_hit) as grupo3_no_hit,sum(grupo5_hit) as grupo5_hit,sum(grupo5_no_hit) as grupo5_no_hit,
			sum(a.grupo6_hit) as grupo6_hit,sum(a.grupo6_no_hit) as grupo6_no_hit, sum(a.grupoA_hit) as grupoA_hit,sum(a.grupoA_no_hit) as grupoA_no_hit,
            sum(grupo7_hit) as grupo7_hit,sum(grupo7_no_hit) as grupo7_no_hit,sum(grupo8_hit) as grupo8_hit,sum(grupo8_no_hit) as grupo8_no_hit, sum(grupo9_hit) as grupo9_hit, sum(grupo9_no_hit) as grupo9_no_hit,
			sum(a.cantidad_hit) as total_x_status_hit,sum(a.cantidad_no_hit) as total_x_status_no_hit,
			ROUND((sum(a.cantidad_hit) / case when total_sol_rep_hit = 0 then 1 else total_sol_rep_hit end) * 100,2) as porc_status_hit,
			ROUND((sum(a.cantidad_no_hit) / case when total_sol_rep_no_hit = 0 then 1 else total_sol_rep_no_hit end) * 100,2) as porc_status_no_hit,
			sum(a.cantidad) as total_x_status, ROUND((sum(a.cantidad) / case when total_sol_rep = 0 then 1 else total_sol_rep end) * 100,2) as porc_status,
			(CASE WHEN a.status_solicitud IN ('RT','CM','CN','AT','AP') THEN 1 ELSE 0 END) as tiene_causas,b.orden_reporte
			FROM total a, bdisolic:ss_status_sol b
			WHERE a.status_solicitud = b.status_solicitud AND b.activa_reporte = "1" 
			GROUP BY a.descripcion,a.status_solicitud,b.orden_reporte; 
		ELIF (pFiltro = '' AND pEstatus <> '' AND psubcausa = '') or (pFiltro <> '' AND pEstatus <> '' AND psubcausa = '') THEN
			insert into total_sol_group
			SELECT c.descripcion,a.causa_solicitud,sum(a.grupo1_hit) as grupo1_hit,sum(a.grupo1_no_hit) as grupo1_no_hit,sum(a.grupo2_hit) as grupo2_hit,sum(a.grupo2_no_hit) as grupo2_no_hit,
			sum(a.grupo3_hit) as grupo3_hit,sum(a.grupo3_no_hit) as grupo3_no_hit,sum(grupo5_hit) as grupo5_hit,sum(grupo5_no_hit) as grupo5_no_hit,
			sum(a.grupo6_hit) as grupo6_hit,sum(a.grupo6_no_hit) as grupo6_no_hit, sum(a.grupoA_hit) as grupoA_hit,sum(a.grupoA_no_hit) as grupoA_no_hit,
            sum(grupo7_hit) as grupo7_hit,sum(grupo7_no_hit) as grupo7_no_hit,sum(grupo8_hit) as grupo8_hit,sum(grupo8_no_hit) as grupo8_no_hit, sum(grupo9_hit) as grupo9_hit, sum(grupo9_no_hit) as grupo9_no_hit,
			sum(a.cantidad_hit) as total_x_status_hit,sum(a.cantidad_no_hit) as total_x_status_no_hit,
			ROUND((sum(a.cantidad_hit) / case when total_sol_rep_hit = 0 then 1 else total_sol_rep_hit end) * 100,2) as porc_status_hit,
			ROUND((sum(a.cantidad_no_hit) / case when total_sol_rep_no_hit = 0 then 1 else total_sol_rep_no_hit end) * 100,2) as porc_status_no_hit,
			sum(a.cantidad) as total_x_status,ROUND((sum(a.cantidad) / case when total_sol_rep = 0 then 1 else total_sol_rep end) * 100,2) as porc_status,
			sum(CASE WHEN c.status_solicitud = 'RT' AND c.causa_solicitud = 'CPS' THEN 1 ELSE 0 END) as tiene_causas, c.orden_reporte
			FROM total a, bdisolic:ss_status_sol b,bdisolic:ss_causas_sol c
			WHERE a.status_solicitud = b.status_solicitud AND a.status_solicitud = c.status_solicitud AND a.causa_solicitud = c.causa_solicitud
			AND (a.estado = pFiltro or pFiltro='') AND (a.status_solicitud = pEstatus or pEstatus='') AND b.activa_reporte = c.activa_reporte AND b.activa_reporte = "1"
			GROUP BY c.descripcion,a.causa_solicitud,c.orden_reporte; 
		END IF;
	END IF;
	IF pTpConsulta	 = '02' THEN ---CIUDAD
		create temp table total_ciudad	    (  ciudad char(3), estado char(2),total integer,total_hit integer,total_no_hit integer) with no log;		 
		insert into total_ciudad
		SELECT ciudad,estado, sum(cantidad) total, sum(cantidad_hit) total_hit, sum(cantidad_no_hit) total_no_hit FROM total group by 1,2; 		
		IF pFiltro <> '' AND pEstatus = '' AND psubcausa = '' THEN
			SELECT sum(total),sum(total_hit),sum(total_no_hit) INTO total_sol_rep,total_sol_rep_hit,total_sol_rep_no_hit FROM total_ciudad WHERE estado = pretedocd and ciudad = lpad(pFiltro,3,0);
		ELIF pFiltro <> '' AND pEstatus <> '' AND (psubcausa = '' OR psubcausa <> '') THEN
			SELECT sum(cantidad),sum(cantidad_hit),sum(cantidad_no_hit) INTO total_sol_rep,total_sol_rep_hit,total_sol_rep_no_hit FROM total WHERE estado = pretedocd and ciudad = pFiltro AND status_solicitud = pEstatus;
		ELSE
			SELECT sum(total),sum(total_hit),sum(total_no_hit) INTO total_sol_rep,total_sol_rep_hit,total_sol_rep_no_hit FROM total_ciudad;
		END IF;

		IF (pFiltro <> '' AND pEstatus = '' AND psubcausa = '') or (pFiltro = '' AND pEstatus = '' AND psubcausa = '') THEN
			insert into total_sol_group
			SELECT a.descripcion,a.status_solicitud,sum(a.grupo1_hit) as grupo1_hit,sum(a.grupo1_no_hit) as grupo1_no_hit,sum(a.grupo2_hit) as grupo2_hit,sum(a.grupo2_no_hit) as grupo2_no_hit,
			sum(a.grupo3_hit) as grupo3_hit,sum(a.grupo3_no_hit) as grupo3_no_hit,sum(a.grupo5_hit) as grupo5_hit,sum(a.grupo5_no_hit) as grupo5_no_hit,
			sum(a.grupo6_hit) as grupo6_hit,sum(a.grupo6_no_hit) as grupo6_no_hit, sum(a.grupoA_hit) as grupoA_hit,sum(a.grupoA_no_hit) as grupoA_no_hit,
            sum(a.grupo7_hit) as grupo7_hit,sum(a.grupo7_no_hit) as grupo7_no_hit,sum(a.grupo8_hit) as grupo8_hit,sum(a.grupo8_no_hit) as grupo8_no_hit, sum(grupo9_hit) as grupo9_hit, sum(grupo9_no_hit) as grupo9_no_hit,
			sum(a.cantidad_hit) as total_x_status_hit,sum(a.cantidad_no_hit) as total_x_status_no_hit,
			ROUND((sum(a.cantidad_hit) / case when total_sol_rep_hit = 0 then 1 else total_sol_rep_hit end) * 100,2) as porc_status_hit,
			ROUND((sum(a.cantidad_no_hit) / case when total_sol_rep_no_hit = 0 then 1 else total_sol_rep_no_hit end) * 100,2) as porc_status_no_hit,
			sum(a.cantidad) as total_x_status,ROUND((sum(a.cantidad) / case when total_sol_rep = 0 then 1 else total_sol_rep end) * 100,2) as porc_status,
			(CASE WHEN a.status_solicitud IN ('RT','CM','CN','AT','AP') THEN 1 ELSE 0 END) as tiene_causas,b.orden_reporte
			FROM total a, bdisolic:ss_status_sol b
			WHERE a.status_solicitud = b.status_solicitud and b.activa_reporte = "1" and (a.estado = pretedocd or pretedocd='') 
			and ( a.ciudad = lpad(pFiltro,3,0) or pFiltro='')
			GROUP BY a.descripcion,a.status_solicitud,b.orden_reporte; 
		ELIF (pFiltro = '' AND pEstatus <> '' AND psubcausa = '') or (pFiltro <> '' AND pEstatus <> '' AND psubcausa = '') THEN ----DETALLE
			insert into total_sol_group
			SELECT c.descripcion,a.causa_solicitud, sum(a.grupo1_hit) as grupo1_hit, sum(a.grupo1_no_hit) as grupo1_no_hit, sum(a.grupo2_hit) as grupo2_hit,sum(a.grupo2_no_hit) as grupo2_no_hit,
			sum(a.grupo3_hit) as grupo3_hit,sum(a.grupo3_no_hit) as grupo3_no_hit,sum(a.grupo5_hit) as grupo5_hit,sum(a.grupo5_no_hit) as grupo5_no_hit,
			sum(a.grupo6_hit) as grupo6_hit,sum(a.grupo6_no_hit) as grupo6_no_hit, sum(a.grupoA_hit) as grupoA_hit,sum(a.grupoA_no_hit) as grupoA_no_hit,
            sum(a.grupo7_hit) as grupo7_hit,sum(a.grupo7_no_hit) as grupo7_no_hit,sum(a.grupo8_hit) as grupo8_hit,sum(a.grupo8_no_hit) as grupo8_no_hit, sum(grupo9_hit) as grupo9_hit, sum(grupo9_no_hit) as grupo9_no_hit,
			sum(a.cantidad_hit) as total_x_status_hit,sum(a.cantidad_no_hit) as total_x_status_no_hit,
			ROUND((sum(a.cantidad_hit) / case when total_sol_rep_hit = 0 then 1 else total_sol_rep_hit end) * 100,2) as porc_status_hit,
			ROUND((sum(a.cantidad_no_hit) / case when total_sol_rep_no_hit = 0 then 1 else total_sol_rep_no_hit end) * 100,2) as porc_status_no_hit,
			sum(a.cantidad) as total_x_status,ROUND((sum(a.cantidad) / case when total_sol_rep = 0 then 1 else total_sol_rep end) * 100,2) as porc_status,
			sum(CASE WHEN c.status_solicitud = 'RT' AND c.causa_solicitud = 'CPS' THEN 1 ELSE 0 END) as tiene_causas,c.orden_reporte --MOD
			FROM total a, bdisolic:ss_status_sol b,bdisolic:ss_causas_sol c
			WHERE a.status_solicitud = b.status_solicitud AND a.status_solicitud = c.status_solicitud AND a.causa_solicitud = c.causa_solicitud
			AND (a.estado = pretedocd or pretedocd='') AND (a.ciudad = pFiltro or pFiltro='') AND (a.status_solicitud = pEstatus or pEstatus='')
			AND b.activa_reporte = c.activa_reporte AND b.activa_reporte = "1"
			GROUP BY c.descripcion,a.causa_solicitud,c.orden_reporte;			
		END IF;
	END IF;
	IF pTpConsulta	 = '03' THEN ---REGION
		create temp table total_region (  numero_region smallint,total integer,total_hit integer,total_no_hit integer) with no log;
		insert into total_region
		SELECT numero_region, sum(cantidad) total, sum(cantidad_hit) total_hit, sum(cantidad_no_hit) total_no_hit FROM total group by 1;
		
		IF pFiltro <> '' AND pEstatus = '' AND psubcausa = '' THEN
			SELECT sum(total),sum(total_hit),sum(total_no_hit) INTO total_sol_rep,total_sol_rep_hit,total_sol_rep_no_hit FROM total_region WHERE numero_region = pFiltro;
		ELIF pFiltro <> '' AND pEstatus <> '' AND (psubcausa = '' OR psubcausa <> '') THEN
			SELECT sum(cantidad),sum(cantidad_hit),sum(cantidad_no_hit) INTO total_sol_rep,total_sol_rep_hit,total_sol_rep_no_hit FROM total WHERE numero_region = pFiltro AND status_solicitud = pEstatus;
		ELSE
			SELECT sum(total),sum(total_hit),sum(total_no_hit) INTO total_sol_rep,total_sol_rep_hit,total_sol_rep_no_hit FROM total_region;
		END IF;
		IF (pFiltro <> '' AND pEstatus = '' AND psubcausa = '') or (pFiltro = '' AND pEstatus = '' AND psubcausa = '' ) THEN
			insert into total_sol_group
			select a.descripcion,a.status_solicitud,sum(a.grupo1_hit) as grupo1_hit, sum(a.grupo1_no_hit) as grupo1_no_hit, sum(a.grupo2_hit) as grupo2_hit, sum(a.grupo2_no_hit) as grupo2_no_hit,
			sum(a.grupo3_hit) as grupo3_hit, sum(a.grupo3_no_hit) as grupo3_no_hit, sum(a.grupo5_hit) as grupo5_hit, sum(a.grupo5_no_hit) as grupo5_no_hit,
			sum(a.grupo6_hit) as grupo6_hit,sum(a.grupo6_no_hit) as grupo6_no_hit, sum(a.grupoA_hit) as grupoA_hit,sum(a.grupoA_no_hit) as grupoA_no_hit,
            sum(a.grupo7_hit) as grupo7_hit, sum(a.grupo7_no_hit) as grupo7_no_hit,sum(a.grupo8_hit) as grupo8_hit, sum(a.grupo8_no_hit) as grupo8_no_hit, sum(grupo9_hit) as grupo9_hit, sum(grupo9_no_hit) as grupo9_no_hit,
			sum(a.cantidad_hit) as total_x_status_hit,sum(a.cantidad_no_hit) as total_x_status_no_hit,
			ROUND((sum(a.cantidad_hit) / case when total_sol_rep_hit = 0 then 1 else total_sol_rep_hit end) * 100,2) as porc_status_hit,
			ROUND((sum(a.cantidad_no_hit) / case when total_sol_rep_no_hit = 0 then 1 else total_sol_rep_no_hit end) * 100,2) as porc_status_no_hit,
			sum(a.cantidad) as total_x_status, ROUND((sum(a.cantidad) / case when total_sol_rep = 0 then 1 else total_sol_rep end) * 100,2) as porc_status,
			(CASE WHEN a.status_solicitud IN ('RT','CM','CN','AT','AP') THEN 1 ELSE 0 END) as tiene_causas,b.orden_reporte
			from total a, bdisolic:ss_status_sol b
			where a.status_solicitud = b.status_solicitud and b.activa_reporte = "1" and (a.numero_region = pFiltro or pFiltro ='')
			GROUP BY a.descripcion,a.status_solicitud,b.orden_reporte; 
		ELIF (pFiltro = '' AND pEstatus <> '' AND psubcausa = '') or (pFiltro <> '' AND pEstatus <> '' AND psubcausa = '') THEN --DETALLE
			insert into total_sol_group
			SELECT c.descripcion,a.causa_solicitud, sum(a.grupo1_hit) as grupo1_hit,sum(a.grupo1_no_hit) as grupo1_no_hit, sum(a.grupo2_hit) as grupo2_hit, sum(a.grupo2_no_hit) as grupo2_no_hit,
			sum(a.grupo3_hit) as grupo3_hit, sum(a.grupo3_no_hit) as grupo3_no_hit, sum(a.grupo5_hit) as grupo5_hit, sum(a.grupo5_no_hit) as grupo5_no_hit,
			sum(a.grupo6_hit) as grupo6_hit,sum(a.grupo6_no_hit) as grupo6_no_hit, sum(a.grupoA_hit) as grupoA_hit,sum(a.grupoA_no_hit) as grupoA_no_hit,
            sum(a.grupo7_hit) as grupo7_hit, sum(a.grupo7_no_hit) as grupo7_no_hit,sum(a.grupo8_hit) as grupo8_hit, sum(a.grupo8_no_hit) as grupo8_no_hit, sum(grupo9_hit) as grupo9_hit, sum(grupo9_no_hit) as grupo9_no_hit,
			sum(a.cantidad_hit) as total_x_status_hit,sum(a.cantidad_no_hit) as total_x_status_no_hit,
			ROUND((sum(a.cantidad_hit) / case when total_sol_rep_hit = 0 then 1 else total_sol_rep_hit end) * 100,2) as porc_status_hit,
			ROUND((sum(a.cantidad_no_hit) / case when total_sol_rep_no_hit = 0 then 1 else total_sol_rep_no_hit end) * 100,2) as porc_status_no_hit,
			sum(a.cantidad) as total_x_status,ROUND((sum(a.cantidad) / case when total_sol_rep = 0 then 1 else total_sol_rep end) * 100,2) as porc_status, 
			sum(CASE WHEN c.status_solicitud = 'RT' AND c.causa_solicitud = 'CPS' THEN 1 ELSE 0 END) as tiene_causas, c.orden_reporte --MOD
			FROM total a, bdisolic:ss_status_sol b,bdisolic:ss_causas_sol c
			WHERE a.status_solicitud = b.status_solicitud AND a.status_solicitud = c.status_solicitud AND a.causa_solicitud = c.causa_solicitud
			AND (a.numero_region = pFiltro or pFiltro ='') AND (a.status_solicitud = pEstatus OR pEstatus='') AND b.activa_reporte = c.activa_reporte AND b.activa_reporte = "1"
			GROUP BY c.descripcion,a.causa_solicitud,c.orden_reporte; 
		END IF;
	END IF;	
--INI EVALUACIONES DE LA CLASIFICACION DE LA CAUSA CPS
		IF pFiltro = '' AND pEstatus <> '' AND psubcausa <> '' AND pretedocd = '' THEN ----TODAS
			insert into total_sol_group
			SELECT trim(c.descripcion) ||' (CPS)' as descripcion,a.sub_causa_solicitud as causa_solicitud,sum(a.grupo1_hit) as grupo1_hit,sum(a.grupo1_no_hit) as grupo1_no_hit,sum(a.grupo2_hit) as grupo2_hit,sum(a.grupo2_no_hit) as grupo2_no_hit,
			sum(a.grupo3_hit) as grupo3_hit,sum(a.grupo3_no_hit) as grupo3_no_hit,sum(grupo5_hit) as grupo5_hit,sum(grupo5_no_hit) as grupo5_no_hit,
			sum(a.grupo6_hit) as grupo6_hit,sum(a.grupo6_no_hit) as grupo6_no_hit, sum(a.grupoA_hit) as grupoA_hit,sum(a.grupoA_no_hit) as grupoA_no_hit,
            sum(grupo7_hit) as grupo7_hit,sum(grupo7_no_hit) as grupo7_no_hit, sum(a.grupo8_hit) as grupo8_hit, sum(a.grupo8_no_hit) as grupo8_no_hit, sum(grupo9_hit) as grupo9_hit, sum(grupo9_no_hit) as grupo9_no_hit,
			sum(a.cantidad_hit) as total_x_status_hit,sum(a.cantidad_no_hit) as total_x_status_no_hit,
			ROUND((sum(a.cantidad_hit) / case when total_sol_rep_hit = 0 then 1 else total_sol_rep_hit end) * 100,2) as porc_status_hit,
			ROUND((sum(a.cantidad_no_hit) / case when total_sol_rep_no_hit = 0 then 1 else total_sol_rep_no_hit end) * 100,2) as porc_status_no_hit,
			sum(a.cantidad) as total_x_status,ROUND((sum(a.cantidad) / case when total_sol_rep = 0 then 1 else total_sol_rep end) * 100,2) as porc_status,
			0 as tiene_causas,c.orden_reporte
			FROM total a, bdisolic:ss_status_sol b,bdisolic:ss_causas_sol c
			WHERE a.status_solicitud = b.status_solicitud AND a.status_solicitud = c.status_solicitud
			AND a.causa_solicitud = c.causa_solicitud AND b.activa_reporte = c.activa_reporte AND b.activa_reporte = "1"
			GROUP BY a.causa_solicitud,a.sub_causa_solicitud,c.descripcion,c.orden_reporte; 
		ELIF pTpConsulta = '01' AND pFiltro <> '' AND pEstatus <> '' AND psubcausa <> '' THEN ----ESTADO
			insert into total_sol_group
			SELECT trim(c.descripcion) ||' (CPS)' as descripcion,a.sub_causa_solicitud as causa_solicitud,sum(a.grupo1_hit) as grupo1_hit,sum(a.grupo1_no_hit) as grupo1_no_hit,sum(a.grupo2_hit) as grupo2_hit,sum(a.grupo2_no_hit) as grupo2_no_hit,
			sum(a.grupo3_hit) as grupo3_hit,sum(a.grupo3_no_hit) as grupo3_no_hit,sum(grupo5_hit) as grupo5_hit,sum(grupo5_no_hit) as grupo5_no_hit,
			sum(a.grupo6_hit) as grupo6_hit,sum(a.grupo6_no_hit) as grupo6_no_hit, sum(a.grupoA_hit) as grupoA_hit,sum(a.grupoA_no_hit) as grupoA_no_hit,
            sum(grupo7_hit) as grupo7_hit,sum(grupo7_no_hit) as grupo7_no_hit,sum(a.grupo8_hit) as grupo8_hit, sum(a.grupo8_no_hit) as grupo8_no_hit, sum(grupo9_hit) as grupo9_hit, sum(grupo9_no_hit) as grupo9_no_hit,
			sum(a.cantidad_hit) as total_x_status_hit,sum(a.cantidad_no_hit) as total_x_status_no_hit,
			ROUND((sum(a.cantidad_hit) / case when total_sol_rep_hit = 0 then 1 else total_sol_rep_hit end) * 100,2) as porc_status_hit,
			ROUND((sum(a.cantidad_no_hit) / case when total_sol_rep_no_hit = 0 then 1 else total_sol_rep_no_hit end) * 100,2) as porc_status_no_hit,
			sum(a.cantidad) as total_x_status,ROUND((sum(a.cantidad) / case when total_sol_rep = 0 then 1 else total_sol_rep end) * 100,2) as porc_status,
			0 as tiene_causas,c.orden_reporte
			FROM total a, bdisolic:ss_status_sol b,bdisolic:ss_causas_sol c
			WHERE a.status_solicitud = b.status_solicitud AND a.status_solicitud = c.status_solicitud AND a.causa_solicitud = c.causa_solicitud
			AND a.estado = pFiltro AND b.activa_reporte = c.activa_reporte AND b.activa_reporte = "1"
			GROUP BY a.causa_solicitud,a.sub_causa_solicitud,c.descripcion,c.orden_reporte;
		ELIF pTpConsulta = '02' AND pFiltro <> '' AND pEstatus <> '' AND psubcausa <> '' THEN ----CIUDAD
			insert into total_sol_group
			SELECT trim(c.descripcion) ||' (CPS)' as descripcion,a.sub_causa_solicitud as causa_solicitud,sum(a.grupo1_hit) as grupo1_hit,sum(a.grupo1_no_hit) as grupo1_no_hit,sum(a.grupo2_hit) as grupo2_hit,sum(a.grupo2_no_hit) as grupo2_no_hit,
			sum(a.grupo3_hit) as grupo3_hit,sum(a.grupo3_no_hit) as grupo3_no_hit,sum(grupo5_hit) as grupo5_hit,sum(grupo5_no_hit) as grupo5_no_hit,
			sum(a.grupo6_hit) as grupo6_hit,sum(a.grupo6_no_hit) as grupo6_no_hit, sum(a.grupoA_hit) as grupoA_hit,sum(a.grupoA_no_hit) as grupoA_no_hit,
            sum(grupo7_hit) as grupo7_hit,sum(grupo7_no_hit) as grupo7_no_hit,sum(a.grupo8_hit) as grupo8_hit, sum(a.grupo8_no_hit) as grupo8_no_hit, sum(grupo9_hit) as grupo9_hit, sum(grupo9_no_hit) as grupo9_no_hit,
			sum(a.cantidad_hit) as total_x_status_hit,sum(a.cantidad_no_hit) as total_x_status_no_hit,
			ROUND((sum(a.cantidad_hit) / case when total_sol_rep_hit = 0 then 1 else total_sol_rep_hit end) * 100,2) as porc_status_hit,
			ROUND((sum(a.cantidad_no_hit) / case when total_sol_rep_no_hit = 0 then 1 else total_sol_rep_no_hit end) * 100,2) as porc_status_no_hit,
			sum(a.cantidad) as total_x_status,ROUND((sum(a.cantidad) / case when total_sol_rep = 0 then 1 else total_sol_rep end) * 100,2) as porc_status,
			0 as tiene_causas,c.orden_reporte
			FROM total a, bdisolic:ss_status_sol b,bdisolic:ss_causas_sol c
			WHERE a.status_solicitud = b.status_solicitud AND a.status_solicitud = c.status_solicitud AND a.causa_solicitud = c.causa_solicitud
			AND a.estado = pretedocd AND a.ciudad = lpad(pFiltro,3,0) AND b.activa_reporte = c.activa_reporte AND b.activa_reporte = "1"
			GROUP BY a.causa_solicitud,a.sub_causa_solicitud,c.descripcion,c.orden_reporte;
		ELIF pTpConsulta = '04' AND pFiltro <> '' AND pEstatus <> '' AND psubcausa <> '' THEN ----SUCURSAL
			insert into total_sol_group
			SELECT trim(c.descripcion) ||' (CPS)' as descripcion,a.sub_causa_solicitud as causa_solicitud,sum(a.grupo1_hit) as grupo1_hit,sum(a.grupo1_no_hit) as grupo1_no_hit,sum(a.grupo2_hit) as grupo2_hit,sum(a.grupo2_no_hit) as grupo2_no_hit,
			sum(a.grupo3_hit) as grupo3_hit,sum(a.grupo3_no_hit) as grupo3_no_hit,sum(grupo5_hit) as grupo5_hit,sum(grupo5_no_hit) as grupo5_no_hit,
			sum(a.grupo6_hit) as grupo6_hit,sum(a.grupo6_no_hit) as grupo6_no_hit, sum(a.grupoA_hit) as grupoA_hit,sum(a.grupoA_no_hit) as grupoA_no_hit,
            sum(grupo7_hit) as grupo7_hit,sum(grupo7_no_hit) as grupo7_no_hit,sum(a.grupo8_hit) as grupo8_hit, sum(a.grupo8_no_hit) as grupo8_no_hit, sum(grupo9_hit) as grupo9_hit, sum(grupo9_no_hit) as grupo9_no_hit,
			sum(a.cantidad_hit) as total_x_status_hit,sum(a.cantidad_no_hit) as total_x_status_no_hit,
			ROUND((sum(a.cantidad_hit) / case when total_sol_rep_hit = 0 then 1 else total_sol_rep_hit end) * 100,2) as porc_status_hit,
			ROUND((sum(a.cantidad_no_hit) / case when total_sol_rep_no_hit = 0 then 1 else total_sol_rep_no_hit end) * 100,2) as porc_status_no_hit,
			sum(a.cantidad) as total_x_status,ROUND((sum(a.cantidad) / case when total_sol_rep = 0 then 1 else total_sol_rep end) * 100,2) as porc_status,
			0 as tiene_causas,c.orden_reporte
			FROM total a, bdisolic:ss_status_sol b,bdisolic:ss_causas_sol c
			WHERE a.status_solicitud = b.status_solicitud AND a.status_solicitud = c.status_solicitud AND a.causa_solicitud = c.causa_solicitud
			AND a.sucursal = pFiltro AND b.activa_reporte = c.activa_reporte AND b.activa_reporte = "1"
			GROUP BY a.causa_solicitud,a.sub_causa_solicitud,c.descripcion,c.orden_reporte; 
		ELIF pTpConsulta = '03' AND pFiltro <> '' AND pEstatus <> '' AND psubcausa <> '' THEN ----REGION
			insert into total_sol_group
			SELECT trim(c.descripcion) ||' (CPS)' as descripcion,a.sub_causa_solicitud as causa_solicitud,sum(a.grupo1_hit) as grupo1_hit,sum(a.grupo1_no_hit) as grupo1_no_hit,sum(a.grupo2_hit) as grupo2_hit,sum(a.grupo2_no_hit) as grupo2_no_hit,
			sum(a.grupo3_hit) as grupo3_hit,sum(a.grupo3_no_hit) as grupo3_no_hit,sum(grupo5_hit) as grupo5_hit,sum(grupo5_no_hit) as grupo5_no_hit,
			sum(a.grupo6_hit) as grupo6_hit,sum(a.grupo6_no_hit) as grupo6_no_hit, sum(a.grupoA_hit) as grupoA_hit,sum(a.grupoA_no_hit) as grupoA_no_hit,
            sum(grupo7_hit) as grupo7_hit,sum(grupo7_no_hit) as grupo7_no_hit,sum(a.grupo8_hit) as grupo8_hit, sum(a.grupo8_no_hit) as grupo8_no_hit, sum(grupo9_hit) as grupo9_hit, sum(grupo9_no_hit) as grupo9_no_hit,
			sum(a.cantidad_hit) as total_x_status_hit,sum(a.cantidad_no_hit) as total_x_status_no_hit,
			ROUND((sum(a.cantidad_hit) / case when total_sol_rep_hit = 0 then 1 else total_sol_rep_hit end) * 100,2) as porc_status_hit,
			ROUND((sum(a.cantidad_no_hit) / case when total_sol_rep_no_hit = 0 then 1 else total_sol_rep_no_hit end) * 100,2) as porc_status_no_hit,
			sum(a.cantidad) as total_x_status,ROUND((sum(a.cantidad) / case when total_sol_rep = 0 then 1 else total_sol_rep end) * 100,2) as porc_status,
			0 as tiene_causas,c.orden_reporte
			FROM total a, bdisolic:ss_status_sol b,bdisolic:ss_causas_sol c
			WHERE a.status_solicitud = b.status_solicitud AND a.status_solicitud = c.status_solicitud AND a.causa_solicitud = c.causa_solicitud
			AND a.numero_region = pFiltro AND b.activa_reporte = c.activa_reporte AND b.activa_reporte = "1"
			GROUP BY a.causa_solicitud,a.sub_causa_solicitud,c.descripcion,c.orden_reporte;
		END IF;
		--total_sol_group_aux
create temp table total_sol_group_aux
( descripcion char(100),status_solicitud  char(2),grupo1_hit integer,grupo1_no_hit integer,grupo2_hit integer,grupo2_no_hit integer,
grupo3_hit integer,grupo3_no_hit integer, grupo5_hit integer,grupo5_no_hit integer,grupo6_hit integer,grupo6_no_hit integer,  
grupoA_hit integer,grupoA_no_hit integer,grupo7_hit integer,grupo7_no_hit integer,grupo8_hit integer,grupo8_no_hit integer,grupo9_hit integer,grupo9_no_hit integer,
total_x_status_hit integer,total_x_status_no_hit integer,porc_status_hit decimal (14,2),porc_status_no_hit decimal (14,2),
total_x_status	integer,porc_status decimal (14,2),causas integer,orden_reporte	smallint) with no log;		
---------FIN EVALUACIONES DE LA CLASIFICACION DE LA CAUSA CPS
		insert into total_sol_group_aux
		SELECT 'Total Solicitudes' descripcion,'' status_solicitud, sum(grupo1_hit) grupo1_hit, sum(grupo1_no_hit ) grupo1_no_hit, sum(grupo2_hit) grupo2_hit, sum(grupo2_no_hit) grupo2_no_hit, sum(grupo3_hit) grupo3_hit, sum(grupo3_no_hit) grupo3_no_hit, sum(grupo5_hit) grupo5_hit, sum(grupo5_no_hit) grupo5_no_hit,
			sum(grupo6_hit) as grupo6_hit, sum(grupo6_no_hit) as grupo6_no_hit, sum(grupoA_hit) as grupoA_hit,sum(grupoA_no_hit) as grupoA_no_hit, 
            sum(grupo7_hit) grupo7_hit, sum(grupo7_no_hit) grupo7_no_hit,sum(grupo8_hit) as grupo8_hit, sum(grupo8_no_hit) as grupo8_no_hit,
			sum(grupo9_hit) as grupo9_hit,sum(grupo9_no_hit) as grupo9_no_hit,
			sum(grupo1_hit+grupo2_hit+grupo3_hit+grupo5_hit+grupo6_hit+grupoa_hit+grupo7_hit+grupo8_hit+grupo9_hit) total_x_status_hit,
			sum(grupo1_no_hit+grupo2_no_hit+grupo3_no_hit+grupo5_no_hit+grupo6_no_hit+grupoA_no_hit+grupo7_no_hit+grupo8_no_hit+grupo9_no_hit) total_x_status_no_hit, sum(porc_status_hit) porc_status_hit,sum(porc_status_no_hit) porc_status_no_hit,
			sum(grupo1_hit+grupo1_no_hit+grupo2_hit+grupo2_no_hit+grupo3_hit+grupo3_no_hit+grupo5_hit+grupo5_no_hit+grupo6_hit+grupo6_no_hit+grupoA_hit+grupoA_no_hit+grupo7_hit+grupo7_no_hit+grupo8_hit+grupo8_no_hit+grupo9_hit+grupo9_no_hit) total_x_status, 
            sum(porc_status) porc_status,0 causas, 997 orden_rerpote
    FROM total_sol_group;
		select sum(total_x_status) INTO ptotal_x_status from total_sol_group_aux;
		select sum(total_x_status_hit) INTO ptotal_x_status_hit from total_sol_group_aux;
		select sum(total_x_status_no_hit) INTO ptotal_x_status_no_hit from total_sol_group_aux;

		IF ptotal_x_status = 0 THEN LET ptotal_x_status = 1;
		ELIF ptotal_x_status_hit = 0 THEN LET ptotal_x_status_hit = 1;
		ELIF ptotal_x_status_no_hit = 0 THEN LET ptotal_x_status_no_hit = 1;
		END IF;

		INSERT INTO total_sol_group_aux
		SELECT '% de Solicitudes' descripcion,'' status_solicitud,
		round(sum(grupo1_hit)/(ptotal_x_status),2) * 100,round(sum(grupo1_no_hit)/(ptotal_x_status),2) * 100,round(sum(grupo2_hit)/(ptotal_x_status),2) * 100,round(sum(grupo2_no_hit)/(ptotal_x_status),2) * 100,
		round(sum(grupo3_hit)/(ptotal_x_status),2) * 100,round(sum(grupo3_no_hit)/(ptotal_x_status),2) * 100,round(sum(grupo5_hit)/(ptotal_x_status),2) * 100,round(sum(grupo5_no_hit)/(ptotal_x_status),2) * 100,
        round(sum(grupo6_hit)/(ptotal_x_status),2) * 100,round(sum(grupo6_no_hit)/(ptotal_x_status),2) * 100,round(sum(grupoA_hit)/(ptotal_x_status),2) * 100,round(sum(grupoA_no_hit)/(ptotal_x_status),2) * 100,
        round(sum(grupo7_hit)/(ptotal_x_status),2) * 100,round(sum(grupo7_no_hit)/(ptotal_x_status),2) * 100,round(sum(grupo8_hit)/(ptotal_x_status),2) * 100,round(sum(grupo8_no_hit)/(ptotal_x_status),2) * 100,round(sum(grupo9_hit)/(ptotal_x_status),2) * 100,round(sum(grupo9_no_hit)/(ptotal_x_status),2) * 100, --cada uno de los status
		round(sum(grupo1_hit)/(ptotal_x_status_hit),2) * 100+round(sum(grupo2_hit)/(ptotal_x_status_hit),2) * 100+round(sum(grupo3_hit)/(ptotal_x_status_hit),2) * 100+
        round(sum(grupo5_hit)/(ptotal_x_status_hit),2) * 100+round(sum(grupo6_hit)/(ptotal_x_status_hit),2) * 100+round(sum(grupoA_hit)/(ptotal_x_status_hit),2) * 100+
        round(sum(grupo7_hit)/(ptotal_x_status_hit),2) * 100+round(sum(grupo8_hit)/(ptotal_x_status_hit),2) * 100+round(sum(grupo9_hit)/(ptotal_x_status_hit),2) * 100, --total x status_hit
		round(sum(grupo1_no_hit)/(ptotal_x_status_no_hit),2) * 100+round(sum(grupo2_no_hit)/(ptotal_x_status_no_hit),2) * 100+round(sum(grupo3_no_hit)/(ptotal_x_status_no_hit),2) * 100+
        round(sum(grupo5_no_hit)/(ptotal_x_status_no_hit),2) * 100+round(sum(grupo6_no_hit)/(ptotal_x_status_no_hit),2) * 100+round(sum(grupoA_no_hit)/(ptotal_x_status_no_hit),2) * 100+
        round(sum(grupo7_no_hit)/(ptotal_x_status_no_hit),2) * 100+round(sum(grupo8_no_hit)/(ptotal_x_status_no_hit),2) * 100+round(sum(grupo9_no_hit)/(ptotal_x_status_no_hit),2) * 100, --total x status_no_hit
		round(sum(grupo1_hit)/(ptotal_x_status_hit),2) * 100+round(sum(grupo2_hit)/(ptotal_x_status_hit),2) * 100+round(sum(grupo3_hit)/(ptotal_x_status_hit),2) * 100+
        round(sum(grupo5_hit)/(ptotal_x_status_hit),2) * 100+round(sum(grupo6_hit)/(ptotal_x_status_hit),2) * 100+round(sum(grupoA_hit)/(ptotal_x_status_hit),2) * 100+
        round(sum(grupo7_hit)/(ptotal_x_status_hit),2) * 100+round(sum(grupo8_hit)/(ptotal_x_status_hit),2) * 100+round(sum(grupo9_hit)/(ptotal_x_status_hit),2) * 100, --porc de total x status_hit
		round(sum(grupo1_no_hit)/(ptotal_x_status_no_hit),2) * 100+round(sum(grupo2_no_hit)/(ptotal_x_status_no_hit),2) * 100+round(sum(grupo3_no_hit)/(ptotal_x_status_no_hit),2) * 100+
        round(sum(grupo5_no_hit)/(ptotal_x_status_no_hit),2) * 100+round(sum(grupo6_no_hit)/(ptotal_x_status_no_hit),2) * 100+round(sum(grupoA_no_hit)/(ptotal_x_status_no_hit),2) * 100+
        round(sum(grupo7_no_hit)/(ptotal_x_status_no_hit),2) * 100+round(sum(grupo8_no_hit)/(ptotal_x_status_no_hit),2) * 100+round(sum(grupo9_no_hit)/(ptotal_x_status_no_hit),2) * 100, --porc de total x status_hit
		round(sum(grupo1_hit)/(ptotal_x_status),2) * 100+round(sum(grupo1_no_hit)/(ptotal_x_status),2) * 100+round(sum(grupo2_hit)/(ptotal_x_status),2) * 100+round(sum(grupo2_no_hit)/(ptotal_x_status),2) * 100+
		round(sum(grupo3_hit)/(ptotal_x_status),2) * 100+round(sum(grupo3_no_hit)/(ptotal_x_status),2) * 100+round(sum(grupo5_hit)/(ptotal_x_status),2) * 100+round(sum(grupo5_no_hit)/(ptotal_x_status),2) * 100+
        round(sum(grupo6_hit)/(ptotal_x_status),2) * 100+round(sum(grupo6_no_hit)/(ptotal_x_status),2) * 100+round(sum(grupoA_hit)/(ptotal_x_status),2) * 100+round(sum(grupoA_no_hit)/(ptotal_x_status),2) * 100+
        round(sum(grupo7_hit)/(ptotal_x_status),2) * 100+round(sum(grupo7_no_hit)/(ptotal_x_status),2) * 100+round(sum(grupo8_hit)/(ptotal_x_status),2) * 100+round(sum(grupo8_no_hit)/(ptotal_x_status),2) * 100+round(sum(grupo9_hit)/(ptotal_x_status),2) * 100+round(sum(grupo9_no_hit)/(ptotal_x_status),2) * 100, ---total x status
		round(sum(grupo1_hit)/(ptotal_x_status),2) * 100+round(sum(grupo1_no_hit)/(ptotal_x_status),2) * 100+round(sum(grupo2_hit)/(ptotal_x_status),2) * 100+round(sum(grupo2_no_hit)/(ptotal_x_status),2) * 100+
		round(sum(grupo3_hit)/(ptotal_x_status),2) * 100+round(sum(grupo3_no_hit)/(ptotal_x_status),2) * 100+round(sum(grupo5_hit)/(ptotal_x_status),2) * 100+round(sum(grupo5_no_hit)/(ptotal_x_status),2) * 100+
        round(sum(grupo6_hit)/(ptotal_x_status),2) * 100+round(sum(grupo6_no_hit)/(ptotal_x_status),2) * 100+round(sum(grupoA_hit)/(ptotal_x_status),2) * 100+round(sum(grupoA_no_hit)/(ptotal_x_status),2) * 100+
        round(sum(grupo7_hit)/(ptotal_x_status),2) * 100+round(sum(grupo7_no_hit)/(ptotal_x_status),2) * 100+round(sum(grupo8_hit)/(ptotal_x_status),2) * 100+round(sum(grupo8_no_hit)/(ptotal_x_status),2) * 100+round(sum(grupo9_hit)/(ptotal_x_status),2) * 100+round(sum(grupo9_no_hit)/(ptotal_x_status),2) * 100, 0,998 ----porc de total x status
		FROM total_sol_group_aux; 

		INSERT INTO total_sol_group 
		SELECT * FROM total_sol_group_aux;

		SELECT COUNT(*) INTO num_registros FROM total_sol_group;
		IF num_registros > 2 THEN
			IF pEstatus <> '' THEN
			FOREACH WITH HOLD
				SELECT descripcion,status_solicitud,grupo1_hit,grupo1_no_hit,grupo2_hit,grupo2_no_hit,grupo3_hit,grupo3_no_hit,grupo5_hit,grupo5_no_hit,grupo6_hit,grupo6_no_hit,grupoA_hit,grupoA_no_hit,grupo7_hit,grupo7_no_hit,grupo8_hit,grupo8_no_hit,grupo9_hit,grupo9_no_hit, total_x_status_hit,total_x_status_no_hit,porc_status_hit,porc_status_no_hit,total_x_status,porc_status, case when tiene_causas > 0 then 1 else tiene_causas end
				INTO cDescripcion,cStatusSol, dgrupo1_hit, dgrupo1_no_hit, dgrupo2_hit, dgrupo2_no_hit, dgrupo3_hit, dgrupo3_no_hit,dgrupo5_hit,dgrupo5_no_hit,dgrupo6_hit,dgrupo6_no_hit,dgrupoA_hit,dgrupoA_no_hit,dgrupo7_hit,dgrupo7_no_hit,dgrupo8_hit,dgrupo8_no_hit,dgrupo9_hit,dgrupo9_no_hit,dtotal_status_hit,dtotal_status_no_hit,dporc_status_hit,dporc_status_no_hit,dTotalStatus,dTotalGenStatus, cBanCausa
				FROM total_sol_group ORDER BY orden_reporte
			RETURN cCodRet, cMensajeRet, cDescripcion, cStatusSol,dgrupo1_hit,dgrupo1_no_hit, dgrupo2_hit,dgrupo2_no_hit, dgrupo3_hit,dgrupo3_no_hit, dgrupo5_hit, dgrupo5_no_hit,dgrupo6_hit,dgrupo6_no_hit,dgrupoA_hit,dgrupoA_no_hit,dgrupo7_hit, dgrupo7_no_hit,dgrupo8_hit, dgrupo8_no_hit,dgrupo9_hit,dgrupo9_no_hit,dtotal_status_hit,dtotal_status_no_hit, dporc_status_hit,dporc_status_no_hit,dTotalStatus, dTotalGenStatus, cBanCausa WITH RESUME;
			END FOREACH;
			ELSE
			FOREACH WITH HOLD
				SELECT descripcion,status_solicitud,grupo1_hit,grupo1_no_hit,grupo2_hit,grupo2_no_hit,grupo3_hit,grupo3_no_hit,grupo5_hit,grupo5_no_hit,grupo6_hit,grupo6_no_hit,grupoA_hit,grupoA_no_hit,grupo7_hit,grupo7_no_hit,grupo8_hit,grupo8_no_hit,grupo9_hit,grupo9_no_hit,total_x_status_hit,total_x_status_no_hit,porc_status_hit,porc_status_no_hit,total_x_status,porc_status, case when tiene_causas > 0 then 1 else tiene_causas end
				INTO cDescripcion, cStatusSol, dgrupo1_hit, dgrupo1_no_hit, dgrupo2_hit, dgrupo2_no_hit, dgrupo3_hit, dgrupo3_no_hit,dGrupo5_hit, dGrupo5_no_hit,dgrupo6_hit,dgrupo6_no_hit,dgrupoA_hit,dgrupoA_no_hit,dgrupo7_hit,dgrupo7_no_hit,dgrupo8_hit,dgrupo8_no_hit,dgrupo9_hit,dgrupo9_no_hit, dtotal_status_hit,dtotal_status_no_hit,dporc_status_hit,dporc_status_no_hit,dTotalStatus, dTotalGenStatus, cBanCausa
				FROM total_sol_group ORDER BY orden_reporte
				RETURN cCodRet, cMensajeRet, cDescripcion, cStatusSol, dgrupo1_hit, dgrupo1_no_hit, dgrupo2_hit, dgrupo2_no_hit, dgrupo3_hit, dgrupo3_no_hit, dGrupo5_hit, dGrupo5_no_hit,dgrupo6_hit,dgrupo6_no_hit,dgrupoA_hit,dgrupoA_no_hit,dgrupo7_hit, dgrupo7_no_hit,dgrupo8_hit,dgrupo8_no_hit,dgrupo9_hit,dgrupo9_no_hit,dtotal_status_hit,dtotal_status_no_hit,dporc_status_hit,dporc_status_no_hit,dTotalStatus, dTotalGenStatus, cBanCausa WITH RESUME;
			END FOREACH;
			END IF;
		ELSE
			LET cCodRet = '000006'; LET cMensajeRet = 'No hay informacion para este producto en este periodo';
			RETURN cCodRet, cMensajeRet, cDescripcion, cStatusSol, dgrupo1_hit, dgrupo1_no_hit, dgrupo2_hit, dgrupo2_no_hit,dgrupo3_hit, dgrupo3_no_hit, dGrupo5_hit, dGrupo5_no_hit,dgrupo6_hit,dgrupo6_no_hit,dgrupoA_hit,dgrupoA_no_hit,dgrupo7_hit,dgrupo7_no_hit,dgrupo8_hit,dgrupo8_no_hit,dgrupo9_hit,dgrupo9_no_hit,dtotal_status_hit,dtotal_status_no_hit,dporc_status_hit,dporc_status_no_hit,dTotalStatus, dTotalGenStatus, cBanCausa WITH RESUME;
		END IF
		DROP TABLE Tsolicitud; DROP TABLE sol2; DROP TABLE total; DROP TABLE total_sol_group; DROP TABLE total_sol_group_aux;
        
		IF psubcausa <> '' THEN DROP TABLE sol3; DROP TABLE sol4; END IF;
		
		IF pTpConsulta = '04' THEN DROP TABLE total_sucursal; 
		ELIF pTpConsulta = '01' THEN DROP TABLE total_estado; 
		ELIF pTpConsulta = '02' THEN DROP TABLE total_ciudad; 
		ELIF pTpConsulta = '03' THEN DROP TABLE total_region; 
		END IF;
		
		
END
END PROCEDURE
DOCUMENT
'Autor: Viridiana Osobampo',
'Fecha: 12-05-2010',
'Modifico: Marco Valenzuela',
'Fecha: 2014-10-17',
'Descripcion: Se integra grupo 8.';

CREATE PROCEDURE "informix".sp_obtiene_pbehavior()
       RETURNING char(6);

--declaracion de variables
----------------------------------------------------------------------------------------------
DEFINE sql_err 			            INTEGER;
DEFINE isam_err 		            INTEGER;
DEFINE error_info		            CHAR(150);
DEFINE cMensaje 		            CHAR(2);
DEFINE cCod_ret                     CHAR(6);
DEFINE vrowid                       INTEGER;
DEFINE v_numcuentaq                 CHAR(20);
DEFINE v_sresultado					CHAR(50);
DEFINE v_spuntaje					DECIMAL(18,4);
DEFINE v_finmes					     DATE;
--puntajes de las variables
DEFINE v_spuntaje_edad				DECIMAL(18,4);
DEFINE v_spuntaje_sexo				DECIMAL(18,4);
DEFINE v_spuntaje_sdo_corriente		DECIMAL(18,4);
DEFINE v_spuntaje_mnl				DECIMAL(18,4);
DEFINE v_spuntaje_pbl				DECIMAL(18,4);
DEFINE v_spuntaje_snl				DECIMAL(18,4);
DEFINE v_spuntaje_mdl				DECIMAL(18,4);
DEFINE v_spuntaje_ldl				DECIMAL(18,4);
DEFINE v_spuntaje_psp				DECIMAL(18,4);
DEFINE v_spuntaje_cma				DECIMAL(18,4);
DEFINE v_spuntaje_cms				DECIMAL(18,4);
DEFINE v_spuntaje_cmt				DECIMAL(18,4);
DEFINE v_spuntaje_cmn				DECIMAL(18,4);
DEFINE v_spuntaje_ppl				DECIMAL(18,4);
DEFINE v_spuntaje_adp				DECIMAL(18,4);
DEFINE v_spuntaje_adc				DECIMAL(18,4);
DEFINE v_spuntaje_adn				DECIMAL(18,4);
DEFINE v_spuntaje_bc_score			DECIMAL(18,4);		
DEFINE v_spuntaje_adl				DECIMAL(18,4);
DEFINE v_spuntaje_adv4				DECIMAL(18,4);
DEFINE v_spuntajev					DECIMAL(18,4); --variable para llevarme el valor
DEFINE v_sbanderahit				CHAR(1);
DEFINE v_edad				integer;
DEFINE v_sexo				char(1);
DEFINE v_sdocorriente		DECIMAL(18,2);
DEFINE v_mnl				DECIMAL(18,2);
DEFINE v_pbl				DECIMAL(18,2);
DEFINE v_ldl				INTEGER;
DEFINE v_psp				DECIMAL(18,2);
DEFINE v_cma				INTEGER;
DEFINE v_snl				integer;
DEFINE v_mdl				integer;
DEFINE v_cms				integer;
DEFINE v_cmt				integer;
DEFINE v_cmn				integer;
DEFINE v_ppl				integer;
DEFINE v_adp				DECIMAL(18,4);
DEFINE v_adc				DECIMAL(18,4);
DEFINE v_adn				DECIMAL(18,4);
DEFINE v_bc_score			DECIMAL(18,4);
DEFINE v_adl				DECIMAL(18,2);
DEFINE v_adv4				DECIMAL(18,4);
DEFINE i integer;
DEFINE v_cont integer;

    --SET DEBUG FILE TO "/informix/janeth/nva_version/sp_obtiene_pbehavior.out";
   --TRACE ON; 

      LET cCod_ret      = '000000';
	  LET sql_err       = 0;
	  LET isam_err      = 0;
	  LET error_info    = '';
	  LET cMensaje      = 'PROCESO EXITOSO';
	  LET v_numcuentaq      	= '';
	  LET v_sresultado 			= '';
	  LET v_spuntaje 			= 0;
	  LET v_finmes				= DATE(1);
	  --puntajes de las variables
	  LET v_spuntaje_edad				= 0;
	  LET v_spuntaje_sexo				= 0;
	  LET v_spuntaje_sdo_corriente		= 0;
	  LET v_spuntaje_mnl				= 0;
	  LET v_spuntaje_pbl				= 0;
	  LET v_spuntaje_snl				= 0;
	  LET v_spuntaje_mdl				= 0;
	  LET v_spuntaje_ldl				= 0;
	  LET v_spuntaje_psp				= 0;
	  LET v_spuntaje_cma				= 0;
	  LET v_spuntaje_cms				= 0;
	  LET v_spuntaje_cmt				= 0;
	  LET v_spuntaje_cmn				= 0;
	  LET v_spuntaje_ppl				= 0;
	  LET v_spuntaje_adp				= 0;
	  LET v_spuntaje_adc				= 0;
	  LET v_spuntaje_adn				= 0;
	  LET v_spuntaje_bc_score			= 0;		
	  LET v_spuntaje_adl				= 0;
	  LET v_spuntaje_adv4				= 0;
	  LET v_spuntajev  			= 0; --variable para llevarme el puntaje
	  LET v_sbanderahit 		= '';
	  LET v_edad				= 0;
	  LET v_sexo				='';
	  LET v_sdocorriente		= 0;
	  LET v_mnl					= 0;
	  LET v_pbl					= 0;
	  LET v_snl					= 0;
	  LET v_mdl					= 0;
	  LET v_ldl					= 0;
	  LET v_psp					= 0;
	  LET v_cma					= 0;
	  LET v_cms					= 0;
	  LET v_cmt					= 0;
	  LET v_cmn					= 0;
	  LET v_ppl					= 0;
	  LET v_adp					= 0;
	  LET v_adc					= 0;
	  LET v_adn					= 0;
	  LET v_bc_score			= 0;
	  LET v_adl					= 0;
	  LET v_adv4				= 0;
	  
	  BEGIN

ON EXCEPTION SET sql_err, isam_err, error_info
	LET cCod_ret = sql_err;
	LET cMensaje = error_info;
	RETURN cCod_ret;
END EXCEPTION;

   
SET ISOLATION TO dirty READ;
SET LOCK MODE TO wait 3;
--obtengo las fechas
	select date(pri_dia_mes)-1
	INTO v_finmes
     FROM "informix".sd_fechas 
	WHERE	empresa = '001';

	truncate table sd_behavior_puntaje drop storage;
            
FOREACH WITH HOLD

	SELECT num_credito 
      INTO v_numcuentaq
      FROM bdicred:sd_maecredcont
     WHERE empresa = '001'
	   AND num_producto = '6001'
	   AND fecha = v_finmes
	   --and num_credito in ('600003594568','600000005089','600000005527','600000006988','600000008935','600000016698')
	   
	--Obtener la edad
	select sbanderahit,edad,sexo,saldo_corriente,round(mnl/12,2),pbl,snl,mdl,ldl,
	case when compraspsp <= 0 then 0 else round((monto_ATM / compraspsp)*100,2) end psp,
	cma,cms,cmt,cmn,trunc((ppl/6)*100),adp,adc,adn,bc_score,adl,adv4
	into v_sbanderahit,v_edad,v_sexo,v_sdocorriente,v_mnl,v_pbl,v_snl,v_mdl,v_ldl,v_psp,v_cma,v_cms,v_cmt,v_cmn,v_ppl,v_adp,v_adc,v_adn,v_bc_score,v_adl,v_adv4
	from bdicred:sd_varbehavior
	where num_credito = v_numcuentaq;
	
	-- Puntajes a variables
		--Créditos que son Clean Thick Hit
		if v_sbanderahit = 'S' then
			--variable edad
			if v_edad <= 20 then
					let v_spuntaje_edad = -0.5041;
			elif  v_edad >= 21 and v_edad <= 25 then
					let v_spuntaje_edad = -0.5041;
			elif  v_edad >= 26 and v_edad <= 30 then
					let v_spuntaje_edad = -0.5041;
			elif  v_edad >= 31 and v_edad <= 35 then
					let v_spuntaje_edad = 0;
			elif  v_edad >= 36 and v_edad <= 40 then
					let v_spuntaje_edad = 0;
			elif  v_edad >= 41 and v_edad <= 45 then
					let v_spuntaje_edad = 0;
			elif  v_edad >= 46 and v_edad <= 50 then
					let v_spuntaje_edad = 0;
			elif  v_edad >= 51 and v_edad <= 55 then
					let v_spuntaje_edad = 0;
			elif  v_edad >= 56 and v_edad <= 60 then
					let v_spuntaje_edad = 0;
			elif  v_edad >= 61 and v_edad <= 65 then
					let v_spuntaje_edad = 0;
			elif  v_edad >= 66 and v_edad <= 70 then
					let v_spuntaje_edad = 0;
			elif  v_edad >= 71 and v_edad <= 75 then
					let v_spuntaje_edad = 0;
			elif  v_edad >= 76 and v_edad <= 80 then
					let v_spuntaje_edad = 0;
			elif  v_edad >= 81 then
					let v_spuntaje_edad = 0;
			end if;
			--variable sexo
			if v_sexo = 'M' then
				let v_spuntaje_sexo = -0.1551;
			elif v_sexo = 'F' then 
				let v_spuntaje_sexo = 0;
			end if;
			--variable sdo corriente
			if v_sdocorriente <= 0 then
				let v_spuntaje_sdo_corriente = 0;
			elif v_sdocorriente >= 0.1 and v_sdocorriente <= 500.99 then 
				let v_spuntaje_sdo_corriente = 0;
			elif v_sdocorriente >= 500.1 and v_sdocorriente <= 1000.99 then 
				let v_spuntaje_sdo_corriente = 0;
			elif v_sdocorriente >= 1000.1 and v_sdocorriente <= 2000.99 then 
				let v_spuntaje_sdo_corriente = 0;
			elif v_sdocorriente >= 2000.1 and v_sdocorriente <= 3000.99 then 
				let v_spuntaje_sdo_corriente = 0;
			elif v_sdocorriente >= 3000.1 and v_sdocorriente <= 4000.99 then 
				let v_spuntaje_sdo_corriente = -0.8928;
			elif v_sdocorriente >= 4000.1 and v_sdocorriente <= 5000.99 then 
				let v_spuntaje_sdo_corriente = -0.8928;
			elif v_sdocorriente >= 5000.1 and v_sdocorriente <= 6000.99 then 
				let v_spuntaje_sdo_corriente = -0.8928;
			elif v_sdocorriente >= 6000.1 and v_sdocorriente <= 7000.99 then 
				let v_spuntaje_sdo_corriente = -0.8928;
			elif v_sdocorriente >= 7000.1 and v_sdocorriente <= 8000.99 then 
				let v_spuntaje_sdo_corriente = -0.8928;
			elif v_sdocorriente >= 8000.1 and v_sdocorriente <= 9000.99 then 
				let v_spuntaje_sdo_corriente = -0.8928;
			elif v_sdocorriente > 9000 then 
				let v_spuntaje_sdo_corriente = -0.8928;
			end if;
			--variable mnl
			if v_mnl <= 0 then
				let v_spuntaje_mnl = 0;
			elif v_mnl >= 0.01 and v_mnl <= 0.08 then
				let v_spuntaje_mnl = 0;
			elif v_mnl >= 0.09 and v_mnl <= 0.17 then
				let v_spuntaje_mnl = 0;
			elif v_mnl >= 0.18 and v_mnl <= 0.25 then
				let v_spuntaje_mnl = 0;
			elif v_mnl >= 0.26 and v_mnl <= 0.33 then
				let v_spuntaje_mnl = 0;
			elif v_mnl >= 0.34 and v_mnl <= 0.50 then
				let v_spuntaje_mnl = 0;
			elif v_mnl >= 0.51 and v_mnl <= 0.83 then
				let v_spuntaje_mnl = -0.3244;
			elif v_mnl >= 0.84 and v_mnl <= 1.08 then
				let v_spuntaje_mnl = -0.3244;
			elif v_mnl >= 1.09 and v_mnl <= 998 then
				let v_spuntaje_mnl = -0.3244;
			end if;
			--variable pbl
			if v_pbl <= 0 then
				let v_spuntaje_pbl = 0;
			elif v_pbl >= 0.01 and v_pbl <= 30 then
				let v_spuntaje_pbl = 0;
			elif v_pbl >= 31 and v_pbl <= 55 then
				let v_spuntaje_pbl = 0;
			elif v_pbl >= 56 and v_pbl <= 75 then
				let v_spuntaje_pbl = 0;
			elif v_pbl >= 76 and v_pbl <= 85 then
				let v_spuntaje_pbl = -0.3538;
			elif v_pbl >= 86 and v_pbl <= 90 then
				let v_spuntaje_pbl = -0.3538;
			elif v_pbl >= 91 and v_pbl <= 95 then
				let v_spuntaje_pbl = -0.3538;
			elif v_pbl >= 96 and v_pbl <= 100 then
				let v_spuntaje_pbl = -0.3538;
			elif v_pbl >= 101 and v_pbl <= 105 then
				let v_spuntaje_pbl = -0.3538;
			elif v_pbl >= 106 and v_pbl <= 9999999999 then
				let v_spuntaje_pbl = -0.3538;
			elif v_pbl is null then
				let v_spuntaje_pbl = 0;
			end if;
			--variable SNL
			if v_snl <= 1 then
				let v_spuntaje_snl = 0;
			elif v_snl >= 2 and v_snl <= 12 then
				let v_spuntaje_snl = -0.1503;
			end if;
			--variable mdl
			if v_mdl = 0 then
				let v_spuntaje_mdl = 0;
			elif v_mdl = 1 then
				let v_spuntaje_mdl = -0.4655;
			elif v_mdl >= 2 and v_mdl <= 98 then
				let v_spuntaje_mdl = -0.4655;
			end if;
			--variable ldl
			if v_ldl <= 0 then
				let v_spuntaje_ldl = 0;
			elif v_ldl = 1 then
				let v_spuntaje_ldl = 0;
			elif v_ldl >= 1 then
				let v_spuntaje_ldl = 0;
			end if;
			--variable psp
			if v_psp <= 0 then
				let v_spuntaje_psp = 0;
			elif v_psp >= 0.0001 and v_psp <= 25 then
				let v_spuntaje_psp = 0;
			elif v_psp >= 25.01 and v_psp <= 115 then
				let v_spuntaje_psp = 0;
			elif v_psp >= 115.01 and v_psp <= 845 then
				let v_spuntaje_psp = 0;
			elif v_psp >= 845.01 and v_psp <= 9999999999 then
				let v_spuntaje_psp = 0;
			elif v_psp is null then
				let v_spuntaje_psp = 0;
			end if;
			--variable cma
			if v_cma = 0 then
				let v_spuntaje_cma = 0;
			elif v_cma = 1 then
				let v_spuntaje_cma = 0;
			elif v_cma = 2 then
				let v_spuntaje_cma = 0;
			elif v_cma = 3 then
				let v_spuntaje_cma = 0;
			elif v_cma = 4 then
				let v_spuntaje_cma = 0;
			elif v_cma = 5 then
				let v_spuntaje_cma = 0;
			elif v_cma = 6 then
				let v_spuntaje_cma = 0;
			elif v_cma = 7 then
				let v_spuntaje_cma = 0;
			elif v_cma = 8 then
				let v_spuntaje_cma = 0;
			elif v_cma = 9 then
				let v_spuntaje_cma = 0;
			elif v_cma = 10 then
				let v_spuntaje_cma = 0;
			elif v_cma = 11 then
				let v_spuntaje_cma = 0;
			elif v_cma = 12 then
				let v_spuntaje_cma = 0;
			end if;
			--variable cms
			if v_cms = 0 then
				let v_spuntaje_cms = 0;
			elif v_cms = 1 then
				let v_spuntaje_cms = 0;
			elif v_cms = 2 then
				let v_spuntaje_cms = 0;
			elif v_cms = 3 then
				let v_spuntaje_cms = 0;
			elif v_cms = 4 then
				let v_spuntaje_cms = 0;
			elif v_cms = 5 then
				let v_spuntaje_cms = 0;
			elif v_cms = 6 then
				let v_spuntaje_cms = 0;
			end if;
			--variable cmt
			if v_cmt = 0 then
				let v_spuntaje_cmt = 0;
			elif v_cmt = 1 then
				let v_spuntaje_cmt = 0;
			elif v_cmt = 2 then
				let v_spuntaje_cmt = 0;
			elif v_cmt = 3 then
				let v_spuntaje_cmt = 0;
			end if;
			--variable cmn
			if v_cmn = 0 then
				let v_spuntaje_cmn = 0;
			elif v_cmn = 1 then
				let v_spuntaje_cmn = 0;
			elif v_cmn = 2 then
				let v_spuntaje_cmn = 0;
			elif v_cmn = 3 then
				let v_spuntaje_cmn = 0;
			elif v_cmn = 4 then
				let v_spuntaje_cmn = 0;
			elif v_cmn = 5 then
				let v_spuntaje_cmn = 0;
			elif v_cmn = 6 then
				let v_spuntaje_cmn = 0;
			elif v_cmn = 7 then
				let v_spuntaje_cmn = 0;
			elif v_cmn >= 8 and v_cmn <= 12 then
				let v_spuntaje_cmn = 0;
			end if;
			--variable ppl
			if v_ppl <= 20 then
				let v_spuntaje_ppl = 0;
			elif v_ppl > 20 and v_ppl <= 35 then
				let v_spuntaje_ppl = 0;
			elif v_ppl > 35 and v_ppl <= 50 then
				let v_spuntaje_ppl = 0;
			elif v_ppl > 50 and v_ppl <= 70 then
				let v_spuntaje_ppl = 0;
			elif v_ppl > 70 and v_ppl <= 85 then
				let v_spuntaje_ppl = 0;
			elif v_ppl > 85 and v_ppl <= 100 then
				let v_spuntaje_ppl = 0;
			end if;
			--variable ADP
			if v_adp < 0 then
				let v_spuntaje_adp = 0;
			elif v_adp >= 0 and v_adp <= 10.9999 then
				let v_spuntaje_adp = 0;
			elif v_adp >= 11 and v_adp <= 35.9999 then
				let v_spuntaje_adp = 0;
			elif v_adp >= 36 and v_adp <= 55.9999 then
				let v_spuntaje_adp = 0;
			elif v_adp >= 56 and v_adp <= 70.9999 then
				let v_spuntaje_adp = 0;
			elif v_adp >= 71 and v_adp <= 80.9999 then
				let v_spuntaje_adp = 0;
			elif v_adp >= 81 and v_adp <= 90.9999 then
				let v_spuntaje_adp = 0;
			elif v_adp > 90 then
				let v_spuntaje_adp = 0;
			elif v_adp = 9999999999 then
				let v_spuntaje_adp = 0;
			end if;
			--variable adc
			if v_adc <= 1 then
				let v_spuntaje_adc = 0;
			elif v_adc = 2 then
				let v_spuntaje_adc = 0;
			elif v_adc = 3 then
				let v_spuntaje_adc = 0;
			elif v_adc = 4 then
				let v_spuntaje_adc = 0;
			elif v_adc > 4 and v_adc <= 6 then 
				let v_spuntaje_adc = 0;
			elif v_adc > 6 and v_adc <= 9 then 
				let v_spuntaje_adc = -0.2097;
			elif v_adc > 9 and v_adc <= 998 then 
				let v_spuntaje_adc = -0.2097;
			elif v_adc = 999 then
				let v_spuntaje_adc = 0;
			end if;
			--variable adn
			if v_adn <= 0 then
				--let v_scve_variable=17;
				--let v_ssubcve_variable=1;
				let v_spuntaje_adn = 0;
			elif v_adn >= 1 and v_adn <= 15.9999 then
				--let v_scve_variable=17;
				--let v_ssubcve_variable=2;
				let v_spuntaje_adn = 0;
			elif v_adn >= 16 and v_adn <= 35.9999 then
				--let v_scve_variable=17;
				--let v_ssubcve_variable=3;
				let v_spuntaje_adn = -0.1113;
			elif v_adn >= 36 and v_adn <= 50.9999 then
				--let v_scve_variable=17;
				--let v_ssubcve_variable=4;
				let v_spuntaje_adn = -0.1113;
			elif v_adn >= 51 and v_adn <= 100.9999 then
				--let v_scve_variable=17;
				--let v_ssubcve_variable=5;
				let v_spuntaje_adn = -0.1113;
			elif v_adn = 999 then
				--let v_scve_variable=17;
				--let v_ssubcve_variable=6;
				let v_spuntaje_adn = 0;
			end if;
			--variable bc score
			if v_bc_score >= 0 and v_bc_score <= 576 then
				let v_spuntaje_bc_score = -0.9051;
			elif v_bc_score >= 577 and v_bc_score <= 626 then
				let v_spuntaje_bc_score = -0.9051;
			elif v_bc_score >= 627 and v_bc_score <= 661 then
				let v_spuntaje_bc_score = -0.9051;
			elif v_bc_score >= 662 and v_bc_score <= 669 then
				let v_spuntaje_bc_score = -0.9051;
			elif v_bc_score >= 670 and v_bc_score <= 699 then
				let v_spuntaje_bc_score = -0.3533;
			elif v_bc_score >= 700 and v_bc_score <= 705 then
				let v_spuntaje_bc_score = -0.3533;
			elif v_bc_score >= 706 and v_bc_score <= 717 then
				let v_spuntaje_bc_score = -0.3533;
			elif v_bc_score >= 718 and v_bc_score <= 729 then
				let v_spuntaje_bc_score = -0.3533;
			elif v_bc_score >= 730 and v_bc_score <= 746 then
				let v_spuntaje_bc_score = 0;
			elif v_bc_score > 746  then
				let v_spuntaje_bc_score = 0;
			elif v_bc_score = 99999  then
				let v_spuntaje_bc_score = 0;
			elif v_bc_score < 0  then
				let v_spuntaje_bc_score = 0;
			end if;
			--variable adl
			if v_adl < 0 then
				let v_spuntaje_adl = 0.6614;
			elif v_adl >= 0 and v_adl <= 35.9999 then
				let v_spuntaje_adl = 0.6614;
			elif v_adl >= 36 and v_adl <= 70.9999 then
				let v_spuntaje_adl = 0.6614;
			elif v_adl >= 71 and v_adl <= 90.9999 then
				let v_spuntaje_adl = 0;
			elif v_adl > 90 then
				let v_spuntaje_adl = 0;
			elif v_adl = 9999999999 then
				let v_spuntaje_adl = 0;
			end if;
			--variable adv4
			if v_adv4 = 1 then
				let v_spuntaje_adv4 = 0;
			elif v_adv4 = 2 then
				let v_spuntaje_adv4 = 0;
			elif v_adv4 = 3 then
				let v_spuntaje_adv4 = 0;
			elif v_adv4 = 4 then
				let v_spuntaje_adv4 = -0.0986;
			elif v_adv4 = 5 then
				let v_spuntaje_adv4 = -0.0986;
			elif v_adv4 = 6 then
				let v_spuntaje_adv4 = -0.0986;
			elif v_adv4 = 7 then
				let v_spuntaje_adv4 = -0.0986;
			elif v_adv4 = 8 then
				let v_spuntaje_adv4 = -0.0986;
			elif v_adv4 = 9 then
				let v_spuntaje_adv4 = -0.0986;
			elif v_adv4 = 10 then
				let v_spuntaje_adv4 = -0.0986;
			elif v_adv4 = 11 then
				let v_spuntaje_adv4 = -0.0986;
			elif v_adv4 = 12 then
				let v_spuntaje_adv4 = -0.0986;
			elif v_adv4 >= 13 and v_adv4 <= 998 then
				let v_spuntaje_adv4 = -0.0986;
			elif v_adv4 = 999 then
				let v_spuntaje_adv4 = 0;
			elif v_adv4 < 0 then
				let v_spuntaje_adv4 = 0;
			end if;
		end if;
		--Créditos que son Clean Thick No Hit
		if v_sbanderahit = 'N' then
			--variable edad
			if v_edad <= 20 then
					let v_spuntaje_edad = -0.3898;
			elif  v_edad >= 21 and v_edad <= 25 then
					let v_spuntaje_edad = -0.3898;
			elif  v_edad >= 26 and v_edad <= 30 then
					let v_spuntaje_edad = -0.3898;
			elif  v_edad >= 31 and v_edad <= 35 then
					let v_spuntaje_edad = 0;
			elif  v_edad >= 36 and v_edad <= 40 then
					let v_spuntaje_edad = 0;
			elif  v_edad >= 41 and v_edad <= 45 then
					let v_spuntaje_edad = 0;
			elif  v_edad >= 46 and v_edad <= 50 then
					let v_spuntaje_edad = 0;
			elif  v_edad >= 51 and v_edad <= 55 then
					let v_spuntaje_edad = 0;
			elif  v_edad >= 56 and v_edad <= 60 then
					let v_spuntaje_edad = 0;
			elif  v_edad >= 61 and v_edad <= 65 then
					let v_spuntaje_edad = 0;
			elif  v_edad >= 66 and v_edad <= 70 then
					let v_spuntaje_edad = 0;
			elif  v_edad >= 71 and v_edad <= 75 then
					let v_spuntaje_edad = 0;
			elif  v_edad >= 76 and v_edad <= 80 then
					let v_spuntaje_edad = 0;
			elif  v_edad >= 81 then
					let v_spuntaje_edad = 0;
			end if;
			--variable sexo
			if v_sexo = 'M' then
				let v_spuntaje_sexo = -0.2226;
			elif v_sexo = 'F' then 
				let v_spuntaje_sexo = 0;
			end if;
			--variable sdo corriente
			if v_sdocorriente <= 0 then
					let v_spuntaje_sdo_corriente = 0;
				elif v_sdocorriente >= 0.1 and v_sdocorriente <= 500.99 then 
					let v_spuntaje_sdo_corriente = 0;
				elif v_sdocorriente >= 500.1 and v_sdocorriente <= 1000.99 then 
					let v_spuntaje_sdo_corriente = 0;
				elif v_sdocorriente >= 1000.1 and v_sdocorriente <= 2000.99 then 
					let v_spuntaje_sdo_corriente = 0;
				elif v_sdocorriente >= 2000.1 and v_sdocorriente <= 3000.99 then 
					let v_spuntaje_sdo_corriente = 0;
				elif v_sdocorriente >= 3000.1 and v_sdocorriente <= 4000.99 then 
					let v_spuntaje_sdo_corriente = -0.8321;
				elif v_sdocorriente >= 4000.1 and v_sdocorriente <= 5000.99 then 
					let v_spuntaje_sdo_corriente = -0.8321;
				elif v_sdocorriente >= 5000.1 and v_sdocorriente <= 6000.99 then 
					let v_spuntaje_sdo_corriente = -0.8321;
				elif v_sdocorriente >= 6000.1 and v_sdocorriente <= 7000.99 then 
					let v_spuntaje_sdo_corriente = -0.8321;
				elif v_sdocorriente >= 7000.1 and v_sdocorriente <= 8000.99 then 
					let v_spuntaje_sdo_corriente = -0.8321;
				elif v_sdocorriente >= 8000.1 and v_sdocorriente <= 9000.99 then 
					let v_spuntaje_sdo_corriente = -0.8321;
				elif v_sdocorriente > 9000 then 
					let v_spuntaje_sdo_corriente = -0.8321;
			end if;
			--variable mnl
			if v_mnl <= 0 then
				let v_spuntaje_mnl = 0;
			elif v_mnl >= 0.01 and v_mnl <= 0.08 then
				let v_spuntaje_mnl = 0;
			elif v_mnl >= 0.09 and v_mnl <= 0.17 then
				let v_spuntaje_mnl = 0;
			elif v_mnl >= 0.18 and v_mnl <= 0.25 then
				let v_spuntaje_mnl = 0;
			elif v_mnl >= 0.26 and v_mnl <= 0.33 then
				let v_spuntaje_mnl = 0;
			elif v_mnl >= 0.34 and v_mnl <= 0.50 then
				let v_spuntaje_mnl = 0;
			elif v_mnl >= 0.51 and v_mnl <= 0.83 then
				let v_spuntaje_mnl = -0.4308;
			elif v_mnl >= 0.84 and v_mnl <= 1.08 then
				let v_spuntaje_mnl = -0.4308;
			elif v_mnl >= 1.09 and v_mnl <= 998 then
				let v_spuntaje_mnl = -0.4308;
			end if;
			--variable pbl
			if v_pbl <= 0 then
				let v_spuntaje_pbl = 0;
			elif v_pbl >= 0.01 and v_pbl <= 30 then
				let v_spuntaje_pbl = 0;
			elif v_pbl >= 31 and v_pbl <= 55 then
				let v_spuntaje_pbl = 0;
			elif v_pbl >= 56 and v_pbl <= 75 then
				let v_spuntaje_pbl = 0;
			elif v_pbl >= 76 and v_pbl <= 85 then
				let v_spuntaje_pbl = -0.4550;
			elif v_pbl >= 86 and v_pbl <= 90 then
				let v_spuntaje_pbl = -0.4550;
			elif v_pbl >= 91 and v_pbl <= 95 then
				let v_spuntaje_pbl = -0.4550;
			elif v_pbl >= 96 and v_pbl <= 100 then
				let v_spuntaje_pbl = -0.4550;
			elif v_pbl >= 101 and v_pbl <= 105 then
				let v_spuntaje_pbl = -0.4550;
			elif v_pbl >= 106 and v_pbl <= 9999999999 then
				let v_spuntaje_pbl = -0.4550;
			elif v_pbl is null then
				let v_spuntaje_pbl = 0;
			end if;
			--variable SNL
			if v_snl <= 1 then
				let v_spuntaje_snl = 0;
			elif v_snl >= 2 and v_snl <= 12 then
				let v_spuntaje_snl = 0;
			end if;
			--variable mdl
			if v_mdl = 0 then
				let v_spuntaje_mdl = 0;
			elif v_mdl = 1 then
				let v_spuntaje_mdl = -0.4399;
			elif v_mdl >= 2 and v_mdl <= 98 then
				let v_spuntaje_mdl = -0.4399;
			end if;
			--variable ldl
			if v_ldl <= 0 then
				let v_spuntaje_ldl = 0;
			elif v_ldl = 1 then
				let v_spuntaje_ldl = 0;
			elif v_ldl >= 1 then
				let v_spuntaje_ldl = 0;
			end if;
			--variable psp
			if v_psp <= 0 then
				let v_spuntaje_psp = 0;
			elif v_psp >= 0.0001 and v_psp <= 25 then
				let v_spuntaje_psp = 0;
			elif v_psp >= 25.01 and v_psp <= 115 then
				let v_spuntaje_psp = 0;
			elif v_psp >= 115.01 and v_psp <= 845 then
				let v_spuntaje_psp = 0;
			elif v_psp >= 845.01 and v_psp <= 9999999999 then
				let v_spuntaje_psp = 0;
			elif v_psp is null then
				let v_spuntaje_psp = 0;
			end if;
			--variable cma
			if v_cma = 0 then
				let v_spuntaje_cma = 0;
			elif v_cma = 1 then
				let v_spuntaje_cma = 0;
			elif v_cma = 2 then
				let v_spuntaje_cma = 0;
			elif v_cma = 3 then
				let v_spuntaje_cma = 0;
			elif v_cma = 4 then
				let v_spuntaje_cma = 0;
			elif v_cma = 5 then
				let v_spuntaje_cma = 0;
			elif v_cma = 6 then
				let v_spuntaje_cma = 0;
			elif v_cma = 7 then
				let v_spuntaje_cma = 0;
			elif v_cma = 8 then
				let v_spuntaje_cma = 0;
			elif v_cma = 9 then
				let v_spuntaje_cma = 0;
			elif v_cma = 10 then
				let v_spuntaje_cma = 0;
			elif v_cma = 11 then
				let v_spuntaje_cma = 0;
			elif v_cma = 12 then
				let v_spuntaje_cma = 0;
			end if;
			--variable cms
			if v_cms = 0 then
				let v_spuntaje_cms = 0;
			elif v_cms = 1 then
				let v_spuntaje_cms = 0;
			elif v_cms = 2 then
				let v_spuntaje_cms = 0;
			elif v_cms = 3 then
				let v_spuntaje_cms = 0;
			elif v_cms = 4 then
				let v_spuntaje_cms = 0;
			elif v_cms = 5 then
				let v_spuntaje_cms = 0;
			elif v_cms = 6 then
				let v_spuntaje_cms = 0;
			end if;
			--variable cmt
			if v_cmt = 0 then
				let v_spuntaje_cmt = 0;
			elif v_cmt = 1 then
				let v_spuntaje_cmt = 0;
			elif v_cmt = 2 then
				let v_spuntaje_cmt = 0;
			elif v_cmt = 3 then
				let v_spuntaje_cmt = 0;
			end if;
			--variable cmn
			if v_cmn = 0 then
				let v_spuntaje_cmn = 0;
			elif v_cmn = 1 then
				let v_spuntaje_cmn = 0;
			elif v_cmn = 2 then
				let v_spuntaje_cmn = 0;
			elif v_cmn = 3 then
				let v_spuntaje_cmn = 0;
			elif v_cmn = 4 then
				let v_spuntaje_cmn = 0;
			elif v_cmn = 5 then
				let v_spuntaje_cmn = 0;
			elif v_cmn = 6 then
				let v_spuntaje_cmn = 0;
			elif v_cmn = 7 then
				let v_spuntaje_cmn = 0;
			elif v_cmn >= 8 and v_cmn <= 12 then
				let v_spuntaje_cmn = 0;
			end if;
			--variable ppl
			if v_ppl <= 20 then
				let v_spuntaje_ppl = 0;
			elif v_ppl > 20 and v_ppl <= 35 then
				let v_spuntaje_ppl = 0;
			elif v_ppl > 35 and v_ppl <= 50 then
				let v_spuntaje_ppl = 0;
			elif v_ppl > 50 and v_ppl <= 70 then
				let v_spuntaje_ppl = 0;
			elif v_ppl > 70 and v_ppl <= 85 then
				let v_spuntaje_ppl = 0;
			elif v_ppl > 85 and v_ppl <= 100 then
				let v_spuntaje_ppl = 0;
			end if;
			--variable ADP
			if v_adp < 0 then
				let v_spuntaje_adp = 0.2854;
			elif v_adp >= 0 and v_adp <= 10.9999 then
				let v_spuntaje_adp = 0.2854;
			elif v_adp >= 11 and v_adp <= 35.9999 then
				let v_spuntaje_adp = 0.2854;
			elif v_adp >= 36 and v_adp <= 55.9999 then
				let v_spuntaje_adp = 0.2854;
			elif v_adp >= 56 and v_adp <= 70.9999 then
				let v_spuntaje_adp = 0.2854;
			elif v_adp >= 71 and v_adp <= 80.9999 then
				let v_spuntaje_adp = 0;
			elif v_adp >= 81 and v_adp <= 90.9999 then
				let v_spuntaje_adp = 0;
			elif v_adp > 90 then
				let v_spuntaje_adp = 0;
			elif v_adp = 9999999999 then
				let v_spuntaje_adp = 0;
			end if;
			--variable adc
			if v_adc <= 1 then
				let v_spuntaje_adc = 0;
			elif v_adc = 2 then
				let v_spuntaje_adc = 0;
			elif v_adc = 3 then
				let v_spuntaje_adc = 0;
			elif v_adc = 4 then
				let v_spuntaje_adc = -0.2213;
			elif v_adc > 4 and v_adc <= 6 then
				let v_spuntaje_adc = -0.2213;
			elif v_adc > 6 and v_adc <= 9 then 
				let v_spuntaje_adc = -0.2213;
			elif v_adc > 9 and v_adc <= 998 then 
				let v_spuntaje_adc = -0.2213;
			elif v_adc = 999 then
				let v_spuntaje_adc = 0;
			end if;
			--variable adn
			if v_adn <= 0 then
				let v_spuntaje_adn = 0;
			elif v_adn >= 1 and v_adn <= 15.9999 then
				let v_spuntaje_adn = 0;
			elif v_adn >= 16 and v_adn <= 35.9999 then
				let v_spuntaje_adn = 0;
			elif v_adn >= 36 and v_adn <= 50.9999 then
				let v_spuntaje_adn = 0;
			elif v_adn >= 51 and v_adn <= 100.9999 then
				let v_spuntaje_adn = 0;
			elif v_adn = 999 then
				let v_spuntaje_adn = 0;
			end if;
			--variable bc score
			if v_bc_score >= 0 and v_bc_score <= 576 then
				let v_spuntaje_bc_score = -0.7237;
			elif v_bc_score >= 577 and v_bc_score <= 626 then
				let v_spuntaje_bc_score = -0.7237;
			elif v_bc_score >= 627 and v_bc_score <= 661 then
				let v_spuntaje_bc_score = -0.7237;
			elif v_bc_score >= 662 and v_bc_score <= 669 then
				let v_spuntaje_bc_score = -0.7237;
			elif v_bc_score >= 670 and v_bc_score <= 699 then
				let v_spuntaje_bc_score = -0.7237;
			elif v_bc_score >= 700 and v_bc_score <= 705 then
				let v_spuntaje_bc_score = -0.7237;
			elif v_bc_score >= 706 and v_bc_score <= 717 then
				let v_spuntaje_bc_score = -0.7237;
			elif v_bc_score >= 718 and v_bc_score <= 729 then
				let v_spuntaje_bc_score = -0.7237;
			elif v_bc_score >= 730 and v_bc_score <= 746 then
				let v_spuntaje_bc_score = 0;
			elif v_bc_score > 746  then
				let v_spuntaje_bc_score = 0;
			elif v_bc_score = 99999  then
				let v_spuntaje_bc_score = 0;
			elif v_bc_score < 0  then
				let v_spuntaje_bc_score = 0;
			end if;
			--variable adl
			if v_adl < 0 then
				let v_spuntaje_adl = 0;
			elif v_adl >= 0 and v_adl <= 35.9999 then
				let v_spuntaje_adl = 0;
			elif v_adl >= 36 and v_adl <= 70.9999 then
				let v_spuntaje_adl = 0;
			elif v_adl >= 71 and v_adl <= 90.9999 then
				let v_spuntaje_adl = 0;
			elif v_adl > 90 then
				let v_spuntaje_adl = 0;
			elif v_adl = 9999999999 then
				let v_spuntaje_adl = 0;
			end if;
			--variable adv4
			if v_adv4 = 1 then
				let v_spuntaje_adv4 = 0;
			elif v_adv4 = 2 then
				let v_spuntaje_adv4 = 0;
			elif v_adv4 = 3 then
				let v_spuntaje_adv4 = 0;
			elif v_adv4 = 4 then
				let v_spuntaje_adv4 = 0;
			elif v_adv4 = 5 then
				let v_spuntaje_adv4 = 0;
			elif v_adv4 = 6 then
				let v_spuntaje_adv4 = 0;
			elif v_adv4 = 7 then
				let v_spuntaje_adv4 = 0;
			elif v_adv4 = 8 then
				let v_spuntaje_adv4 = 0;
			elif v_adv4 = 9 then
				let v_spuntaje_adv4 = 0;
			elif v_adv4 = 10 then
				let v_spuntaje_adv4 = 0;
			elif v_adv4 = 11 then
				let v_spuntaje_adv4 = 0;
			elif v_adv4 = 12 then
				let v_spuntaje_adv4 = 0;
			elif v_adv4 >= 13 and v_adv4 <= 998 then
				let v_spuntaje_adv4 = 0;
			elif v_adv4 = 999 then
				let v_spuntaje_adv4 = 0;
			elif v_adv4 < 0 or v_adv4 > 12 then
				let v_spuntaje_adv4 = 0;
			end if;
		end if;
		--Créditos que son Dirty
		if v_sbanderahit = 'D' then
			--variable edad
			if v_edad <= 20 then
					let v_spuntaje_edad = -0.2261;
			elif  v_edad >= 21 and v_edad <= 25 then
					let v_spuntaje_edad = -0.2261;
			elif  v_edad >= 26 and v_edad <= 30 then
					let v_spuntaje_edad = -0.2261;
			elif  v_edad >= 31 and v_edad <= 35 then
					let v_spuntaje_edad = 0;
			elif  v_edad >= 36 and v_edad <= 40 then
					let v_spuntaje_edad = 0;
			elif  v_edad >= 41 and v_edad <= 45 then
					let v_spuntaje_edad = 0;
			elif  v_edad >= 46 and v_edad <= 50 then
					let v_spuntaje_edad = 0.1287;
			elif  v_edad >= 51 and v_edad <= 55 then
					let v_spuntaje_edad = 0.1287;
			elif  v_edad >= 56 and v_edad <= 60 then
					let v_spuntaje_edad = 0.1287;
			elif  v_edad >= 61 and v_edad <= 65 then
					let v_spuntaje_edad = 0.1287;
			elif  v_edad >= 66 and v_edad <= 70 then
					let v_spuntaje_edad = 0.1287;
			elif  v_edad >= 71 and v_edad <= 75 then
					let v_spuntaje_edad = 0.1287;
			elif  v_edad >= 76 and v_edad <= 80 then
					let v_spuntaje_edad = 0.1287;
			elif  v_edad >= 81 then
					let v_spuntaje_edad = 0;
			end if;
			--variable sexo
			if v_sexo = 'M' then
				let v_spuntaje_sexo = 0;
			elif v_sexo = 'F' then 
				let v_spuntaje_sexo = 0;
			end if;
			--variable sdo_corriente
			if v_sdocorriente <= 0.99 then
					let v_spuntaje_sdo_corriente = 0.541;
				elif v_sdocorriente >= 0.1 and v_sdocorriente <= 500.99 then 
					let v_spuntaje_sdo_corriente = 0.541;
				elif v_sdocorriente >= 500.1 and v_sdocorriente <= 1000.99 then 
					let v_spuntaje_sdo_corriente = 0.541;
				elif v_sdocorriente >= 1000.1 and v_sdocorriente <= 2000.99 then 
					let v_spuntaje_sdo_corriente = 0.541;
				elif v_sdocorriente >= 2000.1 and v_sdocorriente <= 3000.99 then 
					let v_spuntaje_sdo_corriente = 0;
				elif v_sdocorriente >= 3000.1 and v_sdocorriente <= 4000.99 then 
					let v_spuntaje_sdo_corriente = 0;
				elif v_sdocorriente >= 4000.1 and v_sdocorriente <= 5000.99 then 
					let v_spuntaje_sdo_corriente = 0;
				elif v_sdocorriente >= 5000.1 and v_sdocorriente <= 6000.99 then 
					let v_spuntaje_sdo_corriente = 0;
				elif v_sdocorriente >= 6000.1 and v_sdocorriente <= 7000.99 then 
					let v_spuntaje_sdo_corriente = -0.4399;
				elif v_sdocorriente >= 7000.1 and v_sdocorriente <= 8000.99 then 
					let v_spuntaje_sdo_corriente = -0.4399;
				elif v_sdocorriente >= 8000.1 and v_sdocorriente <= 9000.99 then 
					let v_spuntaje_sdo_corriente = -0.4399;
				elif v_sdocorriente > 9000 then 
					let v_spuntaje_sdo_corriente = -0.4399;
			end if;
			--variable mnl
			if v_mnl <= 0 then
				let v_spuntaje_mnl = 0;
			elif v_mnl >= 0.01 and v_mnl <= 0.08 then
				let v_spuntaje_mnl = 0;
			elif v_mnl >= 0.09 and v_mnl <= 0.17 then
				let v_spuntaje_mnl = 0;
			elif v_mnl >= 0.18 and v_mnl <= 0.25 then
				let v_spuntaje_mnl = 0;
			elif v_mnl >= 0.26 and v_mnl <= 0.33 then
				let v_spuntaje_mnl = 0;
			elif v_mnl >= 0.34 and v_mnl <= 0.50 then
				let v_spuntaje_mnl = 0;
			elif v_mnl >= 0.51 and v_mnl <= 0.83 then
				let v_spuntaje_mnl = 0;
			elif v_mnl >= 0.84 and v_mnl <= 1.08 then
				let v_spuntaje_mnl = 0;
			elif v_mnl >= 1.09 and v_mnl <= 998 then
				let v_spuntaje_mnl = 0;
			end if;
			--varaible pbl
			if v_pbl <= 0 then
				let v_spuntaje_pbl = 0;
			elif v_pbl >= 0.01 and v_pbl <= 30 then
				let v_spuntaje_pbl = 0;
			elif v_pbl >= 31 and v_pbl <= 55 then
				let v_spuntaje_pbl = 0;
			elif v_pbl >= 56 and v_pbl <= 75 then
				let v_spuntaje_pbl = 0;
			elif v_pbl >= 76 and v_pbl <= 85 then
				let v_spuntaje_pbl = 0;
			elif v_pbl >= 86 and v_pbl <= 90 then
				let v_spuntaje_pbl = 0;
			elif v_pbl >= 91 and v_pbl <= 95 then
				let v_spuntaje_pbl = 0;
			elif v_pbl >= 96 and v_pbl <= 100 then
				let v_spuntaje_pbl = 0;
			elif v_pbl >= 101 and v_pbl <= 105 then
				let v_spuntaje_pbl = 0;
			elif v_pbl >= 106 and v_pbl <= 9999999999 then
				let v_spuntaje_pbl = 0;
			elif v_pbl is null then
				let v_spuntaje_pbl = 0;
			end if;
			--variable SNL
			if v_snl <= 1 then
				let v_spuntaje_snl = 0.2366;
			elif v_snl >= 2 and v_snl <= 12 then
				let v_spuntaje_snl = 0;
			end if;
			--variable mdl
			if v_mdl = 0 then
				let v_spuntaje_mdl = 0;
			elif v_mdl = 1 then
				let v_spuntaje_mdl = 0.3575;
			elif v_mdl >= 2 and v_mdl <= 98 then
				let v_spuntaje_mdl = 0;
			end if;
			--variable ldl
			if v_ldl <= 0 then
				let v_spuntaje_ldl = 0;
			elif v_ldl = 1 then
				let v_spuntaje_ldl = 0;
			elif v_ldl >= 1 then
				let v_spuntaje_ldl = -1.3508;
			end if;
			--variable psp
			if v_psp <= 0 then
				let v_spuntaje_psp = 0.1399;
			elif v_psp >= 0.0001 and v_psp <= 25 then
				let v_spuntaje_psp = 0;
			elif v_psp >= 25.01 and v_psp <= 115 then
				let v_spuntaje_psp = 0;
			elif v_psp >= 115.01 and v_psp <= 845 then
				let v_spuntaje_psp = 0;
			elif v_psp >= 845.01 and v_psp <= 9999999999 then
				let v_spuntaje_psp = 0;
			elif v_psp is null then
				let v_spuntaje_psp = 0;
			end if;
			--variable cma
			if v_cma = 0 then
				let v_spuntaje_cma = -0.3138;
			elif v_cma = 1 then
				let v_spuntaje_cma = -0.3138;
			elif v_cma = 2 then
				let v_spuntaje_cma = -0.3138;
			elif v_cma = 3 then
				let v_spuntaje_cma = 0;
			elif v_cma = 4 then
				let v_spuntaje_cma = 0;
			elif v_cma = 5 then
				let v_spuntaje_cma = 0;
			elif v_cma = 6 then
				let v_spuntaje_cma = 0;
			elif v_cma = 7 then
				let v_spuntaje_cma = 0;
			elif v_cma = 8 then
				let v_spuntaje_cma = 0.0807;
			elif v_cma = 9 then
				let v_spuntaje_cma = 0.0807;
			elif v_cma = 10 then
				let v_spuntaje_cma = 0.0807;
			elif v_cma = 11 then
				let v_spuntaje_cma = 0.1124;
			elif v_cma = 12 then
				let v_spuntaje_cma = 0.1124;
			end if;
			--variable cms
			if v_cms = 0 then
				let v_spuntaje_cms = -0.7038;
			elif v_cms = 1 then
				let v_spuntaje_cms = 0;
			elif v_cms = 2 then
				let v_spuntaje_cms = 0;
			elif v_cms = 3 then
				let v_spuntaje_cms = 0;
			elif v_cms = 4 then
				let v_spuntaje_cms = 0;
			elif v_cms = 5 then
				let v_spuntaje_cms = 0.1371;
			elif v_cms = 6 then
				let v_spuntaje_cms = 0.1371;
			end if;
			--variable cmt
			if v_cmt = 0 then
				let v_spuntaje_cmt = -0.336;
			elif v_cmt = 1 then
				let v_spuntaje_cmt = -0.336;
			elif v_cmt = 2 then
				let v_spuntaje_cmt = 0;
			elif v_cmt = 3 then
				let v_spuntaje_cmt = 0.6414;
			end if;
			--variable cmn
			if v_cmn = 0 then
				let v_spuntaje_cmn = 0;
			elif v_cmn = 1 then
				let v_spuntaje_cmn = -0.3281;
			elif v_cmn = 2 then
				let v_spuntaje_cmn = -0.3281;
			elif v_cmn = 3 then
				let v_spuntaje_cmn = -0.3281;
			elif v_cmn = 4 then
				let v_spuntaje_cmn = -0.3281;
			elif v_cmn = 5 then
				let v_spuntaje_cmn = -0.3281;
			elif v_cmn = 6 then
				let v_spuntaje_cmn = -0.3281;
			elif v_cmn = 7 then
				let v_spuntaje_cmn = -0.3281;
			elif v_cmn >= 8 and v_cmn <= 12 then
				let v_spuntaje_cmn = -0.3281;
			end if;
			--variable ppl
			if v_ppl <= 20 then
				let v_spuntaje_ppl = 0;
			elif v_ppl > 20 and v_ppl <= 35 then
				let v_spuntaje_ppl = 0;
			elif v_ppl > 35 and v_ppl <= 50 then
				let v_spuntaje_ppl = 0;
			elif v_ppl > 50 and v_ppl <= 70 then
				let v_spuntaje_ppl = 0;
			elif v_ppl > 70 and v_ppl <= 85 then
				let v_spuntaje_ppl = 0.1766;
			elif v_ppl > 85 and v_ppl <= 100 then
				let v_spuntaje_ppl = 0.3474;
			end if;
			--variable adp
			if v_adp < 0 then
				let v_spuntaje_adp = 0.7086;
			elif v_adp >= 0 and v_adp <= 10.9999 then
				let v_spuntaje_adp = 0.7086;
			elif v_adp >= 11 and v_adp <= 35.9999 then
				let v_spuntaje_adp = 0.7086;
			elif v_adp >= 36 and v_adp <= 55.9999 then
				let v_spuntaje_adp = 0.7086;
			elif v_adp >= 56 and v_adp <= 70.9999 then
				let v_spuntaje_adp = 0.7086;
			elif v_adp >= 71 and v_adp <= 80.9999 then
				let v_spuntaje_adp = 0.7086;
			elif v_adp >= 81 and v_adp <= 90.9999 then
				let v_spuntaje_adp = 0;
			elif v_adp > 90 then
				let v_spuntaje_adp = 0;
			elif v_adp = 9999999999 then
				let v_spuntaje_adp = 0;
			end if;
			--variable adc
			if v_adc <= 1 then
				let v_spuntaje_adc = 0;
			elif v_adc = 2 then
				let v_spuntaje_adc = 0;
			elif v_adc = 3 then
				let v_spuntaje_adc = 0;
			elif v_adc = 4 then
				let v_spuntaje_adc = 0;
			elif v_adc > 4 and v_adc <= 6 then 
				let v_spuntaje_adc = 0;
			elif v_adc > 6 and v_adc <= 9 then 
				let v_spuntaje_adc = 0;
			elif v_adc > 9 and v_adc <= 998 then 
				let v_spuntaje_adc = 0;
			elif v_adc = 999 then
				let v_spuntaje_adc = 0;
			end if;
			--variable adn
			if v_adn <= 0 then
				let v_spuntaje_adn = 0;
			elif v_adn >= 1 and v_adn <= 15.9999 then
				let v_spuntaje_adn = 0;
			elif v_adn >= 16 and v_adn <= 35.9999 then
				let v_spuntaje_adn = 0;
			elif v_adn >= 36 and v_adn <= 50.9999 then
				let v_spuntaje_adn = 0;
			elif v_adn >= 51 and v_adn <= 100.9999 then
				let v_spuntaje_adn = 0;
			elif v_adn = 999 then
				let v_spuntaje_adn = 0;
			end if;
			--variable bc socre
			if v_bc_score >= 0 and v_bc_score <= 576 then
				let v_spuntaje_bc_score = 0;
			elif v_bc_score >= 577 and v_bc_score <= 626 then
				let v_spuntaje_bc_score = 0;
			elif v_bc_score >= 627 and v_bc_score <= 661 then
				let v_spuntaje_bc_score = 0.6381;
			elif v_bc_score >= 662 and v_bc_score <= 669 then
				let v_spuntaje_bc_score = 0.6381;
			elif v_bc_score >= 670 and v_bc_score <= 699 then
				let v_spuntaje_bc_score = 0.6381;
			elif v_bc_score >= 700 and v_bc_score <= 705 then
				let v_spuntaje_bc_score = 1.2889;
			elif v_bc_score >= 706 and v_bc_score <= 717 then
				let v_spuntaje_bc_score = 1.2889;
			elif v_bc_score >= 718 and v_bc_score <= 729 then
				let v_spuntaje_bc_score = 1.2889;
			elif v_bc_score >= 730 and v_bc_score <= 746 then
				let v_spuntaje_bc_score = 1.2889;
			elif v_bc_score > 746  then
				let v_spuntaje_bc_score = 1.2889;
			elif v_bc_score = 99999  then
				let v_spuntaje_bc_score = 0;
			elif v_bc_score < 0  then
				let v_spuntaje_bc_score = 0;
			end if;
			--variable adl
			if v_adl < 0 then
				let v_spuntaje_adl = 0;
			elif v_adl >= 0 and v_adl <= 35.9999 then
				let v_spuntaje_adl = 0;
			elif v_adl >= 36 and v_adl <= 70.9999 then
				let v_spuntaje_adl = 0;
			elif v_adl >= 71 and v_adl <= 90.9999 then
				let v_spuntaje_adl = 0;
			elif v_adl > 90 then
				let v_spuntaje_adl = 0;
			elif v_adl = 9999999999 then
				let v_spuntaje_adl = 0;
			end if;
			--variable adv4
			if v_adv4 = 1 then
				let v_spuntaje_adv4 = 0;
			elif v_adv4 = 2 then
				let v_spuntaje_adv4 = 0;
			elif v_adv4 = 3 then
				let v_spuntaje_adv4 = 0;
			elif v_adv4 = 4 then
				let v_spuntaje_adv4 = 0;
			elif v_adv4 = 5 then
				let v_spuntaje_adv4 = 0;
			elif v_adv4 = 6 then
				let v_spuntaje_adv4 = 0;
			elif v_adv4 = 7 then
				let v_spuntaje_adv4 = 0;
			elif v_adv4 = 8 then
				let v_spuntaje_adv4 = 0;
			elif v_adv4 = 9 then
				let v_spuntaje_adv4 = 0;
			elif v_adv4 = 10 then
				let v_spuntaje_adv4 = 0;
			elif v_adv4 = 11 then
				let v_spuntaje_adv4 = 0;
			elif v_adv4 = 12 then
				let v_spuntaje_adv4 = 0;
			elif v_adv4 >= 13 and v_adv4 <= 998 then
				let v_spuntaje_adv4 = 0;
			elif v_adv4 = 999 then
				let v_spuntaje_adv4 = 0;
			elif v_adv4 < 0 or v_adv4 > 12 then
				let v_spuntaje_adv4 = 0;
			end if;
		end if;

	
	 --end for;
	 insert into bdicred:sd_behavior_puntaje (num_credito,spuntaje_edad,spuntaje_sexo,spuntaje_sdo_corriente,spuntaje_mnl,
												spuntaje_pbl,spuntaje_snl,spuntaje_mdl,spuntaje_ldl,spuntaje_psp,spuntaje_cma,
												spuntaje_cms,spuntaje_cmt,spuntaje_cmn,spuntaje_ppl,spuntaje_adp,spuntaje_adc,
												spuntaje_adn,spuntaje_bc_score,spuntaje_adl,spuntaje_adv4,sbanderahit)
			values (v_numcuentaq,v_spuntaje_edad,v_spuntaje_sexo,v_spuntaje_sdo_corriente,v_spuntaje_mnl,
					v_spuntaje_pbl,v_spuntaje_snl,v_spuntaje_mdl,v_spuntaje_ldl,v_spuntaje_psp,v_spuntaje_cma,
					v_spuntaje_cms,v_spuntaje_cmt,v_spuntaje_cmn,v_spuntaje_ppl,v_spuntaje_adp,v_spuntaje_adc,
					v_spuntaje_adn,v_spuntaje_bc_score,v_spuntaje_adl,v_spuntaje_adv4,v_sbanderahit);
	   
	
	END FOREACH; 
	
     RETURN cCod_ret;
	END;
	
END PROCEDURE;
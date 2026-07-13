CREATE PROCEDURE "informix".ivr_saldo_cuenta( pTarjeta CHAR(16) ) 
RETURNING CHAR(5),      --- Codigo de Retorno
          CHAR(1),      --- Mas Cuentas
          CHAR(2),      --- Tipo Cuenta
          CHAR(4),      --- Cuenta
          MONEY(14,2),  --- Sdo Disponible
          MONEY(14,2),  --- Pago No Intereses
          MONEY(14,2),  --- Pago Minimo
          DATE;         --- Fecha Limite Pago
     
    DEFINE Sql_Err  INTEGER;
    DEFINE Isam_Err INTEGER;
    DEFINE Desc_Err CHAR(50);
    DEFINE vCodRet1 CHAR(5);
    DEFINE vCodRet2 CHAR(5);
    DEFINE vCodRet3 CHAR(50);
    
    DEFINE vcTelefono       CHAR(10);
    DEFINE vcStatusCte      CHAR(1);
    DEFINE vcTarjeta        CHAR(20);
    DEFINE vcCuenta         CHAR(20);
    DEFINE vcNumCliente     CHAR(10);
    DEFINE vcCredito        CHAR(20);
    DEFINE vStatusCta       CHAR(1);
    DEFINE vSdoActual       MONEY(18,2);
    DEFINE vSdoRetenido     MONEY(18,2);
    DEFINE vSdoCongelado    MONEY(18,2);
    DEFINE vSdoSobregirado  MONEY(18,2);
    DEFINE viExisMasCtas    SMALLINT;
    DEFINE viExisMasCrds    SMALLINT;
    DEFINE viExisMasCrds2   SMALLINT;
    
    DEFINE vcStatusCred             CHAR(2);
    DEFINE vcodret_sdos             CHAR(6);
    DEFINE vmensaje_sdos            CHAR(80);
    DEFINE vnumcredito              CHAR(20);
    DEFINE vcodigo_tipcred          CHAR(2);
    DEFINE vfecha_origen            DATE;
    DEFINE vfecha_prox_pago         DATE;
    DEFINE vpago_minimo             DECIMAL(18,2);
    DEFINE vfecha_ult_pago          DATE;
    DEFINE vplazo                   INTEGER;
    DEFINE vpagos_realizados        INTEGER;
    DEFINE vlinea_otorgada          DECIMAL(18,2);
    DEFINE vtasa_interes            DECIMAL(9,6);
    DEFINE vtasa_moratorios         DECIMAL(9,6);
    DEFINE vmonto_sbc               DECIMAL(14,2);
    DEFINE vcap_vig                 DECIMAL(18,2);
    DEFINE vcap_trans               DECIMAL(18,2);
    DEFINE vcap_vdo_exig            DECIMAL(18,2);
    DEFINE vcap_vdo_no_exig         DECIMAL(18,2);
    DEFINE vsdo_act_total_cap       DECIMAL(18,2);
    DEFINE vint_vig                 DECIMAL(18,2);
    DEFINE vint_vdo                 DECIMAL(18,2);
    DEFINE vint_moratorios          DECIMAL(18,2);
    DEFINE vint_mes                 DECIMAL(18,2);
    DEFINE vsdo_act_total_int       DECIMAL(18,2);
    DEFINE viva_int_vig             DECIMAL(18,2);
    DEFINE viva_int_vdo             DECIMAL(18,2);
    DEFINE viva_int_moratorios      DECIMAL(18,2);
    DEFINE viva_int_mes             DECIMAL(18,2);
    DEFINE vsdo_act_total_iva       DECIMAL(18,2);
    DEFINE vcom_pend                DECIMAL(18,2);
    DEFINE viva_com                 DECIMAL(18,2);
    DEFINE vsdo_retenido            DECIMAL(18,2);
    DEFINE vtotal_liquidacion       DECIMAL(18,2);
    DEFINE vint_devengado           DECIMAL(18,2);
    DEFINE viva_int_devengado       DECIMAL(18,2);
    DEFINE vlinea_disponible        DECIMAL(18,2);
    DEFINE vpagos_vdos              DECIMAL(18,2);
    DEFINE vdesc_status_cred        CHAR(60);
    DEFINE vid_bloqueo_cred         INTEGER;
    DEFINE vbloqueo_cta             CHAR(60);
    DEFINE vid_causa_bloqueo_cred   CHAR(3);
    DEFINE vcausa_bloqueo_cta       CHAR(50);
    DEFINE vid_sit_esp_cte          CHAR(1);
    DEFINE vid_causa_esp_cte        INTEGER;
    DEFINE vsit_esp_cte             CHAR(75);
    DEFINE vid_sit_esp_cred         CHAR(1);
    DEFINE vid_causa_esp_cred       INTEGER;
    DEFINE vsit_esp_cred            CHAR(75);
    DEFINE vCodRetSdoCorte          CHAR(5);
    DEFINE vSdoNoGenInt             DECIMAL(18,2);
    
    DEFINE vOtrasCtas       CHAR(1);
    DEFINE vTipoCta         CHAR(2);
    DEFINE vCuenta          CHAR(4);
    DEFINE vSdoDisp         MONEY(14,2);
    DEFINE vPagoNoInt       MONEY(14,2);
    DEFINE vPagoMin         MONEY(14,2);
    DEFINE vFechLimPago     DATE;
    DEFINE vSecMax          INTEGER;

    -- RQM 09 704. Se agregan las variables para el retorno de consulta de saldo. LEOC.
    DEFINE cCodRetConsSdo               CHAR(5);    -- Codigo de retorno de SP de consulta de saldo.
    DEFINE cMensajeRetConsSdo           CHAR(50);   -- Mensaje de retorno de SP de consulta de saldo.
    DEFINE mSaldoSbc                    MONEY(14,2);    
    LET Sql_Err	 = 0;
    LET Isam_Err = 0;
    LET Desc_Err = '';
    LET vCodRet1 = '00000';
    LET vCodRet2 = '';
    LET vCodRet3 = '';  
    
    LET vcTelefono   = '';
    LET vcStatusCte  = '';
    LET vcTarjeta    = '';
    LET vcCuenta     = '';
    LET vcNumCliente = '';
    LET vcCredito    = '';
    LET vStatusCta   = '';
    LET vSdoActual   = 0.00;
    LET vSdoRetenido = 0.00;
    LET vSdoCongelado = 0.00;
    LET vSdoSobregirado = 0.00;
    LET viExisMasCtas = 0;
    LET viExisMasCrds = 0;
    LET viExisMasCrds2 = 0;
    
    LET vcStatusCred           = '';
    LET vcodret_sdos           = '';
    LET vmensaje_sdos          = '';
    LET vnumcredito            = '';
    LET vcodigo_tipcred        = '';
    LET vfecha_origen          = '';
    LET vfecha_prox_pago       = '';
    LET vpago_minimo           = 0;
    LET vfecha_ult_pago        = '';
    LET vplazo                 = 0;
    LET vpagos_realizados      = 0;
    LET vlinea_otorgada        = 0;
    LET vtasa_interes          = 0;
    LET vtasa_moratorios       = 0;
    LET vmonto_sbc             = 0;
    LET vcap_vig               = 0;
    LET vcap_trans             = 0;
    LET vcap_vdo_exig          = 0;
    LET vcap_vdo_no_exig       = 0;
    LET vsdo_act_total_cap     = 0;
    LET vint_vig               = 0;
    LET vint_vdo               = 0;
    LET vint_moratorios        = 0;
    LET vint_mes               = 0;
    LET vsdo_act_total_int     = 0;
    LET viva_int_vig           = 0;
    LET viva_int_vdo           = 0;
    LET viva_int_moratorios    = 0;
    LET viva_int_mes           = 0;
    LET vsdo_act_total_iva     = 0;
    LET vcom_pend              = 0;
    LET viva_com               = 0;
    LET vsdo_retenido          = 0;
    LET vtotal_liquidacion     = 0;
    LET vint_devengado         = 0;
    LET viva_int_devengado     = 0;
    LET vlinea_disponible      = 0;
    LET vpagos_vdos            = 0;
    LET vdesc_status_cred      = '';
    LET vid_bloqueo_cred       = 0;
    LET vbloqueo_cta           = '';
    LET vid_causa_bloqueo_cred = '';
    LET vcausa_bloqueo_cta     = '';
    LET vid_sit_esp_cte        = '';
    LET vid_causa_esp_cte      = 0;
    LET vsit_esp_cte           = '';
    LET vid_sit_esp_cred       = '';
    LET vid_causa_esp_cred     = 0;
    LET vsit_esp_cred          = '';
    LET vCodRetSdoCorte        = '';
    LET vSdoNoGenInt           = 0.00;
    
    LET vOtrasCtas   = '';
    LET vTipoCta     = '';
    LET vCuenta      = '';
    LET vSdoDisp     = 0.00;
    LET vPagoNoInt   = 0.00;
    LET vPagoMin     = 0.00;
    LET vFechLimPago = '';
    LET vSecMax      = 0;

       -- RQM 09 704. Se inicializan las variables para el retorno de consulta de saldo. LEOC.
    LET cCodRetConsSdo               = '00000';
    LET cMensajeRetConsSdo           = '';
    LET mSaldoSbc                    = 0.00;
    
    BEGIN

    ON EXCEPTION SET Sql_Err, Isam_Err, Desc_Err
        --- SET DEBUG FILE TO "/resplogifx/conciliachq/ivr_saldo_cuenta.err";
        --- TRACE ON;
        IF Sql_Err <> 0 THEN
            LET vCodRet1 = Sql_Err;
            LET vCodRet2 = Isam_Err;
            LET vCodRet3 = Desc_Err;
            RETURN vCodRet1, vOtrasCtas, vTipoCta, vCuenta, vSdoDisp, vPagoNoInt, vPagoMin, vFechLimPago;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/ivr_saldo_cuenta.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF ( pTarjeta is null OR pTarjeta = '' ) THEN
        LET vCodRet1 = '00017';
        RETURN vCodRet1, vOtrasCtas, vTipoCta, vCuenta, vSdoDisp, vPagoNoInt, vPagoMin, vFechLimPago;
    END IF;
        
    -- // VERIFICA SI LA TARJETA ES DE DEBITO O CREDITO
    SELECT NVL(tar.num_tarjeta, ' '), tar.cuenta, tar.numcte
      INTO vcTarjeta, vcCuenta, vcNumCliente
      FROM bdicheq:"informix".sc_tarjeta tar,
           bdicheq:"informix".sc_maechq chq
     WHERE tar.empresa = chq.empresa
       AND tar.num_tarjeta = pTarjeta
       AND tar.tipo_tarjeta = 'T'
       AND tar.status_tar = 'A'
       AND chq.cuenta = tar.cuenta
       AND chq.num_cte = tar.numcte;
       
    IF vcTarjeta is null OR vcTarjeta = '' OR vcTarjeta = ' ' OR vcTarjeta <> pTarjeta THEN
        SELECT NVL(tar.num_tarjeta, ' '), tar.num_credito, tar.numcte
          INTO vcTarjeta, vcCredito, vcNumCliente
          FROM bdicred:"informix".sd_tarjeta tar,
               bdicred:"informix".sd_maecred crd
         WHERE tar.empresa = crd.empresa
           AND tar.num_tarjeta = pTarjeta
           AND tar.tipo_tarjeta = 'T'
           AND tar.status_tar = 'A'
           AND crd.num_credito = tar.num_credito
           AND crd.numcte = tar.numcte;
        
        IF vcTarjeta is null OR vcTarjeta = '' OR vcTarjeta = ' ' OR vcTarjeta <> pTarjeta THEN
            LET vCodRet1 = '00013';
            RETURN vCodRet1, vOtrasCtas, vTipoCta, vCuenta, vSdoDisp, vPagoNoInt, vPagoMin, vFechLimPago;
        ELSE
            LET vTipoCta = 'CR';
        END IF;
    ELSE
        LET vTipoCta = 'DB';
    END IF;
    
    IF vcCuenta is null OR vcCuenta = '' THEN
        LET vcCuenta = '10000000000';
    END IF;
    
    IF vcCredito is null OR vcCredito = '' THEN
        LET vcCredito = '600000000000';
    END IF;
    
    -- // VERIFICA SI EL CLIENTE EXISTE EN TABLA DE CLIENTES IVR
    SELECT NVL(telefono, ' '), status_cte
      INTO vcTelefono, vcStatusCte
      FROM bdinteg:"informix".si_cliente_ivr 
     WHERE numcte = vcNumCliente;
     
    IF vcTelefono is null OR vcTelefono = '' OR vcTelefono = ' ' THEN
        LET vCodRet1 = '00011';
        RETURN vCodRet1, vOtrasCtas, vTipoCta, vCuenta, vSdoDisp, vPagoNoInt, vPagoMin, vFechLimPago;
    END IF;
    
    IF vcStatusCte <> 'A' THEN
        LET vCodRet1 = '00012';
        RETURN vCodRet1, vOtrasCtas, vTipoCta, vCuenta, vSdoDisp, vPagoNoInt, vPagoMin, vFechLimPago;
    END IF;
     
    -- // OBTIENE LOS SALDOS DE LA TARJETA YA SEA DEBITO O CREDITO
    IF vTipoCta = 'DB' THEN
        -- // OBTIENE SALDOS DE LA CUENTA DE DEBITO
        SELECT NVL(status_cta, '2'), sdo_actual, sdo_retenido, sdo_cong, imp_chq_sbg, saldo_sbc
          INTO vStatusCta, vSdoActual, vSdoRetenido, vSdoCongelado, vSdoSobregirado, mSaldoSbc
          FROM bdicheq:"informix".sc_maechq
         WHERE empresa = '001'
           AND cuenta = vcCuenta;
           
        -- // VALIDA QUE LA CUENTA NO ESTE CANCELADA
        IF vStatusCta IN('2','3','6','7') THEN
            LET vCodRet1 = '00014';
            RETURN vCodRet1, vOtrasCtas, vTipoCta, vCuenta, vSdoDisp, vPagoNoInt, vPagoMin, vFechLimPago;
        END IF;
        
        LET vCuenta      = SUBSTR(vcCuenta, LENGTH(vcCuenta) - 3, 4);
        -- LET vSdoDisp     = vSdoActual - (vSdoRetenido + vSdoCongelado + vSdoSobregirado);
        LET vPagoNoInt   = 0.00;
        LET vPagoMin     = 0.00;
        LET vFechLimPago = '';

        -- RQM 09 704. Se agrega el llamado al SP de consulta de saldo con el tipo de calculo requerido para esta operacion. LEOC
        EXECUTE PROCEDURE bdicheq:"informix".sp_cons_sdodisp_x_tpcalculo(NULL, vSdoActual, vSdoRetenido, vSdoCongelado, mSaldoSbc, vSdoSobregirado, NULL, NULL, 'F', 1) INTO cCodRetConsSdo,cMensajeRetConsSdo,vSdoDisp;
        
    ELIF vTipoCta = 'CR' THEN
    
        -- // VALIDA QUE EL CREDITO ESTE VIGENTE
        SELECT NVL(status_cred, 'VV')
          INTO vcStatusCred
          FROM bdicred:"informix".sd_maecred
         WHERE empresa = '001'
           AND num_credito = vcCredito;
           
        IF vcStatusCred is null OR vcStatusCred = '' OR vcStatusCred NOT IN('AA','BA','BT','VP') THEN
            LET vCodRet1 = '00014';
            RETURN vCodRet1, vOtrasCtas, vTipoCta, vCuenta, vSdoDisp, vPagoNoInt, vPagoMin, vFechLimPago;
        END IF;
        
        LET vCuenta = SUBSTR(pTarjeta, LENGTH(pTarjeta) - 3, 4);
        
        -- // OBTIENE LOS SALDOS DEL CREDITO 
        EXECUTE PROCEDURE bdicred:"informix".sp_consulta_saldos_general('001', vcCredito)
        INTO vcodret_sdos, vmensaje_sdos, vnumcredito, vcodigo_tipcred, vfecha_origen, vfecha_prox_pago, 
             vpago_minimo, vfecha_ult_pago, vplazo, vpagos_realizados, vlinea_otorgada, vtasa_interes,
             vtasa_moratorios, vmonto_sbc, vcap_vig, vcap_trans, vcap_vdo_exig, vcap_vdo_no_exig, vsdo_act_total_cap,
             vint_vig, vint_vdo, vint_moratorios, vint_mes, vsdo_act_total_int, viva_int_vig, viva_int_vdo, viva_int_moratorios,
             viva_int_mes, vsdo_act_total_iva, vcom_pend, viva_com, vsdo_retenido, vtotal_liquidacion, vint_devengado, viva_int_devengado, 
             vlinea_disponible, vpagos_vdos, vdesc_status_cred, vid_bloqueo_cred, vbloqueo_cta, vid_causa_bloqueo_cred, vcausa_bloqueo_cta, 
             vid_sit_esp_cte, vid_causa_esp_cte, vsit_esp_cte, vid_sit_esp_cred, vid_causa_esp_cred, vsit_esp_cred;
                 
        -- // SALDO DISPONIBLE AL DIA DE HOY
        LET vSdoDisp = vtotal_liquidacion;
        
        IF vSdoDisp is null OR vSdoDisp < 0.00 THEN 
            LET vSdoDisp = 0.00; 
        END IF;
        
        -- // PAGO PARA NO GENERAR INTERESES
        EXECUTE PROCEDURE bdicred:"informix".sp_consultasaldocorte('001', vcCredito, 0)
        INTO vCodRetSdoCorte, vSdoNoGenInt;
        
        LET vPagoNoInt = vSdoNoGenInt;
        
        IF vPagoNoInt is null THEN 
            LET vPagoNoInt = 0.00; 
        END IF;
        
        -- // PAGO MINIMO
        LET vPagoMin = vpago_minimo;
        
        IF vPagoMin < 0 THEN 
            LET vPagoMin = 0.00; 
        END IF;
        
        -- // FECHA LIMITE DE PAGO 
        LET vFechLimPago = vfecha_prox_pago;
    
    END IF;
    
    -- // VERIFICA SI EL CLIENTE TIENE MAS CUENTAS 
    SELECT COUNT(*)
      INTO viExisMasCtas
      FROM bdicheq:"informix".sc_maechq
     WHERE empresa = '001'
       AND num_cte = vcNumCliente
       AND status_cta IN('1','4','5')
       AND cuenta <> vcCuenta
       AND producto NOT IN(SELECT producto FROM bdinteg:"informix".si_prodinval_ivr);
       
    -- // VERIFICA SI TIENE MAS CREDITOS VIGENTES
    SELECT COUNT(*)
      INTO viExisMasCrds
      FROM bdicred:"informix".sd_maecred
     WHERE numcte = vcNumCliente
       AND status_cred IN('AA','BA','BT','E1','E2','E3')
       AND num_credito <> vcCredito
       AND num_producto NOT IN(SELECT producto FROM bdinteg:"informix".si_prodinval_ivr);
    
    SELECT COUNT(*)
      INTO viExisMasCrds2
      FROM bdicred:"informix".sd_maecredcrd
     WHERE numcte = vcNumCliente
       AND status_cred IN('AA','BA','BT','VP','E1','E2','E3')
       AND num_credito <> vcCredito
       AND num_producto NOT IN(SELECT producto FROM bdinteg:"informix".si_prodinval_ivr);
       
    IF viExisMasCtas > 0 OR viExisMasCrds > 0 OR viExisMasCrds2 > 0 THEN
        LET vOtrasCtas = '1';
    ELSE
        LET vOtrasCtas = '0';
    END IF;
    
    -- // GUARDA REGISTRO EN BITACORA
    SELECT MAX(secuencia)
      INTO vSecMax
      FROM bdinteg:"informix".si_bitacora_ivr
     WHERE DATE(fecha_oper) = CURRENT::DATE
       AND numcte = vcNumCliente;
       
    IF vSecMax is null THEN
        LET vSecMax = 0;
    END IF;
    
    LET vSecMax = vSecMax + 1;
    
    INSERT INTO bdinteg:"informix".si_bitacora_ivr VALUES
    ( current, vSecMax, 'OBT_SDO_TARJETA', vcTarjeta, vcNumCliente, vcTelefono );
    
    END; 
    
    RETURN vCodRet1, vOtrasCtas, vTipoCta, vCuenta, vSdoDisp, vPagoNoInt, vPagoMin, vFechLimPago;
    
END PROCEDURE
DOCUMENT
'AUTOR      : N/A',
'BD         : BDIVVR',
'--------------------------------------',
'MODIFICO   : Luis Enrique Orozco Cosme',
'FECHA      : 7 de julio de 2025',
'MODIFICACION: Se modifica el calculo de saldo disponible para homologarlo con el llamado a un nuevo spl sp_cons_sdodisp_x_tpcalculo',
'PROYECTO   : RQM 09 704 Cobranza Automatica en Cuentas de Captacion',
'BD         : BDIVR',
'VERSION    : 1.0.1';

CREATE PROCEDURE "informix".ivr_saldo_otra_cuenta( pTarjeta CHAR(16) ) 
RETURNING CHAR(5),      --- Codigo de Retorno
          CHAR(2),      --- Tipo Cuenta 1
          CHAR(4),      --- Cuenta 1
          MONEY(14,2),  --- Sdo Disponible 1
          MONEY(14,2),  --- Pago No Intereses 1
          MONEY(14,2),  --- Pago Minimo 1
          DATE,         --- Fecha Limite Pago 1
          CHAR(2),      --- Tipo Cuenta 2
          CHAR(4),      --- Cuenta 2
          MONEY(14,2),  --- Sdo Disponible 2
          MONEY(14,2),  --- Pago No Intereses 2
          MONEY(14,2),  --- Pago Minimo 2
          DATE,         --- Fecha Limite Pago 2
          CHAR(2),      --- Tipo Cuenta 3
          CHAR(4),      --- Cuenta 3
          MONEY(14,2),  --- Sdo Disponible 3
          MONEY(14,2),  --- Pago No Intereses 3
          MONEY(14,2),  --- Pago Minimo 3
          DATE,         --- Fecha Limite Pago 3
          CHAR(2),      --- Tipo Cuenta 4
          CHAR(4),      --- Cuenta 4
          MONEY(14,2),  --- Sdo Disponible 4
          MONEY(14,2),  --- Pago No Intereses 4
          MONEY(14,2),  --- Pago Minimo 4
          DATE,         --- Fecha Limite Pago 4
          CHAR(2),      --- Tipo Cuenta 5
          CHAR(4),      --- Cuenta 5
          MONEY(14,2),  --- Sdo Disponible 5
          MONEY(14,2),  --- Pago No Intereses 5
          MONEY(14,2),  --- Pago Minimo 5
          DATE,         --- Fecha Limite Pago 5
          CHAR(2),      --- Tipo Cuenta 6
          CHAR(4),      --- Cuenta 6
          MONEY(14,2),  --- Sdo Disponible 6
          MONEY(14,2),  --- Pago No Intereses 6
          MONEY(14,2),  --- Pago Minimo 6
          DATE,         --- Fecha Limite Pago 6
          CHAR(2),      --- Tipo Cuenta 7
          CHAR(4),      --- Cuenta 7
          MONEY(14,2),  --- Sdo Disponible 7
          MONEY(14,2),  --- Pago No Intereses 7
          MONEY(14,2),  --- Pago Minimo 7
          DATE,         --- Fecha Limite Pago 7
          CHAR(2),      --- Tipo Cuenta 8
          CHAR(4),      --- Cuenta 8
          MONEY(14,2),  --- Sdo Disponible 8
          MONEY(14,2),  --- Pago No Intereses 8
          MONEY(14,2),  --- Pago Minimo 8
          DATE,         --- Fecha Limite Pago 8
          CHAR(2),      --- Tipo Cuenta 9
          CHAR(4),      --- Cuenta 9
          MONEY(14,2),  --- Sdo Disponible 9
          MONEY(14,2),  --- Pago No Intereses 9
          MONEY(14,2),  --- Pago Minimo 9
          DATE,         --- Fecha Limite Pago 9
          CHAR(2),      --- Tipo Cuenta 10
          CHAR(4),      --- Cuenta 10
          MONEY(14,2),  --- Sdo Disponible 10
          MONEY(14,2),  --- Pago No Intereses 10
          MONEY(14,2),  --- Pago Minimo 10
          DATE;         --- Fecha Limite Pago 10
    
    DEFINE Sql_Err  INTEGER;
    DEFINE Isam_Err INTEGER;
    DEFINE Desc_Err CHAR(50);
    DEFINE vCodRet1 CHAR(5);
    DEFINE vCodRet2 CHAR(5);
    DEFINE vCodRet3 CHAR(50);
    
    DEFINE vTipoCta1     CHAR(2);
    DEFINE vCuenta1      CHAR(4);
    DEFINE vSdoDisp1     MONEY(14,2);
    DEFINE vPagoNoInt1   MONEY(14,2);
    DEFINE vPagoMin1     MONEY(14,2);
    DEFINE vFechLimPago1 DATE;
    
    DEFINE vTipoCta2     CHAR(2);
    DEFINE vCuenta2      CHAR(4);
    DEFINE vSdoDisp2     MONEY(14,2);
    DEFINE vPagoNoInt2   MONEY(14,2);
    DEFINE vPagoMin2     MONEY(14,2);
    DEFINE vFechLimPago2 DATE;
    
    DEFINE vTipoCta3     CHAR(2);
    DEFINE vCuenta3      CHAR(4);
    DEFINE vSdoDisp3     MONEY(14,2);
    DEFINE vPagoNoInt3   MONEY(14,2);
    DEFINE vPagoMin3     MONEY(14,2);
    DEFINE vFechLimPago3 DATE;
    
    DEFINE vTipoCta4     CHAR(2);
    DEFINE vCuenta4      CHAR(4);
    DEFINE vSdoDisp4     MONEY(14,2);
    DEFINE vPagoNoInt4   MONEY(14,2);
    DEFINE vPagoMin4     MONEY(14,2);
    DEFINE vFechLimPago4 DATE;
    
    DEFINE vTipoCta5     CHAR(2);
    DEFINE vCuenta5      CHAR(4);
    DEFINE vSdoDisp5     MONEY(14,2);
    DEFINE vPagoNoInt5   MONEY(14,2);
    DEFINE vPagoMin5     MONEY(14,2);
    DEFINE vFechLimPago5 DATE;
    
    DEFINE vTipoCta6     CHAR(2);
    DEFINE vCuenta6      CHAR(4);
    DEFINE vSdoDisp6     MONEY(14,2);
    DEFINE vPagoNoInt6   MONEY(14,2);
    DEFINE vPagoMin6     MONEY(14,2);
    DEFINE vFechLimPago6 DATE;
    
    DEFINE vTipoCta7     CHAR(2);
    DEFINE vCuenta7      CHAR(4);
    DEFINE vSdoDisp7     MONEY(14,2);
    DEFINE vPagoNoInt7   MONEY(14,2);
    DEFINE vPagoMin7     MONEY(14,2);
    DEFINE vFechLimPago7 DATE;
    
    DEFINE vTipoCta8     CHAR(2);
    DEFINE vCuenta8      CHAR(4);
    DEFINE vSdoDisp8     MONEY(14,2);
    DEFINE vPagoNoInt8   MONEY(14,2);
    DEFINE vPagoMin8     MONEY(14,2);
    DEFINE vFechLimPago8 DATE;
    
    DEFINE vTipoCta9     CHAR(2);
    DEFINE vCuenta9      CHAR(4);
    DEFINE vSdoDisp9     MONEY(14,2);
    DEFINE vPagoNoInt9   MONEY(14,2);
    DEFINE vPagoMin9     MONEY(14,2);
    DEFINE vFechLimPago9 DATE;
    
    DEFINE vTipoCta10     CHAR(2);
    DEFINE vCuenta10      CHAR(4);
    DEFINE vSdoDisp10     MONEY(14,2);
    DEFINE vPagoNoInt10   MONEY(14,2);
    DEFINE vPagoMin10     MONEY(14,2);
    DEFINE vFechLimPago10 DATE;
    
    DEFINE vcTelefono       CHAR(10);
    DEFINE vcNumCliente     CHAR(10);
    DEFINE vcStatusCte      CHAR(1);
    DEFINE vcCuenta         CHAR(20);
    DEFINE vcCredito        CHAR(20);
    DEFINE viExisMasCtas    SMALLINT;
    DEFINE viExisMasCrds    SMALLINT;
    DEFINE viExisMasCrds2   SMALLINT;
    DEFINE vcont            SMALLINT;
    DEFINE vnum_credito     CHAR(20);
    DEFINE vnum_tarjeta     CHAR(16);
    DEFINE vcuenta          CHAR(20);
    DEFINE vcTarjeta        CHAR(20);
    
    DEFINE vcodret_dat      CHAR(6);
    DEFINE vmensaje_dat     CHAR(80);
    DEFINE vnum_credito_dat CHAR(20);
    DEFINE vnumcte_dat      CHAR(20);
    DEFINE vnombre_prod_dat CHAR(40);
    DEFINE vnum_tarjeta_dat CHAR(20);
    DEFINE vcliente_dat     CHAR(150);
    
    DEFINE vcStatusCred             CHAR(2);
    DEFINE vcodret_sdos             CHAR(6);
    DEFINE vmensaje_sdos            CHAR(80);
    DEFINE vnumcredito              CHAR(20);
    DEFINE vcodigo_tipcred          CHAR(2);
    DEFINE vfecha_origen            DATE;
    DEFINE vfecha_prox_pago         DATE;
    DEFINE vpago_minimo             DECIMAL(18,2);
    DEFINE vfecha_ult_pago          DATE;
    DEFINE vplazo                   INTEGER;
    DEFINE vpagos_realizados        INTEGER;
    DEFINE vlinea_otorgada          DECIMAL(18,2);
    DEFINE vtasa_interes            DECIMAL(9,6);
    DEFINE vtasa_moratorios         DECIMAL(9,6);
    DEFINE vmonto_sbc               DECIMAL(14,2);
    DEFINE vcap_vig                 DECIMAL(18,2);
    DEFINE vcap_trans               DECIMAL(18,2);
    DEFINE vcap_vdo_exig            DECIMAL(18,2);
    DEFINE vcap_vdo_no_exig         DECIMAL(18,2);
    DEFINE vsdo_act_total_cap       DECIMAL(18,2);
    DEFINE vint_vig                 DECIMAL(18,2);
    DEFINE vint_vdo                 DECIMAL(18,2);
    DEFINE vint_moratorios          DECIMAL(18,2);
    DEFINE vint_mes                 DECIMAL(18,2);
    DEFINE vsdo_act_total_int       DECIMAL(18,2);
    DEFINE viva_int_vig             DECIMAL(18,2);
    DEFINE viva_int_vdo             DECIMAL(18,2);
    DEFINE viva_int_moratorios      DECIMAL(18,2);
    DEFINE viva_int_mes             DECIMAL(18,2);
    DEFINE vsdo_act_total_iva       DECIMAL(18,2);
    DEFINE vcom_pend                DECIMAL(18,2);
    DEFINE viva_com                 DECIMAL(18,2);
    DEFINE vsdo_retenido            DECIMAL(18,2);
    DEFINE vtotal_liquidacion       DECIMAL(18,2);
    DEFINE vint_devengado           DECIMAL(18,2);
    DEFINE viva_int_devengado       DECIMAL(18,2);
    DEFINE vlinea_disponible        DECIMAL(18,2);
    DEFINE vpagos_vdos              DECIMAL(18,2);
    DEFINE vdesc_status_cred        CHAR(60);
    DEFINE vid_bloqueo_cred         INTEGER;
    DEFINE vbloqueo_cta             CHAR(60);
    DEFINE vid_causa_bloqueo_cred   CHAR(3);
    DEFINE vcausa_bloqueo_cta       CHAR(50);
    DEFINE vid_sit_esp_cte          CHAR(1);
    DEFINE vid_causa_esp_cte        INTEGER;
    DEFINE vsit_esp_cte             CHAR(75);
    DEFINE vid_sit_esp_cred         CHAR(1);
    DEFINE vid_causa_esp_cred       INTEGER;
    DEFINE vsit_esp_cred            CHAR(75);
    DEFINE vSdoDisp                 DECIMAL(18,2);
    DEFINE vPagoNoInt               MONEY(16,2);
    DEFINE vPagoMin                 MONEY(16,2);
    DEFINE vFechLimPago             DATE;
    DEFINE vSecMax                  INTEGER;
    DEFINE vstatus_cred             CHAR(2);
    DEFINE vCodRetSdoCorte          CHAR(5);
    DEFINE vSdoNoGenInt             DECIMAL(18,2);

    -- RQM 09 704. Se agregan las variables para el retorno de consulta de saldo. LEOC.
    DEFINE cCodRetConsSdo               CHAR(5);    -- Codigo de retorno de SP de consulta de saldo.
    DEFINE cMensajeRetConsSdo           CHAR(50);   -- Mensaje de retorno de SP de consulta de saldo.
    DEFINE mSdoActual                   MONEY(14,2);    DEFINE mSdoRetenido                 MONEY(14,2);    DEFINE mSdoCong                     MONEY(14,2);    DEFINE mImpChqSbg                   MONEY(14,2);    DEFINE mSaldoSbc                    MONEY(14,2);    
    LET Sql_Err	 = 0;
    LET Isam_Err = 0;
    LET Desc_Err = '';
    LET vCodRet1 = '00000';
    LET vCodRet2 = '00000';
    LET vCodRet3 = '';  
    
    LET vTipoCta1     = '';
    LET vCuenta1      = '';
    LET vSdoDisp1     = 0.00;
    LET vPagoNoInt1   = 0.00;
    LET vPagoMin1     = 0.00;
    LET vFechLimPago1 = '';
    
    LET vTipoCta2     = '';
    LET vCuenta2      = '';
    LET vSdoDisp2     = 0.00;
    LET vPagoNoInt2   = 0.00;
    LET vPagoMin2     = 0.00;
    LET vFechLimPago2 = '';
    
    LET vTipoCta3     = '';
    LET vCuenta3      = '';
    LET vSdoDisp3     = 0.00;
    LET vPagoNoInt3   = 0.00;
    LET vPagoMin3     = 0.00;
    LET vFechLimPago3 = '';
    
    LET vTipoCta4     = '';
    LET vCuenta4      = '';
    LET vSdoDisp4     = 0.00;
    LET vPagoNoInt4   = 0.00;
    LET vPagoMin4     = 0.00;
    LET vFechLimPago4 = '';
    
    LET vTipoCta5     = '';
    LET vCuenta5      = '';
    LET vSdoDisp5     = 0.00;
    LET vPagoNoInt5   = 0.00;
    LET vPagoMin5     = 0.00;
    LET vFechLimPago5 = '';
    
    LET vTipoCta6     = '';
    LET vCuenta6      = '';
    LET vSdoDisp6     = 0.00;
    LET vPagoNoInt6   = 0.00;
    LET vPagoMin6     = 0.00;
    LET vFechLimPago6 = '';
    
    LET vTipoCta7     = '';
    LET vCuenta7      = '';
    LET vSdoDisp7     = 0.00;
    LET vPagoNoInt7   = 0.00;
    LET vPagoMin7     = 0.00;
    LET vFechLimPago7 = '';
    
    LET vTipoCta8     = '';
    LET vCuenta8      = '';
    LET vSdoDisp8     = 0.00;
    LET vPagoNoInt8   = 0.00;
    LET vPagoMin8     = 0.00;
    LET vFechLimPago8 = '';
    
    LET vTipoCta9     = '';
    LET vCuenta9      = '';
    LET vSdoDisp9     = 0.00;
    LET vPagoNoInt9   = 0.00;
    LET vPagoMin9     = 0.00;
    LET vFechLimPago9 = '';
    
    LET vTipoCta10     = '';
    LET vCuenta10      = '';
    LET vSdoDisp10     = 0.00;
    LET vPagoNoInt10   = 0.00;
    LET vPagoMin10     = 0.00;
    LET vFechLimPago10 = '';
    
    LET vcTelefono       = '';
    LET vcNumCliente     = '';
    LET vcStatusCte      = '';
    LET vcCuenta         = '';
    LET vcCredito        = '';
    LET viExisMasCtas    = 0.00;
    LET viExisMasCrds    = 0.00;
    LET viExisMasCrds2   = 0.00;
    LET vcont            = 0;
    LET vnum_credito     = '';
    LET vnum_tarjeta     = '';
    LET vcuenta          = '';
    LET vcTarjeta        = '';
    
    LET vcodret_dat      = '';
    LET vmensaje_dat     = '';
    LET vnum_credito_dat = '';
    LET vnumcte_dat      = '';
    LET vnombre_prod_dat = '';
    LET vnum_tarjeta_dat = '';
    LET vcliente_dat     = '';
    
    LET vcodret_sdos           = '';
    LET vmensaje_sdos          = '';
    LET vnumcredito            = '';
    LET vcodigo_tipcred        = '';
    LET vfecha_origen          = '';
    LET vfecha_prox_pago       = '';
    LET vpago_minimo           = 0;
    LET vfecha_ult_pago        = '';
    LET vplazo                 = 0;
    LET vpagos_realizados      = 0;
    LET vlinea_otorgada        = 0;
    LET vtasa_interes          = 0;
    LET vtasa_moratorios       = 0;
    LET vmonto_sbc             = 0;
    LET vcap_vig               = 0;
    LET vcap_trans             = 0;
    LET vcap_vdo_exig          = 0;
    LET vcap_vdo_no_exig       = 0;
    LET vsdo_act_total_cap     = 0;
    LET vint_vig               = 0;
    LET vint_vdo               = 0;
    LET vint_moratorios        = 0;
    LET vint_mes               = 0;
    LET vsdo_act_total_int     = 0;
    LET viva_int_vig           = 0;
    LET viva_int_vdo           = 0;
    LET viva_int_moratorios    = 0;
    LET viva_int_mes           = 0;
    LET vsdo_act_total_iva     = 0;
    LET vcom_pend              = 0;
    LET viva_com               = 0;
    LET vsdo_retenido          = 0;
    LET vtotal_liquidacion     = 0;
    LET vint_devengado         = 0;
    LET viva_int_devengado     = 0;
    LET vlinea_disponible      = 0;
    LET vpagos_vdos            = 0;
    LET vdesc_status_cred      = '';
    LET vid_bloqueo_cred       = 0;
    LET vbloqueo_cta           = '';
    LET vid_causa_bloqueo_cred = '';
    LET vcausa_bloqueo_cta     = '';
    LET vid_sit_esp_cte        = '';
    LET vid_causa_esp_cte      = 0;
    LET vsit_esp_cte           = '';
    LET vid_sit_esp_cred       = '';
    LET vid_causa_esp_cred     = 0;
    LET vsit_esp_cred          = '';
    LET vSdoDisp               = 0;
    LET vPagoNoInt             = 0.00;
    LET vPagoMin               = 0.00;
    LET vFechLimPago           = '';
    LET vSecMax                = 0;
    LET vstatus_cred           = '';
    LET vCodRetSdoCorte        = '';
    LET vSdoNoGenInt           = 0.00;

    -- RQM 09 704. Se inicializan las variables para el retorno de consulta de saldo. LEOC.
    LET cCodRetConsSdo               = '00000';
    LET cMensajeRetConsSdo           = '';
    LET mSdoActual                   = 0.00;
    LET mSdoRetenido                 = 0.00;
    LET mSdoCong                     = 0.00;
    LET mImpChqSbg                   = 0.00;
    LET mSaldoSbc                    = 0.00;
    
    BEGIN

    ON EXCEPTION SET Sql_Err, Isam_Err, Desc_Err
        --- SET DEBUG FILE TO "/resplogifx/conciliachq/ivr_saldo_otra_cuenta.err";
        --- TRACE ON;
        IF Sql_Err <> 0 THEN
            LET vCodRet1 = Sql_Err;
            LET vCodRet2 = Isam_Err;
            LET vCodRet3 = Desc_Err;
            RETURN vCodRet1, 
                   vTipoCta1,  vCuenta1,  vSdoDisp1,  vPagoNoInt1,  vPagoMin1,  vFechLimPago1,
                   vTipoCta2,  vCuenta2,  vSdoDisp2,  vPagoNoInt2,  vPagoMin2,  vFechLimPago2,
                   vTipoCta3,  vCuenta3,  vSdoDisp3,  vPagoNoInt3,  vPagoMin3,  vFechLimPago3,
                   vTipoCta4,  vCuenta4,  vSdoDisp4,  vPagoNoInt4,  vPagoMin4,  vFechLimPago4,
                   vTipoCta5,  vCuenta5,  vSdoDisp5,  vPagoNoInt5,  vPagoMin5,  vFechLimPago5,
                   vTipoCta6,  vCuenta6,  vSdoDisp6,  vPagoNoInt6,  vPagoMin6,  vFechLimPago6,
                   vTipoCta7,  vCuenta7,  vSdoDisp7,  vPagoNoInt7,  vPagoMin7,  vFechLimPago7,
                   vTipoCta8,  vCuenta8,  vSdoDisp8,  vPagoNoInt8,  vPagoMin8,  vFechLimPago8,
                   vTipoCta9,  vCuenta9,  vSdoDisp9,  vPagoNoInt9,  vPagoMin9,  vFechLimPago9,
                   vTipoCta10, vCuenta10, vSdoDisp10, vPagoNoInt10, vPagoMin10, vFechLimPago10;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/ivr_saldo_otra_cuenta.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF ( pTarjeta is null OR pTarjeta = '' ) THEN
        LET vCodRet1 = '00017';
        RETURN vCodRet1, 
               vTipoCta1,  vCuenta1,  vSdoDisp1,  vPagoNoInt1,  vPagoMin1,  vFechLimPago1,
               vTipoCta2,  vCuenta2,  vSdoDisp2,  vPagoNoInt2,  vPagoMin2,  vFechLimPago2,
               vTipoCta3,  vCuenta3,  vSdoDisp3,  vPagoNoInt3,  vPagoMin3,  vFechLimPago3,
               vTipoCta4,  vCuenta4,  vSdoDisp4,  vPagoNoInt4,  vPagoMin4,  vFechLimPago4,
               vTipoCta5,  vCuenta5,  vSdoDisp5,  vPagoNoInt5,  vPagoMin5,  vFechLimPago5,
               vTipoCta6,  vCuenta6,  vSdoDisp6,  vPagoNoInt6,  vPagoMin6,  vFechLimPago6,
               vTipoCta7,  vCuenta7,  vSdoDisp7,  vPagoNoInt7,  vPagoMin7,  vFechLimPago7,
               vTipoCta8,  vCuenta8,  vSdoDisp8,  vPagoNoInt8,  vPagoMin8,  vFechLimPago8,
               vTipoCta9,  vCuenta9,  vSdoDisp9,  vPagoNoInt9,  vPagoMin9,  vFechLimPago9,
               vTipoCta10, vCuenta10, vSdoDisp10, vPagoNoInt10, vPagoMin10, vFechLimPago10;
    END IF;
    
    -- // VERIFICA SI LA TARJETA ES DE DEBITO O CREDITO
    SELECT NVL(tar.num_tarjeta, ' '), tar.cuenta, tar.numcte
      INTO vcTarjeta, vcCuenta, vcNumCliente
      FROM bdicheq:"informix".sc_tarjeta tar,
           bdicheq:"informix".sc_maechq chq
     WHERE tar.empresa = chq.empresa
       AND tar.num_tarjeta = pTarjeta
       AND tar.tipo_tarjeta = 'T'
       AND tar.status_tar = 'A'
       AND chq.cuenta = tar.cuenta
       AND chq.num_cte = tar.numcte;
       
    IF vcTarjeta is null OR vcTarjeta = '' OR vcTarjeta = ' ' OR vcTarjeta <> pTarjeta THEN
        SELECT NVL(tar.num_tarjeta, ' '), tar.num_credito, tar.numcte
          INTO vcTarjeta, vcCredito, vcNumCliente
          FROM bdicred:"informix".sd_tarjeta tar,
               bdicred:"informix".sd_maecred crd
         WHERE tar.empresa = crd.empresa
           AND tar.num_tarjeta = pTarjeta
           AND tar.tipo_tarjeta = 'T'
           AND tar.status_tar = 'A'
           AND crd.num_credito = tar.num_credito
           AND crd.numcte = tar.numcte;
        
        IF vcTarjeta is null OR vcTarjeta = '' OR vcTarjeta = ' ' OR vcTarjeta <> pTarjeta THEN
            LET vCodRet1 = '00013';
            RETURN vCodRet1, 
                   vTipoCta1,  vCuenta1,  vSdoDisp1,  vPagoNoInt1,  vPagoMin1,  vFechLimPago1,
                   vTipoCta2,  vCuenta2,  vSdoDisp2,  vPagoNoInt2,  vPagoMin2,  vFechLimPago2,
                   vTipoCta3,  vCuenta3,  vSdoDisp3,  vPagoNoInt3,  vPagoMin3,  vFechLimPago3,
                   vTipoCta4,  vCuenta4,  vSdoDisp4,  vPagoNoInt4,  vPagoMin4,  vFechLimPago4,
                   vTipoCta5,  vCuenta5,  vSdoDisp5,  vPagoNoInt5,  vPagoMin5,  vFechLimPago5,
                   vTipoCta6,  vCuenta6,  vSdoDisp6,  vPagoNoInt6,  vPagoMin6,  vFechLimPago6,
                   vTipoCta7,  vCuenta7,  vSdoDisp7,  vPagoNoInt7,  vPagoMin7,  vFechLimPago7,
                   vTipoCta8,  vCuenta8,  vSdoDisp8,  vPagoNoInt8,  vPagoMin8,  vFechLimPago8,
                   vTipoCta9,  vCuenta9,  vSdoDisp9,  vPagoNoInt9,  vPagoMin9,  vFechLimPago9,
                   vTipoCta10, vCuenta10, vSdoDisp10, vPagoNoInt10, vPagoMin10, vFechLimPago10;
        END IF;
    END IF;
    
    IF vcCuenta is null OR vcCuenta = '' OR vcCuenta = ' ' THEN
        LET vcCuenta = '10000000000';
    END IF;
    
    IF vcCredito is null OR vcCredito = '' OR vcCredito = ' ' THEN
        LET vcCredito = '600000000000';
    END IF;
    
    -- // VERIFICA SI EL CLIENTE EXISTE EN TABLA DE CLIENTES IVR
    SELECT NVL(telefono, ' '), status_cte
      INTO vcTelefono, vcStatusCte
      FROM bdinteg:"informix".si_cliente_ivr 
     WHERE numcte = vcNumCliente;
     
    IF vcTelefono is null OR vcTelefono = '' OR vcTelefono = ' ' THEN
        LET vCodRet1 = '00015';
        RETURN vCodRet1, 
               vTipoCta1,  vCuenta1,  vSdoDisp1,  vPagoNoInt1,  vPagoMin1,  vFechLimPago1,
               vTipoCta2,  vCuenta2,  vSdoDisp2,  vPagoNoInt2,  vPagoMin2,  vFechLimPago2,
               vTipoCta3,  vCuenta3,  vSdoDisp3,  vPagoNoInt3,  vPagoMin3,  vFechLimPago3,
               vTipoCta4,  vCuenta4,  vSdoDisp4,  vPagoNoInt4,  vPagoMin4,  vFechLimPago4,
               vTipoCta5,  vCuenta5,  vSdoDisp5,  vPagoNoInt5,  vPagoMin5,  vFechLimPago5,
               vTipoCta6,  vCuenta6,  vSdoDisp6,  vPagoNoInt6,  vPagoMin6,  vFechLimPago6,
               vTipoCta7,  vCuenta7,  vSdoDisp7,  vPagoNoInt7,  vPagoMin7,  vFechLimPago7,
               vTipoCta8,  vCuenta8,  vSdoDisp8,  vPagoNoInt8,  vPagoMin8,  vFechLimPago8,
               vTipoCta9,  vCuenta9,  vSdoDisp9,  vPagoNoInt9,  vPagoMin9,  vFechLimPago9,
               vTipoCta10, vCuenta10, vSdoDisp10, vPagoNoInt10, vPagoMin10, vFechLimPago10;
    END IF;
    
    IF vcStatusCte <> 'A' THEN
        LET vCodRet1 = '00016';
        RETURN vCodRet1, 
               vTipoCta1,  vCuenta1,  vSdoDisp1,  vPagoNoInt1,  vPagoMin1,  vFechLimPago1,
               vTipoCta2,  vCuenta2,  vSdoDisp2,  vPagoNoInt2,  vPagoMin2,  vFechLimPago2,
               vTipoCta3,  vCuenta3,  vSdoDisp3,  vPagoNoInt3,  vPagoMin3,  vFechLimPago3,
               vTipoCta4,  vCuenta4,  vSdoDisp4,  vPagoNoInt4,  vPagoMin4,  vFechLimPago4,
               vTipoCta5,  vCuenta5,  vSdoDisp5,  vPagoNoInt5,  vPagoMin5,  vFechLimPago5,
               vTipoCta6,  vCuenta6,  vSdoDisp6,  vPagoNoInt6,  vPagoMin6,  vFechLimPago6,
               vTipoCta7,  vCuenta7,  vSdoDisp7,  vPagoNoInt7,  vPagoMin7,  vFechLimPago7,
               vTipoCta8,  vCuenta8,  vSdoDisp8,  vPagoNoInt8,  vPagoMin8,  vFechLimPago8,
               vTipoCta9,  vCuenta9,  vSdoDisp9,  vPagoNoInt9,  vPagoMin9,  vFechLimPago9,
               vTipoCta10, vCuenta10, vSdoDisp10, vPagoNoInt10, vPagoMin10, vFechLimPago10;
    END IF;
       
    -- // VERIFICA SI TIENE MAS CREDITOS VIGENTES
    SELECT COUNT(*)
      INTO viExisMasCrds
      FROM bdicred:"informix".sd_maecred
     WHERE numcte = vcNumCliente
       AND status_cred IN('AA','BA','BT','E1','E2','E3')
       AND num_credito <> vcCredito
       AND num_producto NOT IN(SELECT producto FROM bdinteg:"informix".si_prodinval_ivr);
    
    SELECT COUNT(*)
      INTO viExisMasCrds2
      FROM bdicred:"informix".sd_maecredcrd
     WHERE numcte = vcNumCliente
       AND status_cred IN('AA','BA','BT','VP','E1','E2','E3')
       AND num_credito <> vcCredito
       AND num_producto NOT IN(SELECT producto FROM bdinteg:"informix".si_prodinval_ivr);
       
    IF viExisMasCrds > 0 OR viExisMasCrds2 > 0 THEN
    
        LET vcont = 1;
    
        FOREACH
            SELECT num_credito
              INTO vnum_credito_dat
              FROM bdicred:"informix".sd_maecred
             WHERE numcte = vcNumCliente
               AND status_cred IN('AA','BA','BT','VP','E1','E2','E3' )
               AND num_credito <> vcCredito
               AND num_producto NOT IN(SELECT producto FROM bdinteg:"informix".si_prodinval_ivr)
            UNION
            SELECT num_credito
              FROM bdicred:"informix".sd_maecredcrd
             WHERE numcte = vcNumCliente
               AND status_cred IN('AA','BA','BT','VP','E1','E2','E3')
               AND num_credito <> vcCredito
               AND num_producto NOT IN(SELECT producto FROM bdinteg:"informix".si_prodinval_ivr)
        
            EXECUTE PROCEDURE bdicred:"informix".sp_consulta_datos_general('001', vcNumCliente, vnum_credito_dat, '', '', '', '')
            INTO vcodret_dat, vmensaje_dat, vnum_credito_dat, vnumcte_dat, vnombre_prod_dat, vnum_tarjeta_dat, vcliente_dat;
            
            IF vcodret_dat <> '000000' OR vnum_credito_dat is null OR vnum_credito_dat = '' OR vnum_tarjeta_dat = pTarjeta THEN 
                CONTINUE FOREACH;
            END IF;
            
            -- // OBTIENE EL NUMERO DE TARJETA O CREDITO
            LET vnum_credito = vnum_credito_dat;
            LET vnum_tarjeta = vnum_tarjeta_dat;
            
            IF vnum_tarjeta is null OR vnum_tarjeta = '' THEN
                LET vnum_tarjeta = vnum_credito;
            END IF;
            
            -- // OBTIENE LOS SALDOS DEL CREDITO 
            EXECUTE PROCEDURE bdicred:"informix".sp_consulta_saldos_general('001', vnum_credito)
            INTO vcodret_sdos, vmensaje_sdos, vnumcredito, vcodigo_tipcred, vfecha_origen, vfecha_prox_pago, 
                 vpago_minimo, vfecha_ult_pago, vplazo, vpagos_realizados, vlinea_otorgada, vtasa_interes,
                 vtasa_moratorios, vmonto_sbc, vcap_vig, vcap_trans, vcap_vdo_exig, vcap_vdo_no_exig, vsdo_act_total_cap,
                 vint_vig, vint_vdo, vint_moratorios, vint_mes, vsdo_act_total_int, viva_int_vig, viva_int_vdo, viva_int_moratorios,
                 viva_int_mes, vsdo_act_total_iva, vcom_pend, viva_com, vsdo_retenido, vtotal_liquidacion, vint_devengado, viva_int_devengado, 
                 vlinea_disponible, vpagos_vdos, vdesc_status_cred, vid_bloqueo_cred, vbloqueo_cta, vid_causa_bloqueo_cred, vcausa_bloqueo_cta, 
                 vid_sit_esp_cte, vid_causa_esp_cte, vsit_esp_cte, vid_sit_esp_cred, vid_causa_esp_cred, vsit_esp_cred;
                     
            -- // SALDO DISPONIBLE AL DIA DE HOY
            LET vSdoDisp = vtotal_liquidacion;
            
            IF vSdoDisp is null OR vSdoDisp < 0.00 THEN 
                LET vSdoDisp = 0.00; 
            END IF;
            
            -- // PAGO PARA NO GENERAR INTERESES
            EXECUTE PROCEDURE bdicred:"informix".sp_consultasaldocorte('001', vnum_credito, 0)
            INTO vCodRetSdoCorte, vSdoNoGenInt;
            
            LET vPagoNoInt = vSdoNoGenInt;
            
            IF vPagoNoInt is null THEN 
                LET vPagoNoInt = 0.00; 
            END IF;
            
            -- // PAGO MINIMO
            LET vPagoMin = vpago_minimo;
            
            IF vPagoMin < 0 THEN 
                LET vPagoMin = 0.00; 
            END IF;
            
            -- // FECHA LIMITE DE PAGO 
            LET vFechLimPago = vfecha_prox_pago;
                             
            IF vcont = 1 THEN 
                LET vTipoCta1     = 'CR';
                LET vCuenta1      = SUBSTR(vnum_tarjeta, LENGTH(vnum_tarjeta) - 3, 4);
                LET vSdoDisp1     = vSdoDisp;
                LET vPagoNoInt1   = vPagoNoInt;
                LET vPagoMin1     = vPagoMin;
                LET vFechLimPago1 = vFechLimPago;
            ELIF vcont = 2 THEN
                LET vTipoCta2     = 'CR';
                LET vCuenta2      = SUBSTR(vnum_tarjeta, LENGTH(vnum_tarjeta) - 3, 4);
                LET vSdoDisp2     = vSdoDisp;
                LET vPagoNoInt2   = vPagoNoInt;
                LET vPagoMin2     = vPagoMin;
                LET vFechLimPago2 = vFechLimPago;
            ELIF vcont = 3 THEN
                LET vTipoCta3     = 'CR';
                LET vCuenta3      = SUBSTR(vnum_tarjeta, LENGTH(vnum_tarjeta) - 3, 4);
                LET vSdoDisp3     = vSdoDisp;
                LET vPagoNoInt3   = vPagoNoInt;
                LET vPagoMin3     = vPagoMin;
                LET vFechLimPago3 = vFechLimPago;
            ELIF vcont = 4 THEN
                LET vTipoCta4     = 'CR';
                LET vCuenta4      = SUBSTR(vnum_tarjeta, LENGTH(vnum_tarjeta) - 3, 4);
                LET vSdoDisp4     = vSdoDisp;
                LET vPagoNoInt4   = vPagoNoInt;
                LET vPagoMin4     = vPagoMin;
                LET vFechLimPago4 = vFechLimPago;
            ELIF vcont = 5 THEN
                LET vTipoCta5     = 'CR';
                LET vCuenta5      = SUBSTR(vnum_tarjeta, LENGTH(vnum_tarjeta) - 3, 4);
                LET vSdoDisp5     = vSdoDisp;
                LET vPagoNoInt5   = vPagoNoInt;
                LET vPagoMin5     = vPagoMin;
                LET vFechLimPago5 = vFechLimPago;
            ELIF vcont = 6 THEN
                LET vTipoCta6     = 'CR';
                LET vCuenta6      = SUBSTR(vnum_tarjeta, LENGTH(vnum_tarjeta) - 3, 4);
                LET vSdoDisp6     = vSdoDisp;
                LET vPagoNoInt6   = vPagoNoInt;
                LET vPagoMin6     = vPagoMin;
                LET vFechLimPago6 = vFechLimPago;
            ELIF vcont = 7 THEN
                LET vTipoCta7     = 'CR';
                LET vCuenta7      = SUBSTR(vnum_tarjeta, LENGTH(vnum_tarjeta) - 3, 4);
                LET vSdoDisp7     = vSdoDisp;
                LET vPagoNoInt7   = vPagoNoInt;
                LET vPagoMin7     = vPagoMin;
                LET vFechLimPago7 = vFechLimPago;
            ELIF vcont = 8 THEN
                LET vTipoCta8     = 'CR';
                LET vCuenta8      = SUBSTR(vnum_tarjeta, LENGTH(vnum_tarjeta) - 3, 4);
                LET vSdoDisp8     = vSdoDisp;
                LET vPagoNoInt8   = vPagoNoInt;
                LET vPagoMin8     = vPagoMin;
                LET vFechLimPago8 = vFechLimPago;
            ELIF vcont = 9 THEN
                LET vTipoCta9     = 'CR';
                LET vCuenta9      = SUBSTR(vnum_tarjeta, LENGTH(vnum_tarjeta) - 3, 4);
                LET vSdoDisp9     = vSdoDisp;
                LET vPagoNoInt9   = vPagoNoInt;
                LET vPagoMin9     = vPagoMin;
                LET vFechLimPago9 = vFechLimPago;
            ELIF vcont = 10 THEN
                LET vTipoCta10     = 'CR';
                LET vCuenta10      = SUBSTR(vnum_tarjeta, LENGTH(vnum_tarjeta) - 3, 4);
                LET vSdoDisp10     = vSdoDisp;
                LET vPagoNoInt10   = vPagoNoInt;
                LET vPagoMin10     = vPagoMin;
                LET vFechLimPago10 = vFechLimPago;       
            END IF;
            
            LET vcont = vcont + 1;
            
            IF vcont > 10 THEN
                EXIT FOREACH;
            END IF;

        END FOREACH;
        
    END IF;
    
    -- // VERIFICA SI EL CLIENTE TIENE MAS CUENTAS DE DEBITO 
    SELECT COUNT(*)
      INTO viExisMasCtas
      FROM bdicheq:"informix".sc_maechq
     WHERE empresa = '001'
       AND num_cte = vcNumCliente
       AND status_cta IN('1','4','5')
       AND cuenta <> vcCuenta
       AND producto NOT IN(SELECT producto FROM bdinteg:"informix".si_prodinval_ivr);
       
    IF viExisMasCtas > 0 THEN
    
        IF vcont = 0 THEN
            LET vcont = 1;
        ELSE
            LET vcont = vcont;
        END IF;
        
        FOREACH
           -- SELECT mae.cuenta, mae.sdo_actual - (sdo_retenido + sdo_cong + imp_chq_sbg)
              -- INTO vcuenta, vSdoDisp
           SELECT mae.cuenta, mae.sdo_actual, mae.sdo_retenido, mae.sdo_cong, mae.imp_chq_sbg, mae.saldo_sbc
              INTO vcuenta, mSdoActual, mSdoRetenido, mSdoCong, mImpChqSbg, mSaldoSbc
              FROM bdicheq:"informix".sc_maechq mae
             WHERE mae.num_cte = vcNumCliente
               AND mae.status_cta <> '2'
               AND mae.cuenta <> vcCuenta
               AND producto NOT IN(SELECT producto FROM bdinteg:"informix".si_prodinval_ivr)
             ORDER BY 2 DESC

           -- RQM 09 704. Se agrega el llamado al SP de consulta de saldo con el tipo de calculo requerido para esta operacion. LEOC
           EXECUTE PROCEDURE bdicheq:"informix".sp_cons_sdodisp_x_tpcalculo(NULL, mSdoActual, mSdoRetenido, mSdoCong, mSaldoSbc, mImpChqSbg, NULL, NULL, 'F', 1) INTO cCodRetConsSdo,cMensajeRetConsSdo,vSdoDisp;
             
            SELECT num_tarjeta
              INTO vnum_tarjeta
              FROM bdicheq:"informix".sc_tarjeta
             WHERE empresa = '001'
               AND cuenta = vcuenta
               AND status_tar = 'A'
               AND tipo_tarjeta = 'P';
               
            IF vnum_tarjeta is null OR vnum_tarjeta = '' THEN
                LET vnum_tarjeta = vcuenta;
            END IF;
             
            IF vcont = 1 THEN
                LET vTipoCta1     = 'DB';
                LET vCuenta1      = SUBSTR(vnum_tarjeta, LENGTH(vnum_tarjeta) - 3, 4);
                LET vSdoDisp1     = vSdoDisp;
                LET vPagoNoInt1   = 0.00;
                LET vPagoMin1     = 0.00;
                LET vFechLimPago1 = '';
            ELIF vcont = 2 THEN
                LET vTipoCta2     = 'DB';
                LET vCuenta2      = SUBSTR(vnum_tarjeta, LENGTH(vnum_tarjeta) - 3, 4);
                LET vSdoDisp2     = vSdoDisp;
                LET vPagoNoInt2   = 0.00;
                LET vPagoMin2     = 0.00;
                LET vFechLimPago2 = '';
            ELIF vcont = 3 THEN
                LET vTipoCta3     = 'DB';
                LET vCuenta3      = SUBSTR(vnum_tarjeta, LENGTH(vnum_tarjeta) - 3, 4);
                LET vSdoDisp3     = vSdoDisp;
                LET vPagoNoInt3   = 0.00;
                LET vPagoMin3     = 0.00;
                LET vFechLimPago3 = '';
            ELIF vcont = 4 THEN
                LET vTipoCta4     = 'DB';
                LET vCuenta4      = SUBSTR(vnum_tarjeta, LENGTH(vnum_tarjeta) - 3, 4);
                LET vSdoDisp4     = vSdoDisp;
                LET vPagoNoInt4   = 0.00;
                LET vPagoMin4     = 0.00;
                LET vFechLimPago4 = '';
            ELIF vcont = 5 THEN
                LET vTipoCta5     = 'DB';
                LET vCuenta5      = SUBSTR(vnum_tarjeta, LENGTH(vnum_tarjeta) - 3, 4);
                LET vSdoDisp5     = vSdoDisp;
                LET vPagoNoInt5   = 0.00;
                LET vPagoMin5     = 0.00;
                LET vFechLimPago5 = '';
            ELIF vcont = 6 THEN
                LET vTipoCta6     = 'DB';
                LET vCuenta6      = SUBSTR(vnum_tarjeta, LENGTH(vnum_tarjeta) - 3, 4);
                LET vSdoDisp6     = vSdoDisp;
                LET vPagoNoInt6   = 0.00;
                LET vPagoMin6     = 0.00;
                LET vFechLimPago6 = '';
            ELIF vcont = 7 THEN
                LET vTipoCta7     = 'DB';
                LET vCuenta7      = SUBSTR(vnum_tarjeta, LENGTH(vnum_tarjeta) - 3, 4);
                LET vSdoDisp7     = vSdoDisp;
                LET vPagoNoInt7   = 0.00;
                LET vPagoMin7     = 0.00;
                LET vFechLimPago7 = '';
            ELIF vcont = 8 THEN
                LET vTipoCta8     = 'DB';
                LET vCuenta8      = SUBSTR(vnum_tarjeta, LENGTH(vnum_tarjeta) - 3, 4);
                LET vSdoDisp8     = vSdoDisp;
                LET vPagoNoInt8   = 0.00;
                LET vPagoMin8     = 0.00;
                LET vFechLimPago8 = '';
            ELIF vcont = 9 THEN
                LET vTipoCta9     = 'DB';
                LET vCuenta9      = SUBSTR(vnum_tarjeta, LENGTH(vnum_tarjeta) - 3, 4);
                LET vSdoDisp9     = vSdoDisp;
                LET vPagoNoInt9   = 0.00;
                LET vPagoMin9     = 0.00;
                LET vFechLimPago9 = '';
            ELIF vcont = 10 THEN
                LET vTipoCta10     = 'DB';
                LET vCuenta10      = SUBSTR(vnum_tarjeta, LENGTH(vnum_tarjeta) - 3, 4);
                LET vSdoDisp10     = vSdoDisp;
                LET vPagoNoInt10   = 0.00;
                LET vPagoMin10     = 0.00;
                LET vFechLimPago10 = ''; 
            END IF;
            
            LET vcont = vcont + 1;
            
            IF vcont > 10 THEN
                EXIT FOREACH;
            END IF;

        END FOREACH;
    
    END IF;
    
    -- // GUARDA REGISTRO EN BITACORA
    SELECT MAX(secuencia)
      INTO vSecMax
      FROM bdinteg:"informix".si_bitacora_ivr
     WHERE DATE(fecha_oper) = CURRENT::DATE
       AND numcte = vcNumCliente;
       
    IF vSecMax is null THEN
        LET vSecMax = 0;
    END IF;
    
    LET vSecMax = vSecMax + 1;
    
    INSERT INTO bdinteg:"informix".si_bitacora_ivr VALUES
    ( current, vSecMax, 'OBT_SDO_OTRCTAS', pTarjeta, vcNumCliente, vcTelefono );
    
    END;
    
    RETURN vCodRet1, 
           vTipoCta1,  vCuenta1,  vSdoDisp1,  vPagoNoInt1,  vPagoMin1,  vFechLimPago1,
           vTipoCta2,  vCuenta2,  vSdoDisp2,  vPagoNoInt2,  vPagoMin2,  vFechLimPago2,
           vTipoCta3,  vCuenta3,  vSdoDisp3,  vPagoNoInt3,  vPagoMin3,  vFechLimPago3,
           vTipoCta4,  vCuenta4,  vSdoDisp4,  vPagoNoInt4,  vPagoMin4,  vFechLimPago4,
           vTipoCta5,  vCuenta5,  vSdoDisp5,  vPagoNoInt5,  vPagoMin5,  vFechLimPago5,
           vTipoCta6,  vCuenta6,  vSdoDisp6,  vPagoNoInt6,  vPagoMin6,  vFechLimPago6,
           vTipoCta7,  vCuenta7,  vSdoDisp7,  vPagoNoInt7,  vPagoMin7,  vFechLimPago7,
           vTipoCta8,  vCuenta8,  vSdoDisp8,  vPagoNoInt8,  vPagoMin8,  vFechLimPago8,
           vTipoCta9,  vCuenta9,  vSdoDisp9,  vPagoNoInt9,  vPagoMin9,  vFechLimPago9,
           vTipoCta10, vCuenta10, vSdoDisp10, vPagoNoInt10, vPagoMin10, vFechLimPago10;
    
END PROCEDURE
DOCUMENT
'AUTOR      : N/A',
'BD         : BDIVVR',
'--------------------------------------',
'MODIFICO   : Luis Enrique Orozco Cosme',
'FECHA      : 7 de julio de 2025',
'MODIFICACION: Se modifica el calculo de saldo disponible para homologarlo con el llamado a un nuevo spl sp_cons_sdodisp_x_tpcalculo',
'PROYECTO   : RQM 09 704 Cobranza Automatica en Cuentas de Captacion',
'BD         : BDIVR',
'VERSION    : 1.0.1';

CREATE PROCEDURE "informix".sp_ivr_depura_cliente_iccat(p_Periodo INT, p_Bloque INT)
RETURNING CHAR(5) AS CodRet,-- CÃDIGO DE RETORNO
          CHAR(12)AS Registros; --REGISTROS

-- DECLARACIÃN DE VARIABLES
DEFINE error_sql 			INTEGER;
DEFINE vcodret				VARCHAR(5);
DEFINE i_count 				INT;
DEFINE d_inicio 			DATE;
DEFINE v_id_row             INT;
DEFINE vregistros           INT; 

-- INICIALIZACIÃN DE VARIABLES
LET vcodret = '00000';
LET vregistros = 0;

-- SET DEBUG FILE TO "/tmp/misael/sp_ivr_depura_cliente_iccat.out";
-- TRACE ON;

BEGIN
    ON EXCEPTION SET error_sql
        IF error_sql != 0 THEN
            LET vcodret = error_sql;
            RETURN vcodret, 0;
        END IF;

        IF EXISTS(SELECT 1 FROM tmp_si_cliente_iccat) THEN
            DROP TABLE tmp_si_cliente_iccat;
        END IF;
    END EXCEPTION;
        
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

    IF p_Periodo <> 0 AND p_Bloque <> 0 THEN 
    
        CREATE TEMP TABLE tmp_si_cliente_iccat (
        id serial) WITH NO LOG;
        CREATE INDEX idx_tmp_si_cliente_iccat ON tmp_si_cliente_iccat (id);

        LET d_inicio = TODAY - p_Periodo UNITS day;

        INSERT INTO tmp_si_cliente_iccat (id)
        SELECT {+INDEX(bdivr:"informix".si_cliente_iccat idx_si_cliente_iccat)} FIRST p_Bloque id 
        FROM bdivr:si_cliente_iccat
        WHERE fecha <= d_inicio;            

        IF DBINFO('sqlca.sqlerrd2') > 0 THEN
            DELETE FROM bdivr:si_cliente_iccat
            WHERE id IN (SELECT id FROM tmp_si_cliente_iccat);
        END IF;
        DROP TABLE tmp_si_cliente_iccat;

        SELECT {+INDEX(bdivr:"informix".si_cliente_iccat idx_si_cliente_iccat)} COUNT (*) 
        INTO vregistros
        FROM bdivr:si_cliente_iccat
        WHERE fecha <= d_inicio;

    ELSE
       LET vcodret = '00001'; --Falta de parametros 
    END IF;   
END;
RETURN vcodret,vregistros;
END PROCEDURE;
CREATE PROCEDURE "informix".cons_pago_minimo_no_interes_pba( pc_costos CHAR(4), pusuario CHAR(8), pfolio CHAR(16), pnum_tarjeta CHAR(16) )
RETURNING CHAR(3), CHAR(16), CHAR(16);
    
	DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE desc_err         CHAR(50);
    DEFINE vcodret          CHAR(3);
	DEFINE vcodret1         CHAR(5);
    DEFINE vcodret2         CHAR(5);
    DEFINE vcodret3         CHAR(50);
	
	DEFINE vtarjeta         		CHAR(16);
    DEFINE vnum_credito     		CHAR(20);
    DEFINE vstatus_tar      		CHAR(1);
	DEFINE vcodret_sdos             CHAR(6);
    DEFINE vmensaje_sdos            CHAR(80);
    DEFINE vnumcredito              CHAR(20);
    DEFINE vcodigo_tipcred          CHAR(2);
    DEFINE vfecha_origen            DATE;
    DEFINE vfecha_prox_pago         DATE;
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
    DEFINE vdpago_min               DECIMAL(14,2);
    DEFINE vdpago_nogenints         DECIMAL(14,2);
    DEFINE vipago_min               INTEGER;
    DEFINE vipago_nogenints         INTEGER;
    DEFINE vcpago_minimo            CHAR(16);
	DEFINE vcpago_nogenint			CHAR(16);
	
	LET sql_err	 = 0;
    LET isam_err = 0;
    LET desc_err = '';
    LET vcodret  = '000';
	LET vcodret1 = '';
    LET vcodret2 = '';
    LET vcodret3 = '';
	
	LET vtarjeta               = '';
    LET vnum_credito           = '';
    LET vstatus_tar            = '';
	LET vcodret_sdos           = '';
    LET vmensaje_sdos          = '';
    LET vnumcredito            = '';
    LET vcodigo_tipcred        = '';
    LET vfecha_origen          = '';
    LET vfecha_prox_pago       = '';
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
    LET vdpago_min             = 0.00;
    LET vdpago_nogenints       = 0.00;
    LET vipago_min             = 0;
    LET vipago_nogenints       = 0;
    LET vcpago_minimo          = ''; 	
	LET vcpago_nogenint        = ''; 
	
	BEGIN

    ON EXCEPTION SET sql_err, isam_err, desc_err
        --- SET DEBUG FILE TO "/resplogifx/conciliachq/cons_pago_minimo_no_interes.err";
        --- TRACE ON;
        IF sql_err <> 0 THEN
			LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
			LET vcodret  = '999';
            LET vcpago_minimo = '0'; 	
            LET vcpago_nogenint = '0'; 
            RETURN vcodret, vcpago_minimo, vcpago_nogenint;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/cons_pago_minimo_no_interes.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	IF (pc_costos is null OR pc_costos = '' OR LENGTH(pc_costos) <> 4) OR
       (pusuario is null OR pusuario = '' OR LENGTH(pusuario) <> 8) OR
       (pfolio is null OR pfolio = '' OR LENGTH(pfolio) <> 16) OR
       (pnum_tarjeta is null OR pnum_tarjeta = '' OR LENGTH(pnum_tarjeta) <> 16) THEN
        LET vcodret = '110';
        LET vcpago_minimo = '0'; 	
        LET vcpago_nogenint = '0'; 
        RETURN vcodret, vcpago_minimo, vcpago_nogenint;
    END IF;
	
	-- // VALIDA DATOS DEL CREDITO
    SELECT num_tarjeta, num_credito, status_tar
      INTO vtarjeta, vnum_credito, vstatus_tar
      FROM bdicred:sd_tarjeta
     WHERE num_tarjeta = pnum_tarjeta
       AND empresa = '001';
    
    IF vtarjeta is null THEN
        LET vtarjeta = ' ';
    END IF;
    
    IF vnum_credito is null THEN
        LET vnum_credito = ' ';
    END IF;
    
    IF vstatus_tar is null THEN
        LET vstatus_tar = ' ';
    END IF;
       
    IF (vtarjeta <> pnum_tarjeta) OR (vstatus_tar <> 'A')  THEN
        LET vcodret = '100';
        LET vcpago_minimo = '0'; 	
        LET vcpago_nogenint = '0';
        RETURN vcodret, vcpago_minimo, vcpago_nogenint;
    END IF;
    
    IF (vnum_credito is null OR vnum_credito = '') THEN
        LET vcodret = '100';
        LET vcpago_minimo = '0'; 	
        LET vcpago_nogenint = '0';
        RETURN vcodret, vcpago_minimo, vcpago_nogenint;
    END IF;
	
	-- // OBTIENE PAGO MINIMO DEL CREDITO 
	EXECUTE PROCEDURE bdicred:"informix".sp_consulta_saldos_general('001', vnum_credito)
	INTO vcodret_sdos, vmensaje_sdos, vnumcredito, vcodigo_tipcred, vfecha_origen, vfecha_prox_pago, 
		 vdpago_min, vfecha_ult_pago, vplazo, vpagos_realizados, vlinea_otorgada, vtasa_interes,
		 vtasa_moratorios, vmonto_sbc, vcap_vig, vcap_trans, vcap_vdo_exig, vcap_vdo_no_exig, vsdo_act_total_cap,
		 vint_vig, vint_vdo, vint_moratorios, vint_mes, vsdo_act_total_int, viva_int_vig, viva_int_vdo, viva_int_moratorios,
		 viva_int_mes, vsdo_act_total_iva, vcom_pend, viva_com, vsdo_retenido, vtotal_liquidacion, vint_devengado, viva_int_devengado, 
		 vlinea_disponible, vpagos_vdos, vdesc_status_cred, vid_bloqueo_cred, vbloqueo_cta, vid_causa_bloqueo_cred, vcausa_bloqueo_cta, 
		 vid_sit_esp_cte, vid_causa_esp_cte, vsit_esp_cte, vid_sit_esp_cred, vid_causa_esp_cred, vsit_esp_cred;
		 
	IF vdpago_min is null OR vdpago_min < 0 THEN 
		LET vdpago_min = 0; 
	END IF;
    
    LET vdpago_min    = ROUND(vdpago_min, 0);
    LET vipago_min    = vdpago_min;
    LET vcpago_minimo = vipago_min;	
    
    -- // OBTIENE PAGO PARA NO GENERAR INTERESES DEL CREDITO 
    EXECUTE PROCEDURE bdicred:"informix".sp_consultasaldocorte('001', vnum_credito, 0)
	INTO vCodRetSdoCorte, vdpago_nogenints;
	
	IF vdpago_nogenints is null OR vdpago_nogenints < 0 THEN 
		LET vdpago_nogenints = 0; 
	END IF;
    
    LET vdpago_nogenints = vdpago_nogenints + 0.49;
    LET vdpago_nogenints = ROUND(vdpago_nogenints, 0);
    LET vipago_nogenints = vdpago_nogenints;
    LET vcpago_nogenint  = vipago_nogenints;
	
	END;

    RETURN vcodret, vcpago_minimo, vcpago_nogenint;

END PROCEDURE;
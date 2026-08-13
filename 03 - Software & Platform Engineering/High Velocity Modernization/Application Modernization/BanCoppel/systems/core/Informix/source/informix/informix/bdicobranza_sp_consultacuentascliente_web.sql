CREATE PROCEDURE "informix".sp_consultacuentascliente_web(
                                            pEmpresa CHAR (3),
                                            pTipoBusqueda CHAR(1),  -- 1= por num cliente, 2= por num credito
                                            pNumero CHAR (20),
                                            pIndice CHAR (3),
                                            pFecha DATE
                                            )

RETURNING
            CHAR(5), --cod retorno
            CHAR(20), --numero de cliente
            CHAR(26), --apellido paterno
            CHAR(26), --apellido materno
            CHAR(26), --nombre1
            CHAR(26), --nombre2
            CHAR(20), --numero de la referencia cliente
            CHAR(13), --numero de telefono
            CHAR(20), --numero de credito
            CHAR(40), --descripcion del credito
            CHAR(30), --Situacion especial
            CHAR(30), --Causa
            CHAR(30), --Saldo actual
            CHAR(30), --Tipo convenio

            CHAR(30), --Numero de dias vencidos
            CHAR(30), --Numero de pagos vencidos
            CHAR(30), --Pago minimo vencido
            CHAR(30), --proximo pago por vencer
            CHAR(30), --fecha ultimo abono
            CHAR(30), --importe ultimo abono
            CHAR(30), --fecha ultimo convenio
            CHAR(30), --importe convenio
            CHAR(3), --cumplio convenio
            CHAR(3), --origen convenio
            DECIMAL(14,2) -- monto minimo a negociar; 


DEFINE v_codret char(5);
DEFINE v_numcte char(20);
DEFINE v_apaterno char (26);
DEFINE v_amaterno char (26);
DEFINE v_nombre1 char (26);
DEFINE v_nombre2 char (26);
DEFINE v_numcteref char(20);
DEFINE v_telefono char(13);
DEFINE v_numcredito char (20);
DEFINE v_descripcioncred char(40);
DEFINE v_situacionespecial char(30);
DEFINE v_causa char(30);
DEFINE v_saldoactual decimal (16,2);
DEFINE v_tipoconvenio char (30);

DEFINE v_numdiasvencidos char(30);
DEFINE v_numpagovencidos char(30);
DEFINE v_pagominvencido char(30);
DEFINE v_proxpagoporvencer char(30);
DEFINE v_fechaultabono char(30);
DEFINE v_importeultabono char(30);
DEFINE v_fechaultconvenio date;
DEFINE v_importeconvenio decimal(14);
DEFINE v_cumplioconvenio char(3);
DEFINE v_origenconvenio smallint;

DEFINE v_sqlerr integer;
DEFINE v_isamerr integer;

DEFINE v_Indice integer;
DEFINE v_num_producto char (4);
DEFINE v_fechaeimporteultabono char(125);
DEFINE v_codretvalidavencidos char (6);
DEFINE v_activo char (6);
DEFINE v_sucursal char (4);
DEFINE vPorcIva decimal (14);
DEFINE vIntMora decimal(14);
DEFINE vIvaIntMora decimal(14);
DEFINE vivacredito decimal(14);
DEFINE vinteresmes decimal(14);
DEFINE vivames decimal(14);
DEFINE vSdoDisponible decimal(14);
DEFINE vPagoMin decimal(14);
DEFINE vFechaCorte date;
DEFINE vFechaPago date;
DEFINE vDisponible decimal(14);
DEFINE vSdoRetenido decimal(14);
DEFINE vstatuscred char (4);
DEFINE vinteresvencido decimal(14);
DEFINE vmSumaAbono MONEY(18,2);

DEFINE cCodRet  				CHAR(6);
DEFINE dMtoNegociar 			DECIMAL(14,2);
DEFINE cCod_ret                 CHAR(6);
DEFINE cMensaje                 CHAR(80); 
DEFINE cNumCred                 CHAR(20);
DEFINE cTipCred                 CHAR(2);
DEFINE dtFecha_origen           DATE;
DEFINE dtfecha_prox_pago        DATE;
DEFINE dPago_minimo             DECIMAL(18,2);       
DEFINE dtFecha_ult_pago         DATE;
DEFINE iPlazo                   INTEGER;
DEFINE iPagos_realizados        INTEGER;
DEFINE dLinea_otorgada          DECIMAL(18,2);
DEFINE dTasa_interes            DECIMAL(9,6);
DEFINE dTasa_mora               DECIMAL(9,6);
DEFINE dMonto_sbc               DECIMAL(14,2);
DEFINE dCap_vig                 DECIMAL(18,2);  
DEFINE dCap_trans               DECIMAL(18,2);
DEFINE dCap_vdo_exig            DECIMAL(18,2);
DEFINE dCap_vdo_no_exig         DECIMAL(18,2);
DEFINE dSdo_act_total_cap       DECIMAL(18,2);
DEFINE dInt_vig                 DECIMAL(18,2);
DEFINE dInt_vdo                 DECIMAL(18,2);
DEFINE dInt_moratorios          DECIMAL(18,2);
DEFINE dInt_mes                 DECIMAL(18,2);
DEFINE dSdo_act_total_int       DECIMAL(18,2);
DEFINE dIva_int_vig             DECIMAL(18,2);
DEFINE dIva_int_vdo             DECIMAL(18,2);
DEFINE dIva_int_moratorios      DECIMAL(18,2);
DEFINE dIva_int_mes             DECIMAL(18,2);
DEFINE dSdo_act_total_iva       DECIMAL(18,2);
DEFINE dCom_pend                DECIMAL(18,2);
DEFINE dIva_com                 DECIMAL(18,2);
DEFINE dSdo_retenido            DECIMAL(18,2);
DEFINE dTotal_liquidacion       DECIMAL(18,2);
DEFINE dInt_devengado           DECIMAL(18,2);
DEFINE dIva_int_devengado       DECIMAL(18,2);
DEFINE dLinea_disponible        DECIMAL(18,2);
DEFINE dPagos_vdos              DECIMAL(18,2);   
DEFINE cDesc_status_cred        CHAR(60);
DEFINE iId_bloqueo_cred         INTEGER;
DEFINE cBloqueo_cta             CHAR(60);
DEFINE cId_causa_bloqueo_cred   CHAR(3);
DEFINE cCausa_bloqueo_cta       CHAR(50);
DEFINE cId_sit_esp_cte          CHAR(1);
DEFINE iId_causa_esp_cte        INTEGER;
DEFINE cSit_esp_cte             CHAR(75);
DEFINE cId_sit_esp_cred         CHAR(1);
DEFINE iId_causa_esp_cred       INTEGER;
DEFINE cSit_esp_cred            CHAR(75);


LET v_codret = "00000";
LET v_numcte = "";
LET v_apaterno = "";
LET v_amaterno = "";
LET v_nombre1 = "";
LET v_nombre2 = "";
LET v_numcteref = "";
LET v_telefono = "";
LET v_numcredito = "";
LET v_descripcioncred = "";
LET v_situacionespecial = "";
LET v_causa = "";
LET v_saldoactual = "";
LET v_tipoconvenio = "";

LET v_numdiasvencidos = "";
LET v_numpagovencidos = "";
LET v_pagominvencido = "";
LET v_proxpagoporvencer = "";
LET v_fechaultabono = "";
LET v_importeultabono = "";
LET v_fechaultconvenio = "";
LET v_importeconvenio = "";
LET v_cumplioconvenio = "";
LET v_origenconvenio = "";

LET v_sqlerr = 0;
LET v_isamerr = 0;

LET v_Indice = 0;
LET v_num_producto = "";
LET v_fechaeimporteultabono = "";
LET v_codretvalidavencidos = "";
LET v_activo = "";
LET v_sucursal = "";
LET vPorcIva = 0;
LET vIntMora = 0;
LET vIvaIntMora = 0;
LET vivacredito = 0;
LET vinteresmes = 0;
LET vivames = 0;

LET vSdoDisponible = 0;
LET vPagoMin = 0;
LET vFechaCorte = "";
LET vFechaPago = "";
LET vDisponible = 0;
LET vSdoRetenido = 0;
LET vstatuscred = "";
LET vinteresvencido = 0;


LET cCodRet         		= "000000";
LET dMtoNegociar    		= 0;
LET cCod_ret                = "000000";
LET cMensaje                = "";
LET cNumCred                = "";
LET cTipCred                = "";
LET dtFecha_origen          = DATE(1);
LET dtfecha_prox_pago       = DATE(1);
LET dPago_minimo            = 0;            
LET dtFecha_ult_pago        = DATE(1);
LET iPlazo                  = 0;
LET iPagos_realizados       = 0;
LET dLinea_otorgada         = 0;
LET dTasa_interes           = 0;
LET dTasa_mora              = 0;
LET dMonto_sbc              = 0;
LET dCap_vig                = 0;
LET dCap_trans              = 0;
LET dCap_vdo_exig           = 0;
LET dCap_vdo_no_exig        = 0;
LET dSdo_act_total_cap      = 0;
LET dInt_vig                = 0;
LET dInt_vdo                = 0;
LET dInt_moratorios         = 0;
LET dInt_mes                = 0;
LET dSdo_act_total_int      = 0;
LET dIva_int_vig            = 0;
LET dIva_int_vdo            = 0;
LET dIva_int_moratorios     = 0;
LET dIva_int_mes            = 0;
LET dSdo_act_total_iva      = 0;
LET dCom_pend               = 0;
LET dIva_com                = 0;
LET dSdo_retenido           = 0;
LET dTotal_liquidacion      = 0;
LET dInt_devengado          = 0;
LET dIva_int_devengado      = 0;
LET dLinea_disponible       = 0;
LET dPagos_vdos             = 0;             
LET cDesc_status_cred       = "";
LET iId_bloqueo_cred        = 0;
LET cBloqueo_cta            = "";
LET cId_causa_bloqueo_cred  = "";
LET cCausa_bloqueo_cta      = "";
LET cId_sit_esp_cte         = "";
LET iId_causa_esp_cte       = 0;
LET cSit_esp_cte            = "";
LET cId_sit_esp_cred        = "";
LET iId_causa_esp_cred      = 0;
LET cSit_esp_cred           = "";



--30-10-2008
--Modifico:
--Walberto Castro
--Se agrego la tabla real para consultar la descripcion del producto de credito.
--Se agrego la empresa en los where de las consultas donde no se habia puesto.

--27-11-2008
--Modifico:
--Walberto Castro
--Se agregaron los intereses moratorios e iva al calculo de pago minimo.

-- 19-08-2010
-- Modifico:
-- Viridiana Osobampo
-- Se modifica para retornar el monto minimo a negociar para el convenio de pago,
-- ademas de obtener los saldos del credito mediante el llamado al spl 
-- sp_consulta_saldos_general en lugar de obtenerlos de forma directa a las tablas.


--SET DEBUG FILE TO "/home/sysifx/viridiana/sp_consultacuentascliente.out";
--TRACE ON;

BEGIN

    ON EXCEPTION SET v_sqlerr, v_isamerr
        IF v_sqlerr != 0 THEN
            let v_codret=v_sqlerr;
            --ROLLBACK WORK;
            RETURN v_codret, v_numcte, v_apaterno, v_amaterno, v_nombre1, v_nombre2, v_numcteref, v_telefono, v_numcredito, v_descripcioncred,
                    v_situacionespecial, v_causa, v_saldoactual, v_tipoconvenio,v_numdiasvencidos, v_numpagovencidos, v_pagominvencido, v_proxpagoporvencer,
                    v_fechaultabono, v_importeultabono,v_fechaultconvenio, v_importeconvenio, v_cumplioconvenio, v_origenconvenio,dMtoNegociar;
        END IF;
    END EXCEPTION;

    --checar valores nulos en los parametros
    IF pEmpresa IS NULL OR Trim(pEmpresa) = "" THEN
        LET v_codret = "00001";
        RETURN v_codret, v_numcte, v_apaterno, v_amaterno, v_nombre1, v_nombre2, v_numcteref, v_telefono, v_numcredito, v_descripcioncred,
                v_situacionespecial, v_causa, v_saldoactual, v_tipoconvenio,v_numdiasvencidos, v_numpagovencidos, v_pagominvencido, v_proxpagoporvencer,
                v_fechaultabono, v_importeultabono,v_fechaultconvenio, v_importeconvenio, v_cumplioconvenio, v_origenconvenio,dMtoNegociar;
    END IF;
    IF pTipoBusqueda IS NULL OR Trim(pTipoBusqueda) = "" THEN
        LET v_codret = "00002";
        RETURN v_codret, v_numcte, v_apaterno, v_amaterno, v_nombre1, v_nombre2, v_numcteref, v_telefono, v_numcredito, v_descripcioncred,
                v_situacionespecial, v_causa, v_saldoactual, v_tipoconvenio,v_numdiasvencidos, v_numpagovencidos, v_pagominvencido, v_proxpagoporvencer,
                v_fechaultabono, v_importeultabono,v_fechaultconvenio, v_importeconvenio, v_cumplioconvenio, v_origenconvenio,dMtoNegociar;
    END IF;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

    -- Busqueda por numero de cliente
    IF pTipoBusqueda = "1" THEN
        LET v_numcte = pNumero;
        --Existe el cliente?
        IF EXISTS (SELECT numcte FROM bdinteg:si_cliente WHERE numcte = v_numcte) THEN

            --buscar nombre completo del cliente y su numero de referencia
            SELECT apell_paterno, apell_materno, nombre1, nombre2, numcte_ref
            INTO v_apaterno, v_amaterno, v_nombre1, v_nombre2, v_numcteref
           FROM bdinteg:si_cliente
            WHERE empresa = pEmpresa and numcte = v_numcte;

            --buscar si el cliente tiene alguna situacion especial
            SELECT situacion, causa
            INTO v_situacionespecial, v_causa
            FROM bdisitesp:se_ctessitespcte
            WHERE empresa = pEmpresa and numcte = v_numcte;

            --buscar el numero de telefono del cliente
            SELECT telefono
            INTO v_telefono
            FROM bdinteg:si_telefonos
            WHERE numcte = v_numcte
            AND tipo_tel = 1
            AND secuencia = (SELECT MAX(secuencia) FROM bdinteg:si_telefonos WHERE numcte = v_numcte AND tipo_tel = 1);

            --Ciclar la busqueda de creditos para ese numero de cliente
            FOREACH
                        SELECT num_credito, num_producto, sucursal
                        INTO v_numcredito, v_num_producto, v_sucursal
                        FROM bdicred:sd_maecred
                        WHERE empresa = pEmpresa and numcte = v_numcte

                        --buscar la descripcion del credito
                        SELECT nombre_prod
                        INTO v_descripcioncred
                        FROM bdicred:sd_definicion
                        WHERE empresa = pEmpresa and num_producto = v_num_producto;


                EXECUTE PROCEDURE bdicred:"informix".sp_consulta_saldos_general(pEmpresa, 
                                                                                v_numcredito)
                  INTO cCod_ret,
                       cMensaje,
                       cNumCred,
                       cTipCred,
                       dtFecha_origen,
                       dtfecha_prox_pago,
                       dPago_minimo,            
                       dtFecha_ult_pago,
                       iPlazo,
                       iPagos_realizados,
                       dLinea_otorgada,
                       dTasa_interes,
                       dTasa_mora,
                       dMonto_sbc,
                       dCap_vig,
                       dCap_trans,
                       dCap_vdo_exig,
                       dCap_vdo_no_exig,
                       dSdo_act_total_cap,
                       dInt_vig,
                       dInt_vdo,
                       dInt_moratorios,
                       dInt_mes,
                       dSdo_act_total_int,
                       dIva_int_vig,
                       dIva_int_vdo,
                       dIva_int_moratorios,
                       dIva_int_mes,
                       dSdo_act_total_iva,
                       dCom_pend,
                       dIva_com,
                       dSdo_retenido,
                       dTotal_liquidacion,
                       dInt_devengado,
                       dIva_int_devengado,
                       dLinea_disponible,
                       dPagos_vdos,             
                       cDesc_status_cred,
                       iId_bloqueo_cred,
                       cBloqueo_cta,
                       cId_causa_bloqueo_cred,
                       cCausa_bloqueo_cta,
                       cId_sit_esp_cte,
                       iId_causa_esp_cte,
                       cSit_esp_cte,
                       cId_sit_esp_cred,
                       iId_causa_esp_cred,
                       cSit_esp_cred;


                       LET v_saldoactual        = dSdo_act_total_cap;
                       LET v_numpagovencidos    = dPagos_vdos;
                       LET v_pagominvencido     = dPago_minimo;
                       LET vSdoDisponible       = dLinea_disponible;
                       LET v_proxpagoporvencer  = dtfecha_prox_pago;
                       LET v_fechaultabono      = dtFecha_ult_pago;                       

                        LET vmSumaAbono = 0;

                        SELECT {+INDEX(bdicred:sd_movdia mov3)} NVL(SUM(monto),0)
                        INTO vmSumaAbono FROM bdicred:sd_movdia 
                        WHERE empresa = pEmpresa and num_credito = v_numcredito 
                        and codigo_fun in ('033', '334', '335', '336', '337') and codigo_ref = 1 and reversado = 'N';

                        IF vmSumaAbono=0 THEN
                           SELECT {+INDEX(bdicred:sd_movhis inx_movhis)} NVL(SUM(monto),0) 
                           INTO vmSumaAbono 
                           FROM bdicred:sd_movhis 
                           WHERE empresa = pEmpresa and num_credito = v_numcredito 
                             and codigo_fun in ('033', '334', '335', '336', '337') and codigo_ref = 1
                             and fecha_mov = v_fechaultabono 
                             and reversado = 'N'; 
                        END IF;

                        let v_importeultabono = vmSumaAbono;

                        --buscar numero de dias vencidos y el tipo de convenio
                        EXECUTE PROCEDURE bdicobranza:sp_validavencidos(pEmpresa, v_numcredito, pFecha)
                        INTO v_codretvalidavencidos, v_numdiasvencidos, v_tipoconvenio;

                        --buscar la fecha del ultimo convenio, su importe, si fue cumplido y el origen de dicho convenio
                        IF(SELECT keyx FROM bdicobranza:cb_compac WHERE empresa = pEmpresa and numcuenta = v_numcredito) > 0 THEN
                            SELECT fecha_compac, importe, flag_pago, activo, origen
                            INTO v_fechaultconvenio, v_importeconvenio, v_cumplioconvenio, v_activo, v_origenconvenio
                            FROM bdicobranza:cb_compac
                            WHERE empresa = pEmpresa and numcuenta = v_numcredito
                            AND keyx = (SELECT MAX(keyx)FROM bdicobranza:cb_compac WHERE empresa = pEmpresa and numcuenta = v_numcredito);
                        ELSE
                            IF(SELECT keyx FROM bdicobranza:cb_compac_his WHERE empresa = pEmpresa and numcuenta = v_numcredito) > 0 THEN
                                SELECT FIRST 1 fecha_compac, importe, flag_pago, activo, origen
                                INTO v_fechaultconvenio, v_importeconvenio, v_cumplioconvenio, v_activo, v_origenconvenio
                                FROM bdicobranza:cb_compac_his
                                WHERE empresa = pEmpresa and numcuenta = v_numcredito
                                AND keyx = (SELECT MAX(keyx)FROM bdicobranza:cb_compac_his WHERE empresa = pEmpresa and numcuenta = v_numcredito);
                            ELSE
                                LET v_fechaultconvenio = "";
                                LET v_importeconvenio = "";
                                LET v_cumplioconvenio = "";
                                LET v_origenconvenio = "";
                            END IF;
                        END IF;
                        --asignar descripcion para saber el estado del compac
                        IF TRIM(v_cumplioconvenio) = '1' THEN
                            let v_cumplioconvenio = 'C';
                        ELSE
                            IF TRIM(v_cumplioconvenio) = '0' THEN
                                IF TRIM(v_activo) = '0' THEN
                                    let v_cumplioconvenio = 'NC';
                                ELSE
                                    IF TRIM(v_activo) = '1' THEN
                                    let v_cumplioconvenio = 'P';
                                    ELSE
                                        LET v_fechaultconvenio = "";
                                        LET v_importeconvenio = "";
                                        LET v_cumplioconvenio = "";
                                        LET v_origenconvenio = "";
                                    END IF;
                                END IF;
                            ELSE
                                LET v_fechaultconvenio = "";
                                LET v_importeconvenio = "";
                                LET v_cumplioconvenio = "";
                                LET v_origenconvenio = "";
                            END IF;
                        END IF;


                        --incrementar el indice del ciclo y checar si debe de continuar
                        LET v_Indice = v_Indice +1;
                        IF v_Indice <= pIndice THEN
                            CONTINUE FOREACH;
                        END IF;

                        EXECUTE PROCEDURE "informix".sp_compac_monto_minimo_convenio(pEmpresa, v_numcredito)
                                     INTO cCodRet, cMensaje,dMtoNegociar;

                        IF cCodRet <> "000000" THEN
                            let v_codret = "00005";
                        END IF;             

                        RETURN v_codret, v_numcte, v_apaterno, v_amaterno, v_nombre1, v_nombre2, v_numcteref, v_telefono, v_numcredito, v_descripcioncred,
                                v_situacionespecial, v_causa, v_saldoactual, v_tipoconvenio,v_numdiasvencidos, v_numpagovencidos, v_pagominvencido, v_proxpagoporvencer,
                                v_fechaultabono, v_importeultabono,v_fechaultconvenio, v_importeconvenio, v_cumplioconvenio, v_origenconvenio,dMtoNegociar WITH RESUME;
            END FOREACH;
        ELSE
            LET v_codret = "00003";
            RETURN v_codret, v_numcte, v_apaterno, v_amaterno, v_nombre1, v_nombre2, v_numcteref, v_telefono, v_numcredito, v_descripcioncred,
                    v_situacionespecial, v_causa, v_saldoactual, v_tipoconvenio,v_numdiasvencidos, v_numpagovencidos, v_pagominvencido, v_proxpagoporvencer,
                    v_fechaultabono, v_importeultabono,v_fechaultconvenio, v_importeconvenio, v_cumplioconvenio, v_origenconvenio,dMtoNegociar;
        END IF;
    ELSE
        --Busqueda por numero de credito
        IF pTipoBusqueda = "2" THEN
            --checar si existe el numero de credito
            IF( SELECT numcte FROM bdicred:sd_maecred WHERE empresa = pEmpresa and num_credito =  pNumero) > 0 THEN
                LET v_numcredito = pNumero;
                -- buscar el numero de cliente
                SELECT numcte, num_producto, sucursal
                INTO v_numcte, v_num_producto, v_Sucursal
                FROM bdicred:sd_maecred
                WHERE empresa = pEmpresa and num_credito =  v_numcredito;

			 --buscar el numero de telefono del cliente
            SELECT telefono
            INTO v_telefono
            FROM bdinteg:si_telefonos
            WHERE numcte = v_numcte
            AND tipo_tel = 1
            AND secuencia = (SELECT MAX(secuencia) FROM bdinteg:si_telefonos WHERE numcte = v_numcte AND tipo_tel = 1);
			
                --buscar nombre completo del cliente y su numero de referencia
                SELECT apell_paterno, apell_materno, nombre1, nombre2, numcte_ref
                INTO v_apaterno, v_amaterno, v_nombre1, v_nombre2, v_numcteref
                FROM bdinteg:si_cliente
                WHERE empresa = pEmpresa and numcte = v_numcte;

                --buscar si el cliente tiene alguna situacion especial
                SELECT situacion, causa
                INTO v_situacionespecial, v_causa
                FROM bdisitesp:se_ctessitespcte
                WHERE empresa = pEmpresa and numcte = v_numcte;

                --buscar la descripcion del credito
                SELECT nombre_prod
					INTO v_descripcioncred
				FROM bdicred:sd_definicion
                WHERE empresa = pEmpresa and num_producto = v_num_producto;

                EXECUTE PROCEDURE bdicred:"informix".sp_consulta_saldos_general(pEmpresa, 
                                                                                v_numcredito)
                  INTO cCod_ret,
                       cMensaje,
                       cNumCred,
                       cTipCred,
                       dtFecha_origen,
                       dtfecha_prox_pago,
                       dPago_minimo,            
                       dtFecha_ult_pago,
                       iPlazo,
                       iPagos_realizados,
                       dLinea_otorgada,
                       dTasa_interes,
                       dTasa_mora,
                       dMonto_sbc,
                       dCap_vig,
                       dCap_trans,
                       dCap_vdo_exig,
                       dCap_vdo_no_exig,
                       dSdo_act_total_cap,
                       dInt_vig,
                       dInt_vdo,
                       dInt_moratorios,
                       dInt_mes,
                       dSdo_act_total_int,
                       dIva_int_vig,
                       dIva_int_vdo,
                       dIva_int_moratorios,
                       dIva_int_mes,
                       dSdo_act_total_iva,
                       dCom_pend,
                       dIva_com,
                       dSdo_retenido,
                       dTotal_liquidacion,
                       dInt_devengado,
                       dIva_int_devengado,
                       dLinea_disponible,
                       dPagos_vdos,             
                       cDesc_status_cred,
                       iId_bloqueo_cred,
                       cBloqueo_cta,
                       cId_causa_bloqueo_cred,
                       cCausa_bloqueo_cta,
                       cId_sit_esp_cte,
                       iId_causa_esp_cte,
                       cSit_esp_cte,
                       cId_sit_esp_cred,
                       iId_causa_esp_cred,
                       cSit_esp_cred;


                       LET v_saldoactual        = dSdo_act_total_cap;
                       LET v_numpagovencidos    = dPagos_vdos;
                       LET v_pagominvencido     = dPago_minimo;
                       LET vSdoDisponible       = dLinea_disponible;
                       LET v_proxpagoporvencer  = dtfecha_prox_pago;
                       LET v_fechaultabono      = dtFecha_ult_pago;

                LET vmSumaAbono =0;

                SELECT {+INDEX(bdicred:sd_movdia mov3)} NVL(SUM(monto),0)
                INTO vmSumaAbono FROM bdicred:sd_movdia 
                WHERE empresa = pEmpresa and num_credito = v_numcredito 
                and codigo_fun in ('033', '334', '335', '336', '337') and codigo_ref = 1 and reversado = 'N';

                IF vmSumaAbono=0 THEN
                   SELECT {+INDEX(bdicred:sd_movhis inx_movhis)} NVL(SUM(monto),0) 
                   INTO vmSumaAbono 
                   FROM bdicred:sd_movhis 
                   WHERE empresa = pEmpresa and num_credito = v_numcredito 
                     and codigo_fun in ('033', '334', '335', '336', '337') and codigo_ref = 1
                     and fecha_mov = v_fechaultabono 
                     and reversado = 'N'; 
                END IF;

                let v_importeultabono = vmSumaAbono;

                --buscar numero de dias vencidos y el tipo de convenio
                EXECUTE PROCEDURE bdicobranza:sp_validavencidos(pEmpresa, v_numcredito, pFecha)
                INTO v_codretvalidavencidos, v_numdiasvencidos, v_tipoconvenio;

                --buscar la fecha del ultimo convenio, su importe, si fue cumplido y el origen de dicho convenio
                IF(SELECT keyx FROM bdicobranza:cb_compac WHERE empresa = pEmpresa and numcuenta = v_numcredito) > 0 THEN
                    SELECT fecha_compac, importe, flag_pago, activo, origen
                    INTO v_fechaultconvenio, v_importeconvenio, v_cumplioconvenio, v_activo, v_origenconvenio
                    FROM bdicobranza:cb_compac
                    WHERE empresa = pEmpresa and numcuenta = v_numcredito
                    AND keyx = (SELECT MAX(keyx)FROM bdicobranza:cb_compac WHERE empresa = pEmpresa and numcuenta = v_numcredito);
                ELSE
                    IF(SELECT keyx FROM bdicobranza:cb_compac_his WHERE empresa = pEmpresa and numcuenta = v_numcredito) > 0 THEN
                        SELECT FIRST 1 fecha_compac, importe, flag_pago, activo, origen
                        INTO v_fechaultconvenio, v_importeconvenio, v_cumplioconvenio, v_activo, v_origenconvenio
                        FROM bdicobranza:cb_compac_his
                        WHERE empresa = pEmpresa and numcuenta = v_numcredito
                        AND keyx = (SELECT MAX(keyx)FROM bdicobranza:cb_compac_his WHERE empresa = pEmpresa and numcuenta = v_numcredito);
                    ELSE
                        LET v_fechaultconvenio = "";
                        LET v_importeconvenio = "";
                        LET v_cumplioconvenio = "";
                        LET v_origenconvenio = "";
                    END IF;
                END IF;
                --asignar descripcion para saber el estado del compac
                IF TRIM(v_cumplioconvenio) = '1' THEN
                    let v_cumplioconvenio = 'C';
                ELSE
                    IF TRIM(v_cumplioconvenio) = '0' THEN
                        IF TRIM(v_activo) = '0' THEN
                            let v_cumplioconvenio = 'NC';
                        ELSE
                            IF TRIM(v_activo) = '1' THEN
                            let v_cumplioconvenio = 'P';
                            ELSE
                                LET v_fechaultconvenio = "";
                                LET v_importeconvenio = "";
                                LET v_cumplioconvenio = "";
                                LET v_origenconvenio = "";
                            END IF;
                        END IF;
                    ELSE
                        LET v_fechaultconvenio = "";
                        LET v_importeconvenio = "";
                        LET v_cumplioconvenio = "";
                        LET v_origenconvenio = "";
                    END IF;
                END IF;

                        EXECUTE PROCEDURE "informix".sp_compac_monto_minimo_convenio(pEmpresa, v_numcredito)
                                     INTO cCodRet, cMensaje,dMtoNegociar;

                        IF cCodRet <> "000000" THEN
                            let v_codret = "00006";
                        END IF;

                RETURN v_codret, v_numcte, v_apaterno, v_amaterno, v_nombre1, v_nombre2, v_numcteref, v_telefono, v_numcredito, v_descripcioncred,
                        v_situacionespecial, v_causa, v_saldoactual, v_tipoconvenio,v_numdiasvencidos, v_numpagovencidos, v_pagominvencido, v_proxpagoporvencer,
                        v_fechaultabono, v_importeultabono,v_fechaultconvenio, v_importeconvenio, v_cumplioconvenio, v_origenconvenio,dMtoNegociar;

            ELSE
                LET v_codret = "00004";
                RETURN v_codret, v_numcte, v_apaterno, v_amaterno, v_nombre1, v_nombre2, v_numcteref, v_telefono, v_numcredito, v_descripcioncred,
                        v_situacionespecial, v_causa, v_saldoactual, v_tipoconvenio,v_numdiasvencidos, v_numpagovencidos, v_pagominvencido, v_proxpagoporvencer,
                        v_fechaultabono, v_importeultabono,v_fechaultconvenio, v_importeconvenio, v_cumplioconvenio, v_origenconvenio,dMtoNegociar;
            END IF;
        END IF;
    END IF;
END;
END PROCEDURE;
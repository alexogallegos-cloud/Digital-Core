CREATE PROCEDURE "informix".sp_consultacuentascliente(
                                            pEmpresa char (3),
                                            pTipoBusqueda char(1),  -- 1= por num cliente, 2= por num credito
                                            pNumero char (20),
                                            pIndice char (3),
                                            pFecha date
                                            )

RETURNING
            char(5), --cod retorno
            char(20), --numero de cliente
            char(26), --apellido paterno
            char(26), --apellido materno
            char(26), --nombre1
            char(26), --nombre2
            char(20), --numero de la referencia cliente
            char(13), --numero de telefono
            char(20), --numero de credito
            char(40), --descripcion del credito
            char(30), --Situacion especial
            char(30), --Causa
            char(30), --Saldo actual
            char(30), --Tipo convenio

            char(30), --Numero de dias vencidos
            char(30), --Numero de pagos vencidos
            char(30), --Pago minimo vencido
            char(30), --proximo pago por vencer
            char(30), --fecha ultimo abono
            char(30), --importe ultimo abono
            char(30), --fecha ultimo convenio
            char(30), --importe convenio
            char(3), --cumplio convenio
            char(3), --origen convenio
            decimal(14,2) -- monto mínimo a negociar; 


define v_codret char(5);
define v_numcte char(20);
define v_apaterno char (26);
define v_amaterno char (26);
define v_nombre1 char (26);
define v_nombre2 char (26);
define v_numcteref char(20);
define v_telefono char(13);
define v_numcredito char (20);
define v_descripcioncred char(40);
define v_situacionespecial char(30);
define v_causa char(30);
define v_saldoactual decimal (16,2);
--define v_saldoactual char(30);
define v_tipoconvenio char (30);

define v_numdiasvencidos char(30);
define v_numpagovencidos char(30);
define v_pagominvencido char(30);
define v_proxpagoporvencer char(30);
define v_fechaultabono char(30);
define v_importeultabono char(30);
define v_fechaultconvenio date;
define v_importeconvenio decimal(14);
define v_cumplioconvenio char(3);
define v_origenconvenio smallint;

define v_sqlerr integer;
define v_isamerr integer;

define v_Indice integer;
define v_num_producto char (4);
define v_fechaeimporteultabono char(125);
define v_codretvalidavencidos char (6);
define v_activo char (6);
define v_sucursal char (4);
define vPorcIva decimal (14);
define vIntMora decimal(14);
define vIvaIntMora decimal(14);
define vivacredito decimal(14);
define vinteresmes decimal(14);
define vivames decimal(14);
define vSdoDisponible decimal(14);
define vPagoMin decimal(14);
define vFechaCorte date;
define vFechaPago date;
define vDisponible decimal(14);
define vSdoRetenido decimal(14);
define vstatuscred char (4);
define vinteresvencido decimal(14);
define vmSumaAbono MONEY(18,2);

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


let v_codret = "000";
let v_numcte = "";
let v_apaterno = "";
let v_amaterno = "";
let v_nombre1 = "";
let v_nombre2 = "";
let v_numcteref = "";
let v_telefono = "";
let v_numcredito = "";
let v_descripcioncred = "";
let v_situacionespecial = "";
let v_causa = "";
let v_saldoactual = "";
let v_tipoconvenio = "";

let v_numdiasvencidos = "";
let v_numpagovencidos = "";
let v_pagominvencido = "";
let v_proxpagoporvencer = "";
let v_fechaultabono = "";
let v_importeultabono = "";
let v_fechaultconvenio = "";
let v_importeconvenio = "";
let v_cumplioconvenio = "";
let v_origenconvenio = "";

let v_sqlerr = 0;
let v_isamerr = 0;

let v_Indice = 0;
let v_num_producto = "";
let v_fechaeimporteultabono = "";
let v_codretvalidavencidos = "";
let v_activo = "";
let v_sucursal = "";
let vPorcIva = 0;
let vIntMora = 0;
let vIvaIntMora = 0;
let vivacredito = 0;
let vinteresmes = 0;
let vivames = 0;

let vSdoDisponible = 0;
let vPagoMin = 0;
let vFechaCorte = "";
let vFechaPago = "";
let vDisponible = 0;
let vSdoRetenido = 0;
let vstatuscred = "";
let vinteresvencido = 0;


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
-- Modificó:
-- Viridiana Osobampo
-- Se modifica para retornar el monto mínimo a negociar para el convenio de pago,
-- además de obtener los saldos del crédito mediante el llamado al spl 
-- sp_consulta_saldos_general en lugar de obtenerlos de forma directa a las tablas.


--SET DEBUG FILE TO "/home/sysifx/viridiana/sp_consultacuentascliente.out";
--TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

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
        LET v_codret = "001";
        RETURN v_codret, v_numcte, v_apaterno, v_amaterno, v_nombre1, v_nombre2, v_numcteref, v_telefono, v_numcredito, v_descripcioncred,
                v_situacionespecial, v_causa, v_saldoactual, v_tipoconvenio,v_numdiasvencidos, v_numpagovencidos, v_pagominvencido, v_proxpagoporvencer,
                v_fechaultabono, v_importeultabono,v_fechaultconvenio, v_importeconvenio, v_cumplioconvenio, v_origenconvenio,dMtoNegociar;
    END IF;
    IF pTipoBusqueda IS NULL OR Trim(pTipoBusqueda) = "" THEN
        LET v_codret = "002";
        RETURN v_codret, v_numcte, v_apaterno, v_amaterno, v_nombre1, v_nombre2, v_numcteref, v_telefono, v_numcredito, v_descripcioncred,
                v_situacionespecial, v_causa, v_saldoactual, v_tipoconvenio,v_numdiasvencidos, v_numpagovencidos, v_pagominvencido, v_proxpagoporvencer,
                v_fechaultabono, v_importeultabono,v_fechaultconvenio, v_importeconvenio, v_cumplioconvenio, v_origenconvenio,dMtoNegociar;
    END IF;

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
/*
            --buscar el numero de telefono del cliente
            SELECT telefono1
            INTO v_telefono
            FROM bdinteg:si_direcciones
            WHERE numcte = v_numcte
            AND tipo_dir = '1'
            AND secuencia = (SELECT MAX(secuencia) FROM bdinteg:si_direcciones WHERE numcte = v_numcte AND tipo_dir = '1');
*/

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


                        --buscar Fecha e importe del ultimo abono
        /*
                        SELECT nvl(max (cast(secuencia as char(50)) || " " || cast(fecha_mov as char(10)) || " " || cast(hora_mov as char(15)) || " " || cast(monto as char(50))),'')
                        INTO v_fechaeimporteultabono
                        FROM bdicred:sd_movhis
                        WHERE empresa = pEmpresa and num_credito= v_numcredito AND transacc_suc = '6260'
                        AND codigo_fun = '033' AND codigo_ref = '1' AND reversado = 'S' AND fecha_mov = (SELECT fecha_ult_pago FROM bdicred:sd_maecredanexo WHERE empresa = pEmpresa and num_credito = v_numcredito);


                        --recuperar los datos que se necesitan de la cadena devuelta anteriormente

                        let v_fechaultabono = substr(v_fechaeimporteultabono,50,60);
                        let v_fechaultabono = substr(v_fechaultabono,3,10);
                        let v_importeultabono = substr(v_fechaeimporteultabono,79,125);
        */
                        --buscar numero de dias vencidos y el tipo de convenio
                        EXECUTE PROCEDURE bdicobranza:sp_validavencidos(pEmpresa, v_numcredito, pFecha)
                        INTO v_codretvalidavencidos, v_numdiasvencidos, v_tipoconvenio;

                        --buscar la fecha del ultimo convenio, su importe, si fue cumplido y el origen de dicho convenio
                        IF EXISTS (SELECT keyx FROM bdicobranza:cb_compac WHERE empresa = pEmpresa and numcuenta = v_numcredito) THEN
                            SELECT fecha_compac, importe, flag_pago, activo, origen
                            INTO v_fechaultconvenio, v_importeconvenio, v_cumplioconvenio, v_activo, v_origenconvenio
                            FROM bdicobranza:cb_compac
                            WHERE empresa = pEmpresa and numcuenta = v_numcredito
                            AND keyx = (SELECT MAX(keyx)FROM bdicobranza:cb_compac WHERE empresa = pEmpresa and numcuenta = v_numcredito);
                        ELSE
                            IF EXISTS (SELECT keyx FROM bdicobranza:cb_compac_his WHERE empresa = pEmpresa and numcuenta = v_numcredito) THEN
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
                            let v_codret = "005";
                        END IF;             

                        RETURN v_codret, v_numcte, v_apaterno, v_amaterno, v_nombre1, v_nombre2, v_numcteref, v_telefono, v_numcredito, v_descripcioncred,
                                v_situacionespecial, v_causa, v_saldoactual, v_tipoconvenio,v_numdiasvencidos, v_numpagovencidos, v_pagominvencido, v_proxpagoporvencer,
                                v_fechaultabono, v_importeultabono,v_fechaultconvenio, v_importeconvenio, v_cumplioconvenio, v_origenconvenio,dMtoNegociar WITH RESUME;
            END FOREACH;
        ELSE
            LET v_codret = "003";
            RETURN v_codret, v_numcte, v_apaterno, v_amaterno, v_nombre1, v_nombre2, v_numcteref, v_telefono, v_numcredito, v_descripcioncred,
                    v_situacionespecial, v_causa, v_saldoactual, v_tipoconvenio,v_numdiasvencidos, v_numpagovencidos, v_pagominvencido, v_proxpagoporvencer,
                    v_fechaultabono, v_importeultabono,v_fechaultconvenio, v_importeconvenio, v_cumplioconvenio, v_origenconvenio,dMtoNegociar;
        END IF;
    ELSE
        --Busqueda por numero de credito
        IF pTipoBusqueda = "2" THEN
            --checar si existe el numero de credito
            IF EXISTS ( SELECT numcte FROM bdicred:sd_maecred WHERE empresa = pEmpresa and num_credito =  pNumero) THEN
                LET v_numcredito = pNumero;
                -- buscar el numero de cliente
                SELECT numcte, num_producto, sucursal
                INTO v_numcte, v_num_producto, v_Sucursal
                FROM bdicred:sd_maecred
                WHERE empresa = pEmpresa and num_credito =  v_numcredito;
/*
                --buscar el numero de telefono del cliente
                SELECT telefono1
                INTO v_telefono
                FROM bdinteg:si_direcciones
                WHERE numcte = v_numcte
                AND tipo_dir = '1'
                AND secuencia = (SELECT MAX(secuencia) FROM bdinteg:si_direcciones WHERE numcte = v_numcte AND tipo_dir = '1');
			 */
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

                --buscar Fecha de prox Pago
/*
                SELECT prox_fecha_pago
                INTO v_proxpagoporvencer
                FROM bdicred:sd_maecredanexo
                WHERE empresa = pEmpresa
                AND num_credito = v_numcredito;
*/

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

/*
                --buscar Fecha e importe del ultimo abono
                SELECT nvl(max (cast(secuencia as char(50)) || " " || cast(fecha_mov as char(10)) || " " || cast(hora_mov as char(15)) || " " || cast(monto as char(50))),'')
                INTO v_fechaeimporteultabono
                FROM bdicred:sd_movhis
                WHERE empresa = pEmpresa and num_credito= v_numcredito AND transacc_suc = '6260'
                AND codigo_fun = '033' AND codigo_ref = '1' AND reversado = 'S' AND fecha_mov = (SELECT fecha_ult_pago FROM bdicred:sd_maecredanexo WHERE empresa = pEmpresa and num_credito = v_numcredito);
                --recuperar los datos que se necesitan de la cadena devuelta anteriormente
                let v_fechaultabono = substr(v_fechaeimporteultabono,50,60);
                let v_fechaultabono = substr(v_fechaultabono,3,10);
                let v_importeultabono = substr(v_fechaeimporteultabono,79,125);
*/
                --buscar numero de dias vencidos y el tipo de convenio
                EXECUTE PROCEDURE bdicobranza:sp_validavencidos(pEmpresa, v_numcredito, pFecha)
                INTO v_codretvalidavencidos, v_numdiasvencidos, v_tipoconvenio;

                --buscar la fecha del ultimo convenio, su importe, si fue cumplido y el origen de dicho convenio
                IF EXISTS (SELECT keyx FROM bdicobranza:cb_compac WHERE empresa = pEmpresa and numcuenta = v_numcredito) THEN
                    SELECT fecha_compac, importe, flag_pago, activo, origen
                    INTO v_fechaultconvenio, v_importeconvenio, v_cumplioconvenio, v_activo, v_origenconvenio
                    FROM bdicobranza:cb_compac
                    WHERE empresa = pEmpresa and numcuenta = v_numcredito
                    AND keyx = (SELECT MAX(keyx)FROM bdicobranza:cb_compac WHERE empresa = pEmpresa and numcuenta = v_numcredito);
                ELSE
                    IF EXISTS (SELECT keyx FROM bdicobranza:cb_compac_his WHERE empresa = pEmpresa and numcuenta = v_numcredito) THEN
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
                            let v_codret = "006";
                        END IF;

                RETURN v_codret, v_numcte, v_apaterno, v_amaterno, v_nombre1, v_nombre2, v_numcteref, v_telefono, v_numcredito, v_descripcioncred,
                        v_situacionespecial, v_causa, v_saldoactual, v_tipoconvenio,v_numdiasvencidos, v_numpagovencidos, v_pagominvencido, v_proxpagoporvencer,
                        v_fechaultabono, v_importeultabono,v_fechaultconvenio, v_importeconvenio, v_cumplioconvenio, v_origenconvenio,dMtoNegociar;

            ELSE
                LET v_codret = "004";
                RETURN v_codret, v_numcte, v_apaterno, v_amaterno, v_nombre1, v_nombre2, v_numcteref, v_telefono, v_numcredito, v_descripcioncred,
                        v_situacionespecial, v_causa, v_saldoactual, v_tipoconvenio,v_numdiasvencidos, v_numpagovencidos, v_pagominvencido, v_proxpagoporvencer,
                        v_fechaultabono, v_importeultabono,v_fechaultconvenio, v_importeconvenio, v_cumplioconvenio, v_origenconvenio,dMtoNegociar;
            END IF;
        END IF;
    END IF;
END;
END PROCEDURE;
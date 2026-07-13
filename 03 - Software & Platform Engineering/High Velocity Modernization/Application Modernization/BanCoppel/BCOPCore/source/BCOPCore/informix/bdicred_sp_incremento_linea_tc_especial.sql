CREATE PROCEDURE "informix".sp_incremento_linea_tc_especial()
RETURNING
    CHAR(5) AS cCodRet;

DEFINE cCodRet          	 CHAR(5);  
DEFINE iSqlErr          	 INTEGER;  
DEFINE dfecha_hoy      		 DATE;  
DEFINE cnum_credito  		 CHAR(20);
DEFINE cnumcte 				 CHAR(20);
DEFINE dlinea_anterior  	 DECIMAL(18,2);
DEFINE dnueva_lc 			 DECIMAL(18,2);
DEFINE dincremento			 DECIMAL(18,2);
DEFINE cvalidacion			 CHAR(1);
DEFINE cvalidacion_sucursal  CHAR(1);
DEFINE cvalidacion_sms 	 	 CHAR(1);
DEFINE dmonto_otorgado		 DECIMAL(18,2);
DEFINE csucursal 			 CHAR(4);
DEFINE cnum_producto 		 CHAR(4);
DEFINE cfecha_apertura		 DATE;
DEFINE cexiste				 CHAR(1);



LET cCodRet            		 = "00000";
LET iSqlErr            		 = 0;
LET dfecha_hoy          	 = DATE(1);
LET cnum_credito 			 = "";
LET cnumcte 				 = "";
LET dlinea_anterior 		 = 0;
LET dnueva_lc				 = 0; 
LET dincremento 			 = 0;
LET cvalidacion 			 = 0;
LET cvalidacion_sucursal 	 = 0;
LET cvalidacion_sms 		 = 0;
LET dmonto_otorgado		 	 = 0;
LET csucursal 			 	 = "";
LET cnum_producto 		 	 = "";
LET cfecha_apertura		 	 = DATE(1);
LET cexiste					 = '';



-- **********************************************************************
-- *                        CONTROL DE ERRORES
-- **********************************************************************

BEGIN
    ON EXCEPTION SET iSqlErr
        IF iSqlErr != 0 THEN
            LET cCodRet= iSqlErr;
            RETURN cCodRet;
        END IF;
    END EXCEPTION;

-- **********************************************************************
-- *                        PROGRAMA PRINCIPAL
-- **********************************************************************	
	
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	

	SELECT fecha_hoy
    INTO dfecha_hoy
    FROM bdicred:"informix".sd_fechas
    WHERE empresa = "001";
	
	FOREACH WITH HOLD
	SELECT numcte, num_credito, nueva_lc
	INTO cnumcte, cnum_credito, dnueva_lc
	FROM bdicred:"informix".sd_cred_incremento_especial
	
	IF NVL(cnum_credito, "") = "" OR NVL(dnueva_lc, 0) = 0 THEN
		CONTINUE FOREACH;
	END IF;
	
	SELECT A.monto_otorgado, B.sucursal, B.num_producto, B.fecha_apertura
	INTO dmonto_otorgado, csucursal, cnum_producto, cfecha_apertura
	FROM bdicred:"informix".sd_maesdos A
	INNER JOIN bdicred:"informix".sd_maecred B ON A.num_credito = B.num_credito
	WHERE A.num_credito = cnum_credito;
	
	LET dincremento = dnueva_lc - dmonto_otorgado;
	
	INSERT INTO bdicred:"informix".sd_bitacora_incremento_especial(num_credito, linea_anterior, linea_actual, incremento, validacion, validacion_sms, validacion_sucursal, fecha_proceso )
	VALUES(cnum_credito, dmonto_otorgado, dnueva_lc, dincremento, cvalidacion, cvalidacion_sms, cvalidacion_sucursal, dfecha_hoy);
	
	IF NVL(dmonto_otorgado, 0) = 0 THEN 
		CONTINUE FOREACH;
	END IF;
	
	IF dmonto_otorgado >= dnueva_lc THEN
		UPDATE bdicred:"informix".sd_bitacora_incremento_especial 
		SET validacion = "2"
		WHERE num_credito = cnum_credito;
		CONTINUE FOREACH;
	END IF;
	
	SELECT count(*)
	INTO cexiste
	FROM bdicred:"informix".sd_incrementos_linea
	WHERE num_solicitud = cnum_credito;
	
	IF cexiste = '1' THEN
	
		UPDATE bdicred:"informix".sd_incrementos_linea 
		SET flag_incremento_especial = "1" 
		WHERE num_solicitud = cnum_credito;
	
	ELIF cexiste = '0' THEN
					
		INSERT INTO bdicred:"informix".sd_incrementos_linea(num_solicitud, numcte, sucursal, num_producto, monto_otorgado, fecha_apertura, flag_incremento_especial)
		VALUES(cnum_credito, cnumcte, csucursal, cnum_producto, dmonto_otorgado, cfecha_apertura, "1" );
	
	END IF;
								
		
	END FOREACH;

RETURN cCodRet;
END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se validan los candidatos a incremento especial y se insertan y actualizan en las bitacoras',
'AUTOR: MAFL',
'FECHA: Septiembre de 2025',
'BASE DE DATOS: bdicred';

CREATE PROCEDURE "informix".sp_genera_carteraenlinea_tab(pEmpresa char(3), pServicio char(1)) 

RETURNING  CHAR(6) AS Cod_Ret,  CHAR(80) AS Mens_Ret;

-- Creador por: MAHR. Abril 2012. Se crea la informacion de la Cartera en linea dentro de la tabla sd_sdos_cartera_linea, a fin de que los 
--             diversos procesos que explotan la misma informacion la obtengan de dicha tabla, optimizando los tiempos de consulta.
-- Servicios: 1.- Tarjeta de Credito, 2.- Prestamo Personal y Reestructura 3.- AMBOS.

-- Se modifica el proceso para agregar campos solicitados en el RQM 09 463 - Agosto 2017. ADLM.
--Declaracion de variables
-- V.2 JAHJ Septiembre 2023  
DEFINE sql_err          INTEGER;
DEFINE isam_err         INTEGER;
DEFINE error_info       CHAR(80);
DEFINE cEmpresa         CHAR(3);
DEFINE cProceso         CHAR(4);
DEFINE cCod_ret         CHAR(6);
DEFINE cCod_retBit      CHAR(6);
DEFINE cMensajeRet      CHAR(125);  
DEFINE cruta            CHAR(100);
DEFINE cSQL             CHAR(8204);
DEFINE cSQL1            CHAR(6204);
DEFINE cSQL2            CHAR(6204);
DEFINE vcliente         CHAR(20);
DEFINE vcredito         CHAR(20);
DEFINE vtarjeta         CHAR(20);
DEFINE vcta_eje         CHAR(20);
DEFINE vproducto        CHAR(4);
DEFINE vstatuscred      CHAR(2);
DEFINE vsucursal        CHAR(4);
DEFINE vcat             CHAR(6);
DEFINE dFecha_hoy       DATE;
DEFINE dFecha_max       DATE;
DEFINE dFecha_min       DATE;
DEFINE dFecha_ayer      DATE;
DEFINE dFecha_today 	DATE;
DEFINE vfechaultpago	DATE;
DEFINE vfch_apertura    DATE;
DEFINE vproxfchpago     DATE;
DEFINE cfechavencto, cfechavencto1, cfechavencto2, cfechavencto3, cfechavencto4, cfechavencto5 DATE;
DEFINE cfecha_habil1, cfecha_habil2, cfecha_habil3, cfecha_habil4, cfecha_habil5 DATE;
DEFINE vtasainteres     DECIMAL(9,6);
DEFINE ctasamora        DECIMAL(9,6);
DEFINE vmontootorgado,  vsdo_intereses, vmensualidad_act	 DECIMAL(18,2);
DEFINE vsdo_capital,   vmonto_vencido, vmtovenctrasp, vcaptrasnovenci, vsdocapinsoluto	DECIMAL(18,2);
DEFINE montofinanciado,vsdomoratorio,  vinteresiva,   vmoras,          pagounamora    	DECIMAL(18,2);
DEFINE cSaldovencido1, cSaldovencido2, cSaldovencido3,cSaldovencido4,  cSaldovencido5   MONEY(18,2);
DEFINE cSaldovencido6, cInteresmoratorio1, cInteresmoratorio2, cInteresmoratorio3       MONEY(18,2);
DEFINE cInteresmoratorio4, cInteresmoratorio5, cInteresmoratorio6, cInteresV            MONEY(18,2);
DEFINE mIvaSucursal     MONEY(5,3);
DEFINE sAbonosVdos      INTEGER;
DEFINE sDiasTrans       INTEGER;
DEFINE sDiaCorte        SMALLINT;
DEFINE vgrupo			CHAR(1);
DEFINE vantiguedad		INTEGER;
DEFINE vbcscore			DECIMAL(5,2);
DEFINE vscoreprop		DECIMAL(5,2);
DEFINE vficoscore		DECIMAL(5,2);
DEFINE vbhscore			DECIMAL(5,2);
DEFINE vnovencidos1		INTEGER;
DEFINE vnovencidos2		INTEGER;
DEFINE vnovencidos3		INTEGER;
DEFINE vnovencidos4		INTEGER;
DEFINE vnovencidos5		INTEGER;
DEFINE vnovencidos6		INTEGER;
DEFINE vcelular			CHAR(13);
DEFINE vivatrasp		DECIMAL(18,2);
DEFINE vretenido        DECIMAL(18,2);
DEFINE cAct                     INTEGER;
DEFINE cAtr                     INTEGER;

DEFINE v_fecha_vencido  DATE;
DEFINE v_num_vencidos   INTEGER;
DEFINE dPagosVdos       INTEGER;
DEFINE v_dias_vencido   INTEGER;
DEFINE dUltDisp_atm     DATE;
DEFINE dUltDisp_pos     DATE;
DEFINE dUltDisp_vnt     DATE;
DEFINE dUltima_Disposicion DATE;
DEFINE v_ejecutivo CHAR(8);
DEFINE v_cuenta_bloque  integer;

--SET DEBUG FILE TO "/ifxsif01/PEDRO/carteralinea/sp_genera_carteraenlinea_tab.out";
--TRACE ON;

--Inicializacion de variables
LET sql_err         = 0;
LET isam_err        = 0;
LET error_info      = "";
LET cEmpresa        = "";
LET cProceso        = '0024';
LET cCod_Ret        = '000000';
LET cCod_retBit     = '000000';
LET cMensajeRet     = 'PROCESO EXITOSO';
LET cSQL            = '';
LET cSQL1           = '';
LET cSQL2           = '';
LET cruta           = '';
LET	vcliente        = '';
LET	vcredito        = '';
LET	vtarjeta        = '';
LET	vcta_eje        = '';
LET	vproducto       = '';
LET	vstatuscred     = '';
LET	vsucursal       = '';
LET	vcat            = '';
LET	vsdo_capital    = 0;    LET vmonto_vencido	= 0;    LET vmtovenctrasp  = 0;     LET vcaptrasnovenci    = 0; LET vsdocapinsoluto     = 0; 
LET pagounamora     = 0;    LET montofinanciado = 0;    LET vsdomoratorio  = 0;     LET vinteresiva        = 0; LET vmoras              = 0; 
LET vmontootorgado  = 0;    LET vtasainteres    = 0;    LET ctasamora      = 0;     LET cSaldovencido1     = 0; LET cSaldovencido2      = 0; 
LET cSaldovencido3  = 0;    LET cSaldovencido4  = 0;    LET cSaldovencido5 = 0;     LET cSaldovencido6     = 0; LET cInteresmoratorio1  = 0; 
LET cInteresmoratorio2 = 0; LET cInteresmoratorio3 = 0; LET cInteresmoratorio4 = 0; LET cInteresmoratorio5 = 0; LET cInteresmoratorio6  = 0; 
LET mIvaSucursal       = 0; LET sAbonosVdos     = 0;    LET sDiasTrans     = 0;     LET vsdo_intereses     = 0; LET vmensualidad_act   = 0;
LET sDiaCorte          = 0; 
LET vgrupo			= "";
LET vantiguedad		= 0;
LET vbcscore		= 0;
LET vscoreprop		= 0;
LET vficoscore		= 0;
LET vbhscore		= 0;
LET vnovencidos1	= 0;
LET vnovencidos2	= 0;
LET vnovencidos3	= 0;
LET vnovencidos4	= 0;
LET vnovencidos5	= 0;
LET vnovencidos6	= 0;
LET vcelular		="";
LET vivatrasp		= 0;
LET vretenido       = 0;
LET dFecha_hoy      = date(1);
LET dFecha_max      = date(1);
LET dFecha_min      = date(1);
LET dFecha_ayer		= date(1);
LET dFecha_today	= date(1);
LET cAct                        = 0;
LET cAtr                        = 0;

LET v_fecha_vencido  = DATE(1);
LET v_num_vencidos   =0;
LET dPagosVdos       =0;
LET v_dias_vencido   =0; 
LET dUltDisp_atm  = DATE(1);
LET dUltDisp_pos  = DATE(1);
LET dUltDisp_vnt  = DATE(1);
LET dUltima_Disposicion = DATE(1);
LET v_ejecutivo ="";
LET v_cuenta_bloque = 0;

BEGIN

    ON EXCEPTION SET sql_err, isam_err, error_info
        LET cCod_ret = sql_err;
        LET cMensajeRet = error_info;        
            -- Validamos si ya se encuentra creada la tabla
					
		DROP TABLE IF EXISTS "informix".creditossl_tab2;	
			
--       IF EXISTS( SELECT tabname FROM sysmaster:systabnames WHERE tabname = 'creditossl_tab2' ) THEN
--          DROP TABLE creditossl_tab2;
--		 END IF;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCod_ret, cMensajeRet || ' Error en cart_tab', '02') RETURNING cCod_retBit;
        RETURN cCod_ret,cMensajeRet;
    END EXCEPTION;

    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCod_ret, 'INICIA sp_genera_carteraenlinea_tab ', '02') RETURNING cCod_retBit;       

    --Directiva para lectura de tablas bloqueadas.
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    -- Obtener la fecha del dia de hoy
    SELECT fecha_hoy, fecha_ant INTO dFecha_hoy, dFecha_ayer FROM bdicred:"informix".sd_fechas WHERE empresa = pEmpresa; 
--  LET dFecha_hoy = mdy('08','01','2023');     --  <--    ***********************  comentar esta linea 
--	LET dFecha_ayer = mdy('07','31','2023');  --  <--    ***********************  comentar esta linea 
	IF dFecha_hoy IS NULL THEN
        LET dFecha_hoy = Today;
		LET dFecha_ayer = today - 1;
    END IF
      
	--Validacion de la empresa
    SELECT empresa INTO cEmpresa FROM bdinteg:"informix".si_empresas WHERE empresa = pEmpresa;
    IF NVL (cEmpresa, '') = '' OR cEmpresa IS NULL THEN
        LET pEmpresa = '001';
		LET dFecha_ayer = today - 1;
    END IF;

    IF pServicio NOT IN ('1','2','3') THEN
        LET cCod_Ret=  '102002';
        SELECT descripcion INTO cMensajeRet
            FROM bdicobranza:"informix".cb_errores
            WHERE origen = 3 AND codigo_error = cCod_Ret;
        IF cMensajeRet IS NULL THEN
            LET cMensajeRet = "";
        END IF;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCod_ret, 'Servicio proporcionado incorrecto a sp_genera_carteraenlinea_tab', '02') RETURNING cCod_retBit;
        RETURN cCod_Ret,cMensajeRet;
    END IF;

	--Obtener ruta del archivo
    SELECT TRIM(valor_alfabetico) INTO cruta
        FROM bdicobranza:"informix".cb_param_campania
        WHERE empresa = pEmpresa AND tipo_campania = 1
        AND grupo_parametro = 'ARCHIVOS'AND num_parametro = 34;  
    IF NVL (cruta,'') = '' THEN     --Valida que exista la carpeta
        LET cCod_Ret= '104005';
        SELECT descripcion INTO cMensajeRet
            FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCod_Ret;
        IF cMensajeRet IS NULL THEN
            LET cMensajeRet = "";
        END IF;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCod_ret, 'Ruta incorrecta - sp_genera_carteraenlinea_tab', '02') RETURNING cCod_retBit;
        RETURN cCod_Ret,cMensajeRet;
    END IF;
	
--	LET cruta='/ifxsif01/90260202/marco/';							--  <--    ***********************  comentar esta linea 
	
	-- Validamos si ya se encuentra creada la tabla.
	
	DROP TABLE  IF EXISTS creditossl_tab2;
	

    -- Elimina la informacion almacenada, generada el dia anterior. -- Se modifica para que no borre lo que ya existe si ya existe informacion procesada del dia.
     --Delete from bdicred:"informix".sd_sdos_cartera_linea;
	SELECT max(fecha), min(fecha) INTO dFecha_max, dFecha_min FROM bdicred:sd_sdos_cartera_linea;
	LET dFecha_today = today;

	IF dFecha_max = dFecha_min AND dFecha_max = dFecha_ayer AND dFecha_max = (dFecha_today - 1)
			THEN
		LET pServicio = '2';										-- Si ya existe informacion no elimine tabla y solo ejecute prestamo.
		LET dFecha_hoy = dFecha_ayer;
	ELSE
		TRUNCATE bdicred:"informix".sd_sdos_cartera_linea;   		-- Elimine si es un nuevo dia. 
	END IF;
	

	
    -- | Cliente | Credito | Tarjeta | Cuenta eje | Producto | sdo_capital | monto_vencido | mto_venc_trasp | cap_tras_no_venci | sdo_cap_insoluto | 
    -- | monto financiado | Int moratorio | interes_iva | No moras | status_cred | fecha_ult_pago | pago una mora | Sucursal | Fecha_apertura |  
    -- | monto_otorgado | tasa_interes | prox_fecha_pago | Cat | saldovencido1 |saldovencido2 |saldovencido3 | saldovencido4 | saldovencido5 |
    -- | saldovencido6 | interesmoratorio1 | interesmoratorio2 | interesmoratorio3 | interesmoratorio4 | interesmoratorio5 | interesmoratorio6 |

    IF pServicio = '1' OR pServicio = '3' THEN      -- Obtiene informacion de Cartera de Tarjeta de Credito

	    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCod_ret, 'Paso 1: Obtiene info TDC', '02') RETURNING cCod_retBit;  


        --LET cSQL1 = ' echo " SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cruta) || TRIM(cnomarchivo) || ' DELIMITER ' || ''''|| cdelimitador || ''''||'';


        LET cSQL1 = ' echo " SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cruta) || 'creditos_tab2.txt' 
                || ' select  {+INDEX(sd_maecred maesta)} a.empresa, a.numcte, a.num_credito , a.sucursal, a.status_cred, a.num_producto,'
                || ' a.fecha_apertura, a.tasa_interes, a.tasa_moratorios, (select max(b.fecha) from sd_maesdoshist b) fecha_his, a.ejecutivo '
                || ' from bdicred:sd_maecred a, bdicred:sd_maesdos d'
				--IFRS || ' where a.empresa = ''001'' '
				|| ' where a.num_credito = d.num_credito'
                || ' and (a.status_cred in (''BT'',''BA'',''E1'',''E2'',''E3'') and (d.monto_vencido + d.mto_venc_trasp) > 0 );  '
                --|| ' create temp table bdicred:creditossl_tab2 ' 
                || ' create table bdicred:creditossl_tab2 '
                || '(empresa 		char(3), '
                || ' numcte 		char(20), '
                || ' num_credito 	char(20), '
                || ' sucursal 		char(4), '
                || ' status_cred 	char(2), '
                || ' num_producto 	char(4), '
                || ' fecha_apertura date, '
                || ' tasa_interes   decimal(9,6), '
                || ' tasa_moratorios decimal(9,6), '
		        || ' fecha_his 		date, '
		        || ' ejecutivo 		char(8) '
                --|| ') with no log; ' 
                || '); '  
                || ' load from '|| TRIM(cruta) ||'creditos_tab2.txt insert into creditossl_tab2;  '
                || ' create unique index inx_creditossl_tab2 on creditossl_tab2(numcte,sucursal,num_credito);'
                || ' update statistics medium for table creditossl_tab2 resolution 1.6; ' ;
                /*||' SELECT {+INDEX(creditoss1 inx_creditoss1), +INDEX(bdinteg:si_direcciones_actual idx_diract_ctetpo)} a.*, numerociudad '
                ||' FROM creditossl a,  bdinteg:si_direcciones_actual d '
                || ' WHERE d.numcte = a.numcte '
                || ' AND d.tipo_dir = ''1'' '
                || ' into temp CreditoCiudad with no log; '*/
                --|| ' unload to '|| TRIM(cruta) || TRIM(cnomarchivo) ;



        LET cSQL2 = '">' || TRIM(cRuta) || 'Ejecuta_cart_linea_creatabla.sql';
        LET cSQL = trim(cSQL1) || cSQL2;
        SYSTEM cSQL;

        LET cSQL='chmod 777 '|| TRIM(cRuta)|| 'Ejecuta_cart_linea_creatabla.sql';
        SYSTEM cSQL;

        LET cSQL = 'dbaccess bdicred ' || TRIM(cRuta) || 'Ejecuta_cart_linea_creatabla.sql';
        SYSTEM cSQL;

        --Borra el archivo de control.
        LET cSQL = '' ;
        LET cSQL = 'rm ' || TRIM(cruta) || 'creditos_tab2.txt ' || TRIM(cruta) || 'Ejecuta_cart_linea_creatabla.sql';
        SYSTEM cSQL;


		CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCod_ret, 'Paso 3: Inicia Foreach Obtener info REVS monto,saldos,etc', '02') RETURNING cCod_retBit;  

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
        FOREACH                 
            SELECT a.numcte, a.num_credito, nvl(c.num_tarjeta,'0'), 0 Cuenta_eje, a.num_producto, b.sdo_capital, b.monto_vencido, 
                b.mto_venc_trasp, b.cap_tras_no_venci, b.sdo_cap_insoluto, b.monto_financiado, 
                round((b.sdo_moratorio + b.sdo_contab_mora) * (1+ s.iva),2) moratorio, nvl((select sum(interes_debe - interes_pagado) + 
                sum(iva_debe - iva_pagado) from bdicred:sd_amortiza_credito where a.empresa = empresa and a.num_credito = num_credito 
                and capital_status in ('2','7','6')),0) interes_iva, b.mto_fin_ven_trasp::integer mora_actual, a.status_cred, d.fecha_ult_pago, 
                nvl((select capital_debe - capital_pagado from bdicred:sd_amortiza_credito where a.empresa = empresa 
                and a.num_credito = num_credito and fecha_cuota = (select min(fecha_cuota) from bdicred:sd_amortiza_credito 
                where a.empresa = empresa and a.num_credito = num_credito and capital_status in ('2','7','6'))) + 
                round((b.sdo_moratorio + b.sdo_contab_mora) * (1+ s.iva),2) + (select sum(interes_debe - interes_pagado) + 
                sum(iva_debe - iva_pagado) from bdicred:sd_amortiza_credito where a.empresa = empresa and a.num_credito = num_credito 
                and capital_status in ('2','7','6')),0) pago_una_mora, a.sucursal, a.fecha_apertura, b.monto_otorgado, a.tasa_interes, 
                d.prox_fecha_pago, nvl((SELECT trim(valor) FROM bdicred:sd_param WHERE a.empresa = empresa and cod_param= '034'),'0') cat,
                1 + s.iva, a.tasa_moratorios, d.fecha_vencto, round(NVL(b.sdo_intereses,0) * (1 + s.iva),2),
                (b.monto_financiado - b.monto_vencido - b.mto_venc_trasp) mensualidad_actual, d.dia_corte, 
				(select resum.grupo from bdisolic:ss_resum_scor_fin resum where a.num_credito=resum.num_solicitud) grupo,
				trunc((dfecha_hoy - a.fecha_apertura)/30) antiguedad, 
				nvl(scr1.evaluacion,0), nvl(scr2.evaluacion,0), nvl(scr3.evaluacion,0), nvl(scr4.evaluacion,0),    --  ***************    cambio jahj Julio 2023
				nvl(mahis1.mto_fin_ven_trasp,0), nvl(mahis2.mto_fin_ven_trasp,0), nvl(mahis3.mto_fin_ven_trasp,0), --  ***************    cambio jahj Julio 2023
				nvl(mahis4.mto_fin_ven_trasp,0), nvl(mahis5.mto_fin_ven_trasp,0), nvl(mahis6.mto_fin_ven_trasp,0), --  ***************    cambio jahj Julio 2023
				cel.telefono, 0.00, CASE WHEN nvl(b.sdo_retenido,0) > 0 then nvl(b.sdo_retenido,0) else 0.00 end sdo_retenido,	b.act, 
				a.ejecutivo --  ***************    cambio jahj Julio 2023
                INTO
                vcliente, vcredito, vtarjeta, vcta_eje, vproducto, vsdo_capital, vmonto_vencido, vmtovenctrasp, vcaptrasnovenci, 
                vsdocapinsoluto, montofinanciado, vsdomoratorio, vinteresiva, vmoras, vstatuscred, vfechaultpago, pagounamora, vsucursal, 
                vfch_apertura, vmontootorgado, vtasainteres, vproxfchpago, vcat, mIvaSucursal, ctasamora, cfechavencto, vsdo_intereses,
                vmensualidad_act, sDiaCorte, vgrupo, vantiguedad, 
				vbcscore, vscoreprop, vficoscore, vbhscore,        									 --  ***************    cambio jahj Julio 2023
				vnovencidos1, vnovencidos2, vnovencidos3, vnovencidos4, vnovencidos5, vnovencidos6,      --  ***************    cambio jahj Julio 2023
				vcelular, vivatrasp, vretenido, cAct, 
				v_ejecutivo --  ***************    cambio jahj Julio 2023
            	from bdicred:creditossl_tab2 a       -- sd_maecred a   --  ***************    cambio jahj Julio 2023
                join bdicred:sd_maesdos b on (a.empresa = b.empresa and a.num_credito = b.num_credito) 
    			join bdicred:sd_maecredanexo d on (a.empresa = d.empresa and a.num_credito = d.num_credito) 
        		left outer join bdicred:sd_tarjeta c on (a.empresa = c.empresa and a.num_credito = c.num_credito and c.tipo_tarjeta = 'T' 
                                and secuencia = (select max(secuencia) from bdicred:sd_tarjeta where a.empresa = empresa 
                                and a.num_credito = num_credito and tipo_tarjeta = 'T')) 
				join bdinteg:si_sucursales s on ( s.empresa = a.empresa and s.sucursal = a.sucursal)
				
				left outer join bdisolic:ss_resumen_scoring scr1 on (a.num_credito=scr1.num_solicitud and scr1.seccion=1)
				left outer join bdisolic:ss_resumen_scoring scr2 on (a.num_credito=scr2.num_solicitud and scr2.seccion=2)
				left outer join bdisolic:ss_resumen_scoring scr3 on (a.num_credito=scr3.num_solicitud and scr3.seccion=3)
				left outer join bdisolic:ss_resumen_scoring scr4 on (a.num_credito=scr4.num_solicitud and scr4.seccion=4) 
				left outer join bdicred:sd_maesdoshist mahis1 on(a.num_credito=mahis1.num_credito and mahis1.fecha=add_months(a.fecha_his,-1)) --***** cambio jahj Julio 2023
				left outer join bdicred:sd_maesdoshist mahis2 on(a.num_credito=mahis2.num_credito and mahis2.fecha=add_months(a.fecha_his,-2)) --***** cambio jahj Julio 2023
				left outer join bdicred:sd_maesdoshist mahis3 on(a.num_credito=mahis3.num_credito and mahis3.fecha=add_months(a.fecha_his,-3)) --***** cambio jahj Julio 2023
				left outer join bdicred:sd_maesdoshist mahis4 on(a.num_credito=mahis4.num_credito and mahis4.fecha=add_months(a.fecha_his,-4)) --***** cambio jahj Julio 2023
				left outer join bdicred:sd_maesdoshist mahis5 on(a.num_credito=mahis5.num_credito and mahis5.fecha=add_months(a.fecha_his,-5)) --***** cambio jahj Julio 2023
				left outer join bdicred:sd_maesdoshist mahis6 on(a.num_credito=mahis6.num_credito and mahis6.fecha=add_months(a.fecha_his,-6)) --***** cambio jahj Julio 2023
				left outer join bdinteg:si_telefonos_actual cel on(a.numcte=cel.numcte and cel.secuencia=(select max(secuencia) 
																											from bdinteg:si_telefonos_actual
																											where a.numcte=numcte and tipo_tel=2 and status_tel='A'))
														
            IF NOT EXISTS (SELECT fecha, num_credito FROM bdicred:"informix".sd_sdos_cartera_linea 
                                                                      WHERE fecha = dFecha_hoy AND num_credito = vcredito) THEN

                -- Obtiene las fechas de meses de vencimiento
                IF cfechavencto IS NULL THEN LET cfechavencto = date(1); END IF;
                EXECUTE PROCEDURE bdicred:"informix".sp_mes_siguiente(cfechavencto, 1 , sDiaCorte) INTO cCod_Ret, cfechavencto1, sDiasTrans;
                EXECUTE PROCEDURE bdicred:"informix".sp_mes_siguiente(cfechavencto, 2 , sDiaCorte) INTO cCod_Ret, cfechavencto2, sDiasTrans;
                EXECUTE PROCEDURE bdicred:"informix".sp_mes_siguiente(cfechavencto, 3 , sDiaCorte) INTO cCod_Ret, cfechavencto3, sDiasTrans;
                EXECUTE PROCEDURE bdicred:"informix".sp_mes_siguiente(cfechavencto, 4 , sDiaCorte) INTO cCod_Ret, cfechavencto4, sDiasTrans;
                EXECUTE PROCEDURE bdicred:"informix".sp_mes_siguiente(cfechavencto, 5 , sDiaCorte) INTO cCod_Ret, cfechavencto5, sDiasTrans;

                -- Valida que las fechas sean fechas habiles, si no obtiene la fecha habil correcta.
                EXECUTE PROCEDURE bdicred:"informix".sp_valfechabil(cfechavencto1,'+') INTO cCod_Ret, cfecha_habil1;
                EXECUTE PROCEDURE bdicred:"informix".sp_valfechabil(cfechavencto2,'+') INTO cCod_Ret, cfecha_habil2;
                EXECUTE PROCEDURE bdicred:"informix".sp_valfechabil(cfechavencto3,'+') INTO cCod_Ret, cfecha_habil3;
                EXECUTE PROCEDURE bdicred:"informix".sp_valfechabil(cfechavencto4,'+') INTO cCod_Ret, cfecha_habil4;
                EXECUTE PROCEDURE bdicred:"informix".sp_valfechabil(cfechavencto5,'+') INTO cCod_Ret, cfecha_habil5;
                IF cfechavencto1 <> cfecha_habil1 THEN LET cfechavencto1 = cfecha_habil1; END IF;
                IF cfechavencto2 <> cfecha_habil2 THEN LET cfechavencto2 = cfecha_habil2; END IF;
                IF cfechavencto3 <> cfecha_habil3 THEN LET cfechavencto3 = cfecha_habil3; END IF;
                IF cfechavencto4 <> cfecha_habil4 THEN LET cfechavencto4 = cfecha_habil4; END IF;
                IF cfechavencto5 <> cfecha_habil5 THEN LET cfechavencto5 = cfecha_habil5; END IF;

                SELECT
                    sum(case when fecha_cuota = cfechavencto then nvl((capital_debe-capital_pagado),0) + NVL((interes_debe-interes_pagado+iva_debe-iva_pagado),0) else 0 end),
                    sum(case when fecha_cuota = cfechavencto then NVL(((mora_provi_ordi+mora_provi_cope+mora_sdo_ordi-mora_sdo_ordi_pag+mora_sdo_cope-mora_sdo_cope_pag)*mIvaSucursal),0) + nvl(((capital_debe-capital_pagado) * ctasamora / 36000) * 17.25,0)  else 0 end),
                    sum(case when fecha_cuota = cfechavencto1 then nvl((capital_debe-capital_pagado),0) + NVL((interes_debe-interes_pagado+iva_debe-iva_pagado),0) else 0 end),
                    sum(case when fecha_cuota = cfechavencto1 then NVL(((mora_provi_ordi+mora_provi_cope+mora_sdo_ordi-mora_sdo_ordi_pag+mora_sdo_cope-mora_sdo_cope_pag)*mIvaSucursal),0) + nvl(((capital_debe-capital_pagado) * ctasamora / 36000) * 17.25,0)  else 0 end),
                    sum(case when fecha_cuota = cfechavencto2 then nvl((capital_debe-capital_pagado),0) + NVL((interes_debe-interes_pagado+iva_debe-iva_pagado),0) else 0 end),
                    sum(case when fecha_cuota = cfechavencto2 then NVL(((mora_provi_ordi+mora_provi_cope+mora_sdo_ordi-mora_sdo_ordi_pag+mora_sdo_cope-mora_sdo_cope_pag)*mIvaSucursal),0) + nvl(((capital_debe-capital_pagado) * ctasamora / 36000) * 17.25,0)  else 0 end),
                    sum(case when fecha_cuota = cfechavencto3 then nvl((capital_debe-capital_pagado),0) + NVL((interes_debe-interes_pagado+iva_debe-iva_pagado),0) else 0 end),
                    sum(case when fecha_cuota = cfechavencto3 then NVL(((mora_provi_ordi+mora_provi_cope+mora_sdo_ordi-mora_sdo_ordi_pag+mora_sdo_cope-mora_sdo_cope_pag)*mIvaSucursal),0) + nvl(((capital_debe-capital_pagado) * ctasamora / 36000) * 17.25,0)  else 0 end),
                    sum(case when fecha_cuota = cfechavencto4 then nvl((capital_debe-capital_pagado),0) + NVL((interes_debe-interes_pagado+iva_debe-iva_pagado),0) else 0 end),
                    sum(case when fecha_cuota = cfechavencto4 then NVL(((mora_provi_ordi+mora_provi_cope+mora_sdo_ordi-mora_sdo_ordi_pag+mora_sdo_cope-mora_sdo_cope_pag)*mIvaSucursal),0) + nvl(((capital_debe-capital_pagado) * ctasamora / 36000) * 17.25,0)  else 0 end),
                    sum(case when fecha_cuota >= cfechavencto5 then nvl((capital_debe-capital_pagado),0) + NVL((interes_debe-interes_pagado+iva_debe-iva_pagado),0) else 0 end),
                    sum(case when fecha_cuota >= cfechavencto5 then NVL(((mora_provi_ordi+mora_provi_cope+mora_sdo_ordi-mora_sdo_ordi_pag+mora_sdo_cope-mora_sdo_cope_pag)*mIvaSucursal),0) + nvl(((capital_debe-capital_pagado) * ctasamora / 36000) * 17.25,0)  else 0 end),
                    sum(NVL((interes_debe-interes_pagado+iva_debe-iva_pagado),0)), count(*)
                    INTO
                    cSaldovencido1, cInteresmoratorio1, cSaldovencido2, cInteresmoratorio2,cSaldovencido3, cInteresmoratorio3, cSaldovencido4, 
                    cInteresmoratorio4, cSaldovencido5, cInteresmoratorio5, cSaldovencido6, cInteresmoratorio6, cInteresV, sAbonosVdos
                    from bdicred:sd_amortiza_credito
                    where empresa = pEmpresa and num_credito = vcredito and fecha_cuota >= cfechavencto and capital_status in ('2','7','6');
                    
                    --NUEVOS CAMPOS ADENDUM RQM 04 127
              
                    SELECT num_vencidos, dias_atraso, nvl(atm_disp_fecha_h,''), nvl(pos_disp_fecha_h,''), nvl(vnt_disp_fecha_h,'') --fecha_vencido, 
                    INTO  v_num_vencidos, v_dias_vencido, dUltDisp_atm, dUltDisp_pos, dUltDisp_vnt  --v_fecha_vencido,
                    FROM sd_indicador_cred
                    WHERE num_credito=vcredito;
					
--  				***************    cambio jahj Julio 2023	 se toma la consulta en la parte de arriba		
--					select fecha_vencto
--					into v_fecha_vencido
--					from bdicred:sd_maecredanexo
--					where num_credito=vcredito;
                    
					Let v_fecha_vencido = cfechavencto;       --  ***************    cambio jahj Julio 2023
					
					
					if dUltDisp_atm is null then let dUltDisp_atm = ''; end if;
					if dUltDisp_pos is null then let dUltDisp_pos = ''; end if;
					if dUltDisp_vnt is null then let dUltDisp_vnt = ''; end if;
					
					IF vproducto='7800' THEN
						SELECT MAX(fecha_mov) INTO dUltima_Disposicion
						FROM SD_MOVHIS
						where num_credito=vcredito AND codigo_fun='002' AND codigo_ref=111;
					ELSE
						IF (dUltDisp_atm > dUltDisp_pos) THEN
							IF (dUltDisp_atm >= dUltDisp_vnt) THEN
							   LET dUltima_Disposicion = dUltDisp_atm;
							ELSE
							   LET dUltima_Disposicion = dUltDisp_vnt;
							END IF;
						ELIF (dUltDisp_atm = dUltDisp_pos) THEN    
							IF (dUltDisp_pos >= dUltDisp_vnt) THEN
								LET dUltima_Disposicion = dUltDisp_pos;
							ELSE
								LET dUltima_Disposicion = dUltDisp_vnt;
							END IF;
						END IF;
					END IF;

--  				***************    cambio jahj Julio 2023				la consulta se coloca arriba en el txt	
--					SELECT ejecutivo INTO v_ejecutivo
--					FROM sd_maecred
--					WHERE num_credito=vcredito;
				

                INSERT INTO bdicred:"informix".sd_sdos_cartera_linea 
                    (fecha,numcte,num_credito,num_tarjeta,num_cta,num_producto,sdo_capital,monto_vencido,mto_venc_trasp,cap_tras_no_venci,
                    sdo_cap_insoluto,monto_financiado,moratorio,interes_iva,mto_fin_ven_trasp,status_cred,fecha_ult_pago,pago_una_mora,
                    sucursal,fecha_apertura,monto_otorgado,tasa_interes,prox_fecha_pago,cat, saldovencido1, saldovencido2, saldovencido3, 
                    saldovencido4, saldovencido5, saldovencido6, interesmoratorio1, interesmoratorio2, interesmoratorio3, interesmoratorio4, 
                    interesmoratorio5, interesmoratorio6, sdo_intereses, mensualidad_actual, grupo, antiguedad, bcscore, scoreprop, ficoscore,
					bhscore, novencidos1, novencidos2, novencidos3, novencidos4, novencidos5, novencidos6, celular, iva_int_trasp,sdo_retenido,
					dias_vencido, atr, act, fecha_vencido, fecha_ult_dispo, ejecutivo)
                    VALUES(dFecha_hoy, vcliente, vcredito, vtarjeta, vcta_eje, vproducto, vsdo_capital, vmonto_vencido, vmtovenctrasp, 
                    vcaptrasnovenci, vsdocapinsoluto, montofinanciado, vsdomoratorio, vinteresiva, vmoras, vstatuscred, vfechaultpago, 
                    pagounamora, vsucursal, vfch_apertura, vmontootorgado, vtasainteres, vproxfchpago, vcat, cSaldovencido1, cSaldovencido2, 
                    cSaldovencido3, cSaldovencido4, cSaldovencido5, cSaldovencido6, cInteresmoratorio1, cInteresmoratorio2, cInteresmoratorio3,  
                    cInteresmoratorio4, cInteresmoratorio5, cInteresmoratorio6, vsdo_intereses, vmensualidad_act, vgrupo, vantiguedad, vbcscore,
					vscoreprop, vficoscore, vbhscore, vnovencidos1, vnovencidos2, vnovencidos3, vnovencidos4, vnovencidos5, vnovencidos6, vcelular,
					vivatrasp,vretenido, v_dias_vencido, 0, cAct, v_fecha_vencido, dUltima_Disposicion,v_ejecutivo );
				
				LET v_cuenta_bloque = v_cuenta_bloque+1;
				
				IF v_cuenta_bloque = 30000 THEN 
				   CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCod_ret, '  Cuenta bloque REVS', '02') RETURNING cCod_retBit;   
				   LET v_cuenta_bloque = 0;
				END IF;
            END IF;

        END FOREACH;    

		CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCod_ret, 'Paso 3: Termina Foreach Obtener info REVS monto,saldos,etc', '02') RETURNING cCod_retBit;  
		
    END IF;

    LET v_cuenta_bloque = 0;
 	
    -- | Cliente | Credito | Tarjeta | Cuenta eje | Producto | sdo_capital | monto_vencido | mto_venc_trasp | cap_tras_no_venci | sdo_cap_insoluto | 
    -- | monto financiado | Int moratorio | interes_iva | No moras | status_cred | fecha_ult_pago | pago una mora | Sucursal | Fecha_apertura |  
    -- | monto_otorgado | tasa_interes | prox_fecha_pago | Cat | saldovencido1 |saldovencido2 |saldovencido3 | saldovencido4 | saldovencido5 |
    -- | saldovencido6 | interesmoratorio1 | interesmoratorio2 | interesmoratorio3 | interesmoratorio4 | interesmoratorio5 | interesmoratorio6 |

	-- ********************************************************************************************************************
	-- ********************************************************************************************************************
	-- ********************************************************************************************************************

    IF pServicio = '2' OR pServicio = '3' THEN      -- Obtiene informacion de Cartera de Prestamo Personal y Reestructura
		--AAME RQM 10 393 20150624 Se solicita contemplar los dos nuevos productos de prestamo personal (7600,7700)
        --AAME RQM 10 1177 Se agregan nuevos prestamos 9100,9300 y Reestructura 8600
		
		CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCod_ret, 'Paso 4: Obtiene info PLAZO', '02') RETURNING cCod_retBit;  
		
		DROP TABLE IF EXISTS tmp_creditos_crd;

        LET cSQL1 = ' echo " SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cruta) || 'tmp_creditos_crd.txt' 
                || ' SELECT  a.empresa, a.num_credito,a.numcte, a.num_producto, a.status_cred ,a.sucursal,a.fecha_apertura,a.tasa_interes,a.tasa_moratorios,a.credito_externo,a.ejecutivo '
                || ' FROM bdicred:sd_maecredcrd a, bdicred:sd_maesdoscrd b'
				|| ' WHERE a.num_credito = b.num_credito'
                || ' and a.status_cred in (''BT'',''BA'',''VP'',''E1'',''E2'',''E3'') AND a.num_producto IN (''6011'',''6300'',''6400'',''6800'',''7600'',''7700'',''8600'',''9100'',''9300'') '
				|| ' and (b.monto_vencido + b.mto_venc_trasp) > 0 ; '
				|| ' create table bdicred:tmp_creditos_crd('
				|| ' empresa char(3), '
				|| ' num_credito char(20), '
				|| ' numcte char(20), '
				|| ' num_producto char(4), '
				|| ' status_cred char(2), '
				|| ' sucursal char(4), ' 
				|| ' fecha_apertura date, '
				|| ' tasa_interes   decimal(9,6), '
				|| ' tasa_moratorios decimal(9,6), '
				|| ' credito_externo char(20), '
				|| ' ejecutivo char(8) '
                || '); '  
                || ' load from '|| TRIM(cruta) ||'tmp_creditos_crd.txt insert into tmp_creditos_crd;  '
                || ' create unique index inx_creditossl_crd on tmp_creditos_crd(numcte,sucursal,num_credito);'
                || ' update statistics medium for table tmp_creditos_crd resolution 1.6; ' ;
               
			  
        LET cSQL2 = '">' || TRIM(cRuta) || 'Ejecuta_cart_linea_creatabla_crd.sql';
        LET cSQL = trim(cSQL1) || cSQL2;
        SYSTEM cSQL;

        LET cSQL='chmod 777 '|| TRIM(cRuta)|| 'Ejecuta_cart_linea_creatabla_crd.sql';
        SYSTEM cSQL;

        LET cSQL = 'dbaccess bdicred ' || TRIM(cRuta) || 'Ejecuta_cart_linea_creatabla_crd.sql';
        SYSTEM cSQL;

        --Borra el archivo de control.
        LET cSQL = '' ;
        LET cSQL = 'rm ' || TRIM(cruta) || 'tmp_creditos_crd.txt ' || TRIM(cruta) || 'Ejecuta_cart_linea_creatabla_crd.sql';
        SYSTEM cSQL;


		--  ******************************************************    cambio jahj Julio 2023
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;		

		CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCod_ret, 'Paso 5: Inicia Foreach Obtener info PLAZO monto,saldos,etc', '02') RETURNING cCod_retBit;  
        FOREACH with hold 
            SELECT a.numcte, a.num_credito, 0 num_tarjeta, (SELECT num_cta FROM bdicred:sd_ctascarg WHERE a.num_credito = num_credito 
                AND naturaleza= 'A') Cta_eje, a.num_producto, b.sdo_capital, b.monto_vencido, b.mto_venc_trasp, b.cap_tras_no_venci, 
                b.sdo_cap_insoluto, b.monto_financiado, round((b.sdo_moratorio + b.sdo_contab_mora) * (1 + s.iva),2) moratorio,
                (b.int_tra_no_exig + b.mto_venc_int + b.sdo_no_exig + b.mto_finan_vdo) interes_iva,
                b.mto_fin_ven_trasp::integer mora_actual, 
				(case when (a.status_cred = 'VP' and b.mto_fin_ven_trasp = 1 and nvl(b.atr,0) = 0) then 'BA'
				      when (a.status_cred = 'VP' and b.mto_fin_ven_trasp > 1 and nvl(b.atr,0) = 0) then 'BT' 
				      when (a.status_cred = 'VP' and nvl(b.atr,0) = 1) then 'E1'  
					  when (a.status_cred = 'VP' and nvl(b.atr,0) in (2,3)) then 'E2'  
					  when (a.status_cred = 'VP' and nvl(b.atr,0) > 3) then 'E3'  
					  when (a.status_cred <> 'VP') then a.status_cred end) Status_Cred, 
                d.fecha_ult_pago, (SELECT (capital_debe - capital_pagado) + (interes_debe - interes_pagado) + (iva_debe - iva_pagado) +
                ((( mora_provi_ordi + mora_provi_cope) + ( mora_sdo_ordi - mora_sdo_ordi_pag) + ( mora_sdo_cope - mora_sdo_cope_pag)) * (1+ s.iva)) 
                FROM bdicred:sd_amortiza_creditocrd amort 
				WHERE a.empresa = amort.empresa AND a.num_credito = amort.num_credito AND amort.fecha_cuota = (SELECT min (fecha_cuota) FROM bdicred:sd_amortiza_creditocrd WHERE amort.empresa = empresa 
                AND amort.num_credito = num_credito AND capital_status IN ('2','7','6'))) Pago_una_mora, a.sucursal, a.fecha_apertura, b.monto_otorgado, 
                a.tasa_interes, d.prox_fecha_pago, (SELECT cat.cat FROM bdicred:sd_tasa_cat cat WHERE a.empresa = cat.empresa 
                AND a.tasa_interes = cat.tasa AND a.num_producto = cat.producto) cat, 1 + s.iva, a.tasa_moratorios, --d.fecha_vencto,
                (Select min(fecha_cuota) from bdicred:sd_amortiza_creditocrd WHERE a.empresa = empresa and a.num_credito = num_credito 
                 and capital_status in ('2','7','6')) fecha_vencto, round(NVL(b.sdo_intereses,0) * (1+ s.iva),2),
                nvl((SELECT (nvl(capital_debe,0) - nvl(capital_pagado,0)) + (nvl(interes_debe,0) - nvl(interes_pagado,0)) +
                (nvl(iva_debe,0) - nvl(iva_pagado,0)) FROM bdicred:sd_amortiza_creditocrd WHERE a.empresa = empresa
                AND a.num_credito = num_credito AND capital_status = 1 ),0) Mensualidad_Actual, d.dia_corte,
				(select resum.grupo from bdisolic:ss_resum_scor_fin resum where a.num_credito=resum.num_solicitud) grupo,
				trunc((dfecha_hoy - a.fecha_apertura)/30) antiguedad, 

				case when a.num_producto <> '6011' then nvl(scr1.evaluacion,0) else nvl(sRe1.evaluacion,0) end, 
				case when a.num_producto <> '6011' then nvl(scr2.evaluacion,0) else nvl(sRe2.evaluacion,0) end, 
				case when a.num_producto <> '6011' then nvl(scr3.evaluacion,0) else nvl(sRe3.evaluacion,0) end, 
				case when a.num_producto <> '6011' then nvl(scr4.evaluacion,0) else nvl(sRe4.evaluacion,0) end,	

				nvl(mhre1.mto_fin_ven_trasp,0), nvl(mhre2.mto_fin_ven_trasp,0), nvl(mhre3.mto_fin_ven_trasp,0), nvl(mhre4.mto_fin_ven_trasp,0),
				nvl(mhre5.mto_fin_ven_trasp,0), nvl(mhre6.mto_fin_ven_trasp,0),

				cel.telefono, nvl((SELECT (nvl(interes_debe,0) - nvl(interes_pagado,0)) + (nvl(iva_debe,0) - nvl(iva_pagado,0)) FROM bdicred:sd_amortiza_creditocrd 
				WHERE a.empresa = empresa AND a.num_credito = num_credito AND capital_status = 1 ),0) iva_int_trasp,
				CASE WHEN nvl(b.sdo_retenido,0) > 0 then nvl(b.sdo_retenido,0) else 0.00 end sdo_retenido, 
				b.atr, 
				d.fecha_vencto  --  ***************    cambio jahj Julio 2023
                INTO
                vcliente, vcredito, vtarjeta, vcta_eje, vproducto, vsdo_capital, vmonto_vencido, vmtovenctrasp, vcaptrasnovenci, vsdocapinsoluto, 
                montofinanciado, vsdomoratorio, vinteresiva, vmoras, vstatuscred, vfechaultpago, pagounamora, vsucursal, vfch_apertura, 
                vmontootorgado, vtasainteres, vproxfchpago, vcat, mIvaSucursal, ctasamora, cfechavencto, vsdo_intereses, vmensualidad_act, sDiaCorte,
				vgrupo, vantiguedad, 
				vbcscore, vscoreprop, vficoscore, vbhscore,   --  ***************    cambio jahj Julio 2023
				vnovencidos1, vnovencidos2, vnovencidos3, vnovencidos4, vnovencidos5, vnovencidos6,   --  ***************    cambio jahj Julio 2023
				vcelular, vivatrasp,vretenido, cAtr, 
				v_fecha_vencido   --  ***************    cambio jahj Julio 2023  De acuerdo a la lectura solo es para bajarlo al foreach
                FROM tmp_creditos_crd a
                JOIN bdicred:sd_maesdoscrd b ON (a.empresa = b.empresa AND a.num_credito = b.num_credito)
                JOIN bdicred:sd_maecredanexocrd d ON (a.empresa = d.empresa AND a.num_credito = d.num_credito)
                JOIN bdinteg:si_sucursales s ON (s.empresa = a.empresa AND s.sucursal = a.sucursal)

				left outer join bdisolic:ss_resumen_scoring scr1 on (a.num_credito=scr1.num_solicitud and scr1.seccion=1)
				left outer join bdisolic:ss_resumen_scoring scr2 on (a.num_credito=scr2.num_solicitud and scr2.seccion=2)
				left outer join bdisolic:ss_resumen_scoring scr3 on (a.num_credito=scr3.num_solicitud and scr3.seccion=3)
				left outer join bdisolic:ss_resumen_scoring scr4 on (a.num_credito=scr4.num_solicitud and scr4.seccion=4) 
				left outer join bdisolic:ss_resumen_scoring sRe1 on (a.credito_externo=sRe1.num_solicitud and sRe1.seccion=1)
				left outer join bdisolic:ss_resumen_scoring sRe2 on (a.credito_externo=sRe2.num_solicitud and sRe2.seccion=2)
				left outer join bdisolic:ss_resumen_scoring sRe3 on (a.credito_externo=sRe3.num_solicitud and sRe3.seccion=3)
				left outer join bdisolic:ss_resumen_scoring sRe4 on (a.credito_externo=sRe4.num_solicitud and sRe4.seccion=4) 
				left outer join bdicred:sd_maesdoshistcrd mhre1 on(a.num_credito=mhre1.num_credito and mhre1.fecha=add_months((select max(b.fecha) from bdicred:sd_maesdoshistcrd b where b.num_credito=a.num_credito),-1)) 
				left outer join bdicred:sd_maesdoshistcrd mhre2 on(a.num_credito=mhre2.num_credito and mhre2.fecha=add_months((select max(b.fecha) from bdicred:sd_maesdoshistcrd b where b.num_credito=a.num_credito),-2))
				left outer join bdicred:sd_maesdoshistcrd mhre3 on(a.num_credito=mhre3.num_credito and mhre3.fecha=add_months((select max(b.fecha) from bdicred:sd_maesdoshistcrd b where b.num_credito=a.num_credito),-3))
				left outer join bdicred:sd_maesdoshistcrd mhre4 on(a.num_credito=mhre4.num_credito and mhre4.fecha=add_months((select max(b.fecha) from bdicred:sd_maesdoshistcrd b where b.num_credito=a.num_credito),-4))
				left outer join bdicred:sd_maesdoshistcrd mhre5 on(a.num_credito=mhre5.num_credito and mhre5.fecha=add_months((select max(b.fecha) from bdicred:sd_maesdoshistcrd b where b.num_credito=a.num_credito),-5))
				left outer join bdicred:sd_maesdoshistcrd mhre6 on(a.num_credito=mhre6.num_credito and mhre6.fecha=add_months((select max(b.fecha) from bdicred:sd_maesdoshistcrd b where b.num_credito=a.num_credito),-6))

				left outer join bdinteg:si_telefonos_actual cel on(a.numcte=cel.numcte and cel.secuencia=(select max(secuencia) 
								from bdinteg:si_telefonos_actual where a.numcte=numcte and tipo_tel=2 and status_tel='A'))
--              WHERE (b.monto_vencido + b.mto_venc_trasp) > 0
--				b.monto_vencido + b.mto_venc_trasp > 0
--              ORDER BY a.num_producto ASC

            IF NOT EXISTS (SELECT fecha, num_credito FROM bdicred:"informix".sd_sdos_cartera_linea 
                                                                      WHERE fecha = dFecha_hoy AND num_credito = vcredito) THEN

                -- Obtiene las fechas de meses de vencimiento
                IF cfechavencto IS NULL THEN LET cfechavencto = date(1); END IF;
                EXECUTE PROCEDURE bdicred:"informix".sp_mes_siguiente(cfechavencto, 1 , sDiaCorte) INTO cCod_Ret, cfechavencto1, sDiasTrans;
                EXECUTE PROCEDURE bdicred:"informix".sp_mes_siguiente(cfechavencto, 2 , sDiaCorte) INTO cCod_Ret, cfechavencto2, sDiasTrans;
                EXECUTE PROCEDURE bdicred:"informix".sp_mes_siguiente(cfechavencto, 3 , sDiaCorte) INTO cCod_Ret, cfechavencto3, sDiasTrans;
                EXECUTE PROCEDURE bdicred:"informix".sp_mes_siguiente(cfechavencto, 4 , sDiaCorte) INTO cCod_Ret, cfechavencto4, sDiasTrans;
                EXECUTE PROCEDURE bdicred:"informix".sp_mes_siguiente(cfechavencto, 5 , sDiaCorte) INTO cCod_Ret, cfechavencto5, sDiasTrans;

                -- Valida que las fechas sean fechas habiles, si no obtiene la fecha habil correcta.
                EXECUTE PROCEDURE bdicred:"informix".sp_valfechabil(cfechavencto1,'+') INTO cCod_Ret, cfecha_habil1;
                EXECUTE PROCEDURE bdicred:"informix".sp_valfechabil(cfechavencto2,'+') INTO cCod_Ret, cfecha_habil2;
                EXECUTE PROCEDURE bdicred:"informix".sp_valfechabil(cfechavencto3,'+') INTO cCod_Ret, cfecha_habil3;
                EXECUTE PROCEDURE bdicred:"informix".sp_valfechabil(cfechavencto4,'+') INTO cCod_Ret, cfecha_habil4;
                EXECUTE PROCEDURE bdicred:"informix".sp_valfechabil(cfechavencto5,'+') INTO cCod_Ret, cfecha_habil5;
                IF cfechavencto1 != cfecha_habil1 THEN LET cfechavencto1 = cfecha_habil1; END IF;
                IF cfechavencto2 != cfecha_habil2 THEN LET cfechavencto2 = cfecha_habil2; END IF;
                IF cfechavencto3 != cfecha_habil3 THEN LET cfechavencto3 = cfecha_habil3; END IF;
                IF cfechavencto4 != cfecha_habil4 THEN LET cfechavencto4 = cfecha_habil4; END IF;
                IF cfechavencto5 != cfecha_habil5 THEN LET cfechavencto5 = cfecha_habil5; END IF;


                SELECT
                    sum(case when fecha_cuota = cfechavencto then nvl((capital_debe-capital_pagado),0) + NVL((interes_debe-interes_pagado+iva_debe-iva_pagado),0) else 0 end),
                    sum(case when fecha_cuota = cfechavencto then NVL(((mora_provi_ordi+mora_provi_cope+mora_sdo_ordi-mora_sdo_ordi_pag+mora_sdo_cope-mora_sdo_cope_pag)*mIvaSucursal),0) + nvl(((capital_debe-capital_pagado) * ctasamora / 36000) * 17.25,0)  else 0 end),
                    sum(case when fecha_cuota = cfechavencto1 then nvl((capital_debe-capital_pagado),0) + NVL((interes_debe-interes_pagado+iva_debe-iva_pagado),0) else 0 end),
                    sum(case when fecha_cuota = cfechavencto1 then NVL(((mora_provi_ordi+mora_provi_cope+mora_sdo_ordi-mora_sdo_ordi_pag+mora_sdo_cope-mora_sdo_cope_pag)*mIvaSucursal),0) + nvl(((capital_debe-capital_pagado) * ctasamora / 36000) * 17.25,0)  else 0 end),
                    sum(case when fecha_cuota = cfechavencto2 then nvl((capital_debe-capital_pagado),0) + NVL((interes_debe-interes_pagado+iva_debe-iva_pagado),0) else 0 end),
                    sum(case when fecha_cuota = cfechavencto2 then NVL(((mora_provi_ordi+mora_provi_cope+mora_sdo_ordi-mora_sdo_ordi_pag+mora_sdo_cope-mora_sdo_cope_pag)*mIvaSucursal),0) + nvl(((capital_debe-capital_pagado) * ctasamora / 36000) * 17.25,0)  else 0 end),
                    sum(case when fecha_cuota = cfechavencto3 then nvl((capital_debe-capital_pagado),0) + NVL((interes_debe-interes_pagado+iva_debe-iva_pagado),0) else 0 end),
                    sum(case when fecha_cuota = cfechavencto3 then NVL(((mora_provi_ordi+mora_provi_cope+mora_sdo_ordi-mora_sdo_ordi_pag+mora_sdo_cope-mora_sdo_cope_pag)*mIvaSucursal),0) + nvl(((capital_debe-capital_pagado) * ctasamora / 36000) * 17.25,0)  else 0 end),
                    sum(case when fecha_cuota = cfechavencto4 then nvl((capital_debe-capital_pagado),0) + NVL((interes_debe-interes_pagado+iva_debe-iva_pagado),0) else 0 end),
                    sum(case when fecha_cuota = cfechavencto4 then NVL(((mora_provi_ordi+mora_provi_cope+mora_sdo_ordi-mora_sdo_ordi_pag+mora_sdo_cope-mora_sdo_cope_pag)*mIvaSucursal),0) + nvl(((capital_debe-capital_pagado) * ctasamora / 36000) * 17.25,0)  else 0 end),
                    sum(case when fecha_cuota >= cfechavencto5 then nvl((capital_debe-capital_pagado),0) + NVL((interes_debe-interes_pagado+iva_debe-iva_pagado),0) else 0 end),
                    sum(case when fecha_cuota >= cfechavencto5 then NVL(((mora_provi_ordi+mora_provi_cope+mora_sdo_ordi-mora_sdo_ordi_pag+mora_sdo_cope-mora_sdo_cope_pag)*mIvaSucursal),0) + nvl(((capital_debe-capital_pagado) * ctasamora / 36000) * 17.25,0)  else 0 end),
                    sum(NVL((interes_debe-interes_pagado+iva_debe-iva_pagado),0)), count(*)
                    INTO
                    cSaldovencido1, cInteresmoratorio1, cSaldovencido2, cInteresmoratorio2,cSaldovencido3, cInteresmoratorio3, cSaldovencido4, 
                    cInteresmoratorio4, cSaldovencido5, cInteresmoratorio5, cSaldovencido6, cInteresmoratorio6, cInteresV, sAbonosVdos
                    from bdicred:sd_amortiza_creditocrd b
                    where empresa = pEmpresa and num_credito = vcredito and fecha_cuota >= cfechavencto and capital_status in ('1','2','7','6');
                                        
                    SELECT  num_vencidos_ch, dias_atraso  --fecha_vencido,
                    INTO  v_num_vencidos, v_dias_vencido  --v_fecha_vencido,
                    FROM sd_indicador_cred_crd
                    WHERE num_credito=vcredito;
					
--  				***************    cambio jahj Julio 2023 recuperamos el dato en la consulta principal
--					select fecha_vencto
--					into v_fecha_vencido
--					from bdicred:sd_maecredanexocrd 
--					where num_credito=vcredito;
					
					
				IF vproducto='6800' THEN
					SELECT MAX(fecha_insert) INTO dUltima_Disposicion
					FROM sd_maecredcrd_flex
					where num_credito=vcredito;
				ELSE
					SELECT fecha_apertura INTO dUltima_Disposicion
					FROM sd_maecredcrd WHERE num_credito=vcredito;
				END IF;

--  				***************    cambio jahj Julio 2023 recuperamos el dato en la consulta principal
--					SELECT ejecutivo INTO v_ejecutivo
--					FROM sd_maecredcrd
--					WHERE num_credito=vcredito;



                INSERT INTO bdicred:"informix".sd_sdos_cartera_linea 
                    (fecha,numcte,num_credito,num_tarjeta,num_cta,num_producto,sdo_capital,monto_vencido,mto_venc_trasp,cap_tras_no_venci,
                    sdo_cap_insoluto,monto_financiado,moratorio,interes_iva,mto_fin_ven_trasp,status_cred,fecha_ult_pago,pago_una_mora,
                    sucursal,fecha_apertura,monto_otorgado,tasa_interes,prox_fecha_pago,cat,saldovencido1, saldovencido2, saldovencido3, 
                    saldovencido4, saldovencido5, saldovencido6, interesmoratorio1, interesmoratorio2, interesmoratorio3, interesmoratorio4, 
                    interesmoratorio5, interesmoratorio6, sdo_intereses, mensualidad_actual, grupo, antiguedad, bcscore, scoreprop, ficoscore,
					bhscore, novencidos1, novencidos2, novencidos3, novencidos4, novencidos5, novencidos6, celular, iva_int_trasp, sdo_retenido,
					dias_vencido, atr, act, fecha_vencido, fecha_ult_dispo, ejecutivo)
                    VALUES(dFecha_hoy, vcliente, vcredito, vtarjeta, vcta_eje, vproducto, vsdo_capital, vmonto_vencido, vmtovenctrasp, 
                    vcaptrasnovenci, vsdocapinsoluto, montofinanciado, vsdomoratorio, vinteresiva, vmoras, vstatuscred, vfechaultpago, 
                    pagounamora, vsucursal, vfch_apertura, vmontootorgado, vtasainteres, vproxfchpago, vcat, cSaldovencido1, cSaldovencido2, 
                    cSaldovencido3, cSaldovencido4, cSaldovencido5, cSaldovencido6, cInteresmoratorio1, cInteresmoratorio2, cInteresmoratorio3,  
                    cInteresmoratorio4, cInteresmoratorio5, cInteresmoratorio6, vsdo_intereses, vmensualidad_act, vgrupo, vantiguedad, vbcscore,
					vscoreprop, vficoscore, vbhscore, vnovencidos1, vnovencidos2, vnovencidos3, vnovencidos4, vnovencidos5, vnovencidos6, vcelular,
					vivatrasp, vretenido, v_dias_vencido, cAtr, 0, v_fecha_vencido, dUltima_Disposicion,v_ejecutivo);

					
				LET v_cuenta_bloque = v_cuenta_bloque+1;
				
				IF v_cuenta_bloque = 30000 THEN 
				   CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCod_ret, '  Cuenta bloque PLAZO', '02') RETURNING cCod_retBit;   
				   LET v_cuenta_bloque = 0;
				END IF;	
					
            END IF;
			
        END FOREACH;     


		CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCod_ret, 'Paso 5: Termina Foreach Obtener info PLAZO monto,saldos,etc', '02') RETURNING cCod_retBit;  
		
    END IF;          


    IF pServicio = '2' OR pServicio = '3' THEN
        DROP TABLE bdicred:tmp_creditos_crd;
    END IF;

    IF pServicio = '1' OR pServicio = '3' THEN
        DROP TABLE bdicred:creditossl_tab2;
    END IF;
    LET cCod_Ret = '000000';
    LET cMensajeRet = 'PROCESO CONCLUIDO';
    
    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCod_ret, 'FINALIZA sp_genera_carteraenlinea_tab', '02') RETURNING cCod_retBit;       
    RETURN cCod_ret,cMensajeRet;

END;
END PROCEDURE;
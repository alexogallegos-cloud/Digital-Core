CREATE PROCEDURE "informix".encabezado2_edocta(pEmpresa CHAR(3),pNumCredito CHAR(20),pFechaEmision char(10))

RETURNING CHAR(5),          DATE ,    			CHAR(20),    		DECIMAL(14,2),
		                    DECIMAL(14,2),	    DECIMAL(14,2),	    DATE,
		                    DATE,				DECIMAL(14,2),		DECIMAL(14,2),
                            DECIMAL(14,2),	    DECIMAL(14,2),		DECIMAL(14,2),
					        DECIMAL(14,2),	    DECIMAL(14,2),		DECIMAL(14,2),
                            DECIMAL(14,2),      DECIMAL(14,2),		CHAR(560),
                            DECIMAL(14,2),      DECIMAL(14,2),		DECIMAL(14,2),
                            DECIMAL(14,2),      DECIMAL(14,2),		DECIMAL(14,2),
                            DECIMAL(14,2),      DECIMAL(14,2),		DECIMAL(14,2),
                            DECIMAL(14,2),      DATE,			    DATE,
                            CHAR(255),          DECIMAL(14,2),      DECIMAL(14,2),
                            DECIMAL(14,2),      DECIMAL(14,2),      DECIMAL(14,2),
                            DECIMAL(14,2);

--------------------------------------------------------
--	VARIABLES GENERACION ENCABEZADO2 EDO CUENTA
--------------------------------------------------------
DEFINE sql_err   SMALLINT;
DEFINE sCodRet   CHAR(5);

DEFINE v_fecha_emision 		DATE ;
DEFINE v_num_credito 			CHAR(20);

DEFINE v_sdo_pagar 						DECIMAL(14,2);
DEFINE v_sdo_debe 						DECIMAL(14,2);
DEFINE v_sdo_disponible 			DECIMAL(14,2);
DEFINE v_pago_antes_de 				DATE;
DEFINE v_fecha_corte 					DATE;
DEFINE v_usted_debia 					DECIMAL(14,2);
DEFINE v_menos_abonos 				DECIMAL(14,2);
DEFINE v_menos_o_abonos 			DECIMAL(14,2);
DEFINE v_mas_compras 					DECIMAL(14,2);
DEFINE v_mas_o_cargos 				DECIMAL(14,2);
DEFINE v_mas_disp_efectivo 		DECIMAL(14,2);
DEFINE v_mas_intereses 				DECIMAL(14,2);
DEFINE v_mas_iva 							DECIMAL(14,2);
DEFINE v_usted_debe 					DECIMAL(14,2);
DEFINE v_mas_rendimientos 		DECIMAL(14,2);
DEFINE v_mensajes 						CHAR(560);
DEFINE v_capital_tc 					DECIMAL(14,2);
DEFINE v_interes_tc 					DECIMAL(14,2);
DEFINE v_iva_interes_tc 			DECIMAL(14,2);
DEFINE v_capital_ven_tc 			DECIMAL(14,2);
DEFINE v_interes_ven_tc 			DECIMAL(14,2);
DEFINE v_iva_interes_ven_tc 	DECIMAL(14,2);
DEFINE v_moratorios_tc 				DECIMAL(14,2);
DEFINE v_iva_moratorios_tc 		DECIMAL(14,2);
DEFINE v_interes_pago_total_tc DECIMAL(14,2);
DEFINE v_limite_tc 						DECIMAL(14,2);
DEFINE v_periodo_tc_ini 			DATE;
DEFINE v_periodo_tc_fin 			DATE;
DEFINE v_dias_periodo_tc 			CHAR(255);
DEFINE v_sus_comisiones				DECIMAL(14,2);
--INICIO-----LHM 
DEFINE v_comisiones_iva      DECIMAL(14,2);
DEFINE v_intereses_iva       DECIMAL(14,2);
DEFINE v_intereses_pag       DECIMAL(14,2);
DEFINE v_saldos_menos_pag    DECIMAL(14,2);
DEFINE v_compras_disp        DECIMAL(14,2);
--FIN--------LHM


--------------------------------------------------------
--	VARIABLES GENERACION ENCABEZADO EDO CUENTA
--------------------------------------------------------
LET sql_err   = 0;
LET sCodRet   = '000';

LET v_fecha_emision 		= " ";
LET v_num_credito 			= "";

LET v_sdo_pagar 				= 0;
LET v_sdo_debe 					= 0;
LET v_sdo_disponible 		= 0;
LET v_pago_antes_de 		= " ";
LET v_fecha_corte 			= " ";
LET v_usted_debia 			= 0;
LET v_menos_abonos 			= 0;
LET v_menos_o_abonos 		= 0;
LET v_mas_compras 			= 0;
LET v_mas_o_cargos 			= 0;
LET v_mas_disp_efectivo = 0;
LET v_mas_intereses 		= 0;
LET v_mas_iva 					= 0;
LET v_usted_debe 				= 0;
LET v_mas_rendimientos 	= 0;
LET v_mensajes 					= "";
LET v_capital_tc 				= 0;
LET v_interes_tc 				= 0;
LET v_iva_interes_tc 		= 0;
LET v_capital_ven_tc 		= 0;
LET v_interes_ven_tc 		= 0;
LET v_iva_interes_ven_tc = 0;
LET v_moratorios_tc 		= 0;
LET v_iva_moratorios_tc = 0;
LET v_interes_pago_total_tc = 0;
LET v_limite_tc 				= 0;
LET v_periodo_tc_ini 		= " ";
LET v_periodo_tc_fin 		= " ";
LET v_dias_periodo_tc 	= "";
LET v_sus_comisiones		= 0;
--INICIO-----LHM 
LET v_comisiones_iva     = 0;
LET v_intereses_iva      = 0;
LET v_intereses_pag      = 0;
LET v_saldos_menos_pag   = 0;
LET v_compras_disp       = 0;



--SET DEBUG FILE TO "encabezado2_edocta.out";
--TRACE ON;

BEGIN

		ON EXCEPTION SET sql_err
      LET sCodRet = sql_err;
      RETURN sCodRet, 
				nvl(v_fecha_emision,date(1)),NVL(v_num_credito,""),				NVL(v_sdo_pagar,0),
				NVL(v_sdo_debe,0),			NVL(v_sdo_disponible,0),			NVL(v_pago_antes_de,0),
				nvl(v_fecha_corte,date(1)),				NVL(v_usted_debia,0),				NVL(v_menos_abonos,0),
				NVL(v_menos_o_abonos,0),	NVL(v_mas_compras,0),				NVL(v_mas_o_cargos,0),
				NVL(v_mas_disp_efectivo,0),	NVL(v_mas_intereses,0),             NVL(v_mas_iva,0),
				NVL(v_usted_debe,0),		NVL(v_mas_rendimientos,0),          NVL(v_mensajes,""),
				NVL(v_capital_tc,0),		NVL(v_interes_tc,0),				NVL(v_iva_interes_tc,0),
				NVL(v_capital_ven_tc,0),	NVL(v_interes_ven_tc,0),			NVL(v_iva_interes_ven_tc,0),
				NVL(v_moratorios_tc,0),		NVL(v_iva_moratorios_tc,0),         NVL(v_interes_pago_total_tc,0),
				NVL(v_limite_tc,0),			NVL(v_periodo_tc_ini,DATE(1)),		NVL(v_periodo_tc_fin,DATE(1)),
				NVL(v_dias_periodo_tc,""),	NVL(v_sus_comisiones,0),            NVL(v_comisiones_iva,0),
                NVL(v_intereses_iva,0),     NVL(v_intereses_pag,0),             NVL(v_saldos_menos_pag,0),
                NVL(v_compras_disp,0);
     END EXCEPTION ;


  -------------------------------------------------------------
  --GENERACION ENCABEZADO EDO CUENTA
  -------------------------------------------------------------
	SELECT		fecha_emision,		   num_credito,				sdo_pagar,
				sdo_debe,			   sdo_disponible,			pago_antes_de,
				fecha_corte,		   usted_debia,				menos_abonos,
				menos_o_abonos,		   mas_compras,				mas_o_cargos,
				mas_disp_efectivo,	   mas_intereses,			mas_iva,
				usted_debe,			   mas_rendimientos,		mensajes,
				capital_tc,			   interes_tc,				iva_interes_tc,
				capital_ven_tc,		   interes_ven_tc,			iva_interes_ven_tc,
				moratorios_tc,		   iva_moratorios_tc,	    interes_pago_total_tc,
				limite_tc,			   periodo_tc_ini,			periodo_tc_fin,
				dias_periodo_tc,	   sus_comisiones,          comisiones_iva,
                intereses_iva,         intereses_pag,           saldo_menos_pag,
                compras_disp
	INTO		v_fecha_emision,	   v_num_credito,			v_sdo_pagar,
				v_sdo_debe,			   v_sdo_disponible,		v_pago_antes_de,
				v_fecha_corte,		   v_usted_debia,			v_menos_abonos,
				v_menos_o_abonos,	   v_mas_compras,			v_mas_o_cargos,
				v_mas_disp_efectivo,   v_mas_intereses,			v_mas_iva,
				v_usted_debe,		   v_mas_rendimientos,		v_mensajes,
				v_capital_tc,		   v_interes_tc,			v_iva_interes_tc,
				v_capital_ven_tc,	   v_interes_ven_tc,		v_iva_interes_ven_tc,
				v_moratorios_tc,	   v_iva_moratorios_tc,	    v_interes_pago_total_tc,
				v_limite_tc,		   v_periodo_tc_ini,		v_periodo_tc_fin,
				v_dias_periodo_tc,	   v_sus_comisiones,         v_comisiones_iva,
                v_intereses_iva,       v_intereses_pag,         v_saldos_menos_pag,
                v_compras_disp

	 --FROM sd_encabezado2_edocta
	 FROM bdicred@pld_tcp:sd_encabezado2_edocta
	 WHERE fecha_emision = pFechaEmision 
	 		AND num_credito = pNumCredito;

	IF v_num_credito IS NULL THEN
		LET sCodRet = "185";
      RETURN sCodRet, 
				nvl(v_fecha_emision,date(1)),NVL(v_num_credito,""),				NVL(v_sdo_pagar,0),
				NVL(v_sdo_debe,0),			NVL(v_sdo_disponible,0),			NVL(v_pago_antes_de,0),
				nvl(v_fecha_corte,date(1)),				NVL(v_usted_debia,0),				NVL(v_menos_abonos,0),
				NVL(v_menos_o_abonos,0),	NVL(v_mas_compras,0),				NVL(v_mas_o_cargos,0),
				NVL(v_mas_disp_efectivo,0),	NVL(v_mas_intereses,0),             NVL(v_mas_iva,0),
				NVL(v_usted_debe,0),		NVL(v_mas_rendimientos,0),          NVL(v_mensajes,""),
				NVL(v_capital_tc,0),		NVL(v_interes_tc,0),				NVL(v_iva_interes_tc,0),
				NVL(v_capital_ven_tc,0),	NVL(v_interes_ven_tc,0),			NVL(v_iva_interes_ven_tc,0),
				NVL(v_moratorios_tc,0),		NVL(v_iva_moratorios_tc,0),         NVL(v_interes_pago_total_tc,0),
				NVL(v_limite_tc,0),			NVL(v_periodo_tc_ini,DATE(1)),		NVL(v_periodo_tc_fin,DATE(1)),
				NVL(v_dias_periodo_tc,""),	NVL(v_sus_comisiones,0),            NVL(v_comisiones_iva,0),
                NVL(v_intereses_iva,0),     NVL(v_intereses_pag,0),             NVL(v_saldos_menos_pag,0),
                NVL(v_compras_disp,0);
	END IF

  RETURN sCodRet, 
				v_fecha_emision,			NVL(v_num_credito,""),				NVL(v_sdo_pagar,0),
				NVL(v_sdo_debe,0),			NVL(v_sdo_disponible,0),			NVL(v_pago_antes_de,0),
				v_fecha_corte,				NVL(v_usted_debia,0),				NVL(v_menos_abonos,0),
				NVL(v_menos_o_abonos,0),	NVL(v_mas_compras,0),				NVL(v_mas_o_cargos,0),
				NVL(v_mas_disp_efectivo,0),	NVL(v_mas_intereses,0),             NVL(v_mas_iva,0),
				NVL(v_usted_debe,0),		NVL(v_mas_rendimientos,0),          NVL(v_mensajes,""),
				NVL(v_capital_tc,0),		NVL(v_interes_tc,0),				NVL(v_iva_interes_tc,0),
				NVL(v_capital_ven_tc,0),	NVL(v_interes_ven_tc,0),			NVL(v_iva_interes_ven_tc,0),
				NVL(v_moratorios_tc,0),		NVL(v_iva_moratorios_tc,0),         NVL(v_interes_pago_total_tc,0),
				NVL(v_limite_tc,0),			NVL(v_periodo_tc_ini,DATE(1)),		NVL(v_periodo_tc_fin,DATE(1)),
				NVL(v_dias_periodo_tc,""),	NVL(v_sus_comisiones,0),            NVL(v_comisiones_iva,0),
                NVL(v_intereses_iva,0),     NVL(v_intereses_pag,0),             NVL(v_saldos_menos_pag,0),
                NVL(v_compras_disp,0);

END;

END PROCEDURE DOCUMENT "Version 1.00.000";

CREATE PROCEDURE "informix".sp_genarch_aumlcr_real (pempresa CHAR(3), pfechacorte date)

RETURNING CHAR(6);

----------------------------------------------------------------------------------------------------------------
-- Creado por: Martha A. Hernandez 
-- 06 Octubre 2011
-- Proceso para la creacion del archivo con los aumentos de lcr aceptadoss por los clientes en el mes anterior
----------------------------------------------------------------------------------------------------------------

--Declaracion de variables
DEFINE sql_err				INTEGER;
DEFINE isam_err				INTEGER;
DEFINE error_info			CHAR(80);
DEFINE cMensaje				CHAR(80);
DEFINE cCod_ret				CHAR(6);
DEFINE vproceso				CHAR(30);
DEFINE vprocesoIncLcr		CHAR(30);
DEFINE cruta                CHAR(100);
DEFINE cnombre				CHAR(100);
DEFINE cnomarchivo          CHAR(100);
DEFINE cnomarchivo1			CHAR(100);
DEFINE cSQL                 CHAR(8204);
DEFINE cSQL1                CHAR(6204);
DEFINE cSQL2                CHAR(6204);
DEFINE cSQL3                CHAR(100);
DEFINE cempresa             CHAR(3);
DEFINE cdelimitador         CHAR(1);
DEFINE cCod_RetIB           CHAR(6);
DEFINE dFechaProcIni        DATE;
DEFINE dFechaProcFin        DATE;
DEFINE dFechaHoy            DATE;
DEFINE cCodRetMesAnt        CHAR(6);
DEFINE cFechaMesAnt         DATE;
DEFINE sDiasTransMesAnt     INT;


--SET DEBUG FILE TO "/informix/mahr/sp_genarch_aumlcr_real.out";
--TRACE ON;

--Inicialización de variables
LET sql_err                 = 0;
LET isam_err                = 0;
LET error_info              = "";
LET cCod_Ret                = "000000";
LET cMensaje                = 'PROCESO EXITOSO';
LET vproceso				= '0021';  -- proceso de incrementos realizados en el mes previo.
LET vprocesoIncLcr			= '0104';  -- proceso de incremento de lcr preautorizado ( sp_cat_genarch_aumlincred ) (ant 0020)
LET cruta                   = "";
LET cnombre					= "";
LET cnomarchivo             = "";
LET cnomarchivo1			= "";
LET cSQL                    = "";
LET cSQL1                   = "";
LET cSQL2                   = "";
LET cSQL3                   = "";
LET cempresa                = "001";
LET cdelimitador            = "";
LET cCod_RetIB              = "000000";
LET dFechaProcIni           = DATE(1);
LET dFechaProcFin           = DATE(1);
LET cCodRetMesAnt           = "";
LET sDiasTransMesAnt        = 0;

BEGIN

    ON EXCEPTION SET sql_err, isam_err, error_info
        LET cCod_ret = sql_err;
        LET cMensaje = error_info;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCod_ret, cMensaje, '02')
                Returning cCod_RetIB;
        RETURN cCod_ret;
    END EXCEPTION;
	
    --Directiva para lectura de tablas bloqueadas.
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCod_ret, cMensaje, '01')
            Returning cCod_RetIB;

	-- Validacion de parámetros de entrada
    IF NVL(pEmpresa,"") = "" OR NVL(pfechacorte, "") = "" THEN
        LET cCod_Ret= "104001";

        SELECT descripcion INTO cMensaje
            FROM bdicobranza:"informix".cb_errores
            WHERE origen = 3  AND codigo_error = cCod_Ret;
        IF cMensaje IS NULL THEN
            LET cMensaje = "";
        END IF;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCod_ret, cMensaje, '02')
            Returning cCod_RetIB;
        Return cCod_Ret;
	END IF;

	--Validación de la empresa
    SELECT empresa INTO cempresa
        FROM bdinteg:"informix".si_empresas WHERE empresa = pempresa;

        IF NVL (cempresa, '') = '' OR cempresa IS NULL THEN
        LET cCod_Ret= '104002';
        SELECT descripcion INTO cMensaje
            FROM bdicobranza:"informix".cb_errores
            WHERE origen = 3 AND codigo_error = cCod_Ret;
        IF cMensaje IS NULL THEN
            LET cMensaje = "";
        END IF;

        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCod_ret, cMensaje, '02')
            Returning cCod_RetIB;
        Return cCod_Ret;
	END IF;

    -- Obtiene las fechas para obtener la consulta de los datos entregados como preautorizados en el mes anterior.
    SELECT pri_dia_mes, fecha_hoy INTO dFechaProcIni, dFechaProcFin
      FROM bdinteg:"informix".si_fechas  WHERE empresa = pempresa;

    IF dFechaProcIni IS NULL OR dFechaProcFin IS NULL THEN
        LET cCod_Ret=  '20013';
        SELECT descripcion INTO cMensaje
            FROM bdicobranza:"informix".cb_errores
            WHERE origen = 2 AND codigo_error = cCod_Ret;
        IF cMensaje IS NULL THEN
            LET cMensaje = "";
        END IF;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCod_ret, cMensaje, '02')
            Returning cCod_RetIB;
        Return cCod_Ret;
    END IF
    LET dFechaHoy = dFechaProcFin; --dFechaHoy fecha de ejecucion y que lleve la fecha en el nombre del arch

    --LET dFechaProcIni = dFechaHoy - 1 UNITS MONTH;
    EXECUTE PROCEDURE bdicred:"informix".sp_mes_siguiente(dFechaHoy, -1 , day(dFechaHoy)) INTO cCodRetMesAnt, cFechaMesAnt, sDiasTransMesAnt;
    LET dFechaProcIni = cFechaMesAnt;

    LET dFechaProcIni = MDY(MONTH(dFechaProcIni),1, YEAR(dFechaProcIni)); -- 1er dia del mes anterior. 

            --obtiene la ultima fecha_OK de proceso de incrementos preautorizados del mes anterior.
    SELECT MAX(fecha_ejecucion) INTO dFechaProcFin FROM bdicobranza:"informix".cb_bitacora
        WHERE empresa = pempresa AND num_proceso = vprocesoIncLcr 
            AND (fecha_ejecucion >= dFechaProcIni AND fecha_ejecucion <= cFechaMesAnt ) --(dFechaHoy - 1 UNITS MONTH))
        AND cod_ret = '000000' and mensaje = 'PROCESO FINALIZADO';

    IF dFechaProcFin IS NULL THEN
            -- en caso de NO obtener la ultima fecha OK del mes anterior. Fecha fin = Hoy - 1 mes
        LET dFechaProcFin = cFechaMesAnt; -- dFechaHoy - 1 UNITS MONTH;
    END IF;
   
	--Obtener caracter delimitador  (mismo que el arch con el aum de lcr preautorizados)
    SELECT trim(valor_alfabetico)  INTO cdelimitador
        FROM bdicobranza:"informix".cb_param_campania
        WHERE empresa = pempresa AND tipo_campania = 1
        AND grupo_parametro = 'ARCHIVOS' AND num_parametro = 26;   

                            --Valida que exista el caracter
	IF NVL(cDelimitador,'') = '' THEN
        LET cCod_Ret= '104004';
        SELECT descripcion INTO cMensaje
            FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCod_Ret;
        
        IF cMensaje IS NULL THEN
            LET cMensaje = "";
        END IF;

        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCod_ret, cMensaje, '02')
            Returning cCod_RetIB;
        Return cCod_Ret;
	END IF;

	--Obtener ruta del archivo:  /resplogifx/archivoscartera/   (mismo que el arch con el aum de lcr preautorizados)
    SELECT TRIM(valor_alfabetico) INTO cruta
        FROM bdicobranza:"informix".cb_param_campania
        WHERE empresa = pempresa AND tipo_campania = 1 
        AND grupo_parametro = 'ARCHIVOS' AND num_parametro = 36; 

                    --Valida que exista la carpeta
	IF NVL (cruta,'') = '' THEN
        LET cCod_Ret= '104005';
        SELECT descripcion INTO cMensaje 
            FROM bdicobranza:"informix".cb_errores
            WHERE origen = 3 AND codigo_error = cCod_Ret;

        IF cMensaje IS NULL THEN
            LET cMensaje = "";
        END IF;

        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCod_ret, cMensaje, '02')
            Returning cCod_RetIB;
        Return cCod_Ret;
	END IF;

	--Obtener el nombre del archivo
    SELECT TRIM(valor_alfabetico) INTO cnombre
        FROM bdicobranza:"informix".cb_param_campania
        WHERE empresa = pempresa AND tipo_campania = 1
        AND grupo_parametro = 'ARCHIVOS' AND num_parametro = 37; --

		--Validar que existe el archivo
    LET cnomarchivo1 =  trim(cnombre)||'Aux'||substr(year(dFechaHoy),3)||to_char(dFechaHoy,'%m%d')||'.txt';
    LET cnomarchivo =  trim(cnombre)||substr(year(dFechaHoy),3)||to_char(dFechaHoy,'%m%d')||'.txt';

	--se ejecuta para ponerle el encabezado
	LET cSql='';
    LET cSql = 'echo "cliente' || cdelimitador || 'tarjeta' || cdelimitador || 'lcr_anterior' || cdelimitador || 'lcr_actual' || 
                    cdelimitador || 'sucursal' || ' " >' ||TRIM(cruta)|| cnomarchivo;
	system csql;
	
	LET cSQL1 = ' echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cruta) || TRIM(cnomarchivo1) || ' DELIMITER ' || ''''|| cdelimitador || ''''||'';

    --      Cliente || Tarjeta || LCR Anterior || LCR Actual || Sucursal

    LET cSQL2 = " SELECT trim(aum.numcte) AS Cliente, substr(trim(t.num_tarjeta),13) AS Tarjeta, "
        || " aum.lincred_actual AS LCR_Anterior, dos.monto_otorgado AS LCR_actual, trim(aum.sucursal) AS Sucursal "
        || " FROM bdicred:sd_bitacora_aumlincred aum, "
        || " bdicred:sd_tarjeta t, "
        || " bdicred:sd_maesdos dos "
        || " WHERE "
        || " (aum.dfecha_cobranza >= mdy(" || month(dFechaProcIni) || "," || day(dFechaProcIni) || "," ||
                                       year(dFechaProcIni)
        || ") and aum.dfecha_cobranza <= mdy(" || month(dFechaProcFin) || "," || day(dFechaProcFin)
        || "," || year(dFechaProcFin) || ")) AND "
        || " aum.num_solicitud = t.num_credito AND "
--        || " aum.status = 'AP'  AND "
        || " aum.empresa = t.empresa AND aum.numcte = t.numcte AND "
        || " t.secuencia = (Select max(secuencia) from bdicred:sd_tarjeta "      
        || " Where empresa = aum.empresa and num_credito = aum.num_solicitud and "
        || " numcte = aum.numcte  and tipo_tarjeta = 'T' and status_tar = 'A' ) AND "
        || " dos.empresa = aum.empresa AND dos.num_credito = aum.num_solicitud ";
 

	LET cSQL3 = '">'||TRIM(cRuta)||'Ejecuta_resp_aumlcr.sql';
    LET cSQL = trim(cSQL1) || cSQL2 || trim(cSQL3);
    System cSQL;

    LET cSQL='chmod 777 '|| TRIM(cRuta)||'Ejecuta_resp_aumlcr.sql';
    System cSQL;

    let cSQL = 'dbaccess bdicred ' || TRIM(cRuta) || 'Ejecuta_resp_aumlcr.sql';
    System cSQL;

    LET cSql = cSql;
    LET cSql = "sed 's/"||cDelimitador||"$//g' "|| TRIM(cRuta) || TRIM(cnomarchivo1) || " >> " || TRIM(cRuta) || TRIM(cnomarchivo);
    SYSTEM cSql;

	--Borra el archivo de control.
	LET cSQL = '' ;
	LET cSQL = 'rm ' || TRIM(cruta) || 'Ejecuta_resp_aumlcr.sql';
	SYSTEM cSQL;

    LET cSQL = '' ;
	LET cSQL = 'rm ' || TRIM(cruta) || cnomarchivo1;
	SYSTEM cSQL;

	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCod_ret, cMensaje, '03')
        Returning cCod_RetIB;

	RETURN cCod_ret;

END;
END PROCEDURE;
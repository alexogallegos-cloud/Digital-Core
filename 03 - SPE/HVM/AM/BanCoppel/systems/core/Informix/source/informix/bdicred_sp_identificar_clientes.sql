CREATE PROCEDURE "informix".sp_identificar_clientes(pEmpresa CHAR(3),pFechaHoyAumlincred DATE)
RETURNING CHAR(6)  AS codigo_retorno,
          CHAR(80) AS mensaje_retorno;          
---DECLARACIONES          
DEFINE cEmpresa             CHAR(3);
DEFINE cNumCte              CHAR(20);
DEFINE cNum_cred            CHAR(20);
DEFINE cCreditoDirty        CHAR(20);
DEFINE cCreditoClean 		CHAR(20);
DEFINE cRiesgo              CHAR(02);
DEFINE dMontoOtor           DECIMAL(18,2);
DEFINE dMontoReserva        DECIMAL(18,2);
DEFINE pNum_Vencidos        INTEGER;
DEFINE p_FechaHoy           DATE;
DEFINE p_PriDiaMes          DATE;
DEFINE p_UltDiaMesAnt       DATE;
DEFINE p_FechaMinApertCrd   DATE;
DEFINE p_FechaAnt1m         DATE;
DEFINE p_FechaAnt2m         DATE;
DEFINE p_FechaAnt3m         DATE;
DEFINE p_FechaAnt4m         DATE;
DEFINE p_FechaAnt6m         DATE;
DEFINE p_FechaAnt7m         DATE;
DEFINE p_FechaAnt12m        DATE;
DEFINE FechaAnt             DATE;
DEFINE dFechaCob            DATE;
DEFINE dtfechains           DATE;
DEFINE cCodRet              CHAR(6); 
DEFINE cCodRet2              CHAR(6); 
DEFINE cCod_RetIB           CHAR(6);
DEFINE cMensajeRet          CHAR(80);
DEFINE cMensajeRet2         CHAR(80);
DEFINE cComentario          CHAR(80);
DEFINE iSqlErr              INTEGER;
DEFINE iIsamErr             INTEGER;
DEFINE cErrorInfo           CHAR(80);
DEFINE LinUtil80            DECIMAL(18,2);
DEFINE valorsm              DECIMAL(18,2);
DEFINE cantidadsm           DECIMAL(18,2);
DEFINE valorsmzonac         DECIMAL(18,2);
DEFINE cSuc                 CHAR(4);
DEFINE Incprev              SMALLINT;
DEFINE Incprev6m            SMALLINT;
DEFINE iNumIncrTope         SMALLINT;
DEFINE utili                DECIMAL(18,2);
DEFINE vStatus              CHAR(2);
DEFINE vCausa               CHAR(3);
DEFINE valorlinutilcred     DECIMAL(18,2);
DEFINE valorreserva         DECIMAL(18,2);
DEFINE valor_reserva        DECIMAL(18,2);
DEFINE diasvigencia         INTEGER;
DEFINE regvigentes          INTEGER;
DEFINE numprod              CHAR(4);
DEFINE cUser                CHAR(20);
DEFINE sCommit              SMALLINT;
DEFINE contador_commit      INTEGER;
DEFINE sDiasMinimosAper     SMALLINT;
DEFINE sLineaCreditoMin     SMALLINT;
DEFINE sLineaCredito        SMALLINT;
DEFINE sNumIncremPrevios    SMALLINT;
DEFINE sLineaUtilizacion    SMALLINT;
DEFINE sNumVencidos         SMALLINT;
DEFINE sSolicitudBC         SMALLINT;
DEFINE sMesesTrancurridos   SMALLINT;
DEFINE cIncreAuto           CHAR(1);
DEFINE dtFechaMesesTranscurridos DATE;
DEFINE dtFecha_apertura     DATE;
DEFINE porc_uso             DECIMAL(18,2);
DEFINE int_cred_ven         DECIMAL(18,2);
DEFINE may_porc_uso6        DECIMAL(18,2);
DEFINE may_porc_usoProm        DECIMAL(18,2);
DEFINE dFechaVencto         DATE;
DEFINE dtFechaCuotaAnt      DATE;
DEFINE vproceso				CHAR(4);
DEFINE dLineaSugerida   DECIMAL(18,2);
DEFINE dAum1            DECIMAL(18,2);
DEFINE dAum2            DECIMAL(18,2);
DEFINE dAum3            DECIMAL(18,2);
DEFINE dAux0            DECIMAL(18,2);
DEFINE smblinsug		DECIMAL(18,2);
DEFINE sLineaCreditoMax	INTEGER;
DEFINE sScore			INTEGER;

DEFINE sLineaCreditoBC  SMALLINT;
DEFINE sLineaCreditoCAC INTEGER;
DEFINE cPregunta        CHAR(200);
DEFINE dtFechaCuota     DATE;
DEFINE dtFechaPago      DATE;
DEFINE dtFechaAux       DATE;
DEFINE sMinScoreCteDir  SMALLINT;
DEFINE sNumDecartIncr   SMALLINT;
DEFINE cCalifBuro   	CHAR(2);
DEFINE cStatus_bit   	CHAR(2);

DEFINE cMedioRes 		CHAR(1);
DEFINE cEjecutivo 		CHAR(10);
DEFINE cRespCte 		CHAR(1);
DEFINE iNumvencidos 	INTEGER;
DEFINE cGrupo 			CHAR(1);
DEFINE iMesesHistoria 	INTEGER;
DEFINE dSituacionPago 	DECIMAL(5,2);

DEFINE dFechaReporteBHVR	DATE;
DEFINE dPagado            	DECIMAL(18,2);
DEFINE dPagoMin            	DECIMAL(18,2);
DEFINE dPorcMaxUti          DECIMAL(18,2);
DEFINE iFlagRtPagMin    	INTEGER;
DEFINE cSQL					CHAR(1000);
DEFINE cReinicio			CHAR(01);
DEFINE iTotalProcesados		INTEGER;
DEFINE iTotalBitacora 		INTEGER;
DEFINE sIncremento_especial SMALLINT;

DEFINE dIva 				DECIMAL(5,3);
DEFINE dIncremento          DECIMAL (18,2); 
DEFINE dLineaActual         DECIMAL(18,2);
--DEFINE pfechahoyaumlincred	DATE;
		
---INICIALIZACIONES
LET cEmpresa                = "001";
LET cNumCte                 = "";
LET cNum_cred               = "";
LET cCreditoDirty           = "";
LET cCreditoClean 			= "";
LET cRiesgo                 = "";
LET dMontoOtor              = 0;
LET dMontoReserva           = 0;
LET pNum_Vencidos           = 0;
LET p_FechaHoy              = DATE(1);
LET p_PriDiaMes             = DATE(1);
LET p_UltDiaMesAnt          = DATE(1);
LET p_FechaMinApertCrd      = DATE(1);
LET dtfechains              = DATE(1);
LET p_FechaAnt1m            = DATE(1);
LET p_FechaAnt2m            = DATE(1);
LET p_FechaAnt3m            = DATE(1);
LET p_FechaAnt4m            = DATE(1);
LET p_FechaAnt6m            = DATE(1);
LET p_FechaAnt7m            = DATE(1);
LET p_FechaAnt12m           = DATE(1);
LET FechaAnt                = DATE(1);
LET dFechaCob               = DATE(1);
LET LinUtil80               = 0;
--LET paramsm               = "013";
--LET paramcantsm           = "012";
--LET paramlinutilcred      = "019";
--LET paramvigencia         = "011";
--LET paramreserva          = "018";
LET valorsm                 = 0;
LET cantidadsm              = 0;
LET valorlinutilcred        = 0;
LET cSuc                    = "";
LET Incprev                 = 0;
LET Incprev6m               = 0;
LET iNumIncrTope            = 0;
LET utili                   = 0;
LET vStatus                 = "";
LET vCausa                  = "";
LET valorreserva            = 0;
LET valor_reserva           = 0;
LET diasvigencia            = 0;
LET regvigentes             = 0;
LET cComentario             = "";
LET numprod                 = "";
LET cUser                   = USER;
LET iSqlErr                 = 0;
LET iIsamErr                = 0;
LET cErrorInfo              = "";
LET cCodRet                 = "000000";
LET cCodRet2                = "000000";
LET cMensajeRet             = "Se realizo la consulta correctamente";
LET cMensajeRet2             = "Se realizo la consulta correctamente";
LET sCommit                 = 0;
LET contador_commit         = 0;
LET sDiasMinimosAper        = 0;
LET sLineaCreditoMin        = 0;
LET sLineaCredito           = 0;
LET sNumIncremPrevios       = 0;
LET sLineaUtilizacion       = 0;
LET sNumVencidos            = 0;
LET sSolicitudBC            = 0;
LET sMesesTrancurridos      = 0;
LET cIncreAuto              = "";
LET dtFechaMesesTranscurridos = DATE(1);
LET dtFecha_apertura = DATE(1);
LET porc_uso                = 0;
LET int_cred_ven            = 0;
LET may_porc_uso6           = 0;
LET may_porc_usoProm          = 0;
LET dFechaVencto            = DATE(1);
LET dtFechaCuotaAnt         = DATE(1);
LET vproceso                = '0501';
LET dLineaSugerida  	= 0;
LET dAum1  		 		= 0;
LET dAum2 				= 0;
LET dAum3               = 0;
LET dAux0             	= 0;
LET smblinsug			= 0;
LET sLineaCreditoBC     = 0;
LET sLineaCreditoCAC    = 0;
LET cPregunta           = "";
LET sLineaCreditoMax    = 0;
LET sScore    = 0;
LET sMinScoreCteDir   	= 0;
LET sNumDecartIncr    	= 0;
LET dtFechaCuota        =     DATE(1);
LET dtFechaPago         =   DATE(1);
LET dtFechaAux         	=   DATE(1);
LET cCalifBuro         	=  "";
LET cStatus_bit  		=  "";
LET cMedioRes 			= "";
LET cEjecutivo 			= "";
LET cRespCte 			= "";
LET iNumvencidos  		= 0;
LET cGrupo 				= '';
LET iMesesHistoria 		= 0;
LET dSituacionPago 		= 0;

LET dFechaReporteBHVR = DATE(1);

LET dPagado      	= 0;
LET dPagoMin     	= 0;
LET dPorcMaxUti     = 0;
LET iFlagRtPagMin   = 0;
LET cSQL			= "";
LET cReinicio 		= '';
LET iTotalProcesados = 0;
LET iTotalBitacora 	= 0;
LET dIva 			= 0;
--LET pfechahoyaumlincred	= DATE(1);
LET sIncremento_especial =0;
LEt dIncremento =0; 
LET dLineaActual =0;


BEGIN

    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
        LET cCodRet= iSqlErr;
        LET cMensajeRet= cErrorInfo;
        IF (sCommit = -1) THEN
            rollback work;
        END IF;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, vproceso, cCodRet, trim(cMensajeRet) || "-" || iIsamErr::CHAR, '02') Returning cCod_RetIB;
        RETURN cCodRet, cMensajeRet;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, vproceso, cCodRet, cMensajeRet, '01') Returning cCod_RetIB;

--SET DEBUG FILE TO 'sp_identificar_clientes.out';
--TRACE ON;

    SELECT pri_dia_mes INTO p_PriDiaMes
    FROM bdicred:"informix".sd_fechas
    WHERE empresa = cEmpresa;
	
    IF NVL(cEmpresa,"") = "" THEN
        LET cCodRet     = "000011";
        LET cMensajeRet = "ParÃ¡metro requerido esta vacÃ­o";
        RETURN cCodRet, cMensajeRet;
    END IF;

	SELECT fecha_hoy 
	INTO pFechaHoyAumlincred
	FROM "informix".sd_fechas_aumlincred
	WHERE empresa = cEmpresa;
	
--rss temporal para pruebas
--    let p_PriDiaMes = mdy('04','01','2018');
--rss temporal para pruebas
----Obtencion de parametros
    -- obtener el valor del salario minimo de la zona C
    SELECT valor INTO valorsm
     FROM bdicred:"informix".sd_param 
    WHERE cod_param = '013' AND empresa   = cEmpresa;
    -- validacion de los parametros.
    IF NVL(valorsm,"")  = "" THEN
        LET cCodRet     = "000001";
        LET cMensajeRet = "Error al obtener el parÃ¡metro del valor del salario mÃ­nimo";
        RETURN cCodRet, cMensajeRet;
    END IF;

    -- obtener el valor de la cantidad de salarios minimos zona C =1.27
    SELECT valor INTO cantidadsm
      FROM bdicred:"informix".sd_param 
     WHERE cod_param = '012' AND empresa   = cEmpresa;
    -- validacion de los parametros.
    IF NVL(cantidadsm,"") = "" THEN
        LET cCodRet     = "000002";
        LET cMensajeRet = "Error al obtener el parÃ¡metro de la cantidad de salarios mÃ­nimos";
        RETURN cCodRet, cMensajeRet;
    END IF;

    -- posteriormente multiplicarlo para obtener la cantidad a numeros reales
    LET valorsmzonac = (valorsm * 30.42) * cantidadsm;

    -- obtener el valor del procentaje de utilizacion para los crÃ©ditos
    SELECT valor INTO valorlinutilcred
      FROM bdicred:"informix".sd_param 
     WHERE cod_param = '019' AND empresa   = cEmpresa;
    -- validacion de los parametros.
    IF NVL(valorlinutilcred,"") = "" THEN
        LET cCodRet     = "000003";
        LET cMensajeRet = "Error al obtener el parÃ¡metro de la cantidad de utilizaciÃ³n de la lÃ­nea de crÃ©dito";
        RETURN cCodRet, cMensajeRet;
    END IF;

    -- obtener el valor del de la reserva
    SELECT valor INTO valor_reserva
      FROM bdicred:"informix".sd_param 
     WHERE cod_param = '018' AND empresa = cEmpresa;
    -- validacion de los parametros.
    IF NVL(valor_reserva,"") = "" THEN
        LET cCodRet     = "000007";
        LET cMensajeRet = "Error al obtener el parÃ¡metro del monto de reserva";
        RETURN cCodRet, cMensajeRet;
    END IF;

    LET valorreserva = (valor_reserva * valorsm) * 30.42;

    -- obtener el valor de los dias de vigencia de los crÃ©ditos
    SELECT valor INTO diasvigencia
      FROM bdicred:"informix".sd_param 
     WHERE cod_param = '011' AND empresa = cEmpresa ;
    -- validaciÃ³n de los parametros.
    IF NVL(diasvigencia,"") = "" THEN
        LET cCodRet     = "000008";
        LET cMensajeRet = "Error al obtener el parÃ¡metro de los dÃ­as de vigencia del crÃ©dito";
        RETURN cCodRet, cMensajeRet;
    END IF; 

    -- DÃ­as mÃ­nimos de apertura de crÃ©ditos
    SELECT valor INTO sDiasMinimosAper
      FROM bdicred:"informix".sd_param 
     WHERE cod_param = '021' AND empresa = cEmpresa ;
    IF NVL(sDiasMinimosAper,"") = "" THEN
        LET cCodRet     = "000009";
        LET cMensajeRet = "Error al obtener los dÃ­as mÃ­nimos de apertura de crÃ©ditos";
        RETURN cCodRet, cMensajeRet;
    END IF;

    -- LÃ­nea de crÃ©dito mÃ­nimo para incrementos de lÃ­nea
    SELECT valor INTO sLineaCreditoMin
      FROM bdicred:"informix".sd_param 
     WHERE cod_param = '022' AND empresa = cEmpresa ;
    IF NVL(sLineaCreditoMin,"") = "" THEN
        LET cCodRet     = "000010";
        LET cMensajeRet = "Error al obtener la lÃ­nea de crÃ©dito mÃ­nima para incrementos de lÃ­nea";
        RETURN cCodRet, cMensajeRet;
    END IF;
  
    -- Compara crÃ©d con lÃ­n crÃ©d MN para increm lÃ­nea
    SELECT valor INTO sLineaCredito
      FROM bdicred:"informix".sd_param 
     WHERE cod_param = '023' AND empresa = cEmpresa ;
    IF NVL(sLineaCredito,"") = "" THEN
        LET cCodRet     = "000011";
        LET cMensajeRet = "Error al obtener la lÃ­nea de crÃ©dito a comparar para incrementos de lÃ­nea";
        RETURN cCodRet, cMensajeRet;
    END IF;

    -- NÃºmero incrementos previos para increm lÃ­nea
    SELECT valor INTO sNumIncremPrevios
      FROM bdicred:"informix".sd_param 
     WHERE cod_param = '024' AND empresa = cEmpresa ;
    IF NVL(sNumIncremPrevios,"") = "" THEN
        LET cCodRet     = "000012";
        LET cMensajeRet = "Error al obtener el nÃºmero incrementos previos para incrementos de lÃ­nea";
        RETURN cCodRet, cMensajeRet;
    END IF;

    -- NÃºmero de vencidos 
    SELECT valor INTO slineautilizacion
      FROM bdicred:"informix".sd_param 
     WHERE cod_param = '025' AND empresa = cEmpresa ;
    IF NVL(slineautilizacion,"") = "" THEN
        LET cCodRet     = "000013";
        LET cMensajeRet = "Error al obtener el nÃºmero de vencidos para incrementos de lÃ­nea";
        RETURN cCodRet, cMensajeRet;
    END IF;

    SELECT TRIM(valor)::integer INTO sMesesTrancurridos
      FROM bdicred:"informix".sd_param 
     WHERE cod_param = '001' AND empresa = cEmpresa ;
    IF NVL(sMesesTrancurridos,"") = "" THEN
        LET cCodRet     = "000014";
        LET cMensajeRet = "Error al obtener el nÃºmero de meses transcurridos para incrementos automÃ¡ticos";
        RETURN cCodRet, cMensajeRet;
    END IF;
-- LÃ­nea de crÃ©dito Maxima para incrementos de lÃ­nea
    SELECT valor INTO sLineaCreditoMax
      FROM bdicred:"informix".sd_param 
     WHERE cod_param = '046' AND empresa = cEmpresa ; ---checar parametro
    IF NVL(sLineaCreditoMax,"") = "" THEN
        LET cCodRet     = "000015";
        LET cMensajeRet = "Error al obtener la lÃ­nea de crÃ©dito maxima para incrementos de lÃ­nea";
        RETURN cCodRet, cMensajeRet;
    END IF;	
	
-- Compara lÃ­nea crÃ©dito para enviar a BC 
SELECT valor 
  INTO sLineaCreditoBC
  FROM "informix".sd_param 
 WHERE cod_param = '027'
   AND empresa = cEmpresa ;

IF NVL(sLineaCreditoBC,"") = "" THEN
    LET cCodRet     = "000009";
	LET cMensajeRet = "Error al obtener la lÃ­nea crÃ©dito para enviar a BC para incrementos de lÃ­nea";
	RETURN cCodRet, cMensajeRet;
END IF;

-- Compara lÃ­nea crÃ©dito para enviar aL CAC 
SELECT valor 
  INTO sLineaCreditoCAC
  FROM "informix".sd_param 
 WHERE cod_param = '028'
   AND empresa = cEmpresa ;

IF NVL(sLineaCreditoCAC,"") = "" THEN
    LET cCodRet     = "000010";
	LET cMensajeRet = "Error al obtener la lÃ­nea crÃ©dito para enviar al CAC para incrementos de lÃ­nea";
	RETURN cCodRet, cMensajeRet;
END IF;
	
SELECT valor 
  INTO iNumIncrTope
  FROM "informix".sd_param 
 WHERE cod_param = '047'
   AND empresa = cEmpresa ;

IF NVL(iNumIncrTope,"") = "" THEN
    LET cCodRet     = "000017";
	LET cMensajeRet = "Error al obtener el tope de maximo de incrementos";
	RETURN cCodRet, cMensajeRet;
END IF;
	
-- obtencion del porcentaje para calcuar la linea de clientes con su linea actual mayor o igual a 1.27 sm 
SELECT valor 
  INTO dAum1
  FROM "informix".sd_param 
 WHERE empresa = cEmpresa 
   AND cod_param = '016';

-- validacion de los parametros.
IF NVL(dAum1,"") = "" THEN
    LET cCodRet     = "000006";
	LET cMensajeRet = "Error al obtener el parametro de porcentaje de incremento para salarios minimos mayores a 1.27";
	RETURN cCodRet, cMensajeRet;
END IF;

-- obtencion del porcentaje para calcuar la linea de clientes con su linea actual mayor o igual a 1.27 sm 
SELECT valor 
  INTO dAum3
  FROM "informix".sd_param 
 WHERE empresa = cEmpresa 
   AND cod_param = '092';

-- validacion de los parametros.
IF NVL(dAum3,"") = "" THEN
    LET cCodRet     = "000016";
	LET cMensajeRet = "Error al obtener el parametro de porcentaje de incremento para salarios minimos mayores a 1.27";
	RETURN cCodRet, cMensajeRet;
END IF;

--Dic 2015 Se toma la Ãºltima base de los clientes clean procesados
--SELECT MAX(fecha_reporte) INTO dFechaReporteBHVR FROM bdicred:"informix".sd_clientes_clean_behavior WHERE status_bit IS NULL;
--rss
SELECT MAX(fecha_reporte) INTO dFechaReporteBHVR FROM bdicred:"informix".sd_clientes_clean_behavior 
 WHERE fecha_reporte >= date(1) and fecha_reporte <= today
   AND num_credito>=''
   AND status_bit IS NULL;
--rss

SELECT trim(valor)::SMALLINT INTO sMinScoreCteDir FROM bdicred:sd_param WHERE cod_param = 106; --Nivel de riesgo a procesar (score minimo para descartar)
	
	SELECT valor INTO dPorcMaxUti
FROM bdicred:"informix".sd_param 
WHERE cod_param = '112' AND empresa   = cEmpresa;
	
    --LET FechaAnt = p_FechaHoy - diasvigencia UNITS DAY;
    --LET FechaAnt = pFechaHoyAumlincred - diasvigencia UNITS DAY;
	CALL bdicred:"informix".monthadd(pFechaHoyAumlincred,-1)  RETURNING p_FechaAnt1m; -- 30 dÃ­as
    CALL bdicred:"informix".monthadd(pFechaHoyAumlincred,-2)  RETURNING p_FechaAnt2m; -- 60 dÃ­as
    CALL bdicred:"informix".monthadd(pFechaHoyAumlincred,-3)  RETURNING p_FechaAnt3m; -- 90 dÃ­as
    CALL bdicred:"informix".monthadd(pFechaHoyAumlincred,-4)  RETURNING p_FechaAnt4m; -- 120 dÃ­as
    CALL bdicred:"informix".monthadd(pFechaHoyAumlincred,-6)  RETURNING p_FechaAnt6m; -- 180 dÃ­as
	CALL bdicred:"informix".monthadd(pFechaHoyAumlincred,-7)  RETURNING p_FechaAnt7m; -- 210 dÃ­as
    CALL bdicred:"informix".monthadd(pFechaHoyAumlincred,-12) RETURNING p_FechaAnt12m; -- 360 dÃ­as
    -- obtener la fecha de los meses que se tienen q pasar para los incrementos automaticos
    CALL bdicred:"informix".monthadd(pFechaHoyAumlincred,-sMesesTrancurridos) RETURNING dtFechaMesesTranscurridos; 
	
    -- Almacena en una temporal los creditos a tratar en el foreach - creditos al corriente de pagos
    LET p_UltDiaMesAnt =  p_PriDiaMes - 1 units day;
	LET dtFechaCuotaAnt = MONTH(p_FechaAnt1m)||'-'||day(20)||'-'||YEAR(p_FechaAnt1m);
    LET p_FechaMinApertCrd = pFechaHoyAumlincred - sDiasMinimosAper;
--TRACE OFF;	
----------Fin parametros
/*
		SELECT a.num_solicitud, a.numcte, b.sucursal, a.num_producto, a.ajuste_de_cuota, 
		c.monto_otorgado,b.fecha_apertura, d.grupo,
        d.meses_historia, d.situacion_pago		--,ctes.num_credito, ctes.score
		FROM bdisolic:"informix".ss_solicitudes a 
		INNER JOIN bdicred:"informix".sd_maecredcont b ON (b.fecha = p_UltDiaMesAnt AND b.empresa = a.empresa AND b.num_credito = a.num_solicitud AND b.status_cred = "AA" AND NVL(b.id_unidad_prod ,'') = ''	AND NVL(b.cod_caract ,'') = '' AND NVL(b.cod_caract_2 ,'') = '')
		INNER JOIN bdicred:"informix".sd_maesdos c ON (c.empresa= a.empresa AND c.num_credito = a.num_solicitud AND c.monto_otorgado BETWEEN sLineaCreditoMin AND sLineaCreditoMax)
		INNER JOIN bdisolic:ss_resum_scor_fin d ON (d.empresa = a.empresa AND d.num_solicitud = a.num_solicitud)
		WHERE a.empresa = '001'
		AND a.num_solicitud = b.num_credito		
        INTO TEMP CreditosIncrLcr WITH NO LOG;
*/
--rss
/*		TRUNCATE TABLE sd_incrementos_linea;

		insert into sd_incrementos_linea
		SELECT b.num_credito, b.numcte, b.sucursal, b.num_producto,
		c.monto_otorgado,b.fecha_apertura
		FROM bdicred:"informix".sd_maecredcont b 
		INNER JOIN bdicred:"informix".sd_maesdos c ON (c.empresa= b.empresa AND c.num_credito = b.num_credito AND c.monto_otorgado BETWEEN sLineaCreditoMin AND sLineaCreditoMax)
		WHERE b.empresa = '001'
		and b.fecha = p_UltDiaMesAnt
		AND b.num_credito >= '' 
		and b.num_producto in ('6001','6600')
		AND b.status_cred = "AA" 
		AND (b.id_unidad_prod is null OR b.id_unidad_prod = '')
		AND (b.cod_caract is null OR b.cod_caract_2 = '');
*/
--rss
--        CREATE INDEX inx_cred_increm ON CreditosIncrLcr (num_credito);
--        UPDATE STATISTICS medium FOR TABLE sd_incrementos_linea;

--SE ELIMINA PARA EL NUEVO PROCESO INCREMENTO DE LINEA  RQI 21 154 INICIO
/*
SELECT valor INTO cReinicio FROM bdicred:sd_param WHERE empresa = cEmpresa AND cod_param = '054';

IF NVL(cReinicio,"") = "" THEN
    LET cCodRet     = "000019";
	LET cMensajeRet = "Error al obtener el parametro de reinicio";
	RETURN cCodRet, cMensajeRet;
END IF;

IF cReinicio = '0' THEN
    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, vproceso, '000000', 'Trunca tabla sd_incrementos_linea', '02') Returning cCod_RetIB;

	TRUNCATE TABLE bdicred:sd_incrementos_linea DROP STORAGE;
	TRUNCATE TABLE bdicred:sd_bitacora_aumlincred DROP STORAGE;
    TRUNCATE TABLE bdicred:sd_autorizacion_aumlincred DROP STORAGE;

	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, vproceso, '000000', 'Descarga informacion a procesar', '02') Returning cCod_RetIB;
		
	LET cSQL = '';
    LET cSQL = 'echo "UNLOAD TO '''|| '/respaldos/sd_incrementos_linea.unl'||''' delimiter '''||'|'||'''" > /respaldos/descarga_incrementos.sql';
--    LET cSQL = 'echo "UNLOAD TO '''|| '/pisa/ricardo/incrementos/sd_incrementos_linea.unl'||''' delimiter '''||'|'||'''" > /pisa/ricardo/incrementos/descarga_incrementos.sql';

	SYSTEM cSQL;

	LET cSQL = '';
	LET cSQL = 'echo "SELECT b.num_credito, b.numcte, b.sucursal, b.num_producto, c.monto_otorgado, b.fecha_apertura '
	|| ' FROM bdicred:sd_maecredcont b '
    || ' INNER JOIN bdicred:"informix".sd_maesdos c ON (c.empresa= b.empresa AND c.num_credito = b.num_credito AND c.monto_otorgado BETWEEN '''||sLineaCreditoMin||''' AND '''||sLineaCreditoMax||''') '
    || ' WHERE b.empresa = '''||'001'||''''
    || ' AND b.fecha ='''|| p_UltDiaMesAnt ||''''
    || ' AND b.num_credito >= '''|| '' ||''''
	|| ' AND b.num_producto in ('''||'6001'||''','''||'6600'||''') '
    || ' AND b.status_cred = '''|| 'AA' ||''''
	|| ' AND (b.id_unidad_prod is null OR b.id_unidad_prod = '''|| '' ||''') '
    || ' AND (b.cod_caract is null OR b.cod_caract_2 = '''|| '' ||''')" >>  /respaldos/descarga_incrementos.sql';
--    || ' AND (b.cod_caract is null OR b.cod_caract_2 = '''|| '' ||''')" >>  /pisa/ricardo/incrementos/descarga_incrementos.sql';
	SYSTEM cSQL;
	
	LET cSQL = 'dbaccess bdicred /respaldos/descarga_incrementos.sql';
--	LET cSQL = 'dbaccess bdicred /pisa/ricardo/incrementos/descarga_incrementos.sql';
	SYSTEM cSQL;

	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, vproceso, '000000', 'Carga informacion en la sd_incrementos_linea', '02') Returning cCod_RetIB;


	LET cSQL = '';
	LET cSQL = 'echo "FILE /respaldos/sd_incrementos_linea.unl DELIMITER '''||'|'||''' 6; INSERT INTO sd_incrementos_linea; " > /respaldos/carga_sd_incrementos_linea1.sql';
	SYSTEM cSQL;
	
	LET cSQL = '';
	LET cSQL = 'dbload -d bdicred -c /respaldos/carga_sd_incrementos_linea1.sql -l /respaldos/sd_incrementos_linea.log -n 1000 -k';
--	LET cSQL =   'dbload -d bdicred -c /pisa/ricardo/incrementos/carga_sd_incrementos_linea.sql -l   /pisa/ricardo/incrementos/sd_incrementos_linea.log -n 1000 -k';
	SYSTEM cSQL;
	
    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, vproceso, '000000', 'Depura sd_incrementos_linea', '02') Returning cCod_RetIB;
	
    -- Elimina los registros que ya tengan registro correspondiente de incremento
--    DELETE FROM sd_incrementos_linea WHERE num_solicitud IN (select {+INDEX(bdicred:"informix".sd_bitacora_aumlincred idx_bitacora_fhinsert)} num_solicitud from bdicred:"informix".sd_bitacora_aumlincred where empresa=cEmpresa and fecha_insert = pFechaHoyAumlincred);
--    DELETE FROM sd_incrementos_linea WHERE num_solicitud IN (select num_solicitud from bdicred:"informix".sd_bitacora_aumlincred where empresa=cEmpresa and fecha_insert = pFechaHoyAumlincred);
    --DELETE FROM sd_incrementos_linea WHERE num_solicitud IN (select num_solicitud from bdicred:"informix".sd_bitacora_aumlincred where fecha_insert = pFechaHoyAumlincred);

    -- Elimina los registros que ya hayan tenido una solicitud RT en los dos meses previos
    DELETE FROM sd_incrementos_linea WHERE num_solicitud IN (select num_solicitud from bdicred:"informix".sd_bitacora_aumlincred where empresa=cEmpresa and fecha_status BETWEEN p_FechaAnt2m AND pFechaHoyAumlincred and status = 'RT');
    --Elimina los registros que tengan una registro previo con status: PC,BC,CC,AC,EC            
    DELETE FROM sd_incrementos_linea WHERE num_solicitud IN (SELECT num_solicitud FROM bdicred:"informix".sd_bitacora_aumlincred WHERE empresa= cEmpresa AND status IN ("PC","BC","CC","AC","EC","AT","IN"));
	--    -- Elimina los clientes ten marcados como "dirty" en el proceso behavior. // se modifica sp: sp_calcularaumlincred
--    DELETE FROM CreditosIncrLcr WHERE num_credito IN ( Select num_credito from bdicred:sd_clientes_dirty_behavior );

    --  Se eliminan los clientes que cuentan con incrementos automaticos autorizados Y se valida que el nÃºmero de meses transcurridos de la fecha del Ãºltimo incremento
    --   o la fecha de alta del crÃ©dito (lo Ãºltimo que haya sucedido) sea mayor al valor obtenido en la variable dtFechaMesesTranscurridos // ( Se elimina condicion**1)
	 
--rss pasar abajo    DELETE FROM CreditosIncrLcr WHERE ajuste_de_cuota = 'S' AND fecha_apertura >= dtFechaMesesTranscurridos;
    -- Se eliminan los creditos de Tarjetas Garantizadas. (condicion**2)
	
    DELETE FROM sd_incrementos_linea WHERE num_solicitud IN (SELECT num_credito FROM bdicred:"informix".sd_tarjeta_garantizada WHERE empresa = cEmpresa AND garantizada = 'S');
	-- Se eliminan los creditos que no tienen mas de 180 dias y que su monto sea mayor al minimo 3000 RQM 09 320
	DELETE FROM sd_incrementos_linea WHERE  fecha_apertura >= p_FechaMinApertCrd;

	DELETE FROM sd_incrementos_linea WHERE monto_otorgado = sLineaCreditoMax ;
	
	-- Se eliminan los creditos que se originaron como grupo 6 para que no sean candidatos a ofertarles un incremento RQM 09320-1 PIQV
	--DELETE FROM CreditosIncrLcr WHERE grupo = '6'; RQM 09 407-2
--rss pasar abajo	DELETE FROM CreditosIncrLcr WHERE grupo in ('6','8');
    UPDATE STATISTICS medium FOR TABLE sd_incrementos_linea;

	UPDATE bdicred:sd_param SET valor = '1'	WHERE empresa = cEmpresa AND cod_param = '054';
--temporal solo para pruebas
--RETURN cCodRet, cMensajeRet;	
--temporal solo para pruebas
END IF;
*/
--SE ELIMINA PARA EL NUEVO PROCESO INCREMENTO DE LINEA  RQI 21 154 FIN

--RETURN cCodRet, cMensajeRet;
    -- Foreach que obtiene crÃ©ditos al corriente de pagos
    --se modifica la consulta principal para obtener el valor  que indica si el cliente cuenta con incremento automatico activo.

SELECT valor INTO cReinicio FROM bdicred:sd_param WHERE empresa = cEmpresa AND cod_param = '054';

IF NVL(cReinicio,"") = "" THEN
    LET cCodRet     = "000019";
	LET cMensajeRet = "Error al obtener el parametro de reinicio";
	RETURN cCodRet, cMensajeRet;
END IF;

CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, vproceso, '000000', 'Inicia procesamiento de incrementos', '02') Returning cCod_RetIB;

IF cReinicio = '1' THEN
--    DELETE FROM sd_incrementos_linea WHERE num_solicitud IN (select num_solicitud from bdicred:"informix".sd_bitacora_aumlincred where fecha_insert = pFechaHoyAumlincred);
	
    FOREACH WITH HOLD
		SELECT  num_solicitud,  numcte, sucursal, num_producto,	monto_otorgado,   fecha_apertura,flag_incremento_especial
          INTO cNum_cred	, cNumCte, 	   cSuc,	  numprod,	    dMontoOtor,	dtFecha_apertura,sIncremento_especial
--          INTO cNum_cred, cNumCte,  cSuc, numprod,cIncreAuto,dMontoOtor,dtFecha_apertura,cCreditoClean, sScore, cGrupo, iMesesHistoria, dSituacionPago
          FROM sd_incrementos_linea 	

/* original
--	SELECT num_solicitud, numcte,   sucursal, num_producto,ajuste_de_cuota,monto_otorgado, fecha_apertura,c.num_credito, NVL(c.score,0), grupo, NVL(meses_historia,0), NVL(situacion_pago,0)
		SELECT num_solicitud,  numcte, sucursal, num_producto,	monto_otorgado,   fecha_apertura, c.num_credito, NVL(c.score,0)
          INTO cNum_cred	, cNumCte, 	   cSuc,	  numprod,	    dMontoOtor,	dtFecha_apertura, cCreditoClean,       sScore
--          INTO cNum_cred, cNumCte,  cSuc, numprod,cIncreAuto,dMontoOtor,dtFecha_apertura,cCreditoClean, sScore, cGrupo, iMesesHistoria, dSituacionPago
          FROM sd_incrementos_linea 	
		  LEFT JOIN  bdicred:"informix".sd_clientes_clean_behavior c ON (c.fecha_reporte = dFechaReporteBHVR AND c.num_credito =num_solicitud) 
*/

		IF dMontoOtor IS NULL OR dMontoOtor = '' THEN LET dMontoOtor = 0; END IF;

		SELECT c.num_credito, NVL(c.score,0)
          INTO cCreditoClean,       sScore
          FROM bdicred:"informix".sd_clientes_clean_behavior c 
		 WHERE c.fecha_reporte = dFechaReporteBHVR AND c.num_credito =cNum_cred;



		LET cMensajeRet = cNum_cred || '  identificacion_clientes';
		LET iTotalProcesados = iTotalProcesados + 1;
		
     /*    --rss ENE 2011 TEMPORAL en lo que se implementan las respuestas de BurÃ³ de CrÃ©dito
        SELECT {+INDEX(bdicred:"informix".sd_bitacora_aumlincred idx_bitacora_status)} NVL(count(*),0)
            INTO sSolicitudBC
            FROM bdicred:"informix".sd_bitacora_aumlincred 
            WHERE numcte  = cNumCte
            AND empresa = cEmpresa
            AND status = 'BC';

            IF sSolicitudBC > 0 THEN CONTINUE FOREACH; END IF;
        --rss ENE 2011 TEMPORAL en lo que se implementan las respuestas de BurÃ³ de CrÃ©dito */

--rss
		SELECT a.ajuste_de_cuota,  d.grupo, d.meses_historia, d.situacion_pago
          INTO 		  cIncreAuto,	cGrupo,   iMesesHistoria,   dSituacionPago		  
		FROM bdisolic:"informix".ss_solicitudes a 
		INNER JOIN bdisolic:ss_resum_scor_fin d ON (d.empresa = a.empresa AND d.num_solicitud = a.num_solicitud)
		WHERE a.empresa = '001'
		AND a.num_solicitud = cNum_cred;		
--		DELETE FROM CreditosIncrLcr WHERE ajuste_de_cuota = 'S' AND fecha_apertura >= dtFechaMesesTranscurridos;
--		DELETE FROM CreditosIncrLcr WHERE grupo in ('6','8');

		IF cIncreAuto IS NULL OR cIncreAuto = '' THEN LET cIncreAuto = ''; END IF;
		IF cGrupo IS NULL OR cGrupo = '' THEN LET cGrupo = ''; END IF;
		IF iMesesHistoria IS NULL OR iMesesHistoria = '' THEN LET iMesesHistoria = 0; END IF;
		IF dSituacionPago IS NULL OR dSituacionPago = '' THEN LET dSituacionPago = 0; END IF;
		IF sIncremento_especial IS NULL OR sIncremento_especial = '' THEN LET sIncremento_especial =0; END IF;
		
		IF ((cIncreAuto = 'S' AND dtFecha_apertura >= dtFechaMesesTranscurridos) OR (cGrupo IN ('6','8')))  AND sIncremento_especial != 1 THEN
			DELETE sd_incrementos_linea where num_solicitud = cNum_cred;
			CONTINUE FOREACH;
		END IF;
		
        IF (sCommit = 0) THEN
            BEGIN WORK;
            LET contador_commit = 0;
            LET sCommit = -1;
        END IF; 

        IF cRiesgo IS NULL THEN LET cRiesgo = ""; END IF;

        --Se hace commit y update statistics a los 1000 registros insertados en tablas
        IF (contador_commit >= 500) THEN
            COMMIT WORK;
            --       UPDATE STATISTICS MEDIUM FOR TABLE bdicred:"informix".sd_bitacora_aumlincred;
            --       UPDATE STATISTICS MEDIUM FOR TABLE bdicred:"informix".sd_autorizacion_aumlincred;
            LET contador_commit = 0;
            BEGIN WORK;
        END IF;

        LET contador_commit = contador_commit  + 1;
        LET regvigentes  = 0;
        LET Incprev6m    = 0;
        LET Incprev      = 0;
        LET vStatus = "";
        LET vCausa  = "";
		LET may_porc_uso6 = 0;
		LET int_cred_ven  = 0;
		LET utili = 0;
		LET cMedioRes = "";
		LET cEjecutivo = "";
		LET cRespCte = "";
		LET cPregunta= "";
		
		IF NVL(cGrupo,'') = '' THEN
			IF ((iMesesHistoria >= 13 AND dSituacionPago >= 85) OR
			   (iMesesHistoria >= 6 AND dSituacionPago >= 0 AND dSituacionPago < 85)) THEN
			   LET cGrupo = '1';
			ELIF iMesesHistoria >= 6 AND iMesesHistoria < 13 AND dSituacionPago >= 85 THEN
			   LET cGrupo = '2';
			ELIF ((iMesesHistoria < 6 AND dSituacionPago > 0) OR (iMesesHistoria > 0 AND iMesesHistoria < 6 AND dSituacionPago <= 0) OR
				 (dSituacionPago = -1)) THEN
			   LET cGrupo = '3';
			ELIF iMesesHistoria = 0 and dSituacionPago = 0 THEN
			   LET cGrupo = '5';
			END IF;
		END IF;
			
        --IF NVL(cGrupo,'') = '3' THEN	RQM 09 407-2
        IF NVL(cGrupo,'') in ('3','5') THEN		
		   LET dAux0 = dAum3;
		ELSE
		   LET dAux0 = dAum1;
		END IF;		

		--Trae la fecha del Ãºltimo incremento del crÃ©dito para validar si fue en los Ãºltimos 6 meses, si es asÃ­ no se considera para el anÃ¡lisis de incremento de lÃ­nea
        --Cuenta los incrementos que ha tenido el crÃ©dito
--        SELECT {+INDEX(bdicred:"informix".sd_bitacora_aumlincred idx_bitacora_status)} 
		SELECT 
				 MAX(fecha_status),nvl(count(status),0)
            INTO dtfechains,Incprev
            FROM bdicred:"informix".sd_bitacora_aumlincred 
--            WHERE numcte  = cNumCte
--            AND empresa = cEmpresa
			WHERE empresa = '001'
			AND num_solicitud = cNum_cred
            AND status = 'AP'
			AND (fecha_insert >= DATE(1) AND fecha_insert <= pFechaHoyAumlincred) AND
			(flag_incremento_especial != 1 OR flag_incremento_especial IS NULL);

        IF dtfechains IS NULL OR dtfechains = '' THEN LET dtfechains = date(1); END IF;

		IF sIncremento_especial = 1 THEN
				

				SELECT monto_otorgado INTO dLineaActual FROM bdicred:"informix".sd_maesdos where num_credito = cNum_cred;
				

				SELECT 	 nueva_lc
				INTO dLineaSugerida
				FROM bdicred:"informix".sd_cred_incremento_especial where num_credito = cNum_cred;

                 IF dLineaSugerida IS NULL OR dLineaSugerida = '' THEN LET dLineaSugerida = 0 ; END IF;

				IF dLineaSugerida > sLineaCreditoMax THEN 
					LET dLineaSugerida =sLineaCreditoMax;
					LEt dIncremento = dLineaSugerida - dMontoOtor; 
					UPDATE bdicred:"informix".sd_bitacora_incremento_especial SET linea_actual = dLineaSugerida,incremento = dIncremento where num_credito = cNum_cred AND validacion = 0;
				END IF;

				IF dLineaSugerida <= dLineaActual THEN 
					DELETE sd_incrementos_linea where num_solicitud = cNum_cred;
					UPDATE bdicred:"informix".sd_bitacora_incremento_especial SET validacion = 2 where num_credito = cNum_cred AND validacion = 0;
				END IF;

				LET smblinsug = dLineaSugerida / (30.42 * valorsm);
		
				--validar si califico para ir a buro
				IF (dLineaSugerida >= sLineaCreditoBC) THEN
					LET cCalifBuro = "SI";
					LET cStatus_bit = 'BC';
				ELSE
					LET cCalifBuro = "NO";
					LET cStatus_bit = 'AT';
				END IF;

				INSERT INTO bdicred:"informix".sd_bitacora_aumlincred(empresa, num_solicitud, numcte, num_producto, status, causa_status,         fecha_status,  hora_status, sucursal, lincred_actual, lincred_sugerida, smb_lincred, grado_riesgo, monto_reserva, califica_buro, resp_cte, mensaje, ejecutivo, sucursal_at, origen, user_insert, fecha_insert, num_inc_prev, num_per_porutimay_806, num_per_porutimay_8012, medio_res, cte_noestit_p, cte_noestit_v, porc_uso, int_cred_ven, may_porc_uso6,dfecha_cobranza,flag_incremento_especial) 
				VALUES(cEmpresa, cNum_cred   , cNumCte, numprod    , cStatus_bit,       vCausa,   pFechaHoyAumlincred,     current,      cSuc,     dMontoOtor,             dLineaSugerida,           smblinsug,      cRiesgo, dMontoReserva,            '',      '',      '',        '',          '',    'C', cUser, pFechaHoyAumlincred, Incprev, utili, utili, '', 0, 0, porc_uso, int_cred_ven, may_porc_uso6,DATE(1),1);

				LET iTotalBitacora = iTotalBitacora + 1;

				-- Registra el movimiento 
				INSERT INTO bdicred:"informix".sd_autorizacion_aumlincred(empresa, num_solicitud, status, causa_status, user_insert, fecha_status, fecha_insert, revision_cac) 
				 VALUES(cEmpresa, cNum_cred, "PC", "", cUser, pFechaHoyAumlincred, pFechaHoyAumlincred, 0);
				
				INSERT INTO bdicred:"informix".sd_autorizacion_aumlincred(empresa, num_solicitud, status, causa_status, user_insert, fecha_status, fecha_insert, revision_cac) 
				VALUES(cEmpresa, cNum_cred,cStatus_bit , "", cUser, pFechaHoyAumlincred, pFechaHoyAumlincred, 0);

				
				DELETE sd_incrementos_linea where num_solicitud = cNum_cred;
				
				CONTINUE FOREACH;
		 END IF;
		

        IF cIncreAuto ='S' AND dtfechains >= dtFechaMesesTranscurridos  AND dtfechains <= today THEN
			DELETE sd_incrementos_linea where num_solicitud = cNum_cred;
            CONTINUE FOREACH;
        END IF;

		IF Incprev >= iNumIncrTope THEN		
			DELETE sd_incrementos_linea where num_solicitud = cNum_cred;
			CONTINUE FOREACH;
		END IF;
	
		--IF dtfechains >= p_FechaAnt6m AND dtfechains <= today THEN--RQM 09 407
		IF dtfechains >= p_FechaAnt12m AND dtfechains <= today THEN
      	   DELETE sd_incrementos_linea where num_solicitud = cNum_cred;
           CONTINUE FOREACH;
        END IF;

		--INI validacion del behavior clean
		
		IF NVL(cCreditoClean,'') = ''  THEN
				
				LET dLineaSugerida  = round(dMontoOtor + (dMontoOtor * dAux0),-2);
				LET smblinsug = dLineaSugerida / (30.42 * valorsm);
				--LET dMontoIncrem = dLineaSugerida - dMontoOtor;
				LET vstatus = 'RT';
				LET vCausa  = 'RDB';
				
				--validar si califico para ir a buro
				IF (dLineaSugerida >= sLineaCreditoBC) THEN
					LET cCalifBuro = "SI";
					LET cStatus_bit = 'BC';
				ELSE
					LET cCalifBuro = "NO";
					LET cStatus_bit = 'AT';
				END IF;
				--- LET cComentario = 'Se rechaza incremento por ser Cliente Dirty en proceso Behavior';

				INSERT INTO bdicred:"informix".sd_bitacora_aumlincred(empresa, num_solicitud, numcte, num_producto, status, causa_status,         fecha_status,  hora_status, sucursal, lincred_actual, lincred_sugerida, smb_lincred, grado_riesgo, monto_reserva, califica_buro, resp_cte, mensaje, ejecutivo, sucursal_at, origen, user_insert, fecha_insert, num_inc_prev, num_per_porutimay_806, num_per_porutimay_8012, medio_res, cte_noestit_p, cte_noestit_v, porc_uso, int_cred_ven, may_porc_uso6,dfecha_cobranza) 
				VALUES(cEmpresa, cNum_cred   , cNumCte, numprod    , vStatus,       vCausa,   pFechaHoyAumlincred,     current,      cSuc,     dMontoOtor,             dLineaSugerida,           smblinsug,      cRiesgo, dMontoReserva,            '',      '',      '',        '',          '',    'C', cUser, pFechaHoyAumlincred, Incprev, utili, utili, '', 0, 0, porc_uso, int_cred_ven, may_porc_uso6,DATE(1));

				LET iTotalBitacora = iTotalBitacora + 1;

				-- Registra el movimiento de la cancelacion.
				INSERT INTO bdicred:"informix".sd_autorizacion_aumlincred(empresa, num_solicitud, status, causa_status, user_insert, fecha_status, fecha_insert, revision_cac) 
				 VALUES(cEmpresa, cNum_cred, "PC", "", cUser, pFechaHoyAumlincred, pFechaHoyAumlincred, 0);
				
				INSERT INTO bdicred:informix.sd_autorizacion_aumlincred(empresa, num_solicitud, status, causa_status, user_insert, fecha_status, fecha_insert, revision_cac) 
				VALUES(cEmpresa, cNum_cred,cStatus_bit , "", cUser, pFechaHoyAumlincred, pFechaHoyAumlincred, 0);

				INSERT INTO bdicred:informix.sd_autorizacion_aumlincred(empresa, num_solicitud, status, causa_status, user_insert, fecha_status, fecha_insert, revision_cac) 
				VALUES(cEmpresa, cNum_cred, vstatus, vCausa, cUser, pFechaHoyAumlincred, pFechaHoyAumlincred, 0);

--				SELECT count(num_credito) INTO sNumDecartIncr  FROM bdicred:"informix".sd_clientes_clean_behavior
--				WHERE num_credito = cNum_cred AND status_bit IS NOT NULL;

--				LET sNumDecartIncr = sNumDecartIncr + 1; -- Suma 1, ya que toma como 1 el proceso que se esta ejecutando.
		

				-- Actualiza informacion de cliente Dirty en la tabla que almacena estos clientes.
				INSERT INTO bdicred:"informix".sd_clientes_clean_behavior (fecha_reporte,num_credito,score,status_bit,monto_lcr_original,incremento_sugerido,
				increm_otorgados_actual,num_descartes_increm,candidato_buro)
				VALUES(pFechaHoyAumlincred,cNum_cred,sScore,vstatus,dMontoOtor,dLineaSugerida - dMontoOtor,Incprev,sNumDecartIncr,cCalifBuro); 

				DELETE sd_incrementos_linea where num_solicitud = cNum_cred;
				
				CONTINUE FOREACH;
		 END IF;
		--fin validacion del behavior clean
	
		--INI validacion del behavior
		
		
			/*IF sScore >= sMinScoreCteDir AND NVL(cCreditoDirty,'') <> ''  THEN
				
				LET dLineaSugerida  = round(dMontoOtor + (dMontoOtor * dAux0),-2);
				LET smblinsug = dLineaSugerida / (30.42 * valorsm);
				--LET dMontoIncrem = dLineaSugerida - dMontoOtor;
				LET vstatus = 'RT';
				LET vCausa  = 'RDB';*/
				
				/*--validar si califico para ir a buro
				IF (dLineaSugerida >= sLineaCreditoBC) THEN
					LET cCalifBuro = "SI";
					LET cStatus_bit = 'BC';
				ELSE
					LET cCalifBuro = "NO";
					LET cStatus_bit = 'AT';
				END IF;
				--- LET cComentario = 'Se rechaza incremento por ser Cliente Dirty en proceso Behavior';

				INSERT INTO bdicred:"informix".sd_bitacora_aumlincred(empresa, num_solicitud, numcte, num_producto, status, causa_status,         fecha_status,  hora_status, sucursal, lincred_actual, lincred_sugerida, smb_lincred, grado_riesgo, monto_reserva, califica_buro, resp_cte, mensaje, ejecutivo, sucursal_at, origen, user_insert, fecha_insert, num_inc_prev, num_per_porutimay_806, num_per_porutimay_8012, medio_res, cte_noestit_p, cte_noestit_v, porc_uso, int_cred_ven, may_porc_uso6,dfecha_cobranza) 
				VALUES(cEmpresa, cNum_cred   , cNumCte, numprod    , vStatus,       vCausa,   pFechaHoyAumlincred,     current,      cSuc,     dMontoOtor,             dLineaSugerida,           smblinsug,      cRiesgo, dMontoReserva,            '',      '',      '',        '',          '',    'C', cUser, pFechaHoyAumlincred, Incprev, utili, utili, '', 0, 0, porc_uso, int_cred_ven, may_porc_uso6,DATE(1));
				   
*/
				-- Registra el movimiento de la cancelacion.
				/*INSERT INTO bdicred:"informix".sd_autorizacion_aumlincred(empresa, num_solicitud, status, causa_status, user_insert, fecha_status, fecha_insert, revision_cac) 
				 VALUES(cEmpresa, cNum_cred, "PC", "", cUser, pFechaHoyAumlincred, pFechaHoyAumlincred, 0);
				
				INSERT INTO bdicred:informix.sd_autorizacion_aumlincred(empresa, num_solicitud, status, causa_status, user_insert, fecha_status, fecha_insert, revision_cac) 
				VALUES(cEmpresa, cNum_cred,cStatus_bit , "", cUser, pFechaHoyAumlincred, pFechaHoyAumlincred, 0);

				INSERT INTO bdicred:informix.sd_autorizacion_aumlincred(empresa, num_solicitud, status, causa_status, user_insert, fecha_status, fecha_insert, revision_cac) 
				VALUES(cEmpresa, cNum_cred, vstatus, vCausa, cUser, pFechaHoyAumlincred, pFechaHoyAumlincred, 0);

				SELECT count(num_credito) INTO sNumDecartIncr  FROM bdicred:"informix".sd_clientes_dirty_behavior
				WHERE num_credito = cNum_cred AND status_bit IS NOT NULL;

				LET sNumDecartIncr = sNumDecartIncr + 1; -- Suma 1, ya que toma como 1 el proceso que se esta ejecutando.
		
*/
				-- Actualiza informacion de cliente Dirty en la tabla que almacena estos clientes.
				/*UPDATE bdicred:"informix".sd_clientes_dirty_behavior
				SET status_bit = cStatus_bit,
					monto_lcr_original = dMontoOtor,
					incremento_sugerido = dLineaSugerida - dMontoOtor,
					increm_otorgados_actual = Incprev,
					num_descartes_increm = sNumDecartIncr,
					candidato_buro = cCalifBuro
				WHERE  num_credito = cNum_cred
				AND month(fecha_reporte) = month(pFechaHoyAumlincred) 
				AND year(fecha_reporte) = year(pFechaHoyAumlincred);
				  CONTINUE FOREACH;*/
		 --END IF;
		--fin validacion del behavior
		--RQM 09 407
		 --se mueve seccion de codigo con la finalidad de validar tanto para lineas menos o mayores del minimo que el cliente no presente vencidos
/*
			SELECT COUNT(num_credito) 
				INTO sNumVencidos 
				FROM bdicred:"informix".sd_maesdoshist
				WHERE empresa        = cEmpresa
				AND num_credito    = cNum_cred
				--AND fecha BETWEEN p_FechaAnt6m AND pFechaHoyAumlincred   
				AND fecha BETWEEN p_FechaAnt12m AND pFechaHoyAumlincred   --RQM 09 407
				AND mto_fin_ven_trasp > 0;*/
					
            LET iFlagRtPagMin = 0;
            LET sNumVencidos = 0;
			LET dIva = 0;

			select 1 + nvl(iva,0) into dIva from bdinteg:si_sucursales where empresa = cEmpresa and sucursal = cSuc;
			
			if dIva is null or dIva = '' then let dIva = 0; end if;
			
			SELECT MAX(round(((b.sdo_cap_insoluto + (b.sdo_contab_mora + b.sdo_moratorio) * dIva
			+ amo.campo_trabajo1 + case when b.int_tra_no_exig - b.sdo_int_anticip >= 0 then  b.int_tra_no_exig - b.sdo_int_anticip else b.int_tra_no_exig end) / case when monto_otorgado = 0 then 1 else monto_otorgado end)*100,2)), 
			nvl(count(round(((b.sdo_cap_insoluto + (b.sdo_contab_mora + b.sdo_moratorio) * dIva
			+ amo.campo_trabajo1 + case when b.int_tra_no_exig - b.sdo_int_anticip >= 0 then  b.int_tra_no_exig - b.sdo_int_anticip else b.int_tra_no_exig end) / case when monto_otorgado = 0 then 1 else monto_otorgado end)*100,2)),0),
			Round(AVG(round(((b.sdo_cap_insoluto + (b.sdo_contab_mora + b.sdo_moratorio) * dIva
			+ amo.campo_trabajo1 + case when b.int_tra_no_exig - b.sdo_int_anticip >= 0 then  b.int_tra_no_exig - b.sdo_int_anticip else b.int_tra_no_exig end) / case when monto_otorgado = 0 then 1 else monto_otorgado end)*100,2)),0),
            sum(case when mto_fin_ven_trasp > 0 then 1 else 0 end),
            sum(case when mto_fin_ven_trasp > 0 and b.fecha >= p_FechaAnt4m then 1 else 0 end)
			INTO may_porc_uso6,utili,may_porc_usoProm, sNumVencidos, iFlagRtPagMin
			FROM bdicred:sd_maesdoshist b
			LEFT OUTER JOIN bdicred:sd_amortiza_credito amo on amo.empresa = b.empresa and amo.num_credito = b.num_credito and amo.fecha_cuota = b.fecha
			WHERE b.fecha     BETWEEN p_FechaAnt12m AND pFechaHoyAumlincred
			AND b.empresa     = cEmpresa              
			AND b.num_credito = cNum_cred;
			
            if (sNumVencidos is null)  then let sNumVencidos = 0; end if;
            if (iFlagRtPagMin is null) then let iFlagRtPagMin = 0; end if;


				IF sNumVencidos = 0 THEN--Se valida que el cliente no presente vencidos en prestamos					
			    
/*					SELECT COUNT(SolPresVenc)
					INTO sNumVencidos
					FROM TABLE (MULTISET (
								SELECT 
								CASE WHEN status_cred IN ("BA","BT") THEN status_cred END AS SolPresVenc
								FROM bdicred:"informix".q
							   WHERE numcte = cNumCte
								 AND empresa = "001" ));*/

					/*SELECT COUNT(*)
					INTO sNumVencidos
					FROM bdicred:"informix".sd_maecredcrd
					WHERE numcte = cNumCte
					   AND status_cred IN ("BA","BT");*/

					SELECT COUNT(*)
					INTO sNumVencidos
					FROM bdicred:"informix".sd_maecredcrd a
   				    join bdicred:"informix".sd_maesdoscrd b on a.num_credito = b.num_credito
					WHERE a.numcte = cNumCte
					  AND a.status_cred in ("BA","BT","VP","E1","E2","E3") 
					  AND (b.monto_vencido + b.mto_venc_trasp) > 0;  --IFRS MACF

				END IF;   
				   
				IF(  sNumVencidos > pNum_Vencidos) THEN
					LET vStatus = "RT";
					LET vCausa  = "RBE";
					INSERT INTO bdicred:"informix".sd_bitacora_aumlincred(empresa, num_solicitud, numcte, num_producto, status, causa_status,         fecha_status,  hora_status, sucursal, lincred_actual, lincred_sugerida, smb_lincred, grado_riesgo, monto_reserva, califica_buro, resp_cte, mensaje, ejecutivo, sucursal_at, origen, user_insert, fecha_insert, num_inc_prev, num_per_porutimay_806, num_per_porutimay_8012, medio_res, cte_noestit_p, cte_noestit_v, porc_uso, int_cred_ven, may_porc_uso6) 
						 VALUES(cEmpresa, cNum_cred   , cNumCte, numprod    , vStatus,       vCausa,   pFechaHoyAumlincred,     current,      cSuc,     dMontoOtor,                0,           0,      cRiesgo, dMontoReserva,            '',      '',      '',        '',          '',    'C', cUser, pFechaHoyAumlincred, Incprev, utili, utili, '', 0, 0, porc_uso, int_cred_ven, may_porc_uso6);
					INSERT INTO bdicred:"informix".sd_autorizacion_aumlincred(empresa, num_solicitud, status, causa_status, user_insert, fecha_status, fecha_insert, revision_cac) 
						 VALUES(cEmpresa, cNum_cred, vStatus, vCausa, cUser, pFechaHoyAumlincred, pFechaHoyAumlincred, 0);
					DELETE sd_incrementos_linea where num_solicitud = cNum_cred;
					LET iTotalBitacora = iTotalBitacora + 1;
					CONTINUE FOREACH;
				END IF;
		
		
        --Si la lÃ­nea de crÃ©dito actual del crÃ©dito es menor a 2100 MN (1.27 SM zona C aproximadamente) se precalifica
        IF dMontoOtor < sLineaCredito THEN -- compara la linea de credito en pesos y ya no en salarios mÃ­nimos  
            LET vStatus     = "AT";          
			--LET cComentario = "Requiere autorizaciÃ³n del cliente para su aplicaciÃ³n";
			LET dLineaSugerida  = round(dMontoOtor + (dMontoOtor * dAux0),-2);
			LET smblinsug = dLineaSugerida / (30.42 * valorsm);
			
			IF dLineaSugerida < sLineaCredito THEN --RQM 09 320 
				LET dLineaSugerida = sLineaCredito;
			END IF 
				/*	
            --se inserta el registro de la precalificacion
            INSERT INTO bdicred:"informix".sd_autorizacion_aumlincred(empresa, num_solicitud, status, causa_status, user_insert, fecha_status, fecha_insert, revision_cac) 
                VALUES(cEmpresa, cNum_cred, "PC", "", cUser, pFechaHoyAumlincred, pFechaHoyAumlincred, 0);
			--se inserta el registro de la preautorizaciÃ³n
			INSERT INTO bdicred:"informix".sd_autorizacion_aumlincred(empresa, num_solicitud, status, causa_status, user_insert, fecha_status, fecha_insert, revision_cac) 
                VALUES(cEmpresa, cNum_cred, vStatus, vCausa, cUser, pFechaHoyAumlincred, pFechaHoyAumlincred, 0);
			
			
					--se agrega validacion para ver si el cliente cuenta con incrementos automaticos, si es asi se manda llamar al procedimiento sp_registrarrespuestacte para simular la respuesta de autorizacion del cliente.
			IF cIncreAuto ='S' AND  vStatus= "AT" THEN
			
				LET cPregunta= "Autorizo expresamente a BanCoppel a incrementar mi linea de crÃ©dito a $" ||dLineaSugerida|| ", asÃ­ mismo, acepto las nuevas condiciones y tÃ©rminos aplicables a partir de esta fecha.";
				LET cMedioRes = 'P';
				LET cEjecutivo = 'sistema';
				LET cRespCte = '1';
				LET vStatus     = "AP";
				LET vCausa      = "";
			--se inserta el registro de la autorizaciÃ³n
			INSERT INTO bdicred:"informix".sd_autorizacion_aumlincred(empresa, num_solicitud, status, causa_status, user_insert, fecha_status, fecha_insert, revision_cac) 
					VALUES(cEmpresa, cNum_cred, vStatus, vCausa, cUser, today, pFechaHoyAumlincred, 0);
			END IF; 
			
			--se inserta el registro en la bitacora con el resultado final.
			INSERT INTO bdicred:"informix".sd_bitacora_aumlincred(empresa, num_solicitud, numcte, num_producto, status, causa_status, fecha_status,          hora_status, sucursal, lincred_actual, lincred_sugerida, smb_lincred, grado_riesgo, monto_reserva, califica_buro, resp_cte, mensaje, ejecutivo, sucursal_at, origen, user_insert, fecha_insert, num_inc_prev, num_per_porutimay_806, num_per_porutimay_8012, medio_res, cte_noestit_p, cte_noestit_v, porc_uso, int_cred_ven, may_porc_uso6,dfecha_cobranza) 
                VALUES(cEmpresa, cNum_cred   , cNumCte, numprod    , vStatus,       vCausa,   pFechaHoyAumlincred,     current,      cSuc,     dMontoOtor, dLineaSugerida,          smblinsug,     cRiesgo,  dMontoReserva, '', cRespCte, cPregunta, '', '',    'C', cUser, pFechaHoyAumlincred, Incprev, utili, utili, cMedioRes, 0, 0, porc_uso, int_cred_ven, may_porc_uso6,pFechaHoyAumlincred);
        				
			IF cIncreAuto ='S' AND  vStatus= "AP" THEN --se coloca aqui para que primero inserte el registro en la bitacora y despues se asigne el incremento.
		
			EXECUTE PROCEDURE bdicred:"informix".sp_grabarincrementolincred(cEmpresa, cNum_cred) INTO cCodRet, cMensajeRet;
				IF cCodRet <> "00000" THEN
					LET cCodRet = "00001";
					LET cMensajeRet = "Error al realizar incremento automÃ¡tico de lÃ­nea para el crÃ©dito  " || cNum_cred;			
					RETURN cCodRet, cMensajeRet;
				END IF;	

			END IF; 			
				
           CONTINUE FOREACH;*/
        END IF;

		SELECT grado_riesgo,nvl(reserva_calificacion,0),porcentaje_uso
			INTO  cRiesgo,dMontoReserva,porc_uso
		  FROM bdicred:"informix".sd_hist_reserva  
		  WHERE empresa = cEmpresa 
		  AND num_credito = cNum_cred
		  AND fecha_cierre = p_UltDiaMesAnt;     
		
		
        --Se descartan los crÃ©ditos con grado de riesgo D, E y C (para este Ãºltimo con monto de reserva mayor a 600 MN (0.37 SM zona C aproximadamente))
        --IF (cRiesgo NOT IN ("A","B1","B2")) OR ((cRiesgo = "C") AND (dMontoReserva > 600)) THEN -- se compara en pesos y ya no en salarios mÃ­nimos
        IF (cRiesgo NOT IN ("A1","A2","B1","B2","B3","C1","C2")) THEN -- PIQV RQM 09 320-4
            LET vStatus = "RT";
            LET vCausa  = "RGR";
			--Se realiza cambio por incidencia 
            INSERT INTO bdicred:"informix".sd_bitacora_aumlincred(empresa, num_solicitud, numcte, num_producto, status, causa_status, fecha_status,           hora_status, sucursal, lincred_actual, lincred_sugerida, smb_lincred, grado_riesgo, monto_reserva, califica_buro, resp_cte, mensaje, ejecutivo, sucursal_at, origen, user_insert, fecha_insert, num_inc_prev, num_per_porutimay_806, num_per_porutimay_8012, medio_res, cte_noestit_p, cte_noestit_v, porc_uso, int_cred_ven, may_porc_uso6) 
                 VALUES(cEmpresa, cNum_cred   , cNumCte, numprod    , vStatus,       vCausa,   pFechaHoyAumlincred,     current,      cSuc,     dMontoOtor,                0,           0,      cRiesgo,  dMontoReserva,            '',      '',      '',        '',          '',    'C', cUser, pFechaHoyAumlincred, Incprev, utili, utili, '', 0, 0, porc_uso, int_cred_ven, may_porc_uso6);
            INSERT INTO bdicred:"informix".sd_autorizacion_aumlincred(empresa, num_solicitud, status, causa_status, user_insert, fecha_status, fecha_insert, revision_cac) 
                 VALUES(cEmpresa, cNum_cred, vStatus, vCausa, cUser, pFechaHoyAumlincred, pFechaHoyAumlincred, 0);
			DELETE sd_incrementos_linea where num_solicitud = cNum_cred;
			LET iTotalBitacora = iTotalBitacora + 1;
			CONTINUE FOREACH; 
        END IF;

        --Selecciona el mayor porcentaje de uso en los ultimos 6 meses que presenta el credito
      /*
		SELECT MAX(porcentaje_uso), nvl(count(porcentaje_uso),0)
			INTO may_porc_uso6,utili
          FROM bdicred:"informix".sd_hist_reserva
	     WHERE empresa     = cEmpresa
	       AND num_credito = cNum_cred
	       AND fecha_cierre BETWEEN p_FechaAnt6m AND pFechaHoyAumlincred;
			--AND porcentaje_uso >= valorlinutilcred;  
			*/
/*			
			SELECT MAX(round(((b.sdo_cap_insoluto + (b.sdo_contab_mora + b.sdo_moratorio) * (select 1 + nvl(iva,0) from bdinteg:si_sucursales where empresa='001' and sucursal = cSuc)
			+ amo.campo_trabajo1 + case when b.int_tra_no_exig - b.sdo_int_anticip >= 0 then  b.int_tra_no_exig - b.sdo_int_anticip else b.int_tra_no_exig end) / monto_otorgado)*100,2)), 
			nvl(count(round(((b.sdo_cap_insoluto + (b.sdo_contab_mora + b.sdo_moratorio) * (select 1 + nvl(iva,0) from bdinteg:si_sucursales where empresa='001' and sucursal = cSuc)
			+ amo.campo_trabajo1 + case when b.int_tra_no_exig - b.sdo_int_anticip >= 0 then  b.int_tra_no_exig - b.sdo_int_anticip else b.int_tra_no_exig end) / monto_otorgado)*100,2)),0),
			Round(AVG(round(((b.sdo_cap_insoluto + (b.sdo_contab_mora + b.sdo_moratorio) * (select 1 + nvl(iva,0) from bdinteg:si_sucursales where empresa='001' and sucursal = cSuc)
			+ amo.campo_trabajo1 + case when b.int_tra_no_exig - b.sdo_int_anticip >= 0 then  b.int_tra_no_exig - b.sdo_int_anticip else b.int_tra_no_exig end) / monto_otorgado)*100,2)),0) 			
			INTO may_porc_uso6,utili,may_porc_usoProm
			FROM bdicred:sd_maesdoshist b
			LEFT OUTER JOIN bdicred:sd_amortiza_credito amo on amo.empresa = b.empresa and amo.num_credito = b.num_credito and amo.fecha_cuota = b.fecha
			WHERE b.fecha     BETWEEN p_FechaAnt12m AND pFechaHoyAumlincred
			AND b.empresa     = cEmpresa              
			AND b.num_credito = cNum_cred;
*/			
	 
	   
		  --RQM 09 407-2
		 --  IF NVL(may_porc_uso6,0) >= valorlinutilcred THEN --JMAH RQM 09 320							
		 IF NVL(may_porc_uso6,0) >= valorlinutilcred AND  NVL(may_porc_uso6,0) <=dPorcMaxUti THEN 	--RQM 09 407-2					
/*							 
				--validacion del pago minimo
				LET iFlagRtPagMin =0;
				FOREACH WITH HOLD
					SELECT count(*)
						INTO dtFechaPago,dPagoMin 
					FROM bdicred:"informix".sd_maesdoshist
					WHERE empresa        = cEmpresa
					AND num_credito    = cNum_cred	
					AND fecha BETWEEN p_FechaAnt4m AND pFechaHoyAumlincred 
					ORDER BY fecha DESC
					
					--en revision
					LET  dtFechaAux = monthadd (dtFechaPago,-1) + 1 units day;
					SELECT SUM(monto)
						INTO dPagado
					FROM bdicred:sd_movhis a
					WHERE a.empresa  = cEmpresa
					AND fecha_mov BETWEEN dtFechaAux AND  dtFechaPago
					AND num_credito  = cNum_cred
					AND a.codigo_fun in (select cod_fun from bdicred:sd_conceptospagomanual)
					AND a.codigo_ref = 1 
					AND reversado    = 'N'					;

					IF dPagado <= dPagoMin  THEN
						LET iFlagRtPagMin= 1;
						EXIT FOREACH;
					END IF 
					
				END FOREACH;
*/
				IF iFlagRtPagMin > 0 THEN 
					LET vStatus = "RT";
					LET vCausa  = "RPM";					--Se realiza cambio por incidencia 
					INSERT INTO bdicred:"informix".sd_bitacora_aumlincred(empresa, num_solicitud, numcte, num_producto, status, causa_status, fecha_status,           hora_status, sucursal, lincred_actual, lincred_sugerida, smb_lincred, grado_riesgo, monto_reserva, califica_buro, resp_cte, mensaje, ejecutivo, sucursal_at, origen, user_insert, fecha_insert, num_inc_prev, num_per_porutimay_806, num_per_porutimay_8012, medio_res, cte_noestit_p, cte_noestit_v, porc_uso, int_cred_ven, may_porc_uso6,prom_porc_uso12) 
					 VALUES(cEmpresa, cNum_cred   , cNumCte, numprod    , vStatus,       vCausa,   pFechaHoyAumlincred,     current,      cSuc,     dMontoOtor,                0,           0,      cRiesgo,  dMontoReserva,            '',      '',      '',        '',          '',    'C', cUser, pFechaHoyAumlincred, Incprev, utili, utili, '', 0, 0, porc_uso, int_cred_ven, may_porc_uso6,may_porc_usoProm);
					INSERT INTO bdicred:"informix".sd_autorizacion_aumlincred(empresa, num_solicitud, status, causa_status, user_insert, fecha_status, fecha_insert, revision_cac) 
					 VALUES(cEmpresa, cNum_cred, vStatus, vCausa, cUser, pFechaHoyAumlincred, pFechaHoyAumlincred, 0);
					DELETE sd_incrementos_linea where num_solicitud = cNum_cred;
					LET iTotalBitacora = iTotalBitacora + 1;
					CONTINUE FOREACH; 
				END IF 
				
				LET int_cred_ven		   = 0;
/*
				SELECT fecha_vencto INTO dFechaVencto
				 FROM bdicred:sd_maecredanexo 
				WHERE empresa = cEmpresa AND num_credito  = cNum_cred;

				IF dFechaVencto IS NULL OR dFechaVencto = '' THEN LET dFechaVencto = DATE(1); END IF;

				IF dFechaVencto != DATE(1) THEN
					SELECT sum(monto)
					INTO int_cred_ven
					FROM bdicred:sd_movhis mov
					WHERE mov.empresa = cEmpresa
					AND mov.fecha_mov = dFechaVencto
					AND mov.num_credito = cNum_cred
					AND mov.codigo_fun  = '605'
					AND mov.codigo_ref  = 2
					AND mov.reversado   = 'N';
				END IF;
*/	   
				--se obtiene el monto del incremento
				LET dLineaSugerida = round(dMontoOtor + (dMontoOtor * dAux0),-2);
				IF dLineaSugerida > sLineaCreditoMax THEN
					LET dLineaSugerida =sLineaCreditoMax;
				END IF
				LET smblinsug = dLineaSugerida / (30.42 * valorsm);
				--Si la lÃ­nea sugerida es mayor a 10,000 (6 SM zona C aproximadamente) se va a consultar a BurÃ³ de CrÃ©dito				
				IF (dLineaSugerida >= sLineaCreditoBC) THEN --se compara en pesos y no en salarios mÃ­nimos
					LET vstatus     = "BC";
					LET dFechaCob   = DATE(1);
					
					EXECUTE PROCEDURE bdiburo:"informix".sp_generarespaldoshistoricosic_bc(cNumCte,vstatus)
					INTO cCodRet2,cMensajeRet2; 
					
				ELSE
				--Si la lÃ­nea sugerida es mayor a 21,000 (12 SM zona C aproximadamente) se va a consultar al CAC
				   IF (dLineaSugerida >= sLineaCreditoCAC) THEN --se compara en pesos y no en salarios mÃ­nimos
					   LET vstatus     = "AC";					
					   LET dFechaCob   = DATE(1);
					ELSE
					   LET vstatus     = "AT";					   
					   LET dFechaCob = pFechaHoyAumlincred;
					END IF;
				END IF;					   
		     
					 --se inserta el registro de la precalificacion
				INSERT INTO bdicred:"informix".sd_autorizacion_aumlincred(empresa, num_solicitud, status, causa_status, user_insert, fecha_status, fecha_insert, revision_cac) 
					VALUES(cEmpresa, cNum_cred, "PC", "", cUser, pFechaHoyAumlincred, pFechaHoyAumlincred, 0);
				--se inserta el registro de la preautorizaciÃ³n
				INSERT INTO bdicred:"informix".sd_autorizacion_aumlincred(empresa, num_solicitud, status, causa_status, user_insert, fecha_status, fecha_insert, revision_cac) 
					VALUES(cEmpresa, cNum_cred, vStatus, vCausa, cUser, pFechaHoyAumlincred, pFechaHoyAumlincred, 0);
				
				
		--se agrega validacion para ver si el cliente cuenta con incrementos automaticos, si es asi se manda llamar al procedimiento sp_registrarrespuestacte para simular la respuesta de autorizacion del cliente.
				IF cIncreAuto ='S' AND  vStatus= "AT" THEN
				
					LET cPregunta= "Autorizo expresamente a BanCoppel a incrementar mi linea de crÃ©dito a $" ||dLineaSugerida|| ", asÃ­ mismo, acepto las nuevas condiciones y tÃ©rminos aplicables a partir de esta fecha.";
					LET cMedioRes = 'P';
					LET cEjecutivo = 'sistema';
					LET cRespCte = '1';
					LET vStatus     = "AP";
					LET vCausa      = "";
				--se inserta el registro de la autorizaciÃ³n
				INSERT INTO bdicred:"informix".sd_autorizacion_aumlincred(empresa, num_solicitud, status, causa_status, user_insert, fecha_status, fecha_insert, revision_cac) 
						VALUES(cEmpresa, cNum_cred, vStatus, vCausa, cUser, today, pFechaHoyAumlincred, 0);
				END IF; 
				
				--se inserta el registro en la bitacora con el resultado final.
							
				INSERT INTO bdicred:"informix".sd_bitacora_aumlincred(empresa, num_solicitud, numcte, num_producto, status, causa_status,         fecha_status, hora_status, sucursal, lincred_actual, lincred_sugerida, smb_lincred, grado_riesgo, monto_reserva, califica_buro, resp_cte, mensaje, ejecutivo, sucursal_at, origen, user_insert, fecha_insert, num_inc_prev, num_per_porutimay_806, num_per_porutimay_8012, medio_res, cte_noestit_p, cte_noestit_v, porc_uso, int_cred_ven, may_porc_uso6,dfecha_cobranza,prom_porc_uso12) 
						VALUES(cEmpresa, cNum_cred   , cNumCte, numprod    , vStatus,       vCausa,   pFechaHoyAumlincred,    current,      cSuc,     dMontoOtor,dLineaSugerida, smblinsug,      cRiesgo, dMontoReserva, '', cRespCte, cPregunta,  '', '',    'C', cEjecutivo, pFechaHoyAumlincred, Incprev, utili, 'N/A', cMedioRes, 0, 0, porc_uso, int_cred_ven, may_porc_uso6,dFechaCob,may_porc_usoProm);
			    LET iTotalBitacora = iTotalBitacora + 1;
				
				IF cIncreAuto ='S' AND  vStatus= "AP" THEN --se coloca aqui para que primero inserte el registro en la bitacora y despues se asigne el incremento.
			
					EXECUTE PROCEDURE bdicred:"informix".sp_grabarincrementolincred(cEmpresa, cNum_cred) INTO cCodRet, cMensajeRet;
					IF cCodRet <> "00000" THEN
						LET cCodRet = "00001";
						LET cMensajeRet = "Error al realizar incremento automÃ¡tico de lÃ­nea para el crÃ©dito  " || cNum_cred;			
						RETURN cCodRet, cMensajeRet;
					END IF;
				END IF
				DELETE sd_incrementos_linea where num_solicitud = cNum_cred;
				CONTINUE FOREACH;										    		
            ELSE
               LET vStatus = "CN";
               LET vCausa  = "CUL";
               INSERT INTO bdicred:"informix".sd_bitacora_aumlincred(empresa, num_solicitud, numcte, num_producto, status, causa_status,         fecha_status, hora_status, sucursal, lincred_actual, lincred_sugerida, smb_lincred, grado_riesgo, monto_reserva, califica_buro, resp_cte, mensaje, ejecutivo, sucursal_at, origen, user_insert, fecha_insert, num_inc_prev, num_per_porutimay_806, num_per_porutimay_8012, medio_res, cte_noestit_p, cte_noestit_v, porc_uso, int_cred_ven, may_porc_uso6,prom_porc_uso12) 
                    VALUES(cEmpresa, cNum_cred   , cNumCte, numprod    , vStatus,       vCausa,   pFechaHoyAumlincred,    current,      cSuc,     dMontoOtor,                0,           0,      cRiesgo, dMontoReserva,            '',      '',      '',        '',          '',    'C', cUser, pFechaHoyAumlincred, Incprev, utili, 'N/A', '', 0, 0, porc_uso, int_cred_ven, may_porc_uso6,may_porc_usoProm);
               INSERT INTO bdicred:"informix".sd_autorizacion_aumlincred(empresa, num_solicitud, status, causa_status, user_insert, fecha_status, fecha_insert, revision_cac) 
                    VALUES(cEmpresa, cNum_cred, vStatus, vCausa, cUser, pFechaHoyAumlincred, pFechaHoyAumlincred, 0);
				DELETE sd_incrementos_linea where num_solicitud = cNum_cred;
				LET iTotalBitacora = iTotalBitacora + 1;
                CONTINUE FOREACH;
            END IF;
			DELETE sd_incrementos_linea where num_solicitud = cNum_cred;
    END FOREACH;

    IF sCommit = -1 THEN
        COMMIT WORK;
    END IF;
    LET sCommit = 0;

--    UPDATE STATISTICS MEDIUM FOR TABLE bdicred:"informix".sd_bitacora_aumlincred;
--    UPDATE STATISTICS MEDIUM FOR TABLE bdicred:"informix".sd_autorizacion_aumlincred;

    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, vproceso, '000000', 'Registra en parametros fin de proceso', '02') Returning cCod_RetIB;
	
	UPDATE bdicred:sd_param SET valor = '2'	WHERE empresa = cEmpresa AND cod_param = '054';
ELSE
	LET cMensajeRet = 'Universo para Inrementos de Linea no se ha creado.';
	LET cCodRet = '000100';
    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, vproceso, cCodRet, cMensajeRet, '02') Returning cCod_RetIB;
	RETURN cCodRet, cMensajeRet;
END IF;

SELECT valor INTO cReinicio FROM bdicred:sd_param WHERE empresa = cEmpresa AND cod_param = '054';

IF NVL(cReinicio,"") = "" THEN
    LET cCodRet     = "000019";
	LET cMensajeRet = "Error al obtener el parametro de reinicio";
	RETURN cCodRet, cMensajeRet;
END IF;
/*
IF cReinicio = '2' THEN
    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, vproceso, '000000', 'Descarga tabla de trabajo bitacora', '02') Returning cCod_RetIB;

	LET cSQL = '';
    LET cSQL = 'echo "UNLOAD TO '''|| '/respaldos/sd_bitacora_aumlincred.unl'||''' delimiter '''||'|'||'''" > /respaldos/descarga_incrementos_trabajados.sql';
--    LET cSQL = 'echo "UNLOAD TO '''|| '/pisa/ricardo/incrementos/sd_bitacora_aumlincred.unl'||''' delimiter '''||'|'||'''" > /pisa/ricardo/incrementos/descarga_incrementos_trabajados.sql';

	SYSTEM cSQL;

	LET cSQL = '';
	LET cSQL = 'echo "SELECT * '
    || ' FROM sd_bitacora_aumlincred " >>  /respaldos/descarga_incrementos_trabajados.sql';
--    || '  FROM sd_bitacora_aumlincred " >>  /pisa/ricardo/incrementos/descarga_incrementos_trabajados.sql';
	SYSTEM cSQL;
	
	LET cSQL = 'dbaccess bdicred /respaldos/descarga_incrementos_trabajados.sql';
--	LET cSQL = 'dbaccess bdicred /pisa/ricardo/incrementos/descarga_incrementos_trabajados.sql';
	SYSTEM cSQL;

	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, vproceso, '000000', 'Descarga tabla de trabajo autorizacion', '02') Returning cCod_RetIB;

	LET cSQL = '';
    LET cSQL = 'echo "UNLOAD TO '''|| '/respaldos/sd_autorizacion_aumlincred.unl'||''' delimiter '''||'|'||'''" > /respaldos/descarga_incrementos_trabajados1.sql';
--    LET cSQL = 'echo "UNLOAD TO '''|| '/pisa/ricardo/incrementos/sd_autorizacion_aumlincred.unl'||''' delimiter '''||'|'||'''" > /pisa/ricardo/incrementos/descarga_incrementos_trabajados1.sql';

	SYSTEM cSQL;

	LET cSQL = '';
	LET cSQL = 'echo "SELECT * '
    || ' FROM sd_autorizacion_aumlincred " >>  /respaldos/descarga_incrementos_trabajados1.sql';
--    || '  FROM sd_autorizacion_aumlincred " >>  /pisa/ricardo/incrementos/descarga_incrementos_trabajados1.sql';
	SYSTEM cSQL;
	
	LET cSQL = 'dbaccess bdicred /respaldos/descarga_incrementos_trabajados1.sql';
--	LET cSQL = 'dbaccess bdicred /pisa/ricardo/incrementos/descarga_incrementos_trabajados1.sql';
	SYSTEM cSQL;

    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, vproceso, '000000', 'Descarga tabla de trabajo clientes clean', '02') Returning cCod_RetIB;

	LET cSQL = '';
    LET cSQL = 'echo "UNLOAD TO '''|| '/respaldos/sd_clientes_clean_behavior.unl'||''' delimiter '''||'|'||'''" > /respaldos/descarga_clientes_clean.sql';
--    LET cSQL = 'echo "UNLOAD TO '''|| '/pisa/ricardo/incrementos/sd_clientes_clean_behavior.unl'||''' delimiter '''||'|'||'''" > /pisa/ricardo/incrementos/descarga_clientes_clean.sql';

	SYSTEM cSQL;

	LET cSQL = '';
	LET cSQL = 'echo "SELECT * '
    || ' FROM sd_clientes_clean_behavior " >>  /respaldos/descarga_clientes_clean.sql';
--    || '  FROM sd_clientes_clean_behavior " >>  /pisa/ricardo/incrementos/descarga_clientes_clean.sql';
	SYSTEM cSQL;
	
	LET cSQL = 'dbaccess bdicred /respaldos/descarga_clientes_clean.sql';
--	LET cSQL = 'dbaccess bdicred /pisa/ricardo/incrementos/descarga_clientes_clean.sql';
	SYSTEM cSQL;

	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, vproceso, '000000', 'Carga tabla bitacora', '02') Returning cCod_RetIB;

	LET cSQL = '';
	LET cSQL = 'echo "FILE /respaldos/sd_bitacora_aumlincred.unl DELIMITER '''||'|'||''' 50; INSERT INTO sd_bitacora_aumlincred; " > /respaldos/carga_sd_bitacora_aumlincred.sql';
	SYSTEM cSQL;
	
	LET cSQL = '';
	LET cSQL = 'dbload -d bdicred -c /respaldos/carga_sd_bitacora_aumlincred.sql -l /respaldos/carga_sd_bitacora_aumlincred.log -n 1000 -k';
--	LET cSQL =   'dbload -d bdicred -c /pisa/ricardo/incrementos/carga_sd_bitacora_aumlincred.sql -l   /pisa/ricardo/incrementos/carga_sd_bitacora_aumlincred.log -n 1000 -k';
	SYSTEM cSQL;

	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, vproceso, '000000', 'Carga tabla autorizacion', '02') Returning cCod_RetIB;

	LET cSQL = '';
	LET cSQL = 'echo "FILE /respaldos/sd_autorizacion_aumlincred.unl DELIMITER '''||'|'||''' 9; INSERT INTO sd_autorizacion_aumlincred; " > /respaldos/carga_sd_autorizacion_aumlincred.sql';
	SYSTEM cSQL;
	
	LET cSQL = '';
	LET cSQL = 'dbload -d bdicred -c /respaldos/carga_sd_autorizacion_aumlincred.sql -l /respaldos/carga_sd_autorizacion_aumlincred.log -n 1000 -k';
--	LET cSQL =   'dbload -d bdicred -c /pisa/ricardo/incrementos/carga_sd_autorizacion_aumlincred.sql -l   /pisa/ricardo/incrementos/carga_sd_autorizacion_aumlincred.log -n 1000 -k';
	SYSTEM cSQL;

	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, vproceso, '000000', 'Carga tabla clientes clean', '02') Returning cCod_RetIB;

	LET cSQL = '';
	LET cSQL = 'echo "FILE /respaldos/sd_clientes_clean_behavior.unl DELIMITER '''||'|'||''' 9; INSERT INTO sd_clientes_clean_behavior; " > /respaldos/carga_sd_clientes_clean_behavior.sql';
	SYSTEM cSQL;
	
	LET cSQL = '';
	LET cSQL = 'dbload -d bdicred -c /respaldos/carga_sd_clientes_clean_behavior.sql -l /respaldos/carga_sd_clientes_clean_behavior.log -n 1000 -k';
--	LET cSQL =   'dbload -d bdicred -c /pisa/ricardo/incrementos/carga_sd_clientes_clean_behavior.sql -l   /pisa/ricardo/incrementos/carga_sd_clientes_clean_behavior.log -n 1000 -k';
	SYSTEM cSQL;
	
END IF;
*/
    UPDATE STATISTICS MEDIUM FOR TABLE bdicred:sd_bitacora_aumlincred;
    UPDATE STATISTICS MEDIUM FOR TABLE bdicred:sd_autorizacion_aumlincred;
    UPDATE STATISTICS MEDIUM FOR TABLE bdicred:sd_clientes_clean_behavior;

	UPDATE bdicred:sd_param SET valor = '0'	WHERE empresa = cEmpresa AND cod_param = '054';
	
--	SELECT COUNT(*) INTO iTotalProcesados FROM bdicred:sd_bitacora_aumlincred;

	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, vproceso, '000000', 'TOTAL cuentas procesadas '||iTotalProcesados, '02') Returning cCod_RetIB;

--	SELECT COUNT(*) INTO iTotalBitacora FROM bdicred:sd_autorizacion_aumlincred;

	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, vproceso, '000000', 'TOTAL cuentas en bitacora '||iTotalBitacora, '02') Returning cCod_RetIB;
	
	-- Elimina los creditos que no fueron considerados para el incremento de lcr (el proceso normal de incrementos los rechazo)
	/* DELETE FROM bdicred:"informix".sd_clientes_dirty_behavior WHERE month(fecha_reporte) = month(pFechaHoyAumlincred) 
        AND year(fecha_reporte) = year(pFechaHoyAumlincred) AND status_bit IS NULL;*/
		
    LET cMensajeRet            = "Se realizo la consulta correctamente. Registros procesados "||iTotalProcesados;
    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, vproceso, cCodRet, cMensajeRet, '03') Returning cCod_RetIB;

    RETURN cCodRet, cMensajeRet;

END
END PROCEDURE
DOCUMENT 
'Se realiza procedimiento para obtener clientes prospectos para incremento de linea de crÃ©dito',
'de acuerdo a las validaciones propias de la empresa',
'AUTOR : JesÃºs Manuel Aguilar Heredia',
'FECHA : 09/JUNIO/2010',
'BD    : BDICRED',
'Se modifica para contemplar la nueva funcionalidad de incrementos automÃ¡ticos para clientes que tengan activa esta opcion',
'MODIFICO : JesÃºs Manuel Aguilar Heredia',
'FECHA : 14/MARZO/2011',
'BD    : BDICRED',
'VERSION:20110314.1530',
'Se modifica para insertar campos agregados a tabla sd_bitacora_aumlincred y para obtener incrementos previos',
'MODIFICO : Rochin Rocha Edgar Ivan',
'FECHA : 27/JUNIO/2011',
'BD    : BDICRED',
'VERSION:20110627.1530',
'Se modifica para no contemplar TDC Garantizadas en el proceso de incrementos automÃ¡ticos',
'MODIFICO : JesÃºs Manuel Aguilar Heredia',
'FECHA : 25/ENERO/2012',
'BD    : BDICRED',
'VERSION:20120125.1530',
'Se modifica para contemplar las solicitudes de incrementos automaticos desde sucursal',
'MODIFICO : JesÃºs Manuel Aguilar Heredia',
'FECHA : 14/NOVIEMBRE/2011',
'BD    : BDICRED',
'VERSION:20111114.1530',
'Se agrega el flujo para el incremento especial',
'MODIFICO : Sergio Esteban Camacho Paez',
'FECHA : 4/NOVIEMBRE/2025',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_obtiene_tabla_amortizacion_edocta( pEmpresa CHAR(3))
	RETURNING   CHAR(6)         AS Codigo; 		  	-- CODIGO DE RETORNO


	-- VARIABLES PARA RETORNO DE DATOS --
	DEFINE cCodRet     			CHAR(6); 			-- CODIGO DE RETORNO DE ERROR
	DEFINE iPeriodo				INTEGER;			-- PERIODO ACTUAL PARA PP
	DEFINE iCicloRtc 			INTEGER;   			-- PERIODO ACTUAL PARA RTC
	DEFINE dtFechaCouta			DATE;				-- FECHA DEL PAGO PARA PP
	DEFINE dtFecha_Alta       	DATE;				-- FECHA DEL PAGO PARA RTC
	DEFINE dSdoInicial			MONEY(14,2);		-- SALDO INICIAL
	DEFINE dMensualidad			DECIMAL(18,6);		-- MENSUALIDAD
	DEFINE dIntereses			MONEY(14,2);		-- INTERESES
	DEFINE dIvaInt				DECIMAL(14,2);		-- IVA DE INTERESES
	DEFINE dCapital				MONEY(14,2);		-- CAPITAL
	DEFINE dSdoFinal			DECIMAL(18,6);		-- SALDO FINAL
	DEFINE iDiasPeriodo			INTEGER;			-- DIAS DEL PERIODO
	DEFINE dtFechaAper			DATE;				-- FECHA DE APERTURA
	DEFINE dPlazoAux      		DECIMAL(18,6);		-- NUMERO DE MESES PAGO
	DEFINE dMtoContrato      	DECIMAL(18,2);		-- MONTO CONTRATADO PARA PP
	DEFINE dEnganchePag      	DECIMAL(18,2);		-- ENGANCHE PAGADO DE LA RTC
	DEFINE dMtoTotalaPagar      DECIMAL(18,2);		-- MONTO TOTAL A PAGAR PARA PP Y RTC
	DEFINE cTasaFija      		CHAR(6);			-- TASA DE INTERES FIJA ANUAL PARA PP Y RTC
	DEFINE dTasaFija      		DECIMAL(18,2);		-- TASA DE INTERES FIJA ANUAL PARA PP Y RTC
	DEFINE dTotLiqpp 			DECIMAL(18,2);   	-- TOTAL LIQUIDACION PARA PRESTAMO
	DEFINE dTotLiqRtc 			DECIMAL(18,2);   	-- TOTAL LIQUIDACION PARA REESCTRUCTURA
	DEFINE dTotAhorro  			DECIMAL(18,2);		-- MONTO DE TE AHORRARIAS
	DEFINE cCadena1      		CHAR(3);
	DEFINE cCadena2      		CHAR(6);
	DEFINE cCadena3      		CHAR(6);
	-- VARIABLES AUXILIARES PARA PRESTAMO/REESTRUCTURA/CREDINOMINA
	DEFINE iSqlErr      		INTEGER;			-- CODIGO DE ERROR
	DEFINE dTasa				DECIMAL(18,6);		-- TASA ANUAL
	DEFINE dTasa_Mora			DECIMAL(18,6);		-- TASA ANUAL MORATORIA	
	DEFINE iContador 			INTEGER; 			-- PARA CONTROLAR LAS INTERACIONES DEL CICLO
	DEFINE cProducto     		CHAR(4);			-- NUMERO DEL PRODUCTO
	DEFINE dCapacidadPres		DECIMAL(18,6); 		-- CAPACIDAD DE PAGO DEL CLIENTE
	DEFINE iDiaPago      		INTEGER;			-- DIA DE PAGO
	DEFINE iPagosRealizados 	INTEGER;			-- NUMERO DE PAGOS REALIZADO
	DEFINE dIva              	MONEY(14,2);		-- IVA DE SUCURSAL
	-- VARIABLES AUXILIARES PARA PRESTAMO
	DEFINE dtFechaInicial		DATE;				-- FECHA QUE SE TOMA COMO INICIO PARA CALCULAR LAS DEMAS FECHAS
	DEFINE dtFechaAnt			DATE;				-- FECHA ANTERIOR DE COUTA
	DEFINE dTasaInt 			DECIMAL(18,6);		-- TASA DE INTERES
	DEFINE dtFechaCoutaAux		DATE;				-- FECHA DEL PAGO AUXILIAR
	DEFINE cFrecuencia     		CHAR(1);			-- FECUENCIA DEL PAGO
	DEFINE dMontoAut 			DECIMAL(18,6); 		-- MONTO DEL CREDITO
	DEFINE dPlazo  	 			DECIMAL(18,6);		-- PLAZO EN MESES PARA PAGAR
	-- VARIABLES AUXILIARES PARA REESTRUCTURA
	DEFINE dtFechaIniRtc		DATE;				-- FECHA CUOTA DE LA PRIMERA MENSUALIDAD
	DEFINE dtFechaActual		DATE;				-- FECHA DEL CAMPO  fecha_hoy DE LA TABLA sd_fechas
	DEFINE dSobreTasa			DECIMAL(18,2);		-- TASA ANUAL
	DEFINE cDias_Cal_Int    	CHAR(10);			-- DIAS PARA EL CALCULO DE INTERESES
	DEFINE cFactor_SobreTasa 	CHAR(1);			-- FACTOR SOBRE TASA
	DEFINE dTasa_IntDiario      DECIMAL(10,6);		-- TASA DE INTERES DIARIO
	DEFINE dTasa_Interes    	DECIMAL(9,6);		-- TASA DE INTERES
	DEFINE sPlazoMax			SMALLINT;			-- PLAZO MAXIMO
	-- VARIABLES PARA EL PROCEDIMIENTO sp_ofi_consultasdos
	DEFINE cCod_Ret2 			CHAR(6);			-- CODIGO DE RETORNO
	DEFINE cMensaje 			CHAR(80);  	  		-- MENSAJE DE RETORNO
	DEFINE cNumCred				CHAR(20); 	  		-- NUMERO DE CREDITO
	DEFINE cNumProd				CHAR(4); 	  		-- NUMERO DEL PRODUCTO
	DEFINE cDescProd			CHAR(40);      		-- DESCRIPCION DEL PRODUCTO
	DEFINE cNumCte				CHAR(20);      		-- NUMERO DE CLIENTE
	DEFINE cNomCte				CHAR(150);			-- NOMBRE DEL CLIENTE
	DEFINE dMtoLinea			DECIMAL(18,2);		-- MONTO DE LINEA OTORGADA
	DEFINE cStatus 				CHAR (60); 			-- ESATUS DEL CREDITO
	DEFINE dtProximo 			DATE;				-- FECHA DEL PROXIMO PAGO
	DEFINE dtFecha 				DATE; 				-- FECHA DEL PAGO
	DEFINE dSaldo				DECIMAL(18,2); 		-- SALDO DEL CREDITO
	DEFINE mInteres 			DECIMAL(18,2);   	-- INTERESES DEL CREDITO
	DEFINE dIvaInt2				DECIMAL(18,2);   	-- IVA DE INTERESES DEL CREDITO
	DEFINE mTotal 				DECIMAL(18,2);  	-- MONTO TOTAL DEL CREDITO
	DEFINE mPagos 				DECIMAL(18,2);      -- MONTO DE PAGO DEL CREDITO
	DEFINE mMinimo 				DECIMAL(18,2);   	-- MONTO DE PAGO MINIMO DEL CREDITO
	DEFINE mSaldar 				DECIMAL(18,2); 		-- MONTO DE TOTAL DE LIQUIDACION
	DEFINE dAhorro  			DECIMAL(18,2);		-- MONTO DE AHORRO DEL CREDITO
	DEFINE mDeuda 				DECIMAL(18,2);   	-- MONTO DE DEUDA DEL CREDITO
	DEFINE mPagReal				DECIMAL(18,2);   	-- MONTO DE PAGO REAL DEL CREDITO
	DEFINE mIntDeven			DECIMAL(18,2);   	-- INTERESES DEVENGADOS DEL CREDITO
	DEFINE dIvaIntDeven			DECIMAL(18,2);  	-- IVA DE INTERES DEVENGADOS DEL CREDITO
	DEFINE mComision 			DECIMAL(18,2);   	-- MONTO DE COMISION DEL CREDITO
	DEFINE mIvaCom 				DECIMAL(18,2);   	-- IVA DE COMISION DEL CREDITO
	DEFINE mMonto 				DECIMAL(18,2);   	-- MONTO DEL CREDITO
	DEFINE iPagos 				INTEGER;       		-- NUMERO DE PAGOS DEL CREDITO
	DEFINE iPlazo 				INTEGER;   			-- NUMERO DE PLAZOS DEL CREDITO
	DEFINE cCodRetTDif			CHAR(6);			-- COD RETORNO TASAS DIFERENCIADAS
	DEFINE dfechahoy 			DATE;
	DEFINE vfechahoy 			DATE;
	DEFINE vMesAnt				DATE;
	DEFINE vAnioAnt				DATE;
	DEFINE dSum_capital DECIMAL(18,2); 
	DEFINE	dSum_intereses DECIMAL(18,2); 
	DEFINE	dSum_iva_intereses DECIMAL(18,2); 
	DEFINE	dSum_pagomin DECIMAL(18,2); 
	DEFINE  pNumCred CHAR(12);
	DEFINE cAmortiza INTEGER;
	DEFINE cBandera INTEGER;
	DEFINE pSucursal CHAR(4);
	DEFINE dMesesadicionales  INTEGER;
	DEFINE dFecha_vencim DATE;
	DEFINE dInteresesAcum MONEY(14,2);
	DEFINE sSdo_debe MONEY(14,2);
	DEFINE sSdo_pagado MONEY(14,2);
	DEFINE psaldoInteresApoyo DECIMAL(18,2);
	DEFINE psaldoIvaApoyo DECIMAL(18,2);
	DEFINE dSdoAdeudTotal  DECIMAL(18,2);
	DEFINE pProporcion  DECIMAL(18,2);
	DEFINE dUltimopago  DECIMAL(18,2);
	DEFINE dUlt_interes  DECIMAL(18,2);
	DEFINE dUltiva  DECIMAL(18,2);
	DEFINE dInt_restante  DECIMAL(18,2);
	DEFINE dInteres_sumar  DECIMAL(18,2);
	DEFINE dIva_sumar  DECIMAL(18,2);
	DEFINE pFinal_intreses  DECIMAL(18,2);
	DEFINE pFinal_iva	  DECIMAL(18,2);
	DEFINE DFinal_montopago  DECIMAL(18,2);
	DEFINE dUltpago_capital  DECIMAL(18,2);
	DEFINE dInteresesN DECIMAL(18,2);
	DEFINE dIvaIntN DECIMAL(18,2);
	DEFINE dMensualidadN DECIMAL(18,2);
	DEFINE dSdoAdeudTotal_liquidar DECIMAL(18,2);

	
	-- VARIABLES PARA RETORNO DE DATOS
	LET cCodRet     			= '000000';
	LET iPeriodo				= 0;
	LET iCicloRtc				= 0;
	LET dtFechaCouta			= DATE(1);
	LET dtFecha_Alta			= DATE(1);
	LET dSdoInicial				= 0;
	LET dMensualidad			= 0;
	LET dIntereses				= 0;
	LET dIvaInt					= 0;
	LET dCapital				= 0;
	LET dSdoFinal				= 0;
	LET iDiasPeriodo			= 0;
	LET dtFechaAper				= DATE(1);
	LET dPlazoAux      			= 0;
	LET dMtoContrato      		= 0;
	LET dEnganchePag			= 0;
	LET dMtoTotalaPagar      	= 0;
	LET dTasaFija				= 0;
	LET dTotLiqpp 				= 0;
	LET dTotLiqRtc 				= 0;
	LET dTotAhorro  			= 0;
	-- VARIABLES AUXILIARES PARA PRESTAMO/REESTRUCTURA/CREDINOMINA
	LET iSqlErr      			= 0;
	LET dTasa					= 0;
	LET dTasa_Mora				= 0;
	LET iContador 				= 0;
	LET cProducto     			= '';
	LET dCapacidadPres			= 0;
	LET iDiaPago      			= 0;
	LET iPagosRealizados 		= 0;
	LET dIva              		= 0;
	-- VARIABLES AUXILIARES PARA PRESTAMO
	LET dtFechaInicial			= DATE(1);
	LET dtFechaAnt				= DATE(1);
	LET dTasaInt 				= DATE(1);
	LET dtFechaCoutaAux			= DATE(1);
	LET cFrecuencia     		= '';
	LET dMontoAut 				= 0;
	LET dPlazo  	 			= 0;
	-- VARIABLES AUXILIARES PARA REESTRUCTURA
	LET dtFechaActual			= DATE(1);
	LET dtFechaIniRtc			= DATE(1);
	LET dSobreTasa				= 0;
	LET cDias_Cal_Int    		= '';
	LET cFactor_SobreTasa 		= '';
	LET dTasa_IntDiario     	= 0;
	LET dTasa_Interes    		= 0;
	LET sPlazoMax				= 0;
	-- VARIABLES PARA EL PROCEDIMIENTO sp_ofi_consultasdos
	LET cCod_Ret2 				= '000000';
	LET cMensaje 				= '';
	LET cNumCred				= '';
	LET cNumProd				= '';
	LET cDescProd				= '';
	LET cNumCte					= '';
	LET cNomCte					= '';
	LET dMtoLinea				= 0;
	LET cStatus 				= '';
	LET dtProximo 				= DATE(1);
	LET dtFecha 				= DATE(1);
	LET dSaldo					= 0;
	LET mInteres 				= 0;
	LET dIvaInt2				= 0;
	LET mTotal 					= 0;
	LET mPagos 					= 0;
	LET mMinimo 				= 0;
	LET mSaldar 				= 0;
	LET dAhorro  				= 0;
	LET mDeuda 					= 0;
	LET mPagReal				= 0;
	LET mIntDeven				= 0;
	LET dIvaIntDeven			= 0;
	LET mComision 				= 0;
	LET mIvaCom 				= 0;
	LET mMonto 					= 0;
	LET iPagos 					= 0;
	LET iPlazo 					= 0;
	LET cCodRetTDif				= '';
	LET dfechahoy				= DATE(1);
	LET vfechahoy				= DATE(1);
	LET vMesAnt					= DATE(1);
	LET vAnioAnt				= DATE(1);
	LET dSum_capital 			= 0;
	LET	dSum_intereses 			= 0;
	LET	dSum_iva_intereses 		= 0;
	LET	dSum_pagomin 			= 0;
	LET pNumCred				= '';
	LET cAmortiza = 0;
	LET cBandera = 0;
	LET pSucursal = '';
	LET dMesesadicionales = 0;
	LET dFecha_vencim = DATE(1);
	LET dInteresesAcum =  0;
	LET sSdo_debe = 0;
	LET sSdo_pagado =  0;
	LET psaldoInteresApoyo = 0;
	LET psaldoIvaApoyo = 0;
	LET dSdoAdeudTotal   = 0;
	LET pProporcion   = 0;
	LET dUltimopago  = 0;
	LET dUlt_interes   = 0;
	LET dUltiva   = 0;
	LET dInt_restante  = 0;
	LET dInteres_sumar  = 0;
	LET dIva_sumar   = 0;
	LET pFinal_intreses   = 0;
	LET pFinal_iva	   = 0;
	LET DFinal_montopago   = 0;
	LET dUltpago_capital  = 0;
	LET dInteresesN  = 0;
	LET dIvaIntN  = 0;
	LET dMensualidadN  = 0;
	LET dSdoAdeudTotal_liquidar  = 0;

	BEGIN

		ON EXCEPTION  SET iSqlErr
			IF iSqlErr <> 0  THEN
				LET  cCodRet  = iSqlErr;
				RETURN NVL(cCodRet,'');
			END IF;
		END  EXCEPTION

--		SET DEBUG FILE TO '/home/sysaccapp4/cobranza/rqi21402/home/sysaccapp4/cobranza/rqi21402/sp_obtiene_tabla_amortizacion.out';
--		TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT fecha_hoy - 1 units day, fecha_hoy - 1 UNITS MONTH, fecha_hoy - 1 UNITS YEAR ---SE COMENTA PARA PRUEBAS
			INTO vfechahoy, vMesAnt, vAnioAnt
		FROM bdicred:"informix".sd_fechas;
		
		-- Si los dÃ­as son FESTIVOS 25 de Dic y 1 de Ene
		IF (MONTH(vfechahoy) = 12 AND DAY(vfechahoy) = 25) THEN 
			LET dfechahoy = MDY(MONTH(vfechahoy),24,YEAR(vfechahoy));
		ELIF (LPAD(MONTH(vfechahoy),2,0) = 1 AND LPAD(DAY(vfechahoy),2,0) = 1) THEN 
			LET dfechahoy = MDY(MONTH(vMesAnt),31,YEAR(vAnioAnt));
		ELSE
			LET dfechahoy = vfechahoy;
		END IF;
		
		--LET dfechahoy = MDY(10,29,2020);
		--RQI 27 231 Se contemplan productos 9100 y 9300 para impresion de tabla de amortiza en Edo Cta
			FOREACH
					 SELECT  a.num_credito
							  INTO pNumCred
							  FROM "informix".sd_encabezado_edoctacrd a
							 WHERE  a.fecha_emision = dfechahoy
							   --AND a.empresa = pempresa
								AND a.num_producto IN ('6300','7600','7700','6800','9100','9300')
								AND a.ind_tabla_amortizacion = 1

								
					-- SE OBTIENEN LOS PARAMETROS PARA VALIDAR EL MONTO Y EL PLAZO DEL CREDITO,
					--INCLUYE EL ENGANCHE PAGADO DE LA REESTRUCTURA
					SELECT plazo, periodo_plazo,fecha_apertura,
						num_producto,valor_preferencial,tasa_interes::CHAR(6),sucursal,fecha_vencim
					INTO dPlazo,cFrecuencia,dtFechaCouta,
						cProducto,dEnganchePag,cTasaFija, pSucursal,dFecha_vencim
					FROM "informix".sd_maecredcrd
					WHERE empresa = pEmpresa AND num_credito = pNumCred
					AND status_cred IN ('AA','E1');
					
					IF NVL(cProducto,'') = '' THEN
						--LET cCodRet = '001042';
						CONTINUE FOREACH;
					END IF;
					
					INSERT INTO "informix".sd_amortizacion_creditoedoctacrd (
							fecha_emision ,num_credito ,monto_ahorro ,num_periodo ,fecha_pago ,pago_capital, intereses  ,iva_intereses ,monto_pago  ,
							saldo_insoluto ,sum_capital ,sum_intereses ,sum_iva_intereses  ,sum_pagomin  )
					VALUES(dfechahoy,pNumCred, 0.00,0,dtFechaCouta ,0.00,0.00,0.00,
							0.00,0.00,0.00,0.00,0.00,0.00);
					LET dTotAhorro = 0.00;
					--SE TOMA COMO REFERENCIA LA FECHA DE APERTURA PARA PP
					LET dtFechaCoutaAux = dtFechaCouta;

					--SI ES CREDINOMINA RESPETA RESPETA LA FECHA ACTUAL
					SELECT fecha_hoy
					INTO dtFechaActual
					FROM "informix".sd_fechas
					WHERE empresa = pEmpresa ;

					-- CONSULTA SALDO INICIAL PARA PP Y RTC, MONTO DE TOTAL A PAGAR PARA PRESTAMO PERSONAL
					SELECT  sdo_cap_insoluto,mto_capitalizado
					INTO  dSdoInicial,dMtoTotalaPagar
					FROM "informix".sd_maesdoscrd
					WHERE num_credito = pNumCred
					AND empresa = pEmpresa;

					
	   
					--NUMERO DE PAGOS REALIZADOS
					SELECT COUNT(num_credito)
					INTO iPagosRealizados
					FROM "informix".sd_amortiza_creditocrd
					WHERE empresa = pEmpresa
					AND num_credito = pNumCred
					AND capital_status = '5';

					-- SE OBTIENE EL I.V.A
					SELECT valor
					INTO dIva
					FROM "informix".sd_param
					WHERE empresa = '001'
					AND cod_param = '12';

					-- SE OBTIENE LA TASA ANUAL
					
					SELECT a.factor_sobretasa, a.sobretasa, plazo_max_cred
					  INTO cFactor_SobreTasa,  dSobreTasa, sPlazoMax
					  FROM "informix".sd_definicion a
					 WHERE a.num_producto = cProducto;
					
					LET dTasa = cTasaFija; -- Calculo de intereses diarios se hace en base a la tasa del credito ya que varia por credito.
					
					
					--MONTO DE LA MENSUALIDAD
					--OBTIENE LA FECHA CUOTA PARA LA PRIMERA MENSUALIDAD
					SELECT capital_mto_cuota,fecha_cuota
					INTO dCapacidadPres,dtFechaIniRtc
					FROM "informix".sd_amortiza_creditocrd
					WHERE num_credito = pNumCred
					AND  num_pago = 1;
					
					
						--TASA DE INTERES FIJA ANUAL
						IF NVL(cTasaFija,'') <> '' THEN
							LET cCadena1 = SUBSTR(cTasaFija, 0, INSTR(cTasaFija, '.')-1);
							LET cCadena2 = (cTasaFija - cCadena1); 
							LET cCadena2 = SUBSTR(cCadena2, 3, INSTR(cCadena2, '.')-1);
							LET cTasaFija = TRIM(cCadena1)  || '.' || TRIM(cCadena2);
							LET dTasaFija = NVL(TRIM(cTasaFija)::DECIMAL(18,2),0);
						END IF;
						
						--plazo origen del prÃÂ©stamo
						LET iPlazo = dPlazo;
						
					---se revisa si es programa de apoyo.	
						SELECT COUNT(*) 
						INTO cBandera
						FROM bdicred:sd_programa_apoyo2020crd 
						WHERE  num_credito = pNumCred;

					IF cBandera > 0 THEN
					
						SELECT count(fecha_cuota) 
						 INTO cAmortiza
							FROM "informix".sd_amortiza_creditocrd
							WHERE empresa = pEmpresa
							AND num_credito = pNumCred;
							
							IF cAmortiza > dPlazo THEN
							 LET dPlazo = cAmortiza;
							END IF;
						--- se obtienen los  montos de INT e IVA de la maeretenido del prorama de apoyo
						SELECT monto
							INTO psaldoInteresApoyo
						FROM bdicred:sd_maeretenido 
						WHERE num_credito = pNumCred
							AND transacc = '8374'
							AND estatus = 'R';

							IF psaldoInteresApoyo IS NULL THEN
								LET psaldoInteresApoyo = 0;
							END IF;

						SELECT monto
							INTO psaldoIvaApoyo
						FROM bdicred:sd_maeretenido 
						WHERE num_credito = pNumCred
							AND transacc ='8375'
							AND estatus = 'R';

							IF psaldoIvaApoyo IS NULL THEN
								LET psaldoIvaApoyo = 0;
							END IF;
						
					END IF;
					
						LET dMontoAut = NVL(dSdoInicial,0);
						LET dPlazo = NVL(dPlazo,0) - NVL(iPagosRealizados,0);
						-- SE OBTIENE LA TASA ANUAL CON IVA
						LET dTasaInt = NVL(dTasa,0) / 100;
						LET dPlazoAux = NVL(dPlazo,0);

						IF cFrecuencia = 'M'  THEN --FRECUENCIA MENSUAL
							LET dPlazo = dPlazo * 1;
							LET iDiasPeriodo = 30;
						ELIF cFrecuencia = 'Q'  THEN --FRECUENCIA QUINCENAL
							LET dPlazo = dPlazo * 2;
							LET iDiasPeriodo = 15;
						END IF;

						LET dMensualidad = ROUND(dCapacidadPres,0);

						CALL "informix".monthadd(dtFechaCouta,iPagosRealizados) RETURNING dtFechaCouta;

						-- EL CICLO TENDRA EL NUMERO DE ITERACIONES IGUAL AL PLAZO DE PAGOS
						LET dtFechaInicial = dtFechaCouta;
						LET dtFechaAnt = dtFechaCouta;

						SELECT b.sdo_cap_insoluto
							  -- NVL(SUM(sdo_cap_insoluto + sdo_no_exig + int_tra_no_exig + mto_finan_vdo + mto_venc_int),0) --v_usted_debe_tc
						  INTO dSdoFinal
						  FROM sd_maecredcrd a, sd_maesdoshistcrd b
						 WHERE b.fecha = dfechahoy
						   AND a.empresa       = b.empresa
						   AND a.empresa       = pEmpresa
						   AND a.num_credito   = pNumCred
						   AND a.num_credito   = b.num_credito;
						
						---	Se suman los montos de interes e IVA del programa de apoyo a la deuda total

							IF psaldoInteresApoyo > 0 THEN
								LET dSdoAdeudTotal = 0;
								LET dSdoAdeudTotal = dSdoAdeudTotal + psaldoInteresApoyo + psaldoIvaApoyo;
								LET dSdoAdeudTotal_liquidar = psaldoInteresApoyo + psaldoIvaApoyo;
							END IF;
					
					IF dSdoFinal > 0 THEN 
								-- 26/11/2026 jahj rqi 21 402	
							LET dMesesadicionales = case when dMensualidad <> 0 then round(dSdoFinal / dMensualidad) + 1  else 0 end;
							
							LET dPlazo =  dPlazo + dMesesadicionales;
							
							
							
							--es porque ya excedio elpretamo
							IF dSdoAdeudTotal > 0 THEN 
								-- 26/11/2026 jahj rqi 21 402	
								LET dMesesadicionales = case when dMensualidad <> 0 then  round(dSdoAdeudTotal / dMensualidad) + 1 else 0 end;
								LET dPlazo =  dPlazo + dMesesadicionales;

							END IF;

					END IF;

				IF dPlazo > 0 THEN
					
						
						FOR iContador = 1 TO dPlazo  STEP 1

							-- SE OBTIENE EL SALDO INICIAL DEL PERIODO, SI EL SALDO FINAL ES CERO 
							--QUIERE DECIR QUE ES EL PRIMER PERIODO Y EL SALDO INICIAL ES IGUAL AL MONTO APROBADO
							IF dSdoFinal > 0 THEN
								LET dSdoInicial = NVL(dSdoFinal,0);
							END IF;

							IF dSdoFinal <= 0 AND iContador > 1 THEN
								IF dSdoAdeudTotal <= 0 THEN
								EXIT FOR;
								ELSE 
								LET dSdoInicial = 0;
								END IF;
								
							END IF;

							--SE OBTIENEN LOS MESES DEL PERIODO
							LET iPeriodo = NVL(iContador,0) + NVL(iPagosRealizados,0);

							-- ********************************************************************************************************************
							-- ************************** SE OBTIENE LA SIGUIENTE FECHA DE CUOTA Y LOS DIAS DEL PERIODO **********************
							--*********************************************************************************************************************
							
								--OBTIENE LA FECHA DE LA SIGUIENTE FECHA DE PAGO
								CALL "informix".monthadd(dtFechaInicial,iContador) RETURNING dtFechaCouta;
								--OBTIENE LA FECHA DE LA FECHA DE PAGO ANTERIOR
								CALL "informix".monthadd(dtFechaInicial,iContador-1) RETURNING dtFechaAnt;

								--SI LA FECHA CUOTA O FECHA ANTERIOS ESTAN ENTRE LOS DIAS FESTIVOS 1 DE ENERO Y 25 DE DICIEMBRE
								--SE PASAN AL DIA SIGUIENTE
								IF (MONTH(dtFechaCouta) = 1 AND DAY(dtFechaCouta) = 1) OR (MONTH(dtFechaCouta) = 12 AND DAY(dtFechaCouta) = 25) THEN
									LET dtFechaCouta = dtFechaCouta + 1;
								END IF;

								IF (MONTH(dtFechaAnt) = 1 AND DAY(dtFechaAnt) = 1) OR (MONTH(dtFechaAnt) = 12 AND DAY(dtFechaAnt) = 25) THEN
									LET dtFechaAnt = dtFechaAnt + 1;
								END IF;

								IF iContador = 1 THEN
									IF NVL(iPagosRealizados,0 ) =0 THEN
										LET iDiasPeriodo = dtFechaCouta - dtFechaCoutaAux;
									ELSE
										LET iDiasPeriodo = dtFechaCouta - dtFechaAnt;
									END IF
								ELSE
									LET iDiasPeriodo = dtFechaCouta - dtFechaAnt;
								END IF;
							

							--SE CALCULAN LOS INTERESES
							LET dIntereses = NVL(dSdoInicial,0) * (NVL(dTasaInt,0) / 360) * NVL(iDiasPeriodo,0);
							-- SE CALCULA EL IVA DE LOS INTERESES
							LET dIvaInt = ROUND(NVL(dIntereses,0) * NVL(dIva,0),2);

							IF dMontoAut < dMensualidad and dSdoFinal > 0  THEN
							
								/*IF iPeriodo > iPlazo THEN
								--IF iPeriodo = '13' THEN--
								--LET dSdoInicial = '700';--
								--END IF;--
								LET dCapital = dSdoInicial ;
								LET dMensualidad = dSdoInicial ;
								ELSE*/
								LET dMensualidad = NVL(dMontoAut,0) + NVL(dIntereses,0) + NVL(dIvaInt,0);
								LET dCapital = NVL(dMontoAut,0);
								--END IF;
							ELSE
								/*IF iPeriodo > iPlazo THEN
								--IF iPeriodo = '13' THEN--
								--LET dSdoInicial = '700';--
								--END IF;--
								LET dCapital = NVL(dMensualidad,0);
								ELSE*/
								IF dSdoFinal > 0 THEN
								LET dCapital = NVL(dMensualidad,0) - (NVL(dIntereses,0) + NVL(dIvaInt,0));
								ELSE
								LET dCapital = 0;
								END IF;
								--END IF;
								LET dIntereses = NVL(dIntereses,0) ;
								LET dIvaInt  = NVL(dIvaInt,0) ;
								LET iDiasPeriodo= NVL(iDiasPeriodo,0);
							END IF;

							-- SE CALCULA EL SALDO FINAL
							LET dSdoFinal = NVL(dSdoInicial,0) - NVL(dCapital,0);
							
						   
							LET dMontoAut = NVL(dSdoInicial,0) - NVL(dCapital,0);
							
							
						IF 	dSdoFinal = 0 and dSdoAdeudTotal > 0 THEN
						
						
								
							--proporcional a intereses
							-- 26/11/2025 JAHJ RQI 21 402
							LET pProporcion = case when dSdoAdeudTotal <> 0 then  round(psaldoInteresApoyo / dSdoAdeudTotal,10) else 0 end;
							
							/*SELECT pago_capital, monto_pago,intereses  ,iva_intereses 
							INTO dUltpago_capital, dUltimopago, dUlt_interes, dUltiva
							FROM sd_amortizacion_creditoedoctacrd
							WHERE num_credito = pNumCred
							AND num_periodo <> 0
							AND saldo_insoluto = 0;*/
							
							LET dUltpago_capital  = dCapital;
							LET dUltimopago = dMensualidad;
							LET dUlt_interes = dIntereses;
							LET dUltiva = dIvaInt;
							
							IF dCapital > 0 THEN
							
								IF dMensualidad < dCapacidadPres AND (dSdoAdeudTotal - dMensualidad) = 0 THEN
									LET dInt_restante = dMensualidad;								ELSE
									--IF dMensualidad < dCapacidadPres AND dSdoAdeudTotal <= dMensualidad THEN
									--	LET dInt_restante = dSdoAdeudTotal;
									--ELSE
										IF dSdoAdeudTotal > dMensualidad AND dSdoAdeudTotal <= dCapacidadPres  THEN
											LET dInt_restante = dSdoAdeudTotal;
										ELSE
											LET dInt_restante = dCapacidadPres - dUltimopago ;
										END IF;
									--END IF;
								END IF;
							ELSE
								IF dSdoAdeudTotal < dMensualidad THEN
								LET dMensualidad = dSdoAdeudTotal;								--LET  dIntereses = psaldoInteresApoyo;
								--LET dIvaInt = 0;
								/*ELSE
								--LET dMensualidad = dMensualidad;
								LET dIntereses = dMensualidad - psaldoIvaApoyo;
								LET dIvaInt = psaldoIvaApoyo;*/
								END IF;
							LET dInt_restante = dMensualidad;
							END IF;
							LET dInteres_sumar =  dInt_restante * pProporcion;
							LET dIva_sumar = dInt_restante - dInteres_sumar;
							
							
							LET pFinal_intreses = dUlt_interes + dInteres_sumar;
							LET pFinal_iva =  dUltiva + dIva_sumar;
							LET DFinal_montopago = dUltpago_capital + pFinal_intreses + pFinal_iva;
							
							
							--IF dCapital > 0 THEN
								LET dIntereses = pFinal_intreses;
								LET dIvaInt = pFinal_iva;
								LET dMensualidad = DFinal_montopago;
							--ELSE 
								
							IF dCapital = 0 THEN	
								IF dSdoAdeudTotal > 0 THEN
								let psaldoInteresApoyo = psaldoInteresApoyo - dIntereses;
								let dSdoAdeudTotal = dSdoAdeudTotal - dMensualidad;								LET psaldoIvaApoyo = psaldoIvaApoyo - dIvaInt;
								END IF;
							 ELSE
								IF dSdoAdeudTotal > 0 THEN
								let psaldoInteresApoyo = psaldoInteresApoyo - dInteres_sumar;
								let dSdoAdeudTotal = dSdoAdeudTotal - (dInteres_sumar + dIva_sumar );								LET psaldoIvaApoyo = psaldoIvaApoyo - dIva_sumar;
								END IF;
							END IF;
							--END IF;
							
						END IF;
							
							INSERT INTO "informix".sd_amortizacion_creditoedoctacrd (
							fecha_emision ,num_credito ,monto_ahorro ,num_periodo ,fecha_pago ,pago_capital, intereses  ,iva_intereses ,
							monto_pago  ,
							saldo_insoluto ,sum_capital ,sum_intereses ,sum_iva_intereses  ,sum_pagomin  )
							VALUES(dfechahoy,pNumCred, 0.00,iPeriodo,dtFechaCouta ,dCapital,dIntereses,dIvaInt,
							dMensualidad,dSdoFinal,0.00,0.00,0.00,0.00);
							
						
						/*	UPDATE "informix".sd_amortizacion_creditoedoctacrd 
							set intereses = pFinal_intreses  ,iva_intereses = pFinal_iva , monto_pago = DFinal_montopago
							WHERE fecha_emision = dfechahoy
								AND num_credito = pNumCred
								AND num_periodo <> 0
								AND pago_capital > 0
							AND saldo_insoluto = 0;*/
							
							/*INSERT INTO "informix".sd_amortizacion_creditoedoctacrd (
							fecha_emision ,num_credito ,monto_ahorro ,num_periodo ,fecha_pago ,pago_capital, intereses  ,iva_intereses ,monto_pago  ,
							saldo_insoluto ,sum_capital ,sum_intereses ,sum_iva_intereses  ,sum_pagomin  )
							VALUES(dfechahoy,pNumCred, 0.00,iPeriodo,dtFechaCouta ,0.00,dInteresesN,dIvaIntN,
							dMensualidadN,0.00,0.00,0.00,0.00,0.00);*/
				
							
						END FOR;
			
				END IF;
					
							SELECT sum(pago_capital), sum(intereses), sum(iva_intereses), sum(monto_pago)
								INTO dSum_capital, dSum_intereses, dSum_iva_intereses, dSum_pagomin
							FROM  "informix".sd_amortizacion_creditoedoctacrd
								WHERE fecha_emision = dfechahoy
								AND num_credito = pNumCred;
								
							IF cBandera > 0 THEN
							LET dSum_capital = dSum_capital + dSdoAdeudTotal_liquidar;
							END IF;
							
							LET dTotAhorro = NVL(dTotAhorro,0) + NVL(dSum_intereses,0) + NVL(dSum_iva_intereses,0);
							
							UPDATE "informix".sd_amortizacion_creditoedoctacrd 
							set sum_capital = dSum_capital, sum_intereses = dSum_intereses, sum_iva_intereses = dSum_iva_intereses,  
							sum_pagomin = dSum_pagomin,
							monto_ahorro = dTotAhorro
							WHERE fecha_emision = dfechahoy
								AND num_credito = pNumCred
								AND num_periodo = '0';
								
							
			END FOREACH;
						
								
								
			RETURN NVL(cCodRet,'');
		
	END;
END PROCEDURE
DOCUMENT
'CREACION: GUADALUPE DE JESUS ESPINOZA VALENZUELA',
'FECHA: 29/08/2020 ',
'BD:BDICRED';

CREATE PROCEDURE "informix".sp_valida_spei_cred(pvchrclaverastreo CHAR(30),p_cta_clabe CHAR(18),pmonto MONEY(14,2))
RETURNING CHAR(6)       	AS retorno,
		CHAR(100)     		AS mensaje,
		CHAR (20)			AS numcte,
		CHAR (100)			AS nombre,
		CHAR (13)			AS rfc;	
		  

-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************

DEFINE cCodRet      		CHAR(6); 
DEFINE vMensaje             CHAR(300);
DEFINE iSqlErr      		INTEGER;
DEFINE iIsamErr     		INTEGER;

DEFINE vbanco				CHAR (3);
DEFINE p_cod_banco			CHAR (3);
DEFINE p_cod_financiero		CHAR (3);
DEFINE p_cod_producto		CHAR (4);
DEFINE tipo_producto		INTEGER;
DEFINE v_status_cred		CHAR(2);
DEFINE v_num_credito		CHAR(20);
DEFINE v_numcte				CHAR(20);
DEFINE v_producto			CHAR (4);
DEFINE v_sucursal			CHAR (4);
DEFINE v_divisa				CHAR (2);
DEFINE v_divisa_cred		CHAR (2);
DEFINE v_transaccion		CHAR(4);
DEFINE v_Folio				CHAR(16);
DEFINE v_tipo_bloqueo		INTEGER;
DEFINE v_causa_bloqueo		CHAR (3);
DEFINE valida_total_posisiones INTEGER;
DEFINE v_validanumerico		CHAR(1);

DEFINE cCodRetGF			CHAR (3);
DEFINE cFolioSucGF			CHAR (16);

DEFINE CodRet				CHAR(5);     -- Codigo de Retorno
DEFINE g_Remanente			MONEY(14,2); -- Remanente
DEFINE g_IntMoraCob			MONEY(14,2); -- Interes Moratorio Cobrado
DEFINE g_IntVencCob			MONEY(14,2); -- Interes Vencido Cobrado
DEFINE g_CapVencCob			MONEY(14,2); -- Capital Vencido Cobrado
DEFINE g_IntVigCob			MONEY(14,2); -- Interes Vigente Cobrado
DEFINE g_CapVigCob			MONEY(14,2); -- Capital Vigente Cobrado
DEFINE g_Impuesto			MONEY(14,2); -- Impuesto Cobrado
DEFINE g_Comision			MONEY(14,2); -- Comisiones Cobradas
DEFINE g_Seguro				MONEY(14,2); -- Seguro Cobrado

DEFINE cCodRet2				CHAR(5);
DEFINE cMensaje				CHAR(80);
DEFINE cNumCreditocrd		CHAR(20);
DEFINE Cuenta_eje			CHAR(20);
DEFINE Producto				CHAR(40);
DEFINE Num_Cliente			CHAR(20);
DEFINE Nom_Cliente			CHAR(80);
DEFINE Pago_Efectivo		DECIMAL(18,2);
DEFINE Pago_Cuenta			DECIMAL(18,2);
DEFINE Monto_Operacion		DECIMAL(18,2);
DEFINE Saldo_Actual			DECIMAL(18,2);
DEFINE Status_Actual		CHAR(60);

DEFINE v_apell_paterno		CHAR (25);
DEFINE v_apell_materno		CHAR (25);
DEFINE v_nombrecte			CHAR (100);
DEFINE v_nombre1			CHAR (25);
DEFINE v_nombre2			CHAR (25);
DEFINE v_rfc				CHAR (13);
DEFINE pempresa				CHAR (3);
DEFINE cReferencia			CHAR (40);

-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************

LET cCodRet      			= '000000';
LET vMensaje				= 'Proceso Exitoso';
LET iSqlErr      			= 0;
LET iIsamErr     			= 0;

LET vbanco					= '';
LET p_cod_banco				= '';
LET p_cod_financiero		= '';
LET p_cod_producto			= '';
LET tipo_producto			= 0;
LET v_status_cred			= '';
LET v_num_credito			= '';
LET v_numcte				= '';
LET v_producto				= '';
LET v_sucursal				= '';
LET v_divisa				= '';
LET v_divisa_cred			= '';
LET v_transaccion			= '';
LET v_Folio					= '';
LET v_tipo_bloqueo			= 0;
LET v_causa_bloqueo			= '';
LET valida_total_posisiones = 0;
LET v_validanumerico		= '';

LET cCodRetGF				= '';
LET cFolioSucGF				= '';

LET CodRet		         	= '';
LET g_Remanente	         	= 0;
LET g_IntMoraCob	     	= 0;
LET g_IntVencCob	     	= 0;
LET g_CapVencCob	     	= 0;
LET g_IntVigCob	         	= 0;
LET g_CapVigCob	         	= 0;
LET g_Impuesto	         	= 0;
LET g_Comision	         	= 0;
LET g_Seguro		     	= 0;

LET cCodRet2			= "00000";
LET cMensaje			= "Se realizÃ³ el proceso exitosamente";
LET cNumCreditocrd		= '';
LET Cuenta_eje			= "";
LET Producto			= "";
LET Num_Cliente			= "";
LET Nom_Cliente			= "";
LET Pago_Efectivo		= 0;
LET Pago_Cuenta			= 0;
LET Monto_Operacion		= 0;
LET Saldo_Actual		= 0;
LET Status_Actual		= "";

LET v_apell_paterno			= '';
LET v_apell_materno			= '';
LET v_nombre1				= '';
LET v_nombre2				= '';
LET v_nombrecte				= '';
LET v_rfc					= '';
LET pempresa				= '001';
LET cReferencia				= '';


-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	BEGIN

		ON EXCEPTION SET iSqlErr, iIsamErr
			IF iSqlErr != 0 THEN
				LET cCodRet = iSqlErr;		
				RETURN cCodRet,vMensaje,v_numcte,v_nombrecte,v_rfc;
			END IF;
		END EXCEPTION;
		
---	  SET DEBUG FILE TO '/informix/Israel/sp_valida_spei_cred.out';
--	  SET DEBUG FILE TO '/RESPALDOSNEW/Israel/sp_valida_spei_cred.out';
--	  TRACE ON;

-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************	


		IF p_cta_clabe = '' OR p_cta_clabe IS NULL OR pmonto IS NULL OR  NVL (pmonto,'') = '' THEN
			LET cCodRet = '14';
			LET vMensaje = 'Falta informaciÃ³n mandatoria para completar el pago';
			RETURN cCodRet,vMensaje,v_numcte,v_nombrecte,v_rfc;
		END IF;
		
		--- Obtiene el numero de posiciones
		LET valida_total_posisiones = LENGTH(p_cta_clabe);
		
		--- Valida que la cadena sea solo numerica
		EXECUTE PROCEDURE bdinteg:sp_esnumerico (p_cta_clabe)
			INTO v_validanumerico;
		
		---- Consulta numero banco (clabe receptor de SPEI)
		select{+ INDEX(bdinteg:si_param ix_si_param)} valor INTO vbanco
		  FROM bdinteg:si_param
		  WHERE empresa = pempresa and cod_param = 5;

		--- Obtiene codigo Bancario
		LET p_cod_banco = SUBSTR(p_cta_clabe,1,3);
		--- Obtiene codigo financiero
		LET p_cod_financiero = SUBSTR(p_cta_clabe,4,3);
		--- Obtiene numero de producto
		LET p_cod_producto = SUBSTR(p_cta_clabe,7,2)||'00';
			
		IF NVL (p_cod_banco,'') <> vbanco THEN
			LET cCodRet = '6';
			LET vMensaje = 'Cuenta no pertenece al Banco Receptor';
			RETURN cCodRet,vMensaje,v_numcte,v_nombrecte,v_rfc;
		ELIF pmonto <= 0 THEN
			LET cCodRet = '15';
			LET vMensaje = 'Tipo de pago erroneo';	
			RETURN cCodRet,vMensaje,v_numcte,v_nombrecte,v_rfc;
		ELIF p_cod_producto = '6500' OR valida_total_posisiones <> 18 THEN
			LET cCodRet = '17';
			LET vMensaje = 'Tipo de cuenta no corresponde';		
			RETURN cCodRet,vMensaje,v_numcte,v_nombrecte,v_rfc;
		ELIF v_validanumerico = 'F' THEN
			LET cCodRet = '19';
			LET vMensaje = 'Caracter invalido';		
			RETURN cCodRet,vMensaje,v_numcte,v_nombrecte,v_rfc;
		END IF;	
		
		--AGO - ValidaciÃ³n de producto 7800 PARA NO PERMITIR PAGO DE ADN
		IF NVL(TRIM(p_cod_producto),'') != '' AND NVL(TRIM(p_cod_producto),'') = '7800' THEN
				LET cCodRet     = '15';	-- 'NO SE ACEPTA PRODUCTO 7800'
				RETURN cCodRet,'NO SE ACEPTA PAGO PRODUCTO 7800',v_numcte,v_nombrecte,v_rfc;
		END IF;
				
		IF p_cod_financiero in ('975') OR p_cod_producto = '7800' THEN
		
			SELECT a.num_credito,a.numcte,a.num_producto,a.status_cred,a.sucursal,a.divisa,a.id_unidad_prod,a.Cod_caract_2,b.divisa,b.transacc_spei
				INTO v_num_credito,v_numcte,v_producto,v_status_cred,v_sucursal,v_divisa_cred,v_tipo_bloqueo,v_causa_bloqueo,v_divisa,v_transaccion
			FROM  bdicred:"informix".sd_maecred a
				JOIN bdicred:sd_definicion b on (a.num_producto = b.num_producto)
				WHERE cuenta_clabe = p_cta_clabe;
				
				IF (v_num_credito IS NULL OR NVL (v_num_credito,'') = '') OR (v_numcte IS NULL OR NVL (v_numcte,'') = '') 
					OR (v_producto IS NULL OR NVL (v_producto,'') = '') THEN
						LET cCodRet = '1';
						LET vMensaje = 'Cuenta Inexistente';
						RETURN cCodRet,vMensaje,v_numcte,v_nombrecte,v_rfc;

--				ELIF (v_tipo_bloqueo <> '' OR v_tipo_bloqueo IS NOT NULL) 
--					AND (v_causa_bloqueo <> '' OR v_causa_bloqueo IS NOT NULL) THEN --- VALIDAR ESTATUS BLOQUEADO
--						LET cCodRet = '2';
--						LET vMensaje = 'Cuenta Bloqueada';
--						RETURN cCodRet,vMensaje,v_numcte,v_nombrecte,v_rfc;
--
--				ELIF v_status_cred IN ('FI','FF') THEN --- Validar tipos de canceladas FI cancelada por saldos inmateriales
--					LET cCodRet = '3';
--					LET vMensaje = 'Cuenta Cancelada';
--					RETURN cCodRet,vMensaje,v_numcte,v_nombrecte,v_rfc;
					
--				ELIF (NVL (v_divisa_cred,'') = '' OR v_divisa_cred IS NULL) OR  v_divisa <> v_divisa_cred THEN 
--					LET cCodRet = '5';
--					LET vMensaje = 'Cuenta en otra divisa';
--					RETURN cCodRet,vMensaje,v_numcte,v_nombrecte,v_rfc;
				END IF;
			--- Genera folio para el movimiento
			EXECUTE PROCEDURE bdicred:sp_generafoliocredi(user ,1)
			INTO cCodRetGF,cFolioSucGF;
			
				IF cCodRetGF::INTEGER <> 0 THEN
					LET cCodRet = '000447';
					LET vMensaje = 'OCURRIO UN ERROR EN EL PROCESO QUE GENERA EL FOLIO';
					RETURN cCodRet,vMensaje,v_numcte,v_nombrecte,v_rfc;
				ELSE
					IF pvchrclaverastreo IS NOT NULL AND pvchrclaverastreo != '' THEN LET cReferencia = pvchrclaverastreo; END IF;
					
					EXECUTE PROCEDURE bdicred:"informix".principalrefer (pempresa,v_num_credito,1,'',user,v_sucursal,cFolioSucGF,v_transaccion,0,pmonto,cReferencia)
						INTO CodRet, g_Remanente, g_IntMoraCob, g_IntVencCob,
							g_CapVencCob, g_IntVigCob, g_CapVigCob, g_Impuesto,
							g_Comision, g_Seguro;
							
						IF (CodRet::INTEGER <> 0) THEN
							LET cCodRet = '000448';
							LET vMensaje = 'Error al ejecutar el pago';
							RETURN cCodRet,vMensaje,v_numcte,v_nombrecte,v_rfc;
						ELSE
							SELECT apell_paterno,apell_materno,nombre1,nombre2,rfc
								INTO v_apell_paterno,v_apell_materno,v_nombre1,v_nombre2,v_rfc
							FROM bdinteg:si_cliente 
							WHERE numcte = v_numcte;
							
							IF v_nombre2 IS NULL OR NVL (v_nombre2,'') = '' THEN
								LET v_nombrecte = TRIM (v_nombre1)||' '||TRIM (v_apell_paterno)||' '||TRIM (v_apell_materno);
							ELSE
								LET v_nombrecte = TRIM (v_nombre1)||' '||TRIM (v_nombre2)||' '||TRIM (v_apell_paterno)||' '||TRIM (v_apell_materno);
							END IF;
								
						END IF;
				END IF;

		ELIF p_cod_financiero in ('970','971','972') THEN
		
			SELECT a.num_credito,a.numcte,a.num_producto,a.status_cred,a.sucursal,a.divisa,b.divisa,b.transacc_spei
				INTO v_num_credito,v_numcte,v_producto,v_status_cred,v_sucursal,v_divisa_cred,v_divisa,v_transaccion
			FROM  bdicred:"informix".sd_maecredcrd a
				JOIN bdicred:sd_definicion b on (a.num_producto = b.num_producto)
				WHERE cuenta_clabe = p_cta_clabe;
				
				IF (v_num_credito IS NULL OR NVL (v_num_credito,'') = '') OR (v_numcte IS NULL OR NVL (v_numcte,'') = '') 
					OR (v_producto IS NULL OR NVL (v_producto,'') = '') THEN
						LET cCodRet = '1';
						LET vMensaje = 'Cuenta Inexistente';
						RETURN cCodRet,vMensaje,v_numcte,v_nombrecte,v_rfc;

--				ELIF v_status_cred = '' THEN --- VALIDAR ESTATUS BLOQUEADO
--					LET cCodRet = '2';
--					LET vMensaje = 'Cuenta Bloqueada';
--					RETURN cCodRet,vMensaje,v_numcte,v_nombrecte,v_rfc;
--
--				ELIF v_status_cred IN ('CN','FF') THEN --- 
--					LET cCodRet = '3';
--					LET vMensaje = 'Cuenta Cancelada';
--					RETURN cCodRet,vMensaje,v_numcte,v_nombrecte,v_rfc;
--					
--				ELIF (NVL (v_divisa_cred,'') = '' OR v_divisa_cred IS NULL) OR  v_divisa <> v_divisa_cred THEN 
--					LET cCodRet = '5';
--					LET vMensaje = 'Cuenta en otra divisa';
--					RETURN cCodRet,vMensaje,v_numcte,v_nombrecte,v_rfc;
				END IF;
			--- Genera folio para el movimiento
			EXECUTE PROCEDURE bdicred:sp_generafoliocredi(user ,1)
			INTO cCodRetGF,cFolioSucGF;
			
				IF cCodRetGF::INTEGER <> 0 THEN
					LET cCodRet = '000447';
					LET vMensaje = 'OCURRIO UN ERROR EN EL PROCESO QUE GENERA EL FOLIO';
					RETURN cCodRet,vMensaje,v_numcte,v_nombrecte,v_rfc;
				ELSE

					EXECUTE PROCEDURE bdicred:sp_principal_suc_rr (pempresa,v_num_credito,v_producto,pmonto,0,user,v_sucursal,cFolioSucGF,v_transaccion)
						INTO cCodRet2,cMensaje,cNumCreditocrd,Cuenta_eje,Producto,Num_Cliente,Nom_Cliente,
							Pago_Efectivo,Pago_Cuenta,Monto_Operacion,Saldo_Actual,Status_Actual;
							
						IF (cCodRet2::INTEGER <> 0) THEN
							LET cCodRet = '000449';
							LET vMensaje = cMensaje;
							RETURN cCodRet,vMensaje,v_numcte,v_nombrecte,v_rfc;
						ELSE
							SELECT apell_paterno,apell_materno,nombre1,nombre2,rfc
								INTO v_apell_paterno,v_apell_materno,v_nombre1,v_nombre2,v_rfc
							FROM bdinteg:si_cliente 
							WHERE numcte = v_numcte;
							
							IF v_nombre2 IS NULL OR NVL (v_nombre2,'') = '' THEN
								LET v_nombrecte = TRIM (v_nombre1)||' '||TRIM (v_apell_paterno)||' '||TRIM (v_apell_materno);
							ELSE
								LET v_nombrecte = TRIM (v_nombre1)||' '||TRIM (v_nombre2)||' '||TRIM (v_apell_paterno)||' '||TRIM (v_apell_materno);
							END IF;
							
						END IF;
				END IF;
		ELSE
			LET cCodRet = '6';
			LET vMensaje = 'Cuenta no pertenece al Banco Receptor';
			RETURN cCodRet,vMensaje,v_numcte,v_nombrecte,v_rfc;		
		END IF;
		
	END		
	
RETURN cCodRet,vMensaje,v_numcte,v_nombrecte,v_rfc;

END PROCEDURE
DOCUMENT
'Proceso que realiza la validacion para aplicar un SPEI de credito',
'AUTOR : Israel Travieso',
'FECHA : SEP/2019',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_genarch_info_ctasrtpp()
--EXECUTE PROCEDURE sp_genarch_info_ctasrtpp();

	RETURNING CHAR(5), CHAR(50)    ;  --CodRet
	
	--*****************************************************
	--DECLARACION DE VARIABLES
	--*****************************************************
	DEFINE vCodRet      VARCHAR(05);
	DEFINE cMensaje     CHAR(150); 
	DEFINE iSqlErr      INTEGER;
	DEFINE iIsamErr     INTEGER;
	DEFINE Error_Info   VARCHAR(80);
	DEFINE vFechaHoy	DATE;
	DEFINE vDiaHoy		CHAR(02);
	DEFINE vMesHoy		CHAR(02);
	DEFINE vMesAnt		CHAR(02);
	DEFINE vAnioHoy		CHAR(04);
	DEFINE vFechaRep1	DATE;
	DEFINE vFechaRep2	DATE;
	DEFINE vFechaP1		DATE;
	
	DEFINE vRuta        VARCHAR(255);
	DEFINE v_sql        CHAR(3000);
	DEFINE v_sql1       CHAR(200);
	DEFINE v_sql2       CHAR(666);
	DEFINE v_sql3		CHAR(666);
	
	LET vCodRet     = '00000';
	LET cMensaje    = 'Ejecucion Exitosa';
	LET iSqlErr     = 0;
	LET iIsamErr    = 0;
	LET Error_Info  = '';
	LET vFechaHoy	= date(1);
	LET vDiaHoy		= '20';
	LET vMesHoy		= '';
	LET vMesAnt		= '';
	LET vAnioHoy	= '';
	LET vFechaRep1	= date(1);
	LET vFechaRep2	= date(1);
	LET vFechaP1	= DATE(1);
	
	LET vRuta   = ''; -- '/resplogifx/archivoscartera/';
	LET v_sql   = '';
	LET v_sql1  = '';
	LET v_sql2	= '';
	LET v_sql3	= '';
	
	BEGIN

	ON EXCEPTION SET iSqlErr, iIsamErr
        IF iSqlErr != 0 THEN
			LET vCodRet = iSqlErr;		
            LET cMensaje = 'Error en la ejecucion';
            RETURN vCodRet,cMensaje;
		END IF;
    END EXCEPTION;
	
	--SET DEBUG FILE TO '/informix/Ulises/RQM_repCarteras/sp_genarch_info_ctasrtpp.out';
	--TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	-- Obtiene el Mes y Anio para colocar en el archivo
	SELECT LPAD(MONTH(fecha_hoy),2,0),YEAR(fecha_hoy),LPAD(MONTH(fecha_hoy - 1 units month),2,0)
	INTO vMesHoy,vAnioHoy,vMesAnt
	FROM "informix".sd_fechas where empresa = '001';
	
	--LET vMesHoy = '07'; --para pruebas
	--LET vAnioHoy = '2021'; --para pruebas
	--LET vMesAnt	= '06'; --para pruebas
	
	-- se obtiene la fecha para filtar por mes la obtenciÃ³n de la informaciÃ³n
	LET vFechaRep1 = MDY(vMesAnt,17,vAnioHoy);
	LET vFechaRep2 = MDY(vMesHoy,17,vAnioHoy);
	
	-- Obtiene la ruta donde se realiza la descarga del archivo.
	SELECT TRIM(valor) INTO vRuta FROM sd_param WHERE empresa = '001' AND cod_param = '033';
	
	--LET vRuta = '/informix/ulises/RQI/25_183/OLTP/'; -- PARA PRUEBAS
	
	-- Descarga reporte de Pestamo Personal
/*	LET v_sql1 = ' echo "UNLOAD TO '||trim(vRuta)||'descargaRepPP.unl';
	LET v_sql2 = ' SELECT a.num_credito,a.numcte,a.nombre_cte,a.direccion_cn,a.direccion_col,a.direccion_del, '||
				' a.edo_cd,a.cl_cobra,a.cp,a.ruta,a.entre_calles,a.observaciones,b.capital_ven_tc,b.interes_ven_tc ' ||
				' FROM "informix".sd_encabezado_edoctacrd a '||
				' INNER JOIN "informix".sd_encabezado2_edoctacrd b on b.num_credito = a.num_credito and b.fecha_emision > '''||vFechaRep1|| ''' and b.fecha_emision <= '''||vFechaRep2|| ''' '||
				' WHERE a.fecha_emision > '''||vFechaRep1|| ''' and a.fecha_emision <= '''||vFechaRep2|| ''' and a.num_producto IN(''6300'',''7600'',''7700'',''6800'') ;"  > queryRepPP.sql';
*/
	LET v_sql1 = ' echo "UNLOAD TO '||trim(vRuta)||'descargaRepPP.unl';
	LET v_sql2 = ' SELECT nvl ( replace ( replace( a.num_credito, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
				 ' nvl ( replace ( replace( numcte, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
				 ' nvl ( replace ( replace( nombre_cte, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
				 ' nvl ( replace ( replace( direccion_cn, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
                 ' replace ( replace ( replace( direccion_col, ''|'' , '' '' ), ''\'' , '' '' ), '''','' '' ),'||
				 ' replace ( replace ( replace( direccion_del, ''|'' , '' '' ), ''\'' , '' '' ), '''','' '' ),'||
				 ' replace ( replace ( replace( edo_cd, ''|'' , '' '' ), ''\'' , '' '' ), '''','' '' ),'||
				 ' nvl ( replace ( replace( cl_cobra, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
				 ' nvl ( replace ( replace( cp, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),';
	LET v_sql3 = ' replace ( replace ( replace( ruta, ''|'' , '' '' ), ''\'' , '' '' ), '' '','' '' ),'||
				 ' nvl ( replace ( replace( entre_calles, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
                 ' nvl ( replace ( replace( observaciones, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
				 ' nvl ( capital_ven_tc,0),'||
				 ' nvl ( interes_ven_tc,0)'||
				 ' FROM "informix".sd_encabezado_edoctacrd a '||
				 ' INNER JOIN "informix".sd_encabezado2_edoctacrd b on b.num_credito = a.num_credito and b.fecha_emision > '''||vFechaRep1|| ''' and b.fecha_emision <= '''||vFechaRep2|| ''' '||
				 ' WHERE a.fecha_emision > '''||vFechaRep1|| ''' and a.fecha_emision <= '''||vFechaRep2|| ''' and a.num_producto IN(''6300'',''7600'',''7700'',''6800'') ;"  > queryRepPP.sql';
	LET v_sql = v_sql1||v_sql2||v_sql3;
	SYSTEM v_sql;
	
	LET v_sql = "dbaccess bdicred queryRepPP.sql";
	SYSTEM v_sql;
	
	LET v_sql = '';
    LET v_sql = "sed 's/|$//g' "||trim(vRuta)||'descargaRepPP.unl'||" >"||trim(vRuta)||'descargaRepPP1.txt';
    SYSTEM v_sql;
	
		-- Elimina los caracteres especiales que se tienen dentro de las columnas.
		  LET v_sql = '';
		  LET v_sql = 'echo " cd '|| '\"'||vRuta||'\"'||'" > eliminaespeciales.sh ' ;
		  SYSTEM v_sql;
		  
		  LET v_sql = '';
		  LET v_sql = "chmod 777 "||'eliminaespeciales.sh ';
		  SYSTEM v_sql;

		  LET v_sql = '';
		  LET v_sql = ' echo '||'"'||' sed  -e ''s/''\$(echo ['||'\"'||'\\\001\\\002\\\003\\\004\\\005\\\006\\\007\\\010\\\016\\\017\\\020\\\021'||		                     
		                         '\\\022\\\023\\\024\\\025\\\026\\\027\\\030\\\031\\\032\\\033\\\034\\\035\\\036\\\037'||
                              '\"'||'])''//g'' '||vRuta||'descargaRepPP1.txt'||" > "||vRuta||'descargaRepPP2.txt'||
                              '" >>'||'eliminaespeciales.sh ';
		  SYSTEM v_sql;
		  
		  LET v_sql = '';
		  LET v_sql = "./"||'eliminaespeciales.sh ';
		  SYSTEM v_sql;
	
	LET v_sql = '';
    LET v_sql = "sed 's/" || '"' ||  "//g' "||trim(vRuta)||'descargaRepPP2.txt'||" > " || trim(vRuta||'descargaRepPP1.txt');
    SYSTEM v_sql;
	
	--Elimina diagonal invertida
	LET v_sql = '';
    LET v_sql = "sed 's/[\]//g' "||trim(vRuta)||'descargaRepPP1.txt'||" >"||trim(vRuta)||'descargaRepPP2.txt';
    SYSTEM v_sql;
	
	--Convierte de formato Linux a Windows
	LET v_sql = '';
    LET v_sql = "awk 'sub(""$"", ""\r"")' "||trim(vRuta)||'descargaRepPP2.txt'||" > " || trim(vRuta||'clientesbancoppelppbase64_'||vMesHoy||SUBSTR(vAnioHoy, 3, 4)||'.txt');
    SYSTEM v_sql;
	
	LET v_sql = '';
	LET v_sql = " gzip " ||trim(vRuta)||'clientesbancoppelppbase64_'||vMesHoy||SUBSTR(vAnioHoy, 3, 4)||'.txt ';
    SYSTEM v_sql;
	
	LET v_sql = '';
    LET v_sql = "rm "||trim(vRuta)||'descargaRepPP.unl';
    SYSTEM v_sql;
	
	LET v_sql = '';
    LET v_sql = "rm "||trim(vRuta)||'descargaRepPP1.txt';
    SYSTEM v_sql;
	
	LET v_sql = '';
    LET v_sql = "rm "||trim(vRuta)||'descargaRepPP2.txt';
    SYSTEM v_sql;
	
	LET v_sql = '';
    LET v_sql = "rm "||'queryRepPP.sql';
    SYSTEM v_sql;
	
	LET v_sql = '';
    LET v_sql = "rm "||'eliminaespeciales.sh ';
    SYSTEM v_sql;
	
	LET v_sql1 = '';
	LET v_sql2 = '';
	
	-- Descarga reporte de Reestructura
/*	LET v_sql1 = ' echo "UNLOAD TO '||trim(vRuta)||'descargaRepRT.unl';
	LET v_sql2 = ' SELECT a.num_credito,a.numcte,a.nombre_cte,a.direccion_cn,a.direccion_col,a.direccion_del, '||
				' a.edo_cd,a.cl_cobra,a.cp,a.ruta,a.entre_calles,a.observaciones,b.capital_ven_tc,b.interes_ven_tc ' ||
				' FROM "informix".sd_encabezado_edoctacrd a '||
				' INNER JOIN "informix".sd_encabezado2_edoctacrd b on b.num_credito = a.num_credito and b.fecha_emision > '''||vFechaRep1|| ''' and b.fecha_emision <= '''||vFechaRep2|| ''' '||
				' WHERE a.fecha_emision > '''||vFechaRep1|| ''' and a.fecha_emision <= '''||vFechaRep2|| ''' and a.num_producto IN(''6011'') ;"  > queryRepRT.sql';
*/
	LET v_sql1 = ' echo "UNLOAD TO '||trim(vRuta)||'descargaRepRT.unl';
	LET v_sql2 = ' SELECT nvl ( replace ( replace( a.num_credito, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
				 ' nvl ( replace ( replace( numcte, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
				 ' nvl ( replace ( replace( nombre_cte, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
				 ' nvl ( replace ( replace( direccion_cn, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
                 ' replace ( replace ( replace( direccion_col, ''|'' , '' '' ), ''\'' , '' '' ), '''','' '' ),'||
				 ' replace ( replace ( replace( direccion_del, ''|'' , '' '' ), ''\'' , '' '' ), '''','' '' ),'||
				 ' replace ( replace ( replace( edo_cd, ''|'' , '' '' ), ''\'' , '' '' ), '''','' '' ),'||
				 ' nvl ( replace ( replace( cl_cobra, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
				 ' nvl ( replace ( replace( cp, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),';
	LET v_sql3 = ' replace ( replace ( replace( ruta, ''|'' , '' '' ), ''\'' , '' '' ), '' '','' '' ),'||
				 ' nvl ( replace ( replace( entre_calles, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
                 ' nvl ( replace ( replace( observaciones, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
				 ' nvl ( capital_ven_tc,0),'||
				 ' nvl ( interes_ven_tc,0)'||
				 ' FROM "informix".sd_encabezado_edoctacrd a '||
				 ' INNER JOIN "informix".sd_encabezado2_edoctacrd b on b.num_credito = a.num_credito and b.fecha_emision > '''||vFechaRep1|| ''' and b.fecha_emision <= '''||vFechaRep2|| ''' '||
				 ' WHERE a.fecha_emision > '''||vFechaRep1|| ''' and a.fecha_emision <= '''||vFechaRep2|| ''' and a.num_producto IN(''6011'') ;"  > queryRepRT.sql';
	LET v_sql = v_sql1||v_sql2||v_sql3;
	SYSTEM v_sql;
	
	LET v_sql = "dbaccess bdicred queryRepRT.sql";
	SYSTEM v_sql;
	
	LET v_sql = '';
    LET v_sql = "sed 's/|$//g' "||trim(vRuta)||'descargaRepRT.unl'||" >"||trim(vRuta)||'descargaRepRT1.txt';
    SYSTEM v_sql;
	
		-- Elimina los caracteres especiales que se tienen dentro de las columnas.
		  LET v_sql = '';
		  LET v_sql = 'echo " cd '|| '\"'||vRuta||'\"'||'" > eliminaespeciales.sh ' ;
		  SYSTEM v_sql;
		  
		  LET v_sql = '';
		  LET v_sql = "chmod 777 "||'eliminaespeciales.sh ';
		  SYSTEM v_sql;

		  LET v_sql = '';
		  LET v_sql = ' echo '||'"'||' sed  -e ''s/''\$(echo ['||'\"'||'\\\001\\\002\\\003\\\004\\\005\\\006\\\007\\\010\\\016\\\017\\\020\\\021'||		                     
		                         '\\\022\\\023\\\024\\\025\\\026\\\027\\\030\\\031\\\032\\\033\\\034\\\035\\\036\\\037'||
                              '\"'||'])''//g'' '||vRuta||'descargaRepRT1.txt'||" > "||vRuta||'descargaRepRT2.txt'||
                              '" >>'||'eliminaespeciales.sh ';
		  SYSTEM v_sql;
		  
		  LET v_sql = '';
		  LET v_sql = "./"||'eliminaespeciales.sh ';
		  SYSTEM v_sql;
	
	LET v_sql = '';
    LET v_sql = "sed 's/" || '"' ||  "//g' "||trim(vRuta)||'descargaRepRT2.txt'||" > " || trim(vRuta||'descargaRepRT1.txt');
    SYSTEM v_sql;
	
	--Elimina diagonal invertida
	LET v_sql = '';
    LET v_sql = "sed 's/[\]//g' "||trim(vRuta)||'descargaRepRT1.txt'||" >"||trim(vRuta)||'descargaRepRT2.txt';
    SYSTEM v_sql;
	
	--Convierte de formato Linux a Windows
	LET v_sql = '';
    LET v_sql = "awk 'sub(""$"", ""\r"")' "||trim(vRuta)||'descargaRepRT2.txt'||" > " || trim(vRuta||'clientesbancoppelrtbase64_'||vMesHoy||SUBSTR(vAnioHoy, 3, 4)||'.txt');
    SYSTEM v_sql;
	
	LET v_sql = '';
	LET v_sql = " gzip " ||trim(vRuta)||'clientesbancoppelrtbase64_'||vMesHoy||SUBSTR(vAnioHoy, 3, 4)||'.txt ';
    SYSTEM v_sql;
	
	LET v_sql = '';
    LET v_sql = "rm "||trim(vRuta)||'descargaRepRT.unl';
    SYSTEM v_sql;
	
	LET v_sql = '';
    LET v_sql = "rm "||trim(vRuta)||'descargaRepRT1.txt';
    SYSTEM v_sql;
	
	LET v_sql = '';
    LET v_sql = "rm "||trim(vRuta)||'descargaRepRT2.txt';
    SYSTEM v_sql;
	
	LET v_sql = '';
    LET v_sql = "rm "||'queryRepRT.sql';
    SYSTEM v_sql;
	
	LET v_sql = '';
    LET v_sql = "rm "||'eliminaespeciales.sh ';
    SYSTEM v_sql;
	
	END;
	RETURN vCodRet,cMensaje;
END PROCEDURE
DOCUMENT
'Reportes para Carteras Coppel de PP y RT',
'Autor: David Cuenca',
'BD: bdicred',
'Fecha: 2021';

CREATE PROCEDURE "informix".ugenera_layoutedocuenta_muestras(pempresa CHAR(3),pperiodo DATE) 
--EXECUTE PROCEDURE ugenera_layoutedocuenta_muestras('001',MDY('02','20','2022'));
RETURNING CHAR(5);

DEFINE v_ruta		VARCHAR(255);
DEFINE v_ruta_cfd	VARCHAR(255);
DEFINE cod_ret 		CHAR(5);
DEFINE sql_err 		INTEGER;
DEFINE v_sql        CHAR(8000);
DEFINE v_sql1       CHAR(1600);
DEFINE v_sql2       CHAR(1600);
DEFINE v_sql3       CHAR(1600);
DEFINE v_sql4       CHAR(1600);
DEFINE v_sql5       CHAR(1600);
DEFINE cNumCred     CHAR(20);
DEFINE cNumCredAux  CHAR(20);
DEFINE cNumCte      CHAR(20);
DEFINE cNumCteAux   CHAR(20);
DEFINE iMovMax      INTEGER;
DEFINE sPaso        SMALLINT;
DEFINE v_sql0       CHAR(50);

LET v_ruta      = "";
LET v_sql       = "";
LET v_sql1      = "";
LET v_sql2      = "";
LET v_sql3      = "";
LET v_sql4      = "";
LET v_sql5      = "";
LET sPaso       = 0; 
LET cNumCred    = "";
LET cNumCredAux = "";
LET cNumCte     = "";
LET cNumCteAux  = "";
LET iMovMax     = 0;
LET v_sql0 = ' echo "SET ISOLATION TO DIRTY READ; ';


set isolation to dirty read;
set lock mode to wait 3;
--set pdqpriority 20;

-- Fecha: 03/04/2013
-- Autor: Faviola M. Juarez
-- Nodificacion: Se modifico la tabla temporal  sd_paso_cred por sd_cred_muestra
-- Separando los querys.
 
BEGIN

	ON EXCEPTION SET sql_err
		IF sql_err <> 0 THEN
			LET cod_ret = sql_err;
			SELECT COUNT(tabid)
			  INTO sPaso
			  FROM systables 
			 WHERE tabname= 'sd_cred_muestra';

			IF NVL(sPaso,0) > 0 THEN
				DROP TABLE sd_cred_muestra;
			END IF;
			
			RETURN cod_ret;
		END IF
	END EXCEPTION;

	LET cod_ret = "000";
   
	--SET DEBUG FILE TO "/informix/David/RQM_10_1674/Muestras/sps/ugenera_layoutedocuenta_muestras.out";
	--TRACE ON;

-----------------OBTENGO LA FECHA DE PROCESO---------------------------------------------------

	SELECT TRIM(valor) INTO v_ruta FROM sd_param WHERE empresa = pempresa AND cod_param = '033';
	SELECT TRIM(valor) INTO v_ruta_cfd FROM sd_param WHERE empresa = pempresa AND cod_param = '037';


	SELECT COUNT(tabid)
		INTO sPaso
	FROM systables 
	WHERE tabname= 'sd_cred_muestra';

	IF NVL(sPaso,0) > 0 THEN
		DROP TABLE "informix".sd_cred_muestra;
	END IF;

    CREATE TABLE "informix".sd_cred_muestra 
    (
		num_credito CHAR(20)
    ) in dbs_cfd_03 EXTENT SIZE 1024 NEXT SIZE 4096 LOCK MODE ROW;
	 
	insert into "informix".sd_cred_muestra  values ('000'); -- Encabezado_edocta  General
    insert into "informix".sd_cred_muestra  values ('100'); -- Encabezado_edocta  General
    insert into "informix".sd_cred_muestra  values ('200'); -- Encabezado edocta Saldos
	insert into "informix".sd_cred_muestra  values ('201'); -- Encabezado Sdos sobre Interes Periodo
    insert into "informix".sd_cred_muestra  values ('300'); -- Detalle
	insert into "informix".sd_cred_muestra  values ('301'); -- Detalle MSI
	insert into "informix".sd_cred_muestra  values ('302'); -- CoppelMax
	insert into "informix".sd_cred_muestra  values ('303'); -- Movimiento de Lineas Adi
	insert into "informix".sd_cred_muestra  values ('304'); -- Lienas adicionales
    insert into "informix".sd_cred_muestra  values ('400'); -- Aclaraciones
    insert into "informix".sd_cred_muestra  values ('500'); -- Mensajes
    insert into "informix".sd_cred_muestra  values ('600'); -- Pie
    insert into "informix".sd_cred_muestra  values ('900'); -- Credisoluciones
		
	insert into "informix".sd_cred_muestra
	select num_credito from sd_muestra_edocta
	where empresa ='001'
	and fecha_corte = pperiodo;
    
                  
	------------------------------------------------------------------------------------------------------------------------
	-- RQI 12 297 Actualizacion de archivos de credito para implementar CFDI 3.3.--
	-- ADLM: Se agregan los campos base_iva, descuento, subtotal y total.
	-----------------ENCABEZADO DOS---------------------------------------------------ARCHIVO 200B
	LET v_sql1 = ' UNLOAD TO '||v_ruta||'descargaB.unl';
	LET v_sql2 = ' SELECT nvl ( fecha_emision,date(1)), '||
			  ' trim( replace ( replace( a.num_credito, ''|'' , '' '' ), ''\'' , '' '' )), '||
			  ' nvl ( capital_tc,0), '||
			  ' nvl ( interes_tc,0), '||
			  ' nvl ( iva_interes_tc,0), '||
			  ' nvl ( capital_ven_tc,0), '||
			  ' nvl ( interes_ven_tc,0), '||
			  ' nvl ( iva_interes_ven_tc,0), '||
			  ' nvl ( moratorios_tc,0), '||
			  ' nvl ( iva_moratorios_tc,0), '||
			  ' nvl ( sdo_pagar,0), '||
			  ' nvl ( interes_pago_total_tc,0), '||
			  ' nvl ( limite_tc,0), '||
			  ' nvl ( sdo_disponible,0), '||
			  ' nvl ( periodo_tc_ini,0), '||
			  ' nvl ( periodo_tc_fin,date(1)), '||
			  ' nvl ( pago_antes_de,date(1)), '||
			  ' nvl ( fecha_corte,date(1)), '||
			  ' nvl ( replace ( replace( dias_periodo_tc, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ), '||
			  ' nvl ( usted_debia,0), '||
			  ' nvl ( menos_abonos,0), '||
			  ' nvl ( mas_compras,0), '||
			  ' nvl ( sus_comisiones,0), '||
			  ' nvl ( mas_disp_efectivo,0), '||
			  ' nvl ( mas_intereses,0), '||
			  ' nvl ( mas_iva,0), '||
			  ' nvl ( mas_rendimientos,0), '||
			  ' nvl ( comisiones_iva,0), '||
			  ' nvl ( intereses_iva,0), '||
			  ' nvl ( intereses_pag,0), '||
			  ' nvl ( saldo_menos_pag,0), '||
			  ' nvl ( compras_disp,0), '||
			  ' nvl ( saldo_diferido,0), '||
			  ' nvl ( saldo_total,0), '||
			  ' nvl ( saldo_corte,0), '||
			  ' nvl ( comisionxcobrar,0.00),' ;
	LET v_sql3=  ' nvl ( base_iva,0.00), '||
			  ' nvl ( descuento,0.00), '|| 
			  ' CAST(nvl ( subtotal,0.0) AS CHAR(18)), '|| 
			  ' CAST(nvl ( total,0.0) AS CHAR(18)), '|| 
			  ' nvl ( pagomin_msi,0.00), '||
			  ' CAST(nvl ( val_base_cfdi,0.0) AS CHAR(18)), '||
			  ' CAST(nvl ( iva_intereses_reales_cfdi,0.0) AS CHAR(18)), '||
			  ' CAST(nvl ( intereses_reales_cfdi,0.0) AS CHAR(18)), '||
			  ' nvl ( mtomensgral_pagosfijos,0.0), '||
			  ' CAST(nvl ( iva_cfdi,0.0) AS CHAR(18)), '||
			  ' nvl( trim(term_pagomin_uno),'''' ), '||
			  ' nvl( trim(pago_int_uno),'''' ), '||
			  ' nvl( trim(pagomin_dos_plazos),'''' ), '||
			  ' nvl( trim(term_pagomin_dos),'''' ), '||
			  ' nvl( trim(pago_int_dos),'''' ), '||
			  ' nvl( trim(pagomin_cinco_plazos),'''' ), '||
			  ' nvl( trim(term_pagomin_cinco),'''' ), '||
			  ' nvl( trim(pago_int_cinco),'''' ), '||
			  ' nvl( iva_inter_comi,0 ), '||
			  ' nvl( sdo_deudor_total,0 ), '||
			  ' nvl( lim_disp_efectivo,0 ), '||
			  ' nvl( lim_disp_transferencia,0 ), '||
			  ' nvl( sdo_cargo_regular,0 ), '||
			  ' nvl( sdo_cargo_meses,0 ), '||
			  ' nvl( inter_comi,0 ), '||
			  ' nvl( intereses_pag_12m,0 ), '||
			  ' nvl( comisiones_pag_12m,0 ), '||
			  ' nvl( anualidad_pag_12m,0 ), '||
			  ' nvl( dist_carg_dif_msi,0 ), '||
			  ' nvl( dist_carg_dif_con_int,0 ) '||
			  ' FROM sd_encabezado2_edocta a '||
			  ' WHERE a.fecha_emision = '''||pperiodo||'''  AND a.num_credito in (select num_credito from "informix".sd_cred_muestra)  " > query200B.sql';

	LET v_sql = v_sql0||v_sql1||v_sql2||v_sql3;

	system v_sql;
	LET v_sql = "dbaccess bdicred query200B.sql";
	system v_sql;

	LET v_sql = '';
	LET v_sql = "sed 's/|$//g' "||v_ruta||'descargaB.unl'||" >"||v_ruta||'descarga1.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "rm "||v_ruta||'descargaB.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "sed 's/\\//g' "||v_ruta||'descarga1.unl'||" > " ||v_ruta||'descarga2.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "rm "||v_ruta||'descarga1.unl';
	SYSTEM v_sql;
	
	LET v_sql = '';
	LET v_sql = "sed 's/" || '"' ||  "//g' "||v_ruta||'descarga2.unl'||" > " ||v_ruta||'Archivo200'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban';
	SYSTEM v_sql;
	
	LET v_sql = '';
	LET v_sql = "rm "||v_ruta||'descarga2.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = " gzip " || v_ruta||'Archivo200'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban ';
	SYSTEM v_sql;
	  	  
	--FIN DE COMPRIMIR Y COPIAR A LA RUTA DE CFD , EN ESTA SECCION VA PARA CADAD UNO DE LOS MENSAJES


	-----------------DETALLE---------------------------------------------------ARCHIVO 300
	LET v_sql1 = ' UNLOAD TO '||v_ruta||'descarga.unl';
	LET v_sql2 = ' SELECT nvl ( fecha_emision,date(1)), '||
			  ' trim(nvl ( replace ( replace( a.num_credito, ''|'' , '' '' ), ''\'' , '' '' ), '' '' )), '||
			  ' nvl ( secuencia,0), '||
			  ' nvl ( nlinea,0), '||
			  ' nvl ( replace ( replace( fecha_mov, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ), '||
			  ' nvl ( replace ( replace( concepto, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ), '||
			  ' replace ( replace ( replace( '' '', ''|'' , '' '' ), ''\'' , '' '' ), '''','' '' ), '||
			  ' replace ( replace ( replace( '' '', ''|'' , '' '' ), ''\'' , '' '' ), '''','' '' ), '||
			  ' nvl ( replace ( replace( monto, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ), '||
			  ' nvl ( replace ( replace( fecha_operacion, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ), '||
			  ' nvl ( replace ( replace( num_tarjeta, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ) '||
			  ' FROM sd_detalle_edocta a '||
			  ' WHERE a.fecha_emision ='''||pperiodo||''' AND a.num_credito in (select num_credito from "informix".sd_cred_muestra) '||
			  ' AND a.tipo_tarjeta = ''T'' ORDER BY a.num_credito,secuencia,nlinea " '||
			  ' > query300.sql';

	LET v_sql = v_sql0 || v_sql1||v_sql2;

	system v_sql;
	LET v_sql = "dbaccess bdicred query300.sql";
	system v_sql;

	LET v_sql = '';
	LET v_sql = "sed 's/|$//g' "||v_ruta||'descarga.unl'||" >"||v_ruta||'descarga1.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "rm "||v_ruta||'descarga.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "sed 's/" || '"' ||  "//g' "||v_ruta||'descarga1.unl'||" > " ||v_ruta||'Archivo300'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "rm "||v_ruta||'descarga1.unl';
	SYSTEM v_sql;

	--COMPRIMIR Y COPIAR A LA RUTA DE CFD 
	LET v_sql = '';
	LET v_sql = " gzip " || v_ruta||'Archivo300'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban ';
	SYSTEM v_sql;

	--FIN DE COMPRIMIR Y COPIAR A LA RUTA DE CFD , EN ESTA SECCION VA PARA CADAD UNO DE LOS MENSAJES


	-----------------ACLARACIONES---------------------------------------------------ARCHIVO 400
	LET v_sql1 = ' UNLOAD TO '||v_ruta||'descarga.unl';
	LET v_sql2 = ' SELECT a.fecha_emision, trim(a.num_credito) num_credito, nvl ( secuencia,0) secuencia, nvl ( nlinea,0) nlinea, '||
				' nvl ( replace ( replace( fecha_aclara, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ), ' ||
				' '' '', '' '','' '', 0.0, '' ''  FROM bdicred:sd_aclaraciones_edocta a '||
				' WHERE a.fecha_emision = '''||pperiodo||''' AND num_credito = ''400'' UNION ALL  '||
				' SELECT nvl ( fecha_emision,date(1)),'||
				' trim(nvl ( replace ( replace( a.num_credito, ''|'' , '' '' ), ''\'' , '' '' ), '' '' )),'||
				' nvl ( secuencia,0),'||
				' nvl ( nlinea,0),'||
				' nvl ( replace ( replace( fecha_aclara, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
				' nvl ( replace ( replace( folio, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
				' nvl ( replace ( replace( fecha_movimiento, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
				' nvl ( replace ( replace( descripcion, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
				' nvl ( importe,0), '||
				' nvl ( replace ( replace ( estatus_aclara, ''|'' , '''' ), ''\'' , '''' ), '' '' ) '||
				' FROM sd_aclaraciones_edocta a '||
			' WHERE a.fecha_emision ='''||pperiodo||''' AND a.num_credito in (select num_credito from "informix".sd_cred_muestra)  ORDER BY num_credito,secuencia,nlinea"'||
			' > query400.sql';

	LET v_sql = v_sql0 || v_sql1||v_sql2;

	system v_sql;
	LET v_sql = "dbaccess bdicred query400.sql";
	system v_sql;

	LET v_sql = '';
	LET v_sql = "sed 's/|$//g' "||v_ruta||'descarga.unl'||" >"||v_ruta||'descarga1.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "rm "||v_ruta||'descarga.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "sed 's/" || '"' ||  "//g' "||v_ruta||'descarga1.unl'||" > "||v_ruta||'descarga2.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "rm "||v_ruta||'descarga1.unl';
	SYSTEM v_sql;
	
	LET v_sql = '';
	LET v_sql = "sed 's/\\//g' "||v_ruta||'descarga2.unl'||" > " ||v_ruta||'Archivo400'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban';
	SYSTEM v_sql;
	
	LET v_sql = '';
	LET v_sql = "rm "||v_ruta||'descarga2.unl';
	SYSTEM v_sql;

	--COMPRIMIR Y COPIAR A LA RUTA DE CFD 
	LET v_sql = '';
	LET v_sql = " gzip " || v_ruta||'Archivo400'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban ';
	SYSTEM v_sql;

	--FIN DE COMPRIMIR Y COPIAR A LA RUTA DE CFD , EN ESTA SECCION VA PARA CADAD UNO DE LOS MENSAJES


	-----------------MENSAJES ARCHIVO 500 BIS -----------ARCHIVO DE MENSAJES ANTERIOR----------------------------------  
	-----------------MENSAJES---------------------------------------------------
    LET v_sql1 = ' UNLOAD TO '||v_ruta||'descarga500B.unl';
    LET v_sql2 = ' SELECT nvl (fecha_emision,date(1)),'||
                 ' trim(nvl ( replace ( replace( num_credito, ''|'' , '' '' ), ''\'' , '' '' ), '' '' )),'||
                 ' nvl ( secuencia,0),'||
                 ' nvl ( nlinea,0),'||
				 ' replace ( replace ( replace( '' '', ''|'' , '' '' ), ''\'' , '' '' ), '''','' '' ), '||
                 ' nvl ( replace ( replace ( trim(mensajes), ''|'' , '''' ), ''\'' , '''' ), '' '' ) '||
                 ' FROM sd_mensajes_edocta WHERE fecha_emision = '''||pperiodo||''' AND num_credito in (select num_credito from "informix".sd_cred_muestra)  ORDER BY 2,3,4"'||
                 ' > query500B.sql';

	LET v_sql = v_sql0||v_sql1||v_sql2;

	system v_sql;
	LET v_sql = "dbaccess bdicred query500B.sql";
	system v_sql;

	LET v_sql = '';
	LET v_sql = "sed 's/|$//g' "||v_ruta||'descarga500B.unl'||" >"||v_ruta||'descarga1.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "rm "||v_ruta||'descarga500B.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "sed 's/" || '"' ||  "//g' "||v_ruta||'descarga1.unl'||" > "||v_ruta||'descarga2.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "rm "||v_ruta||'descarga1.unl';
	SYSTEM v_sql;
	
	LET v_sql = '';
	LET v_sql = "sed 's/\\//g' "||v_ruta||'descarga2.unl'||" > " ||v_ruta||'Archivo500'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban';
	SYSTEM v_sql;
	
	LET v_sql = '';
	LET v_sql = "rm "||v_ruta||'descarga2.unl';
	SYSTEM v_sql;

	--COMPRIMIR Y COPIAR A LA RUTA DE CFD 
	LET v_sql = '';
	LET v_sql = " gzip " || v_ruta||'Archivo500'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban ';
	SYSTEM v_sql;

	--FIN DE COMPRIMIR Y MOVER  A LA RUTA DE CFD , EN ESTA SECCION VA PARA CADAD UNO DE LOS MENSAJES

	  
    -----------------MENSAJES ARCHIVO 800 ---------------------------------------------
	LET v_sql1 = ' UNLOAD TO '||v_ruta||'descarga800.unl';
	LET v_sql2 = ' SELECT '''||pperiodo||''', clave, secuencia, TRIM(inciso) || '') '' || clave || ''. '' || mensaje FROM bdicred:sd_notas_aclara_edc order by clave,secuencia"'||
			  ' > query800.sql';
			  
	LET v_sql = v_sql0||v_sql1||v_sql2;

	system v_sql;
	LET v_sql = "dbaccess bdicred query800.sql";
	system v_sql;

	LET v_sql = '';
	LET v_sql = "sed 's/|$//g' "||v_ruta||'descarga800.unl'||" >"||v_ruta||'descarga1800.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "rm "||v_ruta||'descarga800.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "sed 's/\\//g' "||v_ruta||'descarga1800.unl'||" > "||v_ruta||'Archivo800'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "rm "||v_ruta||'descarga1800.unl';
	SYSTEM v_sql;


	--COMPRIMIR Y COPIAR A LA RUTA DE CFD 
	LET v_sql = '';
	LET v_sql = " gzip " || v_ruta||'Archivo800'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban ';
	SYSTEM v_sql;

	--FIN DE COMPRIMIR Y COPIAR A LA RUTA DE CFD , EN ESTA SECCION VA PARA CADAD UNO DE LOS MENSAJES
	
	
	-----------------MENSAJES DE GLOSARIO ARCHIVO 801 ---------------------------------------------		
	LET v_sql1 = ' echo "SET ISOLATION TO DIRTY READ; ';
	LET v_sql2 = ' UNLOAD TO '||v_ruta||'descarga801B.unl '||
				' SELECT '''||pperiodo||''', '||
				' nvl ( clave,0),'||
				' nvl ( secuencia,0), '||
				' nvl ( replace ( replace ( termino, ''|'' , '''' ), ''\'' , '''' ), '' '' ), '||
				' nvl ( replace ( replace ( significado, ''|'' , '''' ), ''\'' , '''' ), '' '' ) '||
				' FROM sd_glosario_edc ORDER BY clave,secuencia; " > query801.sql';
			
	LET v_sql = v_sql1||v_sql2;
			
	system v_sql;
	LET v_sql = "dbaccess bdicred query801.sql";
	system v_sql;
																																  
	LET v_sql = '';
	LET v_sql = "sed 's/|$//g' "||v_ruta||'descarga801B.unl'||" >"||v_ruta||'descarga801.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "rm "||v_ruta||'descarga801B.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "sed 's/" || '"' ||  "//g' "||v_ruta||'descarga801.unl'||" > "||v_ruta||'Archivo801'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "rm "||v_ruta||'descarga801.unl';
	SYSTEM v_sql;
			
	LET v_sql = '';
	LET v_sql = " gzip " || v_ruta||'Archivo801'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban ';
	SYSTEM v_sql;
	  
	  
	-----------------PIE DE PAGINA---------------------------------------------------ARCHIVO 600
	LET v_sql1 = ' UNLOAD TO '||v_ruta||'descarga.unl';
	LET v_sql2 = ' SELECT nvl (fecha_emision,date(1)),'||
				' trim(nvl ( replace ( replace( a.num_credito, ''|'' , '' '' ), ''\'' , '' '' ), '' '' )),'||
				' nvl ( replace ( replace( tasa_mensual, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
				' nvl ( replace ( replace( round(tasa_anual,1), ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
				' nvl ( replace ( replace( round(cat,1), ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
				' nvl ( replace ( replace( saldo_promedio, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
				' nvl ( tasa_mora,0),'||
				' case when nvl (tasa_mensual_mora,0) - (trim( nvl (tasa_mensual_mora,0)::CHAR(2))::int ) = 0 THEN '||
				' (trim(nvl (tasa_mensual_mora,0)::CHAR(2)))||''.00'' '||
				' else '||
				' (trim(nvl (tasa_mensual_mora,0)::CHAR(2)))||substr(rpad(nvl (tasa_mensual_mora,0) - (trim(nvl (tasa_mensual_mora,0)::CHAR(2))::int ),4,0),2,3) '||
				' end '||
				' FROM sd_pie_edocta a '||
				' WHERE fecha_emision ='''||pperiodo||''' AND a.num_credito in (select num_credito from "informix".sd_cred_muestra)  "' ||
				' > query600.sql';

	LET v_sql = v_sql0||v_sql1||v_sql2;

	system v_sql;
	LET v_sql = "dbaccess bdicred query600.sql";
	system v_sql;

	LET v_sql = '';
	LET v_sql = "sed 's/|$//g' "||v_ruta||'descarga.unl'||" >"||v_ruta||'descarga1.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "rm "||v_ruta||'descarga.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "sed 's/" || '"' ||  "//g' "||v_ruta||'descarga1.unl'||" > " ||v_ruta||'Archivo600'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "rm "||v_ruta||'descarga1.unl';
	SYSTEM v_sql;

	--COMPRIMIR ARCHIVO GENERADO
	LET v_sql = '';
	LET v_sql = " gzip " || v_ruta||'Archivo600'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban ';
	SYSTEM v_sql;

	--- ARCHIVO 100 DE CFDI con la atencion del RQI 12 379 Inclusion de Correo Electronico en Archivos de TDC PIQV

	  
	--------------ENCABEZADO UNO---------------------------------------------------ARCHIVO 100
	LET v_sql1 = ' UNLOAD TO '||trim(v_ruta)||'descargaB.unl';
	LET v_sql2 = ' SELECT a.fecha_emision, a.num_credito, '' '', ''0'',''0'',''0'',''0'',''0'',''0'',''0'',''0'',''0'',''0'',''0'',''0'',''0'',ruta,'' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '' '||
				' FROM bdicred:sd_encabezado_edocta a '||
				' WHERE a.fecha_emision = '''||pperiodo||''' AND a.num_credito IN (''100'', ''000'') UNION ALL  '||
				' SELECT nvl ( fecha_emision,DATE(1)),'||
				' nvl ( replace ( replace( a.num_credito, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
				' nvl ( replace ( replace( num_producto, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
				' nvl ( replace ( replace( numcte, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
				' replace ( replace ( replace( num_tarjeta, ''|'' , '' '' ), ''\'' , '' '' ), '''','' '' ),'||
				' nvl ( replace ( replace( replace( nombre_cte, ''|'' , '' '' ), ''\'' , '' '' ), ''  '' , '' '' ), '' '' ),'||
				' nvl ( replace ( replace( replace ( direccion_cn, ''|'' , '' '' ), ''\'' , '' '' ), ''Â´'', '' ''), '' '' ),'||
				' replace ( replace ( replace( direccion_col, ''|'' , '' '' ), ''\'' , '' '' ), '''','' '' ),'||
				' replace ( replace ( replace( direccion_del, ''|'' , '' '' ), ''\'' , '' '' ), '''','' '' ) || '' '' || '||
				' replace ( replace ( replace( cp, ''|'' , '' '' ), ''\'' , '' '' ), '''','' '' ) || '' '' || '||
				' replace ( replace ( replace( edo_cd, ''|'' , '' '' ), ''\'' , '' '' ), '''','' '' ), ';
	LET v_sql3 =  ' replace ( replace ( replace( '' '', ''|'' , '' '' ), ''\'' , '' '' ), '''','' '' ),'||
				' nvl ( replace ( replace( replace ( cl_cobra, ''|'' , '' '' ), ''\'' , '' '' ) , ''Â´'', '' ''), '' '' ),'||
				' nvl ( replace ( replace( sucursal_nombre, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
				' replace ( replace ( replace( '' '', ''|'' , '' '' ), ''\'' , '' '' ), '''','' '' ),'||
				' nvl ( replace ( replace( rfc, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
				' replace ( replace ( replace( '' '', ''|'' , '' '' ), ''\'' , '' '' ), '''','' '' ),'||
				' nvl ( replace ( replace( cp, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
				' replace ( replace ( replace ( replace( ruta, ''|'' , '' '' ), ''\'' , '' '' ), '''','' '' ), ''Â´'', '' ''),'||
				' replace ( replace ( replace( '' '', ''|'' , '' '' ), ''\'' , '' '' ), '''','' '' ),'||
				' replace ( replace ( replace( trim( observaciones), ''|'' , '' '' ), ''\'' , '' '' ), '''','' '' ),'||
				' nvl ( replace ( replace( insertos, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),';
	LET v_sql4 =  ' nvl ( replace ( replace( sucursal, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
				' nvl ((SELECT TRIM(NVL(b.correo_elec,'' '')) FROM bdinteg:si_correos b WHERE b.numcte = a.numcte '||
				' AND b.secuencia IN (select max(d.secuencia) FROM bdinteg:si_correos d  WHERE d.numcte = a.numcte AND d.tipo_correo = b.tipo_correo '||
				' AND d.status_correo = b.status_correo AND d.valido = b.valido) AND b.tipo_correo = 1 AND b.status_correo = ''A'' AND b.valido = ''1'' '||
				' and b.numcte not in (select c.numcte from bdinteg:"informix".si_altaserv_edoctamov c where c.empresa = ''001'' and c.numcte = b.numcte)),'' ''),'||
				' nvl ( replace ( replace( confirmacion, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
				' nvl((SELECT TRIM(NVL(b.cuenta_clabe,'' '')) FROM bdicred:sd_maecred b where b.num_credito = a.num_credito), '' ''),'||
				' nvl ( replace ( replace( num_ciudad_coppel, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
				' nvl ( replace ( replace( num_region, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
				' nvl ( replace ( replace( ec_edocta, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
				' nvl ((SELECT TRIM(valor) FROM sd_param WHERE empresa = ''' || pempresa || ''' AND cod_param = ''135''), '' ''),'||
				' nvl ((SELECT TRIM(valor) FROM sd_param WHERE empresa = ''' || pempresa || ''' AND cod_param = ''136''), '' ''),'||
				' nvl ( replace ( replace( obj_imp, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
				' nvl ( replace ( replace( base_cfdi, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ) ';
	LET v_sql5=  ' FROM sd_encabezado_edocta a '||
				' WHERE a.fecha_emision = '''||TO_CHAR(pperiodo,'%m/%d/%Y')||''' AND a.num_credito  in (select num_credito from "informix".sd_cred_muestra) order by ruta " > query100B.sql';

	LET v_sql = v_sql0||v_sql1||v_sql2||v_sql3||v_sql4||v_sql5;
	system v_sql;

	LET v_sql = "dbaccess bdicred query100B.sql";
	system v_sql;

	LET v_sql = '';
	LET v_sql = "sed 's/|$//g' "||v_ruta||'descargaB.unl'||" >"||v_ruta||'descarga1B.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "sed 's/Â´/ /g' "||v_ruta||'descarga1B.unl'||" >"||v_ruta||'descarga2B.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = 'sed "s/''/ /g" '||v_ruta||'descarga2B.unl'||" >"||v_ruta||'descarga1B.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "sed 's/&/ /g' "||v_ruta||'descarga1B.unl'||" >"||v_ruta||'descarga2B.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "sed 's/Â¨/ /g' "||v_ruta||'descarga2B.unl'||" >"||v_ruta||'descarga1B.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "sed 's/>/ /g' "||v_ruta||'descarga1B.unl'||" >"||v_ruta||'descarga2B.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "sed 's/</ /g' "||v_ruta||'descarga2B.unl'||" >"||v_ruta||'descarga1B.unl';
	SYSTEM v_sql;
	  
	LET v_sql = '';
	LET v_sql = 'echo " cd '|| '\"'||v_ruta||'\"'||'" > eliminaespeciales.sh ' ;
	SYSTEM v_sql;
	  
	LET v_sql = '';
	LET v_sql = "chmod 777 "||'eliminaespeciales.sh ';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = ' echo '||'"'||' sed  -e ''s/''\$(echo ['||'\"'||'\\\001\\\002\\\003\\\004\\\005\\\006\\\007\\\010\\\016\\\017\\\020\\\021'||		                     
							 '\\\022\\\023\\\024\\\025\\\026\\\027\\\030\\\031\\\032\\\033\\\034\\\035\\\036\\\037'||
						  '\"'||'])''//g'' '||v_ruta||'descarga1B.unl'||" > "||v_ruta||'descarga2B.unl'||
						  '" >>'||'eliminaespeciales.sh ';
	SYSTEM v_sql;
	  
	  
	LET v_sql = '';
	LET v_sql = "./"||'eliminaespeciales.sh ';
	SYSTEM v_sql;
	  
	let v_sql = '';
	LET v_sql = "rm "||v_ruta||'descargaB.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "sed 's/" || '"' ||  "//g' "||v_ruta||'descarga2B.unl'||" > " || trim(v_ruta||'Archivo100'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban');
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "rm "||v_ruta||'descarga1B.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "rm "||v_ruta||'descarga2B.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = " gzip " || v_ruta||'Archivo100'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban ';
	SYSTEM v_sql;
	
	LET v_sql = '';
	LET v_sql = "rm "||'eliminaespeciales.sh ';
	SYSTEM v_sql;
	  
	--- ARCHIVO 100 DE CFDI con la atencion del RQI 12 379 Inclusion de Correo Electronico en Archivos de TDC PIQV

	--FIN DE COMPRIMIR Y COPIAR A LA RUTA DE CFD , EN ESTA SECCION VA PARA CADAD UNO DE LOS MENSAJES

    LET v_sql3= "";
    
    
	--------------------- ARCHIVO 900 CREDISOLUCIONES --------------------
	LET v_sql1 = ' UNLOAD TO '||v_ruta||'descarga.unl';				
	LET v_sql4 = ' SELECT nvl ( fecha_emision,date(1)),'||
				 ' trim(a.num_credito) num_credito,'||
				 ' nvl (secuencia,0),'||
				 ' nvl (nlinea,0),'||
				 ' nvl (prox_fecha_pago,date(1)),'||
				 ' concepto,'||
				 ' nvl (tasa,0),'||
				 ' nvl (saldo_pendiente,0),'||
				 ' replace (replace(numero_cuotas,''.0'',''''),''/'','''')::integer ' ||'||''/''||'||'"plazo",'||
				 ' nvl (monto_prox_pago,0),'||
				 ' nvl (fecha_oper,date(1)),'||
				 ' nvl (monto_ori,0),'||
				 ' nvl (int_periodo,0),'||
				 ' nvl (iva_int_periodo,0),'||
				 ' '' '','||
				 ' tipo_tarjeta '||
				 ' FROM sd_detalle_dif_edocta a'||
				 ' WHERE a.fecha_emision = '''||pperiodo||''' AND a.num_credito = ''900'' '||
				 'UNION ALL';
	LET v_sql2 = ' SELECT nvl ( fecha_emision,date(1)),'||
				 ' trim(nvl ( replace ( replace( a.num_credito, ''|'' , '' '' ), ''\'' , '' '' ), '' '' )),'||
				 ' nvl (secuencia,0),'||
				 ' nvl (nlinea,0),'||
				 ' nvl (prox_fecha_pago,date(1)),'||
				 ' concepto,'||
				 ' nvl (tasa,0),'||
				 ' nvl (saldo_pendiente,0),'||
				 --' replace (replace(numero_cuotas,''.0'',''''),''/'','''')::integer + 1  ' ||'||''/''||'||'"plazo",'||
				 ' replace (replace(numero_cuotas,''.0'',''''),''/'','''')::integer  ' ||'||''/''||'||'"plazo",'||
				 ' nvl (monto_prox_pago,0),'||
				 ' nvl (fecha_oper,date(1)),'||
				 ' nvl (monto_ori,0),'||
				 ' nvl (int_periodo,0),'||
				 ' nvl (iva_int_periodo,0),'||
				 ' replace ( replace ( replace( trim(a.num_tar_ori), ''|'' , '' '' ), ''\'' , '' '' ), '''','' '' ), '||
				 ' replace ( replace ( replace( a.tipo_tarjeta, ''|'' , '' '' ), ''\'' , '' '' ), '''','' '' )'||
				 ' FROM sd_detalle_dif_edocta a';
	LET v_sql3 = ' WHERE a.fecha_emision = '''||pperiodo||''' AND a.num_credito in (select num_credito from "informix".sd_cred_muestra) " > query900.sql';
		                                                                                   
	LET v_sql = v_sql0||v_sql1||v_sql2||v_sql3;

	system v_sql;
	LET v_sql = "dbaccess bdicred query900.sql";
	system v_sql;
		 
	LET v_sql = '';
	LET v_sql = "sed 's/|$//g' "||v_ruta||'descarga.unl'||" >"||v_ruta||'descarga1.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "rm "||v_ruta||'descarga.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "sed 's/" || '"' ||  "//g' "||v_ruta||'descarga1.unl'||" > " ||v_ruta||'Archivo900'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = " gzip " || v_ruta||'Archivo900'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban ';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "rm "||v_ruta||'descarga1.unl'; 
	SYSTEM v_sql;
	
	
	--------------------------------ARCHIVO 201 Sdos sobre Interes Periodo------------------------------   
	LET v_sql1 = ' UNLOAD TO '|| v_ruta ||'descargSdosInterPer.unl' ;
	LET v_sql2 = ' SELECT fecha_emision, trim(num_credito) num_credito, 0 secuencia, '' '', '' '', '' '', '' '', '' '', '' '' '||  
				 ' FROM bdicred:sd_sdo_int_periodo_edc'||
				 ' WHERE fecha_emision = '''||pperiodo||''' AND num_credito = ''201'' UNION ALL  '||    
				 ' SELECT nvl (fecha_emision,date(1)), ' ||
				 ' trim(nvl ( replace ( replace( num_credito, ''|'' , '' '' ), ''\'' , '' '' ), '' '' )), '||
				 ' nvl ( secuencia,0),'||
				 ' trim(nvl ( replace ( replace( descripcion, ''|'' , '' '' ), ''\'' , '' '' ), '' '' )), '||
				 ' nvl ( replace ( replace( sdo_base, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ), '||
				 ' nvl ( replace ( replace( dias_periodo, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ), '||
				 ' nvl ( replace ( replace( tasa_inter_aplicable, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ), '||
				 ' nvl ( replace ( replace( monto_interes, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ), '||
				 ' nvl ( replace ( replace( tipo_proceso, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ) '||
				 ' FROM bdicred:sd_sdo_int_periodo_edc '||
				 ' WHERE fecha_emision = '''||pperiodo||''' AND num_credito in (select num_credito from "informix".sd_cred_muestra) ORDER BY num_credito,secuencia " > query201.sql' ;

	LET v_sql = v_sql0||v_sql1||v_sql2 ;

	system v_sql;
	LET v_sql = "dbaccess bdicred query201.sql";
	system v_sql;

	LET v_sql = '';
	LET v_sql = "sed 's/|$//g' "||v_ruta||'descargSdosInterPer.unl'||" >"||v_ruta||'descarga1.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "rm "||v_ruta||'descargSdosInterPer.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "sed 's/" || '"' ||  "//g' "||v_ruta||'descarga1.unl'||" > " ||v_ruta||'Archivo201'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "rm "||v_ruta||'descarga1.unl';
	SYSTEM v_sql;

	  --COMPRIMIR ARCHIVO GENERADO
	LET v_sql = '';
	LET v_sql = " gzip " || v_ruta||'Archivo201'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban ';
	SYSTEM v_sql;
	
	
	--------------------- ARCHIVO 301 MESES SIN INTERESES --------------------
	LET v_sql1 = ' UNLOAD TO '||v_ruta||'descargaMSI.unl';
	LET v_sql4 = ' SELECT nvl ( a.fecha_emision,date(1)), '||
				 ' trim(a.num_credito) num_credito, '||
				 --' LPAD(DAY(fecha_compra),2,''0'') || ''/'' || LPAD(MONTH(fecha_compra),2,''0'') || ''/'' || YEAR(fecha_compra), '||
				 ' nvl (fecha_compra,date(1)),'||
				 ' nvl ( replace ( replace ( a.comercio, ''|'' , '''' ), ''\'' , '''' ), '' '' ), '||
				 ' replace (replace(a.plazo,''.0'',''''),''/'','''')::integer ' ||'||''/''||'||'"numero_cuotas",'||
				 ' nvl (a.saldo_total_compra,0.0), '||
				 ' nvl (a.msipagomin,0.0), '||
				 ' nvl (a.saldo_total_deudor,0.0), '||
				 ' trim(a.tasa_int_aplicable), '||
				 ' nvl ( replace ( replace ( a.num_tarjeta, ''|'' , '''' ), ''\'' , '''' ), '''' ), '||
				 ' a.tipo_tarjeta '||
				 ' FROM sd_detalle_msi_edocta a '||
				 ' WHERE a.fecha_emision = '''||pperiodo||''' AND a.num_credito = ''301'' '||
				 'UNION ALL';
	LET v_sql2 = ' SELECT nvl ( a.fecha_emision,date(1)), '||
				 ' trim(nvl ( replace ( replace( a.num_credito, ''|'' , '' '' ), ''\'' , '' '' ), '' '' )), '||
				 --' LPAD(DAY(fecha_compra),2,''0'') || ''/'' || LPAD(MONTH(fecha_compra),2,''0'') || ''/'' || YEAR(fecha_compra), '||
				 ' nvl (fecha_compra,date(1)),'||
				 ' replace ( replace ( replace( trim(a.num_sol_prestamo), ''|'' , '' '' ), ''\'' , '' '' ), '''','' '' ) || '' '' || '||
				 ' replace ( replace ( replace( trim(a.comercio), ''|'' , '' '' ), ''\'' , '' '' ), '''','' '' ) || '' '' || '||
				 ' replace ( replace ( replace( trim(a.descripcion), ''|'' , '' '' ), ''\'' , '' '' ), '''','' '' ), '||
				 --' replace (replace(a.plazo,''.0'',''''),''/'','''')::integer  ' ||'||''/''||'||' replace (replace(numero_cuotas,''.00'',''''),''/'','''')::integer,'||
				 ' replace (replace(numero_cuotas,''.00'',''''),''/'','''')::integer  ' ||'||''/''||'||' replace (replace(a.plazo,''.0'',''''),''/'','''')::integer,'||
				 ' nvl (a.saldo_total_compra,0.0), '||
				 ' nvl (a.msipagomin,0.0), '||
				 ' nvl (a.saldo_total_deudor,0.0), '||
				 ' trim(a.tasa_int_aplicable), '||
				 ' replace ( replace ( replace( trim(a.num_tarjeta), ''|'' , '' '' ), ''\'' , '' '' ), '''','' '' ), '||
				 ' nvl ( replace ( replace( trim(a.tipo_tarjeta), ''|'' , '' '' ), ''\'' , '' '' ), '' '' )'||
				 ' FROM sd_detalle_msi_edocta a';
	LET v_sql3 = ' WHERE a.fecha_emision = '''||pperiodo||''' AND status in(''2'',''6'') AND a.num_credito in (select num_credito from "informix".sd_cred_muestra) " > query301.sql';

	LET v_sql = TRIM(v_sql0)||" "||TRIM(v_sql1)||" "||TRIM(v_sql4)||" "||TRIM(v_sql2)||" "||TRIM(v_sql3);

	system v_sql;
	LET v_sql = "dbaccess bdicred query301.sql";
	system v_sql;
			 
	LET v_sql = '';
	LET v_sql = "sed 's/|$//g' "||v_ruta||'descargaMSI.unl'||" >"||v_ruta||'descargaMSI1.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "rm "||v_ruta||'descargaMSI.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "sed 's/" || '"' ||  "//g' "||v_ruta||'descargaMSI1.unl'||" > " ||v_ruta||'descargaMSI2.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "rm "||v_ruta||'descargaMSI1.unl';
	SYSTEM v_sql;
	
	LET v_sql = '';
	LET v_sql = "sed 's/\\//g' "||v_ruta||'descargaMSI2.unl'||" > " ||v_ruta||'Archivo301'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban';
	SYSTEM v_sql;
	
	LET v_sql = '';
	LET v_sql = "rm "||v_ruta||'descargaMSI2.unl';
	SYSTEM v_sql;

	--COMPRIMIR Y COPIAR A LA RUTA DE CFD 
	LET v_sql = '';
	LET v_sql = " gzip " || v_ruta||'Archivo301'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban ';
	SYSTEM v_sql;
	
	
	------------- ARCHIVO 302 coppel max --------------------            
	LET v_sql1 = ' UNLOAD TO '|| v_ruta ||'descargaCmax.unl' ;
	LET v_sql2 = ' SELECT fecha_emision, trim(num_credito), nvl (sdo_inicio_elect,0),nvl (dro_elect_utilizado,0),nvl (dro_elect_vencido,0),nvl (dro_elect_obt,0), '||
				 ' nvl(dro_elect_x_venc,0),nvl(sdo_fin_dro_elect,0),nvl(equivale_pesos,0) '|| 
				 ' FROM bdicred:sd_coppelmax_edc '||
				 ' WHERE fecha_emision = '''||pperiodo||''' AND num_credito = ''302'' UNION ALL  '||    
				 ' SELECT nvl (fecha_emision,date(1)),  ' ||
				 ' trim(nvl ( replace ( replace( num_credito, ''|'' , '' '' ), ''\'' , '' '' ), '' '' )),'||
				 ' nvl ( sdo_inicio_elect,0), ' || 
				 ' nvl ( dro_elect_utilizado,0), ' ||  
				 ' nvl ( dro_elect_vencido,0), ' || 
				 ' nvl ( dro_elect_obt,0), ' || 
				 ' nvl ( dro_elect_x_venc,0), ' || 
				 ' nvl ( sdo_fin_dro_elect,0), ' ||
				 ' nvl ( equivale_pesos,0) ' || 
				 ' FROM bdicred:sd_coppelmax_edc '||
				 --' WHERE fecha_emision = '''||pperiodo||''' AND num_credito in (select num_credito from "informix".sd_cred_muestra) " > query302.sql' ;
				 ' WHERE fecha_emision = '''||pperiodo||''' AND num_credito = ''302'' " > query302.sql' ;
											   
	LET v_sql = v_sql0||v_sql1||v_sql2 ;

	system v_sql;
	LET v_sql = "dbaccess bdicred query302.sql";
	system v_sql;

	LET v_sql = '';
	LET v_sql = "sed 's/|$//g' "||v_ruta||'descargaCmax.unl'||" >"||v_ruta||'descarga1.unl';																															  
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "rm "||v_ruta||'descargaCmax.unl';																															 																															   																															 
	SYSTEM v_sql;

	LET v_sql = '';																																	 
	LET v_sql = "sed 's/" || '"' ||  "//g' "||v_ruta||'descarga1.unl'||" > " ||v_ruta||'Archivo302'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "rm "||v_ruta||'descarga1.unl';
																																
	SYSTEM v_sql;

	  --COMPRIMIR ARCHIVO GENERADO
	LET v_sql = '';
	LET v_sql = " gzip " || v_ruta||'Archivo302'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban ';
	SYSTEM v_sql;
		
	---------------- 303 DETALLE DE MOVIMIENTO DE LAS TARJETAS ADICIONALES------------------------------------------------------------------- 
	LET v_sql1 = ' UNLOAD TO '||v_ruta||'descargaDetMovAdi.unl';
	LET v_sql2 = ' SELECT a.fecha_emision, trim(num_credito) num_credito, nvl ( secuencia,0)secuencia ,nvl ( nlinea,0) nlinea, ''0'', ''0'', ''0'', ''0'', ''0'' FROM bdicred:sd_detalle_edocta a '||
			  ' WHERE a.fecha_emision = '''||pperiodo||''' AND num_credito = ''303'' UNION ALL  '||                        
			  ' SELECT nvl ( fecha_emision,DATE(1)),'||
			  ' trim(nvl ( replace ( replace( a.num_credito, ''|'' , '' '' ), ''\'' , '' '' ), '' '' )),'||
			  ' nvl ( secuencia,0),'||
			  ' nvl ( nlinea,0),'||
			  ' nvl ( replace ( replace( fecha_mov, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ), '||
			  ' nvl ( replace ( replace( concepto, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ), '||
			  ' nvl ( replace ( replace( monto, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
			  ' nvl ( replace ( replace( fecha_operacion, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ), '||
			  ' nvl ( replace ( replace( num_tarjeta, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ) '||
			  ' FROM sd_detalle_edocta a '||
			  ' WHERE a.fecha_emision ='''||pperiodo||''' AND a.num_credito in (select num_credito from "informix".sd_cred_muestra) '||  
			  ' AND a.tipo_tarjeta = ''A'' ORDER BY num_credito,secuencia,nlinea" '||
			  ' > query303.sql';
						
	LET v_sql = v_sql0||v_sql1||v_sql2;

	system v_sql;
	LET v_sql = "dbaccess bdicred query303.sql";
	system v_sql;

	LET v_sql = '';
	LET v_sql = "sed 's/|$//g' "||v_ruta||'descargaDetMovAdi.unl'||" >"||v_ruta||'descarga1.unl';
						  
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "rm "||v_ruta||'descargaDetMovAdi.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "sed 's/" || '"' ||  "//g' "||v_ruta||'descarga1.unl'||" > " ||v_ruta||'Archivo303'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "rm "||v_ruta||'descarga1.unl';
	SYSTEM v_sql;

	--COMPRIMIR Y COPIAR A LA RUTA DE CFD
	LET v_sql = '';
	LET v_sql = " gzip " || v_ruta ||'Archivo303'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban ';
	SYSTEM v_sql;
		
	------------- ARCHIVO 304 lineas adicionales -------------------- 
	LET v_sql1 = ' UNLOAD TO '|| v_ruta ||'descargLineasAdic.unl' ;
	LET v_sql2 = ' SELECT fecha_emision, trim(num_credito), nvl (fecha_oper_adi,DATE(1)),'' '',nvl (monto_orig_adi,0),nvl (saldo_pend_adi,0), '||
				 ' nvl (intereses_peri_adi,0),nvl (iva_peri_adi,0), nvl (pago_requ_adi,0), nvl (numero_pago_adi,0), nvl (tasa_apli_adi,0), nvl (credito_adic_adi,0), nvl (fecha_adic_adi,DATE(1)) '|| 
				 ' FROM bdicred:sd_lineas_adicionales_edc '||
				 ' WHERE fecha_emision = '''||pperiodo||''' AND num_credito = ''304'' UNION ALL '||    
				 ' SELECT nvl (fecha_emision,date(1)),  '||
				 ' trim(nvl ( replace ( replace( num_credito, ''|'' , '' '' ), ''\'' , '' '' ), '' '' )), '||
				 ' nvl ( fecha_oper_adi,DATE(1)), '|| 
				 ' trim(nvl ( replace ( replace( descripcion_Desc_adi, ''|'' , '' '' ), ''\'' , '' '' ), '' '' )), '||
				 ' nvl ( monto_orig_adi,0), '||  
				 ' nvl ( saldo_pend_adi,0), '|| 
				 ' nvl ( intereses_peri_adi,0), '||
				 ' nvl ( iva_peri_adi,0), '|| 
				 ' nvl ( pago_requ_adi,0), '||  
				 ' nvl ( numero_pago_adi,0), '||
				 ' nvl ( tasa_apli_adi,0), '||
				 ' nvl (credito_adic_adi,0), '||
				 ' nvl (fecha_adic_adi,DATE(1)) '||
				 ' FROM bdicred:sd_lineas_adicionales_edc '||
				 ' WHERE fecha_emision = '''||pperiodo||''' AND num_credito in (select num_credito from "informix".sd_cred_muestra) " > query304.sql' ;

	LET v_sql = v_sql0||v_sql1||v_sql2 ;								 

	system v_sql;
	LET v_sql = "dbaccess bdicred query304.sql";
	system v_sql;

	LET v_sql = '';
	LET v_sql = "sed 's/|$//g' "||v_ruta||'descargLineasAdic.unl'||" >"||v_ruta||'descarga1.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "rm "||v_ruta||'descargLineasAdic.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "sed 's/" || '"' ||  "//g' "||v_ruta||'descarga1.unl'||" > " ||v_ruta||'descarga2.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "rm "||v_ruta||'descarga1.unl';
	SYSTEM v_sql;
	
	LET v_sql = '';
	LET v_sql = "sed 's/\\//g' "||v_ruta||'descarga2.unl'||" > " ||v_ruta||'Archivo304'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban';
	SYSTEM v_sql;
	
	LET v_sql = '';
	LET v_sql = "rm "||v_ruta||'descarga2.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = " gzip " || v_ruta ||'Archivo304'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban ';
	SYSTEM v_sql;
	
	
	----- ARCHIVO 802 Mensajes Gnerales_MA_AQ --------------------
	LET v_sql1 = ' UNLOAD TO '|| v_ruta ||'descargaGneralMA_QA.unl ';
	LET v_sql2 = ' SELECT nvl (fecha_emision,date(1)), ' ||
				 ' nvl ( secuencia,0), ' || 
				 ' nvl ( nlinea,0), ' || 
				 ' nvl ( mensaje,'' ''), ' || 
				 ' trim(nvl ( replace ( replace( tipo_mens, ''|'' , '' '' ), ''\'' , '' '' ), '' '' )) '||
				 ' FROM bdicred:sd_mensajes_mensual_edocta '||
				 ' WHERE fecha_emision = '''||pperiodo||''' " > query802.sql' ;

	LET v_sql = v_sql0||v_sql1||v_sql2 ;

	system v_sql;
	LET v_sql = "dbaccess bdicred query802.sql";
	system v_sql;

	LET v_sql = '';
	LET v_sql = "sed 's/|$//g' "||v_ruta||'descargaGneralMA_QA.unl'||" >"||v_ruta||'descarga1.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "rm "||v_ruta||'descargaGneralMA_QA.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "sed 's/" || '"' ||  "//g' "||v_ruta||'descarga1.unl'||" > " ||v_ruta||'Archivo802'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "rm "||v_ruta||'descarga1.unl';
	SYSTEM v_sql;

	--COMPRIMIR ARCHIVO GENERADO
	LET v_sql = '';
	LET v_sql = " gzip " || v_ruta||'Archivo802'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban ';
	SYSTEM v_sql;

    
	---------  MOVER ARCHIVOS CREADOS A LA DE CFD ------------------- SOLO VAMOS UTULIZAR EN LA RUTA 
	LET v_sql = '';
	LET v_sql = "mv " || v_ruta|| 'Archivo100'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.gz '||
					   trim(v_ruta_cfd) ||'Archivo100'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.gz ';
	SYSTEM v_sql;

	LET v_sql = ''; 
	LET v_sql = "mv " || v_ruta|| 'Archivo200'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.gz '||
					   trim(v_ruta_cfd) ||'Archivo200'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.gz ';
	SYSTEM v_sql; 

	LET v_sql = '';
	LET v_sql = "mv " || v_ruta|| 'Archivo201'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.gz '||
					   trim(v_ruta_cfd) ||'Archivo201'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.gz ';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "mv " || v_ruta|| 'Archivo300'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.gz '||
					   trim(v_ruta_cfd) ||'Archivo300'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.gz ';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = " mv " || v_ruta|| 'Archivo301'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.gz '||
					   trim(v_ruta_cfd) ||'Archivo301'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.gz ';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "mv " || v_ruta|| 'Archivo302'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.gz '||
					   trim(v_ruta_cfd) ||'Archivo302'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.gz ';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "mv " || v_ruta|| 'Archivo303'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.gz '||
					   trim(v_ruta_cfd) ||'Archivo303'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.gz ';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "mv " || v_ruta|| 'Archivo304'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.gz '||
					   trim(v_ruta_cfd) ||'Archivo304'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.gz ';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "mv " || v_ruta|| 'Archivo400'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.gz '||
					   trim(v_ruta_cfd) ||'Archivo400'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.gz ';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "mv " || v_ruta|| 'Archivo500'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.gz '||
					   trim(v_ruta_cfd) ||'Archivo500'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.gz ';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "mv " || v_ruta|| 'Archivo600'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.gz '||
					   trim(v_ruta_cfd) ||'Archivo600'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.gz ';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "mv " || v_ruta|| 'Archivo800'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.gz '||
					   trim(v_ruta_cfd) ||'Archivo800'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.gz ';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "mv " || v_ruta|| 'Archivo801'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.gz '||
					   trim(v_ruta_cfd) ||'Archivo801'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.gz ';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "mv " || v_ruta|| 'Archivo802'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.gz '||
					   trim(v_ruta_cfd) ||'Archivo802'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.gz ';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "mv " || v_ruta|| 'Archivo900'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.gz '||
					   trim(v_ruta_cfd) ||'Archivo900'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.gz ';
	SYSTEM v_sql;
		

	  
	-----FIN DE COPIAR A LA RUTA DE CFD.
	LET v_sql = '';
	LET v_sql = 'rm query100B.sql ';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = 'rm query201.sql ';
	SYSTEM v_sql;

	LET v_sql = ''; 
	LET v_sql = 'rm query200B.sql '; 
	SYSTEM v_sql; 

	LET v_sql = '';
	LET v_sql = 'rm query300.sql ';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = 'rm query301.sql ';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = 'rm query302.sql ';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = 'rm query303.sql ';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = 'rm query304.sql ';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = 'rm query400.sql ';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = 'rm query500B.sql ';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = 'rm query600.sql ';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = 'rm query800.sql ';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = 'rm query801.sql ';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = 'rm query802.sql ';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = 'rm query900.sql ';
	SYSTEM v_sql;

  END;
  RETURN cod_ret;

END PROCEDURE;
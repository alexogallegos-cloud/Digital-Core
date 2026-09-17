CREATE PROCEDURE "informix".sp_mc_obteninfosolicitudgen(pEmpresa CHAR(3),pNumSol CHAR(20))
RETURNING 
	CHAR(6)  AS codigo_retorno,
	CHAR(80) AS mensaje_retorno,
	CHAR(20) AS Numcte  ,        
	CHAR(104) AS NombreCte,      
	CHAR(13) AS Rfc  ,           
	CHAR(4) AS Sucursal  , 
	CHAR(20) AS NumCteCop  ,      
	DECIMAL(18,2) AS LineaCoppel     , 
	DECIMAL(18,2) AS  EficienciaPago  , 
	SMALLINT AS MesesHist,
	CHAR(2) AS Puntualidad,
	DECIMAL(18,2) AS VencidoUdis,
	CHAR(1) AS Situacion_credito,
	SMALLINT AS Causa,
	CHAR(40) AS DescSitEsp,
	CHAR(20) AS NumSolicitud,
	DATE AS FechaSol,
	DATE AS FechaCambioStatus,
	DECIMAL(18,2) AS BCScore ,
	DECIMAL(18,2) AS ScoreProp,
	DECIMAL(18,2) AS ResultadoTotal,
	CHAR(2) AS StatusSol,
	CHAR(3) AS CausaStatusSol,
	CHAR(100) AS ComportamientoSic,
	DATE AS FechaSolOs,
	CHAR(1) AS StatusOS,
	CHAR(1) AS SitEspOS,
	SMALLINT AS CausaSitEspOS,
	CHAR(100) AS DescSitEspOS,
	CHAR(100) AS DescMotivoOS,
	DATE AS FechaOstel,
	CHAR(1) AS RespuestaOstel,
	CHAR(2) AS Atendio,
	DECIMAL(18,2) AS IngresoMensual,
	DECIMAL(18,2) AS IngresoLC,	
	DECIMAL(18,2) AS CompromisosBanco,
	DECIMAL(18,2) AS CompromisosSIC,
	DECIMAL(18,2) AS CompromisosCoppel,
	DECIMAL(18,2) AS CMA,
	DECIMAL(18,2) AS TAB,
	DECIMAL(18,2) AS LineaTeorica,
	DECIMAL(18,2) AS MontoSol,
	DECIMAL(18,2) AS MontoMaxSol,
	CHAR(4) AS NumProd1  , 
	CHAR(40) AS DescNumProd1,
	CHAR(4) AS NumProd2  , 
	CHAR(40) AS DescNumProd2,
	INTEGER AS CMA_cop,
	INTEGER AS TAB_cop,
	INTEGER AS CRA_cop,	
	INTEGER AS MontoSolCop,
	INTEGER AS LineaTeoricaCop,	
	INTEGER AS Puntos_parcn,
	INTEGER AS Par_altoriesgo,	
	INTEGER AS Par_celulares,
	INTEGER AS Par_prestamos,
	CHAR(1) AS EnvioCop,
	CHAR(20) AS NumSolicitudRef,
	CHAR(2) AS StatusSol2,
	CHAR(3) AS CausaStatusSol2,
	DATE AS FechaCambioStatus2,
	CHAR(1) AS Permite_cambio,
	DECIMAL(18,2) AS MontoAut,
	DECIMAL(18,2) AS Limitecreditopesos,
	CHAR(100) AS ComportamientoCop,
	CHAR(3) AS Causa_solicitud,
	CHAR(3) AS Causa_solicitud2,
    CHAR(1) AS Genero;
    
	
	
---DECLARACIONES
DEFINE cCodRet          CHAR(6); 
DEFINE cCodRet2          CHAR(6); 
DEFINE cMensajeRet      CHAR(80);

DEFINE iSqlErr      	INTEGER;
DEFINE iIsamErr         INTEGER;
DEFINE cErrorInfo       CHAR(80);

DEFINE cNumcte          CHAR(20);
DEFINE cNombreCte       CHAR(104);
DEFINE cRfc             CHAR(13);
DEFINE cSucursal        CHAR(4);

DEFINE cNumCteCop        CHAR(20);
DEFINE dLineaCoppel      DECIMAL(18,2);
DEFINE cEficienciaPago   DECIMAL(18,2);
DEFINE cMesesHist        SMALLINT;
DEFINE cPuntualidad      CHAR(2);
DEFINE cVencidoUdis      DECIMAL(18,2);
DEFINE cSituacion_credito CHAR(1);
DEFINE cCausa			 SMALLINT;
DEFINE cDescSitEsp       CHAR(40);

DEFINE cNumSolicitud    CHAR(20);
DEFINE cNum_solicitud_ref    CHAR(20);
DEFINE cNumSol2    		CHAR(20);
DEFINE cTpSol    		CHAR(1);
DEFINE cNumProd    		CHAR(4);
DEFINE cNumProd2        CHAR(4);
DEFINE cDescNumProd     CHAR(40);
DEFINE cDescNumProd2    CHAR(40);
DEFINE dtFechaSol       DATE;
DEFINE dtFechaCambioStatus  DATE;
DEFINE dtFechaCambioStatus2  DATE;
DEFINE dtFechaCambioStatusAux DATE;
DEFINE cEnvioCop 		CHAR(1);

DEFINE dBCScore        DECIMAL(18,2);
DEFINE dScoreProp      DECIMAL(18,2);
DEFINE dResultadoTotal DECIMAL(18,2);
DEFINE iCantidad SMALLINT;
DEFINE cStatusSol      CHAR(2);
DEFINE cCausaStatus    CHAR(3);
DEFINE cStatusSol2      CHAR(2);
DEFINE cCausaStatus2    CHAR(3);
DEFINE cCausaStatusAux    CHAR(3);
DEFINE cDescStatusSol  CHAR(2);
DEFINE cComportamientoSic CHAR(100);
DEFINE cComportamientoSicCop CHAR(100);

DEFINE dtFechaSolOs   DATE;
DEFINE cStatusOS      CHAR(1);
DEFINE cSitEspOS 	 CHAR(1);
DEFINE cMotivoOS 	 CHAR(2);
DEFINE iCausaSitEspOS     SMALLINT;
DEFINE cDescSitEspOS CHAR(100);
DEFINE cDescMotivoOS CHAR(100);

DEFINE dtFechaOstel   DATE;
DEFINE cRespuestaOstel CHAR(1);
DEFINE cAtendio 	 CHAR(2);
DEFINE iSecuenciaOstel 	 INTEGER;
DEFINE cGeneroOstel 	 CHAR(1);


DEFINE dIngresoMensual DECIMAL(18,2);
DEFINE dIngresoLC      DECIMAL(18,2);
DEFINE dCompromisosBanco DECIMAL(18,2);
DEFINE dCompromisosSIC DECIMAL(18,2);
DEFINE dCompromisosCoppel DECIMAL(18,2);
DEFINE dCMA DECIMAL(18,2);
DEFINE dTAB DECIMAL(18,2);
DEFINE dLineaTeorica DECIMAL(18,2);
DEFINE dMontoSol DECIMAL(18,2);
DEFINE dMontoAut DECIMAL(18,2);
DEFINE dMontoMaxSol DECIMAL(18,2);

DEFINE dCMA_cop 	 INTEGER;
DEFINE dTAB_cop 	 INTEGER;
DEFINE dCRA_cop 	 INTEGER;
DEFINE dMontoSol_cop 	 INTEGER;
DEFINE dLineaTeorica_cop 	 INTEGER;

DEFINE iPuntos_parcn     SMALLINT;
DEFINE iPar_altoriesgo     SMALLINT;
DEFINE iPar_celulares     SMALLINT;
DEFINE iPar_prestamos     SMALLINT;
DEFINE iBanderaMixta     SMALLINT;
DEFINE cPermCambio    CHAR(1);

DEFINE dCapacidad  MONEY(14,2);
DEFINE iPlazo      INTEGER;
DEFINE dValor      DECIMAL(14,2);
DEFINE dLimitecreditopesos      DECIMAL(18,2);
DEFINE cCausaSol      CHAR(3);
DEFINE cCausaSol2      CHAR(3);
DEFINE iContAux      SMALLINT;

DEFINE cSexo CHAR(1);


---INICIALIZACIONES
LET iSqlErr        = 0;
LET iIsamErr       = 0;
LET cErrorInfo     = "";
LET cCodRet        = "000000";
LET cCodRet2        = "000000";
LET cMensajeRet    = "Se realizó la consulta correctamente";

LET iSqlErr        =0;
LET iIsamErr       =0;
LET cErrorInfo     = "";
LET cNumcte        = "";
LET cNombreCte     = "";
LET cRfc           = "";
LET cSucursal      = "";
LET cNumCteCop     = "";
LET dLineaCoppel   =0;
LET cEficienciaPago =0;
LET cMesesHist      =0;
LET cPuntualidad    = "";
LET cVencidoUdis    =0;
LET cSituacion_credito  = "";
LET cCausa			 =0;
LET cDescSitEsp      = "";
LET cNumSolicitud    = "";
LET cNum_solicitud_ref    = "";
LET cNumSol2    = "";
LET cNumProd    = "";
LET cNumProd2    = "";
LET cDescNumProd    = "";
LET cDescNumProd2    = "";
LET cTpSol    = "";
LET dtFechaSol       = DATE(1);
LET dtFechaCambioStatus  = DATE(1);
LET dtFechaCambioStatus2  = DATE(1);
LET dtFechaCambioStatusAux  = DATE(1);

LET dBCScore        =0;
LET dScoreProp      =0;
LET dResultadoTotal =0;
LET iCantidad =0;
LET cStatusSol      = "";
LET cCausaStatus      = "";
LET cCausaStatusAux      = "";
LET cComportamientoSic = "";
LET cComportamientoSicCop = "";
LET dtFechaSolOs  =DATE(1);
LET cStatusOS     = "";
LET cSitEspOS 	  = "";
LET cMotivoOS 	  = "";
LET iCausaSitEspOS =0;
LET cDescSitEspOS = "";
LET cDescMotivoOS = "";
LET dtFechaOstel   = DATE(1);
LET cRespuestaOstel = "";
LET cAtendio 	 = "";
LET iSecuenciaOstel =0;
LET cGeneroOstel = "F";
LET dIngresoMensual =0;
LET dIngresoLC      =0;
LET dCompromisosBanco =0;
LET dCompromisosSIC =0;
LET dCompromisosCoppel =0;
LET dCMA =0;
LET dTAB =0;
LET dLineaTeorica =0;
LET dMontoSol =0;
LET dMontoMaxSol =0;
LET dCMA_cop 	  =0;
LET dTAB_cop 	  =0;
LET dCRA_cop 	  =0;
LET dMontoSol_cop 	  =0;
LET dLineaTeorica_cop =0;

LET iPuntos_parcn    =0;
LET iPar_altoriesgo  =0;
LET iPar_celulares   =0;
LET iPar_prestamos   =0;
LET cStatusSol2      = "";
LET cCausaStatus2      = "";
LET cPermCambio      = "";
     
LET dCapacidad  =0;
LET iPlazo     =0;
LET dValor      =0;
LET dLimitecreditopesos      =0;
LET iBanderaMixta      =1;
LET cCausaSol      ="";
LET cCausaSol2     ="";
LET iContAux     = 0;

LET dMontoAut = 0;
LET cEnvioCop = '';

LET cSexo = '';

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo   
     LET cCodRet= iSqlErr;
     RETURN cCodRet, cErrorInfo,cNumcte,cNombreCte,cRfc,cSucursal,
		cNumCteCop,dLineaCoppel,  cEficienciaPago,cMesesHist,cPuntualidad,cVencidoUdis, cSituacion_credito,cCausa,cDescSitEsp,
		cNumSolicitud,dtFechaSol,dtFechaCambioStatus,
		dBCScore, dScoreProp,dResultadoTotal,cStatusSol,cCausaStatus,cComportamientoSic,
		dtFechaSolOs,cStatusOS,cSitEspOS,iCausaSitEspOS,cDescSitEspOS,cDescMotivoOS,
		dtFechaOstel,cRespuestaOstel,cAtendio,
		dIngresoMensual,dIngresoLC,dCompromisosBanco,dCompromisosSIC,dCompromisosCoppel,dCMA,dTAB,	dLineaTeorica,dMontoSol,
		dMontoMaxSol,cNumProd,cDescNumProd,cNumProd,cDescNumProd,	
	    dCMA_cop,dTAB_cop,dCRA_cop,dMontoSol_cop,dLineaTeorica_cop,iPuntos_parcn,iPar_altoriesgo,iPar_celulares,
		iPar_prestamos,cEnvioCop,cNum_solicitud_ref,cStatusSol2, cCausaStatus2 ,dtFechaCambioStatus2,cPermCambio,dMontoAut,dLimitecreditopesos,cComportamientoSicCop,cCausaSol,cCausaSol2, cSexo; 		
END EXCEPTION;

    --SET DEBUG FILE TO '/informix/jesus/sp_mc_obteninfosolicitud.out';
	--TRACE ON;
	

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

	 IF NVL(pEmpresa, '' ) = '' OR NVL(pNumSol,'')= '' THEN
		LET cCodret = '000001'; 
		LET cMensajeRet = 'PARAMETROS DE ENTRADA INVALIDOS'; 
		RETURN cCodRet, cMensajeRet,cNumcte,cNombreCte,cRfc,cSucursal,
		cNumCteCop,dLineaCoppel,  cEficienciaPago,cMesesHist,cPuntualidad,cVencidoUdis, cSituacion_credito,cCausa,cDescSitEsp,
		cNumSolicitud,dtFechaSol,dtFechaCambioStatus,
		dBCScore, dScoreProp,dResultadoTotal,cStatusSol,cCausaStatus,cComportamientoSic,
		dtFechaSolOs,cStatusOS,cSitEspOS,iCausaSitEspOS,cDescSitEspOS,cDescMotivoOS,
		dtFechaOstel,cRespuestaOstel,cAtendio,
		dIngresoMensual,dIngresoLC,dCompromisosBanco,dCompromisosSIC,dCompromisosCoppel,dCMA,dTAB,	dLineaTeorica,dMontoSol,
		dMontoMaxSol,cNumProd,cDescNumProd,cNumProd,cDescNumProd,	
	    dCMA_cop,dTAB_cop,dCRA_cop,dMontoSol_cop,dLineaTeorica_cop,iPuntos_parcn,iPar_altoriesgo,iPar_celulares,
		iPar_prestamos,cEnvioCop,cNum_solicitud_ref,cStatusSol2, cCausaStatus2,dtFechaCambioStatus2,cPermCambio,dMontoAut,dLimitecreditopesos,cComportamientoSicCop ,cCausaSol,cCausaSol2, cSexo; 		
	 END IF;
	 
	 
	
	 
	 --se valida que si el cliente tiene tramite mixto, se tome como principal el producto de bancoppel
	 IF SUBSTR(pNumSol,1,2) ='65'  THEN		-- SE Valida si la solicitud tiene tramite mixto
		SELECT num_solicitud_ref INTO cNumSol2
		FROM "informix".ss_resum_scor_fin 
		WHERE empresa = pEmpresa
		AND num_solicitud = pNumSol;
		
		--se valida que ambas solicitudes esten relacionadas.
		IF NVL(cNumSol2,"") <> "" THEN
			IF (SELECT num_solicitud_ref FROM "informix".ss_resum_scor_fin 
			WHERE empresa = pEmpresa AND num_solicitud = cNumSol2 ) = pNumSol THEN 
				
					LET cNum_solicitud_ref=cNumSol2;
					LET cNumSol2=pNumSol; 
					LET pNumSol = cNum_solicitud_ref;	
			ELSE
				LET cNumSol2="";
				LET iBanderaMixta = 0;
			END IF;
		
		END IF;
		
	 END IF;
	 
	SELECT a.num_solicitud, a.numcte, a.tipo_solicitud, NVL(a.status_solicitud, '') ,  NVL(a.monto_solicitado,0) , NVL(a.monto_autorizado,0) ,
	       b.num_producto, b.nombre_prod, ss.descripcion, a.sucursal,a.fecha_insert,envio_parametrico,permite_cambio
	  INTO  cNumSolicitud,cNumcte,cTpSol,cStatusSol,dMontoSol,dMontoAut,cNumProd,cDescNumProd,cDescStatusSol,cSucursal,dtFechaSol,cEnvioCop,cPermCambio
    FROM "informix".ss_solicitudes as a 
      LEFT JOIN bdicred:"informix".sd_definicion as b on (b.empresa=a.empresa AND a.num_producto = b.num_producto)
      LEFT JOIN "informix".ss_status_sol as ss On (ss.empresa=a.empresa AND ss.status_solicitud = a.status_solicitud)    	
	  LEFT JOIN "informix".ss_cambio_status_mc as sc On (sc.empresa=a.empresa
														AND sc.status_inicial = a.status_solicitud 
														AND secuencia  = (SELECT MAX(secuencia) 
																			FROM "informix".ss_cambio_status_mc 
																			WHERE empresa=a.empresa
																			AND status_inicial = a.status_solicitud))    	
        WHERE a.empresa = pEmpresa
     AND a.num_solicitud = pNumSol;	 
	 
	 
	 IF cNumProd = "6500" THEN
		LET  cNumProd2 = cNumProd;
		LET  cDescNumProd2 = cDescNumProd;
		LET  cStatusSol2 = cStatusSol; 
		LET  cCausaStatus2 = cCausaStatus;
	 END IF;
	
	 
	IF NVL(cNumSolicitud,"") = "" THEN
		LET cCodret = '000002'; --
		LET cMensajeRet         = "No se encontro información, verifique...";
		RETURN cCodRet, cMensajeRet,cNumcte,cNombreCte,cRfc,cSucursal,
		cNumCteCop,dLineaCoppel,  cEficienciaPago,cMesesHist,cPuntualidad,cVencidoUdis, cSituacion_credito,cCausa,cDescSitEsp,
		cNumSolicitud,dtFechaSol,dtFechaCambioStatus,
		dBCScore, dScoreProp,dResultadoTotal,cStatusSol,cCausaStatus,cComportamientoSic,
		dtFechaSolOs,cStatusOS,cSitEspOS,iCausaSitEspOS,cDescSitEspOS,cDescMotivoOS,
		dtFechaOstel,cRespuestaOstel,cAtendio,
		dIngresoMensual,dIngresoLC,dCompromisosBanco,dCompromisosSIC,dCompromisosCoppel,dCMA,dTAB,	dLineaTeorica,dMontoSol,
		dMontoMaxSol,cNumProd,cDescNumProd,cNumProd2,cDescNumProd2,	
	    dCMA_cop,dTAB_cop,dCRA_cop,dMontoSol_cop,dLineaTeorica_cop,iPuntos_parcn,iPar_altoriesgo,iPar_celulares,iPar_prestamos,cEnvioCop,cNum_solicitud_ref,cStatusSol2, cCausaStatus2 ,dtFechaCambioStatus2,cPermCambio,dMontoAut,dLimitecreditopesos,cComportamientoSicCop,cCausaSol,cCausaSol2, cSexo; 		
	END IF

	
	SELECT rfc,TRIM(nombre1)||' '||TRIM(nombre2)||' '||TRIM(apell_paterno)||' '||TRIM(apell_materno),numcte_ref
		INTO cRfc,cNombreCte,cNumCteCop
	FROM bdinteg:"informix".si_cliente
	WHERE empresa = '001'
	AND numcte = cNumCte;   	
	
	
	/* EXECUTE PROCEDURE "informix".determina_lincred_tc_cjunk(pEmpresa,pNumSol,'') INTO cCodRet2,dValor,dCapacidad,iPlazo;
	IF cTpSol IN ('T') THEN
		   UPDATE "informix".ss_solicitudes
			  SET monto_solicitado = dValor,
				  capacidad_pres = dCapacidad
			WHERE empresa = pEmpresa
			  AND num_solicitud = pNumSol;
	ELIF cTpSol = 'P' THEN
	   UPDATE "informix".ss_solicitudes
		  SET monto_autorizado = dValor,
			  capacidad_pres = dCapacidad,
			  plazo = iPlazo
		WHERE empresa = pEmpresa
		  AND num_solicitud = pNumSol;
	END IF; */
	
	-- SE OBTIENE LAS PUNTUACIONES DEL SCORING QUE SE LE REALIZÓ AL CLIENTE.
	SELECT NVL(SUM(DECODE(seccion, '1', NVL(evaluacion,0), 0)),0) ,
		   NVL(SUM(DECODE(seccion, '2', NVL(evaluacion,0), 0)),0) ,
		   NVL(SUM(NVL(evaluacion, 0)),0) ,
			COUNT(num_solicitud) 
	INTO dBCScore, dScoreProp, dResultadoTotal,iCantidad
	FROM "informix".ss_resumen_scoring
	WHERE empresa = pEmpresa
	  AND num_solicitud = cNumSolicitud
	  AND seccion IN ('1','2');
	  
	
	

    If iCantidad <> 2 Then    
     
           Select nvl(sum(nvl(puntuacion,0)),0) 
		   INTO dBCScore
            From "informix".ss_scoring_financ sf, "informix".ss_resum_scor_fin rsf 
            where rsf.empresa = pEmpresa
            and rsf.num_solicitud = cNumSolicitud
            and rsf.empresa = sf.empresa 
            and upper(sf.tp_solicitud) = cTpSol
            and sf.circulo_credito = evalua_cc 
            and sf.min_mes_hist <= rsf.meses_historia 
            and sf.max_mes_hist >= rsf.meses_historia 
            and sf.min_porc_pago <= rsf.situacion_pago 
            and sf.max_porc_pago >= rsf.situacion_pago;
        
		   
            Select  nvl(sum(nvl(dc.valor,0)),0) 
			INTO dScoreProp
            From "informix".ss_detalle_scoring dc, "informix".ss_scoring_grupo sg 
            Where sg.empresa = dc.empresa 
            and sg.grupo = dc.grupo 
            and sg.seccion = dc.seccion 
            and dc.num_solicitud = cNumSolicitud
            and dc.seccion = '2' 
            and dc.empresa = pEmpresa;           	
           
            LET dResultadoTotal = dBCScore + dScoreProp;
    End If  
		 
	
	
	--INI Datos sección Orden de Supervisión Calle
	SELECT a.fecha_solicitud, nvl(a.status, '') ,a.motivo_os,  c.situacionespecial, c.causasituacionespecial 
	INTO dtFechaSolOs,cStatusOS,cMotivoOS,cSitEspOS,iCausaSitEspOS
	FROM "informix".ss_solicitud_os a 
	LEFT JOIN "informix".ss_osclientesupervisar c ON (c.empresa=a.empresa and c.num_solicitud =a.num_solicitud and c.fechasolicitud=a.fecha_solicitud)
	WHERE a.num_solicitud = cNumSolicitud
	  AND a.fecha_solicitud =(
							   SELECT MAX(fecha_solicitud) 
							   FROM bdisolic:"informix".ss_solicitud_os b 
							   WHERE b.num_solicitud = a.num_solicitud 
							   AND b.empresa = a.empresa
							 )
	  and a.empresa =pEmpresa;
	 
	IF NVL(cSitEspOS,"") <> "" THEN
		SELECT descripcion 
			INTO cDescSitEspOS
		FROM bdicred:"informix".sd_causas_os 
		WHERE empresa = pEmpresa
		AND situacion = cSitEspOS
		AND causa = iCausaSitEspOS;
	END IF;
	--cMotivoOS LEER descripcion del motivo
	IF NVL(cMotivoOS,0) <> 0 THEN --SE corrige consulta JMAH 
		SELECT LIMIT 1 valor_alfabetico 
		INTO cDescMotivoOS
		FROM "informix".ss_param_solicitudes
		WHERE empresa = pEmpresa
		AND grupo_parametro ='MOTIVOS_OS'
		AND secuencia = cMotivoOS;	
	END IF;
	--FIN Datos sección Orden de Supervisión Calle		
	--INI Datos sección Orden de Supervisión Telefónica		
	SELECT LIMIT 1 secuenciaostel,resultadofinal,DECODE(automatico,'1','NO','SI')
		INTO iSecuenciaOstel,cRespuestaOstel,cAtendio
	FROM "informix".ss_ostelrefsolicitud 
    WHERE num_solicitud =cNumSolicitud;	
    IF NVL(iSecuenciaOstel,0) >  0 THEN
		SELECT fechaenvio,generar_os 
		INTO dtFechaOstel,cGeneroOstel
		FROM "informix".ss_osclientesupervisartel 
		WHERE secuenciaostel =  iSecuenciaOstel
		AND enviada ='1';
	END IF;
	IF cGeneroOstel = 'F' THEN
		LET dtFechaOstel ="";
		LET cRespuestaOstel ="";
		LET cAtendio ="";	
	END IF;	

	--FIN Datos sección Orden de Supervisión Telefónica	            
	
	
	--INI Datos sección determinación línea de crédito
    -- SE OBTIENEN LOS DATOS DE LA INFORMACIÓN CREDITICIA EN COPPEL/BANCOPPEL.
	SELECT 
	--datos coppel
	linea_tienda,situacion_pago,meses_historia,puntualidad,
	(vencidoropa + vencidomuebles + vencidoprestamos ),situacion_credito,causa,motivo_cc,
	(abonomensualprestamos + abonomensualmuebles + abonomensualropa),
	--datos bancoppel
	ingreso_mensual,ingreso_lc,compromisos_bco,pago_minimo,valor_cma,valor_tab,linea_teorica,num_solicitud_ref
	INTO dLineaCoppel,cEficienciaPago,cMesesHist,cPuntualidad,
		cVencidoUdis, cSituacion_credito,cCausa,cComportamientoSic,dCompromisosCoppel,
		dIngresoMensual,dIngresoLC,dCompromisosBanco,dCompromisosSIC,dCMA,dTAB,	dLineaTeorica,cNumSol2
	FROM "informix".ss_resum_scor_fin 
	WHERE empresa = pEmpresa
	  AND num_solicitud = pNumSol;
	 
	
	  
	IF NVL(cSituacion_credito,"") <> "" THEN
		SELECT descripcion 
		INTO cDescSitEsp
		FROM bdicred:"informix".sd_causas_cte_coppel
		WHERE empresa = pEmpresa
		AND situacion = cSituacion_credito
		AND causa = cCausa;    	
	END IF;	
	
	LET iContAux= 0;
	FOREACH WITH HOLD
		SELECT causa_solicitud,fecha_entrada
		INTO cCausaStatusAux,dtFechaCambioStatusAux
		FROM "informix".ss_autorizacion 
		WHERE num_solicitud = pNumSol 
		AND status_solicitud= cStatusSol
		ORDER BY FECHA_HORA DESC
		
		LET iContAux= iContAux+1;
		
		IF iContAux = 1 THEN
		
			LET cCausaStatus = cCausaStatusAux;
			LET dtFechaCambioStatus =dtFechaCambioStatusAux;
			IF cStatusSol <> "CN" THEN
					EXIT FOREACH;
			END IF;
		ELIF iContAux = 2 THEN
			LET cCausaSol = cCausaStatusAux;
			EXIT FOREACH;
		END IF
		
	END FOREACH;
	
	IF NVL(cNumSol2,"") <> ""  AND iBanderaMixta =  1 THEN	
		SELECT a.status_solicitud ,  b.num_producto, b.nombre_prod, envio_parametrico
		  INTO cStatusSol2,cNumProd2,cDescNumProd2,cEnvioCop
		FROM "informix".ss_solicitudes as a 
		  LEFT JOIN bdicred:"informix".sd_definicion as b on (b.empresa=a.empresa AND a.num_producto = b.num_producto)
		  LEFT JOIN "informix".ss_status_sol as ss On (ss.empresa=a.empresa AND ss.status_solicitud = a.status_solicitud)    	
			WHERE a.empresa = pEmpresa
		 AND a.num_solicitud = cNumSol2;	

	
		
			LET iContAux= 0;
		FOREACH WITH HOLD
			SELECT causa_solicitud,fecha_entrada
			INTO cCausaStatusAux,dtFechaCambioStatusAux
			FROM "informix".ss_autorizacion 
			WHERE num_solicitud = cNumSol2 
			AND status_solicitud= cStatusSol2
			ORDER BY FECHA_HORA DESC
			
			LET iContAux= iContAux+1;
			
			IF iContAux = 1 THEN			
				LET cCausaStatus2 = cCausaStatusAux;
				LET dtFechaCambioStatus2 =dtFechaCambioStatusAux;
				IF cStatusSol2 <> "CN" THEN
					EXIT FOREACH;
				END IF;
			ELIF iContAux = 2 THEN
				LET cCausaSol2 = cCausaStatusAux;
				EXIT FOREACH;
			END IF
			
		END FOREACH;
	

		SELECT motivo_cc
			INTO cComportamientoSicCop
		FROM "informix".ss_resum_scor_fin 
		WHERE empresa = pEmpresa
		AND num_solicitud = cNumSol2;
		 
	ELSE
		IF cNumProd ='6500' THEN
			LET  cNumProd = '';
			LET  cDescNumProd = '';
			LET  cStatusSol2 = ''; 
			LET  cCausaStatus2 = '';
			LET dtFechaCambioStatus2 ="";
			LET cComportamientoSicCop ="";
		END IF;
	END IF;
	--FIN Datos sección determinación línea de crédito
	
	IF cNumProd = "6500" OR cNumProd2 ="6500"  THEN
		IF SUBSTR(pNumSol,1,2) = '65' THEN
			LET cNumSol2 =pNumSol;	
		END IF;
		SELECT Limit 1 capmaxima_abono , tope_abonocoppel, capreal_abono , lineacreditotope , lineacredito_real,
		puntos_parcn,par_altoriesgo,par_celulares,par_prestamos,limitecreditopesos
		INTO dCMA_cop,dTAB_cop,dCRA_cop,dMontoSol_cop,dLineaTeorica_cop,
		iPuntos_parcn,iPar_altoriesgo,iPar_celulares,iPar_prestamos,dLimitecreditopesos
		FROM bdisolic:"informix".ss_nuevo_parametrico
		WHERE empresa = pEmpresa
		AND num_solicitud = cNumSol2;  	
		
	END IF;
	IF cNumProd = "6400" OR cNumProd2 ="6400" THEN
		
		SELECT promedio_mes,maximo_solic 
			INTO dIngresoLC,dMontoMaxSol
		FROM "informix".ss_sol_nomina
		WHERE empresa = pEmpresa
		AND num_solicitud = cNumSolicitud;

		
	END IF

	SELECT sexo
      INTO cSexo
	  FROM bdinteg:"informix".si_ctepf
	 WHERE numcte = cNumCte;   	
    
    IF (cSexo is null) then
        LET cSexo = '';
    END IF;
	


RETURN cCodRet, cMensajeRet,cNumcte,cNombreCte,cRfc,cSucursal,
		cNumCteCop,dLineaCoppel,  cEficienciaPago,cMesesHist,cPuntualidad,cVencidoUdis, cSituacion_credito,cCausa,NVL(cDescSitEsp,""),
		cNumSolicitud,dtFechaSol,dtFechaCambioStatus,
		dBCScore, dScoreProp,dResultadoTotal,cStatusSol,cCausaStatus,cComportamientoSic,
		NVL(dtFechaSolOs,""),NVL(cStatusOS,""),NVL(cSitEspOS,""),NVL(iCausaSitEspOS,""),NVL(cDescSitEspOS,""),NVL(cDescMotivoOS,""),
		NVL(dtFechaOstel,""),NVL(cRespuestaOstel,""),NVL(cAtendio,""),
		dIngresoMensual,dIngresoLC,dCompromisosBanco,dCompromisosSIC,dCompromisosCoppel,dCMA,dTAB,	dLineaTeorica,dMontoSol,
		dMontoMaxSol,cNumProd,cDescNumProd,cNumProd2,cDescNumProd2,	
	    dCMA_cop,dTAB_cop,dCRA_cop,dMontoSol_cop,dLineaTeorica_cop,iPuntos_parcn,iPar_altoriesgo,iPar_celulares,iPar_prestamos,cEnvioCop,cNumSol2,cStatusSol2, cCausaStatus2,dtFechaCambioStatus2,cPermCambio,dMontoAut,dLimitecreditopesos,cComportamientoSicCop,cCausaSol,cCausaSol2, cSexo; 
			
END 
END PROCEDURE

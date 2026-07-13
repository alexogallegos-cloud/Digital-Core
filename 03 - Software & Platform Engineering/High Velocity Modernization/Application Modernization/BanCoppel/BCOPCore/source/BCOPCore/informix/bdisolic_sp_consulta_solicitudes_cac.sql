CREATE PROCEDURE "informix".sp_consulta_solicitudes_cac(pEmpresa CHAR(3), pNumSolicitud  CHAR(20))
RETURNING CHAR(6)  		AS cCodRet,
          CHAR(80) 		AS cMensajeRet,
          CHAR(20) 		AS cuenta,
		  CHAR(20) 		AS cNumCte,
          CHAR(107) 	AS cNombreCte,
          CHAR(13) 		AS cRfcCte,
          CHAR(6) 		AS cAntecBC,
          DECIMAL(18,2) AS deCompMensBC,
          CHAR(6) 		AS cAntecCC,
          DECIMAL(18,2) AS deCompMensCC,
		  CHAR(20) 		AS cNumCteCop,
          SMALLINT 		AS smAntiguedad,
          CHAR(2)  		AS cPuntualidad,
		  DECIMAL(18,2) AS deEficPago,
		  DECIMAL(18,2) AS deAbonMensual,
		  DECIMAL(18,2) AS deIngresoMen,
		  DECIMAL(18,2) AS deMontoSolic,
		  CHAR(300) 	As Observaciones,
		  DECIMAL(18,2) AS deCompromisos_cac,
		  CHAR(1) 		AS cComprobante_val,
		  CHAR(20) 		AS cFecha_insert,		  
		  DECIMAL(18,2) AS deMontoSolic2,
		  DECIMAL(18,2) AS deIngresoValMC,
		  DECIMAL(18,2) AS deLineaCoppel,
		  DECIMAL(18,2) AS dePagoMensBco;


--DECLARACIÓN DE VARIABLES
DEFINE iSqlErr         	INTEGER;
DEFINE iIsamErr        	INTEGER;
DEFINE cErrorInfo      	CHAR(80);
DEFINE cCodRet         	CHAR(6);
DEFINE cMensajeRet     	CHAR(80);
DEFINE cNumSolic       	CHAR(20);
DEFINE cNumCte         	CHAR(20);
DEFINE cNom1Cte        	CHAR(26);
DEFINE cNom2Cte        	CHAR(26);
DEFINE cApellPat        CHAR(26);
DEFINE cApellMat       	CHAR(26);
DEFINE cNombreCte      	CHAR(107);
DEFINE cRfcCte         	CHAR(13);
DEFINE cAntecCC        	CHAR(6);
DEFINE cAntecBC        	CHAR(6);
DEFINE cInstitucion     CHAR(2);
DEFINE deCompMensCC    	DECIMAL(18,2);
DEFINE deCompMensBC    	DECIMAL(18,2);
DEFINE iConInst        	SMALLINT;
DEFINE cNumCteCop       CHAR(20);

DEFINE smAntiguedad    	SMALLINT;
DEFINE cPuntualidad    	CHAR(2);
DEFINE deEficPago      	DECIMAL(18,2);

DEFINE deAbMenRopa     	DECIMAL(18,2);
DEFINE deAbMenMue       DECIMAL(18,2);
DEFINE deAbMenPresPers  DECIMAL(18,2);
DEFINE deAbonMensual    DECIMAL(18,2);

DEFINE deIngresoMen     DECIMAL(18,2);
DEFINE deIngresoValMC   DECIMAL(18,2);
DEFINE deMontoSolic     DECIMAL(18,2);
DEFINE deMontoSolic1    DECIMAL(18,2);
DEFINE cObservaciones   CHAR(300);

-- FOLIO 1400
DEFINE deCompromisos_cac  DECIMAL(18,2);
DEFINE cComprobante_val   CHAR(1);
DEFINE cFecha_insert      CHAR(10);
DEFINE deMontoSolic2     DECIMAL(18,2);
DEFINE dLineaCop     DECIMAL(18,2);
DEFINE dPagoMensBco     DECIMAL(18,2);
DEFINE cRevisado     CHAR(1);

--INICIALIZACIÓN DE VARIABLES
LET iSqlErr            	= 0;
LET iIsamErr           	= 0;
LET cErrorInfo         	= "";
LET cCodRet            	= "000000";
LET cMensajeRet        	= "PROCESO EXITOSO";
LET cNumSolic          	= "";
LET cNumCte            	= "";
LET cNom1Cte           	= "";
LET cNom2Cte           	= "";
LET cApellPat			= "";
LET cApellMat			= "";
LET cNombreCte         	= "";
LET cRfcCte            	= "";
LET cAntecCC           	= "";
LET cAntecBC           	= "";
LET cInstitucion        = "";
LET deCompMensCC       	= 0.00;
LET deCompMensBC       	= 0.00;
LET iConInst           	= 0;
LET cNumCteCop          ="";

LET smAntiguedad     	= 0;
LET cPuntualidad   		= "";
LET deEficPago       	= 0.00;

LET deAbMenRopa     	= 0.00;
LET deAbMenMue         	= 0.00;
LET deAbMenPresPers    	= 0.00;
LET deAbonMensual       = 0.00;

LET deIngresoMen        = 0.00;
LET deIngresoValMC      = 0.00;
LET deMontoSolic       	= 0.00;
LET deMontoSolic1      	= 0.00;
LET cObservaciones      = "";

LET deCompromisos_cac  = 0.00;
LET cComprobante_val   = "";
LET cFecha_insert      = "";
LET deMontoSolic2      = 0.00;
LET dLineaCop          = 0.00;
LET dPagoMensBco       = 0.00;
LET cRevisado       = "";


BEGIN

-- EN CASO DE CAER EN ERRORES MENORES NO CONTROLADOS
ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
      LET cCodRet= iSqlErr;
      LET cMensajeRet= cErrorInfo;
		RETURN cCodRet, cMensajeRet, NVL(cNumSolic,""), NVL(cNumCte,""), NVL(cNombreCte,""), NVL(cRfcCte,""), NVL(cAntecBC,""), NVL(deCompMensBC,0),
		NVL(cAntecCC,""), NVL(deCompMensCC,0), NVL(cNumCteCop,""), NVL(smAntiguedad,0), NVL(cPuntualidad,""),NVL(deEficPago,0),
		NVL(deAbonMensual,0), NVL(deIngresoMen,0), NVL(deMontoSolic,0), NVL(cObservaciones,""),NVL(deCompromisos_cac,0.00),NVL(cComprobante_val,""),NVL(cFecha_insert,""),NVL(deMontoSolic,0),NVL(deIngresoValMC,0), NVL(dLineaCop,0), NVL(dPagoMensBco,0);
   END IF;
END EXCEPTION;

-- RUTA DE TRACE
--SET DEBUG FILE TO "/informix/jesus/sp_consulta_solicitudes_cac.out";
--TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

	-- SE VERIFICA QUE LOS PARAMETROS NO VENGAN VACÍOS
	IF  pEmpresa = "" OR pNumSolicitud = ""  THEN
		LET cCodRet =  "000001";
		LET cMensajeRet = "PARAMETROS DE ENTRADA INCOMPLETOS";

		RETURN cCodRet, cMensajeRet, NVL(cNumSolic,""), NVL(cNumCte,""), NVL(cNombreCte,""), NVL(cRfcCte,""), NVL(cAntecBC,""), NVL(deCompMensBC,0),
		NVL(cAntecCC,""), NVL(deCompMensCC,0), NVL(cNumCteCop,""), NVL(smAntiguedad,0), NVL(cPuntualidad,""),NVL(deEficPago,0),
		NVL(deAbonMensual,0), NVL(deIngresoMen,0), NVL(deMontoSolic,0), NVL(cObservaciones,""),NVL(deCompromisos_cac,0.00),NVL(cComprobante_val,""),NVL(cFecha_insert,""),NVL(deMontoSolic,0),NVL(deIngresoValMC,0),NVL(dLineaCop,0), NVL(dPagoMensBco,0);

	END IF;
	
	-- SE VERIFICA QUE LA EMPRESA EXISTA EN LA TABLA BDINTEG:"INFORMIX".SI_EMPRESAS 
	IF NOT EXISTS(SELECT empresa FROM bdinteg:"informix".si_empresas  WHERE empresa = pEmpresa) THEN
		
		-- SI LA EMPRESA NO EXISTE SE TERMINA EL SP Y SE RETORNA LO QUE SE TIENE HASTA EL MOMENTO
		LET cCodRet =  "000002";
		LET cMensajeRet = "EMPRESA NO VÁLIDA";

		RETURN cCodRet, cMensajeRet, NVL(cNumSolic,""), NVL(cNumCte,""), NVL(cNombreCte,""), NVL(cRfcCte,""), NVL(cAntecBC,""), NVL(deCompMensBC,0),
		NVL(cAntecCC,""), NVL(deCompMensCC,0), NVL(cNumCteCop,""), NVL(smAntiguedad,0), NVL(cPuntualidad,""),NVL(deEficPago,0),
		NVL(deAbonMensual,0), NVL(deIngresoMen,0), NVL(deMontoSolic,0), NVL(cObservaciones,""),NVL(deCompromisos_cac,0.00),NVL(cComprobante_val,""),NVL(cFecha_insert,""),NVL(deMontoSolic,0),NVL(deIngresoValMC,0),NVL(dLineaCop,0), NVL(dPagoMensBco,0);

	END IF;
	
	-- SE VERIFICA QUE LA SOLICITUD EXISTA EN LA TABLA "INFORMIX".SS_SOLICITUDES
	IF EXISTS(SELECT num_solicitud FROM "informix".ss_solicitudes	WHERE num_solicitud = pNumSolicitud) THEN
		
		-- SI LA SOLICITUD EXISTE SE BUSCA LA INFORMACIÓN DE LA SOLICITUD Y EL NÚMERO DE CLIENTE
		SELECT num_solicitud, numcte,monto_solicitado,fecha_insert
		INTO cNumSolic, cNumCte,deMontoSolic,cFecha_insert
		FROM "informix".ss_solicitudes
		WHERE num_solicitud = pNumSolicitud;
	ELSE
	
		-- SI NO EXISTE LA SOLICITUD SE TERMINA EL SP Y SE RETORNA LO QUE SE TIENE HASTA EL MOMENTO
		LET cCodRet =  "000003";
		LET cMensajeRet = "SOLICITUD NO EXISTE O ESTA INCORRECTA";

		RETURN cCodRet, cMensajeRet, NVL(cNumSolic,""), NVL(cNumCte,""), NVL(cNombreCte,""), NVL(cRfcCte,""), NVL(cAntecBC,""), NVL(deCompMensBC,0),
		NVL(cAntecCC,""), NVL(deCompMensCC,0), NVL(cNumCteCop,""), NVL(smAntiguedad,0), NVL(cPuntualidad,""),NVL(deEficPago,0),
		NVL(deAbonMensual,0), NVL(deIngresoMen,0), NVL(deMontoSolic,0), NVL(cObservaciones,""),NVL(deCompromisos_cac,0.00),NVL(cComprobante_val,""),NVL(cFecha_insert,""),NVL(deMontoSolic,0),NVL(deIngresoValMC,0),NVL(dLineaCop,0), NVL(dPagoMensBco,0);

	END IF;
	
	-- SI LA EMPRESA Y LA SOLICITUD SON VALIDAS SE BUSCAN LOS DATOS DE EL CLIENTE 
	SELECT nombre1, nombre2, apell_paterno, apell_materno, rfc, numcte_ref
	INTO cNom1Cte, cNom2Cte, cApellPat, cApellMat, cRfcCte, cNumCteCop
	FROM bdinteg:"informix".si_cliente
	WHERE empresa = pEmpresa
	AND numcte = cNumCte;
	
	-- SE CONCATENA EL NOMBRE DE EL CLIENTE
	LET cNombreCte = TRIM(NVL(cNom1Cte,"")) || " " || TRIM(NVL(cNom2Cte,"")) || " " || TRIM(NVL(cApellPat,"")) || " " || TRIM(NVL(cApellMat,""));

	-- SE BUSCA LA INSTITUCIÓN PARA PODER RETORNARLA
	SELECT limit 1 institucion 
		INTO cInstitucion
	FROM "informix".ss_solicitudes_sic
	WHERE num_solicitud = pNumSolicitud
	AND numcte = cNumCte;
	
	-- SE BUSCA LA INFORMACIÓN HISTORICA, SITUACIÓN DE PAGO Y ABONOS DE LA SOLICITUD
	SELECT  DECODE(evalua_cc, "0", "BUENOS", "1", "MALOS", "X", "NULOS"), ingreso_mensual, pago_minimo,
	meses_historia, puntualidad, situacion_pago,abonomensualropa, abonomensualmuebles,
			abonomensualprestamos, linea_tienda ,compromisos_bco 
	INTO cAntecBC, deIngresoMen, deCompMensBC,
		smAntiguedad, cPuntualidad, deEficPago, deAbMenRopa, deAbMenMue, deAbMenPresPers,dLineaCop, dPagoMensBco
	FROM "informix".ss_resum_scor_fin
	WHERE empresa = pEmpresa
	AND num_solicitud = pNumSolicitud;
	
	-- SE SACA EL ABONO TOTAL MENSUAL SUMANDO LOS VALORES DE *** deAbMenRopa + deAbMenMue + deAbMenPresPers ***
	LET deAbonMensual = deAbMenRopa + deAbMenMue + deAbMenPresPers;
	
	-- SE OBTIENE LAS OBSERVACIONES,COMPROMISOS_CAC,COMPROBANTE_VALIDO Y MONTO_SOLICITADO DE LA SOLICITUD
	SELECT a.observaciones,a.compromisos_cac,a.comprobante_valido,b.monto_solicitado,a.ingreso_cac,linea_determinada_sistema,NVL(a.revisado,'N') 
	INTO cObservaciones,deCompromisos_cac,cComprobante_val, deMontoSolic2,deIngresoValMC,deMontoSolic1,cRevisado
	FROM "informix".ss_solicitudes_cac a,
	"informix".ss_solicitudes b
	WHERE a.empresa = pEmpresa
	AND a.num_solicitud = pNumSolicitud
    AND a.num_solicitud = b.num_solicitud;
	--AND a.revisado = 'S';
	
	IF cRevisado <>'S' THEN
		LET deIngresoValMC = 0;
		LET deMontoSolic2 = 0;
	END IF;
		--IF NVL(deMontoSolic1,0) = 0 THEN 
--			LET deMontoSolic1 = deMontoSolic;
	--	END IF
	
		-- SE RETORNAN TODOS LOS VALORES OBTENIDOS 
		RETURN cCodRet, cMensajeRet, NVL(cNumSolic,""), NVL(cNumCte,""), NVL(cNombreCte,""), NVL(cRfcCte,""), NVL(cAntecBC,""), NVL(deCompMensBC,0),
		NVL(cAntecCC,""), NVL(deCompMensCC,0), NVL(cNumCteCop,""), NVL(smAntiguedad,0), NVL(cPuntualidad,""),NVL(deEficPago,0),
		NVL(deAbonMensual,0), NVL(deIngresoMen,0), NVL(deMontoSolic1,0), NVL(cObservaciones,""),NVL(deCompromisos_cac,0.00),NVL(cComprobante_val,""),NVL(cFecha_insert,""),NVL(deMontoSolic2,0),NVL(deIngresoValMC,0),NVL(dLineaCop,0), NVL(dPagoMensBco,0);

END
END PROCEDURE

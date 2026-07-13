CREATE PROCEDURE "informix".sp_reporte_cac_lineacredito(pFechaInicial CHAR(10),pFechaFinal CHAR(10))
RETURNING CHAR(6) AS cod_ret,
		  VARCHAR(80) 	 AS descripcion,
		  VARCHAR(50) 	 AS estado_sol,
		  INTEGER 		 AS grupo1,
		  DECIMAL(18,2)	 AS linprom_grupo1,
		  INTEGER 		 AS grupo2,
		  DECIMAL(18,2)	 AS linprom_grupo2,
		  INTEGER		 AS grupo3,
		  DECIMAL(18,2)	 AS linprom_grupo3,
		  INTEGER		 AS lineas_totales,
		  DECIMAL(18,2)	 AS linprom_total,
		  DECIMAL(18,2)	 AS monto_totasig;

---DECLARACIONES
DEFINE iSqlErr			        INTEGER;
DEFINE iIsamErr			        INTEGER;
DEFINE cErrorInfo		        VARCHAR(80);
DEFINE cCodRet			        CHAR(6);
DEFINE cMensajeRet		        VARCHAR(80);
DEFINE vcEstadoSol		        VARCHAR(50);
DEFINE iGrupo1 			        INTEGER;
DEFINE dLinPromGrupo1	        DECIMAL(18,2);
DEFINE iGrupo2			        INTEGER;
DEFINE dLinPromGrupo2 	        DECIMAL(18,2);
DEFINE iGrupo3 			        INTEGER;
DEFINE dlinPromGrupo3 	        DECIMAL(18,2);
DEFINE iLineasTotales 	        INTEGER;
DEFINE dLinPromTotal  	        DECIMAL(18,2);
DEFINE dMontoTotAsig  	        DECIMAL(18,2);
DEFINE cBandExitosa		        CHAR(1);
DEFINE dtFechaInsertI           DATE;
DEFINE dtFechaInsertF           DATE;
DEFINE vNumSolic                VARCHAR(20,1);
DEFINE cRevisado                CHAR(1);
DEFINE dLinCred                 DECIMAL(18,2);
DEFINE cComprobValido           CHAR(1);
DEFINE cStatusSolicCAC          CHAR(2);
DEFINE sMesesHist               SMALLINT;
DEFINE iCont_cv                 INTEGER;
DEFINE vEtiqueta_cv             VARCHAR(50);
DEFINE iNum_casos_grupo1_cv     INTEGER;
DEFINE dLinCred_grupo1_cv       DECIMAL(18,2);
DEFINE iNum_casos_grupo2_cv     INTEGER;
DEFINE dLinCred_grupo2_cv       DECIMAL(18,2);
DEFINE iNum_casos_grupo3_cv     INTEGER;
DEFINE dLinCred_grupo3_cv       DECIMAL(18,2);
DEFINE iNumRow                  INTEGER;
DEFINE dLinCredTotalAsig_cv     DECIMAL(18,2);
DEFINE iLinTotal_cv             INTEGER;
DEFINE dLinPromtotal_cv         DECIMAL(18,2);
DEFINE iCont_cnv                INTEGER;
DEFINE vEtiqueta_cnv            VARCHAR(50);
DEFINE iNum_casos_grupo1_cnv    INTEGER;
DEFINE dLinCred_grupo1_cnv      DECIMAL(18,2);
DEFINE iNum_casos_grupo2_cnv    INTEGER;
DEFINE dLinCred_grupo2_cnv      DECIMAL(18,2);
DEFINE iNum_casos_grupo3_cnv    INTEGER;
DEFINE dLinCred_grupo3_cnv      DECIMAL(18,2);
DEFINE dLinCredTotalAsig_cnv    DECIMAL(18,2);
DEFINE iLinTotal_cnv            INTEGER;
DEFINE dLinPromtotal_cnv        DECIMAL(18,2);
DEFINE iSeccion                 INTEGER;
DEFINE iGrupo                   INTEGER;
DEFINE iElemento                INTEGER;
DEFINE iCont_nci                INTEGER;
DEFINE vEtiqueta_nci            VARCHAR(50);
DEFINE iNum_casos_grupo1_nci    INTEGER;
DEFINE dLinCred_grupo1_nci      DECIMAL(18,2);
DEFINE iNum_casos_grupo2_nci    INTEGER;
DEFINE dLinCred_grupo2_nci      DECIMAL(18,2);
DEFINE iNum_casos_grupo3_nci    INTEGER;
DEFINE dLinCred_grupo3_nci      DECIMAL(18,2);
DEFINE dLinCredTotalAsig_nci    DECIMAL(18,2);
DEFINE iLinTotal_nci            INTEGER;
DEFINE dLinPromtotal_nci        DECIMAL(18,2);
DEFINE iCont_csr                INTEGER;
DEFINE vEtiqueta_csr            VARCHAR(50);
DEFINE iNum_casos_grupo1_csr    INTEGER;
DEFINE dLinCred_grupo1_csr      DECIMAL(18,2);
DEFINE iNum_casos_grupo2_csr    INTEGER;
DEFINE dLinCred_grupo2_csr      DECIMAL(18,2);
DEFINE iNum_casos_grupo3_csr    INTEGER;
DEFINE dLinCred_grupo3_csr      DECIMAL(18,2);
DEFINE dLinCredTotalAsig_csr    DECIMAL(18,2);
DEFINE iLinTotal_csr            INTEGER;
DEFINE dLinPromtotal_csr        DECIMAL(18,2);
DEFINE iBanSC                   INTEGER;
DEFINE iTotalGrupo1             INTEGER;
DEFINE iTotalGrupo2             INTEGER;
DEFINE iTotalGrupo3             INTEGER;
DEFINE iTotalGrupos             INTEGER;
DEFINE dLinPromTotalGen         DECIMAL(18,2);
DEFINE dLinCredTotalAsigGen     DECIMAL(18,2);
DEFINE dPromGpo1_cv             DECIMAL(18,2);
DEFINE dPromGpo1_cnv            DECIMAL(18,2);
DEFINE dPromGpo1_csr            DECIMAL(18,2);
DEFINE dPromGpo1_nci            DECIMAL(18,2);
DEFINE dPromGpo1_gen            DECIMAL(18,2);
DEFINE dPromGpo2_cv             DECIMAL(18,2);
DEFINE dPromGpo2_cnv            DECIMAL(18,2);
DEFINE dPromGpo2_csr            DECIMAL(18,2);
DEFINE dPromGpo2_nci            DECIMAL(18,2);
DEFINE dPromGpo2_gen            DECIMAL(18,2);
DEFINE dPromGpo3_cv             DECIMAL(18,2);
DEFINE dPromGpo3_cnv            DECIMAL(18,2);
DEFINE dPromGpo3_csr            DECIMAL(18,2);
DEFINE dPromGpo3_nci            DECIMAL(18,2);
DEFINE dPromGpo3_gen            DECIMAL(18,2);
DEFINE dPromtt_cv				DECIMAL(18,2);
DEFINE dPromtt_cnv              DECIMAL(18,2);
DEFINE dPromtt_csr              DECIMAL(18,2);
DEFINE dPromtt_nci              DECIMAL(18,2);
DEFINE dPromtt_gen              DECIMAL(18,2);
 
---INICIALIZACIONES
LET iSqlErr				     = 0;
LET iIsamErr			     = 0;
LET cErrorInfo			     = '';
LET cCodRet				     = '000000';
LET cMensajeRet			     = 'PROCESO EXITOSO';
LET vcEstadoSol			     = '';
LET iGrupo1 			     = 0;
LET dLinPromGrupo1		     = 0.0;
LET iGrupo2				     = 0;
LET dLinPromGrupo2 		     = 0.0;
LET iGrupo3 			     = 0;
LET dlinPromGrupo3 		     = 0.0;
LET iLineasTotales 		     = 0;
LET dLinPromTotal  		     = 0.0;
LET dMontoTotAsig  		     = 0.0;
LET cBandExitosa		     = 'N';
LET dtFechaInsertI           = DATE(1);
LET dtFechaInsertF           = DATE(1);
LET vNumSolic                = '';
LET cRevisado                = '';
LET dLinCred                 = 0.00;
LET cComprobValido           = '';
LET cStatusSolicCAC          = '';
LET sMesesHist               = 0;
LET iCont_cv                 = 0;
LET vEtiqueta_cv             = '   Documentos Válidos';
LET iNum_casos_grupo1_cv     = 0;
LET dLinCred_grupo1_cv       = 0.00;
LET iNum_casos_grupo2_cv     = 0;
LET dLinCred_grupo2_cv       = 0.00;
LET iNum_casos_grupo3_cv     = 0;
LET dLinCred_grupo3_cv       = 0.00;
LET iNumRow                  = 0;
LET dLinCredTotalAsig_cv     = 0.00;
LET iLinTotal_cv             = 0;
LET dLinPromtotal_cv         = 0.00;
LET iCont_cnv                = 0;
LET vEtiqueta_cnv            = '   Documentos No Válidos';
LET iNum_casos_grupo1_cnv    = 0;
LET dLinCred_grupo1_cnv      = 0.00;
LET iNum_casos_grupo2_cnv    = 0;
LET dLinCred_grupo2_cnv      = 0.00;
LET iNum_casos_grupo3_cnv    = 0;
LET dLinCred_grupo3_cnv      = 0.00;
LET dLinCredTotalAsig_cnv    = 0.00;
LET iLinTotal_cnv            = 0;
LET dLinPromtotal_cnv        = 0.00;
LET iSeccion                 = 0;
LET iGrupo                   = 0;
LET iElemento                = 0;
LET iCont_csr                = 0;
LET vEtiqueta_csr            = 'No revisados por MC por tiempo agotado';		 		 
LET iNum_casos_grupo1_csr    = 0;
LET dLinCred_grupo1_csr      = 0.00;
LET iNum_casos_grupo2_csr    = 0;
LET dLinCred_grupo2_csr      = 0.00;
LET iNum_casos_grupo3_csr    = 0;
LET dLinCred_grupo3_csr      = 0.00;
LET dLinCredTotalAsig_csr    = 0.00;
LET iLinTotal_csr            = 0;
LET dLinPromtotal_csr        = 0.00;
LET iCont_nci                = 0;
LET vEtiqueta_nci            = 'Proceso de originación Sin Comprobante de Ingresos';
LET iNum_casos_grupo1_nci    = 0;
LET dLinCred_grupo1_nci      = 0.00;
LET iNum_casos_grupo2_nci    = 0;
LET dLinCred_grupo2_nci      = 0.00;
LET iNum_casos_grupo3_nci    = 0;
LET dLinCred_grupo3_nci      = 0.00;
LET dLinCredTotalAsig_nci    = 0.00;
LET iLinTotal_nci            = 0;
LET dLinPromtotal_nci        = 0.00;
LET iBanSC                   = 0;
LET iTotalGrupo1             = 0;
LET iTotalGrupo2             = 0;
LET iTotalGrupo3             = 0;
LET iTotalGrupos             = 0;
LET dLinPromTotalGen         = 0.00;
LET dLinCredTotalAsigGen     = 0.00;
LET dPromGpo1_cv             = 0.00;
LET dPromGpo1_cnv            = 0.00;
LET dPromGpo1_csr            = 0.00;
LET dPromGpo1_nci            = 0.00;
LET dPromGpo1_gen            = 0.00;
LET dPromGpo2_cv             = 0.00;
LET dPromGpo2_cnv            = 0.00;
LET dPromGpo2_csr            = 0.00;
LET dPromGpo2_nci            = 0.00;
LET dPromGpo2_gen            = 0.00;
LET dPromGpo3_cv             = 0.00;
LET dPromGpo3_cnv            = 0.00;
LET dPromGpo3_csr            = 0.00;
LET dPromGpo3_nci            = 0.00;
LET dPromGpo3_gen            = 0.00;
LET dPromtt_cv				 = 0.00;
LET dPromtt_cnv              = 0.00;
LET dPromtt_csr              = 0.00;
LET dPromtt_nci              = 0.00;
LET dPromtt_gen              = 0.00;

BEGIN
ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
		LET cCodRet = iSqlErr;
		LET cMensajeRet = cErrorInfo;
		RETURN TRIM(cCodRet), cMensajeRet, NVL(vcEstadoSol,''), NVL(iGrupo1,0), NVL(dLinPromGrupo1,0.0), NVL(iGrupo2,0), NVL(dLinPromGrupo2,0.0), NVL(iGrupo3,0), NVL(dlinPromGrupo3,0.0), NVL(iLineasTotales,0), NVL(dLinPromTotal,0), NVL(dMontoTotAsig,0.0);
   END IF;
END EXCEPTION;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

--SET DEBUG FILE TO '/informix/paulq/sp_reporte_cac_lineacredito.out';
--TRACE OFF;

-- VALIDA QUE LOS PARAMETROS NO VENGAN VACIOS
IF NVL(pFechaInicial,'') = '' OR NVL(pFechaFinal,'') = '' THEN
	LET cCodRet = '000001';
	LET cMensajeRet = 'FALTA UNO O MAS PARAMETROS';
	RETURN TRIM(cCodRet), cMensajeRet, NVL(vcEstadoSol,''), NVL(iGrupo1,0), NVL(dLinPromGrupo1,0.0), NVL(iGrupo2,0), NVL(dLinPromGrupo2,0.0), NVL(iGrupo3,0), NVL(dlinPromGrupo3,0.0), NVL(iLineasTotales,0), NVL(dLinPromTotal,0), NVL(dMontoTotAsig,0.0);
END IF;	

IF pFechaInicial > pFechaFinal THEN
	LET cCodRet = '000002';
	LET cMensajeRet = 'LA FECHA INICIAL ES MAYOR A LA FECHA FINAL';
	RETURN TRIM(cCodRet), cMensajeRet, NVL(vcEstadoSol,''), NVL(iGrupo1,0), NVL(dLinPromGrupo1,0.0), NVL(iGrupo2,0), NVL(dLinPromGrupo2,0.0), NVL(iGrupo3,0), NVL(dlinPromGrupo3,0.0), NVL(iLineasTotales,0), NVL(dLinPromTotal,0), NVL(dMontoTotAsig,0.0);
END IF;

-- SE INICIALIZA LA TABLA TEMPORAL FIJA DEL REPORTE GENERAL DEL CAC
DELETE FROM "informix".tmp_rlc_reportelincred;

LET dtFechaInsertI = pFechaInicial::DATE;
LET dtFechaInsertF = pFechaFinal::DATE;

FOREACH WITH HOLD

	SELECT a.num_solicitud, a.revisado, a.linea_determinada_sistema, a.comprobante_valido, a.status, c.meses_historia
      INTO vNumSolic, cRevisado, dLinCred, cComprobValido, cStatusSolicCAC, sMesesHist
	  FROM "informix".ss_solicitudes_cac a,
		   "informix".ss_solicitudes b,
           "informix".ss_resum_scor_fin c
     WHERE a.empresa = b.empresa
	   AND a.num_solicitud = b.num_solicitud
       AND c.empresa = a.empresa
       AND c.num_solicitud = a.num_solicitud
	   AND a.status IN ('AT') --AAME INC 27 023 19-08-2013 OBSv.4 Se solicita que se contabilicen las solicitudes atendidas y aperturadas.
	   AND a.fecha_insert >= dtFechaInsertI AND a.fecha_insert <= dtFechaInsertF	  
	  
		SELECT 1
		  INTO iBanSC
		  FROM "informix".ss_detalle_scoring
		 WHERE num_solicitud = vNumSolic
		   AND seccion = 2
		   AND grupo = 14
		   AND elemento = 3;
		 
		 IF iBanSC IS NULL THEN LET iBanSC = 0; END IF;

	  -- OBTIENE LOS REVISADOS CAC CON DOCUMENTOS VALIDOS
	  IF NVL(cRevisado,'') = 'S' AND NVL(cComprobValido,'') = 'S' THEN
		 LET iCont_cv = iCont_cv + 1;
		 IF sMesesHist >= 13 THEN
			LET iNum_casos_grupo1_cv = iNum_casos_grupo1_cv + 1;
			LET dLinCred_grupo1_cv = dLinCred_grupo1_cv + dLinCred;
		 ELIF sMesesHist >= 6 AND sMesesHist < 13 THEN
			LET iNum_casos_grupo2_cv = iNum_casos_grupo2_cv + 1;
			LET dLinCred_grupo2_cv = dLinCred_grupo2_cv + dLinCred;
		 ELIF sMesesHist < 6 THEN
			LET iNum_casos_grupo3_cv = iNum_casos_grupo3_cv + 1;
			LET dLinCred_grupo3_cv = dLinCred_grupo3_cv + dLinCred;
		 END IF		 
	  END IF
	  
	  -- OBTIENE LAS SOLICITUDES REVISADOS CAC CON DOCUMENTOS NO VALIDOS
	  IF NVL(cRevisado,'') = 'S' AND NVL(cComprobValido,'') = 'N' THEN
		 LET iCont_cnv = iCont_cnv + 1;
		 IF sMesesHist >= 13 THEN
			LET iNum_casos_grupo1_cnv = iNum_casos_grupo1_cnv + 1;
			LET dLinCred_grupo1_cnv = dLinCred_grupo1_cnv + dLinCred;
		 ELIF sMesesHist >= 6 AND sMesesHist < 13 THEN
			LET iNum_casos_grupo2_cnv = iNum_casos_grupo2_cnv + 1;
			LET dLinCred_grupo2_cnv = dLinCred_grupo2_cnv + dLinCred;
		 ELIF sMesesHist < 6 THEN
			LET iNum_casos_grupo3_cnv = iNum_casos_grupo3_cnv + 1;
			LET dLinCred_grupo3_cnv = dLinCred_grupo3_cnv + dLinCred;
		 END IF		 
	  END IF
	  
      -- OBTIENE LAS SOLICITUDES SIN REVISAR
	  IF NVL(cRevisado,'') = 'N' THEN
		 LET iCont_csr = iCont_csr + 1;
		 IF sMesesHist >= 13 THEN
			LET iNum_casos_grupo1_csr = iNum_casos_grupo1_csr + 1;
			LET dLinCred_grupo1_csr = dLinCred_grupo1_csr + dLinCred;
		 ELIF sMesesHist >= 6 AND sMesesHist < 13 THEN
			LET iNum_casos_grupo2_csr = iNum_casos_grupo2_csr + 1;
			LET dLinCred_grupo2_csr = dLinCred_grupo2_csr + dLinCred;
		 ELIF sMesesHist < 6 THEN
			LET iNum_casos_grupo3_csr = iNum_casos_grupo3_csr + 1;
			LET dLinCred_grupo3_csr = dLinCred_grupo3_csr + dLinCred;
		 END IF		 
	  END IF
	  
	  -- OBTIENE LAS SOLICITUDES SIN COMPROBANTE DE INGRESOS
	  IF iBanSC = 1 THEN
		 LET iCont_nci = iCont_nci + 1;
		 IF sMesesHist >= 13 THEN
			LET iNum_casos_grupo1_nci = iNum_casos_grupo1_nci + 1;
			LET dLinCred_grupo1_nci = dLinCred_grupo1_nci + dLinCred;
		 ELIF sMesesHist >= 6 AND sMesesHist < 13 THEN
			LET iNum_casos_grupo2_nci = iNum_casos_grupo2_nci + 1;
			LET dLinCred_grupo2_nci = dLinCred_grupo2_nci + dLinCred;
		 ELIF sMesesHist < 6 THEN
			LET iNum_casos_grupo3_nci = iNum_casos_grupo3_nci + 1;
			LET dLinCred_grupo3_nci = dLinCred_grupo3_nci + dLinCred;
		 END IF		  
	  END IF
	  
END FOREACH;

LET iNumRow = dbinfo("sqlca.sqlerrd2");
IF  iNumRow > 0 THEN

	LET iTotalGrupo1 = iNum_casos_grupo1_cv + iNum_casos_grupo1_cnv + iNum_casos_grupo1_csr + iNum_casos_grupo1_nci;
	LET iTotalGrupo2 = iNum_casos_grupo2_cv + iNum_casos_grupo2_cnv + iNum_casos_grupo2_csr + iNum_casos_grupo2_nci;
	LET iTotalGrupo3 = iNum_casos_grupo3_cv + iNum_casos_grupo3_cnv + iNum_casos_grupo3_csr + iNum_casos_grupo3_nci;
	LET iTotalGrupos = iTotalGrupo1 + iTotalGrupo2 + iTotalGrupo3;
	
	LET dLinCredTotalAsig_cv = dLinCred_grupo1_cv + dLinCred_grupo2_cv + dLinCred_grupo3_cv;
	LET dLinCredTotalAsig_cnv = dLinCred_grupo1_cnv + dLinCred_grupo2_cnv + dLinCred_grupo3_cnv;
	LET dLinCredTotalAsig_csr = dLinCred_grupo1_csr + dLinCred_grupo2_csr + dLinCred_grupo3_csr;
	LET dLinCredTotalAsig_nci = dLinCred_grupo1_nci + dLinCred_grupo2_nci + dLinCred_grupo3_nci;
	LET dLinCredTotalAsigGen = dLinCredTotalAsig_cv + dLinCredTotalAsig_cnv + dLinCredTotalAsig_csr + dLinCredTotalAsig_nci;	
	
	LET iLinTotal_cv  = iNum_casos_grupo1_cv+ iNum_casos_grupo2_cv + iNum_casos_grupo3_cv;
	LET iLinTotal_cnv = iNum_casos_grupo1_cnv+ iNum_casos_grupo2_cnv + iNum_casos_grupo3_cnv;
	LET iLinTotal_csr = iNum_casos_grupo1_csr+ iNum_casos_grupo2_csr + iNum_casos_grupo3_csr;
	LET iLinTotal_nci = iNum_casos_grupo1_nci + iNum_casos_grupo2_nci + iNum_casos_grupo3_nci;
	
	LET dLinPromtotal_cv = CASE WHEN iLinTotal_cv > 0 THEN dLinCredTotalAsig_cv/iLinTotal_cv ELSE 0 END;
	LET dLinPromtotal_cnv = CASE WHEN iLinTotal_cnv > 0 THEN dLinCredTotalAsig_cnv/iLinTotal_cnv ELSE 0 END;
	LET dLinPromtotal_csr = CASE WHEN iLinTotal_csr > 0 THEN dLinCredTotalAsig_csr/iLinTotal_csr ELSE 0 END;
	LET dLinPromtotal_nci = CASE WHEN iLinTotal_nci > 0 THEN dLinCredTotalAsig_nci/iLinTotal_nci ELSE 0 END;
	
	LET dLinCred_grupo1_cv = CASE WHEN iNum_casos_grupo1_cv > 0 THEN dLinCred_grupo1_cv / iNum_casos_grupo1_cv ELSE 0 END;
	LET dLinCred_grupo2_cv = CASE WHEN iNum_casos_grupo2_cv > 0 THEN dLinCred_grupo2_cv / iNum_casos_grupo2_cv ELSE 0 END;
	LET dLinCred_grupo3_cv = CASE WHEN iNum_casos_grupo3_cv > 0 THEN dLinCred_grupo3_cv / iNum_casos_grupo3_cv ELSE 0 END;
	LET dLinCred_grupo1_cnv = CASE WHEN iNum_casos_grupo1_cnv > 0 THEN dLinCred_grupo1_cnv / iNum_casos_grupo1_cnv ELSE 0 END;
	LET dLinCred_grupo2_cnv = CASE WHEN iNum_casos_grupo2_cnv > 0 THEN dLinCred_grupo2_cnv / iNum_casos_grupo2_cnv ELSE 0 END;
	LET dLinCred_grupo3_cnv = CASE WHEN iNum_casos_grupo3_cnv > 0 THEN dLinCred_grupo3_cnv / iNum_casos_grupo3_cnv ELSE 0 END;
	LET dLinCred_grupo1_csr = CASE WHEN iNum_casos_grupo1_csr > 0 THEN dLinCred_grupo1_csr / iNum_casos_grupo1_csr ELSE 0 END;
	LET dLinCred_grupo2_csr = CASE WHEN iNum_casos_grupo2_csr > 0 THEN dLinCred_grupo2_csr / iNum_casos_grupo2_csr ELSE 0 END;
	LET dLinCred_grupo3_csr = CASE WHEN iNum_casos_grupo3_csr > 0 THEN dLinCred_grupo3_csr / iNum_casos_grupo3_csr ELSE 0 END;
	LET dLinCred_grupo1_nci = CASE WHEN iNum_casos_grupo1_nci > 0 THEN dLinCred_grupo1_nci / iNum_casos_grupo1_nci ELSE 0 END;
	LET dLinCred_grupo2_nci = CASE WHEN iNum_casos_grupo2_nci > 0 THEN dLinCred_grupo2_nci / iNum_casos_grupo2_nci ELSE 0 END;
	LET dLinCred_grupo3_nci = CASE WHEN iNum_casos_grupo3_nci > 0 THEN dLinCred_grupo3_nci / iNum_casos_grupo3_nci ELSE 0 END;
	
	LET dPromGpo1_cv = CASE WHEN iTotalGrupo1 > 0 THEN (iNum_casos_grupo1_cv * dLinCred_grupo1_cv) / iTotalGrupo1 ELSE 0 END;
	LET dPromGpo1_cnv = CASE WHEN iTotalGrupo1 > 0 THEN (iNum_casos_grupo1_cnv * dLinCred_grupo1_cnv) / iTotalGrupo1 ELSE 0 END;
	LET dPromGpo1_csr = CASE WHEN iTotalGrupo1 > 0 THEN (iNum_casos_grupo1_csr * dLinCred_grupo1_csr) / iTotalGrupo1 ELSE 0 END;
	LET dPromGpo1_nci = CASE WHEN iTotalGrupo1 > 0 THEN (iNum_casos_grupo1_nci * dLinCred_grupo1_nci) / iTotalGrupo1 ELSE 0 END;
	LET dPromGpo1_gen = dPromGpo1_cv + dPromGpo1_cnv + dPromGpo1_csr + dPromGpo1_nci;
	
	LET dPromGpo2_cv = CASE WHEN iTotalGrupo2 > 0 THEN (iNum_casos_grupo2_cv * dLinCred_grupo2_cv) / iTotalGrupo2 ELSE 0 END;
	LET dPromGpo2_cnv = CASE WHEN iTotalGrupo2 > 0 THEN (iNum_casos_grupo2_cnv * dLinCred_grupo2_cnv) / iTotalGrupo2 ELSE 0 END;
	LET dPromGpo2_csr = CASE WHEN iTotalGrupo2 > 0 THEN (iNum_casos_grupo2_csr * dLinCred_grupo2_csr) / iTotalGrupo2 ELSE 0 END;
	LET dPromGpo2_nci = CASE WHEN iTotalGrupo2 > 0 THEN (iNum_casos_grupo2_nci * dLinCred_grupo2_nci) / iTotalGrupo2 ELSE 0 END;
	LET dPromGpo2_gen = dPromGpo2_cv + dPromGpo2_cnv + dPromGpo2_csr + dPromGpo2_nci;
	
	LET dPromGpo3_cv = CASE WHEN iTotalGrupo3 > 0 THEN (iNum_casos_grupo3_cv * dLinCred_grupo3_cv) / iTotalGrupo3 ELSE 0 END;
	LET dPromGpo3_cnv = CASE WHEN iTotalGrupo3 > 0 THEN (iNum_casos_grupo3_cnv * dLinCred_grupo3_cnv) / iTotalGrupo3 ELSE 0 END;
	LET dPromGpo3_csr = CASE WHEN iTotalGrupo3 > 0 THEN (iNum_casos_grupo3_csr * dLinCred_grupo3_csr) / iTotalGrupo3 ELSE 0 END;
	LET dPromGpo3_nci = CASE WHEN iTotalGrupo3 > 0 THEN (iNum_casos_grupo3_nci * dLinCred_grupo3_nci) / iTotalGrupo3 ELSE 0 END;
	LET dPromGpo3_gen = dPromGpo3_cv + dPromGpo3_cnv + dPromGpo3_csr + dPromGpo3_nci;	
	
    LET dPromtt_cv  = CASE WHEN iTotalGrupos > 0 THEN (dLinPromtotal_cv * iLinTotal_cv) / iTotalGrupos ELSE 0 END;
	LET dPromtt_cnv = CASE WHEN iTotalGrupos > 0 THEN (dLinPromtotal_cnv * iLinTotal_cnv) / iTotalGrupos ELSE 0 END;
    LET dPromtt_csr = CASE WHEN iTotalGrupos > 0 THEN (dLinPromtotal_csr * iLinTotal_csr) / iTotalGrupos ELSE 0 END;
	LET dPromtt_nci = CASE WHEN iTotalGrupos > 0 THEN (dLinPromtotal_nci * iLinTotal_nci) / iTotalGrupos ELSE 0 END;	
	LET dPromtt_gen = dPromtt_cv + dPromtt_cnv + dPromtt_csr + dPromtt_nci;
	
	INSERT INTO "informix".tmp_rlc_reportelincred 
	VALUES ('Revisados MC',iTotalGrupo1,dPromGpo1_gen,iTotalGrupo2,dPromGpo2_gen,iTotalGrupo3,dPromGpo3_gen,iTotalGrupos,dPromtt_gen,dLinCredTotalAsigGen);
	
	INSERT INTO "informix".tmp_rlc_reportelincred VALUES(vEtiqueta_cv,iNum_casos_grupo1_cv, dLinCred_grupo1_cv,	iNum_casos_grupo2_cv, dLinCred_grupo2_cv, 
	iNum_casos_grupo3_cv, dLinCred_grupo3_cv,iLinTotal_cv, dLinPromtotal_cv, dLinCredTotalAsig_cv);  
	
	INSERT INTO "informix".tmp_rlc_reportelincred VALUES(vEtiqueta_cnv,iNum_casos_grupo1_cnv, dLinCred_grupo1_cnv,	iNum_casos_grupo2_cnv, dLinCred_grupo2_cnv, 
	iNum_casos_grupo3_cnv, dLinCred_grupo3_cnv,iLinTotal_cnv, dLinPromtotal_cnv, dLinCredTotalAsig_cnv);  
	
	INSERT INTO "informix".tmp_rlc_reportelincred VALUES(vEtiqueta_csr,iNum_casos_grupo1_csr, dLinCred_grupo1_csr,	iNum_casos_grupo2_csr, dLinCred_grupo2_csr, 
	iNum_casos_grupo3_csr, dLinCred_grupo3_csr,iLinTotal_csr, dLinPromtotal_csr, dLinCredTotalAsig_csr);  
	
	INSERT INTO "informix".tmp_rlc_reportelincred VALUES(vEtiqueta_nci,iNum_casos_grupo1_nci, dLinCred_grupo1_nci, iNum_casos_grupo2_nci, dLinCred_grupo2_nci, 
	iNum_casos_grupo3_nci, dLinCred_grupo3_nci, iLinTotal_nci, dLinPromtotal_nci, dLinCredTotalAsig_nci);  
	
	INSERT INTO "informix".tmp_rlc_reportelincred VALUES('TOTAL',iTotalGrupo1,dPromGpo1_gen,iTotalGrupo2,dPromGpo2_gen,iTotalGrupo3,dPromGpo3_gen,iTotalGrupos,dPromtt_gen,dLinCredTotalAsigGen);  
	
	-- OBTIENE EL REPORTE		
	FOREACH WITH HOLD
		SELECT estado_sol, grupo1, linprom_grupo1, grupo2, linprom_grupo2, grupo3, linprom_grupo3, lineas_totales, linprom_total, monto_totasig
		INTO vcEstadoSol, iGrupo1, dLinPromGrupo1, iGrupo2, dLinPromGrupo2, iGrupo3, dlinPromGrupo3, iLineasTotales, dLinPromTotal, dMontoTotAsig
		FROM "informix".tmp_rlc_reportelincred

		RETURN TRIM(cCodRet), cMensajeRet, NVL(vcEstadoSol,''), NVL(iGrupo1,0), NVL(dLinPromGrupo1,0.0), NVL(iGrupo2,0), NVL(dLinPromGrupo2,0.0), NVL(iGrupo3,0), NVL(dlinPromGrupo3,0.0), NVL(iLineasTotales,0), NVL(dLinPromTotal,0), NVL(dMontoTotAsig,0.0) WITH RESUME;
	END FOREACH
	
ELSE
	LET cCodRet = '000003';
	LET cMensajeRet = 'NO HAY DATOS PARA ESTE REPORTE, VERIFICAR FECHAS';
	RETURN TRIM(cCodRet), cMensajeRet, NVL(vcEstadoSol,''), NVL(iGrupo1,0), NVL(dLinPromGrupo1,0.0), NVL(iGrupo2,0), NVL(dLinPromGrupo2,0.0), NVL(iGrupo3,0), NVL(dlinPromGrupo3,0.0), NVL(iLineasTotales,0), NVL(dLinPromTotal,0), NVL(dMontoTotAsig,0.0);
END IF;

END;
END PROCEDURE

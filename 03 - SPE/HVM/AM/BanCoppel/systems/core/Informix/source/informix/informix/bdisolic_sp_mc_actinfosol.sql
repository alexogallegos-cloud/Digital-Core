CREATE PROCEDURE "informix".sp_mc_actinfosol (pEmpresa CHAR (3),pNumSol CHAR (20),pNumcte CHAR (20),pNumcteRef CHAR (20))
RETURNING
	CHAR(6) AS COD_RET,
	CHAR(80) AS DESCRIPCION; 

---DECLARACIONES
DEFINE iSqlErr			INTEGER;
DEFINE iIsamErr			INTEGER;
DEFINE iSecuencia       INTEGER;
DEFINE cErrorInfo		CHAR(80);
DEFINE cCodRet			CHAR(6);
DEFINE cMensajeRet		CHAR(80);

DEFINE dEficiencia DECIMAL(5,2);
DEFINE cSitespecial CHAR(2); 
DEFINE iMesesHist  INTEGER;
DEFINE iLimitecredito   INTEGER;
DEFINE iCausa  INTEGER;
DEFINE iPuntualidad  CHAR(3);
DEFINE iSdoropa   INTEGER;
DEFINE iSdomuebles  INTEGER;
DEFINE iSdoprestamos  INTEGER; 
DEFINE iVdoropa  INTEGER; 
DEFINE iVdomuebles  INTEGER; 
DEFINE iVdoprestamos  INTEGER; 
DEFINE iAbonomesropa  INTEGER; 
DEFINE iAbonomesmuebles  INTEGER; 
DEFINE iAbonomesprestamos  INTEGER; 
DEFINE dtFecha_ult_compra  DATE;   
DEFINE cFecha  CHAR(10);  
DEFINE iSdotiempoaire   INTEGER;
DEFINE iSdonegociosafi  INTEGER;
DEFINE iSdotiemporeestruc  INTEGER; 
DEFINE iVdotiempoaire  INTEGER; 
DEFINE iVdonegociosafi  INTEGER; 
DEFINE iVdotiemporeestruc  INTEGER; 
DEFINE iAbonomestiempoaire  INTEGER; 
DEFINE iAbonomesnegociosafi  INTEGER; 
DEFINE iAbonomestiemporeestruc  INTEGER; 

DEFINE ptipogrupo   CHAR(2); 
DEFINE phit 		CHAR(6);
   
---INICIALIZACIONES
LET iSqlErr				= 0;
LET iIsamErr			= 0;
LET iSecuencia			= 0;
LET cErrorInfo			= '';
LET cCodRet				= '000000';
LET cMensajeRet			= 'Proceso Exitoso';
    
LET dEficiencia = 0;
LET cSitespecial  = ""; 
LET iMesesHist  = 0;
LET iLimitecredito   = 0;
LET iCausa  = 0;
LET iPuntualidad  = "";
LET iSdoropa   = 0;
LET iSdomuebles  = 0;
LET iSdoprestamos  = 0; 
LET iVdoropa  = 0; 
LET iVdomuebles  = 0; 
LET iVdoprestamos  = 0; 
LET iAbonomesropa  = 0; 
LET iAbonomesmuebles  = 0; 
LET iAbonomesprestamos  = 0; 
LET dtFecha_ult_compra  = "";
LET cFecha    = "";
LET ptipogrupo = '';
LET phit  = '';
LET iSdotiempoaire   = 0;
LET iSdonegociosafi  = 0;
LET iSdotiemporeestruc  = 0;
LET iVdotiempoaire  = 0; 
LET iVdonegociosafi  = 0; 
LET iVdotiemporeestruc  = 0; 
LET iAbonomestiempoaire  = 0; 
LET iAbonomesnegociosafi  = 0; 
LET iAbonomestiemporeestruc  = 0; 


BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
          LET cCodRet = iSqlErr;
          LET cMensajeRet = cErrorInfo;
          RETURN cCodRet, cMensajeRet;
       END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
--	SET DEBUG FILE TO "/informix/jesus/sp_mc_actinfosol.out";
--	TRACE ON;
	
	IF NVL(pEmpresa,"") = "" AND NVL(pNumSol,"") = "" THEN
	  LET cCodRet = "000001";
	  LET cMensajeRet = "PARAMETROS DE ENTRADA INVALIDOS.";
	  
	ELSE
      IF NVL(pNumCteRef,"") <> "" THEN
	  --limitecredito Se cambia por creditoaut
		SELECT  eficiencia,sitespecial, meseshist,creditoaut,causa,puntualidad,
			sdoropa,sdomuebles,sdoprestamos, vdoropa,vdomuebles,vdoprestamos,     
			abonomesropa, abonomesmuebles, abonomesprestamos, fecha_ult_compra,
            sdotiempoaire,sdonegociosafi,sdotiemporeestruc,vdotiempoaire,vdonegociosafi,vdotiemporeestruc,
            abonomestiempoaire,abonomesnegociosafi,abonomestiemporeestruc
			INTO dEficiencia,cSitespecial, iMesesHist, iLimitecredito , iCausa,iPuntualidad,
			iSdoropa ,iSdomuebles,iSdoprestamos, iVdoropa, iVdomuebles, iVdoprestamos, 
			iAbonomesropa, iAbonomesmuebles, iAbonomesprestamos, cFecha,
            iSdotiempoaire,iSdonegociosafi,iSdotiemporeestruc,iVdotiempoaire,iVdonegociosafi,iVdotiemporeestruc,
            iAbonomestiempoaire,iAbonomesnegociosafi,iAbonomestiemporeestruc
		FROM "informix".ss_respuesta_conscoppel    
		WHERE numcte = pNumCte
		AND numcte_ref = pNumCteRef;
		
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			RETURN cCodRet, cMensajeRet;
		END IF;
		
		
      END IF;
	
--	LET cFecha=SUBSTR(cFecha,6,2)||"-"||SUBSTR(cFecha,9,2) ||"-"|| SUBSTR(cFecha,1,4);
	--LET dtFecha_ult_compra = cFecha::DATE;

	  --se actualiza informaciÃÂ³n de la solicitud de coppel.
	  UPDATE "informix".ss_resum_scor_fin
		SET situacion_pago = dEficiencia,
		situacion_credito = cSitespecial,
		meses_historia = iMesesHist,
		linea_tienda = iLimitecredito, 
		causa   = iCausa,
		puntualidad = iPuntualidad, 
		saldoropa =  iSdoropa, 
		saldomuebles = iSdomuebles, 
		saldoprestamos = iSdoprestamos, 
		vencidoropa = iVdoropa,
		vencidomuebles = iVdomuebles, 
		vencidoprestamos = iVdoprestamos, 
		abonomensualropa = iAbonomesropa, 
		abonomensualmuebles = iAbonomesmuebles,
		abonomensualprestamos= iAbonomesprestamos,
		fecha_ultima_compra = dtFecha_ult_compra,
        saldototalaire=iSdotiempoaire,
        saldototalafiliados=iSdonegociosafi,
        saldototalreestructura=iSdotiemporeestruc,
        vencidototalaire=iVdotiempoaire,
        vencidototalafiliados=iVdonegociosafi,
        vencidototalreestructura=iVdotiemporeestruc,
        abonomensualaire=iAbonomestiempoaire,
        abonomensualafiliados=iAbonomesnegociosafi,
        abonomensualreestructura =iAbonomestiemporeestruc
		--grupo = case when iMesesHist > 0 THEN '' ELSE grupo END 		
      WHERE empresa = pEmpresa AND num_solicitud = pNumSol;
                   
      -- Actualiza informacion de auditoria para cnbv, para la solicitud modificada.
      UPDATE "informix".ss_revision_determinacion
		SET situacion_pago = dEficiencia, situacion_credito = cSitespecial, meses_historia = iMesesHist, linea_tienda = iLimitecredito, 
		saldoropa =  iSdoropa, saldomuebles = iSdomuebles, saldoprestamo = iSdoprestamos, vencidoropa = iVdoropa,
		vencidomuebles = iVdomuebles, vencidoprestamos = iVdoprestamos, abonomensualropa = iAbonomesropa, abonomensualmuebles = iAbonomesmuebles,
		abonomensualprestamos= iAbonomesprestamos,
        saldototalaire=iSdotiempoaire,
        saldototalafiliados=iSdonegociosafi,
        saldototalreestructura=iSdotiemporeestruc,
        vencidototalaire=iVdotiempoaire,
        vencidototalafiliados=iVdonegociosafi,
        vencidototalreestructura=iVdotiemporeestruc,
        abonomensualaire=iAbonomestiempoaire,
        abonomensualafiliados=iAbonomesnegociosafi,
        abonomensualreestructura =iAbonomestiemporeestruc
	  WHERE empresa = pEmpresa AND num_solicitud = pNumSol;

      CALL bdisolic:"informix".sp_obtienegrupo (pNumSol)RETURNING cCodRet,ptipogrupo,phit;

	END IF;
	
	RETURN cCodRet, cMensajeRet;
END
END PROCEDURE

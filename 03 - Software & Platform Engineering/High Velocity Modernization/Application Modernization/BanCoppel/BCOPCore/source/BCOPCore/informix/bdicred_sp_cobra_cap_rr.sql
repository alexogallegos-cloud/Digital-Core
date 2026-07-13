CREATE PROCEDURE "informix".sp_cobra_cap_rr(pFechaCuota DATE,pPagoCapitalM DECIMAL(18,2),pCapitalStatus CHAR(1),dStatusCred char(2))
   RETURNING CHAR(6)  AS codigo_ret,
             CHAR(80) AS mensaje;

DEFINE iSqlErr               INTEGER;
DEFINE iIsamErr              INTEGER;
DEFINE cErrorInfo            CHAR(100);
DEFINE cCodRet               CHAR(6);
DEFINE cMensajeRet           CHAR(80);

--Modifico: Roque Solis
--Fechas: 2010/01/18
--Modificacion: Se agrego la reduccion a los campos monto_financiado y se comento la
--              actualizaciÃ³n al campo sdo_capital.

-- Modifico: Paul Ivan Quintero Varela
-- Fecha: 2010/01/20
-- Comentario: Se agrega la actualizaciÃ³n del campo capital_status_ant

DEFINE GLOBAL g_Empresa              CHAR(3)        DEFAULT "";
DEFINE GLOBAL g_NumCred              CHAR(20)       DEFAULT "";
DEFINE GLOBAL g_NumProd              CHAR(4)        DEFAULT "";
DEFINE GLOBAL g_CodFun               CHAR(3)        DEFAULT "";
DEFINE GLOBAL g_dtFechaHoy           DATE           DEFAULT "";
DEFINE GLOBAL g_Folio                CHAR(16)       DEFAULT "";
DEFINE GLOBAL g_Sucursal             CHAR(4)        DEFAULT "";
DEFINE GLOBAL g_Divisa               CHAR(2)        DEFAULT "";
DEFINE GLOBAL g_TransaccSuc          CHAR(4)        DEFAULT "";
DEFINE GLOBAL g_NumPago              CHAR(40)       DEFAULT "";
DEFINE GLOBAL dStatusCred            CHAR(2)        DEFAULT "";

DEFINE dCodRef               INTEGER;
DEFINE BanderaIFRS           CHAR(1);

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
          LET cCodRet= iSqlErr;
          LET cMensajeRet= cErrorInfo;
       RETURN cCodRet,cMensajeRet;
   END IF;
END EXCEPTION;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

LET iSqlErr               = 0;
LET iIsamErr              = 0;
LET cErrorInfo            = "";
LET cCodRet               = "000000";
LET cMensajeRet           = "Se realizÃ³ el calculo correctamente";

LET dCodRef               = 0;
LET BanderaIFRS           = '';

--SET DEBUG FILE TO "/tmp/sp_cobra_cap_vdo_pp.out";
--TRACE ON;

 select NVL(valor,'I')
   INTO BanderaIFRS 
   from "informix".sd_param 
   WHERE empresa = '001' 
      AND cod_param='700'; 

   IF (dStatusCred='AA' OR dStatusCred='BA' OR dStatusCred='BT' or (BanderaIFRS='I' and dStatusCred='VP')) THEN

      IF pCapitalStatus = "1" THEN
         LET dCodRef = 11;     --> FMV : PAGO DE CAPITAL VIGENTE EN CARGO A CUENTA
      ELIF pCapitalStatus = "7" THEN
         LET dCodRef = 2;   --> FMV : PAGO DE CAPITAL TRANSITORIO CON CARGO EN CUENTA
      ELIF pCapitalStatus = "2" THEN
         LET dCodRef = 9;   -->  FMV : PAGO DE CAPITAL VENCIDO EXIGIBLE CON CARGO A CTA
      ELIF pCapitalStatus = "6" THEN
         LET dCodRef = 309;   -->  FMV : PAGO DE CAPITAL A E3 CON CARGO A CTA --AEH
      END IF;

   ELIF (dStatusCred='E1' OR dStatusCred='E2' OR dStatusCred='E3' OR (BanderaIFRS='A' and dStatusCred='VP')) THEN

      IF pCapitalStatus = "1" THEN
         LET dCodRef = 1106;
      ELIF (pCapitalStatus = "7" AND dStatusCred='E1') THEN
         LET dCodRef = 1107;
      ELIF (pCapitalStatus = "7" AND dStatusCred='E2') THEN
         LET dCodRef = 1108;
      ELIF pCapitalStatus = "2" THEN 
         LET dCodRef = 1108;
      ELIF (pCapitalStatus = "6" AND dStatusCred='E2') THEN 
         LET dCodRef = 1108;
      ELIF (pCapitalStatus = "6" AND (dStatusCred='E3' OR dStatusCred='VP')) THEN 
         LET dCodRef = 1109;
      END IF;
   
   END IF;


    IF dStatusCred = 'VP' THEN
         IF (dStatusCred='AA' OR dStatusCred='BA' OR dStatusCred='BT' OR (BanderaIFRS='I' and dStatusCred='VP')) THEN
            IF pCapitalStatus = "1" THEN
               LET dCodRef = 36;   --> FMV: PAGO DE CAPITAL VENCIDO EXIGIBLE CON CARGO EN CTA.
               LET pCapitalStatus = "6";
            END IF;
         ELIF (dStatusCred='E1' OR dStatusCred='E2' OR dStatusCred='E3' OR (BanderaIFRS='A' and dStatusCred='VP')) THEN
            IF pCapitalStatus = "1" THEN
               LET dCodRef = 1118;   --> FMV: PAGO DE CAPITAL VENCIDO EXIGIBLE CON CARGO EN CTA.
               LET pCapitalStatus = "16";
            END IF;
         END IF;
    END IF;



    IF pPagoCapitalM > 0 THEN

      IF (dStatusCred='AA' OR dStatusCred='BA' OR dStatusCred='BT' OR (BanderaIFRS='I' and dStatusCred='VP')) THEN

        UPDATE "informix".sd_maesdoscrd
           SET sdo_cap_insoluto = sdo_cap_insoluto - pPagoCapitalM,
               sdo_capital = (CASE WHEN pCapitalStatus = "1" THEN (sdo_capital - pPagoCapitalM) ELSE sdo_capital END),
               monto_vencido    = (CASE WHEN pCapitalStatus = "7" THEN (monto_vencido - pPagoCapitalM)  ELSE monto_vencido END),
               mto_venc_trasp   = (CASE WHEN pCapitalStatus = "2" THEN (mto_venc_trasp - pPagoCapitalM) ELSE mto_venc_trasp END),
               cap_tras_no_venci   = (CASE WHEN pCapitalStatus = "6" THEN (cap_tras_no_venci - pPagoCapitalM) ELSE cap_tras_no_venci END),
               monto_financiado = monto_financiado - pPagoCapitalM
         WHERE empresa          = g_Empresa
           AND num_credito      = g_NumCred;

      ELIF (dStatusCred='E1' OR dStatusCred='E2' OR dStatusCred='E3' OR (BanderaIFRS='A' and dStatusCred='VP')) THEN
         
         UPDATE "informix".sd_maesdoscrd
           SET sdo_cap_insoluto = sdo_cap_insoluto - pPagoCapitalM,
               sdo_capital = (CASE WHEN pCapitalStatus in ('1','16') THEN (sdo_capital - pPagoCapitalM) ELSE sdo_capital END),
               monto_vencido    = (CASE WHEN pCapitalStatus in ('7','2','6') THEN (monto_vencido - pPagoCapitalM)  ELSE monto_vencido END),
               monto_financiado = monto_financiado - pPagoCapitalM
         WHERE empresa          = g_Empresa
           AND num_credito      = g_NumCred;
      
      END IF;

         UPDATE "informix".sd_amortiza_creditocrd
            SET capital_pagado     = capital_pagado + pPagoCapitalM,
                capital_fecha_pago = g_dtFechaHoy,
                capital_status_ant = (CASE WHEN ((capital_pagado + pPagoCapitalM) >= capital_debe) THEN capital_status ELSE capital_status_ant END),
                capital_status     = (CASE WHEN ((capital_pagado + pPagoCapitalM) >= capital_debe) THEN "5" ELSE capital_status END)
          WHERE empresa            = g_Empresa
            AND num_credito        = g_NumCred
            AND fecha_cuota        = pFechaCuota;

		IF g_TransaccSuc ='9888' AND (dCodRef = 11 OR dCodRef =1106 OR dCodRef =36) THEN
			    LET dCodRef	= '33';
			ELIF g_TransaccSuc ='4320' AND (dCodRef = 11 OR dCodRef =1106 OR dCodRef =36) THEN
			    LET dCodRef	= '90';
			ELIF g_TransaccSuc ='9888' AND (dCodRef = 2 OR dCodRef =1107 OR dCodRef = 9) THEN
				LET dCodRef	= '34';
			ELIF g_TransaccSuc ='4320' AND (dCodRef = 2 OR dCodRef =1107 OR dCodRef = 9) THEN
				LET dCodRef	= '91';
			ELIF g_TransaccSuc ='9888' AND dCodRef =1108 THEN
				LET dCodRef	= '36';
			ELIF g_TransaccSuc ='4320' AND dCodRef =1108 THEN
				LET dCodRef	= '93';
			ELIF g_TransaccSuc ='9888' AND dCodRef =1109 THEN
				LET dCodRef	= '38';
			ELIF g_TransaccSuc ='4320' AND dCodRef =1109 THEN
				LET dCodRef	= '95';
			ELIF g_TransaccSuc ='9888' AND dCodRef =309 OR dCodRef =1118  THEN
			    LET dCodRef	= '37';	
			ELIF g_TransaccSuc ='4320' AND dCodRef =309 OR dCodRef =1118  THEN
			    LET dCodRef	= '94';	
		END IF;
        CALL "informix".genmovcrd(g_Empresa, g_NumCred, g_NumProd, dCodRef, g_CodFun, g_dtFechaHoy, pPagoCapitalM,
                   g_Folio,g_Sucursal, g_Divisa, g_TransaccSuc, g_NumPago,"")
         RETURNING cCodRet, cMensajeRet;

        IF (cCodRet <> "000000") THEN
            RETURN cCodRet,cMensajeRet;
        END IF;
     END IF;

       RETURN cCodRet,cMensajeRet;

END PROCEDURE;
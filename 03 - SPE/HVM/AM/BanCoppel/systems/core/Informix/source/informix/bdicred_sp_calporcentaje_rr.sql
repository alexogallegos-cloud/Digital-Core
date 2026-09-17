CREATE PROCEDURE "informix".sp_calporcentaje_rr(pAdeudoMoraInt DECIMAL(18,2),pMoraOrdi DECIMAL(18,2), 
                                                  pMoraCope DECIMAL(18,2),pAdeudoIva DECIMAL(18,2), pTpCal SMALLINT)
RETURNING CHAR(6)        AS codigo_ret,
          CHAR(80)       AS Mensaje_ret,
          DECIMAL(14,2)  AS Pago_Mora_Ordi,
          DECIMAL(14,2)  AS Pago_Mora_Cope,
          DECIMAL(14,2)  AS Pago_Int,
          DECIMAL(14,2)  AS Pago_Iva;

DEFINE iSqlErr               INTEGER;
DEFINE iIsamErr              INTEGER;
DEFINE cErrorInfo            CHAR(100);
DEFINE cCodRet               CHAR(6);
DEFINE cMensajeRet           CHAR(80);

--la variable pTpCal define que tipo de calculo vas a hacer si 
-- 1) si calculas moratorios
-- 2) si calculas interes
------variables globales de pago
DEFINE GLOBAL g_Remanente_pago       DECIMAL(18,2)  DEFAULT 0;

------varibles locales de calc. porcentaje
DEFINE dFactor               DECIMAL(14,9);
DEFINE dFactorMoraCope       DECIMAL(14,9);

DEFINE dPagoMoraInt          DECIMAL(14,2);
DEFINE dPagoIvaMoraInt       DECIMAL(14,2);
DEFINE dAdeudoTotal          DECIMAL(14,2);

DEFINE dPagoMoraCope         DECIMAL(14,2);
DEFINE dPagoMoraOrdi         DECIMAL(14,2);

LET dFactor             = 0;
LET dFactorMoraCope     = 0;

LET dPagoMoraInt        = 0;
LET dPagoIvaMoraInt     = 0;

LET dPagoMoraCope       = 0;
LET dPagoMoraOrdi       = 0;

LET iSqlErr               = 0;
LET iIsamErr              = 0;
LET cErrorInfo            = "";
LET cCodRet               = "000000";
LET cMensajeRet           = "Se realizó el calculo correctamente";


BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
          LET cCodRet= iSqlErr;
          LET cMensajeRet= cErrorInfo;
       RETURN cCodRet,cMensajeRet,dPagoMoraOrdi,dPagoMoraCope,dPagoMoraInt,dPagoIvaMoraInt;
   END IF;
END EXCEPTION;

 --SET DEBUG FILE TO "/tmp/sp_calc_porcentaje_pp.out";
 --TRACE ON;
 --> FMV 13-MAYO-10: No se considera Calculo de Moratorios para Reestructura
  /*  IF pTpCal=1 THEN
       LET  pAdeudoMoraInt = pMoraOrdi + pMoraCope;
    END IF;
*/

    LET dAdeudoTotal = pAdeudoMoraInt + pAdeudoIva;
    
    IF dAdeudoTotal > g_Remanente_pago AND pAdeudoMoraInt > 0 THEN

       LET dFactor = pAdeudoMoraInt / dAdeudoTotal;
       LET dPagoMoraInt = round(g_Remanente_pago * dFactor,2);
       LET dPagoIvaMoraInt = g_Remanente_pago - dPagoMoraInt;

    ELSE

       LET dPagoMoraInt = pAdeudoMoraInt;
       LET dPagoIvaMoraInt = pAdeudoIva;        

    END IF;

--> FMV 13-MAYO-10: No se considera Calculo de Moratorios para Reestructura
/*
    IF pTpCal=1 and pAdeudoMoraInt > 0 THEN
       
       LET dFactorMoraCope = (pMoraCope / pAdeudoMoraInt);
       LET dPagoMoraCope   = round(dPagoMoraInt * dFactorMoraCope,2);
       LET dPagoMoraOrdi   = dPagoMoraInt - dPagoMoraCope;
       LET dPagoMoraInt    = 0;
        
    END IF;
*/

   RETURN cCodRet,cMensajeRet,dPagoMoraOrdi,dPagoMoraCope,dPagoMoraInt,dPagoIvaMoraInt;

END
END PROCEDURE;
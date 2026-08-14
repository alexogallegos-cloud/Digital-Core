CREATE PROCEDURE "informix".calc_iva_grav_pp_09062013(p_cEmpresa CHAR(3), p_cNumCredito CHAR(20), p_dTasaInt DECIMAL(9,6),
                                             p_dIvaSuc DECIMAL(5,3), p_dtFechaHoy DATE,p_dtIvaFechaPag DATE,
                                             p_dtFechaApert DATE,p_dtFechaCuota DATE,p_dIntNorm DECIMAL(18,2))

RETURNING
   CHAR(6)        AS Cod_Ret,
   DECIMAL(18,2)  AS IvaIntReal,
   CHAR(80)       AS Mens_Ret;

    DEFINE iSqlErr          INTEGER;
    DEFINE iIsamErr         INTEGER;
    DEFINE cErrorInfo       CHAR(80);
    DEFINE cCodRet          CHAR(6);
    DEFINE cMensajeRet      CHAR(125);
    DEFINE l_diascalc       INTEGER;
    DEFINE l_dtFechaComp    DATE;
    DEFINE l_iDias          INTEGER;
    DEFINE l_dFactor1       DECIMAL(14,9);
    DEFINE l_dFactor2       DECIMAL(14,9);
    DEFINE l_dTasaReal      DECIMAL(14,9);
    DEFINE l_dFactorIntReal DECIMAL(14,9);
    DEFINE l_dIvaIntReal    DECIMAL(18,2);

    LET iSqlErr               = 0;
    LET iIsamErr              = 0;
    LET cErrorInfo            = "";
    LET cCodRet               = "000000";
    LET cMensajeRet           = "Proceso Exitoso";

    LET l_diascalc            = 0;
    LET l_dtFechaComp         = DATE(1);
    LET l_iDias               = 0;
    LET l_dFactor1            = 0;
    LET l_dFactor2            = 0;
    LET l_dTasaReal           = 0;
    LET l_dFactorIntReal      = 0;
    LET l_dIvaIntReal         = 0;

    BEGIN

    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
          LET cCodRet= iSqlErr;
          LET cMensajeRet= cErrorInfo;
       RETURN cCodRet,l_dIvaIntReal,cMensajeRet;
       END IF;
    END EXCEPTION;

   -- SET DEBUG FILE TO "/pisa/cas/calc_iva_grav_pp.out";
   -- TRACE ON;

--    SET LOCK MODE TO WAIT 3;

    select valor
    into l_diascalc
    from bdicred:sd_param
    where cod_param='24'
    and empresa= p_cEmpresa;

    IF p_dtIvaFechaPag IS NULL THEN
        CALL bdicred:monthadd(p_dtFechaCuota,-1) RETURNING l_dtFechaComp;

          SELECT fecha_cuota
            INTO l_dtFechaComp
            FROM "informix".sd_amortiza_creditocrd
           WHERE empresa     = p_cEmpresa
             AND num_credito = p_cNumCredito
             AND fecha_cuota = l_dtFechaComp;

             IF l_dtFechaComp IS NULL THEN
                 LET l_dtFechaComp = p_dtFechaApert;
             END IF;
    ELSE
          LET l_dtFechaComp = p_dtIvaFechaPag;
    END IF;

    LET l_iDias    = p_dtFechaHoy - l_dtFechaComp;

    IF l_iDias > 0 THEN
        LET l_dFactor1 = NVL(p_dTasaInt,0)/(l_diascalc *100)* l_iDias;
        IF NVL(l_dFactor1,0) < 0 THEN
             LET cCodRet      = "000001";
             LET cMensajeRet  = "No es posible realizar los calculos con el valor obtenido para el factor 1";
          RETURN cCodRet,l_dIvaIntReal,TRIM(cMensajeRet);
        END IF;

        CALL bdicred:determina_udi_rango_09062013(p_cEmpresa,date(l_dtFechaComp-1),date(p_dtFechaHoy-1)) RETURNING cCodRet,l_dFactor2;

        IF NVL(l_dFactor2,0) < 0 THEN
             LET cCodRet     = "000002";
             LET cMensajeRet = "No es posible realizar los calculos con el valor obtenido para el factor 2";
          RETURN cCodRet,l_dIvaIntReal,TRIM(cMensajeRet);
        END IF;

        LET l_dTasaReal       = l_dFactor1 - l_dFactor2;
        IF l_dTasaReal< 0 THEN LET l_dTasaReal=0; END IF;
        LET l_dFactorIntReal  = (l_dTasaReal * p_dIvaSuc)/l_dFactor1;
--        LET p_dIntNorm        = g_dSdoInt;
        LET l_dIvaIntReal     = round(l_dFactorIntReal * p_dIntNorm,2);
    END IF;

    IF cCodRet <> "000000" THEN
      LET cCodRet = "000000";
    END IF;

        RETURN cCodRet,l_dIvaIntReal,cMensajeRet;

    END
END PROCEDURE;
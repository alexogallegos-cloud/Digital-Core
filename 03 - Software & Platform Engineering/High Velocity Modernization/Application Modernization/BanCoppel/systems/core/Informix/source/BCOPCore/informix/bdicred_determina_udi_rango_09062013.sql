CREATE PROCEDURE "informix".determina_udi_rango_09062013(pEmpresa CHAR(3),
                                                pFecha_ini   DATE,
                                                pFecha_fin   DATE)
RETURNING CHAR(5) AS retorno,
          DECIMAL(14,6) AS valor_udi;
--------------------------------------------------------------------------------
-- Modificó: Viridiana Osobampo
-- Descripción: Se valida que la información de fechas recibidas sea correcta.
--        La fecha inicial no debe ser mayor que la fecha final y la fecha final 
--        no debe ser mayor a la fecha actual.
-- Fecha de modificación: 09-10-2009
-- Petición: Préstamo Personal.
--------------------------------------------------------------------------------
-- Modificó: Viridiana Osobampo
-- Descripción: Se modifica para que al obtener el valor2 de la udi, primero busque
--              en la tabla si_tpcambio y si no encontró información buscar en la
--              si_histdiv, tal como se hace al obtener el valor inicial.
-- Fecha de modificación: 22-01-2010
-- Petición: Préstamo Personal.
--------------------------------------------------------------------------------

   -- **************************************************************************
   -- *                      DEFINICION DE VARIABLES                           *
   -- **************************************************************************

   DEFINE cod_ret		CHAR(5);
   DEFINE sql_err       SMALLINT;
   DEFINE isam_err      SMALLINT;
   DEFINE error_info    CHAR(40);
   DEFINE vValor1       DECIMAL(14,6);
   DEFINE vValor2       DECIMAL(14,6);
   DEFINE vPrecio       DECIMAL(14,6);
   DEFINE vFechaPaso    DATE;
   DEFINE vDivUdi       CHAR(2);
   DEFINE vClaseUdi     CHAR(1);
   DEFINE dtFechaHoy    DATE;

   -- **************************************************************************
   -- *                      CONTROL DE ERRORES                                *
   -- **************************************************************************
BEGIN

   ON EXCEPTION SET sql_err, isam_err, error_info
      LET cod_ret = sql_err;
      RETURN cod_ret, vPrecio;
   END EXCEPTION;

 --SET DEBUG FILE TO "/pisa/cas/determina_udi_rango.out";
 --TRACE ON;

  -- **************************************************************************
  -- *                      ASIGNACION DE VARIABLES                           *
  -- **************************************************************************
   LET cod_ret    	= "000";
   LET vValor1   	= 0;
   LET vValor2   	= 0;
   LET vPrecio   	= 0;
   LET vFechaPaso 	= "";
   LET dtFechaHoy   = DATE(1);

-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************

    -- Valida que se proporcionen los parámetros de entrada
   IF NVL(pEmpresa,'')= '' OR NVL(pFecha_ini,'')= '' OR NVL(pFecha_fin,'')= '' THEN
       LET cod_ret = '902';
       RETURN cod_ret, NVL(vPrecio,0);
   END IF;

    -- valida que la fecha ini no sea mayor que la fecha fin
   IF pFecha_ini > pFecha_fin THEN
       LET cod_ret = '903';
       RETURN cod_ret, NVL(vPrecio,0);  
   END IF; 

   -- Valida que la fecha fin no sea mayor que la fecha actual
   SELECT fecha_hoy
     INTO dtFechaHoy
     FROM bdicred:sd_fechas;

  let dtFechaHoy = mdy('06','09','2013');
   IF pFecha_fin > dtFechaHoy THEN
       LET cod_ret = '904';
       RETURN cod_ret, NVL(vPrecio,0);
   END IF;

      -- ******************************************
      -- Extrae Parametro de Codigo de Divisa UDI *
      -- ******************************************
   SELECT TRIM(valor) 
     INTO vDivUdi
     FROM bdinteg:si_param
    WHERE empresa = pEmpresa
      AND cod_param = 16;

      -- *****************************************
      -- Extrae Clase de Tipo de Cmabio para UDI *
      -- *****************************************
   SELECT TRIM(valor) 
     INTO vClaseUdi
     FROM sd_param
    WHERE empresa = pEmpresa
      AND cod_param = "336";

      -- **************
      -- Precio Inicio*
      -- **************    
   SELECT precio_compra 
     INTO vValor1
     FROM bdinteg:si_tpcambio
    WHERE empresa = pEmpresa
      AND divisa = vDivUdi
      AND fecha_tpcambio = (SELECT MAX(fecha_tpcambio)
                              FROM bdinteg:si_tpcambio
                             WHERE empresa = pEmpresa
                               AND divisa = vDivUdi
                               AND fecha_tpcambio = pFecha_fin)
      AND hora_tpcambio=(SELECT MAX(hora_tpcambio)
                           FROM bdinteg:si_tpcambio
                          WHERE empresa = pEmpresa
                            AND divisa = vDivUdi
                            AND fecha_tpcambio = pFecha_fin)
      AND clase_tpcambio = vClaseUdi;

       IF vValor1 IS NULL THEN

           SELECT precio_compra 
             INTO vValor1
             FROM bdinteg:si_histdiv
            WHERE empresa = pEmpresa
              AND divisa = "09"
              AND fecha_tc = (SELECT MAX(fecha_tc)
                                FROM bdinteg:si_histdiv
                               WHERE empresa = pEmpresa
                                 AND divisa = "09"
                                 AND fecha_tc = pFecha_fin)
              AND hora_tc=(SELECT MAX(hora_tc)
                             FROM bdinteg:si_histdiv
                            WHERE empresa = pEmpresa
                              AND divisa = "09"
                              AND fecha_tc = pFecha_fin)
              AND clase_tpcambio = vClaseUdi;

           IF vValor1 IS NULL THEN
               LET cod_ret = "900";
               RETURN cod_ret, vPrecio;
           END IF;

        END IF;

            -- *************
            -- Precio Final*
            -- *************
   SELECT precio_compra 
     INTO vValor2
     FROM bdinteg:si_tpcambio
    WHERE empresa = pEmpresa
      AND divisa = vDivUdi
      AND fecha_tpcambio = (SELECT MAX(fecha_tpcambio)
                              FROM bdinteg:si_tpcambio
                             WHERE empresa = pEmpresa
                               AND divisa = vDivUdi
                               AND fecha_tpcambio = pFecha_ini)
      AND hora_tpcambio=(SELECT MAX(hora_tpcambio)
                           FROM bdinteg:si_tpcambio
                          WHERE empresa = pEmpresa
                            AND divisa = vDivUdi
                            AND fecha_tpcambio = pFecha_ini)
      AND clase_tpcambio = vClaseUdi;

      IF vValor2 IS NULL THEN

           SELECT precio_compra 
             INTO vValor2
             FROM bdinteg:si_histdiv
            WHERE empresa = pEmpresa
              AND divisa = "09"
              AND fecha_tc = (SELECT MAX(fecha_tc)
                                FROM bdinteg:si_histdiv
                               WHERE empresa = pEmpresa
                                 AND divisa = "09"
                                 AND fecha_tc = pFecha_ini)
              AND hora_tc=(SELECT MAX(hora_tc)
                           FROM bdinteg:si_histdiv
                           WHERE empresa = pEmpresa
                           AND divisa = "09"
                           AND fecha_tc = pFecha_ini)  
              AND clase_tpcambio = vClaseUdi;

           IF vValor2 IS NULL THEN
               LET cod_ret = "901";
               RETURN cod_ret, vPrecio;
           END IF
      END IF;

           LET vPrecio = (vValor1 / vValor2);

       IF vPrecio > 1 THEN
           LET vPrecio =  vPrecio -1;
       ELSE
           LET vPrecio = 0;
       END IF;
END
       RETURN cod_ret, vPrecio;
END PROCEDURE 
DOCUMENT "Version 1.00.000";

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
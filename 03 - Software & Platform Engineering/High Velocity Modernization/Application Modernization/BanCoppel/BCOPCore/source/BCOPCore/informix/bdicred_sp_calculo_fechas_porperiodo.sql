CREATE PROCEDURE "informix".sp_calculo_fechas_porperiodo(pEmpresa CHAR(3),pFechaBase DATE,pPeriodo CHAR(1),pTipoFactura CHAR(1),pFechaFinMes DATE)
RETURNING CHAR(06)       AS retorno,
          DATE           AS rFechaInicio,
          DATE           AS rFechaFin,
          CHAR(40)       AS rMensaje;
--pFechaBase es la fecha de referencia a tomar para el cálculo
--VALORES POSIBLES PARA el parámetro pPeriodo
-- M mesiversario
-- Q quincenal
--PARA PERIODO SEMANAL
-- L Lunes
-- A Martes
-- I Miércoles
-- J Jueves
-- V Viernes
-- S Sábado
-- D Domingo
--VALORES POSIBLES PARA el parámetro pTipoFactura
-- N Normal
-- M Mesiversario
--pFechaFinMes es la fecha a partir en que se genera el cálculo


DEFINE iSqlErr              SMALLINT;
DEFINE iIsamErr             SMALLINT;
DEFINE cErrorInfo           CHAR(80);
DEFINE cCodRet              CHAR(06); 
DEFINE cMensajeRet          VARCHAR(40);
DEFINE dFechaInicio         DATE;
DEFINE dFechaFin            DATE;
DEFINE sDiaCorte            SMALLINT;
DEFINE dtFechaInicioPeriodo DATE;
DEFINE dtFechaFinPeriodo    DATE;
DEFINE dFechaHoy            DATE;
DEFINE dPriDiaMes           DATE;
DEFINE dUltDiaMesAnterior   DATE;


		 
BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
      LET cCodRet= iSqlErr;
      RETURN cCodRet,dFechaInicio,dFechaFin,cMensajeRet;
   END IF;
END EXCEPTION;

--SET DEBUG FILE TO "sp_calculo_fechas_porperiodo.out";
--TRACE ON;

LET iSqlErr            = 0;
LET iIsamErr           = 0;
LET cErrorInfo         = "";
LET cCodRet            = '000000';
LET cMensajeRet        = 'CALCULO EXITOSO';
LET dFechaInicio       = '';
LET dFechaFin          = '';
LET sDiaCorte          = 0;
LET dtFechaInicioPeriodo = '';
LET dtFechaFinPeriodo    = '';
LET dFechaHoy           = DATE(1);
LET dPriDiaMes          = DATE(1);
LET dUltDiaMesAnterior  = DATE(1);

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

IF pEmpresa IS NULL OR pEmpresa = '' THEN
   LET cCodRet= '000001';
   LET cMensajeRet= 'FALTA PARAMETRO EMPRESA: CAMPO 1';
   RETURN cCodRet,dFechaInicio,dFechaFin,cMensajeRet;
END IF;

IF pFechaBase IS NULL OR pFechaBase = '' THEN
   LET cCodRet= '000002';
   LET cMensajeRet= 'FALTA PARAMETRO FECHA BASE: CAMPO 2';
   RETURN cCodRet,dFechaInicio,dFechaFin,cMensajeRet;
END IF;

IF pPeriodo IS NULL OR pPeriodo = '' THEN
   LET cCodRet= '000003';
   LET cMensajeRet= 'FALTA PARAMETRO PERIODO: CAMPO 3';
   RETURN cCodRet,dFechaInicio,dFechaFin,cMensajeRet;
END IF;

IF pFechaFinMes IS NULL OR pFechaFinMes = '' THEN
   LET cCodRet= '000004';
   LET cMensajeRet= 'FALTA PARAMETRO TIPO FACTURA: CAMPO 4';
   RETURN cCodRet,dFechaInicio,dFechaFin,cMensajeRet;
END IF;

IF pFechaFinMes IS NULL OR pFechaFinMes = '' THEN
   LET cCodRet= '000004';
   LET cMensajeRet= 'FALTA PARAMETRO FECHA HOY: CAMPO 5';
   RETURN cCodRet,dFechaInicio,dFechaFin,cMensajeRet;
END IF;

LET sDiaCorte = DAY(pFechaBase);

IF pTipoFactura = 'M' THEN 
    IF pPeriodo = 'M' THEN
    --   EXECUTE PROCEDURE "informix".monthadd(mdy('03','31','2012'), -1) 
    --   LET dtFechaInicioPeriodo = mdy(month(pFechaFinMes),day(pFechaBase),year(pFechaFinMes));

    --Cálculo de fechas de un periodo para obtener los pagos del periodo del crédito, considerando años biciestos
        IF MONTH(pFechaFinMes)::smallint = 3 AND YEAR(pFechaFinMes)::smallint IN (2012,2016,2020,2024,2028,2032) THEN 
            IF sDiaCorte = 30 THEN
    --           LET dtFechaInicioPeriodo = (pFechaFinMes - 1 UNITS MONTH) - 1 UNITS DAY;
               LET dtFechaInicioPeriodo = (pFechaFinMes - 1 UNITS DAY) - 1 UNITS MONTH;
            LET dtFechaFinPeriodo = pFechaFinMes;
            ELIF sDiaCorte = 31 THEN
    --           LET dtFechaInicioPeriodo = (pFechaFinMes - 1 UNITS MONTH) - 2 UNITS DAY;
               LET dtFechaInicioPeriodo = (pFechaFinMes - 2 UNITS DAY) - 1 UNITS MONTH;
            LET dtFechaFinPeriodo = pFechaFinMes;
            ELSE
--cualquier periodo
                LET dtFechaInicioPeriodo = MDY(MONTH(pFechaFinMes),LPAD(sDiaCorte,2,0),YEAR(pFechaFinMes)) - 1 UNITS MONTH;
                LET dtFechaFinPeriodo = MDY(MONTH(pFechaFinMes),LPAD(sDiaCorte,2,0),YEAR(pFechaFinMes));
--cualquier periodo
            END IF;
        ELIF MONTH(pFechaFinMes)::smallint = 2 AND YEAR(pFechaFinMes)::smallint IN (2012,2016,2020,2024,2028,2032) THEN 
            IF sDiaCorte = 30 THEN
               LET dtFechaInicioPeriodo = (pFechaFinMes - 1 UNITS MONTH) + 1 UNITS DAY;
               LET dtFechaFinPeriodo = pFechaFinMes;
            ELIF sDiaCorte = 31 THEN
               LET dtFechaInicioPeriodo = (pFechaFinMes - 1 UNITS MONTH) + 2 UNITS DAY;
               LET dtFechaFinPeriodo = pFechaFinMes;
            ELSE
    --           LET dtFechaInicioPeriodo = pFechaFinMes - 1 UNITS MONTH;
                LET dtFechaInicioPeriodo = MDY(MONTH(pFechaFinMes),LPAD(sDiaCorte,2,0),YEAR(pFechaFinMes)) - 1 UNITS MONTH;
                LET dtFechaFinPeriodo = MDY(MONTH(pFechaFinMes),LPAD(sDiaCorte,2,0),YEAR(pFechaFinMes));
            END IF;
        ELIF MONTH(pFechaFinMes)::smallint IN (4,6,9,11) AND sDiaCorte = 31 THEN
            LET dtFechaInicioPeriodo = (pFechaFinMes - 1 UNITS MONTH) + 1 UNITS DAY;
            LET dtFechaFinPeriodo = pFechaFinMes;
        ELIF MONTH(pFechaFinMes)::smallint IN (5,7,8,10,12) AND sDiaCorte = 31 THEN
            LET dtFechaInicioPeriodo = (MDY(MONTH(pFechaFinMes),LPAD(sDiaCorte,2,0),YEAR(pFechaFinMes)) - 1 UNITS DAY) - 1 UNITS MONTH;
            LET dtFechaFinPeriodo = pFechaFinMes;
        ELIF MONTH(pFechaFinMes)::smallint = 2 THEN
            IF sDiaCorte = 29 THEN
                LET dtFechaInicioPeriodo = (pFechaFinMes - 1 UNITS MONTH) + 1 UNITS DAY;
                LET dtFechaFinPeriodo = pFechaFinMes;
            ELIF sDiaCorte = 30 THEN
                LET dtFechaInicioPeriodo = (pFechaFinMes - 1 UNITS MONTH) + 2 UNITS DAY;
                LET dtFechaFinPeriodo = pFechaFinMes;
            ELIF sDiaCorte = 31 THEN
                LET dtFechaInicioPeriodo = (pFechaFinMes - 1 UNITS MONTH) + 3 UNITS DAY;
                LET dtFechaFinPeriodo = pFechaFinMes;
            ELSE
    --rss            LET dtFechaInicioPeriodo = pFechaFinMes - 1 UNITS MONTH;
                LET dtFechaInicioPeriodo = MDY(MONTH(pFechaFinMes),LPAD(sDiaCorte,2,0),YEAR(pFechaFinMes)) - 1 UNITS MONTH;
                LET dtFechaFinPeriodo = MDY(MONTH(pFechaFinMes),LPAD(sDiaCorte,2,0),YEAR(pFechaFinMes));
            END IF;
        ELIF MONTH(pFechaFinMes)::smallint = 3 THEN 
            IF sDiaCorte = 29 THEN
    --           LET dtFechaInicioPeriodo = (pFechaFinMes - 1 UNITS MONTH) - 1 UNITS DAY;
               LET dtFechaInicioPeriodo = (pFechaFinMes - 3 UNITS DAY) - 1 UNITS MONTH;
               LET dtFechaFinPeriodo = pFechaFinMes - 2 UNITS DAY;
            ELIF sDiaCorte = 30 THEN
    --           LET dtFechaInicioPeriodo = (pFechaFinMes - 1 UNITS MONTH) - 2 UNITS DAY;
               LET dtFechaInicioPeriodo = (pFechaFinMes - 3 UNITS DAY) - 1 UNITS MONTH;
               LET dtFechaFinPeriodo = pFechaFinMes - 1 UNITS DAY;
            ELIF sDiaCorte = 31 THEN
    --           LET dtFechaInicioPeriodo = (pFechaFinMes - 1 UNITS MONTH) - 3 UNITS DAY;
               LET dtFechaInicioPeriodo = (pFechaFinMes - 3 UNITS DAY) - 1 UNITS MONTH;
               LET dtFechaFinPeriodo = pFechaFinMes;
            ELSE
                LET dtFechaInicioPeriodo = MDY(MONTH(pFechaFinMes),LPAD(sDiaCorte,2,0),YEAR(pFechaFinMes)) - 1 UNITS MONTH;
                LET dtFechaFinPeriodo = MDY(MONTH(pFechaFinMes),LPAD(sDiaCorte,2,0),YEAR(pFechaFinMes));
            END IF;
        ELSE
--cualquier periodo
            LET dtFechaInicioPeriodo = MDY(MONTH(pFechaFinMes),LPAD(sDiaCorte,2,0),YEAR(pFechaFinMes)) - 1 UNITS MONTH;
            LET dtFechaFinPeriodo = MDY(MONTH(pFechaFinMes),LPAD(sDiaCorte,2,0),YEAR(pFechaFinMes));
--cualquier periodo
        END IF;
    ELIF pPeriodo = 'Q' THEN
        LET dPriDiaMes = MDY(MONTH(pFechaFinMes),'01',YEAR(pFechaFinMes));
        LET dUltDiaMesAnterior = dPriDiaMes - 1 UNITS DAY;

        IF DAY(pFechaFinMes)::SMALLINT = 30 THEN

           IF DAY(pFechaBase)::SMALLINT <= 15 THEN 
              LET dtFechaInicioPeriodo = MDY(MONTH(pFechaFinMes),LPAD(sDiaCorte,2,0),YEAR(pFechaFinMes));
              LET dtFechaFinPeriodo = dtFechaInicioPeriodo + 15 UNITS DAY;
           ELSE
              LET dtFechaInicioPeriodo = MDY(MONTH(dUltDiaMesAnterior),LPAD(sDiaCorte,2,0),YEAR(dUltDiaMesAnterior)) + 17 UNITS DAY;
              LET dtFechaFinPeriodo = dtFechaInicioPeriodo + 14 UNITS DAY;
           END IF;

    --    ELIF DAY(dPriDiaMes)::SMALLINT = 30 THEN
        END IF;
    END IF;
ELIF pTipoFactura = 'N' THEN
    IF pPeriodo = 'M' THEN
    --   EXECUTE PROCEDURE "informix".monthadd(mdy('03','31','2012'), -1) 
    --   LET dtFechaInicioPeriodo = mdy(month(pFechaFinMes),day(pFechaBase),year(pFechaFinMes));
       LET dtFechaInicioPeriodo = mdy(month(pFechaFinMes),1,year(pFechaFinMes));
       LET dtFechaFinPeriodo = pFechaFinMes;
    ELIF pPeriodo = 'Q' THEN
        LET dPriDiaMes = MDY(MONTH(pFechaFinMes),'01',YEAR(pFechaFinMes));
        LET dUltDiaMesAnterior = dPriDiaMes - 1 UNITS DAY;

        IF DAY(pFechaFinMes)::SMALLINT = 30 THEN

           IF DAY(pFechaBase)::SMALLINT <= 15 THEN 
              LET dtFechaInicioPeriodo = MDY(MONTH(pFechaFinMes),LPAD(sDiaCorte,2,0),YEAR(pFechaFinMes));
              LET dtFechaFinPeriodo = dtFechaInicioPeriodo + 15 UNITS DAY;
           ELSE
              LET dtFechaInicioPeriodo = MDY(MONTH(dUltDiaMesAnterior),LPAD(sDiaCorte,2,0),YEAR(dUltDiaMesAnterior)) + 17 UNITS DAY;
              LET dtFechaFinPeriodo = dtFechaInicioPeriodo + 14 UNITS DAY;
           END IF;

    --    ELIF DAY(dPriDiaMes)::SMALLINT = 30 THEN
        END IF;
    END IF;

END IF;

RETURN cCodRet,dtFechaInicioPeriodo,dtFechaFinPeriodo,cMensajeRet;

END
END PROCEDURE


;
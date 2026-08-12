CREATE PROCEDURE "informix".sp_fecha_habil(P_EMPRESA      VARCHAR(3)
                ,P_FECHA        DATE
                ,P_TP_AJUSTE    VARCHAR(1)
                )
       RETURNING VARCHAR(5), VARCHAR(80), DATE;

DEFINE P_COD_RET       VARCHAR(5);
DEFINE P_MENSAJE       VARCHAR(80);
DEFINE V_FECHA_HABIL   DATE;
DEFINE V_DIA           INTEGER;

DEFINE V_FACTOR        INTEGER;
DEFINE V_FERIADO       INTEGER;
BEGIN
   LET P_COD_RET = '00000';
   LET P_MENSAJE = 'PROCESO EXITOSO';
   LET V_FECHA_HABIL = TODAY;

   IF P_TP_AJUSTE = 'S' THEN
      SELECT DECODE(WEEKDAY(P_FECHA)
                   ,0, P_FECHA + 1
--                   ,6, P_FECHA + 2
                   ,P_FECHA
                   )
      INTO   V_FECHA_HABIL
      FROM SD_FECHAS;

      LET V_FACTOR = 1;
   ELSE
      SELECT DECODE(WEEKDAY(P_FECHA)
                   ,0, P_FECHA - 2
--                   ,6, P_FECHA - 1
                   ,P_FECHA
                   )
      INTO   V_FECHA_HABIL
      FROM SD_FECHAS;
      LET V_FACTOR = -1;
   END IF;

   SELECT COUNT(*) 
   INTO   V_FERIADO
   FROM   BDINTEG:SI_FERIADO 
   WHERE  EMPRESA = P_EMPRESA
   AND    FECHA = V_FECHA_HABIL;

   IF V_FERIADO = 0 THEN
      RETURN P_COD_RET, P_MENSAJE, V_FECHA_HABIL;
   ELSE
      LET V_FECHA_HABIL = V_FECHA_HABIL + V_FACTOR;
      EXECUTE PROCEDURE SP_FECHA_HABIL(P_EMPRESA, V_FECHA_HABIL, P_TP_AJUSTE)
                   INTO P_COD_RET, P_MENSAJE, V_FECHA_HABIL;
      RETURN P_COD_RET, P_MENSAJE, V_FECHA_HABIL;
   END IF;
END;
END PROCEDURE;
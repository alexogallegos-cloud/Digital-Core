CREATE PROCEDURE "informix".sp_calcula_fecha(P_EMPRESA         VARCHAR(3)
                ,P_PLAZO           INTEGER
                ,P_PERIODO_PLAZO   VARCHAR(2)
                ,P_FECHA_INICIO    DATE
                ,P_AJUSTE          VARCHAR(2)
                ,P_TIPO_AJUSTE     VARCHAR(2)
                ) RETURNING VARCHAR(5), DATE;

DEFINE P_COD_RET             VARCHAR(5);
DEFINE P_MENSAJE             VARCHAR(80);

DEFINE V_FECHA_FINAL         DATE;
DEFINE V_DIA_ULTIMO          INTEGER;
DEFINE V_ANIO                INTEGER;
DEFINE V_ANIO_RES            DECIMAL(6,2);
DEFINE V_MES                 INTEGER;
DEFINE V_ANIOAX              DATE;
BEGIN

--set debug file to 'calcula_fecha.out';
--trace on;


  LET P_COD_RET = '00000';
  LET P_MENSAJE = 'PROCESO EXITOSO';
  LET V_FECHA_FINAL = TODAY;

  IF P_PERIODO_PLAZO = 'D' THEN
    LET V_FECHA_FINAL = P_FECHA_INICIO + P_PLAZO;

  ELIF P_PERIODO_PLAZO = 'Q' THEN
    IF P_PLAZO > 0 THEN
       LET V_FECHA_FINAL = P_FECHA_INICIO + (15 * P_PLAZO);
    ELSE
       LET V_FECHA_FINAL = P_FECHA_INICIO + 15;
    END IF;
    IF DAY(V_FECHA_FINAL) <= 15 THEN
       LET V_FECHA_FINAL = MDY(MONTH(V_FECHA_FINAL),15, YEAR(V_FECHA_FINAL));
    ELSE
       IF MONTH(V_FECHA_FINAL) = 12 THEN
          LET V_DIA_ULTIMO = 31;
       ELSE
          LET V_DIA_ULTIMO = DAY(MDY(MONTH(V_FECHA_FINAL)+1,1,YEAR(V_FECHA_FINAL))-1);
       END IF;
       LET V_FECHA_FINAL = MDY(MONTH(V_FECHA_FINAL),V_DIA_ULTIMO, YEAR(V_FECHA_FINAL));
    END IF;

  ELIF P_PERIODO_PLAZO = 'M' THEN
    LET V_ANIO = P_PLAZO / 12;
    LET V_ANIO_RES = TRUNC(P_PLAZO/12,2);
    LET V_ANIO_RES = V_ANIO_RES - V_ANIO;
    IF V_ANIO = 0 THEN
       LET V_MES = P_PLAZO;
       IF P_PLAZO > 12 THEN
          LET V_MES = MOD(P_PLAZO,12);
       END IF;
       LET V_MES = MONTH(P_FECHA_INICIO) + V_MES;
       IF V_MES > 12 THEN
          LET V_MES = V_MES - 12;
          LET V_ANIO = 1;
       END IF;
       --calcula el dia ultimo del nuevo mes
       if v_mes < 12 then
         let v_dia_ultimo = day(mdy(v_mes+1, 1, year(p_fecha_inicio))-1);
       else
         let v_dia_ultimo = day(mdy(1, 1, year(p_fecha_inicio))-1);
       end if;
       IF DAY(P_FECHA_INICIO) > V_DIA_ULTIMO THEN
         LET V_FECHA_FINAL = MDY(V_MES, V_DIA_ULTIMO, YEAR(P_FECHA_INICIO)+V_ANIO);
       ELSE
         LET V_FECHA_FINAL = MDY(V_MES, DAY(P_FECHA_INICIO), YEAR(P_FECHA_INICIO)+V_ANIO);
       END IF;

    ELSE
       LET V_MES = P_PLAZO;
       IF P_PLAZO > 12 THEN
          LET V_MES = MOD(P_PLAZO, 12);
       END IF;
       LET V_MES = MONTH(P_FECHA_INICIO) + V_MES;
       IF V_MES > 12 THEN
          --IF V_ANIO_RES > 0.32 THEN
             LET V_ANIO = V_ANIO + 1;
          --END IF;
          LET V_MES = V_MES - 12;
       END IF;
       --calcula el dia ultimo del nuevo mes
       if v_mes < 12 then
         let v_dia_ultimo = day(mdy(v_mes+1, 1, year(p_fecha_inicio)+V_ANIO)-1);
       else
         let v_dia_ultimo = day(mdy(1, 1, year(p_fecha_inicio)+V_ANIO)-1);
       end if;
       IF DAY(P_FECHA_INICIO) > V_DIA_ULTIMO THEN
         LET V_FECHA_FINAL = MDY(V_MES, V_DIA_ULTIMO, YEAR(P_FECHA_INICIO)+V_ANIO);
       ELSE
         LET V_FECHA_FINAL = MDY(V_MES, DAY(P_FECHA_INICIO), YEAR(P_FECHA_INICIO)+V_ANIO);
       END IF;
    END IF;
  ELIF P_PERIODO_PLAZO = 'A' THEN
    LET V_FECHA_FINAL = MDY(MONTH(P_FECHA_INICIO), DAY(P_FECHA_INICIO), YEAR(P_FECHA_INICIO) + P_PLAZO);
  END IF;

  IF P_AJUSTE = 'S' THEN
     EXECUTE PROCEDURE SP_FECHA_HABIL(P_EMPRESA, V_FECHA_FINAL,P_TIPO_AJUSTE)
                                 INTO P_COD_RET, P_MENSAJE, V_FECHA_FINAL;

     RETURN P_COD_RET, V_FECHA_FINAL;
  ELSE
     RETURN P_COD_RET, V_FECHA_FINAL;
  END IF;

END;
END PROCEDURE;
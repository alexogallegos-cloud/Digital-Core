CREATE PROCEDURE "informix".capital(
   p_empresa                VARCHAR(3)  ,
   pnum_credito             VARCHAR(20) ,
   pfecha_alta              DATE        ,
   pfecha_vencim            DATE        ,
   pmonto_linea             INTEGER     ,
   pperiod_pago_cap         INTEGER     ,
   pcuota_con_dec           VARCHAR(1)  , --(S/N)
   pajuste_vencim           VARCHAR(1)  , -- ajuste cuota cap.(U,P)
   pajuste_de_cuota         VARCHAR(1)  , --(S/N)
   ptipo_ajuste             VARCHAR(1)  , --(S,P)
   pdia_corte_cap           VARCHAR(5)  ,
   vfecha_gra_cap           DATE        )
RETURNING VARCHAR(10), VARCHAR(80);

--p_cod_ret            OUT VARCHAR2 ,
--p_mensaje            OUT VARCHAR2 

DEFINE P_COD_RET   VARCHAR(10);
DEFINE P_MENSAJE   VARCHAR(80);

--########################################################################
--### Programa      : capital.sql                                      ###
--### Descripcion   : GENERACION DE PLANES DE CAPITAL AUTOMATICAMENTE. ###
--########################################################################

DEFINE   pfecha_cuota      DATE;
DEFINE   pmonto_cuota      DECIMAL(18,2);
DEFINE   factor            INTEGER;
DEFINE   v_dia_fecha_cuota INTEGER;
DEFINE   v_fecha_cuota_ult DATE;
DEFINE   v_fecha_cuota_pen DATE;
DEFINE   v_fecha_cuota     DATE;
DEFINE   v_dias_max        VARCHAR(50);
DEFINE   cuantos_dias      INTEGER;
DEFINE   v_max_fecha       DATE;
DEFINE   v_no_hay          INTEGER;
DEFINE   pfecha_gra_cap    DATE;
DEFINE   V_ULTIMO_DIA_MES  INTEGER;
DEFINE   V_DIA_ORIGINAL    INTEGER;
DEFINE   V_DIAS            INTEGER;
DEFINE   V_DIA             INTEGER;
DEFINE   V_MES             INTEGER;
DEFINE   V_ANIO            INTEGER;
DEFINE   V_TIPO_TASA       INTEGER;

DEFINE   V_CADENA1         VARCHAR(80);
DEFINE   V_CADENA2         VARCHAR(80);

DEFINE   V_DIA_CONTROL     INTEGER;

BEGIN


   LET V_ULTIMO_DIA_MES = 0;
   LET V_DIAS            = 0;
   LET p_cod_ret         = '00000';
   LET pfecha_cuota      = '';
   LET pmonto_cuota      = 0;
   LET v_fecha_cuota_ult = NULL;
   LET v_fecha_cuota_pen = NULL;
   LET v_fecha_cuota     = '';
   LET v_dias_max        = '';
   LET cuantos_dias      = 0;
   LET v_max_fecha       = '';
   LET v_no_hay          = 0;
   LET pfecha_gra_cap    = vfecha_gra_cap;
   LET P_COD_RET         = '00000';
   LET P_MENSAJE         = 'PROCESO EXITOSO';


--#########################################################################



   DELETE FROM sd_pagocapit
   WHERE  empresa       = p_empresa
   AND    num_credito = pnum_credito;


   --SELECCIONA EL NUMERO DE DIAS CORRESPONDIENTE AL PERIODO
   SELECT EQUIVALENCIA_DIAS
   INTO   V_DIAS
   FROM   BDICRED:SD_CODPCAP
   WHERE  EMPRESA = P_EMPRESA 
   AND    PERIOD_PAGO_CAP = PPERIOD_PAGO_CAP;
			
   IF pperiod_pago_cap = '7' THEN
      LET pfecha_cuota = pfecha_vencim;
      LET pmonto_cuota = pmonto_linea/100;
      EXECUTE PROCEDURE ins_cuotas(p_empresa     ,pnum_credito   ,pfecha_cuota,
                                   pmonto_cuota  ,pfecha_vencim  ,pajuste_de_cuota,
                                   ptipo_ajuste) INTO p_cod_ret,p_mensaje;
      RETURN P_COD_RET, P_MENSAJE;
   END IF;

   IF V_DIAS >= 30 THEN
     LET FACTOR = 0;
   ELSE
     LET FACTOR = -1;
   END IF;
/*
   IF pperiod_pago_cap = '2' THEN        -- MENSUAL.
      IF pdia_corte_cap = '50' THEN
         LET factor = 1;                 -- no cuenta el mes.(apert.)
      ELSE
         LET factor = 0;                 -- si cuenta el mes.(apert.)
      END IF;
   ELIF pperiod_pago_cap = '3' THEN      -- BIMESTRAL.
      IF pdia_corte_cap = '50' THEN
         LET factor = 2;                 -- no cuenta el mes.(apert.)
      ELSE
         LET factor = 1;                 -- si cuenta el mes.(apert.)
      END IF;
   ELIF pperiod_pago_cap = '4' THEN      -- TRIMESTRAL.
      IF pdia_corte_cap = '50' THEN
         LET factor = 3;                 -- no cuenta el mes.(apert.)
      ELSE
         LET factor = 2;                 -- si cuenta el mes.(apert.)
      END IF;
   ELIF pperiod_pago_cap = '5' THEN      -- SEMESTRAL.
      IF pdia_corte_cap = '50' THEN
         LET factor = 6;                 -- no cuenta el mes.(apert.)
      ELSE
         LET factor = 5;                 -- si cuenta el mes.(apert.)
      END IF;
   ELIF pperiod_pago_cap = '6' THEN      -- ANUAL.
      IF pdia_corte_cap = '50' THEN
         LET factor = 12;                -- no cuenta el mes.(apert.)
      ELSE
         LET factor = 11;                -- si cuenta el mes.(apert.)
      END IF;
   ELSE 
      LET FACTOR = -1;                   -- EL PERIODO ES MENOR A 30 DIAS
      LET V_DIAS = ABS(V_DIAS) * -1;
   END IF;
*/

   -- DIA MAXIMO PARA SABER SI GENERA CUOTA EN EL MISMO MES,DEPENDIENDO DEL
   -- DIA DE LA APERTURA.
BEGIN
   SELECT valor
   INTO   v_dia_fecha_cuota
   FROM   BDICRED:sd_param
   WHERE  empresa   = p_empresa
   AND    cod_param = '7';

END;

--##########################################################################
   -- CUANDO NO LLEGA FECHA DE GRACIA.
   IF pfecha_gra_cap IS NULL THEN
      LET pfecha_cuota = pfecha_alta;
   ELSE
      -- CUANDO SI LLEGA FECHA DE GRACIA.
      LET pfecha_cuota = pfecha_gra_cap;
      EXECUTE PROCEDURE ins_cuotas(p_empresa     , pnum_credito, pfecha_cuota,
                                   pmonto_cuota  , pfecha_vencim ,pajuste_de_cuota,
                                   ptipo_ajuste  ) INTO  p_cod_ret, p_mensaje;

   END IF;
--##########################################################################

   LET V_DIA_ORIGINAL = DAY(PFECHA_CUOTA);
   WHILE pfecha_cuota < pfecha_vencim 

      --FECHA ANIVERSARIO MAYOR A 30 DIAS
      IF pdia_corte_cap = '50' AND FACTOR >= 0 THEN
         LET V_DIA  = DAY(pfecha_cuota);
         LET V_MES  = MONTH(pfecha_cuota) + factor;
         LET V_ANIO = YEAR(pfecha_cuota);
         IF V_MES > 12 THEN
             LET V_MES = V_MES - 12;
             IF (V_MES/12) < 1 THEN
                LET V_ANIO = V_ANIO + 1;
             ELSE
                LET V_ANIO = V_ANIO + (V_MES/12);
             END IF;
         END IF;
         --pregunta si el dia de la fecha es correcto para el mes en turno
         IF V_MES = 12 THEN
            LET V_ULTIMO_DIA_MES = DAY(MDY(1,1,V_ANIO+1) - 1);
         ELSE
            LET V_ULTIMO_DIA_MES = DAY(MDY(V_MES+1,1,V_ANIO) - 1);
         END IF;
         IF V_DIA < V_DIA_ORIGINAL THEN
            LET V_DIA = V_DIA_ORIGINAL;
         END IF;
         IF V_DIA > V_ULTIMO_DIA_MES THEN
            LET V_DIA = V_ULTIMO_DIA_MES;
         END IF;
         LET pfecha_cuota = MDY(V_MES, V_DIA, V_ANIO);
      --FECHA ANIVERSARIO MENOR A 30 DIAS
      ELIF pdia_corte_cap = '50' AND FACTOR < 0 THEN
         IF V_DIAS = 15 THEN
           LET PFECHA_CUOTA = PFECHA_CUOTA + (V_DIAS * FACTOR);
           IF DAY(PFECHA_CUOTA) <= 15 THEN
              LET PFECHA_CUOTA = MDY(MONTH(PFECHA_CUOTA),15,YEAR(PFECHA_CUOTA));
           ELSE
              IF MONTH(PFECHA_CUOTA)+1 > 12 THEN
                 LET PFECHA_CUOTA = MDY(1,1,YEAR(PFECHA_CUOTA)+1)-1;
              ELSE
                 LET PFECHA_CUOTA = MDY(MONTH(PFECHA_CUOTA)+1,1,YEAR(PFECHA_CUOTA))-1;
              END IF;
           END IF;
         ELSE
           LET pfecha_cuota = pfecha_cuota + (V_DIAS * FACTOR);
         END IF;
      END IF;

      IF pdia_corte_cap = '99' AND
         pperiod_pago_cap = '2' THEN
         IF FACTOR >= 0 THEN         
             -- ESTA FUNCION NOS DICE EL ULTIMO DIA DE DETERMINADO MES.
            LET V_DIA  = 1;
            LET V_MES  = MONTH(pfecha_cuota) + factor +1;
            LET V_ANIO = YEAR(pfecha_cuota);
            IF V_MES > 12 THEN
                LET V_MES = V_MES - 12;
                IF (V_MES/12) < 1 THEN
                   LET V_ANIO = V_ANIO + 1;
                ELSE
                   LET V_ANIO = V_ANIO + (V_MES/12);
                END IF;
            END IF;
             LET pfecha_cuota = MDY(V_MES, V_DIA, V_ANIO)-1 ;
         END IF;
      END IF;

/*
      IF pdia_corte_cap = '99' AND
         pperiod_pago_cap <> '2' THEN
         IF pperiod_pago_cap   = '2' THEN    -- MENSUAL
            LET factor = 1;
         ELIF pperiod_pago_cap = '3' THEN    -- BIMESTRAL
            LET factor = 2;
         ELIF pperiod_pago_cap = '4' THEN    -- TRIMESTRAL
            LET factor = 3;
         ELIF pperiod_pago_cap = '5' THEN    -- SEMESTRAL
            LET factor = 6;
         ELIF pperiod_pago_cap = '6' THEN    -- ANUAL
            LET factor = 12;
         ELSE 
            LET FACTOR = -1;
            LET V_DIAS = ABS(V_DIAS) * -1;
         END IF;
         
         IF FACTOR >= 0 THEN
            -- ESTA FUNCION NOS DICE EL ULTIMO DIA DE DETERMINADO MES.
             LET V_DIA  = 1;
             LET V_MES  = MONTH(pfecha_cuota) + FACTOR + 1;
             LET V_ANIO = YEAR(pfecha_cuota);
             IF V_MES > 12 THEN
                 LET V_MES = V_MES - 12;
                 IF (V_MES/12) < 1 THEN
                    LET V_ANIO = V_ANIO + 1;
                 ELSE
                    LET V_ANIO = V_ANIO + (V_MES/12);
                 END IF;
             END IF;
             LET pfecha_cuota = MDY(V_MES, V_DIA, V_ANIO)-1;
         END IF;
      END IF;
*/
      IF pfecha_cuota <= pfecha_vencim THEN
         EXECUTE PROCEDURE ins_cuotas(p_empresa     , pnum_credito, pfecha_cuota,
                                      pmonto_cuota  , pfecha_vencim , pajuste_de_cuota,
                                      ptipo_ajuste) INTO  p_cod_ret, p_mensaje;
      END IF;

      IF pperiod_pago_cap   = '2' THEN    -- MENSUAL
         LET factor = 1;
      ELIF pperiod_pago_cap = '3' THEN    -- BIMESTRAL
         LET factor = 2;
      ELIF pperiod_pago_cap = '4' THEN    -- TRIMESTRAL
         LET factor = 3;
      ELIF pperiod_pago_cap = '5' THEN    -- SEMESTRAL
         LET factor = 6;
      ELIF pperiod_pago_cap = '6' THEN    -- ANUAL
         LET factor = 12;
      ELSE 
         LET FACTOR = -1;
         LET V_DIAS = ABS(V_DIAS) * -1;
      END IF;
   END WHILE;

   SELECT MAX(fecha_cuota)
   INTO   v_fecha_cuota_ult
   FROM   sd_pagocapit
   WHERE  empresa     = p_empresa
   AND    num_credito = pnum_credito;

   SELECT MAX(fecha_cuota)
   INTO   v_fecha_cuota_pen
   FROM   sd_pagocapit
   WHERE  empresa     = p_empresa
   AND    num_credito = pnum_credito
   AND    fecha_cuota < v_fecha_cuota_ult;

   LET v_fecha_cuota = v_fecha_cuota_pen;

   LET cuantos_dias = pfecha_vencim - v_fecha_cuota;

   -- DIAS MAXIMO PARA SABER SI GENERA LA PENULTIMA CUOTA O NO.
BEGIN
   SELECT valor
   INTO   v_dias_max
   FROM   BDICRED:sd_param
   WHERE  empresa   = p_empresa
   AND    cod_param = 34;
END;

   IF cuantos_dias < v_dias_max THEN
      DELETE FROM sd_pagocapit
      WHERE empresa     = p_empresa
      AND   num_credito = pnum_credito
      AND   fecha_cuota = v_fecha_cuota_ult;

      UPDATE sd_pagocapit
      SET    fecha_cuota = pfecha_vencim
      WHERE  empresa     = p_empresa
      AND    num_credito = pnum_credito
      AND    fecha_cuota = v_fecha_cuota_pen;
   END IF;

   SELECT MAX(fecha_cuota)
   INTO   v_max_fecha
   FROM   sd_pagocapit
   WHERE  empresa     = p_empresa
   AND    num_credito = pnum_credito;

   IF v_max_fecha < pfecha_vencim THEN
      LET pfecha_cuota = pfecha_vencim;
      EXECUTE PROCEDURE ins_cuotas(p_empresa     , pnum_credito, pfecha_cuota,
                                   pmonto_cuota  , pfecha_vencim , pajuste_de_cuota,
                                   ptipo_ajuste) INTO  p_cod_ret, p_mensaje;
   END IF;

   -- SI NO GENERO NINGUNA CUOTA DE CAPITAL SIGNIFICO QUE POR LA PERIODICIDAD
   -- NO ALCANZO PARA GENERAR CUOTAS, Y YO GRABO SIEMPRE UNA AL VTO.
   SELECT COUNT(*)
   INTO   v_no_hay
   FROM   sd_pagocapit
   WHERE  empresa     = p_empresa
   AND    num_credito = pnum_credito;

   IF v_no_hay = 0 then
      LET pfecha_cuota = pfecha_vencim;
      LET pmonto_cuota = pmonto_linea/100;
      EXECUTE PROCEDURE ins_cuotas(p_empresa     , pnum_credito, pfecha_cuota,
                                   pmonto_cuota  , pfecha_vencim , pajuste_de_cuota,
                                   ptipo_ajuste) INTO  p_cod_ret, p_mensaje;
   END IF;
   SELECT ',' || TRIM(VALOR)  || ',' CADENA1
         ,REPLACE(',' || TRIM(VALOR)  || ',', ','||B.NUM_PRODUCTO||',',',ZZ,') CADENA2
   INTO   V_CADENA1,V_CADENA2
   FROM   BDICRED:SD_PARAM A, BDISOLIC:SS_SOLICITUDES B
   WHERE  COD_PARAM  = '52'
   AND    A.EMPRESA = P_EMPRESA
   AND    NUM_SOLICITUD = pnum_credito
   AND    B.EMPRESA = P_EMPRESA;

   IF V_CADENA1 =  V_CADENA2 THEN
      EXECUTE PROCEDURE importes(p_empresa, pnum_credito, pajuste_vencim,
                                 pcuota_con_dec, pmonto_linea) INTO p_cod_ret, p_mensaje;
   END IF;

   RETURN P_COD_RET, P_MENSAJE;
END;
END PROCEDURE;
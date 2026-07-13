CREATE PROCEDURE "informix".interes(
   p_empresa                VARCHAR(3)  ,
   pnum_credito           VARCHAR(20) ,
   pfecha_alta              DATE        ,
   pfecha_vencim            DATE        ,
   pmonto_linea             INTEGER     ,
   pperiod_pag_int          VARCHAR(3)  ,
   pcuota_con_dec           VARCHAR(3)  ,
   pajuste_venc_int         VARCHAR(3)  ,  -- ajuste cuota int.(S,P)
   pajuste_de_cuota         VARCHAR(3)  ,  -- si se ajusta la cuota
   ptipo_calculo            VARCHAR(3)  ,
   pdia_corte_int           VARCHAR(3)  ,
   vfecha_gra_int           DATE )
RETURNING VARCHAR(10), VARCHAR(80);

--########################################################################
--### Programa      : interes.sql                                      ###
--### Descripcion   : GENERACION DE PLANES DE INTERES AUTOMATICAMENTE. ###
--########################################################################

DEFINE  p_cod_ret     VARCHAR(10);
DEFINE  p_mensaje     VARCHAR(80);
DEFINE  SQL_ERR       INTEGER;
DEFINE  ISAM_ERR      INTEGER;
DEFINE  ERROR_INFO    VARCHAR(80);

DEFINE  pfecha_cuota        DATE;
DEFINE  pnum_cuota          INTEGER;
DEFINE  pmonto_cuota        DECIMAL(14,2);
DEFINE  factor              INTEGER;
DEFINE  v_dia_fecha_cuota   INTEGER;
DEFINE  v_fecha_cuota_ult   DATE;
DEFINE  v_fecha_cuota_pen   DATE;
DEFINE  v_fecha_cuota       DATE;
DEFINE  v_dias_max          VARCHAR(50);
DEFINE  cuantos_dias        INTEGER;
DEFINE  v_max_fecha         DATE;
DEFINE  v_no_hay            INTEGER;
DEFINE  pfecha_gra_int      DATE;

DEFINE  v_cuantas_hay       INTEGER;
DEFINE  v_cuota             INTEGER;
DEFINE  vajuste_venc_int    VARCHAR(1);
				
DEFINE  V_DIAS              INTEGER;
DEFINE  V_DIA_ORIGINAL      INTEGER;
DEFINE  V_ULTIMO_DIA_MES    INTEGER;

DEFINE  V_DIA               INTEGER;
DEFINE  V_MES               INTEGER;
DEFINE  V_ANIO              INTEGER;

DEFINE  V_TIPO_TASA         INTEGER;
DEFINE  V_CADENA1           VARCHAR(80);
DEFINE  V_CADENA2           VARCHAR(80);


BEGIN
   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
      LET P_COD_RET = SQL_ERR;
      LET P_MENSAJE = ERROR_INFO;
      RETURN P_COD_RET, P_MENSAJE;
   END EXCEPTION;



   LET vajuste_venc_int  = pajuste_venc_int;
   LET p_cod_ret         = '00000';
   LET P_MENSAJE         = 'PROCESO EXITOSO';
   LET pfecha_cuota      = '';
   LET pnum_cuota        = 0;
   LET pmonto_cuota      = 0;
   LET v_fecha_cuota_ult = NULL;
   LET v_fecha_cuota_pen = NULL;
   LET v_fecha_cuota     = '';
   LET v_dias_max        = '';
   LET cuantos_dias      = 0;
   LET v_max_fecha       = '';
   LET v_no_hay          = 0;
   LET factor            = 0;
   LET pfecha_gra_int    = vfecha_gra_int;

   LET v_cuantas_hay = 0;
   LET v_cuota       = 0;

--#########################################################################

   DELETE FROM sd_paginter
   WHERE  STATUS_CUOTA     = 1
   AND    MONTO_REAL_PAG   = 0
   AND    empresa          = p_empresa
   AND    num_credito      = pnum_credito;

   SELECT EQUIVALENCIA_DIAS
   INTO   V_DIAS
   FROM   BDICRED:SD_CODPINT
   WHERE  EMPRESA = P_EMPRESA 
   AND    PERIOD_PAG_INT = pperiod_pag_int;
			
   IF pperiod_pag_int = '1' THEN
      LET pfecha_cuota = pfecha_vencim;
      LET pnum_cuota   = 1;
      LET pmonto_cuota = 0;
      EXECUTE PROCEDURE inser_cuotas(p_empresa       , pnum_credito, pfecha_cuota ,
                                     pmonto_cuota    , pfecha_vencim , vajuste_venc_int,
                                     pajuste_de_cuota
                                    ) INTO p_cod_ret, p_mensaje;

      RETURN P_COD_RET||'01', P_MENSAJE;
   END IF;

/*
   IF pperiod_pag_int = '3' THEN        -- MENSUAL.
      IF pdia_corte_int = '50' THEN
--         LET factor = 1;                 -- no cuenta el mes.(apert.)
         LET factor = 0;                 -- no cuenta el mes.(apert.)
      ELSE
         LET factor = 0;                 -- si cuenta el mes.(apert.)
      END IF;
   ELIF pperiod_pag_int = '4' THEN      -- BIMESTRAL.
      IF pdia_corte_int = '50' THEN
--         LET factor = 2;                 -- no cuenta el mes.(apert.)
         LET factor = 1;                 -- no cuenta el mes.(apert.)
      ELSE
         LET factor = 1;                 -- si cuenta el mes.(apert.)
      END IF;
   ELIF pperiod_pag_int = '5' THEN      -- TRIMESTRAL.
      IF pdia_corte_int = '50' THEN
--         LET factor = 3;                 -- no cuenta el mes.(apert.)
         LET factor = 2;                 -- no cuenta el mes.(apert.)
      ELSE
         LET factor = 2;                 -- si cuenta el mes.(apert.)
      END IF;
   ELIF pperiod_pag_int = '6' THEN      -- SEMESTRAL.
      IF pdia_corte_int = '50' THEN
--         LET factor = 6;                 -- no cuenta el mes.(apert.)
         LET factor = 5;                 -- no cuenta el mes.(apert.)
      ELSE
         LET factor = 5;                 -- si cuenta el mes.(apert.)
      END IF;
   ELIF pperiod_pag_int = '7' THEN      -- ANUAL.
      IF pdia_corte_int = '50' THEN
--         LET factor = 12;                -- no cuenta el mes.(apert.)
         LET factor = 11;                -- no cuenta el mes.(apert.)
      ELSE
         LET factor = 11;                -- si cuenta el mes.(apert.)
      END IF;
   ELSE
      LET FACTOR = -1;  --PERIODO MENOR A UN MES
   END IF;
*/

   IF V_DIAS >= 30 THEN
     LET FACTOR = 0;
   ELSE
     LET FACTOR = -1;
   END IF;

   -- DIA MAXIMO PARA SABER SI GENERA CUOTA EN EL MISMO MES,DEPENDIENDO DEL
   -- DIA DE LA APERTURA.
   SELECT valor
   INTO   v_dia_fecha_cuota
   FROM   BDICRED:sd_param
   WHERE  empresa   = p_empresa
   AND    cod_param = '7';

--##########################################################################
   -- CUANDO NO LLEGA FECHA DE GRACIA.
   IF pfecha_gra_int IS NULL THEN
      LET pfecha_cuota = pfecha_alta;
   ELSE
      -- CUANDO SI LLEGA FECHA DE GRACIA.
      LET pnum_cuota = 1;
      LET pfecha_cuota = pfecha_gra_int;

      EXECUTE PROCEDURE inser_cuotas(p_empresa    , pnum_credito , pfecha_cuota,
                                     pmonto_cuota , pfecha_vencim  , vajuste_venc_int,
                                     pajuste_de_cuota
                                    ) INTO p_cod_ret, p_mensaje;
   END IF;
--##########################################################################

   LET V_DIA_ORIGINAL = DAY(PFECHA_CUOTA);
   WHILE pfecha_cuota <= pfecha_vencim
      if pfecha_cuota = pfecha_vencim then
         EXIT WHILE;
      end if;

      LET pnum_cuota = pnum_cuota + 1;

      IF pdia_corte_int = '50' AND FACTOR >= 0  THEN
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
         --pregunta se el dia de la fecha es correcto para el mes en cuestion
         if v_mes = 12 then
            let v_ultimo_dia_mes = day(mdy(1,1,v_anio+1)-1);
         else
            let v_ultimo_dia_mes = day(mdy(v_mes+1 ,1,v_anio)-1);
         end if;
         if v_dia < v_ultimo_dia_mes then
            let v_dia = v_dia_original;
         else
            let v_dia = v_ultimo_dia_mes;
         end if;
         LET pfecha_cuota = MDY(V_MES, V_DIA, V_ANIO);
      ELIF PDIA_CORTE_INT = '50' AND FACTOR < 0 THEN
         IF V_DIAS = 15 THEN
           LET PFECHA_CUOTA = PFECHA_CUOTA + (15 * FACTOR);
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
           LET PFECHA_CUOTA = PFECHA_CUOTA + (V_DIAS * FACTOR);
         END IF;
      END IF;

      IF pdia_corte_int = '99' THEN
         -- ESTA FUNCION NOS DICE EL ULTIMO DIA DE DETERMINADO MES.
         LET V_DIA  = 1;
         LET V_MES  = MONTH(pfecha_cuota) + factor + 1;
         LET V_ANIO = YEAR(pfecha_cuota);
         IF V_MES > 12 THEN
             LET V_MES = V_MES - 12;
             IF (V_MES/12) < 1 THEN
                LET V_ANIO = V_ANIO + 1;
             ELSE
                LET V_ANIO = V_ANIO + (V_MES/12);
             END IF;
         END IF;
         LET pfecha_cuota = MDY(V_MES,V_DIA,V_ANIO)-1;
      END IF;
/*
      IF pdia_corte_int = '99' AND
         pperiod_pag_int <> '3' THEN
         IF pperiod_pag_int   = '3' THEN    -- MENSUAL
            LET factor = 1;
         ELIF pperiod_pag_int = '4' THEN    -- BIMESTRAL
            LET factor = 2;
         ELIF pperiod_pag_int = '5' THEN    -- TRIMESTRAL
            LET factor = 3;
         ELIF pperiod_pag_int = '6' THEN    -- SEMESTRAL
            LET factor = 6;
         ELIF pperiod_pag_int = '7' THEN    -- ANUAL
            LET factor = 12;
         ELSE
            LET FACTOR = -1;   --MENOR A  UN MES
         END IF;

         IF FACTOR >= 0 THEN
            -- ESTA FUNCION NOS DICE EL ULTIMO DIA DE DETERMINADO MES.
            LET V_DIA  = 1;
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
            LET pfecha_cuota = MDY(V_MES+1,V_DIA,V_ANIO)-1;
--         ELSE
--            LET pfecha_cuota = pfecha_cuota + (V_DIAS * FACTOR);
         END IF;
      END IF;
*/
      IF pfecha_cuota > pfecha_vencim THEN
         LET pfecha_cuota = pfecha_vencim;
      END IF;

      EXECUTE PROCEDURE inser_cuotas(p_empresa   , pnum_credito, pfecha_cuota,
                                     pmonto_cuota, pfecha_vencim , vajuste_venc_int,
                                     pajuste_de_cuota
                                    ) INTO p_cod_ret, p_mensaje;

      IF ptipo_calculo = '04' THEN
         RETURN P_COD_RET, P_MENSAJE;
      END IF;

      IF pperiod_pag_int   = '3' THEN    -- MENSUAL
         LET factor = 1;
      ELIF pperiod_pag_int = '4' THEN    -- BIMESTRAL
         LET factor = 2;
      ELIF pperiod_pag_int = '5' THEN    -- TRIMESTRAL
         LET factor = 3;
      ELIF pperiod_pag_int = '6' THEN    -- SEMESTRAL
         LET factor = 6;
      ELIF pperiod_pag_int = '7' THEN    -- ANUAL
         LET factor = 12;
	ELSE
         LET FACTOR = -1;
         LET V_DIAS = ABS(V_DIAS) * -1;
      END IF;
   END WHILE;

   SELECT MAX(fecha_cuota)
   INTO   v_fecha_cuota_ult
   FROM   sd_paginter
   WHERE  empresa     = p_empresa
   AND    num_credito = pnum_credito;

   SELECT MAX(fecha_cuota)
   INTO   v_fecha_cuota_pen
   FROM   sd_paginter
   WHERE  empresa      = p_empresa
   AND    num_credito  = pnum_credito
   AND    fecha_cuota  < v_fecha_cuota_ult;

   LET v_fecha_cuota = v_fecha_cuota_pen;
   LET cuantos_dias  = pfecha_vencim - v_fecha_cuota;

   -- DIAS MAXIMO PARA SABER SI GENERA LA PENULTIMA CUOTA O NO.
   SELECT valor
   INTO   v_dias_max
   FROM   BDICRED:sd_param
   WHERE  empresa   = p_empresa
   AND    cod_param = 34;

   IF cuantos_dias < v_dias_max THEN
      DELETE FROM sd_paginter
      WHERE empresa     = p_empresa
      AND   num_credito = pnum_credito
      AND   fecha_cuota = v_fecha_cuota_ult;

      UPDATE sd_paginter
      SET    fecha_cuota   = pfecha_vencim
      WHERE  empresa       = p_empresa
      AND    num_credito   = pnum_credito
      AND    fecha_cuota   = v_fecha_cuota_pen;
   END IF;

   SELECT MAX(fecha_cuota)
   INTO   v_max_fecha
   FROM   sd_paginter
   WHERE  empresa     = p_empresa
   AND    num_credito = pnum_credito;

   IF v_max_fecha <> pfecha_vencim THEN
      LET pfecha_cuota = pfecha_vencim;
      EXECUTE PROCEDURE inser_cuotas(p_empresa   , pnum_credito, pfecha_cuota,
                                     pmonto_cuota, pfecha_vencim , vajuste_venc_int,
                                     pajuste_de_cuota
                                    ) INTO p_cod_ret, p_mensaje;
   END IF;

   -- SI NO GENERO NINGUNA CUOTA DE INTERES SIGNIFICO QUE POR LA PERIODICIDAD
   -- NO ALCANZO PARA GENERAR CUOTAS, Y YO GRABO SIEMPRE UNA AL VTO.

   SELECT COUNT(*)
   INTO   v_no_hay
   FROM   sd_paginter
   WHERE  empresa     = p_empresa
   AND    num_credito = pnum_credito;

   IF v_no_hay = 0 then
      LET pfecha_cuota = pfecha_vencim;
      LET pmonto_cuota = 0;
      EXECUTE PROCEDURE inser_cuotas(p_empresa   , pnum_credito, pfecha_cuota,
                                     pmonto_cuota, pfecha_vencim , vajuste_venc_int,
                                     pajuste_de_cuota
                                    ) INTO p_cod_ret, p_mensaje;
   END IF;

   RETURN P_COD_RET, P_MENSAJE;
END;
END PROCEDURE;
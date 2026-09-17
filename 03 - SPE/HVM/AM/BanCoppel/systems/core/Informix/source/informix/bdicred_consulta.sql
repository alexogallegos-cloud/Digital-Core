cREATE PROCEDURE "informix".consulta(pnum_credito CHAR(20))

   RETURNING CHAR(5),CHAR(20),CHAR(20), CHAR(4),CHAR(5), CHAR(2),
             CHAR(2),MONEY(14,2), DATE, char(3), char(4), char(1),
             char(20), char(3);

   DEFINE cod_ret          CHAR(05);
   DEFINE sqlerr           SMALLINT;
   DEFINE isamerr          SMALLINT;
   DEFINE text             CHAR(150);
   DEFINE v_num_credito    LIKE sd_maecred.num_credito;
   DEFINE v_numcte         LIKE sd_maecred.numcte;
   DEFINE v_cod_linea      LIKE sd_maecred.cod_linea;
   DEFINE v_cod_agricola   LIKE sd_maecred.cod_agricola;
   DEFINE v_divisa         LIKE sd_maecred.divisa;
   DEFINE v_cod_tipcred    LIKE sd_definicion.cod_tipcred;
   DEFINE v_monto_otorgado MONEY(14,2);
   DEFINE v_fecha_vencim   DATE;
   DEFINE v_codigo_ins     CHAR(03);
   DEFINE v_cod_inversion  CHAR(04);
   DEFINE v_tipo_cta       CHAR(01);
   DEFINE v_num_cta        CHAR(20);
   DEFINE v_actividad      LIKE sd_maecred.actividad;
   DEFINE v_num_producto   CHAR(04);

   ON EXCEPTION SET sqlerr, isamerr, text
      LET cod_ret = sqlerr;
      SET DEBUG FILE TO "gen_min.err"; -- se guarda en /users/desarrollo/
      TRACE sqlerr || " * " || isamerr || " * " || text;
      RETURN cod_ret,v_num_credito,v_numcte,v_cod_linea,v_cod_agricola,
             v_divisa,v_cod_tipcred,v_monto_otorgado,v_fecha_vencim,
             v_codigo_ins,v_cod_inversion,v_tipo_cta,v_num_cta,
             v_actividad;
   END EXCEPTION;


   LET cod_ret          = "000";
   LET v_num_credito    = " ";
   LET v_numcte         = " ";
   LET v_cod_linea      = " ";
   LET v_cod_agricola   = " ";
   LET v_divisa         = " ";
   LET v_cod_tipcred    = " ";
   LET v_monto_otorgado = 0;
   LET v_fecha_vencim   = " ";
   LET v_codigo_ins     = " ";
   LET v_cod_inversion  = " ";
   LET v_tipo_cta       = " ";
   LET v_num_cta        = " ";
   LET v_actividad      = " ";
   LET v_num_producto   = " ";

  ---------------------------------------------------------------------------

   IF pnum_credito IS NULL OR
      pnum_credito = " " THEN
      LET cod_ret = "223"; -- CREDITO NULO O BLANCO
      RETURN cod_ret,v_num_credito,v_numcte,v_cod_linea,v_cod_agricola,
             v_divisa,v_cod_tipcred,v_monto_otorgado,v_fecha_vencim,
             v_codigo_ins,v_cod_inversion,v_tipo_cta,v_num_cta,
             v_actividad;
   ELSE
      LET v_num_credito = pnum_credito;
      SELECT num_credito,numcte,cod_linea,cod_agricola,divisa,num_producto,
             fecha_vencim,codigo_ins,cod_inversion,actividad
      INTO v_num_credito,v_numcte,v_cod_linea,v_cod_agricola,
           v_divisa,v_num_producto,v_fecha_vencim,
           v_codigo_ins,v_cod_inversion,v_actividad
      FROM sd_maecred
      WHERE num_credito = v_num_credito;
   END IF;

   IF v_num_credito IS NULL THEN
      LET cod_ret = "224"; -- CREDITO NO EXISTE
      RETURN cod_ret,v_num_credito,v_numcte,v_cod_linea,v_cod_agricola,
             v_divisa,v_cod_tipcred,v_monto_otorgado,v_fecha_vencim,
             v_codigo_ins,v_cod_inversion,v_tipo_cta,v_num_cta,
             v_actividad;
   END IF;

   SELECT monto_otorgado INTO v_monto_otorgado
   FROM sd_maesdos
   WHERE num_credito = v_num_credito;
   IF v_numcte         IS NULL THEN LET v_numcte         = " "; END IF;
   IF v_cod_linea      IS NULL THEN LET v_cod_linea      = " "; END IF;
   IF v_cod_agricola   IS NULL THEN LET v_cod_agricola   = " "; END IF;
   IF v_divisa         IS NULL THEN LET v_divisa         = " "; END IF;
   IF v_num_producto   IS NULL THEN LET v_num_producto   = " "; END IF;
   IF v_monto_otorgado IS NULL THEN LET v_monto_otorgado = 0;   END IF;
   IF v_fecha_vencim   IS NULL THEN LET v_fecha_vencim   = " "; END IF;
   IF v_codigo_ins     IS NULL THEN LET v_codigo_ins     = " "; END IF;
   IF v_cod_inversion  IS NULL THEN LET v_cod_inversion  = " "; END IF;
   IF v_actividad      IS NULL THEN LET v_actividad      = " "; END IF;

   SELECT cod_tipcred INTO v_cod_tipcred
   FROM sd_definicion
   WHERE num_producto = v_num_producto;
   IF v_cod_tipcred IS NULL THEN LET v_cod_tipcred = " "; END IF;

   SELECT tipo_cta,num_cta INTO v_tipo_cta,v_num_cta
   FROM sd_ctascarg
   WHERE num_credito  = v_num_credito AND
         naturaleza   = "A"           AND -- permite abonos a capital.
         con_cap_inte = "C";              -- capital.
   IF v_tipo_cta IS NULL THEN LET v_tipo_cta = " "; END IF;
   IF v_num_cta  IS NULL THEN LET v_num_cta  = " "; END IF;

   RETURN cod_ret,v_num_credito,v_numcte,v_cod_linea,v_cod_agricola,
          v_divisa,v_cod_tipcred,v_monto_otorgado,v_fecha_vencim,v_codigo_ins,
          v_cod_inversion,v_tipo_cta,v_num_cta,v_actividad;
END PROCEDURE;
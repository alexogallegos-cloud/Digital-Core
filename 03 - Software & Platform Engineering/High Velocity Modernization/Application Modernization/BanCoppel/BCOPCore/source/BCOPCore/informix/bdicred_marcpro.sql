CREATE PROCEDURE "informix".marcpro(pnum_credito CHAR(20),
                         psucursal    CHAR(04),
                         pejecutivo   CHAR(08),
                         pfecha_alta  DATE,
                         pmotivo      CHAR(100))
   RETURNING CHAR(5);

   --####################################################################
   --#####                    Define variables                      #####
   --####################################################################

   DEFINE i               SMALLINT;
   DEFINE text            CHAR(100);
   DEFINE sqlerr,isamerr  SMALLINT;
   DEFINE cod_ret         CHAR(5);
   DEFINE v_hay_marcpro   SMALLINT;
   DEFINE v_num_credito   LIKE sd_maecred.num_credito;
   DEFINE v_credito       LIKE sd_maecred.num_credito;
   DEFINE v_sucursal      LIKE sd_maecred.sucursal;

-- ##########################################################################
-- #####                    Control de Errores
-- ##########################################################################

   ON EXCEPTION SET sqlerr, isamerr, text
      LET cod_ret = sqlerr;
      SET DEBUG FILE TO "marcpro.err";
      TRACE sqlerr || " * " || isamerr || " * " || text;
      RETURN cod_ret;
   END EXCEPTION;

   SET LOCK MODE TO WAIT 30;



   --####################################################################
   --#####                 Inicializa Variables                     #####
   --####################################################################

   LET cod_ret       = "000";
   LET v_num_credito = " ";
   LET v_hay_marcpro = 0;

   --#####################################################################
   --######            Inicio de Transaccion                         #####
   --#####################################################################

   IF pnum_credito IS NULL OR
      pnum_credito = " " THEN
      LET cod_ret = "223"; -- CREDITO NULO O BLANCO
      RETURN cod_ret;
   ELSE
      LET v_num_credito = pnum_credito;
   END IF;

   SELECT num_credito INTO v_credito
   FROM sd_maecred
   WHERE num_credito = v_num_credito;
   IF v_credito IS NULL OR
      v_credito = " " THEN
      LET cod_ret = "224"; -- NO EXISTE EL CREDITO EN sd_maecred
      RETURN cod_ret;
   END IF;

   SELECT COUNT(*) INTO v_hay_marcpro
   FROM sd_marcpro
   WHERE num_credito = v_num_credito;

   IF v_hay_marcpro > 0 THEN
      LET cod_ret = "250"; -- CREDITO MARCADO PROBLEMATICO
      RETURN cod_ret;
   END IF;

   IF psucursal IS NULL OR
      psucursal = " " THEN
      LET cod_ret = "205"; -- SUCURSAL NULO O BLANCO
      RETURN cod_ret;
   ELSE
      SELECT sucursal INTO v_sucursal
      FROM sd_maecred
      WHERE num_credito = v_num_credito AND
            sucursal = psucursal;
      IF v_sucursal IS NULL OR
         v_sucursal = " " THEN
         LET cod_ret = "246"; -- EL CREDITO NO ES DE ESA SUCURSAL
         RETURN cod_ret;
      END IF;
   END IF;

   IF pfecha_alta IS NULL OR
      pfecha_alta = " " THEN
      LET cod_ret = "247"; -- FECHA NULA O EN BLANCO
      RETURN cod_ret;
   END IF;

   IF pejecutivo IS NULL OR
      pejecutivo = " " THEN
      LET cod_ret = "210"; -- EJECUTIVO NULO O BLANCO
      RETURN cod_ret;
   END IF;

   IF pmotivo IS NULL OR
      pmotivo = " " THEN
      LET cod_ret = "249"; -- MOTIVO NULO O EN BLANCO
      RETURN cod_ret;
   END IF;

   IF cod_ret != "000" THEN
      RETURN cod_ret;
   ELSE
      BEGIN
         INSERT INTO sd_marcpro VALUES ("001",v_num_credito,psucursal,pejecutivo,
                                        pfecha_alta,"P",pmotivo,"");
      END;
   END IF;
RETURN cod_ret;
END PROCEDURE;
CREATE PROCEDURE "informix".apli_amplicred(pnum_credito    CHAR(20),
                                pregional       CHAR(03),
                                pplaza          CHAR(03),
                                psucursal       CHAR(4),
                                pmonto_aplica   MONEY(14,2),
                                psuper_aplica   DECIMAL(9,3),
                                pcomentarios    CHAR(150),
                                pfecha_hoy      DATE)
   RETURNING CHAR(5);

   --####################################################################
   --#####                    Define variables                      #####
   --####################################################################

   DEFINE i                   SMALLINT;
   DEFINE text                CHAR(100);
   DEFINE sqlerr,isamerr      SMALLINT;
   DEFINE cod_ret             CHAR(5);
   DEFINE v_hay_amplicred     SMALLINT;
   DEFINE v_num_credito       LIKE sd_maecred.num_credito;
   DEFINE v_credito           LIKE sd_maecred.num_credito;
   DEFINE v_monto_otorgado    LIKE sd_maesdos.monto_otorgado;
   DEFINE v_fechas_int_cred   LIKE sd_param.fechas_int_cred;
   DEFINE v_fecha_hoy         LIKE sd_fechas.fecha_hoy;
   DEFINE v_status_amp        CHAR(2);
   DEFINE dFecha              DATE;
   DEFINE v_fecha_vencim      DATE;
   DEFINE cCveSucursal        CHAR(4);
   DEFINE v_existe            SMALLINT;

-- ##########################################################################
-- #####                    Control de Errores
-- ##########################################################################

   ON EXCEPTION SET sqlerr, isamerr, text
      LET cod_ret = sqlerr;
      SET DEBUG FILE TO "apli_amplicred.err"; -- se guarda en /users/desarrollo
      TRACE sqlerr || " * " || isamerr || " * " || text;
      RETURN cod_ret;
   END EXCEPTION;

   SET LOCK MODE TO WAIT 30;


   --####################################################################
   --#####                 Inicializa Variables                     #####
   --####################################################################

   LET cod_ret       = "000";
   LET v_num_credito = " ";
   LET v_credito     = " ";
   LET v_fechas_int_cred  = "";
   LET v_fecha_hoy        = "";
   LET v_fecha_vencim     = "";
   LET v_status_amp       = "";
   LET dFecha             = "";
   LET v_existe           = 0;

   --#####################################################################
   --######            Inicio de Transaccion                         #####
   --#####################################################################

   IF pnum_credito IS NULL OR
      pnum_credito = " " THEN
      LET cod_ret = "223"; -- CREDITO NULO O BLANCO
      RETURN cod_ret;
   ELSE
      LET v_num_credito = pnum_credito;

      SELECT MAX(bdicred:sd_amplicred.fecha)
         INTO dFecha
         FROM bdicred:sd_amplicred
         WHERE bdicred:sd_amplicred.num_credito = v_num_credito;

      IF dFecha IS NOT NULL THEN

         IF dFecha != v_fecha_hoy THEN

            SELECT status_amp
               INTO v_status_amp
               FROM bdicred:sd_amplicred
               WHERE bdicred:sd_amplicred.num_credito = v_num_credito AND
                     bdicred:sd_amplicred.fecha       = dFecha;

            IF v_status_amp = "CO" OR v_status_amp = "AT" OR v_status_amp = "EE" THEN
               LET cod_ret = "412";                -- SOLICITUD ESTA EN TRAMITE
            END IF

         ELSE
            SELECT status_amp
               INTO v_status_amp
               FROM bdicred:sd_amplicred
               WHERE bdicred:sd_amplicred.num_credito = v_num_credito AND
                     bdicred:sd_amplicred.fecha       = v_fecha_hoy;

            IF v_status_amp = "CO" OR v_status_amp = "OP" OR v_status_amp = "AT" OR v_status_amp = "EE" THEN
               IF v_status_amp = "OP" THEN
                  LET cod_ret = "419";             -- SOLICITUD YA FUE APLICADA HOY
               ELSE
                  LET cod_ret = "412";             -- SOLICITUD ESTA EN TRAMITE
               END IF
            ELSE
               IF v_status_amp = "RE" OR v_status_amp = "RV" THEN
                  DELETE FROM bdicred:sd_amplicred
                     WHERE bdicred:sd_amplicred.num_credito = v_num_credito AND
                           bdicred:sd_amplicred.fecha       = v_fecha_hoy;
               END IF
            END IF
         END IF

      END IF

      IF cod_ret != "000" THEN
         RETURN cod_ret;
      END IF

   END IF;

   IF pregional IS NULL OR pregional = "" THEN
      LET cod_ret = "203"; -- CODIGO DE REGIONAL NULO O BLANCO
      RETURN cod_ret;
   END IF;

   IF pplaza IS NULL OR pplaza = "" THEN
      LET cod_ret = "204"; --  CODIGO DE PLAZA NULO O BLANCO
      RETURN cod_ret;
   END IF;

   IF psucursal IS NULL OR psucursal = "" THEN
      LET cod_ret = "205"; --  CODIGO DE SUCURSAL NULO O BLANCO
      RETURN cod_ret;
   END IF;

   IF pmonto_aplica IS NULL OR pmonto_aplica <= 0 THEN
      LET cod_ret = "254"; -- MONTO NULO O MENOR= A CERO.
      RETURN cod_ret;
   END IF;

   SELECT num_credito,sucursal, fecha_vencim
      INTO v_credito, cCveSucursal, v_fecha_vencim
      FROM sd_maecred
      WHERE num_credito = v_num_credito;
   IF v_credito IS NULL OR v_credito = " " THEN
      LET cod_ret = "224"; -- NO EXISTE EL CREDITO EN sd_maecred
      RETURN cod_ret;
   END IF;
   IF cCveSucursal != psucursal THEN
      LET cod_ret = "246"; -- EL CREDITO NO ES DE LA SUCURSAL QUE SOLICITA
      RETURN cod_ret;
   END IF;

   IF v_fecha_vencim < pfecha_hoy THEN
      LET cod_ret = "346"; -- fecha de vencimiento anterior al dia de hoy
      RETURN cod_ret;
   END IF;


   SELECT monto_otorgado INTO v_monto_otorgado
   FROM sd_maesdos
   WHERE num_credito = v_num_credito;

   IF psucursal IS NULL OR psucursal = " " THEN
      LET cod_ret = "205"; -- SUCURSAL NULO O BLANCO
      RETURN cod_ret;
   END IF;

   IF pcomentarios IS NULL OR pcomentarios = " " THEN
      LET cod_ret = "249"; -- COMENTARIO NULO O EN BLANCO
      RETURN cod_ret;
   END IF;

   IF cod_ret != "000" THEN
      RETURN cod_ret;
   ELSE
      SELECT COUNT(*) INTO v_existe from sd_amplicred
      where num_credito = v_num_credito and
            fecha       = pfecha_hoy;
      if v_existe > 0 then
         let cod_ret = "345"; -- ya existe solicitud de ampliacion
         return cod_ret;
      ELSE
         BEGIN
            INSERT INTO sd_amplicred VALUES (v_num_credito,
                                             pfecha_hoy,
                                             v_monto_otorgado,
                                             pregional,
                                             pplaza,
                                             psucursal,
                                             " ",
                                             " ",
                                             " ",
                                             pmonto_aplica,
                                             psuper_aplica,
                                             " ",
                                             pcomentarios,
                                             "CO");
         END;
      END IF;
   END IF;
   RETURN cod_ret;
END PROCEDURE;
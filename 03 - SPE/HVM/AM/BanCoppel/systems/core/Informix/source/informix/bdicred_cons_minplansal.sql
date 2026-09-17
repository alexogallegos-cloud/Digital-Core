CREATE PROCEDURE "informix".cons_minplansal(pnum_credito CHAR(20),
                                 pnum_minis   SMALLINT)

   RETURNING CHAR(5), DATE, DATE, CHAR(40), CHAR(45), CHAR(33), CHAR(80),
             MONEY(14,2), MONEY(14,2), DATE, SMALLINT, MONEY(14,2),
             MONEY(14,2),CHAR(01);

   --####################################################################
   --#####                    Define variables                      #####
   --####################################################################

   DEFINE i                SMALLINT;
   DEFINE text             CHAR(100);
   DEFINE sqlerr,isamerr   SMALLINT;
   DEFINE cod_ret          CHAR(5);
   DEFINE v_ciclo          SMALLINT;
   DEFINE v_conta          SMALLINT;
   DEFINE v_clien          LIKE sd_maecred.numcte;
   DEFINE v_apell_paterno  CHAR(15);
   DEFINE v_apell_materno  CHAR(15);
   DEFINE v_nombre1        CHAR(15);
   DEFINE v_nombre2        CHAR(15);
   DEFINE v_razon_social   CHAR(60);

   DEFINE v_num_credito      LIKE sd_maecred.num_credito;
   DEFINE v_numcte           LIKE sd_maecred.numcte;
   DEFINE v_cliente          CHAR(60);
   DEFINE v_descripcion      CHAR(40);
   DEFINE v_num_producto     LIKE sd_maecred.num_producto;
   DEFINE v_nombre_prod      CHAR(42);
   DEFINE v_fecha_apertura   LIKE sd_maecred.fecha_apertura;
   DEFINE v_fecha_vencim     LIKE sd_maecred.fecha_vencim;
   DEFINE v_divisa           LIKE sd_maecred.divisa;
   DEFINE v_divisas          CHAR(33);
   DEFINE vg_cliente         CHAR(80);
   DEFINE vg_producto        CHAR(45);
   DEFINE v_ejecutivo        LIKE sd_maecred.ejecutivo;
   DEFINE v_monto_ministrado MONEY(14,2);  --LIKE sd_detminis.monto__otorgado;
   DEFINE v_monto_real_otorg MONEY(14,2);  --LIKE sd_detminis.monto_real_otorg;
   DEFINE v_monto_por_minis  LIKE sd_detminis.sdo_cuota;
   DEFINE v_fecha_programada LIKE sd_detminis.fecha_programada;
   DEFINE v_num_minis        LIKE sd_detminis.num_minis;
   DEFINE v_monto_otorgado   MONEY(14,2);   --LIKE sd_detminis.monto_otorgado;
   DEFINE v_sdo_cuota        LIKE sd_detminis.sdo_cuota;
   DEFINE v_status_ministra  LIKE sd_detminis.status_ministra;
   DEFINE v_ejecut           CHAR(54);

-- ##########################################################################
-- #####                    Control de Errores
-- ##########################################################################

   ON EXCEPTION SET sqlerr, isamerr, text
      LET cod_ret = sqlerr;
      SET DEBUG FILE TO "cons_minplansal.err"; -- se guarda en /users/desarrollo
      TRACE sqlerr || " * " || isamerr || " * " || text;
      RETURN cod_ret,v_fecha_apertura,v_fecha_vencim,v_nombre_prod,
             v_ejecut,v_divisas,vg_cliente,v_monto_ministrado,v_monto_por_minis,
             v_fecha_programada,v_num_minis,v_sdo_cuota,v_monto_real_otorg,
             v_status_ministra;
   END EXCEPTION;



   --####################################################################
   --#####                 Inicializa Variables                     #####
   --####################################################################

   LET cod_ret            = "000";
   LET v_ciclo            = 0;
   LET v_conta            = 0;
   LET v_num_credito      = " ";
   LET v_fecha_apertura   = " ";
   LET v_fecha_vencim     = " ";
   LET v_nombre_prod      = " ";
   LET v_cliente          = " ";
   LET v_ejecut           = " ";
   LET v_numcte           = " ";
   LET v_divisa           = " ";
   LET v_divisas          = " ";
   LET vg_cliente         = " ";
   LET v_monto_ministrado = 0;
   LET v_monto_por_minis  = 0;
   LET v_fecha_programada = " ";
   LET v_num_minis        = 0;
   LET v_monto_otorgado   = 0;
   LET v_sdo_cuota        = 0;
   LET v_monto_por_minis  = 0;
   LET v_monto_real_otorg = 0;
   LET v_status_ministra  = " ";

   --#####################################################################
   --######            Inicio de Transaccion                         #####
   --#####################################################################

   IF pnum_credito IS NULL OR
      pnum_credito = " " THEN
      LET cod_ret = "223"; -- CREDITO NULO O BLANCO
      RETURN cod_ret,v_fecha_apertura,v_fecha_vencim,v_nombre_prod,
             v_ejecut,v_divisas,vg_cliente,v_monto_ministrado,v_monto_por_minis,
             v_fecha_programada,v_num_minis,v_sdo_cuota,v_monto_real_otorg,
             v_status_ministra;
   ELSE
      LET v_num_credito = pnum_credito;
   END IF;

   SELECT num_credito INTO v_num_credito
   FROM sd_maecred
   WHERE num_credito = v_num_credito;
   IF v_num_credito IS NULL THEN
      LET cod_ret = "224"; -- NO EXISTE EL CREDITO EN sd_maecred
      RETURN cod_ret,v_fecha_apertura,v_fecha_vencim,v_nombre_prod,
             v_ejecut,v_divisas,vg_cliente,v_monto_ministrado,v_monto_por_minis,
             v_fecha_programada,v_num_minis,v_sdo_cuota,v_monto_real_otorg,
             v_status_ministra;
   END IF;

   SELECT fecha_apertura,fecha_vencim,num_producto,ejecutivo,
          divisa,numcte
   INTO v_fecha_apertura,v_fecha_vencim,v_num_producto,v_ejecutivo,
        v_divisa,v_numcte
   FROM sd_maecred
   WHERE num_credito = v_num_credito;

   SELECT nombre_prod INTO v_nombre_prod
   FROM sd_definicion
   WHERE num_producto = v_num_producto;
   IF v_nombre_prod IS NULL THEN
      LET v_nombre_prod = " ";
   ELSE
--      LET v_nombre_prod = TRIM (v_num_producto) || " " ||
--          TRIM (v_nombre_prod);
   END IF;

   SELECT nombre INTO v_ejecut
   FROM bdinteg:si_ejecut
   WHERE ejecutivo = v_ejecutivo;
   IF v_ejecut IS NULL THEN
      LET v_ejecut = " ";
   ELSE
      LET v_ejecut = TRIM (v_ejecutivo) || " " ||
          TRIM (v_ejecut);
   END IF;

   SELECT descripcion INTO v_divisas
   FROM bdinteg:si_divisas
   WHERE divisa = v_divisa;

   IF v_numcte IS NULL THEN
      LET v_numcte = " ";
   ELSE
      SELECT numcte,apell_paterno,apell_materno,nombre1,nombre2,razon_social
      INTO v_numcte,v_apell_paterno,v_apell_materno,v_nombre1,v_nombre2,
           v_razon_social
      FROM bdinteg:si_cliente
      WHERE numcte = v_numcte;
      IF v_razon_social IS NULL OR
         v_razon_social = " " THEN
         LET v_cliente =
            TRIM (v_nombre1) || " " ||
            TRIM (v_nombre2);
         LET v_cliente = TRIM (v_cliente) || " " ||
            TRIM (v_apell_paterno) || " " ||
            TRIM (v_apell_materno);
      ELSE
         LET v_cliente = v_razon_social;
      END IF;
      LET vg_cliente = TRIM (v_numcte) || " " ||
          TRIM (v_cliente);
   END IF;

   SELECT SUM(sdo_cuota) INTO v_monto_ministrado
   FROM sd_detminis
   WHERE num_credito  = v_num_credito AND
         status_ministra = "A";

   IF v_monto_ministrado IS NULL OR
      v_monto_ministrado = 0 THEN
      LET v_monto_ministrado = 0;
   END IF;

   SELECT SUM(sdo_cuota) INTO v_monto_por_minis
   FROM sd_detminis
   WHERE num_credito  = v_num_credito AND
         status_ministra = "P";

   IF v_monto_por_minis IS NULL OR
      v_monto_por_minis = 0 THEN
      LET v_monto_por_minis = 0;
   END IF;

   FOREACH
      SELECT fecha_programada,num_minis,sdo_cuota,monto_otorgado,
             status_ministra
      INTO v_fecha_programada,v_num_minis,v_sdo_cuota,v_monto_real_otorg,
           v_status_ministra
      FROM sd_detminis
      WHERE num_credito = v_num_credito

      IF v_fecha_programada IS NULL OR
         v_fecha_programada = " " THEN
         LET v_fecha_programada = " ";
      END IF;

      IF v_sdo_cuota IS NULL OR
         v_sdo_cuota = 0 THEN
         LET v_sdo_cuota = 0;
      END IF;

      IF v_monto_real_otorg IS NULL OR
         v_monto_real_otorg = 0 THEN
         LET v_monto_real_otorg = 0;
      END IF;

      LET v_ciclo = v_ciclo + 1;

      IF v_ciclo <= pnum_minis THEN
         CONTINUE FOREACH;
      END IF;

      IF vg_cliente IS NULL THEN
         LET vg_cliente = " ";
      END IF;

      RETURN cod_ret,v_fecha_apertura,v_fecha_vencim,v_nombre_prod,
             v_ejecut,v_divisas,vg_cliente,v_monto_ministrado,v_monto_por_minis,
             v_fecha_programada,v_num_minis,v_sdo_cuota,v_Monto_real_otorg,
             v_status_ministra
      WITH RESUME;
      LET v_conta = v_conta + 1;
   END FOREACH;
END PROCEDURE;
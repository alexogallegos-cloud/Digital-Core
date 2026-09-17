CREATE PROCEDURE "informix".cliente(pnum_credito  CHAR(20),
                                    pempresa      CHAR(3))

   RETURNING CHAR(5), CHAR(20), CHAR(60);

   --####################################################################
   --#####                    Define variables                      #####
   --####################################################################

   DEFINE i                  SMALLINT;
   DEFINE text               CHAR(100);
   DEFINE sqlerr,isamerr     SMALLINT;

   DEFINE cod_ret            CHAR(5);
   DEFINE v_num_credito      CHAR(20);
   DEFINE v_numcte           CHAR(20);
   DEFINE v_apell_paterno    CHAR(15);
   DEFINE v_apell_materno    CHAR(15);
   DEFINE v_nombre1          CHAR(15);
   DEFINE v_nombre2          CHAR(15);
   DEFINE v_razon_social     CHAR(40);
   DEFINE v_cliente          CHAR(60);

-- ##########################################################################
-- #####                    Control de Errores
-- ##########################################################################

   ON EXCEPTION SET sqlerr, isamerr, text
      LET cod_ret = sqlerr;
      SET DEBUG FILE TO "cliente.err"; -- se guarda en /users/cs2
      TRACE sqlerr || " * " || isamerr || " * " || text;
      RETURN cod_ret,v_numcte,v_cliente;
   END EXCEPTION;



   --####################################################################
   --#####                 Inicializa Variables                     #####
   --####################################################################

   LET cod_ret            = "000";
   LET i                  = 1;
   LET v_numcte           = " ";
   LET v_apell_paterno    = " ";
   LET v_apell_materno    = " ";
   LET v_nombre1          = " ";
   LET v_nombre2          = " ";
   LET v_cliente          = " ";
   LET v_razon_social     = " ";

   --#####################################################################
   --######            Inicio de Transaccion                         #####
   --#####################################################################

   IF pnum_credito IS NULL OR
      pnum_credito = " " THEN
      LET cod_ret = "223"; -- NUMERO DE CREDITO NULO O BLANCO
      RETURN cod_ret,v_numcte,v_cliente;
   ELSE
      LET v_num_credito = pnum_credito;
      SELECT num_credito,numcte INTO v_num_credito,v_numcte
      FROM sd_maecred
      WHERE num_credito = pnum_credito
      AND empresa       = pempresa;
      IF v_num_credito IS NULL OR
         v_num_credito = " " THEN
         LET cod_ret = "224"; -- NO EXISTE EL CREDITO EN sd_maecred
         RETURN cod_ret,v_numcte,v_cliente;
      END IF;
      IF v_numcte IS NULL OR
         v_numcte = " " THEN
         LET cod_ret = "202"; -- CLIENTE NULO O EN BLANCO EN sd_maecred
         RETURN cod_ret,v_numcte,v_cliente;
      ELSE
         SELECT numcte,apell_paterno,apell_materno,nombre1,nombre2,razon_social
         INTO v_numcte,v_apell_paterno,v_apell_materno,v_nombre1,v_nombre2,
              v_razon_social
         FROM bdinteg:si_cliente
         WHERE numcte = v_numcte
         AND empresa  = pempresa;
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
      END IF;
   END IF;
   RETURN cod_ret,v_numcte,v_cliente;
END PROCEDURE;
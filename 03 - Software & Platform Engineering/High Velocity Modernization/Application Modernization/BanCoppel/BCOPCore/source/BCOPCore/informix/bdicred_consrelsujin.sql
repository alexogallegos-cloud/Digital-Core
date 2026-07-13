CREATE PROCEDURE "informix".consrelsujin(pnum_cliente CHAR(20))

   RETURNING CHAR(5), CHAR(30), CHAR(30), CHAR(30), CHAR(30), CHAR(30),
             CHAR(30), CHAR(30), CHAR(30), SMALLINT, DECIMAL(9,3), SMALLINT,
             DECIMAL(9,3);

   --####################################################################
   --#####                    Define variables                      #####
   --####################################################################

   DEFINE i                  SMALLINT;
   DEFINE text               CHAR(100);
   DEFINE sqlerr,isamerr     SMALLINT;
   DEFINE cod_ret            CHAR(5);

   DEFINE v_num_cliente      char(20);  --LIKE sd_listanegrabr.numcte;
   DEFINE v_cliente          char(20);  --LIKE sd_listanegrabr.numcte;
   DEFINE v_distrito         char(5);    --LIKE sd_ddruralbr.descrip_ddr;
   DEFINE v_cod_ddr          char(5);   --LIKE sd_ddruralbr.cod_ddr;
   DEFINE v_cod_ctroapoyo    char(5);   --LIKE Sd_centroapbr.descrip_ctroapoyo;
   DEFINE v_nombre_predio    char(30);  --LIKE sd_sujecred.nombre_predio;
   DEFINE v_ent_federat      CHAR(30);
   DEFINE v_mun_predio       CHAR(30);
   DEFINE v_cuantos_int      SMALLINT;
   DEFINE v_hay_sujecredbr   SMALLINT;
   DEFINE v_superf_total     DECIMAL(9,3);
   DEFINE v_presidente       char(20); --LIKE sd_sujecred.presidente;
   DEFINE v_secretario       char(20);  --LIKE sd_sujecred.secretario;
   DEFINE v_tesorero         char(20);  --LIKE sd_sujecred.tesorero;
   DEFINE v_total_integran   smallint;  --LIKE sd_sujecred.total_integrantes;
   DEFINE v_superficie_total decimal(9,3);  --LIKE sd_calcte.superficie;
   DEFINE v_descrip_ctroapo  char(30);  --iLIKE sd_centroapbr.descrip_ctroapoyo;

-- ##########################################################################
-- #####                    Control de Errores
-- ##########################################################################

   ON EXCEPTION SET sqlerr, isamerr, text
      LET cod_ret = sqlerr;
      SET DEBUG FILE TO "consrelsujin.err"; -- se guarda en /users/desarrollo
      TRACE sqlerr || " * " || isamerr || " * " || text;
      RETURN cod_ret,v_nombre_predio,v_ent_federat,v_mun_predio,v_distrito,
             v_cod_ctroapoyo,v_presidente,v_secretario,v_tesorero,
             v_total_integran,v_superficie_total,v_cuantos_int,v_superf_total;
   END EXCEPTION;


   --####################################################################
   --#####                 Inicializa Variables                     #####
   --####################################################################

   LET cod_ret            = "000";
   LET v_num_cliente      = " ";
   LET v_ent_federat      = " ";
   LET v_mun_predio       = " ";
   LET v_cod_ddr          = 0;
   LET v_distrito         = " ";
   LET v_cod_ctroapoyo    = " ";
   LET v_nombre_predio    = " ";
   LET v_presidente       = " ";
   LET v_secretario       = " ";
   LET v_tesorero         = " ";
   LET v_total_integran   = 0;
   LET v_superficie_total = 0;
   LET v_descrip_ctroapo  = " ";
   LET v_cuantos_int      = 0;
   LET v_superf_total     = 0;

   --#####################################################################
   --######            Inicio de Transaccion                         #####
   --#####################################################################

   IF pnum_cliente IS NULL OR
      pnum_cliente = " " THEN
      LET cod_ret = "202"; -- CLIENTE NULO O BLANCO
   ELSE
      LET v_num_cliente = pnum_cliente;
   END IF;

let v_num_cliente = v_num_cliente;


   SELECT nvl(numcte, " ")  INTO v_cliente
   FROM bdinteg:si_cliente
   WHERE numcte = "00000000045"; -- v_num_cliente;
{   IF v_cliente IS NULL OR
      v_cliente = " " THEN
      LET cod_ret = "238"; -- NO EXISTE EL CLIENTE EN CENTRAL
      RETURN cod_ret,v_nombre_predio,v_ent_federat,v_mun_predio,v_distrito,
             v_cod_ctroapoyo,v_presidente,v_secretario,v_tesorero,
             v_total_integran,v_superficie_total,v_cuantos_int,v_superf_total;
   END IF;


   SELECT COUNT(*) INTO v_hay_sujecredbr
   FROM sd_sujecred
   WHERE numcte = v_num_cliente;
   IF v_hay_sujecredbr = 0 THEN
      LET cod_ret = "261"; -- NO EXISTE EL CLIENTE EN sd_sujecred
      RETURN cod_ret,v_nombre_predio,v_ent_federat,v_mun_predio,v_distrito,
             v_cod_ctroapoyo,v_presidente,v_secretario,v_tesorero,
             v_total_integran,v_superficie_total,v_cuantos_int,v_superf_total;
   END IF;

   SELECT nvl(cod_ddr,0), nvl(cod_ctroapoyo," "), nvl(nombre_predio," "), nvl(presidente," "), nvl(secretario," "), nvl(tesorero," "),
          nvl(total_integrantes,0)
   INTO v_cod_ddr,v_cod_ctroapoyo,v_nombre_predio,v_presidente,v_secretario,
        v_tesorero,v_total_integran
   FROM sd_sujecred
   WHERE numcte = v_num_cliente;



   SELECT bdicred:sd_calcte.superficie
      INTO v_superficie_total
      FROM bdicred:sd_calcte
      WHERE bdicred:sd_calcte.numcte = v_num_cliente;

--   SELECT descrip_ddr INTO v_distrito
--   FROM sd_ddruralbr
--   WHERE cod_ddr = v_cod_ddr;

--   SELECT descrip_ctroapoyo
--   INTO v_cod_ctroapoyo
--   FROM sd_centroapbr
--   WHERE cod_ddr = v_cod_ddr AND
--         cod_ctroapoyo = v_cod_ctroapoyo;

   SELECT COUNT(*) INTO v_cuantos_int
   FROM sd_intpred
   WHERE numcte = v_num_cliente;


   SELECT SUM(sup_total) INTO v_superf_total
   FROM sd_intpred
   WHERE numcte = v_num_cliente;

let v_num_cliente = v_num_cliente;
}
   RETURN cod_ret,v_nombre_predio,v_ent_federat,v_mun_predio,v_distrito,
          v_cod_ctroapoyo,v_presidente,v_secretario,v_tesorero,
          v_total_integran,v_superficie_total,v_cuantos_int,v_superf_total;
END PROCEDURE;
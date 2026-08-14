CREATE PROCEDURE "informix".consulta_lim00(vnum_credito CHAR(20),
                                           nreng        SMALLINT)
   RETURNING CHAR(5),
             INTEGER,
             CHAR(4),
             CHAR(12),
             CHAR,
             MONEY(14,2),
             CHAR(2),
             CHAR;         -- Linea 10

-- ****************************************************************
--                   Definicion de variables
-- ****************************************************************

   DEFINE cod_ret             CHAR(5);
   DEFINE i                   SMALLINT;
   DEFINE n                   SMALLINT;
   DEFINE vid_garan           INTEGER;
   DEFINE v1id_garan          INTEGER; -- Linea 1
   DEFINE v1cod_garan         CHAR(4);
   DEFINE v1grupo_garan       CHAR(12);
   DEFINE v1cac               CHAR;
   DEFINE v1val_garantot      MONEY(14,2);
   DEFINE v1divisa            CHAR(2);
   DEFINE v1credito           CHAR(15);
   DEFINE v1status            CHAR;
   DEFINE sqlerr              SMALLINT;
   DEFINE isamerr             SMALLINT;
   DEFINE text                CHAR(80);

-- ****************************************************************
--                      Control de errores
-- ****************************************************************

   ON EXCEPTION SET sqlerr, isamerr, text
      LET cod_ret = sqlerr;
      LET text = text || ": " || vnum_credito;
      SET DEBUG FILE TO "consulta_lim.err";
      TRACE sqlerr || " * " || isamerr || " * " || text;
      RETURN cod_ret,v1id_garan,v1cod_garan,v1grupo_garan,v1cac,v1val_garantot,
             v1divisa,v1status;
   END EXCEPTION;


-- ****************************************************************
--                    Validaciones iniciales
-- ****************************************************************

   LET cod_ret        = "000";
   LET v1id_garan     = 0;
   LET v1cod_garan    = " ";
   LET v1grupo_garan  = " ";
   LET v1cac          = " ";
   LET v1credito      = " ";
   LET v1val_garantot = 0.0;
   LET v1divisa       = " ";
   LET v1status       = " ";
   LET v1credito      = vnum_credito[1,15];

   IF ((SELECT COUNT(*) FROM bdigaran:sg_maegaran
        WHERE num_credito[1,15] = v1credito) = 0) THEN
      LET cod_ret = "322";
      RETURN cod_ret,v1id_garan,v1cod_garan,v1grupo_garan,v1cac,v1val_garantot,
             v1divisa,v1status;
   END IF

-- ****************************************************************
--                     Inicio de transaccion
-- ****************************************************************

   LET n = 1;
   LET i = 0;

   FOREACH
      SELECT id_garan INTO vid_garan
      FROM bdigaran:sg_maegaran
      WHERE num_credito[1,15] = v1credito

--    IF i > 10 THEN
--    RAISE EXCEPTION 350 , 0, " Demasiadas garantias en el credito consultado";
--    END IF

      IF nreng > 0 AND n <= nreng THEN
         LET n = n + 1;
         CONTINUE FOREACH;
      END IF

      LET v1id_garan = vid_garan;

      SELECT cod_garan,grupo_garan,cac,val_garantot,divisa,status_garan
      INTO v1cod_garan,v1grupo_garan,v1cac,v1val_garantot,v1divisa,v1status
      FROM bdigaran:sg_maegaran
      WHERE num_credito[1,15] = v1credito AND id_garan = vid_garan;

      IF v1grupo_garan[1] = "1" THEN
         LET v1grupo_garan = "HIPOTECARIA";
      ELIF v1grupo_garan[1] = "2" THEN
         LET v1grupo_garan = "BANCARIA";
      ELIF v1grupo_garan[1] = "3" THEN
         LET v1grupo_garan = "F. SOLIDARIA";
      ELIF v1grupo_garan[1] = "4" THEN
         LET v1grupo_garan = "PRENDARIA";
      ELIF v1grupo_garan[1] = "5" THEN
         LET v1grupo_garan = "SEGURO";
      ELIF v1grupo_garan[1] = "6" THEN
         LET v1grupo_garan = "FIDUCIARIA";
      ELSE
         LET v1grupo_garan = "COMERCIAL";
      END IF

      RETURN cod_ret,v1id_garan,v1cod_garan,v1grupo_garan,v1cac,v1val_garantot,
             v1divisa,v1status
      WITH RESUME;

   END FOREACH
END PROCEDURE;
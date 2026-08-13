CREATE PROCEDURE "informix".validames(p_fecha DATE, p_meses SMALLINT)

RETURNING DATE;

   DEFINE v_fecha_finmes  DATE;
   DEFINE v_dia           DATE;
   DEFINE v_mes           DATE;
   DEFINE v_ano           DATE;

   
   LET v_fecha_finmes = NULL;
   LET v_dia          = 0;

   BEGIN

      WHILE 1 = 1
         ON EXCEPTION IN (-1267)
            LET v_dia = v_dia + 1;
         END EXCEPTION;

         LET v_fecha_finmes = DATE(EXTEND(p_fecha, YEAR TO DAY)
                              - v_dia UNITS DAY
                              + p_meses UNITS MONTH);
            EXIT WHILE;
      END WHILE;

      RETURN v_fecha_finmes;
   END;
END PROCEDURE

DOCUMENT
"Spl para obtener la fecha futura en base al ",
"numero de meses que se le de en el parametro",
"valida que al sumar 1 mes al 31 de enero controla el error para ",
"obtener la fecha de fechrero por ejemplo",
"base de datos: bdicred",
"AUTOR : Jose Cruz Narvaez Guzman",
"FECHA : 19/abril/2001",
"Ver.  : 1.0",
"Mod   : ";

CREATE PROCEDURE "informix".con_adeupago(f_num_credito CHAR(20),
                                         f_empresa     CHAR(3))
RETURNING CHAR(5),      -- Codigo Retorno
         CHAR(60),      -- Nombre Cliente
         CHAR(4),       -- Num Producto
         CHAR(30),      -- Nombre Producto
         CHAR(2),       -- Divisa
         CHAR(25),      -- Nombre Divisa
         MONEY(14,2),   -- Capital Vigente
         MONEY(14,2),   -- Interes Vigente
         MONEY(14,2),   -- Capital Vencido
         MONEY(14,2),   -- Interes Vencido
         MONEY(14,2),   -- Interes Moratorio
         CHAR(2),       -- Status del Credito
         CHAR(20);      -- Cuenta Asociada Al Credito

-- ############################################################################
-- #                        Definicion de Variables                           #
-- ############################################################################
DEFINE v_codret     CHAR(5);
DEFINE sqlerr       INTEGER;
DEFINE r_nomcte     CHAR(60);
DEFINE r_producto   CHAR(4);
DEFINE r_nomprod    CHAR(30);
DEFINE r_divisa     CHAR(2);
DEFINE r_nomdiv     CHAR(25);
DEFINE r_capvig     MONEY(14,2);
DEFINE r_intvig     MONEY(14,2);
DEFINE r_capven     MONEY(14,2);
DEFINE r_intven     MONEY(14,2);
DEFINE r_intmor     MONEY(14,2);
DEFINE r_stcred     CHAR(2);
DEFINE v_hoy        DATE;
DEFINE v_rs         CHAR(40);
DEFINE v_appa       CHAR(15);
DEFINE v_apma       CHAR(15);
DEFINE v_nom1       CHAR(15);
DEFINE v_nom2       CHAR(15);
DEFINE v_sdocap     MONEY(14,2);
DEFINE v_fcuota      DATE;
DEFINE c_empresa     LIKE sd_ctascarg.empresa;
DEFINE c_numero      LIKE sd_ctascarg.numero;
DEFINE c_con_cap     LIKE sd_ctascarg.con_cap_inte;
DEFINE c_naturale    LIKE sd_ctascarg.naturaleza;
DEFINE c_num_credito LIKE sd_ctascarg.num_credito;
DEFINE c_tipo        LIKE sd_ctascarg.tipo_cta;
DEFINE c_num_cta     LIKE sd_ctascarg.num_cta;
DEFINE c_num_nomi    LIKE sd_ctascarg.num_nomina;
-- ############################################################################
-- #                        Asignacion de Variables                           #
-- ############################################################################
LET v_codret     = "000";
LET sqlerr       = 0;
LET r_nomcte     = "";
LET r_producto   = "";
LET r_nomprod    = "";
LET r_divisa     = "";
LET r_nomdiv     = "";
LET r_capvig     = 0;
LET r_intvig     = 0;
LET r_capven     = 0;
LET r_intven     = 0;
LET r_intmor     = 0;
LET r_stcred     = "";
LET v_fcuota     = "";
LET v_appa       = "";
LET v_apma       = "";
LET v_nom1       = "";
LET v_nom2       = "";
LET v_rs         = "";
LET c_empresa    = "";
LET c_numero      = 0;
LET c_con_cap     = " ";
LET c_naturale    = " ";
LET c_num_credito = " ";
LET c_tipo        = " ";
LET c_num_cta     = " ";
LET c_num_nomi    = " ";
SELECT fecha_hoy INTO v_hoy FROM sd_fechas
WHERE empresa = f_empresa;
-- ############################################################################
-- #                    Control de Errores para INFORMIX                      #
-- ############################################################################
BEGIN
 ON EXCEPTION
      SET sqlerr
      LET v_codret = sqlerr;
      RETURN v_codret, r_nomcte, r_producto, r_nomprod, r_divisa, r_nomdiv,
             r_capvig, r_intvig, r_capven  , r_intven , r_intmor, r_stcred,
             c_num_cta;
 END EXCEPTION;


-- ############################################################################
-- #                              Codigo Principal                            #
-- ############################################################################

SELECT nombre1, nombre2, apell_paterno, apell_materno, razon_social,
       a.num_producto, nombre_prod, a.divisa, descripcion, status_cred
  INTO v_nom1, v_nom2, v_appa, v_apma, v_rs, r_producto, r_nomprod, r_divisa,
       r_nomdiv, r_stcred
  FROM sd_maecred a, bdinteg:si_cliente b, bdinteg:si_divisas c,
       sd_definicion d
 WHERE num_credito = f_num_credito
   AND a.empresa   = f_empresa
   AND b.numcte = a.numcte
   AND c.divisa = a.divisa
   AND d.num_producto = a.num_producto;

   IF r_producto IS NULL THEN
        LET v_codret = "008";
        RETURN v_codret, r_nomcte, r_producto, r_nomprod, r_divisa, r_nomdiv,
               r_capvig, r_intvig, r_capven  , r_intven , r_intmor, r_stcred,
               c_num_cta;
   END IF

   IF v_nom2 IS NULL THEN
      LET v_nom2 = " ";
   END IF;

   IF v_apma IS NULL THEN
      LET v_apma = " ";
   END IF;
   IF v_rs IS NULL THEN
      LET v_rs = " ";
   END IF;
   LET r_nomcte = TRIM(v_rs) || " " || TRIM(v_nom1) || " " ||
                  TRIM(v_nom2) || " " || TRIM(v_appa) || " " ||
                  TRIM(v_apma);

   SELECT sdo_exig_int, monto_vencido + mto_venc_trasp, sdo_moratorio,
          sdo_capital
     INTO r_intven, r_capven, r_intmor, v_sdocap
     FROM sd_maesdos
    WHERE num_credito = f_num_credito
    AND empresa = f_empresa;

   -- Determina si la cuota vigente de capital ya es exigible
   SELECT fecha_cuota, saldo_cuota - monto_real_pag
     INTO v_fcuota, r_capvig
     FROM sd_pagocapit
    WHERE num_credito = f_num_credito
      AND empresa   = f_empresa
      AND fecha_cuota = (SELECT MIN(fecha_cuota) FROM sd_pagocapit
                        WHERE num_credito = f_num_credito
                          AND empresa      = f_empresa
                          AND status_cuota ="1") ;

   IF r_capvig IS NULL THEN
        LET r_capvig = 0;
   ELSE
     IF v_fcuota = v_hoy THEN
        LET r_capven = r_capven + r_capvig;
        LET v_sdocap = v_sdocap - r_capvig;
        LET r_capvig = v_sdocap;
     ELSE
        LET r_capvig = v_sdocap;
     END IF
   END IF

   -- Determina si la cuota vigente de interes ya es exigible
   SELECT fecha_cuota, monto_cuota - monto_real_pag
     INTO v_fcuota, r_intvig
     FROM sd_paginter
    WHERE num_credito = f_num_credito
      AND empresa   = f_empresa
      AND fecha_cuota = (SELECT MIN(fecha_cuota) FROM sd_paginter
                        WHERE num_credito = f_num_credito
                          AND empresa      = f_empresa
                          AND status_cuota ="1") ;

   IF r_intvig IS NULL THEN
        LET r_intvig = 0;
   ELSE
     IF v_fcuota = v_hoy THEN
        LET r_intven = r_intven + r_intvig;
        LET r_intvig = 0;
     END IF
   END IF

   --Extrae El Numero de Cuenta De Cheques del Credito Para Su Pago.
   --Modificado Por Sergio Ruiz el 25-Septiembre-2001
     SELECT * INTO c_empresa,c_numero, c_con_cap, c_naturale, c_num_credito,
                   c_tipo, c_num_cta, c_num_nomi
     FROM sd_ctascarg
     WHERE num_credito = f_num_credito
     AND empresa      = f_empresa
     AND con_cap_inte = "C"
     AND naturaleza = "C";
     IF c_num_cta IS NULL THEN
        LET c_num_cta = " ";
        LET v_codret = "009";
        RETURN v_codret, r_nomcte, r_producto, r_nomprod, r_divisa, r_nomdiv,
               r_capvig, r_intvig, r_capven  , r_intven , r_intmor, r_stcred,
               c_num_cta;
     END IF;
END
      RETURN v_codret, r_nomcte, r_producto, r_nomprod, r_divisa, r_nomdiv,
             r_capvig, r_intvig, r_capven  , r_intven , r_intmor, r_stcred,
             c_num_cta;

END PROCEDURE;
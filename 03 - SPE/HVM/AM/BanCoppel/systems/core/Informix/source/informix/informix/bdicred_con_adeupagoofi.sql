CREATE PROCEDURE "informix".con_adeupagoofi(f_num_credito CHAR(20),
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
	 MONEY(14,2),   -- Seguro
	 MONEY(14,2),   -- Comision
         CHAR(2),       -- Status del Credito
         CHAR(20),      -- Cuenta Asociada Al Credito
         SMALLINT,      -- No. de Cuotas de Cap e Int Vencidos
         MONEY(14,2),   -- Monto vencido, capital + intereses
         MONEY(14,2);   -- Capital Insoluto

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
DEFINE r_seguro     MONEY(14,2);
DEFINE r_comis      MONEY(14,2);
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
DEFINE r_numcuot     SMALLINT;
DEFINE r_adeudovenc  MONEY(14,2);
DEFINE r_capinsol    MONEY(14,2);

DEFINE winteres      MONEY(14,2);
DEFINE wcapital      MONEY(14,2);
DEFINE wfecha        DATE;
DEFINE v_mtominimo MONEY(14,2);
DEFINE v_linea       CHAR(1);
DEFINE v_desem      SMALLINT;

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
LET r_seguro     = 0;
LET r_comis      = 0;
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
LET c_num_cta     = "??????????????";
LET c_num_nomi    = " ";
LET r_numcuot     = 0;
LET r_adeudovenc  = 0;
LET r_capinsol    = 0;

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
               r_capvig, r_intvig, r_capven  , r_intven , r_intmor, r_seguro,
	       r_comis , r_stcred, c_num_cta,  r_numcuot, r_adeudovenc,
               r_capinsol;
 END EXCEPTION;


-- ############################################################################
-- #                              Codigo Principal                            #
-- ############################################################################

SELECT nombre1, nombre2, apell_paterno, apell_materno, razon_social,
       a.num_producto, nombre_prod, a.divisa, descripcion, status_cred,
       d.maneja_linea
  INTO v_nom1, v_nom2, v_appa, v_apma, v_rs, r_producto, r_nomprod, r_divisa,
       r_nomdiv, r_stcred, v_linea
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
               r_capvig, r_intvig, r_capven  , r_intven , r_intmor, r_seguro,
	       r_comis , r_stcred, c_num_cta,  r_numcuot, r_adeudovenc,
               r_capinsol;
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
   IF r_nomcte IS NULL THEN
      LET r_nomcte = " ";
   END IF;

   IF v_linea = "N" THEN
   	SELECT sdo_exig_int, monto_vencido + mto_venc_trasp, sdo_moratorio,
               sdo_capital, sdo_cap_insoluto, monto_financiado
          INTO r_intven, r_capven, r_intmor, v_sdocap, r_capinsol, v_mtominimo
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
   	END IF

   	-- Determina si la cuota vigente de interes ya es exigible
   	SELECT fecha_cuota, monto_cuota - monto_real_pag
  	   INTO v_fcuota, r_intvig
  	   FROM sd_paginter
   	 WHERE num_credito = f_num_credito
    	   AND empresa   = f_empresa
   	   AND fecha_cuota =  v_fcuota;

   	IF r_intvig IS NULL THEN
        	LET r_intvig = 0;
   	END IF

        SELECT COUNT(*) INTO v_desem FROM sd_detminis
         WHERE num_credito = f_num_credito
           AND empresa = f_empresa
           AND status_ministra <> "M";

        IF v_desem > 0 AND r_producto = "411" THEN
           SELECT sdo_no_exig INTO r_intvig FROM sd_maesdos
            WHERE num_credito = f_num_credito
              AND empresa = f_empresa;
        END IF


   	-- Determina Deuda de Comisiones
   	SELECT SUM(monto_com) INTO r_comis
     	FROM sd_detcomi a, sd_tpcomis b
    	WHERE b.cod_comis = a.cod_comis
    	  AND b.empresa = a.empresa
   	   AND b.comi_o_seg = "1"
   	   AND a.num_credito = f_num_credito
    	  AND a.empresa = f_empresa
   	   AND a.estado_com = "P";

   	IF r_comis IS NULL THEN
		LET r_comis = 0;
   	END IF

   	-- Determina Deuda de Seguro
   	SELECT SUM(monto_com) INTO r_seguro
   	  FROM sd_detcomi a, sd_tpcomis b
   	 WHERE b.cod_comis = a.cod_comis
    	   AND b.empresa = a.empresa
   	   AND b.comi_o_seg = "2"
   	   AND a.num_credito = f_num_credito
   	   AND a.empresa = f_empresa
   	   AND a.fecha_alta <= v_fcuota
   	   AND a.estado_com = "P";

   	IF r_seguro IS NULL THEN
		LET r_seguro = 0;
   	END IF

  	-- Determina el numero de cuotas vencidas y el monto vencido

   	SELECT COUNT(*) INTO r_numcuot
  	  FROM sd_pagocapit
 	 WHERE empresa = f_empresa
  	   AND num_credito = f_num_credito
  	   AND status_cuota in ("2", "7");

   	LET r_adeudovenc = r_intven + r_capven;

   	SELECT MIN(fecha_cuota) INTO wfecha
          FROM sd_pagocapit
	 WHERE empresa = f_empresa
	   AND num_credito = f_num_credito
           AND status_cuota = "1";

   	IF (wfecha IS NOT NULL) THEN
      		SELECT a.saldo_cuota - a.monto_real_pag,
         	       b.monto_cuota - b.monto_real_pag
   		  INTO wcapital, winteres
     		  FROM sd_pagocapit a, sd_paginter b
   	         WHERE a.empresa = f_empresa
   		   AND a.num_credito = f_num_credito
   		   AND a.fecha_cuota = wfecha
  		   AND b.empresa = a.empresa
                   AND b.num_credito = a.num_credito
                   AND b.fecha_cuota = a.fecha_cuota;

      		LET r_numcuot = r_numcuot + 1;
      		IF (winteres IS NULL) THEN
         		LET winteres = 0;
      		END IF;
      		IF (wcapital IS NULL) THEN
         		LET wcapital = 0;
      		END IF;
      		LET r_adeudovenc = r_adeudovenc + winteres + wcapital;
   	END IF;
   	LET r_adeudovenc = r_capvig + r_intvig + r_capven + r_intven ;
   ELSE
   	SELECT sdo_exig_int + sdo_no_exig, sdo_cap_insoluto , sdo_moratorio,
               sdo_capital, sdo_cap_insoluto, monto_financiado+sdo_trab4
   	  INTO r_intven, r_capven, r_intmor, v_sdocap, r_capinsol, v_mtominimo
   	  FROM sd_maesdos
   	 WHERE num_credito = f_num_credito
  	   AND empresa = f_empresa;
	IF v_mtominimo = 0 THEN
		LET r_adeudovenc = r_capven + r_intven;
	ELSE
		LET r_adeudovenc = v_mtominimo;
	END IF
   END IF
END
   IF (c_num_cta IS NULL) THEN
      LET c_num_cta = " ";
   END IF;

        RETURN v_codret, r_nomcte, r_producto, r_nomprod, r_divisa, r_nomdiv,
               r_capvig, r_intvig, r_capven  , r_intven , r_intmor, r_seguro,
	       r_comis , r_stcred, c_num_cta,  r_numcuot, r_adeudovenc,
               r_capinsol;

END PROCEDURE;
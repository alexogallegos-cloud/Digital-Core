CREATE PROCEDURE "informix".consdetcred(f_empresa      CHAR(3),
                             f_num_credito  CHAR(20))
RETURNING CHAR(5),       -- Codigo Retorno
          CHAR(40),      -- Nombre Promotor
          CHAR(20),      -- Nombre Divisa
	  CHAR(30),	 -- Status Credito
          MONEY(14,2),   -- Interes Vigente
          MONEY(14,2),   -- Interes Vencido
          MONEY(14,2),   -- Interes Moratorio
          MONEY(14,2),   -- Capital Vigente
          MONEY(14,2),   -- Capital Vencido
          MONEY(14,2),   -- Adeudo Total
          DATE;          -- Fecha Proximo Pago

-- ############################################################################
-- #                        Definicion de Variables                           #
-- ############################################################################
DEFINE v_codret     CHAR(5);
DEFINE sqlerr       INTEGER;
DEFINE r_nompromo   CHAR(60);
DEFINE r_nomdiv     CHAR(25);
DEFINE r_capvig     MONEY(14,2);
DEFINE r_intvig     MONEY(14,2);
DEFINE r_capven     MONEY(14,2);
DEFINE r_intven     MONEY(14,2);
DEFINE r_intmor     MONEY(14,2);
DEFINE r_adetotal   MONEY(14,2);
DEFINE r_stcred     CHAR(30);
DEFINE v_hoy        DATE;
DEFINE r_fcuota     DATE;
DEFINE v_st         CHAR(2);
-- ############################################################################
-- #                        Asignacion de Variables                           #
-- ############################################################################
LET v_codret     = "000";
LET sqlerr       = 0;
LET r_nompromo   = "";
LET r_nomdiv     = "";
LET r_capvig     = 0;
LET r_intvig     = 0;
LET r_capven     = 0;
LET r_intven     = 0;
LET r_intmor     = 0;
LET r_adetotal   = 0;
LET r_stcred     = "";
LET r_fcuota     = "";
SELECT fecha_hoy INTO v_hoy FROM sd_fechas
WHERE empresa = f_empresa;
-- ############################################################################
-- #                    Control de Errores para INFORMIX                      #
-- ############################################################################
BEGIN
 ON EXCEPTION
      SET sqlerr
      LET v_codret = sqlerr;
      RETURN v_codret, r_nompromo, r_nomdiv, r_stcred, r_intvig, r_intven,
	     r_intmor, r_capvig, r_capven , r_adetotal, r_fcuota;
 END EXCEPTION;


-- ############################################################################
-- #                              Codigo Principal                            #
-- ############################################################################

   LET f_num_credito = f_num_credito;
   LET f_empresa = f_empresa; 
   SELECT d.nombre, c.descripcion, e.descripcion, sdo_no_exig, sdo_exig_int,
          sdo_moratorio, sdo_capital, monto_vencido + mto_venc_trasp,
          sdo_no_exig + sdo_exig_int + sdo_cap_insoluto + sdo_moratorio,
          a.status_cred
     INTO r_nompromo, r_nomdiv, r_stcred, r_intvig, r_intven, r_intmor, 
	  r_capvig, r_capven, r_adetotal, v_st
     FROM sd_maecred a, sd_maesdos b, bdinteg:si_divisas c,
	  bdinteg:si_ejecut d, sd_tipocartera e
    WHERE d.ejecutivo = a.ejecutivo
      AND d.empresa = a.empresa
      AND e.status_cred = a.status_cred
      AND e.empresa = a.empresa
      AND c.divisa = a.divisa
      AND c.empresa = a.empresa
      AND b.num_credito = a.num_credito
      AND b.empresa = a.empresa
      AND a.num_credito = f_num_credito
      AND a.empresa = f_empresa;

   IF r_intvig IS NOT NULL THEN
	IF SUBSTR(v_st,1,1) = "B" THEN
		LET r_fcuota = v_hoy;
	ELSE
		SELECT MIN(fecha_cuota)fecha_cuota FROM sd_pagocapit
		 WHERE num_credito ='204000022670007'
		   AND status_cuota ='1'
		UNION ALL
		SELECT MIN(fecha_cuota)fecha_cuota FROM sd_paginter
	 	 WHERE num_credito ='204000022670007'
	 	   AND status_cuota ='1'
		 ORDER BY 1
		  INTO TEMP axel;
		SELECT MIN(fecha_cuota) INTO r_fcuota FROM axel;
		IF r_fcuota IS NULL THEN
			LET r_fcuota = v_hoy;
		END IF
	END IF
        RETURN v_codret, r_nompromo, r_nomdiv, r_stcred, r_intvig, r_intven,
	       r_intmor, r_capvig, r_capven , r_adetotal, r_fcuota;
   ELSE
   	SELECT d.nombre, c.descripcion, e.descripcion, "0", "0", "0", "0", "0",
               monto_solicitado, " "
          INTO r_nompromo, r_nomdiv, r_stcred, r_intvig, r_intven, r_intmor,
               r_capvig, r_capven, r_adetotal, r_fcuota
          FROM bdisolic:ss_solicitudes a, bdisolic:ss_anexosol b, 
               bdinteg:si_divisas c, bdinteg:si_ejecut d, 
               bdisolic:ss_status_sol e
         WHERE d.ejecutivo = b.ejecutivo_sol
           AND d.empresa = b.empresa
           AND e.status_solicitud = a.status_solicitud
           AND e.empresa = a.empresa
           AND c.divisa = a.divisa
           AND c.empresa = a.empresa
           AND b.num_solicitud = a.num_solicitud
           AND b.empresa = a.empresa
           AND a.num_solicitud = f_num_credito
           AND a.empresa = f_empresa;

	IF r_adetotal IS NULL THEN
		LET v_codret = '100';
        	RETURN v_codret, r_nompromo, r_nomdiv, r_stcred, r_intvig, 
		       r_intven, r_intmor, r_capvig, r_capven , r_adetotal, 
		       r_fcuota;
	ELSE
                RETURN v_codret, r_nompromo, r_nomdiv, r_stcred, r_intvig, 
                       r_intven, r_intmor, r_capvig, r_capven , r_adetotal, 
                       r_fcuota;
	END IF
   END IF


END
END PROCEDURE;
CREATE PROCEDURE "informix".corrige_cvenytr(param_fechaproc DATE)
RETURNING CHAR(50),              -- Credito o Mensaje de error
          CHAR(1),               -- Valor de v15_ccvenytr
          MONEY(14,2),           -- sd_maesdos.monto_vencido antes de act.
          MONEY(14,2),           -- suma ccap/st=7 antes de act.
          MONEY(14,2),           -- sd_maesdos.monto_vencido despues de act.
          MONEY(14,2),           -- suma ccap/st=7 despues de act.
          MONEY(14,2),           -- sd_maesdos_mto_venc_trasp antes de act.
          MONEY(14,2),           -- suma ccap/st=2 antes de act.
          MONEY(14,2),           -- sd_maesdos_mto_venc_trasp despues de act.
          MONEY(14,2),           -- suma ccap/st=2 despues de act.
          CHAR(1),               -- Valor de v16_civenytr
          MONEY(14,2),           -- sd_maesdos.mto_venc_int antes de act.
          MONEY(14,2),           -- suma cint/st=7 antes de act.
          MONEY(14,2),           -- sd_maesdos.mto_venc_int despues de act.
          MONEY(14,2),           -- suma cint/st=7 despues de act.
          MONEY(14,2),           -- sd_maesdos.mto_venc_tra_int antes de act.
          MONEY(14,2),           -- suma cint/st=2 antes de act.
          MONEY(14,2),           -- sd_maesdos.mto_venc_tra_int despues de act.
          MONEY(14,2);           -- suma cint/st=2 despues de act.
-------------------------------------------------------------------------
-- DEFINE VARIABLES DE TRABAJO
-------------------------------------------------------------------------
DEFINE x_num_credito        LIKE sd_maecred.num_credito;
DEFINE x_num_producto       LIKE sd_maecred.num_producto;
DEFINE x_v15_ccvenytr       LIKE sd_auditsdo.v15_ccvenytr;
DEFINE x_v16_civenytr       LIKE sd_auditsdo.v16_civenytr;
DEFINE x_status_cred        LIKE sd_maecred.status_cred;
DEFINE x_fechamax_ccap2     LIKE sd_pagocapit.fecha_cuota;
DEFINE x_fecha_cuota        LIKE sd_pagocapit.fecha_cuota;
DEFINE x_fechamax_cint2     LIKE sd_paginter.fecha_cuota;
DEFINE x_mtovenc_reg        MONEY(14,2);
DEFINE x_mtovtra_reg        MONEY(14,2);
DEFINE x_cuo_cap7_reg       MONEY(14,2);
DEFINE x_cuo_cap2_reg       MONEY(14,2);
DEFINE x_mtovein_reg        MONEY(14,2);
DEFINE x_mtovtin_reg        MONEY(14,2);
DEFINE x_cuo_int7_reg       MONEY(14,2);
DEFINE x_cuo_int2_reg       MONEY(14,2);
DEFINE x_mtovenc_act        MONEY(14,2);
DEFINE x_mtovtra_act        MONEY(14,2);
DEFINE x_cuo_cap7_act       MONEY(14,2);
DEFINE x_cuo_cap2_act       MONEY(14,2);
DEFINE x_mtovein_act        MONEY(14,2);
DEFINE x_mtovtin_act        MONEY(14,2);
DEFINE x_cuo_int7_act       MONEY(14,2);
DEFINE x_cuo_int2_act       MONEY(14,2);
DEFINE x_codret             CHAR(4);
DEFINE sqlerr               INTEGER;
DEFINE x_reg_leidos         INTEGER;
DEFINE x_reg_actua_cap      INTEGER;
DEFINE x_reg_actua_int      INTEGER;
DEFINE x_cuota_rec          LIKE sd_pagocapit.cuota_rec;
DEFINE x_status_cuota       LIKE sd_pagocapit.status_cuota;
DEFINE x_begin              char(1);

-------------------------------------------------------------------------
-- INICIALIZA VARIABLES DE TRABAJO
-------------------------------------------------------------------------
LET x_num_credito        = "";
LET x_num_producto       = "";
LET x_v15_ccvenytr       = "";
LET x_v16_civenytr       = "";
LET x_fechamax_ccap2     = "";
LET x_fechamax_cint2     = "";
LET x_fecha_cuota        = "";
LET x_mtovenc_reg        = 0;
LET x_mtovtra_reg        = 0;
LET x_cuo_cap7_reg       = 0;
LET x_cuo_cap2_reg       = 0;
LET x_mtovein_reg        = 0;
LET x_mtovtin_reg        = 0;
LET x_cuo_int7_reg       = 0;
LET x_cuo_int2_reg       = 0;
LET x_mtovenc_act        = 0;
LET x_mtovtra_act        = 0;
LET x_cuo_cap7_act       = 0;
LET x_cuo_cap2_act       = 0;
LET x_mtovein_act        = 0;
LET x_mtovtin_act        = 0;
LET x_cuo_int7_act       = 0;
LET x_cuo_int2_act       = 0;
LET x_codret             = "FIN";
LET sqlerr               = 0;
LET x_reg_leidos         = 0;
LET x_reg_actua_cap      = 0;
LET x_reg_actua_int      = 0;
LET x_cuota_rec          = "";
LET x_status_cuota       = "";
LET x_begin              = "";

------------------------------------------------------------------------
-- Crea tabla temporal de trabajo donde registra las cuotas de Capital
-- e Interes que se les debe cambiar el estatus de 7 a 2
------------------------------------------------------------------------
CREATE TEMP TABLE CambiosEnCuotas
(num_credito  CHAR(20),
 fecha_cuota  DATE,
 cuota_rec    CHAR(1),
 status_cuota CHAR(1),
 cambioen     CHAR(3));

------------------------------------------------------------------------
-- Inicia Proceso
------------------------------------------------------------------------
BEGIN
   ON EXCEPTION
      SET sqlerr
      LET x_codret = sqlerr;
      IF x_begin = "S" THEN
         ROLLBACK;
      END IF;
      RETURN x_codret || " ERROR EN LA EJECUCION",
             x_v15_ccvenytr ,
             x_mtovenc_reg  ,
             x_cuo_cap7_reg ,
             x_mtovenc_act  ,
             x_cuo_cap7_act ,
             x_mtovtra_reg  ,
             x_cuo_cap2_reg ,
             x_mtovtra_act  ,
             x_cuo_cap2_act ,
             x_v16_civenytr ,
             x_mtovein_reg  ,
             x_cuo_int7_reg ,
             x_mtovein_act  ,
             x_cuo_int7_act ,
             x_mtovtin_reg  ,
             x_cuo_int2_reg ,
             x_mtovtin_act  ,
             x_cuo_int2_act ;
   END EXCEPTION;

   FOREACH
      SELECT  num_credito,
              v15_ccvenytr,
              v16_civenytr
        INTO  x_num_credito,
              x_v15_ccvenytr,
              x_v16_civenytr
        FROM  sd_auditsdo
        WHERE ((v15_ccvenytr = "1" AND solucion[15] <> "S")
              OR (v16_civenytr = "1" AND solucion[16] <> "S"))
        AND   status_cred[1,1] <> "F"
        AND   fecha_act = param_fechaproc

      LET x_reg_leidos = x_reg_leidos + 1;
      ------------------------------------------------------------------------
      -- Obtine datos de maesdos
      ------------------------------------------------------------------------
      SELECT  monto_vencido,
              mto_venc_trasp,
              mto_venc_int,
              mto_venc_tra_int
        INTO  x_mtovenc_reg,
              x_mtovtra_reg,
              x_mtovein_reg,
              x_mtovtin_reg
        FROM  sd_maesdos
        WHERE num_credito = x_num_credito;

      ------------------------------------------------------------------------
      -- Obtiene cuotas de CAPITAL vencidas y traspasadas intercaladas
      ------------------------------------------------------------------------
      IF x_v15_ccvenytr = "1" THEN
         SELECT  NVL(sum(saldo_cuota - monto_real_pag),0)
           INTO  x_cuo_cap7_reg
           FROM  sd_pagocapit
           WHERE num_credito = x_num_credito
           AND   status_cuota = "7";

         SELECT  NVL(sum(saldo_cuota - monto_real_pag),0)
           INTO  x_cuo_cap2_reg
           FROM  sd_pagocapit
           WHERE num_credito = x_num_credito
           AND   status_cuota = "2";

         SELECT MAX(fecha_cuota)
           INTO  x_fechamax_ccap2
           FROM  sd_pagocapit
           WHERE num_credito = x_num_credito
           AND   status_cuota = "2";

         IF DBINFO("sqlca.sqlerrd2") > 0 THEN
            INSERT INTO CambiosEnCuotas
                   SELECT num_credito,
                          fecha_cuota,
                          cuota_rec,
                          status_cuota,
                          "CAP"
                   FROM  sd_pagocapit
                   WHERE num_credito = x_num_credito
                   AND   status_cuota = "7"
                   AND   fecha_cuota < x_fechamax_ccap2;
         END IF;
      END IF;

      ------------------------------------------------------------------------
      -- Obtiene cuotas de INTERES vencidas y traspasadas intercaladas
      ------------------------------------------------------------------------
      IF x_v16_civenytr = "1" THEN
         SELECT  NVL(sum(monto_cuota - monto_real_pag),0)
           INTO  x_cuo_int7_reg
           FROM  sd_paginter
           WHERE num_credito = x_num_credito
           AND   status_cuota = "7";

         SELECT  NVL(sum(monto_cuota - monto_real_pag),0)
           INTO  x_cuo_int2_reg
           FROM  sd_paginter
           WHERE num_credito = x_num_credito
           AND   status_cuota = "2";

         SELECT MAX(fecha_cuota)
           INTO  x_fechamax_cint2
           FROM  sd_paginter
           WHERE num_credito = x_num_credito
           AND   status_cuota = "2";

         IF DBINFO("sqlca.sqlerrd2") > 0 THEN
            INSERT INTO CambiosEnCuotas
                   SELECT  num_credito,
                           fecha_cuota,
                           cuota_rec,
                           status_cuota,
                           "INT"
                   FROM  sd_paginter
                   WHERE num_credito = x_num_credito
                   AND   status_cuota = "7"
                   AND   fecha_cuota < x_fechamax_cint2;
         END IF;
      END IF;

      ------------------------------------------------------------------------
      -- Actualiza la informacion del credito en pagocapit, paginter y maesdos
      ------------------------------------------------------------------------
  --  BEGIN WORK;
      LET x_begin = "S";
      LET x_fecha_cuota = "";

  --  FOREACH WITH HOLD
      FOREACH
         SELECT  fecha_cuota
           INTO  x_fecha_cuota
           FROM  CambiosEnCuotas
           WHERE num_credito = x_num_credito
           AND   cambioen = "CAP"

         UPDATE sd_pagocapit
            SET status_cuota = "2",
                cuota_rec    = "7"
          WHERE num_credito  = x_num_credito
            AND fecha_cuota  = x_fecha_cuota;

         LET x_fecha_cuota = "";
      END FOREACH;

      LET x_fecha_cuota = "";
      FOREACH
         SELECT  fecha_cuota
           INTO  x_fecha_cuota
           FROM  CambiosEnCuotas
           WHERE num_credito = x_num_credito
           AND   cambioen = "INT"

         UPDATE sd_paginter
            SET status_cuota = "2",
                cuota_rec     = "7"
          WHERE num_credito = x_num_credito
            AND fecha_cuota = x_fecha_cuota;

         LET x_fecha_cuota = "";
      END FOREACH;

      SELECT  NVL(sum(saldo_cuota - monto_real_pag),0)
        INTO  x_cuo_cap7_act
        FROM  sd_pagocapit
        WHERE num_credito = x_num_credito
        AND   status_cuota = "7";

      SELECT  nvl(sum(saldo_cuota - monto_real_pag),0)
        INTO  x_cuo_cap2_act
        FROM  sd_pagocapit
        WHERE num_credito = x_num_credito
        AND   status_cuota = "2";

      SELECT  NVL(sum(monto_cuota - monto_real_pag),0)
        INTO  x_cuo_int7_act
        FROM  sd_paginter
        WHERE num_credito = x_num_credito
        AND   status_cuota = "7";

      SELECT  NVL(sum(monto_cuota - monto_real_pag),0)
        INTO  x_cuo_int2_act
        FROM  sd_paginter
        WHERE num_credito = x_num_credito
        AND   status_cuota = "2";

      UPDATE   sd_maesdos
         SET   monto_vencido    = x_cuo_cap7_act,
               mto_venc_trasp   = x_cuo_cap2_act,
               mto_venc_int     = x_cuo_int7_act,
               mto_venc_tra_int = x_cuo_int2_act
         WHERE num_credito      = x_num_credito;

      IF x_v15_ccvenytr = "1" AND x_v16_civenytr = "1" THEN
         UPDATE   sd_auditsdo
            SET   solucion[15,16] = "SS"
            WHERE num_credito = x_num_credito;
      END IF;

      IF x_v15_ccvenytr = "1" AND x_v16_civenytr <> "1" THEN
         UPDATE   sd_auditsdo
            SET   solucion[15] = "S"
            WHERE num_credito = x_num_credito;
      END IF;

      IF x_v15_ccvenytr <> "1" AND x_v16_civenytr = "1" THEN
         UPDATE   sd_auditsdo
            SET   solucion[16] = "S"
            WHERE num_credito = x_num_credito;
      END IF;

--    COMMIT;
      LET x_reg_actua_cap = x_reg_actua_cap + 1;

      SELECT  monto_vencido,
              mto_venc_trasp,
              mto_venc_int,
              mto_venc_tra_int
        INTO  x_mtovenc_act,
              x_mtovtra_act,
              x_mtovein_act,
              x_mtovtin_act
        FROM  sd_maesdos
        WHERE num_credito = x_num_credito;

      RETURN x_num_credito || " ACT.MAESDOS CUO CAPeINT",
                x_v15_ccvenytr ,
                x_mtovenc_reg  ,
                x_cuo_cap7_reg ,
                x_mtovenc_act  ,
                x_cuo_cap7_act ,
                x_mtovtra_reg  ,
                x_cuo_cap2_reg ,
                x_mtovtra_act  ,
                x_cuo_cap2_act ,
                x_v16_civenytr ,
                x_mtovein_reg  ,
                x_cuo_int7_reg ,
                x_mtovein_act  ,
                x_cuo_int7_act ,
                x_mtovtin_reg  ,
                x_cuo_int2_reg ,
                x_mtovtin_act  ,
                x_cuo_int2_act  WITH RESUME;
      -------------------------------------------------------------------------
      -- INICIALIZA VARIABLES DE TRABAJO
      -------------------------------------------------------------------------
      LET x_num_credito        = "";
      LET x_num_producto       = "";
      LET x_v15_ccvenytr       = "";
      LET x_v16_civenytr       = "";
      LET x_fechamax_ccap2     = "";
      LET x_fechamax_cint2     = "";
      LET x_fecha_cuota        = "";
      LET x_mtovenc_reg        = 0;
      LET x_mtovtra_reg        = 0;
      LET x_cuo_cap7_reg       = 0;
      LET x_cuo_cap2_reg       = 0;
      LET x_mtovein_reg        = 0;
      LET x_mtovtin_reg        = 0;
      LET x_cuo_int7_reg       = 0;
      LET x_cuo_int2_reg       = 0;
      LET x_mtovenc_act        = 0;
      LET x_mtovtra_act        = 0;
      LET x_cuo_cap7_act       = 0;
      LET x_cuo_cap2_act       = 0;
      LET x_mtovein_act        = 0;
      LET x_mtovtin_act        = 0;
      LET x_cuo_int7_act       = 0;
      LET x_cuo_int2_act       = 0;
   END FOREACH;

   RETURN "registros leidos :" || x_reg_leidos,
          "",0,0,0,0,0,0,0,0,"",0,0,0,0,0,0,0,0 with resume;

   RETURN "registros act_cap :" || x_reg_actua_cap,
          "",0,0,0,0,0,0,0,0,"",0,0,0,0,0,0,0,0 with resume;

   RETURN "registros act_int :" || x_reg_actua_int,
          "",0,0,0,0,0,0,0,0,"",0,0,0,0,0,0,0,0 with resume;
END;
END PROCEDURE
DOCUMENT
"****************************************************************************",
"*                        -- CACSI --                                       *",
"* Procedimiento para corregir los creditos que tienen cuotas vencidas(st=7)*",
"* intercaldas en cuotas vencidas y traspasadas (st=2), tanto en Cap e Int  *",
"* Realizado por : Magda Marquez el 10/Mar/2005                             *",
"* Se prohibe la distribucion total o parcial de este programa sin la       *",
"* autorizacion de GRUPO PISA                                               *",
"****************************************************************************";

create procedure "informix".sp_factura( p_empresa char(3), p_num_credito char(20), p_fecha date )
returning 	char(20) ,
		char(20) ,
		char(4) ,
		decimal(18,2) ,
		date ,
		date ,
		date ,
		date ,
		integer ,
		decimal(9,6) ,
		decimal(18,2) ;

define r_num_cte char(20);
define r_num_credito char(20);
define r_num_producto char(4);
define r_monto_desembolso decimal(18,2);
define r_fecha_desembolso date;
define r_fecha_apertura date;
define r_fecha_inicial date;
define r_fecha_factura date;
define r_dias integer;
define r_tasa_interes decimal(9,6);
define r_monto_interes decimal(18,2);
define ax_programada DATE;

define v_min_fecha_nopagada date;
define v_max_fecha_pagada date;
define v_fecha_dias date;



let r_fecha_factura = p_fecha;

select num_credito, fecha_apertura, tasa_interes, numcte, num_producto
into r_num_credito, r_fecha_apertura, r_tasa_interes, r_num_cte, r_num_producto
from sd_maecred
where empresa = p_empresa
and num_credito = p_num_credito;

foreach
	select monto_otorgado, fecha_otorga, fecha_programada
	into r_monto_desembolso, r_fecha_desembolso, ax_programada
	from sd_detminis
	where empresa = p_empresa
	and num_credito = r_num_credito
	and status_ministra = 'M'
	and monto_otorgado > 0.0
	order by fecha_programada

		select min(fecha_cuota)
		into v_min_fecha_nopagada
		from sd_paginter
		where  empresa = p_empresa
		and num_credito = p_num_credito
		and status_cuota in ('1','2','7')
		and fecha_cuota > r_fecha_desembolso;

		select max(fecha_cuota)
		into v_max_fecha_pagada
		from sd_paginter
		where empresa = p_empresa
		and num_credito = p_num_credito
		and status_cuota in ('5')
		and fecha_cuota < v_min_fecha_nopagada;

		if r_fecha_desembolso < v_min_fecha_nopagada and r_fecha_desembolso < v_max_fecha_pagada then
			let r_fecha_inicial = v_max_fecha_pagada;
		else
			let r_fecha_inicial = r_fecha_desembolso;
		end if;

		let v_fecha_dias = r_fecha_factura - r_fecha_inicial;
		let r_dias = day(v_fecha_dias) + 30 * (month(v_fecha_dias)-1) + 365 * (year(v_fecha_dias)-1900) + 1;


		let r_monto_interes = (r_monto_desembolso) * (( r_tasa_interes / 100 ) / ( 365 )) * r_dias;

		return r_num_cte, r_num_credito, r_num_producto, r_monto_desembolso, r_fecha_desembolso, r_fecha_apertura, r_fecha_inicial, r_fecha_factura,
		       r_dias,	r_tasa_interes, r_monto_interes with resume;


end foreach;


end procedure;
CREATE PROCEDURE "informix".totcomp_pba2(o_empresa   CHAR(3),
				    o_usuario   CHAR(8),
				    o_sucursal  CHAR(4),
                         	    o_num_total SMALLINT)

RETURNING char(5),     char(2),  money(16,2), money(16,2), money(16,2),
          money(16,2), char(40), integer,     integer,     integer,
          integer;

-- ============================================================================
-- =                        DEFINICION DE VARIABLES                           =
-- ============================================================================
DEFINE v_monto_cargo, v_monto_firme, v_monto_sbc, v_monto_rem money(16,2);
DEFINE v_movto_cargo, v_movto_firme, v_movto_sbc, v_movto_rem integer;
DEFINE v_descripcion char(40);
DEFINE v_contador smallint;
DEFINE v_fecha date;
DEFINE v_row integer;
DEFINE v_codret char(5);
DEFINE v_empresa, w_plaza char(3);
DEFINE w_sucursal char(4);
DEFINE v_producto char(4);
DEFINE v_ciclo smallint;
DEFINE v_divisa char(2);
DEFINE v_cal_int_chq char(1);
DEFINE sql_err integer;
DEFINE v_usuario CHAR(8);
DEFINE v_existe CHAR(1);
-- ============================================================================
-- =                        ASIGNACION DE VALORES                             =
-- ============================================================================
LET v_contador = 0;
LET v_ciclo = 0;
LET v_divisa = " ";
LET v_monto_cargo = 0;
LET v_monto_firme = 0;
LET v_monto_sbc = 0;
LET v_monto_rem = 0;
LET v_movto_cargo = 0;
LET v_movto_firme = 0;
LET v_movto_sbc = 0;
LET v_movto_rem = 0;
LET v_descripcion = " ";
LET v_usuario     = " ";
LET v_codret = "00000";
LET v_existe = "";

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

BEGIN
   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
         LET v_coDret = sql_err;
         RETURN v_codret, v_divisa, v_monto_cargo, v_monto_firme,
               v_monto_sbc, v_monto_rem, v_descripcion, v_movto_cargo,
               v_movto_firme, v_movto_sbc, v_movto_rem;
      END IF
   END EXCEPTION;

SELECT fecha_hoy INTO v_fecha FROM sd_fechas where empresa = o_empresa;

--DELETE FROM sd_totcomp WHERE usuario = o_usuario and empresa = o_empresa;
FOREACH
         SELECT divisa, nvl(sum(case when codigo_fun = '002' then monto end),0), nvl(sum(case when codigo_fun = '002' then 1 end),0),
                nvl(sum(case when codigo_fun in ('033','333','336') then monto end),0), nvl(sum(case when codigo_fun in ('033','333','336') then 1 end),0), (select descripcion from bdinteg:si_divisas where a.divisa = divisa  and empresa = '001')
          INTO v_divisa, v_monto_cargo, v_movto_cargo, v_monto_firme, v_movto_firme, v_descripcion
          FROM sd_movdia a
         WHERE ((codigo_fun IN ("033", "333") and codigo_ref = 1) or (codigo_fun = "336" and codigo_ref = 20) or (codigo_fun = "002" and codigo_ref = 50))
            AND usuario = o_usuario
            AND sucursal = o_sucursal
            AND fecha_mov = v_fecha
            AND empresa = o_empresa
            AND reversado <> "S"
         group by 1

        RETURN v_codret, v_divisa, v_monto_cargo, v_monto_firme,
               v_monto_sbc, v_monto_rem, v_descripcion, v_movto_cargo,
               v_movto_firme, v_movto_sbc, v_movto_rem WITH RESUME;


END FOREACH;
END

END PROCEDURE DOCUMENT "Version 1.00.000";

create procedure "informix".cambia_tasa(pempresa char(3))
returning char(5);


define vcodret         char(5);
define vNumCredito     char(20);
define vsqlerr         Integer;
define vMtoMin         money(14,2);
define vMtoFinan       money(14,2);
define vDifFinan       money(14,2);


-- CONTROL DE ERRORES
BEGIN
ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
      LET vcodret=vsqlerr;
      RETURN vcodret;
   END IF;
END EXCEPTION;

  --set debug file to "audita.out";
  --trace on;



  let vcodret         = "000";
  let vNumCredito     = '';
  let vMtoMin         = 0;
  let  vDifFinan      = 0;
  let  vMtoFinan      = 0;

--Creditos Transitorios

  FOREACH WITH HOLD
        SELECT num_credito INTO vNumCredito FROM bdicred:sd_maecred WHERE empresa = pempresa and status_cred <> 'CV'
        BEGIN WORK;

        UPDATE bdicred:sd_maecred SET tasa_interes = 67, tasa_moratorios = 103 
        WHERE empresa = pempresa and num_credito = vNumCredito;
        COMMIT work;
  END FOREACH;

  RETURN vcodret;
END
end procedure
;
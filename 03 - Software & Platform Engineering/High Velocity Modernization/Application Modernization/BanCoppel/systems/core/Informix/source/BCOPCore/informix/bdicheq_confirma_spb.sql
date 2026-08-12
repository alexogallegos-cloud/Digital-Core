CREATE PROCEDURE "informix".confirma_spb(pempresa char(3),
                              p_sucursal char(4),
                              p_usuario  char(8),
                              p_foliosuc char(16),
                              p_rastreo char(16))
RETURNING char(5);

-- ************* Definicion de Variables ************************************

DEFINE v_codret char(5);
DEFINE sql_err  integer;
DEFINE v_fechoy char(8);
DEFINE v_hora datetime hour to second;
DEFINE v_importe money(14,2);
DEFINE v_transpeua char(4);
DEFINE v_ctapropia char(20);
DEFINE v_tipomov  char(1);
DEFINE v_producto char(4);
DEFINE v_status   char(1);
define vfecha_hoy date;
define pfoliosu char(16);
define pfoliosu1 char(16);

-- **************************************************************************

let pfoliosu = trim(p_foliosuc);
let pfoliosu1 = trim(p_rastreo);

LET v_codret = "000";
LET v_status ="";

BEGIN
   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
         LET v_codret = sql_err;
         RETURN v_codret;
      END IF
   END EXCEPTION;

select fecha_hoy into vfecha_hoy
from sc_fechas where empresa = pempresa;

-- ************************************************************************
   select a.operac, a.cta_ordenante, a.importe, a.fecha_valor, b.producto,
          a.status_envio
      into v_tipomov, v_ctapropia, v_importe, v_fechoy, v_producto, v_status
      from bdispeua:sp_pagoenviar a, outer sc_maechq b
      where a.clave_rastreo = p_rastreo
      and b.empresa = pempresa and b.cuenta = a.cta_ordenante;

-- Se valida Tipo de Movimiento

select transacc_envio into v_transpeua
        from bdispeua:sp_operaciones
        where codigo=v_tipomov;


-- Se registra en Movimiento de SPEUA
        let v_hora=current hour to second;
--        insert into bdispeua:sp_movdia values(0, p_foliosuc,
--                                        v_producto,
--                                        p_sucursal,
--                                        p_usuario,
--                                        vfecha_hoy,
--                                        v_hora,
--                                        v_transpeua,
--                                        v_ctapropia,
--                                        v_importe,
--                                        " ",
--                                        "0000", " ");

IF v_status = "P" THEN
-- UPDATE bdispeua:sp_pagoenviar SET status_envio = " "
-- WHERE clave_rastreo = p_rastreo;
ELSE
   LET v_codret = "145";
END IF;

RETURN v_codret;

-- ***********************************************************************
END
END PROCEDURE;
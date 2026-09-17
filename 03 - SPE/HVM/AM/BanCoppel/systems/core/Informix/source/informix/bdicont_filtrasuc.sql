CREATE PROCEDURE "informix".filtrasuc(p_sucursal CHAR(4), p_reg_suc CHAR(3))
RETURNING CHAR(4);

DEFINE v_sucursal CHAR(4);

--IF p_reg_suc = "R" THEN
--   LET p_sucursal = "0000";
--END IF
  LET p_sucursal=p_sucursal;

RETURN p_sucursal;

END PROCEDURE;
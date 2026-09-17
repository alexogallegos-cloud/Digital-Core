CREATE PROCEDURE "informix".sp_premio(o_empresa  CHAR(3),
			   o_sucursal CHAR(4),
			   o_usuario  CHAR(8),
                           o_cuenta   CHAR(20))


RETURNING CHAR(5), CHAR(6), DECIMAL(14,2);

-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
DEFINE scod_ret     CHAR(5);
DEFINE vsqlerr      INTEGER;
DEFINE sql_err      SMALLINT;
DEFINE isam_err     SMALLINT;
DEFINE error_info   CHAR(100);
DEFINE s_folio      CHAR(6);
DEFINE s_monto      DECIMAL(14,2);

-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************
LET scod_ret     = "000";
LET vsqlerr      = 0;

-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************
BEGIN
   ON EXCEPTION SET sql_err, isam_err, error_info
      LET scod_ret = sql_err;
      RETURN scod_ret, s_folio, s_monto;
   END EXCEPTION;

-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************

        SELECT folio_premio, monto
	  INTO s_folio, s_monto
	  FROM sc_premio
	 WHERE empresa = o_empresa
	   AND cuenta = o_cuenta
	   AND estatus = "0"
	   AND fecha_vigencia >= (SELECT fecha_hoy FROM sc_fechas);

	IF s_folio IS NULL THEN
		LET s_folio = "000000";
		LET s_monto = 0;
	ELSE
		UPDATE sc_premio SET estatus = "1"
	 	 WHERE empresa = o_empresa
	   	   AND cuenta = o_cuenta
	   	   AND estatus = "0";
	END IF


END
	RETURN scod_ret, s_folio, s_monto;

END PROCEDURE;
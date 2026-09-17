CREATE PROCEDURE "informix".cons_cred_tarjeta(o_empresa CHAR(3),o_credito CHAR(20))
RETURNING CHAR(5), CHAR(20);

-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
DEFINE scod_ret     CHAR(5);
DEFINE vsqlerr      INTEGER;
DEFINE sql_err      SMALLINT;
DEFINE isam_err     SMALLINT;
DEFINE error_info   CHAR(100);
DEFINE vtarjeta     CHAR(20);

-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************
LET scod_ret     = "000";
LET vsqlerr      = 0;
LET vtarjeta     = "";


-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************
BEGIN
   ON EXCEPTION SET sql_err, isam_err, error_info
      SET DEBUG FILE TO "cons_cred_tarjeta.err";
   --   TRACE sql_err||" * "||isam_err||" * "||error_info;
      LET scod_ret = sql_err;
      RETURN scod_ret, vtarjeta;
   END EXCEPTION;



-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************


	-- ****************************
	-- Extrae Datos de la Tarjeta *
	-- ****************************

	SELECT num_tarjeta
	  INTO vtarjeta
          FROM sd_tarjeta
	 WHERE empresa = o_empresa AND
	       num_credito = o_credito AND
	       status_tar = "A";

	IF vtarjeta  is null THEN
	   let vtarjeta = "";
	END IF

END
	RETURN scod_ret, vtarjeta;

END PROCEDURE;
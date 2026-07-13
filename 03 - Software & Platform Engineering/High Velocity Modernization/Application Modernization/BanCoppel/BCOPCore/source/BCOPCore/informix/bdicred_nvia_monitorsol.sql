CREATE PROCEDURE "informix".nvia_monitorsol(o_empresa   CHAR(3),
				 o_numsol   CHAR(20),
				 o_ejecutivo CHAR(8))


RETURNING CHAR(5);      -- Codigo de Retorno

-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
DEFINE scod_ret     CHAR(3);
DEFINE vsqlerr      INTEGER;
DEFINE v_status     CHAR(2);
DEFINE v_hoy	    DATE;

-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************
LET scod_ret     = "000";
LET vsqlerr      = 0;
LET v_status     = "??";
SELECT fecha_hoy INTO v_hoy FROM bdinteg:sd_fechas;
-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************
BEGIN
ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
      LET scod_ret=vsqlerr;
      RETURN scod_ret;
   END IF;
END EXCEPTION;


-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************

	SELECT status_solicitud INTO v_status
	  FROM ss_solicitudes 
	 WHERE empresa = o_empresa
	   AND num_solicitud = o_numsol;

	IF v_status = "AP" THEN
		LET scod_ret = "001";
		RETURN scod_ret;
	END IF
	
	UPDATE ss_solcitiudes SET status_solicitud = "AN"
	 WHERE empresa = o_empresa
	   AND num_solicitud = o_numsol;

	INSERT INTO ss_autorizacion
	 (empresa, ejecutivo_auto, num_solciitud, status_solicitud,
	  comentario, fecha_entrada, fecha_salida)
	VALUES
	 (o_empresa, o_ejecutivo, o_numsol, "AN", 
	  "Anulada por peticion del Cliente", v_hoy, v_hoy);


    RETURN scod_ret;
                  
END

END PROCEDURE
;
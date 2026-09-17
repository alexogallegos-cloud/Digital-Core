CREATE PROCEDURE "informix".determina_lincred_tc_cjunk_web(o_empresa CHAR(3), o_numsol CHAR(20), o_cte_nvo CHAR(1))
RETURNING CHAR(5)       AS retorno,
          MONEY(14,2)   AS linea_cred,
          MONEY(14,2)   AS capacidad_de_pago,
          INTEGER       AS plazo;

	-- ****************************************************************************
	-- *                        DEFINICION DE VARIABLES                           *
	-- ****************************************************************************
	DEFINE scod_ret    CHAR(5);
	DEFINE vsqlerr     INTEGER;
	DEFINE v_linea     MONEY(14,2);
	DEFINE v_capacidad MONEY(14,2);
	DEFINE iPlazoMax   INTEGER;
	DEFINE cSolicitud  CHAR(20);

	-- ****************************************************************************
	-- *                        ASIGNACION DE VARIABLES                           *
	-- ****************************************************************************
	LET scod_ret     = "00000";
	LET vsqlerr      = 0;
	LET v_linea      = 0;
	LET v_capacidad  = 0;
	LET iPlazoMax    = 0;
	LET cSolicitud   = '';

	-- ****************************************************************************
	-- *                        CONTROL DE ERRORES                                *
	-- ****************************************************************************
	
	BEGIN
		ON EXCEPTION SET vsqlerr
			IF vsqlerr != 0 THEN
				LET scod_ret=vsqlerr;
				RETURN TRIM(scod_ret), NVL(v_linea,0),NVL(v_capacidad,0),NVL(iPlazoMax,0);
			END IF;
		END EXCEPTION;

		-- SET DEBUG FILE TO '/informix/determina_lincred_tc_cjunk.out';
		-- TRACE ON;
		
		SELECT num_solicitud INTO cSolicitud FROM bdisolic:ss_solicitudes WHERE num_solicitud = o_numsol AND canal_sol IN ('6','7');
		
		IF cSolicitud = '' THEN
			EXECUTE PROCEDURE bdisolic:"informix".determina_lincred_tc_cjunk(o_empresa, o_numsol, o_cte_nvo) 
			INTO scod_ret, v_linea, v_capacidad, iPlazoMax;
		END IF;

		RETURN LPAD(TRIM(scod_ret),5,'0'), NVL(v_linea,0), NVL(v_capacidad,0), NVL(iPlazoMax,0);
	END
	
END PROCEDURE

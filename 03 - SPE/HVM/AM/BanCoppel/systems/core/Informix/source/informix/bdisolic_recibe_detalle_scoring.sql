CREATE PROCEDURE "informix".recibe_detalle_scoring(o_empresa CHAR(3),
				o_num_solicitud   CHAR(20),
				o_tpsol         CHAR(1),
				o_tipper        CHAR(2),
				o_seccion       SMALLINT,
				o_grupo         SMALLINT,
				o_elemento      SMALLINT)

RETURNING CHAR(5);

-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
DEFINE scod_ret     CHAR(6);
DEFINE vsqlerr      INTEGER;
DEFINE v_valor      DECIMAL(5,2);
DEFINE vExistecuenta smallint;
-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************
LET scod_ret     = "000";
LET vsqlerr      = 0;
LET v_valor      = 0;
LET vExistecuenta = 0;
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

--SET ISOLATION TO COMMITTED READ LAST COMMITTED;
SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO wait 3;
--SET DEBUG FILE TO "recibe_det_scoring.out";
--TRACE ON;
-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************

	-- *********************************************
	-- Extrae los pesos de los elementos recibidos *
	-- *********************************************

    SELECT first 1 empresa
      into vExistecuenta
      FROM "informix".ss_solicitudes_movil							
	  WHERE empresa  = o_empresa 
		AND  num_solicitud = o_num_solicitud;
    

	IF vExistecuenta is null THEN
        SELECT valor INTO v_valor
          FROM ss_scoring_pesos
         WHERE empresa = o_empresa
           AND tp_solicitud = o_tpsol
           AND grupo = o_grupo
           AND elemento = o_elemento
           AND seccion = o_seccion
           AND tpo_persona = o_tipper;

        IF v_valor IS NULL THEN
            LET v_valor = 0;
        END IF
				
		INSERT INTO ss_detalle_scoring
		 (empresa, seccion, grupo, elemento, tpo_persona, num_solicitud, valor)
		VALUES
		 (o_empresa, o_seccion, o_grupo, o_elemento, o_tipper, o_num_solicitud,
		  v_valor);
	END IF;

END
	RETURN scod_ret;

END PROCEDURE
;
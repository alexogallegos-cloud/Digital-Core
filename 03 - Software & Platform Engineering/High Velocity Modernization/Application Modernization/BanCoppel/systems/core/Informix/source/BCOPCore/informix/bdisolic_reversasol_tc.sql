CREATE PROCEDURE "informix".reversasol_tc(p_empresa   CHAR(3),
				p_numsol  	CHAR(20),
				p_ejecutivo	CHAR(8))

RETURNING CHAR(5);	-- Codigo de Retorno

-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
DEFINE scod_ret		CHAR(5);
DEFINE vsqlerr		INTEGER;
DEFINE v_status		CHAR(2);
DEFINE v_hoy		DATE;

-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************
LET scod_ret	= "00000";
LET vsqlerr		= 0;
LET v_status	= "";
LET v_hoy		= "";

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
	SET ISOLATION TO DIRTY READ;
	set lock mode to wait 3;
	
	-- CGP Se agrega validacion para  el no de solicitud
	if p_numsol = '' then
		RETURN scod_ret;
	end if

    IF NOT EXISTS(select * from ss_solicitudes_movil where num_solicitud =p_numsol) THEN

        SELECT status_solicitud INTO v_status
        FROM ss_solicitudes
        WHERE empresa = p_empresa AND num_solicitud = p_numsol;
       
	   	IF (v_status <> 'PC')  THEN  --IPCB CorrecciÃ³n, anulaciÃ³n de solicitudes unicamente de estatus PC.  LÃ­nea original (--IF (v_status <> 'AP') or (v_status = 'AN') or (v_status = 'MC')  THEN)
            LET scod_ret = "00001";
            RETURN scod_ret;
        END IF

        SELECT fecha_hoy INTO v_hoy
        FROM bdicred:sd_fechas
        where empresa = p_empresa;

        UPDATE ss_solicitudes SET status_solicitud = 'AN'
        WHERE empresa = p_empresa
        AND num_solicitud = p_numsol;

        INSERT INTO ss_autorizacion
            (empresa, ejecutivo_auto, num_solicitud, status_solicitud,
            comentario, fecha_entrada, fecha_salida)
        VALUES
            (p_empresa, p_ejecutivo, p_numsol, 'AN',
            'Anulada por peticion del Cliente', v_hoy, v_hoy);
    END IF;

    RETURN scod_ret;

END

END PROCEDURE;
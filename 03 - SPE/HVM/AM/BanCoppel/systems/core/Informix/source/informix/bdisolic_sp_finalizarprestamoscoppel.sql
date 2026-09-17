CREATE PROCEDURE "informix".sp_finalizarprestamoscoppel(numctex char(20), folio_prestamox char(20), tokenx char(8), status_solicitudx char(1))
RETURNING CHAR(6), CHAR(40);


-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************

DEFINE v_cod_ret			CHAR(6);
DEFINE vsqlerr				INTEGER;
DEFINE sMensaje			    char(40);
DEFINE p_fecha			    DATE;


-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************

LET v_cod_ret				= "000000";
LET vsqlerr					= 0;
LET sMensaje				= "REGISTRO ACTUALIZADO CON ÉXITO";
LET p_fecha				    = TODAY;

-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************

BEGIN
    ON EXCEPTION SET vsqlerr
    IF vsqlerr != 0 THEN
        LET v_cod_ret=vsqlerr;
        LET sMensaje = "ERROR AL ACTUALIZAR REGISTRO";
        RETURN v_cod_ret, sMensaje;
    END IF;
    END EXCEPTION;


	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************

    SELECT fecha_hoy
        INTO p_fecha
    FROM bdinteg: si_fechas;

    UPDATE bdisolic:informix.ss_prestamoscoppel SET fecha_contratacion = p_fecha, status_result = '1', status_solicitud = status_solicitudx 
            WHERE numcte = numctex and folio_prestamo = folio_prestamox and token = tokenx;

    RETURN v_cod_ret, sMensaje;	
END;	

END PROCEDURE;
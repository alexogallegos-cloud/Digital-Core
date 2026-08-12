CREATE PROCEDURE "informix".sp_finalizarprestamoscoppel_web(
										numctex CHAR(20), 
										folio_prestamox CHAR(20), 
										tokenx CHAR(8), 
										status_solicitudx CHAR(1))
										
RETURNING CHAR(5), CHAR(40);

-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************

DEFINE v_cod_ret			CHAR(5);
DEFINE vsqlerr				INTEGER;
DEFINE sMensaje			    CHAR(40);
DEFINE p_fecha			    DATE;

-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************

LET v_cod_ret				= "00000";
LET vsqlerr					= 0;
LET sMensaje				= "REGISTRO ACTUALIZADO CON EXITO";
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

	--SET DEBUG FILE TO '/INFORMIXDUMP/sp_finalizarprestamoscoppel_web.trc';    
    --TRACE ON;
	
-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************

    SELECT {+INDEX(bdinteg:"informix".si_fechas idx_si_fechas)}  fecha_hoy
        INTO p_fecha
    FROM bdinteg:"informix".si_fechas;

    UPDATE bdisolic:"informix".ss_prestamoscoppel 
		SET fecha_contratacion = p_fecha, 
			status_result = '1', 
			status_solicitud = status_solicitudx 
    WHERE numcte = numctex 
	AND folio_prestamo = folio_prestamox 
	AND token = tokenx;
	
    RETURN v_cod_ret, sMensaje;	
END;

END PROCEDURE

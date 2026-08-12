CREATE PROCEDURE "informix".sp_obtenerfechamaximacierresucursal(cSucursal CHAR(4))
RETURNING CHAR(6), DATE;

--VARIABLES
DEFINE vcodret      CHAR(6);
DEFINE tFecha       DATE;
DEFINE vsqlerr      INTEGER;
DEFINE cContador    INTEGER;

BEGIN
   ON EXCEPTION SET vsqlerr
        IF vsqlerr <> 0 THEN
            let vcodret = vsqlerr;
            RETURN  vcodret, tFecha;
        END IF;
    END EXCEPTION;

    -- Inicializa Variables
    LET vcodret = '000000';
    LET tFecha = '01-01-1900';
    LET cContador = 0;

    SELECT COUNT(*)
    INTO cContador
    FROM mi_rptcierresucestatus
    WHERE Sucursal = cSucursal;

    IF cContador <> 0 THEN
        SELECT MAX(fecha_rptcierre)
        INTO tFecha
        FROM mi_rptcierresucestatus
        WHERE Sucursal = cSucursal;
    ELSE
         LET vcodret = '000001';
    END IF

END;
    RETURN vcodret, tFecha;
END PROCEDURE
;
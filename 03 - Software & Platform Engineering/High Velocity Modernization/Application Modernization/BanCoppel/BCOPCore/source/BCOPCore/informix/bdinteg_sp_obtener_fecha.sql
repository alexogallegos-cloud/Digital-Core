CREATE PROCEDURE "informix".sp_obtener_fecha()
        RETURNING DATETIME YEAR TO SECOND;

    -- Realizo   : Javier Humberto Calderon Zazueta
    -- Actividad : Obetener fecha del servidor
    -- Solicitó  : Diana Castellanos
    -- Fecha     :  18/07/2008

       DEFINE vFecha  DATETIME YEAR TO SECOND;
       DEFINE sql_err integer;

ON EXCEPTION SET sql_err
       IF sql_err <> 0 THEN
        RETURN vFecha;
       END IF;
END EXCEPTION;

BEGIN

    SELECT LIMIT 1 current
    INTO vFecha
    FROM si_bpiusuarios;

    RETURN vFecha;
END;

END PROCEDURE;
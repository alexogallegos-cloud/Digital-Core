CREATE PROCEDURE "informix".sp_obt_cant_det_cred(pCuenta char(20),
                                                                    pMes integer,
                                                                    pAnio integer)
        RETURNING char(5), integer;

    -- Realizo   : Javier Humberto Calderon Zazueta
    -- Actividad : Obetener cantidad de detalles del estado de cuenta de credito
    -- Solicitó  : Diana Castellanos
    -- Fecha     :  17/07/2008

       DEFINE vcodret   char(5);
       DEFINE vCantidad  integer;
       DEFINE sql_err       integer;

ON EXCEPTION SET sql_err
       IF sql_err <> 0 THEN
        LET vcodret = sql_err;
        RETURN vcodret, vCantidad;
       END IF;
END EXCEPTION;

LET vcodret = '000';
LET vCantidad = 0;
BEGIN
    SELECT COUNT(secuencia) AS cantidad
    INTO vCantidad
    FROM bdicred@pld_tcp:sd_detalle_edocta
    WHERE num_credito = pCuenta
    AND MONTH(fecha_emision) = pMes
    AND YEAR(fecha_emision) = pAnio;

    RETURN vcodret, vCantidad;
END;

END PROCEDURE;
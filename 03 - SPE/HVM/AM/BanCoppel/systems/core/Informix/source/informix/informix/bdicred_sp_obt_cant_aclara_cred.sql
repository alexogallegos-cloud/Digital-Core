CREATE PROCEDURE "informix".sp_obt_cant_aclara_cred(pCuenta char(20),
                                                                    pMes integer,
                                                                    pAnio integer)
        RETURNING char(5), integer;

    -- Realizo   : Javier Humberto Calderon Zazueta
    -- Actividad : Obetener cantidad de detalles de los movimientos en proceso de aclaracion
    -- Solicitó  : Mauricio Leon Ibarra
    -- Fecha     :  20/08/2008

       DEFINE vcodret   char(5);
       DEFINE vCantidad  integer;
       DEFINE sql_err       integer;
       DEFINE femision   date;

ON EXCEPTION SET sql_err
       IF sql_err <> 0 THEN
        LET vcodret = sql_err;
        RETURN vcodret, vCantidad;
       END IF;
END EXCEPTION;

LET vcodret = '000';
LET vCantidad = 0;
LET femision = '01-01-1900';

BEGIN
    /*SELECT COUNT(secuencia) AS cantidad
    INTO vCantidad
    FROM sd_aclaraciones_edocta
    WHERE num_credito = pCuenta
    AND MONTH(fecha_emision) = pMes
    AND YEAR(fecha_emision) = pAnio;*/
    let femision = mdy(pMes,20,pAnio);   

    SELECT COUNT(secuencia) AS cantidad
    INTO vCantidad
    FROM bdicred@pld_tcp:sd_aclaraciones_edocta
    WHERE fecha_emision = femision
    AND num_credito = pCuenta;

    RETURN vcodret, vCantidad;
END;

END PROCEDURE;
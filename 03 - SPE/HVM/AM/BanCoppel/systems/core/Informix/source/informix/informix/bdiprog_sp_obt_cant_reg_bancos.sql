CREATE PROCEDURE "informix".sp_obt_cant_reg_bancos()
        RETURNING char(5), integer;

    -- Realizo   : Javier Humberto Calderon Zazueta
    -- Actividad : Obetener cantidad de registros en la tabla si_bancos
    -- Solicitó  : Mauricio Leon Ibarra
    -- Fecha     : 05/12/2008

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

    SELECT COUNT(banco) AS cantidad
    INTO vCantidad
    FROM bdinteg:si_bancos;

    RETURN vcodret, vCantidad;
END;

END PROCEDURE;
CREATE PROCEDURE "informix".sp_obt_cant_reg_ctasterceros(pNumCliente char(20), pCvePago char(2))
        RETURNING char(5), integer;

    -- Realizo   : Javier Humberto Calderon Zazueta
    -- Actividad : Obetener cantidad de registros de un cliente en la tabla pp_ctasterceros con estado 01
    -- Solicitó  : Mauricio Leon Ibarra
    -- Fecha     : 09/12/2008

	-- Modifico  : Javier Humberto Calderon Zazueta
	-- Fecha     : 04/02/2009
	-- Motivo    : Parametrizar la clave de pago y filtrar las cuentas por dicho parametro

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

	SELECT COUNT(cuenta) AS cantidad
        INTO vCantidad
        FROM bdiprog:pp_ctasterceros AS ct
        INNER JOIN bdiprog:pp_cuentapago AS cp ON ct.cve_cuenta = cp.cve_cuenta AND cp.cve_pago = pCvePago
	WHERE ct.num_cte = pNumCliente AND ct.cve_estado = '01';

    RETURN vcodret, vCantidad;
END;

END PROCEDURE;
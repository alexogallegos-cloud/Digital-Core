CREATE PROCEDURE "informix".sp_obt_cant_reg_referencias_bex(pNumCliente char(20), pCveCuenta char(2),pCveBanco char(3))
        RETURNING char(5), integer;

       DEFINE vcodret   char(5);
       DEFINE vCantidad  integer;
       DEFINE sql_err       integer;

ON EXCEPTION SET sql_err
       IF sql_err <> 0 THEN
        LET vcodret = sql_err;
        RETURN vcodret, vCantidad;
       END IF;
END EXCEPTION;

LET vcodret = '00000';
LET vCantidad = 0;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3 ;

BEGIN
	SELECT COUNT(cuenta) AS cantidad
	INTO vCantidad
	FROM bdiprog:pp_ctasterceros_bex
	WHERE num_cte=TRIM(pNumCliente)
	AND cve_banco=TRIM(pCveBanco)
	AND cve_cuenta=TRIM(pCveCuenta)
	AND cve_estado='01';
	--AND (current - ( YEAR(fecha_insert) || '-' || MONTH(fecha_insert) || '-' || DAY(fecha_insert) || ' ' || hora_insert)::DATETIME YEAR TO FRACTION) > '0 00:30:00';

    RETURN vcodret, vCantidad;
END;

END PROCEDURE;
CREATE PROCEDURE "informix".sp_reg_monto_maximo(pCliente CHAR(20), pCuenta CHAR(20), pBanco CHAR(3), pMonto MONEY(16,2))
        RETURNING char(5);

    -- Realizo   : Walber Castro
    -- Actividad : Registrar monto máximo de las cuentas/referencias/telefonos/tarjetas frecuentes.
    -- Solicitó  : José de Jesus Nevarez
    -- Fecha     : 11/17/2011

       DEFINE vcodret   char(5);       
       DEFINE sql_err   integer;

ON EXCEPTION SET sql_err
       IF sql_err <> 0 THEN
        LET vcodret = sql_err;
        RETURN vcodret;
       END IF;
END EXCEPTION;

LET vcodret = '000';

BEGIN
	SET LOCK MODE TO WAIT 10;

    UPDATE bdiprog:"informix".pp_ctasterceros SET monto_maximo = pMonto WHERE num_cte = pCliente AND cuenta = pCuenta AND cve_banco = pBanco;
    RETURN vcodret;

END;
END PROCEDURE;
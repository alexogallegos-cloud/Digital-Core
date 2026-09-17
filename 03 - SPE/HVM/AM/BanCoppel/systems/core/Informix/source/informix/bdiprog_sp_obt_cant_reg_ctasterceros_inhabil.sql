CREATE PROCEDURE "informix".sp_obt_cant_reg_ctasterceros_inhabil(pNumCliente char(20), pCvePago char(2))
        RETURNING char(5), integer;

    -- Realizo   : Walber Castro
    -- Actividad : Obetener cantidad de registros de ctas frecuentes inhabiles.
    -- Solicitó  : Diana Castellanos
    -- Fecha     : 29/09/2010

DEFINE vcodret   char(5);
DEFINE vCantidad  integer;
DEFINE sql_err       integer;
DEFINE v_FechaInsert		DATE;
DEFINE v_HoraInsert			DATETIME HOUR TO SECOND;
DEFINE v_FechaHoraInsert	DATETIME YEAR TO FRACTION;	

LET vcodret = '000';
LET vCantidad = 0;

BEGIN	
	ON EXCEPTION SET sql_err
       IF sql_err <> 0 THEN
        LET vcodret = sql_err;
        RETURN vcodret, vCantidad;
       END IF;
	END EXCEPTION;
	
	FOREACH
		SELECT fecha_insert, hora_insert--COUNT(cuenta) AS cantidad
			INTO v_FechaInsert, v_HoraInsert
			FROM bdiprog:pp_ctasterceros AS ct
			INNER JOIN bdiprog:pp_cuentapago AS cp ON ct.cve_cuenta = cp.cve_cuenta AND cp.cve_pago = pCvePago
		WHERE ct.num_cte = pNumCliente AND ct.cve_estado = '01'
		
		LET v_FechaHoraInsert = ( YEAR(v_FechaInsert) || '-' || MONTH(v_FechaInsert) || '-' || DAY(v_FechaInsert) || ' ' || v_HoraInsert)::DATETIME YEAR TO FRACTION;
		IF (current - v_FechaHoraInsert) < '0 00:30:00' THEN
			LET vCantidad = vCantidad + 1;
		END IF;
	END FOREACH;
    RETURN vcodret, vCantidad;
END;

END PROCEDURE;
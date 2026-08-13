CREATE PROCEDURE "informix".spsldetreporteentero(p_dfechareporte DATE)


RETURNING CHAR(5), CHAR(20), CHAR(20), DATE, MONEY(16,2);

	DEFINE v_scodret 			  CHAR(5);
	DEFINE v_snum_cte             CHAR(20);
	DEFINE v_scuenta_ret		  CHAR(20);
	DEFINE v_dfecha_ret			  DATE;
	DEFINE v_mrecaudado	     	  MONEY (16,2);

	DEFINE sql_err                INTEGER;

	ON EXCEPTION SET sql_err
      	LET v_scodret = sql_err;
      	RETURN v_scodret, v_snum_cte, v_scuenta_ret, v_dfecha_ret, v_mrecaudado;
   	END EXCEPTION;

	LET v_scodret = '001';

	--********************************************************
	-- Creado por Fabiola Corrales Tapia 15/MAY/2007 	   --*
    -- Modificado Julio Cesar Polanco 30/06/2008           --*
	-- Debug del Procedure                           	   --*
 	-- SET DEBUG FILE TO "/tmp/spsldetreporteentero.out";  --*
 	-- TRACE ON;                                           --*
	--********************************************************

	BEGIN
		IF EXISTS (SELECT fech_entero 
                     FROM bdilide:sl_enteros 
                    WHERE fech_entero = p_dfechareporte 
                      AND monto > 0) THEN
			FOREACH
				SELECT num_cte, cuenta_ret, fecha_ret, imp_recaudado
				  INTO v_snum_cte, v_scuenta_ret, v_dfecha_ret, v_mrecaudado
				  FROM bdilide:sl_detlide 
                 WHERE num_cte BETWEEN (SELECT MIN(num_cte) FROM bdilide:sl_detlide) and (SELECT MAX(num_cte) FROM bdilide:sl_detlide)
                   AND fecha_ret = p_dfechareporte
                 ORDER BY num_cte   

				LET v_scodret = '000';
				RETURN v_scodret, v_snum_cte, v_scuenta_ret, v_dfecha_ret, v_mrecaudado WITH RESUME;
			END FOREACH
		END IF
	END
END PROCEDURE

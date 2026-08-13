CREATE PROCEDURE "informix".sp_obtener_cta_con_num_tar(pEmpresa char(3),
                                                        pNumTarj char(16))
        RETURNING char(5), char(11);

    -- Realizo   : Javier Humberto Calderon Zazueta
    -- Actividad : Obtener numero de cuenta con el numero de tarjeta
    -- Solicitó  : Mauricio Leon
    -- Fecha     : 13/05/2009

       DEFINE vcodret char(5);
       DEFINE vcuenta char(20);
       DEFINE sql_err integer;

	LET vcodret = '000';
	LET vcuenta = '';

	BEGIN
		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				LET vcodret = sql_err;
				RETURN vcodret, vcuenta;
		    END IF;
		END EXCEPTION;
		IF EXISTS(SELECT cuenta FROM sc_tarjeta WHERE empresa = pEmpresa AND num_tarjeta = pNumTarj AND tipo_tarjeta = 'T' AND status_tar = 'A') THEN
			SELECT cuenta 
			INTO vcuenta
			FROM sc_tarjeta 
			WHERE empresa = pEmpresa 
			AND num_tarjeta = pNumTarj
			AND tipo_tarjeta = 'T' 
			AND status_tar = 'A';
		ELSE
			LET vcodret = '001';
		END IF;
		RETURN vcodret, vcuenta;
	END;

END PROCEDURE;
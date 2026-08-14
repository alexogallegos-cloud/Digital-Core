CREATE PROCEDURE "informix".sp_obtener_status_cuenta(pempresa CHAR(3),pcuenta CHAR(20))
RETURNING CHAR(5);

-------------------------------------------------------------------------------------------------------
	--Realizó: Jose Ruben Lopez Hernadez
	--Fecha: 11/06/2013
	--Actividad:Se verifica el estatus de la cuenta que sea 1
	--BD: bdicheq
-------------------------------------------------------------------------------------------------------
	
	--Define variables
	DEFINE sql_err integer;
	DEFINE cod_ret char (5);
	DEFINE statusCta char(2);

	--Inicializa Variables
	LET sql_err = 0;
	LET cod_ret = '00000';
	LET statusCta='00';
	BEGIN
	
	 ON EXCEPTION SET sql_err
		IF sql_err <> 0 THEN
			LET cod_ret = sql_err;
			RETURN cod_ret;
		END IF;
	 END EXCEPTION;
	 
	SELECT {+INDEX(bdicheq:"informix".sc_maechq idx_sc_maechq3)}status_cta
      INTO statusCta
      FROM bdicheq:"informix".sc_maechq
     WHERE empresa = pempresa
       AND cuenta = pcuenta;

	IF statusCta<>1 THEN
			LET cod_ret = '00001'; --Cuenta diferente 1(estatus invalido)
	 END IF;

	 RETURN cod_ret;

	END;

END PROCEDURE;
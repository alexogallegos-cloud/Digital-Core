CREATE PROCEDURE "informix".sp_actualizabitacora_for_pagogdf(pLineaCaptura char(40), pCertificado char(40)) RETURNING char(5);

    -- Realizo   : Solser
    -- Actividad : Reimpresion de comprobante de pago de GDF
    -- Fecha     : 25/04/2018

-- DEFINICION DE VARIABLES
DEFINE cod_ret char(5);
DEFINE sql_err integer;

-- INICIALIZA VARIABLES
LET cod_ret  = "00000";

BEGIN
    ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            LET cod_ret = sql_err;
            RETURN cod_ret;
      END IF ;
    END EXCEPTION ;

    IF pLineaCaptura IS NULL OR pCertificado IS NULL THEN
		LET cod_ret = '00001'; 		RETURN cod_ret;
    END IF

    -- La linea de captura se guardo en el campo cgen2
    -- El certificado se debe guardar en el campo cgen7
    UPDATE bdibei:"informix".bei_bitacora
        SET cgenerico6 = pCertificado
        WHERE cgenerico2 = pLineaCaptura;

	RETURN cod_ret;

	END;
END PROCEDURE;
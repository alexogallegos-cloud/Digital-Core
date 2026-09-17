CREATE PROCEDURE "informix".sp_obt_cant_pagos_diferidos(pCuenta CHAR(20),pMes INTEGER, pAnio INTEGER)
	RETURNING CHAR(5), INTEGER;
-- Realizó   : Moisés Soriano Guerrero
-- Actividad : Obetener cantidad de pagos diferidos
-- Solicitó  : Alejandro Vazquez
-- Fecha     :  13/07/2015
DEFINE vcodret   	CHAR(5);
DEFINE vCantidad  	INTEGER;
DEFINE sql_err      INTEGER;
LET vcodret = '000';
LET vCantidad = 0;
BEGIN
	ON EXCEPTION SET sql_err
		   IF sql_err <> 0 THEN
			LET vcodret = sql_err;
			RETURN vcodret, vCantidad;
		   END IF;
	END EXCEPTION;
	
	SET LOCK MODE TO WAIT 3;
    SELECT COUNT(num_credito) AS cantidad
    INTO vCantidad
    FROM bdicred@pld_tcp:"informix".sd_detalle_dif_edocta
    WHERE num_credito = pCuenta
    AND MONTH(fecha_emision) = pMes
    AND YEAR(fecha_emision) = pAnio;
    RETURN vcodret, vCantidad;
END;
END PROCEDURE;
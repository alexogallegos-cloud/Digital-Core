CREATE PROCEDURE "informix".sp_obtenercredito_iccat(pNumCliente char (9))
returning char(5), char (20), char (20);

   --Elaboró: Javier A. Chávez T.
   --Actividad: consulta el número de crédito y tarjeta de un cliente
   --Solicito: Mauricio León
   --Fecha: 05-05-09
   --Modificó: Pedro Enrique Zavala Valdez
   --Fecha: 06-05-09

DEFINE sql_error integer;
DEFINE cod_ret  char  (5);
DEFINE vCredito char (20);
DEFINE vTarjeta char (20);

LET cod_ret = '';
LET vCredito = '';
LET vTarjeta = '';

 BEGIN

 ON EXCEPTION SET sql_error
	IF sql_error <> 0 THEN
		LET cod_ret = sql_error;
		return cod_ret, vCredito, vTarjeta;
	END IF;
 END EXCEPTION;


	IF (pNumCliente = "") THEN
		LET cod_ret = '001'; -- El Cliente viene vacio
	ELSE
	   	IF EXISTS(SELECT numcte FROM bdicred:sd_maecred WHERE numcte = pNumCliente) THEN
				SELECT LIMIT 1 c.num_credito,t.num_tarjeta INTO vCredito,vTarjeta FROM bdicred:sd_maecred c 
				INNER JOIN bdicred:sd_tarjeta t ON c.num_credito = t.num_credito 
				WHERE c.numcte = pNumCliente;
				
				LET cod_ret = '000';
				
				IF (vCredito = '' OR vCredito IS NULL) THEN
					LET cod_ret = '003'; -- El crédito viene vacio
				ELIF (vTarjeta = '' OR vTarjeta IS NULL) THEN
					LET cod_ret = '004'; -- La tarjeta viene vacia
				END IF;
				
		ELSE
				LET cod_ret = '002'; -- No existe el número de cliente
		END IF;

	END IF;
	return cod_ret,vCredito,vTarjeta;

 END;

END PROCEDURE;
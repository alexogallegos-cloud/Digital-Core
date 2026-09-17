CREATE PROCEDURE "informix".cons_combina(pempresa char(3),
                                         pcuenta CHAR(20))
   RETURNING         CHAR(5),
                     CHAR(120);
   DEFINE cod_ret CHAR(5);
   DEFINE wcombinacion CHAR(120);
   DEFINE sqlerr       INTEGER;

   ON EXCEPTION SET sqlerr
   LET cod_ret = "000";
   LET wcombinacion = " ";
      LET cod_ret = sqlerr;
      RETURN cod_ret,pcuenta;
   END EXCEPTION ;

   LET cod_ret = "000";
   LET wcombinacion = " ";
   SELECT
      combinacion
   INTO
      wcombinacion
   FROM
      sc_firmantes
   WHERE
      empresa = pempresa and cuenta = pcuenta
   AND
      secuencia = 1;

   IF (wcombinacion IS NULL) THEN
      LET wcombinacion = " ";
   END IF
   RETURN cod_ret, wcombinacion ;

END PROCEDURE;
CREATE PROCEDURE "informix".obtenperiodos_edocuenta(				
				pnum_tarjeta char(20)
				)
RETURNING CHAR(5),DATE;



DEFINE cod_ret             char(5);
DEFINE sql_err             integer;

DEFINE v_fecha_emision	DATE;


--INICIALIZO VARIABLES

LET v_fecha_emision = " ";

 
 --SET DEBUG FILE TO "obtenPeriodos_edocuenta.out";
 --TRACE ON;


BEGIN

  ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            LET cod_ret = sql_err;
            RETURN cod_ret," ";
        END IF
   END EXCEPTION;



   LET cod_ret = "000";




    FOREACH  SELECT DISTINCT fecha_emision INTO v_fecha_emision
    		 --FROM sd_encabezado_edocta
			 FROM bdicred@pld_tcp:sd_encabezado_edocta
    		 WHERE num_tarjeta = pnum_tarjeta
             union
             SELECT DISTINCT fecha_emision 
    		 FROM sd_encabezado_edocta_hist
			 --FROM bdicred@pld_tcp:sd_encabezado_edocta_hist
    		 WHERE num_tarjeta = pnum_tarjeta
			 ORDER BY fecha_emision DESC

			RETURN cod_ret,v_fecha_emision WITH RESUME;

    END FOREACH;


END;

--Procedimiento para el cambio de mensajes
--AUTOR : Cristian Campos Diaz',
--FECHA : 13/Mayo/2008',
--BD    : BDICRED'
END PROCEDURE;
CREATE PROCEDURE "informix".sp_actualiza_fecha(pfecha date)
RETURNING char(6);


DEFINE scod_ret               CHAR(5);
DEFINE vsqlerr                INTEGER;
DEFINE ccredito             CHAR(20);
DEFINE ccontador              INTEGER;

LET scod_ret     = "000";
LET vsqlerr      = 0;
LET ccontador    = 1;


BEGIN
ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
      LET scod_ret=vsqlerr;
      RETURN scod_ret;
   END IF;
END EXCEPTION;

  FOREACH WITH HOLD 
         select num_credito 
         into ccredito
         from bdicred:sd_sdodiario 

        IF ccontador=1 then
          BEGIN WORK;
        END IF;
         
         update bdicred:sd_sdodiario set fecha = mdy(month(today),'01',year(today)) where fecha=today and num_credito=ccredito;

         IF ccontador>=70000 THEN
            COMMIT WORK;
            ---update statistics medium for table bdiburo:br_traslado;
            LET ccontador=1;
         ELSE
            LET ccontador=ccontador+1;
         END IF;

    END FOREACH; 

  IF ccontador > 1 THEN
        COMMIT WORK; 
  END IF;

    LET ccontador = 1;

RETURN scod_ret;
END
END PROCEDURE;
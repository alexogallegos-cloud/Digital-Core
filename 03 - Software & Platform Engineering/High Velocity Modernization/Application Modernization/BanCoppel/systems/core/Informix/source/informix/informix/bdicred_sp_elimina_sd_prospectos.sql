CREATE PROCEDURE "informix".sp_elimina_sd_prospectos()
RETURNING CHAR(6);

-- *********************************************************************
-- *                        DEFINICION DE VARIABLES                    *
-- *********************************************************************
DEFINE scod_ret         CHAR(6);
DEFINE vsqlerr          INTEGER;
DEFINE numcredito       CHAR(20);
DEFINE icontador        INTEGER;

-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************
LET scod_ret  = "000";
LET vsqlerr = 0;
LET numcredito="";
LET icontador=1;

-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************
BEGIN
ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
      LET scod_ret=vsqlerr;
      RETURN scod_ret;
   END IF;
END EXCEPTION;

--SET DEBUG FILE TO "sp_elimina_sd_prospectos.out";
--TRACE ON;

  FOREACH WITH HOLD 

        SELECT num_credito
          INTO numcredito
	      FROM "informix".sd_prospectos 
		 WHERE num_producto = '6900'
		   AND num_promo = '7'		 

        IF icontador = 1 THEN
          BEGIN WORK;
        END IF;

        DELETE FROM "informix".sd_prospectos WHERE num_credito = numcredito AND num_producto = '6900' AND num_promo = '7';		
     
    IF icontador = 2000 then
        COMMIT WORK; 
        LET icontador = 1;
    ELSE
        LET icontador = icontador + 1;
    END IF;

  END FOREACH


  IF icontador > 1 THEN
        COMMIT WORK; 
  END IF;


  UPDATE statistics medium FOR TABLE "informix".sd_prospectos;


  RETURN scod_ret;
END
END PROCEDURE;
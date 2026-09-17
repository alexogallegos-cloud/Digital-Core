CREATE PROCEDURE "informix".limpia_cierre_hist()
RETURNING CHAR(5);

-- *********************************************************************
-- *                        DEFINICION DE VARIABLES                    *
-- *********************************************************************
DEFINE scod_ret         CHAR(5);
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

--SET DEBUG FILE TO "limpia_amortizacredito.out";
--TRACE ON;

-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************
	-- ************************************************************
	-- Datos de MAEDCRED QUE DEBEN BORRARSE DE SD_AMORTIZA_CREDTO *
	-- ************************************************************

  FOREACH WITH HOLD 

        SELECT num_credito
          INTO numcredito
	      FROM bdicred:sd_maesdos where empresa='001'

        IF icontador=1 then
          BEGIN WORK;
        END IF;

        DELETE FROM bdicred:sd_maesdoshist WHERE empresa='001' AND num_credito=numcredito AND fecha = '07/20/2008';
     
    IF icontador=2000 then
        COMMIT WORK; 
        LET icontador=1;
    ELSE
        LET icontador=icontador+1;
    END IF;

  END FOREACH


  IF icontador > 1 THEN
        COMMIT WORK; 
  END IF;


  update statistics medium for table bdicred:sd_maesdoshist;


  RETURN scod_ret;
END
END PROCEDURE;
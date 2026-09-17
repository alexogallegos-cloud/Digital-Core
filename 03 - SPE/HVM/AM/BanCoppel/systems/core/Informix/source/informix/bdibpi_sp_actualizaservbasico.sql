CREATE PROCEDURE "informix".sp_actualizaservbasico(pNumCte char(9))
RETURNING char(5);
   
   -- CreaciÃ³n: Solser
   -- DescripciÃ³n: Actualiza la tabla: bdibpi:bpi_serviciobasico 
   -- y el tipo de servicio en la tabla: bdinteg:si_bpiusuarios
   -- SolicitÃ³: BanCoppel
   -- Fecha: 16/04/2020 
 
-- ***************************************************************************
-- DefiniciÃ³n de variables
-- ***************************************************************************
   DEFINE cod_ret char(5);
   DEFINE sql_err integer;
   DEFINE cantidad integer;

-- ***************************************************************************
-- InicializaciÃ³n de variables
-- ***************************************************************************
   LET cod_ret = "00000";

   
   
   Set isolation to dirty read;
	SET LOCK MODE TO WAIT 3;
	

BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            LET cod_ret = sql_err;
            RETURN cod_ret;
      END IF;
   END EXCEPTION;
   

    IF (NVL(pNumCte, 0) == 0) OR (pNumCte IS NULL) THEN		
        LET cod_ret = '00001';  -- El parametro de entrada no es valido
    ELSE
		SELECT COUNT (*) INTO cantidad FROM bdibpi:bpi_serviciobasico WHERE numcte = pNumCte;
	
			IF (cantidad>0) THEN
			
				UPDATE bdibpi:bpi_serviciobasico
				SET id_control = 2, id_entendimiento = 1, f_entendimiento = SYSDATE
				WHERE numcte = pNumCte;

				UPDATE bdinteg:si_bpiusuarios
				SET servicio = 2
				WHERE numcte = pNumCte;

				LET cod_ret = '00000';
			ELSE
				LET cod_ret = '00001';  -- No existe el cliente
			END IF;
    END IF;

    RETURN cod_ret;

END

END PROCEDURE;
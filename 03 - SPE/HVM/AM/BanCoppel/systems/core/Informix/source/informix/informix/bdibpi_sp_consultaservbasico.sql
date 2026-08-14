CREATE PROCEDURE "informix".sp_consultaservbasico(pNumCte char(9))
RETURNING char(5), char(5), date;
   
   -- CreaciÃ³n: Solser
   -- DescripciÃ³n: El sp realiza una bÃºsqueda del cliente en la tabla de control: bpi_serviciobasico, 
   -- y tomarÃ¡ el valor del campo idControl y f_ultimo_acceso, este valor serÃ¡ retornado por el sp
   -- SolicitÃ³: BanCoppel
   -- Fecha: 16/04/2020 
 
-- ***************************************************************************
-- DefiniciÃ³n de variables
-- ***************************************************************************
   DEFINE cod_ret char(5);
   DEFINE sql_err integer;
   DEFINE vIdControl char(20);
   DEFINE vFechaUltAcceso date;
   DEFINE cantidad integer;
-- ***************************************************************************
-- InicializaciÃ³n de variables
-- ***************************************************************************
   LET cod_ret = "00000";
   LET vIdControl = "";
   LET vFechaUltAcceso = null;

Set isolation to dirty read;
	SET LOCK MODE TO WAIT 3;
   
   
BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            LET cod_ret = sql_err;
            RETURN cod_ret, vIdControl, vFechaUltAcceso;
      END IF;
   END EXCEPTION;
   

    IF (NVL(pNumCte, 0) == 0) OR (pNumCte IS NULL) THEN		
        LET cod_ret = '00001';  -- El parametro de entrada no es valido
    ELSE
		SELECT COUNT (*) INTO cantidad FROM bdibpi:bpi_serviciobasico WHERE numcte = pNumCte;
		
		IF (cantidad>0) THEN
      		SELECT id_control, f_ultimo_acceso 
            INTO vIdControl, vFechaUltAcceso 
            FROM bdibpi:bpi_serviciobasico 
            WHERE numcte = pNumCte;
							
			LET cod_ret = '00000';
        ELSE
            LET cod_ret = '00001';  -- No existe el cliente
        END IF;
       
    END IF;

    RETURN cod_ret, vIdControl, vFechaUltAcceso;

END

END PROCEDURE;
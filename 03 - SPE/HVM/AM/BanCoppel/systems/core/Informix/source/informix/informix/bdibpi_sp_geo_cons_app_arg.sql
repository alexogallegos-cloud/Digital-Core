CREATE PROCEDURE "informix".sp_geo_cons_app_arg(  ) RETURNING CHAR(5) AS cod_ret;
--****************************************************************************************************
-- DESCRIPCION: Colocar trazado de geolocalizacion
-- AUTOR : AVF
-- FECHA : 14/12/2022 | 19/11/2024
-- BD: bdibpi 
--****************************************************************************************************

-- Definicion de variables
 
	DEFINE dFechaHoy	DATE;
	DEFINE dFechaAnt DATE; 
	
-- Variables para manejo de excepcion/resultado
    DEFINE sql_err INTEGER; 
    DEFINE cod_ret CHAR(5);
    DEFINE cod_res CHAR(5); 
	DEFINE xday INTEGER; 
 	
	LET cod_ret  = '00000'; 
	LET cod_res  = '00000';  
	LET xday = 0;
    --set debug file to "/ifxsif01/aw/out/sp_geo_cons_app.out";
    --Trace on;
	
BEGIN
    -- Manejo de excepcion
    ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            LET cod_ret = sql_err;
          RETURN cod_ret;
      END IF ;
	END EXCEPTION;
 
	
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	-- Se valida que la fecha concuerde con la dia actual	
	SELECT fecha_hoy INTO dFechaHoy 
	FROM bdicheq:sc_fechas WHERE empresa = '001';
	
	SELECT valor INTO xday
	FROM bpi_param WHERE id_param='31'; 
	
	LET dFechaHoy = dFechaHoy - xday UNITS DAY;
	LET xday = 1;
	LET dFechaAnt = dFechaHoy - xday UNITS DAY;
	
	
	EXECUTE PROCEDURE sp_geo_cons_app (dFechaHoy ) INTO cod_res;

	EXECUTE PROCEDURE sp_geo_cons_app (dFechaAnt ) INTO cod_res;
	
	LET dFechaAnt = dFechaAnt - xday UNITS DAY;
	EXECUTE PROCEDURE sp_geo_cons_app (dFechaAnt ) INTO cod_res;
 
RETURN cod_ret;
END;
END PROCEDURE;
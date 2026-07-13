CREATE PROCEDURE "informix".sp_geo_cons(  ) RETURNING CHAR(5) AS cod_ret;
--****************************************************************************************************
-- DESCRIPCION: Colocar trazado de geolocalizacion
-- AUTOR : AVF
-- FECHA : 14/12/2022
-- BD: bdibpi 
--****************************************************************************************************

-- Definicion de variables
 
	DEFINE dFechaHoy	DATE;
	DEFINE dFechaAnt DATE;
	DEFINE vFolio	CHAR(30);
	DEFINE vRef	CHAR(30);
	DEFINE vNumSerial CHAR(12);
	
	DEFINE nTransacc CHAR(4);
    DEFINE vid_operacion CHAR(4);
	DEFINE vLat CHAR(12);
	DEFINE vLong CHAR(12);
	DEFINE xday INTEGER; 
	
-- Variables para manejo de excepcion/resultado
    DEFINE sql_err INTEGER; 
    DEFINE cod_ret CHAR(5);
    DEFINE cod_res CHAR(5);
	LET cod_ret  = '00000'; 
	LET cod_res  = '00000'; 
	LET vRef = '';
    --set debug file to "/ifxsif01/aw/out/sp_geo_cons.out";
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
	LET xday = xday +1;
	LET dFechaAnt = dFechaHoy - xday UNITS DAY;
   
   
	--Inicia iteracion Portales
	FOREACH WITH HOLD
		SELECT  id_oper, id_tran INTO  vid_operacion, nTransacc
		FROM  bpi_cat_operaciones as cop  
		WHERE cve_geo = '1'
			
			--BPI
			FOREACH WITH HOLD
				SELECT folio, latitud, longitud  INTO  vfolio, vLat, vLong
				FROM  bdibpi:bpi_geolocalizacion as geo					
				WHERE geo.fecha_oper>= dFechaHoy 
				AND geo.id_operacion = vid_operacion
						
				IF vfolio <> '' THEN 
					EXECUTE PROCEDURE sp_locale_geo_cons (vfolio, vRef, vLat, vLong, nTransacc,'1') INTO cod_res;				
				END IF;
			
			CONTINUE FOREACH;	
			END FOREACH;		
			
			FOREACH WITH HOLD
				SELECT folio, latitud, longitud, version_a  INTO  vfolio, vLat, vLong, vNumSerial
				FROM  bdibpi:bpi_geolocalizacion as geo					
				WHERE geo.fecha_oper= dFechaAnt 
				AND geo.id_operacion = vid_operacion
						
				IF vNumSerial = '' THEN 
					EXECUTE PROCEDURE sp_locale_geo_cons (vfolio, vRef, vLat, vLong, nTransacc,'1') INTO cod_res;				
				END IF;
			
			CONTINUE FOREACH;	
			END FOREACH;	
			
			LET vfolio = '';
			
			FOREACH WITH HOLD
				SELECT  geo.referencia, geo.latitud, geo.longitud  INTO  vfolio, vLat, vLong				
				FROM  bdibei:bei_bitacora_geolocalizacion as geo  
				WHERE geo.fecha_hr_oper >= dFechaHoy
				AND geo.id_operacion =vid_operacion
				
				IF vfolio <> '' THEN 
					EXECUTE PROCEDURE sp_locale_geo_cons (vfolio, vRef, vLat, vLong, nTransacc, '2') INTO cod_res;
				END IF;
				
			CONTINUE FOREACH;	
			END FOREACH;			
			
			FOREACH WITH HOLD
				SELECT  geo.referencia, geo.latitud, geo.longitud, version_a  INTO  vfolio, vLat, vLong, vNumSerial				
				FROM  bdibei:bei_bitacora_geolocalizacion as geo  
				WHERE geo.fecha_hr_oper = dFechaAnt
				AND geo.id_operacion =vid_operacion
				
				IF vNumSerial = '' THEN 
					EXECUTE PROCEDURE sp_locale_geo_cons (vfolio, vRef, vLat, vLong, nTransacc, '2') INTO cod_res;
				END IF;
				
			CONTINUE FOREACH;	
			END FOREACH;		
			
		CONTINUE FOREACH;		
		END FOREACH;					
	--Termina  iteracion Portales		
	
	EXECUTE PROCEDURE sp_folio_ODP_geolocalizacion (dFechaHoy, '1134' , '3004', '5008') INTO cod_res;
					
RETURN cod_ret;
END;
END PROCEDURE;
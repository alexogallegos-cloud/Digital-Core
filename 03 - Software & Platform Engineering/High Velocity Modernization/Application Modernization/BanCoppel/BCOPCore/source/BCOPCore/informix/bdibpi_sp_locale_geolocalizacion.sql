CREATE PROCEDURE "informix".sp_locale_geolocalizacion(pFolio CHAR(30), pLat CHAR(12), pLong CHAR(12) ) RETURNING CHAR(5) AS cod_ret;
--****************************************************************************************************
-- DESCRIPCION: Generar trazado de geolocalizacion -> canal APP Movil
-- AUTOR : AVF
-- FECHA : 15/05/2023
-- BD: bdibpi
--****************************************************************************************************

-- Definicion de variables
	DEFINE lat0		CHAR(12);
	DEFINE lon0		CHAR(12);
	DEFINE alfa_lat	CHAR(12);
	DEFINE beta_lat	CHAR(12);
	DEFINE gamma_lat	CHAR(12);
	DEFINE alfa_lon	CHAR(12);
    DEFINE cod_res	CHAR(5);
	DEFINE geodata	CHAR(60);

-- Variables para manejo de excepcion/resultado
    DEFINE sql_err INTEGER;
    DEFINE cod_ret CHAR(5);
	LET cod_ret  = '00000';
	LET geodata  = '000,000,00,00000,XX'; 
	
    --set debug file to "/ifxsif01/aw/out/sp_locale_geolocalizacion.out";
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

	IF pFolio IS NULL OR pFolio ='' THEN
		LET cod_ret  = '00009';
		RETURN cod_ret;
	END IF;
 
	--Opcion A
	LET alfa_lat = SUBSTR(pLat,1,5);
	LET alfa_lon = SUBSTR(pLong,1,5);
	--Opcion B
	LET beta_lat = SUBSTR(pLat,1,7);
	--Opcion C
	LET gamma_lat = SUBSTR(pLat,1,9);
	--Opcion 0
	LET  lat0 = alfa_lat||'%';
	LET  lon0 = alfa_lon||'%';
	
	LET cod_ret  = '00002';
	
	EXECUTE PROCEDURE sp_locale_data_geo(pLat, pLong, alfa_lat,alfa_lon, '1') INTO cod_res,geodata; 

	
	/*IF geodata = '' THEN --CODIGO ORIGINAL
		EXECUTE PROCEDURE sp_locale_data_geo(pLat, pLong, beta_lat, '', '2') INTO cod_res,geodata; 
	END IF;
	
	IF geodata = '' THEN
		EXECUTE PROCEDURE sp_locale_data_geo(pLat, pLong, gamma_lat, '', '2') INTO cod_res,geodata; 
	END IF;
	
	IF geodata = '' THEN
		EXECUTE PROCEDURE sp_locale_data_geo(pLat, pLong, alfa_lat, '', '2') INTO cod_res,geodata; 
	END IF;
	
	IF geodata = '' THEN
		EXECUTE PROCEDURE sp_locale_data_geo(pLat, pLong, lat0, lon0, '1') INTO cod_res,geodata; 
	END IF;
	
	IF geodata = '' THEN
		--Inicia iteracion USA
		EXECUTE PROCEDURE sp_locale_data_geo(pLat, pLong, '','', '3') INTO cod_res,geodata; 
	END IF;*/  --CODIGO ORIGINAL
	
	IF geodata = '' THEN  --STK 202401
		
		EXECUTE PROCEDURE sp_locale_data_geo(pLat, pLong, beta_lat, '', '2') INTO cod_res,geodata; --STK 202401
		
		IF geodata = '' THEN	--STK 202401
		
			EXECUTE PROCEDURE sp_locale_data_geo(pLat, pLong, gamma_lat, '', '2') INTO cod_res,geodata;	--STK 202401 
		
			IF geodata = '' THEN	--STK 202401
				
				EXECUTE PROCEDURE sp_locale_data_geo(pLat, pLong, alfa_lat, '', '2') INTO cod_res,geodata; 	--STK 202401
				
				IF geodata = '' THEN	--STK 202401
				
					EXECUTE PROCEDURE sp_locale_data_geo(pLat, pLong, lat0, lon0, '1') INTO cod_res,geodata;	--STK 202401 
					
						IF geodata = '' THEN	--STK 202401
						
						--Inicia iteracion USA
						EXECUTE PROCEDURE sp_locale_data_geo(pLat, pLong, '','', '3') INTO cod_res,geodata; 	--STK 202401
					
					END IF;	--STK 202401
				
				END IF;	--STK 202401
			
			END IF;	--STK 202401
					
	
		END IF;	--STK 202401
		
	END IF;	--STK 202401
	
	IF geodata <> '' THEN
		UPDATE bdibpi:bi_geolocalizacion SET referencia_23 = geodata, folio_suc = pFolio WHERE folio = pFolio;
		LET cod_ret  = '00000';
	END IF;

RETURN cod_ret;
END;
END PROCEDURE;
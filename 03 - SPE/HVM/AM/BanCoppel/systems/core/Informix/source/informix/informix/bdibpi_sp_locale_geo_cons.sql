CREATE PROCEDURE "informix".sp_locale_geo_cons(pFolio CHAR(30), pRef CHAR(30),  pLat CHAR(12), pLong CHAR(12), pTransacc CHAR (4), pTipo CHAR (1)  ) RETURNING CHAR(5) AS cod_ret;
--****************************************************************************************************
-- DESCRIPCION: Generar trazado de geolocalizacion
-- AUTOR : AVF
-- FECHA : 21/08/2023
-- BD: bdibpi
--****************************************************************************************************
-- FECHA : 01/11/2023
-- Actualizacio
--****************************************************************************************************
-- Definicion de variables
	DEFINE distance INTEGER;
	DEFINE idEnt INTEGER;
	DEFINE delta_lat FLOAT;
	DEFINE delta_lng FLOAT;
	DEFINE lat0 CHAR(12);
	DEFINE lon0 CHAR(12);
	DEFINE alfa_lat CHAR(12);
	DEFINE beta_lat CHAR(12);
	DEFINE gamma_lat CHAR(12);
	DEFINE alfa_lon CHAR(12);

	DEFINE	geodata	CHAR(60);
	DEFINE	pFolio_suc	CHAR(30);
	DEFINE	xFolio	CHAR(30);
	DEFINE xCveGeo CHAR(1);
	DEFINE vTransacc CHAR(4);	
	DEFINE vSuc CHAR(4);
	DEFINE vNumserial CHAR(10); 


-- Variables para manejo de excepcion/resultado
    DEFINE sql_err INTEGER;
    DEFINE cod_ret CHAR(5);
    DEFINE cod_res	CHAR(5);
	LET cod_ret  = '00000';
	LET geodata  = '000,000,00,00000,XX';
	
   -- set debug file to "/ifxsif01/aw/out/sp_locale_geo_cons.out";
   -- Trace on;

BEGIN
    -- Manejo de excepcion
    ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            LET cod_ret = sql_err;
          RETURN cod_ret;
      END IF ;
	END EXCEPTION;

	
	IF pFolio IS NULL OR pFolio ='' OR pTipo='' THEN
		LET cod_ret  = '00009';
		RETURN cod_ret;
	END IF;


    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	--Opcion A
	LET alfa_lat = SUBSTR(pLat,1,5);
	LET alfa_lon = SUBSTR(pLong,1,5);
	--Opcion B
	LET beta_lat = SUBSTR(pLat,1,7);
	--Opcion C
	LET gamma_lat = SUBSTR(pLat,1,9);
	
	LET cod_ret  = '00002';

	LET pFolio_suc = '';
	LET xCveGeo = '0';

		IF pTipo='2' AND pTransacc='0274' THEN
			--SELECT FIRST 1 folio_suc INTO pFolio FROM bdicheq:sc_movdia as mov WHERE mov.empresa = '001' AND mov.sucursal = '5008' AND mov.referencia = pRef;

			FOREACH WITH HOLD
				SELECT chrfolioprom 
				INTO xFolio
				FROM bdispei:tblpago 
				WHERE vchrclaverastreo=pFolio
				
				IF xFolio<>'' THEN
					LET pFolio_suc=xFolio;
				END IF;	
			CONTINUE FOREACH;	
			END FOREACH;		
			
			IF (pFolio_suc = '') THEN
				FOREACH WITH HOLD
					SELECT chrfolioprom 
					INTO xFolio
					FROM bdispei:tblhistpago 
					WHERE vchrclaverastreo=pFolio
					
					IF xFolio<>'' THEN
						LET pFolio_suc=xFolio;
					END IF;	
				CONTINUE FOREACH;	
				END FOREACH;		
			END IF;
		ELSE
			LET pFolio_suc = pFolio;
		END IF;
		
		
	--Inicia busqueda de geolocalización
	EXECUTE PROCEDURE sp_locale_data_geo( pLat, pLong, alfa_lat,alfa_lon, '1') INTO cod_res,geodata; 
	
	IF geodata = '' THEN
		EXECUTE PROCEDURE sp_locale_data_geo( pLat, pLong, beta_lat, '', '2') INTO cod_res,geodata; 
	END IF;
	
	IF geodata = '' THEN
		EXECUTE PROCEDURE sp_locale_data_geo( pLat, pLong, gamma_lat, '', '2') INTO cod_res,geodata; 
	END IF;
	
	IF geodata = '' THEN
		EXECUTE PROCEDURE sp_locale_data_geo( pLat, pLong, alfa_lat, '', '2') INTO cod_res,geodata; 
	END IF;
	
	IF geodata = '' THEN
		--Inicia iteracion USA
		EXECUTE PROCEDURE sp_locale_data_geo( pLat, pLong, '','', '3') INTO cod_res,geodata; 
	END IF;
	
	IF geodata = '' THEN
		LET geodata  = '000,000,00,00000,XX';	
	END IF;
	
	
	
	IF pTipo='1' THEN
		UPDATE bdibpi:bpi_geolocalizacion SET  referencia_23 = geodata WHERE folio = pFolio;			
		IF pFolio_suc<>'' THEN
			LET xCveGeo = '1';
			UPDATE bdicheq:sc_movhis SET referencia_23 = geodata WHERE empresa='001' AND folio_suc = pFolio_suc; 
			
			FOREACH WITH HOLD
				SELECT  folio_suc,  num_serial, transacc, sucursal
				INTO  xFolio, vNumserial, vTransacc, vSuc
				FROM  bdicheq:sc_movhis as mov  			
				WHERE  empresa='001' AND folio_suc=pFolio_suc
				
				
				IF (xFolio <> '' AND vTransacc = pTransacc) THEN 								
					UPDATE bdibpi:bpi_geolocalizacion SET cve_geo=xCveGeo, version_a =  vNumserial WHERE folio = pFolio_suc;
				ELSE 
					UPDATE bdibpi:bpi_geolocalizacion SET cve_geo=xCveGeo, version_b =  vNumserial  WHERE folio = pFolio_suc;
				END IF;	
			
			CONTINUE FOREACH;	
			END FOREACH;
		END IF;
	END IF;
	
	IF pTipo='2' THEN
		UPDATE bdibei:bei_bitacora_geolocalizacion SET cve_geo=xCveGeo, referencia_23 = geodata WHERE referencia = pFolio;			
		IF pFolio_suc<>'' THEN
			LET xCveGeo = '1';
			UPDATE bdicheq:sc_movhis SET referencia_23 = geodata WHERE empresa='001' AND folio_suc = pFolio_suc; 
			
			FOREACH WITH HOLD
				SELECT  folio_suc,  num_serial, transacc, sucursal
				INTO  xFolio, vNumserial, vTransacc, vSuc
				FROM  bdicheq:sc_movhis as mov  			
				WHERE  empresa='001' AND folio_suc=pFolio_suc
				
				
				IF (xFolio <> '' AND vTransacc = pTransacc) THEN 								
					UPDATE bdibei:bei_bitacora_geolocalizacion SET cve_geo=xCveGeo, version_a =  vNumserial WHERE referencia = pFolio;
				ELSE 
					UPDATE bdibei:bei_bitacora_geolocalizacion SET cve_geo=xCveGeo, version_b =  vNumserial  WHERE referencia = pFolio;
				END IF;	
			
			CONTINUE FOREACH;	
			END FOREACH;
		END IF;
	
	END IF;

	LET cod_ret  = '00000';

RETURN cod_ret;
END;
END PROCEDURE;
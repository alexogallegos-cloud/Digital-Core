CREATE PROCEDURE "informix".sp_depura_geo_cons_app(  ) RETURNING CHAR(5) AS cod_ret;
--****************************************************************************************************
-- DESCRIPCION: Depura trazado de geolocalizacion
-- AUTOR : AVF
-- FECHA : 14/12/2022
-- FECHA ACTUALIZACION: 28/10/2024 | Depurar registros con ID distintos al catalogo par a geolocalización
-- BD: bdibpi 
--****************************************************************************************************

-- Definicion de variables
 
	DEFINE dFechaHoy	DATE;
	DEFINE vFolio	CHAR(30);
	DEFINE vRef	CHAR(30);
	
-- Variables para manejo de excepcion/resultado
    DEFINE sql_err INTEGER; 
    DEFINE cod_ret CHAR(5);
    DEFINE cod_res CHAR(5);
    DEFINE vid_operacion CHAR(4);
	DEFINE vLat CHAR(12);
	DEFINE vLong CHAR(12);
	
	DEFINE vcomienza CHAR(1);
	DEFINE xday INTEGER; 
	DEFINE vreg INTEGER; 
	
	LET cod_ret  = '00000'; 
	LET cod_res  = '00000'; 
	LET vRef = '';
	LET vid_operacion = '';
	LET vcomienza   = '0';
	LET xday = 0;
	LET vreg = 0;
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
	FROM bpi_param WHERE id_param='32';
	
	LET dFechaHoy = dFechaHoy - xday UNITS DAY;
			
	--Inicia iteracion A-APP
		FOREACH WITH HOLD
			SELECT  id_oper INTO  vid_operacion
			FROM  bpi_cat_operaciones as cop  
			WHERE cve_geo = '1'
		
			FOREACH WITH HOLD
				SELECT folio   INTO  vfolio
				FROM  bdibpi:bi_geolocalizacion as geo					
				WHERE geo.fecha_oper = dFechaHoy  
				AND geo.id_operacion = vid_operacion
										
				IF vcomienza <> "1" THEN
					BEGIN WORK;
					LET vcomienza = "1";
				END IF;
				
				LET vreg = vreg + 1;
				DELETE FROM  bi_geolocalizacion as geo  					
				WHERE  geo.folio= vfolio
				;
				
				IF (vreg>= 1000) THEN
					COMMIT WORK;				
					LET vcomienza = "0";			
					LET vreg = 0;
				END IF;		
			
			CONTINUE FOREACH;	
			END FOREACH;			
				
			
		END FOREACH;					
	--Termina  iteracion A-APP
		IF (vcomienza = "1") THEN
			COMMIT WORK;
		END IF;
	-- Depurar todos los registros
	LET vcomienza = "0";			
	LET vreg = 0;

	FOREACH WITH HOLD
		SELECT folio   INTO  vfolio
		FROM  bdibpi:bi_geolocalizacion as geo					
		WHERE geo.fecha_oper <= dFechaHoy  
		AND geo.id_operacion <>''
								
		IF vcomienza <> "1" THEN
			BEGIN WORK;
			LET vcomienza = "1";
		END IF;
		
			LET vreg = vreg + 1;
			DELETE FROM  bi_geolocalizacion as geo  					
			WHERE  geo.folio= vfolio
			;
		IF (vreg>= 1000) THEN
			COMMIT WORK;				
			LET vcomienza = "0";			
			LET vreg = 0;
		END IF;		
	
	CONTINUE FOREACH;	
	END FOREACH;			
		
	--Termina  iteracion A-Todos
		IF (vcomienza = "1") THEN
			COMMIT WORK;
		END IF;
		
		
RETURN cod_ret;
END;
END PROCEDURE;
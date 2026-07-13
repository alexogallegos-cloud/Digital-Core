CREATE PROCEDURE "informix".sp_geo_cons_app_jv( pFecha DATE ) RETURNING CHAR(5) AS cod_ret;
--****************************************************************************************************
-- DESCRIPCION: Colocar trazado de geolocalizacion
-- AUTOR : AVF
-- FECHA : 14/12/2022 | 19/11/2024
-- BD: bdibpi 
--****************************************************************************************************

-- Definicion de variables
 
	DEFINE dFechaHoy		DATE;
	DEFINE vFolio			CHAR(30);
	DEFINE xfolio			CHAR(30);
	DEFINE xNumserial		CHAR(12);
	DEFINE vRef				CHAR(30);
	DEFINE vRef23			CHAR(23);
	
-- Variables para manejo de excepcion/resultado
    DEFINE sql_err 			INTEGER; 
    DEFINE cod_ret 			CHAR(5);
    DEFINE cod_res 			CHAR(5);
	DEFINE nTransacc        CHAR(4);
    DEFINE vid_operacion    CHAR(4);
	DEFINE vLat             CHAR(12);
	DEFINE vLong            CHAR(12);
	DEFINE vFlagFolio       CHAR(1);
	DEFINE xday             INTEGER; 
	DEFINE vcomienza        CHAR(1); 
	DEFINE vreg             INTEGER; 

	LET dFechaHoy   		= '';	
	LET vFolio			    = '';	
	LET xfolio 				= '';
	LET xNumserial 			= '';	
	LET vRef 				= '';	
	LET vRef23 				= '';	
    LET sql_err  			= 0; 
	LET cod_ret  			= '00000'; 
	LET cod_res  			= '00000'; 
 	LET nTransacc   		= '';
	LET vid_operacion 		= '';
	LET vLat             	= '';
	LET vLong            	= '';
	LET vFlagFolio       	= '';
 	LET xday 				= 0;	
	LET vcomienza   		= '0'; 
	LET vreg 				= 0;
    --set debug file to "/ifxsif01/aw/out/sp_geo_cons_app_JV.out";
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
	
	IF(pFecha ="") THEN
		RETURN cod_ret;
	END IF;
	
	SELECT valor INTO vFlagFolio
	FROM bpi_param WHERE id_param='35';								
	LET dFechaHoy = pFecha;
   
		FOREACH WITH HOLD
			SELECT   geo.folio, geo.folio_suc, latitud, longitud, version, referencia_23, cop.id_tran
				INTO  vRef, vfolio, vLat, vLong, xNumserial, vRef23, nTransacc
			FROM  bpi_cat_operaciones as cop 
				INNER JOIN bi_geolocalizacion as geo 
			ON geo.id_operacion = cop.id_oper
				WHERE cve_geo = '1' AND geo.fecha_oper = dFechaHoy
							
							
							
							
			IF vcomienza <> "1" THEN
				BEGIN WORK;
				LET vcomienza = "1";
			END IF;
			
			IF vfolio = '' AND vRef23 = '' THEN 
				EXECUTE PROCEDURE sp_locale_geolocalizacion (vRef, vLat, vLong ) INTO cod_res;
				LET vreg = vreg + 1;
			END IF;
			IF vFlagFolio='1' AND ( xNumserial='0' OR  xNumserial='' )THEN
				EXECUTE PROCEDURE "informix".sp_folio_geolocalizacion (vRef, nTransacc) INTO cod_res;
				LET vreg = vreg + 1;
			END IF;	
			
			IF (vreg>= 1000) THEN
				COMMIT WORK;				
				LET vcomienza = "0";			
				LET vreg = 0;
			END IF;		
		
		
		CONTINUE FOREACH;		
		END FOREACH;			

		IF (vcomienza = "1") THEN
			COMMIT WORK;
		END IF;
RETURN cod_ret;
END;
END PROCEDURE;
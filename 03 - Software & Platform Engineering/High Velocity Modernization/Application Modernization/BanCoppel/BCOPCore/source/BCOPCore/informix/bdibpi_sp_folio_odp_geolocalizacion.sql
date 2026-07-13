CREATE PROCEDURE "informix".sp_folio_odp_geolocalizacion(pFecha DATE, pTransacc CHAR(4), pIdOper CHAR(4) , pSuc CHAR(4) ) RETURNING CHAR(5) AS cod_ret;
--****************************************************************************************************
-- DESCRIPCION: Generar trazado de folio de la operacion en la identificacion de geolocalizacion -> canal Banca por Internet
-- AUTOR : AVF
-- FECHA : 17/11/2023
-- BD: bdibpi
--****************************************************************************************************

-- Definicion de variables
    DEFINE cod_res	CHAR(5);
	DEFINE vFolio_suc	CHAR(30); 	 
	DEFINE vFolio	CHAR(30); 	
	
	
-- Variables para manejo de excepcion/resultado
    DEFINE sql_err INTEGER;
    DEFINE cod_ret CHAR(5);
	DEFINE vcomienza CHAR(1);
	DEFINE vreg INTEGER; 
	
	DEFINE	geodata	CHAR(60);
	DEFINE	xGeodata	CHAR(60);
	DEFINE vreferencia_23 CHAR(23);
	DEFINE	vFile	CHAR(11);
	DEFINE	vNomFile CHAR(11);
	DEFINE	vCta	CHAR(12);
	DEFINE	vcte	CHAR(12);
	DEFINE  vOper CHAR(4);
	DEFINE  trasacc CHAR(4);
	
	DEFINE vFecha90	DATE;
	DEFINE vFch	DATE;

	LET vcomienza   = '0';
	LET vreg = 0;
	
	LET cod_ret  = '00000';
	LET vFolio_suc  = ''; 
	
    --set debug file to "/ifxsif01/aw/out/sp_folio_ODP_geolocalizacion.out";
    --Trace on;
	
BEGIN
    -- Manejo de excepcion
    ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            LET cod_ret = sql_err;
          RETURN cod_ret;
      END IF ;
	END EXCEPTION;


	IF pTransacc IS NULL OR pTransacc ='' OR
		pIdOper IS NULL OR pIdOper ='' OR
		pSuc IS NULL OR pSuc ='' OR
		pFecha IS NULL
	THEN
		LET cod_ret  = '00009';
		RETURN cod_ret;
	END IF;
 

   SET ISOLATION TO DIRTY READ;
   SET LOCK MODE TO WAIT 3; 
   
   LET vFecha90 = pFecha - 90 UNITS DAY;
   
		--Inicia iteracion Portales
	FOREACH WITH HOLD
		SELECT folio_suc, cuenta, referencia_23 INTO  vFolio_suc, vCta, vreferencia_23
		FROM bdicheq:sc_movhis  
		WHERE sucursal=pSuc
		AND fech_alt>=pFecha
		AND transacc ='1134'
		AND cancelad<> 'S'
		 
		
		IF (vreferencia_23 = '') THEN
			FOREACH WITH HOLD
				SELECT  num_cliente, tipo_dispersion, archivo, fecha INTO vcte, vOper, vNomFile, vFch
				FROM bdibei:bei_dispersiones_odp 
				WHERE num_referencia=vFolio_suc
				AND archivo is not null
				AND cta_origen=vCta
				
				LET xGeodata = '';
				LET trasacc = '0';
				
				FOREACH WITH HOLD	
					SELECT cgenerico1, cgenerico2, referencia_23 INTO vfolio, vFile , geodata
					FROM bdibei:bei_bitacora_historial bta
					INNER JOIN bdibei:bei_bitacora_geolocalizacion geo ON (bta.cgenerico1 = geo.referencia AND bta.id_operacion = geo.id_operacion AND bta.id_usuario=geo.id_usuario)
					WHERE (bta.fecha_oper >= vFch
					AND bta.id_operacion =vOper )
					AND bta.cuenta_origen = vCta
										
					IF (vfolio = vFolio_suc AND geodata<>'') THEN
						LET trasacc = '1';
						EXIT FOREACH;		
					END IF;		
					
					IF (vFile = vNomFile AND geodata<>'' ) THEN
						LET xGeodata= geodata; 
					END IF;		
					
					CONTINUE FOREACH;		
				END FOREACH;
				
				IF trasacc = '1' THEN
					LET xGeodata= geodata; 				
				END IF;
				
				IF xGeodata <> '' THEN
					
					IF vcomienza <> "1" THEN
							BEGIN WORK;
							LET vcomienza = "1";
						END IF;
						
						UPDATE bdicheq:sc_movhis SET referencia_23 = xGeodata WHERE folio_suc = vFolio_suc;
				
						IF (vreg>= 10) THEN
							COMMIT WORK;				
							LET vcomienza = "0";			
							LET vreg = 0;
					END IF;
				END IF;
				CONTINUE FOREACH;		
			END FOREACH;		
		END IF;
		CONTINUE FOREACH;	
	END FOREACH;

	IF (vcomienza = "1") THEN
			COMMIT WORK;
		END IF;


	--Inicia iteracion Portales
	FOREACH WITH HOLD
		SELECT  folio_suc, cuenta, referencia_23 INTO  vFolio_suc, vCta, vreferencia_23
		FROM bdicheq:sc_movhis  
		WHERE
		sucursal=pSuc
		AND fech_alt>=pFecha
		AND transacc ='0272' 
		AND cancelad<> 'S' 
		
		IF (vreferencia_23 = '') THEN
			 				
				FOREACH WITH HOLD	
					SELECT cgenerico1, cgenerico2, referencia_23 INTO vfolio, vFile , geodata
					FROM bdibei:bei_bitacora_historial bta
					INNER JOIN bdibei:bei_bitacora_geolocalizacion geo ON (bta.cgenerico1 = geo.referencia AND bta.id_operacion = geo.id_operacion AND bta.num_cliente=geo.num_cliente)
					WHERE bta.id_operacion ='3007'   
					AND bta.cuenta_origen = vCta
					AND bta.fecha_oper >= vFch
										
					IF (vfolio = vFolio_suc AND geodata<>'') THEN
						LET trasacc = '1';
						EXIT FOREACH;		
					END IF;		
									
					CONTINUE FOREACH;		
				END FOREACH;
				
				IF geodata <> '' THEN					
					IF vcomienza <> "1" THEN
							BEGIN WORK;
							LET vcomienza = "1";
					END IF;
						
						UPDATE bdicheq:sc_movhis SET referencia_23 = geodata WHERE folio_suc = vFolio_suc;
				
					IF (vreg>= 10) THEN
							COMMIT WORK;				
							LET vcomienza = "0";			
							LET vreg = 0;
					END IF; 		
			 	END IF; 	
		END IF;
		CONTINUE FOREACH;			
	END FOREACH;

	IF (vcomienza = "1") THEN
			COMMIT WORK;
		END IF;

	RETURN cod_ret;
	
	
END;
END PROCEDURE;
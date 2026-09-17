CREATE PROCEDURE "informix".sp_folio_geolocalizacion(pFolio CHAR(30), pTransacc CHAR(4) ) RETURNING CHAR(5) AS cod_ret;
--****************************************************************************************************
-- DESCRIPCION: Generar trazado de folio de la operacion en la identificacion de geolocalizacion -> canal APP Movil
-- AUTOR : AVF
-- FECHA : 31/07/2023
-- Ultima edicion LDEM 
-- Fecha edicion 01/04/2026
-- Se cambia la tabla Movdia por la sc_movdia_concil de bdicheq
-- BD: bdibpi
--****************************************************************************************************

-- Definicion de variables
    DEFINE cod_res	CHAR(5);
	DEFINE vFolio_suc	CHAR(30);
	DEFINE xFolio	CHAR(30);	
	DEFINE vTransacc CHAR(4);	
	DEFINE vSuc CHAR(4);
	DEFINE vNumserial CHAR(10); 
	
-- Variables para manejo de excepcion/resultado
    DEFINE sql_err INTEGER;
    DEFINE cod_ret CHAR(5);
	
	LET cod_ret  = '00000';
	LET vFolio_suc  = ''; 
	LET xFolio  = ''; 
	LET vTransacc='';
	LET vNumserial=''; 
	LET vSuc='';
    --set debug file to "/ifxsif01/aw/out/sp_folio_geolocalizacion.out";
    --Trace on;
	
BEGIN
    -- Manejo de excepcion
    ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            LET cod_ret = sql_err;
          RETURN cod_ret;
      END IF ;
	END EXCEPTION;


	IF pFolio IS NULL OR pFolio ='' THEN
		LET cod_ret  = '00009';
		RETURN cod_ret;
	END IF;
 

   SET ISOLATION TO DIRTY READ;
   SET LOCK MODE TO WAIT 3; 
   
	--Opcion A 	
	LET vFolio_suc=pFolio;
	--Opcion B
	IF (pTransacc ='0274' OR pTransacc ='0447') THEN 
		
		LET vFolio_suc='';
		
		FOREACH WITH HOLD
			SELECT chrfolioprom 
			INTO xFolio
			FROM bdispei:tblpago 
			WHERE vchrclaverastreo=pFolio
			
			IF xFolio<>'' THEN
				LET vFolio_suc=xFolio;
			END IF;	
		CONTINUE FOREACH;	
		END FOREACH;		
		IF (vFolio_suc='') THEN
			FOREACH WITH HOLD
				SELECT chrfolioprom 
				INTO xFolio
				FROM bdispei:tblhistpago 
				WHERE vchrclaverastreo=pFolio
				
				IF xFolio<>'' THEN
					LET vFolio_suc=xFolio;
				END IF;	
			CONTINUE FOREACH;	
			END FOREACH;		
		END IF;
		
	END IF;
	 
	IF vFolio_suc IS NULL OR vFolio_suc ='' THEN
		LET cod_ret  = '00002';
		RETURN cod_ret;
	END IF;
	
		
 	
	FOREACH WITH HOLD
		SELECT  folio_suc,  num_serial, transacc, sucursal
		INTO  xFolio, vNumserial, vTransacc, vSuc
		FROM  bdicheq:sc_movdia_concil as mov  		-- se cambia bdicheq:sc_movhis por bdicheq:sc_movdia_concil
		WHERE  folio_suc=vFolio_suc
		
		IF (xFolio <> '' AND vTransacc = pTransacc AND vSuc='5011') THEN 			
			UPDATE bdibpi:bi_geolocalizacion SET version =  vNumserial, folio_suc = xFolio  WHERE folio = pFolio;
		ELSE 
			UPDATE bdibpi:bi_geolocalizacion SET version_b =  vNumserial  WHERE folio = pFolio;
		END IF;	
	
	CONTINUE FOREACH;	
	END FOREACH;
				
	IF vNumserial <> '' THEN		
		LET cod_ret  = '00000';
	END IF;

RETURN cod_ret;
END;
END PROCEDURE;
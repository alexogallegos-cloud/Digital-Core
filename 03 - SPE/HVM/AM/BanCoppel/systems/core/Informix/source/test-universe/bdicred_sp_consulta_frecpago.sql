CREATE PROCEDURE "informix".sp_consulta_frecpago(pValor CHAR(2), pTipo_pago VARCHAR(20),pNum_producto CHAR(4),pTipoEjecucion CHAR(1))

RETURNING CHAR(5) AS CodRet,
          CHAR(2) AS Valor,
		  VARCHAR(20) AS TipoPago;
    
DEFINE cCodRet CHAR(5);
DEFINE cValor  CHAR(2);
DEFINE cTipoPago VARCHAR(15);
DEFINE vNum_producto CHAR(4);
DEFINE iSqlErr  INTEGER;

LET cCodRet = '00000';
LET cValor = '';
LET cTipoPago = '';
LET vNum_producto = '';
LET iSqlErr = 0;
    
	BEGIN
		-- // MANEJO DE EXCEPCIONES   
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet,cValor,cTipoPago;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO "/ifxsif01/home/e_efierro/sp_consulta_frecpago.out";
		--TRACE ON;
	
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pTipoEjecucion = '1' THEN--Consulta Catalogo
			FOREACH
				SELECT valor,tipo_pago
				INTO cValor,cTipoPago
				FROM "informix".sd_cattipopago
			
				RETURN cCodRet, cValor,cTipoPago WITH RESUME;
			END FOREACH;
		
		ELIF pTipoEjecucion = '2' THEN --Guarda los valores seleccionados por el usuario de las frecuencias de pago 
			IF (pValor = '' AND pTipo_pago = '' AND pNum_producto = '') THEN
				LET cCodRet = '00001';
				ELSE
					SELECT COUNT (num_producto) 
					INTO vNum_producto
					FROM tmp_sd_frectipopago;
				
					IF vNum_producto >= 1 THEN
					
						IF vNum_producto <> pNum_producto THEN
							SELECT LIMIT 1 num_producto
							INTO pNum_producto
							FROM tmp_sd_frectipopago;
							--Se eliminan los registros que se crearon para obtener subproducto
							DELETE FROM tmp_sd_frectipopago
							WHERE num_producto = pNum_producto AND valor = 0;
						END IF;
					END IF;
				
					INSERT INTO "informix".tmp_sd_frectipopago(valor, tipo_pago, num_producto)
					VALUES(pValor, pTipo_pago, pNum_producto);
			END IF;
			RETURN cCodRet, TRIM(cValor), TRIM(cTipoPago);
		ELIF pTipoEjecucion = '3' THEN --Elima Opciones seleccionadas 
			DELETE FROM tmp_sd_frectipopago
			WHERE num_producto = pNum_producto AND valor = pValor;
					
			RETURN cCodRet, cValor,cTipoPago;
			
		ELIF pTipoEjecucion = '4' THEN --Consulta los valores asignados por usuario previamente registrados
			SELECT COUNT (num_producto) 
			INTO vNum_producto
			FROM tmp_sd_frectipopago;
			
			IF vNum_producto >= 1 THEN
				SELECT LIMIT 1 num_producto
				INTO pNum_producto
				FROM tmp_sd_frectipopago;
			END IF;
			
			FOREACH
				SELECT valor,tipo_pago
				INTO cValor,cTipoPago
				FROM "informix".sd_frectipopago
				WHERE num_producto = pNum_producto
				ORDER BY valor
			
				RETURN cCodRet, cValor,cTipoPago WITH RESUME;
			END FOREACH;
			
			IF DBINFO("sqlca.sqlerrd2") = 0 THEN
				LET cCodRet= '00002';  --No hay informacion
			RETURN cCodRet, TRIM(cValor), TRIM(cTipoPago);
			END IF;
		END IF;
	END
END PROCEDURE;
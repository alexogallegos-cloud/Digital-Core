CREATE PROCEDURE "informix".sp_tokenizacion_cardoperation(pissuer_id CHAR(10), pcard_id CHAR(48), px_correlation_id CHAR(64), p_operationid CHAR(64),
															p_operation  CHAR(10), pdigitalcard_ids LVARCHAR, pstatus CHAR(11))
	RETURNING  CHAR(5) AS codretorno,  CHAR(150) AS descodretorno ;
	
--Definicion de Variables
DEFINE isqlerr 	   					INTEGER;
DEFINE codigoRetorno    			CHAR (5);
DEFINE desCodRetorno 				CHAR (120);
DEFINE outNumTarjeta				CHAR(19);
DEFINE outIdEstatus					INTEGER;
DEFINE outNumTarjetaTokenizada		CHAR(19);
DEFINE outProces 					CHAR(10);
DEFINE outStatus					INTEGER;
DEFINE inFechaToken 				DATETIME YEAR TO FRACTION;
DEFINE inTokenizada					CHAR(1);

--Inicializacion de Variables
LET isqlerr 						= 0;
LET codigoRetorno 					= '00000';
LET desCodRetorno 					= 'Consulta Exitosa.';
LET outNumTarjeta					= '';
LET outNumTarjetaTokenizada			= '';
LET outProces 						= '';
LET outStatus						= 0;
LET inFechaToken					= NULL;
LET inTokenizada 					= '0';


	BEGIN
		
		ON EXCEPTION SET isqlerr
			IF isqlerr <> 0 THEN		
				LET codigoRetorno = isqlerr;
				LET desCodRetorno = 'Error No Controlado al invocar SP sp_tokenizacion_consultatarjeta. Validar.';
			END IF;
			RETURN codigoRetorno, desCodRetorno;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 10;
		
		
		--SET DEBUG FILE TO '/home/c90313380/sp_tokenizacion_cardoperation.log';
	    --TRACE ON;	
		
	--Obtiene numero de tarjeta con el card_id	
		SELECT numtarjeta
			INTO outNumTarjeta
		FROM tokenizacion_cardid 
			WHERE card_id = pcard_id;
			
		IF outNumTarjeta IS NULL OR outNumTarjeta = '' THEN
			LET codigoRetorno = '00400';
			LET desCodRetorno =  'No se encontro numero de tarjeta con card_id';
			RETURN codigoRetorno, desCodRetorno;
		END IF
		
	--Obtiene id_estatus
		SELECT id_estatus 
			INTO outIdEstatus
		FROM "informix".tarjeta_estatus_tokenizacion 
			WHERE estatus = pstatus;
			
		IF outIdEstatus IS NULL OR outIdEstatus = '' THEN
			LET codigoRetorno = '00400';
			LET desCodRetorno =  'No se encontro id de estatus';
			RETURN codigoRetorno, desCodRetorno;
		END IF

	--Busca en tarjeta tokenizadas
		SELECT numtarjeta, operacion, status 
			INTO outNumTarjetaTokenizada, outProces , outStatus
		FROM tarjetas_tokenizadas
			WHERE numtarjeta = outNumTarjeta;
			
		IF outNumTarjetaTokenizada IS NULL OR outNumTarjetaTokenizada = ' ' THEN
			IF pstatus = 'FAILED' OR pstatus = 'PENDING' THEN		
				LET	inTokenizada = '0';
				
			ELIF pstatus = 'SUCCESSFUL' THEN	
				LET	inTokenizada = '1';
				LET	inFechaToken = CURRENT;					
			END IF
			
			INSERT INTO tarjetas_tokenizadas(numtarjeta, operacion, status, tokenizada, fecha_tokenizacion, fecha_del_token, fecha_susp_token, fecha_insert) 
			VALUES(outNumTarjeta,p_operation, outIdEstatus, inTokenizada, CURRENT, inFechaToken, NULL, CURRENT );
		ELSE
			IF pstatus = 'SUCCESSFUL' THEN
				LET	inTokenizada = '1';
				LET	inFechaToken = CURRENT;	
			END IF
			
			UPDATE tarjetas_tokenizadas 
				SET operacion = p_operation, 
					status = outIdEstatus,  
					tokenizada = inTokenizada,
					fecha_tokenizacion = inFechaToken
				WHERE numtarjeta = outNumTarjetaTokenizada;
		END IF
		
		INSERT INTO "informix".bitacora_token_cardoperation(issuer_id, card_id, x_correlation_id, operation_id, operation, digital_cardids, status, cod_retorno , des_codret, fecha_insert)
		VALUES(pissuer_id, pcard_id,  px_correlation_id, p_operationid, p_operation , pdigitalcard_ids, pstatus, codigoRetorno, desCodRetorno, CURRENT);
			
		RETURN codigoRetorno, desCodRetorno;
		
	END
END PROCEDURE;
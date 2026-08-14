CREATE PROCEDURE "informix".sp_tokenizacion_consultatarjeta(pissuer_id	CHAR(10), px_correlation_id	CHAR(64), pcard_id	CHAR(48), pcard_bin	CHAR(8), 
															ppan	CHAR(19), pexpiracion	CHAR(4), pname	VARCHAR(150), pcvv	CHAR(4))
															
RETURNING 	CHAR (5) AS codretorno , VARCHAR(100) AS descodRetorno,  CHAR(48) AS id_tarjeta,  CHAR(64) AS id_cliente, CHAR(64) AS id_cuenta, Boolean AS valido,
						 Boolean AS verificacionintentosexcedidos,  Boolean AS perdido,  Boolean AS expirado,  Boolean AS invalido,  Boolean AS posiblefraude;

--Definicion de Variables
DEFINE isqlerr 	   					INTEGER;
DEFINE codRetorno    				CHAR (5);
DEFINE desCodRetorno 				CHAR (120);
DEFINE mesFechActual    		    CHAR (2);
DEFINE anioFechActual    			CHAR (2);
DEFINE mesFechExp    		        CHAR (2);
DEFINE anioFechExp   			    CHAR (2);
DEFINE inNumTarjeta					CHAR (48);
DEFINE ccvv2						CHAR (01); -- No se hace nada
DEFINE outNumCliente				CHAR (09);
DEFINE outCodStatusTarjeta 			CHAR (20);
DEFINE binTarjeta					CHAR (06);
DEFINE rangoBinTarjeta				CHAR (02);
DEFINE outCuenta					CHAR (12);
DEFINE outCVVvalido					BOOLEAN;
DEFINE outStatus_perdido			BOOLEAN;
DEFINE outFechaExpirada 			BOOLEAN;
DEFINE outTarjetaInval				BOOLEAN;
DEFINE outCVVIntExcedido			BOOLEAN;
DEFINE outStatusFraude				BOOLEAN;
DEFINE binToken						INTEGER;
DEFINE outNumTarjeta				CHAR(19);
DEFINE outCardId					CHAR(48);
DEFINE inCard_ID					CHAR(48);
DEFINE outStatus					INTEGER;
DEFINE outFechaExpira 				CHAR(4);


	--SET DEBUG FILE TO '/home/c90313380/sp_tokenizacion_consultatarjeta.log';
	--TRACE ON;	

--Inicializacion de Variables
LET isqlerr 					= 0;
LET codRetorno 					= '00000';
LET desCodRetorno 				= 'Consulta Exitosa.';
LET inNumTarjeta 				= '';
LET ccvv2 						= ''; -- no se hace nada
LET outNumCliente 				= '';
LET outCodStatusTarjeta 		= '';
LET binTarjeta 					= '';
LET rangoBinTarjeta 			= '';
LET outCuenta					= '';
LET outCVVvalido				= 't'; ---Bandera para valida cvv dinamico(t) o estatico(f) 
LET outStatus_perdido			= 'f';
LET outFechaExpirada		    = 'f';
LET outTarjetaInval				= 'f';
LET outCVVIntExcedido			= 'f';
LET outStatusFraude				= 'f';
LET binToken					= '';
LET outNumTarjeta				= '';
LET outCardId					= '';
LET inCard_ID					= NULL;
LET outStatus					= 0;
LET outFechaExpira				='';
LET mesFechActual    	        ='';
LET anioFechActual    	    	='';
LET mesFechExp    		        ='';
LET anioFechExp   			    ='';


BEGIN

		ON EXCEPTION SET isqlerr
			IF isqlerr <> 0 THEN		
				LET codRetorno = isqlerr;
				LET desCodRetorno = 'Error No Controlado al invocar SP sp_tokenizacion_consultatarjeta. Validar.';
			END IF;
			RETURN codRetorno, desCodRetorno, outCardId,  outNumCliente, outCuenta, outCVVvalido, outCVVIntExcedido, outStatus_perdido, outFechaExpirada, outTarjetaInval, outStatusFraude;
		END EXCEPTION;

	
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 10;

	
	-- Valida bin y producto de la tarjeta--
		LET inNumTarjeta = trim(ppan);
		LET inCard_ID = trim(pcard_id);
		--Obtiene rango de bin
		LET rangoBinTarjeta = SUBSTR (inNumTarjeta, 7, 2); 

	-- Valida que exista la tarjeta
		SELECT numtarjeta, codstatustarjeta, numcliente, fechaexp
				INTO outNumTarjeta, outCodStatusTarjeta, outNumCliente, outFechaExpira
		FROM "informix".tarjeta 
				WHERE numtarjeta = inNumTarjeta;
		
		IF outNumTarjeta IS NULL OR outNumTarjeta = '' THEN
				LET outTarjetaInval = 't';
				LET codRetorno = '00400';
				LET desCodRetorno = 'Tokenizacion de Tarjeta, numero de tarjeta invalido';
				RETURN codRetorno, desCodRetorno, inCard_ID, outNumCliente, outCuenta, outCVVvalido, outCVVIntExcedido, outStatus_perdido, outFechaExpirada, outTarjetaInval, outStatusFraude;	
		END IF;

	--Obtiene y valida si el usuario tiene CVV2 dinamico o estatico
		IF((SELECT cvv2dinamico FROM tarjeta_indicadores WHERE numtarjeta = inNumTarjeta) = 'V') THEN
			LET outCVVvalido = 'f';
		END IF;
				
	--Obtiene informacion de tabla tarjetacuenta
	SELECT numcuenta 
		INTO outCuenta 
	FROM tarjetacuenta 
		WHERE numtarjeta = outNumTarjeta;
			
	--Consulta BIN
	IF((SELECT COUNT(*) FROM "informix".tokenizacion_bines WHERE binfisico = pcard_bin AND rango = rangoBinTarjeta) <> 1) THEN
		LET outTarjetaInval = 't';
		LET codRetorno = '00400';
		LET desCodRetorno = 'Bin no apto para tokenizar.';
		RETURN codRetorno, desCodRetorno, inCard_ID, outNumCliente, outCuenta, outCVVvalido, outCVVIntExcedido,  outStatus_perdido, outFechaExpirada, outTarjetaInval, outStatusFraude;
	END IF;
	
	
	--Valida que exista cardID -- Modificar
		SELECT card_id 
			INTO outCardId 
		FROM "informix".tokenizacion_cardid 
			WHERE numtarjeta = outNumTarjeta;
			
		IF( outCardId IS NULL) THEN
			INSERT INTO "informix".tokenizacion_cardid(numtarjeta, card_id, fecha_insert) 
			VALUES( inNumTarjeta, inCard_ID, current);	
			LET outCardId = inCard_ID;
		END IF;
	
	--Valida estatus tarjeta 
		IF outCodStatusTarjeta IN('EXT', 'ROB','BLT','ACT','BLO') THEN
			IF outCodStatusTarjeta IN('EXT', 'ROB') THEN
				LET outStatus_perdido = 't';
				LET outTarjetaInval = 'f';
				LET codRetorno = '00400';
				LET desCodRetorno = 'Tokenizacion de Tarjeta, estatus de tarjeta robada';
				RETURN codRetorno, desCodRetorno, outCardId, outNumCliente, outCuenta, outCVVvalido, outCVVIntExcedido, outStatus_perdido, outFechaExpirada, outTarjetaInval, outStatusFraude;				
			END IF;		
			--Valida estatus tarjeta fraude
			IF outCodStatusTarjeta = 'BLT'	THEN
				LET outStatusFraude = 't';
				LET codRetorno = '00400';
				LET desCodRetorno = 'Tokenizacion de Tarjeta, posible fraude';
				RETURN codRetorno, desCodRetorno, outCardId, outNumCliente, outCuenta, outCVVvalido, outCVVIntExcedido, outStatus_perdido, outFechaExpirada, outTarjetaInval, outStatusFraude;
			END IF;
		ELSE
				LET outTarjetaInval = 't';
				LET codRetorno = '00400';
				LET desCodRetorno = 'Tokenizacion de Tarjeta, estatus de tarjeta invalido';
				RETURN codRetorno, desCodRetorno, outCardId, outNumCliente, outCuenta, outCVVvalido, outCVVIntExcedido, outStatus_perdido, outFechaExpirada, outTarjetaInval, outStatusFraude;
		END IF;

	--Valida fechas
		LET mesFechExp  = SUBSTR(pexpiracion,3,2);
		LET anioFechExp = SUBSTR(pexpiracion,1,2);
			
		
		--Obtiene fecha actual
		SELECT MONTH(TODAY),SUBSTR(YEAR(TODAY),3,2) 
		    INTO mesFechActual,anioFechActual
		FROM systables WHERE tabid = 1;
		
		IF mesFechActual < 10 THEN
		    LET mesFechActual = 0 || mesFechActual;
		END IF;
		
		--Valida que exista fecha de exp
		IF outFechaExpira <> pexpiracion THEN
			LET codRetorno = '00400';
			LET outTarjetaInval = 't';	
			LET desCodRetorno = 'Tokenizacion de Tarjeta, fecha expiraciÃÂ³n erronea';
			RETURN codRetorno, desCodRetorno, outCardId, outNumCliente, outCuenta, outCVVvalido, outCVVIntExcedido, outStatus_perdido, outFechaExpirada, outTarjetaInval, outStatusFraude;	
		END IF;
			
		IF anioFechExp = anioFechActual THEN
		    IF mesFechExp < mesFechActual THEN
		        LET codRetorno = '00400';
			    LET desCodRetorno = 'Tokenizacion de Tarjeta Expirada';
			    LET outFechaExpirada = 't';
			    RETURN codRetorno, desCodRetorno, outCardId, outNumCliente, outCuenta, outCVVvalido, outCVVIntExcedido, outStatus_perdido, outFechaExpirada, outTarjetaInval, outStatusFraude;
			END IF;
		ELIF anioFechExp < anioFechActual THEN
			LET codRetorno = '00400';
			LET desCodRetorno = 'Tokenizacion de Tarjeta Expirada';
			LET outFechaExpirada = 't';
			RETURN codRetorno, desCodRetorno, outCardId, outNumCliente, outCuenta, outCVVvalido, outCVVIntExcedido, outStatus_perdido, outFechaExpirada, outTarjetaInval, outStatusFraude;
		END IF;		
	    RETURN codRetorno, desCodRetorno, outCardId, outNumCliente, outCuenta, outCVVvalido, outCVVIntExcedido, outStatus_perdido, outFechaExpirada, outTarjetaInval, outStatusFraude;
	END
END PROCEDURE;
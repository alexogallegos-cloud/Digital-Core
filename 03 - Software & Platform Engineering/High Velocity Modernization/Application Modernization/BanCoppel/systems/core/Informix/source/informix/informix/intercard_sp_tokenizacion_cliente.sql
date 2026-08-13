CREATE PROCEDURE "informix".sp_tokenizacion_cliente (pcard_id CHAR(48), pissuerId CHAR(10), px_correlation_id  CHAR(64))

RETURNING CHAR(5) as codigoretorno, CHAR(80) as desc_codigoretorno, CHAR (16) as numtarjeta,  CHAR (5) as fechaexp, CHAR (104) as nombre, CHAR(04) as cvv;

--Definicion de Variables
DEFINE isqlerr 	   					INTEGER;
DEFINE codigoRetorno    			CHAR (05);
DEFINE desCodRetorno 				CHAR (80);
DEFINE outNumTarjeta				CHAR (20);
DEFINE outNumCliente				CHAR (30);
DEFINE outFechaExp					CHAR (04);
DEFINE outFechaExpMMAA				CHAR (04);
DEFINE outPrimerNombre 				CHAR(128);
DEFINE outSegundoNombre				CHAR(218);
DEFINE outApellidoPat				CHAR(128);
DEFINE outApellidoMat				CHAR(128);
DEFINE outNombreCliente				CHAR (104);

--Inicializacion de Variables
LET isqlerr 						= 0;
LET codigoRetorno 					= '00000';
LET desCodRetorno 					= 'Consulta Exitosa.';
LET outNumTarjeta 					= '';
LET outNumCliente 					= '';
LET outFechaExp 					= '';
LET outFechaExpMMAA					= '';
LET	outPrimerNombre 				= '';
LET	outSegundoNombre				= '';
LET	outApellidoPat					= '';
LET	outApellidoMat					= '';
LET outNombreCliente 				= '';

--SET DEBUG FILE TO '/home/c90313380/sp_tokenizacion_cliente.log';
	--TRACE ON;	

	BEGIN
		
		ON EXCEPTION SET isqlerr
			IF isqlerr <> 0 THEN		
				LET codigoRetorno = isqlerr;
				LET desCodRetorno = 'Error No Controlado al invocar SP sp_tokenizacion_cliente. Validar.';
			END IF;
			RETURN codigoRetorno, desCodRetorno, outNumTarjeta, outFechaExpMMAA, outNombreCliente, '';
		END EXCEPTION;
		
		
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 10;
		
	-- Valida card_id	
		IF pcard_id IS NULL OR pcard_id = '' THEN
			LET codigoRetorno = '00404';
			LET desCodRetorno =  'La variable de pcard_id se encuentra sin valor';
			RETURN codigoRetorno, desCodRetorno, outNumTarjeta, outFechaExpMMAA, outNombreCliente, '';
		END IF
	
	-- Obtiene numero de tarjeta
		SELECT numtarjeta
			INTO outNumTarjeta
		FROM tokenizacion_cardid WHERE card_id = pcard_id;
		
		IF outNumTarjeta IS NULL OR outNumTarjeta = '' THEN
			LET codigoRetorno = '00404';
			LET desCodRetorno =  'No se encontro numero de tarjeta con el card_id';
			RETURN codigoRetorno, desCodRetorno, outNumTarjeta, outFechaExpMMAA, outNombreCliente, '';
		END IF
	
	-- Obtiene fechaexp y numcliente
		SELECT fechaexp, numcliente 
			INTO outFechaExp, outNumCliente
		FROM "informix".tarjeta 
			WHERE numtarjeta = outNumTarjeta;
	
	-- Cambia formato de fecha = Mes - AÃ±o
		LET outFechaExpMMAA = SUBSTR (outFechaExp, 3, 2)||''||SUBSTR (outFechaExp, 1, 2);
		
	--Obtien nombre del cliente
		SELECT  nombre1, nombre2 , apell_paterno , apell_materno
			INTO  outPrimerNombre, outSegundoNombre, outApellidoPat , outApellidoMat
		FROM bdinteg:"informix".si_cliente WHERE numcte = outNumCliente;
		
		LET outNombreCliente = TRIM(outPrimerNombre)||' '||(outSegundoNombre)||' '||TRIM(outApellidoPat)||' '||TRIM(outApellidoMat);

		RETURN codigoRetorno, desCodRetorno, outNumTarjeta, outFechaExpMMAA, outNombreCliente, '';
	END
END PROCEDURE;
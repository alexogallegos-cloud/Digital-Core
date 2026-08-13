CREATE PROCEDURE "informix".sp_tokenizacion_digitalcardoperation(pdigital_cardid	CHAR(64), pissuer_id	CHAR(10),  px_correlation_id CHAR(64), p_operation_id	CHAR(64), 
							poperation CHAR(10), pstatus	CHAR(11))
	RETURNING  CHAR(5) AS codretorno,  CHAR(150) AS descodretorno;
	
	--Definicion de Variables
DEFINE isqlerr 	   			INTEGER;
DEFINE  cod_retorno 		CHAR(5);
DEFINE  des_cod_retorno 	CHAR(150);
	
	--Inicializacion de Variables
LET isqlerr 						= 0;
LET cod_retorno 					= '00000';
LET des_cod_retorno 				= 'Consulta Exitosa.';

	  
	BEGIN
	
		ON EXCEPTION SET isqlerr
				IF isqlerr <> 0 THEN		
					LET cod_retorno = isqlerr;
					LET des_cod_retorno = 'Error No Controlado al invocar SP sp_tokenizacion_digitalcardoperation. Validar.';
				END IF;
				RETURN cod_retorno, des_cod_retorno;
		END EXCEPTION;
	
			
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 10;
		
		--++++++++ Se realiza insercion de informacion en bitacora de la informacion ++++++++--
		
		INSERT INTO "informix".bitacora_token_digitalcard(digital_cardid,issuer_id, x_correlation_id, operation_id, operation, status, cod_retorno , des_codret, fecha_insert)
		VALUES(pdigital_cardid, pissuer_id,  px_correlation_id, p_operation_id, poperation , pstatus,cod_retorno, des_cod_retorno, CURRENT);
			
		RETURN cod_retorno, des_cod_retorno;
	
	END;
END PROCEDURE
;
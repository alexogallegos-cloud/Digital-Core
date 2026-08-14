CREATE PROCEDURE "informix".sp_token_avatar_bei(pIdUsuario INTEGER,pNumCliente CHAR(9),pTokenVirtual VARCHAR(20))
	RETURNING CHAR(5);

	--Declaración de variables
	DEFINE vCodRet char(5);
	DEFINE sql_err INTEGER;

	--Inicializar variables
	LET vCodRet  = "00000";

	--****************************************************************************************************
	-- DESCRIPCION: Actualiza la información del avatar
	-- AUTOR: Irving Guzman Salas - SOLSER
	-- FECHA: 22/09/2014
	-- BD: bdibei
	-- SOLICITO:BanCoppel
	-- FECHA LIBERACION A PRODUCCION: 22-ENERO-2015

	--***************************************************************************************************

	BEGIN
	   	ON EXCEPTION SET sql_err
	    	IF sql_err <> 0 THEN
	        	let vCodRet = sql_err;
	            RETURN vCodRet;
	      	END IF ;
	   	END EXCEPTION ;

		IF(NVL(pIdUsuario,0) <= 0) THEN
	        LET vCodRet="00001";
            RETURN vCodRet;
	    END IF;

	    IF(LENGTH(TRIM(NVL(pNumCliente,''))) = 0) THEN
	        LET vCodRet="00002";
            RETURN vCodRet;
	    END IF;

		IF(LENGTH(TRIM(NVL(pTokenVirtual,''))) = 0) THEN
	        LET vCodRet="00003";
            RETURN vCodRet;
	    END IF;



	   	SET LOCK MODE TO WAIT 4;

		UPDATE 	bdibei:"informix".bei_avatar
		SET  tokenvirtual = pTokenVirtual,
		    f_modifica = CURRENT
		WHERE id_usuario = pIdUsuario
		AND num_cliente = pNumCliente;

	  RETURN vCodRet;
	END
END PROCEDURE;
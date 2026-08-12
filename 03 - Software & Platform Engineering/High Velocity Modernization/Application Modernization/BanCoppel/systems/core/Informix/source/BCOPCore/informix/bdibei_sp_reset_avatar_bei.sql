CREATE PROCEDURE "informix".sp_reset_avatar_bei(pNumCliente CHAR(9), pIdUsuario INTEGER)
	RETURNING CHAR(5);

	--Declaración de variables
	DEFINE vCodRet char(5);
	DEFINE sql_err INTEGER;

	--Inicializar variables
	LET vCodRet  = "00000";

	--****************************************************************************************************
	-- DESCRIPCION: Realiza eliminacion del registro del Avatar de un usuario
	-- AUTOR: Jesus Ferruzca Luna- SOLSER
	-- FECHA: 27/10/2014
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

	   	SET LOCK MODE TO WAIT 4;

		DELETE FROM "informix".bei_avatar
        WHERE id_usuario = pIdUsuario
        AND num_cliente = pNumCliente;

	  RETURN vCodRet;
	END
END PROCEDURE;
CREATE PROCEDURE "informix".sp_insertar_avatar_bei(pIdUsuario INTEGER,pNumCliente CHAR(9),pIdAvatar SMALLINT,pNumIntento SMALLINT,pTokenVirtual VARCHAR(20))
	RETURNING CHAR(5);

	--Declaración de variables
	DEFINE vCodRet CHAR(5);
	DEFINE sql_err INTEGER;

	--Inicializar variables
	LET vCodRet='00000';

	--****************************************************************************************************
	-- DESCRIPCION: Inserta un nuevo avatar para el usuario
	-- AUTOR: Gerardo García Ortiz - SOLSER
	-- FECHA: 22/09/2014
	-- BD: bdibei
	-- FECHA LIBERACION A PRODUCCION: 22-ENERO-2015
	--***************************************************************************************************

	BEGIN
		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				LET vCodRet = sql_err;
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

	    IF(NVL(pIdAvatar,0) <= 0) THEN
	        LET vCodRet="00003";
            RETURN vCodRet;
	    END IF;

	    IF(NVL(pNumIntento,0) < 0) THEN
	        LET vCodRet="00004";
            RETURN vCodRet;
	    END IF;

	    IF(LENGTH(TRIM(NVL(pTokenVirtual,''))) = 0) THEN
	        LET vCodRet="00005";
            RETURN vCodRet;
	    END IF;

	    SET LOCK MODE TO WAIT 4;

	    INSERT INTO bdibei:"informix".bei_avatar(
	        id_usuario,
	        num_cliente,
	        id_avatar,
	        numintento,
	        f_registro,
	        tokenvirtual)
		VALUES(
	        pIdUsuario,
	        pNumCliente,
	        pIdAvatar,
	        pNumIntento,
	        TODAY,
	        pTokenVirtual);

	    RETURN vCodRet;
	END
END PROCEDURE;
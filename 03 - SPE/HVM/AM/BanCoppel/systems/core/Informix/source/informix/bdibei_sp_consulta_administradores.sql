CREATE PROCEDURE "informix".sp_consulta_administradores(pNumCliente CHAR(9),pIdOperacion CHAR(8))
	returning char(5),INTEGER, CHAR(50);

	--Declaración de variables
	DEFINE vCodRet char(5);
	DEFINE sql_err INTEGER;

    DEFINE sIdUsuario           INTEGER;
    DEFINE sEmail               CHAR(50);

	--Inicializar variables
	LET vCodRet  = "00000";
    LET sIdUsuario  = 0;
    LET sEmail      = "";

	--****************************************************************************************************
	-- DESCRIPCION: Consulta numero de operadores
	-- AUTOR: Luis Ponce - SOLSER
	-- BD: bdibei
	-- SOLICITO: BanCoppel
	-- Fecha: Octubre 2014
	-- FECHA LIBERACION A PRODUCCION: 22-ENERO-2015
	--***************************************************************************************************

	BEGIN
	   	ON EXCEPTION SET sql_err
	    	IF sql_err <> 0 THEN
	        	let vCodRet = sql_err;
                RETURN vCodRet, sIdUsuario, sEmail;
	      	END IF ;
	   	END EXCEPTION ;


	    IF(LENGTH(TRIM(NVL(pNumCliente,''))) = 0) THEN
	        LET vCodRet="00001";
            RETURN vCodRet, sIdUsuario, sEmail;
	    END IF;

         IF(LENGTH(TRIM(NVL(pIdOperacion,''))) = 0) THEN
                    LET vCodRet="00001";
                    RETURN vCodRet, sIdUsuario, sEmail;
         END IF;

	   	SET LOCK MODE TO WAIT 4;

        --Consulta la cuenta de la operacion mancomunada

    FOREACH

        SELECT us.id_usuario,daus.e_mail
        INTO  sIdUsuario,sEmail
        FROM bdibei:"informix".bei_usuario us 
        INNER JOIN bdibei:"informix".bei_datos_usuario daus ON (us.id_usuario = daus.id_usuario)
        JOIN (
                    SELECT DISTINCT u.id_usuario as id_usuario
                    FROM bdibei:"informix".bei_usuario u 
                    WHERE u.num_cliente=pNumCliente
                    AND u.id_tipo_usuario=1
                    AND u.id_status=30
        ) TAB ON(us.id_usuario = TAB.id_usuario)
        WHERE us.num_cliente=pNumCliente
        AND us.id_tipo_usuario=1

	  RETURN vCodRet,sIdUsuario,sEmail WITH RESUME;
    END FOREACH;
	END
END PROCEDURE;
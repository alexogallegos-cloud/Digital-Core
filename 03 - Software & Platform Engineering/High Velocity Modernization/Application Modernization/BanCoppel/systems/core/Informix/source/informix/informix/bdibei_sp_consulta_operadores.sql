CREATE PROCEDURE "informix".sp_consulta_operadores(pNumCliente CHAR(9),pIdOperacion CHAR(8))
	returning char(5),INTEGER, CHAR(50);

	--Declaración de variables
	DEFINE vCodRet char(5);
	DEFINE sql_err INTEGER;

    DEFINE sIdUsuario           INTEGER;
    DEFINE sEmail               CHAR(50);

    DEFINE NumCta               CHAR(20);

	--Inicializar variables
	LET vCodRet  = "00000";
    LET sIdUsuario  = 0;
    LET sEmail      = "";

	--****************************************************************************************************
	-- DESCRIPCION: Consulta numero de operadores
	-- AUTOR: Luis Ponce
	-- BD: bdibei
	-- SOLICITO: BanCoppel
	-- Fecha: Octubre 2014
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

        SELECT o.cuenta_origen
        INTO NumCta
        FROM bdibei:"informix".bei_operacionesmancomunadasoperador o 
        WHERE o.id_operacion=pIdOperacion;

    FOREACH
        SELECT us.id_usuario,daus.e_mail
        INTO  sIdUsuario,sEmail
        FROM bdibei:"informix".bei_usuario us 
        INNER JOIN bdibei:"informix".bei_datos_usuario daus ON (us.id_usuario = daus.id_usuario)
        JOIN (
            SELECT o.id_usuario 
            FROM bdibei:"informix".bei_operacionesmancomunadasoperador o 
            WHERE o.id_operacion=pIdOperacion
            UNION
            SELECT m.id_usuario 
            FROM bdibei:"informix".bei_mancomunidad m 
            INNER JOIN bei_operacionesmancomunadasoperador o ON (m.num_cta = o.cuenta_origen) 
            WHERE m.num_cta=NumCta
            AND m.autoriza='T' 
            AND o.id_operacion=pIdOperacion
        ) TAB ON(us.id_usuario = TAB.id_usuario)
        WHERE us.num_cliente=pNumCliente
        AND us.id_tipo_usuario=2

	  RETURN vCodRet,sIdUsuario,sEmail WITH RESUME;
    END FOREACH;
	END
END PROCEDURE;
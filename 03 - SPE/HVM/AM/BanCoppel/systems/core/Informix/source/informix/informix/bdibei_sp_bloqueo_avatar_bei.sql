CREATE PROCEDURE "informix".sp_bloqueo_avatar_bei(pIdUsuario INTEGER,pNumCliente CHAR(9),pIntetno INTEGER,pMinBlqueo INTEGER)
	RETURNING CHAR(5);

	--Declaración de variables
	DEFINE vCodRet char(5);
	DEFINE sql_err INTEGER;
 	DEFINE sFBloqueoTemp DATETIME YEAR to SECOND;
 	
	--Inicializar variables
	LET vCodRet  = "00000";

	--****************************************************************************************************
	-- DESCRIPCION: Actualiza la Intentos Avatar
	-- AUTOR: Irving Guzman Salas
	-- FECHA: 22/09/2014
	-- BD: bdibei
	-- SOLICITO:
	-- FECHA LIBERACION A PRODUCCION: 22-ENERO-2015
	--***************************************************************************************************

	BEGIN
	   	ON EXCEPTION SET sql_err
	    	IF sql_err <> 0 THEN
	        	let vCodRet = sql_err;
	            RETURN vCodRet;
	      	END IF ;
	   	END EXCEPTION ;
	   	
	   	
	   	SET LOCK MODE TO WAIT 4;
	   	
	

		IF(NVL(pIdUsuario,0) <= 0) THEN
	        LET vCodRet="00003";
            RETURN vCodRet;
	    END IF;

	    IF(LENGTH(TRIM(NVL(pNumCliente,''))) = 0) THEN
	        LET vCodRet="00004";
            RETURN vCodRet;
	    END IF;

		IF NVL(pIntetno,0) = 0 THEN
			UPDATE 	bdibei:"informix".bei_avatar
			SET f_modifica = CURRENT,
			 	numintento=numintento+1
			WHERE id_usuario = pIdUsuario
			AND num_cliente = pNumCliente;
			  LET vCodRet="00000";
		ELIF pIntetno = 1 THEN
			UPDATE 	bdibei:"informix".bei_avatar
			SET f_modifica = CURRENT,
			 	numintento=0
			WHERE id_usuario = pIdUsuario
			AND num_cliente = pNumCliente;
			LET vCodRet="00001";
		ELSE
		
			  LET sFBloqueoTemp =CURRENT+ pMinBlqueo units minute;
		
			UPDATE 	bdibei:"informix".bei_avatar
			SET f_modifica = CURRENT,
			 	numintento=0 , 
			 	f_bloqueo_temp=sFBloqueoTemp 
			WHERE id_usuario = pIdUsuario
			AND num_cliente = pNumCliente;
			
			LET vCodRet="00002";
	    END IF;

	  RETURN vCodRet;
	END
END PROCEDURE;
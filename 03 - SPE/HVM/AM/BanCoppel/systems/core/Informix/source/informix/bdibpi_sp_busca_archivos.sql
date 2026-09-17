CREATE PROCEDURE "informix".sp_busca_archivos()
				 returning char(5) as codRet, char(50) as nombre1, char(50) as nombre2
				 
	/*
	************************************************************************************
	
		Elaboró: Nubia Janeth Montoya Medina
		Actividad: Buscar Archivos de empleados para la asignación de Token
		Solicito: Mauricio León
		Fecha: 26-02-2010
		Modificó: Nubia Janeth Montoya Medina
		Modificación: Cambiar los id de parametros establecidos.
		Fecha: 29-03-2010

	************************************************************************************
	*/
	
				
	-- DECLARA
	DEFINE sql_err integer;
	DEFINE codRet char(5);
	DEFINE nombre1 char(50);
	DEFINE nombre2 char(50);
	
	-- INICIALIZA
	LET sql_err = 0;
	LET codRet = '00000';
	LET nombre1 =  '';
	LET nombre2 =  '';
			 
	BEGIN
	
		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				let codRet = sql_err;
				RETURN codRet, nombre1, nombre2;
			END IF;
		END EXCEPTION;
		
		SELECT valor 
		INTO nombre1
		FROM bdibpi:tkn_parametros 
		WHERE id_param = 18;
		
		SELECT valor 
		INTO nombre2
		FROM bdibpi:tkn_parametros 
		WHERE id_param = 19;
		
		IF (nombre1 = '') THEN
			LET codRet = '00001';
		END IF;
		
		IF (nombre2 = '') THEN
			LET codRet = '00002';
		END IF;
		
		RETURN codRet, nombre1, nombre2;

	END;	
END PROCEDURE;
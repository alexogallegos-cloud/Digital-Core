CREATE PROCEDURE "informix".sp_resetstatus_token(pNumCte char(9), pNumToken char(10), pStatusNuevo char(3), pUsrAtendio char(9),pCanal char(2))
   returning char(5);
   
---------------------------------------------------------------------------------------------
-- RealizÃ³: Gabriela Aguilar Mendoza
-- Actividad: Actualiza el estatus del token cuando no existe pregunta 1010
-- SolicitÃ³: Alejandro VÃ¡zquez
-- Fecha: 25/08/2016
---------------------------------------------------------------------------------------------

--Define variables
    DEFINE sql_err int ;
    DEFINE cod_ret char(5);
	DEFINE pNumToken char(9);
	DEFINE pStatusViejo char(3);
	
   
--Inicializa variables
	LET cod_ret  = '00000';
	LET pNumToken = '0000000000';
	LET pStatusViejo = '000';
	
	
	
	--SET DEBUG FILE TO "/informix/gaby/pregunta1010/sp_resetstatus_token.out";
	--TRACE ON;
		

	BEGIN
	
	   ON EXCEPTION SET sql_err
		  IF sql_err <> 0 THEN
			let cod_ret = sql_err;
			RETURN cod_ret;
		  END IF ;
	   END EXCEPTION;
	   		
	   SELECT ns_token, id_status_token INTO pNumToken, pStatusViejo  FROM bdinteg:"informix".si_bpitoken WHERE num_cliente = pNumcte;						
			
	   IF pNumToken = ''  THEN --Valida que  no sean nulo o espacio en blanco
			LET cod_ret = '901';   -- El usuario no cuenta con token asigando
			RETURN cod_ret;
			
		ELSE
     			UPDATE bdibpi:tkn_nseries SET id_status = pStatusNuevo, f_status = current, canal=pCanal       
				WHERE ns_token = pNumToken; 

				INSERT INTO bdibpi:tkn_status_token (ns_token,anterior,actual,f_cambio_status, usr_cambio_status,canal) 
				VALUES(pNumToken, pStatusViejo, pStatusNuevo, current, pUsrAtendio, pCanal);
				
				UPDATE bdinteg:si_bpitoken SET id_status_token=pStatusNuevo, f_status=current WHERE num_cliente = pNumcte AND ns_token=pNumToken;  	
		
				LET cod_ret='900';
				RETURN cod_ret;
		END IF;
	
	END;
	
END PROCEDURE;
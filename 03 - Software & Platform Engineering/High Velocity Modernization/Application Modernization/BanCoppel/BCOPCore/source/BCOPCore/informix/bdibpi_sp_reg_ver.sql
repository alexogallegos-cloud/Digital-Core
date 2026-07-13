CREATE PROCEDURE "informix".sp_reg_ver(pNumCteTel CHAR(15), pCanal CHAR(3),pVer CHAR(50))
returning CHAR(5);

	DEFINE sql_err 			INTEGER ;
	DEFINE cod_ret 			CHAR(5);
	DEFINE vUser			CHAR(3);

	
 
	LET cod_ret 	 	= '00000';
	LET vUser			= '';
	
  
--  SET DEBUG FILE TO "/informix/bdibpi/sp_reg_ver.out";
--  TRACE ON;
  
	
BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            LET cod_ret = sql_err;
            RETURN cod_ret;
      END IF;
   END EXCEPTION;
   
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	LET vUser = LENGTH(pNumCteTel);
	
	IF pCanal = 'BX' THEN  --PARA BANCOPPEL EXPRESS
	
		IF vUser = '10' THEN  --SI SE ENVIA NUMERO CELULAR
		
			UPDATE bdibpi:bpi_registro_bex SET folio_activacion=pVer WHERE no_celular = pNumCteTel
			AND servicio = 'activo';
			
			LET cod_ret  = '00000';
			RETURN cod_ret;	
			
		ELIF vUser = '9' THEN  ---SI SE ENVIA NUMERO CLIENTE
			
			UPDATE bdibpi:bpi_registro_bex SET folio_activacion=pVer WHERE num_cliente = pNumCteTel
			AND servicio = 'activo';
			
			LET cod_ret  = '00000';
			RETURN cod_ret;	
			
		END IF	
		
	END IF
	
	IF pCanal = 'BM' THEN --PARA BANCOPPEL MOVIL
		
		IF vUser = '10' THEN  --SI SE ENVIA NUMERO CELULAR
		
			UPDATE bdibpi:bpi_reg_dispo_apps SET generico1=pVer WHERE no_celular = pNumCteTel
			AND dispo_act = '1';
			
			LET cod_ret  = '00000';
			RETURN cod_ret;	
			
		ELIF vUser = '9' THEN  ---SI SE ENVIA NUMERO CLIENTE
			
			UPDATE bdibpi:bpi_reg_dispo_apps SET generico1=pVer WHERE num_cliente = pNumCteTel
			AND dispo_act = '1';
	
			LET cod_ret  = '00000';
			RETURN cod_ret;	
			
		END IF	
		
	END IF
   
END;

END PROCEDURE;
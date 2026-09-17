CREATE PROCEDURE "informix".sp_regkey_app(pc_canal varchar(50), pc_usuario varchar(20), id_seg varchar(100))
    RETURNING CHAR(5),CHAR(3);
	
	DEFINE resultado CHAR(3);
    DEFINE vcodret   CHAR(5);
    DEFINE sql_err   integer;
	DEFINE vExit    INTEGER;
    DEFINE vNumCte varchar(10);

	LET resultado = '00000';
	LET vcodret   = '00000';
	LET vExit 	  =	'';
    LET vNumCte = '';
	
	
BEGIN
		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				LET vcodret = sql_err;
				RETURN vcodret, resultado;
			END IF;
		END EXCEPTION;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
			SELECT TRIM(numcliente)  INTO vNumCte
			FROM bdibpi:bpi_usuario WHERE usuario = pc_usuario 
			AND st_portal = 'activo' ;
		
			SELECT COUNT(numcliente) 
			INTO vExit
			FROM "informix".bpi_doblesesion 
			WHERE numcliente = vNumCte
			AND (CURRENT - fecha) < '0 00:08:00.000';
   
		IF vExit = 1 THEN
            				
			UPDATE "informix".bpi_doblesesion 
            SET llave = id_seg 
            WHERE numcliente = vNumCte; 
			LET resultado = '000';
			
		ELSE
		
		-- Se agrega la opcion para borrar registros 
		    DELETE FROM "informix".bpi_doblesesion 
            WHERE numcliente = vNumCte;
			
			DELETE FROM "informix".bpi_doblesesion 
            WHERE numcliente = '0' AND usuario = pc_usuario;
			
			INSERT INTO "informix".bpi_doblesesion(numcliente, 
													usuario,
													fecha,
													canal,
													id_sesion,
													status,
													llave
													)
											VALUES ('0',
													pc_usuario,
													CURRENT,
													pc_canal,
													'0',
													'0',
													id_seg
													);
			LET resultado = '000';
			
		END IF;
END;	
	RETURN	vcodret, resultado;	
	
END PROCEDURE;
CREATE PROCEDURE "informix".sp_depura_bpi_doblesesion()
RETURNING CHAR(5),INTEGER;
-----------------------------------------------------------------------------------
--Definicion de variables del proceso, operaciones con fechas y manejo de errores--
-----------------------------------------------------------------------------------
    DEFINE vcodret1         CHAR(5);
    DEFINE error_info		CHAR(50);
    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE vcontador1       INTEGER;
	DEFINE vcontador2       INTEGER;
	DEFINE vRegistros		INTEGER;
	DEFINE vId				INTEGER;
	DEFINE vfecha_oper     	DATE; 
	
---------------------------
--Inicializando variables--
---------------------------
--	SET DEBUG FILE TO "/informix/c90215678/depura/sp_depura_bpi_doblesesion_modificado.out"; --Se genera log en un archivo .out
--	TRACE ON;
	
		LET vcodret1        = '00000';
		LET sql_err	        = 0;
		LET isam_err        = 0;
		LET vcontador1      = -1;
		LET vcontador2      = 0;
		LET vRegistros      = 0;
		LET vId 			= 0;
		

	/*Incia SP*/
BEGIN

		ON EXCEPTION SET sql_err, isam_err
			IF sql_err <> 0 THEN
				LET vcodret1 = sql_err;
				LET vcontador1 = isam_err;
				RETURN vcodret1, vcontador1;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 4;
		
		
		SELECT COUNT(*) INTO vRegistros  FROM "informix".bpi_doblesesion  WHERE fecha NOT IN (SELECT fecha FROM bdibpi:bpi_doblesesion  WHERE DATE(fecha) BETWEEN TODAY-1 AND TODAY);
				
		IF vRegistros > 0 THEN
			
			FOREACH WITH HOLD

			
			SELECT fecha INTO vfecha_oper FROM "informix".bpi_doblesesion  
			WHERE fecha NOT IN (SELECT fecha FROM bdibpi:bpi_doblesesion  WHERE DATE(fecha) BETWEEN TODAY-1 AND TODAY)
			
			IF vcontador1 = -1 THEN
				LET vcontador1 = 0;
				BEGIN WORK;
			END IF;
		
			DELETE FROM "informix".bpi_doblesesion  WHERE fecha NOT IN (SELECT fecha FROM bdibpi:bpi_doblesesion  WHERE DATE(fecha) BETWEEN TODAY-1 AND TODAY);
		
			LET vcontador1 = vcontador1 + 1;
			LET vcontador2 = vcontador2 + 1;
		
			 IF vcontador2 >= 10000 THEN   --- Sftk 201223 Se cambia valor de 1000 a 10000
				LET vcontador2 = 0;
				COMMIT WORK;
				BEGIN WORK;
			 END IF;
		
			COMMIT WORK;
			BEGIN WORK;
			
			END FOREACH;
			IF vcontador1 > -1 THEN		
				COMMIT WORK;
			END IF;
		ELSE 
			LET vcodret1 = '00000';
		END IF;

		RETURN vcodret1, vcontador1;	
	END;
END PROCEDURE;
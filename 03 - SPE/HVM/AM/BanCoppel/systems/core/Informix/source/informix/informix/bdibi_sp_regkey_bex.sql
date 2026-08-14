CREATE PROCEDURE "informix".sp_regkey_bex(pc_canal varchar(50), pNumCte varchar(10) ,pc_usuario varchar(20), key_seg varchar(100))
    RETURNING CHAR(5),CHAR(5);
	
	DEFINE resultado CHAR(5);
    DEFINE vcodret   CHAR(5);
    DEFINE sql_err   integer;

	--SET DEBUG FILE TO "/informix/ireb/bdibpi/sp_regkey_bex.out";
    --TRACE ON; 
	

	LET resultado = '00000';
	LET vcodret   = '00000';
	
BEGIN
		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				LET vcodret = sql_err;
				RETURN vcodret, resultado;
			END IF;
		END EXCEPTION;

SET ISOLATION TO DIRTY READ;

		
		IF NOT EXISTS (SELECT {+INDEX(bpi_doblesesion idx_bpi_doblesesion)} usuario FROM "informix".bpi_doblesesion WHERE numcliente = pNumCte AND canal in ('PORTALBPI','APPS','BEX'))
			THEN
		
			IF EXISTS (SELECT {+INDEX(  idx_bpi_doblesesion)} usuario FROM "informix".bpi_doblesesion WHERE numcliente = pNumCte)
				THEN
					UPDATE "informix".bpi_doblesesion SET llave = key_seg/*, fecha = CURRENT*/ WHERE numcliente = pNumCte and canal=pc_canal; /*SE DEJA DE ACTUALIZAR LA FECHA*/
					--LET resultado = '00000';
			ELSE
				INSERT INTO "informix".bpi_doblesesion(numcliente, 
														usuario,
														fecha,
														canal,
														id_sesion,
														status,
														llave
														)
												VALUES (pNumCte,
														pc_usuario,
														CURRENT,
														pc_canal,
														'0',
														'0',
														key_seg
														);
								LET resultado = '00000';
			END IF;
		ELSE 
		LET resultado = '00000';
		END IF;
END;	
	RETURN	vcodret, resultado;	
	
END PROCEDURE;
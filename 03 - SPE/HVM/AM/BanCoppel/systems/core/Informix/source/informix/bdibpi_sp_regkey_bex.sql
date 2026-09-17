CREATE PROCEDURE "informix".sp_regkey_bex(pc_canal varchar(50), pNumCte varchar(10) ,pc_usuario varchar(20), key_seg varchar(100))
    RETURNING CHAR(5),CHAR(5);
	
	DEFINE resultado CHAR(5);
    DEFINE vcodret   CHAR(5);
    DEFINE sql_err   INTEGER;
	DEFINE vExit    varchar(8);

	LET resultado = '00000';
	LET vcodret   = '00000';
	LET vExit 	  =	'';
	
	BEGIN
		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				LET vcodret = sql_err;
				RETURN vcodret, resultado;
			END IF;
		END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3 ;

		SELECT FIRST 1 usuario
		INTO vExit
		FROM "informix".bpi_doblesesion 
		WHERE numcliente = pNumCte 
		AND (CURRENT - fecha) < '0 00:08:00.000';
		
			IF NVL(vExit,'') <> '' THEN 
				LET resultado = '00001';
			ELSE

--GM2 Juan Olivares: 25/10/2018 INI: ModificaciÃ³n Validacion Doble SesiÃ³n para evitar error -284
                DELETE FROM "informix".bpi_doblesesion 
				WHERE numcliente = pNumCte;

--GM2 Juan Olivares: 25/10/2018 FIN: ModificaciÃ³n Validacion Doble SesiÃ³n para evitar error -284
				INSERT INTO "informix".bpi_doblesesion(numcliente, usuario,fecha,canal,id_sesion,status,llave)
				VALUES (pNumCte,pc_usuario,CURRENT,pc_canal,'0','0',key_seg);
				
				LET resultado = '00000';
			END IF;
		
	END;	
	RETURN	vcodret, resultado;	
END PROCEDURE;
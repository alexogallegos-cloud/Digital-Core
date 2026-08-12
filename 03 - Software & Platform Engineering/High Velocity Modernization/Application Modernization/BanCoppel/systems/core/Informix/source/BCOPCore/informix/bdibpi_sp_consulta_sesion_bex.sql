CREATE PROCEDURE "informix".sp_consulta_sesion_bex(pc_numero_cliente varchar(20), pc_canal varchar(50), pc_id_sesion char(500), pc_usuario varchar(20), key_old varchar(100), key_new varchar(100))
    RETURNING CHAR(5),CHAR(3);
	
	DEFINE resultado CHAR(3);
    DEFINE vcodret   CHAR(5);
    DEFINE sql_err   INTEGER;
	DEFINE vCount 	INTEGER;
    DEFINE vCountinactivas INTEGER;
	
	LET resultado = '000';
	LET vcodret   = '00000';
	LET vCount	  = 0;
    let vCountinactivas = 0;
	
	--SET DEBUG FILE TO "/informix/ireb/bdibpi/sp_consulta_sesion_bex.out";
    --TRACE ON; 
BEGIN	
	ON EXCEPTION SET sql_err
       IF sql_err <> 0 THEN
			LET vcodret = sql_err;
        RETURN vcodret, resultado;
       END IF;
	END EXCEPTION;

    SET LOCK MODE TO WAIT 3;
    SET ISOLATION TO DIRTY READ;
	
	SELECT {+INDEX(bpi_doblesesion idx_bpi_doblesesion)} 
	COUNT(numcliente) 
	INTO vCount 
	FROM "informix".bpi_doblesesion 
	WHERE numcliente = pc_numero_cliente 
	AND canal IN ('PORTALBPI','APPS');

	IF vCount > 0 THEN
	--GMTTO2 JUAN OLIVARES INI: ModificaciÃ³n para evitar el error -284
		SELECT SUM(CASE WHEN (CURRENT - fecha) < '0 00:08:00.000' THEN 1 ELSE 0 END)
        INTO vCountinactivas
        FROM "informix".bpi_doblesesion 
        WHERE numcliente = pc_numero_cliente;

		LET vCountinactivas = NVL(vCountinactivas,0);
				
		IF ( vCountinactivas > 0 ) THEN
			LET resultado = '002';
		ELSE
			SELECT COUNT(usuario)  
			INTO vCount 
			FROM "informix".bpi_doblesesion
			WHERE numcliente = pc_numero_cliente;
	--GMTTO2 JUAN OLIVARES FIN: ModificaciÃ³n para evitar el error -284			
			IF vCount > 0 THEN
				DELETE FROM "informix".bpi_doblesesion 
				WHERE numcliente = pc_numero_cliente;
						
				INSERT INTO "informix".bpi_doblesesion (numcliente, 
					usuario, fecha, canal, id_sesion, status, llave)
				VALUES (pc_numero_cliente, pc_usuario, CURRENT, pc_canal,
					pc_id_sesion, '0', key_new);
				
				LET resultado = '000';		
			ELSE
				LET resultado = '004';
			END IF;
		END IF;
	ELSE
		SELECT COUNT(usuario)  
		INTO vCount 
		FROM "informix".bpi_doblesesion 
		WHERE usuario = pc_usuario;
				
		IF vCount > 0 THEN
		--GMTTO2 JUAN OLIVARES INI: ModificaciÃ³n para evitar el error -284
			SELECT SUM(CASE WHEN (CURRENT - fecha) < '0 00:08:00.000' THEN 1 ELSE 0 END)
            INTO vCountinactivas
            FROM "informix".bpi_doblesesion 
            WHERE usuario = pc_usuario;

			LET vCountinactivas = NVL(vCountinactivas,0);

			IF (vCountinactivas = 1)THEN
				SELECT COUNT(usuario) 
				INTO vCount
				FROM "informix".bpi_doblesesion 
				WHERE usuario = pc_usuario 
				AND llave = key_old;
		--GMTTO2 JUAN OLIVARES INI: ModificaciÃ³n para evitar el error -284	
				IF vCount > 0 THEN
					UPDATE "informix".bpi_doblesesion 
					SET numcliente = pc_numero_cliente,
					    id_sesion = pc_id_sesion,
						llave = key_new,
						fecha = CURRENT
					WHERE usuario = pc_usuario;
					
					LET resultado = '000';
				ELSE
					LET resultado = '001';
				END IF;
									
			ELSE
				SELECT COUNT(usuario) 
				INTO vCount 
				FROM "informix".bpi_doblesesion 
				WHERE usuario = pc_usuario 
				AND llave = key_old;
					IF vCount > 0 THEN 
						DELETE FROM "informix".bpi_doblesesion 
						WHERE usuario = pc_usuario;
						
						INSERT INTO "informix".bpi_doblesesion (numcliente, 
							usuario, fecha, canal, id_sesion, status, llave)
						VALUES (pc_numero_cliente, pc_usuario, CURRENT, pc_canal,
							pc_id_sesion, '0', key_new);
						
						LET resultado = '000';		
					ELSE
						DELETE FROM "informix".bpi_doblesesion 
						WHERE usuario = pc_usuario;
						
						LET resultado = '004';
					END IF;
			END IF;
		ELSE 
			LET resultado = '005';
		END IF;	
	END IF;
END;	
	RETURN	vcodret, resultado;	
END PROCEDURE;
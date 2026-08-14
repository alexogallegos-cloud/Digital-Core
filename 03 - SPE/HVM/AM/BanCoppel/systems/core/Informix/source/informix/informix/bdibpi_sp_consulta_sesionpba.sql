CREATE PROCEDURE "informix".sp_consulta_sesionpba(pc_numero_cliente varchar(20), pc_canal varchar(50), pc_id_sesion char(500), pc_usuario varchar(20))
    RETURNING CHAR(5),CHAR(3);
	
	DEFINE resultado CHAR(3);
    DEFINE vcodret   CHAR(5);
    DEFINE sql_err   integer;

	LET resultado = '000';
	LET vcodret   = '00000';


set debug file to "/tmp/consultasesion.out";
trace on;

	
BEGIN	
	ON EXCEPTION SET sql_err
       IF sql_err <> 0 THEN
			LET vcodret = sql_err;
        RETURN vcodret, resultado;
       END IF;
	END EXCEPTION;
	

	---IF EXISTS (SELECT numcliente FROM "informix".bpi_doblesesion WHERE numcliente LIKE pc_numero_cliente AND canal like 'PORTALBPI')
	IF EXISTS (SELECT {+INDEX(bpi_doblesesion_new idx_bpi_doblesesion_new)} numcliente FROM "informix".bpi_doblesesion_new WHERE numcliente = pc_numero_cliente AND canal like 'PORTALBPI')
		THEN
			IF(pc_canal = 'PORTALBPI')
				THEN
					---IF ((SELECT (CURRENT - fecha) FROM "informix".bpi_doblesesion WHERE numcliente LIKE pc_numero_cliente) <  '0 00:08:00.000')
					IF ((SELECT {+INDEX(bpi_doblesesion_new idx_bpi_doblesesion_new)} (CURRENT - fecha) FROM "informix".bpi_doblesesion_new WHERE numcliente = pc_numero_cliente) <  '0 00:08:00.000')
						THEN

						LET resultado = '003';
					ELSE
						---DELETE FROM "informix".bpi_doblesesion WHERE numcliente LIKE pc_numero_cliente;
						DELETE {+INDEX(bpi_doblesesion_new idx_bpi_doblesesion_new)} FROM "informix".bpi_doblesesion_new WHERE numcliente = pc_numero_cliente;
						INSERT INTO "informix".bpi_doblesesion_new (numcliente, 
												usuario,
												fecha,
												canal,
												id_sesion,
												status
												)
										VALUES (pc_numero_cliente,
												pc_usuario,
												CURRENT,
												pc_canal,
												pc_id_sesion,
												'0'
												);
						LET resultado = '000';
					END IF;
			
			ELSE 
				---IF ((SELECT (CURRENT - fecha) FROM "informix".bpi_doblesesion WHERE numcliente LIKE pc_numero_cliente) <  '0 00:08:00.000')
				IF ((SELECT {+INDEX(bpi_doblesesion_new idx_bpi_doblesesion_new)} (CURRENT - fecha) FROM "informix".bpi_doblesesion_new WHERE numcliente LIKE pc_numero_cliente) <  '0 00:08:00.000')
						THEN

						LET resultado = '002';
					ELSE
						---DELETE FROM "informix".bpi_doblesesion WHERE numcliente LIKE pc_numero_cliente;
						DELETE FROM "informix".bpi_doblesesion_new WHERE numcliente = pc_numero_cliente;
						---INSERT INTO "informix".bpi_doblesesion(numcliente, 
						INSERT INTO "informix".bpi_doblesesion_new(numcliente, 
												usuario,
												fecha,
												canal,
												id_sesion,
												status
												)
										VALUES (pc_numero_cliente,
												pc_usuario,
												CURRENT,
												pc_canal,
												pc_id_sesion,
												'0'
												);
						LET resultado = '000';
					END IF;
				
			
			END IF
	ELSE 
		IF(pc_canal = 'PORTALBPI')
			THEN
				---IF EXISTS (SELECT numcliente FROM "informix".bpi_doblesesion WHERE numcliente LIKE pc_numero_cliente) THEN
				IF EXISTS (SELECT {+INDEX(bpi_doblesesion_new idx_bpi_doblesesion_new)} numcliente FROM "informix".bpi_doblesesion_new WHERE numcliente = pc_numero_cliente) THEN
						---IF ((SELECT (CURRENT - fecha) FROM "informix".bpi_doblesesion WHERE numcliente LIKE pc_numero_cliente) <  '0 00:08:00.000')
						IF ((SELECT {+INDEX(bpi_doblesesion_new idx_bpi_doblesesion_new)} (CURRENT - fecha) FROM "informix".bpi_doblesesion_new WHERE numcliente = pc_numero_cliente) <  '0 00:08:00.000')
						THEN

							LET resultado = '003';
						ELSE
							---DELETE FROM "informix".bpi_doblesesion WHERE numcliente LIKE pc_numero_cliente;
							DELETE FROM "informix".bpi_doblesesion_new WHERE numcliente = pc_numero_cliente;
							---INSERT INTO "informix".bpi_doblesesion(numcliente, 
							INSERT INTO "informix".bpi_doblesesion_new(numcliente, 
													usuario,
													fecha,
													canal,
													id_sesion,
													status
													)
											VALUES (pc_numero_cliente,
													pc_usuario,
													CURRENT,
													pc_canal,
													pc_id_sesion,
													'0'
													);
							LET resultado = '000';
						END IF;
					ELSE 
						INSERT INTO "informix".bpi_doblesesion_new(numcliente, 
													usuario,
													fecha,
													canal,
													id_sesion,
													status
													)
											VALUES (pc_numero_cliente,
													pc_usuario,
													CURRENT,
													pc_canal,
													pc_id_sesion,
													'0'
													);
						LET resultado = '000';
					END IF	
		ELSE 
			---IF EXISTS (SELECT numcliente FROM "informix".bpi_doblesesion WHERE numcliente LIKE pc_numero_cliente) THEN
			IF EXISTS (SELECT {+INDEX(bpi_doblesesion_new idx_bpi_doblesesion_new)} numcliente FROM "informix".bpi_doblesesion_new WHERE numcliente = pc_numero_cliente) THEN
						---IF ((SELECT (CURRENT - fecha) FROM "informix".bpi_doblesesion WHERE numcliente LIKE pc_numero_cliente) <  '0 00:08:00.000')
						IF ((SELECT {+INDEX(bpi_doblesesion_new idx_bpi_doblesesion_new)} (CURRENT - fecha) FROM "informix".bpi_doblesesion_new WHERE numcliente = pc_numero_cliente) <  '0 00:08:00.000')
						THEN

							LET resultado = '001';
						ELSE
							---DELETE FROM "informix".bpi_doblesesion WHERE numcliente LIKE pc_numero_cliente;
							DELETE {+INDEX(bpi_doblesesion_new idx_bpi_doblesesion_new)} FROM "informix".bpi_doblesesion_new WHERE numcliente = pc_numero_cliente;
							INSERT INTO "informix".bpi_doblesesion_new(numcliente, 
													usuario,
													fecha,
													canal,
													id_sesion,
													status
													)
											VALUES (pc_numero_cliente,
													pc_usuario,
													CURRENT,
													pc_canal,
													pc_id_sesion,
													'0'
													);
							LET resultado = '000';
						END IF;
					ELSE 
						INSERT INTO "informix".bpi_doblesesion_new(numcliente, 
													usuario,
													fecha,
													canal,
													id_sesion,
													status
													)
											VALUES (pc_numero_cliente,
													pc_usuario,
													CURRENT,
													pc_canal,
													pc_id_sesion,
													'0'
													);
						LET resultado = '000';
					END IF	
		
			
		END IF;
			
		
	END IF;
END;	
	RETURN	vcodret, resultado;	
	
END PROCEDURE;
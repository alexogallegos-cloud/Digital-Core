CREATE PROCEDURE "informix".sp_homologacion_tarjeta_normal
(
	inNumeroCaso		INTEGER
	-- 1: CASO 1	ACT/BLO/BLT			NOA/NOE		SIN informacion en intercard:tarjetacuenta y CON informacion en bdicred:sd_tarjeta/sd_maecred
	-- 2: CASO 2	ACT/BLO/BLT			NOA/NOE 	SIN informacion en intercard:tarjetacuenta y SIN informacion en bdicred:sd_tarjeta/sd_maecred
	-- 3: CASO 3	ACT/BLO/BLT			NOA/NOE 	CON informacion en intercard:tarjetacuenta y CON informacion en bdicred:sd_tarjeta/sd_maecred
	-- 6: CASO 6	ACT/BLO/BLT			SIA    		CON informacion en intercard:tarjetacuenta y CON informacion en bdicred:sd_tarjeta/sd_maecred
	-- 9: CASO 9	DAN					NOA/NOE		SIN informacion en intercard:tarjetacuenta y CON informacion en bdicred:sd_tarjeta/sd_maecred
	--10: CASO 10	DAN					NOA/NOE		SIN informacion en intercard:tarjetacuenta y SIN informacion en bdicred:sd_tarjeta/sd_maecred con registro de numero de cliente en intercard:tarjeta
	--13: CASO 13	CAN/ROB/EXT/FAL		NOA/NOE		SIN informacion en intercard:tarjetacuenta y CON informacion en bdicred:sd_tarjeta/sd_maecred
	--16: CASO 16	CAN/ROB/EXT/FAL		NOA/NOE		CON informacion en intercard:tarjetacuenta y SIN informacion en bdicred:sd_tarjeta/sd_maecred
	--17: CASO 17	CAN/ROB/EXT/FAL		SIA			SIN informacion en intercard:tarjetacuenta y CON informacion en bdicred:sd_tarjeta/sd_maecred
	--20: CASO 20	CAN/ROB/EXT/FAL		SIA			CON informacion en intercard:tarjetacuenta y CON informacion en bdicred:sd_tarjeta/sd_maecred
)
RETURNING CHAR(5) AS outCodigo, VARCHAR(250) AS outMensaje;
	
	-- Variables para manejar error
	DEFINE err_sql				INTEGER;
	DEFINE err_isam				INTEGER;
	DEFINE err_info				CHAR(40);
	
	-- Variable de retorno
	DEFINE vCodigoRetorno		CHAR(5);
	DEFINE vMensaje				VARCHAR(250);
	
	-- Variables para realizar el procesamiento de homologacion
	DEFINE vEstatusTarjeta				CHAR(1);
	DEFINE vCodigoEstatusTarjeta		VARCHAR(3);
	DEFINE vCodigoAsignacionTarjeta		VARCHAR(3);
	DEFINE vNumeroTarjeta				VARCHAR(16);
	DEFINE vNumeroCredito				VARCHAR(12);
	
	DEFINE vContadorCommit				INTEGER;
	DEFINE vFlagTransaccion				CHAR(1);
	
	-- Inicializacion de variable
	LET err_sql		= 0;
	LET err_isam	= 0;
	LET err_info	= '';

	LET vCodigoRetorno	= '00000';
	LET vMensaje 		= 'PROCESO EXITOSO';
	
	LET vEstatusTarjeta				= '';
	LET vCodigoEstatusTarjeta		= '';
	LET vCodigoAsignacionTarjeta	= '';
	LET vNumeroTarjeta				= '';
	LET vNumeroCredito				= '';
	
	LET vContadorCommit				= 1000;
	LET vFlagTransaccion			= 'F';
	
BEGIN
    -- Manejo de errores
    ON EXCEPTION SET err_sql, err_isam, err_info
	
		IF (vFlagTransaccion = 'V') THEN
		
			COMMIT;
			LET vFlagTransaccion = 'F';
			
		END IF;

		IF ( err_sql <> 0 ) THEN
		
			LET vCodigoRetorno	= err_sql;
			LET vMensaje		= 'Error: ' || err_isam || err_info;
		
			RETURN vCodigoRetorno, vMensaje;
			
		END IF;

    END EXCEPTION;

	--SET DEBUG FILE TO "/home/c90311247/homologacion_sp/cc_32_511_cancelacion/pruebas/sp_homologacion_tarjeta_general.out";
	--TRACE ON;
	
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	-- 1: CASO 1	ACT/BLO/BLT			NOA/NOE		SIN informacion en intercard:tarjetacuenta y CON informacion en bdicred:sd_tarjeta/sd_maecred
	IF inNumeroCaso = 1 THEN
	
		BEGIN WORK;
		LET vFlagTransaccion = 'V';
		
		FOREACH WITH HOLD
			SELECT numtarjeta
			INTO vNumeroTarjeta
			FROM intercard:tmp_numtarjeta_homologacion

			IF NOT EXISTS ( SELECT * FROM intercard:tarjetacuenta WHERE numtarjeta = vNumeroTarjeta ) THEN 
			
				SELECT FIRST 1 a.status_tar, a.num_credito
                    INTO vEstatusTarjeta, vNumeroCredito
				FROM bdicred:sd_tarjeta a 
				JOIN bdicred:sd_maecred b
				ON a.num_credito = b.num_credito
                WHERE a.num_tarjeta = vNumeroTarjeta;
				
                IF vEstatusTarjeta IS NOT NULL THEN
				
					SELECT codstatustarjeta,codstatusasignada
                        INTO vCodigoEstatusTarjeta, vCodigoAsignacionTarjeta
                    FROM  intercard:tarjeta
                    WHERE numtarjeta = vNumeroTarjeta;

                    IF vCodigoEstatusTarjeta IN ( 'ACT', 'BLO', 'BLT' ) AND vCodigoAsignacionTarjeta IN ( 'NOE', 'NOA' )  THEN

						UPDATE intercard:tarjeta 
						SET codstatustarjeta = 'CAN', fechaultmodif = CURRENT, usuarioultmodif = 'systarjetas'
						WHERE numtarjeta = vNumeroTarjeta;
						
						INSERT INTO intercard:tarjetacuenta(numcuenta,numtarjeta)
						VALUES (vNumeroCredito, vNumeroTarjeta);
						
						IF vEstatusTarjeta <> 'C' THEN
							UPDATE bdicred:sd_tarjeta 
							SET status_tar = 'C' 
							WHERE num_tarjeta = vNumeroTarjeta;
						END IF;

						INSERT INTO intercard:tmp_modificacion_homologacion(numtarjeta, codstatustarjeta, codstatusasignada, status_tar )
						VALUES (vNumeroTarjeta, vCodigoEstatusTarjeta, vCodigoAsignacionTarjeta, vEstatusTarjeta);
						
						LET vContadorCommit = vContadorCommit + 1;
						
						IF vContadorCommit = 1000 THEN
							COMMIT;
							LET vFlagTransaccion = 'F';
							LET vContadorCommit = 0;
							BEGIN WORK;
							LET vFlagTransaccion = 'V';
						END IF;
						
					END IF;
				END IF;
			END IF;	
		END FOREACH;

        COMMIT;
		LET vFlagTransaccion = 'F';
	END IF;
	
	-- 2: CASO 2	ACT/BLO/BLT			NOA/NOE 	SIN informacion en intercard:tarjetacuenta y SIN informacion en bdicred:sd_tarjeta/sd_maecred
	IF inNumeroCaso = 2 THEN
	
		BEGIN WORK;
		LET vFlagTransaccion = 'V';
		
		FOREACH WITH HOLD
			SELECT numtarjeta
			INTO vNumeroTarjeta
			FROM intercard:tmp_numtarjeta_homologacion

			IF NOT EXISTS ( SELECT * FROM intercard:tarjetacuenta WHERE numtarjeta = vNumeroTarjeta ) THEN 
			
				SELECT FIRST 1 a.status_tar, a.num_credito
					INTO vEstatusTarjeta, vNumeroCredito
				FROM bdicred:sd_tarjeta a 
				JOIN bdicred:sd_maecred b
				ON a.num_credito = b.num_credito
				WHERE a.num_tarjeta = vNumeroTarjeta;
				
				IF vEstatusTarjeta IS NULL THEN
				
					SELECT codstatustarjeta,codstatusasignada
						INTO vCodigoEstatusTarjeta, vCodigoAsignacionTarjeta
					FROM  intercard:tarjeta
					WHERE numtarjeta = vNumeroTarjeta;

					IF vCodigoEstatusTarjeta IN ( 'ACT', 'BLO', 'BLT' ) AND vCodigoAsignacionTarjeta IN ( 'NOE', 'NOA' )  THEN

						UPDATE intercard:tarjeta 
						SET codstatustarjeta = 'CAN', fechaultmodif = CURRENT, usuarioultmodif = 'systarjetas'
						WHERE numtarjeta = vNumeroTarjeta;
						
						INSERT INTO intercard:tmp_modificacion_homologacion(numtarjeta, codstatustarjeta, codstatusasignada, status_tar )
						VALUES (vNumeroTarjeta, vCodigoEstatusTarjeta, vCodigoAsignacionTarjeta, '');
						
						LET vContadorCommit = vContadorCommit + 1;
						
						IF vContadorCommit = 1000 THEN
							COMMIT;
							LET vFlagTransaccion = 'F';
							LET vContadorCommit = 0;
							BEGIN WORK;
							LET vFlagTransaccion = 'V';
						END IF;
						
					END IF;
				END IF;
			END IF;	
		END FOREACH;

		COMMIT;
		LET vFlagTransaccion = 'F';
	END IF;
	
	-- 3: CASO 3	ACT/BLO/BLT			NOA/NOE 	CON informacion en intercard:tarjetacuenta y CON informacion en bdicred:sd_tarjeta/sd_maecred
	IF inNumeroCaso = 3 THEN
		
		BEGIN WORK;
		LET vFlagTransaccion = 'V';
		
		FOREACH WITH HOLD
			SELECT numtarjeta
			INTO vNumeroTarjeta
			FROM intercard:tmp_numtarjeta_homologacion

			IF EXISTS ( SELECT * FROM intercard:tarjetacuenta WHERE numtarjeta = vNumeroTarjeta ) THEN 
			
				SELECT FIRST 1 a.status_tar, a.num_credito
					INTO vEstatusTarjeta, vNumeroCredito
				FROM bdicred:sd_tarjeta a 
				JOIN bdicred:sd_maecred b
				ON a.num_credito = b.num_credito
				WHERE a.num_tarjeta = vNumeroTarjeta;
				
				IF vEstatusTarjeta IS NOT NULL THEN
				
					SELECT codstatustarjeta,codstatusasignada
                        INTO vCodigoEstatusTarjeta, vCodigoAsignacionTarjeta
                    FROM  intercard:tarjeta
                    WHERE numtarjeta = vNumeroTarjeta;

                    IF vCodigoEstatusTarjeta IN ( 'ACT', 'BLO', 'BLT' ) AND vCodigoAsignacionTarjeta IN ( 'NOE', 'NOA' )  THEN

						UPDATE intercard:tarjeta 
						SET codstatustarjeta = 'CAN', fechaultmodif = CURRENT, usuarioultmodif = 'systarjetas'
						WHERE numtarjeta = vNumeroTarjeta;
						
						IF vEstatusTarjeta <> 'C' THEN
							UPDATE bdicred:sd_tarjeta 
							SET status_tar = 'C' 
							WHERE num_tarjeta = vNumeroTarjeta;
						END IF;

						INSERT INTO intercard:tmp_modificacion_homologacion(numtarjeta, codstatustarjeta, codstatusasignada, status_tar )
						VALUES (vNumeroTarjeta, vCodigoEstatusTarjeta, vCodigoAsignacionTarjeta, vEstatusTarjeta);
						
						LET vContadorCommit = vContadorCommit + 1;
						
						IF vContadorCommit = 1000 THEN
							COMMIT;
							LET vFlagTransaccion = 'F';
							LET vContadorCommit = 0;
							BEGIN WORK;
							LET vFlagTransaccion = 'V';
						END IF;
						
					END IF;
				END IF;
			END IF;	
		END FOREACH;

		COMMIT;
		LET vFlagTransaccion = 'F';
	END IF;

	-- 6: CASO 6	ACT/BLO/BLT			SIA    		CON informacion en intercard:tarjetacuenta y CON informacion en bdicred:sd_tarjeta/sd_maecred
	IF inNumeroCaso = 6 THEN
	
		-- Caso a trabajar en la segunda etapa
	END IF;
	
	-- 9: CASO 9	DAN					NOA/NOE		SIN informacion en intercard:tarjetacuenta y CON informacion en bdicred:sd_tarjeta/sd_maecred
	IF inNumeroCaso = 9 THEN
	
		BEGIN WORK;
		LET vFlagTransaccion = 'V';
		
		FOREACH WITH HOLD
			SELECT numtarjeta
			INTO vNumeroTarjeta
			FROM intercard:tmp_numtarjeta_homologacion

			IF NOT EXISTS ( SELECT * FROM intercard:tarjetacuenta WHERE numtarjeta = vNumeroTarjeta ) THEN 
			
				SELECT FIRST 1 a.status_tar, a.num_credito
                    INTO vEstatusTarjeta, vNumeroCredito
				FROM bdicred:sd_tarjeta a 
				JOIN bdicred:sd_maecred b
				ON a.num_credito = b.num_credito
                WHERE a.num_tarjeta = vNumeroTarjeta;
				
                IF vEstatusTarjeta IS NOT NULL THEN
				
					SELECT codstatustarjeta,codstatusasignada
                        INTO vCodigoEstatusTarjeta, vCodigoAsignacionTarjeta
                    FROM  intercard:tarjeta
                    WHERE numtarjeta = vNumeroTarjeta;

                    IF vCodigoEstatusTarjeta IN ( 'DAN' ) AND vCodigoAsignacionTarjeta IN ( 'NOE', 'NOA' )  THEN

						UPDATE intercard:tarjeta 
						SET codstatustarjeta = 'CAN', fechaultmodif = CURRENT, usuarioultmodif = 'systarjetas'
						WHERE numtarjeta = vNumeroTarjeta;
						
						INSERT INTO intercard:tarjetacuenta(numcuenta,numtarjeta)
						VALUES (vNumeroCredito, vNumeroTarjeta);
						
						IF vEstatusTarjeta <> 'C' THEN
							UPDATE bdicred:sd_tarjeta 
							SET status_tar = 'C' 
							WHERE num_tarjeta = vNumeroTarjeta;
						END IF;

						INSERT INTO intercard:tmp_modificacion_homologacion(numtarjeta, codstatustarjeta, codstatusasignada, status_tar )
						VALUES (vNumeroTarjeta, vCodigoEstatusTarjeta, vCodigoAsignacionTarjeta, vEstatusTarjeta);
						
						LET vContadorCommit = vContadorCommit + 1;
						
						IF vContadorCommit = 1000 THEN
							COMMIT;
							LET vFlagTransaccion = 'F';
							LET vContadorCommit = 0;
							BEGIN WORK;
							LET vFlagTransaccion = 'V';
						END IF;
						
					END IF;
				END IF;
			END IF;	
		END FOREACH;

        COMMIT;
		LET vFlagTransaccion = 'F';
	END IF;
	
	--10: CASO 10	DAN					NOA/NOE		SIN informacion en intercard:tarjetacuenta y SIN informacion en bdicred:sd_tarjeta/sd_maecred con registro de numero de cliente en intercard:tarjeta
	IF inNumeroCaso = 10 THEN
	
		BEGIN WORK;
		LET vFlagTransaccion = 'V';
		
		FOREACH WITH HOLD
			SELECT numtarjeta
			INTO vNumeroTarjeta
			FROM intercard:tmp_numtarjeta_homologacion

			IF NOT EXISTS ( SELECT * FROM intercard:tarjetacuenta WHERE numtarjeta = vNumeroTarjeta ) THEN 
			
				SELECT FIRST 1 a.status_tar, a.num_credito
                    INTO vEstatusTarjeta, vNumeroCredito
				FROM bdicred:sd_tarjeta a 
				JOIN bdicred:sd_maecred b
				ON a.num_credito = b.num_credito
                WHERE a.num_tarjeta = vNumeroTarjeta;
				
                IF vEstatusTarjeta IS NULL THEN
				
					SELECT codstatustarjeta,codstatusasignada
                        INTO vCodigoEstatusTarjeta, vCodigoAsignacionTarjeta
                    FROM  intercard:tarjeta
                    WHERE numtarjeta = vNumeroTarjeta;

                    IF vCodigoEstatusTarjeta IN ( 'DAN' ) AND vCodigoAsignacionTarjeta IN ( 'NOE', 'NOA' )  THEN

						UPDATE intercard:tarjeta 
						SET codstatustarjeta = 'CAN', fechaultmodif = CURRENT, usuarioultmodif = 'systarjetas'
						WHERE numtarjeta = vNumeroTarjeta;

						INSERT INTO intercard:tmp_modificacion_homologacion(numtarjeta, codstatustarjeta, codstatusasignada, status_tar )
						VALUES (vNumeroTarjeta, vCodigoEstatusTarjeta, vCodigoAsignacionTarjeta, '');
						
						LET vContadorCommit = vContadorCommit + 1;
						
						IF vContadorCommit = 1000 THEN
							COMMIT;
							LET vFlagTransaccion = 'F';
							LET vContadorCommit = 0;
							BEGIN WORK;
							LET vFlagTransaccion = 'V';
						END IF;
						
					END IF;
				END IF;
			END IF;	
		END FOREACH;

        COMMIT;
		LET vFlagTransaccion = 'F';
	END IF;
	
	--13: CASO 13	CAN/ROB/EXT/FAL		NOA/NOE		SIN informacion en intercard:tarjetacuenta y CON informacion en bdicred:sd_tarjeta/sd_maecred
	IF inNumeroCaso = 13 THEN
	
		BEGIN WORK;
		LET vFlagTransaccion = 'V';
		
		FOREACH WITH HOLD
			SELECT numtarjeta
			INTO vNumeroTarjeta
			FROM intercard:tmp_numtarjeta_homologacion

			IF NOT EXISTS ( SELECT * FROM intercard:tarjetacuenta WHERE numtarjeta = vNumeroTarjeta ) THEN 
			
				SELECT FIRST 1 a.status_tar, a.num_credito
                    INTO vEstatusTarjeta, vNumeroCredito
				FROM bdicred:sd_tarjeta a 
				JOIN bdicred:sd_maecred b
				ON a.num_credito = b.num_credito
                WHERE a.num_tarjeta = vNumeroTarjeta;
				
                IF vEstatusTarjeta IS NOT NULL THEN
				
					SELECT codstatustarjeta,codstatusasignada
                        INTO vCodigoEstatusTarjeta, vCodigoAsignacionTarjeta
                    FROM  intercard:tarjeta
                    WHERE numtarjeta = vNumeroTarjeta;

                    IF vCodigoEstatusTarjeta IN ( 'CAN', 'ROB', 'EXT', 'FAL' ) AND vCodigoAsignacionTarjeta IN ( 'NOE', 'NOA' )  THEN
						
						INSERT INTO intercard:tarjetacuenta(numcuenta,numtarjeta)
						VALUES (vNumeroCredito, vNumeroTarjeta);
						
						-- En este caso se supone que las TDC estan canceladas, sin embargo, se deja la valdiacion
						IF vEstatusTarjeta <> 'C' THEN
							UPDATE bdicred:sd_tarjeta 
							SET status_tar = 'C' 
							WHERE num_tarjeta = vNumeroTarjeta;
						END IF;

						INSERT INTO intercard:tmp_modificacion_homologacion(numtarjeta, codstatustarjeta, codstatusasignada, status_tar )
						VALUES (vNumeroTarjeta, vCodigoEstatusTarjeta, vCodigoAsignacionTarjeta, vEstatusTarjeta);
						
						LET vContadorCommit = vContadorCommit + 1;
						
						IF vContadorCommit = 1000 THEN
							COMMIT;
							LET vFlagTransaccion = 'F';
							LET vContadorCommit = 0;
							BEGIN WORK;
							LET vFlagTransaccion = 'V';
						END IF;
						
					END IF;
				END IF;
			END IF;	
		END FOREACH;

        COMMIT;
		LET vFlagTransaccion = 'F';
	END IF;
	
	--16: CASO 16	CAN/ROB/EXT/FAL		NOA/NOE		CON informacion en intercard:tarjetacuenta y SIN informacion en bdicred:sd_tarjeta/sd_maecred
	IF (inNumeroCaso = 16) THEN
		
		-- Caso a trabajar en la segunda etapa
	END IF;
	
	--17: CASO 17	CAN/ROB/EXT/FAL		SIA			SIN informacion en intercard:tarjetacuenta y CON informacion en bdicred:sd_tarjeta/sd_maecred
	IF inNumeroCaso = 17 THEN
	
		BEGIN WORK;
		LET vFlagTransaccion = 'V';
		
		FOREACH WITH HOLD
			SELECT numtarjeta
			INTO vNumeroTarjeta
			FROM intercard:tmp_numtarjeta_homologacion

			IF NOT EXISTS ( SELECT * FROM intercard:tarjetacuenta WHERE numtarjeta = vNumeroTarjeta ) THEN 
			
				SELECT FIRST 1 a.status_tar, a.num_credito
                    INTO vEstatusTarjeta, vNumeroCredito
				FROM bdicred:sd_tarjeta a 
				JOIN bdicred:sd_maecred b
				ON a.num_credito = b.num_credito
                WHERE a.num_tarjeta = vNumeroTarjeta;
				
                IF vEstatusTarjeta IS NOT NULL THEN
				
					SELECT codstatustarjeta,codstatusasignada
                        INTO vCodigoEstatusTarjeta, vCodigoAsignacionTarjeta
                    FROM  intercard:tarjeta
                    WHERE numtarjeta = vNumeroTarjeta;

                    IF vCodigoEstatusTarjeta IN ( 'CAN', 'ROB', 'EXT', 'FAL' ) AND vCodigoAsignacionTarjeta IN ( 'SIA' )  THEN
						
						INSERT INTO intercard:tarjetacuenta(numcuenta,numtarjeta)
						VALUES (vNumeroCredito, vNumeroTarjeta);
						
						-- En este caso se supone que las TDC estan canceladas, sin embargo, se deja la valdiacion
						IF vEstatusTarjeta <> 'C' THEN
							UPDATE bdicred:sd_tarjeta 
							SET status_tar = 'C' 
							WHERE num_tarjeta = vNumeroTarjeta;
						END IF;

						INSERT INTO intercard:tmp_modificacion_homologacion(numtarjeta, codstatustarjeta, codstatusasignada, status_tar )
						VALUES (vNumeroTarjeta, vCodigoEstatusTarjeta, vCodigoAsignacionTarjeta, vEstatusTarjeta);
						
						LET vContadorCommit = vContadorCommit + 1;
						
						IF vContadorCommit = 1000 THEN
							COMMIT;
							LET vFlagTransaccion = 'F';
							LET vContadorCommit = 0;
							BEGIN WORK;
							LET vFlagTransaccion = 'V';
						END IF;
						
					END IF;
				END IF;
			END IF;	
		END FOREACH;

        COMMIT;
		LET vFlagTransaccion = 'F';
	END IF;
	
	--20: CASO 20	CAN/ROB/EXT/FAL		SIA			CON informacion en intercard:tarjetacuenta y CON informacion en bdicred:sd_tarjeta/sd_maecred
	IF (inNumeroCaso = 20) THEN
	
		-- Caso a trabajar en la segunda etapa
		
	END IF;

	RETURN vCodigoRetorno, vMensaje;

END;
END PROCEDURE;
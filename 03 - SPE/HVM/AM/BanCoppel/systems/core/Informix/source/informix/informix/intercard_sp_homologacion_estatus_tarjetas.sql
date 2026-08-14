CREATE PROCEDURE "informix".sp_homologacion_estatus_tarjetas(
    opcionTabla INTEGER ---  Tipo de caso para canelacion en intercard (1), bdicred (2) o bdicheq (3)
)
RETURNING CHAR(5) AS oCodigoRetorno, VARCHAR(250) AS oMensaje;

	-- Variables de Retorno
	DEFINE vstatus_proc     CHAR(1);
	DEFINE vcod_ret         VARCHAR(10);
	DEFINE sql_err          INTEGER;
	DEFINE isam_err         INTEGER;
	DEFINE error_info       CHAR(40);
	
	DEFINE vCodigoRetorno   CHAR(5);
	DEFINE vMensaje             VARCHAR(250);
	DEFINE ReturnValue      CHAR(1);
	
	DEFINE v_sql            CHAR(250);
	
	DEFINE Contador_commit	SMALLINT;
	DEFINE vFlagTransaccion	CHAR(1);
	
	DEFINE var_status_tar           CHAR(1);
	DEFINE var_codstatustarjeta     VARCHAR(3);
	DEFINE var_codstatusasignada    VARCHAR(3);
	DEFINE var_numtarjeta           VARCHAR(16);
	
	DEFINE validaciontarjetacuencta INTEGER;
	
	DEFINE vExecuteSQL      	CHAR(250);
	DEFINE nomRut           	CHAR(250);
	DEFINE nomArch          	CHAR(250);
	DEFINE vNombreCompTXT   	CHAR(250);
	DEFINE vNombreCompLog   	CHAR(250);
	DEFINE vNombreEjecucionLog  CHAR(250);

    -- MANEJO DEL ERROR
    ON EXCEPTION SET sql_err, isam_err, error_info
		
		DROP TABLE IF EXISTS intercard:temp_cancelacionparahomologacion;
		
		IF (vFlagTransaccion = 'V') THEN
			COMMIT;
			LET vFlagTransaccion = 'F';
		END IF;
		
		IF ( sql_err <> 0 ) THEN
			LET vCodigoRetorno = sql_err;
			LET vMensaje = 'Error:  '|| isam_err || error_info;
		
			RETURN vCodigoRetorno, vMensaje;
		END IF;

    END EXCEPTION;

    --SET DEBUG FILE TO "/RESPALDOSNEW/sp_cancelacion_homologacion.out";
    --TRACE ON;

	-- Definicion de variables
	LET vstatus_proc		= '';
	LET vcod_ret			= '000';
	LET sql_err				= 0;
	LET isam_err			= 0;
	LET error_info			= '';
	LET ReturnValue			= "0";
	
	LET nomRut				= '/RESPALDOSNEW/';
	LET vNombreCompTXT		= 'paso1.txt';
	LET vNombreCompLog		= 'paso1.log';
	LET vNombreEjecucionLog	= 'paso1_rep.log';
	
	LET Contador_commit		= 0;
	LET vFlagTransaccion	= 'F';

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    CREATE TABLE IF NOT EXISTS intercard:temp_cancelacionparahomologacion(
        numtarjeta			CHAR(16),
        codstatustarjeta	VARCHAR(3),
        codstatusasignada	VARCHAR(3),
        status_tar			CHAR(1)
    );

    TRUNCATE TABLE intercard:temp_cancelacionparahomologacion;
    
	-- Homologacion de estatus de tarjetas de debito y credito dada su cancelacion en intercard
	
    -- Homologacion en la Base de Datos bdicheq:sc_tarjeta (debito)
    IF(opcionTabla = 1) THEN
		LET nomArch = 'tarjetas_debito_bdicheq.unl';

		LET vExecuteSQL = '';
		LET vExecuteSQL = "echo "||'"'|| "FILE '" || TRIM(nomRut) || TRIM(nomArch) || "' delimiter '" || '|' || "' " || '4' || "; INSERT INTO "|| 'temp_cancelacionparahomologacion' || ";" || '"' || ' > '|| TRIM(nomRut) || TRIM(vNombreCompTXT);
		SYSTEM vExecuteSQL;

		LET vExecuteSQL = '';
		LET vExecuteSQL = "chmod 777 " || TRIM(nomRut) || TRIM(vNombreCompTXT);
		SYSTEM vExecuteSQL;

		LET vExecuteSQL = '';
		LET vExecuteSQL = "dbload -d intercard -c " || TRIM(nomRut) || TRIM(vNombreCompTXT) || " -l " || TRIM(nomRut) || TRIM(vNombreCompLog) || " -n " || 1000 || " -r > " || TRIM(nomRut) || TRIM(vNombreEjecucionLog);
		SYSTEM vExecuteSQL;

		LET vExecuteSQL = '';
		LET vExecuteSQL = "chmod 777 /RESPALDOSNEW/" || TRIM(vNombreCompLog);
		SYSTEM vExecuteSQL;

		LET vExecuteSQL = '';
		LET vExecuteSQL = "chmod 777 /RESPALDOSNEW/" || TRIM(vNombreEjecucionLog);
		SYSTEM vExecuteSQL;

		LET vExecuteSQL = '';
		LET vExecuteSQL = "rm -r /RESPALDOSNEW/" || TRIM(vNombreCompTXT);
		SYSTEM vExecuteSQL;

		LET vExecuteSQL = '';
		LET vExecuteSQL = "rm -r /RESPALDOSNEW/" || TRIM(vNombreCompLog);
		SYSTEM vExecuteSQL;

		LET vExecuteSQL = '';
		LET vExecuteSQL = "rm -r /RESPALDOSNEW/" || TRIM(vNombreEjecucionLog);
		SYSTEM vExecuteSQL;

		LET vExecuteSQL = '';

		LET vFlagTransaccion = 'V';
		
        BEGIN WORK;
            FOREACH WITH HOLD
                SELECT numtarjeta
                    INTO var_numtarjeta
                FROM intercard:temp_cancelacionparahomologacion

                SELECT FIRST 1 a.status_tar
                    INTO var_status_tar
                FROM bdicheq:sc_tarjeta a
				JOIN bdicheq:sc_maechq b
				ON a.cuenta = b.cuenta
                WHERE a.num_tarjeta = var_numtarjeta;

                IF var_status_tar = 'A' THEN

                    SELECT codstatustarjeta
                        INTO var_codstatustarjeta
                    FROM  intercard:tarjeta
                    WHERE numtarjeta = var_numtarjeta;

                    IF var_codstatustarjeta IN ('CAN', 'FAL', 'ROB','EXT','DAN') THEN

						UPDATE bdicheq:sc_tarjeta SET status_tar = 'C' WHERE num_tarjeta = var_numtarjeta;
						
						LET Contador_commit = Contador_commit + 1;
						
						IF Contador_commit = 1000 THEN
							COMMIT;
							LET vFlagTransaccion = 'F';
							LET Contador_commit = 0;
							BEGIN WORK;
							LET vFlagTransaccion = 'V';
						END IF;

                    END IF;

                END IF;
				
            END FOREACH;

        COMMIT;
		
		LET vFlagTransaccion = 'F';

    END IF;

    -- Homologacion en la Base de Datos bdicred:sd_tarjeta (credito)
    IF(opcionTabla = 2) THEN
		LET nomArch = 'tarjetas_credito_bdicred.unl';
		
		LET vExecuteSQL = '';
		LET vExecuteSQL = "echo "||'"'|| "FILE '" || TRIM(nomRut) || TRIM(nomArch) || "' delimiter '" || '|' || "' " || '4' || "; INSERT INTO "|| 'temp_cancelacionparahomologacion' || ";" || '"' || ' > '|| TRIM(nomRut) || TRIM(vNombreCompTXT);
		SYSTEM vExecuteSQL;

		LET vExecuteSQL = '';
		LET vExecuteSQL = "chmod 777 " || TRIM(nomRut) || TRIM(vNombreCompTXT);
		SYSTEM vExecuteSQL;

		LET vExecuteSQL = '';
		LET vExecuteSQL = "dbload -d intercard -c " || TRIM(nomRut) || TRIM(vNombreCompTXT) || " -l " || TRIM(nomRut) || TRIM(vNombreCompLog) || " -n " || 1000 || " -r > " || TRIM(nomRut) || TRIM(vNombreEjecucionLog);
		SYSTEM vExecuteSQL;

		LET vExecuteSQL = '';
		LET vExecuteSQL = "chmod 777 /RESPALDOSNEW/" || TRIM(vNombreCompLog);
		SYSTEM vExecuteSQL;

		LET vExecuteSQL = '';
		LET vExecuteSQL = "chmod 777 /RESPALDOSNEW/" || TRIM(vNombreEjecucionLog);
		SYSTEM vExecuteSQL;

		LET vExecuteSQL = '';
		LET vExecuteSQL = "rm -r /RESPALDOSNEW/" || TRIM(vNombreCompTXT);
		SYSTEM vExecuteSQL;

		LET vExecuteSQL = '';
		LET vExecuteSQL = "rm -r /RESPALDOSNEW/" || TRIM(vNombreCompLog);
		SYSTEM vExecuteSQL;

		LET vExecuteSQL = '';
		LET vExecuteSQL = "rm -r /RESPALDOSNEW/" || TRIM(vNombreEjecucionLog);
		SYSTEM vExecuteSQL;

		LET vExecuteSQL = '';
		
		LET vFlagTransaccion = 'V';
		
        BEGIN WORK;
        
			FOREACH WITH HOLD
				SELECT numtarjeta
					INTO var_numtarjeta
				FROM intercard:temp_cancelacionparahomologacion
			
				SELECT FIRST 1 a.status_tar
					INTO var_status_tar
				FROM bdicred:sd_tarjeta a
				JOIN bdicred:sd_maecred b
				ON a.num_credito = b.num_credito
				WHERE a.num_tarjeta = var_numtarjeta;

				IF var_status_tar = 'A' THEN

					SELECT codstatustarjeta
					INTO var_codstatustarjeta
					FROM  intercard:tarjeta
					WHERE numtarjeta = var_numtarjeta;

					IF var_codstatustarjeta IN ('CAN', 'FAL', 'ROB','EXT','DAN') THEN

						UPDATE bdicred:sd_tarjeta SET status_tar = 'C' WHERE num_tarjeta = var_numtarjeta;  
						
						LET Contador_commit = Contador_commit + 1;

						IF Contador_commit = 1000 THEN
							COMMIT;
							LET vFlagTransaccion = 'F';
							LET Contador_commit = 0;
							BEGIN WORK;
							LET vFlagTransaccion = 'V';
						END IF;
						
					END IF;
					
				END IF;
			
			END FOREACH;

        COMMIT;

		LET vFlagTransaccion = 'F';
		
	END IF;

    -- Homologacion en la Base de Datos intercard:tarjeta (debito)
	IF(opcionTabla = 3) THEN

		LET vExecuteSQL = '';
		LET vExecuteSQL = "echo "||'"'|| "FILE '/RESPALDOSNEW/tarjetas_debito_intercard.unl' delimiter '"|| '|' ||"' "|| '4'|| "; INSERT INTO "|| 'temp_cancelacionparahomologacion' || ";"||'"'||' > '|| '/RESPALDOSNEW/paso1.txt';
		SYSTEM vExecuteSQL;

		LET vExecuteSQL = '';
		LET vExecuteSQL = "chmod 777 /RESPALDOSNEW/paso1.txt";
		SYSTEM vExecuteSQL;

		LET vExecuteSQL = '';
		LET vExecuteSQL = "dbload -d intercard -c " || '/RESPALDOSNEW/paso1.txt' || " -l " || '/RESPALDOSNEW/paso1.log' || " -n " || 1000 ||" -r > "|| '/RESPALDOSNEW/paso1_rep.log';
		SYSTEM vExecuteSQL;

		LET vExecuteSQL = '';
		LET vExecuteSQL = "chmod 777 /RESPALDOSNEW/" || TRIM(vNombreCompLog);
		SYSTEM vExecuteSQL;

		LET vExecuteSQL = '';
		LET vExecuteSQL = "chmod 777 /RESPALDOSNEW/" || TRIM(vNombreEjecucionLog);
		SYSTEM vExecuteSQL;

		LET vExecuteSQL = '';
		LET vExecuteSQL = "rm -r /RESPALDOSNEW/" || TRIM(vNombreCompTXT);
		SYSTEM vExecuteSQL;

		LET vExecuteSQL = '';
		LET vExecuteSQL = "rm -r /RESPALDOSNEW/" || TRIM(vNombreCompLog);
		SYSTEM vExecuteSQL;

		LET vExecuteSQL = '';
		LET vExecuteSQL = "rm -r /RESPALDOSNEW/" || TRIM(vNombreEjecucionLog);
		SYSTEM vExecuteSQL;

		LET vExecuteSQL = '';

		LET vFlagTransaccion = 'V';
		
        BEGIN WORK;
            FOREACH WITH HOLD
				SELECT numtarjeta
					INTO var_numtarjeta
				FROM intercard:temp_cancelacionparahomologacion

                SELECT FIRST 1 a.status_tar
					INTO var_status_tar
                FROM bdicheq:sc_tarjeta a
				JOIN bdicheq:sc_maechq b
				ON a.cuenta = b.cuenta
                WHERE a.num_tarjeta = var_numtarjeta;

                IF var_status_tar = 'C' THEN

                    SELECT codstatustarjeta
					INTO var_codstatustarjeta
					FROM  intercard:tarjeta
					WHERE numtarjeta = var_numtarjeta;

                    IF var_codstatustarjeta in ('ACT', 'BLO', 'BLT') THEN

						LET Contador_commit = Contador_commit + 1;

						SELECT COUNT(numcuenta)
						INTO validaciontarjetacuencta
						FROM intercard:tarjetacuenta
						WHERE numtarjeta = var_numtarjeta;

						IF validaciontarjetacuencta = 1 THEN

                            UPDATE intercard:tarjeta
							SET codstatustarjeta = 'CAN', fechaultmodif = CURRENT, usuarioultmodif = 'intercar', numtarjeta = NVL(numtarjeta, ''), numcliente = NVL(numcliente, '') , titular = NVL(titular, '')
							WHERE numtarjeta = var_numtarjeta;

							IF Contador_commit = 1000 THEN
								COMMIT;
								LET vFlagTransaccion = 'F';
								LET Contador_commit = 0;
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

    -- Homologacion en la Base de Datos intercard:tarjeta (credito)
    IF(opcionTabla = 4) THEN

		LET vExecuteSQL = '';
		LET vExecuteSQL = "echo "||'"'|| "FILE '/RESPALDOSNEW/tarjetas_credito_intercard.unl' delimiter '"|| '|' ||"' "|| '4'|| "; INSERT INTO "|| 'temp_cancelacionparahomologacion' || ";"||'"'||' > '|| '/RESPALDOSNEW/paso1.txt';
		SYSTEM vExecuteSQL;
		
		LET vExecuteSQL = '';
		LET vExecuteSQL = "chmod 777 /RESPALDOSNEW/paso1.txt";
		SYSTEM vExecuteSQL;
		
		LET vExecuteSQL = '';
		LET vExecuteSQL = "dbload -d intercard -c " || '/RESPALDOSNEW/paso1.txt' || " -l " || '/RESPALDOSNEW/paso1.log' || " -n " || 1000 ||" -r > "|| '/RESPALDOSNEW/paso1_rep.log';
		SYSTEM vExecuteSQL;
		
		LET vExecuteSQL = '';
		LET vExecuteSQL = "chmod 777 /RESPALDOSNEW/" || TRIM(vNombreCompLog);
		SYSTEM vExecuteSQL;

		LET vExecuteSQL = '';
		LET vExecuteSQL = "chmod 777 /RESPALDOSNEW/" || TRIM(vNombreEjecucionLog);
		SYSTEM vExecuteSQL;

		LET vExecuteSQL = '';
		LET vExecuteSQL = "rm -r /RESPALDOSNEW/" || TRIM(vNombreCompTXT);
		SYSTEM vExecuteSQL;

		LET vExecuteSQL = '';
		LET vExecuteSQL = "rm -r /RESPALDOSNEW/" || TRIM(vNombreCompLog);
		SYSTEM vExecuteSQL;

		LET vExecuteSQL = '';
		LET vExecuteSQL = "rm -r /RESPALDOSNEW/" || TRIM(vNombreEjecucionLog);
		SYSTEM vExecuteSQL;

        LET vExecuteSQL = '';
		
		LET vFlagTransaccion = 'V';

        BEGIN WORK;
			FOREACH WITH HOLD
				SELECT numtarjeta
				INTO var_numtarjeta
				FROM intercard:temp_cancelacionparahomologacion

                SELECT FIRST 1 a.status_tar
				INTO var_status_tar
				FROM bdicred:sd_tarjeta a
				JOIN bdicred:sd_maecred b
				ON a.num_credito = b.num_credito
				WHERE a.num_tarjeta = var_numtarjeta;

				IF var_status_tar = 'C' THEN

					SELECT codstatustarjeta
					INTO var_codstatustarjeta
					FROM  intercard:tarjeta
					WHERE numtarjeta = var_numtarjeta;

					IF var_codstatustarjeta IN ('ACT', 'BLO', 'BLT') THEN

						LET Contador_commit = Contador_commit + 1;

						SELECT COUNT(numcuenta)
						INTO validaciontarjetacuencta
						FROM intercard:tarjetacuenta
						WHERE numtarjeta = var_numtarjeta;

						IF validaciontarjetacuencta = 1 THEN

							UPDATE intercard:tarjeta
							SET codstatustarjeta = 'CAN', fechaultmodif = CURRENT, usuarioultmodif = 'intercar', numtarjeta = NVL(numtarjeta, ''), numcliente = NVL(numcliente, '') , titular = NVL(titular, '')
							WHERE numtarjeta = var_numtarjeta;

							IF Contador_commit = 1000 THEN
								COMMIT;
								LET vFlagTransaccion = 'F';
								LET Contador_commit = 0;
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
	
	DROP TABLE IF EXISTS intercard:temp_cancelacionparahomologacion;

	LET vCodigoRetorno = "00000";
	LET vMensaje = "Proceso completado";

	RETURN vCodigoRetorno, vMensaje;

END PROCEDURE;
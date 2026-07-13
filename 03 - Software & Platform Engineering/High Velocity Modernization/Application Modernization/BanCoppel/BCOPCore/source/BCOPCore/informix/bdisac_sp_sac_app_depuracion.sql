CREATE PROCEDURE "informix".sp_sac_app_depuracion(pfecharepor DATE)

	RETURNING CHAR(5), VARCHAR(200), VARCHAR(200), VARCHAR(200);


		--Definicion de Variables
    DEFINE cCodRet          	CHAR(5);
    DEFINE iSqlErr				INTEGER;
	DEFINE iIsamErr 			INTEGER;
    DEFINE cInfoErr         	CHAR(100);
	DEFINE cMensaje				VARCHAR(200);
	DEFINE cMensaje2			VARCHAR(200);
	DEFINE cMensaje3			VARCHAR(200);
	DEFINE cRutaArch 			CHAR(100);
	DEFINE cStmt 				CHAR (500);
	DEFINE cConteoPayi          VARCHAR(50);
	DEFINE cConteoQryi          VARCHAR(50);
	DEFINE cConteoGetorder 		VARCHAR(50);
	DEFINE cConteoRecordorder   VARCHAR(50);
	DEFINE cConteoConfpayment   VARCHAR(50);
	DEFINE cConteoRevi			VARCHAR(50);
	DEFINE cConteoCcta			VARCHAR(50);
	DEFINE cFecha_proceso 	    DATE;

	DEFINE cDiasRespaldos 	    INTEGER;

	DEFINE cConteo  	     	INTEGER;
	DEFINE cConteo2  	     	INTEGER;
	DEFINE cConteo3  	     	INTEGER;
	
	DEFINE cNo_row			    VARCHAR(50);
	DEFINE cFh					DATETIME YEAR to FRACTION(5);
	DEFINE cConteo4  	     	INTEGER;
	DEFINE vtransaccion	   		SMALLINT;

	
	
	--SET DEBUG FILE TO '/tmp/sp_sac_app_depuracion.out';
	--TRACE ON; 
	--SET DEBUG FILE TO '/INFORMIXTMP/HMLG/sp_sac_app_depuracion.out';
	--TRACE ON;
	--SET DEBUG FILE TO '/informix/ENP/sp_sac_app_depuracion.out';
	--TRACE ON;
	
	-- Inicializa variables
	LET cCodRet            		= "00000";
	LET cMensaje				= "Proceso Exitoso|";
	LET cMensaje2				= '';
	LET cMensaje3				= '';
	LET cFecha_proceso 			= MDY('01','01','1900');


	LET cConteo 	= 0;
	LET cConteo2 	= 0;
	LET cConteo3 	= 0;
	LET cConteoPayi = '0';
	LET cConteoQryi = '0';
	LET cConteoGetorder = '0';
	LET cConteoRecordorder = '0';
	LET cConteoConfpayment = '0';
	LET cConteoRevi = '0';
	LET cConteoCcta = '0';
	LET cDiasRespaldos = 0;
	
	LET cNo_row				= '';
	LET cFh	 			= MDY('01','01','1900');
	LET cConteo4 	= 0;
	LET vtransaccion 	= 0;

	LET cStmt = '';
	LET cRutaArch = '';
	
	LET cFecha_proceso = today;

	BEGIN
	
		ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
			--Manejo de errores, en caso de error, envÃ­o codigo de error y guarda evidencia
            IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;
                EXECUTE PROCEDURE bdisac:"informix".sp_sac_guardamensajeerror(iSqlErr, iIsamErr, cInfoErr, "sp_sac_app_depuracion");
								
				LET cMensaje = "ERROR EN LA EJECUCION DEL SP BDD";
				LET cMensaje2 = 'Fecha|Payi|Qryi|GetOrder|RecOrder|ConfPaymnt|Revi|WsCcta|';
				LET cMensaje3 = cFecha_proceso||'|'||cConteoPayi||"|"||cConteoQryi||"|"||cConteoGetorder||"|"||cConteoRecordorder||"|"||cConteoConfpayment||"|"||cConteoRevi||"|"||cConteoCcta||"|";
		
				
                RETURN cCodRet,cMensaje,cMensaje2,cMensaje3;
            END IF;
        END EXCEPTION;
		
		ON EXCEPTION IN (-535)
			COMMIT WORK;
		END EXCEPTION WITH RESUME;
		
		-- IF vtransaccion = 1 THEN
			-- COMMIT WORK;
			-- BEGIN WORK;
		-- ELSE
			-- BEGIN WORK;
		-- END IF;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
	
		--DIAS PARA MIGRACION A PROCESOS HISTORICOS
		
		SELECT valor 
		INTO cDiasRespaldos
		FROM sac_param
		WHERE cod_param = 139;
		
		IF cDiasRespaldos IS NULL OR cDiasRespaldos = 0 THEN 
			LET cDiasRespaldos = 95;
		END IF;
		
		
	/*DEPURACION sac_app_payi*/
		
		LET cConteo = 0;
				
		SELECT COUNT(*)
		INTO cConteo
		FROM sac_app_payi 
		WHERE fecha <= EXTEND((today - cDiasRespaldos), YEAR to SECOND)+24 UNITS HOUR+60 UNITS MINUTE+60 UNITS SECOND;
		
		IF cConteo IS NULL THEN 
			LET cConteo = 0;
		END IF;
		
		IF cConteo <> 0 THEN 
			DROP TABLE IF EXISTS tmp_sac_app_payi_621028;
			DROP TABLE IF EXISTS tmp_sac_app_payi_621028_2;
			LET cStmt = 'rm -f /RESPALDOSNEW/tmp_sac_app_payi_621028.sql';
			SYSTEM cStmt;
			LET cStmt = 'rm -f /RESPALDOSNEW/tmp_sac_app_payi_621028_up.sql';
			SYSTEM cStmt;
			LET cStmt = 'rm -f /RESPALDOSNEW/tmp_sac_app_payi_621028_up2.sql';
			SYSTEM cStmt;
			LET cStmt = 'rm -f /RESPALDOSNEW/tmp_sac_app_payi_621028.unl';
			SYSTEM cStmt;
			LET cStmt = 'rm -f /RESPALDOSNEW/tmp_sac_app_payi_621028_up.log';
			SYSTEM cStmt;
			LET cStmt = 'rm -f /RESPALDOSNEW/tmp_sac_app_payi_621028_up2.log';
			SYSTEM cStmt;
			
			
			SELECT *
			FROM sac_app_payi 
			WHERE fecha <= EXTEND((today - cDiasRespaldos), YEAR to SECOND)+24 UNITS HOUR+60 UNITS MINUTE+60 UNITS SECOND
			INTO tmp_sac_app_payi_621028;
			
			
			LET cStmt = 'echo "UNLOAD TO /RESPALDOSNEW/tmp_sac_app_payi_621028.unl SELECT * FROM tmp_sac_app_payi_621028;">/RESPALDOSNEW/tmp_sac_app_payi_621028.sql';
			SYSTEM cStmt;
			
			
			LET cStmt = 'chmod 777 /RESPALDOSNEW/tmp_sac_app_payi_621028.sql';
			SYSTEM cStmt;
						
			LET cStmt= 'dbaccess bdisac	/RESPALDOSNEW/tmp_sac_app_payi_621028.sql';
			SYSTEM cStmt;
			
			LET cStmt = 'chmod 777 /RESPALDOSNEW/tmp_sac_app_payi_621028.unl';
			SYSTEM cStmt;
			
			
			--LET cStmt = 'echo "LOAD FROM /RESPALDOSNEW/tmp_sac_app_payi_621028.unl INSERT INTO sac_app_payi_old;">/RESPALDOSNEW/tmp_sac_app_payi_621028_up.sql';
			--SYSTEM cStmt;
			
			
			LET cStmt = '';
			LET cStmt = ' echo "FILE /RESPALDOSNEW/tmp_sac_app_payi_621028.unl'||' DELIMITER '|| "'" || '|' || "'" || ' 129;' || '">/RESPALDOSNEW/tmp_sac_app_payi_621028_up.sql';
			SYSTEM cStmt;

			LET cStmt = '';
			LET cStmt = ' echo "INSERT INTO sac_app_payi_old;' || '">> /RESPALDOSNEW/tmp_sac_app_payi_621028_up.sql';
			SYSTEM cStmt;
			
			LET cStmt = '';
			LET cStmt = 'chmod 777 /RESPALDOSNEW/tmp_sac_app_payi_621028_up.sql';
			SYSTEM cStmt;
			
			/*
			LET cStmt = "";
			LET cStmt = 'dbload -d bdisac -c /RESPALDOSNEW/tmp_sac_app_payi_621028_up.sql -l /RESPALDOSNEW/tmp_sac_app_payi_621028_up.log -n 1000 -r';
			SYSTEM cStmt;
			*/
		
			LET cConteo2 = 0;
			
			SELECT COUNT(*)
			INTO cConteo2
			FROM tmp_sac_app_payi_621028;
			
			IF cConteo2 IS NULL THEN 
				LET cConteo2 = 0;
			END IF;
			
			SELECT FIRST 1 * FROM tmp_sac_app_payi_621028 INTO tmp_sac_app_payi_621028_2;
			
			TRUNCATE TABLE tmp_sac_app_payi_621028_2;
			
			
			/*
			LET cStmt = 'echo "LOAD FROM /RESPALDOSNEW/tmp_sac_app_payi_621028.unl INSERT INTO tmp_sac_app_payi_621028_2;">/RESPALDOSNEW/tmp_sac_app_payi_621028_up2.sql';
			SYSTEM cStmt;
			
			LET cStmt= 'dbaccess bdisac	/RESPALDOSNEW/tmp_sac_app_payi_621028_up2.sql';
			SYSTEM cStmt;
			*/
			
			LET cStmt = '';
			LET cStmt = ' echo "FILE /RESPALDOSNEW/tmp_sac_app_payi_621028.unl'||' DELIMITER '|| "'" || '|' || "'" || ' 129;' || '">/RESPALDOSNEW/tmp_sac_app_payi_621028_up2.sql';
			SYSTEM cStmt;
			
			LET cStmt = '';
			LET cStmt = ' echo "INSERT INTO tmp_sac_app_payi_621028_2;' || '">> /RESPALDOSNEW/tmp_sac_app_payi_621028_up2.sql';
			SYSTEM cStmt;
			
			LET cStmt = '';
			LET cStmt = 'chmod 777 /RESPALDOSNEW/tmp_sac_app_payi_621028_up2.sql';
			SYSTEM cStmt;
			
			
			LET cStmt = "";
			LET cStmt = 'dbload -d bdisac -c /RESPALDOSNEW/tmp_sac_app_payi_621028_up2.sql -l /RESPALDOSNEW/tmp_sac_app_payi_621028_up2.log -n 1000 -r';
			SYSTEM cStmt;
			
			
			LET cConteo3 = 0;
			
			SELECT COUNT(*)
			INTO cConteo3
			FROM tmp_sac_app_payi_621028_2;
			
			IF cConteo3 IS NULL THEN 
				LET cConteo3 = 0;
			END IF;
			
				
			IF cConteo = cConteo2 AND cConteo = cConteo3 THEN 
				
				LET cConteoPayi = cConteo;
				
				--LET cStmt= 'dbaccess bdisac	/RESPALDOSNEW/tmp_sac_app_payi_621028_up.sql';
				--SYSTEM cStmt;
				LET cStmt = "";
				LET cStmt = 'dbload -d bdisac -c /RESPALDOSNEW/tmp_sac_app_payi_621028_up.sql -l /RESPALDOSNEW/tmp_sac_app_payi_621028_up.log -n 1000 -r';
				SYSTEM cStmt;
				
				LET cConteo4 = 0;
				BEGIN WORK;
				FOREACH WITH HOLD
					select unirefnum,fecha 
					into cNo_row, cFh
					from tmp_sac_app_payi_621028

					
					DELETE FROM "informix".sac_app_payi WHERE unirefnum = cNo_row AND fecha = cFh;
					
					LET cConteo4 = cConteo4 + 1;						
					IF cConteo4 = 1000 THEN
						COMMIT WORK;
						LET cConteo4 = 0;
						BEGIN WORK;
					END IF;			
					
				END FOREACH;
				
				IF cConteo4 <> 0 THEN 
					COMMIT WORK;
					LET cConteo4 = 0;
					--BEGIN WORK;
				END IF;
			
				DROP TABLE IF EXISTS tmp_sac_app_payi_621028;
				DROP TABLE IF EXISTS tmp_sac_app_payi_621028_2;
				
				LET cStmt = 'rm -f /RESPALDOSNEW/tmp_sac_app_payi_621028.sql';
				SYSTEM cStmt;
				LET cStmt = 'rm -f /RESPALDOSNEW/tmp_sac_app_payi_621028_up.sql';
				SYSTEM cStmt;
				LET cStmt = 'rm -f /RESPALDOSNEW/tmp_sac_app_payi_621028_up2.sql';
				SYSTEM cStmt;
				LET cStmt = 'rm -f /RESPALDOSNEW/tmp_sac_app_payi_621028.unl';
				SYSTEM cStmt;
				LET cStmt = 'rm -f /RESPALDOSNEW/tmp_sac_app_payi_621028_up.log';
				SYSTEM cStmt;
				LET cStmt = 'rm -f /RESPALDOSNEW/tmp_sac_app_payi_621028_up2.log';
				SYSTEM cStmt;
				
				
				--DELETE FROM sac_app_payi WHERE fecha <= EXTEND((today - cDiasRespaldos), YEAR to SECOND)+24 UNITS HOUR+60 UNITS MINUTE+60 UNITS SECOND;
			ELSE 
				LET cCodRet = "00001";				
				LET cMensaje =  "Verificar Diferencias en Proceso|";
				LET cConteoPayi = cConteo||"-"||cConteo2||"-"||cConteo3;

			END IF;

		END IF;

	/*FIN DEPURACION sac_app_payi*/
		
		
	/*DEPURACION sac_app_qryi*/
		
		LET cConteo = 0;
				
		SELECT COUNT(*)
		INTO cConteo
		FROM sac_app_qryi
		WHERE fecha <= EXTEND((today - cDiasRespaldos), YEAR to SECOND)+24 UNITS HOUR+60 UNITS MINUTE+60 UNITS SECOND;
		
		IF cConteo IS NULL THEN 
			LET cConteo = 0;
		END IF;
		
		IF cConteo <> 0 THEN 
			DROP TABLE IF EXISTS tmp_sac_app_qryi_621028;
			DROP TABLE IF EXISTS tmp_sac_app_qryi_621028_2;
			
			LET cStmt = 'rm -f /RESPALDOSNEW/tmp_sac_app_qryi_621028.sql';
			SYSTEM cStmt;
			LET cStmt = 'rm -f /RESPALDOSNEW/tmp_sac_app_qryi_621028_up.sql';
			SYSTEM cStmt;
			LET cStmt = 'rm -f /RESPALDOSNEW/tmp_sac_app_qryi_621028_up2.sql';
			SYSTEM cStmt;
			LET cStmt = 'rm -f /RESPALDOSNEW/tmp_sac_app_qryi_621028.unl';
			SYSTEM cStmt;
			LET cStmt = 'rm -f /RESPALDOSNEW/tmp_sac_app_qryi_621028_up.log';
			SYSTEM cStmt;
			LET cStmt = 'rm -f /RESPALDOSNEW/tmp_sac_app_qryi_621028_up2.log';
			SYSTEM cStmt;
			
			
			SELECT *
			FROM sac_app_qryi 
			WHERE fecha <= EXTEND((today - cDiasRespaldos), YEAR to SECOND)+24 UNITS HOUR+60 UNITS MINUTE+60 UNITS SECOND
			INTO tmp_sac_app_qryi_621028;
			
			
			LET cStmt = 'echo "UNLOAD TO /RESPALDOSNEW/tmp_sac_app_qryi_621028.unl SELECT * FROM tmp_sac_app_qryi_621028;">/RESPALDOSNEW/tmp_sac_app_qryi_621028.sql';
			SYSTEM cStmt;
			
			LET cStmt = 'chmod 777 /RESPALDOSNEW/tmp_sac_app_qryi_621028.sql';
			SYSTEM cStmt;
						
					
			LET cStmt= 'dbaccess bdisac	/RESPALDOSNEW/tmp_sac_app_qryi_621028.sql';
			SYSTEM cStmt;
			
			LET cStmt = 'chmod 777 /RESPALDOSNEW/tmp_sac_app_qryi_621028.unl';
			SYSTEM cStmt;
			
			
			--LET cStmt = 'echo "LOAD FROM /RESPALDOSNEW/tmp_sac_app_qryi_621028.unl INSERT INTO sac_app_qryi_old;">/RESPALDOSNEW/tmp_sac_app_qryi_621028_up.sql';
			--SYSTEM cStmt;
			
			LET cStmt = '';
			LET cStmt = ' echo "FILE /RESPALDOSNEW/tmp_sac_app_qryi_621028.unl'||' DELIMITER '|| "'" || '|' || "'" || ' 101;' || '">/RESPALDOSNEW/tmp_sac_app_qryi_621028_up.sql';
			SYSTEM cStmt;

			LET cStmt = '';
			LET cStmt = ' echo "INSERT INTO sac_app_qryi_old;' || '">> /RESPALDOSNEW/tmp_sac_app_qryi_621028_up.sql';
			SYSTEM cStmt;
			
			LET cStmt = '';
			LET cStmt = 'chmod 777 /RESPALDOSNEW/tmp_sac_app_qryi_621028_up.sql';
			SYSTEM cStmt;
			
			/*
			LET cStmt = "";
			LET cStmt = 'dbload -d bdisac -c /RESPALDOSNEW/tmp_sac_app_qryi_621028_up.sql -l /RESPALDOSNEW/tmp_sac_app_qryi_621028_up.log -n 1000 -r';
			SYSTEM cStmt;
			*/
					
			LET cConteo2 = 0;
			
			SELECT COUNT(*)
			INTO cConteo2
			FROM tmp_sac_app_qryi_621028;
			
			IF cConteo2 IS NULL THEN 
				LET cConteo2 = 0;
			END IF;
			
			SELECT FIRST 1 * FROM tmp_sac_app_qryi_621028 INTO tmp_sac_app_qryi_621028_2;
			
			TRUNCATE TABLE tmp_sac_app_qryi_621028_2;
			
			
			/*
			LET cStmt = 'echo "LOAD FROM /RESPALDOSNEW/tmp_sac_app_qryi_621028.unl INSERT INTO tmp_sac_app_qryi_621028_2;">/RESPALDOSNEW/tmp_sac_app_qryi_621028_up2.sql';
			SYSTEM cStmt;
			
			LET cStmt= 'dbaccess bdisac	/RESPALDOSNEW/tmp_sac_app_qryi_621028_up2.sql';
			SYSTEM cStmt;
			*/
			
			LET cStmt = '';
			LET cStmt = ' echo "FILE /RESPALDOSNEW/tmp_sac_app_qryi_621028.unl'||' DELIMITER '|| "'" || '|' || "'" || ' 101;' || '">/RESPALDOSNEW/tmp_sac_app_qryi_621028_up2.sql';
			SYSTEM cStmt;
			
			LET cStmt = '';
			LET cStmt = ' echo "INSERT INTO tmp_sac_app_qryi_621028_2;' || '">> /RESPALDOSNEW/tmp_sac_app_qryi_621028_up2.sql';
			SYSTEM cStmt;
			
			LET cStmt = '';
			LET cStmt = 'chmod 777 /RESPALDOSNEW/tmp_sac_app_qryi_621028_up2.sql';
			SYSTEM cStmt;
			
			
			LET cStmt = "";
			LET cStmt = 'dbload -d bdisac -c /RESPALDOSNEW/tmp_sac_app_qryi_621028_up2.sql -l /RESPALDOSNEW/tmp_sac_app_qryi_621028_up2.log -n 1000 -r';
			SYSTEM cStmt;
			
			
			LET cConteo3 = 0;
			
			SELECT COUNT(*)
			INTO cConteo3
			FROM tmp_sac_app_qryi_621028_2;
			
			IF cConteo3 IS NULL THEN 
				LET cConteo3 = 0;
			END IF;
			
			
			IF cConteo = cConteo2 AND cConteo = cConteo3 THEN 
				
				LET cConteoQryi = cConteo;
				
				--LET cStmt= 'dbaccess bdisac	/RESPALDOSNEW/tmp_sac_app_qryi_621028_up.sql';
				--SYSTEM cStmt;
				
				LET cStmt = "";
				LET cStmt = 'dbload -d bdisac -c /RESPALDOSNEW/tmp_sac_app_qryi_621028_up.sql -l /RESPALDOSNEW/tmp_sac_app_qryi_621028_up.log -n 1000 -r';
				SYSTEM cStmt;
				
				LET cConteo4 = 0;
				BEGIN WORK;
				FOREACH WITH HOLD
					select unirefnum,fecha 
					into cNo_row, cFh
					from tmp_sac_app_qryi_621028

					
					DELETE FROM "informix".sac_app_qryi WHERE unirefnum = cNo_row AND fecha = cFh;
					
					LET cConteo4 = cConteo4 + 1;						
					IF cConteo4 = 1000 THEN
						COMMIT WORK;
						LET cConteo4 = 0;
						BEGIN WORK;
					END IF;			
					
				END FOREACH;
				
				IF cConteo4 <> 0 THEN 
					COMMIT WORK;
					LET cConteo4 = 0;
					--BEGIN WORK;
				END IF;
			
			
				DROP TABLE IF EXISTS tmp_sac_app_qryi_621028;
				DROP TABLE IF EXISTS tmp_sac_app_qryi_621028_2;
				
				LET cStmt = 'rm -f /RESPALDOSNEW/tmp_sac_app_qryi_621028.sql';
				SYSTEM cStmt;
				LET cStmt = 'rm -f /RESPALDOSNEW/tmp_sac_app_qryi_621028_up.sql';
				SYSTEM cStmt;
				LET cStmt = 'rm -f /RESPALDOSNEW/tmp_sac_app_qryi_621028_up2.sql';
				SYSTEM cStmt;
				LET cStmt = 'rm -f /RESPALDOSNEW/tmp_sac_app_qryi_621028.unl';
				SYSTEM cStmt;
				LET cStmt = 'rm -f /RESPALDOSNEW/tmp_sac_app_qryi_621028_up.log';
				SYSTEM cStmt;
				LET cStmt = 'rm -f /RESPALDOSNEW/tmp_sac_app_qryi_621028_up2.log';
				SYSTEM cStmt;
				
				--DELETE FROM sac_app_qryi WHERE fecha <= EXTEND((today - cDiasRespaldos), YEAR to SECOND)+24 UNITS HOUR+60 UNITS MINUTE+60 UNITS SECOND;
			ELSE 
				LET cCodRet = "00002";				
				LET cMensaje =  "Verificar Diferencias en Proceso|";
				LET cConteoQryi = cConteo||"-"||cConteo2||"-"||cConteo3;

			END IF;

		END IF;

	/*FIN DEPURACION sac_app_qryi*/
		
		
	/*DEPURACION sac_app_getorder*/
		
		LET cConteo = 0;
				
		SELECT COUNT(*)
		INTO cConteo
		FROM sac_app_getorder
		WHERE fecha_insert <= EXTEND((today - cDiasRespaldos), YEAR to SECOND)+24 UNITS HOUR+60 UNITS MINUTE+60 UNITS SECOND;
		
		IF cConteo IS NULL THEN 
			LET cConteo = 0;
		END IF;
		
		IF cConteo <> 0 THEN 
			DROP TABLE IF EXISTS tmp_sac_app_getorder_621028;
			DROP TABLE IF EXISTS tmp_sac_app_getorder_621028_2;
			
			LET cStmt = 'rm -f /RESPALDOSNEW/tmp_sac_app_getorder_621028.sql';
			SYSTEM cStmt;
			LET cStmt = 'rm -f /RESPALDOSNEW/tmp_sac_app_getorder_621028_up.sql';
			SYSTEM cStmt;
			LET cStmt = 'rm -f /RESPALDOSNEW/tmp_sac_app_getorder_621028_up2.sql';
			SYSTEM cStmt;
			LET cStmt = 'rm -f /RESPALDOSNEW/tmp_sac_app_getorder_621028.unl';
			SYSTEM cStmt;
			LET cStmt = 'rm -f /RESPALDOSNEW/tmp_sac_app_getorder_621028_up.log';
			SYSTEM cStmt;
			LET cStmt = 'rm -f /RESPALDOSNEW/tmp_sac_app_getorder_621028_up2.log';
			SYSTEM cStmt;
			
			SELECT *
			FROM sac_app_getorder 
			WHERE fecha_insert <= EXTEND((today - cDiasRespaldos), YEAR to SECOND)+24 UNITS HOUR+60 UNITS MINUTE+60 UNITS SECOND
			INTO tmp_sac_app_getorder_621028;
			
			
			LET cStmt = 'echo "UNLOAD TO /RESPALDOSNEW/tmp_sac_app_getorder_621028.unl SELECT * FROM tmp_sac_app_getorder_621028;">/RESPALDOSNEW/tmp_sac_app_getorder_621028.sql';
			SYSTEM cStmt;
			
			LET cStmt = 'chmod 777 /RESPALDOSNEW/tmp_sac_app_getorder_621028.sql';
			SYSTEM cStmt;			
					
			LET cStmt= 'dbaccess bdisac	/RESPALDOSNEW/tmp_sac_app_getorder_621028.sql';
			SYSTEM cStmt;
			
			LET cStmt = 'chmod 777 /RESPALDOSNEW/tmp_sac_app_getorder_621028.unl';
			SYSTEM cStmt;
					
			--LET cStmt = 'echo "LOAD FROM /RESPALDOSNEW/tmp_sac_app_getorder_621028.unl INSERT INTO sac_app_getorder_old;">/RESPALDOSNEW/tmp_sac_app_getorder_621028_up.sql';
			--SYSTEM cStmt;
			
			
			LET cStmt = '';
			LET cStmt = ' echo "FILE /RESPALDOSNEW/tmp_sac_app_getorder_621028.unl'||' DELIMITER '|| "'" || '|' || "'" || ' 99;' || '">/RESPALDOSNEW/tmp_sac_app_getorder_621028_up.sql';
			SYSTEM cStmt;

			LET cStmt = '';
			LET cStmt = ' echo "INSERT INTO sac_app_getorder_old;' || '">> /RESPALDOSNEW/tmp_sac_app_getorder_621028_up.sql';
			SYSTEM cStmt;
			
			LET cStmt = '';
			LET cStmt = 'chmod 777 /RESPALDOSNEW/tmp_sac_app_getorder_621028_up.sql';
			SYSTEM cStmt;
			
			/*
			LET cStmt = "";
			LET cStmt = 'dbload -d bdisac -c /RESPALDOSNEW/tmp_sac_app_getorder_621028_up.sql -l /RESPALDOSNEW/tmp_sac_app_getorder_621028_up.log -n 1000 -r';
			SYSTEM cStmt;
			*/
					

			LET cConteo2 = 0;
			
			SELECT COUNT(*)
			INTO cConteo2
			FROM tmp_sac_app_getorder_621028;
			
			IF cConteo2 IS NULL THEN 
				LET cConteo2 = 0;
			END IF;
			
			SELECT FIRST 1 * FROM tmp_sac_app_getorder_621028 INTO tmp_sac_app_getorder_621028_2;
			
			TRUNCATE TABLE tmp_sac_app_getorder_621028_2;
			
			/*
			LET cStmt = 'echo "LOAD FROM /RESPALDOSNEW/tmp_sac_app_getorder_621028.unl INSERT INTO tmp_sac_app_getorder_621028_2;">/RESPALDOSNEW/tmp_sac_app_getorder_621028_up2.sql';
			SYSTEM cStmt;
			
			LET cStmt= 'dbaccess bdisac	/RESPALDOSNEW/tmp_sac_app_getorder_621028_up2.sql';
			SYSTEM cStmt;
			*/
			
			LET cStmt = '';
			LET cStmt = ' echo "FILE /RESPALDOSNEW/tmp_sac_app_getorder_621028.unl'||' DELIMITER '|| "'" || '|' || "'" || ' 99;' || '">/RESPALDOSNEW/tmp_sac_app_getorder_621028_up2.sql';
			SYSTEM cStmt;
			
			LET cStmt = '';
			LET cStmt = ' echo "INSERT INTO tmp_sac_app_getorder_621028_2;' || '">> /RESPALDOSNEW/tmp_sac_app_getorder_621028_up2.sql';
			SYSTEM cStmt;
			
			LET cStmt = '';
			LET cStmt = 'chmod 777 /RESPALDOSNEW/tmp_sac_app_getorder_621028_up2.sql';
			SYSTEM cStmt;
			
			
			LET cStmt = "";
			LET cStmt = 'dbload -d bdisac -c /RESPALDOSNEW/tmp_sac_app_getorder_621028_up2.sql -l /RESPALDOSNEW/tmp_sac_app_getorder_621028_up2.log -n 1000 -r';
			SYSTEM cStmt;
			
			
			LET cConteo3 = 0;
			
			SELECT COUNT(*)
			INTO cConteo3
			FROM tmp_sac_app_getorder_621028_2;
			
			IF cConteo3 IS NULL THEN 
				LET cConteo3 = 0;
			END IF;
			
			
			
			IF cConteo = cConteo2 AND cConteo = cConteo3 THEN 
				
				LET cConteoGetorder = cConteo;
				
				--LET cStmt= 'dbaccess bdisac	/RESPALDOSNEW/tmp_sac_app_getorder_621028_up.sql';
				--SYSTEM cStmt;
				
				LET cStmt = "";
				LET cStmt = 'dbload -d bdisac -c /RESPALDOSNEW/tmp_sac_app_getorder_621028_up.sql -l /RESPALDOSNEW/tmp_sac_app_getorder_621028_up.log -n 1000 -r';
				SYSTEM cStmt;
				
				LET cConteo4 = 0;
				BEGIN WORK;
				FOREACH WITH HOLD
					select uniquereferencenumber,fecha_insert 
					into cNo_row, cFh
					from tmp_sac_app_getorder_621028

					
					DELETE FROM "informix".sac_app_getorder WHERE uniquereferencenumber = cNo_row AND fecha_insert = cFh;
					
					LET cConteo4 = cConteo4 + 1;						
					IF cConteo4 = 1000 THEN
						COMMIT WORK;
						LET cConteo4 = 0;
						BEGIN WORK;
					END IF;			
					
				END FOREACH;
				
				IF cConteo4 <> 0 THEN 
					COMMIT WORK;
					LET cConteo4 = 0;
					--BEGIN WORK;
				END IF;
			
				DROP TABLE IF EXISTS tmp_sac_app_getorder_621028;
				DROP TABLE IF EXISTS tmp_sac_app_getorder_621028_2;
				
				LET cStmt = 'rm -f /RESPALDOSNEW/tmp_sac_app_getorder_621028.sql';
				SYSTEM cStmt;
				LET cStmt = 'rm -f /RESPALDOSNEW/tmp_sac_app_getorder_621028_up.sql';
				SYSTEM cStmt;
				LET cStmt = 'rm -f /RESPALDOSNEW/tmp_sac_app_getorder_621028_up2.sql';
				SYSTEM cStmt;
				LET cStmt = 'rm -f /RESPALDOSNEW/tmp_sac_app_getorder_621028.unl';
				SYSTEM cStmt;
				LET cStmt = 'rm -f /RESPALDOSNEW/tmp_sac_app_getorder_621028_up.log';
				SYSTEM cStmt;
				LET cStmt = 'rm -f /RESPALDOSNEW/tmp_sac_app_getorder_621028_up2.log';
				SYSTEM cStmt;
				
				--DELETE FROM sac_app_getorder WHERE fecha_insert <= EXTEND((today - cDiasRespaldos), YEAR to SECOND)+24 UNITS HOUR+60 UNITS MINUTE+60 UNITS SECOND;
			ELSE 
				LET cCodRet = "00003";				
				LET cMensaje =  "Verificar Diferencias en Proceso|";
				LET cConteoGetorder = cConteo||"-"||cConteo2||"-"||cConteo3;

			END IF;

		END IF;

	/*FIN DEPURACION sac_app_getorder*/
		
		
	/*DEPURACION sac_app_recordorder*/
		
		LET cConteo = 0;
				
		SELECT COUNT(*)
		INTO cConteo
		FROM sac_app_recordorder
		WHERE fecha_insert <= EXTEND((today - cDiasRespaldos), YEAR to SECOND)+24 UNITS HOUR+60 UNITS MINUTE+60 UNITS SECOND;
		
		IF cConteo IS NULL THEN 
			LET cConteo = 0;
		END IF;
		
		IF cConteo <> 0 THEN 
			DROP TABLE IF EXISTS tmp_sac_app_recordorder_621028;
			DROP TABLE IF EXISTS tmp_sac_app_recordorder_621028_2;
			
			LET cStmt = 'rm -f /RESPALDOSNEW/tmp_sac_app_recordorder_621028.sql';
			SYSTEM cStmt;
			LET cStmt = 'rm -f /RESPALDOSNEW/tmp_sac_app_recordorder_621028_up.sql';
			SYSTEM cStmt;
			LET cStmt = 'rm -f /RESPALDOSNEW/tmp_sac_app_recordorder_621028_up2.sql';
			SYSTEM cStmt;
			LET cStmt = 'rm -f /RESPALDOSNEW/tmp_sac_app_recordorder_621028.unl';
			SYSTEM cStmt;
			LET cStmt = 'rm -f /RESPALDOSNEW/tmp_sac_app_recordorder_621028_up.log';
			SYSTEM cStmt;
			LET cStmt = 'rm -f /RESPALDOSNEW/tmp_sac_app_recordorder_621028_up2.log';
			SYSTEM cStmt;
			
			
			SELECT *
			FROM sac_app_recordorder 
			WHERE fecha_insert <= EXTEND((today - cDiasRespaldos), YEAR to SECOND)+24 UNITS HOUR+60 UNITS MINUTE+60 UNITS SECOND
			INTO tmp_sac_app_recordorder_621028;
			
			
			LET cStmt = 'echo "UNLOAD TO /RESPALDOSNEW/tmp_sac_app_recordorder_621028.unl SELECT * FROM tmp_sac_app_recordorder_621028;">/RESPALDOSNEW/tmp_sac_app_recordorder_621028.sql';
			SYSTEM cStmt;
					
			
			LET cStmt = 'chmod 777 /RESPALDOSNEW/tmp_sac_app_recordorder_621028.sql';
			SYSTEM cStmt;
			
			
			LET cStmt= 'dbaccess bdisac	/RESPALDOSNEW/tmp_sac_app_recordorder_621028.sql';
			SYSTEM cStmt;
			
			LET cStmt = 'chmod 777 /RESPALDOSNEW/tmp_sac_app_recordorder_621028.unl';
			SYSTEM cStmt;			
			
			
			--LET cStmt = 'echo "LOAD FROM /RESPALDOSNEW/tmp_sac_app_recordorder_621028.unl INSERT INTO sac_app_recordorder_old;">/RESPALDOSNEW/tmp_sac_app_recordorder_621028_up.sql';
			--SYSTEM cStmt;
			
			LET cStmt = '';
			LET cStmt = ' echo "FILE /RESPALDOSNEW/tmp_sac_app_recordorder_621028.unl'||' DELIMITER '|| "'" || '|' || "'" || ' 21;' || '">/RESPALDOSNEW/tmp_sac_app_recordorder_621028_up.sql';
			SYSTEM cStmt;

			LET cStmt = '';
			LET cStmt = ' echo "INSERT INTO sac_app_recordorder_old;' || '">> /RESPALDOSNEW/tmp_sac_app_recordorder_621028_up.sql';
			SYSTEM cStmt;
			
			LET cStmt = '';
			LET cStmt = 'chmod 777 /RESPALDOSNEW/tmp_sac_app_recordorder_621028_up.sql';
			SYSTEM cStmt;
			
			/*
			LET cStmt = "";
			LET cStmt = 'dbload -d bdisac -c /RESPALDOSNEW/tmp_sac_app_recordorder_621028_up.sql -l /RESPALDOSNEW/tmp_sac_app_recordorder_621028_up.log -n 1000 -r';
			SYSTEM cStmt;
			*/
			
			LET cConteo2 = 0;
			
			SELECT COUNT(*)
			INTO cConteo2
			FROM tmp_sac_app_recordorder_621028;
			
			IF cConteo2 IS NULL THEN 
				LET cConteo2 = 0;
			END IF;
			
			SELECT FIRST 1 * FROM tmp_sac_app_recordorder_621028 INTO tmp_sac_app_recordorder_621028_2;
			
			TRUNCATE TABLE tmp_sac_app_recordorder_621028_2;
			
			
			/*
			LET cStmt = 'echo "LOAD FROM /RESPALDOSNEW/tmp_sac_app_recordorder_621028.unl INSERT INTO tmp_sac_app_recordorder_621028_2;">/RESPALDOSNEW/tmp_sac_app_recordorder_621028_up2.sql';
			SYSTEM cStmt;
			
			LET cStmt= 'dbaccess bdisac	/RESPALDOSNEW/tmp_sac_app_recordorder_621028_up2.sql';
			SYSTEM cStmt;
			*/
			
			LET cStmt = '';
			LET cStmt = ' echo "FILE /RESPALDOSNEW/tmp_sac_app_recordorder_621028.unl'||' DELIMITER '|| "'" || '|' || "'" || ' 21;' || '">/RESPALDOSNEW/tmp_sac_app_recordorder_621028_up2.sql';
			SYSTEM cStmt;
			
			LET cStmt = '';
			LET cStmt = ' echo "INSERT INTO tmp_sac_app_recordorder_621028_2;' || '">> /RESPALDOSNEW/tmp_sac_app_recordorder_621028_up2.sql';
			SYSTEM cStmt;
			
			LET cStmt = '';
			LET cStmt = 'chmod 777 /RESPALDOSNEW/tmp_sac_app_recordorder_621028_up2.sql';
			SYSTEM cStmt;
			
			
			LET cStmt = "";
			LET cStmt = 'dbload -d bdisac -c /RESPALDOSNEW/tmp_sac_app_recordorder_621028_up2.sql -l /RESPALDOSNEW/tmp_sac_app_recordorder_621028_up2.log -n 1000 -r';
			SYSTEM cStmt;	
			
			
			LET cConteo3 = 0;
			
			SELECT COUNT(*)
			INTO cConteo3
			FROM tmp_sac_app_recordorder_621028_2;
			
			IF cConteo3 IS NULL THEN 
				LET cConteo3 = 0;
			END IF;
			
			
			
			IF cConteo = cConteo2 AND cConteo = cConteo3 THEN 
				
				LET cConteoRecordorder = cConteo;
				
				--LET cStmt= 'dbaccess bdisac	/RESPALDOSNEW/tmp_sac_app_recordorder_621028_up.sql';
				--SYSTEM cStmt;
				
				LET cStmt = "";
				LET cStmt = 'dbload -d bdisac -c /RESPALDOSNEW/tmp_sac_app_recordorder_621028_up.sql -l /RESPALDOSNEW/tmp_sac_app_recordorder_621028_up.log -n 1000 -r';
				SYSTEM cStmt;
				
				LET cConteo4 = 0;
				BEGIN WORK;
				FOREACH WITH HOLD
					select uniquereferencenumber,fecha_insert 
					into cNo_row, cFh
					from tmp_sac_app_recordorder_621028

					
					DELETE FROM "informix".sac_app_recordorder WHERE uniquereferencenumber = cNo_row AND fecha_insert = cFh;
					
					LET cConteo4 = cConteo4 + 1;						
					IF cConteo4 = 1000 THEN
						COMMIT WORK;
						LET cConteo4 = 0;
						BEGIN WORK;
					END IF;			
					
				END FOREACH;
				
				IF cConteo4 <> 0 THEN 
					COMMIT WORK;
					LET cConteo4 = 0;
					--BEGIN WORK;
				END IF;
			
				DROP TABLE IF EXISTS tmp_sac_app_recordorder_621028;
				DROP TABLE IF EXISTS tmp_sac_app_recordorder_621028_2;
				
				LET cStmt = 'rm -f /RESPALDOSNEW/tmp_sac_app_recordorder_621028.sql';
				SYSTEM cStmt;
				LET cStmt = 'rm -f /RESPALDOSNEW/tmp_sac_app_recordorder_621028_up.sql';
				SYSTEM cStmt;
				LET cStmt = 'rm -f /RESPALDOSNEW/tmp_sac_app_recordorder_621028_up2.sql';
				SYSTEM cStmt;
				LET cStmt = 'rm -f /RESPALDOSNEW/tmp_sac_app_recordorder_621028.unl';
				SYSTEM cStmt;
				LET cStmt = 'rm -f /RESPALDOSNEW/tmp_sac_app_recordorder_621028_up.log';
				SYSTEM cStmt;
				LET cStmt = 'rm -f /RESPALDOSNEW/tmp_sac_app_recordorder_621028_up2.log';
				SYSTEM cStmt;
				
				--DELETE FROM sac_app_recordorder WHERE fecha_insert <= EXTEND((today - cDiasRespaldos), YEAR to SECOND)+24 UNITS HOUR+60 UNITS MINUTE+60 UNITS SECOND;
			ELSE 
				
				LET cCodRet = "00004";				
				LET cMensaje =  "Verificar Diferencias en Proceso|";
				LET cConteoRecordorder = cConteo||"-"||cConteo2||"-"||cConteo3;

			END IF;

		END IF;

	/*FIN DEPURACION sac_app_recordorder*/
		
		
	/*DEPURACION sac_app_confirmpayment*/
		
		LET cConteo = 0;
				
		SELECT COUNT(*)
		INTO cConteo
		FROM sac_app_confirmpayment
		WHERE fecha_insert <= EXTEND((today - cDiasRespaldos), YEAR to SECOND)+24 UNITS HOUR+60 UNITS MINUTE+60 UNITS SECOND;
		
		IF cConteo IS NULL THEN 
			LET cConteo = 0;
		END IF;
		
		IF cConteo <> 0 THEN 
			DROP TABLE IF EXISTS tmp_sac_app_confirmpayment_621028;
			DROP TABLE IF EXISTS tmp_sac_app_confirmpayment_621028_2;
			
			LET cStmt = 'rm -f /RESPALDOSNEW/tmp_sac_app_confirmpayment_621028.sql';
			SYSTEM cStmt;
			LET cStmt = 'rm -f /RESPALDOSNEW/tmp_sac_app_confirmpayment_621028_up.sql';
			SYSTEM cStmt;
			LET cStmt = 'rm -f /RESPALDOSNEW/tmp_sac_app_confirmpayment_621028_up2.sql';
			SYSTEM cStmt;
			LET cStmt = 'rm -f /RESPALDOSNEW/tmp_sac_app_confirmpayment_621028.unl';
			SYSTEM cStmt;
			LET cStmt = 'rm -f /RESPALDOSNEW/tmp_sac_app_confirmpayment_621028_up.log';
			SYSTEM cStmt;
			LET cStmt = 'rm -f /RESPALDOSNEW/tmp_sac_app_confirmpayment_621028_up2.log';
			SYSTEM cStmt;
			
			
			SELECT *
			FROM sac_app_confirmpayment
			WHERE fecha_insert <= EXTEND((today - cDiasRespaldos), YEAR to SECOND)+24 UNITS HOUR+60 UNITS MINUTE+60 UNITS SECOND
			INTO tmp_sac_app_confirmpayment_621028;
			
			
			LET cStmt = 'echo "UNLOAD TO /RESPALDOSNEW/tmp_sac_app_confirmpayment_621028.unl SELECT * FROM tmp_sac_app_confirmpayment_621028;">/RESPALDOSNEW/tmp_sac_app_confirmpayment_621028.sql';
			SYSTEM cStmt;
			
			LET cStmt = 'chmod 777 /RESPALDOSNEW/tmp_sac_app_confirmpayment_621028.sql';
			SYSTEM cStmt;
									
			LET cStmt= 'dbaccess bdisac	/RESPALDOSNEW/tmp_sac_app_confirmpayment_621028.sql';
			SYSTEM cStmt;
			
			LET cStmt = 'chmod 777 /RESPALDOSNEW/tmp_sac_app_confirmpayment_621028.unl';
			SYSTEM cStmt;
					
			--LET cStmt = 'echo "LOAD FROM /RESPALDOSNEW/tmp_sac_app_confirmpayment_621028.unl INSERT INTO sac_app_confirmpayment_old;">/RESPALDOSNEW/tmp_sac_app_confirmpayment_621028_up.sql';
			--SYSTEM cStmt;
					
			LET cStmt = '';
			LET cStmt = ' echo "FILE /RESPALDOSNEW/tmp_sac_app_confirmpayment_621028.unl'||' DELIMITER '|| "'" || '|' || "'" || ' 37;' || '">/RESPALDOSNEW/tmp_sac_app_confirmpayment_621028_up.sql';
			SYSTEM cStmt;

			LET cStmt = '';
			LET cStmt = ' echo "INSERT INTO sac_app_confirmpayment_old;' || '">> /RESPALDOSNEW/tmp_sac_app_confirmpayment_621028_up.sql';
			SYSTEM cStmt;
			
			LET cStmt = '';
			LET cStmt = 'chmod 777 /RESPALDOSNEW/tmp_sac_app_confirmpayment_621028_up.sql';
			SYSTEM cStmt;
			
			/*
			LET cStmt = "";
			LET cStmt = 'dbload -d bdisac -c /RESPALDOSNEW/tmp_sac_app_confirmpayment_621028_up.sql -l /RESPALDOSNEW/tmp_sac_app_confirmpayment_621028_up.log -n 1000 -r';
			SYSTEM cStmt;
			*/
			
			LET cConteo2 = 0;
			
			SELECT COUNT(*)
			INTO cConteo2
			FROM tmp_sac_app_confirmpayment_621028;
			
			IF cConteo2 IS NULL THEN 
				LET cConteo2 = 0;
			END IF;
			
			SELECT FIRST 1 * FROM tmp_sac_app_confirmpayment_621028 INTO tmp_sac_app_confirmpayment_621028_2;
			
			TRUNCATE TABLE tmp_sac_app_confirmpayment_621028_2;
			
			/*
			LET cStmt = 'echo "LOAD FROM /RESPALDOSNEW/tmp_sac_app_confirmpayment_621028.unl INSERT INTO tmp_sac_app_confirmpayment_621028_2;">/RESPALDOSNEW/tmp_sac_app_confirmpayment_621028_up2.sql';
			SYSTEM cStmt;
			
			LET cStmt= 'dbaccess bdisac	/RESPALDOSNEW/tmp_sac_app_confirmpayment_621028_up2.sql';
			SYSTEM cStmt;
			*/
			
			LET cStmt = '';
			LET cStmt = ' echo "FILE /RESPALDOSNEW/tmp_sac_app_confirmpayment_621028.unl'||' DELIMITER '|| "'" || '|' || "'" || ' 37;' || '">/RESPALDOSNEW/tmp_sac_app_confirmpayment_621028_up2.sql';
			SYSTEM cStmt;
			
			LET cStmt = '';
			LET cStmt = ' echo "INSERT INTO tmp_sac_app_confirmpayment_621028_2;' || '">> /RESPALDOSNEW/tmp_sac_app_confirmpayment_621028_up2.sql';
			SYSTEM cStmt;
			
			LET cStmt = '';
			LET cStmt = 'chmod 777 /RESPALDOSNEW/tmp_sac_app_confirmpayment_621028_up2.sql';
			SYSTEM cStmt;
			
			
			LET cStmt = "";
			LET cStmt = 'dbload -d bdisac -c /RESPALDOSNEW/tmp_sac_app_confirmpayment_621028_up2.sql -l /RESPALDOSNEW/tmp_sac_app_confirmpayment_621028_up2.log -n 1000 -r';
			SYSTEM cStmt;
			
			
			LET cConteo3 = 0;
			
			SELECT COUNT(*)
			INTO cConteo3
			FROM tmp_sac_app_confirmpayment_621028_2;
			
			IF cConteo3 IS NULL THEN 
				LET cConteo3 = 0;
			END IF;
			
			
			
			IF cConteo = cConteo2 AND cConteo = cConteo3 THEN 
				
				LET cConteoConfpayment = cConteo;
				
				--LET cStmt= 'dbaccess bdisac	/RESPALDOSNEW/tmp_sac_app_confirmpayment_621028_up.sql';
				--SYSTEM cStmt;
				
				LET cStmt = "";
				LET cStmt = 'dbload -d bdisac -c /RESPALDOSNEW/tmp_sac_app_confirmpayment_621028_up.sql -l /RESPALDOSNEW/tmp_sac_app_confirmpayment_621028_up.log -n 1000 -r';
				SYSTEM cStmt;
				
				LET cConteo4 = 0;
				BEGIN WORK;
				FOREACH WITH HOLD
					select uniquereferencenumber,fecha_insert 
					into cNo_row, cFh
					from tmp_sac_app_confirmpayment_621028

					
					DELETE FROM "informix".sac_app_confirmpayment WHERE uniquereferencenumber = cNo_row AND fecha_insert = cFh;
					
					LET cConteo4 = cConteo4 + 1;						
					IF cConteo4 = 1000 THEN
						COMMIT WORK;
						LET cConteo4 = 0;
						BEGIN WORK;
					END IF;			
					
				END FOREACH;
				
				IF cConteo4 <> 0 THEN 
					COMMIT WORK;
					LET cConteo4 = 0;
					--BEGIN WORK;
				END IF;
			
				DROP TABLE IF EXISTS tmp_sac_app_confirmpayment_621028;
				DROP TABLE IF EXISTS tmp_sac_app_confirmpayment_621028_2;
				
				LET cStmt = 'rm -f /RESPALDOSNEW/tmp_sac_app_confirmpayment_621028.sql';
				SYSTEM cStmt;
				LET cStmt = 'rm -f /RESPALDOSNEW/tmp_sac_app_confirmpayment_621028_up.sql';
				SYSTEM cStmt;
				LET cStmt = 'rm -f /RESPALDOSNEW/tmp_sac_app_confirmpayment_621028_up2.sql';
				SYSTEM cStmt;
				LET cStmt = 'rm -f /RESPALDOSNEW/tmp_sac_app_confirmpayment_621028.unl';
				SYSTEM cStmt;
				LET cStmt = 'rm -f /RESPALDOSNEW/tmp_sac_app_confirmpayment_621028_up.log';
				SYSTEM cStmt;
				LET cStmt = 'rm -f /RESPALDOSNEW/tmp_sac_app_confirmpayment_621028_up2.log';
				SYSTEM cStmt;
				
				--DELETE FROM sac_app_confirmpayment WHERE fecha_insert <= EXTEND((today - cDiasRespaldos), YEAR to SECOND)+24 UNITS HOUR+60 UNITS MINUTE+60 UNITS SECOND;
			ELSE 
				
				LET cCodRet = "00005";				
				LET cMensaje =  "Verificar Diferencias en Proceso|";
				LET cConteoConfpayment = cConteo||"-"||cConteo2||"-"||cConteo3;

			END IF;

		END IF;

	/*FIN DEPURACION sac_app_confirmpayment*/
	
	/*DEPURACION sac_app_revi*/
		
		LET cConteo = 0;
				
		SELECT COUNT(*)
		INTO cConteo
		FROM sac_app_revi
		WHERE fecha <= EXTEND((today - cDiasRespaldos), YEAR to SECOND)+24 UNITS HOUR+60 UNITS MINUTE+60 UNITS SECOND;
		
		IF cConteo IS NULL THEN 
			LET cConteo = 0;
		END IF;
		
		IF cConteo <> 0 THEN 
			DROP TABLE IF EXISTS tmp_sac_app_revi_621028;
			DROP TABLE IF EXISTS tmp_sac_app_revi_621028_2;
			
			LET cStmt = 'rm -f /RESPALDOSNEW/tmp_sac_app_revi_621028.sql';
			SYSTEM cStmt;
			LET cStmt = 'rm -f /RESPALDOSNEW/tmp_sac_app_revi_621028_up.sql';
			SYSTEM cStmt;
			LET cStmt = 'rm -f /RESPALDOSNEW/tmp_sac_app_revi_621028_up2.sql';
			SYSTEM cStmt;
			LET cStmt = 'rm -f /RESPALDOSNEW/tmp_sac_app_revi_621028.unl';
			SYSTEM cStmt;
			LET cStmt = 'rm -f /RESPALDOSNEW/tmp_sac_app_revi_621028_up.log';
			SYSTEM cStmt;
			LET cStmt = 'rm -f /RESPALDOSNEW/tmp_sac_app_revi_621028_up2.log';
			SYSTEM cStmt;
			
			
			SELECT *
			FROM sac_app_revi
			WHERE fecha <= EXTEND((today - cDiasRespaldos), YEAR to SECOND)+24 UNITS HOUR+60 UNITS MINUTE+60 UNITS SECOND
			INTO tmp_sac_app_revi_621028;
			
			
			LET cStmt = 'echo "UNLOAD TO /RESPALDOSNEW/tmp_sac_app_revi_621028.unl SELECT * FROM tmp_sac_app_revi_621028;">/RESPALDOSNEW/tmp_sac_app_revi_621028.sql';
			SYSTEM cStmt;
			
			LET cStmt = 'chmod 777 /RESPALDOSNEW/tmp_sac_app_revi_621028.sql';
			SYSTEM cStmt;
					
			LET cStmt= 'dbaccess bdisac	/RESPALDOSNEW/tmp_sac_app_revi_621028.sql';
			SYSTEM cStmt;
					
			LET cStmt = 'chmod 777 /RESPALDOSNEW/tmp_sac_app_revi_621028.unl';
			SYSTEM cStmt;
			
			
			--LET cStmt = 'echo "LOAD FROM /RESPALDOSNEW/tmp_sac_app_revi_621028.unl INSERT INTO sac_app_revi_old;">/RESPALDOSNEW/tmp_sac_app_revi_621028_up.sql';
			--SYSTEM cStmt;
			
			LET cStmt = '';
			LET cStmt = ' echo "FILE /RESPALDOSNEW/tmp_sac_app_revi_621028.unl'||' DELIMITER '|| "'" || '|' || "'" || ' 28;' || '">/RESPALDOSNEW/tmp_sac_app_revi_621028_up.sql';
			SYSTEM cStmt;

			LET cStmt = '';
			LET cStmt = ' echo "INSERT INTO sac_app_revi_old;' || '">> /RESPALDOSNEW/tmp_sac_app_revi_621028_up.sql';
			SYSTEM cStmt;
			
			LET cStmt = '';
			LET cStmt = 'chmod 777 /RESPALDOSNEW/tmp_sac_app_revi_621028_up.sql';
			SYSTEM cStmt;
			
			/*
			LET cStmt = "";
			LET cStmt = 'dbload -d bdisac -c /RESPALDOSNEW/tmp_sac_app_payi_621028_up.sql -l /RESPALDOSNEW/tmp_sac_app_payi_621028_up.log -n 1000 -r';
			SYSTEM cStmt;
			*/
		
					

			LET cConteo2 = 0;
			
			SELECT COUNT(*)
			INTO cConteo2
			FROM tmp_sac_app_revi_621028;
			
			IF cConteo2 IS NULL THEN 
				LET cConteo2 = 0;
			END IF;
			
			SELECT FIRST 1 * FROM tmp_sac_app_revi_621028 INTO tmp_sac_app_revi_621028_2;
			
			TRUNCATE TABLE tmp_sac_app_revi_621028_2;
			
			/*
			LET cStmt = 'echo "LOAD FROM /RESPALDOSNEW/tmp_sac_app_revi_621028.unl INSERT INTO tmp_sac_app_revi_621028_2;">/RESPALDOSNEW/tmp_sac_app_revi_621028_up2.sql';
			SYSTEM cStmt;
			
			LET cStmt= 'dbaccess bdisac	/RESPALDOSNEW/tmp_sac_app_revi_621028_up2.sql';
			SYSTEM cStmt;
			*/
			
			LET cStmt = '';
			LET cStmt = ' echo "FILE /RESPALDOSNEW/tmp_sac_app_revi_621028.unl'||' DELIMITER '|| "'" || '|' || "'" || ' 28;' || '">/RESPALDOSNEW/tmp_sac_app_revi_621028_up2.sql';
			SYSTEM cStmt;
			
			LET cStmt = '';
			LET cStmt = ' echo "INSERT INTO tmp_sac_app_revi_621028_2;' || '">> /RESPALDOSNEW/tmp_sac_app_revi_621028_up2.sql';
			SYSTEM cStmt;
			
			LET cStmt = '';
			LET cStmt = 'chmod 777 /RESPALDOSNEW/tmp_sac_app_revi_621028_up2.sql';
			SYSTEM cStmt;
			
			
			LET cStmt = "";
			LET cStmt = 'dbload -d bdisac -c /RESPALDOSNEW/tmp_sac_app_revi_621028_up2.sql -l /RESPALDOSNEW/tmp_sac_app_revi_621028_up2.log -n 1000 -r';
			SYSTEM cStmt;
		
			
			LET cConteo3 = 0;
			
			SELECT COUNT(*)
			INTO cConteo3
			FROM tmp_sac_app_revi_621028_2;
			
			IF cConteo3 IS NULL THEN 
				LET cConteo3 = 0;
			END IF;
			
			
			
			IF cConteo = cConteo2 AND cConteo = cConteo3 THEN 
				
				LET cConteoRevi = cConteo;
				
				--LET cStmt= 'dbaccess bdisac	/RESPALDOSNEW/tmp_sac_app_revi_621028_up.sql';
				--SYSTEM cStmt;
				
				LET cStmt = "";
				LET cStmt = 'dbload -d bdisac -c /RESPALDOSNEW/tmp_sac_app_revi_621028_up.sql -l /RESPALDOSNEW/tmp_sac_app_revi_621028_up.log -n 1000 -r';
				SYSTEM cStmt;
				
				LET cConteo4 = 0;
				BEGIN WORK;
				FOREACH WITH HOLD
					select unirefnum,fecha 
					into cNo_row, cFh
					from tmp_sac_app_revi_621028

					
					DELETE FROM "informix".sac_app_revi WHERE unirefnum = cNo_row AND fecha = cFh;
					
					LET cConteo4 = cConteo4 + 1;						
					IF cConteo4 = 1000 THEN
						COMMIT WORK;
						LET cConteo4 = 0;
						BEGIN WORK;
					END IF;			
					
				END FOREACH;
				
				IF cConteo4 <> 0 THEN 
					COMMIT WORK;
					LET cConteo4 = 0;
					--BEGIN WORK;
				END IF;
			
				DROP TABLE IF EXISTS tmp_sac_app_revi_621028;
				DROP TABLE IF EXISTS tmp_sac_app_revi_621028_2;
				
				LET cStmt = 'rm -f /RESPALDOSNEW/tmp_sac_app_revi_621028.sql';
				SYSTEM cStmt;
				LET cStmt = 'rm -f /RESPALDOSNEW/tmp_sac_app_revi_621028_up.sql';
				SYSTEM cStmt;
				LET cStmt = 'rm -f /RESPALDOSNEW/tmp_sac_app_revi_621028_up2.sql';
				SYSTEM cStmt;
				LET cStmt = 'rm -f /RESPALDOSNEW/tmp_sac_app_revi_621028.unl';
				SYSTEM cStmt;
				LET cStmt = 'rm -f /RESPALDOSNEW/tmp_sac_app_revi_621028_up.log';
				SYSTEM cStmt;
				LET cStmt = 'rm -f /RESPALDOSNEW/tmp_sac_app_revi_621028_up2.log';
				SYSTEM cStmt;
				
				--DELETE FROM sac_app_revi WHERE fecha <= EXTEND((today - cDiasRespaldos), YEAR to SECOND)+24 UNITS HOUR+60 UNITS MINUTE+60 UNITS SECOND;
			ELSE 
				
				LET cCodRet = "00006";				
				LET cMensaje =  "Verificar Diferencias en Proceso|";
				LET cConteoRevi = cConteo||"-"||cConteo2||"-"||cConteo3;

			END IF;

		END IF;

	/*FIN DEPURACION sac_app_revi*/
		
		
	/*DEPURACION sac_ws_ccta*/
		
		LET cConteo = 0;
				
		SELECT COUNT(*)
		INTO cConteo
		FROM sac_ws_ccta
		WHERE fecha_insert <= EXTEND((today - cDiasRespaldos), YEAR to SECOND)+24 UNITS HOUR+60 UNITS MINUTE+60 UNITS SECOND;
		
		IF cConteo IS NULL THEN 
			LET cConteo = 0;
		END IF;
		
		IF cConteo <> 0 THEN 
			DROP TABLE IF EXISTS tmp_sac_ws_ccta_621028;
			DROP TABLE IF EXISTS tmp_sac_ws_ccta_621028_2;
			
			LET cStmt = 'rm -f /RESPALDOSNEW/tmp_sac_ws_ccta_621028.sql';
			SYSTEM cStmt;
			LET cStmt = 'rm -f /RESPALDOSNEW/tmp_sac_ws_ccta_621028_up.sql';
			SYSTEM cStmt;
			LET cStmt = 'rm -f /RESPALDOSNEW/tmp_sac_ws_ccta_621028_up2.sql';
			SYSTEM cStmt;
			LET cStmt = 'rm -f /RESPALDOSNEW/tmp_sac_ws_ccta_621028.unl';
			SYSTEM cStmt;
			LET cStmt = 'rm -f /RESPALDOSNEW/tmp_sac_ws_ccta_621028_up.log';
			SYSTEM cStmt;
			LET cStmt = 'rm -f /RESPALDOSNEW/tmp_sac_ws_ccta_621028_up2.log';
			SYSTEM cStmt;
			
			
			SELECT *
			FROM sac_ws_ccta
			WHERE fecha_insert <= EXTEND((today - cDiasRespaldos), YEAR to SECOND)+24 UNITS HOUR+60 UNITS MINUTE+60 UNITS SECOND
			INTO tmp_sac_ws_ccta_621028;
			
			
			LET cStmt = 'echo "UNLOAD TO /RESPALDOSNEW/tmp_sac_ws_ccta_621028.unl SELECT * FROM tmp_sac_ws_ccta_621028;">/RESPALDOSNEW/tmp_sac_ws_ccta_621028.sql';
			SYSTEM cStmt;
			
			LET cStmt = 'chmod 777 /RESPALDOSNEW/tmp_sac_ws_ccta_621028.sql';
			SYSTEM cStmt;
			
					
			LET cStmt= 'dbaccess bdisac	/RESPALDOSNEW/tmp_sac_ws_ccta_621028.sql';
			SYSTEM cStmt;
					
			LET cStmt = 'chmod 777 /RESPALDOSNEW/tmp_sac_ws_ccta_621028.unl';
			SYSTEM cStmt;
			
			--LET cStmt = 'echo "LOAD FROM /RESPALDOSNEW/tmp_sac_ws_ccta_621028.unl INSERT INTO sac_ws_ccta_old;">/RESPALDOSNEW/tmp_sac_ws_ccta_621028_up.sql';
			--SYSTEM cStmt;
			
			
						
			LET cStmt = '';
			LET cStmt = ' echo "FILE /RESPALDOSNEW/tmp_sac_ws_ccta_621028.unl'||' DELIMITER '|| "'" || '|' || "'" || ' 31;' || '">/RESPALDOSNEW/tmp_sac_ws_ccta_621028_up.sql';
			SYSTEM cStmt;

			LET cStmt = '';
			LET cStmt = ' echo "INSERT INTO sac_ws_ccta_old;' || '">> /RESPALDOSNEW/tmp_sac_ws_ccta_621028_up.sql';
			SYSTEM cStmt;
			
			LET cStmt = '';
			LET cStmt = 'chmod 777 /RESPALDOSNEW/tmp_sac_ws_ccta_621028_up.sql';
			SYSTEM cStmt;
			
			/*
			LET cStmt = "";
			LET cStmt = 'dbload -d bdisac -c /RESPALDOSNEW/tmp_sac_ws_ccta_621028_up.sql -l /RESPALDOSNEW/tmp_sac_ws_ccta_621028_up.log -n 1000 -r';
			SYSTEM cStmt;
			*/

			LET cConteo2 = 0;
			
			SELECT COUNT(*)
			INTO cConteo2
			FROM tmp_sac_ws_ccta_621028;
			
			IF cConteo2 IS NULL THEN 
				LET cConteo2 = 0;
			END IF;
			
			SELECT FIRST 1 * FROM tmp_sac_ws_ccta_621028 INTO tmp_sac_ws_ccta_621028_2;
			
			TRUNCATE TABLE tmp_sac_ws_ccta_621028_2;
			
			/*
			LET cStmt = 'echo "LOAD FROM /RESPALDOSNEW/tmp_sac_ws_ccta_621028.unl INSERT INTO tmp_sac_ws_ccta_621028_2;">/RESPALDOSNEW/tmp_sac_ws_ccta_621028_up2.sql';
			SYSTEM cStmt;
			
			LET cStmt= 'dbaccess bdisac	/RESPALDOSNEW/tmp_sac_ws_ccta_621028_up2.sql';
			SYSTEM cStmt;
			*/
			
						
			LET cStmt = '';
			LET cStmt = ' echo "FILE /RESPALDOSNEW/tmp_sac_ws_ccta_621028.unl'||' DELIMITER '|| "'" || '|' || "'" || ' 31;' || '">/RESPALDOSNEW/tmp_sac_ws_ccta_621028_up2.sql';
			SYSTEM cStmt;
			
			LET cStmt = '';
			LET cStmt = ' echo "INSERT INTO tmp_sac_ws_ccta_621028_2;' || '">> /RESPALDOSNEW/tmp_sac_ws_ccta_621028_up2.sql';
			SYSTEM cStmt;
			
			LET cStmt = '';
			LET cStmt = 'chmod 777 /RESPALDOSNEW/tmp_sac_ws_ccta_621028_up2.sql';
			SYSTEM cStmt;
			
			
			LET cStmt = "";
			LET cStmt = 'dbload -d bdisac -c /RESPALDOSNEW/tmp_sac_ws_ccta_621028_up2.sql -l /RESPALDOSNEW/tmp_sac_ws_ccta_621028_up2.log -n 1000 -r';
			SYSTEM cStmt;
			
			
			LET cConteo3 = 0;
			
			SELECT COUNT(*)
			INTO cConteo3
			FROM tmp_sac_ws_ccta_621028_2;
			
			IF cConteo3 IS NULL THEN 
				LET cConteo3 = 0;
			END IF;
			
			
			
			IF cConteo = cConteo2 AND cConteo = cConteo3 THEN 
				
				LET cConteoCcta = cConteo;
				
				--LET cStmt= 'dbaccess bdisac	/RESPALDOSNEW/tmp_sac_ws_ccta_621028_up.sql';
				--SYSTEM cStmt;
				
				LET cStmt = "";
				LET cStmt = 'dbload -d bdisac -c /RESPALDOSNEW/tmp_sac_ws_ccta_621028_up.sql -l /RESPALDOSNEW/tmp_sac_ws_ccta_621028_up.log -n 1000 -r';
				SYSTEM cStmt;
				
				LET cConteo4 = 0;
				BEGIN WORK;
				FOREACH WITH HOLD
					select num_cta,fecha_insert 
					into cNo_row, cFh
					from tmp_sac_ws_ccta_621028

					
					DELETE FROM "informix".sac_ws_ccta WHERE num_cta = cNo_row AND fecha_insert = cFh;
					
					LET cConteo4 = cConteo4 + 1;						
					IF cConteo4 = 1000 THEN
						COMMIT WORK;
						LET cConteo4 = 0;
						BEGIN WORK;
					END IF;			
					
				END FOREACH;
				
				IF cConteo4 <> 0 THEN 
					COMMIT WORK;
					LET cConteo4 = 0;
					--BEGIN WORK;
				END IF;
			
				DROP TABLE IF EXISTS tmp_sac_ws_ccta_621028;
				DROP TABLE IF EXISTS tmp_sac_ws_ccta_621028_2;
				
				LET cStmt = 'rm -f /RESPALDOSNEW/tmp_sac_ws_ccta_621028.sql';
				SYSTEM cStmt;
				LET cStmt = 'rm -f /RESPALDOSNEW/tmp_sac_ws_ccta_621028_up.sql';
				SYSTEM cStmt;
				LET cStmt = 'rm -f /RESPALDOSNEW/tmp_sac_ws_ccta_621028_up2.sql';
				SYSTEM cStmt;
				LET cStmt = 'rm -f /RESPALDOSNEW/tmp_sac_ws_ccta_621028.unl';
				SYSTEM cStmt;
				LET cStmt = 'rm -f /RESPALDOSNEW/tmp_sac_ws_ccta_621028_up.log';
				SYSTEM cStmt;
				LET cStmt = 'rm -f /RESPALDOSNEW/tmp_sac_ws_ccta_621028_up2.log';
				SYSTEM cStmt;
				
				--DELETE FROM sac_ws_ccta WHERE fecha_insert <= EXTEND((today - cDiasRespaldos), YEAR to SECOND)+24 UNITS HOUR+60 UNITS MINUTE+60 UNITS SECOND;
			ELSE 
				
				LET cCodRet = "00007";				
				LET cMensaje =  "Verificar Diferencias en Proceso|";
				LET cConteoCcta = cConteo||"-"||cConteo2||"-"||cConteo3;

			END IF;

		END IF;

	/*FIN DEPURACION sac_ws_ccta*/
	
	
	
		IF cCodRet = '00000' THEN 
			LET cCodRet = "00000";				
			LET cMensaje =  "Proceso Exitoso|";
			
			INSERT INTO sac_procesos_jobs (proceso,fecha_proceso,status,user_insert,fecha_insert,numero_ejecuciones,nombre_sp,descripcion)
			VALUES ('SAC_APP_DEPURACION',today,'1','informix',CURRENT,'1','sp_sac_app_depuracion','Depuracion Tablas Appriza '||cCodRet);
			
		ELSE 
			INSERT INTO sac_procesos_jobs (proceso,fecha_proceso,status,user_insert,fecha_insert,numero_ejecuciones,nombre_sp,descripcion)
			VALUES ('SAC_APP_DEPURACION',today,'0','informix',CURRENT,'1','sp_sac_app_depuracion','Depuracion Tablas Appriza Verificar '||cCodRet);
		END IF;
		
		LET cMensaje2 = 'Fecha|Payi|Qryi|GetOrder|RecOrder|ConfPaymnt|Revi|WsCcta|';
		LET cMensaje3 = cFecha_proceso||'|'||cConteoPayi||"|"||cConteoQryi||"|"||cConteoGetorder||"|"||cConteoRecordorder||"|"||cConteoConfpayment||"|"||cConteoRevi||"|"||cConteoCcta||"|";
		

					
		
		RETURN cCodRet,cMensaje,cMensaje2,cMensaje3;
		
	END;
END PROCEDURE;
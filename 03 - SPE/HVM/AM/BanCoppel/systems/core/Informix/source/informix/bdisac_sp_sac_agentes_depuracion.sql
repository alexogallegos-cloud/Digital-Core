CREATE PROCEDURE "informix".sp_sac_agentes_depuracion()

	RETURNING CHAR(5) AS Codigo_Respuesta, VARCHAR(200)  AS Mensaje_Respuesta, VARCHAR(200) AS Mensaje_Proceso, VARCHAR(200) AS Mensaje_Detalle;


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
	DEFINE cConteoAgent         VARCHAR(50);
	DEFINE cConteoQryi          VARCHAR(50);
	DEFINE cConteoGetorder 		VARCHAR(50);
	DEFINE cConteoRecordorder   VARCHAR(50);
	DEFINE cConteoConfpayment   VARCHAR(50);
	DEFINE cConteoRevi			VARCHAR(50);
	DEFINE cConteoCcta			VARCHAR(50);
	DEFINE cFecha_proceso 	    DATE;
    DEFINE dFecha_Hoy           DATE;
	DEFINE cDiasRespaldos 	    INTEGER;
	DEFINE cConteo  	     	INTEGER;
	DEFINE cConteo2  	     	INTEGER;
	DEFINE cConteo3  	     	INTEGER;
	DEFINE cVal 			    VARCHAR(50);
	DEFINE cFh					DATETIME YEAR to FRACTION(5);
	DEFINE cConteo4  	     	INTEGER;
	DEFINE vtransaccion	   		SMALLINT;
	DEFINE cDia                 CHAR (2);
	DEFINE cMes                 CHAR (2);
	DEFINE cAnio                CHAR (2);
	DEFINE cFecha_archivo       VARCHAR(10);
	DEFINE cRutaOltp            CHAR(50);
	
	
	--SET DEBUG FILE TO '/RESPALDOSNEW/enrique/sp_sac_agentes_depuracion.out';
	--TRACE ON; 
	
	-- Inicializa variables
	LET cCodRet            		= "00000";
	LET cMensaje				= "Proceso Exitoso|";
	LET cMensaje2				= '';
	LET cMensaje3				= '';
	LET cFecha_proceso 			= MDY('01','01','1900');
	LET cConteo 				= 0;
	LET cConteo2 				= 0;
	LET cConteo3 				= 0;
	LET cConteoAgent 			= '0';
	LET cConteoQryi 			= '0';
	LET cConteoGetorder 		= '0';
	LET cConteoRecordorder 		= '0';
	LET cConteoConfpayment 		= '0';
	LET cConteoRevi 			= '0';
	LET cConteoCcta 			= '0';
	LET cDiasRespaldos 			= 1;
	LET cVal					= '';
	LET cFh	 					= MDY('01','01','1900');
	LET cConteo4 				= 0;
	LET vtransaccion 			= 0;
	LET cStmt 					= '';
	LET cRutaArch 				= '';
	LET dFecha_Hoy   			= DATE(1);
	LET cDia          		  	= '';
    LET cMes          		 	= '';
    LET cAnio         		  	= '';
	LET cFecha_archivo			= 'AA_MM_DD';
	LET cRutaOltp      			= '/RESPALDOSNEW/depuraremesas/';
	LET cFecha_proceso = today;

	BEGIN
	
		ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
			--Manejo de errores, en caso de error, envÃÂ­o codigo de error y guarda evidencia
            IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;
                EXECUTE PROCEDURE bdisac:"informix".sp_sac_guardamensajeerror(iSqlErr, iIsamErr, cInfoErr, "sp_sac_agentes_depuracion");
								
				LET cMensaje = "ERROR EN LA EJECUCION DEL SP BDD";
				LET cMensaje2 = 'Fecha|Agentes|';
				LET cMensaje3 = cFecha_proceso||'|'||cConteoAgent||"|";
		
				
                RETURN cCodRet,cMensaje,cMensaje2,cMensaje3;
            END IF;
        END EXCEPTION;
		
		ON EXCEPTION IN (-535)
			COMMIT WORK;
		END EXCEPTION WITH RESUME;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
		
	    /*DEPURACION sac_agentes*/
		
		SELECT fecha_hoy 
		INTO dFecha_Hoy 
		FROM bdisac:"informix".sac_fechas
		WHERE empresa = "001";
		
		LET cDia = LPAD(DAY(dFecha_Hoy::DATE), 2, '0');
        LET cMEs = LPAD(MONTH(dFecha_Hoy::DATE), 2, '0');
        LET cAnio = LPAD(SUBSTRING(YEAR(dFecha_Hoy ::DATE) FROM 3 FOR 2), 2, '0'); 
		
		LET cFecha_archivo = REPLACE(cFecha_archivo,'AA',cAnio);
		LET cFecha_archivo = REPLACE(cFecha_archivo,'MM',cMes);
		LET cFecha_archivo = REPLACE(cFecha_archivo,'DD',cDia);
		
		LET cConteo = 0;
				
		SELECT COUNT(*)
		INTO cConteo
		FROM sac_agentes 
		WHERE fecha_insert::date <= TODAY - 7;
		
		IF cConteo IS NULL THEN 
			LET cConteo = 0;
		END IF;
		
		IF cConteo <> 0 THEN 
			--Elimina la tabla temporal en caso de que exista y los archivos que se crean
			DROP TABLE IF EXISTS tmp_sac_agentes_resp;
			LET cStmt = 'rm -f ' || TRIM(cRutaOltp) || 'tmp_sac_agentes_' || cFecha_archivo || '.sql';
			SYSTEM cStmt;
			LET cStmt = 'rm -f ' || TRIM(cRutaOltp) || 'tmp_sac_agentes_' || cFecha_archivo || '.unl';
			SYSTEM cStmt;
			LET cStmt = 'rm -f ' || TRIM(cRutaOltp) || 'tmp_sac_agentes_' || cFecha_archivo || '_hist.sql';
			SYSTEM cStmt;
			

			SELECT *
			FROM sac_agentes 
			WHERE fecha_insert::date <= TODAY - 7
			INTO tmp_sac_agentes_resp;
			
			---Crea el archivo UNL y se depositan en la ruta /RESPALDOSNEW/depuraremesas/
			
			LET cStmt = 'echo "UNLOAD TO ' || TRIM(cRutaOltp) || 'tmp_sac_agentes_' || cFecha_archivo || '.unl SELECT * FROM tmp_sac_agentes_resp;">' || TRIM(cRutaOltp) || 'tmp_sac_agentes_' || cFecha_archivo || '.sql';
			SYSTEM cStmt;
			
			LET cStmt = 'chmod 777 ' || TRIM(cRutaOltp) || 'tmp_sac_agentes_' || cFecha_archivo || '.sql';
			SYSTEM cStmt;
						
			LET cStmt= 'dbaccess bdisac	' || TRIM(cRutaOltp) || 'tmp_sac_agentes_' || cFecha_archivo || '.sql';
			SYSTEM cStmt;
			
			LET cStmt = 'chmod 777 ' || TRIM(cRutaOltp) || 'tmp_sac_agentes_' || cFecha_archivo || '.unl';
			SYSTEM cStmt;
			
			--Carga el archivo que se genero a la tabla historica

			/*LET cStmt = 'echo "LOAD FROM ' || TRIM(cRutaOltp) || 'tmp_sac_agentes_' || cFecha_archivo || '.unl INSERT INTO sac_agentes_hist;">' || TRIM(cRutaOltp) || 'tmp_sac_agentes_' || cFecha_archivo || '_hist.sql';
			SYSTEM cStmt;

			LET cStmt = 'chmod 777 ' || TRIM(cRutaOltp) || 'tmp_sac_agentes_' || cFecha_archivo || '_hist.sql';
			SYSTEM cStmt;
			LET cStmt= 'dbaccess bdisac ' || TRIM(cRutaOltp) || 'tmp_sac_agentes_' || cFecha_archivo || '_hist.sql';
			SYSTEM cStmt;*/
			
			LET cStmt = '';
			LET cStmt = ' echo "FILE ' || TRIM(cRutaOltp) || 'tmp_sac_agentes_' || cFecha_archivo || '.unl ' ||' DELIMITER '|| "'" || '|' || "'" || ' 4;' || '">' || TRIM(cRutaOltp) || 'tmp_sac_agentes_' || cFecha_archivo || '_hist.sql';
			SYSTEM cStmt;

			LET cStmt = '';
			LET cStmt = ' echo "INSERT INTO sac_agentes_hist;' || '">> ' || TRIM(cRutaOltp) || 'tmp_sac_agentes_' || cFecha_archivo || '_hist.sql';
			SYSTEM cStmt;
			
			LET cStmt = '';
			LET cStmt = 'chmod 777 ' || TRIM(cRutaOltp) || 'tmp_sac_agentes_' || cFecha_archivo || '_hist.sql';
			SYSTEM cStmt;
			
			LET cStmt = "";
			LET cStmt = 'dbload -d bdisac -c ' || TRIM(cRutaOltp) || 'tmp_sac_agentes_' || cFecha_archivo || '_hist.sql -l ' || TRIM(cRutaOltp) || 'tmp_sac_agentes_' || cFecha_archivo || '_hist.log -n 1000 -r';
			SYSTEM cStmt;
			
			LET cConteo2 = 0;
			
			SELECT COUNT(*)
			INTO cConteo2
			FROM tmp_sac_agentes_resp;
			
			IF cConteo2 IS NULL THEN 
				LET cConteo2 = 0;
			END IF;
			
				
			IF cConteo = cConteo2 THEN 
				
				LET cConteoAgent = cConteo;
				LET cConteo4 = 0;
				BEGIN WORK;
				FOREACH WITH HOLD
					select val,fecha_insert 
					into cVal, cFh
					from tmp_sac_agentes_resp

					
					DELETE FROM "informix".sac_agentes WHERE val = cVal AND fecha_insert = cFh;
					
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
					
			ELSE 
				LET cCodRet = "00001";				
				LET cMensaje =  "Verificar Diferencias en Proceso";
				LET cConteoAgent = cConteo||"-"||cConteo2;

			END IF;
		END IF;
		/*FIN DEPURACION sac_agentes*/
	
		IF cCodRet = '00000' THEN 
			LET cCodRet = "00000";				
			LET cMensaje =  "Proceso Exitoso";
			
			UPDATE STATISTICS MEDIUM FOR TABLE "informix".sac_agentes;
			UPDATE STATISTICS MEDIUM FOR TABLE "informix".sac_agentes_hist;
	
			INSERT INTO sac_procesos_jobs (proceso,fecha_proceso,status,user_insert,fecha_insert,numero_ejecuciones,nombre_sp,descripcion)
			VALUES ('SAC_AGENTES_DEP',today,'1','informix',CURRENT,'1','sp_sac_agentes_depuracion','Depuracion Tablas Agentes'|| ' ' || cCodRet);
			--Si el proceso es exitoso elimina los archivos y elimina la tabla temporal 
			DROP TABLE IF EXISTS tmp_sac_agentes_resp;	
			--Elimina los archivos despues de ser procesados
			LET cStmt = 'rm -f ' || TRIM(cRutaOltp) || 'tmp_sac_agentes_' || cFecha_archivo || '.sql';
			SYSTEM cStmt;
			LET cStmt = 'rm -f ' || TRIM(cRutaOltp) || 'tmp_sac_agentes_' || cFecha_archivo || '.unl';
			SYSTEM cStmt;
			LET cStmt = 'rm -f ' || TRIM(cRutaOltp) || 'tmp_sac_agentes_' || cFecha_archivo || '_hist.sql';
			SYSTEM cStmt;
			LET cStmt = 'rm -f ' || TRIM(cRutaOltp) || 'tmp_sac_agentes_' || cFecha_archivo || '_hist.log';
			SYSTEM cStmt;
		ELSE 
			INSERT INTO sac_procesos_jobs (proceso,fecha_proceso,status,user_insert,fecha_insert,numero_ejecuciones,nombre_sp,descripcion)
			VALUES ('SAC_AGENTES_DEP',today,'0','informix',CURRENT,'1','sp_sac_agentes_depuracion','Depuracion Tablas Agentes'|| ' ' || cCodRet);
		END IF;
		
		LET cMensaje2 = 'Fecha|Agentes|';
		LET cMensaje3 = cFecha_proceso||'|'||cConteoAgent||"|";
		
		RETURN cCodRet,cMensaje,cMensaje2,cMensaje3;
		
	END;
END PROCEDURE;
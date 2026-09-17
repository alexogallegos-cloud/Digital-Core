CREATE PROCEDURE "informix".sp_updgenero_cte_remesa(pNumcte CHAR (9),pSexo CHAR (1),pEmpresa CHAR (3))
RETURNING   CHAR(5),CHAR(50);

DEFINE iSqlErr 			INTEGER;
DEFINE cCodret 			CHAR (5);
DEFINE cDescripcion 	CHAR (50);

LET iSqlErr  = 0;
LET cCodret  = '00000';
LET cDescripcion = '';
	
BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN			
			LET cCodRet = iSqlErr;			
			RETURN cCodRet, cDescripcion; 
	   END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO '/tmp/Guicho/sp_updgenero_cte_remesa.out';
	--TRACE ON;	
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;

	IF NVL(pEmpresa,'')='' OR  NVL(pSexo,'')='' OR  NVL(pNumcte,'')= ''  THEN	
			LET cCodRet = '00002'; --Si algun parametro se encuentra vacio.
			LET cDescripcion = "Parametros de Entrada Requeridos";
			RETURN cCodRet, cDescripcion;
	END IF;

		UPDATE bdinteg:"informix".si_ctepf SET sexo = pSexo WHERE numcte = pNumcte AND empresa = pEmpresa;
	 
		IF dbinfo("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet= "00001";
			LET cDescripcion = "Update no realizado";
			RETURN TRIM(cCodRet), TRIM(cDescripcion);
        ELSE			
			LET cDescripcion = "Exitoso";
		END IF;
		
        
		
	RETURN  cCodret, cDescripcion;
END;
END PROCEDURE
DOCUMENT
' Folio      : 1992',  
' Autor      : Hector Hazael Aguilar Arteaga / Jesus Ivan Garcia Guicho',
' Fecha      : 17/01/2022',
' Descripcion: se crea SP para actualizar el valor del campo sexo, para clientes Banco que aun no son usuarios Remesas que no contengan',
'              en ese momento el campo sexo en la tabla si_ctepf por ser altas de origen del proceso de Dictamen Unificado.',  
' Solicito   : Hector Miguel Loera Guzman / Leonardo Hernandez Moreno',
' BD         : bdisac';

CREATE PROCEDURE "informix".sp_sac_wu_depuracion()

	RETURNING CHAR(5), VARCHAR(200), VARCHAR(200), VARCHAR(200);


		--Definicion de Variables
    DEFINE cCodRet          	    CHAR(5);
    DEFINE iSqlErr				    INTEGER;
	DEFINE iIsamErr 			    INTEGER;
    DEFINE cInfoErr         	    CHAR(100);
	DEFINE cMensaje				    VARCHAR(200);
	DEFINE cMensaje2			    VARCHAR(200);
	DEFINE cMensaje3			    VARCHAR(200);
	DEFINE cRutaArch 			    CHAR(100);
	DEFINE cStmt 				    CHAR (500);
	DEFINE cConteoPay               VARCHAR(50);
	DEFINE cConteoSearch            VARCHAR(50);
	DEFINE cConteoCancel 		    VARCHAR(50);
	DEFINE cFecha_proceso 	        DATE;
	
	DEFINE cDiasRespaldos			INTEGER;
	DEFINE cDiasRespaldosG 	    	VARCHAR(5);
	DEFINE cDiasRespaldosPAY		INTEGER;
	DEFINE cDiasRespaldosSEARCH		INTEGER;
	DEFINE cDiasRespaldosCANCEL		INTEGER;
	
	
	DEFINE cConteo  	     	    INTEGER;
	DEFINE cConteo2  	     	    INTEGER;
	DEFINE cConteo3  	     	    INTEGER;
	
	DEFINE cNo_row			        VARCHAR(50);
	DEFINE cFh					    DATETIME YEAR to FRACTION(5);
	DEFINE cConteo4  	     	    INTEGER;
	DEFINE vtransaccion	   		    SMALLINT;
	DEFINE cConf_pago 			    VARCHAR(5);
	DEFINE cForeign_rs_refnum_rq    VARCHAR(20);
	DEFINE cRutaOltp                CHAR(50);
	DEFINE dFecha_Hoy               DATE;
	DEFINE cDia                 	CHAR (2);
	DEFINE cMes                 	CHAR (2);
	DEFINE cAnio                	CHAR (2);
	DEFINE cFecha_archivo       	VARCHAR(10);

	--SET DEBUG FILE TO '/RESPALDOSNEW/enrique/sp_sac_wu_depuracion.out';
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
	LET cConteoPay = '0';
    LET cConteoSearch = '0';
	LET cConteoCancel = '0';
	LET cDiasRespaldos = 0;
	LET cDiasRespaldosG = '';
	LET cDiasRespaldosPAY = 0;
	LET cDiasRespaldosSEARCH = 0;
	LET cDiasRespaldosCANCEL = 0;
	LET cNo_row				= '';
	LET cFh	 			= MDY('01','01','1900');
	LET cConteo4 	= 0;
	LET vtransaccion 	= 0;
	LET cConf_pago = '';
	LET cForeign_rs_refnum_rq = '';
	LET cStmt = '';
	LET cRutaArch = '';
	LET cFecha_proceso = today;
	LET dFecha_Hoy   			= DATE(1);
	LET cDia          		  	= '';
    LET cMes          		 	= '';
    LET cAnio         		  	= '';
	LET cFecha_archivo			= 'AA_MM_DD';
	LET cRutaOltp = '/RESPALDOSNEW/depuraremesas/';

	BEGIN
	
		ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
			--Manejo de errores, en caso de error, envÃ­o codigo de error y guarda evidencia
            IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;
                EXECUTE PROCEDURE bdisac:"informix".sp_sac_guardamensajeerror(iSqlErr, iIsamErr, cInfoErr, "sp_sac_wu_depuracion");
								
				LET cMensaje = "ERROR EN LA EJECUCION DEL SP BDD";
				LET cMensaje2 = 'Fecha|Sac_Wu_Pay|Saw_Wu_Search|Cancel_Pay|';
				LET cMensaje3 = cFecha_proceso||'|'||cConteoPay||"|" ||cConteoSearch||"|" ||cConteoCancel||"|";
		
				
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
		
	
		--DIAS PARA MIGRACION A PROCESOS HISTORICOS
		
		SELECT valor 
		INTO cDiasRespaldosG
		FROM sac_param
		WHERE cod_param = 147;
		
		IF cDiasRespaldosG IS NULL OR cDiasRespaldosG = "" THEN 
			LET cDiasRespaldosG = 'I';
		END IF;
		

	IF 	cDiasRespaldosG = 'A' THEN
		
		/*DEPURACION sac_wu_pay*/
		
			SELECT valor 
			INTO cDiasRespaldosPAY
			FROM sac_param
			WHERE cod_param = 148;
			
			IF cDiasRespaldosPAY IS NULL OR cDiasRespaldosPAY = 0 THEN 
				LET cDiasRespaldosPAY = '95';
			END IF;
			
			LET cConteo = 0;
					
			SELECT COUNT(*)
			INTO cConteo
			FROM sac_wu_pay 
			WHERE fecha_insert <= EXTEND((today - cDiasRespaldosPAY), YEAR to SECOND)+24 UNITS HOUR+60 UNITS MINUTE+60 UNITS SECOND;
			
			IF cConteo IS NULL THEN 
				LET cConteo = 0;
			END IF;
			
			IF cConteo <> 0 THEN 
				DROP TABLE IF EXISTS tmp_sac_wu_pay_621048;
				DROP TABLE IF EXISTS tmp_sac_wu_pay_621048_2;
				LET cStmt = 'rm -f ' || TRIM(cRutaOltp) || 'tmp_sac_wu_pay_' || TRIM(cFecha_archivo) || '.sql';
				SYSTEM cStmt;
				LET cStmt = 'rm -f ' || TRIM(cRutaOltp) || 'tmp_sac_wu_pay_' || TRIM(cFecha_archivo) || '_up.sql';
				SYSTEM cStmt;
				LET cStmt = 'rm -f ' || TRIM(cRutaOltp) || 'tmp_sac_wu_pay_' || TRIM(cFecha_archivo) || '_up.log';
				SYSTEM cStmt;
				LET cStmt = 'rm -f ' || TRIM(cRutaOltp) || 'tmp_sac_wu_pay_' || TRIM(cFecha_archivo) || '.unl';
				SYSTEM cStmt;
				
				
				SELECT *
				FROM sac_wu_pay 
				WHERE fecha_insert <= EXTEND((today - cDiasRespaldosPAY), YEAR to SECOND)+24 UNITS HOUR+60 UNITS MINUTE+60 UNITS SECOND
				INTO tmp_sac_wu_pay_621048;
				
				
				LET cStmt = 'echo "UNLOAD TO ' || TRIM(cRutaOltp) || 'tmp_sac_wu_pay_' || TRIM(cFecha_archivo) || '.unl SELECT * FROM tmp_sac_wu_pay_621048;">' || TRIM(cRutaOltp) || 'tmp_sac_wu_pay_' || TRIM(cFecha_archivo) || '.sql';
				SYSTEM cStmt;
				
				
				LET cStmt = 'chmod 777 ' || TRIM(cRutaOltp) || 'tmp_sac_wu_pay_' || TRIM(cFecha_archivo) || '.sql';
				SYSTEM cStmt;
							
				LET cStmt= 'dbaccess bdisac	' || TRIM(cRutaOltp) || 'tmp_sac_wu_pay_' || TRIM(cFecha_archivo) || '.sql';
				SYSTEM cStmt;
				
				LET cStmt = 'chmod 777 ' || TRIM(cRutaOltp) || 'tmp_sac_wu_pay_' || TRIM(cFecha_archivo) || '.unl';
				SYSTEM cStmt;
				
				LET cStmt = '';
				LET cStmt = ' echo "FILE ' || TRIM(cRutaOltp) || 'tmp_sac_wu_pay_' || TRIM(cFecha_archivo) || '.unl'||' DELIMITER '|| "'" || '|' || "'" || ' 60;' || '">' || TRIM(cRutaOltp) || 'tmp_sac_wu_pay_' || TRIM(cFecha_archivo) || '_up.sql';
				SYSTEM cStmt;

				LET cStmt = '';
				LET cStmt = ' echo "INSERT INTO sac_wu_pay_old;' || '">> ' || TRIM(cRutaOltp) || 'tmp_sac_wu_pay_' || TRIM(cFecha_archivo) || '_up.sql';
				SYSTEM cStmt;
				
				LET cStmt = '';
				LET cStmt = 'chmod 777 ' || TRIM(cRutaOltp) || 'tmp_sac_wu_pay_' || TRIM(cFecha_archivo) || '_up.sql';
				SYSTEM cStmt;
				
				LET cStmt = "";
				LET cStmt = 'dbload -d bdisac -c ' || TRIM(cRutaOltp) || 'tmp_sac_wu_pay_' || cFecha_archivo || '_up.sql -l ' || TRIM(cRutaOltp) || 'tmp_sac_wu_pay_' || cFecha_archivo || '_up.log -n 1000 -r';
				SYSTEM cStmt;
				
				
				LET cConteo2 = 0;
				
				SELECT COUNT(*)
				INTO cConteo2
				FROM tmp_sac_wu_pay_621048;
				
				IF cConteo2 IS NULL THEN 
					LET cConteo2 = 0;
				END IF;
					
					
				IF cConteo = cConteo2 THEN 
					
					LET cConteoPay = cConteo;
					
					
					LET cConteo4 = 0;
					BEGIN WORK;
					FOREACH WITH HOLD
						SELECT mtcn,fecha_insert,conf_pago,foreign_rs_refnum_rq 
						INTO cNo_row, cFh,cConf_pago,cForeign_rs_refnum_rq
						FROM tmp_sac_wu_pay_621048

							DELETE FROM "informix".sac_wu_pay WHERE mtcn = cNo_row AND fecha_insert = cFh AND conf_pago = cConf_pago AND foreign_rs_refnum_rq = cForeign_rs_refnum_rq;
						
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
				
					UPDATE STATISTICS MEDIUM FOR TABLE "informix".sac_wu_pay;
					UPDATE STATISTICS MEDIUM FOR TABLE "informix".sac_wu_pay_old;
					
					DROP TABLE IF EXISTS tmp_sac_wu_pay_621048;
					DROP TABLE IF EXISTS tmp_sac_wu_pay_621048_2;
					LET cStmt = 'rm -f ' || TRIM(cRutaOltp) || 'tmp_sac_wu_pay_' || TRIM(cFecha_archivo) || '.sql';
					SYSTEM cStmt;
					LET cStmt = 'rm -f ' || TRIM(cRutaOltp) || 'tmp_sac_wu_pay_' || TRIM(cFecha_archivo) || '_up.sql';
					SYSTEM cStmt;
					LET cStmt = 'rm -f ' || TRIM(cRutaOltp) || 'tmp_sac_wu_pay_' || TRIM(cFecha_archivo) || '_up.log';
					SYSTEM cStmt;
					LET cStmt = 'rm -f ' || TRIM(cRutaOltp) || 'tmp_sac_wu_pay_' || TRIM(cFecha_archivo) || '.unl';
					SYSTEM cStmt;
					LET cCodRet = "00000";
				ELSE 
					LET cCodRet = "00001";				
					LET cMensaje =  "Verificar Diferencias en Proceso|";
					LET cConteoPay = cConteo||"-"||cConteo2||"-"||cConteo3;

				END IF;

			END IF;

		/*FIN DEPURACION sac_wu_pay*/
		
		/*DEPURACION sac_wu_search*/
		
			SELECT valor 
			INTO cDiasRespaldosSEARCH
			FROM sac_param
			WHERE cod_param = 149;
			
			IF cDiasRespaldosSEARCH IS NULL OR cDiasRespaldosSEARCH = 0 THEN 
				LET cDiasRespaldosSEARCH = '95';
			END IF;
			
			LET cConteo = 0;
					
			SELECT COUNT(*)
			INTO cConteo
			FROM sac_wu_search 
			WHERE fecha_insert <= EXTEND((today - cDiasRespaldosSEARCH), YEAR to SECOND)+24 UNITS HOUR+60 UNITS MINUTE+60 UNITS SECOND;
			
			IF cConteo IS NULL THEN 
				LET cConteo = 0;
			END IF;
			
			IF cConteo <> 0 THEN 
				DROP TABLE IF EXISTS tmp_sac_wu_search_621048;
				DROP TABLE IF EXISTS tmp_sac_wu_search_621048_2;
				LET cStmt = 'rm -f ' || TRIM(cRutaOltp) || 'tmp_sac_wu_search_' || TRIM(cFecha_archivo) || '.sql';
				SYSTEM cStmt;
				LET cStmt = 'rm -f ' || TRIM(cRutaOltp) || 'tmp_sac_wu_search_' || TRIM(cFecha_archivo) || '_up.sql';
				SYSTEM cStmt;
				LET cStmt = 'rm -f ' || TRIM(cRutaOltp) || 'tmp_sac_wu_search_' || TRIM(cFecha_archivo) || '_up.log';
				SYSTEM cStmt;
				LET cStmt = 'rm -f ' || TRIM(cRutaOltp) || 'tmp_sac_wu_search_' || TRIM(cFecha_archivo) || '.unl';
				SYSTEM cStmt;
				
				
				SELECT *
				FROM sac_wu_search 
				WHERE fecha_insert <= EXTEND((today - cDiasRespaldosSEARCH), YEAR to SECOND)+24 UNITS HOUR+60 UNITS MINUTE+60 UNITS SECOND
				INTO tmp_sac_wu_search_621048;
				
				
				LET cStmt = 'echo "UNLOAD TO ' || TRIM(cRutaOltp) || 'tmp_sac_wu_search_' || TRIM(cFecha_archivo) || '.unl SELECT * FROM tmp_sac_wu_search_621048;">' || TRIM(cRutaOltp) || 'tmp_sac_wu_search_' || TRIM(cFecha_archivo) || '.sql';
				SYSTEM cStmt;
				
				
				LET cStmt = 'chmod 777 ' || TRIM(cRutaOltp) || 'tmp_sac_wu_search_' || TRIM(cFecha_archivo) || '.sql';
				SYSTEM cStmt;
							
				LET cStmt= 'dbaccess bdisac	' || TRIM(cRutaOltp) || 'tmp_sac_wu_search_' || TRIM(cFecha_archivo) || '.sql';
				SYSTEM cStmt;
				
				LET cStmt = 'chmod 777 ' || TRIM(cRutaOltp) || 'tmp_sac_wu_search_' || TRIM(cFecha_archivo) || '.unl';
				SYSTEM cStmt;
				
				LET cStmt = '';
				LET cStmt = ' echo "FILE ' || TRIM(cRutaOltp) || 'tmp_sac_wu_search_' || TRIM(cFecha_archivo) || '.unl'||' DELIMITER '|| "'" || '|' || "'" || ' 58;' || '">' || TRIM(cRutaOltp) || 'tmp_sac_wu_search_' || TRIM(cFecha_archivo) || '_up.sql';
				SYSTEM cStmt;

				LET cStmt = '';
				LET cStmt = ' echo "INSERT INTO sac_wu_search_old;' || '">> ' || TRIM(cRutaOltp) || 'tmp_sac_wu_search_' || TRIM(cFecha_archivo) || '_up.sql';
				SYSTEM cStmt;
				
				LET cStmt = '';
				LET cStmt = 'chmod 777 ' || TRIM(cRutaOltp) || 'tmp_sac_wu_search_' || TRIM(cFecha_archivo) || '_up.sql';
				SYSTEM cStmt;
				
				LET cStmt = "";
				LET cStmt = 'dbload -d bdisac -c ' || TRIM(cRutaOltp) || 'tmp_sac_wu_search_' || cFecha_archivo || '_up.sql -l ' || TRIM(cRutaOltp) || 'tmp_sac_wu_search_' || cFecha_archivo || '_up.log -n 1000 -r';
				SYSTEM cStmt;
				
				
				LET cConteo2 = 0;
				
				SELECT COUNT(*)
				INTO cConteo2
				FROM tmp_sac_wu_search_621048;
				
				IF cConteo2 IS NULL THEN 
					LET cConteo2 = 0;
				END IF;
					
					
				IF cConteo = cConteo2 THEN 
					
					LET cConteoSearch = cConteo;
					
					
					LET cConteo4 = 0;
					BEGIN WORK;
					FOREACH WITH HOLD
						SELECT mtcn,fecha_insert,foreign_rs_refnum_rq 
						INTO cNo_row,cFh,cForeign_rs_refnum_rq
						FROM tmp_sac_wu_search_621048

							DELETE FROM "informix".sac_wu_search WHERE mtcn = cNo_row AND fecha_insert = cFh AND foreign_rs_refnum_rq = cForeign_rs_refnum_rq;
						
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
				
					UPDATE STATISTICS MEDIUM FOR TABLE "informix".sac_wu_search;
					UPDATE STATISTICS MEDIUM FOR TABLE "informix".sac_wu_search_old;
					
					DROP TABLE IF EXISTS tmp_sac_wu_search_621048;
					DROP TABLE IF EXISTS tmp_sac_wu_search_621048_2;
					LET cStmt = 'rm -f ' || TRIM(cRutaOltp) || 'tmp_sac_wu_search_' || TRIM(cFecha_archivo) || '.sql';
					SYSTEM cStmt;
					LET cStmt = 'rm -f ' || TRIM(cRutaOltp) || 'tmp_sac_wu_search_' || TRIM(cFecha_archivo) || '_up.sql';
					SYSTEM cStmt;
					LET cStmt = 'rm -f ' || TRIM(cRutaOltp) || 'tmp_sac_wu_search_' || TRIM(cFecha_archivo) || '_up.log';
					SYSTEM cStmt;
					LET cStmt = 'rm -f ' || TRIM(cRutaOltp) || 'tmp_sac_wu_search_' || TRIM(cFecha_archivo) || '.unl';
					SYSTEM cStmt;
					LET cCodRet = "00000";
				ELSE 
					LET cCodRet = "00001";				
					LET cMensaje =  "Verificar Diferencias en Proceso|";
					LET cConteoPay = cConteo||"-"||cConteo2||"-"||cConteo3;

				END IF;

			END IF;

		/*FIN DEPURACION sac_wu_search*/
		
		/*DEPURACION sac_wu_cancelpay*/
		
			SELECT valor 
			INTO cDiasRespaldosCANCEL
			FROM sac_param
			WHERE cod_param = 150;
			
			IF cDiasRespaldosCANCEL IS NULL OR cDiasRespaldosCANCEL = 0 THEN 
				LET cDiasRespaldosCANCEL = '95';
			END IF;
			
			LET cConteo = 0;
					
			SELECT COUNT(*)
			INTO cConteo
			FROM sac_wu_cancelpay 
			WHERE fecha_insert <= EXTEND((today - cDiasRespaldosCANCEL), YEAR to SECOND)+24 UNITS HOUR+60 UNITS MINUTE+60 UNITS SECOND;
			
			IF cConteo IS NULL THEN 
				LET cConteo = 0;
			END IF;
			
			IF cConteo <> 0 THEN 
				DROP TABLE IF EXISTS tmp_sac_wu_cancelpay_621048;
				DROP TABLE IF EXISTS tmp_sac_wu_cancelpay_621048_2;
				LET cStmt = 'rm -f ' || TRIM(cRutaOltp) || 'tmp_sac_wu_cancelpay_' || TRIM(cFecha_archivo) || '.sql';
				SYSTEM cStmt;
				LET cStmt = 'rm -f ' || TRIM(cRutaOltp) || 'tmp_sac_wu_cancelpay_' || TRIM(cFecha_archivo) || '_up.sql';
				SYSTEM cStmt;
				LET cStmt = 'rm -f ' || TRIM(cRutaOltp) || 'tmp_sac_wu_cancelpay_' || TRIM(cFecha_archivo) || '_up.log';
				SYSTEM cStmt;
				LET cStmt = 'rm -f ' || TRIM(cRutaOltp) || 'tmp_sac_wu_cancelpay_' || TRIM(cFecha_archivo) || '.unl';
				SYSTEM cStmt;
				
				
				SELECT *
				FROM sac_wu_cancelpay 
				WHERE fecha_insert <= EXTEND((today - cDiasRespaldosCANCEL), YEAR to SECOND)+24 UNITS HOUR+60 UNITS MINUTE+60 UNITS SECOND
				INTO tmp_sac_wu_cancelpay_621048;
				
				
				LET cStmt = 'echo "UNLOAD TO ' || TRIM(cRutaOltp) || 'tmp_sac_wu_cancelpay_' || TRIM(cFecha_archivo) || '.unl SELECT * FROM tmp_sac_wu_cancelpay_621048;">' || TRIM(cRutaOltp) || 'tmp_sac_wu_cancelpay_' || TRIM(cFecha_archivo) || '.sql';
				SYSTEM cStmt;
				
				
				LET cStmt = 'chmod 777 ' || TRIM(cRutaOltp) || 'tmp_sac_wu_cancelpay_' || TRIM(cFecha_archivo) || '.sql';
				SYSTEM cStmt;
							
				LET cStmt= 'dbaccess bdisac	' || TRIM(cRutaOltp) || 'tmp_sac_wu_cancelpay_' || TRIM(cFecha_archivo) || '.sql';
				SYSTEM cStmt;
				
				LET cStmt = 'chmod 777 ' || TRIM(cRutaOltp) || 'tmp_sac_wu_cancelpay_' || TRIM(cFecha_archivo) || '.unl';
				SYSTEM cStmt;
				
				LET cStmt = '';
				LET cStmt = ' echo "FILE ' || TRIM(cRutaOltp) || 'tmp_sac_wu_cancelpay_' || TRIM(cFecha_archivo) || '.unl'||' DELIMITER '|| "'" || '|' || "'" || ' 23;' || '">' || TRIM(cRutaOltp) || 'tmp_sac_wu_cancelpay_' || TRIM(cFecha_archivo) || '_up.sql';
				SYSTEM cStmt;

				LET cStmt = '';
				LET cStmt = ' echo "INSERT INTO sac_wu_cancelpay_old;' || '">> ' || TRIM(cRutaOltp) || 'tmp_sac_wu_cancelpay_' || TRIM(cFecha_archivo) || '_up.sql';
				SYSTEM cStmt;
				
				LET cStmt = '';
				LET cStmt = 'chmod 777 ' || TRIM(cRutaOltp) || 'tmp_sac_wu_cancelpay_' || TRIM(cFecha_archivo) || '_up.sql';
				SYSTEM cStmt;
				
				LET cStmt = "";
				LET cStmt = 'dbload -d bdisac -c ' || TRIM(cRutaOltp) || 'tmp_sac_wu_cancelpay_' || cFecha_archivo || '_up.sql -l ' || TRIM(cRutaOltp) || 'tmp_sac_wu_cancelpay_' || cFecha_archivo || '_up.log -n 1000 -r';
				SYSTEM cStmt;
				
				
				LET cConteo2 = 0;
				
				SELECT COUNT(*)
				INTO cConteo2
				FROM tmp_sac_wu_cancelpay_621048;
				
				IF cConteo2 IS NULL THEN 
					LET cConteo2 = 0;
				END IF;
					
					
				IF cConteo = cConteo2 THEN 
					
					LET cConteoCancel = cConteo;
					
					
					LET cConteo4 = 0;
					BEGIN WORK;
					FOREACH WITH HOLD
						SELECT mtcn,fecha_insert
						INTO cNo_row,cFh
						FROM tmp_sac_wu_cancelpay_621048

							DELETE FROM "informix".sac_wu_cancelpay WHERE mtcn = cNo_row AND fecha_insert = cFh;
						
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
				
					UPDATE STATISTICS MEDIUM FOR TABLE "informix".sac_wu_cancelpay;
					UPDATE STATISTICS MEDIUM FOR TABLE "informix".sac_wu_cancelpay_old;
					
					DROP TABLE IF EXISTS tmp_sac_wu_cancelpay_621048;
					DROP TABLE IF EXISTS tmp_sac_wu_cancelpay_621048_2;
					LET cStmt = 'rm -f ' || TRIM(cRutaOltp) || 'tmp_sac_wu_cancelpay_' || TRIM(cFecha_archivo) || '.sql';
					SYSTEM cStmt;
					LET cStmt = 'rm -f ' || TRIM(cRutaOltp) || 'tmp_sac_wu_cancelpay_' || TRIM(cFecha_archivo) || '_up.sql';
					SYSTEM cStmt;
					LET cStmt = 'rm -f ' || TRIM(cRutaOltp) || 'tmp_sac_wu_cancelpay_' || TRIM(cFecha_archivo) || '_up.log';
					SYSTEM cStmt;
					LET cStmt = 'rm -f ' || TRIM(cRutaOltp) || 'tmp_sac_wu_cancelpay_' || TRIM(cFecha_archivo) || '.unl';
					SYSTEM cStmt;
					LET cCodRet = "00000";
				ELSE 
					LET cCodRet = "00001";				
					LET cMensaje =  "Verificar Diferencias en Proceso|";
					LET cConteoPay = cConteo||"-"||cConteo2||"-"||cConteo3;

				END IF;

			END IF;

		/*FIN DEPURACION sac_wu_cancelpay*/
	
	ELSE
		
		LET cCodRet = "00001";				
		LET cMensaje =  "Proceso Desactivado sac_param 147|";
		
	END IF;
	
	
		IF cCodRet = '00000' THEN 
			LET cCodRet = "00000";				
			LET cMensaje =  "Proceso Exitoso|";
			
			INSERT INTO sac_procesos_jobs (proceso,fecha_proceso,status,user_insert,fecha_insert,numero_ejecuciones,nombre_sp,descripcion)
			VALUES ('SAC_WU_DEPURACION',today,'1','informix',CURRENT,'1','sp_sac_wu_depuracion','Depuracion Tablas WU '||cCodRet);
			
		ELSE 
			INSERT INTO sac_procesos_jobs (proceso,fecha_proceso,status,user_insert,fecha_insert,numero_ejecuciones,nombre_sp,descripcion)
			VALUES ('SAC_WU_DEPURACION',today,'0','informix',CURRENT,'1','sp_sac_wu_depuracion','Depuracion Tablas WU Verificar '||cCodRet);
		END IF;
		
		LET cMensaje2 = 'Fecha|Sac_Wu_Pay|Saw_Wu_Search|Cancel_Pay|';
		LET cMensaje3 = cFecha_proceso||'|'||cConteoPay||"|" ||cConteoSearch||"|" ||cConteoCancel||"|";
		

					
		
		RETURN cCodRet,cMensaje,cMensaje2,cMensaje3;
		
	END;
END PROCEDURE;
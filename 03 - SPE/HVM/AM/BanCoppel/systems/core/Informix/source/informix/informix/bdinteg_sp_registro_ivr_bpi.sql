CREATE PROCEDURE "informix".sp_registro_ivr_bpi(pTipoProceso CHAR(3), pFechaInicial DATE, pFechaFinal DATE)

RETURNING 
		CHAR(100) AS Proceso,
		CHAR(5) AS CodRet,
		CHAR(100) AS DataError;

	 --DEFINICION DE VARIABLES--
    DEFINE iSqlErr			INTEGER;
	DEFINE iSamErr			INTEGER;
    DEFINE cCodRet      	CHAR(5);
	DEFINE dFechaIni        DATETIME YEAR TO FRACTION(5);
	DEFINE dFechaFin        DATETIME YEAR TO FRACTION(5);
	DEFINE cNumCte			CHAR(20);
	DEFINE cEstatus         CHAR(1);
	DEFINE dFechaOper		DATETIME YEAR TO FRACTION(5);
	DEFINE cProceso			CHAR(100);
	DEFINE cVarDataErr		CHAR(100);
	DEFINE iEstatus			INTEGER;
	DEFINE sCommit          SMALLINT;
	DEFINE iCont            INTEGER;
	DEFINE dFechaUltAcceso  DATETIME YEAR TO FRACTION(5);
	DEFINE dFechaReg		DATETIME YEAR TO FRACTION(5);
	DEFINE sServicio		SMALLINT;
	DEFINE cStmt 			CHAR (500);
	DEFINE cRutaOltp	    CHAR(50);
	
	--INICIALIZACION DE VARIABLES--
    LET iSqlErr 		= 0;
    LET cCodRet 		= '00000';
	LET dFechaIni   	= '';
	LET dFechaFin	    = '';
	LET cNumCte	     	= '';
	LET cEstatus  		= '';
	LET dFechaOper     	= '';
	LET cProceso 		= 'SP_REGISTRO_IVR_BPI';
	LET cVarDataErr 	= '';
	LET iEstatus        = 1;
	LET iCont	        = 0;
	LET sCommit         = 0;
	LET dFechaUltAcceso = '';
	LET dFechaReg		= '';
	LET sServicio 		= 0; 
	LET cStmt           = '';
	LET cRutaOltp       = '/RESPALDOSNEW/depuraremesas/';

    --SET DEBUG FILE TO "/RESPALDOSNEW/enrique/sp_registro_ivr_bpi_ljfs.out";
	--TRACE ON;

	BEGIN
		--CONTROLAMOS ERRORES
		ON EXCEPTION SET iSqlErr, iSamErr, cVarDataErr
				IF iSqlErr <> 0 THEN
					LET cCodRet=iSqlErr;
				IF (sCommit = -1) THEN
					ROLLBACK WORK;
				END IF;
				LET cVarDataErr = 'ERROR NO CONTROLADO';
				INSERT INTO bdiunica@stag_ids1170:"informix".uni_reg_ejec_proceso (nombre_proceso, fecha_inicio, fecha_fin, status_ejecucion, observacion)
				VALUES (cProceso, dFechaIni, CURRENT, cCodRet , cVarDataErr);
					
				RETURN cProceso,cCodRet, cVarDataErr;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
	
		SELECT  DBINFO('utc_to_datetime',sh_curtime)
		INTO    dFechaIni
		FROM    sysmaster:"informix".sysshmvals;
		
		--TRUNCATE TABLE bdinteg:"informix".tmp_unica_paso;
	
		--VALIDAR LOS PARAMETROS DE ENTRADA 
		IF NVL(pTipoProceso,'') = '' OR NVL(pFechaInicial,'')='' OR NVL(pFechaFinal,'')='' THEN
			LET cCodRet =   '00001';
			LET iEstatus=0;
			LET cVarDataErr = 'UNO O MAS PARAMETROS VACIOS';
			INSERT INTO bdiunica@stag_ids1170:"informix".uni_reg_ejec_proceso (nombre_proceso, fecha_inicio, fecha_fin, status_ejecucion, observacion)
			VALUES (cProceso, dFechaIni, CURRENT, iEstatus, cVarDataErr);
				
			RETURN cProceso,cCodRet, cVarDataErr;
		END IF;
		
		IF pFechaFinal > CURRENT::DATE THEN
			LET cCodRet =   '00002'; 
			LET iEstatus=0;
			LET cVarDataErr="FECHA FINAL ES MAYOR A LA FECHA DE HOY";
			INSERT INTO bdiunica@stag_ids1170:"informix".uni_reg_ejec_proceso (nombre_proceso, fecha_inicio, fecha_fin,status_ejecucion, observacion)
			VALUES (cProceso, dFechaIni, CURRENT, iEstatus, cVarDataErr);
					
			RETURN cProceso,cCodRet, cVarDataErr;
		END IF;
		
		IF pFechaInicial > pFechaFinal THEN
			LET cCodRet =   '00003'; 
			LET iEstatus=0;
			LET cVarDataErr="FECHA INICIO ES MAYOR A LA FECHA FIN";
			INSERT INTO bdiunica@stag_ids1170:"informix".uni_reg_ejec_proceso (nombre_proceso, fecha_inicio, fecha_fin,status_ejecucion, observacion)
			VALUES (cProceso, dFechaIni, CURRENT, iEstatus, cVarDataErr);
			RETURN cProceso,cCodRet, cVarDataErr;
			
		END IF;  --TERMINA DE VALIDAR LOS PARAMETROS DE ENTRADA
		
	-- INICIA PROCESO IVR
		
	IF (UPPER(pTipoProceso) = 'IVR') THEN   --UNI_IVR	
								 
		--/** OBTENEMOS LOS REGISTROS DE LA FECHA DESEADA PARA IVR **/
		DROP TABLE IF EXISTS temp_ivrusuarios;
		SELECT      bitc.numcte, ivr.status_cte, MAX(bitc.fecha_oper) fecha_oper
		FROM        bdinteg:"informix".si_bitacora_ivr bitc  
		INNER JOIN  bdinteg:"informix".si_cliente_ivr ivr ON (ivr.numcte = bitc.numcte)
		WHERE       bitc.fecha_oper >  pFechaInicial
		AND         bitc.fecha_oper <= pFechaFinal 
		GROUP BY    bitc.numcte, ivr.status_cte
		INTO temp_ivrusuarios;						 
		LET cStmt = 'echo "UNLOAD TO ' || TRIM(cRutaOltp) || 'si_registro_ivr.unl SELECT * FROM temp_ivrusuarios;">' || TRIM(cRutaOltp) || 'u_ivrusuarios.sql';
		SYSTEM cStmt;
		LET cStmt = 'chmod 777 ' || TRIM(cRutaOltp) || 'u_ivrusuarios.sql';
		SYSTEM cStmt;
		LET cStmt= 'dbaccess bdinteg ' || TRIM(cRutaOltp) || 'u_ivrusuarios.sql';
		SYSTEM cStmt;
		LET cStmt = 'rm -f ' || TRIM(cRutaOltp) || 'u_ivrusuarios.sql';
		SYSTEM cStmt;
		   
		DROP TABLE IF EXISTS temp_ivrusuarios;		  		

		LET cVarDataErr = 'EJECUCION EXITOSA IVR';

		SELECT  DBINFO('utc_to_datetime',sh_curtime)
		INTO    dFechaFin
		FROM    sysmaster:"informix".sysshmvals;

		--INSERTAMOS REGISTRO DE EJECUCION DEL PROCESO
		INSERT INTO bdiunica@stag_ids1170:"informix".uni_reg_ejec_proceso (nombre_proceso, fecha_inicio, fecha_fin, status_ejecucion, observacion,tipo_proceso)
		VALUES (cProceso, dFechaIni, dFechaFin, iEstatus, cVarDataErr, pTipoProceso);
		  
	END IF; --  TERMINA PROCESO IVR

	
	-- INICIA PROCESO BPI
	IF (UPPER(pTipoProceso) = 'BPI') THEN   --UNI_BPI
	    
		--/** OBTENEMOS LOS REGISTROS DE LA FECHA DESEADA PARA BPI **/
		--INSERT    INTO bdinteg:"informix".tmp_unica_paso (numcte)
		DROP TABLE IF EXISTS temp_bpiusuarios;
		SELECT    a.numcte,  a.f_ultimo_acceso, a.f_registro, a.servicio
		FROM      TABLE(MULTISET(SELECT    bis.numcte,  bis.f_ultimo_acceso, bis.f_registro, bis.servicio 
								 FROM      bdinteg:"informix".si_bpiusuarios bis
								 WHERE     (bis.f_ultimo_acceso > pFechaInicial AND bis.f_ultimo_acceso <= pFechaFinal)
								 UNION ALL
								 SELECT    bis.numcte,  bis.f_ultimo_acceso, bis.f_registro, bis.servicio 
								 FROM      bdinteg:"informix".si_bpiusuarios bis
								 WHERE     (bis.f_registro > pFechaInicial AND bis.f_registro <= pFechaFinal)
								 AND       f_ultimo_acceso IS NULL)) a						
		INTO temp_bpiusuarios;						 
		LET cStmt = 'echo "UNLOAD TO ' || TRIM(cRutaOltp) || 'si_registro_bpi.unl SELECT * FROM temp_bpiusuarios;">' || TRIM(cRutaOltp) || 'u_bpiusuarios.sql';
		SYSTEM cStmt;
		LET cStmt = 'chmod 777 ' || TRIM(cRutaOltp) || 'u_bpiusuarios.sql';
		SYSTEM cStmt;
		LET cStmt= 'dbaccess bdinteg ' || TRIM(cRutaOltp) || 'u_bpiusuarios.sql';
		SYSTEM cStmt;
		LET cStmt = 'rm -f ' || TRIM(cRutaOltp) || 'u_bpiusuarios.sql';
		SYSTEM cStmt;
		
		DROP TABLE IF EXISTS temp_bpiusuarios;

		LET cVarDataErr = 'EJECUCION EXITOSA BPI';

		SELECT  DBINFO('utc_to_datetime',sh_curtime)
		INTO    dFechaFin
		FROM    sysmaster:"informix".sysshmvals;

		--INSERTAMOS REGISTRO DE EJECUCION DEL PROCESO
		INSERT INTO bdiunica@stag_ids1170:"informix".uni_reg_ejec_proceso (nombre_proceso, fecha_inicio, fecha_fin, status_ejecucion, observacion,tipo_proceso)
		VALUES (cProceso, dFechaIni, dFechaFin, iEstatus, cVarDataErr, pTipoProceso);		  		  
		
	END IF; --  TERMINA PROCESO BPI
	
RETURN cProceso, cCodRet, cVarDataErr;

END;
END PROCEDURE;
CREATE PROCEDURE "informix".sp_archivo_ind_cheques(pTipoProc CHAR(3))
	
	RETURNING
    CHAR(100),CHAR(5), CHAR (100);
	
	-- DECLARAR LAS VARIABLES
	DEFINE iSqlErr 			INTEGER;
	DEFINE iSamErr 			INTEGER;
	DEFINE sCommit   		SMALLINT;
	DEFINE cAnioMesAct		CHAR(6);
	DEFINE cAnioMesUni  	CHAR(6);
	DEFINE cProceso     	CHAR(100);
	DEFINE dFechaIni		DATETIME YEAR TO FRACTION(5);
	DEFINE dFechaFin		DATETIME YEAR TO FRACTION(5);
	DEFINE cCodRet			CHAR(5);
	DEFINE cVarError		CHAR(100);
	DEFINE cRuta			CHAR(30);
	DEFINE cNombreArchivo	CHAR(30);
	DEFINE cSql				CHAR(1024);
	DEFINE dFechaProceso	DATE;
	
	-- INCIALIZAR LAS VARIABLES
	LET cAnioMesAct		= '';
	LET cAnioMesUni		= '';
	LET cProceso		= 'SP_ARCHIVO_UNL';
	LET dFechaIni		= '';
	LET dFechaFin		= '';
	LET cCodRet			= '00000';
	LET cVarError		= 'EJECUCION EXITOSA';
	LET cRuta			= '/RESPALDOSNEW/UNICA/';
	LET cNombreArchivo  = 'ind_cheques_';
	LET cSql 			= '';
	LET sCommit 		= 0;
	LET dFechaProceso   = '';
	
	--SET DEBUG FILE TO "/informix/ljfs/sp_archivo_sh.out";
	--TRACE ON;
	
	
	BEGIN
	
		-- CONTROL DE ERRORES
		ON EXCEPTION SET iSqlErr, iSamErr, cVarError
			IF iSqlErr <> 0 THEN
				LET cCodRet=iSqlErr;
				LET cVarError = 'ERROR NO CONTROLADO';
				
				INSERT INTO bdiunica@stag_ids1170:"informix".uni_reg_ejec_proceso (nombre_proceso, fecha_inicio, fecha_fin, status_ejecucion, observacion, tipo_proceso)
				VALUES (cProceso, CURRENT, CURRENT, cCodRet, cVarError, pTipoProc);
					
				RETURN cProceso,cCodRet,cVarError;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		-- VALIDA PARAMETROS DE ENTRADA
		IF pTipoProc IS NULL OR pTipoProc <> 'UNL'  THEN 
		
			LET cCodRet =   '00001'; 
			LET cVarError = "FALTAN PARAMETROS DE ENTRADA";
			
				INSERT INTO bdiunica@stag_ids1170:"informix".uni_reg_ejec_proceso (nombre_proceso, fecha_inicio, fecha_fin, status_ejecucion, observacion, tipo_proceso)
				VALUES (cProceso, CURRENT, CURRENT, cCodRet, cVarError, pTipoProc);
					
			RETURN cProceso, cCodRet, cVarError;
				
		END IF;  -- TERMINA VALIDACION DE PARAMETROS
		
		-- OBTENER  AÃO MES QUE SE VA A EJECUTAR
		
		SELECT TO_CHAR(TODAY-1 UNITS MONTH, '%Y%m')
		INTO   cAnioMesAct
		FROM   systables WHERE tabid = 1;
		
		-- OBTENEMOS FECHA Y HORA QUE INICIA PROCESO
		
		 LET dFechaIni=CURRENT;
	/*
		SELECT  DBINFO('utc_to_datetime',sh_curtime)
	    INTO    dFechaIni
	    FROM    sysmaster:"informix".sysshmvals;
		*/
		-- INICA CREACION DE ARCHIVO .UNL
		LET cNombreArchivo = TRIM(cNombreArchivo) || TRIM(SUBSTRING(cAnioMesAct FROM 5 FOR 2)) || '.unl';
		
		IF cAnioMesAct IS NOT NULL  THEN
		
			LET cSql=  'echo "UNLOAD TO '||TRIM(cRuta)||TRIM(cNombreArchivo)||' '||
						'SELECT id.anio_mes, ch.num_cte, id.producto, id.cuenta,' ||
						'id.fecha_apertura, id.saldo_maximo_mes, id.saldo_promedio, ch.status_cta, ch.ultpagocap ' ||
						'FROM bdicheq:"informix".sc_indicadores id, ' ||
						'bdicheq:"informix".sc_maechq ch ' ||
						'WHERE id.cuenta = ch.cuenta ' ||
						'AND id.producto = ch.producto ' ||
						'AND id.empresa = ch.empresa ' ||
						'AND id.sucursal_apertura = ch.sucursal ' ||
						'AND id.anio_mes = '||TRIM(cAnioMesAct)||'" > '||TRIM(cRuta)||'ind_cheques.sql'; 	   
			SYSTEM cSql;
			LET cSql= '';
			
			LET cSql= "dbaccess bdicheq " ||TRIM(cRuta)||"ind_cheques.sql";
			SYSTEM cSql;
			LET cSql ='';
				
			LET cSql ="rm " ||TRIM(cRuta)||"ind_cheques.sql";
			SYSTEM cSql;
			LET cSql ='';
			
		END IF;
		
		LET cVarError = 'EJECUCION ARCHIVO .UNL';
		
		LET dFechaProceso = TODAY;
		LET cCodRet = '00000';
		
		
		-- OBTENEMOS LA FECHA Y HORA EN QUE TERMINA EL PROCESO
		
		    LET dFechaFin=CURRENT;
		/*
	    SELECT  DBINFO('utc_to_datetime',sh_curtime)
	    INTO    dFechaFin
	    FROM    sysmaster:"informix".sysshmvals;
		*/
		-- INSERTAMOS REGISTRO DE EJECUCION DEL PROCESO
		INSERT INTO bdiunica@stag_ids1170:"informix".uni_reg_ejec_proceso (nombre_proceso, fecha_inicio, fecha_fin, status_ejecucion, observacion, fecha_proceso, tipo_proceso)
		VALUES (cProceso, dFechaIni, dFechaFin, cCodRet, cVarError, dFechaProceso, pTipoProc);
		
		RETURN cProceso,cCodRet,cVarError;
	END;

END PROCEDURE;
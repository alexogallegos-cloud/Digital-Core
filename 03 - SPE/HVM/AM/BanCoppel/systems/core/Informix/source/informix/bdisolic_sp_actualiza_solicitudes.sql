CREATE PROCEDURE "informix".sp_actualiza_solicitudes(pTipoProceso CHAR(3), pFechaInicio DATE, pFechaFin DATE)
	
    RETURNING
    CHAR(100),CHAR(5), CHAR (100);

    --DEFINICION DE VARIABLES
    DEFINE cCodret           CHAR (5);
	DEFINE cVarError		 CHAR(100);
	DEFINE cStatus_ejecucion CHAR(1);
	DEFINE iContador 		 INTEGER;
	DEFINE iCont			 INTEGER;
	DEFINE iSamErr 			 INTEGER;
	DEFINE iSqlErr 			 INTEGER;
	DEFINE cNumCte 			 CHAR(100);
	DEFINE cNumSolicitud 	 CHAR(100);
	DEFINE cSucurs 			 CHAR(100);
	DEFINE cStatusSolic 	 CHAR(10);
	DEFINE cNumProduct 		 CHAR(100);
	DEFINE cMontoAutor 		 CHAR(100);
	DEFINE dFechaAut 		 DATE;
	DEFINE cProceso  		 CHAR(100);
	DEFINE dFechaIni         DATETIME YEAR TO FRACTION(5);
	DEFINE dFechaFin         DATETIME YEAR TO FRACTION(5);
	DEFINE sCommit           SMALLINT;
	DEFINE cVarDataErr       CHAR(100);
	DEFINE iEstatus			 INTEGER;
	DEFINE iDiasVigencia	 INTEGER;
	DEFINE cStmt 			 CHAR (500);
	DEFINE cRutaOltp	     CHAR(50);
	
    --INICIALIZACION DE VARIABLES
    LET cCodret           ="00000";
	LET cVarError		  ="EJECUCION EXITOSA SOL";
	LET cStatus_ejecucion ="1";
	LET iContador         = 0;
	LET iCont	          = 0;
	LET iSamErr           = 0;
	LET iSqlErr           = 0;
	LET cNumCte           ="";
	LET cNumSolicitud     ="";
	LET cSucurs 		  = 0;
	LET cStatusSolic 	  ="";
	LET cNumProduct 	  ="";
	LET cMontoAutor       ="";
	LET dFechaAut         ="";
	LET cProceso          ="sp_actualiza_solicitudes";
	LET dFechaIni 		  = CURRENT;
	LET dFechaFin 		  = '';
	LET sCommit           = 0;
	LET cVarDataErr 	  = '';
	LET iEstatus          = 1;
	LET iDiasVigencia	  = 0;
	LET cStmt             = '';
	LET cRutaOltp         = '/RESPALDOSNEW/depuraremesas/';

	--SET DEBUG FILE TO "/informix/ljfs/sp_actualiza_solicitudes_ljfs.out";
	--TRACE ON; 
	
    BEGIN
	
		--CONTROLAMOS ERRORES
		ON EXCEPTION SET iSqlErr, iSamErr, cVarError
				IF iSqlErr <> 0 THEN
					LET cCodRet=iSqlErr;
					LET cStatus_ejecucion =0;
					LET cVarError = 'ERROR NO CONTROLADO';
				
				INSERT INTO bdiunica@stag_ids1170:"informix".uni_reg_ejec_proceso (nombre_proceso, fecha_inicio, fecha_fin, status_ejecucion, observacion, tipo_proceso)
				VALUES (cProceso, dFechaIni, CURRENT, cStatus_ejecucion,cVarError, pTipoProceso);
				
				RETURN cProceso,cCodRet,cVarError;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT  DBINFO('utc_to_datetime',sh_curtime)
		INTO    dFechaIni
		FROM    sysmaster:"informix".sysshmvals;
		
		TRUNCATE TABLE bdisolic:"informix".tmp_unica_paso;
		DROP TABLE IF EXISTS tmp_solicitudes;
		
		--VALIDAR LOS PARAMETROS DE ENTRADA
		IF NVL(pTipoProceso,'') = '' OR NVL(pFechaInicio,'')= '' OR NVL(pFechaFin,'') = '' THEN
			
			LET cCodRet =   '00001'; 
			LET cStatus_ejecucion=0;
			LET cVarError="FALTAN PARAMETROS DE ENTRADA";
			
			INSERT INTO bdiunica@stag_ids1170:"informix".uni_reg_ejec_proceso (nombre_proceso, fecha_inicio, fecha_fin,status_ejecucion, observacion, tipo_proceso)
			VALUES (cProceso, dFechaIni, CURRENT, cStatus_ejecucion, cVarError, pTipoProceso);
					
			RETURN cProceso,cCodRet, cVarError;
		END IF;
		
		IF pFechaFin > CURRENT::DATE THEN
			LET cCodRet =   '00002'; 
			LET cStatus_ejecucion=0;
			LET cVarError="FECHA FINAL ES MAYOR A LA FECHA DE HOY";
			INSERT INTO bdiunica@stag_ids1170:"informix".uni_reg_ejec_proceso (nombre_proceso, fecha_inicio, fecha_fin,status_ejecucion, observacion, tipo_proceso)
			VALUES (cProceso, dFechaIni, CURRENT, cStatus_ejecucion, cVarError, pTipoProceso);
					
			RETURN cProceso,cCodRet, cVarError;
		END IF;
		
		IF pFechaInicio > pFechaFin THEN
			LET cCodRet =   '00003'; 
			LET cStatus_ejecucion=0;
			LET cVarError="FECHA INICIO ES MAYOR A LA FECHA FIN";
			INSERT INTO bdiunica@stag_ids1170:"informix".uni_reg_ejec_proceso (nombre_proceso, fecha_inicio, fecha_fin,status_ejecucion, observacion, tipo_proceso)
			VALUES (cProceso, dFechaIni, CURRENT, cStatus_ejecucion, cVarError, pTipoProceso);
			RETURN cProceso,cCodRet, cVarError;
			
		END IF;	  --TERMINA DE VALIDAR LOS PARAMETROS DE ENTRADA	
	

		SELECT	MAX(dias_vigencia) dias_vig
		INTO 	iDiasVigencia
		FROM 	bdisolic:"informix".ss_vigencia_sol_productos
		WHERE	status_solicitud = 'AT';
	
	 
	IF (UPPER(pTipoProceso) = 'SOL') THEN --UNI_SOLICITUDES
	
		SELECT a.num_solicitud, a.status_solicitud
		FROM TABLE(MULTISET(SELECT  sl.num_solicitud, sl.status_solicitud
							FROM    bdisolic:"informix".ss_solicitudes sl
							WHERE   (sl.fecha_insert > pFechaInicio AND sl.fecha_insert <= pFechaFin)
							UNION ALL
							SELECT  au.num_solicitud, au.status_solicitud
							FROM    bdisolic:"informix".ss_autorizacion au
							WHERE   (au.fecha_insert > pFechaInicio AND au.fecha_insert <= pFechaFin)
				  )) a
		INTO TEMP tmp_solicitudes WITH NO LOG;
	
	
		DROP TABLE IF EXISTS tmp_solicitudes_at;
		SELECT  b.numcte, a.num_solicitud, b.sucursal, a.status_solicitud, b.num_producto, b.monto_autorizado, b.fecha_insert
		FROM    bdisolic:tmp_solicitudes a, bdisolic:"informix".ss_solicitudes b
		WHERE   b.num_solicitud = a.num_solicitud
		AND		b.status_solicitud =  a.status_solicitud
		AND		a.status_solicitud = 'AT'
		INTO tmp_solicitudes_at;
		
		LET cStmt = 'echo "UNLOAD TO ' || TRIM(cRutaOltp) || 'ss_solicitudes_at.unl SELECT * FROM tmp_solicitudes_at;">' || TRIM(cRutaOltp) || 'u_solicitudes_at.sql';
		SYSTEM cStmt;
		LET cStmt = 'chmod 777 ' || TRIM(cRutaOltp) || 'u_solicitudes_at.sql';
		SYSTEM cStmt;
		LET cStmt= 'dbaccess bdisolic ' || TRIM(cRutaOltp) || 'u_solicitudes_at.sql';
		SYSTEM cStmt;
		LET cStmt = 'rm -f ' || TRIM(cRutaOltp) || 'u_solicitudes_at.sql';
		SYSTEM cStmt;
		
		
		DROP TABLE IF EXISTS tmp_solicitudes_ap;
		SELECT  f.numcte, e.num_solicitud, f.sucursal, e.status_solicitud, f.num_producto, f.monto_autorizado, f.fecha_insert
		FROM    bdisolic:tmp_solicitudes e, bdisolic:"informix".ss_solicitudes f
		WHERE   f.num_solicitud = e.num_solicitud
		AND		f.status_solicitud =  e.status_solicitud
		AND		e.status_solicitud = 'AP'
		INTO tmp_solicitudes_ap;
		
		LET cStmt = 'echo "UNLOAD TO ' || TRIM(cRutaOltp) || 'ss_solicitudes_ap.unl SELECT * FROM tmp_solicitudes_ap;">' || TRIM(cRutaOltp) || 'u_solicitudes_ap.sql';
		SYSTEM cStmt;
		LET cStmt = 'chmod 777 ' || TRIM(cRutaOltp) || 'u_solicitudes_ap.sql';
		SYSTEM cStmt;
		LET cStmt= 'dbaccess bdisolic ' || TRIM(cRutaOltp) || 'u_solicitudes_ap.sql';
		SYSTEM cStmt;
		LET cStmt = 'rm -f ' || TRIM(cRutaOltp) || 'u_solicitudes_ap.sql';
		SYSTEM cStmt;

		DROP TABLE IF EXISTS tmp_solicitudes_dif;
		SELECT  n.numcte, m.num_solicitud, n.sucursal, m.status_solicitud, n.num_producto, n.monto_autorizado, n.fecha_insert
		FROM    bdisolic:tmp_solicitudes m, bdisolic:"informix".ss_solicitudes n
		WHERE   n.num_solicitud = m.num_solicitud
		AND		n.status_solicitud =  m.status_solicitud
		AND		m.status_solicitud NOT IN ('AP','AT')
		INTO tmp_solicitudes_dif;
		
		LET cStmt = 'echo "UNLOAD TO ' || TRIM(cRutaOltp) || 'ss_solicitudes_dif.unl SELECT * FROM tmp_solicitudes_dif;">' || TRIM(cRutaOltp) || 'u_solicitudes_dif.sql';
		SYSTEM cStmt;
		LET cStmt = 'chmod 777 ' || TRIM(cRutaOltp) || 'u_solicitudes_dif.sql';
		SYSTEM cStmt;
		LET cStmt= 'dbaccess bdisolic ' || TRIM(cRutaOltp) || 'u_solicitudes_dif.sql';
		SYSTEM cStmt;
		LET cStmt = 'rm -f ' || TRIM(cRutaOltp) || 'u_solicitudes_dif.sql';
		SYSTEM cStmt;
		
		DROP TABLE bdisolic:tmp_solicitudes;
		DROP TABLE IF EXISTS tmp_solicitudes_at;
		DROP TABLE IF EXISTS tmp_solicitudes_ap;
		DROP TABLE IF EXISTS tmp_solicitudes_dif;

		LET cVarDataErr = 'EJECUCION EXITOSA SOL';

		SELECT  DBINFO('utc_to_datetime',sh_curtime)
		INTO    dFechaFin
		FROM    sysmaster:"informix".sysshmvals;

		--INSERTAMOS REGISTRO DE EJECUCION DEL PROCESO
		INSERT INTO bdiunica@stag_ids1170:"informix".uni_reg_ejec_proceso (nombre_proceso, fecha_inicio, fecha_fin, status_ejecucion, observacion, tipo_proceso)
		VALUES (cProceso, dFechaIni, dFechaFin, iEstatus, cVarDataErr, pTipoProceso);
	END IF;

	RETURN cProceso, cCodRet, cVarDataErr;

	END;
END PROCEDURE;
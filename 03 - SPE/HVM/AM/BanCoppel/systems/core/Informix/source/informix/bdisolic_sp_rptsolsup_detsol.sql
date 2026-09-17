CREATE PROCEDURE "informix".sp_rptsolsup_detsol(pEmpresa CHAR(3), pNumCte VARCHAR(20), pNumSolic VARCHAR(20), pFechaIni DATE, pFechaFin DATE, pUsuario CHAR(10), pInicio INTEGER, pFinal INTEGER)
RETURNING CHAR(6)        AS codigo_retorno,
          VARCHAR(80,1)  AS mensaje_retorno,	
		  VARCHAR(20,1)  AS numero_solicitud,
		  VARCHAR(20,1)  AS numero_cliente,
		  VARCHAR(180,1) AS nombre_cliente,
		  CHAR(4)        AS sucursal,
          DATE           AS fecha_solicitud, 
		  VARCHAR(3,1)   AS status,
		  DATE           AS fecha_ingreso_status,
		  DATETIME YEAR to SECOND AS hora_ingreso_status,
		  DATE           AS fecha_reenvio,
		  DATETIME YEAR to SECOND AS hora_reenvio,
		  VARCHAR(3,1)   AS status_actual,
		  VARCHAR(20,1)  AS tipo_movimiento,
		  VARCHAR(180,1) AS nombre_analista;
		  
	-- DECLARACIONES
	DEFINE cCodRet          CHAR(6); 
	DEFINE cMensajeRet      VARCHAR(80,1);
	DEFINE iSqlErr      	INTEGER;
	DEFINE iIsamErr         INTEGER;
	DEFINE cErrorInfo       VARCHAR(80,1);
	
	DEFINE iNumReg          INTEGER;
	DEFINE vNumSolic        VARCHAR(20,1);
	DEFINE vNumCte          VARCHAR(20,1);
	DEFINE vNomCte          VARCHAR(180,1);
	DEFINE vSucursal        CHAR(4);
	DEFINE dtFechaSolic     DATE;
	DEFINE vStatusAnt       VARCHAR(3,1);
	DEFINE dtFechaIngreso   DATE;
	DEFINE dtHoraIngreso    DATETIME YEAR to SECOND;
	DEFINE dtFechaReenv     DATE;
	DEFINE dtHoraReenv      DATETIME YEAR to SECOND;
	DEFINE vStatusAct       VARCHAR(3,1);
	DEFINE vTpoMovto        VARCHAR(20,1);
	DEFINE vNombreAnalista  VARCHAR(180,1);
			
	-- INICIALIZACIONES
	LET iSqlErr             = 0;
	LET iIsamErr            = 0;
	LET cErrorInfo          = '';
	LET cCodRet             = '000000';
	LET cMensajeRet         = 'Se realizo la consulta correctamente';
	
	LET iNumReg          = 0;
	LET vNumSolic        = '';
	LET vNumCte          = '';
	LET vNomCte          = '';
	LET vSucursal        = '';
	LET dtFechaSolic     = DATE(1);
	LET vStatusAnt       = '';
	LET dtFechaIngreso   = DATE(1);
	LET dtHoraIngreso    = '';
	LET dtFechaReenv     = DATE(1);
	LET dtHoraReenv      = '';
	LET vStatusAct       = '';
	LET vTpoMovto        = '';
	LET vNombreAnalista  = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
			IF iSqlErr != 0 THEN
				LET cCodRet= iSqlErr;
				LET cMensajeRet = cErrorInfo;
				RETURN NVL(cCodRet,''),NVL(cMensajeRet,''),NVL(vNumSolic,''), NVL(vNumCte,''), NVL(vNomCte,''), NVL(vSucursal,''), 
					NVL(dtFechaSolic,DATE(1)), NVL(vStatusAnt,''), NVL(dtFechaIngreso,DATE(1)), NVL(dtHoraIngreso,''), NVL(dtFechaReenv,DATE(1)), 
					NVL(dtHoraReenv,''), NVL(vStatusAct,''),NVL(vTpoMovto,''),NVL(vNombreAnalista,'');
			END IF;
		END EXCEPTION;
	
		--SET DEBUG FILE TO '/tmp/mfinis/sp_rptsolsup_detsol.out';
		--TRACE ON;
	
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
	
		IF NVL(pNumCte,'') = '' AND NVL(pNumSolic,'') = '' AND NVL(pFechaIni,'') = '' AND NVL(pFechaFin,'') = '' AND NVL(pUsuario,'') = '' THEN
			LET cCodRet = '000001';
			LET cMensajeRet = 'Parametros de execucion incorrectos';
				RETURN NVL(cCodRet,''),NVL(cMensajeRet,''),NVL(vNumSolic,''), NVL(vNumCte,''), NVL(vNomCte,''), NVL(vSucursal,''), 
			NVL(dtFechaSolic,DATE(1)), NVL(vStatusAnt,''), NVL(dtFechaIngreso,DATE(1)), NVL(dtHoraIngreso,''), NVL(dtFechaReenv,DATE(1)), 
			NVL(dtHoraReenv,''), NVL(vStatusAct,''),NVL(vTpoMovto,''),NVL(vNombreAnalista,'');
		END IF;
	
		FOREACH WITH HOLD
			SELECT SKIP pInicio FIRST pFinal numerosolicitud, numerocliente, nombrecliente, sucursal, fechasolicitud, status, fechaingresostatus, horaingresostatus, 
			fechareenvio, horareenvio, statusactual, tipomovimiento, nombreanalista
			INTO vNumSolic, vNumCte, vNomCte, vSucursal, dtFechaSolic, vStatusAnt, dtFechaIngreso, dtHoraIngreso, dtFechaReenv,
			dtHoraReenv, vStatusAct, vTpoMovto, vNombreAnalista
			FROM bdicnweb:"informix".sw_consultasolsupdetsol 
			WHERE usuario = pUsuario
		
			RETURN NVL(cCodRet,''),NVL(cMensajeRet,''),NVL(vNumSolic,''), NVL(vNumCte,''), NVL(vNomCte,''), NVL(vSucursal,''), 
			NVL(dtFechaSolic,DATE(1)), NVL(vStatusAnt,''), NVL(dtFechaIngreso,DATE(1)), NVL(dtHoraIngreso,''), NVL(dtFechaReenv,DATE(1)), 
			NVL(dtHoraReenv,''), NVL(vStatusAct,''),NVL(vTpoMovto,''),NVL(vNombreAnalista,'') WITH RESUME;
			
		END FOREACH;

	
		LET iNumReg = dbinfo("sqlca.sqlerrd2");
		IF iNumReg = 0 THEN
			LET cCodRet = '000002';
			LET cMensajeRet = 'No hay información para el filtro indicado';
			RETURN NVL(cCodRet,''),NVL(cMensajeRet,''),NVL(vNumSolic,''), NVL(vNumCte,''), NVL(vNomCte,''), NVL(vSucursal,''), 
				NVL(dtFechaSolic,DATE(1)), NVL(vStatusAnt,''), NVL(dtFechaIngreso,DATE(1)), NVL(dtHoraIngreso,''), NVL(dtFechaReenv,DATE(1)), 
				NVL(dtHoraReenv,''), NVL(vStatusAct,''),NVL(vTpoMovto,''),NVL(vNombreAnalista,'');
		END IF;
			
	END
END PROCEDURE

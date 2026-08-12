CREATE PROCEDURE "informix".sp_rptsolsup_detsol_total(pEmpresa CHAR(3), pNumCte CHAR(20), pNumSolic CHAR(20), pFechaIni DATE, pFechaFin DATE, pUsuario CHAR(10))
RETURNING CHAR(6) AS codigo_retorno,
          CHAR(80) AS mensaje_retorno,	
		  INTEGER AS num_registros;
		  
	-- DECLARACIONES
	DEFINE cCodRet          CHAR(6); 
	DEFINE cMensajeRet      CHAR(80);
	DEFINE iSqlErr      	INTEGER;
	DEFINE iIsamErr         INTEGER;
	DEFINE cErrorInfo       VARCHAR(80,1);
	DEFINE iNumRegistros    INTEGER;
	
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
	LET iNumRegistros       = 0;

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
		  RETURN NVL(cCodRet,''),NVL(cMensajeRet,''),NVL(iNumRegistros,0);
	   END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO '/tmp/mfinis/sp_rptsolsup_detsol_total.out';
	--TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	IF NVL(pNumCte,'') = '' AND NVL(pNumSolic,'') = '' AND NVL(pFechaIni,'') = '' AND NVL(pFechaFin,'') = '' AND NVL(pUsuario,'') = '' THEN
		LET cCodRet = '000001';
		LET cMensajeRet = 'Parámetros de execución incorrectos';
			 RETURN NVL(cCodRet,''),NVL(cMensajeRet,''),NVL(iNumRegistros,0);
	END IF;
	
	DELETE FROM bdicnweb:"informix".sw_consultasolsupdetsol WHERE usuario = pUsuario;

	IF NVL(pNumSolic,'') <> '' THEN

	FOREACH WITH HOLD
		SELECT a.num_solicitud, a.numcte, 
			TRIM(NVL(c.nombre1,'')) ||' '||
			TRIM(NVL(c.nombre2,'')) ||' '||
			TRIM(NVL(c.apell_paterno,'')) ||' '||
			TRIM(NVL(c.apell_materno,'')) AS nom_cte,
			a.sucursal,
			a.fecha_insert,
			esp.status_ant,
			(SELECT i.fecha_insert FROM ss_autorizacion i
			WHERE i.num_solicitud = esp.num_solicitud AND i.status_solicitud =  esp.status_nvo AND i.fecha_insert = esp.fecha_modif),
			(SELECT j.fecha_hora FROM ss_autorizacion j
			WHERE j.num_solicitud = esp.num_solicitud AND j.status_solicitud =  esp.status_nvo AND j.fecha_insert = esp.fecha_modif),			
			a.status_solicitud,
			CASE WHEN TRIM(NVL(e.tipo_movimiento,'')) = 'M' THEN 'MIXTO' ELSE 'UNICO' END CASE,
			d.nombre
			INTO vNumSolic, vNumCte, vNomCte, vSucursal, dtFechaSolic, vStatusAnt,
				dtFechaReenv, dtHoraReenv, vStatusAct, vTpoMovto,vNombreAnalista			
		FROM bdisolic:ss_autorizacion_especial esp, bdisolic: ss_solicitudes a,
		bdinteg:si_cliente c , bdinteg:si_ejecut d , bdisolic:ss_resum_scor_fin e 
		WHERE a.num_solicitud = esp.num_solicitud 
		AND a.numcte =  a.numcte 
		AND e.num_solicitud = a.num_solicitud
		AND esp.num_solicitud = pNumSolic 
		--(CASE WHEN pNumSolic IS NULL THEN esp.num_solicitud ELSE TRIM(pNumSolic) END)
		--AND esp.numcte = (CASE WHEN pNumCte IS NULL THEN esp.numcte ELSE TRIM(pNumCte) END)	  
		AND esp.usuario_modif = d.ejecutivo AND d.sucursal = '9700'
		--AND esp.fecha_modif >= (CASE WHEN pFechaIni IS NULL THEN esp.fecha_modif ELSE pFechaIni END) 
		--AND esp.fecha_modif <= (CASE WHEN pFechaFin IS NULL THEN esp.fecha_modif ELSE pFechaFin END)
		AND c.numcte = a.numcte 
		AND esp.status_ant = 'OA'
		
		FOREACH WITH HOLD
				SELECT b.fecha_insert,b.fecha_hora
				INTO dtFechaIngreso, dtHoraIngreso
				FROM ss_autorizacion b
				WHERE b.num_solicitud = vNumSolic 
				AND b.status_solicitud = 'OA'
				AND b.fecha_insert <= dtFechaReenv
				ORDER BY b.fecha_insert DESC
				EXIT FOREACH;
		END FOREACH;
	
		INSERT INTO bdicnweb:"informix".sw_consultasolsupdetsol(numerosolicitud, numerocliente, nombrecliente, sucursal, fechasolicitud, status, fechaingresostatus, horaingresostatus, fechareenvio, horareenvio, statusactual, tipomovimiento, nombreanalista, usuario) 
		VALUES(NVL(vNumSolic,''), NVL(vNumCte,''), NVL(vNomCte,''), NVL(vSucursal,''), NVL(dtFechaSolic,DATE(1)), NVL(vStatusAnt,''), NVL(dtFechaIngreso,DATE(1)), NVL(dtHoraIngreso,''), NVL(dtFechaReenv,DATE(1)), 
		NVL(dtHoraReenv,''), NVL(vStatusAct,''), NVL(vTpoMovto,''), NVL(vNombreAnalista,''), pUsuario);
	
	END FOREACH;
	
	ELIF pNumCte <> '' THEN
	
		FOREACH WITH HOLD
			SELECT a.num_solicitud, a.numcte, 
				TRIM(NVL(c.nombre1,'')) ||' '||
				TRIM(NVL(c.nombre2,'')) ||' '||
				TRIM(NVL(c.apell_paterno,'')) ||' '||
				TRIM(NVL(c.apell_materno,'')) AS nom_cte,
				a.sucursal,
				a.fecha_insert,
				esp.status_ant,
				(SELECT i.fecha_insert FROM ss_autorizacion i 
				WHERE i.num_solicitud = esp.num_solicitud AND i.status_solicitud = esp.status_nvo AND i.fecha_insert = esp.fecha_modif),
				(SELECT j.fecha_hora FROM ss_autorizacion j 
				WHERE j.num_solicitud = esp.num_solicitud AND j.status_solicitud = esp.status_nvo AND j.fecha_insert = esp.fecha_modif),
				a.status_solicitud,
				CASE WHEN TRIM(NVL(e.tipo_movimiento,'')) = 'M' THEN 'MIXTO' ELSE 'UNICO' END CASE,
				d.nombre
			INTO vNumSolic, vNumCte, vNomCte, vSucursal, dtFechaSolic, vStatusAnt,
				dtFechaReenv, dtHoraReenv, vStatusAct, vTpoMovto,vNombreAnalista			
			FROM bdisolic:ss_autorizacion_especial esp, bdisolic: ss_solicitudes a,
			bdinteg:si_cliente c , bdinteg:si_ejecut d , bdisolic:ss_resum_scor_fin e 
			WHERE a.num_solicitud = esp.num_solicitud 
			AND a.numcte =  a.numcte 
			AND e.num_solicitud = a.num_solicitud
			--AND esp.num_solicitud = pNumSolic --(CASE WHEN pNumSolic IS NULL THEN esp.num_solicitud ELSE TRIM(pNumSolic) END)
			AND esp.numcte = pNumCte	  
			AND esp.usuario_modif = d.ejecutivo AND d.sucursal = '9700'
			--AND esp.fecha_modif >= (CASE WHEN pFechaIni IS NULL THEN esp.fecha_modif ELSE pFechaIni END) 
			--AND esp.fecha_modif <= (CASE WHEN pFechaFin IS NULL THEN esp.fecha_modif ELSE pFechaFin END)
			AND c.numcte = a.numcte 
			AND esp.status_ant = 'OA'
		
		FOREACH WITH HOLD
				SELECT b.fecha_insert,b.fecha_hora
				INTO dtFechaIngreso, dtHoraIngreso
				FROM ss_autorizacion b
				WHERE b.num_solicitud = vNumSolic 
				AND b.status_solicitud = 'OA'
				AND b.fecha_insert <= dtFechaReenv
				ORDER BY b.fecha_insert DESC
				EXIT FOREACH;
		END FOREACH;
		
		INSERT INTO bdicnweb:"informix".sw_consultasolsupdetsol(numerosolicitud, numerocliente, nombrecliente, sucursal, fechasolicitud, status, fechaingresostatus, horaingresostatus, fechareenvio, horareenvio, statusactual, tipomovimiento, nombreanalista, usuario) 
		VALUES(NVL(vNumSolic,''), NVL(vNumCte,''), NVL(vNomCte,''), NVL(vSucursal,''), NVL(dtFechaSolic,DATE(1)), NVL(vStatusAnt,''), NVL(dtFechaIngreso,DATE(1)), NVL(dtHoraIngreso,''), NVL(dtFechaReenv,DATE(1)), 
		NVL(dtHoraReenv,''), NVL(vStatusAct,''), NVL(vTpoMovto,''), NVL(vNombreAnalista,''), pUsuario);
	
	END FOREACH;
	
	ELSE
	
	FOREACH WITH HOLD
		SELECT a.num_solicitud, a.numcte, 
				TRIM(NVL(c.nombre1,'')) ||' '||
				TRIM(NVL(c.nombre2,'')) ||' '||
				TRIM(NVL(c.apell_paterno,'')) ||' '||
				TRIM(NVL(c.apell_materno,'')) AS nom_cte,
				a.sucursal,
				a.fecha_insert,
				esp.status_ant,
				(SELECT i.fecha_insert FROM ss_autorizacion i
				WHERE i.num_solicitud = esp.num_solicitud AND i.status_solicitud =  esp.status_nvo AND i.fecha_insert = esp.fecha_modif ),
				(SELECT j.fecha_hora FROM ss_autorizacion j
				WHERE j.num_solicitud = esp.num_solicitud AND j.status_solicitud =  esp.status_nvo AND j.fecha_insert = esp.fecha_modif  ),			
				a.status_solicitud,
				CASE WHEN TRIM(NVL(e.tipo_movimiento,'')) = 'M' THEN 'MIXTO' ELSE 'UNICO' END CASE,
				d.nombre
		INTO vNumSolic, vNumCte, vNomCte, vSucursal, dtFechaSolic, vStatusAnt,
			 dtFechaReenv, dtHoraReenv, vStatusAct, vTpoMovto,vNombreAnalista			
		FROM bdisolic:ss_autorizacion_especial esp, bdisolic: ss_solicitudes a,
		bdinteg:si_cliente c , bdinteg:si_ejecut d , bdisolic:ss_resum_scor_fin e 
		WHERE a.num_solicitud = esp.num_solicitud 
		AND a.numcte =  a.numcte 
		AND e.num_solicitud = a.num_solicitud
		--AND esp.num_solicitud = pNumSolic --(CASE WHEN pNumSolic IS NULL THEN esp.num_solicitud ELSE TRIM(pNumSolic) END)
		--AND esp.numcte = (CASE WHEN pNumCte IS NULL THEN esp.numcte ELSE TRIM(pNumCte) END)	  
		AND esp.usuario_modif = d.ejecutivo AND d.sucursal = '9700'
		AND esp.fecha_modif BETWEEN pFechaIni AND pFechaIni
		AND esp.status_ant = 'OA'
		AND c.numcte = a.numcte 
		
		FOREACH WITH HOLD
				SELECT b.fecha_insert,b.fecha_hora
				INTO dtFechaIngreso, dtHoraIngreso
				FROM ss_autorizacion b
				WHERE b.num_solicitud = vNumSolic 
				AND b.status_solicitud = 'OA'
				AND b.fecha_insert <= dtFechaReenv
				ORDER BY b.fecha_insert DESC
				EXIT FOREACH;
		END FOREACH;
	
		INSERT INTO bdicnweb:"informix".sw_consultasolsupdetsol(numerosolicitud, numerocliente, nombrecliente, sucursal, fechasolicitud, status, fechaingresostatus, horaingresostatus, fechareenvio, horareenvio, statusactual, tipomovimiento, nombreanalista, usuario) 
		VALUES(NVL(vNumSolic,''), NVL(vNumCte,''), NVL(vNomCte,''), NVL(vSucursal,''), NVL(dtFechaSolic,DATE(1)), NVL(vStatusAnt,''), NVL(dtFechaIngreso,DATE(1)), NVL(dtHoraIngreso,''), NVL(dtFechaReenv,DATE(1)), 
		NVL(dtHoraReenv,''), NVL(vStatusAct,''), NVL(vTpoMovto,''), NVL(vNombreAnalista,''), pUsuario);
	
	END FOREACH;
	END IF;

	SELECT  COUNT(*)
	INTO iNumRegistros
	FROM bdicnweb:"informix".sw_consultasolsupdetsol 
	WHERE usuario = pUsuario;

	IF NVL(iNumRegistros,0) = 0 THEN
		LET cCodRet = '000002';
		LET cMensajeRet = 'No hay informacion para el filtro indicado';
	END IF;
	
	RETURN NVL(cCodRet,''),NVL(cMensajeRet,''),NVL(iNumRegistros,0);
	
END
END PROCEDURE

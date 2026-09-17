CREATE PROCEDURE "informix".sp_rptsolsup_reean_totales (pEmpresa CHAR(3), pFechaIni DATE, pFechaFin DATE, pUsuario CHAR(10))
RETURNING CHAR(6)         AS codigo_retorno,
          INTEGER AS num_registros;

	-- DECLARACIONES
	DEFINE cCodRet          	CHAR(6); 
	DEFINE cMensajeRet      	VARCHAR(80,1);
	DEFINE iSqlErr      		INTEGER;
	DEFINE iIsamErr         	INTEGER;
	DEFINE cErrorInfo       	VARCHAR(80,1);
	
	DEFINE vEjecutivo          	VARCHAR(10,1);
	DEFINE vNombre             	VARCHAR(180,1);
	DEFINE iTotalAtendidas     	INTEGER;
	DEFINE iPorAtendidas       	INTEGER;
	DEFINE iTotalTDC           	INTEGER;
	DEFINE iPorcTDC            	INTEGER;
	DEFINE iTotalCoppel        	INTEGER;
	DEFINE iPorcCoppel         	INTEGER;
	DEFINE iTotalPP            	INTEGER;
	DEFINE iPorcPP             	INTEGER;
	DEFINE iNumReg             	INTEGER;
	DEFINE iTotal              	INTEGER;
	DEFINE iPorcGenAten        	INTEGER;
	DEFINE iPorcGenTDC         	INTEGER;
	DEFINE iPorcGenCoppel      	INTEGER;
	DEFINE iPorcGenPP          	INTEGER;
	DEFINE iContAtendidas      	INTEGER;
	DEFINE iContTDC            	INTEGER;  
	DEFINE iContCoppel         	INTEGER;
	DEFINE iContPP             	INTEGER;
	
	-- INICIALIZACIONES
	LET iSqlErr             = 0;
	LET iIsamErr            = 0;
	LET cErrorInfo          = '';
	LET cCodRet             = '000000';
	LET cMensajeRet         = 'Se realizo la consulta correctamente';
	
	LET vEjecutivo          = '';
	LET vNombre             = '';
	LET iTotalAtendidas     = 0;
	LET iPorAtendidas       = 0;
	LET iTotalTDC           = 0;
	LET iPorcTDC            = 0;
	LET iTotalCoppel        = 0;
	LET iPorcCoppel         = 0;
	LET iTotalPP            = 0;
	LET iPorcPP             = 0;
	LET iNumReg             = 0;
	LET iTotal              = 0;
	LET iPorcGenAten        = 0;
	LET iPorcGenTDC         = 0;
	LET iPorcGenCoppel      = 0;
	LET iPorcGenPP          = 0;
	LET iContAtendidas      = 0;
	LET iContTDC            = 0;
	LET iContCoppel         = 0;
	LET iContPP             = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
			IF iSqlErr != 0 THEN
				LET cCodRet= iSqlErr;
				LET cMensajeRet = cErrorInfo;
				RETURN cCodRet,iNumReg;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_rptsolsup_reean_totales.out';
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF NVL(pFechaIni,'') = '' THEN
			LET pFechaIni = NULL;
		END IF;
		
		IF NVL(pFechaFin,'') = '' THEN
			LET pFechaFin = NULL;
		END IF;
		
		DELETE FROM bdicnweb:"informix".sw_consultasolsupreenvioanalista WHERE usuario = pUsuario;
		
		
		SELECT COUNT(b.num_solicitud)
		INTO iTotal
		FROM bdisolic:ss_autorizacion_especial b 
		INNER JOIN bdinteg:si_ejecut c ON (b.usuario_modif = c.ejecutivo AND c.sucursal = '9700')
		WHERE 
		b.fecha_modif >= pFechaIni
		AND b.fecha_modif <= pFechaFin
		AND b.status_ant = 'OA'
		AND b.status_nvo = 'EE';
		
		
		FOREACH WITH HOLD
			SELECT c.ejecutivo, c.nombre,
				SUM(CASE WHEN TRIM(tipo_solicitud) = 'T' THEN 1 ELSE 0 END),	
				SUM(CASE WHEN TRIM(tipo_solicitud) = 'C' THEN 1 ELSE 0 END),	
				SUM(CASE WHEN TRIM(tipo_solicitud) = 'P' THEN 1 ELSE 0 END)
			INTO vEjecutivo, vNombre, iTotalTDC, iTotalCoppel, iTotalPP	
			FROM bdisolic:ss_autorizacion_especial  a
			INNER JOIN bdisolic:ss_solicitudes b ON (b.num_solicitud = a.num_solicitud )	
			INNER JOIN bdinteg:si_ejecut c ON (a.usuario_modif = c.ejecutivo AND c.sucursal = '9700')
			where a.num_solicitud = b.num_solicitud 
			AND a.fecha_modif >= pFechaIni
			AND a.fecha_modif <= pFechaFin
			AND a.status_ant = 'OA' AND a.status_nvo = 'EE'
			GROUP BY 1,2
			ORDER BY 1
			
			LET iTotalAtendidas = iTotalTDC + iTotalCoppel + iTotalPP;
			IF iTotalAtendidas > 0 THEN LET iPorAtendidas = (iTotalAtendidas * 100)/iTotal; END IF;
			IF iTotalTDC > 0 THEN LET iPorcTDC = (iTotalTDC * 100)/iTotalAtendidas; END IF;
			IF iTotalCoppel > 0 THEN LET iPorcCoppel = (iTotalCoppel * 100)/iTotalAtendidas; END IF;
			IF iTotalPP > 0 THEN LET iPorcPP = (iTotalPP * 100)/iTotalAtendidas; END IF;
			
			INSERT INTO bdicnweb:"informix".sw_consultasolsupreenvioanalista(numeroempleado, nombreempleado, atendidas, porcatendidas, tdcatendidas, porctdcatendidas, coppelatendidas, porccoppelatendidas, ppatendidas, porcppatendidas, usuario) 
			VALUES(NVL(vEjecutivo,''),NVL(vNombre,''),NVL(iTotalAtendidas,0), NVL(iPorAtendidas,0),NVL(iTotalTDC,0),NVL(iPorcTDC,0),
					NVL(iTotalCoppel,0),NVL(iPorcCoppel,0), NVL(iTotalPP,0), NVL(iPorcPP,0), pUsuario);

		END FOREACH
		
		SELECT COUNT(*)
		INTO iNumReg
		FROM bdicnweb:"informix".sw_consultasolsupreenvioanalista
		WHERE usuario = pUsuario;
		
		IF iNumReg = 0 THEN
			LET cCodRet = '000002';
			LET cMensajeRet = 'No hay informacion para el filtro indicado';
		ELSE 
			LET iNumReg = iNumReg + 1;
		END IF;
		
		RETURN cCodRet,iNumReg;
		
	END
END PROCEDURE

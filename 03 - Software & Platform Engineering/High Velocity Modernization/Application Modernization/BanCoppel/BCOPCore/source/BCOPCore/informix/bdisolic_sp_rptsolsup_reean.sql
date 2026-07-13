CREATE PROCEDURE "informix".sp_rptsolsup_reean(pEmpresa CHAR(3), pFechaIni DATE, pFechaFin DATE, pUsuario CHAR(10), pInicio INTEGER, pFinal INTEGER)
	RETURNING CHAR(6)         AS codigo_retorno,
          VARCHAR(80,1)   AS mensaje_retorno,
		  VARCHAR(10,1)   AS numero_empleado,
		  VARCHAR(180,1)  AS nombre_empleado,
		  INTEGER         AS atendidas,
		  INTEGER         AS porc_atendidas,
		  INTEGER         AS tdc_atendidas,
		  INTEGER         AS porc_tdc_atendidas,
		  INTEGER         AS coppel_atendidas,
		  INTEGER         AS porc_coppel_atendidas,
		  INTEGER         AS pp_atendidas,
		  INTEGER         AS porc_pp_atendidas;

	---DECLARACIONES
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
	
	---INICIALIZACIONES
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
			RETURN NVL(cCodRet,''), NVL(cMensajeRet,''),NVL(vEjecutivo,''),NVL(vNombre,''),NVL(iTotalAtendidas,0),
					NVL(iPorAtendidas,0),NVL(iTotalTDC,0),NVL(iPorcTDC,0),NVL(iTotalCoppel,0),NVL(iPorcCoppel,0),
					NVL(iTotalPP,0), NVL(iPorcPP,0);
		END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_rptsolsup_reean.out';
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF NVL(pFechaIni,'') = '' THEN
			LET pFechaIni = NULL;
		END IF;
		
		IF NVL(pFechaFin,'') = '' THEN
			LET pFechaFin = NULL;
		END IF;
		
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
			SELECT SKIP pInicio FIRST pFinal numeroempleado, nombreempleado, atendidas, porcatendidas, tdcatendidas, 
				porctdcatendidas, coppelatendidas, porccoppelatendidas, ppatendidas, porcppatendidas
			INTO vEjecutivo, vNombre, iTotalAtendidas, iPorAtendidas, iTotalTDC, iPorcTDC,
					iTotalCoppel, iPorcCoppel, iTotalPP, iPorcPP
			FROM bdicnweb:"informix".sw_consultasolsupreenvioanalista
			WHERE usuario = pUsuario
			
			LET iContAtendidas = iContAtendidas + iTotalAtendidas;
			LET iContTDC       = iContTDC + iTotalTDC;
			LET iContCoppel    = iContCoppel + iTotalCoppel;
			LET iContPP        = iContPP + iTotalPP;
		
			RETURN NVL(cCodRet,''), NVL(cMensajeRet,''),NVL(vEjecutivo,''),NVL(vNombre,''),NVL(iTotalAtendidas,0),
					NVL(iPorAtendidas,0),NVL(iTotalTDC,0),NVL(iPorcTDC,0),NVL(iTotalCoppel,0),NVL(iPorcCoppel,0),
					NVL(iTotalPP,0), NVL(iPorcPP,0) WITH RESUME;
		END FOREACH;
		
		LET iNumReg = dbinfo("sqlca.sqlerrd2");
		
		IF iNumReg = 0 THEN
			LET cCodRet = '000002';
			LET cMensajeRet = 'No hay informacion para el filtro indicado';
			RETURN NVL(cCodRet,''), NVL(cMensajeRet,''),NVL(vEjecutivo,''),NVL(vNombre,''),NVL(iTotalAtendidas,0),
				NVL(iPorAtendidas,0),NVL(iTotalTDC,0),NVL(iPorcTDC,0),NVL(iTotalCoppel,0),NVL(iPorcCoppel,0),
				NVL(iTotalPP,0), NVL(iPorcPP,0);
		ELSE
			LET iPorcGenAten    = (iContAtendidas * 100)/iTotal;
			LET iPorcGenTDC     = (iContTDC * 100)/iTotal;
			LET iPorcGenCoppel  = (iContCoppel * 100)/iTotal;
			LET iPorcGenPP      = (iContPP * 100)/iTotal;	
			
			RETURN NVL(cCodRet,''), NVL(cMensajeRet,''),'   TOTAL ','',NVL(iTotal,0),
				NVL(iPorcGenAten,0),NVL(iContTDC,0),NVL(iPorcGenTDC,0),NVL(iContCoppel,0),NVL(iPorcGenCoppel,0),
				NVL(iContPP,0), NVL(iPorcGenPP,0);
		END IF;
		
	END
END PROCEDURE

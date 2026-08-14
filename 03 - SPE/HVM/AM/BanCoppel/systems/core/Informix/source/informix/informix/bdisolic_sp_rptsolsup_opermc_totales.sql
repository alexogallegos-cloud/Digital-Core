CREATE PROCEDURE "informix".sp_rptsolsup_opermc_totales(pEmpresa CHAR(3), pFechaIni DATE, pFechaFin DATE, pUsuario CHAR(10))
RETURNING CHAR(6)        AS codigo_retorno,
          INTEGER AS num_registros;
		  
	-- DECLARACIONES
	DEFINE cCodRet          		CHAR(6); 
	DEFINE cMensajeRet      		VARCHAR(80,1);
	DEFINE iSqlErr      			INTEGER;
	DEFINE iIsamErr         		INTEGER;
	DEFINE cErrorInfo       		VARCHAR(80,1);
	
	DEFINE dtFecha                  DATE;
	DEFINE iTotalxFecha             INTEGER;
	DEFINE iTotalAtendidasxFecha    INTEGER;
	DEFINE iNoAtendidasxFecha       INTEGER;
	DEFINE iPorcNoAtendidas         INTEGER;
	DEFINE iPorcAtendidas           INTEGER;
	DEFINE iTotalGeneralfinal       INTEGER;
	DEFINE iTotalAtendidasfinal     INTEGER;
	DEFINE iTotalNoAtendidasfinal   INTEGER;
	DEFINE iPorcNoAtendidasfinal    INTEGER;
	DEFINE iPorcAtendidasfinal      INTEGER;
	DEFINE iNumReg                  INTEGER;
	
	---INICIALIZACIONES
	LET iSqlErr             	= 0;
	LET iIsamErr            	= 0;
	LET cErrorInfo          	= '';
	LET cCodRet             	= '000000';
	LET cMensajeRet         	= 'Se realizo la consulta correctamente';		  
	
	LET dtFecha                 = DATE(1);
	LET iTotalxFecha            = 0;
	LET iTotalAtendidasxFecha   = 0;
	LET iNoAtendidasxFecha      = 0;
	LET iPorcNoAtendidas        = 0;
	LET iPorcAtendidas          = 0;
	LET iTotalGeneralfinal      = 0;
	LET iTotalAtendidasfinal    = 0;
	LET iTotalNoAtendidasfinal  = 0;
	LET iPorcNoAtendidasfinal   = 0;
	LET iPorcAtendidasfinal     = 0;
	LET iNumReg                 = 0;
	
	BEGIN
	
	ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
	IF iSqlErr != 0 THEN
		LET cCodRet= iSqlErr;
		LET cMensajeRet = cErrorInfo;
		RETURN cCodRet,iNumReg;
	END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO '/tmp/mfinis/sp_rptsolsup_opermc.out';
	--TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	IF NVL(pFechaIni,'') = '' OR NVL(pFechaFin,'') = '' OR NVL(pUsuario,'') = '' THEN
		LET cCodRet = "000001";
		LET cMensajeRet = 'Parámetros de execución incorrectos';
		RETURN cCodRet,iNumReg;
	END IF;
	
	DELETE FROM bdicnweb:"informix".sw_consultasolsupoperacionmc WHERE usuario = pUsuario;

	IF NVL(pFechaIni,'') = '' THEN
		LET pFechaIni = NULL;
	END IF;
	
	IF NVL(pFechaFin,'') = '' THEN
		LET pFechaFin = NULL;
	END IF;
		
		FOREACH WITH HOLD
			SELECT e.FECHA_INSERT, COUNT(e.FECHA_INSERT) 
			INTO dtFecha,iTotalxFecha
			FROM bdisolic:ss_autorizacion e
			WHERE e.FECHA_INSERT >= pFechaIni
			AND e.FECHA_INSERT <=  pFechaFin
			AND e.status_solicitud = 'OA'
			GROUP BY 1
			ORDER BY 1
			
			SELECT COUNT(b.num_solicitud)
			INTO iTotalAtendidasxFecha
			FROM bdisolic:ss_autorizacion_especial  b
			--INNER JOIN bdisolic: ss_autorizacion a on(a.num_solicitud = b.num_solicitud and a.status_solicitud = status_ant AND a.FECHA_INSERT = dtFecha)
			WHERE b.fecha_modif =  dtFecha
			--AND b.fecha_modif <= dtFecha
			AND b.status_ant = 'OA';
			
			LET iNoAtendidasxFecha = iTotalxFecha - iTotalAtendidasxFecha;
			LET iPorcNoAtendidas = (iNoAtendidasxFecha * 100)/iTotalxFecha;
			LET iPorcAtendidas = 100 - iPorcNoAtendidas;
			
			INSERT INTO bdicnweb:"informix".sw_consultasolsupoperacionmc(fecha, generadas, noatendidas, porcnoatendidas, atendidas, porcatendidas, usuario) 
			VALUES(NVL(dtFecha,''), NVL(iTotalxFecha,0), NVL(iNoAtendidasxFecha,0), NVL(iPorcNoAtendidas,0), NVL(iTotalAtendidasxFecha,0), NVL(iPorcAtendidas,0), pUsuario);
			
		END FOREACH;
	
	
		SELECT COUNT(*)
		INTO iNumReg
		FROM bdicnweb:"informix".sw_consultasolsupoperacionmc
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

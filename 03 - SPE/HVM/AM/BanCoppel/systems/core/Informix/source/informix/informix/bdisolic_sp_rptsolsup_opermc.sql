CREATE PROCEDURE "informix".sp_rptsolsup_opermc(pEmpresa CHAR(3), pFechaIni DATE, pFechaFin DATE, pUsuario CHAR(10))
RETURNING CHAR(6)        AS codigo_retorno,
          VARCHAR(80,1)  AS mensaje_retorno,	
		  VARCHAR(10,1)     AS fecha,
		  INTEGER        AS generadas,
          INTEGER        AS no_atendidas, 
		  INTEGER        AS porc_no_atendidas,
		  INTEGER        AS atendidas,
		  INTEGER        AS porc_atendidas;
		  
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
	LET cMensajeRet        		= 'Se realizo la consulta correctamente';		  
	
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
		RETURN cCodRet, cMensajeRet, NVL(dtFecha,''), NVL(iTotalxFecha,0), NVL(iNoAtendidasxFecha,0), NVL(iPorcNoAtendidas,0), NVL(iTotalAtendidasxFecha,0), NVL(iPorcAtendidas,0);
	END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO '/tmp/mfinis/sp_rptsolsup_opermc.out';
	--TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	IF NVL(pFechaIni,'') = '' OR NVL(pFechaFin,'') = '' OR NVL(pUsuario,'') = '' THEN
		LET cCodRet = '000001';
		LET cMensajeRet = 'Parametros de execucion incorrectos';
		RETURN cCodRet, cMensajeRet, NVL(dtFecha,''), NVL(iTotalxFecha,0), NVL(iNoAtendidasxFecha,0), NVL(iPorcNoAtendidas,0), NVL(iTotalAtendidasxFecha,0), NVL(iPorcAtendidas,0);
	END IF;
	
	IF NVL(pFechaIni,'') = '' THEN
		LET pFechaIni = NULL;
	END IF;
	
	IF NVL(pFechaFin,'') = '' THEN
		LET pFechaFin = NULL;
	END IF;
	
	FOREACH WITH HOLD
		SELECT fecha, generadas, noatendidas, porcnoatendidas, atendidas, porcatendidas
		INTO dtFecha, iTotalxFecha, iNoAtendidasxFecha, iPorcNoAtendidas, iTotalAtendidasxFecha, iPorcAtendidas
		FROM bdicnweb:"informix".sw_consultasolsupoperacionmc
		WHERE usuario = pUsuario
		
		LET iTotalGeneralfinal = iTotalGeneralfinal + iTotalxFecha;
		LET iTotalAtendidasfinal = iTotalAtendidasfinal + iTotalAtendidasxFecha;
		LET iTotalNoAtendidasfinal = iTotalNoAtendidasfinal + iNoAtendidasxFecha;
			
		RETURN cCodRet, cMensajeRet, NVL(dtFecha,''), NVL(iTotalxFecha,0), NVL(iNoAtendidasxFecha,0), NVL(iPorcNoAtendidas,0), NVL(iTotalAtendidasxFecha,0), NVL(iPorcAtendidas,0) WITH RESUME;
		
	END FOREACH;
	
	LET iNumReg = dbinfo("sqlca.sqlerrd2");
	IF iNumReg = 0 THEN
		LET cCodRet = '00002';
		LET cMensajeRet = 'No hay informacion para el filtro indicado';
		RETURN cCodRet, cMensajeRet, NVL(dtFecha,''), NVL(iTotalxFecha,0), NVL(iNoAtendidasxFecha,0), NVL(iPorcNoAtendidas,0), NVL(iTotalAtendidasxFecha,0), NVL(iPorcAtendidas,0);
	ELSE
		LET iPorcNoAtendidasfinal = (iTotalNoAtendidasfinal * 100)/iTotalGeneralfinal;
		LET iPorcAtendidasfinal = 100 - iPorcNoAtendidasfinal;
		
		RETURN cCodRet, cMensajeRet, '   TOTAL ', NVL(iTotalGeneralfinal,0), NVL(iTotalNoAtendidasfinal,0), NVL(iPorcNoAtendidasfinal,0), NVL(iTotalAtendidasfinal,0), NVL(iPorcAtendidasfinal,0);		

	END IF;
		
	END
END PROCEDURE

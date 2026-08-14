CREATE PROCEDURE "informix".sp_rptsolsup_conest(pEmpresa CHAR(3), pStatus CHAR(2), pFechaIni DATE, pFechaFin DATE, pUsuario CHAR(10), pInicio INTEGER, pFinal INTEGER)
RETURNING CHAR(6)         AS codigo_retorno,
          VARCHAR(80,1)   AS mensaje_retorno,
		  VARCHAR(20,1)   AS num_solicitud,
		  VARCHAR(20,1)   AS num_cte,
		  VARCHAR(180,1)  AS nom_cte,
		  CHAR(4)         AS sucursal,
		  CHAR(4)         AS num_producto,
		  DECIMAL(18,2)   AS linea_asignada,
		  VARCHAR(3,1)    AS status,
		  DATE            AS fecha_cambio_status,
		  DATETIME YEAR TO SECOND AS hora_cambio_status,
		  VARCHAR(20,1)   AS num_cte_ref,
		  DECIMAL(5,2)    AS eficiencia,
		  INTEGER         AS meses_historia,
		  DECIMAL(18,2)   AS vdo_coppel,
		  CHAR(2)         AS puntualidad,
		  DECIMAL(5,2)    AS bc_score,
		  DECIMAL(5,2)    AS score_propietario,
		  VARCHAR(20,1)   AS tpo_movto;

	-- DECLARACIONES
	DEFINE cCodRet          	 CHAR(6); 
	DEFINE cMensajeRet      	 VARCHAR(80,1);
	DEFINE iSqlErr      		 INTEGER;
	DEFINE iIsamErr         	 INTEGER;
	DEFINE cErrorInfo       	 VARCHAR(80,1);
	
	DEFINE vNumSolicitud         VARCHAR(20,1);
	DEFINE vNumCte               VARCHAR(20,1);
	DEFINE vNombreCte            VARCHAR(180,1);
	DEFINE vSucursal             CHAR(4);
	DEFINE vNumProducto          CHAR(4);
	DEFINE dLineaAsignada        DECIMAL(18,2);
	DEFINE vStatus               VARCHAR(3,1); 
	DEFINE dtFechaCambioStatus   DATE;
	DEFINE dtHoraCambioStatus    DATETIME YEAR TO SECOND;
	DEFINE vNumCteRef            VARCHAR(20,1);
	DEFINE dEficiencia           DECIMAL(5,2);
	DEFINE iMesesHistoria        INTEGER; 
	DEFINE dVdoCoppel            DECIMAL(18,2);
	DEFINE cPuntualidad          CHAR(2);
	DEFINE dBcScore              DECIMAL(5,2);
	DEFINE dScorePropietario     DECIMAL(5,2);   
	DEFINE vTpoMovto             VARCHAR(20,1);
	DEFINE iNumReg               INTEGER;
	
	-- INICIALIZACIONES
	LET iSqlErr               = 0;
	LET iIsamErr              = 0;
	LET cErrorInfo            = '';
	LET cCodRet               = '000000';
	LET cMensajeRet           = 'Se realizo la consulta correctamente';
	
	LET vNumSolicitud         = '';
	LET vNumCte               = '';
	LET vNombreCte            = '';
	LET vSucursal             = '';
	LET vNumProducto          = '';
	LET dLineaAsignada        = 0;
	LET vStatus               = '';
	LET dtFechaCambioStatus   = DATE(1);
	LET dtHoraCambioStatus    = '';
	LET vNumCteRef            = '';
	LET dEficiencia           = 0;
	LET iMesesHistoria        = 0;
	LET dVdoCoppel            = 0;
	LET cPuntualidad          = '';
	LET dBcScore              = 0;
	LET dScorePropietario     = 0;
	LET vTpoMovto             = '';
	LET iNumReg               = 0;
	
	BEGIN
	
	ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
		IF iSqlErr != 0 THEN
			LET cCodRet= iSqlErr;
			LET cMensajeRet = cErrorInfo;
			RETURN NVL(cCodRet,''), NVL(cMensajeRet,''), NVL(vNumSolicitud,''), NVL(vNumCte,''), NVL(vNombreCte,''),
				NVL(vSucursal,''), NVL(vNumProducto,''), NVL(dLineaAsignada,0), NVL(vStatus,''), NVL(dtFechaCambioStatus,DATE(1)),
				NVL(dtHoraCambioStatus,''), NVL(vNumCteRef,''), NVL(dEficiencia,0), NVL(iMesesHistoria,0), NVL(dVdoCoppel,0),
				NVL(cPuntualidad,''), NVL(dBcScore,0), NVL(dScorePropietario,0), NVL(vTpoMovto,'');
		END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO '/tmp/mfinis/sp_rptsolsup_conest.out';
	--TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	IF NVL(pStatus,'') = '' OR NVL(pFechaIni,'') = '' OR NVL(pFechaFin,'') = '' OR NVL(pUsuario,'') = '' THEN
		LET cCodRet = '000001';
		LET cMensajeRet = 'Parámetros de execución incorrectos';
		RETURN NVL(cCodRet,''), NVL(cMensajeRet,''), NVL(vNumSolicitud,''), NVL(vNumCte,''), NVL(vNombreCte,''),
			NVL(vSucursal,''), NVL(vNumProducto,''), NVL(dLineaAsignada,0), NVL(vStatus,''), NVL(dtFechaCambioStatus,DATE(1)),
			NVL(dtHoraCambioStatus,''), NVL(vNumCteRef,''), NVL(dEficiencia,0), NVL(iMesesHistoria,0), NVL(dVdoCoppel,0),
			NVL(cPuntualidad,''), NVL(dBcScore,0), NVL(dScorePropietario,0), NVL(vTpoMovto,'');
	END IF;

	FOREACH WITH HOLD
		SELECT SKIP pInicio FIRST pFinal numsolicitud, numcte, nombrecte, sucursal, numproducto, lineaasignada, status, 
		fechacambiostatus, horacambiostatus, numcteref, eficiencia, meseshistoria, vdocoppel, puntualidad, bcscore, 
		scorepropietario, tpomovto
		INTO vNumSolicitud, vNumCte, vNombreCte, vSucursal, vNumProducto, dLineaAsignada, vStatus,
		   dtFechaCambioStatus, dtHoraCambioStatus, vNumCteRef, dEficiencia, iMesesHistoria,
		   dVdoCoppel, cPuntualidad, dBcScore, dScorePropietario, vTpoMovto
		FROM bdicnweb:"informix".sw_consultasolsupstatus
		WHERE usuario = pUsuario
	   
		RETURN NVL(cCodRet,''), NVL(cMensajeRet,''), NVL(vNumSolicitud,''), NVL(vNumCte,''), NVL(vNombreCte,''),
              NVL(vSucursal,''), NVL(vNumProducto,''), NVL(dLineaAsignada,0), NVL(vStatus,''), NVL(dtFechaCambioStatus,DATE(1)),
              NVL(dtHoraCambioStatus,''), NVL(vNumCteRef,''), NVL(dEficiencia,0), NVL(iMesesHistoria,0), NVL(dVdoCoppel,0),
              NVL(cPuntualidad,''), NVL(dBcScore,0), NVL(dScorePropietario,0), NVL(vTpoMovto,'') WITH RESUME;
	   
	END FOREACH;   

	LET iNumReg = dbinfo("sqlca.sqlerrd2");
	IF iNumReg = 0 THEN
		LET cCodRet = '000002';
		LET cMensajeRet = 'No hay información para el filtro indicado';
		RETURN NVL(cCodRet,''), NVL(cMensajeRet,''), NVL(vNumSolicitud,''), NVL(vNumCte,''), NVL(vNombreCte,''),
				NVL(vSucursal,''), NVL(vNumProducto,''), NVL(dLineaAsignada,0), NVL(vStatus,''), NVL(dtFechaCambioStatus,DATE(1)),
				NVL(dtHoraCambioStatus,''), NVL(vNumCteRef,''), NVL(dEficiencia,0), NVL(iMesesHistoria,0), NVL(dVdoCoppel,0),
				NVL(cPuntualidad,''), NVL(dBcScore,0), NVL(dScorePropietario,0), NVL(vTpoMovto,'');
	END IF;


	END
END PROCEDURE

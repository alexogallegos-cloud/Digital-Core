CREATE PROCEDURE "informix".sp_rptsolsup_conest_total(pEmpresa CHAR(3), pStatus CHAR(2), pFechaIni DATE, pFechaFin DATE, pUsuario CHAR(10))
RETURNING CHAR(6) AS codigo_retorno,
          CHAR(80) AS mensaje_retorno,
		  INTEGER AS num_registros;

	-- DECLARACIONES
	DEFINE cCodRet          	 CHAR(6); 
	DEFINE cMensajeRet      	 CHAR(80);
	DEFINE iSqlErr      		 INTEGER;
	DEFINE iIsamErr         	 INTEGER;
	DEFINE cErrorInfo       	 VARCHAR(80,1);
	DEFINE iNumRegistros    	 INTEGER;
	
	
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
	
	---INICIALIZACIONES
	LET iSqlErr               = 0;
	LET iIsamErr              = 0;
	LET cErrorInfo            = '';
	LET cCodRet               = '000000';
	LET cMensajeRet           = 'Se realizo la consulta correctamente';
	LET iNumRegistros         = 0;
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
				RETURN NVL(cCodRet,''), NVL(cMensajeRet,''), NVL(iNumRegistros,0);
			END IF;
		END EXCEPTION;

	--SET DEBUG FILE TO '/tmp/mfinis/sp_rptsolsup_conest_total.out';
	--TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	IF NVL(pStatus,'') = '' OR NVL(pFechaIni,'') = '' OR NVL(pFechaFin,'') = '' OR NVL(pUsuario,'') = '' THEN
		LET cCodRet = '000001';
		LET cMensajeRet = 'Parámetros de execución incorrectos';
		RETURN NVL(cCodRet,''), NVL(cMensajeRet,''), NVL(iNumRegistros,0);
	END IF;
	
	DELETE FROM bdicnweb:"informix".sw_consultasolsupstatus WHERE usuario = pUsuario;
	
	FOREACH WITH HOLD
		SELECT a.num_solicitud, b.numcte, 
			TRIM(NVL(b.nombre1,'')) ||' '||
			TRIM(NVL(b.nombre2,'')) ||' '||
			TRIM(NVL(b.apell_paterno,'')) ||' '||
			TRIM(NVL(b.apell_materno,'')) AS nom_cte,
			a.sucursal,
			a.num_producto,
			CASE WHEN a.tipo_solicitud = 'P' THEN a.monto_autorizado else a.monto_solicitado END CASE,
			a.status_solicitud,
			aut.fecha_insert,
			aut.fecha_hora,
			b.numcte_ref,
			c.situacion_pago,
			c.meses_historia,
			nvl(c.vencidoropa,0) + nvl(c.vencidomuebles,0) + nvl(c.vencidoprestamos,0),
			c.puntualidad,
			(select f.evaluacion from bdisolic:ss_resumen_scoring f where f.num_solicitud = a.num_solicitud and f.seccion = 1),
			(select g.evaluacion from bdisolic:ss_resumen_scoring g where g.num_solicitud = a.num_solicitud and g.seccion = 2),
			CASE WHEN c.tipo_movimiento = 'M' THEN 'Mixto' ELSE 'Unico' END CASE
		INTO vNumSolicitud, vNumCte, vNombreCte, vSucursal, vNumProducto, dLineaAsignada, vStatus,
			dtFechaCambioStatus, dtHoraCambioStatus, vNumCteRef, dEficiencia, iMesesHistoria,
			dVdoCoppel, cPuntualidad, dBcScore, dScorePropietario, vTpoMovto
		FROM bdisolic:ss_solicitudes a
		INNER JOIN bdinteg:si_cliente b ON (b.numcte = a.numcte)
		FULL OUTER JOIN bdisolic:"informix".ss_autorizacion aut ON (aut.num_solicitud= a.num_solicitud
																AND aut.empresa= a.empresa
																AND aut.status_solicitud= a.status_solicitud
																AND aut.fecha_entrada=(SELECT MAX(aut_aux.fecha_entrada)
																					   FROM bdisolic:"informix".ss_autorizacion aut_aux
																					   WHERE aut_aux.empresa= a.empresa
																					   AND aut_aux.num_solicitud= a.num_solicitud
																					   AND aut_aux.status_solicitud= a.status_solicitud)
																AND aut.ejecutivo_auto= aut.ejecutivo_auto)
		INNER JOIN bdisolic:ss_resum_scor_fin c ON (c.num_solicitud = a.num_solicitud and c.empresa = a.empresa)
		WHERE a.num_solicitud = aut.num_solicitud
		AND a.empresa = '001'
		AND a.status_solicitud = TRIM(pStatus)
		AND a.fecha_insert BETWEEN pFechaIni AND pFechaFin
	   
		
		INSERT INTO bdicnweb:"informix".sw_consultasolsupstatus(numsolicitud, numcte, nombrecte, sucursal, numproducto, lineaasignada, status, fechacambiostatus, horacambiostatus, numcteref, eficiencia, meseshistoria, vdocoppel, puntualidad, bcscore, scorepropietario, tpomovto, usuario) 
		VALUES(NVL(vNumSolicitud,''), NVL(vNumCte,''), NVL(vNombreCte,''), NVL(vSucursal,''), NVL(vNumProducto,''), NVL(dLineaAsignada,0), NVL(vStatus,''), NVL(dtFechaCambioStatus,DATE(1)),
				NVL(dtHoraCambioStatus,''), NVL(vNumCteRef,''), NVL(dEficiencia,0), NVL(iMesesHistoria,0), NVL(dVdoCoppel,0),
				NVL(cPuntualidad,''), NVL(dBcScore,0), NVL(dScorePropietario,0), NVL(vTpoMovto,''),pUsuario);
	   
	END FOREACH;   


	SELECT COUNT(*)
	INTO iNumRegistros
	FROM bdicnweb:"informix".sw_consultasolsupstatus
	WHERE usuario = pUsuario;
  
	IF NVL(iNumRegistros,0) = 0 THEN
		LET cCodRet = '000002';
		LET cMensajeRet = 'No hay informacion para el filtro indicado';
	END IF;

	RETURN NVL(cCodRet,''), NVL(cMensajeRet,''), NVL(iNumRegistros,0);

END
END PROCEDURE

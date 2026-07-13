CREATE PROCEDURE "informix".sp_obtsol_portanom_bpi(pEmpresa CHAR(3),pCliente CHAR(20),pNumRegistros SMALLINT)
RETURNING
	CHAR(5)  AS  CodRet,
	DATE     AS  fechasolicitud,
	CHAR(1)  AS  clavesentido,
	CHAR(20) AS  cuentaordenante,
	CHAR(30) AS  foliosolicitud,
	CHAR(2)  AS  estatusSolicitud;  
	
	-- Creador: Moisés Soriano
	-- Objetivo: Obtiene las solicitudes de portabilidad de nómina del cliente.
	-- Solicitó: Alejandro Vazquez
	-- Fecha: 10/02/2016	
	-- Se agrega la utilización de índices para reducir costos
	-- Bibiana Gaxiola Verdugo
	-- Fecha: 30/03/2016
	
	--Declaracion de  Variables
	DEFINE cCodRet				CHAR (5);
	DEFINE cSqlErr				SMALLINT;
	DEFINE cCiclo				SMALLINT;
	DEFINE vcFechaSolicitud		CHAR(8)	;
	DEFINE vcClaveSentido		CHAR(1);
	DEFINE vcCuentaOrdenante	CHAR(20);
	DEFINE vcCuentaAux			CHAR(20);
	DEFINE vcfolioSolicitud		CHAR(30);
	DEFINE vdFechasol			DATE;
	DEFINE vcFechaAux			CHAR(10);
	DEFINE vcEstatusSolicitud	CHAR(2);
	
	--Inicialización de Variables
	LET cCodRet					= '00000';
	LET cSqlErr					= 0;
	LET cCiclo				  	= 0;
	LET vcFechaSolicitud		= '';
	LET vcClaveSentido			= '';
	LET vcCuentaOrdenante		= '';
	LET vcCuentaAux				= '';
	LET vcfolioSolicitud		= '';
	LET vdFechasol				= '01-01-1900';
	LET vcFechaAux				= '';
	LET vcEstatusSolicitud		= '';
	
	BEGIN
		ON EXCEPTION SET cSqlErr
			IF cSqlErr <> 0 THEN
				LET cCodRet = cSqlErr;
				RETURN cCodRet,vdFechasol,vcClaveSentido,vcCuentaOrdenante,vcfolioSolicitud,vcEstatusSolicitud;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO "/home/sysifx/moises/bdicheq/sp_obtsol_portanom_bpi.out";
		--TRACE ON;
		
		SET LOCK MODE TO WAIT 3;
		FOREACH
			
			SELECT	{+INDEX (sc_portacec_solicitud, idx_cte_cve_estatus)} fecha_solicitud,
					clave_sentido,
					folio_solicitud,
					estatus_portabilidad
				INTO vcFechaSolicitud, vcClaveSentido, vcfolioSolicitud,vcEstatusSolicitud
			FROM bdicheq:"informix".sc_portacec_solicitud 
			WHERE num_cte = pCliente
			AND clave_sentido IN('1','2')
			AND estatus_portabilidad IN ('1','2')
			ORDER BY fecha_solicitud
			
			IF (vcClaveSentido = 1)THEN
				
				SELECT cta_ordenante INTO vcCuentaAux FROM bdicheq:"informix".sc_portacec_solicitud WHERE num_cte = pCliente AND clave_sentido='1' AND folio_solicitud = vcfolioSolicitud;
				--cta_ordenante= cuenta_clabe
				IF EXISTS(SELECT cuenta_clabe FROM bdicheq:"informix".sc_maechq WHERE num_cte = pCliente AND cuenta_clabe = vcCuentaAux)THEN
					SELECT cuenta INTO vcCuentaOrdenante FROM bdicheq:"informix".sc_maechq WHERE num_cte = pCliente AND cuenta_clabe = vcCuentaAux;
				--cta_ordenante = num_tarjeta
				ELIF EXISTS(SELECT num_tarjeta FROM bdicheq:"informix".sc_tarjeta WHERE numcte = pCliente AND num_tarjeta = vcCuentaAux) THEN
					SELECT cuenta INTO vcCuentaOrdenante FROM bdicheq:"informix".sc_maechq WHERE num_cte = pCliente AND cuenta = (SELECT cuenta FROM bdicheq:"informix".sc_tarjeta WHERE numcte = pCliente AND num_tarjeta = vcCuentaAux);
				END IF;
			ELSE
				LET vcCuentaOrdenante = '';
			END IF;
			
			LET vcFechaAux = SUBSTRING(vcFechaSolicitud FROM 5 FOR 2) ||'/' ||SUBSTRING(vcFechaSolicitud FROM 7 FOR 2)||'/'||SUBSTRING(vcFechaSolicitud FROM 1 FOR 4);
			LET vdFechasol = vcFechaAux::DATE;

			LET cCiclo = cCiclo + 1;
			IF cCiclo <= pNumRegistros THEN
				CONTINUE FOREACH;
			END IF;
			
			RETURN cCodRet,vdFechasol,vcClaveSentido,NVL(vcCuentaOrdenante,''),vcfolioSolicitud,vcEstatusSolicitud WITH RESUME;
			
		END FOREACH;
	END;
END PROCEDURE;
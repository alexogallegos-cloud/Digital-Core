CREATE PROCEDURE "informix".sp_rep_osteldetalle(pcOpcion CHAR(2),pcProd CHAR(7),pcNumBusqueda CHAR(4),pdFechaini DATE,pdFechaFin DATE,pcEmpresa CHAR(3))
RETURNING CHAR(6),CHAR(20),INTEGER,CHAR(1),INTEGER,CHAR(1),CHAR(2),CHAR(2),CHAR(2),CHAR(2),CHAR(2),CHAR(2),CHAR(2),CHAR(2),
CHAR(2),CHAR(2),DATE,DATE,CHAR(8),DATE,CHAR(8),CHAR(8);
--Declaracion de variables
DEFINE iSqlErr INTEGER;
DEFINE cCodRet CHAR(6);
DEFINE cNumSol CHAR(20);
DEFINE iSecuencia INTEGER;
DEFINE cRdoFinal CHAR(1);
DEFINE iTipoCd INTEGER;
DEFINE cGrupo CHAR(1);
DEFINE cResTelCasa CHAR(2);
DEFINE cResTelRef CHAR(2);
DEFINE cResTelTrab CHAR(2);
DEFINE cResTelCel CHAR(2);
DEFINE cResprc_1 CHAR(2);
DEFINE cResprct_2 CHAR(2);
DEFINE cResprrt_3 CHAR(2);
DEFINE cDecCoppel CHAR(2);
DEFINE cDecBancoppelCteNvo CHAR(2);
DEFINE cAttn15 CHAR(2);
DEFINE dFechaInsert DATE;
DEFINE dfechaIni DATE;
DEFINE cHoraini CHAR(8);
DEFINE dFechaFin DATE;
DEFINE cHoraFin CHAR(8);
DEFINE cEjecutivo CHAR(8);
DEFINE cBandera CHAR(1);
DEFINE cMensaje				  CHAR(80);
DEFINE vproceso				  CHAR (4);
define sPaso smallint;
-- Iniciacion de variables
LET iSqlErr = 0;
LET cCodRet = '000000';
LET cNumSol = '';
LET iSecuencia = 0;
LET cRdoFinal = '';
LET iTipoCd = 0;
LET cGrupo = '';
LET cResTelCasa = '';
LET cResTelRef = '';
LET cResTelTrab = '';
LET cResTelCel = '';
LET cResprc_1 = '';
LET cResprct_2 = '';
LET cResprrt_3 = '';
LET cDecCoppel = '';
LET cDecBancoppelCteNvo = '';
LET cAttn15 = '';
LET dFechaInsert = CURRENT::DATE;
LET dfechaIni = CURRENT::DATE;
LET cHoraini = '';
LET dFechaFin = CURRENT::DATE;
LET cHoraFin = '';
LET cEjecutivo = '';
LET cBandera = 'F';
LET cMensaje    = 'PROCESO EXITOSO';
LET vproceso	='2065';
LET  sPaso = 0;
BEGIN
	-- Manejador de errores
	ON EXCEPTION SET iSqlErr
		IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			CALL bdicobranza:"informix".inserta_bitacora_cob('001', vproceso, cCodRet, cMensaje, '02');
			RETURN cCodRet,cNumSol,iSecuencia,cRdoFinal,iTipoCd,cGrupo,cResTelCasa,cResTelRef,cResTelTrab,cResTelCel,
			cResprc_1,cResprct_2,cResprrt_3,cDecCoppel,cDecBancoppelCteNvo,cAttn15,dFechaInsert,dfechaIni,cHoraini,dFechaFin,
			cHoraFin,cEjecutivo;
		END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO "/tmp/sp_rep_osteldetalle.txt";
	--TRACE ON;
	CALL bdicobranza:"informix".inserta_bitacora_cob('001', vproceso, cCodRet, cMensaje, '01');
	-- Valida que los parametros sean correctos
	IF NVL(pcOpcion,'') = '' OR NVL(pcProd,'') = '' OR NVL(pcNumBusqueda,'') = '' OR NVL(pdFechaini,'') = '' OR NVL(pdFechaFin,'') = '' OR NVL(pcEmpresa,'') = '' THEN
		LET cCodRet = '000001';
	ELIF pcOpcion NOT IN ('01','02','03','04','05') THEN
		LET cCodRet = '000002';
	END IF;
	IF cCodRet = '000000' THEN
		
		--DELETE FROM bdisolic:"informix".tme_soldetalle;
		--DELETE FROM bdisolic:"informix".tme_reposteldetalle;
	SELECT COUNT(tabid)INTO sPaso FROM systables WHERE tabname= 'tme_soldetalle';
            IF NVL(sPaso,0) > 0 THEN
                DROP TABLE tme_soldetalle;
            END IF;
	
	CREATE TABLE bdisolic:"informix".tme_soldetalle
	(
	num_solicitud CHAR(20),
	secuencia INTEGER,
	resultadofinal CHAR(1),
	tipociudad INTEGER,
	grupo CHAR(1),
	restelcasa CHAR(2),
	restelref CHAR(2),
	resteltrab CHAR(2),
	restelcel CHAR(2),
	resprc_1 CHAR(2),
	resprct_2 CHAR(2),
	resprrt_3 CHAR(2),
	deccoppel CHAR(2),
	decbancoppelctenvo CHAR(2),
	attn15 CHAR(2),
	fechainsert DATE,
	fechaini DATE,
	horaini CHAR(8),
	fechafin DATE,
	horafin CHAR(8),
	ejecutivo CHAR(8),
	sucursal CHAR(4),
	estado CHAR(2),
	ciudad SMALLINT,
	region SMALLINT
	);
	  LET  sPaso = 0;
	  SELECT COUNT(tabid)INTO sPaso FROM systables WHERE tabname= 'tme_reposteldetalle';
            IF NVL(sPaso,0) > 0 THEN
                DROP TABLE tme_reposteldetalle;
            END IF;
	CREATE TABLE bdisolic:"informix".tme_reposteldetalle
	(
	num_solicitud CHAR(20),
	secuencia INTEGER,
	resultadofinal CHAR(1),
	tipociudad INTEGER,
	grupo CHAR(1),
	restelcasa CHAR(2),
	restelref CHAR(2),
	resteltrab CHAR(2),
	restelcel CHAR(2),
	resprc_1 CHAR(2),
	resprct_2 CHAR(2),
	resprrt_3 CHAR(2),
	deccoppel CHAR(2),
	decbancoppelctenvo CHAR(2),
	attn15 CHAR(2),
	fechainsert DATE,
	fechaini DATE,
	horaini CHAR(8),
	fechafin DATE,
	horafin CHAR(8),
	ejecutivo CHAR(8)
	);
        begin;
	CREATE INDEX idx_tme_soldetalle ON "informix".tme_soldetalle(estado) FILLFACTOR 75 ONLINE;
        commit;
        begin;
	CREATE INDEX idx_tme_soldetalle_2 ON "informix".tme_soldetalle(ciudad) FILLFACTOR 75 ONLINE;
        commit;
        begin;
	CREATE INDEX idx_tme_soldetalle_3 ON "informix".tme_soldetalle(region) FILLFACTOR 75 ONLINE;
        commit;
        begin;
	CREATE INDEX idx_tme_soldetalle_4 ON "informix".tme_soldetalle(sucursal) FILLFACTOR 75 ONLINE;
        commit;
        begin;
	CREATE INDEX idx_tme_reposteldetalle ON "informix".tme_reposteldetalle(num_solicitud) FILLFACTOR 75 ONLINE;
        commit;
        update statistics medium for table tme_soldetalle;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		--Se obtienen las solocitudes aprobadas, a supervisar y en proceso de atencion
		INSERT INTO bdisolic:"informix".tme_soldetalle(num_solicitud,secuencia,resultadofinal,tipociudad,grupo,restelcasa,restelref,resteltrab,
		restelcel,resprc_1,resprct_2,resprrt_3,deccoppel,decbancoppelctenvo,attn15,fechainsert,fechaini,horaini,fechafin,horafin,
		ejecutivo,sucursal,estado,ciudad,region)
		SELECT sol.num_solicitud, rdo.Secuencia,refsol.resultadofinal,rdo.TipoCiudad,
		(CASE WHEN scorfin.meses_historia > 12 AND scorfin.situacion_pago >= 85 THEN 1
			WHEN scorfin.meses_historia BETWEEN 6 AND 12 THEN 2
			WHEN scorfin.meses_historia BETWEEN 0 AND 5 AND (scorfin.situacion_pago = -1 OR scorfin.situacion_pago >= 85) THEN 3
			WHEN scorfin.meses_historia > 12 AND scorfin.situacion_pago < 85 THEN 4
			WHEN scorfin.meses_historia = 0 THEN 5 END),rdo.ResultadoTelefonoCasa,rdo.ResultadoTelefonoref,
		rdo.ResultadoTelefonotrab,rdo.ResultadoTelefonoCelular,rdo.ResultadoPrC_1,rdo.ResultadoPrCT_2,rdo.ResultadoPrRT_3,
		rdo.DecCoppel,rdo.decbancoppelctenuevo,rdo.Atendido_15min,sol.fecha_insert,DATE(rdo.FechaHoraInicio),
		TO_CHAR(rdo.FechaHoraInicio,'%H:%M:%S'),DATE(rdo.FechaHoraFin),TO_CHAR(rdo.FechaHoraFin,'%H:%M:%S'),rdo.ejecutivo,
		sol.sucursal,cd.estado,cd.ciudad,catcd.numero_region
		FROM bdisolic:"informix".ss_solicitudes sol,bdisolic:"informix".ss_ostelrefsolicitud refsol,
		bdisolic:"informix".ss_resum_scor_fin scorfin,bdisolic:"informix".ss_ostel_resultado rdo,
		bdinteg:"informix".si_ciudades cd,bdinteg:"informix".si_sucursales suc,bdinteg:"informix".si_regiones reg,
		bdinteg:"informix".si_catciudades catcd
		WHERE sol.empresa = pcEmpresa
		AND sol.empresa= scorfin.empresa
		AND sol.num_solicitud = scorfin.num_solicitud
		AND sol.num_solicitud = refsol.num_solicitud
		AND refsol.secuenciaostel = rdo.secuencia
		AND sol.sucursal = suc.sucursal
		AND suc.ciudad = cd.ciudad
		AND suc.estado = cd.estado
		AND cd.ciudad_coppel = catcd.numerociudad
		AND catcd.numero_region = reg.numero_region
		AND sol.fecha_insert BETWEEN pdFechaini AND pdFechaFin
		AND sol.num_producto = pcProd
		GROUP BY sol.num_solicitud,rdo.Secuencia,refsol.resultadofinal,rdo.TipoCiudad,scorfin.meses_historia,
		scorfin.situacion_pago,rdo.ResultadoTelefonoCasa,rdo.ResultadoTelefonoref,rdo.ResultadoTelefonotrab,
		rdo.ResultadoTelefonoCelular,rdo.ResultadoPrC_1,rdo.ResultadoPrCT_2,rdo.ResultadoPrRT_3,rdo.DecCoppel,
		rdo.decbancoppelctenuevo,rdo.Atendido_15min,sol.fecha_insert,rdo.FechaHoraInicio,rdo.FechaHoraInicio,rdo.FechaHoraFin,
		rdo.FechaHoraFin,rdo.ejecutivo,sol.sucursal,cd.estado,cd.ciudad,catcd.numero_region;
		
		IF pcOpcion = "01" THEN
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;
			INSERT INTO bdisolic:"informix".tme_reposteldetalle(num_solicitud,secuencia,resultadofinal,tipociudad,grupo,restelcasa,restelref,
			resteltrab,restelcel,resprc_1,resprct_2,resprrt_3,deccoppel,decbancoppelctenvo,attn15,fechainsert,fechaini,horaini,
			fechafin,horafin,ejecutivo)
			SELECT num_solicitud,secuencia,resultadofinal,tipociudad,grupo,restelcasa,restelref,resteltrab,restelcel,resprc_1,
			resprct_2,resprrt_3,deccoppel,decbancoppelctenvo,attn15,fechainsert,fechaini,horaini,fechafin,horafin,ejecutivo
			FROM bdisolic:"informix".tme_soldetalle
			WHERE estado = pcNumBusqueda;
		ELIF pcOpcion = "02" THEN
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;
			INSERT INTO bdisolic:"informix".tme_reposteldetalle(num_solicitud,secuencia,resultadofinal,tipociudad,grupo,restelcasa,restelref,
			resteltrab,restelcel,resprc_1,resprct_2,resprrt_3,deccoppel,decbancoppelctenvo,attn15,fechainsert,fechaini,horaini,
			fechafin,horafin,ejecutivo)
			SELECT num_solicitud,secuencia,resultadofinal,tipociudad,grupo,restelcasa,restelref,resteltrab,restelcel,resprc_1,
			resprct_2,resprrt_3,deccoppel,decbancoppelctenvo,attn15,fechainsert,fechaini,horaini,fechafin,horafin,ejecutivo
			FROM bdisolic:"informix".tme_soldetalle
			WHERE ciudad = pcNumBusqueda;
		ELIF pcOpcion = "03" THEN
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;
			INSERT INTO bdisolic:"informix".tme_reposteldetalle(num_solicitud,secuencia,resultadofinal,tipociudad,grupo,restelcasa,restelref,
			resteltrab,restelcel,resprc_1,resprct_2,resprrt_3,deccoppel,decbancoppelctenvo,attn15,fechainsert,fechaini,horaini,
			fechafin,horafin,ejecutivo)
			SELECT num_solicitud,secuencia,resultadofinal,tipociudad,grupo,restelcasa,restelref,resteltrab,restelcel,resprc_1,
			resprct_2,resprrt_3,deccoppel,decbancoppelctenvo,attn15,fechainsert,fechaini,horaini,fechafin,horafin,ejecutivo
			FROM bdisolic:"informix".tme_soldetalle
			WHERE region = pcNumBusqueda;
		ELIF pcOpcion = "04" THEN
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;
			INSERT INTO bdisolic:"informix".tme_reposteldetalle(num_solicitud,secuencia,resultadofinal,tipociudad,grupo,restelcasa,restelref,
			resteltrab,restelcel,resprc_1,resprct_2,resprrt_3,deccoppel,decbancoppelctenvo,attn15,fechainsert,fechaini,horaini,
			fechafin,horafin,ejecutivo)
			SELECT num_solicitud,secuencia,resultadofinal,tipociudad,grupo,restelcasa,restelref,resteltrab,restelcel,resprc_1,
			resprct_2,resprrt_3,deccoppel,decbancoppelctenvo,attn15,fechainsert,fechaini,horaini,fechafin,horafin,ejecutivo
			FROM bdisolic:"informix".tme_soldetalle
			WHERE sucursal = pcNumBusqueda;
		ELIF pcOpcion = "05" THEN
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;
			INSERT INTO bdisolic:"informix".tme_reposteldetalle(num_solicitud,secuencia,resultadofinal,tipociudad,grupo,restelcasa,restelref,
			resteltrab,restelcel,resprc_1,resprct_2,resprrt_3,deccoppel,decbancoppelctenvo,attn15,fechainsert,fechaini,horaini,
			fechafin,horafin,ejecutivo)
			SELECT {+INDEX("informix".tme_soldetalle idx_tme_soldetalle_6)} num_solicitud,secuencia,resultadofinal,tipociudad,grupo,restelcasa,restelref,resteltrab,restelcel,resprc_1,
			resprct_2,resprrt_3,deccoppel,decbancoppelctenvo,attn15,fechainsert,fechaini,horaini,fechafin,horafin,ejecutivo
			FROM bdisolic:"informix".tme_soldetalle
			WHERE num_solicitud <> '';
		END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		FOREACH

			SELECT {+INDEX("informix".tme_reposteldetalle idx_tme_reposteldetalle)} num_solicitud,secuencia,resultadofinal,
			tipociudad,NVL(grupo,''),restelcasa,restelref,resteltrab,restelcel,resprc_1,resprct_2,resprrt_3,deccoppel,
			decbancoppelctenvo,attn15,fechainsert,fechaini,horaini,fechafin,horafin,ejecutivo
			INTO cNumSol,iSecuencia,cRdoFinal,iTipoCd,cGrupo,cResTelCasa,cResTelRef,cResTelTrab,cResTelCel,
			cResprc_1,cResprct_2,cResprrt_3,cDecCoppel,cDecBancoppelCteNvo,cAttn15,dFechaInsert,dfechaIni,cHoraini,dFechaFin,
			cHoraFin,cEjecutivo
			FROM bdisolic:"informix".tme_reposteldetalle
			WHERE num_solicitud <> ''
			LET cBandera = 'V';
			--CALL bdicobranza:"informix".inserta_bitacora_cob('001', vproceso, cCodRet, cMensaje, '03');
			RETURN cCodRet,cNumSol,iSecuencia,cRdoFinal,iTipoCd,cGrupo,cResTelCasa,cResTelRef,cResTelTrab,cResTelCel,
			cResprc_1,cResprct_2,cResprrt_3,cDecCoppel,cDecBancoppelCteNvo,cAttn15,dFechaInsert,dfechaIni,cHoraini,dFechaFin,
			cHoraFin,cEjecutivo WITH RESUME;
		END FOREACH;
		--Se elimina informacion de tablas temporales
		DELETE FROM bdisolic:"informix".tme_soldetalle;
		DELETE FROM bdisolic:"informix".tme_reposteldetalle;
	END IF;
	IF cBandera = 'F' THEN
	--CALL bdicobranza:"informix".inserta_bitacora_cob('001', vproceso, cCodRet, cMensaje, '03');
		RETURN cCodRet,cNumSol,iSecuencia,cRdoFinal,iTipoCd,cGrupo,cResTelCasa,cResTelRef,cResTelTrab,cResTelCel,
			cResprc_1,cResprct_2,cResprrt_3,cDecCoppel,cDecBancoppelCteNvo,cAttn15,dFechaInsert,dfechaIni,cHoraini,dFechaFin,
			cHoraFin,cEjecutivo;
	END IF;
	CALL bdicobranza:"informix".inserta_bitacora_cob('001', vproceso, cCodRet, cMensaje, '03');
--	DROP TABLE bdisolic:"informix".tme_soldetalle;
--	drop table bdisolic:"informix".tme_reposteldetalle;
	/*
	drop INDEX idx_tme_soldetalle ;
	drop INDEX idx_tme_soldetalle_2 ;
	drop INDEX idx_tme_soldetalle_3 ;
	drop INDEX idx_tme_soldetalle_4 ;
	drop INDEX idx_tme_reposteldetalle ;*/
END
END PROCEDURE

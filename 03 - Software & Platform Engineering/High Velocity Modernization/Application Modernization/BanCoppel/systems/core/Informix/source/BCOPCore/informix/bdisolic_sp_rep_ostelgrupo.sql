CREATE PROCEDURE "informix".sp_rep_ostelgrupo(pcOpcion CHAR(2),pcProd CHAR(7),pcNumBusqueda CHAR(4),pdFechaini DATE,pdFechaFin DATE,pcEmpresa CHAR(3))
RETURNING CHAR(6) AS cCodRet,INTEGER AS iGrupo,CHAR(1) AS cTipo,INTEGER AS iTotalExisteCof,INTEGER AS iTotalValida,INTEGER AS iTotalInvalida,INTEGER AS iTotalTelInc,INTEGER AS iTotalFax,INTEGER AS iTotalTelNoExiste,INTEGER AS iTotalSinMarcar,INTEGER AS iTotalPend,INTEGER AS iTotalNoExisteCof,INTEGER AS iTotalNoTel,INTEGER AS iTotal,DECIMAL(18,2) AS dPorcExisteCof,DECIMAL(18,2) AS dPorcValida,DECIMAL(18,2) AS dPorcInvalida,DECIMAL(18,2) AS dPorcTelInc,DECIMAL(18,2) AS dPorcFax,DECIMAL(18,2) AS dPorcTelNoExiste,DECIMAL(18,2) AS dPorcSinMarcar,DECIMAL(18,2) AS dPorcPend,DECIMAL(18,2) AS dPorcNoExisteCof,DECIMAL(18,2) AS dPorcNoTel,DECIMAL(18,2) AS dPorcTotal;
--Declaracion de variables
DEFINE iSqlErr INTEGER;
DEFINE cCodRet CHAR(6);
DEFINE iGrupo INTEGER;
DEFINE cTipo CHAR(1);
DEFINE iTotal INTEGER;
DEFINE dPorcTotal DECIMAL(18,2);
DEFINE iTotalExisteCof INTEGER;
DEFINE dPorcExisteCof DECIMAL(18,2);
DEFINE iTotalNoExisteCof INTEGER;
DEFINE dPorcNoExisteCof DECIMAL(18,2);
DEFINE iTotalNoTel INTEGER;
DEFINE dPorcNoTel DECIMAL(18,2);
DEFINE iTotalValida INTEGER;
DEFINE dPorcValida DECIMAL(18,2);
DEFINE iTotalInvalida INTEGER;
DEFINE dPorcInvalida DECIMAL(18,2);
DEFINE iTotalSinMarcar INTEGER;
DEFINE dPorcSinMarcar DECIMAL(18,2);
DEFINE iTotalPend INTEGER;
DEFINE dPorcPend DECIMAL(18,2);
DEFINE iTotalTelInc INTEGER;
DEFINE dPorcTelInc DECIMAL(18,2);
DEFINE iTotalFax INTEGER;
DEFINE dPorcFax DECIMAL(18,2);
DEFINE iTotalTelNoExiste INTEGER;
DEFINE dPorcTelNoExiste DECIMAL(18,2);
DEFINE cBandera CHAR(1);
DEFINE cMensaje				  CHAR(80);
DEFINE vproceso				  CHAR (4);
define sPaso smallint;
-- Iniciacion de variables
LET iSqlErr = 0;
LET cCodRet = '000000';
LET iGrupo = 0;
LET cTipo = '1';
LET iTotal = 0;
LET dPorcTotal = 0;
LET iTotalExisteCof = 0;
LET dPorcExisteCof = 0;
LET iTotalNoExisteCof = 0;
LET dPorcNoExisteCof = 0;
LET iTotalNoTel = 0;
LET dPorcNoTel = 0;
LET iTotalValida = 0;
LET dPorcValida = 0;
LET iTotalInvalida = 0;
LET dPorcInvalida = 0;
LET iTotalSinMarcar = 0;
LET dPorcSinMarcar = 0;
LET iTotalPend = 0;
LET dPorcPend = 0;
LET iTotalTelInc = 0;
LET dPorcTelInc = 0;
LET iTotalFax = 0;
LET dPorcFax = 0;
LET iTotalTelNoExiste = 0;
LET dPorcTelNoExiste = 0;
LET cBandera = 'F';
LET cMensaje    = 'PROCESO EXITOSO';
LET vproceso	='2067';
let sPaso = 0;
BEGIN
	-- Manejador de errores
	ON EXCEPTION SET iSqlErr
		IF iSqlErr != 0 THEN
			LET cCodRet= iSqlErr;
			CALL bdicobranza:"informix".inserta_bitacora_cob('001', vproceso, cCodRet, cMensaje, '02');
			RETURN cCodRet,iGrupo,cTipo,iTotalExisteCof,iTotalValida,iTotalInvalida,iTotalTelInc,iTotalFax,iTotalTelNoExiste,iTotalSinMarcar,iTotalPend,iTotalNoExisteCof,iTotalNoTel,iTotal,dPorcExisteCof,dPorcValida,dPorcInvalida,dPorcTelInc,dPorcFax,dPorcTelNoExiste,dPorcSinMarcar,dPorcPend,dPorcNoExisteCof,dPorcNoTel,dPorcTotal;
		END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO "/tmp/marcoscuevas/sp_rep_ostelgrupo.txt";
	--TRACE ON;
CALL bdicobranza:"informix".inserta_bitacora_cob('001', vproceso, cCodRet, cMensaje, '01');
	-- Valida que los parametros sean correctos
	IF NVL(pcOpcion,'') = '' OR NVL(pcProd,'') = '' OR NVL(pcNumBusqueda,'') = '' OR NVL(pdFechaini,'') = '' OR NVL(pdFechaFin,'') = '' OR NVL(pcEmpresa,'') = '' THEN
		LET cCodRet = '000001';
	ELIF pcOpcion NOT IN ('01','02','03','04','05') THEN
		LET cCodRet = '000002';
	END IF;
	IF cCodRet = '000000' THEN
		--DELETE FROM bdisolic:"informix".tme_solgrupo;
		--DELETE FROM bdisolic:"informix".tme_solgrupo2;
		--DELETE FROM bdisolic:"informix".tme_solgrupo3;
		--DELETE FROM bdisolic:"informix".tme_repostelgpo;
	
	  SELECT COUNT(tabid)INTO sPaso FROM systables WHERE tabname= 'tme_solgrupo';
            IF NVL(sPaso,0) > 0 THEN
                DROP TABLE tme_solgrupo;
            END IF;
	CREATE TABLE bdisolic:"informix".tme_solgrupo
	(
	num_solicitud CHAR(20),
	resultadotelcasa CHAR(2),
	causatelcasa CHAR(1),
	resultadotelref CHAR(2),
	causatelref CHAR(1),
	resultadoteltrab CHAR(2),
	causateltrab CHAR(1),
	resultadotelcel CHAR(2),
	causatelcel CHAR(1),
	sucursal CHAR(4),
	tipo CHAR(1),
	grupo CHAR(1),
	tipotel CHAR(1)
	);
	 LET  sPaso = 0;
	  SELECT COUNT(tabid)INTO sPaso FROM systables WHERE tabname= 'tme_solgrupo2';
            IF NVL(sPaso,0) > 0 THEN
                DROP TABLE tme_solgrupo2;
            END IF;
	CREATE TABLE bdisolic:"informix".tme_solgrupo2
	(
	tipo CHAR(1),
	tipotel CHAR(1),
	sucursal CHAR(4),
	grupo CHAR(1)
	);
	 LET  sPaso = 0;
	  SELECT COUNT(tabid)INTO sPaso FROM systables WHERE tabname= 'tme_solgrupo3';
            IF NVL(sPaso,0) > 0 THEN
                DROP TABLE tme_solgrupo3;
            END IF;
	CREATE TABLE bdisolic:"informix".tme_solgrupo3
	(
	num_solicitud CHAR(20),
	resultadotelcasa CHAR(2),
	causatelcasa CHAR(1),
	resultadotelref CHAR(2),
	causatelref CHAR(1),
	resultadoteltrab CHAR(2),
	causateltrab CHAR(1),
	resultadotelcel CHAR(2),
	causatelcel CHAR(1),
	sucursal CHAR(4),
	grupo CHAR(1)
	);
	 LET  sPaso = 0;
	  SELECT COUNT(tabid)INTO sPaso FROM systables WHERE tabname= 'tme_repostelgpo';
            IF NVL(sPaso,0) > 0 THEN
                DROP TABLE tme_repostelgpo;
            END IF;
	CREATE TABLE bdisolic:"informix".tme_repostelgpo
	(
	grupo CHAR(1),
	tipo CHAR(1),
	canttotal INTEGER,
	porctotal DECIMAL(18,2),
	canttotalexistecof INTEGER,
	porcexistecof DECIMAL(18,2),
	canttotalnoexistecof INTEGER,
	porcnoexistecof DECIMAL(18,2),
	canttotalnotel INTEGER,
	porcnotel DECIMAL(18,2),
	canttotalvalida INTEGER,
	porcvalida DECIMAL(18,2),
	canttotalinvalida INTEGER,
	porcinvalida DECIMAL(18,2),
	canttotalsinmarcar INTEGER,
	porcsinmarcar DECIMAL(18,2),
	canttotalpend INTEGER,
	porctotalpend DECIMAL(18,2),
	canttotaltelinc INTEGER,
	porctelinc DECIMAL(18,2),
	canttotalfax INTEGER,
	porcfax DECIMAL(18,2),
	canttotaltelnoexiste INTEGER,
	porctelnoexiste DECIMAL(18,2)
	);
        begin;
	CREATE INDEX idx_tme_solgrupo ON "informix".tme_solgrupo(sucursal) FILLFACTOR 75 ONLINE;
        commit;
        begin;
	CREATE INDEX idx_tme_solgrupo2 ON "informix".tme_solgrupo2(grupo) FILLFACTOR 75 ONLINE;
        commit;
        begin;
	CREATE INDEX idx_tme_solgrupo2_2 ON "informix".tme_solgrupo2(tipotel,grupo) FILLFACTOR 75 ONLINE;
        commit;
        begin;
	CREATE INDEX idx_tme_solgrupo2_3 ON "informix".tme_solgrupo2(grupo,tipo) FILLFACTOR 75 ONLINE;
        commit;
        begin;
	CREATE INDEX idx_tme_solgrupo2_4 ON "informix".tme_solgrupo2(tipotel,grupo,tipo) FILLFACTOR 75 ONLINE;
        commit;
        begin;
	CREATE INDEX idx_tme_solgrupo3 ON "informix".tme_solgrupo3(resultadotelcasa,causatelcasa) FILLFACTOR 75 ONLINE;
        commit;
        begin;
	CREATE INDEX idx_tme_solgrupo3_2 ON "informix".tme_solgrupo3(resultadotelref,causatelref) FILLFACTOR 75 ONLINE;
        commit;
        begin;
	CREATE INDEX idx_tme_solgrupo3_3 ON "informix".tme_solgrupo3(resultadoteltrab,causateltrab) FILLFACTOR 75 ONLINE;
        commit;
        begin;
	CREATE INDEX idx_tme_solgrupo3_4 ON "informix".tme_solgrupo3(resultadotelcel,causatelcel) FILLFACTOR 75 ONLINE;
        commit;
        begin;
	CREATE INDEX idx_tme_repostelgpo ON "informix".tme_repostelgpo(grupo) FILLFACTOR 75 ONLINE;	
        commit;
        update statistics high for table tme_solgrupo;
        update statistics high for table tme_solgrupo2;
        update statistics high for table tme_solgrupo3;
        update statistics high for table tme_repostelgpo;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		--Se obtienen las solicitudes aprobadas, a supervisar y en proceso de atencion
		--DSB 2012-01-16
		INSERT INTO bdisolic:"informix".tme_solgrupo3(num_solicitud,resultadotelcasa,causatelcasa,resultadotelref,causatelref,resultadoteltrab,
		causateltrab,resultadotelcel,causatelcel,sucursal,grupo)
		SELECT sol.num_solicitud,rdo.resultadotelefonocasa,rdo.causatelefonocasa,rdo.resultadotelefonoref,rdo.causatelefonoref,
		rdo.resultadotelefonotrab,rdo.causatelefonotrab,rdo.resultadotelefonocelular,rdo.causatelefonocelular,sol.sucursal,
		SUM(CASE WHEN scorfin.meses_historia > 12 AND scorfin.situacion_pago >= 85 THEN 1
				WHEN scorfin.meses_historia BETWEEN 6 AND 12 THEN 2
				WHEN scorfin.meses_historia BETWEEN 0 AND 5 AND (scorfin.situacion_pago >= 85 OR scorfin.situacion_pago = -1)THEN 3 
		WHEN scorfin.meses_historia > 12 AND scorfin.situacion_pago <= 85 THEN 4 
		WHEN scorfin.meses_historia = 0 THEN 5 END )
		FROM bdisolic:"informix".ss_solicitudes sol,bdisolic:"informix".ss_ostelrefsolicitud refsol,
		bdisolic:"informix".ss_resum_scor_fin scorfin,bdisolic:"informix".ss_ostel_resultado rdo
		WHERE sol.empresa = pcEmpresa
		AND sol.empresa= scorfin.empresa
		AND sol.num_solicitud = scorfin.num_solicitud
		AND sol.num_solicitud = refsol.num_solicitud
		AND refsol.secuenciaostel = (SELECT MAX(refsol.secuenciaostel)
									FROM bdisolic:"informix".ss_ostelrefsolicitud refsol 
									WHERE refsol.num_solicitud = sol.num_solicitud AND num_referencia = refsol.num_referencia)
		AND refsol.secuenciaostel = rdo.secuencia
		AND refsol.num_referencia = (SELECT MAX(refsol.num_referencia) 
									FROM bdisolic:"informix".ss_ostelrefsolicitud refsol 
									WHERE refsol.num_solicitud = sol.num_solicitud)
		AND sol.fecha_insert BETWEEN pdFechaini AND pdFechaFin
		AND sol.num_producto = pcProd
		GROUP BY sol.num_solicitud,rdo.resultadotelefonocasa,rdo.causatelefonocasa,rdo.resultadotelefonoref,rdo.causatelefonoref,
		rdo.resultadotelefonotrab,rdo.causatelefonotrab,rdo.resultadotelefonocelular,rdo.causatelefonocelular,sol.sucursal;
		
		--Se obtienen las solicitudes que contienen telefono de casa
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		INSERT INTO bdisolic:"informix".tme_solgrupo(num_solicitud,resultadotelcasa,causatelcasa,resultadotelref,causatelref,resultadoteltrab,
		causateltrab,resultadotelcel,causatelcel,sucursal,tipo,grupo,tipotel)
		SELECT num_solicitud,resultadotelcasa,causatelcasa,resultadotelref,causatelref,resultadoteltrab,
		causateltrab,resultadotelcel,causatelcel,sucursal,cTipo,grupo,
		CASE WHEN (resultadotelcasa = 'V' AND causatelcasa = '1') THEN 'V'
			WHEN (resultadotelcasa = 'P' AND causatelcasa = '7') THEN 'T' 
			WHEN (resultadotelcasa = 'P' AND causatelcasa = '5') THEN 'F' 
			WHEN (resultadotelcasa = 'P' AND causatelcasa = '4') THEN 'M' 
			WHEN (resultadotelcasa = 'E' AND causatelcasa = '') THEN 'E'
			WHEN (resultadotelcasa = 'E' AND causatelcasa = '3') THEN 'P' 
			WHEN (resultadotelcasa = 'I' AND causatelcasa = '0') THEN 'I'
			WHEN (resultadotelcasa = 'N' AND causatelcasa = '') THEN 'N' END
		FROM bdisolic:"informix".tme_solgrupo3
		WHERE resultadotelcasa IN('V','P','E','I','N') 
		AND causatelcasa IN('1','7','5','4','','0','3','6');
		--Se obtienen las solicitudes que contienen telefono de referencia
		LET cTipo = '2';
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		INSERT INTO bdisolic:"informix".tme_solgrupo(num_solicitud,resultadotelcasa,causatelcasa,resultadotelref,causatelref,resultadoteltrab,
		causateltrab,resultadotelcel,causatelcel,sucursal,tipo,grupo,tipotel)
		SELECT num_solicitud,resultadotelcasa,causatelcasa,resultadotelref,causatelref,resultadoteltrab,
		causateltrab,resultadotelcel,causatelcel,sucursal,cTipo,grupo,
		CASE WHEN (resultadotelref = 'V' AND causatelref = '1') THEN 'V'
			WHEN (resultadotelref = 'P' AND causatelref = '7') THEN 'T' 
			WHEN (resultadotelref = 'P' AND causatelref = '5') THEN 'F' 
			WHEN (resultadotelref = 'P' AND causatelref = '4') THEN 'M' 
			WHEN (resultadotelref = 'E' AND causatelref = '') THEN 'E'
			WHEN (resultadotelref = 'E' AND causatelref = '3') THEN 'P' 
			WHEN (resultadotelref = 'I' AND causatelref = '0') THEN 'I'
			WHEN (resultadotelref = 'N' AND causatelref = '') THEN 'N' END
		FROM bdisolic:"informix".tme_solgrupo3
		WHERE resultadotelref IN('V','P','E','I','N')
		AND causatelref IN('1','7','5','4','','0','3','6');
		--Se obtienen las solicitudes que contienen telefono de trabajo
		LET cTipo = '3';
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		INSERT INTO bdisolic:"informix".tme_solgrupo(num_solicitud,resultadotelcasa,causatelcasa,resultadotelref,causatelref,resultadoteltrab,
		causateltrab,resultadotelcel,causatelcel,sucursal,tipo,grupo,tipotel)
		SELECT num_solicitud,resultadotelcasa,causatelcasa,resultadotelref,causatelref,resultadoteltrab,
		causateltrab,resultadotelcel,causatelcel,sucursal,cTipo,grupo,
		CASE WHEN (resultadoteltrab = 'V' AND causateltrab = '1') THEN 'V'
			WHEN (resultadoteltrab = 'P' AND causateltrab = '7') THEN 'T' 
			WHEN (resultadoteltrab = 'P' AND causateltrab = '5') THEN 'F' 
			WHEN (resultadoteltrab = 'P' AND causateltrab = '4') THEN 'M' 
			WHEN (resultadoteltrab = 'E' AND causateltrab = '') THEN 'E'
			WHEN (resultadoteltrab = 'E' AND causateltrab = '3') THEN 'P' 
			WHEN (resultadoteltrab = 'I' AND causateltrab = '0') THEN 'I'
			WHEN (resultadoteltrab = 'N' AND causateltrab = '') THEN 'N' END
		FROM bdisolic:"informix".tme_solgrupo3
		WHERE resultadoteltrab IN('V','P','E','I','N')
		AND causateltrab IN('1','7','5','4','','0','3','6');
		--Se obtienen las solicitudes que contienen telefono celular
		LET cTipo = '4';
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		INSERT INTO bdisolic:"informix".tme_solgrupo(num_solicitud,resultadotelcasa,causatelcasa,resultadotelref,causatelref,resultadoteltrab,
		causateltrab,resultadotelcel,causatelcel,sucursal,tipo,grupo,tipotel)
		SELECT num_solicitud,resultadotelcasa,causatelcasa,resultadotelref,causatelref,resultadoteltrab,
		causateltrab,resultadotelcel,causatelcel,sucursal,cTipo,grupo,
		CASE WHEN (resultadotelcel = 'V' AND causatelcel = '1') THEN 'V'
			WHEN (resultadotelcel = 'P' AND causatelcel = '7') THEN 'T' 
			WHEN (resultadotelcel = 'P' AND causatelcel = '5') THEN 'F' 
			WHEN (resultadotelcel = 'P' AND causatelcel = '4') THEN 'M' 
			WHEN (resultadotelcel = 'E' AND causatelcel = '') THEN 'E'
			WHEN (resultadotelcel = 'E' AND causatelcel = '3') THEN 'P' 
			WHEN (resultadotelcel = 'I' AND causatelcel = '0') THEN 'I'
			WHEN (resultadotelcel = 'N' AND causatelcel = '') THEN 'N' END
		FROM bdisolic:"informix".tme_solgrupo3
		WHERE resultadotelcel IN('V','P','E','I','N')
		AND causatelcel IN('1','7','5','4','','0','3','6');
		
		--dsb 22/02/2012
		DELETE FROM tme_solgrupo WHERE tipotel IS NULL;
		
		IF pcOpcion = "01" THEN
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;
			INSERT INTO bdisolic:"informix".tme_solgrupo2(tipo,tipotel,sucursal,grupo)
			SELECT tmegpo.tipo,tmegpo.tipotel,tmegpo.sucursal,tmegpo.grupo
			FROM bdinteg:"informix".si_ciudades cd,bdinteg:"informix".si_sucursales suc,bdisolic:"informix".tme_solgrupo tmegpo
			WHERE tmegpo.sucursal = suc.sucursal 
			AND cd.estado = suc.estado 
			AND cd.ciudad = suc.ciudad
			AND suc.estado = pcNumBusqueda;
		ELIF pcOpcion = "02" THEN
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;
			INSERT INTO bdisolic:"informix".tme_solgrupo2(tipo,tipotel,sucursal,grupo)
			SELECT tmegpo.tipo,tmegpo.tipotel,tmegpo.sucursal,tmegpo.grupo
			FROM bdinteg:"informix".si_ciudades cd,bdinteg:"informix".si_sucursales suc,bdisolic:"informix".tme_solgrupo tmegpo
			WHERE tmegpo.sucursal = suc.sucursal 
			AND cd.estado = suc.estado 
			AND cd.ciudad = suc.ciudad
			AND suc.ciudad = pcNumBusqueda;
		ELIF pcOpcion = "03" THEN
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;
			INSERT INTO bdisolic:"informix".tme_solgrupo2(tipo,tipotel,sucursal,grupo)
			SELECT tmegpo.tipo,tmegpo.tipotel,tmegpo.sucursal,tmegpo.grupo
			FROM bdinteg:"informix".si_ciudades cd,bdinteg:"informix".si_sucursales suc,bdinteg:"informix".si_regiones reg,
			bdinteg:"informix".si_catciudades catcdd,bdisolic:"informix".tme_solgrupo tmegpo
			WHERE tmegpo.sucursal = suc.sucursal AND suc.estado = cd.estado AND cd.ciudad_coppel = catcdd.numerociudad
			AND catcdd.numero_region = reg.numero_region AND reg.numero_region = pcNumBusqueda;
		ELIF pcOpcion = "04" THEN
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;
			INSERT INTO bdisolic:"informix".tme_solgrupo2(tipo,tipotel,sucursal,grupo)
			SELECT tmegpo.tipo,tmegpo.tipotel,tmegpo.sucursal,tmegpo.grupo
			FROM bdinteg:"informix".si_ciudades cd,bdinteg:"informix".si_sucursales suc,bdisolic:"informix".tme_solgrupo tmegpo
			WHERE tmegpo.sucursal = suc.sucursal 
			AND cd.estado = suc.estado 
			AND cd.ciudad = suc.ciudad
			AND suc.sucursal = pcNumBusqueda;
		ELIF pcOpcion = "05" THEN
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;
			INSERT INTO bdisolic:"informix".tme_solgrupo2(tipo,tipotel,sucursal,grupo)
			SELECT tmegpo.tipo,tmegpo.tipotel,tmegpo.sucursal,tmegpo.grupo
			FROM bdinteg:"informix".si_ciudades cd,bdinteg:"informix".si_sucursales suc,bdisolic:"informix".tme_solgrupo tmegpo
			WHERE tmegpo.sucursal = suc.sucursal 
			AND cd.estado = suc.estado 
			AND cd.ciudad = suc.ciudad
			AND tmegpo.grupo != 6;
		END IF;
		LET cTipo = '0';
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		FOREACH
			SELECT grupo INTO iGrupo FROM bdisolic:"informix".tme_solgrupo2 GROUP BY grupo
			--Se obtiene el total de llamadas por grupo
			SELECT {+INDEX("informix".tme_solgrupo2 idx_tme_solgrupo2)} COUNT(tipo) INTO iTotal FROM bdisolic:"informix".tme_solgrupo2 
			WHERE grupo = iGrupo;
			--Se obtiene el total de llamadas existentes por cofetel por grupo
			SELECT {+INDEX("informix".tme_solgrupo2 idx_tme_solgrupo2_2)} COUNT(tipo) INTO iTotalExisteCof FROM bdisolic:"informix".tme_solgrupo2 
			WHERE tipotel IN('V','T','F','M','E','P') AND grupo = iGrupo;
			--Se obtiene el total de llamadas validas por grupo
			SELECT {+INDEX("informix".tme_solgrupo2 idx_tme_solgrupo2_2)} COUNT(tipo) INTO iTotalValida FROM bdisolic:"informix".tme_solgrupo2 
			WHERE tipotel = 'V' AND grupo = iGrupo;
			--Se obtiene el total de llamadas invalidas por grupo
			SELECT {+INDEX("informix".tme_solgrupo2 idx_tme_solgrupo2_2)} COUNT(tipo) INTO iTotalInvalida FROM bdisolic:"informix".tme_solgrupo2 
			WHERE tipotel IN('T','F','M') AND grupo = iGrupo;
			--Se calcula el total de llamadas invalidas de telefono invalido por grupo
			SELECT {+INDEX("informix".tme_solgrupo2 idx_tme_solgrupo2_2)} COUNT(tipo) INTO iTotalTelInc FROM bdisolic:"informix".tme_solgrupo2 
			WHERE tipotel = 'T' AND grupo = iGrupo;
			--Se calcula el total de llamadas invalidas de fax por grupo
			SELECT {+INDEX("informix".tme_solgrupo2 idx_tme_solgrupo2_2)} COUNT(tipo) INTO iTotalFax FROM bdisolic:"informix".tme_solgrupo2 
			WHERE tipotel = 'F' AND grupo = iGrupo;
			--Se calcula el total de llamadas invalidas de no existe al marcar por grupo
			SELECT {+INDEX("informix".tme_solgrupo2 idx_tme_solgrupo2_2)} COUNT(tipo) INTO iTotalTelNoExiste FROM bdisolic:"informix".tme_solgrupo2 
			WHERE tipotel = 'M' AND grupo = iGrupo;
			--Se calcula el total de llamadas existentes sin marcar por grupo
			SELECT {+INDEX("informix".tme_solgrupo2 idx_tme_solgrupo2_2)} COUNT(tipo) INTO iTotalSinMarcar FROM bdisolic:"informix".tme_solgrupo2 
			WHERE tipotel = 'E' AND grupo = iGrupo;
			--Se calcula el total de llamadas pendientes por grupo
			SELECT {+INDEX("informix".tme_solgrupo2 idx_tme_solgrupo2_2)} COUNT(tipo) INTO iTotalPend FROM bdisolic:"informix".tme_solgrupo2 
			WHERE tipotel = 'P' AND grupo = iGrupo;
			--Se calcula el total de llamadas de no existentes por Cofetel por grupo
			SELECT {+INDEX("informix".tme_solgrupo2 idx_tme_solgrupo2_2)} COUNT(tipo) INTO iTotalNoExisteCof FROM bdisolic:"informix".tme_solgrupo2 
			WHERE tipotel = 'I' AND grupo = iGrupo;
			--Se calcula el total de llamadas que no cuentan con telefono  por grupo
			SELECT {+INDEX("informix".tme_solgrupo2 idx_tme_solgrupo2_2)} COUNT(tipo) INTO iTotalNoTel FROM bdisolic:"informix".tme_solgrupo2 
			WHERE tipotel = 'N' AND grupo = iGrupo;
			IF iTotal > 0 THEN
				--Se calculan los porcentaje de llamadas existentes por Cofetel  por grupo
				IF iTotalExisteCof > 0 THEN
					LET dPorcExisteCof = (iTotalExisteCof/iTotal) * 100;
				ELSE
					LET dPorcExisteCof = 0;
				END IF;
				--Se calculan los porcentaje de llamadas de no existentes por Cofetel por grupo
				IF iTotalNoExisteCof > 0 THEN
					LET dPorcNoExisteCof = (iTotalNoExisteCof/iTotal) * 100;
				ELSE
					LET dPorcNoExisteCof = 0;
				END IF;
				--Se calculan los porcentaje de llamadas de no existentes por Cofetel por grupo
				IF iTotalNoTel > 0 THEN
					LET dPorcNoTel = (iTotalNoTel/iTotal) * 100;
				ELSE
					LET dPorcNoTel = 0;
				END IF;
				--Se calculan los porcentaje de llamadas validas por grupo
				IF iTotalValida > 0 THEN
					LET dPorcValida = (iTotalValida/iTotalExisteCof) * 100;
				ELSE
					LET dPorcValida = 0;
				END IF;
				--Se calculan los porcentaje de llamadas invalidas por grupo
				IF iTotalInvalida > 0 THEN
					LET dPorcInvalida = (iTotalInvalida/iTotalExisteCof) * 100;
				ELSE
					LET dPorcInvalida = 0;
				END IF;
				--Se calculan los porcentaje de llamadas sin marcar por grupo
				IF iTotalSinMarcar > 0 THEN
					LET dPorcSinMarcar = (iTotalSinMarcar/iTotalExisteCof) * 100;
				ELSE
					LET dPorcSinMarcar = 0;
				END IF;
				--Se calculan los porcentaje de llamadas pendientes por grupo
				IF iTotalPend > 0 THEN
					LET dPorcPend = (iTotalPend/iTotalExisteCof) * 100;
				ELSE
					LET dPorcPend = 0;
				END IF;
				--Se calculan los porcentaje de llamadas invalidas por grupo
				IF iTotalTelInc > 0 THEN
					LET dPorcTelInc = (iTotalTelInc/iTotalInvalida) * 100;
				ELSE
					LET dPorcTelInc = 0;
				END IF;
				--Se calculan los porcentaje de llamadas sin marcar por grupo
				IF iTotalFax > 0 THEN
					LET dPorcFax = (iTotalFax/iTotalInvalida) * 100;
				ELSE
					--dsb 22/02/2012
					--LET iTotalFax = 0;
					LET dPorcFax = 0;
				END IF;
				--Se calculan los porcentaje de llamadas pendientes por grupo
				IF iTotalTelNoExiste > 0 THEN
					LET dPorcTelNoExiste = (iTotalTelNoExiste/iTotalInvalida) * 100;
				ELSE
					LET dPorcTelNoExiste = 0;
				END IF;
			ELSE
				--Se calculan los porcentaje de llamadas existentes por Cofetel por grupo
				LET dPorcExisteCof = 0;
				--Se calculan los porcentaje de llamadas de no existentes por Cofetel por grupo
				LET dPorcNoExisteCof = 0;
				--Se calculan los porcentaje de llamadas de no existentes por Cofetel por grupo
				LET dPorcNoTel = 0;
				--Se calculan los porcentaje de llamadas validas por grupo
				LET dPorcValida = 0;
				--Se calculan los porcentaje de llamadas invalidas por grupo
				LET dPorcInvalida = 0;
				--Se calculan los porcentaje de llamadas sin marcar por grupo
				LET dPorcSinMarcar = 0;
				--Se calculan los porcentaje de llamadas pendientes por grupo
				LET dPorcPend = 0;
				--Se calculan los porcentaje de llamadas invalidas por grupo
				LET dPorcTelInc = 0;
				--Se calculan los porcentaje de llamadas sin marcar por grupo
				LET dPorcFax = 0;
				--Se calculan los porcentaje de llamadas pendientes por grupo
				LET dPorcTelNoExiste = 0;
			END IF;
			--Se calculan los porcentaje total
			IF dPorcExisteCof = 0 AND dPorcNoExisteCof = 0 AND dPorcNoTel = 0 THEN
				LET dPorcTotal = 0;
			ELSE
				LET dPorcTotal = dPorcExisteCof + dPorcNoExisteCof + dPorcNoTel;
			END IF;
			LET cTipo = '0';
			--Se insertan totales por grupo
			INSERT INTO bdisolic:"informix".tme_repostelgpo(grupo,tipo,canttotal,porctotal,canttotalexistecof,porcexistecof,canttotalnoexistecof,
			porcnoexistecof,canttotalnotel,porcnotel,canttotalvalida,porcvalida,canttotalinvalida,porcinvalida,canttotalsinmarcar,
			porcsinmarcar,canttotalpend,porctotalpend,canttotaltelinc,porctelinc,canttotalfax,porcfax,canttotaltelnoexiste,
			porctelnoexiste)
			VALUES(iGrupo,cTipo,iTotal,dPorcTotal,iTotalExisteCof,dPorcExisteCof,iTotalNoExisteCof,dPorcNoExisteCof,iTotalNoTel,
			dPorcNoTel,iTotalValida,dPorcValida,iTotalInvalida,dPorcInvalida,iTotalSinMarcar,dPorcSinMarcar,iTotalPend,dPorcPend,
			iTotalTelInc,dPorcTelInc,iTotalFax,dPorcFax,iTotalTelNoExiste,dPorcTelNoExiste);
			--DSB 2012-01-16
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;
			FOREACH
				SELECT tipo INTO cTipo FROM bdisolic:"informix".tme_solgrupo2 GROUP BY tipo
				--Se obtiene el total de llamadas por tipo
				SELECT {+INDEX("informix".tme_solgrupo2 idx_tme_solgrupo2_3)} COUNT(tipo) INTO iTotal 
				FROM bdisolic:"informix".tme_solgrupo2 WHERE grupo = iGrupo AND tipo = cTipo;
				--Se obtiene el total de llamadas existentes por cofetel por tipo
				SELECT {+INDEX("informix".tme_solgrupo2 idx_tme_solgrupo2_4)} COUNT(tipo) INTO iTotalExisteCof FROM bdisolic:"informix".tme_solgrupo2 
				WHERE tipotel IN('V','T','F','M','E','P') AND grupo = iGrupo AND tipo = cTipo;
				--Se obtiene el total de llamadas validas por tipo
				SELECT {+INDEX("informix".tme_solgrupo2 idx_tme_solgrupo2_4)} COUNT(tipo) INTO iTotalValida FROM bdisolic:"informix".tme_solgrupo2 
				WHERE tipotel = 'V' AND grupo = iGrupo AND tipo = cTipo;
				--Se obtiene el total de llamadas invalidas por tipo
				SELECT {+INDEX("informix".tme_solgrupo2 idx_tme_solgrupo2_4)} COUNT(tipo) INTO iTotalInvalida FROM bdisolic:"informix".tme_solgrupo2 
				WHERE tipotel IN('T','F','M') AND grupo = iGrupo AND tipo = cTipo;
				--Se calcula el total de llamadas invalicas de telefono invalido por tipo
				SELECT {+INDEX("informix".tme_solgrupo2 idx_tme_solgrupo2_4)} COUNT(tipo) INTO iTotalTelInc FROM bdisolic:"informix".tme_solgrupo2 
				WHERE tipotel = 'T' AND grupo = iGrupo AND tipo = cTipo;
				--Se calcula el total de llamadas invalicas de fax por tipo
				SELECT {+INDEX("informix".tme_solgrupo2 idx_tme_solgrupo2_4)} COUNT(tipo) INTO iTotalFax FROM bdisolic:"informix".tme_solgrupo2 
				WHERE tipotel = 'F' AND grupo = iGrupo AND tipo = cTipo;
				--Se calcula el total de llamadas invalicas de no existe al marcar por tipo
				SELECT {+INDEX("informix".tme_solgrupo2 idx_tme_solgrupo2_4)} COUNT(tipo) INTO iTotalTelNoExiste FROM bdisolic:"informix".tme_solgrupo2 
				WHERE tipotel = 'M' AND grupo = iGrupo AND tipo = cTipo;
				--Se calcula el total de llamadas existentes sin marcar por tipo
				SELECT {+INDEX("informix".tme_solgrupo2 idx_tme_solgrupo2_4)} COUNT(tipo) INTO iTotalSinMarcar FROM bdisolic:"informix".tme_solgrupo2 
				WHERE tipotel = 'E' AND grupo = iGrupo AND tipo = cTipo;
				--Se calcula el total de llamadas pendientes por tipo
				SELECT {+INDEX("informix".tme_solgrupo2 idx_tme_solgrupo2_4)} COUNT(tipo) INTO iTotalPend FROM bdisolic:"informix".tme_solgrupo2 
				WHERE tipotel = 'P' AND grupo = iGrupo AND tipo = cTipo;
				--Se calcula el total de llamadas de no existentes por Cofetel por tipo 
				SELECT {+INDEX("informix".tme_solgrupo2 idx_tme_solgrupo2_4)} COUNT(tipo) INTO iTotalNoExisteCof FROM bdisolic:"informix".tme_solgrupo2 
				WHERE tipotel = 'I' AND grupo = iGrupo AND tipo = cTipo;
				--Se calcula el total de llamadas que no cuentan con telefono por tipo
				SELECT {+INDEX("informix".tme_solgrupo2 idx_tme_solgrupo2_4)} COUNT(tipo) INTO iTotalNoTel FROM bdisolic:"informix".tme_solgrupo2 
				WHERE tipotel = 'N' AND grupo = iGrupo AND tipo = cTipo;
				IF iTotal > 0 THEN
					--Se calculan los porcentaje de llamadas existentes por Cofetel por tipo
					IF iTotalExisteCof > 0 THEN
						LET dPorcExisteCof = (iTotalExisteCof/iTotal) * 100;
					ELSE
						LET dPorcExisteCof = 0;
					END IF;
					--Se calculan los porcentaje de llamadas de no existentes por Cofetel por tipo
					IF iTotalNoExisteCof > 0 THEN
						LET dPorcNoExisteCof = (iTotalNoExisteCof/iTotal) * 100;
					ELSE
						LET dPorcNoExisteCof = 0;
					END IF;
					--Se calculan los porcentaje de llamadas de no existentes por Cofetel por tipo
					IF iTotalNoTel > 0 THEN
						LET dPorcNoTel = (iTotalNoTel/iTotal) * 100;
					ELSE
						LET dPorcNoTel = 0;
					END IF;
					--Se calculan los porcentaje de llamadas validas por tipo
					IF iTotalValida > 0 THEN
						LET dPorcValida = (iTotalValida/iTotalExisteCof) * 100;
					ELSE
						LET dPorcValida = 0;
					END IF;
					--Se calculan los porcentaje de llamadas invalidas por tipo
					IF iTotalInvalida > 0 THEN
						LET dPorcInvalida = (iTotalInvalida/iTotalExisteCof) * 100;
					ELSE
						LET dPorcInvalida = 0;
					END IF;
					--Se calculan los porcentaje de llamadas sin marcar por tipo
					IF iTotalSinMarcar > 0 THEN
						LET dPorcSinMarcar = (iTotalSinMarcar/iTotalExisteCof) * 100;
					ELSE
						LET dPorcSinMarcar = 0;
					END IF;
					--Se calculan los porcentaje de llamadas pendientes por tipo
					IF iTotalPend > 0 THEN
						LET dPorcPend = (iTotalPend/iTotalExisteCof) * 100;
					ELSE
						LET dPorcPend = 0;
					END IF;
					--Se calculan los porcentaje de llamadas invalidas por tipo
					IF iTotalTelInc > 0 THEN
						LET dPorcTelInc = (iTotalTelInc/iTotalInvalida) * 100;
					ELSE
						LET dPorcTelInc = 0;
					END IF;
					--Se calculan los porcentaje de llamadas sin marcar por tipo
					IF iTotalFax > 0 THEN
						LET dPorcFax = (iTotalFax/iTotalInvalida) * 100;
					ELSE
						--dsb 22/02/2012
						--LET iTotalFax = 0;
						LET dPorcFax = 0;
					END IF;
					--Se calculan los porcentaje de llamadas pendientes por tipo
					IF iTotalTelNoExiste > 0 THEN
						LET dPorcTelNoExiste = (iTotalTelNoExiste/iTotalInvalida) * 100;
					ELSE
						LET dPorcTelNoExiste = 0;
					END IF;
				ELSE
					--Se calculan los porcentaje de llamadas existentes por Cofetel por tipo
					LET dPorcExisteCof = 0;
					--Se calculan los porcentaje de llamadas de no existentes por Cofetel por tipo
					LET dPorcNoExisteCof = 0;
					--Se calculan los porcentaje de llamadas de no existentes por Cofetel por tipo
					LET dPorcNoTel = 0;
					--Se calculan los porcentaje de llamadas validas por tipo
					LET dPorcValida = 0;
					--Se calculan los porcentaje de llamadas invalidas por tipo
					LET dPorcInvalida = 0;
					--Se calculan los porcentaje de llamadas sin marcar por tipo
					LET dPorcSinMarcar = 0;
					--Se calculan los porcentaje de llamadas pendientes por tipo
					LET dPorcPend = 0;
					--Se calculan los porcentaje de llamadas invalidas por tipo
					LET dPorcTelInc = 0;
					--Se calculan los porcentaje de llamadas sin marcar por tipo
					LET dPorcFax = 0;
					--Se calculan los porcentaje de llamadas pendientes por tipo
					LET dPorcTelNoExiste = 0;
				END IF;
				--Se calculan los porcentaje total
				IF dPorcExisteCof = 0 AND dPorcNoExisteCof = 0 AND dPorcNoTel = 0 THEN
					LET dPorcTotal = 0;
				ELSE
					LET dPorcTotal = dPorcExisteCof + dPorcNoExisteCof + dPorcNoTel;
				END IF;
				--Se insertan totales por grupo
				INSERT INTO bdisolic:"informix".tme_repostelgpo(grupo,tipo,canttotal,porctotal,canttotalexistecof,porcexistecof,canttotalnoexistecof,
				porcnoexistecof,canttotalnotel,porcnotel,canttotalvalida,porcvalida,canttotalinvalida,porcinvalida,canttotalsinmarcar,
				porcsinmarcar,canttotalpend,porctotalpend,canttotaltelinc,porctelinc,canttotalfax,porcfax,canttotaltelnoexiste,
				porctelnoexiste)
				VALUES(iGrupo,cTipo,iTotal,dPorcTotal,iTotalExisteCof,dPorcExisteCof,iTotalNoExisteCof,dPorcNoExisteCof,iTotalNoTel,
				dPorcNoTel,iTotalValida,dPorcValida,iTotalInvalida,dPorcInvalida,iTotalSinMarcar,dPorcSinMarcar,iTotalPend,dPorcPend,
				iTotalTelInc,dPorcTelInc,iTotalFax,dPorcFax,iTotalTelNoExiste,dPorcTelNoExiste);
			END FOREACH;
		END FOREACH;
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		FOREACH
			--2012-01-02 se obliga a que utilice el index para bajar costos
			SELECT {+INDEX("informix".tme_repostelgpo idx_tme_repostelgpo)} NVL(grupo,''),tipo,canttotal,porctotal,canttotalexistecof,porcexistecof,canttotalnoexistecof,porcnoexistecof,
			canttotalnotel,porcnotel,canttotalvalida,porcvalida,canttotalinvalida,porcinvalida,canttotalsinmarcar,porcsinmarcar,
			canttotalpend,porctotalpend,canttotaltelinc,porctelinc,canttotalfax,porcfax,canttotaltelnoexiste,porctelnoexiste
			INTO iGrupo,cTipo,iTotal,dPorcTotal,iTotalExisteCof,dPorcExisteCof,iTotalNoExisteCof,dPorcNoExisteCof,iTotalNoTel,
			dPorcNoTel,iTotalValida,dPorcValida,iTotalInvalida,dPorcInvalida,iTotalSinMarcar,dPorcSinMarcar,iTotalPend,dPorcPend,
			iTotalTelInc,dPorcTelInc,iTotalFax,dPorcFax,iTotalTelNoExiste,dPorcTelNoExiste
			FROM bdisolic:"informix".tme_repostelgpo
			WHERE grupo <> ''
			ORDER BY grupo
			LET cBandera = 'V';
			--CALL bdicobranza:"informix".inserta_bitacora_cob('001', vproceso, cCodRet, cMensaje, '03');
			RETURN cCodRet,iGrupo,cTipo,iTotalExisteCof,iTotalValida,iTotalInvalida,iTotalTelInc,iTotalFax,iTotalTelNoExiste,iTotalSinMarcar,iTotalPend,iTotalNoExisteCof,iTotalNoTel,iTotal,dPorcExisteCof,dPorcValida,dPorcInvalida,dPorcTelInc,dPorcFax,dPorcTelNoExiste,dPorcSinMarcar,dPorcPend,dPorcNoExisteCof,dPorcNoTel,dPorcTotal WITH RESUME;
		END FOREACH;
		--Se elimina informacion de tablas temporales
		DELETE FROM bdisolic:"informix".tme_solgrupo;
		DELETE FROM bdisolic:"informix".tme_solgrupo2;
		DELETE FROM bdisolic:"informix".tme_solgrupo3;
		DELETE FROM bdisolic:"informix".tme_repostelgpo;
	END IF;
	IF cBandera = 'F' THEN
	--CALL bdicobranza:"informix".inserta_bitacora_cob('001', vproceso, cCodRet, cMensaje, '03');
		RETURN cCodRet,iGrupo,cTipo,iTotalExisteCof,iTotalValida,iTotalInvalida,iTotalTelInc,iTotalFax,iTotalTelNoExiste,iTotalSinMarcar,iTotalPend,iTotalNoExisteCof,iTotalNoTel,iTotal,dPorcExisteCof,dPorcValida,dPorcInvalida,dPorcTelInc,dPorcFax,dPorcTelNoExiste,dPorcSinMarcar,dPorcPend,dPorcNoExisteCof,dPorcNoTel,dPorcTotal;
	END IF;
	CALL bdicobranza:"informix".inserta_bitacora_cob('001', vproceso, cCodRet, cMensaje, '03');
--	drop table bdisolic:"informix".tme_solgrupo;
--	drop table bdisolic:"informix".tme_solgrupo2;
--	drop table bdisolic:"informix".tme_solgrupo3;
--	drop table bdisolic:"informix".tme_repostelgpo;
	
	/*drop INDEX idx_tme_solgrupo ;
	drop INDEX idx_tme_solgrupo2 ;
	drop INDEX idx_tme_solgrupo2_2 ;
	drop INDEX idx_tme_solgrupo2_3 ;
	drop INDEX idx_tme_solgrupo2_4 ;
	drop INDEX idx_tme_solgrupo3 ;
	drop INDEX idx_tme_solgrupo3_2 ;
	drop INDEX idx_tme_solgrupo3_3 ;
	drop INDEX idx_tme_solgrupo3_4 ;
	drop INDEX idx_tme_repostelgpo ;*/
END
END PROCEDURE

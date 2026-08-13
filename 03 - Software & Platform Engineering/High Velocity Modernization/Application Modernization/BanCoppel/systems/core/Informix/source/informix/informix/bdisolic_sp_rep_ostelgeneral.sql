CREATE PROCEDURE "informix".sp_rep_ostelgeneral(pcOpcion CHAR(2),pcProd CHAR(7),pcNumBusqueda CHAR(4),pdFechaini DATE,pdFechaFin DATE,pcEmpresa CHAR(3))
RETURNING CHAR(6) AS cCodRet,INTEGER AS iGrupo,INTEGER AS iAttnCat,INTEGER AS iSolApro,INTEGER AS iSolAproATiempo,
INTEGER AS iSolAproFTiempo,INTEGER AS iSolSup,INTEGER AS iSolSupATiempo,INTEGER AS iSolSupFTiempo,INTEGER AS iProcAttn,
INTEGER AS iTotalSol,DECIMAL(18,2) AS dPorcAttn,DECIMAL(18,2) AS dPorcAttnAprob,DECIMAL(18,2) AS dPorcAttnATiempo,
DECIMAL(18,2) AS dPorcAttnFTiempo,DECIMAL(18,2) AS dPorcAttnSup,DECIMAL(18,2) AS dPorcSolSupATiempo,
DECIMAL(18,2) AS dPorcSolSupFTiempo,DECIMAL(18,2) AS dPorcProcAttn,DECIMAL(18,2) AS dPorcTotal;
--Declaracion de variables
DEFINE iSqlErr INTEGER;
DEFINE cCodRet CHAR(6);
DEFINE iGrupo INTEGER;
DEFINE iTotalSol INTEGER;
DEFINE dPorcTotal DECIMAL(18,2);
DEFINE iAttnCat INTEGER;
DEFINE dPorcAttn DECIMAL(18,2);
DEFINE iProcAttn INTEGER;
DEFINE dPorcProcAttn DECIMAL(18,2);
DEFINE iSolApro INTEGER;
DEFINE dPorcAttnAprob DECIMAL(18,2);
DEFINE iSolSup INTEGER;
DEFINE dPorcAttnSup DECIMAL(18,2);
DEFINE iSolAproATiempo INTEGER;
DEFINE dPorcAttnATiempo DECIMAL(18,2);
DEFINE iSolAproFTiempo INTEGER;
DEFINE dPorcAttnFTiempo DECIMAL(18,2);
DEFINE iSolSupATiempo INTEGER;
DEFINE dPorcSolSupATiempo DECIMAL(18,2);
DEFINE iSolSupFTiempo INTEGER;
DEFINE dPorcSolSupFTiempo DECIMAL(18,2);
DEFINE cBandera CHAR(1);
DEFINE cMensaje				  CHAR(80);
DEFINE vproceso				  CHAR (4);
define sPaso smallint;
-- Iniciacion de variables
LET iSqlErr = 0;
LET cCodRet = '000000';
LET iGrupo = 0;
LET iTotalSol = 0;
LET dPorcTotal = 0;
LET iAttnCat = 0;
LET dPorcAttn = 0;
LET iProcAttn = 0;
LET dPorcProcAttn = 0;
LET iSolApro = 0;
LET dPorcAttnAprob = 0;
LET iSolSup = 0;
LET dPorcAttnSup = 0;
LET iSolAproATiempo = 0;
LET dPorcAttnATiempo = 0;
LET iSolAproFTiempo = 0;
LET dPorcAttnFTiempo = 0;
LET iSolSupATiempo = 0;
LET dPorcSolSupATiempo = 0;
LET iSolSupFTiempo = 0;
LET dPorcSolSupFTiempo = 0;
LET cBandera = 'F';
LET cMensaje    = 'PROCESO EXITOSO';
LET vproceso	='2066';
 LET  sPaso = 0;
BEGIN
	-- Manejador de errores
	ON EXCEPTION SET iSqlErr
		IF iSqlErr != 0 THEN
			LET cCodRet= iSqlErr;
			CALL bdicobranza:"informix".inserta_bitacora_cob('001', vproceso, cCodRet, cMensaje, '02');
			RETURN cCodRet,iGrupo,iAttnCat,iSolApro,iSolAproATiempo,iSolAproFTiempo,iSolSup,iSolSupATiempo,iSolSupFTiempo,iProcAttn,iTotalSol,
			dPorcAttn,dPorcAttnAprob,dPorcAttnATiempo,dPorcAttnFTiempo,dPorcAttnSup,dPorcSolSupATiempo,dPorcSolSupFTiempo,dPorcProcAttn,dPorcTotal;
		END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO "/tmp/sp_rep_ostelgeneral.txt";
	--TRACE ON;
CALL bdicobranza:"informix".inserta_bitacora_cob('001', vproceso, cCodRet, cMensaje, '01');
	-- Valida que los parametros sean correctos
	IF NVL(pcOpcion,'') = '' OR NVL(pcProd,'') = '' OR NVL(pcNumBusqueda,'') = '' OR NVL(pdFechaini,'') = '' OR NVL(pdFechaFin,'') = '' OR NVL(pcEmpresa,'') = '' THEN
		LET cCodRet = '000001';
	ELIF pcOpcion NOT IN ('01','02','03','04','05') THEN
		LET cCodRet = '000002';
	END IF;
	IF cCodRet = '000000' THEN
		--DELETE FROM bdisolic:"informix".tme_solicitudes;
		--DELETE FROM bdisolic:"informix".tme_solicitudes2;
		--DELETE FROM bdisolic:"informix".tme_repostelgral;

	  SELECT COUNT(tabid)INTO sPaso FROM systables WHERE tabname= 'tme_solicitudes';
            IF NVL(sPaso,0) > 0 THEN
                DROP TABLE tme_solicitudes;
            END IF;
	CREATE TABLE bdisolic:"informix".tme_solicitudes
	(
	tipo CHAR(1),
	num_solicitud CHAR(20),
	sucursal CHAR(4),
	grupo CHAR(1)
	);
	 LET  sPaso = 0;
	  SELECT COUNT(tabid)INTO sPaso FROM systables WHERE tabname= 'tme_solicitudes2';
            IF NVL(sPaso,0) > 0 THEN
                DROP TABLE tme_solicitudes2;
            END IF;
	CREATE TABLE bdisolic:"informix".tme_solicitudes2
	(
	tipo CHAR(1),
	atencioncat CHAR(20),
	grupo CHAR(1)
	);
	 LET  sPaso = 0;
	  SELECT COUNT(tabid)INTO sPaso FROM systables WHERE tabname= 'tme_repostelgral';
            IF NVL(sPaso,0) > 0 THEN
                DROP TABLE tme_repostelgral;
            END IF;
	CREATE TABLE bdisolic:"informix".tme_repostelgral
	(
	grupo CHAR(1),
	canttotal INTEGER,
	porctotal DECIMAL(18,2),
	cantattncat INTEGER,
	porcattncat DECIMAL(18,2),
	cantprocattn INTEGER,
	porcprocattn DECIMAL(18,2),
	cantattnaprob INTEGER,
	porcattnaprob DECIMAL(18,2),
	cantattnsup INTEGER,
	porcattnsup DECIMAL(18,2),
	cantsolaprobatiempo INTEGER,
	porcsolaprobatiempo DECIMAL(18,2),
	cantsolaprobftiempo INTEGER,
	porcsolaprobftiempo DECIMAL(18,2),
	cantsolsupatiempo INTEGER,
	porcsolsupatiempo DECIMAL(18,2),
	cantsolsupftiempo INTEGER,
	porcsolsupftiempo DECIMAL(18,2)
	);
        begin;
	CREATE INDEX idx_tme_solicitudes ON "informix".tme_solicitudes(sucursal) FILLFACTOR 75 ONLINE;
        commit;
        begin;
	CREATE INDEX idx_tme_solicitudes2 ON "informix".tme_solicitudes2(tipo) FILLFACTOR 75 ONLINE;
        commit;
        begin;
	CREATE INDEX idx_tme_solicitudes2_2 ON "informix".tme_solicitudes2(grupo) FILLFACTOR 75 ONLINE;
        commit;
        begin;
	CREATE INDEX idx_tme_solicitudes2_3 ON "informix".tme_solicitudes2(tipo,atencioncat) FILLFACTOR 75 ONLINE;
        commit;
        begin;
	CREATE INDEX idx_tme_solicitudes2_4 ON "informix".tme_solicitudes2(tipo,atencioncat,grupo) FILLFACTOR 75 ONLINE;
        commit;
        begin;
	CREATE INDEX idx_tme_repostelgral ON "informix".tme_repostelgral(grupo) FILLFACTOR 75 ONLINE;	
        commit;
	UPDATE STATISTICS HIGH FOR TABLE tme_solicitudes;	
	UPDATE STATISTICS HIGH FOR TABLE tme_solicitudes2;	
	UPDATE STATISTICS HIGH FOR TABLE tme_repostelgral;	
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		--Se obtienen las solocitudes aprobadas, a supervisar y en proceso de atencion
		INSERT INTO bdisolic:"informix".tme_solicitudes(tipo,num_solicitud,sucursal,grupo)
		SELECT CASE WHEN refsol.resultadofinal = 'A' AND rdo.Atendido_15min = 'S' THEN 1 
			WHEN refsol.resultadofinal = 'A' AND rdo.Atendido_15min = 'N'  THEN 2 
			WHEN refsol.resultadofinal = 'S' AND rdo.Atendido_15min = 'A' THEN 3 
			WHEN refsol.resultadofinal = 'S' AND rdo.Atendido_15min = 'S' THEN 4 
			WHEN refsol.resultadofinal = '' THEN 5 END,sol.num_solicitud,sol.sucursal,
			SUM(CASE WHEN scorfin.meses_historia > 12 AND scorfin.situacion_pago >= 85 THEN 1 
				WHEN scorfin.meses_historia BETWEEN 6 AND 12 THEN 2 
				WHEN scorfin.meses_historia BETWEEN 0 AND 5 AND (scorfin.situacion_pago >= 85 OR scorfin.situacion_pago = -1) THEN 3 
				WHEN scorfin.meses_historia > 12 AND scorfin.situacion_pago <= 85 THEN 4 
				WHEN scorfin.meses_historia = 0 THEN 5 END)
		FROM bdisolic:"informix".ss_solicitudes sol,bdisolic:"informix".ss_ostelrefsolicitud refsol,bdisolic:"informix".ss_resum_scor_fin scorfin,
			bdisolic:"informix".ss_ostel_resultado rdo,bdinteg:"informix".si_sucursales suc
		WHERE sol.empresa = pcEmpresa
		AND sol.empresa= scorfin.empresa
		AND sol.num_solicitud = scorfin.num_solicitud
		AND sol.num_solicitud = refsol.num_solicitud
		AND suc.sucursal = sol.sucursal
		AND refsol.secuenciaostel = (SELECT MAX(refsol.secuenciaostel) --DSB 2012-01-16
									FROM bdisolic:"informix".ss_ostelrefsolicitud refsol 
									WHERE refsol.num_solicitud = sol.num_solicitud AND num_referencia = refsol.num_referencia)
		AND refsol.secuenciaostel = rdo.secuencia
		AND sol.fecha_insert BETWEEN pdFechaini AND pdFechaFin
		AND refsol.num_referencia = (SELECT MAX(refsol.num_referencia) 
									FROM bdisolic:"informix".ss_ostelrefsolicitud refsol 
									WHERE refsol.num_solicitud = sol.num_solicitud)
		AND sol.num_producto = pcProd
		GROUP BY 1,sol.num_solicitud,sol.sucursal;
		
		IF pcOpcion = "01" THEN
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;
			INSERT INTO bdisolic:"informix".tme_solicitudes2(tipo,atencioncat,grupo)
			SELECT CASE WHEN tmesol.tipo IN(1,2) THEN 'A' WHEN tmesol.tipo IN(3,4) THEN 'S'
				WHEN tmesol.tipo = 5 THEN 'P' END,CASE WHEN tmesol.tipo IN(1,3) THEN 'ATTN A TIEMPO' 
				WHEN tmesol.tipo IN(2,4) THEN 'ATTN F TIEMPO' WHEN tmesol.tipo = 5 THEN 'PROC DE ATTN' END,tmesol.grupo
			FROM bdinteg:"informix".si_ciudades cd,bdinteg:"informix".si_sucursales suc,bdisolic:"informix".tme_solicitudes tmesol
			WHERE tmesol.sucursal = suc.sucursal 
			AND cd.estado = suc.estado 
			AND cd.ciudad = suc.ciudad
			AND suc.estado = pcNumBusqueda;
		ELIF pcOpcion = "02" THEN
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;
			INSERT INTO bdisolic:"informix".tme_solicitudes2(tipo,atencioncat,grupo)
			SELECT CASE WHEN tmesol.tipo IN(1,2) THEN 'A' WHEN tmesol.tipo IN(3,4) THEN 'S'
				WHEN tmesol.tipo = 5 THEN 'P' END,CASE WHEN tmesol.tipo IN(1,3) THEN 'ATTN A TIEMPO' 
				WHEN tmesol.tipo IN(2,4) THEN 'ATTN F TIEMPO' WHEN tmesol.tipo = 5 THEN 'PROC DE ATTN' END,tmesol.grupo
			FROM bdinteg:"informix".si_ciudades cd,bdinteg:"informix".si_sucursales suc,bdisolic:"informix".tme_solicitudes tmesol
			WHERE tmesol.sucursal = suc.sucursal 
			AND cd.estado = suc.estado 
			AND cd.ciudad = suc.ciudad
			AND suc.ciudad = pcNumBusqueda;
		ELIF pcOpcion = "03" THEN
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;
			INSERT INTO bdisolic:"informix".tme_solicitudes2(tipo,atencioncat,sucursal,grupo,estado,ciudad,region)
			SELECT CASE WHEN tmesol.tipo IN(1,2) THEN 'A' WHEN tmesol.tipo IN(3,4) THEN 'S'
				WHEN tmesol.tipo = 5 THEN 'P' END,CASE WHEN tmesol.tipo IN(1,3) THEN 'ATTN A TIEMPO' 
				WHEN tmesol.tipo IN(2,4) THEN 'ATTN F TIEMPO' WHEN tmesol.tipo = 5 THEN 'PROC DE ATTN' END,
				tmesol.sucursal,tmesol.grupo,cd.estado,cd.ciudad,catcdd.numero_region
			FROM bdinteg:"informix".si_ciudades cd,bdinteg:"informix".si_sucursales suc,bdinteg:"informix".si_regiones reg,
			bdinteg:"informix".si_catciudades catcdd,bdisolic:"informix".tme_solicitudes tmesol
			WHERE tmesol.sucursal = suc.sucursal AND cd.estado = suc.estado AND cd.ciudad_coppel = catcdd.numerociudad
			AND catcdd.numero_region = reg.numero_region AND reg.numero_region = pcNumBusqueda;
		ELIF pcOpcion = "04" THEN
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;
			INSERT INTO bdisolic:"informix".tme_solicitudes2(tipo,atencioncat,grupo)
			SELECT CASE WHEN tmesol.tipo IN(1,2) THEN 'A' WHEN tmesol.tipo IN(3,4) THEN 'S'
				WHEN tmesol.tipo = 5 THEN 'P' END,CASE WHEN tmesol.tipo IN(1,3) THEN 'ATTN A TIEMPO' 
				WHEN tmesol.tipo IN(2,4) THEN 'ATTN F TIEMPO' WHEN tmesol.tipo = 5 THEN 'PROC DE ATTN' END,tmesol.grupo
			FROM bdinteg:"informix".si_ciudades cd,bdinteg:"informix".si_sucursales suc,bdisolic:"informix".tme_solicitudes tmesol
			WHERE tmesol.sucursal = suc.sucursal 
			AND cd.estado = suc.estado 
			AND cd.ciudad = suc.ciudad
			AND suc.sucursal = pcNumBusqueda;
		ELIF pcOpcion = "05" THEN
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;
			INSERT INTO bdisolic:"informix".tme_solicitudes2(tipo,atencioncat,grupo)
			SELECT CASE WHEN tmesol.tipo IN(1,2) THEN 'A' WHEN tmesol.tipo IN(3,4) THEN 'S'
				WHEN tmesol.tipo = 5 THEN 'P' END,CASE WHEN tmesol.tipo IN(1,3) THEN 'ATTN A TIEMPO' 
				WHEN tmesol.tipo IN(2,4) THEN 'ATTN F TIEMPO' WHEN tmesol.tipo = 5 THEN 'PROC DE ATTN' END,tmesol.grupo
			FROM bdinteg:"informix".si_ciudades cd,bdinteg:"informix".si_sucursales suc,bdisolic:"informix".tme_solicitudes tmesol
			WHERE tmesol.sucursal = suc.sucursal 
			AND cd.estado = suc.estado 
			AND cd.ciudad = suc.ciudad;
		END IF;
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		--DSB 2012-01-16
		--Se obtiene el total de solicitudes enviadas al CAT 
		SELECT {+INDEX("informix".tme_solicitudes2 idx_tme_solicitudes2)} COUNT(tipo) INTO iTotalSol FROM bdisolic:"informix".tme_solicitudes2;
		--Se obtiene el total de solicitudes atendidas 
		SELECT {+INDEX("informix".tme_solicitudes2 idx_tme_solicitudes2)} COUNT(tipo) INTO iAttnCat FROM bdisolic:"informix".tme_solicitudes2 WHERE tipo <> 'P';
		--Se obtiene el total de solicitudes en proceso de atencion
		SELECT {+INDEX("informix".tme_solicitudes2 idx_tme_solicitudes2)} COUNT(tipo) INTO iProcAttn FROM bdisolic:"informix".tme_solicitudes2 WHERE tipo = 'P';
		--Se calculan los porcentaje de solicitudes atendidas aprobadas
		SELECT {+INDEX("informix".tme_solicitudes2 idx_tme_solicitudes2)} COUNT(tipo) INTO iSolApro FROM bdisolic:"informix".tme_solicitudes2 WHERE tipo = 'A';
		--Se calculan los porcentaje de solicitudes atendidas supervisadas
		SELECT {+INDEX("informix".tme_solicitudes2 idx_tme_solicitudes2)} COUNT(tipo) INTO iSolSup FROM bdisolic:"informix".tme_solicitudes2 WHERE tipo = 'S';
		--Se calculan los porcentaje de solicitudes atendidas aprobadas a tiempo
		SELECT {+INDEX("informix".tme_solicitudes2 idx_tme_solicitudes2_3)} COUNT(tipo) INTO iSolAproATiempo FROM bdisolic:"informix".tme_solicitudes2 WHERE tipo = 'A' AND atencioncat = 'ATTN A TIEMPO';
		--Se calculan los porcentaje de solicitudes atendidas aprobadas fuera de tiempo
		SELECT {+INDEX("informix".tme_solicitudes2 idx_tme_solicitudes2_3)} COUNT(tipo) INTO iSolAproFTiempo FROM bdisolic:"informix".tme_solicitudes2 WHERE tipo = 'A' AND atencioncat = 'ATTN F TIEMPO';
		--Se calculan los porcentaje de solicitudes atendidas supervisar a tiempo
		SELECT {+INDEX("informix".tme_solicitudes2 idx_tme_solicitudes2_3)} COUNT(tipo) INTO iSolSupATiempo FROM bdisolic:"informix".tme_solicitudes2 WHERE tipo = 'S' AND atencioncat = 'ATTN A TIEMPO';
		--Se calculan los porcentaje de solicitudes atendidas supervisar fuera de tiempo
		SELECT {+INDEX("informix".tme_solicitudes2 idx_tme_solicitudes2_3)} COUNT(tipo) INTO iSolSupFTiempo FROM bdisolic:"informix".tme_solicitudes2 WHERE tipo = 'S' AND atencioncat = 'ATTN F TIEMPO';
		IF iTotalSol > 0 THEN
			--Se calculan los porcentaje de solicitudes atendidas
			IF iAttnCat > 0 THEN
				LET dPorcAttn = (iAttnCat/iTotalSol) * 100;
			ELSE
				LET dPorcAttn = 0;
			END IF;
			--Se calculan los porcentaje de solicitudes en proceso de atencion
			IF iProcAttn > 0 THEN
				LET dPorcProcAttn = (iProcAttn/iTotalSol) * 100;
			ELSE
				LET dPorcProcAttn = 0;
			END IF;
			--Se calculan los porcentaje de solicitudes atendidas aprobadas
			IF iSolApro > 0 THEN
				LET dPorcAttnAprob = (iSolApro/iAttnCat) * 100;
			ELSE
				LET dPorcAttnAprob = 0;
			END IF;
			--Se calculan los porcentaje de solicitudes atendidas supervisadas
			IF iSolSup > 0 THEN
				LET dPorcAttnSup = (iSolSup/iAttnCat) * 100;
			ELSE
				LET dPorcAttnSup = 0;
			END IF;
			--Se calculan los porcentaje de solicitudes atendidas aprobadas a tiempo
			IF iSolAproATiempo > 0 THEN
				LET dPorcAttnATiempo = (iSolAproATiempo/iSolApro) * 100;
			ELSE
				LET dPorcAttnATiempo = 0;
			END IF;
			--Se calculan los porcentaje de solicitudes atendidas aprobadas fuera de tiempo
			IF iSolAproFTiempo > 0 THEN
				LET dPorcAttnFTiempo = (iSolAproFTiempo/iSolApro) * 100;
			ELSE
				LET dPorcAttnFTiempo = 0;
			END IF;
			--Se calculan los porcentaje de solicitudes atendidas supervisar a tiempo
			IF iSolSupATiempo > 0 THEN
				LET dPorcSolSupATiempo = (iSolSupATiempo/iSolSup) * 100;
			ELSE
				LET dPorcSolSupATiempo = 0;
			END IF;
			--Se calculan los porcentaje de solicitudes atendidas supervisar fuera de tiempo
			IF iSolSupFTiempo > 0 THEN
				LET dPorcSolSupFTiempo = (iSolSupFTiempo/iSolSup) * 100;
			ELSE
				LET dPorcSolSupFTiempo = 0;
			END IF;
		ELSE
			--Se calculan los porcentaje de solicitudes atendidas
			LET dPorcAttn = 0;
			--Se calculan los porcentaje de solicitudes en proceso de atencion
			LET dPorcProcAttn = 0;
			--Se calculan los porcentaje de solicitudes atendidas aprobadas
			LET dPorcAttnAprob = 0;
			--Se calculan los porcentaje de solicitudes atendidas supervisadas
			LET dPorcAttnSup = 0;
			--Se calculan los porcentaje de solicitudes atendidas aprobadas a tiempo
			LET dPorcAttnATiempo = 0;
			--Se calculan los porcentaje de solicitudes atendidas aprobadas fuera de tiempo
			LET dPorcAttnFTiempo = 0;
			--Se calculan los porcentaje de solicitudes atendidas supervisar a tiempo
			LET dPorcSolSupATiempo = 0;
			--Se calculan los porcentaje de solicitudes atendidas supervisar fuera de tiempo
			LET dPorcSolSupFTiempo = 0;
		END IF;
		--Se calcula porcentaje total
		IF dPorcAttn = 0 AND dPorcProcAttn = 0 THEN
			LET dPorcTotal = 0;
		ELSE
			LET dPorcTotal = dPorcAttn + dPorcProcAttn;
		END IF;
		--Se inserta total de solicitudes
		INSERT INTO bdisolic:"informix".tme_repostelgral(grupo,canttotal,porctotal,cantattncat,porcattncat,cantprocattn,porcprocattn,cantattnaprob,
		porcattnaprob,cantattnsup,porcattnsup,cantsolaprobatiempo,porcsolaprobatiempo,cantsolaprobftiempo,porcsolaprobftiempo,
		cantsolsupatiempo,porcsolsupatiempo,cantsolsupftiempo,porcsolsupftiempo)
		VALUES(iGrupo,iTotalSol,dPorcTotal,iAttnCat,dPorcAttn,iProcAttn,dPorcProcAttn,iSolApro,dPorcAttnAprob,iSolSup,
		dPorcAttnSup,iSolAproATiempo,dPorcAttnATiempo,iSolAproFTiempo,dPorcAttnFTiempo,iSolSupATiempo,dPorcSolSupATiempo,
		iSolSupFTiempo,dPorcSolSupFTiempo);
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		FOREACH
			SELECT grupo INTO iGrupo FROM bdisolic:"informix".tme_solicitudes2 GROUP BY grupo
			--Se obtiene el total de solicitudes enviadas al CAT  por grupo
			SELECT {+INDEX("informix".tme_solicitudes2 idx_tme_solicitudes2_2)} COUNT(tipo) INTO iTotalSol FROM bdisolic:"informix".tme_solicitudes2 WHERE grupo = iGrupo;
			SELECT {+INDEX("informix".tme_solicitudes2 idx_tme_solicitudes2_2)} COUNT(tipo) INTO iAttnCat FROM bdisolic:"informix".tme_solicitudes2 WHERE tipo <> 'P' AND grupo = iGrupo;
			SELECT {+INDEX("informix".tme_solicitudes2 idx_tme_solicitudes2_2)} COUNT(tipo) INTO iProcAttn FROM bdisolic:"informix".tme_solicitudes2 WHERE tipo = 'P' AND grupo = iGrupo;
			SELECT {+INDEX("informix".tme_solicitudes2 idx_tme_solicitudes2_2)} COUNT(tipo) INTO iSolApro FROM bdisolic:"informix".tme_solicitudes2 WHERE tipo = 'A' AND grupo = iGrupo;
			SELECT {+INDEX("informix".tme_solicitudes2 idx_tme_solicitudes2_2)} COUNT(tipo) INTO iSolSup FROM bdisolic:"informix".tme_solicitudes2 WHERE tipo = 'S' AND grupo = iGrupo;
			SELECT {+INDEX("informix".tme_solicitudes2 idx_tme_solicitudes2_4)} COUNT(tipo) INTO iSolAproATiempo FROM bdisolic:"informix".tme_solicitudes2 WHERE tipo = 'A' AND atencioncat = 'ATTN A TIEMPO' AND grupo = iGrupo;
			SELECT {+INDEX("informix".tme_solicitudes2 idx_tme_solicitudes2_4)} COUNT(tipo) INTO iSolAproFTiempo FROM bdisolic:"informix".tme_solicitudes2 WHERE tipo = 'A' AND atencioncat = 'ATTN F TIEMPO' AND grupo = iGrupo;
			SELECT {+INDEX("informix".tme_solicitudes2 idx_tme_solicitudes2_4)} COUNT(tipo) INTO iSolSupATiempo FROM bdisolic:"informix".tme_solicitudes2 WHERE tipo = 'S' AND atencioncat = 'ATTN A TIEMPO' AND grupo = iGrupo;
			SELECT {+INDEX("informix".tme_solicitudes2 idx_tme_solicitudes2_4)} COUNT(tipo) INTO iSolSupFTiempo FROM bdisolic:"informix".tme_solicitudes2 WHERE tipo = 'S' AND atencioncat = 'ATTN F TIEMPO' AND grupo = iGrupo;
			IF iTotalSol > 0 THEN
			--Se calculan los porcentaje de solicitudes atendidas por grupo
			IF iAttnCat > 0 THEN
				LET dPorcAttn = (iAttnCat/iTotalSol) * 100;
			ELSE
				LET dPorcAttn = 0;
			END IF;
			--Se calculan los porcentaje de solicitudes en proceso de atencion por grupo
			IF iProcAttn > 0 THEN
				LET dPorcProcAttn = (iProcAttn/iTotalSol) * 100;
			ELSE
				LET dPorcProcAttn = 0;
			END IF;
			--Se calculan los porcentaje de solicitudes atendidas aprobadas por grupo
			IF iSolApro > 0 THEN
				LET dPorcAttnAprob = (iSolApro/iAttnCat) * 100;
			ELSE
				LET dPorcAttnAprob = 0;
			END IF;
			--Se calculan los porcentaje de solicitudes atendidas supervisadas por grupo
			IF iSolSup > 0 THEN
				LET dPorcAttnSup = (iSolSup/iAttnCat) * 100;
			ELSE
				LET dPorcAttnSup = 0;
			END IF;
			--Se calculan los porcentaje de solicitudes atendidas aprobadas a tiempo por grupo
			IF iSolAproATiempo > 0 THEN
				LET dPorcAttnATiempo = (iSolAproATiempo/iSolApro) * 100;
			ELSE
				LET dPorcAttnATiempo = 0;
			END IF;
			--Se calculan los porcentaje de solicitudes atendidas aprobadas fuera de tiempo por grupo
			IF iSolAproFTiempo > 0 THEN
				LET dPorcAttnFTiempo = (iSolAproFTiempo/iSolApro) * 100;
			ELSE
				LET dPorcAttnFTiempo = 0;
			END IF;
			--Se calculan los porcentaje de solicitudes atendidas supervisar a tiempo por grupo
			IF iSolSupATiempo > 0 THEN
				LET dPorcSolSupATiempo = (iSolSupATiempo/iSolSup) * 100;
			ELSE
				LET dPorcSolSupATiempo = 0;
			END IF;
			--Se calculan los porcentaje de solicitudes atendidas supervisar fuera de tiempo por grupo
			IF iSolSupFTiempo > 0 THEN
				LET dPorcSolSupFTiempo = (iSolSupFTiempo/iSolSup) * 100;
			ELSE
				LET dPorcSolSupFTiempo = 0;
			END IF;
		ELSE
			--Se calculan los porcentaje de solicitudes atendidas por grupo
			LET dPorcAttn = 0;
			--Se calculan los porcentaje de solicitudes en proceso de atencion por grupo
			LET dPorcProcAttn = 0;
			--Se calculan los porcentaje de solicitudes atendidas aprobadas por grupo
			LET dPorcAttnAprob = 0;
			--Se calculan los porcentaje de solicitudes atendidas supervisadas por grupo
			LET dPorcAttnSup = 0;
			--Se calculan los porcentaje de solicitudes atendidas aprobadas a tiempo por grupo
			LET dPorcAttnATiempo = 0;
			--Se calculan los porcentaje de solicitudes atendidas aprobadas fuera de tiempo por grupo
			LET dPorcAttnFTiempo = 0;
			--Se calculan los porcentaje de solicitudes atendidas supervisar a tiempo por grupo
			LET dPorcSolSupATiempo = 0;
			--Se calculan los porcentaje de solicitudes atendidas supervisar fuera de tiempo por grupo
			LET dPorcSolSupFTiempo = 0;
		END IF;
			--Se calcula porcentaje total
			IF dPorcAttn = 0 AND dPorcProcAttn = 0 THEN
				LET dPorcTotal = 0;
			ELSE
				LET dPorcTotal = dPorcAttn + dPorcProcAttn;
			END IF;
			--Se insertan totales por grupo
			INSERT INTO bdisolic:"informix".tme_repostelgral(grupo,canttotal,porctotal,cantattncat,porcattncat,cantprocattn,porcprocattn,
			cantattnaprob,porcattnaprob,cantattnsup,porcattnsup,cantsolaprobatiempo,porcsolaprobatiempo,cantsolaprobftiempo,
			porcsolaprobftiempo,cantsolsupatiempo,porcsolsupatiempo,cantsolsupftiempo,porcsolsupftiempo)
			VALUES(iGrupo,iTotalSol,dPorcTotal,iAttnCat,dPorcAttn,iProcAttn,dPorcProcAttn,iSolApro,dPorcAttnAprob,iSolSup,
			dPorcAttnSup,iSolAproATiempo,dPorcAttnATiempo,iSolAproFTiempo,dPorcAttnFTiempo,iSolSupATiempo,dPorcSolSupATiempo,
			iSolSupFTiempo,dPorcSolSupFTiempo);
		END FOREACH;
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		FOREACH
			SELECT {+INDEX("informix".tme_repostelgral idx_tme_repostelgral)} NVL(grupo,''),canttotal,porctotal,cantattncat,porcattncat,cantprocattn,porcprocattn,cantattnaprob,porcattnaprob,
			cantattnsup,porcattnsup,cantsolaprobatiempo,porcsolaprobatiempo,cantsolaprobftiempo,porcsolaprobftiempo,
			cantsolsupatiempo,porcsolsupatiempo,cantsolsupftiempo,porcsolsupftiempo
			INTO iGrupo,iTotalSol,dPorcTotal,iAttnCat,dPorcAttn,iProcAttn,dPorcProcAttn,iSolApro,dPorcAttnAprob,iSolSup,
			dPorcAttnSup,iSolAproATiempo,dPorcAttnATiempo,iSolAproFTiempo,dPorcAttnFTiempo,iSolSupATiempo,dPorcSolSupATiempo,
			iSolSupFTiempo,dPorcSolSupFTiempo
			FROM bdisolic:"informix".tme_repostelgral
			WHERE grupo <> ''
			ORDER BY grupo
			LET cBandera = 'V';
			--CALL bdicobranza:"informix".inserta_bitacora_cob('001', vproceso, cCodRet, cMensaje, '03');
			RETURN cCodRet,iGrupo,iAttnCat,iSolApro,iSolAproATiempo,iSolAproFTiempo,iSolSup,iSolSupATiempo,iSolSupFTiempo,iProcAttn,iTotalSol,
			dPorcAttn,dPorcAttnAprob,dPorcAttnATiempo,dPorcAttnFTiempo,dPorcAttnSup,dPorcSolSupATiempo,dPorcSolSupFTiempo,dPorcProcAttn,
			dPorcTotal WITH RESUME;
		END FOREACH;
		--Se elimina la informacion de las tablas temporales
		DELETE FROM bdisolic:"informix".tme_solicitudes;
		DELETE FROM bdisolic:"informix".tme_solicitudes2;
		DELETE FROM bdisolic:"informix".tme_repostelgral;
	END IF;
	IF cBandera = 'F' THEN
	--CALL bdicobranza:"informix".inserta_bitacora_cob('001', vproceso, cCodRet, cMensaje, '03');
		RETURN cCodRet,iGrupo,iAttnCat,iSolApro,iSolAproATiempo,iSolAproFTiempo,iSolSup,iSolSupATiempo,iSolSupFTiempo,iProcAttn,iTotalSol,dPorcAttn,
		dPorcAttnAprob,dPorcAttnATiempo,dPorcAttnFTiempo,dPorcAttnSup,dPorcSolSupATiempo,dPorcSolSupFTiempo,dPorcProcAttn,dPorcTotal;
	END IF;
	CALL bdicobranza:"informix".inserta_bitacora_cob('001', vproceso, cCodRet, cMensaje, '03');
--	drop table bdisolic:tme_solicitudes;
--	drop table bdisolic:tme_solicitudes2;
--	drop table bdisolic:tme_repostelgral;
	/*
	drop INDEX idx_tme_solicitudes ;
	drop INDEX idx_tme_solicitudes2;
	drop INDEX idx_tme_solicitudes2_2 ;
	drop INDEX idx_tme_solicitudes2_3 ;
	drop INDEX idx_tme_solicitudes2_4 ;
	drop INDEX idx_tme_repostelgral;	*/
END
END PROCEDURE

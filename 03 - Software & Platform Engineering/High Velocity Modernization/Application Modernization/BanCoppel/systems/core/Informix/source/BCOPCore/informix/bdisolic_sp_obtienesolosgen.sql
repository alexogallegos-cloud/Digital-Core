CREATE PROCEDURE "informix".sp_obtienesolosgen(pEmpresa CHAR(3), pTpConsulta CHAR(2), pFiltro VARCHAR(4), pProducto CHAR(4), pFechaIni DATE, pFechaFin DATE, pUsuario CHAR(8)) 
RETURNING
		CHAR(6)			AS cod_ret,
		VARCHAR(80,1)	AS mensaje_ret,
		VARCHAR(200,1)	AS descripcion_status,
		DECIMAL(18,2)	AS grupo1_hit,
		DECIMAL(18,2)	AS grupo1_no_hit,
		DECIMAL(18,2)	AS grupo2_hit,
		DECIMAL(18,2)	AS grupo2_no_hit,
		DECIMAL(18,2)	AS grupo3_hit,
		DECIMAL(18,2)	AS grupo3_no_hit,
		DECIMAL(18,2)	AS grupo5_hit,
		DECIMAL(18,2)	AS grupo5_no_hit,
		DECIMAL(18,2)	AS grupo6_hit,		--RQM 09 298-2
		DECIMAL(18,2)	AS grupo6_no_hit,	--RQM 09 298-2
		DECIMAL(18,2)	AS grupoa_hit,		--RQM 09 298-2
		DECIMAL(18,2)	AS grupoa_no_hit,	--RQM 09 298-2
		DECIMAL(18,2)	AS grupo7_hit,
		DECIMAL(18,2)	AS grupo7_no_hit,
		DECIMAL(18,2)	AS grupo8_hit,
		DECIMAL(18,2)	AS grupo8_no_hit,
		DECIMAL(18,2)	AS total_x_estatus_hit,
		DECIMAL(18,2)	AS total_x_estatus_no_hit,
		DECIMAL(18,2)	AS porc_status_hit,
		DECIMAL(18,2)	AS porc_status_no_hit,
		DECIMAL(18,2)	AS total_x_estatus,
		DECIMAL(18,2)	AS porc_status;

DEFINE iSqlErr					INTEGER;
DEFINE iIsamErr					INTEGER;
DEFINE cErrorInfo				CHAR(80);
DEFINE cCodRet					CHAR(6);
DEFINE vMensajeRet				VARCHAR(80,1);
DEFINE cEmpresa					CHAR(3);
DEFINE vDescripcion				VARCHAR(200,1);
DEFINE dgrupo1_hit				DECIMAL(18,2);
DEFINE dgrupo1_no_hit			DECIMAL(18,2);
DEFINE dgrupo2_hit				DECIMAL(18,2);
DEFINE dgrupo2_no_hit			DECIMAL(18,2);
DEFINE dgrupo3_hit				DECIMAL(18,2);
DEFINE dgrupo3_no_hit			DECIMAL(18,2);
DEFINE dGrupo5_hit				DECIMAL(18,2);
DEFINE dGrupo5_no_hit			DECIMAL(18,2);
DEFINE dGrupo6_hit				DECIMAL(18,2); --RQM 09 298-2
DEFINE dGrupo6_no_hit			DECIMAL(18,2); --RQM 09 298-2
DEFINE dGrupoa_hit				DECIMAL(18,2); --RQM 09 298-2
DEFINE dGrupoa_no_hit			DECIMAL(18,2); --RQM 09 298-2
DEFINE dGrupo7_hit				DECIMAL(18,2);
DEFINE dGrupo7_no_hit			DECIMAL(18,2);
DEFINE dGrupo8_hit				DECIMAL(18,2);
DEFINE dGrupo8_no_hit			DECIMAL(18,2);
DEFINE dTotalStatus				DECIMAL(18,2);
DEFINE dTotalGenStatus			DECIMAL(18,2);
DEFINE cBanTmp					CHAR(1);
DEFINE iTotal_sol_rep			INTEGER;
DEFINE iTotal_sol_rep_hit		INTEGER;
DEFINE iTotal_sol_rep_no_hit	INTEGER;
DEFINE dtotal_status_hit		DECIMAL(18,2); 
DEFINE dtotal_status_no_hit		DECIMAL(18,2); 
DEFINE dporc_status_hit			DECIMAL(18,2);   
DEFINE dporc_status_no_hit		DECIMAL(18,2);   
DEFINE sNumRegistros			SMALLINT;
DEFINE iNumSesion				INTEGER;
DEFINE iMotivoOs				INTEGER;
DEFINE cSucursal				CHAR(4);
DEFINE cCiudad					CHAR(3);
DEFINE cEstado					CHAR(2);
DEFINE sNumRegion				SMALLINT;
DEFINE sSecuencia				SMALLINT;


-- INICIALIZACION
LET iSqlErr					= 0;
LET iIsamErr				= 0;
LET cErrorInfo				= '';
LET cCodRet					= '000000';
LET vMensajeRet				= 'Se ejecutó la consulta correctamente';
LET cEmpresa				= '';
LET vDescripcion			= '';
LET dgrupo1_hit				= 0;
LET dgrupo1_no_hit			= 0;
LET dgrupo2_hit				= 0;
LET dgrupo2_no_hit			= 0;
LET dgrupo3_hit				= 0;
LET dgrupo3_no_hit			= 0;
LET dGrupo5_hit				= 0;
LET dGrupo5_no_hit			= 0;
LET dGrupoa_hit				= 0; --RQM 09 298-2
LET dGrupoa_no_hit			= 0; --RQM 09 298-2
LET dGrupo6_hit				= 0; --RQM 09 298-2
LET dGrupo6_no_hit			= 0; --RQM 09 298-2
LET dGrupo7_hit				= 0;
LET dGrupo7_no_hit			= 0;
LET dGrupo8_hit				= 0;
LET dGrupo8_no_hit			= 0;
LET dTotalStatus			= 0;
LET dTotalGenStatus			= 0;
LET cBanTmp					= "N";
LET iTotal_sol_rep			= 0;
LET iTotal_sol_rep_hit		= 0;
LET iTotal_sol_rep_no_hit	= 0;
LET dporc_status_hit		= 0;
LET dporc_status_no_hit		= 0; 
LET sNumRegistros			= 0;
LET dtotal_status_hit		= 0; 
LET dtotal_status_no_hit	= 0; 
LET iNumSesion				= 0; 
LET iMotivoOs				= 0; 
LET cSucursal				= '';
LET cCiudad					= '';
LET cEstado					= '';
LET sNumRegion				= 0; 
LET sSecuencia				= 0; 


BEGIN

	ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
	   IF iSqlErr <> 0 THEN
		  IF cBanTmp = "S" THEN
			IF pTpConsulta = '01' THEN

				DELETE FROM "informix".ss_grupo_os WHERE usuario = pUsuario AND sesion = iNumSesion;
				DELETE FROM "informix".ss_totalsolgrupo WHERE usuario = pUsuario AND sesion = iNumSesion;
				DELETE FROM "informix".ss_totalestado;

			ELIF pTpConsulta = '02' THEN

				DELETE FROM "informix".ss_grupo_os WHERE usuario = pUsuario AND sesion = iNumSesion;
				DELETE FROM "informix".ss_totalsolgrupo WHERE usuario = pUsuario AND sesion = iNumSesion;
				DELETE FROM "informix".ss_totalciudad;

			ELIF pTpConsulta = '03' THEN

				DELETE FROM "informix".ss_grupo_os WHERE usuario = pUsuario AND sesion = iNumSesion;
				DELETE FROM "informix".ss_totalsolgrupo WHERE usuario = pUsuario AND sesion = iNumSesion;
				DELETE FROM "informix".ss_totalregion;
			ELIF pTpConsulta = '04' THEN

				DELETE FROM "informix".ss_grupo_os WHERE usuario = pUsuario AND sesion = iNumSesion;
				DELETE FROM "informix".ss_totalsolgrupo WHERE usuario = pUsuario AND sesion = iNumSesion;
				DELETE FROM "informix".ss_totalsucursal;

			END IF
		  END IF;

			LET cCodRet= iSqlErr;
			LET vMensajeRet= cErrorInfo;
			RETURN cCodRet, vMensajeRet, vDescripcion, dgrupo1_hit,dgrupo1_no_hit, dgrupo2_hit,dgrupo2_no_hit , dgrupo3_hit,dgrupo3_no_hit, dGrupo5_hit, dGrupo5_no_hit, dGrupo6_hit, dGrupo6_no_hit, dGrupoa_hit, dGrupoa_no_hit,dgrupo7_hit, dgrupo7_no_hit,dgrupo8_hit, dgrupo8_no_hit, dtotal_status_hit,dtotal_status_no_hit,dporc_status_hit,dporc_status_no_hit,dTotalStatus, dTotalGenStatus;
		END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO "gegenes.out";
	--TRACE ON;
	--SET EXPLAIN FILE TO '/dbexportb/carlos/oscalle/gegenes.out';

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	IF NVL(pEmpresa,'') = '' THEN
		LET cCodRet = '000001';
		LET vMensajeRet = 'Es necesario indicar la empresa para ejecutar el proceso';
		RETURN cCodRet, vMensajeRet, vDescripcion, dgrupo1_hit,dgrupo1_no_hit, dgrupo2_hit,dgrupo2_no_hit, dgrupo3_hit,dgrupo3_no_hit,dGrupo5_hit, dGrupo5_no_hit, dGrupo6_hit, dGrupo6_no_hit, dGrupoa_hit, dGrupoa_no_hit,dgrupo7_hit,dgrupo7_no_hit,dgrupo8_hit, dgrupo8_no_hit, dtotal_status_hit,dtotal_status_no_hit,dporc_status_hit,dporc_status_no_hit,dTotalStatus, dTotalGenStatus;
	END IF;

	SELECT empresa
	INTO cEmpresa
	FROM bdinteg:"informix".si_empresas
	WHERE empresa = pEmpresa;

	IF cEmpresa IS NULL THEN
		LET cCodRet = '000002';
		LET vMensajeRet = 'La empresa indicada no es valida';
	ELIF NVL(pTpConsulta,"") = "" THEN
		LET cCodRet = "000003";
		LET vMensajeRet = "Es necesario indicar el tipo de consulta a realizar";
	ELIF NVL(pFechaIni,"") = "" AND NVL(pFechaFin, "") = "" THEN
		LET cCodRet = "000004";
		LET vMensajeRet = "Es necesario indicar al menos una fecha";
	ELIF (NVL(pFechaIni,"") <> "" AND NVL(pFechaFin, "") <> "") AND (pFechaIni > pFechaFin) THEN
		LET cCodRet = "000005";
		LET vMensajeRet = "La fecha inicial no debe ser mayor a la fecha final";
	ELIF NVL(pUsuario,"") = "" THEN
		LET cCodRet = "000007";
		LET vMensajeRet = "Es obligatorio enviar el num de usuario para su ejecucion";
	END IF;

	IF cCodRet <> '000000' THEN
		RETURN cCodRet, vMensajeRet, vDescripcion, dgrupo1_hit, dgrupo1_no_hit, dgrupo2_hit, dgrupo2_no_hit, dgrupo3_hit, dgrupo3_no_hit, dGrupo5_hit, dGrupo5_no_hit, dGrupo6_hit, dGrupo6_no_hit, dGrupoa_hit, dGrupoa_no_hit, dgrupo7_hit, dgrupo7_no_hit,dgrupo8_hit, dgrupo8_no_hit, dtotal_status_hit,dtotal_status_no_hit,dporc_status_hit,dporc_status_no_hit,dTotalStatus, dTotalGenStatus;
	END IF;

	-- Obtenemos el numero de la sesion para el control de registros.
	SELECT DBINFO('sessionid')
	INTO iNumSesion
	FROM sysmaster:"informix".systables
	WHERE tabname = 'systables';
	
	DELETE FROM "informix".ss_grupo_os WHERE usuario = pUsuario;
	DELETE FROM "informix".ss_totalsolgrupo WHERE usuario = pUsuario;

	LET cBanTmp = "S";

	-- CONSULTAMOS TODOS LOS REGISTROS DE OS GENERADAS.
	INSERT INTO "informix".ss_grupo_os( motivo_os, sucursal, valor_alfabetico, secuencia, grupo1_hit, grupo1_no_hit, grupo2_hit, grupo2_no_hit,
	grupo3_hit, grupo3_no_hit, grupo5_hit, grupo5_no_hit, grupo6_hit, grupo6_no_hit, grupoa_hit, grupoa_no_hit, grupo7_hit, grupo7_no_hit,grupo8_hit, grupo8_no_hit, cantidad, cantidad_hit, cantidad_no_hit, usuario, sesion )
	SELECT ssOS.motivo_os,  a.sucursal, ssP.valor_alfabetico, ssP.secuencia,
		SUM(CASE WHEN (nvl(b.grupo,'') in ('1','4')) AND evalua_cc IN ('0','1','2','3','4')  THEN 1 ELSE 0 END)grupo1_hit, 
		SUM(CASE WHEN (nvl(b.grupo,'') in ('1','4')) AND NVL(evalua_cc,'') IN ('X','')  THEN 1 ELSE 0 END) grupo1_no_hit, 
		SUM(CASE WHEN (nvl(b.grupo,'') = '2') AND evalua_cc IN ('0','1','2','3','4')  THEN 1 ELSE 0 END) grupo2_hit,
		SUM(CASE WHEN (nvl(b.grupo,'') = '2') AND NVL(evalua_cc,'') IN ('X','')  THEN 1 ELSE 0 END) grupo2_no_hit,
		SUM(CASE WHEN (nvl(b.grupo,'') = '3') AND evalua_cc IN ('0','1','2','3','4')  THEN 1 ELSE 0 END) grupo3_hit,
		SUM(CASE WHEN (nvl(b.grupo,'') = '3') AND NVL(evalua_cc,'') IN ('X','')  THEN 1 ELSE 0 END) grupo3_no_hit,
		SUM(CASE WHEN (nvl(b.grupo,'') = '5') AND evalua_cc in ('0','1','2','3','4')  THEN 1 ELSE 0 END) grupo5_hit,
		SUM(CASE WHEN (nvl(b.grupo,'') = '5') AND NVL(evalua_cc,'') IN ('X','')  THEN 1 ELSE 0 END) grupo5_no_hit,
		SUM(CASE WHEN (nvl(b.Grupo,'') = '6') AND evalua_cc IN ('0','1','2','3','4')  THEN 1 ELSE 0 END) grupo6_hit,
		SUM(CASE WHEN (nvl(b.Grupo,'') = '6') AND NVL(evalua_cc,'') IN ('X','') THEN 1 ELSE 0 END) grupo6_no_hit,
		SUM(CASE WHEN (nvl(b.Grupo,'') = 'A') AND evalua_cc IN ('0','1','2','3','4')  THEN 1 ELSE 0 END) grupoa_hit,
		SUM(CASE WHEN (nvl(b.Grupo,'') = 'A') AND NVL(evalua_cc,'') IN ('X','')  THEN 1 ELSE 0 END) grupoa_no_hit,
		0 grupo7_hit, SUM(CASE WHEN (nvl(b.Grupo,'') = '7') OR (NVL(pr.tipo_alta,'') = '2' and nvl(a.num_producto,'') = '6500') THEN 1 ELSE 0 END) grupo7_no_hit,
		SUM(CASE WHEN (nvl(b.Grupo,'') = '8') AND evalua_cc IN ('0','1','2','3','4')  THEN 1 ELSE 0 END) grupo8_hit,
		SUM(CASE WHEN (nvl(b.Grupo,'') = '8') AND NVL(evalua_cc,'') IN ('X','')  THEN 1 ELSE 0 END) grupo8_no_hit ,
		SUM(CASE WHEN (nvl(b.grupo,'') in ('1','4')) AND evalua_cc IN ('0','1','2','3','4')  THEN 1 ELSE 0 END +
			CASE WHEN (nvl(b.grupo,'') in ('1','4')) AND NVL(evalua_cc,'') IN ('X','')  THEN 1 ELSE 0 END +
			CASE WHEN (nvl(b.grupo,'') = '2') AND evalua_cc IN ('0','1','2','3','4')  THEN 1 ELSE 0 END +
			CASE WHEN (nvl(b.grupo,'') = '2') AND NVL(evalua_cc,'') IN ('X','')  THEN 1 ELSE 0 END +
			CASE WHEN (nvl(b.grupo,'') = '3') AND evalua_cc IN ('0','1','2','3','4')  THEN 1 ELSE 0 END +
			CASE WHEN (nvl(b.grupo,'') = '3') AND NVL(evalua_cc,'') IN ('X','')  THEN 1 ELSE 0 END +
			CASE WHEN (nvl(b.grupo,'') = '5') AND evalua_cc in ('0','1','2','3','4')  THEN 1 ELSE 0 END +
			CASE WHEN (nvl(b.grupo,'') = '5') AND NVL(evalua_cc,'') IN ('X','')  THEN 1 ELSE 0 END +
			CASE WHEN (nvl(b.Grupo,'') = '6') AND evalua_cc IN ('0','1','2','3','4')  THEN 1 ELSE 0 END +
			CASE WHEN (nvl(b.Grupo,'') = '6') AND NVL(evalua_cc,'') IN ('X','') THEN 1 ELSE 0 END +
			CASE WHEN (nvl(b.Grupo,'') = 'A') AND evalua_cc IN ('0','1','2','3','4')  THEN 1 ELSE 0 END +
			CASE WHEN (nvl(b.Grupo,'') = 'A') AND NVL(evalua_cc,'') IN ('X','')  THEN 1 ELSE 0 END +
			CASE WHEN (nvl(b.Grupo,'') = '7') OR (NVL(pr.tipo_alta,'') = '2' and nvl(a.num_producto,'') = '6500') THEN 1 ELSE 0 END+
			CASE WHEN (nvl(b.Grupo,'') = '8') AND evalua_cc IN ('0','1','2','3','4')  THEN 1 ELSE 0 END +
			CASE WHEN (nvl(b.Grupo,'') = '8') AND NVL(evalua_cc,'') IN ('X','')  THEN 1 ELSE 0 END ) AS cantidad,
		SUM(CASE WHEN (nvl(b.grupo,'') in ('1','4')) AND evalua_cc IN ('0','1','2','3','4')  THEN 1 ELSE 0 END +
			CASE WHEN (nvl(b.grupo,'') = '2') AND evalua_cc IN ('0','1','2','3','4')  THEN 1 ELSE 0 END +
			CASE WHEN (nvl(b.grupo,'') = '3') AND evalua_cc IN ('0','1','2','3','4')  THEN 1 ELSE 0 END +
			CASE WHEN (nvl(b.grupo,'') = '5') AND evalua_cc in ('0','1','2','3','4')  THEN 1 ELSE 0 END +
			CASE WHEN (nvl(b.Grupo,'') = '6') AND evalua_cc IN ('0','1','2','3','4')  THEN 1 ELSE 0 END +
			CASE WHEN (nvl(b.Grupo,'') = 'A') AND evalua_cc IN ('0','1','2','3','4')  THEN 1 ELSE 0 END +
			CASE WHEN (nvl(b.Grupo,'') = '8') AND evalua_cc IN ('0','1','2','3','4')  THEN 1 ELSE 0 END) AS cantidad_hit,
		SUM(CASE WHEN (nvl(b.grupo,'') in ('1','4')) AND NVL(evalua_cc,'') IN ('X','')  THEN 1 ELSE 0 END +
			CASE WHEN (nvl(b.grupo,'') = '2') AND NVL(evalua_cc,'') IN ('X','')  THEN 1 ELSE 0 END +
			CASE WHEN (nvl(b.grupo,'') = '3') AND NVL(evalua_cc,'') IN ('X','')  THEN 1 ELSE 0 END +
			CASE WHEN (nvl(b.grupo,'') = '5') AND NVL(evalua_cc,'') IN ('X','')  THEN 1 ELSE 0 END +
			CASE WHEN (nvl(b.Grupo,'') = '6') AND NVL(evalua_cc,'') IN ('X','') THEN 1 ELSE 0 END +
			CASE WHEN (nvl(b.Grupo,'') = 'A') AND NVL(evalua_cc,'') IN ('X','')  THEN 1 ELSE 0 END +
			CASE WHEN (nvl(b.Grupo,'') = '7') OR (NVL(pr.tipo_alta,'') = '2' and nvl(a.num_producto,'') = '6500') THEN 1 ELSE 0 END +
			CASE WHEN (nvl(b.Grupo,'') = '8') AND NVL(evalua_cc,'') IN ('X','')  THEN 1 ELSE 0 END ) AS cantidad_no_hit,
			pUsuario, iNumSesion
	FROM "informix".ss_solicitudes a,
		 "informix".ss_resum_scor_fin b,
		 "informix".ss_autorizacion c,
		 "informix".ss_solicitud_os ssOS,
		 "informix".ss_param_solicitudes ssP,
		 outer bdiprospectos:"informix".pr_cliente pr
	WHERE a.empresa = b.empresa
	AND a.num_solicitud = ssOS.num_solicitud
	AND a.num_solicitud = b.num_solicitud
	AND a.num_solicitud = c.num_solicitud
	AND a.status_solicitud= c.status_solicitud
	and a.numcte = pr.numcte
	AND c.fecha_entrada = (SELECT MAX(fecha_entrada) FROM "informix".ss_autorizacion WHERE a.empresa = empresa AND a.num_solicitud = num_solicitud AND a.status_solicitud = status_solicitud)
	AND a.num_producto = pProducto
	AND a.fecha_insert >= pFechaIni
	AND a.fecha_insert <= pFechaFin
	AND ssP.num_parametro = ssOS.motivo_os
	AND ssP.valor_numerico = "1"  and ssP.grupo_parametro = 'MOTIVOS_OS'
	and pr.tipo_alta = '2'
	GROUP BY 1,2,3,4;

	FOREACH

		SELECT a.motivo_os, a.sucursal, a.secuencia, c.ciudad, c.estado, r.numero_region
		INTO iMotivoOs, cSucursal, sSecuencia, cCiudad, cEstado, sNumRegion
		FROM "informix".ss_grupo_os a,
			 bdinteg:"informix".si_sucursales s,
			 bdinteg:"informix".si_ciudades c ,
			 bdinteg:"informix".si_catciudades t,
			 bdinteg:"informix".si_regiones r
		WHERE a.sucursal = s.sucursal
		  AND s.tpo_sucursal = "S"
		  AND s.ciudad = c.ciudad
		  AND s.pais = c.pais
		  AND s.estado = c.estado
		  AND c.ciudad_coppel = t.numerociudad
		  AND t.numero_region = r.numero_region
		  AND a.usuario = pUsuario
		  AND a.sesion = iNumSesion

		-- Le agregamos el valor de la ciudad, estado, region.
		UPDATE "informix".ss_grupo_os SET ciudad = cCiudad, estado = cEstado, numero_region = sNumRegion
		WHERE motivo_os = iMotivoOs
		  AND sucursal = cSucursal
		  AND secuencia = sSecuencia
		  AND usuario = pUsuario
		  AND sesion = iNumSesion;

	END FOREACH

	IF pTpConsulta	 = '04' THEN ---SUCURSAL

		INSERT INTO "informix".ss_totalsucursal(sucursal, cantidad, cantidad_hit, cantidad_no_hit)
		SELECT sucursal, SUM(cantidad), SUM(cantidad_hit), SUM(cantidad_no_hit)
		FROM "informix".ss_grupo_os 
		WHERE usuario = pUsuario
		AND sesion = iNumSesion
		GROUP BY 1;

		IF pFiltro <> '' THEN
			SELECT SUM(cantidad),SUM(cantidad_hit),SUM(cantidad_no_hit) INTO iTotal_sol_rep,iTotal_sol_rep_hit,iTotal_sol_rep_no_hit FROM "informix".ss_totalsucursal 
			WHERE sucursal = pFiltro; 
		ELSE
			SELECT SUM(cantidad),SUM(cantidad_hit),SUM(cantidad_no_hit) INTO iTotal_sol_rep,iTotal_sol_rep_hit,iTotal_sol_rep_no_hit FROM "informix".ss_totalsucursal; 
		END IF;

		IF  pFiltro <> '' THEN

			INSERT INTO "informix".ss_totalsolgrupo(valor_alfabetico, grupo1_hit, grupo1_no_hit, grupo2_hit, grupo2_no_hit, grupo3_hit, grupo3_no_hit,
			grupo5_hit, grupo5_no_hit, grupo6_hit, grupo6_no_hit, grupoa_hit, grupoa_no_hit, grupo7_hit, grupo7_no_hit,grupo8_hit, grupo8_no_hit, total_x_status_hit, total_x_status_no_hit, porc_status_hit, porc_status_no_hit, total_x_status,
			 porc_status, secuencia, usuario, sesion) 
			SELECT a.valor_alfabetico, SUM(a.grupo1_hit) AS grupo1_hit, SUM(a.grupo1_no_hit) AS grupo1_no_hit, SUM(a.grupo2_hit) AS grupo2_hit, SUM(a.grupo2_no_hit) AS grupo2_no_hit,
				SUM(a.grupo3_hit) AS grupo3_hit, SUM(a.grupo3_no_hit) AS grupo3_no_hit, SUM(grupo5_hit) AS grupo5_hit,SUM(grupo5_no_hit) AS grupo5_no_hit, 
				SUM(grupo6_hit) AS grupo6_hit, SUM(grupo6_no_hit) AS grupo6_no_hit, SUM(grupoa_hit) AS grupoa_hit, SUM(grupoa_no_hit) AS grupoa_no_hit, SUM(grupo7_hit) AS grupo7_hit,SUM(grupo7_no_hit) AS grupo7_no_hit,
				SUM(grupo8_hit) AS grupo8_hit,SUM(grupo8_no_hit) AS grupo8_no_hit,
				SUM(a.cantidad_hit) AS total_x_status_hit, SUM(a.cantidad_no_hit) AS total_x_status_no_hit,
				( CASE WHEN iTotal_sol_rep_hit = 0 THEN 0 ELSE ROUND((SUM(a.cantidad_hit) / iTotal_sol_rep_hit) * 100,2) END ) AS porc_status_hit, 
				( CASE WHEN iTotal_sol_rep_no_hit = 0 THEN 0 ELSE ROUND((SUM(a.cantidad_no_hit) / iTotal_sol_rep_no_hit) * 100,2) END ) AS porc_status_no_hit,
				SUM(grupo1_hit+grupo1_no_hit+grupo2_hit+grupo2_no_hit+grupo3_hit+grupo3_no_hit+grupo5_hit+grupo5_no_hit+grupo6_hit+ grupo6_no_hit +grupoa_hit+grupoa_no_hit+grupo7_hit+grupo7_no_hit+grupo8_hit+grupo8_no_hit) total_x_status, 
				( CASE WHEN iTotal_sol_rep = 0 THEN 0 ELSE ROUND((SUM(a.cantidad) / iTotal_sol_rep) * 100,2) END ) AS porc_status,
				a.secuencia, pUsuario, iNumSesion
			FROM "informix".ss_grupo_os a 
			WHERE a.sucursal = pFiltro
			GROUP BY a.valor_alfabetico, a.secuencia;

		ELIF pFiltro = '' THEN

			INSERT INTO "informix".ss_totalsolgrupo(valor_alfabetico, grupo1_hit, grupo1_no_hit, grupo2_hit, grupo2_no_hit, grupo3_hit, grupo3_no_hit,
			 grupo5_hit, grupo5_no_hit, grupo6_hit, grupo6_no_hit, grupoa_hit, grupoa_no_hit, grupo7_hit, grupo7_no_hit, grupo8_hit, grupo8_no_hit, total_x_status_hit, total_x_status_no_hit, porc_status_hit, porc_status_no_hit, total_x_status,
			 porc_status, secuencia, usuario, sesion) 
			SELECT a.valor_alfabetico, SUM(a.grupo1_hit) AS grupo1_hit, SUM(a.grupo1_no_hit) AS grupo1_no_hit,SUM(a.grupo2_hit) AS grupo2_hit,SUM(a.grupo2_no_hit) AS grupo2_no_hit,
				SUM(a.grupo3_hit) AS grupo3_hit,SUM(a.grupo3_no_hit) AS grupo3_no_hit, SUM(grupo5_hit) AS grupo5_hit,SUM(grupo5_no_hit) AS grupo5_no_hit, 
				SUM(grupo6_hit) AS grupo6_hit, SUM(grupo6_no_hit) AS grupo6_no_hit, SUM(grupoa_hit) AS grupoa_hit, SUM(grupoa_no_hit) AS grupoa_no_hit, SUM(grupo7_hit) AS grupo7_hit,SUM(grupo7_no_hit) AS grupo7_no_hit,
				SUM(grupo8_hit) AS grupo8_hit,SUM(grupo8_no_hit) AS grupo8_no_hit,
				SUM(a.cantidad_hit) AS total_x_status_hit,SUM(a.cantidad_no_hit) AS total_x_status_no_hit,
				( CASE WHEN iTotal_sol_rep_hit = 0 THEN 0 ELSE ROUND((SUM(a.cantidad_hit) / iTotal_sol_rep_hit) * 100,2) END ) AS porc_status_hit,
				( CASE WHEN iTotal_sol_rep_no_hit = 0 THEN 0 ELSE ROUND((SUM(a.cantidad_no_hit) / iTotal_sol_rep_no_hit) * 100,2) END ) AS porc_status_no_hit,
				SUM(grupo1_hit+grupo1_no_hit+grupo2_hit+grupo2_no_hit+grupo3_hit+grupo3_no_hit+grupo5_hit+grupo5_no_hit+grupo6_hit+ grupo6_no_hit +grupoa_hit+grupoa_no_hit+grupo7_hit+grupo7_no_hit+grupo8_hit+grupo8_no_hit) total_x_status, 
				( CASE WHEN iTotal_sol_rep = 0 THEN 0 ELSE ROUND((SUM(a.cantidad) / iTotal_sol_rep) * 100,2) END ) AS porc_status,
				a.secuencia, pUsuario, iNumSesion
			FROM "informix".ss_grupo_os a 
			GROUP BY a.valor_alfabetico, a.secuencia;

		END IF;

	END IF;

	IF pTpConsulta	 = '01' THEN  ---ESTADO
		
		INSERT INTO "informix".ss_totalestado(estado, cantidad, cantidad_hit, cantidad_no_hit)
		SELECT estado, SUM(cantidad) total,SUM(cantidad_hit) total_hit,SUM(cantidad_no_hit) total_no_hit
		FROM "informix".ss_grupo_os 
		WHERE usuario = pUsuario
		AND sesion	= iNumSesion
		GROUP BY 1;

		IF pFiltro <> '' THEN
			LET iTotal_sol_rep = 0;
			SELECT SUM(cantidad),SUM(cantidad_hit),SUM(cantidad_no_hit) INTO iTotal_sol_rep,iTotal_sol_rep_hit,iTotal_sol_rep_no_hit FROM "informix".ss_totalestado 
			WHERE estado = pFiltro;
		ELSE
			SELECT SUM(cantidad),SUM(cantidad_hit),SUM(cantidad_no_hit) INTO iTotal_sol_rep,iTotal_sol_rep_hit,iTotal_sol_rep_no_hit FROM "informix".ss_totalestado; 
		END IF;

		IF  pFiltro <> '' THEN

			INSERT INTO "informix".ss_totalsolgrupo(valor_alfabetico, grupo1_hit, grupo1_no_hit, grupo2_hit, grupo2_no_hit, grupo3_hit, grupo3_no_hit,
			 grupo5_hit, grupo5_no_hit, grupo6_hit, grupo6_no_hit,  grupoa_hit, grupoa_no_hit, grupo7_hit, grupo7_no_hit,grupo8_hit, grupo8_no_hit, total_x_status_hit, total_x_status_no_hit, porc_status_hit, porc_status_no_hit, total_x_status,
			 porc_status, secuencia, usuario, sesion) 
			SELECT a.valor_alfabetico, SUM(a.grupo1_hit) AS grupo1_hit, SUM(a.grupo1_no_hit) AS grupo1_no_hit, SUM(a.grupo2_hit) AS grupo2_hit, SUM(a.grupo2_no_hit) AS grupo2_no_hit,
				SUM(a.grupo3_hit) AS grupo3_hit, SUM(a.grupo3_no_hit) AS grupo3_no_hit, SUM(grupo5_hit) AS grupo5_hit,SUM(grupo5_no_hit) AS grupo5_no_hit,
				SUM(grupo6_hit) AS grupo6_hit, SUM(grupo6_no_hit) AS grupo6_no_hit, SUM(grupoa_hit) AS grupoa_hit, SUM(grupoa_no_hit) AS grupoa_no_hit, SUM(grupo7_hit) AS grupo7_hit,SUM(grupo7_no_hit) AS grupo7_no_hit,
				SUM(grupo8_hit) AS grupo8_hit,SUM(grupo8_no_hit) AS grupo8_no_hit,
				SUM(a.cantidad_hit) AS total_x_status_hit, SUM(a.cantidad_no_hit) AS total_x_status_no_hit,
				( CASE WHEN iTotal_sol_rep_hit = 0 THEN 0 ELSE ROUND((SUM(a.cantidad_hit) / iTotal_sol_rep_hit) * 100,2) END ) AS porc_status_hit, 
				( CASE WHEN iTotal_sol_rep_no_hit = 0 THEN 0 ELSE ROUND((SUM(a.cantidad_no_hit) / iTotal_sol_rep_no_hit) * 100,2) END ) AS porc_status_no_hit,
				SUM(grupo1_hit+grupo1_no_hit+grupo2_hit+grupo2_no_hit+grupo3_hit+grupo3_no_hit+grupo5_hit+grupo5_no_hit+grupo6_hit+ grupo6_no_hit +grupoa_hit+grupoa_no_hit+grupo7_hit+grupo7_no_hit+grupo8_hit+grupo8_no_hit) AS total_x_status, 
				( CASE WHEN iTotal_sol_rep = 0 THEN 0 ELSE ROUND((SUM(a.cantidad) / iTotal_sol_rep) * 100,2) END ) AS porc_status,
				a.secuencia, pUsuario, iNumSesion
			FROM "informix".ss_grupo_os a 
			WHERE a.estado = pFiltro
			GROUP BY a.valor_alfabetico, a.secuencia;

		ELIF pFiltro = '' THEN

			INSERT INTO "informix".ss_totalsolgrupo(valor_alfabetico, grupo1_hit, grupo1_no_hit, grupo2_hit, grupo2_no_hit, grupo3_hit, grupo3_no_hit,
			 grupo5_hit, grupo5_no_hit, grupo6_hit, grupo6_no_hit, grupoa_hit, grupoa_no_hit, grupo7_hit, grupo7_no_hit,grupo8_hit, grupo8_no_hit, total_x_status_hit, total_x_status_no_hit, porc_status_hit, porc_status_no_hit, total_x_status,
			 porc_status, secuencia, usuario, sesion) 
			SELECT a.valor_alfabetico, SUM(a.grupo1_hit) AS grupo1_hit, SUM(a.grupo1_no_hit) AS grupo1_no_hit,SUM(a.grupo2_hit) AS grupo2_hit,SUM(a.grupo2_no_hit) AS grupo2_no_hit,
				SUM(a.grupo3_hit) AS grupo3_hit,SUM(a.grupo3_no_hit) AS grupo3_no_hit, SUM(grupo5_hit) AS grupo5_hit,SUM(grupo5_no_hit) AS grupo5_no_hit, 
				SUM(grupo6_hit) AS grupo6_hit, SUM(grupo6_no_hit) AS grupo6_no_hit, SUM(grupoa_hit) AS grupoa_hit, SUM(grupoa_no_hit) AS grupoa_no_hit, SUM(grupo7_hit) AS grupo7_hit,SUM(grupo7_no_hit) AS grupo7_no_hit,
				SUM(grupo8_hit) AS grupo8_hit,SUM(grupo8_no_hit) AS grupo8_no_hit,
				SUM(a.cantidad_hit) AS total_x_status_hit,SUM(a.cantidad_no_hit) AS total_x_status_no_hit,
				( CASE WHEN iTotal_sol_rep_hit = 0 THEN 0 ELSE ROUND((SUM(a.cantidad_hit) / iTotal_sol_rep_hit) * 100,2) END ) AS porc_status_hit,
				( CASE WHEN iTotal_sol_rep_no_hit = 0 THEN 0 ELSE ROUND((SUM(a.cantidad_no_hit) / iTotal_sol_rep_no_hit) * 100,2) END ) AS porc_status_no_hit,
				SUM(grupo1_hit+grupo1_no_hit+grupo2_hit+grupo2_no_hit+grupo3_hit+grupo3_no_hit+grupo5_hit+grupo5_no_hit+grupo6_hit+ grupo6_no_hit +grupoa_hit+grupoa_no_hit+grupo7_hit+grupo7_no_hit +grupo8_hit+grupo8_no_hit) AS total_x_status, 
				( CASE WHEN iTotal_sol_rep = 0 THEN 0 ELSE ROUND((SUM(a.cantidad) / iTotal_sol_rep) * 100,2) END ) AS porc_status,
				a.secuencia, pUsuario, iNumSesion
			FROM "informix".ss_grupo_os a 
			GROUP BY a.valor_alfabetico, a.secuencia;

		END IF;

	END IF;

	IF pTpConsulta	 = '02' THEN  ---CIUDAD

		INSERT INTO "informix".ss_totalciudad(ciudad, cantidad, cantidad_hit, cantidad_no_hit)
		SELECT ciudad, SUM(cantidad) total, SUM(cantidad_hit) total_hit, SUM(cantidad_no_hit) total_no_hit
		FROM "informix".ss_grupo_os 
		 WHERE usuario = pUsuario
		 AND sesion  = iNumSesion
	    GROUP BY 1;

		IF pFiltro <> '' THEN
			SELECT SUM(cantidad),SUM(cantidad_hit),SUM(cantidad_no_hit) INTO iTotal_sol_rep,iTotal_sol_rep_hit,iTotal_sol_rep_no_hit FROM "informix".ss_totalciudad 
			WHERE ciudad = LPAD(pFiltro,3,0);
		ELSE
		    SELECT SUM(cantidad),SUM(cantidad_hit),SUM(cantidad_no_hit) INTO iTotal_sol_rep,iTotal_sol_rep_hit,iTotal_sol_rep_no_hit FROM "informix".ss_totalciudad; 
		END IF;

		IF  pFiltro <> '' THEN

			INSERT INTO "informix".ss_totalsolgrupo(valor_alfabetico, grupo1_hit, grupo1_no_hit, grupo2_hit, grupo2_no_hit, grupo3_hit, grupo3_no_hit,
			 grupo5_hit, grupo5_no_hit, grupo6_hit, grupo6_no_hit, grupoa_hit, grupoa_no_hit, grupo7_hit, grupo7_no_hit, grupo8_hit, grupo8_no_hit, total_x_status_hit, total_x_status_no_hit, porc_status_hit, porc_status_no_hit, total_x_status,
			 porc_status, secuencia, usuario, sesion) 
			SELECT a.valor_alfabetico, SUM(a.grupo1_hit) AS grupo1_hit, SUM(a.grupo1_no_hit) AS grupo1_no_hit, SUM(a.grupo2_hit) AS grupo2_hit, SUM(a.grupo2_no_hit) AS grupo2_no_hit,
				SUM(a.grupo3_hit) AS grupo3_hit, SUM(a.grupo3_no_hit) AS grupo3_no_hit, SUM(grupo5_hit) AS grupo5_hit,SUM(grupo5_no_hit) AS grupo5_no_hit,
				SUM(grupo6_hit) AS grupo6_hit, SUM(grupo6_no_hit) AS grupo6_no_hit, SUM(grupoa_hit) AS grupoa_hit, SUM(grupoa_no_hit) AS grupoa_no_hit, SUM(grupo7_hit) AS grupo7_hit,SUM(grupo7_no_hit) AS grupo7_no_hit,
				SUM(grupo8_hit) AS grupo8_hit,SUM(grupo8_no_hit) AS grupo8_no_hit,
				SUM(a.cantidad_hit) AS total_x_status_hit, SUM(a.cantidad_no_hit) AS total_x_status_no_hit,
				( CASE WHEN iTotal_sol_rep_hit = 0 THEN 0 ELSE ROUND((SUM(a.cantidad_hit) / iTotal_sol_rep_hit) * 100,2) END ) AS porc_status_hit, 
				( CASE WHEN iTotal_sol_rep_no_hit = 0 THEN 0 ELSE ROUND((SUM(a.cantidad_no_hit) / iTotal_sol_rep_no_hit) * 100,2) END ) AS porc_status_no_hit,
				SUM(grupo1_hit+grupo1_no_hit+grupo2_hit+grupo2_no_hit+grupo3_hit+grupo3_no_hit+grupo5_hit+grupo5_no_hit+grupo6_hit+ grupo6_no_hit +grupoa_hit+grupoa_no_hit+grupo7_hit+grupo7_no_hit+grupo8_hit+grupo8_no_hit) AS total_x_status, 
				( CASE WHEN iTotal_sol_rep = 0 THEN 0 ELSE ROUND((SUM(a.cantidad) / iTotal_sol_rep) * 100,2) END ) AS porc_status,
				a.secuencia, pUsuario, iNumSesion
			FROM "informix".ss_grupo_os a 
			WHERE a.ciudad = LPAD(pFiltro,3,0)
			GROUP BY a.valor_alfabetico, a.secuencia;

			
		ELIF pFiltro = '' THEN
			
			INSERT INTO "informix".ss_totalsolgrupo(valor_alfabetico, grupo1_hit, grupo1_no_hit, grupo2_hit, grupo2_no_hit, grupo3_hit, grupo3_no_hit,
			 grupo5_hit, grupo5_no_hit, grupo6_hit, grupo6_no_hit, grupoa_hit, grupoa_no_hit, grupo7_hit, grupo7_no_hit, grupo8_hit, grupo8_no_hit, total_x_status_hit, total_x_status_no_hit, porc_status_hit, porc_status_no_hit, total_x_status,
			 porc_status, secuencia, usuario, sesion) 
			SELECT a.valor_alfabetico, SUM(a.grupo1_hit) AS grupo1_hit, SUM(a.grupo1_no_hit) AS grupo1_no_hit,SUM(a.grupo2_hit) AS grupo2_hit,SUM(a.grupo2_no_hit) AS grupo2_no_hit,
				SUM(a.grupo3_hit) AS grupo3_hit,SUM(a.grupo3_no_hit) AS grupo3_no_hit, SUM(grupo5_hit) AS grupo5_hit,SUM(grupo5_no_hit) AS grupo5_no_hit,
				SUM(grupo6_hit) AS grupo6_hit, SUM(grupo6_no_hit) AS grupo6_no_hit, SUM(grupoa_hit) AS grupoa_hit, SUM(grupoa_no_hit) AS grupoa_no_hit, SUM(grupo7_hit) AS grupo7_hit,SUM(grupo7_no_hit) AS grupo7_no_hit,
				SUM(grupo8_hit) AS grupo8_hit,SUM(grupo8_no_hit) AS grupo8_no_hit,
				SUM(a.cantidad_hit) AS total_x_status_hit,SUM(a.cantidad_no_hit) AS total_x_status_no_hit,
				( CASE WHEN iTotal_sol_rep_hit = 0 THEN 0 ELSE ROUND((SUM(a.cantidad_hit) / iTotal_sol_rep_hit) * 100,2) END ) AS porc_status_hit,
				( CASE WHEN iTotal_sol_rep_no_hit = 0 THEN 0 ELSE ROUND((SUM(a.cantidad_no_hit) / iTotal_sol_rep_no_hit) * 100,2) END ) AS porc_status_no_hit,
				SUM(grupo1_hit+grupo1_no_hit+grupo2_hit+grupo2_no_hit+grupo3_hit+grupo3_no_hit+grupo5_hit+grupo5_no_hit+grupo6_hit+ grupo6_no_hit +grupoa_hit+grupoa_no_hit+grupo7_hit+grupo7_no_hit+grupo8_hit+grupo8_no_hit) AS total_x_status, 
				( CASE WHEN iTotal_sol_rep = 0 THEN 0 ELSE ROUND((SUM(a.cantidad) / iTotal_sol_rep) * 100,2) END ) AS porc_status,
				a.secuencia, pUsuario, iNumSesion
			FROM "informix".ss_grupo_os a 
			GROUP BY a.valor_alfabetico, a.secuencia;

			
		END IF;
	
	END IF;
	
	IF pTpConsulta	 = '03' THEN   ---REGION
	
		INSERT INTO "informix".ss_totalregion(region, cantidad, cantidad_hit, cantidad_no_hit)
		SELECT numero_region, SUM(cantidad) total, SUM(cantidad_hit) total_hit, SUM(cantidad_no_hit) total_no_hit 
		FROM "informix".ss_grupo_os 
		 WHERE usuario = pUsuario
		 AND sesion	= iNumSesion
		GROUP BY 1;
		
		IF  pFiltro <> '' THEN
			SELECT SUM(cantidad),SUM(cantidad_hit),SUM(cantidad_no_hit) INTO iTotal_sol_rep,iTotal_sol_rep_hit,iTotal_sol_rep_no_hit FROM "informix".ss_totalregion --total_region
			WHERE region = pFiltro;
		ELSE
		    SELECT SUM(cantidad),SUM(cantidad_hit),SUM(cantidad_no_hit) INTO iTotal_sol_rep,iTotal_sol_rep_hit,iTotal_sol_rep_no_hit FROM "informix".ss_totalregion; --total_region; 
		END IF;
		 
		IF  pFiltro <> '' THEN
			
			INSERT INTO "informix".ss_totalsolgrupo(valor_alfabetico, grupo1_hit, grupo1_no_hit, grupo2_hit, grupo2_no_hit, grupo3_hit, grupo3_no_hit,
			 grupo5_hit, grupo5_no_hit, grupo6_hit, grupo6_no_hit, grupoa_hit, grupoa_no_hit, grupo7_hit, grupo7_no_hit,grupo8_hit, grupo8_no_hit, total_x_status_hit, total_x_status_no_hit, porc_status_hit, porc_status_no_hit, total_x_status,
			 porc_status, secuencia, usuario, sesion) 
			SELECT a.valor_alfabetico, SUM(a.grupo1_hit) AS grupo1_hit, SUM(a.grupo1_no_hit) AS grupo1_no_hit, SUM(a.grupo2_hit) AS grupo2_hit, SUM(a.grupo2_no_hit) AS grupo2_no_hit,
				SUM(a.grupo3_hit) AS grupo3_hit, SUM(a.grupo3_no_hit) AS grupo3_no_hit, SUM(grupo5_hit) AS grupo5_hit,SUM(grupo5_no_hit) AS grupo5_no_hit,
				SUM(grupo6_hit) AS grupo6_hit, SUM(grupo6_no_hit) AS grupo6_no_hit, SUM(grupoa_hit) AS grupoa_hit, SUM(grupoa_no_hit) AS grupoa_no_hit, SUM(grupo7_hit) AS grupo7_hit,SUM(grupo7_no_hit) AS grupo7_no_hit,
				SUM(grupo8_hit) AS grupo8_hit,SUM(grupo8_no_hit) AS grupo8_no_hit,
				SUM(a.cantidad_hit) AS total_x_status_hit, SUM(a.cantidad_no_hit) AS total_x_status_no_hit,
				( CASE WHEN iTotal_sol_rep_hit = 0 THEN 0 ELSE ROUND((SUM(a.cantidad_hit) / iTotal_sol_rep_hit) * 100,2) END ) AS porc_status_hit, 
				( CASE WHEN iTotal_sol_rep_no_hit = 0 THEN 0 ELSE ROUND((SUM(a.cantidad_no_hit) / iTotal_sol_rep_no_hit) * 100,2) END ) AS porc_status_no_hit,
				SUM(grupo1_hit+grupo1_no_hit+grupo2_hit+grupo2_no_hit+grupo3_hit+grupo3_no_hit+grupo5_hit+grupo5_no_hit+grupo6_hit+ grupo6_no_hit +grupoa_hit+grupoa_no_hit+grupo7_hit+grupo7_no_hit+grupo8_hit+grupo8_no_hit) AS total_x_status, 
				( CASE WHEN iTotal_sol_rep = 0 THEN 0 ELSE ROUND((SUM(a.cantidad) / iTotal_sol_rep) * 100,2) END ) AS porc_status,
				a.secuencia, pUsuario, iNumSesion
			FROM "informix".ss_grupo_os a 
			WHERE a.numero_region = pFiltro
			GROUP BY a.valor_alfabetico, a.secuencia;
			
		ELIF pFiltro = '' THEN
			
			INSERT INTO "informix".ss_totalsolgrupo(valor_alfabetico, grupo1_hit, grupo1_no_hit, grupo2_hit, grupo2_no_hit, grupo3_hit, grupo3_no_hit,
			 grupo5_hit, grupo5_no_hit, grupo6_hit, grupo6_no_hit, grupoa_hit, grupoa_no_hit, grupo7_hit, grupo7_no_hit,grupo8_hit, grupo8_no_hit, total_x_status_hit, total_x_status_no_hit, porc_status_hit, porc_status_no_hit, total_x_status,
			 porc_status, secuencia, usuario, sesion) 
			SELECT a.valor_alfabetico, SUM(a.grupo1_hit) AS grupo1_hit, SUM(a.grupo1_no_hit) AS grupo1_no_hit,SUM(a.grupo2_hit) AS grupo2_hit,SUM(a.grupo2_no_hit) AS grupo2_no_hit,
				SUM(a.grupo3_hit) AS grupo3_hit,SUM(a.grupo3_no_hit) AS grupo3_no_hit, SUM(grupo5_hit) AS grupo5_hit,SUM(grupo5_no_hit) AS grupo5_no_hit,
				SUM(grupo6_hit) AS grupo6_hit, SUM(grupo6_no_hit) AS grupo6_no_hit, SUM(grupoa_hit) AS grupoa_hit, SUM(grupoa_no_hit) AS grupoa_no_hit, SUM(grupo7_hit) AS grupo7_hit,SUM(grupo7_no_hit) AS grupo7_no_hit,
				SUM(grupo8_hit) AS grupo8_hit,SUM(grupo8_no_hit) AS grupo8_no_hit,
				SUM(a.cantidad_hit) AS total_x_status_hit,SUM(a.cantidad_no_hit) AS total_x_status_no_hit,
				( CASE WHEN iTotal_sol_rep_hit = 0 THEN 0 ELSE ROUND((SUM(a.cantidad_hit) / iTotal_sol_rep_hit) * 100,2) END ) AS porc_status_hit,
				( CASE WHEN iTotal_sol_rep_no_hit = 0 THEN 0 ELSE ROUND((SUM(a.cantidad_no_hit) / iTotal_sol_rep_no_hit) * 100,2) END ) AS porc_status_no_hit,
				SUM(grupo1_hit+grupo1_no_hit+grupo2_hit+grupo2_no_hit+grupo3_hit+grupo3_no_hit+grupo5_hit+grupo5_no_hit+grupo6_hit+ grupo6_no_hit +grupoa_hit+grupoa_no_hit+grupo7_hit+grupo7_no_hit+grupo8_hit+grupo8_no_hit) AS total_x_status, 
				( CASE WHEN iTotal_sol_rep = 0 THEN 0 ELSE ROUND((SUM(a.cantidad) / iTotal_sol_rep) * 100,2) END ) AS porc_status,
				a.secuencia, pUsuario, iNumSesion
			FROM "informix".ss_grupo_os a 
			GROUP BY a.valor_alfabetico, a.secuencia;
			
		END IF;
		
	END IF;	
	
	INSERT INTO "informix".ss_totalsolgrupo(valor_alfabetico, grupo1_hit, grupo1_no_hit, grupo2_hit, grupo2_no_hit, grupo3_hit, grupo3_no_hit,
	 grupo5_hit, grupo5_no_hit, grupo6_hit, grupo6_no_hit, grupoa_hit, grupoa_no_hit, grupo7_hit, grupo7_no_hit,grupo8_hit, grupo8_no_hit, total_x_status_hit, total_x_status_no_hit, porc_status_hit, porc_status_no_hit, total_x_status,
	 porc_status, secuencia, usuario, sesion) 
	SELECT 'Total' valor_alfabetico, SUM(grupo1_hit) grupo1_hit, SUM(grupo1_no_hit ) grupo1_no_hit, SUM(grupo2_hit) grupo2_hit, SUM(grupo2_no_hit) grupo2_no_hit, SUM(grupo3_hit) grupo3_hit, SUM(grupo3_no_hit) grupo3_no_hit, SUM(grupo5_hit) grupo5_hit, SUM(grupo5_no_hit) grupo5_no_hit, SUM(grupo6_hit) grupo6_hit, SUM(grupo6_no_hit) grupo6_no_hit, SUM(grupoa_hit) grupoa_hit, SUM(grupoa_no_hit) grupoa_no_hit, SUM(grupo7_hit) grupo7_hit, SUM(grupo7_no_hit) grupo7_no_hit,SUM(grupo8_hit) grupo8_hit, SUM(grupo8_no_hit) grupo8_no_hit,
	SUM( grupo1_hit+grupo2_hit+grupo3_hit+grupo5_hit+grupo6_hit+grupoa_hit+grupo7_hit+grupo8_hit) AS total_x_status_hit,
	SUM( grupo1_no_hit+grupo2_no_hit+grupo3_no_hit+grupo5_no_hit+grupo6_no_hit+grupoa_no_hit+grupo7_no_hit+grupo8_no_hit) AS total_x_status_no_hit,	
	(CASE WHEN SUM(porc_status_hit)=0 THEN 0 ELSE ROUND(SUM(porc_status_hit),-1) END) AS porc_status_hit,	
	(CASE WHEN SUM(porc_status_no_hit)=0 THEN 0 ELSE ROUND(SUM(porc_status_no_hit),-1) END) AS porc_status_no_hit ,
	SUM(grupo1_hit + grupo1_no_hit +
		grupo2_hit + grupo2_no_hit +
		grupo3_hit + grupo3_no_hit +
		grupo5_hit + grupo5_no_hit +
		grupo6_hit + grupo6_no_hit +
		grupoa_hit + grupoa_no_hit +
		grupo7_hit + grupo7_no_hit +
		grupo8_hit + grupo8_no_hit) AS total_x_status,
		(CASE WHEN SUM(porc_status) > 100 OR SUM(porc_status) < 100 THEN 100 ELSE SUM(porc_status) END ) AS porc_status ,997 orden_rerpote,
		pUsuario, iNumSesion
	FROM "informix".ss_totalsolgrupo; 
	
	SELECT COUNT(*) INTO sNumRegistros 
	FROM "informix".ss_totalsolgrupo;
	
	
	--GENERAMOS EL REPORTE CON TODOS LOS REGISTROS PROCESADOS.
	IF sNumRegistros > 1 THEN
		FOREACH WITH HOLD
			SELECT valor_alfabetico, grupo1_hit,grupo1_no_hit,grupo2_hit,grupo2_no_hit,grupo3_hit,grupo3_no_hit,grupo5_hit,grupo5_no_hit, grupo6_hit, grupo6_no_hit, grupoa_hit, grupoa_no_hit, grupo7_hit,grupo7_no_hit,grupo8_hit,grupo8_no_hit, total_x_status_hit,total_x_status_no_hit,porc_status_hit,porc_status_no_hit,total_x_status,porc_status
				   INTO vDescripcion, dgrupo1_hit, dgrupo1_no_hit, dgrupo2_hit, dgrupo2_no_hit, dgrupo3_hit, dgrupo3_no_hit, dGrupo5_hit, dGrupo5_no_hit, dGrupo6_hit, dGrupo6_no_hit, dGrupoa_hit, dGrupoa_no_hit, dgrupo7_hit, dgrupo7_no_hit,dgrupo8_hit, dgrupo8_no_hit, dtotal_status_hit,dtotal_status_no_hit,dporc_status_hit,dporc_status_no_hit,dTotalStatus, dTotalGenStatus
			  FROM "informix".ss_totalsolgrupo 
			  ORDER BY secuencia
			 RETURN cCodRet, NVL(TRIM(vMensajeRet),''), NVL(TRIM(vDescripcion),''), NVL(dgrupo1_hit,0), NVL(dgrupo1_no_hit,0), NVL(dgrupo2_hit,0), NVL(dgrupo2_no_hit,0), NVL(dgrupo3_hit,0), NVL(dgrupo3_no_hit,0), NVL(dGrupo5_hit,0), NVL(dGrupo5_no_hit,0), NVL(dGrupo6_hit, 0), NVL(dGrupo6_no_hit, 0), NVL(dGrupoa_hit, 0), NVL(dGrupoa_no_hit, 0), NVL(dgrupo7_hit,0), NVL(dgrupo7_no_hit,0), NVL(dgrupo8_hit,0), NVL(dgrupo8_no_hit,0),NVL(dtotal_status_hit,0), NVL(dtotal_status_no_hit,0), NVL(dporc_status_hit,0), NVL(dporc_status_no_hit,0), NVL(dTotalStatus,0), NVL(dTotalGenStatus,0) WITH RESUME;
		END FOREACH;
		
	ELSE
		
		LET cCodRet = '000006';
		LET vMensajeRet = 'No hay informacion para este producto en este periodo';
		
	END IF
	 
	-- ELIMINAMOS LAS TABLAS TEMPORALES
	IF pTpConsulta = '04' THEN
		
		DELETE FROM "informix".ss_grupo_os WHERE usuario = pUsuario AND sesion = iNumSesion;
		DELETE FROM "informix".ss_totalsolgrupo WHERE usuario = pUsuario AND sesion = iNumSesion;
		DELETE FROM "informix".ss_totalsucursal;	
	ELIF pTpConsulta = '01' THEN
	
		DELETE FROM "informix".ss_grupo_os WHERE usuario = pUsuario AND sesion = iNumSesion;
		DELETE FROM "informix".ss_totalsolgrupo WHERE usuario = pUsuario AND sesion = iNumSesion;
		DELETE FROM "informix".ss_totalestado;
	ELIF pTpConsulta = '02' THEN
	
		DELETE FROM "informix".ss_grupo_os WHERE usuario = pUsuario AND sesion = iNumSesion;
		DELETE FROM "informix".ss_totalsolgrupo WHERE usuario = pUsuario AND sesion = iNumSesion;
		DELETE FROM "informix".ss_totalciudad;	
	ELIF pTpConsulta = '03' THEN
		
		DELETE FROM "informix".ss_grupo_os WHERE usuario = pUsuario AND sesion = iNumSesion;
		DELETE FROM "informix".ss_totalsolgrupo WHERE usuario = pUsuario AND sesion = iNumSesion;
		DELETE FROM "informix".ss_totalregion;		
	END IF;
	
		
	IF cCodRet <> '000000' THEN 
	   RETURN cCodRet, vMensajeRet, vDescripcion, dgrupo1_hit, dgrupo1_no_hit, dgrupo2_hit, dgrupo2_no_hit,dgrupo3_hit, dgrupo3_no_hit, dGrupo5_hit, dGrupo5_no_hit, dGrupo6_hit, dGrupo6_no_hit, dGrupoa_hit, dGrupoa_no_hit, dgrupo7_hit, dgrupo7_no_hit,dgrupo8_hit, dgrupo8_no_hit, dtotal_status_hit,dtotal_status_no_hit,dporc_status_hit,dporc_status_no_hit,dTotalStatus, dTotalGenStatus;
	END IF
	
END
END PROCEDURE

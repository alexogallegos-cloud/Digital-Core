CREATE PROCEDURE "informix".sp_consulctesbitacoraprecal(pEmpresa     CHAR(3),
														pTpConsulta  CHAR(2),
														pFiltro      VARCHAR(4),
														pProducto    CHAR(4),
														pFechaIni    DATE, 
														pFechaFin    DATE,
														pCausa       CHAR(1),
														pConsxcdedo  CHAR(2))
RETURNING
		CHAR(6)			AS cod_ret,
		VARCHAR(80,1)		AS mensaje_ret,
		VARCHAR(200,1)	AS descripcion_status,
		VARCHAR(3,1)		AS status_sol,
		DECIMAL(18,2)		AS grupo1,
		DECIMAL(18,2)		AS grupo2,
		DECIMAL(18,2)		AS grupo3,
		DECIMAL(18,2)		AS grupo5,
        DECIMAL(18,2)		AS grupo8,
		DECIMAL(18,2)		AS total_x_status,
		DECIMAL(18,2)		AS porc_status,
		CHAR(1)			AS tiene_causas;

-- * Retornos de grupos: 
	--		grupo1 - Clientes coppel >=13 meses y eficiencia >= 85 %
	--		grupo2 - Clientes coppel de 6 a 12 meses con eficiencia >= 85%
	--		grupo3 - Clientes nuevos

DEFINE iSqlErr			INTEGER;
DEFINE iIsamErr			INTEGER;
DEFINE cErrorInfo		CHAR(80);
DEFINE cCodRet			CHAR(6);
DEFINE cMensajeRet		VARCHAR(80,1);
DEFINE cEmpresa			CHAR(3);
DEFINE cCausaSol		CHAR(3);
DEFINE cBanTmp			CHAR(1);
DEFINE cCriterio		VARCHAR(200,1);
DEFINE cTieneCausa		CHAR(1);
DEFINE dGrupo1			DECIMAL(18,2);
DEFINE dGrupo2			DECIMAL(18,2);
DEFINE dGrupo3			DECIMAL(18,2);
DEFINE dGrupo5			DECIMAL(18,2);
DEFINE dGrupo8			DECIMAL(18,2);
DEFINE dTotalStatus		DECIMAL(18,2);
DEFINE dPorcStatus		DECIMAL(18,2);
DEFINE cGpoPrecal		CHAR(1);
DEFINE dTotalGrupo1		DECIMAL(18,2);
DEFINE dTotalGrupo2		DECIMAL(18,2);
DEFINE dTotalGrupo3		DECIMAL(18,2);
DEFINE dTotalGenStatus	DECIMAL(18,2);
DEFINE dPorcGenStatus	DECIMAL(18,2);   
DEFINE total_precal		INTEGER;
DEFINE num_registros	INTEGER; 

LET iSqlErr				=  0;
LET iIsamErr			= 0;
LET cErrorInfo			= "";
LET cCodRet				= "000000";
LET cMensajeRet			= "Proceso realizado con Ã©xito";
LET cEmpresa			= "";
LET cCausaSol			= "";
LET cBanTmp				= "N";
LET cCriterio			= "";
LET cTieneCausa			= "0";
LET dGrupo1				= 0;
LET dGrupo2				= 0;
LET dGrupo3				= 0;
LET dGrupo5				= 0;
LET dGrupo8             = 0;
LET dTotalStatus		= 0;
LET dPorcStatus			= 0;
LET cGpoPrecal			= "";
LET dTotalGrupo1		= 0;
LET dTotalGrupo2		= 0;
LET dTotalGrupo3		= 0;
LET dTotalGenStatus		= 0;
LET dPorcGenStatus		= 0;
LET total_precal		= 0;
LET num_registros		=0;

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
	IF iSqlErr != 0 THEN
		IF cBanTmp = "S" THEN
			DROP TABLE bdisolic:precal1;
			DROP TABLE bdisolic:precal2;
			DROP TABLE bdisolic:total_precal_group;
		END IF;
		LET cCodRet= iSqlErr;
		LET cMensajeRet= cErrorInfo;
		RETURN cCodRet, cMensajeRet, cCriterio, cCausaSol, dGrupo1, dGrupo2, dGrupo3,dGrupo5, dGrupo8, 
               dTotalStatus,dTotalGenStatus, cTieneCausa;
	END IF;
END EXCEPTION;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;
---SET pdqpriority 10;

		--SET DEBUG FILE TO '/ifxsif01/Male/RQM10679-2/Bdisolic/sp_consulctesbitacoraprecal.out';
		--TRACE ON;

IF NVL(pEmpresa,'') = '' THEN
	LET cCodRet     = '000001';
	LET cMensajeRet = 'Es necesario indicar la empresa para ejecutar el proceso';
	RETURN cCodRet, cMensajeRet, cCriterio, cCausaSol, dGrupo1, dGrupo2, dGrupo3,dGrupo5, dGrupo8, 
           dTotalStatus,dTotalGenStatus, cTieneCausa;
END IF;

SELECT empresa 
INTO cEmpresa
FROM bdinteg:si_empresas
WHERE empresa = pEmpresa;

IF NVL(cEmpresa,'') = '' THEN
	LET cCodRet     = '000002';
	LET cMensajeRet = 'La empresa indicada no es vÃ¡lida';
	RETURN cCodRet, cMensajeRet, cCriterio, cCausaSol, dGrupo1, dGrupo2, dGrupo3,dGrupo5, dGrupo8, 
           dTotalStatus,dTotalGenStatus, cTieneCausa;
END IF;

IF NVL(pTpConsulta,"") = "" THEN
	LET cCodRet = "000003";
	LET cMensajeRet = "Es necesario indicar el tipo de consulta a realizar";   
	RETURN cCodRet, cMensajeRet, cCriterio, cCausaSol, dGrupo1, dGrupo2, dGrupo3,dGrupo5, dGrupo8, 
           dTotalStatus,dTotalGenStatus, cTieneCausa;
END IF;

IF NVL(pFechaIni,"") = "" AND NVL(pFechaFin, "") = "" THEN
	LET cCodRet = "000004";
	LET cMensajeRet = "Es necesario indicar al menos una fecha";
	RETURN cCodRet, cMensajeRet, cCriterio, cCausaSol, dGrupo1, dGrupo2, dGrupo3,dGrupo5, dGrupo8, 
           dTotalStatus,dTotalGenStatus, cTieneCausa;
END IF;

IF (NVL(pFechaIni,"") <> "" AND NVL(pFechaFin, "") <> "") AND (pFechaIni > pFechaFin) THEN
	LET cCodRet = "000005";
	LET cMensajeRet = "La fecha inicial no debe ser mayor a la fecha final";
	RETURN cCodRet, cMensajeRet, cCriterio, cCausaSol, dGrupo1, dGrupo2, dGrupo3,dGrupo5, dGrupo8, 
           dTotalStatus,dTotalGenStatus, cTieneCausa;
END IF;

IF NVL(pProducto,"") = "" THEN
	LET cCodRet = "000006";
	LET cMensajeRet = "Es necesario indicar el producto para realizar la consulta";
	RETURN cCodRet, cMensajeRet, cCriterio, cCausaSol, dGrupo1, dGrupo2, dGrupo3,dGrupo5, dGrupo8, 
           dTotalStatus,dTotalGenStatus, cTieneCausa;
END IF;

IF pFechaIni IS NULL THEN 
	LET pFechaIni = DATE(1);
END IF;

IF pFechaFin IS NULL THEN 
	LET pFechaFin = pFechaIni;
END IF;

LET cBanTmp = "S";

--SET DEBUG FILE TO "/tmp/bitacora_precal.out";
--TRACE ON;

IF pTpConsulta = '06' THEN --RQM 10 679-2 Agregar filtro Canal de Solicitud
	CREATE temp TABLE precal1
	(causa_solicitud CHAR(3), 
	sucursal CHAR(4), 
	situacion CHAR(1),
	canal_sol CHAR(1),
	grupo1 INTEGER,
	grupo2 INTEGER,
	grupo3 INTEGER,
	grupo5 INTEGER,
	grupo8 INTEGER,
	cantidad INTEGER) WITH NO LOG;
		INSERT INTO precal1
		SELECT a.causa_solicitud, a.sucursal, a.situacion, NVL(b.canal_sol,0),
		SUM(CASE WHEN  meses_hist >= 13 AND porcentaje >= 0 AND NVL(grupo,'') NOT IN ('8') THEN 1 ELSE 0 END) grupo1, 
		SUM(CASE WHEN  meses_hist >= 6 AND meses_hist < 13 AND porcentaje >= 0 AND NVL(grupo,'') NOT IN ('8') THEN 1 ELSE 0 END) grupo2,
		SUM(CASE WHEN  (meses_hist > 0 AND meses_hist < 6 AND porcentaje >= 0) AND NVL(grupo,'') NOT IN ('8') THEN 1 ELSE 0 END) grupo3,
		SUM(CASE WHEN  ((meses_hist = 0 AND porcentaje = 0 ) OR ( porcentaje < 0 )) AND NVL(grupo,'') NOT IN ('8') THEN 1 ELSE 0 END) grupo5,
        SUM(CASE WHEN  grupo = '8' THEN 1 ELSE 0 END) grupo8,
		SUM(CASE WHEN  meses_hist >= 13 AND porcentaje >= 0 AND NVL(grupo,'') NOT IN ('8') THEN 1 ELSE 0 END) +
		SUM(CASE WHEN  meses_hist >= 6 AND meses_hist < 13 AND porcentaje >= 0 AND NVL(grupo,'') NOT IN ('8') THEN 1 ELSE 0 END) +
		SUM(CASE WHEN  (meses_hist > 0 AND meses_hist < 6 AND porcentaje >= 0) AND NVL(grupo,'') NOT IN ('8') THEN 1 ELSE 0 END) +
		SUM(CASE WHEN  ((meses_hist = 0 AND porcentaje = 0 ) OR ( porcentaje < 0 )) AND NVL(grupo,'') NOT IN ('8') THEN 1 ELSE 0 END) +
        SUM(CASE WHEN  grupo = '8' THEN 1 ELSE 0 END) cantidad
		FROM bdisolic:ss_bitacora_precal a
		LEFT OUTER JOIN bdisolic:ss_solicitudes b ON (a.sucursal = b.sucursal AND status_solicitud ='RT' AND a.fecha = b.fecha_insert)
		WHERE a.empresa = pEmpresa
		  AND a.producto = 	pProducto
		  AND a.fecha >= pFechaIni     
		  AND a.fecha <= pFechaFin
		GROUP BY 1,2,3,4; --INTO temp precal1 WITH NO LOG;
ELSE
	CREATE temp TABLE precal1
	(causa_solicitud CHAR(3), 
	sucursal CHAR(4), 
	situacion CHAR(1),
	grupo1 INTEGER,
	grupo2 INTEGER,
	grupo3 INTEGER,
	grupo5 INTEGER,
	grupo8 INTEGER,
	cantidad INTEGER) WITH NO LOG;
		INSERT INTO precal1
		SELECT a.causa_solicitud, a.sucursal, a.situacion,
		SUM(CASE WHEN  meses_hist >= 13 AND porcentaje >= 0 AND NVL(grupo,'') NOT IN ('8') THEN 1 ELSE 0 END) grupo1, 
		SUM(CASE WHEN  meses_hist >= 6 AND meses_hist < 13 AND porcentaje >= 0 AND NVL(grupo,'') NOT IN ('8') THEN 1 ELSE 0 END) grupo2,
		SUM(CASE WHEN  (meses_hist > 0 AND meses_hist < 6 AND porcentaje >= 0) AND NVL(grupo,'') NOT IN ('8') THEN 1 ELSE 0 END) grupo3,
		SUM(CASE WHEN  ((meses_hist = 0 AND porcentaje = 0 ) OR ( porcentaje < 0 )) AND NVL(grupo,'') NOT IN ('8') THEN 1 ELSE 0 END) grupo5,
        SUM(CASE WHEN  grupo = '8' THEN 1 ELSE 0 END) grupo8,
		SUM(CASE WHEN  meses_hist >= 13 AND porcentaje >= 0 AND NVL(grupo,'') NOT IN ('8') THEN 1 ELSE 0 END) +
		SUM(CASE WHEN  meses_hist >= 6 AND meses_hist < 13 AND porcentaje >= 0 AND NVL(grupo,'') NOT IN ('8') THEN 1 ELSE 0 END) +
		SUM(CASE WHEN  (meses_hist > 0 AND meses_hist < 6 AND porcentaje >= 0) AND NVL(grupo,'') NOT IN ('8') THEN 1 ELSE 0 END) +
		SUM(CASE WHEN  ((meses_hist = 0 AND porcentaje = 0 ) OR ( porcentaje < 0 )) AND NVL(grupo,'') NOT IN ('8') THEN 1 ELSE 0 END) +
        SUM(CASE WHEN  grupo = '8' THEN 1 ELSE 0 END) cantidad
		FROM bdisolic:ss_bitacora_precal a
		WHERE a.empresa = pEmpresa
		  AND a.producto = 	pProducto
		  AND a.fecha >= pFechaIni     
		  AND a.fecha <= pFechaFin
		GROUP BY 1,2,3; --INTO temp precal1 WITH NO LOG;
/*
		SELECT a.causa_solicitud, a.sucursal, a.situacion,
		SUM(CASE WHEN  meses_hist >= 13 AND porcentaje >= 85 THEN 1 ELSE 0 END) grupo1, 
		SUM(CASE WHEN  meses_hist >= 6 AND meses_hist < 13 THEN 1 ELSE 0 END) grupo2,
		SUM(CASE WHEN  ((meses_hist < 6 AND meses_hist <> 0)) OR porcentaje < 0 THEN 1 ELSE 0 END) grupo3,
		SUM(CASE WHEN  meses_hist >= 13 AND porcentaje < 85 AND porcentaje >= 0 THEN 1 ELSE 0 END) grupo4, 
		SUM(CASE WHEN  meses_hist = 0 AND porcentaje = 0 is null THEN 1 ELSE 0 END) grupo5,
		SUM(CASE WHEN  producto is null THEN 1 ELSE 0 END) grupo5,
		count(*) cantidad
		FROM bdisolic:ss_bitacora_precal a
		WHERE a.empresa = pEmpresa
		  AND a.producto = 	pProducto
		  AND a.fecha >= pFechaIni     
		  AND a.fecha <= pFechaFin
		GROUP BY 1,2,3 INTO temp precal1 WITH NO LOG;
*/
END IF;
IF pTpConsulta = '06' THEN --RQM 10 679-2 Agregar filtro Canal de Solicitud
	CREATE temp TABLE precal2
	(
	descripcion CHAR(100),
	orden_reporte SMALLINT,
	status_solicitud CHAR(5),
	causa_solicitud CHAR(3), 
	sucursal CHAR(4), 
	situacion CHAR(1),
	canal_sol CHAR(1),		
	grupo1 INTEGER,
	grupo2 INTEGER,
	grupo3 INTEGER,
	grupo5 INTEGER,
	grupo8 INTEGER,
	cantidad INTEGER,	
	ciudad CHAR(3), 
	estado CHAR(2), 
	numero_region SMALLINT
	) WITH NO LOG;
			INSERT INTO precal2
			SELECT d.descripcion,b.orden_reporte,b.status_solicitud,a.*, 
					c.ciudad, c.estado, r.numero_region
			 FROM precal1 a, bdisolic:ss_status_sol b, bdisolic:ss_causas_sol d, bdinteg:si_sucursales s,
					bdinteg:si_ciudades c , bdinteg:si_catciudades t, bdinteg:si_regiones r
			WHERE   b.empresa          = pEmpresa
				AND b.status_solicitud = d.status_solicitud
				AND b.status_solicitud IN('RP')
				AND a.causa_solicitud = d.causa_solicitud
				AND b.activa_reporte = d.activa_reporte
				AND b.activa_reporte = "1"
				AND a.sucursal = s.sucursal
				AND s.tpo_sucursal      = "S"
				AND s.ciudad            = c.ciudad
				AND s.pais              = c.pais
				AND s.estado            = c.estado
				AND c.ciudad_coppel     = t.numerociudad
				AND t.numero_region     = r.numero_region;

ELSE
	CREATE temp TABLE precal2
	(
	descripcion CHAR(100),
	orden_reporte SMALLINT,
	status_solicitud CHAR(5),
	causa_solicitud CHAR(3), 
	sucursal CHAR(4), 
	situacion CHAR(1),
	grupo1 INTEGER,
	grupo2 INTEGER,
	grupo3 INTEGER,
	grupo5 INTEGER,
	grupo8 INTEGER,
	cantidad INTEGER,
	ciudad CHAR(3), 
	estado CHAR(2), 
	numero_region SMALLINT
	) WITH NO LOG;
			INSERT INTO precal2
			SELECT d.descripcion,b.orden_reporte,b.status_solicitud,a.*, 
					c.ciudad, c.estado, r.numero_region
			 FROM precal1 a, bdisolic:ss_status_sol b, bdisolic:ss_causas_sol d, bdinteg:si_sucursales s,
					bdinteg:si_ciudades c , bdinteg:si_catciudades t, bdinteg:si_regiones r
			WHERE   b.empresa          = pEmpresa
				AND b.status_solicitud = d.status_solicitud
				AND b.status_solicitud IN('RP')
				AND a.causa_solicitud = d.causa_solicitud
				AND b.activa_reporte = d.activa_reporte
				AND b.activa_reporte = "1"
				AND a.sucursal = s.sucursal
				AND s.tpo_sucursal      = "S"
				AND s.ciudad            = c.ciudad
				AND s.pais              = c.pais
				AND s.estado            = c.estado
				AND c.ciudad_coppel     = t.numerociudad
				AND t.numero_region     = r.numero_region;
			--INTO temp precal2 WITH NO LOG;
END IF;		

CREATE temp TABLE total_precal_group
(
descripcion CHAR(100),
causa_solicitud CHAR(3), 
grupo1 INTEGER,
grupo2 INTEGER,
grupo3 INTEGER,
grupo5 INTEGER,
grupo8 INTEGER,
total_x_status INTEGER,
porc_status DECIMAL (18,2),
orden_reporte SMALLINT,  
sit_esp SMALLINT
) WITH NO LOG;	

		IF pTpConsulta IN('04','01','02','03') AND pFiltro = '' AND pCausa = '' THEN

			select SUM(cantidad) INTO total_precal FROM precal2;
			INSERT INTO total_precal_group
			SELECT a.descripcion,a.causa_solicitud,SUM(a.grupo1) AS grupo1,SUM(a.grupo2) AS grupo2,
			SUM(a.grupo3) AS grupo3,SUM(a.grupo5) AS grupo5,SUM(a.grupo8) AS grupo8,
			SUM(a.cantidad) AS total_x_status,ROUND((SUM(a.cantidad) / total_precal) * 100,2) AS porc_status,
			b.orden_reporte, CASE WHEN a.causa_solicitud = 'SE' THEN 1 ELSE 0 END AS sit_esp
			FROM precal2 a, bdisolic:ss_causas_sol b
			WHERE a.causa_solicitud = b.causa_solicitud
			AND a.status_solicitud=b.status_solicitud
			GROUP BY a.descripcion,a.causa_solicitud,b.orden_reporte;
			--ORDER BY b.orden_reporte;
			--INTO temp total_precal_group WITH NO LOG;	

		ELIF pTpConsulta = '04' AND pFiltro <> '' AND pCausa = '' THEN

			select SUM(cantidad) INTO total_precal FROM precal2 
			WHERE sucursal = 	pFiltro;
			INSERT INTO total_precal_group
			SELECT a.descripcion,a.causa_solicitud,SUM(a.grupo1) AS grupo1,SUM(a.grupo2) AS grupo2,
			SUM(a.grupo3) AS grupo3,SUM(a.grupo5) AS grupo5, SUM(a.grupo8) AS grupo8,
			SUM(a.cantidad) AS total_x_status,ROUND((SUM(a.cantidad) / total_precal) * 100,2) AS porc_status,
			b.orden_reporte, CASE WHEN a.causa_solicitud = 'SE' THEN 1 ELSE 0 END AS sit_esp
			FROM precal2 a, bdisolic:ss_causas_sol b
			WHERE a.causa_solicitud = b.causa_solicitud
			AND a.sucursal = 	pFiltro
			GROUP BY a.descripcion,a.causa_solicitud,b.orden_reporte;
			--ORDER BY b.orden_reporte;
			--INTO temp total_precal_group WITH NO LOG;

		ELIF pTpConsulta = '01' AND pFiltro <> '' AND pCausa = '' THEN

			select SUM(cantidad) INTO total_precal FROM precal2 
			WHERE estado = pFiltro;
			
			INSERT INTO total_precal_group
			SELECT a.descripcion,a.causa_solicitud,SUM(a.grupo1) AS grupo1,SUM(a.grupo2) AS grupo2,
			SUM(a.grupo3) AS grupo3,SUM(a.grupo5) AS grupo5, SUM(a.grupo8) AS grupo8,
			SUM(a.cantidad) AS total_x_status,ROUND((SUM(a.cantidad) / total_precal) * 100,2) AS porc_status,
			b.orden_reporte, CASE WHEN a.causa_solicitud = 'SE' THEN 1 ELSE 0 END AS sit_esp
			FROM precal2 a, bdisolic:ss_causas_sol b
			WHERE a.causa_solicitud = b.causa_solicitud
			  AND a.estado = 	pFiltro
			GROUP BY a.descripcion,a.causa_solicitud,b.orden_reporte;
			--ORDER BY b.orden_reporte;
			--INTO temp total_precal_group WITH NO LOG;

		ELIF pTpConsulta = '02' AND pFiltro <> '' AND pCausa = '' THEN

			select SUM(cantidad) INTO total_precal FROM precal2 
			WHERE estado = pConsxcdedo AND ciudad = LPAD(pFiltro,3,0);

			INSERT INTO total_precal_group
			SELECT a.descripcion,a.causa_solicitud,SUM(a.grupo1) AS grupo1,SUM(a.grupo2) AS grupo2,
			SUM(a.grupo3) AS grupo3,SUM(a.grupo5) AS grupo5, SUM(a.grupo8) AS grupo8,
			SUM(a.cantidad) AS total_x_status,ROUND((SUM(a.cantidad) / total_precal) * 100,2) AS porc_status,
			b.orden_reporte, CASE WHEN a.causa_solicitud = 'SE' THEN 1 ELSE 0 END AS sit_esp
			FROM precal2 a, bdisolic:ss_causas_sol b
			WHERE a.causa_solicitud = b.causa_solicitud
			AND a.estado = pConsxcdedo
			AND a.ciudad = LPAD(pFiltro,3,0)
			GROUP BY a.descripcion,a.causa_solicitud,b.orden_reporte;
			--ORDER BY b.orden_reporte;
			--INTO temp total_precal_group WITH NO LOG;

		ELIF pTpConsulta = '03' AND pFiltro <> '' AND pCausa = '' THEN

			select SUM(cantidad) INTO total_precal FROM precal2 
			WHERE numero_region = pFiltro;
			INSERT INTO total_precal_group
			SELECT a.descripcion,a.causa_solicitud,SUM(a.grupo1) AS grupo1,SUM(a.grupo2) AS grupo2,
			SUM(a.grupo3) AS grupo3,SUM(a.grupo5) AS grupo5,SUM(a.grupo8) AS grupo8,
			SUM(a.cantidad) AS total_x_status,ROUND((SUM(a.cantidad) / total_precal) * 100,2) AS porc_status,
			b.orden_reporte, CASE WHEN a.causa_solicitud = 'SE' THEN 1 ELSE 0 END AS sit_esp
			FROM precal2 a, bdisolic:ss_causas_sol b
			WHERE a.causa_solicitud = b.causa_solicitud
			  AND a.numero_region = pFiltro
			GROUP BY a.descripcion,a.causa_solicitud,b.orden_reporte;
			--ORDER BY b.orden_reporte;
			--INTO temp total_precal_group WITH NO LOG;
		ELIF pTpConsulta = '06' AND pFiltro <> '' AND pCausa = '' THEN --RQM 10 679-2 Se agrega filtro canal_sol

			select SUM(cantidad) INTO total_precal FROM precal2 
			WHERE canal_sol = 	pFiltro;
			
			INSERT INTO total_precal_group
			SELECT a.descripcion,a.causa_solicitud,SUM(a.grupo1) AS grupo1,SUM(a.grupo2) AS grupo2,
			SUM(a.grupo3) AS grupo3,SUM(a.grupo5) AS grupo5, SUM(a.grupo8) AS grupo8,
			SUM(a.cantidad) AS total_x_status,ROUND((SUM(a.cantidad) / total_precal) * 100,2) AS porc_status,
			b.orden_reporte, CASE WHEN a.causa_solicitud = 'SE' THEN 1 ELSE 0 END AS sit_esp
			FROM precal2 a, bdisolic:ss_causas_sol b
			WHERE a.causa_solicitud = b.causa_solicitud
			AND a.canal_sol = 	pFiltro
			GROUP BY a.descripcion,a.causa_solicitud,b.orden_reporte;		
			
		END IF;

			IF pTpConsulta IN('04','01','02','03') AND pFiltro = '' AND pCausa <> '' THEN

				select SUM(cantidad) INTO total_precal FROM precal2
				WHERE causa_solicitud = 'SE';
				INSERT INTO total_precal_group
				SELECT c.descripcion,c.situacion,SUM(a.grupo1) AS grupo1,SUM(a.grupo2) AS grupo2,
				SUM(a.grupo3) AS grupo3,SUM(a.grupo5) AS grupo5,SUM(a.grupo8) AS grupo8,
				SUM(a.cantidad) AS total_x_status,ROUND((SUM(a.cantidad) / total_precal) * 100,2) AS porc_status,
				b.orden_reporte,'0' AS sit_esp
				FROM precal2 a, bdisolic:ss_causas_sol b,bdicred:sd_situacion_cred c
				WHERE a.causa_solicitud = b.causa_solicitud
				AND a.causa_solicitud = 'SE'
				AND a.situacion = c.situacion
				GROUP BY c.descripcion,c.situacion,b.orden_reporte;
				--ORDER BY b.orden_reporte;
				--INTO temp total_precal_group WITH NO LOG;
				
			ELIF pTpConsulta = '06' AND pFiltro <> '' AND pCausa <> '' THEN

				select SUM(cantidad) INTO total_precal FROM precal2
				WHERE causa_solicitud = 'SE' AND canal_sol = pFiltro;
				INSERT INTO total_precal_group
				SELECT c.descripcion,c.situacion,SUM(a.grupo1) AS grupo1,SUM(a.grupo2) AS grupo2,
				SUM(a.grupo3) AS grupo3,SUM(a.grupo5) AS grupo5,SUM(a.grupo8) AS grupo8,
				SUM(a.cantidad) AS total_x_status,ROUND((SUM(a.cantidad) / total_precal) * 100,2) AS porc_status,
				b.orden_reporte,'0' AS sit_esp
				FROM precal2 a, bdisolic:ss_causas_sol b,bdicred:sd_situacion_cred c
				WHERE a.causa_solicitud = b.causa_solicitud
				AND a.causa_solicitud = 'SE'
				AND a.situacion = c.situacion
				AND a.canal_sol = 	pFiltro
				GROUP BY c.descripcion,c.situacion,b.orden_reporte; 
				
			ELIF pTpConsulta = '04' AND pFiltro <> '' AND pCausa <> '' THEN

				select SUM(cantidad) INTO total_precal FROM precal2
				WHERE causa_solicitud = 'SE' AND sucursal = pFiltro;
				INSERT INTO total_precal_group
				SELECT c.descripcion,c.situacion,SUM(a.grupo1) AS grupo1,SUM(a.grupo2) AS grupo2,
				SUM(a.grupo3) AS grupo3,SUM(a.grupo5) AS grupo5,SUM(a.grupo8) AS grupo8,
				SUM(a.cantidad) AS total_x_status,ROUND((SUM(a.cantidad) / total_precal) * 100,2) AS porc_status,
				b.orden_reporte,'0' AS sit_esp
				FROM precal2 a, bdisolic:ss_causas_sol b,bdicred:sd_situacion_cred c
				WHERE a.causa_solicitud = b.causa_solicitud
				AND a.causa_solicitud = 'SE'
				AND a.situacion = c.situacion
				AND a.sucursal = 	pFiltro
				GROUP BY c.descripcion,c.situacion,b.orden_reporte; 
				--ORDER BY b.orden_reporte;
				--INTO temp total_precal_group WITH NO LOG;

			ELIF pTpConsulta = '03' AND pFiltro <> '' AND pCausa <> '' THEN

				select SUM(cantidad) INTO total_precal FROM precal2
				WHERE causa_solicitud = 'SE' AND numero_region = pFiltro;
				INSERT INTO total_precal_group
				SELECT c.descripcion,c.situacion,SUM(a.grupo1) AS grupo1,SUM(a.grupo2) AS grupo2,
				SUM(a.grupo3) AS grupo3,SUM(a.grupo5) AS grupo5,SUM(a.grupo8) AS grupo8,
				SUM(a.cantidad) AS total_x_status,ROUND((SUM(a.cantidad) / total_precal) * 100,2) AS porc_status,
				b.orden_reporte,'0' AS sit_esp
				FROM precal2 a, bdisolic:ss_causas_sol b,bdicred:sd_situacion_cred c
				WHERE a.causa_solicitud = b.causa_solicitud
				AND a.causa_solicitud = 'SE'
				AND a.situacion = c.situacion
				AND a.numero_region = pFiltro
				GROUP BY c.descripcion,c.situacion,b.orden_reporte;
				--ORDER BY b.orden_reporte;
				--INTO temp total_precal_group WITH NO LOG;

			ELIF pTpConsulta = '01' AND pFiltro <> '' AND pCausa <> '' THEN

				select SUM(cantidad) INTO total_precal FROM precal2
				WHERE causa_solicitud = 'SE' AND estado = 	pFiltro;
				INSERT INTO total_precal_group
				SELECT c.descripcion,c.situacion,SUM(a.grupo1) AS grupo1,SUM(a.grupo2) AS grupo2,
				SUM(a.grupo3) AS grupo3,SUM(a.grupo5) AS grupo5,SUM(a.grupo8) AS grupo8,
				SUM(a.cantidad) AS total_x_status,ROUND((SUM(a.cantidad) / total_precal) * 100,2) AS porc_status,
				b.orden_reporte,'0' AS sit_esp
				FROM precal2 a, bdisolic:ss_causas_sol b,bdicred:sd_situacion_cred c
				WHERE a.causa_solicitud = b.causa_solicitud
				AND a.causa_solicitud = 'SE'
				AND a.situacion = c.situacion
				AND a.estado = 	pFiltro
				GROUP BY c.descripcion,c.situacion,b.orden_reporte;
				--ORDER BY b.orden_reporte;
				--INTO temp total_precal_group WITH NO LOG;

			ELIF pTpConsulta = '02' AND pFiltro <> '' AND pCausa <> '' AND pConsxcdedo <> '' THEN

				SELECT SUM(cantidad) INTO total_precal FROM precal2
				WHERE causa_solicitud = 'SE' AND estado = pConsxcdedo
				AND ciudad = LPAD(pFiltro,3,0);	
				INSERT INTO total_precal_group
				SELECT c.descripcion,c.situacion,SUM(a.grupo1) AS grupo1,SUM(a.grupo2) AS grupo2,
				SUM(a.grupo3) AS grupo3,SUM(a.grupo5) AS grupo5, SUM(a.grupo8) AS grupo8,
				SUM(a.cantidad) AS total_x_status,ROUND((SUM(a.cantidad) / total_precal) * 100,2) AS porc_status,
				b.orden_reporte,'0' AS sit_esp
				FROM precal2 a, bdisolic:ss_causas_sol b,bdicred:sd_situacion_cred c
				WHERE a.causa_solicitud = b.causa_solicitud
				  AND a.causa_solicitud = 'SE'
				  AND a.situacion = c.situacion
				  AND a.estado = pConsxcdedo
				  AND a.ciudad = LPAD(pFiltro,3,0)
				GROUP BY c.descripcion,c.situacion,b.orden_reporte;
				--ORDER BY b.orden_reporte;
				--INTO temp total_precal_group WITH NO LOG;
			END IF;

		INSERT INTO total_precal_group
		SELECT 'Total Solicitudes','',SUM(grupo1),SUM(grupo2),SUM(grupo3),SUM(grupo5),SUM(grupo8),
				SUM(grupo1+grupo2+grupo3+grupo5+grupo8), SUM(porc_status),'998','0'
		FROM total_precal_group;

		INSERT INTO total_precal_group
		SELECT '% de Solicitudes','',
				ROUND(SUM(grupo1)/SUM(grupo1+grupo2+grupo3+grupo5+grupo8),2) * 100,
				ROUND(SUM(grupo2)/SUM(grupo1+grupo2+grupo3+grupo5+grupo8),2) * 100,
				ROUND(SUM(grupo3)/SUM(grupo1+grupo2+grupo3+grupo5+grupo8),2) * 100,
				ROUND(SUM(grupo5)/SUM(grupo1+grupo2+grupo3+grupo5+grupo8),2) * 100,
                            ROUND(SUM(grupo8)/SUM(grupo1+grupo2+grupo3+grupo5+grupo8),2) * 100,
				ROUND(SUM(grupo1)/SUM(grupo1+grupo2+grupo3+grupo5+grupo8),2) * 100 +
				ROUND(SUM(grupo2)/SUM(grupo1+grupo2+grupo3+grupo5+grupo8),2) * 100 +
				ROUND(SUM(grupo3)/SUM(grupo1+grupo2+grupo3+grupo5+grupo8),2) * 100 +
				ROUND(SUM(grupo5)/SUM(grupo1+grupo2+grupo3+grupo5+grupo8),2) * 100 +
				ROUND(SUM(grupo8)/SUM(grupo1+grupo2+grupo3+grupo5+grupo8),2) * 100 ,
				ROUND(SUM(grupo1)/SUM(grupo1+grupo2+grupo3+grupo5+grupo8),2) * 100 + 
				ROUND(SUM(grupo2)/SUM(grupo1+grupo2+grupo3+grupo5+grupo8),2) * 100 + 
				ROUND(SUM(grupo3)/SUM(grupo1+grupo2+grupo3+grupo5+grupo8),2) * 100 +
				ROUND(SUM(grupo5)/SUM(grupo1+grupo2+grupo3+grupo5+grupo8),2) * 100 +
                            ROUND(SUM(grupo8)/SUM(grupo1+grupo2+grupo3+grupo5+grupo8),2) * 100 ,'999','0'
		FROM total_precal_group;

	SELECT COUNT(*) INTO num_registros FROM total_precal_group;

	IF num_registros > 2 THEN

		IF pTpConsulta IN('04','01','02','03') AND pCausa <> '' THEN
			FOREACH WITH HOLD

				SELECT descripcion, causa_solicitud, grupo1, grupo2, grupo3,grupo5,grupo8, total_x_status, porc_status, sit_esp
				INTO cCriterio, cCausaSol, dGrupo1,dGrupo2,dGrupo3,dGrupo5,dGrupo8, dTotalStatus,dTotalGenStatus, cTieneCausa
				FROM total_precal_group
				ORDER BY orden_reporte

				 RETURN cCodRet, cMensajeRet, cCriterio, cCausaSol, dGrupo1, dGrupo2, dGrupo3,dGrupo5, dGrupo8, 
                        dTotalStatus,dTotalGenStatus, cTieneCausa WITH RESUME;

			END FOREACH;

		ELSE

			FOREACH WITH HOLD

				SELECT descripcion, causa_solicitud, grupo1, grupo2, grupo3,grupo5,grupo8,  total_x_status, porc_status, sit_esp
				INTO cCriterio, cCausaSol, dGrupo1,dGrupo2,dGrupo3,dGrupo5,dGrupo8, dTotalStatus,dTotalGenStatus, cTieneCausa
				FROM total_precal_group
				ORDER BY orden_reporte

				 RETURN cCodRet, cMensajeRet, cCriterio, cCausaSol, dGrupo1, dGrupo2, dGrupo3,dGrupo5, dGrupo8, 
                        dTotalStatus,dTotalGenStatus, cTieneCausa WITH RESUME;

			END FOREACH;
		END IF

	ELSE

			LET cCodRet = '000006';
			LET cMensajeRet = 'No hay informacion para este producto en este periodo';
			RETURN cCodRet, cMensajeRet, cCriterio, cCausaSol, dGrupo1, dGrupo2, dGrupo3,dGrupo5, dGrupo8, 
                   dTotalStatus,dTotalGenStatus, cTieneCausa WITH RESUME;

	END IF;

	IF pTpConsulta IN ('01','02','03','04','06') THEN
		DROP TABLE "informix".precal1;
		DROP TABLE "informix".precal2;
		DROP TABLE "informix".total_precal_group;
	END IF;

END 

END PROCEDURE

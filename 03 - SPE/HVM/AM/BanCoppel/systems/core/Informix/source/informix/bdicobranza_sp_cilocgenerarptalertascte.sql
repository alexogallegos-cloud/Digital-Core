CREATE PROCEDURE "informix".sp_cilocgenerarptalertascte(pNumCte CHAR(20), pSucursal CHAR(4), pRegion SMALLINT, pFechaIni CHAR(10), pFechaFin CHAR(10), pTipo INTEGER, pSitAlarma CHAR(4))
RETURNING CHAR(5) AS CODRET, CHAR(4) AS SUCURSAL , CHAR(20) AS NUMCTE, INTEGER AS ALERTA, CHAR(4) AS SITUACION, DATE AS FECHAALERTA, CHAR(40) AS ESTATUSALERTA, CHAR(2) AS REGION, CHAR(20) AS NOMBRECD, CHAR(3) AS NUMCD, CHAR(4) AS SIGLAS;

--Declaracion de variables
------------------------------------------------------------
DEFINE sql_err 			                INTEGER;
DEFINE isam_err 		                INTEGER;
DEFINE error_info		                CHAR(80);
DEFINE cCod_ret                         CHAR(6);
DEFINE cSucursal						CHAR(4);
DEFINE cSucursal2						CHAR(4);
DEFINE cNumcte							CHAR(20);
DEFINE cNumAlerta						INTEGER;
DEFINE dFechaAlerta						DATE;
DEFINE cEstatusAlerta                   CHAR(40);
DEFINE cCiudad							CHAR(3);
DEFINE cNombreCd						CHAR(20);
DEFINE cSiglasCd						CHAR(4);
DEFINE cRegion							CHAR(2);
DEFINE cSituacion						CHAR(4);
DEFINE cCod_ret2						CHAR(5);
DEFINE dtfechainicial					DATE;
DEFINE dtfechafinal						DATE;
DEFINE dtfechainicial2					DATE;
DEFINE dtfechafinal2					DATE;
DEFINE cMesIni							CHAR(2);
DEFINE cAnoIni							CHAR(4);
DEFINE cMesFin							CHAR(2);
DEFINE cAnoFin							CHAR(4);
-----------------------------------------------------
LET cCod_ret  = '00000';
LET sql_err   = 0;
LET cSucursal = '';
LET cSucursal2 = '';
LET cNumcte	= '';
LET cNumAlerta	= 0;
LET dFechaAlerta	= '';
LET cEstatusAlerta  = '';
LET cCiudad	= '';
LET cNombreCd	= '';
LET cSiglasCd	= '';
LET cRegion		= '';
LET cSituacion = '';
LET cCod_ret2	= '';
LET dtfechainicial='';		
LET dtfechafinal='';
LET dtfechainicial2='';
LET dtfechafinal2='';
LET cMesIni		= '';
LET cAnoIni		= '';
LET cMesFin		= '';
LET cAnoFin		= '';

  BEGIN

	ON EXCEPTION SET sql_err, isam_err, error_info
		LET cCod_ret = sql_err;
		RETURN cCod_ret, cSucursal, cNumcte,  cNumAlerta, cSituacion, dFechaAlerta, cEstatusAlerta, cRegion, cNombreCd, cCiudad, cSiglasCd;
	END EXCEPTION;
	
	--SET DEBUG FILE TO "/tmp/sp_CiLocGeneraRptAlertasCte.out";
	--TRACE ON;
	
	
	--ORDENADO
	IF pTipo = 2 THEN --POR SUCURSAL
	
		IF LENGTH (pFechaIni) = 7 AND LENGTH (pFechaFin) = 7 THEN
			LET cMesIni = SUBSTR(TRIM(pFechaIni), 1, 2);
			LET cAnoIni = SUBSTR(TRIM(pFechaIni), 4, 7);
			LET cMesFin = SUBSTR(TRIM(pFechaFin), 1, 2);
			LET cAnoFin = SUBSTR(TRIM(pFechaFin), 4, 7);
			execute  procedure bdinteg:sp_diaprimeroultimomesanio(cMesIni,cAnoIni) into cCod_ret2,dtfechainicial, dtfechainicial2 ;
			execute  procedure bdinteg:sp_diaprimeroultimomesanio(cMesFin,cAnoFin) into cCod_ret2,dtfechafinal, dtfechafinal2 ;
		
			FOREACH WITH HOLD
			
				SELECT m.numcte,COUNT(m.numcte), m.sucursal ,MAX(m.fecha)
				INTO cNumcte,cNumAlerta, cSucursal,dFechaAlerta
				FROM bdicobranza:cb_alerta_succliente m
				INNER JOIN bdinteg:si_sucursales s ON (m.sucursal= s.sucursal)
				INNER JOIN bdinteg: si_ciudades d ON (d.ciudad = s.ciudad) AND (s.estado= d.estado)
				INNER JOIN bdinteg:si_catciudades c ON (d.ciudad_coppel = c.numerociudad)
				WHERE m.numcte = CASE when pNumCte = '' THEN  m.numcte ELSE pNumCte END	
				AND c.numero_region = CASE when pRegion = 0 THEN  c.numero_region ELSE pRegion END
				AND m.sucursal = CASE when pSucursal = '' THEN  m.sucursal ELSE pSucursal END				
				AND m.estatus = CASE when pSitAlarma = '' THEN  m.estatus   ELSE pSitAlarma END 
				AND m.fecha::DATE between dtfechainicial::DATE AND dtfechafinal2::DATE 
				GROUP BY m.numcte,m.sucursal
				ORDER BY m.sucursal
			
				SELECT LIMIT 1 m.sucursal, e.desc_estatus, c.numero_region,d.nombre, s.ciudad, c.inicialciudad, 
				m.situacion
				INTO cSucursal, cEstatusAlerta, cRegion, cNombreCd, cCiudad, cSiglasCd, cSituacion
				FROM bdicobranza:cb_alerta_succliente m
				INNER JOIN bdinteg:si_sucursales s ON (m.sucursal= s.sucursal)
				INNER JOIN bdinteg: si_ciudades d ON (d.ciudad = s.ciudad) AND (s.estado= d.estado)
				INNER JOIN bdinteg:si_catciudades c ON (d.ciudad_coppel = c.numerociudad)  
				INNER JOIN bdicobranza:cb_estatus_loc e ON (e.tipo= m.estatus)
				WHERE m.numcte = CASE when pNumCte = '' THEN  numcte ELSE pNumCte END	
				AND m.sucursal = CASE when pSucursal = '' THEN  m.sucursal ELSE pSucursal END
				AND c.numero_region = CASE when pRegion = 0 THEN  c.numero_region ELSE pRegion END
				AND m.estatus = CASE when pSitAlarma = '' THEN  m.estatus   ELSE pSitAlarma END 
				AND fecha::DATE = dFechaAlerta
				AND m.numalerta = (SELECT MAX(numalerta) FROM cb_alerta_succliente 
								 WHERE numcte = cNumcte 
								 AND estatus = CASE when pSitAlarma = '' THEN  estatus   ELSE pSitAlarma END
								 AND fecha::DATE = dFechaAlerta);
				
				RETURN cCod_ret, cSucursal, cNumcte,  cNumAlerta, cSituacion, dFechaAlerta, cEstatusAlerta, cRegion, cNombreCd, cCiudad, cSiglasCd WITH RESUME;
				
			END FOREACH;
			
		ELSE 
		
			FOREACH WITH HOLD						
				
				SELECT numcte,COUNT(m.numcte), m.sucursal ,MAX(m.fecha)
				INTO cNumcte,cNumAlerta, cSucursal,dFechaAlerta
				FROM bdicobranza:cb_alerta_succliente m
				INNER JOIN bdinteg:si_sucursales s ON (m.sucursal= s.sucursal)
				INNER JOIN bdinteg: si_ciudades d ON (d.ciudad = s.ciudad) AND (s.estado= d.estado)
				INNER JOIN bdinteg:si_catciudades c ON (d.ciudad_coppel = c.numerociudad)
				WHERE m.numcte = CASE when pNumCte = '' THEN  m.numcte ELSE pNumCte END	
				AND c.numero_region = CASE when pRegion = 0 THEN  c.numero_region ELSE pRegion END
				AND m.sucursal = CASE when pSucursal = '' THEN  m.sucursal ELSE pSucursal END				
				AND m.estatus = CASE when pSitAlarma = '' THEN  m.estatus   ELSE pSitAlarma END 
				AND m.fecha::DATE between pFechaIni::DATE AND pFechaFin::DATE 
				GROUP BY m.numcte,m.sucursal
				ORDER BY m.sucursal
			
				SELECT LIMIT 1 m.sucursal, e.desc_estatus, c.numero_region,d.nombre, s.ciudad, c.inicialciudad, 
				m.situacion
				INTO cSucursal, cEstatusAlerta, cRegion, cNombreCd, cCiudad, cSiglasCd, cSituacion
				FROM bdicobranza:cb_alerta_succliente m
				INNER JOIN bdinteg:si_sucursales s ON (m.sucursal= s.sucursal)
				INNER JOIN bdinteg: si_ciudades d ON (d.ciudad = s.ciudad) AND (s.estado= d.estado)
				INNER JOIN bdinteg:si_catciudades c ON (d.ciudad_coppel = c.numerociudad)  
				INNER JOIN bdicobranza:cb_estatus_loc e ON (m.estatus = e.tipo)
				WHERE m.sucursal = CASE when pSucursal = '' THEN  m.sucursal ELSE pSucursal END
				AND c.numero_region = CASE when pRegion = 0 THEN  c.numero_region   ELSE pRegion END
				AND m.estatus = CASE when pSitAlarma = '' THEN  m.estatus   ELSE pSitAlarma END 
				AND m.numcte = cNumcte
				AND m.fecha = dFechaAlerta
				AND m.numalerta = (SELECT MAX(m.numalerta) FROM cb_alerta_succliente m
								 WHERE numcte = cNumcte 
								 AND estatus = CASE when pSitAlarma = '' THEN  estatus   ELSE pSitAlarma END
								 AND fecha::DATE = dFechaAlerta );
				
				RETURN cCod_ret, cSucursal, cNumcte,  cNumAlerta, cSituacion, dFechaAlerta, cEstatusAlerta, cRegion, cNombreCd, cCiudad, cSiglasCd WITH RESUME;
				
			END FOREACH;		
		END IF;		
			
	ELIF pTipo = 3 THEN--TIPO  POR REGION
	
		IF LENGTH (pFechaIni) = 7 AND LENGTH (pFechaFin) = 7 THEN	
			LET cMesIni = SUBSTR(TRIM(pFechaIni), 1, 2);
			LET cAnoIni = SUBSTR(TRIM(pFechaIni), 4, 7);
			LET cMesFin = SUBSTR(TRIM(pFechaFin), 1, 2);
			LET cAnoFin = SUBSTR(TRIM(pFechaFin), 4, 7);
			execute  procedure bdinteg:sp_diaprimeroultimomesanio(cMesIni,cAnoIni) into cCod_ret2,dtfechainicial, dtfechainicial2 ;
			execute  procedure bdinteg:sp_diaprimeroultimomesanio(cMesFin,cAnoFin) into cCod_ret2,dtfechafinal, dtfechafinal2 ;
			
			FOREACH	WITH HOLD
				
				SELECT m.numcte,COUNT(m.numcte),c.numero_region, MAX(m.fecha)
				INTO cNumcte, cNumAlerta,cRegion, dFechaAlerta
				FROM bdicobranza:cb_alerta_succliente m
				INNER JOIN bdinteg:si_sucursales s ON (m.sucursal= s.sucursal)
				INNER JOIN bdinteg: si_ciudades d ON (d.ciudad = s.ciudad) AND (s.estado= d.estado)
				INNER JOIN bdinteg:si_catciudades c ON (d.ciudad_coppel = c.numerociudad)
				WHERE m.numcte = CASE when pNumCte = '' THEN  m.numcte ELSE pNumCte END	
				AND c.numero_region = CASE when pRegion = 0 THEN  c.numero_region ELSE pRegion END
				AND m.sucursal = CASE when pSucursal = '' THEN  m.sucursal ELSE pSucursal END				
				AND m.estatus = CASE when pSitAlarma = '' THEN  m.estatus   ELSE pSitAlarma END 
				AND fecha::DATE between dtfechainicial::DATE AND dtfechafinal2::DATE 
				GROUP BY m.numcte,c.numero_region
				ORDER BY c.numero_region
			
				SELECT LIMIT 1 m.sucursal, e.desc_estatus, c.numero_region,d.nombre, s.ciudad, c.inicialciudad, 
				m.situacion
				INTO cSucursal, cEstatusAlerta, cRegion, cNombreCd, cCiudad, cSiglasCd, cSituacion
				FROM bdicobranza:cb_alerta_succliente m
				INNER JOIN bdinteg:si_sucursales s ON (m.sucursal= s.sucursal)
				INNER JOIN bdinteg: si_ciudades d ON (d.ciudad = s.ciudad) AND (s.estado= d.estado)
				INNER JOIN bdinteg:si_catciudades c ON (d.ciudad_coppel = c.numerociudad)  
				INNER JOIN bdicobranza:cb_estatus_loc e ON (e.tipo= m.estatus)
				WHERE m.sucursal = CASE when pSucursal = '' THEN  m.sucursal   ELSE pSucursal END
				AND c.numero_region = CASE when pRegion = 0 THEN  c.numero_region   ELSE pRegion END
				AND m.estatus = CASE when pSitAlarma = '' THEN  m.estatus   ELSE pSitAlarma END 
				AND m.numcte = cNumcte
				AND m.fecha::DATE = dFechaAlerta 
				AND m.numalerta = (SELECT MAX(numalerta) FROM cb_alerta_succliente
								 WHERE numcte = cNumcte 
								 AND estatus = CASE when pSitAlarma = '' THEN  estatus   ELSE pSitAlarma END
								 AND fecha::DATE = dFechaAlerta );						
				
				RETURN cCod_ret, cSucursal, cNumcte,  cNumAlerta, cSituacion, dFechaAlerta, cEstatusAlerta, cRegion, cNombreCd, cCiudad, cSiglasCd WITH RESUME;
				
			END FOREACH;			
		ELSE
		
			FOREACH WITH HOLD
		
				SELECT m.numcte,COUNT(m.numcte),c.numero_region, MAX(m.fecha)
				INTO cNumcte, cNumAlerta, cRegion, dFechaAlerta
				FROM bdicobranza:cb_alerta_succliente m
				INNER JOIN bdinteg:si_sucursales s ON (m.sucursal= s.sucursal)
				INNER JOIN bdinteg: si_ciudades d ON (d.ciudad = s.ciudad) AND (s.estado= d.estado)
				INNER JOIN bdinteg:si_catciudades c ON (d.ciudad_coppel = c.numerociudad)
				WHERE numcte = CASE when pNumCte = '' THEN  numcte ELSE pNumCte END
				AND c.numero_region = CASE when pRegion = 0 THEN  c.numero_region ELSE pRegion END				
				AND m.sucursal = CASE when pSucursal = '' THEN  m.sucursal ELSE pSucursal END				
				AND m.estatus = CASE when pSitAlarma = '' THEN  m.estatus   ELSE pSitAlarma END 
				AND m.fecha BETWEEN pFechaIni AND pFechaFin
				GROUP BY m.numcte,c.numero_region
				ORDER BY c.numero_region
				
			
				SELECT LIMIT 1 m.sucursal, e.desc_estatus, c.numero_region,d.nombre, s.ciudad, c.inicialciudad,
				m.situacion
				INTO cSucursal, cEstatusAlerta, cRegion, cNombreCd, cCiudad, cSiglasCd, cSituacion
				FROM bdicobranza:cb_alerta_succliente m
				INNER JOIN bdinteg:si_sucursales s ON (m.sucursal= s.sucursal)
				INNER JOIN bdinteg: si_ciudades d ON (d.ciudad = s.ciudad) AND (s.estado= d.estado)
				INNER JOIN bdinteg:si_catciudades c ON (d.ciudad_coppel = c.numerociudad)  
				INNER JOIN bdicobranza:cb_estatus_loc e ON (e.tipo= m.estatus)
				WHERE m.sucursal = CASE when pSucursal = '' THEN  m.sucursal   ELSE pSucursal END
				AND c.numero_region = CASE when pRegion = 0 THEN  c.numero_region   ELSE pRegion END
				AND m.estatus = CASE when pSitAlarma = '' THEN  m.estatus   ELSE pSitAlarma END 
				AND m.numcte = cNumcte
				AND m.fecha = dFechaAlerta
				AND m.numalerta = (SELECT MAX(numalerta) FROM cb_alerta_succliente 
								 WHERE numcte = cNumcte 
								 AND estatus = CASE when pSitAlarma = '' THEN  estatus   ELSE pSitAlarma END
								 AND fecha::DATE  = dFechaAlerta );
				
				--ORDER BY c.numero_region;		
				
				RETURN cCod_ret, cSucursal, cNumcte,  cNumAlerta, cSituacion, dFechaAlerta, cEstatusAlerta, cRegion, cNombreCd, 
				cCiudad, cSiglasCd WITH RESUME;
			
			END FOREACH;
		END IF;	
	ELIF pTipo = 1 THEN -- SIN ORDER
	
		IF LENGTH (pFechaIni) = 7 AND LENGTH (pFechaFin) = 7 THEN
			LET cMesIni = SUBSTR(TRIM(pFechaIni), 1, 2);
			LET cAnoIni = SUBSTR(TRIM(pFechaIni), 4, 7);
			LET cMesFin = SUBSTR(TRIM(pFechaFin), 1, 2);
			LET cAnoFin = SUBSTR(TRIM(pFechaFin), 4, 7);
			execute  procedure bdinteg:sp_diaprimeroultimomesanio(cMesIni,cAnoIni) into cCod_ret2,dtfechainicial, dtfechainicial2 ;
			execute  procedure bdinteg:sp_diaprimeroultimomesanio(cMesFin,cAnoFin) into cCod_ret2,dtfechafinal, dtfechafinal2 ;
		
			FOREACH WITH HOLD
			
				SELECT m.numcte,COUNT(m.numcte), MAX(m.fecha)
				INTO cNumcte,cNumAlerta,dFechaAlerta
				FROM bdicobranza:cb_alerta_succliente m
				INNER JOIN bdinteg:si_sucursales s ON (m.sucursal= s.sucursal)
				INNER JOIN bdinteg: si_ciudades d ON (d.ciudad = s.ciudad) AND (s.estado= d.estado)
				INNER JOIN bdinteg:si_catciudades c ON (d.ciudad_coppel = c.numerociudad)
				WHERE m.numcte = CASE when pNumCte = '' THEN  numcte ELSE pNumCte END	
				AND c.numero_region = CASE when pRegion = 0 THEN  c.numero_region ELSE pRegion END
				AND m.sucursal = CASE when pSucursal = '' THEN  m.sucursal ELSE pSucursal END				
				AND m.estatus = CASE when pSitAlarma = '' THEN  m.estatus   ELSE pSitAlarma END 
				AND m.fecha::DATE between dtfechainicial::DATE AND dtfechafinal2::DATE 			
				GROUP BY m.numcte
				
				SELECT LIMIT 1 m.sucursal, e.desc_estatus, c.numero_region,d.nombre, s.ciudad, c.inicialciudad,
				m.situacion
				INTO cSucursal, cEstatusAlerta, cRegion, cNombreCd, cCiudad, cSiglasCd, cSituacion
				FROM bdicobranza:cb_alerta_succliente m
				INNER JOIN bdinteg:si_sucursales s ON (m.sucursal= s.sucursal)
				INNER JOIN bdinteg: si_ciudades d ON (d.ciudad = s.ciudad) AND (s.estado= d.estado)
				INNER JOIN bdinteg:si_catciudades c ON (d.ciudad_coppel = c.numerociudad)  
				INNER JOIN bdicobranza:cb_estatus_loc e ON (e.tipo= m.estatus)
				WHERE m.numcte = cNumcte
				AND m.sucursal = CASE when pSucursal = '' THEN  m.sucursal ELSE pSucursal END
				AND c.numero_region = CASE when pRegion = 0 THEN  c.numero_region ELSE pRegion END
				AND m.estatus = CASE when pSitAlarma = '' THEN  m.estatus   ELSE pSitAlarma END 
				AND m.fecha::DATE = dFechaAlerta
				AND m.numalerta = (SELECT MAX(numalerta) FROM cb_alerta_succliente  
								 WHERE numcte = cNumcte 
								 AND estatus = CASE when pSitAlarma = '' THEN  estatus   ELSE pSitAlarma END
								 AND fecha::DATE = dFechaAlerta);
				
				RETURN cCod_ret, cSucursal, cNumcte,  cNumAlerta, cSituacion, dFechaAlerta, cEstatusAlerta, cRegion, cNombreCd, 
				cCiudad, cSiglasCd WITH RESUME;				
			END FOREACH;
			
		ELSE 
		
			FOREACH  WITH HOLD						
				
				SELECT m.numcte,COUNT(m.numcte), MAX(m.fecha)
				INTO cNumcte,cNumAlerta,dFechaAlerta
				FROM bdicobranza:cb_alerta_succliente m
				INNER JOIN bdinteg:si_sucursales s ON (m.sucursal= s.sucursal)
				INNER JOIN bdinteg: si_ciudades d ON (d.ciudad = s.ciudad) AND (s.estado= d.estado)
				INNER JOIN bdinteg:si_catciudades c ON (d.ciudad_coppel = c.numerociudad)  
				WHERE m.numcte = CASE when pNumCte = '' THEN  m.numcte ELSE pNumCte END
				AND c.numero_region = CASE when pRegion = 0 THEN  c.numero_region ELSE pRegion END				
				AND m.sucursal = CASE when pSucursal = '' THEN  m.sucursal ELSE pSucursal END				
				AND m.estatus = CASE when pSitAlarma = '' THEN  m.estatus   ELSE pSitAlarma END 
				AND m.fecha BETWEEN pFechaIni AND pFechaFin
				GROUP BY m.numcte
				
						
				SELECT LIMIT 1 m.sucursal, e.desc_estatus, c.numero_region,d.nombre, s.ciudad, c.inicialciudad,
				m.situacion
				INTO cSucursal, cEstatusAlerta, cRegion, cNombreCd, cCiudad, cSiglasCd, cSituacion
				FROM bdicobranza:cb_alerta_succliente m
				INNER JOIN bdinteg:si_sucursales s ON (m.sucursal= s.sucursal)
				INNER JOIN bdinteg: si_ciudades d ON (d.ciudad = s.ciudad) AND (s.estado= d.estado)
				INNER JOIN bdinteg:si_catciudades c ON (d.ciudad_coppel = c.numerociudad)  
				INNER JOIN bdicobranza:cb_estatus_loc e ON (e.tipo= m.estatus)
				WHERE m.sucursal = CASE when pSucursal = '' THEN  m.sucursal   ELSE pSucursal END
				AND c.numero_region = CASE when pRegion = 0 THEN  c.numero_region   ELSE pRegion END
				AND m.estatus = CASE when pSitAlarma = '' THEN  m.estatus   ELSE pSitAlarma END 
				AND m.numcte = cNumcte
				AND m.fecha = dFechaAlerta
				AND m.numalerta = (SELECT MAX(numalerta) FROM cb_alerta_succliente  
								 WHERE numcte = cNumcte 
								 AND estatus = CASE when pSitAlarma = '' THEN  estatus   ELSE pSitAlarma END
								 AND fecha::DATE = dFechaAlerta );			
				
				RETURN cCod_ret, cSucursal, cNumcte,  cNumAlerta, cSituacion, dFechaAlerta, cEstatusAlerta, cRegion, cNombreCd,
				cCiudad, cSiglasCd WITH RESUME;
				
			END FOREACH;		
		END IF;			
	END IF;

END;
END PROCEDURE

DOCUMENT
'AUTOR: ABIGAIL VASAVILBAZO CAÑEDO',
'DESCRIPCION: GENERA INFORMACION PARA REPORTE DE MARCAS (ORDENADO POR REGION O SUCURSAL)',
'BD: BDICOBRANZA',
'VERSION: 20100910.1209';

CREATE PROCEDURE "informix".sp_cilocgenerarptmarcascte(pNumCte CHAR(20), pSucursal CHAR(4), pRegion SMALLINT, pFechaIni CHAR(10), pFechaFin CHAR(10), pTipo INTEGER, pMarca CHAR(4), pSitMarca CHAR(4))
RETURNING CHAR(5), CHAR(4), CHAR(20), INTEGER, CHAR(4), DATE, CHAR(40), SMALLINT, CHAR(20), CHAR(3), CHAR(4);

--Declaracion de variables
------------------------------------------------------------
DEFINE sql_err 			                INTEGER;
DEFINE isam_err 		                INTEGER;
DEFINE error_info		                CHAR(80);
DEFINE cCod_ret                         CHAR(6);
DEFINE cSucursal						CHAR(4);
DEFINE cNumcte							CHAR(20);
DEFINE iNumMarcas						INTEGER;
DEFINE cTpoMarca						CHAR(4);
DEFINE dFechaMarca						DATE;
DEFINE cEstatusMarca                    CHAR(40);
DEFINE cCiudad							CHAR(3);
DEFINE cNombreCd						CHAR(20);
DEFINE cSiglasCd						CHAR(4);
DEFINE sRegion							SMALLINT;
DEFINE cMesIni							CHAR(2);
DEFINE cAnoIni							CHAR(4);
DEFINE cMesFin							CHAR(2);
DEFINE cAnoFin							CHAR(4);
DEFINE cCod_ret2						CHAR(5);
DEFINE dtfechainicial					DATE;
DEFINE dtfechafinal						DATE;
DEFINE dtfechainicial2					DATE;
DEFINE dtfechafinal2					DATE;
DEFINE cEstatus							CHAR(4);
-----------------------------------------------------
LET cCod_ret  = '00000';
LET sql_err   = 0;
LET cSucursal = '';
LET cNumcte	= '';
LET iNumMarcas	=0;
LET cTpoMarca	= '';
LET dFechaMarca	= '';
LET cEstatusMarca  = '';
LET cCiudad	= '';
LET cNombreCd	= '';
LET cSiglasCd	= '';
LET sRegion		= '';
LET cCod_ret2   = '';
LET cMesIni		= '';
LET cAnoIni		= '';
LET cMesFin		= '';
LET cAnoFin		= '';
LET dtfechainicial='';		
LET dtfechafinal='';
LET dtfechainicial2='';
LET dtfechafinal2='';
LET cEstatus = '';

  BEGIN

	ON EXCEPTION SET sql_err, isam_err, error_info
		LET cCod_ret = sql_err;
		RETURN cCod_ret, cSucursal, cNumcte, iNumMarcas, cTpoMarca, dFechaMarca, cEstatusMarca, sRegion, cNombreCd, cCiudad, cSiglasCd ;
	END EXCEPTION;
	
	--SET DEBUG FILE TO "/tmp/sp_CiLocGeneraRptMarcasCte.out";
	--TRACE ON;
	
	--ORDENADO
	IF pTipo = 2 THEN --POR SUCURSAL
	
		IF LENGTH (pFechaIni) = 7 AND LENGTH (pFechaFin) = 7 THEN
		
			LET cMesIni = SUBSTR(TRIM(pFechaIni), 1, 2);
			LET cAnoIni = SUBSTR(TRIM(pFechaIni), 4, 7);
			LET cMesFin = SUBSTR(TRIM(pFechaFin), 1, 2);
			LET cAnoFin = SUBSTR(TRIM(pFechaFin), 4, 7);
			execute  procedure bdinteg:sp_diaprimeroultimomesanio(cMesIni,cAnoIni) into cCod_ret2,dtfechainicial, dtfechainicial2 ;
			execute  procedure bdinteg:sp_diaprimeroultimomesanio(cMesFin,cAnoFin) into cCod_ret2,dtfechafinal, dtfechafinal2 ;
		
			FOREACH WITH HOLD
			
				SELECT m.sucursal,COUNT(m.numcte), m.numcte, m.tipo_marca, MAX(m.fecha_insert), e.desc_estatus, c.numero_region,d.nombre, s.ciudad, c.inicialciudad, m.estatus
				INTO cSucursal, iNumMarcas,cNumcte, cTpoMarca, dFechaMarca, cEstatusMarca, sRegion, cNombreCd, cCiudad, cSiglasCd, cEstatus
				FROM bdicobranza:cb_marcacliente m
				INNER JOIN bdinteg:si_sucursales s ON (m.sucursal= s.sucursal)
				INNER JOIN bdinteg: si_ciudades d ON (d.ciudad = s.ciudad) AND ( s.estado= d.estado)
				INNER JOIN bdinteg:si_catciudades c ON (d.ciudad_coppel = c.numerociudad)  
				INNER JOIN bdicobranza:cb_estatus_loc e ON (e.tipo= m.estatus)
				INNER JOIN  bdisitesp:se_ctessitespcte p ON (m.numcte = p.numcte)
				WHERE m.sucursal = CASE when pSucursal = '' THEN  s.sucursal   ELSE pSucursal END
				AND c.numero_region = CASE when pRegion = 0 THEN  c.numero_region   ELSE pRegion END
				AND m.numcte = CASE when pNumCte = '' THEN  m.numcte   ELSE pNumCte END
				AND m.tipo_marca = CASE when pMarca = '' THEN  m.tipo_marca   ELSE pMarca END
				AND m.estatus = CASE when pSitMarca = '' THEN  m.estatus   ELSE pSitMarca END 
				AND m.fecha_insert::DATE between dtfechainicial::DATE AND dtfechafinal2::DATE 
				AND p.situacion IN ('L', 'M')
				GROUP BY m.numcte, m.tipo_marca, m.sucursal, m.estatus, e.desc_estatus, c.numero_region,d.nombre, s.ciudad, c.inicialciudad
				ORDER BY m.sucursal, m.numcte, m.tipo_marca
				
				RETURN cCod_ret, cSucursal, cNumcte, iNumMarcas, cTpoMarca, dFechaMarca, cEstatusMarca, sRegion, cNombreCd, cCiudad, cSiglasCd WITH RESUME;
				
			END FOREACH;
			
		ELSE
		
			FOREACH WITH HOLD
		
				SELECT m.sucursal,COUNT(m.numcte), m.numcte, m.tipo_marca, MAX(m.fecha_insert), e.desc_estatus, c.numero_region,d.nombre, s.ciudad, c.inicialciudad, m.estatus
				INTO cSucursal, iNumMarcas,cNumcte, cTpoMarca, dFechaMarca, cEstatusMarca, sRegion, cNombreCd, cCiudad, cSiglasCd, cEstatus
				FROM bdicobranza:cb_marcacliente m
				INNER JOIN bdinteg:si_sucursales s ON (m.sucursal= s.sucursal)
				INNER JOIN bdinteg: si_ciudades d ON (d.ciudad = s.ciudad) AND ( s.estado= d.estado)
				INNER JOIN bdinteg:si_catciudades c ON (d.ciudad_coppel = c.numerociudad)   
				INNER JOIN bdicobranza:cb_estatus_loc e ON (e.tipo= m.estatus)
				INNER JOIN  bdisitesp:se_ctessitespcte p ON (m.numcte = p.numcte)
				WHERE m.sucursal = CASE when pSucursal = '' THEN  s.sucursal   ELSE pSucursal END
				AND c.numero_region = CASE when pRegion = 0 THEN  c.numero_region   ELSE pRegion END
				AND m.numcte = CASE when pNumCte = '' THEN  m.numcte   ELSE pNumCte END
				AND tipo_marca = CASE when pMarca = '' THEN  m.tipo_marca   ELSE pMarca END
				AND m.estatus = CASE when pSitMarca = '' THEN  m.estatus   ELSE pSitMarca END 
				AND  m.fecha_insert::DATE between pFechaIni::DATE AND pFechaFin::DATE 
				AND p.situacion IN ('L', 'M')
				GROUP BY m.numcte, m.tipo_marca, m.sucursal, m.estatus, e.desc_estatus, c.numero_region,d.nombre, s.ciudad, c.inicialciudad, m.estatus
				ORDER BY m.sucursal, m.numcte, m.tipo_marca				
				
				RETURN cCod_ret, cSucursal, cNumcte, iNumMarcas, cTpoMarca, dFechaMarca, cEstatusMarca, sRegion, cNombreCd, cCiudad, cSiglasCd WITH RESUME;
				
			END FOREACH;
		
		END IF;		
			
	ELIF pTipo = 3 THEN
	
		IF LENGTH (pFechaIni) = 7 AND LENGTH (pFechaFin) = 7 THEN
			LET cMesIni = SUBSTR(TRIM(pFechaIni), 1, 2);
			LET cAnoIni = SUBSTR(TRIM(pFechaIni), 4, 7);
			LET cMesFin = SUBSTR(TRIM(pFechaFin), 1, 2);
			LET cAnoFin = SUBSTR(TRIM(pFechaFin), 4, 7);
			execute  procedure bdinteg:sp_diaprimeroultimomesanio(cMesIni,cAnoIni) into cCod_ret2,dtfechainicial, dtfechainicial2 ;
			execute  procedure bdinteg:sp_diaprimeroultimomesanio(cMesFin,cAnoFin) into cCod_ret2,dtfechafinal, dtfechafinal2 ;
	
			FOREACH WITH HOLD			
	
				SELECT m.sucursal,COUNT(m.numcte), m.numcte, m.tipo_marca, MAX(m.fecha_insert), e.desc_estatus, c.numero_region,d.nombre, s.ciudad, c.inicialciudad, m.estatus
				INTO cSucursal, iNumMarcas,cNumcte, cTpoMarca, dFechaMarca, cEstatusMarca, sRegion, cNombreCd, cCiudad, cSiglasCd, cEstatus
				FROM bdicobranza:cb_marcacliente m
				INNER JOIN bdinteg:si_sucursales s ON (m.sucursal= s.sucursal)
				INNER JOIN bdinteg: si_ciudades d ON (d.ciudad = s.ciudad) AND ( s.estado= d.estado)
				INNER JOIN bdinteg:si_catciudades c ON (d.ciudad_coppel = c.numerociudad)   
				INNER JOIN bdicobranza:cb_estatus_loc e ON (e.tipo= m.estatus)
				INNER JOIN  bdisitesp:se_ctessitespcte p ON (m.numcte = p.numcte)
				WHERE m.sucursal = CASE when pSucursal = '' THEN  s.sucursal   ELSE pSucursal END
				AND c.numero_region = CASE when pRegion = 0 THEN  c.numero_region   ELSE pRegion END
				AND tipo_marca = CASE when pMarca = '' THEN  m.tipo_marca   ELSE pMarca END
				AND m.estatus = CASE when pSitMarca = '' THEN  m.estatus   ELSE pSitMarca END 
				AND m.numcte = CASE when pNumCte = '' THEN  m.numcte   ELSE pNumCte END
				AND  m.fecha_insert::DATE between dtfechainicial::DATE AND dtfechafinal2::DATE 
				AND p.situacion IN ('L', 'M')
				GROUP BY m.numcte, m.tipo_marca, m.sucursal, m.estatus, e.desc_estatus, c.numero_region,d.nombre, s.ciudad, c.inicialciudad, m.estatus
				ORDER BY c.numero_region, m.numcte, m.tipo_marca				
				
				RETURN cCod_ret, cSucursal, cNumcte, iNumMarcas, cTpoMarca, dFechaMarca, cEstatusMarca, sRegion, cNombreCd, cCiudad, cSiglasCd WITH RESUME;
				
			END FOREACH;
			
		ELSE
		
			FOREACH WITH HOLD
		
				SELECT m.sucursal,COUNT(m.numcte), m.numcte, m.tipo_marca, MAX(m.fecha_insert), e.desc_estatus, c.numero_region,d.nombre, s.ciudad, c.inicialciudad, m.estatus
				INTO cSucursal, iNumMarcas,cNumcte, cTpoMarca, dFechaMarca, cEstatusMarca, sRegion, cNombreCd, cCiudad, cSiglasCd, cEstatus
				FROM bdicobranza:cb_marcacliente m
				INNER JOIN bdinteg:si_sucursales s ON (m.sucursal= s.sucursal)
				INNER JOIN bdinteg: si_ciudades d ON (d.ciudad = s.ciudad) AND ( s.estado= d.estado)
				INNER JOIN bdinteg:si_catciudades c ON (d.ciudad_coppel = c.numerociudad)  
				INNER JOIN bdicobranza:cb_estatus_loc e ON (e.tipo= m.estatus)	
				INNER JOIN  bdisitesp:se_ctessitespcte p ON (m.numcte = p.numcte)				
				WHERE m.sucursal = CASE when pSucursal = '' THEN  s.sucursal   ELSE pSucursal END
				AND c.numero_region = CASE when pRegion = 0 THEN  c.numero_region   ELSE pRegion END
				AND m.numcte = CASE when pNumCte = '' THEN  m.numcte   ELSE pNumCte END
				AND tipo_marca = CASE when pMarca = '' THEN  m.tipo_marca   ELSE pMarca END
				AND m.estatus = CASE when pSitMarca = '' THEN  m.estatus   ELSE pSitMarca END 
				AND  m.fecha_insert::DATE between pFechaIni::DATE AND pFechaFin::DATE 
				AND p.situacion IN ('L', 'M')
				GROUP BY m.numcte, m.tipo_marca, m.sucursal, m.estatus, e.desc_estatus, c.numero_region,d.nombre, s.ciudad, c.inicialciudad, m.estatus
				ORDER BY c.numero_region, m.numcte, m.tipo_marca
				
				RETURN cCod_ret, cSucursal, cNumcte, iNumMarcas, cTpoMarca, dFechaMarca, cEstatusMarca, sRegion, cNombreCd, cCiudad, cSiglasCd WITH RESUME;
			
			END FOREACH;
		
		END IF;
		
	ELIF pTipo = 1 THEN
	
		IF LENGTH (pFechaIni) = 7 AND LENGTH (pFechaFin) = 7 THEN
		
			LET cMesIni = SUBSTR(TRIM(pFechaIni), 1, 2);
			LET cAnoIni = SUBSTR(TRIM(pFechaIni), 4, 7);
			LET cMesFin = SUBSTR(TRIM(pFechaFin), 1, 2);
			LET cAnoFin = SUBSTR(TRIM(pFechaFin), 4, 7);
			execute  procedure bdinteg:sp_diaprimeroultimomesanio(cMesIni,cAnoIni) into cCod_ret2,dtfechainicial, dtfechainicial2 ;
			execute  procedure bdinteg:sp_diaprimeroultimomesanio(cMesFin,cAnoFin) into cCod_ret2,dtfechafinal, dtfechafinal2 ;
		
			FOREACH WITH HOLD
			
				SELECT m.sucursal,COUNT(m.numcte), m.numcte, m.tipo_marca, MAX(m.fecha_insert), e.desc_estatus, c.numero_region,d.nombre, s.ciudad, c.inicialciudad, m.estatus
				INTO cSucursal, iNumMarcas,cNumcte, cTpoMarca, dFechaMarca, cEstatusMarca, sRegion, cNombreCd, cCiudad, cSiglasCd, cEstatus
				FROM bdicobranza:cb_marcacliente m
				INNER JOIN bdinteg:si_sucursales s ON (m.sucursal= s.sucursal)
				INNER JOIN bdinteg: si_ciudades d ON (d.ciudad = s.ciudad) AND ( s.estado= d.estado)
				INNER JOIN bdinteg:si_catciudades c ON (d.ciudad_coppel = c.numerociudad)  
				INNER JOIN bdicobranza:cb_estatus_loc e ON (e.tipo= m.estatus)
				INNER JOIN  bdisitesp:se_ctessitespcte p ON (m.numcte = p.numcte)
				WHERE m.sucursal = CASE when pSucursal = '' THEN  s.sucursal   ELSE pSucursal END
				AND c.numero_region = CASE when pRegion = 0 THEN  c.numero_region   ELSE pRegion END
				AND m.numcte = CASE when pNumCte = '' THEN  m.numcte   ELSE pNumCte END
				AND m.tipo_marca = CASE when pMarca = '' THEN  m.tipo_marca   ELSE pMarca END
				AND m.estatus = CASE when pSitMarca = '' THEN  m.estatus   ELSE pSitMarca END 
				AND  m.fecha_insert::DATE between dtfechainicial::DATE AND dtfechafinal2::DATE 
				AND p.situacion IN ('L', 'M')
				GROUP BY m.numcte, m.tipo_marca, m.sucursal, m.estatus, e.desc_estatus, c.numero_region,d.nombre, s.ciudad, c.inicialciudad, m.estatus
				ORDER BY m.numcte, m.tipo_marca

				RETURN cCod_ret, cSucursal, cNumcte, iNumMarcas, cTpoMarca, dFechaMarca, cEstatusMarca, sRegion, cNombreCd, cCiudad, cSiglasCd WITH RESUME;
				
			END FOREACH;
			
		ELSE
		
			FOREACH WITH HOLD
		
				SELECT m.sucursal,COUNT(m.numcte), m.numcte, m.tipo_marca, MAX(m.fecha_insert), e.desc_estatus, c.numero_region,d.nombre, s.ciudad, c.inicialciudad, m.estatus
				INTO cSucursal, iNumMarcas,cNumcte, cTpoMarca, dFechaMarca, cEstatusMarca, sRegion, cNombreCd, cCiudad, cSiglasCd, cEstatus
				FROM bdicobranza:cb_marcacliente m
				INNER JOIN bdinteg:si_sucursales s ON (m.sucursal= s.sucursal)
				INNER JOIN bdinteg: si_ciudades d ON (d.ciudad = s.ciudad) AND ( s.estado= d.estado)
				INNER JOIN bdinteg:si_catciudades c ON (d.ciudad_coppel = c.numerociudad)   
				INNER JOIN bdicobranza:cb_estatus_loc e ON (e.tipo= m.estatus)
				INNER JOIN  bdisitesp:se_ctessitespcte p ON (m.numcte = p.numcte)
				WHERE m.sucursal = CASE when pSucursal = '' THEN  s.sucursal   ELSE pSucursal END
				AND c.numero_region = CASE when pRegion = 0 THEN  c.numero_region   ELSE pRegion END
				AND m.numcte = CASE when pNumCte = '' THEN  m.numcte   ELSE pNumCte END
				AND tipo_marca = CASE when pMarca = '' THEN  m.tipo_marca   ELSE pMarca END
				AND m.estatus = CASE when pSitMarca = '' THEN  m.estatus   ELSE pSitMarca END 
				AND  m.fecha_insert::DATE between pFechaIni::DATE AND pFechaFin::DATE 
				AND p.situacion IN ('L','M')
				GROUP BY m.numcte, m.tipo_marca, m.sucursal, m.estatus, e.desc_estatus, c.numero_region,d.nombre, s.ciudad, c.inicialciudad, m.estatus
				ORDER BY m.numcte, m.tipo_marca
				
				RETURN cCod_ret, cSucursal, cNumcte, iNumMarcas, cTpoMarca, dFechaMarca, cEstatusMarca, sRegion, cNombreCd, cCiudad, cSiglasCd WITH RESUME;
				
			END FOREACH;
		
		END IF;		
		
	END IF;
	
	IF iNumMarcas = 0 THEN
		LET cCod_ret = '00001';
		RETURN cCod_ret, cSucursal, cNumcte, iNumMarcas, cTpoMarca, dFechaMarca, cEstatusMarca, sRegion, cNombreCd, cCiudad, cSiglasCd;
	END IF;

END;
END PROCEDURE

DOCUMENT
'AUTOR: ABIGAIL VASAVILBAZO CAÑEDO',
'DESCRIPCION: GENERA INFORMACION PARA REPORTE DE MARCAS ORDENADO POR REGION O SUCURSAL ',
'BD: BDICOBRANZA',
'VERSION: 20100910.1206';

CREATE PROCEDURE "informix".sp_cilocgenerarptsituacioncausacte(pSituacion CHAR(1),pCausa SMALLINT,pNumcte CHAR(20),pNumsucursal CHAR(4),pNumRegion smallint,pFechaInicio CHAR (10),pFechaFin CHAR(10),piTipoOrder INTEGER)
		RETURNING   CHAR(5) AS Codigo,	--codret
					CHAR(1) AS Situacion, --Situacion elegida
					SMALLINT AS Causa, --Causa segun la situacion seleccionada
					CHAR(20) AS Num_Cliente,--Numero de cliente
					CHAR(4) AS Num_Sucursal, --Numero de sucursal
					CHAR(30) AS Num_region, --Nombre de region
					DATE AS FechaInicio, -- Fecha de inicio
					DATE AS FechaFin, -- Fecha de fin
					CHAR(8) AS Num_Empleado,--Numero de empleado
					CHAR(12) AS Origen, --Valor de origen
					INTEGER AS Num_ciudad, --Numero de ciudad
					CHAR(30) AS Nom_ciudad, --Nombre de region
					CHAR(4) AS Siglas_ciudad; --Iniciales de ciudad
					
	DEFINE cCodRet 			CHAR(5);
	DEFINE cCod_ret2 		CHAR(5);
	DEFINE iCont            INTEGER;
	DEFINE iSqlErr 			INTEGER;
	DEFINE biTipoOrder      INTEGER;
	DEFINE cSituacion    	CHAR(1);
	DEFINE sCausa 			SMALLINT; 
	DEFINE cNumCte 			CHAR(20);
	DEFINE cNumsucursal		CHAR(4);
	DEFINE sRegion 			SMALLINT;
	DEFINE cFechaInicio 	DATE;
	DEFINE cFechaFin 		DATE;
	DEFINE cNum_empleado    CHAR(8);
	DEFINE cOrigen			CHAR(12);
	DEFINE sNumCiudad		SMALLINT;
	DEFINE cNombreCiudad	CHAR(30);
	DEFINE cSiglas_ciudad   CHAR(4);
	DEFINE cMesIni          CHAR(2);
	DEFINE cAnoIni			CHAR(4);
	DEFINE cMesFin			CHAR(2);
	DEFINE cAnoFin			CHAR(4);
	DEFINE dtfechainicial	DATE;
	DEFINE dtfechafinal		DATE;
	DEFINE dtfechainicial2	DATE;
	DEFINE dtfechafinal2	DATE;
	
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET icont=0;
	LET cSituacion= '';
	LET sCausa='';
	LET cNumCte='';
	LET cNumsucursal='';
	LET sRegion=0;
	LET cFechaInicio='';
	LET cFechaFin='';
	LET cNum_empleado='';
	LET cOrigen='';
	LET sNumCiudad=0;
	LET cNombreCiudad='';
	LET cSiglas_ciudad='';
	LET biTipoOrder=piTipoOrder;
	LET dtfechainicial='';		
	LET dtfechafinal='';
	LET dtfechainicial2='';
	LET dtfechafinal2='';
	--------------------------------------------------------------------------
	--SET DEBUG FILE TO '/home/sysifx/Malena/sp_CiLocGeneraRptSituacionCausaCte.out';
	--TRACE ON;
	--------------------------------------------------------------------------
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;			RETURN cCodRet,cSituacion,sCausa,cNumcte,cNumSucursal,sRegion,cFechaInicio,cFechaFin,cNum_empleado,cOrigen,sNumCiudad,cNombreCiudad,cSiglas_ciudad;
		END EXCEPTION;		
		
	--Se realizan las consultas a la tabla se_ctessitespcte para obtener la informacion para generar el reporte de situaciones causas
	
	set isolation to dirty read; -- Lectura de tablas bloqueadas.
	
	-->>>VALORES DEL TIPO DE ORDENAMIENTO
	--1--Sin ordenar
	--2--Ordenar por sucursal
	--3--Ordenar por region

	IF piTipoOrder = 1 THEN 
	
					IF LENGTH(pFechaInicio)<> 7  OR LENGTH(pFechaFin) <> 7 THEN
						FOREACH
							SELECT CTE.sucursal,CTE.numcte,CTE.situacion,CTE.causa,CTE.fchalta::DATE,CTE.fchmodifica::DATE,CTE.empleadoefectuo,CTE.cvesitesporigen,CAT.numero_region,CAT.numerociudad,CAT.nombreciudad,CAT.inicialciudad
							INTO  cNumSucursal,cNumCte,cSituacion,sCausa,cFechaInicio,cFechaFin,cNum_empleado,cOrigen,sRegion,sNumCiudad,cNombreCiudad,cSiglas_ciudad
							FROM bdisitesp:se_ctessitespcte CTE 
							INNER JOIN bdinteg:si_sucursales AS SUC ON CTE.sucursal=SUC.sucursal 
							INNER JOIN bdinteg:si_ciudades AS CIU ON (SUC.ciudad = CIU.ciudad)AND (SUC.estado = CIU.estado)
							INNER JOIN bdinteg:si_catciudades AS CAT ON (CIU.ciudad_coppel = CAT.numerociudad)
							INNER JOIN bdinteg:si_regiones AS REG ON (CAT.numero_region = REG.numero_region)
							WHERE CTE.situacion = CASE WHEN pSituacion = '' THEN CTE.situacion ELSE pSituacion END
							AND CTE.causa = CASE WHEN pCausa = 0 THEN CTE.causa ELSE pCausa END
							AND CTE.numcte = CASE WHEN pNumcte = '' THEN CTE.numcte ELSE pNumcte END
							AND CTE.sucursal = CASE WHEN pNumsucursal = '' THEN CTE.sucursal ELSE pNumsucursal END
							AND CAT.numero_region = CASE WHEN pNumRegion= 0 THEN CAT.numero_region ELSE pNumregion END
							AND CTE.fchalta::DATE between pFechaInicio::DATE AND pFechaFin::DATE 
							ORDER BY CTE.numcte
							LET icont=icont+1;
							RETURN cCodRet,cSituacion,sCausa,cNumcte,cNumSucursal,sRegion,cFechaInicio,cFechaFin,cNum_empleado,cOrigen,sNumCiudad,cNombreCiudad,cSiglas_ciudad WITH RESUME;
						END FOREACH;
					ELSE
					LET cMesIni = SUBSTR(TRIM(pFechaInicio), 1, 2);
					LET cAnoIni = SUBSTR(TRIM(pFechaInicio), 4, 7);
					LET cMesFin = SUBSTR(TRIM(pFechaFin), 1, 2);
					LET cAnoFin = SUBSTR(TRIM(pFechaFin), 4, 7);
					execute  procedure bdinteg:sp_diaprimeroultimomesanio(cMesIni,cAnoIni) into cCod_ret2,dtfechainicial, dtfechainicial2 ;
					execute  procedure bdinteg:sp_diaprimeroultimomesanio(cMesFin,cAnoFin) into cCod_ret2,dtfechafinal, dtfechafinal2 ;			
						FOREACH
							SELECT CTE.sucursal,CTE.numcte,CTE.situacion,CTE.causa,CTE.fchalta::DATE,CTE.fchmodifica::DATE,CTE.empleadoefectuo,CTE.cvesitesporigen,CAT.numero_region,CAT.numerociudad,CAT.nombreciudad,CAT.inicialciudad
							INTO  cNumSucursal,cNumCte,cSituacion,sCausa,cFechaInicio,cFechaFin,cNum_empleado,cOrigen,sRegion,sNumCiudad,cNombreCiudad,cSiglas_ciudad
							FROM bdisitesp:se_ctessitespcte CTE 
							INNER JOIN bdinteg:si_sucursales AS SUC ON CTE.sucursal=SUC.sucursal 
							INNER JOIN bdinteg:si_ciudades AS CIU ON (SUC.ciudad = CIU.ciudad)AND (SUC.estado = CIU.estado)
							INNER JOIN bdinteg:si_catciudades AS CAT ON (CIU.ciudad_coppel = CAT.numerociudad)
							INNER JOIN bdinteg:si_regiones AS REG ON (CAT.numero_region = REG.numero_region)
							WHERE CTE.situacion = CASE WHEN pSituacion = '' THEN CTE.situacion ELSE pSituacion END
							AND CTE.causa = CASE WHEN pCausa = 0 THEN CTE.causa ELSE pCausa END
							AND	CTE.numcte = CASE WHEN pNumcte = '' THEN CTE.numcte ELSE pNumcte END
							AND CTE.sucursal = CASE WHEN pNumsucursal = '' THEN CTE.sucursal ELSE pNumsucursal END
							AND CAT.numero_region = CASE WHEN pNumRegion= 0 THEN CAT.numero_region ELSE pNumregion END
							AND CTE.fchalta::DATE between dtfechainicial::DATE AND dtfechafinal2::DATE 
							ORDER BY CTE.numcte
							LET icont=icont+1;
							RETURN cCodRet,cSituacion,sCausa,cNumcte,cNumSucursal,sRegion,cFechaInicio,cFechaFin,cNum_empleado,cOrigen,sNumCiudad,cNombreCiudad,cSiglas_ciudad WITH RESUME;
						END FOREACH;
					END IF;
	END IF;		
	
	IF piTipoOrder= 2 THEN 		
			IF LENGTH(pFechaInicio)<> 7  OR LENGTH(pFechaFin) <> 7 THEN
					FOREACH			
						SELECT CTE.sucursal,CTE.numcte,CTE.situacion,CTE.causa,CTE.fchalta::DATE,CTE.fchmodifica::DATE,CTE.empleadoefectuo,CTE.cvesitesporigen,CAT.numero_region,CAT.numerociudad,CAT.nombreciudad,CAT.inicialciudad
						INTO  cNumSucursal,cNumCte,cSituacion,sCausa,cFechaInicio,cFechaFin,cNum_empleado,cOrigen,sRegion,sNumCiudad,cNombreCiudad,cSiglas_ciudad
						FROM bdisitesp:se_ctessitespcte AS CTE
						INNER JOIN bdinteg:si_sucursales AS SUC ON CTE.sucursal=SUC.sucursal 
						INNER JOIN bdinteg:si_ciudades AS CIU ON (SUC.ciudad = CIU.ciudad)AND (SUC.estado = CIU.estado)
						INNER JOIN bdinteg:si_catciudades AS CAT ON (CIU.ciudad_coppel = CAT.numerociudad)
						INNER JOIN bdinteg:si_regiones AS REG ON (CAT.numero_region = REG.numero_region)
						WHERE CTE.situacion = CASE WHEN pSituacion = '' THEN CTE.situacion ELSE pSituacion END
						AND CTE.causa = CASE WHEN pCausa = 0 THEN CTE.causa ELSE pCausa END
						AND CTE.numcte = CASE WHEN pNumcte = '' THEN CTE.numcte ELSE pNumcte END
						AND CTE.sucursal = CASE WHEN pNumsucursal = '' THEN CTE.sucursal ELSE pNumsucursal END
						AND CAT.numero_region = CASE WHEN pNumRegion= 0 THEN CAT.numero_region ELSE pNumregion END
						AND CTE.fchalta::DATE between pFechaInicio::DATE AND pFechaFin::DATE
						Order by CTE.sucursal
							LET icont=icont+1;
							RETURN cCodRet,cSituacion,sCausa,cNumcte,cNumSucursal,sRegion,cFechaInicio,cFechaFin,cNum_empleado,cOrigen,sNumCiudad,cNombreCiudad,cSiglas_ciudad WITH RESUME;
					END FOREACH;	
			ELSE 
				LET cMesIni = SUBSTR(TRIM(pFechaInicio), 1, 2);
				LET cAnoIni = SUBSTR(TRIM(pFechaInicio), 4, 7);
				LET cMesFin = SUBSTR(TRIM(pFechaFin), 1, 2);
				LET cAnoFin = SUBSTR(TRIM(pFechaFin), 4, 7);
				execute  procedure bdinteg:sp_diaprimeroultimomesanio(cMesIni,cAnoIni) into cCod_ret2,dtfechainicial, dtfechainicial2 ;
				execute  procedure bdinteg:sp_diaprimeroultimomesanio(cMesFin,cAnoFin) into cCod_ret2,dtfechafinal, dtfechafinal2 ;
					FOREACH			
						SELECT CTE.sucursal,CTE.numcte,CTE.situacion,CTE.causa,CTE.fchalta::DATE,CTE.fchmodifica::DATE,CTE.empleadoefectuo,CTE.cvesitesporigen,CAT.numero_region,CAT.numerociudad,CAT.nombreciudad,CAT.inicialciudad
						INTO  cNumSucursal,cNumCte,cSituacion,sCausa,cFechaInicio,cFechaFin,cNum_empleado,cOrigen,sRegion,sNumCiudad,cNombreCiudad,cSiglas_ciudad
						FROM bdisitesp:se_ctessitespcte AS CTE
						INNER JOIN bdinteg:si_sucursales AS SUC ON CTE.sucursal=SUC.sucursal 
						INNER JOIN bdinteg:si_ciudades AS CIU ON (SUC.ciudad = CIU.ciudad)AND (SUC.estado = CIU.estado)
						INNER JOIN bdinteg:si_catciudades AS CAT ON (CIU.ciudad_coppel = CAT.numerociudad)
						INNER JOIN bdinteg:si_regiones AS REG ON (CAT.numero_region = REG.numero_region)
						WHERE CTE.situacion = CASE WHEN pSituacion = '' THEN CTE.situacion ELSE pSituacion END
						AND CTE.causa = CASE WHEN pCausa = 0 THEN CTE.causa ELSE pCausa END
						AND CTE.numcte = CASE WHEN pNumcte = '' THEN CTE.numcte ELSE pNumcte END
						AND CTE.sucursal = CASE WHEN pNumsucursal = '' THEN CTE.sucursal ELSE pNumsucursal END
						AND CAT.numero_region = CASE WHEN pNumRegion= 0 THEN CAT.numero_region ELSE pNumregion END
						AND CTE.fchalta::DATE BETWEEN  dtfechainicial::DATE AND dtfechafinal2::DATE
						Order by CTE.sucursal
						LET icont=icont+1;
						RETURN cCodRet,cSituacion,sCausa,cNumcte,cNumSucursal,sRegion,cFechaInicio,cFechaFin,cNum_empleado,cOrigen,sNumCiudad,cNombreCiudad,cSiglas_ciudad WITH RESUME;
					END FOREACH;						
			END IF;
	END IF;
	IF piTipoOrder= 3  THEN 
			IF LENGTH(pFechaInicio)<> 7  OR LENGTH(pFechaFin) <> 7 THEN

					FOREACH			
						SELECT CTE.sucursal,CTE.numcte,CTE.situacion,CTE.causa,CTE.fchalta::DATE,CTE.fchmodifica::DATE,CTE.empleadoefectuo,CTE.cvesitesporigen,CAT.numero_region,CAT.numerociudad,CAT.nombreciudad,CAT.inicialciudad
						INTO  cNumSucursal,cNumCte,cSituacion,sCausa,cFechaInicio,cFechaFin,cNum_empleado,cOrigen,sRegion,sNumCiudad,cNombreCiudad,cSiglas_ciudad
						FROM bdisitesp:se_ctessitespcte AS CTE
						INNER JOIN bdinteg:si_sucursales AS SUC ON CTE.sucursal=SUC.sucursal 
						INNER JOIN bdinteg:si_ciudades AS CIU ON (SUC.ciudad = CIU.ciudad)AND (SUC.estado = CIU.estado)
						INNER JOIN bdinteg:si_catciudades AS CAT ON (CIU.ciudad_coppel = CAT.numerociudad)
						INNER JOIN bdinteg:si_regiones AS REG ON (CAT.numero_region = REG.numero_region)
						WHERE CTE.situacion = CASE WHEN pSituacion = '' THEN CTE.situacion ELSE pSituacion END
						AND CTE.causa = CASE WHEN pCausa = 0 THEN CTE.causa ELSE pCausa END
						AND CTE.numcte = CASE WHEN pNumcte = '' THEN CTE.numcte ELSE pNumcte END
						AND CTE.sucursal = CASE WHEN pNumsucursal = '' THEN CTE.sucursal ELSE pNumsucursal END
						AND CAT.numero_region = CASE WHEN pNumRegion= 0 THEN CAT.numero_region ELSE pNumregion END
						AND CTE.fchalta::DATE between pFechaInicio::DATE AND pFechaFin::DATE
						Order by CAT.numero_region
						LET icont=icont+1;
						RETURN cCodRet,cSituacion,sCausa,cNumcte,cNumSucursal,sRegion,cFechaInicio,cFechaFin,cNum_empleado,cOrigen,sNumCiudad,cNombreCiudad,cSiglas_ciudad WITH RESUME;
					END FOREACH;
			ELSE
				LET cMesIni = SUBSTR(TRIM(pFechaInicio), 1, 2);
				LET cAnoIni = SUBSTR(TRIM(pFechaInicio), 4, 7);
				LET cMesFin = SUBSTR(TRIM(pFechaFin), 1, 2);
				LET cAnoFin = SUBSTR(TRIM(pFechaFin), 4, 7);
				execute  procedure bdinteg:sp_diaprimeroultimomesanio(cMesIni,cAnoIni) into cCod_ret2,dtfechainicial, dtfechainicial2 ;
				execute  procedure bdinteg:sp_diaprimeroultimomesanio(cMesFin,cAnoFin) into cCod_ret2,dtfechafinal, dtfechafinal2 ;
					FOREACH			
						SELECT CTE.sucursal,CTE.numcte,CTE.situacion,CTE.causa,CTE.fchalta::DATE,CTE.fchmodifica::DATE,CTE.empleadoefectuo,CTE.cvesitesporigen,CAT.numero_region,CAT.numerociudad,CAT.nombreciudad,CAT.inicialciudad
						INTO  cNumSucursal,cNumCte,cSituacion,sCausa,cFechaInicio,cFechaFin,cNum_empleado,cOrigen,sRegion,sNumCiudad,cNombreCiudad,cSiglas_ciudad
						FROM bdisitesp:se_ctessitespcte AS CTE
						INNER JOIN bdinteg:si_sucursales AS SUC ON CTE.sucursal=SUC.sucursal 
						INNER JOIN bdinteg:si_ciudades AS CIU ON (SUC.ciudad = CIU.ciudad)AND (SUC.estado = CIU.estado)
						INNER JOIN bdinteg:si_catciudades AS CAT ON (CIU.ciudad_coppel = CAT.numerociudad)
						INNER JOIN bdinteg:si_regiones AS REG ON (CAT.numero_region = REG.numero_region)
						WHERE CTE.situacion = CASE WHEN pSituacion = '' THEN CTE.situacion ELSE pSituacion END
						AND CTE.causa = CASE WHEN pCausa = 0 THEN CTE.causa ELSE pCausa END
						AND CTE.numcte = CASE WHEN pNumcte = '' THEN CTE.numcte ELSE pNumcte END
						AND CTE.sucursal = CASE WHEN pNumsucursal = '' THEN CTE.sucursal ELSE pNumsucursal END
						AND CAT.numero_region = CASE WHEN pNumRegion= 0 THEN CAT.numero_region ELSE pNumregion END
						AND CTE.fchalta::DATE BETWEEN dtfechainicial::DATE AND dtfechafinal2::DATE
						Order by CAT.numero_region		
						LET icont=icont+1;
						RETURN cCodRet,cSituacion,sCausa,cNumcte,cNumSucursal,sRegion,cFechaInicio,cFechaFin,cNum_empleado,cOrigen,sNumCiudad,cNombreCiudad,cSiglas_ciudad WITH RESUME;
					END FOREACH;						
			END IF;
	END IF;			
    IF icont == 0 THEN 
		LET cCodret='00001';  --'No hay Informacion para los criterios de busqueda seleccionados';
        RETURN cCodRet,cSituacion,sCausa,cNumcte,cNumSucursal,sRegion,cFechaInicio,cFechaFin,cNum_empleado,cOrigen,sNumCiudad,cNombreCiudad,cSiglas_ciudad WITH RESUME;
    END IF;

	END;
END PROCEDURE
DOCUMENT
'AUTOR       : Maria Elena Angulo Aispuro',
'DESCRIPCION : Devuelve un listado del resultado de la busqueda segun los criterios seleccionados por el cliente para la generacion del reporte de situacion especial',
'FECHA       : 17 de Agosto de 2010',
'VERSION     : 20100817.1700',
'BD          : BDICOBRANZA';

CREATE PROCEDURE "informix".sp_cilocgenerarpttotalalarmas(pNumCte CHAR(20), pSucursal CHAR(4), pRegion SMALLINT, pFechaIni CHAR(10), pFechaFin CHAR(10), pTipo INTEGER, pSitAlarma CHAR(2))
RETURNING CHAR(5) AS CODIGO, CHAR(4) AS SUCURSAL, SMALLINT as REGION ,CHAR(4) AS SITUACIONESP,CHAR (4) AS SITUACIONALARMA ,CHAR(40) AS SITUACIONALARMADESC,  INTEGER AS TOTAL;

--Declaracion de variables
------------------------------------------------------------
DEFINE sql_err 			                INTEGER;
DEFINE isam_err 		                INTEGER;
DEFINE error_info		                CHAR(80);
DEFINE cCod_ret                         CHAR(6);
DEFINE cCod_ret2                         CHAR(6);
DEFINE cSucursal						CHAR(4);
DEFINE cNumMarcas						INTEGER;
DEFINE cTpoMarca						CHAR(4);
DEFINE sRegion							SMALLINT;
DEFINE cTotal							INTEGER;
DEFINE cSituacionAlarma					CHAR(4);
DEFINE cSituacionAlarmaDesc				CHAR(40);
DEFINE cSituacionEsp					CHAR(4);
DEFINE cMesIni							CHAR(2);
DEFINE cAnoIni							CHAR(4);
DEFINE cMesFin							CHAR(2);
DEFINE cAnoFin							CHAR(4);
DEFINE dtfechainicial 					DATE;
DEFINE dtfechainicial2 					DATE;
DEFINE dtfechafinal     				DATE;
DEFINE dtfechafinal2 					DATE;
-----------------------------------------------------
LET cCod_ret  = '00000';
LET sql_err   = 0;
LET cSucursal = '';
LET cNumMarcas	=0;
LET cTpoMarca	= '';
LET sRegion		= '';
LET cTotal = 0;
LET cSituacionAlarma = '';
LET cSituacionEsp='';
LET cSituacionAlarmaDesc='';

  BEGIN

	ON EXCEPTION SET sql_err, isam_err, error_info
		LET cCod_ret = sql_err;
		RETURN cCod_ret, NVL(cSucursal, ''), NVL(sRegion, 0), NVL(cSituacionEsp, ''), NVL(cSituacionAlarma, ''), NVL(cSituacionAlarmaDesc, ''),NVL(cTotal, 0 );
	END EXCEPTION;
	
	--SET DEBUG FILE TO "/home/sysifx/jesusm/sp_CiLocGeneraRptTotalAlarmas.out";
	--TRACE ON;
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	IF pFechaIni = '' OR pFechaIni IS NULL THEN
		LET cCod_ret= '00001';
		RETURN cCod_ret, NVL(cSucursal, ''), NVL(sRegion, 0), NVL(cSituacionEsp, ''), NVL(cSituacionAlarma, ''), NVL(cSituacionAlarmaDesc, ''),NVL(cTotal, 0 );
	END IF
	IF pTipo = '' OR pTipo IS NULL THEN
		LET cCod_ret= '00002';
		RETURN cCod_ret, NVL(cSucursal, ''), NVL(sRegion, 0), NVL(cSituacionEsp, ''), NVL(cSituacionAlarma, ''), NVL(cSituacionAlarmaDesc, ''),NVL(cTotal, 0 );
	END IF
	--ORDENADO

	IF pTipo = 2 THEN --POR SUCURSAL		
		
		IF LENGTH (pFechaIni) = 7 AND LENGTH (pFechaFin) = 7 THEN
			LET cMesIni = SUBSTR(TRIM(pFechaIni), 1, 2);
			LET cAnoIni = SUBSTR(TRIM(pFechaIni), 4, 7);
			LET cMesFin = SUBSTR(TRIM(pFechaFin), 1, 2);
			LET cAnoFin = SUBSTR(TRIM(pFechaFin), 4, 7);
			execute  procedure bdinteg:sp_diaprimeroultimomesanio(cMesIni,cAnoIni) into cCod_ret2,dtfechainicial, dtfechainicial2 ;
			IF cCod_ret2 <> '000000' THEN 
				LET cCod_ret= '00005';
				RETURN cCod_ret, NVL(cSucursal, ''), NVL(sRegion, 0), NVL(cSituacionEsp, ''), NVL(cSituacionAlarma, ''), NVL(cSituacionAlarmaDesc, ''),NVL(cTotal, 0 );
			END IF;	
			execute  procedure bdinteg:sp_diaprimeroultimomesanio(cMesFin,cAnoFin) into cCod_ret2,dtfechafinal, dtfechafinal2 ;
			IF cCod_ret2 <> '000000' THEN 
				 LET cCod_ret= '00006';
				RETURN cCod_ret, NVL(cSucursal, ''), NVL(sRegion, 0), NVL(cSituacionEsp, ''), NVL(cSituacionAlarma, ''), NVL(cSituacionAlarmaDesc, ''),NVL(cTotal, 0 );
			END IF;	
			FOREACH
		
				SELECT m.sucursal, m.situacion,m.estatus,e.desc_estatus,count(m.estatus)
				INTO cSucursal, cSituacionEsp,cSituacionAlarma,cSituacionAlarmaDesc, cTotal
				FROM cb_alerta_succliente m
				INNER JOIN bdicobranza:cb_estatus_loc e ON (m.estatus= e.tipo)
			--	INNER JOIN  bdisitesp:se_ctessitespcte p ON (m.numcte = p.numcte)
				INNER JOIN bdinteg:si_sucursales s ON (m.sucursal= s.sucursal)
				INNER JOIN bdinteg: si_ciudades d ON (d.ciudad = s.ciudad) AND (s.estado= d.estado)
				INNER JOIN bdinteg:si_catciudades c ON (d.ciudad_coppel = c.numerociudad) 
				WHERE c.numero_region = c.numero_region 
				AND m.numcte = CASE when pNumCte = '' THEN  m.numcte ELSE pNumCte END
				AND s.sucursal = CASE when pSucursal = '' THEN  s.sucursal   ELSE pSucursal END
				AND m.situacion in ('L','M')
				AND m.estatus = CASE when pSitAlarma = '' THEN  m.estatus   ELSE pSitAlarma END
				AND m.fecha BETWEEN dtfechainicial AND dtfechafinal2
				Group by m.sucursal, m.situacion,m.estatus,e.desc_estatus
				ORDER BY m.sucursal,m.situacion,m.estatus,e.desc_estatus
				
				RETURN cCod_ret, NVL(cSucursal, ''), NVL(sRegion, 0), NVL(cSituacionEsp, ''), NVL(cSituacionAlarma, ''), NVL(cSituacionAlarmaDesc, ''),NVL(cTotal, 0 ) WITH RESUME;	
				
			END FOREACH;		
			
		ELSE 
		
			FOREACH WITH HOLD
				SELECT m.sucursal, m.situacion,m.estatus,e.desc_estatus,count(m.estatus)
				INTO cSucursal, cSituacionEsp,cSituacionAlarma,cSituacionAlarmaDesc, cTotal
				FROM cb_alerta_succliente m
				INNER JOIN bdicobranza:cb_estatus_loc e ON (m.estatus= e.tipo)
				--INNER JOIN  bdisitesp:se_ctessitespcte p ON (m.numcte = p.numcte)
				INNER JOIN bdinteg:si_sucursales s ON (m.sucursal= s.sucursal)
				INNER JOIN bdinteg: si_ciudades d ON (d.ciudad = s.ciudad) AND (s.estado= d.estado)
				INNER JOIN bdinteg:si_catciudades c ON (d.ciudad_coppel = c.numerociudad) 
				WHERE c.numero_region = c.numero_region 
				AND m.numcte = CASE when pNumCte = '' THEN  m.numcte ELSE pNumCte END
				AND s.sucursal = CASE when pSucursal = '' THEN  s.sucursal   ELSE pSucursal END
				AND m.situacion in ('L','M')
				AND m.estatus = CASE when pSitAlarma = '' THEN  m.estatus   ELSE pSitAlarma END
				AND m.fecha BETWEEN pFechaIni AND pFechaFin
				Group by m.sucursal, m.situacion,m.estatus,e.desc_estatus
				ORDER BY m.sucursal,m.situacion,m.estatus,e.desc_estatus
							
				RETURN cCod_ret, NVL(cSucursal, ''), NVL(sRegion, 0), NVL(cSituacionEsp, ''), NVL(cSituacionAlarma, ''), NVL(cSituacionAlarmaDesc, ''),NVL(cTotal, 0 ) WITH RESUME;	
				
			END FOREACH;
		
		END IF;		
			
	ELIF  pTipo= '3' THEN --TIPO  POR REGION	
	
		IF LENGTH (pFechaIni) = 7 AND LENGTH (pFechaFin) = 7 THEN
			LET cMesIni = SUBSTR(TRIM(pFechaIni), 1, 2);
			LET cAnoIni = SUBSTR(TRIM(pFechaIni), 4, 7);
			LET cMesFin = SUBSTR(TRIM(pFechaFin), 1, 2);
			LET cAnoFin = SUBSTR(TRIM(pFechaFin), 4, 7);
			execute  procedure bdinteg:sp_diaprimeroultimomesanio(cMesIni,cAnoIni) into cCod_ret2,dtfechainicial, dtfechainicial2 ;
			IF cCod_ret2 <> '000000' THEN 
				LET cCod_ret= '00005';
				RETURN cCod_ret, NVL(cSucursal, ''), NVL(sRegion, 0), NVL(cSituacionEsp, ''), NVL(cSituacionAlarma, ''), NVL(cSituacionAlarmaDesc, ''),NVL(cTotal, 0 );	
			END IF;	
			execute  procedure bdinteg:sp_diaprimeroultimomesanio(cMesFin,cAnoFin) into cCod_ret2,dtfechafinal, dtfechafinal2 ;
			IF cCod_ret2 <> '000000' THEN 
				 LET cCod_ret= '00006';
				RETURN cCod_ret, NVL(cSucursal, ''), NVL(sRegion, 0), NVL(cSituacionEsp, ''), NVL(cSituacionAlarma, ''), NVL(cSituacionAlarmaDesc, ''),NVL(cTotal, 0 );
			END IF;	
			FOREACH WITH HOLD
				SELECT c.numero_region, m.situacion,m.estatus,e.desc_estatus,count(m.estatus)
				INTO sRegion, cSituacionEsp,cSituacionAlarma,cSituacionAlarmaDesc, cTotal
				FROM cb_alerta_succliente m
				INNER JOIN bdicobranza:cb_estatus_loc e ON (m.estatus= e.tipo)
			--	INNER JOIN  bdisitesp:se_ctessitespcte p ON (m.numcte = p.numcte)
				INNER JOIN bdinteg:si_sucursales s ON (m.sucursal= s.sucursal)
				INNER JOIN bdinteg: si_ciudades d ON (d.ciudad = s.ciudad) AND (s.estado= d.estado)
				INNER JOIN bdinteg:si_catciudades c ON (d.ciudad_coppel = c.numerociudad) 
				WHERE c.numero_region = CASE when pRegion = 0 THEN  c.numero_region   ELSE pRegion END
				AND m.numcte = CASE when pNumCte = '' THEN  m.numcte ELSE pNumCte END
				AND s.sucursal = s.sucursal
				AND m.situacion in ('L','M')
				AND m.estatus = CASE when pSitAlarma = '' THEN  m.estatus   ELSE pSitAlarma END
				AND m.fecha BETWEEN dtfechainicial AND dtfechafinal2
				Group by c.numero_region, m.situacion,m.estatus,e.desc_estatus
				ORDER BY c.numero_region,m.situacion,m.estatus,e.desc_estatus
				
				RETURN cCod_ret, NVL(cSucursal, ''), NVL(sRegion, 0), NVL(cSituacionEsp, ''), NVL(cSituacionAlarma, ''), NVL(cSituacionAlarmaDesc, ''),NVL(cTotal, 0 ) WITH RESUME;	
			
			END FOREACH;
			
		ELSE 
		
			FOREACH WITH HOLD
				SELECT c.numero_region, m.situacion,m.estatus,e.desc_estatus,count(m.estatus)
				INTO sRegion, cSituacionEsp,cSituacionAlarma,cSituacionAlarmaDesc, cTotal
				FROM cb_alerta_succliente m
				INNER JOIN bdicobranza:cb_estatus_loc e ON (m.estatus= e.tipo)
			--	INNER JOIN  bdisitesp:se_ctessitespcte p ON (m.numcte = p.numcte)
				INNER JOIN bdinteg:si_sucursales s ON (m.sucursal= s.sucursal)
				INNER JOIN bdinteg: si_ciudades d ON (d.ciudad = s.ciudad) AND (s.estado= d.estado)
				INNER JOIN bdinteg:si_catciudades c ON (d.ciudad_coppel = c.numerociudad) 
				WHERE c.numero_region = CASE when pRegion = 0 THEN  c.numero_region   ELSE pRegion END
				AND m.numcte = CASE when pNumCte = '' THEN  m.numcte ELSE pNumCte END
				AND s.sucursal = s.sucursal
				AND m.situacion in ('L','M')
				AND m.estatus = CASE when pSitAlarma = '' THEN  m.estatus   ELSE pSitAlarma END
				AND m.fecha BETWEEN pFechaIni AND pFechaFin
				Group by c.numero_region, m.situacion,m.estatus,e.desc_estatus
				ORDER BY c.numero_region,m.situacion,m.estatus,e.desc_estatus
				
				RETURN cCod_ret, NVL(cSucursal, ''), NVL(sRegion, 0), NVL(cSituacionEsp, ''), NVL(cSituacionAlarma, ''), NVL(cSituacionAlarmaDesc, ''),NVL(cTotal, 0 ) WITH RESUME;	
				
			END FOREACH;
		
		END IF;
	ELSE 
		LET cCod_ret= '00004';
		RETURN cCod_ret, NVL(cSucursal, ''), NVL(sRegion, 0), NVL(cSituacionEsp, ''), NVL(cSituacionAlarma, ''), NVL(cSituacionAlarmaDesc, ''),NVL(cTotal, 0 );
	END IF;

END;
END PROCEDURE

DOCUMENT
'AUTOR: ABIGAIL VASAVILBAZO CAÑEDO, HECTOR MANUEL BOJORQUEZ',
'DESCRIPCION: GENERA INFORMACION PARA REPORTE DE ALARMAS (TOTALIZADO POR REGION O SUCURSAL)',
'BD: BDICOBRANZA',
'VERSION: 20100831.1123';

CREATE PROCEDURE "informix".sp_cilocgenerarpttotalmarcas(pNumCte CHAR(20), pSucursal CHAR(4), pRegion SMALLINT, pFechaIni CHAR(10), pFechaFin CHAR(10), pTipo INTEGER, pMarca CHAR(4), pSitMarca CHAR(4))
RETURNING CHAR(5) AS CODIGO, CHAR(4) AS SUCURSAL ,CHAR(4) AS TIPOMARCA, CHAR(40) AS SITUACIONESP, INTEGER AS TOTAL , SMALLINT as REGION;

--Declaracion de variables
------------------------------------------------------------
DEFINE sql_err 			                INTEGER;
DEFINE isam_err 		                INTEGER;
DEFINE error_info		                CHAR(80);
DEFINE cCod_ret                         CHAR(6);
DEFINE cSucursal						CHAR(4);
DEFINE cNumMarcas						INTEGER;
DEFINE cTpoMarca						CHAR(4);
DEFINE sRegion							SMALLINT;
DEFINE cTotal							INTEGER;
DEFINE cSituacionMarca					CHAR(40);
DEFINE cMesIni							CHAR(2);
DEFINE cAnoIni							CHAR(4);
DEFINE cMesFin							CHAR(2);
DEFINE cAnoFin							CHAR(4);
DEFINE cCod_ret2						CHAR(5);
DEFINE dtfechainicial					DATE;
DEFINE dtfechafinal						DATE;
DEFINE dtfechainicial2					DATE;
DEFINE dtfechafinal2					DATE;
-----------------------------------------------------
LET cCod_ret  = '00000';
LET sql_err   = 0;
LET cSucursal = '';
LET cNumMarcas	=0;
LET cTpoMarca	= '';
LET sRegion		= '';
LET cTotal = 0;
LET cSituacionMarca = '';
LET cCod_ret2   = '';
LET cMesIni		= '';
LET cAnoIni		= '';
LET cMesFin		= '';
LET cAnoFin		= '';
LET dtfechainicial='';		
LET dtfechafinal='';
LET dtfechainicial2='';
LET dtfechafinal2='';


  BEGIN

	ON EXCEPTION SET sql_err, isam_err, error_info
		LET cCod_ret = sql_err;
		RETURN cCod_ret, cSucursal, cTpoMarca, cSituacionMarca, cTotal, sRegion ;
	END EXCEPTION;
	
	--SET DEBUG FILE TO "/tmp/sp_CiLocGeneraRptTotalMarcas.out";
	--TRACE ON;
	
	IF pFechaIni = '' OR pFechaIni IS NULL THEN
		LET cCod_ret= '00001';
		RETURN cCod_ret, cSucursal, cTpoMarca, cSituacionMarca, cTotal, sRegion ;		
	END IF
	
	--ORDENADO
	IF pTipo = 2 THEN --POR SUCURSAL		
		
		IF LENGTH (pFechaIni) = 7 AND LENGTH (pFechaFin) = 7 THEN
		
			LET cMesIni = SUBSTR(TRIM(pFechaIni), 1, 2);
			LET cAnoIni = SUBSTR(TRIM(pFechaIni), 4, 7);
			LET cMesFin = SUBSTR(TRIM(pFechaFin), 1, 2);
			LET cAnoFin = SUBSTR(TRIM(pFechaFin), 4, 7);
			execute  procedure bdinteg:sp_diaprimeroultimomesanio(cMesIni,cAnoIni) into cCod_ret2,dtfechainicial, dtfechainicial2 ;
			execute  procedure bdinteg:sp_diaprimeroultimomesanio(cMesFin,cAnoFin) into cCod_ret2,dtfechafinal, dtfechafinal2 ;
			
			FOREACH				
		
				SELECT m.sucursal, COUNT(m.numcte), m.tipo_marca,e.desc_estatus
				INTO cSucursal,cTotal,cTpoMarca, cSituacionMarca
				FROM cb_marcacliente m
				INNER JOIN bdinteg:si_sucursales s ON (m.sucursal= s.sucursal)
				INNER JOIN bdinteg: si_ciudades d ON (d.ciudad = s.ciudad) AND (s.estado= d.estado)
				INNER JOIN bdinteg:si_catciudades c ON (d.ciudad_coppel = c.numerociudad) 
				INNER JOIN bdicobranza:cb_tipo_marca t ON (t.tipo = m.tipo_marca )
				INNER JOIN bdicobranza:cb_estatus_loc e ON (m.estatus= e.tipo)
				INNER JOIN  bdisitesp:se_ctessitespcte p ON (m.numcte = p.numcte)
				WHERE c.numero_region = CASE when pRegion = 0 THEN  c.numero_region   ELSE pRegion END
				AND m.numcte = CASE when pNumCte = '' THEN  m.numcte ELSE pNumCte END
				AND s.sucursal = CASE when pSucursal = '' THEN  s.sucursal   ELSE pSucursal END
				AND tipo_marca = CASE when pMarca = '' THEN  m.tipo_marca   ELSE pMarca END
				AND m.estatus = CASE when pSitMarca = '' THEN  m.estatus   ELSE pSitMarca END 
				AND m.fecha_insert::DATE between dtfechainicial::DATE AND dtfechafinal2::DATE 
				AND p.situacion IN ('L', 'M')
				Group by m.sucursal,tipo_marca,e.desc_estatus
				ORDER BY m.sucursal, m.tipo_marca
				
				RETURN cCod_ret, cSucursal, cTpoMarca, cSituacionMarca, cTotal, sRegion WITH RESUME;
				
			END FOREACH;		
			
		ELSE 
		
			FOREACH WITH HOLD
		
				SELECT m.sucursal, COUNT(m.numcte), m.tipo_marca,e.desc_estatus
				INTO cSucursal,cTotal,cTpoMarca, cSituacionMarca
				FROM cb_marcacliente m
				INNER JOIN bdinteg:si_sucursales s ON (m.sucursal= s.sucursal)
				INNER JOIN bdinteg: si_ciudades d ON (d.ciudad = s.ciudad) AND (s.estado= d.estado)
				INNER JOIN bdinteg:si_catciudades c ON (d.ciudad_coppel = c.numerociudad) 
				INNER JOIN bdicobranza:cb_tipo_marca t ON (t.tipo = m.tipo_marca )
				INNER JOIN bdicobranza:cb_estatus_loc e ON (m.estatus= e.tipo)
				INNER JOIN  bdisitesp:se_ctessitespcte p ON (m.numcte = p.numcte)
				WHERE c.numero_region = CASE when pRegion = 0 THEN  c.numero_region   ELSE pRegion END
				AND m.numcte = CASE when pNumCte = '' THEN  m.numcte ELSE pNumCte END
				AND s.sucursal = CASE when pSucursal = '' THEN  s.sucursal   ELSE pSucursal END
				AND tipo_marca = CASE when pMarca = '' THEN  m.tipo_marca   ELSE pMarca END
				AND m.estatus = CASE when pSitMarca = '' THEN  m.estatus   ELSE pSitMarca END 
				AND m.fecha_insert BETWEEN pFechaIni AND pFechaFin
				AND p.situacion IN ('L', 'M')
				Group by m.sucursal,tipo_marca,e.desc_estatus	
				ORDER BY m.sucursal,m.tipo_marca
				
				RETURN cCod_ret, cSucursal, cTpoMarca, cSituacionMarca, cTotal, sRegion WITH RESUME;
				
			END FOREACH;
		
		END IF;		
			
	ELIF  pTipo= '3' THEN --TIPO  POR REGION
	
	
		IF LENGTH (pFechaIni) = 7 AND LENGTH (pFechaFin) = 7 THEN
			LET cMesIni = SUBSTR(TRIM(pFechaIni), 1, 2);
			LET cAnoIni = SUBSTR(TRIM(pFechaIni), 4, 7);
			LET cMesFin = SUBSTR(TRIM(pFechaFin), 1, 2);
			LET cAnoFin = SUBSTR(TRIM(pFechaFin), 4, 7);
			execute  procedure bdinteg:sp_diaprimeroultimomesanio(cMesIni,cAnoIni) into cCod_ret2,dtfechainicial, dtfechainicial2 ;
			execute  procedure bdinteg:sp_diaprimeroultimomesanio(cMesFin,cAnoFin) into cCod_ret2,dtfechafinal, dtfechafinal2 ;
		
			FOREACH WITH HOLD
	
				SELECT c.numero_region, COUNT(m.numcte),m.tipo_marca,e.desc_estatus
				INTO sRegion,cTotal,cTpoMarca, cSituacionMarca
				FROM cb_marcacliente m
				INNER JOIN bdinteg:si_sucursales s ON (m.sucursal= s.sucursal)
				INNER JOIN bdinteg: si_ciudades d ON (d.ciudad = s.ciudad) AND (s.estado= d.estado)
				INNER JOIN bdinteg:si_catciudades c ON (d.ciudad_coppel = c.numerociudad) 
				INNER JOIN bdicobranza:cb_tipo_marca t ON (t.tipo = m.tipo_marca )
				INNER JOIN bdicobranza:cb_estatus_loc e ON (m.estatus= e.tipo)
				INNER JOIN  bdisitesp:se_ctessitespcte p ON (m.numcte = p.numcte)
				WHERE c.numero_region = CASE when pRegion = 0 THEN  c.numero_region   ELSE pRegion END
				AND m.numcte = CASE when pNumCte = '' THEN  m.numcte ELSE pNumCte END
				AND s.sucursal = CASE when pSucursal = '' THEN  s.sucursal   ELSE pSucursal END
				AND tipo_marca = CASE when pMarca = '' THEN  m.tipo_marca   ELSE pMarca END
				AND m.estatus = CASE when pSitMarca = '' THEN  m.estatus   ELSE pSitMarca END
				AND m.fecha_insert::DATE between dtfechainicial::DATE AND dtfechafinal2::DATE 
				AND p.situacion IN ('L', 'M')
				Group by c.numero_region,tipo_marca,e.desc_estatus
				ORDER BY c.numero_region,m.tipo_marca

				RETURN cCod_ret, cSucursal, cTpoMarca, cSituacionMarca, cTotal, sRegion WITH RESUME;
			
			END FOREACH;
			
		ELSE 
		
			FOREACH WITH HOLD
				
				SELECT c.numero_region, COUNT(m.numcte),tipo_marca,e.desc_estatus
				INTO sRegion,cTotal,cTpoMarca, cSituacionMarca
				FROM cb_marcacliente m
				INNER JOIN bdinteg:si_sucursales s ON (m.sucursal= s.sucursal)
				INNER JOIN bdinteg: si_ciudades d ON (d.ciudad = s.ciudad) AND (s.estado= d.estado)
				INNER JOIN bdinteg:si_catciudades c ON (d.ciudad_coppel = c.numerociudad) 
				INNER JOIN bdicobranza:cb_tipo_marca t ON (t.tipo = m.tipo_marca )
				INNER JOIN bdicobranza:cb_estatus_loc e ON (m.estatus= e.tipo)
				INNER JOIN  bdisitesp:se_ctessitespcte p ON (m.numcte = p.numcte)
				WHERE c.numero_region = CASE when pRegion = 0 THEN  c.numero_region   ELSE pRegion END
				AND m.numcte = CASE when pNumCte = '' THEN  m.numcte ELSE pNumCte END
				AND s.sucursal = CASE when pSucursal = '' THEN  s.sucursal   ELSE pSucursal END
				AND tipo_marca = CASE when pMarca = '' THEN  m.tipo_marca   ELSE pMarca END
				AND m.estatus = CASE when pSitMarca = '' THEN  m.estatus   ELSE pSitMarca END 
			    AND m.fecha_insert BETWEEN pFechaIni AND pFechaFin
				AND p.situacion IN ('L', 'M')
				Group by c.numero_region,tipo_marca,e.desc_estatus
				ORDER BY c.numero_region,m.tipo_marca

				RETURN cCod_ret, cSucursal, cTpoMarca, cSituacionMarca, cTotal, sRegion WITH RESUME;
				
			END FOREACH;
		
		END IF;
		
	END IF;

END;
END PROCEDURE

DOCUMENT
'AUTOR: ABIGAIL VASAVILBAZO CAÑEDO, HECTOR MANUEL BOJORQUEZ',
'DESCRIPCION: GENERA INFORMACION PARA REPORTE DE MARCAS (TOTALIZADO POR REGION O SUCURSAL)',
'BD: BDICOBRANZA',
'VERSION: 20100901.1129';

CREATE PROCEDURE "informix".sp_cilocgenerarpttotalsituacioncausa(pSituacion CHAR(4), pCausa SMALLINT,pNumcte CHAR(20), pNumsucursal CHAR(4), pNumRegion SMALLINT, pFechaInicio CHAR(10), pFechaFin CHAR(10), piTipoOrder INTEGER)
RETURNING CHAR(5) AS CODIGO, CHAR(4) AS SUCURSAL , SMALLINT AS REGION ,CHAR(4) AS SITUACIONESP,CHAR(4) AS CAUSA,  INTEGER AS TOTAL;
				
--Declaracion de variables
------------------------------------------------------------
DEFINE sql_err 			                INTEGER;
DEFINE isam_err 		                INTEGER;
DEFINE error_info		                CHAR(80);
DEFINE cCod_ret                         CHAR(6);
DEFINE cCod_ret2                         CHAR(6);
DEFINE cSucursal						CHAR(4);
DEFINE cNumMarcas						INTEGER;
DEFINE sRegion							SMALLINT;
DEFINE cTotal							INTEGER;
DEFINE cSituacionEsp					CHAR(4);
DEFINE cCausa							CHAR(4);
DEFINE cMesIni							CHAR(2);
DEFINE cAnoIni							CHAR(4);
DEFINE cMesFin							CHAR(2);
DEFINE cAnoFin							CHAR(4);
DEFINE dtfechainicial 					DATE;
DEFINE dtfechainicial2 					DATE;
DEFINE dtfechafinal     				DATE;
DEFINE dtfechafinal2 					DATE;
-----------------------------------------------------
LET cCod_ret  = '00000';
LET sql_err   = 0;
LET cSucursal = '';
LET cNumMarcas	=0;
LET sRegion		= '';
LET cTotal = 0;
LET cSituacionEsp='';
LET cCausa = '';

  BEGIN

	ON EXCEPTION SET sql_err, isam_err, error_info
		LET cCod_ret = sql_err;
		RETURN cCod_ret, NVL(cSucursal, ''), NVL(sRegion, 0), NVL(cSituacionEsp, ''), NVL(cCausa, ''), NVL(cTotal, 0 );					
	END EXCEPTION;

	--SET DEBUG FILE TO "/home/sysifx/jesusm/sp_CiLocGeneraRptTotalAlarmas.out";
	--TRACE ON;
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	IF pFechaInicio = '' OR pFechaInicio IS NULL THEN
		LET cCod_ret= '00001';
		RETURN cCod_ret, NVL(cSucursal, ''), NVL(sRegion, 0), NVL(cSituacionEsp, ''), NVL(cCausa, ''), NVL(cTotal, 0 );					
	END IF
	IF piTipoOrder = '' OR piTipoOrder IS NULL THEN
		LET cCod_ret= '00002';
		RETURN cCod_ret, NVL(cSucursal, ''), NVL(sRegion, 0), NVL(cSituacionEsp, ''), NVL(cCausa, ''), NVL(cTotal, 0 );					
	END IF
	--ORDENADO
	IF piTipoOrder = 2 THEN --POR SUCURSAL		
		
		IF LENGTH (pFechaInicio) = 7 AND LENGTH (pFechaFin) = 7 THEN
		LET cMesIni = SUBSTR(TRIM(pFechaInicio), 1, 2);
		LET cAnoIni = SUBSTR(TRIM(pFechaInicio), 4, 7);
		LET cMesFin = SUBSTR(TRIM(pFechaFin), 1, 2);
		LET cAnoFin = SUBSTR(TRIM(pFechaFin), 4, 7);
		execute  procedure bdinteg:sp_diaprimeroultimomesanio(cMesIni,cAnoIni) into cCod_ret2,dtfechainicial, dtfechainicial2 ;
		IF cCod_ret2 <> '000000' THEN 
			LET cCod_ret= '00005';
			RETURN cCod_ret, NVL(cSucursal, ''), NVL(sRegion, 0), NVL(cSituacionEsp, ''), NVL(cCausa, ''), NVL(cTotal, 0 );					
		END IF;	
		execute  procedure bdinteg:sp_diaprimeroultimomesanio(cMesFin,cAnoFin) into cCod_ret2,dtfechafinal, dtfechafinal2 ;
		IF cCod_ret2 <> '000000' THEN 
			 LET cCod_ret= '00006';
			 RETURN cCod_ret, NVL(cSucursal, ''), NVL(sRegion, 0), NVL(cSituacionEsp, ''), NVL(cCausa, ''), NVL(cTotal, 0 );					
		END IF;	
	
			FOREACH
	
				SELECT p.sucursal, p.situacion, p.causa, COUNT(p.numcte)
				INTO cSucursal, cSituacionEsp, cCausa, cTotal
				FROM bdisitesp:se_ctessitespcte p
				INNER JOIN bdinteg:si_sucursales s ON (p.sucursal= s.sucursal)
				INNER JOIN bdinteg: si_ciudades d ON (d.ciudad = s.ciudad) AND (s.estado= d.estado)
				INNER JOIN bdinteg:si_catciudades c ON (d.ciudad_coppel = c.numerociudad) 
				WHERE c.numero_region =c.numero_region
				AND p.numcte = CASE when pNumCte = '' THEN  p.numcte ELSE pNumCte END
				AND s.sucursal = CASE when pNumsucursal = '' THEN  s.sucursal   ELSE pNumsucursal END
				AND p.situacion = CASE when pSituacion = '' THEN  p.situacion   ELSE pSituacion END
				AND p.causa = CASE when pCausa = 0  THEN  p.causa ELSE pCausa END
				AND p.fchalta::DATE BETWEEN dtfechainicial AND dtfechafinal2
				Group by p.sucursal, p.situacion,p.causa
				ORDER BY p.sucursal,p.situacion,p.causa
				
				RETURN cCod_ret, NVL(cSucursal, ''), NVL(sRegion, 0), NVL(cSituacionEsp, ''), NVL(cCausa, ''), NVL(cTotal, 0 )	 WITH RESUME;				
				
			END FOREACH;					
		ELSE 
		
			FOREACH WITH HOLD
		
				SELECT p.sucursal, p.situacion, p.causa, COUNT(p.numcte)
				INTO cSucursal, cSituacionEsp, cCausa, cTotal
				FROM bdisitesp:se_ctessitespcte p
				INNER JOIN bdinteg:si_sucursales s ON (p.sucursal= s.sucursal)
				INNER JOIN bdinteg: si_ciudades d ON (d.ciudad = s.ciudad) AND (s.estado= d.estado)
				INNER JOIN bdinteg:si_catciudades c ON (d.ciudad_coppel = c.numerociudad) 
				WHERE c.numero_region =c.numero_region 
				AND p.numcte = CASE when pNumCte = '' THEN  p.numcte ELSE pNumCte END
				AND s.sucursal = CASE when pNumsucursal = '' THEN  s.sucursal   ELSE pNumsucursal END
				AND p.situacion = CASE when pSituacion = '' THEN  p.situacion   ELSE pSituacion END
				AND p.causa = CASE when pCausa = 0 THEN  p.causa ELSE pCausa END
				AND p.fchalta::DATE  BETWEEN pFechaInicio::DATE AND pFechaFin::DATE
				Group by p.sucursal, p.situacion,p.causa
				ORDER BY p.sucursal,p.situacion,p.causa			
							
				RETURN cCod_ret, NVL(cSucursal, ''), NVL(sRegion, 0), NVL(cSituacionEsp, ''), NVL(cCausa, ''), NVL(cTotal, 0 )  WITH RESUME;			
				
			END FOREACH;
		
		END IF;		
			
	ELIF  piTipoOrder= 3 THEN --TIPO  POR REGION	
	
		IF LENGTH (pFechaInicio) = 7 AND LENGTH (pFechaFin) = 7 THEN
		LET cMesIni = SUBSTR(TRIM(pFechaInicio), 1, 2);
		LET cAnoIni = SUBSTR(TRIM(pFechaInicio), 4, 7);
		LET cMesFin = SUBSTR(TRIM(pFechaFin), 1, 2);
		LET cAnoFin = SUBSTR(TRIM(pFechaFin), 4, 7);
		execute  procedure bdinteg:sp_diaprimeroultimomesanio(cMesIni,cAnoIni) into cCod_ret2,dtfechainicial, dtfechainicial2 ;
		IF cCod_ret2 <> '000000' THEN 
			LET cCod_ret= '00005';
			RETURN cCod_ret, NVL(cSucursal, ''), NVL(sRegion, 0), NVL(cSituacionEsp, ''), NVL(cCausa, ''), NVL(cTotal, 0 );					
		END IF;	
		execute  procedure bdinteg:sp_diaprimeroultimomesanio(cMesFin,cAnoFin) into cCod_ret2,dtfechafinal, dtfechafinal2 ;
		IF cCod_ret2 <> '000000' THEN 
			 LET cCod_ret= '00006';
			 RETURN cCod_ret, NVL(cSucursal, ''), NVL(sRegion, 0), NVL(cSituacionEsp, ''), NVL(cCausa, ''), NVL(cTotal, 0 );					
		END IF;	
			FOREACH WITH HOLD				

					SELECT c.numero_region, p.situacion, p.causa, COUNT(p.numcte)
					INTO sRegion, cSituacionEsp, cCausa, cTotal
					FROM bdisitesp:se_ctessitespcte p
					INNER JOIN bdinteg:si_sucursales s ON (p.sucursal= s.sucursal)
					INNER JOIN bdinteg: si_ciudades d ON (d.ciudad = s.ciudad) AND (s.estado= d.estado)
					INNER JOIN bdinteg:si_catciudades c ON (d.ciudad_coppel = c.numerociudad) 
					WHERE c.numero_region = CASE when pNumRegion = 0 THEN  c.numero_region   ELSE pNumRegion END
					AND p.numcte = CASE when pNumCte = '' THEN  p.numcte ELSE pNumCte END
					AND s.sucursal =  s.sucursal
					AND p.situacion = CASE when pSituacion = '' THEN  p.situacion   ELSE pSituacion END
					AND p.causa = CASE when pCausa = 0 THEN  p.causa ELSE pCausa END
					AND p.fchalta::DATE BETWEEN dtfechainicial AND dtfechafinal2
					Group by c.numero_region, p.situacion,p.causa
					ORDER BY c.numero_region,p.situacion,p.causa

				RETURN cCod_ret, NVL(cSucursal, ''), NVL(sRegion, 0), NVL(cSituacionEsp, ''), NVL(cCausa, ''), NVL(cTotal, 0 )  WITH RESUME;
				

			END FOREACH;		
				
		ELSE 
		
			FOREACH WITH HOLD
				
					SELECT c.numero_region, p.situacion, p.causa, COUNT(p.numcte)
					INTO sRegion, cSituacionEsp, cCausa, cTotal
					FROM bdisitesp:se_ctessitespcte p
					INNER JOIN bdinteg:si_sucursales s ON (p.sucursal= s.sucursal)
					INNER JOIN bdinteg: si_ciudades d ON (d.ciudad = s.ciudad) AND (s.estado= d.estado)
					INNER JOIN bdinteg:si_catciudades c ON (d.ciudad_coppel = c.numerociudad) 
					WHERE c.numero_region = CASE when pNumRegion = 0 THEN  c.numero_region   ELSE pNumRegion END
					AND p.numcte = CASE when pNumCte = '' THEN  p.numcte ELSE pNumCte END
					AND s.sucursal = s.sucursal 
					AND p.situacion = CASE when pSituacion = '' THEN  p.situacion   ELSE pSituacion END
					AND p.causa = CASE when pCausa = 0 THEN  p.causa ELSE pCausa END
					AND p.fchalta::DATE BETWEEN pFechaInicio::DATE AND pFechaFin::DATE
					Group by c.numero_region, p.situacion,p.causa
					ORDER BY c.numero_region,p.situacion,p.causa

				RETURN cCod_ret, NVL(cSucursal, ''), NVL(sRegion, 0), NVL(cSituacionEsp, ''), NVL(cCausa, ''), NVL(cTotal, 0 ) 	 WITH RESUME;
				
			END FOREACH;
		
		END IF;
	ELSE 
		LET cCod_ret= '00004';
		RETURN cCod_ret, NVL(cSucursal, ''), NVL(sRegion, 0), NVL(cSituacionEsp, ''), NVL(cCausa, ''), NVL(cTotal, 0 );	
	END IF;

END;
END PROCEDURE
DOCUMENT
'AUTOR: ABIGAIL VASAVILBAZO CAÑEDO',
'DESCRIPCION: GENERA INFORMACION PARA REPORTE DE SITUACION Y CAUSA (TOTALIZADO POR REGION O SUCURSAL)',
'BD: BDICOBRANZA',
'VERSION: 20100831.1122',
'BD: BDICOBRANZA';

CREATE PROCEDURE "informix".sp_cilocinsertamarcaautomatica()
RETURNING CHAR(5);

--Declaracion de variables
------------------------------------------------------------
DEFINE sql_err 			                INTEGER;
DEFINE isam_err 		                INTEGER;
DEFINE error_info		                CHAR(80);
DEFINE cCod_ret                         CHAR(6);
DEFINE dFechaHoy						DATE;
DEFINE iNumDias							INTEGER;
DEFINE dFechaLim						DATE;
DEFINE cNumcte							CHAR(20);
DEFINE cNombre							CHAR(40);
DEFINE cUsuario							CHAR(80);
DEFINE cCausa							CHAR(80);
DEFINE cSituacionEsp					CHAR(80);
-----------------------------------------------------
LET cCod_ret  		= '00000';
LET sql_err   		= 0;
LET dFechaHoy		= '';
LET iNumDias		= 0;
LET dFechaLim		= '';
LET cNumcte			= '';
LET cNombre			= '';
LET cUsuario		= '';
LET cCausa			= '';
LET cSituacionEsp 	= '';

  BEGIN

	ON EXCEPTION SET sql_err, isam_err, error_info
		LET cCod_ret = sql_err;
		RETURN cCod_ret;
	END EXCEPTION;
	
	--SET DEBUG FILE TO "/tmp/sp_CiLocInsertaMarcaAutomatica.out";
	--TRACE ON;
	
	SELECT fecha_hoy
	INTO dFechaHoy
	FROM bdinteg: si_fechas;
	
	SELECT NVL(valor,'')
	INTO cCausa					--Causa Necesaria para la ejecucion del sp_sustituirse, Causa por la cual será reemplazada la anterior.
	FROM bdicobranza:cb_param
	WHERE cod_param = '31';

	SELECT NVL(valor,'')
	INTO cSituacionEsp			--Situación Necesaria para la ejecucion del sp_sustituirse, Situacion por la cual será reemplazada la anterior.
	FROM bdicobranza:cb_param
	WHERE cod_param = '30';
	
	SELECT NVL(valor,'') 
	INTO cUsuario				--Usuario Necesario para la ejecución del sp:  sp_sustituirse.
	FROM bdicobranza:cb_param
	WHERE cod_param = '19';
	
	SELECT NVL(valor,'') 
	INTO iNumDias
	FROM bdicobranza:cb_param
	WHERE empresa = '001'
	AND cod_param = '15';
	
	LET iNumDias = iNumDias * 30;
	LET dFechaLim = dFechaHoy - iNumDias;
	
	FOREACH WITH HOLD
		
		SELECT numcte 
		INTO cNumcte
		FROM bdisitesp:se_ctessitespcTE 
		WHERE situacion = 'L' 
		AND fchalta::date <= dFechaLim

		EXECUTE PROCEDURE bdisitesp:sp_sustituirse( cNumcte,
							'001',
							'',
							TRIM(cSituacionEsp),
							TRIM(cCausa),
							TRIM(cUsuario),
							TRIM(cUsuario),
							'1'		--1= Cliente, 2.- Credito
							) INTO cCod_ret;
		
		IF cCod_ret <> 0 THEN
			CONTINUE FOREACH;
		END IF;
		
		IF EXISTS ( SELECT numcte FROM bdicobranza:cb_marcacliente WHERE numcte= cNumcte AND estatus = 'SA') THEN
			UPDATE bdicobranza:cb_marcacliente SET estatus = 'NA', usuario_desmarca = cUsuario, fecha_modificacion= dFechaHoy WHERE numcte= cNumcte AND estatus = 'SA' ;
		END IF;
		
		UPDATE bdicobranza:cb_alerta_succliente SET estatus= 'NA' WHERE numcte = cNumcte AND estatus = 'SA';
		
	END FOREACH;
RETURN cCod_ret;
END;
END PROCEDURE

DOCUMENT
'AUTOR: ABIGAIL VASAVILBAZO CAÑEDO',
'MODIFICO : HECTOR MANUEL BOJORQUEZ RUELAS',
'DESCRIPCION: CAMBIA DE MANERA AUTOMATICA DE SITUACION L A SITUACION M ',
'BD: BDICOBRANZA',
'VERSION: 20100914.1217';

CREATE PROCEDURE "informix".sp_cilocregistradesmarcaje( pOrigen CHAR(1),
											 pTpoDir 			CHAR(1),
											 pNumCte 			CHAR(20),
											 pEmpresa 			CHAR(3),
											 pFecha				DATE,
											 pUsuario			CHAR(8),
											 pSucursal			CHAR(4)
											)
RETURNING CHAR(5);

--Declaracion de variables
------------------------------------------------------------
DEFINE sql_err 			                INTEGER;
DEFINE isam_err 		                INTEGER;
DEFINE error_info		                CHAR(80);
DEFINE cCod_ret                         CHAR(6);
DEFINE dFechaHoy						DATE;
DEFINE iNumDias							INTEGER;
DEFINE dFechaLim						DATE;
DEFINE cNumcte							CHAR(20);
DEFINE cNombre							CHAR(40);
DEFINE cUsuario							CHAR(8);
DEFINE cSituacion						CHAR(1);
DEFINE cCausa							SMALLINT;
DEFINE iSecuencia						INTEGER;
DEFINE cSitEspecial						CHAR(1);		
DEFINE sCausaSE							SMALLINT;
DEFINE vTransaccion						INTEGER;
-----------------------------------------------------
LET cCod_ret  	= '00000';
LET sql_err   	= 0;
LET dFechaHoy	= '';				
LET iNumDias	=0;						
LET dFechaLim	='';	
LET cNumcte		= '';
LET cNombre		= '';	
LET cUsuario	= '';
LET cSituacion  = '';
LET cCausa		= 0;
LET iSecuencia = 0;
LET cSitEspecial = '';		
LET sCausaSE	= 0;
LET vTransaccion = 0;

 --SET DEBUG FILE TO "/tmp/sp_CiLocRegistraDesmarcaje.out";
 --TRACE ON;

  BEGIN
  
	ON EXCEPTION SET sql_err, isam_err, error_info
		IF sql_err = -535 THEN
			LET vTransaccion = 1;
			COMMIT WORK;
			BEGIN WORK;
		ELSE
			IF vTransaccion = 1 THEN
                ROLLBACK WORK;
                BEGIN WORK;
            ELSE
                ROLLBACK WORK;
            END IF
			LET cCod_ret = sql_err;
			RETURN cCod_ret;
		END IF
	END EXCEPTION WITH RESUME;

    IF vTransaccion = 0 THEN
         BEGIN WORK;
    END IF
	
	 IF EXISTS ( SELECT 1 FROM bdinteg:si_direcciones WHERE numcte= pNumCte AND tipo_dir = pTpoDir AND fecha_insert = pFecha) AND 
	 EXISTS (SELECT 1 FROM bdisitesp:se_ctessitespcte WHERE numcte =pNumCte AND situacion IN ('L','M') ) THEN		
	
		UPDATE bdisitesp:se_ctessitespcte SET motivo_desmarcaje= 'digitalizacion de campo de comprobante de domiclio' WHERE numcte= pNumCte AND situacion = 'L' ;
		
		SELECT situacion, causa
		INTO cSitEspecial, sCausaSE
		FROM bdisitesp:se_ctessitespcte
		WHERE numcte= pNumCte;
		
		EXECUTE PROCEDURE bdisitesp:sp_eliminarse(pNumCte,
										 pEmpresa,
										 '',
										 cSitEspecial,
										 sCausaSE	,
										 pUsuario,
										 pUsuario,
										 1 ,	--1.- Cliente, 2.- Credito
										 1		--1.- Individual, 2.- General
										) INTO cCod_ret;
		
		IF cCod_ret <> '000' THEN
			ROLLBACK WORK;
			LET cCod_ret= '00002';
			IF vTransaccion = 1 THEN         
				BEGIN WORK;
			END IF;
			RETURN cCod_ret;	
		END IF;		
			
		UPDATE bdicobranza:cb_alerta_succliente SET estatus= 'AT' WHERE numcte = pNumCte AND tipo_domicilio = pTpoDir AND estatus = 'SA';
		
		INSERT INTO bdicobranza:cb_alerta_succlientehis (numalerta, fecha, numcte, hora, tipo_alerta, estatus, sucursal, accion_origen, 
					situacion, causa, origen, tipo_domicilio)
		SELECT numalerta, fecha, numcte, hora, tipo_alerta, estatus, sucursal, accion_origen, situacion, causa, origen,
			   tipo_domicilio FROM bdicobranza:cb_alerta_succliente WHERE numcte = pNumCte AND tipo_domicilio = pTpoDir;
			   
		DELETE FROM bdicobranza:cb_alerta_succliente WHERE numcte = pNumCte AND tipo_domicilio = pTpoDir;
		
		IF EXISTS ( SELECT * FROM bdicobranza:cb_marcacliente WHERE numcte= pNumCte AND estatus = 'SA' AND tipo_domicilio = pTpoDir) THEN
			UPDATE cb_marcacliente SET estatus = 'AT', fecha_modificacion= pFecha WHERE numcte= pNumCte AND estatus = 'SA' AND tipo_domicilio = pTpoDir;
			INSERT INTO cb_marcacliente ( numcte, tipo_domicilio, tipo_marca, fecha_insert, estatus, fecha_modificacion, usuario_marca, 
										  usuario_desmarca, origen, sucursal)
			VALUES( pNumCte, pTpoDir, 'BL', pFecha, 'AT', pFecha, pUsuario, pUsuario, pOrigen ,pSucursal);		--Origen: 1 SUC/PLATAFORMA, 2 CENTRAL, 3 BPI	
			
			SELECT MAX(secuencia) 
			INTO iSecuencia
			FROM bdinteg:si_direcciones_loc 
			WHERE numcte= pNumCte 
			AND tipo_dir = pTpoDir;
			
			UPDATE bdinteg:si_direcciones_loc SET dom_verificado = 'S' WHERE numcte = pNumCte AND tipo_dir = pTpoDir AND secuencia = iSecuencia;
			
		END IF;		
	ELSE
		ROLLBACK WORK;
		LET cCod_ret= '00001';
		IF vTransaccion = 1 THEN         
			BEGIN WORK;
		END IF;
		RETURN cCod_ret;			
	END IF;	
	
	
	COMMIT WORK;
	
	IF vTransaccion = 1 THEN         
         BEGIN WORK;
    END IF;
	
	RETURN cCod_ret;	
END;
END PROCEDURE

DOCUMENT
'AUTOR: ABIGAIL VASAVILBAZO CAÑEDO',
'DESCRIPCION: ACTUALIZA A ATENDIDAS LAS MARCAS, ALERTAS Y ELIMINA LA SITUACION ESPECIAL ',
'BD: BDICOBRANZA',
'VERSION: 20100910.1551';

CREATE PROCEDURE "informix".sp_cargatelefonosburo()
       RETURNING CHAR(5), CHAR(80);
       
DEFINE vCodRet                  CHAR(5);
DEFINE vMensaje                 CHAR(80);
DEFINE SQL_ERR, ISAM_ERR        INTEGER;
DEFINE ERROR_INFO               VARCHAR(80);
DEFINE v_fecha                  DATE;
DEFINE v_dia, v_mes             CHAR(2);
DEFINE v_anio                   CHAR(4);
DEFINE cRuta                    CHAR(100);
DEFINE cRuta2                   CHAR(100);  
DEFINE cNombre                  CHAR(100);
DEFINE cNombre2                 CHAR(100);      
DEFINE iParamRuta               INTEGER;
DEFINE iParamNombre             INTEGER;  
DEFINE iRegistros               INTEGER;
DEFINE v_count                  INTEGER;
DEFINE cCadena                  CHAR(2000);
DEFINE cEmpresa                 CHAR(3);
DEFINE v_numcte                 CHAR(20); 
DEFINE v_cuenta                 CHAR(20);
DEFINE v_telefono1              CHAR(13);
DEFINE v_telefono2              CHAR(13); 
DEFINE v_telefono3              CHAR(13); 
DEFINE v_telefono4              CHAR(13);
DEFINE v_telefono5              CHAR(13);
DEFINE v_longitud               SMALLINT; 
DEFINE vCodRet_2                CHAR(6);
DEFINE vCodRet_tel              CHAR(5);
DEFINE cProceso                 CHAR(4);
DEFINE vvcCod_ret               CHAR(6);

LET SQL_ERR  = 0; 
LET ISAM_ERR = 0; 
LET ERROR_INFO = '';
LET vCodRet  = '00000'; LET vCodRet_2   = ''; LET vCodRet_tel = '';  
LET vvcCod_ret  = '';
LET vMensaje = '';
LET v_fecha  = DATE(1);
LET v_dia    = '';  LET v_mes    = '';  LET v_anio   = '';
LET cRuta    = '';  LET cNombre  = '';
LET cRuta2   = '';  LET cNombre2 = '';
LET iParamRuta  = 20;
LET iParamNombre = 40;
LET iRegistros  = 0;
LET cCadena     = '';
LET cEmpresa    = '001';
LET v_count     = 0;
LET v_numcte = ''; 
LET v_cuenta = '';
LET v_telefono1 = '';  LET v_telefono2 = '';  LET v_telefono3 = '';  
LET v_telefono4 = '';  LET v_telefono5 = '';
LET v_longitud  = 0;
LET cProceso    = '0020';   


 --SET DEBUG FILE TO "/informix/macf/sp_cargatelefonosburo.out";
 --TRACE ON; 

BEGIN

    ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
        LET vCodRet  = SQL_ERR;
        LET vMensaje  = ERROR_INFO;
         
        IF vCodRet = '-668' THEN
            LET vMensaje  = ISAM_ERR || ' El archivo a procesar no se encuentra en la carpeta';
            CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, vCodRet, trim(vMensaje), '02')
            RETURNING vvcCod_ret;
            LET vCodRet  = '00000';
            LET vMensaje  = '';
            RETURN vCodRet, vMensaje;
        ELSE 
            CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, vCodRet, vMensaje, '02')
            RETURNING vvcCod_ret;
        END IF;
          
        RETURN vCodRet, vMensaje;
        
    END EXCEPTION;

    SET LOCK MODE TO WAIT 3;
    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, vCodRet, vMensaje, '01') RETURNING vvcCod_ret;
    SET ISOLATION TO dirty READ;

    SELECT fecha_hoy 
    into v_fecha
    from bdinteg:si_fechas
    WHERE empresa = cEmpresa;
    
    IF EXISTS(SELECT tabname FROM sysmaster:systabnames WHERE tabname = 'tmp_telefonos_buro_2'  AND dbsname = 'bdicobranza') THEN
            DROP TABLE tmp_telefonos_buro_2;
    END IF;

    CREATE TABLE "informix".tmp_telefonos_buro_2
    (
    	cuenta           CHAR(20),
    	empleo           CHAR(60),
    	calleynum        CHAR(60),
    	colonia          CHAR(60),    	
    	delegacion       CHAR(60),
    	ciudad           CHAR(60),
    	estado           CHAR(10),
    	cp               CHAR(10),
    	telefono1        CHAR(13),
    	telefono2        CHAR(13),
    	telefono3        CHAR(13),
    	telefono4        CHAR(13),
    	telefono5        CHAR(13),
    	fecha_reg        CHAR(10) 
    );

    --CUENTA|EMPLEO|CALLE Y NUMERO|COLONIA|DELEGACION|CIUDAD|ESTADO|CP|TELEFONOS|FECHA
    CREATE INDEX "informix".idx_tmp_telefonos_buro_2 ON tmp_telefonos_buro_2 (cuenta) USING btree ;

    IF day(v_fecha) < 10 then
    	LET v_dia = '0' || day(v_fecha);
    ELSE
    	LET v_dia = day(v_fecha);
    END IF;
    
    IF month(v_fecha) < 10 then
    	LET v_mes = '0' || month(v_fecha);
    ELSE
    	LET v_mes = month(v_fecha);
    END IF;
    
    LET v_anio = year(v_fecha);

    SELECT valor  INTO cRuta
      FROM bdicobranza:cb_param
     WHERE empresa = cEmpresa
       AND cod_param = iParamRuta;

    SELECT valor  INTO cNombre2
      FROM bdicobranza:cb_param
     WHERE empresa = cEmpresa
       AND cod_param = iParamNombre;
   
    --LET vMensaje = 'Obtuvo parametros..' || iParamRuta || '-' || iParamNombre || '  ' || v_dia || v_mes || v_anio || ' -- ' || cRuta || '  ' || cNombre2;
    
  IF NVL(cRuta,'') <> '' and NVL(cNombre2, '') <> '' THEN

    LET cNombre = trim(SUBSTR(cNombre2,1,LENGTH(cNombre2)) || v_dia || v_mes || v_anio || '.txt');
    
    LET cCadena = 'echo "load from ''' || SUBSTR(cRuta,1,LENGTH(cRuta)) || SUBSTR(cNombre,1,LENGTH(cNombre)) || '''' ||
                  ' insert into bdicobranza:tmp_telefonos_buro_2 " > ' || SUBSTR(cRuta,1,LENGTH(cRuta)) || 'importa_telefonosburo.sql;';
      
    system SUBSTR(cCadena,1,LENGTH(cCadena));              
    --INSERT INTO bdicobranza:cb_mensajes_trace(nom_variable, descripcion) VALUES('cCadena', trim(cCadena));

    LET cCadena = 'dbaccess bdicobranza ' || SUBSTR(cRuta,1,LENGTH(cRuta)) || 'importa_telefonosburo.sql';
    
    system SUBSTR(cCadena,1,LENGTH(cCadena));
    --DESPUES QUE LOS IMPORTE SE DEBERAN PROCESAR para insertarlos a CB_TELEFONOS  con el SP "sp_cat_graba_telefono_adicional" usado por Cajera Capturista

    SELECT count(*) into v_count 
      FROM tmp_telefonos_buro_2;
      
     IF v_count <= 0 THEN
         LET vCodRet = '00001';
         LET vMensaje = 'NO SE CARGARON REGISTROS A LA TABLA TEMPORAL';
         RETURN vCodRet, vMensaje;  
     END IF;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    --SET pdqpriority 20;
   
     FOREACH 
           SELECT cuenta, telefono1, telefono2, telefono3, telefono4, telefono5               --LENGTH(telefono1)  
             INTO v_cuenta, v_telefono1, v_telefono2, v_telefono3, v_telefono4, v_telefono5   --v_longitud
             FROM bdicobranza:tmp_telefonos_buro_2

           SELECT FIRST 1 numcte INTO v_numcte
             FROM bdicred:sd_maecred
            WHERE num_credito = v_cuenta;

           
           IF LENGTH(v_telefono1)>= 10 THEN  --MÍNIMO QUE SEA DE 10 POSICIONES.
              -- VALIDAR QUE NO TRAIGA CARACTERES RAROS (bdinteg:sp_tipored solo recibe tels de 10 caracteres)
              EXECUTE procedure bdinteg:"informix".sp_validar_telefono(v_telefono1) into vCodRet_tel;

              IF vCodRet_tel = '00000' THEN
                  EXECUTE PROCEDURE "informix".sp_cat_graba_telefono_adicional(cEmpresa, 5, v_numcte, 1, v_telefono1, '', '', 0, user) INTO vCodRet_2;
              END IF;
           END IF;
           LET vCodRet_tel = '';
           
           IF LENGTH(v_telefono2)>= 10 THEN  
              EXECUTE procedure bdinteg:"informix".sp_validar_telefono(v_telefono2) into vCodRet_tel;

              IF vCodRet_tel = '00000' THEN
                  EXECUTE PROCEDURE "informix".sp_cat_graba_telefono_adicional(cEmpresa, 5, v_numcte, 2, v_telefono2, '', '', 0, user) INTO vCodRet_2;
              END IF;
           END IF;
           LET vCodRet_tel = '';
            
           IF LENGTH(v_telefono3)>= 10 THEN  
              EXECUTE procedure bdinteg:"informix".sp_validar_telefono(v_telefono3) into vCodRet_tel;

              IF vCodRet_tel = '00000' THEN
                  EXECUTE PROCEDURE "informix".sp_cat_graba_telefono_adicional(cEmpresa, 5, v_numcte, 3, v_telefono3, '', '', 0, user) INTO vCodRet_2;
              END IF;
           END IF;
           LET vCodRet_tel = '';
            
           IF LENGTH(v_telefono4)>= 10 THEN  
              EXECUTE procedure bdinteg:"informix".sp_validar_telefono(v_telefono4) into vCodRet_tel;

              IF vCodRet_tel = '00000' THEN
                  EXECUTE PROCEDURE "informix".sp_cat_graba_telefono_adicional(cEmpresa, 5, v_numcte, 4, v_telefono4, '', '', 0, user) INTO vCodRet_2;
              END IF;
           END IF;
           LET vCodRet_tel = '';

           IF LENGTH(v_telefono5)>= 10 THEN  
              EXECUTE procedure bdinteg:"informix".sp_validar_telefono(v_telefono5) into vCodRet_tel;

              IF vCodRet_tel = '00000' THEN
                  EXECUTE PROCEDURE "informix".sp_cat_graba_telefono_adicional(cEmpresa, 5, v_numcte, 5, v_telefono5, '', '', 0, user) INTO vCodRet_2;
              END IF;
           END IF;
                           
           LET iRegistros = iRegistros + 1;
      END FOREACH 

      DROP INDEX "informix".idx_tmp_telefonos_buro_2;
      --DROP TABLE "informix".tmp_telefonos_buro_2;
      
      LET cCadena = '';
      LET cCadena = 'bzip2 ' || SUBSTR(cRuta,1,LENGTH(cRuta)) || SUBSTR(cNombre,1,LENGTH(cNombre)); 
      system SUBSTR(cCadena,1,LENGTH(cCadena));
      
      CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, vCodRet, vMensaje, '03')
      RETURNING vvcCod_ret;
      
  END IF;
	  
   	
RETURN vCodRet, vMensaje;
END 
END PROCEDURE;
CREATE PROCEDURE "informix".sp_catinfogrid_sol_superv (pEmpresa CHAR(3), pNumSolicitud VARCHAR(20,1))
RETURNING
  CHAR(6) 	     AS codret,
  VARCHAR(20,1)  AS folio_os,
  DATE           AS fecha_generacion_os,
  VARCHAR(20,1)  AS num_solicitud,
  VARCHAR(20,1)  AS numcte,
  VARCHAR(110,1) AS nombre_cte,
  CHAR(2)        AS status,
  INTEGER        AS num_ciudad,
  INTEGER        AS num_zona,
  VARCHAR(32,1)  AS nom_zona,
  VARCHAR(60,1)  AS nom_ciudad,
  VARCHAR(27,1)  AS municipio,
  VARCHAR(6,1)   AS codigo_postal,
  VARCHAR(30,1)  AS estado,
  VARCHAR(20,1)  AS folio_os_coppel,
  DATE           AS fecha_generacion_os_coppel,
  VARCHAR(20,1)  AS num_solicitud_coppel,
  VARCHAR(20,1)  AS numcte_coppel,
  INTEGER        AS num_ciudad_coppel,
  INTEGER        AS num_zona_coppel, 
  VARCHAR(32,1)  AS nom_zona_coppel,
  VARCHAR(60,1)  AS nom_ciudad_coppel,
  VARCHAR(27,1)  AS municipio_coppel,
  VARCHAR(6)     AS codigo_postal_coppel,
  VARCHAR(30,1)  AS estado_coppel,
  VARCHAR(11,1)  AS tienda_matriz_coppel,
  INTEGER        AS num_cobranza_coppel;
  

---DECLARACIONES
DEFINE cCodRet        CHAR(6); 
DEFINE iSqlErr        INTEGER;
DEFINE iIsamErr       INTEGER;
DEFINE iNumReg        INTEGER;

DEFINE cEmpresa           CHAR(3);
DEFINE cNumSolicitud      VARCHAR(20,1);
DEFINE cNumCte            VARCHAR(20,1);
DEFINE cNombreCte         VARCHAR(110,1);
DEFINE cEstatusSol        CHAR(2);
DEFINE iNumCiudad         INTEGER;
DEFINE iNumZona           INTEGER;
DEFINE cNombreZona        VARCHAR(32,1);
DEFINE cNombreCiudad      VARCHAR(60,1);
DEFINE cMunicipio         VARCHAR(27,1);
DEFINE cCP                VARCHAR(6,1);
DEFINE cEstado            VARCHAR(30,1);
DEFINE cFolio             VARCHAR(20,1);
DEFINE iNumCiudadC        INTEGER;
DEFINE iNumZonaC          INTEGER;
DEFINE cNombreZonaC       VARCHAR(32,1);
DEFINE cNombreCiudadC     VARCHAR(60,1);
DEFINE cMunicipioC        VARCHAR(27,1);
DEFINE cCPC               INTEGER;
DEFINE cEstadoC           VARCHAR(30,1);
DEFINE cTdaMatriz         VARCHAR(11,1);
DEFINE iCobranzas         INTEGER;  
DEFINE cEdo               VARCHAR(2,1);
DEFINE dFechaOS           DATE;
DEFINE iSecuencia         INTEGER;
DEFINE iNumCiudad2        INTEGER;
DEFINE cNombreCiudad2     VARCHAR(60,1);
DEFINE iNumZona2          INTEGER;
DEFINE cNombreZona2       VARCHAR(32,1);
DEFINE cMunicipio2        VARCHAR(27,1);
DEFINE iNumCiudadC2       INTEGER;
DEFINE iNumZonaC2         INTEGER;
DEFINE cNombreZonaC2      VARCHAR(32,1);
DEFINE cMunicipioC2       VARCHAR(27,1);
DEFINE cCPC2              INTEGER;
DEFINE cEstadoC2          VARCHAR(30,1);
DEFINE cNombreCiudadC2    VARCHAR(60,1);
DEFINE iCobranzas2        INTEGER;
DEFINE iCont              INTEGER;

---INICIALIZACIONES
LET iSqlErr             = 0;
LET iIsamErr            = 0;
LET cCodRet             = "000000";
LET iNumReg             = 0;

LET cEmpresa            = '';
LET cNumSolicitud       = '';
LET cNumCte             = '';
LET cNombreCte          = '';
LET cEstatusSol         = '';
LET iNumCiudad          = 0;
LET iNumZona            = 0;
LET cNombreZona         = '';
LET cNombreCiudad       = '';
LET cMunicipio          = '';
LET cCP                 = '';
LET cEstado             = '';
LET cFolio              = '';
LET iNumCiudadC         = 0;
LET iNumZonaC           = 0;
LET cNombreZonaC        = '';
LET cNombreCiudadC      = '';
LET cMunicipioC         = '';
LET cCPC                = 0;
LET cEstadoC            = '';
LET cTdaMatriz          = '';
LET iCobranzas          = 0;
LET cEdo                = '';
LET dFechaOS            = DATE(1);
LET iSecuencia          = 0;
LET iNumCiudad2         = 0;
LET cNombreCiudad2      = '';
LET iNumZona2           = 0;
LET cNombreZona2        = '';
LET cMunicipio2         = '';
LET cCP                 = '';
LET iNumCiudadC2        = 0;
LET iNumZonaC2          = 0;
LET cNombreZonaC2       = '';
LET cMunicipioC2        = '';
LET cCPC2               = 0;
LET cEstadoC2           = '';
LET cNombreCiudadC2     = '';
LET iCobranzas2         = 0;
LET iCont               = 0;


BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr
   IF iSqlErr != 0 THEN
     LET cCodRet= iSqlErr;
	 RETURN	NVL(cCodRet,''), NVL(cFolio,''),  NVL(dFechaOS,DATE(1)), NVL(cNumSolicitud,''), NVL(cNumCte,''),
			NVL(cNombreCte,''), NVL(cEstatusSol,''), NVL(iNumCiudad,0), NVL(iNumZona,0), NVL(cNombreZona,''),
			NVL(cNombreCiudad,''), NVL(cMunicipio,''), NVL(cCP,''), NVL(cEstado,''), NVL(cFolio,''), NVL(dFechaOS,DATE(1)),
			NVL(cNumSolicitud,''), NVL(cNumCte,''), NVL(iNumCiudadC2,0), NVL(iNumZonaC2,0),NVL(cNombreZonaC2,''),
			NVL(cNombreCiudadC2,''), NVL(cMunicipioC2,''), NVL(cCPC2,''), NVL(cEstadoC2,''), NVL(cTdaMatriz,''),
			NVL(iCobranzas2,0);
   END IF;
END EXCEPTION;

--SET DEBUG FILE TO 'sp_catinfogrid_sol_superv.out';
--TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

SELECT empresa
  INTO cEmpresa     
  FROM bdinteg:si_empresas 
 WHERE empresa= pEmpresa;
  
IF cEmpresa IS NULL THEN
  LET cCodRet = '000001';
  	 RETURN	NVL(cCodRet,''), NVL(cFolio,''),  NVL(dFechaOS,DATE(1)), NVL(cNumSolicitud,''), NVL(cNumCte,''),
			NVL(cNombreCte,''), NVL(cEstatusSol,''), NVL(iNumCiudad,0), NVL(iNumZona,0), NVL(cNombreZona,''),
			NVL(cNombreCiudad,''), NVL(cMunicipio,''), NVL(cCP,''), NVL(cEstado,''), NVL(cFolio,''), NVL(dFechaOS,DATE(1)),
			NVL(cNumSolicitud,''), NVL(cNumCte,''), NVL(iNumCiudadC2,0), NVL(iNumZonaC2,0),NVL(cNombreZonaC2,''),
			NVL(cNombreCiudadC2,''), NVL(cMunicipioC2,''), NVL(cCPC2,''), NVL(cEstadoC2,''), NVL(cTdaMatriz,''),
			NVL(iCobranzas2,0);
END IF;

IF NVL(pNumSolicitud,'') = '' THEN
  LET cCodRet = '000002';
  	 RETURN	NVL(cCodRet,''), NVL(cFolio,''),  NVL(dFechaOS,DATE(1)), NVL(cNumSolicitud,''), NVL(cNumCte,''),
			NVL(cNombreCte,''), NVL(cEstatusSol,''), NVL(iNumCiudad,0), NVL(iNumZona,0), NVL(cNombreZona,''),
			NVL(cNombreCiudad,''), NVL(cMunicipio,''), NVL(cCP,''), NVL(cEstado,''), NVL(cFolio,''), NVL(dFechaOS,DATE(1)),
			NVL(cNumSolicitud,''), NVL(cNumCte,''), NVL(iNumCiudadC2,0), NVL(iNumZonaC2,0),NVL(cNombreZonaC2,''),
			NVL(cNombreCiudadC2,''), NVL(cMunicipioC2,''), NVL(cCPC2,''), NVL(cEstadoC2,''), NVL(cTdaMatriz,''),
			NVL(iCobranzas2,0);
END IF;   

FOREACH 
	SELECT TRIM(sol.num_solicitud) NUMSOL, 
		   TRIM(dir.numcte), TRIM(cli.nombre1)||'  '||TRIM(cli.nombre2)||' '||TRIM(cli.apell_paterno)||' '||TRIM(cli.apell_materno),
	       TRIM(sol.status_solicitud), 
	       dir.numerociudad, 
	       dir.numerocolonia,
	       TRIM(cat.nombrezona),
	       TRIM(ciu.nombre),
	       TRIM(cat.municipiozona), 
	       TRIM(dir.cod_postal),
	       TRIM(est.nombre),
	       DECODE(NVL(sup.folio,''),'','','0','',LPAD(TRIM(sol.sucursal),4,'0')||sup.folio), 
	       cat.numerociudadcoppel, 
	       cat.numerocoloniacoppel, 
	       TRIM(cat.nombrezonacoppel), 
	       TRIM(ciu2.nombre), 
	       CASE WHEN cat2.numerociudad::CHAR(11) = '0' THEN  '' ELSE cat2.municipiozona END  ,
	       CASE WHEN cat2.numerocolonia = 0 THEN 0 ELSE cat2.codigopostalzona END ,	
	       TRIM(est2.nombre), 
	       TRIM(sup.estatusos::CHAR(11)), 
	       cat.numerocobranzas,est.estado,sup.fechasolicitud,NVL(sup.secuencia,0)
      INTO cNumSolicitud, cNumCte, cNombreCte, cEstatusSol, iNumCiudad, iNumZona, cNombreZona, cNombreCiudad, cMunicipio,
		   cCP, cEstado,cFolio, iNumCiudadC, iNumZonaC, cNombreZonaC, cNombreCiudadC, cMunicipioC, cCPC, cEstadoC, cTdaMatriz, iCobranzas,cEdo,dFechaOS,iSecuencia
      FROM bdinteg:"informix".si_cliente cli,
		   bdisolic:"informix".ss_solicitudes sol
LEFT OUTER JOIN bdisolic:"informix".ss_solicitud_os os ON (sol.empresa = os.empresa  AND sol.num_solicitud = os.num_solicitud 
													  AND ( os.fecha_solicitud = (SELECT MAX(o.fechasolicitud) 
															     					    FROM bdisolic:"informix".ss_osclientesupervisar o 
																						WHERE o.empresa= sol.empresa 
																						AND os.secuenciaos = o.secuencia ))) 
														    LEFT OUTER JOIN bdisolic:"informix".ss_osclientesupervisar sup
															ON (os.empresa = sup.empresa AND os.secuenciaos = sup.secuencia
															AND  os.fecha_solicitud = sup.fechasolicitud),
					bdinteg:"informix".si_ciudades ciu,
					bdinteg:"informix".si_estados est,
					bdinteg:"informix".si_direcciones_actual dir 
					LEFT OUTER JOIN bdinteg:"informix".si_catzonas cat
					ON (dir.numerociudad= cat.numerociudad AND dir.numerocolonia = cat.numerocolonia) 
					LEFT OUTER JOIN  bdinteg:"informix".si_catzonas cat2
					ON (cat.numerociudadcoppel = cat2.numerociudad  AND cat.numerocoloniacoppel = cat2.numerocolonia)
					LEFT OUTER JOIN BDINTEG:"informix".si_ciudades ciu2 ON (cat2.numerociudad = ciu2.ciudad_coppel 
					AND ciu2.estado = dir.estado AND ciu2.ciudad = dir.ciudad)
					LEFT OUTER JOIN BDINTEG:"informix".si_estados est2 ON (ciu2.estado = est2.estado)																		
				WHERE sol.empresa = cli.empresa AND sol.numcte = cli.numcte
				AND sol.numcte = dir.numcte
				AND sol.empresa= pEmpresa			
				AND sol.num_solicitud =  pNumSolicitud
				AND dir.tipo_dir = '1'
				AND dir.numcte= cli.numcte	
				AND est.estado= dir.estado						
				AND dir.numerociudad= ciu.ciudad_coppel							
				AND dir.estado = ciu.estado  
				AND dir.secuencia IN (SELECT MAX(dir2.secuencia) FROM bdinteg:"informix".si_direcciones_actual dir2 WHERE dir2.numcte= dir.numcte AND dir2.tipo_dir = '1')  
					
					
				IF iSecuencia > 0 THEN
					
					SELECT b.ciudad,ciu2.nombre,b.colonia,TRIM(cat.nombrezona),TRIM(cat.municipiozona),cat.codigopostalzona,cat.numerociudadcoppel, 
					       cat.numerocoloniacoppel,TRIM(cat.nombrezonacoppel),
					       CASE WHEN cat2.numerociudad::CHAR(11) = '0' THEN  '' ELSE cat2.municipiozona END  ,
					       CASE WHEN cat2.numerocoloniacoppel = 0 THEN 0 ELSE cat2.codigopostalzona END ,
					       TRIM(ciu2.nombre),TRIM(ciu2.nombre),cat.numerocobranzas
					  INTO iNumCiudad2,cNombreCiudad2,iNumZona2,cNombreZona2,cMunicipio2,cCP,iNumCiudadC2,iNumZonaC2, cNombreZonaC2,cMunicipioC2, cCPC2,cEstadoC2,cNombreCiudadC2,iCobranzas2
					  FROM bdisolic:"informix".ss_osclientesupervisar b
           LEFT OUTER JOIN bdinteg:"informix".si_catzonas cat
			  			 ON (b.ciudad= cat.numerociudad AND b.colonia = cat.numerocolonia)
						 LEFT OUTER JOIN  bdinteg:"informix".si_catzonas cat2
						 ON (cat.numerociudadcoppel = cat2.numerociudad  AND
							cat.numerocoloniacoppel = cat2.numerocolonia)
						 LEFT OUTER JOIN BDINTEG:"informix".si_ciudades ciu2 ON
							(cat2.numerociudad = ciu2.ciudad_coppel
						 AND ciu2.estado = cEdo AND ciu2.ciudad = b.ciudad)
						 LEFT OUTER JOIN BDINTEG:"informix".si_estados est2 ON
							(ciu2.estado = est2.estado)
					WHERE b.secuencia = iSecuencia
					  AND b.clave = b.clave 
					  AND b.num_solicitud =cNumSolicitud;
				
					LET iCont= iCont +1;

						IF iCont <= 300 THEN
						 RETURN	NVL(cCodRet,''), NVL(cFolio,''),  NVL(dFechaOS,DATE(1)), NVL(cNumSolicitud,''), NVL(cNumCte,''),
								NVL(cNombreCte,''), NVL(cEstatusSol,''), NVL(iNumCiudad,0), NVL(iNumZona,0), NVL(cNombreZona,''),
								NVL(cNombreCiudad,''), NVL(cMunicipio,''), NVL(cCP,''), NVL(cEstado,''), NVL(cFolio,''), NVL(dFechaOS,DATE(1)),
								NVL(cNumSolicitud,''), NVL(cNumCte,''), NVL(iNumCiudadC2,0), NVL(iNumZonaC2,0),NVL(cNombreZonaC2,''),
								NVL(cNombreCiudadC2,''), NVL(cMunicipioC2,''), NVL(cCPC2,''), NVL(cEstadoC2,''), NVL(cTdaMatriz,''),
								NVL(iCobranzas2,0) WITH RESUME;			
						END IF;
					
			END IF;
			
END FOREACH;

LET iNumReg = dbinfo("sqlca.sqlerrd2");
IF iNumReg = 0 or iCont = 0 THEN
	LET cCodRet = "000003";
	RETURN NVL(cCodRet,''), NVL(cFolio,''),  NVL(dFechaOS,DATE(1)), NVL(cNumSolicitud,''), NVL(cNumCte,''),
		   NVL(cNombreCte,''), NVL(cEstatusSol,''), NVL(iNumCiudad,0), NVL(iNumZona,0), NVL(cNombreZona,''),
		   NVL(cNombreCiudad,''), NVL(cMunicipio,''), NVL(cCP,''), NVL(cEstado,''), NVL(cFolio,''), NVL(dFechaOS,DATE(1)),
		   NVL(cNumSolicitud,''), NVL(cNumCte,''), NVL(iNumCiudadC2,0), NVL(iNumZonaC2,0),NVL(cNombreZonaC2,''),
		   NVL(cNombreCiudadC2,''), NVL(cMunicipioC2,''), NVL(cCPC2,''), NVL(cEstadoC2,''), NVL(cTdaMatriz,''),
		   NVL(iCobranzas2,0);
END IF;

END
END PROCEDURE

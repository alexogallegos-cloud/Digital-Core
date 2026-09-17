CREATE PROCEDURE "informix".sp_consulta_cat_bancoppel_pba(pSolicitud CHAR(20), pCliente CHAR(20), 	
									pFechaIni DATE, pFechaFin DATE, pEstatus CHAR(2), pEstado CHAR(2), 
									pCiudad CHAR(3), pZona INTEGER, pConsulta INTEGER,pApCe INTEGER)
	RETURNING 	CHAR(6)   AS CodRetorno,
				CHAR(20)  AS NumSol,
				CHAR(20)  AS Cliente,
				CHAR(110) AS NombreCte,
				CHAR(2)	  AS Estatus,
				INTEGER	  AS Ciudad,
				INTEGER	  AS NumZona,
				CHAR(32)  AS NomZona,
				CHAR(60)  AS CiudadPob,
				CHAR(27)  AS Municipio,
				CHAR(6)	  AS CP,
				CHAR(30)  AS Estado,
				CHAR(20)  AS Folio,
				INTEGER	  AS CiudadC,
				INTEGER	  AS NumZonaC,
				CHAR(32)  AS NomZonaC,
				CHAR(60)  AS CiudadPobC,
				CHAR(27)  AS MunicipioC,
				CHAR(11)  AS CPC,
				CHAR(30)  AS EstadoC,
				CHAR(11)  AS TdaMatriz,
				INTEGER	  AS Cobranzas,
				DATE      AS Fecha_OS;

	--Declaración de variables			
	DEFINE isqlerr      	INTEGER;
	DEFINE cCodRet     		CHAR(6); 
	DEFINE cNumSolicitud	CHAR(20);
	DEFINE cNumCte		    CHAR(20);
	DEFINE cNombreCte		CHAR(110);
	DEFINE cEstatusSol		CHAR(2);
	DEFINE iNumCiudad	    INTEGER;
	DEFINE iNumZona			INTEGER;
	DEFINE cNombreZona		CHAR(32);
	DEFINE cNombreCiudad	CHAR(60);
	DEFINE cMunicipio		CHAR(27);
	DEFINE cCP				CHAR(6);
	DEFINE cEstado			CHAR(30);  
	DEFINE cFolio			CHAR(20);
	DEFINE iNumCiudadC		INTEGER;
	DEFINE iNumZonaC		INTEGER;
	DEFINE cNombreZonaC		CHAR(32);
	DEFINE cNombreCiudadC   CHAR(60);
	DEFINE cMunicipioC		CHAR(27);
	DEFINE cCPC 			INTEGER;
	DEFINE cEstadoC			CHAR(30);
	DEFINE cTdaMatriz		CHAR(11);
	DEFINE iCobranzas		INTEGER;  
	DEFINE iCont			INTEGER;
	DEFINE iMaxnumcd        INTEGER;
	DEFINE dFechaOS         DATE;
	DEFINE sEstado          SMALLINT;
	DEFINE sCiudad			SMALLINT;
	DEFINE sZona 			SMALLINT;
	DEFINE iTipo			INTEGER;
	---
	DEFINE cNombreCiudadC2  CHAR(60);
	DEFINE iNumCiudad2	    INTEGER;
	DEFINE iNumZona2		INTEGER;
	DEFINE cNombreZona2		CHAR(32);
	DEFINE cNombreCiudad2	CHAR(60);
	DEFINE cMunicipio2		CHAR(27);
	DEFINE iNumCiudadC2		INTEGER;
	DEFINE iNumZonaC2		INTEGER;
	DEFINE cNombreZonaC2	CHAR(32);
	DEFINE cMunicipioC2		CHAR(27);
	DEFINE cCPC2			INTEGER;
	DEFINE cEstadoC2		CHAR(30);
	DEFINE cTdaMatriz2		CHAR(11);
	DEFINE iCobranzas2		INTEGER;
	DEFINE cEdo             CHAR(2);
	DEFINE iSecuencia     	INTEGER;
	
	--Asinación de valores   
	LET isqlerr     		= 0;
	LET cCodRet     		= '000000';
	LET cNumSolicitud		= '';
	LET cNumCte				= '';
	LET cNombreCte			= '';
	LET cEstatusSol			= '';
	LET iNumCiudad			= 0;
	LET iNumZona			= 0;
	LET cNombreZona			= '';
	LET cNombreCiudad		= '';
	LET cMunicipio			= '';
	LET cCP					= '';
	LET cEstado				= ''; 
	LET cFolio				= '';
	LET iNumCiudadC			= 0;
	LET iNumZonaC			= 0;
	LET cNombreZonaC		= '';
	LET cNombreCiudadC	    = '';
	LET cMunicipioC			= '';
	LET cCPC				= '';
	LET cEstadoC			= ''; 
	LET cTdaMatriz			= ''; 
	LET iCobranzas			= 0;
	LET iCont				= 0;
	LET iMaxnumcd           = 0;
	LET dFechaOS			= DATE(1);
	LET sEstado             = 0;
	LET sCiudad				= 0;
	LET sZona				= 0;
	LET iTipo 				= 0;
	--
	LET cNombreCiudadC2     = '';
	LET iNumCiudad2	    	= 0; 
	LET iNumZona2			= 0; 
	LET cNombreZona2		= ''; 
	LET cNombreCiudad2		= ''; 
	LET cMunicipio2			= ''; 
	LET iNumCiudadC2		= 0; 
	LET iNumZonaC2			= 0; 
	LET cNombreZonaC2		= ''; 
	LET cMunicipioC2		= ''; 
	LET cCPC2				= 0; 
	LET cEstadoC2			= ''; 
	LET cTdaMatriz2			= ''; 
	LET iCobranzas2			= 0; 
	LET cEdo                = '';
	LET iSecuencia          = 0;
	
	--SET DEBUG FILE TO '/respaldosbd/martin/sp_consulta_cat_bancoppel.out';
	--TRACE ON;

	
	BEGIN
		
	--Control de errores
		ON EXCEPTION SET iSqlErr
			  LET cCodRet= iSqlErr;
			  RETURN cCodRet, NVL(cNumSolicitud,""), NVL(cNumCte,""), NVL(cNombreCte,""), NVL(cEstatusSol,""), NVL(iNumCiudad,0), NVL(iNumZona,0),
					NVL(cNombreZona, ""), NVL(cNombreCiudad,""), NVL(cMunicipio, ""), NVL(cCP,""), NVL(cEstado,"") , NVL(cFolio,'0'), NVL(iNumCiudadC,0), NVL(iNumZonaC,0), NVL(cNombreZonaC,''),
					NVL(cNombreCiudadC,''), NVL(cMunicipioC,''), NVL(cCPC,''), NVL(cEstadoC,''), NVL(cTdaMatriz,''), NVL(iCobranzas,0),dFechaOS;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;	
		
		IF NVL(pFechaIni,"") = "" THEN
			LET pFechaIni= DATE(1);
		END IF
		
		IF NVL(pFechaFin,"") = "" THEN
			LET pFechaFin = DATE(1);
		END IF	
		
		IF pSolicitud IS NULL THEN
			LET pSolicitud = '';
		END IF 
		
		IF pEstatus IS NULL THEN
			LET pEstatus = '';
		END IF 
		
		IF pEstado IS NULL THEN
			LET pEstado = '';
		END IF 
		
		IF pCiudad IS NULL THEN
			LET pCiudad = '';
		END IF 
		
		IF pZona IS NULL THEN
			LET pZona = 0;
		END IF 
		
		LET sEstado = pEstado;
		LET sCiudad = pCiudad;
		LET sZona   = pZona;
		
		--Validación de parámetros
		IF pSolicitud= ''  AND pCliente= ''  AND pFechaIni= DATE(1)  AND pFechaFin =DATE(1) AND 
		pEstatus= '' AND  pEstado= '' THEN
			LET cCodRet = '000001'; --Faltan parámetros
			RETURN cCodRet, NVL(cNumSolicitud,""), NVL(cNumCte,""), NVL(cNombreCte,""), NVL(cEstatusSol,""), NVL(iNumCiudad,0), NVL(iNumZona,0),
					NVL(cNombreZona, ""), NVL(cNombreCiudad,""), NVL(cMunicipio, ""), NVL(cCP,""), NVL(cEstado,"") , NVL(cFolio,""), NVL(iNumCiudadC,0), NVL(iNumZonaC,0), NVL(cNombreZonaC,''),
					NVL(cNombreCiudadC,''), NVL(cMunicipioC,''), NVL(cCPC,''), NVL(cEstadoC,''), NVL(cTdaMatriz,''), NVL(iCobranzas,0),NVL(dFechaOS,"");
		END IF;
		
		IF (pFechaIni <> '' AND pFechaFin= '' ) OR  ( pFechaFin <> '' AND pFechaIni = '') THEN
			LET cCodRet = '000002'; --Rango de fechas incompleto
			RETURN cCodRet, NVL(cNumSolicitud,""), NVL(cNumCte,""), NVL(cNombreCte,""), NVL(cEstatusSol,""), NVL(iNumCiudad,0), NVL(iNumZona,0),
					NVL(cNombreZona, ""), NVL(cNombreCiudad,""), NVL(cMunicipio, ""), NVL(cCP,""), NVL(cEstado,"") , NVL(cFolio,""), NVL(iNumCiudadC,0), NVL(iNumZonaC,0), NVL(cNombreZonaC,''),
					NVL(cNombreCiudadC,''), NVL(cMunicipioC,''), NVL(cCPC,''), NVL(cEstadoC,''), NVL(cTdaMatriz,''), NVL(iCobranzas,0),NVL(dFechaOS,"");
		END IF	
			
		IF pSolicitud <> ""  THEN		
			--Consulta por NÚMERO SOLICITUD	
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
					 bdisolic:"informix".ss_solicitudes sol LEFT OUTER JOIN bdisolic:"informix".ss_solicitud_os os
														    ON (sol.empresa = os.empresa  AND sol.num_solicitud = os.num_solicitud 
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
				AND  sol.numcte = dir.numcte
				AND sol.empresa= '001'			
				AND sol.num_solicitud =  pSolicitud
                and sol.sucursal IN ( select sucursal from bdinteg:si_sucursales )
				AND sol.status_solicitud=  CASE WHEN pEstatus = "" THEN sol.status_solicitud  ELSE pEstatus END 
				AND dir.tipo_dir = '1'
				AND dir.numcte= cli.numcte	
				AND est.estado= dir.estado						
				AND dir.estado=  CASE WHEN pEstado = "" THEN dir.estado  ELSE pEstado END 
				AND dir.ciudad=  CASE WHEN pCiudad = "" THEN dir.ciudad  ELSE pCiudad END
				AND dir.numerocolonia= CASE WHEN pZona = 0 THEN dir.numerocolonia  ELSE pZona END							
				AND sol.fecha_insert BETWEEN CASE WHEN pFechaIni = DATE(1) THEN sol.fecha_insert  ELSE pFechaIni END 
									 AND CASE WHEN pFechaFin = DATE(1) THEN sol.fecha_insert  ELSE pFechaFin END 
				AND dir.numerociudad= ciu.ciudad_coppel							
				AND dir.estado = ciu.estado  
				--AND dir.ciudad = ciu.ciudad  
				AND dir.secuencia IN (SELECT MAX(dir2.secuencia) FROM bdinteg:"informix".si_direcciones_actual dir2 WHERE dir2.numcte= dir.numcte AND dir2.tipo_dir = '1')  
					
				IF iSecuencia > 0 THEN
					
					SELECT  b.ciudad,ciu2.nombre,b.colonia,TRIM(cat.nombrezona),TRIM(cat.municipiozona),cat.codigopostalzona,cat.numerociudadcoppel, 
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
					AND b.clave = b.clave;
				
					LET iCont= iCont +1;

					IF pConsulta = 1 THEN
						
						IF iCont <= 300 THEN
								RETURN cCodRet, NVL(cNumSolicitud,""), NVL(cNumCte,""), NVL(cNombreCte,""), NVL(cEstatusSol,""), NVL(iNumCiudad2,0), NVL(iNumZona2,0),
								NVL(cNombreZona2, ""), NVL(cNombreCiudad2,""), NVL(cMunicipio2, ""), NVL(cCP,""), NVL(cEstado,"") , NVL(cFolio,""), NVL(iNumCiudadC2,0), NVL(iNumZonaC2,0), NVL(cNombreZonaC2,''),
								NVL(cNombreCiudadC2,''), NVL(cMunicipioC2,''), NVL(cCPC2,''), NVL(cEstadoC,''), NVL(cTdaMatriz,''), NVL(iCobranzas2,0),NVL(dFechaOS,DATE(1)) WITH RESUME;			
						END IF;
					ELSE 
						RETURN cCodRet, NVL(cNumSolicitud,""), NVL(cNumCte,""), NVL(cNombreCte,""), NVL(cEstatusSol,""), NVL(iNumCiudad2,0), NVL(iNumZona2,0),
						NVL(cNombreZona2, ""), NVL(cNombreCiudad2,""), NVL(cMunicipio2, ""), NVL(cCP,""), NVL(cEstado,"") , NVL(cFolio,""), NVL(iNumCiudadC2,0), NVL(iNumZonaC2,0), NVL(cNombreZonaC2,''),
						NVL(cNombreCiudadC2,''), NVL(cMunicipioC2,''), NVL(cCPC2,''), NVL(cEstadoC,''), NVL(cTdaMatriz,''), NVL(iCobranzas2,0),NVL(dFechaOS,DATE(1)) WITH RESUME;			
					END IF;
					
				ELSE
					
					LET iCont= iCont +1;

					IF pConsulta = 1 THEN
						
						IF iCont <= 300 THEN
								RETURN cCodRet, NVL(cNumSolicitud,""), NVL(cNumCte,""), NVL(cNombreCte,""), NVL(cEstatusSol,""), NVL(iNumCiudad,0), NVL(iNumZona,0),
									NVL(cNombreZona, ""), NVL(cNombreCiudad,""), NVL(cMunicipio, ""), NVL(cCP,""), NVL(cEstado,"") , NVL(cFolio,""), NVL(iNumCiudadC,0), NVL(iNumZonaC,0), NVL(cNombreZonaC,''),
									NVL(cNombreCiudadC,''), NVL(cMunicipioC,''), NVL(cCPC,''), NVL(cEstadoC,''), NVL(cTdaMatriz,''), NVL(iCobranzas,0),NVL(dFechaOS,DATE(1)) WITH RESUME;			
						END IF;
					ELSE 
						RETURN cCodRet, NVL(cNumSolicitud,""), NVL(cNumCte,""), NVL(cNombreCte,""), NVL(cEstatusSol,""), NVL(iNumCiudad,0), NVL(iNumZona,0),
							NVL(cNombreZona, ""), NVL(cNombreCiudad,""), NVL(cMunicipio, ""), NVL(cCP,""), NVL(cEstado,"") , NVL(cFolio,""), NVL(iNumCiudadC,0), NVL(iNumZonaC,0), NVL(cNombreZonaC,''),
							NVL(cNombreCiudadC,''), NVL(cMunicipioC,''), NVL(cCPC,''), NVL(cEstadoC,''), NVL(cTdaMatriz,''), NVL(iCobranzas,0),NVL(dFechaOS,DATE(1)) WITH RESUME;
					END IF;
				END IF;
			END FOREACH;
		ELIF pCliente <> ""  THEN	
		
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
					 bdisolic:"informix".ss_solicitudes sol LEFT OUTER JOIN bdisolic:"informix".ss_solicitud_os os
														    ON (sol.empresa = os.empresa  AND sol.num_solicitud = os.num_solicitud 
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
				AND  sol.numcte = dir.numcte
				AND sol.empresa= '001'			
				AND dir.numcte= pCliente
				AND sol.status_solicitud=  CASE WHEN pEstatus = "" THEN sol.status_solicitud  ELSE pEstatus END 
				AND dir.tipo_dir = '1'
				AND dir.numcte= cli.numcte	
				AND est.estado= dir.estado						
				AND dir.estado=  CASE WHEN pEstado = "" THEN dir.estado  ELSE pEstado END 
				AND dir.ciudad=  CASE WHEN pCiudad = "" THEN dir.ciudad  ELSE pCiudad END
				AND dir.numerocolonia= CASE WHEN pZona = 0 THEN dir.numerocolonia  ELSE pZona END							
				AND sol.fecha_insert BETWEEN CASE WHEN pFechaIni = DATE(1) THEN sol.fecha_insert  ELSE pFechaIni END 
									 AND CASE WHEN pFechaFin = DATE(1) THEN sol.fecha_insert  ELSE pFechaFin END 
				AND dir.numerociudad= ciu.ciudad_coppel							
				AND dir.estado = ciu.estado  
				AND dir.ciudad = ciu.ciudad  
				AND dir.secuencia IN (SELECT MAX(dir2.secuencia) FROM bdinteg:"informix".si_direcciones_actual dir2 WHERE dir2.numcte= dir.numcte AND dir2.tipo_dir = '1')  

				IF iSecuencia > 0 THEN
					
					SELECT  b.ciudad,ciu2.nombre,b.colonia,TRIM(cat.nombrezona),TRIM(cat.municipiozona),cat.codigopostalzona,cat.numerociudadcoppel, 
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
					AND b.clave = b.clave;
					
					LET iCont= iCont +1;

					IF pConsulta = 1 THEN
						
						IF iCont <= 300 THEN
								RETURN cCodRet, NVL(cNumSolicitud,""), NVL(cNumCte,""), NVL(cNombreCte,""), NVL(cEstatusSol,""), NVL(iNumCiudad2,0), NVL(iNumZona2,0),
								NVL(cNombreZona2, ""), NVL(cNombreCiudad2,""), NVL(cMunicipio2, ""), NVL(cCP,""), NVL(cEstado,"") , NVL(cFolio,""), NVL(iNumCiudadC2,0), NVL(iNumZonaC2,0), NVL(cNombreZonaC2,''),
								NVL(cNombreCiudadC2,''), NVL(cMunicipioC2,''), NVL(cCPC2,''), NVL(cEstadoC,''), NVL(cTdaMatriz,''), NVL(iCobranzas2,0),NVL(dFechaOS,DATE(1)) WITH RESUME;			
						END IF;
					ELSE 
						RETURN cCodRet, NVL(cNumSolicitud,""), NVL(cNumCte,""), NVL(cNombreCte,""), NVL(cEstatusSol,""), NVL(iNumCiudad2,0), NVL(iNumZona2,0),
						NVL(cNombreZona2, ""), NVL(cNombreCiudad2,""), NVL(cMunicipio2, ""), NVL(cCP,""), NVL(cEstado,"") , NVL(cFolio,""), NVL(iNumCiudadC2,0), NVL(iNumZonaC2,0), NVL(cNombreZonaC2,''),
						NVL(cNombreCiudadC2,''), NVL(cMunicipioC2,''), NVL(cCPC2,''), NVL(cEstadoC,''), NVL(cTdaMatriz,''), NVL(iCobranzas2,0),NVL(dFechaOS,DATE(1)) WITH RESUME;			
					END IF;
					
				ELSE
					
					LET iCont= iCont +1;

					IF pConsulta = 1 THEN
						
						IF iCont <= 300 THEN
								RETURN cCodRet, NVL(cNumSolicitud,""), NVL(cNumCte,""), NVL(cNombreCte,""), NVL(cEstatusSol,""), NVL(iNumCiudad,0), NVL(iNumZona,0),
									NVL(cNombreZona, ""), NVL(cNombreCiudad,""), NVL(cMunicipio, ""), NVL(cCP,""), NVL(cEstado,"") , NVL(cFolio,""), NVL(iNumCiudadC,0), NVL(iNumZonaC,0), NVL(cNombreZonaC,''),
									NVL(cNombreCiudadC,''), NVL(cMunicipioC,''), NVL(cCPC,''), NVL(cEstadoC,''), NVL(cTdaMatriz,''), NVL(iCobranzas,0),NVL(dFechaOS,DATE(1)) WITH RESUME;			
						END IF;
					ELSE 
						RETURN cCodRet, NVL(cNumSolicitud,""), NVL(cNumCte,""), NVL(cNombreCte,""), NVL(cEstatusSol,""), NVL(iNumCiudad,0), NVL(iNumZona,0),
							NVL(cNombreZona, ""), NVL(cNombreCiudad,""), NVL(cMunicipio, ""), NVL(cCP,""), NVL(cEstado,"") , NVL(cFolio,""), NVL(iNumCiudadC,0), NVL(iNumZonaC,0), NVL(cNombreZonaC,''),
							NVL(cNombreCiudadC,''), NVL(cMunicipioC,''), NVL(cCPC,''), NVL(cEstadoC,''), NVL(cTdaMatriz,''), NVL(iCobranzas,0),NVL(dFechaOS,DATE(1)) WITH RESUME;
					END IF;
				END IF;
			END FOREACH;	
		ELIF pApCe = 1 THEN
			
			FOREACH 

				SELECT num_solicitud 
				INTO cNumSolicitud
				FROM bdisolic:"informix".ss_os_solautdirecta
				WHERE empresa = '001'
				AND flagce =1
				AND status_sol = 'CE'
					LET pEstatus ='';
				IF DBINFO("sqlca.sqlerrd2") = 1 THEN
				
					FOREACH 
					
						SELECT {+INDEX(bdisolic:ss_solicitudes idx_ss_solicitudes3)} TRIM(sol.num_solicitud) NUMSOL, 
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
							 bdisolic:"informix".ss_solicitudes sol LEFT OUTER JOIN bdisolic:"informix".ss_solicitud_os os
																	ON (sol.empresa = os.empresa  AND sol.num_solicitud = os.num_solicitud 
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
						AND  sol.numcte = dir.numcte
						AND sol.empresa= '001'			
						AND sol.num_solicitud =  cNumSolicitud
                        and sol.sucursal IN ( select sucursal from bdinteg:si_sucursales )
						AND sol.status_solicitud=  CASE WHEN pEstatus = "" THEN sol.status_solicitud  ELSE pEstatus END 
						AND dir.tipo_dir = '1'
						AND dir.numcte= cli.numcte	
						AND est.estado= dir.estado						
						AND dir.estado=  CASE WHEN pEstado = "" THEN dir.estado  ELSE pEstado END 
						AND dir.ciudad=  CASE WHEN pCiudad = "" THEN dir.ciudad  ELSE pCiudad END
						AND dir.numerocolonia= CASE WHEN pZona = 0 THEN dir.numerocolonia  ELSE pZona END							
						AND sol.fecha_insert BETWEEN CASE WHEN pFechaIni = DATE(1) THEN sol.fecha_insert  ELSE pFechaIni END 
											 AND CASE WHEN pFechaFin = DATE(1) THEN sol.fecha_insert  ELSE pFechaFin END 
						AND dir.numerociudad= ciu.ciudad_coppel							
						AND dir.estado = ciu.estado  
						--AND dir.ciudad = ciu.ciudad  
						AND dir.secuencia IN (SELECT MAX(dir2.secuencia) FROM bdinteg:"informix".si_direcciones_actual dir2 WHERE dir2.numcte= dir.numcte AND dir2.tipo_dir = '1')
				
						IF iSecuencia > 0 THEN
							
							SELECT  b.ciudad,ciu2.nombre,b.colonia,TRIM(cat.nombrezona),TRIM(cat.municipiozona),cat.codigopostalzona,cat.numerociudadcoppel, 
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
							AND b.clave = b.clave;
								
							LET iCont= iCont +1;

							IF pConsulta = 1 THEN
							
								IF iCont <= 300 THEN
										RETURN cCodRet, NVL(cNumSolicitud,""), NVL(cNumCte,""), NVL(cNombreCte,""), NVL(cEstatusSol,""), NVL(iNumCiudad2,0), NVL(iNumZona2,0),
										NVL(cNombreZona2, ""), NVL(cNombreCiudad2,""), NVL(cMunicipio2, ""), NVL(cCP,""), NVL(cEstado,"") , NVL(cFolio,""), NVL(iNumCiudadC2,0), NVL(iNumZonaC2,0), NVL(cNombreZonaC2,''),
										NVL(cNombreCiudadC2,''), NVL(cMunicipioC2,''), NVL(cCPC2,''), NVL(cEstadoC,''), NVL(cTdaMatriz,''), NVL(iCobranzas2,0),NVL(dFechaOS,DATE(1)) WITH RESUME;			
								END IF;
							ELSE 
								RETURN cCodRet, NVL(cNumSolicitud,""), NVL(cNumCte,""), NVL(cNombreCte,""), NVL(cEstatusSol,""), NVL(iNumCiudad2,0), NVL(iNumZona2,0),
								NVL(cNombreZona2, ""), NVL(cNombreCiudad2,""), NVL(cMunicipio2, ""), NVL(cCP,""), NVL(cEstado,"") , NVL(cFolio,""), NVL(iNumCiudadC2,0), NVL(iNumZonaC2,0), NVL(cNombreZonaC2,''),
								NVL(cNombreCiudadC2,''), NVL(cMunicipioC2,''), NVL(cCPC2,''), NVL(cEstadoC,''), NVL(cTdaMatriz,''), NVL(iCobranzas2,0),NVL(dFechaOS,DATE(1)) WITH RESUME;			
							END IF;
							
						ELSE
							
							LET iCont= iCont +1;

							IF pConsulta = 1 THEN
								
								IF iCont <= 300 THEN
										RETURN cCodRet, NVL(cNumSolicitud,""), NVL(cNumCte,""), NVL(cNombreCte,""), NVL(cEstatusSol,""), NVL(iNumCiudad,0), NVL(iNumZona,0),
											NVL(cNombreZona, ""), NVL(cNombreCiudad,""), NVL(cMunicipio, ""), NVL(cCP,""), NVL(cEstado,"") , NVL(cFolio,""), NVL(iNumCiudadC,0), NVL(iNumZonaC,0), NVL(cNombreZonaC,''),
											NVL(cNombreCiudadC,''), NVL(cMunicipioC,''), NVL(cCPC,''), NVL(cEstadoC,''), NVL(cTdaMatriz,''), NVL(iCobranzas,0),NVL(dFechaOS,DATE(1)) WITH RESUME;			
								END IF;
							ELSE 
								RETURN cCodRet, NVL(cNumSolicitud,""), NVL(cNumCte,""), NVL(cNombreCte,""), NVL(cEstatusSol,""), NVL(iNumCiudad,0), NVL(iNumZona,0),
									NVL(cNombreZona, ""), NVL(cNombreCiudad,""), NVL(cMunicipio, ""), NVL(cCP,""), NVL(cEstado,"") , NVL(cFolio,""), NVL(iNumCiudadC,0), NVL(iNumZonaC,0), NVL(cNombreZonaC,''),
									NVL(cNombreCiudadC,''), NVL(cMunicipioC,''), NVL(cCPC,''), NVL(cEstadoC,''), NVL(cTdaMatriz,''), NVL(iCobranzas,0),NVL(dFechaOS,DATE(1)) WITH RESUME;
							END IF;
						END IF;
					END FOREACH;
				END IF;
			END FOREACH;
		ELSE 		
			FOREACH 
			
				SELECT {+index (ss_solicitudes idx_numctempresa) +INDEX(bdinteg:si_direcciones_actual idx_diract_asignar)} TRIM(sol.num_solicitud) NUMSOL, 
				TRIM(dir.numcte), 
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
				INTO cNumSolicitud, cNumCte, cEstatusSol, iNumCiudad, iNumZona, cNombreZona, cNombreCiudad, cMunicipio,
					 cCP, cEstado,cFolio, iNumCiudadC, iNumZonaC, cNombreZonaC, cNombreCiudadC, cMunicipioC, cCPC, cEstadoC, cTdaMatriz, iCobranzas,cEdo,dFechaOS,iSecuencia
				FROM bdisolic:"informix".ss_solicitudes sol LEFT OUTER JOIN bdisolic:"informix".ss_solicitud_os os
															ON (sol.empresa = os.empresa  AND os.num_solicitud  = sol.num_solicitud 
															AND (os.fecha_solicitud  = os.fecha_solicitud))
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
				LEFT OUTER JOIN bdinteg:"informix".si_ciudades ciu2 ON (cat2.numerociudad = ciu2.ciudad_coppel 
					AND ciu2.estado = dir.estado AND ciu2.ciudad = dir.ciudad)
				LEFT OUTER JOIN bdinteg:"informix".si_estados est2 ON (ciu2.estado = est2.estado)																		
				WHERE sol.empresa= '001'				
				AND sol.numcte = dir.numcte		
				AND sol.num_solicitud = sol.num_solicitud				
				AND  sol.fecha_insert BETWEEN CASE WHEN pFechaIni = DATE(1) THEN sol.fecha_insert  ELSE pFechaIni END 
									  AND CASE WHEN pFechaFin = DATE(1) THEN sol.fecha_insert  ELSE pFechaFin END 
				AND sol.status_solicitud =  CASE WHEN pEstatus = "" THEN sol.status_solicitud  ELSE pEstatus END 
				AND dir.tipo_dir = '1'
				AND dir.numcte= sol.numcte	
				AND est.estado= dir.estado						
				AND dir.estado=  CASE WHEN pEstado = "" THEN dir.estado  ELSE pEstado END 
				AND dir.ciudad=  CASE WHEN pCiudad = "" THEN dir.ciudad  ELSE pCiudad END
				AND dir.numerocolonia= CASE WHEN pZona = 0 THEN dir.numerocolonia  ELSE pZona END							
				AND dir.numerociudad= ciu.ciudad_coppel							
				AND dir.estado = ciu.estado  
				AND dir.ciudad = ciu.ciudad  
				AND dir.secuencia IN (SELECT MAX(dir2.secuencia) FROM bdinteg:"informix".si_direcciones_actual dir2 WHERE dir2.numcte= dir.numcte AND dir2.tipo_dir = '1')  

				
				SELECT TRIM(cli.nombre1)||'  '||TRIM(cli.nombre2)||' '||TRIM(cli.apell_paterno)||' '||TRIM(cli.apell_materno)
					INTO cNombreCte
				FROM  bdinteg:"informix".si_cliente cli
				WHERE cli.empresa ='001'
				AND cli.numcte = cNumCte;
				
				IF iSecuencia > 0 THEN
					
					SELECT  b.ciudad,ciu2.nombre,b.colonia,TRIM(cat.nombrezona),TRIM(cat.municipiozona),cat.codigopostalzona,cat.numerociudadcoppel, 
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
					AND b.clave = b.clave;
										
					LET iCont= iCont +1;

					IF pConsulta = 1 THEN
						
						IF iCont <= 300 THEN
								RETURN cCodRet, NVL(cNumSolicitud,""), NVL(cNumCte,""), NVL(cNombreCte,""), NVL(cEstatusSol,""), NVL(iNumCiudad2,0), NVL(iNumZona2,0),
								NVL(cNombreZona2, ""), NVL(cNombreCiudad2,""), NVL(cMunicipio2, ""), NVL(cCP,""), NVL(cEstado,"") , NVL(cFolio,""), NVL(iNumCiudadC2,0), NVL(iNumZonaC2,0), NVL(cNombreZonaC2,''),
								NVL(cNombreCiudadC2,''), NVL(cMunicipioC2,''), NVL(cCPC2,''), NVL(cEstadoC,''), NVL(cTdaMatriz,''), NVL(iCobranzas2,0),NVL(dFechaOS,DATE(1)) WITH RESUME;			
						END IF;
					ELSE 
						RETURN cCodRet, NVL(cNumSolicitud,""), NVL(cNumCte,""), NVL(cNombreCte,""), NVL(cEstatusSol,""), NVL(iNumCiudad2,0), NVL(iNumZona2,0),
						NVL(cNombreZona2, ""), NVL(cNombreCiudad2,""), NVL(cMunicipio2, ""), NVL(cCP,""), NVL(cEstado,"") , NVL(cFolio,""), NVL(iNumCiudadC2,0), NVL(iNumZonaC2,0), NVL(cNombreZonaC2,''),
						NVL(cNombreCiudadC2,''), NVL(cMunicipioC2,''), NVL(cCPC2,''), NVL(cEstadoC,''), NVL(cTdaMatriz,''), NVL(iCobranzas2,0),NVL(dFechaOS,DATE(1)) WITH RESUME;			
					END IF;
					
				ELSE
					
					LET iCont= iCont +1;

					IF pConsulta = 1 THEN
						
						IF iCont <= 300 THEN
								RETURN cCodRet, NVL(cNumSolicitud,""), NVL(cNumCte,""), NVL(cNombreCte,""), NVL(cEstatusSol,""), NVL(iNumCiudad,0), NVL(iNumZona,0),
									NVL(cNombreZona, ""), NVL(cNombreCiudad,""), NVL(cMunicipio, ""), NVL(cCP,""), NVL(cEstado,"") , NVL(cFolio,""), NVL(iNumCiudadC,0), NVL(iNumZonaC,0), NVL(cNombreZonaC,''),
									NVL(cNombreCiudadC,''), NVL(cMunicipioC,''), NVL(cCPC,''), NVL(cEstadoC,''), NVL(cTdaMatriz,''), NVL(iCobranzas,0),NVL(dFechaOS,DATE(1)) WITH RESUME;			
						END IF;
					ELSE 
						RETURN cCodRet, NVL(cNumSolicitud,""), NVL(cNumCte,""), NVL(cNombreCte,""), NVL(cEstatusSol,""), NVL(iNumCiudad,0), NVL(iNumZona,0),
							NVL(cNombreZona, ""), NVL(cNombreCiudad,""), NVL(cMunicipio, ""), NVL(cCP,""), NVL(cEstado,"") , NVL(cFolio,""), NVL(iNumCiudadC,0), NVL(iNumZonaC,0), NVL(cNombreZonaC,''),
							NVL(cNombreCiudadC,''), NVL(cMunicipioC,''), NVL(cCPC,''), NVL(cEstadoC,''), NVL(cTdaMatriz,''), NVL(iCobranzas,0),NVL(dFechaOS,DATE(1)) WITH RESUME;
					END IF;
				END IF;
			END FOREACH; 	

		END IF;
		
		--Valida si se encontro información
		IF iCont = 0 THEN
			LET cCodRet = '000003'; --No hay información 
			RETURN cCodRet, NVL(cNumSolicitud,""), NVL(cNumCte,""), NVL(cNombreCte,""), NVL(cEstatusSol,""), NVL(iNumCiudad,0), NVL(iNumZona,0),
					NVL(cNombreZona, ""), NVL(cNombreCiudad,""), NVL(cMunicipio, ""), NVL(cCP,""), NVL(cEstado,"") , NVL(cFolio,""), NVL(iNumCiudadC,0), NVL(iNumZonaC,0), NVL(cNombreZonaC,''),
					NVL(cNombreCiudadC,''), NVL(cMunicipioC,''), NVL(cCPC,''), NVL(cEstadoC,''), NVL(cTdaMatriz,''), NVL(iCobranzas,0),NVL(dFechaOS,"");
		ELSE
			LET cCodRet = '100000';
			LET cNumSolicitud = iCont;
			RETURN cCodRet, NVL(cNumSolicitud,""), NVL(cNumCte,""), NVL(cNombreCte,""), NVL(cEstatusSol,""), NVL(iNumCiudad,0), NVL(iNumZona,0),
							NVL(cNombreZona, ""), NVL(cNombreCiudad,""), NVL(cMunicipio, ""), NVL(cCP,""), NVL(cEstado,"") , NVL(cFolio,""), NVL(iNumCiudadC,0), NVL(iNumZonaC,0), NVL(cNombreZonaC,''),
							NVL(cNombreCiudadC,''), NVL(cMunicipioC,''), NVL(cCPC,''), NVL(cEstadoC,''), NVL(cTdaMatriz,''), NVL(iCobranzas,0),NVL(dFechaOS,"");
							
		END IF;	
		
	END;
	

END PROCEDURE

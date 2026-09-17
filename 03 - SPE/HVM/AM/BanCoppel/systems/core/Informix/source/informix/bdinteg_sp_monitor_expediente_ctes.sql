CREATE PROCEDURE "informix".sp_monitor_expediente_ctes(pEmpresa char(3),  pSucursal CHAR(4),pNumcte CHAR(20),pTipoConsulta SMALLINT,pFechaIni DATE,pFechaFin DATE,pTipoRevision INTEGER, pPaginacion SMALLINT )

RETURNING CHAR(5),    -- Codigo de Retorno
		  CHAR(4),   -- Producto
		  CHAR(20),   -- Numero de Cuenta
          CHAR(20),   -- Nro de Cliente
		  CHAR(107),  -- Nombre del Cliente
          CHAR(10),   -- Numero de empleado que apertura
		  CHAR(10),   -- Gerente Reviso
		  CHAR(30),   -- Estatus de la revision
		  DATE,       -- Fecha de alta
          CHAR(250);  -- Observaciones

---DECLARACIONES
DEFINE iSqlErr			INTEGER;
DEFINE iIsamErr			INTEGER;
DEFINE iSecuencia       INTEGER;
DEFINE cErrorInfo		CHAR(80);
DEFINE cCodRet			CHAR(5);
DEFINE cMensajeRet		CHAR(80);

DEFINE cProducto		CHAR(4);
DEFINE cNumCta			CHAR(20);
DEFINE cNumcte			CHAR(20);
DEFINE cNumcteAux		CHAR(20);
DEFINE cNombreCte 		CHAR(120);
DEFINE cEmpAlta 		CHAR(10);
DEFINE cReviso	 		CHAR(10);
DEFINE cStatusRevision 	CHAR(30);
DEFINE dtFechaAlta		DATE;
DEFINE dTFecha			DATE;
DEFINE cObservaciones 	CHAR(100);
DEFINE iBandera 		INTEGER;
DEFINE iDias 		INTEGER;
DEFINE dtFechaHoy 		DATE;
DEFINE dtFechaIni 		DATE;
DEFINE dtFechaFin 		DATE;
DEFINE iStatus 		INTEGER;


---INICIALIZACIONES
LET iSqlErr				= 0;
LET iIsamErr			= 0;
LET iSecuencia			= 0;
LET cErrorInfo			= '';
LET cCodRet				= '00000';
LET cMensajeRet			= 'Proceso Exitoso';

LET cProducto	= '';
LET cNumCta		= '';
LET cNumcte		= '';
LET cNumcteAux	= '';
LET cNombreCte  = '';
LET cEmpAlta    = '';
LET cReviso     = '';
LET cStatusRevision = '';
LET dtFechaAlta		= DATE(1);
LET dTFecha			= DATE(1);
LET cObservaciones  = '';
LET iBandera =  0;
LET iDias =  0;
LET dtFechaHoy =  DATE(1);
LET dtFechaIni =  DATE(1);
LET dtFechaFin =  DATE(1);
LET iStatus =  0;

BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr
       IF iSqlErr != 0 THEN
          LET cCodRet = iSqlErr;
          RETURN cCodRet, NVL(cProducto,""),NVL(cNumCta,""),NVL(cNumcte,""),NVL(cNombreCte,""),NVL(cEmpAlta,""),NVL(cReviso,"") , NVL(cStatusRevision,""),NVL(dtFechaAlta,DATE(1)),NVL(cObservaciones,"") ;
       END IF;
    END EXCEPTION;

	SET LOCK MODE TO WAIT 3;
    ---SET ISOLATION TO COMMITTED READ LAST COMMITTED;
    SET ISOLATION TO DIRTY READ;


--SET DEBUG FILE TO "/tmp/sp_monitor_expediente_ctes_modf.out";
--TRACE ON;

	IF NVL(pNumcte,"") <> "" THEN
		LET pSucursal = "";
	END IF


	SELECT fecha_hoy
	INTO dtFechaHoy
	FROM bdicred:"informix".sd_fechas
	WHERE empresa = pEmpresa;
	--consulta todos

	SELECT valor
	INTO iDias
	FROM bdicred:"informix".sd_param
	WHERE empresa = pEmpresa
	AND cod_param ='086';

	LET dtFechaHoy = dtFechaHoy - iDias;

	IF pFechaIni IS NULL THEN
		LET dtFechaIni = dtFechaHoy;
		LET dtFechaFin = TODAY;
	ELSE
		LET dtFechaIni = pFechaIni;
		LET dtFechaFin = pFechaFin;
	END IF;

	IF NVL(pSucursal,"") <> "" THEN--va consultar todos los estatus	o el estatus que se mande
		FOREACH 
		SELECT distinct (cte3.numcte),TRIM(cte3.nombre1)||" "||TRIM(cte3.nombre2)||" "||TRIM(cte3.apell_paterno)||" "||TRIM(cte3.apell_materno), cte3.fecha_insert,cte3.user_insert
			INTO cNumcte,cNombreCte,dtFechaAlta,cEmpAlta
			FROM bdinteg:"informix".si_cliente cte3
			WHERE cte3.fecha_insert = dtFechaIni -- BETWEEN  dtFechaIni and dtFechaFin
			AND cte3.sucursal  = pSucursal
			AND cte3.tipo_cliente = 1

			LET cReviso     = '';
			LET cStatusRevision = '';
			LET cObservaciones= '';
			LET iStatus= 0;


			FOREACH 
				SELECT LIMIT 1 gerente,status_revision, DECODE(status_revision,0,"Sin Revisar",1,"Status OK",2,"Pendiente de Corregir"),observaciones,fecha_insert
				INTO cReviso,iStatus,cStatusRevision,cObservaciones, dTFecha
				FROM bdinteg:"informix".si_reporte_expediente
				WHERE empresa = pEmpresa
				AND numcte = cNumcte
				ORDER BY fecha_insert DESC

				IF dTFecha < dtFechaHoy THEN
					LET cReviso     = '';
					LET cStatusRevision = '';
				END IF;
				EXIT FOREACH;
			END FOREACH;

			IF (iStatus <> pTipoRevision) AND pTipoRevision <> 3  THEN
				CONTINUE FOREACH;
			END IF

			IF pTipoConsulta = 1 THEN --CZB
			--Se buscaran las cuentas dadas de alta creditos,Prestamos,debito
				FOREACH 
					SELECT 	sol.num_producto, sol.num_solicitud
						INTO cProducto, cNumCta
					FROM bdisolic:"informix".ss_solicitudes   sol
					WHERE sol.empresa = pEmpresa
					AND sol.numcte = cNumcte
					AND sol.status_solicitud NOT IN ('PC','AN','AP')
					AND sol.fecha_insert = dtFechaIni --BETWEEN  dtFechaIni and dtFechaFin

					LET iBandera = iBandera+1;

					IF iBandera <= pPaginacion THEN
						CONTINUE FOREACH;
					ELSE
						RETURN cCodRet, NVL(cProducto,""),NVL(cNumCta,""),NVL(cNumcte,""),NVL(cNombreCte,""),NVL(cEmpAlta,""),NVL(cReviso,"") , NVL(cStatusRevision,""),NVL(dtFechaAlta,DATE(1)),NVL(cObservaciones,"") WITH RESUME;
					END IF;
				END FOREACH
				FOREACH --cuentas aperturadas
					SELECT 	sol2.num_producto, sol2.num_solicitud
						INTO cProducto, cNumCta
					FROM bdisolic:"informix".ss_solicitudes   sol2
--					inner join bdinteg:"informix".si_cliente cte4 ON (cte4.empresa = pEmpresa and cte4.numcte = sol2.numcte)
					WHERE sol2.empresa = pEmpresa
					AND sol2.numcte = cNumcte
					AND sol2.status_solicitud = 'AP'
					AND sol2.sucursal =pSucursal
					AND sol2.num_solicitud IN (SELECT num_solicitud
										FROM bdisolic:"informix".ss_autorizacion aut
										WHERE  aut.empresa = pEmpresa AND aut.num_solicitud = sol2.num_solicitud AND aut.status_solicitud ='AP' AND aut.fecha_insert = dtFechaIni) --BETWEEN  dtFechaIni and dtFechaFin)

                   


					LET iBandera = iBandera+1;

					IF iBandera <= pPaginacion THEN
						CONTINUE FOREACH;
					ELSE
						RETURN cCodRet, NVL(cProducto,""),NVL(cNumCta,""),NVL(cNumcte,""),NVL(cNombreCte,""),NVL(cEmpAlta,""),NVL(cReviso,"") , NVL(cStatusRevision,""),NVL(dtFechaAlta,DATE(1)),NVL(cObservaciones,"") WITH RESUME;
					END IF;

				END FOREACH
				FOREACH 	---cuentas de captacion

					SELECT mae.cuenta, Mae.producto
					INTO  cNumCta, cProducto
					FROM bdicheq:sc_maechq Mae
					INNER JOIN bdicheq:sc_maenoc noc on (noc.cuenta = mae.cuenta and noc.fecha_alta = dtFechaIni) --BETWEEN  dtFechaIni and dtFechaFin)
					WHERE   Mae.empresa = pEmpresa
					AND Mae.num_cte = cNumcte
					AND Mae.status_cta    = '1'
					AND Mae.producto IN ('1300','1400','1500','1700','1800','1900','2000','1100')

						LET iBandera = iBandera+1;

						IF iBandera <= pPaginacion THEN
							CONTINUE FOREACH;
						ELSE
							RETURN cCodRet, NVL(cProducto,""),NVL(cNumCta,""),NVL(cNumcte,""),NVL(cNombreCte,""),NVL(cEmpAlta,""),NVL(cReviso,"") , NVL(cStatusRevision,""),NVL(dtFechaAlta,DATE(1)),NVL(cObservaciones,"") WITH RESUME;
						END IF;


				END FOREACH;
				FOREACH 	---cuentas de inversion

					SELECT 	invers.cuenta, invers.cod_instrum
					INTO  cNumCta, cProducto
					FROM bdinvers:"informix".sv_maeinv   invers
					inner join bdinteg:"informix".si_cliente cte5 ON (cte5.empresa = pEmpresa and cte5.numcte = invers.num_cte)
					WHERE invers.empresa = pEmpresa
					AND invers.num_cte = cNumcte
					AND invers.fecha_alta = dtFechaIni --BETWEEN  dtFechaIni and dtFechaFin
					AND invers.sucursal =pSucursal
					AND invers.secuencia =1


						LET iBandera = iBandera+1;

						IF iBandera <= pPaginacion THEN
							CONTINUE FOREACH;
						ELSE
							RETURN cCodRet, NVL(cProducto,""),NVL(cNumCta,""),NVL(cNumcte,""),NVL(cNombreCte,""),NVL(cEmpAlta,""),NVL(cReviso,"") , NVL(cStatusRevision,""),NVL(dtFechaAlta,DATE(1)),NVL(cObservaciones,"") WITH RESUME;
						END IF;


				END FOREACH;

			ELSE
				LET iBandera = iBandera+1;

				IF iBandera <= pPaginacion THEN
					CONTINUE FOREACH;
				ELSE
					RETURN cCodRet, NVL(cProducto,""),NVL(cNumCta,""),NVL(cNumcte,""),NVL(cNombreCte,""),NVL(cEmpAlta,""),NVL(cReviso,"") , NVL(cStatusRevision,""),NVL(dtFechaAlta,DATE(1)),NVL(cObservaciones,"") WITH RESUME;
				END IF;

			END IF;
			LET cProducto	= '';
			LET cNumCta		= '';
			LET cNumcte		= '';
			LET cNombreCte  = '';
			LET cEmpAlta    = '';
			LET cReviso     = '';
			LET cStatusRevision = '';
			LET dtFechaAlta		= DATE(1);
			LET cObservaciones  = '';
		END FOREACH;

		FOREACH 
			SELECT UNIQUE num_cte
			INTO cNumcte
			FROM bdicheq:sc_maechq Mae
			INNER JOIN bdicheq:sc_maenoc noc on (noc.cuenta = mae.cuenta and noc.fecha_alta = dtFechaIni) -- BETWEEN  dtFechaIni and dtFechaFin)
--			INNER JOIN bdinteg:"informix".si_cliente cte ON (cte.empresa = pEmpresa and cte.numcte = mae.num_cte and cte.fecha_insert < dtFechaIni)
			WHERE  Mae.status_cta    = '1'
			AND Mae.empresa = pEmpresa
			AND mae.sucursal = pSucursal
			AND Mae.producto IN ('1300','1400','1500','1700','1800','1900','2000','1100')

            SELECT TRIM(nombre1)||" "||TRIM(nombre2)||" "||TRIM(apell_paterno)||" "||TRIM(apell_materno), fecha_insert, user_insert
            INTO cNombreCte,dtFechaAlta,cEmpAlta
            FROM bdinteg:"informix".si_cliente 
            WHERE numcte = cNumcte;

			LET cReviso     = '';
			LET cStatusRevision = '';
			LET cObservaciones= '';
			LET iStatus= 0;

			FOREACH 
				SELECT LIMIT 1 gerente,status_revision, DECODE(status_revision,0,"Sin Revisar",1,"Status OK",2,"Pendiente de Corregir"),observaciones,fecha_insert
				INTO cReviso,iStatus,cStatusRevision,cObservaciones, dTFecha
				FROM bdinteg:"informix".si_reporte_expediente
				WHERE empresa = pEmpresa
				AND numcte = cNumcte
				ORDER BY fecha_insert DESC

				IF dTFecha < dtFechaHoy THEN
					LET cReviso     = '';
					LET cStatusRevision = '';
				END IF;
				EXIT FOREACH;
			END FOREACH;

			IF (iStatus <> pTipoRevision) AND pTipoRevision <> 3  THEN
				CONTINUE FOREACH;
			END IF

			IF pTipoConsulta = 1 THEN --CZB
			--Se buscaran las cuentas dadas de alta creditos,Prestamos,debito
				FOREACH 
					SELECT 	sol.num_producto, sol.num_solicitud
						INTO cProducto, cNumCta
					FROM bdisolic:"informix".ss_solicitudes   sol
					WHERE sol.empresa = pEmpresa
					AND sol.numcte = cNumcte
					AND sol.status_solicitud NOT IN ('PC','AN','AP')
					AND sol.fecha_insert = dtFechaIni --BETWEEN  dtFechaIni and dtFechaFin

					LET iBandera = iBandera+1;

					IF iBandera <= pPaginacion THEN
						CONTINUE FOREACH;
					ELSE
						RETURN cCodRet, NVL(cProducto,""),NVL(cNumCta,""),NVL(cNumcte,""),NVL(cNombreCte,""),NVL(cEmpAlta,""),NVL(cReviso,"") , NVL(cStatusRevision,""),NVL(dtFechaAlta,DATE(1)),NVL(cObservaciones,"") WITH RESUME;
					END IF;
				END FOREACH
				FOREACH --cuentas aperturadas
					SELECT 	sol2.num_producto, sol2.num_solicitud
						INTO cProducto, cNumCta
					FROM bdisolic:"informix".ss_solicitudes   sol2
--					inner join bdinteg:"informix".si_cliente cte4 ON (cte4.empresa = pEmpresa and cte4.numcte = sol2.numcte)
					WHERE sol2.empresa = pEmpresa
					AND sol2.numcte = cNumcte
					AND sol2.status_solicitud = 'AP'
					AND sol2.sucursal =pSucursal
					AND sol2.num_solicitud IN (SELECT num_solicitud
										FROM bdisolic:"informix".ss_autorizacion aut
										WHERE  aut.empresa = pEmpresa AND aut.num_solicitud = sol2.num_solicitud AND aut.status_solicitud ='AP' AND aut.fecha_insert = dtFechaIni) -- BETWEEN  dtFechaIni and dtFechaFin)


					LET iBandera = iBandera+1;

					IF iBandera <= pPaginacion THEN
						CONTINUE FOREACH;
					ELSE
						RETURN cCodRet, NVL(cProducto,""),NVL(cNumCta,""),NVL(cNumcte,""),NVL(cNombreCte,""),NVL(cEmpAlta,""),NVL(cReviso,"") , NVL(cStatusRevision,""),NVL(dtFechaAlta,DATE(1)),NVL(cObservaciones,"") WITH RESUME;
					END IF;

				END FOREACH
				FOREACH 	---cuentas de captacion

					SELECT mae.cuenta, Mae.producto
					INTO  cNumCta, cProducto
					FROM bdicheq:sc_maechq Mae
					INNER JOIN bdicheq:sc_maenoc noc on (noc.cuenta = mae.cuenta and noc.fecha_alta = dtFechaIni) --BETWEEN  dtFechaIni and dtFechaFin)
					WHERE  Mae.status_cta    = '1'
					AND Mae.empresa = pEmpresa	--Revisar indice
					AND Mae.num_cte = cNumcte
					AND Mae.producto IN ('1300','1400','1500','1700','1800','1900','2000','1100')

						LET iBandera = iBandera+1;

						IF iBandera <= pPaginacion THEN
							CONTINUE FOREACH;
						ELSE
							RETURN cCodRet, NVL(cProducto,""),NVL(cNumCta,""),NVL(cNumcte,""),NVL(cNombreCte,""),NVL(cEmpAlta,""),NVL(cReviso,"") , NVL(cStatusRevision,""),NVL(dtFechaAlta,DATE(1)),NVL(cObservaciones,"") WITH RESUME;
						END IF;


				END FOREACH;
				FOREACH 	---cuentas de inversion

					SELECT 	invers.cuenta, invers.cod_instrum
					INTO  cNumCta, cProducto
					FROM bdinvers:"informix".sv_maeinv   invers
					inner join bdinteg:"informix".si_cliente cte5 ON (cte5.empresa = pEmpresa and cte5.numcte = invers.num_cte)
					WHERE invers.empresa = pEmpresa
					AND invers.num_cte = cNumcte
					AND invers.fecha_alta = dtFechaIni --BETWEEN  dtFechaIni and dtFechaFin
					AND invers.sucursal =pSucursal
					AND invers.secuencia =1


						LET iBandera = iBandera+1;

						IF iBandera <= pPaginacion THEN
							CONTINUE FOREACH;
						ELSE
							RETURN cCodRet, NVL(cProducto,""),NVL(cNumCta,""),NVL(cNumcte,""),NVL(cNombreCte,""),NVL(cEmpAlta,""),NVL(cReviso,"") , NVL(cStatusRevision,""),NVL(dtFechaAlta,DATE(1)),NVL(cObservaciones,"") WITH RESUME;
						END IF;


				END FOREACH;





			ELSE
				LET iBandera = iBandera+1;

				IF iBandera <= pPaginacion THEN
					CONTINUE FOREACH;
				ELSE
					RETURN cCodRet, NVL(cProducto,""),NVL(cNumCta,""),NVL(cNumcte,""),NVL(cNombreCte,""),NVL(cEmpAlta,""),NVL(cReviso,"") , NVL(cStatusRevision,""),NVL(dtFechaAlta,DATE(1)),NVL(cObservaciones,"") WITH RESUME;
				END IF;

			END IF;
			LET cProducto	= '';
			LET cNumCta		= '';
			LET cNumcte		= '';
			LET cNombreCte  = '';
			LET cEmpAlta    = '';
			LET cReviso     = '';
			LET cStatusRevision = '';
			LET dtFechaAlta		= DATE(1);
			LET cObservaciones  = '';
		END FOREACH;

		FOREACH 
			SELECT distinct (cte2.numcte),TRIM(cte2.nombre1)||" "||TRIM(cte2.nombre2)||" "||TRIM(cte2.apell_paterno)||" "||TRIM(cte2.apell_materno), cte2.fecha_insert,cte2.user_insert
			INTO cNumcte,cNombreCte,dtFechaAlta,cEmpAlta
			FROM bdisolic:"informix".ss_solicitudes   sol
			inner join bdinteg:"informix".si_cliente cte2 ON (cte2.empresa = pEmpresa and cte2.numcte = sol.numcte  and cte2.fecha_insert < dtFechaIni)
			WHERE sol.empresa = pEmpresa
			AND sol.numcte =  cte2.numcte
			AND sol.sucursal =pSucursal
			AND sol.fecha_insert = dtFechaIni --BETWEEN  dtFechaIni and dtFechaFin
			AND sol.status_solicitud NOT IN ('PC','AN')

			LET cReviso     = '';
			LET cStatusRevision = '';
			LET cObservaciones= '';
			LET iStatus= 0;

			IF EXISTS(SELECT Mae.num_cte
				FROM bdicheq:sc_maechq Mae
				INNER JOIN bdicheq:sc_maenoc noc on (noc.cuenta = mae.cuenta and noc.fecha_alta = dtFechaIni) --BETWEEN  dtFechaIni and dtFechaFin)
				WHERE  Mae.status_cta    = '1'
				AND Mae.empresa = pEmpresa
				AND Mae.num_cte = cNumcte
				AND mae.sucursal =pSucursal
				AND Mae.producto IN ('1300','1400','1500','1700','1800','1900','2000','1100')) THEN
				CONTINUE FOREACH;
			END IF;


			FOREACH 
				SELECT LIMIT 1 gerente,status_revision, DECODE(status_revision,0,"Sin Revisar",1,"Status OK",2,"Pendiente de Corregir"),observaciones,fecha_insert
				INTO cReviso,iStatus,cStatusRevision,cObservaciones, dTFecha
				FROM bdinteg:"informix".si_reporte_expediente
				WHERE empresa = pEmpresa
				AND numcte = cNumcte
				ORDER BY fecha_insert DESC

				IF dTFecha < dtFechaHoy THEN
					LET cReviso     = '';
					LET cStatusRevision = '';
				END IF;
				EXIT FOREACH;
			END FOREACH;

			IF (iStatus <> pTipoRevision) AND pTipoRevision <> 3  THEN
				CONTINUE FOREACH;
			END IF

			IF pTipoConsulta = 1 THEN --CZB
			--Se buscaran las cuentas dadas de alta creditos,Prestamos,debito
				FOREACH 
					SELECT 	sol.num_producto, sol.num_solicitud
						INTO cProducto, cNumCta
					FROM bdisolic:"informix".ss_solicitudes   sol
					WHERE sol.empresa = pEmpresa
					AND sol.numcte = cNumcte
					AND sol.status_solicitud NOT IN ('PC','AN','AP')
					AND sol.fecha_insert = dtFechaIni --BETWEEN  dtFechaIni and dtFechaFin

					LET iBandera = iBandera+1;

					IF iBandera <= pPaginacion THEN
						CONTINUE FOREACH;
					ELSE
						RETURN cCodRet, NVL(cProducto,""),NVL(cNumCta,""),NVL(cNumcte,""),NVL(cNombreCte,""),NVL(cEmpAlta,""),NVL(cReviso,"") , NVL(cStatusRevision,""),NVL(dtFechaAlta,DATE(1)),NVL(cObservaciones,"") WITH RESUME;
					END IF;
				END FOREACH
				FOREACH --cuentas aperturadas
					SELECT 	sol2.num_producto, sol2.num_solicitud
						INTO cProducto, cNumCta
					FROM bdisolic:"informix".ss_solicitudes   sol2
--					inner join bdinteg:"informix".si_cliente cte4 ON (cte4.empresa = pEmpresa and cte4.numcte = sol2.numcte)
					WHERE sol2.empresa = pEmpresa
					AND sol2.numcte = cNumcte
					AND sol2.status_solicitud = 'AP'
					AND sol2.sucursal =pSucursal
					AND sol2.num_solicitud IN (SELECT num_solicitud
										FROM bdisolic:"informix".ss_autorizacion aut
										WHERE  aut.empresa = pEmpresa AND aut.num_solicitud = sol2.num_solicitud AND aut.status_solicitud ='AP' AND aut.fecha_insert = dtFechaIni) --BETWEEN  dtFechaIni and dtFechaFin)


					LET iBandera = iBandera+1;

					IF iBandera <= pPaginacion THEN
						CONTINUE FOREACH;
					ELSE
						RETURN cCodRet, NVL(cProducto,""),NVL(cNumCta,""),NVL(cNumcte,""),NVL(cNombreCte,""),NVL(cEmpAlta,""),NVL(cReviso,"") , NVL(cStatusRevision,""),NVL(dtFechaAlta,DATE(1)),NVL(cObservaciones,"") WITH RESUME;
					END IF;

				END FOREACH
				FOREACH 	---cuentas de captacion

					SELECT mae.cuenta, Mae.producto
					INTO  cNumCta, cProducto
					FROM bdicheq:sc_maechq Mae
					INNER JOIN bdicheq:sc_maenoc noc on (noc.cuenta = mae.cuenta and noc.fecha_alta = dtFechaIni) --BETWEEN  dtFechaIni and dtFechaFin)
					WHERE  Mae.status_cta    = '1'
					AND Mae.empresa = pEmpresa	--Revisar indice
					AND Mae.num_cte = cNumcte
					AND Mae.producto IN ('1300','1400','1500','1700','1800','1900','2000','1100')

						LET iBandera = iBandera+1;

						IF iBandera <= pPaginacion THEN
							CONTINUE FOREACH;
						ELSE
							RETURN cCodRet, NVL(cProducto,""),NVL(cNumCta,""),NVL(cNumcte,""),NVL(cNombreCte,""),NVL(cEmpAlta,""),NVL(cReviso,"") , NVL(cStatusRevision,""),NVL(dtFechaAlta,DATE(1)),NVL(cObservaciones,"") WITH RESUME;
						END IF;


				END FOREACH;
				FOREACH 	---cuentas de inversion

					SELECT 	invers.cuenta, invers.cod_instrum
					INTO  cNumCta, cProducto
					FROM bdinvers:"informix".sv_maeinv   invers
					inner join bdinteg:"informix".si_cliente cte5 ON (cte5.empresa = pEmpresa and cte5.numcte = invers.num_cte)
					WHERE invers.empresa = pEmpresa
					AND invers.num_cte = cNumcte
					AND invers.fecha_alta = dtFechaIni --BETWEEN  dtFechaIni and dtFechaFin
					AND invers.sucursal =pSucursal
					AND invers.secuencia =1


						LET iBandera = iBandera+1;

						IF iBandera <= pPaginacion THEN
							CONTINUE FOREACH;
						ELSE
							RETURN cCodRet, NVL(cProducto,""),NVL(cNumCta,""),NVL(cNumcte,""),NVL(cNombreCte,""),NVL(cEmpAlta,""),NVL(cReviso,"") , NVL(cStatusRevision,""),NVL(dtFechaAlta,DATE(1)),NVL(cObservaciones,"") WITH RESUME;
						END IF;


				END FOREACH;

			ELSE
				LET iBandera = iBandera+1;

				IF iBandera <= pPaginacion THEN
					CONTINUE FOREACH;
				ELSE
					RETURN cCodRet, NVL(cProducto,""),NVL(cNumCta,""),NVL(cNumcte,""),NVL(cNombreCte,""),NVL(cEmpAlta,""),NVL(cReviso,"") , NVL(cStatusRevision,""),NVL(dtFechaAlta,DATE(1)),NVL(cObservaciones,"") WITH RESUME;
				END IF;

			END IF;
			LET cProducto	= '';
			LET cNumCta		= '';
			LET cNumcte		= '';
			LET cNombreCte  = '';
			LET cEmpAlta    = '';
			LET cReviso     = '';
			LET cStatusRevision = '';
			LET dtFechaAlta		= DATE(1);
			LET cObservaciones  = '';
		END FOREACH;

		FOREACH 
			SELECT unique numcte
			INTO cNumcte
			FROM bdisolic:"informix".ss_solicitudes sol2,
                 bdisolic:"informix".ss_autorizacion aut
			WHERE sol2.status_solicitud = 'AP'
			AND sol2.sucursal = pSucursal
            AND sol2.empresa = aut.empresa 
            AND sol2.status_solicitud = aut.status_solicitud 
            AND sol2.num_solicitud = aut.num_solicitud 
            AND aut.fecha_insert = dtFechaIni --BETWEEN dtFechaIni and dtFechaFin

            SELECT TRIM(nombre1)||" "||TRIM(nombre2)||" "||TRIM(apell_paterno)||" "||TRIM(apell_materno), fecha_insert, user_insert
            INTO cNombreCte,dtFechaAlta,cEmpAlta
            FROM bdinteg:"informix".si_cliente 
            WHERE numcte = cNumcte;

			IF EXISTS (SELECT sol.numcte
				FROM bdisolic:"informix".ss_solicitudes   sol
				WHERE sol.empresa = pEmpresa
				AND sol.numcte =  cNumcte
				AND sol.sucursal =pSucursal
				AND sol.fecha_insert = dtFechaIni --BETWEEN  dtFechaIni and dtFechaFin
				AND sol.status_solicitud NOT IN ('PC','AN')) THEN
				CONTINUE FOREACH;
			END IF;

			LET cReviso     = '';
			LET cStatusRevision = '';
			LET cObservaciones= '';
			LET iStatus= 0;

			IF EXISTS(SELECT Mae.num_cte
				FROM bdicheq:sc_maechq Mae
				INNER JOIN bdicheq:sc_maenoc noc on (noc.cuenta = mae.cuenta and noc.fecha_alta = dtFechaIni) --BETWEEN  dtFechaIni and dtFechaFin)
				WHERE  Mae.status_cta    = '1'
				AND Mae.empresa = pEmpresa
				AND Mae.num_cte = cNumcte
				AND mae.sucursal =pSucursal
				AND Mae.producto IN ('1300','1400','1500','1700','1800','1900','2000','1100')) THEN
				CONTINUE FOREACH;
			END IF;


			FOREACH 
				SELECT LIMIT 1 gerente,status_revision, DECODE(status_revision,0,"Sin Revisar",1,"Status OK",2,"Pendiente de Corregir"),observaciones,fecha_insert
				INTO cReviso,iStatus,cStatusRevision,cObservaciones, dTFecha
				FROM bdinteg:"informix".si_reporte_expediente
				WHERE empresa = pEmpresa
				AND numcte = cNumcte
				ORDER BY fecha_insert DESC

				IF dTFecha < dtFechaHoy THEN
					LET cReviso     = '';
					LET cStatusRevision = '';
				END IF;
				EXIT FOREACH;
			END FOREACH;

			IF (iStatus <> pTipoRevision) AND pTipoRevision <> 3  THEN
				CONTINUE FOREACH;
			END IF

			IF pTipoConsulta = 1 THEN --CZB
			--Se buscaran las cuentas dadas de alta creditos,Prestamos,debito
				FOREACH 
					SELECT 	sol.num_producto, sol.num_solicitud
						INTO cProducto, cNumCta
					FROM bdisolic:"informix".ss_solicitudes   sol
					WHERE sol.empresa = pEmpresa
					AND sol.numcte = cNumcte
					AND sol.status_solicitud NOT IN ('PC','AN','AP')
					AND sol.fecha_insert = dtFechaIni --BETWEEN  dtFechaIni and dtFechaFin

					LET iBandera = iBandera+1;

					IF iBandera <= pPaginacion THEN
						CONTINUE FOREACH;
					ELSE
						RETURN cCodRet, NVL(cProducto,""),NVL(cNumCta,""),NVL(cNumcte,""),NVL(cNombreCte,""),NVL(cEmpAlta,""),NVL(cReviso,"") , NVL(cStatusRevision,""),NVL(dtFechaAlta,DATE(1)),NVL(cObservaciones,"") WITH RESUME;
					END IF;
				END FOREACH
				FOREACH --cuentas aperturadas
					SELECT 	sol2.num_producto, sol2.num_solicitud
						INTO cProducto, cNumCta
					FROM bdisolic:"informix".ss_solicitudes   sol2
--					inner join bdinteg:"informix".si_cliente cte4 ON (cte4.empresa = pEmpresa and cte4.numcte = sol2.numcte)
					WHERE sol2.empresa = pEmpresa
					AND sol2.numcte = cNumcte
					AND sol2.status_solicitud = 'AP'
					AND sol2.sucursal =pSucursal
					AND sol2.num_solicitud IN (SELECT num_solicitud
										FROM bdisolic:"informix".ss_autorizacion aut
										WHERE  aut.empresa = pEmpresa AND aut.num_solicitud = sol2.num_solicitud AND aut.status_solicitud ='AP' AND aut.fecha_insert = dtFechaIni) --BETWEEN  dtFechaIni and dtFechaFin)


					LET iBandera = iBandera+1;

					IF iBandera <= pPaginacion THEN
						CONTINUE FOREACH;
					ELSE
						RETURN cCodRet, NVL(cProducto,""),NVL(cNumCta,""),NVL(cNumcte,""),NVL(cNombreCte,""),NVL(cEmpAlta,""),NVL(cReviso,"") , NVL(cStatusRevision,""),NVL(dtFechaAlta,DATE(1)),NVL(cObservaciones,"") WITH RESUME;
					END IF;

				END FOREACH
				FOREACH 	---cuentas de captacion

					SELECT mae.cuenta, Mae.producto
					INTO  cNumCta, cProducto
					FROM bdicheq:sc_maechq Mae
					INNER JOIN bdicheq:sc_maenoc noc on (noc.cuenta = mae.cuenta and noc.fecha_alta = dtFechaIni) --BETWEEN  dtFechaIni and dtFechaFin)
					WHERE  Mae.status_cta    = '1'
					AND Mae.empresa = pEmpresa	--Revisar indice
					AND Mae.num_cte = cNumcte
					AND Mae.producto IN ('1300','1400','1500','1700','1800','1900','2000','1100')

						LET iBandera = iBandera+1;

						IF iBandera <= pPaginacion THEN
							CONTINUE FOREACH;
						ELSE
							RETURN cCodRet, NVL(cProducto,""),NVL(cNumCta,""),NVL(cNumcte,""),NVL(cNombreCte,""),NVL(cEmpAlta,""),NVL(cReviso,"") , NVL(cStatusRevision,""),NVL(dtFechaAlta,DATE(1)),NVL(cObservaciones,"") WITH RESUME;
						END IF;


				END FOREACH;
				FOREACH 	---cuentas de inversion

					SELECT 	invers.cuenta, invers.cod_instrum
					INTO  cNumCta, cProducto
					FROM bdinvers:"informix".sv_maeinv   invers
					inner join bdinteg:"informix".si_cliente cte5 ON (cte5.empresa = pEmpresa and cte5.numcte = invers.num_cte)
					WHERE invers.empresa = pEmpresa
					AND invers.num_cte = cNumcte
					AND invers.fecha_alta = dtFechaIni ---BETWEEN  dtFechaIni and dtFechaFin
					AND invers.sucursal =pSucursal
					AND invers.secuencia =1


						LET iBandera = iBandera+1;

						IF iBandera <= pPaginacion THEN
							CONTINUE FOREACH;
						ELSE
							RETURN cCodRet, NVL(cProducto,""),NVL(cNumCta,""),NVL(cNumcte,""),NVL(cNombreCte,""),NVL(cEmpAlta,""),NVL(cReviso,"") , NVL(cStatusRevision,""),NVL(dtFechaAlta,DATE(1)),NVL(cObservaciones,"") WITH RESUME;
						END IF;


				END FOREACH;





			ELSE
				LET iBandera = iBandera+1;

				IF iBandera <= pPaginacion THEN
					CONTINUE FOREACH;
				ELSE
					RETURN cCodRet, NVL(cProducto,""),NVL(cNumCta,""),NVL(cNumcte,""),NVL(cNombreCte,""),NVL(cEmpAlta,""),NVL(cReviso,"") , NVL(cStatusRevision,""),NVL(dtFechaAlta,DATE(1)),NVL(cObservaciones,"") WITH RESUME;
				END IF;

			END IF;
			LET cProducto	= '';
			LET cNumCta		= '';
			LET cNumcte		= '';
			LET cNombreCte  = '';
			LET cEmpAlta    = '';
			LET cReviso     = '';
			LET cStatusRevision = '';
			LET dtFechaAlta		= DATE(1);
			LET cObservaciones  = '';
		END FOREACH;
		FOREACH 
			SELECT distinct (cte5.numcte),TRIM(cte5.nombre1)||" "||TRIM(cte5.nombre2)||" "||TRIM(cte5.apell_paterno)||" "||TRIM(cte5.apell_materno), cte5.fecha_insert,cte5.user_insert
			INTO cNumcte,cNombreCte,dtFechaAlta,cEmpAlta
			FROM bdinvers:"informix".sv_maeinv   invers
			inner join bdinteg:"informix".si_cliente cte5 ON (cte5.empresa = pEmpresa and cte5.numcte = invers.num_cte AND cte5.fecha_insert < dtFechaIni)
			WHERE invers.empresa = pEmpresa
			AND invers.num_cte = invers.num_cte
			AND invers.fecha_alta = dtFechaIni --BETWEEN  dtFechaIni and dtFechaFin
			AND invers.sucursal =pSucursal
			AND invers.secuencia =1


			IF EXISTS (SELECT sol.numcte
				FROM bdisolic:"informix".ss_solicitudes   sol
				WHERE sol.empresa = pEmpresa
				AND sol.numcte =  cNumcte
				AND sol.sucursal =pSucursal
				AND sol.fecha_insert = dtFechaIni --BETWEEN  dtFechaIni and dtFechaFin
				AND sol.status_solicitud NOT IN ('PC','AN')) THEN
				CONTINUE FOREACH;
			END IF;

			IF EXISTS (	SELECT 	sol2.numcte
			FROM bdisolic:"informix".ss_solicitudes   sol2
			WHERE sol2.empresa = pEmpresa
			AND sol2.numcte = cNumcte
			AND sol2.status_solicitud = 'AP'
			AND sol2.sucursal =pSucursal
			AND sol2.num_solicitud IN (SELECT num_solicitud
										FROM bdisolic:"informix".ss_autorizacion aut
										WHERE  aut.empresa = pEmpresa
										AND aut.num_solicitud = sol2.num_solicitud
										AND aut.status_solicitud ='AP'
										AND aut.fecha_insert = dtFechaIni )) THEN-- BETWEEN  dtFechaIni and dtFechaFin)) THEN
				CONTINUE FOREACH;
			END IF;

			LET cReviso     = '';
			LET cStatusRevision = '';
			LET cObservaciones= '';
			LET iStatus= 0;

			IF EXISTS(SELECT Mae.num_cte
				FROM bdicheq:sc_maechq Mae
				INNER JOIN bdicheq:sc_maenoc noc on (noc.cuenta = mae.cuenta and noc.fecha_alta = dtFechaIni) --BETWEEN  dtFechaIni and dtFechaFin)
				WHERE  Mae.status_cta    = '1'
				AND Mae.empresa = pEmpresa
				AND Mae.num_cte = cNumcte
				AND mae.sucursal =pSucursal
				AND Mae.producto IN ('1300','1400','1500','1700','1800','1900','2000','1100')) THEN
				CONTINUE FOREACH;
			END IF;


			FOREACH 
				SELECT LIMIT 1 gerente,status_revision, DECODE(status_revision,0,"Sin Revisar",1,"Status OK",2,"Pendiente de Corregir"),observaciones,fecha_insert
				INTO cReviso,iStatus,cStatusRevision,cObservaciones, dTFecha
				FROM bdinteg:"informix".si_reporte_expediente
				WHERE empresa = pEmpresa
				AND numcte = cNumcte
				ORDER BY fecha_insert DESC

				IF dTFecha < dtFechaHoy THEN
					LET cReviso     = '';
					LET cStatusRevision = '';
				END IF;
				EXIT FOREACH;
			END FOREACH;

			IF (iStatus <> pTipoRevision) AND pTipoRevision <> 3  THEN
				CONTINUE FOREACH;
			END IF

			IF pTipoConsulta = 1 THEN --CZB
			--Se buscaran las cuentas dadas de alta creditos,Prestamos,debito
				FOREACH 
					SELECT 	sol.num_producto, sol.num_solicitud
						INTO cProducto, cNumCta
					FROM bdisolic:"informix".ss_solicitudes   sol
					WHERE sol.empresa = pEmpresa
					AND sol.numcte = cNumcte
					AND sol.status_solicitud NOT IN ('PC','AN','AP')
					AND sol.fecha_insert = dtFechaIni --BETWEEN  dtFechaIni and dtFechaFin

					LET iBandera = iBandera+1;

					IF iBandera <= pPaginacion THEN
						CONTINUE FOREACH;
					ELSE
						RETURN cCodRet, NVL(cProducto,""),NVL(cNumCta,""),NVL(cNumcte,""),NVL(cNombreCte,""),NVL(cEmpAlta,""),NVL(cReviso,"") , NVL(cStatusRevision,""),NVL(dtFechaAlta,DATE(1)),NVL(cObservaciones,"") WITH RESUME;
					END IF;
				END FOREACH
				FOREACH --cuentas aperturadas
					SELECT 	sol2.num_producto, sol2.num_solicitud
						INTO cProducto, cNumCta
					FROM bdisolic:"informix".ss_solicitudes   sol2
--					inner join bdinteg:"informix".si_cliente cte4 ON (cte4.empresa = pEmpresa and cte4.numcte = sol2.numcte)
					WHERE sol2.empresa = pEmpresa
					AND sol2.numcte = cNumcte
					AND sol2.status_solicitud = 'AP'
					AND sol2.sucursal =pSucursal
					AND sol2.num_solicitud IN (SELECT num_solicitud
										FROM bdisolic:"informix".ss_autorizacion aut
										WHERE  aut.empresa = pEmpresa AND aut.num_solicitud = sol2.num_solicitud AND aut.status_solicitud ='AP' AND aut.fecha_insert = dtFechaIni) --BETWEEN  dtFechaIni and dtFechaFin)


					LET iBandera = iBandera+1;

					IF iBandera <= pPaginacion THEN
						CONTINUE FOREACH;
					ELSE
						RETURN cCodRet, NVL(cProducto,""),NVL(cNumCta,""),NVL(cNumcte,""),NVL(cNombreCte,""),NVL(cEmpAlta,""),NVL(cReviso,"") , NVL(cStatusRevision,""),NVL(dtFechaAlta,DATE(1)),NVL(cObservaciones,"") WITH RESUME;
					END IF;

				END FOREACH
				FOREACH 	---cuentas de captacion

					SELECT mae.cuenta, Mae.producto
					INTO  cNumCta, cProducto
					FROM bdicheq:sc_maechq Mae
					INNER JOIN bdicheq:sc_maenoc noc on (noc.cuenta = mae.cuenta and noc.fecha_alta = dtFechaIni) --BETWEEN  dtFechaIni and dtFechaFin)
					WHERE  Mae.status_cta    = '1'
					AND Mae.empresa = pEmpresa	--Revisar indice
					AND Mae.num_cte = cNumcte
					AND Mae.producto IN ('1300','1400','1500','1700','1800','1900','2000','1100')

						LET iBandera = iBandera+1;

						IF iBandera <= pPaginacion THEN
							CONTINUE FOREACH;
						ELSE
							RETURN cCodRet, NVL(cProducto,""),NVL(cNumCta,""),NVL(cNumcte,""),NVL(cNombreCte,""),NVL(cEmpAlta,""),NVL(cReviso,"") , NVL(cStatusRevision,""),NVL(dtFechaAlta,DATE(1)),NVL(cObservaciones,"") WITH RESUME;
						END IF;


				END FOREACH;
				FOREACH 	---cuentas de inversion

					SELECT 	invers.cuenta, invers.cod_instrum
					INTO  cNumCta, cProducto
					FROM bdinvers:"informix".sv_maeinv   invers
					INNER JOIN bdinteg:"informix".si_cliente cte5 ON (cte5.empresa = pEmpresa and cte5.numcte = invers.num_cte)
					WHERE invers.empresa = pEmpresa
					AND invers.num_cte = cNumcte
					AND invers.fecha_alta = dtFechaIni --BETWEEN  dtFechaIni and dtFechaFin
					AND invers.sucursal =pSucursal
					AND invers.secuencia =1


						LET iBandera = iBandera+1;

						IF iBandera <= pPaginacion THEN
							CONTINUE FOREACH;
						ELSE
							RETURN cCodRet, NVL(cProducto,""),NVL(cNumCta,""),NVL(cNumcte,""),NVL(cNombreCte,""),NVL(cEmpAlta,""),NVL(cReviso,"") , NVL(cStatusRevision,""),NVL(dtFechaAlta,DATE(1)),NVL(cObservaciones,"") WITH RESUME;
						END IF;


				END FOREACH;

			ELSE
				LET iBandera = iBandera+1;

				IF iBandera <= pPaginacion THEN
					CONTINUE FOREACH;
				ELSE
					RETURN cCodRet, NVL(cProducto,""),NVL(cNumCta,""),NVL(cNumcte,""),NVL(cNombreCte,""),NVL(cEmpAlta,""),NVL(cReviso,"") , NVL(cStatusRevision,""),NVL(dtFechaAlta,DATE(1)),NVL(cObservaciones,"") WITH RESUME;
				END IF;

			END IF;
			LET cProducto	= '';
			LET cNumCta		= '';
			LET cNumcte		= '';
			LET cNombreCte  = '';
			LET cEmpAlta    = '';
			LET cReviso     = '';
			LET cStatusRevision = '';
			LET dtFechaAlta		= DATE(1);
			LET cObservaciones  = '';
		END FOREACH;

	END IF;

	---Consulta por cliente
	IF NVL(pNumcte,"") <> "" THEN--va consultar todos los estatus
		FOREACH 
			SELECT numcte,TRIM(nombre1)||" "||TRIM(nombre2)||" "||TRIM(apell_paterno)||" "||TRIM(apell_materno), fecha_insert,user_insert
			INTO cNumcte,cNombreCte,dtFechaAlta,cEmpAlta
			FROM bdinteg:"informix".si_cliente
			WHERE empresa =pEmpresa
			AND numcte = pNumcte
			AND tipo_cliente = 1
			ORDER BY nombre1, nombre2, apell_paterno,apell_materno

			LET cReviso     = '';
			LET cStatusRevision = '';
			LET cObservaciones= '';

			FOREACH 
				SELECT LIMIT 1 gerente,status_revision, DECODE(status_revision,0,"Sin Revisar",1,"Status OK",2,"Pendiente de Corregir"),observaciones,fecha_insert
				INTO cReviso,iStatus,cStatusRevision,cObservaciones, dTFecha
				FROM bdinteg:"informix".si_reporte_expediente
				WHERE empresa = pEmpresa
				AND numcte = cNumcte
				ORDER BY fecha_insert DESC

				IF dTFecha < dtFechaHoy THEN
					LET cReviso     = '';
					LET cStatusRevision = '';
				END IF;
				EXIT FOREACH;
			END FOREACH;

			IF pTipoConsulta = 1 THEN --CZB
			--Se buscaran las cuentas dadas de alta creditos,Prestamos,debito
				FOREACH 
					SELECT 	def.nombre_prod, sol.num_solicitud
						INTO cProducto, cNumCta
					FROM bdisolic:"informix".ss_solicitudes   sol
					INNER JOIN bdicred:sd_definicion def ON (def.num_producto = sol.num_producto)
					WHERE sol.empresa = pEmpresa
					AND sol.numcte = cNumcte
					AND sol.status_solicitud NOT IN ('PC','AN','AP')
					AND sol.fecha_insert > dtFechaHoy

					LET iBandera = iBandera+1;

					IF iBandera <= pPaginacion THEN
						CONTINUE FOREACH;
					ELSE
						RETURN cCodRet, NVL(cProducto,""),NVL(cNumCta,""),NVL(cNumcte,""),NVL(cNombreCte,""),NVL(cEmpAlta,""),NVL(cReviso,"") , NVL(cStatusRevision,""),NVL(dtFechaAlta,DATE(1)),NVL(cObservaciones,"") WITH RESUME;
					END IF;
				END FOREACH
				FOREACH --cuentas aperturadas
					SELECT 	sol2.num_producto, sol2.num_solicitud
						INTO cProducto, cNumCta
					FROM bdisolic:"informix".ss_solicitudes   sol2
--					inner join bdinteg:"informix".si_cliente cte4 ON (cte4.empresa = pEmpresa and cte4.numcte = sol2.numcte)
					WHERE sol2.empresa = pEmpresa
					AND sol2.numcte = sol2.numcte
					AND sol2.status_solicitud = 'AP'
					AND sol2.sucursal =pSucursal
					AND sol2.num_solicitud IN (SELECT num_solicitud
										FROM bdisolic:"informix".ss_autorizacion aut
										WHERE  aut.empresa = pEmpresa AND aut.num_solicitud = sol2.num_solicitud AND aut.status_solicitud ='AP' AND aut.fecha_insert > dtFechaHoy)


					LET iBandera = iBandera+1;

					IF iBandera <= pPaginacion THEN
						CONTINUE FOREACH;
					ELSE
						RETURN cCodRet, NVL(cProducto,""),NVL(cNumCta,""),NVL(cNumcte,""),NVL(cNombreCte,""),NVL(cEmpAlta,""),NVL(cReviso,"") , NVL(cStatusRevision,""),NVL(dtFechaAlta,DATE(1)),NVL(cObservaciones,"") WITH RESUME;
					END IF;

				END FOREACH
				FOREACH 	---cuentas de captacion

					SELECT mae.cuenta, Mae.producto
					INTO  cNumCta, cProducto
					FROM bdicheq:sc_maechq Mae
					INNER JOIN bdicheq:sc_maenoc noc on (noc.cuenta = mae.cuenta and noc.fecha_alta > dtFechaHoy)
					WHERE  Mae.status_cta    = '1'
					AND Mae.empresa = pEmpresa	--Revisar indice
					AND Mae.num_cte = cNumcte
					AND Mae.producto IN ('1300','1400','1500','1700','1800','1900','2000','1100')

						LET iBandera = iBandera+1;

						IF iBandera <= pPaginacion THEN
							CONTINUE FOREACH;
						ELSE
							RETURN cCodRet, NVL(cProducto,""),NVL(cNumCta,""),NVL(cNumcte,""),NVL(cNombreCte,""),NVL(cEmpAlta,""),NVL(cReviso,"") , NVL(cStatusRevision,""),NVL(dtFechaAlta,DATE(1)),NVL(cObservaciones,"") WITH RESUME;
						END IF;

				END FOREACH;

				FOREACH 	---cuentas de inversion

					SELECT 	invers.cuenta, invers.cod_instrum
					INTO  cNumCta, cProducto
					FROM bdinvers:"informix".sv_maeinv   invers
					inner join bdinteg:"informix".si_cliente cte5 ON (cte5.empresa = pEmpresa and cte5.numcte = invers.num_cte)
					WHERE invers.empresa = pEmpresa
					AND invers.num_cte = cNumcte
					AND invers.fecha_alta > dtFechaHoy
					AND invers.secuencia =1


						LET iBandera = iBandera+1;

						IF iBandera <= pPaginacion THEN
							CONTINUE FOREACH;
						ELSE
							RETURN cCodRet, NVL(cProducto,""),NVL(cNumCta,""),NVL(cNumcte,""),NVL(cNombreCte,""),NVL(cEmpAlta,""),NVL(cReviso,"") , NVL(cStatusRevision,""),NVL(dtFechaAlta,DATE(1)),NVL(cObservaciones,"") WITH RESUME;
						END IF;


				END FOREACH;

			ELSE
				LET iBandera = iBandera+1;

				IF iBandera <= pPaginacion THEN
					CONTINUE FOREACH;
				ELSE
					RETURN cCodRet, NVL(cProducto,""),NVL(cNumCta,""),NVL(cNumcte,""),NVL(cNombreCte,""),NVL(cEmpAlta,""),NVL(cReviso,"") , NVL(cStatusRevision,"Sin Revisar"),NVL(dtFechaAlta,DATE(1)),NVL(cObservaciones,"") WITH RESUME;
				END IF;

			END IF;
			LET cProducto	= '';
			LET cNumCta		= '';
			LET cNumcte		= '';
			LET cNombreCte  = '';
			LET cEmpAlta    = '';
			LET cReviso     = '';
			LET cStatusRevision = '';
			LET dtFechaAlta		= DATE(1);
			LET cObservaciones  = '';
			LET dtFechaHoy =  DATE(1);

		END FOREACH;
	END IF;

	IF iBandera = 0 THEN
		LET cCodRet				= '00001';
		RETURN cCodRet, "","","","",DATE(1),"",0,"","";
	END IF;

END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Procedimiento para consultar clientes para realizar la validaciones de expediente',
'AUTOR: Jesus Manuel Aguilar Heredia',
'FECHA: 06 mayo 2014',
'VERSION: 201405061209',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_agregarbitacora_bpi(pFechaOper datetime year to second, pNumTrans char(4),pNumSuc char(4),pIdUsuario integer,pIpUsuario char(15),pFechaApli date,pCtaOrigen char(12),pCtaDesti char(18),pMonto money,pSecTrans char(16),pCgen1 char(40),pCgen2 char(40),pCgen3 char(40),pCgen4 char(40))
 returning char(5);
 
    -- Realizo   : Javier Alonso Chávez Trujillo
    -- Actividad : Agrega Bitacora
    -- Solicitó  : Mauricio Leon
    -- Fecha     : 25/11/2008
	--//////////////////////////////////////////
	-- Realizo   : Walber Castro
	-- Actividad : se modifica el tipo de dato del parametro de entrada Monto ya que redondeaba las cifras grandes.
	-- Solicitó  : Mauricio Leon
	-- Fecha     : 23/08/2010
	-- ////////////////////////////////////////
	-- Bibiana Gaxiola Verdugo
	-- Se agrega la actualización del movimiento en la tabla de cuentas frecuentes para la caducidad de las mismas.
	-- 21/01/2013
 
 --DEFINICION DE VARIABLES
DEFINE cod_ret char(5);
DEFINE sql_err integer;
DEFINE vCtasFrec CHAR(1);
DEFINE vNumCte CHAR(10);
DEFINE vCveCaducidad CHAR(1);

--INICIALIZA VARIABLES
LET cod_ret  = "000";

--SET DEBUG FILE TO "/home/informix/bibiana/sp_agregarbitacora_bpi.out";
--TRACE ON;

BEGIN
  ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
            RETURN cod_ret;
      END IF ;
   END EXCEPTION ;
   
   
	INSERT INTO si_bpibitacora(fecha_oper,  
			     id_operacion, 
			     sucursal, 
			     id_usuario,
			     ipusuario, 
			     fecha_aplic, 
			     cuenta_origen,
			     destino,
			     monto_oper, 
			     sec_transaccion,
			     cgenerico1,
			     cgenerico2,
			     cgenerico3,
			     cgenerico4) VALUES (pFechaOper,
						  pNumTrans,
						  pNumSuc,
						  pIdUsuario,
						  pIpUsuario,
						  pFechaApli,
						  pCtaOrigen,
						  pCtaDesti,
						  pMonto,
						  pSecTrans,
						  pCgen1,
						  pCgen2,
						  pCgen3,
						  pCgen4);
	

		
		SELECT ctas_frec INTO vCtasFrec FROM bdibpi:"informix".bpi_cat_operaciones WHERE id_oper = pNumTrans;
		
		IF (vCtasFrec = '1') THEN --- Significa que son operaciones que involucran cuentas frecuentes
		
			SELECT numcliente INTO vNumCte FROM bdibpi:"informix".bpi_usuario WHERE id_usuario = pIdUsuario AND st_portal = 'activo';
		
			IF (pNumTrans IN ('1016','2100','2017','2020','2021','2022','2023')) THEN
				SELECT cve_caducidad INTO vCveCaducidad FROM bdiprog:"informix".pp_ctasterceros WHERE cuenta = pCtaDesti AND num_cte = vNumCte;

				IF (vCveCaducidad = '3') THEN
					UPDATE bdiprog:"informix".pp_ctasterceros SET fecha_movtos = today WHERE cuenta = pCtaDesti AND num_ctE = vNumCte;
					RETURN cod_ret;
				ELSE
					RETURN cod_ret;
				END IF;
			ELSE
			--IN ('1015','1017','1020','1021','1022','1023','1024','1025')) THEN 
				SELECT cve_caducidad INTO vCveCaducidad FROM bdiprog:"informix".pp_ctasterceros WHERE cuenta = pCgen2 AND num_cte = vNumCte;
			
				IF (vCveCaducidad = '3') THEN
					UPDATE bdiprog:"informix".pp_ctasterceros SET fecha_movtos = today WHERE cuenta = pCgen2 AND num_ctE = vNumCte;
					RETURN cod_ret;
				ELSE
					RETURN cod_ret;
				END IF;
			END IF;
			
		END IF;
	
	RETURN cod_ret;
	 
END;
END PROCEDURE;
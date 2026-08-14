CREATE PROCEDURE "informix".sp_val_clubproteccion(pCliente CHAR(20),pCuenta CHAR(20),pCredito CHAR(20),pTarjeta CHAR(20))


RETURNING CHAR(6) AS codRet,
		  DATE AS fecha_vencimiento;

--DEFINICION DE VARIABLES
DEFINE cCodret CHAR(6);
DEFINE iSqlErr INTEGER;
DEFINE dtFechaHoy DATE;
DEFINE dtFechaVenc DATE;
DEFINE cNumCte CHAR(20);
DEFINE iDiaVenc INTEGER;

--INICIALIZACION DE VARIABLES
LET cCodret	= "000000";
LET iSqlErr = 0;
LET iDiaVenc = 0;
LET cNumCte = '';
LET dtFechaHoy = '';
LET dtFechaVenc = DATE(1);

--SET DEBUG FILE TO '/home/sysifx/Bryan/137/sp_val_clubproteccion.out';
--TRACE ON;

BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodret = iSqlErr;
			RETURN cCodret,dtFechaVenc;
		END IF;
	END EXCEPTION;


RETURN cCodret,today+100;


	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	
	LET pCliente=TRIM(NVL(pCliente,''));
	LET pCuenta=TRIM(NVL(pCuenta,''));
	LET pCredito=TRIM(NVL(pCredito,''));
	LET pTarjeta=TRIM(NVL(pTarjeta,''));
	
	

	IF pCliente = '' AND pCuenta = '' AND pCredito= '' AND pTarjeta = '' THEN
		LET cCodret	= "000001";
	ELSE
		IF pCliente = '' THEN
			IF  pCuenta <> '' OR pCredito <> '' THEN
				SELECT num_cte INTO cNumCte FROM bdicheq: "informix".sc_maechq WHERE cuenta = pCuenta;
				IF dbinfo("sqlca.sqlerrd2") = 0 then
					SELECT numcte INTO cNumCte FROM bdicred: "informix".sd_maecred WHERE num_credito = pCredito;

					IF dbinfo("sqlca.sqlerrd2") = 0 then
						SELECT numcte INTO cNumCte FROM bdicred: "informix".sd_maecredcrd WHERE num_credito = pCredito;
					END IF;
				END IF;
			ELIF pTarjeta <> '' THEN
				SELECT numcte INTO cNumCte FROM bdicred: "informix".sd_tarjeta WHERE num_tarjeta = pTarjeta;

				IF dbinfo("sqlca.sqlerrd2") = 0 then
					SELECT numcte INTO cNumCte FROM bdicheq: "informix".sc_tarjeta WHERE num_tarjeta = pTarjeta;
				END IF;
			END IF;
		ELSE
			SELECT fecha_hoy INTO dtFechaHoy FROM bdinteg: "informix".si_fechas where empresa='001';

			SELECT fecha_vencimiento INTO dtFechaVenc FROM bdinteg: "informix".si_ctesavencer  WHERE numcte_banco = pCliente AND pagado = 0;

			IF dtFechaHoy <= dtFechaVenc THEN
				LET iDiaVenc =  dtFechaVenc - dtFechaHoy;
				LET iDiaVenc = NVL(iDiaVenc,0);

				IF iDiaVenc <= 7 THEN
					LET cCodret	= "1468";
					RETURN cCodret,dtFechaVenc;
				END IF;
			ELIF dtFechaHoy > dtFechaVenc THEN
				LET iDiaVenc =  dtFechaHoy - dtFechaVenc;
				LET iDiaVenc = NVL(iDiaVenc,0);

				IF iDiaVenc > 0 AND iDiaVenc <= 60 THEN
					LET cCodret	= '1469';
					RETURN cCodret,dtFechaVenc;
				ELIF iDiaVenc > 60 THEN
					LET cCodret	= '1470';
					RETURN cCodret,dtFechaVenc;
				END IF;
			END IF;
		END IF;

	END IF;

	RETURN cCodret,dtFechaVenc;
END
END PROCEDURE
DOCUMENT
'Folio: 137 Consulta saldos para Club de proteccion familiar.',
'Autor: Bryan Limon',
'BD: bdinteg',
'Fecha: 03/11/2016',
'DescripciÃÂ³n: REALIZA LA VALIDACIÃÂN SEGUN EL ESTADO EN QUE SE ENCUENTRE EL CLUB DE PROTECCION DEL CLIENTE VALIDA QUE MENSAJE MOSTRAR AL USUARIO AL USUARIO';

CREATE PROCEDURE "informix".sp_monitor_expediente_ctes_mx1(pEmpresa char(3),  pSucursal CHAR(4),pNumcte CHAR(20),pTipoConsulta SMALLINT,pFechaIni DATE,pFechaFin DATE,pTipoRevision INTEGER, pPaginacion SMALLINT )

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
			WHERE cte3.fecha_insert BETWEEN  dtFechaIni and dtFechaFin
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
					AND sol.fecha_insert BETWEEN  dtFechaIni and dtFechaFin

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
										WHERE  aut.empresa = pEmpresa AND aut.num_solicitud = sol2.num_solicitud AND aut.status_solicitud ='AP' AND aut.fecha_insert BETWEEN  dtFechaIni and dtFechaFin)

                   


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
					INNER JOIN bdicheq:sc_maenoc noc on (noc.cuenta = mae.cuenta and noc.fecha_alta BETWEEN  dtFechaIni and dtFechaFin)
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
					AND invers.fecha_alta BETWEEN  dtFechaIni and dtFechaFin
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
			INNER JOIN bdicheq:sc_maenoc noc on (noc.cuenta = mae.cuenta and noc.fecha_alta BETWEEN  dtFechaIni and dtFechaFin)
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
					AND sol.fecha_insert BETWEEN  dtFechaIni and dtFechaFin

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
										WHERE  aut.empresa = pEmpresa AND aut.num_solicitud = sol2.num_solicitud AND aut.status_solicitud ='AP' AND aut.fecha_insert BETWEEN  dtFechaIni and dtFechaFin)


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
					INNER JOIN bdicheq:sc_maenoc noc on (noc.cuenta = mae.cuenta and noc.fecha_alta BETWEEN  dtFechaIni and dtFechaFin)
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
					AND invers.fecha_alta BETWEEN  dtFechaIni and dtFechaFin
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
			AND sol.fecha_insert BETWEEN  dtFechaIni and dtFechaFin
			AND sol.status_solicitud NOT IN ('PC','AN')

			LET cReviso     = '';
			LET cStatusRevision = '';
			LET cObservaciones= '';
			LET iStatus= 0;

			IF EXISTS(SELECT Mae.num_cte
				FROM bdicheq:sc_maechq Mae
				INNER JOIN bdicheq:sc_maenoc noc on (noc.cuenta = mae.cuenta and noc.fecha_alta BETWEEN  dtFechaIni and dtFechaFin)
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
					AND sol.fecha_insert BETWEEN  dtFechaIni and dtFechaFin

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
										WHERE  aut.empresa = pEmpresa AND aut.num_solicitud = sol2.num_solicitud AND aut.status_solicitud ='AP' AND aut.fecha_insert BETWEEN  dtFechaIni and dtFechaFin)


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
					INNER JOIN bdicheq:sc_maenoc noc on (noc.cuenta = mae.cuenta and noc.fecha_alta BETWEEN  dtFechaIni and dtFechaFin)
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
					AND invers.fecha_alta BETWEEN  dtFechaIni and dtFechaFin
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
            AND aut.fecha_insert BETWEEN dtFechaIni and dtFechaFin

            SELECT TRIM(nombre1)||" "||TRIM(nombre2)||" "||TRIM(apell_paterno)||" "||TRIM(apell_materno), fecha_insert, user_insert
            INTO cNombreCte,dtFechaAlta,cEmpAlta
            FROM bdinteg:"informix".si_cliente 
            WHERE numcte = cNumcte;

			IF EXISTS (SELECT sol.numcte
				FROM bdisolic:"informix".ss_solicitudes   sol
				WHERE sol.empresa = pEmpresa
				AND sol.numcte =  cNumcte
				AND sol.sucursal =pSucursal
				AND sol.fecha_insert BETWEEN  dtFechaIni and dtFechaFin
				AND sol.status_solicitud NOT IN ('PC','AN')) THEN
				CONTINUE FOREACH;
			END IF;

			LET cReviso     = '';
			LET cStatusRevision = '';
			LET cObservaciones= '';
			LET iStatus= 0;

			IF EXISTS(SELECT Mae.num_cte
				FROM bdicheq:sc_maechq Mae
				INNER JOIN bdicheq:sc_maenoc noc on (noc.cuenta = mae.cuenta and noc.fecha_alta BETWEEN  dtFechaIni and dtFechaFin)
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
					AND sol.fecha_insert BETWEEN  dtFechaIni and dtFechaFin

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
										WHERE  aut.empresa = pEmpresa AND aut.num_solicitud = sol2.num_solicitud AND aut.status_solicitud ='AP' AND aut.fecha_insert BETWEEN  dtFechaIni and dtFechaFin)


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
					INNER JOIN bdicheq:sc_maenoc noc on (noc.cuenta = mae.cuenta and noc.fecha_alta BETWEEN  dtFechaIni and dtFechaFin)
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
					AND invers.fecha_alta BETWEEN  dtFechaIni and dtFechaFin
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
			AND invers.fecha_alta BETWEEN  dtFechaIni and dtFechaFin
			AND invers.sucursal =pSucursal
			AND invers.secuencia =1


			IF EXISTS (SELECT sol.numcte
				FROM bdisolic:"informix".ss_solicitudes   sol
				WHERE sol.empresa = pEmpresa
				AND sol.numcte =  cNumcte
				AND sol.sucursal =pSucursal
				AND sol.fecha_insert BETWEEN  dtFechaIni and dtFechaFin
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
										AND aut.fecha_insert BETWEEN  dtFechaIni and dtFechaFin)) THEN
				CONTINUE FOREACH;
			END IF;

			LET cReviso     = '';
			LET cStatusRevision = '';
			LET cObservaciones= '';
			LET iStatus= 0;

			IF EXISTS(SELECT Mae.num_cte
				FROM bdicheq:sc_maechq Mae
				INNER JOIN bdicheq:sc_maenoc noc on (noc.cuenta = mae.cuenta and noc.fecha_alta BETWEEN  dtFechaIni and dtFechaFin)
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
					AND sol.fecha_insert BETWEEN  dtFechaIni and dtFechaFin

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
										WHERE  aut.empresa = pEmpresa AND aut.num_solicitud = sol2.num_solicitud AND aut.status_solicitud ='AP' AND aut.fecha_insert BETWEEN  dtFechaIni and dtFechaFin)


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
					INNER JOIN bdicheq:sc_maenoc noc on (noc.cuenta = mae.cuenta and noc.fecha_alta BETWEEN  dtFechaIni and dtFechaFin)
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
					AND invers.fecha_alta BETWEEN  dtFechaIni and dtFechaFin
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

CREATE PROCEDURE "informix".sp_valida_domicilio_ife
(
   pEmpresa CHAR(3),
   pNumCte CHAR(20)
)
RETURNING CHAR(5) AS codret , INTEGER AS secuencia;

	DEFINE cCodRet CHAR(5);
	DEFINE iSecuencia INTEGER;
	DEFINE iSql_err INTEGER;
	DEFINE cNumCredito CHAR(20);
	DEFINE iContadorCreditos INTEGER;
	DEFINE iContadorPrestamos INTEGER;
	DEFINE bBandCreditos BOOLEAN;
	DEFINE bBandPrestamos BOOLEAN;
	DEFINE dFechaHoy DATE;
	DEFINE dFechaLimite DATE;
	DEFINE dFecha_AltaId DATE;
	DEFINE vObservacionesId VARCHAR(200);
	DEFINE dFecha_AltaComp DATE;
	DEFINE vObservacionesComp VARCHAR(200);
	DEFINE dtFecUltPag DATE;
	DEFINE dtfechaalta DATE;
	DEFINE v_coddocto CHAR(4);

	LET cCodRet = '00000';
	LET iSecuencia = 0;
	LET iSql_err	 = 0;
	LET cNumCredito ='';
	LET iContadorCreditos = 0;
	LET iContadorPrestamos = 0;
	LET bBandCreditos = 'f' ;
	LET bBandPrestamos = 'f';
	LET dFecha_AltaId = '';
	LET vObservacionesId = '';
	LET dFecha_AltaComp = '';
	LET dtFecUltPag = '';
	LET dtfechaalta = '';
	LET vObservacionesComp = '';
	LET v_coddocto = '';

	BEGIN

		ON EXCEPTION SET iSql_err
			IF iSql_err <> 0 THEN
				LET cCodRet = iSql_err;
				RETURN cCodRet , iSecuencia ;
			END IF;
		END EXCEPTION;

		--SET DEBUG FILE TO "/dbexportb/marioolivo/sp_valida_domicilio_ife.out";
		--TRACE ON;

		--SET DEBUG FILE TO "/respaldosbd/mc/sp_valida_domicilio_ife.out";
		--TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;


		--IF cCodRet = '00002' OR cCodRet = '00003' THEN
        let cCodRet = '00002';
			SELECT  MAX(secuencia)  INTO iSecuencia
			from "informix".si_direcciones_actual
			WHERE tipo_dir = 1 AND numcte = pNumCte;
		--END IF;

		RETURN cCodRet,iSecuencia;



		--VALIDA PARAMETROS
		IF NVL(pEmpresa,'') <> '' AND NVL(pNumCte,'') <> '' THEN

			SELECT fecha_hoy INTO dFechaHoy FROM bdicred:"informix".sd_fechas;





			--RESTA UN AÑO A LA FECHA HOY.
			EXECUTE PROCEDURE bdicred:"informix".monthadd(dFechaHoy,-12)  INTO dFechaLimite;

			--VALIDA SI TIENE COMO COMPROBANTE DE DOMICILIO LA IFE.
			/*IF (SELECT cod_docto FROM bdidigital@coppelimg_tcp:"informix".dg_expediente WHERE  ROWID = (SELECT MAX(ROWID) FROM bdidigital@coppelimg_tcp:"informix".dg_expediente WHERE empresa = pEmpresa AND cliente = pNumCte  AND cod_docto IN (SELECT cod_docto FROM  bdidigital@coppelimg_tcp:"informix".dg_tipodocumento WHERE cod_grupo = '001'))) = '0001'
			AND (SELECT cod_docto FROM bdidigital@coppelimg_tcp:"informix".dg_expediente  WHERE  ROWID =  (SELECT MAX(ROWID) FROM bdidigital@coppelimg_tcp:"informix".dg_expediente WHERE empresa = pEmpresa AND cliente = pNumCte  AND  cod_docto IN  (SELECT cod_docto FROM  bdidigital@coppelimg_tcp:"informix".dg_tipodocumento WHERE cod_grupo = '002')))  = '0033' THEN

			--OBTIENE LA FECHA DE ALTA EN LA DG_EXPEDIENTE.
			SELECT MAX(fecha_alta),MAX(observaciones)
			INTO dFecha_AltaId,vobservacionesId
			FROM bdidigital@coppelimg_tcp:"informix".dg_expediente_img
			WHERE empresa = pEmpresa
			AND cliente = pNumCte
			AND cod_docto IN (SELECT cod_docto FROM  bdidigital@coppelimg_tcp:"informix".dg_tipodocumento WHERE cod_grupo = '001');

			IF (SELECT cod_docto FROM bdidigital@coppelimg_tcp:"informix".dg_expediente_img WHERE ROWID = (SELECT MAX(ROWID)
				FROM bdidigital@coppelimg_tcp:"informix".dg_expediente_img
				WHERE empresa = pEmpresa AND cliente = pNumCte
				AND cod_docto IN (SELECT cod_docto FROM  bdidigital@coppelimg_tcp:"informix".dg_tipodocumento WHERE cod_grupo = '001')
				)
				AND fecha_alta = dFecha_AltaId AND observaciones = vobservacionesId AND empresa = pEmpresa AND cliente = pNumCte) = '0001' THEN

				SELECT MAX(fecha_alta),MAX(observaciones)
				INTO dFecha_AltaComp,vObservacionesComp
				FROM bdidigital@coppelimg_tcp:"informix".dg_expediente_img
				WHERE empresa = pEmpresa
				AND cliente = pNumCte
				AND cod_docto IN (SELECT cod_docto FROM  bdidigital@coppelimg_tcp:"informix".dg_tipodocumento WHERE cod_grupo = '002');


				IF (SELECT cod_docto FROM bdidigital@coppelimg_tcp:"informix".dg_expediente_img WHERE ROWID = (SELECT MAX(ROWID)
					FROM bdidigital@coppelimg_tcp:"informix".dg_expediente_img
					WHERE empresa = pEmpresa AND cliente = pNumCte
					AND cod_docto IN (SELECT cod_docto FROM  bdidigital@coppelimg_tcp:"informix".dg_tipodocumento WHERE cod_grupo = '002')
					)
					AND fecha_alta = dFecha_AltaComp AND observaciones = vObservacionesComp AND empresa = pEmpresa AND cliente = pNumCte) = '0033' THEN*/

			FOREACH
				SELECT LIMIT 1 a.cod_docto, a.fecha_alta, b.observaciones
				INTO v_coddocto,dFecha_AltaComp,vObservacionesComp
				FROM bdidigital@coppelimg_tcp:"informix".dg_expediente a, bdidigital@coppelimg_tcp:"informix".dg_expediente_img b, bdidigital@coppelimg_tcp:"informix".dg_tipodocumento c
				-- WHERE a.empresa = b.empresa
				WHERE a.cliente = b.cliente
				AND a.cod_docto = b.cod_docto
				AND a.secuencia = b.secuencia
				AND a.cliente = pNumCte
				AND a.cod_docto = c.cod_docto
				AND c.cod_grupo = '002'
				ORDER BY fecha_alta DESC, observaciones DESC
			END FOREACH;

			IF v_coddocto = '0033' THEN

					--VERIFICA SI TIENE CREDITOS
						FOREACH

							SELECT num_credito INTO cNumCredito FROM bdicred:"informix".sd_maecred WHERE empresa = pEmpresa AND numcte = pNumCte

							LET iContadorCreditos = iContadorCreditos +1;

							--REVIZA CUAL FUE SU ULTIMA FECHA DE PAGO Y LA FECHA DE ALTA
							SELECT fecha_ultimo_pago ,fecha_alta
							INTO dtFecUltPag,dtfechaalta
							FROM bdicred:"informix".sd_indicador_cred
							WHERE num_credito = cNumCredito;

							--VALIDA LA FECHA ULTIMO PAGO
							IF NVL(dtFecUltPag,DATE(1)) = DATE(1)THEN
							--VALIDA LA FECHA ALTA DEL CREDITO
								IF NVL(dtfechaalta,DATE(1)) > dFechaLimite THEN
									LET bBandCreditos = 't' ;
									EXIT FOREACH;
								ELSE
									LET bBandCreditos = 'f' ;
								END IF;
							ELIF  NVL(dtFecUltPag,DATE(1))> dFechaLimite  THEN
								LET bBandCreditos = 't' ;
								EXIT FOREACH;
							END IF

						END FOREACH;
						--VERIFICA SI TIENE PRESTAMOS
						FOREACH

							SELECT num_credito INTO cNumCredito FROM bdicred:"informix".sd_maecredcrd WHERE empresa = pEmpresa
							AND numcte = pNumCte

							LET iContadorPrestamos = iContadorPrestamos +1;

							--REVIZA CUAL FUE SU ULTIMA FECHA DE PAGO
							SELECT fecha_ultimo_pago,fecha_alta
							INTO dtFecUltPag,dtfechaalta
							FROM bdicred:"informix".sd_indicador_cred_crd
							WHERE num_credito = cNumCredito;

							IF NVL(dtFecUltPag,DATE(1)) = DATE(1)THEN
								IF NVL(dtfechaalta,DATE(1)) > dFechaLimite THEN
									LET bBandPrestamos = 't' ;
									EXIT FOREACH;
								ELSE
									LET bBandPrestamos = 'f' ;
								END IF;
							ELIF  NVL(dtFecUltPag,DATE(1))> dFechaLimite  THEN
								LET bBandPrestamos = 't';
								EXIT FOREACH;
							END IF;

						END FOREACH;

						--VALIDACION DE CREDITOS Y PRESTAMOS ASI COMO TAMBIEN SE VALIDA LA FECHA DEL ULTIMO PAGO.
						IF iContadorCreditos > 0  AND iContadorPrestamos = 0 THEN
							IF  bBandCreditos = 'f' THEN
								LET cCodRet = '00002';
							END IF;
						ELIF iContadorCreditos = 0  AND iContadorPrestamos > 0 THEN
							IF  bBandPrestamos = 'f' THEN
								LET cCodRet = '00002';
							END IF;
						ELIF iContadorCreditos > 0  AND iContadorPrestamos > 0 THEN
							IF bBandPrestamos='f' AND bBandCreditos = 'f' THEN
								LET cCodRet = '00002';
							END IF;
						ELIF iContadorCreditos = 0  AND iContadorPrestamos = 0 THEN
							LET cCodRet = '00003';
						END IF;
					--END IF;
				--END IF;
				END IF;
			ELSE
				LET cCodRet = '00001';
			END IF;


	END;
END PROCEDURE
DOCUMENT
"Folio:1586",
"Autor:95142134 Mario Gallardo",
"Fecha:27/02/2014",
"Modificación: Se crea SP para vailidar que el domicilio de el cliente sea el mismo que el de la IFE",
"Sustento: RQM 09 337 Mantenimiento de Datos y OS para Domicilio diferente al IFE_0001_v1.0.pdf",
"Solicita: Jaime Garciadiego, Juan Miguel Rivas ",
"BD: bdinteg",
"Folio:1430",
"Autor:Ivan Garcia",
"Fecha:27/05/2014",
"Modificación: Se modifica SP para obtener correctamente si la credencial de elector fue digitalizada como identificacion y como comprobante de domicilio",
"Sustento:RQM 09 337 Mantenimiento de Datos y OS para Domicilio diferente al IFE_0001_v1.0.pdf",
"Solicita: Angeles Perez,Rodolfo Gomez",
"BD: bdinteg",
'Modifica: Mario Gamaliel Olivo Urias',
'Solicita: Rodolfo Gomez',
'Modificacion: Se modifica la validacion de la ultima fecha de pago.',
'BD: bdinteg',
'FOLIO:1663',
'BD:bdinteg',
'MODIFICACION:Se modifica procedimiento para validar que el cliente haya presentado su credencial de elector(IFE) como identificación y',
'comprobante de domicilio. Si la validación es correcta consulta si cuenta con algun crédito o prestamo para tomar su fecha de ultimo pago.',
'Cuando el valor de la fecha de ultimo pago sea igual a null,se consultara con la fecha de alta y en caso de ser menor a la fecha limite,', 'mandara un código de retorno que otro componente interpretara.',
'AUTOR:Isarai Bojorquez',
'FECHA:20140911.1200';

CREATE PROCEDURE "informix".sp_obtiene_cterfc( pRfc CHAR(13))

RETURNING CHAR(5) AS codret , 
	      CHAR(9) as numcte;

DEFINE vCodret CHAR (5);
DEFINE vNumcte CHAR (20);
DEFINE vSql_err INTEGER;  

LET vCodret  = '00000';
LET vNumcte  = '';
LET vSql_err = 0;

 BEGIN

     ON EXCEPTION SET vSql_err
        IF vSql_err <> 0 THEN
           LET vCodret = vSql_err;
           RETURN vCodret, vNumcte ;
        END IF;
     END EXCEPTION;
     
     --SET DEBUG FILE TO "/tmp/sp_obtiene_cterfc.out";
     --TRACE ON;

     SET LOCK MODE TO WAIT 3;
     SET ISOLATION TO DIRTY READ;

     IF pRfc is null or pRfc ="" THEN 
        LET vCodret = '00002' ; -- Falta parametro de entrada
        RETURN vCodret, vNumcte ;

     END IF;

     SELECT LIMIT 1 numcte 
     INTO vNumcte
     FROM si_cliente 
     WHERE rfc = pRfc; 
 
     LET vNumcte = NVL(vNumcte,'');

     RETURN vCodret, vNumcte ;
 END;
END PROCEDURE;
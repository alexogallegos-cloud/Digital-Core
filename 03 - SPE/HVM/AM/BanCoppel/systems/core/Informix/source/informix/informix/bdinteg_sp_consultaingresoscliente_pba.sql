CREATE PROCEDURE "informix".sp_consultaingresoscliente_pba(pTipoOper SMALLINT, pNumCte CHAR(20), pTipoIngres CHAR(1))
	RETURNING 	CHAR(5), CHAR(3), CHAR(20), SMALLINT, CHAR(1), CHAR(60), CHAR (3), CHAR(2), DECIMAL(4,2), CHAR(40), CHAR(60), MONEY(14,2),
				CHAR(8), DATE, INTEGER, INTEGER, INTEGER, INTEGER, INTEGER, INTEGER, INTEGER;

--Definicion de Variables
DEFINE iSqlErr INTEGER;
DEFINE cCodRet CHAR(5);
DEFINE cEmpres CHAR(3);
DEFINE cNumCte CHAR(20);
DEFINE sSecIng SMALLINT;
DEFINE cTipIng CHAR(1);
DEFINE cNomEmp CHAR(60);
DEFINE cPuesto CHAR(3);
DEFINE cPutEsp CHAR(2);
DEFINE dAntigd DECIMAL(4,2);
DEFINE cNomDep CHAR(40);
DEFINE cJefInm CHAR(60);
DEFINE mIngMen MONEY(14,2);
DEFINE cUsrInt CHAR(8);
DEFINE dFecInt DATE;
DEFINE iCvePst INTEGER;
DEFINE iCveOPt INTEGER;
DEFINE iCveSOP INTEGER;
DEFINE iSisCot INTEGER;
DEFINE iNumELa INTEGER;
DEFINE iPerios INTEGER;
DEFINE iTipIEx INTEGER;

--Inicializacion de Variables
LET iSqlErr = 0;
LET cCodRet = '00000';
LET cEmpres = '';
LET cNumCte = '';
LET sSecIng = 0;
LET cTipIng = '';
LET cNomEmp = '';
LET cPuesto = '';
LET cPutEsp = '';
LET dAntigd = 0;
LET cNomDep = '';
LET cJefInm = '';
LET mIngMen = 0;
LET cUsrInt = '';
LET dFecInt = DATE(1);
LET iCvePst = 0;
LET iCveOPt = 0;
LET iCveSOP = 0;
LET iSisCot = 0;
LET iNumELa = 0;
LET iPerios = 0;
LET iTipIEx = 0;

--SET DEBUG FILE TO '/tmp/sp_ConsultaIngresosCliente.out';
--TRACE ON;

BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cEmpres, cNumCte, sSecIng, cTipIng, cNomEmp, cPuesto, cPutEsp, dAntigd, cNomDep, cJefInm, mIngMen, cUsrInt, dFecInt, 
			iCvePst, iCveOPt, iCveSOP, iSisCot, iNumELa, iPerios, iTipIEx;
		END IF;
	END EXCEPTION;
	
	SET LOCK MODE TO WAIT 3;
	
	IF pNumCte = '' OR pTipoIngres = '' THEN
		LET cCodRet = '00001';
		RETURN cCodRet, cEmpres, cNumCte, sSecIng, cTipIng, cNomEmp, cPuesto, cPutEsp, dAntigd, cNomDep, cJefInm, mIngMen, cUsrInt, dFecInt, 
		iCvePst, iCveOPt, iCveSOP, iSisCot, iNumELa, iPerios, iTipIEx;
	END IF;
	
	
	IF pTipoOper = 1 THEN --Consulta los datos de ingreso del cliente
		IF (SELECT COUNT(sec_ingreso) FROM bdinteg:"informix".si_ingresos WHERE numcte = pNumCte AND tipo_ingreso = pTipoIngres) > 0 THEN
			SELECT empresa, numcte, sec_ingreso, tipo_ingreso, nombre_empresa, puesto, puesto_esp, antiguedad, nombre_depto, jefe_inmediato, ingreso_mensual,
			user_insert, fecha_insert, clavepuesto, claveopcionpuesto, clavesubopcionpuesto, sis_cotiza, num_emp_lab, periosidad, tipo_ingreso_ext
			INTO cEmpres, cNumCte, sSecIng, cTipIng, cNomEmp, cPuesto, cPutEsp, dAntigd, cNomDep, cJefInm, mIngMen, cUsrInt, dFecInt, 
			iCvePst, iCveOPt, iCveSOP, iSisCot, iNumELa, iPerios, iTipIEx
			FROM bdinteg:"informix".si_ingresos 
			WHERE numcte = pNumCte 
			AND sec_ingreso = (SELECT MAX(sec_ingreso) FROM bdinteg:"informix".si_ingresos WHERE numcte = pNumCte AND tipo_ingreso = pTipoIngres)
			AND tipo_ingreso = pTipoIngres;
		ELSE
			LET cCodRet = '00001';
		END IF;
	ELIF pTipoOper = 2 THEN --Colsulta los datos de ingreso del cliente, si no exite, consulta en bitacora.
		IF (SELECT COUNT(sec_ingreso) FROM bdinteg:"informix".si_ingresos WHERE numcte = pNumCte AND tipo_ingreso = pTipoIngres) > 0 THEN
			SELECT empresa, numcte, sec_ingreso, tipo_ingreso, nombre_empresa, puesto, puesto_esp, antiguedad, nombre_depto, jefe_inmediato, ingreso_mensual,
			user_insert, fecha_insert, clavepuesto, claveopcionpuesto, clavesubopcionpuesto, sis_cotiza, num_emp_lab, periosidad, tipo_ingreso_ext
			INTO cEmpres, cNumCte, sSecIng, cTipIng, cNomEmp, cPuesto, cPutEsp, dAntigd, cNomDep, cJefInm, mIngMen, cUsrInt, dFecInt, 
			iCvePst, iCveOPt, iCveSOP, iSisCot, iNumELa, iPerios, iTipIEx
			FROM bdinteg:"informix".si_ingresos 
			WHERE numcte = pNumCte 
			AND sec_ingreso = (SELECT MAX(sec_ingreso) FROM bdinteg:"informix".si_ingresos WHERE numcte = pNumCte AND tipo_ingreso = pTipoIngres)
			AND tipo_ingreso = pTipoIngres;
		ELSE
			SELECT id_act, id_subact INTO iCveOPt, iCveSOP FROM bdinteg:"informix".si_bitacoraapertura 
			WHERE numcte = pNumCte AND id_pregunta = 6
			AND id_secuencia = (SELECT MAX(id_secuencia) FROM bdinteg:"informix".si_bitacoraapertura WHERE numcte = pNumCte AND id_pregunta = 6);
			
			IF NVL(iCveOPt, 0) = 0 OR NVL(iCveSOP, 0) = 0 THEN
				LET iCveOPt = 0;
				LET iCveSOP = 0;
				LET cCodRet = '00001';
			END IF;
		END IF;
		
	END IF;
	
	RETURN cCodRet, cEmpres, cNumCte, sSecIng, cTipIng, cNomEmp, cPuesto, cPutEsp, dAntigd, cNomDep, cJefInm, mIngMen, cUsrInt, dFecInt, 
	iCvePst, iCveOPt, iCveSOP, iSisCot, iNumELa, iPerios, iTipIEx;
	
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Consulta datos de ingresos del cliente, si no existe informacion consulta en bitacora',
'AUTOR : Adrian Lara I.',
'FECHA : 08 de Julio de 2011',
'VERSION: 20110708.1239',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_monitor_expediente_ctes_pba2(pEmpresa char(3),  pSucursal CHAR(4),pNumcte CHAR(20),pTipoConsulta SMALLINT,pFechaIni DATE,pFechaFin DATE,pTipoRevision INTEGER, pPaginacion SMALLINT )

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
    SET ISOLATION TO COMMITTED READ LAST COMMITTED;
    
	
SET DEBUG FILE TO "/controlcambios/P-BD-20151221-01/bdinteg/spls/sp_monitor_expediente_ctes_modf.out";
TRACE ON;
    	
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
		FOREACH WITH HOLD
		SELECT distinct (cte3.numcte),TRIM(cte3.nombre1)||" "||TRIM(cte3.nombre2)||" "||TRIM(cte3.apell_paterno)||" "||TRIM(cte3.apell_materno), cte3.fecha_insert,cte3.user_insert
			INTO cNumcte,cNombreCte,dtFechaAlta,cEmpAlta
			FROM bdinteg:"informix".si_cliente cte3			
			WHERE cte3.empresa = pEmpresa
			AND cte3.numcte >''
			AND cte3.fecha_insert BETWEEN  dtFechaIni and dtFechaFin
			AND cte3.sucursal  = pSucursal
			AND cte3.tipo_cliente = 1
			

			
			LET cReviso     = '';
			LET cStatusRevision = '';
			LET cObservaciones= '';
			LET iStatus= 0;
						
			
			FOREACH WITH HOLD	
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
				FOREACH WITH HOLD
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
				FOREACH WITH HOLD--cuentas aperturadas
					SELECT 	sol2.num_producto, sol2.num_solicitud
						INTO cProducto, cNumCta
					FROM bdisolic:"informix".ss_solicitudes   sol2	
					inner join bdinteg:"informix".si_cliente cte4 ON (cte4.empresa = pEmpresa and cte4.numcte = sol2.numcte)						
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
				FOREACH WITH HOLD	---cuentas de captacion						
										
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
				FOREACH WITH HOLD	---cuentas de inversion						
										
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
		
		FOREACH WITH HOLD
			SELECT DISTINCT (cte.numcte),TRIM(cte.nombre1)||" "||TRIM(cte.nombre2)||" "||TRIM(cte.apell_paterno)||" "||TRIM(cte.apell_materno), cte.fecha_insert,cte.user_insert
			INTO cNumcte,cNombreCte,dtFechaAlta,cEmpAlta
			FROM bdicheq:sc_maechq Mae			
			INNER JOIN bdicheq:sc_maenoc noc on (noc.cuenta = mae.cuenta and noc.fecha_alta BETWEEN  dtFechaIni and dtFechaFin)
			INNER JOIN bdinteg:"informix".si_cliente cte ON (cte.empresa = pEmpresa and cte.numcte = mae.num_cte and cte.fecha_insert < dtFechaIni)		
			WHERE  Mae.status_cta    = '1'
			AND Mae.empresa = pEmpresa	 			
			AND Mae.num_cte = cte.numcte
			AND mae.sucursal =pSucursal
			AND Mae.producto IN ('1300','1400','1500','1700','1800','1900','2000','1100')
			
			LET cReviso     = '';
			LET cStatusRevision = '';
			LET cObservaciones= '';
			LET iStatus= 0;			
			
			FOREACH WITH HOLD	
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
				FOREACH WITH HOLD
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
				FOREACH WITH HOLD--cuentas aperturadas
					SELECT 	sol2.num_producto, sol2.num_solicitud
						INTO cProducto, cNumCta
					FROM bdisolic:"informix".ss_solicitudes   sol2	
					inner join bdinteg:"informix".si_cliente cte4 ON (cte4.empresa = pEmpresa and cte4.numcte = sol2.numcte)						
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
				FOREACH WITH HOLD	---cuentas de captacion						
										
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
				FOREACH WITH HOLD	---cuentas de inversion						
										
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
		
		FOREACH WITH HOLD
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
		
			
			FOREACH WITH HOLD	
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
				FOREACH WITH HOLD
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
				FOREACH WITH HOLD--cuentas aperturadas
					SELECT 	sol2.num_producto, sol2.num_solicitud
						INTO cProducto, cNumCta
					FROM bdisolic:"informix".ss_solicitudes   sol2	
					inner join bdinteg:"informix".si_cliente cte4 ON (cte4.empresa = pEmpresa and cte4.numcte = sol2.numcte)						
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
				FOREACH WITH HOLD	---cuentas de captacion						
										
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
				FOREACH WITH HOLD	---cuentas de inversion						
										
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
		
		FOREACH WITH HOLD
			SELECT distinct (cte4.numcte),TRIM(cte4.nombre1)||" "||TRIM(cte4.nombre2)||" "||TRIM(cte4.apell_paterno)||" "||TRIM(cte4.apell_materno), cte4.fecha_insert,cte4.user_insert
			INTO cNumcte,cNombreCte,dtFechaAlta,cEmpAlta
			FROM bdisolic:"informix".ss_solicitudes   sol2	
			inner join bdinteg:"informix".si_cliente cte4 ON (cte4.empresa = pEmpresa and cte4.numcte = sol2.numcte and cte4.fecha_insert < dtFechaIni)						
			WHERE sol2.empresa = pEmpresa
			AND sol2.numcte = cte4.numcte
			AND sol2.status_solicitud = 'AP'
			AND sol2.sucursal =pSucursal
			AND sol2.num_solicitud IN (SELECT num_solicitud 
										FROM bdisolic:"informix".ss_autorizacion aut
										WHERE  aut.empresa = pEmpresa AND aut.num_solicitud = sol2.num_solicitud AND aut.status_solicitud ='AP' AND aut.fecha_insert BETWEEN  dtFechaIni and dtFechaFin)
			
			
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
		
			
			FOREACH WITH HOLD	
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
				FOREACH WITH HOLD
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
				FOREACH WITH HOLD--cuentas aperturadas
					SELECT 	sol2.num_producto, sol2.num_solicitud
						INTO cProducto, cNumCta
					FROM bdisolic:"informix".ss_solicitudes   sol2	
					inner join bdinteg:"informix".si_cliente cte4 ON (cte4.empresa = pEmpresa and cte4.numcte = sol2.numcte)						
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
				FOREACH WITH HOLD	---cuentas de captacion						
										
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
				FOREACH WITH HOLD	---cuentas de inversion						
										
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
		FOREACH WITH HOLD
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
		
			
			FOREACH WITH HOLD	
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
				FOREACH WITH HOLD
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
				FOREACH WITH HOLD--cuentas aperturadas
					SELECT 	sol2.num_producto, sol2.num_solicitud
						INTO cProducto, cNumCta
					FROM bdisolic:"informix".ss_solicitudes   sol2	
					inner join bdinteg:"informix".si_cliente cte4 ON (cte4.empresa = pEmpresa and cte4.numcte = sol2.numcte)						
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
				FOREACH WITH HOLD	---cuentas de captacion						
										
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
				FOREACH WITH HOLD	---cuentas de inversion						
										
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
		FOREACH WITH HOLD		
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
				
			FOREACH WITH HOLD	
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
				FOREACH WITH HOLD
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
				FOREACH WITH HOLD--cuentas aperturadas
					SELECT 	sol2.num_producto, sol2.num_solicitud
						INTO cProducto, cNumCta
					FROM bdisolic:"informix".ss_solicitudes   sol2	
					inner join bdinteg:"informix".si_cliente cte4 ON (cte4.empresa = pEmpresa and cte4.numcte = sol2.numcte)						
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
				FOREACH WITH HOLD	---cuentas de captacion						
										
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
				
				FOREACH WITH HOLD	---cuentas de inversion						
										
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

CREATE PROCEDURE "informix".sp_adminbancos(
											pintcvebanco      			CHAR(5),      -- clave de banco
											pvchrnombre       			CHAR(60),     -- nombre banco
											pvchrnombrecorto  			CHAR(20),     -- nombre corto
											pdatfecha         			CHAR(10), 	  -- fecha operacion
											pchroperacion     			CHAR(1),	  -- tipo de operacion (ABC)
											pusuario          			CHAR(9),      -- usuario en sesion
											pspei						CHAR(1),	  -- indicador SPEI
											pcheques					CHAR(1),	  -- indicador CHEQUES
											pnomina						CHAR(1),	  -- indicador NOMINA
											ptefrecibe		  			CHAR(1),	  -- indicador TEF Recibe
											ptefpresentador		  		CHAR(1),	  -- indicador TEF Presenta
											pdomirecibe		  			CHAR(1),	  -- indicador DOMI Recibe
											pdomipresentador		  	CHAR(1)		  -- indicador DOMI Presenta
											)             

	RETURNING  CHAR(5);   -- codigo retorno
    
	DEFINE vCodRet  		CHAR(5);
	DEFINE vCodRet2			CHAR(5);
	DEFINE vSqlErr          INTEGER;
	DEFINE vIsamErr			INTEGER;
	
	DEFINE vintindice		INTEGER;
	DEFINE vintcvebanco		CHAR(5);
	DEFINE vvchrnombre		CHAR(60);		
	DEFINE vvchrnombrecorto	CHAR(20);
	DEFINE vchroperacion	CHAR(1);
	DEFINE vpdatfecha		DATE;
	DEFINE vusuario			CHAR(9);
	DEFINE vintcvesif       CHAR(3);
	DEFINE vexitebanco		CHAR(1);
	DEFINE vreqfechaspei	CHAR(1);
	DEFINE vfechahoy        DATE;
    
    
	LET vCodRet       = "000";
    LET vCodRet2      = "000";
    LET vSqlErr       = 0;
    LET vIsamErr      = 0;
	
	LET vintindice=0;
	LET vintcvebanco=TRIM(pintcvebanco);
	LET vvchrnombre=TRIM(pvchrnombre);
	LET vvchrnombrecorto=TRIM(pvchrnombrecorto);
	LET vchroperacion=TRIM(pchroperacion);
	LET vpdatfecha=date(pdatfecha);
	LET vusuario=TRIM(pusuario);
	LET vintcvesif=SUBSTR(vintcvebanco,3,3);
	LET vexitebanco='0';
	LET vreqfechaspei='0';
	LET vFechaHoy = date(current);
    	
    --SET DEBUG FILE TO "/informix/Jess/sp_adminbancos2.out";
    --TRACE ON;

    BEGIN
	
		
		ON EXCEPTION SET vSqlErr, vIsamErr
			--SET DEBUG FILE TO "/informix/Jess/sp_adminbancos.out";
			--TRACE ON;
			IF vSqlErr != 0 THEN
				LET vCodRet = vSqlErr;
				LET vCodRet2 = vIsamErr;
            RETURN vCodRet; 
			END IF;
		END EXCEPTION;
		
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		
		IF (LENGTH(vchroperacion) != 0) THEN
		
		    -- Valida que tenga fecha operacion si tiene canal spei y que sea valida
			/*IF (pspei = '1') THEN
				IF (LENGTH(pdatfecha) > 0) THEN
					IF (vpdatfecha > vfechahoy) OR (vpdatfecha = vfechahoy)  THEN
						LET vreqfechaspei=0;  -- fecha correcta
					ELSE
						LET vreqfechaspei= 2; -- fecha correcta, solo aplica si es una modificacion
						LET pdatfecha=vfechahoy;
					END IF;
				ELSE
					LET vreqfechaspei=1;
				END IF;
			ELSE
			    LET vreqfechaspei=3;  -- no tiene canal spei
				LET pdatfecha=vfechahoy;
			END IF;
	        */

		    -- Revisa si existe el banco
			IF /*EXISTS(SELECT cvecesif FROM bdispei:tblbanco WHERE cvecesif=vintcvebanco) or*/  
            EXISTS(SELECT cvecesif FROM "informix".si_bancos WHERE cvecesif=vintcvebanco or banco=vintcvesif) THEN
				LET vexitebanco='1';
			ELSE
			    LET vexitebanco='0';
			END IF;
			

		    IF vchroperacion = '1' THEN  -- ALTA
				IF vexitebanco = '1' THEN
					LET vCodRet='002'; -- ya existe la clave banco
				ELSE

						IF (LENGTH(vintcvebanco) != 0) AND (LENGTH(vvchrnombre) != 0) AND (LENGTH(vvchrnombrecorto) != 0)   THEN

							INSERT INTO "informix".si_bancos(banco, descripcion, pais, estado, ciudad, swift, telex, tp_banco, convenio, user_insert, fecha_insert, cvecesif, vchrnombrecorto, flg_domi_r, flg_domi_p, flg_tef_r, flg_tef_p, flg_spei, flg_cheq, flg_nomi, fecha_opera)
							VALUES(vintcvesif, vvchrnombre, '001', '01', '001', 'x', 'x', 'D', 'S', vusuario, current, vintcvebanco, vvchrnombrecorto, pdomirecibe, pdomipresentador, ptefrecibe, ptefpresentador, pspei, pcheques, pnomina, pdatfecha);
						 
								
							IF pspei = '1' THEN  -- Si tiene seleccionado canal SPEI
							
								LET vintindice='-' || vintcvebanco; 
                                IF EXISTS(SELECT cvecesif FROM bdispei:tblbanco WHERE cvecesif=vintcvebanco) THEN
									UPDATE bdispei:tblbanco SET chredobco='A', vchrnombrecorto=vvchrnombrecorto, vchrnombre=vvchrnombre WHERE cvecesif=vintcvebanco;
								ELSE
									INSERT INTO bdispei:tblbanco(cvecesif, vchrnombrecorto, intindice, vchrnombre, chredobco, chrbcoreceptivo, intcvebsi, chrhabilitarprom)
									VALUES(vintcvebanco, vvchrnombrecorto, vintindice, vvchrnombre, 'A', 'R', 0, '1');
								END IF;
							    
						    END IF;
								
							LET vCodRet='000';
							

						ELSE
							-- falta informacion de banco
							LET vCodRet='003';	
							
						END IF;
				END IF;
				
		    ELIF vchroperacion = '2' THEN   -- ACTUALIZA 
			
				IF vexitebanco = '0' THEN
					LET vCodRet='005'; -- No existe la clave banco
				ELSE

						IF (LENGTH(vintcvebanco) != 0) AND (LENGTH(vvchrnombre) != 0) AND (LENGTH(vvchrnombrecorto) != 0) THEN	
						
							 IF pspei='1' THEN   -- Tiene canal SPEI
								UPDATE "informix".si_bancos SET descripcion=vvchrnombre, vchrnombrecorto=vvchrnombrecorto, user_insert=vusuario, flg_domi_r=pdomirecibe, 
								flg_domi_p=pdomipresentador, flg_tef_r=ptefrecibe, flg_tef_p=ptefpresentador, flg_spei=pspei, flg_cheq=pcheques, flg_nomi=pnomina, fecha_opera=pdatfecha
								WHERE cvecesif=vintcvebanco;
							 ELSE
							    UPDATE "informix".si_bancos SET descripcion=vvchrnombre, vchrnombrecorto=vvchrnombrecorto, user_insert=vusuario, flg_domi_r=pdomirecibe, 
								flg_domi_p=pdomipresentador, flg_tef_r=ptefrecibe, flg_tef_p=ptefpresentador, flg_spei=pspei, flg_cheq=pcheques, flg_nomi=pnomina, fecha_opera=vFechaHoy
								WHERE cvecesif=vintcvebanco;
							 END IF;
								
								-- Verifica si el banco ya opera con canal spei.
								IF EXISTS(SELECT cvecesif FROM bdispei:tblbanco WHERE cvecesif=vintcvebanco) THEN
								
									IF pspei = '0' THEN  -- No tiene seleccionado canal SPEI

										UPDATE bdispei:tblbanco SET chredobco='B' WHERE cvecesif=vintcvebanco;
										
									ELSE
									   
									    UPDATE bdispei:tblbanco SET chredobco='A', vchrnombrecorto=vvchrnombrecorto, vchrnombre=vvchrnombre WHERE cvecesif=vintcvebanco;
									
									END IF;
									
									LET vCodRet='000';

						        ELSE
								
									IF pspei = '1' THEN  -- Si tiene canal SPEI
										LET vintindice='-' || vintcvebanco; 
										INSERT INTO bdispei:tblbanco(cvecesif, vchrnombrecorto, intindice, vchrnombre, chredobco, chrbcoreceptivo, intcvebsi, chrhabilitarprom)
										VALUES(vintcvebanco, vvchrnombrecorto, vintindice, vvchrnombre, 'A', 'R', 0, '1');
								   
									END IF;

								    LET vCodRet='000';
									
								END IF;

						ELSE
							-- falta informacion de banco
							LET 	vCodRet='003';	
						END IF;
				END IF;
		    ELSE
				-- tipo de operacion no valida
				LET 	vCodRet='004';
            END IF;
		   
		ELSE
			-- no esta definida la operacion
           LET 	vCodRet='001';	
		END IF;
		
	END;
   RETURN vCodRet;	
END PROCEDURE;
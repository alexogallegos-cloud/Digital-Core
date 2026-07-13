CREATE PROCEDURE "informix".sp_rep_mtto_huella_sif(pFechaCarga DATE)

RETURNING
--Datos a Regresar--
CHAR(5);
--DEFINICION DE VARIABLES--
DEFINE iSql_err 	INTEGER;
DEFINE cCodRet 		CHAR(5);
DEFINE dFechaMtto	DATETIME YEAR TO SECOND;
DEFINE cNumSucur	CHAR(4);
DEFINE cNumCte 		CHAR(9);
DEFINE cNomCte		CHAR(108);
DEFINE cStatus		CHAR(1);
DEFINE cTpoIdent 	CHAR(20);
DEFINE cFolIdent	CHAR(20);
DEFINE cNumProm	 	CHAR(8);
DEFINE cNomProm	 	CHAR(45);
DEFINE cNumGeren 	CHAR(8);
DEFINE cNomGeren	CHAR(45);
DEFINE cNumCajer	CHAR(8);
DEFINE cNomCajer	CHAR(45);
DEFINE cSecuencia 	CHAR(2);
DEFINE iExisteReg	SMALLINT;
DEFINE iCont		SMALLINT;
DEFINE iMaxCommit	INTEGER;

--INICIACION DE VARIABLES--
LET iSql_err 	=	0;
LET cCodRet 	=	'00000';
LET dFechaMtto	=	'';
LET cNumSucur	=	'';
LET cNumCte 	=	'';
LET cNomCte		=	'';
LET cStatus		=	'';
LET cTpoIdent 	=	'';
LET cFolIdent	=	'';
LET cNumProm	=	'';
LET cNomProm	=	'';
LET cNumGeren 	=	'';
LET cNomGeren	=	'';
LET cNumCajer	=	'';
LET cNomCajer	=	'';
LET cSecuencia  = 	'';
LET iExisteReg 	= 	0;
LET iCont 		= 	0;
LET iMaxCommit	= 	5000;

--SET DEBUG FILE TO "/informix/emm/sp_rep_mtto_huella_sif.out";
--TRACE ON;

BEGIN

	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN  cCodRet;
		END IF;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	--Se eliminan los registros de la tabla si_rep_mtto_huella mayores a 365 dias
	DELETE FROM "informix".si_rep_mtto_huella WHERE fecha_alta < TODAY -365;

	--Se cargan los registros de mantenimientos de huellas realizados en el dia especificado como parametro.
	BEGIN WORK;
	FOREACH WITH HOLD
		SELECT fech_ult_camb,numcte,secuencia,sucursal,usuario
		INTO dFechaMtto,cNumCte,cSecuencia,cNumSucur,cNumCajer
		FROM "informix".si_cte_huella cte
		WHERE fecha_alta=pFechaCarga AND secuencia =(SELECT MAX(secuencia)
					FROM  si_cte_huella cte1
					WHERE cte1.numcte= cte.numcte AND cte1.fecha_alta=pFechaCarga AND cte1.secuencia <> 1)
		
		--Se valida que no exista el registro en la tabla si_rep_mtto_huella, en dado de caso que exista el registro, se omite este registro.
		SELECT COUNT(*) INTO iExisteReg
		FROM "informix".si_rep_mtto_huella
		WHERE numcte = cNumCte AND secuencia = cSecuencia;
		
		IF (iExisteReg > 0) THEN
			CONTINUE FOREACH;
		END IF;
		
		IF (cNumCajer IS NULL OR cNumCajer = '') THEN
			CONTINUE FOREACH;
		ELSE
			--Se obtiene el nombre del cajero que realizaron el mantenimiento de datos.
			SELECT nombre
			INTO cNomCajer
			FROM  bdinteg:"informix".si_ejecut
			WHERE ejecutivo=cNumCajer;
		END IF;
		
		--Se consulta el nÃºmero de empleado del gerente desde ta tabla si_huella_linea
		SELECT status_huella, empleado INTO  cStatus, cNumGeren
		FROM bdinteg:"informix".si_huella_linea
		WHERE fecha_alta_huella=pFechaCarga and numcte=cNumCte and secuencia=cSecuencia;

		IF (cNumGeren IS NULL OR cNumGeren='') THEN
			SELECT status_huella, empleado
			INTO  cStatus, cNumGeren
			FROM bdinteg:"informix".si_huella_linea_hist
			WHERE fecha_consulta=pFechaCarga and numcte=cNumCte and secuencia=cSecuencia;
		END IF;
		
		IF (cNumGeren IS NULL OR cNumGeren = '') THEN
			CONTINUE FOREACH;
		END IF;		
		
		--Se obtiene el nombre del gerente que autorizo el mantenimiento de datos.
		SELECT nombre
		INTO cNomGeren
		FROM  bdinteg:"informix".si_ejecut
		WHERE ejecutivo = cNumGeren;
			
		--Se obtiene el nombre del cliente y el numero de su identificacion
		SELECT 
			CASE WHEN cl.nombre2 = '' THEN TRIM(cl.nombre1) || " " || TRIM(cl.apell_paterno) || " " || TRIM(cl.apell_materno) ELSE TRIM(cl.nombre1) || " " || TRIM(cl.nombre2) || " " || TRIM(cl.apell_paterno) || " " || TRIM(cl.apell_materno) END
			, CASE WHEN (pf.codidentifi = 'A') THEN 'A  CRED.IFE'
				WHEN (pf.codidentifi = 'B') THEN 'B  PASAPORTE'
				WHEN (pf.codidentifi = 'C') THEN 'C  CARTILLA MILITAR'
				WHEN (pf.codidentifi = 'D') THEN 'D  CEDULA PROFESIONA'
				WHEN (pf.codidentifi = 'E') THEN 'E  TARJETA UNICA DE'
				WHEN (pf.codidentifi = 'F') THEN 'F  TARJ. DE AFILIACI'
				WHEN (pf.codidentifi = 'G') THEN 'G  CREDENCIAL DEL IM'
				WHEN (pf.codidentifi = 'H') THEN 'H  CARTA IDENTIDAD C'
				WHEN (pf.codidentifi = 'I') THEN 'I  CERTIFICADO DE MA'
				WHEN (pf.codidentifi = 'J') THEN 'J  CREDENCIAL ISSSTE'
				WHEN (pf.codidentifi = 'K') THEN 'K  COMPROBANTE MENOR'
				WHEN (pf.codidentifi = 'L') THEN 'L  CREDENCIAL DE LA'
				WHEN (pf.codidentifi = 'M') THEN 'M  CERTIFICADO DE LA'
				WHEN (pf.codidentifi = 'N') THEN 'N  PRE-CARTILLA S M'
				WHEN (pf.codidentifi = 'O') THEN 'O  ACTA DE NACIMIENT'
				WHEN (pf.codidentifi = 'P') THEN 'P  CARTILLA DE VACUN'
				WHEN (pf.codidentifi = 'Q') THEN 'Q  CREDENCIAL DE RES'
			END AS nueva_ident
			,pf.numidentifi AS num_refer
		INTO cNomCte, cTpoIdent, cFolIdent
		FROM bdinteg:"informix".si_cliente cl
		INNER JOIN bdinteg:"informix".si_ctepf pf on pf.numcte = cl.numcte
		WHERE cl.numcte=cNumCte;

		IF (cFolIdent IS NULL OR cFolIdent = '') THEN
			CONTINUE FOREACH;	
		END IF;
		
		--Se obtiene el numero y nombre del promotor que realizaron el mantenimiento de datos.
		SELECT ex.usuario_alta
		INTO cNumProm
		FROM bdidigital@coppelimg_tcp:dg_expediente ex
		WHERE ex.cliente = cNumCte
			AND ex.cod_docto = '0231'
			AND ex.fecha_alta = pFechaCarga
			AND ex.secuencia = (SELECT MAX(secuencia)
								FROM bdidigital@coppelimg_tcp:"informix".dg_expediente ex2
								WHERE ex2.cliente = cNumCte
									AND ex2.cod_docto = '0231'
									AND ex2.fecha_alta = pFechaCarga);


		IF (cNumProm IS NULL OR cNumProm = '') THEN
			SELECT ex.usuario_alta INTO cNumProm
			FROM bdidigital@coppelimg_tcp:dg_expediente ex
			WHERE ex.cliente = cNumCte 
			AND ex.cod_docto = '0024' 
			AND ex.fecha_alta = pFechaCarga
			AND ex.secuencia = (SELECT MAX(secuencia) FROM bdidigital@coppelimg_tcp:"informix".dg_expediente ex2
				                 WHERE ex2.cliente = cNumCte 
								 AND ex2.cod_docto = '0024' 
								 AND ex2.fecha_alta = pFechaCarga
								 AND lower(ex2.descrip2) like '%mantenimiento%');
				
			if(cNumProm IS NULL OR cNumProm = '') THEN
				SELECT ex.usuario_alta INTO cNumProm
				FROM bdidigital@coppelimg_tcp:dg_expediente ex
				WHERE ex.cliente = cNumCte 
				AND ex.cod_docto = '0024' 
				AND ex.fecha_alta = pFechaCarga
				AND ex.secuencia = (SELECT MAX(secuencia) FROM bdidigital@coppelimg_tcp:"informix".dg_expediente ex2
					                 WHERE ex2.cliente = cNumCte 
									 AND ex2.cod_docto = '0024' 
									 AND ex2.fecha_alta = pFechaCarga
									 AND lower(ex2.descrip2) like '%huella%');			
			end if	
		end if 
		
		if(cNumProm IS NOT NULL OR cNumProm <> '') THEN
			SELECT nombre INTO cNomProm
			FROM si_ejecut WHERE ejecutivo = cNumProm;
		ELSE
			CONTINUE FOREACH;
		END IF;
		
		IF (cNumProm = cNumGeren) THEN
			CONTINUE FOREACH;
		END IF;
		
		--Se inserta el registro en la tabla si_rep_mtto_huella
		INSERT INTO "informix".si_rep_mtto_huella (numcte, secuencia, nombre_cte, status, operador, nombre_promotor, empleado, nombre_gerente, usuario3, nombre_cajero, sucursal, nueva_ident, num_refer, fecha_alta, fecha_hora_alta)
		VALUES (cNumCte, cSecuencia, cNomCte, cStatus, cNumProm, cNomProm, cNumGeren, cNomGeren, cNumCajer, cNomCajer, cNumSucur, cTpoIdent, cFolIdent, pFechaCarga, dFechaMtto);

		LET iCont=iCont+1;

		IF iCont >= iMaxCommit THEN
			LET iCont = 0;
			COMMIT WORK;
			BEGIN WORK;
		END IF;
		
	END FOREACH;

	COMMIT WORK;

	RETURN  cCodRet;
END;
END PROCEDURE
DOCUMENT
'Carga en la tabla si_rep_mtto_huella los mantenimientos de huellas de clientes realizados el dia anterior de operaciones.',
'Autor : Jorge Alberto Garcia Lopez',
'FECHA : 19/10/2021',
'BD: bdinteg',
'Se realizan los ajustes para obtiener correctamente los campos del promotor,gerente y cajero.',
'Autor : Zahide Tellez Ramirez',
'FECHA : 01/12/2022',
'BD: bdinteg',
'El usuario reporta que hay casos donde el folio de la identificacion es vacio y que el ejecutivo, cajero y gerente se duplican, se', 
'realiza el ajuste al sp y se cambia la tabla pivote a si_cte_huella, se omitieron los casos en donde el folio de la identificacion', 
'es vacio o null, anteriormente se duplicaban los ejecutivos si no se encontraban, se quita esta validaciÃ³n. Y se anexa una validacion', 
'si el gerente y promotor son iguales se omite registro, ya que el usuario nos habÃ­a comentado que estos ejecutivos deben ser diferentes',
'Autor : Zahide Tellez Ramirez',
'FECHA : 16/02/2023',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_revision_expediente_cte_reporte(pEmpresa CHAR(3), pSucursal CHAR(4),pUsuario CHAR(10),pFechaIni  DATE, pFechaFin  DATE, pRegistros  INTEGER)
RETURNING 	CHAR(5)  AS Cod_Retorno,
			CHAR(10) AS Empleado_Reviso,
			CHAR(50) AS Nombre_Reviso,
			CHAR(20) AS Numero_Cliente,
			CHAR(107) AS Nombre,
			CHAR(10) AS promotor,
			CHAR(10)  AS Gerente,		
			CHAR (30) AS StatusRevision ,			
			DATE 	  AS Fecha_revision,
			CHAR(250) AS observaciones;		
			

---DECLARACIONES
DEFINE iSqlErr			INTEGER;
DEFINE iIsamErr			INTEGER;
DEFINE iSecuencia       INTEGER;
DEFINE cErrorInfo		CHAR(80);
DEFINE cCodRet			CHAR(5);
DEFINE cMensajeRet		CHAR(80);
DEFINE cNumcte			CHAR(20);
DEFINE cNumcteAux		CHAR(20);
DEFINE cNomCte			CHAR(107);
DEFINE cReviso			CHAR(10);
DEFINE cNomReviso		CHAR(50);
DEFINE cPromotor		CHAR(10);
DEFINE cGerente			CHAR(10);
DEFINE cStatusRevision	CHAR(30);
DEFINE dtFechaRevision	DATE;
DEFINE dtFechaHoy		DATE;
DEFINE dTFecha			DATE;
DEFINE cObservaciones	CHAR(250);
DEFINE iBandera        	INTEGER;

---INICIALIZACIONES
LET iSqlErr				= 0;
LET iIsamErr			= 0;
LET iSecuencia			= 0;
LET cErrorInfo			= '';
LET cCodRet				= '00000';
LET cMensajeRet			= 'Proceso Exitoso';
LET cNumcte				= ' ';
LET cNumcteAux			= ' ';
LET cReviso				= ' ';
LET cNomCte				= '';
LET cNomReviso			= '';
LET cPromotor			= '';
LET cGerente			= '';
LET cStatusRevision		= 'Pendiente de Revisar';
LET dtFechaRevision		= '';
LET dtFechaHoy			= '';
LET dTFecha				= '';
LET cObservaciones		= '';
LET iBandera			= 0;


BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr
       IF iSqlErr != 0 THEN
          LET cCodRet = iSqlErr;
         RETURN cCodRet, NVL(cReviso,""), NVL(cNomReviso,""),NVL(cNumcte,""), NVL(cNomCte,""),NVL(cPromotor,""),NVL(cGerente,""),
			NVL(cStatusRevision,""),NVL(dtFechaRevision,DATE(1)), NVL(cObservaciones,"");
       END IF;
    END EXCEPTION;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
		
	--SET DEBUG FILE TO "/informix/sp_revision_expediente_cte_reportes.out";
	--TRACE ON;
	
	SELECT fecha_hoy INTO dtFechaHoy
	FROM bdicred:"informix".sd_fechas
	WHERE empresa ='001';

	IF nvl(pFechaIni,"") = "" THEN
		LET pFechaIni =  dtFechaHoy;
		LET pFechaFin =  dtFechaHoy;
	END IF;
	FOREACH WITH HOLD
		SELECT distinct (cte3.numcte),TRIM(cte3.nombre1)||" "||TRIM(cte3.nombre2)||" "||TRIM(cte3.apell_paterno)||" "||TRIM(cte3.apell_materno), cte3.user_insert			
			INTO cNumcte, cNomCte, cPromotor
			FROM bdinteg:"informix".si_cliente cte3			
			WHERE cte3.empresa = pEmpresa 			
                        AND cte3.fecha_insert BETWEEN pFechaIni AND pFechaFin
			AND cte3.sucursal  = pSucursal
			AND cte3.tipo_cliente = 1
			AND cte3.numcte <> ''	
			
			LET cReviso     = '';
			LET cStatusRevision		= 'Pendiente de Revisar';
			LET cNomReviso= '';
			LET cGerente= '';
			LET cObservaciones= '';
			LET dtFechaRevision= DATE(1);			
		
			
		IF (pUsuario = '') THEN 
			FOREACH WITH HOLD
				SELECT LIMIT 1 reviso ,substr(nombre_reviso,10,length(nombre_reviso)),gerente,
				DECODE(status_revision,0,"Sin Revisar",1,"Status OK",2,"Pendiente de Corregir"),fecha_revision,observaciones,fecha_insert
				INTO   cReviso, cNomReviso,cGerente, cStatusRevision,dtFechaRevision, cObservaciones, dTFecha
				FROM "informix".si_reporte_expediente 
				WHERE empresa = pEmpresa 
				AND numcte = cNumcte
				AND user_insert = user_insert
				ORDER BY fecha_insert DESC
				
				IF dTFecha < dtFechaHoy THEN
					LET cReviso     = '';
					LET cStatusRevision = '';
				END IF;
				
				EXIT FOREACH;
			END FOREACH;
			
		ELSE
			FOREACH WITH HOLD
				SELECT LIMIT 1 reviso ,substr(nombre_reviso,10,length(nombre_reviso)),gerente,
				DECODE(status_revision,0,"Sin Revisar",1,"Status OK",2,"Pendiente de Corregir"),fecha_revision,observaciones,fecha_insert
				INTO   cReviso, cNomReviso,cGerente, cStatusRevision,dtFechaRevision, cObservaciones, dTFecha
				FROM "informix".si_reporte_expediente 
				WHERE empresa = pEmpresa 
				AND numcte = cNumcte
				AND user_insert = pUsuario
				ORDER BY fecha_insert DESC
				
				IF dTFecha < dtFechaHoy THEN
					LET cReviso     = '';
					LET cStatusRevision = '';
				END IF;
				
				EXIT FOREACH;
			END FOREACH;
		END IF;
				
	
		IF NVL(cReviso,"") = '' and NVL(pUsuario,"")  <> '' THEN --en el caso de que sea consulta por usuario
			CONTINUE FOREACH;
		END IF;
		
		LET iBandera = iBandera+1;

		IF iBandera <= pRegistros THEN				
			CONTINUE FOREACH;
		ELSE				
			RETURN cCodRet, NVL(cReviso,""), NVL(cNomReviso,""),NVL(cNumcte,""), NVL(cNomCte,""),NVL(cPromotor,""),NVL(cGerente,""),
			NVL(cStatusRevision,""),NVL(dtFechaRevision,DATE(1)), NVL(cObservaciones,"") WITH RESUME;
		END IF;					
			
	END FOREACH;			
			
	FOREACH WITH HOLD
			SELECT distinct (cte.numcte),TRIM(cte.nombre1)||" "||TRIM(cte.nombre2)||" "||TRIM(cte.apell_paterno)||" "||TRIM(cte.apell_materno), cte.user_insert
			INTO cNumcte, cNomCte, cPromotor
			FROM bdicheq:sc_maechq Mae			
			INNER JOIN bdicheq:sc_maenoc noc ON mae.cuenta = noc.cuenta 
			inner join bdinteg:"informix".si_cliente cte ON Mae.empresa = cte.empresa and mae.num_cte = cte.numcte 		
			WHERE Mae.empresa = pEmpresa 
			AND mae.sucursal = pSucursal			
			AND Mae.producto IN ('1300','1400','1500','1700','1800','1900','2000','1100')
			AND Mae.num_cte = cte.numcte			
			AND Mae.status_cta = '1'
			AND noc.fecha_alta BETWEEN pFechaIni AND pFechaFin
			AND cte.fecha_insert < pFechaIni
			
			LET cReviso     = '';
			LET cStatusRevision	= 'Pendiente de Revisar';
			LET cNomReviso= '';
			LET cGerente= '';
			LET cObservaciones= '';
			LET dtFechaRevision= DATE(1);			
		
			
			IF (pUsuario = '') THEN
				FOREACH WITH HOLD
					SELECT LIMIT 1 reviso ,substr(nombre_reviso,10,length(nombre_reviso)),gerente,
					DECODE(status_revision,0,"Sin Revisar",1,"Status OK",2,"Pendiente de Corregir"),fecha_revision,observaciones,fecha_insert
					INTO   cReviso, cNomReviso,cGerente, cStatusRevision,dtFechaRevision, cObservaciones,dTFecha
					FROM "informix".si_reporte_expediente 
					WHERE empresa = pEmpresa 
					AND numcte = cNumcte
					AND user_insert = user_insert
					ORDER BY fecha_insert DESC
					IF dTFecha < dtFechaHoy THEN
						LET cReviso     = '';
						LET cStatusRevision = '';
					END IF;
					
					EXIT FOREACH;
				END FOREACH;
			ELSE 
				FOREACH WITH HOLD
					SELECT LIMIT 1 reviso ,substr(nombre_reviso,10,length(nombre_reviso)),gerente,
					DECODE(status_revision,0,"Sin Revisar",1,"Status OK",2,"Pendiente de Corregir"),fecha_revision,observaciones,fecha_insert
					INTO   cReviso, cNomReviso,cGerente, cStatusRevision,dtFechaRevision, cObservaciones,dTFecha
					FROM "informix".si_reporte_expediente 
					WHERE empresa = pEmpresa 
					AND numcte = cNumcte
					AND user_insert = pUsuario
					ORDER BY fecha_insert DESC
					
					IF dTFecha < dtFechaHoy THEN
						LET cReviso     = '';
						LET cStatusRevision = '';
					END IF;
					
					EXIT FOREACH;
				END FOREACH;				
			END IF;
				
	
			IF NVL(cReviso,"") = '' and NVL(pUsuario,"")  <> '' THEN --en el caso de que sea consulta por usuario
				CONTINUE FOREACH;
			END IF;
		
		LET iBandera = iBandera+1;

		IF iBandera <= pRegistros THEN				
			CONTINUE FOREACH;
		ELSE				
			RETURN cCodRet, NVL(cReviso,""), NVL(cNomReviso,""),NVL(cNumcte,""), NVL(cNomCte,""),NVL(cPromotor,""),NVL(cGerente,""),
			NVL(cStatusRevision,""),NVL(dtFechaRevision,DATE(1)), NVL(cObservaciones,"") WITH RESUME;
		END IF;					
			
	END FOREACH;		
			
			
	FOREACH WITH HOLD
		SELECT 	distinct (cte2.numcte),TRIM(cte2.nombre1)||" "||TRIM(cte2.nombre2)||" "||TRIM(cte2.apell_paterno)||" "||TRIM(cte2.apell_materno), cte2.user_insert
		INTO cNumcte, cNomCte, cPromotor
		FROM bdisolic:"informix".ss_solicitudes sol	
		inner join bdinteg:"informix".si_cliente cte2 ON sol.numcte = cte2.numcte AND sol.empresa = cte2.empresa
		WHERE sol.empresa = pEmpresa
		AND sol.numcte =  cte2.numcte		
		AND sol.fecha_insert BETWEEN pFechaIni AND pFechaFin
		AND sol.sucursal = pSucursal
		AND sol.status_solicitud NOT IN ('PC','AN') 
		AND cte2.fecha_insert < pFechaIni
		  
		  
		IF EXISTS(SELECT Mae.num_cte
			FROM bdicheq:sc_maechq Mae			
			INNER JOIN bdicheq:sc_maenoc noc ON mae.cuenta = noc.cuenta		
			WHERE Mae.num_cte = cNumcte
			AND Mae.status_cta = '1'			
			AND Mae.empresa = pEmpresa	 		
			AND mae.sucursal = pSucursal
			AND Mae.producto IN ('1300','1400','1500','1700','1800','1900','2000','1100')
			AND noc.fecha_alta BETWEEN pFechaIni AND pFechaFin) THEN
			CONTINUE FOREACH;
		END IF;
			
		LET cReviso     = '';
		LET cStatusRevision		= 'Pendiente de Revisar';
		LET cNomReviso= '';
		LET cGerente= '';
		LET cObservaciones= '';
		LET dtFechaRevision= DATE(1);
		
		
		IF (pUsuario = '') THEN 
			FOREACH WITH HOLD
				SELECT LIMIT 1 reviso ,substr(nombre_reviso,10,length(nombre_reviso)),gerente,
				DECODE(status_revision,0,"Sin Revisar",1,"Status OK",2,"Pendiente de Corregir"),fecha_revision,observaciones,fecha_insert
				INTO   cReviso, cNomReviso,cGerente, cStatusRevision,dtFechaRevision, cObservaciones,dTFecha
				FROM "informix".si_reporte_expediente 
				WHERE empresa = pEmpresa 
				AND numcte = cNumcte
				AND user_insert = user_insert
				ORDER BY fecha_insert DESC
				IF dTFecha < dtFechaHoy THEN
					LET cReviso     = '';
					LET cStatusRevision = '';
				END IF;
				
				EXIT FOREACH;
			END FOREACH;				
		ELSE 
			FOREACH WITH HOLD
				SELECT LIMIT 1 reviso ,substr(nombre_reviso,10,length(nombre_reviso)),gerente,
				DECODE(status_revision,0,"Sin Revisar",1,"Status OK",2,"Pendiente de Corregir"),fecha_revision,observaciones,fecha_insert
				INTO   cReviso, cNomReviso,cGerente, cStatusRevision,dtFechaRevision, cObservaciones,dTFecha
				FROM "informix".si_reporte_expediente 
				WHERE empresa = pEmpresa 
				AND numcte = cNumcte
				AND user_insert = pUsuario
				ORDER BY fecha_insert DESC
				IF dTFecha < dtFechaHoy THEN
					LET cReviso     = '';
					LET cStatusRevision = '';
				END IF;
				
				EXIT FOREACH;
			END FOREACH;				
		END IF;
				

		IF NVL(cReviso,"") = '' and NVL(pUsuario,"")  <> '' THEN --en el caso de que sea consulta por usuario
			CONTINUE FOREACH;
		END IF;

		LET iBandera = iBandera+1;

		IF iBandera <= pRegistros THEN				
			CONTINUE FOREACH;
		ELSE				
			RETURN cCodRet, NVL(cReviso,""), NVL(cNomReviso,""),NVL(cNumcte,""), NVL(cNomCte,""),NVL(cPromotor,""),NVL(cGerente,""),
			NVL(cStatusRevision,""),NVL(dtFechaRevision,DATE(1)), NVL(cObservaciones,"") WITH RESUME;
		END IF;		

	END FOREACH;	
			
	--Consulta optimizada ARMNEORIS
	FOREACH WITH HOLD	
			SELECT 	distinct (cte4.numcte),
				TRIM(cte4.nombre1)||" "||TRIM(cte4.nombre2)||" "||TRIM(cte4.apell_paterno)||" "||TRIM(cte4.apell_materno), cte4.user_insert
			INTO cNumcte, cNomCte, cPromotor
			FROM bdinteg:"informix".si_cliente cte4 
				inner join bdisolic:"informix".ss_solicitudes sol2 ON cte4.numcte = sol2.numcte and cte4.empresa = sol2.empresa
				inner join bdisolic:"informix".ss_autorizacion aut ON sol2.num_solicitud = aut.num_solicitud  AND sol2.empresa = aut.empresa 
			WHERE 
				cte4.empresa = pEmpresa 
				AND cte4.fecha_insert < pFechaIni
				AND sol2.sucursal = pSucursal
				AND sol2.status_solicitud = 'AP'
				AND aut.fecha_insert BETWEEN pFechaIni AND pFechaFin
                AND aut.status_solicitud ='AP' 
			
			IF EXISTS (SELECT Mae.num_cte
				FROM bdicheq:sc_maechq Mae			
				INNER JOIN bdicheq:sc_maenoc noc ON mae.cuenta = noc.cuenta 			
				WHERE  Mae.empresa = pEmpresa 
				AND Mae.num_cte = cNumcte				
				AND Mae.status_cta = '1'
				AND mae.sucursal = pSucursal
				AND Mae.producto IN ('1300','1400','1500','1700','1800','1900','2000','1100')
				and noc.fecha_alta BETWEEN pFechaIni AND pFechaFin ) THEN
				
				CONTINUE FOREACH;
			END IF;
			
			
			IF EXISTS (SELECT sol.numcte				
				FROM bdisolic:"informix".ss_solicitudes   sol	
				WHERE sol.empresa = pEmpresa
				AND sol.numcte =  cNumcte							
				AND sol.fecha_insert BETWEEN pFechaIni AND pFechaFin
				AND sol.sucursal =pSucursal	
				AND sol.status_solicitud NOT IN ('PC','AN')) THEN
				CONTINUE FOREACH;
			END IF;	
			
			LET cReviso     = '';
			LET cStatusRevision		= 'Pendiente de Revisar';
			LET cNomReviso= '';
			LET cGerente= '';
			LET cObservaciones= '';
			LET dtFechaRevision= DATE(1);			
			
			IF (pUsuario = '') THEN 
				FOREACH WITH HOLD
					SELECT LIMIT 1 reviso ,substr(nombre_reviso,10,length(nombre_reviso)),gerente,
					DECODE(status_revision,0,"Sin Revisar",1,"Status OK",2,"Pendiente de Corregir"),fecha_revision,observaciones,fecha_insert
					INTO   cReviso, cNomReviso,cGerente,cStatusRevision,dtFechaRevision, cObservaciones,dTFecha
					FROM "informix".si_reporte_expediente 
					WHERE empresa = pEmpresa 
					AND numcte = cNumcte
					AND user_insert = user_insert
					ORDER BY fecha_insert DESC
									
					IF dTFecha < dtFechaHoy THEN
						LET cReviso     = '';
						LET cStatusRevision = '';
					END IF;
				
					EXIT FOREACH;
				END FOREACH;
			ELSE
				FOREACH WITH HOLD
					SELECT LIMIT 1 reviso ,substr(nombre_reviso,10,length(nombre_reviso)),gerente,
					DECODE(status_revision,0,"Sin Revisar",1,"Status OK",2,"Pendiente de Corregir"),fecha_revision,observaciones,fecha_insert
					INTO   cReviso, cNomReviso,cGerente,cStatusRevision,dtFechaRevision, cObservaciones,dTFecha
					FROM "informix".si_reporte_expediente 
					WHERE empresa = pEmpresa 
					AND numcte = cNumcte
					AND user_insert = pUsuario
					ORDER BY fecha_insert DESC
									
					IF dTFecha < dtFechaHoy THEN
						LET cReviso     = '';
						LET cStatusRevision = '';
					END IF;
				
					EXIT FOREACH;
				END FOREACH;
			END IF;
				

			IF NVL(cReviso,"") = '' and NVL(pUsuario,"")  <> '' THEN --en el caso de que sea consulta por usuario
				CONTINUE FOREACH;
			END IF;
		
		LET iBandera = iBandera+1;

		IF iBandera <= pRegistros THEN				
			CONTINUE FOREACH;
		ELSE				
			RETURN cCodRet, NVL(cReviso,""), NVL(cNomReviso,""),NVL(cNumcte,""), NVL(cNomCte,""),NVL(cPromotor,""),NVL(cGerente,""),
			NVL(cStatusRevision,""),NVL(dtFechaRevision,DATE(1)), NVL(cObservaciones,"") WITH RESUME;
		END IF;					
			
	END FOREACH;		
			
	FOREACH WITH HOLD		
			SELECT 	distinct (cte5.numcte),TRIM(cte5.nombre1)||" "||TRIM(cte5.nombre2)||" "||TRIM(cte5.apell_paterno)||" "||TRIM(cte5.apell_materno), cte5.user_insert
			INTO cNumcte, cNomCte, cPromotor
			FROM bdinvers:"informix".sv_maeinv invers	
			inner join bdinteg:"informix".si_cliente cte5 ON invers.empresa = cte5.empresa and invers.num_cte = cte5.numcte  					
			WHERE invers.empresa = pEmpresa
			AND invers.secuencia = 1	
			AND invers.sucursal = pSucursal					
			AND invers.fecha_alta BETWEEN pFechaIni AND pFechaFin
			AND cte5.fecha_insert < pFechaIni	
			
			IF EXISTS (SELECT Mae.num_cte
				FROM bdicheq:sc_maechq Mae			
				INNER JOIN bdicheq:sc_maenoc noc ON noc.cuenta = mae.cuenta 			
				WHERE  Mae.status_cta    = '1'
				AND Mae.empresa = pEmpresa	 			
				AND Mae.num_cte = cNumcte
				AND mae.sucursal = pSucursal
				AND Mae.producto IN ('1300','1400','1500','1700','1800','1900','2000','1100')
				and noc.fecha_alta BETWEEN pFechaIni AND pFechaFin ) THEN
				CONTINUE FOREACH;
			END IF;
			IF EXISTS (SELECT sol.numcte				
				FROM bdisolic:"informix".ss_solicitudes sol	
				WHERE sol.numcte = cNumcte
				AND sol.empresa = pEmpresa
				AND sol.fecha_insert BETWEEN pFechaIni AND pFechaFin	
				AND sol.sucursal = pSucursal
				AND sol.status_solicitud NOT IN ('PC','AN')) THEN
				CONTINUE FOREACH;
			END IF;	
			
			
			IF EXISTS (	SELECT 	sol2.numcte
			FROM bdisolic:"informix".ss_solicitudes   sol2	
			WHERE sol2.numcte = cNumcte
			AND sol2.empresa = pEmpresa 			
			AND sol2.num_solicitud IN (SELECT num_solicitud 
										FROM bdisolic:"informix".ss_autorizacion aut
										WHERE  aut.empresa = pEmpresa 
										AND aut.num_solicitud = sol2.num_solicitud
										AND aut.status_solicitud ='AP' 
										AND aut.fecha_insert BETWEEN pFechaIni AND pFechaFin)
			AND sol2.sucursal = pSucursal	
            AND sol2.status_solicitud = 'AP'									
			) THEN		
				CONTINUE FOREACH;
			END IF;
			
			
			LET cReviso     = '';
			LET cStatusRevision		= 'Pendiente de Revisar';
			LET cNomReviso= '';
			LET cGerente= '';
			LET cObservaciones= '';
			LET dtFechaRevision= DATE(1);			
			
			
			IF (pUsuario = '') THEN 
				FOREACH WITH HOLD
					SELECT LIMIT 1 reviso ,substr(nombre_reviso,10,length(nombre_reviso)),gerente,
					DECODE(status_revision,0,"Sin Revisar",1,"Status OK",2,"Pendiente de Corregir"),fecha_revision,observaciones,fecha_insert
					INTO   cReviso, cNomReviso,cGerente, cStatusRevision,dtFechaRevision, cObservaciones,dTFecha
					FROM "informix".si_reporte_expediente 
					WHERE empresa = pEmpresa 
					AND numcte = cNumcte
					AND user_insert = user_insert
					ORDER BY fecha_insert DESC
					
					IF dTFecha < dtFechaHoy THEN
						LET cReviso     = '';
						LET cStatusRevision = '';
					END IF;
					
					EXIT FOREACH;
				END FOREACH;					
			ELSE
				FOREACH WITH HOLD
					SELECT LIMIT 1 reviso ,substr(nombre_reviso,10,length(nombre_reviso)),gerente,
					DECODE(status_revision,0,"Sin Revisar",1,"Status OK",2,"Pendiente de Corregir"),fecha_revision,observaciones,fecha_insert
					INTO   cReviso, cNomReviso,cGerente, cStatusRevision,dtFechaRevision, cObservaciones,dTFecha
					FROM "informix".si_reporte_expediente 
					WHERE empresa = pEmpresa 
					AND numcte = cNumcte
					AND user_insert = pUsuario
					ORDER BY fecha_insert DESC
					
					IF dTFecha < dtFechaHoy THEN
						LET cReviso     = '';
						LET cStatusRevision = '';
					END IF;
					
					EXIT FOREACH;
				END FOREACH;					
			END IF;
				
	
			IF NVL(cReviso,"") = '' and NVL(pUsuario,"")  <> '' THEN --en el caso de que sea consulta por usuario
				CONTINUE FOREACH;
			END IF;
		
		LET iBandera = iBandera+1;

		IF iBandera <= pRegistros THEN				
			CONTINUE FOREACH;
		ELSE				
			RETURN cCodRet, NVL(cReviso,""), NVL(cNomReviso,""),NVL(cNumcte,""), NVL(cNomCte,""),NVL(cPromotor,""),NVL(cGerente,""),
			NVL(cStatusRevision,""),NVL(dtFechaRevision,DATE(1)), NVL(cObservaciones,"") WITH RESUME;
		END IF;					
			
	END FOREACH;				
	
		
	IF iBandera = 0 THEN
		LET cCodRet				= '00001';		
		RETURN cCodRet, NVL(cReviso,""), NVL(cNomReviso,""),NVL(cNumcte,""), NVL(cNomCte,""),NVL(cPromotor,""),NVL(cGerente,""),
			NVL(cStatusRevision,""),NVL(dtFechaRevision,DATE(1)), NVL(cObservaciones,"");			
	END IF;	
	
	
END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Procedimiento para consultar clientes para realizar la validaciones de expediente', 
'AUTOR: Jesus Manuel Aguilar Heredia',
'FECHA: 06 mayo 2014',
'VERSION: 201405061209',
'BD: bdinteg',
'Modificado: 28 de Junio 2022',
'Modifico: Alejandro Rodriguez Martinez (ARMNEORIS)';

CREATE PROCEDURE "informix".sp_valida_correo_bpi_pbajj(pNumCte CHAR(9), pCorreo CHAR(100), pCorreoAlterno CHAR(100))
RETURNING CHAR(5) as Cod_Ret;

DEFINE sCodRet		CHAR(5);
DEFINE iSqlErr		INTEGER;
DEFINE vExisteCorreo     INTEGER;
DEFINE vExisteCorreoAlt     INTEGER;



LEt sCodRet     =   '00000';
LET vExisteCorreo =   0;
LET vExisteCorreoAlt =   0;
LET iSqlErr		=   0;



BEGIN
    ON EXCEPTION SET iSqlErr
        IF iSqlErr != 0 THEN
            LET sCodRet = iSqlErr::CHAR(8);
            RETURN sCodRet;
        END IF;
    END EXCEPTION; 	
 


	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	SELECT {+INDEX(bdinteg:"informix".si_correos idx_corr_ctestatcorr )} COUNT(numcte) INTO vExisteCorreo FROM bdinteg:"informix".si_correos 
	WHERE numcte!=pNumCte  AND status_correo='A' AND  correo_elec = pCorreo; 
    IF LENGTH(TRIM(pCorreoAlterno))> 0 THEN
        SELECT {+INDEX(bdibpi:"informix".bpi_usuario idx_usuario3 )}COUNT(numcliente) INTO vExisteCorreoAlt FROM bdibpi:bpi_usuario
        WHERE e_mail = pCorreoAlterno AND  numcliente !=pNumCte AND st_portal = 'activo';

      
    END IF;  
 
    IF (vExisteCorreo >0 AND vExisteCorreoAlt >0 ) THEN
		LET sCodRet='00003';
	
	ELIF vExisteCorreo >0 THEN
		LET sCodRet='00001';
	ELIF vExisteCorreoAlt >0 THEN
		LET sCodRet='00002';
	END IF;
	
    
	

RETURN sCodRet;

END
END PROCEDURE;
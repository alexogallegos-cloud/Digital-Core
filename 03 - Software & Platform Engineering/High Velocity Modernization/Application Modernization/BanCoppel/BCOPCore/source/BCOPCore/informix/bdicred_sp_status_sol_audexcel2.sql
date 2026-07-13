CREATE PROCEDURE "informix".sp_status_sol_audexcel2(pempresa CHAR(3),psucursal CHAR(4),pfechaini CHAR(10),pfechafin CHAR(10),pstatus CHAR(2),pRegistros INTEGER,pRecuperacion INTEGER)
RETURNING CHAR(5),       -- Codigo de Retorno
		  CHAR(80),      -- Mensaje de Retorno
          CHAR(20),      -- Nro de Solicitud
		  CHAR(20),      -- Nro de Cliente
		  DATE,          -- Fecha Alta
          CHAR(104),     -- Nombre del Cliente
          CHAR(2),       -- Status Solicitud
          MONEY(14,2),   -- Monto Solicitud
		  MONEY(14,2),   -- Monto otorgado
          DATE,          -- Fecha Cambio Status
		  CHAR(45),      -- Nombre del promotor que realizo la alta de solicitud
		  CHAR(45),      -- Nombre del promotor que autorizo la entrega de solicitud
		  CHAR(45),      -- Nombre del promotor que entrega la tarjeta
		  CHAR(45),      -- Nombre del promotor que asigno la tarjeta	  
          CHAR(13),      -- Telefono Particular
		  CHAR(13),      -- Telefono Celular
		  CHAR(13),      -- Telefono Oficina
		  CHAR (4),		 -- Sucursal 
		  CHAR(104),     -- Nombre de la primer referencia
		  CHAR(13),      -- Telefono Particular
		  CHAR(13),      -- Telefono Celular
		  CHAR(13),      -- Telefono Oficina
		  CHAR(104),     -- Nombre de la segunda referencia
		  CHAR(13),      -- Telefono Particular
		  CHAR(13),      -- Telefono Celular
		  CHAR(13);      -- Telefono Oficina

		  
--*************************************************************************
--                         DEFINICION DE VARIABLES
--*************************************************************************
DEFINE cCod_ret CHAR(5);
DEFINE cMen_ret CHAR(80);
DEFINE iSqlerr INTEGER;
DEFINE iIsamErr INTEGER;
DEFINE cNumSol CHAR(20);
DEFINE cNumcte CHAR(20);
DEFINE cStatus CHAR(2);
DEFINE mMonto MONEY(14,2);
DEFINE mMonto_aut     MONEY(14,2);
DEFINE cNomCte     CHAR(104);
DEFINE cNombre1       CHAR(26);
DEFINE cNombre2       CHAR(26);
DEFINE cApell_paterno CHAR(26);
DEFINE cApell_materno CHAR(26);
DEFINE dtFechaSol     DATE;
DEFINE dtFechaCam DATE;
DEFINE cUsuarioAlta CHAR(10);
DEFINE cNombrePromAlta CHAR(45);
DEFINE cNombrePromAutoriza CHAR(45);
DEFINE cNombrePromEntrega CHAR(45);
DEFINE cNombrePromActiva CHAR(45);
DEFINE cTelCasa CHAR(13);
DEFINE cTelCel CHAR(13);
DEFINE cTelOfi CHAR(13);
DEFINE cTel CHAR(13);
DEFINE cSucursal CHAR(4);
DEFINE sTipoTel SMALLINT;
DEFINE icontador INTEGER;
DEFINE iDiasConsulta INTEGER;
DEFINE iDiasConsultaExcel INTEGER;
DEFINE iConStatus INTEGER;
DEFINE cNomRef1 CHAR(104);
DEFINE cNomRef2 CHAR(104);
DEFINE cTelefonotrabajoRef1 CHAR(13);
DEFINE cTelefonocelularRef1 CHAR(13);
DEFINE cTelefonooficinaRef1 CHAR(13);
DEFINE cTelefonotrabajoRef2 CHAR(13);
DEFINE cTelefonocelularRef2 CHAR(13);
DEFINE cTelefonooficinaRef2 CHAR(13);
DEFINE iSecuencia INTEGER;
DEFINE iSegundaref INTEGER;
DEFINE icontador2 INTEGER;
DEFINE cEstadocivil CHAR(1);

--referencias
DEFINE cNombre 		 CHAR(104);
DEFINE cParentesco   CHAR(2);
DEFINE cTelRef 		CHAR(13);
DEFINE cNumcteRef   CHAR(20);
DEFINE cNombreCong 		CHAR(104);
DEFINE cNombreR1 		CHAR(104);
DEFINE cTelR1 	     	CHAR(13);
DEFINE cNombreR2 		CHAR(104);
DEFINE cTelR2 		    CHAR(13);
-- *************************************************************************
-- *                        ASIGNACION DE VARIABLES
-- **************************************************************************
LET cCod_ret     = "000";
LET cMen_ret     = "Proceso Exitoso";
LET iSqlerr      = 0;
LET iIsamErr      = 0;
LET cNumcte     = "";
LET cNumSol        = "";
LET cStatus        = "";
LET mMonto         = 0;
LET mMonto_aut     = 0;
LET cNomCte     = "";
LET cNombre1       = "";
LET cNombre2       = "";
LET cApell_paterno = "";
LET cApell_materno = "";
LET dtFechaSol     = "";
LET dtFechaCam = "";
LET cUsuarioAlta = "";
LET cNombrePromAlta = "";
LET cNombrePromAutoriza = "";
LET cNombrePromEntrega = "";
LET cNombrePromActiva = "";
LET cTelCasa = "";
LET cTelCel = "";
LET cTelOfi = "";
LET cTel = "";
LET sTipoTel = "";
LET cSucursal = "";
LET icontador = 0;
LET iDiasConsulta = 0;
LET iDiasConsultaExcel = 0;
LET iConStatus = 0;

LET  cNomRef1 = "";
LET  cNomRef2 = "";
LET  cTelefonotrabajoRef1 = "";
LET  cTelefonocelularRef1 = "";
LET  cTelefonooficinaRef1 = "";
LET  cTelefonotrabajoRef2 = "";
LET  cTelefonocelularRef2 = "";
LET  cTelefonooficinaRef2 = "";
LET  iSecuencia = 0;
LET  iSegundaref = 0;
LET  icontador2 = 0;
LET  cEstadocivil = "";

LET cNombre 		= "";
LET cParentesco     = "";
LET cTelRef 		= "";
LET cNumcteRef      = "";
LET cNombreCong 	= "";
LET cNombreR1 		= "";
LET cTelR1 	     	= "";
LET cNombreR2 		= "";
LET cTelR2 		    = "";
-- **********************************************************************
-- *                        CONTROL DE ERRORES
-- ***********************************************************************
BEGIN
ON EXCEPTION SET iSqlerr,iIsamErr,cMen_ret
   IF iSqlerr != 0 THEN
      LET cCod_ret=iSqlerr;
     RETURN cCod_ret,cMen_ret, NVL(cNumSol,""), NVL(cNumcte,""), NVL(dtFechaSol,DATE(1)), NVL(cNomCte,""),
		NVL(cStatus,""), NVL(mMonto,0), NVL(mMonto_aut,0), NVL(dtFechaCam,DATE(1)),NVL(cNombrePromAlta,""),NVL(cNombrePromAutoriza,""),NVL(cNombrePromEntrega,""),NVL(cNombrePromActiva,""),NVL(cTelCasa,""),NVL(cTelCel,""),NVL(cTelOfi,""),NVL(cSucursal,""),'','','','','','','','';	
   END IF;
END EXCEPTION;



--SET DEBUG FILE TO "/tmp/mfinis/sp_status_sol_audexcel2.out";
--TRACE ON;
-- **********************************************************************
-- *                        PROGRAMA PRINCIPAL
-- **********************************************************************

    IF NVL(pSucursal, '') = '' THEN
        LET  cCod_ret = '00001';
		LET cMen_ret = 'LA SUCURSAL ES UN DATO REQUERIDO PARA LA EXPORTACION A EXCEL';
		RETURN cCod_ret,cMen_ret, NVL(cNumSol,""), NVL(cNumcte,""), NVL(dtFechaSol,DATE(1)), NVL(cNomCte,""),
		NVL(cStatus,""), NVL(mMonto,0), NVL(mMonto_aut,0), NVL(dtFechaCam,DATE(1)),NVL(cNombrePromAlta,""),NVL(cNombrePromAutoriza,""),NVL(cNombrePromEntrega,""),NVL(cNombrePromActiva,""),NVL(cTelCasa,""),NVL(cTelCel,""),NVL(cTelOfi,""),NVL(cSucursal,""),'','','','','','','','';	
	END IF;
    IF NVL(pStatus, '') = '' THEN
        LET  cCod_ret = '00002';
		LET cMen_ret = 'EL ESTATUS ES UN DATO REQUERIDO PARA LA EXPORTACION A EXCEL';		
		RETURN cCod_ret,cMen_ret, NVL(cNumSol,""), NVL(cNumcte,""), NVL(dtFechaSol,DATE(1)), NVL(cNomCte,""),
		NVL(cStatus,""), NVL(mMonto,0), NVL(mMonto_aut,0), NVL(dtFechaCam,DATE(1)),NVL(cNombrePromAlta,""),NVL(cNombrePromAutoriza,""),NVL(cNombrePromEntrega,""),NVL(cNombrePromActiva,""),NVL(cTelCasa,""),NVL(cTelCel,""),NVL(cTelOfi,""),NVL(cSucursal,""),'','','','','','','','';	
    END IF;


	
	SELECT  COUNT(valor_alfabetico)
	INTO iConStatus
	FROM "informix".sd_param_campania
	WHERE empresa = pempresa
	AND tipo_campania = 65
	AND grupo_parametro ='EXCELAUDI'
	AND TRIM(valor_alfabetico) = pStatus;

	IF iConStatus = 0 THEN
		LET  cCod_ret = '00003';
		LET cMen_ret = 'EL ESTATUS NO ES VALIDO PARA LA EXPORTACION A EXCEL';		
		RETURN cCod_ret,cMen_ret, NVL(cNumSol,""), NVL(cNumcte,""), NVL(dtFechaSol,DATE(1)), NVL(cNomCte,""),
		NVL(cStatus,""), NVL(mMonto,0), NVL(mMonto_aut,0), NVL(dtFechaCam,DATE(1)),NVL(cNombrePromAlta,""),NVL(cNombrePromAutoriza,""),NVL(cNombrePromEntrega,""),NVL(cNombrePromActiva,""),NVL(cTelCasa,""),NVL(cTelCel,""),NVL(cTelOfi,""),NVL(cSucursal,""),'','','','','','','','';	
	END IF;
	--validacion de los dias de consulta
	
	SELECT  valor
	INTO iDiasConsultaExcel
	FROM "informix".sd_param
	WHERE empresa = pempresa
	AND cod_param = '084';
	
	 LET  iDiasConsulta = pFechafin::DATE - pFechaini::DATE ;
	 
	 IF iDiasConsulta > iDiasConsultaExcel THEN
		LET  cCod_ret = '00004';
		LET cMen_ret = 'EL RANGO DE FECHAS NO ES VALIDO PARA LA EXPORTACION A EXCEL';		
		RETURN cCod_ret,cMen_ret, NVL(cNumSol,""), NVL(cNumcte,""), NVL(dtFechaSol,DATE(1)), NVL(cNomCte,""),
		NVL(cStatus,""), NVL(mMonto,0), NVL(mMonto_aut,0), NVL(dtFechaCam,DATE(1)),NVL(cNombrePromAlta,""),NVL(cNombrePromAutoriza,""),NVL(cNombrePromEntrega,""),NVL(cNombrePromActiva,""),NVL(cTelCasa,""),NVL(cTelCel,""),NVL(cTelOfi,""),NVL(cSucursal,""),'','','','','','','','';		 
	 END IF;
	

	FOREACH WITH HOLD

		SELECT SKIP pRegistros FIRST pRecuperacion a.num_solicitud, a.numcte, a.status_solicitud,nvl(a.monto_solicitado,0),
		nvl(a.monto_autorizado,0),nvl(a.fecha_insert,date(1)), a.sucursal,a.user_insert
		INTO cNumSol,cNumcte,cStatus,mMonto,mMonto_aut,dtFechaSol ,cSucursal,cUsuarioAlta
		FROM bdisolic:"informix".ss_solicitudes  a
		INNER JOIN bdisolic:"informix".ss_anexosol b ON (b.empresa = a.empresa AND b.num_solicitud = a.num_solicitud) 
		WHERE a.empresa = pEmpresa 
		AND a.num_solicitud >=''		
		AND a.fecha_insert BETWEEN pFechaini::DATE AND  pFechafin::DATE
		AND a.status_solicitud = pStatus
		AND  a.sucursal =pSucursal
	
		SELECT pf.estado_civil,TRIM(cte.nombre1) || ' ' || TRIM(cte.nombre2) || ' ' || TRIM(cte.apell_paterno) || ' ' || TRIM(cte.apell_materno)
		INTO cEstadocivil,cNomCte
		FROM bdinteg:"informix".si_cliente cte
		INNER JOIN bdinteg:"informix".si_ctepf pf ON (pf.Empresa = cte.empresa and pf.numcte= cte.numcte)
		WHERE cte.empresa = pEmpresa 
		AND cte.numcte = cNumcte;
  

	--Obtencion de telefonos
		
		FOREACH 
			SELECT telefono,tipo_tel
				INTO cTel,sTipoTel
			FROM bdinteg:"informix".si_telefonos_actual a	 
			WHERE a.empresa = '001' 
			AND a.numcte = cNumcte 
			AND a.tipo_tel IN (1,2,3)		
			AND a.status_tel = 'A'
			
			IF sTipoTel = 1 THEN
				LET cTelCasa =cTel;				
			ELIF sTipoTel = 2 THEN
				LET cTelCel = cTel;				
			ELIF sTipoTel = 3 THEN
				LET cTelOfi = cTel;
			END IF;	
		END FOREACH;
      -----------------------------MONTO AUTORIZADO--------------------------------
         
		IF cStatus='AP' THEN
		
			SELECT LIMIT 1 NVL(eje.nombre,"")--Usuario que dio de alta la solicitud
			INTO cNombrePromAlta
			FROM  bdinteg:"informix".si_ejecut eje 
			WHERE eje.empresa = pEmpresa
			AND eje.ejecutivo = cUsuarioAlta;
			
			SELECT LIMIT 1 NVL(eje.nombre,""),aut.fecha_insert--Usuario que aperturo el crÃ?Â©dito.
			INTO cNombrePromAutoriza,dtFechaCam
			FROM bdisolic:"informix".ss_autorizacion aut
			INNER JOIN bdinteg:"informix".si_ejecut eje ON eje.empresa = pEmpresa AND eje.ejecutivo = aut.ejecutivo_auto
			WHERE aut.empresa=pEmpresa 
			AND aut.num_solicitud=cNumSol
			AND aut.status_solicitud = "AP";
			
			IF SUBSTR(cNumSol,1,2)= "60" THEN
				SELECT monto_otorgado
				INTO mMonto_aut
				FROM bdicred:"informix".sd_maesdos
				WHERE empresa=pEmpresa and num_credito=cNumSol;
				
				SELECT LIMIT 1 NVL(eje.nombre,""),NVL(eje2.nombre,"")--Usuario que aperturo el crÃ?Â©dito.
				INTO cNombrePromEntrega,cNombrePromActiva
				FROM "informix".sd_tarjeta tar
				INNER JOIN "informix".bitacora_activacion act ON (act.numtarjeta =tar.num_tarjeta)
				LEFT JOIN bdinteg:"informix".si_ejecut eje ON (eje.empresa = '001' AND eje.ejecutivo = act.no_empleado_asigna)
				LEFT JOIN bdinteg:"informix".si_ejecut eje2 ON (eje2.empresa = '001' AND eje2.ejecutivo = act.no_empleado_activa)
				WHERE tar.empresa=pEmpresa 
				AND tar.num_credito=cNumSol
				AND tar.secuencia ='1';
			
			END IF;
			IF SUBSTR(cNumSol,1,2)= "65" THEN
				SELECT LIMIT 1 NVL(eje.nombre,"")
				INTO cNombrePromEntrega
				FROM bdinteg:"informix".si_adiccoppel cop
				LEFT JOIN bdinteg:"informix".si_ejecut eje ON (eje.empresa = '001' AND eje.ejecutivo = cop.user_insert)
				WHERE numcte =cNumcte
				AND secuencia = 1
			    AND tipotar ='1';				
			END IF;
			
		END IF;

		
		
		
		
	FOREACH
	
		SELECT NVL(nombre_ref, "" ) , parentesco, NVL(telefono_ref, "") ,numcte_ref
			INTO cNombre,cParentesco, cTelRef,cNumcteRef
		FROM bdisolic:"informix".ss_refpersonales 
		WHERE num_solicitud  = cNumSol				
		
		 IF cParentesco = "E" THEN
			SELECT TRIM(nombre1)||' '||TRIM(nombre2)||' '||TRIM(apell_paterno)||' '||TRIM(apell_materno)
				INTO cNomRef1
			FROM bdinteg:"informix".si_cliente
			WHERE empresa = '001'
			AND numcte = cNumcteRef;
			--Obtencion de telefonos de las referencias
			
		    --Si el nombre lo trae vacio es en los casos en que el cliente se fusiono y es necesario obtener la informacion de las tablas de fusion de clientes
			
			IF NVL(cNomRef1,'') = '' THEN
				SELECT TRIM(nombre1)||' '||TRIM(nombre2)||' '||TRIM(apell_paterno)||' '||TRIM(apell_materno)
					INTO cNomRef1
				FROM bdinteg:"informix".si_fuscliente
				WHERE empresa = '001'
				AND numcte = cNumcteRef;
				--se cambia el numero de cliente por el cual se fusiono
				FOREACH 
					SELECT telefono,tipo_tel
						INTO cTel,sTipoTel						
					FROM bdinteg:"informix".si_fustelefonos
					WHERE empresa = '001'
					AND numcte = cNumcteRef
					AND tipo_tel IN (1,2,3)		
					AND status_tel = 'A'
					
					
					IF sTipoTel = 1 THEN
						LET cTelefonotrabajoRef1 =cTel;				
					ELIF sTipoTel = 2 THEN
						LET cTelefonocelularRef1 = cTel;				
					ELIF sTipoTel = 3 THEN
						LET cTelefonooficinaRef1 = cTel;
					END IF;	
					
				END FOREACH
			ELSE

				FOREACH 
					SELECT telefono,tipo_tel
						INTO cTel,sTipoTel
					FROM bdinteg:"informix".si_telefonos_actual a	 
					WHERE a.empresa = '001' 
					AND a.numcte = cNumcteRef 
					AND a.tipo_tel IN (1,2,3)		
					AND a.status_tel = 'A'
					
					IF sTipoTel = 1 THEN
						LET cTelefonotrabajoRef1 =cTel;				
					ELIF sTipoTel = 2 THEN
						LET cTelefonocelularRef1 = cTel;				
					ELIF sTipoTel = 3 THEN
						LET cTelefonooficinaRef1 = cTel;
					END IF;				
			END FOREACH;
			END IF
			
			
		 END IF;
		 IF cNumcteRef = "R1" AND  cParentesco <> "E" THEN
			LET cNomRef1 = cNombre;			
			LET cTelefonotrabajoRef1= cTelRef;
		 ELIF cNumcteRef <> "R1" AND  cParentesco <> "E" THEN
			LET cNomRef2 = cNombre;
			LET cTelefonotrabajoRef2= cTelRef;
		 END IF

	END FOREACH;     		
	
		RETURN cCod_ret, cMen_ret,NVL(cNumSol,""), NVL(cNumcte,""), NVL(dtFechaSol,DATE(1)), NVL(cNomCte,""),
         NVL(cStatus,""), NVL(mMonto,0), NVL(mMonto_aut,0), NVL(dtFechaCam,DATE(1)),NVL(cNombrePromAlta,""),NVL(cNombrePromAutoriza,""),NVL(cNombrePromEntrega,""),NVL(cNombrePromActiva,""),NVL(cTelCasa,""),NVL(cTelCel,""),NVL(cTelOfi,""),NVL(cSucursal,""),NVL(cNomRef1,""),NVL(cTelefonotrabajoRef1,""),NVL(cTelefonocelularRef1,""),NVL(cTelefonooficinaRef1,""),NVL(cNomRef2,""),NVL(cTelefonotrabajoRef2,""),NVL(cTelefonocelularRef2,""),NVL(cTelefonooficinaRef2,"") WITH RESUME;	
        
		
		
		LET cTelCasa = "";
		LET cTelCel = "";
		LET cTelOfi = "";
		LET mMonto_aut=0;		
		LET  cNomRef1 = "";
		LET  cNomRef2 = "";
		LET  cTelefonotrabajoRef1 = "";
		LET  cTelefonocelularRef1 = "";
		LET  cTelefonooficinaRef1 = "";
		LET  cTelefonotrabajoRef2 = "";
		LET  cTelefonocelularRef2 = "";
		LET  cTelefonooficinaRef2 = "";
		LET cNombrePromAlta = "";
		LET cNombrePromAutoriza = "";
		LET cNombrePromEntrega = "";
		LET cNombrePromActiva = "";
		LET  iSecuencia = 0;
		LET  iSegundaref = 0;
		LET icontador = 1;		
		
		
		END FOREACH;
		
    	IF icontador =0 THEN
		 LET  cCod_ret = '00005';
		 LET cMen_ret = 'NO EXISTE INFORMACION';
		 RETURN cCod_ret,cMen_ret, NVL(cNumSol,""), NVL(cNumcte,""), NVL(dtFechaSol,DATE(1)), NVL(cNomCte,""),
         NVL(cStatus,""), NVL(mMonto,0), NVL(mMonto_aut,0), NVL(dtFechaCam,DATE(1)),NVL(cNombrePromAlta,""),NVL(cNombrePromAutoriza,""),NVL(cNombrePromEntrega,""),NVL(cNombrePromActiva,""),NVL(cTelCasa,""),NVL(cTelCel,""),NVL(cTelOfi,""),NVL(cSucursal,"") ,'','','','','','','','';

		END IF;
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se realiza procedimiento para ObtenciÃ?Â³n de datos para el reporte de solicitudes para el area de auditoria.',
'AUTOR: JesÃ?Âºs Manuel Aguilar Heredia',
'BD: bdicred ',
'FECHA: FEBERO 2014',
'VERSION: 20140217.1735',
'AUTOR: L. Montserrat León Amador',
'FECHA: 04/08/2017',
'DESCRIPCION: Se realiza spl clon para agregar los parámetros de paginado.';

CREATE PROCEDURE "informix".status_sol2(
                pempresa     CHAR(3),
                psucursal    CHAR(4),
                pfechafin    DATE,
                pfechaini    DATE,
                pstatus      CHAR(2),
				pRegistros INTEGER,
				pRecuperacion INTEGER)

RETURNING CHAR(5),       -- Codigo de Retorno
          CHAR(20),      -- Nro de Solicitud
          CHAR(4),       -- Sucursal
          CHAR(40),      -- Nombre Sucursal
          CHAR(104),     -- Nombre del Cliente
          CHAR(2),       -- Status Solicitud
          MONEY(14,2),   -- Monto Solicitud
		  MONEY(14,2),   -- Monto otorgado
          DATE,          -- Fecha Alta
          DATE,          -- Fecha Cambio Status
          DECIMAL(10,4), -- Eficiencia de Pago
          SMALLINT,      -- Meses de Historia
          SMALLINT,      -- Scoring 1
          SMALLINT,      -- Scoring 2
          SMALLINT,      -- Total Scoring
          CHAR(10);      -- Causa de Rechazo

--Juan Andrès Coronel M
--21/12/2007
--Se modifica para que devuelva la causa de rechazo de la solicitud.
--Se unifica el còdigo para hacer un solo select de los 4 que existian en la versiòn previa.
--Se agrega validaciòn para que si los parametros de psucursal y pstatus vienen vacìo o null, el sp pueda devolver datos con ambos valores.


--Roque Enrique Solis Campaña
--28/10/2008
--se agrego el campo monto otorgado para incluirse en el reporte RStatusSol.rpt
--se realizo la consulta para obtener el campo monto otorgado

--Julio Cesar Polanco Inzunza
--04/03/2009
--Se modifica para contemplar los cambios en la tabla ss_scoring_solic
-- para que solo contemple los registros antes de caja unica campo activa = 0

--*************************************************************************
--                         DEFINICION DE VARIABLES
--*************************************************************************
DEFINE scod_ret        CHAR(5);
DEFINE vsqlerr         INTEGER;
DEFINE s_numsol        CHAR(20);
DEFINE s_sucursal      CHAR(4);
DEFINE s_nomsuc        CHAR(40);
DEFINE s_status        CHAR(2);
DEFINE s_monto         MONEY(14,2);
DEFINE s_monto_aut     MONEY(14,2);
DEFINE s_nombrecte     CHAR(104);
DEFINE s_nombre1       CHAR(26);
DEFINE s_nombre2       CHAR(26);
DEFINE s_apell_paterno CHAR(26);
DEFINE s_apell_materno CHAR(26);
DEFINE s_comentario    VARCHAR(255,1);
DEFINE s_evalua_cc     CHAR(1);
DEFINE s_status_nvo    CHAR(2);



DEFINE s_fecha_sol     DATE;
DEFINE s_fecha_entrada DATE;
DEFINE s_eficiencia    DECIMAL(10,4);
DEFINE s_meses         SMALLINT;
DEFINE s_scoring_1     SMALLINT;
DEFINE s_scoring_2     SMALLINT;
DEFINE s_scoring_total SMALLINT;

DEFINE s_numcte        CHAR(20);
DEFINE v_cuantos       SMALLINT;
DEFINE vfecha_hoy      DATE;
DEFINE s_consulta      SMALLINT;
DEFINE s_causa         char(10);
DEFINE s_eval_min      DECIMAL(10,2);
DEFINE s_eval_max      DECIMAL(10,2);
DEFINE s_eva_min_sup   DECIMAL(5,2);
DEFINE sMesesHis       SMALLINT;


-- *************************************************************************
-- *                        ASIGNACION DE VARIABLES
-- **************************************************************************
LET scod_ret     = "000";
LET vsqlerr      = 0;
LET s_numcte     = "";
LET v_cuantos    = 0;

LET s_numsol        = "";
LET s_sucursal      = "";
LET s_nomsuc        = "";
LET s_status        = "";
LET s_monto         = 0;
LET s_monto_aut     = 0;
LET s_nombrecte     = "";
LET s_nombre1       = "";
LET s_nombre2       = "";
LET s_apell_paterno = "";
LET s_apell_materno = "";
LET s_comentario    = "";
LET s_evalua_cc     = "";
LET s_status_nvo    = "";
LET s_fecha_sol     = "";
LET s_fecha_entrada = "";
LET s_eficiencia    = "";
LET s_meses         = 0;
LET s_scoring_1     = 0;
LET s_scoring_2     = 0;
LET s_scoring_total = 0;
LET s_consulta      = 0;
LET s_causa         = '';
LET s_eval_min      = 0;
LET s_eval_max      = 0;
LET s_eva_min_sup   = 0;
LET sMesesHis       = 0;

-- **********************************************************************
-- *                        CONTROL DE ERRORES
-- ***********************************************************************
BEGIN
ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
      LET scod_ret=vsqlerr;
      RETURN scod_ret, s_numsol, s_sucursal, s_nomsuc, s_nombrecte,
         s_status, s_monto, s_monto_aut, s_fecha_sol, s_fecha_entrada,
         s_eficiencia, s_meses, s_scoring_1, s_scoring_2, s_scoring_total, s_causa;
   END IF;
END EXCEPTION;

--SET DEBUG FILE TO "/tmp/mfinis/status_sol2.out";
--TRACE ON;

-- **********************************************************************
-- *                        PROGRAMA PRINCIPAL
-- **********************************************************************


let pempresa = pempresa;
let psucursal = psucursal;
let pfechafin = pfechafin;
let pfechaini  = pfechaini;
let pstatus = pstatus;

   -- Carga la Fecha del Dia

   SELECT fecha_hoy
     INTO vfecha_hoy
     FROM bdicred:sd_fechas
    WHERE empresa = pempresa;

   -- Valida Tipo de Consulta

    If nvl(psucursal, '') = '' then
        Let psucursal = null;
    End if;
    If nvl(pstatus, '') = '' then
        Let pstatus = null;
    End if;

/*
    IF psucursal = "" AND pstatus = "" then
        LET s_consulta = 1;
    ELSE
        IF psucursal <> "" AND pstatus = "" then
            LET s_consulta = 2;
        ELSE
            IF pstatus <> "" AND psucursal = "" then
                LET s_consulta = 3;
            ELSE
                IF psucursal <> "" AND pstatus <> "" then
                    LET s_consulta = 4;
                END IF
            END IF
        END IF
    END IF
*/
    LET s_consulta = 1;

    IF s_consulta = 1 THEN
        FOREACH

        SELECT SKIP pRegistros FIRST pRecuperacion
            a.num_solicitud, a.sucursal, a.status_solicitud, nvl(a.monto_solicitado,0),
            g.nombre1,g.nombre2,g.apell_paterno,g.apell_materno,
            b.nombre, nvl(a.fecha_insert,date(1)),nvl(d.fecha_entrada,date(1)), nvl(e.situacion_pago,0), nvl(e.meses_historia,0),
--            nvl((select SUM(f.evaluacion) from bdisolic:ss_resumen_scoring f where
--            a.empresa = f.empresa AND a.num_solicitud = f.num_solicitud group by f.num_solicitud),0),
            d.comentario,e.evalua_cc,h.status_nvo
          INTO
            s_numsol,s_sucursal,s_status,s_monto,
            s_nombre1,s_nombre2,s_apell_paterno,s_apell_materno,
            s_nomsuc,s_fecha_sol,s_fecha_entrada,s_eficiencia,s_meses,
--            s_scoring_total,s_comentario,s_evalua_cc,s_status_nvo
            s_comentario,s_evalua_cc,s_status_nvo
        FROM
        (((
            bdisolic:ss_solicitudes a LEFT OUTER JOIN bdinteg:si_sucursales b
            ON a.empresa = b.empresa AND a.sucursal = b.sucursal)
--            LEFT OUTER JOIN bdisolic:ss_anexosol c
--            ON a.empresa = c.empresa AND a.num_solicitud = c.num_solicitud)
            LEFT OUTER JOIN bdisolic:ss_autorizacion d
            ON a.empresa = d.empresa AND a.num_solicitud = d.num_solicitud AND a.status_solicitud = d.status_solicitud
            and fecha_entrada = (select nvl(max(fecha_entrada),today) from bdisolic:ss_autorizacion
            where a.empresa = empresa AND a.num_solicitud = num_solicitud AND a.status_solicitud = status_solicitud ))
            LEFT OUTER JOIN bdisolic:ss_resum_scor_fin e
            ON a.empresa = e.empresa AND a.num_solicitud = e.num_solicitud)
            LEFT OUTER JOIN bdinteg:si_cliente g
            ON a.empresa = g.empresa AND a.numcte = g.numcte
            LEFT OUTER JOIN bdisolic:ss_autorizacion_especial h On a.empresa = h.empresa and a.num_solicitud = h.num_solicitud and h.status_nvo = 'RT'
        WHERE a.empresa = pempresa AND
            (a.fecha_insert >= pfechaini AND a.fecha_insert <= pfechafin) AND
            a.status_solicitud = nvl(pstatus,   a.status_solicitud) AND
            a.sucursal         = nvl(psucursal, a.sucursal)
        ORDER BY a.sucursal, b.nombre ASC


    let s_scoring_total = 0;
---cambio CAS
    LET s_nombrecte=trim(s_nombre1) || ' ' || trim(s_nombre2) || ' ' || trim(s_apell_paterno) || ' ' || trim(s_apell_materno);

    -- Calcula Scoring 2

            SELECT SUM(VALOR)
              INTO s_scoring_2
              FROM bdisolic:ss_detalle_scoring
             WHERE empresa = pempresa AND
                   num_solicitud = s_numsol;

    -- Calcula Scoring 1

            SELECT nvl(sum(nvl(puntuacion,0)),0)
              INTO s_scoring_1
              FROM bdisolic:ss_scoring_financ sf, bdisolic:ss_resum_scor_fin rsf
             WHERE rsf.empresa = pempresa
               and rsf.num_solicitud = s_numsol
               and rsf.empresa = sf.empresa
               and upper(sf.tp_solicitud) = 'T'
               and sf.circulo_credito = evalua_cc
               and sf.min_mes_hist <= rsf.meses_historia
               and sf.max_mes_hist >= rsf.meses_historia
               and sf.min_porc_pago <= rsf.situacion_pago
               and sf.max_porc_pago >= rsf.situacion_pago;

    LET s_scoring_total = s_scoring_1 + s_scoring_2;
--JCP
    SELECT evaluacion_min
      INTO s_eval_max
      FROM bdisolic:ss_scoring_solic
     WHERE empresa = pempresa AND tp_solicitud = 'T'
       AND seccion = 2 AND tpo_persona = '01' AND activa = '0';

    SELECT evaluacion_min
      INTO s_eval_min
      FROM bdisolic:ss_scoring_solic
     WHERE empresa = pempresa AND tp_solicitud = 'T'
       AND seccion = 4 AND tpo_persona = '01' AND activa = '0';

	SELECT evaluacion_min
      INTO s_eva_min_sup
	  FROM bdisolic:ss_scoring_solic
     WHERE empresa = pempresa AND tp_solicitud = 'T'
       AND seccion = 1 AND tpo_persona = '01' AND activa = '0';
--JCP
    SELECT valor INTO sMesesHis
      FROM bdisolic:ss_param
     WHERE empresa = pempresa
       AND secuencia = 308;


    IF  s_status = 'RT' then
        IF (s_scoring_total >= s_eval_min and s_scoring_total <= s_eval_max) or (s_eficiencia >= s_eva_min_sup  and s_eficiencia >= sMesesHis) then
              LET s_causa='CAC';
        ELSE
            IF trim(s_comentario) = 'Resolucion Orden de Supervision' then
                 LET s_causa='OS';
            ELSE
                IF trim(s_evalua_cc) = '1' then
                    LET s_causa='CC';
                ELSE
                    IF  s_scoring_total < s_eval_min then
                         LET s_causa='SC';
                    ELSE
                        IF not s_status_nvo is null then
                            LET s_causa='E';
                        ELSE
                            LET s_causa='OTRO';
                        END IF;
                    END IF;
                END IF;
             END IF;
        END IF;
    ELSE
         LET s_causa='';
    END IF;
---cambio CAS


       -----------------------------MONTO AUTORIZADO--------------------------------
          LET s_monto_aut=0;
		IF   s_status='AT' OR s_status='AP' THEN

		  if exists (SELECT monto_otorgado
			FROM bdicred:sd_maesdos
			where empresa=pempresa and num_credito=s_numsol) then
				SELECT monto_otorgado
					INTO s_monto_aut
					FROM bdicred:sd_maesdos
					where empresa=pempresa and num_credito=s_numsol;
		   end if;
		END IF;


            RETURN scod_ret, s_numsol, s_sucursal, s_nomsuc, s_nombrecte,
                   s_status, s_monto, s_monto_aut, s_fecha_sol, s_fecha_entrada, s_eficiencia,
                   s_meses, s_scoring_1, s_scoring_2, s_scoring_total, s_causa
            WITH RESUME;
        END FOREACH;
    END IF;
END;
END PROCEDURE
DOCUMENT
'AUTOR: L. Montserrat León Amador',
'FECHA: 03/08/2017',
'DESCRIPCION: Se realiza spl clon para agregar los parámetros de paginado.';

CREATE PROCEDURE "informix".sp_obtenereversocargospagosmancre(pUsuario CHAR(8), pIdFuncion CHAR(10), pFolio CHAR(16))
		RETURNING CHAR(5), 
					CHAR(80), 
					CHAR(20),
					CHAR(20), 
					CHAR(40), 
					CHAR(20),
					CHAR(150), 
					DECIMAL(18,2),
					DECIMAL(18,2), 
					DECIMAL(18,2),
					DECIMAL(18,2),
					DECIMAL(18,2),
					DECIMAL(18,2),
					DECIMAL(18,2),
					DECIMAL(18,2),
					DECIMAL(18,2),
					DECIMAL(18,2),
					DECIMAL(18,2),
					DECIMAL(18,2),
					DECIMAL(18,2),
					DECIMAL(18,2),
					CHAR(20),
					CHAR(50),
					CHAR(1);

	--DECLARACION DE VARIABLES
	DEFINE vCodRet    CHAR(5);
	DEFINE vCodRetSp  CHAR(6);
	DEFINE vSqlErr, vIsamErr INTEGER;
	DEFINE cNumCred   CHAR(20);
	DEFINE cFolio     CHAR(16);
	DEFINE cCodigo_retorno CHAR(6);
	DEFINE cMensaje_retorno CHAR(80);
	DEFINE cNumero_credito  CHAR(20);
	DEFINE cNumero_cliente  CHAR(20);
	DEFINE cNombre_producto CHAR(40);
	DEFINE cNumero_tarjeta  CHAR(20);
	DEFINE cNombre_cliente  CHAR(150);      
	DEFINE cImporte_pago    DECIMAL(18,2);
	DEFINE cCapital_vigente DECIMAL(18,2);
	DEFINE cCapital_transitorio DECIMAL(18,2);
	DEFINE cCapital_vencido DECIMAL(18,2);
	DEFINE cCapital_vencido_no_exigible DECIMAL(18,2);
	DEFINE cInteres_vigente DECIMAL(18,2);
	DEFINE cIva_de_interes_vigente DECIMAL(18,2);
	DEFINE cInteres_vencido DECIMAL(18,2);
	DEFINE cIva_de_interes_vencido DECIMAL(18,2);
	DEFINE cInteres_moratorio_base DECIMAL(18,2);
	DEFINE cIva_interesmoratorio_base DECIMAL(18,2);
	DEFINE cInteres_moratorio_copete DECIMAL(18,2);
	DEFINE cIva_interesmoratorio_copete DECIMAL(18,2);
	DEFINE cCapital_Total   DECIMAL(18,2);
	DEFINE cConcepto                CHAR(20);
	DEFINE cDescripcion     CHAR(50);
	DEFINE cTipo_reverso    CHAR(1);
	DEFINE dHoy     DATE;
	DEFINE dFechaUltMov     DATE;
	DEFINE cSucursal                CHAR(4);
	DEFINE cTpoSucursal             CHAR(1);
	--INICIALIZACION DE VARIABLES

	LET vCodRet = "00000";
	LET vCodRetSp = "000000";
	LET cNumCred = '';
	LET cFolio   = '';
	LET cCodigo_retorno = 0;
	LET cMensaje_retorno  = 0;
	LET cNumero_credito      = 0;
	LET cNumero_cliente      = 0;
	LET cNombre_producto     = 0;
	LET cNumero_tarjeta      = 0;
	LET cNombre_cliente      = 0;
	LET cImporte_pago                = 0;
	LET cCapital_vigente     = 0;
	LET cCapital_transitorio  = 0;
	LET cCapital_vencido  = 0;
	LET cCapital_vencido_no_exigible  = 0;
	LET cInteres_vigente  = 0;
	LET cIva_de_interes_vigente  = 0;
	LET cInteres_vencido  = 0;
	LET cIva_de_interes_vencido = 0;
	--LET cInteres_moratorio  = 0;
	--LET cIva_interesmoratorio         = 0;
	LET cInteres_moratorio_base = 0;
	LET cIva_interesmoratorio_base = 0;
	LET cInteres_moratorio_copete = 0;
	LET cIva_interesmoratorio_copete = 0;
	LET cCapital_Total       = 0;
	LET cConcepto            ='';
	LET cDescripcion     = '';
	LET cTipo_reverso        = '';
	LET dHoy = NULL;
	LET dFechaUltMov = NULL;
	LET cSucursal = '';
	LET cTpoSucursal = '';

	BEGIN
		ON EXCEPTION SET vSqlErr
			IF vSqlErr != 0 THEN
				LET vCodRet = vSqlErr;
				RETURN vCodRet,'', '', '', '', '', '', '', '', '','', '', '','', '', '','', '', '','','','', '', '';
			END IF;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_obtenereversocargospagosmancremodi.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' OR pFolio = '' THEN
			LET vCodRet = '00003';
			RETURN vCodRet, '', '', '', '', '', '', '', '', '','', '', '','', '', '','', '', '','','','', '', '';
		END IF;

		-- Seleccionamos el dÃÂ­a de hoy
		SELECT fecha_hoy
		INTO dHoy
		FROM bdicred:sd_fechas;

		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo (pUsuario, pIdFuncion) INTO vCodRet;
		IF vCodRet <> '00000' THEN
			RETURN vCodRet, '', '', '', '', '', '', '', '', '','', '', '','', '', '', '', '', '', '', '', '', '', '';
		END IF;


		FOREACH EXECUTE PROCEDURE bdicred:sp_obtenereversopagosman(pFolio)
			INTO vCodRetSp ,cMensaje_retorno, cNumero_credito, cNumero_cliente, cNombre_producto, cNumero_tarjeta, cNombre_cliente, 
				cImporte_pago, cCapital_vigente, cCapital_transitorio, 
				cCapital_vencido, cCapital_vencido_no_exigible,cCapital_Total ,cInteres_vigente, cIva_de_interes_vigente, 
				cInteres_vencido, cIva_de_interes_vencido, 
				cInteres_moratorio_base, cIva_interesmoratorio_base, 
				cInteres_moratorio_copete, cIva_interesmoratorio_copete, 
				cConcepto, cDescripcion
			
			IF vCodRetSp = '30000' THEN
				--YA FUE REVERSADO ANTERIORMENTE
				LET vCodRet = '00163'; 
			ELIF vCodRetSp = '10000' THEN
				--El folio recibido no es el ultimo movimiento
				LET vCodRet = '00164';
			ELIF vCodRetSp <> '00000' THEN
				let vCodRet = vCodRetSp;
			END IF;

			IF vCodRetSp <> '20000' THEN
				LET cTipo_reverso  = 'P';

				-- Se evalua la fecha
				SELECT FIRST 1 fecha_mov, sucursal
				INTO dFechaUltMov, cSucursal
				FROM bdicred:sd_bitacorapagos
				WHERE folio = pFolio;

				SELECT tpo_sucursal
				INTO cTpoSucursal
				FROM bdinteg:si_sucursales
				WHERE sucursal = cSucursal;

				IF cTpoSucursal <> 'N' THEN
					LET vCodRet = '00170';
				END IF;

				IF dFechaUltMov < dHoy THEN
					LET vCodRet = '00169'; -- El movimiento no corresponde al dÃÂ­a de hoy
				END IF;

				RETURN vCodRet,cMensaje_retorno, cNumero_credito, cNumero_cliente, cNombre_producto, cNumero_tarjeta, cNombre_cliente, cImporte_pago, cCapital_vigente, cCapital_transitorio, 
						cCapital_vencido, cCapital_vencido_no_exigible,cCapital_Total ,cInteres_vigente, cIva_de_interes_vigente, 
						cInteres_vencido, cIva_de_interes_vencido, 
						cInteres_moratorio_base, cIva_interesmoratorio_base, 
						cInteres_moratorio_copete, cIva_interesmoratorio_copete, 
						cConcepto, cDescripcion,cTipo_reverso WITH RESUME;                
			END IF;
		END FOREACH;

		IF vCodRetSp = '20000' THEN
			LET vCodRetSp = '000000';
			LET vCodRet='00000';

			FOREACH EXECUTE PROCEDURE bdicred:sp_obtenereversocargosman(pFolio)
				INTO vCodRetSp ,cMensaje_retorno, cNumero_credito, cNumero_cliente, cNombre_producto, cNumero_tarjeta, cNombre_cliente, cImporte_pago, cCapital_vigente, cCapital_transitorio, 
						cCapital_vencido, cCapital_vencido_no_exigible,cCapital_Total ,cInteres_vigente, cIva_de_interes_vigente, 
						cInteres_vencido, cIva_de_interes_vencido, cInteres_moratorio_base, cIva_interesmoratorio_base, cConcepto, cDescripcion           

				--YA FUE REVERSADO ANTERIORMENTE
				IF vCodRetSp = '30000' THEN
					LET vCodRet = '00167'; 
				END IF;

				--El folio recibido no es el ultimo movimiento
				IF vCodRetSp = '10000' THEN
					LET vCodRet = '00168';
				END IF;

				IF vCodRetSp <> '20000' THEN
					-- Se revisa que la sucursal en donde se realizo el cargo sea un centro de costos administrativos
					SELECT tpo_sucursal
					INTO cTpoSucursal
					FROM bdinteg:si_sucursales
					WHERE sucursal = (
					SELECT sucursal
					FROM bdicred:sd_movdia
					WHERE num_credito = (SELECT num_credito
										FROM bdicred:sd_bitacora_cargos
										WHERE folio = pFolio)
					AND folio_suc = pFolio);

					IF cTpoSucursal <> 'N' THEN
						LET vCodRet = '00170';
						RETURN vCodRet, '', '', '', '', '', '', '', '', '','', '', '','', '', '','', '', '','','','', '', '';
					END IF;

					-- Se evalua la fecha
					SELECT FIRST 1 fecha_cargo
					INTO dFechaUltMov
					FROM bdicred:sd_bitacora_cargos
					WHERE folio = pFolio;

					IF dFechaUltMov < dHoy THEN
						LET vCodRet = '00169'; -- El movimiento no corresponde al dÃÂ­a de hoy
					ELSE
						LET cTipo_reverso = 'C';
						--LET vCodRet=vCodRetSp;

						--SELECT TRIM(TRIM(cConcepto)||' - '||UPPER(concepto))
						SELECT TRIM(UPPER(concepto))
						INTO cConcepto
						FROM bdicred:sd_conceptoscargoscredito
						WHERE codigo = cConcepto;

					END IF;

					RETURN vCodRet,cMensaje_retorno, cNumero_credito, cNumero_cliente, cNombre_producto, cNumero_tarjeta, cNombre_cliente, cImporte_pago, cCapital_vigente, cCapital_transitorio, 
						cCapital_vencido, cCapital_vencido_no_exigible,cCapital_Total ,cInteres_vigente, cIva_de_interes_vigente, 
						cInteres_vencido, cIva_de_interes_vencido, 
						cInteres_moratorio_base, cIva_interesmoratorio_base, 
						cInteres_moratorio_copete, cIva_interesmoratorio_copete, 
						cConcepto, cDescripcion, cTipo_reverso WITH RESUME;               
				END IF; 

			END FOREACH;

		END IF;

		IF vCodRetSp = '20000' THEN
			LET vCodRet = '00166'; --El folio recibido no se trata de un pago manual
			RETURN vCodRet, '', '', '', '', '', '', '', '', '','', '', '','', '', '','', '', '','','','', '','';
		END IF;
	END
END PROCEDURE
DOCUMENT
'DESCRIPCION: OBTIENE REVERSOS DE PAGOS MANUALES',
'AUTOR: SAÃL ORTIZ BAEZA',
'FECHA: JULIO 2013',
'DESCRIPCION: SE AGREGAN LOS DATOS DESGLOSADOS DE LOS INTERESES MORATORIOS',
'AUTOR: OSCAR FLORES CONDE',
'FECHA: AGOSTO 2014',
'BD: BDICRED';

CREATE PROCEDURE "informix".sp_camp_primer_uso_fecha(pempresa CHAR(3), pFecha date)

RETURNING CHAR(6);

--Creado: MAHR. Mayo 2012. Campaña de Primer uso. Campañas dirigidas a los clientes que no han realizad operaciones con su tarjeta de credito entregada.
-- Subcampaña: 2 LlamadaBienvenida, 3 CorreoDirecto, 4 CrediEfectivo, 5 Recomprensa, 6 LlamadaPreCanc, 7 PreCanc-1erBim, 8 PreCanc-2doBim, 
--  9 Ctas_por_cancelar, 10 cierre de numeros de campaña 9.


--Declaracion de variables
DEFINE sql_err				INTEGER;
DEFINE isam_err				INTEGER;
DEFINE iGenero_info         INTEGER;
DEFINE error_info			CHAR(80);
DEFINE cMensaje				CHAR(80);
DEFINE cCod_ret				CHAR(6);
DEFINE vempresa				CHAR(3);
DEFINE vproceso				CHAR(4);
DEFINE cempresa             CHAR(3);
DEFINE cCod_RetIB           CHAR(6);
DEFINE dFechaHoy            DATE;
DEFINE dFecha_1_anio        DATE;
DEFINE sDia5_correcamp      SMALLINT;
DEFINE sDia21_correcamp     SMALLINT;
DEFINE sMessinactAnt        SMALLINT;
DEFINE cdelimitador         CHAR(1);
DEFINE cruta                CHAR(100);
DEFINE cnombre				CHAR(100);
DEFINE cnomarchivo          CHAR(100);
DEFINE cnomarchivo1			CHAR(100);
DEFINE cnomarchivoejecsql   CHAR(100);
DEFINE cSQL                 CHAR(2500);
DEFINE cSQL1                CHAR(1000);
DEFINE cSQL2                CHAR(1000);
DEFINE cSQL3                CHAR(500);


--SET DEBUG FILE TO "/informix/sp_camp_primer_uso.out";
--TRACE ON;

--Inicialización de variables
LET sql_err                 = 0;
LET isam_err                = 0;
LET iGenero_info            = 0;
LET error_info              = '';
LET cCod_Ret                = '000000';
LET cMensaje                = 'PROCESO EXITOSO';
LET vproceso				= '0600';
LET vempresa				= '001';
LET cempresa                = '';
LET cCod_RetIB              = '000000';
LET dFechaHoy               = DATE(1);
LET dFecha_1_anio           = DATE(1);
LET sDia5_correcamp         = 0; 
LET sDia21_correcamp        = 0; 
LET sMessinactAnt           = 0;
--LET iNum_tarjetas_ent       = 0;
LET cdelimitador            = '';
LET cruta                   = '';
LET cnombre                 = '';
LET cnomarchivo             = '';
LET cnomarchivo1			= '';
LET cnomarchivoejecsql      = '';
LET cSQL                    = '';
LET cSQL1                   = '';
LET cSQL2                   = '';
LET cSQL3                   = '';

BEGIN

    ON EXCEPTION SET sql_err, isam_err, error_info
        LET cCod_ret = sql_err;
        LET cMensaje = error_info;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, vproceso, cCod_ret, cMensaje, '02') Returning cCod_RetIB;
        RETURN cCod_ret;
	END EXCEPTION;
	
	--Directiva para lectura de tablas bloqueadas.
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, vproceso, cCod_ret, cMensaje, '01') Returning cCod_RetIB;

    -- Validacion de parámetros de entrada
    IF NVL(pEmpresa,"") = "" THEN
        LET cCod_Ret= '104001';
        SELECT descripcion INTO cMensaje 
        FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCod_Ret;

        IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, vproceso, cCod_ret, cMensaje, '02') Returning cCod_RetIB;
        RETURN cCod_Ret;
	END IF;

	--Validación de la empresa
	SELECT empresa INTO cempresa
	FROM bdinteg:si_empresas WHERE empresa = pempresa;
	IF NVL (cempresa, '') = '' THEN
        LET cCod_Ret= '104002';
        SELECT descripcion INTO cMensaje 
        FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCod_Ret;

        IF cMensaje IS NULL THEN LET cMensaje = "";  END IF;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, vproceso, cCod_ret, cMensaje, '02') Returning cCod_RetIB;
        Return cCod_Ret;
	END IF;

    -- Obtiene los dias en que se ejecuta este proceso para asignar el aviso correspondiente
    SELECT TRIM(valor_alfabetico)::SMALLINT, valor_numerico::SMALLINT INTO sDia5_correcamp, sDia21_correcamp
        FROM bdicred:"informix".sd_param_campania WHERE grupo_parametro = 'ARCH1ERUSO' AND num_parametro = 12;
    IF (NVL(sDia5_correcamp,0) = 0 OR NVL(sDia21_correcamp,0) = 0 ) THEN
        LET cCod_Ret= '104001';
        SELECT descripcion INTO cMensaje 
        FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCod_Ret;
        IF cMensaje IS NULL THEN LET cMensaje = "";  END IF;

        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, vproceso, cCod_ret, cMensaje, '02') Returning cCod_RetIB;
        Return cCod_Ret;
    END IF;

    -- Obtiene la fecha del dia de hoy
    if nvl(pFecha,date(1)) = date(1) then 
      SELECT fecha_hoy INTO dFechaHoy FROM bdinteg:"informix".si_fechas WHERE empresa = pempresa;
    else 
      Let dFechaHoy = pFecha ;
    end if;

	
    -- Campaña 2: LlamadaBienvenida: Se ejecuta dia 5 del mes
    IF (DAY(dFechaHoy) = sDia5_correcamp) OR (DAY(dFechaHoy) = sDia5_correcamp - 1) THEN    

        CALL bdicred:"informix".sp_camp_primer_uso_crea_arch(vempresa, '02', 1, dFechaHoy) Returning cCod_RetIB; 

        IF cCod_RetIB = '000000' THEN
            LET iGenero_info = 1;  -- Se genero informacion y se creara el reporte de seguimiento
        END IF;
    END IF;

    -- Campaña 3:  CorreoDirecto    Se ejecuta el dia 21 (despues del corte) de cada mes.
    IF (DAY(dFechaHoy) = sDia21_correcamp) OR (DAY(dFechaHoy) = sDia21_correcamp - 1) THEN   

        SELECT valor_numerico::SMALLINT INTO sMessinactAnt
            FROM bdicred:"informix".sd_param_campania WHERE grupo_parametro = 'ARCH1ERUSO' AND num_parametro = 14;

        CALL bdicred:"informix".sp_camp_primer_uso_crea_arch(vempresa, '03', sMessinactAnt, dFechaHoy) Returning cCod_RetIB;

        IF cCod_RetIB = '000000' THEN
            LET iGenero_info = 1;  -- Se genero informacion y se creara el reporte de seguimiento
        END IF;                    
    END IF;

    -- Campaña 4: CrediEfectivo     Se ejecuta dia 5 del mes
    IF (DAY(dFechaHoy) = sDia5_correcamp) OR (DAY(dFechaHoy) = sDia5_correcamp - 1) THEN

        SELECT valor_numerico::SMALLINT INTO sMessinactAnt
            FROM bdicred:"informix".sd_param_campania WHERE grupo_parametro = 'ARCH1ERUSO' AND num_parametro = 15;

        CALL bdicred:"informix".sp_camp_primer_uso_crea_arch(vempresa, '04', sMessinactAnt, dFechaHoy) Returning cCod_RetIB; 

        IF cCod_RetIB = '000000' THEN
            LET iGenero_info = 1;  -- Se genero informacion y se creara el reporte de seguimiento
        END IF;                    
    END IF;

    -- Campaña 5: Recomprensa       Se ejecuta los dias 21 de cada mes.
    IF (DAY(dFechaHoy) = sDia21_correcamp) OR (DAY(dFechaHoy) = sDia21_correcamp - 1) THEN

        SELECT valor_numerico::SMALLINT INTO sMessinactAnt
            FROM bdicred:"informix".sd_param_campania WHERE grupo_parametro = 'ARCH1ERUSO' AND num_parametro = 16;

        CALL bdicred:"informix".sp_camp_primer_uso_crea_arch(vempresa, '05', sMessinactAnt, dFechaHoy) Returning cCod_RetIB; 

        IF cCod_RetIB = '000000' THEN
            LET iGenero_info = 1;  -- Se genero informacion y se creara el reporte de seguimiento
        END IF;
    END IF;

    -- Campaña 6: Llamada de precancelacion     Se ejecuta dia 5 del mes
    IF (DAY(dFechaHoy) = sDia5_correcamp) OR (DAY(dFechaHoy) = sDia5_correcamp - 1) THEN

        SELECT valor_numerico::SMALLINT INTO sMessinactAnt
            FROM bdicred:"informix".sd_param_campania WHERE grupo_parametro = 'ARCH1ERUSO' AND num_parametro = 17;

        CALL bdicred:"informix".sp_camp_primer_uso_crea_arch (vempresa, '06', sMessinactAnt, dFechaHoy) Returning cCod_RetIB; 

        IF cCod_RetIB = '000000' THEN
            LET iGenero_info = 1;  -- Se genero información y se creara el reporte de seguimiento
        END IF;
    END IF;

    -- Campaña 7: Seguimiento 1er Bimestre Pre-Cancelacion.
    IF (DAY(dFechaHoy) = sDia5_correcamp) OR (DAY(dFechaHoy) = sDia5_correcamp - 1) THEN

        SELECT valor_numerico::SMALLINT INTO sMessinactAnt
            FROM bdicred:"informix".sd_param_campania WHERE grupo_parametro = 'ARCH1ERUSO' AND num_parametro = 27;

        CALL bdicred:"informix".sp_camp_primer_uso_crea_arch (vempresa, '07', sMessinactAnt, dFechaHoy) Returning cCod_RetIB; 

        IF cCod_RetIB = '000000' THEN
            LET iGenero_info = 1;  -- Se genero informacion y se creara el reporte de seguimiento
        END IF;
    END IF;

    -- Campaña 8: Seguimiento 2do Bimestre Pre-Cancelacion.
    IF (DAY(dFechaHoy) = sDia5_correcamp) OR (DAY(dFechaHoy) = sDia5_correcamp - 1) THEN

        SELECT valor_numerico::SMALLINT INTO sMessinactAnt
            FROM bdicred:"informix".sd_param_campania WHERE grupo_parametro = 'ARCH1ERUSO' AND num_parametro = 37;

        CALL bdicred:"informix".sp_camp_primer_uso_crea_arch (vempresa, '08', sMessinactAnt, dFechaHoy) Returning cCod_RetIB; 

        IF cCod_RetIB = '000000' THEN
            LET iGenero_info = 1;  -- Se genero informacion y se creara el reporte de seguimiento
        END IF;
    END IF;

    -- Campaña 9: Cuentas por cancelar
    IF (DAY(dFechaHoy) = sDia5_correcamp) OR (DAY(dFechaHoy) = sDia5_correcamp - 1) THEN

        SELECT valor_numerico::SMALLINT INTO sMessinactAnt
            FROM bdicred:"informix".sd_param_campania WHERE grupo_parametro = 'ARCH1ERUSO' AND num_parametro = 38;

        CALL bdicred:"informix".sp_camp_primer_uso_crea_arch (vempresa, '09', sMessinactAnt, dFechaHoy) Returning cCod_RetIB; 

        IF cCod_RetIB = '000000' THEN
            LET iGenero_info = 1;  -- Se genero informacion y se creara el reporte de seguimiento
        END IF;
    END IF;

    -- Campaña 10: Cierre de cifras de campaña 9: Cuentas por cancelar, y genera de reporte de cuentas canceladas.
    IF (DAY(dFechaHoy) = sDia5_correcamp) OR (DAY(dFechaHoy) = sDia5_correcamp - 1) THEN

        SELECT valor_numerico::SMALLINT INTO sMessinactAnt 
            FROM bdicred:"informix".sd_param_campania WHERE grupo_parametro = 'ARCH1ERUSO' AND num_parametro = 39;

        CALL bdicred:"informix".sp_camp_primer_uso_cierra9a10RepCanc (vempresa, '10', sMessinactAnt, dFechaHoy) Returning cCod_RetIB; 

         IF cCod_RetIB = '000000' THEN
            LET iGenero_info = 1;  -- Se genero informacion y se creara el reporte de seguimiento
        END IF;
    END IF;


    -- GENERA REPORTE DE SEGUIMIENTO DE LAS CAMPAÑAS
    IF iGenero_info = 1 THEN
                --Obtener caracter delimitador
        SELECT trim(valor_alfabetico) INTO cdelimitador FROM bdicobranza:"informix".cb_param_campania WHERE empresa = pempresa
            AND tipo_campania = 1 AND grupo_parametro = 'ARCHIVOS' AND num_parametro = 26;
        IF NVL(cDelimitador,'') = '' THEN
            LET cCod_Ret= '104004';
            SELECT descripcion INTO cMensaje FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCod_Ret;
            IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;
            CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, vproceso, cCod_ret, cMensaje, '02') Returning cCod_RetIB;
            RETURN cCod_Ret;
        END IF;

        -- Obtiene la ruta del archivo
        SELECT TRIM(valor_alfabetico) INTO cruta FROM bdicred:"informix".sd_param_campania WHERE empresa = pempresa
            AND grupo_parametro = 'ARCH1ERUSO' AND num_parametro = 1; 
    	IF NVL (cruta,'') = '' THEN
            LET cCod_Ret= '104005';
            SELECT descripcion INTO cMensaje FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCod_Ret;
            IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;
            CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, vproceso, cCod_ret, cMensaje, '02') Returning cCod_RetIB;
            RETURN cCod_Ret;
        END IF;

    	-- Obtiene el nombre del archivo con el reporte de seguimiento.
        SELECT TRIM(valor_alfabetico) INTO cnombre FROM bdicred:"informix".sd_param_campania WHERE empresa = pempresa
            AND grupo_parametro = 'ARCH1ERUSO' AND num_parametro = 24; 
        IF NVL (cnombre,'') = '' THEN
            LET cCod_Ret= '102002';
            SELECT descripcion INTO cMensaje FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCod_Ret;
            IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;
            CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, vproceso, cCod_ret, cMensaje, '02') Returning cCod_RetIB;
            RETURN cCod_Ret;
    	END IF;

        -- Asigna nombre de archivo, segun el nombre asignado en el parametro y la fecha correspondiente
        LET cnomarchivo1 =  trim(cnombre)||'Aux'||substr(year(dFechaHoy),3)||to_char(dFechaHoy,'%m%d')||'.txt';
        LET cnomarchivo  =  trim(cnombre)||substr(year(dFechaHoy),3)||to_char( dFechaHoy,'%m%d')||'.txt';
        LET cnomarchivoejecsql = 'Ejecuta_rep_seguim_1er_uso.sql';

        LET cSql='';
        LET cSql = 'echo "fecha_campaña'||';'||'entregadas desde'||';'||'entregadas hasta'||';'||'nombre campaña'||';'||'tarjetas entregadas'
                         ||';'||'tarjetas_con_telefono'||';'||'tarjetas_sin_telefono'||';'||'tarjetas_activas_con_telefono'
						 ||';'||'tarjetas_activas_sin_telefono'||';'||'tarjetas_inactivas_con_telefono'||';'||'tarjetas_inactivas_sin_telefono'
						 ||';'||'tarjetas_actcontel_canceladas'||';'||'tarjetas_actsintel_canceladas'||';'||'tarjetas_inactcontel_canceladas'||';'||'tarjetas_inactsintelcanceladas'
						 || ' " >' ||TRIM(cruta)|| cnomarchivo;
        System csql;

        LET cSQL1 = ' echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cruta) || TRIM(cnomarchivo1) || ' DELIMITER ' || ''''|| cdelimitador || ''''||'';
        --LET dFecha_1_anio = dFechaHoy - 2 units year;


        LET cSQL2 = " SELECT fecha_gen_campania, fecha_entreg_desde, fecha_entreg_hasta, trim(param.valor_alfabetico), tot_tarj_entreg_ina, "
                || " tot_tarj_contel,tot_tarj_sintel, tot_tarj_activas_contel, "
				|| " tot_tarj_activas_sintel,tot_tarj_inactivas_contel, tot_tarj_inactivas_sintel, "
				|| " tot_tarj_act_contel_canceladas,tot_tarj_act_sintel_canceladas,tot_tarj_inact_contel_canceladas,tot_tarj_inact_sintel_canceladas "
                || " FROM bdicred:cb_1eruso_rep_seguim seguim, bdicred:sd_param_campania param "
                || " WHERE param.grupo_parametro = 'ARCH1ERUSO' AND param.num_parametro in (18, 19, 20, 21, 22, 23, 40, 41, 42) "
                || " AND seguim.sub_campania = param.valor_numerico "
                || " AND seguim.fecha_gen_campania >= mdy(12,05,2015) "
                || " ORDER BY seguim.fecha_gen_campania, seguim.fecha_ejecucion, seguim.sub_campania ";

        LET cSQL3 = '">'||TRIM(cRuta)|| cnomarchivoejecsql;
        LET cSQL = trim(cSQL1) || cSQL2 || trim(cSQL3);
        System cSQL;

        LET cSQL='chmod 777 '|| TRIM(cRuta)|| cnomarchivoejecsql;
        System cSQL;

        let cSQL = 'dbaccess bdicred ' || TRIM(cRuta) || cnomarchivoejecsql;
        System cSQL;

        LET cSql = cSql;
        LET cSql = "sed 's/"||cDelimitador||"$//g' "|| TRIM(cRuta) || TRIM(cnomarchivo1) || " >> " || TRIM(cRuta) || TRIM(cnomarchivo);
        SYSTEM cSql;

    	LET cSQL = '' ;
    	LET cSQL = 'rm ' || TRIM(cruta) || cnomarchivoejecsql || ' ' || TRIM(cruta) || cnomarchivo1  ; 
        SYSTEM cSQL;

    END IF;

    -- Valida si existen las tablas temporales y las borra.
    IF EXISTS( SELECT tabname FROM sysmaster:systabnames WHERE tabname = 'sd_temp_1er_uso_telef' ) THEN
        DROP TABLE bdicred:sd_temp_1er_uso_telef;
    END IF;
 
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, vproceso, cCod_ret, cMensaje, '03')
        Returning cCod_RetIB;

	RETURN cCod_ret;

END;
END PROCEDURE;